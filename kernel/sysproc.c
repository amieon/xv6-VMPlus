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
vma_alloc_index(struct proc *p)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used)
      return i;
  }
  return -1;
}

static int
vma_find_overlap(struct proc *p, uint64 a, uint64 b)
{
  for(int i = 0; i < NVMA; i++){
    if(!p->vmas[i].used) continue;
    uint64 s = p->vmas[i].start;
    uint64 e = p->vmas[i].end;
    if(!(b <= s || a >= e))   // overlap
      return i;
  }
  return -1;
}

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

    // 再更新 VMA（四种情况）
    if(seg_start <= v->start && seg_end >= v->end){
      // 覆盖整条 VMA：删除
      v->used = 0;
      v->start = v->end = 0;
      v->prot = v->flags = 0;
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

  return 0;
}

