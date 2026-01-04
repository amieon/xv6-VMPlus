#include "../kernel/types.h"
#include "../kernel/vmstats.h"
#include "../kernel/shm.h"
#include "user.h"

#define TOTAL_MB 8
#define TOTAL_BYTES (TOTAL_MB*1024*1024)

#define CHUNK 256
#define BSZ   (64*1024)
#define NCHUNK (BSZ/CHUNK)

struct shmring {
  int head;
  int tail;
  char buf[BSZ];
};

static void
print_delta(char *tag, int t0, int t1,
            struct vmstats_user *a, struct vmstats_user *b)
{
  printf("\n=== %s ===\n", tag);
  printf("time: %d ticks\n", t1 - t0);
  printf("kalloc: %d\n", (int)(b->kalloc_cnt - a->kalloc_cnt));
  printf("copyin_bytes: %d\n", (int)(b->copyin_bytes - a->copyin_bytes));
  printf("copyout_bytes: %d\n", (int)(b->copyout_bytes - a->copyout_bytes));
  printf("faults: cow=%d lazy=%d shm=%d\n",
         (int)(b->cow_faults - a->cow_faults),
         (int)(b->lazy_faults - a->lazy_faults),
         (int)(b->shm_faults - a->shm_faults));
}

static void
bench_pipe(void)
{
  int pfd[2];
  if(pipe(pfd) < 0){
    printf("pipe failed\n");
    exit(1);
  }

  int pid = fork();
  if(pid == 0){
    close(pfd[1]);
    char tmp[CHUNK];
    int got = 0;
    while(got < TOTAL_BYTES){
      int n = read(pfd[0], tmp, sizeof(tmp));
      if(n <= 0) break;
      got += n;
    }
    close(pfd[0]);
    exit(0);
  }

  close(pfd[0]);
  char tmp[CHUNK];
  for(int i=0;i<CHUNK;i++) tmp[i] = (char)(i);

  int sent = 0;
  while(sent < TOTAL_BYTES){
    int n = CHUNK;
    if(TOTAL_BYTES - sent < n) n = TOTAL_BYTES - sent;
    if(write(pfd[1], tmp, n) != n){
      printf("pipe write fail\n");
      break;
    }
    sent += n;
  }
  close(pfd[1]);
  wait(0);
}

static void
bench_shm_sem(void)
{
  int shmkey = 10;
  int sem_empty = 200;
  int sem_full  = 201;

  struct shmring *r = (struct shmring*)mmap(0, 4096*20, PROT_READ|PROT_WRITE,
                                           MAP_ANON|MAP_SHARED, shmkey);
  if(r == (void*)-1){
    printf("mmap shm fail\n");
    exit(1);
  }

  // 初始化 ring
  r->head = r->tail = 0;

  if(sem_open(sem_empty, NCHUNK) < 0 || sem_open(sem_full, 0) < 0){
    printf("sem_open fail\n");
    exit(1);
  }

  int pid = fork();
  if(pid == 0){
    // consumer
    int got = 0;
    while(got < TOTAL_BYTES){
      sem_wait(sem_full);

      // 取一块
      int idx = r->tail % NCHUNK;
      volatile char x = r->buf[idx*CHUNK]; // 触碰一下，防止编译器全优化
      (void)x;
      r->tail++;

      sem_post(sem_empty);
      got += CHUNK;
    }
    munmap((char*)r, 4096*20);
    exit(0);
  }

  // producer
  int sent = 0;
  while(sent < TOTAL_BYTES){
    sem_wait(sem_empty);

    int idx = r->head % NCHUNK;
    // 写一块（简单填充）
    for(int i=0;i<CHUNK;i++){
      r->buf[idx*CHUNK + i] = (char)(sent + i);
    }
    r->head++;

    sem_post(sem_full);
    sent += CHUNK;
  }

  wait(0);
  munmap((char*)r, 4096*20);
  shmctl(shmkey, IPC_RMID);  // 可选：清理
}

int
main(void)
{
  struct vmstats_user a,b;
  int t0,t1;

  // pipe
  vmstats(&a);
  t0 = uptime();
  bench_pipe();
  t1 = uptime();
  vmstats(&b);
  print_delta("PIPE IPC", t0, t1, &a, &b);

  // shm+sem
  vmstats(&a);
  t0 = uptime();
  bench_shm_sem();
  t1 = uptime();
  vmstats(&b);
  print_delta("SHM+SEM IPC", t0, t1, &a, &b);

  exit(0);
}
