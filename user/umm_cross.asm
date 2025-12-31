
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
  68:	92c50513          	addi	a0,a0,-1748 # 990 <malloc+0xf8>
  6c:	778000ef          	jal	ra,7e4 <printf>

  // 从 a 的第二页开始，unmap 3 页：覆盖 a[1页] + (可能的空洞) + b[0页]
  int r = munmap(a + 4096, 3*4096);
  70:	658d                	lui	a1,0x3
  72:	854e                	mv	a0,s3
  74:	3c4000ef          	jal	ra,438 <munmap>
  78:	89aa                	mv	s3,a0
  printf("munmap ret=%d\n", r);
  7a:	85aa                	mv	a1,a0
  7c:	00001517          	auipc	a0,0x1
  80:	92450513          	addi	a0,a0,-1756 # 9a0 <malloc+0x108>
  84:	760000ef          	jal	ra,7e4 <printf>

  if(r < 0){
  88:	0609c163          	bltz	s3,ea <main+0xea>
    exit(0);
  }

  // 支持跨 VMA 时：
  // a[0] 应该还活着
  printf("a0=%c\n", a[0]);
  8c:	0004c583          	lbu	a1,0(s1)
  90:	00001517          	auipc	a0,0x1
  94:	94850513          	addi	a0,a0,-1720 # 9d8 <malloc+0x140>
  98:	74c000ef          	jal	ra,7e4 <printf>

  // a[4096] 已被 unmap（应死）
  printf("touch a[4096] (should die): %c\n", a[4096]);
  9c:	6985                	lui	s3,0x1
  9e:	94ce                	add	s1,s1,s3
  a0:	0004c583          	lbu	a1,0(s1)
  a4:	00001517          	auipc	a0,0x1
  a8:	93c50513          	addi	a0,a0,-1732 # 9e0 <malloc+0x148>
  ac:	738000ef          	jal	ra,7e4 <printf>

  // b[0] 已被 unmap（应死）
  printf("touch b[0] (should die): %c\n", b[0]);
  b0:	00094583          	lbu	a1,0(s2)
  b4:	00001517          	auipc	a0,0x1
  b8:	94c50513          	addi	a0,a0,-1716 # a00 <malloc+0x168>
  bc:	728000ef          	jal	ra,7e4 <printf>

  // b[4096] 可能还活（取决于布局/是否真相邻），但一般会活
  printf("b[4096]=%c\n", b[4096]);
  c0:	994e                	add	s2,s2,s3
  c2:	00094583          	lbu	a1,0(s2)
  c6:	00001517          	auipc	a0,0x1
  ca:	95a50513          	addi	a0,a0,-1702 # a20 <malloc+0x188>
  ce:	716000ef          	jal	ra,7e4 <printf>

  exit(0);
  d2:	4501                	li	a0,0
  d4:	2bc000ef          	jal	ra,390 <exit>
    printf("mmap failed\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	8a850513          	addi	a0,a0,-1880 # 980 <malloc+0xe8>
  e0:	704000ef          	jal	ra,7e4 <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	2aa000ef          	jal	ra,390 <exit>
    printf("OK: cross-VMA munmap not supported\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	8c650513          	addi	a0,a0,-1850 # 9b0 <malloc+0x118>
  f2:	6f2000ef          	jal	ra,7e4 <printf>
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

0000000000000450 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 450:	48e9                	li	a7,26
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 458:	48ed                	li	a7,27
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 460:	48f1                	li	a7,28
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <putc>:

static char digits[] = "0123456789ABCDEF";

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
 47a:	f37ff0ef          	jal	ra,3b0 <write>
}
 47e:	60e2                	ld	ra,24(sp)
 480:	6442                	ld	s0,16(sp)
 482:	6105                	addi	sp,sp,32
 484:	8082                	ret

0000000000000486 <printint>:

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
 4a8:	59450513          	addi	a0,a0,1428 # a38 <digits>
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
 4ce:	fd078793          	addi	a5,a5,-48
 4d2:	97a2                	add	a5,a5,s0
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
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
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
 568:	4d4c8c93          	addi	s9,s9,1236 # a38 <digits>
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
        // Unknown % sequence.  Print it to draw attention.
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
 78c:	2a890913          	addi	s2,s2,680 # a30 <malloc+0x198>
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
static Header base;
static Header *freep;

void
free(void *ap)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	00000797          	auipc	a5,0x0
 824:	7e07b783          	ld	a5,2016(a5) # 1000 <freep>
 828:	a02d                	j	852 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82a:	4618                	lw	a4,8(a2)
 82c:	9f2d                	addw	a4,a4,a1
 82e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	6310                	ld	a2,0(a4)
 836:	a83d                	j	874 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 838:	ff852703          	lw	a4,-8(a0)
 83c:	9f31                	addw	a4,a4,a2
 83e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 840:	ff053683          	ld	a3,-16(a0)
 844:	a091                	j	888 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 846:	6398                	ld	a4,0(a5)
 848:	00e7e463          	bltu	a5,a4,850 <free+0x3a>
 84c:	00e6ea63          	bltu	a3,a4,860 <free+0x4a>
{
 850:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 852:	fed7fae3          	bgeu	a5,a3,846 <free+0x30>
 856:	6398                	ld	a4,0(a5)
 858:	00e6e463          	bltu	a3,a4,860 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85c:	fee7eae3          	bltu	a5,a4,850 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 860:	ff852583          	lw	a1,-8(a0)
 864:	6390                	ld	a2,0(a5)
 866:	02059813          	slli	a6,a1,0x20
 86a:	01c85713          	srli	a4,a6,0x1c
 86e:	9736                	add	a4,a4,a3
 870:	fae60de3          	beq	a2,a4,82a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 874:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 878:	4790                	lw	a2,8(a5)
 87a:	02061593          	slli	a1,a2,0x20
 87e:	01c5d713          	srli	a4,a1,0x1c
 882:	973e                	add	a4,a4,a5
 884:	fae68ae3          	beq	a3,a4,838 <free+0x22>
    p->s.ptr = bp->s.ptr;
 888:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 88a:	00000717          	auipc	a4,0x0
 88e:	76f73b23          	sd	a5,1910(a4) # 1000 <freep>
}
 892:	6422                	ld	s0,8(sp)
 894:	0141                	addi	sp,sp,16
 896:	8082                	ret

0000000000000898 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 898:	7139                	addi	sp,sp,-64
 89a:	fc06                	sd	ra,56(sp)
 89c:	f822                	sd	s0,48(sp)
 89e:	f426                	sd	s1,40(sp)
 8a0:	f04a                	sd	s2,32(sp)
 8a2:	ec4e                	sd	s3,24(sp)
 8a4:	e852                	sd	s4,16(sp)
 8a6:	e456                	sd	s5,8(sp)
 8a8:	e05a                	sd	s6,0(sp)
 8aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ac:	02051493          	slli	s1,a0,0x20
 8b0:	9081                	srli	s1,s1,0x20
 8b2:	04bd                	addi	s1,s1,15
 8b4:	8091                	srli	s1,s1,0x4
 8b6:	0014899b          	addiw	s3,s1,1
 8ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8bc:	00000517          	auipc	a0,0x0
 8c0:	74453503          	ld	a0,1860(a0) # 1000 <freep>
 8c4:	c515                	beqz	a0,8f0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c8:	4798                	lw	a4,8(a5)
 8ca:	02977f63          	bgeu	a4,s1,908 <malloc+0x70>
 8ce:	8a4e                	mv	s4,s3
 8d0:	0009871b          	sext.w	a4,s3
 8d4:	6685                	lui	a3,0x1
 8d6:	00d77363          	bgeu	a4,a3,8dc <malloc+0x44>
 8da:	6a05                	lui	s4,0x1
 8dc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e4:	00000917          	auipc	s2,0x0
 8e8:	71c90913          	addi	s2,s2,1820 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ec:	5afd                	li	s5,-1
 8ee:	a885                	j	95e <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8f0:	00000797          	auipc	a5,0x0
 8f4:	72078793          	addi	a5,a5,1824 # 1010 <base>
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70f73423          	sd	a5,1800(a4) # 1000 <freep>
 900:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 902:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 906:	b7e1                	j	8ce <malloc+0x36>
      if(p->s.size == nunits)
 908:	02e48c63          	beq	s1,a4,940 <malloc+0xa8>
        p->s.size -= nunits;
 90c:	4137073b          	subw	a4,a4,s3
 910:	c798                	sw	a4,8(a5)
        p += p->s.size;
 912:	02071693          	slli	a3,a4,0x20
 916:	01c6d713          	srli	a4,a3,0x1c
 91a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 920:	00000717          	auipc	a4,0x0
 924:	6ea73023          	sd	a0,1760(a4) # 1000 <freep>
      return (void*)(p + 1);
 928:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 92c:	70e2                	ld	ra,56(sp)
 92e:	7442                	ld	s0,48(sp)
 930:	74a2                	ld	s1,40(sp)
 932:	7902                	ld	s2,32(sp)
 934:	69e2                	ld	s3,24(sp)
 936:	6a42                	ld	s4,16(sp)
 938:	6aa2                	ld	s5,8(sp)
 93a:	6b02                	ld	s6,0(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 940:	6398                	ld	a4,0(a5)
 942:	e118                	sd	a4,0(a0)
 944:	bff1                	j	920 <malloc+0x88>
  hp->s.size = nu;
 946:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 94a:	0541                	addi	a0,a0,16
 94c:	ecbff0ef          	jal	ra,816 <free>
  return freep;
 950:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 954:	dd61                	beqz	a0,92c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 956:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 958:	4798                	lw	a4,8(a5)
 95a:	fa9777e3          	bgeu	a4,s1,908 <malloc+0x70>
    if(p == freep)
 95e:	00093703          	ld	a4,0(s2)
 962:	853e                	mv	a0,a5
 964:	fef719e3          	bne	a4,a5,956 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 968:	8552                	mv	a0,s4
 96a:	9f3ff0ef          	jal	ra,35c <sbrk>
  if(p == SBRK_ERROR)
 96e:	fd551ce3          	bne	a0,s5,946 <malloc+0xae>
        return 0;
 972:	4501                	li	a0,0
 974:	bf65                	j	92c <malloc+0x94>
