
user/_umm_tail：     文件格式 elf64-littleriscv


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
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int len = 3*4096;
  char *p = mmap(0, len, PROT_READ|PROT_WRITE, MAP_ANON, 1);
   c:	4705                	li	a4,1
   e:	4685                	li	a3,1
  10:	460d                	li	a2,3
  12:	658d                	lui	a1,0x3
  14:	4501                	li	a0,0
  16:	3e6000ef          	jal	ra,3fc <mmap>
  if(p == (char*)-1){
  1a:	57fd                	li	a5,-1
  1c:	08f50463          	beq	a0,a5,a4 <main+0xa4>
  20:	84aa                	mv	s1,a0
    printf("mmap failed\n");
    exit(1);
  }

  p[0] = 'A';
  22:	04100793          	li	a5,65
  26:	00f50023          	sb	a5,0(a0)
  p[4096] = 'B';
  2a:	6785                	lui	a5,0x1
  2c:	97aa                	add	a5,a5,a0
  2e:	04200713          	li	a4,66
  32:	00e78023          	sb	a4,0(a5) # 1000 <freep>
  p[8192] = 'C';
  36:	6909                	lui	s2,0x2
  38:	992a                	add	s2,s2,a0
  3a:	04300793          	li	a5,67
  3e:	00f90023          	sb	a5,0(s2) # 2000 <base+0xff0>
  printf("before: %c %c %c\n", p[0], p[4096], p[8192]);
  42:	04300693          	li	a3,67
  46:	04200613          	li	a2,66
  4a:	04100593          	li	a1,65
  4e:	00001517          	auipc	a0,0x1
  52:	91250513          	addi	a0,a0,-1774 # 960 <malloc+0xfc>
  56:	75a000ef          	jal	ra,7b0 <printf>

  // unmap 最后一页
  if(munmap(p + 8192, 4096) < 0){
  5a:	6585                	lui	a1,0x1
  5c:	854a                	mv	a0,s2
  5e:	3a6000ef          	jal	ra,404 <munmap>
  62:	04054a63          	bltz	a0,b6 <main+0xb6>
    printf("munmap failed\n");
    exit(1);
  }

  printf("after: %c %c\n", p[0], p[4096]);
  66:	6785                	lui	a5,0x1
  68:	97a6                	add	a5,a5,s1
  6a:	0007c603          	lbu	a2,0(a5) # 1000 <freep>
  6e:	0004c583          	lbu	a1,0(s1)
  72:	00001517          	auipc	a0,0x1
  76:	91650513          	addi	a0,a0,-1770 # 988 <malloc+0x124>
  7a:	736000ef          	jal	ra,7b0 <printf>
  printf("touch unmapped (should die): %c\n", p[8192]);
  7e:	6789                	lui	a5,0x2
  80:	94be                	add	s1,s1,a5
  82:	0004c583          	lbu	a1,0(s1)
  86:	00001517          	auipc	a0,0x1
  8a:	91250513          	addi	a0,a0,-1774 # 998 <malloc+0x134>
  8e:	722000ef          	jal	ra,7b0 <printf>

  printf("FAIL: still alive\n");
  92:	00001517          	auipc	a0,0x1
  96:	92e50513          	addi	a0,a0,-1746 # 9c0 <malloc+0x15c>
  9a:	716000ef          	jal	ra,7b0 <printf>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	2bc000ef          	jal	ra,35c <exit>
    printf("mmap failed\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	8ac50513          	addi	a0,a0,-1876 # 950 <malloc+0xec>
  ac:	704000ef          	jal	ra,7b0 <printf>
    exit(1);
  b0:	4505                	li	a0,1
  b2:	2aa000ef          	jal	ra,35c <exit>
    printf("munmap failed\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	8c250513          	addi	a0,a0,-1854 # 978 <malloc+0x114>
  be:	6f2000ef          	jal	ra,7b0 <printf>
    exit(1);
  c2:	4505                	li	a0,1
  c4:	298000ef          	jal	ra,35c <exit>

00000000000000c8 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e406                	sd	ra,8(sp)
  cc:	e022                	sd	s0,0(sp)
  ce:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  d0:	f31ff0ef          	jal	ra,0 <main>
  exit(r);
  d4:	288000ef          	jal	ra,35c <exit>

00000000000000d8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  de:	87aa                	mv	a5,a0
  e0:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
  e2:	0785                	addi	a5,a5,1 # 2001 <base+0xff1>
  e4:	fff5c703          	lbu	a4,-1(a1)
  e8:	fee78fa3          	sb	a4,-1(a5)
  ec:	fb75                	bnez	a4,e0 <strcpy+0x8>
    ;
  return os;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb91                	beqz	a5,112 <strcmp+0x1e>
 100:	0005c703          	lbu	a4,0(a1)
 104:	00f71763          	bne	a4,a5,112 <strcmp+0x1e>
    p++, q++;
 108:	0505                	addi	a0,a0,1
 10a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 10c:	00054783          	lbu	a5,0(a0)
 110:	fbe5                	bnez	a5,100 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 112:	0005c503          	lbu	a0,0(a1)
}
 116:	40a7853b          	subw	a0,a5,a0
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strlen>:

uint
strlen(const char *s)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cf91                	beqz	a5,146 <strlen+0x26>
 12c:	0505                	addi	a0,a0,1
 12e:	87aa                	mv	a5,a0
 130:	4685                	li	a3,1
 132:	9e89                	subw	a3,a3,a0
 134:	00f6853b          	addw	a0,a3,a5
 138:	0785                	addi	a5,a5,1
 13a:	fff7c703          	lbu	a4,-1(a5)
 13e:	fb7d                	bnez	a4,134 <strlen+0x14>
    ;
  return n;
}
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret
  for(n = 0; s[n]; n++)
 146:	4501                	li	a0,0
 148:	bfe5                	j	140 <strlen+0x20>

000000000000014a <memset>:

void*
memset(void *dst, int c, uint n)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 150:	ca19                	beqz	a2,166 <memset+0x1c>
 152:	87aa                	mv	a5,a0
 154:	1602                	slli	a2,a2,0x20
 156:	9201                	srli	a2,a2,0x20
 158:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 160:	0785                	addi	a5,a5,1
 162:	fee79de3          	bne	a5,a4,15c <memset+0x12>
  }
  return dst;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strchr>:

char*
strchr(const char *s, char c)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  for(; *s; s++)
 172:	00054783          	lbu	a5,0(a0)
 176:	cb99                	beqz	a5,18c <strchr+0x20>
    if(*s == c)
 178:	00f58763          	beq	a1,a5,186 <strchr+0x1a>
  for(; *s; s++)
 17c:	0505                	addi	a0,a0,1
 17e:	00054783          	lbu	a5,0(a0)
 182:	fbfd                	bnez	a5,178 <strchr+0xc>
      return (char*)s;
  return 0;
 184:	4501                	li	a0,0
}
 186:	6422                	ld	s0,8(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret
  return 0;
 18c:	4501                	li	a0,0
 18e:	bfe5                	j	186 <strchr+0x1a>

0000000000000190 <gets>:

char*
gets(char *buf, int max)
{
 190:	711d                	addi	sp,sp,-96
 192:	ec86                	sd	ra,88(sp)
 194:	e8a2                	sd	s0,80(sp)
 196:	e4a6                	sd	s1,72(sp)
 198:	e0ca                	sd	s2,64(sp)
 19a:	fc4e                	sd	s3,56(sp)
 19c:	f852                	sd	s4,48(sp)
 19e:	f456                	sd	s5,40(sp)
 1a0:	f05a                	sd	s6,32(sp)
 1a2:	ec5e                	sd	s7,24(sp)
 1a4:	1080                	addi	s0,sp,96
 1a6:	8baa                	mv	s7,a0
 1a8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1aa:	892a                	mv	s2,a0
 1ac:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ae:	4aa9                	li	s5,10
 1b0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b2:	89a6                	mv	s3,s1
 1b4:	2485                	addiw	s1,s1,1
 1b6:	0344d663          	bge	s1,s4,1e2 <gets+0x52>
    cc = read(0, &c, 1);
 1ba:	4605                	li	a2,1
 1bc:	faf40593          	addi	a1,s0,-81
 1c0:	4501                	li	a0,0
 1c2:	1b2000ef          	jal	ra,374 <read>
    if(cc < 1)
 1c6:	00a05e63          	blez	a0,1e2 <gets+0x52>
    buf[i++] = c;
 1ca:	faf44783          	lbu	a5,-81(s0)
 1ce:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d2:	01578763          	beq	a5,s5,1e0 <gets+0x50>
 1d6:	0905                	addi	s2,s2,1
 1d8:	fd679de3          	bne	a5,s6,1b2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1dc:	89a6                	mv	s3,s1
 1de:	a011                	j	1e2 <gets+0x52>
 1e0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e2:	99de                	add	s3,s3,s7
 1e4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e8:	855e                	mv	a0,s7
 1ea:	60e6                	ld	ra,88(sp)
 1ec:	6446                	ld	s0,80(sp)
 1ee:	64a6                	ld	s1,72(sp)
 1f0:	6906                	ld	s2,64(sp)
 1f2:	79e2                	ld	s3,56(sp)
 1f4:	7a42                	ld	s4,48(sp)
 1f6:	7aa2                	ld	s5,40(sp)
 1f8:	7b02                	ld	s6,32(sp)
 1fa:	6be2                	ld	s7,24(sp)
 1fc:	6125                	addi	sp,sp,96
 1fe:	8082                	ret

0000000000000200 <stat>:

int
stat(const char *n, struct stat *st)
{
 200:	1101                	addi	sp,sp,-32
 202:	ec06                	sd	ra,24(sp)
 204:	e822                	sd	s0,16(sp)
 206:	e426                	sd	s1,8(sp)
 208:	e04a                	sd	s2,0(sp)
 20a:	1000                	addi	s0,sp,32
 20c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20e:	4581                	li	a1,0
 210:	18c000ef          	jal	ra,39c <open>
  if(fd < 0)
 214:	02054163          	bltz	a0,236 <stat+0x36>
 218:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21a:	85ca                	mv	a1,s2
 21c:	198000ef          	jal	ra,3b4 <fstat>
 220:	892a                	mv	s2,a0
  close(fd);
 222:	8526                	mv	a0,s1
 224:	160000ef          	jal	ra,384 <close>
  return r;
}
 228:	854a                	mv	a0,s2
 22a:	60e2                	ld	ra,24(sp)
 22c:	6442                	ld	s0,16(sp)
 22e:	64a2                	ld	s1,8(sp)
 230:	6902                	ld	s2,0(sp)
 232:	6105                	addi	sp,sp,32
 234:	8082                	ret
    return -1;
 236:	597d                	li	s2,-1
 238:	bfc5                	j	228 <stat+0x28>

000000000000023a <atoi>:

int
atoi(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 240:	00054683          	lbu	a3,0(a0)
 244:	fd06879b          	addiw	a5,a3,-48
 248:	0ff7f793          	zext.b	a5,a5
 24c:	4625                	li	a2,9
 24e:	02f66863          	bltu	a2,a5,27e <atoi+0x44>
 252:	872a                	mv	a4,a0
  n = 0;
 254:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 256:	0705                	addi	a4,a4,1
 258:	0025179b          	slliw	a5,a0,0x2
 25c:	9fa9                	addw	a5,a5,a0
 25e:	0017979b          	slliw	a5,a5,0x1
 262:	9fb5                	addw	a5,a5,a3
 264:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 268:	00074683          	lbu	a3,0(a4)
 26c:	fd06879b          	addiw	a5,a3,-48
 270:	0ff7f793          	zext.b	a5,a5
 274:	fef671e3          	bgeu	a2,a5,256 <atoi+0x1c>
  return n;
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  n = 0;
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <atoi+0x3e>

0000000000000282 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 288:	02b57463          	bgeu	a0,a1,2b0 <memmove+0x2e>
    while(n-- > 0)
 28c:	00c05f63          	blez	a2,2aa <memmove+0x28>
 290:	1602                	slli	a2,a2,0x20
 292:	9201                	srli	a2,a2,0x20
 294:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 298:	872a                	mv	a4,a0
      *dst++ = *src++;
 29a:	0585                	addi	a1,a1,1
 29c:	0705                	addi	a4,a4,1
 29e:	fff5c683          	lbu	a3,-1(a1)
 2a2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a6:	fee79ae3          	bne	a5,a4,29a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
    dst += n;
 2b0:	00c50733          	add	a4,a0,a2
    src += n;
 2b4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b6:	fec05ae3          	blez	a2,2aa <memmove+0x28>
 2ba:	fff6079b          	addiw	a5,a2,-1
 2be:	1782                	slli	a5,a5,0x20
 2c0:	9381                	srli	a5,a5,0x20
 2c2:	fff7c793          	not	a5,a5
 2c6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c8:	15fd                	addi	a1,a1,-1
 2ca:	177d                	addi	a4,a4,-1
 2cc:	0005c683          	lbu	a3,0(a1)
 2d0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d4:	fee79ae3          	bne	a5,a4,2c8 <memmove+0x46>
 2d8:	bfc9                	j	2aa <memmove+0x28>

00000000000002da <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e0:	ca05                	beqz	a2,310 <memcmp+0x36>
 2e2:	fff6069b          	addiw	a3,a2,-1
 2e6:	1682                	slli	a3,a3,0x20
 2e8:	9281                	srli	a3,a3,0x20
 2ea:	0685                	addi	a3,a3,1
 2ec:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ee:	00054783          	lbu	a5,0(a0)
 2f2:	0005c703          	lbu	a4,0(a1)
 2f6:	00e79863          	bne	a5,a4,306 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fa:	0505                	addi	a0,a0,1
    p2++;
 2fc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fe:	fed518e3          	bne	a0,a3,2ee <memcmp+0x14>
  }
  return 0;
 302:	4501                	li	a0,0
 304:	a019                	j	30a <memcmp+0x30>
      return *p1 - *p2;
 306:	40e7853b          	subw	a0,a5,a4
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  return 0;
 310:	4501                	li	a0,0
 312:	bfe5                	j	30a <memcmp+0x30>

0000000000000314 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31c:	f67ff0ef          	jal	ra,282 <memmove>
}
 320:	60a2                	ld	ra,8(sp)
 322:	6402                	ld	s0,0(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <sbrk>:

char *
sbrk(int n) {
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 330:	4585                	li	a1,1
 332:	0b2000ef          	jal	ra,3e4 <sys_sbrk>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <sbrklazy>:

char *
sbrklazy(int n) {
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 346:	4589                	li	a1,2
 348:	09c000ef          	jal	ra,3e4 <sys_sbrk>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 354:	4885                	li	a7,1
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <exit>:
.global exit
exit:
 li a7, SYS_exit
 35c:	4889                	li	a7,2
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <wait>:
.global wait
wait:
 li a7, SYS_wait
 364:	488d                	li	a7,3
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36c:	4891                	li	a7,4
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <read>:
.global read
read:
 li a7, SYS_read
 374:	4895                	li	a7,5
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <write>:
.global write
write:
 li a7, SYS_write
 37c:	48c1                	li	a7,16
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <close>:
.global close
close:
 li a7, SYS_close
 384:	48d5                	li	a7,21
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <kill>:
.global kill
kill:
 li a7, SYS_kill
 38c:	4899                	li	a7,6
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <exec>:
.global exec
exec:
 li a7, SYS_exec
 394:	489d                	li	a7,7
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <open>:
.global open
open:
 li a7, SYS_open
 39c:	48bd                	li	a7,15
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a4:	48c5                	li	a7,17
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ac:	48c9                	li	a7,18
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b4:	48a1                	li	a7,8
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <link>:
.global link
link:
 li a7, SYS_link
 3bc:	48cd                	li	a7,19
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c4:	48d1                	li	a7,20
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3cc:	48a5                	li	a7,9
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d4:	48a9                	li	a7,10
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3dc:	48ad                	li	a7,11
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e4:	48b1                	li	a7,12
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ec:	48b5                	li	a7,13
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f4:	48b9                	li	a7,14
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3fc:	48d9                	li	a7,22
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 404:	48dd                	li	a7,23
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 40c:	48e1                	li	a7,24
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 414:	48e5                	li	a7,25
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 41c:	48e9                	li	a7,26
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 424:	48ed                	li	a7,27
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 42c:	48f1                	li	a7,28
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 434:	1101                	addi	sp,sp,-32
 436:	ec06                	sd	ra,24(sp)
 438:	e822                	sd	s0,16(sp)
 43a:	1000                	addi	s0,sp,32
 43c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 440:	4605                	li	a2,1
 442:	fef40593          	addi	a1,s0,-17
 446:	f37ff0ef          	jal	ra,37c <write>
}
 44a:	60e2                	ld	ra,24(sp)
 44c:	6442                	ld	s0,16(sp)
 44e:	6105                	addi	sp,sp,32
 450:	8082                	ret

0000000000000452 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 452:	715d                	addi	sp,sp,-80
 454:	e486                	sd	ra,72(sp)
 456:	e0a2                	sd	s0,64(sp)
 458:	fc26                	sd	s1,56(sp)
 45a:	f84a                	sd	s2,48(sp)
 45c:	f44e                	sd	s3,40(sp)
 45e:	0880                	addi	s0,sp,80
 460:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 462:	c299                	beqz	a3,468 <printint+0x16>
 464:	0805c163          	bltz	a1,4e6 <printint+0x94>
  neg = 0;
 468:	4881                	li	a7,0
 46a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 46e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 470:	00000517          	auipc	a0,0x0
 474:	57050513          	addi	a0,a0,1392 # 9e0 <digits>
 478:	883e                	mv	a6,a5
 47a:	2785                	addiw	a5,a5,1
 47c:	02c5f733          	remu	a4,a1,a2
 480:	972a                	add	a4,a4,a0
 482:	00074703          	lbu	a4,0(a4)
 486:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 48a:	872e                	mv	a4,a1
 48c:	02c5d5b3          	divu	a1,a1,a2
 490:	0685                	addi	a3,a3,1
 492:	fec773e3          	bgeu	a4,a2,478 <printint+0x26>
  if(neg)
 496:	00088b63          	beqz	a7,4ac <printint+0x5a>
    buf[i++] = '-';
 49a:	fd078793          	addi	a5,a5,-48
 49e:	97a2                	add	a5,a5,s0
 4a0:	02d00713          	li	a4,45
 4a4:	fee78423          	sb	a4,-24(a5)
 4a8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ac:	02f05663          	blez	a5,4d8 <printint+0x86>
 4b0:	fb840713          	addi	a4,s0,-72
 4b4:	00f704b3          	add	s1,a4,a5
 4b8:	fff70993          	addi	s3,a4,-1
 4bc:	99be                	add	s3,s3,a5
 4be:	37fd                	addiw	a5,a5,-1
 4c0:	1782                	slli	a5,a5,0x20
 4c2:	9381                	srli	a5,a5,0x20
 4c4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4c8:	fff4c583          	lbu	a1,-1(s1)
 4cc:	854a                	mv	a0,s2
 4ce:	f67ff0ef          	jal	ra,434 <putc>
  while(--i >= 0)
 4d2:	14fd                	addi	s1,s1,-1
 4d4:	ff349ae3          	bne	s1,s3,4c8 <printint+0x76>
}
 4d8:	60a6                	ld	ra,72(sp)
 4da:	6406                	ld	s0,64(sp)
 4dc:	74e2                	ld	s1,56(sp)
 4de:	7942                	ld	s2,48(sp)
 4e0:	79a2                	ld	s3,40(sp)
 4e2:	6161                	addi	sp,sp,80
 4e4:	8082                	ret
    x = -xx;
 4e6:	40b005b3          	neg	a1,a1
    neg = 1;
 4ea:	4885                	li	a7,1
    x = -xx;
 4ec:	bfbd                	j	46a <printint+0x18>

00000000000004ee <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ee:	7119                	addi	sp,sp,-128
 4f0:	fc86                	sd	ra,120(sp)
 4f2:	f8a2                	sd	s0,112(sp)
 4f4:	f4a6                	sd	s1,104(sp)
 4f6:	f0ca                	sd	s2,96(sp)
 4f8:	ecce                	sd	s3,88(sp)
 4fa:	e8d2                	sd	s4,80(sp)
 4fc:	e4d6                	sd	s5,72(sp)
 4fe:	e0da                	sd	s6,64(sp)
 500:	fc5e                	sd	s7,56(sp)
 502:	f862                	sd	s8,48(sp)
 504:	f466                	sd	s9,40(sp)
 506:	f06a                	sd	s10,32(sp)
 508:	ec6e                	sd	s11,24(sp)
 50a:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50c:	0005c903          	lbu	s2,0(a1)
 510:	24090c63          	beqz	s2,768 <vprintf+0x27a>
 514:	8b2a                	mv	s6,a0
 516:	8a2e                	mv	s4,a1
 518:	8bb2                	mv	s7,a2
  state = 0;
 51a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 51c:	4481                	li	s1,0
 51e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 520:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 524:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 528:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 52c:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 530:	00000c97          	auipc	s9,0x0
 534:	4b0c8c93          	addi	s9,s9,1200 # 9e0 <digits>
 538:	a005                	j	558 <vprintf+0x6a>
        putc(fd, c0);
 53a:	85ca                	mv	a1,s2
 53c:	855a                	mv	a0,s6
 53e:	ef7ff0ef          	jal	ra,434 <putc>
 542:	a019                	j	548 <vprintf+0x5a>
    } else if(state == '%'){
 544:	03598263          	beq	s3,s5,568 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 548:	2485                	addiw	s1,s1,1
 54a:	8726                	mv	a4,s1
 54c:	009a07b3          	add	a5,s4,s1
 550:	0007c903          	lbu	s2,0(a5)
 554:	20090a63          	beqz	s2,768 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 558:	0009079b          	sext.w	a5,s2
    if(state == 0){
 55c:	fe0994e3          	bnez	s3,544 <vprintf+0x56>
      if(c0 == '%'){
 560:	fd579de3          	bne	a5,s5,53a <vprintf+0x4c>
        state = '%';
 564:	89be                	mv	s3,a5
 566:	b7cd                	j	548 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 568:	c3c1                	beqz	a5,5e8 <vprintf+0xfa>
 56a:	00ea06b3          	add	a3,s4,a4
 56e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 572:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 574:	c681                	beqz	a3,57c <vprintf+0x8e>
 576:	9752                	add	a4,a4,s4
 578:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 57c:	03878e63          	beq	a5,s8,5b8 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 580:	05a78863          	beq	a5,s10,5d0 <vprintf+0xe2>
      } else if(c0 == 'u'){
 584:	0db78b63          	beq	a5,s11,65a <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 588:	07800713          	li	a4,120
 58c:	10e78d63          	beq	a5,a4,6a6 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 590:	07000713          	li	a4,112
 594:	14e78263          	beq	a5,a4,6d8 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 598:	06300713          	li	a4,99
 59c:	16e78f63          	beq	a5,a4,71a <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5a0:	07300713          	li	a4,115
 5a4:	18e78563          	beq	a5,a4,72e <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5a8:	05579063          	bne	a5,s5,5e8 <vprintf+0xfa>
        putc(fd, '%');
 5ac:	85d6                	mv	a1,s5
 5ae:	855a                	mv	a0,s6
 5b0:	e85ff0ef          	jal	ra,434 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bf49                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5b8:	008b8913          	addi	s2,s7,8
 5bc:	4685                	li	a3,1
 5be:	4629                	li	a2,10
 5c0:	000ba583          	lw	a1,0(s7)
 5c4:	855a                	mv	a0,s6
 5c6:	e8dff0ef          	jal	ra,452 <printint>
 5ca:	8bca                	mv	s7,s2
      state = 0;
 5cc:	4981                	li	s3,0
 5ce:	bfad                	j	548 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d0:	03868663          	beq	a3,s8,5fc <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d4:	05a68163          	beq	a3,s10,616 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5d8:	09b68d63          	beq	a3,s11,672 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5dc:	03a68f63          	beq	a3,s10,61a <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5e0:	07800793          	li	a5,120
 5e4:	0cf68d63          	beq	a3,a5,6be <vprintf+0x1d0>
        putc(fd, '%');
 5e8:	85d6                	mv	a1,s5
 5ea:	855a                	mv	a0,s6
 5ec:	e49ff0ef          	jal	ra,434 <putc>
        putc(fd, c0);
 5f0:	85ca                	mv	a1,s2
 5f2:	855a                	mv	a0,s6
 5f4:	e41ff0ef          	jal	ra,434 <putc>
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b7b9                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000bb583          	ld	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	e49ff0ef          	jal	ra,452 <printint>
        i += 1;
 60e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
        i += 1;
 614:	bf15                	j	548 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 616:	03860563          	beq	a2,s8,640 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 61a:	07b60963          	beq	a2,s11,68c <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 61e:	07800793          	li	a5,120
 622:	fcf613e3          	bne	a2,a5,5e8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 626:	008b8913          	addi	s2,s7,8
 62a:	4681                	li	a3,0
 62c:	4641                	li	a2,16
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	e1fff0ef          	jal	ra,452 <printint>
        i += 2;
 638:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
        i += 2;
 63e:	b729                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 640:	008b8913          	addi	s2,s7,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000bb583          	ld	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e05ff0ef          	jal	ra,452 <printint>
        i += 2;
 652:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
        i += 2;
 658:	bdc5                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4681                	li	a3,0
 660:	4629                	li	a2,10
 662:	000be583          	lwu	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	debff0ef          	jal	ra,452 <printint>
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	bde1                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	008b8913          	addi	s2,s7,8
 676:	4681                	li	a3,0
 678:	4629                	li	a2,10
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	dd3ff0ef          	jal	ra,452 <printint>
        i += 1;
 684:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
        i += 1;
 68a:	bd7d                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000bb583          	ld	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	db9ff0ef          	jal	ra,452 <printint>
        i += 2;
 69e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
        i += 2;
 6a4:	b555                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4641                	li	a2,16
 6ae:	000be583          	lwu	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	d9fff0ef          	jal	ra,452 <printint>
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b571                	j	548 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4641                	li	a2,16
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	d87ff0ef          	jal	ra,452 <printint>
        i += 1;
 6d0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
        i += 1;
 6d6:	bd8d                	j	548 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6d8:	008b8793          	addi	a5,s7,8
 6dc:	f8f43423          	sd	a5,-120(s0)
 6e0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e4:	03000593          	li	a1,48
 6e8:	855a                	mv	a0,s6
 6ea:	d4bff0ef          	jal	ra,434 <putc>
  putc(fd, 'x');
 6ee:	07800593          	li	a1,120
 6f2:	855a                	mv	a0,s6
 6f4:	d41ff0ef          	jal	ra,434 <putc>
 6f8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fa:	03c9d793          	srli	a5,s3,0x3c
 6fe:	97e6                	add	a5,a5,s9
 700:	0007c583          	lbu	a1,0(a5)
 704:	855a                	mv	a0,s6
 706:	d2fff0ef          	jal	ra,434 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70a:	0992                	slli	s3,s3,0x4
 70c:	397d                	addiw	s2,s2,-1
 70e:	fe0916e3          	bnez	s2,6fa <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 712:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 716:	4981                	li	s3,0
 718:	bd05                	j	548 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 71a:	008b8913          	addi	s2,s7,8
 71e:	000bc583          	lbu	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	d11ff0ef          	jal	ra,434 <putc>
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bd31                	j	548 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 72e:	008b8993          	addi	s3,s7,8
 732:	000bb903          	ld	s2,0(s7)
 736:	00090f63          	beqz	s2,754 <vprintf+0x266>
        for(; *s; s++)
 73a:	00094583          	lbu	a1,0(s2)
 73e:	c195                	beqz	a1,762 <vprintf+0x274>
          putc(fd, *s);
 740:	855a                	mv	a0,s6
 742:	cf3ff0ef          	jal	ra,434 <putc>
        for(; *s; s++)
 746:	0905                	addi	s2,s2,1
 748:	00094583          	lbu	a1,0(s2)
 74c:	f9f5                	bnez	a1,740 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 74e:	8bce                	mv	s7,s3
      state = 0;
 750:	4981                	li	s3,0
 752:	bbdd                	j	548 <vprintf+0x5a>
          s = "(null)";
 754:	00000917          	auipc	s2,0x0
 758:	28490913          	addi	s2,s2,644 # 9d8 <malloc+0x174>
        for(; *s; s++)
 75c:	02800593          	li	a1,40
 760:	b7c5                	j	740 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 762:	8bce                	mv	s7,s3
      state = 0;
 764:	4981                	li	s3,0
 766:	b3cd                	j	548 <vprintf+0x5a>
    }
  }
}
 768:	70e6                	ld	ra,120(sp)
 76a:	7446                	ld	s0,112(sp)
 76c:	74a6                	ld	s1,104(sp)
 76e:	7906                	ld	s2,96(sp)
 770:	69e6                	ld	s3,88(sp)
 772:	6a46                	ld	s4,80(sp)
 774:	6aa6                	ld	s5,72(sp)
 776:	6b06                	ld	s6,64(sp)
 778:	7be2                	ld	s7,56(sp)
 77a:	7c42                	ld	s8,48(sp)
 77c:	7ca2                	ld	s9,40(sp)
 77e:	7d02                	ld	s10,32(sp)
 780:	6de2                	ld	s11,24(sp)
 782:	6109                	addi	sp,sp,128
 784:	8082                	ret

0000000000000786 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 786:	715d                	addi	sp,sp,-80
 788:	ec06                	sd	ra,24(sp)
 78a:	e822                	sd	s0,16(sp)
 78c:	1000                	addi	s0,sp,32
 78e:	e010                	sd	a2,0(s0)
 790:	e414                	sd	a3,8(s0)
 792:	e818                	sd	a4,16(s0)
 794:	ec1c                	sd	a5,24(s0)
 796:	03043023          	sd	a6,32(s0)
 79a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a2:	8622                	mv	a2,s0
 7a4:	d4bff0ef          	jal	ra,4ee <vprintf>
}
 7a8:	60e2                	ld	ra,24(sp)
 7aa:	6442                	ld	s0,16(sp)
 7ac:	6161                	addi	sp,sp,80
 7ae:	8082                	ret

00000000000007b0 <printf>:

void
printf(const char *fmt, ...)
{
 7b0:	711d                	addi	sp,sp,-96
 7b2:	ec06                	sd	ra,24(sp)
 7b4:	e822                	sd	s0,16(sp)
 7b6:	1000                	addi	s0,sp,32
 7b8:	e40c                	sd	a1,8(s0)
 7ba:	e810                	sd	a2,16(s0)
 7bc:	ec14                	sd	a3,24(s0)
 7be:	f018                	sd	a4,32(s0)
 7c0:	f41c                	sd	a5,40(s0)
 7c2:	03043823          	sd	a6,48(s0)
 7c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	00840613          	addi	a2,s0,8
 7ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d2:	85aa                	mv	a1,a0
 7d4:	4505                	li	a0,1
 7d6:	d19ff0ef          	jal	ra,4ee <vprintf>
}
 7da:	60e2                	ld	ra,24(sp)
 7dc:	6442                	ld	s0,16(sp)
 7de:	6125                	addi	sp,sp,96
 7e0:	8082                	ret

00000000000007e2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e2:	1141                	addi	sp,sp,-16
 7e4:	e422                	sd	s0,8(sp)
 7e6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	00001797          	auipc	a5,0x1
 7f0:	8147b783          	ld	a5,-2028(a5) # 1000 <freep>
 7f4:	a02d                	j	81e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f6:	4618                	lw	a4,8(a2)
 7f8:	9f2d                	addw	a4,a4,a1
 7fa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fe:	6398                	ld	a4,0(a5)
 800:	6310                	ld	a2,0(a4)
 802:	a83d                	j	840 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 804:	ff852703          	lw	a4,-8(a0)
 808:	9f31                	addw	a4,a4,a2
 80a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 80c:	ff053683          	ld	a3,-16(a0)
 810:	a091                	j	854 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 812:	6398                	ld	a4,0(a5)
 814:	00e7e463          	bltu	a5,a4,81c <free+0x3a>
 818:	00e6ea63          	bltu	a3,a4,82c <free+0x4a>
{
 81c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	fed7fae3          	bgeu	a5,a3,812 <free+0x30>
 822:	6398                	ld	a4,0(a5)
 824:	00e6e463          	bltu	a3,a4,82c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 828:	fee7eae3          	bltu	a5,a4,81c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 82c:	ff852583          	lw	a1,-8(a0)
 830:	6390                	ld	a2,0(a5)
 832:	02059813          	slli	a6,a1,0x20
 836:	01c85713          	srli	a4,a6,0x1c
 83a:	9736                	add	a4,a4,a3
 83c:	fae60de3          	beq	a2,a4,7f6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 840:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 844:	4790                	lw	a2,8(a5)
 846:	02061593          	slli	a1,a2,0x20
 84a:	01c5d713          	srli	a4,a1,0x1c
 84e:	973e                	add	a4,a4,a5
 850:	fae68ae3          	beq	a3,a4,804 <free+0x22>
    p->s.ptr = bp->s.ptr;
 854:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 856:	00000717          	auipc	a4,0x0
 85a:	7af73523          	sd	a5,1962(a4) # 1000 <freep>
}
 85e:	6422                	ld	s0,8(sp)
 860:	0141                	addi	sp,sp,16
 862:	8082                	ret

0000000000000864 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 864:	7139                	addi	sp,sp,-64
 866:	fc06                	sd	ra,56(sp)
 868:	f822                	sd	s0,48(sp)
 86a:	f426                	sd	s1,40(sp)
 86c:	f04a                	sd	s2,32(sp)
 86e:	ec4e                	sd	s3,24(sp)
 870:	e852                	sd	s4,16(sp)
 872:	e456                	sd	s5,8(sp)
 874:	e05a                	sd	s6,0(sp)
 876:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 878:	02051493          	slli	s1,a0,0x20
 87c:	9081                	srli	s1,s1,0x20
 87e:	04bd                	addi	s1,s1,15
 880:	8091                	srli	s1,s1,0x4
 882:	0014899b          	addiw	s3,s1,1
 886:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 888:	00000517          	auipc	a0,0x0
 88c:	77853503          	ld	a0,1912(a0) # 1000 <freep>
 890:	c515                	beqz	a0,8bc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 892:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 894:	4798                	lw	a4,8(a5)
 896:	02977f63          	bgeu	a4,s1,8d4 <malloc+0x70>
 89a:	8a4e                	mv	s4,s3
 89c:	0009871b          	sext.w	a4,s3
 8a0:	6685                	lui	a3,0x1
 8a2:	00d77363          	bgeu	a4,a3,8a8 <malloc+0x44>
 8a6:	6a05                	lui	s4,0x1
 8a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b0:	00000917          	auipc	s2,0x0
 8b4:	75090913          	addi	s2,s2,1872 # 1000 <freep>
  if(p == SBRK_ERROR)
 8b8:	5afd                	li	s5,-1
 8ba:	a885                	j	92a <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8bc:	00000797          	auipc	a5,0x0
 8c0:	75478793          	addi	a5,a5,1876 # 1010 <base>
 8c4:	00000717          	auipc	a4,0x0
 8c8:	72f73e23          	sd	a5,1852(a4) # 1000 <freep>
 8cc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d2:	b7e1                	j	89a <malloc+0x36>
      if(p->s.size == nunits)
 8d4:	02e48c63          	beq	s1,a4,90c <malloc+0xa8>
        p->s.size -= nunits;
 8d8:	4137073b          	subw	a4,a4,s3
 8dc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8de:	02071693          	slli	a3,a4,0x20
 8e2:	01c6d713          	srli	a4,a3,0x1c
 8e6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ec:	00000717          	auipc	a4,0x0
 8f0:	70a73a23          	sd	a0,1812(a4) # 1000 <freep>
      return (void*)(p + 1);
 8f4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f8:	70e2                	ld	ra,56(sp)
 8fa:	7442                	ld	s0,48(sp)
 8fc:	74a2                	ld	s1,40(sp)
 8fe:	7902                	ld	s2,32(sp)
 900:	69e2                	ld	s3,24(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	6121                	addi	sp,sp,64
 90a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90c:	6398                	ld	a4,0(a5)
 90e:	e118                	sd	a4,0(a0)
 910:	bff1                	j	8ec <malloc+0x88>
  hp->s.size = nu;
 912:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 916:	0541                	addi	a0,a0,16
 918:	ecbff0ef          	jal	ra,7e2 <free>
  return freep;
 91c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 920:	dd61                	beqz	a0,8f8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 922:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 924:	4798                	lw	a4,8(a5)
 926:	fa9777e3          	bgeu	a4,s1,8d4 <malloc+0x70>
    if(p == freep)
 92a:	00093703          	ld	a4,0(s2)
 92e:	853e                	mv	a0,a5
 930:	fef719e3          	bne	a4,a5,922 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 934:	8552                	mv	a0,s4
 936:	9f3ff0ef          	jal	ra,328 <sbrk>
  if(p == SBRK_ERROR)
 93a:	fd551ce3          	bne	a0,s5,912 <malloc+0xae>
        return 0;
 93e:	4501                	li	a0,0
 940:	bf65                	j	8f8 <malloc+0x94>
