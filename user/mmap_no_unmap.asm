
user/_mmap_no_unmap：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int main(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  char *p = mmap(0, 8192, PROT_READ|PROT_WRITE, MAP_ANON, 1);
   8:	4705                	li	a4,1
   a:	4685                	li	a3,1
   c:	460d                	li	a2,3
   e:	6589                	lui	a1,0x2
  10:	4501                	li	a0,0
  12:	346000ef          	jal	ra,358 <mmap>
  p[0] = 'A';
  16:	04100793          	li	a5,65
  1a:	00f50023          	sb	a5,0(a0)
  // 不调用 munmap，直接 exit
  exit(0);
  1e:	4501                	li	a0,0
  20:	298000ef          	jal	ra,2b8 <exit>

0000000000000024 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  24:	1141                	addi	sp,sp,-16
  26:	e406                	sd	ra,8(sp)
  28:	e022                	sd	s0,0(sp)
  2a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  2c:	fd5ff0ef          	jal	ra,0 <main>
  exit(r);
  30:	288000ef          	jal	ra,2b8 <exit>

0000000000000034 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  34:	1141                	addi	sp,sp,-16
  36:	e422                	sd	s0,8(sp)
  38:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  3a:	87aa                	mv	a5,a0
  3c:	0585                	addi	a1,a1,1 # 2001 <base+0xff1>
  3e:	0785                	addi	a5,a5,1
  40:	fff5c703          	lbu	a4,-1(a1)
  44:	fee78fa3          	sb	a4,-1(a5)
  48:	fb75                	bnez	a4,3c <strcpy+0x8>
    ;
  return os;
}
  4a:	6422                	ld	s0,8(sp)
  4c:	0141                	addi	sp,sp,16
  4e:	8082                	ret

0000000000000050 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  50:	1141                	addi	sp,sp,-16
  52:	e422                	sd	s0,8(sp)
  54:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  56:	00054783          	lbu	a5,0(a0)
  5a:	cb91                	beqz	a5,6e <strcmp+0x1e>
  5c:	0005c703          	lbu	a4,0(a1)
  60:	00f71763          	bne	a4,a5,6e <strcmp+0x1e>
    p++, q++;
  64:	0505                	addi	a0,a0,1
  66:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	fbe5                	bnez	a5,5c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  6e:	0005c503          	lbu	a0,0(a1)
}
  72:	40a7853b          	subw	a0,a5,a0
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strlen>:

uint
strlen(const char *s)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  82:	00054783          	lbu	a5,0(a0)
  86:	cf91                	beqz	a5,a2 <strlen+0x26>
  88:	0505                	addi	a0,a0,1
  8a:	87aa                	mv	a5,a0
  8c:	4685                	li	a3,1
  8e:	9e89                	subw	a3,a3,a0
  90:	00f6853b          	addw	a0,a3,a5
  94:	0785                	addi	a5,a5,1
  96:	fff7c703          	lbu	a4,-1(a5)
  9a:	fb7d                	bnez	a4,90 <strlen+0x14>
    ;
  return n;
}
  9c:	6422                	ld	s0,8(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret
  for(n = 0; s[n]; n++)
  a2:	4501                	li	a0,0
  a4:	bfe5                	j	9c <strlen+0x20>

00000000000000a6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ac:	ca19                	beqz	a2,c2 <memset+0x1c>
  ae:	87aa                	mv	a5,a0
  b0:	1602                	slli	a2,a2,0x20
  b2:	9201                	srli	a2,a2,0x20
  b4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  bc:	0785                	addi	a5,a5,1
  be:	fee79de3          	bne	a5,a4,b8 <memset+0x12>
  }
  return dst;
}
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret

00000000000000c8 <strchr>:

char*
strchr(const char *s, char c)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	cb99                	beqz	a5,e8 <strchr+0x20>
    if(*s == c)
  d4:	00f58763          	beq	a1,a5,e2 <strchr+0x1a>
  for(; *s; s++)
  d8:	0505                	addi	a0,a0,1
  da:	00054783          	lbu	a5,0(a0)
  de:	fbfd                	bnez	a5,d4 <strchr+0xc>
      return (char*)s;
  return 0;
  e0:	4501                	li	a0,0
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret
  return 0;
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strchr+0x1a>

00000000000000ec <gets>:

char*
gets(char *buf, int max)
{
  ec:	711d                	addi	sp,sp,-96
  ee:	ec86                	sd	ra,88(sp)
  f0:	e8a2                	sd	s0,80(sp)
  f2:	e4a6                	sd	s1,72(sp)
  f4:	e0ca                	sd	s2,64(sp)
  f6:	fc4e                	sd	s3,56(sp)
  f8:	f852                	sd	s4,48(sp)
  fa:	f456                	sd	s5,40(sp)
  fc:	f05a                	sd	s6,32(sp)
  fe:	ec5e                	sd	s7,24(sp)
 100:	1080                	addi	s0,sp,96
 102:	8baa                	mv	s7,a0
 104:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 106:	892a                	mv	s2,a0
 108:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 10a:	4aa9                	li	s5,10
 10c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 10e:	89a6                	mv	s3,s1
 110:	2485                	addiw	s1,s1,1
 112:	0344d663          	bge	s1,s4,13e <gets+0x52>
    cc = read(0, &c, 1);
 116:	4605                	li	a2,1
 118:	faf40593          	addi	a1,s0,-81
 11c:	4501                	li	a0,0
 11e:	1b2000ef          	jal	ra,2d0 <read>
    if(cc < 1)
 122:	00a05e63          	blez	a0,13e <gets+0x52>
    buf[i++] = c;
 126:	faf44783          	lbu	a5,-81(s0)
 12a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12e:	01578763          	beq	a5,s5,13c <gets+0x50>
 132:	0905                	addi	s2,s2,1
 134:	fd679de3          	bne	a5,s6,10e <gets+0x22>
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	a011                	j	13e <gets+0x52>
 13c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13e:	99de                	add	s3,s3,s7
 140:	00098023          	sb	zero,0(s3)
  return buf;
}
 144:	855e                	mv	a0,s7
 146:	60e6                	ld	ra,88(sp)
 148:	6446                	ld	s0,80(sp)
 14a:	64a6                	ld	s1,72(sp)
 14c:	6906                	ld	s2,64(sp)
 14e:	79e2                	ld	s3,56(sp)
 150:	7a42                	ld	s4,48(sp)
 152:	7aa2                	ld	s5,40(sp)
 154:	7b02                	ld	s6,32(sp)
 156:	6be2                	ld	s7,24(sp)
 158:	6125                	addi	sp,sp,96
 15a:	8082                	ret

000000000000015c <stat>:

int
stat(const char *n, struct stat *st)
{
 15c:	1101                	addi	sp,sp,-32
 15e:	ec06                	sd	ra,24(sp)
 160:	e822                	sd	s0,16(sp)
 162:	e426                	sd	s1,8(sp)
 164:	e04a                	sd	s2,0(sp)
 166:	1000                	addi	s0,sp,32
 168:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16a:	4581                	li	a1,0
 16c:	18c000ef          	jal	ra,2f8 <open>
  if(fd < 0)
 170:	02054163          	bltz	a0,192 <stat+0x36>
 174:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 176:	85ca                	mv	a1,s2
 178:	198000ef          	jal	ra,310 <fstat>
 17c:	892a                	mv	s2,a0
  close(fd);
 17e:	8526                	mv	a0,s1
 180:	160000ef          	jal	ra,2e0 <close>
  return r;
}
 184:	854a                	mv	a0,s2
 186:	60e2                	ld	ra,24(sp)
 188:	6442                	ld	s0,16(sp)
 18a:	64a2                	ld	s1,8(sp)
 18c:	6902                	ld	s2,0(sp)
 18e:	6105                	addi	sp,sp,32
 190:	8082                	ret
    return -1;
 192:	597d                	li	s2,-1
 194:	bfc5                	j	184 <stat+0x28>

0000000000000196 <atoi>:

int
atoi(const char *s)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 19c:	00054683          	lbu	a3,0(a0)
 1a0:	fd06879b          	addiw	a5,a3,-48
 1a4:	0ff7f793          	zext.b	a5,a5
 1a8:	4625                	li	a2,9
 1aa:	02f66863          	bltu	a2,a5,1da <atoi+0x44>
 1ae:	872a                	mv	a4,a0
  n = 0;
 1b0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1b2:	0705                	addi	a4,a4,1
 1b4:	0025179b          	slliw	a5,a0,0x2
 1b8:	9fa9                	addw	a5,a5,a0
 1ba:	0017979b          	slliw	a5,a5,0x1
 1be:	9fb5                	addw	a5,a5,a3
 1c0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c4:	00074683          	lbu	a3,0(a4)
 1c8:	fd06879b          	addiw	a5,a3,-48
 1cc:	0ff7f793          	zext.b	a5,a5
 1d0:	fef671e3          	bgeu	a2,a5,1b2 <atoi+0x1c>
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  n = 0;
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <atoi+0x3e>

00000000000001de <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e4:	02b57463          	bgeu	a0,a1,20c <memmove+0x2e>
    while(n-- > 0)
 1e8:	00c05f63          	blez	a2,206 <memmove+0x28>
 1ec:	1602                	slli	a2,a2,0x20
 1ee:	9201                	srli	a2,a2,0x20
 1f0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1f4:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f6:	0585                	addi	a1,a1,1
 1f8:	0705                	addi	a4,a4,1
 1fa:	fff5c683          	lbu	a3,-1(a1)
 1fe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 202:	fee79ae3          	bne	a5,a4,1f6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
    dst += n;
 20c:	00c50733          	add	a4,a0,a2
    src += n;
 210:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 212:	fec05ae3          	blez	a2,206 <memmove+0x28>
 216:	fff6079b          	addiw	a5,a2,-1
 21a:	1782                	slli	a5,a5,0x20
 21c:	9381                	srli	a5,a5,0x20
 21e:	fff7c793          	not	a5,a5
 222:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 224:	15fd                	addi	a1,a1,-1
 226:	177d                	addi	a4,a4,-1
 228:	0005c683          	lbu	a3,0(a1)
 22c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 230:	fee79ae3          	bne	a5,a4,224 <memmove+0x46>
 234:	bfc9                	j	206 <memmove+0x28>

0000000000000236 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 23c:	ca05                	beqz	a2,26c <memcmp+0x36>
 23e:	fff6069b          	addiw	a3,a2,-1
 242:	1682                	slli	a3,a3,0x20
 244:	9281                	srli	a3,a3,0x20
 246:	0685                	addi	a3,a3,1
 248:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 24a:	00054783          	lbu	a5,0(a0)
 24e:	0005c703          	lbu	a4,0(a1)
 252:	00e79863          	bne	a5,a4,262 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 256:	0505                	addi	a0,a0,1
    p2++;
 258:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 25a:	fed518e3          	bne	a0,a3,24a <memcmp+0x14>
  }
  return 0;
 25e:	4501                	li	a0,0
 260:	a019                	j	266 <memcmp+0x30>
      return *p1 - *p2;
 262:	40e7853b          	subw	a0,a5,a4
}
 266:	6422                	ld	s0,8(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret
  return 0;
 26c:	4501                	li	a0,0
 26e:	bfe5                	j	266 <memcmp+0x30>

0000000000000270 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 270:	1141                	addi	sp,sp,-16
 272:	e406                	sd	ra,8(sp)
 274:	e022                	sd	s0,0(sp)
 276:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 278:	f67ff0ef          	jal	ra,1de <memmove>
}
 27c:	60a2                	ld	ra,8(sp)
 27e:	6402                	ld	s0,0(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret

0000000000000284 <sbrk>:

char *
sbrk(int n) {
 284:	1141                	addi	sp,sp,-16
 286:	e406                	sd	ra,8(sp)
 288:	e022                	sd	s0,0(sp)
 28a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 28c:	4585                	li	a1,1
 28e:	0b2000ef          	jal	ra,340 <sys_sbrk>
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret

000000000000029a <sbrklazy>:

char *
sbrklazy(int n) {
 29a:	1141                	addi	sp,sp,-16
 29c:	e406                	sd	ra,8(sp)
 29e:	e022                	sd	s0,0(sp)
 2a0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2a2:	4589                	li	a1,2
 2a4:	09c000ef          	jal	ra,340 <sys_sbrk>
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret

00000000000002b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2b0:	4885                	li	a7,1
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b8:	4889                	li	a7,2
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2c0:	488d                	li	a7,3
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c8:	4891                	li	a7,4
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <read>:
.global read
read:
 li a7, SYS_read
 2d0:	4895                	li	a7,5
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <write>:
.global write
write:
 li a7, SYS_write
 2d8:	48c1                	li	a7,16
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <close>:
.global close
close:
 li a7, SYS_close
 2e0:	48d5                	li	a7,21
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e8:	4899                	li	a7,6
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2f0:	489d                	li	a7,7
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <open>:
.global open
open:
 li a7, SYS_open
 2f8:	48bd                	li	a7,15
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 300:	48c5                	li	a7,17
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 308:	48c9                	li	a7,18
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 310:	48a1                	li	a7,8
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <link>:
.global link
link:
 li a7, SYS_link
 318:	48cd                	li	a7,19
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 320:	48d1                	li	a7,20
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 328:	48a5                	li	a7,9
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <dup>:
.global dup
dup:
 li a7, SYS_dup
 330:	48a9                	li	a7,10
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 338:	48ad                	li	a7,11
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 340:	48b1                	li	a7,12
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <pause>:
.global pause
pause:
 li a7, SYS_pause
 348:	48b5                	li	a7,13
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 350:	48b9                	li	a7,14
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 358:	48d9                	li	a7,22
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 360:	48dd                	li	a7,23
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 368:	48e1                	li	a7,24
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 370:	48e5                	li	a7,25
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 378:	48e9                	li	a7,26
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 380:	48ed                	li	a7,27
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 388:	48f1                	li	a7,28
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 390:	48f5                	li	a7,29
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 398:	1101                	addi	sp,sp,-32
 39a:	ec06                	sd	ra,24(sp)
 39c:	e822                	sd	s0,16(sp)
 39e:	1000                	addi	s0,sp,32
 3a0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a4:	4605                	li	a2,1
 3a6:	fef40593          	addi	a1,s0,-17
 3aa:	f2fff0ef          	jal	ra,2d8 <write>
}
 3ae:	60e2                	ld	ra,24(sp)
 3b0:	6442                	ld	s0,16(sp)
 3b2:	6105                	addi	sp,sp,32
 3b4:	8082                	ret

00000000000003b6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3b6:	715d                	addi	sp,sp,-80
 3b8:	e486                	sd	ra,72(sp)
 3ba:	e0a2                	sd	s0,64(sp)
 3bc:	fc26                	sd	s1,56(sp)
 3be:	f84a                	sd	s2,48(sp)
 3c0:	f44e                	sd	s3,40(sp)
 3c2:	0880                	addi	s0,sp,80
 3c4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3c6:	c299                	beqz	a3,3cc <printint+0x16>
 3c8:	0805c163          	bltz	a1,44a <printint+0x94>
  neg = 0;
 3cc:	4881                	li	a7,0
 3ce:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3d2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3d4:	00000517          	auipc	a0,0x0
 3d8:	4e450513          	addi	a0,a0,1252 # 8b8 <digits>
 3dc:	883e                	mv	a6,a5
 3de:	2785                	addiw	a5,a5,1
 3e0:	02c5f733          	remu	a4,a1,a2
 3e4:	972a                	add	a4,a4,a0
 3e6:	00074703          	lbu	a4,0(a4)
 3ea:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3ee:	872e                	mv	a4,a1
 3f0:	02c5d5b3          	divu	a1,a1,a2
 3f4:	0685                	addi	a3,a3,1
 3f6:	fec773e3          	bgeu	a4,a2,3dc <printint+0x26>
  if(neg)
 3fa:	00088b63          	beqz	a7,410 <printint+0x5a>
    buf[i++] = '-';
 3fe:	fd078793          	addi	a5,a5,-48
 402:	97a2                	add	a5,a5,s0
 404:	02d00713          	li	a4,45
 408:	fee78423          	sb	a4,-24(a5)
 40c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 410:	02f05663          	blez	a5,43c <printint+0x86>
 414:	fb840713          	addi	a4,s0,-72
 418:	00f704b3          	add	s1,a4,a5
 41c:	fff70993          	addi	s3,a4,-1
 420:	99be                	add	s3,s3,a5
 422:	37fd                	addiw	a5,a5,-1
 424:	1782                	slli	a5,a5,0x20
 426:	9381                	srli	a5,a5,0x20
 428:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 42c:	fff4c583          	lbu	a1,-1(s1)
 430:	854a                	mv	a0,s2
 432:	f67ff0ef          	jal	ra,398 <putc>
  while(--i >= 0)
 436:	14fd                	addi	s1,s1,-1
 438:	ff349ae3          	bne	s1,s3,42c <printint+0x76>
}
 43c:	60a6                	ld	ra,72(sp)
 43e:	6406                	ld	s0,64(sp)
 440:	74e2                	ld	s1,56(sp)
 442:	7942                	ld	s2,48(sp)
 444:	79a2                	ld	s3,40(sp)
 446:	6161                	addi	sp,sp,80
 448:	8082                	ret
    x = -xx;
 44a:	40b005b3          	neg	a1,a1
    neg = 1;
 44e:	4885                	li	a7,1
    x = -xx;
 450:	bfbd                	j	3ce <printint+0x18>

0000000000000452 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 452:	7119                	addi	sp,sp,-128
 454:	fc86                	sd	ra,120(sp)
 456:	f8a2                	sd	s0,112(sp)
 458:	f4a6                	sd	s1,104(sp)
 45a:	f0ca                	sd	s2,96(sp)
 45c:	ecce                	sd	s3,88(sp)
 45e:	e8d2                	sd	s4,80(sp)
 460:	e4d6                	sd	s5,72(sp)
 462:	e0da                	sd	s6,64(sp)
 464:	fc5e                	sd	s7,56(sp)
 466:	f862                	sd	s8,48(sp)
 468:	f466                	sd	s9,40(sp)
 46a:	f06a                	sd	s10,32(sp)
 46c:	ec6e                	sd	s11,24(sp)
 46e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 470:	0005c903          	lbu	s2,0(a1)
 474:	24090c63          	beqz	s2,6cc <vprintf+0x27a>
 478:	8b2a                	mv	s6,a0
 47a:	8a2e                	mv	s4,a1
 47c:	8bb2                	mv	s7,a2
  state = 0;
 47e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 480:	4481                	li	s1,0
 482:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 484:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 488:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 48c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 490:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 494:	00000c97          	auipc	s9,0x0
 498:	424c8c93          	addi	s9,s9,1060 # 8b8 <digits>
 49c:	a005                	j	4bc <vprintf+0x6a>
        putc(fd, c0);
 49e:	85ca                	mv	a1,s2
 4a0:	855a                	mv	a0,s6
 4a2:	ef7ff0ef          	jal	ra,398 <putc>
 4a6:	a019                	j	4ac <vprintf+0x5a>
    } else if(state == '%'){
 4a8:	03598263          	beq	s3,s5,4cc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4ac:	2485                	addiw	s1,s1,1
 4ae:	8726                	mv	a4,s1
 4b0:	009a07b3          	add	a5,s4,s1
 4b4:	0007c903          	lbu	s2,0(a5)
 4b8:	20090a63          	beqz	s2,6cc <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4bc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4c0:	fe0994e3          	bnez	s3,4a8 <vprintf+0x56>
      if(c0 == '%'){
 4c4:	fd579de3          	bne	a5,s5,49e <vprintf+0x4c>
        state = '%';
 4c8:	89be                	mv	s3,a5
 4ca:	b7cd                	j	4ac <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4cc:	c3c1                	beqz	a5,54c <vprintf+0xfa>
 4ce:	00ea06b3          	add	a3,s4,a4
 4d2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4d6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4d8:	c681                	beqz	a3,4e0 <vprintf+0x8e>
 4da:	9752                	add	a4,a4,s4
 4dc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4e0:	03878e63          	beq	a5,s8,51c <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 4e4:	05a78863          	beq	a5,s10,534 <vprintf+0xe2>
      } else if(c0 == 'u'){
 4e8:	0db78b63          	beq	a5,s11,5be <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4ec:	07800713          	li	a4,120
 4f0:	10e78d63          	beq	a5,a4,60a <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4f4:	07000713          	li	a4,112
 4f8:	14e78263          	beq	a5,a4,63c <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4fc:	06300713          	li	a4,99
 500:	16e78f63          	beq	a5,a4,67e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 504:	07300713          	li	a4,115
 508:	18e78563          	beq	a5,a4,692 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 50c:	05579063          	bne	a5,s5,54c <vprintf+0xfa>
        putc(fd, '%');
 510:	85d6                	mv	a1,s5
 512:	855a                	mv	a0,s6
 514:	e85ff0ef          	jal	ra,398 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 518:	4981                	li	s3,0
 51a:	bf49                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 51c:	008b8913          	addi	s2,s7,8
 520:	4685                	li	a3,1
 522:	4629                	li	a2,10
 524:	000ba583          	lw	a1,0(s7)
 528:	855a                	mv	a0,s6
 52a:	e8dff0ef          	jal	ra,3b6 <printint>
 52e:	8bca                	mv	s7,s2
      state = 0;
 530:	4981                	li	s3,0
 532:	bfad                	j	4ac <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 534:	03868663          	beq	a3,s8,560 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 538:	05a68163          	beq	a3,s10,57a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 53c:	09b68d63          	beq	a3,s11,5d6 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 540:	03a68f63          	beq	a3,s10,57e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 544:	07800793          	li	a5,120
 548:	0cf68d63          	beq	a3,a5,622 <vprintf+0x1d0>
        putc(fd, '%');
 54c:	85d6                	mv	a1,s5
 54e:	855a                	mv	a0,s6
 550:	e49ff0ef          	jal	ra,398 <putc>
        putc(fd, c0);
 554:	85ca                	mv	a1,s2
 556:	855a                	mv	a0,s6
 558:	e41ff0ef          	jal	ra,398 <putc>
      state = 0;
 55c:	4981                	li	s3,0
 55e:	b7b9                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 560:	008b8913          	addi	s2,s7,8
 564:	4685                	li	a3,1
 566:	4629                	li	a2,10
 568:	000bb583          	ld	a1,0(s7)
 56c:	855a                	mv	a0,s6
 56e:	e49ff0ef          	jal	ra,3b6 <printint>
        i += 1;
 572:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 574:	8bca                	mv	s7,s2
      state = 0;
 576:	4981                	li	s3,0
        i += 1;
 578:	bf15                	j	4ac <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 57a:	03860563          	beq	a2,s8,5a4 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 57e:	07b60963          	beq	a2,s11,5f0 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 582:	07800793          	li	a5,120
 586:	fcf613e3          	bne	a2,a5,54c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 58a:	008b8913          	addi	s2,s7,8
 58e:	4681                	li	a3,0
 590:	4641                	li	a2,16
 592:	000bb583          	ld	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	e1fff0ef          	jal	ra,3b6 <printint>
        i += 2;
 59c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 59e:	8bca                	mv	s7,s2
      state = 0;
 5a0:	4981                	li	s3,0
        i += 2;
 5a2:	b729                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a4:	008b8913          	addi	s2,s7,8
 5a8:	4685                	li	a3,1
 5aa:	4629                	li	a2,10
 5ac:	000bb583          	ld	a1,0(s7)
 5b0:	855a                	mv	a0,s6
 5b2:	e05ff0ef          	jal	ra,3b6 <printint>
        i += 2;
 5b6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b8:	8bca                	mv	s7,s2
      state = 0;
 5ba:	4981                	li	s3,0
        i += 2;
 5bc:	bdc5                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5be:	008b8913          	addi	s2,s7,8
 5c2:	4681                	li	a3,0
 5c4:	4629                	li	a2,10
 5c6:	000be583          	lwu	a1,0(s7)
 5ca:	855a                	mv	a0,s6
 5cc:	debff0ef          	jal	ra,3b6 <printint>
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	bde1                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4629                	li	a2,10
 5de:	000bb583          	ld	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	dd3ff0ef          	jal	ra,3b6 <printint>
        i += 1;
 5e8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
        i += 1;
 5ee:	bd7d                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	008b8913          	addi	s2,s7,8
 5f4:	4681                	li	a3,0
 5f6:	4629                	li	a2,10
 5f8:	000bb583          	ld	a1,0(s7)
 5fc:	855a                	mv	a0,s6
 5fe:	db9ff0ef          	jal	ra,3b6 <printint>
        i += 2;
 602:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 604:	8bca                	mv	s7,s2
      state = 0;
 606:	4981                	li	s3,0
        i += 2;
 608:	b555                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 60a:	008b8913          	addi	s2,s7,8
 60e:	4681                	li	a3,0
 610:	4641                	li	a2,16
 612:	000be583          	lwu	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	d9fff0ef          	jal	ra,3b6 <printint>
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	b571                	j	4ac <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4641                	li	a2,16
 62a:	000bb583          	ld	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	d87ff0ef          	jal	ra,3b6 <printint>
        i += 1;
 634:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
        i += 1;
 63a:	bd8d                	j	4ac <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 63c:	008b8793          	addi	a5,s7,8
 640:	f8f43423          	sd	a5,-120(s0)
 644:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 648:	03000593          	li	a1,48
 64c:	855a                	mv	a0,s6
 64e:	d4bff0ef          	jal	ra,398 <putc>
  putc(fd, 'x');
 652:	07800593          	li	a1,120
 656:	855a                	mv	a0,s6
 658:	d41ff0ef          	jal	ra,398 <putc>
 65c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65e:	03c9d793          	srli	a5,s3,0x3c
 662:	97e6                	add	a5,a5,s9
 664:	0007c583          	lbu	a1,0(a5)
 668:	855a                	mv	a0,s6
 66a:	d2fff0ef          	jal	ra,398 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66e:	0992                	slli	s3,s3,0x4
 670:	397d                	addiw	s2,s2,-1
 672:	fe0916e3          	bnez	s2,65e <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 676:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd05                	j	4ac <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 67e:	008b8913          	addi	s2,s7,8
 682:	000bc583          	lbu	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	d11ff0ef          	jal	ra,398 <putc>
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
 690:	bd31                	j	4ac <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 692:	008b8993          	addi	s3,s7,8
 696:	000bb903          	ld	s2,0(s7)
 69a:	00090f63          	beqz	s2,6b8 <vprintf+0x266>
        for(; *s; s++)
 69e:	00094583          	lbu	a1,0(s2)
 6a2:	c195                	beqz	a1,6c6 <vprintf+0x274>
          putc(fd, *s);
 6a4:	855a                	mv	a0,s6
 6a6:	cf3ff0ef          	jal	ra,398 <putc>
        for(; *s; s++)
 6aa:	0905                	addi	s2,s2,1
 6ac:	00094583          	lbu	a1,0(s2)
 6b0:	f9f5                	bnez	a1,6a4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6b2:	8bce                	mv	s7,s3
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	bbdd                	j	4ac <vprintf+0x5a>
          s = "(null)";
 6b8:	00000917          	auipc	s2,0x0
 6bc:	1f890913          	addi	s2,s2,504 # 8b0 <malloc+0xe8>
        for(; *s; s++)
 6c0:	02800593          	li	a1,40
 6c4:	b7c5                	j	6a4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6c6:	8bce                	mv	s7,s3
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b3cd                	j	4ac <vprintf+0x5a>
    }
  }
}
 6cc:	70e6                	ld	ra,120(sp)
 6ce:	7446                	ld	s0,112(sp)
 6d0:	74a6                	ld	s1,104(sp)
 6d2:	7906                	ld	s2,96(sp)
 6d4:	69e6                	ld	s3,88(sp)
 6d6:	6a46                	ld	s4,80(sp)
 6d8:	6aa6                	ld	s5,72(sp)
 6da:	6b06                	ld	s6,64(sp)
 6dc:	7be2                	ld	s7,56(sp)
 6de:	7c42                	ld	s8,48(sp)
 6e0:	7ca2                	ld	s9,40(sp)
 6e2:	7d02                	ld	s10,32(sp)
 6e4:	6de2                	ld	s11,24(sp)
 6e6:	6109                	addi	sp,sp,128
 6e8:	8082                	ret

00000000000006ea <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ea:	715d                	addi	sp,sp,-80
 6ec:	ec06                	sd	ra,24(sp)
 6ee:	e822                	sd	s0,16(sp)
 6f0:	1000                	addi	s0,sp,32
 6f2:	e010                	sd	a2,0(s0)
 6f4:	e414                	sd	a3,8(s0)
 6f6:	e818                	sd	a4,16(s0)
 6f8:	ec1c                	sd	a5,24(s0)
 6fa:	03043023          	sd	a6,32(s0)
 6fe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 702:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 706:	8622                	mv	a2,s0
 708:	d4bff0ef          	jal	ra,452 <vprintf>
}
 70c:	60e2                	ld	ra,24(sp)
 70e:	6442                	ld	s0,16(sp)
 710:	6161                	addi	sp,sp,80
 712:	8082                	ret

0000000000000714 <printf>:

void
printf(const char *fmt, ...)
{
 714:	711d                	addi	sp,sp,-96
 716:	ec06                	sd	ra,24(sp)
 718:	e822                	sd	s0,16(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	e40c                	sd	a1,8(s0)
 71e:	e810                	sd	a2,16(s0)
 720:	ec14                	sd	a3,24(s0)
 722:	f018                	sd	a4,32(s0)
 724:	f41c                	sd	a5,40(s0)
 726:	03043823          	sd	a6,48(s0)
 72a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72e:	00840613          	addi	a2,s0,8
 732:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 736:	85aa                	mv	a1,a0
 738:	4505                	li	a0,1
 73a:	d19ff0ef          	jal	ra,452 <vprintf>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6125                	addi	sp,sp,96
 744:	8082                	ret

0000000000000746 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 746:	1141                	addi	sp,sp,-16
 748:	e422                	sd	s0,8(sp)
 74a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 750:	00001797          	auipc	a5,0x1
 754:	8b07b783          	ld	a5,-1872(a5) # 1000 <freep>
 758:	a02d                	j	782 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 75a:	4618                	lw	a4,8(a2)
 75c:	9f2d                	addw	a4,a4,a1
 75e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 762:	6398                	ld	a4,0(a5)
 764:	6310                	ld	a2,0(a4)
 766:	a83d                	j	7a4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 768:	ff852703          	lw	a4,-8(a0)
 76c:	9f31                	addw	a4,a4,a2
 76e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 770:	ff053683          	ld	a3,-16(a0)
 774:	a091                	j	7b8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 776:	6398                	ld	a4,0(a5)
 778:	00e7e463          	bltu	a5,a4,780 <free+0x3a>
 77c:	00e6ea63          	bltu	a3,a4,790 <free+0x4a>
{
 780:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 782:	fed7fae3          	bgeu	a5,a3,776 <free+0x30>
 786:	6398                	ld	a4,0(a5)
 788:	00e6e463          	bltu	a3,a4,790 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78c:	fee7eae3          	bltu	a5,a4,780 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 790:	ff852583          	lw	a1,-8(a0)
 794:	6390                	ld	a2,0(a5)
 796:	02059813          	slli	a6,a1,0x20
 79a:	01c85713          	srli	a4,a6,0x1c
 79e:	9736                	add	a4,a4,a3
 7a0:	fae60de3          	beq	a2,a4,75a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a8:	4790                	lw	a2,8(a5)
 7aa:	02061593          	slli	a1,a2,0x20
 7ae:	01c5d713          	srli	a4,a1,0x1c
 7b2:	973e                	add	a4,a4,a5
 7b4:	fae68ae3          	beq	a3,a4,768 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ba:	00001717          	auipc	a4,0x1
 7be:	84f73323          	sd	a5,-1978(a4) # 1000 <freep>
}
 7c2:	6422                	ld	s0,8(sp)
 7c4:	0141                	addi	sp,sp,16
 7c6:	8082                	ret

00000000000007c8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c8:	7139                	addi	sp,sp,-64
 7ca:	fc06                	sd	ra,56(sp)
 7cc:	f822                	sd	s0,48(sp)
 7ce:	f426                	sd	s1,40(sp)
 7d0:	f04a                	sd	s2,32(sp)
 7d2:	ec4e                	sd	s3,24(sp)
 7d4:	e852                	sd	s4,16(sp)
 7d6:	e456                	sd	s5,8(sp)
 7d8:	e05a                	sd	s6,0(sp)
 7da:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7dc:	02051493          	slli	s1,a0,0x20
 7e0:	9081                	srli	s1,s1,0x20
 7e2:	04bd                	addi	s1,s1,15
 7e4:	8091                	srli	s1,s1,0x4
 7e6:	0014899b          	addiw	s3,s1,1
 7ea:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ec:	00001517          	auipc	a0,0x1
 7f0:	81453503          	ld	a0,-2028(a0) # 1000 <freep>
 7f4:	c515                	beqz	a0,820 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f8:	4798                	lw	a4,8(a5)
 7fa:	02977f63          	bgeu	a4,s1,838 <malloc+0x70>
 7fe:	8a4e                	mv	s4,s3
 800:	0009871b          	sext.w	a4,s3
 804:	6685                	lui	a3,0x1
 806:	00d77363          	bgeu	a4,a3,80c <malloc+0x44>
 80a:	6a05                	lui	s4,0x1
 80c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 810:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 814:	00000917          	auipc	s2,0x0
 818:	7ec90913          	addi	s2,s2,2028 # 1000 <freep>
  if(p == SBRK_ERROR)
 81c:	5afd                	li	s5,-1
 81e:	a885                	j	88e <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 820:	00000797          	auipc	a5,0x0
 824:	7f078793          	addi	a5,a5,2032 # 1010 <base>
 828:	00000717          	auipc	a4,0x0
 82c:	7cf73c23          	sd	a5,2008(a4) # 1000 <freep>
 830:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 832:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 836:	b7e1                	j	7fe <malloc+0x36>
      if(p->s.size == nunits)
 838:	02e48c63          	beq	s1,a4,870 <malloc+0xa8>
        p->s.size -= nunits;
 83c:	4137073b          	subw	a4,a4,s3
 840:	c798                	sw	a4,8(a5)
        p += p->s.size;
 842:	02071693          	slli	a3,a4,0x20
 846:	01c6d713          	srli	a4,a3,0x1c
 84a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 850:	00000717          	auipc	a4,0x0
 854:	7aa73823          	sd	a0,1968(a4) # 1000 <freep>
      return (void*)(p + 1);
 858:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
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
 874:	bff1                	j	850 <malloc+0x88>
  hp->s.size = nu;
 876:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 87a:	0541                	addi	a0,a0,16
 87c:	ecbff0ef          	jal	ra,746 <free>
  return freep;
 880:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 884:	dd61                	beqz	a0,85c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 886:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 888:	4798                	lw	a4,8(a5)
 88a:	fa9777e3          	bgeu	a4,s1,838 <malloc+0x70>
    if(p == freep)
 88e:	00093703          	ld	a4,0(s2)
 892:	853e                	mv	a0,a5
 894:	fef719e3          	bne	a4,a5,886 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 898:	8552                	mv	a0,s4
 89a:	9ebff0ef          	jal	ra,284 <sbrk>
  if(p == SBRK_ERROR)
 89e:	fd551ce3          	bne	a0,s5,876 <malloc+0xae>
        return 0;
 8a2:	4501                	li	a0,0
 8a4:	bf65                	j	85c <malloc+0x94>
