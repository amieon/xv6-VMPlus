/*
 * ulib.c - 用户空间库函数集合
 * 
 * 该文件包含操作系统用户空间程序所需的基本库函数，包括：
 * - 字符串处理函数（strcpy, strcmp, strlen等）
 * - 内存管理函数（memset, memcpy, memmove等）
 * - 文件操作函数（stat）
 * - 系统调用包装函数
 * - 程序启动和退出处理
 * 
 * 这些函数为用户程序提供了与内核交互的基本接口和常用功能实现。
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "kernel/riscv.h"
#include "kernel/vm.h"
#include "user/user.h"


/*
 * start - 程序启动函数包装器
 * 
 * 该函数作为用户程序的入口点，调用main函数并确保程序正确退出
 * 即使main函数没有显式调用exit
 * 
 * 参数：
 *   argc - 命令行参数数量
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  exit(r);
}

/*
 * strcpy - 字符串复制函数
 * 
 * 将源字符串t复制到目标字符串s中
 * 
 * 参数：
 *   s - 目标字符串指针
 *   t - 源字符串指针
 * 
 * 返回值：
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    ;
  return os;
}

/*
 * strcmp - 字符串比较函数
 * 
 * 比较两个字符串p和q的大小
 * 
 * 参数：
 *   p - 第一个字符串指针
 *   q - 第二个字符串指针
 * 
 * 返回值：
 *   0 - 两个字符串相等
 *   正数 - p大于q
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    p++, q++;
  return (uchar)*p - (uchar)*q;
}

/*
 * strlen - 字符串长度计算函数
 * 
 * 计算字符串s的长度（不包括结尾的null字符）
 * 
 * 参数：
 *   s - 字符串指针
 * 
 * 返回值：
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
    ;
  return n;
}

/*
 * memset - 内存设置函数
 * 
 * 将目标内存区域的前n个字节设置为指定的值c
 * 
 * 参数：
 *   dst - 目标内存区域指针
 *   c - 要设置的值
 *   n - 要设置的字节数
 * 
 * 返回值：
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    cdst[i] = c;
  }
  return dst;
}

/*
 * strchr - 字符串字符查找函数
 * 
 * 在字符串s中查找第一个出现的字符c
 * 
 * 参数：
 *   s - 字符串指针
 *   c - 要查找的字符
 * 
 * 返回值：
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
}

/*
 * gets - 从标准输入读取一行
 * 
 * 从标准输入读取一行文本，最多读取max-1个字符
 * 
 * 参数：
 *   buf - 存储读取结果的缓冲区
 *   max - 缓冲区的最大容量
 * 
 * 返回值：
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
  return buf;
}

/*
 * stat - 获取文件状态信息
 * 
 * 获取指定文件的状态信息并存储到st结构体中
 * 
 * 参数：
 *   n - 文件名
 *   st - 存储文件状态信息的结构体指针
 * 
 * 返回值：
 *   0 - 成功
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
  close(fd);
  return r;
}

/*
 * atoi - 字符串转换为整数
 * 
 * 将字符串s转换为整数
 * 
 * 参数：
 *   s - 要转换的字符串
 * 
 * 返回值：
 *   转换后的整数
 */

int
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    n = n*10 + *s++ - '0';
  return n;
}

/*
 * memmove - 内存移动函数
 * 
 * 将源内存区域的前n个字节复制到目标内存区域，处理重叠区域
 * 
 * 参数：
 *   vdst - 目标内存区域指针
 *   vsrc - 源内存区域指针
 *   n - 要复制的字节数
 * 
 * 返回值：
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    while(n-- > 0)
      *dst++ = *src++;
  } else {
    dst += n;
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}

/*
 * memcmp - 内存比较函数
 * 
 * 比较两个内存区域的前n个字节
 * 
 * 参数：
 *   s1 - 第一个内存区域指针
 *   s2 - 第二个内存区域指针
 *   n - 要比较的字节数
 * 
 * 返回值：
 *   0 - 两个内存区域相等
 *   正数 - s1大于s2
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    if (*p1 != *p2) {
      return *p1 - *p2;
    }
    p1++;
    p2++;
  }
  return 0;
}

/*
 * memcpy - 内存复制函数
 * 
 * 将源内存区域的前n个字节复制到目标内存区域
 * 
 * 参数：
 *   dst - 目标内存区域指针
 *   src - 源内存区域指针
 *   n - 要复制的字节数
 * 
 * 返回值：
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
}

/*
 * sbrk - 扩展进程的堆空间（立即分配）
 * 
 * 调用系统调用sys_sbrk扩展进程的堆空间，使用立即分配模式
 * 
 * 参数：
 *   n - 要扩展的字节数
 * 
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
  return sys_sbrk(n, SBRK_EAGER);
}

/*
 * sbrklazy - 扩展进程的堆空间（延迟分配）
 * 
 * 调用系统调用sys_sbrk扩展进程的堆空间，使用延迟分配模式
 * 
 * 参数：
 *   n - 要扩展的字节数
 * 
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
  return sys_sbrk(n, SBRK_LAZY);
}

