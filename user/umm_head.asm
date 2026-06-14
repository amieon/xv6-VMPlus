
user/_umm_head:     file format elf64-littleriscv


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
   8:	1000                	addi	s0,sp,32
  int len = 3*4096;
  char *p = mmap(0, len, PROT_READ|PROT_WRITE, MAP_ANON, 1);
   a:	4705                	li	a4,1
   c:	4685                	li	a3,1
   e:	460d                	li	a2,3
  10:	658d                	lui	a1,0x3
  12:	4501                	li	a0,0
  14:	3e8000ef          	jal	ra,3fc <mmap>
  if(p == (char*)-1){
  18:	57fd                	li	a5,-1
  1a:	08f50463          	beq	a0,a5,a2 <main+0xa2>
  1e:	84aa                	mv	s1,a0
    printf("mmap failed\n");
    exit(1);
  }

  p[0] = 'A';
  20:	04100793          	li	a5,65
  24:	00f50023          	sb	a5,0(a0)
  p[4096] = 'B';
  28:	6785                	lui	a5,0x1
  2a:	97aa                	add	a5,a5,a0
  2c:	04200713          	li	a4,66
  30:	00e78023          	sb	a4,0(a5) # 1000 <freep>
  p[8192] = 'C';
  34:	6789                	lui	a5,0x2
  36:	97aa                	add	a5,a5,a0
  38:	04300713          	li	a4,67
  3c:	00e78023          	sb	a4,0(a5) # 2000 <base+0xff0>
  printf("before: %c %c %c\n", p[0], p[4096], p[8192]);
  40:	04300693          	li	a3,67
  44:	04200613          	li	a2,66
  48:	04100593          	li	a1,65
  4c:	00001517          	auipc	a0,0x1
  50:	91450513          	addi	a0,a0,-1772 # 960 <malloc+0xee>
  54:	764000ef          	jal	ra,7b8 <printf>

  // unmap 第一页
  if(munmap(p, 4096) < 0){
  58:	6585                	lui	a1,0x1
  5a:	8526                	mv	a0,s1
  5c:	3a8000ef          	jal	ra,404 <munmap>
  60:	04054a63          	bltz	a0,b4 <main+0xb4>
    printf("munmap failed\n");
    exit(1);
  }

  // 还应该能访问后两页
  printf("after: %c %c\n", p[4096], p[8192]);
  64:	6709                	lui	a4,0x2
  66:	9726                	add	a4,a4,s1
  68:	6785                	lui	a5,0x1
  6a:	97a6                	add	a5,a5,s1
  6c:	00074603          	lbu	a2,0(a4) # 2000 <base+0xff0>
  70:	0007c583          	lbu	a1,0(a5) # 1000 <freep>
  74:	00001517          	auipc	a0,0x1
  78:	91450513          	addi	a0,a0,-1772 # 988 <malloc+0x116>
  7c:	73c000ef          	jal	ra,7b8 <printf>

  // 这句如果你实现是“访问被 unmap 的页直接 kill”，会导致进程死在这行（正常）
  printf("touch unmapped (should die): %c\n", p[0]);
  80:	0004c583          	lbu	a1,0(s1)
  84:	00001517          	auipc	a0,0x1
  88:	91450513          	addi	a0,a0,-1772 # 998 <malloc+0x126>
  8c:	72c000ef          	jal	ra,7b8 <printf>

  printf("FAIL: still alive\n");
  90:	00001517          	auipc	a0,0x1
  94:	93050513          	addi	a0,a0,-1744 # 9c0 <malloc+0x14e>
  98:	720000ef          	jal	ra,7b8 <printf>
  exit(0);
  9c:	4501                	li	a0,0
  9e:	2be000ef          	jal	ra,35c <exit>
    printf("mmap failed\n");
  a2:	00001517          	auipc	a0,0x1
  a6:	8ae50513          	addi	a0,a0,-1874 # 950 <malloc+0xde>
  aa:	70e000ef          	jal	ra,7b8 <printf>
    exit(1);
  ae:	4505                	li	a0,1
  b0:	2ac000ef          	jal	ra,35c <exit>
    printf("munmap failed\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	8c450513          	addi	a0,a0,-1852 # 978 <malloc+0x106>
  bc:	6fc000ef          	jal	ra,7b8 <printf>
    exit(1);
  c0:	4505                	li	a0,1
  c2:	29a000ef          	jal	ra,35c <exit>

00000000000000c6 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ce:	f33ff0ef          	jal	ra,0 <main>
  exit(r);
  d2:	28a000ef          	jal	ra,35c <exit>

00000000000000d6 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  dc:	87aa                	mv	a5,a0
  de:	0585                	addi	a1,a1,1
  e0:	0785                	addi	a5,a5,1
  e2:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x61f>
  e6:	fee78fa3          	sb	a4,-1(a5)
  ea:	fb75                	bnez	a4,de <strcpy+0x8>
    ;
  return os;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb91                	beqz	a5,110 <strcmp+0x1e>
  fe:	0005c703          	lbu	a4,0(a1)
 102:	00f71763          	bne	a4,a5,110 <strcmp+0x1e>
    p++, q++;
 106:	0505                	addi	a0,a0,1
 108:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbe5                	bnez	a5,fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 110:	0005c503          	lbu	a0,0(a1)
}
 114:	40a7853b          	subw	a0,a5,a0
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cf91                	beqz	a5,144 <strlen+0x26>
 12a:	0505                	addi	a0,a0,1
 12c:	87aa                	mv	a5,a0
 12e:	4685                	li	a3,1
 130:	9e89                	subw	a3,a3,a0
 132:	00f6853b          	addw	a0,a3,a5
 136:	0785                	addi	a5,a5,1
 138:	fff7c703          	lbu	a4,-1(a5)
 13c:	fb7d                	bnez	a4,132 <strlen+0x14>
    ;
  return n;
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  for(n = 0; s[n]; n++)
 144:	4501                	li	a0,0
 146:	bfe5                	j	13e <strlen+0x20>

0000000000000148 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14e:	ca19                	beqz	a2,164 <memset+0x1c>
 150:	87aa                	mv	a5,a0
 152:	1602                	slli	a2,a2,0x20
 154:	9201                	srli	a2,a2,0x20
 156:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15e:	0785                	addi	a5,a5,1
 160:	fee79de3          	bne	a5,a4,15a <memset+0x12>
  }
  return dst;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 170:	00054783          	lbu	a5,0(a0)
 174:	cb99                	beqz	a5,18a <strchr+0x20>
    if(*s == c)
 176:	00f58763          	beq	a1,a5,184 <strchr+0x1a>
  for(; *s; s++)
 17a:	0505                	addi	a0,a0,1
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbfd                	bnez	a5,176 <strchr+0xc>
      return (char*)s;
  return 0;
 182:	4501                	li	a0,0
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret
  return 0;
 18a:	4501                	li	a0,0
 18c:	bfe5                	j	184 <strchr+0x1a>

000000000000018e <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 18e:	711d                	addi	sp,sp,-96
 190:	ec86                	sd	ra,88(sp)
 192:	e8a2                	sd	s0,80(sp)
 194:	e4a6                	sd	s1,72(sp)
 196:	e0ca                	sd	s2,64(sp)
 198:	fc4e                	sd	s3,56(sp)
 19a:	f852                	sd	s4,48(sp)
 19c:	f456                	sd	s5,40(sp)
 19e:	f05a                	sd	s6,32(sp)
 1a0:	ec5e                	sd	s7,24(sp)
 1a2:	1080                	addi	s0,sp,96
 1a4:	8baa                	mv	s7,a0
 1a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a8:	892a                	mv	s2,a0
 1aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ac:	4aa9                	li	s5,10
 1ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	2485                	addiw	s1,s1,1
 1b4:	0344d663          	bge	s1,s4,1e0 <gets+0x52>
    cc = read(0, &c, 1);
 1b8:	4605                	li	a2,1
 1ba:	faf40593          	addi	a1,s0,-81
 1be:	4501                	li	a0,0
 1c0:	1b4000ef          	jal	ra,374 <read>
    if(cc < 1)
 1c4:	00a05e63          	blez	a0,1e0 <gets+0x52>
    buf[i++] = c;
 1c8:	faf44783          	lbu	a5,-81(s0)
 1cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d0:	01578763          	beq	a5,s5,1de <gets+0x50>
 1d4:	0905                	addi	s2,s2,1
 1d6:	fd679de3          	bne	a5,s6,1b0 <gets+0x22>
  for(i=0; i+1 < max; ){
 1da:	89a6                	mv	s3,s1
 1dc:	a011                	j	1e0 <gets+0x52>
 1de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e0:	99de                	add	s3,s3,s7
 1e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e6:	855e                	mv	a0,s7
 1e8:	60e6                	ld	ra,88(sp)
 1ea:	6446                	ld	s0,80(sp)
 1ec:	64a6                	ld	s1,72(sp)
 1ee:	6906                	ld	s2,64(sp)
 1f0:	79e2                	ld	s3,56(sp)
 1f2:	7a42                	ld	s4,48(sp)
 1f4:	7aa2                	ld	s5,40(sp)
 1f6:	7b02                	ld	s6,32(sp)
 1f8:	6be2                	ld	s7,24(sp)
 1fa:	6125                	addi	sp,sp,96
 1fc:	8082                	ret

00000000000001fe <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 1fe:	1101                	addi	sp,sp,-32
 200:	ec06                	sd	ra,24(sp)
 202:	e822                	sd	s0,16(sp)
 204:	e426                	sd	s1,8(sp)
 206:	e04a                	sd	s2,0(sp)
 208:	1000                	addi	s0,sp,32
 20a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	4581                	li	a1,0
 20e:	18e000ef          	jal	ra,39c <open>
  if(fd < 0)
 212:	02054163          	bltz	a0,234 <stat+0x36>
 216:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 218:	85ca                	mv	a1,s2
 21a:	19a000ef          	jal	ra,3b4 <fstat>
 21e:	892a                	mv	s2,a0
  close(fd);
 220:	8526                	mv	a0,s1
 222:	162000ef          	jal	ra,384 <close>
  return r;
}
 226:	854a                	mv	a0,s2
 228:	60e2                	ld	ra,24(sp)
 22a:	6442                	ld	s0,16(sp)
 22c:	64a2                	ld	s1,8(sp)
 22e:	6902                	ld	s2,0(sp)
 230:	6105                	addi	sp,sp,32
 232:	8082                	ret
    return -1;
 234:	597d                	li	s2,-1
 236:	bfc5                	j	226 <stat+0x28>

0000000000000238 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23e:	00054603          	lbu	a2,0(a0)
 242:	fd06079b          	addiw	a5,a2,-48
 246:	0ff7f793          	andi	a5,a5,255
 24a:	4725                	li	a4,9
 24c:	02f76963          	bltu	a4,a5,27e <atoi+0x46>
 250:	86aa                	mv	a3,a0
  n = 0;
 252:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 254:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 256:	0685                	addi	a3,a3,1
 258:	0025179b          	slliw	a5,a0,0x2
 25c:	9fa9                	addw	a5,a5,a0
 25e:	0017979b          	slliw	a5,a5,0x1
 262:	9fb1                	addw	a5,a5,a2
 264:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 268:	0006c603          	lbu	a2,0(a3)
 26c:	fd06071b          	addiw	a4,a2,-48
 270:	0ff77713          	andi	a4,a4,255
 274:	fee5f1e3          	bgeu	a1,a4,256 <atoi+0x1e>
  return n;
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  n = 0;
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <atoi+0x40>

0000000000000282 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 288:	02b57463          	bgeu	a0,a1,2b0 <memmove+0x2e>
    while(n-- > 0)
 28c:	00c05f63          	blez	a2,2aa <memmove+0x28>
 290:	1602                	slli	a2,a2,0x20
 292:	9201                	srli	a2,a2,0x20
 294:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 298:	872a                	mv	a4,a0
      *dst++ = *src++;
 29a:	0585                	addi	a1,a1,1
 29c:	0705                	addi	a4,a4,1
 29e:	fff5c683          	lbu	a3,-1(a1)
 2a2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a6:	fee79ae3          	bne	a5,a4,29a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
    dst += n;
 2b0:	00c50733          	add	a4,a0,a2
    src += n;
 2b4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b6:	fec05ae3          	blez	a2,2aa <memmove+0x28>
 2ba:	fff6079b          	addiw	a5,a2,-1
 2be:	1782                	slli	a5,a5,0x20
 2c0:	9381                	srli	a5,a5,0x20
 2c2:	fff7c793          	not	a5,a5
 2c6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c8:	15fd                	addi	a1,a1,-1
 2ca:	177d                	addi	a4,a4,-1
 2cc:	0005c683          	lbu	a3,0(a1)
 2d0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d4:	fee79ae3          	bne	a5,a4,2c8 <memmove+0x46>
 2d8:	bfc9                	j	2aa <memmove+0x28>

00000000000002da <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e0:	ca05                	beqz	a2,310 <memcmp+0x36>
 2e2:	fff6069b          	addiw	a3,a2,-1
 2e6:	1682                	slli	a3,a3,0x20
 2e8:	9281                	srli	a3,a3,0x20
 2ea:	0685                	addi	a3,a3,1
 2ec:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ee:	00054783          	lbu	a5,0(a0)
 2f2:	0005c703          	lbu	a4,0(a1)
 2f6:	00e79863          	bne	a5,a4,306 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fa:	0505                	addi	a0,a0,1
    p2++;
 2fc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fe:	fed518e3          	bne	a0,a3,2ee <memcmp+0x14>
  }
  return 0;
 302:	4501                	li	a0,0
 304:	a019                	j	30a <memcmp+0x30>
      return *p1 - *p2;
 306:	40e7853b          	subw	a0,a5,a4
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  return 0;
 310:	4501                	li	a0,0
 312:	bfe5                	j	30a <memcmp+0x30>

0000000000000314 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31c:	f67ff0ef          	jal	ra,282 <memmove>
}
 320:	60a2                	ld	ra,8(sp)
 322:	6402                	ld	s0,0(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 330:	4585                	li	a1,1
 332:	0b2000ef          	jal	ra,3e4 <sys_sbrk>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 346:	4589                	li	a1,2
 348:	09c000ef          	jal	ra,3e4 <sys_sbrk>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 354:	4885                	li	a7,1
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <exit>:
.global exit
exit:
 li a7, SYS_exit
 35c:	4889                	li	a7,2
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <wait>:
.global wait
wait:
 li a7, SYS_wait
 364:	488d                	li	a7,3
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36c:	4891                	li	a7,4
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <read>:
.global read
read:
 li a7, SYS_read
 374:	4895                	li	a7,5
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <write>:
.global write
write:
 li a7, SYS_write
 37c:	48c1                	li	a7,16
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <close>:
.global close
close:
 li a7, SYS_close
 384:	48d5                	li	a7,21
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <kill>:
.global kill
kill:
 li a7, SYS_kill
 38c:	4899                	li	a7,6
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <exec>:
.global exec
exec:
 li a7, SYS_exec
 394:	489d                	li	a7,7
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <open>:
.global open
open:
 li a7, SYS_open
 39c:	48bd                	li	a7,15
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a4:	48c5                	li	a7,17
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ac:	48c9                	li	a7,18
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b4:	48a1                	li	a7,8
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <link>:
.global link
link:
 li a7, SYS_link
 3bc:	48cd                	li	a7,19
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c4:	48d1                	li	a7,20
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3cc:	48a5                	li	a7,9
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d4:	48a9                	li	a7,10
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3dc:	48ad                	li	a7,11
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e4:	48b1                	li	a7,12
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ec:	48b5                	li	a7,13
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f4:	48b9                	li	a7,14
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3fc:	48d9                	li	a7,22
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 404:	48dd                	li	a7,23
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 40c:	48e1                	li	a7,24
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 414:	48e5                	li	a7,25
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 41c:	48e9                	li	a7,26
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 424:	48ed                	li	a7,27
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 42c:	48f1                	li	a7,28
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 434:	48f5                	li	a7,29
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 43c:	1101                	addi	sp,sp,-32
 43e:	ec06                	sd	ra,24(sp)
 440:	e822                	sd	s0,16(sp)
 442:	1000                	addi	s0,sp,32
 444:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 448:	4605                	li	a2,1
 44a:	fef40593          	addi	a1,s0,-17
 44e:	f2fff0ef          	jal	ra,37c <write>
}
 452:	60e2                	ld	ra,24(sp)
 454:	6442                	ld	s0,16(sp)
 456:	6105                	addi	sp,sp,32
 458:	8082                	ret

000000000000045a <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 45a:	715d                	addi	sp,sp,-80
 45c:	e486                	sd	ra,72(sp)
 45e:	e0a2                	sd	s0,64(sp)
 460:	fc26                	sd	s1,56(sp)
 462:	f84a                	sd	s2,48(sp)
 464:	f44e                	sd	s3,40(sp)
 466:	0880                	addi	s0,sp,80
 468:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 46a:	c299                	beqz	a3,470 <printint+0x16>
 46c:	0805c163          	bltz	a1,4ee <printint+0x94>
  neg = 0;
 470:	4881                	li	a7,0
 472:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 476:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 478:	00000517          	auipc	a0,0x0
 47c:	56850513          	addi	a0,a0,1384 # 9e0 <digits>
 480:	883e                	mv	a6,a5
 482:	2785                	addiw	a5,a5,1
 484:	02c5f733          	remu	a4,a1,a2
 488:	972a                	add	a4,a4,a0
 48a:	00074703          	lbu	a4,0(a4)
 48e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 492:	872e                	mv	a4,a1
 494:	02c5d5b3          	divu	a1,a1,a2
 498:	0685                	addi	a3,a3,1
 49a:	fec773e3          	bgeu	a4,a2,480 <printint+0x26>
  if(neg)
 49e:	00088b63          	beqz	a7,4b4 <printint+0x5a>
    buf[i++] = '-';
 4a2:	fd040713          	addi	a4,s0,-48
 4a6:	97ba                	add	a5,a5,a4
 4a8:	02d00713          	li	a4,45
 4ac:	fee78423          	sb	a4,-24(a5)
 4b0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b4:	02f05663          	blez	a5,4e0 <printint+0x86>
 4b8:	fb840713          	addi	a4,s0,-72
 4bc:	00f704b3          	add	s1,a4,a5
 4c0:	fff70993          	addi	s3,a4,-1
 4c4:	99be                	add	s3,s3,a5
 4c6:	37fd                	addiw	a5,a5,-1
 4c8:	1782                	slli	a5,a5,0x20
 4ca:	9381                	srli	a5,a5,0x20
 4cc:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4d0:	fff4c583          	lbu	a1,-1(s1)
 4d4:	854a                	mv	a0,s2
 4d6:	f67ff0ef          	jal	ra,43c <putc>
  while(--i >= 0)
 4da:	14fd                	addi	s1,s1,-1
 4dc:	ff349ae3          	bne	s1,s3,4d0 <printint+0x76>
}
 4e0:	60a6                	ld	ra,72(sp)
 4e2:	6406                	ld	s0,64(sp)
 4e4:	74e2                	ld	s1,56(sp)
 4e6:	7942                	ld	s2,48(sp)
 4e8:	79a2                	ld	s3,40(sp)
 4ea:	6161                	addi	sp,sp,80
 4ec:	8082                	ret
    x = -xx;
 4ee:	40b005b3          	neg	a1,a1
    neg = 1;
 4f2:	4885                	li	a7,1
    x = -xx;
 4f4:	bfbd                	j	472 <printint+0x18>

00000000000004f6 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f6:	7119                	addi	sp,sp,-128
 4f8:	fc86                	sd	ra,120(sp)
 4fa:	f8a2                	sd	s0,112(sp)
 4fc:	f4a6                	sd	s1,104(sp)
 4fe:	f0ca                	sd	s2,96(sp)
 500:	ecce                	sd	s3,88(sp)
 502:	e8d2                	sd	s4,80(sp)
 504:	e4d6                	sd	s5,72(sp)
 506:	e0da                	sd	s6,64(sp)
 508:	fc5e                	sd	s7,56(sp)
 50a:	f862                	sd	s8,48(sp)
 50c:	f466                	sd	s9,40(sp)
 50e:	f06a                	sd	s10,32(sp)
 510:	ec6e                	sd	s11,24(sp)
 512:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 514:	0005c903          	lbu	s2,0(a1)
 518:	24090c63          	beqz	s2,770 <vprintf+0x27a>
 51c:	8b2a                	mv	s6,a0
 51e:	8a2e                	mv	s4,a1
 520:	8bb2                	mv	s7,a2
  state = 0;
 522:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 524:	4481                	li	s1,0
 526:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 528:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 52c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 530:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 534:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 538:	00000c97          	auipc	s9,0x0
 53c:	4a8c8c93          	addi	s9,s9,1192 # 9e0 <digits>
 540:	a005                	j	560 <vprintf+0x6a>
        putc(fd, c0);
 542:	85ca                	mv	a1,s2
 544:	855a                	mv	a0,s6
 546:	ef7ff0ef          	jal	ra,43c <putc>
 54a:	a019                	j	550 <vprintf+0x5a>
    } else if(state == '%'){
 54c:	03598263          	beq	s3,s5,570 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 550:	2485                	addiw	s1,s1,1
 552:	8726                	mv	a4,s1
 554:	009a07b3          	add	a5,s4,s1
 558:	0007c903          	lbu	s2,0(a5)
 55c:	20090a63          	beqz	s2,770 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 560:	0009079b          	sext.w	a5,s2
    if(state == 0){
 564:	fe0994e3          	bnez	s3,54c <vprintf+0x56>
      if(c0 == '%'){
 568:	fd579de3          	bne	a5,s5,542 <vprintf+0x4c>
        state = '%';
 56c:	89be                	mv	s3,a5
 56e:	b7cd                	j	550 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 570:	c3c1                	beqz	a5,5f0 <vprintf+0xfa>
 572:	00ea06b3          	add	a3,s4,a4
 576:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 57a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 57c:	c681                	beqz	a3,584 <vprintf+0x8e>
 57e:	9752                	add	a4,a4,s4
 580:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 584:	03878e63          	beq	a5,s8,5c0 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 588:	05a78863          	beq	a5,s10,5d8 <vprintf+0xe2>
      } else if(c0 == 'u'){
 58c:	0db78b63          	beq	a5,s11,662 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 590:	07800713          	li	a4,120
 594:	10e78d63          	beq	a5,a4,6ae <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 598:	07000713          	li	a4,112
 59c:	14e78263          	beq	a5,a4,6e0 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5a0:	06300713          	li	a4,99
 5a4:	16e78f63          	beq	a5,a4,722 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5a8:	07300713          	li	a4,115
 5ac:	18e78563          	beq	a5,a4,736 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5b0:	05579063          	bne	a5,s5,5f0 <vprintf+0xfa>
        putc(fd, '%');
 5b4:	85d6                	mv	a1,s5
 5b6:	855a                	mv	a0,s6
 5b8:	e85ff0ef          	jal	ra,43c <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5bc:	4981                	li	s3,0
 5be:	bf49                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4685                	li	a3,1
 5c6:	4629                	li	a2,10
 5c8:	000ba583          	lw	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	e8dff0ef          	jal	ra,45a <printint>
 5d2:	8bca                	mv	s7,s2
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	bfad                	j	550 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d8:	03868663          	beq	a3,s8,604 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5dc:	05a68163          	beq	a3,s10,61e <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5e0:	09b68d63          	beq	a3,s11,67a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e4:	03a68f63          	beq	a3,s10,622 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5e8:	07800793          	li	a5,120
 5ec:	0cf68d63          	beq	a3,a5,6c6 <vprintf+0x1d0>
        putc(fd, '%');
 5f0:	85d6                	mv	a1,s5
 5f2:	855a                	mv	a0,s6
 5f4:	e49ff0ef          	jal	ra,43c <putc>
        putc(fd, c0);
 5f8:	85ca                	mv	a1,s2
 5fa:	855a                	mv	a0,s6
 5fc:	e41ff0ef          	jal	ra,43c <putc>
      state = 0;
 600:	4981                	li	s3,0
 602:	b7b9                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 604:	008b8913          	addi	s2,s7,8
 608:	4685                	li	a3,1
 60a:	4629                	li	a2,10
 60c:	000bb583          	ld	a1,0(s7)
 610:	855a                	mv	a0,s6
 612:	e49ff0ef          	jal	ra,45a <printint>
        i += 1;
 616:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
        i += 1;
 61c:	bf15                	j	550 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61e:	03860563          	beq	a2,s8,648 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 622:	07b60963          	beq	a2,s11,694 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 626:	07800793          	li	a5,120
 62a:	fcf613e3          	bne	a2,a5,5f0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	008b8913          	addi	s2,s7,8
 632:	4681                	li	a3,0
 634:	4641                	li	a2,16
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e1fff0ef          	jal	ra,45a <printint>
        i += 2;
 640:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	b729                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	008b8913          	addi	s2,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e05ff0ef          	jal	ra,45a <printint>
        i += 2;
 65a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	bdc5                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4629                	li	a2,10
 66a:	000be583          	lwu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	debff0ef          	jal	ra,45a <printint>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	bde1                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	dd3ff0ef          	jal	ra,45a <printint>
        i += 1;
 68c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 1;
 692:	bd7d                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	db9ff0ef          	jal	ra,45a <printint>
        i += 2;
 6a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	b555                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4641                	li	a2,16
 6b6:	000be583          	lwu	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	d9fff0ef          	jal	ra,45a <printint>
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b571                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4641                	li	a2,16
 6ce:	000bb583          	ld	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	d87ff0ef          	jal	ra,45a <printint>
        i += 1;
 6d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
        i += 1;
 6de:	bd8d                	j	550 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6e0:	008b8793          	addi	a5,s7,8
 6e4:	f8f43423          	sd	a5,-120(s0)
 6e8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ec:	03000593          	li	a1,48
 6f0:	855a                	mv	a0,s6
 6f2:	d4bff0ef          	jal	ra,43c <putc>
  putc(fd, 'x');
 6f6:	07800593          	li	a1,120
 6fa:	855a                	mv	a0,s6
 6fc:	d41ff0ef          	jal	ra,43c <putc>
 700:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 702:	03c9d793          	srli	a5,s3,0x3c
 706:	97e6                	add	a5,a5,s9
 708:	0007c583          	lbu	a1,0(a5)
 70c:	855a                	mv	a0,s6
 70e:	d2fff0ef          	jal	ra,43c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 712:	0992                	slli	s3,s3,0x4
 714:	397d                	addiw	s2,s2,-1
 716:	fe0916e3          	bnez	s2,702 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 71a:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 71e:	4981                	li	s3,0
 720:	bd05                	j	550 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 722:	008b8913          	addi	s2,s7,8
 726:	000bc583          	lbu	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	d11ff0ef          	jal	ra,43c <putc>
 730:	8bca                	mv	s7,s2
      state = 0;
 732:	4981                	li	s3,0
 734:	bd31                	j	550 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 736:	008b8993          	addi	s3,s7,8
 73a:	000bb903          	ld	s2,0(s7)
 73e:	00090f63          	beqz	s2,75c <vprintf+0x266>
        for(; *s; s++)
 742:	00094583          	lbu	a1,0(s2)
 746:	c195                	beqz	a1,76a <vprintf+0x274>
          putc(fd, *s);
 748:	855a                	mv	a0,s6
 74a:	cf3ff0ef          	jal	ra,43c <putc>
        for(; *s; s++)
 74e:	0905                	addi	s2,s2,1
 750:	00094583          	lbu	a1,0(s2)
 754:	f9f5                	bnez	a1,748 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 756:	8bce                	mv	s7,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	bbdd                	j	550 <vprintf+0x5a>
          s = "(null)";
 75c:	00000917          	auipc	s2,0x0
 760:	27c90913          	addi	s2,s2,636 # 9d8 <malloc+0x166>
        for(; *s; s++)
 764:	02800593          	li	a1,40
 768:	b7c5                	j	748 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 76a:	8bce                	mv	s7,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b3cd                	j	550 <vprintf+0x5a>
    }
  }
}
 770:	70e6                	ld	ra,120(sp)
 772:	7446                	ld	s0,112(sp)
 774:	74a6                	ld	s1,104(sp)
 776:	7906                	ld	s2,96(sp)
 778:	69e6                	ld	s3,88(sp)
 77a:	6a46                	ld	s4,80(sp)
 77c:	6aa6                	ld	s5,72(sp)
 77e:	6b06                	ld	s6,64(sp)
 780:	7be2                	ld	s7,56(sp)
 782:	7c42                	ld	s8,48(sp)
 784:	7ca2                	ld	s9,40(sp)
 786:	7d02                	ld	s10,32(sp)
 788:	6de2                	ld	s11,24(sp)
 78a:	6109                	addi	sp,sp,128
 78c:	8082                	ret

000000000000078e <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 78e:	715d                	addi	sp,sp,-80
 790:	ec06                	sd	ra,24(sp)
 792:	e822                	sd	s0,16(sp)
 794:	1000                	addi	s0,sp,32
 796:	e010                	sd	a2,0(s0)
 798:	e414                	sd	a3,8(s0)
 79a:	e818                	sd	a4,16(s0)
 79c:	ec1c                	sd	a5,24(s0)
 79e:	03043023          	sd	a6,32(s0)
 7a2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7aa:	8622                	mv	a2,s0
 7ac:	d4bff0ef          	jal	ra,4f6 <vprintf>
}
 7b0:	60e2                	ld	ra,24(sp)
 7b2:	6442                	ld	s0,16(sp)
 7b4:	6161                	addi	sp,sp,80
 7b6:	8082                	ret

00000000000007b8 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7b8:	711d                	addi	sp,sp,-96
 7ba:	ec06                	sd	ra,24(sp)
 7bc:	e822                	sd	s0,16(sp)
 7be:	1000                	addi	s0,sp,32
 7c0:	e40c                	sd	a1,8(s0)
 7c2:	e810                	sd	a2,16(s0)
 7c4:	ec14                	sd	a3,24(s0)
 7c6:	f018                	sd	a4,32(s0)
 7c8:	f41c                	sd	a5,40(s0)
 7ca:	03043823          	sd	a6,48(s0)
 7ce:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d2:	00840613          	addi	a2,s0,8
 7d6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7da:	85aa                	mv	a1,a0
 7dc:	4505                	li	a0,1
 7de:	d19ff0ef          	jal	ra,4f6 <vprintf>
}
 7e2:	60e2                	ld	ra,24(sp)
 7e4:	6442                	ld	s0,16(sp)
 7e6:	6125                	addi	sp,sp,96
 7e8:	8082                	ret

00000000000007ea <free>:
 *   无
 */

void
free(void *ap)
{
 7ea:	1141                	addi	sp,sp,-16
 7ec:	e422                	sd	s0,8(sp)
 7ee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7f0:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f4:	00001797          	auipc	a5,0x1
 7f8:	80c7b783          	ld	a5,-2036(a5) # 1000 <freep>
 7fc:	a805                	j	82c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fe:	4618                	lw	a4,8(a2)
 800:	9db9                	addw	a1,a1,a4
 802:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 806:	6398                	ld	a4,0(a5)
 808:	6318                	ld	a4,0(a4)
 80a:	fee53823          	sd	a4,-16(a0)
 80e:	a091                	j	852 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 810:	ff852703          	lw	a4,-8(a0)
 814:	9e39                	addw	a2,a2,a4
 816:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 818:	ff053703          	ld	a4,-16(a0)
 81c:	e398                	sd	a4,0(a5)
 81e:	a099                	j	864 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	6398                	ld	a4,0(a5)
 822:	00e7e463          	bltu	a5,a4,82a <free+0x40>
 826:	00e6ea63          	bltu	a3,a4,83a <free+0x50>
{
 82a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82c:	fed7fae3          	bgeu	a5,a3,820 <free+0x36>
 830:	6398                	ld	a4,0(a5)
 832:	00e6e463          	bltu	a3,a4,83a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	fee7eae3          	bltu	a5,a4,82a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 83a:	ff852583          	lw	a1,-8(a0)
 83e:	6390                	ld	a2,0(a5)
 840:	02059713          	slli	a4,a1,0x20
 844:	9301                	srli	a4,a4,0x20
 846:	0712                	slli	a4,a4,0x4
 848:	9736                	add	a4,a4,a3
 84a:	fae60ae3          	beq	a2,a4,7fe <free+0x14>
    bp->s.ptr = p->s.ptr;
 84e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 852:	4790                	lw	a2,8(a5)
 854:	02061713          	slli	a4,a2,0x20
 858:	9301                	srli	a4,a4,0x20
 85a:	0712                	slli	a4,a4,0x4
 85c:	973e                	add	a4,a4,a5
 85e:	fae689e3          	beq	a3,a4,810 <free+0x26>
  } else
    p->s.ptr = bp;
 862:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 864:	00000717          	auipc	a4,0x0
 868:	78f73e23          	sd	a5,1948(a4) # 1000 <freep>
}
 86c:	6422                	ld	s0,8(sp)
 86e:	0141                	addi	sp,sp,16
 870:	8082                	ret

0000000000000872 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 872:	7139                	addi	sp,sp,-64
 874:	fc06                	sd	ra,56(sp)
 876:	f822                	sd	s0,48(sp)
 878:	f426                	sd	s1,40(sp)
 87a:	f04a                	sd	s2,32(sp)
 87c:	ec4e                	sd	s3,24(sp)
 87e:	e852                	sd	s4,16(sp)
 880:	e456                	sd	s5,8(sp)
 882:	e05a                	sd	s6,0(sp)
 884:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 886:	02051493          	slli	s1,a0,0x20
 88a:	9081                	srli	s1,s1,0x20
 88c:	04bd                	addi	s1,s1,15
 88e:	8091                	srli	s1,s1,0x4
 890:	0014899b          	addiw	s3,s1,1
 894:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 896:	00000517          	auipc	a0,0x0
 89a:	76a53503          	ld	a0,1898(a0) # 1000 <freep>
 89e:	c515                	beqz	a0,8ca <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8a2:	4798                	lw	a4,8(a5)
 8a4:	02977f63          	bgeu	a4,s1,8e2 <malloc+0x70>
 8a8:	8a4e                	mv	s4,s3
 8aa:	0009871b          	sext.w	a4,s3
 8ae:	6685                	lui	a3,0x1
 8b0:	00d77363          	bgeu	a4,a3,8b6 <malloc+0x44>
 8b4:	6a05                	lui	s4,0x1
 8b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8ba:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8be:	00000917          	auipc	s2,0x0
 8c2:	74290913          	addi	s2,s2,1858 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8c6:	5afd                	li	s5,-1
 8c8:	a0bd                	j	936 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8ca:	00000797          	auipc	a5,0x0
 8ce:	74678793          	addi	a5,a5,1862 # 1010 <base>
 8d2:	00000717          	auipc	a4,0x0
 8d6:	72f73723          	sd	a5,1838(a4) # 1000 <freep>
 8da:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8dc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8e0:	b7e1                	j	8a8 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8e2:	02e48b63          	beq	s1,a4,918 <malloc+0xa6>
        p->s.size -= nunits;
 8e6:	4137073b          	subw	a4,a4,s3
 8ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ec:	1702                	slli	a4,a4,0x20
 8ee:	9301                	srli	a4,a4,0x20
 8f0:	0712                	slli	a4,a4,0x4
 8f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70a73423          	sd	a0,1800(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 900:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 904:	70e2                	ld	ra,56(sp)
 906:	7442                	ld	s0,48(sp)
 908:	74a2                	ld	s1,40(sp)
 90a:	7902                	ld	s2,32(sp)
 90c:	69e2                	ld	s3,24(sp)
 90e:	6a42                	ld	s4,16(sp)
 910:	6aa2                	ld	s5,8(sp)
 912:	6b02                	ld	s6,0(sp)
 914:	6121                	addi	sp,sp,64
 916:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 918:	6398                	ld	a4,0(a5)
 91a:	e118                	sd	a4,0(a0)
 91c:	bff1                	j	8f8 <malloc+0x86>
  hp->s.size = nu;
 91e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 922:	0541                	addi	a0,a0,16
 924:	ec7ff0ef          	jal	ra,7ea <free>
  return freep;
 928:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92c:	dd61                	beqz	a0,904 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 930:	4798                	lw	a4,8(a5)
 932:	fa9778e3          	bgeu	a4,s1,8e2 <malloc+0x70>
    if(p == freep)
 936:	00093703          	ld	a4,0(s2)
 93a:	853e                	mv	a0,a5
 93c:	fef719e3          	bne	a4,a5,92e <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 940:	8552                	mv	a0,s4
 942:	9e7ff0ef          	jal	ra,328 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 946:	fd551ce3          	bne	a0,s5,91e <malloc+0xac>
        return 0;  /* 内存分配失败 */
 94a:	4501                	li	a0,0
 94c:	bf65                	j	904 <malloc+0x92>
