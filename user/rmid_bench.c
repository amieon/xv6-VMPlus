// rmidbench.c -- IPC_RMID deferred-reclamation correctness test for xv6-VMPlus
//
// Build: add  $U/_rmidbench  to UPROGS in the Makefile.
// Run:   make qemu ; in shell: rmidbench
//
// System V IPC_RMID semantics under test:
//   A1. After RMID, a NEW attach (mmap of the key) is REJECTED.
//   A2. After RMID, processes ALREADY attached keep reading/writing correctly,
//       and the physical pages are NOT freed while any reference remains
//       (deferred reclamation -- the soul of IPC_RMID).
//   A3. The pages are reclaimed only when the LAST reference detaches; the
//       freed-page count then matches the data pages that were touched.
//
// Page accounting uses kfree_cnt (real frees) and shm_faults. Cross-process
// ordering uses two semaphores so the parent RMIDs only after the child has
// attached and verified, and detaches happen in a controlled order.
//
// xv6 printf supports only %d %x %p %s %c %%.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/vmstats.h"
#include "kernel/shm.h"        // IPC_RMID
#include "user/user.h"

#define PG     4096
#define NPAGES 8               // data pages in the shared object
#define KEY    55
#define S_CHILD 400            // posted when child has attached + verified
#define S_PARENT 401           // posted when parent allows child to detach

static struct vmstats_user A;
static int g_pass = 1;

static void chk(int cond, char *msg)
{
  if(cond) { printf("  [PASS] %s\n", msg); }
  else     { printf("  [FAIL] %s\n", msg); g_pass = 0; }
}

static uint64 freed(void) { vmstats(&A); return A.kfree_cnt; }

int
main(void)
{
  sem_open(S_CHILD, 0);
  sem_open(S_PARENT, 0);

  // Parent attaches first and fills a known pattern.
  char *p = (char*)mmap(0, NPAGES*PG, PROT_READ|PROT_WRITE,
                        MAP_ANON|MAP_SHARED, KEY);
  if(p == (char*)-1){ printf("parent mmap failed\n"); exit(1); }
  for(int i = 0; i < NPAGES; i++) p[i*PG] = (char)(0xA0 + i);

  printf("=== IPC_RMID deferred-reclamation test (NPAGES=%d) ===\n", NPAGES);

  int pid = fork();
  if(pid == 0){
    // ---- child: shares the parent's mapping via fork (same address p),
    //      exactly like ipcbench -- a SINGLE reference, no second mmap. ----
    int ok = 1;
    for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok = 0;
    if(!ok) printf("  [FAIL] child did not see parent's data\n");

    sem_post(S_CHILD);          // tell parent: I'm attached + verified
    sem_wait(S_PARENT);         // wait until parent has done RMID

    // A2 (child side): after RMID, an already-attached process still works.
    int ok2 = 1;
    for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok2 = 0; // read
    for(int i = 0; i < NPAGES; i++) p[i*PG] = (char)(0x50 + i);              // write
    if(!ok2) printf("  [FAIL] child lost access to data after RMID\n");

    munmap(p, NPAGES*PG);       // child detaches its single (inherited) reference
    sem_post(S_CHILD);          // tell parent: I've detached
    exit(ok && ok2 ? 0 : 1);
  }

  // ---- parent ----
  sem_wait(S_CHILD);            // wait until child is attached + verified

  // A1: mark for deletion, then a brand-new attach of the same key must fail.
  shmctl(KEY, IPC_RMID);
  char *late = (char*)mmap(0, NPAGES*PG, PROT_READ|PROT_WRITE,
                           MAP_ANON|MAP_SHARED, KEY);
  chk(late == (char*)-1, "A1: attach after RMID is rejected");
  if(late != (char*)-1) munmap(late, NPAGES*PG);

  // A2 (parent side): pages still alive & correct after RMID, with refs remaining.
  uint64 f0 = freed();
  int ok = 1;
  for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok = 0;
  chk(ok, "A2: parent still reads correct data after RMID");

  sem_post(S_PARENT);           // let child do its post-RMID access + detach
  sem_wait(S_CHILD);            // wait until child has detached

  // Child detached but parent still holds a reference: pages must NOT be freed yet.
  uint64 f1 = freed();
  chk((int)(f1 - f0) == 0, "A2: pages NOT reclaimed while parent still attached");

  // parent reads the child's post-RMID writes (proves shared pages stayed live)
  int ok3 = 1;
  for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0x50 + i)) ok3 = 0;
  chk(ok3, "A2: parent sees child's post-RMID writes (pages stayed live)");

  // A3: parent is the last reference -> detaching it must reclaim the data pages.
  wait(0);                      // reap child FIRST: guarantee its reference is gone
  uint64 f2 = freed();
  munmap(p, NPAGES*PG);
  uint64 f3 = freed();
  int reclaimed = (int)(f3 - f2);
  chk(reclaimed >= NPAGES, "A3: last detach reclaims the data pages");
  printf("  (pages freed at last detach = %d, expected >= %d data pages)\n",
         reclaimed, NPAGES);

  printf("\n=== OVERALL: %s ===\n", g_pass ? "ALL RMID SEMANTICS VERIFIED" : "SOME CHECKS FAILED");
  exit(0);
}