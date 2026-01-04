#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// 处理来自用户空间的中断、异常或系统调用
//
// 该函数是用户空间到内核空间的入口点，负责以下主要功能：
// 1. 处理系统调用 (scause == 8)
// 2. 处理设备中断 (通过 devintr() 函数)
// 3. 处理缺页异常 (scause == 13 读缺页, scause == 15 写缺页)
// 4. 处理其他异常
//
// 调用流程：
// - 从 trampoline.S 调用
// - 处理完成后返回 user satp 值给 trampoline.S，用于切换回用户页表
//
uint64
usertrap(void)
{
  int which_dev = 0;
  uint64 sc = r_scause();
  uint64 va = r_stval();

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);  //DOC: kernelvec

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  
  if(r_scause() == 8){
    // system call

    if(killed(p))
      kexit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
  } else if((which_dev = devintr()) != 0){
    // ok
  } else if(sc == 13 || sc == 15) {
    // 统一处理缺页异常
    // sc == 13: 读缺页异常 (Load Page Fault)
    // sc == 15: 写缺页异常 (Store/AMO Page Fault)
    // va: 引发缺页异常的虚拟地址
    
    if(sc == 15){
      // 写缺页异常处理流程
      // 1. 首先尝试 COW 页面处理：只有写操作才会触发 COW
      if(cowbreak(p->pagetable, va) == 0) {
        // COW 页面处理成功
      } else if(vmafault(p, va, 1) != 0) {
        // 2. COW 失败，尝试 VMA 区域的写异常处理（如 mmap 映射区域）
      } else if(vmfault(p->pagetable, va, 0) != 0) {
        // 3. VMA 处理失败，尝试堆区域的惰性分配
      } else {
        // 所有处理都失败，标记进程为可终止
        setkilled(p);
      }
    } else { 
      // 读缺页异常处理流程
      // 1. 首先尝试 VMA 区域的读异常处理（如 mmap 映射区域）
      if(vmafault(p, va, 0) != 0) {
      } else if(vmfault(p->pagetable, va, 1) != 0) {
        // 2. VMA 处理失败，尝试堆区域的惰性分配
      } else {
        // 所有处理都失败，标记进程为可终止
        setkilled(p);
      }
    }
    // //先处理lazy allocation：只处理“没映射但合法”的情况
    // if(vmfault(p->pagetable, va, sc == 13) != 0){
    //   // handled
    // }
    // //再处理COW：只有 store fault 才可能
    // else if(sc == 15){
    //   if(cowbreak(p->pagetable, va) == 0){
    //     // handled
    //   } else {
    //     printf("COW fail: pid=%d va=0x%lx pte?\n", p->pid, va);
    //     setkilled(p);
    //   }
    // } 
    // //load fault 但 vmfault 也处理不了,所以非法
    // else {
    //   setkilled(p);
    // }

  } else {
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    setkilled(p);
  }


  if(killed(p))
    kexit(-1);

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2)
    yield();

  prepare_return();

  // the user page table to switch to, for trampoline.S
  uint64 satp = MAKE_SATP(p->pagetable);

  // return to trampoline.S; satp value in a0.
  return satp;
}

//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  if((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if(intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if((which_dev = devintr()) == 0){
    // interrupt or trap from an unknown source
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    panic("kerneltrap");
  }

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2 && myproc() != 0)
    yield();

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void
clockintr()
{
  if(cpuid() == 0){
    acquire(&tickslock);
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
  }
}

