
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
  2a:	fee78fa3          	sb	a4,-1(a5) # fff <digits+0x63f>

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
  48:	fee78fa3          	sb	a4,-1(a5) # fff <digits+0x63f>
    printf("child: %c %c (expect B Y)\n", p[0], p[4095]);
  4c:	05900613          	li	a2,89
  50:	04200593          	li	a1,66
  54:	00001517          	auipc	a0,0x1
  58:	8fc50513          	addi	a0,a0,-1796 # 950 <malloc+0xf2>
  5c:	74e000ef          	jal	ra,7aa <printf>
    if(p[0] != 'B' || p[4095] != 'Y') printf("FAIL child\n");
  60:	0004c783          	lbu	a5,0(s1)
  64:	01279a63          	bne	a5,s2,78 <main+0x78>
  68:	6785                	lui	a5,0x1
  6a:	97a6                	add	a5,a5,s1
  6c:	fff7c703          	lbu	a4,-1(a5) # fff <digits+0x63f>
  70:	05900793          	li	a5,89
  74:	00f70863          	beq	a4,a5,84 <main+0x84>
  78:	00001517          	auipc	a0,0x1
  7c:	8f850513          	addi	a0,a0,-1800 # 970 <malloc+0x112>
  80:	72a000ef          	jal	ra,7aa <printf>
    exit(0);
  84:	4501                	li	a0,0
  86:	308000ef          	jal	ra,38e <exit>
    printf("sbrk failed\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	8b650513          	addi	a0,a0,-1866 # 940 <malloc+0xe2>
  92:	718000ef          	jal	ra,7aa <printf>
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
  ac:	fff7c603          	lbu	a2,-1(a5) # fff <digits+0x63f>
  b0:	0004c583          	lbu	a1,0(s1)
  b4:	00001517          	auipc	a0,0x1
  b8:	8cc50513          	addi	a0,a0,-1844 # 980 <malloc+0x122>
  bc:	6ee000ef          	jal	ra,7aa <printf>
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
  e0:	8c450513          	addi	a0,a0,-1852 # 9a0 <malloc+0x142>
  e4:	6c6000ef          	jal	ra,7aa <printf>
  printf("PASS\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	8c850513          	addi	a0,a0,-1848 # 9b0 <malloc+0x152>
  f0:	6ba000ef          	jal	ra,7aa <printf>
  exit(0);
  f4:	4501                	li	a0,0
  f6:	298000ef          	jal	ra,38e <exit>

00000000000000fa <start>:
//
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

000000000000042e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 42e:	1101                	addi	sp,sp,-32
 430:	ec06                	sd	ra,24(sp)
 432:	e822                	sd	s0,16(sp)
 434:	1000                	addi	s0,sp,32
 436:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43a:	4605                	li	a2,1
 43c:	fef40593          	addi	a1,s0,-17
 440:	f6fff0ef          	jal	ra,3ae <write>
}
 444:	60e2                	ld	ra,24(sp)
 446:	6442                	ld	s0,16(sp)
 448:	6105                	addi	sp,sp,32
 44a:	8082                	ret

000000000000044c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 44c:	715d                	addi	sp,sp,-80
 44e:	e486                	sd	ra,72(sp)
 450:	e0a2                	sd	s0,64(sp)
 452:	fc26                	sd	s1,56(sp)
 454:	f84a                	sd	s2,48(sp)
 456:	f44e                	sd	s3,40(sp)
 458:	0880                	addi	s0,sp,80
 45a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 45c:	c299                	beqz	a3,462 <printint+0x16>
 45e:	0805c163          	bltz	a1,4e0 <printint+0x94>
  neg = 0;
 462:	4881                	li	a7,0
 464:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 468:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 46a:	00000517          	auipc	a0,0x0
 46e:	55650513          	addi	a0,a0,1366 # 9c0 <digits>
 472:	883e                	mv	a6,a5
 474:	2785                	addiw	a5,a5,1
 476:	02c5f733          	remu	a4,a1,a2
 47a:	972a                	add	a4,a4,a0
 47c:	00074703          	lbu	a4,0(a4)
 480:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 484:	872e                	mv	a4,a1
 486:	02c5d5b3          	divu	a1,a1,a2
 48a:	0685                	addi	a3,a3,1
 48c:	fec773e3          	bgeu	a4,a2,472 <printint+0x26>
  if(neg)
 490:	00088b63          	beqz	a7,4a6 <printint+0x5a>
    buf[i++] = '-';
 494:	fd078793          	addi	a5,a5,-48
 498:	97a2                	add	a5,a5,s0
 49a:	02d00713          	li	a4,45
 49e:	fee78423          	sb	a4,-24(a5)
 4a2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4a6:	02f05663          	blez	a5,4d2 <printint+0x86>
 4aa:	fb840713          	addi	a4,s0,-72
 4ae:	00f704b3          	add	s1,a4,a5
 4b2:	fff70993          	addi	s3,a4,-1
 4b6:	99be                	add	s3,s3,a5
 4b8:	37fd                	addiw	a5,a5,-1
 4ba:	1782                	slli	a5,a5,0x20
 4bc:	9381                	srli	a5,a5,0x20
 4be:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4c2:	fff4c583          	lbu	a1,-1(s1)
 4c6:	854a                	mv	a0,s2
 4c8:	f67ff0ef          	jal	ra,42e <putc>
  while(--i >= 0)
 4cc:	14fd                	addi	s1,s1,-1
 4ce:	ff349ae3          	bne	s1,s3,4c2 <printint+0x76>
}
 4d2:	60a6                	ld	ra,72(sp)
 4d4:	6406                	ld	s0,64(sp)
 4d6:	74e2                	ld	s1,56(sp)
 4d8:	7942                	ld	s2,48(sp)
 4da:	79a2                	ld	s3,40(sp)
 4dc:	6161                	addi	sp,sp,80
 4de:	8082                	ret
    x = -xx;
 4e0:	40b005b3          	neg	a1,a1
    neg = 1;
 4e4:	4885                	li	a7,1
    x = -xx;
 4e6:	bfbd                	j	464 <printint+0x18>

00000000000004e8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e8:	7119                	addi	sp,sp,-128
 4ea:	fc86                	sd	ra,120(sp)
 4ec:	f8a2                	sd	s0,112(sp)
 4ee:	f4a6                	sd	s1,104(sp)
 4f0:	f0ca                	sd	s2,96(sp)
 4f2:	ecce                	sd	s3,88(sp)
 4f4:	e8d2                	sd	s4,80(sp)
 4f6:	e4d6                	sd	s5,72(sp)
 4f8:	e0da                	sd	s6,64(sp)
 4fa:	fc5e                	sd	s7,56(sp)
 4fc:	f862                	sd	s8,48(sp)
 4fe:	f466                	sd	s9,40(sp)
 500:	f06a                	sd	s10,32(sp)
 502:	ec6e                	sd	s11,24(sp)
 504:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 506:	0005c903          	lbu	s2,0(a1)
 50a:	24090c63          	beqz	s2,762 <vprintf+0x27a>
 50e:	8b2a                	mv	s6,a0
 510:	8a2e                	mv	s4,a1
 512:	8bb2                	mv	s7,a2
  state = 0;
 514:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 516:	4481                	li	s1,0
 518:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 51a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 51e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 522:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 526:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 52a:	00000c97          	auipc	s9,0x0
 52e:	496c8c93          	addi	s9,s9,1174 # 9c0 <digits>
 532:	a005                	j	552 <vprintf+0x6a>
        putc(fd, c0);
 534:	85ca                	mv	a1,s2
 536:	855a                	mv	a0,s6
 538:	ef7ff0ef          	jal	ra,42e <putc>
 53c:	a019                	j	542 <vprintf+0x5a>
    } else if(state == '%'){
 53e:	03598263          	beq	s3,s5,562 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 542:	2485                	addiw	s1,s1,1
 544:	8726                	mv	a4,s1
 546:	009a07b3          	add	a5,s4,s1
 54a:	0007c903          	lbu	s2,0(a5)
 54e:	20090a63          	beqz	s2,762 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 552:	0009079b          	sext.w	a5,s2
    if(state == 0){
 556:	fe0994e3          	bnez	s3,53e <vprintf+0x56>
      if(c0 == '%'){
 55a:	fd579de3          	bne	a5,s5,534 <vprintf+0x4c>
        state = '%';
 55e:	89be                	mv	s3,a5
 560:	b7cd                	j	542 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 562:	c3c1                	beqz	a5,5e2 <vprintf+0xfa>
 564:	00ea06b3          	add	a3,s4,a4
 568:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 56c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 56e:	c681                	beqz	a3,576 <vprintf+0x8e>
 570:	9752                	add	a4,a4,s4
 572:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 576:	03878e63          	beq	a5,s8,5b2 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 57a:	05a78863          	beq	a5,s10,5ca <vprintf+0xe2>
      } else if(c0 == 'u'){
 57e:	0db78b63          	beq	a5,s11,654 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 582:	07800713          	li	a4,120
 586:	10e78d63          	beq	a5,a4,6a0 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 58a:	07000713          	li	a4,112
 58e:	14e78263          	beq	a5,a4,6d2 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 592:	06300713          	li	a4,99
 596:	16e78f63          	beq	a5,a4,714 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 59a:	07300713          	li	a4,115
 59e:	18e78563          	beq	a5,a4,728 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5a2:	05579063          	bne	a5,s5,5e2 <vprintf+0xfa>
        putc(fd, '%');
 5a6:	85d6                	mv	a1,s5
 5a8:	855a                	mv	a0,s6
 5aa:	e85ff0ef          	jal	ra,42e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	bf49                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4685                	li	a3,1
 5b8:	4629                	li	a2,10
 5ba:	000ba583          	lw	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	e8dff0ef          	jal	ra,44c <printint>
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bfad                	j	542 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ca:	03868663          	beq	a3,s8,5f6 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ce:	05a68163          	beq	a3,s10,610 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5d2:	09b68d63          	beq	a3,s11,66c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d6:	03a68f63          	beq	a3,s10,614 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5da:	07800793          	li	a5,120
 5de:	0cf68d63          	beq	a3,a5,6b8 <vprintf+0x1d0>
        putc(fd, '%');
 5e2:	85d6                	mv	a1,s5
 5e4:	855a                	mv	a0,s6
 5e6:	e49ff0ef          	jal	ra,42e <putc>
        putc(fd, c0);
 5ea:	85ca                	mv	a1,s2
 5ec:	855a                	mv	a0,s6
 5ee:	e41ff0ef          	jal	ra,42e <putc>
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b7b9                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4685                	li	a3,1
 5fc:	4629                	li	a2,10
 5fe:	000bb583          	ld	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	e49ff0ef          	jal	ra,44c <printint>
        i += 1;
 608:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
        i += 1;
 60e:	bf15                	j	542 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 610:	03860563          	beq	a2,s8,63a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 614:	07b60963          	beq	a2,s11,686 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 618:	07800793          	li	a5,120
 61c:	fcf613e3          	bne	a2,a5,5e2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 620:	008b8913          	addi	s2,s7,8
 624:	4681                	li	a3,0
 626:	4641                	li	a2,16
 628:	000bb583          	ld	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	e1fff0ef          	jal	ra,44c <printint>
        i += 2;
 632:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
        i += 2;
 638:	b729                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4685                	li	a3,1
 640:	4629                	li	a2,10
 642:	000bb583          	ld	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	e05ff0ef          	jal	ra,44c <printint>
        i += 2;
 64c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
        i += 2;
 652:	bdc5                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 654:	008b8913          	addi	s2,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000be583          	lwu	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	debff0ef          	jal	ra,44c <printint>
 666:	8bca                	mv	s7,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	bde1                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66c:	008b8913          	addi	s2,s7,8
 670:	4681                	li	a3,0
 672:	4629                	li	a2,10
 674:	000bb583          	ld	a1,0(s7)
 678:	855a                	mv	a0,s6
 67a:	dd3ff0ef          	jal	ra,44c <printint>
        i += 1;
 67e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 680:	8bca                	mv	s7,s2
      state = 0;
 682:	4981                	li	s3,0
        i += 1;
 684:	bd7d                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 686:	008b8913          	addi	s2,s7,8
 68a:	4681                	li	a3,0
 68c:	4629                	li	a2,10
 68e:	000bb583          	ld	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	db9ff0ef          	jal	ra,44c <printint>
        i += 2;
 698:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
        i += 2;
 69e:	b555                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4641                	li	a2,16
 6a8:	000be583          	lwu	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d9fff0ef          	jal	ra,44c <printint>
 6b2:	8bca                	mv	s7,s2
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b571                	j	542 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b8:	008b8913          	addi	s2,s7,8
 6bc:	4681                	li	a3,0
 6be:	4641                	li	a2,16
 6c0:	000bb583          	ld	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	d87ff0ef          	jal	ra,44c <printint>
        i += 1;
 6ca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6cc:	8bca                	mv	s7,s2
      state = 0;
 6ce:	4981                	li	s3,0
        i += 1;
 6d0:	bd8d                	j	542 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6d2:	008b8793          	addi	a5,s7,8
 6d6:	f8f43423          	sd	a5,-120(s0)
 6da:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6de:	03000593          	li	a1,48
 6e2:	855a                	mv	a0,s6
 6e4:	d4bff0ef          	jal	ra,42e <putc>
  putc(fd, 'x');
 6e8:	07800593          	li	a1,120
 6ec:	855a                	mv	a0,s6
 6ee:	d41ff0ef          	jal	ra,42e <putc>
 6f2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f4:	03c9d793          	srli	a5,s3,0x3c
 6f8:	97e6                	add	a5,a5,s9
 6fa:	0007c583          	lbu	a1,0(a5)
 6fe:	855a                	mv	a0,s6
 700:	d2fff0ef          	jal	ra,42e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 704:	0992                	slli	s3,s3,0x4
 706:	397d                	addiw	s2,s2,-1
 708:	fe0916e3          	bnez	s2,6f4 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 70c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 710:	4981                	li	s3,0
 712:	bd05                	j	542 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 714:	008b8913          	addi	s2,s7,8
 718:	000bc583          	lbu	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	d11ff0ef          	jal	ra,42e <putc>
 722:	8bca                	mv	s7,s2
      state = 0;
 724:	4981                	li	s3,0
 726:	bd31                	j	542 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 728:	008b8993          	addi	s3,s7,8
 72c:	000bb903          	ld	s2,0(s7)
 730:	00090f63          	beqz	s2,74e <vprintf+0x266>
        for(; *s; s++)
 734:	00094583          	lbu	a1,0(s2)
 738:	c195                	beqz	a1,75c <vprintf+0x274>
          putc(fd, *s);
 73a:	855a                	mv	a0,s6
 73c:	cf3ff0ef          	jal	ra,42e <putc>
        for(; *s; s++)
 740:	0905                	addi	s2,s2,1
 742:	00094583          	lbu	a1,0(s2)
 746:	f9f5                	bnez	a1,73a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 748:	8bce                	mv	s7,s3
      state = 0;
 74a:	4981                	li	s3,0
 74c:	bbdd                	j	542 <vprintf+0x5a>
          s = "(null)";
 74e:	00000917          	auipc	s2,0x0
 752:	26a90913          	addi	s2,s2,618 # 9b8 <malloc+0x15a>
        for(; *s; s++)
 756:	02800593          	li	a1,40
 75a:	b7c5                	j	73a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 75c:	8bce                	mv	s7,s3
      state = 0;
 75e:	4981                	li	s3,0
 760:	b3cd                	j	542 <vprintf+0x5a>
    }
  }
}
 762:	70e6                	ld	ra,120(sp)
 764:	7446                	ld	s0,112(sp)
 766:	74a6                	ld	s1,104(sp)
 768:	7906                	ld	s2,96(sp)
 76a:	69e6                	ld	s3,88(sp)
 76c:	6a46                	ld	s4,80(sp)
 76e:	6aa6                	ld	s5,72(sp)
 770:	6b06                	ld	s6,64(sp)
 772:	7be2                	ld	s7,56(sp)
 774:	7c42                	ld	s8,48(sp)
 776:	7ca2                	ld	s9,40(sp)
 778:	7d02                	ld	s10,32(sp)
 77a:	6de2                	ld	s11,24(sp)
 77c:	6109                	addi	sp,sp,128
 77e:	8082                	ret

0000000000000780 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 780:	715d                	addi	sp,sp,-80
 782:	ec06                	sd	ra,24(sp)
 784:	e822                	sd	s0,16(sp)
 786:	1000                	addi	s0,sp,32
 788:	e010                	sd	a2,0(s0)
 78a:	e414                	sd	a3,8(s0)
 78c:	e818                	sd	a4,16(s0)
 78e:	ec1c                	sd	a5,24(s0)
 790:	03043023          	sd	a6,32(s0)
 794:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 798:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 79c:	8622                	mv	a2,s0
 79e:	d4bff0ef          	jal	ra,4e8 <vprintf>
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6161                	addi	sp,sp,80
 7a8:	8082                	ret

00000000000007aa <printf>:

void
printf(const char *fmt, ...)
{
 7aa:	711d                	addi	sp,sp,-96
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	1000                	addi	s0,sp,32
 7b2:	e40c                	sd	a1,8(s0)
 7b4:	e810                	sd	a2,16(s0)
 7b6:	ec14                	sd	a3,24(s0)
 7b8:	f018                	sd	a4,32(s0)
 7ba:	f41c                	sd	a5,40(s0)
 7bc:	03043823          	sd	a6,48(s0)
 7c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c4:	00840613          	addi	a2,s0,8
 7c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7cc:	85aa                	mv	a1,a0
 7ce:	4505                	li	a0,1
 7d0:	d19ff0ef          	jal	ra,4e8 <vprintf>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6125                	addi	sp,sp,96
 7da:	8082                	ret

00000000000007dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7dc:	1141                	addi	sp,sp,-16
 7de:	e422                	sd	s0,8(sp)
 7e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	00001797          	auipc	a5,0x1
 7ea:	81a7b783          	ld	a5,-2022(a5) # 1000 <freep>
 7ee:	a02d                	j	818 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f0:	4618                	lw	a4,8(a2)
 7f2:	9f2d                	addw	a4,a4,a1
 7f4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	6398                	ld	a4,0(a5)
 7fa:	6310                	ld	a2,0(a4)
 7fc:	a83d                	j	83a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fe:	ff852703          	lw	a4,-8(a0)
 802:	9f31                	addw	a4,a4,a2
 804:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 806:	ff053683          	ld	a3,-16(a0)
 80a:	a091                	j	84e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	6398                	ld	a4,0(a5)
 80e:	00e7e463          	bltu	a5,a4,816 <free+0x3a>
 812:	00e6ea63          	bltu	a3,a4,826 <free+0x4a>
{
 816:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 818:	fed7fae3          	bgeu	a5,a3,80c <free+0x30>
 81c:	6398                	ld	a4,0(a5)
 81e:	00e6e463          	bltu	a3,a4,826 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 822:	fee7eae3          	bltu	a5,a4,816 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 826:	ff852583          	lw	a1,-8(a0)
 82a:	6390                	ld	a2,0(a5)
 82c:	02059813          	slli	a6,a1,0x20
 830:	01c85713          	srli	a4,a6,0x1c
 834:	9736                	add	a4,a4,a3
 836:	fae60de3          	beq	a2,a4,7f0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 83a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 83e:	4790                	lw	a2,8(a5)
 840:	02061593          	slli	a1,a2,0x20
 844:	01c5d713          	srli	a4,a1,0x1c
 848:	973e                	add	a4,a4,a5
 84a:	fae68ae3          	beq	a3,a4,7fe <free+0x22>
    p->s.ptr = bp->s.ptr;
 84e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 850:	00000717          	auipc	a4,0x0
 854:	7af73823          	sd	a5,1968(a4) # 1000 <freep>
}
 858:	6422                	ld	s0,8(sp)
 85a:	0141                	addi	sp,sp,16
 85c:	8082                	ret

000000000000085e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 85e:	7139                	addi	sp,sp,-64
 860:	fc06                	sd	ra,56(sp)
 862:	f822                	sd	s0,48(sp)
 864:	f426                	sd	s1,40(sp)
 866:	f04a                	sd	s2,32(sp)
 868:	ec4e                	sd	s3,24(sp)
 86a:	e852                	sd	s4,16(sp)
 86c:	e456                	sd	s5,8(sp)
 86e:	e05a                	sd	s6,0(sp)
 870:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 872:	02051493          	slli	s1,a0,0x20
 876:	9081                	srli	s1,s1,0x20
 878:	04bd                	addi	s1,s1,15
 87a:	8091                	srli	s1,s1,0x4
 87c:	0014899b          	addiw	s3,s1,1
 880:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 882:	00000517          	auipc	a0,0x0
 886:	77e53503          	ld	a0,1918(a0) # 1000 <freep>
 88a:	c515                	beqz	a0,8b6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88e:	4798                	lw	a4,8(a5)
 890:	02977f63          	bgeu	a4,s1,8ce <malloc+0x70>
 894:	8a4e                	mv	s4,s3
 896:	0009871b          	sext.w	a4,s3
 89a:	6685                	lui	a3,0x1
 89c:	00d77363          	bgeu	a4,a3,8a2 <malloc+0x44>
 8a0:	6a05                	lui	s4,0x1
 8a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8aa:	00000917          	auipc	s2,0x0
 8ae:	75690913          	addi	s2,s2,1878 # 1000 <freep>
  if(p == SBRK_ERROR)
 8b2:	5afd                	li	s5,-1
 8b4:	a885                	j	924 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8b6:	00000797          	auipc	a5,0x0
 8ba:	75a78793          	addi	a5,a5,1882 # 1010 <base>
 8be:	00000717          	auipc	a4,0x0
 8c2:	74f73123          	sd	a5,1858(a4) # 1000 <freep>
 8c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8cc:	b7e1                	j	894 <malloc+0x36>
      if(p->s.size == nunits)
 8ce:	02e48c63          	beq	s1,a4,906 <malloc+0xa8>
        p->s.size -= nunits;
 8d2:	4137073b          	subw	a4,a4,s3
 8d6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d8:	02071693          	slli	a3,a4,0x20
 8dc:	01c6d713          	srli	a4,a3,0x1c
 8e0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e6:	00000717          	auipc	a4,0x0
 8ea:	70a73d23          	sd	a0,1818(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ee:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f2:	70e2                	ld	ra,56(sp)
 8f4:	7442                	ld	s0,48(sp)
 8f6:	74a2                	ld	s1,40(sp)
 8f8:	7902                	ld	s2,32(sp)
 8fa:	69e2                	ld	s3,24(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
 902:	6121                	addi	sp,sp,64
 904:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	e118                	sd	a4,0(a0)
 90a:	bff1                	j	8e6 <malloc+0x88>
  hp->s.size = nu;
 90c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 910:	0541                	addi	a0,a0,16
 912:	ecbff0ef          	jal	ra,7dc <free>
  return freep;
 916:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 91a:	dd61                	beqz	a0,8f2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91e:	4798                	lw	a4,8(a5)
 920:	fa9777e3          	bgeu	a4,s1,8ce <malloc+0x70>
    if(p == freep)
 924:	00093703          	ld	a4,0(s2)
 928:	853e                	mv	a0,a5
 92a:	fef719e3          	bne	a4,a5,91c <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 92e:	8552                	mv	a0,s4
 930:	a2bff0ef          	jal	ra,35a <sbrk>
  if(p == SBRK_ERROR)
 934:	fd551ce3          	bne	a0,s5,90c <malloc+0xae>
        return 0;
 938:	4501                	li	a0,0
 93a:	bf65                	j	8f2 <malloc+0x94>
