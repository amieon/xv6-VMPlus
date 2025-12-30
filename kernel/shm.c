#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "shm.h"



struct shmobj {
  int used;
  int key;
  int npages;
  uint64 pa[SHM_MAXPG];   // 每页一个物理页地址，0 表示还没分配（lazy）
  int refcnt;             
};

static struct {
  struct spinlock lock;
  struct shmobj obj[NSHM];
} shmt;

void
shm_init(void)
{
  initlock(&shmt.lock, "shmt");
}

// 找到或创建 key 对应对象，返回 index；失败返回 -1
int
shm_get(int key, int npages)
{
  acquire(&shmt.lock);

  // 先找已有
  for(int i=0;i<NSHM;i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
        return -1;
      }
      shmt.obj[i].refcnt++;
      release(&shmt.lock);
      return i;
    }
  }

  // 再创建
  for(int i=0;i<NSHM;i++){
    if(!shmt.obj[i].used){
      shmt.obj[i].used = 1;
      shmt.obj[i].key = key;
      shmt.obj[i].npages = npages;
      shmt.obj[i].refcnt = 1;
      for(int j=0;j<npages;j++) shmt.obj[i].pa[j] = 0;
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
  return -1;
}

// refcnt--，若为 0 则释放对象里的所有页（kfree 会走页 refcnt，安全）
void
shm_put(int key)
{
  acquire(&shmt.lock);
  for(int i=0;i<NSHM;i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      shmt.obj[i].refcnt--;
      if(shmt.obj[i].refcnt == 0){
        for(int j=0;j<shmt.obj[i].npages;j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
            shmt.obj[i].pa[j] = 0;
          }
        }
        shmt.obj[i].used = 0;
      }
      break;
    }
  }
  release(&shmt.lock);
}

// 取某页的 pa；若未分配则分配（lazy），返回 pa 或 0
uint64
shm_getpa(int key, int page_index)
{
  uint64 pa = 0;
  acquire(&shmt.lock);

  for(int i=0;i<NSHM;i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
        pa = 0;
        break;
      }
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
        if(mem == 0){
          pa = 0;
          break;
        }
        memset(mem, 0, PGSIZE);
        shmt.obj[i].pa[page_index] = (uint64)mem;
      }
      pa = shmt.obj[i].pa[page_index];
      break;
    }
  }

  release(&shmt.lock);
  return pa;
}
