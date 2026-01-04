#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "vmstats.h"

volatile static int started = 0;

/*
 * 内核主函数，所有CPU在supervisor模式下从start()跳转到这里执行
 * 
 * 功能：
 * 1. 初始化内核各个子系统（控制台、内存管理、进程管理、中断处理等）
 * 2. 启动第一个用户进程
 * 3. 进入调度器开始进程调度
 * 
 * 执行流程：
 * - CPU 0负责初始化所有核心子系统
 * - 其他CPU等待初始化完成后启动
 * - 所有CPU最终都进入调度器
 */
void
main()
{
  if(cpuid() == 0){
    consoleinit();
    printfinit();
    printf("\n");
    printf("xv6 kernel is booting\n");
    printf("\n");
    vmstatsinit();
    kinit();         // physical page allocator
    kvminit();       // create kernel page table
    kvminithart();   // turn on paging
    procinit();      // process table
    trapinit();      // trap vectors
    trapinithart();  // install kernel trap vector
    plicinit();      // set up interrupt controller
    plicinithart();  // ask PLIC for device interrupts
    binit();         // buffer cache
    iinit();         // inode table
    fileinit();      // file table
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    shm_init();
    seminit();

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
      ;
    __sync_synchronize();
    printf("hart %d starting\n", cpuid());
    kvminithart();    // turn on paging
    trapinithart();   // install kernel trap vector
    plicinithart();   // ask PLIC for device interrupts
  }

  scheduler();        
}
