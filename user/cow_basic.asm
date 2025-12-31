
user/_cow_basic：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

int x = 1;

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  int pid = fork();
   a:	30e000ef          	jal	ra,318 <fork>
  if(pid < 0){
   e:	02054263          	bltz	a0,32 <main+0x32>
    printf("fork failed\n");
    exit(1);
  }
  if(pid == 0){
  12:	e90d                	bnez	a0,44 <main+0x44>
    x = 2;
  14:	4789                	li	a5,2
  16:	00001717          	auipc	a4,0x1
  1a:	fef72523          	sw	a5,-22(a4) # 1000 <x>
    printf("child: x=%d\n", x);
  1e:	4589                	li	a1,2
  20:	00001517          	auipc	a0,0x1
  24:	8e050513          	addi	a0,a0,-1824 # 900 <malloc+0xf0>
  28:	734000ef          	jal	ra,75c <printf>
    exit(0);
  2c:	4501                	li	a0,0
  2e:	2f2000ef          	jal	ra,320 <exit>
    printf("fork failed\n");
  32:	00001517          	auipc	a0,0x1
  36:	8be50513          	addi	a0,a0,-1858 # 8f0 <malloc+0xe0>
  3a:	722000ef          	jal	ra,75c <printf>
    exit(1);
  3e:	4505                	li	a0,1
  40:	2e0000ef          	jal	ra,320 <exit>
  }
  wait(0);
  44:	4501                	li	a0,0
  46:	2e2000ef          	jal	ra,328 <wait>
  printf("parent: x=%d\n", x);
  4a:	00001497          	auipc	s1,0x1
  4e:	fb648493          	addi	s1,s1,-74 # 1000 <x>
  52:	408c                	lw	a1,0(s1)
  54:	00001517          	auipc	a0,0x1
  58:	8bc50513          	addi	a0,a0,-1860 # 910 <malloc+0x100>
  5c:	700000ef          	jal	ra,75c <printf>
  if(x != 1){
  60:	408c                	lw	a1,0(s1)
  62:	4785                	li	a5,1
  64:	00f58b63          	beq	a1,a5,7a <main+0x7a>
    printf("FAIL: parent saw x=%d\n", x);
  68:	00001517          	auipc	a0,0x1
  6c:	8b850513          	addi	a0,a0,-1864 # 920 <malloc+0x110>
  70:	6ec000ef          	jal	ra,75c <printf>
    exit(1);
  74:	4505                	li	a0,1
  76:	2aa000ef          	jal	ra,320 <exit>
  }
  printf("PASS\n");
  7a:	00001517          	auipc	a0,0x1
  7e:	8be50513          	addi	a0,a0,-1858 # 938 <malloc+0x128>
  82:	6da000ef          	jal	ra,75c <printf>
  exit(0);
  86:	4501                	li	a0,0
  88:	298000ef          	jal	ra,320 <exit>

000000000000008c <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e406                	sd	ra,8(sp)
  90:	e022                	sd	s0,0(sp)
  92:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  94:	f6dff0ef          	jal	ra,0 <main>
  exit(r);
  98:	288000ef          	jal	ra,320 <exit>

000000000000009c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a2:	87aa                	mv	a5,a0
  a4:	0585                	addi	a1,a1,1
  a6:	0785                	addi	a5,a5,1
  a8:	fff5c703          	lbu	a4,-1(a1)
  ac:	fee78fa3          	sb	a4,-1(a5)
  b0:	fb75                	bnez	a4,a4 <strcpy+0x8>
    ;
  return os;
}
  b2:	6422                	ld	s0,8(sp)
  b4:	0141                	addi	sp,sp,16
  b6:	8082                	ret

00000000000000b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  be:	00054783          	lbu	a5,0(a0)
  c2:	cb91                	beqz	a5,d6 <strcmp+0x1e>
  c4:	0005c703          	lbu	a4,0(a1)
  c8:	00f71763          	bne	a4,a5,d6 <strcmp+0x1e>
    p++, q++;
  cc:	0505                	addi	a0,a0,1
  ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d0:	00054783          	lbu	a5,0(a0)
  d4:	fbe5                	bnez	a5,c4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d6:	0005c503          	lbu	a0,0(a1)
}
  da:	40a7853b          	subw	a0,a5,a0
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strlen>:

uint
strlen(const char *s)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cf91                	beqz	a5,10a <strlen+0x26>
  f0:	0505                	addi	a0,a0,1
  f2:	87aa                	mv	a5,a0
  f4:	4685                	li	a3,1
  f6:	9e89                	subw	a3,a3,a0
  f8:	00f6853b          	addw	a0,a3,a5
  fc:	0785                	addi	a5,a5,1
  fe:	fff7c703          	lbu	a4,-1(a5)
 102:	fb7d                	bnez	a4,f8 <strlen+0x14>
    ;
  return n;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret
  for(n = 0; s[n]; n++)
 10a:	4501                	li	a0,0
 10c:	bfe5                	j	104 <strlen+0x20>

000000000000010e <memset>:

void*
memset(void *dst, int c, uint n)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 114:	ca19                	beqz	a2,12a <memset+0x1c>
 116:	87aa                	mv	a5,a0
 118:	1602                	slli	a2,a2,0x20
 11a:	9201                	srli	a2,a2,0x20
 11c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 120:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 124:	0785                	addi	a5,a5,1
 126:	fee79de3          	bne	a5,a4,120 <memset+0x12>
  }
  return dst;
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strchr>:

char*
strchr(const char *s, char c)
{
 130:	1141                	addi	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	addi	s0,sp,16
  for(; *s; s++)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cb99                	beqz	a5,150 <strchr+0x20>
    if(*s == c)
 13c:	00f58763          	beq	a1,a5,14a <strchr+0x1a>
  for(; *s; s++)
 140:	0505                	addi	a0,a0,1
 142:	00054783          	lbu	a5,0(a0)
 146:	fbfd                	bnez	a5,13c <strchr+0xc>
      return (char*)s;
  return 0;
 148:	4501                	li	a0,0
}
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret
  return 0;
 150:	4501                	li	a0,0
 152:	bfe5                	j	14a <strchr+0x1a>

0000000000000154 <gets>:

char*
gets(char *buf, int max)
{
 154:	711d                	addi	sp,sp,-96
 156:	ec86                	sd	ra,88(sp)
 158:	e8a2                	sd	s0,80(sp)
 15a:	e4a6                	sd	s1,72(sp)
 15c:	e0ca                	sd	s2,64(sp)
 15e:	fc4e                	sd	s3,56(sp)
 160:	f852                	sd	s4,48(sp)
 162:	f456                	sd	s5,40(sp)
 164:	f05a                	sd	s6,32(sp)
 166:	ec5e                	sd	s7,24(sp)
 168:	1080                	addi	s0,sp,96
 16a:	8baa                	mv	s7,a0
 16c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16e:	892a                	mv	s2,a0
 170:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 172:	4aa9                	li	s5,10
 174:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 176:	89a6                	mv	s3,s1
 178:	2485                	addiw	s1,s1,1
 17a:	0344d663          	bge	s1,s4,1a6 <gets+0x52>
    cc = read(0, &c, 1);
 17e:	4605                	li	a2,1
 180:	faf40593          	addi	a1,s0,-81
 184:	4501                	li	a0,0
 186:	1b2000ef          	jal	ra,338 <read>
    if(cc < 1)
 18a:	00a05e63          	blez	a0,1a6 <gets+0x52>
    buf[i++] = c;
 18e:	faf44783          	lbu	a5,-81(s0)
 192:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 196:	01578763          	beq	a5,s5,1a4 <gets+0x50>
 19a:	0905                	addi	s2,s2,1
 19c:	fd679de3          	bne	a5,s6,176 <gets+0x22>
  for(i=0; i+1 < max; ){
 1a0:	89a6                	mv	s3,s1
 1a2:	a011                	j	1a6 <gets+0x52>
 1a4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a6:	99de                	add	s3,s3,s7
 1a8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ac:	855e                	mv	a0,s7
 1ae:	60e6                	ld	ra,88(sp)
 1b0:	6446                	ld	s0,80(sp)
 1b2:	64a6                	ld	s1,72(sp)
 1b4:	6906                	ld	s2,64(sp)
 1b6:	79e2                	ld	s3,56(sp)
 1b8:	7a42                	ld	s4,48(sp)
 1ba:	7aa2                	ld	s5,40(sp)
 1bc:	7b02                	ld	s6,32(sp)
 1be:	6be2                	ld	s7,24(sp)
 1c0:	6125                	addi	sp,sp,96
 1c2:	8082                	ret

00000000000001c4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c4:	1101                	addi	sp,sp,-32
 1c6:	ec06                	sd	ra,24(sp)
 1c8:	e822                	sd	s0,16(sp)
 1ca:	e426                	sd	s1,8(sp)
 1cc:	e04a                	sd	s2,0(sp)
 1ce:	1000                	addi	s0,sp,32
 1d0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d2:	4581                	li	a1,0
 1d4:	18c000ef          	jal	ra,360 <open>
  if(fd < 0)
 1d8:	02054163          	bltz	a0,1fa <stat+0x36>
 1dc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1de:	85ca                	mv	a1,s2
 1e0:	198000ef          	jal	ra,378 <fstat>
 1e4:	892a                	mv	s2,a0
  close(fd);
 1e6:	8526                	mv	a0,s1
 1e8:	160000ef          	jal	ra,348 <close>
  return r;
}
 1ec:	854a                	mv	a0,s2
 1ee:	60e2                	ld	ra,24(sp)
 1f0:	6442                	ld	s0,16(sp)
 1f2:	64a2                	ld	s1,8(sp)
 1f4:	6902                	ld	s2,0(sp)
 1f6:	6105                	addi	sp,sp,32
 1f8:	8082                	ret
    return -1;
 1fa:	597d                	li	s2,-1
 1fc:	bfc5                	j	1ec <stat+0x28>

00000000000001fe <atoi>:

int
atoi(const char *s)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 204:	00054683          	lbu	a3,0(a0)
 208:	fd06879b          	addiw	a5,a3,-48
 20c:	0ff7f793          	zext.b	a5,a5
 210:	4625                	li	a2,9
 212:	02f66863          	bltu	a2,a5,242 <atoi+0x44>
 216:	872a                	mv	a4,a0
  n = 0;
 218:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 21a:	0705                	addi	a4,a4,1
 21c:	0025179b          	slliw	a5,a0,0x2
 220:	9fa9                	addw	a5,a5,a0
 222:	0017979b          	slliw	a5,a5,0x1
 226:	9fb5                	addw	a5,a5,a3
 228:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22c:	00074683          	lbu	a3,0(a4)
 230:	fd06879b          	addiw	a5,a3,-48
 234:	0ff7f793          	zext.b	a5,a5
 238:	fef671e3          	bgeu	a2,a5,21a <atoi+0x1c>
  return n;
}
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret
  n = 0;
 242:	4501                	li	a0,0
 244:	bfe5                	j	23c <atoi+0x3e>

0000000000000246 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 24c:	02b57463          	bgeu	a0,a1,274 <memmove+0x2e>
    while(n-- > 0)
 250:	00c05f63          	blez	a2,26e <memmove+0x28>
 254:	1602                	slli	a2,a2,0x20
 256:	9201                	srli	a2,a2,0x20
 258:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 25c:	872a                	mv	a4,a0
      *dst++ = *src++;
 25e:	0585                	addi	a1,a1,1
 260:	0705                	addi	a4,a4,1
 262:	fff5c683          	lbu	a3,-1(a1)
 266:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 26a:	fee79ae3          	bne	a5,a4,25e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret
    dst += n;
 274:	00c50733          	add	a4,a0,a2
    src += n;
 278:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 27a:	fec05ae3          	blez	a2,26e <memmove+0x28>
 27e:	fff6079b          	addiw	a5,a2,-1
 282:	1782                	slli	a5,a5,0x20
 284:	9381                	srli	a5,a5,0x20
 286:	fff7c793          	not	a5,a5
 28a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 28c:	15fd                	addi	a1,a1,-1
 28e:	177d                	addi	a4,a4,-1
 290:	0005c683          	lbu	a3,0(a1)
 294:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 298:	fee79ae3          	bne	a5,a4,28c <memmove+0x46>
 29c:	bfc9                	j	26e <memmove+0x28>

000000000000029e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a4:	ca05                	beqz	a2,2d4 <memcmp+0x36>
 2a6:	fff6069b          	addiw	a3,a2,-1
 2aa:	1682                	slli	a3,a3,0x20
 2ac:	9281                	srli	a3,a3,0x20
 2ae:	0685                	addi	a3,a3,1
 2b0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b2:	00054783          	lbu	a5,0(a0)
 2b6:	0005c703          	lbu	a4,0(a1)
 2ba:	00e79863          	bne	a5,a4,2ca <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2be:	0505                	addi	a0,a0,1
    p2++;
 2c0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c2:	fed518e3          	bne	a0,a3,2b2 <memcmp+0x14>
  }
  return 0;
 2c6:	4501                	li	a0,0
 2c8:	a019                	j	2ce <memcmp+0x30>
      return *p1 - *p2;
 2ca:	40e7853b          	subw	a0,a5,a4
}
 2ce:	6422                	ld	s0,8(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret
  return 0;
 2d4:	4501                	li	a0,0
 2d6:	bfe5                	j	2ce <memcmp+0x30>

00000000000002d8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e0:	f67ff0ef          	jal	ra,246 <memmove>
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <sbrk>:

char *
sbrk(int n) {
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e406                	sd	ra,8(sp)
 2f0:	e022                	sd	s0,0(sp)
 2f2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2f4:	4585                	li	a1,1
 2f6:	0b2000ef          	jal	ra,3a8 <sys_sbrk>
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret

0000000000000302 <sbrklazy>:

char *
sbrklazy(int n) {
 302:	1141                	addi	sp,sp,-16
 304:	e406                	sd	ra,8(sp)
 306:	e022                	sd	s0,0(sp)
 308:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 30a:	4589                	li	a1,2
 30c:	09c000ef          	jal	ra,3a8 <sys_sbrk>
}
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret

0000000000000318 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 318:	4885                	li	a7,1
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exit>:
.global exit
exit:
 li a7, SYS_exit
 320:	4889                	li	a7,2
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <wait>:
.global wait
wait:
 li a7, SYS_wait
 328:	488d                	li	a7,3
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 330:	4891                	li	a7,4
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <read>:
.global read
read:
 li a7, SYS_read
 338:	4895                	li	a7,5
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <write>:
.global write
write:
 li a7, SYS_write
 340:	48c1                	li	a7,16
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <close>:
.global close
close:
 li a7, SYS_close
 348:	48d5                	li	a7,21
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <kill>:
.global kill
kill:
 li a7, SYS_kill
 350:	4899                	li	a7,6
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exec>:
.global exec
exec:
 li a7, SYS_exec
 358:	489d                	li	a7,7
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <open>:
.global open
open:
 li a7, SYS_open
 360:	48bd                	li	a7,15
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 368:	48c5                	li	a7,17
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 370:	48c9                	li	a7,18
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 378:	48a1                	li	a7,8
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <link>:
.global link
link:
 li a7, SYS_link
 380:	48cd                	li	a7,19
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 388:	48d1                	li	a7,20
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 390:	48a5                	li	a7,9
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <dup>:
.global dup
dup:
 li a7, SYS_dup
 398:	48a9                	li	a7,10
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a0:	48ad                	li	a7,11
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3a8:	48b1                	li	a7,12
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3b0:	48b5                	li	a7,13
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b8:	48b9                	li	a7,14
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3c0:	48d9                	li	a7,22
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3c8:	48dd                	li	a7,23
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3d0:	48e1                	li	a7,24
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d8:	48e5                	li	a7,25
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e0:	1101                	addi	sp,sp,-32
 3e2:	ec06                	sd	ra,24(sp)
 3e4:	e822                	sd	s0,16(sp)
 3e6:	1000                	addi	s0,sp,32
 3e8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ec:	4605                	li	a2,1
 3ee:	fef40593          	addi	a1,s0,-17
 3f2:	f4fff0ef          	jal	ra,340 <write>
}
 3f6:	60e2                	ld	ra,24(sp)
 3f8:	6442                	ld	s0,16(sp)
 3fa:	6105                	addi	sp,sp,32
 3fc:	8082                	ret

00000000000003fe <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3fe:	715d                	addi	sp,sp,-80
 400:	e486                	sd	ra,72(sp)
 402:	e0a2                	sd	s0,64(sp)
 404:	fc26                	sd	s1,56(sp)
 406:	f84a                	sd	s2,48(sp)
 408:	f44e                	sd	s3,40(sp)
 40a:	0880                	addi	s0,sp,80
 40c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 40e:	c299                	beqz	a3,414 <printint+0x16>
 410:	0805c163          	bltz	a1,492 <printint+0x94>
  neg = 0;
 414:	4881                	li	a7,0
 416:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 41a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 41c:	00000517          	auipc	a0,0x0
 420:	52c50513          	addi	a0,a0,1324 # 948 <digits>
 424:	883e                	mv	a6,a5
 426:	2785                	addiw	a5,a5,1
 428:	02c5f733          	remu	a4,a1,a2
 42c:	972a                	add	a4,a4,a0
 42e:	00074703          	lbu	a4,0(a4)
 432:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 436:	872e                	mv	a4,a1
 438:	02c5d5b3          	divu	a1,a1,a2
 43c:	0685                	addi	a3,a3,1
 43e:	fec773e3          	bgeu	a4,a2,424 <printint+0x26>
  if(neg)
 442:	00088b63          	beqz	a7,458 <printint+0x5a>
    buf[i++] = '-';
 446:	fd078793          	addi	a5,a5,-48
 44a:	97a2                	add	a5,a5,s0
 44c:	02d00713          	li	a4,45
 450:	fee78423          	sb	a4,-24(a5)
 454:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 458:	02f05663          	blez	a5,484 <printint+0x86>
 45c:	fb840713          	addi	a4,s0,-72
 460:	00f704b3          	add	s1,a4,a5
 464:	fff70993          	addi	s3,a4,-1
 468:	99be                	add	s3,s3,a5
 46a:	37fd                	addiw	a5,a5,-1
 46c:	1782                	slli	a5,a5,0x20
 46e:	9381                	srli	a5,a5,0x20
 470:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 474:	fff4c583          	lbu	a1,-1(s1)
 478:	854a                	mv	a0,s2
 47a:	f67ff0ef          	jal	ra,3e0 <putc>
  while(--i >= 0)
 47e:	14fd                	addi	s1,s1,-1
 480:	ff349ae3          	bne	s1,s3,474 <printint+0x76>
}
 484:	60a6                	ld	ra,72(sp)
 486:	6406                	ld	s0,64(sp)
 488:	74e2                	ld	s1,56(sp)
 48a:	7942                	ld	s2,48(sp)
 48c:	79a2                	ld	s3,40(sp)
 48e:	6161                	addi	sp,sp,80
 490:	8082                	ret
    x = -xx;
 492:	40b005b3          	neg	a1,a1
    neg = 1;
 496:	4885                	li	a7,1
    x = -xx;
 498:	bfbd                	j	416 <printint+0x18>

000000000000049a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49a:	7119                	addi	sp,sp,-128
 49c:	fc86                	sd	ra,120(sp)
 49e:	f8a2                	sd	s0,112(sp)
 4a0:	f4a6                	sd	s1,104(sp)
 4a2:	f0ca                	sd	s2,96(sp)
 4a4:	ecce                	sd	s3,88(sp)
 4a6:	e8d2                	sd	s4,80(sp)
 4a8:	e4d6                	sd	s5,72(sp)
 4aa:	e0da                	sd	s6,64(sp)
 4ac:	fc5e                	sd	s7,56(sp)
 4ae:	f862                	sd	s8,48(sp)
 4b0:	f466                	sd	s9,40(sp)
 4b2:	f06a                	sd	s10,32(sp)
 4b4:	ec6e                	sd	s11,24(sp)
 4b6:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b8:	0005c903          	lbu	s2,0(a1)
 4bc:	24090c63          	beqz	s2,714 <vprintf+0x27a>
 4c0:	8b2a                	mv	s6,a0
 4c2:	8a2e                	mv	s4,a1
 4c4:	8bb2                	mv	s7,a2
  state = 0;
 4c6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c8:	4481                	li	s1,0
 4ca:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4cc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4d4:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4d8:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4dc:	00000c97          	auipc	s9,0x0
 4e0:	46cc8c93          	addi	s9,s9,1132 # 948 <digits>
 4e4:	a005                	j	504 <vprintf+0x6a>
        putc(fd, c0);
 4e6:	85ca                	mv	a1,s2
 4e8:	855a                	mv	a0,s6
 4ea:	ef7ff0ef          	jal	ra,3e0 <putc>
 4ee:	a019                	j	4f4 <vprintf+0x5a>
    } else if(state == '%'){
 4f0:	03598263          	beq	s3,s5,514 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4f4:	2485                	addiw	s1,s1,1
 4f6:	8726                	mv	a4,s1
 4f8:	009a07b3          	add	a5,s4,s1
 4fc:	0007c903          	lbu	s2,0(a5)
 500:	20090a63          	beqz	s2,714 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 504:	0009079b          	sext.w	a5,s2
    if(state == 0){
 508:	fe0994e3          	bnez	s3,4f0 <vprintf+0x56>
      if(c0 == '%'){
 50c:	fd579de3          	bne	a5,s5,4e6 <vprintf+0x4c>
        state = '%';
 510:	89be                	mv	s3,a5
 512:	b7cd                	j	4f4 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 514:	c3c1                	beqz	a5,594 <vprintf+0xfa>
 516:	00ea06b3          	add	a3,s4,a4
 51a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 51e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 520:	c681                	beqz	a3,528 <vprintf+0x8e>
 522:	9752                	add	a4,a4,s4
 524:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 528:	03878e63          	beq	a5,s8,564 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 52c:	05a78863          	beq	a5,s10,57c <vprintf+0xe2>
      } else if(c0 == 'u'){
 530:	0db78b63          	beq	a5,s11,606 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 534:	07800713          	li	a4,120
 538:	10e78d63          	beq	a5,a4,652 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 53c:	07000713          	li	a4,112
 540:	14e78263          	beq	a5,a4,684 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 544:	06300713          	li	a4,99
 548:	16e78f63          	beq	a5,a4,6c6 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 54c:	07300713          	li	a4,115
 550:	18e78563          	beq	a5,a4,6da <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 554:	05579063          	bne	a5,s5,594 <vprintf+0xfa>
        putc(fd, '%');
 558:	85d6                	mv	a1,s5
 55a:	855a                	mv	a0,s6
 55c:	e85ff0ef          	jal	ra,3e0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 560:	4981                	li	s3,0
 562:	bf49                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 564:	008b8913          	addi	s2,s7,8
 568:	4685                	li	a3,1
 56a:	4629                	li	a2,10
 56c:	000ba583          	lw	a1,0(s7)
 570:	855a                	mv	a0,s6
 572:	e8dff0ef          	jal	ra,3fe <printint>
 576:	8bca                	mv	s7,s2
      state = 0;
 578:	4981                	li	s3,0
 57a:	bfad                	j	4f4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 57c:	03868663          	beq	a3,s8,5a8 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 580:	05a68163          	beq	a3,s10,5c2 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 584:	09b68d63          	beq	a3,s11,61e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 588:	03a68f63          	beq	a3,s10,5c6 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 58c:	07800793          	li	a5,120
 590:	0cf68d63          	beq	a3,a5,66a <vprintf+0x1d0>
        putc(fd, '%');
 594:	85d6                	mv	a1,s5
 596:	855a                	mv	a0,s6
 598:	e49ff0ef          	jal	ra,3e0 <putc>
        putc(fd, c0);
 59c:	85ca                	mv	a1,s2
 59e:	855a                	mv	a0,s6
 5a0:	e41ff0ef          	jal	ra,3e0 <putc>
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	b7b9                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a8:	008b8913          	addi	s2,s7,8
 5ac:	4685                	li	a3,1
 5ae:	4629                	li	a2,10
 5b0:	000bb583          	ld	a1,0(s7)
 5b4:	855a                	mv	a0,s6
 5b6:	e49ff0ef          	jal	ra,3fe <printint>
        i += 1;
 5ba:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5bc:	8bca                	mv	s7,s2
      state = 0;
 5be:	4981                	li	s3,0
        i += 1;
 5c0:	bf15                	j	4f4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c2:	03860563          	beq	a2,s8,5ec <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c6:	07b60963          	beq	a2,s11,638 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5ca:	07800793          	li	a5,120
 5ce:	fcf613e3          	bne	a2,a5,594 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4641                	li	a2,16
 5da:	000bb583          	ld	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e1fff0ef          	jal	ra,3fe <printint>
        i += 2;
 5e4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e6:	8bca                	mv	s7,s2
      state = 0;
 5e8:	4981                	li	s3,0
        i += 2;
 5ea:	b729                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4685                	li	a3,1
 5f2:	4629                	li	a2,10
 5f4:	000bb583          	ld	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	e05ff0ef          	jal	ra,3fe <printint>
        i += 2;
 5fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
        i += 2;
 604:	bdc5                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 606:	008b8913          	addi	s2,s7,8
 60a:	4681                	li	a3,0
 60c:	4629                	li	a2,10
 60e:	000be583          	lwu	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	debff0ef          	jal	ra,3fe <printint>
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bde1                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b8913          	addi	s2,s7,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	dd3ff0ef          	jal	ra,3fe <printint>
        i += 1;
 630:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 1;
 636:	bd7d                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	008b8913          	addi	s2,s7,8
 63c:	4681                	li	a3,0
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	db9ff0ef          	jal	ra,3fe <printint>
        i += 2;
 64a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 2;
 650:	b555                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 652:	008b8913          	addi	s2,s7,8
 656:	4681                	li	a3,0
 658:	4641                	li	a2,16
 65a:	000be583          	lwu	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	d9fff0ef          	jal	ra,3fe <printint>
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	b571                	j	4f4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	d87ff0ef          	jal	ra,3fe <printint>
        i += 1;
 67c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 1;
 682:	bd8d                	j	4f4 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 684:	008b8793          	addi	a5,s7,8
 688:	f8f43423          	sd	a5,-120(s0)
 68c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 690:	03000593          	li	a1,48
 694:	855a                	mv	a0,s6
 696:	d4bff0ef          	jal	ra,3e0 <putc>
  putc(fd, 'x');
 69a:	07800593          	li	a1,120
 69e:	855a                	mv	a0,s6
 6a0:	d41ff0ef          	jal	ra,3e0 <putc>
 6a4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a6:	03c9d793          	srli	a5,s3,0x3c
 6aa:	97e6                	add	a5,a5,s9
 6ac:	0007c583          	lbu	a1,0(a5)
 6b0:	855a                	mv	a0,s6
 6b2:	d2fff0ef          	jal	ra,3e0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b6:	0992                	slli	s3,s3,0x4
 6b8:	397d                	addiw	s2,s2,-1
 6ba:	fe0916e3          	bnez	s2,6a6 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6be:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bd05                	j	4f4 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	000bc583          	lbu	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	d11ff0ef          	jal	ra,3e0 <putc>
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bd31                	j	4f4 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6da:	008b8993          	addi	s3,s7,8
 6de:	000bb903          	ld	s2,0(s7)
 6e2:	00090f63          	beqz	s2,700 <vprintf+0x266>
        for(; *s; s++)
 6e6:	00094583          	lbu	a1,0(s2)
 6ea:	c195                	beqz	a1,70e <vprintf+0x274>
          putc(fd, *s);
 6ec:	855a                	mv	a0,s6
 6ee:	cf3ff0ef          	jal	ra,3e0 <putc>
        for(; *s; s++)
 6f2:	0905                	addi	s2,s2,1
 6f4:	00094583          	lbu	a1,0(s2)
 6f8:	f9f5                	bnez	a1,6ec <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6fa:	8bce                	mv	s7,s3
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bbdd                	j	4f4 <vprintf+0x5a>
          s = "(null)";
 700:	00000917          	auipc	s2,0x0
 704:	24090913          	addi	s2,s2,576 # 940 <malloc+0x130>
        for(; *s; s++)
 708:	02800593          	li	a1,40
 70c:	b7c5                	j	6ec <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 70e:	8bce                	mv	s7,s3
      state = 0;
 710:	4981                	li	s3,0
 712:	b3cd                	j	4f4 <vprintf+0x5a>
    }
  }
}
 714:	70e6                	ld	ra,120(sp)
 716:	7446                	ld	s0,112(sp)
 718:	74a6                	ld	s1,104(sp)
 71a:	7906                	ld	s2,96(sp)
 71c:	69e6                	ld	s3,88(sp)
 71e:	6a46                	ld	s4,80(sp)
 720:	6aa6                	ld	s5,72(sp)
 722:	6b06                	ld	s6,64(sp)
 724:	7be2                	ld	s7,56(sp)
 726:	7c42                	ld	s8,48(sp)
 728:	7ca2                	ld	s9,40(sp)
 72a:	7d02                	ld	s10,32(sp)
 72c:	6de2                	ld	s11,24(sp)
 72e:	6109                	addi	sp,sp,128
 730:	8082                	ret

0000000000000732 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 732:	715d                	addi	sp,sp,-80
 734:	ec06                	sd	ra,24(sp)
 736:	e822                	sd	s0,16(sp)
 738:	1000                	addi	s0,sp,32
 73a:	e010                	sd	a2,0(s0)
 73c:	e414                	sd	a3,8(s0)
 73e:	e818                	sd	a4,16(s0)
 740:	ec1c                	sd	a5,24(s0)
 742:	03043023          	sd	a6,32(s0)
 746:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 74e:	8622                	mv	a2,s0
 750:	d4bff0ef          	jal	ra,49a <vprintf>
}
 754:	60e2                	ld	ra,24(sp)
 756:	6442                	ld	s0,16(sp)
 758:	6161                	addi	sp,sp,80
 75a:	8082                	ret

000000000000075c <printf>:

void
printf(const char *fmt, ...)
{
 75c:	711d                	addi	sp,sp,-96
 75e:	ec06                	sd	ra,24(sp)
 760:	e822                	sd	s0,16(sp)
 762:	1000                	addi	s0,sp,32
 764:	e40c                	sd	a1,8(s0)
 766:	e810                	sd	a2,16(s0)
 768:	ec14                	sd	a3,24(s0)
 76a:	f018                	sd	a4,32(s0)
 76c:	f41c                	sd	a5,40(s0)
 76e:	03043823          	sd	a6,48(s0)
 772:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 776:	00840613          	addi	a2,s0,8
 77a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 77e:	85aa                	mv	a1,a0
 780:	4505                	li	a0,1
 782:	d19ff0ef          	jal	ra,49a <vprintf>
}
 786:	60e2                	ld	ra,24(sp)
 788:	6442                	ld	s0,16(sp)
 78a:	6125                	addi	sp,sp,96
 78c:	8082                	ret

000000000000078e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78e:	1141                	addi	sp,sp,-16
 790:	e422                	sd	s0,8(sp)
 792:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 794:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 798:	00001797          	auipc	a5,0x1
 79c:	8787b783          	ld	a5,-1928(a5) # 1010 <freep>
 7a0:	a02d                	j	7ca <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a2:	4618                	lw	a4,8(a2)
 7a4:	9f2d                	addw	a4,a4,a1
 7a6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7aa:	6398                	ld	a4,0(a5)
 7ac:	6310                	ld	a2,0(a4)
 7ae:	a83d                	j	7ec <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b0:	ff852703          	lw	a4,-8(a0)
 7b4:	9f31                	addw	a4,a4,a2
 7b6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b8:	ff053683          	ld	a3,-16(a0)
 7bc:	a091                	j	800 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7be:	6398                	ld	a4,0(a5)
 7c0:	00e7e463          	bltu	a5,a4,7c8 <free+0x3a>
 7c4:	00e6ea63          	bltu	a3,a4,7d8 <free+0x4a>
{
 7c8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ca:	fed7fae3          	bgeu	a5,a3,7be <free+0x30>
 7ce:	6398                	ld	a4,0(a5)
 7d0:	00e6e463          	bltu	a3,a4,7d8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d4:	fee7eae3          	bltu	a5,a4,7c8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d8:	ff852583          	lw	a1,-8(a0)
 7dc:	6390                	ld	a2,0(a5)
 7de:	02059813          	slli	a6,a1,0x20
 7e2:	01c85713          	srli	a4,a6,0x1c
 7e6:	9736                	add	a4,a4,a3
 7e8:	fae60de3          	beq	a2,a4,7a2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ec:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f0:	4790                	lw	a2,8(a5)
 7f2:	02061593          	slli	a1,a2,0x20
 7f6:	01c5d713          	srli	a4,a1,0x1c
 7fa:	973e                	add	a4,a4,a5
 7fc:	fae68ae3          	beq	a3,a4,7b0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 800:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 802:	00001717          	auipc	a4,0x1
 806:	80f73723          	sd	a5,-2034(a4) # 1010 <freep>
}
 80a:	6422                	ld	s0,8(sp)
 80c:	0141                	addi	sp,sp,16
 80e:	8082                	ret

0000000000000810 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 810:	7139                	addi	sp,sp,-64
 812:	fc06                	sd	ra,56(sp)
 814:	f822                	sd	s0,48(sp)
 816:	f426                	sd	s1,40(sp)
 818:	f04a                	sd	s2,32(sp)
 81a:	ec4e                	sd	s3,24(sp)
 81c:	e852                	sd	s4,16(sp)
 81e:	e456                	sd	s5,8(sp)
 820:	e05a                	sd	s6,0(sp)
 822:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 824:	02051493          	slli	s1,a0,0x20
 828:	9081                	srli	s1,s1,0x20
 82a:	04bd                	addi	s1,s1,15
 82c:	8091                	srli	s1,s1,0x4
 82e:	0014899b          	addiw	s3,s1,1
 832:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 834:	00000517          	auipc	a0,0x0
 838:	7dc53503          	ld	a0,2012(a0) # 1010 <freep>
 83c:	c515                	beqz	a0,868 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 840:	4798                	lw	a4,8(a5)
 842:	02977f63          	bgeu	a4,s1,880 <malloc+0x70>
 846:	8a4e                	mv	s4,s3
 848:	0009871b          	sext.w	a4,s3
 84c:	6685                	lui	a3,0x1
 84e:	00d77363          	bgeu	a4,a3,854 <malloc+0x44>
 852:	6a05                	lui	s4,0x1
 854:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 858:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85c:	00000917          	auipc	s2,0x0
 860:	7b490913          	addi	s2,s2,1972 # 1010 <freep>
  if(p == SBRK_ERROR)
 864:	5afd                	li	s5,-1
 866:	a885                	j	8d6 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 868:	00000797          	auipc	a5,0x0
 86c:	7b878793          	addi	a5,a5,1976 # 1020 <base>
 870:	00000717          	auipc	a4,0x0
 874:	7af73023          	sd	a5,1952(a4) # 1010 <freep>
 878:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87e:	b7e1                	j	846 <malloc+0x36>
      if(p->s.size == nunits)
 880:	02e48c63          	beq	s1,a4,8b8 <malloc+0xa8>
        p->s.size -= nunits;
 884:	4137073b          	subw	a4,a4,s3
 888:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88a:	02071693          	slli	a3,a4,0x20
 88e:	01c6d713          	srli	a4,a3,0x1c
 892:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 894:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 898:	00000717          	auipc	a4,0x0
 89c:	76a73c23          	sd	a0,1912(a4) # 1010 <freep>
      return (void*)(p + 1);
 8a0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a4:	70e2                	ld	ra,56(sp)
 8a6:	7442                	ld	s0,48(sp)
 8a8:	74a2                	ld	s1,40(sp)
 8aa:	7902                	ld	s2,32(sp)
 8ac:	69e2                	ld	s3,24(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
 8b4:	6121                	addi	sp,sp,64
 8b6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b8:	6398                	ld	a4,0(a5)
 8ba:	e118                	sd	a4,0(a0)
 8bc:	bff1                	j	898 <malloc+0x88>
  hp->s.size = nu;
 8be:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c2:	0541                	addi	a0,a0,16
 8c4:	ecbff0ef          	jal	ra,78e <free>
  return freep;
 8c8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8cc:	dd61                	beqz	a0,8a4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d0:	4798                	lw	a4,8(a5)
 8d2:	fa9777e3          	bgeu	a4,s1,880 <malloc+0x70>
    if(p == freep)
 8d6:	00093703          	ld	a4,0(s2)
 8da:	853e                	mv	a0,a5
 8dc:	fef719e3          	bne	a4,a5,8ce <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 8e0:	8552                	mv	a0,s4
 8e2:	a0bff0ef          	jal	ra,2ec <sbrk>
  if(p == SBRK_ERROR)
 8e6:	fd551ce3          	bne	a0,s5,8be <malloc+0xae>
        return 0;
 8ea:	4501                	li	a0,0
 8ec:	bf65                	j	8a4 <malloc+0x94>
