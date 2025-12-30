
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
  char *a = mmap(0, 2*4096, PROT_READ|PROT_WRITE, MAP_ANON);
   e:	4685                	li	a3,1
  10:	460d                	li	a2,3
  12:	6589                	lui	a1,0x2
  14:	4501                	li	a0,0
  16:	416000ef          	jal	ra,42c <mmap>
  1a:	84aa                	mv	s1,a0
  char *b = mmap(0, 2*4096, PROT_READ|PROT_WRITE, MAP_ANON);
  1c:	4685                	li	a3,1
  1e:	460d                	li	a2,3
  20:	6589                	lui	a1,0x2
  22:	4501                	li	a0,0
  24:	408000ef          	jal	ra,42c <mmap>
  if(a == (char*)-1 || b == (char*)-1){
  28:	57fd                	li	a5,-1
  2a:	0af48563          	beq	s1,a5,d4 <main+0xd4>
  2e:	892a                	mv	s2,a0
  30:	0af50263          	beq	a0,a5,d4 <main+0xd4>
    printf("mmap failed\n");
    exit(1);
  }

  a[0] = 'A';
  34:	04100793          	li	a5,65
  38:	00f48023          	sb	a5,0(s1)
  a[4096] = 'a';
  3c:	6785                	lui	a5,0x1
  3e:	00f489b3          	add	s3,s1,a5
  42:	06100713          	li	a4,97
  46:	00e98023          	sb	a4,0(s3)
  b[0] = 'B';
  4a:	04200713          	li	a4,66
  4e:	00e50023          	sb	a4,0(a0)
  b[4096] = 'b';
  52:	97aa                	add	a5,a5,a0
  54:	06200713          	li	a4,98
  58:	00e78023          	sb	a4,0(a5) # 1000 <freep>

  printf("a=%p b=%p\n", a, b);
  5c:	862a                	mv	a2,a0
  5e:	85a6                	mv	a1,s1
  60:	00001517          	auipc	a0,0x1
  64:	90050513          	addi	a0,a0,-1792 # 960 <malloc+0xf4>
  68:	750000ef          	jal	ra,7b8 <printf>

  // 从 a 的第二页开始，unmap 3 页：覆盖 a[1页] + (可能的空洞) + b[0页]
  int r = munmap(a + 4096, 3*4096);
  6c:	658d                	lui	a1,0x3
  6e:	854e                	mv	a0,s3
  70:	3c4000ef          	jal	ra,434 <munmap>
  74:	89aa                	mv	s3,a0
  printf("munmap ret=%d\n", r);
  76:	85aa                	mv	a1,a0
  78:	00001517          	auipc	a0,0x1
  7c:	8f850513          	addi	a0,a0,-1800 # 970 <malloc+0x104>
  80:	738000ef          	jal	ra,7b8 <printf>

  if(r < 0){
  84:	0609c163          	bltz	s3,e6 <main+0xe6>
    exit(0);
  }

  // 支持跨 VMA 时：
  // a[0] 应该还活着
  printf("a0=%c\n", a[0]);
  88:	0004c583          	lbu	a1,0(s1)
  8c:	00001517          	auipc	a0,0x1
  90:	91c50513          	addi	a0,a0,-1764 # 9a8 <malloc+0x13c>
  94:	724000ef          	jal	ra,7b8 <printf>

  // a[4096] 已被 unmap（应死）
  printf("touch a[4096] (should die): %c\n", a[4096]);
  98:	6985                	lui	s3,0x1
  9a:	94ce                	add	s1,s1,s3
  9c:	0004c583          	lbu	a1,0(s1)
  a0:	00001517          	auipc	a0,0x1
  a4:	91050513          	addi	a0,a0,-1776 # 9b0 <malloc+0x144>
  a8:	710000ef          	jal	ra,7b8 <printf>

  // b[0] 已被 unmap（应死）
  printf("touch b[0] (should die): %c\n", b[0]);
  ac:	00094583          	lbu	a1,0(s2)
  b0:	00001517          	auipc	a0,0x1
  b4:	92050513          	addi	a0,a0,-1760 # 9d0 <malloc+0x164>
  b8:	700000ef          	jal	ra,7b8 <printf>

  // b[4096] 可能还活（取决于布局/是否真相邻），但一般会活
  printf("b[4096]=%c\n", b[4096]);
  bc:	994e                	add	s2,s2,s3
  be:	00094583          	lbu	a1,0(s2)
  c2:	00001517          	auipc	a0,0x1
  c6:	92e50513          	addi	a0,a0,-1746 # 9f0 <malloc+0x184>
  ca:	6ee000ef          	jal	ra,7b8 <printf>

  exit(0);
  ce:	4501                	li	a0,0
  d0:	2bc000ef          	jal	ra,38c <exit>
    printf("mmap failed\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	87c50513          	addi	a0,a0,-1924 # 950 <malloc+0xe4>
  dc:	6dc000ef          	jal	ra,7b8 <printf>
    exit(1);
  e0:	4505                	li	a0,1
  e2:	2aa000ef          	jal	ra,38c <exit>
    printf("OK: cross-VMA munmap not supported\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	89a50513          	addi	a0,a0,-1894 # 980 <malloc+0x114>
  ee:	6ca000ef          	jal	ra,7b8 <printf>
    exit(0);
  f2:	4501                	li	a0,0
  f4:	298000ef          	jal	ra,38c <exit>

00000000000000f8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 100:	f01ff0ef          	jal	ra,0 <main>
  exit(r);
 104:	288000ef          	jal	ra,38c <exit>

0000000000000108 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10e:	87aa                	mv	a5,a0
 110:	0585                	addi	a1,a1,1 # 3001 <base+0x1ff1>
 112:	0785                	addi	a5,a5,1
 114:	fff5c703          	lbu	a4,-1(a1)
 118:	fee78fa3          	sb	a4,-1(a5)
 11c:	fb75                	bnez	a4,110 <strcpy+0x8>
    ;
  return os;
}
 11e:	6422                	ld	s0,8(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret

0000000000000124 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	cb91                	beqz	a5,142 <strcmp+0x1e>
 130:	0005c703          	lbu	a4,0(a1)
 134:	00f71763          	bne	a4,a5,142 <strcmp+0x1e>
    p++, q++;
 138:	0505                	addi	a0,a0,1
 13a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13c:	00054783          	lbu	a5,0(a0)
 140:	fbe5                	bnez	a5,130 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 142:	0005c503          	lbu	a0,0(a1)
}
 146:	40a7853b          	subw	a0,a5,a0
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strlen>:

uint
strlen(const char *s)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cf91                	beqz	a5,176 <strlen+0x26>
 15c:	0505                	addi	a0,a0,1
 15e:	87aa                	mv	a5,a0
 160:	4685                	li	a3,1
 162:	9e89                	subw	a3,a3,a0
 164:	00f6853b          	addw	a0,a3,a5
 168:	0785                	addi	a5,a5,1
 16a:	fff7c703          	lbu	a4,-1(a5)
 16e:	fb7d                	bnez	a4,164 <strlen+0x14>
    ;
  return n;
}
 170:	6422                	ld	s0,8(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret
  for(n = 0; s[n]; n++)
 176:	4501                	li	a0,0
 178:	bfe5                	j	170 <strlen+0x20>

000000000000017a <memset>:

void*
memset(void *dst, int c, uint n)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 180:	ca19                	beqz	a2,196 <memset+0x1c>
 182:	87aa                	mv	a5,a0
 184:	1602                	slli	a2,a2,0x20
 186:	9201                	srli	a2,a2,0x20
 188:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 190:	0785                	addi	a5,a5,1
 192:	fee79de3          	bne	a5,a4,18c <memset+0x12>
  }
  return dst;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <strchr>:

char*
strchr(const char *s, char c)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cb99                	beqz	a5,1bc <strchr+0x20>
    if(*s == c)
 1a8:	00f58763          	beq	a1,a5,1b6 <strchr+0x1a>
  for(; *s; s++)
 1ac:	0505                	addi	a0,a0,1
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	fbfd                	bnez	a5,1a8 <strchr+0xc>
      return (char*)s;
  return 0;
 1b4:	4501                	li	a0,0
}
 1b6:	6422                	ld	s0,8(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret
  return 0;
 1bc:	4501                	li	a0,0
 1be:	bfe5                	j	1b6 <strchr+0x1a>

00000000000001c0 <gets>:

char*
gets(char *buf, int max)
{
 1c0:	711d                	addi	sp,sp,-96
 1c2:	ec86                	sd	ra,88(sp)
 1c4:	e8a2                	sd	s0,80(sp)
 1c6:	e4a6                	sd	s1,72(sp)
 1c8:	e0ca                	sd	s2,64(sp)
 1ca:	fc4e                	sd	s3,56(sp)
 1cc:	f852                	sd	s4,48(sp)
 1ce:	f456                	sd	s5,40(sp)
 1d0:	f05a                	sd	s6,32(sp)
 1d2:	ec5e                	sd	s7,24(sp)
 1d4:	1080                	addi	s0,sp,96
 1d6:	8baa                	mv	s7,a0
 1d8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1da:	892a                	mv	s2,a0
 1dc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1de:	4aa9                	li	s5,10
 1e0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e2:	89a6                	mv	s3,s1
 1e4:	2485                	addiw	s1,s1,1
 1e6:	0344d663          	bge	s1,s4,212 <gets+0x52>
    cc = read(0, &c, 1);
 1ea:	4605                	li	a2,1
 1ec:	faf40593          	addi	a1,s0,-81
 1f0:	4501                	li	a0,0
 1f2:	1b2000ef          	jal	ra,3a4 <read>
    if(cc < 1)
 1f6:	00a05e63          	blez	a0,212 <gets+0x52>
    buf[i++] = c;
 1fa:	faf44783          	lbu	a5,-81(s0)
 1fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 202:	01578763          	beq	a5,s5,210 <gets+0x50>
 206:	0905                	addi	s2,s2,1
 208:	fd679de3          	bne	a5,s6,1e2 <gets+0x22>
  for(i=0; i+1 < max; ){
 20c:	89a6                	mv	s3,s1
 20e:	a011                	j	212 <gets+0x52>
 210:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 212:	99de                	add	s3,s3,s7
 214:	00098023          	sb	zero,0(s3) # 1000 <freep>
  return buf;
}
 218:	855e                	mv	a0,s7
 21a:	60e6                	ld	ra,88(sp)
 21c:	6446                	ld	s0,80(sp)
 21e:	64a6                	ld	s1,72(sp)
 220:	6906                	ld	s2,64(sp)
 222:	79e2                	ld	s3,56(sp)
 224:	7a42                	ld	s4,48(sp)
 226:	7aa2                	ld	s5,40(sp)
 228:	7b02                	ld	s6,32(sp)
 22a:	6be2                	ld	s7,24(sp)
 22c:	6125                	addi	sp,sp,96
 22e:	8082                	ret

0000000000000230 <stat>:

int
stat(const char *n, struct stat *st)
{
 230:	1101                	addi	sp,sp,-32
 232:	ec06                	sd	ra,24(sp)
 234:	e822                	sd	s0,16(sp)
 236:	e426                	sd	s1,8(sp)
 238:	e04a                	sd	s2,0(sp)
 23a:	1000                	addi	s0,sp,32
 23c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23e:	4581                	li	a1,0
 240:	18c000ef          	jal	ra,3cc <open>
  if(fd < 0)
 244:	02054163          	bltz	a0,266 <stat+0x36>
 248:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24a:	85ca                	mv	a1,s2
 24c:	198000ef          	jal	ra,3e4 <fstat>
 250:	892a                	mv	s2,a0
  close(fd);
 252:	8526                	mv	a0,s1
 254:	160000ef          	jal	ra,3b4 <close>
  return r;
}
 258:	854a                	mv	a0,s2
 25a:	60e2                	ld	ra,24(sp)
 25c:	6442                	ld	s0,16(sp)
 25e:	64a2                	ld	s1,8(sp)
 260:	6902                	ld	s2,0(sp)
 262:	6105                	addi	sp,sp,32
 264:	8082                	ret
    return -1;
 266:	597d                	li	s2,-1
 268:	bfc5                	j	258 <stat+0x28>

000000000000026a <atoi>:

int
atoi(const char *s)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 270:	00054683          	lbu	a3,0(a0)
 274:	fd06879b          	addiw	a5,a3,-48
 278:	0ff7f793          	zext.b	a5,a5
 27c:	4625                	li	a2,9
 27e:	02f66863          	bltu	a2,a5,2ae <atoi+0x44>
 282:	872a                	mv	a4,a0
  n = 0;
 284:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 286:	0705                	addi	a4,a4,1
 288:	0025179b          	slliw	a5,a0,0x2
 28c:	9fa9                	addw	a5,a5,a0
 28e:	0017979b          	slliw	a5,a5,0x1
 292:	9fb5                	addw	a5,a5,a3
 294:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 298:	00074683          	lbu	a3,0(a4)
 29c:	fd06879b          	addiw	a5,a3,-48
 2a0:	0ff7f793          	zext.b	a5,a5
 2a4:	fef671e3          	bgeu	a2,a5,286 <atoi+0x1c>
  return n;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  n = 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <atoi+0x3e>

00000000000002b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b8:	02b57463          	bgeu	a0,a1,2e0 <memmove+0x2e>
    while(n-- > 0)
 2bc:	00c05f63          	blez	a2,2da <memmove+0x28>
 2c0:	1602                	slli	a2,a2,0x20
 2c2:	9201                	srli	a2,a2,0x20
 2c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ca:	0585                	addi	a1,a1,1
 2cc:	0705                	addi	a4,a4,1
 2ce:	fff5c683          	lbu	a3,-1(a1)
 2d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d6:	fee79ae3          	bne	a5,a4,2ca <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
    dst += n;
 2e0:	00c50733          	add	a4,a0,a2
    src += n;
 2e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e6:	fec05ae3          	blez	a2,2da <memmove+0x28>
 2ea:	fff6079b          	addiw	a5,a2,-1
 2ee:	1782                	slli	a5,a5,0x20
 2f0:	9381                	srli	a5,a5,0x20
 2f2:	fff7c793          	not	a5,a5
 2f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f8:	15fd                	addi	a1,a1,-1
 2fa:	177d                	addi	a4,a4,-1
 2fc:	0005c683          	lbu	a3,0(a1)
 300:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 304:	fee79ae3          	bne	a5,a4,2f8 <memmove+0x46>
 308:	bfc9                	j	2da <memmove+0x28>

000000000000030a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 310:	ca05                	beqz	a2,340 <memcmp+0x36>
 312:	fff6069b          	addiw	a3,a2,-1
 316:	1682                	slli	a3,a3,0x20
 318:	9281                	srli	a3,a3,0x20
 31a:	0685                	addi	a3,a3,1
 31c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31e:	00054783          	lbu	a5,0(a0)
 322:	0005c703          	lbu	a4,0(a1)
 326:	00e79863          	bne	a5,a4,336 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32a:	0505                	addi	a0,a0,1
    p2++;
 32c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32e:	fed518e3          	bne	a0,a3,31e <memcmp+0x14>
  }
  return 0;
 332:	4501                	li	a0,0
 334:	a019                	j	33a <memcmp+0x30>
      return *p1 - *p2;
 336:	40e7853b          	subw	a0,a5,a4
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
  return 0;
 340:	4501                	li	a0,0
 342:	bfe5                	j	33a <memcmp+0x30>

0000000000000344 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 344:	1141                	addi	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34c:	f67ff0ef          	jal	ra,2b2 <memmove>
}
 350:	60a2                	ld	ra,8(sp)
 352:	6402                	ld	s0,0(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret

0000000000000358 <sbrk>:

char *
sbrk(int n) {
 358:	1141                	addi	sp,sp,-16
 35a:	e406                	sd	ra,8(sp)
 35c:	e022                	sd	s0,0(sp)
 35e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 360:	4585                	li	a1,1
 362:	0b2000ef          	jal	ra,414 <sys_sbrk>
}
 366:	60a2                	ld	ra,8(sp)
 368:	6402                	ld	s0,0(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret

000000000000036e <sbrklazy>:

char *
sbrklazy(int n) {
 36e:	1141                	addi	sp,sp,-16
 370:	e406                	sd	ra,8(sp)
 372:	e022                	sd	s0,0(sp)
 374:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 376:	4589                	li	a1,2
 378:	09c000ef          	jal	ra,414 <sys_sbrk>
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret

0000000000000384 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 384:	4885                	li	a7,1
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <exit>:
.global exit
exit:
 li a7, SYS_exit
 38c:	4889                	li	a7,2
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <wait>:
.global wait
wait:
 li a7, SYS_wait
 394:	488d                	li	a7,3
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39c:	4891                	li	a7,4
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <read>:
.global read
read:
 li a7, SYS_read
 3a4:	4895                	li	a7,5
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <write>:
.global write
write:
 li a7, SYS_write
 3ac:	48c1                	li	a7,16
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <close>:
.global close
close:
 li a7, SYS_close
 3b4:	48d5                	li	a7,21
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3bc:	4899                	li	a7,6
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c4:	489d                	li	a7,7
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <open>:
.global open
open:
 li a7, SYS_open
 3cc:	48bd                	li	a7,15
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d4:	48c5                	li	a7,17
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3dc:	48c9                	li	a7,18
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e4:	48a1                	li	a7,8
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <link>:
.global link
link:
 li a7, SYS_link
 3ec:	48cd                	li	a7,19
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f4:	48d1                	li	a7,20
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fc:	48a5                	li	a7,9
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <dup>:
.global dup
dup:
 li a7, SYS_dup
 404:	48a9                	li	a7,10
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40c:	48ad                	li	a7,11
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 414:	48b1                	li	a7,12
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <pause>:
.global pause
pause:
 li a7, SYS_pause
 41c:	48b5                	li	a7,13
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 424:	48b9                	li	a7,14
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 42c:	48d9                	li	a7,22
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 434:	48dd                	li	a7,23
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43c:	1101                	addi	sp,sp,-32
 43e:	ec06                	sd	ra,24(sp)
 440:	e822                	sd	s0,16(sp)
 442:	1000                	addi	s0,sp,32
 444:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 448:	4605                	li	a2,1
 44a:	fef40593          	addi	a1,s0,-17
 44e:	f5fff0ef          	jal	ra,3ac <write>
}
 452:	60e2                	ld	ra,24(sp)
 454:	6442                	ld	s0,16(sp)
 456:	6105                	addi	sp,sp,32
 458:	8082                	ret

000000000000045a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 45a:	715d                	addi	sp,sp,-80
 45c:	e486                	sd	ra,72(sp)
 45e:	e0a2                	sd	s0,64(sp)
 460:	fc26                	sd	s1,56(sp)
 462:	f84a                	sd	s2,48(sp)
 464:	f44e                	sd	s3,40(sp)
 466:	0880                	addi	s0,sp,80
 468:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 46a:	c299                	beqz	a3,470 <printint+0x16>
 46c:	0805c163          	bltz	a1,4ee <printint+0x94>
  neg = 0;
 470:	4881                	li	a7,0
 472:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 476:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 478:	00000517          	auipc	a0,0x0
 47c:	59050513          	addi	a0,a0,1424 # a08 <digits>
 480:	883e                	mv	a6,a5
 482:	2785                	addiw	a5,a5,1
 484:	02c5f733          	remu	a4,a1,a2
 488:	972a                	add	a4,a4,a0
 48a:	00074703          	lbu	a4,0(a4)
 48e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 492:	872e                	mv	a4,a1
 494:	02c5d5b3          	divu	a1,a1,a2
 498:	0685                	addi	a3,a3,1
 49a:	fec773e3          	bgeu	a4,a2,480 <printint+0x26>
  if(neg)
 49e:	00088b63          	beqz	a7,4b4 <printint+0x5a>
    buf[i++] = '-';
 4a2:	fd078793          	addi	a5,a5,-48
 4a6:	97a2                	add	a5,a5,s0
 4a8:	02d00713          	li	a4,45
 4ac:	fee78423          	sb	a4,-24(a5)
 4b0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b4:	02f05663          	blez	a5,4e0 <printint+0x86>
 4b8:	fb840713          	addi	a4,s0,-72
 4bc:	00f704b3          	add	s1,a4,a5
 4c0:	fff70993          	addi	s3,a4,-1
 4c4:	99be                	add	s3,s3,a5
 4c6:	37fd                	addiw	a5,a5,-1
 4c8:	1782                	slli	a5,a5,0x20
 4ca:	9381                	srli	a5,a5,0x20
 4cc:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4d0:	fff4c583          	lbu	a1,-1(s1)
 4d4:	854a                	mv	a0,s2
 4d6:	f67ff0ef          	jal	ra,43c <putc>
  while(--i >= 0)
 4da:	14fd                	addi	s1,s1,-1
 4dc:	ff349ae3          	bne	s1,s3,4d0 <printint+0x76>
}
 4e0:	60a6                	ld	ra,72(sp)
 4e2:	6406                	ld	s0,64(sp)
 4e4:	74e2                	ld	s1,56(sp)
 4e6:	7942                	ld	s2,48(sp)
 4e8:	79a2                	ld	s3,40(sp)
 4ea:	6161                	addi	sp,sp,80
 4ec:	8082                	ret
    x = -xx;
 4ee:	40b005b3          	neg	a1,a1
    neg = 1;
 4f2:	4885                	li	a7,1
    x = -xx;
 4f4:	bfbd                	j	472 <printint+0x18>

00000000000004f6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f6:	7119                	addi	sp,sp,-128
 4f8:	fc86                	sd	ra,120(sp)
 4fa:	f8a2                	sd	s0,112(sp)
 4fc:	f4a6                	sd	s1,104(sp)
 4fe:	f0ca                	sd	s2,96(sp)
 500:	ecce                	sd	s3,88(sp)
 502:	e8d2                	sd	s4,80(sp)
 504:	e4d6                	sd	s5,72(sp)
 506:	e0da                	sd	s6,64(sp)
 508:	fc5e                	sd	s7,56(sp)
 50a:	f862                	sd	s8,48(sp)
 50c:	f466                	sd	s9,40(sp)
 50e:	f06a                	sd	s10,32(sp)
 510:	ec6e                	sd	s11,24(sp)
 512:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 514:	0005c903          	lbu	s2,0(a1)
 518:	24090c63          	beqz	s2,770 <vprintf+0x27a>
 51c:	8b2a                	mv	s6,a0
 51e:	8a2e                	mv	s4,a1
 520:	8bb2                	mv	s7,a2
  state = 0;
 522:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 524:	4481                	li	s1,0
 526:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 528:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 52c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 530:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 534:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 538:	00000c97          	auipc	s9,0x0
 53c:	4d0c8c93          	addi	s9,s9,1232 # a08 <digits>
 540:	a005                	j	560 <vprintf+0x6a>
        putc(fd, c0);
 542:	85ca                	mv	a1,s2
 544:	855a                	mv	a0,s6
 546:	ef7ff0ef          	jal	ra,43c <putc>
 54a:	a019                	j	550 <vprintf+0x5a>
    } else if(state == '%'){
 54c:	03598263          	beq	s3,s5,570 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 550:	2485                	addiw	s1,s1,1
 552:	8726                	mv	a4,s1
 554:	009a07b3          	add	a5,s4,s1
 558:	0007c903          	lbu	s2,0(a5)
 55c:	20090a63          	beqz	s2,770 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 560:	0009079b          	sext.w	a5,s2
    if(state == 0){
 564:	fe0994e3          	bnez	s3,54c <vprintf+0x56>
      if(c0 == '%'){
 568:	fd579de3          	bne	a5,s5,542 <vprintf+0x4c>
        state = '%';
 56c:	89be                	mv	s3,a5
 56e:	b7cd                	j	550 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 570:	c3c1                	beqz	a5,5f0 <vprintf+0xfa>
 572:	00ea06b3          	add	a3,s4,a4
 576:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 57a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 57c:	c681                	beqz	a3,584 <vprintf+0x8e>
 57e:	9752                	add	a4,a4,s4
 580:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 584:	03878e63          	beq	a5,s8,5c0 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 588:	05a78863          	beq	a5,s10,5d8 <vprintf+0xe2>
      } else if(c0 == 'u'){
 58c:	0db78b63          	beq	a5,s11,662 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 590:	07800713          	li	a4,120
 594:	10e78d63          	beq	a5,a4,6ae <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 598:	07000713          	li	a4,112
 59c:	14e78263          	beq	a5,a4,6e0 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5a0:	06300713          	li	a4,99
 5a4:	16e78f63          	beq	a5,a4,722 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5a8:	07300713          	li	a4,115
 5ac:	18e78563          	beq	a5,a4,736 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5b0:	05579063          	bne	a5,s5,5f0 <vprintf+0xfa>
        putc(fd, '%');
 5b4:	85d6                	mv	a1,s5
 5b6:	855a                	mv	a0,s6
 5b8:	e85ff0ef          	jal	ra,43c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5bc:	4981                	li	s3,0
 5be:	bf49                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4685                	li	a3,1
 5c6:	4629                	li	a2,10
 5c8:	000ba583          	lw	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	e8dff0ef          	jal	ra,45a <printint>
 5d2:	8bca                	mv	s7,s2
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	bfad                	j	550 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d8:	03868663          	beq	a3,s8,604 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5dc:	05a68163          	beq	a3,s10,61e <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5e0:	09b68d63          	beq	a3,s11,67a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e4:	03a68f63          	beq	a3,s10,622 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5e8:	07800793          	li	a5,120
 5ec:	0cf68d63          	beq	a3,a5,6c6 <vprintf+0x1d0>
        putc(fd, '%');
 5f0:	85d6                	mv	a1,s5
 5f2:	855a                	mv	a0,s6
 5f4:	e49ff0ef          	jal	ra,43c <putc>
        putc(fd, c0);
 5f8:	85ca                	mv	a1,s2
 5fa:	855a                	mv	a0,s6
 5fc:	e41ff0ef          	jal	ra,43c <putc>
      state = 0;
 600:	4981                	li	s3,0
 602:	b7b9                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 604:	008b8913          	addi	s2,s7,8
 608:	4685                	li	a3,1
 60a:	4629                	li	a2,10
 60c:	000bb583          	ld	a1,0(s7)
 610:	855a                	mv	a0,s6
 612:	e49ff0ef          	jal	ra,45a <printint>
        i += 1;
 616:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
        i += 1;
 61c:	bf15                	j	550 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61e:	03860563          	beq	a2,s8,648 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 622:	07b60963          	beq	a2,s11,694 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 626:	07800793          	li	a5,120
 62a:	fcf613e3          	bne	a2,a5,5f0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	008b8913          	addi	s2,s7,8
 632:	4681                	li	a3,0
 634:	4641                	li	a2,16
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e1fff0ef          	jal	ra,45a <printint>
        i += 2;
 640:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	b729                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	008b8913          	addi	s2,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e05ff0ef          	jal	ra,45a <printint>
        i += 2;
 65a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	bdc5                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4629                	li	a2,10
 66a:	000be583          	lwu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	debff0ef          	jal	ra,45a <printint>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	bde1                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	dd3ff0ef          	jal	ra,45a <printint>
        i += 1;
 68c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 1;
 692:	bd7d                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	db9ff0ef          	jal	ra,45a <printint>
        i += 2;
 6a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	b555                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4641                	li	a2,16
 6b6:	000be583          	lwu	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	d9fff0ef          	jal	ra,45a <printint>
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b571                	j	550 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4641                	li	a2,16
 6ce:	000bb583          	ld	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	d87ff0ef          	jal	ra,45a <printint>
        i += 1;
 6d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
        i += 1;
 6de:	bd8d                	j	550 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6e0:	008b8793          	addi	a5,s7,8
 6e4:	f8f43423          	sd	a5,-120(s0)
 6e8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ec:	03000593          	li	a1,48
 6f0:	855a                	mv	a0,s6
 6f2:	d4bff0ef          	jal	ra,43c <putc>
  putc(fd, 'x');
 6f6:	07800593          	li	a1,120
 6fa:	855a                	mv	a0,s6
 6fc:	d41ff0ef          	jal	ra,43c <putc>
 700:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 702:	03c9d793          	srli	a5,s3,0x3c
 706:	97e6                	add	a5,a5,s9
 708:	0007c583          	lbu	a1,0(a5)
 70c:	855a                	mv	a0,s6
 70e:	d2fff0ef          	jal	ra,43c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 712:	0992                	slli	s3,s3,0x4
 714:	397d                	addiw	s2,s2,-1
 716:	fe0916e3          	bnez	s2,702 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 71a:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 71e:	4981                	li	s3,0
 720:	bd05                	j	550 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 722:	008b8913          	addi	s2,s7,8
 726:	000bc583          	lbu	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	d11ff0ef          	jal	ra,43c <putc>
 730:	8bca                	mv	s7,s2
      state = 0;
 732:	4981                	li	s3,0
 734:	bd31                	j	550 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 736:	008b8993          	addi	s3,s7,8
 73a:	000bb903          	ld	s2,0(s7)
 73e:	00090f63          	beqz	s2,75c <vprintf+0x266>
        for(; *s; s++)
 742:	00094583          	lbu	a1,0(s2)
 746:	c195                	beqz	a1,76a <vprintf+0x274>
          putc(fd, *s);
 748:	855a                	mv	a0,s6
 74a:	cf3ff0ef          	jal	ra,43c <putc>
        for(; *s; s++)
 74e:	0905                	addi	s2,s2,1
 750:	00094583          	lbu	a1,0(s2)
 754:	f9f5                	bnez	a1,748 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 756:	8bce                	mv	s7,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	bbdd                	j	550 <vprintf+0x5a>
          s = "(null)";
 75c:	00000917          	auipc	s2,0x0
 760:	2a490913          	addi	s2,s2,676 # a00 <malloc+0x194>
        for(; *s; s++)
 764:	02800593          	li	a1,40
 768:	b7c5                	j	748 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 76a:	8bce                	mv	s7,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b3cd                	j	550 <vprintf+0x5a>
    }
  }
}
 770:	70e6                	ld	ra,120(sp)
 772:	7446                	ld	s0,112(sp)
 774:	74a6                	ld	s1,104(sp)
 776:	7906                	ld	s2,96(sp)
 778:	69e6                	ld	s3,88(sp)
 77a:	6a46                	ld	s4,80(sp)
 77c:	6aa6                	ld	s5,72(sp)
 77e:	6b06                	ld	s6,64(sp)
 780:	7be2                	ld	s7,56(sp)
 782:	7c42                	ld	s8,48(sp)
 784:	7ca2                	ld	s9,40(sp)
 786:	7d02                	ld	s10,32(sp)
 788:	6de2                	ld	s11,24(sp)
 78a:	6109                	addi	sp,sp,128
 78c:	8082                	ret

000000000000078e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 78e:	715d                	addi	sp,sp,-80
 790:	ec06                	sd	ra,24(sp)
 792:	e822                	sd	s0,16(sp)
 794:	1000                	addi	s0,sp,32
 796:	e010                	sd	a2,0(s0)
 798:	e414                	sd	a3,8(s0)
 79a:	e818                	sd	a4,16(s0)
 79c:	ec1c                	sd	a5,24(s0)
 79e:	03043023          	sd	a6,32(s0)
 7a2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7aa:	8622                	mv	a2,s0
 7ac:	d4bff0ef          	jal	ra,4f6 <vprintf>
}
 7b0:	60e2                	ld	ra,24(sp)
 7b2:	6442                	ld	s0,16(sp)
 7b4:	6161                	addi	sp,sp,80
 7b6:	8082                	ret

00000000000007b8 <printf>:

void
printf(const char *fmt, ...)
{
 7b8:	711d                	addi	sp,sp,-96
 7ba:	ec06                	sd	ra,24(sp)
 7bc:	e822                	sd	s0,16(sp)
 7be:	1000                	addi	s0,sp,32
 7c0:	e40c                	sd	a1,8(s0)
 7c2:	e810                	sd	a2,16(s0)
 7c4:	ec14                	sd	a3,24(s0)
 7c6:	f018                	sd	a4,32(s0)
 7c8:	f41c                	sd	a5,40(s0)
 7ca:	03043823          	sd	a6,48(s0)
 7ce:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d2:	00840613          	addi	a2,s0,8
 7d6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7da:	85aa                	mv	a1,a0
 7dc:	4505                	li	a0,1
 7de:	d19ff0ef          	jal	ra,4f6 <vprintf>
}
 7e2:	60e2                	ld	ra,24(sp)
 7e4:	6442                	ld	s0,16(sp)
 7e6:	6125                	addi	sp,sp,96
 7e8:	8082                	ret

00000000000007ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ea:	1141                	addi	sp,sp,-16
 7ec:	e422                	sd	s0,8(sp)
 7ee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f4:	00001797          	auipc	a5,0x1
 7f8:	80c7b783          	ld	a5,-2036(a5) # 1000 <freep>
 7fc:	a02d                	j	826 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fe:	4618                	lw	a4,8(a2)
 800:	9f2d                	addw	a4,a4,a1
 802:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 806:	6398                	ld	a4,0(a5)
 808:	6310                	ld	a2,0(a4)
 80a:	a83d                	j	848 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80c:	ff852703          	lw	a4,-8(a0)
 810:	9f31                	addw	a4,a4,a2
 812:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 814:	ff053683          	ld	a3,-16(a0)
 818:	a091                	j	85c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81a:	6398                	ld	a4,0(a5)
 81c:	00e7e463          	bltu	a5,a4,824 <free+0x3a>
 820:	00e6ea63          	bltu	a3,a4,834 <free+0x4a>
{
 824:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 826:	fed7fae3          	bgeu	a5,a3,81a <free+0x30>
 82a:	6398                	ld	a4,0(a5)
 82c:	00e6e463          	bltu	a3,a4,834 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 830:	fee7eae3          	bltu	a5,a4,824 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 834:	ff852583          	lw	a1,-8(a0)
 838:	6390                	ld	a2,0(a5)
 83a:	02059813          	slli	a6,a1,0x20
 83e:	01c85713          	srli	a4,a6,0x1c
 842:	9736                	add	a4,a4,a3
 844:	fae60de3          	beq	a2,a4,7fe <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 848:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84c:	4790                	lw	a2,8(a5)
 84e:	02061593          	slli	a1,a2,0x20
 852:	01c5d713          	srli	a4,a1,0x1c
 856:	973e                	add	a4,a4,a5
 858:	fae68ae3          	beq	a3,a4,80c <free+0x22>
    p->s.ptr = bp->s.ptr;
 85c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 85e:	00000717          	auipc	a4,0x0
 862:	7af73123          	sd	a5,1954(a4) # 1000 <freep>
}
 866:	6422                	ld	s0,8(sp)
 868:	0141                	addi	sp,sp,16
 86a:	8082                	ret

000000000000086c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86c:	7139                	addi	sp,sp,-64
 86e:	fc06                	sd	ra,56(sp)
 870:	f822                	sd	s0,48(sp)
 872:	f426                	sd	s1,40(sp)
 874:	f04a                	sd	s2,32(sp)
 876:	ec4e                	sd	s3,24(sp)
 878:	e852                	sd	s4,16(sp)
 87a:	e456                	sd	s5,8(sp)
 87c:	e05a                	sd	s6,0(sp)
 87e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 880:	02051493          	slli	s1,a0,0x20
 884:	9081                	srli	s1,s1,0x20
 886:	04bd                	addi	s1,s1,15
 888:	8091                	srli	s1,s1,0x4
 88a:	0014899b          	addiw	s3,s1,1
 88e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 890:	00000517          	auipc	a0,0x0
 894:	77053503          	ld	a0,1904(a0) # 1000 <freep>
 898:	c515                	beqz	a0,8c4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89c:	4798                	lw	a4,8(a5)
 89e:	02977f63          	bgeu	a4,s1,8dc <malloc+0x70>
 8a2:	8a4e                	mv	s4,s3
 8a4:	0009871b          	sext.w	a4,s3
 8a8:	6685                	lui	a3,0x1
 8aa:	00d77363          	bgeu	a4,a3,8b0 <malloc+0x44>
 8ae:	6a05                	lui	s4,0x1
 8b0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b8:	00000917          	auipc	s2,0x0
 8bc:	74890913          	addi	s2,s2,1864 # 1000 <freep>
  if(p == SBRK_ERROR)
 8c0:	5afd                	li	s5,-1
 8c2:	a885                	j	932 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8c4:	00000797          	auipc	a5,0x0
 8c8:	74c78793          	addi	a5,a5,1868 # 1010 <base>
 8cc:	00000717          	auipc	a4,0x0
 8d0:	72f73a23          	sd	a5,1844(a4) # 1000 <freep>
 8d4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8da:	b7e1                	j	8a2 <malloc+0x36>
      if(p->s.size == nunits)
 8dc:	02e48c63          	beq	s1,a4,914 <malloc+0xa8>
        p->s.size -= nunits;
 8e0:	4137073b          	subw	a4,a4,s3
 8e4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e6:	02071693          	slli	a3,a4,0x20
 8ea:	01c6d713          	srli	a4,a3,0x1c
 8ee:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f4:	00000717          	auipc	a4,0x0
 8f8:	70a73623          	sd	a0,1804(a4) # 1000 <freep>
      return (void*)(p + 1);
 8fc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 900:	70e2                	ld	ra,56(sp)
 902:	7442                	ld	s0,48(sp)
 904:	74a2                	ld	s1,40(sp)
 906:	7902                	ld	s2,32(sp)
 908:	69e2                	ld	s3,24(sp)
 90a:	6a42                	ld	s4,16(sp)
 90c:	6aa2                	ld	s5,8(sp)
 90e:	6b02                	ld	s6,0(sp)
 910:	6121                	addi	sp,sp,64
 912:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 914:	6398                	ld	a4,0(a5)
 916:	e118                	sd	a4,0(a0)
 918:	bff1                	j	8f4 <malloc+0x88>
  hp->s.size = nu;
 91a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 91e:	0541                	addi	a0,a0,16
 920:	ecbff0ef          	jal	ra,7ea <free>
  return freep;
 924:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 928:	dd61                	beqz	a0,900 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92c:	4798                	lw	a4,8(a5)
 92e:	fa9777e3          	bgeu	a4,s1,8dc <malloc+0x70>
    if(p == freep)
 932:	00093703          	ld	a4,0(s2)
 936:	853e                	mv	a0,a5
 938:	fef719e3          	bne	a4,a5,92a <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 93c:	8552                	mv	a0,s4
 93e:	a1bff0ef          	jal	ra,358 <sbrk>
  if(p == SBRK_ERROR)
 942:	fd551ce3          	bne	a0,s5,91a <malloc+0xae>
        return 0;
 946:	4501                	li	a0,0
 948:	bf65                	j	900 <malloc+0x94>
