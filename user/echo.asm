
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
 * 返回值：
 *   始终返回0表示成功执行
 */
int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  /* 遍历所有命令行参数（从索引1开始，跳过程序名） */
  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	04a7dc63          	bge	a5,a0,6a <main+0x6a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	1982                	slli	s3,s3,0x20
  20:	0209d993          	srli	s3,s3,0x20
  24:	098e                	slli	s3,s3,0x3
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    /* 输出当前参数 */
    write(1, argv[i], strlen(argv[i]));
    /* 如果不是最后一个参数，输出空格分隔符 */
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00001a17          	auipc	s4,0x1
  2e:	8d6a0a13          	addi	s4,s4,-1834 # 900 <malloc+0xe4>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	090000ef          	jal	ra,c8 <strlen>
  3c:	0005061b          	sext.w	a2,a0
  40:	85ca                	mv	a1,s2
  42:	4505                	li	a0,1
  44:	2e2000ef          	jal	ra,326 <write>
    if(i + 1 < argc){
  48:	04a1                	addi	s1,s1,8
  4a:	01348863          	beq	s1,s3,5a <main+0x5a>
      write(1, " ", 1);
  4e:	4605                	li	a2,1
  50:	85d2                	mv	a1,s4
  52:	4505                	li	a0,1
  54:	2d2000ef          	jal	ra,326 <write>
  for(i = 1; i < argc; i++){
  58:	bfe9                	j	32 <main+0x32>
    } else {
      /* 最后一个参数，输出换行符 */
      write(1, "\n", 1);
  5a:	4605                	li	a2,1
  5c:	00001597          	auipc	a1,0x1
  60:	8ac58593          	addi	a1,a1,-1876 # 908 <malloc+0xec>
  64:	4505                	li	a0,1
  66:	2c0000ef          	jal	ra,326 <write>
    }
  }
  /* 程序正常退出 */
  exit(0);
  6a:	4501                	li	a0,0
  6c:	29a000ef          	jal	ra,306 <exit>

0000000000000070 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  70:	1141                	addi	sp,sp,-16
  72:	e406                	sd	ra,8(sp)
  74:	e022                	sd	s0,0(sp)
  76:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  78:	f89ff0ef          	jal	ra,0 <main>
  exit(r);
  7c:	28a000ef          	jal	ra,306 <exit>

0000000000000080 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  80:	1141                	addi	sp,sp,-16
  82:	e422                	sd	s0,8(sp)
  84:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  86:	87aa                	mv	a5,a0
  88:	0585                	addi	a1,a1,1
  8a:	0785                	addi	a5,a5,1
  8c:	fff5c703          	lbu	a4,-1(a1)
  90:	fee78fa3          	sb	a4,-1(a5)
  94:	fb75                	bnez	a4,88 <strcpy+0x8>
    ;
  return os;
}
  96:	6422                	ld	s0,8(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret

000000000000009c <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a2:	00054783          	lbu	a5,0(a0)
  a6:	cb91                	beqz	a5,ba <strcmp+0x1e>
  a8:	0005c703          	lbu	a4,0(a1)
  ac:	00f71763          	bne	a4,a5,ba <strcmp+0x1e>
    p++, q++;
  b0:	0505                	addi	a0,a0,1
  b2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b4:	00054783          	lbu	a5,0(a0)
  b8:	fbe5                	bnez	a5,a8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ba:	0005c503          	lbu	a0,0(a1)
}
  be:	40a7853b          	subw	a0,a5,a0
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret

00000000000000c8 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	cf91                	beqz	a5,ee <strlen+0x26>
  d4:	0505                	addi	a0,a0,1
  d6:	87aa                	mv	a5,a0
  d8:	4685                	li	a3,1
  da:	9e89                	subw	a3,a3,a0
  dc:	00f6853b          	addw	a0,a3,a5
  e0:	0785                	addi	a5,a5,1
  e2:	fff7c703          	lbu	a4,-1(a5)
  e6:	fb7d                	bnez	a4,dc <strlen+0x14>
    ;
  return n;
}
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret
  for(n = 0; s[n]; n++)
  ee:	4501                	li	a0,0
  f0:	bfe5                	j	e8 <strlen+0x20>

00000000000000f2 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f8:	ca19                	beqz	a2,10e <memset+0x1c>
  fa:	87aa                	mv	a5,a0
  fc:	1602                	slli	a2,a2,0x20
  fe:	9201                	srli	a2,a2,0x20
 100:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 104:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 108:	0785                	addi	a5,a5,1
 10a:	fee79de3          	bne	a5,a4,104 <memset+0x12>
  }
  return dst;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb99                	beqz	a5,134 <strchr+0x20>
    if(*s == c)
 120:	00f58763          	beq	a1,a5,12e <strchr+0x1a>
  for(; *s; s++)
 124:	0505                	addi	a0,a0,1
 126:	00054783          	lbu	a5,0(a0)
 12a:	fbfd                	bnez	a5,120 <strchr+0xc>
      return (char*)s;
  return 0;
 12c:	4501                	li	a0,0
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret
  return 0;
 134:	4501                	li	a0,0
 136:	bfe5                	j	12e <strchr+0x1a>

0000000000000138 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 138:	711d                	addi	sp,sp,-96
 13a:	ec86                	sd	ra,88(sp)
 13c:	e8a2                	sd	s0,80(sp)
 13e:	e4a6                	sd	s1,72(sp)
 140:	e0ca                	sd	s2,64(sp)
 142:	fc4e                	sd	s3,56(sp)
 144:	f852                	sd	s4,48(sp)
 146:	f456                	sd	s5,40(sp)
 148:	f05a                	sd	s6,32(sp)
 14a:	ec5e                	sd	s7,24(sp)
 14c:	1080                	addi	s0,sp,96
 14e:	8baa                	mv	s7,a0
 150:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 152:	892a                	mv	s2,a0
 154:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 156:	4aa9                	li	s5,10
 158:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15a:	89a6                	mv	s3,s1
 15c:	2485                	addiw	s1,s1,1
 15e:	0344d663          	bge	s1,s4,18a <gets+0x52>
    cc = read(0, &c, 1);
 162:	4605                	li	a2,1
 164:	faf40593          	addi	a1,s0,-81
 168:	4501                	li	a0,0
 16a:	1b4000ef          	jal	ra,31e <read>
    if(cc < 1)
 16e:	00a05e63          	blez	a0,18a <gets+0x52>
    buf[i++] = c;
 172:	faf44783          	lbu	a5,-81(s0)
 176:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17a:	01578763          	beq	a5,s5,188 <gets+0x50>
 17e:	0905                	addi	s2,s2,1
 180:	fd679de3          	bne	a5,s6,15a <gets+0x22>
  for(i=0; i+1 < max; ){
 184:	89a6                	mv	s3,s1
 186:	a011                	j	18a <gets+0x52>
 188:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18a:	99de                	add	s3,s3,s7
 18c:	00098023          	sb	zero,0(s3)
  return buf;
}
 190:	855e                	mv	a0,s7
 192:	60e6                	ld	ra,88(sp)
 194:	6446                	ld	s0,80(sp)
 196:	64a6                	ld	s1,72(sp)
 198:	6906                	ld	s2,64(sp)
 19a:	79e2                	ld	s3,56(sp)
 19c:	7a42                	ld	s4,48(sp)
 19e:	7aa2                	ld	s5,40(sp)
 1a0:	7b02                	ld	s6,32(sp)
 1a2:	6be2                	ld	s7,24(sp)
 1a4:	6125                	addi	sp,sp,96
 1a6:	8082                	ret

00000000000001a8 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 1a8:	1101                	addi	sp,sp,-32
 1aa:	ec06                	sd	ra,24(sp)
 1ac:	e822                	sd	s0,16(sp)
 1ae:	e426                	sd	s1,8(sp)
 1b0:	e04a                	sd	s2,0(sp)
 1b2:	1000                	addi	s0,sp,32
 1b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b6:	4581                	li	a1,0
 1b8:	18e000ef          	jal	ra,346 <open>
  if(fd < 0)
 1bc:	02054163          	bltz	a0,1de <stat+0x36>
 1c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c2:	85ca                	mv	a1,s2
 1c4:	19a000ef          	jal	ra,35e <fstat>
 1c8:	892a                	mv	s2,a0
  close(fd);
 1ca:	8526                	mv	a0,s1
 1cc:	162000ef          	jal	ra,32e <close>
  return r;
}
 1d0:	854a                	mv	a0,s2
 1d2:	60e2                	ld	ra,24(sp)
 1d4:	6442                	ld	s0,16(sp)
 1d6:	64a2                	ld	s1,8(sp)
 1d8:	6902                	ld	s2,0(sp)
 1da:	6105                	addi	sp,sp,32
 1dc:	8082                	ret
    return -1;
 1de:	597d                	li	s2,-1
 1e0:	bfc5                	j	1d0 <stat+0x28>

00000000000001e2 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1e8:	00054603          	lbu	a2,0(a0)
 1ec:	fd06079b          	addiw	a5,a2,-48
 1f0:	0ff7f793          	andi	a5,a5,255
 1f4:	4725                	li	a4,9
 1f6:	02f76963          	bltu	a4,a5,228 <atoi+0x46>
 1fa:	86aa                	mv	a3,a0
  n = 0;
 1fc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1fe:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 200:	0685                	addi	a3,a3,1
 202:	0025179b          	slliw	a5,a0,0x2
 206:	9fa9                	addw	a5,a5,a0
 208:	0017979b          	slliw	a5,a5,0x1
 20c:	9fb1                	addw	a5,a5,a2
 20e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 212:	0006c603          	lbu	a2,0(a3)
 216:	fd06071b          	addiw	a4,a2,-48
 21a:	0ff77713          	andi	a4,a4,255
 21e:	fee5f1e3          	bgeu	a1,a4,200 <atoi+0x1e>
  return n;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
  n = 0;
 228:	4501                	li	a0,0
 22a:	bfe5                	j	222 <atoi+0x40>

000000000000022c <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 232:	02b57463          	bgeu	a0,a1,25a <memmove+0x2e>
    while(n-- > 0)
 236:	00c05f63          	blez	a2,254 <memmove+0x28>
 23a:	1602                	slli	a2,a2,0x20
 23c:	9201                	srli	a2,a2,0x20
 23e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 242:	872a                	mv	a4,a0
      *dst++ = *src++;
 244:	0585                	addi	a1,a1,1
 246:	0705                	addi	a4,a4,1
 248:	fff5c683          	lbu	a3,-1(a1)
 24c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 250:	fee79ae3          	bne	a5,a4,244 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
    dst += n;
 25a:	00c50733          	add	a4,a0,a2
    src += n;
 25e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 260:	fec05ae3          	blez	a2,254 <memmove+0x28>
 264:	fff6079b          	addiw	a5,a2,-1
 268:	1782                	slli	a5,a5,0x20
 26a:	9381                	srli	a5,a5,0x20
 26c:	fff7c793          	not	a5,a5
 270:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 272:	15fd                	addi	a1,a1,-1
 274:	177d                	addi	a4,a4,-1
 276:	0005c683          	lbu	a3,0(a1)
 27a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 27e:	fee79ae3          	bne	a5,a4,272 <memmove+0x46>
 282:	bfc9                	j	254 <memmove+0x28>

0000000000000284 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 28a:	ca05                	beqz	a2,2ba <memcmp+0x36>
 28c:	fff6069b          	addiw	a3,a2,-1
 290:	1682                	slli	a3,a3,0x20
 292:	9281                	srli	a3,a3,0x20
 294:	0685                	addi	a3,a3,1
 296:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 298:	00054783          	lbu	a5,0(a0)
 29c:	0005c703          	lbu	a4,0(a1)
 2a0:	00e79863          	bne	a5,a4,2b0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2a4:	0505                	addi	a0,a0,1
    p2++;
 2a6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2a8:	fed518e3          	bne	a0,a3,298 <memcmp+0x14>
  }
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	a019                	j	2b4 <memcmp+0x30>
      return *p1 - *p2;
 2b0:	40e7853b          	subw	a0,a5,a4
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
  return 0;
 2ba:	4501                	li	a0,0
 2bc:	bfe5                	j	2b4 <memcmp+0x30>

00000000000002be <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e406                	sd	ra,8(sp)
 2c2:	e022                	sd	s0,0(sp)
 2c4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2c6:	f67ff0ef          	jal	ra,22c <memmove>
}
 2ca:	60a2                	ld	ra,8(sp)
 2cc:	6402                	ld	s0,0(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2da:	4585                	li	a1,1
 2dc:	0b2000ef          	jal	ra,38e <sys_sbrk>
}
 2e0:	60a2                	ld	ra,8(sp)
 2e2:	6402                	ld	s0,0(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret

00000000000002e8 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2f0:	4589                	li	a1,2
 2f2:	09c000ef          	jal	ra,38e <sys_sbrk>
}
 2f6:	60a2                	ld	ra,8(sp)
 2f8:	6402                	ld	s0,0(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret

00000000000002fe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2fe:	4885                	li	a7,1
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <exit>:
.global exit
exit:
 li a7, SYS_exit
 306:	4889                	li	a7,2
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <wait>:
.global wait
wait:
 li a7, SYS_wait
 30e:	488d                	li	a7,3
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 316:	4891                	li	a7,4
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <read>:
.global read
read:
 li a7, SYS_read
 31e:	4895                	li	a7,5
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <write>:
.global write
write:
 li a7, SYS_write
 326:	48c1                	li	a7,16
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <close>:
.global close
close:
 li a7, SYS_close
 32e:	48d5                	li	a7,21
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <kill>:
.global kill
kill:
 li a7, SYS_kill
 336:	4899                	li	a7,6
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <exec>:
.global exec
exec:
 li a7, SYS_exec
 33e:	489d                	li	a7,7
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <open>:
.global open
open:
 li a7, SYS_open
 346:	48bd                	li	a7,15
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 34e:	48c5                	li	a7,17
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 356:	48c9                	li	a7,18
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 35e:	48a1                	li	a7,8
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <link>:
.global link
link:
 li a7, SYS_link
 366:	48cd                	li	a7,19
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 36e:	48d1                	li	a7,20
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 376:	48a5                	li	a7,9
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <dup>:
.global dup
dup:
 li a7, SYS_dup
 37e:	48a9                	li	a7,10
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 386:	48ad                	li	a7,11
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 38e:	48b1                	li	a7,12
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <pause>:
.global pause
pause:
 li a7, SYS_pause
 396:	48b5                	li	a7,13
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 39e:	48b9                	li	a7,14
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3a6:	48d9                	li	a7,22
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3ae:	48dd                	li	a7,23
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3b6:	48e1                	li	a7,24
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3be:	48e5                	li	a7,25
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 3c6:	48e9                	li	a7,26
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3ce:	48ed                	li	a7,27
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3d6:	48f1                	li	a7,28
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3de:	48f5                	li	a7,29
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 3e6:	1101                	addi	sp,sp,-32
 3e8:	ec06                	sd	ra,24(sp)
 3ea:	e822                	sd	s0,16(sp)
 3ec:	1000                	addi	s0,sp,32
 3ee:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f2:	4605                	li	a2,1
 3f4:	fef40593          	addi	a1,s0,-17
 3f8:	f2fff0ef          	jal	ra,326 <write>
}
 3fc:	60e2                	ld	ra,24(sp)
 3fe:	6442                	ld	s0,16(sp)
 400:	6105                	addi	sp,sp,32
 402:	8082                	ret

0000000000000404 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 404:	715d                	addi	sp,sp,-80
 406:	e486                	sd	ra,72(sp)
 408:	e0a2                	sd	s0,64(sp)
 40a:	fc26                	sd	s1,56(sp)
 40c:	f84a                	sd	s2,48(sp)
 40e:	f44e                	sd	s3,40(sp)
 410:	0880                	addi	s0,sp,80
 412:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 414:	c299                	beqz	a3,41a <printint+0x16>
 416:	0805c163          	bltz	a1,498 <printint+0x94>
  neg = 0;
 41a:	4881                	li	a7,0
 41c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 420:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 422:	00000517          	auipc	a0,0x0
 426:	4f650513          	addi	a0,a0,1270 # 918 <digits>
 42a:	883e                	mv	a6,a5
 42c:	2785                	addiw	a5,a5,1
 42e:	02c5f733          	remu	a4,a1,a2
 432:	972a                	add	a4,a4,a0
 434:	00074703          	lbu	a4,0(a4)
 438:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 43c:	872e                	mv	a4,a1
 43e:	02c5d5b3          	divu	a1,a1,a2
 442:	0685                	addi	a3,a3,1
 444:	fec773e3          	bgeu	a4,a2,42a <printint+0x26>
  if(neg)
 448:	00088b63          	beqz	a7,45e <printint+0x5a>
    buf[i++] = '-';
 44c:	fd040713          	addi	a4,s0,-48
 450:	97ba                	add	a5,a5,a4
 452:	02d00713          	li	a4,45
 456:	fee78423          	sb	a4,-24(a5)
 45a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 45e:	02f05663          	blez	a5,48a <printint+0x86>
 462:	fb840713          	addi	a4,s0,-72
 466:	00f704b3          	add	s1,a4,a5
 46a:	fff70993          	addi	s3,a4,-1
 46e:	99be                	add	s3,s3,a5
 470:	37fd                	addiw	a5,a5,-1
 472:	1782                	slli	a5,a5,0x20
 474:	9381                	srli	a5,a5,0x20
 476:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 47a:	fff4c583          	lbu	a1,-1(s1)
 47e:	854a                	mv	a0,s2
 480:	f67ff0ef          	jal	ra,3e6 <putc>
  while(--i >= 0)
 484:	14fd                	addi	s1,s1,-1
 486:	ff349ae3          	bne	s1,s3,47a <printint+0x76>
}
 48a:	60a6                	ld	ra,72(sp)
 48c:	6406                	ld	s0,64(sp)
 48e:	74e2                	ld	s1,56(sp)
 490:	7942                	ld	s2,48(sp)
 492:	79a2                	ld	s3,40(sp)
 494:	6161                	addi	sp,sp,80
 496:	8082                	ret
    x = -xx;
 498:	40b005b3          	neg	a1,a1
    neg = 1;
 49c:	4885                	li	a7,1
    x = -xx;
 49e:	bfbd                	j	41c <printint+0x18>

00000000000004a0 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a0:	7119                	addi	sp,sp,-128
 4a2:	fc86                	sd	ra,120(sp)
 4a4:	f8a2                	sd	s0,112(sp)
 4a6:	f4a6                	sd	s1,104(sp)
 4a8:	f0ca                	sd	s2,96(sp)
 4aa:	ecce                	sd	s3,88(sp)
 4ac:	e8d2                	sd	s4,80(sp)
 4ae:	e4d6                	sd	s5,72(sp)
 4b0:	e0da                	sd	s6,64(sp)
 4b2:	fc5e                	sd	s7,56(sp)
 4b4:	f862                	sd	s8,48(sp)
 4b6:	f466                	sd	s9,40(sp)
 4b8:	f06a                	sd	s10,32(sp)
 4ba:	ec6e                	sd	s11,24(sp)
 4bc:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4be:	0005c903          	lbu	s2,0(a1)
 4c2:	24090c63          	beqz	s2,71a <vprintf+0x27a>
 4c6:	8b2a                	mv	s6,a0
 4c8:	8a2e                	mv	s4,a1
 4ca:	8bb2                	mv	s7,a2
  state = 0;
 4cc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ce:	4481                	li	s1,0
 4d0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4d2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4d6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4da:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4de:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4e2:	00000c97          	auipc	s9,0x0
 4e6:	436c8c93          	addi	s9,s9,1078 # 918 <digits>
 4ea:	a005                	j	50a <vprintf+0x6a>
        putc(fd, c0);
 4ec:	85ca                	mv	a1,s2
 4ee:	855a                	mv	a0,s6
 4f0:	ef7ff0ef          	jal	ra,3e6 <putc>
 4f4:	a019                	j	4fa <vprintf+0x5a>
    } else if(state == '%'){
 4f6:	03598263          	beq	s3,s5,51a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4fa:	2485                	addiw	s1,s1,1
 4fc:	8726                	mv	a4,s1
 4fe:	009a07b3          	add	a5,s4,s1
 502:	0007c903          	lbu	s2,0(a5)
 506:	20090a63          	beqz	s2,71a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 50a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 50e:	fe0994e3          	bnez	s3,4f6 <vprintf+0x56>
      if(c0 == '%'){
 512:	fd579de3          	bne	a5,s5,4ec <vprintf+0x4c>
        state = '%';
 516:	89be                	mv	s3,a5
 518:	b7cd                	j	4fa <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 51a:	c3c1                	beqz	a5,59a <vprintf+0xfa>
 51c:	00ea06b3          	add	a3,s4,a4
 520:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 524:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 526:	c681                	beqz	a3,52e <vprintf+0x8e>
 528:	9752                	add	a4,a4,s4
 52a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 52e:	03878e63          	beq	a5,s8,56a <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 532:	05a78863          	beq	a5,s10,582 <vprintf+0xe2>
      } else if(c0 == 'u'){
 536:	0db78b63          	beq	a5,s11,60c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 53a:	07800713          	li	a4,120
 53e:	10e78d63          	beq	a5,a4,658 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 542:	07000713          	li	a4,112
 546:	14e78263          	beq	a5,a4,68a <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 54a:	06300713          	li	a4,99
 54e:	16e78f63          	beq	a5,a4,6cc <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 552:	07300713          	li	a4,115
 556:	18e78563          	beq	a5,a4,6e0 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 55a:	05579063          	bne	a5,s5,59a <vprintf+0xfa>
        putc(fd, '%');
 55e:	85d6                	mv	a1,s5
 560:	855a                	mv	a0,s6
 562:	e85ff0ef          	jal	ra,3e6 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 566:	4981                	li	s3,0
 568:	bf49                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 56a:	008b8913          	addi	s2,s7,8
 56e:	4685                	li	a3,1
 570:	4629                	li	a2,10
 572:	000ba583          	lw	a1,0(s7)
 576:	855a                	mv	a0,s6
 578:	e8dff0ef          	jal	ra,404 <printint>
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	bfad                	j	4fa <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 582:	03868663          	beq	a3,s8,5ae <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 586:	05a68163          	beq	a3,s10,5c8 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 58a:	09b68d63          	beq	a3,s11,624 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 58e:	03a68f63          	beq	a3,s10,5cc <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 592:	07800793          	li	a5,120
 596:	0cf68d63          	beq	a3,a5,670 <vprintf+0x1d0>
        putc(fd, '%');
 59a:	85d6                	mv	a1,s5
 59c:	855a                	mv	a0,s6
 59e:	e49ff0ef          	jal	ra,3e6 <putc>
        putc(fd, c0);
 5a2:	85ca                	mv	a1,s2
 5a4:	855a                	mv	a0,s6
 5a6:	e41ff0ef          	jal	ra,3e6 <putc>
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b7b9                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ae:	008b8913          	addi	s2,s7,8
 5b2:	4685                	li	a3,1
 5b4:	4629                	li	a2,10
 5b6:	000bb583          	ld	a1,0(s7)
 5ba:	855a                	mv	a0,s6
 5bc:	e49ff0ef          	jal	ra,404 <printint>
        i += 1;
 5c0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c2:	8bca                	mv	s7,s2
      state = 0;
 5c4:	4981                	li	s3,0
        i += 1;
 5c6:	bf15                	j	4fa <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c8:	03860563          	beq	a2,s8,5f2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5cc:	07b60963          	beq	a2,s11,63e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5d0:	07800793          	li	a5,120
 5d4:	fcf613e3          	bne	a2,a5,59a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	4681                	li	a3,0
 5de:	4641                	li	a2,16
 5e0:	000bb583          	ld	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	e1fff0ef          	jal	ra,404 <printint>
        i += 2;
 5ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
        i += 2;
 5f0:	b729                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000bb583          	ld	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	e05ff0ef          	jal	ra,404 <printint>
        i += 2;
 604:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
        i += 2;
 60a:	bdc5                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4629                	li	a2,10
 614:	000be583          	lwu	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	debff0ef          	jal	ra,404 <printint>
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bde1                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 624:	008b8913          	addi	s2,s7,8
 628:	4681                	li	a3,0
 62a:	4629                	li	a2,10
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	dd3ff0ef          	jal	ra,404 <printint>
        i += 1;
 636:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
        i += 1;
 63c:	bd7d                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63e:	008b8913          	addi	s2,s7,8
 642:	4681                	li	a3,0
 644:	4629                	li	a2,10
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	db9ff0ef          	jal	ra,404 <printint>
        i += 2;
 650:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
        i += 2;
 656:	b555                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000be583          	lwu	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	d9fff0ef          	jal	ra,404 <printint>
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b571                	j	4fa <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 670:	008b8913          	addi	s2,s7,8
 674:	4681                	li	a3,0
 676:	4641                	li	a2,16
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	d87ff0ef          	jal	ra,404 <printint>
        i += 1;
 682:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 1;
 688:	bd8d                	j	4fa <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 68a:	008b8793          	addi	a5,s7,8
 68e:	f8f43423          	sd	a5,-120(s0)
 692:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 696:	03000593          	li	a1,48
 69a:	855a                	mv	a0,s6
 69c:	d4bff0ef          	jal	ra,3e6 <putc>
  putc(fd, 'x');
 6a0:	07800593          	li	a1,120
 6a4:	855a                	mv	a0,s6
 6a6:	d41ff0ef          	jal	ra,3e6 <putc>
 6aa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ac:	03c9d793          	srli	a5,s3,0x3c
 6b0:	97e6                	add	a5,a5,s9
 6b2:	0007c583          	lbu	a1,0(a5)
 6b6:	855a                	mv	a0,s6
 6b8:	d2fff0ef          	jal	ra,3e6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6bc:	0992                	slli	s3,s3,0x4
 6be:	397d                	addiw	s2,s2,-1
 6c0:	fe0916e3          	bnez	s2,6ac <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6c4:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bd05                	j	4fa <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	000bc583          	lbu	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	d11ff0ef          	jal	ra,3e6 <putc>
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bd31                	j	4fa <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6e0:	008b8993          	addi	s3,s7,8
 6e4:	000bb903          	ld	s2,0(s7)
 6e8:	00090f63          	beqz	s2,706 <vprintf+0x266>
        for(; *s; s++)
 6ec:	00094583          	lbu	a1,0(s2)
 6f0:	c195                	beqz	a1,714 <vprintf+0x274>
          putc(fd, *s);
 6f2:	855a                	mv	a0,s6
 6f4:	cf3ff0ef          	jal	ra,3e6 <putc>
        for(; *s; s++)
 6f8:	0905                	addi	s2,s2,1
 6fa:	00094583          	lbu	a1,0(s2)
 6fe:	f9f5                	bnez	a1,6f2 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 700:	8bce                	mv	s7,s3
      state = 0;
 702:	4981                	li	s3,0
 704:	bbdd                	j	4fa <vprintf+0x5a>
          s = "(null)";
 706:	00000917          	auipc	s2,0x0
 70a:	20a90913          	addi	s2,s2,522 # 910 <malloc+0xf4>
        for(; *s; s++)
 70e:	02800593          	li	a1,40
 712:	b7c5                	j	6f2 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 714:	8bce                	mv	s7,s3
      state = 0;
 716:	4981                	li	s3,0
 718:	b3cd                	j	4fa <vprintf+0x5a>
    }
  }
}
 71a:	70e6                	ld	ra,120(sp)
 71c:	7446                	ld	s0,112(sp)
 71e:	74a6                	ld	s1,104(sp)
 720:	7906                	ld	s2,96(sp)
 722:	69e6                	ld	s3,88(sp)
 724:	6a46                	ld	s4,80(sp)
 726:	6aa6                	ld	s5,72(sp)
 728:	6b06                	ld	s6,64(sp)
 72a:	7be2                	ld	s7,56(sp)
 72c:	7c42                	ld	s8,48(sp)
 72e:	7ca2                	ld	s9,40(sp)
 730:	7d02                	ld	s10,32(sp)
 732:	6de2                	ld	s11,24(sp)
 734:	6109                	addi	sp,sp,128
 736:	8082                	ret

0000000000000738 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 738:	715d                	addi	sp,sp,-80
 73a:	ec06                	sd	ra,24(sp)
 73c:	e822                	sd	s0,16(sp)
 73e:	1000                	addi	s0,sp,32
 740:	e010                	sd	a2,0(s0)
 742:	e414                	sd	a3,8(s0)
 744:	e818                	sd	a4,16(s0)
 746:	ec1c                	sd	a5,24(s0)
 748:	03043023          	sd	a6,32(s0)
 74c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 750:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 754:	8622                	mv	a2,s0
 756:	d4bff0ef          	jal	ra,4a0 <vprintf>
}
 75a:	60e2                	ld	ra,24(sp)
 75c:	6442                	ld	s0,16(sp)
 75e:	6161                	addi	sp,sp,80
 760:	8082                	ret

0000000000000762 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 762:	711d                	addi	sp,sp,-96
 764:	ec06                	sd	ra,24(sp)
 766:	e822                	sd	s0,16(sp)
 768:	1000                	addi	s0,sp,32
 76a:	e40c                	sd	a1,8(s0)
 76c:	e810                	sd	a2,16(s0)
 76e:	ec14                	sd	a3,24(s0)
 770:	f018                	sd	a4,32(s0)
 772:	f41c                	sd	a5,40(s0)
 774:	03043823          	sd	a6,48(s0)
 778:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77c:	00840613          	addi	a2,s0,8
 780:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 784:	85aa                	mv	a1,a0
 786:	4505                	li	a0,1
 788:	d19ff0ef          	jal	ra,4a0 <vprintf>
}
 78c:	60e2                	ld	ra,24(sp)
 78e:	6442                	ld	s0,16(sp)
 790:	6125                	addi	sp,sp,96
 792:	8082                	ret

0000000000000794 <free>:
 *   无
 */

void
free(void *ap)
{
 794:	1141                	addi	sp,sp,-16
 796:	e422                	sd	s0,8(sp)
 798:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 79a:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79e:	00001797          	auipc	a5,0x1
 7a2:	8627b783          	ld	a5,-1950(a5) # 1000 <freep>
 7a6:	a805                	j	7d6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a8:	4618                	lw	a4,8(a2)
 7aa:	9db9                	addw	a1,a1,a4
 7ac:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b0:	6398                	ld	a4,0(a5)
 7b2:	6318                	ld	a4,0(a4)
 7b4:	fee53823          	sd	a4,-16(a0)
 7b8:	a091                	j	7fc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ba:	ff852703          	lw	a4,-8(a0)
 7be:	9e39                	addw	a2,a2,a4
 7c0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7c2:	ff053703          	ld	a4,-16(a0)
 7c6:	e398                	sd	a4,0(a5)
 7c8:	a099                	j	80e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e7e463          	bltu	a5,a4,7d4 <free+0x40>
 7d0:	00e6ea63          	bltu	a3,a4,7e4 <free+0x50>
{
 7d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	fed7fae3          	bgeu	a5,a3,7ca <free+0x36>
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e6e463          	bltu	a3,a4,7e4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	fee7eae3          	bltu	a5,a4,7d4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7e4:	ff852583          	lw	a1,-8(a0)
 7e8:	6390                	ld	a2,0(a5)
 7ea:	02059713          	slli	a4,a1,0x20
 7ee:	9301                	srli	a4,a4,0x20
 7f0:	0712                	slli	a4,a4,0x4
 7f2:	9736                	add	a4,a4,a3
 7f4:	fae60ae3          	beq	a2,a4,7a8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7f8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fc:	4790                	lw	a2,8(a5)
 7fe:	02061713          	slli	a4,a2,0x20
 802:	9301                	srli	a4,a4,0x20
 804:	0712                	slli	a4,a4,0x4
 806:	973e                	add	a4,a4,a5
 808:	fae689e3          	beq	a3,a4,7ba <free+0x26>
  } else
    p->s.ptr = bp;
 80c:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 80e:	00000717          	auipc	a4,0x0
 812:	7ef73923          	sd	a5,2034(a4) # 1000 <freep>
}
 816:	6422                	ld	s0,8(sp)
 818:	0141                	addi	sp,sp,16
 81a:	8082                	ret

000000000000081c <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 81c:	7139                	addi	sp,sp,-64
 81e:	fc06                	sd	ra,56(sp)
 820:	f822                	sd	s0,48(sp)
 822:	f426                	sd	s1,40(sp)
 824:	f04a                	sd	s2,32(sp)
 826:	ec4e                	sd	s3,24(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
 82e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 830:	02051493          	slli	s1,a0,0x20
 834:	9081                	srli	s1,s1,0x20
 836:	04bd                	addi	s1,s1,15
 838:	8091                	srli	s1,s1,0x4
 83a:	0014899b          	addiw	s3,s1,1
 83e:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 840:	00000517          	auipc	a0,0x0
 844:	7c053503          	ld	a0,1984(a0) # 1000 <freep>
 848:	c515                	beqz	a0,874 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 84c:	4798                	lw	a4,8(a5)
 84e:	02977f63          	bgeu	a4,s1,88c <malloc+0x70>
 852:	8a4e                	mv	s4,s3
 854:	0009871b          	sext.w	a4,s3
 858:	6685                	lui	a3,0x1
 85a:	00d77363          	bgeu	a4,a3,860 <malloc+0x44>
 85e:	6a05                	lui	s4,0x1
 860:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 864:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 868:	00000917          	auipc	s2,0x0
 86c:	79890913          	addi	s2,s2,1944 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 870:	5afd                	li	s5,-1
 872:	a0bd                	j	8e0 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 874:	00000797          	auipc	a5,0x0
 878:	79c78793          	addi	a5,a5,1948 # 1010 <base>
 87c:	00000717          	auipc	a4,0x0
 880:	78f73223          	sd	a5,1924(a4) # 1000 <freep>
 884:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 886:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 88a:	b7e1                	j	852 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 88c:	02e48b63          	beq	s1,a4,8c2 <malloc+0xa6>
        p->s.size -= nunits;
 890:	4137073b          	subw	a4,a4,s3
 894:	c798                	sw	a4,8(a5)
        p += p->s.size;
 896:	1702                	slli	a4,a4,0x20
 898:	9301                	srli	a4,a4,0x20
 89a:	0712                	slli	a4,a4,0x4
 89c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89e:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8a2:	00000717          	auipc	a4,0x0
 8a6:	74a73f23          	sd	a0,1886(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 8aa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 8ae:	70e2                	ld	ra,56(sp)
 8b0:	7442                	ld	s0,48(sp)
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	7902                	ld	s2,32(sp)
 8b6:	69e2                	ld	s3,24(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
 8be:	6121                	addi	sp,sp,64
 8c0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c2:	6398                	ld	a4,0(a5)
 8c4:	e118                	sd	a4,0(a0)
 8c6:	bff1                	j	8a2 <malloc+0x86>
  hp->s.size = nu;
 8c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 8cc:	0541                	addi	a0,a0,16
 8ce:	ec7ff0ef          	jal	ra,794 <free>
  return freep;
 8d2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d6:	dd61                	beqz	a0,8ae <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8da:	4798                	lw	a4,8(a5)
 8dc:	fa9778e3          	bgeu	a4,s1,88c <malloc+0x70>
    if(p == freep)
 8e0:	00093703          	ld	a4,0(s2)
 8e4:	853e                	mv	a0,a5
 8e6:	fef719e3          	bne	a4,a5,8d8 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8ea:	8552                	mv	a0,s4
 8ec:	9e7ff0ef          	jal	ra,2d2 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8f0:	fd551ce3          	bne	a0,s5,8c8 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 8f4:	4501                	li	a0,0
 8f6:	bf65                	j	8ae <malloc+0x92>
