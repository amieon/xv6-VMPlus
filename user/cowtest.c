#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int x = 1;

int
main(void)
{
  int pid = fork();
  if(pid == 0){
    x = 2;
    printf("child: x=%d\n", x);
    exit(0);
  }
  wait(0);
  printf("parent: x=%d\n", x);
  exit(0);
}
