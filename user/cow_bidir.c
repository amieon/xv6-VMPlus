#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int x = 100;

int
main(void)
{
  int pid = fork();
  if(pid < 0) exit(1);

    if(pid == 0){
    // child
    x = 200;
    printf("child: x=%d\n", x);
    exit(0);
    }


  // parent writes
  x = 300;
  wait(0);
  printf("parent: x=%d (expect 300)\n", x);
  if(x != 300) printf("FAIL parent\n");
  printf("PASS\n");
  exit(0);
}
