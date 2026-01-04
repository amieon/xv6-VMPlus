/*
 * echo.c - 回显命令行参数的用户程序
 * 
 * 该程序将命令行参数输出到标准输出，参数之间用空格分隔，最后输出换行符
 * 是一个基本的用户空间工具程序，用于调试和简单的文本输出
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

/*
 * main - 程序入口函数
 * 
 * 将命令行参数输出到标准输出
 * 
 * 参数：
 *   argc - 命令行参数数量
 *   argv - 命令行参数数组
 * 
 * 返回值：
 *   始终返回0表示成功执行
 */
int
main(int argc, char *argv[])
{
  int i;

  /* 遍历所有命令行参数（从索引1开始，跳过程序名） */
  for(i = 1; i < argc; i++){
    /* 输出当前参数 */
    write(1, argv[i], strlen(argv[i]));
    /* 如果不是最后一个参数，输出空格分隔符 */
    if(i + 1 < argc){
      write(1, " ", 1);
    } else {
      /* 最后一个参数，输出换行符 */
      write(1, "\n", 1);
    }
  }
  /* 程序正常退出 */
  exit(0);
}
