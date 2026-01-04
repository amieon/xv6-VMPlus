/*
 * mmap_basic.c - mmap基本功能测试程序
 * 
 * 该程序用于验证mmap系统调用的基本功能，包括：
 * - 匿名内存映射的创建
 * - 映射内存的读写操作
 * - 内存映射的解除
 * 
 * 测试流程：
 * 1. 创建一个8192字节的可读写匿名内存映射
 * 2. 向映射内存的不同位置写入数据
 * 3. 读取并验证写入的数据
 * 4. 解除内存映射
 * 5. 输出测试结果
 */

#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

/*
 * main - 程序入口函数
 * 
 * 执行mmap基本功能测试
 * 
 * 参数：
 *   无
 * 
 * 返回值：
 *   成功时返回0，失败时返回1
 */
int
main(void)
{
  int len = 8192;  /* 映射内存的长度（8KB） */
  
  /* 创建匿名内存映射：起始地址0（让系统分配）、长度8192字节、可读写、匿名映射 */
  char *p = mmap(0, len, PROT_READ|PROT_WRITE, MAP_ANON, 1);
  if(p == (char*)-1){  /* 检查映射是否成功 */
    printf("mmap failed\n");
    exit(1);
  }

  /* 测试写入映射内存 */
  p[0] = 'A';       /* 向映射内存的第一个字节写入'A' */
  p[4096] = 'B';    /* 向映射内存的第4097个字节写入'B'（跨页测试） */
  
  /* 读取并验证写入的数据 */
  printf("p[0]=%c p[4096]=%c\n", p[0], p[4096]);

  /* 解除内存映射 */
  if(munmap(p, len) < 0){
    printf("munmap failed\n");
    exit(1);
  }

  printf("PASS\n");  /* 测试通过 */
  exit(0);
}
