#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

#define NPAGES 64   // 64 pages = 256KB

int
main(void)
{
  char *p = sbrk(NPAGES * 4096);
  if(p == (char*)-1){
    printf("alloc failed\n");
    exit(1);
  }

  // 预触发页，确保真的分配
  for(int i = 0; i < NPAGES * 4096; i += 4096)
    p[i] = 1;

  int pid = fork();
  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
    // 子进程：只写第一页
    p[0] = 42;
    exit(0);
  }

  wait(0);
  exit(0);
}
