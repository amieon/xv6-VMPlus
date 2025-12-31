
user/_cow_heap：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  char *p = sbrk(4096);
   c:	6505                	lui	a0,0x1
   e:	34c000ef          	jal	ra,35a <sbrk>
  if(p == (char*)-1){
  12:	57fd                	li	a5,-1
  14:	06f50b63          	beq	a0,a5,8a <main+0x8a>
  18:	84aa                	mv	s1,a0
    printf("sbrk failed\n");
    exit(1);
  }

  p[0] = 'A';
  1a:	04100793          	li	a5,65
  1e:	00f50023          	sb	a5,0(a0) # 1000 <freep>
  p[4095] = 'Z';
  22:	6785                	lui	a5,0x1
  24:	97aa                	add	a5,a5,a0
  26:	05a00713          	li	a4,90
  2a:	fee78fa3          	sb	a4,-1(a5) # fff <digits+0x5ff>

  int pid = fork();
  2e:	358000ef          	jal	ra,386 <fork>
  if(pid < 0) exit(1);
  32:	06054563          	bltz	a0,9c <main+0x9c>

  if(pid == 0){
  36:	e535                	bnez	a0,a2 <main+0xa2>
    p[0] = 'B';
  38:	04200913          	li	s2,66
  3c:	01248023          	sb	s2,0(s1)
    p[4095] = 'Y';
  40:	6785                	lui	a5,0x1
  42:	97a6                	add	a5,a5,s1
  44:	05900713          	li	a4,89
  48:	fee78fa3          	sb	a4,-1(a5) # fff <digits+0x5ff>
    printf("child: %c %c (expect B Y)\n", p[0], p[4095]);
  4c:	05900613          	li	a2,89
  50:	04200593          	li	a1,66
  54:	00001517          	auipc	a0,0x1
  58:	93c50513          	addi	a0,a0,-1732 # 990 <malloc+0xfa>
  5c:	786000ef          	jal	ra,7e2 <printf>
    if(p[0] != 'B' || p[4095] != 'Y') printf("FAIL child\n");
  60:	0004c783          	lbu	a5,0(s1)
  64:	01279a63          	bne	a5,s2,78 <main+0x78>
  68:	6785                	lui	a5,0x1
  6a:	97a6                	add	a5,a5,s1
  6c:	fff7c703          	lbu	a4,-1(a5) # fff <digits+0x5ff>
  70:	05900793          	li	a5,89
  74:	00f70863          	beq	a4,a5,84 <main+0x84>
  78:	00001517          	auipc	a0,0x1
  7c:	93850513          	addi	a0,a0,-1736 # 9b0 <malloc+0x11a>
  80:	762000ef          	jal	ra,7e2 <printf>
    exit(0);
  84:	4501                	li	a0,0
  86:	308000ef          	jal	ra,38e <exit>
    printf("sbrk failed\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	8f650513          	addi	a0,a0,-1802 # 980 <malloc+0xea>
  92:	750000ef          	jal	ra,7e2 <printf>
    exit(1);
  96:	4505                	li	a0,1
  98:	2f6000ef          	jal	ra,38e <exit>
  if(pid < 0) exit(1);
  9c:	4505                	li	a0,1
  9e:	2f0000ef          	jal	ra,38e <exit>
  }

  wait(0);
  a2:	4501                	li	a0,0
  a4:	2f2000ef          	jal	ra,396 <wait>
  printf("parent: %c %c (expect A Z)\n", p[0], p[4095]);
  a8:	6785                	lui	a5,0x1
  aa:	97a6                	add	a5,a5,s1
  ac:	fff7c603          	lbu	a2,-1(a5) # fff <digits+0x5ff>
  b0:	0004c583          	lbu	a1,0(s1)
  b4:	00001517          	auipc	a0,0x1
  b8:	90c50513          	addi	a0,a0,-1780 # 9c0 <malloc+0x12a>
  bc:	726000ef          	jal	ra,7e2 <printf>
  if(p[0] != 'A' || p[4095] != 'Z') printf("FAIL parent\n");
  c0:	0004c703          	lbu	a4,0(s1)
  c4:	04100793          	li	a5,65
  c8:	00f71a63          	bne	a4,a5,dc <main+0xdc>
  cc:	6785                	lui	a5,0x1
  ce:	94be                	add	s1,s1,a5
  d0:	fff4c703          	lbu	a4,-1(s1)
  d4:	05a00793          	li	a5,90
  d8:	00f70863          	beq	a4,a5,e8 <main+0xe8>
  dc:	00001517          	auipc	a0,0x1
  e0:	90450513          	addi	a0,a0,-1788 # 9e0 <malloc+0x14a>
  e4:	6fe000ef          	jal	ra,7e2 <printf>
  printf("PASS\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	90850513          	addi	a0,a0,-1784 # 9f0 <malloc+0x15a>
  f0:	6f2000ef          	jal	ra,7e2 <printf>
  exit(0);
  f4:	4501                	li	a0,0
  f6:	298000ef          	jal	ra,38e <exit>

00000000000000fa <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e406                	sd	ra,8(sp)
  fe:	e022                	sd	s0,0(sp)
 100:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 102:	effff0ef          	jal	ra,0 <main>
  exit(r);
 106:	288000ef          	jal	ra,38e <exit>

000000000000010a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 110:	87aa                	mv	a5,a0
 112:	0585                	addi	a1,a1,1
 114:	0785                	addi	a5,a5,1 # 1001 <freep+0x1>
 116:	fff5c703          	lbu	a4,-1(a1)
 11a:	fee78fa3          	sb	a4,-1(a5)
 11e:	fb75                	bnez	a4,112 <strcpy+0x8>
    ;
  return os;
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cb91                	beqz	a5,144 <strcmp+0x1e>
 132:	0005c703          	lbu	a4,0(a1)
 136:	00f71763          	bne	a4,a5,144 <strcmp+0x1e>
    p++, q++;
 13a:	0505                	addi	a0,a0,1
 13c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13e:	00054783          	lbu	a5,0(a0)
 142:	fbe5                	bnez	a5,132 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 144:	0005c503          	lbu	a0,0(a1)
}
 148:	40a7853b          	subw	a0,a5,a0
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strlen>:

uint
strlen(const char *s)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cf91                	beqz	a5,178 <strlen+0x26>
 15e:	0505                	addi	a0,a0,1
 160:	87aa                	mv	a5,a0
 162:	4685                	li	a3,1
 164:	9e89                	subw	a3,a3,a0
 166:	00f6853b          	addw	a0,a3,a5
 16a:	0785                	addi	a5,a5,1
 16c:	fff7c703          	lbu	a4,-1(a5)
 170:	fb7d                	bnez	a4,166 <strlen+0x14>
    ;
  return n;
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret
  for(n = 0; s[n]; n++)
 178:	4501                	li	a0,0
 17a:	bfe5                	j	172 <strlen+0x20>

000000000000017c <memset>:

void*
memset(void *dst, int c, uint n)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 182:	ca19                	beqz	a2,198 <memset+0x1c>
 184:	87aa                	mv	a5,a0
 186:	1602                	slli	a2,a2,0x20
 188:	9201                	srli	a2,a2,0x20
 18a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 192:	0785                	addi	a5,a5,1
 194:	fee79de3          	bne	a5,a4,18e <memset+0x12>
  }
  return dst;
}
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strchr>:

char*
strchr(const char *s, char c)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cb99                	beqz	a5,1be <strchr+0x20>
    if(*s == c)
 1aa:	00f58763          	beq	a1,a5,1b8 <strchr+0x1a>
  for(; *s; s++)
 1ae:	0505                	addi	a0,a0,1
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	fbfd                	bnez	a5,1aa <strchr+0xc>
      return (char*)s;
  return 0;
 1b6:	4501                	li	a0,0
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  return 0;
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strchr+0x1a>

00000000000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	711d                	addi	sp,sp,-96
 1c4:	ec86                	sd	ra,88(sp)
 1c6:	e8a2                	sd	s0,80(sp)
 1c8:	e4a6                	sd	s1,72(sp)
 1ca:	e0ca                	sd	s2,64(sp)
 1cc:	fc4e                	sd	s3,56(sp)
 1ce:	f852                	sd	s4,48(sp)
 1d0:	f456                	sd	s5,40(sp)
 1d2:	f05a                	sd	s6,32(sp)
 1d4:	ec5e                	sd	s7,24(sp)
 1d6:	1080                	addi	s0,sp,96
 1d8:	8baa                	mv	s7,a0
 1da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1dc:	892a                	mv	s2,a0
 1de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e0:	4aa9                	li	s5,10
 1e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e4:	89a6                	mv	s3,s1
 1e6:	2485                	addiw	s1,s1,1
 1e8:	0344d663          	bge	s1,s4,214 <gets+0x52>
    cc = read(0, &c, 1);
 1ec:	4605                	li	a2,1
 1ee:	faf40593          	addi	a1,s0,-81
 1f2:	4501                	li	a0,0
 1f4:	1b2000ef          	jal	ra,3a6 <read>
    if(cc < 1)
 1f8:	00a05e63          	blez	a0,214 <gets+0x52>
    buf[i++] = c;
 1fc:	faf44783          	lbu	a5,-81(s0)
 200:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 204:	01578763          	beq	a5,s5,212 <gets+0x50>
 208:	0905                	addi	s2,s2,1
 20a:	fd679de3          	bne	a5,s6,1e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 20e:	89a6                	mv	s3,s1
 210:	a011                	j	214 <gets+0x52>
 212:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 214:	99de                	add	s3,s3,s7
 216:	00098023          	sb	zero,0(s3)
  return buf;
}
 21a:	855e                	mv	a0,s7
 21c:	60e6                	ld	ra,88(sp)
 21e:	6446                	ld	s0,80(sp)
 220:	64a6                	ld	s1,72(sp)
 222:	6906                	ld	s2,64(sp)
 224:	79e2                	ld	s3,56(sp)
 226:	7a42                	ld	s4,48(sp)
 228:	7aa2                	ld	s5,40(sp)
 22a:	7b02                	ld	s6,32(sp)
 22c:	6be2                	ld	s7,24(sp)
 22e:	6125                	addi	sp,sp,96
 230:	8082                	ret

0000000000000232 <stat>:

int
stat(const char *n, struct stat *st)
{
 232:	1101                	addi	sp,sp,-32
 234:	ec06                	sd	ra,24(sp)
 236:	e822                	sd	s0,16(sp)
 238:	e426                	sd	s1,8(sp)
 23a:	e04a                	sd	s2,0(sp)
 23c:	1000                	addi	s0,sp,32
 23e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 240:	4581                	li	a1,0
 242:	18c000ef          	jal	ra,3ce <open>
  if(fd < 0)
 246:	02054163          	bltz	a0,268 <stat+0x36>
 24a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24c:	85ca                	mv	a1,s2
 24e:	198000ef          	jal	ra,3e6 <fstat>
 252:	892a                	mv	s2,a0
  close(fd);
 254:	8526                	mv	a0,s1
 256:	160000ef          	jal	ra,3b6 <close>
  return r;
}
 25a:	854a                	mv	a0,s2
 25c:	60e2                	ld	ra,24(sp)
 25e:	6442                	ld	s0,16(sp)
 260:	64a2                	ld	s1,8(sp)
 262:	6902                	ld	s2,0(sp)
 264:	6105                	addi	sp,sp,32
 266:	8082                	ret
    return -1;
 268:	597d                	li	s2,-1
 26a:	bfc5                	j	25a <stat+0x28>

000000000000026c <atoi>:

int
atoi(const char *s)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 272:	00054683          	lbu	a3,0(a0)
 276:	fd06879b          	addiw	a5,a3,-48
 27a:	0ff7f793          	zext.b	a5,a5
 27e:	4625                	li	a2,9
 280:	02f66863          	bltu	a2,a5,2b0 <atoi+0x44>
 284:	872a                	mv	a4,a0
  n = 0;
 286:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 288:	0705                	addi	a4,a4,1
 28a:	0025179b          	slliw	a5,a0,0x2
 28e:	9fa9                	addw	a5,a5,a0
 290:	0017979b          	slliw	a5,a5,0x1
 294:	9fb5                	addw	a5,a5,a3
 296:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29a:	00074683          	lbu	a3,0(a4)
 29e:	fd06879b          	addiw	a5,a3,-48
 2a2:	0ff7f793          	zext.b	a5,a5
 2a6:	fef671e3          	bgeu	a2,a5,288 <atoi+0x1c>
  return n;
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  n = 0;
 2b0:	4501                	li	a0,0
 2b2:	bfe5                	j	2aa <atoi+0x3e>

00000000000002b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e422                	sd	s0,8(sp)
 2b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ba:	02b57463          	bgeu	a0,a1,2e2 <memmove+0x2e>
    while(n-- > 0)
 2be:	00c05f63          	blez	a2,2dc <memmove+0x28>
 2c2:	1602                	slli	a2,a2,0x20
 2c4:	9201                	srli	a2,a2,0x20
 2c6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ca:	872a                	mv	a4,a0
      *dst++ = *src++;
 2cc:	0585                	addi	a1,a1,1
 2ce:	0705                	addi	a4,a4,1
 2d0:	fff5c683          	lbu	a3,-1(a1)
 2d4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d8:	fee79ae3          	bne	a5,a4,2cc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret
    dst += n;
 2e2:	00c50733          	add	a4,a0,a2
    src += n;
 2e6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e8:	fec05ae3          	blez	a2,2dc <memmove+0x28>
 2ec:	fff6079b          	addiw	a5,a2,-1
 2f0:	1782                	slli	a5,a5,0x20
 2f2:	9381                	srli	a5,a5,0x20
 2f4:	fff7c793          	not	a5,a5
 2f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fa:	15fd                	addi	a1,a1,-1
 2fc:	177d                	addi	a4,a4,-1
 2fe:	0005c683          	lbu	a3,0(a1)
 302:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 306:	fee79ae3          	bne	a5,a4,2fa <memmove+0x46>
 30a:	bfc9                	j	2dc <memmove+0x28>

000000000000030c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 312:	ca05                	beqz	a2,342 <memcmp+0x36>
 314:	fff6069b          	addiw	a3,a2,-1
 318:	1682                	slli	a3,a3,0x20
 31a:	9281                	srli	a3,a3,0x20
 31c:	0685                	addi	a3,a3,1
 31e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 320:	00054783          	lbu	a5,0(a0)
 324:	0005c703          	lbu	a4,0(a1)
 328:	00e79863          	bne	a5,a4,338 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32c:	0505                	addi	a0,a0,1
    p2++;
 32e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 330:	fed518e3          	bne	a0,a3,320 <memcmp+0x14>
  }
  return 0;
 334:	4501                	li	a0,0
 336:	a019                	j	33c <memcmp+0x30>
      return *p1 - *p2;
 338:	40e7853b          	subw	a0,a5,a4
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  return 0;
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <memcmp+0x30>

0000000000000346 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34e:	f67ff0ef          	jal	ra,2b4 <memmove>
}
 352:	60a2                	ld	ra,8(sp)
 354:	6402                	ld	s0,0(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret

000000000000035a <sbrk>:

char *
sbrk(int n) {
 35a:	1141                	addi	sp,sp,-16
 35c:	e406                	sd	ra,8(sp)
 35e:	e022                	sd	s0,0(sp)
 360:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 362:	4585                	li	a1,1
 364:	0b2000ef          	jal	ra,416 <sys_sbrk>
}
 368:	60a2                	ld	ra,8(sp)
 36a:	6402                	ld	s0,0(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret

0000000000000370 <sbrklazy>:

char *
sbrklazy(int n) {
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 378:	4589                	li	a1,2
 37a:	09c000ef          	jal	ra,416 <sys_sbrk>
}
 37e:	60a2                	ld	ra,8(sp)
 380:	6402                	ld	s0,0(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 386:	4885                	li	a7,1
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <exit>:
.global exit
exit:
 li a7, SYS_exit
 38e:	4889                	li	a7,2
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <wait>:
.global wait
wait:
 li a7, SYS_wait
 396:	488d                	li	a7,3
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39e:	4891                	li	a7,4
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <read>:
.global read
read:
 li a7, SYS_read
 3a6:	4895                	li	a7,5
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <write>:
.global write
write:
 li a7, SYS_write
 3ae:	48c1                	li	a7,16
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <close>:
.global close
close:
 li a7, SYS_close
 3b6:	48d5                	li	a7,21
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <kill>:
.global kill
kill:
 li a7, SYS_kill
 3be:	4899                	li	a7,6
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c6:	489d                	li	a7,7
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <open>:
.global open
open:
 li a7, SYS_open
 3ce:	48bd                	li	a7,15
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d6:	48c5                	li	a7,17
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3de:	48c9                	li	a7,18
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e6:	48a1                	li	a7,8
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <link>:
.global link
link:
 li a7, SYS_link
 3ee:	48cd                	li	a7,19
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f6:	48d1                	li	a7,20
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fe:	48a5                	li	a7,9
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <dup>:
.global dup
dup:
 li a7, SYS_dup
 406:	48a9                	li	a7,10
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40e:	48ad                	li	a7,11
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 416:	48b1                	li	a7,12
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <pause>:
.global pause
pause:
 li a7, SYS_pause
 41e:	48b5                	li	a7,13
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 426:	48b9                	li	a7,14
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 42e:	48d9                	li	a7,22
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 436:	48dd                	li	a7,23
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 43e:	48e1                	li	a7,24
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 446:	48e5                	li	a7,25
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 44e:	48e9                	li	a7,26
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 456:	48ed                	li	a7,27
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 45e:	48f1                	li	a7,28
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 466:	1101                	addi	sp,sp,-32
 468:	ec06                	sd	ra,24(sp)
 46a:	e822                	sd	s0,16(sp)
 46c:	1000                	addi	s0,sp,32
 46e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 472:	4605                	li	a2,1
 474:	fef40593          	addi	a1,s0,-17
 478:	f37ff0ef          	jal	ra,3ae <write>
}
 47c:	60e2                	ld	ra,24(sp)
 47e:	6442                	ld	s0,16(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret

0000000000000484 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 484:	715d                	addi	sp,sp,-80
 486:	e486                	sd	ra,72(sp)
 488:	e0a2                	sd	s0,64(sp)
 48a:	fc26                	sd	s1,56(sp)
 48c:	f84a                	sd	s2,48(sp)
 48e:	f44e                	sd	s3,40(sp)
 490:	0880                	addi	s0,sp,80
 492:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 494:	c299                	beqz	a3,49a <printint+0x16>
 496:	0805c163          	bltz	a1,518 <printint+0x94>
  neg = 0;
 49a:	4881                	li	a7,0
 49c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4a0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4a2:	00000517          	auipc	a0,0x0
 4a6:	55e50513          	addi	a0,a0,1374 # a00 <digits>
 4aa:	883e                	mv	a6,a5
 4ac:	2785                	addiw	a5,a5,1
 4ae:	02c5f733          	remu	a4,a1,a2
 4b2:	972a                	add	a4,a4,a0
 4b4:	00074703          	lbu	a4,0(a4)
 4b8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4bc:	872e                	mv	a4,a1
 4be:	02c5d5b3          	divu	a1,a1,a2
 4c2:	0685                	addi	a3,a3,1
 4c4:	fec773e3          	bgeu	a4,a2,4aa <printint+0x26>
  if(neg)
 4c8:	00088b63          	beqz	a7,4de <printint+0x5a>
    buf[i++] = '-';
 4cc:	fd078793          	addi	a5,a5,-48
 4d0:	97a2                	add	a5,a5,s0
 4d2:	02d00713          	li	a4,45
 4d6:	fee78423          	sb	a4,-24(a5)
 4da:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4de:	02f05663          	blez	a5,50a <printint+0x86>
 4e2:	fb840713          	addi	a4,s0,-72
 4e6:	00f704b3          	add	s1,a4,a5
 4ea:	fff70993          	addi	s3,a4,-1
 4ee:	99be                	add	s3,s3,a5
 4f0:	37fd                	addiw	a5,a5,-1
 4f2:	1782                	slli	a5,a5,0x20
 4f4:	9381                	srli	a5,a5,0x20
 4f6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4fa:	fff4c583          	lbu	a1,-1(s1)
 4fe:	854a                	mv	a0,s2
 500:	f67ff0ef          	jal	ra,466 <putc>
  while(--i >= 0)
 504:	14fd                	addi	s1,s1,-1
 506:	ff349ae3          	bne	s1,s3,4fa <printint+0x76>
}
 50a:	60a6                	ld	ra,72(sp)
 50c:	6406                	ld	s0,64(sp)
 50e:	74e2                	ld	s1,56(sp)
 510:	7942                	ld	s2,48(sp)
 512:	79a2                	ld	s3,40(sp)
 514:	6161                	addi	sp,sp,80
 516:	8082                	ret
    x = -xx;
 518:	40b005b3          	neg	a1,a1
    neg = 1;
 51c:	4885                	li	a7,1
    x = -xx;
 51e:	bfbd                	j	49c <printint+0x18>

0000000000000520 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 520:	7119                	addi	sp,sp,-128
 522:	fc86                	sd	ra,120(sp)
 524:	f8a2                	sd	s0,112(sp)
 526:	f4a6                	sd	s1,104(sp)
 528:	f0ca                	sd	s2,96(sp)
 52a:	ecce                	sd	s3,88(sp)
 52c:	e8d2                	sd	s4,80(sp)
 52e:	e4d6                	sd	s5,72(sp)
 530:	e0da                	sd	s6,64(sp)
 532:	fc5e                	sd	s7,56(sp)
 534:	f862                	sd	s8,48(sp)
 536:	f466                	sd	s9,40(sp)
 538:	f06a                	sd	s10,32(sp)
 53a:	ec6e                	sd	s11,24(sp)
 53c:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 53e:	0005c903          	lbu	s2,0(a1)
 542:	24090c63          	beqz	s2,79a <vprintf+0x27a>
 546:	8b2a                	mv	s6,a0
 548:	8a2e                	mv	s4,a1
 54a:	8bb2                	mv	s7,a2
  state = 0;
 54c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 54e:	4481                	li	s1,0
 550:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 552:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 556:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 55a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 55e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 562:	00000c97          	auipc	s9,0x0
 566:	49ec8c93          	addi	s9,s9,1182 # a00 <digits>
 56a:	a005                	j	58a <vprintf+0x6a>
        putc(fd, c0);
 56c:	85ca                	mv	a1,s2
 56e:	855a                	mv	a0,s6
 570:	ef7ff0ef          	jal	ra,466 <putc>
 574:	a019                	j	57a <vprintf+0x5a>
    } else if(state == '%'){
 576:	03598263          	beq	s3,s5,59a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 57a:	2485                	addiw	s1,s1,1
 57c:	8726                	mv	a4,s1
 57e:	009a07b3          	add	a5,s4,s1
 582:	0007c903          	lbu	s2,0(a5)
 586:	20090a63          	beqz	s2,79a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 58a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 58e:	fe0994e3          	bnez	s3,576 <vprintf+0x56>
      if(c0 == '%'){
 592:	fd579de3          	bne	a5,s5,56c <vprintf+0x4c>
        state = '%';
 596:	89be                	mv	s3,a5
 598:	b7cd                	j	57a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 59a:	c3c1                	beqz	a5,61a <vprintf+0xfa>
 59c:	00ea06b3          	add	a3,s4,a4
 5a0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5a4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5a6:	c681                	beqz	a3,5ae <vprintf+0x8e>
 5a8:	9752                	add	a4,a4,s4
 5aa:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5ae:	03878e63          	beq	a5,s8,5ea <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5b2:	05a78863          	beq	a5,s10,602 <vprintf+0xe2>
      } else if(c0 == 'u'){
 5b6:	0db78b63          	beq	a5,s11,68c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5ba:	07800713          	li	a4,120
 5be:	10e78d63          	beq	a5,a4,6d8 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5c2:	07000713          	li	a4,112
 5c6:	14e78263          	beq	a5,a4,70a <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5ca:	06300713          	li	a4,99
 5ce:	16e78f63          	beq	a5,a4,74c <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5d2:	07300713          	li	a4,115
 5d6:	18e78563          	beq	a5,a4,760 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5da:	05579063          	bne	a5,s5,61a <vprintf+0xfa>
        putc(fd, '%');
 5de:	85d6                	mv	a1,s5
 5e0:	855a                	mv	a0,s6
 5e2:	e85ff0ef          	jal	ra,466 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bf49                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000ba583          	lw	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	e8dff0ef          	jal	ra,484 <printint>
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bfad                	j	57a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 602:	03868663          	beq	a3,s8,62e <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 606:	05a68163          	beq	a3,s10,648 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 60a:	09b68d63          	beq	a3,s11,6a4 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 60e:	03a68f63          	beq	a3,s10,64c <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 612:	07800793          	li	a5,120
 616:	0cf68d63          	beq	a3,a5,6f0 <vprintf+0x1d0>
        putc(fd, '%');
 61a:	85d6                	mv	a1,s5
 61c:	855a                	mv	a0,s6
 61e:	e49ff0ef          	jal	ra,466 <putc>
        putc(fd, c0);
 622:	85ca                	mv	a1,s2
 624:	855a                	mv	a0,s6
 626:	e41ff0ef          	jal	ra,466 <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b7b9                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	008b8913          	addi	s2,s7,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e49ff0ef          	jal	ra,484 <printint>
        i += 1;
 640:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 1;
 646:	bf15                	j	57a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 648:	03860563          	beq	a2,s8,672 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 64c:	07b60963          	beq	a2,s11,6be <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 650:	07800793          	li	a5,120
 654:	fcf613e3          	bne	a2,a5,61a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	e1fff0ef          	jal	ra,484 <printint>
        i += 2;
 66a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
        i += 2;
 670:	b729                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 672:	008b8913          	addi	s2,s7,8
 676:	4685                	li	a3,1
 678:	4629                	li	a2,10
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	e05ff0ef          	jal	ra,484 <printint>
        i += 2;
 684:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
        i += 2;
 68a:	bdc5                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000be583          	lwu	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	debff0ef          	jal	ra,484 <printint>
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bde1                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4629                	li	a2,10
 6ac:	000bb583          	ld	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	dd3ff0ef          	jal	ra,484 <printint>
        i += 1;
 6b6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
        i += 1;
 6bc:	bd7d                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	db9ff0ef          	jal	ra,484 <printint>
        i += 2;
 6d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	b555                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4641                	li	a2,16
 6e0:	000be583          	lwu	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	d9fff0ef          	jal	ra,484 <printint>
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b571                	j	57a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4641                	li	a2,16
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	d87ff0ef          	jal	ra,484 <printint>
        i += 1;
 702:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
        i += 1;
 708:	bd8d                	j	57a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 70a:	008b8793          	addi	a5,s7,8
 70e:	f8f43423          	sd	a5,-120(s0)
 712:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 716:	03000593          	li	a1,48
 71a:	855a                	mv	a0,s6
 71c:	d4bff0ef          	jal	ra,466 <putc>
  putc(fd, 'x');
 720:	07800593          	li	a1,120
 724:	855a                	mv	a0,s6
 726:	d41ff0ef          	jal	ra,466 <putc>
 72a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72c:	03c9d793          	srli	a5,s3,0x3c
 730:	97e6                	add	a5,a5,s9
 732:	0007c583          	lbu	a1,0(a5)
 736:	855a                	mv	a0,s6
 738:	d2fff0ef          	jal	ra,466 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73c:	0992                	slli	s3,s3,0x4
 73e:	397d                	addiw	s2,s2,-1
 740:	fe0916e3          	bnez	s2,72c <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 744:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 748:	4981                	li	s3,0
 74a:	bd05                	j	57a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 74c:	008b8913          	addi	s2,s7,8
 750:	000bc583          	lbu	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	d11ff0ef          	jal	ra,466 <putc>
 75a:	8bca                	mv	s7,s2
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bd31                	j	57a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 760:	008b8993          	addi	s3,s7,8
 764:	000bb903          	ld	s2,0(s7)
 768:	00090f63          	beqz	s2,786 <vprintf+0x266>
        for(; *s; s++)
 76c:	00094583          	lbu	a1,0(s2)
 770:	c195                	beqz	a1,794 <vprintf+0x274>
          putc(fd, *s);
 772:	855a                	mv	a0,s6
 774:	cf3ff0ef          	jal	ra,466 <putc>
        for(; *s; s++)
 778:	0905                	addi	s2,s2,1
 77a:	00094583          	lbu	a1,0(s2)
 77e:	f9f5                	bnez	a1,772 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 780:	8bce                	mv	s7,s3
      state = 0;
 782:	4981                	li	s3,0
 784:	bbdd                	j	57a <vprintf+0x5a>
          s = "(null)";
 786:	00000917          	auipc	s2,0x0
 78a:	27290913          	addi	s2,s2,626 # 9f8 <malloc+0x162>
        for(; *s; s++)
 78e:	02800593          	li	a1,40
 792:	b7c5                	j	772 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 794:	8bce                	mv	s7,s3
      state = 0;
 796:	4981                	li	s3,0
 798:	b3cd                	j	57a <vprintf+0x5a>
    }
  }
}
 79a:	70e6                	ld	ra,120(sp)
 79c:	7446                	ld	s0,112(sp)
 79e:	74a6                	ld	s1,104(sp)
 7a0:	7906                	ld	s2,96(sp)
 7a2:	69e6                	ld	s3,88(sp)
 7a4:	6a46                	ld	s4,80(sp)
 7a6:	6aa6                	ld	s5,72(sp)
 7a8:	6b06                	ld	s6,64(sp)
 7aa:	7be2                	ld	s7,56(sp)
 7ac:	7c42                	ld	s8,48(sp)
 7ae:	7ca2                	ld	s9,40(sp)
 7b0:	7d02                	ld	s10,32(sp)
 7b2:	6de2                	ld	s11,24(sp)
 7b4:	6109                	addi	sp,sp,128
 7b6:	8082                	ret

00000000000007b8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b8:	715d                	addi	sp,sp,-80
 7ba:	ec06                	sd	ra,24(sp)
 7bc:	e822                	sd	s0,16(sp)
 7be:	1000                	addi	s0,sp,32
 7c0:	e010                	sd	a2,0(s0)
 7c2:	e414                	sd	a3,8(s0)
 7c4:	e818                	sd	a4,16(s0)
 7c6:	ec1c                	sd	a5,24(s0)
 7c8:	03043023          	sd	a6,32(s0)
 7cc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d4:	8622                	mv	a2,s0
 7d6:	d4bff0ef          	jal	ra,520 <vprintf>
}
 7da:	60e2                	ld	ra,24(sp)
 7dc:	6442                	ld	s0,16(sp)
 7de:	6161                	addi	sp,sp,80
 7e0:	8082                	ret

00000000000007e2 <printf>:

void
printf(const char *fmt, ...)
{
 7e2:	711d                	addi	sp,sp,-96
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e40c                	sd	a1,8(s0)
 7ec:	e810                	sd	a2,16(s0)
 7ee:	ec14                	sd	a3,24(s0)
 7f0:	f018                	sd	a4,32(s0)
 7f2:	f41c                	sd	a5,40(s0)
 7f4:	03043823          	sd	a6,48(s0)
 7f8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fc:	00840613          	addi	a2,s0,8
 800:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 804:	85aa                	mv	a1,a0
 806:	4505                	li	a0,1
 808:	d19ff0ef          	jal	ra,520 <vprintf>
}
 80c:	60e2                	ld	ra,24(sp)
 80e:	6442                	ld	s0,16(sp)
 810:	6125                	addi	sp,sp,96
 812:	8082                	ret

0000000000000814 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 814:	1141                	addi	sp,sp,-16
 816:	e422                	sd	s0,8(sp)
 818:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	00000797          	auipc	a5,0x0
 822:	7e27b783          	ld	a5,2018(a5) # 1000 <freep>
 826:	a02d                	j	850 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 828:	4618                	lw	a4,8(a2)
 82a:	9f2d                	addw	a4,a4,a1
 82c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	6398                	ld	a4,0(a5)
 832:	6310                	ld	a2,0(a4)
 834:	a83d                	j	872 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 836:	ff852703          	lw	a4,-8(a0)
 83a:	9f31                	addw	a4,a4,a2
 83c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 83e:	ff053683          	ld	a3,-16(a0)
 842:	a091                	j	886 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	6398                	ld	a4,0(a5)
 846:	00e7e463          	bltu	a5,a4,84e <free+0x3a>
 84a:	00e6ea63          	bltu	a3,a4,85e <free+0x4a>
{
 84e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	fed7fae3          	bgeu	a5,a3,844 <free+0x30>
 854:	6398                	ld	a4,0(a5)
 856:	00e6e463          	bltu	a3,a4,85e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85a:	fee7eae3          	bltu	a5,a4,84e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 85e:	ff852583          	lw	a1,-8(a0)
 862:	6390                	ld	a2,0(a5)
 864:	02059813          	slli	a6,a1,0x20
 868:	01c85713          	srli	a4,a6,0x1c
 86c:	9736                	add	a4,a4,a3
 86e:	fae60de3          	beq	a2,a4,828 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 876:	4790                	lw	a2,8(a5)
 878:	02061593          	slli	a1,a2,0x20
 87c:	01c5d713          	srli	a4,a1,0x1c
 880:	973e                	add	a4,a4,a5
 882:	fae68ae3          	beq	a3,a4,836 <free+0x22>
    p->s.ptr = bp->s.ptr;
 886:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 888:	00000717          	auipc	a4,0x0
 88c:	76f73c23          	sd	a5,1912(a4) # 1000 <freep>
}
 890:	6422                	ld	s0,8(sp)
 892:	0141                	addi	sp,sp,16
 894:	8082                	ret

0000000000000896 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 896:	7139                	addi	sp,sp,-64
 898:	fc06                	sd	ra,56(sp)
 89a:	f822                	sd	s0,48(sp)
 89c:	f426                	sd	s1,40(sp)
 89e:	f04a                	sd	s2,32(sp)
 8a0:	ec4e                	sd	s3,24(sp)
 8a2:	e852                	sd	s4,16(sp)
 8a4:	e456                	sd	s5,8(sp)
 8a6:	e05a                	sd	s6,0(sp)
 8a8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8aa:	02051493          	slli	s1,a0,0x20
 8ae:	9081                	srli	s1,s1,0x20
 8b0:	04bd                	addi	s1,s1,15
 8b2:	8091                	srli	s1,s1,0x4
 8b4:	0014899b          	addiw	s3,s1,1
 8b8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ba:	00000517          	auipc	a0,0x0
 8be:	74653503          	ld	a0,1862(a0) # 1000 <freep>
 8c2:	c515                	beqz	a0,8ee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c6:	4798                	lw	a4,8(a5)
 8c8:	02977f63          	bgeu	a4,s1,906 <malloc+0x70>
 8cc:	8a4e                	mv	s4,s3
 8ce:	0009871b          	sext.w	a4,s3
 8d2:	6685                	lui	a3,0x1
 8d4:	00d77363          	bgeu	a4,a3,8da <malloc+0x44>
 8d8:	6a05                	lui	s4,0x1
 8da:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8de:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e2:	00000917          	auipc	s2,0x0
 8e6:	71e90913          	addi	s2,s2,1822 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ea:	5afd                	li	s5,-1
 8ec:	a885                	j	95c <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8ee:	00000797          	auipc	a5,0x0
 8f2:	72278793          	addi	a5,a5,1826 # 1010 <base>
 8f6:	00000717          	auipc	a4,0x0
 8fa:	70f73523          	sd	a5,1802(a4) # 1000 <freep>
 8fe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 900:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 904:	b7e1                	j	8cc <malloc+0x36>
      if(p->s.size == nunits)
 906:	02e48c63          	beq	s1,a4,93e <malloc+0xa8>
        p->s.size -= nunits;
 90a:	4137073b          	subw	a4,a4,s3
 90e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 910:	02071693          	slli	a3,a4,0x20
 914:	01c6d713          	srli	a4,a3,0x1c
 918:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91e:	00000717          	auipc	a4,0x0
 922:	6ea73123          	sd	a0,1762(a4) # 1000 <freep>
      return (void*)(p + 1);
 926:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 92a:	70e2                	ld	ra,56(sp)
 92c:	7442                	ld	s0,48(sp)
 92e:	74a2                	ld	s1,40(sp)
 930:	7902                	ld	s2,32(sp)
 932:	69e2                	ld	s3,24(sp)
 934:	6a42                	ld	s4,16(sp)
 936:	6aa2                	ld	s5,8(sp)
 938:	6b02                	ld	s6,0(sp)
 93a:	6121                	addi	sp,sp,64
 93c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 93e:	6398                	ld	a4,0(a5)
 940:	e118                	sd	a4,0(a0)
 942:	bff1                	j	91e <malloc+0x88>
  hp->s.size = nu;
 944:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 948:	0541                	addi	a0,a0,16
 94a:	ecbff0ef          	jal	ra,814 <free>
  return freep;
 94e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 952:	dd61                	beqz	a0,92a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 954:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 956:	4798                	lw	a4,8(a5)
 958:	fa9777e3          	bgeu	a4,s1,906 <malloc+0x70>
    if(p == freep)
 95c:	00093703          	ld	a4,0(s2)
 960:	853e                	mv	a0,a5
 962:	fef719e3          	bne	a4,a5,954 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 966:	8552                	mv	a0,s4
 968:	9f3ff0ef          	jal	ra,35a <sbrk>
  if(p == SBRK_ERROR)
 96c:	fd551ce3          	bne	a0,s5,944 <malloc+0xae>
        return 0;
 970:	4501                	li	a0,0
 972:	bf65                	j	92a <malloc+0x94>
