
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
  48:	9a450513          	addi	a0,a0,-1628 # 9e8 <malloc+0x110>
  4c:	7d8000ef          	jal	ra,824 <printf>
    sleep(50);
  50:	03200513          	li	a0,50
  54:	434000ef          	jal	ra,488 <sleep>
    printf("child still sees %d\n", c[0]);
  58:	0004c583          	lbu	a1,0(s1)
  5c:	00001517          	auipc	a0,0x1
  60:	99c50513          	addi	a0,a0,-1636 # 9f8 <malloc+0x120>
  64:	7c0000ef          	jal	ra,824 <printf>
    munmap(c, 4096);
  68:	6585                	lui	a1,0x1
  6a:	8526                	mv	a0,s1
  6c:	40c000ef          	jal	ra,478 <munmap>
    exit(0);
  70:	4501                	li	a0,0
  72:	35e000ef          	jal	ra,3d0 <exit>
  if(p == (char*)-1){ printf("mmap1 fail\n"); exit(1); }
  76:	00001517          	auipc	a0,0x1
  7a:	94a50513          	addi	a0,a0,-1718 # 9c0 <malloc+0xe8>
  7e:	7a6000ef          	jal	ra,824 <printf>
  82:	4505                	li	a0,1
  84:	34c000ef          	jal	ra,3d0 <exit>
    if(c == (char*)-1){ printf("child mmap fail\n"); exit(1); }
  88:	00001517          	auipc	a0,0x1
  8c:	94850513          	addi	a0,a0,-1720 # 9d0 <malloc+0xf8>
  90:	794000ef          	jal	ra,824 <printf>
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
  ae:	96650513          	addi	a0,a0,-1690 # a10 <malloc+0x138>
  b2:	772000ef          	jal	ra,824 <printf>

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
  ce:	95e50513          	addi	a0,a0,-1698 # a28 <malloc+0x150>
  d2:	752000ef          	jal	ra,824 <printf>
    exit(1);
  d6:	4505                	li	a0,1
  d8:	2f8000ef          	jal	ra,3d0 <exit>
  } else {
    printf("OK: mmap after rmid rejected\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	97450513          	addi	a0,a0,-1676 # a50 <malloc+0x178>
  e4:	740000ef          	jal	ra,824 <printf>
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
 114:	97850513          	addi	a0,a0,-1672 # a88 <malloc+0x1b0>
 118:	70c000ef          	jal	ra,824 <printf>
  munmap(r, 4096);
 11c:	6585                	lui	a1,0x1
 11e:	8526                	mv	a0,s1
 120:	358000ef          	jal	ra,478 <munmap>

  exit(0);
 124:	4501                	li	a0,0
 126:	2aa000ef          	jal	ra,3d0 <exit>
  if(r == (char*)-1){ printf("mmap after free fail\n"); exit(1); }
 12a:	00001517          	auipc	a0,0x1
 12e:	94650513          	addi	a0,a0,-1722 # a70 <malloc+0x198>
 132:	6f2000ef          	jal	ra,824 <printf>
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

00000000000004a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a8:	1101                	addi	sp,sp,-32
 4aa:	ec06                	sd	ra,24(sp)
 4ac:	e822                	sd	s0,16(sp)
 4ae:	1000                	addi	s0,sp,32
 4b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b4:	4605                	li	a2,1
 4b6:	fef40593          	addi	a1,s0,-17
 4ba:	f37ff0ef          	jal	ra,3f0 <write>
}
 4be:	60e2                	ld	ra,24(sp)
 4c0:	6442                	ld	s0,16(sp)
 4c2:	6105                	addi	sp,sp,32
 4c4:	8082                	ret

00000000000004c6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4c6:	715d                	addi	sp,sp,-80
 4c8:	e486                	sd	ra,72(sp)
 4ca:	e0a2                	sd	s0,64(sp)
 4cc:	fc26                	sd	s1,56(sp)
 4ce:	f84a                	sd	s2,48(sp)
 4d0:	f44e                	sd	s3,40(sp)
 4d2:	0880                	addi	s0,sp,80
 4d4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4d6:	c299                	beqz	a3,4dc <printint+0x16>
 4d8:	0805c163          	bltz	a1,55a <printint+0x94>
  neg = 0;
 4dc:	4881                	li	a7,0
 4de:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4e2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4e4:	00000517          	auipc	a0,0x0
 4e8:	5cc50513          	addi	a0,a0,1484 # ab0 <digits>
 4ec:	883e                	mv	a6,a5
 4ee:	2785                	addiw	a5,a5,1
 4f0:	02c5f733          	remu	a4,a1,a2
 4f4:	972a                	add	a4,a4,a0
 4f6:	00074703          	lbu	a4,0(a4)
 4fa:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4fe:	872e                	mv	a4,a1
 500:	02c5d5b3          	divu	a1,a1,a2
 504:	0685                	addi	a3,a3,1
 506:	fec773e3          	bgeu	a4,a2,4ec <printint+0x26>
  if(neg)
 50a:	00088b63          	beqz	a7,520 <printint+0x5a>
    buf[i++] = '-';
 50e:	fd078793          	addi	a5,a5,-48
 512:	97a2                	add	a5,a5,s0
 514:	02d00713          	li	a4,45
 518:	fee78423          	sb	a4,-24(a5)
 51c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 520:	02f05663          	blez	a5,54c <printint+0x86>
 524:	fb840713          	addi	a4,s0,-72
 528:	00f704b3          	add	s1,a4,a5
 52c:	fff70993          	addi	s3,a4,-1
 530:	99be                	add	s3,s3,a5
 532:	37fd                	addiw	a5,a5,-1
 534:	1782                	slli	a5,a5,0x20
 536:	9381                	srli	a5,a5,0x20
 538:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 53c:	fff4c583          	lbu	a1,-1(s1)
 540:	854a                	mv	a0,s2
 542:	f67ff0ef          	jal	ra,4a8 <putc>
  while(--i >= 0)
 546:	14fd                	addi	s1,s1,-1
 548:	ff349ae3          	bne	s1,s3,53c <printint+0x76>
}
 54c:	60a6                	ld	ra,72(sp)
 54e:	6406                	ld	s0,64(sp)
 550:	74e2                	ld	s1,56(sp)
 552:	7942                	ld	s2,48(sp)
 554:	79a2                	ld	s3,40(sp)
 556:	6161                	addi	sp,sp,80
 558:	8082                	ret
    x = -xx;
 55a:	40b005b3          	neg	a1,a1
    neg = 1;
 55e:	4885                	li	a7,1
    x = -xx;
 560:	bfbd                	j	4de <printint+0x18>

0000000000000562 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 562:	7119                	addi	sp,sp,-128
 564:	fc86                	sd	ra,120(sp)
 566:	f8a2                	sd	s0,112(sp)
 568:	f4a6                	sd	s1,104(sp)
 56a:	f0ca                	sd	s2,96(sp)
 56c:	ecce                	sd	s3,88(sp)
 56e:	e8d2                	sd	s4,80(sp)
 570:	e4d6                	sd	s5,72(sp)
 572:	e0da                	sd	s6,64(sp)
 574:	fc5e                	sd	s7,56(sp)
 576:	f862                	sd	s8,48(sp)
 578:	f466                	sd	s9,40(sp)
 57a:	f06a                	sd	s10,32(sp)
 57c:	ec6e                	sd	s11,24(sp)
 57e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 580:	0005c903          	lbu	s2,0(a1)
 584:	24090c63          	beqz	s2,7dc <vprintf+0x27a>
 588:	8b2a                	mv	s6,a0
 58a:	8a2e                	mv	s4,a1
 58c:	8bb2                	mv	s7,a2
  state = 0;
 58e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 590:	4481                	li	s1,0
 592:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 594:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 598:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 59c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5a0:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a4:	00000c97          	auipc	s9,0x0
 5a8:	50cc8c93          	addi	s9,s9,1292 # ab0 <digits>
 5ac:	a005                	j	5cc <vprintf+0x6a>
        putc(fd, c0);
 5ae:	85ca                	mv	a1,s2
 5b0:	855a                	mv	a0,s6
 5b2:	ef7ff0ef          	jal	ra,4a8 <putc>
 5b6:	a019                	j	5bc <vprintf+0x5a>
    } else if(state == '%'){
 5b8:	03598263          	beq	s3,s5,5dc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5bc:	2485                	addiw	s1,s1,1
 5be:	8726                	mv	a4,s1
 5c0:	009a07b3          	add	a5,s4,s1
 5c4:	0007c903          	lbu	s2,0(a5)
 5c8:	20090a63          	beqz	s2,7dc <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5cc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5d0:	fe0994e3          	bnez	s3,5b8 <vprintf+0x56>
      if(c0 == '%'){
 5d4:	fd579de3          	bne	a5,s5,5ae <vprintf+0x4c>
        state = '%';
 5d8:	89be                	mv	s3,a5
 5da:	b7cd                	j	5bc <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5dc:	c3c1                	beqz	a5,65c <vprintf+0xfa>
 5de:	00ea06b3          	add	a3,s4,a4
 5e2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5e6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5e8:	c681                	beqz	a3,5f0 <vprintf+0x8e>
 5ea:	9752                	add	a4,a4,s4
 5ec:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5f0:	03878e63          	beq	a5,s8,62c <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5f4:	05a78863          	beq	a5,s10,644 <vprintf+0xe2>
      } else if(c0 == 'u'){
 5f8:	0db78b63          	beq	a5,s11,6ce <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5fc:	07800713          	li	a4,120
 600:	10e78d63          	beq	a5,a4,71a <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 604:	07000713          	li	a4,112
 608:	14e78263          	beq	a5,a4,74c <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 60c:	06300713          	li	a4,99
 610:	16e78f63          	beq	a5,a4,78e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 614:	07300713          	li	a4,115
 618:	18e78563          	beq	a5,a4,7a2 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 61c:	05579063          	bne	a5,s5,65c <vprintf+0xfa>
        putc(fd, '%');
 620:	85d6                	mv	a1,s5
 622:	855a                	mv	a0,s6
 624:	e85ff0ef          	jal	ra,4a8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 628:	4981                	li	s3,0
 62a:	bf49                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 62c:	008b8913          	addi	s2,s7,8
 630:	4685                	li	a3,1
 632:	4629                	li	a2,10
 634:	000ba583          	lw	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	e8dff0ef          	jal	ra,4c6 <printint>
 63e:	8bca                	mv	s7,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	bfad                	j	5bc <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 644:	03868663          	beq	a3,s8,670 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 648:	05a68163          	beq	a3,s10,68a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 64c:	09b68d63          	beq	a3,s11,6e6 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 650:	03a68f63          	beq	a3,s10,68e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 654:	07800793          	li	a5,120
 658:	0cf68d63          	beq	a3,a5,732 <vprintf+0x1d0>
        putc(fd, '%');
 65c:	85d6                	mv	a1,s5
 65e:	855a                	mv	a0,s6
 660:	e49ff0ef          	jal	ra,4a8 <putc>
        putc(fd, c0);
 664:	85ca                	mv	a1,s2
 666:	855a                	mv	a0,s6
 668:	e41ff0ef          	jal	ra,4a8 <putc>
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b7b9                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 670:	008b8913          	addi	s2,s7,8
 674:	4685                	li	a3,1
 676:	4629                	li	a2,10
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	e49ff0ef          	jal	ra,4c6 <printint>
        i += 1;
 682:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 1;
 688:	bf15                	j	5bc <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 68a:	03860563          	beq	a2,s8,6b4 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 68e:	07b60963          	beq	a2,s11,700 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 692:	07800793          	li	a5,120
 696:	fcf613e3          	bne	a2,a5,65c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 69a:	008b8913          	addi	s2,s7,8
 69e:	4681                	li	a3,0
 6a0:	4641                	li	a2,16
 6a2:	000bb583          	ld	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	e1fff0ef          	jal	ra,4c6 <printint>
        i += 2;
 6ac:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ae:	8bca                	mv	s7,s2
      state = 0;
 6b0:	4981                	li	s3,0
        i += 2;
 6b2:	b729                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	4685                	li	a3,1
 6ba:	4629                	li	a2,10
 6bc:	000bb583          	ld	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	e05ff0ef          	jal	ra,4c6 <printint>
        i += 2;
 6c6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c8:	8bca                	mv	s7,s2
      state = 0;
 6ca:	4981                	li	s3,0
        i += 2;
 6cc:	bdc5                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ce:	008b8913          	addi	s2,s7,8
 6d2:	4681                	li	a3,0
 6d4:	4629                	li	a2,10
 6d6:	000be583          	lwu	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	debff0ef          	jal	ra,4c6 <printint>
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bde1                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	4681                	li	a3,0
 6ec:	4629                	li	a2,10
 6ee:	000bb583          	ld	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	dd3ff0ef          	jal	ra,4c6 <printint>
        i += 1;
 6f8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fa:	8bca                	mv	s7,s2
      state = 0;
 6fc:	4981                	li	s3,0
        i += 1;
 6fe:	bd7d                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 700:	008b8913          	addi	s2,s7,8
 704:	4681                	li	a3,0
 706:	4629                	li	a2,10
 708:	000bb583          	ld	a1,0(s7)
 70c:	855a                	mv	a0,s6
 70e:	db9ff0ef          	jal	ra,4c6 <printint>
        i += 2;
 712:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 714:	8bca                	mv	s7,s2
      state = 0;
 716:	4981                	li	s3,0
        i += 2;
 718:	b555                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 71a:	008b8913          	addi	s2,s7,8
 71e:	4681                	li	a3,0
 720:	4641                	li	a2,16
 722:	000be583          	lwu	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	d9fff0ef          	jal	ra,4c6 <printint>
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
 730:	b571                	j	5bc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 732:	008b8913          	addi	s2,s7,8
 736:	4681                	li	a3,0
 738:	4641                	li	a2,16
 73a:	000bb583          	ld	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	d87ff0ef          	jal	ra,4c6 <printint>
        i += 1;
 744:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
        i += 1;
 74a:	bd8d                	j	5bc <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 74c:	008b8793          	addi	a5,s7,8
 750:	f8f43423          	sd	a5,-120(s0)
 754:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 758:	03000593          	li	a1,48
 75c:	855a                	mv	a0,s6
 75e:	d4bff0ef          	jal	ra,4a8 <putc>
  putc(fd, 'x');
 762:	07800593          	li	a1,120
 766:	855a                	mv	a0,s6
 768:	d41ff0ef          	jal	ra,4a8 <putc>
 76c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76e:	03c9d793          	srli	a5,s3,0x3c
 772:	97e6                	add	a5,a5,s9
 774:	0007c583          	lbu	a1,0(a5)
 778:	855a                	mv	a0,s6
 77a:	d2fff0ef          	jal	ra,4a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77e:	0992                	slli	s3,s3,0x4
 780:	397d                	addiw	s2,s2,-1
 782:	fe0916e3          	bnez	s2,76e <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 786:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 78a:	4981                	li	s3,0
 78c:	bd05                	j	5bc <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 78e:	008b8913          	addi	s2,s7,8
 792:	000bc583          	lbu	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	d11ff0ef          	jal	ra,4a8 <putc>
 79c:	8bca                	mv	s7,s2
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	bd31                	j	5bc <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7a2:	008b8993          	addi	s3,s7,8
 7a6:	000bb903          	ld	s2,0(s7)
 7aa:	00090f63          	beqz	s2,7c8 <vprintf+0x266>
        for(; *s; s++)
 7ae:	00094583          	lbu	a1,0(s2)
 7b2:	c195                	beqz	a1,7d6 <vprintf+0x274>
          putc(fd, *s);
 7b4:	855a                	mv	a0,s6
 7b6:	cf3ff0ef          	jal	ra,4a8 <putc>
        for(; *s; s++)
 7ba:	0905                	addi	s2,s2,1
 7bc:	00094583          	lbu	a1,0(s2)
 7c0:	f9f5                	bnez	a1,7b4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7c2:	8bce                	mv	s7,s3
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bbdd                	j	5bc <vprintf+0x5a>
          s = "(null)";
 7c8:	00000917          	auipc	s2,0x0
 7cc:	2e090913          	addi	s2,s2,736 # aa8 <malloc+0x1d0>
        for(; *s; s++)
 7d0:	02800593          	li	a1,40
 7d4:	b7c5                	j	7b4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7d6:	8bce                	mv	s7,s3
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	b3cd                	j	5bc <vprintf+0x5a>
    }
  }
}
 7dc:	70e6                	ld	ra,120(sp)
 7de:	7446                	ld	s0,112(sp)
 7e0:	74a6                	ld	s1,104(sp)
 7e2:	7906                	ld	s2,96(sp)
 7e4:	69e6                	ld	s3,88(sp)
 7e6:	6a46                	ld	s4,80(sp)
 7e8:	6aa6                	ld	s5,72(sp)
 7ea:	6b06                	ld	s6,64(sp)
 7ec:	7be2                	ld	s7,56(sp)
 7ee:	7c42                	ld	s8,48(sp)
 7f0:	7ca2                	ld	s9,40(sp)
 7f2:	7d02                	ld	s10,32(sp)
 7f4:	6de2                	ld	s11,24(sp)
 7f6:	6109                	addi	sp,sp,128
 7f8:	8082                	ret

00000000000007fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fa:	715d                	addi	sp,sp,-80
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	e010                	sd	a2,0(s0)
 804:	e414                	sd	a3,8(s0)
 806:	e818                	sd	a4,16(s0)
 808:	ec1c                	sd	a5,24(s0)
 80a:	03043023          	sd	a6,32(s0)
 80e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 812:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 816:	8622                	mv	a2,s0
 818:	d4bff0ef          	jal	ra,562 <vprintf>
}
 81c:	60e2                	ld	ra,24(sp)
 81e:	6442                	ld	s0,16(sp)
 820:	6161                	addi	sp,sp,80
 822:	8082                	ret

0000000000000824 <printf>:

void
printf(const char *fmt, ...)
{
 824:	711d                	addi	sp,sp,-96
 826:	ec06                	sd	ra,24(sp)
 828:	e822                	sd	s0,16(sp)
 82a:	1000                	addi	s0,sp,32
 82c:	e40c                	sd	a1,8(s0)
 82e:	e810                	sd	a2,16(s0)
 830:	ec14                	sd	a3,24(s0)
 832:	f018                	sd	a4,32(s0)
 834:	f41c                	sd	a5,40(s0)
 836:	03043823          	sd	a6,48(s0)
 83a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 83e:	00840613          	addi	a2,s0,8
 842:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 846:	85aa                	mv	a1,a0
 848:	4505                	li	a0,1
 84a:	d19ff0ef          	jal	ra,562 <vprintf>
}
 84e:	60e2                	ld	ra,24(sp)
 850:	6442                	ld	s0,16(sp)
 852:	6125                	addi	sp,sp,96
 854:	8082                	ret

0000000000000856 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 856:	1141                	addi	sp,sp,-16
 858:	e422                	sd	s0,8(sp)
 85a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 860:	00000797          	auipc	a5,0x0
 864:	7a07b783          	ld	a5,1952(a5) # 1000 <freep>
 868:	a02d                	j	892 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 86a:	4618                	lw	a4,8(a2)
 86c:	9f2d                	addw	a4,a4,a1
 86e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	6398                	ld	a4,0(a5)
 874:	6310                	ld	a2,0(a4)
 876:	a83d                	j	8b4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 878:	ff852703          	lw	a4,-8(a0)
 87c:	9f31                	addw	a4,a4,a2
 87e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 880:	ff053683          	ld	a3,-16(a0)
 884:	a091                	j	8c8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 886:	6398                	ld	a4,0(a5)
 888:	00e7e463          	bltu	a5,a4,890 <free+0x3a>
 88c:	00e6ea63          	bltu	a3,a4,8a0 <free+0x4a>
{
 890:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 892:	fed7fae3          	bgeu	a5,a3,886 <free+0x30>
 896:	6398                	ld	a4,0(a5)
 898:	00e6e463          	bltu	a3,a4,8a0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89c:	fee7eae3          	bltu	a5,a4,890 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8a0:	ff852583          	lw	a1,-8(a0)
 8a4:	6390                	ld	a2,0(a5)
 8a6:	02059813          	slli	a6,a1,0x20
 8aa:	01c85713          	srli	a4,a6,0x1c
 8ae:	9736                	add	a4,a4,a3
 8b0:	fae60de3          	beq	a2,a4,86a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8b4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8b8:	4790                	lw	a2,8(a5)
 8ba:	02061593          	slli	a1,a2,0x20
 8be:	01c5d713          	srli	a4,a1,0x1c
 8c2:	973e                	add	a4,a4,a5
 8c4:	fae68ae3          	beq	a3,a4,878 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8c8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	72f73b23          	sd	a5,1846(a4) # 1000 <freep>
}
 8d2:	6422                	ld	s0,8(sp)
 8d4:	0141                	addi	sp,sp,16
 8d6:	8082                	ret

00000000000008d8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d8:	7139                	addi	sp,sp,-64
 8da:	fc06                	sd	ra,56(sp)
 8dc:	f822                	sd	s0,48(sp)
 8de:	f426                	sd	s1,40(sp)
 8e0:	f04a                	sd	s2,32(sp)
 8e2:	ec4e                	sd	s3,24(sp)
 8e4:	e852                	sd	s4,16(sp)
 8e6:	e456                	sd	s5,8(sp)
 8e8:	e05a                	sd	s6,0(sp)
 8ea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ec:	02051493          	slli	s1,a0,0x20
 8f0:	9081                	srli	s1,s1,0x20
 8f2:	04bd                	addi	s1,s1,15
 8f4:	8091                	srli	s1,s1,0x4
 8f6:	0014899b          	addiw	s3,s1,1
 8fa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8fc:	00000517          	auipc	a0,0x0
 900:	70453503          	ld	a0,1796(a0) # 1000 <freep>
 904:	c515                	beqz	a0,930 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 906:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 908:	4798                	lw	a4,8(a5)
 90a:	02977f63          	bgeu	a4,s1,948 <malloc+0x70>
 90e:	8a4e                	mv	s4,s3
 910:	0009871b          	sext.w	a4,s3
 914:	6685                	lui	a3,0x1
 916:	00d77363          	bgeu	a4,a3,91c <malloc+0x44>
 91a:	6a05                	lui	s4,0x1
 91c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 920:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 924:	00000917          	auipc	s2,0x0
 928:	6dc90913          	addi	s2,s2,1756 # 1000 <freep>
  if(p == SBRK_ERROR)
 92c:	5afd                	li	s5,-1
 92e:	a885                	j	99e <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 930:	00000797          	auipc	a5,0x0
 934:	6e078793          	addi	a5,a5,1760 # 1010 <base>
 938:	00000717          	auipc	a4,0x0
 93c:	6cf73423          	sd	a5,1736(a4) # 1000 <freep>
 940:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 942:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 946:	b7e1                	j	90e <malloc+0x36>
      if(p->s.size == nunits)
 948:	02e48c63          	beq	s1,a4,980 <malloc+0xa8>
        p->s.size -= nunits;
 94c:	4137073b          	subw	a4,a4,s3
 950:	c798                	sw	a4,8(a5)
        p += p->s.size;
 952:	02071693          	slli	a3,a4,0x20
 956:	01c6d713          	srli	a4,a3,0x1c
 95a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 95c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 960:	00000717          	auipc	a4,0x0
 964:	6aa73023          	sd	a0,1696(a4) # 1000 <freep>
      return (void*)(p + 1);
 968:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 96c:	70e2                	ld	ra,56(sp)
 96e:	7442                	ld	s0,48(sp)
 970:	74a2                	ld	s1,40(sp)
 972:	7902                	ld	s2,32(sp)
 974:	69e2                	ld	s3,24(sp)
 976:	6a42                	ld	s4,16(sp)
 978:	6aa2                	ld	s5,8(sp)
 97a:	6b02                	ld	s6,0(sp)
 97c:	6121                	addi	sp,sp,64
 97e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 980:	6398                	ld	a4,0(a5)
 982:	e118                	sd	a4,0(a0)
 984:	bff1                	j	960 <malloc+0x88>
  hp->s.size = nu;
 986:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 98a:	0541                	addi	a0,a0,16
 98c:	ecbff0ef          	jal	ra,856 <free>
  return freep;
 990:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 994:	dd61                	beqz	a0,96c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 996:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 998:	4798                	lw	a4,8(a5)
 99a:	fa9777e3          	bgeu	a4,s1,948 <malloc+0x70>
    if(p == freep)
 99e:	00093703          	ld	a4,0(s2)
 9a2:	853e                	mv	a0,a5
 9a4:	fef719e3          	bne	a4,a5,996 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 9a8:	8552                	mv	a0,s4
 9aa:	9f3ff0ef          	jal	ra,39c <sbrk>
  if(p == SBRK_ERROR)
 9ae:	fd551ce3          	bne	a0,s5,986 <malloc+0xae>
        return 0;
 9b2:	4501                	li	a0,0
 9b4:	bf65                	j	96c <malloc+0x94>
