
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
  48:	98450513          	addi	a0,a0,-1660 # 9c8 <malloc+0x108>
  4c:	7c0000ef          	jal	ra,80c <printf>
    sleep(50);
  50:	03200513          	li	a0,50
  54:	434000ef          	jal	ra,488 <sleep>
    printf("child still sees %d\n", c[0]);
  58:	0004c583          	lbu	a1,0(s1)
  5c:	00001517          	auipc	a0,0x1
  60:	97c50513          	addi	a0,a0,-1668 # 9d8 <malloc+0x118>
  64:	7a8000ef          	jal	ra,80c <printf>
    munmap(c, 4096);
  68:	6585                	lui	a1,0x1
  6a:	8526                	mv	a0,s1
  6c:	40c000ef          	jal	ra,478 <munmap>
    exit(0);
  70:	4501                	li	a0,0
  72:	35e000ef          	jal	ra,3d0 <exit>
  if(p == (char*)-1){ printf("mmap1 fail\n"); exit(1); }
  76:	00001517          	auipc	a0,0x1
  7a:	92a50513          	addi	a0,a0,-1750 # 9a0 <malloc+0xe0>
  7e:	78e000ef          	jal	ra,80c <printf>
  82:	4505                	li	a0,1
  84:	34c000ef          	jal	ra,3d0 <exit>
    if(c == (char*)-1){ printf("child mmap fail\n"); exit(1); }
  88:	00001517          	auipc	a0,0x1
  8c:	92850513          	addi	a0,a0,-1752 # 9b0 <malloc+0xf0>
  90:	77c000ef          	jal	ra,80c <printf>
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
  ae:	94650513          	addi	a0,a0,-1722 # 9f0 <malloc+0x130>
  b2:	75a000ef          	jal	ra,80c <printf>

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
  ce:	93e50513          	addi	a0,a0,-1730 # a08 <malloc+0x148>
  d2:	73a000ef          	jal	ra,80c <printf>
    exit(1);
  d6:	4505                	li	a0,1
  d8:	2f8000ef          	jal	ra,3d0 <exit>
  } else {
    printf("OK: mmap after rmid rejected\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	95450513          	addi	a0,a0,-1708 # a30 <malloc+0x170>
  e4:	728000ef          	jal	ra,80c <printf>
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
 114:	95850513          	addi	a0,a0,-1704 # a68 <malloc+0x1a8>
 118:	6f4000ef          	jal	ra,80c <printf>
  munmap(r, 4096);
 11c:	6585                	lui	a1,0x1
 11e:	8526                	mv	a0,s1
 120:	358000ef          	jal	ra,478 <munmap>

  exit(0);
 124:	4501                	li	a0,0
 126:	2aa000ef          	jal	ra,3d0 <exit>
  if(r == (char*)-1){ printf("mmap after free fail\n"); exit(1); }
 12a:	00001517          	auipc	a0,0x1
 12e:	92650513          	addi	a0,a0,-1754 # a50 <malloc+0x190>
 132:	6da000ef          	jal	ra,80c <printf>
 136:	4505                	li	a0,1
 138:	298000ef          	jal	ra,3d0 <exit>

000000000000013c <start>:
// wrapper so that it's OK if main() does not call exit().
//

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
}

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

0000000000000490 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 490:	1101                	addi	sp,sp,-32
 492:	ec06                	sd	ra,24(sp)
 494:	e822                	sd	s0,16(sp)
 496:	1000                	addi	s0,sp,32
 498:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49c:	4605                	li	a2,1
 49e:	fef40593          	addi	a1,s0,-17
 4a2:	f4fff0ef          	jal	ra,3f0 <write>
}
 4a6:	60e2                	ld	ra,24(sp)
 4a8:	6442                	ld	s0,16(sp)
 4aa:	6105                	addi	sp,sp,32
 4ac:	8082                	ret

00000000000004ae <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ae:	715d                	addi	sp,sp,-80
 4b0:	e486                	sd	ra,72(sp)
 4b2:	e0a2                	sd	s0,64(sp)
 4b4:	fc26                	sd	s1,56(sp)
 4b6:	f84a                	sd	s2,48(sp)
 4b8:	f44e                	sd	s3,40(sp)
 4ba:	0880                	addi	s0,sp,80
 4bc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4be:	c299                	beqz	a3,4c4 <printint+0x16>
 4c0:	0805c163          	bltz	a1,542 <printint+0x94>
  neg = 0;
 4c4:	4881                	li	a7,0
 4c6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ca:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4cc:	00000517          	auipc	a0,0x0
 4d0:	5c450513          	addi	a0,a0,1476 # a90 <digits>
 4d4:	883e                	mv	a6,a5
 4d6:	2785                	addiw	a5,a5,1
 4d8:	02c5f733          	remu	a4,a1,a2
 4dc:	972a                	add	a4,a4,a0
 4de:	00074703          	lbu	a4,0(a4)
 4e2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4e6:	872e                	mv	a4,a1
 4e8:	02c5d5b3          	divu	a1,a1,a2
 4ec:	0685                	addi	a3,a3,1
 4ee:	fec773e3          	bgeu	a4,a2,4d4 <printint+0x26>
  if(neg)
 4f2:	00088b63          	beqz	a7,508 <printint+0x5a>
    buf[i++] = '-';
 4f6:	fd078793          	addi	a5,a5,-48
 4fa:	97a2                	add	a5,a5,s0
 4fc:	02d00713          	li	a4,45
 500:	fee78423          	sb	a4,-24(a5)
 504:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 508:	02f05663          	blez	a5,534 <printint+0x86>
 50c:	fb840713          	addi	a4,s0,-72
 510:	00f704b3          	add	s1,a4,a5
 514:	fff70993          	addi	s3,a4,-1
 518:	99be                	add	s3,s3,a5
 51a:	37fd                	addiw	a5,a5,-1
 51c:	1782                	slli	a5,a5,0x20
 51e:	9381                	srli	a5,a5,0x20
 520:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 524:	fff4c583          	lbu	a1,-1(s1)
 528:	854a                	mv	a0,s2
 52a:	f67ff0ef          	jal	ra,490 <putc>
  while(--i >= 0)
 52e:	14fd                	addi	s1,s1,-1
 530:	ff349ae3          	bne	s1,s3,524 <printint+0x76>
}
 534:	60a6                	ld	ra,72(sp)
 536:	6406                	ld	s0,64(sp)
 538:	74e2                	ld	s1,56(sp)
 53a:	7942                	ld	s2,48(sp)
 53c:	79a2                	ld	s3,40(sp)
 53e:	6161                	addi	sp,sp,80
 540:	8082                	ret
    x = -xx;
 542:	40b005b3          	neg	a1,a1
    neg = 1;
 546:	4885                	li	a7,1
    x = -xx;
 548:	bfbd                	j	4c6 <printint+0x18>

000000000000054a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54a:	7119                	addi	sp,sp,-128
 54c:	fc86                	sd	ra,120(sp)
 54e:	f8a2                	sd	s0,112(sp)
 550:	f4a6                	sd	s1,104(sp)
 552:	f0ca                	sd	s2,96(sp)
 554:	ecce                	sd	s3,88(sp)
 556:	e8d2                	sd	s4,80(sp)
 558:	e4d6                	sd	s5,72(sp)
 55a:	e0da                	sd	s6,64(sp)
 55c:	fc5e                	sd	s7,56(sp)
 55e:	f862                	sd	s8,48(sp)
 560:	f466                	sd	s9,40(sp)
 562:	f06a                	sd	s10,32(sp)
 564:	ec6e                	sd	s11,24(sp)
 566:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 568:	0005c903          	lbu	s2,0(a1)
 56c:	24090c63          	beqz	s2,7c4 <vprintf+0x27a>
 570:	8b2a                	mv	s6,a0
 572:	8a2e                	mv	s4,a1
 574:	8bb2                	mv	s7,a2
  state = 0;
 576:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 578:	4481                	li	s1,0
 57a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 57c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 580:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 584:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 588:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58c:	00000c97          	auipc	s9,0x0
 590:	504c8c93          	addi	s9,s9,1284 # a90 <digits>
 594:	a005                	j	5b4 <vprintf+0x6a>
        putc(fd, c0);
 596:	85ca                	mv	a1,s2
 598:	855a                	mv	a0,s6
 59a:	ef7ff0ef          	jal	ra,490 <putc>
 59e:	a019                	j	5a4 <vprintf+0x5a>
    } else if(state == '%'){
 5a0:	03598263          	beq	s3,s5,5c4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5a4:	2485                	addiw	s1,s1,1
 5a6:	8726                	mv	a4,s1
 5a8:	009a07b3          	add	a5,s4,s1
 5ac:	0007c903          	lbu	s2,0(a5)
 5b0:	20090a63          	beqz	s2,7c4 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5b4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b8:	fe0994e3          	bnez	s3,5a0 <vprintf+0x56>
      if(c0 == '%'){
 5bc:	fd579de3          	bne	a5,s5,596 <vprintf+0x4c>
        state = '%';
 5c0:	89be                	mv	s3,a5
 5c2:	b7cd                	j	5a4 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5c4:	c3c1                	beqz	a5,644 <vprintf+0xfa>
 5c6:	00ea06b3          	add	a3,s4,a4
 5ca:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5ce:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5d0:	c681                	beqz	a3,5d8 <vprintf+0x8e>
 5d2:	9752                	add	a4,a4,s4
 5d4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5d8:	03878e63          	beq	a5,s8,614 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5dc:	05a78863          	beq	a5,s10,62c <vprintf+0xe2>
      } else if(c0 == 'u'){
 5e0:	0db78b63          	beq	a5,s11,6b6 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5e4:	07800713          	li	a4,120
 5e8:	10e78d63          	beq	a5,a4,702 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ec:	07000713          	li	a4,112
 5f0:	14e78263          	beq	a5,a4,734 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5f4:	06300713          	li	a4,99
 5f8:	16e78f63          	beq	a5,a4,776 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5fc:	07300713          	li	a4,115
 600:	18e78563          	beq	a5,a4,78a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 604:	05579063          	bne	a5,s5,644 <vprintf+0xfa>
        putc(fd, '%');
 608:	85d6                	mv	a1,s5
 60a:	855a                	mv	a0,s6
 60c:	e85ff0ef          	jal	ra,490 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 610:	4981                	li	s3,0
 612:	bf49                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 614:	008b8913          	addi	s2,s7,8
 618:	4685                	li	a3,1
 61a:	4629                	li	a2,10
 61c:	000ba583          	lw	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	e8dff0ef          	jal	ra,4ae <printint>
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	bfad                	j	5a4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 62c:	03868663          	beq	a3,s8,658 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 630:	05a68163          	beq	a3,s10,672 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 634:	09b68d63          	beq	a3,s11,6ce <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 638:	03a68f63          	beq	a3,s10,676 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 63c:	07800793          	li	a5,120
 640:	0cf68d63          	beq	a3,a5,71a <vprintf+0x1d0>
        putc(fd, '%');
 644:	85d6                	mv	a1,s5
 646:	855a                	mv	a0,s6
 648:	e49ff0ef          	jal	ra,490 <putc>
        putc(fd, c0);
 64c:	85ca                	mv	a1,s2
 64e:	855a                	mv	a0,s6
 650:	e41ff0ef          	jal	ra,490 <putc>
      state = 0;
 654:	4981                	li	s3,0
 656:	b7b9                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 658:	008b8913          	addi	s2,s7,8
 65c:	4685                	li	a3,1
 65e:	4629                	li	a2,10
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	e49ff0ef          	jal	ra,4ae <printint>
        i += 1;
 66a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
        i += 1;
 670:	bf15                	j	5a4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 672:	03860563          	beq	a2,s8,69c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 676:	07b60963          	beq	a2,s11,6e8 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 67a:	07800793          	li	a5,120
 67e:	fcf613e3          	bne	a2,a5,644 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 682:	008b8913          	addi	s2,s7,8
 686:	4681                	li	a3,0
 688:	4641                	li	a2,16
 68a:	000bb583          	ld	a1,0(s7)
 68e:	855a                	mv	a0,s6
 690:	e1fff0ef          	jal	ra,4ae <printint>
        i += 2;
 694:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
        i += 2;
 69a:	b729                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 69c:	008b8913          	addi	s2,s7,8
 6a0:	4685                	li	a3,1
 6a2:	4629                	li	a2,10
 6a4:	000bb583          	ld	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	e05ff0ef          	jal	ra,4ae <printint>
        i += 2;
 6ae:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
        i += 2;
 6b4:	bdc5                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4629                	li	a2,10
 6be:	000be583          	lwu	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	debff0ef          	jal	ra,4ae <printint>
 6c8:	8bca                	mv	s7,s2
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	bde1                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ce:	008b8913          	addi	s2,s7,8
 6d2:	4681                	li	a3,0
 6d4:	4629                	li	a2,10
 6d6:	000bb583          	ld	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	dd3ff0ef          	jal	ra,4ae <printint>
        i += 1;
 6e0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e2:	8bca                	mv	s7,s2
      state = 0;
 6e4:	4981                	li	s3,0
        i += 1;
 6e6:	bd7d                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e8:	008b8913          	addi	s2,s7,8
 6ec:	4681                	li	a3,0
 6ee:	4629                	li	a2,10
 6f0:	000bb583          	ld	a1,0(s7)
 6f4:	855a                	mv	a0,s6
 6f6:	db9ff0ef          	jal	ra,4ae <printint>
        i += 2;
 6fa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
        i += 2;
 700:	b555                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 702:	008b8913          	addi	s2,s7,8
 706:	4681                	li	a3,0
 708:	4641                	li	a2,16
 70a:	000be583          	lwu	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	d9fff0ef          	jal	ra,4ae <printint>
 714:	8bca                	mv	s7,s2
      state = 0;
 716:	4981                	li	s3,0
 718:	b571                	j	5a4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 71a:	008b8913          	addi	s2,s7,8
 71e:	4681                	li	a3,0
 720:	4641                	li	a2,16
 722:	000bb583          	ld	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	d87ff0ef          	jal	ra,4ae <printint>
        i += 1;
 72c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 72e:	8bca                	mv	s7,s2
      state = 0;
 730:	4981                	li	s3,0
        i += 1;
 732:	bd8d                	j	5a4 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 734:	008b8793          	addi	a5,s7,8
 738:	f8f43423          	sd	a5,-120(s0)
 73c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 740:	03000593          	li	a1,48
 744:	855a                	mv	a0,s6
 746:	d4bff0ef          	jal	ra,490 <putc>
  putc(fd, 'x');
 74a:	07800593          	li	a1,120
 74e:	855a                	mv	a0,s6
 750:	d41ff0ef          	jal	ra,490 <putc>
 754:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 756:	03c9d793          	srli	a5,s3,0x3c
 75a:	97e6                	add	a5,a5,s9
 75c:	0007c583          	lbu	a1,0(a5)
 760:	855a                	mv	a0,s6
 762:	d2fff0ef          	jal	ra,490 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 766:	0992                	slli	s3,s3,0x4
 768:	397d                	addiw	s2,s2,-1
 76a:	fe0916e3          	bnez	s2,756 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 76e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 772:	4981                	li	s3,0
 774:	bd05                	j	5a4 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 776:	008b8913          	addi	s2,s7,8
 77a:	000bc583          	lbu	a1,0(s7)
 77e:	855a                	mv	a0,s6
 780:	d11ff0ef          	jal	ra,490 <putc>
 784:	8bca                	mv	s7,s2
      state = 0;
 786:	4981                	li	s3,0
 788:	bd31                	j	5a4 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 78a:	008b8993          	addi	s3,s7,8
 78e:	000bb903          	ld	s2,0(s7)
 792:	00090f63          	beqz	s2,7b0 <vprintf+0x266>
        for(; *s; s++)
 796:	00094583          	lbu	a1,0(s2)
 79a:	c195                	beqz	a1,7be <vprintf+0x274>
          putc(fd, *s);
 79c:	855a                	mv	a0,s6
 79e:	cf3ff0ef          	jal	ra,490 <putc>
        for(; *s; s++)
 7a2:	0905                	addi	s2,s2,1
 7a4:	00094583          	lbu	a1,0(s2)
 7a8:	f9f5                	bnez	a1,79c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7aa:	8bce                	mv	s7,s3
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	bbdd                	j	5a4 <vprintf+0x5a>
          s = "(null)";
 7b0:	00000917          	auipc	s2,0x0
 7b4:	2d890913          	addi	s2,s2,728 # a88 <malloc+0x1c8>
        for(; *s; s++)
 7b8:	02800593          	li	a1,40
 7bc:	b7c5                	j	79c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7be:	8bce                	mv	s7,s3
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b3cd                	j	5a4 <vprintf+0x5a>
    }
  }
}
 7c4:	70e6                	ld	ra,120(sp)
 7c6:	7446                	ld	s0,112(sp)
 7c8:	74a6                	ld	s1,104(sp)
 7ca:	7906                	ld	s2,96(sp)
 7cc:	69e6                	ld	s3,88(sp)
 7ce:	6a46                	ld	s4,80(sp)
 7d0:	6aa6                	ld	s5,72(sp)
 7d2:	6b06                	ld	s6,64(sp)
 7d4:	7be2                	ld	s7,56(sp)
 7d6:	7c42                	ld	s8,48(sp)
 7d8:	7ca2                	ld	s9,40(sp)
 7da:	7d02                	ld	s10,32(sp)
 7dc:	6de2                	ld	s11,24(sp)
 7de:	6109                	addi	sp,sp,128
 7e0:	8082                	ret

00000000000007e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e2:	715d                	addi	sp,sp,-80
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e010                	sd	a2,0(s0)
 7ec:	e414                	sd	a3,8(s0)
 7ee:	e818                	sd	a4,16(s0)
 7f0:	ec1c                	sd	a5,24(s0)
 7f2:	03043023          	sd	a6,32(s0)
 7f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7fe:	8622                	mv	a2,s0
 800:	d4bff0ef          	jal	ra,54a <vprintf>
}
 804:	60e2                	ld	ra,24(sp)
 806:	6442                	ld	s0,16(sp)
 808:	6161                	addi	sp,sp,80
 80a:	8082                	ret

000000000000080c <printf>:

void
printf(const char *fmt, ...)
{
 80c:	711d                	addi	sp,sp,-96
 80e:	ec06                	sd	ra,24(sp)
 810:	e822                	sd	s0,16(sp)
 812:	1000                	addi	s0,sp,32
 814:	e40c                	sd	a1,8(s0)
 816:	e810                	sd	a2,16(s0)
 818:	ec14                	sd	a3,24(s0)
 81a:	f018                	sd	a4,32(s0)
 81c:	f41c                	sd	a5,40(s0)
 81e:	03043823          	sd	a6,48(s0)
 822:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 826:	00840613          	addi	a2,s0,8
 82a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 82e:	85aa                	mv	a1,a0
 830:	4505                	li	a0,1
 832:	d19ff0ef          	jal	ra,54a <vprintf>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6125                	addi	sp,sp,96
 83c:	8082                	ret

000000000000083e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83e:	1141                	addi	sp,sp,-16
 840:	e422                	sd	s0,8(sp)
 842:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 844:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	00000797          	auipc	a5,0x0
 84c:	7b87b783          	ld	a5,1976(a5) # 1000 <freep>
 850:	a02d                	j	87a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 852:	4618                	lw	a4,8(a2)
 854:	9f2d                	addw	a4,a4,a1
 856:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 85a:	6398                	ld	a4,0(a5)
 85c:	6310                	ld	a2,0(a4)
 85e:	a83d                	j	89c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 860:	ff852703          	lw	a4,-8(a0)
 864:	9f31                	addw	a4,a4,a2
 866:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 868:	ff053683          	ld	a3,-16(a0)
 86c:	a091                	j	8b0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	6398                	ld	a4,0(a5)
 870:	00e7e463          	bltu	a5,a4,878 <free+0x3a>
 874:	00e6ea63          	bltu	a3,a4,888 <free+0x4a>
{
 878:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87a:	fed7fae3          	bgeu	a5,a3,86e <free+0x30>
 87e:	6398                	ld	a4,0(a5)
 880:	00e6e463          	bltu	a3,a4,888 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 884:	fee7eae3          	bltu	a5,a4,878 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 888:	ff852583          	lw	a1,-8(a0)
 88c:	6390                	ld	a2,0(a5)
 88e:	02059813          	slli	a6,a1,0x20
 892:	01c85713          	srli	a4,a6,0x1c
 896:	9736                	add	a4,a4,a3
 898:	fae60de3          	beq	a2,a4,852 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 89c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a0:	4790                	lw	a2,8(a5)
 8a2:	02061593          	slli	a1,a2,0x20
 8a6:	01c5d713          	srli	a4,a1,0x1c
 8aa:	973e                	add	a4,a4,a5
 8ac:	fae68ae3          	beq	a3,a4,860 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8b0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b2:	00000717          	auipc	a4,0x0
 8b6:	74f73723          	sd	a5,1870(a4) # 1000 <freep>
}
 8ba:	6422                	ld	s0,8(sp)
 8bc:	0141                	addi	sp,sp,16
 8be:	8082                	ret

00000000000008c0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c0:	7139                	addi	sp,sp,-64
 8c2:	fc06                	sd	ra,56(sp)
 8c4:	f822                	sd	s0,48(sp)
 8c6:	f426                	sd	s1,40(sp)
 8c8:	f04a                	sd	s2,32(sp)
 8ca:	ec4e                	sd	s3,24(sp)
 8cc:	e852                	sd	s4,16(sp)
 8ce:	e456                	sd	s5,8(sp)
 8d0:	e05a                	sd	s6,0(sp)
 8d2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d4:	02051493          	slli	s1,a0,0x20
 8d8:	9081                	srli	s1,s1,0x20
 8da:	04bd                	addi	s1,s1,15
 8dc:	8091                	srli	s1,s1,0x4
 8de:	0014899b          	addiw	s3,s1,1
 8e2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e4:	00000517          	auipc	a0,0x0
 8e8:	71c53503          	ld	a0,1820(a0) # 1000 <freep>
 8ec:	c515                	beqz	a0,918 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f0:	4798                	lw	a4,8(a5)
 8f2:	02977f63          	bgeu	a4,s1,930 <malloc+0x70>
 8f6:	8a4e                	mv	s4,s3
 8f8:	0009871b          	sext.w	a4,s3
 8fc:	6685                	lui	a3,0x1
 8fe:	00d77363          	bgeu	a4,a3,904 <malloc+0x44>
 902:	6a05                	lui	s4,0x1
 904:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 908:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90c:	00000917          	auipc	s2,0x0
 910:	6f490913          	addi	s2,s2,1780 # 1000 <freep>
  if(p == SBRK_ERROR)
 914:	5afd                	li	s5,-1
 916:	a885                	j	986 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 918:	00000797          	auipc	a5,0x0
 91c:	6f878793          	addi	a5,a5,1784 # 1010 <base>
 920:	00000717          	auipc	a4,0x0
 924:	6ef73023          	sd	a5,1760(a4) # 1000 <freep>
 928:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92e:	b7e1                	j	8f6 <malloc+0x36>
      if(p->s.size == nunits)
 930:	02e48c63          	beq	s1,a4,968 <malloc+0xa8>
        p->s.size -= nunits;
 934:	4137073b          	subw	a4,a4,s3
 938:	c798                	sw	a4,8(a5)
        p += p->s.size;
 93a:	02071693          	slli	a3,a4,0x20
 93e:	01c6d713          	srli	a4,a3,0x1c
 942:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 944:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 948:	00000717          	auipc	a4,0x0
 94c:	6aa73c23          	sd	a0,1720(a4) # 1000 <freep>
      return (void*)(p + 1);
 950:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 954:	70e2                	ld	ra,56(sp)
 956:	7442                	ld	s0,48(sp)
 958:	74a2                	ld	s1,40(sp)
 95a:	7902                	ld	s2,32(sp)
 95c:	69e2                	ld	s3,24(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	6121                	addi	sp,sp,64
 966:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 968:	6398                	ld	a4,0(a5)
 96a:	e118                	sd	a4,0(a0)
 96c:	bff1                	j	948 <malloc+0x88>
  hp->s.size = nu;
 96e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 972:	0541                	addi	a0,a0,16
 974:	ecbff0ef          	jal	ra,83e <free>
  return freep;
 978:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 97c:	dd61                	beqz	a0,954 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 980:	4798                	lw	a4,8(a5)
 982:	fa9777e3          	bgeu	a4,s1,930 <malloc+0x70>
    if(p == freep)
 986:	00093703          	ld	a4,0(s2)
 98a:	853e                	mv	a0,a5
 98c:	fef719e3          	bne	a4,a5,97e <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 990:	8552                	mv	a0,s4
 992:	a0bff0ef          	jal	ra,39c <sbrk>
  if(p == SBRK_ERROR)
 996:	fd551ce3          	bne	a0,s5,96e <malloc+0xae>
        return 0;
 99a:	4501                	li	a0,0
 99c:	bf65                	j	954 <malloc+0x94>
