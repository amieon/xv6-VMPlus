#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
  char *p = sbrk(4096);
  if(p == (char*)-1) exit(1);

  for(int i = 0; i < 4096; i++)
    p[i] = (char)(i % 97);

  int pid = fork();
  if(pid < 0) exit(1);

  if(pid == 0){
    for(int i = 0; i < 4096; i += 7)
      p[i] = (char)(p[i] + 1);
    printf("child: wrote many offsets\n");
    exit(0);
  }

  wait(0);
  // 父校验页内容未变
  for(int i = 0; i < 4096; i++){
    if(p[i] != (char)(i % 97)){
      printf("FAIL: parent page changed at %d\n", i);
      exit(1);
    }
  }
  printf("PASS\n");
  exit(0);
}
