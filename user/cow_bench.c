#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/vmstats.h"   // struct vmstats_user
#include "user/user.h"

#define PG 4096

static struct vmstats_user S;
static uint64 snap_cow(void)   { vmstats(&S); return S.cow_faults; }


// 实验一：fork 后子进程不写，实际复制应 ≈0
static void exp1(int n){
  char *p = malloc(n*PG); memset(p, 1, n*PG);   // 触一遍，保证页 present + 可写
  uint64 c0 = snap_cow();
  if(fork() == 0) exit(0);
  wait(0);
  printf("exp1 N=%d  cow_copies=%d  (expect ~0)\n", n, (int)(snap_cow()-c0));
  free(p);
}

// 实验二：子进程只写 frac% 的页，复制应 ≈ frac%*N（线性，斜率=N）
static void exp2(int n){
  int frac[] = {0, 25, 50, 75, 100};
  for(int k = 0; k < 5; k++){
    int w = n * frac[k] / 100;
    char *p = malloc(n*PG); memset(p, 1, n*PG);
    uint64 c0 = snap_cow();
    if(fork() == 0){
      for(int i = 0; i < w; i++) p[i*PG] = 7;   // 每页首字节 → 触发 cowbreak
      exit(0);
    }
    wait(0);
    printf("exp2 N=%d  write=%d%%  cow_copies=%d  (expect ~%d)\n",
           n, frac[k], (int)(snap_cow()-c0), w);
    free(p);
  }
}

// 实验三：fork 期间 kalloc 量 vs 进程规模（COW 与 EAGER_FORK 各跑一遍对比）
static void exp3(void){
  int sizes[] = {64,128,256,512};
  for(int s = 0; s < 4; s++){
    int n = sizes[s];
    char *p = malloc(n*PG); memset(p, 1, n*PG);   // 让 n 页驻留
    vmstats(&S); uint64 cp0 = S.fork_copy_pages, sh0 = S.fork_share_pages;
    if(fork() == 0) exit(0);
    wait(0);
    vmstats(&S);
    printf("exp3 N=%d  fork_copied=%d  fork_shared=%d\n",
           n, (int)(S.fork_copy_pages - cp0), (int)(S.fork_share_pages - sh0));
    free(p);
  }
}

int main(void){
  printf("== COW fork benchmark ==\n");
  exp1(512);
  exp2(512);
  exp3();
  exit(0);
}