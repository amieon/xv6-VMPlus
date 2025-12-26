
user/_kill：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7d763          	bge	a5,a0,3c <main+0x3c>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	19a000ef          	jal	ra,1c2 <atoi>
  2c:	2e8000ef          	jal	ra,314 <kill>
  for(i=1; i<argc; i++)
  30:	04a1                	addi	s1,s1,8
  32:	ff249ae3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  36:	4501                	li	a0,0
  38:	2ac000ef          	jal	ra,2e4 <exit>
    fprintf(2, "usage: kill pid...\n");
  3c:	00001597          	auipc	a1,0x1
  40:	86458593          	addi	a1,a1,-1948 # 8a0 <malloc+0xec>
  44:	4509                	li	a0,2
  46:	690000ef          	jal	ra,6d6 <fprintf>
    exit(1);
  4a:	4505                	li	a0,1
  4c:	298000ef          	jal	ra,2e4 <exit>

0000000000000050 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  58:	fa9ff0ef          	jal	ra,0 <main>
  exit(r);
  5c:	288000ef          	jal	ra,2e4 <exit>

0000000000000060 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	87aa                	mv	a5,a0
  68:	0585                	addi	a1,a1,1
  6a:	0785                	addi	a5,a5,1
  6c:	fff5c703          	lbu	a4,-1(a1)
  70:	fee78fa3          	sb	a4,-1(a5)
  74:	fb75                	bnez	a4,68 <strcpy+0x8>
    ;
  return os;
}
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	cb91                	beqz	a5,9a <strcmp+0x1e>
  88:	0005c703          	lbu	a4,0(a1)
  8c:	00f71763          	bne	a4,a5,9a <strcmp+0x1e>
    p++, q++;
  90:	0505                	addi	a0,a0,1
  92:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  94:	00054783          	lbu	a5,0(a0)
  98:	fbe5                	bnez	a5,88 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9a:	0005c503          	lbu	a0,0(a1)
}
  9e:	40a7853b          	subw	a0,a5,a0
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strlen>:

uint
strlen(const char *s)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cf91                	beqz	a5,ce <strlen+0x26>
  b4:	0505                	addi	a0,a0,1
  b6:	87aa                	mv	a5,a0
  b8:	4685                	li	a3,1
  ba:	9e89                	subw	a3,a3,a0
  bc:	00f6853b          	addw	a0,a3,a5
  c0:	0785                	addi	a5,a5,1
  c2:	fff7c703          	lbu	a4,-1(a5)
  c6:	fb7d                	bnez	a4,bc <strlen+0x14>
    ;
  return n;
}
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
  for(n = 0; s[n]; n++)
  ce:	4501                	li	a0,0
  d0:	bfe5                	j	c8 <strlen+0x20>

00000000000000d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d8:	ca19                	beqz	a2,ee <memset+0x1c>
  da:	87aa                	mv	a5,a0
  dc:	1602                	slli	a2,a2,0x20
  de:	9201                	srli	a2,a2,0x20
  e0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e8:	0785                	addi	a5,a5,1
  ea:	fee79de3          	bne	a5,a4,e4 <memset+0x12>
  }
  return dst;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strchr>:

char*
strchr(const char *s, char c)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb99                	beqz	a5,114 <strchr+0x20>
    if(*s == c)
 100:	00f58763          	beq	a1,a5,10e <strchr+0x1a>
  for(; *s; s++)
 104:	0505                	addi	a0,a0,1
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbfd                	bnez	a5,100 <strchr+0xc>
      return (char*)s;
  return 0;
 10c:	4501                	li	a0,0
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
  return 0;
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strchr+0x1a>

0000000000000118 <gets>:

char*
gets(char *buf, int max)
{
 118:	711d                	addi	sp,sp,-96
 11a:	ec86                	sd	ra,88(sp)
 11c:	e8a2                	sd	s0,80(sp)
 11e:	e4a6                	sd	s1,72(sp)
 120:	e0ca                	sd	s2,64(sp)
 122:	fc4e                	sd	s3,56(sp)
 124:	f852                	sd	s4,48(sp)
 126:	f456                	sd	s5,40(sp)
 128:	f05a                	sd	s6,32(sp)
 12a:	ec5e                	sd	s7,24(sp)
 12c:	1080                	addi	s0,sp,96
 12e:	8baa                	mv	s7,a0
 130:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 132:	892a                	mv	s2,a0
 134:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 136:	4aa9                	li	s5,10
 138:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13a:	89a6                	mv	s3,s1
 13c:	2485                	addiw	s1,s1,1
 13e:	0344d663          	bge	s1,s4,16a <gets+0x52>
    cc = read(0, &c, 1);
 142:	4605                	li	a2,1
 144:	faf40593          	addi	a1,s0,-81
 148:	4501                	li	a0,0
 14a:	1b2000ef          	jal	ra,2fc <read>
    if(cc < 1)
 14e:	00a05e63          	blez	a0,16a <gets+0x52>
    buf[i++] = c;
 152:	faf44783          	lbu	a5,-81(s0)
 156:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15a:	01578763          	beq	a5,s5,168 <gets+0x50>
 15e:	0905                	addi	s2,s2,1
 160:	fd679de3          	bne	a5,s6,13a <gets+0x22>
  for(i=0; i+1 < max; ){
 164:	89a6                	mv	s3,s1
 166:	a011                	j	16a <gets+0x52>
 168:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16a:	99de                	add	s3,s3,s7
 16c:	00098023          	sb	zero,0(s3)
  return buf;
}
 170:	855e                	mv	a0,s7
 172:	60e6                	ld	ra,88(sp)
 174:	6446                	ld	s0,80(sp)
 176:	64a6                	ld	s1,72(sp)
 178:	6906                	ld	s2,64(sp)
 17a:	79e2                	ld	s3,56(sp)
 17c:	7a42                	ld	s4,48(sp)
 17e:	7aa2                	ld	s5,40(sp)
 180:	7b02                	ld	s6,32(sp)
 182:	6be2                	ld	s7,24(sp)
 184:	6125                	addi	sp,sp,96
 186:	8082                	ret

0000000000000188 <stat>:

int
stat(const char *n, struct stat *st)
{
 188:	1101                	addi	sp,sp,-32
 18a:	ec06                	sd	ra,24(sp)
 18c:	e822                	sd	s0,16(sp)
 18e:	e426                	sd	s1,8(sp)
 190:	e04a                	sd	s2,0(sp)
 192:	1000                	addi	s0,sp,32
 194:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 196:	4581                	li	a1,0
 198:	18c000ef          	jal	ra,324 <open>
  if(fd < 0)
 19c:	02054163          	bltz	a0,1be <stat+0x36>
 1a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a2:	85ca                	mv	a1,s2
 1a4:	198000ef          	jal	ra,33c <fstat>
 1a8:	892a                	mv	s2,a0
  close(fd);
 1aa:	8526                	mv	a0,s1
 1ac:	160000ef          	jal	ra,30c <close>
  return r;
}
 1b0:	854a                	mv	a0,s2
 1b2:	60e2                	ld	ra,24(sp)
 1b4:	6442                	ld	s0,16(sp)
 1b6:	64a2                	ld	s1,8(sp)
 1b8:	6902                	ld	s2,0(sp)
 1ba:	6105                	addi	sp,sp,32
 1bc:	8082                	ret
    return -1;
 1be:	597d                	li	s2,-1
 1c0:	bfc5                	j	1b0 <stat+0x28>

00000000000001c2 <atoi>:

int
atoi(const char *s)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c8:	00054683          	lbu	a3,0(a0)
 1cc:	fd06879b          	addiw	a5,a3,-48
 1d0:	0ff7f793          	zext.b	a5,a5
 1d4:	4625                	li	a2,9
 1d6:	02f66863          	bltu	a2,a5,206 <atoi+0x44>
 1da:	872a                	mv	a4,a0
  n = 0;
 1dc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1de:	0705                	addi	a4,a4,1
 1e0:	0025179b          	slliw	a5,a0,0x2
 1e4:	9fa9                	addw	a5,a5,a0
 1e6:	0017979b          	slliw	a5,a5,0x1
 1ea:	9fb5                	addw	a5,a5,a3
 1ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f0:	00074683          	lbu	a3,0(a4)
 1f4:	fd06879b          	addiw	a5,a3,-48
 1f8:	0ff7f793          	zext.b	a5,a5
 1fc:	fef671e3          	bgeu	a2,a5,1de <atoi+0x1c>
  return n;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
  n = 0;
 206:	4501                	li	a0,0
 208:	bfe5                	j	200 <atoi+0x3e>

000000000000020a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 210:	02b57463          	bgeu	a0,a1,238 <memmove+0x2e>
    while(n-- > 0)
 214:	00c05f63          	blez	a2,232 <memmove+0x28>
 218:	1602                	slli	a2,a2,0x20
 21a:	9201                	srli	a2,a2,0x20
 21c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 220:	872a                	mv	a4,a0
      *dst++ = *src++;
 222:	0585                	addi	a1,a1,1
 224:	0705                	addi	a4,a4,1
 226:	fff5c683          	lbu	a3,-1(a1)
 22a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22e:	fee79ae3          	bne	a5,a4,222 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
    dst += n;
 238:	00c50733          	add	a4,a0,a2
    src += n;
 23c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 23e:	fec05ae3          	blez	a2,232 <memmove+0x28>
 242:	fff6079b          	addiw	a5,a2,-1
 246:	1782                	slli	a5,a5,0x20
 248:	9381                	srli	a5,a5,0x20
 24a:	fff7c793          	not	a5,a5
 24e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 250:	15fd                	addi	a1,a1,-1
 252:	177d                	addi	a4,a4,-1
 254:	0005c683          	lbu	a3,0(a1)
 258:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25c:	fee79ae3          	bne	a5,a4,250 <memmove+0x46>
 260:	bfc9                	j	232 <memmove+0x28>

0000000000000262 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 268:	ca05                	beqz	a2,298 <memcmp+0x36>
 26a:	fff6069b          	addiw	a3,a2,-1
 26e:	1682                	slli	a3,a3,0x20
 270:	9281                	srli	a3,a3,0x20
 272:	0685                	addi	a3,a3,1
 274:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 276:	00054783          	lbu	a5,0(a0)
 27a:	0005c703          	lbu	a4,0(a1)
 27e:	00e79863          	bne	a5,a4,28e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 282:	0505                	addi	a0,a0,1
    p2++;
 284:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 286:	fed518e3          	bne	a0,a3,276 <memcmp+0x14>
  }
  return 0;
 28a:	4501                	li	a0,0
 28c:	a019                	j	292 <memcmp+0x30>
      return *p1 - *p2;
 28e:	40e7853b          	subw	a0,a5,a4
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
  return 0;
 298:	4501                	li	a0,0
 29a:	bfe5                	j	292 <memcmp+0x30>

000000000000029c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e406                	sd	ra,8(sp)
 2a0:	e022                	sd	s0,0(sp)
 2a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a4:	f67ff0ef          	jal	ra,20a <memmove>
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret

00000000000002b0 <sbrk>:

char *
sbrk(int n) {
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e406                	sd	ra,8(sp)
 2b4:	e022                	sd	s0,0(sp)
 2b6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2b8:	4585                	li	a1,1
 2ba:	0b2000ef          	jal	ra,36c <sys_sbrk>
}
 2be:	60a2                	ld	ra,8(sp)
 2c0:	6402                	ld	s0,0(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <sbrklazy>:

char *
sbrklazy(int n) {
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2ce:	4589                	li	a1,2
 2d0:	09c000ef          	jal	ra,36c <sys_sbrk>
}
 2d4:	60a2                	ld	ra,8(sp)
 2d6:	6402                	ld	s0,0(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret

00000000000002dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2dc:	4885                	li	a7,1
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e4:	4889                	li	a7,2
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ec:	488d                	li	a7,3
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f4:	4891                	li	a7,4
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <read>:
.global read
read:
 li a7, SYS_read
 2fc:	4895                	li	a7,5
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <write>:
.global write
write:
 li a7, SYS_write
 304:	48c1                	li	a7,16
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <close>:
.global close
close:
 li a7, SYS_close
 30c:	48d5                	li	a7,21
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <kill>:
.global kill
kill:
 li a7, SYS_kill
 314:	4899                	li	a7,6
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <exec>:
.global exec
exec:
 li a7, SYS_exec
 31c:	489d                	li	a7,7
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <open>:
.global open
open:
 li a7, SYS_open
 324:	48bd                	li	a7,15
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32c:	48c5                	li	a7,17
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 334:	48c9                	li	a7,18
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33c:	48a1                	li	a7,8
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <link>:
.global link
link:
 li a7, SYS_link
 344:	48cd                	li	a7,19
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34c:	48d1                	li	a7,20
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 354:	48a5                	li	a7,9
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <dup>:
.global dup
dup:
 li a7, SYS_dup
 35c:	48a9                	li	a7,10
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 364:	48ad                	li	a7,11
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 36c:	48b1                	li	a7,12
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <pause>:
.global pause
pause:
 li a7, SYS_pause
 374:	48b5                	li	a7,13
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37c:	48b9                	li	a7,14
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 384:	1101                	addi	sp,sp,-32
 386:	ec06                	sd	ra,24(sp)
 388:	e822                	sd	s0,16(sp)
 38a:	1000                	addi	s0,sp,32
 38c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 390:	4605                	li	a2,1
 392:	fef40593          	addi	a1,s0,-17
 396:	f6fff0ef          	jal	ra,304 <write>
}
 39a:	60e2                	ld	ra,24(sp)
 39c:	6442                	ld	s0,16(sp)
 39e:	6105                	addi	sp,sp,32
 3a0:	8082                	ret

00000000000003a2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3a2:	715d                	addi	sp,sp,-80
 3a4:	e486                	sd	ra,72(sp)
 3a6:	e0a2                	sd	s0,64(sp)
 3a8:	fc26                	sd	s1,56(sp)
 3aa:	f84a                	sd	s2,48(sp)
 3ac:	f44e                	sd	s3,40(sp)
 3ae:	0880                	addi	s0,sp,80
 3b0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3b2:	c299                	beqz	a3,3b8 <printint+0x16>
 3b4:	0805c163          	bltz	a1,436 <printint+0x94>
  neg = 0;
 3b8:	4881                	li	a7,0
 3ba:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3be:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3c0:	00000517          	auipc	a0,0x0
 3c4:	50050513          	addi	a0,a0,1280 # 8c0 <digits>
 3c8:	883e                	mv	a6,a5
 3ca:	2785                	addiw	a5,a5,1
 3cc:	02c5f733          	remu	a4,a1,a2
 3d0:	972a                	add	a4,a4,a0
 3d2:	00074703          	lbu	a4,0(a4)
 3d6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3da:	872e                	mv	a4,a1
 3dc:	02c5d5b3          	divu	a1,a1,a2
 3e0:	0685                	addi	a3,a3,1
 3e2:	fec773e3          	bgeu	a4,a2,3c8 <printint+0x26>
  if(neg)
 3e6:	00088b63          	beqz	a7,3fc <printint+0x5a>
    buf[i++] = '-';
 3ea:	fd078793          	addi	a5,a5,-48
 3ee:	97a2                	add	a5,a5,s0
 3f0:	02d00713          	li	a4,45
 3f4:	fee78423          	sb	a4,-24(a5)
 3f8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3fc:	02f05663          	blez	a5,428 <printint+0x86>
 400:	fb840713          	addi	a4,s0,-72
 404:	00f704b3          	add	s1,a4,a5
 408:	fff70993          	addi	s3,a4,-1
 40c:	99be                	add	s3,s3,a5
 40e:	37fd                	addiw	a5,a5,-1
 410:	1782                	slli	a5,a5,0x20
 412:	9381                	srli	a5,a5,0x20
 414:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 418:	fff4c583          	lbu	a1,-1(s1)
 41c:	854a                	mv	a0,s2
 41e:	f67ff0ef          	jal	ra,384 <putc>
  while(--i >= 0)
 422:	14fd                	addi	s1,s1,-1
 424:	ff349ae3          	bne	s1,s3,418 <printint+0x76>
}
 428:	60a6                	ld	ra,72(sp)
 42a:	6406                	ld	s0,64(sp)
 42c:	74e2                	ld	s1,56(sp)
 42e:	7942                	ld	s2,48(sp)
 430:	79a2                	ld	s3,40(sp)
 432:	6161                	addi	sp,sp,80
 434:	8082                	ret
    x = -xx;
 436:	40b005b3          	neg	a1,a1
    neg = 1;
 43a:	4885                	li	a7,1
    x = -xx;
 43c:	bfbd                	j	3ba <printint+0x18>

000000000000043e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43e:	7119                	addi	sp,sp,-128
 440:	fc86                	sd	ra,120(sp)
 442:	f8a2                	sd	s0,112(sp)
 444:	f4a6                	sd	s1,104(sp)
 446:	f0ca                	sd	s2,96(sp)
 448:	ecce                	sd	s3,88(sp)
 44a:	e8d2                	sd	s4,80(sp)
 44c:	e4d6                	sd	s5,72(sp)
 44e:	e0da                	sd	s6,64(sp)
 450:	fc5e                	sd	s7,56(sp)
 452:	f862                	sd	s8,48(sp)
 454:	f466                	sd	s9,40(sp)
 456:	f06a                	sd	s10,32(sp)
 458:	ec6e                	sd	s11,24(sp)
 45a:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 45c:	0005c903          	lbu	s2,0(a1)
 460:	24090c63          	beqz	s2,6b8 <vprintf+0x27a>
 464:	8b2a                	mv	s6,a0
 466:	8a2e                	mv	s4,a1
 468:	8bb2                	mv	s7,a2
  state = 0;
 46a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 46c:	4481                	li	s1,0
 46e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 470:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 474:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 478:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 47c:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 480:	00000c97          	auipc	s9,0x0
 484:	440c8c93          	addi	s9,s9,1088 # 8c0 <digits>
 488:	a005                	j	4a8 <vprintf+0x6a>
        putc(fd, c0);
 48a:	85ca                	mv	a1,s2
 48c:	855a                	mv	a0,s6
 48e:	ef7ff0ef          	jal	ra,384 <putc>
 492:	a019                	j	498 <vprintf+0x5a>
    } else if(state == '%'){
 494:	03598263          	beq	s3,s5,4b8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 498:	2485                	addiw	s1,s1,1
 49a:	8726                	mv	a4,s1
 49c:	009a07b3          	add	a5,s4,s1
 4a0:	0007c903          	lbu	s2,0(a5)
 4a4:	20090a63          	beqz	s2,6b8 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4a8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ac:	fe0994e3          	bnez	s3,494 <vprintf+0x56>
      if(c0 == '%'){
 4b0:	fd579de3          	bne	a5,s5,48a <vprintf+0x4c>
        state = '%';
 4b4:	89be                	mv	s3,a5
 4b6:	b7cd                	j	498 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4b8:	c3c1                	beqz	a5,538 <vprintf+0xfa>
 4ba:	00ea06b3          	add	a3,s4,a4
 4be:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4c2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4c4:	c681                	beqz	a3,4cc <vprintf+0x8e>
 4c6:	9752                	add	a4,a4,s4
 4c8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4cc:	03878e63          	beq	a5,s8,508 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 4d0:	05a78863          	beq	a5,s10,520 <vprintf+0xe2>
      } else if(c0 == 'u'){
 4d4:	0db78b63          	beq	a5,s11,5aa <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4d8:	07800713          	li	a4,120
 4dc:	10e78d63          	beq	a5,a4,5f6 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4e0:	07000713          	li	a4,112
 4e4:	14e78263          	beq	a5,a4,628 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4e8:	06300713          	li	a4,99
 4ec:	16e78f63          	beq	a5,a4,66a <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4f0:	07300713          	li	a4,115
 4f4:	18e78563          	beq	a5,a4,67e <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4f8:	05579063          	bne	a5,s5,538 <vprintf+0xfa>
        putc(fd, '%');
 4fc:	85d6                	mv	a1,s5
 4fe:	855a                	mv	a0,s6
 500:	e85ff0ef          	jal	ra,384 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 504:	4981                	li	s3,0
 506:	bf49                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 508:	008b8913          	addi	s2,s7,8
 50c:	4685                	li	a3,1
 50e:	4629                	li	a2,10
 510:	000ba583          	lw	a1,0(s7)
 514:	855a                	mv	a0,s6
 516:	e8dff0ef          	jal	ra,3a2 <printint>
 51a:	8bca                	mv	s7,s2
      state = 0;
 51c:	4981                	li	s3,0
 51e:	bfad                	j	498 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 520:	03868663          	beq	a3,s8,54c <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 524:	05a68163          	beq	a3,s10,566 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 528:	09b68d63          	beq	a3,s11,5c2 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 52c:	03a68f63          	beq	a3,s10,56a <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 530:	07800793          	li	a5,120
 534:	0cf68d63          	beq	a3,a5,60e <vprintf+0x1d0>
        putc(fd, '%');
 538:	85d6                	mv	a1,s5
 53a:	855a                	mv	a0,s6
 53c:	e49ff0ef          	jal	ra,384 <putc>
        putc(fd, c0);
 540:	85ca                	mv	a1,s2
 542:	855a                	mv	a0,s6
 544:	e41ff0ef          	jal	ra,384 <putc>
      state = 0;
 548:	4981                	li	s3,0
 54a:	b7b9                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 54c:	008b8913          	addi	s2,s7,8
 550:	4685                	li	a3,1
 552:	4629                	li	a2,10
 554:	000bb583          	ld	a1,0(s7)
 558:	855a                	mv	a0,s6
 55a:	e49ff0ef          	jal	ra,3a2 <printint>
        i += 1;
 55e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
        i += 1;
 564:	bf15                	j	498 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 566:	03860563          	beq	a2,s8,590 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 56a:	07b60963          	beq	a2,s11,5dc <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 56e:	07800793          	li	a5,120
 572:	fcf613e3          	bne	a2,a5,538 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 576:	008b8913          	addi	s2,s7,8
 57a:	4681                	li	a3,0
 57c:	4641                	li	a2,16
 57e:	000bb583          	ld	a1,0(s7)
 582:	855a                	mv	a0,s6
 584:	e1fff0ef          	jal	ra,3a2 <printint>
        i += 2;
 588:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 58a:	8bca                	mv	s7,s2
      state = 0;
 58c:	4981                	li	s3,0
        i += 2;
 58e:	b729                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 590:	008b8913          	addi	s2,s7,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000bb583          	ld	a1,0(s7)
 59c:	855a                	mv	a0,s6
 59e:	e05ff0ef          	jal	ra,3a2 <printint>
        i += 2;
 5a2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a4:	8bca                	mv	s7,s2
      state = 0;
 5a6:	4981                	li	s3,0
        i += 2;
 5a8:	bdc5                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5aa:	008b8913          	addi	s2,s7,8
 5ae:	4681                	li	a3,0
 5b0:	4629                	li	a2,10
 5b2:	000be583          	lwu	a1,0(s7)
 5b6:	855a                	mv	a0,s6
 5b8:	debff0ef          	jal	ra,3a2 <printint>
 5bc:	8bca                	mv	s7,s2
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bde1                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4681                	li	a3,0
 5c8:	4629                	li	a2,10
 5ca:	000bb583          	ld	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	dd3ff0ef          	jal	ra,3a2 <printint>
        i += 1;
 5d4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
        i += 1;
 5da:	bd7d                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5dc:	008b8913          	addi	s2,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4629                	li	a2,10
 5e4:	000bb583          	ld	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	db9ff0ef          	jal	ra,3a2 <printint>
        i += 2;
 5ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
        i += 2;
 5f4:	b555                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4641                	li	a2,16
 5fe:	000be583          	lwu	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	d9fff0ef          	jal	ra,3a2 <printint>
 608:	8bca                	mv	s7,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b571                	j	498 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 60e:	008b8913          	addi	s2,s7,8
 612:	4681                	li	a3,0
 614:	4641                	li	a2,16
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	d87ff0ef          	jal	ra,3a2 <printint>
        i += 1;
 620:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 1;
 626:	bd8d                	j	498 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 628:	008b8793          	addi	a5,s7,8
 62c:	f8f43423          	sd	a5,-120(s0)
 630:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 634:	03000593          	li	a1,48
 638:	855a                	mv	a0,s6
 63a:	d4bff0ef          	jal	ra,384 <putc>
  putc(fd, 'x');
 63e:	07800593          	li	a1,120
 642:	855a                	mv	a0,s6
 644:	d41ff0ef          	jal	ra,384 <putc>
 648:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64a:	03c9d793          	srli	a5,s3,0x3c
 64e:	97e6                	add	a5,a5,s9
 650:	0007c583          	lbu	a1,0(a5)
 654:	855a                	mv	a0,s6
 656:	d2fff0ef          	jal	ra,384 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 65a:	0992                	slli	s3,s3,0x4
 65c:	397d                	addiw	s2,s2,-1
 65e:	fe0916e3          	bnez	s2,64a <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 662:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 666:	4981                	li	s3,0
 668:	bd05                	j	498 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 66a:	008b8913          	addi	s2,s7,8
 66e:	000bc583          	lbu	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	d11ff0ef          	jal	ra,384 <putc>
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd31                	j	498 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 67e:	008b8993          	addi	s3,s7,8
 682:	000bb903          	ld	s2,0(s7)
 686:	00090f63          	beqz	s2,6a4 <vprintf+0x266>
        for(; *s; s++)
 68a:	00094583          	lbu	a1,0(s2)
 68e:	c195                	beqz	a1,6b2 <vprintf+0x274>
          putc(fd, *s);
 690:	855a                	mv	a0,s6
 692:	cf3ff0ef          	jal	ra,384 <putc>
        for(; *s; s++)
 696:	0905                	addi	s2,s2,1
 698:	00094583          	lbu	a1,0(s2)
 69c:	f9f5                	bnez	a1,690 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 69e:	8bce                	mv	s7,s3
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bbdd                	j	498 <vprintf+0x5a>
          s = "(null)";
 6a4:	00000917          	auipc	s2,0x0
 6a8:	21490913          	addi	s2,s2,532 # 8b8 <malloc+0x104>
        for(; *s; s++)
 6ac:	02800593          	li	a1,40
 6b0:	b7c5                	j	690 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6b2:	8bce                	mv	s7,s3
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b3cd                	j	498 <vprintf+0x5a>
    }
  }
}
 6b8:	70e6                	ld	ra,120(sp)
 6ba:	7446                	ld	s0,112(sp)
 6bc:	74a6                	ld	s1,104(sp)
 6be:	7906                	ld	s2,96(sp)
 6c0:	69e6                	ld	s3,88(sp)
 6c2:	6a46                	ld	s4,80(sp)
 6c4:	6aa6                	ld	s5,72(sp)
 6c6:	6b06                	ld	s6,64(sp)
 6c8:	7be2                	ld	s7,56(sp)
 6ca:	7c42                	ld	s8,48(sp)
 6cc:	7ca2                	ld	s9,40(sp)
 6ce:	7d02                	ld	s10,32(sp)
 6d0:	6de2                	ld	s11,24(sp)
 6d2:	6109                	addi	sp,sp,128
 6d4:	8082                	ret

00000000000006d6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d6:	715d                	addi	sp,sp,-80
 6d8:	ec06                	sd	ra,24(sp)
 6da:	e822                	sd	s0,16(sp)
 6dc:	1000                	addi	s0,sp,32
 6de:	e010                	sd	a2,0(s0)
 6e0:	e414                	sd	a3,8(s0)
 6e2:	e818                	sd	a4,16(s0)
 6e4:	ec1c                	sd	a5,24(s0)
 6e6:	03043023          	sd	a6,32(s0)
 6ea:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ee:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f2:	8622                	mv	a2,s0
 6f4:	d4bff0ef          	jal	ra,43e <vprintf>
}
 6f8:	60e2                	ld	ra,24(sp)
 6fa:	6442                	ld	s0,16(sp)
 6fc:	6161                	addi	sp,sp,80
 6fe:	8082                	ret

0000000000000700 <printf>:

void
printf(const char *fmt, ...)
{
 700:	711d                	addi	sp,sp,-96
 702:	ec06                	sd	ra,24(sp)
 704:	e822                	sd	s0,16(sp)
 706:	1000                	addi	s0,sp,32
 708:	e40c                	sd	a1,8(s0)
 70a:	e810                	sd	a2,16(s0)
 70c:	ec14                	sd	a3,24(s0)
 70e:	f018                	sd	a4,32(s0)
 710:	f41c                	sd	a5,40(s0)
 712:	03043823          	sd	a6,48(s0)
 716:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71a:	00840613          	addi	a2,s0,8
 71e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 722:	85aa                	mv	a1,a0
 724:	4505                	li	a0,1
 726:	d19ff0ef          	jal	ra,43e <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6125                	addi	sp,sp,96
 730:	8082                	ret

0000000000000732 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 732:	1141                	addi	sp,sp,-16
 734:	e422                	sd	s0,8(sp)
 736:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 738:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73c:	00001797          	auipc	a5,0x1
 740:	8c47b783          	ld	a5,-1852(a5) # 1000 <freep>
 744:	a02d                	j	76e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 746:	4618                	lw	a4,8(a2)
 748:	9f2d                	addw	a4,a4,a1
 74a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 74e:	6398                	ld	a4,0(a5)
 750:	6310                	ld	a2,0(a4)
 752:	a83d                	j	790 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 754:	ff852703          	lw	a4,-8(a0)
 758:	9f31                	addw	a4,a4,a2
 75a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 75c:	ff053683          	ld	a3,-16(a0)
 760:	a091                	j	7a4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 762:	6398                	ld	a4,0(a5)
 764:	00e7e463          	bltu	a5,a4,76c <free+0x3a>
 768:	00e6ea63          	bltu	a3,a4,77c <free+0x4a>
{
 76c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76e:	fed7fae3          	bgeu	a5,a3,762 <free+0x30>
 772:	6398                	ld	a4,0(a5)
 774:	00e6e463          	bltu	a3,a4,77c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 778:	fee7eae3          	bltu	a5,a4,76c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 77c:	ff852583          	lw	a1,-8(a0)
 780:	6390                	ld	a2,0(a5)
 782:	02059813          	slli	a6,a1,0x20
 786:	01c85713          	srli	a4,a6,0x1c
 78a:	9736                	add	a4,a4,a3
 78c:	fae60de3          	beq	a2,a4,746 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 790:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 794:	4790                	lw	a2,8(a5)
 796:	02061593          	slli	a1,a2,0x20
 79a:	01c5d713          	srli	a4,a1,0x1c
 79e:	973e                	add	a4,a4,a5
 7a0:	fae68ae3          	beq	a3,a4,754 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7a4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7a6:	00001717          	auipc	a4,0x1
 7aa:	84f73d23          	sd	a5,-1958(a4) # 1000 <freep>
}
 7ae:	6422                	ld	s0,8(sp)
 7b0:	0141                	addi	sp,sp,16
 7b2:	8082                	ret

00000000000007b4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b4:	7139                	addi	sp,sp,-64
 7b6:	fc06                	sd	ra,56(sp)
 7b8:	f822                	sd	s0,48(sp)
 7ba:	f426                	sd	s1,40(sp)
 7bc:	f04a                	sd	s2,32(sp)
 7be:	ec4e                	sd	s3,24(sp)
 7c0:	e852                	sd	s4,16(sp)
 7c2:	e456                	sd	s5,8(sp)
 7c4:	e05a                	sd	s6,0(sp)
 7c6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c8:	02051493          	slli	s1,a0,0x20
 7cc:	9081                	srli	s1,s1,0x20
 7ce:	04bd                	addi	s1,s1,15
 7d0:	8091                	srli	s1,s1,0x4
 7d2:	0014899b          	addiw	s3,s1,1
 7d6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7d8:	00001517          	auipc	a0,0x1
 7dc:	82853503          	ld	a0,-2008(a0) # 1000 <freep>
 7e0:	c515                	beqz	a0,80c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e4:	4798                	lw	a4,8(a5)
 7e6:	02977f63          	bgeu	a4,s1,824 <malloc+0x70>
 7ea:	8a4e                	mv	s4,s3
 7ec:	0009871b          	sext.w	a4,s3
 7f0:	6685                	lui	a3,0x1
 7f2:	00d77363          	bgeu	a4,a3,7f8 <malloc+0x44>
 7f6:	6a05                	lui	s4,0x1
 7f8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7fc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 800:	00001917          	auipc	s2,0x1
 804:	80090913          	addi	s2,s2,-2048 # 1000 <freep>
  if(p == SBRK_ERROR)
 808:	5afd                	li	s5,-1
 80a:	a885                	j	87a <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 80c:	00001797          	auipc	a5,0x1
 810:	80478793          	addi	a5,a5,-2044 # 1010 <base>
 814:	00000717          	auipc	a4,0x0
 818:	7ef73623          	sd	a5,2028(a4) # 1000 <freep>
 81c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 81e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 822:	b7e1                	j	7ea <malloc+0x36>
      if(p->s.size == nunits)
 824:	02e48c63          	beq	s1,a4,85c <malloc+0xa8>
        p->s.size -= nunits;
 828:	4137073b          	subw	a4,a4,s3
 82c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 82e:	02071693          	slli	a3,a4,0x20
 832:	01c6d713          	srli	a4,a3,0x1c
 836:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 838:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 83c:	00000717          	auipc	a4,0x0
 840:	7ca73223          	sd	a0,1988(a4) # 1000 <freep>
      return (void*)(p + 1);
 844:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 848:	70e2                	ld	ra,56(sp)
 84a:	7442                	ld	s0,48(sp)
 84c:	74a2                	ld	s1,40(sp)
 84e:	7902                	ld	s2,32(sp)
 850:	69e2                	ld	s3,24(sp)
 852:	6a42                	ld	s4,16(sp)
 854:	6aa2                	ld	s5,8(sp)
 856:	6b02                	ld	s6,0(sp)
 858:	6121                	addi	sp,sp,64
 85a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 85c:	6398                	ld	a4,0(a5)
 85e:	e118                	sd	a4,0(a0)
 860:	bff1                	j	83c <malloc+0x88>
  hp->s.size = nu;
 862:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 866:	0541                	addi	a0,a0,16
 868:	ecbff0ef          	jal	ra,732 <free>
  return freep;
 86c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 870:	dd61                	beqz	a0,848 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 872:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 874:	4798                	lw	a4,8(a5)
 876:	fa9777e3          	bgeu	a4,s1,824 <malloc+0x70>
    if(p == freep)
 87a:	00093703          	ld	a4,0(s2)
 87e:	853e                	mv	a0,a5
 880:	fef719e3          	bne	a4,a5,872 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 884:	8552                	mv	a0,s4
 886:	a2bff0ef          	jal	ra,2b0 <sbrk>
  if(p == SBRK_ERROR)
 88a:	fd551ce3          	bne	a0,s5,862 <malloc+0xae>
        return 0;
 88e:	4501                	li	a0,0
 890:	bf65                	j	848 <malloc+0x94>
