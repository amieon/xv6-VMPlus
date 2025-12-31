#include "spinlock.h"
#include "defs.h"
#include "types.h"
#define NSEM 64

struct sem {
  int used;
  int key;
  int val;
  int waiters;   // 调试用
};

struct {
  struct spinlock lock;
  struct sem s[NSEM];
} semt;

void
seminit(void)
{
  initlock(&semt.lock, "semt");
}

// 找到 key 对应 sem；不存在返回 -1
static int
sem_lookup(int key)
{
  for(int i = 0; i < NSEM; i++){
    if(semt.s[i].used && semt.s[i].key == key)
      return i;
  }
  return -1;
}

// 创建或返回已有
int
sem_open(int key, int init)
{
  acquire(&semt.lock);

  int idx = sem_lookup(key);
  if(idx >= 0){
    release(&semt.lock);
    return 0;  // 已存在，直接成功
  }

  for(int i = 0; i < NSEM; i++){
    if(!semt.s[i].used){
      semt.s[i].used = 1;
      semt.s[i].key = key;
      semt.s[i].val = init;
      semt.s[i].waiters = 0;
      release(&semt.lock);
      return 0;
    }
  }

  release(&semt.lock);
  return -1;
}

int
sem_wait(int key)
{
  acquire(&semt.lock);

  int idx = sem_lookup(key);
  if(idx < 0){
    release(&semt.lock);
    return -1;
  }

  // while(val==0) sleep
  while(semt.s[idx].val == 0){
    semt.s[idx].waiters++;
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    semt.s[idx].waiters--;
  }

  semt.s[idx].val--;
  release(&semt.lock);
  return 0;
}

int
sem_post(int key)
{
  acquire(&semt.lock);

  int idx = sem_lookup(key);
  if(idx < 0){
    release(&semt.lock);
    return -1;
  }

  semt.s[idx].val++;

  // 唤醒一个或全部：先做全部更简单也正确
  wakeup(&semt.s[idx]);

  release(&semt.lock);
  return 0;
}
