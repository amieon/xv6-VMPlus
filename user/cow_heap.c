#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
  char *p = sbrk(4096);
  if(p == (char*)-1){
    printf("sbrk failed\n");
    exit(1);
  }

  p[0] = 'A';
  p[4095] = 'Z';

  int pid = fork();
  if(pid < 0) exit(1);

  if(pid == 0){
    p[0] = 'B';
    p[4095] = 'Y';
    printf("child: %c %c (expect B Y)\n", p[0], p[4095]);
    if(p[0] != 'B' || p[4095] != 'Y') printf("FAIL child\n");
    exit(0);
  }

  wait(0);
  printf("parent: %c %c (expect A Z)\n", p[0], p[4095]);
  if(p[0] != 'A' || p[4095] != 'Z') printf("FAIL parent\n");
  printf("PASS\n");
  exit(0);
}
