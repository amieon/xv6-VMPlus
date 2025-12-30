
user/_shm_test1：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/types.h"
#include "../kernel/stat.h"
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
  14:	3cc000ef          	jal	ra,3e0 <mmap>
  if(p == (char*)-1){ printf("mmap fail\n"); exit(1); }
  18:	57fd                	li	a5,-1
  1a:	04f50563          	beq	a0,a5,64 <main+0x64>
  1e:	84aa                	mv	s1,a0

  int pid = fork();
  20:	318000ef          	jal	ra,338 <fork>
  if(pid == 0){
  24:	e929                	bnez	a0,76 <main+0x76>
  26:	009897b7          	lui	a5,0x989
  2a:	67f78793          	addi	a5,a5,1663 # 98967f <base+0x98866f>
    // child
    for(int i=1;i<10000000;++i)
  2e:	37fd                	addiw	a5,a5,-1
  30:	fffd                	bnez	a5,2e <main+0x2e>
        ;
    printf("child sees: %d\n", p[0]);
  32:	0004c583          	lbu	a1,0(s1)
  36:	00001517          	auipc	a0,0x1
  3a:	8da50513          	addi	a0,a0,-1830 # 910 <malloc+0xf0>
  3e:	72e000ef          	jal	ra,76c <printf>
    p[0] = 42;
  42:	02a00793          	li	a5,42
  46:	00f48023          	sb	a5,0(s1)
    printf("child wrote 42\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	8d650513          	addi	a0,a0,-1834 # 920 <malloc+0x100>
  52:	71a000ef          	jal	ra,76c <printf>
    munmap(p, 4096);
  56:	6585                	lui	a1,0x1
  58:	8526                	mv	a0,s1
  5a:	38e000ef          	jal	ra,3e8 <munmap>
    exit(0);
  5e:	4501                	li	a0,0
  60:	2e0000ef          	jal	ra,340 <exit>
  if(p == (char*)-1){ printf("mmap fail\n"); exit(1); }
  64:	00001517          	auipc	a0,0x1
  68:	89c50513          	addi	a0,a0,-1892 # 900 <malloc+0xe0>
  6c:	700000ef          	jal	ra,76c <printf>
  70:	4505                	li	a0,1
  72:	2ce000ef          	jal	ra,340 <exit>
  } else {
    // parent
    p[0] = 7;
  76:	479d                	li	a5,7
  78:	00f48023          	sb	a5,0(s1)
    printf("parent wrote 7\n");
  7c:	00001517          	auipc	a0,0x1
  80:	8b450513          	addi	a0,a0,-1868 # 930 <malloc+0x110>
  84:	6e8000ef          	jal	ra,76c <printf>
    wait(0);
  88:	4501                	li	a0,0
  8a:	2be000ef          	jal	ra,348 <wait>
    printf("parent sees after child: %d\n", p[0]);
  8e:	0004c583          	lbu	a1,0(s1)
  92:	00001517          	auipc	a0,0x1
  96:	8ae50513          	addi	a0,a0,-1874 # 940 <malloc+0x120>
  9a:	6d2000ef          	jal	ra,76c <printf>
    munmap(p, 4096);
  9e:	6585                	lui	a1,0x1
  a0:	8526                	mv	a0,s1
  a2:	346000ef          	jal	ra,3e8 <munmap>
    exit(0);
  a6:	4501                	li	a0,0
  a8:	298000ef          	jal	ra,340 <exit>

00000000000000ac <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e406                	sd	ra,8(sp)
  b0:	e022                	sd	s0,0(sp)
  b2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  b4:	f4dff0ef          	jal	ra,0 <main>
  exit(r);
  b8:	288000ef          	jal	ra,340 <exit>

00000000000000bc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c2:	87aa                	mv	a5,a0
  c4:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
  c6:	0785                	addi	a5,a5,1
  c8:	fff5c703          	lbu	a4,-1(a1)
  cc:	fee78fa3          	sb	a4,-1(a5)
  d0:	fb75                	bnez	a4,c4 <strcpy+0x8>
    ;
  return os;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb91                	beqz	a5,f6 <strcmp+0x1e>
  e4:	0005c703          	lbu	a4,0(a1)
  e8:	00f71763          	bne	a4,a5,f6 <strcmp+0x1e>
    p++, q++;
  ec:	0505                	addi	a0,a0,1
  ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	fbe5                	bnez	a5,e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f6:	0005c503          	lbu	a0,0(a1)
}
  fa:	40a7853b          	subw	a0,a5,a0
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strlen>:

uint
strlen(const char *s)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cf91                	beqz	a5,12a <strlen+0x26>
 110:	0505                	addi	a0,a0,1
 112:	87aa                	mv	a5,a0
 114:	4685                	li	a3,1
 116:	9e89                	subw	a3,a3,a0
 118:	00f6853b          	addw	a0,a3,a5
 11c:	0785                	addi	a5,a5,1
 11e:	fff7c703          	lbu	a4,-1(a5)
 122:	fb7d                	bnez	a4,118 <strlen+0x14>
    ;
  return n;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  for(n = 0; s[n]; n++)
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strlen+0x20>

000000000000012e <memset>:

void*
memset(void *dst, int c, uint n)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 134:	ca19                	beqz	a2,14a <memset+0x1c>
 136:	87aa                	mv	a5,a0
 138:	1602                	slli	a2,a2,0x20
 13a:	9201                	srli	a2,a2,0x20
 13c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 140:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 144:	0785                	addi	a5,a5,1
 146:	fee79de3          	bne	a5,a4,140 <memset+0x12>
  }
  return dst;
}
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strchr>:

char*
strchr(const char *s, char c)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  for(; *s; s++)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cb99                	beqz	a5,170 <strchr+0x20>
    if(*s == c)
 15c:	00f58763          	beq	a1,a5,16a <strchr+0x1a>
  for(; *s; s++)
 160:	0505                	addi	a0,a0,1
 162:	00054783          	lbu	a5,0(a0)
 166:	fbfd                	bnez	a5,15c <strchr+0xc>
      return (char*)s;
  return 0;
 168:	4501                	li	a0,0
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  return 0;
 170:	4501                	li	a0,0
 172:	bfe5                	j	16a <strchr+0x1a>

0000000000000174 <gets>:

char*
gets(char *buf, int max)
{
 174:	711d                	addi	sp,sp,-96
 176:	ec86                	sd	ra,88(sp)
 178:	e8a2                	sd	s0,80(sp)
 17a:	e4a6                	sd	s1,72(sp)
 17c:	e0ca                	sd	s2,64(sp)
 17e:	fc4e                	sd	s3,56(sp)
 180:	f852                	sd	s4,48(sp)
 182:	f456                	sd	s5,40(sp)
 184:	f05a                	sd	s6,32(sp)
 186:	ec5e                	sd	s7,24(sp)
 188:	1080                	addi	s0,sp,96
 18a:	8baa                	mv	s7,a0
 18c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18e:	892a                	mv	s2,a0
 190:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 192:	4aa9                	li	s5,10
 194:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 196:	89a6                	mv	s3,s1
 198:	2485                	addiw	s1,s1,1
 19a:	0344d663          	bge	s1,s4,1c6 <gets+0x52>
    cc = read(0, &c, 1);
 19e:	4605                	li	a2,1
 1a0:	faf40593          	addi	a1,s0,-81
 1a4:	4501                	li	a0,0
 1a6:	1b2000ef          	jal	ra,358 <read>
    if(cc < 1)
 1aa:	00a05e63          	blez	a0,1c6 <gets+0x52>
    buf[i++] = c;
 1ae:	faf44783          	lbu	a5,-81(s0)
 1b2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b6:	01578763          	beq	a5,s5,1c4 <gets+0x50>
 1ba:	0905                	addi	s2,s2,1
 1bc:	fd679de3          	bne	a5,s6,196 <gets+0x22>
  for(i=0; i+1 < max; ){
 1c0:	89a6                	mv	s3,s1
 1c2:	a011                	j	1c6 <gets+0x52>
 1c4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c6:	99de                	add	s3,s3,s7
 1c8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1cc:	855e                	mv	a0,s7
 1ce:	60e6                	ld	ra,88(sp)
 1d0:	6446                	ld	s0,80(sp)
 1d2:	64a6                	ld	s1,72(sp)
 1d4:	6906                	ld	s2,64(sp)
 1d6:	79e2                	ld	s3,56(sp)
 1d8:	7a42                	ld	s4,48(sp)
 1da:	7aa2                	ld	s5,40(sp)
 1dc:	7b02                	ld	s6,32(sp)
 1de:	6be2                	ld	s7,24(sp)
 1e0:	6125                	addi	sp,sp,96
 1e2:	8082                	ret

00000000000001e4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e4:	1101                	addi	sp,sp,-32
 1e6:	ec06                	sd	ra,24(sp)
 1e8:	e822                	sd	s0,16(sp)
 1ea:	e426                	sd	s1,8(sp)
 1ec:	e04a                	sd	s2,0(sp)
 1ee:	1000                	addi	s0,sp,32
 1f0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f2:	4581                	li	a1,0
 1f4:	18c000ef          	jal	ra,380 <open>
  if(fd < 0)
 1f8:	02054163          	bltz	a0,21a <stat+0x36>
 1fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fe:	85ca                	mv	a1,s2
 200:	198000ef          	jal	ra,398 <fstat>
 204:	892a                	mv	s2,a0
  close(fd);
 206:	8526                	mv	a0,s1
 208:	160000ef          	jal	ra,368 <close>
  return r;
}
 20c:	854a                	mv	a0,s2
 20e:	60e2                	ld	ra,24(sp)
 210:	6442                	ld	s0,16(sp)
 212:	64a2                	ld	s1,8(sp)
 214:	6902                	ld	s2,0(sp)
 216:	6105                	addi	sp,sp,32
 218:	8082                	ret
    return -1;
 21a:	597d                	li	s2,-1
 21c:	bfc5                	j	20c <stat+0x28>

000000000000021e <atoi>:

int
atoi(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 224:	00054683          	lbu	a3,0(a0)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	4625                	li	a2,9
 232:	02f66863          	bltu	a2,a5,262 <atoi+0x44>
 236:	872a                	mv	a4,a0
  n = 0;
 238:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23a:	0705                	addi	a4,a4,1
 23c:	0025179b          	slliw	a5,a0,0x2
 240:	9fa9                	addw	a5,a5,a0
 242:	0017979b          	slliw	a5,a5,0x1
 246:	9fb5                	addw	a5,a5,a3
 248:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24c:	00074683          	lbu	a3,0(a4)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	fef671e3          	bgeu	a2,a5,23a <atoi+0x1c>
  return n;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  n = 0;
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <atoi+0x3e>

0000000000000266 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26c:	02b57463          	bgeu	a0,a1,294 <memmove+0x2e>
    while(n-- > 0)
 270:	00c05f63          	blez	a2,28e <memmove+0x28>
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27c:	872a                	mv	a4,a0
      *dst++ = *src++;
 27e:	0585                	addi	a1,a1,1
 280:	0705                	addi	a4,a4,1
 282:	fff5c683          	lbu	a3,-1(a1)
 286:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28a:	fee79ae3          	bne	a5,a4,27e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
    dst += n;
 294:	00c50733          	add	a4,a0,a2
    src += n;
 298:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 29a:	fec05ae3          	blez	a2,28e <memmove+0x28>
 29e:	fff6079b          	addiw	a5,a2,-1
 2a2:	1782                	slli	a5,a5,0x20
 2a4:	9381                	srli	a5,a5,0x20
 2a6:	fff7c793          	not	a5,a5
 2aa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ac:	15fd                	addi	a1,a1,-1
 2ae:	177d                	addi	a4,a4,-1
 2b0:	0005c683          	lbu	a3,0(a1)
 2b4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b8:	fee79ae3          	bne	a5,a4,2ac <memmove+0x46>
 2bc:	bfc9                	j	28e <memmove+0x28>

00000000000002be <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c4:	ca05                	beqz	a2,2f4 <memcmp+0x36>
 2c6:	fff6069b          	addiw	a3,a2,-1
 2ca:	1682                	slli	a3,a3,0x20
 2cc:	9281                	srli	a3,a3,0x20
 2ce:	0685                	addi	a3,a3,1
 2d0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	0005c703          	lbu	a4,0(a1)
 2da:	00e79863          	bne	a5,a4,2ea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2de:	0505                	addi	a0,a0,1
    p2++;
 2e0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e2:	fed518e3          	bne	a0,a3,2d2 <memcmp+0x14>
  }
  return 0;
 2e6:	4501                	li	a0,0
 2e8:	a019                	j	2ee <memcmp+0x30>
      return *p1 - *p2;
 2ea:	40e7853b          	subw	a0,a5,a4
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
  return 0;
 2f4:	4501                	li	a0,0
 2f6:	bfe5                	j	2ee <memcmp+0x30>

00000000000002f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 300:	f67ff0ef          	jal	ra,266 <memmove>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <sbrk>:

char *
sbrk(int n) {
 30c:	1141                	addi	sp,sp,-16
 30e:	e406                	sd	ra,8(sp)
 310:	e022                	sd	s0,0(sp)
 312:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 314:	4585                	li	a1,1
 316:	0b2000ef          	jal	ra,3c8 <sys_sbrk>
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <sbrklazy>:

char *
sbrklazy(int n) {
 322:	1141                	addi	sp,sp,-16
 324:	e406                	sd	ra,8(sp)
 326:	e022                	sd	s0,0(sp)
 328:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 32a:	4589                	li	a1,2
 32c:	09c000ef          	jal	ra,3c8 <sys_sbrk>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 338:	4885                	li	a7,1
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <exit>:
.global exit
exit:
 li a7, SYS_exit
 340:	4889                	li	a7,2
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <wait>:
.global wait
wait:
 li a7, SYS_wait
 348:	488d                	li	a7,3
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <close>:
.global close
close:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 388:	48c5                	li	a7,17
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 390:	48c9                	li	a7,18
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 398:	48a1                	li	a7,8
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <link>:
.global link
link:
 li a7, SYS_link
 3a0:	48cd                	li	a7,19
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a8:	48d1                	li	a7,20
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b0:	48a5                	li	a7,9
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b8:	48a9                	li	a7,10
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c0:	48ad                	li	a7,11
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c8:	48b1                	li	a7,12
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d0:	48b5                	li	a7,13
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d8:	48b9                	li	a7,14
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3e0:	48d9                	li	a7,22
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3e8:	48dd                	li	a7,23
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f0:	1101                	addi	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	1000                	addi	s0,sp,32
 3f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fc:	4605                	li	a2,1
 3fe:	fef40593          	addi	a1,s0,-17
 402:	f5fff0ef          	jal	ra,360 <write>
}
 406:	60e2                	ld	ra,24(sp)
 408:	6442                	ld	s0,16(sp)
 40a:	6105                	addi	sp,sp,32
 40c:	8082                	ret

000000000000040e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 40e:	715d                	addi	sp,sp,-80
 410:	e486                	sd	ra,72(sp)
 412:	e0a2                	sd	s0,64(sp)
 414:	fc26                	sd	s1,56(sp)
 416:	f84a                	sd	s2,48(sp)
 418:	f44e                	sd	s3,40(sp)
 41a:	0880                	addi	s0,sp,80
 41c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 41e:	c299                	beqz	a3,424 <printint+0x16>
 420:	0805c163          	bltz	a1,4a2 <printint+0x94>
  neg = 0;
 424:	4881                	li	a7,0
 426:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 42a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 42c:	00000517          	auipc	a0,0x0
 430:	53c50513          	addi	a0,a0,1340 # 968 <digits>
 434:	883e                	mv	a6,a5
 436:	2785                	addiw	a5,a5,1
 438:	02c5f733          	remu	a4,a1,a2
 43c:	972a                	add	a4,a4,a0
 43e:	00074703          	lbu	a4,0(a4)
 442:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 446:	872e                	mv	a4,a1
 448:	02c5d5b3          	divu	a1,a1,a2
 44c:	0685                	addi	a3,a3,1
 44e:	fec773e3          	bgeu	a4,a2,434 <printint+0x26>
  if(neg)
 452:	00088b63          	beqz	a7,468 <printint+0x5a>
    buf[i++] = '-';
 456:	fd078793          	addi	a5,a5,-48
 45a:	97a2                	add	a5,a5,s0
 45c:	02d00713          	li	a4,45
 460:	fee78423          	sb	a4,-24(a5)
 464:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 468:	02f05663          	blez	a5,494 <printint+0x86>
 46c:	fb840713          	addi	a4,s0,-72
 470:	00f704b3          	add	s1,a4,a5
 474:	fff70993          	addi	s3,a4,-1
 478:	99be                	add	s3,s3,a5
 47a:	37fd                	addiw	a5,a5,-1
 47c:	1782                	slli	a5,a5,0x20
 47e:	9381                	srli	a5,a5,0x20
 480:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 484:	fff4c583          	lbu	a1,-1(s1)
 488:	854a                	mv	a0,s2
 48a:	f67ff0ef          	jal	ra,3f0 <putc>
  while(--i >= 0)
 48e:	14fd                	addi	s1,s1,-1
 490:	ff349ae3          	bne	s1,s3,484 <printint+0x76>
}
 494:	60a6                	ld	ra,72(sp)
 496:	6406                	ld	s0,64(sp)
 498:	74e2                	ld	s1,56(sp)
 49a:	7942                	ld	s2,48(sp)
 49c:	79a2                	ld	s3,40(sp)
 49e:	6161                	addi	sp,sp,80
 4a0:	8082                	ret
    x = -xx;
 4a2:	40b005b3          	neg	a1,a1
    neg = 1;
 4a6:	4885                	li	a7,1
    x = -xx;
 4a8:	bfbd                	j	426 <printint+0x18>

00000000000004aa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4aa:	7119                	addi	sp,sp,-128
 4ac:	fc86                	sd	ra,120(sp)
 4ae:	f8a2                	sd	s0,112(sp)
 4b0:	f4a6                	sd	s1,104(sp)
 4b2:	f0ca                	sd	s2,96(sp)
 4b4:	ecce                	sd	s3,88(sp)
 4b6:	e8d2                	sd	s4,80(sp)
 4b8:	e4d6                	sd	s5,72(sp)
 4ba:	e0da                	sd	s6,64(sp)
 4bc:	fc5e                	sd	s7,56(sp)
 4be:	f862                	sd	s8,48(sp)
 4c0:	f466                	sd	s9,40(sp)
 4c2:	f06a                	sd	s10,32(sp)
 4c4:	ec6e                	sd	s11,24(sp)
 4c6:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c8:	0005c903          	lbu	s2,0(a1)
 4cc:	24090c63          	beqz	s2,724 <vprintf+0x27a>
 4d0:	8b2a                	mv	s6,a0
 4d2:	8a2e                	mv	s4,a1
 4d4:	8bb2                	mv	s7,a2
  state = 0;
 4d6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d8:	4481                	li	s1,0
 4da:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4dc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4e0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4e4:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4e8:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ec:	00000c97          	auipc	s9,0x0
 4f0:	47cc8c93          	addi	s9,s9,1148 # 968 <digits>
 4f4:	a005                	j	514 <vprintf+0x6a>
        putc(fd, c0);
 4f6:	85ca                	mv	a1,s2
 4f8:	855a                	mv	a0,s6
 4fa:	ef7ff0ef          	jal	ra,3f0 <putc>
 4fe:	a019                	j	504 <vprintf+0x5a>
    } else if(state == '%'){
 500:	03598263          	beq	s3,s5,524 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 504:	2485                	addiw	s1,s1,1
 506:	8726                	mv	a4,s1
 508:	009a07b3          	add	a5,s4,s1
 50c:	0007c903          	lbu	s2,0(a5)
 510:	20090a63          	beqz	s2,724 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 514:	0009079b          	sext.w	a5,s2
    if(state == 0){
 518:	fe0994e3          	bnez	s3,500 <vprintf+0x56>
      if(c0 == '%'){
 51c:	fd579de3          	bne	a5,s5,4f6 <vprintf+0x4c>
        state = '%';
 520:	89be                	mv	s3,a5
 522:	b7cd                	j	504 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 524:	c3c1                	beqz	a5,5a4 <vprintf+0xfa>
 526:	00ea06b3          	add	a3,s4,a4
 52a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 52e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 530:	c681                	beqz	a3,538 <vprintf+0x8e>
 532:	9752                	add	a4,a4,s4
 534:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 538:	03878e63          	beq	a5,s8,574 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 53c:	05a78863          	beq	a5,s10,58c <vprintf+0xe2>
      } else if(c0 == 'u'){
 540:	0db78b63          	beq	a5,s11,616 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 544:	07800713          	li	a4,120
 548:	10e78d63          	beq	a5,a4,662 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 54c:	07000713          	li	a4,112
 550:	14e78263          	beq	a5,a4,694 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 554:	06300713          	li	a4,99
 558:	16e78f63          	beq	a5,a4,6d6 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 55c:	07300713          	li	a4,115
 560:	18e78563          	beq	a5,a4,6ea <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 564:	05579063          	bne	a5,s5,5a4 <vprintf+0xfa>
        putc(fd, '%');
 568:	85d6                	mv	a1,s5
 56a:	855a                	mv	a0,s6
 56c:	e85ff0ef          	jal	ra,3f0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 570:	4981                	li	s3,0
 572:	bf49                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 574:	008b8913          	addi	s2,s7,8
 578:	4685                	li	a3,1
 57a:	4629                	li	a2,10
 57c:	000ba583          	lw	a1,0(s7)
 580:	855a                	mv	a0,s6
 582:	e8dff0ef          	jal	ra,40e <printint>
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	bfad                	j	504 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 58c:	03868663          	beq	a3,s8,5b8 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 590:	05a68163          	beq	a3,s10,5d2 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 594:	09b68d63          	beq	a3,s11,62e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 598:	03a68f63          	beq	a3,s10,5d6 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 59c:	07800793          	li	a5,120
 5a0:	0cf68d63          	beq	a3,a5,67a <vprintf+0x1d0>
        putc(fd, '%');
 5a4:	85d6                	mv	a1,s5
 5a6:	855a                	mv	a0,s6
 5a8:	e49ff0ef          	jal	ra,3f0 <putc>
        putc(fd, c0);
 5ac:	85ca                	mv	a1,s2
 5ae:	855a                	mv	a0,s6
 5b0:	e41ff0ef          	jal	ra,3f0 <putc>
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b7b9                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b8:	008b8913          	addi	s2,s7,8
 5bc:	4685                	li	a3,1
 5be:	4629                	li	a2,10
 5c0:	000bb583          	ld	a1,0(s7)
 5c4:	855a                	mv	a0,s6
 5c6:	e49ff0ef          	jal	ra,40e <printint>
        i += 1;
 5ca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5cc:	8bca                	mv	s7,s2
      state = 0;
 5ce:	4981                	li	s3,0
        i += 1;
 5d0:	bf15                	j	504 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d2:	03860563          	beq	a2,s8,5fc <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d6:	07b60963          	beq	a2,s11,648 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5da:	07800793          	li	a5,120
 5de:	fcf613e3          	bne	a2,a5,5a4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	e1fff0ef          	jal	ra,40e <printint>
        i += 2;
 5f4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 2;
 5fa:	b729                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000bb583          	ld	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	e05ff0ef          	jal	ra,40e <printint>
        i += 2;
 60e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
        i += 2;
 614:	bdc5                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 616:	008b8913          	addi	s2,s7,8
 61a:	4681                	li	a3,0
 61c:	4629                	li	a2,10
 61e:	000be583          	lwu	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	debff0ef          	jal	ra,40e <printint>
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bde1                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62e:	008b8913          	addi	s2,s7,8
 632:	4681                	li	a3,0
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	dd3ff0ef          	jal	ra,40e <printint>
        i += 1;
 640:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 1;
 646:	bd7d                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4629                	li	a2,10
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	db9ff0ef          	jal	ra,40e <printint>
        i += 2;
 65a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	b555                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4641                	li	a2,16
 66a:	000be583          	lwu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	d9fff0ef          	jal	ra,40e <printint>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	b571                	j	504 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4641                	li	a2,16
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	d87ff0ef          	jal	ra,40e <printint>
        i += 1;
 68c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 1;
 692:	bd8d                	j	504 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 694:	008b8793          	addi	a5,s7,8
 698:	f8f43423          	sd	a5,-120(s0)
 69c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a0:	03000593          	li	a1,48
 6a4:	855a                	mv	a0,s6
 6a6:	d4bff0ef          	jal	ra,3f0 <putc>
  putc(fd, 'x');
 6aa:	07800593          	li	a1,120
 6ae:	855a                	mv	a0,s6
 6b0:	d41ff0ef          	jal	ra,3f0 <putc>
 6b4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b6:	03c9d793          	srli	a5,s3,0x3c
 6ba:	97e6                	add	a5,a5,s9
 6bc:	0007c583          	lbu	a1,0(a5)
 6c0:	855a                	mv	a0,s6
 6c2:	d2fff0ef          	jal	ra,3f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c6:	0992                	slli	s3,s3,0x4
 6c8:	397d                	addiw	s2,s2,-1
 6ca:	fe0916e3          	bnez	s2,6b6 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6ce:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bd05                	j	504 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6d6:	008b8913          	addi	s2,s7,8
 6da:	000bc583          	lbu	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	d11ff0ef          	jal	ra,3f0 <putc>
 6e4:	8bca                	mv	s7,s2
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	bd31                	j	504 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6ea:	008b8993          	addi	s3,s7,8
 6ee:	000bb903          	ld	s2,0(s7)
 6f2:	00090f63          	beqz	s2,710 <vprintf+0x266>
        for(; *s; s++)
 6f6:	00094583          	lbu	a1,0(s2)
 6fa:	c195                	beqz	a1,71e <vprintf+0x274>
          putc(fd, *s);
 6fc:	855a                	mv	a0,s6
 6fe:	cf3ff0ef          	jal	ra,3f0 <putc>
        for(; *s; s++)
 702:	0905                	addi	s2,s2,1
 704:	00094583          	lbu	a1,0(s2)
 708:	f9f5                	bnez	a1,6fc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 70a:	8bce                	mv	s7,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bbdd                	j	504 <vprintf+0x5a>
          s = "(null)";
 710:	00000917          	auipc	s2,0x0
 714:	25090913          	addi	s2,s2,592 # 960 <malloc+0x140>
        for(; *s; s++)
 718:	02800593          	li	a1,40
 71c:	b7c5                	j	6fc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 71e:	8bce                	mv	s7,s3
      state = 0;
 720:	4981                	li	s3,0
 722:	b3cd                	j	504 <vprintf+0x5a>
    }
  }
}
 724:	70e6                	ld	ra,120(sp)
 726:	7446                	ld	s0,112(sp)
 728:	74a6                	ld	s1,104(sp)
 72a:	7906                	ld	s2,96(sp)
 72c:	69e6                	ld	s3,88(sp)
 72e:	6a46                	ld	s4,80(sp)
 730:	6aa6                	ld	s5,72(sp)
 732:	6b06                	ld	s6,64(sp)
 734:	7be2                	ld	s7,56(sp)
 736:	7c42                	ld	s8,48(sp)
 738:	7ca2                	ld	s9,40(sp)
 73a:	7d02                	ld	s10,32(sp)
 73c:	6de2                	ld	s11,24(sp)
 73e:	6109                	addi	sp,sp,128
 740:	8082                	ret

0000000000000742 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 742:	715d                	addi	sp,sp,-80
 744:	ec06                	sd	ra,24(sp)
 746:	e822                	sd	s0,16(sp)
 748:	1000                	addi	s0,sp,32
 74a:	e010                	sd	a2,0(s0)
 74c:	e414                	sd	a3,8(s0)
 74e:	e818                	sd	a4,16(s0)
 750:	ec1c                	sd	a5,24(s0)
 752:	03043023          	sd	a6,32(s0)
 756:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 75a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75e:	8622                	mv	a2,s0
 760:	d4bff0ef          	jal	ra,4aa <vprintf>
}
 764:	60e2                	ld	ra,24(sp)
 766:	6442                	ld	s0,16(sp)
 768:	6161                	addi	sp,sp,80
 76a:	8082                	ret

000000000000076c <printf>:

void
printf(const char *fmt, ...)
{
 76c:	711d                	addi	sp,sp,-96
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e40c                	sd	a1,8(s0)
 776:	e810                	sd	a2,16(s0)
 778:	ec14                	sd	a3,24(s0)
 77a:	f018                	sd	a4,32(s0)
 77c:	f41c                	sd	a5,40(s0)
 77e:	03043823          	sd	a6,48(s0)
 782:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	00840613          	addi	a2,s0,8
 78a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78e:	85aa                	mv	a1,a0
 790:	4505                	li	a0,1
 792:	d19ff0ef          	jal	ra,4aa <vprintf>
}
 796:	60e2                	ld	ra,24(sp)
 798:	6442                	ld	s0,16(sp)
 79a:	6125                	addi	sp,sp,96
 79c:	8082                	ret

000000000000079e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79e:	1141                	addi	sp,sp,-16
 7a0:	e422                	sd	s0,8(sp)
 7a2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a8:	00001797          	auipc	a5,0x1
 7ac:	8587b783          	ld	a5,-1960(a5) # 1000 <freep>
 7b0:	a02d                	j	7da <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b2:	4618                	lw	a4,8(a2)
 7b4:	9f2d                	addw	a4,a4,a1
 7b6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ba:	6398                	ld	a4,0(a5)
 7bc:	6310                	ld	a2,0(a4)
 7be:	a83d                	j	7fc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c0:	ff852703          	lw	a4,-8(a0)
 7c4:	9f31                	addw	a4,a4,a2
 7c6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c8:	ff053683          	ld	a3,-16(a0)
 7cc:	a091                	j	810 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ce:	6398                	ld	a4,0(a5)
 7d0:	00e7e463          	bltu	a5,a4,7d8 <free+0x3a>
 7d4:	00e6ea63          	bltu	a3,a4,7e8 <free+0x4a>
{
 7d8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	fed7fae3          	bgeu	a5,a3,7ce <free+0x30>
 7de:	6398                	ld	a4,0(a5)
 7e0:	00e6e463          	bltu	a3,a4,7e8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e4:	fee7eae3          	bltu	a5,a4,7d8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e8:	ff852583          	lw	a1,-8(a0)
 7ec:	6390                	ld	a2,0(a5)
 7ee:	02059813          	slli	a6,a1,0x20
 7f2:	01c85713          	srli	a4,a6,0x1c
 7f6:	9736                	add	a4,a4,a3
 7f8:	fae60de3          	beq	a2,a4,7b2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7fc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 800:	4790                	lw	a2,8(a5)
 802:	02061593          	slli	a1,a2,0x20
 806:	01c5d713          	srli	a4,a1,0x1c
 80a:	973e                	add	a4,a4,a5
 80c:	fae68ae3          	beq	a3,a4,7c0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 810:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 812:	00000717          	auipc	a4,0x0
 816:	7ef73723          	sd	a5,2030(a4) # 1000 <freep>
}
 81a:	6422                	ld	s0,8(sp)
 81c:	0141                	addi	sp,sp,16
 81e:	8082                	ret

0000000000000820 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 820:	7139                	addi	sp,sp,-64
 822:	fc06                	sd	ra,56(sp)
 824:	f822                	sd	s0,48(sp)
 826:	f426                	sd	s1,40(sp)
 828:	f04a                	sd	s2,32(sp)
 82a:	ec4e                	sd	s3,24(sp)
 82c:	e852                	sd	s4,16(sp)
 82e:	e456                	sd	s5,8(sp)
 830:	e05a                	sd	s6,0(sp)
 832:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 834:	02051493          	slli	s1,a0,0x20
 838:	9081                	srli	s1,s1,0x20
 83a:	04bd                	addi	s1,s1,15
 83c:	8091                	srli	s1,s1,0x4
 83e:	0014899b          	addiw	s3,s1,1
 842:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 844:	00000517          	auipc	a0,0x0
 848:	7bc53503          	ld	a0,1980(a0) # 1000 <freep>
 84c:	c515                	beqz	a0,878 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 850:	4798                	lw	a4,8(a5)
 852:	02977f63          	bgeu	a4,s1,890 <malloc+0x70>
 856:	8a4e                	mv	s4,s3
 858:	0009871b          	sext.w	a4,s3
 85c:	6685                	lui	a3,0x1
 85e:	00d77363          	bgeu	a4,a3,864 <malloc+0x44>
 862:	6a05                	lui	s4,0x1
 864:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 868:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 86c:	00000917          	auipc	s2,0x0
 870:	79490913          	addi	s2,s2,1940 # 1000 <freep>
  if(p == SBRK_ERROR)
 874:	5afd                	li	s5,-1
 876:	a885                	j	8e6 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 878:	00000797          	auipc	a5,0x0
 87c:	79878793          	addi	a5,a5,1944 # 1010 <base>
 880:	00000717          	auipc	a4,0x0
 884:	78f73023          	sd	a5,1920(a4) # 1000 <freep>
 888:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 88a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 88e:	b7e1                	j	856 <malloc+0x36>
      if(p->s.size == nunits)
 890:	02e48c63          	beq	s1,a4,8c8 <malloc+0xa8>
        p->s.size -= nunits;
 894:	4137073b          	subw	a4,a4,s3
 898:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89a:	02071693          	slli	a3,a4,0x20
 89e:	01c6d713          	srli	a4,a3,0x1c
 8a2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a8:	00000717          	auipc	a4,0x0
 8ac:	74a73c23          	sd	a0,1880(a4) # 1000 <freep>
      return (void*)(p + 1);
 8b0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
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
 8cc:	bff1                	j	8a8 <malloc+0x88>
  hp->s.size = nu;
 8ce:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d2:	0541                	addi	a0,a0,16
 8d4:	ecbff0ef          	jal	ra,79e <free>
  return freep;
 8d8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8dc:	dd61                	beqz	a0,8b4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	fa9777e3          	bgeu	a4,s1,890 <malloc+0x70>
    if(p == freep)
 8e6:	00093703          	ld	a4,0(s2)
 8ea:	853e                	mv	a0,a5
 8ec:	fef719e3          	bne	a4,a5,8de <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 8f0:	8552                	mv	a0,s4
 8f2:	a1bff0ef          	jal	ra,30c <sbrk>
  if(p == SBRK_ERROR)
 8f6:	fd551ce3          	bne	a0,s5,8ce <malloc+0xae>
        return 0;
 8fa:	4501                	li	a0,0
 8fc:	bf65                	j	8b4 <malloc+0x94>
