
user/_mmap_ro_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int main(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *p = mmap(0, 4096, PROT_READ, MAP_ANON, 1);
   a:	4705                	li	a4,1
   c:	4685                	li	a3,1
   e:	4605                	li	a2,1
  10:	6585                	lui	a1,0x1
  12:	4501                	li	a0,0
  14:	360000ef          	jal	ra,374 <mmap>
  18:	84aa                	mv	s1,a0
  printf("about to write (should die)\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	8b650513          	addi	a0,a0,-1866 # 8d0 <malloc+0xe6>
  22:	70e000ef          	jal	ra,730 <printf>
  p[0] = 1; // 应该被 kill
  26:	4785                	li	a5,1
  28:	00f48023          	sb	a5,0(s1)
  printf("FAIL: still alive\n");
  2c:	00001517          	auipc	a0,0x1
  30:	8c450513          	addi	a0,a0,-1852 # 8f0 <malloc+0x106>
  34:	6fc000ef          	jal	ra,730 <printf>
  exit(1);
  38:	4505                	li	a0,1
  3a:	29a000ef          	jal	ra,2d4 <exit>

000000000000003e <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e406                	sd	ra,8(sp)
  42:	e022                	sd	s0,0(sp)
  44:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  46:	fbbff0ef          	jal	ra,0 <main>
  exit(r);
  4a:	28a000ef          	jal	ra,2d4 <exit>

000000000000004e <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e422                	sd	s0,8(sp)
  52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  54:	87aa                	mv	a5,a0
  56:	0585                	addi	a1,a1,1
  58:	0785                	addi	a5,a5,1
  5a:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x6ef>
  5e:	fee78fa3          	sb	a4,-1(a5)
  62:	fb75                	bnez	a4,56 <strcpy+0x8>
    ;
  return os;
}
  64:	6422                	ld	s0,8(sp)
  66:	0141                	addi	sp,sp,16
  68:	8082                	ret

000000000000006a <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  6a:	1141                	addi	sp,sp,-16
  6c:	e422                	sd	s0,8(sp)
  6e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  70:	00054783          	lbu	a5,0(a0)
  74:	cb91                	beqz	a5,88 <strcmp+0x1e>
  76:	0005c703          	lbu	a4,0(a1)
  7a:	00f71763          	bne	a4,a5,88 <strcmp+0x1e>
    p++, q++;
  7e:	0505                	addi	a0,a0,1
  80:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	fbe5                	bnez	a5,76 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  88:	0005c503          	lbu	a0,0(a1)
}
  8c:	40a7853b          	subw	a0,a5,a0
  90:	6422                	ld	s0,8(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret

0000000000000096 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cf91                	beqz	a5,bc <strlen+0x26>
  a2:	0505                	addi	a0,a0,1
  a4:	87aa                	mv	a5,a0
  a6:	4685                	li	a3,1
  a8:	9e89                	subw	a3,a3,a0
  aa:	00f6853b          	addw	a0,a3,a5
  ae:	0785                	addi	a5,a5,1
  b0:	fff7c703          	lbu	a4,-1(a5)
  b4:	fb7d                	bnez	a4,aa <strlen+0x14>
    ;
  return n;
}
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret
  for(n = 0; s[n]; n++)
  bc:	4501                	li	a0,0
  be:	bfe5                	j	b6 <strlen+0x20>

00000000000000c0 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c6:	ca19                	beqz	a2,dc <memset+0x1c>
  c8:	87aa                	mv	a5,a0
  ca:	1602                	slli	a2,a2,0x20
  cc:	9201                	srli	a2,a2,0x20
  ce:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d6:	0785                	addi	a5,a5,1
  d8:	fee79de3          	bne	a5,a4,d2 <memset+0x12>
  }
  return dst;
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e422                	sd	s0,8(sp)
  e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	cb99                	beqz	a5,102 <strchr+0x20>
    if(*s == c)
  ee:	00f58763          	beq	a1,a5,fc <strchr+0x1a>
  for(; *s; s++)
  f2:	0505                	addi	a0,a0,1
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbfd                	bnez	a5,ee <strchr+0xc>
      return (char*)s;
  return 0;
  fa:	4501                	li	a0,0
}
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret
  return 0;
 102:	4501                	li	a0,0
 104:	bfe5                	j	fc <strchr+0x1a>

0000000000000106 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 106:	711d                	addi	sp,sp,-96
 108:	ec86                	sd	ra,88(sp)
 10a:	e8a2                	sd	s0,80(sp)
 10c:	e4a6                	sd	s1,72(sp)
 10e:	e0ca                	sd	s2,64(sp)
 110:	fc4e                	sd	s3,56(sp)
 112:	f852                	sd	s4,48(sp)
 114:	f456                	sd	s5,40(sp)
 116:	f05a                	sd	s6,32(sp)
 118:	ec5e                	sd	s7,24(sp)
 11a:	1080                	addi	s0,sp,96
 11c:	8baa                	mv	s7,a0
 11e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 120:	892a                	mv	s2,a0
 122:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 124:	4aa9                	li	s5,10
 126:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 128:	89a6                	mv	s3,s1
 12a:	2485                	addiw	s1,s1,1
 12c:	0344d663          	bge	s1,s4,158 <gets+0x52>
    cc = read(0, &c, 1);
 130:	4605                	li	a2,1
 132:	faf40593          	addi	a1,s0,-81
 136:	4501                	li	a0,0
 138:	1b4000ef          	jal	ra,2ec <read>
    if(cc < 1)
 13c:	00a05e63          	blez	a0,158 <gets+0x52>
    buf[i++] = c;
 140:	faf44783          	lbu	a5,-81(s0)
 144:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 148:	01578763          	beq	a5,s5,156 <gets+0x50>
 14c:	0905                	addi	s2,s2,1
 14e:	fd679de3          	bne	a5,s6,128 <gets+0x22>
  for(i=0; i+1 < max; ){
 152:	89a6                	mv	s3,s1
 154:	a011                	j	158 <gets+0x52>
 156:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 158:	99de                	add	s3,s3,s7
 15a:	00098023          	sb	zero,0(s3)
  return buf;
}
 15e:	855e                	mv	a0,s7
 160:	60e6                	ld	ra,88(sp)
 162:	6446                	ld	s0,80(sp)
 164:	64a6                	ld	s1,72(sp)
 166:	6906                	ld	s2,64(sp)
 168:	79e2                	ld	s3,56(sp)
 16a:	7a42                	ld	s4,48(sp)
 16c:	7aa2                	ld	s5,40(sp)
 16e:	7b02                	ld	s6,32(sp)
 170:	6be2                	ld	s7,24(sp)
 172:	6125                	addi	sp,sp,96
 174:	8082                	ret

0000000000000176 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 176:	1101                	addi	sp,sp,-32
 178:	ec06                	sd	ra,24(sp)
 17a:	e822                	sd	s0,16(sp)
 17c:	e426                	sd	s1,8(sp)
 17e:	e04a                	sd	s2,0(sp)
 180:	1000                	addi	s0,sp,32
 182:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 184:	4581                	li	a1,0
 186:	18e000ef          	jal	ra,314 <open>
  if(fd < 0)
 18a:	02054163          	bltz	a0,1ac <stat+0x36>
 18e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 190:	85ca                	mv	a1,s2
 192:	19a000ef          	jal	ra,32c <fstat>
 196:	892a                	mv	s2,a0
  close(fd);
 198:	8526                	mv	a0,s1
 19a:	162000ef          	jal	ra,2fc <close>
  return r;
}
 19e:	854a                	mv	a0,s2
 1a0:	60e2                	ld	ra,24(sp)
 1a2:	6442                	ld	s0,16(sp)
 1a4:	64a2                	ld	s1,8(sp)
 1a6:	6902                	ld	s2,0(sp)
 1a8:	6105                	addi	sp,sp,32
 1aa:	8082                	ret
    return -1;
 1ac:	597d                	li	s2,-1
 1ae:	bfc5                	j	19e <stat+0x28>

00000000000001b0 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1b6:	00054603          	lbu	a2,0(a0)
 1ba:	fd06079b          	addiw	a5,a2,-48
 1be:	0ff7f793          	andi	a5,a5,255
 1c2:	4725                	li	a4,9
 1c4:	02f76963          	bltu	a4,a5,1f6 <atoi+0x46>
 1c8:	86aa                	mv	a3,a0
  n = 0;
 1ca:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1cc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ce:	0685                	addi	a3,a3,1
 1d0:	0025179b          	slliw	a5,a0,0x2
 1d4:	9fa9                	addw	a5,a5,a0
 1d6:	0017979b          	slliw	a5,a5,0x1
 1da:	9fb1                	addw	a5,a5,a2
 1dc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e0:	0006c603          	lbu	a2,0(a3)
 1e4:	fd06071b          	addiw	a4,a2,-48
 1e8:	0ff77713          	andi	a4,a4,255
 1ec:	fee5f1e3          	bgeu	a1,a4,1ce <atoi+0x1e>
  return n;
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret
  n = 0;
 1f6:	4501                	li	a0,0
 1f8:	bfe5                	j	1f0 <atoi+0x40>

00000000000001fa <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 200:	02b57463          	bgeu	a0,a1,228 <memmove+0x2e>
    while(n-- > 0)
 204:	00c05f63          	blez	a2,222 <memmove+0x28>
 208:	1602                	slli	a2,a2,0x20
 20a:	9201                	srli	a2,a2,0x20
 20c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 210:	872a                	mv	a4,a0
      *dst++ = *src++;
 212:	0585                	addi	a1,a1,1
 214:	0705                	addi	a4,a4,1
 216:	fff5c683          	lbu	a3,-1(a1)
 21a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 21e:	fee79ae3          	bne	a5,a4,212 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
    dst += n;
 228:	00c50733          	add	a4,a0,a2
    src += n;
 22c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 22e:	fec05ae3          	blez	a2,222 <memmove+0x28>
 232:	fff6079b          	addiw	a5,a2,-1
 236:	1782                	slli	a5,a5,0x20
 238:	9381                	srli	a5,a5,0x20
 23a:	fff7c793          	not	a5,a5
 23e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 240:	15fd                	addi	a1,a1,-1
 242:	177d                	addi	a4,a4,-1
 244:	0005c683          	lbu	a3,0(a1)
 248:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 24c:	fee79ae3          	bne	a5,a4,240 <memmove+0x46>
 250:	bfc9                	j	222 <memmove+0x28>

0000000000000252 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 258:	ca05                	beqz	a2,288 <memcmp+0x36>
 25a:	fff6069b          	addiw	a3,a2,-1
 25e:	1682                	slli	a3,a3,0x20
 260:	9281                	srli	a3,a3,0x20
 262:	0685                	addi	a3,a3,1
 264:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 266:	00054783          	lbu	a5,0(a0)
 26a:	0005c703          	lbu	a4,0(a1)
 26e:	00e79863          	bne	a5,a4,27e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 272:	0505                	addi	a0,a0,1
    p2++;
 274:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 276:	fed518e3          	bne	a0,a3,266 <memcmp+0x14>
  }
  return 0;
 27a:	4501                	li	a0,0
 27c:	a019                	j	282 <memcmp+0x30>
      return *p1 - *p2;
 27e:	40e7853b          	subw	a0,a5,a4
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
  return 0;
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <memcmp+0x30>

000000000000028c <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 294:	f67ff0ef          	jal	ra,1fa <memmove>
}
 298:	60a2                	ld	ra,8(sp)
 29a:	6402                	ld	s0,0(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e406                	sd	ra,8(sp)
 2a4:	e022                	sd	s0,0(sp)
 2a6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2a8:	4585                	li	a1,1
 2aa:	0b2000ef          	jal	ra,35c <sys_sbrk>
}
 2ae:	60a2                	ld	ra,8(sp)
 2b0:	6402                	ld	s0,0(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret

00000000000002b6 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e406                	sd	ra,8(sp)
 2ba:	e022                	sd	s0,0(sp)
 2bc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2be:	4589                	li	a1,2
 2c0:	09c000ef          	jal	ra,35c <sys_sbrk>
}
 2c4:	60a2                	ld	ra,8(sp)
 2c6:	6402                	ld	s0,0(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret

00000000000002cc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2cc:	4885                	li	a7,1
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d4:	4889                	li	a7,2
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2dc:	488d                	li	a7,3
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e4:	4891                	li	a7,4
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <read>:
.global read
read:
 li a7, SYS_read
 2ec:	4895                	li	a7,5
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <write>:
.global write
write:
 li a7, SYS_write
 2f4:	48c1                	li	a7,16
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <close>:
.global close
close:
 li a7, SYS_close
 2fc:	48d5                	li	a7,21
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <kill>:
.global kill
kill:
 li a7, SYS_kill
 304:	4899                	li	a7,6
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <exec>:
.global exec
exec:
 li a7, SYS_exec
 30c:	489d                	li	a7,7
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <open>:
.global open
open:
 li a7, SYS_open
 314:	48bd                	li	a7,15
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31c:	48c5                	li	a7,17
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 324:	48c9                	li	a7,18
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32c:	48a1                	li	a7,8
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <link>:
.global link
link:
 li a7, SYS_link
 334:	48cd                	li	a7,19
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33c:	48d1                	li	a7,20
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 344:	48a5                	li	a7,9
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <dup>:
.global dup
dup:
 li a7, SYS_dup
 34c:	48a9                	li	a7,10
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 354:	48ad                	li	a7,11
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 35c:	48b1                	li	a7,12
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <pause>:
.global pause
pause:
 li a7, SYS_pause
 364:	48b5                	li	a7,13
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36c:	48b9                	li	a7,14
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 374:	48d9                	li	a7,22
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 37c:	48dd                	li	a7,23
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 384:	48e1                	li	a7,24
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 38c:	48e5                	li	a7,25
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 394:	48e9                	li	a7,26
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 39c:	48ed                	li	a7,27
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3a4:	48f1                	li	a7,28
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3ac:	48f5                	li	a7,29
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 3b4:	1101                	addi	sp,sp,-32
 3b6:	ec06                	sd	ra,24(sp)
 3b8:	e822                	sd	s0,16(sp)
 3ba:	1000                	addi	s0,sp,32
 3bc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c0:	4605                	li	a2,1
 3c2:	fef40593          	addi	a1,s0,-17
 3c6:	f2fff0ef          	jal	ra,2f4 <write>
}
 3ca:	60e2                	ld	ra,24(sp)
 3cc:	6442                	ld	s0,16(sp)
 3ce:	6105                	addi	sp,sp,32
 3d0:	8082                	ret

00000000000003d2 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 3d2:	715d                	addi	sp,sp,-80
 3d4:	e486                	sd	ra,72(sp)
 3d6:	e0a2                	sd	s0,64(sp)
 3d8:	fc26                	sd	s1,56(sp)
 3da:	f84a                	sd	s2,48(sp)
 3dc:	f44e                	sd	s3,40(sp)
 3de:	0880                	addi	s0,sp,80
 3e0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3e2:	c299                	beqz	a3,3e8 <printint+0x16>
 3e4:	0805c163          	bltz	a1,466 <printint+0x94>
  neg = 0;
 3e8:	4881                	li	a7,0
 3ea:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ee:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3f0:	00000517          	auipc	a0,0x0
 3f4:	52050513          	addi	a0,a0,1312 # 910 <digits>
 3f8:	883e                	mv	a6,a5
 3fa:	2785                	addiw	a5,a5,1
 3fc:	02c5f733          	remu	a4,a1,a2
 400:	972a                	add	a4,a4,a0
 402:	00074703          	lbu	a4,0(a4)
 406:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 40a:	872e                	mv	a4,a1
 40c:	02c5d5b3          	divu	a1,a1,a2
 410:	0685                	addi	a3,a3,1
 412:	fec773e3          	bgeu	a4,a2,3f8 <printint+0x26>
  if(neg)
 416:	00088b63          	beqz	a7,42c <printint+0x5a>
    buf[i++] = '-';
 41a:	fd040713          	addi	a4,s0,-48
 41e:	97ba                	add	a5,a5,a4
 420:	02d00713          	li	a4,45
 424:	fee78423          	sb	a4,-24(a5)
 428:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 42c:	02f05663          	blez	a5,458 <printint+0x86>
 430:	fb840713          	addi	a4,s0,-72
 434:	00f704b3          	add	s1,a4,a5
 438:	fff70993          	addi	s3,a4,-1
 43c:	99be                	add	s3,s3,a5
 43e:	37fd                	addiw	a5,a5,-1
 440:	1782                	slli	a5,a5,0x20
 442:	9381                	srli	a5,a5,0x20
 444:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 448:	fff4c583          	lbu	a1,-1(s1)
 44c:	854a                	mv	a0,s2
 44e:	f67ff0ef          	jal	ra,3b4 <putc>
  while(--i >= 0)
 452:	14fd                	addi	s1,s1,-1
 454:	ff349ae3          	bne	s1,s3,448 <printint+0x76>
}
 458:	60a6                	ld	ra,72(sp)
 45a:	6406                	ld	s0,64(sp)
 45c:	74e2                	ld	s1,56(sp)
 45e:	7942                	ld	s2,48(sp)
 460:	79a2                	ld	s3,40(sp)
 462:	6161                	addi	sp,sp,80
 464:	8082                	ret
    x = -xx;
 466:	40b005b3          	neg	a1,a1
    neg = 1;
 46a:	4885                	li	a7,1
    x = -xx;
 46c:	bfbd                	j	3ea <printint+0x18>

000000000000046e <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 46e:	7119                	addi	sp,sp,-128
 470:	fc86                	sd	ra,120(sp)
 472:	f8a2                	sd	s0,112(sp)
 474:	f4a6                	sd	s1,104(sp)
 476:	f0ca                	sd	s2,96(sp)
 478:	ecce                	sd	s3,88(sp)
 47a:	e8d2                	sd	s4,80(sp)
 47c:	e4d6                	sd	s5,72(sp)
 47e:	e0da                	sd	s6,64(sp)
 480:	fc5e                	sd	s7,56(sp)
 482:	f862                	sd	s8,48(sp)
 484:	f466                	sd	s9,40(sp)
 486:	f06a                	sd	s10,32(sp)
 488:	ec6e                	sd	s11,24(sp)
 48a:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48c:	0005c903          	lbu	s2,0(a1)
 490:	24090c63          	beqz	s2,6e8 <vprintf+0x27a>
 494:	8b2a                	mv	s6,a0
 496:	8a2e                	mv	s4,a1
 498:	8bb2                	mv	s7,a2
  state = 0;
 49a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 49c:	4481                	li	s1,0
 49e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4a0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4a8:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4ac:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4b0:	00000c97          	auipc	s9,0x0
 4b4:	460c8c93          	addi	s9,s9,1120 # 910 <digits>
 4b8:	a005                	j	4d8 <vprintf+0x6a>
        putc(fd, c0);
 4ba:	85ca                	mv	a1,s2
 4bc:	855a                	mv	a0,s6
 4be:	ef7ff0ef          	jal	ra,3b4 <putc>
 4c2:	a019                	j	4c8 <vprintf+0x5a>
    } else if(state == '%'){
 4c4:	03598263          	beq	s3,s5,4e8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4c8:	2485                	addiw	s1,s1,1
 4ca:	8726                	mv	a4,s1
 4cc:	009a07b3          	add	a5,s4,s1
 4d0:	0007c903          	lbu	s2,0(a5)
 4d4:	20090a63          	beqz	s2,6e8 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4dc:	fe0994e3          	bnez	s3,4c4 <vprintf+0x56>
      if(c0 == '%'){
 4e0:	fd579de3          	bne	a5,s5,4ba <vprintf+0x4c>
        state = '%';
 4e4:	89be                	mv	s3,a5
 4e6:	b7cd                	j	4c8 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4e8:	c3c1                	beqz	a5,568 <vprintf+0xfa>
 4ea:	00ea06b3          	add	a3,s4,a4
 4ee:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4f2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4f4:	c681                	beqz	a3,4fc <vprintf+0x8e>
 4f6:	9752                	add	a4,a4,s4
 4f8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4fc:	03878e63          	beq	a5,s8,538 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 500:	05a78863          	beq	a5,s10,550 <vprintf+0xe2>
      } else if(c0 == 'u'){
 504:	0db78b63          	beq	a5,s11,5da <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 508:	07800713          	li	a4,120
 50c:	10e78d63          	beq	a5,a4,626 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 510:	07000713          	li	a4,112
 514:	14e78263          	beq	a5,a4,658 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 518:	06300713          	li	a4,99
 51c:	16e78f63          	beq	a5,a4,69a <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 520:	07300713          	li	a4,115
 524:	18e78563          	beq	a5,a4,6ae <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 528:	05579063          	bne	a5,s5,568 <vprintf+0xfa>
        putc(fd, '%');
 52c:	85d6                	mv	a1,s5
 52e:	855a                	mv	a0,s6
 530:	e85ff0ef          	jal	ra,3b4 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 534:	4981                	li	s3,0
 536:	bf49                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 538:	008b8913          	addi	s2,s7,8
 53c:	4685                	li	a3,1
 53e:	4629                	li	a2,10
 540:	000ba583          	lw	a1,0(s7)
 544:	855a                	mv	a0,s6
 546:	e8dff0ef          	jal	ra,3d2 <printint>
 54a:	8bca                	mv	s7,s2
      state = 0;
 54c:	4981                	li	s3,0
 54e:	bfad                	j	4c8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 550:	03868663          	beq	a3,s8,57c <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 554:	05a68163          	beq	a3,s10,596 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 558:	09b68d63          	beq	a3,s11,5f2 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 55c:	03a68f63          	beq	a3,s10,59a <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 560:	07800793          	li	a5,120
 564:	0cf68d63          	beq	a3,a5,63e <vprintf+0x1d0>
        putc(fd, '%');
 568:	85d6                	mv	a1,s5
 56a:	855a                	mv	a0,s6
 56c:	e49ff0ef          	jal	ra,3b4 <putc>
        putc(fd, c0);
 570:	85ca                	mv	a1,s2
 572:	855a                	mv	a0,s6
 574:	e41ff0ef          	jal	ra,3b4 <putc>
      state = 0;
 578:	4981                	li	s3,0
 57a:	b7b9                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 57c:	008b8913          	addi	s2,s7,8
 580:	4685                	li	a3,1
 582:	4629                	li	a2,10
 584:	000bb583          	ld	a1,0(s7)
 588:	855a                	mv	a0,s6
 58a:	e49ff0ef          	jal	ra,3d2 <printint>
        i += 1;
 58e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
        i += 1;
 594:	bf15                	j	4c8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 596:	03860563          	beq	a2,s8,5c0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 59a:	07b60963          	beq	a2,s11,60c <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 59e:	07800793          	li	a5,120
 5a2:	fcf613e3          	bne	a2,a5,568 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5a6:	008b8913          	addi	s2,s7,8
 5aa:	4681                	li	a3,0
 5ac:	4641                	li	a2,16
 5ae:	000bb583          	ld	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	e1fff0ef          	jal	ra,3d2 <printint>
        i += 2;
 5b8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ba:	8bca                	mv	s7,s2
      state = 0;
 5bc:	4981                	li	s3,0
        i += 2;
 5be:	b729                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4685                	li	a3,1
 5c6:	4629                	li	a2,10
 5c8:	000bb583          	ld	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	e05ff0ef          	jal	ra,3d2 <printint>
        i += 2;
 5d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
        i += 2;
 5d8:	bdc5                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4681                	li	a3,0
 5e0:	4629                	li	a2,10
 5e2:	000be583          	lwu	a1,0(s7)
 5e6:	855a                	mv	a0,s6
 5e8:	debff0ef          	jal	ra,3d2 <printint>
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bde1                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4681                	li	a3,0
 5f8:	4629                	li	a2,10
 5fa:	000bb583          	ld	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	dd3ff0ef          	jal	ra,3d2 <printint>
        i += 1;
 604:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
        i += 1;
 60a:	bd7d                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4629                	li	a2,10
 614:	000bb583          	ld	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	db9ff0ef          	jal	ra,3d2 <printint>
        i += 2;
 61e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 620:	8bca                	mv	s7,s2
      state = 0;
 622:	4981                	li	s3,0
        i += 2;
 624:	b555                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 626:	008b8913          	addi	s2,s7,8
 62a:	4681                	li	a3,0
 62c:	4641                	li	a2,16
 62e:	000be583          	lwu	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	d9fff0ef          	jal	ra,3d2 <printint>
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b571                	j	4c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63e:	008b8913          	addi	s2,s7,8
 642:	4681                	li	a3,0
 644:	4641                	li	a2,16
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	d87ff0ef          	jal	ra,3d2 <printint>
        i += 1;
 650:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
        i += 1;
 656:	bd8d                	j	4c8 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 658:	008b8793          	addi	a5,s7,8
 65c:	f8f43423          	sd	a5,-120(s0)
 660:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 664:	03000593          	li	a1,48
 668:	855a                	mv	a0,s6
 66a:	d4bff0ef          	jal	ra,3b4 <putc>
  putc(fd, 'x');
 66e:	07800593          	li	a1,120
 672:	855a                	mv	a0,s6
 674:	d41ff0ef          	jal	ra,3b4 <putc>
 678:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67a:	03c9d793          	srli	a5,s3,0x3c
 67e:	97e6                	add	a5,a5,s9
 680:	0007c583          	lbu	a1,0(a5)
 684:	855a                	mv	a0,s6
 686:	d2fff0ef          	jal	ra,3b4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 68a:	0992                	slli	s3,s3,0x4
 68c:	397d                	addiw	s2,s2,-1
 68e:	fe0916e3          	bnez	s2,67a <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 692:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 696:	4981                	li	s3,0
 698:	bd05                	j	4c8 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 69a:	008b8913          	addi	s2,s7,8
 69e:	000bc583          	lbu	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	d11ff0ef          	jal	ra,3b4 <putc>
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	bd31                	j	4c8 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6ae:	008b8993          	addi	s3,s7,8
 6b2:	000bb903          	ld	s2,0(s7)
 6b6:	00090f63          	beqz	s2,6d4 <vprintf+0x266>
        for(; *s; s++)
 6ba:	00094583          	lbu	a1,0(s2)
 6be:	c195                	beqz	a1,6e2 <vprintf+0x274>
          putc(fd, *s);
 6c0:	855a                	mv	a0,s6
 6c2:	cf3ff0ef          	jal	ra,3b4 <putc>
        for(; *s; s++)
 6c6:	0905                	addi	s2,s2,1
 6c8:	00094583          	lbu	a1,0(s2)
 6cc:	f9f5                	bnez	a1,6c0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6ce:	8bce                	mv	s7,s3
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bbdd                	j	4c8 <vprintf+0x5a>
          s = "(null)";
 6d4:	00000917          	auipc	s2,0x0
 6d8:	23490913          	addi	s2,s2,564 # 908 <malloc+0x11e>
        for(; *s; s++)
 6dc:	02800593          	li	a1,40
 6e0:	b7c5                	j	6c0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6e2:	8bce                	mv	s7,s3
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b3cd                	j	4c8 <vprintf+0x5a>
    }
  }
}
 6e8:	70e6                	ld	ra,120(sp)
 6ea:	7446                	ld	s0,112(sp)
 6ec:	74a6                	ld	s1,104(sp)
 6ee:	7906                	ld	s2,96(sp)
 6f0:	69e6                	ld	s3,88(sp)
 6f2:	6a46                	ld	s4,80(sp)
 6f4:	6aa6                	ld	s5,72(sp)
 6f6:	6b06                	ld	s6,64(sp)
 6f8:	7be2                	ld	s7,56(sp)
 6fa:	7c42                	ld	s8,48(sp)
 6fc:	7ca2                	ld	s9,40(sp)
 6fe:	7d02                	ld	s10,32(sp)
 700:	6de2                	ld	s11,24(sp)
 702:	6109                	addi	sp,sp,128
 704:	8082                	ret

0000000000000706 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 706:	715d                	addi	sp,sp,-80
 708:	ec06                	sd	ra,24(sp)
 70a:	e822                	sd	s0,16(sp)
 70c:	1000                	addi	s0,sp,32
 70e:	e010                	sd	a2,0(s0)
 710:	e414                	sd	a3,8(s0)
 712:	e818                	sd	a4,16(s0)
 714:	ec1c                	sd	a5,24(s0)
 716:	03043023          	sd	a6,32(s0)
 71a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 722:	8622                	mv	a2,s0
 724:	d4bff0ef          	jal	ra,46e <vprintf>
}
 728:	60e2                	ld	ra,24(sp)
 72a:	6442                	ld	s0,16(sp)
 72c:	6161                	addi	sp,sp,80
 72e:	8082                	ret

0000000000000730 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 730:	711d                	addi	sp,sp,-96
 732:	ec06                	sd	ra,24(sp)
 734:	e822                	sd	s0,16(sp)
 736:	1000                	addi	s0,sp,32
 738:	e40c                	sd	a1,8(s0)
 73a:	e810                	sd	a2,16(s0)
 73c:	ec14                	sd	a3,24(s0)
 73e:	f018                	sd	a4,32(s0)
 740:	f41c                	sd	a5,40(s0)
 742:	03043823          	sd	a6,48(s0)
 746:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74a:	00840613          	addi	a2,s0,8
 74e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 752:	85aa                	mv	a1,a0
 754:	4505                	li	a0,1
 756:	d19ff0ef          	jal	ra,46e <vprintf>
}
 75a:	60e2                	ld	ra,24(sp)
 75c:	6442                	ld	s0,16(sp)
 75e:	6125                	addi	sp,sp,96
 760:	8082                	ret

0000000000000762 <free>:
 *   无
 */

void
free(void *ap)
{
 762:	1141                	addi	sp,sp,-16
 764:	e422                	sd	s0,8(sp)
 766:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 768:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76c:	00001797          	auipc	a5,0x1
 770:	8947b783          	ld	a5,-1900(a5) # 1000 <freep>
 774:	a805                	j	7a4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 776:	4618                	lw	a4,8(a2)
 778:	9db9                	addw	a1,a1,a4
 77a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 77e:	6398                	ld	a4,0(a5)
 780:	6318                	ld	a4,0(a4)
 782:	fee53823          	sd	a4,-16(a0)
 786:	a091                	j	7ca <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 788:	ff852703          	lw	a4,-8(a0)
 78c:	9e39                	addw	a2,a2,a4
 78e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 790:	ff053703          	ld	a4,-16(a0)
 794:	e398                	sd	a4,0(a5)
 796:	a099                	j	7dc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 798:	6398                	ld	a4,0(a5)
 79a:	00e7e463          	bltu	a5,a4,7a2 <free+0x40>
 79e:	00e6ea63          	bltu	a3,a4,7b2 <free+0x50>
{
 7a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	fed7fae3          	bgeu	a5,a3,798 <free+0x36>
 7a8:	6398                	ld	a4,0(a5)
 7aa:	00e6e463          	bltu	a3,a4,7b2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	fee7eae3          	bltu	a5,a4,7a2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7b2:	ff852583          	lw	a1,-8(a0)
 7b6:	6390                	ld	a2,0(a5)
 7b8:	02059713          	slli	a4,a1,0x20
 7bc:	9301                	srli	a4,a4,0x20
 7be:	0712                	slli	a4,a4,0x4
 7c0:	9736                	add	a4,a4,a3
 7c2:	fae60ae3          	beq	a2,a4,776 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ca:	4790                	lw	a2,8(a5)
 7cc:	02061713          	slli	a4,a2,0x20
 7d0:	9301                	srli	a4,a4,0x20
 7d2:	0712                	slli	a4,a4,0x4
 7d4:	973e                	add	a4,a4,a5
 7d6:	fae689e3          	beq	a3,a4,788 <free+0x26>
  } else
    p->s.ptr = bp;
 7da:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82f73223          	sd	a5,-2012(a4) # 1000 <freep>
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret

00000000000007ea <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 7ea:	7139                	addi	sp,sp,-64
 7ec:	fc06                	sd	ra,56(sp)
 7ee:	f822                	sd	s0,48(sp)
 7f0:	f426                	sd	s1,40(sp)
 7f2:	f04a                	sd	s2,32(sp)
 7f4:	ec4e                	sd	s3,24(sp)
 7f6:	e852                	sd	s4,16(sp)
 7f8:	e456                	sd	s5,8(sp)
 7fa:	e05a                	sd	s6,0(sp)
 7fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fe:	02051493          	slli	s1,a0,0x20
 802:	9081                	srli	s1,s1,0x20
 804:	04bd                	addi	s1,s1,15
 806:	8091                	srli	s1,s1,0x4
 808:	0014899b          	addiw	s3,s1,1
 80c:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 80e:	00000517          	auipc	a0,0x0
 812:	7f253503          	ld	a0,2034(a0) # 1000 <freep>
 816:	c515                	beqz	a0,842 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 81a:	4798                	lw	a4,8(a5)
 81c:	02977f63          	bgeu	a4,s1,85a <malloc+0x70>
 820:	8a4e                	mv	s4,s3
 822:	0009871b          	sext.w	a4,s3
 826:	6685                	lui	a3,0x1
 828:	00d77363          	bgeu	a4,a3,82e <malloc+0x44>
 82c:	6a05                	lui	s4,0x1
 82e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 832:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 836:	00000917          	auipc	s2,0x0
 83a:	7ca90913          	addi	s2,s2,1994 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 83e:	5afd                	li	s5,-1
 840:	a0bd                	j	8ae <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 842:	00000797          	auipc	a5,0x0
 846:	7ce78793          	addi	a5,a5,1998 # 1010 <base>
 84a:	00000717          	auipc	a4,0x0
 84e:	7af73b23          	sd	a5,1974(a4) # 1000 <freep>
 852:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 854:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 858:	b7e1                	j	820 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 85a:	02e48b63          	beq	s1,a4,890 <malloc+0xa6>
        p->s.size -= nunits;
 85e:	4137073b          	subw	a4,a4,s3
 862:	c798                	sw	a4,8(a5)
        p += p->s.size;
 864:	1702                	slli	a4,a4,0x20
 866:	9301                	srli	a4,a4,0x20
 868:	0712                	slli	a4,a4,0x4
 86a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 86c:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 870:	00000717          	auipc	a4,0x0
 874:	78a73823          	sd	a0,1936(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 878:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 87c:	70e2                	ld	ra,56(sp)
 87e:	7442                	ld	s0,48(sp)
 880:	74a2                	ld	s1,40(sp)
 882:	7902                	ld	s2,32(sp)
 884:	69e2                	ld	s3,24(sp)
 886:	6a42                	ld	s4,16(sp)
 888:	6aa2                	ld	s5,8(sp)
 88a:	6b02                	ld	s6,0(sp)
 88c:	6121                	addi	sp,sp,64
 88e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 890:	6398                	ld	a4,0(a5)
 892:	e118                	sd	a4,0(a0)
 894:	bff1                	j	870 <malloc+0x86>
  hp->s.size = nu;
 896:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 89a:	0541                	addi	a0,a0,16
 89c:	ec7ff0ef          	jal	ra,762 <free>
  return freep;
 8a0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a4:	dd61                	beqz	a0,87c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8a8:	4798                	lw	a4,8(a5)
 8aa:	fa9778e3          	bgeu	a4,s1,85a <malloc+0x70>
    if(p == freep)
 8ae:	00093703          	ld	a4,0(s2)
 8b2:	853e                	mv	a0,a5
 8b4:	fef719e3          	bne	a4,a5,8a6 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8b8:	8552                	mv	a0,s4
 8ba:	9e7ff0ef          	jal	ra,2a0 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8be:	fd551ce3          	bne	a0,s5,896 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 8c2:	4501                	li	a0,0
 8c4:	bf65                	j	87c <malloc+0x92>
