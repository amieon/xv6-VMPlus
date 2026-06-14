
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	97a78793          	addi	a5,a5,-1670 # 990 <malloc+0x10c>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	93450513          	addi	a0,a0,-1740 # 960 <malloc+0xdc>
  34:	796000ef          	jal	ra,7ca <printf>
  memset(data, 'a', sizeof(data));
  38:	20000613          	li	a2,512
  3c:	06100593          	li	a1,97
  40:	dd040513          	addi	a0,s0,-560
  44:	116000ef          	jal	ra,15a <memset>

  for(i = 0; i < 4; i++)
  48:	4481                	li	s1,0
  4a:	4911                	li	s2,4
    if(fork() > 0)
  4c:	31a000ef          	jal	ra,366 <fork>
  50:	00a04563          	bgtz	a0,5a <main+0x5a>
  for(i = 0; i < 4; i++)
  54:	2485                	addiw	s1,s1,1
  56:	ff249be3          	bne	s1,s2,4c <main+0x4c>
      break;

  printf("write %d\n", i);
  5a:	85a6                	mv	a1,s1
  5c:	00001517          	auipc	a0,0x1
  60:	91c50513          	addi	a0,a0,-1764 # 978 <malloc+0xf4>
  64:	766000ef          	jal	ra,7ca <printf>

  path[8] += i;
  68:	fd844783          	lbu	a5,-40(s0)
  6c:	9cbd                	addw	s1,s1,a5
  6e:	fc940c23          	sb	s1,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  72:	20200593          	li	a1,514
  76:	fd040513          	addi	a0,s0,-48
  7a:	334000ef          	jal	ra,3ae <open>
  7e:	892a                	mv	s2,a0
  80:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  82:	20000613          	li	a2,512
  86:	dd040593          	addi	a1,s0,-560
  8a:	854a                	mv	a0,s2
  8c:	302000ef          	jal	ra,38e <write>
  for(i = 0; i < 20; i++)
  90:	34fd                	addiw	s1,s1,-1
  92:	f8e5                	bnez	s1,82 <main+0x82>
  close(fd);
  94:	854a                	mv	a0,s2
  96:	300000ef          	jal	ra,396 <close>

  printf("read\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	8ee50513          	addi	a0,a0,-1810 # 988 <malloc+0x104>
  a2:	728000ef          	jal	ra,7ca <printf>

  fd = open(path, O_RDONLY);
  a6:	4581                	li	a1,0
  a8:	fd040513          	addi	a0,s0,-48
  ac:	302000ef          	jal	ra,3ae <open>
  b0:	892a                	mv	s2,a0
  b2:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  b4:	20000613          	li	a2,512
  b8:	dd040593          	addi	a1,s0,-560
  bc:	854a                	mv	a0,s2
  be:	2c8000ef          	jal	ra,386 <read>
  for (i = 0; i < 20; i++)
  c2:	34fd                	addiw	s1,s1,-1
  c4:	f8e5                	bnez	s1,b4 <main+0xb4>
  close(fd);
  c6:	854a                	mv	a0,s2
  c8:	2ce000ef          	jal	ra,396 <close>

  wait(0);
  cc:	4501                	li	a0,0
  ce:	2a8000ef          	jal	ra,376 <wait>

  exit(0);
  d2:	4501                	li	a0,0
  d4:	29a000ef          	jal	ra,36e <exit>

00000000000000d8 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e406                	sd	ra,8(sp)
  dc:	e022                	sd	s0,0(sp)
  de:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e0:	f21ff0ef          	jal	ra,0 <main>
  exit(r);
  e4:	28a000ef          	jal	ra,36e <exit>

00000000000000e8 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ee:	87aa                	mv	a5,a0
  f0:	0585                	addi	a1,a1,1
  f2:	0785                	addi	a5,a5,1
  f4:	fff5c703          	lbu	a4,-1(a1)
  f8:	fee78fa3          	sb	a4,-1(a5)
  fc:	fb75                	bnez	a4,f0 <strcpy+0x8>
    ;
  return os;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cb91                	beqz	a5,122 <strcmp+0x1e>
 110:	0005c703          	lbu	a4,0(a1)
 114:	00f71763          	bne	a4,a5,122 <strcmp+0x1e>
    p++, q++;
 118:	0505                	addi	a0,a0,1
 11a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbe5                	bnez	a5,110 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 122:	0005c503          	lbu	a0,0(a1)
}
 126:	40a7853b          	subw	a0,a5,a0
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 130:	1141                	addi	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cf91                	beqz	a5,156 <strlen+0x26>
 13c:	0505                	addi	a0,a0,1
 13e:	87aa                	mv	a5,a0
 140:	4685                	li	a3,1
 142:	9e89                	subw	a3,a3,a0
 144:	00f6853b          	addw	a0,a3,a5
 148:	0785                	addi	a5,a5,1
 14a:	fff7c703          	lbu	a4,-1(a5)
 14e:	fb7d                	bnez	a4,144 <strlen+0x14>
    ;
  return n;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  for(n = 0; s[n]; n++)
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strlen+0x20>

000000000000015a <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 160:	ca19                	beqz	a2,176 <memset+0x1c>
 162:	87aa                	mv	a5,a0
 164:	1602                	slli	a2,a2,0x20
 166:	9201                	srli	a2,a2,0x20
 168:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 170:	0785                	addi	a5,a5,1
 172:	fee79de3          	bne	a5,a4,16c <memset+0x12>
  }
  return dst;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  for(; *s; s++)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb99                	beqz	a5,19c <strchr+0x20>
    if(*s == c)
 188:	00f58763          	beq	a1,a5,196 <strchr+0x1a>
  for(; *s; s++)
 18c:	0505                	addi	a0,a0,1
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbfd                	bnez	a5,188 <strchr+0xc>
      return (char*)s;
  return 0;
 194:	4501                	li	a0,0
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  return 0;
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strchr+0x1a>

00000000000001a0 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 1a0:	711d                	addi	sp,sp,-96
 1a2:	ec86                	sd	ra,88(sp)
 1a4:	e8a2                	sd	s0,80(sp)
 1a6:	e4a6                	sd	s1,72(sp)
 1a8:	e0ca                	sd	s2,64(sp)
 1aa:	fc4e                	sd	s3,56(sp)
 1ac:	f852                	sd	s4,48(sp)
 1ae:	f456                	sd	s5,40(sp)
 1b0:	f05a                	sd	s6,32(sp)
 1b2:	ec5e                	sd	s7,24(sp)
 1b4:	1080                	addi	s0,sp,96
 1b6:	8baa                	mv	s7,a0
 1b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ba:	892a                	mv	s2,a0
 1bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1be:	4aa9                	li	s5,10
 1c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	2485                	addiw	s1,s1,1
 1c6:	0344d663          	bge	s1,s4,1f2 <gets+0x52>
    cc = read(0, &c, 1);
 1ca:	4605                	li	a2,1
 1cc:	faf40593          	addi	a1,s0,-81
 1d0:	4501                	li	a0,0
 1d2:	1b4000ef          	jal	ra,386 <read>
    if(cc < 1)
 1d6:	00a05e63          	blez	a0,1f2 <gets+0x52>
    buf[i++] = c;
 1da:	faf44783          	lbu	a5,-81(s0)
 1de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e2:	01578763          	beq	a5,s5,1f0 <gets+0x50>
 1e6:	0905                	addi	s2,s2,1
 1e8:	fd679de3          	bne	a5,s6,1c2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	a011                	j	1f2 <gets+0x52>
 1f0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f2:	99de                	add	s3,s3,s7
 1f4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f8:	855e                	mv	a0,s7
 1fa:	60e6                	ld	ra,88(sp)
 1fc:	6446                	ld	s0,80(sp)
 1fe:	64a6                	ld	s1,72(sp)
 200:	6906                	ld	s2,64(sp)
 202:	79e2                	ld	s3,56(sp)
 204:	7a42                	ld	s4,48(sp)
 206:	7aa2                	ld	s5,40(sp)
 208:	7b02                	ld	s6,32(sp)
 20a:	6be2                	ld	s7,24(sp)
 20c:	6125                	addi	sp,sp,96
 20e:	8082                	ret

0000000000000210 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 210:	1101                	addi	sp,sp,-32
 212:	ec06                	sd	ra,24(sp)
 214:	e822                	sd	s0,16(sp)
 216:	e426                	sd	s1,8(sp)
 218:	e04a                	sd	s2,0(sp)
 21a:	1000                	addi	s0,sp,32
 21c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21e:	4581                	li	a1,0
 220:	18e000ef          	jal	ra,3ae <open>
  if(fd < 0)
 224:	02054163          	bltz	a0,246 <stat+0x36>
 228:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 22a:	85ca                	mv	a1,s2
 22c:	19a000ef          	jal	ra,3c6 <fstat>
 230:	892a                	mv	s2,a0
  close(fd);
 232:	8526                	mv	a0,s1
 234:	162000ef          	jal	ra,396 <close>
  return r;
}
 238:	854a                	mv	a0,s2
 23a:	60e2                	ld	ra,24(sp)
 23c:	6442                	ld	s0,16(sp)
 23e:	64a2                	ld	s1,8(sp)
 240:	6902                	ld	s2,0(sp)
 242:	6105                	addi	sp,sp,32
 244:	8082                	ret
    return -1;
 246:	597d                	li	s2,-1
 248:	bfc5                	j	238 <stat+0x28>

000000000000024a <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 250:	00054603          	lbu	a2,0(a0)
 254:	fd06079b          	addiw	a5,a2,-48
 258:	0ff7f793          	andi	a5,a5,255
 25c:	4725                	li	a4,9
 25e:	02f76963          	bltu	a4,a5,290 <atoi+0x46>
 262:	86aa                	mv	a3,a0
  n = 0;
 264:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 266:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 268:	0685                	addi	a3,a3,1
 26a:	0025179b          	slliw	a5,a0,0x2
 26e:	9fa9                	addw	a5,a5,a0
 270:	0017979b          	slliw	a5,a5,0x1
 274:	9fb1                	addw	a5,a5,a2
 276:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27a:	0006c603          	lbu	a2,0(a3)
 27e:	fd06071b          	addiw	a4,a2,-48
 282:	0ff77713          	andi	a4,a4,255
 286:	fee5f1e3          	bgeu	a1,a4,268 <atoi+0x1e>
  return n;
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  n = 0;
 290:	4501                	li	a0,0
 292:	bfe5                	j	28a <atoi+0x40>

0000000000000294 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29a:	02b57463          	bgeu	a0,a1,2c2 <memmove+0x2e>
    while(n-- > 0)
 29e:	00c05f63          	blez	a2,2bc <memmove+0x28>
 2a2:	1602                	slli	a2,a2,0x20
 2a4:	9201                	srli	a2,a2,0x20
 2a6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2aa:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ac:	0585                	addi	a1,a1,1
 2ae:	0705                	addi	a4,a4,1
 2b0:	fff5c683          	lbu	a3,-1(a1)
 2b4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b8:	fee79ae3          	bne	a5,a4,2ac <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
    dst += n;
 2c2:	00c50733          	add	a4,a0,a2
    src += n;
 2c6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c8:	fec05ae3          	blez	a2,2bc <memmove+0x28>
 2cc:	fff6079b          	addiw	a5,a2,-1
 2d0:	1782                	slli	a5,a5,0x20
 2d2:	9381                	srli	a5,a5,0x20
 2d4:	fff7c793          	not	a5,a5
 2d8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2da:	15fd                	addi	a1,a1,-1
 2dc:	177d                	addi	a4,a4,-1
 2de:	0005c683          	lbu	a3,0(a1)
 2e2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e6:	fee79ae3          	bne	a5,a4,2da <memmove+0x46>
 2ea:	bfc9                	j	2bc <memmove+0x28>

00000000000002ec <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f2:	ca05                	beqz	a2,322 <memcmp+0x36>
 2f4:	fff6069b          	addiw	a3,a2,-1
 2f8:	1682                	slli	a3,a3,0x20
 2fa:	9281                	srli	a3,a3,0x20
 2fc:	0685                	addi	a3,a3,1
 2fe:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 300:	00054783          	lbu	a5,0(a0)
 304:	0005c703          	lbu	a4,0(a1)
 308:	00e79863          	bne	a5,a4,318 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 30c:	0505                	addi	a0,a0,1
    p2++;
 30e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 310:	fed518e3          	bne	a0,a3,300 <memcmp+0x14>
  }
  return 0;
 314:	4501                	li	a0,0
 316:	a019                	j	31c <memcmp+0x30>
      return *p1 - *p2;
 318:	40e7853b          	subw	a0,a5,a4
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
  return 0;
 322:	4501                	li	a0,0
 324:	bfe5                	j	31c <memcmp+0x30>

0000000000000326 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32e:	f67ff0ef          	jal	ra,294 <memmove>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 342:	4585                	li	a1,1
 344:	0b2000ef          	jal	ra,3f6 <sys_sbrk>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 358:	4589                	li	a1,2
 35a:	09c000ef          	jal	ra,3f6 <sys_sbrk>
}
 35e:	60a2                	ld	ra,8(sp)
 360:	6402                	ld	s0,0(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret

0000000000000366 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 366:	4885                	li	a7,1
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <exit>:
.global exit
exit:
 li a7, SYS_exit
 36e:	4889                	li	a7,2
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <wait>:
.global wait
wait:
 li a7, SYS_wait
 376:	488d                	li	a7,3
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37e:	4891                	li	a7,4
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <read>:
.global read
read:
 li a7, SYS_read
 386:	4895                	li	a7,5
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <write>:
.global write
write:
 li a7, SYS_write
 38e:	48c1                	li	a7,16
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <close>:
.global close
close:
 li a7, SYS_close
 396:	48d5                	li	a7,21
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <kill>:
.global kill
kill:
 li a7, SYS_kill
 39e:	4899                	li	a7,6
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a6:	489d                	li	a7,7
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <open>:
.global open
open:
 li a7, SYS_open
 3ae:	48bd                	li	a7,15
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b6:	48c5                	li	a7,17
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3be:	48c9                	li	a7,18
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c6:	48a1                	li	a7,8
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <link>:
.global link
link:
 li a7, SYS_link
 3ce:	48cd                	li	a7,19
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d6:	48d1                	li	a7,20
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3de:	48a5                	li	a7,9
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e6:	48a9                	li	a7,10
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ee:	48ad                	li	a7,11
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3f6:	48b1                	li	a7,12
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <pause>:
.global pause
pause:
 li a7, SYS_pause
 3fe:	48b5                	li	a7,13
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 406:	48b9                	li	a7,14
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 40e:	48d9                	li	a7,22
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 416:	48dd                	li	a7,23
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 41e:	48e1                	li	a7,24
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 426:	48e5                	li	a7,25
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 42e:	48e9                	li	a7,26
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 436:	48ed                	li	a7,27
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 43e:	48f1                	li	a7,28
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 446:	48f5                	li	a7,29
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 44e:	1101                	addi	sp,sp,-32
 450:	ec06                	sd	ra,24(sp)
 452:	e822                	sd	s0,16(sp)
 454:	1000                	addi	s0,sp,32
 456:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 45a:	4605                	li	a2,1
 45c:	fef40593          	addi	a1,s0,-17
 460:	f2fff0ef          	jal	ra,38e <write>
}
 464:	60e2                	ld	ra,24(sp)
 466:	6442                	ld	s0,16(sp)
 468:	6105                	addi	sp,sp,32
 46a:	8082                	ret

000000000000046c <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 46c:	715d                	addi	sp,sp,-80
 46e:	e486                	sd	ra,72(sp)
 470:	e0a2                	sd	s0,64(sp)
 472:	fc26                	sd	s1,56(sp)
 474:	f84a                	sd	s2,48(sp)
 476:	f44e                	sd	s3,40(sp)
 478:	0880                	addi	s0,sp,80
 47a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 47c:	c299                	beqz	a3,482 <printint+0x16>
 47e:	0805c163          	bltz	a1,500 <printint+0x94>
  neg = 0;
 482:	4881                	li	a7,0
 484:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 488:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 48a:	00000517          	auipc	a0,0x0
 48e:	51e50513          	addi	a0,a0,1310 # 9a8 <digits>
 492:	883e                	mv	a6,a5
 494:	2785                	addiw	a5,a5,1
 496:	02c5f733          	remu	a4,a1,a2
 49a:	972a                	add	a4,a4,a0
 49c:	00074703          	lbu	a4,0(a4)
 4a0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4a4:	872e                	mv	a4,a1
 4a6:	02c5d5b3          	divu	a1,a1,a2
 4aa:	0685                	addi	a3,a3,1
 4ac:	fec773e3          	bgeu	a4,a2,492 <printint+0x26>
  if(neg)
 4b0:	00088b63          	beqz	a7,4c6 <printint+0x5a>
    buf[i++] = '-';
 4b4:	fd040713          	addi	a4,s0,-48
 4b8:	97ba                	add	a5,a5,a4
 4ba:	02d00713          	li	a4,45
 4be:	fee78423          	sb	a4,-24(a5)
 4c2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4c6:	02f05663          	blez	a5,4f2 <printint+0x86>
 4ca:	fb840713          	addi	a4,s0,-72
 4ce:	00f704b3          	add	s1,a4,a5
 4d2:	fff70993          	addi	s3,a4,-1
 4d6:	99be                	add	s3,s3,a5
 4d8:	37fd                	addiw	a5,a5,-1
 4da:	1782                	slli	a5,a5,0x20
 4dc:	9381                	srli	a5,a5,0x20
 4de:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4e2:	fff4c583          	lbu	a1,-1(s1)
 4e6:	854a                	mv	a0,s2
 4e8:	f67ff0ef          	jal	ra,44e <putc>
  while(--i >= 0)
 4ec:	14fd                	addi	s1,s1,-1
 4ee:	ff349ae3          	bne	s1,s3,4e2 <printint+0x76>
}
 4f2:	60a6                	ld	ra,72(sp)
 4f4:	6406                	ld	s0,64(sp)
 4f6:	74e2                	ld	s1,56(sp)
 4f8:	7942                	ld	s2,48(sp)
 4fa:	79a2                	ld	s3,40(sp)
 4fc:	6161                	addi	sp,sp,80
 4fe:	8082                	ret
    x = -xx;
 500:	40b005b3          	neg	a1,a1
    neg = 1;
 504:	4885                	li	a7,1
    x = -xx;
 506:	bfbd                	j	484 <printint+0x18>

0000000000000508 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 508:	7119                	addi	sp,sp,-128
 50a:	fc86                	sd	ra,120(sp)
 50c:	f8a2                	sd	s0,112(sp)
 50e:	f4a6                	sd	s1,104(sp)
 510:	f0ca                	sd	s2,96(sp)
 512:	ecce                	sd	s3,88(sp)
 514:	e8d2                	sd	s4,80(sp)
 516:	e4d6                	sd	s5,72(sp)
 518:	e0da                	sd	s6,64(sp)
 51a:	fc5e                	sd	s7,56(sp)
 51c:	f862                	sd	s8,48(sp)
 51e:	f466                	sd	s9,40(sp)
 520:	f06a                	sd	s10,32(sp)
 522:	ec6e                	sd	s11,24(sp)
 524:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 526:	0005c903          	lbu	s2,0(a1)
 52a:	24090c63          	beqz	s2,782 <vprintf+0x27a>
 52e:	8b2a                	mv	s6,a0
 530:	8a2e                	mv	s4,a1
 532:	8bb2                	mv	s7,a2
  state = 0;
 534:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 536:	4481                	li	s1,0
 538:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 53a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 53e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 542:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 546:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54a:	00000c97          	auipc	s9,0x0
 54e:	45ec8c93          	addi	s9,s9,1118 # 9a8 <digits>
 552:	a005                	j	572 <vprintf+0x6a>
        putc(fd, c0);
 554:	85ca                	mv	a1,s2
 556:	855a                	mv	a0,s6
 558:	ef7ff0ef          	jal	ra,44e <putc>
 55c:	a019                	j	562 <vprintf+0x5a>
    } else if(state == '%'){
 55e:	03598263          	beq	s3,s5,582 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 562:	2485                	addiw	s1,s1,1
 564:	8726                	mv	a4,s1
 566:	009a07b3          	add	a5,s4,s1
 56a:	0007c903          	lbu	s2,0(a5)
 56e:	20090a63          	beqz	s2,782 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 572:	0009079b          	sext.w	a5,s2
    if(state == 0){
 576:	fe0994e3          	bnez	s3,55e <vprintf+0x56>
      if(c0 == '%'){
 57a:	fd579de3          	bne	a5,s5,554 <vprintf+0x4c>
        state = '%';
 57e:	89be                	mv	s3,a5
 580:	b7cd                	j	562 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 582:	c3c1                	beqz	a5,602 <vprintf+0xfa>
 584:	00ea06b3          	add	a3,s4,a4
 588:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 58c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 58e:	c681                	beqz	a3,596 <vprintf+0x8e>
 590:	9752                	add	a4,a4,s4
 592:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 596:	03878e63          	beq	a5,s8,5d2 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 59a:	05a78863          	beq	a5,s10,5ea <vprintf+0xe2>
      } else if(c0 == 'u'){
 59e:	0db78b63          	beq	a5,s11,674 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a2:	07800713          	li	a4,120
 5a6:	10e78d63          	beq	a5,a4,6c0 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5aa:	07000713          	li	a4,112
 5ae:	14e78263          	beq	a5,a4,6f2 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5b2:	06300713          	li	a4,99
 5b6:	16e78f63          	beq	a5,a4,734 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5ba:	07300713          	li	a4,115
 5be:	18e78563          	beq	a5,a4,748 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5c2:	05579063          	bne	a5,s5,602 <vprintf+0xfa>
        putc(fd, '%');
 5c6:	85d6                	mv	a1,s5
 5c8:	855a                	mv	a0,s6
 5ca:	e85ff0ef          	jal	ra,44e <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	bf49                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4685                	li	a3,1
 5d8:	4629                	li	a2,10
 5da:	000ba583          	lw	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e8dff0ef          	jal	ra,46c <printint>
 5e4:	8bca                	mv	s7,s2
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bfad                	j	562 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ea:	03868663          	beq	a3,s8,616 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ee:	05a68163          	beq	a3,s10,630 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5f2:	09b68d63          	beq	a3,s11,68c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f6:	03a68f63          	beq	a3,s10,634 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5fa:	07800793          	li	a5,120
 5fe:	0cf68d63          	beq	a3,a5,6d8 <vprintf+0x1d0>
        putc(fd, '%');
 602:	85d6                	mv	a1,s5
 604:	855a                	mv	a0,s6
 606:	e49ff0ef          	jal	ra,44e <putc>
        putc(fd, c0);
 60a:	85ca                	mv	a1,s2
 60c:	855a                	mv	a0,s6
 60e:	e41ff0ef          	jal	ra,44e <putc>
      state = 0;
 612:	4981                	li	s3,0
 614:	b7b9                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 616:	008b8913          	addi	s2,s7,8
 61a:	4685                	li	a3,1
 61c:	4629                	li	a2,10
 61e:	000bb583          	ld	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	e49ff0ef          	jal	ra,46c <printint>
        i += 1;
 628:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
        i += 1;
 62e:	bf15                	j	562 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 630:	03860563          	beq	a2,s8,65a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 634:	07b60963          	beq	a2,s11,6a6 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 638:	07800793          	li	a5,120
 63c:	fcf613e3          	bne	a2,a5,602 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 640:	008b8913          	addi	s2,s7,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000bb583          	ld	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e1fff0ef          	jal	ra,46c <printint>
        i += 2;
 652:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
        i += 2;
 658:	b729                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4685                	li	a3,1
 660:	4629                	li	a2,10
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	e05ff0ef          	jal	ra,46c <printint>
        i += 2;
 66c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
        i += 2;
 672:	bdc5                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4629                	li	a2,10
 67c:	000be583          	lwu	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	debff0ef          	jal	ra,46c <printint>
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bde1                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000bb583          	ld	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	dd3ff0ef          	jal	ra,46c <printint>
        i += 1;
 69e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
        i += 1;
 6a4:	bd7d                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	db9ff0ef          	jal	ra,46c <printint>
        i += 2;
 6b8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 2;
 6be:	b555                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000be583          	lwu	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	d9fff0ef          	jal	ra,46c <printint>
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b571                	j	562 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4641                	li	a2,16
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	d87ff0ef          	jal	ra,46c <printint>
        i += 1;
 6ea:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
        i += 1;
 6f0:	bd8d                	j	562 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6f2:	008b8793          	addi	a5,s7,8
 6f6:	f8f43423          	sd	a5,-120(s0)
 6fa:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6fe:	03000593          	li	a1,48
 702:	855a                	mv	a0,s6
 704:	d4bff0ef          	jal	ra,44e <putc>
  putc(fd, 'x');
 708:	07800593          	li	a1,120
 70c:	855a                	mv	a0,s6
 70e:	d41ff0ef          	jal	ra,44e <putc>
 712:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 714:	03c9d793          	srli	a5,s3,0x3c
 718:	97e6                	add	a5,a5,s9
 71a:	0007c583          	lbu	a1,0(a5)
 71e:	855a                	mv	a0,s6
 720:	d2fff0ef          	jal	ra,44e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 724:	0992                	slli	s3,s3,0x4
 726:	397d                	addiw	s2,s2,-1
 728:	fe0916e3          	bnez	s2,714 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 72c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 730:	4981                	li	s3,0
 732:	bd05                	j	562 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 734:	008b8913          	addi	s2,s7,8
 738:	000bc583          	lbu	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	d11ff0ef          	jal	ra,44e <putc>
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
 746:	bd31                	j	562 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 748:	008b8993          	addi	s3,s7,8
 74c:	000bb903          	ld	s2,0(s7)
 750:	00090f63          	beqz	s2,76e <vprintf+0x266>
        for(; *s; s++)
 754:	00094583          	lbu	a1,0(s2)
 758:	c195                	beqz	a1,77c <vprintf+0x274>
          putc(fd, *s);
 75a:	855a                	mv	a0,s6
 75c:	cf3ff0ef          	jal	ra,44e <putc>
        for(; *s; s++)
 760:	0905                	addi	s2,s2,1
 762:	00094583          	lbu	a1,0(s2)
 766:	f9f5                	bnez	a1,75a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 768:	8bce                	mv	s7,s3
      state = 0;
 76a:	4981                	li	s3,0
 76c:	bbdd                	j	562 <vprintf+0x5a>
          s = "(null)";
 76e:	00000917          	auipc	s2,0x0
 772:	23290913          	addi	s2,s2,562 # 9a0 <malloc+0x11c>
        for(; *s; s++)
 776:	02800593          	li	a1,40
 77a:	b7c5                	j	75a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 77c:	8bce                	mv	s7,s3
      state = 0;
 77e:	4981                	li	s3,0
 780:	b3cd                	j	562 <vprintf+0x5a>
    }
  }
}
 782:	70e6                	ld	ra,120(sp)
 784:	7446                	ld	s0,112(sp)
 786:	74a6                	ld	s1,104(sp)
 788:	7906                	ld	s2,96(sp)
 78a:	69e6                	ld	s3,88(sp)
 78c:	6a46                	ld	s4,80(sp)
 78e:	6aa6                	ld	s5,72(sp)
 790:	6b06                	ld	s6,64(sp)
 792:	7be2                	ld	s7,56(sp)
 794:	7c42                	ld	s8,48(sp)
 796:	7ca2                	ld	s9,40(sp)
 798:	7d02                	ld	s10,32(sp)
 79a:	6de2                	ld	s11,24(sp)
 79c:	6109                	addi	sp,sp,128
 79e:	8082                	ret

00000000000007a0 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 7a0:	715d                	addi	sp,sp,-80
 7a2:	ec06                	sd	ra,24(sp)
 7a4:	e822                	sd	s0,16(sp)
 7a6:	1000                	addi	s0,sp,32
 7a8:	e010                	sd	a2,0(s0)
 7aa:	e414                	sd	a3,8(s0)
 7ac:	e818                	sd	a4,16(s0)
 7ae:	ec1c                	sd	a5,24(s0)
 7b0:	03043023          	sd	a6,32(s0)
 7b4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7bc:	8622                	mv	a2,s0
 7be:	d4bff0ef          	jal	ra,508 <vprintf>
}
 7c2:	60e2                	ld	ra,24(sp)
 7c4:	6442                	ld	s0,16(sp)
 7c6:	6161                	addi	sp,sp,80
 7c8:	8082                	ret

00000000000007ca <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7ca:	711d                	addi	sp,sp,-96
 7cc:	ec06                	sd	ra,24(sp)
 7ce:	e822                	sd	s0,16(sp)
 7d0:	1000                	addi	s0,sp,32
 7d2:	e40c                	sd	a1,8(s0)
 7d4:	e810                	sd	a2,16(s0)
 7d6:	ec14                	sd	a3,24(s0)
 7d8:	f018                	sd	a4,32(s0)
 7da:	f41c                	sd	a5,40(s0)
 7dc:	03043823          	sd	a6,48(s0)
 7e0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e4:	00840613          	addi	a2,s0,8
 7e8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ec:	85aa                	mv	a1,a0
 7ee:	4505                	li	a0,1
 7f0:	d19ff0ef          	jal	ra,508 <vprintf>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6125                	addi	sp,sp,96
 7fa:	8082                	ret

00000000000007fc <free>:
 *   无
 */

void
free(void *ap)
{
 7fc:	1141                	addi	sp,sp,-16
 7fe:	e422                	sd	s0,8(sp)
 800:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 802:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	00000797          	auipc	a5,0x0
 80a:	7fa7b783          	ld	a5,2042(a5) # 1000 <freep>
 80e:	a805                	j	83e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 810:	4618                	lw	a4,8(a2)
 812:	9db9                	addw	a1,a1,a4
 814:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 818:	6398                	ld	a4,0(a5)
 81a:	6318                	ld	a4,0(a4)
 81c:	fee53823          	sd	a4,-16(a0)
 820:	a091                	j	864 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 822:	ff852703          	lw	a4,-8(a0)
 826:	9e39                	addw	a2,a2,a4
 828:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 82a:	ff053703          	ld	a4,-16(a0)
 82e:	e398                	sd	a4,0(a5)
 830:	a099                	j	876 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	6398                	ld	a4,0(a5)
 834:	00e7e463          	bltu	a5,a4,83c <free+0x40>
 838:	00e6ea63          	bltu	a3,a4,84c <free+0x50>
{
 83c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83e:	fed7fae3          	bgeu	a5,a3,832 <free+0x36>
 842:	6398                	ld	a4,0(a5)
 844:	00e6e463          	bltu	a3,a4,84c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 848:	fee7eae3          	bltu	a5,a4,83c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 84c:	ff852583          	lw	a1,-8(a0)
 850:	6390                	ld	a2,0(a5)
 852:	02059713          	slli	a4,a1,0x20
 856:	9301                	srli	a4,a4,0x20
 858:	0712                	slli	a4,a4,0x4
 85a:	9736                	add	a4,a4,a3
 85c:	fae60ae3          	beq	a2,a4,810 <free+0x14>
    bp->s.ptr = p->s.ptr;
 860:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 864:	4790                	lw	a2,8(a5)
 866:	02061713          	slli	a4,a2,0x20
 86a:	9301                	srli	a4,a4,0x20
 86c:	0712                	slli	a4,a4,0x4
 86e:	973e                	add	a4,a4,a5
 870:	fae689e3          	beq	a3,a4,822 <free+0x26>
  } else
    p->s.ptr = bp;
 874:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 876:	00000717          	auipc	a4,0x0
 87a:	78f73523          	sd	a5,1930(a4) # 1000 <freep>
}
 87e:	6422                	ld	s0,8(sp)
 880:	0141                	addi	sp,sp,16
 882:	8082                	ret

0000000000000884 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 884:	7139                	addi	sp,sp,-64
 886:	fc06                	sd	ra,56(sp)
 888:	f822                	sd	s0,48(sp)
 88a:	f426                	sd	s1,40(sp)
 88c:	f04a                	sd	s2,32(sp)
 88e:	ec4e                	sd	s3,24(sp)
 890:	e852                	sd	s4,16(sp)
 892:	e456                	sd	s5,8(sp)
 894:	e05a                	sd	s6,0(sp)
 896:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 898:	02051493          	slli	s1,a0,0x20
 89c:	9081                	srli	s1,s1,0x20
 89e:	04bd                	addi	s1,s1,15
 8a0:	8091                	srli	s1,s1,0x4
 8a2:	0014899b          	addiw	s3,s1,1
 8a6:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 8a8:	00000517          	auipc	a0,0x0
 8ac:	75853503          	ld	a0,1880(a0) # 1000 <freep>
 8b0:	c515                	beqz	a0,8dc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8b4:	4798                	lw	a4,8(a5)
 8b6:	02977f63          	bgeu	a4,s1,8f4 <malloc+0x70>
 8ba:	8a4e                	mv	s4,s3
 8bc:	0009871b          	sext.w	a4,s3
 8c0:	6685                	lui	a3,0x1
 8c2:	00d77363          	bgeu	a4,a3,8c8 <malloc+0x44>
 8c6:	6a05                	lui	s4,0x1
 8c8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8cc:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8d0:	00000917          	auipc	s2,0x0
 8d4:	73090913          	addi	s2,s2,1840 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8d8:	5afd                	li	s5,-1
 8da:	a0bd                	j	948 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8dc:	00000797          	auipc	a5,0x0
 8e0:	73478793          	addi	a5,a5,1844 # 1010 <base>
 8e4:	00000717          	auipc	a4,0x0
 8e8:	70f73e23          	sd	a5,1820(a4) # 1000 <freep>
 8ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8f2:	b7e1                	j	8ba <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8f4:	02e48b63          	beq	s1,a4,92a <malloc+0xa6>
        p->s.size -= nunits;
 8f8:	4137073b          	subw	a4,a4,s3
 8fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fe:	1702                	slli	a4,a4,0x20
 900:	9301                	srli	a4,a4,0x20
 902:	0712                	slli	a4,a4,0x4
 904:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 906:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 90a:	00000717          	auipc	a4,0x0
 90e:	6ea73b23          	sd	a0,1782(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 912:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 916:	70e2                	ld	ra,56(sp)
 918:	7442                	ld	s0,48(sp)
 91a:	74a2                	ld	s1,40(sp)
 91c:	7902                	ld	s2,32(sp)
 91e:	69e2                	ld	s3,24(sp)
 920:	6a42                	ld	s4,16(sp)
 922:	6aa2                	ld	s5,8(sp)
 924:	6b02                	ld	s6,0(sp)
 926:	6121                	addi	sp,sp,64
 928:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 92a:	6398                	ld	a4,0(a5)
 92c:	e118                	sd	a4,0(a0)
 92e:	bff1                	j	90a <malloc+0x86>
  hp->s.size = nu;
 930:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 934:	0541                	addi	a0,a0,16
 936:	ec7ff0ef          	jal	ra,7fc <free>
  return freep;
 93a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 93e:	dd61                	beqz	a0,916 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 940:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 942:	4798                	lw	a4,8(a5)
 944:	fa9778e3          	bgeu	a4,s1,8f4 <malloc+0x70>
    if(p == freep)
 948:	00093703          	ld	a4,0(s2)
 94c:	853e                	mv	a0,a5
 94e:	fef719e3          	bne	a4,a5,940 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 952:	8552                	mv	a0,s4
 954:	9e7ff0ef          	jal	ra,33a <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 958:	fd551ce3          	bne	a0,s5,930 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 95c:	4501                	li	a0,0
 95e:	bf65                	j	916 <malloc+0x92>
