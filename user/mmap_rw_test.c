#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int main(){
  char *p = mmap(0, 8192, PROT_READ|PROT_WRITE, MAP_ANON, 1);
  p[0] = 'A';
  p[4096] = 'B';
  if(p[0]=='A' && p[4096]=='B') printf("RW PASS\n");
  munmap(p, 8192);
  exit(0);
}
