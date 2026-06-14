
user/_shm_keep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/shm.h"
#include "user.h"

int 
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  int key = 1;
  char *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
   a:	4705                	li	a4,1
   c:	468d                	li	a3,3
   e:	460d                	li	a2,3
  10:	6585                	lui	a1,0x1
  12:	4501                	li	a0,0
  14:	414000ef          	jal	ra,428 <mmap>
  if(p == (char*)-1){
  18:	57fd                	li	a5,-1
  1a:	04f50363          	beq	a0,a5,60 <main+0x60>
  1e:	84aa                	mv	s1,a0
    printf("mmap fail\n");
    exit(1);
  }

  int pid = fork();
  20:	360000ef          	jal	ra,380 <fork>
  if(pid == 0){
  24:	e539                	bnez	a0,72 <main+0x72>
    // child：持有映射，写入，然后睡一会儿别退出
    p[0] = 99;
  26:	06300793          	li	a5,99
  2a:	00f48023          	sb	a5,0(s1)
    printf("child wrote 99\n");
  2e:	00001517          	auipc	a0,0x1
  32:	96250513          	addi	a0,a0,-1694 # 990 <malloc+0xf2>
  36:	7ae000ef          	jal	ra,7e4 <printf>
    sleep(50);
  3a:	03200513          	li	a0,50
  3e:	402000ef          	jal	ra,440 <sleep>
    printf("child still sees %d\n", p[0]);
  42:	0004c583          	lbu	a1,0(s1)
  46:	00001517          	auipc	a0,0x1
  4a:	95a50513          	addi	a0,a0,-1702 # 9a0 <malloc+0x102>
  4e:	796000ef          	jal	ra,7e4 <printf>
    munmap(p, 4096);
  52:	6585                	lui	a1,0x1
  54:	8526                	mv	a0,s1
  56:	3da000ef          	jal	ra,430 <munmap>
    exit(0);
  5a:	4501                	li	a0,0
  5c:	32c000ef          	jal	ra,388 <exit>
    printf("mmap fail\n");
  60:	00001517          	auipc	a0,0x1
  64:	92050513          	addi	a0,a0,-1760 # 980 <malloc+0xe2>
  68:	77c000ef          	jal	ra,7e4 <printf>
    exit(1);
  6c:	4505                	li	a0,1
  6e:	31a000ef          	jal	ra,388 <exit>
  }

  // parent：等 child 写完
  sleep(20);
  72:	4551                	li	a0,20
  74:	3cc000ef          	jal	ra,440 <sleep>
  printf("parent sees %d before unmap\n", p[0]);
  78:	0004c583          	lbu	a1,0(s1)
  7c:	00001517          	auipc	a0,0x1
  80:	93c50513          	addi	a0,a0,-1732 # 9b8 <malloc+0x11a>
  84:	760000ef          	jal	ra,7e4 <printf>

  // parent 解除映射
  if(munmap(p, 4096) < 0){
  88:	6585                	lui	a1,0x1
  8a:	8526                	mv	a0,s1
  8c:	3a4000ef          	jal	ra,430 <munmap>
  90:	02054f63          	bltz	a0,ce <main+0xce>
    printf("parent munmap failed\n");
    exit(1);
  }

  // parent 再次 mmap 同 key（此时 child 还活着、refcnt>0）
  char *q = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  94:	4705                	li	a4,1
  96:	468d                	li	a3,3
  98:	460d                	li	a2,3
  9a:	6585                	lui	a1,0x1
  9c:	4501                	li	a0,0
  9e:	38a000ef          	jal	ra,428 <mmap>
  a2:	84aa                	mv	s1,a0
  if(q == (char*)-1){
  a4:	57fd                	li	a5,-1
  a6:	02f50d63          	beq	a0,a5,e0 <main+0xe0>
    printf("remap fail\n");
    exit(1);
  }

  printf("parent sees %d after remap\n", q[0]); // 预期仍是 99
  aa:	00054583          	lbu	a1,0(a0)
  ae:	00001517          	auipc	a0,0x1
  b2:	95250513          	addi	a0,a0,-1710 # a00 <malloc+0x162>
  b6:	72e000ef          	jal	ra,7e4 <printf>

  wait(0);
  ba:	4501                	li	a0,0
  bc:	2d4000ef          	jal	ra,390 <wait>
  munmap(q, 4096);
  c0:	6585                	lui	a1,0x1
  c2:	8526                	mv	a0,s1
  c4:	36c000ef          	jal	ra,430 <munmap>
  exit(0);
  c8:	4501                	li	a0,0
  ca:	2be000ef          	jal	ra,388 <exit>
    printf("parent munmap failed\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	90a50513          	addi	a0,a0,-1782 # 9d8 <malloc+0x13a>
  d6:	70e000ef          	jal	ra,7e4 <printf>
    exit(1);
  da:	4505                	li	a0,1
  dc:	2ac000ef          	jal	ra,388 <exit>
    printf("remap fail\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	91050513          	addi	a0,a0,-1776 # 9f0 <malloc+0x152>
  e8:	6fc000ef          	jal	ra,7e4 <printf>
    exit(1);
  ec:	4505                	li	a0,1
  ee:	29a000ef          	jal	ra,388 <exit>

00000000000000f2 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e406                	sd	ra,8(sp)
  f6:	e022                	sd	s0,0(sp)
  f8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  fa:	f07ff0ef          	jal	ra,0 <main>
  exit(r);
  fe:	28a000ef          	jal	ra,388 <exit>

0000000000000102 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 108:	87aa                	mv	a5,a0
 10a:	0585                	addi	a1,a1,1
 10c:	0785                	addi	a5,a5,1
 10e:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x5d7>
 112:	fee78fa3          	sb	a4,-1(a5)
 116:	fb75                	bnez	a4,10a <strcpy+0x8>
    ;
  return os;
}
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 124:	00054783          	lbu	a5,0(a0)
 128:	cb91                	beqz	a5,13c <strcmp+0x1e>
 12a:	0005c703          	lbu	a4,0(a1)
 12e:	00f71763          	bne	a4,a5,13c <strcmp+0x1e>
    p++, q++;
 132:	0505                	addi	a0,a0,1
 134:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 136:	00054783          	lbu	a5,0(a0)
 13a:	fbe5                	bnez	a5,12a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 13c:	0005c503          	lbu	a0,0(a1)
}
 140:	40a7853b          	subw	a0,a5,a0
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 150:	00054783          	lbu	a5,0(a0)
 154:	cf91                	beqz	a5,170 <strlen+0x26>
 156:	0505                	addi	a0,a0,1
 158:	87aa                	mv	a5,a0
 15a:	4685                	li	a3,1
 15c:	9e89                	subw	a3,a3,a0
 15e:	00f6853b          	addw	a0,a3,a5
 162:	0785                	addi	a5,a5,1
 164:	fff7c703          	lbu	a4,-1(a5)
 168:	fb7d                	bnez	a4,15e <strlen+0x14>
    ;
  return n;
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  for(n = 0; s[n]; n++)
 170:	4501                	li	a0,0
 172:	bfe5                	j	16a <strlen+0x20>

0000000000000174 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 174:	1141                	addi	sp,sp,-16
 176:	e422                	sd	s0,8(sp)
 178:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17a:	ca19                	beqz	a2,190 <memset+0x1c>
 17c:	87aa                	mv	a5,a0
 17e:	1602                	slli	a2,a2,0x20
 180:	9201                	srli	a2,a2,0x20
 182:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 186:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18a:	0785                	addi	a5,a5,1
 18c:	fee79de3          	bne	a5,a4,186 <memset+0x12>
  }
  return dst;
}
 190:	6422                	ld	s0,8(sp)
 192:	0141                	addi	sp,sp,16
 194:	8082                	ret

0000000000000196 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	cb99                	beqz	a5,1b6 <strchr+0x20>
    if(*s == c)
 1a2:	00f58763          	beq	a1,a5,1b0 <strchr+0x1a>
  for(; *s; s++)
 1a6:	0505                	addi	a0,a0,1
 1a8:	00054783          	lbu	a5,0(a0)
 1ac:	fbfd                	bnez	a5,1a2 <strchr+0xc>
      return (char*)s;
  return 0;
 1ae:	4501                	li	a0,0
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret
  return 0;
 1b6:	4501                	li	a0,0
 1b8:	bfe5                	j	1b0 <strchr+0x1a>

00000000000001ba <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 1ba:	711d                	addi	sp,sp,-96
 1bc:	ec86                	sd	ra,88(sp)
 1be:	e8a2                	sd	s0,80(sp)
 1c0:	e4a6                	sd	s1,72(sp)
 1c2:	e0ca                	sd	s2,64(sp)
 1c4:	fc4e                	sd	s3,56(sp)
 1c6:	f852                	sd	s4,48(sp)
 1c8:	f456                	sd	s5,40(sp)
 1ca:	f05a                	sd	s6,32(sp)
 1cc:	ec5e                	sd	s7,24(sp)
 1ce:	1080                	addi	s0,sp,96
 1d0:	8baa                	mv	s7,a0
 1d2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	892a                	mv	s2,a0
 1d6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d8:	4aa9                	li	s5,10
 1da:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1dc:	89a6                	mv	s3,s1
 1de:	2485                	addiw	s1,s1,1
 1e0:	0344d663          	bge	s1,s4,20c <gets+0x52>
    cc = read(0, &c, 1);
 1e4:	4605                	li	a2,1
 1e6:	faf40593          	addi	a1,s0,-81
 1ea:	4501                	li	a0,0
 1ec:	1b4000ef          	jal	ra,3a0 <read>
    if(cc < 1)
 1f0:	00a05e63          	blez	a0,20c <gets+0x52>
    buf[i++] = c;
 1f4:	faf44783          	lbu	a5,-81(s0)
 1f8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fc:	01578763          	beq	a5,s5,20a <gets+0x50>
 200:	0905                	addi	s2,s2,1
 202:	fd679de3          	bne	a5,s6,1dc <gets+0x22>
  for(i=0; i+1 < max; ){
 206:	89a6                	mv	s3,s1
 208:	a011                	j	20c <gets+0x52>
 20a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20c:	99de                	add	s3,s3,s7
 20e:	00098023          	sb	zero,0(s3)
  return buf;
}
 212:	855e                	mv	a0,s7
 214:	60e6                	ld	ra,88(sp)
 216:	6446                	ld	s0,80(sp)
 218:	64a6                	ld	s1,72(sp)
 21a:	6906                	ld	s2,64(sp)
 21c:	79e2                	ld	s3,56(sp)
 21e:	7a42                	ld	s4,48(sp)
 220:	7aa2                	ld	s5,40(sp)
 222:	7b02                	ld	s6,32(sp)
 224:	6be2                	ld	s7,24(sp)
 226:	6125                	addi	sp,sp,96
 228:	8082                	ret

000000000000022a <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 22a:	1101                	addi	sp,sp,-32
 22c:	ec06                	sd	ra,24(sp)
 22e:	e822                	sd	s0,16(sp)
 230:	e426                	sd	s1,8(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	18e000ef          	jal	ra,3c8 <open>
  if(fd < 0)
 23e:	02054163          	bltz	a0,260 <stat+0x36>
 242:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 244:	85ca                	mv	a1,s2
 246:	19a000ef          	jal	ra,3e0 <fstat>
 24a:	892a                	mv	s2,a0
  close(fd);
 24c:	8526                	mv	a0,s1
 24e:	162000ef          	jal	ra,3b0 <close>
  return r;
}
 252:	854a                	mv	a0,s2
 254:	60e2                	ld	ra,24(sp)
 256:	6442                	ld	s0,16(sp)
 258:	64a2                	ld	s1,8(sp)
 25a:	6902                	ld	s2,0(sp)
 25c:	6105                	addi	sp,sp,32
 25e:	8082                	ret
    return -1;
 260:	597d                	li	s2,-1
 262:	bfc5                	j	252 <stat+0x28>

0000000000000264 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26a:	00054603          	lbu	a2,0(a0)
 26e:	fd06079b          	addiw	a5,a2,-48
 272:	0ff7f793          	andi	a5,a5,255
 276:	4725                	li	a4,9
 278:	02f76963          	bltu	a4,a5,2aa <atoi+0x46>
 27c:	86aa                	mv	a3,a0
  n = 0;
 27e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 280:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 282:	0685                	addi	a3,a3,1
 284:	0025179b          	slliw	a5,a0,0x2
 288:	9fa9                	addw	a5,a5,a0
 28a:	0017979b          	slliw	a5,a5,0x1
 28e:	9fb1                	addw	a5,a5,a2
 290:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 294:	0006c603          	lbu	a2,0(a3)
 298:	fd06071b          	addiw	a4,a2,-48
 29c:	0ff77713          	andi	a4,a4,255
 2a0:	fee5f1e3          	bgeu	a1,a4,282 <atoi+0x1e>
  return n;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
  n = 0;
 2aa:	4501                	li	a0,0
 2ac:	bfe5                	j	2a4 <atoi+0x40>

00000000000002ae <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b4:	02b57463          	bgeu	a0,a1,2dc <memmove+0x2e>
    while(n-- > 0)
 2b8:	00c05f63          	blez	a2,2d6 <memmove+0x28>
 2bc:	1602                	slli	a2,a2,0x20
 2be:	9201                	srli	a2,a2,0x20
 2c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c6:	0585                	addi	a1,a1,1
 2c8:	0705                	addi	a4,a4,1
 2ca:	fff5c683          	lbu	a3,-1(a1)
 2ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d2:	fee79ae3          	bne	a5,a4,2c6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
    dst += n;
 2dc:	00c50733          	add	a4,a0,a2
    src += n;
 2e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e2:	fec05ae3          	blez	a2,2d6 <memmove+0x28>
 2e6:	fff6079b          	addiw	a5,a2,-1
 2ea:	1782                	slli	a5,a5,0x20
 2ec:	9381                	srli	a5,a5,0x20
 2ee:	fff7c793          	not	a5,a5
 2f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f4:	15fd                	addi	a1,a1,-1
 2f6:	177d                	addi	a4,a4,-1
 2f8:	0005c683          	lbu	a3,0(a1)
 2fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 300:	fee79ae3          	bne	a5,a4,2f4 <memmove+0x46>
 304:	bfc9                	j	2d6 <memmove+0x28>

0000000000000306 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30c:	ca05                	beqz	a2,33c <memcmp+0x36>
 30e:	fff6069b          	addiw	a3,a2,-1
 312:	1682                	slli	a3,a3,0x20
 314:	9281                	srli	a3,a3,0x20
 316:	0685                	addi	a3,a3,1
 318:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31a:	00054783          	lbu	a5,0(a0)
 31e:	0005c703          	lbu	a4,0(a1)
 322:	00e79863          	bne	a5,a4,332 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 326:	0505                	addi	a0,a0,1
    p2++;
 328:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32a:	fed518e3          	bne	a0,a3,31a <memcmp+0x14>
  }
  return 0;
 32e:	4501                	li	a0,0
 330:	a019                	j	336 <memcmp+0x30>
      return *p1 - *p2;
 332:	40e7853b          	subw	a0,a5,a4
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  return 0;
 33c:	4501                	li	a0,0
 33e:	bfe5                	j	336 <memcmp+0x30>

0000000000000340 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e406                	sd	ra,8(sp)
 344:	e022                	sd	s0,0(sp)
 346:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 348:	f67ff0ef          	jal	ra,2ae <memmove>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 35c:	4585                	li	a1,1
 35e:	0b2000ef          	jal	ra,410 <sys_sbrk>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 36a:	1141                	addi	sp,sp,-16
 36c:	e406                	sd	ra,8(sp)
 36e:	e022                	sd	s0,0(sp)
 370:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 372:	4589                	li	a1,2
 374:	09c000ef          	jal	ra,410 <sys_sbrk>
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 380:	4885                	li	a7,1
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exit>:
.global exit
exit:
 li a7, SYS_exit
 388:	4889                	li	a7,2
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <wait>:
.global wait
wait:
 li a7, SYS_wait
 390:	488d                	li	a7,3
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 398:	4891                	li	a7,4
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <read>:
.global read
read:
 li a7, SYS_read
 3a0:	4895                	li	a7,5
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <write>:
.global write
write:
 li a7, SYS_write
 3a8:	48c1                	li	a7,16
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <close>:
.global close
close:
 li a7, SYS_close
 3b0:	48d5                	li	a7,21
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b8:	4899                	li	a7,6
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c0:	489d                	li	a7,7
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <open>:
.global open
open:
 li a7, SYS_open
 3c8:	48bd                	li	a7,15
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d0:	48c5                	li	a7,17
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d8:	48c9                	li	a7,18
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e0:	48a1                	li	a7,8
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <link>:
.global link
link:
 li a7, SYS_link
 3e8:	48cd                	li	a7,19
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f0:	48d1                	li	a7,20
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f8:	48a5                	li	a7,9
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <dup>:
.global dup
dup:
 li a7, SYS_dup
 400:	48a9                	li	a7,10
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 408:	48ad                	li	a7,11
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 410:	48b1                	li	a7,12
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <pause>:
.global pause
pause:
 li a7, SYS_pause
 418:	48b5                	li	a7,13
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 420:	48b9                	li	a7,14
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 428:	48d9                	li	a7,22
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 430:	48dd                	li	a7,23
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 438:	48e1                	li	a7,24
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 440:	48e5                	li	a7,25
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 448:	48e9                	li	a7,26
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 450:	48ed                	li	a7,27
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 458:	48f1                	li	a7,28
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 460:	48f5                	li	a7,29
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 468:	1101                	addi	sp,sp,-32
 46a:	ec06                	sd	ra,24(sp)
 46c:	e822                	sd	s0,16(sp)
 46e:	1000                	addi	s0,sp,32
 470:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 474:	4605                	li	a2,1
 476:	fef40593          	addi	a1,s0,-17
 47a:	f2fff0ef          	jal	ra,3a8 <write>
}
 47e:	60e2                	ld	ra,24(sp)
 480:	6442                	ld	s0,16(sp)
 482:	6105                	addi	sp,sp,32
 484:	8082                	ret

0000000000000486 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 486:	715d                	addi	sp,sp,-80
 488:	e486                	sd	ra,72(sp)
 48a:	e0a2                	sd	s0,64(sp)
 48c:	fc26                	sd	s1,56(sp)
 48e:	f84a                	sd	s2,48(sp)
 490:	f44e                	sd	s3,40(sp)
 492:	0880                	addi	s0,sp,80
 494:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 496:	c299                	beqz	a3,49c <printint+0x16>
 498:	0805c163          	bltz	a1,51a <printint+0x94>
  neg = 0;
 49c:	4881                	li	a7,0
 49e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4a2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4a4:	00000517          	auipc	a0,0x0
 4a8:	58450513          	addi	a0,a0,1412 # a28 <digits>
 4ac:	883e                	mv	a6,a5
 4ae:	2785                	addiw	a5,a5,1
 4b0:	02c5f733          	remu	a4,a1,a2
 4b4:	972a                	add	a4,a4,a0
 4b6:	00074703          	lbu	a4,0(a4)
 4ba:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4be:	872e                	mv	a4,a1
 4c0:	02c5d5b3          	divu	a1,a1,a2
 4c4:	0685                	addi	a3,a3,1
 4c6:	fec773e3          	bgeu	a4,a2,4ac <printint+0x26>
  if(neg)
 4ca:	00088b63          	beqz	a7,4e0 <printint+0x5a>
    buf[i++] = '-';
 4ce:	fd040713          	addi	a4,s0,-48
 4d2:	97ba                	add	a5,a5,a4
 4d4:	02d00713          	li	a4,45
 4d8:	fee78423          	sb	a4,-24(a5)
 4dc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4e0:	02f05663          	blez	a5,50c <printint+0x86>
 4e4:	fb840713          	addi	a4,s0,-72
 4e8:	00f704b3          	add	s1,a4,a5
 4ec:	fff70993          	addi	s3,a4,-1
 4f0:	99be                	add	s3,s3,a5
 4f2:	37fd                	addiw	a5,a5,-1
 4f4:	1782                	slli	a5,a5,0x20
 4f6:	9381                	srli	a5,a5,0x20
 4f8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4fc:	fff4c583          	lbu	a1,-1(s1)
 500:	854a                	mv	a0,s2
 502:	f67ff0ef          	jal	ra,468 <putc>
  while(--i >= 0)
 506:	14fd                	addi	s1,s1,-1
 508:	ff349ae3          	bne	s1,s3,4fc <printint+0x76>
}
 50c:	60a6                	ld	ra,72(sp)
 50e:	6406                	ld	s0,64(sp)
 510:	74e2                	ld	s1,56(sp)
 512:	7942                	ld	s2,48(sp)
 514:	79a2                	ld	s3,40(sp)
 516:	6161                	addi	sp,sp,80
 518:	8082                	ret
    x = -xx;
 51a:	40b005b3          	neg	a1,a1
    neg = 1;
 51e:	4885                	li	a7,1
    x = -xx;
 520:	bfbd                	j	49e <printint+0x18>

0000000000000522 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 522:	7119                	addi	sp,sp,-128
 524:	fc86                	sd	ra,120(sp)
 526:	f8a2                	sd	s0,112(sp)
 528:	f4a6                	sd	s1,104(sp)
 52a:	f0ca                	sd	s2,96(sp)
 52c:	ecce                	sd	s3,88(sp)
 52e:	e8d2                	sd	s4,80(sp)
 530:	e4d6                	sd	s5,72(sp)
 532:	e0da                	sd	s6,64(sp)
 534:	fc5e                	sd	s7,56(sp)
 536:	f862                	sd	s8,48(sp)
 538:	f466                	sd	s9,40(sp)
 53a:	f06a                	sd	s10,32(sp)
 53c:	ec6e                	sd	s11,24(sp)
 53e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 540:	0005c903          	lbu	s2,0(a1)
 544:	24090c63          	beqz	s2,79c <vprintf+0x27a>
 548:	8b2a                	mv	s6,a0
 54a:	8a2e                	mv	s4,a1
 54c:	8bb2                	mv	s7,a2
  state = 0;
 54e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 550:	4481                	li	s1,0
 552:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 554:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 558:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 55c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 560:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 564:	00000c97          	auipc	s9,0x0
 568:	4c4c8c93          	addi	s9,s9,1220 # a28 <digits>
 56c:	a005                	j	58c <vprintf+0x6a>
        putc(fd, c0);
 56e:	85ca                	mv	a1,s2
 570:	855a                	mv	a0,s6
 572:	ef7ff0ef          	jal	ra,468 <putc>
 576:	a019                	j	57c <vprintf+0x5a>
    } else if(state == '%'){
 578:	03598263          	beq	s3,s5,59c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 57c:	2485                	addiw	s1,s1,1
 57e:	8726                	mv	a4,s1
 580:	009a07b3          	add	a5,s4,s1
 584:	0007c903          	lbu	s2,0(a5)
 588:	20090a63          	beqz	s2,79c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 58c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 590:	fe0994e3          	bnez	s3,578 <vprintf+0x56>
      if(c0 == '%'){
 594:	fd579de3          	bne	a5,s5,56e <vprintf+0x4c>
        state = '%';
 598:	89be                	mv	s3,a5
 59a:	b7cd                	j	57c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 59c:	c3c1                	beqz	a5,61c <vprintf+0xfa>
 59e:	00ea06b3          	add	a3,s4,a4
 5a2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5a6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5a8:	c681                	beqz	a3,5b0 <vprintf+0x8e>
 5aa:	9752                	add	a4,a4,s4
 5ac:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b0:	03878e63          	beq	a5,s8,5ec <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	05a78863          	beq	a5,s10,604 <vprintf+0xe2>
      } else if(c0 == 'u'){
 5b8:	0db78b63          	beq	a5,s11,68e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5bc:	07800713          	li	a4,120
 5c0:	10e78d63          	beq	a5,a4,6da <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5c4:	07000713          	li	a4,112
 5c8:	14e78263          	beq	a5,a4,70c <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5cc:	06300713          	li	a4,99
 5d0:	16e78f63          	beq	a5,a4,74e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5d4:	07300713          	li	a4,115
 5d8:	18e78563          	beq	a5,a4,762 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5dc:	05579063          	bne	a5,s5,61c <vprintf+0xfa>
        putc(fd, '%');
 5e0:	85d6                	mv	a1,s5
 5e2:	855a                	mv	a0,s6
 5e4:	e85ff0ef          	jal	ra,468 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	bf49                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4685                	li	a3,1
 5f2:	4629                	li	a2,10
 5f4:	000ba583          	lw	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	e8dff0ef          	jal	ra,486 <printint>
 5fe:	8bca                	mv	s7,s2
      state = 0;
 600:	4981                	li	s3,0
 602:	bfad                	j	57c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 604:	03868663          	beq	a3,s8,630 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 608:	05a68163          	beq	a3,s10,64a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 60c:	09b68d63          	beq	a3,s11,6a6 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 610:	03a68f63          	beq	a3,s10,64e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 614:	07800793          	li	a5,120
 618:	0cf68d63          	beq	a3,a5,6f2 <vprintf+0x1d0>
        putc(fd, '%');
 61c:	85d6                	mv	a1,s5
 61e:	855a                	mv	a0,s6
 620:	e49ff0ef          	jal	ra,468 <putc>
        putc(fd, c0);
 624:	85ca                	mv	a1,s2
 626:	855a                	mv	a0,s6
 628:	e41ff0ef          	jal	ra,468 <putc>
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b7b9                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 630:	008b8913          	addi	s2,s7,8
 634:	4685                	li	a3,1
 636:	4629                	li	a2,10
 638:	000bb583          	ld	a1,0(s7)
 63c:	855a                	mv	a0,s6
 63e:	e49ff0ef          	jal	ra,486 <printint>
        i += 1;
 642:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
        i += 1;
 648:	bf15                	j	57c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 64a:	03860563          	beq	a2,s8,674 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 64e:	07b60963          	beq	a2,s11,6c0 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 652:	07800793          	li	a5,120
 656:	fcf613e3          	bne	a2,a5,61c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4681                	li	a3,0
 660:	4641                	li	a2,16
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	e1fff0ef          	jal	ra,486 <printint>
        i += 2;
 66c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
        i += 2;
 672:	b729                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 674:	008b8913          	addi	s2,s7,8
 678:	4685                	li	a3,1
 67a:	4629                	li	a2,10
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	e05ff0ef          	jal	ra,486 <printint>
        i += 2;
 686:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
        i += 2;
 68c:	bdc5                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 68e:	008b8913          	addi	s2,s7,8
 692:	4681                	li	a3,0
 694:	4629                	li	a2,10
 696:	000be583          	lwu	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	debff0ef          	jal	ra,486 <printint>
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bde1                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	dd3ff0ef          	jal	ra,486 <printint>
        i += 1;
 6b8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 1;
 6be:	bd7d                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4629                	li	a2,10
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	db9ff0ef          	jal	ra,486 <printint>
        i += 2;
 6d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	b555                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4641                	li	a2,16
 6e2:	000be583          	lwu	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	d9fff0ef          	jal	ra,486 <printint>
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b571                	j	57c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4641                	li	a2,16
 6fa:	000bb583          	ld	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	d87ff0ef          	jal	ra,486 <printint>
        i += 1;
 704:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
        i += 1;
 70a:	bd8d                	j	57c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 70c:	008b8793          	addi	a5,s7,8
 710:	f8f43423          	sd	a5,-120(s0)
 714:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 718:	03000593          	li	a1,48
 71c:	855a                	mv	a0,s6
 71e:	d4bff0ef          	jal	ra,468 <putc>
  putc(fd, 'x');
 722:	07800593          	li	a1,120
 726:	855a                	mv	a0,s6
 728:	d41ff0ef          	jal	ra,468 <putc>
 72c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72e:	03c9d793          	srli	a5,s3,0x3c
 732:	97e6                	add	a5,a5,s9
 734:	0007c583          	lbu	a1,0(a5)
 738:	855a                	mv	a0,s6
 73a:	d2fff0ef          	jal	ra,468 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73e:	0992                	slli	s3,s3,0x4
 740:	397d                	addiw	s2,s2,-1
 742:	fe0916e3          	bnez	s2,72e <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 746:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 74a:	4981                	li	s3,0
 74c:	bd05                	j	57c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 74e:	008b8913          	addi	s2,s7,8
 752:	000bc583          	lbu	a1,0(s7)
 756:	855a                	mv	a0,s6
 758:	d11ff0ef          	jal	ra,468 <putc>
 75c:	8bca                	mv	s7,s2
      state = 0;
 75e:	4981                	li	s3,0
 760:	bd31                	j	57c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 762:	008b8993          	addi	s3,s7,8
 766:	000bb903          	ld	s2,0(s7)
 76a:	00090f63          	beqz	s2,788 <vprintf+0x266>
        for(; *s; s++)
 76e:	00094583          	lbu	a1,0(s2)
 772:	c195                	beqz	a1,796 <vprintf+0x274>
          putc(fd, *s);
 774:	855a                	mv	a0,s6
 776:	cf3ff0ef          	jal	ra,468 <putc>
        for(; *s; s++)
 77a:	0905                	addi	s2,s2,1
 77c:	00094583          	lbu	a1,0(s2)
 780:	f9f5                	bnez	a1,774 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 782:	8bce                	mv	s7,s3
      state = 0;
 784:	4981                	li	s3,0
 786:	bbdd                	j	57c <vprintf+0x5a>
          s = "(null)";
 788:	00000917          	auipc	s2,0x0
 78c:	29890913          	addi	s2,s2,664 # a20 <malloc+0x182>
        for(; *s; s++)
 790:	02800593          	li	a1,40
 794:	b7c5                	j	774 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 796:	8bce                	mv	s7,s3
      state = 0;
 798:	4981                	li	s3,0
 79a:	b3cd                	j	57c <vprintf+0x5a>
    }
  }
}
 79c:	70e6                	ld	ra,120(sp)
 79e:	7446                	ld	s0,112(sp)
 7a0:	74a6                	ld	s1,104(sp)
 7a2:	7906                	ld	s2,96(sp)
 7a4:	69e6                	ld	s3,88(sp)
 7a6:	6a46                	ld	s4,80(sp)
 7a8:	6aa6                	ld	s5,72(sp)
 7aa:	6b06                	ld	s6,64(sp)
 7ac:	7be2                	ld	s7,56(sp)
 7ae:	7c42                	ld	s8,48(sp)
 7b0:	7ca2                	ld	s9,40(sp)
 7b2:	7d02                	ld	s10,32(sp)
 7b4:	6de2                	ld	s11,24(sp)
 7b6:	6109                	addi	sp,sp,128
 7b8:	8082                	ret

00000000000007ba <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 7ba:	715d                	addi	sp,sp,-80
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	e010                	sd	a2,0(s0)
 7c4:	e414                	sd	a3,8(s0)
 7c6:	e818                	sd	a4,16(s0)
 7c8:	ec1c                	sd	a5,24(s0)
 7ca:	03043023          	sd	a6,32(s0)
 7ce:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d6:	8622                	mv	a2,s0
 7d8:	d4bff0ef          	jal	ra,522 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6161                	addi	sp,sp,80
 7e2:	8082                	ret

00000000000007e4 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7e4:	711d                	addi	sp,sp,-96
 7e6:	ec06                	sd	ra,24(sp)
 7e8:	e822                	sd	s0,16(sp)
 7ea:	1000                	addi	s0,sp,32
 7ec:	e40c                	sd	a1,8(s0)
 7ee:	e810                	sd	a2,16(s0)
 7f0:	ec14                	sd	a3,24(s0)
 7f2:	f018                	sd	a4,32(s0)
 7f4:	f41c                	sd	a5,40(s0)
 7f6:	03043823          	sd	a6,48(s0)
 7fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fe:	00840613          	addi	a2,s0,8
 802:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 806:	85aa                	mv	a1,a0
 808:	4505                	li	a0,1
 80a:	d19ff0ef          	jal	ra,522 <vprintf>
}
 80e:	60e2                	ld	ra,24(sp)
 810:	6442                	ld	s0,16(sp)
 812:	6125                	addi	sp,sp,96
 814:	8082                	ret

0000000000000816 <free>:
 *   无
 */

void
free(void *ap)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 81c:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	00000797          	auipc	a5,0x0
 824:	7e07b783          	ld	a5,2016(a5) # 1000 <freep>
 828:	a805                	j	858 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82a:	4618                	lw	a4,8(a2)
 82c:	9db9                	addw	a1,a1,a4
 82e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	6318                	ld	a4,0(a4)
 836:	fee53823          	sd	a4,-16(a0)
 83a:	a091                	j	87e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 83c:	ff852703          	lw	a4,-8(a0)
 840:	9e39                	addw	a2,a2,a4
 842:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 844:	ff053703          	ld	a4,-16(a0)
 848:	e398                	sd	a4,0(a5)
 84a:	a099                	j	890 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84c:	6398                	ld	a4,0(a5)
 84e:	00e7e463          	bltu	a5,a4,856 <free+0x40>
 852:	00e6ea63          	bltu	a3,a4,866 <free+0x50>
{
 856:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 858:	fed7fae3          	bgeu	a5,a3,84c <free+0x36>
 85c:	6398                	ld	a4,0(a5)
 85e:	00e6e463          	bltu	a3,a4,866 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	fee7eae3          	bltu	a5,a4,856 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 866:	ff852583          	lw	a1,-8(a0)
 86a:	6390                	ld	a2,0(a5)
 86c:	02059713          	slli	a4,a1,0x20
 870:	9301                	srli	a4,a4,0x20
 872:	0712                	slli	a4,a4,0x4
 874:	9736                	add	a4,a4,a3
 876:	fae60ae3          	beq	a2,a4,82a <free+0x14>
    bp->s.ptr = p->s.ptr;
 87a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 87e:	4790                	lw	a2,8(a5)
 880:	02061713          	slli	a4,a2,0x20
 884:	9301                	srli	a4,a4,0x20
 886:	0712                	slli	a4,a4,0x4
 888:	973e                	add	a4,a4,a5
 88a:	fae689e3          	beq	a3,a4,83c <free+0x26>
  } else
    p->s.ptr = bp;
 88e:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 890:	00000717          	auipc	a4,0x0
 894:	76f73823          	sd	a5,1904(a4) # 1000 <freep>
}
 898:	6422                	ld	s0,8(sp)
 89a:	0141                	addi	sp,sp,16
 89c:	8082                	ret

000000000000089e <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 89e:	7139                	addi	sp,sp,-64
 8a0:	fc06                	sd	ra,56(sp)
 8a2:	f822                	sd	s0,48(sp)
 8a4:	f426                	sd	s1,40(sp)
 8a6:	f04a                	sd	s2,32(sp)
 8a8:	ec4e                	sd	s3,24(sp)
 8aa:	e852                	sd	s4,16(sp)
 8ac:	e456                	sd	s5,8(sp)
 8ae:	e05a                	sd	s6,0(sp)
 8b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b2:	02051493          	slli	s1,a0,0x20
 8b6:	9081                	srli	s1,s1,0x20
 8b8:	04bd                	addi	s1,s1,15
 8ba:	8091                	srli	s1,s1,0x4
 8bc:	0014899b          	addiw	s3,s1,1
 8c0:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 8c2:	00000517          	auipc	a0,0x0
 8c6:	73e53503          	ld	a0,1854(a0) # 1000 <freep>
 8ca:	c515                	beqz	a0,8f6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8ce:	4798                	lw	a4,8(a5)
 8d0:	02977f63          	bgeu	a4,s1,90e <malloc+0x70>
 8d4:	8a4e                	mv	s4,s3
 8d6:	0009871b          	sext.w	a4,s3
 8da:	6685                	lui	a3,0x1
 8dc:	00d77363          	bgeu	a4,a3,8e2 <malloc+0x44>
 8e0:	6a05                	lui	s4,0x1
 8e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8e6:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8ea:	00000917          	auipc	s2,0x0
 8ee:	71690913          	addi	s2,s2,1814 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8f2:	5afd                	li	s5,-1
 8f4:	a0bd                	j	962 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8f6:	00000797          	auipc	a5,0x0
 8fa:	71a78793          	addi	a5,a5,1818 # 1010 <base>
 8fe:	00000717          	auipc	a4,0x0
 902:	70f73123          	sd	a5,1794(a4) # 1000 <freep>
 906:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 908:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 90c:	b7e1                	j	8d4 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 90e:	02e48b63          	beq	s1,a4,944 <malloc+0xa6>
        p->s.size -= nunits;
 912:	4137073b          	subw	a4,a4,s3
 916:	c798                	sw	a4,8(a5)
        p += p->s.size;
 918:	1702                	slli	a4,a4,0x20
 91a:	9301                	srli	a4,a4,0x20
 91c:	0712                	slli	a4,a4,0x4
 91e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 920:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 924:	00000717          	auipc	a4,0x0
 928:	6ca73e23          	sd	a0,1756(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 92c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 930:	70e2                	ld	ra,56(sp)
 932:	7442                	ld	s0,48(sp)
 934:	74a2                	ld	s1,40(sp)
 936:	7902                	ld	s2,32(sp)
 938:	69e2                	ld	s3,24(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
 940:	6121                	addi	sp,sp,64
 942:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 944:	6398                	ld	a4,0(a5)
 946:	e118                	sd	a4,0(a0)
 948:	bff1                	j	924 <malloc+0x86>
  hp->s.size = nu;
 94a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 94e:	0541                	addi	a0,a0,16
 950:	ec7ff0ef          	jal	ra,816 <free>
  return freep;
 954:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 958:	dd61                	beqz	a0,930 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 95c:	4798                	lw	a4,8(a5)
 95e:	fa9778e3          	bgeu	a4,s1,90e <malloc+0x70>
    if(p == freep)
 962:	00093703          	ld	a4,0(s2)
 966:	853e                	mv	a0,a5
 968:	fef719e3          	bne	a4,a5,95a <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 96c:	8552                	mv	a0,s4
 96e:	9e7ff0ef          	jal	ra,354 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 972:	fd551ce3          	bne	a0,s5,94a <malloc+0xac>
        return 0;  /* 内存分配失败 */
 976:	4501                	li	a0,0
 978:	bf65                	j	930 <malloc+0x92>
