/*
 * printf.c - 格式化输出函数实现
 * 
 * 该文件实现了格式化输出功能，支持以下格式说明符：
 * - %d - 十进制整数
 * - %x - 十六进制整数
 * - %p - 指针地址
 * - %c - 字符
 * - %s - 字符串
 * - %% - 百分号本身
 * 
 * 同时支持长整数格式：
 * - %ld, %lu, %lx - long类型
 * - %lld, %llu, %llx - long long类型
 * 
 * 这些函数为用户程序提供了灵活的输出方式，是操作系统用户空间的基础库函数之一。
 */

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#include <stdarg.h>

/* 用于数字转换的字符数组 */
static char digits[] = "0123456789ABCDEF";

/*
 * putc - 输出单个字符
 * 
 * 将单个字符写入到指定的文件描述符
 * 
 * 参数：
 *   fd - 文件描述符
 *   c - 要输出的字符
 * 
 * 返回值：
 *   无
 */

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
}

/*
 * printint - 输出整数
 * 
 * 将整数以指定进制和符号格式输出到文件描述符
 * 
 * 参数：
 *   fd - 文件描述符
 *   xx - 要输出的整数
 *   base - 输出进制（2-16）
 *   sgn - 是否为有符号整数
 * 
 * 返回值：
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    putc(fd, buf[i]);
}

/*
 * printptr - 输出指针地址
 * 
 * 将指针地址以十六进制格式输出到文件描述符
 * 
 * 参数：
 *   fd - 文件描述符
 *   x - 要输出的指针地址
 * 
 * 返回值：
 *   无
 */

static void
printptr(int fd, uint64 x) {
  int i;
  putc(fd, '0');
  putc(fd, 'x');
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

/*
 * vprintf - 可变参数格式化输出
 * 
 * 核心格式化输出函数，解析格式字符串并输出对应内容
 * 
 * 参数：
 *   fd - 文件描述符
 *   fmt - 格式字符串
 *   ap - 可变参数列表
 * 
 * 返回值：
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    c0 = fmt[i] & 0xff;
    if(state == 0){
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
        printint(fd, va_arg(ap, uint32), 10, 0);
      } else if(c0 == 'l' && c1 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
        printint(fd, va_arg(ap, uint32), 16, 0);
      } else if(c0 == 'l' && c1 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
        putc(fd, '%');
      } else {
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    }
  }
}

/*
 * fprintf - 输出到文件的格式化函数
 * 
 * 将格式化输出写入到指定文件描述符
 * 
 * 参数：
 *   fd - 文件描述符
 *   fmt - 格式字符串
 *   ... - 可变参数列表
 * 
 * 返回值：
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
  va_list ap;

  va_start(ap, fmt);
  vprintf(fd, fmt, ap);
}

/*
 * printf - 标准输出的格式化函数
 * 
 * 将格式化输出写入到标准输出（文件描述符1）
 * 
 * 参数：
 *   fmt - 格式字符串
 *   ... - 可变参数列表
 * 
 * 返回值：
 *   无
 */

void
printf(const char *fmt, ...)
{
  va_list ap;

  va_start(ap, fmt);
  vprintf(1, fmt, ap);
}
