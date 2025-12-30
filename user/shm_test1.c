#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int main(void){
  int key = 1;
  char *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  if(p == (char*)-1){ printf("mmap fail\n"); exit(1); }

  int pid = fork();
  if(pid == 0){
    // child
    for(int i=1;i<10000000;++i)
        ;
    printf("child sees: %d\n", p[0]);
    p[0] = 42;
    printf("child wrote 42\n");
    munmap(p, 4096);
    exit(0);
  } else {
    // parent
    p[0] = 7;
    printf("parent wrote 7\n");
    wait(0);
    printf("parent sees after child: %d\n", p[0]);
    munmap(p, 4096);
    exit(0);
  }
}
