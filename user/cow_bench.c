// cowbench.c -- rigorous Copy-On-Write fork benchmark for xv6-VMPlus
//
// Build: add  $U/_cowbench  to UPROGS in the Makefile.
// Run COW kernel:    make qemu              ; in shell: cowbench
// Run eager kernel:  make qemu EAGER_FORK=1 ; in shell: cowbench
//
// NOTE: xv6 printf supports only %d %x %p %s %c %% (no field widths).
//
// Experiment B = fork-time page disposition vs resident set (must run FIRST).
// Experiment A = run-time COW copy cost vs child write footprint (+ isolation).
// Experiment C = kernel page alloc/free balance over many fork/COW/exit cycles.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/vmstats.h"   // struct vmstats_user
#include "user/user.h"

#define PG      4096
#define TRIALS  10
#define PAT_A   0x11          // parent's baseline byte
#define PAT_B   0x77          // child's overwrite byte

static struct vmstats_user S;
static int g_pass = 1;

static uint64 rd_cow(void)   { vmstats(&S); return S.cow_faults; }
static uint64 rd_copy(void)  { vmstats(&S); return S.fork_copy_pages; }
static uint64 rd_share(void) { vmstats(&S); return S.fork_share_pages; }
static uint64 rd_live(void)  { vmstats(&S); return S.kalloc_cnt - S.kfree_cnt; }

// ---------------------------------------------------------------------------
// Experiment B: fork-time disposition of resident user pages vs resident set.
// Uses raw sbrk with CUMULATIVE growth so the resident set equals N exactly
// (malloc would double-count freed-but-still-mapped pages). Run this FIRST,
// before any malloc, so the heap starts clean.
// ---------------------------------------------------------------------------
static void exp_fork_scaling(void)
{
  int Ns[] = {64, 128, 256, 512};
  printf("\n[Experiment B] fork-time page disposition vs resident set (TRIALS=%d)\n", TRIALS);
  printf("  expect COW: copied=0, shared grows with N ; EAGER: copied grows, shared=0\n");

  uint64 cur = 0;  // pages grown so far
  for(int a = 0; a < 4; a++){
    int N = Ns[a];
    int need = N - (int)cur;
    char *seg = sbrk(need * PG);
    if(seg == (char*)-1){ printf("  sbrk failed\n"); g_pass = 0; return; }
    for(int i = 0; i < need; i++) seg[i*PG] = 1;   // touch only the NEW pages
    cur = N;

    uint64 cpmn = (uint64)-1, cpmx = 0, shmn = (uint64)-1, shmx = 0;
    for(int t = 0; t < TRIALS; t++){
      uint64 cp0 = rd_copy(), sh0 = rd_share();
      if(fork() == 0) exit(0);
      wait(0);
      uint64 dc = rd_copy() - cp0, ds = rd_share() - sh0;
      if(dc < cpmn) cpmn = dc;  
      if(dc > cpmx) cpmx = dc;
      if(ds < shmn) shmn = ds;  
      if(ds > shmx) shmx = ds;
    }
    printf("  N=%d  copied=%d..%d  shared=%d..%d  det=%s\n",
           N, (int)cpmn, (int)cpmx, (int)shmn, (int)shmx,
           (cpmn==cpmx && shmn==shmx) ? "yes" : "no");
  }
}

// ---------------------------------------------------------------------------
// Experiment A: run-time COW copy cost vs child write footprint, swept over N,
// repeated TRIALS times, with an isolation correctness check every run.
//   - child writes PAT_B to the first w pages, then verifies its own view
//   - parent (post-wait) verifies every page is still PAT_A (no leak into parent)
// ---------------------------------------------------------------------------
static void exp_copy_vs_write(void)
{
  int Ns[] = {128, 256, 512};
  int fr[] = {0, 25, 50, 75, 100};
  printf("\n[Experiment A] run-time COW copy cost vs write footprint (TRIALS=%d)\n", TRIALS);
  printf("  expect copied == written pages (slope=1) ; isolation must PASS\n");

  for(int a = 0; a < 3; a++){
    int N = Ns[a];
    for(int b = 0; b < 5; b++){
      int w = N * fr[b] / 100;
      uint64 mn = (uint64)-1, mx = 0;
      int iso_ok = 1;

      for(int t = 0; t < TRIALS; t++){
        char *p = malloc(N * PG);
        for(int i = 0; i < N; i++) p[i*PG] = PAT_A;   // parent baseline

        uint64 c0 = rd_cow();
        int pid = fork();
        if(pid == 0){
          for(int i = 0; i < w; i++) p[i*PG] = PAT_B; // child writes -> cowbreak
          for(int i = 0; i < w; i++) if(p[i*PG] != PAT_B) exit(2); // own writes
          for(int i = w; i < N; i++) if(p[i*PG] != PAT_A) exit(3); // shared reads
          exit(0);
        }
        int st = -1;
        wait(&st);
        uint64 d = rd_cow() - c0;
        if(d < mn) mn = d;  
        if(d > mx) mx = d;

        if(st != 0) iso_ok = 0;                       // child saw inconsistent view
        for(int i = 0; i < N; i++)                    // parent must still see all A
          if(p[i*PG] != PAT_A){ iso_ok = 0; break; }
        free(p);
      }
      if(!iso_ok) g_pass = 0;
      printf("  N=%d write=%d%% copied=%d..%d expect=%d det=%s iso=%s\n",
             N, fr[b], (int)mn, (int)mx, w,
             (mn==mx) ? "yes" : "no", iso_ok ? "PASS" : "FAIL");
    }
  }
}

// ---------------------------------------------------------------------------
// Experiment C: kernel page alloc/free balance. Over many fork/COW/exit cycles
// the live page count (kalloc_cnt - kfree_cnt) must return to baseline.
// ---------------------------------------------------------------------------
static void exp_leak(void)
{
  int cycles = 500, N = 64;
  printf("\n[Experiment C] alloc/free balance over %d fork/COW/exit cycles\n", cycles);

  char *p = malloc(N * PG);                 // warm up: fix heap so loop never grows it
  for(int i = 0; i < N; i++) p[i*PG] = PAT_A;

  uint64 live0 = rd_live();
  for(int k = 0; k < cycles; k++){
    for(int i = 0; i < N; i++) p[i*PG] = PAT_A;   // re-arm parent pages
    if(fork() == 0){
      for(int i = 0; i < N/2; i++) p[i*PG] = PAT_B; // force COW copies in child
      exit(0);
    }
    wait(0);
  }
  uint64 live1 = rd_live();
  free(p);

  int ok = (live1 == live0);
  if(!ok) g_pass = 0;
  printf("  live_pages before=%d after=%d delta=%d  %s\n",
         (int)live0, (int)live1, (int)(live1 - live0),
         ok ? "PASS (no leak)" : "FAIL (leak!)");
}

int
main(void)
{
  printf("=== Rigorous COW fork benchmark (TRIALS=%d) ===\n", TRIALS);
  exp_fork_scaling();    // MUST be first: clean heap for a precise resident set
  exp_copy_vs_write();
  exp_leak();
  printf("\n=== OVERALL: %s ===\n", g_pass ? "ALL CHECKS PASS" : "SOME CHECKS FAILED");
  exit(0);
}