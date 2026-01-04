/*
 * rm.c - 文件删除工具
 * 
 * 该程序用于删除指定的文件
 * 支持删除多个文件，只要有一个文件删除失败就会终止执行
 * 
 * 使用方法：rm files...
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

/*
 * main - 程序入口函数
 * 
 * 删除命令行参数中指定的所有文件
 * 
 * 参数：
 *   argc - 命令行参数数量
 *   argv - 命令行参数数组，包含要删除的文件名列表
 * 
 * 返回值：
 *   成功删除所有文件时返回0，否则返回1
 */
int
main(int argc, char *argv[])
{
  int i;

  /* 检查是否提供了要删除的文件名 */
  if(argc < 2){
    fprintf(2, "Usage: rm files...\n");
    exit(1);
  }

  /* 遍历所有指定的文件名并尝试删除 */
  for(i = 1; i < argc; i++){
    /* 调用unlink系统调用删除文件 */
    if(unlink(argv[i]) < 0){
      fprintf(2, "rm: %s failed to delete\n", argv[i]);
      break;  /* 如果删除失败，终止循环 */
    }
  }

  /* 程序退出 */
  exit(0);
}
