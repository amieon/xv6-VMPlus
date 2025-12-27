#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int x = 1;

int
main(void)
{
  int pid = fork();
  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
    x = 2;
    printf("child: x=%d\n", x);
    exit(0);
  }
  wait(0);
  printf("parent: x=%d\n", x);
  if(x != 1){
    printf("FAIL: parent saw x=%d\n", x);
    exit(1);
  }
  printf("PASS\n");
  exit(0);
}
