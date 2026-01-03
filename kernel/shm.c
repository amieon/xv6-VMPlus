#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "shm.h"
#include "vmstats.h"


struct shmobj {
  int used;
  int key;
  int npages;
  uint64 pa[SHM_MAXPG];   // 每页一个物理页地址，0 表示还没分配（lazy）
  int refcnt;             
  int deleted;   // 1 表示已被 IPC_RMID 标记，拒绝新的 shm_get
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
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
        return -1;
      }
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
      shmt.obj[i].deleted = 0;
      shmt.obj[i].used = 1;
      shmt.obj[i].key = key;
      shmt.obj[i].npages = npages;
      shmt.obj[i].refcnt = 1;
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
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
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
      shmt.obj[i].refcnt--;
      if(shmt.obj[i].refcnt == 0){
        for(int j=0;j<shmt.obj[i].npages;j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
            shmt.obj[i].pa[j] = 0;
          }
        }
        shmt.obj[i].used = 0;
        shmt.obj[i].deleted = 0;
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
  vmstats_inc_shm();

  return pa;
}


int
shm_ctl(int key, int cmd)
{
  if(cmd != IPC_RMID)
    return -1;

  acquire(&shmt.lock);

  for(int i = 0; i < NSHM; i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){

      // 标记删除：后续拒绝新的 shm_get
      shmt.obj[i].deleted = 1;

      // 如果没人引用了，立刻释放
      if(shmt.obj[i].refcnt == 0){
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
            shmt.obj[i].pa[j] = 0;
          }
        }
        shmt.obj[i].used = 0;
        shmt.obj[i].deleted = 0;
        shmt.obj[i].key = 0;     
        shmt.obj[i].npages = 0;  

      }


      release(&shmt.lock);
      return 0;
    }
  }

  release(&shmt.lock);
  return -1; // key 不存在
}

int
shm_is_deleted(int key)
{
  int del = 0; // 默认0,不存在就允许创建
  acquire(&shmt.lock);
  for(int i=0;i<NSHM;i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      del = shmt.obj[i].deleted;
      break;
    }
  }
  release(&shmt.lock);
  //shm_dump(key);
  return del;

}
// void
// shm_dump(int key)
// {
//   acquire(&shmt.lock);
//   for(int i=0;i<NSHM;i++){
//     if(shmt.obj[i].used && shmt.obj[i].key == key){
//       printf("[shm] key=%d idx=%d used=%d ref=%d del=%d np=%d\n",
//         key, i, shmt.obj[i].used, shmt.obj[i].refcnt,
//         shmt.obj[i].deleted, shmt.obj[i].npages);
//       release(&shmt.lock);
//       return;
//     }
//   }
//   printf("[shm] key=%d not found\n", key);
//   release(&shmt.lock);
// }
