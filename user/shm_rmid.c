#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "../kernel/shm.h"
#include "user.h"


int main(void){
  int key = 1;
  char *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  if(p == (char*)-1){ printf("mmap1 fail\n"); exit(1); }
  p[0] = 7;

  int pid = fork();
  if(pid == 0){
    char *c = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
    if(c == (char*)-1){ printf("child mmap fail\n"); exit(1); }
    printf("child sees %d\n", c[0]);
    sleep(50);
    printf("child still sees %d\n", c[0]);
    munmap(c, 4096);
    exit(0);
  }

  sleep(20);
  printf("parent rmid: %d\n", shmctl(key, IPC_RMID));

  // deleted 后不允许新的 attach
  char *q = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  if(q != (char*)-1){
    printf("FAIL: mmap after rmid should fail\n");
    exit(1);
  } else {
    printf("OK: mmap after rmid rejected\n");
  }

  wait(0);
  munmap(p, 4096);

  // 现在对象应已真正释放；再 mmap 应得到新对象（默认内容 0）
  char *r = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  if(r == (char*)-1){ printf("mmap after free fail\n"); exit(1); }
  printf("new object r[0]=%d (expect 0)\n", r[0]);
  munmap(r, 4096);

  exit(0);
}
