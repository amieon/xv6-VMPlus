// semvsbusy.c -- blocking semaphore vs busy-wait, for xv6-VMPlus
//
// Build: add  $U/_semvsbusy  to UPROGS in the Makefile.
// Run:   make CPUS=1 qemu      <-- MUST be single-CPU to create contention
//        in shell: semvsbusy
//
// Thesis: a process waiting on a blocking semaphore SLEEPS and yields the CPU;
//         a busy-waiting process SPINS and steals the CPU from useful work.
//
// Measurement: a background "worker" increments a counter for the whole wait
// window. Its progress = the CPU it received. We compare the worker's progress
// when the OTHER waiter blocks (sem_wait) vs spins (poll a flag).
//   worker_blocking / worker_busy  =  how much CPU busy-wait steals.
//   wasted_spins                   =  cycles the spinner burned doing nothing.
//
// Shared state uses the project's own SHM (mmap MAP_SHARED), inherited across
// fork exactly as in ipcbench. xv6 printf supports only %d %x %p %s %c %%.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/vmstats.h"
#include "kernel/shm.h"        // IPC_RMID
#include "user/user.h"

#define WINDOW 50              // wait-window length in ticks (~0.5s)
#define TRIALS 5
#define KEY    77
#define SEM    300

struct ctl {
  volatile uint64 work;        // worker's useful-work counter
  volatile uint64 spins;       // busy-waiter's wasted-spin counter
  volatile int stop;           // parent -> worker: stop counting
  volatile int flag;           // parent -> busy waiter: released
};

// background worker: do measurable work until told to stop
static void worker(struct ctl *c)
{
  while(c->stop == 0) c->work++;
  munmap((void*)c, 4096);
  exit(0);
}

// blocking scenario: the other waiter sleeps in the kernel on a semaphore.
// returns worker progress in thousands.
static int run_block(struct ctl *c)
{
  c->work = 0; c->spins = 0; c->stop = 0; c->flag = 0;
  sem_open(SEM, 0);                          // val 0 -> sem_wait will block

  if(fork() == 0) worker(c);                 // worker child
  if(fork() == 0){                           // blocking waiter child
    sem_wait(SEM);
    munmap((void*)c, 4096);
    exit(0);
  }

  sleep(WINDOW);                             // measurement window
  sem_post(SEM);                             // release the blocking waiter
  wait(0);                                   // reap waiter
  c->stop = 1;                               // stop worker
  wait(0);                                   // reap worker
  return (int)(c->work / 1000);
}

// busy scenario: the other waiter spins on a shared flag (no yielding).
// returns worker progress in thousands; sets *spinsK to wasted spins (thousands).
static int run_busy(struct ctl *c, int *spinsK)
{
  c->work = 0; c->spins = 0; c->stop = 0; c->flag = 0;

  if(fork() == 0) worker(c);                 // worker child
  if(fork() == 0){                           // busy waiter child
    while(c->flag == 0) c->spins++;          // spin, burning CPU
    munmap((void*)c, 4096);
    exit(0);
  }

  sleep(WINDOW);
  c->flag = 1;                               // release the busy waiter
  wait(0);
  c->stop = 1;
  wait(0);
  *spinsK = (int)(c->spins / 1000);
  return (int)(c->work / 1000);
}

int
main(void)
{
  struct ctl *c = (struct ctl*)mmap(0, 4096, PROT_READ|PROT_WRITE,
                                    MAP_ANON|MAP_SHARED, KEY);
  if(c == (void*)-1){ printf("mmap failed\n"); exit(1); }

  printf("=== Blocking semaphore vs busy-wait (WINDOW=%d ticks, TRIALS=%d) ===\n",
         WINDOW, TRIALS);
  printf("NOTE: run single-CPU ( make CPUS=1 qemu ) or there is no contention to see\n");
  printf("metric: useful work a concurrent worker completes during the wait window\n");

  int sumb = 0, sums = 0, last_spin = 0;
  for(int t = 0; t < TRIALS; t++){
    int bw = run_block(c);
    int sp = 0;
    int sw = run_busy(c, &sp);
    sumb += bw; sums += sw; last_spin = sp;
    printf("  trial %d: worker_blocking=%dK  worker_busy=%dK  wasted_spins=%dK\n",
           t, bw, sw, sp);
  }

  int mb = sumb / TRIALS, ms = sums / TRIALS;
  printf("\nmean: worker_blocking=%dK  worker_busy=%dK  (spinner burned ~%dK spins/window)\n",
         mb, ms, last_spin);
  if(ms > 0){
    int r10 = mb * 10 / ms;                  // ratio x10 for one decimal
    printf("blocking lets the worker do %d.%dx more useful work\n", r10/10, r10%10);
    printf("=> busy-wait wasted ~%d%% of the CPU that blocking returned to useful work\n",
           100 - (ms * 100 / mb));
  }

  munmap((void*)c, 4096);
  shmctl(KEY, IPC_RMID);
  exit(0);
}