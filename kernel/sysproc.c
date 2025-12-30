#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

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


#define MMAPBASE  (0x40000000L)           // 1GB处，远离0起步的heap
#define MMAPTOP   (TRAPFRAME - 10*PGSIZE) // 离 trapframe 留点余量


static uint64
vma_next_conflict_end(struct proc *p, uint64 start, uint64 end)
{
  uint64 best = 0;
  for(int i=0;i<NVMA;i++){
    if(!p->vmas[i].used) continue;
    uint64 s = p->vmas[i].start;
    uint64 e = p->vmas[i].end;
    if(!(end <= s || start >= e)){
      // overlap，候选跳到这个vma的结尾
      if(best == 0 || e < best) best = e;
    }
  }
  return best; // 0表示无冲突
}

static uint64
vma_find_space(struct proc *p, uint64 len)
{
  len = PGROUNDUP(len);

  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    uint64 start = va;
    uint64 end = va + len;

    uint64 jump = vma_next_conflict_end(p, start, end);
    if(jump == 0){
      return start; // 找到空洞
    }

    // 跳到冲突区域末尾，再页对齐
    va = PGROUNDUP(jump);
  }
  return 0;
}


static struct vma*
vma_alloc_slot(struct proc *p)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used)
      return &p->vmas[i];
  }
  return 0;
}

struct vma*
vma_find(struct proc *p, uint64 va)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used) continue;
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
      return &p->vmas[i];
  }
  return 0;
}

static int
vma_find_index(struct proc *p, uint64 addr)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used) continue;
    if(addr >= p->vmas[i].start && addr < p->vmas[i].end)
      return i;
  }
  return -1;
}
static int
vma_alloc_index(struct proc *p)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used)
      return i;
  }
  return -1;
}

uint64
sys_mmap(void)
{
  uint64 addr;
  int len, prot, flags;

  argaddr(0, &addr);
  argint(1, &len);
  argint(2, &prot);
  argint(3, &flags);


  if(len <= 0) return -1;
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return -1;                
  if(plen > (MMAPTOP - MMAPBASE)) return -1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return -1;  
  if((flags & MAP_ANON) == 0) return -1;
  if(addr != 0) return -1;            

  struct proc *p = myproc();

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;

  uint64 va = vma_find_space(p, plen);
  if(va == 0) return (uint64)-1;
  
  v->used = 1;
  v->start = va;
  v->end = va + plen;
  v->prot = prot;
  v->flags = flags;

  if(va < MMAPBASE || va + plen > MMAPTOP) return -1;

  return va;
}


uint64
sys_munmap(void)
{
  struct proc *p = myproc();
  uint64 addr;
  int len;

  argaddr(0, &addr);
  argint(1, &len);

  if(len <= 0) return (uint64)-1;
  if(addr % PGSIZE) return (uint64)-1;

  uint64 unmap_len = PGROUNDUP((uint64)len);
  uint64 unmap_start = addr;
  uint64 unmap_end = addr + unmap_len;

  // 溢出保护
  if(unmap_end < unmap_start) return (uint64)-1;

  int vi = vma_find_index(p, unmap_start);
  if(vi < 0) return (uint64)-1;

  struct vma *v = &p->vmas[vi];

  // 要求整个范围落在同一个 VMA 里（最小版）
  if(unmap_end > v->end) return (uint64)-1;

  // 先拆页表映射（已分配的页会被释放；未分配的页 uvmunmap 会跳过）
  uvmunmap(p->pagetable, unmap_start, unmap_len/PGSIZE, 1);

  // 4种情况
  // 从头删
  if(unmap_start == v->start && unmap_end < v->end){
    v->start = unmap_end;
    return 0;
  }

  // 从尾删
  if(unmap_start > v->start && unmap_end == v->end){
    v->end = unmap_start;
    return 0;
  }

  // 正好整段删光
  if(unmap_start == v->start && unmap_end == v->end){
    v->used = 0;
    v->start = v->end = 0;
    v->prot = v->flags = 0;
    return 0;
  }

  // 中间删 -> 分裂成两段
  // [v->start .... unmap_start)  和  [unmap_end .... v->end)
  if(unmap_start > v->start && unmap_end < v->end){
    int ni = vma_alloc_index(p);
    if(ni < 0){
      // 没槽位可分裂：这里返回 -1 会导致“页表已拆但 VMA 没更新”
      // 为了稳，宁可直接 kill 或 panic，但实验建议：返回 -1 并 setkilled 更直观
      // 简单处理：直接 panic，逼你增大 NVMA 或实现合并策略
      panic("munmap: no vma slot for split");
    }

    // 新 VMA 记录右半段
    p->vmas[ni] = *v;
    p->vmas[ni].start = unmap_end;
    p->vmas[ni].end   = v->end;

    // 原 VMA 变成左半段
    v->end = unmap_start;

    return 0;
  }

  // 理论上不会走到这
  return (uint64)-1;
}
