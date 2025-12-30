#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int
main(void)
{
  char *a = mmap(0, 2*4096, PROT_READ|PROT_WRITE, MAP_ANON);
  char *b = mmap(0, 2*4096, PROT_READ|PROT_WRITE, MAP_ANON);
  if(a == (char*)-1 || b == (char*)-1){
    printf("mmap failed\n");
    exit(1);
  }

  a[0] = 'A';
  a[4096] = 'a';
  b[0] = 'B';
  b[4096] = 'b';

  printf("a=%p b=%p\n", a, b);

  // 从 a 的第二页开始，unmap 3 页：覆盖 a[1页] + (可能的空洞) + b[0页]
  int r = munmap(a + 4096, 3*4096);
  printf("munmap ret=%d\n", r);

  if(r < 0){
    printf("OK: cross-VMA munmap not supported\n");
    exit(0);
  }

  // 支持跨 VMA 时：
  // a[0] 应该还活着
  printf("a0=%c\n", a[0]);

  // a[4096] 已被 unmap（应死）
  printf("touch a[4096] (should die): %c\n", a[4096]);

  // b[0] 已被 unmap（应死）
  printf("touch b[0] (should die): %c\n", b[0]);

  // b[4096] 可能还活（取决于布局/是否真相邻），但一般会活
  printf("b[4096]=%c\n", b[4096]);

  exit(0);
}
