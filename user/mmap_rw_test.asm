
user/_mmap_rw_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int main(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *p = mmap(0, 8192, PROT_READ|PROT_WRITE, MAP_ANON, 1);
   a:	4705                	li	a4,1
   c:	4685                	li	a3,1
   e:	460d                	li	a2,3
  10:	6589                	lui	a1,0x2
  12:	4501                	li	a0,0
  14:	36a000ef          	jal	ra,37e <mmap>
  18:	84aa                	mv	s1,a0
  p[0] = 'A';
  1a:	04100793          	li	a5,65
  1e:	00f50023          	sb	a5,0(a0)
  p[4096] = 'B';
  22:	6785                	lui	a5,0x1
  24:	97aa                	add	a5,a5,a0
  26:	04200713          	li	a4,66
  2a:	00e78023          	sb	a4,0(a5) # 1000 <freep>
  if(p[0]=='A' && p[4096]=='B') printf("RW PASS\n");
  2e:	00001517          	auipc	a0,0x1
  32:	8a250513          	addi	a0,a0,-1886 # 8d0 <malloc+0xdc>
  36:	704000ef          	jal	ra,73a <printf>
  munmap(p, 8192);
  3a:	6589                	lui	a1,0x2
  3c:	8526                	mv	a0,s1
  3e:	348000ef          	jal	ra,386 <munmap>
  exit(0);
  42:	4501                	li	a0,0
  44:	29a000ef          	jal	ra,2de <exit>

0000000000000048 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e406                	sd	ra,8(sp)
  4c:	e022                	sd	s0,0(sp)
  4e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  50:	fb1ff0ef          	jal	ra,0 <main>
  exit(r);
  54:	28a000ef          	jal	ra,2de <exit>

0000000000000058 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e422                	sd	s0,8(sp)
  5c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5e:	87aa                	mv	a5,a0
  60:	0585                	addi	a1,a1,1
  62:	0785                	addi	a5,a5,1
  64:	fff5c703          	lbu	a4,-1(a1) # 1fff <base+0xfef>
  68:	fee78fa3          	sb	a4,-1(a5)
  6c:	fb75                	bnez	a4,60 <strcpy+0x8>
    ;
  return os;
}
  6e:	6422                	ld	s0,8(sp)
  70:	0141                	addi	sp,sp,16
  72:	8082                	ret

0000000000000074 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	cb91                	beqz	a5,92 <strcmp+0x1e>
  80:	0005c703          	lbu	a4,0(a1)
  84:	00f71763          	bne	a4,a5,92 <strcmp+0x1e>
    p++, q++;
  88:	0505                	addi	a0,a0,1
  8a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8c:	00054783          	lbu	a5,0(a0)
  90:	fbe5                	bnez	a5,80 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  92:	0005c503          	lbu	a0,0(a1)
}
  96:	40a7853b          	subw	a0,a5,a0
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cf91                	beqz	a5,c6 <strlen+0x26>
  ac:	0505                	addi	a0,a0,1
  ae:	87aa                	mv	a5,a0
  b0:	4685                	li	a3,1
  b2:	9e89                	subw	a3,a3,a0
  b4:	00f6853b          	addw	a0,a3,a5
  b8:	0785                	addi	a5,a5,1
  ba:	fff7c703          	lbu	a4,-1(a5)
  be:	fb7d                	bnez	a4,b4 <strlen+0x14>
    ;
  return n;
}
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret
  for(n = 0; s[n]; n++)
  c6:	4501                	li	a0,0
  c8:	bfe5                	j	c0 <strlen+0x20>

00000000000000ca <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d0:	ca19                	beqz	a2,e6 <memset+0x1c>
  d2:	87aa                	mv	a5,a0
  d4:	1602                	slli	a2,a2,0x20
  d6:	9201                	srli	a2,a2,0x20
  d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e0:	0785                	addi	a5,a5,1
  e2:	fee79de3          	bne	a5,a4,dc <memset+0x12>
  }
  return dst;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cb99                	beqz	a5,10c <strchr+0x20>
    if(*s == c)
  f8:	00f58763          	beq	a1,a5,106 <strchr+0x1a>
  for(; *s; s++)
  fc:	0505                	addi	a0,a0,1
  fe:	00054783          	lbu	a5,0(a0)
 102:	fbfd                	bnez	a5,f8 <strchr+0xc>
      return (char*)s;
  return 0;
 104:	4501                	li	a0,0
}
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  return 0;
 10c:	4501                	li	a0,0
 10e:	bfe5                	j	106 <strchr+0x1a>

0000000000000110 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 110:	711d                	addi	sp,sp,-96
 112:	ec86                	sd	ra,88(sp)
 114:	e8a2                	sd	s0,80(sp)
 116:	e4a6                	sd	s1,72(sp)
 118:	e0ca                	sd	s2,64(sp)
 11a:	fc4e                	sd	s3,56(sp)
 11c:	f852                	sd	s4,48(sp)
 11e:	f456                	sd	s5,40(sp)
 120:	f05a                	sd	s6,32(sp)
 122:	ec5e                	sd	s7,24(sp)
 124:	1080                	addi	s0,sp,96
 126:	8baa                	mv	s7,a0
 128:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12a:	892a                	mv	s2,a0
 12c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 12e:	4aa9                	li	s5,10
 130:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 132:	89a6                	mv	s3,s1
 134:	2485                	addiw	s1,s1,1
 136:	0344d663          	bge	s1,s4,162 <gets+0x52>
    cc = read(0, &c, 1);
 13a:	4605                	li	a2,1
 13c:	faf40593          	addi	a1,s0,-81
 140:	4501                	li	a0,0
 142:	1b4000ef          	jal	ra,2f6 <read>
    if(cc < 1)
 146:	00a05e63          	blez	a0,162 <gets+0x52>
    buf[i++] = c;
 14a:	faf44783          	lbu	a5,-81(s0)
 14e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 152:	01578763          	beq	a5,s5,160 <gets+0x50>
 156:	0905                	addi	s2,s2,1
 158:	fd679de3          	bne	a5,s6,132 <gets+0x22>
  for(i=0; i+1 < max; ){
 15c:	89a6                	mv	s3,s1
 15e:	a011                	j	162 <gets+0x52>
 160:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 162:	99de                	add	s3,s3,s7
 164:	00098023          	sb	zero,0(s3)
  return buf;
}
 168:	855e                	mv	a0,s7
 16a:	60e6                	ld	ra,88(sp)
 16c:	6446                	ld	s0,80(sp)
 16e:	64a6                	ld	s1,72(sp)
 170:	6906                	ld	s2,64(sp)
 172:	79e2                	ld	s3,56(sp)
 174:	7a42                	ld	s4,48(sp)
 176:	7aa2                	ld	s5,40(sp)
 178:	7b02                	ld	s6,32(sp)
 17a:	6be2                	ld	s7,24(sp)
 17c:	6125                	addi	sp,sp,96
 17e:	8082                	ret

0000000000000180 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 180:	1101                	addi	sp,sp,-32
 182:	ec06                	sd	ra,24(sp)
 184:	e822                	sd	s0,16(sp)
 186:	e426                	sd	s1,8(sp)
 188:	e04a                	sd	s2,0(sp)
 18a:	1000                	addi	s0,sp,32
 18c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18e:	4581                	li	a1,0
 190:	18e000ef          	jal	ra,31e <open>
  if(fd < 0)
 194:	02054163          	bltz	a0,1b6 <stat+0x36>
 198:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 19a:	85ca                	mv	a1,s2
 19c:	19a000ef          	jal	ra,336 <fstat>
 1a0:	892a                	mv	s2,a0
  close(fd);
 1a2:	8526                	mv	a0,s1
 1a4:	162000ef          	jal	ra,306 <close>
  return r;
}
 1a8:	854a                	mv	a0,s2
 1aa:	60e2                	ld	ra,24(sp)
 1ac:	6442                	ld	s0,16(sp)
 1ae:	64a2                	ld	s1,8(sp)
 1b0:	6902                	ld	s2,0(sp)
 1b2:	6105                	addi	sp,sp,32
 1b4:	8082                	ret
    return -1;
 1b6:	597d                	li	s2,-1
 1b8:	bfc5                	j	1a8 <stat+0x28>

00000000000001ba <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c0:	00054603          	lbu	a2,0(a0)
 1c4:	fd06079b          	addiw	a5,a2,-48
 1c8:	0ff7f793          	andi	a5,a5,255
 1cc:	4725                	li	a4,9
 1ce:	02f76963          	bltu	a4,a5,200 <atoi+0x46>
 1d2:	86aa                	mv	a3,a0
  n = 0;
 1d4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1d6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1d8:	0685                	addi	a3,a3,1
 1da:	0025179b          	slliw	a5,a0,0x2
 1de:	9fa9                	addw	a5,a5,a0
 1e0:	0017979b          	slliw	a5,a5,0x1
 1e4:	9fb1                	addw	a5,a5,a2
 1e6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ea:	0006c603          	lbu	a2,0(a3)
 1ee:	fd06071b          	addiw	a4,a2,-48
 1f2:	0ff77713          	andi	a4,a4,255
 1f6:	fee5f1e3          	bgeu	a1,a4,1d8 <atoi+0x1e>
  return n;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
  n = 0;
 200:	4501                	li	a0,0
 202:	bfe5                	j	1fa <atoi+0x40>

0000000000000204 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20a:	02b57463          	bgeu	a0,a1,232 <memmove+0x2e>
    while(n-- > 0)
 20e:	00c05f63          	blez	a2,22c <memmove+0x28>
 212:	1602                	slli	a2,a2,0x20
 214:	9201                	srli	a2,a2,0x20
 216:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 21a:	872a                	mv	a4,a0
      *dst++ = *src++;
 21c:	0585                	addi	a1,a1,1
 21e:	0705                	addi	a4,a4,1
 220:	fff5c683          	lbu	a3,-1(a1)
 224:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 228:	fee79ae3          	bne	a5,a4,21c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
    dst += n;
 232:	00c50733          	add	a4,a0,a2
    src += n;
 236:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 238:	fec05ae3          	blez	a2,22c <memmove+0x28>
 23c:	fff6079b          	addiw	a5,a2,-1
 240:	1782                	slli	a5,a5,0x20
 242:	9381                	srli	a5,a5,0x20
 244:	fff7c793          	not	a5,a5
 248:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24a:	15fd                	addi	a1,a1,-1
 24c:	177d                	addi	a4,a4,-1
 24e:	0005c683          	lbu	a3,0(a1)
 252:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 256:	fee79ae3          	bne	a5,a4,24a <memmove+0x46>
 25a:	bfc9                	j	22c <memmove+0x28>

000000000000025c <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 262:	ca05                	beqz	a2,292 <memcmp+0x36>
 264:	fff6069b          	addiw	a3,a2,-1
 268:	1682                	slli	a3,a3,0x20
 26a:	9281                	srli	a3,a3,0x20
 26c:	0685                	addi	a3,a3,1
 26e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 270:	00054783          	lbu	a5,0(a0)
 274:	0005c703          	lbu	a4,0(a1)
 278:	00e79863          	bne	a5,a4,288 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 27c:	0505                	addi	a0,a0,1
    p2++;
 27e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 280:	fed518e3          	bne	a0,a3,270 <memcmp+0x14>
  }
  return 0;
 284:	4501                	li	a0,0
 286:	a019                	j	28c <memcmp+0x30>
      return *p1 - *p2;
 288:	40e7853b          	subw	a0,a5,a4
}
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret
  return 0;
 292:	4501                	li	a0,0
 294:	bfe5                	j	28c <memcmp+0x30>

0000000000000296 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 296:	1141                	addi	sp,sp,-16
 298:	e406                	sd	ra,8(sp)
 29a:	e022                	sd	s0,0(sp)
 29c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29e:	f67ff0ef          	jal	ra,204 <memmove>
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2b2:	4585                	li	a1,1
 2b4:	0b2000ef          	jal	ra,366 <sys_sbrk>
}
 2b8:	60a2                	ld	ra,8(sp)
 2ba:	6402                	ld	s0,0(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e406                	sd	ra,8(sp)
 2c4:	e022                	sd	s0,0(sp)
 2c6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2c8:	4589                	li	a1,2
 2ca:	09c000ef          	jal	ra,366 <sys_sbrk>
}
 2ce:	60a2                	ld	ra,8(sp)
 2d0:	6402                	ld	s0,0(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret

00000000000002d6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2d6:	4885                	li	a7,1
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <exit>:
.global exit
exit:
 li a7, SYS_exit
 2de:	4889                	li	a7,2
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2e6:	488d                	li	a7,3
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ee:	4891                	li	a7,4
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <read>:
.global read
read:
 li a7, SYS_read
 2f6:	4895                	li	a7,5
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <write>:
.global write
write:
 li a7, SYS_write
 2fe:	48c1                	li	a7,16
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <close>:
.global close
close:
 li a7, SYS_close
 306:	48d5                	li	a7,21
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <kill>:
.global kill
kill:
 li a7, SYS_kill
 30e:	4899                	li	a7,6
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <exec>:
.global exec
exec:
 li a7, SYS_exec
 316:	489d                	li	a7,7
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <open>:
.global open
open:
 li a7, SYS_open
 31e:	48bd                	li	a7,15
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 326:	48c5                	li	a7,17
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 32e:	48c9                	li	a7,18
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 336:	48a1                	li	a7,8
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <link>:
.global link
link:
 li a7, SYS_link
 33e:	48cd                	li	a7,19
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 346:	48d1                	li	a7,20
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 34e:	48a5                	li	a7,9
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <dup>:
.global dup
dup:
 li a7, SYS_dup
 356:	48a9                	li	a7,10
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 35e:	48ad                	li	a7,11
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 366:	48b1                	li	a7,12
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <pause>:
.global pause
pause:
 li a7, SYS_pause
 36e:	48b5                	li	a7,13
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 376:	48b9                	li	a7,14
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 37e:	48d9                	li	a7,22
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 386:	48dd                	li	a7,23
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 38e:	48e1                	li	a7,24
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 396:	48e5                	li	a7,25
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 39e:	48e9                	li	a7,26
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3a6:	48ed                	li	a7,27
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3ae:	48f1                	li	a7,28
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3b6:	48f5                	li	a7,29
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 3be:	1101                	addi	sp,sp,-32
 3c0:	ec06                	sd	ra,24(sp)
 3c2:	e822                	sd	s0,16(sp)
 3c4:	1000                	addi	s0,sp,32
 3c6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ca:	4605                	li	a2,1
 3cc:	fef40593          	addi	a1,s0,-17
 3d0:	f2fff0ef          	jal	ra,2fe <write>
}
 3d4:	60e2                	ld	ra,24(sp)
 3d6:	6442                	ld	s0,16(sp)
 3d8:	6105                	addi	sp,sp,32
 3da:	8082                	ret

00000000000003dc <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 3dc:	715d                	addi	sp,sp,-80
 3de:	e486                	sd	ra,72(sp)
 3e0:	e0a2                	sd	s0,64(sp)
 3e2:	fc26                	sd	s1,56(sp)
 3e4:	f84a                	sd	s2,48(sp)
 3e6:	f44e                	sd	s3,40(sp)
 3e8:	0880                	addi	s0,sp,80
 3ea:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ec:	c299                	beqz	a3,3f2 <printint+0x16>
 3ee:	0805c163          	bltz	a1,470 <printint+0x94>
  neg = 0;
 3f2:	4881                	li	a7,0
 3f4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3f8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3fa:	00000517          	auipc	a0,0x0
 3fe:	4ee50513          	addi	a0,a0,1262 # 8e8 <digits>
 402:	883e                	mv	a6,a5
 404:	2785                	addiw	a5,a5,1
 406:	02c5f733          	remu	a4,a1,a2
 40a:	972a                	add	a4,a4,a0
 40c:	00074703          	lbu	a4,0(a4)
 410:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 414:	872e                	mv	a4,a1
 416:	02c5d5b3          	divu	a1,a1,a2
 41a:	0685                	addi	a3,a3,1
 41c:	fec773e3          	bgeu	a4,a2,402 <printint+0x26>
  if(neg)
 420:	00088b63          	beqz	a7,436 <printint+0x5a>
    buf[i++] = '-';
 424:	fd040713          	addi	a4,s0,-48
 428:	97ba                	add	a5,a5,a4
 42a:	02d00713          	li	a4,45
 42e:	fee78423          	sb	a4,-24(a5)
 432:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 436:	02f05663          	blez	a5,462 <printint+0x86>
 43a:	fb840713          	addi	a4,s0,-72
 43e:	00f704b3          	add	s1,a4,a5
 442:	fff70993          	addi	s3,a4,-1
 446:	99be                	add	s3,s3,a5
 448:	37fd                	addiw	a5,a5,-1
 44a:	1782                	slli	a5,a5,0x20
 44c:	9381                	srli	a5,a5,0x20
 44e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 452:	fff4c583          	lbu	a1,-1(s1)
 456:	854a                	mv	a0,s2
 458:	f67ff0ef          	jal	ra,3be <putc>
  while(--i >= 0)
 45c:	14fd                	addi	s1,s1,-1
 45e:	ff349ae3          	bne	s1,s3,452 <printint+0x76>
}
 462:	60a6                	ld	ra,72(sp)
 464:	6406                	ld	s0,64(sp)
 466:	74e2                	ld	s1,56(sp)
 468:	7942                	ld	s2,48(sp)
 46a:	79a2                	ld	s3,40(sp)
 46c:	6161                	addi	sp,sp,80
 46e:	8082                	ret
    x = -xx;
 470:	40b005b3          	neg	a1,a1
    neg = 1;
 474:	4885                	li	a7,1
    x = -xx;
 476:	bfbd                	j	3f4 <printint+0x18>

0000000000000478 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 478:	7119                	addi	sp,sp,-128
 47a:	fc86                	sd	ra,120(sp)
 47c:	f8a2                	sd	s0,112(sp)
 47e:	f4a6                	sd	s1,104(sp)
 480:	f0ca                	sd	s2,96(sp)
 482:	ecce                	sd	s3,88(sp)
 484:	e8d2                	sd	s4,80(sp)
 486:	e4d6                	sd	s5,72(sp)
 488:	e0da                	sd	s6,64(sp)
 48a:	fc5e                	sd	s7,56(sp)
 48c:	f862                	sd	s8,48(sp)
 48e:	f466                	sd	s9,40(sp)
 490:	f06a                	sd	s10,32(sp)
 492:	ec6e                	sd	s11,24(sp)
 494:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 496:	0005c903          	lbu	s2,0(a1)
 49a:	24090c63          	beqz	s2,6f2 <vprintf+0x27a>
 49e:	8b2a                	mv	s6,a0
 4a0:	8a2e                	mv	s4,a1
 4a2:	8bb2                	mv	s7,a2
  state = 0;
 4a4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4a6:	4481                	li	s1,0
 4a8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4aa:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4ae:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4b2:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4b6:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ba:	00000c97          	auipc	s9,0x0
 4be:	42ec8c93          	addi	s9,s9,1070 # 8e8 <digits>
 4c2:	a005                	j	4e2 <vprintf+0x6a>
        putc(fd, c0);
 4c4:	85ca                	mv	a1,s2
 4c6:	855a                	mv	a0,s6
 4c8:	ef7ff0ef          	jal	ra,3be <putc>
 4cc:	a019                	j	4d2 <vprintf+0x5a>
    } else if(state == '%'){
 4ce:	03598263          	beq	s3,s5,4f2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d2:	2485                	addiw	s1,s1,1
 4d4:	8726                	mv	a4,s1
 4d6:	009a07b3          	add	a5,s4,s1
 4da:	0007c903          	lbu	s2,0(a5)
 4de:	20090a63          	beqz	s2,6f2 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4e2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4e6:	fe0994e3          	bnez	s3,4ce <vprintf+0x56>
      if(c0 == '%'){
 4ea:	fd579de3          	bne	a5,s5,4c4 <vprintf+0x4c>
        state = '%';
 4ee:	89be                	mv	s3,a5
 4f0:	b7cd                	j	4d2 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4f2:	c3c1                	beqz	a5,572 <vprintf+0xfa>
 4f4:	00ea06b3          	add	a3,s4,a4
 4f8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4fc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4fe:	c681                	beqz	a3,506 <vprintf+0x8e>
 500:	9752                	add	a4,a4,s4
 502:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 506:	03878e63          	beq	a5,s8,542 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 50a:	05a78863          	beq	a5,s10,55a <vprintf+0xe2>
      } else if(c0 == 'u'){
 50e:	0db78b63          	beq	a5,s11,5e4 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 512:	07800713          	li	a4,120
 516:	10e78d63          	beq	a5,a4,630 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 51a:	07000713          	li	a4,112
 51e:	14e78263          	beq	a5,a4,662 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 522:	06300713          	li	a4,99
 526:	16e78f63          	beq	a5,a4,6a4 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 52a:	07300713          	li	a4,115
 52e:	18e78563          	beq	a5,a4,6b8 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 532:	05579063          	bne	a5,s5,572 <vprintf+0xfa>
        putc(fd, '%');
 536:	85d6                	mv	a1,s5
 538:	855a                	mv	a0,s6
 53a:	e85ff0ef          	jal	ra,3be <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 53e:	4981                	li	s3,0
 540:	bf49                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 542:	008b8913          	addi	s2,s7,8
 546:	4685                	li	a3,1
 548:	4629                	li	a2,10
 54a:	000ba583          	lw	a1,0(s7)
 54e:	855a                	mv	a0,s6
 550:	e8dff0ef          	jal	ra,3dc <printint>
 554:	8bca                	mv	s7,s2
      state = 0;
 556:	4981                	li	s3,0
 558:	bfad                	j	4d2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 55a:	03868663          	beq	a3,s8,586 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 55e:	05a68163          	beq	a3,s10,5a0 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 562:	09b68d63          	beq	a3,s11,5fc <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 566:	03a68f63          	beq	a3,s10,5a4 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 56a:	07800793          	li	a5,120
 56e:	0cf68d63          	beq	a3,a5,648 <vprintf+0x1d0>
        putc(fd, '%');
 572:	85d6                	mv	a1,s5
 574:	855a                	mv	a0,s6
 576:	e49ff0ef          	jal	ra,3be <putc>
        putc(fd, c0);
 57a:	85ca                	mv	a1,s2
 57c:	855a                	mv	a0,s6
 57e:	e41ff0ef          	jal	ra,3be <putc>
      state = 0;
 582:	4981                	li	s3,0
 584:	b7b9                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 586:	008b8913          	addi	s2,s7,8
 58a:	4685                	li	a3,1
 58c:	4629                	li	a2,10
 58e:	000bb583          	ld	a1,0(s7)
 592:	855a                	mv	a0,s6
 594:	e49ff0ef          	jal	ra,3dc <printint>
        i += 1;
 598:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 59a:	8bca                	mv	s7,s2
      state = 0;
 59c:	4981                	li	s3,0
        i += 1;
 59e:	bf15                	j	4d2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a0:	03860563          	beq	a2,s8,5ca <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a4:	07b60963          	beq	a2,s11,616 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5a8:	07800793          	li	a5,120
 5ac:	fcf613e3          	bne	a2,a5,572 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b0:	008b8913          	addi	s2,s7,8
 5b4:	4681                	li	a3,0
 5b6:	4641                	li	a2,16
 5b8:	000bb583          	ld	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	e1fff0ef          	jal	ra,3dc <printint>
        i += 2;
 5c2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
        i += 2;
 5c8:	b729                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4685                	li	a3,1
 5d0:	4629                	li	a2,10
 5d2:	000bb583          	ld	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	e05ff0ef          	jal	ra,3dc <printint>
        i += 2;
 5dc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
        i += 2;
 5e2:	bdc5                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5e4:	008b8913          	addi	s2,s7,8
 5e8:	4681                	li	a3,0
 5ea:	4629                	li	a2,10
 5ec:	000be583          	lwu	a1,0(s7)
 5f0:	855a                	mv	a0,s6
 5f2:	debff0ef          	jal	ra,3dc <printint>
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	bde1                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4681                	li	a3,0
 602:	4629                	li	a2,10
 604:	000bb583          	ld	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	dd3ff0ef          	jal	ra,3dc <printint>
        i += 1;
 60e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
        i += 1;
 614:	bd7d                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 616:	008b8913          	addi	s2,s7,8
 61a:	4681                	li	a3,0
 61c:	4629                	li	a2,10
 61e:	000bb583          	ld	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	db9ff0ef          	jal	ra,3dc <printint>
        i += 2;
 628:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
        i += 2;
 62e:	b555                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 630:	008b8913          	addi	s2,s7,8
 634:	4681                	li	a3,0
 636:	4641                	li	a2,16
 638:	000be583          	lwu	a1,0(s7)
 63c:	855a                	mv	a0,s6
 63e:	d9fff0ef          	jal	ra,3dc <printint>
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	b571                	j	4d2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	d87ff0ef          	jal	ra,3dc <printint>
        i += 1;
 65a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 1;
 660:	bd8d                	j	4d2 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 662:	008b8793          	addi	a5,s7,8
 666:	f8f43423          	sd	a5,-120(s0)
 66a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 66e:	03000593          	li	a1,48
 672:	855a                	mv	a0,s6
 674:	d4bff0ef          	jal	ra,3be <putc>
  putc(fd, 'x');
 678:	07800593          	li	a1,120
 67c:	855a                	mv	a0,s6
 67e:	d41ff0ef          	jal	ra,3be <putc>
 682:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 684:	03c9d793          	srli	a5,s3,0x3c
 688:	97e6                	add	a5,a5,s9
 68a:	0007c583          	lbu	a1,0(a5)
 68e:	855a                	mv	a0,s6
 690:	d2fff0ef          	jal	ra,3be <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 694:	0992                	slli	s3,s3,0x4
 696:	397d                	addiw	s2,s2,-1
 698:	fe0916e3          	bnez	s2,684 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 69c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bd05                	j	4d2 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	000bc583          	lbu	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d11ff0ef          	jal	ra,3be <putc>
 6b2:	8bca                	mv	s7,s2
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	bd31                	j	4d2 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6b8:	008b8993          	addi	s3,s7,8
 6bc:	000bb903          	ld	s2,0(s7)
 6c0:	00090f63          	beqz	s2,6de <vprintf+0x266>
        for(; *s; s++)
 6c4:	00094583          	lbu	a1,0(s2)
 6c8:	c195                	beqz	a1,6ec <vprintf+0x274>
          putc(fd, *s);
 6ca:	855a                	mv	a0,s6
 6cc:	cf3ff0ef          	jal	ra,3be <putc>
        for(; *s; s++)
 6d0:	0905                	addi	s2,s2,1
 6d2:	00094583          	lbu	a1,0(s2)
 6d6:	f9f5                	bnez	a1,6ca <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6d8:	8bce                	mv	s7,s3
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bbdd                	j	4d2 <vprintf+0x5a>
          s = "(null)";
 6de:	00000917          	auipc	s2,0x0
 6e2:	20290913          	addi	s2,s2,514 # 8e0 <malloc+0xec>
        for(; *s; s++)
 6e6:	02800593          	li	a1,40
 6ea:	b7c5                	j	6ca <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6ec:	8bce                	mv	s7,s3
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b3cd                	j	4d2 <vprintf+0x5a>
    }
  }
}
 6f2:	70e6                	ld	ra,120(sp)
 6f4:	7446                	ld	s0,112(sp)
 6f6:	74a6                	ld	s1,104(sp)
 6f8:	7906                	ld	s2,96(sp)
 6fa:	69e6                	ld	s3,88(sp)
 6fc:	6a46                	ld	s4,80(sp)
 6fe:	6aa6                	ld	s5,72(sp)
 700:	6b06                	ld	s6,64(sp)
 702:	7be2                	ld	s7,56(sp)
 704:	7c42                	ld	s8,48(sp)
 706:	7ca2                	ld	s9,40(sp)
 708:	7d02                	ld	s10,32(sp)
 70a:	6de2                	ld	s11,24(sp)
 70c:	6109                	addi	sp,sp,128
 70e:	8082                	ret

0000000000000710 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 710:	715d                	addi	sp,sp,-80
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	1000                	addi	s0,sp,32
 718:	e010                	sd	a2,0(s0)
 71a:	e414                	sd	a3,8(s0)
 71c:	e818                	sd	a4,16(s0)
 71e:	ec1c                	sd	a5,24(s0)
 720:	03043023          	sd	a6,32(s0)
 724:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72c:	8622                	mv	a2,s0
 72e:	d4bff0ef          	jal	ra,478 <vprintf>
}
 732:	60e2                	ld	ra,24(sp)
 734:	6442                	ld	s0,16(sp)
 736:	6161                	addi	sp,sp,80
 738:	8082                	ret

000000000000073a <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 73a:	711d                	addi	sp,sp,-96
 73c:	ec06                	sd	ra,24(sp)
 73e:	e822                	sd	s0,16(sp)
 740:	1000                	addi	s0,sp,32
 742:	e40c                	sd	a1,8(s0)
 744:	e810                	sd	a2,16(s0)
 746:	ec14                	sd	a3,24(s0)
 748:	f018                	sd	a4,32(s0)
 74a:	f41c                	sd	a5,40(s0)
 74c:	03043823          	sd	a6,48(s0)
 750:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 754:	00840613          	addi	a2,s0,8
 758:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 75c:	85aa                	mv	a1,a0
 75e:	4505                	li	a0,1
 760:	d19ff0ef          	jal	ra,478 <vprintf>
}
 764:	60e2                	ld	ra,24(sp)
 766:	6442                	ld	s0,16(sp)
 768:	6125                	addi	sp,sp,96
 76a:	8082                	ret

000000000000076c <free>:
 *   无
 */

void
free(void *ap)
{
 76c:	1141                	addi	sp,sp,-16
 76e:	e422                	sd	s0,8(sp)
 770:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 772:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 776:	00001797          	auipc	a5,0x1
 77a:	88a7b783          	ld	a5,-1910(a5) # 1000 <freep>
 77e:	a805                	j	7ae <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 780:	4618                	lw	a4,8(a2)
 782:	9db9                	addw	a1,a1,a4
 784:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 788:	6398                	ld	a4,0(a5)
 78a:	6318                	ld	a4,0(a4)
 78c:	fee53823          	sd	a4,-16(a0)
 790:	a091                	j	7d4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 792:	ff852703          	lw	a4,-8(a0)
 796:	9e39                	addw	a2,a2,a4
 798:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 79a:	ff053703          	ld	a4,-16(a0)
 79e:	e398                	sd	a4,0(a5)
 7a0:	a099                	j	7e6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a2:	6398                	ld	a4,0(a5)
 7a4:	00e7e463          	bltu	a5,a4,7ac <free+0x40>
 7a8:	00e6ea63          	bltu	a3,a4,7bc <free+0x50>
{
 7ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	fed7fae3          	bgeu	a5,a3,7a2 <free+0x36>
 7b2:	6398                	ld	a4,0(a5)
 7b4:	00e6e463          	bltu	a3,a4,7bc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b8:	fee7eae3          	bltu	a5,a4,7ac <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7bc:	ff852583          	lw	a1,-8(a0)
 7c0:	6390                	ld	a2,0(a5)
 7c2:	02059713          	slli	a4,a1,0x20
 7c6:	9301                	srli	a4,a4,0x20
 7c8:	0712                	slli	a4,a4,0x4
 7ca:	9736                	add	a4,a4,a3
 7cc:	fae60ae3          	beq	a2,a4,780 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d4:	4790                	lw	a2,8(a5)
 7d6:	02061713          	slli	a4,a2,0x20
 7da:	9301                	srli	a4,a4,0x20
 7dc:	0712                	slli	a4,a4,0x4
 7de:	973e                	add	a4,a4,a5
 7e0:	fae689e3          	beq	a3,a4,792 <free+0x26>
  } else
    p->s.ptr = bp;
 7e4:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
}
 7ee:	6422                	ld	s0,8(sp)
 7f0:	0141                	addi	sp,sp,16
 7f2:	8082                	ret

00000000000007f4 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 7f4:	7139                	addi	sp,sp,-64
 7f6:	fc06                	sd	ra,56(sp)
 7f8:	f822                	sd	s0,48(sp)
 7fa:	f426                	sd	s1,40(sp)
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	ec4e                	sd	s3,24(sp)
 800:	e852                	sd	s4,16(sp)
 802:	e456                	sd	s5,8(sp)
 804:	e05a                	sd	s6,0(sp)
 806:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 808:	02051493          	slli	s1,a0,0x20
 80c:	9081                	srli	s1,s1,0x20
 80e:	04bd                	addi	s1,s1,15
 810:	8091                	srli	s1,s1,0x4
 812:	0014899b          	addiw	s3,s1,1
 816:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 818:	00000517          	auipc	a0,0x0
 81c:	7e853503          	ld	a0,2024(a0) # 1000 <freep>
 820:	c515                	beqz	a0,84c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 822:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 824:	4798                	lw	a4,8(a5)
 826:	02977f63          	bgeu	a4,s1,864 <malloc+0x70>
 82a:	8a4e                	mv	s4,s3
 82c:	0009871b          	sext.w	a4,s3
 830:	6685                	lui	a3,0x1
 832:	00d77363          	bgeu	a4,a3,838 <malloc+0x44>
 836:	6a05                	lui	s4,0x1
 838:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 83c:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 840:	00000917          	auipc	s2,0x0
 844:	7c090913          	addi	s2,s2,1984 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 848:	5afd                	li	s5,-1
 84a:	a0bd                	j	8b8 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 84c:	00000797          	auipc	a5,0x0
 850:	7c478793          	addi	a5,a5,1988 # 1010 <base>
 854:	00000717          	auipc	a4,0x0
 858:	7af73623          	sd	a5,1964(a4) # 1000 <freep>
 85c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 862:	b7e1                	j	82a <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 864:	02e48b63          	beq	s1,a4,89a <malloc+0xa6>
        p->s.size -= nunits;
 868:	4137073b          	subw	a4,a4,s3
 86c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86e:	1702                	slli	a4,a4,0x20
 870:	9301                	srli	a4,a4,0x20
 872:	0712                	slli	a4,a4,0x4
 874:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 876:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 87a:	00000717          	auipc	a4,0x0
 87e:	78a73323          	sd	a0,1926(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 882:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 886:	70e2                	ld	ra,56(sp)
 888:	7442                	ld	s0,48(sp)
 88a:	74a2                	ld	s1,40(sp)
 88c:	7902                	ld	s2,32(sp)
 88e:	69e2                	ld	s3,24(sp)
 890:	6a42                	ld	s4,16(sp)
 892:	6aa2                	ld	s5,8(sp)
 894:	6b02                	ld	s6,0(sp)
 896:	6121                	addi	sp,sp,64
 898:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 89a:	6398                	ld	a4,0(a5)
 89c:	e118                	sd	a4,0(a0)
 89e:	bff1                	j	87a <malloc+0x86>
  hp->s.size = nu;
 8a0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 8a4:	0541                	addi	a0,a0,16
 8a6:	ec7ff0ef          	jal	ra,76c <free>
  return freep;
 8aa:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ae:	dd61                	beqz	a0,886 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8b2:	4798                	lw	a4,8(a5)
 8b4:	fa9778e3          	bgeu	a4,s1,864 <malloc+0x70>
    if(p == freep)
 8b8:	00093703          	ld	a4,0(s2)
 8bc:	853e                	mv	a0,a5
 8be:	fef719e3          	bne	a4,a5,8b0 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8c2:	8552                	mv	a0,s4
 8c4:	9e7ff0ef          	jal	ra,2aa <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8c8:	fd551ce3          	bne	a0,s5,8a0 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 8cc:	4501                	li	a0,0
 8ce:	bf65                	j	886 <malloc+0x92>
