#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

#define NP 8

int
main(void)
{
  char *p = sbrk(NP * 4096);
  if(p == (char*)-1) exit(1);

  for(int k = 0; k < NP; k++)
    p[k*4096] = 'A' + k;

  int pid = fork();
  if(pid < 0) exit(1);

  if(pid == 0){
    for(int k = 0; k < NP; k++)
      p[k*4096] = 'a' + k;
    printf("child wrote %d pages\n", NP);
    exit(0);
  }

  wait(0);
  for(int k = 0; k < NP; k++){
    if(p[k*4096] != 'A' + k){
      printf("FAIL: parent page %d changed to %c\n", k, p[k*4096]);
      exit(1);
    }
  }
  printf("PASS\n");
  exit(0);
}
