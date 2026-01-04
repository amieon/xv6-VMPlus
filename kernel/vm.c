#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"
#include "vmstats.h"

/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // allocate and map a kernel stack for each process.
  proc_mapstacks(kpgtbl);
  
  return kpgtbl;
}

// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Initialize the kernel_pagetable, shared by all CPUs.
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));

  // flush stale entries from the TLB.
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    return 0;
  if((*pte & PTE_V) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    panic("mappages: size not aligned");

  if(size == 0)
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}



// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
      continue;   
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}

// Allocate PTEs and physical memory to grow a process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int xperm)
{
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);
  for(a = oldsz; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}



// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

/*
 * 复制父进程的页表到子进程（实现 Copy-On-Write 机制）
 * 
 * 参数：
 *   old - 父进程的页表
 *   new - 子进程的页表
 *   sz  - 要复制的内存大小（字节）
 * 
 * 返回值：
 *   成功返回 0；失败返回 -1
 * 
 * 实现原理：
 *   1. 遍历父进程的所有用户页表项
 *   2. 对于可写的用户页，将其改为只读并设置 COW 标志
 *   3. 父子进程共享同一物理页，增加物理页的引用计数
 *   4. 仅复制页表结构，不复制物理内存内容，提高 fork 效率
 * 
 * 注意：
 *   - 只读页（如代码页）保持原样，无需设置 COW
 *   - 失败时会回滚已建立的映射并释放资源
 */
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    pte = walk(old, i, 0);
    if(pte == 0)
      continue;                 // 页表项不存在就跳过
    if((*pte & PTE_V) == 0)
      continue;                 // 没有物理页就跳过

    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);

    if((flags & PTE_U) == 0)
      continue;                 // 非用户页跳过
      
    // 只对原本可写的用户页做 COW 处理
    // 代码页/只读页保持原样
    if(flags & PTE_W){
      // 子进程和父进程的映射都设置为只读 + COW 标志
      flags = (flags & ~PTE_W) | PTE_COW;

      // 更新父进程的页表项
      *pte = PA2PTE(pa) | flags | PTE_V;
    }

    // 共享同一物理页：增加物理页的引用计数
    kref_inc((void*)pa);

    // 在子进程中建立映射
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
      // 映射失败，回滚引用计数
      kref_dec((void*)pa);
      goto err;
    }
    sfence_vma();               // 刷新 TLB，确保页表更新生效
  }
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调用 kfree()，kfree 会自动减少引用计数
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}
/*
 * 处理 Copy-On-Write (COW) 页面的写操作请求
 * 
 * 参数：
 *   pagetable - 进程的页表
 *   va        - 触发 COW 的虚拟地址
 * 
 * 返回值：
 *   成功返回 0；失败返回 -1
 *   失败原因包括：页表项不存在、虚拟地址无效、非 COW 页面、内存分配失败等
 * 
 * 实现原理：
 *   1. 检查虚拟地址是否为有效且已映射的用户页
 *   2. 验证页面是否为 COW 标记且当前不可写
 *   3. 如果页面只有一个引用（没有其他进程共享），则直接恢复可写权限
 *   4. 否则，分配新物理页并复制旧页内容
 *   5. 更新页表项指向新物理页并恢复可写权限
 *   6. 减少旧物理页的引用计数
 * 
 * 注意：
 *   - 该函数会在页表更新后刷新 TLB，确保更改立即生效
 *   - 当需要复制页面时，会更新 COW 统计信息
 */
int
cowbreak(pagetable_t pagetable, uint64 va)
{
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
  if(pte == 0)
    return -1;                 // 页表项不存在
  if((*pte & PTE_V) == 0)
    return -1;                 // 虚拟地址未映射到物理页
  if((*pte & PTE_U) == 0)
    return -1;                 // 非用户页

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    sfence_vma();              // 刷新 TLB
    return 0;
  }

  // 分配新物理页
  char *mem = kalloc();
  if(mem == 0)
    return -1;                 // 内存分配失败

  // 复制旧页内容到新页
  memmove(mem, (void*)pa_old, PGSIZE);

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);

  // 更新 PTE：指向新页，变可写，清掉 COW 标志
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;

  sfence_vma();                // 刷新 TLB
  vmstats_inc_cow();           // 更新 COW 统计信息

  return 0;
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.

int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    if(va0 >= MAXVA)
      return -1;
  
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
        return -1;
      }
    }

    pte = walk(pagetable, va0, 0);

    //如果pte是COW的，这里又要求复制，所以我们只好把COW页拆开了
    if(pte && (*pte & PTE_COW)){
      if(cowbreak(pagetable, va0) < 0)
        return -1;
      // cowbreak 后 PTE 已可写，重新 walk 一次拿到新 pte
      pte = walk(pagetable, va0, 0);
      pa0 = walkaddr(pagetable, va0);
    }

    // forbid copyout over read-only user text pages.
    if((*pte & PTE_W) == 0)
      return -1;
      
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
    extern uint64 copyout_bytes;
    copyout_bytes += n;
  }
  return 0;
}

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
        return -1;
      }
    }
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
    extern uint64 copyin_bytes;
    copyin_bytes += n; 
  }
  return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}

/*
 * 处理进程堆区域的缺页异常（惰性内存分配）
 * 
 * 参数：
 *   pagetable - 进程的页表
 *   va        - 触发缺页异常的虚拟地址
 *   read      - 标识是否为读操作（当前未使用）
 * 
 * 返回值：
 *   成功返回分配的物理页地址；失败返回 0
 *   失败原因包括：虚拟地址超出进程大小、已映射、内存分配失败、映射失败等
 * 
 * 实现原理：
 *   1. 检查虚拟地址是否在进程的堆区域范围内
 *   2. 确保虚拟地址未被映射
 *   3. 分配新的物理页并初始化为0
 *   4. 建立虚拟地址到物理页的映射
 *   5. 返回分配的物理页地址
 * 
 * 注意：
 *   - 这是 sys_sbrk 实现惰性内存分配的关键函数
 *   - 只有在进程实际访问已分配但未映射的堆内存时才会被调用
 *   - 失败时会自动释放已分配但未成功映射的物理页
 */
uint64
vmfault(pagetable_t pagetable, uint64 va, int read)
{
  uint64 mem;
  struct proc *p = myproc();

  if (va >= p->sz)              // 检查虚拟地址是否在进程地址空间范围内
    return 0;
  va = PGROUNDDOWN(va);         // 向下对齐到页边界
  if(ismapped(pagetable, va)) { // 检查是否已映射
    return 0;
  }
  mem = (uint64) kalloc();      // 分配新物理页
  if(mem == 0)
    return 0;                   // 内存分配失败
  memset((void *) mem, 0, PGSIZE); // 初始化为0
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    kfree((void *)mem);         // 映射失败，释放物理页
    return 0;
  }
  return mem;                   // 返回成功分配的物理页地址
}

/*
 * 检查虚拟地址是否已映射到物理页
 * 
 * 参数：
 *   pagetable - 进程的页表
 *   va        - 要检查的虚拟地址
 * 
 * 返回值：
 *   1 表示已映射；0 表示未映射
 * 
 * 实现原理：
 *   1. 查找虚拟地址对应的页表项
 *   2. 如果页表项存在且有效（PTE_V 标志置位），返回 1
 *   3. 否则返回 0
 * 
 * 注意：
 *   - 仅检查映射存在性，不检查权限
 *   - 用于 vmfault 和其他内存管理函数中的辅助检查
 */
int
ismapped(pagetable_t pagetable, uint64 va)
{
  pte_t *pte = walk(pagetable, va, 0);
  if (pte == 0) {               // 页表项不存在
    return 0;
  }
  if (*pte & PTE_V){
    return 1;                   // 页表项存在且有效
  }
  return 0;                     // 页表项存在但无效
}


/*
 * 处理 VMA（虚拟内存区域）相关的缺页异常
 * 
 * 参数：
 *   p        - 发生缺页异常的进程
 *   va       - 触发缺页异常的虚拟地址
 *   iswrite  - 标识是否为写操作
 * 
 * 返回值：
 *   成功返回分配的物理页地址或 1（权限修正情况）；失败返回 0
 *   失败原因包括：虚拟地址不在任何 VMA 范围内、权限不足、内存分配失败、映射失败等
 * 
 * 实现原理：
 *   1. 查找虚拟地址所属的 VMA 结构
 *   2. 进行权限检查（读/写权限是否符合 VMA 配置）
 *   3. 如果已经映射但权限不足（如可写 VMA 但 PTE 不可写），修正权限
 *   4. 如果未映射：
 *      - 对于共享内存 VMA，从共享内存对象获取或分配物理页
 *      - 对于普通 VMA，分配新的物理页
 *   5. 建立虚拟地址到物理页的映射
 *   6. 返回物理页地址或成功标志
 * 
 * 注意：
 *   - 这是处理 mmap 映射区域缺页异常的关键函数
 *   - 支持匿名映射和共享内存映射两种类型
 *   - 失败时会自动回滚已分配的资源（如物理页）
 */
uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
  va = PGROUNDDOWN(va);         // 向下对齐到页边界

  struct vma *v = vma_find(p, va); // 查找虚拟地址所属的 VMA
  if(v == 0) return 0;          // 不在任何 VMA 范围内

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    return 0;
  if((v->prot & PROT_READ) == 0) // VMA 不允许读 -> 不处理
    return 0;

  pte_t *pte = walk(p->pagetable, va, 0);
  if(pte && (*pte & PTE_V)){     // 如果已经映射
    // 已经映射：如果 VMA 允许写，但 PTE 没写位，补上写权限
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
      *pte |= PTE_W;
      sfence_vma();              // 刷新 TLB
      return 1;                  // 返回成功标志
    }
    // 已映射且权限没问题：这次 fault 不该由我们处理
    return 0;
  }
  int idx = (va - v->start) / PGSIZE; // 计算页在 VMA 中的索引
  uint64 pa;

  if(v->is_shm){                 // 共享内存 VMA
    pa = shm_getpa(v->shm_key, idx); // 从共享内存对象获取物理页
    if(pa == 0) return 0;        // 获取失败
    kref_inc((void*)pa);         // 增加共享页的引用计数
  } else {                      // 普通 VMA（匿名映射）
    char *mem = kalloc();        // 分配新的物理页
    if(mem == 0) return 0;      // 分配失败
    memset(mem, 0, PGSIZE);     // 初始化为0
    pa = (uint64)mem;
  }
  // 未映射：按 VMA prot 建立映射
  int perm = PTE_U;              // 用户页标志
  if(v->prot & PROT_READ)  perm |= PTE_R; // 读权限
  if(v->prot & PROT_WRITE) perm |= PTE_W; // 写权限

  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    // 映射失败，回滚资源
    if(v->is_shm) kref_dec((void*)pa); // 减少共享页引用计数
    else kfree((void*)pa);            // 释放普通物理页
    return 0;
  }
  vmstats_inc_lazy();            // 更新惰性分配统计信息
  return (uint64)pa;             // 返回物理页地址
}

