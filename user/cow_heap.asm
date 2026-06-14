
user/_cow_heap:     file format elf64-littleriscv


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
   e:	34e000ef          	jal	ra,35c <sbrk>
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
  2a:	fee78fa3          	sb	a4,-1(a5) # fff <digits+0x5ef>

  int pid = fork();
  2e:	35a000ef          	jal	ra,388 <fork>
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
  48:	fee78fa3          	sb	a4,-1(a5) # fff <digits+0x5ef>
    printf("child: %c %c (expect B Y)\n", p[0], p[4095]);
  4c:	05900613          	li	a2,89
  50:	04200593          	li	a1,66
  54:	00001517          	auipc	a0,0x1
  58:	94c50513          	addi	a0,a0,-1716 # 9a0 <malloc+0xfa>
  5c:	790000ef          	jal	ra,7ec <printf>
    if(p[0] != 'B' || p[4095] != 'Y') printf("FAIL child\n");
  60:	0004c783          	lbu	a5,0(s1)
  64:	01279a63          	bne	a5,s2,78 <main+0x78>
  68:	6505                	lui	a0,0x1
  6a:	94aa                	add	s1,s1,a0
  6c:	fff4c703          	lbu	a4,-1(s1)
  70:	05900793          	li	a5,89
  74:	00f70863          	beq	a4,a5,84 <main+0x84>
  78:	00001517          	auipc	a0,0x1
  7c:	94850513          	addi	a0,a0,-1720 # 9c0 <malloc+0x11a>
  80:	76c000ef          	jal	ra,7ec <printf>
    exit(0);
  84:	4501                	li	a0,0
  86:	30a000ef          	jal	ra,390 <exit>
    printf("sbrk failed\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	90650513          	addi	a0,a0,-1786 # 990 <malloc+0xea>
  92:	75a000ef          	jal	ra,7ec <printf>
    exit(1);
  96:	4505                	li	a0,1
  98:	2f8000ef          	jal	ra,390 <exit>
  if(pid < 0) exit(1);
  9c:	4505                	li	a0,1
  9e:	2f2000ef          	jal	ra,390 <exit>
  }

  wait(0);
  a2:	4501                	li	a0,0
  a4:	2f4000ef          	jal	ra,398 <wait>
  printf("parent: %c %c (expect A Z)\n", p[0], p[4095]);
  a8:	6785                	lui	a5,0x1
  aa:	97a6                	add	a5,a5,s1
  ac:	fff7c603          	lbu	a2,-1(a5) # fff <digits+0x5ef>
  b0:	0004c583          	lbu	a1,0(s1)
  b4:	00001517          	auipc	a0,0x1
  b8:	91c50513          	addi	a0,a0,-1764 # 9d0 <malloc+0x12a>
  bc:	730000ef          	jal	ra,7ec <printf>
  if(p[0] != 'A' || p[4095] != 'Z') printf("FAIL parent\n");
  c0:	0004c703          	lbu	a4,0(s1)
  c4:	04100793          	li	a5,65
  c8:	00f71a63          	bne	a4,a5,dc <main+0xdc>
  cc:	6505                	lui	a0,0x1
  ce:	94aa                	add	s1,s1,a0
  d0:	fff4c703          	lbu	a4,-1(s1)
  d4:	05a00793          	li	a5,90
  d8:	00f70863          	beq	a4,a5,e8 <main+0xe8>
  dc:	00001517          	auipc	a0,0x1
  e0:	91450513          	addi	a0,a0,-1772 # 9f0 <malloc+0x14a>
  e4:	708000ef          	jal	ra,7ec <printf>
  printf("PASS\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	91850513          	addi	a0,a0,-1768 # a00 <malloc+0x15a>
  f0:	6fc000ef          	jal	ra,7ec <printf>
  exit(0);
  f4:	4501                	li	a0,0
  f6:	29a000ef          	jal	ra,390 <exit>

00000000000000fa <start>:
 *   argv - 命令行参数数组
 */

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
 106:	28a000ef          	jal	ra,390 <exit>

000000000000010a <strcpy>:
 *   目标字符串s的指针
 */

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
 114:	0785                	addi	a5,a5,1
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
 *   负数 - p小于q
 */

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
 *   字符串s的长度
 */

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
 *   目标内存区域dst的指针
 */

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
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

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
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

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
 1f4:	1b4000ef          	jal	ra,3a8 <read>
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
 *   -1 - 失败
 */

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
 242:	18e000ef          	jal	ra,3d0 <open>
  if(fd < 0)
 246:	02054163          	bltz	a0,268 <stat+0x36>
 24a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24c:	85ca                	mv	a1,s2
 24e:	19a000ef          	jal	ra,3e8 <fstat>
 252:	892a                	mv	s2,a0
  close(fd);
 254:	8526                	mv	a0,s1
 256:	162000ef          	jal	ra,3b8 <close>
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
 *   转换后的整数
 */

int
atoi(const char *s)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 272:	00054603          	lbu	a2,0(a0)
 276:	fd06079b          	addiw	a5,a2,-48
 27a:	0ff7f793          	andi	a5,a5,255
 27e:	4725                	li	a4,9
 280:	02f76963          	bltu	a4,a5,2b2 <atoi+0x46>
 284:	86aa                	mv	a3,a0
  n = 0;
 286:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 288:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 28a:	0685                	addi	a3,a3,1
 28c:	0025179b          	slliw	a5,a0,0x2
 290:	9fa9                	addw	a5,a5,a0
 292:	0017979b          	slliw	a5,a5,0x1
 296:	9fb1                	addw	a5,a5,a2
 298:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29c:	0006c603          	lbu	a2,0(a3)
 2a0:	fd06071b          	addiw	a4,a2,-48
 2a4:	0ff77713          	andi	a4,a4,255
 2a8:	fee5f1e3          	bgeu	a1,a4,28a <atoi+0x1e>
  return n;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
  n = 0;
 2b2:	4501                	li	a0,0
 2b4:	bfe5                	j	2ac <atoi+0x40>

00000000000002b6 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2bc:	02b57463          	bgeu	a0,a1,2e4 <memmove+0x2e>
    while(n-- > 0)
 2c0:	00c05f63          	blez	a2,2de <memmove+0x28>
 2c4:	1602                	slli	a2,a2,0x20
 2c6:	9201                	srli	a2,a2,0x20
 2c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ce:	0585                	addi	a1,a1,1
 2d0:	0705                	addi	a4,a4,1
 2d2:	fff5c683          	lbu	a3,-1(a1)
 2d6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
    dst += n;
 2e4:	00c50733          	add	a4,a0,a2
    src += n;
 2e8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ea:	fec05ae3          	blez	a2,2de <memmove+0x28>
 2ee:	fff6079b          	addiw	a5,a2,-1
 2f2:	1782                	slli	a5,a5,0x20
 2f4:	9381                	srli	a5,a5,0x20
 2f6:	fff7c793          	not	a5,a5
 2fa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fc:	15fd                	addi	a1,a1,-1
 2fe:	177d                	addi	a4,a4,-1
 300:	0005c683          	lbu	a3,0(a1)
 304:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 308:	fee79ae3          	bne	a5,a4,2fc <memmove+0x46>
 30c:	bfc9                	j	2de <memmove+0x28>

000000000000030e <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 314:	ca05                	beqz	a2,344 <memcmp+0x36>
 316:	fff6069b          	addiw	a3,a2,-1
 31a:	1682                	slli	a3,a3,0x20
 31c:	9281                	srli	a3,a3,0x20
 31e:	0685                	addi	a3,a3,1
 320:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 322:	00054783          	lbu	a5,0(a0)
 326:	0005c703          	lbu	a4,0(a1)
 32a:	00e79863          	bne	a5,a4,33a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32e:	0505                	addi	a0,a0,1
    p2++;
 330:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 332:	fed518e3          	bne	a0,a3,322 <memcmp+0x14>
  }
  return 0;
 336:	4501                	li	a0,0
 338:	a019                	j	33e <memcmp+0x30>
      return *p1 - *p2;
 33a:	40e7853b          	subw	a0,a5,a4
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  return 0;
 344:	4501                	li	a0,0
 346:	bfe5                	j	33e <memcmp+0x30>

0000000000000348 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 350:	f67ff0ef          	jal	ra,2b6 <memmove>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 35c:	1141                	addi	sp,sp,-16
 35e:	e406                	sd	ra,8(sp)
 360:	e022                	sd	s0,0(sp)
 362:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 364:	4585                	li	a1,1
 366:	0b2000ef          	jal	ra,418 <sys_sbrk>
}
 36a:	60a2                	ld	ra,8(sp)
 36c:	6402                	ld	s0,0(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 372:	1141                	addi	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 37a:	4589                	li	a1,2
 37c:	09c000ef          	jal	ra,418 <sys_sbrk>
}
 380:	60a2                	ld	ra,8(sp)
 382:	6402                	ld	s0,0(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 388:	4885                	li	a7,1
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exit>:
.global exit
exit:
 li a7, SYS_exit
 390:	4889                	li	a7,2
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <wait>:
.global wait
wait:
 li a7, SYS_wait
 398:	488d                	li	a7,3
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a0:	4891                	li	a7,4
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <read>:
.global read
read:
 li a7, SYS_read
 3a8:	4895                	li	a7,5
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <write>:
.global write
write:
 li a7, SYS_write
 3b0:	48c1                	li	a7,16
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <close>:
.global close
close:
 li a7, SYS_close
 3b8:	48d5                	li	a7,21
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c0:	4899                	li	a7,6
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c8:	489d                	li	a7,7
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <open>:
.global open
open:
 li a7, SYS_open
 3d0:	48bd                	li	a7,15
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d8:	48c5                	li	a7,17
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e0:	48c9                	li	a7,18
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e8:	48a1                	li	a7,8
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <link>:
.global link
link:
 li a7, SYS_link
 3f0:	48cd                	li	a7,19
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f8:	48d1                	li	a7,20
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 400:	48a5                	li	a7,9
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <dup>:
.global dup
dup:
 li a7, SYS_dup
 408:	48a9                	li	a7,10
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 410:	48ad                	li	a7,11
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 418:	48b1                	li	a7,12
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <pause>:
.global pause
pause:
 li a7, SYS_pause
 420:	48b5                	li	a7,13
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 428:	48b9                	li	a7,14
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 430:	48d9                	li	a7,22
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 438:	48dd                	li	a7,23
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 440:	48e1                	li	a7,24
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 448:	48e5                	li	a7,25
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 450:	48e9                	li	a7,26
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 458:	48ed                	li	a7,27
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 460:	48f1                	li	a7,28
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 468:	48f5                	li	a7,29
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 470:	1101                	addi	sp,sp,-32
 472:	ec06                	sd	ra,24(sp)
 474:	e822                	sd	s0,16(sp)
 476:	1000                	addi	s0,sp,32
 478:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47c:	4605                	li	a2,1
 47e:	fef40593          	addi	a1,s0,-17
 482:	f2fff0ef          	jal	ra,3b0 <write>
}
 486:	60e2                	ld	ra,24(sp)
 488:	6442                	ld	s0,16(sp)
 48a:	6105                	addi	sp,sp,32
 48c:	8082                	ret

000000000000048e <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 48e:	715d                	addi	sp,sp,-80
 490:	e486                	sd	ra,72(sp)
 492:	e0a2                	sd	s0,64(sp)
 494:	fc26                	sd	s1,56(sp)
 496:	f84a                	sd	s2,48(sp)
 498:	f44e                	sd	s3,40(sp)
 49a:	0880                	addi	s0,sp,80
 49c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 49e:	c299                	beqz	a3,4a4 <printint+0x16>
 4a0:	0805c163          	bltz	a1,522 <printint+0x94>
  neg = 0;
 4a4:	4881                	li	a7,0
 4a6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4aa:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ac:	00000517          	auipc	a0,0x0
 4b0:	56450513          	addi	a0,a0,1380 # a10 <digits>
 4b4:	883e                	mv	a6,a5
 4b6:	2785                	addiw	a5,a5,1
 4b8:	02c5f733          	remu	a4,a1,a2
 4bc:	972a                	add	a4,a4,a0
 4be:	00074703          	lbu	a4,0(a4)
 4c2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c6:	872e                	mv	a4,a1
 4c8:	02c5d5b3          	divu	a1,a1,a2
 4cc:	0685                	addi	a3,a3,1
 4ce:	fec773e3          	bgeu	a4,a2,4b4 <printint+0x26>
  if(neg)
 4d2:	00088b63          	beqz	a7,4e8 <printint+0x5a>
    buf[i++] = '-';
 4d6:	fd040713          	addi	a4,s0,-48
 4da:	97ba                	add	a5,a5,a4
 4dc:	02d00713          	li	a4,45
 4e0:	fee78423          	sb	a4,-24(a5)
 4e4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4e8:	02f05663          	blez	a5,514 <printint+0x86>
 4ec:	fb840713          	addi	a4,s0,-72
 4f0:	00f704b3          	add	s1,a4,a5
 4f4:	fff70993          	addi	s3,a4,-1
 4f8:	99be                	add	s3,s3,a5
 4fa:	37fd                	addiw	a5,a5,-1
 4fc:	1782                	slli	a5,a5,0x20
 4fe:	9381                	srli	a5,a5,0x20
 500:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 504:	fff4c583          	lbu	a1,-1(s1)
 508:	854a                	mv	a0,s2
 50a:	f67ff0ef          	jal	ra,470 <putc>
  while(--i >= 0)
 50e:	14fd                	addi	s1,s1,-1
 510:	ff349ae3          	bne	s1,s3,504 <printint+0x76>
}
 514:	60a6                	ld	ra,72(sp)
 516:	6406                	ld	s0,64(sp)
 518:	74e2                	ld	s1,56(sp)
 51a:	7942                	ld	s2,48(sp)
 51c:	79a2                	ld	s3,40(sp)
 51e:	6161                	addi	sp,sp,80
 520:	8082                	ret
    x = -xx;
 522:	40b005b3          	neg	a1,a1
    neg = 1;
 526:	4885                	li	a7,1
    x = -xx;
 528:	bfbd                	j	4a6 <printint+0x18>

000000000000052a <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 52a:	7119                	addi	sp,sp,-128
 52c:	fc86                	sd	ra,120(sp)
 52e:	f8a2                	sd	s0,112(sp)
 530:	f4a6                	sd	s1,104(sp)
 532:	f0ca                	sd	s2,96(sp)
 534:	ecce                	sd	s3,88(sp)
 536:	e8d2                	sd	s4,80(sp)
 538:	e4d6                	sd	s5,72(sp)
 53a:	e0da                	sd	s6,64(sp)
 53c:	fc5e                	sd	s7,56(sp)
 53e:	f862                	sd	s8,48(sp)
 540:	f466                	sd	s9,40(sp)
 542:	f06a                	sd	s10,32(sp)
 544:	ec6e                	sd	s11,24(sp)
 546:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 548:	0005c903          	lbu	s2,0(a1)
 54c:	24090c63          	beqz	s2,7a4 <vprintf+0x27a>
 550:	8b2a                	mv	s6,a0
 552:	8a2e                	mv	s4,a1
 554:	8bb2                	mv	s7,a2
  state = 0;
 556:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 558:	4481                	li	s1,0
 55a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 55c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 560:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 564:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 568:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56c:	00000c97          	auipc	s9,0x0
 570:	4a4c8c93          	addi	s9,s9,1188 # a10 <digits>
 574:	a005                	j	594 <vprintf+0x6a>
        putc(fd, c0);
 576:	85ca                	mv	a1,s2
 578:	855a                	mv	a0,s6
 57a:	ef7ff0ef          	jal	ra,470 <putc>
 57e:	a019                	j	584 <vprintf+0x5a>
    } else if(state == '%'){
 580:	03598263          	beq	s3,s5,5a4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 584:	2485                	addiw	s1,s1,1
 586:	8726                	mv	a4,s1
 588:	009a07b3          	add	a5,s4,s1
 58c:	0007c903          	lbu	s2,0(a5)
 590:	20090a63          	beqz	s2,7a4 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 594:	0009079b          	sext.w	a5,s2
    if(state == 0){
 598:	fe0994e3          	bnez	s3,580 <vprintf+0x56>
      if(c0 == '%'){
 59c:	fd579de3          	bne	a5,s5,576 <vprintf+0x4c>
        state = '%';
 5a0:	89be                	mv	s3,a5
 5a2:	b7cd                	j	584 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a4:	c3c1                	beqz	a5,624 <vprintf+0xfa>
 5a6:	00ea06b3          	add	a3,s4,a4
 5aa:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5ae:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5b0:	c681                	beqz	a3,5b8 <vprintf+0x8e>
 5b2:	9752                	add	a4,a4,s4
 5b4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b8:	03878e63          	beq	a5,s8,5f4 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5bc:	05a78863          	beq	a5,s10,60c <vprintf+0xe2>
      } else if(c0 == 'u'){
 5c0:	0db78b63          	beq	a5,s11,696 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c4:	07800713          	li	a4,120
 5c8:	10e78d63          	beq	a5,a4,6e2 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5cc:	07000713          	li	a4,112
 5d0:	14e78263          	beq	a5,a4,714 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5d4:	06300713          	li	a4,99
 5d8:	16e78f63          	beq	a5,a4,756 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5dc:	07300713          	li	a4,115
 5e0:	18e78563          	beq	a5,a4,76a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5e4:	05579063          	bne	a5,s5,624 <vprintf+0xfa>
        putc(fd, '%');
 5e8:	85d6                	mv	a1,s5
 5ea:	855a                	mv	a0,s6
 5ec:	e85ff0ef          	jal	ra,470 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	bf49                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4685                	li	a3,1
 5fa:	4629                	li	a2,10
 5fc:	000ba583          	lw	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	e8dff0ef          	jal	ra,48e <printint>
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
 60a:	bfad                	j	584 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 60c:	03868663          	beq	a3,s8,638 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 610:	05a68163          	beq	a3,s10,652 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 614:	09b68d63          	beq	a3,s11,6ae <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 618:	03a68f63          	beq	a3,s10,656 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 61c:	07800793          	li	a5,120
 620:	0cf68d63          	beq	a3,a5,6fa <vprintf+0x1d0>
        putc(fd, '%');
 624:	85d6                	mv	a1,s5
 626:	855a                	mv	a0,s6
 628:	e49ff0ef          	jal	ra,470 <putc>
        putc(fd, c0);
 62c:	85ca                	mv	a1,s2
 62e:	855a                	mv	a0,s6
 630:	e41ff0ef          	jal	ra,470 <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	b7b9                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	008b8913          	addi	s2,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e49ff0ef          	jal	ra,48e <printint>
        i += 1;
 64a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 1;
 650:	bf15                	j	584 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 652:	03860563          	beq	a2,s8,67c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 656:	07b60963          	beq	a2,s11,6c8 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 65a:	07800793          	li	a5,120
 65e:	fcf613e3          	bne	a2,a5,624 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4641                	li	a2,16
 66a:	000bb583          	ld	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	e1fff0ef          	jal	ra,48e <printint>
        i += 2;
 674:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
        i += 2;
 67a:	b729                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 67c:	008b8913          	addi	s2,s7,8
 680:	4685                	li	a3,1
 682:	4629                	li	a2,10
 684:	000bb583          	ld	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	e05ff0ef          	jal	ra,48e <printint>
        i += 2;
 68e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
        i += 2;
 694:	bdc5                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 696:	008b8913          	addi	s2,s7,8
 69a:	4681                	li	a3,0
 69c:	4629                	li	a2,10
 69e:	000be583          	lwu	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	debff0ef          	jal	ra,48e <printint>
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	bde1                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000bb583          	ld	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	dd3ff0ef          	jal	ra,48e <printint>
        i += 1;
 6c0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
        i += 1;
 6c6:	bd7d                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4629                	li	a2,10
 6d0:	000bb583          	ld	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	db9ff0ef          	jal	ra,48e <printint>
        i += 2;
 6da:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6dc:	8bca                	mv	s7,s2
      state = 0;
 6de:	4981                	li	s3,0
        i += 2;
 6e0:	b555                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	4681                	li	a3,0
 6e8:	4641                	li	a2,16
 6ea:	000be583          	lwu	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	d9fff0ef          	jal	ra,48e <printint>
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b571                	j	584 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4681                	li	a3,0
 700:	4641                	li	a2,16
 702:	000bb583          	ld	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	d87ff0ef          	jal	ra,48e <printint>
        i += 1;
 70c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
        i += 1;
 712:	bd8d                	j	584 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 714:	008b8793          	addi	a5,s7,8
 718:	f8f43423          	sd	a5,-120(s0)
 71c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 720:	03000593          	li	a1,48
 724:	855a                	mv	a0,s6
 726:	d4bff0ef          	jal	ra,470 <putc>
  putc(fd, 'x');
 72a:	07800593          	li	a1,120
 72e:	855a                	mv	a0,s6
 730:	d41ff0ef          	jal	ra,470 <putc>
 734:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 736:	03c9d793          	srli	a5,s3,0x3c
 73a:	97e6                	add	a5,a5,s9
 73c:	0007c583          	lbu	a1,0(a5)
 740:	855a                	mv	a0,s6
 742:	d2fff0ef          	jal	ra,470 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 746:	0992                	slli	s3,s3,0x4
 748:	397d                	addiw	s2,s2,-1
 74a:	fe0916e3          	bnez	s2,736 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 74e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 752:	4981                	li	s3,0
 754:	bd05                	j	584 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 756:	008b8913          	addi	s2,s7,8
 75a:	000bc583          	lbu	a1,0(s7)
 75e:	855a                	mv	a0,s6
 760:	d11ff0ef          	jal	ra,470 <putc>
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
 768:	bd31                	j	584 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 76a:	008b8993          	addi	s3,s7,8
 76e:	000bb903          	ld	s2,0(s7)
 772:	00090f63          	beqz	s2,790 <vprintf+0x266>
        for(; *s; s++)
 776:	00094583          	lbu	a1,0(s2)
 77a:	c195                	beqz	a1,79e <vprintf+0x274>
          putc(fd, *s);
 77c:	855a                	mv	a0,s6
 77e:	cf3ff0ef          	jal	ra,470 <putc>
        for(; *s; s++)
 782:	0905                	addi	s2,s2,1
 784:	00094583          	lbu	a1,0(s2)
 788:	f9f5                	bnez	a1,77c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 78a:	8bce                	mv	s7,s3
      state = 0;
 78c:	4981                	li	s3,0
 78e:	bbdd                	j	584 <vprintf+0x5a>
          s = "(null)";
 790:	00000917          	auipc	s2,0x0
 794:	27890913          	addi	s2,s2,632 # a08 <malloc+0x162>
        for(; *s; s++)
 798:	02800593          	li	a1,40
 79c:	b7c5                	j	77c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 79e:	8bce                	mv	s7,s3
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	b3cd                	j	584 <vprintf+0x5a>
    }
  }
}
 7a4:	70e6                	ld	ra,120(sp)
 7a6:	7446                	ld	s0,112(sp)
 7a8:	74a6                	ld	s1,104(sp)
 7aa:	7906                	ld	s2,96(sp)
 7ac:	69e6                	ld	s3,88(sp)
 7ae:	6a46                	ld	s4,80(sp)
 7b0:	6aa6                	ld	s5,72(sp)
 7b2:	6b06                	ld	s6,64(sp)
 7b4:	7be2                	ld	s7,56(sp)
 7b6:	7c42                	ld	s8,48(sp)
 7b8:	7ca2                	ld	s9,40(sp)
 7ba:	7d02                	ld	s10,32(sp)
 7bc:	6de2                	ld	s11,24(sp)
 7be:	6109                	addi	sp,sp,128
 7c0:	8082                	ret

00000000000007c2 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 7c2:	715d                	addi	sp,sp,-80
 7c4:	ec06                	sd	ra,24(sp)
 7c6:	e822                	sd	s0,16(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	e010                	sd	a2,0(s0)
 7cc:	e414                	sd	a3,8(s0)
 7ce:	e818                	sd	a4,16(s0)
 7d0:	ec1c                	sd	a5,24(s0)
 7d2:	03043023          	sd	a6,32(s0)
 7d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7de:	8622                	mv	a2,s0
 7e0:	d4bff0ef          	jal	ra,52a <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6161                	addi	sp,sp,80
 7ea:	8082                	ret

00000000000007ec <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7ec:	711d                	addi	sp,sp,-96
 7ee:	ec06                	sd	ra,24(sp)
 7f0:	e822                	sd	s0,16(sp)
 7f2:	1000                	addi	s0,sp,32
 7f4:	e40c                	sd	a1,8(s0)
 7f6:	e810                	sd	a2,16(s0)
 7f8:	ec14                	sd	a3,24(s0)
 7fa:	f018                	sd	a4,32(s0)
 7fc:	f41c                	sd	a5,40(s0)
 7fe:	03043823          	sd	a6,48(s0)
 802:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 806:	00840613          	addi	a2,s0,8
 80a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80e:	85aa                	mv	a1,a0
 810:	4505                	li	a0,1
 812:	d19ff0ef          	jal	ra,52a <vprintf>
}
 816:	60e2                	ld	ra,24(sp)
 818:	6442                	ld	s0,16(sp)
 81a:	6125                	addi	sp,sp,96
 81c:	8082                	ret

000000000000081e <free>:
 *   无
 */

void
free(void *ap)
{
 81e:	1141                	addi	sp,sp,-16
 820:	e422                	sd	s0,8(sp)
 822:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 824:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	00000797          	auipc	a5,0x0
 82c:	7d87b783          	ld	a5,2008(a5) # 1000 <freep>
 830:	a805                	j	860 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 832:	4618                	lw	a4,8(a2)
 834:	9db9                	addw	a1,a1,a4
 836:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83a:	6398                	ld	a4,0(a5)
 83c:	6318                	ld	a4,0(a4)
 83e:	fee53823          	sd	a4,-16(a0)
 842:	a091                	j	886 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 844:	ff852703          	lw	a4,-8(a0)
 848:	9e39                	addw	a2,a2,a4
 84a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 84c:	ff053703          	ld	a4,-16(a0)
 850:	e398                	sd	a4,0(a5)
 852:	a099                	j	898 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 854:	6398                	ld	a4,0(a5)
 856:	00e7e463          	bltu	a5,a4,85e <free+0x40>
 85a:	00e6ea63          	bltu	a3,a4,86e <free+0x50>
{
 85e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 860:	fed7fae3          	bgeu	a5,a3,854 <free+0x36>
 864:	6398                	ld	a4,0(a5)
 866:	00e6e463          	bltu	a3,a4,86e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86a:	fee7eae3          	bltu	a5,a4,85e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 86e:	ff852583          	lw	a1,-8(a0)
 872:	6390                	ld	a2,0(a5)
 874:	02059713          	slli	a4,a1,0x20
 878:	9301                	srli	a4,a4,0x20
 87a:	0712                	slli	a4,a4,0x4
 87c:	9736                	add	a4,a4,a3
 87e:	fae60ae3          	beq	a2,a4,832 <free+0x14>
    bp->s.ptr = p->s.ptr;
 882:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 886:	4790                	lw	a2,8(a5)
 888:	02061713          	slli	a4,a2,0x20
 88c:	9301                	srli	a4,a4,0x20
 88e:	0712                	slli	a4,a4,0x4
 890:	973e                	add	a4,a4,a5
 892:	fae689e3          	beq	a3,a4,844 <free+0x26>
  } else
    p->s.ptr = bp;
 896:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 898:	00000717          	auipc	a4,0x0
 89c:	76f73423          	sd	a5,1896(a4) # 1000 <freep>
}
 8a0:	6422                	ld	s0,8(sp)
 8a2:	0141                	addi	sp,sp,16
 8a4:	8082                	ret

00000000000008a6 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 8a6:	7139                	addi	sp,sp,-64
 8a8:	fc06                	sd	ra,56(sp)
 8aa:	f822                	sd	s0,48(sp)
 8ac:	f426                	sd	s1,40(sp)
 8ae:	f04a                	sd	s2,32(sp)
 8b0:	ec4e                	sd	s3,24(sp)
 8b2:	e852                	sd	s4,16(sp)
 8b4:	e456                	sd	s5,8(sp)
 8b6:	e05a                	sd	s6,0(sp)
 8b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ba:	02051493          	slli	s1,a0,0x20
 8be:	9081                	srli	s1,s1,0x20
 8c0:	04bd                	addi	s1,s1,15
 8c2:	8091                	srli	s1,s1,0x4
 8c4:	0014899b          	addiw	s3,s1,1
 8c8:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 8ca:	00000517          	auipc	a0,0x0
 8ce:	73653503          	ld	a0,1846(a0) # 1000 <freep>
 8d2:	c515                	beqz	a0,8fe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8d6:	4798                	lw	a4,8(a5)
 8d8:	02977f63          	bgeu	a4,s1,916 <malloc+0x70>
 8dc:	8a4e                	mv	s4,s3
 8de:	0009871b          	sext.w	a4,s3
 8e2:	6685                	lui	a3,0x1
 8e4:	00d77363          	bgeu	a4,a3,8ea <malloc+0x44>
 8e8:	6a05                	lui	s4,0x1
 8ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8ee:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8f2:	00000917          	auipc	s2,0x0
 8f6:	70e90913          	addi	s2,s2,1806 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8fa:	5afd                	li	s5,-1
 8fc:	a0bd                	j	96a <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8fe:	00000797          	auipc	a5,0x0
 902:	71278793          	addi	a5,a5,1810 # 1010 <base>
 906:	00000717          	auipc	a4,0x0
 90a:	6ef73d23          	sd	a5,1786(a4) # 1000 <freep>
 90e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 910:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 914:	b7e1                	j	8dc <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 916:	02e48b63          	beq	s1,a4,94c <malloc+0xa6>
        p->s.size -= nunits;
 91a:	4137073b          	subw	a4,a4,s3
 91e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 920:	1702                	slli	a4,a4,0x20
 922:	9301                	srli	a4,a4,0x20
 924:	0712                	slli	a4,a4,0x4
 926:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 928:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 92c:	00000717          	auipc	a4,0x0
 930:	6ca73a23          	sd	a0,1748(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 934:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 938:	70e2                	ld	ra,56(sp)
 93a:	7442                	ld	s0,48(sp)
 93c:	74a2                	ld	s1,40(sp)
 93e:	7902                	ld	s2,32(sp)
 940:	69e2                	ld	s3,24(sp)
 942:	6a42                	ld	s4,16(sp)
 944:	6aa2                	ld	s5,8(sp)
 946:	6b02                	ld	s6,0(sp)
 948:	6121                	addi	sp,sp,64
 94a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 94c:	6398                	ld	a4,0(a5)
 94e:	e118                	sd	a4,0(a0)
 950:	bff1                	j	92c <malloc+0x86>
  hp->s.size = nu;
 952:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 956:	0541                	addi	a0,a0,16
 958:	ec7ff0ef          	jal	ra,81e <free>
  return freep;
 95c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 960:	dd61                	beqz	a0,938 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 962:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 964:	4798                	lw	a4,8(a5)
 966:	fa9778e3          	bgeu	a4,s1,916 <malloc+0x70>
    if(p == freep)
 96a:	00093703          	ld	a4,0(s2)
 96e:	853e                	mv	a0,a5
 970:	fef719e3          	bne	a4,a5,962 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 974:	8552                	mv	a0,s4
 976:	9e7ff0ef          	jal	ra,35c <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 97a:	fd551ce3          	bne	a0,s5,952 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 97e:	4501                	li	a0,0
 980:	bf65                	j	938 <malloc+0x92>
