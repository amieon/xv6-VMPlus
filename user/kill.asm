
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7d763          	bge	a5,a0,3c <main+0x3c>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	1902                	slli	s2,s2,0x20
  1c:	02095913          	srli	s2,s2,0x20
  20:	090e                	slli	s2,s2,0x3
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	19a000ef          	jal	ra,1c2 <atoi>
  2c:	2ea000ef          	jal	ra,316 <kill>
  for(i=1; i<argc; i++)
  30:	04a1                	addi	s1,s1,8
  32:	ff249ae3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  36:	4501                	li	a0,0
  38:	2ae000ef          	jal	ra,2e6 <exit>
    fprintf(2, "usage: kill pid...\n");
  3c:	00001597          	auipc	a1,0x1
  40:	8a458593          	addi	a1,a1,-1884 # 8e0 <malloc+0xe4>
  44:	4509                	li	a0,2
  46:	6d2000ef          	jal	ra,718 <fprintf>
    exit(1);
  4a:	4505                	li	a0,1
  4c:	29a000ef          	jal	ra,2e6 <exit>

0000000000000050 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  58:	fa9ff0ef          	jal	ra,0 <main>
  exit(r);
  5c:	28a000ef          	jal	ra,2e6 <exit>

0000000000000060 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	87aa                	mv	a5,a0
  68:	0585                	addi	a1,a1,1
  6a:	0785                	addi	a5,a5,1
  6c:	fff5c703          	lbu	a4,-1(a1)
  70:	fee78fa3          	sb	a4,-1(a5)
  74:	fb75                	bnez	a4,68 <strcpy+0x8>
    ;
  return os;
}
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	cb91                	beqz	a5,9a <strcmp+0x1e>
  88:	0005c703          	lbu	a4,0(a1)
  8c:	00f71763          	bne	a4,a5,9a <strcmp+0x1e>
    p++, q++;
  90:	0505                	addi	a0,a0,1
  92:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  94:	00054783          	lbu	a5,0(a0)
  98:	fbe5                	bnez	a5,88 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9a:	0005c503          	lbu	a0,0(a1)
}
  9e:	40a7853b          	subw	a0,a5,a0
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cf91                	beqz	a5,ce <strlen+0x26>
  b4:	0505                	addi	a0,a0,1
  b6:	87aa                	mv	a5,a0
  b8:	4685                	li	a3,1
  ba:	9e89                	subw	a3,a3,a0
  bc:	00f6853b          	addw	a0,a3,a5
  c0:	0785                	addi	a5,a5,1
  c2:	fff7c703          	lbu	a4,-1(a5)
  c6:	fb7d                	bnez	a4,bc <strlen+0x14>
    ;
  return n;
}
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
  for(n = 0; s[n]; n++)
  ce:	4501                	li	a0,0
  d0:	bfe5                	j	c8 <strlen+0x20>

00000000000000d2 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d8:	ca19                	beqz	a2,ee <memset+0x1c>
  da:	87aa                	mv	a5,a0
  dc:	1602                	slli	a2,a2,0x20
  de:	9201                	srli	a2,a2,0x20
  e0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e8:	0785                	addi	a5,a5,1
  ea:	fee79de3          	bne	a5,a4,e4 <memset+0x12>
  }
  return dst;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb99                	beqz	a5,114 <strchr+0x20>
    if(*s == c)
 100:	00f58763          	beq	a1,a5,10e <strchr+0x1a>
  for(; *s; s++)
 104:	0505                	addi	a0,a0,1
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbfd                	bnez	a5,100 <strchr+0xc>
      return (char*)s;
  return 0;
 10c:	4501                	li	a0,0
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
  return 0;
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strchr+0x1a>

0000000000000118 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 118:	711d                	addi	sp,sp,-96
 11a:	ec86                	sd	ra,88(sp)
 11c:	e8a2                	sd	s0,80(sp)
 11e:	e4a6                	sd	s1,72(sp)
 120:	e0ca                	sd	s2,64(sp)
 122:	fc4e                	sd	s3,56(sp)
 124:	f852                	sd	s4,48(sp)
 126:	f456                	sd	s5,40(sp)
 128:	f05a                	sd	s6,32(sp)
 12a:	ec5e                	sd	s7,24(sp)
 12c:	1080                	addi	s0,sp,96
 12e:	8baa                	mv	s7,a0
 130:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 132:	892a                	mv	s2,a0
 134:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 136:	4aa9                	li	s5,10
 138:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13a:	89a6                	mv	s3,s1
 13c:	2485                	addiw	s1,s1,1
 13e:	0344d663          	bge	s1,s4,16a <gets+0x52>
    cc = read(0, &c, 1);
 142:	4605                	li	a2,1
 144:	faf40593          	addi	a1,s0,-81
 148:	4501                	li	a0,0
 14a:	1b4000ef          	jal	ra,2fe <read>
    if(cc < 1)
 14e:	00a05e63          	blez	a0,16a <gets+0x52>
    buf[i++] = c;
 152:	faf44783          	lbu	a5,-81(s0)
 156:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15a:	01578763          	beq	a5,s5,168 <gets+0x50>
 15e:	0905                	addi	s2,s2,1
 160:	fd679de3          	bne	a5,s6,13a <gets+0x22>
  for(i=0; i+1 < max; ){
 164:	89a6                	mv	s3,s1
 166:	a011                	j	16a <gets+0x52>
 168:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16a:	99de                	add	s3,s3,s7
 16c:	00098023          	sb	zero,0(s3)
  return buf;
}
 170:	855e                	mv	a0,s7
 172:	60e6                	ld	ra,88(sp)
 174:	6446                	ld	s0,80(sp)
 176:	64a6                	ld	s1,72(sp)
 178:	6906                	ld	s2,64(sp)
 17a:	79e2                	ld	s3,56(sp)
 17c:	7a42                	ld	s4,48(sp)
 17e:	7aa2                	ld	s5,40(sp)
 180:	7b02                	ld	s6,32(sp)
 182:	6be2                	ld	s7,24(sp)
 184:	6125                	addi	sp,sp,96
 186:	8082                	ret

0000000000000188 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 188:	1101                	addi	sp,sp,-32
 18a:	ec06                	sd	ra,24(sp)
 18c:	e822                	sd	s0,16(sp)
 18e:	e426                	sd	s1,8(sp)
 190:	e04a                	sd	s2,0(sp)
 192:	1000                	addi	s0,sp,32
 194:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 196:	4581                	li	a1,0
 198:	18e000ef          	jal	ra,326 <open>
  if(fd < 0)
 19c:	02054163          	bltz	a0,1be <stat+0x36>
 1a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a2:	85ca                	mv	a1,s2
 1a4:	19a000ef          	jal	ra,33e <fstat>
 1a8:	892a                	mv	s2,a0
  close(fd);
 1aa:	8526                	mv	a0,s1
 1ac:	162000ef          	jal	ra,30e <close>
  return r;
}
 1b0:	854a                	mv	a0,s2
 1b2:	60e2                	ld	ra,24(sp)
 1b4:	6442                	ld	s0,16(sp)
 1b6:	64a2                	ld	s1,8(sp)
 1b8:	6902                	ld	s2,0(sp)
 1ba:	6105                	addi	sp,sp,32
 1bc:	8082                	ret
    return -1;
 1be:	597d                	li	s2,-1
 1c0:	bfc5                	j	1b0 <stat+0x28>

00000000000001c2 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c8:	00054603          	lbu	a2,0(a0)
 1cc:	fd06079b          	addiw	a5,a2,-48
 1d0:	0ff7f793          	andi	a5,a5,255
 1d4:	4725                	li	a4,9
 1d6:	02f76963          	bltu	a4,a5,208 <atoi+0x46>
 1da:	86aa                	mv	a3,a0
  n = 0;
 1dc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1de:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1e0:	0685                	addi	a3,a3,1
 1e2:	0025179b          	slliw	a5,a0,0x2
 1e6:	9fa9                	addw	a5,a5,a0
 1e8:	0017979b          	slliw	a5,a5,0x1
 1ec:	9fb1                	addw	a5,a5,a2
 1ee:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f2:	0006c603          	lbu	a2,0(a3)
 1f6:	fd06071b          	addiw	a4,a2,-48
 1fa:	0ff77713          	andi	a4,a4,255
 1fe:	fee5f1e3          	bgeu	a1,a4,1e0 <atoi+0x1e>
  return n;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
  n = 0;
 208:	4501                	li	a0,0
 20a:	bfe5                	j	202 <atoi+0x40>

000000000000020c <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 212:	02b57463          	bgeu	a0,a1,23a <memmove+0x2e>
    while(n-- > 0)
 216:	00c05f63          	blez	a2,234 <memmove+0x28>
 21a:	1602                	slli	a2,a2,0x20
 21c:	9201                	srli	a2,a2,0x20
 21e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 222:	872a                	mv	a4,a0
      *dst++ = *src++;
 224:	0585                	addi	a1,a1,1
 226:	0705                	addi	a4,a4,1
 228:	fff5c683          	lbu	a3,-1(a1)
 22c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 230:	fee79ae3          	bne	a5,a4,224 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
    dst += n;
 23a:	00c50733          	add	a4,a0,a2
    src += n;
 23e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 240:	fec05ae3          	blez	a2,234 <memmove+0x28>
 244:	fff6079b          	addiw	a5,a2,-1
 248:	1782                	slli	a5,a5,0x20
 24a:	9381                	srli	a5,a5,0x20
 24c:	fff7c793          	not	a5,a5
 250:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 252:	15fd                	addi	a1,a1,-1
 254:	177d                	addi	a4,a4,-1
 256:	0005c683          	lbu	a3,0(a1)
 25a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25e:	fee79ae3          	bne	a5,a4,252 <memmove+0x46>
 262:	bfc9                	j	234 <memmove+0x28>

0000000000000264 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26a:	ca05                	beqz	a2,29a <memcmp+0x36>
 26c:	fff6069b          	addiw	a3,a2,-1
 270:	1682                	slli	a3,a3,0x20
 272:	9281                	srli	a3,a3,0x20
 274:	0685                	addi	a3,a3,1
 276:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 278:	00054783          	lbu	a5,0(a0)
 27c:	0005c703          	lbu	a4,0(a1)
 280:	00e79863          	bne	a5,a4,290 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 284:	0505                	addi	a0,a0,1
    p2++;
 286:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 288:	fed518e3          	bne	a0,a3,278 <memcmp+0x14>
  }
  return 0;
 28c:	4501                	li	a0,0
 28e:	a019                	j	294 <memcmp+0x30>
      return *p1 - *p2;
 290:	40e7853b          	subw	a0,a5,a4
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  return 0;
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <memcmp+0x30>

000000000000029e <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a6:	f67ff0ef          	jal	ra,20c <memmove>
}
 2aa:	60a2                	ld	ra,8(sp)
 2ac:	6402                	ld	s0,0(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret

00000000000002b2 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e406                	sd	ra,8(sp)
 2b6:	e022                	sd	s0,0(sp)
 2b8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2ba:	4585                	li	a1,1
 2bc:	0b2000ef          	jal	ra,36e <sys_sbrk>
}
 2c0:	60a2                	ld	ra,8(sp)
 2c2:	6402                	ld	s0,0(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret

00000000000002c8 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2d0:	4589                	li	a1,2
 2d2:	09c000ef          	jal	ra,36e <sys_sbrk>
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret

00000000000002de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2de:	4885                	li	a7,1
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e6:	4889                	li	a7,2
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ee:	488d                	li	a7,3
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f6:	4891                	li	a7,4
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <read>:
.global read
read:
 li a7, SYS_read
 2fe:	4895                	li	a7,5
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <write>:
.global write
write:
 li a7, SYS_write
 306:	48c1                	li	a7,16
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <close>:
.global close
close:
 li a7, SYS_close
 30e:	48d5                	li	a7,21
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <kill>:
.global kill
kill:
 li a7, SYS_kill
 316:	4899                	li	a7,6
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <exec>:
.global exec
exec:
 li a7, SYS_exec
 31e:	489d                	li	a7,7
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <open>:
.global open
open:
 li a7, SYS_open
 326:	48bd                	li	a7,15
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32e:	48c5                	li	a7,17
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 336:	48c9                	li	a7,18
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33e:	48a1                	li	a7,8
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <link>:
.global link
link:
 li a7, SYS_link
 346:	48cd                	li	a7,19
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34e:	48d1                	li	a7,20
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 356:	48a5                	li	a7,9
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <dup>:
.global dup
dup:
 li a7, SYS_dup
 35e:	48a9                	li	a7,10
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 366:	48ad                	li	a7,11
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 36e:	48b1                	li	a7,12
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <pause>:
.global pause
pause:
 li a7, SYS_pause
 376:	48b5                	li	a7,13
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37e:	48b9                	li	a7,14
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 386:	48d9                	li	a7,22
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 38e:	48dd                	li	a7,23
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 396:	48e1                	li	a7,24
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 39e:	48e5                	li	a7,25
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 3a6:	48e9                	li	a7,26
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3ae:	48ed                	li	a7,27
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3b6:	48f1                	li	a7,28
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3be:	48f5                	li	a7,29
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 3c6:	1101                	addi	sp,sp,-32
 3c8:	ec06                	sd	ra,24(sp)
 3ca:	e822                	sd	s0,16(sp)
 3cc:	1000                	addi	s0,sp,32
 3ce:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d2:	4605                	li	a2,1
 3d4:	fef40593          	addi	a1,s0,-17
 3d8:	f2fff0ef          	jal	ra,306 <write>
}
 3dc:	60e2                	ld	ra,24(sp)
 3de:	6442                	ld	s0,16(sp)
 3e0:	6105                	addi	sp,sp,32
 3e2:	8082                	ret

00000000000003e4 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 3e4:	715d                	addi	sp,sp,-80
 3e6:	e486                	sd	ra,72(sp)
 3e8:	e0a2                	sd	s0,64(sp)
 3ea:	fc26                	sd	s1,56(sp)
 3ec:	f84a                	sd	s2,48(sp)
 3ee:	f44e                	sd	s3,40(sp)
 3f0:	0880                	addi	s0,sp,80
 3f2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3f4:	c299                	beqz	a3,3fa <printint+0x16>
 3f6:	0805c163          	bltz	a1,478 <printint+0x94>
  neg = 0;
 3fa:	4881                	li	a7,0
 3fc:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 400:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 402:	00000517          	auipc	a0,0x0
 406:	4fe50513          	addi	a0,a0,1278 # 900 <digits>
 40a:	883e                	mv	a6,a5
 40c:	2785                	addiw	a5,a5,1
 40e:	02c5f733          	remu	a4,a1,a2
 412:	972a                	add	a4,a4,a0
 414:	00074703          	lbu	a4,0(a4)
 418:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 41c:	872e                	mv	a4,a1
 41e:	02c5d5b3          	divu	a1,a1,a2
 422:	0685                	addi	a3,a3,1
 424:	fec773e3          	bgeu	a4,a2,40a <printint+0x26>
  if(neg)
 428:	00088b63          	beqz	a7,43e <printint+0x5a>
    buf[i++] = '-';
 42c:	fd040713          	addi	a4,s0,-48
 430:	97ba                	add	a5,a5,a4
 432:	02d00713          	li	a4,45
 436:	fee78423          	sb	a4,-24(a5)
 43a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 43e:	02f05663          	blez	a5,46a <printint+0x86>
 442:	fb840713          	addi	a4,s0,-72
 446:	00f704b3          	add	s1,a4,a5
 44a:	fff70993          	addi	s3,a4,-1
 44e:	99be                	add	s3,s3,a5
 450:	37fd                	addiw	a5,a5,-1
 452:	1782                	slli	a5,a5,0x20
 454:	9381                	srli	a5,a5,0x20
 456:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 45a:	fff4c583          	lbu	a1,-1(s1)
 45e:	854a                	mv	a0,s2
 460:	f67ff0ef          	jal	ra,3c6 <putc>
  while(--i >= 0)
 464:	14fd                	addi	s1,s1,-1
 466:	ff349ae3          	bne	s1,s3,45a <printint+0x76>
}
 46a:	60a6                	ld	ra,72(sp)
 46c:	6406                	ld	s0,64(sp)
 46e:	74e2                	ld	s1,56(sp)
 470:	7942                	ld	s2,48(sp)
 472:	79a2                	ld	s3,40(sp)
 474:	6161                	addi	sp,sp,80
 476:	8082                	ret
    x = -xx;
 478:	40b005b3          	neg	a1,a1
    neg = 1;
 47c:	4885                	li	a7,1
    x = -xx;
 47e:	bfbd                	j	3fc <printint+0x18>

0000000000000480 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 480:	7119                	addi	sp,sp,-128
 482:	fc86                	sd	ra,120(sp)
 484:	f8a2                	sd	s0,112(sp)
 486:	f4a6                	sd	s1,104(sp)
 488:	f0ca                	sd	s2,96(sp)
 48a:	ecce                	sd	s3,88(sp)
 48c:	e8d2                	sd	s4,80(sp)
 48e:	e4d6                	sd	s5,72(sp)
 490:	e0da                	sd	s6,64(sp)
 492:	fc5e                	sd	s7,56(sp)
 494:	f862                	sd	s8,48(sp)
 496:	f466                	sd	s9,40(sp)
 498:	f06a                	sd	s10,32(sp)
 49a:	ec6e                	sd	s11,24(sp)
 49c:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49e:	0005c903          	lbu	s2,0(a1)
 4a2:	24090c63          	beqz	s2,6fa <vprintf+0x27a>
 4a6:	8b2a                	mv	s6,a0
 4a8:	8a2e                	mv	s4,a1
 4aa:	8bb2                	mv	s7,a2
  state = 0;
 4ac:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ae:	4481                	li	s1,0
 4b0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4b2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4b6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4ba:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4be:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4c2:	00000c97          	auipc	s9,0x0
 4c6:	43ec8c93          	addi	s9,s9,1086 # 900 <digits>
 4ca:	a005                	j	4ea <vprintf+0x6a>
        putc(fd, c0);
 4cc:	85ca                	mv	a1,s2
 4ce:	855a                	mv	a0,s6
 4d0:	ef7ff0ef          	jal	ra,3c6 <putc>
 4d4:	a019                	j	4da <vprintf+0x5a>
    } else if(state == '%'){
 4d6:	03598263          	beq	s3,s5,4fa <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4da:	2485                	addiw	s1,s1,1
 4dc:	8726                	mv	a4,s1
 4de:	009a07b3          	add	a5,s4,s1
 4e2:	0007c903          	lbu	s2,0(a5)
 4e6:	20090a63          	beqz	s2,6fa <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4ea:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ee:	fe0994e3          	bnez	s3,4d6 <vprintf+0x56>
      if(c0 == '%'){
 4f2:	fd579de3          	bne	a5,s5,4cc <vprintf+0x4c>
        state = '%';
 4f6:	89be                	mv	s3,a5
 4f8:	b7cd                	j	4da <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4fa:	c3c1                	beqz	a5,57a <vprintf+0xfa>
 4fc:	00ea06b3          	add	a3,s4,a4
 500:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 504:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 506:	c681                	beqz	a3,50e <vprintf+0x8e>
 508:	9752                	add	a4,a4,s4
 50a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 50e:	03878e63          	beq	a5,s8,54a <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 512:	05a78863          	beq	a5,s10,562 <vprintf+0xe2>
      } else if(c0 == 'u'){
 516:	0db78b63          	beq	a5,s11,5ec <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 51a:	07800713          	li	a4,120
 51e:	10e78d63          	beq	a5,a4,638 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 522:	07000713          	li	a4,112
 526:	14e78263          	beq	a5,a4,66a <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 52a:	06300713          	li	a4,99
 52e:	16e78f63          	beq	a5,a4,6ac <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 532:	07300713          	li	a4,115
 536:	18e78563          	beq	a5,a4,6c0 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 53a:	05579063          	bne	a5,s5,57a <vprintf+0xfa>
        putc(fd, '%');
 53e:	85d6                	mv	a1,s5
 540:	855a                	mv	a0,s6
 542:	e85ff0ef          	jal	ra,3c6 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 546:	4981                	li	s3,0
 548:	bf49                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4685                	li	a3,1
 550:	4629                	li	a2,10
 552:	000ba583          	lw	a1,0(s7)
 556:	855a                	mv	a0,s6
 558:	e8dff0ef          	jal	ra,3e4 <printint>
 55c:	8bca                	mv	s7,s2
      state = 0;
 55e:	4981                	li	s3,0
 560:	bfad                	j	4da <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 562:	03868663          	beq	a3,s8,58e <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 566:	05a68163          	beq	a3,s10,5a8 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 56a:	09b68d63          	beq	a3,s11,604 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 56e:	03a68f63          	beq	a3,s10,5ac <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 572:	07800793          	li	a5,120
 576:	0cf68d63          	beq	a3,a5,650 <vprintf+0x1d0>
        putc(fd, '%');
 57a:	85d6                	mv	a1,s5
 57c:	855a                	mv	a0,s6
 57e:	e49ff0ef          	jal	ra,3c6 <putc>
        putc(fd, c0);
 582:	85ca                	mv	a1,s2
 584:	855a                	mv	a0,s6
 586:	e41ff0ef          	jal	ra,3c6 <putc>
      state = 0;
 58a:	4981                	li	s3,0
 58c:	b7b9                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 58e:	008b8913          	addi	s2,s7,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000bb583          	ld	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	e49ff0ef          	jal	ra,3e4 <printint>
        i += 1;
 5a0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
        i += 1;
 5a6:	bf15                	j	4da <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a8:	03860563          	beq	a2,s8,5d2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5ac:	07b60963          	beq	a2,s11,61e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5b0:	07800793          	li	a5,120
 5b4:	fcf613e3          	bne	a2,a5,57a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b8:	008b8913          	addi	s2,s7,8
 5bc:	4681                	li	a3,0
 5be:	4641                	li	a2,16
 5c0:	000bb583          	ld	a1,0(s7)
 5c4:	855a                	mv	a0,s6
 5c6:	e1fff0ef          	jal	ra,3e4 <printint>
        i += 2;
 5ca:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5cc:	8bca                	mv	s7,s2
      state = 0;
 5ce:	4981                	li	s3,0
        i += 2;
 5d0:	b729                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4685                	li	a3,1
 5d8:	4629                	li	a2,10
 5da:	000bb583          	ld	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e05ff0ef          	jal	ra,3e4 <printint>
        i += 2;
 5e4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e6:	8bca                	mv	s7,s2
      state = 0;
 5e8:	4981                	li	s3,0
        i += 2;
 5ea:	bdc5                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4681                	li	a3,0
 5f2:	4629                	li	a2,10
 5f4:	000be583          	lwu	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	debff0ef          	jal	ra,3e4 <printint>
 5fe:	8bca                	mv	s7,s2
      state = 0;
 600:	4981                	li	s3,0
 602:	bde1                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 604:	008b8913          	addi	s2,s7,8
 608:	4681                	li	a3,0
 60a:	4629                	li	a2,10
 60c:	000bb583          	ld	a1,0(s7)
 610:	855a                	mv	a0,s6
 612:	dd3ff0ef          	jal	ra,3e4 <printint>
        i += 1;
 616:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
        i += 1;
 61c:	bd7d                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b8913          	addi	s2,s7,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	db9ff0ef          	jal	ra,3e4 <printint>
        i += 2;
 630:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 2;
 636:	b555                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 638:	008b8913          	addi	s2,s7,8
 63c:	4681                	li	a3,0
 63e:	4641                	li	a2,16
 640:	000be583          	lwu	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	d9fff0ef          	jal	ra,3e4 <printint>
 64a:	8bca                	mv	s7,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b571                	j	4da <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	008b8913          	addi	s2,s7,8
 654:	4681                	li	a3,0
 656:	4641                	li	a2,16
 658:	000bb583          	ld	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	d87ff0ef          	jal	ra,3e4 <printint>
        i += 1;
 662:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
        i += 1;
 668:	bd8d                	j	4da <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 66a:	008b8793          	addi	a5,s7,8
 66e:	f8f43423          	sd	a5,-120(s0)
 672:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 676:	03000593          	li	a1,48
 67a:	855a                	mv	a0,s6
 67c:	d4bff0ef          	jal	ra,3c6 <putc>
  putc(fd, 'x');
 680:	07800593          	li	a1,120
 684:	855a                	mv	a0,s6
 686:	d41ff0ef          	jal	ra,3c6 <putc>
 68a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68c:	03c9d793          	srli	a5,s3,0x3c
 690:	97e6                	add	a5,a5,s9
 692:	0007c583          	lbu	a1,0(a5)
 696:	855a                	mv	a0,s6
 698:	d2fff0ef          	jal	ra,3c6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69c:	0992                	slli	s3,s3,0x4
 69e:	397d                	addiw	s2,s2,-1
 6a0:	fe0916e3          	bnez	s2,68c <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6a4:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bd05                	j	4da <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	000bc583          	lbu	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	d11ff0ef          	jal	ra,3c6 <putc>
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bd31                	j	4da <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6c0:	008b8993          	addi	s3,s7,8
 6c4:	000bb903          	ld	s2,0(s7)
 6c8:	00090f63          	beqz	s2,6e6 <vprintf+0x266>
        for(; *s; s++)
 6cc:	00094583          	lbu	a1,0(s2)
 6d0:	c195                	beqz	a1,6f4 <vprintf+0x274>
          putc(fd, *s);
 6d2:	855a                	mv	a0,s6
 6d4:	cf3ff0ef          	jal	ra,3c6 <putc>
        for(; *s; s++)
 6d8:	0905                	addi	s2,s2,1
 6da:	00094583          	lbu	a1,0(s2)
 6de:	f9f5                	bnez	a1,6d2 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6e0:	8bce                	mv	s7,s3
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bbdd                	j	4da <vprintf+0x5a>
          s = "(null)";
 6e6:	00000917          	auipc	s2,0x0
 6ea:	21290913          	addi	s2,s2,530 # 8f8 <malloc+0xfc>
        for(; *s; s++)
 6ee:	02800593          	li	a1,40
 6f2:	b7c5                	j	6d2 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6f4:	8bce                	mv	s7,s3
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b3cd                	j	4da <vprintf+0x5a>
    }
  }
}
 6fa:	70e6                	ld	ra,120(sp)
 6fc:	7446                	ld	s0,112(sp)
 6fe:	74a6                	ld	s1,104(sp)
 700:	7906                	ld	s2,96(sp)
 702:	69e6                	ld	s3,88(sp)
 704:	6a46                	ld	s4,80(sp)
 706:	6aa6                	ld	s5,72(sp)
 708:	6b06                	ld	s6,64(sp)
 70a:	7be2                	ld	s7,56(sp)
 70c:	7c42                	ld	s8,48(sp)
 70e:	7ca2                	ld	s9,40(sp)
 710:	7d02                	ld	s10,32(sp)
 712:	6de2                	ld	s11,24(sp)
 714:	6109                	addi	sp,sp,128
 716:	8082                	ret

0000000000000718 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 718:	715d                	addi	sp,sp,-80
 71a:	ec06                	sd	ra,24(sp)
 71c:	e822                	sd	s0,16(sp)
 71e:	1000                	addi	s0,sp,32
 720:	e010                	sd	a2,0(s0)
 722:	e414                	sd	a3,8(s0)
 724:	e818                	sd	a4,16(s0)
 726:	ec1c                	sd	a5,24(s0)
 728:	03043023          	sd	a6,32(s0)
 72c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 730:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 734:	8622                	mv	a2,s0
 736:	d4bff0ef          	jal	ra,480 <vprintf>
}
 73a:	60e2                	ld	ra,24(sp)
 73c:	6442                	ld	s0,16(sp)
 73e:	6161                	addi	sp,sp,80
 740:	8082                	ret

0000000000000742 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 742:	711d                	addi	sp,sp,-96
 744:	ec06                	sd	ra,24(sp)
 746:	e822                	sd	s0,16(sp)
 748:	1000                	addi	s0,sp,32
 74a:	e40c                	sd	a1,8(s0)
 74c:	e810                	sd	a2,16(s0)
 74e:	ec14                	sd	a3,24(s0)
 750:	f018                	sd	a4,32(s0)
 752:	f41c                	sd	a5,40(s0)
 754:	03043823          	sd	a6,48(s0)
 758:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75c:	00840613          	addi	a2,s0,8
 760:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 764:	85aa                	mv	a1,a0
 766:	4505                	li	a0,1
 768:	d19ff0ef          	jal	ra,480 <vprintf>
}
 76c:	60e2                	ld	ra,24(sp)
 76e:	6442                	ld	s0,16(sp)
 770:	6125                	addi	sp,sp,96
 772:	8082                	ret

0000000000000774 <free>:
 *   无
 */

void
free(void *ap)
{
 774:	1141                	addi	sp,sp,-16
 776:	e422                	sd	s0,8(sp)
 778:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 77a:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	00001797          	auipc	a5,0x1
 782:	8827b783          	ld	a5,-1918(a5) # 1000 <freep>
 786:	a805                	j	7b6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 788:	4618                	lw	a4,8(a2)
 78a:	9db9                	addw	a1,a1,a4
 78c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 790:	6398                	ld	a4,0(a5)
 792:	6318                	ld	a4,0(a4)
 794:	fee53823          	sd	a4,-16(a0)
 798:	a091                	j	7dc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 79a:	ff852703          	lw	a4,-8(a0)
 79e:	9e39                	addw	a2,a2,a4
 7a0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7a2:	ff053703          	ld	a4,-16(a0)
 7a6:	e398                	sd	a4,0(a5)
 7a8:	a099                	j	7ee <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7aa:	6398                	ld	a4,0(a5)
 7ac:	00e7e463          	bltu	a5,a4,7b4 <free+0x40>
 7b0:	00e6ea63          	bltu	a3,a4,7c4 <free+0x50>
{
 7b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	fed7fae3          	bgeu	a5,a3,7aa <free+0x36>
 7ba:	6398                	ld	a4,0(a5)
 7bc:	00e6e463          	bltu	a3,a4,7c4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	fee7eae3          	bltu	a5,a4,7b4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7c4:	ff852583          	lw	a1,-8(a0)
 7c8:	6390                	ld	a2,0(a5)
 7ca:	02059713          	slli	a4,a1,0x20
 7ce:	9301                	srli	a4,a4,0x20
 7d0:	0712                	slli	a4,a4,0x4
 7d2:	9736                	add	a4,a4,a3
 7d4:	fae60ae3          	beq	a2,a4,788 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7dc:	4790                	lw	a2,8(a5)
 7de:	02061713          	slli	a4,a2,0x20
 7e2:	9301                	srli	a4,a4,0x20
 7e4:	0712                	slli	a4,a4,0x4
 7e6:	973e                	add	a4,a4,a5
 7e8:	fae689e3          	beq	a3,a4,79a <free+0x26>
  } else
    p->s.ptr = bp;
 7ec:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 7ee:	00001717          	auipc	a4,0x1
 7f2:	80f73923          	sd	a5,-2030(a4) # 1000 <freep>
}
 7f6:	6422                	ld	s0,8(sp)
 7f8:	0141                	addi	sp,sp,16
 7fa:	8082                	ret

00000000000007fc <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 7fc:	7139                	addi	sp,sp,-64
 7fe:	fc06                	sd	ra,56(sp)
 800:	f822                	sd	s0,48(sp)
 802:	f426                	sd	s1,40(sp)
 804:	f04a                	sd	s2,32(sp)
 806:	ec4e                	sd	s3,24(sp)
 808:	e852                	sd	s4,16(sp)
 80a:	e456                	sd	s5,8(sp)
 80c:	e05a                	sd	s6,0(sp)
 80e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 810:	02051493          	slli	s1,a0,0x20
 814:	9081                	srli	s1,s1,0x20
 816:	04bd                	addi	s1,s1,15
 818:	8091                	srli	s1,s1,0x4
 81a:	0014899b          	addiw	s3,s1,1
 81e:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 820:	00000517          	auipc	a0,0x0
 824:	7e053503          	ld	a0,2016(a0) # 1000 <freep>
 828:	c515                	beqz	a0,854 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 82c:	4798                	lw	a4,8(a5)
 82e:	02977f63          	bgeu	a4,s1,86c <malloc+0x70>
 832:	8a4e                	mv	s4,s3
 834:	0009871b          	sext.w	a4,s3
 838:	6685                	lui	a3,0x1
 83a:	00d77363          	bgeu	a4,a3,840 <malloc+0x44>
 83e:	6a05                	lui	s4,0x1
 840:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 844:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 848:	00000917          	auipc	s2,0x0
 84c:	7b890913          	addi	s2,s2,1976 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 850:	5afd                	li	s5,-1
 852:	a0bd                	j	8c0 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 854:	00000797          	auipc	a5,0x0
 858:	7bc78793          	addi	a5,a5,1980 # 1010 <base>
 85c:	00000717          	auipc	a4,0x0
 860:	7af73223          	sd	a5,1956(a4) # 1000 <freep>
 864:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 866:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 86a:	b7e1                	j	832 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 86c:	02e48b63          	beq	s1,a4,8a2 <malloc+0xa6>
        p->s.size -= nunits;
 870:	4137073b          	subw	a4,a4,s3
 874:	c798                	sw	a4,8(a5)
        p += p->s.size;
 876:	1702                	slli	a4,a4,0x20
 878:	9301                	srli	a4,a4,0x20
 87a:	0712                	slli	a4,a4,0x4
 87c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87e:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 882:	00000717          	auipc	a4,0x0
 886:	76a73f23          	sd	a0,1918(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 88a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 88e:	70e2                	ld	ra,56(sp)
 890:	7442                	ld	s0,48(sp)
 892:	74a2                	ld	s1,40(sp)
 894:	7902                	ld	s2,32(sp)
 896:	69e2                	ld	s3,24(sp)
 898:	6a42                	ld	s4,16(sp)
 89a:	6aa2                	ld	s5,8(sp)
 89c:	6b02                	ld	s6,0(sp)
 89e:	6121                	addi	sp,sp,64
 8a0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a2:	6398                	ld	a4,0(a5)
 8a4:	e118                	sd	a4,0(a0)
 8a6:	bff1                	j	882 <malloc+0x86>
  hp->s.size = nu;
 8a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 8ac:	0541                	addi	a0,a0,16
 8ae:	ec7ff0ef          	jal	ra,774 <free>
  return freep;
 8b2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b6:	dd61                	beqz	a0,88e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8ba:	4798                	lw	a4,8(a5)
 8bc:	fa9778e3          	bgeu	a4,s1,86c <malloc+0x70>
    if(p == freep)
 8c0:	00093703          	ld	a4,0(s2)
 8c4:	853e                	mv	a0,a5
 8c6:	fef719e3          	bne	a4,a5,8b8 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8ca:	8552                	mv	a0,s4
 8cc:	9e7ff0ef          	jal	ra,2b2 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8d0:	fd551ce3          	bne	a0,s5,8a8 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 8d4:	4501                	li	a0,0
 8d6:	bf65                	j	88e <malloc+0x92>
