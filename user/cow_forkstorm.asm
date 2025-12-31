
user/_cow_forkstorm：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  char *p = sbrk(4096);
   e:	6505                	lui	a0,0x1
  10:	2e0000ef          	jal	ra,2f0 <sbrk>
  if(p == (char*)-1) exit(1);
  14:	57fd                	li	a5,-1
  16:	02f50263          	beq	a0,a5,3a <main+0x3a>
  1a:	89aa                	mv	s3,a0
  p[0] = 1;
  1c:	4785                	li	a5,1
  1e:	00f50023          	sb	a5,0(a0) # 1000 <freep>

  int n = 40;
  for(int i = 0; i < n; i++){
  22:	4481                	li	s1,0
  24:	02800913          	li	s2,40
    int pid = fork();
  28:	2f4000ef          	jal	ra,31c <fork>
    if(pid < 0){
  2c:	00054a63          	bltz	a0,40 <main+0x40>
      printf("fork failed at %d\n", i);
      break;
    }
    if(pid == 0){
  30:	c131                	beqz	a0,74 <main+0x74>
  for(int i = 0; i < n; i++){
  32:	2485                	addiw	s1,s1,1
  34:	ff249ae3          	bne	s1,s2,28 <main+0x28>
  38:	a819                	j	4e <main+0x4e>
  if(p == (char*)-1) exit(1);
  3a:	4505                	li	a0,1
  3c:	2e8000ef          	jal	ra,324 <exit>
      printf("fork failed at %d\n", i);
  40:	85a6                	mv	a1,s1
  42:	00001517          	auipc	a0,0x1
  46:	8ce50513          	addi	a0,a0,-1842 # 910 <malloc+0xe4>
  4a:	72e000ef          	jal	ra,778 <printf>
      p[0] = (char)(i + 2);
      exit(0);
    }
  }

  while(wait(0) >= 0)
  4e:	4501                	li	a0,0
  50:	2dc000ef          	jal	ra,32c <wait>
  54:	fe055de3          	bgez	a0,4e <main+0x4e>
    ;

  // 父进程应该还是原值
  if(p[0] != 1){
  58:	0009c583          	lbu	a1,0(s3)
  5c:	4785                	li	a5,1
  5e:	02f58063          	beq	a1,a5,7e <main+0x7e>
    printf("FAIL: parent p[0]=%d\n", p[0]);
  62:	00001517          	auipc	a0,0x1
  66:	8c650513          	addi	a0,a0,-1850 # 928 <malloc+0xfc>
  6a:	70e000ef          	jal	ra,778 <printf>
    exit(1);
  6e:	4505                	li	a0,1
  70:	2b4000ef          	jal	ra,324 <exit>
      p[0] = (char)(i + 2);
  74:	2489                	addiw	s1,s1,2
  76:	00998023          	sb	s1,0(s3)
      exit(0);
  7a:	2aa000ef          	jal	ra,324 <exit>
  }
  printf("PASS\n");
  7e:	00001517          	auipc	a0,0x1
  82:	8c250513          	addi	a0,a0,-1854 # 940 <malloc+0x114>
  86:	6f2000ef          	jal	ra,778 <printf>
  exit(0);
  8a:	4501                	li	a0,0
  8c:	298000ef          	jal	ra,324 <exit>

0000000000000090 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  90:	1141                	addi	sp,sp,-16
  92:	e406                	sd	ra,8(sp)
  94:	e022                	sd	s0,0(sp)
  96:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  98:	f69ff0ef          	jal	ra,0 <main>
  exit(r);
  9c:	288000ef          	jal	ra,324 <exit>

00000000000000a0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a6:	87aa                	mv	a5,a0
  a8:	0585                	addi	a1,a1,1
  aa:	0785                	addi	a5,a5,1
  ac:	fff5c703          	lbu	a4,-1(a1)
  b0:	fee78fa3          	sb	a4,-1(a5)
  b4:	fb75                	bnez	a4,a8 <strcpy+0x8>
    ;
  return os;
}
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret

00000000000000bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	cb91                	beqz	a5,da <strcmp+0x1e>
  c8:	0005c703          	lbu	a4,0(a1)
  cc:	00f71763          	bne	a4,a5,da <strcmp+0x1e>
    p++, q++;
  d0:	0505                	addi	a0,a0,1
  d2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbe5                	bnez	a5,c8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  da:	0005c503          	lbu	a0,0(a1)
}
  de:	40a7853b          	subw	a0,a5,a0
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strlen>:

uint
strlen(const char *s)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cf91                	beqz	a5,10e <strlen+0x26>
  f4:	0505                	addi	a0,a0,1
  f6:	87aa                	mv	a5,a0
  f8:	4685                	li	a3,1
  fa:	9e89                	subw	a3,a3,a0
  fc:	00f6853b          	addw	a0,a3,a5
 100:	0785                	addi	a5,a5,1
 102:	fff7c703          	lbu	a4,-1(a5)
 106:	fb7d                	bnez	a4,fc <strlen+0x14>
    ;
  return n;
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret
  for(n = 0; s[n]; n++)
 10e:	4501                	li	a0,0
 110:	bfe5                	j	108 <strlen+0x20>

0000000000000112 <memset>:

void*
memset(void *dst, int c, uint n)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 118:	ca19                	beqz	a2,12e <memset+0x1c>
 11a:	87aa                	mv	a5,a0
 11c:	1602                	slli	a2,a2,0x20
 11e:	9201                	srli	a2,a2,0x20
 120:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 124:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 128:	0785                	addi	a5,a5,1
 12a:	fee79de3          	bne	a5,a4,124 <memset+0x12>
  }
  return dst;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strchr>:

char*
strchr(const char *s, char c)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb99                	beqz	a5,154 <strchr+0x20>
    if(*s == c)
 140:	00f58763          	beq	a1,a5,14e <strchr+0x1a>
  for(; *s; s++)
 144:	0505                	addi	a0,a0,1
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbfd                	bnez	a5,140 <strchr+0xc>
      return (char*)s;
  return 0;
 14c:	4501                	li	a0,0
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret
  return 0;
 154:	4501                	li	a0,0
 156:	bfe5                	j	14e <strchr+0x1a>

0000000000000158 <gets>:

char*
gets(char *buf, int max)
{
 158:	711d                	addi	sp,sp,-96
 15a:	ec86                	sd	ra,88(sp)
 15c:	e8a2                	sd	s0,80(sp)
 15e:	e4a6                	sd	s1,72(sp)
 160:	e0ca                	sd	s2,64(sp)
 162:	fc4e                	sd	s3,56(sp)
 164:	f852                	sd	s4,48(sp)
 166:	f456                	sd	s5,40(sp)
 168:	f05a                	sd	s6,32(sp)
 16a:	ec5e                	sd	s7,24(sp)
 16c:	1080                	addi	s0,sp,96
 16e:	8baa                	mv	s7,a0
 170:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	892a                	mv	s2,a0
 174:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 176:	4aa9                	li	s5,10
 178:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 17a:	89a6                	mv	s3,s1
 17c:	2485                	addiw	s1,s1,1
 17e:	0344d663          	bge	s1,s4,1aa <gets+0x52>
    cc = read(0, &c, 1);
 182:	4605                	li	a2,1
 184:	faf40593          	addi	a1,s0,-81
 188:	4501                	li	a0,0
 18a:	1b2000ef          	jal	ra,33c <read>
    if(cc < 1)
 18e:	00a05e63          	blez	a0,1aa <gets+0x52>
    buf[i++] = c;
 192:	faf44783          	lbu	a5,-81(s0)
 196:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 19a:	01578763          	beq	a5,s5,1a8 <gets+0x50>
 19e:	0905                	addi	s2,s2,1
 1a0:	fd679de3          	bne	a5,s6,17a <gets+0x22>
  for(i=0; i+1 < max; ){
 1a4:	89a6                	mv	s3,s1
 1a6:	a011                	j	1aa <gets+0x52>
 1a8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1aa:	99de                	add	s3,s3,s7
 1ac:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b0:	855e                	mv	a0,s7
 1b2:	60e6                	ld	ra,88(sp)
 1b4:	6446                	ld	s0,80(sp)
 1b6:	64a6                	ld	s1,72(sp)
 1b8:	6906                	ld	s2,64(sp)
 1ba:	79e2                	ld	s3,56(sp)
 1bc:	7a42                	ld	s4,48(sp)
 1be:	7aa2                	ld	s5,40(sp)
 1c0:	7b02                	ld	s6,32(sp)
 1c2:	6be2                	ld	s7,24(sp)
 1c4:	6125                	addi	sp,sp,96
 1c6:	8082                	ret

00000000000001c8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c8:	1101                	addi	sp,sp,-32
 1ca:	ec06                	sd	ra,24(sp)
 1cc:	e822                	sd	s0,16(sp)
 1ce:	e426                	sd	s1,8(sp)
 1d0:	e04a                	sd	s2,0(sp)
 1d2:	1000                	addi	s0,sp,32
 1d4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d6:	4581                	li	a1,0
 1d8:	18c000ef          	jal	ra,364 <open>
  if(fd < 0)
 1dc:	02054163          	bltz	a0,1fe <stat+0x36>
 1e0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e2:	85ca                	mv	a1,s2
 1e4:	198000ef          	jal	ra,37c <fstat>
 1e8:	892a                	mv	s2,a0
  close(fd);
 1ea:	8526                	mv	a0,s1
 1ec:	160000ef          	jal	ra,34c <close>
  return r;
}
 1f0:	854a                	mv	a0,s2
 1f2:	60e2                	ld	ra,24(sp)
 1f4:	6442                	ld	s0,16(sp)
 1f6:	64a2                	ld	s1,8(sp)
 1f8:	6902                	ld	s2,0(sp)
 1fa:	6105                	addi	sp,sp,32
 1fc:	8082                	ret
    return -1;
 1fe:	597d                	li	s2,-1
 200:	bfc5                	j	1f0 <stat+0x28>

0000000000000202 <atoi>:

int
atoi(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 208:	00054683          	lbu	a3,0(a0)
 20c:	fd06879b          	addiw	a5,a3,-48
 210:	0ff7f793          	zext.b	a5,a5
 214:	4625                	li	a2,9
 216:	02f66863          	bltu	a2,a5,246 <atoi+0x44>
 21a:	872a                	mv	a4,a0
  n = 0;
 21c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 21e:	0705                	addi	a4,a4,1
 220:	0025179b          	slliw	a5,a0,0x2
 224:	9fa9                	addw	a5,a5,a0
 226:	0017979b          	slliw	a5,a5,0x1
 22a:	9fb5                	addw	a5,a5,a3
 22c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 230:	00074683          	lbu	a3,0(a4)
 234:	fd06879b          	addiw	a5,a3,-48
 238:	0ff7f793          	zext.b	a5,a5
 23c:	fef671e3          	bgeu	a2,a5,21e <atoi+0x1c>
  return n;
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
  n = 0;
 246:	4501                	li	a0,0
 248:	bfe5                	j	240 <atoi+0x3e>

000000000000024a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 250:	02b57463          	bgeu	a0,a1,278 <memmove+0x2e>
    while(n-- > 0)
 254:	00c05f63          	blez	a2,272 <memmove+0x28>
 258:	1602                	slli	a2,a2,0x20
 25a:	9201                	srli	a2,a2,0x20
 25c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 260:	872a                	mv	a4,a0
      *dst++ = *src++;
 262:	0585                	addi	a1,a1,1
 264:	0705                	addi	a4,a4,1
 266:	fff5c683          	lbu	a3,-1(a1)
 26a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 26e:	fee79ae3          	bne	a5,a4,262 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
    dst += n;
 278:	00c50733          	add	a4,a0,a2
    src += n;
 27c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 27e:	fec05ae3          	blez	a2,272 <memmove+0x28>
 282:	fff6079b          	addiw	a5,a2,-1
 286:	1782                	slli	a5,a5,0x20
 288:	9381                	srli	a5,a5,0x20
 28a:	fff7c793          	not	a5,a5
 28e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 290:	15fd                	addi	a1,a1,-1
 292:	177d                	addi	a4,a4,-1
 294:	0005c683          	lbu	a3,0(a1)
 298:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 29c:	fee79ae3          	bne	a5,a4,290 <memmove+0x46>
 2a0:	bfc9                	j	272 <memmove+0x28>

00000000000002a2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a8:	ca05                	beqz	a2,2d8 <memcmp+0x36>
 2aa:	fff6069b          	addiw	a3,a2,-1
 2ae:	1682                	slli	a3,a3,0x20
 2b0:	9281                	srli	a3,a3,0x20
 2b2:	0685                	addi	a3,a3,1
 2b4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b6:	00054783          	lbu	a5,0(a0)
 2ba:	0005c703          	lbu	a4,0(a1)
 2be:	00e79863          	bne	a5,a4,2ce <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c2:	0505                	addi	a0,a0,1
    p2++;
 2c4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c6:	fed518e3          	bne	a0,a3,2b6 <memcmp+0x14>
  }
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	a019                	j	2d2 <memcmp+0x30>
      return *p1 - *p2;
 2ce:	40e7853b          	subw	a0,a5,a4
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  return 0;
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <memcmp+0x30>

00000000000002dc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e406                	sd	ra,8(sp)
 2e0:	e022                	sd	s0,0(sp)
 2e2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e4:	f67ff0ef          	jal	ra,24a <memmove>
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <sbrk>:

char *
sbrk(int n) {
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2f8:	4585                	li	a1,1
 2fa:	0b2000ef          	jal	ra,3ac <sys_sbrk>
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <sbrklazy>:

char *
sbrklazy(int n) {
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 30e:	4589                	li	a1,2
 310:	09c000ef          	jal	ra,3ac <sys_sbrk>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 31c:	4885                	li	a7,1
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <exit>:
.global exit
exit:
 li a7, SYS_exit
 324:	4889                	li	a7,2
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <wait>:
.global wait
wait:
 li a7, SYS_wait
 32c:	488d                	li	a7,3
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 334:	4891                	li	a7,4
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <read>:
.global read
read:
 li a7, SYS_read
 33c:	4895                	li	a7,5
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <write>:
.global write
write:
 li a7, SYS_write
 344:	48c1                	li	a7,16
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <close>:
.global close
close:
 li a7, SYS_close
 34c:	48d5                	li	a7,21
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <kill>:
.global kill
kill:
 li a7, SYS_kill
 354:	4899                	li	a7,6
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <exec>:
.global exec
exec:
 li a7, SYS_exec
 35c:	489d                	li	a7,7
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <open>:
.global open
open:
 li a7, SYS_open
 364:	48bd                	li	a7,15
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 36c:	48c5                	li	a7,17
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 374:	48c9                	li	a7,18
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 37c:	48a1                	li	a7,8
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <link>:
.global link
link:
 li a7, SYS_link
 384:	48cd                	li	a7,19
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 38c:	48d1                	li	a7,20
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 394:	48a5                	li	a7,9
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <dup>:
.global dup
dup:
 li a7, SYS_dup
 39c:	48a9                	li	a7,10
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a4:	48ad                	li	a7,11
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ac:	48b1                	li	a7,12
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3b4:	48b5                	li	a7,13
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3bc:	48b9                	li	a7,14
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3c4:	48d9                	li	a7,22
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3cc:	48dd                	li	a7,23
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3d4:	48e1                	li	a7,24
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3dc:	48e5                	li	a7,25
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 3e4:	48e9                	li	a7,26
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3ec:	48ed                	li	a7,27
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3f4:	48f1                	li	a7,28
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3fc:	1101                	addi	sp,sp,-32
 3fe:	ec06                	sd	ra,24(sp)
 400:	e822                	sd	s0,16(sp)
 402:	1000                	addi	s0,sp,32
 404:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 408:	4605                	li	a2,1
 40a:	fef40593          	addi	a1,s0,-17
 40e:	f37ff0ef          	jal	ra,344 <write>
}
 412:	60e2                	ld	ra,24(sp)
 414:	6442                	ld	s0,16(sp)
 416:	6105                	addi	sp,sp,32
 418:	8082                	ret

000000000000041a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 41a:	715d                	addi	sp,sp,-80
 41c:	e486                	sd	ra,72(sp)
 41e:	e0a2                	sd	s0,64(sp)
 420:	fc26                	sd	s1,56(sp)
 422:	f84a                	sd	s2,48(sp)
 424:	f44e                	sd	s3,40(sp)
 426:	0880                	addi	s0,sp,80
 428:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 42a:	c299                	beqz	a3,430 <printint+0x16>
 42c:	0805c163          	bltz	a1,4ae <printint+0x94>
  neg = 0;
 430:	4881                	li	a7,0
 432:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 436:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 438:	00000517          	auipc	a0,0x0
 43c:	51850513          	addi	a0,a0,1304 # 950 <digits>
 440:	883e                	mv	a6,a5
 442:	2785                	addiw	a5,a5,1
 444:	02c5f733          	remu	a4,a1,a2
 448:	972a                	add	a4,a4,a0
 44a:	00074703          	lbu	a4,0(a4)
 44e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 452:	872e                	mv	a4,a1
 454:	02c5d5b3          	divu	a1,a1,a2
 458:	0685                	addi	a3,a3,1
 45a:	fec773e3          	bgeu	a4,a2,440 <printint+0x26>
  if(neg)
 45e:	00088b63          	beqz	a7,474 <printint+0x5a>
    buf[i++] = '-';
 462:	fd078793          	addi	a5,a5,-48
 466:	97a2                	add	a5,a5,s0
 468:	02d00713          	li	a4,45
 46c:	fee78423          	sb	a4,-24(a5)
 470:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 474:	02f05663          	blez	a5,4a0 <printint+0x86>
 478:	fb840713          	addi	a4,s0,-72
 47c:	00f704b3          	add	s1,a4,a5
 480:	fff70993          	addi	s3,a4,-1
 484:	99be                	add	s3,s3,a5
 486:	37fd                	addiw	a5,a5,-1
 488:	1782                	slli	a5,a5,0x20
 48a:	9381                	srli	a5,a5,0x20
 48c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 490:	fff4c583          	lbu	a1,-1(s1)
 494:	854a                	mv	a0,s2
 496:	f67ff0ef          	jal	ra,3fc <putc>
  while(--i >= 0)
 49a:	14fd                	addi	s1,s1,-1
 49c:	ff349ae3          	bne	s1,s3,490 <printint+0x76>
}
 4a0:	60a6                	ld	ra,72(sp)
 4a2:	6406                	ld	s0,64(sp)
 4a4:	74e2                	ld	s1,56(sp)
 4a6:	7942                	ld	s2,48(sp)
 4a8:	79a2                	ld	s3,40(sp)
 4aa:	6161                	addi	sp,sp,80
 4ac:	8082                	ret
    x = -xx;
 4ae:	40b005b3          	neg	a1,a1
    neg = 1;
 4b2:	4885                	li	a7,1
    x = -xx;
 4b4:	bfbd                	j	432 <printint+0x18>

00000000000004b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b6:	7119                	addi	sp,sp,-128
 4b8:	fc86                	sd	ra,120(sp)
 4ba:	f8a2                	sd	s0,112(sp)
 4bc:	f4a6                	sd	s1,104(sp)
 4be:	f0ca                	sd	s2,96(sp)
 4c0:	ecce                	sd	s3,88(sp)
 4c2:	e8d2                	sd	s4,80(sp)
 4c4:	e4d6                	sd	s5,72(sp)
 4c6:	e0da                	sd	s6,64(sp)
 4c8:	fc5e                	sd	s7,56(sp)
 4ca:	f862                	sd	s8,48(sp)
 4cc:	f466                	sd	s9,40(sp)
 4ce:	f06a                	sd	s10,32(sp)
 4d0:	ec6e                	sd	s11,24(sp)
 4d2:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d4:	0005c903          	lbu	s2,0(a1)
 4d8:	24090c63          	beqz	s2,730 <vprintf+0x27a>
 4dc:	8b2a                	mv	s6,a0
 4de:	8a2e                	mv	s4,a1
 4e0:	8bb2                	mv	s7,a2
  state = 0;
 4e2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4e4:	4481                	li	s1,0
 4e6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4e8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4ec:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4f0:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4f4:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4f8:	00000c97          	auipc	s9,0x0
 4fc:	458c8c93          	addi	s9,s9,1112 # 950 <digits>
 500:	a005                	j	520 <vprintf+0x6a>
        putc(fd, c0);
 502:	85ca                	mv	a1,s2
 504:	855a                	mv	a0,s6
 506:	ef7ff0ef          	jal	ra,3fc <putc>
 50a:	a019                	j	510 <vprintf+0x5a>
    } else if(state == '%'){
 50c:	03598263          	beq	s3,s5,530 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 510:	2485                	addiw	s1,s1,1
 512:	8726                	mv	a4,s1
 514:	009a07b3          	add	a5,s4,s1
 518:	0007c903          	lbu	s2,0(a5)
 51c:	20090a63          	beqz	s2,730 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 520:	0009079b          	sext.w	a5,s2
    if(state == 0){
 524:	fe0994e3          	bnez	s3,50c <vprintf+0x56>
      if(c0 == '%'){
 528:	fd579de3          	bne	a5,s5,502 <vprintf+0x4c>
        state = '%';
 52c:	89be                	mv	s3,a5
 52e:	b7cd                	j	510 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 530:	c3c1                	beqz	a5,5b0 <vprintf+0xfa>
 532:	00ea06b3          	add	a3,s4,a4
 536:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 53a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 53c:	c681                	beqz	a3,544 <vprintf+0x8e>
 53e:	9752                	add	a4,a4,s4
 540:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 544:	03878e63          	beq	a5,s8,580 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 548:	05a78863          	beq	a5,s10,598 <vprintf+0xe2>
      } else if(c0 == 'u'){
 54c:	0db78b63          	beq	a5,s11,622 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 550:	07800713          	li	a4,120
 554:	10e78d63          	beq	a5,a4,66e <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 558:	07000713          	li	a4,112
 55c:	14e78263          	beq	a5,a4,6a0 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 560:	06300713          	li	a4,99
 564:	16e78f63          	beq	a5,a4,6e2 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 568:	07300713          	li	a4,115
 56c:	18e78563          	beq	a5,a4,6f6 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 570:	05579063          	bne	a5,s5,5b0 <vprintf+0xfa>
        putc(fd, '%');
 574:	85d6                	mv	a1,s5
 576:	855a                	mv	a0,s6
 578:	e85ff0ef          	jal	ra,3fc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 57c:	4981                	li	s3,0
 57e:	bf49                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 580:	008b8913          	addi	s2,s7,8
 584:	4685                	li	a3,1
 586:	4629                	li	a2,10
 588:	000ba583          	lw	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	e8dff0ef          	jal	ra,41a <printint>
 592:	8bca                	mv	s7,s2
      state = 0;
 594:	4981                	li	s3,0
 596:	bfad                	j	510 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 598:	03868663          	beq	a3,s8,5c4 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 59c:	05a68163          	beq	a3,s10,5de <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5a0:	09b68d63          	beq	a3,s11,63a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a4:	03a68f63          	beq	a3,s10,5e2 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5a8:	07800793          	li	a5,120
 5ac:	0cf68d63          	beq	a3,a5,686 <vprintf+0x1d0>
        putc(fd, '%');
 5b0:	85d6                	mv	a1,s5
 5b2:	855a                	mv	a0,s6
 5b4:	e49ff0ef          	jal	ra,3fc <putc>
        putc(fd, c0);
 5b8:	85ca                	mv	a1,s2
 5ba:	855a                	mv	a0,s6
 5bc:	e41ff0ef          	jal	ra,3fc <putc>
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	b7b9                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c4:	008b8913          	addi	s2,s7,8
 5c8:	4685                	li	a3,1
 5ca:	4629                	li	a2,10
 5cc:	000bb583          	ld	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	e49ff0ef          	jal	ra,41a <printint>
        i += 1;
 5d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d8:	8bca                	mv	s7,s2
      state = 0;
 5da:	4981                	li	s3,0
        i += 1;
 5dc:	bf15                	j	510 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5de:	03860563          	beq	a2,s8,608 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e2:	07b60963          	beq	a2,s11,654 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5e6:	07800793          	li	a5,120
 5ea:	fcf613e3          	bne	a2,a5,5b0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4641                	li	a2,16
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	e1fff0ef          	jal	ra,41a <printint>
        i += 2;
 600:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
        i += 2;
 606:	b729                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 608:	008b8913          	addi	s2,s7,8
 60c:	4685                	li	a3,1
 60e:	4629                	li	a2,10
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	e05ff0ef          	jal	ra,41a <printint>
        i += 2;
 61a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	bdc5                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000be583          	lwu	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	debff0ef          	jal	ra,41a <printint>
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
 638:	bde1                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4681                	li	a3,0
 640:	4629                	li	a2,10
 642:	000bb583          	ld	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	dd3ff0ef          	jal	ra,41a <printint>
        i += 1;
 64c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
        i += 1;
 652:	bd7d                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b8913          	addi	s2,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	db9ff0ef          	jal	ra,41a <printint>
        i += 2;
 666:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 2;
 66c:	b555                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4641                	li	a2,16
 676:	000be583          	lwu	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	d9fff0ef          	jal	ra,41a <printint>
 680:	8bca                	mv	s7,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	b571                	j	510 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 686:	008b8913          	addi	s2,s7,8
 68a:	4681                	li	a3,0
 68c:	4641                	li	a2,16
 68e:	000bb583          	ld	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	d87ff0ef          	jal	ra,41a <printint>
        i += 1;
 698:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
        i += 1;
 69e:	bd8d                	j	510 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6a0:	008b8793          	addi	a5,s7,8
 6a4:	f8f43423          	sd	a5,-120(s0)
 6a8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ac:	03000593          	li	a1,48
 6b0:	855a                	mv	a0,s6
 6b2:	d4bff0ef          	jal	ra,3fc <putc>
  putc(fd, 'x');
 6b6:	07800593          	li	a1,120
 6ba:	855a                	mv	a0,s6
 6bc:	d41ff0ef          	jal	ra,3fc <putc>
 6c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c2:	03c9d793          	srli	a5,s3,0x3c
 6c6:	97e6                	add	a5,a5,s9
 6c8:	0007c583          	lbu	a1,0(a5)
 6cc:	855a                	mv	a0,s6
 6ce:	d2fff0ef          	jal	ra,3fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d2:	0992                	slli	s3,s3,0x4
 6d4:	397d                	addiw	s2,s2,-1
 6d6:	fe0916e3          	bnez	s2,6c2 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6da:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bd05                	j	510 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	000bc583          	lbu	a1,0(s7)
 6ea:	855a                	mv	a0,s6
 6ec:	d11ff0ef          	jal	ra,3fc <putc>
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bd31                	j	510 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6f6:	008b8993          	addi	s3,s7,8
 6fa:	000bb903          	ld	s2,0(s7)
 6fe:	00090f63          	beqz	s2,71c <vprintf+0x266>
        for(; *s; s++)
 702:	00094583          	lbu	a1,0(s2)
 706:	c195                	beqz	a1,72a <vprintf+0x274>
          putc(fd, *s);
 708:	855a                	mv	a0,s6
 70a:	cf3ff0ef          	jal	ra,3fc <putc>
        for(; *s; s++)
 70e:	0905                	addi	s2,s2,1
 710:	00094583          	lbu	a1,0(s2)
 714:	f9f5                	bnez	a1,708 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 716:	8bce                	mv	s7,s3
      state = 0;
 718:	4981                	li	s3,0
 71a:	bbdd                	j	510 <vprintf+0x5a>
          s = "(null)";
 71c:	00000917          	auipc	s2,0x0
 720:	22c90913          	addi	s2,s2,556 # 948 <malloc+0x11c>
        for(; *s; s++)
 724:	02800593          	li	a1,40
 728:	b7c5                	j	708 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 72a:	8bce                	mv	s7,s3
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b3cd                	j	510 <vprintf+0x5a>
    }
  }
}
 730:	70e6                	ld	ra,120(sp)
 732:	7446                	ld	s0,112(sp)
 734:	74a6                	ld	s1,104(sp)
 736:	7906                	ld	s2,96(sp)
 738:	69e6                	ld	s3,88(sp)
 73a:	6a46                	ld	s4,80(sp)
 73c:	6aa6                	ld	s5,72(sp)
 73e:	6b06                	ld	s6,64(sp)
 740:	7be2                	ld	s7,56(sp)
 742:	7c42                	ld	s8,48(sp)
 744:	7ca2                	ld	s9,40(sp)
 746:	7d02                	ld	s10,32(sp)
 748:	6de2                	ld	s11,24(sp)
 74a:	6109                	addi	sp,sp,128
 74c:	8082                	ret

000000000000074e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74e:	715d                	addi	sp,sp,-80
 750:	ec06                	sd	ra,24(sp)
 752:	e822                	sd	s0,16(sp)
 754:	1000                	addi	s0,sp,32
 756:	e010                	sd	a2,0(s0)
 758:	e414                	sd	a3,8(s0)
 75a:	e818                	sd	a4,16(s0)
 75c:	ec1c                	sd	a5,24(s0)
 75e:	03043023          	sd	a6,32(s0)
 762:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76a:	8622                	mv	a2,s0
 76c:	d4bff0ef          	jal	ra,4b6 <vprintf>
}
 770:	60e2                	ld	ra,24(sp)
 772:	6442                	ld	s0,16(sp)
 774:	6161                	addi	sp,sp,80
 776:	8082                	ret

0000000000000778 <printf>:

void
printf(const char *fmt, ...)
{
 778:	711d                	addi	sp,sp,-96
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e40c                	sd	a1,8(s0)
 782:	e810                	sd	a2,16(s0)
 784:	ec14                	sd	a3,24(s0)
 786:	f018                	sd	a4,32(s0)
 788:	f41c                	sd	a5,40(s0)
 78a:	03043823          	sd	a6,48(s0)
 78e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 792:	00840613          	addi	a2,s0,8
 796:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79a:	85aa                	mv	a1,a0
 79c:	4505                	li	a0,1
 79e:	d19ff0ef          	jal	ra,4b6 <vprintf>
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6125                	addi	sp,sp,96
 7a8:	8082                	ret

00000000000007aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7aa:	1141                	addi	sp,sp,-16
 7ac:	e422                	sd	s0,8(sp)
 7ae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b4:	00001797          	auipc	a5,0x1
 7b8:	84c7b783          	ld	a5,-1972(a5) # 1000 <freep>
 7bc:	a02d                	j	7e6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7be:	4618                	lw	a4,8(a2)
 7c0:	9f2d                	addw	a4,a4,a1
 7c2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c6:	6398                	ld	a4,0(a5)
 7c8:	6310                	ld	a2,0(a4)
 7ca:	a83d                	j	808 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7cc:	ff852703          	lw	a4,-8(a0)
 7d0:	9f31                	addw	a4,a4,a2
 7d2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7d4:	ff053683          	ld	a3,-16(a0)
 7d8:	a091                	j	81c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e7e463          	bltu	a5,a4,7e4 <free+0x3a>
 7e0:	00e6ea63          	bltu	a3,a4,7f4 <free+0x4a>
{
 7e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	fed7fae3          	bgeu	a5,a3,7da <free+0x30>
 7ea:	6398                	ld	a4,0(a5)
 7ec:	00e6e463          	bltu	a3,a4,7f4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f0:	fee7eae3          	bltu	a5,a4,7e4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7f4:	ff852583          	lw	a1,-8(a0)
 7f8:	6390                	ld	a2,0(a5)
 7fa:	02059813          	slli	a6,a1,0x20
 7fe:	01c85713          	srli	a4,a6,0x1c
 802:	9736                	add	a4,a4,a3
 804:	fae60de3          	beq	a2,a4,7be <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80c:	4790                	lw	a2,8(a5)
 80e:	02061593          	slli	a1,a2,0x20
 812:	01c5d713          	srli	a4,a1,0x1c
 816:	973e                	add	a4,a4,a5
 818:	fae68ae3          	beq	a3,a4,7cc <free+0x22>
    p->s.ptr = bp->s.ptr;
 81c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 81e:	00000717          	auipc	a4,0x0
 822:	7ef73123          	sd	a5,2018(a4) # 1000 <freep>
}
 826:	6422                	ld	s0,8(sp)
 828:	0141                	addi	sp,sp,16
 82a:	8082                	ret

000000000000082c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82c:	7139                	addi	sp,sp,-64
 82e:	fc06                	sd	ra,56(sp)
 830:	f822                	sd	s0,48(sp)
 832:	f426                	sd	s1,40(sp)
 834:	f04a                	sd	s2,32(sp)
 836:	ec4e                	sd	s3,24(sp)
 838:	e852                	sd	s4,16(sp)
 83a:	e456                	sd	s5,8(sp)
 83c:	e05a                	sd	s6,0(sp)
 83e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 840:	02051493          	slli	s1,a0,0x20
 844:	9081                	srli	s1,s1,0x20
 846:	04bd                	addi	s1,s1,15
 848:	8091                	srli	s1,s1,0x4
 84a:	0014899b          	addiw	s3,s1,1
 84e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 850:	00000517          	auipc	a0,0x0
 854:	7b053503          	ld	a0,1968(a0) # 1000 <freep>
 858:	c515                	beqz	a0,884 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85c:	4798                	lw	a4,8(a5)
 85e:	02977f63          	bgeu	a4,s1,89c <malloc+0x70>
 862:	8a4e                	mv	s4,s3
 864:	0009871b          	sext.w	a4,s3
 868:	6685                	lui	a3,0x1
 86a:	00d77363          	bgeu	a4,a3,870 <malloc+0x44>
 86e:	6a05                	lui	s4,0x1
 870:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 874:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 878:	00000917          	auipc	s2,0x0
 87c:	78890913          	addi	s2,s2,1928 # 1000 <freep>
  if(p == SBRK_ERROR)
 880:	5afd                	li	s5,-1
 882:	a885                	j	8f2 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 884:	00000797          	auipc	a5,0x0
 888:	78c78793          	addi	a5,a5,1932 # 1010 <base>
 88c:	00000717          	auipc	a4,0x0
 890:	76f73a23          	sd	a5,1908(a4) # 1000 <freep>
 894:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 896:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 89a:	b7e1                	j	862 <malloc+0x36>
      if(p->s.size == nunits)
 89c:	02e48c63          	beq	s1,a4,8d4 <malloc+0xa8>
        p->s.size -= nunits;
 8a0:	4137073b          	subw	a4,a4,s3
 8a4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a6:	02071693          	slli	a3,a4,0x20
 8aa:	01c6d713          	srli	a4,a3,0x1c
 8ae:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b4:	00000717          	auipc	a4,0x0
 8b8:	74a73623          	sd	a0,1868(a4) # 1000 <freep>
      return (void*)(p + 1);
 8bc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c0:	70e2                	ld	ra,56(sp)
 8c2:	7442                	ld	s0,48(sp)
 8c4:	74a2                	ld	s1,40(sp)
 8c6:	7902                	ld	s2,32(sp)
 8c8:	69e2                	ld	s3,24(sp)
 8ca:	6a42                	ld	s4,16(sp)
 8cc:	6aa2                	ld	s5,8(sp)
 8ce:	6b02                	ld	s6,0(sp)
 8d0:	6121                	addi	sp,sp,64
 8d2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8d4:	6398                	ld	a4,0(a5)
 8d6:	e118                	sd	a4,0(a0)
 8d8:	bff1                	j	8b4 <malloc+0x88>
  hp->s.size = nu;
 8da:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8de:	0541                	addi	a0,a0,16
 8e0:	ecbff0ef          	jal	ra,7aa <free>
  return freep;
 8e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e8:	dd61                	beqz	a0,8c0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ec:	4798                	lw	a4,8(a5)
 8ee:	fa9777e3          	bgeu	a4,s1,89c <malloc+0x70>
    if(p == freep)
 8f2:	00093703          	ld	a4,0(s2)
 8f6:	853e                	mv	a0,a5
 8f8:	fef719e3          	bne	a4,a5,8ea <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 8fc:	8552                	mv	a0,s4
 8fe:	9f3ff0ef          	jal	ra,2f0 <sbrk>
  if(p == SBRK_ERROR)
 902:	fd551ce3          	bne	a0,s5,8da <malloc+0xae>
        return 0;
 906:	4501                	li	a0,0
 908:	bf65                	j	8c0 <malloc+0x94>
