#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
  int len = 8192;
  char *p = mmap(0, len, PROT_READ|PROT_WRITE, MAP_ANON, 1);
  if(p == (char*)-1){
    printf("mmap failed\n");
    exit(1);
  }

  p[0] = 'A';
  p[4096] = 'B';
  printf("p[0]=%c p[4096]=%c\n", p[0], p[4096]);

  if(munmap(p, len) < 0){
    printf("munmap failed\n");
    exit(1);
  }

  printf("PASS\n");
  exit(0);
}
