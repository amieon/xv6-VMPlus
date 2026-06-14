
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	2a4000ef          	jal	ra,2ac <fork>
   c:	00a04563          	bgtz	a0,16 <main+0x16>
    pause(5);  // Let child exit before parent.
  exit(0);
  10:	4501                	li	a0,0
  12:	2a2000ef          	jal	ra,2b4 <exit>
    pause(5);  // Let child exit before parent.
  16:	4515                	li	a0,5
  18:	32c000ef          	jal	ra,344 <pause>
  1c:	bfd5                	j	10 <main+0x10>

000000000000001e <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  1e:	1141                	addi	sp,sp,-16
  20:	e406                	sd	ra,8(sp)
  22:	e022                	sd	s0,0(sp)
  24:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  26:	fdbff0ef          	jal	ra,0 <main>
  exit(r);
  2a:	28a000ef          	jal	ra,2b4 <exit>

000000000000002e <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  2e:	1141                	addi	sp,sp,-16
  30:	e422                	sd	s0,8(sp)
  32:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  34:	87aa                	mv	a5,a0
  36:	0585                	addi	a1,a1,1
  38:	0785                	addi	a5,a5,1
  3a:	fff5c703          	lbu	a4,-1(a1)
  3e:	fee78fa3          	sb	a4,-1(a5)
  42:	fb75                	bnez	a4,36 <strcpy+0x8>
    ;
  return os;
}
  44:	6422                	ld	s0,8(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret

000000000000004a <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  4a:	1141                	addi	sp,sp,-16
  4c:	e422                	sd	s0,8(sp)
  4e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  50:	00054783          	lbu	a5,0(a0)
  54:	cb91                	beqz	a5,68 <strcmp+0x1e>
  56:	0005c703          	lbu	a4,0(a1)
  5a:	00f71763          	bne	a4,a5,68 <strcmp+0x1e>
    p++, q++;
  5e:	0505                	addi	a0,a0,1
  60:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  62:	00054783          	lbu	a5,0(a0)
  66:	fbe5                	bnez	a5,56 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  68:	0005c503          	lbu	a0,0(a1)
}
  6c:	40a7853b          	subw	a0,a5,a0
  70:	6422                	ld	s0,8(sp)
  72:	0141                	addi	sp,sp,16
  74:	8082                	ret

0000000000000076 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  7c:	00054783          	lbu	a5,0(a0)
  80:	cf91                	beqz	a5,9c <strlen+0x26>
  82:	0505                	addi	a0,a0,1
  84:	87aa                	mv	a5,a0
  86:	4685                	li	a3,1
  88:	9e89                	subw	a3,a3,a0
  8a:	00f6853b          	addw	a0,a3,a5
  8e:	0785                	addi	a5,a5,1
  90:	fff7c703          	lbu	a4,-1(a5)
  94:	fb7d                	bnez	a4,8a <strlen+0x14>
    ;
  return n;
}
  96:	6422                	ld	s0,8(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret
  for(n = 0; s[n]; n++)
  9c:	4501                	li	a0,0
  9e:	bfe5                	j	96 <strlen+0x20>

00000000000000a0 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a6:	ca19                	beqz	a2,bc <memset+0x1c>
  a8:	87aa                	mv	a5,a0
  aa:	1602                	slli	a2,a2,0x20
  ac:	9201                	srli	a2,a2,0x20
  ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b6:	0785                	addi	a5,a5,1
  b8:	fee79de3          	bne	a5,a4,b2 <memset+0x12>
  }
  return dst;
}
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb99                	beqz	a5,e2 <strchr+0x20>
    if(*s == c)
  ce:	00f58763          	beq	a1,a5,dc <strchr+0x1a>
  for(; *s; s++)
  d2:	0505                	addi	a0,a0,1
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbfd                	bnez	a5,ce <strchr+0xc>
      return (char*)s;
  return 0;
  da:	4501                	li	a0,0
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  return 0;
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strchr+0x1a>

00000000000000e6 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	f852                	sd	s4,48(sp)
  f4:	f456                	sd	s5,40(sp)
  f6:	f05a                	sd	s6,32(sp)
  f8:	ec5e                	sd	s7,24(sp)
  fa:	1080                	addi	s0,sp,96
  fc:	8baa                	mv	s7,a0
  fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 100:	892a                	mv	s2,a0
 102:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 104:	4aa9                	li	s5,10
 106:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 108:	89a6                	mv	s3,s1
 10a:	2485                	addiw	s1,s1,1
 10c:	0344d663          	bge	s1,s4,138 <gets+0x52>
    cc = read(0, &c, 1);
 110:	4605                	li	a2,1
 112:	faf40593          	addi	a1,s0,-81
 116:	4501                	li	a0,0
 118:	1b4000ef          	jal	ra,2cc <read>
    if(cc < 1)
 11c:	00a05e63          	blez	a0,138 <gets+0x52>
    buf[i++] = c;
 120:	faf44783          	lbu	a5,-81(s0)
 124:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 128:	01578763          	beq	a5,s5,136 <gets+0x50>
 12c:	0905                	addi	s2,s2,1
 12e:	fd679de3          	bne	a5,s6,108 <gets+0x22>
  for(i=0; i+1 < max; ){
 132:	89a6                	mv	s3,s1
 134:	a011                	j	138 <gets+0x52>
 136:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 138:	99de                	add	s3,s3,s7
 13a:	00098023          	sb	zero,0(s3)
  return buf;
}
 13e:	855e                	mv	a0,s7
 140:	60e6                	ld	ra,88(sp)
 142:	6446                	ld	s0,80(sp)
 144:	64a6                	ld	s1,72(sp)
 146:	6906                	ld	s2,64(sp)
 148:	79e2                	ld	s3,56(sp)
 14a:	7a42                	ld	s4,48(sp)
 14c:	7aa2                	ld	s5,40(sp)
 14e:	7b02                	ld	s6,32(sp)
 150:	6be2                	ld	s7,24(sp)
 152:	6125                	addi	sp,sp,96
 154:	8082                	ret

0000000000000156 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 156:	1101                	addi	sp,sp,-32
 158:	ec06                	sd	ra,24(sp)
 15a:	e822                	sd	s0,16(sp)
 15c:	e426                	sd	s1,8(sp)
 15e:	e04a                	sd	s2,0(sp)
 160:	1000                	addi	s0,sp,32
 162:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 164:	4581                	li	a1,0
 166:	18e000ef          	jal	ra,2f4 <open>
  if(fd < 0)
 16a:	02054163          	bltz	a0,18c <stat+0x36>
 16e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 170:	85ca                	mv	a1,s2
 172:	19a000ef          	jal	ra,30c <fstat>
 176:	892a                	mv	s2,a0
  close(fd);
 178:	8526                	mv	a0,s1
 17a:	162000ef          	jal	ra,2dc <close>
  return r;
}
 17e:	854a                	mv	a0,s2
 180:	60e2                	ld	ra,24(sp)
 182:	6442                	ld	s0,16(sp)
 184:	64a2                	ld	s1,8(sp)
 186:	6902                	ld	s2,0(sp)
 188:	6105                	addi	sp,sp,32
 18a:	8082                	ret
    return -1;
 18c:	597d                	li	s2,-1
 18e:	bfc5                	j	17e <stat+0x28>

0000000000000190 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 196:	00054603          	lbu	a2,0(a0)
 19a:	fd06079b          	addiw	a5,a2,-48
 19e:	0ff7f793          	andi	a5,a5,255
 1a2:	4725                	li	a4,9
 1a4:	02f76963          	bltu	a4,a5,1d6 <atoi+0x46>
 1a8:	86aa                	mv	a3,a0
  n = 0;
 1aa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1ac:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ae:	0685                	addi	a3,a3,1
 1b0:	0025179b          	slliw	a5,a0,0x2
 1b4:	9fa9                	addw	a5,a5,a0
 1b6:	0017979b          	slliw	a5,a5,0x1
 1ba:	9fb1                	addw	a5,a5,a2
 1bc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c0:	0006c603          	lbu	a2,0(a3)
 1c4:	fd06071b          	addiw	a4,a2,-48
 1c8:	0ff77713          	andi	a4,a4,255
 1cc:	fee5f1e3          	bgeu	a1,a4,1ae <atoi+0x1e>
  return n;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  n = 0;
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <atoi+0x40>

00000000000001da <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e0:	02b57463          	bgeu	a0,a1,208 <memmove+0x2e>
    while(n-- > 0)
 1e4:	00c05f63          	blez	a2,202 <memmove+0x28>
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f2:	0585                	addi	a1,a1,1
 1f4:	0705                	addi	a4,a4,1
 1f6:	fff5c683          	lbu	a3,-1(a1)
 1fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1fe:	fee79ae3          	bne	a5,a4,1f2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
    dst += n;
 208:	00c50733          	add	a4,a0,a2
    src += n;
 20c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 20e:	fec05ae3          	blez	a2,202 <memmove+0x28>
 212:	fff6079b          	addiw	a5,a2,-1
 216:	1782                	slli	a5,a5,0x20
 218:	9381                	srli	a5,a5,0x20
 21a:	fff7c793          	not	a5,a5
 21e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 220:	15fd                	addi	a1,a1,-1
 222:	177d                	addi	a4,a4,-1
 224:	0005c683          	lbu	a3,0(a1)
 228:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 22c:	fee79ae3          	bne	a5,a4,220 <memmove+0x46>
 230:	bfc9                	j	202 <memmove+0x28>

0000000000000232 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 238:	ca05                	beqz	a2,268 <memcmp+0x36>
 23a:	fff6069b          	addiw	a3,a2,-1
 23e:	1682                	slli	a3,a3,0x20
 240:	9281                	srli	a3,a3,0x20
 242:	0685                	addi	a3,a3,1
 244:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 246:	00054783          	lbu	a5,0(a0)
 24a:	0005c703          	lbu	a4,0(a1)
 24e:	00e79863          	bne	a5,a4,25e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 252:	0505                	addi	a0,a0,1
    p2++;
 254:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 256:	fed518e3          	bne	a0,a3,246 <memcmp+0x14>
  }
  return 0;
 25a:	4501                	li	a0,0
 25c:	a019                	j	262 <memcmp+0x30>
      return *p1 - *p2;
 25e:	40e7853b          	subw	a0,a5,a4
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  return 0;
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <memcmp+0x30>

000000000000026c <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 274:	f67ff0ef          	jal	ra,1da <memmove>
}
 278:	60a2                	ld	ra,8(sp)
 27a:	6402                	ld	s0,0(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret

0000000000000280 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 280:	1141                	addi	sp,sp,-16
 282:	e406                	sd	ra,8(sp)
 284:	e022                	sd	s0,0(sp)
 286:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 288:	4585                	li	a1,1
 28a:	0b2000ef          	jal	ra,33c <sys_sbrk>
}
 28e:	60a2                	ld	ra,8(sp)
 290:	6402                	ld	s0,0(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret

0000000000000296 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 296:	1141                	addi	sp,sp,-16
 298:	e406                	sd	ra,8(sp)
 29a:	e022                	sd	s0,0(sp)
 29c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 29e:	4589                	li	a1,2
 2a0:	09c000ef          	jal	ra,33c <sys_sbrk>
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ac:	4885                	li	a7,1
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b4:	4889                	li	a7,2
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2bc:	488d                	li	a7,3
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c4:	4891                	li	a7,4
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <read>:
.global read
read:
 li a7, SYS_read
 2cc:	4895                	li	a7,5
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <write>:
.global write
write:
 li a7, SYS_write
 2d4:	48c1                	li	a7,16
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <close>:
.global close
close:
 li a7, SYS_close
 2dc:	48d5                	li	a7,21
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e4:	4899                	li	a7,6
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ec:	489d                	li	a7,7
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <open>:
.global open
open:
 li a7, SYS_open
 2f4:	48bd                	li	a7,15
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2fc:	48c5                	li	a7,17
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 304:	48c9                	li	a7,18
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 30c:	48a1                	li	a7,8
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <link>:
.global link
link:
 li a7, SYS_link
 314:	48cd                	li	a7,19
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 31c:	48d1                	li	a7,20
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 324:	48a5                	li	a7,9
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <dup>:
.global dup
dup:
 li a7, SYS_dup
 32c:	48a9                	li	a7,10
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 334:	48ad                	li	a7,11
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 33c:	48b1                	li	a7,12
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <pause>:
.global pause
pause:
 li a7, SYS_pause
 344:	48b5                	li	a7,13
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 34c:	48b9                	li	a7,14
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 354:	48d9                	li	a7,22
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 35c:	48dd                	li	a7,23
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 364:	48e1                	li	a7,24
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 36c:	48e5                	li	a7,25
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 374:	48e9                	li	a7,26
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 37c:	48ed                	li	a7,27
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 384:	48f1                	li	a7,28
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 38c:	48f5                	li	a7,29
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 394:	1101                	addi	sp,sp,-32
 396:	ec06                	sd	ra,24(sp)
 398:	e822                	sd	s0,16(sp)
 39a:	1000                	addi	s0,sp,32
 39c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a0:	4605                	li	a2,1
 3a2:	fef40593          	addi	a1,s0,-17
 3a6:	f2fff0ef          	jal	ra,2d4 <write>
}
 3aa:	60e2                	ld	ra,24(sp)
 3ac:	6442                	ld	s0,16(sp)
 3ae:	6105                	addi	sp,sp,32
 3b0:	8082                	ret

00000000000003b2 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 3b2:	715d                	addi	sp,sp,-80
 3b4:	e486                	sd	ra,72(sp)
 3b6:	e0a2                	sd	s0,64(sp)
 3b8:	fc26                	sd	s1,56(sp)
 3ba:	f84a                	sd	s2,48(sp)
 3bc:	f44e                	sd	s3,40(sp)
 3be:	0880                	addi	s0,sp,80
 3c0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3c2:	c299                	beqz	a3,3c8 <printint+0x16>
 3c4:	0805c163          	bltz	a1,446 <printint+0x94>
  neg = 0;
 3c8:	4881                	li	a7,0
 3ca:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ce:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3d0:	00000517          	auipc	a0,0x0
 3d4:	4e850513          	addi	a0,a0,1256 # 8b8 <digits>
 3d8:	883e                	mv	a6,a5
 3da:	2785                	addiw	a5,a5,1
 3dc:	02c5f733          	remu	a4,a1,a2
 3e0:	972a                	add	a4,a4,a0
 3e2:	00074703          	lbu	a4,0(a4)
 3e6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3ea:	872e                	mv	a4,a1
 3ec:	02c5d5b3          	divu	a1,a1,a2
 3f0:	0685                	addi	a3,a3,1
 3f2:	fec773e3          	bgeu	a4,a2,3d8 <printint+0x26>
  if(neg)
 3f6:	00088b63          	beqz	a7,40c <printint+0x5a>
    buf[i++] = '-';
 3fa:	fd040713          	addi	a4,s0,-48
 3fe:	97ba                	add	a5,a5,a4
 400:	02d00713          	li	a4,45
 404:	fee78423          	sb	a4,-24(a5)
 408:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 40c:	02f05663          	blez	a5,438 <printint+0x86>
 410:	fb840713          	addi	a4,s0,-72
 414:	00f704b3          	add	s1,a4,a5
 418:	fff70993          	addi	s3,a4,-1
 41c:	99be                	add	s3,s3,a5
 41e:	37fd                	addiw	a5,a5,-1
 420:	1782                	slli	a5,a5,0x20
 422:	9381                	srli	a5,a5,0x20
 424:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 428:	fff4c583          	lbu	a1,-1(s1)
 42c:	854a                	mv	a0,s2
 42e:	f67ff0ef          	jal	ra,394 <putc>
  while(--i >= 0)
 432:	14fd                	addi	s1,s1,-1
 434:	ff349ae3          	bne	s1,s3,428 <printint+0x76>
}
 438:	60a6                	ld	ra,72(sp)
 43a:	6406                	ld	s0,64(sp)
 43c:	74e2                	ld	s1,56(sp)
 43e:	7942                	ld	s2,48(sp)
 440:	79a2                	ld	s3,40(sp)
 442:	6161                	addi	sp,sp,80
 444:	8082                	ret
    x = -xx;
 446:	40b005b3          	neg	a1,a1
    neg = 1;
 44a:	4885                	li	a7,1
    x = -xx;
 44c:	bfbd                	j	3ca <printint+0x18>

000000000000044e <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 44e:	7119                	addi	sp,sp,-128
 450:	fc86                	sd	ra,120(sp)
 452:	f8a2                	sd	s0,112(sp)
 454:	f4a6                	sd	s1,104(sp)
 456:	f0ca                	sd	s2,96(sp)
 458:	ecce                	sd	s3,88(sp)
 45a:	e8d2                	sd	s4,80(sp)
 45c:	e4d6                	sd	s5,72(sp)
 45e:	e0da                	sd	s6,64(sp)
 460:	fc5e                	sd	s7,56(sp)
 462:	f862                	sd	s8,48(sp)
 464:	f466                	sd	s9,40(sp)
 466:	f06a                	sd	s10,32(sp)
 468:	ec6e                	sd	s11,24(sp)
 46a:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46c:	0005c903          	lbu	s2,0(a1)
 470:	24090c63          	beqz	s2,6c8 <vprintf+0x27a>
 474:	8b2a                	mv	s6,a0
 476:	8a2e                	mv	s4,a1
 478:	8bb2                	mv	s7,a2
  state = 0;
 47a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 47c:	4481                	li	s1,0
 47e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 480:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 484:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 488:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 48c:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 490:	00000c97          	auipc	s9,0x0
 494:	428c8c93          	addi	s9,s9,1064 # 8b8 <digits>
 498:	a005                	j	4b8 <vprintf+0x6a>
        putc(fd, c0);
 49a:	85ca                	mv	a1,s2
 49c:	855a                	mv	a0,s6
 49e:	ef7ff0ef          	jal	ra,394 <putc>
 4a2:	a019                	j	4a8 <vprintf+0x5a>
    } else if(state == '%'){
 4a4:	03598263          	beq	s3,s5,4c8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4a8:	2485                	addiw	s1,s1,1
 4aa:	8726                	mv	a4,s1
 4ac:	009a07b3          	add	a5,s4,s1
 4b0:	0007c903          	lbu	s2,0(a5)
 4b4:	20090a63          	beqz	s2,6c8 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4b8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4bc:	fe0994e3          	bnez	s3,4a4 <vprintf+0x56>
      if(c0 == '%'){
 4c0:	fd579de3          	bne	a5,s5,49a <vprintf+0x4c>
        state = '%';
 4c4:	89be                	mv	s3,a5
 4c6:	b7cd                	j	4a8 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4c8:	c3c1                	beqz	a5,548 <vprintf+0xfa>
 4ca:	00ea06b3          	add	a3,s4,a4
 4ce:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4d2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4d4:	c681                	beqz	a3,4dc <vprintf+0x8e>
 4d6:	9752                	add	a4,a4,s4
 4d8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4dc:	03878e63          	beq	a5,s8,518 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 4e0:	05a78863          	beq	a5,s10,530 <vprintf+0xe2>
      } else if(c0 == 'u'){
 4e4:	0db78b63          	beq	a5,s11,5ba <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4e8:	07800713          	li	a4,120
 4ec:	10e78d63          	beq	a5,a4,606 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4f0:	07000713          	li	a4,112
 4f4:	14e78263          	beq	a5,a4,638 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4f8:	06300713          	li	a4,99
 4fc:	16e78f63          	beq	a5,a4,67a <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 500:	07300713          	li	a4,115
 504:	18e78563          	beq	a5,a4,68e <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 508:	05579063          	bne	a5,s5,548 <vprintf+0xfa>
        putc(fd, '%');
 50c:	85d6                	mv	a1,s5
 50e:	855a                	mv	a0,s6
 510:	e85ff0ef          	jal	ra,394 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 514:	4981                	li	s3,0
 516:	bf49                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 518:	008b8913          	addi	s2,s7,8
 51c:	4685                	li	a3,1
 51e:	4629                	li	a2,10
 520:	000ba583          	lw	a1,0(s7)
 524:	855a                	mv	a0,s6
 526:	e8dff0ef          	jal	ra,3b2 <printint>
 52a:	8bca                	mv	s7,s2
      state = 0;
 52c:	4981                	li	s3,0
 52e:	bfad                	j	4a8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 530:	03868663          	beq	a3,s8,55c <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 534:	05a68163          	beq	a3,s10,576 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 538:	09b68d63          	beq	a3,s11,5d2 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 53c:	03a68f63          	beq	a3,s10,57a <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 540:	07800793          	li	a5,120
 544:	0cf68d63          	beq	a3,a5,61e <vprintf+0x1d0>
        putc(fd, '%');
 548:	85d6                	mv	a1,s5
 54a:	855a                	mv	a0,s6
 54c:	e49ff0ef          	jal	ra,394 <putc>
        putc(fd, c0);
 550:	85ca                	mv	a1,s2
 552:	855a                	mv	a0,s6
 554:	e41ff0ef          	jal	ra,394 <putc>
      state = 0;
 558:	4981                	li	s3,0
 55a:	b7b9                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 55c:	008b8913          	addi	s2,s7,8
 560:	4685                	li	a3,1
 562:	4629                	li	a2,10
 564:	000bb583          	ld	a1,0(s7)
 568:	855a                	mv	a0,s6
 56a:	e49ff0ef          	jal	ra,3b2 <printint>
        i += 1;
 56e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	8bca                	mv	s7,s2
      state = 0;
 572:	4981                	li	s3,0
        i += 1;
 574:	bf15                	j	4a8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 576:	03860563          	beq	a2,s8,5a0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 57a:	07b60963          	beq	a2,s11,5ec <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 57e:	07800793          	li	a5,120
 582:	fcf613e3          	bne	a2,a5,548 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 586:	008b8913          	addi	s2,s7,8
 58a:	4681                	li	a3,0
 58c:	4641                	li	a2,16
 58e:	000bb583          	ld	a1,0(s7)
 592:	855a                	mv	a0,s6
 594:	e1fff0ef          	jal	ra,3b2 <printint>
        i += 2;
 598:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 59a:	8bca                	mv	s7,s2
      state = 0;
 59c:	4981                	li	s3,0
        i += 2;
 59e:	b729                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a0:	008b8913          	addi	s2,s7,8
 5a4:	4685                	li	a3,1
 5a6:	4629                	li	a2,10
 5a8:	000bb583          	ld	a1,0(s7)
 5ac:	855a                	mv	a0,s6
 5ae:	e05ff0ef          	jal	ra,3b2 <printint>
        i += 2;
 5b2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b4:	8bca                	mv	s7,s2
      state = 0;
 5b6:	4981                	li	s3,0
        i += 2;
 5b8:	bdc5                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5ba:	008b8913          	addi	s2,s7,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000be583          	lwu	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	debff0ef          	jal	ra,3b2 <printint>
 5cc:	8bca                	mv	s7,s2
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	bde1                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4629                	li	a2,10
 5da:	000bb583          	ld	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	dd3ff0ef          	jal	ra,3b2 <printint>
        i += 1;
 5e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e6:	8bca                	mv	s7,s2
      state = 0;
 5e8:	4981                	li	s3,0
        i += 1;
 5ea:	bd7d                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4681                	li	a3,0
 5f2:	4629                	li	a2,10
 5f4:	000bb583          	ld	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	db9ff0ef          	jal	ra,3b2 <printint>
        i += 2;
 5fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
        i += 2;
 604:	b555                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 606:	008b8913          	addi	s2,s7,8
 60a:	4681                	li	a3,0
 60c:	4641                	li	a2,16
 60e:	000be583          	lwu	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	d9fff0ef          	jal	ra,3b2 <printint>
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b571                	j	4a8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61e:	008b8913          	addi	s2,s7,8
 622:	4681                	li	a3,0
 624:	4641                	li	a2,16
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	d87ff0ef          	jal	ra,3b2 <printint>
        i += 1;
 630:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 1;
 636:	bd8d                	j	4a8 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 638:	008b8793          	addi	a5,s7,8
 63c:	f8f43423          	sd	a5,-120(s0)
 640:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 644:	03000593          	li	a1,48
 648:	855a                	mv	a0,s6
 64a:	d4bff0ef          	jal	ra,394 <putc>
  putc(fd, 'x');
 64e:	07800593          	li	a1,120
 652:	855a                	mv	a0,s6
 654:	d41ff0ef          	jal	ra,394 <putc>
 658:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65a:	03c9d793          	srli	a5,s3,0x3c
 65e:	97e6                	add	a5,a5,s9
 660:	0007c583          	lbu	a1,0(a5)
 664:	855a                	mv	a0,s6
 666:	d2fff0ef          	jal	ra,394 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66a:	0992                	slli	s3,s3,0x4
 66c:	397d                	addiw	s2,s2,-1
 66e:	fe0916e3          	bnez	s2,65a <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 672:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 676:	4981                	li	s3,0
 678:	bd05                	j	4a8 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 67a:	008b8913          	addi	s2,s7,8
 67e:	000bc583          	lbu	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	d11ff0ef          	jal	ra,394 <putc>
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bd31                	j	4a8 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 68e:	008b8993          	addi	s3,s7,8
 692:	000bb903          	ld	s2,0(s7)
 696:	00090f63          	beqz	s2,6b4 <vprintf+0x266>
        for(; *s; s++)
 69a:	00094583          	lbu	a1,0(s2)
 69e:	c195                	beqz	a1,6c2 <vprintf+0x274>
          putc(fd, *s);
 6a0:	855a                	mv	a0,s6
 6a2:	cf3ff0ef          	jal	ra,394 <putc>
        for(; *s; s++)
 6a6:	0905                	addi	s2,s2,1
 6a8:	00094583          	lbu	a1,0(s2)
 6ac:	f9f5                	bnez	a1,6a0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6ae:	8bce                	mv	s7,s3
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bbdd                	j	4a8 <vprintf+0x5a>
          s = "(null)";
 6b4:	00000917          	auipc	s2,0x0
 6b8:	1fc90913          	addi	s2,s2,508 # 8b0 <malloc+0xe6>
        for(; *s; s++)
 6bc:	02800593          	li	a1,40
 6c0:	b7c5                	j	6a0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6c2:	8bce                	mv	s7,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b3cd                	j	4a8 <vprintf+0x5a>
    }
  }
}
 6c8:	70e6                	ld	ra,120(sp)
 6ca:	7446                	ld	s0,112(sp)
 6cc:	74a6                	ld	s1,104(sp)
 6ce:	7906                	ld	s2,96(sp)
 6d0:	69e6                	ld	s3,88(sp)
 6d2:	6a46                	ld	s4,80(sp)
 6d4:	6aa6                	ld	s5,72(sp)
 6d6:	6b06                	ld	s6,64(sp)
 6d8:	7be2                	ld	s7,56(sp)
 6da:	7c42                	ld	s8,48(sp)
 6dc:	7ca2                	ld	s9,40(sp)
 6de:	7d02                	ld	s10,32(sp)
 6e0:	6de2                	ld	s11,24(sp)
 6e2:	6109                	addi	sp,sp,128
 6e4:	8082                	ret

00000000000006e6 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 6e6:	715d                	addi	sp,sp,-80
 6e8:	ec06                	sd	ra,24(sp)
 6ea:	e822                	sd	s0,16(sp)
 6ec:	1000                	addi	s0,sp,32
 6ee:	e010                	sd	a2,0(s0)
 6f0:	e414                	sd	a3,8(s0)
 6f2:	e818                	sd	a4,16(s0)
 6f4:	ec1c                	sd	a5,24(s0)
 6f6:	03043023          	sd	a6,32(s0)
 6fa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 702:	8622                	mv	a2,s0
 704:	d4bff0ef          	jal	ra,44e <vprintf>
}
 708:	60e2                	ld	ra,24(sp)
 70a:	6442                	ld	s0,16(sp)
 70c:	6161                	addi	sp,sp,80
 70e:	8082                	ret

0000000000000710 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 710:	711d                	addi	sp,sp,-96
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	1000                	addi	s0,sp,32
 718:	e40c                	sd	a1,8(s0)
 71a:	e810                	sd	a2,16(s0)
 71c:	ec14                	sd	a3,24(s0)
 71e:	f018                	sd	a4,32(s0)
 720:	f41c                	sd	a5,40(s0)
 722:	03043823          	sd	a6,48(s0)
 726:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72a:	00840613          	addi	a2,s0,8
 72e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 732:	85aa                	mv	a1,a0
 734:	4505                	li	a0,1
 736:	d19ff0ef          	jal	ra,44e <vprintf>
}
 73a:	60e2                	ld	ra,24(sp)
 73c:	6442                	ld	s0,16(sp)
 73e:	6125                	addi	sp,sp,96
 740:	8082                	ret

0000000000000742 <free>:
 *   无
 */

void
free(void *ap)
{
 742:	1141                	addi	sp,sp,-16
 744:	e422                	sd	s0,8(sp)
 746:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 748:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74c:	00001797          	auipc	a5,0x1
 750:	8b47b783          	ld	a5,-1868(a5) # 1000 <freep>
 754:	a805                	j	784 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 756:	4618                	lw	a4,8(a2)
 758:	9db9                	addw	a1,a1,a4
 75a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 75e:	6398                	ld	a4,0(a5)
 760:	6318                	ld	a4,0(a4)
 762:	fee53823          	sd	a4,-16(a0)
 766:	a091                	j	7aa <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 768:	ff852703          	lw	a4,-8(a0)
 76c:	9e39                	addw	a2,a2,a4
 76e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 770:	ff053703          	ld	a4,-16(a0)
 774:	e398                	sd	a4,0(a5)
 776:	a099                	j	7bc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 778:	6398                	ld	a4,0(a5)
 77a:	00e7e463          	bltu	a5,a4,782 <free+0x40>
 77e:	00e6ea63          	bltu	a3,a4,792 <free+0x50>
{
 782:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 784:	fed7fae3          	bgeu	a5,a3,778 <free+0x36>
 788:	6398                	ld	a4,0(a5)
 78a:	00e6e463          	bltu	a3,a4,792 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78e:	fee7eae3          	bltu	a5,a4,782 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 792:	ff852583          	lw	a1,-8(a0)
 796:	6390                	ld	a2,0(a5)
 798:	02059713          	slli	a4,a1,0x20
 79c:	9301                	srli	a4,a4,0x20
 79e:	0712                	slli	a4,a4,0x4
 7a0:	9736                	add	a4,a4,a3
 7a2:	fae60ae3          	beq	a2,a4,756 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7a6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7aa:	4790                	lw	a2,8(a5)
 7ac:	02061713          	slli	a4,a2,0x20
 7b0:	9301                	srli	a4,a4,0x20
 7b2:	0712                	slli	a4,a4,0x4
 7b4:	973e                	add	a4,a4,a5
 7b6:	fae689e3          	beq	a3,a4,768 <free+0x26>
  } else
    p->s.ptr = bp;
 7ba:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 7bc:	00001717          	auipc	a4,0x1
 7c0:	84f73223          	sd	a5,-1980(a4) # 1000 <freep>
}
 7c4:	6422                	ld	s0,8(sp)
 7c6:	0141                	addi	sp,sp,16
 7c8:	8082                	ret

00000000000007ca <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 7ca:	7139                	addi	sp,sp,-64
 7cc:	fc06                	sd	ra,56(sp)
 7ce:	f822                	sd	s0,48(sp)
 7d0:	f426                	sd	s1,40(sp)
 7d2:	f04a                	sd	s2,32(sp)
 7d4:	ec4e                	sd	s3,24(sp)
 7d6:	e852                	sd	s4,16(sp)
 7d8:	e456                	sd	s5,8(sp)
 7da:	e05a                	sd	s6,0(sp)
 7dc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7de:	02051493          	slli	s1,a0,0x20
 7e2:	9081                	srli	s1,s1,0x20
 7e4:	04bd                	addi	s1,s1,15
 7e6:	8091                	srli	s1,s1,0x4
 7e8:	0014899b          	addiw	s3,s1,1
 7ec:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 7ee:	00001517          	auipc	a0,0x1
 7f2:	81253503          	ld	a0,-2030(a0) # 1000 <freep>
 7f6:	c515                	beqz	a0,822 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 7fa:	4798                	lw	a4,8(a5)
 7fc:	02977f63          	bgeu	a4,s1,83a <malloc+0x70>
 800:	8a4e                	mv	s4,s3
 802:	0009871b          	sext.w	a4,s3
 806:	6685                	lui	a3,0x1
 808:	00d77363          	bgeu	a4,a3,80e <malloc+0x44>
 80c:	6a05                	lui	s4,0x1
 80e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 812:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 816:	00000917          	auipc	s2,0x0
 81a:	7ea90913          	addi	s2,s2,2026 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 81e:	5afd                	li	s5,-1
 820:	a0bd                	j	88e <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 822:	00000797          	auipc	a5,0x0
 826:	7ee78793          	addi	a5,a5,2030 # 1010 <base>
 82a:	00000717          	auipc	a4,0x0
 82e:	7cf73b23          	sd	a5,2006(a4) # 1000 <freep>
 832:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 834:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 838:	b7e1                	j	800 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 83a:	02e48b63          	beq	s1,a4,870 <malloc+0xa6>
        p->s.size -= nunits;
 83e:	4137073b          	subw	a4,a4,s3
 842:	c798                	sw	a4,8(a5)
        p += p->s.size;
 844:	1702                	slli	a4,a4,0x20
 846:	9301                	srli	a4,a4,0x20
 848:	0712                	slli	a4,a4,0x4
 84a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84c:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 850:	00000717          	auipc	a4,0x0
 854:	7aa73823          	sd	a0,1968(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 858:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 85c:	70e2                	ld	ra,56(sp)
 85e:	7442                	ld	s0,48(sp)
 860:	74a2                	ld	s1,40(sp)
 862:	7902                	ld	s2,32(sp)
 864:	69e2                	ld	s3,24(sp)
 866:	6a42                	ld	s4,16(sp)
 868:	6aa2                	ld	s5,8(sp)
 86a:	6b02                	ld	s6,0(sp)
 86c:	6121                	addi	sp,sp,64
 86e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 870:	6398                	ld	a4,0(a5)
 872:	e118                	sd	a4,0(a0)
 874:	bff1                	j	850 <malloc+0x86>
  hp->s.size = nu;
 876:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 87a:	0541                	addi	a0,a0,16
 87c:	ec7ff0ef          	jal	ra,742 <free>
  return freep;
 880:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 884:	dd61                	beqz	a0,85c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 886:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 888:	4798                	lw	a4,8(a5)
 88a:	fa9778e3          	bgeu	a4,s1,83a <malloc+0x70>
    if(p == freep)
 88e:	00093703          	ld	a4,0(s2)
 892:	853e                	mv	a0,a5
 894:	fef719e3          	bne	a4,a5,886 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 898:	8552                	mv	a0,s4
 89a:	9e7ff0ef          	jal	ra,280 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 89e:	fd551ce3          	bne	a0,s5,876 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 8a2:	4501                	li	a0,0
 8a4:	bf65                	j	85c <malloc+0x92>
