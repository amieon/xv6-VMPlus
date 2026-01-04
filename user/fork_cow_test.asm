
user/_fork_cow_test：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define NPAGES 64   // 64 pages = 256KB

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *p = sbrk(NPAGES * 4096);
   a:	00040537          	lui	a0,0x40
   e:	2c8000ef          	jal	ra,2d6 <sbrk>
  if(p == (char*)-1){
  12:	57fd                	li	a5,-1
  14:	02f50963          	beq	a0,a5,46 <main+0x46>
  18:	84aa                	mv	s1,a0
  1a:	87aa                	mv	a5,a0
  1c:	00040737          	lui	a4,0x40
  20:	972a                	add	a4,a4,a0
    exit(1);
  }

  // 预触发页，确保真的分配
  for(int i = 0; i < NPAGES * 4096; i += 4096)
    p[i] = 1;
  22:	4605                	li	a2,1
  for(int i = 0; i < NPAGES * 4096; i += 4096)
  24:	6685                	lui	a3,0x1
    p[i] = 1;
  26:	00c78023          	sb	a2,0(a5)
  for(int i = 0; i < NPAGES * 4096; i += 4096)
  2a:	97b6                	add	a5,a5,a3
  2c:	fee79de3          	bne	a5,a4,26 <main+0x26>

  int pid = fork();
  30:	2d2000ef          	jal	ra,302 <fork>
  if(pid < 0){
  34:	02054263          	bltz	a0,58 <main+0x58>
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
  38:	e90d                	bnez	a0,6a <main+0x6a>
    // 子进程：只写第一页
    p[0] = 42;
  3a:	02a00793          	li	a5,42
  3e:	00f48023          	sb	a5,0(s1)
    exit(0);
  42:	2c8000ef          	jal	ra,30a <exit>
    printf("alloc failed\n");
  46:	00001517          	auipc	a0,0x1
  4a:	8ba50513          	addi	a0,a0,-1862 # 900 <malloc+0xe6>
  4e:	718000ef          	jal	ra,766 <printf>
    exit(1);
  52:	4505                	li	a0,1
  54:	2b6000ef          	jal	ra,30a <exit>
    printf("fork failed\n");
  58:	00001517          	auipc	a0,0x1
  5c:	8b850513          	addi	a0,a0,-1864 # 910 <malloc+0xf6>
  60:	706000ef          	jal	ra,766 <printf>
    exit(1);
  64:	4505                	li	a0,1
  66:	2a4000ef          	jal	ra,30a <exit>
  }

  wait(0);
  6a:	4501                	li	a0,0
  6c:	2a6000ef          	jal	ra,312 <wait>
  exit(0);
  70:	4501                	li	a0,0
  72:	298000ef          	jal	ra,30a <exit>

0000000000000076 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  76:	1141                	addi	sp,sp,-16
  78:	e406                	sd	ra,8(sp)
  7a:	e022                	sd	s0,0(sp)
  7c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  7e:	f83ff0ef          	jal	ra,0 <main>
  exit(r);
  82:	288000ef          	jal	ra,30a <exit>

0000000000000086 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  86:	1141                	addi	sp,sp,-16
  88:	e422                	sd	s0,8(sp)
  8a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8c:	87aa                	mv	a5,a0
  8e:	0585                	addi	a1,a1,1
  90:	0785                	addi	a5,a5,1
  92:	fff5c703          	lbu	a4,-1(a1)
  96:	fee78fa3          	sb	a4,-1(a5)
  9a:	fb75                	bnez	a4,8e <strcpy+0x8>
    ;
  return os;
}
  9c:	6422                	ld	s0,8(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret

00000000000000a2 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e422                	sd	s0,8(sp)
  a6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a8:	00054783          	lbu	a5,0(a0)
  ac:	cb91                	beqz	a5,c0 <strcmp+0x1e>
  ae:	0005c703          	lbu	a4,0(a1)
  b2:	00f71763          	bne	a4,a5,c0 <strcmp+0x1e>
    p++, q++;
  b6:	0505                	addi	a0,a0,1
  b8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ba:	00054783          	lbu	a5,0(a0)
  be:	fbe5                	bnez	a5,ae <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c0:	0005c503          	lbu	a0,0(a1)
}
  c4:	40a7853b          	subw	a0,a5,a0
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret

00000000000000ce <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d4:	00054783          	lbu	a5,0(a0)
  d8:	cf91                	beqz	a5,f4 <strlen+0x26>
  da:	0505                	addi	a0,a0,1
  dc:	87aa                	mv	a5,a0
  de:	4685                	li	a3,1
  e0:	9e89                	subw	a3,a3,a0
  e2:	00f6853b          	addw	a0,a3,a5
  e6:	0785                	addi	a5,a5,1
  e8:	fff7c703          	lbu	a4,-1(a5)
  ec:	fb7d                	bnez	a4,e2 <strlen+0x14>
    ;
  return n;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret
  for(n = 0; s[n]; n++)
  f4:	4501                	li	a0,0
  f6:	bfe5                	j	ee <strlen+0x20>

00000000000000f8 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fe:	ca19                	beqz	a2,114 <memset+0x1c>
 100:	87aa                	mv	a5,a0
 102:	1602                	slli	a2,a2,0x20
 104:	9201                	srli	a2,a2,0x20
 106:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10e:	0785                	addi	a5,a5,1
 110:	fee79de3          	bne	a5,a4,10a <memset+0x12>
  }
  return dst;
}
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 120:	00054783          	lbu	a5,0(a0)
 124:	cb99                	beqz	a5,13a <strchr+0x20>
    if(*s == c)
 126:	00f58763          	beq	a1,a5,134 <strchr+0x1a>
  for(; *s; s++)
 12a:	0505                	addi	a0,a0,1
 12c:	00054783          	lbu	a5,0(a0)
 130:	fbfd                	bnez	a5,126 <strchr+0xc>
      return (char*)s;
  return 0;
 132:	4501                	li	a0,0
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret
  return 0;
 13a:	4501                	li	a0,0
 13c:	bfe5                	j	134 <strchr+0x1a>

000000000000013e <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 13e:	711d                	addi	sp,sp,-96
 140:	ec86                	sd	ra,88(sp)
 142:	e8a2                	sd	s0,80(sp)
 144:	e4a6                	sd	s1,72(sp)
 146:	e0ca                	sd	s2,64(sp)
 148:	fc4e                	sd	s3,56(sp)
 14a:	f852                	sd	s4,48(sp)
 14c:	f456                	sd	s5,40(sp)
 14e:	f05a                	sd	s6,32(sp)
 150:	ec5e                	sd	s7,24(sp)
 152:	1080                	addi	s0,sp,96
 154:	8baa                	mv	s7,a0
 156:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 158:	892a                	mv	s2,a0
 15a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15c:	4aa9                	li	s5,10
 15e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 160:	89a6                	mv	s3,s1
 162:	2485                	addiw	s1,s1,1
 164:	0344d663          	bge	s1,s4,190 <gets+0x52>
    cc = read(0, &c, 1);
 168:	4605                	li	a2,1
 16a:	faf40593          	addi	a1,s0,-81
 16e:	4501                	li	a0,0
 170:	1b2000ef          	jal	ra,322 <read>
    if(cc < 1)
 174:	00a05e63          	blez	a0,190 <gets+0x52>
    buf[i++] = c;
 178:	faf44783          	lbu	a5,-81(s0)
 17c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 180:	01578763          	beq	a5,s5,18e <gets+0x50>
 184:	0905                	addi	s2,s2,1
 186:	fd679de3          	bne	a5,s6,160 <gets+0x22>
  for(i=0; i+1 < max; ){
 18a:	89a6                	mv	s3,s1
 18c:	a011                	j	190 <gets+0x52>
 18e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 190:	99de                	add	s3,s3,s7
 192:	00098023          	sb	zero,0(s3)
  return buf;
}
 196:	855e                	mv	a0,s7
 198:	60e6                	ld	ra,88(sp)
 19a:	6446                	ld	s0,80(sp)
 19c:	64a6                	ld	s1,72(sp)
 19e:	6906                	ld	s2,64(sp)
 1a0:	79e2                	ld	s3,56(sp)
 1a2:	7a42                	ld	s4,48(sp)
 1a4:	7aa2                	ld	s5,40(sp)
 1a6:	7b02                	ld	s6,32(sp)
 1a8:	6be2                	ld	s7,24(sp)
 1aa:	6125                	addi	sp,sp,96
 1ac:	8082                	ret

00000000000001ae <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	e04a                	sd	s2,0(sp)
 1b8:	1000                	addi	s0,sp,32
 1ba:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1bc:	4581                	li	a1,0
 1be:	18c000ef          	jal	ra,34a <open>
  if(fd < 0)
 1c2:	02054163          	bltz	a0,1e4 <stat+0x36>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	198000ef          	jal	ra,362 <fstat>
 1ce:	892a                	mv	s2,a0
  close(fd);
 1d0:	8526                	mv	a0,s1
 1d2:	160000ef          	jal	ra,332 <close>
  return r;
}
 1d6:	854a                	mv	a0,s2
 1d8:	60e2                	ld	ra,24(sp)
 1da:	6442                	ld	s0,16(sp)
 1dc:	64a2                	ld	s1,8(sp)
 1de:	6902                	ld	s2,0(sp)
 1e0:	6105                	addi	sp,sp,32
 1e2:	8082                	ret
    return -1;
 1e4:	597d                	li	s2,-1
 1e6:	bfc5                	j	1d6 <stat+0x28>

00000000000001e8 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ee:	00054683          	lbu	a3,0(a0)
 1f2:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x6a8>
 1f6:	0ff7f793          	zext.b	a5,a5
 1fa:	4625                	li	a2,9
 1fc:	02f66863          	bltu	a2,a5,22c <atoi+0x44>
 200:	872a                	mv	a4,a0
  n = 0;
 202:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 204:	0705                	addi	a4,a4,1 # 40001 <base+0x3eff1>
 206:	0025179b          	slliw	a5,a0,0x2
 20a:	9fa9                	addw	a5,a5,a0
 20c:	0017979b          	slliw	a5,a5,0x1
 210:	9fb5                	addw	a5,a5,a3
 212:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 216:	00074683          	lbu	a3,0(a4)
 21a:	fd06879b          	addiw	a5,a3,-48
 21e:	0ff7f793          	zext.b	a5,a5
 222:	fef671e3          	bgeu	a2,a5,204 <atoi+0x1c>
  return n;
}
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret
  n = 0;
 22c:	4501                	li	a0,0
 22e:	bfe5                	j	226 <atoi+0x3e>

0000000000000230 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 236:	02b57463          	bgeu	a0,a1,25e <memmove+0x2e>
    while(n-- > 0)
 23a:	00c05f63          	blez	a2,258 <memmove+0x28>
 23e:	1602                	slli	a2,a2,0x20
 240:	9201                	srli	a2,a2,0x20
 242:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 246:	872a                	mv	a4,a0
      *dst++ = *src++;
 248:	0585                	addi	a1,a1,1
 24a:	0705                	addi	a4,a4,1
 24c:	fff5c683          	lbu	a3,-1(a1)
 250:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 254:	fee79ae3          	bne	a5,a4,248 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
    dst += n;
 25e:	00c50733          	add	a4,a0,a2
    src += n;
 262:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 264:	fec05ae3          	blez	a2,258 <memmove+0x28>
 268:	fff6079b          	addiw	a5,a2,-1
 26c:	1782                	slli	a5,a5,0x20
 26e:	9381                	srli	a5,a5,0x20
 270:	fff7c793          	not	a5,a5
 274:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 276:	15fd                	addi	a1,a1,-1
 278:	177d                	addi	a4,a4,-1
 27a:	0005c683          	lbu	a3,0(a1)
 27e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 282:	fee79ae3          	bne	a5,a4,276 <memmove+0x46>
 286:	bfc9                	j	258 <memmove+0x28>

0000000000000288 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 28e:	ca05                	beqz	a2,2be <memcmp+0x36>
 290:	fff6069b          	addiw	a3,a2,-1
 294:	1682                	slli	a3,a3,0x20
 296:	9281                	srli	a3,a3,0x20
 298:	0685                	addi	a3,a3,1
 29a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 29c:	00054783          	lbu	a5,0(a0)
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00e79863          	bne	a5,a4,2b4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2a8:	0505                	addi	a0,a0,1
    p2++;
 2aa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ac:	fed518e3          	bne	a0,a3,29c <memcmp+0x14>
  }
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	a019                	j	2b8 <memcmp+0x30>
      return *p1 - *p2;
 2b4:	40e7853b          	subw	a0,a5,a4
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  return 0;
 2be:	4501                	li	a0,0
 2c0:	bfe5                	j	2b8 <memcmp+0x30>

00000000000002c2 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e406                	sd	ra,8(sp)
 2c6:	e022                	sd	s0,0(sp)
 2c8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ca:	f67ff0ef          	jal	ra,230 <memmove>
}
 2ce:	60a2                	ld	ra,8(sp)
 2d0:	6402                	ld	s0,0(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret

00000000000002d6 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e406                	sd	ra,8(sp)
 2da:	e022                	sd	s0,0(sp)
 2dc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2de:	4585                	li	a1,1
 2e0:	0b2000ef          	jal	ra,392 <sys_sbrk>
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e406                	sd	ra,8(sp)
 2f0:	e022                	sd	s0,0(sp)
 2f2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2f4:	4589                	li	a1,2
 2f6:	09c000ef          	jal	ra,392 <sys_sbrk>
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret

0000000000000302 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 302:	4885                	li	a7,1
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <exit>:
.global exit
exit:
 li a7, SYS_exit
 30a:	4889                	li	a7,2
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <wait>:
.global wait
wait:
 li a7, SYS_wait
 312:	488d                	li	a7,3
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31a:	4891                	li	a7,4
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <read>:
.global read
read:
 li a7, SYS_read
 322:	4895                	li	a7,5
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <write>:
.global write
write:
 li a7, SYS_write
 32a:	48c1                	li	a7,16
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <close>:
.global close
close:
 li a7, SYS_close
 332:	48d5                	li	a7,21
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <kill>:
.global kill
kill:
 li a7, SYS_kill
 33a:	4899                	li	a7,6
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <exec>:
.global exec
exec:
 li a7, SYS_exec
 342:	489d                	li	a7,7
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <open>:
.global open
open:
 li a7, SYS_open
 34a:	48bd                	li	a7,15
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 352:	48c5                	li	a7,17
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35a:	48c9                	li	a7,18
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 362:	48a1                	li	a7,8
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <link>:
.global link
link:
 li a7, SYS_link
 36a:	48cd                	li	a7,19
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 372:	48d1                	li	a7,20
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37a:	48a5                	li	a7,9
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <dup>:
.global dup
dup:
 li a7, SYS_dup
 382:	48a9                	li	a7,10
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38a:	48ad                	li	a7,11
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 392:	48b1                	li	a7,12
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <pause>:
.global pause
pause:
 li a7, SYS_pause
 39a:	48b5                	li	a7,13
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a2:	48b9                	li	a7,14
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3aa:	48d9                	li	a7,22
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3b2:	48dd                	li	a7,23
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3ba:	48e1                	li	a7,24
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c2:	48e5                	li	a7,25
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 3ca:	48e9                	li	a7,26
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3d2:	48ed                	li	a7,27
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3da:	48f1                	li	a7,28
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3e2:	48f5                	li	a7,29
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 3ea:	1101                	addi	sp,sp,-32
 3ec:	ec06                	sd	ra,24(sp)
 3ee:	e822                	sd	s0,16(sp)
 3f0:	1000                	addi	s0,sp,32
 3f2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f6:	4605                	li	a2,1
 3f8:	fef40593          	addi	a1,s0,-17
 3fc:	f2fff0ef          	jal	ra,32a <write>
}
 400:	60e2                	ld	ra,24(sp)
 402:	6442                	ld	s0,16(sp)
 404:	6105                	addi	sp,sp,32
 406:	8082                	ret

0000000000000408 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 408:	715d                	addi	sp,sp,-80
 40a:	e486                	sd	ra,72(sp)
 40c:	e0a2                	sd	s0,64(sp)
 40e:	fc26                	sd	s1,56(sp)
 410:	f84a                	sd	s2,48(sp)
 412:	f44e                	sd	s3,40(sp)
 414:	0880                	addi	s0,sp,80
 416:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 418:	c299                	beqz	a3,41e <printint+0x16>
 41a:	0805c163          	bltz	a1,49c <printint+0x94>
  neg = 0;
 41e:	4881                	li	a7,0
 420:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 424:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 426:	00000517          	auipc	a0,0x0
 42a:	50250513          	addi	a0,a0,1282 # 928 <digits>
 42e:	883e                	mv	a6,a5
 430:	2785                	addiw	a5,a5,1
 432:	02c5f733          	remu	a4,a1,a2
 436:	972a                	add	a4,a4,a0
 438:	00074703          	lbu	a4,0(a4)
 43c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 440:	872e                	mv	a4,a1
 442:	02c5d5b3          	divu	a1,a1,a2
 446:	0685                	addi	a3,a3,1
 448:	fec773e3          	bgeu	a4,a2,42e <printint+0x26>
  if(neg)
 44c:	00088b63          	beqz	a7,462 <printint+0x5a>
    buf[i++] = '-';
 450:	fd078793          	addi	a5,a5,-48
 454:	97a2                	add	a5,a5,s0
 456:	02d00713          	li	a4,45
 45a:	fee78423          	sb	a4,-24(a5)
 45e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 462:	02f05663          	blez	a5,48e <printint+0x86>
 466:	fb840713          	addi	a4,s0,-72
 46a:	00f704b3          	add	s1,a4,a5
 46e:	fff70993          	addi	s3,a4,-1
 472:	99be                	add	s3,s3,a5
 474:	37fd                	addiw	a5,a5,-1
 476:	1782                	slli	a5,a5,0x20
 478:	9381                	srli	a5,a5,0x20
 47a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 47e:	fff4c583          	lbu	a1,-1(s1)
 482:	854a                	mv	a0,s2
 484:	f67ff0ef          	jal	ra,3ea <putc>
  while(--i >= 0)
 488:	14fd                	addi	s1,s1,-1
 48a:	ff349ae3          	bne	s1,s3,47e <printint+0x76>
}
 48e:	60a6                	ld	ra,72(sp)
 490:	6406                	ld	s0,64(sp)
 492:	74e2                	ld	s1,56(sp)
 494:	7942                	ld	s2,48(sp)
 496:	79a2                	ld	s3,40(sp)
 498:	6161                	addi	sp,sp,80
 49a:	8082                	ret
    x = -xx;
 49c:	40b005b3          	neg	a1,a1
    neg = 1;
 4a0:	4885                	li	a7,1
    x = -xx;
 4a2:	bfbd                	j	420 <printint+0x18>

00000000000004a4 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a4:	7119                	addi	sp,sp,-128
 4a6:	fc86                	sd	ra,120(sp)
 4a8:	f8a2                	sd	s0,112(sp)
 4aa:	f4a6                	sd	s1,104(sp)
 4ac:	f0ca                	sd	s2,96(sp)
 4ae:	ecce                	sd	s3,88(sp)
 4b0:	e8d2                	sd	s4,80(sp)
 4b2:	e4d6                	sd	s5,72(sp)
 4b4:	e0da                	sd	s6,64(sp)
 4b6:	fc5e                	sd	s7,56(sp)
 4b8:	f862                	sd	s8,48(sp)
 4ba:	f466                	sd	s9,40(sp)
 4bc:	f06a                	sd	s10,32(sp)
 4be:	ec6e                	sd	s11,24(sp)
 4c0:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c2:	0005c903          	lbu	s2,0(a1)
 4c6:	24090c63          	beqz	s2,71e <vprintf+0x27a>
 4ca:	8b2a                	mv	s6,a0
 4cc:	8a2e                	mv	s4,a1
 4ce:	8bb2                	mv	s7,a2
  state = 0;
 4d0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d2:	4481                	li	s1,0
 4d4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4d6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4de:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4e2:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4e6:	00000c97          	auipc	s9,0x0
 4ea:	442c8c93          	addi	s9,s9,1090 # 928 <digits>
 4ee:	a005                	j	50e <vprintf+0x6a>
        putc(fd, c0);
 4f0:	85ca                	mv	a1,s2
 4f2:	855a                	mv	a0,s6
 4f4:	ef7ff0ef          	jal	ra,3ea <putc>
 4f8:	a019                	j	4fe <vprintf+0x5a>
    } else if(state == '%'){
 4fa:	03598263          	beq	s3,s5,51e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4fe:	2485                	addiw	s1,s1,1
 500:	8726                	mv	a4,s1
 502:	009a07b3          	add	a5,s4,s1
 506:	0007c903          	lbu	s2,0(a5)
 50a:	20090a63          	beqz	s2,71e <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 50e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 512:	fe0994e3          	bnez	s3,4fa <vprintf+0x56>
      if(c0 == '%'){
 516:	fd579de3          	bne	a5,s5,4f0 <vprintf+0x4c>
        state = '%';
 51a:	89be                	mv	s3,a5
 51c:	b7cd                	j	4fe <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 51e:	c3c1                	beqz	a5,59e <vprintf+0xfa>
 520:	00ea06b3          	add	a3,s4,a4
 524:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 528:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 52a:	c681                	beqz	a3,532 <vprintf+0x8e>
 52c:	9752                	add	a4,a4,s4
 52e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 532:	03878e63          	beq	a5,s8,56e <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 536:	05a78863          	beq	a5,s10,586 <vprintf+0xe2>
      } else if(c0 == 'u'){
 53a:	0db78b63          	beq	a5,s11,610 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 53e:	07800713          	li	a4,120
 542:	10e78d63          	beq	a5,a4,65c <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 546:	07000713          	li	a4,112
 54a:	14e78263          	beq	a5,a4,68e <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 54e:	06300713          	li	a4,99
 552:	16e78f63          	beq	a5,a4,6d0 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 556:	07300713          	li	a4,115
 55a:	18e78563          	beq	a5,a4,6e4 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 55e:	05579063          	bne	a5,s5,59e <vprintf+0xfa>
        putc(fd, '%');
 562:	85d6                	mv	a1,s5
 564:	855a                	mv	a0,s6
 566:	e85ff0ef          	jal	ra,3ea <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 56a:	4981                	li	s3,0
 56c:	bf49                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 56e:	008b8913          	addi	s2,s7,8
 572:	4685                	li	a3,1
 574:	4629                	li	a2,10
 576:	000ba583          	lw	a1,0(s7)
 57a:	855a                	mv	a0,s6
 57c:	e8dff0ef          	jal	ra,408 <printint>
 580:	8bca                	mv	s7,s2
      state = 0;
 582:	4981                	li	s3,0
 584:	bfad                	j	4fe <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 586:	03868663          	beq	a3,s8,5b2 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 58a:	05a68163          	beq	a3,s10,5cc <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 58e:	09b68d63          	beq	a3,s11,628 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 592:	03a68f63          	beq	a3,s10,5d0 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 596:	07800793          	li	a5,120
 59a:	0cf68d63          	beq	a3,a5,674 <vprintf+0x1d0>
        putc(fd, '%');
 59e:	85d6                	mv	a1,s5
 5a0:	855a                	mv	a0,s6
 5a2:	e49ff0ef          	jal	ra,3ea <putc>
        putc(fd, c0);
 5a6:	85ca                	mv	a1,s2
 5a8:	855a                	mv	a0,s6
 5aa:	e41ff0ef          	jal	ra,3ea <putc>
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b7b9                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4685                	li	a3,1
 5b8:	4629                	li	a2,10
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	e49ff0ef          	jal	ra,408 <printint>
        i += 1;
 5c4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
        i += 1;
 5ca:	bf15                	j	4fe <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5cc:	03860563          	beq	a2,s8,5f6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d0:	07b60963          	beq	a2,s11,642 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5d4:	07800793          	li	a5,120
 5d8:	fcf613e3          	bne	a2,a5,59e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5dc:	008b8913          	addi	s2,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4641                	li	a2,16
 5e4:	000bb583          	ld	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	e1fff0ef          	jal	ra,408 <printint>
        i += 2;
 5ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
        i += 2;
 5f4:	b729                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4685                	li	a3,1
 5fc:	4629                	li	a2,10
 5fe:	000bb583          	ld	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	e05ff0ef          	jal	ra,408 <printint>
        i += 2;
 608:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
        i += 2;
 60e:	bdc5                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 610:	008b8913          	addi	s2,s7,8
 614:	4681                	li	a3,0
 616:	4629                	li	a2,10
 618:	000be583          	lwu	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	debff0ef          	jal	ra,408 <printint>
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
 626:	bde1                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 628:	008b8913          	addi	s2,s7,8
 62c:	4681                	li	a3,0
 62e:	4629                	li	a2,10
 630:	000bb583          	ld	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	dd3ff0ef          	jal	ra,408 <printint>
        i += 1;
 63a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 63c:	8bca                	mv	s7,s2
      state = 0;
 63e:	4981                	li	s3,0
        i += 1;
 640:	bd7d                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 642:	008b8913          	addi	s2,s7,8
 646:	4681                	li	a3,0
 648:	4629                	li	a2,10
 64a:	000bb583          	ld	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	db9ff0ef          	jal	ra,408 <printint>
        i += 2;
 654:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 656:	8bca                	mv	s7,s2
      state = 0;
 658:	4981                	li	s3,0
        i += 2;
 65a:	b555                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 65c:	008b8913          	addi	s2,s7,8
 660:	4681                	li	a3,0
 662:	4641                	li	a2,16
 664:	000be583          	lwu	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	d9fff0ef          	jal	ra,408 <printint>
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	b571                	j	4fe <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4641                	li	a2,16
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	d87ff0ef          	jal	ra,408 <printint>
        i += 1;
 686:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
        i += 1;
 68c:	bd8d                	j	4fe <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 68e:	008b8793          	addi	a5,s7,8
 692:	f8f43423          	sd	a5,-120(s0)
 696:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 69a:	03000593          	li	a1,48
 69e:	855a                	mv	a0,s6
 6a0:	d4bff0ef          	jal	ra,3ea <putc>
  putc(fd, 'x');
 6a4:	07800593          	li	a1,120
 6a8:	855a                	mv	a0,s6
 6aa:	d41ff0ef          	jal	ra,3ea <putc>
 6ae:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b0:	03c9d793          	srli	a5,s3,0x3c
 6b4:	97e6                	add	a5,a5,s9
 6b6:	0007c583          	lbu	a1,0(a5)
 6ba:	855a                	mv	a0,s6
 6bc:	d2fff0ef          	jal	ra,3ea <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c0:	0992                	slli	s3,s3,0x4
 6c2:	397d                	addiw	s2,s2,-1
 6c4:	fe0916e3          	bnez	s2,6b0 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6c8:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bd05                	j	4fe <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	000bc583          	lbu	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	d11ff0ef          	jal	ra,3ea <putc>
 6de:	8bca                	mv	s7,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bd31                	j	4fe <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6e4:	008b8993          	addi	s3,s7,8
 6e8:	000bb903          	ld	s2,0(s7)
 6ec:	00090f63          	beqz	s2,70a <vprintf+0x266>
        for(; *s; s++)
 6f0:	00094583          	lbu	a1,0(s2)
 6f4:	c195                	beqz	a1,718 <vprintf+0x274>
          putc(fd, *s);
 6f6:	855a                	mv	a0,s6
 6f8:	cf3ff0ef          	jal	ra,3ea <putc>
        for(; *s; s++)
 6fc:	0905                	addi	s2,s2,1
 6fe:	00094583          	lbu	a1,0(s2)
 702:	f9f5                	bnez	a1,6f6 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 704:	8bce                	mv	s7,s3
      state = 0;
 706:	4981                	li	s3,0
 708:	bbdd                	j	4fe <vprintf+0x5a>
          s = "(null)";
 70a:	00000917          	auipc	s2,0x0
 70e:	21690913          	addi	s2,s2,534 # 920 <malloc+0x106>
        for(; *s; s++)
 712:	02800593          	li	a1,40
 716:	b7c5                	j	6f6 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 718:	8bce                	mv	s7,s3
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b3cd                	j	4fe <vprintf+0x5a>
    }
  }
}
 71e:	70e6                	ld	ra,120(sp)
 720:	7446                	ld	s0,112(sp)
 722:	74a6                	ld	s1,104(sp)
 724:	7906                	ld	s2,96(sp)
 726:	69e6                	ld	s3,88(sp)
 728:	6a46                	ld	s4,80(sp)
 72a:	6aa6                	ld	s5,72(sp)
 72c:	6b06                	ld	s6,64(sp)
 72e:	7be2                	ld	s7,56(sp)
 730:	7c42                	ld	s8,48(sp)
 732:	7ca2                	ld	s9,40(sp)
 734:	7d02                	ld	s10,32(sp)
 736:	6de2                	ld	s11,24(sp)
 738:	6109                	addi	sp,sp,128
 73a:	8082                	ret

000000000000073c <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 73c:	715d                	addi	sp,sp,-80
 73e:	ec06                	sd	ra,24(sp)
 740:	e822                	sd	s0,16(sp)
 742:	1000                	addi	s0,sp,32
 744:	e010                	sd	a2,0(s0)
 746:	e414                	sd	a3,8(s0)
 748:	e818                	sd	a4,16(s0)
 74a:	ec1c                	sd	a5,24(s0)
 74c:	03043023          	sd	a6,32(s0)
 750:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 754:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 758:	8622                	mv	a2,s0
 75a:	d4bff0ef          	jal	ra,4a4 <vprintf>
}
 75e:	60e2                	ld	ra,24(sp)
 760:	6442                	ld	s0,16(sp)
 762:	6161                	addi	sp,sp,80
 764:	8082                	ret

0000000000000766 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 766:	711d                	addi	sp,sp,-96
 768:	ec06                	sd	ra,24(sp)
 76a:	e822                	sd	s0,16(sp)
 76c:	1000                	addi	s0,sp,32
 76e:	e40c                	sd	a1,8(s0)
 770:	e810                	sd	a2,16(s0)
 772:	ec14                	sd	a3,24(s0)
 774:	f018                	sd	a4,32(s0)
 776:	f41c                	sd	a5,40(s0)
 778:	03043823          	sd	a6,48(s0)
 77c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 780:	00840613          	addi	a2,s0,8
 784:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 788:	85aa                	mv	a1,a0
 78a:	4505                	li	a0,1
 78c:	d19ff0ef          	jal	ra,4a4 <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6125                	addi	sp,sp,96
 796:	8082                	ret

0000000000000798 <free>:
 *   无
 */

void
free(void *ap)
{
 798:	1141                	addi	sp,sp,-16
 79a:	e422                	sd	s0,8(sp)
 79c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 79e:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a2:	00001797          	auipc	a5,0x1
 7a6:	85e7b783          	ld	a5,-1954(a5) # 1000 <freep>
 7aa:	a02d                	j	7d4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ac:	4618                	lw	a4,8(a2)
 7ae:	9f2d                	addw	a4,a4,a1
 7b0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b4:	6398                	ld	a4,0(a5)
 7b6:	6310                	ld	a2,0(a4)
 7b8:	a83d                	j	7f6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ba:	ff852703          	lw	a4,-8(a0)
 7be:	9f31                	addw	a4,a4,a2
 7c0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c2:	ff053683          	ld	a3,-16(a0)
 7c6:	a091                	j	80a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c8:	6398                	ld	a4,0(a5)
 7ca:	00e7e463          	bltu	a5,a4,7d2 <free+0x3a>
 7ce:	00e6ea63          	bltu	a3,a4,7e2 <free+0x4a>
{
 7d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d4:	fed7fae3          	bgeu	a5,a3,7c8 <free+0x30>
 7d8:	6398                	ld	a4,0(a5)
 7da:	00e6e463          	bltu	a3,a4,7e2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7de:	fee7eae3          	bltu	a5,a4,7d2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e2:	ff852583          	lw	a1,-8(a0)
 7e6:	6390                	ld	a2,0(a5)
 7e8:	02059813          	slli	a6,a1,0x20
 7ec:	01c85713          	srli	a4,a6,0x1c
 7f0:	9736                	add	a4,a4,a3
 7f2:	fae60de3          	beq	a2,a4,7ac <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fa:	4790                	lw	a2,8(a5)
 7fc:	02061593          	slli	a1,a2,0x20
 800:	01c5d713          	srli	a4,a1,0x1c
 804:	973e                	add	a4,a4,a5
 806:	fae68ae3          	beq	a3,a4,7ba <free+0x22>
    p->s.ptr = bp->s.ptr;
 80a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  /* 更新空闲链表头指针 */
  freep = p;
 80c:	00000717          	auipc	a4,0x0
 810:	7ef73a23          	sd	a5,2036(a4) # 1000 <freep>
}
 814:	6422                	ld	s0,8(sp)
 816:	0141                	addi	sp,sp,16
 818:	8082                	ret

000000000000081a <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 81a:	7139                	addi	sp,sp,-64
 81c:	fc06                	sd	ra,56(sp)
 81e:	f822                	sd	s0,48(sp)
 820:	f426                	sd	s1,40(sp)
 822:	f04a                	sd	s2,32(sp)
 824:	ec4e                	sd	s3,24(sp)
 826:	e852                	sd	s4,16(sp)
 828:	e456                	sd	s5,8(sp)
 82a:	e05a                	sd	s6,0(sp)
 82c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82e:	02051493          	slli	s1,a0,0x20
 832:	9081                	srli	s1,s1,0x20
 834:	04bd                	addi	s1,s1,15
 836:	8091                	srli	s1,s1,0x4
 838:	0014899b          	addiw	s3,s1,1
 83c:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 83e:	00000517          	auipc	a0,0x0
 842:	7c253503          	ld	a0,1986(a0) # 1000 <freep>
 846:	c515                	beqz	a0,872 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 84a:	4798                	lw	a4,8(a5)
 84c:	02977f63          	bgeu	a4,s1,88a <malloc+0x70>
 850:	8a4e                	mv	s4,s3
 852:	0009871b          	sext.w	a4,s3
 856:	6685                	lui	a3,0x1
 858:	00d77363          	bgeu	a4,a3,85e <malloc+0x44>
 85c:	6a05                	lui	s4,0x1
 85e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 862:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 866:	00000917          	auipc	s2,0x0
 86a:	79a90913          	addi	s2,s2,1946 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 86e:	5afd                	li	s5,-1
 870:	a885                	j	8e0 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 872:	00000797          	auipc	a5,0x0
 876:	79e78793          	addi	a5,a5,1950 # 1010 <base>
 87a:	00000717          	auipc	a4,0x0
 87e:	78f73323          	sd	a5,1926(a4) # 1000 <freep>
 882:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 884:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 888:	b7e1                	j	850 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 88a:	02e48c63          	beq	s1,a4,8c2 <malloc+0xa8>
        p->s.size -= nunits;
 88e:	4137073b          	subw	a4,a4,s3
 892:	c798                	sw	a4,8(a5)
        p += p->s.size;
 894:	02071693          	slli	a3,a4,0x20
 898:	01c6d713          	srli	a4,a3,0x1c
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
 8c6:	bff1                	j	8a2 <malloc+0x88>
  hp->s.size = nu;
 8c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 8cc:	0541                	addi	a0,a0,16
 8ce:	ecbff0ef          	jal	ra,798 <free>
  return freep;
 8d2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d6:	dd61                	beqz	a0,8ae <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8da:	4798                	lw	a4,8(a5)
 8dc:	fa9777e3          	bgeu	a4,s1,88a <malloc+0x70>
    if(p == freep)
 8e0:	00093703          	ld	a4,0(s2)
 8e4:	853e                	mv	a0,a5
 8e6:	fef719e3          	bne	a4,a5,8d8 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8ea:	8552                	mv	a0,s4
 8ec:	9ebff0ef          	jal	ra,2d6 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8f0:	fd551ce3          	bne	a0,s5,8c8 <malloc+0xae>
        return 0;  /* 内存分配失败 */
 8f4:	4501                	li	a0,0
 8f6:	bf65                	j	8ae <malloc+0x94>
