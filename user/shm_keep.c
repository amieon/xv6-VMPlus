#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "../kernel/shm.h"
#include "user.h"

int 
main(void)
{
  int key = 1;
  char *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  if(p == (char*)-1){
    printf("mmap fail\n");
    exit(1);
  }

  int pid = fork();
  if(pid == 0){
    // child：持有映射，写入，然后睡一会儿别退出
    p[0] = 99;
    printf("child wrote 99\n");
    sleep(50);
    printf("child still sees %d\n", p[0]);
    munmap(p, 4096);
    exit(0);
  }

  // parent：等 child 写完
  sleep(20);
  printf("parent sees %d before unmap\n", p[0]);

  // parent 解除映射
  if(munmap(p, 4096) < 0){
    printf("parent munmap failed\n");
    exit(1);
  }

  // parent 再次 mmap 同 key（此时 child 还活着、refcnt>0）
  char *q = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  if(q == (char*)-1){
    printf("remap fail\n");
    exit(1);
  }

  printf("parent sees %d after remap\n", q[0]); // 预期仍是 99

  wait(0);
  munmap(q, 4096);
  exit(0);
}
