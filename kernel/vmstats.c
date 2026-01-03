#include "types.h"
#include "spinlock.h"
#include "defs.h"
#include "vmstats.h"

// 这些变量要有“唯一的定义”
uint64 kalloc_cnt = 0;
uint64 copyin_bytes = 0;
uint64 copyout_bytes = 0;

struct {
  struct spinlock lock;
  uint64 cow_faults;
  uint64 lazy_faults;
  uint64 shm_faults;
} vmstats;

void
vmstatsinit(void)
{
  initlock(&vmstats.lock, "vmstats");
}

// 给 sys_vmstats 用：读出一份快照
void
vmstats_snapshot(struct vmstats_user *out)
{
  acquire(&vmstats.lock);
  out->cow_faults  = vmstats.cow_faults;
  out->lazy_faults = vmstats.lazy_faults;
  out->shm_faults  = vmstats.shm_faults;
  release(&vmstats.lock);

  out->kalloc_cnt = kalloc_cnt;
  out->copyin_bytes = copyin_bytes;
  out->copyout_bytes = copyout_bytes;
}




// 给其他模块做计数：不追求绝对精确可以不加锁
void vmstats_inc_cow(void)  { acquire(&vmstats.lock); vmstats.cow_faults++;  release(&vmstats.lock); }
void vmstats_inc_lazy(void) { acquire(&vmstats.lock); vmstats.lazy_faults++; release(&vmstats.lock); }
void vmstats_inc_shm(void)  { acquire(&vmstats.lock); vmstats.shm_faults++;  release(&vmstats.lock); }
