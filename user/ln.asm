
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	00f50c63          	beq	a0,a5,24 <main+0x24>
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	8d058593          	addi	a1,a1,-1840 # 8e0 <malloc+0xe8>
  18:	4509                	li	a0,2
  1a:	6fa000ef          	jal	ra,714 <fprintf>
    exit(1);
  1e:	4505                	li	a0,1
  20:	2c2000ef          	jal	ra,2e2 <exit>
  24:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  26:	698c                	ld	a1,16(a1)
  28:	6488                	ld	a0,8(s1)
  2a:	318000ef          	jal	ra,342 <link>
  2e:	00054563          	bltz	a0,38 <main+0x38>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  32:	4501                	li	a0,0
  34:	2ae000ef          	jal	ra,2e2 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  38:	6894                	ld	a3,16(s1)
  3a:	6490                	ld	a2,8(s1)
  3c:	00001597          	auipc	a1,0x1
  40:	8bc58593          	addi	a1,a1,-1860 # 8f8 <malloc+0x100>
  44:	4509                	li	a0,2
  46:	6ce000ef          	jal	ra,714 <fprintf>
  4a:	b7e5                	j	32 <main+0x32>

000000000000004c <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  4c:	1141                	addi	sp,sp,-16
  4e:	e406                	sd	ra,8(sp)
  50:	e022                	sd	s0,0(sp)
  52:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  54:	fadff0ef          	jal	ra,0 <main>
  exit(r);
  58:	28a000ef          	jal	ra,2e2 <exit>

000000000000005c <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e422                	sd	s0,8(sp)
  60:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  62:	87aa                	mv	a5,a0
  64:	0585                	addi	a1,a1,1
  66:	0785                	addi	a5,a5,1
  68:	fff5c703          	lbu	a4,-1(a1)
  6c:	fee78fa3          	sb	a4,-1(a5)
  70:	fb75                	bnez	a4,64 <strcpy+0x8>
    ;
  return os;
}
  72:	6422                	ld	s0,8(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7e:	00054783          	lbu	a5,0(a0)
  82:	cb91                	beqz	a5,96 <strcmp+0x1e>
  84:	0005c703          	lbu	a4,0(a1)
  88:	00f71763          	bne	a4,a5,96 <strcmp+0x1e>
    p++, q++;
  8c:	0505                	addi	a0,a0,1
  8e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  90:	00054783          	lbu	a5,0(a0)
  94:	fbe5                	bnez	a5,84 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  96:	0005c503          	lbu	a0,0(a1)
}
  9a:	40a7853b          	subw	a0,a5,a0
  9e:	6422                	ld	s0,8(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret

00000000000000a4 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cf91                	beqz	a5,ca <strlen+0x26>
  b0:	0505                	addi	a0,a0,1
  b2:	87aa                	mv	a5,a0
  b4:	4685                	li	a3,1
  b6:	9e89                	subw	a3,a3,a0
  b8:	00f6853b          	addw	a0,a3,a5
  bc:	0785                	addi	a5,a5,1
  be:	fff7c703          	lbu	a4,-1(a5)
  c2:	fb7d                	bnez	a4,b8 <strlen+0x14>
    ;
  return n;
}
  c4:	6422                	ld	s0,8(sp)
  c6:	0141                	addi	sp,sp,16
  c8:	8082                	ret
  for(n = 0; s[n]; n++)
  ca:	4501                	li	a0,0
  cc:	bfe5                	j	c4 <strlen+0x20>

00000000000000ce <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d4:	ca19                	beqz	a2,ea <memset+0x1c>
  d6:	87aa                	mv	a5,a0
  d8:	1602                	slli	a2,a2,0x20
  da:	9201                	srli	a2,a2,0x20
  dc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e4:	0785                	addi	a5,a5,1
  e6:	fee79de3          	bne	a5,a4,e0 <memset+0x12>
  }
  return dst;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb99                	beqz	a5,110 <strchr+0x20>
    if(*s == c)
  fc:	00f58763          	beq	a1,a5,10a <strchr+0x1a>
  for(; *s; s++)
 100:	0505                	addi	a0,a0,1
 102:	00054783          	lbu	a5,0(a0)
 106:	fbfd                	bnez	a5,fc <strchr+0xc>
      return (char*)s;
  return 0;
 108:	4501                	li	a0,0
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret
  return 0;
 110:	4501                	li	a0,0
 112:	bfe5                	j	10a <strchr+0x1a>

0000000000000114 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 114:	711d                	addi	sp,sp,-96
 116:	ec86                	sd	ra,88(sp)
 118:	e8a2                	sd	s0,80(sp)
 11a:	e4a6                	sd	s1,72(sp)
 11c:	e0ca                	sd	s2,64(sp)
 11e:	fc4e                	sd	s3,56(sp)
 120:	f852                	sd	s4,48(sp)
 122:	f456                	sd	s5,40(sp)
 124:	f05a                	sd	s6,32(sp)
 126:	ec5e                	sd	s7,24(sp)
 128:	1080                	addi	s0,sp,96
 12a:	8baa                	mv	s7,a0
 12c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12e:	892a                	mv	s2,a0
 130:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 132:	4aa9                	li	s5,10
 134:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 136:	89a6                	mv	s3,s1
 138:	2485                	addiw	s1,s1,1
 13a:	0344d663          	bge	s1,s4,166 <gets+0x52>
    cc = read(0, &c, 1);
 13e:	4605                	li	a2,1
 140:	faf40593          	addi	a1,s0,-81
 144:	4501                	li	a0,0
 146:	1b4000ef          	jal	ra,2fa <read>
    if(cc < 1)
 14a:	00a05e63          	blez	a0,166 <gets+0x52>
    buf[i++] = c;
 14e:	faf44783          	lbu	a5,-81(s0)
 152:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 156:	01578763          	beq	a5,s5,164 <gets+0x50>
 15a:	0905                	addi	s2,s2,1
 15c:	fd679de3          	bne	a5,s6,136 <gets+0x22>
  for(i=0; i+1 < max; ){
 160:	89a6                	mv	s3,s1
 162:	a011                	j	166 <gets+0x52>
 164:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 166:	99de                	add	s3,s3,s7
 168:	00098023          	sb	zero,0(s3)
  return buf;
}
 16c:	855e                	mv	a0,s7
 16e:	60e6                	ld	ra,88(sp)
 170:	6446                	ld	s0,80(sp)
 172:	64a6                	ld	s1,72(sp)
 174:	6906                	ld	s2,64(sp)
 176:	79e2                	ld	s3,56(sp)
 178:	7a42                	ld	s4,48(sp)
 17a:	7aa2                	ld	s5,40(sp)
 17c:	7b02                	ld	s6,32(sp)
 17e:	6be2                	ld	s7,24(sp)
 180:	6125                	addi	sp,sp,96
 182:	8082                	ret

0000000000000184 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 184:	1101                	addi	sp,sp,-32
 186:	ec06                	sd	ra,24(sp)
 188:	e822                	sd	s0,16(sp)
 18a:	e426                	sd	s1,8(sp)
 18c:	e04a                	sd	s2,0(sp)
 18e:	1000                	addi	s0,sp,32
 190:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 192:	4581                	li	a1,0
 194:	18e000ef          	jal	ra,322 <open>
  if(fd < 0)
 198:	02054163          	bltz	a0,1ba <stat+0x36>
 19c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 19e:	85ca                	mv	a1,s2
 1a0:	19a000ef          	jal	ra,33a <fstat>
 1a4:	892a                	mv	s2,a0
  close(fd);
 1a6:	8526                	mv	a0,s1
 1a8:	162000ef          	jal	ra,30a <close>
  return r;
}
 1ac:	854a                	mv	a0,s2
 1ae:	60e2                	ld	ra,24(sp)
 1b0:	6442                	ld	s0,16(sp)
 1b2:	64a2                	ld	s1,8(sp)
 1b4:	6902                	ld	s2,0(sp)
 1b6:	6105                	addi	sp,sp,32
 1b8:	8082                	ret
    return -1;
 1ba:	597d                	li	s2,-1
 1bc:	bfc5                	j	1ac <stat+0x28>

00000000000001be <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c4:	00054603          	lbu	a2,0(a0)
 1c8:	fd06079b          	addiw	a5,a2,-48
 1cc:	0ff7f793          	andi	a5,a5,255
 1d0:	4725                	li	a4,9
 1d2:	02f76963          	bltu	a4,a5,204 <atoi+0x46>
 1d6:	86aa                	mv	a3,a0
  n = 0;
 1d8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1da:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1dc:	0685                	addi	a3,a3,1
 1de:	0025179b          	slliw	a5,a0,0x2
 1e2:	9fa9                	addw	a5,a5,a0
 1e4:	0017979b          	slliw	a5,a5,0x1
 1e8:	9fb1                	addw	a5,a5,a2
 1ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ee:	0006c603          	lbu	a2,0(a3)
 1f2:	fd06071b          	addiw	a4,a2,-48
 1f6:	0ff77713          	andi	a4,a4,255
 1fa:	fee5f1e3          	bgeu	a1,a4,1dc <atoi+0x1e>
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  n = 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <atoi+0x40>

0000000000000208 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20e:	02b57463          	bgeu	a0,a1,236 <memmove+0x2e>
    while(n-- > 0)
 212:	00c05f63          	blez	a2,230 <memmove+0x28>
 216:	1602                	slli	a2,a2,0x20
 218:	9201                	srli	a2,a2,0x20
 21a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 21e:	872a                	mv	a4,a0
      *dst++ = *src++;
 220:	0585                	addi	a1,a1,1
 222:	0705                	addi	a4,a4,1
 224:	fff5c683          	lbu	a3,-1(a1)
 228:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22c:	fee79ae3          	bne	a5,a4,220 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
    dst += n;
 236:	00c50733          	add	a4,a0,a2
    src += n;
 23a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 23c:	fec05ae3          	blez	a2,230 <memmove+0x28>
 240:	fff6079b          	addiw	a5,a2,-1
 244:	1782                	slli	a5,a5,0x20
 246:	9381                	srli	a5,a5,0x20
 248:	fff7c793          	not	a5,a5
 24c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24e:	15fd                	addi	a1,a1,-1
 250:	177d                	addi	a4,a4,-1
 252:	0005c683          	lbu	a3,0(a1)
 256:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25a:	fee79ae3          	bne	a5,a4,24e <memmove+0x46>
 25e:	bfc9                	j	230 <memmove+0x28>

0000000000000260 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 266:	ca05                	beqz	a2,296 <memcmp+0x36>
 268:	fff6069b          	addiw	a3,a2,-1
 26c:	1682                	slli	a3,a3,0x20
 26e:	9281                	srli	a3,a3,0x20
 270:	0685                	addi	a3,a3,1
 272:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 274:	00054783          	lbu	a5,0(a0)
 278:	0005c703          	lbu	a4,0(a1)
 27c:	00e79863          	bne	a5,a4,28c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 280:	0505                	addi	a0,a0,1
    p2++;
 282:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 284:	fed518e3          	bne	a0,a3,274 <memcmp+0x14>
  }
  return 0;
 288:	4501                	li	a0,0
 28a:	a019                	j	290 <memcmp+0x30>
      return *p1 - *p2;
 28c:	40e7853b          	subw	a0,a5,a4
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  return 0;
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <memcmp+0x30>

000000000000029a <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e406                	sd	ra,8(sp)
 29e:	e022                	sd	s0,0(sp)
 2a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a2:	f67ff0ef          	jal	ra,208 <memmove>
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2b6:	4585                	li	a1,1
 2b8:	0b2000ef          	jal	ra,36a <sys_sbrk>
}
 2bc:	60a2                	ld	ra,8(sp)
 2be:	6402                	ld	s0,0(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2cc:	4589                	li	a1,2
 2ce:	09c000ef          	jal	ra,36a <sys_sbrk>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2da:	4885                	li	a7,1
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e2:	4889                	li	a7,2
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ea:	488d                	li	a7,3
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f2:	4891                	li	a7,4
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <read>:
.global read
read:
 li a7, SYS_read
 2fa:	4895                	li	a7,5
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <write>:
.global write
write:
 li a7, SYS_write
 302:	48c1                	li	a7,16
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <close>:
.global close
close:
 li a7, SYS_close
 30a:	48d5                	li	a7,21
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <kill>:
.global kill
kill:
 li a7, SYS_kill
 312:	4899                	li	a7,6
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exec>:
.global exec
exec:
 li a7, SYS_exec
 31a:	489d                	li	a7,7
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <open>:
.global open
open:
 li a7, SYS_open
 322:	48bd                	li	a7,15
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32a:	48c5                	li	a7,17
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 332:	48c9                	li	a7,18
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33a:	48a1                	li	a7,8
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <link>:
.global link
link:
 li a7, SYS_link
 342:	48cd                	li	a7,19
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34a:	48d1                	li	a7,20
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 352:	48a5                	li	a7,9
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <dup>:
.global dup
dup:
 li a7, SYS_dup
 35a:	48a9                	li	a7,10
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 362:	48ad                	li	a7,11
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 36a:	48b1                	li	a7,12
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <pause>:
.global pause
pause:
 li a7, SYS_pause
 372:	48b5                	li	a7,13
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37a:	48b9                	li	a7,14
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 382:	48d9                	li	a7,22
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 38a:	48dd                	li	a7,23
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 392:	48e1                	li	a7,24
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 39a:	48e5                	li	a7,25
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 3a2:	48e9                	li	a7,26
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3aa:	48ed                	li	a7,27
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3b2:	48f1                	li	a7,28
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3ba:	48f5                	li	a7,29
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 3c2:	1101                	addi	sp,sp,-32
 3c4:	ec06                	sd	ra,24(sp)
 3c6:	e822                	sd	s0,16(sp)
 3c8:	1000                	addi	s0,sp,32
 3ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ce:	4605                	li	a2,1
 3d0:	fef40593          	addi	a1,s0,-17
 3d4:	f2fff0ef          	jal	ra,302 <write>
}
 3d8:	60e2                	ld	ra,24(sp)
 3da:	6442                	ld	s0,16(sp)
 3dc:	6105                	addi	sp,sp,32
 3de:	8082                	ret

00000000000003e0 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 3e0:	715d                	addi	sp,sp,-80
 3e2:	e486                	sd	ra,72(sp)
 3e4:	e0a2                	sd	s0,64(sp)
 3e6:	fc26                	sd	s1,56(sp)
 3e8:	f84a                	sd	s2,48(sp)
 3ea:	f44e                	sd	s3,40(sp)
 3ec:	0880                	addi	s0,sp,80
 3ee:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3f0:	c299                	beqz	a3,3f6 <printint+0x16>
 3f2:	0805c163          	bltz	a1,474 <printint+0x94>
  neg = 0;
 3f6:	4881                	li	a7,0
 3f8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3fc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3fe:	00000517          	auipc	a0,0x0
 402:	51a50513          	addi	a0,a0,1306 # 918 <digits>
 406:	883e                	mv	a6,a5
 408:	2785                	addiw	a5,a5,1
 40a:	02c5f733          	remu	a4,a1,a2
 40e:	972a                	add	a4,a4,a0
 410:	00074703          	lbu	a4,0(a4)
 414:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 418:	872e                	mv	a4,a1
 41a:	02c5d5b3          	divu	a1,a1,a2
 41e:	0685                	addi	a3,a3,1
 420:	fec773e3          	bgeu	a4,a2,406 <printint+0x26>
  if(neg)
 424:	00088b63          	beqz	a7,43a <printint+0x5a>
    buf[i++] = '-';
 428:	fd040713          	addi	a4,s0,-48
 42c:	97ba                	add	a5,a5,a4
 42e:	02d00713          	li	a4,45
 432:	fee78423          	sb	a4,-24(a5)
 436:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 43a:	02f05663          	blez	a5,466 <printint+0x86>
 43e:	fb840713          	addi	a4,s0,-72
 442:	00f704b3          	add	s1,a4,a5
 446:	fff70993          	addi	s3,a4,-1
 44a:	99be                	add	s3,s3,a5
 44c:	37fd                	addiw	a5,a5,-1
 44e:	1782                	slli	a5,a5,0x20
 450:	9381                	srli	a5,a5,0x20
 452:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 456:	fff4c583          	lbu	a1,-1(s1)
 45a:	854a                	mv	a0,s2
 45c:	f67ff0ef          	jal	ra,3c2 <putc>
  while(--i >= 0)
 460:	14fd                	addi	s1,s1,-1
 462:	ff349ae3          	bne	s1,s3,456 <printint+0x76>
}
 466:	60a6                	ld	ra,72(sp)
 468:	6406                	ld	s0,64(sp)
 46a:	74e2                	ld	s1,56(sp)
 46c:	7942                	ld	s2,48(sp)
 46e:	79a2                	ld	s3,40(sp)
 470:	6161                	addi	sp,sp,80
 472:	8082                	ret
    x = -xx;
 474:	40b005b3          	neg	a1,a1
    neg = 1;
 478:	4885                	li	a7,1
    x = -xx;
 47a:	bfbd                	j	3f8 <printint+0x18>

000000000000047c <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 47c:	7119                	addi	sp,sp,-128
 47e:	fc86                	sd	ra,120(sp)
 480:	f8a2                	sd	s0,112(sp)
 482:	f4a6                	sd	s1,104(sp)
 484:	f0ca                	sd	s2,96(sp)
 486:	ecce                	sd	s3,88(sp)
 488:	e8d2                	sd	s4,80(sp)
 48a:	e4d6                	sd	s5,72(sp)
 48c:	e0da                	sd	s6,64(sp)
 48e:	fc5e                	sd	s7,56(sp)
 490:	f862                	sd	s8,48(sp)
 492:	f466                	sd	s9,40(sp)
 494:	f06a                	sd	s10,32(sp)
 496:	ec6e                	sd	s11,24(sp)
 498:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49a:	0005c903          	lbu	s2,0(a1)
 49e:	24090c63          	beqz	s2,6f6 <vprintf+0x27a>
 4a2:	8b2a                	mv	s6,a0
 4a4:	8a2e                	mv	s4,a1
 4a6:	8bb2                	mv	s7,a2
  state = 0;
 4a8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4aa:	4481                	li	s1,0
 4ac:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4ae:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4b2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4b6:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4ba:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4be:	00000c97          	auipc	s9,0x0
 4c2:	45ac8c93          	addi	s9,s9,1114 # 918 <digits>
 4c6:	a005                	j	4e6 <vprintf+0x6a>
        putc(fd, c0);
 4c8:	85ca                	mv	a1,s2
 4ca:	855a                	mv	a0,s6
 4cc:	ef7ff0ef          	jal	ra,3c2 <putc>
 4d0:	a019                	j	4d6 <vprintf+0x5a>
    } else if(state == '%'){
 4d2:	03598263          	beq	s3,s5,4f6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d6:	2485                	addiw	s1,s1,1
 4d8:	8726                	mv	a4,s1
 4da:	009a07b3          	add	a5,s4,s1
 4de:	0007c903          	lbu	s2,0(a5)
 4e2:	20090a63          	beqz	s2,6f6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4e6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ea:	fe0994e3          	bnez	s3,4d2 <vprintf+0x56>
      if(c0 == '%'){
 4ee:	fd579de3          	bne	a5,s5,4c8 <vprintf+0x4c>
        state = '%';
 4f2:	89be                	mv	s3,a5
 4f4:	b7cd                	j	4d6 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4f6:	c3c1                	beqz	a5,576 <vprintf+0xfa>
 4f8:	00ea06b3          	add	a3,s4,a4
 4fc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 500:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 502:	c681                	beqz	a3,50a <vprintf+0x8e>
 504:	9752                	add	a4,a4,s4
 506:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 50a:	03878e63          	beq	a5,s8,546 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 50e:	05a78863          	beq	a5,s10,55e <vprintf+0xe2>
      } else if(c0 == 'u'){
 512:	0db78b63          	beq	a5,s11,5e8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 516:	07800713          	li	a4,120
 51a:	10e78d63          	beq	a5,a4,634 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 51e:	07000713          	li	a4,112
 522:	14e78263          	beq	a5,a4,666 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 526:	06300713          	li	a4,99
 52a:	16e78f63          	beq	a5,a4,6a8 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 52e:	07300713          	li	a4,115
 532:	18e78563          	beq	a5,a4,6bc <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 536:	05579063          	bne	a5,s5,576 <vprintf+0xfa>
        putc(fd, '%');
 53a:	85d6                	mv	a1,s5
 53c:	855a                	mv	a0,s6
 53e:	e85ff0ef          	jal	ra,3c2 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 542:	4981                	li	s3,0
 544:	bf49                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 546:	008b8913          	addi	s2,s7,8
 54a:	4685                	li	a3,1
 54c:	4629                	li	a2,10
 54e:	000ba583          	lw	a1,0(s7)
 552:	855a                	mv	a0,s6
 554:	e8dff0ef          	jal	ra,3e0 <printint>
 558:	8bca                	mv	s7,s2
      state = 0;
 55a:	4981                	li	s3,0
 55c:	bfad                	j	4d6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 55e:	03868663          	beq	a3,s8,58a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 562:	05a68163          	beq	a3,s10,5a4 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 566:	09b68d63          	beq	a3,s11,600 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 56a:	03a68f63          	beq	a3,s10,5a8 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 56e:	07800793          	li	a5,120
 572:	0cf68d63          	beq	a3,a5,64c <vprintf+0x1d0>
        putc(fd, '%');
 576:	85d6                	mv	a1,s5
 578:	855a                	mv	a0,s6
 57a:	e49ff0ef          	jal	ra,3c2 <putc>
        putc(fd, c0);
 57e:	85ca                	mv	a1,s2
 580:	855a                	mv	a0,s6
 582:	e41ff0ef          	jal	ra,3c2 <putc>
      state = 0;
 586:	4981                	li	s3,0
 588:	b7b9                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 58a:	008b8913          	addi	s2,s7,8
 58e:	4685                	li	a3,1
 590:	4629                	li	a2,10
 592:	000bb583          	ld	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	e49ff0ef          	jal	ra,3e0 <printint>
        i += 1;
 59c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 59e:	8bca                	mv	s7,s2
      state = 0;
 5a0:	4981                	li	s3,0
        i += 1;
 5a2:	bf15                	j	4d6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a4:	03860563          	beq	a2,s8,5ce <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a8:	07b60963          	beq	a2,s11,61a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5ac:	07800793          	li	a5,120
 5b0:	fcf613e3          	bne	a2,a5,576 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4681                	li	a3,0
 5ba:	4641                	li	a2,16
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e1fff0ef          	jal	ra,3e0 <printint>
        i += 2;
 5c6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
        i += 2;
 5cc:	b729                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4685                	li	a3,1
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e05ff0ef          	jal	ra,3e0 <printint>
        i += 2;
 5e0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 2;
 5e6:	bdc5                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5e8:	008b8913          	addi	s2,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4629                	li	a2,10
 5f0:	000be583          	lwu	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	debff0ef          	jal	ra,3e0 <printint>
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	bde1                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	008b8913          	addi	s2,s7,8
 604:	4681                	li	a3,0
 606:	4629                	li	a2,10
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	dd3ff0ef          	jal	ra,3e0 <printint>
        i += 1;
 612:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
        i += 1;
 618:	bd7d                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	db9ff0ef          	jal	ra,3e0 <printint>
        i += 2;
 62c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 2;
 632:	b555                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 634:	008b8913          	addi	s2,s7,8
 638:	4681                	li	a3,0
 63a:	4641                	li	a2,16
 63c:	000be583          	lwu	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	d9fff0ef          	jal	ra,3e0 <printint>
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	b571                	j	4d6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4641                	li	a2,16
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	d87ff0ef          	jal	ra,3e0 <printint>
        i += 1;
 65e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
        i += 1;
 664:	bd8d                	j	4d6 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 666:	008b8793          	addi	a5,s7,8
 66a:	f8f43423          	sd	a5,-120(s0)
 66e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 672:	03000593          	li	a1,48
 676:	855a                	mv	a0,s6
 678:	d4bff0ef          	jal	ra,3c2 <putc>
  putc(fd, 'x');
 67c:	07800593          	li	a1,120
 680:	855a                	mv	a0,s6
 682:	d41ff0ef          	jal	ra,3c2 <putc>
 686:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 688:	03c9d793          	srli	a5,s3,0x3c
 68c:	97e6                	add	a5,a5,s9
 68e:	0007c583          	lbu	a1,0(a5)
 692:	855a                	mv	a0,s6
 694:	d2fff0ef          	jal	ra,3c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 698:	0992                	slli	s3,s3,0x4
 69a:	397d                	addiw	s2,s2,-1
 69c:	fe0916e3          	bnez	s2,688 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6a0:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bd05                	j	4d6 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	000bc583          	lbu	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	d11ff0ef          	jal	ra,3c2 <putc>
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bd31                	j	4d6 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6bc:	008b8993          	addi	s3,s7,8
 6c0:	000bb903          	ld	s2,0(s7)
 6c4:	00090f63          	beqz	s2,6e2 <vprintf+0x266>
        for(; *s; s++)
 6c8:	00094583          	lbu	a1,0(s2)
 6cc:	c195                	beqz	a1,6f0 <vprintf+0x274>
          putc(fd, *s);
 6ce:	855a                	mv	a0,s6
 6d0:	cf3ff0ef          	jal	ra,3c2 <putc>
        for(; *s; s++)
 6d4:	0905                	addi	s2,s2,1
 6d6:	00094583          	lbu	a1,0(s2)
 6da:	f9f5                	bnez	a1,6ce <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6dc:	8bce                	mv	s7,s3
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bbdd                	j	4d6 <vprintf+0x5a>
          s = "(null)";
 6e2:	00000917          	auipc	s2,0x0
 6e6:	22e90913          	addi	s2,s2,558 # 910 <malloc+0x118>
        for(; *s; s++)
 6ea:	02800593          	li	a1,40
 6ee:	b7c5                	j	6ce <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6f0:	8bce                	mv	s7,s3
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b3cd                	j	4d6 <vprintf+0x5a>
    }
  }
}
 6f6:	70e6                	ld	ra,120(sp)
 6f8:	7446                	ld	s0,112(sp)
 6fa:	74a6                	ld	s1,104(sp)
 6fc:	7906                	ld	s2,96(sp)
 6fe:	69e6                	ld	s3,88(sp)
 700:	6a46                	ld	s4,80(sp)
 702:	6aa6                	ld	s5,72(sp)
 704:	6b06                	ld	s6,64(sp)
 706:	7be2                	ld	s7,56(sp)
 708:	7c42                	ld	s8,48(sp)
 70a:	7ca2                	ld	s9,40(sp)
 70c:	7d02                	ld	s10,32(sp)
 70e:	6de2                	ld	s11,24(sp)
 710:	6109                	addi	sp,sp,128
 712:	8082                	ret

0000000000000714 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 714:	715d                	addi	sp,sp,-80
 716:	ec06                	sd	ra,24(sp)
 718:	e822                	sd	s0,16(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	e010                	sd	a2,0(s0)
 71e:	e414                	sd	a3,8(s0)
 720:	e818                	sd	a4,16(s0)
 722:	ec1c                	sd	a5,24(s0)
 724:	03043023          	sd	a6,32(s0)
 728:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 730:	8622                	mv	a2,s0
 732:	d4bff0ef          	jal	ra,47c <vprintf>
}
 736:	60e2                	ld	ra,24(sp)
 738:	6442                	ld	s0,16(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret

000000000000073e <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 73e:	711d                	addi	sp,sp,-96
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e40c                	sd	a1,8(s0)
 748:	e810                	sd	a2,16(s0)
 74a:	ec14                	sd	a3,24(s0)
 74c:	f018                	sd	a4,32(s0)
 74e:	f41c                	sd	a5,40(s0)
 750:	03043823          	sd	a6,48(s0)
 754:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	00840613          	addi	a2,s0,8
 75c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 760:	85aa                	mv	a1,a0
 762:	4505                	li	a0,1
 764:	d19ff0ef          	jal	ra,47c <vprintf>
}
 768:	60e2                	ld	ra,24(sp)
 76a:	6442                	ld	s0,16(sp)
 76c:	6125                	addi	sp,sp,96
 76e:	8082                	ret

0000000000000770 <free>:
 *   无
 */

void
free(void *ap)
{
 770:	1141                	addi	sp,sp,-16
 772:	e422                	sd	s0,8(sp)
 774:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 776:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77a:	00001797          	auipc	a5,0x1
 77e:	8867b783          	ld	a5,-1914(a5) # 1000 <freep>
 782:	a805                	j	7b2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 784:	4618                	lw	a4,8(a2)
 786:	9db9                	addw	a1,a1,a4
 788:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78c:	6398                	ld	a4,0(a5)
 78e:	6318                	ld	a4,0(a4)
 790:	fee53823          	sd	a4,-16(a0)
 794:	a091                	j	7d8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 796:	ff852703          	lw	a4,-8(a0)
 79a:	9e39                	addw	a2,a2,a4
 79c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 79e:	ff053703          	ld	a4,-16(a0)
 7a2:	e398                	sd	a4,0(a5)
 7a4:	a099                	j	7ea <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	6398                	ld	a4,0(a5)
 7a8:	00e7e463          	bltu	a5,a4,7b0 <free+0x40>
 7ac:	00e6ea63          	bltu	a3,a4,7c0 <free+0x50>
{
 7b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b2:	fed7fae3          	bgeu	a5,a3,7a6 <free+0x36>
 7b6:	6398                	ld	a4,0(a5)
 7b8:	00e6e463          	bltu	a3,a4,7c0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bc:	fee7eae3          	bltu	a5,a4,7b0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7c0:	ff852583          	lw	a1,-8(a0)
 7c4:	6390                	ld	a2,0(a5)
 7c6:	02059713          	slli	a4,a1,0x20
 7ca:	9301                	srli	a4,a4,0x20
 7cc:	0712                	slli	a4,a4,0x4
 7ce:	9736                	add	a4,a4,a3
 7d0:	fae60ae3          	beq	a2,a4,784 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7d4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d8:	4790                	lw	a2,8(a5)
 7da:	02061713          	slli	a4,a2,0x20
 7de:	9301                	srli	a4,a4,0x20
 7e0:	0712                	slli	a4,a4,0x4
 7e2:	973e                	add	a4,a4,a5
 7e4:	fae689e3          	beq	a3,a4,796 <free+0x26>
  } else
    p->s.ptr = bp;
 7e8:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 7ea:	00001717          	auipc	a4,0x1
 7ee:	80f73b23          	sd	a5,-2026(a4) # 1000 <freep>
}
 7f2:	6422                	ld	s0,8(sp)
 7f4:	0141                	addi	sp,sp,16
 7f6:	8082                	ret

00000000000007f8 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 7f8:	7139                	addi	sp,sp,-64
 7fa:	fc06                	sd	ra,56(sp)
 7fc:	f822                	sd	s0,48(sp)
 7fe:	f426                	sd	s1,40(sp)
 800:	f04a                	sd	s2,32(sp)
 802:	ec4e                	sd	s3,24(sp)
 804:	e852                	sd	s4,16(sp)
 806:	e456                	sd	s5,8(sp)
 808:	e05a                	sd	s6,0(sp)
 80a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80c:	02051493          	slli	s1,a0,0x20
 810:	9081                	srli	s1,s1,0x20
 812:	04bd                	addi	s1,s1,15
 814:	8091                	srli	s1,s1,0x4
 816:	0014899b          	addiw	s3,s1,1
 81a:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 81c:	00000517          	auipc	a0,0x0
 820:	7e453503          	ld	a0,2020(a0) # 1000 <freep>
 824:	c515                	beqz	a0,850 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 826:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 828:	4798                	lw	a4,8(a5)
 82a:	02977f63          	bgeu	a4,s1,868 <malloc+0x70>
 82e:	8a4e                	mv	s4,s3
 830:	0009871b          	sext.w	a4,s3
 834:	6685                	lui	a3,0x1
 836:	00d77363          	bgeu	a4,a3,83c <malloc+0x44>
 83a:	6a05                	lui	s4,0x1
 83c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 840:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 844:	00000917          	auipc	s2,0x0
 848:	7bc90913          	addi	s2,s2,1980 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 84c:	5afd                	li	s5,-1
 84e:	a0bd                	j	8bc <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 850:	00000797          	auipc	a5,0x0
 854:	7c078793          	addi	a5,a5,1984 # 1010 <base>
 858:	00000717          	auipc	a4,0x0
 85c:	7af73423          	sd	a5,1960(a4) # 1000 <freep>
 860:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 862:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 866:	b7e1                	j	82e <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 868:	02e48b63          	beq	s1,a4,89e <malloc+0xa6>
        p->s.size -= nunits;
 86c:	4137073b          	subw	a4,a4,s3
 870:	c798                	sw	a4,8(a5)
        p += p->s.size;
 872:	1702                	slli	a4,a4,0x20
 874:	9301                	srli	a4,a4,0x20
 876:	0712                	slli	a4,a4,0x4
 878:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87a:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 87e:	00000717          	auipc	a4,0x0
 882:	78a73123          	sd	a0,1922(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 886:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 88a:	70e2                	ld	ra,56(sp)
 88c:	7442                	ld	s0,48(sp)
 88e:	74a2                	ld	s1,40(sp)
 890:	7902                	ld	s2,32(sp)
 892:	69e2                	ld	s3,24(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
 89a:	6121                	addi	sp,sp,64
 89c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 89e:	6398                	ld	a4,0(a5)
 8a0:	e118                	sd	a4,0(a0)
 8a2:	bff1                	j	87e <malloc+0x86>
  hp->s.size = nu;
 8a4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 8a8:	0541                	addi	a0,a0,16
 8aa:	ec7ff0ef          	jal	ra,770 <free>
  return freep;
 8ae:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b2:	dd61                	beqz	a0,88a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8b6:	4798                	lw	a4,8(a5)
 8b8:	fa9778e3          	bgeu	a4,s1,868 <malloc+0x70>
    if(p == freep)
 8bc:	00093703          	ld	a4,0(s2)
 8c0:	853e                	mv	a0,a5
 8c2:	fef719e3          	bne	a4,a5,8b4 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8c6:	8552                	mv	a0,s4
 8c8:	9e7ff0ef          	jal	ra,2ae <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8cc:	fd551ce3          	bne	a0,s5,8a4 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 8d0:	4501                	li	a0,0
 8d2:	bf65                	j	88a <malloc+0x92>
