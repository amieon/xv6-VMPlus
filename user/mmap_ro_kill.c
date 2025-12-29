#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int main(){
  char *p = mmap(0, 4096, PROT_READ, MAP_ANON);
  printf("about to write (should die)\n");
  p[0] = 1; // 应该被 kill
  printf("FAIL: still alive\n");
  exit(1);
}
