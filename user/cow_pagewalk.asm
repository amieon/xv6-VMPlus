
user/_cow_pagewalk：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *p = sbrk(4096);
   a:	6505                	lui	a0,0x1
   c:	316000ef          	jal	ra,322 <sbrk>
  10:	84aa                	mv	s1,a0
  if(p == (char*)-1) exit(1);
  12:	577d                	li	a4,-1
  14:	4781                	li	a5,0

  for(int i = 0; i < 4096; i++)
    p[i] = (char)(i % 97);
  16:	06100593          	li	a1,97
  for(int i = 0; i < 4096; i++)
  1a:	6605                	lui	a2,0x1
  if(p == (char*)-1) exit(1);
  1c:	04e50563          	beq	a0,a4,66 <main+0x66>
    p[i] = (char)(i % 97);
  20:	00f48733          	add	a4,s1,a5
  24:	02b7e6bb          	remw	a3,a5,a1
  28:	00d70023          	sb	a3,0(a4)
  for(int i = 0; i < 4096; i++)
  2c:	0785                	addi	a5,a5,1
  2e:	fec799e3          	bne	a5,a2,20 <main+0x20>

  int pid = fork();
  32:	31c000ef          	jal	ra,34e <fork>
  if(pid < 0) exit(1);
  36:	02054b63          	bltz	a0,6c <main+0x6c>

  if(pid == 0){
  3a:	ed05                	bnez	a0,72 <main+0x72>
  3c:	87a6                	mv	a5,s1
  3e:	6685                	lui	a3,0x1
  40:	0699                	addi	a3,a3,6 # 1006 <freep+0x6>
  42:	96a6                	add	a3,a3,s1
    for(int i = 0; i < 4096; i += 7)
      p[i] = (char)(p[i] + 1);
  44:	0007c703          	lbu	a4,0(a5)
  48:	2705                	addiw	a4,a4,1
  4a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < 4096; i += 7)
  4e:	079d                	addi	a5,a5,7
  50:	fed79ae3          	bne	a5,a3,44 <main+0x44>
    printf("child: wrote many offsets\n");
  54:	00001517          	auipc	a0,0x1
  58:	8dc50513          	addi	a0,a0,-1828 # 930 <malloc+0xea>
  5c:	736000ef          	jal	ra,792 <printf>
    exit(0);
  60:	4501                	li	a0,0
  62:	2f4000ef          	jal	ra,356 <exit>
  if(p == (char*)-1) exit(1);
  66:	4505                	li	a0,1
  68:	2ee000ef          	jal	ra,356 <exit>
  if(pid < 0) exit(1);
  6c:	4505                	li	a0,1
  6e:	2e8000ef          	jal	ra,356 <exit>
  }

  wait(0);
  72:	4501                	li	a0,0
  74:	2ea000ef          	jal	ra,35e <wait>
  78:	4701                	li	a4,0
  // 父校验页内容未变
  for(int i = 0; i < 4096; i++){
    if(p[i] != (char)(i % 97)){
  7a:	06100613          	li	a2,97
  for(int i = 0; i < 4096; i++){
  7e:	6505                	lui	a0,0x1
  80:	0007059b          	sext.w	a1,a4
    if(p[i] != (char)(i % 97)){
  84:	00e486b3          	add	a3,s1,a4
  88:	02c767bb          	remw	a5,a4,a2
  8c:	0006c683          	lbu	a3,0(a3)
  90:	0ff7f793          	zext.b	a5,a5
  94:	00f69e63          	bne	a3,a5,b0 <main+0xb0>
  for(int i = 0; i < 4096; i++){
  98:	0705                	addi	a4,a4,1
  9a:	fea713e3          	bne	a4,a0,80 <main+0x80>
      printf("FAIL: parent page changed at %d\n", i);
      exit(1);
    }
  }
  printf("PASS\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	8da50513          	addi	a0,a0,-1830 # 978 <malloc+0x132>
  a6:	6ec000ef          	jal	ra,792 <printf>
  exit(0);
  aa:	4501                	li	a0,0
  ac:	2aa000ef          	jal	ra,356 <exit>
      printf("FAIL: parent page changed at %d\n", i);
  b0:	00001517          	auipc	a0,0x1
  b4:	8a050513          	addi	a0,a0,-1888 # 950 <malloc+0x10a>
  b8:	6da000ef          	jal	ra,792 <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	298000ef          	jal	ra,356 <exit>

00000000000000c2 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e406                	sd	ra,8(sp)
  c6:	e022                	sd	s0,0(sp)
  c8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ca:	f37ff0ef          	jal	ra,0 <main>
  exit(r);
  ce:	288000ef          	jal	ra,356 <exit>

00000000000000d2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d8:	87aa                	mv	a5,a0
  da:	0585                	addi	a1,a1,1
  dc:	0785                	addi	a5,a5,1
  de:	fff5c703          	lbu	a4,-1(a1)
  e2:	fee78fa3          	sb	a4,-1(a5)
  e6:	fb75                	bnez	a4,da <strcpy+0x8>
    ;
  return os;
}
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cb91                	beqz	a5,10c <strcmp+0x1e>
  fa:	0005c703          	lbu	a4,0(a1)
  fe:	00f71763          	bne	a4,a5,10c <strcmp+0x1e>
    p++, q++;
 102:	0505                	addi	a0,a0,1
 104:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbe5                	bnez	a5,fa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10c:	0005c503          	lbu	a0,0(a1)
}
 110:	40a7853b          	subw	a0,a5,a0
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strlen>:

uint
strlen(const char *s)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 120:	00054783          	lbu	a5,0(a0)
 124:	cf91                	beqz	a5,140 <strlen+0x26>
 126:	0505                	addi	a0,a0,1
 128:	87aa                	mv	a5,a0
 12a:	4685                	li	a3,1
 12c:	9e89                	subw	a3,a3,a0
 12e:	00f6853b          	addw	a0,a3,a5
 132:	0785                	addi	a5,a5,1
 134:	fff7c703          	lbu	a4,-1(a5)
 138:	fb7d                	bnez	a4,12e <strlen+0x14>
    ;
  return n;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret
  for(n = 0; s[n]; n++)
 140:	4501                	li	a0,0
 142:	bfe5                	j	13a <strlen+0x20>

0000000000000144 <memset>:

void*
memset(void *dst, int c, uint n)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14a:	ca19                	beqz	a2,160 <memset+0x1c>
 14c:	87aa                	mv	a5,a0
 14e:	1602                	slli	a2,a2,0x20
 150:	9201                	srli	a2,a2,0x20
 152:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 156:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15a:	0785                	addi	a5,a5,1
 15c:	fee79de3          	bne	a5,a4,156 <memset+0x12>
  }
  return dst;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strchr>:

char*
strchr(const char *s, char c)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb99                	beqz	a5,186 <strchr+0x20>
    if(*s == c)
 172:	00f58763          	beq	a1,a5,180 <strchr+0x1a>
  for(; *s; s++)
 176:	0505                	addi	a0,a0,1
 178:	00054783          	lbu	a5,0(a0)
 17c:	fbfd                	bnez	a5,172 <strchr+0xc>
      return (char*)s;
  return 0;
 17e:	4501                	li	a0,0
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  return 0;
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strchr+0x1a>

000000000000018a <gets>:

char*
gets(char *buf, int max)
{
 18a:	711d                	addi	sp,sp,-96
 18c:	ec86                	sd	ra,88(sp)
 18e:	e8a2                	sd	s0,80(sp)
 190:	e4a6                	sd	s1,72(sp)
 192:	e0ca                	sd	s2,64(sp)
 194:	fc4e                	sd	s3,56(sp)
 196:	f852                	sd	s4,48(sp)
 198:	f456                	sd	s5,40(sp)
 19a:	f05a                	sd	s6,32(sp)
 19c:	ec5e                	sd	s7,24(sp)
 19e:	1080                	addi	s0,sp,96
 1a0:	8baa                	mv	s7,a0
 1a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	892a                	mv	s2,a0
 1a6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a8:	4aa9                	li	s5,10
 1aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ac:	89a6                	mv	s3,s1
 1ae:	2485                	addiw	s1,s1,1
 1b0:	0344d663          	bge	s1,s4,1dc <gets+0x52>
    cc = read(0, &c, 1);
 1b4:	4605                	li	a2,1
 1b6:	faf40593          	addi	a1,s0,-81
 1ba:	4501                	li	a0,0
 1bc:	1b2000ef          	jal	ra,36e <read>
    if(cc < 1)
 1c0:	00a05e63          	blez	a0,1dc <gets+0x52>
    buf[i++] = c;
 1c4:	faf44783          	lbu	a5,-81(s0)
 1c8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1cc:	01578763          	beq	a5,s5,1da <gets+0x50>
 1d0:	0905                	addi	s2,s2,1
 1d2:	fd679de3          	bne	a5,s6,1ac <gets+0x22>
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	a011                	j	1dc <gets+0x52>
 1da:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1dc:	99de                	add	s3,s3,s7
 1de:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e2:	855e                	mv	a0,s7
 1e4:	60e6                	ld	ra,88(sp)
 1e6:	6446                	ld	s0,80(sp)
 1e8:	64a6                	ld	s1,72(sp)
 1ea:	6906                	ld	s2,64(sp)
 1ec:	79e2                	ld	s3,56(sp)
 1ee:	7a42                	ld	s4,48(sp)
 1f0:	7aa2                	ld	s5,40(sp)
 1f2:	7b02                	ld	s6,32(sp)
 1f4:	6be2                	ld	s7,24(sp)
 1f6:	6125                	addi	sp,sp,96
 1f8:	8082                	ret

00000000000001fa <stat>:

int
stat(const char *n, struct stat *st)
{
 1fa:	1101                	addi	sp,sp,-32
 1fc:	ec06                	sd	ra,24(sp)
 1fe:	e822                	sd	s0,16(sp)
 200:	e426                	sd	s1,8(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 208:	4581                	li	a1,0
 20a:	18c000ef          	jal	ra,396 <open>
  if(fd < 0)
 20e:	02054163          	bltz	a0,230 <stat+0x36>
 212:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 214:	85ca                	mv	a1,s2
 216:	198000ef          	jal	ra,3ae <fstat>
 21a:	892a                	mv	s2,a0
  close(fd);
 21c:	8526                	mv	a0,s1
 21e:	160000ef          	jal	ra,37e <close>
  return r;
}
 222:	854a                	mv	a0,s2
 224:	60e2                	ld	ra,24(sp)
 226:	6442                	ld	s0,16(sp)
 228:	64a2                	ld	s1,8(sp)
 22a:	6902                	ld	s2,0(sp)
 22c:	6105                	addi	sp,sp,32
 22e:	8082                	ret
    return -1;
 230:	597d                	li	s2,-1
 232:	bfc5                	j	222 <stat+0x28>

0000000000000234 <atoi>:

int
atoi(const char *s)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23a:	00054683          	lbu	a3,0(a0)
 23e:	fd06879b          	addiw	a5,a3,-48
 242:	0ff7f793          	zext.b	a5,a5
 246:	4625                	li	a2,9
 248:	02f66863          	bltu	a2,a5,278 <atoi+0x44>
 24c:	872a                	mv	a4,a0
  n = 0;
 24e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 250:	0705                	addi	a4,a4,1
 252:	0025179b          	slliw	a5,a0,0x2
 256:	9fa9                	addw	a5,a5,a0
 258:	0017979b          	slliw	a5,a5,0x1
 25c:	9fb5                	addw	a5,a5,a3
 25e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 262:	00074683          	lbu	a3,0(a4)
 266:	fd06879b          	addiw	a5,a3,-48
 26a:	0ff7f793          	zext.b	a5,a5
 26e:	fef671e3          	bgeu	a2,a5,250 <atoi+0x1c>
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  n = 0;
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <atoi+0x3e>

000000000000027c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 282:	02b57463          	bgeu	a0,a1,2aa <memmove+0x2e>
    while(n-- > 0)
 286:	00c05f63          	blez	a2,2a4 <memmove+0x28>
 28a:	1602                	slli	a2,a2,0x20
 28c:	9201                	srli	a2,a2,0x20
 28e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 292:	872a                	mv	a4,a0
      *dst++ = *src++;
 294:	0585                	addi	a1,a1,1
 296:	0705                	addi	a4,a4,1
 298:	fff5c683          	lbu	a3,-1(a1)
 29c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a0:	fee79ae3          	bne	a5,a4,294 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
    dst += n;
 2aa:	00c50733          	add	a4,a0,a2
    src += n;
 2ae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b0:	fec05ae3          	blez	a2,2a4 <memmove+0x28>
 2b4:	fff6079b          	addiw	a5,a2,-1 # fff <digits+0x677>
 2b8:	1782                	slli	a5,a5,0x20
 2ba:	9381                	srli	a5,a5,0x20
 2bc:	fff7c793          	not	a5,a5
 2c0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c2:	15fd                	addi	a1,a1,-1
 2c4:	177d                	addi	a4,a4,-1
 2c6:	0005c683          	lbu	a3,0(a1)
 2ca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ce:	fee79ae3          	bne	a5,a4,2c2 <memmove+0x46>
 2d2:	bfc9                	j	2a4 <memmove+0x28>

00000000000002d4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2da:	ca05                	beqz	a2,30a <memcmp+0x36>
 2dc:	fff6069b          	addiw	a3,a2,-1
 2e0:	1682                	slli	a3,a3,0x20
 2e2:	9281                	srli	a3,a3,0x20
 2e4:	0685                	addi	a3,a3,1
 2e6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00e79863          	bne	a5,a4,300 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f4:	0505                	addi	a0,a0,1
    p2++;
 2f6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f8:	fed518e3          	bne	a0,a3,2e8 <memcmp+0x14>
  }
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	a019                	j	304 <memcmp+0x30>
      return *p1 - *p2;
 300:	40e7853b          	subw	a0,a5,a4
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
  return 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <memcmp+0x30>

000000000000030e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 316:	f67ff0ef          	jal	ra,27c <memmove>
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <sbrk>:

char *
sbrk(int n) {
 322:	1141                	addi	sp,sp,-16
 324:	e406                	sd	ra,8(sp)
 326:	e022                	sd	s0,0(sp)
 328:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32a:	4585                	li	a1,1
 32c:	0b2000ef          	jal	ra,3de <sys_sbrk>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <sbrklazy>:

char *
sbrklazy(int n) {
 338:	1141                	addi	sp,sp,-16
 33a:	e406                	sd	ra,8(sp)
 33c:	e022                	sd	s0,0(sp)
 33e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 340:	4589                	li	a1,2
 342:	09c000ef          	jal	ra,3de <sys_sbrk>
}
 346:	60a2                	ld	ra,8(sp)
 348:	6402                	ld	s0,0(sp)
 34a:	0141                	addi	sp,sp,16
 34c:	8082                	ret

000000000000034e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34e:	4885                	li	a7,1
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <exit>:
.global exit
exit:
 li a7, SYS_exit
 356:	4889                	li	a7,2
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <wait>:
.global wait
wait:
 li a7, SYS_wait
 35e:	488d                	li	a7,3
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 366:	4891                	li	a7,4
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <read>:
.global read
read:
 li a7, SYS_read
 36e:	4895                	li	a7,5
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <write>:
.global write
write:
 li a7, SYS_write
 376:	48c1                	li	a7,16
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <close>:
.global close
close:
 li a7, SYS_close
 37e:	48d5                	li	a7,21
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <kill>:
.global kill
kill:
 li a7, SYS_kill
 386:	4899                	li	a7,6
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <exec>:
.global exec
exec:
 li a7, SYS_exec
 38e:	489d                	li	a7,7
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <open>:
.global open
open:
 li a7, SYS_open
 396:	48bd                	li	a7,15
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39e:	48c5                	li	a7,17
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a6:	48c9                	li	a7,18
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ae:	48a1                	li	a7,8
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <link>:
.global link
link:
 li a7, SYS_link
 3b6:	48cd                	li	a7,19
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3be:	48d1                	li	a7,20
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c6:	48a5                	li	a7,9
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ce:	48a9                	li	a7,10
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d6:	48ad                	li	a7,11
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3de:	48b1                	li	a7,12
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e6:	48b5                	li	a7,13
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ee:	48b9                	li	a7,14
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3f6:	48d9                	li	a7,22
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3fe:	48dd                	li	a7,23
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 406:	48e1                	li	a7,24
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40e:	48e5                	li	a7,25
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 416:	1101                	addi	sp,sp,-32
 418:	ec06                	sd	ra,24(sp)
 41a:	e822                	sd	s0,16(sp)
 41c:	1000                	addi	s0,sp,32
 41e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 422:	4605                	li	a2,1
 424:	fef40593          	addi	a1,s0,-17
 428:	f4fff0ef          	jal	ra,376 <write>
}
 42c:	60e2                	ld	ra,24(sp)
 42e:	6442                	ld	s0,16(sp)
 430:	6105                	addi	sp,sp,32
 432:	8082                	ret

0000000000000434 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 434:	715d                	addi	sp,sp,-80
 436:	e486                	sd	ra,72(sp)
 438:	e0a2                	sd	s0,64(sp)
 43a:	fc26                	sd	s1,56(sp)
 43c:	f84a                	sd	s2,48(sp)
 43e:	f44e                	sd	s3,40(sp)
 440:	0880                	addi	s0,sp,80
 442:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 444:	c299                	beqz	a3,44a <printint+0x16>
 446:	0805c163          	bltz	a1,4c8 <printint+0x94>
  neg = 0;
 44a:	4881                	li	a7,0
 44c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 450:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 452:	00000517          	auipc	a0,0x0
 456:	53650513          	addi	a0,a0,1334 # 988 <digits>
 45a:	883e                	mv	a6,a5
 45c:	2785                	addiw	a5,a5,1
 45e:	02c5f733          	remu	a4,a1,a2
 462:	972a                	add	a4,a4,a0
 464:	00074703          	lbu	a4,0(a4)
 468:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 46c:	872e                	mv	a4,a1
 46e:	02c5d5b3          	divu	a1,a1,a2
 472:	0685                	addi	a3,a3,1
 474:	fec773e3          	bgeu	a4,a2,45a <printint+0x26>
  if(neg)
 478:	00088b63          	beqz	a7,48e <printint+0x5a>
    buf[i++] = '-';
 47c:	fd078793          	addi	a5,a5,-48
 480:	97a2                	add	a5,a5,s0
 482:	02d00713          	li	a4,45
 486:	fee78423          	sb	a4,-24(a5)
 48a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 48e:	02f05663          	blez	a5,4ba <printint+0x86>
 492:	fb840713          	addi	a4,s0,-72
 496:	00f704b3          	add	s1,a4,a5
 49a:	fff70993          	addi	s3,a4,-1
 49e:	99be                	add	s3,s3,a5
 4a0:	37fd                	addiw	a5,a5,-1
 4a2:	1782                	slli	a5,a5,0x20
 4a4:	9381                	srli	a5,a5,0x20
 4a6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4aa:	fff4c583          	lbu	a1,-1(s1)
 4ae:	854a                	mv	a0,s2
 4b0:	f67ff0ef          	jal	ra,416 <putc>
  while(--i >= 0)
 4b4:	14fd                	addi	s1,s1,-1
 4b6:	ff349ae3          	bne	s1,s3,4aa <printint+0x76>
}
 4ba:	60a6                	ld	ra,72(sp)
 4bc:	6406                	ld	s0,64(sp)
 4be:	74e2                	ld	s1,56(sp)
 4c0:	7942                	ld	s2,48(sp)
 4c2:	79a2                	ld	s3,40(sp)
 4c4:	6161                	addi	sp,sp,80
 4c6:	8082                	ret
    x = -xx;
 4c8:	40b005b3          	neg	a1,a1
    neg = 1;
 4cc:	4885                	li	a7,1
    x = -xx;
 4ce:	bfbd                	j	44c <printint+0x18>

00000000000004d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d0:	7119                	addi	sp,sp,-128
 4d2:	fc86                	sd	ra,120(sp)
 4d4:	f8a2                	sd	s0,112(sp)
 4d6:	f4a6                	sd	s1,104(sp)
 4d8:	f0ca                	sd	s2,96(sp)
 4da:	ecce                	sd	s3,88(sp)
 4dc:	e8d2                	sd	s4,80(sp)
 4de:	e4d6                	sd	s5,72(sp)
 4e0:	e0da                	sd	s6,64(sp)
 4e2:	fc5e                	sd	s7,56(sp)
 4e4:	f862                	sd	s8,48(sp)
 4e6:	f466                	sd	s9,40(sp)
 4e8:	f06a                	sd	s10,32(sp)
 4ea:	ec6e                	sd	s11,24(sp)
 4ec:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ee:	0005c903          	lbu	s2,0(a1)
 4f2:	24090c63          	beqz	s2,74a <vprintf+0x27a>
 4f6:	8b2a                	mv	s6,a0
 4f8:	8a2e                	mv	s4,a1
 4fa:	8bb2                	mv	s7,a2
  state = 0;
 4fc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fe:	4481                	li	s1,0
 500:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 502:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 506:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 50a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 50e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 512:	00000c97          	auipc	s9,0x0
 516:	476c8c93          	addi	s9,s9,1142 # 988 <digits>
 51a:	a005                	j	53a <vprintf+0x6a>
        putc(fd, c0);
 51c:	85ca                	mv	a1,s2
 51e:	855a                	mv	a0,s6
 520:	ef7ff0ef          	jal	ra,416 <putc>
 524:	a019                	j	52a <vprintf+0x5a>
    } else if(state == '%'){
 526:	03598263          	beq	s3,s5,54a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 52a:	2485                	addiw	s1,s1,1
 52c:	8726                	mv	a4,s1
 52e:	009a07b3          	add	a5,s4,s1
 532:	0007c903          	lbu	s2,0(a5)
 536:	20090a63          	beqz	s2,74a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 53a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 53e:	fe0994e3          	bnez	s3,526 <vprintf+0x56>
      if(c0 == '%'){
 542:	fd579de3          	bne	a5,s5,51c <vprintf+0x4c>
        state = '%';
 546:	89be                	mv	s3,a5
 548:	b7cd                	j	52a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 54a:	c3c1                	beqz	a5,5ca <vprintf+0xfa>
 54c:	00ea06b3          	add	a3,s4,a4
 550:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 554:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 556:	c681                	beqz	a3,55e <vprintf+0x8e>
 558:	9752                	add	a4,a4,s4
 55a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 55e:	03878e63          	beq	a5,s8,59a <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 562:	05a78863          	beq	a5,s10,5b2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 566:	0db78b63          	beq	a5,s11,63c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 56a:	07800713          	li	a4,120
 56e:	10e78d63          	beq	a5,a4,688 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 572:	07000713          	li	a4,112
 576:	14e78263          	beq	a5,a4,6ba <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 57a:	06300713          	li	a4,99
 57e:	16e78f63          	beq	a5,a4,6fc <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 582:	07300713          	li	a4,115
 586:	18e78563          	beq	a5,a4,710 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 58a:	05579063          	bne	a5,s5,5ca <vprintf+0xfa>
        putc(fd, '%');
 58e:	85d6                	mv	a1,s5
 590:	855a                	mv	a0,s6
 592:	e85ff0ef          	jal	ra,416 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 596:	4981                	li	s3,0
 598:	bf49                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 59a:	008b8913          	addi	s2,s7,8
 59e:	4685                	li	a3,1
 5a0:	4629                	li	a2,10
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	855a                	mv	a0,s6
 5a8:	e8dff0ef          	jal	ra,434 <printint>
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	bfad                	j	52a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5b2:	03868663          	beq	a3,s8,5de <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b6:	05a68163          	beq	a3,s10,5f8 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5ba:	09b68d63          	beq	a3,s11,654 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5be:	03a68f63          	beq	a3,s10,5fc <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5c2:	07800793          	li	a5,120
 5c6:	0cf68d63          	beq	a3,a5,6a0 <vprintf+0x1d0>
        putc(fd, '%');
 5ca:	85d6                	mv	a1,s5
 5cc:	855a                	mv	a0,s6
 5ce:	e49ff0ef          	jal	ra,416 <putc>
        putc(fd, c0);
 5d2:	85ca                	mv	a1,s2
 5d4:	855a                	mv	a0,s6
 5d6:	e41ff0ef          	jal	ra,416 <putc>
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b7b9                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4685                	li	a3,1
 5e4:	4629                	li	a2,10
 5e6:	000bb583          	ld	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	e49ff0ef          	jal	ra,434 <printint>
        i += 1;
 5f0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	8bca                	mv	s7,s2
      state = 0;
 5f4:	4981                	li	s3,0
        i += 1;
 5f6:	bf15                	j	52a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f8:	03860563          	beq	a2,s8,622 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5fc:	07b60963          	beq	a2,s11,66e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 600:	07800793          	li	a5,120
 604:	fcf613e3          	bne	a2,a5,5ca <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 608:	008b8913          	addi	s2,s7,8
 60c:	4681                	li	a3,0
 60e:	4641                	li	a2,16
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	e1fff0ef          	jal	ra,434 <printint>
        i += 2;
 61a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	b729                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 622:	008b8913          	addi	s2,s7,8
 626:	4685                	li	a3,1
 628:	4629                	li	a2,10
 62a:	000bb583          	ld	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	e05ff0ef          	jal	ra,434 <printint>
        i += 2;
 634:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
        i += 2;
 63a:	bdc5                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 63c:	008b8913          	addi	s2,s7,8
 640:	4681                	li	a3,0
 642:	4629                	li	a2,10
 644:	000be583          	lwu	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	debff0ef          	jal	ra,434 <printint>
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	bde1                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b8913          	addi	s2,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	dd3ff0ef          	jal	ra,434 <printint>
        i += 1;
 666:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 1;
 66c:	bd7d                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000bb583          	ld	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	db9ff0ef          	jal	ra,434 <printint>
        i += 2;
 680:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
        i += 2;
 686:	b555                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 688:	008b8913          	addi	s2,s7,8
 68c:	4681                	li	a3,0
 68e:	4641                	li	a2,16
 690:	000be583          	lwu	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	d9fff0ef          	jal	ra,434 <printint>
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b571                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4641                	li	a2,16
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d87ff0ef          	jal	ra,434 <printint>
        i += 1;
 6b2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 1;
 6b8:	bd8d                	j	52a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6ba:	008b8793          	addi	a5,s7,8
 6be:	f8f43423          	sd	a5,-120(s0)
 6c2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c6:	03000593          	li	a1,48
 6ca:	855a                	mv	a0,s6
 6cc:	d4bff0ef          	jal	ra,416 <putc>
  putc(fd, 'x');
 6d0:	07800593          	li	a1,120
 6d4:	855a                	mv	a0,s6
 6d6:	d41ff0ef          	jal	ra,416 <putc>
 6da:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6dc:	03c9d793          	srli	a5,s3,0x3c
 6e0:	97e6                	add	a5,a5,s9
 6e2:	0007c583          	lbu	a1,0(a5)
 6e6:	855a                	mv	a0,s6
 6e8:	d2fff0ef          	jal	ra,416 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ec:	0992                	slli	s3,s3,0x4
 6ee:	397d                	addiw	s2,s2,-1
 6f0:	fe0916e3          	bnez	s2,6dc <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6f4:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bd05                	j	52a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6fc:	008b8913          	addi	s2,s7,8
 700:	000bc583          	lbu	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	d11ff0ef          	jal	ra,416 <putc>
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bd31                	j	52a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 710:	008b8993          	addi	s3,s7,8
 714:	000bb903          	ld	s2,0(s7)
 718:	00090f63          	beqz	s2,736 <vprintf+0x266>
        for(; *s; s++)
 71c:	00094583          	lbu	a1,0(s2)
 720:	c195                	beqz	a1,744 <vprintf+0x274>
          putc(fd, *s);
 722:	855a                	mv	a0,s6
 724:	cf3ff0ef          	jal	ra,416 <putc>
        for(; *s; s++)
 728:	0905                	addi	s2,s2,1
 72a:	00094583          	lbu	a1,0(s2)
 72e:	f9f5                	bnez	a1,722 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 730:	8bce                	mv	s7,s3
      state = 0;
 732:	4981                	li	s3,0
 734:	bbdd                	j	52a <vprintf+0x5a>
          s = "(null)";
 736:	00000917          	auipc	s2,0x0
 73a:	24a90913          	addi	s2,s2,586 # 980 <malloc+0x13a>
        for(; *s; s++)
 73e:	02800593          	li	a1,40
 742:	b7c5                	j	722 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 744:	8bce                	mv	s7,s3
      state = 0;
 746:	4981                	li	s3,0
 748:	b3cd                	j	52a <vprintf+0x5a>
    }
  }
}
 74a:	70e6                	ld	ra,120(sp)
 74c:	7446                	ld	s0,112(sp)
 74e:	74a6                	ld	s1,104(sp)
 750:	7906                	ld	s2,96(sp)
 752:	69e6                	ld	s3,88(sp)
 754:	6a46                	ld	s4,80(sp)
 756:	6aa6                	ld	s5,72(sp)
 758:	6b06                	ld	s6,64(sp)
 75a:	7be2                	ld	s7,56(sp)
 75c:	7c42                	ld	s8,48(sp)
 75e:	7ca2                	ld	s9,40(sp)
 760:	7d02                	ld	s10,32(sp)
 762:	6de2                	ld	s11,24(sp)
 764:	6109                	addi	sp,sp,128
 766:	8082                	ret

0000000000000768 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 768:	715d                	addi	sp,sp,-80
 76a:	ec06                	sd	ra,24(sp)
 76c:	e822                	sd	s0,16(sp)
 76e:	1000                	addi	s0,sp,32
 770:	e010                	sd	a2,0(s0)
 772:	e414                	sd	a3,8(s0)
 774:	e818                	sd	a4,16(s0)
 776:	ec1c                	sd	a5,24(s0)
 778:	03043023          	sd	a6,32(s0)
 77c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 780:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 784:	8622                	mv	a2,s0
 786:	d4bff0ef          	jal	ra,4d0 <vprintf>
}
 78a:	60e2                	ld	ra,24(sp)
 78c:	6442                	ld	s0,16(sp)
 78e:	6161                	addi	sp,sp,80
 790:	8082                	ret

0000000000000792 <printf>:

void
printf(const char *fmt, ...)
{
 792:	711d                	addi	sp,sp,-96
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	e40c                	sd	a1,8(s0)
 79c:	e810                	sd	a2,16(s0)
 79e:	ec14                	sd	a3,24(s0)
 7a0:	f018                	sd	a4,32(s0)
 7a2:	f41c                	sd	a5,40(s0)
 7a4:	03043823          	sd	a6,48(s0)
 7a8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ac:	00840613          	addi	a2,s0,8
 7b0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b4:	85aa                	mv	a1,a0
 7b6:	4505                	li	a0,1
 7b8:	d19ff0ef          	jal	ra,4d0 <vprintf>
}
 7bc:	60e2                	ld	ra,24(sp)
 7be:	6442                	ld	s0,16(sp)
 7c0:	6125                	addi	sp,sp,96
 7c2:	8082                	ret

00000000000007c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c4:	1141                	addi	sp,sp,-16
 7c6:	e422                	sd	s0,8(sp)
 7c8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ca:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ce:	00001797          	auipc	a5,0x1
 7d2:	8327b783          	ld	a5,-1998(a5) # 1000 <freep>
 7d6:	a02d                	j	800 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d8:	4618                	lw	a4,8(a2)
 7da:	9f2d                	addw	a4,a4,a1
 7dc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e0:	6398                	ld	a4,0(a5)
 7e2:	6310                	ld	a2,0(a4)
 7e4:	a83d                	j	822 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e6:	ff852703          	lw	a4,-8(a0)
 7ea:	9f31                	addw	a4,a4,a2
 7ec:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ee:	ff053683          	ld	a3,-16(a0)
 7f2:	a091                	j	836 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f4:	6398                	ld	a4,0(a5)
 7f6:	00e7e463          	bltu	a5,a4,7fe <free+0x3a>
 7fa:	00e6ea63          	bltu	a3,a4,80e <free+0x4a>
{
 7fe:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 800:	fed7fae3          	bgeu	a5,a3,7f4 <free+0x30>
 804:	6398                	ld	a4,0(a5)
 806:	00e6e463          	bltu	a3,a4,80e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80a:	fee7eae3          	bltu	a5,a4,7fe <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 80e:	ff852583          	lw	a1,-8(a0)
 812:	6390                	ld	a2,0(a5)
 814:	02059813          	slli	a6,a1,0x20
 818:	01c85713          	srli	a4,a6,0x1c
 81c:	9736                	add	a4,a4,a3
 81e:	fae60de3          	beq	a2,a4,7d8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 822:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 826:	4790                	lw	a2,8(a5)
 828:	02061593          	slli	a1,a2,0x20
 82c:	01c5d713          	srli	a4,a1,0x1c
 830:	973e                	add	a4,a4,a5
 832:	fae68ae3          	beq	a3,a4,7e6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 836:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 838:	00000717          	auipc	a4,0x0
 83c:	7cf73423          	sd	a5,1992(a4) # 1000 <freep>
}
 840:	6422                	ld	s0,8(sp)
 842:	0141                	addi	sp,sp,16
 844:	8082                	ret

0000000000000846 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 846:	7139                	addi	sp,sp,-64
 848:	fc06                	sd	ra,56(sp)
 84a:	f822                	sd	s0,48(sp)
 84c:	f426                	sd	s1,40(sp)
 84e:	f04a                	sd	s2,32(sp)
 850:	ec4e                	sd	s3,24(sp)
 852:	e852                	sd	s4,16(sp)
 854:	e456                	sd	s5,8(sp)
 856:	e05a                	sd	s6,0(sp)
 858:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85a:	02051493          	slli	s1,a0,0x20
 85e:	9081                	srli	s1,s1,0x20
 860:	04bd                	addi	s1,s1,15
 862:	8091                	srli	s1,s1,0x4
 864:	0014899b          	addiw	s3,s1,1
 868:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 86a:	00000517          	auipc	a0,0x0
 86e:	79653503          	ld	a0,1942(a0) # 1000 <freep>
 872:	c515                	beqz	a0,89e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 874:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 876:	4798                	lw	a4,8(a5)
 878:	02977f63          	bgeu	a4,s1,8b6 <malloc+0x70>
 87c:	8a4e                	mv	s4,s3
 87e:	0009871b          	sext.w	a4,s3
 882:	6685                	lui	a3,0x1
 884:	00d77363          	bgeu	a4,a3,88a <malloc+0x44>
 888:	6a05                	lui	s4,0x1
 88a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 892:	00000917          	auipc	s2,0x0
 896:	76e90913          	addi	s2,s2,1902 # 1000 <freep>
  if(p == SBRK_ERROR)
 89a:	5afd                	li	s5,-1
 89c:	a885                	j	90c <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 89e:	00000797          	auipc	a5,0x0
 8a2:	77278793          	addi	a5,a5,1906 # 1010 <base>
 8a6:	00000717          	auipc	a4,0x0
 8aa:	74f73d23          	sd	a5,1882(a4) # 1000 <freep>
 8ae:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8b0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b4:	b7e1                	j	87c <malloc+0x36>
      if(p->s.size == nunits)
 8b6:	02e48c63          	beq	s1,a4,8ee <malloc+0xa8>
        p->s.size -= nunits;
 8ba:	4137073b          	subw	a4,a4,s3
 8be:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c0:	02071693          	slli	a3,a4,0x20
 8c4:	01c6d713          	srli	a4,a3,0x1c
 8c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72a73923          	sd	a0,1842(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8da:	70e2                	ld	ra,56(sp)
 8dc:	7442                	ld	s0,48(sp)
 8de:	74a2                	ld	s1,40(sp)
 8e0:	7902                	ld	s2,32(sp)
 8e2:	69e2                	ld	s3,24(sp)
 8e4:	6a42                	ld	s4,16(sp)
 8e6:	6aa2                	ld	s5,8(sp)
 8e8:	6b02                	ld	s6,0(sp)
 8ea:	6121                	addi	sp,sp,64
 8ec:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ee:	6398                	ld	a4,0(a5)
 8f0:	e118                	sd	a4,0(a0)
 8f2:	bff1                	j	8ce <malloc+0x88>
  hp->s.size = nu;
 8f4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f8:	0541                	addi	a0,a0,16
 8fa:	ecbff0ef          	jal	ra,7c4 <free>
  return freep;
 8fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 902:	dd61                	beqz	a0,8da <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 906:	4798                	lw	a4,8(a5)
 908:	fa9777e3          	bgeu	a4,s1,8b6 <malloc+0x70>
    if(p == freep)
 90c:	00093703          	ld	a4,0(s2)
 910:	853e                	mv	a0,a5
 912:	fef719e3          	bne	a4,a5,904 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 916:	8552                	mv	a0,s4
 918:	a0bff0ef          	jal	ra,322 <sbrk>
  if(p == SBRK_ERROR)
 91c:	fd551ce3          	bne	a0,s5,8f4 <malloc+0xae>
        return 0;
 920:	4501                	li	a0,0
 922:	bf65                	j	8da <malloc+0x94>
