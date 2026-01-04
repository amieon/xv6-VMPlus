#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
  char *p = sbrk(4096);
  if(p == (char*)-1) exit(1);
  p[0] = 1;

  int n = 40;
  for(int i = 0; i < n; i++){
    int pid = fork();
    if(pid < 0){
      printf("fork failed at %d\n", i);
      break;
    }
    if(pid == 0){
      // 每个子都写一下，触发 COW
      p[0] = (char)(i + 2);
      exit(0);
    }
  }

  while(wait(0) >= 0)
    ;

  // 父进程应该还是原值
  if(p[0] != 1){
    printf("FAIL: parent p[0]=%d\n", p[0]);
    exit(1);
  }
  printf("PASS\n");
  exit(0);
}
