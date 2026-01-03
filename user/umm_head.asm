
user/_umm_head：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"


int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  int len = 3*4096;
  char *p = mmap(0, len, PROT_READ|PROT_WRITE, MAP_ANON, 1);
   a:	4705                	li	a4,1
   c:	4685                	li	a3,1
   e:	460d                	li	a2,3
  10:	658d                	lui	a1,0x3
  12:	4501                	li	a0,0
  14:	3e6000ef          	jal	ra,3fa <mmap>
  if(p == (char*)-1){
  18:	57fd                	li	a5,-1
  1a:	08f50463          	beq	a0,a5,a2 <main+0xa2>
  1e:	84aa                	mv	s1,a0
    printf("mmap failed\n");
    exit(1);
  }

  p[0] = 'A';
  20:	04100793          	li	a5,65
  24:	00f50023          	sb	a5,0(a0)
  p[4096] = 'B';
  28:	6785                	lui	a5,0x1
  2a:	97aa                	add	a5,a5,a0
  2c:	04200713          	li	a4,66
  30:	00e78023          	sb	a4,0(a5) # 1000 <freep>
  p[8192] = 'C';
  34:	6789                	lui	a5,0x2
  36:	97aa                	add	a5,a5,a0
  38:	04300713          	li	a4,67
  3c:	00e78023          	sb	a4,0(a5) # 2000 <base+0xff0>
  printf("before: %c %c %c\n", p[0], p[4096], p[8192]);
  40:	04300693          	li	a3,67
  44:	04200613          	li	a2,66
  48:	04100593          	li	a1,65
  4c:	00001517          	auipc	a0,0x1
  50:	91450513          	addi	a0,a0,-1772 # 960 <malloc+0xf6>
  54:	762000ef          	jal	ra,7b6 <printf>

  // unmap 第一页
  if(munmap(p, 4096) < 0){
  58:	6585                	lui	a1,0x1
  5a:	8526                	mv	a0,s1
  5c:	3a6000ef          	jal	ra,402 <munmap>
  60:	04054a63          	bltz	a0,b4 <main+0xb4>
    printf("munmap failed\n");
    exit(1);
  }

  // 还应该能访问后两页
  printf("after: %c %c\n", p[4096], p[8192]);
  64:	6709                	lui	a4,0x2
  66:	9726                	add	a4,a4,s1
  68:	6785                	lui	a5,0x1
  6a:	97a6                	add	a5,a5,s1
  6c:	00074603          	lbu	a2,0(a4) # 2000 <base+0xff0>
  70:	0007c583          	lbu	a1,0(a5) # 1000 <freep>
  74:	00001517          	auipc	a0,0x1
  78:	91450513          	addi	a0,a0,-1772 # 988 <malloc+0x11e>
  7c:	73a000ef          	jal	ra,7b6 <printf>

  // 这句如果你实现是“访问被 unmap 的页直接 kill”，会导致进程死在这行（正常）
  printf("touch unmapped (should die): %c\n", p[0]);
  80:	0004c583          	lbu	a1,0(s1)
  84:	00001517          	auipc	a0,0x1
  88:	91450513          	addi	a0,a0,-1772 # 998 <malloc+0x12e>
  8c:	72a000ef          	jal	ra,7b6 <printf>

  printf("FAIL: still alive\n");
  90:	00001517          	auipc	a0,0x1
  94:	93050513          	addi	a0,a0,-1744 # 9c0 <malloc+0x156>
  98:	71e000ef          	jal	ra,7b6 <printf>
  exit(0);
  9c:	4501                	li	a0,0
  9e:	2bc000ef          	jal	ra,35a <exit>
    printf("mmap failed\n");
  a2:	00001517          	auipc	a0,0x1
  a6:	8ae50513          	addi	a0,a0,-1874 # 950 <malloc+0xe6>
  aa:	70c000ef          	jal	ra,7b6 <printf>
    exit(1);
  ae:	4505                	li	a0,1
  b0:	2aa000ef          	jal	ra,35a <exit>
    printf("munmap failed\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	8c450513          	addi	a0,a0,-1852 # 978 <malloc+0x10e>
  bc:	6fa000ef          	jal	ra,7b6 <printf>
    exit(1);
  c0:	4505                	li	a0,1
  c2:	298000ef          	jal	ra,35a <exit>

00000000000000c6 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ce:	f33ff0ef          	jal	ra,0 <main>
  exit(r);
  d2:	288000ef          	jal	ra,35a <exit>

00000000000000d6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  dc:	87aa                	mv	a5,a0
  de:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
  e0:	0785                	addi	a5,a5,1
  e2:	fff5c703          	lbu	a4,-1(a1)
  e6:	fee78fa3          	sb	a4,-1(a5)
  ea:	fb75                	bnez	a4,de <strcpy+0x8>
    ;
  return os;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb91                	beqz	a5,110 <strcmp+0x1e>
  fe:	0005c703          	lbu	a4,0(a1)
 102:	00f71763          	bne	a4,a5,110 <strcmp+0x1e>
    p++, q++;
 106:	0505                	addi	a0,a0,1
 108:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbe5                	bnez	a5,fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 110:	0005c503          	lbu	a0,0(a1)
}
 114:	40a7853b          	subw	a0,a5,a0
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strlen>:

uint
strlen(const char *s)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cf91                	beqz	a5,144 <strlen+0x26>
 12a:	0505                	addi	a0,a0,1
 12c:	87aa                	mv	a5,a0
 12e:	4685                	li	a3,1
 130:	9e89                	subw	a3,a3,a0
 132:	00f6853b          	addw	a0,a3,a5
 136:	0785                	addi	a5,a5,1
 138:	fff7c703          	lbu	a4,-1(a5)
 13c:	fb7d                	bnez	a4,132 <strlen+0x14>
    ;
  return n;
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  for(n = 0; s[n]; n++)
 144:	4501                	li	a0,0
 146:	bfe5                	j	13e <strlen+0x20>

0000000000000148 <memset>:

void*
memset(void *dst, int c, uint n)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14e:	ca19                	beqz	a2,164 <memset+0x1c>
 150:	87aa                	mv	a5,a0
 152:	1602                	slli	a2,a2,0x20
 154:	9201                	srli	a2,a2,0x20
 156:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15e:	0785                	addi	a5,a5,1
 160:	fee79de3          	bne	a5,a4,15a <memset+0x12>
  }
  return dst;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strchr>:

char*
strchr(const char *s, char c)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 170:	00054783          	lbu	a5,0(a0)
 174:	cb99                	beqz	a5,18a <strchr+0x20>
    if(*s == c)
 176:	00f58763          	beq	a1,a5,184 <strchr+0x1a>
  for(; *s; s++)
 17a:	0505                	addi	a0,a0,1
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbfd                	bnez	a5,176 <strchr+0xc>
      return (char*)s;
  return 0;
 182:	4501                	li	a0,0
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret
  return 0;
 18a:	4501                	li	a0,0
 18c:	bfe5                	j	184 <strchr+0x1a>

000000000000018e <gets>:

char*
gets(char *buf, int max)
{
 18e:	711d                	addi	sp,sp,-96
 190:	ec86                	sd	ra,88(sp)
 192:	e8a2                	sd	s0,80(sp)
 194:	e4a6                	sd	s1,72(sp)
 196:	e0ca                	sd	s2,64(sp)
 198:	fc4e                	sd	s3,56(sp)
 19a:	f852                	sd	s4,48(sp)
 19c:	f456                	sd	s5,40(sp)
 19e:	f05a                	sd	s6,32(sp)
 1a0:	ec5e                	sd	s7,24(sp)
 1a2:	1080                	addi	s0,sp,96
 1a4:	8baa                	mv	s7,a0
 1a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a8:	892a                	mv	s2,a0
 1aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ac:	4aa9                	li	s5,10
 1ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	2485                	addiw	s1,s1,1
 1b4:	0344d663          	bge	s1,s4,1e0 <gets+0x52>
    cc = read(0, &c, 1);
 1b8:	4605                	li	a2,1
 1ba:	faf40593          	addi	a1,s0,-81
 1be:	4501                	li	a0,0
 1c0:	1b2000ef          	jal	ra,372 <read>
    if(cc < 1)
 1c4:	00a05e63          	blez	a0,1e0 <gets+0x52>
    buf[i++] = c;
 1c8:	faf44783          	lbu	a5,-81(s0)
 1cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d0:	01578763          	beq	a5,s5,1de <gets+0x50>
 1d4:	0905                	addi	s2,s2,1
 1d6:	fd679de3          	bne	a5,s6,1b0 <gets+0x22>
  for(i=0; i+1 < max; ){
 1da:	89a6                	mv	s3,s1
 1dc:	a011                	j	1e0 <gets+0x52>
 1de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e0:	99de                	add	s3,s3,s7
 1e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e6:	855e                	mv	a0,s7
 1e8:	60e6                	ld	ra,88(sp)
 1ea:	6446                	ld	s0,80(sp)
 1ec:	64a6                	ld	s1,72(sp)
 1ee:	6906                	ld	s2,64(sp)
 1f0:	79e2                	ld	s3,56(sp)
 1f2:	7a42                	ld	s4,48(sp)
 1f4:	7aa2                	ld	s5,40(sp)
 1f6:	7b02                	ld	s6,32(sp)
 1f8:	6be2                	ld	s7,24(sp)
 1fa:	6125                	addi	sp,sp,96
 1fc:	8082                	ret

00000000000001fe <stat>:

int
stat(const char *n, struct stat *st)
{
 1fe:	1101                	addi	sp,sp,-32
 200:	ec06                	sd	ra,24(sp)
 202:	e822                	sd	s0,16(sp)
 204:	e426                	sd	s1,8(sp)
 206:	e04a                	sd	s2,0(sp)
 208:	1000                	addi	s0,sp,32
 20a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	4581                	li	a1,0
 20e:	18c000ef          	jal	ra,39a <open>
  if(fd < 0)
 212:	02054163          	bltz	a0,234 <stat+0x36>
 216:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 218:	85ca                	mv	a1,s2
 21a:	198000ef          	jal	ra,3b2 <fstat>
 21e:	892a                	mv	s2,a0
  close(fd);
 220:	8526                	mv	a0,s1
 222:	160000ef          	jal	ra,382 <close>
  return r;
}
 226:	854a                	mv	a0,s2
 228:	60e2                	ld	ra,24(sp)
 22a:	6442                	ld	s0,16(sp)
 22c:	64a2                	ld	s1,8(sp)
 22e:	6902                	ld	s2,0(sp)
 230:	6105                	addi	sp,sp,32
 232:	8082                	ret
    return -1;
 234:	597d                	li	s2,-1
 236:	bfc5                	j	226 <stat+0x28>

0000000000000238 <atoi>:

int
atoi(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23e:	00054683          	lbu	a3,0(a0)
 242:	fd06879b          	addiw	a5,a3,-48
 246:	0ff7f793          	zext.b	a5,a5
 24a:	4625                	li	a2,9
 24c:	02f66863          	bltu	a2,a5,27c <atoi+0x44>
 250:	872a                	mv	a4,a0
  n = 0;
 252:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 254:	0705                	addi	a4,a4,1
 256:	0025179b          	slliw	a5,a0,0x2
 25a:	9fa9                	addw	a5,a5,a0
 25c:	0017979b          	slliw	a5,a5,0x1
 260:	9fb5                	addw	a5,a5,a3
 262:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 266:	00074683          	lbu	a3,0(a4)
 26a:	fd06879b          	addiw	a5,a3,-48
 26e:	0ff7f793          	zext.b	a5,a5
 272:	fef671e3          	bgeu	a2,a5,254 <atoi+0x1c>
  return n;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
  n = 0;
 27c:	4501                	li	a0,0
 27e:	bfe5                	j	276 <atoi+0x3e>

0000000000000280 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 280:	1141                	addi	sp,sp,-16
 282:	e422                	sd	s0,8(sp)
 284:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 286:	02b57463          	bgeu	a0,a1,2ae <memmove+0x2e>
    while(n-- > 0)
 28a:	00c05f63          	blez	a2,2a8 <memmove+0x28>
 28e:	1602                	slli	a2,a2,0x20
 290:	9201                	srli	a2,a2,0x20
 292:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 296:	872a                	mv	a4,a0
      *dst++ = *src++;
 298:	0585                	addi	a1,a1,1
 29a:	0705                	addi	a4,a4,1
 29c:	fff5c683          	lbu	a3,-1(a1)
 2a0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a4:	fee79ae3          	bne	a5,a4,298 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
    dst += n;
 2ae:	00c50733          	add	a4,a0,a2
    src += n;
 2b2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b4:	fec05ae3          	blez	a2,2a8 <memmove+0x28>
 2b8:	fff6079b          	addiw	a5,a2,-1
 2bc:	1782                	slli	a5,a5,0x20
 2be:	9381                	srli	a5,a5,0x20
 2c0:	fff7c793          	not	a5,a5
 2c4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c6:	15fd                	addi	a1,a1,-1
 2c8:	177d                	addi	a4,a4,-1
 2ca:	0005c683          	lbu	a3,0(a1)
 2ce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d2:	fee79ae3          	bne	a5,a4,2c6 <memmove+0x46>
 2d6:	bfc9                	j	2a8 <memmove+0x28>

00000000000002d8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e422                	sd	s0,8(sp)
 2dc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2de:	ca05                	beqz	a2,30e <memcmp+0x36>
 2e0:	fff6069b          	addiw	a3,a2,-1
 2e4:	1682                	slli	a3,a3,0x20
 2e6:	9281                	srli	a3,a3,0x20
 2e8:	0685                	addi	a3,a3,1
 2ea:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	0005c703          	lbu	a4,0(a1)
 2f4:	00e79863          	bne	a5,a4,304 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f8:	0505                	addi	a0,a0,1
    p2++;
 2fa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fc:	fed518e3          	bne	a0,a3,2ec <memcmp+0x14>
  }
  return 0;
 300:	4501                	li	a0,0
 302:	a019                	j	308 <memcmp+0x30>
      return *p1 - *p2;
 304:	40e7853b          	subw	a0,a5,a4
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
  return 0;
 30e:	4501                	li	a0,0
 310:	bfe5                	j	308 <memcmp+0x30>

0000000000000312 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 312:	1141                	addi	sp,sp,-16
 314:	e406                	sd	ra,8(sp)
 316:	e022                	sd	s0,0(sp)
 318:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31a:	f67ff0ef          	jal	ra,280 <memmove>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <sbrk>:

char *
sbrk(int n) {
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32e:	4585                	li	a1,1
 330:	0b2000ef          	jal	ra,3e2 <sys_sbrk>
}
 334:	60a2                	ld	ra,8(sp)
 336:	6402                	ld	s0,0(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret

000000000000033c <sbrklazy>:

char *
sbrklazy(int n) {
 33c:	1141                	addi	sp,sp,-16
 33e:	e406                	sd	ra,8(sp)
 340:	e022                	sd	s0,0(sp)
 342:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 344:	4589                	li	a1,2
 346:	09c000ef          	jal	ra,3e2 <sys_sbrk>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 352:	4885                	li	a7,1
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exit>:
.global exit
exit:
 li a7, SYS_exit
 35a:	4889                	li	a7,2
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <wait>:
.global wait
wait:
 li a7, SYS_wait
 362:	488d                	li	a7,3
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36a:	4891                	li	a7,4
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <read>:
.global read
read:
 li a7, SYS_read
 372:	4895                	li	a7,5
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <write>:
.global write
write:
 li a7, SYS_write
 37a:	48c1                	li	a7,16
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <close>:
.global close
close:
 li a7, SYS_close
 382:	48d5                	li	a7,21
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <kill>:
.global kill
kill:
 li a7, SYS_kill
 38a:	4899                	li	a7,6
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exec>:
.global exec
exec:
 li a7, SYS_exec
 392:	489d                	li	a7,7
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <open>:
.global open
open:
 li a7, SYS_open
 39a:	48bd                	li	a7,15
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a2:	48c5                	li	a7,17
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3aa:	48c9                	li	a7,18
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b2:	48a1                	li	a7,8
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <link>:
.global link
link:
 li a7, SYS_link
 3ba:	48cd                	li	a7,19
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c2:	48d1                	li	a7,20
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ca:	48a5                	li	a7,9
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d2:	48a9                	li	a7,10
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3da:	48ad                	li	a7,11
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e2:	48b1                	li	a7,12
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ea:	48b5                	li	a7,13
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f2:	48b9                	li	a7,14
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3fa:	48d9                	li	a7,22
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 402:	48dd                	li	a7,23
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 40a:	48e1                	li	a7,24
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 412:	48e5                	li	a7,25
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 41a:	48e9                	li	a7,26
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 422:	48ed                	li	a7,27
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 42a:	48f1                	li	a7,28
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 432:	48f5                	li	a7,29
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43a:	1101                	addi	sp,sp,-32
 43c:	ec06                	sd	ra,24(sp)
 43e:	e822                	sd	s0,16(sp)
 440:	1000                	addi	s0,sp,32
 442:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 446:	4605                	li	a2,1
 448:	fef40593          	addi	a1,s0,-17
 44c:	f2fff0ef          	jal	ra,37a <write>
}
 450:	60e2                	ld	ra,24(sp)
 452:	6442                	ld	s0,16(sp)
 454:	6105                	addi	sp,sp,32
 456:	8082                	ret

0000000000000458 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 458:	715d                	addi	sp,sp,-80
 45a:	e486                	sd	ra,72(sp)
 45c:	e0a2                	sd	s0,64(sp)
 45e:	fc26                	sd	s1,56(sp)
 460:	f84a                	sd	s2,48(sp)
 462:	f44e                	sd	s3,40(sp)
 464:	0880                	addi	s0,sp,80
 466:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 468:	c299                	beqz	a3,46e <printint+0x16>
 46a:	0805c163          	bltz	a1,4ec <printint+0x94>
  neg = 0;
 46e:	4881                	li	a7,0
 470:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 474:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 476:	00000517          	auipc	a0,0x0
 47a:	56a50513          	addi	a0,a0,1386 # 9e0 <digits>
 47e:	883e                	mv	a6,a5
 480:	2785                	addiw	a5,a5,1
 482:	02c5f733          	remu	a4,a1,a2
 486:	972a                	add	a4,a4,a0
 488:	00074703          	lbu	a4,0(a4)
 48c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 490:	872e                	mv	a4,a1
 492:	02c5d5b3          	divu	a1,a1,a2
 496:	0685                	addi	a3,a3,1
 498:	fec773e3          	bgeu	a4,a2,47e <printint+0x26>
  if(neg)
 49c:	00088b63          	beqz	a7,4b2 <printint+0x5a>
    buf[i++] = '-';
 4a0:	fd078793          	addi	a5,a5,-48
 4a4:	97a2                	add	a5,a5,s0
 4a6:	02d00713          	li	a4,45
 4aa:	fee78423          	sb	a4,-24(a5)
 4ae:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b2:	02f05663          	blez	a5,4de <printint+0x86>
 4b6:	fb840713          	addi	a4,s0,-72
 4ba:	00f704b3          	add	s1,a4,a5
 4be:	fff70993          	addi	s3,a4,-1
 4c2:	99be                	add	s3,s3,a5
 4c4:	37fd                	addiw	a5,a5,-1
 4c6:	1782                	slli	a5,a5,0x20
 4c8:	9381                	srli	a5,a5,0x20
 4ca:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4ce:	fff4c583          	lbu	a1,-1(s1)
 4d2:	854a                	mv	a0,s2
 4d4:	f67ff0ef          	jal	ra,43a <putc>
  while(--i >= 0)
 4d8:	14fd                	addi	s1,s1,-1
 4da:	ff349ae3          	bne	s1,s3,4ce <printint+0x76>
}
 4de:	60a6                	ld	ra,72(sp)
 4e0:	6406                	ld	s0,64(sp)
 4e2:	74e2                	ld	s1,56(sp)
 4e4:	7942                	ld	s2,48(sp)
 4e6:	79a2                	ld	s3,40(sp)
 4e8:	6161                	addi	sp,sp,80
 4ea:	8082                	ret
    x = -xx;
 4ec:	40b005b3          	neg	a1,a1
    neg = 1;
 4f0:	4885                	li	a7,1
    x = -xx;
 4f2:	bfbd                	j	470 <printint+0x18>

00000000000004f4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f4:	7119                	addi	sp,sp,-128
 4f6:	fc86                	sd	ra,120(sp)
 4f8:	f8a2                	sd	s0,112(sp)
 4fa:	f4a6                	sd	s1,104(sp)
 4fc:	f0ca                	sd	s2,96(sp)
 4fe:	ecce                	sd	s3,88(sp)
 500:	e8d2                	sd	s4,80(sp)
 502:	e4d6                	sd	s5,72(sp)
 504:	e0da                	sd	s6,64(sp)
 506:	fc5e                	sd	s7,56(sp)
 508:	f862                	sd	s8,48(sp)
 50a:	f466                	sd	s9,40(sp)
 50c:	f06a                	sd	s10,32(sp)
 50e:	ec6e                	sd	s11,24(sp)
 510:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 512:	0005c903          	lbu	s2,0(a1)
 516:	24090c63          	beqz	s2,76e <vprintf+0x27a>
 51a:	8b2a                	mv	s6,a0
 51c:	8a2e                	mv	s4,a1
 51e:	8bb2                	mv	s7,a2
  state = 0;
 520:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 522:	4481                	li	s1,0
 524:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 526:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 52a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 52e:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 532:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 536:	00000c97          	auipc	s9,0x0
 53a:	4aac8c93          	addi	s9,s9,1194 # 9e0 <digits>
 53e:	a005                	j	55e <vprintf+0x6a>
        putc(fd, c0);
 540:	85ca                	mv	a1,s2
 542:	855a                	mv	a0,s6
 544:	ef7ff0ef          	jal	ra,43a <putc>
 548:	a019                	j	54e <vprintf+0x5a>
    } else if(state == '%'){
 54a:	03598263          	beq	s3,s5,56e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 54e:	2485                	addiw	s1,s1,1
 550:	8726                	mv	a4,s1
 552:	009a07b3          	add	a5,s4,s1
 556:	0007c903          	lbu	s2,0(a5)
 55a:	20090a63          	beqz	s2,76e <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 55e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 562:	fe0994e3          	bnez	s3,54a <vprintf+0x56>
      if(c0 == '%'){
 566:	fd579de3          	bne	a5,s5,540 <vprintf+0x4c>
        state = '%';
 56a:	89be                	mv	s3,a5
 56c:	b7cd                	j	54e <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 56e:	c3c1                	beqz	a5,5ee <vprintf+0xfa>
 570:	00ea06b3          	add	a3,s4,a4
 574:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 578:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 57a:	c681                	beqz	a3,582 <vprintf+0x8e>
 57c:	9752                	add	a4,a4,s4
 57e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 582:	03878e63          	beq	a5,s8,5be <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 586:	05a78863          	beq	a5,s10,5d6 <vprintf+0xe2>
      } else if(c0 == 'u'){
 58a:	0db78b63          	beq	a5,s11,660 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 58e:	07800713          	li	a4,120
 592:	10e78d63          	beq	a5,a4,6ac <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 596:	07000713          	li	a4,112
 59a:	14e78263          	beq	a5,a4,6de <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 59e:	06300713          	li	a4,99
 5a2:	16e78f63          	beq	a5,a4,720 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5a6:	07300713          	li	a4,115
 5aa:	18e78563          	beq	a5,a4,734 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ae:	05579063          	bne	a5,s5,5ee <vprintf+0xfa>
        putc(fd, '%');
 5b2:	85d6                	mv	a1,s5
 5b4:	855a                	mv	a0,s6
 5b6:	e85ff0ef          	jal	ra,43a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	bf49                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5be:	008b8913          	addi	s2,s7,8
 5c2:	4685                	li	a3,1
 5c4:	4629                	li	a2,10
 5c6:	000ba583          	lw	a1,0(s7)
 5ca:	855a                	mv	a0,s6
 5cc:	e8dff0ef          	jal	ra,458 <printint>
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	bfad                	j	54e <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d6:	03868663          	beq	a3,s8,602 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5da:	05a68163          	beq	a3,s10,61c <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5de:	09b68d63          	beq	a3,s11,678 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e2:	03a68f63          	beq	a3,s10,620 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5e6:	07800793          	li	a5,120
 5ea:	0cf68d63          	beq	a3,a5,6c4 <vprintf+0x1d0>
        putc(fd, '%');
 5ee:	85d6                	mv	a1,s5
 5f0:	855a                	mv	a0,s6
 5f2:	e49ff0ef          	jal	ra,43a <putc>
        putc(fd, c0);
 5f6:	85ca                	mv	a1,s2
 5f8:	855a                	mv	a0,s6
 5fa:	e41ff0ef          	jal	ra,43a <putc>
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b7b9                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 602:	008b8913          	addi	s2,s7,8
 606:	4685                	li	a3,1
 608:	4629                	li	a2,10
 60a:	000bb583          	ld	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	e49ff0ef          	jal	ra,458 <printint>
        i += 1;
 614:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 616:	8bca                	mv	s7,s2
      state = 0;
 618:	4981                	li	s3,0
        i += 1;
 61a:	bf15                	j	54e <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61c:	03860563          	beq	a2,s8,646 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 620:	07b60963          	beq	a2,s11,692 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 624:	07800793          	li	a5,120
 628:	fcf613e3          	bne	a2,a5,5ee <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62c:	008b8913          	addi	s2,s7,8
 630:	4681                	li	a3,0
 632:	4641                	li	a2,16
 634:	000bb583          	ld	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	e1fff0ef          	jal	ra,458 <printint>
        i += 2;
 63e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 640:	8bca                	mv	s7,s2
      state = 0;
 642:	4981                	li	s3,0
        i += 2;
 644:	b729                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 646:	008b8913          	addi	s2,s7,8
 64a:	4685                	li	a3,1
 64c:	4629                	li	a2,10
 64e:	000bb583          	ld	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	e05ff0ef          	jal	ra,458 <printint>
        i += 2;
 658:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
        i += 2;
 65e:	bdc5                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4629                	li	a2,10
 668:	000be583          	lwu	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	debff0ef          	jal	ra,458 <printint>
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
 676:	bde1                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4629                	li	a2,10
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	dd3ff0ef          	jal	ra,458 <printint>
        i += 1;
 68a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 1;
 690:	bd7d                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 692:	008b8913          	addi	s2,s7,8
 696:	4681                	li	a3,0
 698:	4629                	li	a2,10
 69a:	000bb583          	ld	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	db9ff0ef          	jal	ra,458 <printint>
        i += 2;
 6a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
        i += 2;
 6aa:	b555                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4641                	li	a2,16
 6b4:	000be583          	lwu	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	d9fff0ef          	jal	ra,458 <printint>
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b571                	j	54e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4641                	li	a2,16
 6cc:	000bb583          	ld	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	d87ff0ef          	jal	ra,458 <printint>
        i += 1;
 6d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
        i += 1;
 6dc:	bd8d                	j	54e <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6de:	008b8793          	addi	a5,s7,8
 6e2:	f8f43423          	sd	a5,-120(s0)
 6e6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ea:	03000593          	li	a1,48
 6ee:	855a                	mv	a0,s6
 6f0:	d4bff0ef          	jal	ra,43a <putc>
  putc(fd, 'x');
 6f4:	07800593          	li	a1,120
 6f8:	855a                	mv	a0,s6
 6fa:	d41ff0ef          	jal	ra,43a <putc>
 6fe:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 700:	03c9d793          	srli	a5,s3,0x3c
 704:	97e6                	add	a5,a5,s9
 706:	0007c583          	lbu	a1,0(a5)
 70a:	855a                	mv	a0,s6
 70c:	d2fff0ef          	jal	ra,43a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 710:	0992                	slli	s3,s3,0x4
 712:	397d                	addiw	s2,s2,-1
 714:	fe0916e3          	bnez	s2,700 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 718:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bd05                	j	54e <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 720:	008b8913          	addi	s2,s7,8
 724:	000bc583          	lbu	a1,0(s7)
 728:	855a                	mv	a0,s6
 72a:	d11ff0ef          	jal	ra,43a <putc>
 72e:	8bca                	mv	s7,s2
      state = 0;
 730:	4981                	li	s3,0
 732:	bd31                	j	54e <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 734:	008b8993          	addi	s3,s7,8
 738:	000bb903          	ld	s2,0(s7)
 73c:	00090f63          	beqz	s2,75a <vprintf+0x266>
        for(; *s; s++)
 740:	00094583          	lbu	a1,0(s2)
 744:	c195                	beqz	a1,768 <vprintf+0x274>
          putc(fd, *s);
 746:	855a                	mv	a0,s6
 748:	cf3ff0ef          	jal	ra,43a <putc>
        for(; *s; s++)
 74c:	0905                	addi	s2,s2,1
 74e:	00094583          	lbu	a1,0(s2)
 752:	f9f5                	bnez	a1,746 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 754:	8bce                	mv	s7,s3
      state = 0;
 756:	4981                	li	s3,0
 758:	bbdd                	j	54e <vprintf+0x5a>
          s = "(null)";
 75a:	00000917          	auipc	s2,0x0
 75e:	27e90913          	addi	s2,s2,638 # 9d8 <malloc+0x16e>
        for(; *s; s++)
 762:	02800593          	li	a1,40
 766:	b7c5                	j	746 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 768:	8bce                	mv	s7,s3
      state = 0;
 76a:	4981                	li	s3,0
 76c:	b3cd                	j	54e <vprintf+0x5a>
    }
  }
}
 76e:	70e6                	ld	ra,120(sp)
 770:	7446                	ld	s0,112(sp)
 772:	74a6                	ld	s1,104(sp)
 774:	7906                	ld	s2,96(sp)
 776:	69e6                	ld	s3,88(sp)
 778:	6a46                	ld	s4,80(sp)
 77a:	6aa6                	ld	s5,72(sp)
 77c:	6b06                	ld	s6,64(sp)
 77e:	7be2                	ld	s7,56(sp)
 780:	7c42                	ld	s8,48(sp)
 782:	7ca2                	ld	s9,40(sp)
 784:	7d02                	ld	s10,32(sp)
 786:	6de2                	ld	s11,24(sp)
 788:	6109                	addi	sp,sp,128
 78a:	8082                	ret

000000000000078c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 78c:	715d                	addi	sp,sp,-80
 78e:	ec06                	sd	ra,24(sp)
 790:	e822                	sd	s0,16(sp)
 792:	1000                	addi	s0,sp,32
 794:	e010                	sd	a2,0(s0)
 796:	e414                	sd	a3,8(s0)
 798:	e818                	sd	a4,16(s0)
 79a:	ec1c                	sd	a5,24(s0)
 79c:	03043023          	sd	a6,32(s0)
 7a0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a8:	8622                	mv	a2,s0
 7aa:	d4bff0ef          	jal	ra,4f4 <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6161                	addi	sp,sp,80
 7b4:	8082                	ret

00000000000007b6 <printf>:

void
printf(const char *fmt, ...)
{
 7b6:	711d                	addi	sp,sp,-96
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	1000                	addi	s0,sp,32
 7be:	e40c                	sd	a1,8(s0)
 7c0:	e810                	sd	a2,16(s0)
 7c2:	ec14                	sd	a3,24(s0)
 7c4:	f018                	sd	a4,32(s0)
 7c6:	f41c                	sd	a5,40(s0)
 7c8:	03043823          	sd	a6,48(s0)
 7cc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d0:	00840613          	addi	a2,s0,8
 7d4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d8:	85aa                	mv	a1,a0
 7da:	4505                	li	a0,1
 7dc:	d19ff0ef          	jal	ra,4f4 <vprintf>
}
 7e0:	60e2                	ld	ra,24(sp)
 7e2:	6442                	ld	s0,16(sp)
 7e4:	6125                	addi	sp,sp,96
 7e6:	8082                	ret

00000000000007e8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e8:	1141                	addi	sp,sp,-16
 7ea:	e422                	sd	s0,8(sp)
 7ec:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ee:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	00001797          	auipc	a5,0x1
 7f6:	80e7b783          	ld	a5,-2034(a5) # 1000 <freep>
 7fa:	a02d                	j	824 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fc:	4618                	lw	a4,8(a2)
 7fe:	9f2d                	addw	a4,a4,a1
 800:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 804:	6398                	ld	a4,0(a5)
 806:	6310                	ld	a2,0(a4)
 808:	a83d                	j	846 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80a:	ff852703          	lw	a4,-8(a0)
 80e:	9f31                	addw	a4,a4,a2
 810:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 812:	ff053683          	ld	a3,-16(a0)
 816:	a091                	j	85a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 818:	6398                	ld	a4,0(a5)
 81a:	00e7e463          	bltu	a5,a4,822 <free+0x3a>
 81e:	00e6ea63          	bltu	a3,a4,832 <free+0x4a>
{
 822:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 824:	fed7fae3          	bgeu	a5,a3,818 <free+0x30>
 828:	6398                	ld	a4,0(a5)
 82a:	00e6e463          	bltu	a3,a4,832 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82e:	fee7eae3          	bltu	a5,a4,822 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 832:	ff852583          	lw	a1,-8(a0)
 836:	6390                	ld	a2,0(a5)
 838:	02059813          	slli	a6,a1,0x20
 83c:	01c85713          	srli	a4,a6,0x1c
 840:	9736                	add	a4,a4,a3
 842:	fae60de3          	beq	a2,a4,7fc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 846:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84a:	4790                	lw	a2,8(a5)
 84c:	02061593          	slli	a1,a2,0x20
 850:	01c5d713          	srli	a4,a1,0x1c
 854:	973e                	add	a4,a4,a5
 856:	fae68ae3          	beq	a3,a4,80a <free+0x22>
    p->s.ptr = bp->s.ptr;
 85a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 85c:	00000717          	auipc	a4,0x0
 860:	7af73223          	sd	a5,1956(a4) # 1000 <freep>
}
 864:	6422                	ld	s0,8(sp)
 866:	0141                	addi	sp,sp,16
 868:	8082                	ret

000000000000086a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86a:	7139                	addi	sp,sp,-64
 86c:	fc06                	sd	ra,56(sp)
 86e:	f822                	sd	s0,48(sp)
 870:	f426                	sd	s1,40(sp)
 872:	f04a                	sd	s2,32(sp)
 874:	ec4e                	sd	s3,24(sp)
 876:	e852                	sd	s4,16(sp)
 878:	e456                	sd	s5,8(sp)
 87a:	e05a                	sd	s6,0(sp)
 87c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87e:	02051493          	slli	s1,a0,0x20
 882:	9081                	srli	s1,s1,0x20
 884:	04bd                	addi	s1,s1,15
 886:	8091                	srli	s1,s1,0x4
 888:	0014899b          	addiw	s3,s1,1
 88c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 88e:	00000517          	auipc	a0,0x0
 892:	77253503          	ld	a0,1906(a0) # 1000 <freep>
 896:	c515                	beqz	a0,8c2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 898:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89a:	4798                	lw	a4,8(a5)
 89c:	02977f63          	bgeu	a4,s1,8da <malloc+0x70>
 8a0:	8a4e                	mv	s4,s3
 8a2:	0009871b          	sext.w	a4,s3
 8a6:	6685                	lui	a3,0x1
 8a8:	00d77363          	bgeu	a4,a3,8ae <malloc+0x44>
 8ac:	6a05                	lui	s4,0x1
 8ae:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b6:	00000917          	auipc	s2,0x0
 8ba:	74a90913          	addi	s2,s2,1866 # 1000 <freep>
  if(p == SBRK_ERROR)
 8be:	5afd                	li	s5,-1
 8c0:	a885                	j	930 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8c2:	00000797          	auipc	a5,0x0
 8c6:	74e78793          	addi	a5,a5,1870 # 1010 <base>
 8ca:	00000717          	auipc	a4,0x0
 8ce:	72f73b23          	sd	a5,1846(a4) # 1000 <freep>
 8d2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d8:	b7e1                	j	8a0 <malloc+0x36>
      if(p->s.size == nunits)
 8da:	02e48c63          	beq	s1,a4,912 <malloc+0xa8>
        p->s.size -= nunits;
 8de:	4137073b          	subw	a4,a4,s3
 8e2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e4:	02071693          	slli	a3,a4,0x20
 8e8:	01c6d713          	srli	a4,a3,0x1c
 8ec:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ee:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f2:	00000717          	auipc	a4,0x0
 8f6:	70a73723          	sd	a0,1806(a4) # 1000 <freep>
      return (void*)(p + 1);
 8fa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8fe:	70e2                	ld	ra,56(sp)
 900:	7442                	ld	s0,48(sp)
 902:	74a2                	ld	s1,40(sp)
 904:	7902                	ld	s2,32(sp)
 906:	69e2                	ld	s3,24(sp)
 908:	6a42                	ld	s4,16(sp)
 90a:	6aa2                	ld	s5,8(sp)
 90c:	6b02                	ld	s6,0(sp)
 90e:	6121                	addi	sp,sp,64
 910:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 912:	6398                	ld	a4,0(a5)
 914:	e118                	sd	a4,0(a0)
 916:	bff1                	j	8f2 <malloc+0x88>
  hp->s.size = nu;
 918:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 91c:	0541                	addi	a0,a0,16
 91e:	ecbff0ef          	jal	ra,7e8 <free>
  return freep;
 922:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 926:	dd61                	beqz	a0,8fe <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 928:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92a:	4798                	lw	a4,8(a5)
 92c:	fa9777e3          	bgeu	a4,s1,8da <malloc+0x70>
    if(p == freep)
 930:	00093703          	ld	a4,0(s2)
 934:	853e                	mv	a0,a5
 936:	fef719e3          	bne	a4,a5,928 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 93a:	8552                	mv	a0,s4
 93c:	9ebff0ef          	jal	ra,326 <sbrk>
  if(p == SBRK_ERROR)
 940:	fd551ce3          	bne	a0,s5,918 <malloc+0xae>
        return 0;
 944:	4501                	li	a0,0
 946:	bf65                	j	8fe <malloc+0x94>
