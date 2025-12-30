#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int
main(void)
{
  int len = 3*4096;
  char *p = mmap(0, len, PROT_READ|PROT_WRITE, MAP_ANON);
  if(p == (char*)-1){
    printf("mmap failed\n");
    exit(1);
  }

  p[0] = 'A';
  p[4096] = 'B';
  p[8192] = 'C';
  printf("before: %c %c %c\n", p[0], p[4096], p[8192]);

  // unmap 中间一页
  if(munmap(p + 4096, 4096) < 0){
    printf("munmap failed\n");
    exit(1);
  }

  printf("after: %c %c\n", p[0], p[8192]);

  // 这句应该 kill
  printf("touch hole (should die): %c\n", p[4096]);

  printf("FAIL: still alive\n");
  exit(0);
}
