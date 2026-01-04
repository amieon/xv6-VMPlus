// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;


/*
 * 物理页引用计数管理结构
 * 
 * 该结构用于跟踪系统中每个物理页的引用计数，实现了Copy-On-Write和共享内存等功能。
 * 引用计数确保物理页在被多个进程或组件引用时不会被过早释放。
 */
struct {
  struct spinlock lock;        // 保护引用计数的自旋锁
  int refcnt[MAXPAGES];        // 每个物理页的引用计数数组，通过PA2IDX(pa)索引
} kref;

/*
 * 获取指定物理页的当前引用计数
 * 
 * 参数：
 *   pa - 物理页的起始地址
 * 
 * 返回值：
 *   该物理页的当前引用计数
 * 
 * 注意：
 *   - 此函数需要通过PA2IDX将物理地址转换为引用计数数组的索引
 *   - 操作过程中会获取kref锁以保证线程安全
 */
int     
kref_get(void *pa){
  int n;
  acquire(&kref.lock);
  n = kref.refcnt[PA2IDX(pa)];
  release(&kref.lock);
  return n;
}
/*
 * 增加指定物理页的引用计数
 * 
 * 参数：
 *   pa - 物理页的起始地址
 * 
 * 返回值：
 *   增加后的引用计数
 * 
 * 用途：
 *   - 当物理页被多个进程共享时（如COW机制）
 *   - 当物理页被共享内存对象引用时
 *   - 任何需要延长物理页生命周期的场景
 */
int             
kref_inc(void *pa){
  int n;
  acquire(&kref.lock);
  n = ++kref.refcnt[PA2IDX(pa)];
  release(&kref.lock);
  return n;
}
/*
 * 减少指定物理页的引用计数
 * 
 * 参数：
 *   pa - 物理页的起始地址
 * 
 * 返回值：
 *   减少后的引用计数
 * 
 * 注意：
 *   - 当引用计数减为0时，调用者应负责释放该物理页
 *   - 操作过程中会获取kref锁以保证线程安全
 */
int            
kref_dec(void *pa){
  int n;
  acquire(&kref.lock);
  n = --kref.refcnt[PA2IDX(pa)];
  release(&kref.lock);
  return n;
}


void
kinit()
{
  initlock(&kmem.lock, "kmem");
  initlock(&kref.lock, "kref");

  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){

    /*
     * 初始化物理页的引用计数
     * 
     * 新发现的物理页初始引用计数为0，但kfree会将其减1
     * 为避免引用计数变为负数，在调用kfree前将其设置为1
     * 这样kfree后引用计数变为0，物理页会被正确加入空闲链表
     */
    acquire(&kref.lock);
    kref.refcnt[PA2IDX(p)] = 1;
    release(&kref.lock);

    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");
  /*
   * 检查引用计数，决定是否真正释放物理页
   * 
   * 如果减少引用计数后仍大于0，说明还有其他进程或组件在使用该页
   * 此时不释放物理页，直接返回
   */
  if(kref_dec(pa) > 0)
    return;
  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.

void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  
  /*
   * 初始化新分配页的引用计数
   * 
   * 新分配的物理页默认引用计数为1，表示被当前调用者拥有
   */
  if(r){
    acquire(&kref.lock);
    kref.refcnt[PA2IDX(r)] = 1;
    release(&kref.lock);
  }
  extern uint64 kalloc_cnt;
  kalloc_cnt++;


  return (void*)r;
}
