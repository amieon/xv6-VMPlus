
user/_cow_bidir：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

int x = 100;

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid = fork();
   c:	308000ef          	jal	ra,314 <fork>
  if(pid < 0) exit(1);
  10:	02054463          	bltz	a0,38 <main+0x38>

    if(pid == 0){
  14:	e50d                	bnez	a0,3e <main+0x3e>
    // child
    x = 200;
  16:	0c800793          	li	a5,200
  1a:	00001717          	auipc	a4,0x1
  1e:	fef72323          	sw	a5,-26(a4) # 1000 <x>
    printf("child: x=%d\n", x);
  22:	0c800593          	li	a1,200
  26:	00001517          	auipc	a0,0x1
  2a:	8ca50513          	addi	a0,a0,-1846 # 8f0 <malloc+0xe4>
  2e:	72a000ef          	jal	ra,758 <printf>
    exit(0);
  32:	4501                	li	a0,0
  34:	2e8000ef          	jal	ra,31c <exit>
  if(pid < 0) exit(1);
  38:	4505                	li	a0,1
  3a:	2e2000ef          	jal	ra,31c <exit>
    }


  // parent writes
  x = 300;
  3e:	00001497          	auipc	s1,0x1
  42:	fc248493          	addi	s1,s1,-62 # 1000 <x>
  46:	12c00913          	li	s2,300
  4a:	0124a023          	sw	s2,0(s1)
  wait(0);
  4e:	4501                	li	a0,0
  50:	2d4000ef          	jal	ra,324 <wait>
  printf("parent: x=%d (expect 300)\n", x);
  54:	408c                	lw	a1,0(s1)
  56:	00001517          	auipc	a0,0x1
  5a:	8aa50513          	addi	a0,a0,-1878 # 900 <malloc+0xf4>
  5e:	6fa000ef          	jal	ra,758 <printf>
  if(x != 300) printf("FAIL parent\n");
  62:	409c                	lw	a5,0(s1)
  64:	01279b63          	bne	a5,s2,7a <main+0x7a>
  printf("PASS\n");
  68:	00001517          	auipc	a0,0x1
  6c:	8c850513          	addi	a0,a0,-1848 # 930 <malloc+0x124>
  70:	6e8000ef          	jal	ra,758 <printf>
  exit(0);
  74:	4501                	li	a0,0
  76:	2a6000ef          	jal	ra,31c <exit>
  if(x != 300) printf("FAIL parent\n");
  7a:	00001517          	auipc	a0,0x1
  7e:	8a650513          	addi	a0,a0,-1882 # 920 <malloc+0x114>
  82:	6d6000ef          	jal	ra,758 <printf>
  86:	b7cd                	j	68 <main+0x68>

0000000000000088 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  88:	1141                	addi	sp,sp,-16
  8a:	e406                	sd	ra,8(sp)
  8c:	e022                	sd	s0,0(sp)
  8e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  90:	f71ff0ef          	jal	ra,0 <main>
  exit(r);
  94:	288000ef          	jal	ra,31c <exit>

0000000000000098 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e422                	sd	s0,8(sp)
  9c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9e:	87aa                	mv	a5,a0
  a0:	0585                	addi	a1,a1,1
  a2:	0785                	addi	a5,a5,1
  a4:	fff5c703          	lbu	a4,-1(a1)
  a8:	fee78fa3          	sb	a4,-1(a5)
  ac:	fb75                	bnez	a4,a0 <strcpy+0x8>
    ;
  return os;
}
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret

00000000000000b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ba:	00054783          	lbu	a5,0(a0)
  be:	cb91                	beqz	a5,d2 <strcmp+0x1e>
  c0:	0005c703          	lbu	a4,0(a1)
  c4:	00f71763          	bne	a4,a5,d2 <strcmp+0x1e>
    p++, q++;
  c8:	0505                	addi	a0,a0,1
  ca:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	fbe5                	bnez	a5,c0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d2:	0005c503          	lbu	a0,0(a1)
}
  d6:	40a7853b          	subw	a0,a5,a0
  da:	6422                	ld	s0,8(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret

00000000000000e0 <strlen>:

uint
strlen(const char *s)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e422                	sd	s0,8(sp)
  e4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e6:	00054783          	lbu	a5,0(a0)
  ea:	cf91                	beqz	a5,106 <strlen+0x26>
  ec:	0505                	addi	a0,a0,1
  ee:	87aa                	mv	a5,a0
  f0:	4685                	li	a3,1
  f2:	9e89                	subw	a3,a3,a0
  f4:	00f6853b          	addw	a0,a3,a5
  f8:	0785                	addi	a5,a5,1
  fa:	fff7c703          	lbu	a4,-1(a5)
  fe:	fb7d                	bnez	a4,f4 <strlen+0x14>
    ;
  return n;
}
 100:	6422                	ld	s0,8(sp)
 102:	0141                	addi	sp,sp,16
 104:	8082                	ret
  for(n = 0; s[n]; n++)
 106:	4501                	li	a0,0
 108:	bfe5                	j	100 <strlen+0x20>

000000000000010a <memset>:

void*
memset(void *dst, int c, uint n)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 110:	ca19                	beqz	a2,126 <memset+0x1c>
 112:	87aa                	mv	a5,a0
 114:	1602                	slli	a2,a2,0x20
 116:	9201                	srli	a2,a2,0x20
 118:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 11c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 120:	0785                	addi	a5,a5,1
 122:	fee79de3          	bne	a5,a4,11c <memset+0x12>
  }
  return dst;
}
 126:	6422                	ld	s0,8(sp)
 128:	0141                	addi	sp,sp,16
 12a:	8082                	ret

000000000000012c <strchr>:

char*
strchr(const char *s, char c)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  for(; *s; s++)
 132:	00054783          	lbu	a5,0(a0)
 136:	cb99                	beqz	a5,14c <strchr+0x20>
    if(*s == c)
 138:	00f58763          	beq	a1,a5,146 <strchr+0x1a>
  for(; *s; s++)
 13c:	0505                	addi	a0,a0,1
 13e:	00054783          	lbu	a5,0(a0)
 142:	fbfd                	bnez	a5,138 <strchr+0xc>
      return (char*)s;
  return 0;
 144:	4501                	li	a0,0
}
 146:	6422                	ld	s0,8(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret
  return 0;
 14c:	4501                	li	a0,0
 14e:	bfe5                	j	146 <strchr+0x1a>

0000000000000150 <gets>:

char*
gets(char *buf, int max)
{
 150:	711d                	addi	sp,sp,-96
 152:	ec86                	sd	ra,88(sp)
 154:	e8a2                	sd	s0,80(sp)
 156:	e4a6                	sd	s1,72(sp)
 158:	e0ca                	sd	s2,64(sp)
 15a:	fc4e                	sd	s3,56(sp)
 15c:	f852                	sd	s4,48(sp)
 15e:	f456                	sd	s5,40(sp)
 160:	f05a                	sd	s6,32(sp)
 162:	ec5e                	sd	s7,24(sp)
 164:	1080                	addi	s0,sp,96
 166:	8baa                	mv	s7,a0
 168:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16a:	892a                	mv	s2,a0
 16c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 16e:	4aa9                	li	s5,10
 170:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 172:	89a6                	mv	s3,s1
 174:	2485                	addiw	s1,s1,1
 176:	0344d663          	bge	s1,s4,1a2 <gets+0x52>
    cc = read(0, &c, 1);
 17a:	4605                	li	a2,1
 17c:	faf40593          	addi	a1,s0,-81
 180:	4501                	li	a0,0
 182:	1b2000ef          	jal	ra,334 <read>
    if(cc < 1)
 186:	00a05e63          	blez	a0,1a2 <gets+0x52>
    buf[i++] = c;
 18a:	faf44783          	lbu	a5,-81(s0)
 18e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 192:	01578763          	beq	a5,s5,1a0 <gets+0x50>
 196:	0905                	addi	s2,s2,1
 198:	fd679de3          	bne	a5,s6,172 <gets+0x22>
  for(i=0; i+1 < max; ){
 19c:	89a6                	mv	s3,s1
 19e:	a011                	j	1a2 <gets+0x52>
 1a0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a2:	99de                	add	s3,s3,s7
 1a4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a8:	855e                	mv	a0,s7
 1aa:	60e6                	ld	ra,88(sp)
 1ac:	6446                	ld	s0,80(sp)
 1ae:	64a6                	ld	s1,72(sp)
 1b0:	6906                	ld	s2,64(sp)
 1b2:	79e2                	ld	s3,56(sp)
 1b4:	7a42                	ld	s4,48(sp)
 1b6:	7aa2                	ld	s5,40(sp)
 1b8:	7b02                	ld	s6,32(sp)
 1ba:	6be2                	ld	s7,24(sp)
 1bc:	6125                	addi	sp,sp,96
 1be:	8082                	ret

00000000000001c0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c0:	1101                	addi	sp,sp,-32
 1c2:	ec06                	sd	ra,24(sp)
 1c4:	e822                	sd	s0,16(sp)
 1c6:	e426                	sd	s1,8(sp)
 1c8:	e04a                	sd	s2,0(sp)
 1ca:	1000                	addi	s0,sp,32
 1cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ce:	4581                	li	a1,0
 1d0:	18c000ef          	jal	ra,35c <open>
  if(fd < 0)
 1d4:	02054163          	bltz	a0,1f6 <stat+0x36>
 1d8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1da:	85ca                	mv	a1,s2
 1dc:	198000ef          	jal	ra,374 <fstat>
 1e0:	892a                	mv	s2,a0
  close(fd);
 1e2:	8526                	mv	a0,s1
 1e4:	160000ef          	jal	ra,344 <close>
  return r;
}
 1e8:	854a                	mv	a0,s2
 1ea:	60e2                	ld	ra,24(sp)
 1ec:	6442                	ld	s0,16(sp)
 1ee:	64a2                	ld	s1,8(sp)
 1f0:	6902                	ld	s2,0(sp)
 1f2:	6105                	addi	sp,sp,32
 1f4:	8082                	ret
    return -1;
 1f6:	597d                	li	s2,-1
 1f8:	bfc5                	j	1e8 <stat+0x28>

00000000000001fa <atoi>:

int
atoi(const char *s)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 200:	00054683          	lbu	a3,0(a0)
 204:	fd06879b          	addiw	a5,a3,-48
 208:	0ff7f793          	zext.b	a5,a5
 20c:	4625                	li	a2,9
 20e:	02f66863          	bltu	a2,a5,23e <atoi+0x44>
 212:	872a                	mv	a4,a0
  n = 0;
 214:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 216:	0705                	addi	a4,a4,1
 218:	0025179b          	slliw	a5,a0,0x2
 21c:	9fa9                	addw	a5,a5,a0
 21e:	0017979b          	slliw	a5,a5,0x1
 222:	9fb5                	addw	a5,a5,a3
 224:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 228:	00074683          	lbu	a3,0(a4)
 22c:	fd06879b          	addiw	a5,a3,-48
 230:	0ff7f793          	zext.b	a5,a5
 234:	fef671e3          	bgeu	a2,a5,216 <atoi+0x1c>
  return n;
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret
  n = 0;
 23e:	4501                	li	a0,0
 240:	bfe5                	j	238 <atoi+0x3e>

0000000000000242 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 248:	02b57463          	bgeu	a0,a1,270 <memmove+0x2e>
    while(n-- > 0)
 24c:	00c05f63          	blez	a2,26a <memmove+0x28>
 250:	1602                	slli	a2,a2,0x20
 252:	9201                	srli	a2,a2,0x20
 254:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 258:	872a                	mv	a4,a0
      *dst++ = *src++;
 25a:	0585                	addi	a1,a1,1
 25c:	0705                	addi	a4,a4,1
 25e:	fff5c683          	lbu	a3,-1(a1)
 262:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 266:	fee79ae3          	bne	a5,a4,25a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
    dst += n;
 270:	00c50733          	add	a4,a0,a2
    src += n;
 274:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 276:	fec05ae3          	blez	a2,26a <memmove+0x28>
 27a:	fff6079b          	addiw	a5,a2,-1
 27e:	1782                	slli	a5,a5,0x20
 280:	9381                	srli	a5,a5,0x20
 282:	fff7c793          	not	a5,a5
 286:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 288:	15fd                	addi	a1,a1,-1
 28a:	177d                	addi	a4,a4,-1
 28c:	0005c683          	lbu	a3,0(a1)
 290:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 294:	fee79ae3          	bne	a5,a4,288 <memmove+0x46>
 298:	bfc9                	j	26a <memmove+0x28>

000000000000029a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a0:	ca05                	beqz	a2,2d0 <memcmp+0x36>
 2a2:	fff6069b          	addiw	a3,a2,-1
 2a6:	1682                	slli	a3,a3,0x20
 2a8:	9281                	srli	a3,a3,0x20
 2aa:	0685                	addi	a3,a3,1
 2ac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	0005c703          	lbu	a4,0(a1)
 2b6:	00e79863          	bne	a5,a4,2c6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ba:	0505                	addi	a0,a0,1
    p2++;
 2bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2be:	fed518e3          	bne	a0,a3,2ae <memcmp+0x14>
  }
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	a019                	j	2ca <memcmp+0x30>
      return *p1 - *p2;
 2c6:	40e7853b          	subw	a0,a5,a4
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
  return 0;
 2d0:	4501                	li	a0,0
 2d2:	bfe5                	j	2ca <memcmp+0x30>

00000000000002d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2dc:	f67ff0ef          	jal	ra,242 <memmove>
}
 2e0:	60a2                	ld	ra,8(sp)
 2e2:	6402                	ld	s0,0(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret

00000000000002e8 <sbrk>:

char *
sbrk(int n) {
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2f0:	4585                	li	a1,1
 2f2:	0b2000ef          	jal	ra,3a4 <sys_sbrk>
}
 2f6:	60a2                	ld	ra,8(sp)
 2f8:	6402                	ld	s0,0(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret

00000000000002fe <sbrklazy>:

char *
sbrklazy(int n) {
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 306:	4589                	li	a1,2
 308:	09c000ef          	jal	ra,3a4 <sys_sbrk>
}
 30c:	60a2                	ld	ra,8(sp)
 30e:	6402                	ld	s0,0(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret

0000000000000314 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 314:	4885                	li	a7,1
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <exit>:
.global exit
exit:
 li a7, SYS_exit
 31c:	4889                	li	a7,2
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <wait>:
.global wait
wait:
 li a7, SYS_wait
 324:	488d                	li	a7,3
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32c:	4891                	li	a7,4
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <read>:
.global read
read:
 li a7, SYS_read
 334:	4895                	li	a7,5
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <write>:
.global write
write:
 li a7, SYS_write
 33c:	48c1                	li	a7,16
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <close>:
.global close
close:
 li a7, SYS_close
 344:	48d5                	li	a7,21
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <kill>:
.global kill
kill:
 li a7, SYS_kill
 34c:	4899                	li	a7,6
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <exec>:
.global exec
exec:
 li a7, SYS_exec
 354:	489d                	li	a7,7
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <open>:
.global open
open:
 li a7, SYS_open
 35c:	48bd                	li	a7,15
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 364:	48c5                	li	a7,17
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 36c:	48c9                	li	a7,18
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 374:	48a1                	li	a7,8
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <link>:
.global link
link:
 li a7, SYS_link
 37c:	48cd                	li	a7,19
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 384:	48d1                	li	a7,20
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 38c:	48a5                	li	a7,9
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <dup>:
.global dup
dup:
 li a7, SYS_dup
 394:	48a9                	li	a7,10
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 39c:	48ad                	li	a7,11
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3a4:	48b1                	li	a7,12
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ac:	48b5                	li	a7,13
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b4:	48b9                	li	a7,14
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3bc:	48d9                	li	a7,22
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3c4:	48dd                	li	a7,23
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3cc:	48e1                	li	a7,24
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d4:	48e5                	li	a7,25
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3dc:	1101                	addi	sp,sp,-32
 3de:	ec06                	sd	ra,24(sp)
 3e0:	e822                	sd	s0,16(sp)
 3e2:	1000                	addi	s0,sp,32
 3e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e8:	4605                	li	a2,1
 3ea:	fef40593          	addi	a1,s0,-17
 3ee:	f4fff0ef          	jal	ra,33c <write>
}
 3f2:	60e2                	ld	ra,24(sp)
 3f4:	6442                	ld	s0,16(sp)
 3f6:	6105                	addi	sp,sp,32
 3f8:	8082                	ret

00000000000003fa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3fa:	715d                	addi	sp,sp,-80
 3fc:	e486                	sd	ra,72(sp)
 3fe:	e0a2                	sd	s0,64(sp)
 400:	fc26                	sd	s1,56(sp)
 402:	f84a                	sd	s2,48(sp)
 404:	f44e                	sd	s3,40(sp)
 406:	0880                	addi	s0,sp,80
 408:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 40a:	c299                	beqz	a3,410 <printint+0x16>
 40c:	0805c163          	bltz	a1,48e <printint+0x94>
  neg = 0;
 410:	4881                	li	a7,0
 412:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 416:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 418:	00000517          	auipc	a0,0x0
 41c:	52850513          	addi	a0,a0,1320 # 940 <digits>
 420:	883e                	mv	a6,a5
 422:	2785                	addiw	a5,a5,1
 424:	02c5f733          	remu	a4,a1,a2
 428:	972a                	add	a4,a4,a0
 42a:	00074703          	lbu	a4,0(a4)
 42e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 432:	872e                	mv	a4,a1
 434:	02c5d5b3          	divu	a1,a1,a2
 438:	0685                	addi	a3,a3,1
 43a:	fec773e3          	bgeu	a4,a2,420 <printint+0x26>
  if(neg)
 43e:	00088b63          	beqz	a7,454 <printint+0x5a>
    buf[i++] = '-';
 442:	fd078793          	addi	a5,a5,-48
 446:	97a2                	add	a5,a5,s0
 448:	02d00713          	li	a4,45
 44c:	fee78423          	sb	a4,-24(a5)
 450:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 454:	02f05663          	blez	a5,480 <printint+0x86>
 458:	fb840713          	addi	a4,s0,-72
 45c:	00f704b3          	add	s1,a4,a5
 460:	fff70993          	addi	s3,a4,-1
 464:	99be                	add	s3,s3,a5
 466:	37fd                	addiw	a5,a5,-1
 468:	1782                	slli	a5,a5,0x20
 46a:	9381                	srli	a5,a5,0x20
 46c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 470:	fff4c583          	lbu	a1,-1(s1)
 474:	854a                	mv	a0,s2
 476:	f67ff0ef          	jal	ra,3dc <putc>
  while(--i >= 0)
 47a:	14fd                	addi	s1,s1,-1
 47c:	ff349ae3          	bne	s1,s3,470 <printint+0x76>
}
 480:	60a6                	ld	ra,72(sp)
 482:	6406                	ld	s0,64(sp)
 484:	74e2                	ld	s1,56(sp)
 486:	7942                	ld	s2,48(sp)
 488:	79a2                	ld	s3,40(sp)
 48a:	6161                	addi	sp,sp,80
 48c:	8082                	ret
    x = -xx;
 48e:	40b005b3          	neg	a1,a1
    neg = 1;
 492:	4885                	li	a7,1
    x = -xx;
 494:	bfbd                	j	412 <printint+0x18>

0000000000000496 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 496:	7119                	addi	sp,sp,-128
 498:	fc86                	sd	ra,120(sp)
 49a:	f8a2                	sd	s0,112(sp)
 49c:	f4a6                	sd	s1,104(sp)
 49e:	f0ca                	sd	s2,96(sp)
 4a0:	ecce                	sd	s3,88(sp)
 4a2:	e8d2                	sd	s4,80(sp)
 4a4:	e4d6                	sd	s5,72(sp)
 4a6:	e0da                	sd	s6,64(sp)
 4a8:	fc5e                	sd	s7,56(sp)
 4aa:	f862                	sd	s8,48(sp)
 4ac:	f466                	sd	s9,40(sp)
 4ae:	f06a                	sd	s10,32(sp)
 4b0:	ec6e                	sd	s11,24(sp)
 4b2:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b4:	0005c903          	lbu	s2,0(a1)
 4b8:	24090c63          	beqz	s2,710 <vprintf+0x27a>
 4bc:	8b2a                	mv	s6,a0
 4be:	8a2e                	mv	s4,a1
 4c0:	8bb2                	mv	s7,a2
  state = 0;
 4c2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c4:	4481                	li	s1,0
 4c6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4cc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4d0:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4d4:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4d8:	00000c97          	auipc	s9,0x0
 4dc:	468c8c93          	addi	s9,s9,1128 # 940 <digits>
 4e0:	a005                	j	500 <vprintf+0x6a>
        putc(fd, c0);
 4e2:	85ca                	mv	a1,s2
 4e4:	855a                	mv	a0,s6
 4e6:	ef7ff0ef          	jal	ra,3dc <putc>
 4ea:	a019                	j	4f0 <vprintf+0x5a>
    } else if(state == '%'){
 4ec:	03598263          	beq	s3,s5,510 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4f0:	2485                	addiw	s1,s1,1
 4f2:	8726                	mv	a4,s1
 4f4:	009a07b3          	add	a5,s4,s1
 4f8:	0007c903          	lbu	s2,0(a5)
 4fc:	20090a63          	beqz	s2,710 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 500:	0009079b          	sext.w	a5,s2
    if(state == 0){
 504:	fe0994e3          	bnez	s3,4ec <vprintf+0x56>
      if(c0 == '%'){
 508:	fd579de3          	bne	a5,s5,4e2 <vprintf+0x4c>
        state = '%';
 50c:	89be                	mv	s3,a5
 50e:	b7cd                	j	4f0 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 510:	c3c1                	beqz	a5,590 <vprintf+0xfa>
 512:	00ea06b3          	add	a3,s4,a4
 516:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 51a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 51c:	c681                	beqz	a3,524 <vprintf+0x8e>
 51e:	9752                	add	a4,a4,s4
 520:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 524:	03878e63          	beq	a5,s8,560 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 528:	05a78863          	beq	a5,s10,578 <vprintf+0xe2>
      } else if(c0 == 'u'){
 52c:	0db78b63          	beq	a5,s11,602 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 530:	07800713          	li	a4,120
 534:	10e78d63          	beq	a5,a4,64e <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 538:	07000713          	li	a4,112
 53c:	14e78263          	beq	a5,a4,680 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 540:	06300713          	li	a4,99
 544:	16e78f63          	beq	a5,a4,6c2 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 548:	07300713          	li	a4,115
 54c:	18e78563          	beq	a5,a4,6d6 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 550:	05579063          	bne	a5,s5,590 <vprintf+0xfa>
        putc(fd, '%');
 554:	85d6                	mv	a1,s5
 556:	855a                	mv	a0,s6
 558:	e85ff0ef          	jal	ra,3dc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 55c:	4981                	li	s3,0
 55e:	bf49                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 560:	008b8913          	addi	s2,s7,8
 564:	4685                	li	a3,1
 566:	4629                	li	a2,10
 568:	000ba583          	lw	a1,0(s7)
 56c:	855a                	mv	a0,s6
 56e:	e8dff0ef          	jal	ra,3fa <printint>
 572:	8bca                	mv	s7,s2
      state = 0;
 574:	4981                	li	s3,0
 576:	bfad                	j	4f0 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 578:	03868663          	beq	a3,s8,5a4 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 57c:	05a68163          	beq	a3,s10,5be <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 580:	09b68d63          	beq	a3,s11,61a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 584:	03a68f63          	beq	a3,s10,5c2 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 588:	07800793          	li	a5,120
 58c:	0cf68d63          	beq	a3,a5,666 <vprintf+0x1d0>
        putc(fd, '%');
 590:	85d6                	mv	a1,s5
 592:	855a                	mv	a0,s6
 594:	e49ff0ef          	jal	ra,3dc <putc>
        putc(fd, c0);
 598:	85ca                	mv	a1,s2
 59a:	855a                	mv	a0,s6
 59c:	e41ff0ef          	jal	ra,3dc <putc>
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	b7b9                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a4:	008b8913          	addi	s2,s7,8
 5a8:	4685                	li	a3,1
 5aa:	4629                	li	a2,10
 5ac:	000bb583          	ld	a1,0(s7)
 5b0:	855a                	mv	a0,s6
 5b2:	e49ff0ef          	jal	ra,3fa <printint>
        i += 1;
 5b6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b8:	8bca                	mv	s7,s2
      state = 0;
 5ba:	4981                	li	s3,0
        i += 1;
 5bc:	bf15                	j	4f0 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5be:	03860563          	beq	a2,s8,5e8 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c2:	07b60963          	beq	a2,s11,634 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5c6:	07800793          	li	a5,120
 5ca:	fcf613e3          	bne	a2,a5,590 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4641                	li	a2,16
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e1fff0ef          	jal	ra,3fa <printint>
        i += 2;
 5e0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 2;
 5e6:	b729                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e8:	008b8913          	addi	s2,s7,8
 5ec:	4685                	li	a3,1
 5ee:	4629                	li	a2,10
 5f0:	000bb583          	ld	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	e05ff0ef          	jal	ra,3fa <printint>
        i += 2;
 5fa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
        i += 2;
 600:	bdc5                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 602:	008b8913          	addi	s2,s7,8
 606:	4681                	li	a3,0
 608:	4629                	li	a2,10
 60a:	000be583          	lwu	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	debff0ef          	jal	ra,3fa <printint>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	bde1                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	dd3ff0ef          	jal	ra,3fa <printint>
        i += 1;
 62c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 1;
 632:	bd7d                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 634:	008b8913          	addi	s2,s7,8
 638:	4681                	li	a3,0
 63a:	4629                	li	a2,10
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	db9ff0ef          	jal	ra,3fa <printint>
        i += 2;
 646:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
        i += 2;
 64c:	b555                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 64e:	008b8913          	addi	s2,s7,8
 652:	4681                	li	a3,0
 654:	4641                	li	a2,16
 656:	000be583          	lwu	a1,0(s7)
 65a:	855a                	mv	a0,s6
 65c:	d9fff0ef          	jal	ra,3fa <printint>
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	b571                	j	4f0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 666:	008b8913          	addi	s2,s7,8
 66a:	4681                	li	a3,0
 66c:	4641                	li	a2,16
 66e:	000bb583          	ld	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	d87ff0ef          	jal	ra,3fa <printint>
        i += 1;
 678:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
        i += 1;
 67e:	bd8d                	j	4f0 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 680:	008b8793          	addi	a5,s7,8
 684:	f8f43423          	sd	a5,-120(s0)
 688:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 68c:	03000593          	li	a1,48
 690:	855a                	mv	a0,s6
 692:	d4bff0ef          	jal	ra,3dc <putc>
  putc(fd, 'x');
 696:	07800593          	li	a1,120
 69a:	855a                	mv	a0,s6
 69c:	d41ff0ef          	jal	ra,3dc <putc>
 6a0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a2:	03c9d793          	srli	a5,s3,0x3c
 6a6:	97e6                	add	a5,a5,s9
 6a8:	0007c583          	lbu	a1,0(a5)
 6ac:	855a                	mv	a0,s6
 6ae:	d2fff0ef          	jal	ra,3dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b2:	0992                	slli	s3,s3,0x4
 6b4:	397d                	addiw	s2,s2,-1
 6b6:	fe0916e3          	bnez	s2,6a2 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6ba:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bd05                	j	4f0 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	000bc583          	lbu	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	d11ff0ef          	jal	ra,3dc <putc>
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bd31                	j	4f0 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6d6:	008b8993          	addi	s3,s7,8
 6da:	000bb903          	ld	s2,0(s7)
 6de:	00090f63          	beqz	s2,6fc <vprintf+0x266>
        for(; *s; s++)
 6e2:	00094583          	lbu	a1,0(s2)
 6e6:	c195                	beqz	a1,70a <vprintf+0x274>
          putc(fd, *s);
 6e8:	855a                	mv	a0,s6
 6ea:	cf3ff0ef          	jal	ra,3dc <putc>
        for(; *s; s++)
 6ee:	0905                	addi	s2,s2,1
 6f0:	00094583          	lbu	a1,0(s2)
 6f4:	f9f5                	bnez	a1,6e8 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6f6:	8bce                	mv	s7,s3
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bbdd                	j	4f0 <vprintf+0x5a>
          s = "(null)";
 6fc:	00000917          	auipc	s2,0x0
 700:	23c90913          	addi	s2,s2,572 # 938 <malloc+0x12c>
        for(; *s; s++)
 704:	02800593          	li	a1,40
 708:	b7c5                	j	6e8 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 70a:	8bce                	mv	s7,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b3cd                	j	4f0 <vprintf+0x5a>
    }
  }
}
 710:	70e6                	ld	ra,120(sp)
 712:	7446                	ld	s0,112(sp)
 714:	74a6                	ld	s1,104(sp)
 716:	7906                	ld	s2,96(sp)
 718:	69e6                	ld	s3,88(sp)
 71a:	6a46                	ld	s4,80(sp)
 71c:	6aa6                	ld	s5,72(sp)
 71e:	6b06                	ld	s6,64(sp)
 720:	7be2                	ld	s7,56(sp)
 722:	7c42                	ld	s8,48(sp)
 724:	7ca2                	ld	s9,40(sp)
 726:	7d02                	ld	s10,32(sp)
 728:	6de2                	ld	s11,24(sp)
 72a:	6109                	addi	sp,sp,128
 72c:	8082                	ret

000000000000072e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72e:	715d                	addi	sp,sp,-80
 730:	ec06                	sd	ra,24(sp)
 732:	e822                	sd	s0,16(sp)
 734:	1000                	addi	s0,sp,32
 736:	e010                	sd	a2,0(s0)
 738:	e414                	sd	a3,8(s0)
 73a:	e818                	sd	a4,16(s0)
 73c:	ec1c                	sd	a5,24(s0)
 73e:	03043023          	sd	a6,32(s0)
 742:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 746:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 74a:	8622                	mv	a2,s0
 74c:	d4bff0ef          	jal	ra,496 <vprintf>
}
 750:	60e2                	ld	ra,24(sp)
 752:	6442                	ld	s0,16(sp)
 754:	6161                	addi	sp,sp,80
 756:	8082                	ret

0000000000000758 <printf>:

void
printf(const char *fmt, ...)
{
 758:	711d                	addi	sp,sp,-96
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	1000                	addi	s0,sp,32
 760:	e40c                	sd	a1,8(s0)
 762:	e810                	sd	a2,16(s0)
 764:	ec14                	sd	a3,24(s0)
 766:	f018                	sd	a4,32(s0)
 768:	f41c                	sd	a5,40(s0)
 76a:	03043823          	sd	a6,48(s0)
 76e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 772:	00840613          	addi	a2,s0,8
 776:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 77a:	85aa                	mv	a1,a0
 77c:	4505                	li	a0,1
 77e:	d19ff0ef          	jal	ra,496 <vprintf>
}
 782:	60e2                	ld	ra,24(sp)
 784:	6442                	ld	s0,16(sp)
 786:	6125                	addi	sp,sp,96
 788:	8082                	ret

000000000000078a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78a:	1141                	addi	sp,sp,-16
 78c:	e422                	sd	s0,8(sp)
 78e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 790:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 794:	00001797          	auipc	a5,0x1
 798:	87c7b783          	ld	a5,-1924(a5) # 1010 <freep>
 79c:	a02d                	j	7c6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79e:	4618                	lw	a4,8(a2)
 7a0:	9f2d                	addw	a4,a4,a1
 7a2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a6:	6398                	ld	a4,0(a5)
 7a8:	6310                	ld	a2,0(a4)
 7aa:	a83d                	j	7e8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ac:	ff852703          	lw	a4,-8(a0)
 7b0:	9f31                	addw	a4,a4,a2
 7b2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b4:	ff053683          	ld	a3,-16(a0)
 7b8:	a091                	j	7fc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ba:	6398                	ld	a4,0(a5)
 7bc:	00e7e463          	bltu	a5,a4,7c4 <free+0x3a>
 7c0:	00e6ea63          	bltu	a3,a4,7d4 <free+0x4a>
{
 7c4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c6:	fed7fae3          	bgeu	a5,a3,7ba <free+0x30>
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e6e463          	bltu	a3,a4,7d4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d0:	fee7eae3          	bltu	a5,a4,7c4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d4:	ff852583          	lw	a1,-8(a0)
 7d8:	6390                	ld	a2,0(a5)
 7da:	02059813          	slli	a6,a1,0x20
 7de:	01c85713          	srli	a4,a6,0x1c
 7e2:	9736                	add	a4,a4,a3
 7e4:	fae60de3          	beq	a2,a4,79e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7e8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ec:	4790                	lw	a2,8(a5)
 7ee:	02061593          	slli	a1,a2,0x20
 7f2:	01c5d713          	srli	a4,a1,0x1c
 7f6:	973e                	add	a4,a4,a5
 7f8:	fae68ae3          	beq	a3,a4,7ac <free+0x22>
    p->s.ptr = bp->s.ptr;
 7fc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7fe:	00001717          	auipc	a4,0x1
 802:	80f73923          	sd	a5,-2030(a4) # 1010 <freep>
}
 806:	6422                	ld	s0,8(sp)
 808:	0141                	addi	sp,sp,16
 80a:	8082                	ret

000000000000080c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80c:	7139                	addi	sp,sp,-64
 80e:	fc06                	sd	ra,56(sp)
 810:	f822                	sd	s0,48(sp)
 812:	f426                	sd	s1,40(sp)
 814:	f04a                	sd	s2,32(sp)
 816:	ec4e                	sd	s3,24(sp)
 818:	e852                	sd	s4,16(sp)
 81a:	e456                	sd	s5,8(sp)
 81c:	e05a                	sd	s6,0(sp)
 81e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 820:	02051493          	slli	s1,a0,0x20
 824:	9081                	srli	s1,s1,0x20
 826:	04bd                	addi	s1,s1,15
 828:	8091                	srli	s1,s1,0x4
 82a:	0014899b          	addiw	s3,s1,1
 82e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 830:	00000517          	auipc	a0,0x0
 834:	7e053503          	ld	a0,2016(a0) # 1010 <freep>
 838:	c515                	beqz	a0,864 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83c:	4798                	lw	a4,8(a5)
 83e:	02977f63          	bgeu	a4,s1,87c <malloc+0x70>
 842:	8a4e                	mv	s4,s3
 844:	0009871b          	sext.w	a4,s3
 848:	6685                	lui	a3,0x1
 84a:	00d77363          	bgeu	a4,a3,850 <malloc+0x44>
 84e:	6a05                	lui	s4,0x1
 850:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 854:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 858:	00000917          	auipc	s2,0x0
 85c:	7b890913          	addi	s2,s2,1976 # 1010 <freep>
  if(p == SBRK_ERROR)
 860:	5afd                	li	s5,-1
 862:	a885                	j	8d2 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 864:	00000797          	auipc	a5,0x0
 868:	7bc78793          	addi	a5,a5,1980 # 1020 <base>
 86c:	00000717          	auipc	a4,0x0
 870:	7af73223          	sd	a5,1956(a4) # 1010 <freep>
 874:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 876:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87a:	b7e1                	j	842 <malloc+0x36>
      if(p->s.size == nunits)
 87c:	02e48c63          	beq	s1,a4,8b4 <malloc+0xa8>
        p->s.size -= nunits;
 880:	4137073b          	subw	a4,a4,s3
 884:	c798                	sw	a4,8(a5)
        p += p->s.size;
 886:	02071693          	slli	a3,a4,0x20
 88a:	01c6d713          	srli	a4,a3,0x1c
 88e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 890:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 894:	00000717          	auipc	a4,0x0
 898:	76a73e23          	sd	a0,1916(a4) # 1010 <freep>
      return (void*)(p + 1);
 89c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a0:	70e2                	ld	ra,56(sp)
 8a2:	7442                	ld	s0,48(sp)
 8a4:	74a2                	ld	s1,40(sp)
 8a6:	7902                	ld	s2,32(sp)
 8a8:	69e2                	ld	s3,24(sp)
 8aa:	6a42                	ld	s4,16(sp)
 8ac:	6aa2                	ld	s5,8(sp)
 8ae:	6b02                	ld	s6,0(sp)
 8b0:	6121                	addi	sp,sp,64
 8b2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b4:	6398                	ld	a4,0(a5)
 8b6:	e118                	sd	a4,0(a0)
 8b8:	bff1                	j	894 <malloc+0x88>
  hp->s.size = nu;
 8ba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8be:	0541                	addi	a0,a0,16
 8c0:	ecbff0ef          	jal	ra,78a <free>
  return freep;
 8c4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c8:	dd61                	beqz	a0,8a0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8cc:	4798                	lw	a4,8(a5)
 8ce:	fa9777e3          	bgeu	a4,s1,87c <malloc+0x70>
    if(p == freep)
 8d2:	00093703          	ld	a4,0(s2)
 8d6:	853e                	mv	a0,a5
 8d8:	fef719e3          	bne	a4,a5,8ca <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 8dc:	8552                	mv	a0,s4
 8de:	a0bff0ef          	jal	ra,2e8 <sbrk>
  if(p == SBRK_ERROR)
 8e2:	fd551ce3          	bne	a0,s5,8ba <malloc+0xae>
        return 0;
 8e6:	4501                	li	a0,0
 8e8:	bf65                	j	8a0 <malloc+0x94>
