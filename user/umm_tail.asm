
user/_umm_tail:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
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
  int len = 3*4096;
  char *p = mmap(0, len, PROT_READ|PROT_WRITE, MAP_ANON, 1);
   c:	4705                	li	a4,1
   e:	4685                	li	a3,1
  10:	460d                	li	a2,3
  12:	658d                	lui	a1,0x3
  14:	4501                	li	a0,0
  16:	3e8000ef          	jal	ra,3fe <mmap>
  if(p == (char*)-1){
  1a:	57fd                	li	a5,-1
  1c:	08f50463          	beq	a0,a5,a4 <main+0xa4>
  20:	84aa                	mv	s1,a0
    printf("mmap failed\n");
    exit(1);
  }

  p[0] = 'A';
  22:	04100793          	li	a5,65
  26:	00f50023          	sb	a5,0(a0)
  p[4096] = 'B';
  2a:	6785                	lui	a5,0x1
  2c:	97aa                	add	a5,a5,a0
  2e:	04200713          	li	a4,66
  32:	00e78023          	sb	a4,0(a5) # 1000 <freep>
  p[8192] = 'C';
  36:	6909                	lui	s2,0x2
  38:	992a                	add	s2,s2,a0
  3a:	04300793          	li	a5,67
  3e:	00f90023          	sb	a5,0(s2) # 2000 <base+0xff0>
  printf("before: %c %c %c\n", p[0], p[4096], p[8192]);
  42:	04300693          	li	a3,67
  46:	04200613          	li	a2,66
  4a:	04100593          	li	a1,65
  4e:	00001517          	auipc	a0,0x1
  52:	91250513          	addi	a0,a0,-1774 # 960 <malloc+0xec>
  56:	764000ef          	jal	ra,7ba <printf>

  // unmap 最后一页
  if(munmap(p + 8192, 4096) < 0){
  5a:	6585                	lui	a1,0x1
  5c:	854a                	mv	a0,s2
  5e:	3a8000ef          	jal	ra,406 <munmap>
  62:	04054a63          	bltz	a0,b6 <main+0xb6>
    printf("munmap failed\n");
    exit(1);
  }

  printf("after: %c %c\n", p[0], p[4096]);
  66:	6785                	lui	a5,0x1
  68:	97a6                	add	a5,a5,s1
  6a:	0007c603          	lbu	a2,0(a5) # 1000 <freep>
  6e:	0004c583          	lbu	a1,0(s1)
  72:	00001517          	auipc	a0,0x1
  76:	91650513          	addi	a0,a0,-1770 # 988 <malloc+0x114>
  7a:	740000ef          	jal	ra,7ba <printf>
  printf("touch unmapped (should die): %c\n", p[8192]);
  7e:	6509                	lui	a0,0x2
  80:	94aa                	add	s1,s1,a0
  82:	0004c583          	lbu	a1,0(s1)
  86:	00001517          	auipc	a0,0x1
  8a:	91250513          	addi	a0,a0,-1774 # 998 <malloc+0x124>
  8e:	72c000ef          	jal	ra,7ba <printf>

  printf("FAIL: still alive\n");
  92:	00001517          	auipc	a0,0x1
  96:	92e50513          	addi	a0,a0,-1746 # 9c0 <malloc+0x14c>
  9a:	720000ef          	jal	ra,7ba <printf>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	2be000ef          	jal	ra,35e <exit>
    printf("mmap failed\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	8ac50513          	addi	a0,a0,-1876 # 950 <malloc+0xdc>
  ac:	70e000ef          	jal	ra,7ba <printf>
    exit(1);
  b0:	4505                	li	a0,1
  b2:	2ac000ef          	jal	ra,35e <exit>
    printf("munmap failed\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	8c250513          	addi	a0,a0,-1854 # 978 <malloc+0x104>
  be:	6fc000ef          	jal	ra,7ba <printf>
    exit(1);
  c2:	4505                	li	a0,1
  c4:	29a000ef          	jal	ra,35e <exit>

00000000000000c8 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e406                	sd	ra,8(sp)
  cc:	e022                	sd	s0,0(sp)
  ce:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  d0:	f31ff0ef          	jal	ra,0 <main>
  exit(r);
  d4:	28a000ef          	jal	ra,35e <exit>

00000000000000d8 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  de:	87aa                	mv	a5,a0
  e0:	0585                	addi	a1,a1,1
  e2:	0785                	addi	a5,a5,1
  e4:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x61f>
  e8:	fee78fa3          	sb	a4,-1(a5)
  ec:	fb75                	bnez	a4,e0 <strcpy+0x8>
    ;
  return os;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb91                	beqz	a5,112 <strcmp+0x1e>
 100:	0005c703          	lbu	a4,0(a1)
 104:	00f71763          	bne	a4,a5,112 <strcmp+0x1e>
    p++, q++;
 108:	0505                	addi	a0,a0,1
 10a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 10c:	00054783          	lbu	a5,0(a0)
 110:	fbe5                	bnez	a5,100 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 112:	0005c503          	lbu	a0,0(a1)
}
 116:	40a7853b          	subw	a0,a5,a0
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cf91                	beqz	a5,146 <strlen+0x26>
 12c:	0505                	addi	a0,a0,1
 12e:	87aa                	mv	a5,a0
 130:	4685                	li	a3,1
 132:	9e89                	subw	a3,a3,a0
 134:	00f6853b          	addw	a0,a3,a5
 138:	0785                	addi	a5,a5,1
 13a:	fff7c703          	lbu	a4,-1(a5)
 13e:	fb7d                	bnez	a4,134 <strlen+0x14>
    ;
  return n;
}
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret
  for(n = 0; s[n]; n++)
 146:	4501                	li	a0,0
 148:	bfe5                	j	140 <strlen+0x20>

000000000000014a <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 150:	ca19                	beqz	a2,166 <memset+0x1c>
 152:	87aa                	mv	a5,a0
 154:	1602                	slli	a2,a2,0x20
 156:	9201                	srli	a2,a2,0x20
 158:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 160:	0785                	addi	a5,a5,1
 162:	fee79de3          	bne	a5,a4,15c <memset+0x12>
  }
  return dst;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  for(; *s; s++)
 172:	00054783          	lbu	a5,0(a0)
 176:	cb99                	beqz	a5,18c <strchr+0x20>
    if(*s == c)
 178:	00f58763          	beq	a1,a5,186 <strchr+0x1a>
  for(; *s; s++)
 17c:	0505                	addi	a0,a0,1
 17e:	00054783          	lbu	a5,0(a0)
 182:	fbfd                	bnez	a5,178 <strchr+0xc>
      return (char*)s;
  return 0;
 184:	4501                	li	a0,0
}
 186:	6422                	ld	s0,8(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret
  return 0;
 18c:	4501                	li	a0,0
 18e:	bfe5                	j	186 <strchr+0x1a>

0000000000000190 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 190:	711d                	addi	sp,sp,-96
 192:	ec86                	sd	ra,88(sp)
 194:	e8a2                	sd	s0,80(sp)
 196:	e4a6                	sd	s1,72(sp)
 198:	e0ca                	sd	s2,64(sp)
 19a:	fc4e                	sd	s3,56(sp)
 19c:	f852                	sd	s4,48(sp)
 19e:	f456                	sd	s5,40(sp)
 1a0:	f05a                	sd	s6,32(sp)
 1a2:	ec5e                	sd	s7,24(sp)
 1a4:	1080                	addi	s0,sp,96
 1a6:	8baa                	mv	s7,a0
 1a8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1aa:	892a                	mv	s2,a0
 1ac:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ae:	4aa9                	li	s5,10
 1b0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b2:	89a6                	mv	s3,s1
 1b4:	2485                	addiw	s1,s1,1
 1b6:	0344d663          	bge	s1,s4,1e2 <gets+0x52>
    cc = read(0, &c, 1);
 1ba:	4605                	li	a2,1
 1bc:	faf40593          	addi	a1,s0,-81
 1c0:	4501                	li	a0,0
 1c2:	1b4000ef          	jal	ra,376 <read>
    if(cc < 1)
 1c6:	00a05e63          	blez	a0,1e2 <gets+0x52>
    buf[i++] = c;
 1ca:	faf44783          	lbu	a5,-81(s0)
 1ce:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d2:	01578763          	beq	a5,s5,1e0 <gets+0x50>
 1d6:	0905                	addi	s2,s2,1
 1d8:	fd679de3          	bne	a5,s6,1b2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1dc:	89a6                	mv	s3,s1
 1de:	a011                	j	1e2 <gets+0x52>
 1e0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e2:	99de                	add	s3,s3,s7
 1e4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e8:	855e                	mv	a0,s7
 1ea:	60e6                	ld	ra,88(sp)
 1ec:	6446                	ld	s0,80(sp)
 1ee:	64a6                	ld	s1,72(sp)
 1f0:	6906                	ld	s2,64(sp)
 1f2:	79e2                	ld	s3,56(sp)
 1f4:	7a42                	ld	s4,48(sp)
 1f6:	7aa2                	ld	s5,40(sp)
 1f8:	7b02                	ld	s6,32(sp)
 1fa:	6be2                	ld	s7,24(sp)
 1fc:	6125                	addi	sp,sp,96
 1fe:	8082                	ret

0000000000000200 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 200:	1101                	addi	sp,sp,-32
 202:	ec06                	sd	ra,24(sp)
 204:	e822                	sd	s0,16(sp)
 206:	e426                	sd	s1,8(sp)
 208:	e04a                	sd	s2,0(sp)
 20a:	1000                	addi	s0,sp,32
 20c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20e:	4581                	li	a1,0
 210:	18e000ef          	jal	ra,39e <open>
  if(fd < 0)
 214:	02054163          	bltz	a0,236 <stat+0x36>
 218:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21a:	85ca                	mv	a1,s2
 21c:	19a000ef          	jal	ra,3b6 <fstat>
 220:	892a                	mv	s2,a0
  close(fd);
 222:	8526                	mv	a0,s1
 224:	162000ef          	jal	ra,386 <close>
  return r;
}
 228:	854a                	mv	a0,s2
 22a:	60e2                	ld	ra,24(sp)
 22c:	6442                	ld	s0,16(sp)
 22e:	64a2                	ld	s1,8(sp)
 230:	6902                	ld	s2,0(sp)
 232:	6105                	addi	sp,sp,32
 234:	8082                	ret
    return -1;
 236:	597d                	li	s2,-1
 238:	bfc5                	j	228 <stat+0x28>

000000000000023a <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 240:	00054603          	lbu	a2,0(a0)
 244:	fd06079b          	addiw	a5,a2,-48
 248:	0ff7f793          	andi	a5,a5,255
 24c:	4725                	li	a4,9
 24e:	02f76963          	bltu	a4,a5,280 <atoi+0x46>
 252:	86aa                	mv	a3,a0
  n = 0;
 254:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 256:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 258:	0685                	addi	a3,a3,1
 25a:	0025179b          	slliw	a5,a0,0x2
 25e:	9fa9                	addw	a5,a5,a0
 260:	0017979b          	slliw	a5,a5,0x1
 264:	9fb1                	addw	a5,a5,a2
 266:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 26a:	0006c603          	lbu	a2,0(a3)
 26e:	fd06071b          	addiw	a4,a2,-48
 272:	0ff77713          	andi	a4,a4,255
 276:	fee5f1e3          	bgeu	a1,a4,258 <atoi+0x1e>
  return n;
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  n = 0;
 280:	4501                	li	a0,0
 282:	bfe5                	j	27a <atoi+0x40>

0000000000000284 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 28a:	02b57463          	bgeu	a0,a1,2b2 <memmove+0x2e>
    while(n-- > 0)
 28e:	00c05f63          	blez	a2,2ac <memmove+0x28>
 292:	1602                	slli	a2,a2,0x20
 294:	9201                	srli	a2,a2,0x20
 296:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 29a:	872a                	mv	a4,a0
      *dst++ = *src++;
 29c:	0585                	addi	a1,a1,1
 29e:	0705                	addi	a4,a4,1
 2a0:	fff5c683          	lbu	a3,-1(a1)
 2a4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a8:	fee79ae3          	bne	a5,a4,29c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
    dst += n;
 2b2:	00c50733          	add	a4,a0,a2
    src += n;
 2b6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b8:	fec05ae3          	blez	a2,2ac <memmove+0x28>
 2bc:	fff6079b          	addiw	a5,a2,-1
 2c0:	1782                	slli	a5,a5,0x20
 2c2:	9381                	srli	a5,a5,0x20
 2c4:	fff7c793          	not	a5,a5
 2c8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ca:	15fd                	addi	a1,a1,-1
 2cc:	177d                	addi	a4,a4,-1
 2ce:	0005c683          	lbu	a3,0(a1)
 2d2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d6:	fee79ae3          	bne	a5,a4,2ca <memmove+0x46>
 2da:	bfc9                	j	2ac <memmove+0x28>

00000000000002dc <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e422                	sd	s0,8(sp)
 2e0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e2:	ca05                	beqz	a2,312 <memcmp+0x36>
 2e4:	fff6069b          	addiw	a3,a2,-1
 2e8:	1682                	slli	a3,a3,0x20
 2ea:	9281                	srli	a3,a3,0x20
 2ec:	0685                	addi	a3,a3,1
 2ee:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	0005c703          	lbu	a4,0(a1)
 2f8:	00e79863          	bne	a5,a4,308 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fc:	0505                	addi	a0,a0,1
    p2++;
 2fe:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 300:	fed518e3          	bne	a0,a3,2f0 <memcmp+0x14>
  }
  return 0;
 304:	4501                	li	a0,0
 306:	a019                	j	30c <memcmp+0x30>
      return *p1 - *p2;
 308:	40e7853b          	subw	a0,a5,a4
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  return 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <memcmp+0x30>

0000000000000316 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31e:	f67ff0ef          	jal	ra,284 <memmove>
}
 322:	60a2                	ld	ra,8(sp)
 324:	6402                	ld	s0,0(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret

000000000000032a <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 332:	4585                	li	a1,1
 334:	0b2000ef          	jal	ra,3e6 <sys_sbrk>
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 340:	1141                	addi	sp,sp,-16
 342:	e406                	sd	ra,8(sp)
 344:	e022                	sd	s0,0(sp)
 346:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 348:	4589                	li	a1,2
 34a:	09c000ef          	jal	ra,3e6 <sys_sbrk>
}
 34e:	60a2                	ld	ra,8(sp)
 350:	6402                	ld	s0,0(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 356:	4885                	li	a7,1
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <exit>:
.global exit
exit:
 li a7, SYS_exit
 35e:	4889                	li	a7,2
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <wait>:
.global wait
wait:
 li a7, SYS_wait
 366:	488d                	li	a7,3
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36e:	4891                	li	a7,4
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <read>:
.global read
read:
 li a7, SYS_read
 376:	4895                	li	a7,5
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <write>:
.global write
write:
 li a7, SYS_write
 37e:	48c1                	li	a7,16
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <close>:
.global close
close:
 li a7, SYS_close
 386:	48d5                	li	a7,21
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <kill>:
.global kill
kill:
 li a7, SYS_kill
 38e:	4899                	li	a7,6
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <exec>:
.global exec
exec:
 li a7, SYS_exec
 396:	489d                	li	a7,7
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <open>:
.global open
open:
 li a7, SYS_open
 39e:	48bd                	li	a7,15
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a6:	48c5                	li	a7,17
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ae:	48c9                	li	a7,18
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b6:	48a1                	li	a7,8
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <link>:
.global link
link:
 li a7, SYS_link
 3be:	48cd                	li	a7,19
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c6:	48d1                	li	a7,20
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ce:	48a5                	li	a7,9
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d6:	48a9                	li	a7,10
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3de:	48ad                	li	a7,11
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e6:	48b1                	li	a7,12
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ee:	48b5                	li	a7,13
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f6:	48b9                	li	a7,14
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3fe:	48d9                	li	a7,22
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 406:	48dd                	li	a7,23
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 40e:	48e1                	li	a7,24
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 416:	48e5                	li	a7,25
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 41e:	48e9                	li	a7,26
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 426:	48ed                	li	a7,27
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 42e:	48f1                	li	a7,28
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 436:	48f5                	li	a7,29
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 43e:	1101                	addi	sp,sp,-32
 440:	ec06                	sd	ra,24(sp)
 442:	e822                	sd	s0,16(sp)
 444:	1000                	addi	s0,sp,32
 446:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44a:	4605                	li	a2,1
 44c:	fef40593          	addi	a1,s0,-17
 450:	f2fff0ef          	jal	ra,37e <write>
}
 454:	60e2                	ld	ra,24(sp)
 456:	6442                	ld	s0,16(sp)
 458:	6105                	addi	sp,sp,32
 45a:	8082                	ret

000000000000045c <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 45c:	715d                	addi	sp,sp,-80
 45e:	e486                	sd	ra,72(sp)
 460:	e0a2                	sd	s0,64(sp)
 462:	fc26                	sd	s1,56(sp)
 464:	f84a                	sd	s2,48(sp)
 466:	f44e                	sd	s3,40(sp)
 468:	0880                	addi	s0,sp,80
 46a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 46c:	c299                	beqz	a3,472 <printint+0x16>
 46e:	0805c163          	bltz	a1,4f0 <printint+0x94>
  neg = 0;
 472:	4881                	li	a7,0
 474:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 478:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 47a:	00000517          	auipc	a0,0x0
 47e:	56650513          	addi	a0,a0,1382 # 9e0 <digits>
 482:	883e                	mv	a6,a5
 484:	2785                	addiw	a5,a5,1
 486:	02c5f733          	remu	a4,a1,a2
 48a:	972a                	add	a4,a4,a0
 48c:	00074703          	lbu	a4,0(a4)
 490:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 494:	872e                	mv	a4,a1
 496:	02c5d5b3          	divu	a1,a1,a2
 49a:	0685                	addi	a3,a3,1
 49c:	fec773e3          	bgeu	a4,a2,482 <printint+0x26>
  if(neg)
 4a0:	00088b63          	beqz	a7,4b6 <printint+0x5a>
    buf[i++] = '-';
 4a4:	fd040713          	addi	a4,s0,-48
 4a8:	97ba                	add	a5,a5,a4
 4aa:	02d00713          	li	a4,45
 4ae:	fee78423          	sb	a4,-24(a5)
 4b2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b6:	02f05663          	blez	a5,4e2 <printint+0x86>
 4ba:	fb840713          	addi	a4,s0,-72
 4be:	00f704b3          	add	s1,a4,a5
 4c2:	fff70993          	addi	s3,a4,-1
 4c6:	99be                	add	s3,s3,a5
 4c8:	37fd                	addiw	a5,a5,-1
 4ca:	1782                	slli	a5,a5,0x20
 4cc:	9381                	srli	a5,a5,0x20
 4ce:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4d2:	fff4c583          	lbu	a1,-1(s1)
 4d6:	854a                	mv	a0,s2
 4d8:	f67ff0ef          	jal	ra,43e <putc>
  while(--i >= 0)
 4dc:	14fd                	addi	s1,s1,-1
 4de:	ff349ae3          	bne	s1,s3,4d2 <printint+0x76>
}
 4e2:	60a6                	ld	ra,72(sp)
 4e4:	6406                	ld	s0,64(sp)
 4e6:	74e2                	ld	s1,56(sp)
 4e8:	7942                	ld	s2,48(sp)
 4ea:	79a2                	ld	s3,40(sp)
 4ec:	6161                	addi	sp,sp,80
 4ee:	8082                	ret
    x = -xx;
 4f0:	40b005b3          	neg	a1,a1
    neg = 1;
 4f4:	4885                	li	a7,1
    x = -xx;
 4f6:	bfbd                	j	474 <printint+0x18>

00000000000004f8 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f8:	7119                	addi	sp,sp,-128
 4fa:	fc86                	sd	ra,120(sp)
 4fc:	f8a2                	sd	s0,112(sp)
 4fe:	f4a6                	sd	s1,104(sp)
 500:	f0ca                	sd	s2,96(sp)
 502:	ecce                	sd	s3,88(sp)
 504:	e8d2                	sd	s4,80(sp)
 506:	e4d6                	sd	s5,72(sp)
 508:	e0da                	sd	s6,64(sp)
 50a:	fc5e                	sd	s7,56(sp)
 50c:	f862                	sd	s8,48(sp)
 50e:	f466                	sd	s9,40(sp)
 510:	f06a                	sd	s10,32(sp)
 512:	ec6e                	sd	s11,24(sp)
 514:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 516:	0005c903          	lbu	s2,0(a1)
 51a:	24090c63          	beqz	s2,772 <vprintf+0x27a>
 51e:	8b2a                	mv	s6,a0
 520:	8a2e                	mv	s4,a1
 522:	8bb2                	mv	s7,a2
  state = 0;
 524:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 526:	4481                	li	s1,0
 528:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 52a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 52e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 532:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 536:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 53a:	00000c97          	auipc	s9,0x0
 53e:	4a6c8c93          	addi	s9,s9,1190 # 9e0 <digits>
 542:	a005                	j	562 <vprintf+0x6a>
        putc(fd, c0);
 544:	85ca                	mv	a1,s2
 546:	855a                	mv	a0,s6
 548:	ef7ff0ef          	jal	ra,43e <putc>
 54c:	a019                	j	552 <vprintf+0x5a>
    } else if(state == '%'){
 54e:	03598263          	beq	s3,s5,572 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 552:	2485                	addiw	s1,s1,1
 554:	8726                	mv	a4,s1
 556:	009a07b3          	add	a5,s4,s1
 55a:	0007c903          	lbu	s2,0(a5)
 55e:	20090a63          	beqz	s2,772 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 562:	0009079b          	sext.w	a5,s2
    if(state == 0){
 566:	fe0994e3          	bnez	s3,54e <vprintf+0x56>
      if(c0 == '%'){
 56a:	fd579de3          	bne	a5,s5,544 <vprintf+0x4c>
        state = '%';
 56e:	89be                	mv	s3,a5
 570:	b7cd                	j	552 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 572:	c3c1                	beqz	a5,5f2 <vprintf+0xfa>
 574:	00ea06b3          	add	a3,s4,a4
 578:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 57c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 57e:	c681                	beqz	a3,586 <vprintf+0x8e>
 580:	9752                	add	a4,a4,s4
 582:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 586:	03878e63          	beq	a5,s8,5c2 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 58a:	05a78863          	beq	a5,s10,5da <vprintf+0xe2>
      } else if(c0 == 'u'){
 58e:	0db78b63          	beq	a5,s11,664 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 592:	07800713          	li	a4,120
 596:	10e78d63          	beq	a5,a4,6b0 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 59a:	07000713          	li	a4,112
 59e:	14e78263          	beq	a5,a4,6e2 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5a2:	06300713          	li	a4,99
 5a6:	16e78f63          	beq	a5,a4,724 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5aa:	07300713          	li	a4,115
 5ae:	18e78563          	beq	a5,a4,738 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5b2:	05579063          	bne	a5,s5,5f2 <vprintf+0xfa>
        putc(fd, '%');
 5b6:	85d6                	mv	a1,s5
 5b8:	855a                	mv	a0,s6
 5ba:	e85ff0ef          	jal	ra,43e <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bf49                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000ba583          	lw	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	e8dff0ef          	jal	ra,45c <printint>
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	bfad                	j	552 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5da:	03868663          	beq	a3,s8,606 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5de:	05a68163          	beq	a3,s10,620 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5e2:	09b68d63          	beq	a3,s11,67c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e6:	03a68f63          	beq	a3,s10,624 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5ea:	07800793          	li	a5,120
 5ee:	0cf68d63          	beq	a3,a5,6c8 <vprintf+0x1d0>
        putc(fd, '%');
 5f2:	85d6                	mv	a1,s5
 5f4:	855a                	mv	a0,s6
 5f6:	e49ff0ef          	jal	ra,43e <putc>
        putc(fd, c0);
 5fa:	85ca                	mv	a1,s2
 5fc:	855a                	mv	a0,s6
 5fe:	e41ff0ef          	jal	ra,43e <putc>
      state = 0;
 602:	4981                	li	s3,0
 604:	b7b9                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 606:	008b8913          	addi	s2,s7,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000bb583          	ld	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	e49ff0ef          	jal	ra,45c <printint>
        i += 1;
 618:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 61a:	8bca                	mv	s7,s2
      state = 0;
 61c:	4981                	li	s3,0
        i += 1;
 61e:	bf15                	j	552 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 620:	03860563          	beq	a2,s8,64a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 624:	07b60963          	beq	a2,s11,696 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 628:	07800793          	li	a5,120
 62c:	fcf613e3          	bne	a2,a5,5f2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 630:	008b8913          	addi	s2,s7,8
 634:	4681                	li	a3,0
 636:	4641                	li	a2,16
 638:	000bb583          	ld	a1,0(s7)
 63c:	855a                	mv	a0,s6
 63e:	e1fff0ef          	jal	ra,45c <printint>
        i += 2;
 642:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
        i += 2;
 648:	b729                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4685                	li	a3,1
 650:	4629                	li	a2,10
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	e05ff0ef          	jal	ra,45c <printint>
        i += 2;
 65c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 2;
 662:	bdc5                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000be583          	lwu	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	debff0ef          	jal	ra,45c <printint>
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
 67a:	bde1                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67c:	008b8913          	addi	s2,s7,8
 680:	4681                	li	a3,0
 682:	4629                	li	a2,10
 684:	000bb583          	ld	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	dd3ff0ef          	jal	ra,45c <printint>
        i += 1;
 68e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
        i += 1;
 694:	bd7d                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 696:	008b8913          	addi	s2,s7,8
 69a:	4681                	li	a3,0
 69c:	4629                	li	a2,10
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	db9ff0ef          	jal	ra,45c <printint>
        i += 2;
 6a8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 2;
 6ae:	b555                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6b0:	008b8913          	addi	s2,s7,8
 6b4:	4681                	li	a3,0
 6b6:	4641                	li	a2,16
 6b8:	000be583          	lwu	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	d9fff0ef          	jal	ra,45c <printint>
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b571                	j	552 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4641                	li	a2,16
 6d0:	000bb583          	ld	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	d87ff0ef          	jal	ra,45c <printint>
        i += 1;
 6da:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6dc:	8bca                	mv	s7,s2
      state = 0;
 6de:	4981                	li	s3,0
        i += 1;
 6e0:	bd8d                	j	552 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6e2:	008b8793          	addi	a5,s7,8
 6e6:	f8f43423          	sd	a5,-120(s0)
 6ea:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ee:	03000593          	li	a1,48
 6f2:	855a                	mv	a0,s6
 6f4:	d4bff0ef          	jal	ra,43e <putc>
  putc(fd, 'x');
 6f8:	07800593          	li	a1,120
 6fc:	855a                	mv	a0,s6
 6fe:	d41ff0ef          	jal	ra,43e <putc>
 702:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 704:	03c9d793          	srli	a5,s3,0x3c
 708:	97e6                	add	a5,a5,s9
 70a:	0007c583          	lbu	a1,0(a5)
 70e:	855a                	mv	a0,s6
 710:	d2fff0ef          	jal	ra,43e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 714:	0992                	slli	s3,s3,0x4
 716:	397d                	addiw	s2,s2,-1
 718:	fe0916e3          	bnez	s2,704 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 71c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 720:	4981                	li	s3,0
 722:	bd05                	j	552 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 724:	008b8913          	addi	s2,s7,8
 728:	000bc583          	lbu	a1,0(s7)
 72c:	855a                	mv	a0,s6
 72e:	d11ff0ef          	jal	ra,43e <putc>
 732:	8bca                	mv	s7,s2
      state = 0;
 734:	4981                	li	s3,0
 736:	bd31                	j	552 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 738:	008b8993          	addi	s3,s7,8
 73c:	000bb903          	ld	s2,0(s7)
 740:	00090f63          	beqz	s2,75e <vprintf+0x266>
        for(; *s; s++)
 744:	00094583          	lbu	a1,0(s2)
 748:	c195                	beqz	a1,76c <vprintf+0x274>
          putc(fd, *s);
 74a:	855a                	mv	a0,s6
 74c:	cf3ff0ef          	jal	ra,43e <putc>
        for(; *s; s++)
 750:	0905                	addi	s2,s2,1
 752:	00094583          	lbu	a1,0(s2)
 756:	f9f5                	bnez	a1,74a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 758:	8bce                	mv	s7,s3
      state = 0;
 75a:	4981                	li	s3,0
 75c:	bbdd                	j	552 <vprintf+0x5a>
          s = "(null)";
 75e:	00000917          	auipc	s2,0x0
 762:	27a90913          	addi	s2,s2,634 # 9d8 <malloc+0x164>
        for(; *s; s++)
 766:	02800593          	li	a1,40
 76a:	b7c5                	j	74a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 76c:	8bce                	mv	s7,s3
      state = 0;
 76e:	4981                	li	s3,0
 770:	b3cd                	j	552 <vprintf+0x5a>
    }
  }
}
 772:	70e6                	ld	ra,120(sp)
 774:	7446                	ld	s0,112(sp)
 776:	74a6                	ld	s1,104(sp)
 778:	7906                	ld	s2,96(sp)
 77a:	69e6                	ld	s3,88(sp)
 77c:	6a46                	ld	s4,80(sp)
 77e:	6aa6                	ld	s5,72(sp)
 780:	6b06                	ld	s6,64(sp)
 782:	7be2                	ld	s7,56(sp)
 784:	7c42                	ld	s8,48(sp)
 786:	7ca2                	ld	s9,40(sp)
 788:	7d02                	ld	s10,32(sp)
 78a:	6de2                	ld	s11,24(sp)
 78c:	6109                	addi	sp,sp,128
 78e:	8082                	ret

0000000000000790 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 790:	715d                	addi	sp,sp,-80
 792:	ec06                	sd	ra,24(sp)
 794:	e822                	sd	s0,16(sp)
 796:	1000                	addi	s0,sp,32
 798:	e010                	sd	a2,0(s0)
 79a:	e414                	sd	a3,8(s0)
 79c:	e818                	sd	a4,16(s0)
 79e:	ec1c                	sd	a5,24(s0)
 7a0:	03043023          	sd	a6,32(s0)
 7a4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ac:	8622                	mv	a2,s0
 7ae:	d4bff0ef          	jal	ra,4f8 <vprintf>
}
 7b2:	60e2                	ld	ra,24(sp)
 7b4:	6442                	ld	s0,16(sp)
 7b6:	6161                	addi	sp,sp,80
 7b8:	8082                	ret

00000000000007ba <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7ba:	711d                	addi	sp,sp,-96
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	e40c                	sd	a1,8(s0)
 7c4:	e810                	sd	a2,16(s0)
 7c6:	ec14                	sd	a3,24(s0)
 7c8:	f018                	sd	a4,32(s0)
 7ca:	f41c                	sd	a5,40(s0)
 7cc:	03043823          	sd	a6,48(s0)
 7d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d4:	00840613          	addi	a2,s0,8
 7d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7dc:	85aa                	mv	a1,a0
 7de:	4505                	li	a0,1
 7e0:	d19ff0ef          	jal	ra,4f8 <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6125                	addi	sp,sp,96
 7ea:	8082                	ret

00000000000007ec <free>:
 *   无
 */

void
free(void *ap)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7f2:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f6:	00001797          	auipc	a5,0x1
 7fa:	80a7b783          	ld	a5,-2038(a5) # 1000 <freep>
 7fe:	a805                	j	82e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 800:	4618                	lw	a4,8(a2)
 802:	9db9                	addw	a1,a1,a4
 804:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	6398                	ld	a4,0(a5)
 80a:	6318                	ld	a4,0(a4)
 80c:	fee53823          	sd	a4,-16(a0)
 810:	a091                	j	854 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 812:	ff852703          	lw	a4,-8(a0)
 816:	9e39                	addw	a2,a2,a4
 818:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 81a:	ff053703          	ld	a4,-16(a0)
 81e:	e398                	sd	a4,0(a5)
 820:	a099                	j	866 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 822:	6398                	ld	a4,0(a5)
 824:	00e7e463          	bltu	a5,a4,82c <free+0x40>
 828:	00e6ea63          	bltu	a3,a4,83c <free+0x50>
{
 82c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82e:	fed7fae3          	bgeu	a5,a3,822 <free+0x36>
 832:	6398                	ld	a4,0(a5)
 834:	00e6e463          	bltu	a3,a4,83c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 838:	fee7eae3          	bltu	a5,a4,82c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 83c:	ff852583          	lw	a1,-8(a0)
 840:	6390                	ld	a2,0(a5)
 842:	02059713          	slli	a4,a1,0x20
 846:	9301                	srli	a4,a4,0x20
 848:	0712                	slli	a4,a4,0x4
 84a:	9736                	add	a4,a4,a3
 84c:	fae60ae3          	beq	a2,a4,800 <free+0x14>
    bp->s.ptr = p->s.ptr;
 850:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 854:	4790                	lw	a2,8(a5)
 856:	02061713          	slli	a4,a2,0x20
 85a:	9301                	srli	a4,a4,0x20
 85c:	0712                	slli	a4,a4,0x4
 85e:	973e                	add	a4,a4,a5
 860:	fae689e3          	beq	a3,a4,812 <free+0x26>
  } else
    p->s.ptr = bp;
 864:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 866:	00000717          	auipc	a4,0x0
 86a:	78f73d23          	sd	a5,1946(a4) # 1000 <freep>
}
 86e:	6422                	ld	s0,8(sp)
 870:	0141                	addi	sp,sp,16
 872:	8082                	ret

0000000000000874 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 874:	7139                	addi	sp,sp,-64
 876:	fc06                	sd	ra,56(sp)
 878:	f822                	sd	s0,48(sp)
 87a:	f426                	sd	s1,40(sp)
 87c:	f04a                	sd	s2,32(sp)
 87e:	ec4e                	sd	s3,24(sp)
 880:	e852                	sd	s4,16(sp)
 882:	e456                	sd	s5,8(sp)
 884:	e05a                	sd	s6,0(sp)
 886:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 888:	02051493          	slli	s1,a0,0x20
 88c:	9081                	srli	s1,s1,0x20
 88e:	04bd                	addi	s1,s1,15
 890:	8091                	srli	s1,s1,0x4
 892:	0014899b          	addiw	s3,s1,1
 896:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 898:	00000517          	auipc	a0,0x0
 89c:	76853503          	ld	a0,1896(a0) # 1000 <freep>
 8a0:	c515                	beqz	a0,8cc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8a4:	4798                	lw	a4,8(a5)
 8a6:	02977f63          	bgeu	a4,s1,8e4 <malloc+0x70>
 8aa:	8a4e                	mv	s4,s3
 8ac:	0009871b          	sext.w	a4,s3
 8b0:	6685                	lui	a3,0x1
 8b2:	00d77363          	bgeu	a4,a3,8b8 <malloc+0x44>
 8b6:	6a05                	lui	s4,0x1
 8b8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8bc:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8c0:	00000917          	auipc	s2,0x0
 8c4:	74090913          	addi	s2,s2,1856 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8c8:	5afd                	li	s5,-1
 8ca:	a0bd                	j	938 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8cc:	00000797          	auipc	a5,0x0
 8d0:	74478793          	addi	a5,a5,1860 # 1010 <base>
 8d4:	00000717          	auipc	a4,0x0
 8d8:	72f73623          	sd	a5,1836(a4) # 1000 <freep>
 8dc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8de:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8e2:	b7e1                	j	8aa <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8e4:	02e48b63          	beq	s1,a4,91a <malloc+0xa6>
        p->s.size -= nunits;
 8e8:	4137073b          	subw	a4,a4,s3
 8ec:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ee:	1702                	slli	a4,a4,0x20
 8f0:	9301                	srli	a4,a4,0x20
 8f2:	0712                	slli	a4,a4,0x4
 8f4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f6:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8fa:	00000717          	auipc	a4,0x0
 8fe:	70a73323          	sd	a0,1798(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 902:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 906:	70e2                	ld	ra,56(sp)
 908:	7442                	ld	s0,48(sp)
 90a:	74a2                	ld	s1,40(sp)
 90c:	7902                	ld	s2,32(sp)
 90e:	69e2                	ld	s3,24(sp)
 910:	6a42                	ld	s4,16(sp)
 912:	6aa2                	ld	s5,8(sp)
 914:	6b02                	ld	s6,0(sp)
 916:	6121                	addi	sp,sp,64
 918:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 91a:	6398                	ld	a4,0(a5)
 91c:	e118                	sd	a4,0(a0)
 91e:	bff1                	j	8fa <malloc+0x86>
  hp->s.size = nu;
 920:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 924:	0541                	addi	a0,a0,16
 926:	ec7ff0ef          	jal	ra,7ec <free>
  return freep;
 92a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92e:	dd61                	beqz	a0,906 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 930:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 932:	4798                	lw	a4,8(a5)
 934:	fa9778e3          	bgeu	a4,s1,8e4 <malloc+0x70>
    if(p == freep)
 938:	00093703          	ld	a4,0(s2)
 93c:	853e                	mv	a0,a5
 93e:	fef719e3          	bne	a4,a5,930 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 942:	8552                	mv	a0,s4
 944:	9e7ff0ef          	jal	ra,32a <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 948:	fd551ce3          	bne	a0,s5,920 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 94c:	4501                	li	a0,0
 94e:	bf65                	j	906 <malloc+0x92>
