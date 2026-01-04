/*
 * mkdir.c - 目录创建工具
 * 
 * 该程序用于创建指定的目录
 * 支持创建多个目录，只要有一个目录创建失败就会终止执行
 * 
 * 使用方法：mkdir directories...
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

/*
 * main - 程序入口函数
 * 
 * 创建命令行参数中指定的所有目录
 * 
 * 参数：
 *   argc - 命令行参数数量
 *   argv - 命令行参数数组，包含要创建的目录名列表
 * 
 * 返回值：
 *   成功创建所有目录时返回0，否则返回1
 */
int
main(int argc, char *argv[])
{
  int i;

  /* 检查是否提供了要创建的目录名 */
  if(argc < 2){
    fprintf(2, "Usage: mkdir directories...\n");
    exit(1);
  }

  /* 遍历所有指定的目录名并尝试创建 */
  for(i = 1; i < argc; i++){
    /* 调用mkdir系统调用创建目录 */
    if(mkdir(argv[i]) < 0){
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
      break;  /* 如果创建失败，终止循环 */
    }
  }

  /* 程序退出 */
  exit(0);
}
