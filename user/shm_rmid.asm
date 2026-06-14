
user/_shm_rmid:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/stat.h"
#include "../kernel/shm.h"
#include "user.h"


int main(void){
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
  14:	45e000ef          	jal	ra,472 <mmap>
  if(p == (char*)-1){ printf("mmap1 fail\n"); exit(1); }
  18:	57fd                	li	a5,-1
  1a:	04f50e63          	beq	a0,a5,76 <main+0x76>
  1e:	84aa                	mv	s1,a0
  p[0] = 7;
  20:	479d                	li	a5,7
  22:	00f50023          	sb	a5,0(a0)

  int pid = fork();
  26:	3a4000ef          	jal	ra,3ca <fork>
  if(pid == 0){
  2a:	e925                	bnez	a0,9a <main+0x9a>
    char *c = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  2c:	4705                	li	a4,1
  2e:	468d                	li	a3,3
  30:	460d                	li	a2,3
  32:	6585                	lui	a1,0x1
  34:	43e000ef          	jal	ra,472 <mmap>
  38:	84aa                	mv	s1,a0
    if(c == (char*)-1){ printf("child mmap fail\n"); exit(1); }
  3a:	57fd                	li	a5,-1
  3c:	04f50663          	beq	a0,a5,88 <main+0x88>
    printf("child sees %d\n", c[0]);
  40:	00054583          	lbu	a1,0(a0)
  44:	00001517          	auipc	a0,0x1
  48:	9b450513          	addi	a0,a0,-1612 # 9f8 <malloc+0x110>
  4c:	7e2000ef          	jal	ra,82e <printf>
    sleep(50);
  50:	03200513          	li	a0,50
  54:	436000ef          	jal	ra,48a <sleep>
    printf("child still sees %d\n", c[0]);
  58:	0004c583          	lbu	a1,0(s1)
  5c:	00001517          	auipc	a0,0x1
  60:	9ac50513          	addi	a0,a0,-1620 # a08 <malloc+0x120>
  64:	7ca000ef          	jal	ra,82e <printf>
    munmap(c, 4096);
  68:	6585                	lui	a1,0x1
  6a:	8526                	mv	a0,s1
  6c:	40e000ef          	jal	ra,47a <munmap>
    exit(0);
  70:	4501                	li	a0,0
  72:	360000ef          	jal	ra,3d2 <exit>
  if(p == (char*)-1){ printf("mmap1 fail\n"); exit(1); }
  76:	00001517          	auipc	a0,0x1
  7a:	95a50513          	addi	a0,a0,-1702 # 9d0 <malloc+0xe8>
  7e:	7b0000ef          	jal	ra,82e <printf>
  82:	4505                	li	a0,1
  84:	34e000ef          	jal	ra,3d2 <exit>
    if(c == (char*)-1){ printf("child mmap fail\n"); exit(1); }
  88:	00001517          	auipc	a0,0x1
  8c:	95850513          	addi	a0,a0,-1704 # 9e0 <malloc+0xf8>
  90:	79e000ef          	jal	ra,82e <printf>
  94:	4505                	li	a0,1
  96:	33c000ef          	jal	ra,3d2 <exit>
  }

  sleep(20);
  9a:	4551                	li	a0,20
  9c:	3ee000ef          	jal	ra,48a <sleep>
  printf("parent rmid: %d\n", shmctl(key, IPC_RMID));
  a0:	4581                	li	a1,0
  a2:	4505                	li	a0,1
  a4:	3de000ef          	jal	ra,482 <shmctl>
  a8:	85aa                	mv	a1,a0
  aa:	00001517          	auipc	a0,0x1
  ae:	97650513          	addi	a0,a0,-1674 # a20 <malloc+0x138>
  b2:	77c000ef          	jal	ra,82e <printf>

  // deleted 后不允许新的 attach
  char *q = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  b6:	4705                	li	a4,1
  b8:	468d                	li	a3,3
  ba:	460d                	li	a2,3
  bc:	6585                	lui	a1,0x1
  be:	4501                	li	a0,0
  c0:	3b2000ef          	jal	ra,472 <mmap>
  if(q != (char*)-1){
  c4:	57fd                	li	a5,-1
  c6:	00f50b63          	beq	a0,a5,dc <main+0xdc>
    printf("FAIL: mmap after rmid should fail\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	96e50513          	addi	a0,a0,-1682 # a38 <malloc+0x150>
  d2:	75c000ef          	jal	ra,82e <printf>
    exit(1);
  d6:	4505                	li	a0,1
  d8:	2fa000ef          	jal	ra,3d2 <exit>
  } else {
    printf("OK: mmap after rmid rejected\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	98450513          	addi	a0,a0,-1660 # a60 <malloc+0x178>
  e4:	74a000ef          	jal	ra,82e <printf>
  }

  wait(0);
  e8:	4501                	li	a0,0
  ea:	2f0000ef          	jal	ra,3da <wait>
  munmap(p, 4096);
  ee:	6585                	lui	a1,0x1
  f0:	8526                	mv	a0,s1
  f2:	388000ef          	jal	ra,47a <munmap>

  // 现在对象应已真正释放；再 mmap 应得到新对象（默认内容 0）
  char *r = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  f6:	4705                	li	a4,1
  f8:	468d                	li	a3,3
  fa:	460d                	li	a2,3
  fc:	6585                	lui	a1,0x1
  fe:	4501                	li	a0,0
 100:	372000ef          	jal	ra,472 <mmap>
 104:	84aa                	mv	s1,a0
  if(r == (char*)-1){ printf("mmap after free fail\n"); exit(1); }
 106:	57fd                	li	a5,-1
 108:	02f50163          	beq	a0,a5,12a <main+0x12a>
  printf("new object r[0]=%d (expect 0)\n", r[0]);
 10c:	00054583          	lbu	a1,0(a0)
 110:	00001517          	auipc	a0,0x1
 114:	98850513          	addi	a0,a0,-1656 # a98 <malloc+0x1b0>
 118:	716000ef          	jal	ra,82e <printf>
  munmap(r, 4096);
 11c:	6585                	lui	a1,0x1
 11e:	8526                	mv	a0,s1
 120:	35a000ef          	jal	ra,47a <munmap>

  exit(0);
 124:	4501                	li	a0,0
 126:	2ac000ef          	jal	ra,3d2 <exit>
  if(r == (char*)-1){ printf("mmap after free fail\n"); exit(1); }
 12a:	00001517          	auipc	a0,0x1
 12e:	95650513          	addi	a0,a0,-1706 # a80 <malloc+0x198>
 132:	6fc000ef          	jal	ra,82e <printf>
 136:	4505                	li	a0,1
 138:	29a000ef          	jal	ra,3d2 <exit>

000000000000013c <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e406                	sd	ra,8(sp)
 140:	e022                	sd	s0,0(sp)
 142:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 144:	ebdff0ef          	jal	ra,0 <main>
  exit(r);
 148:	28a000ef          	jal	ra,3d2 <exit>

000000000000014c <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 152:	87aa                	mv	a5,a0
 154:	0585                	addi	a1,a1,1
 156:	0785                	addi	a5,a5,1
 158:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x53f>
 15c:	fee78fa3          	sb	a4,-1(a5)
 160:	fb75                	bnez	a4,154 <strcpy+0x8>
    ;
  return os;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb91                	beqz	a5,186 <strcmp+0x1e>
 174:	0005c703          	lbu	a4,0(a1)
 178:	00f71763          	bne	a4,a5,186 <strcmp+0x1e>
    p++, q++;
 17c:	0505                	addi	a0,a0,1
 17e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 180:	00054783          	lbu	a5,0(a0)
 184:	fbe5                	bnez	a5,174 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 186:	0005c503          	lbu	a0,0(a1)
}
 18a:	40a7853b          	subw	a0,a5,a0
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret

0000000000000194 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19a:	00054783          	lbu	a5,0(a0)
 19e:	cf91                	beqz	a5,1ba <strlen+0x26>
 1a0:	0505                	addi	a0,a0,1
 1a2:	87aa                	mv	a5,a0
 1a4:	4685                	li	a3,1
 1a6:	9e89                	subw	a3,a3,a0
 1a8:	00f6853b          	addw	a0,a3,a5
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff7c703          	lbu	a4,-1(a5)
 1b2:	fb7d                	bnez	a4,1a8 <strlen+0x14>
    ;
  return n;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret
  for(n = 0; s[n]; n++)
 1ba:	4501                	li	a0,0
 1bc:	bfe5                	j	1b4 <strlen+0x20>

00000000000001be <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c4:	ca19                	beqz	a2,1da <memset+0x1c>
 1c6:	87aa                	mv	a5,a0
 1c8:	1602                	slli	a2,a2,0x20
 1ca:	9201                	srli	a2,a2,0x20
 1cc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d4:	0785                	addi	a5,a5,1
 1d6:	fee79de3          	bne	a5,a4,1d0 <memset+0x12>
  }
  return dst;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret

00000000000001e0 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e6:	00054783          	lbu	a5,0(a0)
 1ea:	cb99                	beqz	a5,200 <strchr+0x20>
    if(*s == c)
 1ec:	00f58763          	beq	a1,a5,1fa <strchr+0x1a>
  for(; *s; s++)
 1f0:	0505                	addi	a0,a0,1
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	fbfd                	bnez	a5,1ec <strchr+0xc>
      return (char*)s;
  return 0;
 1f8:	4501                	li	a0,0
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
  return 0;
 200:	4501                	li	a0,0
 202:	bfe5                	j	1fa <strchr+0x1a>

0000000000000204 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 204:	711d                	addi	sp,sp,-96
 206:	ec86                	sd	ra,88(sp)
 208:	e8a2                	sd	s0,80(sp)
 20a:	e4a6                	sd	s1,72(sp)
 20c:	e0ca                	sd	s2,64(sp)
 20e:	fc4e                	sd	s3,56(sp)
 210:	f852                	sd	s4,48(sp)
 212:	f456                	sd	s5,40(sp)
 214:	f05a                	sd	s6,32(sp)
 216:	ec5e                	sd	s7,24(sp)
 218:	1080                	addi	s0,sp,96
 21a:	8baa                	mv	s7,a0
 21c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21e:	892a                	mv	s2,a0
 220:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 222:	4aa9                	li	s5,10
 224:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 226:	89a6                	mv	s3,s1
 228:	2485                	addiw	s1,s1,1
 22a:	0344d663          	bge	s1,s4,256 <gets+0x52>
    cc = read(0, &c, 1);
 22e:	4605                	li	a2,1
 230:	faf40593          	addi	a1,s0,-81
 234:	4501                	li	a0,0
 236:	1b4000ef          	jal	ra,3ea <read>
    if(cc < 1)
 23a:	00a05e63          	blez	a0,256 <gets+0x52>
    buf[i++] = c;
 23e:	faf44783          	lbu	a5,-81(s0)
 242:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 246:	01578763          	beq	a5,s5,254 <gets+0x50>
 24a:	0905                	addi	s2,s2,1
 24c:	fd679de3          	bne	a5,s6,226 <gets+0x22>
  for(i=0; i+1 < max; ){
 250:	89a6                	mv	s3,s1
 252:	a011                	j	256 <gets+0x52>
 254:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 256:	99de                	add	s3,s3,s7
 258:	00098023          	sb	zero,0(s3)
  return buf;
}
 25c:	855e                	mv	a0,s7
 25e:	60e6                	ld	ra,88(sp)
 260:	6446                	ld	s0,80(sp)
 262:	64a6                	ld	s1,72(sp)
 264:	6906                	ld	s2,64(sp)
 266:	79e2                	ld	s3,56(sp)
 268:	7a42                	ld	s4,48(sp)
 26a:	7aa2                	ld	s5,40(sp)
 26c:	7b02                	ld	s6,32(sp)
 26e:	6be2                	ld	s7,24(sp)
 270:	6125                	addi	sp,sp,96
 272:	8082                	ret

0000000000000274 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 274:	1101                	addi	sp,sp,-32
 276:	ec06                	sd	ra,24(sp)
 278:	e822                	sd	s0,16(sp)
 27a:	e426                	sd	s1,8(sp)
 27c:	e04a                	sd	s2,0(sp)
 27e:	1000                	addi	s0,sp,32
 280:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 282:	4581                	li	a1,0
 284:	18e000ef          	jal	ra,412 <open>
  if(fd < 0)
 288:	02054163          	bltz	a0,2aa <stat+0x36>
 28c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 28e:	85ca                	mv	a1,s2
 290:	19a000ef          	jal	ra,42a <fstat>
 294:	892a                	mv	s2,a0
  close(fd);
 296:	8526                	mv	a0,s1
 298:	162000ef          	jal	ra,3fa <close>
  return r;
}
 29c:	854a                	mv	a0,s2
 29e:	60e2                	ld	ra,24(sp)
 2a0:	6442                	ld	s0,16(sp)
 2a2:	64a2                	ld	s1,8(sp)
 2a4:	6902                	ld	s2,0(sp)
 2a6:	6105                	addi	sp,sp,32
 2a8:	8082                	ret
    return -1;
 2aa:	597d                	li	s2,-1
 2ac:	bfc5                	j	29c <stat+0x28>

00000000000002ae <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b4:	00054603          	lbu	a2,0(a0)
 2b8:	fd06079b          	addiw	a5,a2,-48
 2bc:	0ff7f793          	andi	a5,a5,255
 2c0:	4725                	li	a4,9
 2c2:	02f76963          	bltu	a4,a5,2f4 <atoi+0x46>
 2c6:	86aa                	mv	a3,a0
  n = 0;
 2c8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2ca:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2cc:	0685                	addi	a3,a3,1
 2ce:	0025179b          	slliw	a5,a0,0x2
 2d2:	9fa9                	addw	a5,a5,a0
 2d4:	0017979b          	slliw	a5,a5,0x1
 2d8:	9fb1                	addw	a5,a5,a2
 2da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2de:	0006c603          	lbu	a2,0(a3)
 2e2:	fd06071b          	addiw	a4,a2,-48
 2e6:	0ff77713          	andi	a4,a4,255
 2ea:	fee5f1e3          	bgeu	a1,a4,2cc <atoi+0x1e>
  return n;
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
  n = 0;
 2f4:	4501                	li	a0,0
 2f6:	bfe5                	j	2ee <atoi+0x40>

00000000000002f8 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fe:	02b57463          	bgeu	a0,a1,326 <memmove+0x2e>
    while(n-- > 0)
 302:	00c05f63          	blez	a2,320 <memmove+0x28>
 306:	1602                	slli	a2,a2,0x20
 308:	9201                	srli	a2,a2,0x20
 30a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30e:	872a                	mv	a4,a0
      *dst++ = *src++;
 310:	0585                	addi	a1,a1,1
 312:	0705                	addi	a4,a4,1
 314:	fff5c683          	lbu	a3,-1(a1)
 318:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 31c:	fee79ae3          	bne	a5,a4,310 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
    dst += n;
 326:	00c50733          	add	a4,a0,a2
    src += n;
 32a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 32c:	fec05ae3          	blez	a2,320 <memmove+0x28>
 330:	fff6079b          	addiw	a5,a2,-1
 334:	1782                	slli	a5,a5,0x20
 336:	9381                	srli	a5,a5,0x20
 338:	fff7c793          	not	a5,a5
 33c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33e:	15fd                	addi	a1,a1,-1
 340:	177d                	addi	a4,a4,-1
 342:	0005c683          	lbu	a3,0(a1)
 346:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34a:	fee79ae3          	bne	a5,a4,33e <memmove+0x46>
 34e:	bfc9                	j	320 <memmove+0x28>

0000000000000350 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e422                	sd	s0,8(sp)
 354:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 356:	ca05                	beqz	a2,386 <memcmp+0x36>
 358:	fff6069b          	addiw	a3,a2,-1
 35c:	1682                	slli	a3,a3,0x20
 35e:	9281                	srli	a3,a3,0x20
 360:	0685                	addi	a3,a3,1
 362:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 364:	00054783          	lbu	a5,0(a0)
 368:	0005c703          	lbu	a4,0(a1)
 36c:	00e79863          	bne	a5,a4,37c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 370:	0505                	addi	a0,a0,1
    p2++;
 372:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 374:	fed518e3          	bne	a0,a3,364 <memcmp+0x14>
  }
  return 0;
 378:	4501                	li	a0,0
 37a:	a019                	j	380 <memcmp+0x30>
      return *p1 - *p2;
 37c:	40e7853b          	subw	a0,a5,a4
}
 380:	6422                	ld	s0,8(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret
  return 0;
 386:	4501                	li	a0,0
 388:	bfe5                	j	380 <memcmp+0x30>

000000000000038a <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e406                	sd	ra,8(sp)
 38e:	e022                	sd	s0,0(sp)
 390:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 392:	f67ff0ef          	jal	ra,2f8 <memmove>
}
 396:	60a2                	ld	ra,8(sp)
 398:	6402                	ld	s0,0(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret

000000000000039e <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 39e:	1141                	addi	sp,sp,-16
 3a0:	e406                	sd	ra,8(sp)
 3a2:	e022                	sd	s0,0(sp)
 3a4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3a6:	4585                	li	a1,1
 3a8:	0b2000ef          	jal	ra,45a <sys_sbrk>
}
 3ac:	60a2                	ld	ra,8(sp)
 3ae:	6402                	ld	s0,0(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret

00000000000003b4 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e406                	sd	ra,8(sp)
 3b8:	e022                	sd	s0,0(sp)
 3ba:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3bc:	4589                	li	a1,2
 3be:	09c000ef          	jal	ra,45a <sys_sbrk>
}
 3c2:	60a2                	ld	ra,8(sp)
 3c4:	6402                	ld	s0,0(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret

00000000000003ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ca:	4885                	li	a7,1
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d2:	4889                	li	a7,2
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <wait>:
.global wait
wait:
 li a7, SYS_wait
 3da:	488d                	li	a7,3
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e2:	4891                	li	a7,4
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <read>:
.global read
read:
 li a7, SYS_read
 3ea:	4895                	li	a7,5
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <write>:
.global write
write:
 li a7, SYS_write
 3f2:	48c1                	li	a7,16
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <close>:
.global close
close:
 li a7, SYS_close
 3fa:	48d5                	li	a7,21
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <kill>:
.global kill
kill:
 li a7, SYS_kill
 402:	4899                	li	a7,6
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <exec>:
.global exec
exec:
 li a7, SYS_exec
 40a:	489d                	li	a7,7
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <open>:
.global open
open:
 li a7, SYS_open
 412:	48bd                	li	a7,15
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41a:	48c5                	li	a7,17
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 422:	48c9                	li	a7,18
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42a:	48a1                	li	a7,8
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <link>:
.global link
link:
 li a7, SYS_link
 432:	48cd                	li	a7,19
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43a:	48d1                	li	a7,20
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 442:	48a5                	li	a7,9
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <dup>:
.global dup
dup:
 li a7, SYS_dup
 44a:	48a9                	li	a7,10
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 452:	48ad                	li	a7,11
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 45a:	48b1                	li	a7,12
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <pause>:
.global pause
pause:
 li a7, SYS_pause
 462:	48b5                	li	a7,13
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46a:	48b9                	li	a7,14
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 472:	48d9                	li	a7,22
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 47a:	48dd                	li	a7,23
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 482:	48e1                	li	a7,24
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 48a:	48e5                	li	a7,25
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 492:	48e9                	li	a7,26
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 49a:	48ed                	li	a7,27
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 4a2:	48f1                	li	a7,28
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 4aa:	48f5                	li	a7,29
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 4b2:	1101                	addi	sp,sp,-32
 4b4:	ec06                	sd	ra,24(sp)
 4b6:	e822                	sd	s0,16(sp)
 4b8:	1000                	addi	s0,sp,32
 4ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4be:	4605                	li	a2,1
 4c0:	fef40593          	addi	a1,s0,-17
 4c4:	f2fff0ef          	jal	ra,3f2 <write>
}
 4c8:	60e2                	ld	ra,24(sp)
 4ca:	6442                	ld	s0,16(sp)
 4cc:	6105                	addi	sp,sp,32
 4ce:	8082                	ret

00000000000004d0 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 4d0:	715d                	addi	sp,sp,-80
 4d2:	e486                	sd	ra,72(sp)
 4d4:	e0a2                	sd	s0,64(sp)
 4d6:	fc26                	sd	s1,56(sp)
 4d8:	f84a                	sd	s2,48(sp)
 4da:	f44e                	sd	s3,40(sp)
 4dc:	0880                	addi	s0,sp,80
 4de:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4e0:	c299                	beqz	a3,4e6 <printint+0x16>
 4e2:	0805c163          	bltz	a1,564 <printint+0x94>
  neg = 0;
 4e6:	4881                	li	a7,0
 4e8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ec:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ee:	00000517          	auipc	a0,0x0
 4f2:	5d250513          	addi	a0,a0,1490 # ac0 <digits>
 4f6:	883e                	mv	a6,a5
 4f8:	2785                	addiw	a5,a5,1
 4fa:	02c5f733          	remu	a4,a1,a2
 4fe:	972a                	add	a4,a4,a0
 500:	00074703          	lbu	a4,0(a4)
 504:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 508:	872e                	mv	a4,a1
 50a:	02c5d5b3          	divu	a1,a1,a2
 50e:	0685                	addi	a3,a3,1
 510:	fec773e3          	bgeu	a4,a2,4f6 <printint+0x26>
  if(neg)
 514:	00088b63          	beqz	a7,52a <printint+0x5a>
    buf[i++] = '-';
 518:	fd040713          	addi	a4,s0,-48
 51c:	97ba                	add	a5,a5,a4
 51e:	02d00713          	li	a4,45
 522:	fee78423          	sb	a4,-24(a5)
 526:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 52a:	02f05663          	blez	a5,556 <printint+0x86>
 52e:	fb840713          	addi	a4,s0,-72
 532:	00f704b3          	add	s1,a4,a5
 536:	fff70993          	addi	s3,a4,-1
 53a:	99be                	add	s3,s3,a5
 53c:	37fd                	addiw	a5,a5,-1
 53e:	1782                	slli	a5,a5,0x20
 540:	9381                	srli	a5,a5,0x20
 542:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 546:	fff4c583          	lbu	a1,-1(s1)
 54a:	854a                	mv	a0,s2
 54c:	f67ff0ef          	jal	ra,4b2 <putc>
  while(--i >= 0)
 550:	14fd                	addi	s1,s1,-1
 552:	ff349ae3          	bne	s1,s3,546 <printint+0x76>
}
 556:	60a6                	ld	ra,72(sp)
 558:	6406                	ld	s0,64(sp)
 55a:	74e2                	ld	s1,56(sp)
 55c:	7942                	ld	s2,48(sp)
 55e:	79a2                	ld	s3,40(sp)
 560:	6161                	addi	sp,sp,80
 562:	8082                	ret
    x = -xx;
 564:	40b005b3          	neg	a1,a1
    neg = 1;
 568:	4885                	li	a7,1
    x = -xx;
 56a:	bfbd                	j	4e8 <printint+0x18>

000000000000056c <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 56c:	7119                	addi	sp,sp,-128
 56e:	fc86                	sd	ra,120(sp)
 570:	f8a2                	sd	s0,112(sp)
 572:	f4a6                	sd	s1,104(sp)
 574:	f0ca                	sd	s2,96(sp)
 576:	ecce                	sd	s3,88(sp)
 578:	e8d2                	sd	s4,80(sp)
 57a:	e4d6                	sd	s5,72(sp)
 57c:	e0da                	sd	s6,64(sp)
 57e:	fc5e                	sd	s7,56(sp)
 580:	f862                	sd	s8,48(sp)
 582:	f466                	sd	s9,40(sp)
 584:	f06a                	sd	s10,32(sp)
 586:	ec6e                	sd	s11,24(sp)
 588:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 58a:	0005c903          	lbu	s2,0(a1)
 58e:	24090c63          	beqz	s2,7e6 <vprintf+0x27a>
 592:	8b2a                	mv	s6,a0
 594:	8a2e                	mv	s4,a1
 596:	8bb2                	mv	s7,a2
  state = 0;
 598:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 59a:	4481                	li	s1,0
 59c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 59e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5a6:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5aa:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ae:	00000c97          	auipc	s9,0x0
 5b2:	512c8c93          	addi	s9,s9,1298 # ac0 <digits>
 5b6:	a005                	j	5d6 <vprintf+0x6a>
        putc(fd, c0);
 5b8:	85ca                	mv	a1,s2
 5ba:	855a                	mv	a0,s6
 5bc:	ef7ff0ef          	jal	ra,4b2 <putc>
 5c0:	a019                	j	5c6 <vprintf+0x5a>
    } else if(state == '%'){
 5c2:	03598263          	beq	s3,s5,5e6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5c6:	2485                	addiw	s1,s1,1
 5c8:	8726                	mv	a4,s1
 5ca:	009a07b3          	add	a5,s4,s1
 5ce:	0007c903          	lbu	s2,0(a5)
 5d2:	20090a63          	beqz	s2,7e6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5d6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5da:	fe0994e3          	bnez	s3,5c2 <vprintf+0x56>
      if(c0 == '%'){
 5de:	fd579de3          	bne	a5,s5,5b8 <vprintf+0x4c>
        state = '%';
 5e2:	89be                	mv	s3,a5
 5e4:	b7cd                	j	5c6 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5e6:	c3c1                	beqz	a5,666 <vprintf+0xfa>
 5e8:	00ea06b3          	add	a3,s4,a4
 5ec:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5f0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5f2:	c681                	beqz	a3,5fa <vprintf+0x8e>
 5f4:	9752                	add	a4,a4,s4
 5f6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5fa:	03878e63          	beq	a5,s8,636 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5fe:	05a78863          	beq	a5,s10,64e <vprintf+0xe2>
      } else if(c0 == 'u'){
 602:	0db78b63          	beq	a5,s11,6d8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 606:	07800713          	li	a4,120
 60a:	10e78d63          	beq	a5,a4,724 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 60e:	07000713          	li	a4,112
 612:	14e78263          	beq	a5,a4,756 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 616:	06300713          	li	a4,99
 61a:	16e78f63          	beq	a5,a4,798 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 61e:	07300713          	li	a4,115
 622:	18e78563          	beq	a5,a4,7ac <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 626:	05579063          	bne	a5,s5,666 <vprintf+0xfa>
        putc(fd, '%');
 62a:	85d6                	mv	a1,s5
 62c:	855a                	mv	a0,s6
 62e:	e85ff0ef          	jal	ra,4b2 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 632:	4981                	li	s3,0
 634:	bf49                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 636:	008b8913          	addi	s2,s7,8
 63a:	4685                	li	a3,1
 63c:	4629                	li	a2,10
 63e:	000ba583          	lw	a1,0(s7)
 642:	855a                	mv	a0,s6
 644:	e8dff0ef          	jal	ra,4d0 <printint>
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
 64c:	bfad                	j	5c6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 64e:	03868663          	beq	a3,s8,67a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 652:	05a68163          	beq	a3,s10,694 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 656:	09b68d63          	beq	a3,s11,6f0 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 65a:	03a68f63          	beq	a3,s10,698 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 65e:	07800793          	li	a5,120
 662:	0cf68d63          	beq	a3,a5,73c <vprintf+0x1d0>
        putc(fd, '%');
 666:	85d6                	mv	a1,s5
 668:	855a                	mv	a0,s6
 66a:	e49ff0ef          	jal	ra,4b2 <putc>
        putc(fd, c0);
 66e:	85ca                	mv	a1,s2
 670:	855a                	mv	a0,s6
 672:	e41ff0ef          	jal	ra,4b2 <putc>
      state = 0;
 676:	4981                	li	s3,0
 678:	b7b9                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4685                	li	a3,1
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	e49ff0ef          	jal	ra,4d0 <printint>
        i += 1;
 68c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 1;
 692:	bf15                	j	5c6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 694:	03860563          	beq	a2,s8,6be <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 698:	07b60963          	beq	a2,s11,70a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 69c:	07800793          	li	a5,120
 6a0:	fcf613e3          	bne	a2,a5,666 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4641                	li	a2,16
 6ac:	000bb583          	ld	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	e1fff0ef          	jal	ra,4d0 <printint>
        i += 2;
 6b6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
        i += 2;
 6bc:	b729                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4685                	li	a3,1
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	e05ff0ef          	jal	ra,4d0 <printint>
        i += 2;
 6d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	bdc5                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000be583          	lwu	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	debff0ef          	jal	ra,4d0 <printint>
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bde1                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4629                	li	a2,10
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	dd3ff0ef          	jal	ra,4d0 <printint>
        i += 1;
 702:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
        i += 1;
 708:	bd7d                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b8913          	addi	s2,s7,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	db9ff0ef          	jal	ra,4d0 <printint>
        i += 2;
 71c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	8bca                	mv	s7,s2
      state = 0;
 720:	4981                	li	s3,0
        i += 2;
 722:	b555                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 724:	008b8913          	addi	s2,s7,8
 728:	4681                	li	a3,0
 72a:	4641                	li	a2,16
 72c:	000be583          	lwu	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	d9fff0ef          	jal	ra,4d0 <printint>
 736:	8bca                	mv	s7,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	b571                	j	5c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 73c:	008b8913          	addi	s2,s7,8
 740:	4681                	li	a3,0
 742:	4641                	li	a2,16
 744:	000bb583          	ld	a1,0(s7)
 748:	855a                	mv	a0,s6
 74a:	d87ff0ef          	jal	ra,4d0 <printint>
        i += 1;
 74e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
        i += 1;
 754:	bd8d                	j	5c6 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 756:	008b8793          	addi	a5,s7,8
 75a:	f8f43423          	sd	a5,-120(s0)
 75e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 762:	03000593          	li	a1,48
 766:	855a                	mv	a0,s6
 768:	d4bff0ef          	jal	ra,4b2 <putc>
  putc(fd, 'x');
 76c:	07800593          	li	a1,120
 770:	855a                	mv	a0,s6
 772:	d41ff0ef          	jal	ra,4b2 <putc>
 776:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 778:	03c9d793          	srli	a5,s3,0x3c
 77c:	97e6                	add	a5,a5,s9
 77e:	0007c583          	lbu	a1,0(a5)
 782:	855a                	mv	a0,s6
 784:	d2fff0ef          	jal	ra,4b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 788:	0992                	slli	s3,s3,0x4
 78a:	397d                	addiw	s2,s2,-1
 78c:	fe0916e3          	bnez	s2,778 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 790:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 794:	4981                	li	s3,0
 796:	bd05                	j	5c6 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 798:	008b8913          	addi	s2,s7,8
 79c:	000bc583          	lbu	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	d11ff0ef          	jal	ra,4b2 <putc>
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bd31                	j	5c6 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7ac:	008b8993          	addi	s3,s7,8
 7b0:	000bb903          	ld	s2,0(s7)
 7b4:	00090f63          	beqz	s2,7d2 <vprintf+0x266>
        for(; *s; s++)
 7b8:	00094583          	lbu	a1,0(s2)
 7bc:	c195                	beqz	a1,7e0 <vprintf+0x274>
          putc(fd, *s);
 7be:	855a                	mv	a0,s6
 7c0:	cf3ff0ef          	jal	ra,4b2 <putc>
        for(; *s; s++)
 7c4:	0905                	addi	s2,s2,1
 7c6:	00094583          	lbu	a1,0(s2)
 7ca:	f9f5                	bnez	a1,7be <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7cc:	8bce                	mv	s7,s3
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	bbdd                	j	5c6 <vprintf+0x5a>
          s = "(null)";
 7d2:	00000917          	auipc	s2,0x0
 7d6:	2e690913          	addi	s2,s2,742 # ab8 <malloc+0x1d0>
        for(; *s; s++)
 7da:	02800593          	li	a1,40
 7de:	b7c5                	j	7be <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7e0:	8bce                	mv	s7,s3
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	b3cd                	j	5c6 <vprintf+0x5a>
    }
  }
}
 7e6:	70e6                	ld	ra,120(sp)
 7e8:	7446                	ld	s0,112(sp)
 7ea:	74a6                	ld	s1,104(sp)
 7ec:	7906                	ld	s2,96(sp)
 7ee:	69e6                	ld	s3,88(sp)
 7f0:	6a46                	ld	s4,80(sp)
 7f2:	6aa6                	ld	s5,72(sp)
 7f4:	6b06                	ld	s6,64(sp)
 7f6:	7be2                	ld	s7,56(sp)
 7f8:	7c42                	ld	s8,48(sp)
 7fa:	7ca2                	ld	s9,40(sp)
 7fc:	7d02                	ld	s10,32(sp)
 7fe:	6de2                	ld	s11,24(sp)
 800:	6109                	addi	sp,sp,128
 802:	8082                	ret

0000000000000804 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 804:	715d                	addi	sp,sp,-80
 806:	ec06                	sd	ra,24(sp)
 808:	e822                	sd	s0,16(sp)
 80a:	1000                	addi	s0,sp,32
 80c:	e010                	sd	a2,0(s0)
 80e:	e414                	sd	a3,8(s0)
 810:	e818                	sd	a4,16(s0)
 812:	ec1c                	sd	a5,24(s0)
 814:	03043023          	sd	a6,32(s0)
 818:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 81c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 820:	8622                	mv	a2,s0
 822:	d4bff0ef          	jal	ra,56c <vprintf>
}
 826:	60e2                	ld	ra,24(sp)
 828:	6442                	ld	s0,16(sp)
 82a:	6161                	addi	sp,sp,80
 82c:	8082                	ret

000000000000082e <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 82e:	711d                	addi	sp,sp,-96
 830:	ec06                	sd	ra,24(sp)
 832:	e822                	sd	s0,16(sp)
 834:	1000                	addi	s0,sp,32
 836:	e40c                	sd	a1,8(s0)
 838:	e810                	sd	a2,16(s0)
 83a:	ec14                	sd	a3,24(s0)
 83c:	f018                	sd	a4,32(s0)
 83e:	f41c                	sd	a5,40(s0)
 840:	03043823          	sd	a6,48(s0)
 844:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 848:	00840613          	addi	a2,s0,8
 84c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 850:	85aa                	mv	a1,a0
 852:	4505                	li	a0,1
 854:	d19ff0ef          	jal	ra,56c <vprintf>
}
 858:	60e2                	ld	ra,24(sp)
 85a:	6442                	ld	s0,16(sp)
 85c:	6125                	addi	sp,sp,96
 85e:	8082                	ret

0000000000000860 <free>:
 *   无
 */

void
free(void *ap)
{
 860:	1141                	addi	sp,sp,-16
 862:	e422                	sd	s0,8(sp)
 864:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 866:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86a:	00000797          	auipc	a5,0x0
 86e:	7967b783          	ld	a5,1942(a5) # 1000 <freep>
 872:	a805                	j	8a2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 874:	4618                	lw	a4,8(a2)
 876:	9db9                	addw	a1,a1,a4
 878:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87c:	6398                	ld	a4,0(a5)
 87e:	6318                	ld	a4,0(a4)
 880:	fee53823          	sd	a4,-16(a0)
 884:	a091                	j	8c8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 886:	ff852703          	lw	a4,-8(a0)
 88a:	9e39                	addw	a2,a2,a4
 88c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 88e:	ff053703          	ld	a4,-16(a0)
 892:	e398                	sd	a4,0(a5)
 894:	a099                	j	8da <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 896:	6398                	ld	a4,0(a5)
 898:	00e7e463          	bltu	a5,a4,8a0 <free+0x40>
 89c:	00e6ea63          	bltu	a3,a4,8b0 <free+0x50>
{
 8a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a2:	fed7fae3          	bgeu	a5,a3,896 <free+0x36>
 8a6:	6398                	ld	a4,0(a5)
 8a8:	00e6e463          	bltu	a3,a4,8b0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ac:	fee7eae3          	bltu	a5,a4,8a0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8b0:	ff852583          	lw	a1,-8(a0)
 8b4:	6390                	ld	a2,0(a5)
 8b6:	02059713          	slli	a4,a1,0x20
 8ba:	9301                	srli	a4,a4,0x20
 8bc:	0712                	slli	a4,a4,0x4
 8be:	9736                	add	a4,a4,a3
 8c0:	fae60ae3          	beq	a2,a4,874 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8c4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c8:	4790                	lw	a2,8(a5)
 8ca:	02061713          	slli	a4,a2,0x20
 8ce:	9301                	srli	a4,a4,0x20
 8d0:	0712                	slli	a4,a4,0x4
 8d2:	973e                	add	a4,a4,a5
 8d4:	fae689e3          	beq	a3,a4,886 <free+0x26>
  } else
    p->s.ptr = bp;
 8d8:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 8da:	00000717          	auipc	a4,0x0
 8de:	72f73323          	sd	a5,1830(a4) # 1000 <freep>
}
 8e2:	6422                	ld	s0,8(sp)
 8e4:	0141                	addi	sp,sp,16
 8e6:	8082                	ret

00000000000008e8 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 8e8:	7139                	addi	sp,sp,-64
 8ea:	fc06                	sd	ra,56(sp)
 8ec:	f822                	sd	s0,48(sp)
 8ee:	f426                	sd	s1,40(sp)
 8f0:	f04a                	sd	s2,32(sp)
 8f2:	ec4e                	sd	s3,24(sp)
 8f4:	e852                	sd	s4,16(sp)
 8f6:	e456                	sd	s5,8(sp)
 8f8:	e05a                	sd	s6,0(sp)
 8fa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8fc:	02051493          	slli	s1,a0,0x20
 900:	9081                	srli	s1,s1,0x20
 902:	04bd                	addi	s1,s1,15
 904:	8091                	srli	s1,s1,0x4
 906:	0014899b          	addiw	s3,s1,1
 90a:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 90c:	00000517          	auipc	a0,0x0
 910:	6f453503          	ld	a0,1780(a0) # 1000 <freep>
 914:	c515                	beqz	a0,940 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 916:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 918:	4798                	lw	a4,8(a5)
 91a:	02977f63          	bgeu	a4,s1,958 <malloc+0x70>
 91e:	8a4e                	mv	s4,s3
 920:	0009871b          	sext.w	a4,s3
 924:	6685                	lui	a3,0x1
 926:	00d77363          	bgeu	a4,a3,92c <malloc+0x44>
 92a:	6a05                	lui	s4,0x1
 92c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 930:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 934:	00000917          	auipc	s2,0x0
 938:	6cc90913          	addi	s2,s2,1740 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 93c:	5afd                	li	s5,-1
 93e:	a0bd                	j	9ac <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 940:	00000797          	auipc	a5,0x0
 944:	6d078793          	addi	a5,a5,1744 # 1010 <base>
 948:	00000717          	auipc	a4,0x0
 94c:	6af73c23          	sd	a5,1720(a4) # 1000 <freep>
 950:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 952:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 956:	b7e1                	j	91e <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 958:	02e48b63          	beq	s1,a4,98e <malloc+0xa6>
        p->s.size -= nunits;
 95c:	4137073b          	subw	a4,a4,s3
 960:	c798                	sw	a4,8(a5)
        p += p->s.size;
 962:	1702                	slli	a4,a4,0x20
 964:	9301                	srli	a4,a4,0x20
 966:	0712                	slli	a4,a4,0x4
 968:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 96a:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 96e:	00000717          	auipc	a4,0x0
 972:	68a73923          	sd	a0,1682(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 976:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 97a:	70e2                	ld	ra,56(sp)
 97c:	7442                	ld	s0,48(sp)
 97e:	74a2                	ld	s1,40(sp)
 980:	7902                	ld	s2,32(sp)
 982:	69e2                	ld	s3,24(sp)
 984:	6a42                	ld	s4,16(sp)
 986:	6aa2                	ld	s5,8(sp)
 988:	6b02                	ld	s6,0(sp)
 98a:	6121                	addi	sp,sp,64
 98c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 98e:	6398                	ld	a4,0(a5)
 990:	e118                	sd	a4,0(a0)
 992:	bff1                	j	96e <malloc+0x86>
  hp->s.size = nu;
 994:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 998:	0541                	addi	a0,a0,16
 99a:	ec7ff0ef          	jal	ra,860 <free>
  return freep;
 99e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a2:	dd61                	beqz	a0,97a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 9a6:	4798                	lw	a4,8(a5)
 9a8:	fa9778e3          	bgeu	a4,s1,958 <malloc+0x70>
    if(p == freep)
 9ac:	00093703          	ld	a4,0(s2)
 9b0:	853e                	mv	a0,a5
 9b2:	fef719e3          	bne	a4,a5,9a4 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 9b6:	8552                	mv	a0,s4
 9b8:	9e7ff0ef          	jal	ra,39e <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 9bc:	fd551ce3          	bne	a0,s5,994 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 9c0:	4501                	li	a0,0
 9c2:	bf65                	j	97a <malloc+0x92>
