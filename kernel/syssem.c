#include "types.h"
#include "defs.h"


uint64
sys_sem_open(void)
{
  int key, init;
  argint(0, &key);
  argint(1, &init);
  return sem_open(key, init);
}

uint64
sys_sem_wait(void)
{
  int key;
  argint(0, &key);
  return sem_wait(key);
}

uint64
sys_sem_post(void)
{
  int key;
  argint(0, &key);
  return sem_post(key);
}
