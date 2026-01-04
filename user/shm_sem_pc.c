#include "../kernel/types.h"
#include "user.h"

struct shmblk {
  int x;
};

int
main(void)
{
  int key = 2;
  struct shmblk *p = (struct shmblk*)mmap(0, 4096, PROT_READ|PROT_WRITE,
                                         MAP_ANON|MAP_SHARED, key);
  if(p == (void*)-1){
    printf("mmap fail\n");
    exit(1);
  }

  // sem key 我建议用不同 key，避免混淆
  int sem_empty = 100;
  int sem_full  = 101;

  if(sem_open(sem_empty, 1) < 0 || sem_open(sem_full, 0) < 0){
    printf("sem_open fail\n");
    exit(1);
  }

  int pid = fork();
  if(pid == 0){
    // consumer
    for(int i=1;i<=20;i++){
      sem_wait(sem_full);
      int v = p->x;
      printf("C got %d\n", v);
      sem_post(sem_empty);
    }
    exit(0);
  }

  // producer
  for(int i=1;i<=20;i++){
    sem_wait(sem_empty);
    p->x = i;
    printf("P put %d\n", i);
    sem_post(sem_full);
  }

  wait(0);
  munmap((char*)p, 4096);
  exit(0);
}
