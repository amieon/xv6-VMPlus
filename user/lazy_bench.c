// lazybench.c -- lazy (demand) allocation benchmark for xv6-VMPlus
//
// Build: add  $U/_lazybench  to UPROGS in the Makefile.
// Run:   make qemu ; in shell: lazybench
//
// Thesis: mapping N pages allocates NOTHING; physical pages are allocated only
//         on first touch. So allocated == touched (K), not mapped (N).
//
// Two independent counters must agree at K:
//   lazy_faults : demand-fault count in vmafault() (anonymous VMA path)
//   kalloc_cnt  : physical pages actually pulled from the allocator
//
// xv6 printf supports only %d %x %p %s %c %% (no field widths).

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/vmstats.h"
#include "user/user.h"

#define PG       4096
#define MAPPAGES 256           // every trial maps this many pages
#define TRIALS   5

static struct vmstats_user A, B;
static int g_pass = 1;

static void chk(int cond, char *msg)
{
  if(!cond){ g_pass = 0; printf("  [FAIL] %s\n", msg); }
}

// Map MAPPAGES, touch the first K, report allocation deltas (mean over TRIALS).
// Returns nothing; prints one row.
static void run_k(int K)
{
  int lf_mn = 0x7fffffff, lf_mx = 0, ka_mn = 0x7fffffff, ka_mx = 0;
  int map_alloc_max = 0;        // pages allocated by the bare mmap (must be 0)

  for(int t = 0; t < TRIALS; t++){
    // --- phase 1: map only, allocate nothing ---
    vmstats(&A);
    char *p = (char*)mmap(0, MAPPAGES*PG, PROT_READ|PROT_WRITE, MAP_ANON, 0);
    if(p == (char*)-1){ printf("  mmap failed\n"); g_pass = 0; return; }
    vmstats(&B);
    int map_alloc = (int)(B.kalloc_cnt - A.kalloc_cnt);   // expect ~0 (metadata only)
    if(map_alloc > map_alloc_max) map_alloc_max = map_alloc;

    // --- phase 2: touch first K pages, expect exactly K faults + K allocations ---
    vmstats(&A);
    for(int i = 0; i < K; i++) p[i*PG] = 1;               // one write per page
    vmstats(&B);
    int lf = (int)(B.lazy_faults - A.lazy_faults);
    int ka = (int)(B.kalloc_cnt  - A.kalloc_cnt);
    if(lf < lf_mn) lf_mn = lf;
    if(lf > lf_mx) lf_mx = lf;
    if(ka < ka_mn) ka_mn = ka;
    if(ka > ka_mx) ka_mx = ka;

    munmap(p, MAPPAGES*PG);
  }

  // correctness criterion: lazy_faults (pure DATA-page demand allocations) == K.
  // kalloc is shown as informational TOTAL cost: data pages + Sv39 page-table
  // pages built on demand by walk(); it can exceed K by a few for small K.
  chk(lf_mn == K && lf_mx == K, "lazy_faults != K");
  int pt = ka_mx - K;          // extra pages beyond data = on-demand page-table pages
  if(pt < 0) pt = 0;
  printf("  mapped=%d touched=%d  lazy_faults=%d..%d (data)  kalloc=%d..%d (data+%d ptbl)  map_only_alloc=%d  %s\n",
         MAPPAGES, K, lf_mn, lf_mx, ka_mn, ka_mx, pt, map_alloc_max,
         (lf_mn==K && lf_mx==K) ? "PASS" : "FAIL");
}

int
main(void)
{
  int Ks[] = {0, 32, 64, 128, 256};
  printf("=== Lazy (demand) allocation benchmark (map %d pages, TRIALS=%d) ===\n",
         MAPPAGES, TRIALS);
  printf("thesis: allocated pages == TOUCHED pages, not MAPPED pages\n");
  for(int i = 0; i < 5; i++) run_k(Ks[i]);
  printf("\n=== OVERALL: %s ===\n", g_pass ? "ALL CHECKS PASS" : "SOME CHECKS FAILED");
  exit(0);
}