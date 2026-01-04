/*
 * ls.c - 文件系统查看工具
 * 
 * 该程序用于列出指定目录中的文件和子目录信息，或显示单个文件的详细信息
 * 支持的功能：
 * - 列出当前目录内容（默认行为）
 * - 列出指定文件或目录的详细信息
 * - 显示文件名、文件类型、inode号和文件大小
 * 
 * 文件类型说明：
 * - T_FILE: 普通文件
 * - T_DIR: 目录
 * - T_DEVICE: 设备文件
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

/*
 * fmtname - 格式化路径名，提取文件名部分
 * 
 * 将完整路径转换为仅包含文件名的字符串，并进行适当的对齐处理
 * 
 * 参数：
 *   path - 完整的文件路径
 * 
 * 返回值：
 *   指向格式化后的文件名的指针
 */
char*
fmtname(char *path)
{
  static char buf[DIRSIZ+1];  /* 用于存储格式化后的文件名，注意静态存储 */
  char *p;

  /* 从路径末尾开始查找最后一个斜杠 */
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
    ;
  p++;  /* 指向文件名的第一个字符 */

  /* 如果文件名长度大于等于DIRSIZ，直接返回原指针 */
  if(strlen(p) >= DIRSIZ)
    return p;
  /* 否则将文件名复制到buf并在末尾填充空格以达到DIRSIZ长度 */
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';  /* 确保字符串以空字符结尾 */
  return buf;
}

/*
 * ls - 列出指定路径的文件信息
 * 
 * 根据文件类型（普通文件、目录、设备）执行不同的显示逻辑
 * 
 * 参数：
 *   path - 要列出的文件或目录路径
 * 
 * 返回值：
 *   无
 */
void
ls(char *path)
{
  char buf[512], *p;
  int fd;
  struct dirent de;  /* 目录项结构 */
  struct stat st;    /* 文件状态结构 */

  /* 尝试打开路径 */
  if((fd = open(path, O_RDONLY)) < 0){
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  /* 获取文件状态信息 */
  if(fstat(fd, &st) < 0){
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  /* 根据文件类型执行不同的处理逻辑 */
  switch(st.type){
  case T_DEVICE:  /* 设备文件 */
  case T_FILE:    /* 普通文件 */
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
    break;

  case T_DIR:     /* 目录文件 */
    /* 检查路径长度是否超过缓冲区大小限制 */
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      printf("ls: path too long\n");
      break;
    }
    /* 构造目录路径 */
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';  /* 添加路径分隔符 */
    /* 遍历目录中的所有项 */
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)  /* 跳过未使用的目录项 */
        continue;
      /* 构造完整的文件路径 */
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      /* 获取文件状态信息 */
      if(stat(buf, &st) < 0){
        printf("ls: cannot stat %s\n", buf);
        continue;
      }
      /* 输出文件信息 */
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);  /* 关闭文件描述符 */
}

/*
 * main - 程序入口函数
 * 
 * 处理命令行参数，调用ls函数列出指定路径的文件信息
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

  /* 如果没有提供命令行参数，默认列出当前目录 */
  if(argc < 2){
    ls(".");
    exit(0);
  }
  /* 否则遍历所有指定的路径并列出信息 */
  for(i=1; i<argc; i++)
    ls(argv[i]);
  exit(0);
}
