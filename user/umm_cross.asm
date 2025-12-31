
user/_umm_cross：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"


int
main(void)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  char *a = mmap(0, 2*4096, PROT_READ|PROT_WRITE, MAP_ANON, 1);
   e:	4705                	li	a4,1
  10:	4685                	li	a3,1
  12:	460d                	li	a2,3
  14:	6589                	lui	a1,0x2
  16:	4501                	li	a0,0
  18:	418000ef          	jal	ra,430 <mmap>
  1c:	84aa                	mv	s1,a0
  char *b = mmap(0, 2*4096, PROT_READ|PROT_WRITE, MAP_ANON, 1);
  1e:	4705                	li	a4,1
  20:	4685                	li	a3,1
  22:	460d                	li	a2,3
  24:	6589                	lui	a1,0x2
  26:	4501                	li	a0,0
  28:	408000ef          	jal	ra,430 <mmap>
  if(a == (char*)-1 || b == (char*)-1){
  2c:	57fd                	li	a5,-1
  2e:	0af48563          	beq	s1,a5,d8 <main+0xd8>
  32:	892a                	mv	s2,a0
  34:	0af50263          	beq	a0,a5,d8 <main+0xd8>
    printf("mmap failed\n");
    exit(1);
  }

  a[0] = 'A';
  38:	04100793          	li	a5,65
  3c:	00f48023          	sb	a5,0(s1)
  a[4096] = 'a';
  40:	6785                	lui	a5,0x1
  42:	00f489b3          	add	s3,s1,a5
  46:	06100713          	li	a4,97
  4a:	00e98023          	sb	a4,0(s3)
  b[0] = 'B';
  4e:	04200713          	li	a4,66
  52:	00e50023          	sb	a4,0(a0)
  b[4096] = 'b';
  56:	97aa                	add	a5,a5,a0
  58:	06200713          	li	a4,98
  5c:	00e78023          	sb	a4,0(a5) # 1000 <freep>

  printf("a=%p b=%p\n", a, b);
  60:	862a                	mv	a2,a0
  62:	85a6                	mv	a1,s1
  64:	00001517          	auipc	a0,0x1
  68:	90c50513          	addi	a0,a0,-1780 # 970 <malloc+0xf0>
  6c:	760000ef          	jal	ra,7cc <printf>

  // 从 a 的第二页开始，unmap 3 页：覆盖 a[1页] + (可能的空洞) + b[0页]
  int r = munmap(a + 4096, 3*4096);
  70:	658d                	lui	a1,0x3
  72:	854e                	mv	a0,s3
  74:	3c4000ef          	jal	ra,438 <munmap>
  78:	89aa                	mv	s3,a0
  printf("munmap ret=%d\n", r);
  7a:	85aa                	mv	a1,a0
  7c:	00001517          	auipc	a0,0x1
  80:	90450513          	addi	a0,a0,-1788 # 980 <malloc+0x100>
  84:	748000ef          	jal	ra,7cc <printf>

  if(r < 0){
  88:	0609c163          	bltz	s3,ea <main+0xea>
    exit(0);
  }

  // 支持跨 VMA 时：
  // a[0] 应该还活着
  printf("a0=%c\n", a[0]);
  8c:	0004c583          	lbu	a1,0(s1)
  90:	00001517          	auipc	a0,0x1
  94:	92850513          	addi	a0,a0,-1752 # 9b8 <malloc+0x138>
  98:	734000ef          	jal	ra,7cc <printf>

  // a[4096] 已被 unmap（应死）
  printf("touch a[4096] (should die): %c\n", a[4096]);
  9c:	6985                	lui	s3,0x1
  9e:	94ce                	add	s1,s1,s3
  a0:	0004c583          	lbu	a1,0(s1)
  a4:	00001517          	auipc	a0,0x1
  a8:	91c50513          	addi	a0,a0,-1764 # 9c0 <malloc+0x140>
  ac:	720000ef          	jal	ra,7cc <printf>

  // b[0] 已被 unmap（应死）
  printf("touch b[0] (should die): %c\n", b[0]);
  b0:	00094583          	lbu	a1,0(s2)
  b4:	00001517          	auipc	a0,0x1
  b8:	92c50513          	addi	a0,a0,-1748 # 9e0 <malloc+0x160>
  bc:	710000ef          	jal	ra,7cc <printf>

  // b[4096] 可能还活（取决于布局/是否真相邻），但一般会活
  printf("b[4096]=%c\n", b[4096]);
  c0:	994e                	add	s2,s2,s3
  c2:	00094583          	lbu	a1,0(s2)
  c6:	00001517          	auipc	a0,0x1
  ca:	93a50513          	addi	a0,a0,-1734 # a00 <malloc+0x180>
  ce:	6fe000ef          	jal	ra,7cc <printf>

  exit(0);
  d2:	4501                	li	a0,0
  d4:	2bc000ef          	jal	ra,390 <exit>
    printf("mmap failed\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	88850513          	addi	a0,a0,-1912 # 960 <malloc+0xe0>
  e0:	6ec000ef          	jal	ra,7cc <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	2aa000ef          	jal	ra,390 <exit>
    printf("OK: cross-VMA munmap not supported\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	8a650513          	addi	a0,a0,-1882 # 990 <malloc+0x110>
  f2:	6da000ef          	jal	ra,7cc <printf>
    exit(0);
  f6:	4501                	li	a0,0
  f8:	298000ef          	jal	ra,390 <exit>

00000000000000fc <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e406                	sd	ra,8(sp)
 100:	e022                	sd	s0,0(sp)
 102:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 104:	efdff0ef          	jal	ra,0 <main>
  exit(r);
 108:	288000ef          	jal	ra,390 <exit>

000000000000010c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 112:	87aa                	mv	a5,a0
 114:	0585                	addi	a1,a1,1 # 3001 <base+0x1ff1>
 116:	0785                	addi	a5,a5,1
 118:	fff5c703          	lbu	a4,-1(a1)
 11c:	fee78fa3          	sb	a4,-1(a5)
 120:	fb75                	bnez	a4,114 <strcpy+0x8>
    ;
  return os;
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret

0000000000000128 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cb91                	beqz	a5,146 <strcmp+0x1e>
 134:	0005c703          	lbu	a4,0(a1)
 138:	00f71763          	bne	a4,a5,146 <strcmp+0x1e>
    p++, q++;
 13c:	0505                	addi	a0,a0,1
 13e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 140:	00054783          	lbu	a5,0(a0)
 144:	fbe5                	bnez	a5,134 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 146:	0005c503          	lbu	a0,0(a1)
}
 14a:	40a7853b          	subw	a0,a5,a0
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strlen>:

uint
strlen(const char *s)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cf91                	beqz	a5,17a <strlen+0x26>
 160:	0505                	addi	a0,a0,1
 162:	87aa                	mv	a5,a0
 164:	4685                	li	a3,1
 166:	9e89                	subw	a3,a3,a0
 168:	00f6853b          	addw	a0,a3,a5
 16c:	0785                	addi	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	fb7d                	bnez	a4,168 <strlen+0x14>
    ;
  return n;
}
 174:	6422                	ld	s0,8(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret
  for(n = 0; s[n]; n++)
 17a:	4501                	li	a0,0
 17c:	bfe5                	j	174 <strlen+0x20>

000000000000017e <memset>:

void*
memset(void *dst, int c, uint n)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 184:	ca19                	beqz	a2,19a <memset+0x1c>
 186:	87aa                	mv	a5,a0
 188:	1602                	slli	a2,a2,0x20
 18a:	9201                	srli	a2,a2,0x20
 18c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 190:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 194:	0785                	addi	a5,a5,1
 196:	fee79de3          	bne	a5,a4,190 <memset+0x12>
  }
  return dst;
}
 19a:	6422                	ld	s0,8(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret

00000000000001a0 <strchr>:

char*
strchr(const char *s, char c)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	cb99                	beqz	a5,1c0 <strchr+0x20>
    if(*s == c)
 1ac:	00f58763          	beq	a1,a5,1ba <strchr+0x1a>
  for(; *s; s++)
 1b0:	0505                	addi	a0,a0,1
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	fbfd                	bnez	a5,1ac <strchr+0xc>
      return (char*)s;
  return 0;
 1b8:	4501                	li	a0,0
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret
  return 0;
 1c0:	4501                	li	a0,0
 1c2:	bfe5                	j	1ba <strchr+0x1a>

00000000000001c4 <gets>:

char*
gets(char *buf, int max)
{
 1c4:	711d                	addi	sp,sp,-96
 1c6:	ec86                	sd	ra,88(sp)
 1c8:	e8a2                	sd	s0,80(sp)
 1ca:	e4a6                	sd	s1,72(sp)
 1cc:	e0ca                	sd	s2,64(sp)
 1ce:	fc4e                	sd	s3,56(sp)
 1d0:	f852                	sd	s4,48(sp)
 1d2:	f456                	sd	s5,40(sp)
 1d4:	f05a                	sd	s6,32(sp)
 1d6:	ec5e                	sd	s7,24(sp)
 1d8:	1080                	addi	s0,sp,96
 1da:	8baa                	mv	s7,a0
 1dc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1de:	892a                	mv	s2,a0
 1e0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e2:	4aa9                	li	s5,10
 1e4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e6:	89a6                	mv	s3,s1
 1e8:	2485                	addiw	s1,s1,1
 1ea:	0344d663          	bge	s1,s4,216 <gets+0x52>
    cc = read(0, &c, 1);
 1ee:	4605                	li	a2,1
 1f0:	faf40593          	addi	a1,s0,-81
 1f4:	4501                	li	a0,0
 1f6:	1b2000ef          	jal	ra,3a8 <read>
    if(cc < 1)
 1fa:	00a05e63          	blez	a0,216 <gets+0x52>
    buf[i++] = c;
 1fe:	faf44783          	lbu	a5,-81(s0)
 202:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 206:	01578763          	beq	a5,s5,214 <gets+0x50>
 20a:	0905                	addi	s2,s2,1
 20c:	fd679de3          	bne	a5,s6,1e6 <gets+0x22>
  for(i=0; i+1 < max; ){
 210:	89a6                	mv	s3,s1
 212:	a011                	j	216 <gets+0x52>
 214:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 216:	99de                	add	s3,s3,s7
 218:	00098023          	sb	zero,0(s3) # 1000 <freep>
  return buf;
}
 21c:	855e                	mv	a0,s7
 21e:	60e6                	ld	ra,88(sp)
 220:	6446                	ld	s0,80(sp)
 222:	64a6                	ld	s1,72(sp)
 224:	6906                	ld	s2,64(sp)
 226:	79e2                	ld	s3,56(sp)
 228:	7a42                	ld	s4,48(sp)
 22a:	7aa2                	ld	s5,40(sp)
 22c:	7b02                	ld	s6,32(sp)
 22e:	6be2                	ld	s7,24(sp)
 230:	6125                	addi	sp,sp,96
 232:	8082                	ret

0000000000000234 <stat>:

int
stat(const char *n, struct stat *st)
{
 234:	1101                	addi	sp,sp,-32
 236:	ec06                	sd	ra,24(sp)
 238:	e822                	sd	s0,16(sp)
 23a:	e426                	sd	s1,8(sp)
 23c:	e04a                	sd	s2,0(sp)
 23e:	1000                	addi	s0,sp,32
 240:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 242:	4581                	li	a1,0
 244:	18c000ef          	jal	ra,3d0 <open>
  if(fd < 0)
 248:	02054163          	bltz	a0,26a <stat+0x36>
 24c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24e:	85ca                	mv	a1,s2
 250:	198000ef          	jal	ra,3e8 <fstat>
 254:	892a                	mv	s2,a0
  close(fd);
 256:	8526                	mv	a0,s1
 258:	160000ef          	jal	ra,3b8 <close>
  return r;
}
 25c:	854a                	mv	a0,s2
 25e:	60e2                	ld	ra,24(sp)
 260:	6442                	ld	s0,16(sp)
 262:	64a2                	ld	s1,8(sp)
 264:	6902                	ld	s2,0(sp)
 266:	6105                	addi	sp,sp,32
 268:	8082                	ret
    return -1;
 26a:	597d                	li	s2,-1
 26c:	bfc5                	j	25c <stat+0x28>

000000000000026e <atoi>:

int
atoi(const char *s)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 274:	00054683          	lbu	a3,0(a0)
 278:	fd06879b          	addiw	a5,a3,-48
 27c:	0ff7f793          	zext.b	a5,a5
 280:	4625                	li	a2,9
 282:	02f66863          	bltu	a2,a5,2b2 <atoi+0x44>
 286:	872a                	mv	a4,a0
  n = 0;
 288:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28a:	0705                	addi	a4,a4,1
 28c:	0025179b          	slliw	a5,a0,0x2
 290:	9fa9                	addw	a5,a5,a0
 292:	0017979b          	slliw	a5,a5,0x1
 296:	9fb5                	addw	a5,a5,a3
 298:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29c:	00074683          	lbu	a3,0(a4)
 2a0:	fd06879b          	addiw	a5,a3,-48
 2a4:	0ff7f793          	zext.b	a5,a5
 2a8:	fef671e3          	bgeu	a2,a5,28a <atoi+0x1c>
  return n;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
  n = 0;
 2b2:	4501                	li	a0,0
 2b4:	bfe5                	j	2ac <atoi+0x3e>

00000000000002b6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2bc:	02b57463          	bgeu	a0,a1,2e4 <memmove+0x2e>
    while(n-- > 0)
 2c0:	00c05f63          	blez	a2,2de <memmove+0x28>
 2c4:	1602                	slli	a2,a2,0x20
 2c6:	9201                	srli	a2,a2,0x20
 2c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ce:	0585                	addi	a1,a1,1
 2d0:	0705                	addi	a4,a4,1
 2d2:	fff5c683          	lbu	a3,-1(a1)
 2d6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
    dst += n;
 2e4:	00c50733          	add	a4,a0,a2
    src += n;
 2e8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ea:	fec05ae3          	blez	a2,2de <memmove+0x28>
 2ee:	fff6079b          	addiw	a5,a2,-1
 2f2:	1782                	slli	a5,a5,0x20
 2f4:	9381                	srli	a5,a5,0x20
 2f6:	fff7c793          	not	a5,a5
 2fa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fc:	15fd                	addi	a1,a1,-1
 2fe:	177d                	addi	a4,a4,-1
 300:	0005c683          	lbu	a3,0(a1)
 304:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 308:	fee79ae3          	bne	a5,a4,2fc <memmove+0x46>
 30c:	bfc9                	j	2de <memmove+0x28>

000000000000030e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 314:	ca05                	beqz	a2,344 <memcmp+0x36>
 316:	fff6069b          	addiw	a3,a2,-1
 31a:	1682                	slli	a3,a3,0x20
 31c:	9281                	srli	a3,a3,0x20
 31e:	0685                	addi	a3,a3,1
 320:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 322:	00054783          	lbu	a5,0(a0)
 326:	0005c703          	lbu	a4,0(a1)
 32a:	00e79863          	bne	a5,a4,33a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32e:	0505                	addi	a0,a0,1
    p2++;
 330:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 332:	fed518e3          	bne	a0,a3,322 <memcmp+0x14>
  }
  return 0;
 336:	4501                	li	a0,0
 338:	a019                	j	33e <memcmp+0x30>
      return *p1 - *p2;
 33a:	40e7853b          	subw	a0,a5,a4
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  return 0;
 344:	4501                	li	a0,0
 346:	bfe5                	j	33e <memcmp+0x30>

0000000000000348 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 350:	f67ff0ef          	jal	ra,2b6 <memmove>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <sbrk>:

char *
sbrk(int n) {
 35c:	1141                	addi	sp,sp,-16
 35e:	e406                	sd	ra,8(sp)
 360:	e022                	sd	s0,0(sp)
 362:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 364:	4585                	li	a1,1
 366:	0b2000ef          	jal	ra,418 <sys_sbrk>
}
 36a:	60a2                	ld	ra,8(sp)
 36c:	6402                	ld	s0,0(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <sbrklazy>:

char *
sbrklazy(int n) {
 372:	1141                	addi	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 37a:	4589                	li	a1,2
 37c:	09c000ef          	jal	ra,418 <sys_sbrk>
}
 380:	60a2                	ld	ra,8(sp)
 382:	6402                	ld	s0,0(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 388:	4885                	li	a7,1
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exit>:
.global exit
exit:
 li a7, SYS_exit
 390:	4889                	li	a7,2
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <wait>:
.global wait
wait:
 li a7, SYS_wait
 398:	488d                	li	a7,3
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a0:	4891                	li	a7,4
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <read>:
.global read
read:
 li a7, SYS_read
 3a8:	4895                	li	a7,5
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <write>:
.global write
write:
 li a7, SYS_write
 3b0:	48c1                	li	a7,16
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <close>:
.global close
close:
 li a7, SYS_close
 3b8:	48d5                	li	a7,21
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c0:	4899                	li	a7,6
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c8:	489d                	li	a7,7
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <open>:
.global open
open:
 li a7, SYS_open
 3d0:	48bd                	li	a7,15
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d8:	48c5                	li	a7,17
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e0:	48c9                	li	a7,18
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e8:	48a1                	li	a7,8
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <link>:
.global link
link:
 li a7, SYS_link
 3f0:	48cd                	li	a7,19
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f8:	48d1                	li	a7,20
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 400:	48a5                	li	a7,9
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <dup>:
.global dup
dup:
 li a7, SYS_dup
 408:	48a9                	li	a7,10
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 410:	48ad                	li	a7,11
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 418:	48b1                	li	a7,12
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <pause>:
.global pause
pause:
 li a7, SYS_pause
 420:	48b5                	li	a7,13
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 428:	48b9                	li	a7,14
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 430:	48d9                	li	a7,22
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 438:	48dd                	li	a7,23
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 440:	48e1                	li	a7,24
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 448:	48e5                	li	a7,25
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 450:	1101                	addi	sp,sp,-32
 452:	ec06                	sd	ra,24(sp)
 454:	e822                	sd	s0,16(sp)
 456:	1000                	addi	s0,sp,32
 458:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 45c:	4605                	li	a2,1
 45e:	fef40593          	addi	a1,s0,-17
 462:	f4fff0ef          	jal	ra,3b0 <write>
}
 466:	60e2                	ld	ra,24(sp)
 468:	6442                	ld	s0,16(sp)
 46a:	6105                	addi	sp,sp,32
 46c:	8082                	ret

000000000000046e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 46e:	715d                	addi	sp,sp,-80
 470:	e486                	sd	ra,72(sp)
 472:	e0a2                	sd	s0,64(sp)
 474:	fc26                	sd	s1,56(sp)
 476:	f84a                	sd	s2,48(sp)
 478:	f44e                	sd	s3,40(sp)
 47a:	0880                	addi	s0,sp,80
 47c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 47e:	c299                	beqz	a3,484 <printint+0x16>
 480:	0805c163          	bltz	a1,502 <printint+0x94>
  neg = 0;
 484:	4881                	li	a7,0
 486:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 48a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 48c:	00000517          	auipc	a0,0x0
 490:	58c50513          	addi	a0,a0,1420 # a18 <digits>
 494:	883e                	mv	a6,a5
 496:	2785                	addiw	a5,a5,1
 498:	02c5f733          	remu	a4,a1,a2
 49c:	972a                	add	a4,a4,a0
 49e:	00074703          	lbu	a4,0(a4)
 4a2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4a6:	872e                	mv	a4,a1
 4a8:	02c5d5b3          	divu	a1,a1,a2
 4ac:	0685                	addi	a3,a3,1
 4ae:	fec773e3          	bgeu	a4,a2,494 <printint+0x26>
  if(neg)
 4b2:	00088b63          	beqz	a7,4c8 <printint+0x5a>
    buf[i++] = '-';
 4b6:	fd078793          	addi	a5,a5,-48
 4ba:	97a2                	add	a5,a5,s0
 4bc:	02d00713          	li	a4,45
 4c0:	fee78423          	sb	a4,-24(a5)
 4c4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4c8:	02f05663          	blez	a5,4f4 <printint+0x86>
 4cc:	fb840713          	addi	a4,s0,-72
 4d0:	00f704b3          	add	s1,a4,a5
 4d4:	fff70993          	addi	s3,a4,-1
 4d8:	99be                	add	s3,s3,a5
 4da:	37fd                	addiw	a5,a5,-1
 4dc:	1782                	slli	a5,a5,0x20
 4de:	9381                	srli	a5,a5,0x20
 4e0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4e4:	fff4c583          	lbu	a1,-1(s1)
 4e8:	854a                	mv	a0,s2
 4ea:	f67ff0ef          	jal	ra,450 <putc>
  while(--i >= 0)
 4ee:	14fd                	addi	s1,s1,-1
 4f0:	ff349ae3          	bne	s1,s3,4e4 <printint+0x76>
}
 4f4:	60a6                	ld	ra,72(sp)
 4f6:	6406                	ld	s0,64(sp)
 4f8:	74e2                	ld	s1,56(sp)
 4fa:	7942                	ld	s2,48(sp)
 4fc:	79a2                	ld	s3,40(sp)
 4fe:	6161                	addi	sp,sp,80
 500:	8082                	ret
    x = -xx;
 502:	40b005b3          	neg	a1,a1
    neg = 1;
 506:	4885                	li	a7,1
    x = -xx;
 508:	bfbd                	j	486 <printint+0x18>

000000000000050a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 50a:	7119                	addi	sp,sp,-128
 50c:	fc86                	sd	ra,120(sp)
 50e:	f8a2                	sd	s0,112(sp)
 510:	f4a6                	sd	s1,104(sp)
 512:	f0ca                	sd	s2,96(sp)
 514:	ecce                	sd	s3,88(sp)
 516:	e8d2                	sd	s4,80(sp)
 518:	e4d6                	sd	s5,72(sp)
 51a:	e0da                	sd	s6,64(sp)
 51c:	fc5e                	sd	s7,56(sp)
 51e:	f862                	sd	s8,48(sp)
 520:	f466                	sd	s9,40(sp)
 522:	f06a                	sd	s10,32(sp)
 524:	ec6e                	sd	s11,24(sp)
 526:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 528:	0005c903          	lbu	s2,0(a1)
 52c:	24090c63          	beqz	s2,784 <vprintf+0x27a>
 530:	8b2a                	mv	s6,a0
 532:	8a2e                	mv	s4,a1
 534:	8bb2                	mv	s7,a2
  state = 0;
 536:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 538:	4481                	li	s1,0
 53a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 53c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 540:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 544:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 548:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54c:	00000c97          	auipc	s9,0x0
 550:	4ccc8c93          	addi	s9,s9,1228 # a18 <digits>
 554:	a005                	j	574 <vprintf+0x6a>
        putc(fd, c0);
 556:	85ca                	mv	a1,s2
 558:	855a                	mv	a0,s6
 55a:	ef7ff0ef          	jal	ra,450 <putc>
 55e:	a019                	j	564 <vprintf+0x5a>
    } else if(state == '%'){
 560:	03598263          	beq	s3,s5,584 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 564:	2485                	addiw	s1,s1,1
 566:	8726                	mv	a4,s1
 568:	009a07b3          	add	a5,s4,s1
 56c:	0007c903          	lbu	s2,0(a5)
 570:	20090a63          	beqz	s2,784 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 574:	0009079b          	sext.w	a5,s2
    if(state == 0){
 578:	fe0994e3          	bnez	s3,560 <vprintf+0x56>
      if(c0 == '%'){
 57c:	fd579de3          	bne	a5,s5,556 <vprintf+0x4c>
        state = '%';
 580:	89be                	mv	s3,a5
 582:	b7cd                	j	564 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 584:	c3c1                	beqz	a5,604 <vprintf+0xfa>
 586:	00ea06b3          	add	a3,s4,a4
 58a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 58e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 590:	c681                	beqz	a3,598 <vprintf+0x8e>
 592:	9752                	add	a4,a4,s4
 594:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 598:	03878e63          	beq	a5,s8,5d4 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 59c:	05a78863          	beq	a5,s10,5ec <vprintf+0xe2>
      } else if(c0 == 'u'){
 5a0:	0db78b63          	beq	a5,s11,676 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a4:	07800713          	li	a4,120
 5a8:	10e78d63          	beq	a5,a4,6c2 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ac:	07000713          	li	a4,112
 5b0:	14e78263          	beq	a5,a4,6f4 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5b4:	06300713          	li	a4,99
 5b8:	16e78f63          	beq	a5,a4,736 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5bc:	07300713          	li	a4,115
 5c0:	18e78563          	beq	a5,a4,74a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5c4:	05579063          	bne	a5,s5,604 <vprintf+0xfa>
        putc(fd, '%');
 5c8:	85d6                	mv	a1,s5
 5ca:	855a                	mv	a0,s6
 5cc:	e85ff0ef          	jal	ra,450 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bf49                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d4:	008b8913          	addi	s2,s7,8
 5d8:	4685                	li	a3,1
 5da:	4629                	li	a2,10
 5dc:	000ba583          	lw	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	e8dff0ef          	jal	ra,46e <printint>
 5e6:	8bca                	mv	s7,s2
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	bfad                	j	564 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ec:	03868663          	beq	a3,s8,618 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f0:	05a68163          	beq	a3,s10,632 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5f4:	09b68d63          	beq	a3,s11,68e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f8:	03a68f63          	beq	a3,s10,636 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5fc:	07800793          	li	a5,120
 600:	0cf68d63          	beq	a3,a5,6da <vprintf+0x1d0>
        putc(fd, '%');
 604:	85d6                	mv	a1,s5
 606:	855a                	mv	a0,s6
 608:	e49ff0ef          	jal	ra,450 <putc>
        putc(fd, c0);
 60c:	85ca                	mv	a1,s2
 60e:	855a                	mv	a0,s6
 610:	e41ff0ef          	jal	ra,450 <putc>
      state = 0;
 614:	4981                	li	s3,0
 616:	b7b9                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 618:	008b8913          	addi	s2,s7,8
 61c:	4685                	li	a3,1
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	e49ff0ef          	jal	ra,46e <printint>
        i += 1;
 62a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 1;
 630:	bf15                	j	564 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 632:	03860563          	beq	a2,s8,65c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 636:	07b60963          	beq	a2,s11,6a8 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 63a:	07800793          	li	a5,120
 63e:	fcf613e3          	bne	a2,a5,604 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	008b8913          	addi	s2,s7,8
 646:	4681                	li	a3,0
 648:	4641                	li	a2,16
 64a:	000bb583          	ld	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	e1fff0ef          	jal	ra,46e <printint>
        i += 2;
 654:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 656:	8bca                	mv	s7,s2
      state = 0;
 658:	4981                	li	s3,0
        i += 2;
 65a:	b729                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	008b8913          	addi	s2,s7,8
 660:	4685                	li	a3,1
 662:	4629                	li	a2,10
 664:	000bb583          	ld	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	e05ff0ef          	jal	ra,46e <printint>
        i += 2;
 66e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 670:	8bca                	mv	s7,s2
      state = 0;
 672:	4981                	li	s3,0
        i += 2;
 674:	bdc5                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 676:	008b8913          	addi	s2,s7,8
 67a:	4681                	li	a3,0
 67c:	4629                	li	a2,10
 67e:	000be583          	lwu	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	debff0ef          	jal	ra,46e <printint>
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bde1                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	008b8913          	addi	s2,s7,8
 692:	4681                	li	a3,0
 694:	4629                	li	a2,10
 696:	000bb583          	ld	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	dd3ff0ef          	jal	ra,46e <printint>
        i += 1;
 6a0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a2:	8bca                	mv	s7,s2
      state = 0;
 6a4:	4981                	li	s3,0
        i += 1;
 6a6:	bd7d                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4629                	li	a2,10
 6b0:	000bb583          	ld	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	db9ff0ef          	jal	ra,46e <printint>
        i += 2;
 6ba:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
        i += 2;
 6c0:	b555                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000be583          	lwu	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	d9fff0ef          	jal	ra,46e <printint>
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b571                	j	564 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4641                	li	a2,16
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	d87ff0ef          	jal	ra,46e <printint>
        i += 1;
 6ec:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 1;
 6f2:	bd8d                	j	564 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6f4:	008b8793          	addi	a5,s7,8
 6f8:	f8f43423          	sd	a5,-120(s0)
 6fc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 700:	03000593          	li	a1,48
 704:	855a                	mv	a0,s6
 706:	d4bff0ef          	jal	ra,450 <putc>
  putc(fd, 'x');
 70a:	07800593          	li	a1,120
 70e:	855a                	mv	a0,s6
 710:	d41ff0ef          	jal	ra,450 <putc>
 714:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 716:	03c9d793          	srli	a5,s3,0x3c
 71a:	97e6                	add	a5,a5,s9
 71c:	0007c583          	lbu	a1,0(a5)
 720:	855a                	mv	a0,s6
 722:	d2fff0ef          	jal	ra,450 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 726:	0992                	slli	s3,s3,0x4
 728:	397d                	addiw	s2,s2,-1
 72a:	fe0916e3          	bnez	s2,716 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 72e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 732:	4981                	li	s3,0
 734:	bd05                	j	564 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 736:	008b8913          	addi	s2,s7,8
 73a:	000bc583          	lbu	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	d11ff0ef          	jal	ra,450 <putc>
 744:	8bca                	mv	s7,s2
      state = 0;
 746:	4981                	li	s3,0
 748:	bd31                	j	564 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 74a:	008b8993          	addi	s3,s7,8
 74e:	000bb903          	ld	s2,0(s7)
 752:	00090f63          	beqz	s2,770 <vprintf+0x266>
        for(; *s; s++)
 756:	00094583          	lbu	a1,0(s2)
 75a:	c195                	beqz	a1,77e <vprintf+0x274>
          putc(fd, *s);
 75c:	855a                	mv	a0,s6
 75e:	cf3ff0ef          	jal	ra,450 <putc>
        for(; *s; s++)
 762:	0905                	addi	s2,s2,1
 764:	00094583          	lbu	a1,0(s2)
 768:	f9f5                	bnez	a1,75c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 76a:	8bce                	mv	s7,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bbdd                	j	564 <vprintf+0x5a>
          s = "(null)";
 770:	00000917          	auipc	s2,0x0
 774:	2a090913          	addi	s2,s2,672 # a10 <malloc+0x190>
        for(; *s; s++)
 778:	02800593          	li	a1,40
 77c:	b7c5                	j	75c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 77e:	8bce                	mv	s7,s3
      state = 0;
 780:	4981                	li	s3,0
 782:	b3cd                	j	564 <vprintf+0x5a>
    }
  }
}
 784:	70e6                	ld	ra,120(sp)
 786:	7446                	ld	s0,112(sp)
 788:	74a6                	ld	s1,104(sp)
 78a:	7906                	ld	s2,96(sp)
 78c:	69e6                	ld	s3,88(sp)
 78e:	6a46                	ld	s4,80(sp)
 790:	6aa6                	ld	s5,72(sp)
 792:	6b06                	ld	s6,64(sp)
 794:	7be2                	ld	s7,56(sp)
 796:	7c42                	ld	s8,48(sp)
 798:	7ca2                	ld	s9,40(sp)
 79a:	7d02                	ld	s10,32(sp)
 79c:	6de2                	ld	s11,24(sp)
 79e:	6109                	addi	sp,sp,128
 7a0:	8082                	ret

00000000000007a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a2:	715d                	addi	sp,sp,-80
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e010                	sd	a2,0(s0)
 7ac:	e414                	sd	a3,8(s0)
 7ae:	e818                	sd	a4,16(s0)
 7b0:	ec1c                	sd	a5,24(s0)
 7b2:	03043023          	sd	a6,32(s0)
 7b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7be:	8622                	mv	a2,s0
 7c0:	d4bff0ef          	jal	ra,50a <vprintf>
}
 7c4:	60e2                	ld	ra,24(sp)
 7c6:	6442                	ld	s0,16(sp)
 7c8:	6161                	addi	sp,sp,80
 7ca:	8082                	ret

00000000000007cc <printf>:

void
printf(const char *fmt, ...)
{
 7cc:	711d                	addi	sp,sp,-96
 7ce:	ec06                	sd	ra,24(sp)
 7d0:	e822                	sd	s0,16(sp)
 7d2:	1000                	addi	s0,sp,32
 7d4:	e40c                	sd	a1,8(s0)
 7d6:	e810                	sd	a2,16(s0)
 7d8:	ec14                	sd	a3,24(s0)
 7da:	f018                	sd	a4,32(s0)
 7dc:	f41c                	sd	a5,40(s0)
 7de:	03043823          	sd	a6,48(s0)
 7e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e6:	00840613          	addi	a2,s0,8
 7ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ee:	85aa                	mv	a1,a0
 7f0:	4505                	li	a0,1
 7f2:	d19ff0ef          	jal	ra,50a <vprintf>
}
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	6125                	addi	sp,sp,96
 7fc:	8082                	ret

00000000000007fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fe:	1141                	addi	sp,sp,-16
 800:	e422                	sd	s0,8(sp)
 802:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 804:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 808:	00000797          	auipc	a5,0x0
 80c:	7f87b783          	ld	a5,2040(a5) # 1000 <freep>
 810:	a02d                	j	83a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 812:	4618                	lw	a4,8(a2)
 814:	9f2d                	addw	a4,a4,a1
 816:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 81a:	6398                	ld	a4,0(a5)
 81c:	6310                	ld	a2,0(a4)
 81e:	a83d                	j	85c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 820:	ff852703          	lw	a4,-8(a0)
 824:	9f31                	addw	a4,a4,a2
 826:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 828:	ff053683          	ld	a3,-16(a0)
 82c:	a091                	j	870 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82e:	6398                	ld	a4,0(a5)
 830:	00e7e463          	bltu	a5,a4,838 <free+0x3a>
 834:	00e6ea63          	bltu	a3,a4,848 <free+0x4a>
{
 838:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	fed7fae3          	bgeu	a5,a3,82e <free+0x30>
 83e:	6398                	ld	a4,0(a5)
 840:	00e6e463          	bltu	a3,a4,848 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	fee7eae3          	bltu	a5,a4,838 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 848:	ff852583          	lw	a1,-8(a0)
 84c:	6390                	ld	a2,0(a5)
 84e:	02059813          	slli	a6,a1,0x20
 852:	01c85713          	srli	a4,a6,0x1c
 856:	9736                	add	a4,a4,a3
 858:	fae60de3          	beq	a2,a4,812 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 85c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 860:	4790                	lw	a2,8(a5)
 862:	02061593          	slli	a1,a2,0x20
 866:	01c5d713          	srli	a4,a1,0x1c
 86a:	973e                	add	a4,a4,a5
 86c:	fae68ae3          	beq	a3,a4,820 <free+0x22>
    p->s.ptr = bp->s.ptr;
 870:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 872:	00000717          	auipc	a4,0x0
 876:	78f73723          	sd	a5,1934(a4) # 1000 <freep>
}
 87a:	6422                	ld	s0,8(sp)
 87c:	0141                	addi	sp,sp,16
 87e:	8082                	ret

0000000000000880 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 880:	7139                	addi	sp,sp,-64
 882:	fc06                	sd	ra,56(sp)
 884:	f822                	sd	s0,48(sp)
 886:	f426                	sd	s1,40(sp)
 888:	f04a                	sd	s2,32(sp)
 88a:	ec4e                	sd	s3,24(sp)
 88c:	e852                	sd	s4,16(sp)
 88e:	e456                	sd	s5,8(sp)
 890:	e05a                	sd	s6,0(sp)
 892:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 894:	02051493          	slli	s1,a0,0x20
 898:	9081                	srli	s1,s1,0x20
 89a:	04bd                	addi	s1,s1,15
 89c:	8091                	srli	s1,s1,0x4
 89e:	0014899b          	addiw	s3,s1,1
 8a2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a4:	00000517          	auipc	a0,0x0
 8a8:	75c53503          	ld	a0,1884(a0) # 1000 <freep>
 8ac:	c515                	beqz	a0,8d8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	02977f63          	bgeu	a4,s1,8f0 <malloc+0x70>
 8b6:	8a4e                	mv	s4,s3
 8b8:	0009871b          	sext.w	a4,s3
 8bc:	6685                	lui	a3,0x1
 8be:	00d77363          	bgeu	a4,a3,8c4 <malloc+0x44>
 8c2:	6a05                	lui	s4,0x1
 8c4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8cc:	00000917          	auipc	s2,0x0
 8d0:	73490913          	addi	s2,s2,1844 # 1000 <freep>
  if(p == SBRK_ERROR)
 8d4:	5afd                	li	s5,-1
 8d6:	a885                	j	946 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8d8:	00000797          	auipc	a5,0x0
 8dc:	73878793          	addi	a5,a5,1848 # 1010 <base>
 8e0:	00000717          	auipc	a4,0x0
 8e4:	72f73023          	sd	a5,1824(a4) # 1000 <freep>
 8e8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ee:	b7e1                	j	8b6 <malloc+0x36>
      if(p->s.size == nunits)
 8f0:	02e48c63          	beq	s1,a4,928 <malloc+0xa8>
        p->s.size -= nunits;
 8f4:	4137073b          	subw	a4,a4,s3
 8f8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fa:	02071693          	slli	a3,a4,0x20
 8fe:	01c6d713          	srli	a4,a3,0x1c
 902:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 904:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 908:	00000717          	auipc	a4,0x0
 90c:	6ea73c23          	sd	a0,1784(a4) # 1000 <freep>
      return (void*)(p + 1);
 910:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 914:	70e2                	ld	ra,56(sp)
 916:	7442                	ld	s0,48(sp)
 918:	74a2                	ld	s1,40(sp)
 91a:	7902                	ld	s2,32(sp)
 91c:	69e2                	ld	s3,24(sp)
 91e:	6a42                	ld	s4,16(sp)
 920:	6aa2                	ld	s5,8(sp)
 922:	6b02                	ld	s6,0(sp)
 924:	6121                	addi	sp,sp,64
 926:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 928:	6398                	ld	a4,0(a5)
 92a:	e118                	sd	a4,0(a0)
 92c:	bff1                	j	908 <malloc+0x88>
  hp->s.size = nu;
 92e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 932:	0541                	addi	a0,a0,16
 934:	ecbff0ef          	jal	ra,7fe <free>
  return freep;
 938:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 93c:	dd61                	beqz	a0,914 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 940:	4798                	lw	a4,8(a5)
 942:	fa9777e3          	bgeu	a4,s1,8f0 <malloc+0x70>
    if(p == freep)
 946:	00093703          	ld	a4,0(s2)
 94a:	853e                	mv	a0,a5
 94c:	fef719e3          	bne	a4,a5,93e <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 950:	8552                	mv	a0,s4
 952:	a0bff0ef          	jal	ra,35c <sbrk>
  if(p == SBRK_ERROR)
 956:	fd551ce3          	bne	a0,s5,92e <malloc+0xae>
        return 0;
 95a:	4501                	li	a0,0
 95c:	bf65                	j	914 <malloc+0x94>
