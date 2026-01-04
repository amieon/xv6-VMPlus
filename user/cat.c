/*
 * cat.c - 文件内容显示工具
 * 
 * 该程序用于显示文件内容到标准输出。如果没有指定文件，则从标准输入读取
 * 内容并显示到标准输出。
 * 
 * 使用方法：
 *   cat [文件1] [文件2] ...
 * 
 * 功能：
 *   - 从指定文件读取内容并显示
 *   - 支持多个文件的连续显示
 *   - 当没有指定文件时，从标准输入读取
 *   - 处理文件读取和写入错误
 */

#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

/* 用于存储读取数据的缓冲区 */
char buf[512];

/*
 * cat - 读取并显示文件内容
 * 
 * 从指定的文件描述符读取内容，并将其写入到标准输出
 * 
 * 参数：
 *   fd - 要读取的文件描述符
 * 
 * 返回值：
 *   无返回值，如果发生错误会直接退出程序
 */
void
cat(int fd)
{
  int n;

  /* 循环读取文件内容，直到文件结束或发生错误 */
  while((n = read(fd, buf, sizeof(buf))) > 0) {
    /* 将读取的内容写入标准输出 */
    if (write(1, buf, n) != n) {
      fprintf(2, "cat: write error\n");
      exit(1);
    }
  }
  /* 检查读取错误 */
  if(n < 0){
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}

/*
 * main - 程序入口点
 * 
 * 解析命令行参数，打开指定的文件并调用cat函数显示内容
 * 
 * 参数：
 *   argc - 命令行参数数量
 *   argv - 命令行参数数组
 * 
 * 返回值：
 *   0 - 程序正常退出
 *   1 - 程序异常退出
 */
int
main(int argc, char *argv[])
{
  int fd, i;

  /* 如果没有指定文件，从标准输入读取 */
  if(argc <= 1){
    cat(0);
    exit(0);
  }

  /* 处理每个指定的文件 */
  for(i = 1; i < argc; i++){
    /* 以只读方式打开文件 */
    if((fd = open(argv[i], O_RDONLY)) < 0){
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    /* 显示文件内容 */
    cat(fd);
    /* 关闭文件 */
    close(fd);
  }
  exit(0);
}
