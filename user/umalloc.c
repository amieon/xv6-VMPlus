/*
 * umalloc.c - 用户空间内存分配器
 * 
 * 该文件实现了一个基于K&R经典设计的内存分配器，用于用户空间程序的动态内存管理
 * 实现了malloc和free函数，提供内存分配和释放功能
 * 
 * 内存分配器使用空闲链表管理可用内存块，每个内存块包含一个头部和实际数据区域
 * 头部包含指向下一个空闲块的指针和块大小信息
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

/* 用于内存对齐的类型 */
typedef long Align;

/* 内存块头部结构 */
union header {
  struct {
    union header *ptr;  /* 指向下一个空闲块的指针 */
    uint size;         /* 块大小（以头部大小为单位） */
  } s;
  Align x;             /* 用于内存对齐 */
};

/* 定义头部类型别名 */
typedef union header Header;

/* 空闲链表的基础块 */
static Header base;
/* 空闲链表的头指针 */
static Header *freep;

/*
 * free - 释放内存块
 * 
 * 将内存块返还给空闲链表，可能会与相邻的空闲块合并
 * 
 * 参数：
 *   ap - 要释放的内存块指针
 * 
 * 返回值：
 *   无
 */

void
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
  /* 更新空闲链表头指针 */
  freep = p;
}

/*
 * morecore - 从内核获取更多内存
 * 
 * 当空闲链表中没有足够大的块时，调用sbrk系统调用扩展堆空间
 * 
 * 参数：
 *   nu - 需要的内存块数量（以头部大小为单位）
 * 
 * 返回值：
 *   指向新分配内存块的指针，失败则返回0
 */

static Header*
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)  /* 最少分配4096个头部大小的内存 */
    nu = 4096;
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
  return freep;
}

/*
 * malloc - 分配内存块
 * 
 * 从空闲链表中分配指定大小的内存块
 * 
 * 参数：
 *   nbytes - 需要的字节数
 * 
 * 返回值：
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){  /* 找到足够大的块 */
      if(p->s.size == nunits)  /* 块大小正好匹配 */
        prevp->s.ptr = p->s.ptr;
      else {  /* 块大小大于需求，分割块 */
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
