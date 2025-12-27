
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
  24:	8c050513          	addi	a0,a0,-1856 # 8e0 <malloc+0xf0>
  28:	714000ef          	jal	ra,73c <printf>
    exit(0);
  2c:	4501                	li	a0,0
  2e:	2f2000ef          	jal	ra,320 <exit>
    printf("fork failed\n");
  32:	00001517          	auipc	a0,0x1
  36:	89e50513          	addi	a0,a0,-1890 # 8d0 <malloc+0xe0>
  3a:	702000ef          	jal	ra,73c <printf>
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
  58:	89c50513          	addi	a0,a0,-1892 # 8f0 <malloc+0x100>
  5c:	6e0000ef          	jal	ra,73c <printf>
  if(x != 1){
  60:	408c                	lw	a1,0(s1)
  62:	4785                	li	a5,1
  64:	00f58b63          	beq	a1,a5,7a <main+0x7a>
    printf("FAIL: parent saw x=%d\n", x);
  68:	00001517          	auipc	a0,0x1
  6c:	89850513          	addi	a0,a0,-1896 # 900 <malloc+0x110>
  70:	6cc000ef          	jal	ra,73c <printf>
    exit(1);
  74:	4505                	li	a0,1
  76:	2aa000ef          	jal	ra,320 <exit>
  }
  printf("PASS\n");
  7a:	00001517          	auipc	a0,0x1
  7e:	89e50513          	addi	a0,a0,-1890 # 918 <malloc+0x128>
  82:	6ba000ef          	jal	ra,73c <printf>
  exit(0);
  86:	4501                	li	a0,0
  88:	298000ef          	jal	ra,320 <exit>

000000000000008c <start>:
//
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

00000000000003c0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c0:	1101                	addi	sp,sp,-32
 3c2:	ec06                	sd	ra,24(sp)
 3c4:	e822                	sd	s0,16(sp)
 3c6:	1000                	addi	s0,sp,32
 3c8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3cc:	4605                	li	a2,1
 3ce:	fef40593          	addi	a1,s0,-17
 3d2:	f6fff0ef          	jal	ra,340 <write>
}
 3d6:	60e2                	ld	ra,24(sp)
 3d8:	6442                	ld	s0,16(sp)
 3da:	6105                	addi	sp,sp,32
 3dc:	8082                	ret

00000000000003de <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3de:	715d                	addi	sp,sp,-80
 3e0:	e486                	sd	ra,72(sp)
 3e2:	e0a2                	sd	s0,64(sp)
 3e4:	fc26                	sd	s1,56(sp)
 3e6:	f84a                	sd	s2,48(sp)
 3e8:	f44e                	sd	s3,40(sp)
 3ea:	0880                	addi	s0,sp,80
 3ec:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ee:	c299                	beqz	a3,3f4 <printint+0x16>
 3f0:	0805c163          	bltz	a1,472 <printint+0x94>
  neg = 0;
 3f4:	4881                	li	a7,0
 3f6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3fa:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3fc:	00000517          	auipc	a0,0x0
 400:	52c50513          	addi	a0,a0,1324 # 928 <digits>
 404:	883e                	mv	a6,a5
 406:	2785                	addiw	a5,a5,1
 408:	02c5f733          	remu	a4,a1,a2
 40c:	972a                	add	a4,a4,a0
 40e:	00074703          	lbu	a4,0(a4)
 412:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 416:	872e                	mv	a4,a1
 418:	02c5d5b3          	divu	a1,a1,a2
 41c:	0685                	addi	a3,a3,1
 41e:	fec773e3          	bgeu	a4,a2,404 <printint+0x26>
  if(neg)
 422:	00088b63          	beqz	a7,438 <printint+0x5a>
    buf[i++] = '-';
 426:	fd078793          	addi	a5,a5,-48
 42a:	97a2                	add	a5,a5,s0
 42c:	02d00713          	li	a4,45
 430:	fee78423          	sb	a4,-24(a5)
 434:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 438:	02f05663          	blez	a5,464 <printint+0x86>
 43c:	fb840713          	addi	a4,s0,-72
 440:	00f704b3          	add	s1,a4,a5
 444:	fff70993          	addi	s3,a4,-1
 448:	99be                	add	s3,s3,a5
 44a:	37fd                	addiw	a5,a5,-1
 44c:	1782                	slli	a5,a5,0x20
 44e:	9381                	srli	a5,a5,0x20
 450:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 454:	fff4c583          	lbu	a1,-1(s1)
 458:	854a                	mv	a0,s2
 45a:	f67ff0ef          	jal	ra,3c0 <putc>
  while(--i >= 0)
 45e:	14fd                	addi	s1,s1,-1
 460:	ff349ae3          	bne	s1,s3,454 <printint+0x76>
}
 464:	60a6                	ld	ra,72(sp)
 466:	6406                	ld	s0,64(sp)
 468:	74e2                	ld	s1,56(sp)
 46a:	7942                	ld	s2,48(sp)
 46c:	79a2                	ld	s3,40(sp)
 46e:	6161                	addi	sp,sp,80
 470:	8082                	ret
    x = -xx;
 472:	40b005b3          	neg	a1,a1
    neg = 1;
 476:	4885                	li	a7,1
    x = -xx;
 478:	bfbd                	j	3f6 <printint+0x18>

000000000000047a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 47a:	7119                	addi	sp,sp,-128
 47c:	fc86                	sd	ra,120(sp)
 47e:	f8a2                	sd	s0,112(sp)
 480:	f4a6                	sd	s1,104(sp)
 482:	f0ca                	sd	s2,96(sp)
 484:	ecce                	sd	s3,88(sp)
 486:	e8d2                	sd	s4,80(sp)
 488:	e4d6                	sd	s5,72(sp)
 48a:	e0da                	sd	s6,64(sp)
 48c:	fc5e                	sd	s7,56(sp)
 48e:	f862                	sd	s8,48(sp)
 490:	f466                	sd	s9,40(sp)
 492:	f06a                	sd	s10,32(sp)
 494:	ec6e                	sd	s11,24(sp)
 496:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 498:	0005c903          	lbu	s2,0(a1)
 49c:	24090c63          	beqz	s2,6f4 <vprintf+0x27a>
 4a0:	8b2a                	mv	s6,a0
 4a2:	8a2e                	mv	s4,a1
 4a4:	8bb2                	mv	s7,a2
  state = 0;
 4a6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4a8:	4481                	li	s1,0
 4aa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4ac:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4b0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4b4:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4b8:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4bc:	00000c97          	auipc	s9,0x0
 4c0:	46cc8c93          	addi	s9,s9,1132 # 928 <digits>
 4c4:	a005                	j	4e4 <vprintf+0x6a>
        putc(fd, c0);
 4c6:	85ca                	mv	a1,s2
 4c8:	855a                	mv	a0,s6
 4ca:	ef7ff0ef          	jal	ra,3c0 <putc>
 4ce:	a019                	j	4d4 <vprintf+0x5a>
    } else if(state == '%'){
 4d0:	03598263          	beq	s3,s5,4f4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d4:	2485                	addiw	s1,s1,1
 4d6:	8726                	mv	a4,s1
 4d8:	009a07b3          	add	a5,s4,s1
 4dc:	0007c903          	lbu	s2,0(a5)
 4e0:	20090a63          	beqz	s2,6f4 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4e4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4e8:	fe0994e3          	bnez	s3,4d0 <vprintf+0x56>
      if(c0 == '%'){
 4ec:	fd579de3          	bne	a5,s5,4c6 <vprintf+0x4c>
        state = '%';
 4f0:	89be                	mv	s3,a5
 4f2:	b7cd                	j	4d4 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4f4:	c3c1                	beqz	a5,574 <vprintf+0xfa>
 4f6:	00ea06b3          	add	a3,s4,a4
 4fa:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4fe:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 500:	c681                	beqz	a3,508 <vprintf+0x8e>
 502:	9752                	add	a4,a4,s4
 504:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 508:	03878e63          	beq	a5,s8,544 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 50c:	05a78863          	beq	a5,s10,55c <vprintf+0xe2>
      } else if(c0 == 'u'){
 510:	0db78b63          	beq	a5,s11,5e6 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 514:	07800713          	li	a4,120
 518:	10e78d63          	beq	a5,a4,632 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 51c:	07000713          	li	a4,112
 520:	14e78263          	beq	a5,a4,664 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 524:	06300713          	li	a4,99
 528:	16e78f63          	beq	a5,a4,6a6 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 52c:	07300713          	li	a4,115
 530:	18e78563          	beq	a5,a4,6ba <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 534:	05579063          	bne	a5,s5,574 <vprintf+0xfa>
        putc(fd, '%');
 538:	85d6                	mv	a1,s5
 53a:	855a                	mv	a0,s6
 53c:	e85ff0ef          	jal	ra,3c0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 540:	4981                	li	s3,0
 542:	bf49                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 544:	008b8913          	addi	s2,s7,8
 548:	4685                	li	a3,1
 54a:	4629                	li	a2,10
 54c:	000ba583          	lw	a1,0(s7)
 550:	855a                	mv	a0,s6
 552:	e8dff0ef          	jal	ra,3de <printint>
 556:	8bca                	mv	s7,s2
      state = 0;
 558:	4981                	li	s3,0
 55a:	bfad                	j	4d4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 55c:	03868663          	beq	a3,s8,588 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 560:	05a68163          	beq	a3,s10,5a2 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 564:	09b68d63          	beq	a3,s11,5fe <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 568:	03a68f63          	beq	a3,s10,5a6 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 56c:	07800793          	li	a5,120
 570:	0cf68d63          	beq	a3,a5,64a <vprintf+0x1d0>
        putc(fd, '%');
 574:	85d6                	mv	a1,s5
 576:	855a                	mv	a0,s6
 578:	e49ff0ef          	jal	ra,3c0 <putc>
        putc(fd, c0);
 57c:	85ca                	mv	a1,s2
 57e:	855a                	mv	a0,s6
 580:	e41ff0ef          	jal	ra,3c0 <putc>
      state = 0;
 584:	4981                	li	s3,0
 586:	b7b9                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 588:	008b8913          	addi	s2,s7,8
 58c:	4685                	li	a3,1
 58e:	4629                	li	a2,10
 590:	000bb583          	ld	a1,0(s7)
 594:	855a                	mv	a0,s6
 596:	e49ff0ef          	jal	ra,3de <printint>
        i += 1;
 59a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 59c:	8bca                	mv	s7,s2
      state = 0;
 59e:	4981                	li	s3,0
        i += 1;
 5a0:	bf15                	j	4d4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a2:	03860563          	beq	a2,s8,5cc <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a6:	07b60963          	beq	a2,s11,618 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5aa:	07800793          	li	a5,120
 5ae:	fcf613e3          	bne	a2,a5,574 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4641                	li	a2,16
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	e1fff0ef          	jal	ra,3de <printint>
        i += 2;
 5c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
        i += 2;
 5ca:	b729                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4685                	li	a3,1
 5d2:	4629                	li	a2,10
 5d4:	000bb583          	ld	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	e05ff0ef          	jal	ra,3de <printint>
        i += 2;
 5de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
        i += 2;
 5e4:	bdc5                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4681                	li	a3,0
 5ec:	4629                	li	a2,10
 5ee:	000be583          	lwu	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	debff0ef          	jal	ra,3de <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bde1                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4629                	li	a2,10
 606:	000bb583          	ld	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	dd3ff0ef          	jal	ra,3de <printint>
        i += 1;
 610:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
        i += 1;
 616:	bd7d                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	008b8913          	addi	s2,s7,8
 61c:	4681                	li	a3,0
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	db9ff0ef          	jal	ra,3de <printint>
        i += 2;
 62a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 2;
 630:	b555                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4641                	li	a2,16
 63a:	000be583          	lwu	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	d9fff0ef          	jal	ra,3de <printint>
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	b571                	j	4d4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4681                	li	a3,0
 650:	4641                	li	a2,16
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	d87ff0ef          	jal	ra,3de <printint>
        i += 1;
 65c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 1;
 662:	bd8d                	j	4d4 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 664:	008b8793          	addi	a5,s7,8
 668:	f8f43423          	sd	a5,-120(s0)
 66c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 670:	03000593          	li	a1,48
 674:	855a                	mv	a0,s6
 676:	d4bff0ef          	jal	ra,3c0 <putc>
  putc(fd, 'x');
 67a:	07800593          	li	a1,120
 67e:	855a                	mv	a0,s6
 680:	d41ff0ef          	jal	ra,3c0 <putc>
 684:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 686:	03c9d793          	srli	a5,s3,0x3c
 68a:	97e6                	add	a5,a5,s9
 68c:	0007c583          	lbu	a1,0(a5)
 690:	855a                	mv	a0,s6
 692:	d2fff0ef          	jal	ra,3c0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 696:	0992                	slli	s3,s3,0x4
 698:	397d                	addiw	s2,s2,-1
 69a:	fe0916e3          	bnez	s2,686 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 69e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bd05                	j	4d4 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	000bc583          	lbu	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	d11ff0ef          	jal	ra,3c0 <putc>
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bd31                	j	4d4 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6ba:	008b8993          	addi	s3,s7,8
 6be:	000bb903          	ld	s2,0(s7)
 6c2:	00090f63          	beqz	s2,6e0 <vprintf+0x266>
        for(; *s; s++)
 6c6:	00094583          	lbu	a1,0(s2)
 6ca:	c195                	beqz	a1,6ee <vprintf+0x274>
          putc(fd, *s);
 6cc:	855a                	mv	a0,s6
 6ce:	cf3ff0ef          	jal	ra,3c0 <putc>
        for(; *s; s++)
 6d2:	0905                	addi	s2,s2,1
 6d4:	00094583          	lbu	a1,0(s2)
 6d8:	f9f5                	bnez	a1,6cc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6da:	8bce                	mv	s7,s3
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bbdd                	j	4d4 <vprintf+0x5a>
          s = "(null)";
 6e0:	00000917          	auipc	s2,0x0
 6e4:	24090913          	addi	s2,s2,576 # 920 <malloc+0x130>
        for(; *s; s++)
 6e8:	02800593          	li	a1,40
 6ec:	b7c5                	j	6cc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6ee:	8bce                	mv	s7,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b3cd                	j	4d4 <vprintf+0x5a>
    }
  }
}
 6f4:	70e6                	ld	ra,120(sp)
 6f6:	7446                	ld	s0,112(sp)
 6f8:	74a6                	ld	s1,104(sp)
 6fa:	7906                	ld	s2,96(sp)
 6fc:	69e6                	ld	s3,88(sp)
 6fe:	6a46                	ld	s4,80(sp)
 700:	6aa6                	ld	s5,72(sp)
 702:	6b06                	ld	s6,64(sp)
 704:	7be2                	ld	s7,56(sp)
 706:	7c42                	ld	s8,48(sp)
 708:	7ca2                	ld	s9,40(sp)
 70a:	7d02                	ld	s10,32(sp)
 70c:	6de2                	ld	s11,24(sp)
 70e:	6109                	addi	sp,sp,128
 710:	8082                	ret

0000000000000712 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 712:	715d                	addi	sp,sp,-80
 714:	ec06                	sd	ra,24(sp)
 716:	e822                	sd	s0,16(sp)
 718:	1000                	addi	s0,sp,32
 71a:	e010                	sd	a2,0(s0)
 71c:	e414                	sd	a3,8(s0)
 71e:	e818                	sd	a4,16(s0)
 720:	ec1c                	sd	a5,24(s0)
 722:	03043023          	sd	a6,32(s0)
 726:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72e:	8622                	mv	a2,s0
 730:	d4bff0ef          	jal	ra,47a <vprintf>
}
 734:	60e2                	ld	ra,24(sp)
 736:	6442                	ld	s0,16(sp)
 738:	6161                	addi	sp,sp,80
 73a:	8082                	ret

000000000000073c <printf>:

void
printf(const char *fmt, ...)
{
 73c:	711d                	addi	sp,sp,-96
 73e:	ec06                	sd	ra,24(sp)
 740:	e822                	sd	s0,16(sp)
 742:	1000                	addi	s0,sp,32
 744:	e40c                	sd	a1,8(s0)
 746:	e810                	sd	a2,16(s0)
 748:	ec14                	sd	a3,24(s0)
 74a:	f018                	sd	a4,32(s0)
 74c:	f41c                	sd	a5,40(s0)
 74e:	03043823          	sd	a6,48(s0)
 752:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	00840613          	addi	a2,s0,8
 75a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 75e:	85aa                	mv	a1,a0
 760:	4505                	li	a0,1
 762:	d19ff0ef          	jal	ra,47a <vprintf>
}
 766:	60e2                	ld	ra,24(sp)
 768:	6442                	ld	s0,16(sp)
 76a:	6125                	addi	sp,sp,96
 76c:	8082                	ret

000000000000076e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 76e:	1141                	addi	sp,sp,-16
 770:	e422                	sd	s0,8(sp)
 772:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 774:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 778:	00001797          	auipc	a5,0x1
 77c:	8987b783          	ld	a5,-1896(a5) # 1010 <freep>
 780:	a02d                	j	7aa <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 782:	4618                	lw	a4,8(a2)
 784:	9f2d                	addw	a4,a4,a1
 786:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78a:	6398                	ld	a4,0(a5)
 78c:	6310                	ld	a2,0(a4)
 78e:	a83d                	j	7cc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 790:	ff852703          	lw	a4,-8(a0)
 794:	9f31                	addw	a4,a4,a2
 796:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 798:	ff053683          	ld	a3,-16(a0)
 79c:	a091                	j	7e0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79e:	6398                	ld	a4,0(a5)
 7a0:	00e7e463          	bltu	a5,a4,7a8 <free+0x3a>
 7a4:	00e6ea63          	bltu	a3,a4,7b8 <free+0x4a>
{
 7a8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7aa:	fed7fae3          	bgeu	a5,a3,79e <free+0x30>
 7ae:	6398                	ld	a4,0(a5)
 7b0:	00e6e463          	bltu	a3,a4,7b8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b4:	fee7eae3          	bltu	a5,a4,7a8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7b8:	ff852583          	lw	a1,-8(a0)
 7bc:	6390                	ld	a2,0(a5)
 7be:	02059813          	slli	a6,a1,0x20
 7c2:	01c85713          	srli	a4,a6,0x1c
 7c6:	9736                	add	a4,a4,a3
 7c8:	fae60de3          	beq	a2,a4,782 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7cc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d0:	4790                	lw	a2,8(a5)
 7d2:	02061593          	slli	a1,a2,0x20
 7d6:	01c5d713          	srli	a4,a1,0x1c
 7da:	973e                	add	a4,a4,a5
 7dc:	fae68ae3          	beq	a3,a4,790 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e2:	00001717          	auipc	a4,0x1
 7e6:	82f73723          	sd	a5,-2002(a4) # 1010 <freep>
}
 7ea:	6422                	ld	s0,8(sp)
 7ec:	0141                	addi	sp,sp,16
 7ee:	8082                	ret

00000000000007f0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f0:	7139                	addi	sp,sp,-64
 7f2:	fc06                	sd	ra,56(sp)
 7f4:	f822                	sd	s0,48(sp)
 7f6:	f426                	sd	s1,40(sp)
 7f8:	f04a                	sd	s2,32(sp)
 7fa:	ec4e                	sd	s3,24(sp)
 7fc:	e852                	sd	s4,16(sp)
 7fe:	e456                	sd	s5,8(sp)
 800:	e05a                	sd	s6,0(sp)
 802:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 804:	02051493          	slli	s1,a0,0x20
 808:	9081                	srli	s1,s1,0x20
 80a:	04bd                	addi	s1,s1,15
 80c:	8091                	srli	s1,s1,0x4
 80e:	0014899b          	addiw	s3,s1,1
 812:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 814:	00000517          	auipc	a0,0x0
 818:	7fc53503          	ld	a0,2044(a0) # 1010 <freep>
 81c:	c515                	beqz	a0,848 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 820:	4798                	lw	a4,8(a5)
 822:	02977f63          	bgeu	a4,s1,860 <malloc+0x70>
 826:	8a4e                	mv	s4,s3
 828:	0009871b          	sext.w	a4,s3
 82c:	6685                	lui	a3,0x1
 82e:	00d77363          	bgeu	a4,a3,834 <malloc+0x44>
 832:	6a05                	lui	s4,0x1
 834:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 838:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 83c:	00000917          	auipc	s2,0x0
 840:	7d490913          	addi	s2,s2,2004 # 1010 <freep>
  if(p == SBRK_ERROR)
 844:	5afd                	li	s5,-1
 846:	a885                	j	8b6 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 848:	00000797          	auipc	a5,0x0
 84c:	7d878793          	addi	a5,a5,2008 # 1020 <base>
 850:	00000717          	auipc	a4,0x0
 854:	7cf73023          	sd	a5,1984(a4) # 1010 <freep>
 858:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 85e:	b7e1                	j	826 <malloc+0x36>
      if(p->s.size == nunits)
 860:	02e48c63          	beq	s1,a4,898 <malloc+0xa8>
        p->s.size -= nunits;
 864:	4137073b          	subw	a4,a4,s3
 868:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86a:	02071693          	slli	a3,a4,0x20
 86e:	01c6d713          	srli	a4,a3,0x1c
 872:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 874:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 878:	00000717          	auipc	a4,0x0
 87c:	78a73c23          	sd	a0,1944(a4) # 1010 <freep>
      return (void*)(p + 1);
 880:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 884:	70e2                	ld	ra,56(sp)
 886:	7442                	ld	s0,48(sp)
 888:	74a2                	ld	s1,40(sp)
 88a:	7902                	ld	s2,32(sp)
 88c:	69e2                	ld	s3,24(sp)
 88e:	6a42                	ld	s4,16(sp)
 890:	6aa2                	ld	s5,8(sp)
 892:	6b02                	ld	s6,0(sp)
 894:	6121                	addi	sp,sp,64
 896:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 898:	6398                	ld	a4,0(a5)
 89a:	e118                	sd	a4,0(a0)
 89c:	bff1                	j	878 <malloc+0x88>
  hp->s.size = nu;
 89e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a2:	0541                	addi	a0,a0,16
 8a4:	ecbff0ef          	jal	ra,76e <free>
  return freep;
 8a8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ac:	dd61                	beqz	a0,884 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	fa9777e3          	bgeu	a4,s1,860 <malloc+0x70>
    if(p == freep)
 8b6:	00093703          	ld	a4,0(s2)
 8ba:	853e                	mv	a0,a5
 8bc:	fef719e3          	bne	a4,a5,8ae <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 8c0:	8552                	mv	a0,s4
 8c2:	a2bff0ef          	jal	ra,2ec <sbrk>
  if(p == SBRK_ERROR)
 8c6:	fd551ce3          	bne	a0,s5,89e <malloc+0xae>
        return 0;
 8ca:	4501                	li	a0,0
 8cc:	bf65                	j	884 <malloc+0x94>
