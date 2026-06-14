
user/_fork_cow_test:     file format elf64-littleriscv


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
   e:	2ca000ef          	jal	ra,2d8 <sbrk>
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
  30:	2d4000ef          	jal	ra,304 <fork>
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
  42:	2ca000ef          	jal	ra,30c <exit>
    printf("alloc failed\n");
  46:	00001517          	auipc	a0,0x1
  4a:	8ba50513          	addi	a0,a0,-1862 # 900 <malloc+0xde>
  4e:	71a000ef          	jal	ra,768 <printf>
    exit(1);
  52:	4505                	li	a0,1
  54:	2b8000ef          	jal	ra,30c <exit>
    printf("fork failed\n");
  58:	00001517          	auipc	a0,0x1
  5c:	8b850513          	addi	a0,a0,-1864 # 910 <malloc+0xee>
  60:	708000ef          	jal	ra,768 <printf>
    exit(1);
  64:	4505                	li	a0,1
  66:	2a6000ef          	jal	ra,30c <exit>
  }

  wait(0);
  6a:	4501                	li	a0,0
  6c:	2a8000ef          	jal	ra,314 <wait>
  exit(0);
  70:	4501                	li	a0,0
  72:	29a000ef          	jal	ra,30c <exit>

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
  82:	28a000ef          	jal	ra,30c <exit>

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
 170:	1b4000ef          	jal	ra,324 <read>
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
 1be:	18e000ef          	jal	ra,34c <open>
  if(fd < 0)
 1c2:	02054163          	bltz	a0,1e4 <stat+0x36>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	19a000ef          	jal	ra,364 <fstat>
 1ce:	892a                	mv	s2,a0
  close(fd);
 1d0:	8526                	mv	a0,s1
 1d2:	162000ef          	jal	ra,334 <close>
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
 1ee:	00054603          	lbu	a2,0(a0)
 1f2:	fd06079b          	addiw	a5,a2,-48
 1f6:	0ff7f793          	andi	a5,a5,255
 1fa:	4725                	li	a4,9
 1fc:	02f76963          	bltu	a4,a5,22e <atoi+0x46>
 200:	86aa                	mv	a3,a0
  n = 0;
 202:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 204:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 206:	0685                	addi	a3,a3,1
 208:	0025179b          	slliw	a5,a0,0x2
 20c:	9fa9                	addw	a5,a5,a0
 20e:	0017979b          	slliw	a5,a5,0x1
 212:	9fb1                	addw	a5,a5,a2
 214:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 218:	0006c603          	lbu	a2,0(a3) # 1000 <freep>
 21c:	fd06071b          	addiw	a4,a2,-48
 220:	0ff77713          	andi	a4,a4,255
 224:	fee5f1e3          	bgeu	a1,a4,206 <atoi+0x1e>
  return n;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
  n = 0;
 22e:	4501                	li	a0,0
 230:	bfe5                	j	228 <atoi+0x40>

0000000000000232 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 238:	02b57463          	bgeu	a0,a1,260 <memmove+0x2e>
    while(n-- > 0)
 23c:	00c05f63          	blez	a2,25a <memmove+0x28>
 240:	1602                	slli	a2,a2,0x20
 242:	9201                	srli	a2,a2,0x20
 244:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 248:	872a                	mv	a4,a0
      *dst++ = *src++;
 24a:	0585                	addi	a1,a1,1
 24c:	0705                	addi	a4,a4,1
 24e:	fff5c683          	lbu	a3,-1(a1)
 252:	fed70fa3          	sb	a3,-1(a4) # 3ffff <base+0x3efef>
    while(n-- > 0)
 256:	fee79ae3          	bne	a5,a4,24a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
    dst += n;
 260:	00c50733          	add	a4,a0,a2
    src += n;
 264:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 266:	fec05ae3          	blez	a2,25a <memmove+0x28>
 26a:	fff6079b          	addiw	a5,a2,-1
 26e:	1782                	slli	a5,a5,0x20
 270:	9381                	srli	a5,a5,0x20
 272:	fff7c793          	not	a5,a5
 276:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 278:	15fd                	addi	a1,a1,-1
 27a:	177d                	addi	a4,a4,-1
 27c:	0005c683          	lbu	a3,0(a1)
 280:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 284:	fee79ae3          	bne	a5,a4,278 <memmove+0x46>
 288:	bfc9                	j	25a <memmove+0x28>

000000000000028a <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 290:	ca05                	beqz	a2,2c0 <memcmp+0x36>
 292:	fff6069b          	addiw	a3,a2,-1
 296:	1682                	slli	a3,a3,0x20
 298:	9281                	srli	a3,a3,0x20
 29a:	0685                	addi	a3,a3,1
 29c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	0005c703          	lbu	a4,0(a1)
 2a6:	00e79863          	bne	a5,a4,2b6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2aa:	0505                	addi	a0,a0,1
    p2++;
 2ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ae:	fed518e3          	bne	a0,a3,29e <memcmp+0x14>
  }
  return 0;
 2b2:	4501                	li	a0,0
 2b4:	a019                	j	2ba <memcmp+0x30>
      return *p1 - *p2;
 2b6:	40e7853b          	subw	a0,a5,a4
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	bfe5                	j	2ba <memcmp+0x30>

00000000000002c4 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2cc:	f67ff0ef          	jal	ra,232 <memmove>
}
 2d0:	60a2                	ld	ra,8(sp)
 2d2:	6402                	ld	s0,0(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret

00000000000002d8 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2e0:	4585                	li	a1,1
 2e2:	0b2000ef          	jal	ra,394 <sys_sbrk>
}
 2e6:	60a2                	ld	ra,8(sp)
 2e8:	6402                	ld	s0,0(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret

00000000000002ee <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e406                	sd	ra,8(sp)
 2f2:	e022                	sd	s0,0(sp)
 2f4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2f6:	4589                	li	a1,2
 2f8:	09c000ef          	jal	ra,394 <sys_sbrk>
}
 2fc:	60a2                	ld	ra,8(sp)
 2fe:	6402                	ld	s0,0(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret

0000000000000304 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 304:	4885                	li	a7,1
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <exit>:
.global exit
exit:
 li a7, SYS_exit
 30c:	4889                	li	a7,2
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <wait>:
.global wait
wait:
 li a7, SYS_wait
 314:	488d                	li	a7,3
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31c:	4891                	li	a7,4
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <read>:
.global read
read:
 li a7, SYS_read
 324:	4895                	li	a7,5
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <write>:
.global write
write:
 li a7, SYS_write
 32c:	48c1                	li	a7,16
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <close>:
.global close
close:
 li a7, SYS_close
 334:	48d5                	li	a7,21
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <kill>:
.global kill
kill:
 li a7, SYS_kill
 33c:	4899                	li	a7,6
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <exec>:
.global exec
exec:
 li a7, SYS_exec
 344:	489d                	li	a7,7
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <open>:
.global open
open:
 li a7, SYS_open
 34c:	48bd                	li	a7,15
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 354:	48c5                	li	a7,17
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35c:	48c9                	li	a7,18
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 364:	48a1                	li	a7,8
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <link>:
.global link
link:
 li a7, SYS_link
 36c:	48cd                	li	a7,19
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 374:	48d1                	li	a7,20
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37c:	48a5                	li	a7,9
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <dup>:
.global dup
dup:
 li a7, SYS_dup
 384:	48a9                	li	a7,10
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38c:	48ad                	li	a7,11
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 394:	48b1                	li	a7,12
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <pause>:
.global pause
pause:
 li a7, SYS_pause
 39c:	48b5                	li	a7,13
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a4:	48b9                	li	a7,14
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3ac:	48d9                	li	a7,22
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3b4:	48dd                	li	a7,23
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3bc:	48e1                	li	a7,24
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c4:	48e5                	li	a7,25
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 3cc:	48e9                	li	a7,26
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 3d4:	48ed                	li	a7,27
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 3dc:	48f1                	li	a7,28
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 3e4:	48f5                	li	a7,29
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 3ec:	1101                	addi	sp,sp,-32
 3ee:	ec06                	sd	ra,24(sp)
 3f0:	e822                	sd	s0,16(sp)
 3f2:	1000                	addi	s0,sp,32
 3f4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f8:	4605                	li	a2,1
 3fa:	fef40593          	addi	a1,s0,-17
 3fe:	f2fff0ef          	jal	ra,32c <write>
}
 402:	60e2                	ld	ra,24(sp)
 404:	6442                	ld	s0,16(sp)
 406:	6105                	addi	sp,sp,32
 408:	8082                	ret

000000000000040a <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 40a:	715d                	addi	sp,sp,-80
 40c:	e486                	sd	ra,72(sp)
 40e:	e0a2                	sd	s0,64(sp)
 410:	fc26                	sd	s1,56(sp)
 412:	f84a                	sd	s2,48(sp)
 414:	f44e                	sd	s3,40(sp)
 416:	0880                	addi	s0,sp,80
 418:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 41a:	c299                	beqz	a3,420 <printint+0x16>
 41c:	0805c163          	bltz	a1,49e <printint+0x94>
  neg = 0;
 420:	4881                	li	a7,0
 422:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 426:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 428:	00000517          	auipc	a0,0x0
 42c:	50050513          	addi	a0,a0,1280 # 928 <digits>
 430:	883e                	mv	a6,a5
 432:	2785                	addiw	a5,a5,1
 434:	02c5f733          	remu	a4,a1,a2
 438:	972a                	add	a4,a4,a0
 43a:	00074703          	lbu	a4,0(a4)
 43e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 442:	872e                	mv	a4,a1
 444:	02c5d5b3          	divu	a1,a1,a2
 448:	0685                	addi	a3,a3,1
 44a:	fec773e3          	bgeu	a4,a2,430 <printint+0x26>
  if(neg)
 44e:	00088b63          	beqz	a7,464 <printint+0x5a>
    buf[i++] = '-';
 452:	fd040713          	addi	a4,s0,-48
 456:	97ba                	add	a5,a5,a4
 458:	02d00713          	li	a4,45
 45c:	fee78423          	sb	a4,-24(a5)
 460:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 464:	02f05663          	blez	a5,490 <printint+0x86>
 468:	fb840713          	addi	a4,s0,-72
 46c:	00f704b3          	add	s1,a4,a5
 470:	fff70993          	addi	s3,a4,-1
 474:	99be                	add	s3,s3,a5
 476:	37fd                	addiw	a5,a5,-1
 478:	1782                	slli	a5,a5,0x20
 47a:	9381                	srli	a5,a5,0x20
 47c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 480:	fff4c583          	lbu	a1,-1(s1)
 484:	854a                	mv	a0,s2
 486:	f67ff0ef          	jal	ra,3ec <putc>
  while(--i >= 0)
 48a:	14fd                	addi	s1,s1,-1
 48c:	ff349ae3          	bne	s1,s3,480 <printint+0x76>
}
 490:	60a6                	ld	ra,72(sp)
 492:	6406                	ld	s0,64(sp)
 494:	74e2                	ld	s1,56(sp)
 496:	7942                	ld	s2,48(sp)
 498:	79a2                	ld	s3,40(sp)
 49a:	6161                	addi	sp,sp,80
 49c:	8082                	ret
    x = -xx;
 49e:	40b005b3          	neg	a1,a1
    neg = 1;
 4a2:	4885                	li	a7,1
    x = -xx;
 4a4:	bfbd                	j	422 <printint+0x18>

00000000000004a6 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a6:	7119                	addi	sp,sp,-128
 4a8:	fc86                	sd	ra,120(sp)
 4aa:	f8a2                	sd	s0,112(sp)
 4ac:	f4a6                	sd	s1,104(sp)
 4ae:	f0ca                	sd	s2,96(sp)
 4b0:	ecce                	sd	s3,88(sp)
 4b2:	e8d2                	sd	s4,80(sp)
 4b4:	e4d6                	sd	s5,72(sp)
 4b6:	e0da                	sd	s6,64(sp)
 4b8:	fc5e                	sd	s7,56(sp)
 4ba:	f862                	sd	s8,48(sp)
 4bc:	f466                	sd	s9,40(sp)
 4be:	f06a                	sd	s10,32(sp)
 4c0:	ec6e                	sd	s11,24(sp)
 4c2:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c4:	0005c903          	lbu	s2,0(a1)
 4c8:	24090c63          	beqz	s2,720 <vprintf+0x27a>
 4cc:	8b2a                	mv	s6,a0
 4ce:	8a2e                	mv	s4,a1
 4d0:	8bb2                	mv	s7,a2
  state = 0;
 4d2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d4:	4481                	li	s1,0
 4d6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4d8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4dc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4e0:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4e4:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4e8:	00000c97          	auipc	s9,0x0
 4ec:	440c8c93          	addi	s9,s9,1088 # 928 <digits>
 4f0:	a005                	j	510 <vprintf+0x6a>
        putc(fd, c0);
 4f2:	85ca                	mv	a1,s2
 4f4:	855a                	mv	a0,s6
 4f6:	ef7ff0ef          	jal	ra,3ec <putc>
 4fa:	a019                	j	500 <vprintf+0x5a>
    } else if(state == '%'){
 4fc:	03598263          	beq	s3,s5,520 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 500:	2485                	addiw	s1,s1,1
 502:	8726                	mv	a4,s1
 504:	009a07b3          	add	a5,s4,s1
 508:	0007c903          	lbu	s2,0(a5)
 50c:	20090a63          	beqz	s2,720 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 510:	0009079b          	sext.w	a5,s2
    if(state == 0){
 514:	fe0994e3          	bnez	s3,4fc <vprintf+0x56>
      if(c0 == '%'){
 518:	fd579de3          	bne	a5,s5,4f2 <vprintf+0x4c>
        state = '%';
 51c:	89be                	mv	s3,a5
 51e:	b7cd                	j	500 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 520:	c3c1                	beqz	a5,5a0 <vprintf+0xfa>
 522:	00ea06b3          	add	a3,s4,a4
 526:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 52a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 52c:	c681                	beqz	a3,534 <vprintf+0x8e>
 52e:	9752                	add	a4,a4,s4
 530:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 534:	03878e63          	beq	a5,s8,570 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 538:	05a78863          	beq	a5,s10,588 <vprintf+0xe2>
      } else if(c0 == 'u'){
 53c:	0db78b63          	beq	a5,s11,612 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 540:	07800713          	li	a4,120
 544:	10e78d63          	beq	a5,a4,65e <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 548:	07000713          	li	a4,112
 54c:	14e78263          	beq	a5,a4,690 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 550:	06300713          	li	a4,99
 554:	16e78f63          	beq	a5,a4,6d2 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 558:	07300713          	li	a4,115
 55c:	18e78563          	beq	a5,a4,6e6 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 560:	05579063          	bne	a5,s5,5a0 <vprintf+0xfa>
        putc(fd, '%');
 564:	85d6                	mv	a1,s5
 566:	855a                	mv	a0,s6
 568:	e85ff0ef          	jal	ra,3ec <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 56c:	4981                	li	s3,0
 56e:	bf49                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 570:	008b8913          	addi	s2,s7,8
 574:	4685                	li	a3,1
 576:	4629                	li	a2,10
 578:	000ba583          	lw	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	e8dff0ef          	jal	ra,40a <printint>
 582:	8bca                	mv	s7,s2
      state = 0;
 584:	4981                	li	s3,0
 586:	bfad                	j	500 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 588:	03868663          	beq	a3,s8,5b4 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 58c:	05a68163          	beq	a3,s10,5ce <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 590:	09b68d63          	beq	a3,s11,62a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 594:	03a68f63          	beq	a3,s10,5d2 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 598:	07800793          	li	a5,120
 59c:	0cf68d63          	beq	a3,a5,676 <vprintf+0x1d0>
        putc(fd, '%');
 5a0:	85d6                	mv	a1,s5
 5a2:	855a                	mv	a0,s6
 5a4:	e49ff0ef          	jal	ra,3ec <putc>
        putc(fd, c0);
 5a8:	85ca                	mv	a1,s2
 5aa:	855a                	mv	a0,s6
 5ac:	e41ff0ef          	jal	ra,3ec <putc>
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	b7b9                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4685                	li	a3,1
 5ba:	4629                	li	a2,10
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e49ff0ef          	jal	ra,40a <printint>
        i += 1;
 5c6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
        i += 1;
 5cc:	bf15                	j	500 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ce:	03860563          	beq	a2,s8,5f8 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d2:	07b60963          	beq	a2,s11,644 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5d6:	07800793          	li	a5,120
 5da:	fcf613e3          	bne	a2,a5,5a0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4681                	li	a3,0
 5e4:	4641                	li	a2,16
 5e6:	000bb583          	ld	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	e1fff0ef          	jal	ra,40a <printint>
        i += 2;
 5f0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f2:	8bca                	mv	s7,s2
      state = 0;
 5f4:	4981                	li	s3,0
        i += 2;
 5f6:	b729                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f8:	008b8913          	addi	s2,s7,8
 5fc:	4685                	li	a3,1
 5fe:	4629                	li	a2,10
 600:	000bb583          	ld	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	e05ff0ef          	jal	ra,40a <printint>
        i += 2;
 60a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
        i += 2;
 610:	bdc5                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 612:	008b8913          	addi	s2,s7,8
 616:	4681                	li	a3,0
 618:	4629                	li	a2,10
 61a:	000be583          	lwu	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	debff0ef          	jal	ra,40a <printint>
 624:	8bca                	mv	s7,s2
      state = 0;
 626:	4981                	li	s3,0
 628:	bde1                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62a:	008b8913          	addi	s2,s7,8
 62e:	4681                	li	a3,0
 630:	4629                	li	a2,10
 632:	000bb583          	ld	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	dd3ff0ef          	jal	ra,40a <printint>
        i += 1;
 63c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 63e:	8bca                	mv	s7,s2
      state = 0;
 640:	4981                	li	s3,0
        i += 1;
 642:	bd7d                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 644:	008b8913          	addi	s2,s7,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	db9ff0ef          	jal	ra,40a <printint>
        i += 2;
 656:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
        i += 2;
 65c:	b555                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 65e:	008b8913          	addi	s2,s7,8
 662:	4681                	li	a3,0
 664:	4641                	li	a2,16
 666:	000be583          	lwu	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	d9fff0ef          	jal	ra,40a <printint>
 670:	8bca                	mv	s7,s2
      state = 0;
 672:	4981                	li	s3,0
 674:	b571                	j	500 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 676:	008b8913          	addi	s2,s7,8
 67a:	4681                	li	a3,0
 67c:	4641                	li	a2,16
 67e:	000bb583          	ld	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	d87ff0ef          	jal	ra,40a <printint>
        i += 1;
 688:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
        i += 1;
 68e:	bd8d                	j	500 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 690:	008b8793          	addi	a5,s7,8
 694:	f8f43423          	sd	a5,-120(s0)
 698:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 69c:	03000593          	li	a1,48
 6a0:	855a                	mv	a0,s6
 6a2:	d4bff0ef          	jal	ra,3ec <putc>
  putc(fd, 'x');
 6a6:	07800593          	li	a1,120
 6aa:	855a                	mv	a0,s6
 6ac:	d41ff0ef          	jal	ra,3ec <putc>
 6b0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b2:	03c9d793          	srli	a5,s3,0x3c
 6b6:	97e6                	add	a5,a5,s9
 6b8:	0007c583          	lbu	a1,0(a5)
 6bc:	855a                	mv	a0,s6
 6be:	d2fff0ef          	jal	ra,3ec <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c2:	0992                	slli	s3,s3,0x4
 6c4:	397d                	addiw	s2,s2,-1
 6c6:	fe0916e3          	bnez	s2,6b2 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6ca:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bd05                	j	500 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	000bc583          	lbu	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	d11ff0ef          	jal	ra,3ec <putc>
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bd31                	j	500 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6e6:	008b8993          	addi	s3,s7,8
 6ea:	000bb903          	ld	s2,0(s7)
 6ee:	00090f63          	beqz	s2,70c <vprintf+0x266>
        for(; *s; s++)
 6f2:	00094583          	lbu	a1,0(s2)
 6f6:	c195                	beqz	a1,71a <vprintf+0x274>
          putc(fd, *s);
 6f8:	855a                	mv	a0,s6
 6fa:	cf3ff0ef          	jal	ra,3ec <putc>
        for(; *s; s++)
 6fe:	0905                	addi	s2,s2,1
 700:	00094583          	lbu	a1,0(s2)
 704:	f9f5                	bnez	a1,6f8 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 706:	8bce                	mv	s7,s3
      state = 0;
 708:	4981                	li	s3,0
 70a:	bbdd                	j	500 <vprintf+0x5a>
          s = "(null)";
 70c:	00000917          	auipc	s2,0x0
 710:	21490913          	addi	s2,s2,532 # 920 <malloc+0xfe>
        for(; *s; s++)
 714:	02800593          	li	a1,40
 718:	b7c5                	j	6f8 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 71a:	8bce                	mv	s7,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b3cd                	j	500 <vprintf+0x5a>
    }
  }
}
 720:	70e6                	ld	ra,120(sp)
 722:	7446                	ld	s0,112(sp)
 724:	74a6                	ld	s1,104(sp)
 726:	7906                	ld	s2,96(sp)
 728:	69e6                	ld	s3,88(sp)
 72a:	6a46                	ld	s4,80(sp)
 72c:	6aa6                	ld	s5,72(sp)
 72e:	6b06                	ld	s6,64(sp)
 730:	7be2                	ld	s7,56(sp)
 732:	7c42                	ld	s8,48(sp)
 734:	7ca2                	ld	s9,40(sp)
 736:	7d02                	ld	s10,32(sp)
 738:	6de2                	ld	s11,24(sp)
 73a:	6109                	addi	sp,sp,128
 73c:	8082                	ret

000000000000073e <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 73e:	715d                	addi	sp,sp,-80
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e010                	sd	a2,0(s0)
 748:	e414                	sd	a3,8(s0)
 74a:	e818                	sd	a4,16(s0)
 74c:	ec1c                	sd	a5,24(s0)
 74e:	03043023          	sd	a6,32(s0)
 752:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75a:	8622                	mv	a2,s0
 75c:	d4bff0ef          	jal	ra,4a6 <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6161                	addi	sp,sp,80
 766:	8082                	ret

0000000000000768 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 768:	711d                	addi	sp,sp,-96
 76a:	ec06                	sd	ra,24(sp)
 76c:	e822                	sd	s0,16(sp)
 76e:	1000                	addi	s0,sp,32
 770:	e40c                	sd	a1,8(s0)
 772:	e810                	sd	a2,16(s0)
 774:	ec14                	sd	a3,24(s0)
 776:	f018                	sd	a4,32(s0)
 778:	f41c                	sd	a5,40(s0)
 77a:	03043823          	sd	a6,48(s0)
 77e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 782:	00840613          	addi	a2,s0,8
 786:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78a:	85aa                	mv	a1,a0
 78c:	4505                	li	a0,1
 78e:	d19ff0ef          	jal	ra,4a6 <vprintf>
}
 792:	60e2                	ld	ra,24(sp)
 794:	6442                	ld	s0,16(sp)
 796:	6125                	addi	sp,sp,96
 798:	8082                	ret

000000000000079a <free>:
 *   无
 */

void
free(void *ap)
{
 79a:	1141                	addi	sp,sp,-16
 79c:	e422                	sd	s0,8(sp)
 79e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7a0:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	00001797          	auipc	a5,0x1
 7a8:	85c7b783          	ld	a5,-1956(a5) # 1000 <freep>
 7ac:	a805                	j	7dc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ae:	4618                	lw	a4,8(a2)
 7b0:	9db9                	addw	a1,a1,a4
 7b2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	6318                	ld	a4,0(a4)
 7ba:	fee53823          	sd	a4,-16(a0)
 7be:	a091                	j	802 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c0:	ff852703          	lw	a4,-8(a0)
 7c4:	9e39                	addw	a2,a2,a4
 7c6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7c8:	ff053703          	ld	a4,-16(a0)
 7cc:	e398                	sd	a4,0(a5)
 7ce:	a099                	j	814 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d0:	6398                	ld	a4,0(a5)
 7d2:	00e7e463          	bltu	a5,a4,7da <free+0x40>
 7d6:	00e6ea63          	bltu	a3,a4,7ea <free+0x50>
{
 7da:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	fed7fae3          	bgeu	a5,a3,7d0 <free+0x36>
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e6e463          	bltu	a3,a4,7ea <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e6:	fee7eae3          	bltu	a5,a4,7da <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7ea:	ff852583          	lw	a1,-8(a0)
 7ee:	6390                	ld	a2,0(a5)
 7f0:	02059713          	slli	a4,a1,0x20
 7f4:	9301                	srli	a4,a4,0x20
 7f6:	0712                	slli	a4,a4,0x4
 7f8:	9736                	add	a4,a4,a3
 7fa:	fae60ae3          	beq	a2,a4,7ae <free+0x14>
    bp->s.ptr = p->s.ptr;
 7fe:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 802:	4790                	lw	a2,8(a5)
 804:	02061713          	slli	a4,a2,0x20
 808:	9301                	srli	a4,a4,0x20
 80a:	0712                	slli	a4,a4,0x4
 80c:	973e                	add	a4,a4,a5
 80e:	fae689e3          	beq	a3,a4,7c0 <free+0x26>
  } else
    p->s.ptr = bp;
 812:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 814:	00000717          	auipc	a4,0x0
 818:	7ef73623          	sd	a5,2028(a4) # 1000 <freep>
}
 81c:	6422                	ld	s0,8(sp)
 81e:	0141                	addi	sp,sp,16
 820:	8082                	ret

0000000000000822 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 822:	7139                	addi	sp,sp,-64
 824:	fc06                	sd	ra,56(sp)
 826:	f822                	sd	s0,48(sp)
 828:	f426                	sd	s1,40(sp)
 82a:	f04a                	sd	s2,32(sp)
 82c:	ec4e                	sd	s3,24(sp)
 82e:	e852                	sd	s4,16(sp)
 830:	e456                	sd	s5,8(sp)
 832:	e05a                	sd	s6,0(sp)
 834:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 836:	02051493          	slli	s1,a0,0x20
 83a:	9081                	srli	s1,s1,0x20
 83c:	04bd                	addi	s1,s1,15
 83e:	8091                	srli	s1,s1,0x4
 840:	0014899b          	addiw	s3,s1,1
 844:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 846:	00000517          	auipc	a0,0x0
 84a:	7ba53503          	ld	a0,1978(a0) # 1000 <freep>
 84e:	c515                	beqz	a0,87a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 850:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 852:	4798                	lw	a4,8(a5)
 854:	02977f63          	bgeu	a4,s1,892 <malloc+0x70>
 858:	8a4e                	mv	s4,s3
 85a:	0009871b          	sext.w	a4,s3
 85e:	6685                	lui	a3,0x1
 860:	00d77363          	bgeu	a4,a3,866 <malloc+0x44>
 864:	6a05                	lui	s4,0x1
 866:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 86a:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 86e:	00000917          	auipc	s2,0x0
 872:	79290913          	addi	s2,s2,1938 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 876:	5afd                	li	s5,-1
 878:	a0bd                	j	8e6 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 87a:	00000797          	auipc	a5,0x0
 87e:	79678793          	addi	a5,a5,1942 # 1010 <base>
 882:	00000717          	auipc	a4,0x0
 886:	76f73f23          	sd	a5,1918(a4) # 1000 <freep>
 88a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 88c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 890:	b7e1                	j	858 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 892:	02e48b63          	beq	s1,a4,8c8 <malloc+0xa6>
        p->s.size -= nunits;
 896:	4137073b          	subw	a4,a4,s3
 89a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89c:	1702                	slli	a4,a4,0x20
 89e:	9301                	srli	a4,a4,0x20
 8a0:	0712                	slli	a4,a4,0x4
 8a2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a4:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8a8:	00000717          	auipc	a4,0x0
 8ac:	74a73c23          	sd	a0,1880(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 8b0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 8b4:	70e2                	ld	ra,56(sp)
 8b6:	7442                	ld	s0,48(sp)
 8b8:	74a2                	ld	s1,40(sp)
 8ba:	7902                	ld	s2,32(sp)
 8bc:	69e2                	ld	s3,24(sp)
 8be:	6a42                	ld	s4,16(sp)
 8c0:	6aa2                	ld	s5,8(sp)
 8c2:	6b02                	ld	s6,0(sp)
 8c4:	6121                	addi	sp,sp,64
 8c6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c8:	6398                	ld	a4,0(a5)
 8ca:	e118                	sd	a4,0(a0)
 8cc:	bff1                	j	8a8 <malloc+0x86>
  hp->s.size = nu;
 8ce:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 8d2:	0541                	addi	a0,a0,16
 8d4:	ec7ff0ef          	jal	ra,79a <free>
  return freep;
 8d8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8dc:	dd61                	beqz	a0,8b4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8e0:	4798                	lw	a4,8(a5)
 8e2:	fa9778e3          	bgeu	a4,s1,892 <malloc+0x70>
    if(p == freep)
 8e6:	00093703          	ld	a4,0(s2)
 8ea:	853e                	mv	a0,a5
 8ec:	fef719e3          	bne	a4,a5,8de <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8f0:	8552                	mv	a0,s4
 8f2:	9e7ff0ef          	jal	ra,2d8 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8f6:	fd551ce3          	bne	a0,s5,8ce <malloc+0xac>
        return 0;  /* 内存分配失败 */
 8fa:	4501                	li	a0,0
 8fc:	bf65                	j	8b4 <malloc+0x92>
