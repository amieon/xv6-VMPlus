#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/vmstats.h"
#include "kernel/shm.h"        // IPC_RMID
#include "user/user.h"

#define PG      4096
#define CHUNK   4096           // one page per chunk -> clean shm_faults
#define SLOTS   16             // ring buffer depth (pages)
#define RINGSZ  (SLOTS*CHUNK)

#define SHMKEY    10
#define SEM_EMPTY 200          // counts free slots
#define SEM_FULL  201          // counts filled slots

// shared ring buffer laid out inside the SHM mapping
struct shmring {
  volatile int head;           // producer index (mod SLOTS)
  volatile int tail;           // consumer index (mod SLOTS)
  // payload starts on the next page so head/tail share a page, data is page-aligned
  char pad[CHUNK - 2*sizeof(int)];
  char buf[RINGSZ];
};

static struct vmstats_user A, B;
static int g_pass = 1;

// fill chunk c with a verifiable pattern: first byte = sequence id, rest = id+offset
static void fill_chunk(char *p, int seq)
{
  p[0] = (char)seq;
  for(int i = 1; i < CHUNK; i++) p[i] = (char)(seq + i);
}
// verify a chunk matches what fill_chunk(seq) produced
static int check_chunk(char *p, int seq)
{
  if(p[0] != (char)seq) return 0;
  if(p[CHUNK-1] != (char)(seq + CHUNK - 1)) return 0;   // sample, not full scan
  return 1;
}

// ----------------------------- PIPE -----------------------------
// returns 0 on success
static int run_pipe(int total)
{
  int nchunks = total / CHUNK;
  int pfd[2];
  if(pipe(pfd) < 0){ printf("pipe() failed\n"); return -1; }

  int pid = fork();
  if(pid == 0){                       // consumer
    close(pfd[1]);
    static char local[CHUNK];         // static: CHUNK=4KB would overflow the 1-page user stack
    int ok = 1;
    for(int c = 0; c < nchunks; c++){
      int got = 0;
      while(got < CHUNK){             // pipe may deliver partial chunks
        int n = read(pfd[0], local + got, CHUNK - got);
        if(n <= 0){ ok = 0; break; }
        got += n;
      }
      if(!ok || !check_chunk(local, c)){ ok = 0; break; }
    }
    close(pfd[0]);
    exit(ok ? 0 : 1);
  }

  close(pfd[0]);                       // producer
  static char local[CHUNK];
  for(int c = 0; c < nchunks; c++){
    fill_chunk(local, c);
    int sent = 0;
    while(sent < CHUNK){
      int n = write(pfd[1], local + sent, CHUNK - sent);
      if(n <= 0){ close(pfd[1]); wait(0); return -1; }
      sent += n;
    }
  }
  close(pfd[1]);
  int st = -1; wait(&st);
  return st;
}

// --------------------------- SHM + SEM ---------------------------
// returns 0 on success
static int run_shm(int total)
{
  int nchunks = total / CHUNK;
  struct shmring *r = (struct shmring*)mmap(0, sizeof(struct shmring),
                          PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, SHMKEY);
  if(r == (void*)-1){ printf("mmap shm failed\n"); return -1; }
  r->head = 0; r->tail = 0;
  if(sem_open(SEM_EMPTY, SLOTS) < 0 || sem_open(SEM_FULL, 0) < 0){
    printf("sem_open failed\n"); munmap((void*)r, sizeof(struct shmring)); return -1;
  }

  int pid = fork();
  if(pid == 0){                        // consumer
    static char local[CHUNK];
    int ok = 1;
    for(int c = 0; c < nchunks; c++){
      sem_wait(SEM_FULL);              // wait for a filled slot
      int idx = r->tail % SLOTS;
      memmove(local, &r->buf[idx*CHUNK], CHUNK);   // real copy OUT (== pipe read)
      r->tail++;
      sem_post(SEM_EMPTY);             // hand the slot back
      if(!check_chunk(local, c)){ ok = 0; break; }
    }
    munmap((void*)r, sizeof(struct shmring));
    exit(ok ? 0 : 1);
  }

  for(int c = 0; c < nchunks; c++){    // producer
    sem_wait(SEM_EMPTY);               // wait for a free slot
    int idx = r->head % SLOTS;
    fill_chunk(&r->buf[idx*CHUNK], c); // real copy IN (== pipe write)
    r->head++;
    sem_post(SEM_FULL);                // mark slot filled
  }
  int st = -1; wait(&st);
  munmap((void*)r, sizeof(struct shmring));
  shmctl(SHMKEY, IPC_RMID);            // tear down so next size starts clean
  return st;
}

// ----------------------------- driver -----------------------------
// run one transport REPS times at a given total size, report mean ticks + deltas
static void measure(const char *tag, int is_shm, int total, int reps)
{
  int t_sum = 0, t_min = 0x7fffffff, t_max = 0;
  int fail = 0;

  vmstats(&A);
  for(int k = 0; k < reps; k++){
    int t0 = uptime();
    int rc = is_shm ? run_shm(total) : run_pipe(total);
    int t1 = uptime();
    if(rc != 0) fail = 1;
    int dt = t1 - t0;
    t_sum += dt;
    if(dt < t_min) t_min = dt;
    if(dt > t_max) t_max = dt;
  }
  vmstats(&B);

  if(fail){ g_pass = 0; }
  int kb = total / 1024;
  int mean10 = (t_sum * 10) / reps;    // mean ticks * 10 (one decimal, no float)
  // byte counters are summed over reps; divide to get per-transfer
  int cin  = (int)((B.copyin_bytes  - A.copyin_bytes)  / reps);
  int cout = (int)((B.copyout_bytes - A.copyout_bytes) / reps);
  int shf  = (int)((B.shm_faults    - A.shm_faults)    / reps);
  int laf  = (int)((B.lazy_faults   - A.lazy_faults)   / reps);

  printf("%s size=%dKB reps=%d ticks_mean=%d.%d min=%d max=%d copyin=%d copyout=%d shmflt=%d lazyflt=%d %s\n",
         tag, kb, reps, mean10/10, mean10%10, t_min, t_max,
         cin, cout, shf, laf, fail ? "FAIL" : "ok");
}

int
main(void)
{
  // (size in KB, reps) -- more reps for small sizes so ticks is measurable
  int sizesKB[] = {64, 256, 1024, 4096, 8192};
  int reps[]    = {50, 20,  8,    3,    2};
  int n = 5;

  printf("=== IPC benchmark: pipe vs SHM+SEM (CHUNK=%d, SLOTS=%d) ===\n", CHUNK, SLOTS);
  printf("--- PIPE ---\n");
  for(int i = 0; i < n; i++) measure("PIPE", 0, sizesKB[i]*1024, reps[i]);
  printf("--- SHM+SEM ---\n");
  for(int i = 0; i < n; i++) measure("SHM ", 1, sizesKB[i]*1024, reps[i]);

  printf("\n=== correctness: %s ===\n", g_pass ? "ALL TRANSFERS VERIFIED" : "SOME FAILED");
  exit(0);
}

