# xv6-VMPlus

![Language](https://img.shields.io/badge/language-C%20%26%20Assembly-blue)
![Arch](https://img.shields.io/badge/arch-RISC--V-green)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

> **基于 xv6 的虚拟内存与高效 IPC 扩展**  
> VMA + mmap/munmap + Copy-on-Write fork + Shared Anonymous Memory (SHM) + Blocking Semaphore  
> 目标：在保持 xv6 简洁结构的前提下，让系统在 **fork 可扩展性、零拷贝 IPC、并发同步与资源回收语义** 上更接近真实操作系统。

---

## 目录

- [项目亮点](#项目亮点)
- [快速开始](#快速开始)
- [核心功能](#核心功能)
- [设计与实现总览](#设计与实现总览)
- [系统调用与使用示例](#系统调用与使用示例)
- [代码改动一览](#代码改动一览)
- [实验评估与性能](#实验评估与性能)
- [已知局限与后续计划](#已知局限与后续计划)
- [文档与目录结构](#文档与目录结构)
- [队伍信息](#队伍信息)

---

## 项目亮点

- **统一的虚拟内存抽象（VMA）**：将进程地址空间从单一 `sbrk` 线性堆扩展为可管理的多区域模型
- **mmap/munmap + 懒分配（Lazy Allocation）**：映射时仅记录元数据，首次访问触发缺页后再分配/映射物理页
- **COW fork（写时复制）**：fork 阶段共享物理页，写入时按需拆分；fork 成本更接近“实际写入页数”
- **共享匿名内存（SHM）零拷贝 IPC**：多进程共享同一组物理页，避免 pipe 的双向拷贝开销
- **IPC_RMID 语义与延迟回收**：共享内存“标记删除但不立即释放”，直至最后一个引用释放
- **阻塞信号量同步**：基于 `sleep/wakeup` 的阻塞语义，避免用户态忙等待造成 CPU 浪费

---

## 快速开始

### 依赖

- RISC-V 交叉编译工具链
- QEMU（riscv64）

Ubuntu 示例：

```bash
sudo apt update
sudo apt install -y gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu \
  qemu-system-riscv64 qemu-user
```

### 编译与运行

```bash
# 1) 进入工程目录
cd <your-xv6-project-dir>

# 2) 编译
make clean
make TOOLPREFIX=riscv64-unknown-elf-

# 3) 运行
make qemu

# 4) 退出 QEMU
# Ctrl+a x
```

---

## 核心功能

### 1) VMA + mmap/munmap（匿名映射）

- 地址空间引入 **VMA（Virtual Memory Area）** 数组，记录每段映射的 `[start, end)`、权限、类型（匿名/共享）等元数据
- `mmap` 默认 **不立刻分配物理页**，首次访问触发 page fault 后由 fault handler 分配/映射
- `munmap` 支持对映射区间的 **局部解除映射**：实现中包含“拆分预检查”，保证 VMA 拆分操作的原子性

### 2) COW fork（写时复制）

- `fork` 时不再复制整段用户内存，而是：
  - 父子进程共享同一物理页
  - 清除写权限并设置 COW 标记
  - 引用计数 +1
- 写入 COW 页时触发 **写保护缺页**：
  - 若引用计数为 1：直接恢复可写
  - 否则：分配新页、拷贝内容、更新映射并减少旧页引用计数
- **copyout 也兼容 COW**：避免“内核写用户地址绕过 COW”造成父子进程数据污染

### 3) SHM：共享匿名内存（零拷贝）

- 以 `key` 标识共享匿名对象（对象模型 + 引用计数）
- 支持 **按页懒分配**：对象内部 `pa[i]==0` 表示该页尚未分配，首次访问才分配
- 支持 **IPC_RMID**：删除只是“标记”，禁止新 attach，但老进程仍可访问；引用归零时回收

### 4) 阻塞信号量（与 SHM 配套）

- 面向用户态提供最小 P/V 语义（等待时阻塞），基于内核 `sleep/wakeup`
- 与共享内存配合实现经典 producer-consumer：共享内存负责数据，信号量负责同步

---

## 设计与实现总览

### 缺页处理链（统一入口）

在 `usertrap()` 中对 page fault 进行分流，形成统一的缺页处理链：

```text
写缺页（scause=15）: cowbreak  → vmafault(写) → vmfault
读缺页（scause=13）:            vmafault(读) → vmfault
```

- **优先处理 COW**：否则会把“应复制的共享只读页”误当成普通缺页，破坏隔离语义
- mmap/SHM 与 lazy-heap 共用 fault handler，减少多条分配路径导致的边界条件错误

### 内存安全不变量（关键语义）

- **物理页生命周期独立于页表**：页表销毁只代表解除映射，物理页是否释放取决于引用计数是否归零
- **共享页写入必须可控**：共享状态下页表必须是只读；写入通过缺页异常统一进入复制/拆页逻辑
- **exit/exec/munmap 统一回收语义**：先解除映射，再更新对象引用与物理页引用，避免 freewalk 类崩溃

---

## 系统调用与使用示例

> 说明：不同分支可能函数签名略有差异，以下以“语义解释 + 使用方式”为主，具体以 `user/user.h` 为准。

### mmap：匿名映射 / 共享匿名映射

```c
// 伪代码示例：申请 4 页匿名映射（lazy 分配）
void *p = mmap(0, 4*4096, PROT_READ|PROT_WRITE, MAP_ANON, -1);
memset(p, 0, 4*4096);  // 首次访问触发缺页，按需分配
```

共享匿名映射（key 相同即共享）：

```c
int key = 1;
void *shm = mmap(0, 8*4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
// 父子/两个进程映射同一 key，可实现零拷贝共享
```

### munmap：解除映射

```c
munmap(shm, 2*4096);   // 支持局部解除（可能触发 VMA 拆分）
```

### shmctl：IPC_RMID

```c
shmctl(key, IPC_RMID); // 标记删除：禁止新 attach，引用归零时回收
```

### 信号量（P/V）

```c
sem_wait(semid);  // P：资源不足则阻塞
sem_post(semid);  // V：释放资源并唤醒等待者
```

---

## 代码改动一览


| 模块 | 关键文件 | 主要改动 |
|---|---|---|
| 物理页引用计数 | `kernel/kalloc.c` | 引入 `kref_*`，改造 `kfree()/freerange()`，共享页/COW 页安全回收 |
| COW fork | `kernel/vm.c` | `uvmcopy()` 改为共享+只读+COW；新增 `cowbreak()`；`copyout()` 兼容 COW |
| 懒分配 | `kernel/vm.c` | `vmfault()` 支持 lazy-heap；`vmafault()` 支持 mmap/SHM 按需映射 |
| 缺页分流 | `kernel/trap.c` | `usertrap()` 中按 scause 分流：COW → VMA → lazy-heap |
| mmap/munmap/shmctl | `kernel/sysproc.c` | `sys_mmap/sys_munmap/sys_shmctl`；自动选址；`munmap` split 预检查 |
| 共享内存对象表 | `kernel/shm.c`, `kernel/shm.h` | `NSHM` 对象表、按 key 管理、按页 lazy、IPC_RMID、refcnt 回收 |
| 进程生命周期集成 | `kernel/proc.h`, `kernel/proc.c` | `vmas[NVMA]`；fork 复制 VMA 并对 key 去重；`vma_release_all()` + `shm_put` 去重 |
| 系统调用挂接 | `kernel/syscall.c` | 添加 `SYS_mmap/SYS_munmap/SYS_shmctl` 以及 sem 相关接口 |

---

## 实验评估与性能

### IPC：Pipe vs SHM+SEM（8MB 负载）

| 指标 | PIPE IPC | SHM+SEM IPC | 结论 |
|---|---:|---:|---|
| time (ticks) | 353 | 138 | **≈2.56× 更快** |
| copyin_bytes | 8,388,608 | 0 | **几乎消除用户→内核拷贝** |
| copyout_bytes | 8,388,664 | 48 | **几乎消除内核→用户拷贝** |
| kalloc | 8 | 28 | SHM 首次访问有一次性分配成本 |
| faults | cow=1,lazy=0,shm=0 | cow=1,lazy=33,shm=33 | lazy/SHM 缺页属预期 |

> 注：SHM 方案的缺页与分配增加主要来自“首次访问的按需映射”，但总体成本远小于 pipe 的大规模数据拷贝。

### 如何复现

在 xv6 shell 中运行：

```bash
$ ipc_bench
```

---

## 已知局限与后续计划

- 当前仅实现匿名映射，**未实现 file-backed mmap**
- VMA 管理采用固定大小数组（可进一步换成链表/平衡树）
- 信号量为最小实现，暂无超时/公平性策略
- 压测规模受 xv6 资源限制，未覆盖极端高并发长时间稳定性场景

---

## 文档与目录结构

### 文档

- [实验文档](docs/实验文档.pdf)
- [函数手册](docs/函数手册.pdf)

### 目录结构

```text
.
├── kernel/
├── user/
├── docs/
   ├── 实验文档.pdf
   └── 函数手册.pdf

```

---

## 队伍信息

中国海洋大学 | T202510423998043 | 冲刺冲 | “OS原理”赛道 | xv6-VMPlus
