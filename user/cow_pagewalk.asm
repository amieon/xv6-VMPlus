
user/_cow_pagewalk:     file format elf64-littleriscv


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
   8:	1000                	addi	s0,sp,32
  char *p = sbrk(4096);
   a:	6505                	lui	a0,0x1
   c:	318000ef          	jal	ra,324 <sbrk>
  10:	84aa                	mv	s1,a0
  if(p == (char*)-1) exit(1);
  12:	577d                	li	a4,-1
  14:	4781                	li	a5,0

  for(int i = 0; i < 4096; i++)
    p[i] = (char)(i % 97);
  16:	06100593          	li	a1,97
  for(int i = 0; i < 4096; i++)
  1a:	6605                	lui	a2,0x1
  if(p == (char*)-1) exit(1);
  1c:	04e50563          	beq	a0,a4,66 <main+0x66>
    p[i] = (char)(i % 97);
  20:	00f48733          	add	a4,s1,a5
  24:	02b7e6bb          	remw	a3,a5,a1
  28:	00d70023          	sb	a3,0(a4)
  for(int i = 0; i < 4096; i++)
  2c:	0785                	addi	a5,a5,1
  2e:	fec799e3          	bne	a5,a2,20 <main+0x20>

  int pid = fork();
  32:	31e000ef          	jal	ra,350 <fork>
  if(pid < 0) exit(1);
  36:	02054b63          	bltz	a0,6c <main+0x6c>

  if(pid == 0){
  3a:	ed05                	bnez	a0,72 <main+0x72>
  3c:	87a6                	mv	a5,s1
  3e:	6705                	lui	a4,0x1
  40:	0719                	addi	a4,a4,6
  42:	94ba                	add	s1,s1,a4
    for(int i = 0; i < 4096; i += 7)
      p[i] = (char)(p[i] + 1);
  44:	0007c703          	lbu	a4,0(a5)
  48:	2705                	addiw	a4,a4,1
  4a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < 4096; i += 7)
  4e:	079d                	addi	a5,a5,7
  50:	fe979ae3          	bne	a5,s1,44 <main+0x44>
    printf("child: wrote many offsets\n");
  54:	00001517          	auipc	a0,0x1
  58:	8fc50513          	addi	a0,a0,-1796 # 950 <malloc+0xe2>
  5c:	758000ef          	jal	ra,7b4 <printf>
    exit(0);
  60:	4501                	li	a0,0
  62:	2f6000ef          	jal	ra,358 <exit>
  if(p == (char*)-1) exit(1);
  66:	4505                	li	a0,1
  68:	2f0000ef          	jal	ra,358 <exit>
  if(pid < 0) exit(1);
  6c:	4505                	li	a0,1
  6e:	2ea000ef          	jal	ra,358 <exit>
  }

  wait(0);
  72:	4501                	li	a0,0
  74:	2ec000ef          	jal	ra,360 <wait>
  78:	4701                	li	a4,0
  // 父校验页内容未变
  for(int i = 0; i < 4096; i++){
    if(p[i] != (char)(i % 97)){
  7a:	06100613          	li	a2,97
  for(int i = 0; i < 4096; i++){
  7e:	6505                	lui	a0,0x1
  80:	0007059b          	sext.w	a1,a4
    if(p[i] != (char)(i % 97)){
  84:	00e486b3          	add	a3,s1,a4
  88:	02c767bb          	remw	a5,a4,a2
  8c:	0006c683          	lbu	a3,0(a3)
  90:	0ff7f793          	andi	a5,a5,255
  94:	00f69e63          	bne	a3,a5,b0 <main+0xb0>
  for(int i = 0; i < 4096; i++){
  98:	0705                	addi	a4,a4,1
  9a:	fea713e3          	bne	a4,a0,80 <main+0x80>
      printf("FAIL: parent page changed at %d\n", i);
      exit(1);
    }
  }
  printf("PASS\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	8fa50513          	addi	a0,a0,-1798 # 998 <malloc+0x12a>
  a6:	70e000ef          	jal	ra,7b4 <printf>
  exit(0);
  aa:	4501                	li	a0,0
  ac:	2ac000ef          	jal	ra,358 <exit>
      printf("FAIL: parent page changed at %d\n", i);
  b0:	00001517          	auipc	a0,0x1
  b4:	8c050513          	addi	a0,a0,-1856 # 970 <malloc+0x102>
  b8:	6fc000ef          	jal	ra,7b4 <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	29a000ef          	jal	ra,358 <exit>

00000000000000c2 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e406                	sd	ra,8(sp)
  c6:	e022                	sd	s0,0(sp)
  c8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ca:	f37ff0ef          	jal	ra,0 <main>
  exit(r);
  ce:	28a000ef          	jal	ra,358 <exit>

00000000000000d2 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d8:	87aa                	mv	a5,a0
  da:	0585                	addi	a1,a1,1
  dc:	0785                	addi	a5,a5,1
  de:	fff5c703          	lbu	a4,-1(a1)
  e2:	fee78fa3          	sb	a4,-1(a5)
  e6:	fb75                	bnez	a4,da <strcpy+0x8>
    ;
  return os;
}
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cb91                	beqz	a5,10c <strcmp+0x1e>
  fa:	0005c703          	lbu	a4,0(a1)
  fe:	00f71763          	bne	a4,a5,10c <strcmp+0x1e>
    p++, q++;
 102:	0505                	addi	a0,a0,1
 104:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbe5                	bnez	a5,fa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10c:	0005c503          	lbu	a0,0(a1)
}
 110:	40a7853b          	subw	a0,a5,a0
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 120:	00054783          	lbu	a5,0(a0)
 124:	cf91                	beqz	a5,140 <strlen+0x26>
 126:	0505                	addi	a0,a0,1
 128:	87aa                	mv	a5,a0
 12a:	4685                	li	a3,1
 12c:	9e89                	subw	a3,a3,a0
 12e:	00f6853b          	addw	a0,a3,a5
 132:	0785                	addi	a5,a5,1
 134:	fff7c703          	lbu	a4,-1(a5)
 138:	fb7d                	bnez	a4,12e <strlen+0x14>
    ;
  return n;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret
  for(n = 0; s[n]; n++)
 140:	4501                	li	a0,0
 142:	bfe5                	j	13a <strlen+0x20>

0000000000000144 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14a:	ca19                	beqz	a2,160 <memset+0x1c>
 14c:	87aa                	mv	a5,a0
 14e:	1602                	slli	a2,a2,0x20
 150:	9201                	srli	a2,a2,0x20
 152:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 156:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15a:	0785                	addi	a5,a5,1
 15c:	fee79de3          	bne	a5,a4,156 <memset+0x12>
  }
  return dst;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb99                	beqz	a5,186 <strchr+0x20>
    if(*s == c)
 172:	00f58763          	beq	a1,a5,180 <strchr+0x1a>
  for(; *s; s++)
 176:	0505                	addi	a0,a0,1
 178:	00054783          	lbu	a5,0(a0)
 17c:	fbfd                	bnez	a5,172 <strchr+0xc>
      return (char*)s;
  return 0;
 17e:	4501                	li	a0,0
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  return 0;
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strchr+0x1a>

000000000000018a <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 18a:	711d                	addi	sp,sp,-96
 18c:	ec86                	sd	ra,88(sp)
 18e:	e8a2                	sd	s0,80(sp)
 190:	e4a6                	sd	s1,72(sp)
 192:	e0ca                	sd	s2,64(sp)
 194:	fc4e                	sd	s3,56(sp)
 196:	f852                	sd	s4,48(sp)
 198:	f456                	sd	s5,40(sp)
 19a:	f05a                	sd	s6,32(sp)
 19c:	ec5e                	sd	s7,24(sp)
 19e:	1080                	addi	s0,sp,96
 1a0:	8baa                	mv	s7,a0
 1a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	892a                	mv	s2,a0
 1a6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a8:	4aa9                	li	s5,10
 1aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ac:	89a6                	mv	s3,s1
 1ae:	2485                	addiw	s1,s1,1
 1b0:	0344d663          	bge	s1,s4,1dc <gets+0x52>
    cc = read(0, &c, 1);
 1b4:	4605                	li	a2,1
 1b6:	faf40593          	addi	a1,s0,-81
 1ba:	4501                	li	a0,0
 1bc:	1b4000ef          	jal	ra,370 <read>
    if(cc < 1)
 1c0:	00a05e63          	blez	a0,1dc <gets+0x52>
    buf[i++] = c;
 1c4:	faf44783          	lbu	a5,-81(s0)
 1c8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1cc:	01578763          	beq	a5,s5,1da <gets+0x50>
 1d0:	0905                	addi	s2,s2,1
 1d2:	fd679de3          	bne	a5,s6,1ac <gets+0x22>
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	a011                	j	1dc <gets+0x52>
 1da:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1dc:	99de                	add	s3,s3,s7
 1de:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e2:	855e                	mv	a0,s7
 1e4:	60e6                	ld	ra,88(sp)
 1e6:	6446                	ld	s0,80(sp)
 1e8:	64a6                	ld	s1,72(sp)
 1ea:	6906                	ld	s2,64(sp)
 1ec:	79e2                	ld	s3,56(sp)
 1ee:	7a42                	ld	s4,48(sp)
 1f0:	7aa2                	ld	s5,40(sp)
 1f2:	7b02                	ld	s6,32(sp)
 1f4:	6be2                	ld	s7,24(sp)
 1f6:	6125                	addi	sp,sp,96
 1f8:	8082                	ret

00000000000001fa <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 1fa:	1101                	addi	sp,sp,-32
 1fc:	ec06                	sd	ra,24(sp)
 1fe:	e822                	sd	s0,16(sp)
 200:	e426                	sd	s1,8(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 208:	4581                	li	a1,0
 20a:	18e000ef          	jal	ra,398 <open>
  if(fd < 0)
 20e:	02054163          	bltz	a0,230 <stat+0x36>
 212:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 214:	85ca                	mv	a1,s2
 216:	19a000ef          	jal	ra,3b0 <fstat>
 21a:	892a                	mv	s2,a0
  close(fd);
 21c:	8526                	mv	a0,s1
 21e:	162000ef          	jal	ra,380 <close>
  return r;
}
 222:	854a                	mv	a0,s2
 224:	60e2                	ld	ra,24(sp)
 226:	6442                	ld	s0,16(sp)
 228:	64a2                	ld	s1,8(sp)
 22a:	6902                	ld	s2,0(sp)
 22c:	6105                	addi	sp,sp,32
 22e:	8082                	ret
    return -1;
 230:	597d                	li	s2,-1
 232:	bfc5                	j	222 <stat+0x28>

0000000000000234 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23a:	00054603          	lbu	a2,0(a0)
 23e:	fd06079b          	addiw	a5,a2,-48
 242:	0ff7f793          	andi	a5,a5,255
 246:	4725                	li	a4,9
 248:	02f76963          	bltu	a4,a5,27a <atoi+0x46>
 24c:	86aa                	mv	a3,a0
  n = 0;
 24e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 250:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 252:	0685                	addi	a3,a3,1
 254:	0025179b          	slliw	a5,a0,0x2
 258:	9fa9                	addw	a5,a5,a0
 25a:	0017979b          	slliw	a5,a5,0x1
 25e:	9fb1                	addw	a5,a5,a2
 260:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 264:	0006c603          	lbu	a2,0(a3)
 268:	fd06071b          	addiw	a4,a2,-48
 26c:	0ff77713          	andi	a4,a4,255
 270:	fee5f1e3          	bgeu	a1,a4,252 <atoi+0x1e>
  return n;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  n = 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <atoi+0x40>

000000000000027e <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 284:	02b57463          	bgeu	a0,a1,2ac <memmove+0x2e>
    while(n-- > 0)
 288:	00c05f63          	blez	a2,2a6 <memmove+0x28>
 28c:	1602                	slli	a2,a2,0x20
 28e:	9201                	srli	a2,a2,0x20
 290:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 294:	872a                	mv	a4,a0
      *dst++ = *src++;
 296:	0585                	addi	a1,a1,1
 298:	0705                	addi	a4,a4,1
 29a:	fff5c683          	lbu	a3,-1(a1)
 29e:	fed70fa3          	sb	a3,-1(a4) # fff <digits+0x657>
    while(n-- > 0)
 2a2:	fee79ae3          	bne	a5,a4,296 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
    dst += n;
 2ac:	00c50733          	add	a4,a0,a2
    src += n;
 2b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b2:	fec05ae3          	blez	a2,2a6 <memmove+0x28>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	fff7c793          	not	a5,a5
 2c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c4:	15fd                	addi	a1,a1,-1
 2c6:	177d                	addi	a4,a4,-1
 2c8:	0005c683          	lbu	a3,0(a1)
 2cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x46>
 2d4:	bfc9                	j	2a6 <memmove+0x28>

00000000000002d6 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2dc:	ca05                	beqz	a2,30c <memcmp+0x36>
 2de:	fff6069b          	addiw	a3,a2,-1
 2e2:	1682                	slli	a3,a3,0x20
 2e4:	9281                	srli	a3,a3,0x20
 2e6:	0685                	addi	a3,a3,1
 2e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00e79863          	bne	a5,a4,302 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f6:	0505                	addi	a0,a0,1
    p2++;
 2f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fa:	fed518e3          	bne	a0,a3,2ea <memcmp+0x14>
  }
  return 0;
 2fe:	4501                	li	a0,0
 300:	a019                	j	306 <memcmp+0x30>
      return *p1 - *p2;
 302:	40e7853b          	subw	a0,a5,a4
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <memcmp+0x30>

0000000000000310 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 318:	f67ff0ef          	jal	ra,27e <memmove>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32c:	4585                	li	a1,1
 32e:	0b2000ef          	jal	ra,3e0 <sys_sbrk>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 342:	4589                	li	a1,2
 344:	09c000ef          	jal	ra,3e0 <sys_sbrk>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 350:	4885                	li	a7,1
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exit>:
.global exit
exit:
 li a7, SYS_exit
 358:	4889                	li	a7,2
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <wait>:
.global wait
wait:
 li a7, SYS_wait
 360:	488d                	li	a7,3
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 368:	4891                	li	a7,4
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <read>:
.global read
read:
 li a7, SYS_read
 370:	4895                	li	a7,5
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <write>:
.global write
write:
 li a7, SYS_write
 378:	48c1                	li	a7,16
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <close>:
.global close
close:
 li a7, SYS_close
 380:	48d5                	li	a7,21
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <kill>:
.global kill
kill:
 li a7, SYS_kill
 388:	4899                	li	a7,6
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exec>:
.global exec
exec:
 li a7, SYS_exec
 390:	489d                	li	a7,7
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <open>:
.global open
open:
 li a7, SYS_open
 398:	48bd                	li	a7,15
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a0:	48c5                	li	a7,17
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a8:	48c9                	li	a7,18
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b0:	48a1                	li	a7,8
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <link>:
.global link
link:
 li a7, SYS_link
 3b8:	48cd                	li	a7,19
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c0:	48d1                	li	a7,20
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c8:	48a5                	li	a7,9
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d0:	48a9                	li	a7,10
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d8:	48ad                	li	a7,11
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e0:	48b1                	li	a7,12
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e8:	48b5                	li	a7,13
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f0:	48b9                	li	a7,14
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3f8:	48d9                	li	a7,22
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 400:	48dd                	li	a7,23
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 408:	48e1                	li	a7,24
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 410:	48e5                	li	a7,25
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 418:	48e9                	li	a7,26
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 420:	48ed                	li	a7,27
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 428:	48f1                	li	a7,28
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 430:	48f5                	li	a7,29
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 438:	1101                	addi	sp,sp,-32
 43a:	ec06                	sd	ra,24(sp)
 43c:	e822                	sd	s0,16(sp)
 43e:	1000                	addi	s0,sp,32
 440:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 444:	4605                	li	a2,1
 446:	fef40593          	addi	a1,s0,-17
 44a:	f2fff0ef          	jal	ra,378 <write>
}
 44e:	60e2                	ld	ra,24(sp)
 450:	6442                	ld	s0,16(sp)
 452:	6105                	addi	sp,sp,32
 454:	8082                	ret

0000000000000456 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 456:	715d                	addi	sp,sp,-80
 458:	e486                	sd	ra,72(sp)
 45a:	e0a2                	sd	s0,64(sp)
 45c:	fc26                	sd	s1,56(sp)
 45e:	f84a                	sd	s2,48(sp)
 460:	f44e                	sd	s3,40(sp)
 462:	0880                	addi	s0,sp,80
 464:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 466:	c299                	beqz	a3,46c <printint+0x16>
 468:	0805c163          	bltz	a1,4ea <printint+0x94>
  neg = 0;
 46c:	4881                	li	a7,0
 46e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 472:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 474:	00000517          	auipc	a0,0x0
 478:	53450513          	addi	a0,a0,1332 # 9a8 <digits>
 47c:	883e                	mv	a6,a5
 47e:	2785                	addiw	a5,a5,1
 480:	02c5f733          	remu	a4,a1,a2
 484:	972a                	add	a4,a4,a0
 486:	00074703          	lbu	a4,0(a4)
 48a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 48e:	872e                	mv	a4,a1
 490:	02c5d5b3          	divu	a1,a1,a2
 494:	0685                	addi	a3,a3,1
 496:	fec773e3          	bgeu	a4,a2,47c <printint+0x26>
  if(neg)
 49a:	00088b63          	beqz	a7,4b0 <printint+0x5a>
    buf[i++] = '-';
 49e:	fd040713          	addi	a4,s0,-48
 4a2:	97ba                	add	a5,a5,a4
 4a4:	02d00713          	li	a4,45
 4a8:	fee78423          	sb	a4,-24(a5)
 4ac:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b0:	02f05663          	blez	a5,4dc <printint+0x86>
 4b4:	fb840713          	addi	a4,s0,-72
 4b8:	00f704b3          	add	s1,a4,a5
 4bc:	fff70993          	addi	s3,a4,-1
 4c0:	99be                	add	s3,s3,a5
 4c2:	37fd                	addiw	a5,a5,-1
 4c4:	1782                	slli	a5,a5,0x20
 4c6:	9381                	srli	a5,a5,0x20
 4c8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4cc:	fff4c583          	lbu	a1,-1(s1)
 4d0:	854a                	mv	a0,s2
 4d2:	f67ff0ef          	jal	ra,438 <putc>
  while(--i >= 0)
 4d6:	14fd                	addi	s1,s1,-1
 4d8:	ff349ae3          	bne	s1,s3,4cc <printint+0x76>
}
 4dc:	60a6                	ld	ra,72(sp)
 4de:	6406                	ld	s0,64(sp)
 4e0:	74e2                	ld	s1,56(sp)
 4e2:	7942                	ld	s2,48(sp)
 4e4:	79a2                	ld	s3,40(sp)
 4e6:	6161                	addi	sp,sp,80
 4e8:	8082                	ret
    x = -xx;
 4ea:	40b005b3          	neg	a1,a1
    neg = 1;
 4ee:	4885                	li	a7,1
    x = -xx;
 4f0:	bfbd                	j	46e <printint+0x18>

00000000000004f2 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f2:	7119                	addi	sp,sp,-128
 4f4:	fc86                	sd	ra,120(sp)
 4f6:	f8a2                	sd	s0,112(sp)
 4f8:	f4a6                	sd	s1,104(sp)
 4fa:	f0ca                	sd	s2,96(sp)
 4fc:	ecce                	sd	s3,88(sp)
 4fe:	e8d2                	sd	s4,80(sp)
 500:	e4d6                	sd	s5,72(sp)
 502:	e0da                	sd	s6,64(sp)
 504:	fc5e                	sd	s7,56(sp)
 506:	f862                	sd	s8,48(sp)
 508:	f466                	sd	s9,40(sp)
 50a:	f06a                	sd	s10,32(sp)
 50c:	ec6e                	sd	s11,24(sp)
 50e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 510:	0005c903          	lbu	s2,0(a1)
 514:	24090c63          	beqz	s2,76c <vprintf+0x27a>
 518:	8b2a                	mv	s6,a0
 51a:	8a2e                	mv	s4,a1
 51c:	8bb2                	mv	s7,a2
  state = 0;
 51e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 520:	4481                	li	s1,0
 522:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 524:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 528:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 52c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 530:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 534:	00000c97          	auipc	s9,0x0
 538:	474c8c93          	addi	s9,s9,1140 # 9a8 <digits>
 53c:	a005                	j	55c <vprintf+0x6a>
        putc(fd, c0);
 53e:	85ca                	mv	a1,s2
 540:	855a                	mv	a0,s6
 542:	ef7ff0ef          	jal	ra,438 <putc>
 546:	a019                	j	54c <vprintf+0x5a>
    } else if(state == '%'){
 548:	03598263          	beq	s3,s5,56c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 54c:	2485                	addiw	s1,s1,1
 54e:	8726                	mv	a4,s1
 550:	009a07b3          	add	a5,s4,s1
 554:	0007c903          	lbu	s2,0(a5)
 558:	20090a63          	beqz	s2,76c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 55c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 560:	fe0994e3          	bnez	s3,548 <vprintf+0x56>
      if(c0 == '%'){
 564:	fd579de3          	bne	a5,s5,53e <vprintf+0x4c>
        state = '%';
 568:	89be                	mv	s3,a5
 56a:	b7cd                	j	54c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 56c:	c3c1                	beqz	a5,5ec <vprintf+0xfa>
 56e:	00ea06b3          	add	a3,s4,a4
 572:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 576:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 578:	c681                	beqz	a3,580 <vprintf+0x8e>
 57a:	9752                	add	a4,a4,s4
 57c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 580:	03878e63          	beq	a5,s8,5bc <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 584:	05a78863          	beq	a5,s10,5d4 <vprintf+0xe2>
      } else if(c0 == 'u'){
 588:	0db78b63          	beq	a5,s11,65e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 58c:	07800713          	li	a4,120
 590:	10e78d63          	beq	a5,a4,6aa <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 594:	07000713          	li	a4,112
 598:	14e78263          	beq	a5,a4,6dc <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 59c:	06300713          	li	a4,99
 5a0:	16e78f63          	beq	a5,a4,71e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5a4:	07300713          	li	a4,115
 5a8:	18e78563          	beq	a5,a4,732 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ac:	05579063          	bne	a5,s5,5ec <vprintf+0xfa>
        putc(fd, '%');
 5b0:	85d6                	mv	a1,s5
 5b2:	855a                	mv	a0,s6
 5b4:	e85ff0ef          	jal	ra,438 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf49                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4685                	li	a3,1
 5c2:	4629                	li	a2,10
 5c4:	000ba583          	lw	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	e8dff0ef          	jal	ra,456 <printint>
 5ce:	8bca                	mv	s7,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bfad                	j	54c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d4:	03868663          	beq	a3,s8,600 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d8:	05a68163          	beq	a3,s10,61a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5dc:	09b68d63          	beq	a3,s11,676 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e0:	03a68f63          	beq	a3,s10,61e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5e4:	07800793          	li	a5,120
 5e8:	0cf68d63          	beq	a3,a5,6c2 <vprintf+0x1d0>
        putc(fd, '%');
 5ec:	85d6                	mv	a1,s5
 5ee:	855a                	mv	a0,s6
 5f0:	e49ff0ef          	jal	ra,438 <putc>
        putc(fd, c0);
 5f4:	85ca                	mv	a1,s2
 5f6:	855a                	mv	a0,s6
 5f8:	e41ff0ef          	jal	ra,438 <putc>
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b7b9                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 600:	008b8913          	addi	s2,s7,8
 604:	4685                	li	a3,1
 606:	4629                	li	a2,10
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	e49ff0ef          	jal	ra,456 <printint>
        i += 1;
 612:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
        i += 1;
 618:	bf15                	j	54c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61a:	03860563          	beq	a2,s8,644 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 61e:	07b60963          	beq	a2,s11,690 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 622:	07800793          	li	a5,120
 626:	fcf613e3          	bne	a2,a5,5ec <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62a:	008b8913          	addi	s2,s7,8
 62e:	4681                	li	a3,0
 630:	4641                	li	a2,16
 632:	000bb583          	ld	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	e1fff0ef          	jal	ra,456 <printint>
        i += 2;
 63c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 63e:	8bca                	mv	s7,s2
      state = 0;
 640:	4981                	li	s3,0
        i += 2;
 642:	b729                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 644:	008b8913          	addi	s2,s7,8
 648:	4685                	li	a3,1
 64a:	4629                	li	a2,10
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	e05ff0ef          	jal	ra,456 <printint>
        i += 2;
 656:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
        i += 2;
 65c:	bdc5                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 65e:	008b8913          	addi	s2,s7,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000be583          	lwu	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	debff0ef          	jal	ra,456 <printint>
 670:	8bca                	mv	s7,s2
      state = 0;
 672:	4981                	li	s3,0
 674:	bde1                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 676:	008b8913          	addi	s2,s7,8
 67a:	4681                	li	a3,0
 67c:	4629                	li	a2,10
 67e:	000bb583          	ld	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	dd3ff0ef          	jal	ra,456 <printint>
        i += 1;
 688:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
        i += 1;
 68e:	bd7d                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 690:	008b8913          	addi	s2,s7,8
 694:	4681                	li	a3,0
 696:	4629                	li	a2,10
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	db9ff0ef          	jal	ra,456 <printint>
        i += 2;
 6a2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
        i += 2;
 6a8:	b555                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000be583          	lwu	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	d9fff0ef          	jal	ra,456 <printint>
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b571                	j	54c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000bb583          	ld	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	d87ff0ef          	jal	ra,456 <printint>
        i += 1;
 6d4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
        i += 1;
 6da:	bd8d                	j	54c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6dc:	008b8793          	addi	a5,s7,8
 6e0:	f8f43423          	sd	a5,-120(s0)
 6e4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e8:	03000593          	li	a1,48
 6ec:	855a                	mv	a0,s6
 6ee:	d4bff0ef          	jal	ra,438 <putc>
  putc(fd, 'x');
 6f2:	07800593          	li	a1,120
 6f6:	855a                	mv	a0,s6
 6f8:	d41ff0ef          	jal	ra,438 <putc>
 6fc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fe:	03c9d793          	srli	a5,s3,0x3c
 702:	97e6                	add	a5,a5,s9
 704:	0007c583          	lbu	a1,0(a5)
 708:	855a                	mv	a0,s6
 70a:	d2fff0ef          	jal	ra,438 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70e:	0992                	slli	s3,s3,0x4
 710:	397d                	addiw	s2,s2,-1
 712:	fe0916e3          	bnez	s2,6fe <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 716:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bd05                	j	54c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 71e:	008b8913          	addi	s2,s7,8
 722:	000bc583          	lbu	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	d11ff0ef          	jal	ra,438 <putc>
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
 730:	bd31                	j	54c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 732:	008b8993          	addi	s3,s7,8
 736:	000bb903          	ld	s2,0(s7)
 73a:	00090f63          	beqz	s2,758 <vprintf+0x266>
        for(; *s; s++)
 73e:	00094583          	lbu	a1,0(s2)
 742:	c195                	beqz	a1,766 <vprintf+0x274>
          putc(fd, *s);
 744:	855a                	mv	a0,s6
 746:	cf3ff0ef          	jal	ra,438 <putc>
        for(; *s; s++)
 74a:	0905                	addi	s2,s2,1
 74c:	00094583          	lbu	a1,0(s2)
 750:	f9f5                	bnez	a1,744 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 752:	8bce                	mv	s7,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	bbdd                	j	54c <vprintf+0x5a>
          s = "(null)";
 758:	00000917          	auipc	s2,0x0
 75c:	24890913          	addi	s2,s2,584 # 9a0 <malloc+0x132>
        for(; *s; s++)
 760:	02800593          	li	a1,40
 764:	b7c5                	j	744 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 766:	8bce                	mv	s7,s3
      state = 0;
 768:	4981                	li	s3,0
 76a:	b3cd                	j	54c <vprintf+0x5a>
    }
  }
}
 76c:	70e6                	ld	ra,120(sp)
 76e:	7446                	ld	s0,112(sp)
 770:	74a6                	ld	s1,104(sp)
 772:	7906                	ld	s2,96(sp)
 774:	69e6                	ld	s3,88(sp)
 776:	6a46                	ld	s4,80(sp)
 778:	6aa6                	ld	s5,72(sp)
 77a:	6b06                	ld	s6,64(sp)
 77c:	7be2                	ld	s7,56(sp)
 77e:	7c42                	ld	s8,48(sp)
 780:	7ca2                	ld	s9,40(sp)
 782:	7d02                	ld	s10,32(sp)
 784:	6de2                	ld	s11,24(sp)
 786:	6109                	addi	sp,sp,128
 788:	8082                	ret

000000000000078a <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 78a:	715d                	addi	sp,sp,-80
 78c:	ec06                	sd	ra,24(sp)
 78e:	e822                	sd	s0,16(sp)
 790:	1000                	addi	s0,sp,32
 792:	e010                	sd	a2,0(s0)
 794:	e414                	sd	a3,8(s0)
 796:	e818                	sd	a4,16(s0)
 798:	ec1c                	sd	a5,24(s0)
 79a:	03043023          	sd	a6,32(s0)
 79e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a6:	8622                	mv	a2,s0
 7a8:	d4bff0ef          	jal	ra,4f2 <vprintf>
}
 7ac:	60e2                	ld	ra,24(sp)
 7ae:	6442                	ld	s0,16(sp)
 7b0:	6161                	addi	sp,sp,80
 7b2:	8082                	ret

00000000000007b4 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7b4:	711d                	addi	sp,sp,-96
 7b6:	ec06                	sd	ra,24(sp)
 7b8:	e822                	sd	s0,16(sp)
 7ba:	1000                	addi	s0,sp,32
 7bc:	e40c                	sd	a1,8(s0)
 7be:	e810                	sd	a2,16(s0)
 7c0:	ec14                	sd	a3,24(s0)
 7c2:	f018                	sd	a4,32(s0)
 7c4:	f41c                	sd	a5,40(s0)
 7c6:	03043823          	sd	a6,48(s0)
 7ca:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ce:	00840613          	addi	a2,s0,8
 7d2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d6:	85aa                	mv	a1,a0
 7d8:	4505                	li	a0,1
 7da:	d19ff0ef          	jal	ra,4f2 <vprintf>
}
 7de:	60e2                	ld	ra,24(sp)
 7e0:	6442                	ld	s0,16(sp)
 7e2:	6125                	addi	sp,sp,96
 7e4:	8082                	ret

00000000000007e6 <free>:
 *   无
 */

void
free(void *ap)
{
 7e6:	1141                	addi	sp,sp,-16
 7e8:	e422                	sd	s0,8(sp)
 7ea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7ec:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f0:	00001797          	auipc	a5,0x1
 7f4:	8107b783          	ld	a5,-2032(a5) # 1000 <freep>
 7f8:	a805                	j	828 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fa:	4618                	lw	a4,8(a2)
 7fc:	9db9                	addw	a1,a1,a4
 7fe:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 802:	6398                	ld	a4,0(a5)
 804:	6318                	ld	a4,0(a4)
 806:	fee53823          	sd	a4,-16(a0)
 80a:	a091                	j	84e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80c:	ff852703          	lw	a4,-8(a0)
 810:	9e39                	addw	a2,a2,a4
 812:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 814:	ff053703          	ld	a4,-16(a0)
 818:	e398                	sd	a4,0(a5)
 81a:	a099                	j	860 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x40>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x50>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bgeu	a5,a3,81c <free+0x36>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059713          	slli	a4,a1,0x20
 840:	9301                	srli	a4,a4,0x20
 842:	0712                	slli	a4,a4,0x4
 844:	9736                	add	a4,a4,a3
 846:	fae60ae3          	beq	a2,a4,7fa <free+0x14>
    bp->s.ptr = p->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061713          	slli	a4,a2,0x20
 854:	9301                	srli	a4,a4,0x20
 856:	0712                	slli	a4,a4,0x4
 858:	973e                	add	a4,a4,a5
 85a:	fae689e3          	beq	a3,a4,80c <free+0x26>
  } else
    p->s.ptr = bp;
 85e:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	7af73023          	sd	a5,1952(a4) # 1000 <freep>
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 86e:	7139                	addi	sp,sp,-64
 870:	fc06                	sd	ra,56(sp)
 872:	f822                	sd	s0,48(sp)
 874:	f426                	sd	s1,40(sp)
 876:	f04a                	sd	s2,32(sp)
 878:	ec4e                	sd	s3,24(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
 880:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 882:	02051493          	slli	s1,a0,0x20
 886:	9081                	srli	s1,s1,0x20
 888:	04bd                	addi	s1,s1,15
 88a:	8091                	srli	s1,s1,0x4
 88c:	0014899b          	addiw	s3,s1,1
 890:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 892:	00000517          	auipc	a0,0x0
 896:	76e53503          	ld	a0,1902(a0) # 1000 <freep>
 89a:	c515                	beqz	a0,8c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 89e:	4798                	lw	a4,8(a5)
 8a0:	02977f63          	bgeu	a4,s1,8de <malloc+0x70>
 8a4:	8a4e                	mv	s4,s3
 8a6:	0009871b          	sext.w	a4,s3
 8aa:	6685                	lui	a3,0x1
 8ac:	00d77363          	bgeu	a4,a3,8b2 <malloc+0x44>
 8b0:	6a05                	lui	s4,0x1
 8b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8b6:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8ba:	00000917          	auipc	s2,0x0
 8be:	74690913          	addi	s2,s2,1862 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8c2:	5afd                	li	s5,-1
 8c4:	a0bd                	j	932 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8c6:	00000797          	auipc	a5,0x0
 8ca:	74a78793          	addi	a5,a5,1866 # 1010 <base>
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72f73923          	sd	a5,1842(a4) # 1000 <freep>
 8d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8dc:	b7e1                	j	8a4 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8de:	02e48b63          	beq	s1,a4,914 <malloc+0xa6>
        p->s.size -= nunits;
 8e2:	4137073b          	subw	a4,a4,s3
 8e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e8:	1702                	slli	a4,a4,0x20
 8ea:	9301                	srli	a4,a4,0x20
 8ec:	0712                	slli	a4,a4,0x4
 8ee:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f0:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8f4:	00000717          	auipc	a4,0x0
 8f8:	70a73623          	sd	a0,1804(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 8fc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 900:	70e2                	ld	ra,56(sp)
 902:	7442                	ld	s0,48(sp)
 904:	74a2                	ld	s1,40(sp)
 906:	7902                	ld	s2,32(sp)
 908:	69e2                	ld	s3,24(sp)
 90a:	6a42                	ld	s4,16(sp)
 90c:	6aa2                	ld	s5,8(sp)
 90e:	6b02                	ld	s6,0(sp)
 910:	6121                	addi	sp,sp,64
 912:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 914:	6398                	ld	a4,0(a5)
 916:	e118                	sd	a4,0(a0)
 918:	bff1                	j	8f4 <malloc+0x86>
  hp->s.size = nu;
 91a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 91e:	0541                	addi	a0,a0,16
 920:	ec7ff0ef          	jal	ra,7e6 <free>
  return freep;
 924:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 928:	dd61                	beqz	a0,900 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 92c:	4798                	lw	a4,8(a5)
 92e:	fa9778e3          	bgeu	a4,s1,8de <malloc+0x70>
    if(p == freep)
 932:	00093703          	ld	a4,0(s2)
 936:	853e                	mv	a0,a5
 938:	fef719e3          	bne	a4,a5,92a <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 93c:	8552                	mv	a0,s4
 93e:	9e7ff0ef          	jal	ra,324 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 942:	fd551ce3          	bne	a0,s5,91a <malloc+0xac>
        return 0;  /* 内存分配失败 */
 946:	4501                	li	a0,0
 948:	bf65                	j	900 <malloc+0x92>
