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


#define MMAPBASE  (0x40000000L)  // 可以选别的，只要在用户区且不撞 heap/stack

static int
vma_overlaps(struct proc *p, uint64 start, uint64 end)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used) continue;
    uint64 s = p->vmas[i].start;
    uint64 e = p->vmas[i].end;
    if(!(end <= s || start >= e))
      return 1;
  }
  return 0;
}

static uint64
vma_find_space(struct proc *p, uint64 len)
{
  uint64 va = MMAPBASE;
  for(int tries = 0; tries < 4096; tries++){
    uint64 start = va;
    uint64 end   = va + len;
    if(end >= MAXVA) return 0;
    if(!vma_overlaps(p, start, end))
      return start;
    va += len; //按 len 跳（不做精细 first-fit）,后面再改
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

uint64
sys_mmap(void)
{
  uint64 addr;
  int len, prot, flags;

  argaddr(0, &addr);
  argint(1, &len);
  argint(2, &prot);
  argint(3, &flags);

  if(addr != 0) return (uint64)-1;
  if(len <= 0) return (uint64)-1;
  if((flags & MAP_ANON) == 0) return (uint64)-1;
  if((prot & PROT_READ) == 0) return (uint64)-1; // 最小版：至少可读

  struct proc *p = myproc();
  uint64 plen = PGROUNDUP((uint64)len);

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;

  uint64 va = vma_find_space(p, plen);
  if(va == 0) return (uint64)-1;

  v->used = 1;
  v->start = va;
  v->end = va + plen;
  v->prot = prot;
  v->flags = flags;

  return va;
}

uint64
sys_munmap(void)
{
  uint64 addr;
  int len;

  argaddr(0, &addr);
  argint(1, &len);

  if(addr % PGSIZE != 0) return (uint64)-1;   // 要求页对齐
  if(len <= 0) return (uint64)-1;

  struct proc *p = myproc();
  uint64 plen = PGROUNDUP((uint64)len);
  // 找到起点匹配的 vma
  struct vma *v = 0;
  for(int i = 0; i < NVMA; i++){
    if(p->vmas[i].used && p->vmas[i].start == addr){
      v = &p->vmas[i];
      break;
    }
  }
  if(v == 0) return (uint64)-1;
  if(plen != (v->end - v->start)) return (uint64)-1;

  // 解除映射：已经分配的页会被 kfree/refcnt 回收，没分配的页 uvmunmap 会跳过
  
  uvmunmap(p->pagetable, v->start, plen/PGSIZE, 1);

  v->used = 0;
  v->start = v->end = 0;
  v->prot = v->flags = 0;

  return 0;
}
