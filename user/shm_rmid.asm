
user/_shm_rmid：     文件格式 elf64-littleriscv


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
  14:	45c000ef          	jal	ra,470 <mmap>
  if(p == (char*)-1){ printf("mmap1 fail\n"); exit(1); }
  18:	57fd                	li	a5,-1
  1a:	04f50e63          	beq	a0,a5,76 <main+0x76>
  1e:	84aa                	mv	s1,a0
  p[0] = 7;
  20:	479d                	li	a5,7
  22:	00f50023          	sb	a5,0(a0)

  int pid = fork();
  26:	3a2000ef          	jal	ra,3c8 <fork>
  if(pid == 0){
  2a:	e925                	bnez	a0,9a <main+0x9a>
    char *c = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  2c:	4705                	li	a4,1
  2e:	468d                	li	a3,3
  30:	460d                	li	a2,3
  32:	6585                	lui	a1,0x1
  34:	43c000ef          	jal	ra,470 <mmap>
  38:	84aa                	mv	s1,a0
    if(c == (char*)-1){ printf("child mmap fail\n"); exit(1); }
  3a:	57fd                	li	a5,-1
  3c:	04f50663          	beq	a0,a5,88 <main+0x88>
    printf("child sees %d\n", c[0]);
  40:	00054583          	lbu	a1,0(a0)
  44:	00001517          	auipc	a0,0x1
  48:	9a450513          	addi	a0,a0,-1628 # 9e8 <malloc+0x108>
  4c:	7e0000ef          	jal	ra,82c <printf>
    sleep(50);
  50:	03200513          	li	a0,50
  54:	434000ef          	jal	ra,488 <sleep>
    printf("child still sees %d\n", c[0]);
  58:	0004c583          	lbu	a1,0(s1)
  5c:	00001517          	auipc	a0,0x1
  60:	99c50513          	addi	a0,a0,-1636 # 9f8 <malloc+0x118>
  64:	7c8000ef          	jal	ra,82c <printf>
    munmap(c, 4096);
  68:	6585                	lui	a1,0x1
  6a:	8526                	mv	a0,s1
  6c:	40c000ef          	jal	ra,478 <munmap>
    exit(0);
  70:	4501                	li	a0,0
  72:	35e000ef          	jal	ra,3d0 <exit>
  if(p == (char*)-1){ printf("mmap1 fail\n"); exit(1); }
  76:	00001517          	auipc	a0,0x1
  7a:	94a50513          	addi	a0,a0,-1718 # 9c0 <malloc+0xe0>
  7e:	7ae000ef          	jal	ra,82c <printf>
  82:	4505                	li	a0,1
  84:	34c000ef          	jal	ra,3d0 <exit>
    if(c == (char*)-1){ printf("child mmap fail\n"); exit(1); }
  88:	00001517          	auipc	a0,0x1
  8c:	94850513          	addi	a0,a0,-1720 # 9d0 <malloc+0xf0>
  90:	79c000ef          	jal	ra,82c <printf>
  94:	4505                	li	a0,1
  96:	33a000ef          	jal	ra,3d0 <exit>
  }

  sleep(20);
  9a:	4551                	li	a0,20
  9c:	3ec000ef          	jal	ra,488 <sleep>
  printf("parent rmid: %d\n", shmctl(key, IPC_RMID));
  a0:	4581                	li	a1,0
  a2:	4505                	li	a0,1
  a4:	3dc000ef          	jal	ra,480 <shmctl>
  a8:	85aa                	mv	a1,a0
  aa:	00001517          	auipc	a0,0x1
  ae:	96650513          	addi	a0,a0,-1690 # a10 <malloc+0x130>
  b2:	77a000ef          	jal	ra,82c <printf>

  // deleted 后不允许新的 attach
  char *q = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  b6:	4705                	li	a4,1
  b8:	468d                	li	a3,3
  ba:	460d                	li	a2,3
  bc:	6585                	lui	a1,0x1
  be:	4501                	li	a0,0
  c0:	3b0000ef          	jal	ra,470 <mmap>
  if(q != (char*)-1){
  c4:	57fd                	li	a5,-1
  c6:	00f50b63          	beq	a0,a5,dc <main+0xdc>
    printf("FAIL: mmap after rmid should fail\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	95e50513          	addi	a0,a0,-1698 # a28 <malloc+0x148>
  d2:	75a000ef          	jal	ra,82c <printf>
    exit(1);
  d6:	4505                	li	a0,1
  d8:	2f8000ef          	jal	ra,3d0 <exit>
  } else {
    printf("OK: mmap after rmid rejected\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	97450513          	addi	a0,a0,-1676 # a50 <malloc+0x170>
  e4:	748000ef          	jal	ra,82c <printf>
  }

  wait(0);
  e8:	4501                	li	a0,0
  ea:	2ee000ef          	jal	ra,3d8 <wait>
  munmap(p, 4096);
  ee:	6585                	lui	a1,0x1
  f0:	8526                	mv	a0,s1
  f2:	386000ef          	jal	ra,478 <munmap>

  // 现在对象应已真正释放；再 mmap 应得到新对象（默认内容 0）
  char *r = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  f6:	4705                	li	a4,1
  f8:	468d                	li	a3,3
  fa:	460d                	li	a2,3
  fc:	6585                	lui	a1,0x1
  fe:	4501                	li	a0,0
 100:	370000ef          	jal	ra,470 <mmap>
 104:	84aa                	mv	s1,a0
  if(r == (char*)-1){ printf("mmap after free fail\n"); exit(1); }
 106:	57fd                	li	a5,-1
 108:	02f50163          	beq	a0,a5,12a <main+0x12a>
  printf("new object r[0]=%d (expect 0)\n", r[0]);
 10c:	00054583          	lbu	a1,0(a0)
 110:	00001517          	auipc	a0,0x1
 114:	97850513          	addi	a0,a0,-1672 # a88 <malloc+0x1a8>
 118:	714000ef          	jal	ra,82c <printf>
  munmap(r, 4096);
 11c:	6585                	lui	a1,0x1
 11e:	8526                	mv	a0,s1
 120:	358000ef          	jal	ra,478 <munmap>

  exit(0);
 124:	4501                	li	a0,0
 126:	2aa000ef          	jal	ra,3d0 <exit>
  if(r == (char*)-1){ printf("mmap after free fail\n"); exit(1); }
 12a:	00001517          	auipc	a0,0x1
 12e:	94650513          	addi	a0,a0,-1722 # a70 <malloc+0x190>
 132:	6fa000ef          	jal	ra,82c <printf>
 136:	4505                	li	a0,1
 138:	298000ef          	jal	ra,3d0 <exit>

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
 148:	288000ef          	jal	ra,3d0 <exit>

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
 154:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
 156:	0785                	addi	a5,a5,1
 158:	fff5c703          	lbu	a4,-1(a1)
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
 236:	1b2000ef          	jal	ra,3e8 <read>
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
 284:	18c000ef          	jal	ra,410 <open>
  if(fd < 0)
 288:	02054163          	bltz	a0,2aa <stat+0x36>
 28c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 28e:	85ca                	mv	a1,s2
 290:	198000ef          	jal	ra,428 <fstat>
 294:	892a                	mv	s2,a0
  close(fd);
 296:	8526                	mv	a0,s1
 298:	160000ef          	jal	ra,3f8 <close>
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
 2b4:	00054683          	lbu	a3,0(a0)
 2b8:	fd06879b          	addiw	a5,a3,-48
 2bc:	0ff7f793          	zext.b	a5,a5
 2c0:	4625                	li	a2,9
 2c2:	02f66863          	bltu	a2,a5,2f2 <atoi+0x44>
 2c6:	872a                	mv	a4,a0
  n = 0;
 2c8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ca:	0705                	addi	a4,a4,1
 2cc:	0025179b          	slliw	a5,a0,0x2
 2d0:	9fa9                	addw	a5,a5,a0
 2d2:	0017979b          	slliw	a5,a5,0x1
 2d6:	9fb5                	addw	a5,a5,a3
 2d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2dc:	00074683          	lbu	a3,0(a4)
 2e0:	fd06879b          	addiw	a5,a3,-48
 2e4:	0ff7f793          	zext.b	a5,a5
 2e8:	fef671e3          	bgeu	a2,a5,2ca <atoi+0x1c>
  return n;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  n = 0;
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <atoi+0x3e>

00000000000002f6 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fc:	02b57463          	bgeu	a0,a1,324 <memmove+0x2e>
    while(n-- > 0)
 300:	00c05f63          	blez	a2,31e <memmove+0x28>
 304:	1602                	slli	a2,a2,0x20
 306:	9201                	srli	a2,a2,0x20
 308:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30c:	872a                	mv	a4,a0
      *dst++ = *src++;
 30e:	0585                	addi	a1,a1,1
 310:	0705                	addi	a4,a4,1
 312:	fff5c683          	lbu	a3,-1(a1)
 316:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 31a:	fee79ae3          	bne	a5,a4,30e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
    dst += n;
 324:	00c50733          	add	a4,a0,a2
    src += n;
 328:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 32a:	fec05ae3          	blez	a2,31e <memmove+0x28>
 32e:	fff6079b          	addiw	a5,a2,-1
 332:	1782                	slli	a5,a5,0x20
 334:	9381                	srli	a5,a5,0x20
 336:	fff7c793          	not	a5,a5
 33a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33c:	15fd                	addi	a1,a1,-1
 33e:	177d                	addi	a4,a4,-1
 340:	0005c683          	lbu	a3,0(a1)
 344:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 348:	fee79ae3          	bne	a5,a4,33c <memmove+0x46>
 34c:	bfc9                	j	31e <memmove+0x28>

000000000000034e <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e422                	sd	s0,8(sp)
 352:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 354:	ca05                	beqz	a2,384 <memcmp+0x36>
 356:	fff6069b          	addiw	a3,a2,-1
 35a:	1682                	slli	a3,a3,0x20
 35c:	9281                	srli	a3,a3,0x20
 35e:	0685                	addi	a3,a3,1
 360:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 362:	00054783          	lbu	a5,0(a0)
 366:	0005c703          	lbu	a4,0(a1)
 36a:	00e79863          	bne	a5,a4,37a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36e:	0505                	addi	a0,a0,1
    p2++;
 370:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 372:	fed518e3          	bne	a0,a3,362 <memcmp+0x14>
  }
  return 0;
 376:	4501                	li	a0,0
 378:	a019                	j	37e <memcmp+0x30>
      return *p1 - *p2;
 37a:	40e7853b          	subw	a0,a5,a4
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
  return 0;
 384:	4501                	li	a0,0
 386:	bfe5                	j	37e <memcmp+0x30>

0000000000000388 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e406                	sd	ra,8(sp)
 38c:	e022                	sd	s0,0(sp)
 38e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 390:	f67ff0ef          	jal	ra,2f6 <memmove>
}
 394:	60a2                	ld	ra,8(sp)
 396:	6402                	ld	s0,0(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret

000000000000039c <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3a4:	4585                	li	a1,1
 3a6:	0b2000ef          	jal	ra,458 <sys_sbrk>
}
 3aa:	60a2                	ld	ra,8(sp)
 3ac:	6402                	ld	s0,0(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret

00000000000003b2 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e406                	sd	ra,8(sp)
 3b6:	e022                	sd	s0,0(sp)
 3b8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3ba:	4589                	li	a1,2
 3bc:	09c000ef          	jal	ra,458 <sys_sbrk>
}
 3c0:	60a2                	ld	ra,8(sp)
 3c2:	6402                	ld	s0,0(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret

00000000000003c8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c8:	4885                	li	a7,1
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d0:	4889                	li	a7,2
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d8:	488d                	li	a7,3
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e0:	4891                	li	a7,4
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <read>:
.global read
read:
 li a7, SYS_read
 3e8:	4895                	li	a7,5
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <write>:
.global write
write:
 li a7, SYS_write
 3f0:	48c1                	li	a7,16
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <close>:
.global close
close:
 li a7, SYS_close
 3f8:	48d5                	li	a7,21
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <kill>:
.global kill
kill:
 li a7, SYS_kill
 400:	4899                	li	a7,6
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <exec>:
.global exec
exec:
 li a7, SYS_exec
 408:	489d                	li	a7,7
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <open>:
.global open
open:
 li a7, SYS_open
 410:	48bd                	li	a7,15
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 418:	48c5                	li	a7,17
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 420:	48c9                	li	a7,18
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 428:	48a1                	li	a7,8
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <link>:
.global link
link:
 li a7, SYS_link
 430:	48cd                	li	a7,19
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 438:	48d1                	li	a7,20
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 440:	48a5                	li	a7,9
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <dup>:
.global dup
dup:
 li a7, SYS_dup
 448:	48a9                	li	a7,10
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 450:	48ad                	li	a7,11
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 458:	48b1                	li	a7,12
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <pause>:
.global pause
pause:
 li a7, SYS_pause
 460:	48b5                	li	a7,13
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 468:	48b9                	li	a7,14
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 470:	48d9                	li	a7,22
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 478:	48dd                	li	a7,23
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 480:	48e1                	li	a7,24
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 488:	48e5                	li	a7,25
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 490:	48e9                	li	a7,26
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 498:	48ed                	li	a7,27
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 4a0:	48f1                	li	a7,28
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 4a8:	48f5                	li	a7,29
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 4b0:	1101                	addi	sp,sp,-32
 4b2:	ec06                	sd	ra,24(sp)
 4b4:	e822                	sd	s0,16(sp)
 4b6:	1000                	addi	s0,sp,32
 4b8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4bc:	4605                	li	a2,1
 4be:	fef40593          	addi	a1,s0,-17
 4c2:	f2fff0ef          	jal	ra,3f0 <write>
}
 4c6:	60e2                	ld	ra,24(sp)
 4c8:	6442                	ld	s0,16(sp)
 4ca:	6105                	addi	sp,sp,32
 4cc:	8082                	ret

00000000000004ce <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ce:	715d                	addi	sp,sp,-80
 4d0:	e486                	sd	ra,72(sp)
 4d2:	e0a2                	sd	s0,64(sp)
 4d4:	fc26                	sd	s1,56(sp)
 4d6:	f84a                	sd	s2,48(sp)
 4d8:	f44e                	sd	s3,40(sp)
 4da:	0880                	addi	s0,sp,80
 4dc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4de:	c299                	beqz	a3,4e4 <printint+0x16>
 4e0:	0805c163          	bltz	a1,562 <printint+0x94>
  neg = 0;
 4e4:	4881                	li	a7,0
 4e6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ea:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ec:	00000517          	auipc	a0,0x0
 4f0:	5c450513          	addi	a0,a0,1476 # ab0 <digits>
 4f4:	883e                	mv	a6,a5
 4f6:	2785                	addiw	a5,a5,1
 4f8:	02c5f733          	remu	a4,a1,a2
 4fc:	972a                	add	a4,a4,a0
 4fe:	00074703          	lbu	a4,0(a4)
 502:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 506:	872e                	mv	a4,a1
 508:	02c5d5b3          	divu	a1,a1,a2
 50c:	0685                	addi	a3,a3,1
 50e:	fec773e3          	bgeu	a4,a2,4f4 <printint+0x26>
  if(neg)
 512:	00088b63          	beqz	a7,528 <printint+0x5a>
    buf[i++] = '-';
 516:	fd078793          	addi	a5,a5,-48
 51a:	97a2                	add	a5,a5,s0
 51c:	02d00713          	li	a4,45
 520:	fee78423          	sb	a4,-24(a5)
 524:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 528:	02f05663          	blez	a5,554 <printint+0x86>
 52c:	fb840713          	addi	a4,s0,-72
 530:	00f704b3          	add	s1,a4,a5
 534:	fff70993          	addi	s3,a4,-1
 538:	99be                	add	s3,s3,a5
 53a:	37fd                	addiw	a5,a5,-1
 53c:	1782                	slli	a5,a5,0x20
 53e:	9381                	srli	a5,a5,0x20
 540:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 544:	fff4c583          	lbu	a1,-1(s1)
 548:	854a                	mv	a0,s2
 54a:	f67ff0ef          	jal	ra,4b0 <putc>
  while(--i >= 0)
 54e:	14fd                	addi	s1,s1,-1
 550:	ff349ae3          	bne	s1,s3,544 <printint+0x76>
}
 554:	60a6                	ld	ra,72(sp)
 556:	6406                	ld	s0,64(sp)
 558:	74e2                	ld	s1,56(sp)
 55a:	7942                	ld	s2,48(sp)
 55c:	79a2                	ld	s3,40(sp)
 55e:	6161                	addi	sp,sp,80
 560:	8082                	ret
    x = -xx;
 562:	40b005b3          	neg	a1,a1
    neg = 1;
 566:	4885                	li	a7,1
    x = -xx;
 568:	bfbd                	j	4e6 <printint+0x18>

000000000000056a <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 56a:	7119                	addi	sp,sp,-128
 56c:	fc86                	sd	ra,120(sp)
 56e:	f8a2                	sd	s0,112(sp)
 570:	f4a6                	sd	s1,104(sp)
 572:	f0ca                	sd	s2,96(sp)
 574:	ecce                	sd	s3,88(sp)
 576:	e8d2                	sd	s4,80(sp)
 578:	e4d6                	sd	s5,72(sp)
 57a:	e0da                	sd	s6,64(sp)
 57c:	fc5e                	sd	s7,56(sp)
 57e:	f862                	sd	s8,48(sp)
 580:	f466                	sd	s9,40(sp)
 582:	f06a                	sd	s10,32(sp)
 584:	ec6e                	sd	s11,24(sp)
 586:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 588:	0005c903          	lbu	s2,0(a1)
 58c:	24090c63          	beqz	s2,7e4 <vprintf+0x27a>
 590:	8b2a                	mv	s6,a0
 592:	8a2e                	mv	s4,a1
 594:	8bb2                	mv	s7,a2
  state = 0;
 596:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 598:	4481                	li	s1,0
 59a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 59c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5a0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5a4:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5a8:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ac:	00000c97          	auipc	s9,0x0
 5b0:	504c8c93          	addi	s9,s9,1284 # ab0 <digits>
 5b4:	a005                	j	5d4 <vprintf+0x6a>
        putc(fd, c0);
 5b6:	85ca                	mv	a1,s2
 5b8:	855a                	mv	a0,s6
 5ba:	ef7ff0ef          	jal	ra,4b0 <putc>
 5be:	a019                	j	5c4 <vprintf+0x5a>
    } else if(state == '%'){
 5c0:	03598263          	beq	s3,s5,5e4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5c4:	2485                	addiw	s1,s1,1
 5c6:	8726                	mv	a4,s1
 5c8:	009a07b3          	add	a5,s4,s1
 5cc:	0007c903          	lbu	s2,0(a5)
 5d0:	20090a63          	beqz	s2,7e4 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5d4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5d8:	fe0994e3          	bnez	s3,5c0 <vprintf+0x56>
      if(c0 == '%'){
 5dc:	fd579de3          	bne	a5,s5,5b6 <vprintf+0x4c>
        state = '%';
 5e0:	89be                	mv	s3,a5
 5e2:	b7cd                	j	5c4 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5e4:	c3c1                	beqz	a5,664 <vprintf+0xfa>
 5e6:	00ea06b3          	add	a3,s4,a4
 5ea:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5ee:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5f0:	c681                	beqz	a3,5f8 <vprintf+0x8e>
 5f2:	9752                	add	a4,a4,s4
 5f4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5f8:	03878e63          	beq	a5,s8,634 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5fc:	05a78863          	beq	a5,s10,64c <vprintf+0xe2>
      } else if(c0 == 'u'){
 600:	0db78b63          	beq	a5,s11,6d6 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 604:	07800713          	li	a4,120
 608:	10e78d63          	beq	a5,a4,722 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 60c:	07000713          	li	a4,112
 610:	14e78263          	beq	a5,a4,754 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 614:	06300713          	li	a4,99
 618:	16e78f63          	beq	a5,a4,796 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 61c:	07300713          	li	a4,115
 620:	18e78563          	beq	a5,a4,7aa <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 624:	05579063          	bne	a5,s5,664 <vprintf+0xfa>
        putc(fd, '%');
 628:	85d6                	mv	a1,s5
 62a:	855a                	mv	a0,s6
 62c:	e85ff0ef          	jal	ra,4b0 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 630:	4981                	li	s3,0
 632:	bf49                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 634:	008b8913          	addi	s2,s7,8
 638:	4685                	li	a3,1
 63a:	4629                	li	a2,10
 63c:	000ba583          	lw	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	e8dff0ef          	jal	ra,4ce <printint>
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	bfad                	j	5c4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 64c:	03868663          	beq	a3,s8,678 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 650:	05a68163          	beq	a3,s10,692 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 654:	09b68d63          	beq	a3,s11,6ee <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 658:	03a68f63          	beq	a3,s10,696 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 65c:	07800793          	li	a5,120
 660:	0cf68d63          	beq	a3,a5,73a <vprintf+0x1d0>
        putc(fd, '%');
 664:	85d6                	mv	a1,s5
 666:	855a                	mv	a0,s6
 668:	e49ff0ef          	jal	ra,4b0 <putc>
        putc(fd, c0);
 66c:	85ca                	mv	a1,s2
 66e:	855a                	mv	a0,s6
 670:	e41ff0ef          	jal	ra,4b0 <putc>
      state = 0;
 674:	4981                	li	s3,0
 676:	b7b9                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 678:	008b8913          	addi	s2,s7,8
 67c:	4685                	li	a3,1
 67e:	4629                	li	a2,10
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e49ff0ef          	jal	ra,4ce <printint>
        i += 1;
 68a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 1;
 690:	bf15                	j	5c4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 692:	03860563          	beq	a2,s8,6bc <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 696:	07b60963          	beq	a2,s11,708 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 69a:	07800793          	li	a5,120
 69e:	fcf613e3          	bne	a2,a5,664 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a2:	008b8913          	addi	s2,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4641                	li	a2,16
 6aa:	000bb583          	ld	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	e1fff0ef          	jal	ra,4ce <printint>
        i += 2;
 6b4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
        i += 2;
 6ba:	b729                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4685                	li	a3,1
 6c2:	4629                	li	a2,10
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	e05ff0ef          	jal	ra,4ce <printint>
        i += 2;
 6ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 2;
 6d4:	bdc5                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6d6:	008b8913          	addi	s2,s7,8
 6da:	4681                	li	a3,0
 6dc:	4629                	li	a2,10
 6de:	000be583          	lwu	a1,0(s7)
 6e2:	855a                	mv	a0,s6
 6e4:	debff0ef          	jal	ra,4ce <printint>
 6e8:	8bca                	mv	s7,s2
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bde1                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ee:	008b8913          	addi	s2,s7,8
 6f2:	4681                	li	a3,0
 6f4:	4629                	li	a2,10
 6f6:	000bb583          	ld	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	dd3ff0ef          	jal	ra,4ce <printint>
        i += 1;
 700:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
        i += 1;
 706:	bd7d                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 708:	008b8913          	addi	s2,s7,8
 70c:	4681                	li	a3,0
 70e:	4629                	li	a2,10
 710:	000bb583          	ld	a1,0(s7)
 714:	855a                	mv	a0,s6
 716:	db9ff0ef          	jal	ra,4ce <printint>
        i += 2;
 71a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
        i += 2;
 720:	b555                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 722:	008b8913          	addi	s2,s7,8
 726:	4681                	li	a3,0
 728:	4641                	li	a2,16
 72a:	000be583          	lwu	a1,0(s7)
 72e:	855a                	mv	a0,s6
 730:	d9fff0ef          	jal	ra,4ce <printint>
 734:	8bca                	mv	s7,s2
      state = 0;
 736:	4981                	li	s3,0
 738:	b571                	j	5c4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 73a:	008b8913          	addi	s2,s7,8
 73e:	4681                	li	a3,0
 740:	4641                	li	a2,16
 742:	000bb583          	ld	a1,0(s7)
 746:	855a                	mv	a0,s6
 748:	d87ff0ef          	jal	ra,4ce <printint>
        i += 1;
 74c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 74e:	8bca                	mv	s7,s2
      state = 0;
 750:	4981                	li	s3,0
        i += 1;
 752:	bd8d                	j	5c4 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 754:	008b8793          	addi	a5,s7,8
 758:	f8f43423          	sd	a5,-120(s0)
 75c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 760:	03000593          	li	a1,48
 764:	855a                	mv	a0,s6
 766:	d4bff0ef          	jal	ra,4b0 <putc>
  putc(fd, 'x');
 76a:	07800593          	li	a1,120
 76e:	855a                	mv	a0,s6
 770:	d41ff0ef          	jal	ra,4b0 <putc>
 774:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 776:	03c9d793          	srli	a5,s3,0x3c
 77a:	97e6                	add	a5,a5,s9
 77c:	0007c583          	lbu	a1,0(a5)
 780:	855a                	mv	a0,s6
 782:	d2fff0ef          	jal	ra,4b0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 786:	0992                	slli	s3,s3,0x4
 788:	397d                	addiw	s2,s2,-1
 78a:	fe0916e3          	bnez	s2,776 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 78e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 792:	4981                	li	s3,0
 794:	bd05                	j	5c4 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 796:	008b8913          	addi	s2,s7,8
 79a:	000bc583          	lbu	a1,0(s7)
 79e:	855a                	mv	a0,s6
 7a0:	d11ff0ef          	jal	ra,4b0 <putc>
 7a4:	8bca                	mv	s7,s2
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	bd31                	j	5c4 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7aa:	008b8993          	addi	s3,s7,8
 7ae:	000bb903          	ld	s2,0(s7)
 7b2:	00090f63          	beqz	s2,7d0 <vprintf+0x266>
        for(; *s; s++)
 7b6:	00094583          	lbu	a1,0(s2)
 7ba:	c195                	beqz	a1,7de <vprintf+0x274>
          putc(fd, *s);
 7bc:	855a                	mv	a0,s6
 7be:	cf3ff0ef          	jal	ra,4b0 <putc>
        for(; *s; s++)
 7c2:	0905                	addi	s2,s2,1
 7c4:	00094583          	lbu	a1,0(s2)
 7c8:	f9f5                	bnez	a1,7bc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7ca:	8bce                	mv	s7,s3
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	bbdd                	j	5c4 <vprintf+0x5a>
          s = "(null)";
 7d0:	00000917          	auipc	s2,0x0
 7d4:	2d890913          	addi	s2,s2,728 # aa8 <malloc+0x1c8>
        for(; *s; s++)
 7d8:	02800593          	li	a1,40
 7dc:	b7c5                	j	7bc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7de:	8bce                	mv	s7,s3
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	b3cd                	j	5c4 <vprintf+0x5a>
    }
  }
}
 7e4:	70e6                	ld	ra,120(sp)
 7e6:	7446                	ld	s0,112(sp)
 7e8:	74a6                	ld	s1,104(sp)
 7ea:	7906                	ld	s2,96(sp)
 7ec:	69e6                	ld	s3,88(sp)
 7ee:	6a46                	ld	s4,80(sp)
 7f0:	6aa6                	ld	s5,72(sp)
 7f2:	6b06                	ld	s6,64(sp)
 7f4:	7be2                	ld	s7,56(sp)
 7f6:	7c42                	ld	s8,48(sp)
 7f8:	7ca2                	ld	s9,40(sp)
 7fa:	7d02                	ld	s10,32(sp)
 7fc:	6de2                	ld	s11,24(sp)
 7fe:	6109                	addi	sp,sp,128
 800:	8082                	ret

0000000000000802 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 802:	715d                	addi	sp,sp,-80
 804:	ec06                	sd	ra,24(sp)
 806:	e822                	sd	s0,16(sp)
 808:	1000                	addi	s0,sp,32
 80a:	e010                	sd	a2,0(s0)
 80c:	e414                	sd	a3,8(s0)
 80e:	e818                	sd	a4,16(s0)
 810:	ec1c                	sd	a5,24(s0)
 812:	03043023          	sd	a6,32(s0)
 816:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 81a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 81e:	8622                	mv	a2,s0
 820:	d4bff0ef          	jal	ra,56a <vprintf>
}
 824:	60e2                	ld	ra,24(sp)
 826:	6442                	ld	s0,16(sp)
 828:	6161                	addi	sp,sp,80
 82a:	8082                	ret

000000000000082c <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 82c:	711d                	addi	sp,sp,-96
 82e:	ec06                	sd	ra,24(sp)
 830:	e822                	sd	s0,16(sp)
 832:	1000                	addi	s0,sp,32
 834:	e40c                	sd	a1,8(s0)
 836:	e810                	sd	a2,16(s0)
 838:	ec14                	sd	a3,24(s0)
 83a:	f018                	sd	a4,32(s0)
 83c:	f41c                	sd	a5,40(s0)
 83e:	03043823          	sd	a6,48(s0)
 842:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 846:	00840613          	addi	a2,s0,8
 84a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84e:	85aa                	mv	a1,a0
 850:	4505                	li	a0,1
 852:	d19ff0ef          	jal	ra,56a <vprintf>
}
 856:	60e2                	ld	ra,24(sp)
 858:	6442                	ld	s0,16(sp)
 85a:	6125                	addi	sp,sp,96
 85c:	8082                	ret

000000000000085e <free>:
 *   无
 */

void
free(void *ap)
{
 85e:	1141                	addi	sp,sp,-16
 860:	e422                	sd	s0,8(sp)
 862:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 864:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	00000797          	auipc	a5,0x0
 86c:	7987b783          	ld	a5,1944(a5) # 1000 <freep>
 870:	a02d                	j	89a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 872:	4618                	lw	a4,8(a2)
 874:	9f2d                	addw	a4,a4,a1
 876:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87a:	6398                	ld	a4,0(a5)
 87c:	6310                	ld	a2,0(a4)
 87e:	a83d                	j	8bc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 880:	ff852703          	lw	a4,-8(a0)
 884:	9f31                	addw	a4,a4,a2
 886:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 888:	ff053683          	ld	a3,-16(a0)
 88c:	a091                	j	8d0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88e:	6398                	ld	a4,0(a5)
 890:	00e7e463          	bltu	a5,a4,898 <free+0x3a>
 894:	00e6ea63          	bltu	a3,a4,8a8 <free+0x4a>
{
 898:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89a:	fed7fae3          	bgeu	a5,a3,88e <free+0x30>
 89e:	6398                	ld	a4,0(a5)
 8a0:	00e6e463          	bltu	a3,a4,8a8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a4:	fee7eae3          	bltu	a5,a4,898 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8a8:	ff852583          	lw	a1,-8(a0)
 8ac:	6390                	ld	a2,0(a5)
 8ae:	02059813          	slli	a6,a1,0x20
 8b2:	01c85713          	srli	a4,a6,0x1c
 8b6:	9736                	add	a4,a4,a3
 8b8:	fae60de3          	beq	a2,a4,872 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8bc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c0:	4790                	lw	a2,8(a5)
 8c2:	02061593          	slli	a1,a2,0x20
 8c6:	01c5d713          	srli	a4,a1,0x1c
 8ca:	973e                	add	a4,a4,a5
 8cc:	fae68ae3          	beq	a3,a4,880 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  /* 更新空闲链表头指针 */
  freep = p;
 8d2:	00000717          	auipc	a4,0x0
 8d6:	72f73723          	sd	a5,1838(a4) # 1000 <freep>
}
 8da:	6422                	ld	s0,8(sp)
 8dc:	0141                	addi	sp,sp,16
 8de:	8082                	ret

00000000000008e0 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 8e0:	7139                	addi	sp,sp,-64
 8e2:	fc06                	sd	ra,56(sp)
 8e4:	f822                	sd	s0,48(sp)
 8e6:	f426                	sd	s1,40(sp)
 8e8:	f04a                	sd	s2,32(sp)
 8ea:	ec4e                	sd	s3,24(sp)
 8ec:	e852                	sd	s4,16(sp)
 8ee:	e456                	sd	s5,8(sp)
 8f0:	e05a                	sd	s6,0(sp)
 8f2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f4:	02051493          	slli	s1,a0,0x20
 8f8:	9081                	srli	s1,s1,0x20
 8fa:	04bd                	addi	s1,s1,15
 8fc:	8091                	srli	s1,s1,0x4
 8fe:	0014899b          	addiw	s3,s1,1
 902:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 904:	00000517          	auipc	a0,0x0
 908:	6fc53503          	ld	a0,1788(a0) # 1000 <freep>
 90c:	c515                	beqz	a0,938 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 910:	4798                	lw	a4,8(a5)
 912:	02977f63          	bgeu	a4,s1,950 <malloc+0x70>
 916:	8a4e                	mv	s4,s3
 918:	0009871b          	sext.w	a4,s3
 91c:	6685                	lui	a3,0x1
 91e:	00d77363          	bgeu	a4,a3,924 <malloc+0x44>
 922:	6a05                	lui	s4,0x1
 924:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 928:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 92c:	00000917          	auipc	s2,0x0
 930:	6d490913          	addi	s2,s2,1748 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 934:	5afd                	li	s5,-1
 936:	a885                	j	9a6 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 938:	00000797          	auipc	a5,0x0
 93c:	6d878793          	addi	a5,a5,1752 # 1010 <base>
 940:	00000717          	auipc	a4,0x0
 944:	6cf73023          	sd	a5,1728(a4) # 1000 <freep>
 948:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 94a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 94e:	b7e1                	j	916 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 950:	02e48c63          	beq	s1,a4,988 <malloc+0xa8>
        p->s.size -= nunits;
 954:	4137073b          	subw	a4,a4,s3
 958:	c798                	sw	a4,8(a5)
        p += p->s.size;
 95a:	02071693          	slli	a3,a4,0x20
 95e:	01c6d713          	srli	a4,a3,0x1c
 962:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 964:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 968:	00000717          	auipc	a4,0x0
 96c:	68a73c23          	sd	a0,1688(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 970:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 974:	70e2                	ld	ra,56(sp)
 976:	7442                	ld	s0,48(sp)
 978:	74a2                	ld	s1,40(sp)
 97a:	7902                	ld	s2,32(sp)
 97c:	69e2                	ld	s3,24(sp)
 97e:	6a42                	ld	s4,16(sp)
 980:	6aa2                	ld	s5,8(sp)
 982:	6b02                	ld	s6,0(sp)
 984:	6121                	addi	sp,sp,64
 986:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 988:	6398                	ld	a4,0(a5)
 98a:	e118                	sd	a4,0(a0)
 98c:	bff1                	j	968 <malloc+0x88>
  hp->s.size = nu;
 98e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 992:	0541                	addi	a0,a0,16
 994:	ecbff0ef          	jal	ra,85e <free>
  return freep;
 998:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 99c:	dd61                	beqz	a0,974 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 9a0:	4798                	lw	a4,8(a5)
 9a2:	fa9777e3          	bgeu	a4,s1,950 <malloc+0x70>
    if(p == freep)
 9a6:	00093703          	ld	a4,0(s2)
 9aa:	853e                	mv	a0,a5
 9ac:	fef719e3          	bne	a4,a5,99e <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 9b0:	8552                	mv	a0,s4
 9b2:	9ebff0ef          	jal	ra,39c <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 9b6:	fd551ce3          	bne	a0,s5,98e <malloc+0xae>
        return 0;  /* 内存分配失败 */
 9ba:	4501                	li	a0,0
 9bc:	bf65                	j	974 <malloc+0x94>
