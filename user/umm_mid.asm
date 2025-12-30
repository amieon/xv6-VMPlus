
user/_umm_mid：     文件格式 elf64-littleriscv


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
  2a:	6905                	lui	s2,0x1
  2c:	992a                	add	s2,s2,a0
  2e:	04200793          	li	a5,66
  32:	00f90023          	sb	a5,0(s2) # 1000 <freep>
  p[8192] = 'C';
  36:	6789                	lui	a5,0x2
  38:	97aa                	add	a5,a5,a0
  3a:	04300713          	li	a4,67
  3e:	00e78023          	sb	a4,0(a5) # 2000 <base+0xff0>
  printf("before: %c %c %c\n", p[0], p[4096], p[8192]);
  42:	04300693          	li	a3,67
  46:	04200613          	li	a2,66
  4a:	04100593          	li	a1,65
  4e:	00001517          	auipc	a0,0x1
  52:	8e250513          	addi	a0,a0,-1822 # 930 <malloc+0xf4>
  56:	732000ef          	jal	ra,788 <printf>

  // unmap 中间一页
  if(munmap(p + 4096, 4096) < 0){
  5a:	6585                	lui	a1,0x1
  5c:	854a                	mv	a0,s2
  5e:	3a6000ef          	jal	ra,404 <munmap>
  62:	04054a63          	bltz	a0,b6 <main+0xb6>
    printf("munmap failed\n");
    exit(1);
  }

  printf("after: %c %c\n", p[0], p[8192]);
  66:	6789                	lui	a5,0x2
  68:	97a6                	add	a5,a5,s1
  6a:	0007c603          	lbu	a2,0(a5) # 2000 <base+0xff0>
  6e:	0004c583          	lbu	a1,0(s1)
  72:	00001517          	auipc	a0,0x1
  76:	8e650513          	addi	a0,a0,-1818 # 958 <malloc+0x11c>
  7a:	70e000ef          	jal	ra,788 <printf>

  // 这句应该 kill
  printf("touch hole (should die): %c\n", p[4096]);
  7e:	6785                	lui	a5,0x1
  80:	94be                	add	s1,s1,a5
  82:	0004c583          	lbu	a1,0(s1)
  86:	00001517          	auipc	a0,0x1
  8a:	8e250513          	addi	a0,a0,-1822 # 968 <malloc+0x12c>
  8e:	6fa000ef          	jal	ra,788 <printf>

  printf("FAIL: still alive\n");
  92:	00001517          	auipc	a0,0x1
  96:	8f650513          	addi	a0,a0,-1802 # 988 <malloc+0x14c>
  9a:	6ee000ef          	jal	ra,788 <printf>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	2bc000ef          	jal	ra,35c <exit>
    printf("mmap failed\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	87c50513          	addi	a0,a0,-1924 # 920 <malloc+0xe4>
  ac:	6dc000ef          	jal	ra,788 <printf>
    exit(1);
  b0:	4505                	li	a0,1
  b2:	2aa000ef          	jal	ra,35c <exit>
    printf("munmap failed\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	89250513          	addi	a0,a0,-1902 # 948 <malloc+0x10c>
  be:	6ca000ef          	jal	ra,788 <printf>
    exit(1);
  c2:	4505                	li	a0,1
  c4:	298000ef          	jal	ra,35c <exit>

00000000000000c8 <start>:
//
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
  e2:	0785                	addi	a5,a5,1 # 1001 <freep+0x1>
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

000000000000040c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	1000                	addi	s0,sp,32
 414:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 418:	4605                	li	a2,1
 41a:	fef40593          	addi	a1,s0,-17
 41e:	f5fff0ef          	jal	ra,37c <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 42a:	715d                	addi	sp,sp,-80
 42c:	e486                	sd	ra,72(sp)
 42e:	e0a2                	sd	s0,64(sp)
 430:	fc26                	sd	s1,56(sp)
 432:	f84a                	sd	s2,48(sp)
 434:	f44e                	sd	s3,40(sp)
 436:	0880                	addi	s0,sp,80
 438:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 43a:	c299                	beqz	a3,440 <printint+0x16>
 43c:	0805c163          	bltz	a1,4be <printint+0x94>
  neg = 0;
 440:	4881                	li	a7,0
 442:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 446:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 448:	00000517          	auipc	a0,0x0
 44c:	56050513          	addi	a0,a0,1376 # 9a8 <digits>
 450:	883e                	mv	a6,a5
 452:	2785                	addiw	a5,a5,1
 454:	02c5f733          	remu	a4,a1,a2
 458:	972a                	add	a4,a4,a0
 45a:	00074703          	lbu	a4,0(a4)
 45e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 462:	872e                	mv	a4,a1
 464:	02c5d5b3          	divu	a1,a1,a2
 468:	0685                	addi	a3,a3,1
 46a:	fec773e3          	bgeu	a4,a2,450 <printint+0x26>
  if(neg)
 46e:	00088b63          	beqz	a7,484 <printint+0x5a>
    buf[i++] = '-';
 472:	fd078793          	addi	a5,a5,-48
 476:	97a2                	add	a5,a5,s0
 478:	02d00713          	li	a4,45
 47c:	fee78423          	sb	a4,-24(a5)
 480:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 484:	02f05663          	blez	a5,4b0 <printint+0x86>
 488:	fb840713          	addi	a4,s0,-72
 48c:	00f704b3          	add	s1,a4,a5
 490:	fff70993          	addi	s3,a4,-1
 494:	99be                	add	s3,s3,a5
 496:	37fd                	addiw	a5,a5,-1
 498:	1782                	slli	a5,a5,0x20
 49a:	9381                	srli	a5,a5,0x20
 49c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4a0:	fff4c583          	lbu	a1,-1(s1)
 4a4:	854a                	mv	a0,s2
 4a6:	f67ff0ef          	jal	ra,40c <putc>
  while(--i >= 0)
 4aa:	14fd                	addi	s1,s1,-1
 4ac:	ff349ae3          	bne	s1,s3,4a0 <printint+0x76>
}
 4b0:	60a6                	ld	ra,72(sp)
 4b2:	6406                	ld	s0,64(sp)
 4b4:	74e2                	ld	s1,56(sp)
 4b6:	7942                	ld	s2,48(sp)
 4b8:	79a2                	ld	s3,40(sp)
 4ba:	6161                	addi	sp,sp,80
 4bc:	8082                	ret
    x = -xx;
 4be:	40b005b3          	neg	a1,a1
    neg = 1;
 4c2:	4885                	li	a7,1
    x = -xx;
 4c4:	bfbd                	j	442 <printint+0x18>

00000000000004c6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c6:	7119                	addi	sp,sp,-128
 4c8:	fc86                	sd	ra,120(sp)
 4ca:	f8a2                	sd	s0,112(sp)
 4cc:	f4a6                	sd	s1,104(sp)
 4ce:	f0ca                	sd	s2,96(sp)
 4d0:	ecce                	sd	s3,88(sp)
 4d2:	e8d2                	sd	s4,80(sp)
 4d4:	e4d6                	sd	s5,72(sp)
 4d6:	e0da                	sd	s6,64(sp)
 4d8:	fc5e                	sd	s7,56(sp)
 4da:	f862                	sd	s8,48(sp)
 4dc:	f466                	sd	s9,40(sp)
 4de:	f06a                	sd	s10,32(sp)
 4e0:	ec6e                	sd	s11,24(sp)
 4e2:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e4:	0005c903          	lbu	s2,0(a1)
 4e8:	24090c63          	beqz	s2,740 <vprintf+0x27a>
 4ec:	8b2a                	mv	s6,a0
 4ee:	8a2e                	mv	s4,a1
 4f0:	8bb2                	mv	s7,a2
  state = 0;
 4f2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f4:	4481                	li	s1,0
 4f6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4f8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4fc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 500:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 504:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 508:	00000c97          	auipc	s9,0x0
 50c:	4a0c8c93          	addi	s9,s9,1184 # 9a8 <digits>
 510:	a005                	j	530 <vprintf+0x6a>
        putc(fd, c0);
 512:	85ca                	mv	a1,s2
 514:	855a                	mv	a0,s6
 516:	ef7ff0ef          	jal	ra,40c <putc>
 51a:	a019                	j	520 <vprintf+0x5a>
    } else if(state == '%'){
 51c:	03598263          	beq	s3,s5,540 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 520:	2485                	addiw	s1,s1,1
 522:	8726                	mv	a4,s1
 524:	009a07b3          	add	a5,s4,s1
 528:	0007c903          	lbu	s2,0(a5)
 52c:	20090a63          	beqz	s2,740 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 530:	0009079b          	sext.w	a5,s2
    if(state == 0){
 534:	fe0994e3          	bnez	s3,51c <vprintf+0x56>
      if(c0 == '%'){
 538:	fd579de3          	bne	a5,s5,512 <vprintf+0x4c>
        state = '%';
 53c:	89be                	mv	s3,a5
 53e:	b7cd                	j	520 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 540:	c3c1                	beqz	a5,5c0 <vprintf+0xfa>
 542:	00ea06b3          	add	a3,s4,a4
 546:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 54a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 54c:	c681                	beqz	a3,554 <vprintf+0x8e>
 54e:	9752                	add	a4,a4,s4
 550:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 554:	03878e63          	beq	a5,s8,590 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 558:	05a78863          	beq	a5,s10,5a8 <vprintf+0xe2>
      } else if(c0 == 'u'){
 55c:	0db78b63          	beq	a5,s11,632 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 560:	07800713          	li	a4,120
 564:	10e78d63          	beq	a5,a4,67e <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 568:	07000713          	li	a4,112
 56c:	14e78263          	beq	a5,a4,6b0 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 570:	06300713          	li	a4,99
 574:	16e78f63          	beq	a5,a4,6f2 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 578:	07300713          	li	a4,115
 57c:	18e78563          	beq	a5,a4,706 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 580:	05579063          	bne	a5,s5,5c0 <vprintf+0xfa>
        putc(fd, '%');
 584:	85d6                	mv	a1,s5
 586:	855a                	mv	a0,s6
 588:	e85ff0ef          	jal	ra,40c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 58c:	4981                	li	s3,0
 58e:	bf49                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 590:	008b8913          	addi	s2,s7,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000ba583          	lw	a1,0(s7)
 59c:	855a                	mv	a0,s6
 59e:	e8dff0ef          	jal	ra,42a <printint>
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	bfad                	j	520 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5a8:	03868663          	beq	a3,s8,5d4 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ac:	05a68163          	beq	a3,s10,5ee <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5b0:	09b68d63          	beq	a3,s11,64a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5b4:	03a68f63          	beq	a3,s10,5f2 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5b8:	07800793          	li	a5,120
 5bc:	0cf68d63          	beq	a3,a5,696 <vprintf+0x1d0>
        putc(fd, '%');
 5c0:	85d6                	mv	a1,s5
 5c2:	855a                	mv	a0,s6
 5c4:	e49ff0ef          	jal	ra,40c <putc>
        putc(fd, c0);
 5c8:	85ca                	mv	a1,s2
 5ca:	855a                	mv	a0,s6
 5cc:	e41ff0ef          	jal	ra,40c <putc>
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b7b9                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d4:	008b8913          	addi	s2,s7,8
 5d8:	4685                	li	a3,1
 5da:	4629                	li	a2,10
 5dc:	000bb583          	ld	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	e49ff0ef          	jal	ra,42a <printint>
        i += 1;
 5e6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
        i += 1;
 5ec:	bf15                	j	520 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ee:	03860563          	beq	a2,s8,618 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f2:	07b60963          	beq	a2,s11,664 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5f6:	07800793          	li	a5,120
 5fa:	fcf613e3          	bne	a2,a5,5c0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4641                	li	a2,16
 606:	000bb583          	ld	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	e1fff0ef          	jal	ra,42a <printint>
        i += 2;
 610:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
        i += 2;
 616:	b729                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 618:	008b8913          	addi	s2,s7,8
 61c:	4685                	li	a3,1
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	e05ff0ef          	jal	ra,42a <printint>
        i += 2;
 62a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 2;
 630:	bdc5                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4629                	li	a2,10
 63a:	000be583          	lwu	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	debff0ef          	jal	ra,42a <printint>
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	bde1                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4681                	li	a3,0
 650:	4629                	li	a2,10
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	dd3ff0ef          	jal	ra,42a <printint>
        i += 1;
 65c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 1;
 662:	bd7d                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	db9ff0ef          	jal	ra,42a <printint>
        i += 2;
 676:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
        i += 2;
 67c:	b555                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4641                	li	a2,16
 686:	000be583          	lwu	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	d9fff0ef          	jal	ra,42a <printint>
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	b571                	j	520 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 696:	008b8913          	addi	s2,s7,8
 69a:	4681                	li	a3,0
 69c:	4641                	li	a2,16
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	d87ff0ef          	jal	ra,42a <printint>
        i += 1;
 6a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 1;
 6ae:	bd8d                	j	520 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6b0:	008b8793          	addi	a5,s7,8
 6b4:	f8f43423          	sd	a5,-120(s0)
 6b8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6bc:	03000593          	li	a1,48
 6c0:	855a                	mv	a0,s6
 6c2:	d4bff0ef          	jal	ra,40c <putc>
  putc(fd, 'x');
 6c6:	07800593          	li	a1,120
 6ca:	855a                	mv	a0,s6
 6cc:	d41ff0ef          	jal	ra,40c <putc>
 6d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d2:	03c9d793          	srli	a5,s3,0x3c
 6d6:	97e6                	add	a5,a5,s9
 6d8:	0007c583          	lbu	a1,0(a5)
 6dc:	855a                	mv	a0,s6
 6de:	d2fff0ef          	jal	ra,40c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e2:	0992                	slli	s3,s3,0x4
 6e4:	397d                	addiw	s2,s2,-1
 6e6:	fe0916e3          	bnez	s2,6d2 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6ea:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bd05                	j	520 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	000bc583          	lbu	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	d11ff0ef          	jal	ra,40c <putc>
 700:	8bca                	mv	s7,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	bd31                	j	520 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 706:	008b8993          	addi	s3,s7,8
 70a:	000bb903          	ld	s2,0(s7)
 70e:	00090f63          	beqz	s2,72c <vprintf+0x266>
        for(; *s; s++)
 712:	00094583          	lbu	a1,0(s2)
 716:	c195                	beqz	a1,73a <vprintf+0x274>
          putc(fd, *s);
 718:	855a                	mv	a0,s6
 71a:	cf3ff0ef          	jal	ra,40c <putc>
        for(; *s; s++)
 71e:	0905                	addi	s2,s2,1
 720:	00094583          	lbu	a1,0(s2)
 724:	f9f5                	bnez	a1,718 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 726:	8bce                	mv	s7,s3
      state = 0;
 728:	4981                	li	s3,0
 72a:	bbdd                	j	520 <vprintf+0x5a>
          s = "(null)";
 72c:	00000917          	auipc	s2,0x0
 730:	27490913          	addi	s2,s2,628 # 9a0 <malloc+0x164>
        for(; *s; s++)
 734:	02800593          	li	a1,40
 738:	b7c5                	j	718 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 73a:	8bce                	mv	s7,s3
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b3cd                	j	520 <vprintf+0x5a>
    }
  }
}
 740:	70e6                	ld	ra,120(sp)
 742:	7446                	ld	s0,112(sp)
 744:	74a6                	ld	s1,104(sp)
 746:	7906                	ld	s2,96(sp)
 748:	69e6                	ld	s3,88(sp)
 74a:	6a46                	ld	s4,80(sp)
 74c:	6aa6                	ld	s5,72(sp)
 74e:	6b06                	ld	s6,64(sp)
 750:	7be2                	ld	s7,56(sp)
 752:	7c42                	ld	s8,48(sp)
 754:	7ca2                	ld	s9,40(sp)
 756:	7d02                	ld	s10,32(sp)
 758:	6de2                	ld	s11,24(sp)
 75a:	6109                	addi	sp,sp,128
 75c:	8082                	ret

000000000000075e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 75e:	715d                	addi	sp,sp,-80
 760:	ec06                	sd	ra,24(sp)
 762:	e822                	sd	s0,16(sp)
 764:	1000                	addi	s0,sp,32
 766:	e010                	sd	a2,0(s0)
 768:	e414                	sd	a3,8(s0)
 76a:	e818                	sd	a4,16(s0)
 76c:	ec1c                	sd	a5,24(s0)
 76e:	03043023          	sd	a6,32(s0)
 772:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 776:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 77a:	8622                	mv	a2,s0
 77c:	d4bff0ef          	jal	ra,4c6 <vprintf>
}
 780:	60e2                	ld	ra,24(sp)
 782:	6442                	ld	s0,16(sp)
 784:	6161                	addi	sp,sp,80
 786:	8082                	ret

0000000000000788 <printf>:

void
printf(const char *fmt, ...)
{
 788:	711d                	addi	sp,sp,-96
 78a:	ec06                	sd	ra,24(sp)
 78c:	e822                	sd	s0,16(sp)
 78e:	1000                	addi	s0,sp,32
 790:	e40c                	sd	a1,8(s0)
 792:	e810                	sd	a2,16(s0)
 794:	ec14                	sd	a3,24(s0)
 796:	f018                	sd	a4,32(s0)
 798:	f41c                	sd	a5,40(s0)
 79a:	03043823          	sd	a6,48(s0)
 79e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a2:	00840613          	addi	a2,s0,8
 7a6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7aa:	85aa                	mv	a1,a0
 7ac:	4505                	li	a0,1
 7ae:	d19ff0ef          	jal	ra,4c6 <vprintf>
}
 7b2:	60e2                	ld	ra,24(sp)
 7b4:	6442                	ld	s0,16(sp)
 7b6:	6125                	addi	sp,sp,96
 7b8:	8082                	ret

00000000000007ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ba:	1141                	addi	sp,sp,-16
 7bc:	e422                	sd	s0,8(sp)
 7be:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c4:	00001797          	auipc	a5,0x1
 7c8:	83c7b783          	ld	a5,-1988(a5) # 1000 <freep>
 7cc:	a02d                	j	7f6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ce:	4618                	lw	a4,8(a2)
 7d0:	9f2d                	addw	a4,a4,a1
 7d2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d6:	6398                	ld	a4,0(a5)
 7d8:	6310                	ld	a2,0(a4)
 7da:	a83d                	j	818 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7dc:	ff852703          	lw	a4,-8(a0)
 7e0:	9f31                	addw	a4,a4,a2
 7e2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e4:	ff053683          	ld	a3,-16(a0)
 7e8:	a091                	j	82c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ea:	6398                	ld	a4,0(a5)
 7ec:	00e7e463          	bltu	a5,a4,7f4 <free+0x3a>
 7f0:	00e6ea63          	bltu	a3,a4,804 <free+0x4a>
{
 7f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f6:	fed7fae3          	bgeu	a5,a3,7ea <free+0x30>
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e6e463          	bltu	a3,a4,804 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 800:	fee7eae3          	bltu	a5,a4,7f4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 804:	ff852583          	lw	a1,-8(a0)
 808:	6390                	ld	a2,0(a5)
 80a:	02059813          	slli	a6,a1,0x20
 80e:	01c85713          	srli	a4,a6,0x1c
 812:	9736                	add	a4,a4,a3
 814:	fae60de3          	beq	a2,a4,7ce <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 818:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 81c:	4790                	lw	a2,8(a5)
 81e:	02061593          	slli	a1,a2,0x20
 822:	01c5d713          	srli	a4,a1,0x1c
 826:	973e                	add	a4,a4,a5
 828:	fae68ae3          	beq	a3,a4,7dc <free+0x22>
    p->s.ptr = bp->s.ptr;
 82c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 82e:	00000717          	auipc	a4,0x0
 832:	7cf73923          	sd	a5,2002(a4) # 1000 <freep>
}
 836:	6422                	ld	s0,8(sp)
 838:	0141                	addi	sp,sp,16
 83a:	8082                	ret

000000000000083c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 83c:	7139                	addi	sp,sp,-64
 83e:	fc06                	sd	ra,56(sp)
 840:	f822                	sd	s0,48(sp)
 842:	f426                	sd	s1,40(sp)
 844:	f04a                	sd	s2,32(sp)
 846:	ec4e                	sd	s3,24(sp)
 848:	e852                	sd	s4,16(sp)
 84a:	e456                	sd	s5,8(sp)
 84c:	e05a                	sd	s6,0(sp)
 84e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 850:	02051493          	slli	s1,a0,0x20
 854:	9081                	srli	s1,s1,0x20
 856:	04bd                	addi	s1,s1,15
 858:	8091                	srli	s1,s1,0x4
 85a:	0014899b          	addiw	s3,s1,1
 85e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 860:	00000517          	auipc	a0,0x0
 864:	7a053503          	ld	a0,1952(a0) # 1000 <freep>
 868:	c515                	beqz	a0,894 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 86c:	4798                	lw	a4,8(a5)
 86e:	02977f63          	bgeu	a4,s1,8ac <malloc+0x70>
 872:	8a4e                	mv	s4,s3
 874:	0009871b          	sext.w	a4,s3
 878:	6685                	lui	a3,0x1
 87a:	00d77363          	bgeu	a4,a3,880 <malloc+0x44>
 87e:	6a05                	lui	s4,0x1
 880:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 884:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 888:	00000917          	auipc	s2,0x0
 88c:	77890913          	addi	s2,s2,1912 # 1000 <freep>
  if(p == SBRK_ERROR)
 890:	5afd                	li	s5,-1
 892:	a885                	j	902 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 894:	00000797          	auipc	a5,0x0
 898:	77c78793          	addi	a5,a5,1916 # 1010 <base>
 89c:	00000717          	auipc	a4,0x0
 8a0:	76f73223          	sd	a5,1892(a4) # 1000 <freep>
 8a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8aa:	b7e1                	j	872 <malloc+0x36>
      if(p->s.size == nunits)
 8ac:	02e48c63          	beq	s1,a4,8e4 <malloc+0xa8>
        p->s.size -= nunits;
 8b0:	4137073b          	subw	a4,a4,s3
 8b4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b6:	02071693          	slli	a3,a4,0x20
 8ba:	01c6d713          	srli	a4,a3,0x1c
 8be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c4:	00000717          	auipc	a4,0x0
 8c8:	72a73e23          	sd	a0,1852(a4) # 1000 <freep>
      return (void*)(p + 1);
 8cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d0:	70e2                	ld	ra,56(sp)
 8d2:	7442                	ld	s0,48(sp)
 8d4:	74a2                	ld	s1,40(sp)
 8d6:	7902                	ld	s2,32(sp)
 8d8:	69e2                	ld	s3,24(sp)
 8da:	6a42                	ld	s4,16(sp)
 8dc:	6aa2                	ld	s5,8(sp)
 8de:	6b02                	ld	s6,0(sp)
 8e0:	6121                	addi	sp,sp,64
 8e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e4:	6398                	ld	a4,0(a5)
 8e6:	e118                	sd	a4,0(a0)
 8e8:	bff1                	j	8c4 <malloc+0x88>
  hp->s.size = nu;
 8ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ee:	0541                	addi	a0,a0,16
 8f0:	ecbff0ef          	jal	ra,7ba <free>
  return freep;
 8f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f8:	dd61                	beqz	a0,8d0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fc:	4798                	lw	a4,8(a5)
 8fe:	fa9777e3          	bgeu	a4,s1,8ac <malloc+0x70>
    if(p == freep)
 902:	00093703          	ld	a4,0(s2)
 906:	853e                	mv	a0,a5
 908:	fef719e3          	bne	a4,a5,8fa <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 90c:	8552                	mv	a0,s4
 90e:	a1bff0ef          	jal	ra,328 <sbrk>
  if(p == SBRK_ERROR)
 912:	fd551ce3          	bne	a0,s5,8ea <malloc+0xae>
        return 0;
 916:	4501                	li	a0,0
 918:	bf65                	j	8d0 <malloc+0x94>
