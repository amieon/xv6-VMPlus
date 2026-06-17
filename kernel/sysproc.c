#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "vmstats.h"


uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}


/*
 * 内存映射相关常量定义
 */
#define MMAPBASE  (0x40000000L)           // mmap内存区域起始地址（1GB处，远离堆）
#define MMAPTOP   (TRAPFRAME - 10*PGSIZE) // mmap内存区域结束地址（离trapframe留有安全余量）


/*
 * 查找与给定地址范围冲突的VMA的最小结束地址
 * 
 * 参数：
 *   p     - 进程指针
 *   start - 检查的起始地址
 *   end   - 检查的结束地址
 * 
 * 返回值：
 *   与给定范围冲突的所有VMA中最小的结束地址；如果没有冲突则返回0
 * 
 * 用途：
 *   在vma_find_space中用于快速跳过冲突区域，提高查找可用地址空间的效率
 */
static uint64
vma_next_conflict_end(struct proc *p, uint64 start, uint64 end)
{
  uint64 best = 0;
  for(int i=0; i<NVMA; i++){
    if(!p->vmas[i].used) continue;
    uint64 s = p->vmas[i].start;
    uint64 e = p->vmas[i].end;
    if(!(end <= s || start >= e)){
      // 存在地址重叠，记录这个VMA的结束地址作为候选
      if(best == 0 || e < best) best = e;
    }
  }
  return best; // 0表示无冲突
}

/*
 * 查找适合映射指定长度内存的可用虚拟地址空间
 * 
 * 参数：
 *   p   - 进程指针
 *   len - 需要映射的内存长度
 * 
 * 返回值：
 *   找到的可用虚拟地址起始位置；如果没有足够空间则返回0
 * 
 * 查找范围：
 *   在MMAPBASE到MMAPTOP之间查找连续的、大小为PGROUNDUP(len)的空闲区域
 * 
 * 算法：
 *   使用快速跳转算法，跳过已知的冲突区域，提高查找效率
 */
static uint64
vma_find_space(struct proc *p, uint64 len)
{
  len = PGROUNDUP(len);  // 将长度向上对齐到页边界

  // 在MMAP区域内查找可用空间
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    uint64 start = va;
    uint64 end = va + len;

    // 检查当前地址范围是否与现有VMA冲突
    uint64 jump = vma_next_conflict_end(p, start, end);
    if(jump == 0){
      return start;  // 找到没有冲突的空闲区域
    }

    // 跳到冲突区域的末尾，继续查找
    va = PGROUNDUP(jump);
  }
  return 0;  // 没有找到足够大小的空闲区域
}


/*
 * 分配一个空闲的VMA槽位
 * 
 * 参数：
 *   p - 进程指针
 * 
 * 返回值：
 *   指向空闲VMA槽位的指针；如果没有空闲槽位则返回0
 * 
 * 说明：
 *   每个进程有NVMA个VMA槽位，用于跟踪进程的内存映射
 */
static struct vma*
vma_alloc_slot(struct proc *p)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used)
      return &p->vmas[i];
  }
  return 0;  // 没有空闲的VMA槽位
}

/*
 * 根据虚拟地址查找对应的VMA
 * 
 * 参数：
 *   p  - 进程指针
 *   va - 要查找的虚拟地址
 * 
 * 返回值：
 *   指向包含该虚拟地址的VMA的指针；如果没有找到则返回0
 * 
 * 注意：
 *   该函数是内核导出的公共接口，用于内存管理和缺页异常处理
 */
struct vma*
vma_find(struct proc *p, uint64 va)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used) continue;
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
      return &p->vmas[i];
  }
  return 0;  // 没有找到包含该虚拟地址的VMA
}


/*
 * 分配一个空闲的VMA索引
 * 
 * 参数：
 *   p - 进程指针
 * 
 * 返回值：
 *   空闲VMA的索引；如果没有空闲槽位则返回-1
 * 
 * 用途：
 *   主要用于VMA分割操作，当需要将一个VMA分成两个时使用
 */
static int
vma_alloc_index(struct proc *p)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used)
      return i;
  }
  return -1;  // 没有空闲的VMA索引
}

/*
 * 查找与给定地址范围重叠的VMA
 * 
 * 参数：
 *   p - 进程指针
 *   a - 检查的起始地址
 *   b - 检查的结束地址
 * 
 * 返回值：
 *   与给定范围重叠的第一个VMA的索引；如果没有重叠则返回-1
 * 
 * 重叠判断条件：
 *   当!(b <= s || a >= e)时存在重叠
 */
static int
vma_find_overlap(struct proc *p, uint64 a, uint64 b)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used) continue;
    uint64 s = p->vmas[i].start;
    uint64 e = p->vmas[i].end;
    if(!(b <= s || a >= e))   // 存在地址重叠
      return i;
  }
  return -1;  // 没有找到重叠的VMA
}

/*
 * 查找大于等于指定地址的下一个VMA起始地址
 * 
 * 参数：
 *   p - 进程指针
 *   x - 基准地址
 * 
 * 返回值：
 *   大于等于x的最小VMA起始地址；如果没有则返回(uint64)-1
 * 
 * 用途：
 *   在munmap等操作中用于跳过空闲区域，提高处理效率
 */
static uint64
vma_next_start(struct proc *p, uint64 x)
{
  uint64 best = (uint64)-1;
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used) continue;
    uint64 s = p->vmas[i].start;
    if(s >= x && s < best) best = s;
  }
  return best;
}
/*
 * 检查进程是否有指定key的共享内存VMA
 * 
 * 参数：
 *   p    - 进程指针
 *   key  - 共享内存键值
 *   skip - 要跳过检查的VMA（用于删除操作时避免自己检查自己）
 * 
 * 返回值：
 *   1表示存在匹配的共享内存VMA，0表示不存在
 * 
 * 用途：
 *   用于判断进程是否还有其他VMA引用同一个共享内存对象
 */
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
  for(int i = 0; i < NVMA; i++){
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    if(v->used && v->is_shm && v->shm_key == key)
      return 1;
  }
  return 0;
}

uint64
sys_mmap(void)
{
  uint64 addr;
  int len, prot, flags, key = -1;
  int did_shm_get = 0;
  int need_get = 0;
  int npages = 0;

  argaddr(0, &addr);
  argint(1, &len);
  argint(2, &prot);
  argint(3, &flags);
  argint(4, &key);

  if(len <= 0) return (uint64)-1;
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return (uint64)-1;
  if(plen > (MMAPTOP - MMAPBASE)) return (uint64)-1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return (uint64)-1;
  if((flags & MAP_ANON) == 0) return (uint64)-1;
  if(addr != 0) return (uint64)-1;

  struct proc *p = myproc();

  //先把“是否需要 shm_get”算出来（此时还没创建/污染 vma）
  if(flags & MAP_SHARED){
    if(key < 0) return (uint64)-1;
    npages = plen / PGSIZE;

    // rmid 后禁止新 attach
    if(shm_is_deleted(key))
      return (uint64)-1;

    // 按进程计数：本进程首次引用才 shm_get
    if(!proc_has_shm_key(p, key, 0))
      need_get = 1;
  }

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;

  // 先清空这条 slot，避免失败时留下脏状态
  memset(v, 0, sizeof(*v));
  v->shm_key = -1;

  uint64 va = vma_find_space(p, plen);
  if(va == 0) goto bad;
  if(va < MMAPBASE || va + plen > MMAPTOP) goto bad;

  // 先写入 vma 基本信息
  v->used  = 1;
  v->start = va;
  v->end   = va + plen;
  v->prot  = prot;
  v->flags = flags;

  if(flags & MAP_SHARED){
    if(need_get){
      if(shm_get(key, npages) < 0)
        goto bad;
      did_shm_get = 1;
    }
    v->is_shm = 1;
    v->shm_key = key;
  }

  return va;

bad:
  if(did_shm_get){
    shm_put(key);
  }
  if(v){
    v->used = 0;
    v->is_shm = 0;
    v->shm_key = -1;
    v->start = v->end = 0;
    v->prot = v->flags = 0;
  }
  return (uint64)-1;
}




/*
 * 删除或重置VMA结构
 * 
 * 参数：
 *   p - 进程指针
 *   v - 要删除的VMA指针
 * 
 * 操作：
 *   1. 如果VMA未使用，直接返回
 *   2. 如果是共享内存VMA，检查是否还有其他VMA引用同一共享内存对象
 *   3. 如果没有其他引用，调用shm_put释放共享内存
 *   4. 重置VMA的所有字段为初始状态
 * 
 * 注意：
 *   该函数只删除VMA结构，不会释放对应的物理内存或页表项
 */
static void
vma_delete(struct proc *p, struct vma *v)
{
  if(v->used == 0) return;

  if(v->is_shm){
    int key = v->shm_key;
    // 检查是否还有其他VMA引用同一个共享内存对象
    if(!proc_has_shm_key(p, key, v)){
      shm_put(key);  // 没有其他引用，释放共享内存
    }
  }

  // 重置VMA字段为初始状态
  v->used = 0;
  v->start = v->end = 0;
  v->prot = v->flags = 0;
  v->is_shm = 0;
  v->shm_key = -1;
}


uint64
sys_munmap(void)
{
  struct proc *p = myproc();
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
  argint(1, &len);

  if(len <= 0) return (uint64)-1;


  uint64 a = PGROUNDDOWN(uaddr);
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
  if(b < a) return (uint64)-1;  // 溢出了

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
      uint64 ns = vma_next_start(p, cur);
      if(ns == (uint64)-1 || ns >= b) break;
      cur = ns;
      continue;
    }
    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    uint64 seg_end   = b   < v->end   ? b   : v->end;

    // 如果切在中间需要 split
    if(v->start < seg_start && seg_end < v->end)
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    // 不做任何事，保持一致性
    return (uint64)-1;
  }

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
      uint64 ns = vma_next_start(p, cur);
      if(ns == (uint64)-1 || ns >= b) break;
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    uint64 seg_end   = b   < v->end   ? b   : v->end;

    // 先拆页表（按页）
    if(seg_end > seg_start){
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
      // 覆盖整条VMA删除
      // printf("munmap: deleting vma key=%d used=%d [%p,%p)\n",
      //  v->shm_key, v->used, (void *)v->start, (void *)v->end);

      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    } else if(seg_start > v->start && seg_end >= v->end){
      // 从尾砍
      v->end = seg_start;
    } else {
      // 中间砍
      int ni = vma_alloc_index(p);
      // 预检查保证一定有
      p->vmas[ni] = *v;
      p->vmas[ni].start = seg_end;
      p->vmas[ni].end   = v->end;

      v->end = seg_start;
    }

    cur = seg_end;
  }
  //shm_dump(1);
  return 0;
}

uint64
sys_shmctl(void)
{
  int key, cmd;
  argint(0, &key);
  argint(1, &cmd);
  return shm_ctl(key, cmd);
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    return -1;

  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);  
  }
  release(&tickslock);
  return 0;
}


uint64
sys_vmstats(void)
{
  uint64 uaddr;
  argaddr(0, &uaddr);

  struct vmstats_user s;
  vmstats_snapshot(&s);

  extern uint64 kalloc_cnt, copyin_bytes, copyout_bytes, fork_copy_pages, fork_share_pages;
  s.kalloc_cnt = kalloc_cnt;
  s.copyin_bytes = copyin_bytes;
  s.copyout_bytes = copyout_bytes;
  s.fork_copy_pages  = fork_copy_pages;   
  s.fork_share_pages = fork_share_pages;  

  if(copyout(myproc()->pagetable, uaddr, (char*)&s, sizeof(s)) < 0)
    return -1;
  return 0;
}