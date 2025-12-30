#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int main(){
  char *p = mmap(0, 8192, PROT_READ|PROT_WRITE, MAP_ANON, 1);
  p[0] = 'A';
  // 不调用 munmap，直接 exit
  exit(0);
}
