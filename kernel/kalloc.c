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


struct {
  struct spinlock lock;
  int refcnt[MAXPAGES];
} kref;

//这三个函数作用差不多
//先加锁，在操作，最后释放锁再返回现在的引用数
int     
kref_get(void *pa){
  int n;
  acquire(&kref.lock);
  n = kref.refcnt[PA2IDX(pa)];
  release(&kref.lock);
  return n;
}
int             
kref_inc(void *pa){
  int n;
  acquire(&kref.lock);
  n = ++kref.refcnt[PA2IDX(pa)];
  release(&kref.lock);
  return n;
}
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

    //这个时候所有页都不是kmallc生成的，他们的引用数都为0,不为1
    //在kfree后引用数都会变成-1,而引用数小于0三不被允许的
    //所以在初始kfree之前，我们为所有页的引用数初始化为1
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
  //如果某个进程将这个页free后引用数不为0
  //那么说明有其他进程要用到这个页，故不真正将其free了
  if(kref_dec(pa)>0)
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
  
  //alloc出页后，默认引用数为1
  if(r){
  acquire(&kref.lock);
  kref.refcnt[PA2IDX(r)] = 1;
  release(&kref.lock);
  }
  extern uint64 kalloc_cnt;
  kalloc_cnt++;


  return (void*)r;
}
