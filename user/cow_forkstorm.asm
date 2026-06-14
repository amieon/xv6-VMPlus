
user/_cow_forkstorm:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  char *p = sbrk(4096);
   e:	6505                	lui	a0,0x1
  10:	2e2000ef          	jal	ra,2f2 <sbrk>
  if(p == (char*)-1) exit(1);
  14:	57fd                	li	a5,-1
  16:	02f50263          	beq	a0,a5,3a <main+0x3a>
  1a:	89aa                	mv	s3,a0
  p[0] = 1;
  1c:	4785                	li	a5,1
  1e:	00f50023          	sb	a5,0(a0) # 1000 <freep>

  int n = 40;
  for(int i = 0; i < n; i++){
  22:	4481                	li	s1,0
  24:	02800913          	li	s2,40
    int pid = fork();
  28:	2f6000ef          	jal	ra,31e <fork>
    if(pid < 0){
  2c:	00054a63          	bltz	a0,40 <main+0x40>
      printf("fork failed at %d\n", i);
      break;
    }
    if(pid == 0){
  30:	c131                	beqz	a0,74 <main+0x74>
  for(int i = 0; i < n; i++){
  32:	2485                	addiw	s1,s1,1
  34:	ff249ae3          	bne	s1,s2,28 <main+0x28>
  38:	a819                	j	4e <main+0x4e>
  if(p == (char*)-1) exit(1);
  3a:	4505                	li	a0,1
  3c:	2ea000ef          	jal	ra,326 <exit>
      printf("fork failed at %d\n", i);
  40:	85a6                	mv	a1,s1
  42:	00001517          	auipc	a0,0x1
  46:	8de50513          	addi	a0,a0,-1826 # 920 <malloc+0xe4>
  4a:	738000ef          	jal	ra,782 <printf>
      p[0] = (char)(i + 2);
      exit(0);
    }
  }

  while(wait(0) >= 0)
  4e:	4501                	li	a0,0
  50:	2de000ef          	jal	ra,32e <wait>
  54:	fe055de3          	bgez	a0,4e <main+0x4e>
    ;

  // 父进程应该还是原值
  if(p[0] != 1){
  58:	0009c583          	lbu	a1,0(s3)
  5c:	4785                	li	a5,1
  5e:	02f58063          	beq	a1,a5,7e <main+0x7e>
    printf("FAIL: parent p[0]=%d\n", p[0]);
  62:	00001517          	auipc	a0,0x1
  66:	8d650513          	addi	a0,a0,-1834 # 938 <malloc+0xfc>
  6a:	718000ef          	jal	ra,782 <printf>
    exit(1);
  6e:	4505                	li	a0,1
  70:	2b6000ef          	jal	ra,326 <exit>
      p[0] = (char)(i + 2);
  74:	2489                	addiw	s1,s1,2
  76:	00998023          	sb	s1,0(s3)
      exit(0);
  7a:	2ac000ef          	jal	ra,326 <exit>
  }
  printf("PASS\n");
  7e:	00001517          	auipc	a0,0x1
  82:	8d250513          	addi	a0,a0,-1838 # 950 <malloc+0x114>
  86:	6fc000ef          	jal	ra,782 <printf>
  exit(0);
  8a:	4501                	li	a0,0
  8c:	29a000ef          	jal	ra,326 <exit>

0000000000000090 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  90:	1141                	addi	sp,sp,-16
  92:	e406                	sd	ra,8(sp)
  94:	e022                	sd	s0,0(sp)
  96:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  98:	f69ff0ef          	jal	ra,0 <main>
  exit(r);
  9c:	28a000ef          	jal	ra,326 <exit>

00000000000000a0 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a6:	87aa                	mv	a5,a0
  a8:	0585                	addi	a1,a1,1
  aa:	0785                	addi	a5,a5,1
  ac:	fff5c703          	lbu	a4,-1(a1)
  b0:	fee78fa3          	sb	a4,-1(a5)
  b4:	fb75                	bnez	a4,a8 <strcpy+0x8>
    ;
  return os;
}
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret

00000000000000bc <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	cb91                	beqz	a5,da <strcmp+0x1e>
  c8:	0005c703          	lbu	a4,0(a1)
  cc:	00f71763          	bne	a4,a5,da <strcmp+0x1e>
    p++, q++;
  d0:	0505                	addi	a0,a0,1
  d2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbe5                	bnez	a5,c8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  da:	0005c503          	lbu	a0,0(a1)
}
  de:	40a7853b          	subw	a0,a5,a0
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cf91                	beqz	a5,10e <strlen+0x26>
  f4:	0505                	addi	a0,a0,1
  f6:	87aa                	mv	a5,a0
  f8:	4685                	li	a3,1
  fa:	9e89                	subw	a3,a3,a0
  fc:	00f6853b          	addw	a0,a3,a5
 100:	0785                	addi	a5,a5,1
 102:	fff7c703          	lbu	a4,-1(a5)
 106:	fb7d                	bnez	a4,fc <strlen+0x14>
    ;
  return n;
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret
  for(n = 0; s[n]; n++)
 10e:	4501                	li	a0,0
 110:	bfe5                	j	108 <strlen+0x20>

0000000000000112 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 118:	ca19                	beqz	a2,12e <memset+0x1c>
 11a:	87aa                	mv	a5,a0
 11c:	1602                	slli	a2,a2,0x20
 11e:	9201                	srli	a2,a2,0x20
 120:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 124:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 128:	0785                	addi	a5,a5,1
 12a:	fee79de3          	bne	a5,a4,124 <memset+0x12>
  }
  return dst;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb99                	beqz	a5,154 <strchr+0x20>
    if(*s == c)
 140:	00f58763          	beq	a1,a5,14e <strchr+0x1a>
  for(; *s; s++)
 144:	0505                	addi	a0,a0,1
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbfd                	bnez	a5,140 <strchr+0xc>
      return (char*)s;
  return 0;
 14c:	4501                	li	a0,0
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret
  return 0;
 154:	4501                	li	a0,0
 156:	bfe5                	j	14e <strchr+0x1a>

0000000000000158 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 158:	711d                	addi	sp,sp,-96
 15a:	ec86                	sd	ra,88(sp)
 15c:	e8a2                	sd	s0,80(sp)
 15e:	e4a6                	sd	s1,72(sp)
 160:	e0ca                	sd	s2,64(sp)
 162:	fc4e                	sd	s3,56(sp)
 164:	f852                	sd	s4,48(sp)
 166:	f456                	sd	s5,40(sp)
 168:	f05a                	sd	s6,32(sp)
 16a:	ec5e                	sd	s7,24(sp)
 16c:	1080                	addi	s0,sp,96
 16e:	8baa                	mv	s7,a0
 170:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	892a                	mv	s2,a0
 174:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 176:	4aa9                	li	s5,10
 178:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 17a:	89a6                	mv	s3,s1
 17c:	2485                	addiw	s1,s1,1
 17e:	0344d663          	bge	s1,s4,1aa <gets+0x52>
    cc = read(0, &c, 1);
 182:	4605                	li	a2,1
 184:	faf40593          	addi	a1,s0,-81
 188:	4501                	li	a0,0
 18a:	1b4000ef          	jal	ra,33e <read>
    if(cc < 1)
 18e:	00a05e63          	blez	a0,1aa <gets+0x52>
    buf[i++] = c;
 192:	faf44783          	lbu	a5,-81(s0)
 196:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 19a:	01578763          	beq	a5,s5,1a8 <gets+0x50>
 19e:	0905                	addi	s2,s2,1
 1a0:	fd679de3          	bne	a5,s6,17a <gets+0x22>
  for(i=0; i+1 < max; ){
 1a4:	89a6                	mv	s3,s1
 1a6:	a011                	j	1aa <gets+0x52>
 1a8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1aa:	99de                	add	s3,s3,s7
 1ac:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b0:	855e                	mv	a0,s7
 1b2:	60e6                	ld	ra,88(sp)
 1b4:	6446                	ld	s0,80(sp)
 1b6:	64a6                	ld	s1,72(sp)
 1b8:	6906                	ld	s2,64(sp)
 1ba:	79e2                	ld	s3,56(sp)
 1bc:	7a42                	ld	s4,48(sp)
 1be:	7aa2                	ld	s5,40(sp)
 1c0:	7b02                	ld	s6,32(sp)
 1c2:	6be2                	ld	s7,24(sp)
 1c4:	6125                	addi	sp,sp,96
 1c6:	8082                	ret

00000000000001c8 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 1c8:	1101                	addi	sp,sp,-32
 1ca:	ec06                	sd	ra,24(sp)
 1cc:	e822                	sd	s0,16(sp)
 1ce:	e426                	sd	s1,8(sp)
 1d0:	e04a                	sd	s2,0(sp)
 1d2:	1000                	addi	s0,sp,32
 1d4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d6:	4581                	li	a1,0
 1d8:	18e000ef          	jal	ra,366 <open>
  if(fd < 0)
 1dc:	02054163          	bltz	a0,1fe <stat+0x36>
 1e0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e2:	85ca                	mv	a1,s2
 1e4:	19a000ef          	jal	ra,37e <fstat>
 1e8:	892a                	mv	s2,a0
  close(fd);
 1ea:	8526                	mv	a0,s1
 1ec:	162000ef          	jal	ra,34e <close>
  return r;
}
 1f0:	854a                	mv	a0,s2
 1f2:	60e2                	ld	ra,24(sp)
 1f4:	6442                	ld	s0,16(sp)
 1f6:	64a2                	ld	s1,8(sp)
 1f8:	6902                	ld	s2,0(sp)
 1fa:	6105                	addi	sp,sp,32
 1fc:	8082                	ret
    return -1;
 1fe:	597d                	li	s2,-1
 200:	bfc5                	j	1f0 <stat+0x28>

0000000000000202 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 208:	00054603          	lbu	a2,0(a0)
 20c:	fd06079b          	addiw	a5,a2,-48
 210:	0ff7f793          	andi	a5,a5,255
 214:	4725                	li	a4,9
 216:	02f76963          	bltu	a4,a5,248 <atoi+0x46>
 21a:	86aa                	mv	a3,a0
  n = 0;
 21c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 21e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 220:	0685                	addi	a3,a3,1
 222:	0025179b          	slliw	a5,a0,0x2
 226:	9fa9                	addw	a5,a5,a0
 228:	0017979b          	slliw	a5,a5,0x1
 22c:	9fb1                	addw	a5,a5,a2
 22e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 232:	0006c603          	lbu	a2,0(a3)
 236:	fd06071b          	addiw	a4,a2,-48
 23a:	0ff77713          	andi	a4,a4,255
 23e:	fee5f1e3          	bgeu	a1,a4,220 <atoi+0x1e>
  return n;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
  n = 0;
 248:	4501                	li	a0,0
 24a:	bfe5                	j	242 <atoi+0x40>

000000000000024c <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 252:	02b57463          	bgeu	a0,a1,27a <memmove+0x2e>
    while(n-- > 0)
 256:	00c05f63          	blez	a2,274 <memmove+0x28>
 25a:	1602                	slli	a2,a2,0x20
 25c:	9201                	srli	a2,a2,0x20
 25e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 262:	872a                	mv	a4,a0
      *dst++ = *src++;
 264:	0585                	addi	a1,a1,1
 266:	0705                	addi	a4,a4,1
 268:	fff5c683          	lbu	a3,-1(a1)
 26c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 270:	fee79ae3          	bne	a5,a4,264 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
    dst += n;
 27a:	00c50733          	add	a4,a0,a2
    src += n;
 27e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 280:	fec05ae3          	blez	a2,274 <memmove+0x28>
 284:	fff6079b          	addiw	a5,a2,-1
 288:	1782                	slli	a5,a5,0x20
 28a:	9381                	srli	a5,a5,0x20
 28c:	fff7c793          	not	a5,a5
 290:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 292:	15fd                	addi	a1,a1,-1
 294:	177d                	addi	a4,a4,-1
 296:	0005c683          	lbu	a3,0(a1)
 29a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 29e:	fee79ae3          	bne	a5,a4,292 <memmove+0x46>
 2a2:	bfc9                	j	274 <memmove+0x28>

00000000000002a4 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e422                	sd	s0,8(sp)
 2a8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2aa:	ca05                	beqz	a2,2da <memcmp+0x36>
 2ac:	fff6069b          	addiw	a3,a2,-1
 2b0:	1682                	slli	a3,a3,0x20
 2b2:	9281                	srli	a3,a3,0x20
 2b4:	0685                	addi	a3,a3,1
 2b6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	0005c703          	lbu	a4,0(a1)
 2c0:	00e79863          	bne	a5,a4,2d0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c4:	0505                	addi	a0,a0,1
    p2++;
 2c6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c8:	fed518e3          	bne	a0,a3,2b8 <memcmp+0x14>
  }
  return 0;
 2cc:	4501                	li	a0,0
 2ce:	a019                	j	2d4 <memcmp+0x30>
      return *p1 - *p2;
 2d0:	40e7853b          	subw	a0,a5,a4
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
  return 0;
 2da:	4501                	li	a0,0
 2dc:	bfe5                	j	2d4 <memcmp+0x30>

00000000000002de <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e406                	sd	ra,8(sp)
 2e2:	e022                	sd	s0,0(sp)
 2e4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e6:	f67ff0ef          	jal	ra,24c <memmove>
}
 2ea:	60a2                	ld	ra,8(sp)
 2ec:	6402                	ld	s0,0(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e406                	sd	ra,8(sp)
 2f6:	e022                	sd	s0,0(sp)
 2f8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2fa:	4585                	li	a1,1
 2fc:	0b2000ef          	jal	ra,3ae <sys_sbrk>
}
 300:	60a2                	ld	ra,8(sp)
 302:	6402                	ld	s0,0(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 310:	4589                	li	a1,2
 312:	09c000ef          	jal	ra,3ae <sys_sbrk>
}
 316:	60a2                	ld	ra,8(sp)
 318:	6402                	ld	s0,0(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret

000000000000031e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 31e:	4885                	li	a7,1
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <exit>:
.global exit
exit:
 li a7, SYS_exit
 326:	4889                	li	a7,2
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <wait>:
.global wait
wait:
 li a7, SYS_wait
 32e:	488d                	li	a7,3
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 336:	4891                	li	a7,4
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <read>:
.global read
read:
 li a7, SYS_read
 33e:	4895                	li	a7,5
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <write>:
.global write
write:
 li a7, SYS_write
 346:	48c1                	li	a7,16
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <close>:
.global close
close:
 li a7, SYS_close
 34e:	48d5                	li	a7,21
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <kill>:
.global kill
kill:
 li a7, SYS_kill
 356:	4899                	li	a7,6
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <exec>:
.global exec
exec:
 li a7, SYS_exec
 35e:	489d                	li	a7,7
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <open>:
.global open
open:
 li a7, SYS_open
 366:	48bd                	li	a7,15
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 36e:	48c5                	li	a7,17
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 376:	48c9                	li	a7,18
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 37e:	48a1                	li	a7,8
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <link>:
.global link
link:
 li a7, SYS_link
 386:	48cd                	li	a7,19
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 38e:	48d1                	li	a7,20
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 396:	48a5                	li	a7,9
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <dup>:
.global dup
dup:
 li a7, SYS_dup
 39e:	48a9                	li	a7,10
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a6:	48ad                	li	a7,11
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ae:	48b1                	li	a7,12
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3b6:	48b5                	li	a7,13
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3be:	48b9                	li	a7,14
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3c6:	48d9                	li	a7,22
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3ce:	48dd                	li	a7,23
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3d6:	48e1                	li	a7,24
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3de:	48e5                	li	a7,25
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 3e6:	48e9                	li	a7,26
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3ee:	48ed                	li	a7,27
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3f6:	48f1                	li	a7,28
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3fe:	48f5                	li	a7,29
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 406:	1101                	addi	sp,sp,-32
 408:	ec06                	sd	ra,24(sp)
 40a:	e822                	sd	s0,16(sp)
 40c:	1000                	addi	s0,sp,32
 40e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 412:	4605                	li	a2,1
 414:	fef40593          	addi	a1,s0,-17
 418:	f2fff0ef          	jal	ra,346 <write>
}
 41c:	60e2                	ld	ra,24(sp)
 41e:	6442                	ld	s0,16(sp)
 420:	6105                	addi	sp,sp,32
 422:	8082                	ret

0000000000000424 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 424:	715d                	addi	sp,sp,-80
 426:	e486                	sd	ra,72(sp)
 428:	e0a2                	sd	s0,64(sp)
 42a:	fc26                	sd	s1,56(sp)
 42c:	f84a                	sd	s2,48(sp)
 42e:	f44e                	sd	s3,40(sp)
 430:	0880                	addi	s0,sp,80
 432:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 434:	c299                	beqz	a3,43a <printint+0x16>
 436:	0805c163          	bltz	a1,4b8 <printint+0x94>
  neg = 0;
 43a:	4881                	li	a7,0
 43c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 440:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 442:	00000517          	auipc	a0,0x0
 446:	51e50513          	addi	a0,a0,1310 # 960 <digits>
 44a:	883e                	mv	a6,a5
 44c:	2785                	addiw	a5,a5,1
 44e:	02c5f733          	remu	a4,a1,a2
 452:	972a                	add	a4,a4,a0
 454:	00074703          	lbu	a4,0(a4)
 458:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 45c:	872e                	mv	a4,a1
 45e:	02c5d5b3          	divu	a1,a1,a2
 462:	0685                	addi	a3,a3,1
 464:	fec773e3          	bgeu	a4,a2,44a <printint+0x26>
  if(neg)
 468:	00088b63          	beqz	a7,47e <printint+0x5a>
    buf[i++] = '-';
 46c:	fd040713          	addi	a4,s0,-48
 470:	97ba                	add	a5,a5,a4
 472:	02d00713          	li	a4,45
 476:	fee78423          	sb	a4,-24(a5)
 47a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 47e:	02f05663          	blez	a5,4aa <printint+0x86>
 482:	fb840713          	addi	a4,s0,-72
 486:	00f704b3          	add	s1,a4,a5
 48a:	fff70993          	addi	s3,a4,-1
 48e:	99be                	add	s3,s3,a5
 490:	37fd                	addiw	a5,a5,-1
 492:	1782                	slli	a5,a5,0x20
 494:	9381                	srli	a5,a5,0x20
 496:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 49a:	fff4c583          	lbu	a1,-1(s1)
 49e:	854a                	mv	a0,s2
 4a0:	f67ff0ef          	jal	ra,406 <putc>
  while(--i >= 0)
 4a4:	14fd                	addi	s1,s1,-1
 4a6:	ff349ae3          	bne	s1,s3,49a <printint+0x76>
}
 4aa:	60a6                	ld	ra,72(sp)
 4ac:	6406                	ld	s0,64(sp)
 4ae:	74e2                	ld	s1,56(sp)
 4b0:	7942                	ld	s2,48(sp)
 4b2:	79a2                	ld	s3,40(sp)
 4b4:	6161                	addi	sp,sp,80
 4b6:	8082                	ret
    x = -xx;
 4b8:	40b005b3          	neg	a1,a1
    neg = 1;
 4bc:	4885                	li	a7,1
    x = -xx;
 4be:	bfbd                	j	43c <printint+0x18>

00000000000004c0 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c0:	7119                	addi	sp,sp,-128
 4c2:	fc86                	sd	ra,120(sp)
 4c4:	f8a2                	sd	s0,112(sp)
 4c6:	f4a6                	sd	s1,104(sp)
 4c8:	f0ca                	sd	s2,96(sp)
 4ca:	ecce                	sd	s3,88(sp)
 4cc:	e8d2                	sd	s4,80(sp)
 4ce:	e4d6                	sd	s5,72(sp)
 4d0:	e0da                	sd	s6,64(sp)
 4d2:	fc5e                	sd	s7,56(sp)
 4d4:	f862                	sd	s8,48(sp)
 4d6:	f466                	sd	s9,40(sp)
 4d8:	f06a                	sd	s10,32(sp)
 4da:	ec6e                	sd	s11,24(sp)
 4dc:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4de:	0005c903          	lbu	s2,0(a1)
 4e2:	24090c63          	beqz	s2,73a <vprintf+0x27a>
 4e6:	8b2a                	mv	s6,a0
 4e8:	8a2e                	mv	s4,a1
 4ea:	8bb2                	mv	s7,a2
  state = 0;
 4ec:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ee:	4481                	li	s1,0
 4f0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4f2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4f6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4fa:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4fe:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 502:	00000c97          	auipc	s9,0x0
 506:	45ec8c93          	addi	s9,s9,1118 # 960 <digits>
 50a:	a005                	j	52a <vprintf+0x6a>
        putc(fd, c0);
 50c:	85ca                	mv	a1,s2
 50e:	855a                	mv	a0,s6
 510:	ef7ff0ef          	jal	ra,406 <putc>
 514:	a019                	j	51a <vprintf+0x5a>
    } else if(state == '%'){
 516:	03598263          	beq	s3,s5,53a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 51a:	2485                	addiw	s1,s1,1
 51c:	8726                	mv	a4,s1
 51e:	009a07b3          	add	a5,s4,s1
 522:	0007c903          	lbu	s2,0(a5)
 526:	20090a63          	beqz	s2,73a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 52a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 52e:	fe0994e3          	bnez	s3,516 <vprintf+0x56>
      if(c0 == '%'){
 532:	fd579de3          	bne	a5,s5,50c <vprintf+0x4c>
        state = '%';
 536:	89be                	mv	s3,a5
 538:	b7cd                	j	51a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 53a:	c3c1                	beqz	a5,5ba <vprintf+0xfa>
 53c:	00ea06b3          	add	a3,s4,a4
 540:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 544:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 546:	c681                	beqz	a3,54e <vprintf+0x8e>
 548:	9752                	add	a4,a4,s4
 54a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 54e:	03878e63          	beq	a5,s8,58a <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 552:	05a78863          	beq	a5,s10,5a2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 556:	0db78b63          	beq	a5,s11,62c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 55a:	07800713          	li	a4,120
 55e:	10e78d63          	beq	a5,a4,678 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 562:	07000713          	li	a4,112
 566:	14e78263          	beq	a5,a4,6aa <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 56a:	06300713          	li	a4,99
 56e:	16e78f63          	beq	a5,a4,6ec <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 572:	07300713          	li	a4,115
 576:	18e78563          	beq	a5,a4,700 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 57a:	05579063          	bne	a5,s5,5ba <vprintf+0xfa>
        putc(fd, '%');
 57e:	85d6                	mv	a1,s5
 580:	855a                	mv	a0,s6
 582:	e85ff0ef          	jal	ra,406 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 586:	4981                	li	s3,0
 588:	bf49                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 58a:	008b8913          	addi	s2,s7,8
 58e:	4685                	li	a3,1
 590:	4629                	li	a2,10
 592:	000ba583          	lw	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	e8dff0ef          	jal	ra,424 <printint>
 59c:	8bca                	mv	s7,s2
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	bfad                	j	51a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5a2:	03868663          	beq	a3,s8,5ce <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a6:	05a68163          	beq	a3,s10,5e8 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5aa:	09b68d63          	beq	a3,s11,644 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5ae:	03a68f63          	beq	a3,s10,5ec <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5b2:	07800793          	li	a5,120
 5b6:	0cf68d63          	beq	a3,a5,690 <vprintf+0x1d0>
        putc(fd, '%');
 5ba:	85d6                	mv	a1,s5
 5bc:	855a                	mv	a0,s6
 5be:	e49ff0ef          	jal	ra,406 <putc>
        putc(fd, c0);
 5c2:	85ca                	mv	a1,s2
 5c4:	855a                	mv	a0,s6
 5c6:	e41ff0ef          	jal	ra,406 <putc>
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b7b9                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4685                	li	a3,1
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e49ff0ef          	jal	ra,424 <printint>
        i += 1;
 5e0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 1;
 5e6:	bf15                	j	51a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e8:	03860563          	beq	a2,s8,612 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5ec:	07b60963          	beq	a2,s11,65e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5f0:	07800793          	li	a5,120
 5f4:	fcf613e3          	bne	a2,a5,5ba <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f8:	008b8913          	addi	s2,s7,8
 5fc:	4681                	li	a3,0
 5fe:	4641                	li	a2,16
 600:	000bb583          	ld	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	e1fff0ef          	jal	ra,424 <printint>
        i += 2;
 60a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
        i += 2;
 610:	b729                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 612:	008b8913          	addi	s2,s7,8
 616:	4685                	li	a3,1
 618:	4629                	li	a2,10
 61a:	000bb583          	ld	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	e05ff0ef          	jal	ra,424 <printint>
        i += 2;
 624:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
        i += 2;
 62a:	bdc5                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 62c:	008b8913          	addi	s2,s7,8
 630:	4681                	li	a3,0
 632:	4629                	li	a2,10
 634:	000be583          	lwu	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	debff0ef          	jal	ra,424 <printint>
 63e:	8bca                	mv	s7,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	bde1                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 644:	008b8913          	addi	s2,s7,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	dd3ff0ef          	jal	ra,424 <printint>
        i += 1;
 656:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
        i += 1;
 65c:	bd7d                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	008b8913          	addi	s2,s7,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	db9ff0ef          	jal	ra,424 <printint>
        i += 2;
 670:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
        i += 2;
 676:	b555                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4641                	li	a2,16
 680:	000be583          	lwu	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	d9fff0ef          	jal	ra,424 <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b571                	j	51a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 690:	008b8913          	addi	s2,s7,8
 694:	4681                	li	a3,0
 696:	4641                	li	a2,16
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	d87ff0ef          	jal	ra,424 <printint>
        i += 1;
 6a2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
        i += 1;
 6a8:	bd8d                	j	51a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6aa:	008b8793          	addi	a5,s7,8
 6ae:	f8f43423          	sd	a5,-120(s0)
 6b2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6b6:	03000593          	li	a1,48
 6ba:	855a                	mv	a0,s6
 6bc:	d4bff0ef          	jal	ra,406 <putc>
  putc(fd, 'x');
 6c0:	07800593          	li	a1,120
 6c4:	855a                	mv	a0,s6
 6c6:	d41ff0ef          	jal	ra,406 <putc>
 6ca:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6cc:	03c9d793          	srli	a5,s3,0x3c
 6d0:	97e6                	add	a5,a5,s9
 6d2:	0007c583          	lbu	a1,0(a5)
 6d6:	855a                	mv	a0,s6
 6d8:	d2fff0ef          	jal	ra,406 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6dc:	0992                	slli	s3,s3,0x4
 6de:	397d                	addiw	s2,s2,-1
 6e0:	fe0916e3          	bnez	s2,6cc <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6e4:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	bd05                	j	51a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6ec:	008b8913          	addi	s2,s7,8
 6f0:	000bc583          	lbu	a1,0(s7)
 6f4:	855a                	mv	a0,s6
 6f6:	d11ff0ef          	jal	ra,406 <putc>
 6fa:	8bca                	mv	s7,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bd31                	j	51a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 700:	008b8993          	addi	s3,s7,8
 704:	000bb903          	ld	s2,0(s7)
 708:	00090f63          	beqz	s2,726 <vprintf+0x266>
        for(; *s; s++)
 70c:	00094583          	lbu	a1,0(s2)
 710:	c195                	beqz	a1,734 <vprintf+0x274>
          putc(fd, *s);
 712:	855a                	mv	a0,s6
 714:	cf3ff0ef          	jal	ra,406 <putc>
        for(; *s; s++)
 718:	0905                	addi	s2,s2,1
 71a:	00094583          	lbu	a1,0(s2)
 71e:	f9f5                	bnez	a1,712 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 720:	8bce                	mv	s7,s3
      state = 0;
 722:	4981                	li	s3,0
 724:	bbdd                	j	51a <vprintf+0x5a>
          s = "(null)";
 726:	00000917          	auipc	s2,0x0
 72a:	23290913          	addi	s2,s2,562 # 958 <malloc+0x11c>
        for(; *s; s++)
 72e:	02800593          	li	a1,40
 732:	b7c5                	j	712 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 734:	8bce                	mv	s7,s3
      state = 0;
 736:	4981                	li	s3,0
 738:	b3cd                	j	51a <vprintf+0x5a>
    }
  }
}
 73a:	70e6                	ld	ra,120(sp)
 73c:	7446                	ld	s0,112(sp)
 73e:	74a6                	ld	s1,104(sp)
 740:	7906                	ld	s2,96(sp)
 742:	69e6                	ld	s3,88(sp)
 744:	6a46                	ld	s4,80(sp)
 746:	6aa6                	ld	s5,72(sp)
 748:	6b06                	ld	s6,64(sp)
 74a:	7be2                	ld	s7,56(sp)
 74c:	7c42                	ld	s8,48(sp)
 74e:	7ca2                	ld	s9,40(sp)
 750:	7d02                	ld	s10,32(sp)
 752:	6de2                	ld	s11,24(sp)
 754:	6109                	addi	sp,sp,128
 756:	8082                	ret

0000000000000758 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 758:	715d                	addi	sp,sp,-80
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	1000                	addi	s0,sp,32
 760:	e010                	sd	a2,0(s0)
 762:	e414                	sd	a3,8(s0)
 764:	e818                	sd	a4,16(s0)
 766:	ec1c                	sd	a5,24(s0)
 768:	03043023          	sd	a6,32(s0)
 76c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 774:	8622                	mv	a2,s0
 776:	d4bff0ef          	jal	ra,4c0 <vprintf>
}
 77a:	60e2                	ld	ra,24(sp)
 77c:	6442                	ld	s0,16(sp)
 77e:	6161                	addi	sp,sp,80
 780:	8082                	ret

0000000000000782 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 782:	711d                	addi	sp,sp,-96
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e40c                	sd	a1,8(s0)
 78c:	e810                	sd	a2,16(s0)
 78e:	ec14                	sd	a3,24(s0)
 790:	f018                	sd	a4,32(s0)
 792:	f41c                	sd	a5,40(s0)
 794:	03043823          	sd	a6,48(s0)
 798:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79c:	00840613          	addi	a2,s0,8
 7a0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a4:	85aa                	mv	a1,a0
 7a6:	4505                	li	a0,1
 7a8:	d19ff0ef          	jal	ra,4c0 <vprintf>
}
 7ac:	60e2                	ld	ra,24(sp)
 7ae:	6442                	ld	s0,16(sp)
 7b0:	6125                	addi	sp,sp,96
 7b2:	8082                	ret

00000000000007b4 <free>:
 *   无
 */

void
free(void *ap)
{
 7b4:	1141                	addi	sp,sp,-16
 7b6:	e422                	sd	s0,8(sp)
 7b8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7ba:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7be:	00001797          	auipc	a5,0x1
 7c2:	8427b783          	ld	a5,-1982(a5) # 1000 <freep>
 7c6:	a805                	j	7f6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c8:	4618                	lw	a4,8(a2)
 7ca:	9db9                	addw	a1,a1,a4
 7cc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d0:	6398                	ld	a4,0(a5)
 7d2:	6318                	ld	a4,0(a4)
 7d4:	fee53823          	sd	a4,-16(a0)
 7d8:	a091                	j	81c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7da:	ff852703          	lw	a4,-8(a0)
 7de:	9e39                	addw	a2,a2,a4
 7e0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7e2:	ff053703          	ld	a4,-16(a0)
 7e6:	e398                	sd	a4,0(a5)
 7e8:	a099                	j	82e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ea:	6398                	ld	a4,0(a5)
 7ec:	00e7e463          	bltu	a5,a4,7f4 <free+0x40>
 7f0:	00e6ea63          	bltu	a3,a4,804 <free+0x50>
{
 7f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f6:	fed7fae3          	bgeu	a5,a3,7ea <free+0x36>
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e6e463          	bltu	a3,a4,804 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 800:	fee7eae3          	bltu	a5,a4,7f4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 804:	ff852583          	lw	a1,-8(a0)
 808:	6390                	ld	a2,0(a5)
 80a:	02059713          	slli	a4,a1,0x20
 80e:	9301                	srli	a4,a4,0x20
 810:	0712                	slli	a4,a4,0x4
 812:	9736                	add	a4,a4,a3
 814:	fae60ae3          	beq	a2,a4,7c8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 818:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 81c:	4790                	lw	a2,8(a5)
 81e:	02061713          	slli	a4,a2,0x20
 822:	9301                	srli	a4,a4,0x20
 824:	0712                	slli	a4,a4,0x4
 826:	973e                	add	a4,a4,a5
 828:	fae689e3          	beq	a3,a4,7da <free+0x26>
  } else
    p->s.ptr = bp;
 82c:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 82e:	00000717          	auipc	a4,0x0
 832:	7cf73923          	sd	a5,2002(a4) # 1000 <freep>
}
 836:	6422                	ld	s0,8(sp)
 838:	0141                	addi	sp,sp,16
 83a:	8082                	ret

000000000000083c <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 83c:	7139                	addi	sp,sp,-64
 83e:	fc06                	sd	ra,56(sp)
 840:	f822                	sd	s0,48(sp)
 842:	f426                	sd	s1,40(sp)
 844:	f04a                	sd	s2,32(sp)
 846:	ec4e                	sd	s3,24(sp)
 848:	e852                	sd	s4,16(sp)
 84a:	e456                	sd	s5,8(sp)
 84c:	e05a                	sd	s6,0(sp)
 84e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 850:	02051493          	slli	s1,a0,0x20
 854:	9081                	srli	s1,s1,0x20
 856:	04bd                	addi	s1,s1,15
 858:	8091                	srli	s1,s1,0x4
 85a:	0014899b          	addiw	s3,s1,1
 85e:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 860:	00000517          	auipc	a0,0x0
 864:	7a053503          	ld	a0,1952(a0) # 1000 <freep>
 868:	c515                	beqz	a0,894 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 86c:	4798                	lw	a4,8(a5)
 86e:	02977f63          	bgeu	a4,s1,8ac <malloc+0x70>
 872:	8a4e                	mv	s4,s3
 874:	0009871b          	sext.w	a4,s3
 878:	6685                	lui	a3,0x1
 87a:	00d77363          	bgeu	a4,a3,880 <malloc+0x44>
 87e:	6a05                	lui	s4,0x1
 880:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 884:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 888:	00000917          	auipc	s2,0x0
 88c:	77890913          	addi	s2,s2,1912 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 890:	5afd                	li	s5,-1
 892:	a0bd                	j	900 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 894:	00000797          	auipc	a5,0x0
 898:	77c78793          	addi	a5,a5,1916 # 1010 <base>
 89c:	00000717          	auipc	a4,0x0
 8a0:	76f73223          	sd	a5,1892(a4) # 1000 <freep>
 8a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8aa:	b7e1                	j	872 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8ac:	02e48b63          	beq	s1,a4,8e2 <malloc+0xa6>
        p->s.size -= nunits;
 8b0:	4137073b          	subw	a4,a4,s3
 8b4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b6:	1702                	slli	a4,a4,0x20
 8b8:	9301                	srli	a4,a4,0x20
 8ba:	0712                	slli	a4,a4,0x4
 8bc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8be:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8c2:	00000717          	auipc	a4,0x0
 8c6:	72a73f23          	sd	a0,1854(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 8ca:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 8ce:	70e2                	ld	ra,56(sp)
 8d0:	7442                	ld	s0,48(sp)
 8d2:	74a2                	ld	s1,40(sp)
 8d4:	7902                	ld	s2,32(sp)
 8d6:	69e2                	ld	s3,24(sp)
 8d8:	6a42                	ld	s4,16(sp)
 8da:	6aa2                	ld	s5,8(sp)
 8dc:	6b02                	ld	s6,0(sp)
 8de:	6121                	addi	sp,sp,64
 8e0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e2:	6398                	ld	a4,0(a5)
 8e4:	e118                	sd	a4,0(a0)
 8e6:	bff1                	j	8c2 <malloc+0x86>
  hp->s.size = nu;
 8e8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 8ec:	0541                	addi	a0,a0,16
 8ee:	ec7ff0ef          	jal	ra,7b4 <free>
  return freep;
 8f2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f6:	dd61                	beqz	a0,8ce <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8fa:	4798                	lw	a4,8(a5)
 8fc:	fa9778e3          	bgeu	a4,s1,8ac <malloc+0x70>
    if(p == freep)
 900:	00093703          	ld	a4,0(s2)
 904:	853e                	mv	a0,a5
 906:	fef719e3          	bne	a4,a5,8f8 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 90a:	8552                	mv	a0,s4
 90c:	9e7ff0ef          	jal	ra,2f2 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 910:	fd551ce3          	bne	a0,s5,8e8 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 914:	4501                	li	a0,0
 916:	bf65                	j	8ce <malloc+0x92>
