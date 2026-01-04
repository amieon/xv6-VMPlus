## xv6-VMPlus 

![Language](https://img.shields.io/badge/language-C%20%26%20Assembly-blue)![Arch](https://img.shields.io/badge/arch-RISC--V-green)![License](https://img.shields.io/badge/license-MIT-orange.svg)
基于 xv6 操作系统的虚拟内存与高效 IPC 机制设计与实现



## 项目简介

This project extends xv6 with copy-on-write fork and zero-copy shared memory IPC.

本项目基于教学操作系统 xv6，对其虚拟内存管理与进程间通信机制进行了系统级扩展。项目重点解决 xv6 在 fork、IPC 以及并发场景下的性能与语义局限，引入了写时复制（COW）、内存映射（mmap/munmap）、共享内存（SHM）以及基于阻塞的同步机制，使系统行为更接近真实操作系统。


------


## 快速打开实验文档

- [实验文档](docs/实验文档.pdf)
- [函数手册](docs/函数手册.pdf)


------

## 编译与运行

```
# 1) 进入工程目录
cd <project3035746-357447>

# 2)安装交叉编译工具和 QEMU
sudo apt update
sudo apt install -y gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu qemu-system-riscv64 qemu-user

# 3) 编译
make clean
make TOOLPREFIX=riscv64-unknown-elf-

# 4) 运行
make qemu

# 5) 退出
# Ctrl+a x
```

## 核心改造内容

- 引入 **VMA（Virtual Memory Area）抽象**，将进程地址空间从线性堆模型扩展为多区域可管理模型
- 实现 **写时复制（COW）fork**，显著降低 fork 的内存与时间开销
- 基于 mmap 实现 **共享匿名内存（SHM）**，支持零拷贝进程间通信
- 实现 **IPC_RMID 语义**，通过对象模型与延迟回收正确管理共享内存生命周期
- 基于 sleep/wakeup 实现 **阻塞同步原语**，避免忙等待带来的 CPU 浪费

------

## 关键设计思想

本项目的核心设计思想在于：
 **通过明确虚拟内存系统中的关键不变量，将 mmap、COW、共享内存与进程生命周期管理统一到同一内存框架中。**

相比简单地增加系统调用，本项目更关注机制之间的语义一致性，避免在共享内存与进程退出、exec 等场景下产生资源错误或内核崩溃。

------

## 实验结果摘要

对比传统 pipe IPC 与基于共享内存的 IPC 实现，在 8MB 数据传输场景下：

- 执行时间从 **353 ticks 降低至 138 ticks**
- 用户态–内核态数据拷贝从 **约 16MB 降至近 0**
- fork 的内存开销由“按地址空间大小”降低为“按实际写入页数”

实验结果表明，引入共享内存与写时复制机制在性能与可扩展性上具有显著优势。

------

## 文档结构说明

- 第 2 章：设计概要与方案取舍
- 第 3–5 章：虚拟内存、mmap、COW 与共享内存设计
- 第 6 章：同步机制设计
- 第 7 章：实验评估与性能分析



## 队伍信息

中国海洋大学 | T202510423998043 | 冲刺冲 | “OS原理”赛道 | vx6-VMPlus

赛道为：各参赛队可结合本校操作系统课程实验内容，针对其中某个实验模块做拓展延伸和优化创新，引入更复杂的算法和更先进的设计，在功能、性能、可靠性等方面取得进步。推荐改进比较复杂的模块，如进程管理、内存管理、文件系统、并发控制等。
