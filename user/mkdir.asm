
user/_mkdir：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  int i;

  if(argc < 2){
   e:	4785                	li	a5,1
  10:	02a7d563          	bge	a5,a0,3a <main+0x3a>
  14:	00858493          	addi	s1,a1,8
  18:	ffe5091b          	addiw	s2,a0,-2
  1c:	02091793          	slli	a5,s2,0x20
  20:	01d7d913          	srli	s2,a5,0x1d
  24:	05c1                	addi	a1,a1,16
  26:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  28:	6088                	ld	a0,0(s1)
  2a:	336000ef          	jal	ra,360 <mkdir>
  2e:	02054063          	bltz	a0,4e <main+0x4e>
  for(i = 1; i < argc; i++){
  32:	04a1                	addi	s1,s1,8
  34:	ff249ae3          	bne	s1,s2,28 <main+0x28>
  38:	a01d                	j	5e <main+0x5e>
    fprintf(2, "Usage: mkdir files...\n");
  3a:	00001597          	auipc	a1,0x1
  3e:	87658593          	addi	a1,a1,-1930 # 8b0 <malloc+0xe8>
  42:	4509                	li	a0,2
  44:	6a6000ef          	jal	ra,6ea <fprintf>
    exit(1);
  48:	4505                	li	a0,1
  4a:	2ae000ef          	jal	ra,2f8 <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  4e:	6090                	ld	a2,0(s1)
  50:	00001597          	auipc	a1,0x1
  54:	87858593          	addi	a1,a1,-1928 # 8c8 <malloc+0x100>
  58:	4509                	li	a0,2
  5a:	690000ef          	jal	ra,6ea <fprintf>
      break;
    }
  }

  exit(0);
  5e:	4501                	li	a0,0
  60:	298000ef          	jal	ra,2f8 <exit>

0000000000000064 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  6c:	f95ff0ef          	jal	ra,0 <main>
  exit(r);
  70:	288000ef          	jal	ra,2f8 <exit>

0000000000000074 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7a:	87aa                	mv	a5,a0
  7c:	0585                	addi	a1,a1,1
  7e:	0785                	addi	a5,a5,1
  80:	fff5c703          	lbu	a4,-1(a1)
  84:	fee78fa3          	sb	a4,-1(a5)
  88:	fb75                	bnez	a4,7c <strcpy+0x8>
    ;
  return os;
}
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret

0000000000000090 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  90:	1141                	addi	sp,sp,-16
  92:	e422                	sd	s0,8(sp)
  94:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  96:	00054783          	lbu	a5,0(a0)
  9a:	cb91                	beqz	a5,ae <strcmp+0x1e>
  9c:	0005c703          	lbu	a4,0(a1)
  a0:	00f71763          	bne	a4,a5,ae <strcmp+0x1e>
    p++, q++;
  a4:	0505                	addi	a0,a0,1
  a6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  a8:	00054783          	lbu	a5,0(a0)
  ac:	fbe5                	bnez	a5,9c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ae:	0005c503          	lbu	a0,0(a1)
}
  b2:	40a7853b          	subw	a0,a5,a0
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret

00000000000000bc <strlen>:

uint
strlen(const char *s)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	cf91                	beqz	a5,e2 <strlen+0x26>
  c8:	0505                	addi	a0,a0,1
  ca:	87aa                	mv	a5,a0
  cc:	4685                	li	a3,1
  ce:	9e89                	subw	a3,a3,a0
  d0:	00f6853b          	addw	a0,a3,a5
  d4:	0785                	addi	a5,a5,1
  d6:	fff7c703          	lbu	a4,-1(a5)
  da:	fb7d                	bnez	a4,d0 <strlen+0x14>
    ;
  return n;
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  for(n = 0; s[n]; n++)
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strlen+0x20>

00000000000000e6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ec:	ca19                	beqz	a2,102 <memset+0x1c>
  ee:	87aa                	mv	a5,a0
  f0:	1602                	slli	a2,a2,0x20
  f2:	9201                	srli	a2,a2,0x20
  f4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  f8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  fc:	0785                	addi	a5,a5,1
  fe:	fee79de3          	bne	a5,a4,f8 <memset+0x12>
  }
  return dst;
}
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strchr>:

char*
strchr(const char *s, char c)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cb99                	beqz	a5,128 <strchr+0x20>
    if(*s == c)
 114:	00f58763          	beq	a1,a5,122 <strchr+0x1a>
  for(; *s; s++)
 118:	0505                	addi	a0,a0,1
 11a:	00054783          	lbu	a5,0(a0)
 11e:	fbfd                	bnez	a5,114 <strchr+0xc>
      return (char*)s;
  return 0;
 120:	4501                	li	a0,0
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret
  return 0;
 128:	4501                	li	a0,0
 12a:	bfe5                	j	122 <strchr+0x1a>

000000000000012c <gets>:

char*
gets(char *buf, int max)
{
 12c:	711d                	addi	sp,sp,-96
 12e:	ec86                	sd	ra,88(sp)
 130:	e8a2                	sd	s0,80(sp)
 132:	e4a6                	sd	s1,72(sp)
 134:	e0ca                	sd	s2,64(sp)
 136:	fc4e                	sd	s3,56(sp)
 138:	f852                	sd	s4,48(sp)
 13a:	f456                	sd	s5,40(sp)
 13c:	f05a                	sd	s6,32(sp)
 13e:	ec5e                	sd	s7,24(sp)
 140:	1080                	addi	s0,sp,96
 142:	8baa                	mv	s7,a0
 144:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 146:	892a                	mv	s2,a0
 148:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 14a:	4aa9                	li	s5,10
 14c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 14e:	89a6                	mv	s3,s1
 150:	2485                	addiw	s1,s1,1
 152:	0344d663          	bge	s1,s4,17e <gets+0x52>
    cc = read(0, &c, 1);
 156:	4605                	li	a2,1
 158:	faf40593          	addi	a1,s0,-81
 15c:	4501                	li	a0,0
 15e:	1b2000ef          	jal	ra,310 <read>
    if(cc < 1)
 162:	00a05e63          	blez	a0,17e <gets+0x52>
    buf[i++] = c;
 166:	faf44783          	lbu	a5,-81(s0)
 16a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 16e:	01578763          	beq	a5,s5,17c <gets+0x50>
 172:	0905                	addi	s2,s2,1
 174:	fd679de3          	bne	a5,s6,14e <gets+0x22>
  for(i=0; i+1 < max; ){
 178:	89a6                	mv	s3,s1
 17a:	a011                	j	17e <gets+0x52>
 17c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 17e:	99de                	add	s3,s3,s7
 180:	00098023          	sb	zero,0(s3)
  return buf;
}
 184:	855e                	mv	a0,s7
 186:	60e6                	ld	ra,88(sp)
 188:	6446                	ld	s0,80(sp)
 18a:	64a6                	ld	s1,72(sp)
 18c:	6906                	ld	s2,64(sp)
 18e:	79e2                	ld	s3,56(sp)
 190:	7a42                	ld	s4,48(sp)
 192:	7aa2                	ld	s5,40(sp)
 194:	7b02                	ld	s6,32(sp)
 196:	6be2                	ld	s7,24(sp)
 198:	6125                	addi	sp,sp,96
 19a:	8082                	ret

000000000000019c <stat>:

int
stat(const char *n, struct stat *st)
{
 19c:	1101                	addi	sp,sp,-32
 19e:	ec06                	sd	ra,24(sp)
 1a0:	e822                	sd	s0,16(sp)
 1a2:	e426                	sd	s1,8(sp)
 1a4:	e04a                	sd	s2,0(sp)
 1a6:	1000                	addi	s0,sp,32
 1a8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1aa:	4581                	li	a1,0
 1ac:	18c000ef          	jal	ra,338 <open>
  if(fd < 0)
 1b0:	02054163          	bltz	a0,1d2 <stat+0x36>
 1b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b6:	85ca                	mv	a1,s2
 1b8:	198000ef          	jal	ra,350 <fstat>
 1bc:	892a                	mv	s2,a0
  close(fd);
 1be:	8526                	mv	a0,s1
 1c0:	160000ef          	jal	ra,320 <close>
  return r;
}
 1c4:	854a                	mv	a0,s2
 1c6:	60e2                	ld	ra,24(sp)
 1c8:	6442                	ld	s0,16(sp)
 1ca:	64a2                	ld	s1,8(sp)
 1cc:	6902                	ld	s2,0(sp)
 1ce:	6105                	addi	sp,sp,32
 1d0:	8082                	ret
    return -1;
 1d2:	597d                	li	s2,-1
 1d4:	bfc5                	j	1c4 <stat+0x28>

00000000000001d6 <atoi>:

int
atoi(const char *s)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1dc:	00054683          	lbu	a3,0(a0)
 1e0:	fd06879b          	addiw	a5,a3,-48
 1e4:	0ff7f793          	zext.b	a5,a5
 1e8:	4625                	li	a2,9
 1ea:	02f66863          	bltu	a2,a5,21a <atoi+0x44>
 1ee:	872a                	mv	a4,a0
  n = 0;
 1f0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1f2:	0705                	addi	a4,a4,1
 1f4:	0025179b          	slliw	a5,a0,0x2
 1f8:	9fa9                	addw	a5,a5,a0
 1fa:	0017979b          	slliw	a5,a5,0x1
 1fe:	9fb5                	addw	a5,a5,a3
 200:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 204:	00074683          	lbu	a3,0(a4)
 208:	fd06879b          	addiw	a5,a3,-48
 20c:	0ff7f793          	zext.b	a5,a5
 210:	fef671e3          	bgeu	a2,a5,1f2 <atoi+0x1c>
  return n;
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
  n = 0;
 21a:	4501                	li	a0,0
 21c:	bfe5                	j	214 <atoi+0x3e>

000000000000021e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 224:	02b57463          	bgeu	a0,a1,24c <memmove+0x2e>
    while(n-- > 0)
 228:	00c05f63          	blez	a2,246 <memmove+0x28>
 22c:	1602                	slli	a2,a2,0x20
 22e:	9201                	srli	a2,a2,0x20
 230:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 234:	872a                	mv	a4,a0
      *dst++ = *src++;
 236:	0585                	addi	a1,a1,1
 238:	0705                	addi	a4,a4,1
 23a:	fff5c683          	lbu	a3,-1(a1)
 23e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 242:	fee79ae3          	bne	a5,a4,236 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 246:	6422                	ld	s0,8(sp)
 248:	0141                	addi	sp,sp,16
 24a:	8082                	ret
    dst += n;
 24c:	00c50733          	add	a4,a0,a2
    src += n;
 250:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 252:	fec05ae3          	blez	a2,246 <memmove+0x28>
 256:	fff6079b          	addiw	a5,a2,-1
 25a:	1782                	slli	a5,a5,0x20
 25c:	9381                	srli	a5,a5,0x20
 25e:	fff7c793          	not	a5,a5
 262:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 264:	15fd                	addi	a1,a1,-1
 266:	177d                	addi	a4,a4,-1
 268:	0005c683          	lbu	a3,0(a1)
 26c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 270:	fee79ae3          	bne	a5,a4,264 <memmove+0x46>
 274:	bfc9                	j	246 <memmove+0x28>

0000000000000276 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 27c:	ca05                	beqz	a2,2ac <memcmp+0x36>
 27e:	fff6069b          	addiw	a3,a2,-1
 282:	1682                	slli	a3,a3,0x20
 284:	9281                	srli	a3,a3,0x20
 286:	0685                	addi	a3,a3,1
 288:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 28a:	00054783          	lbu	a5,0(a0)
 28e:	0005c703          	lbu	a4,0(a1)
 292:	00e79863          	bne	a5,a4,2a2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 296:	0505                	addi	a0,a0,1
    p2++;
 298:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29a:	fed518e3          	bne	a0,a3,28a <memcmp+0x14>
  }
  return 0;
 29e:	4501                	li	a0,0
 2a0:	a019                	j	2a6 <memcmp+0x30>
      return *p1 - *p2;
 2a2:	40e7853b          	subw	a0,a5,a4
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <memcmp+0x30>

00000000000002b0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e406                	sd	ra,8(sp)
 2b4:	e022                	sd	s0,0(sp)
 2b6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2b8:	f67ff0ef          	jal	ra,21e <memmove>
}
 2bc:	60a2                	ld	ra,8(sp)
 2be:	6402                	ld	s0,0(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <sbrk>:

char *
sbrk(int n) {
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2cc:	4585                	li	a1,1
 2ce:	0b2000ef          	jal	ra,380 <sys_sbrk>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <sbrklazy>:

char *
sbrklazy(int n) {
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2e2:	4589                	li	a1,2
 2e4:	09c000ef          	jal	ra,380 <sys_sbrk>
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f0:	4885                	li	a7,1
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f8:	4889                	li	a7,2
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <wait>:
.global wait
wait:
 li a7, SYS_wait
 300:	488d                	li	a7,3
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 308:	4891                	li	a7,4
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <read>:
.global read
read:
 li a7, SYS_read
 310:	4895                	li	a7,5
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <write>:
.global write
write:
 li a7, SYS_write
 318:	48c1                	li	a7,16
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <close>:
.global close
close:
 li a7, SYS_close
 320:	48d5                	li	a7,21
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <kill>:
.global kill
kill:
 li a7, SYS_kill
 328:	4899                	li	a7,6
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <exec>:
.global exec
exec:
 li a7, SYS_exec
 330:	489d                	li	a7,7
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <open>:
.global open
open:
 li a7, SYS_open
 338:	48bd                	li	a7,15
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 340:	48c5                	li	a7,17
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 348:	48c9                	li	a7,18
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 350:	48a1                	li	a7,8
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <link>:
.global link
link:
 li a7, SYS_link
 358:	48cd                	li	a7,19
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 360:	48d1                	li	a7,20
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 368:	48a5                	li	a7,9
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <dup>:
.global dup
dup:
 li a7, SYS_dup
 370:	48a9                	li	a7,10
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 378:	48ad                	li	a7,11
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 380:	48b1                	li	a7,12
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <pause>:
.global pause
pause:
 li a7, SYS_pause
 388:	48b5                	li	a7,13
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 390:	48b9                	li	a7,14
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
 3aa:	f6fff0ef          	jal	ra,318 <write>
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
 3d8:	51c50513          	addi	a0,a0,1308 # 8f0 <digits>
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
 498:	45cc8c93          	addi	s9,s9,1116 # 8f0 <digits>
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
 6bc:	23090913          	addi	s2,s2,560 # 8e8 <malloc+0x120>
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
 89a:	a2bff0ef          	jal	ra,2c4 <sbrk>
  if(p == SBRK_ERROR)
 89e:	fd551ce3          	bne	a0,s5,876 <malloc+0xae>
        return 0;
 8a2:	4501                	li	a0,0
 8a4:	bf65                	j	85c <malloc+0x94>
