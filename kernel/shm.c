#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "shm.h"
#include "vmstats.h"


/*
 * 共享内存对象结构
 * 
 * 每个共享内存对象代表一个可以被多个进程共享的内存区域，
 * 采用惰性分配机制（lazy allocation），只有在实际使用时才分配物理页。
 */
struct shmobj {
  int used;               // 标识对象是否被使用 (1: 使用中, 0: 空闲)
  int key;                // 共享内存键值，用于标识和查找共享内存对象
  int npages;             // 共享内存的总页数
  uint64 pa[SHM_MAXPG];   // 每页一个物理页地址，0 表示还没分配（lazy allocation）
  int refcnt;             // 引用计数，记录当前有多少进程或VMA引用该共享内存
  int deleted;            // 1 表示已被 IPC_RMID 标记，拒绝新的 shm_get 请求
};

/*
 * 共享内存全局管理结构
 * 
 * 包含一个自旋锁用于同步访问，以及一个共享内存对象数组。
 */
static struct {
  struct spinlock lock;   // 保护共享内存对象的自旋锁
  struct shmobj obj[NSHM];// 共享内存对象数组，最大NSHM个
} shmt;



/*
 * 初始化共享内存子系统
 * 
 * 创建并初始化保护共享内存对象的自旋锁。
 */
void
shm_init(void)
{
  initlock(&shmt.lock, "shmt");
}

/*
 * 找到或创建 key 对应的共享内存对象
 * 
 * 参数：
 *   key    - 共享内存键值，用于标识共享内存对象
 *   npages - 需要的页数（必须小于或等于已有对象的页数）
 * 
 * 返回值：
 *   成功返回共享内存对象的索引；失败返回 -1
 *   失败原因包括：对象已被标记删除、请求页数超过已有对象页数、没有空闲对象槽位
 * 
 * 操作流程：
 *   1. 首先查找是否存在已有的 key 对应的对象
 *   2. 如果找到且满足条件，增加引用计数并返回
 *   3. 如果没找到，创建一个新的共享内存对象
 */
int
shm_get(int key, int npages)
{
  acquire(&shmt.lock);

  // 先查找已有的共享内存对象
  for(int i=0;i<NSHM;i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查对象是否已被标记删除
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
        return -1;
      }
      // 检查请求的页数是否超过对象的总页数
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
        return -1;
      }
      // 增加引用计数
      shmt.obj[i].refcnt++;
      release(&shmt.lock);
      return i;
    }
  }

  // 如果没有找到，创建一个新的共享内存对象
  for(int i=0;i<NSHM;i++){
    if(!shmt.obj[i].used){
      // 初始化新对象
      shmt.obj[i].deleted = 0;
      shmt.obj[i].used = 1;
      shmt.obj[i].key = key;
      shmt.obj[i].npages = npages;
      shmt.obj[i].refcnt = 1;
      // 初始化为0，表示所有物理页都未分配
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
  return -1;  // 没有空闲的共享内存对象槽位
}


/*
 * 减少共享内存对象的引用计数
 * 
 * 参数：
 *   key - 共享内存键值
 * 
 * 操作：
 *   1. 查找 key 对应的共享内存对象
 *   2. 减少引用计数
 *   3. 如果引用计数为 0，释放对象中的所有物理页并重置对象状态
 * 
 * 注意：
 *   - 使用 kfree 释放物理页，kfree 会正确处理页的引用计数
 *   - 如果对象已被标记删除，当引用计数为 0 时也会被完全释放
 */
void
shm_put(int key)
{
  acquire(&shmt.lock);
  for(int i=0;i<NSHM;i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查引用计数的有效性
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
      
      // 减少引用计数
      shmt.obj[i].refcnt--;
      
      // 如果引用计数为 0，释放所有资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j=0;j<shmt.obj[i].npages;j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
            shmt.obj[i].pa[j] = 0;
          }
        }
        // 重置对象状态
        shmt.obj[i].used = 0;
        shmt.obj[i].deleted = 0;
      }
      break;
    }
  }
  release(&shmt.lock);
}

/*
 * 获取共享内存指定页的物理地址（惰性分配）
 * 
 * 参数：
 *   key        - 共享内存键值
 *   page_index - 页索引（从0开始）
 * 
 * 返回值：
 *   成功返回物理页地址；失败返回 0
 *   失败原因包括：对象不存在、页索引越界、内存分配失败
 * 
 * 操作：
 *   1. 查找 key 对应的共享内存对象
 *   2. 检查页索引是否有效
 *   3. 如果该页尚未分配，分配一个新的物理页并初始化为0
 *   4. 返回该页的物理地址
 */
uint64
shm_getpa(int key, int page_index)
{
  uint64 pa = 0;
  acquire(&shmt.lock);

  for(int i=0;i<NSHM;i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查页索引是否有效
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
        pa = 0;
        break;
      }
      
      // 如果该页尚未分配，执行惰性分配
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
        if(mem == 0){
          pa = 0;
          break;
        }
        // 初始化新分配的物理页为0
        memset(mem, 0, PGSIZE);
        shmt.obj[i].pa[page_index] = (uint64)mem;
      }
      
      pa = shmt.obj[i].pa[page_index];
      break;
    }
  }

  release(&shmt.lock);
  vmstats_inc_shm();  // 更新共享内存统计信息

  return pa;
}


/*
 * 控制共享内存对象（目前仅支持 IPC_RMID 命令）
 * 
 * 参数：
 *   key  - 共享内存键值
 *   cmd  - 控制命令（目前仅支持 IPC_RMID）
 * 
 * 返回值：
 *   成功返回 0；失败返回 -1
 *   失败原因包括：不支持的命令、key 不存在
 * 
 * 操作（当 cmd 为 IPC_RMID 时）：
 *   1. 标记共享内存对象为已删除，拒绝新的 shm_get 请求
 *   2. 如果当前引用计数为 0，立即释放所有资源
 *   3. 否则，当引用计数降为 0 时由 shm_put 释放资源
 */
int
shm_ctl(int key, int cmd)
{
  // 目前仅支持 IPC_RMID 命令
  if(cmd != IPC_RMID)
    return -1;

  acquire(&shmt.lock);

  for(int i = 0; i < NSHM; i++){
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 标记删除：后续新的 shm_get 请求将被拒绝
      shmt.obj[i].deleted = 1;

      // 如果当前没有任何进程引用，立即释放资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
            shmt.obj[i].pa[j] = 0;
          }
        }
        // 完全重置对象状态
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
  return -1; // key 对应的共享内存对象不存在
}

/*
 * 检查共享内存对象是否已被标记删除
 * 
 * 参数：
 *   key - 共享内存键值
 * 
 * 返回值：
 *   1 表示对象存在且已被标记删除；
 *   0 表示对象不存在或未被标记删除
 * 
 * 注意：
 *   - 如果对象不存在，默认返回 0（允许创建新对象）
 *   - 用于在 shm_get 时检查是否可以创建或访问共享内存对象
 */
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
