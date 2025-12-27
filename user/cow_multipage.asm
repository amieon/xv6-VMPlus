
user/_cow_multipage：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define NP 8

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *p = sbrk(NP * 4096);
   a:	6521                	lui	a0,0x8
   c:	30e000ef          	jal	ra,31a <sbrk>
  if(p == (char*)-1) exit(1);
  10:	57fd                	li	a5,-1
  12:	04f50c63          	beq	a0,a5,6a <main+0x6a>
  16:	84aa                	mv	s1,a0
  18:	04100793          	li	a5,65

  for(int k = 0; k < NP; k++)
  1c:	6685                	lui	a3,0x1
  1e:	04900713          	li	a4,73
    p[k*4096] = 'A' + k;
  22:	00f50023          	sb	a5,0(a0) # 8000 <base+0x6ff0>
  for(int k = 0; k < NP; k++)
  26:	2785                	addiw	a5,a5,1
  28:	0ff7f793          	zext.b	a5,a5
  2c:	9536                	add	a0,a0,a3
  2e:	fee79ae3          	bne	a5,a4,22 <main+0x22>

  int pid = fork();
  32:	314000ef          	jal	ra,346 <fork>
  if(pid < 0) exit(1);
  36:	02054d63          	bltz	a0,70 <main+0x70>

  if(pid == 0){
  3a:	ed15                	bnez	a0,76 <main+0x76>
  3c:	06100793          	li	a5,97
    for(int k = 0; k < NP; k++)
  40:	6685                	lui	a3,0x1
  42:	06900713          	li	a4,105
      p[k*4096] = 'a' + k;
  46:	00f48023          	sb	a5,0(s1)
    for(int k = 0; k < NP; k++)
  4a:	2785                	addiw	a5,a5,1
  4c:	0ff7f793          	zext.b	a5,a5
  50:	94b6                	add	s1,s1,a3
  52:	fee79ae3          	bne	a5,a4,46 <main+0x46>
    printf("child wrote %d pages\n", NP);
  56:	45a1                	li	a1,8
  58:	00001517          	auipc	a0,0x1
  5c:	8a850513          	addi	a0,a0,-1880 # 900 <malloc+0xe2>
  60:	70a000ef          	jal	ra,76a <printf>
    exit(0);
  64:	4501                	li	a0,0
  66:	2e8000ef          	jal	ra,34e <exit>
  if(p == (char*)-1) exit(1);
  6a:	4505                	li	a0,1
  6c:	2e2000ef          	jal	ra,34e <exit>
  if(pid < 0) exit(1);
  70:	4505                	li	a0,1
  72:	2dc000ef          	jal	ra,34e <exit>
  }

  wait(0);
  76:	4501                	li	a0,0
  78:	2de000ef          	jal	ra,356 <wait>
  for(int k = 0; k < NP; k++){
  7c:	4581                	li	a1,0
  7e:	6685                	lui	a3,0x1
  80:	4721                	li	a4,8
    if(p[k*4096] != 'A' + k){
  82:	0004c603          	lbu	a2,0(s1)
  86:	0415879b          	addiw	a5,a1,65
  8a:	00c79f63          	bne	a5,a2,a8 <main+0xa8>
  for(int k = 0; k < NP; k++){
  8e:	2585                	addiw	a1,a1,1
  90:	94b6                	add	s1,s1,a3
  92:	fee598e3          	bne	a1,a4,82 <main+0x82>
      printf("FAIL: parent page %d changed to %c\n", k, p[k*4096]);
      exit(1);
    }
  }
  printf("PASS\n");
  96:	00001517          	auipc	a0,0x1
  9a:	8aa50513          	addi	a0,a0,-1878 # 940 <malloc+0x122>
  9e:	6cc000ef          	jal	ra,76a <printf>
  exit(0);
  a2:	4501                	li	a0,0
  a4:	2aa000ef          	jal	ra,34e <exit>
      printf("FAIL: parent page %d changed to %c\n", k, p[k*4096]);
  a8:	00001517          	auipc	a0,0x1
  ac:	87050513          	addi	a0,a0,-1936 # 918 <malloc+0xfa>
  b0:	6ba000ef          	jal	ra,76a <printf>
      exit(1);
  b4:	4505                	li	a0,1
  b6:	298000ef          	jal	ra,34e <exit>

00000000000000ba <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e406                	sd	ra,8(sp)
  be:	e022                	sd	s0,0(sp)
  c0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  c2:	f3fff0ef          	jal	ra,0 <main>
  exit(r);
  c6:	288000ef          	jal	ra,34e <exit>

00000000000000ca <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d0:	87aa                	mv	a5,a0
  d2:	0585                	addi	a1,a1,1
  d4:	0785                	addi	a5,a5,1
  d6:	fff5c703          	lbu	a4,-1(a1)
  da:	fee78fa3          	sb	a4,-1(a5)
  de:	fb75                	bnez	a4,d2 <strcpy+0x8>
    ;
  return os;
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cb91                	beqz	a5,104 <strcmp+0x1e>
  f2:	0005c703          	lbu	a4,0(a1)
  f6:	00f71763          	bne	a4,a5,104 <strcmp+0x1e>
    p++, q++;
  fa:	0505                	addi	a0,a0,1
  fc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  fe:	00054783          	lbu	a5,0(a0)
 102:	fbe5                	bnez	a5,f2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 104:	0005c503          	lbu	a0,0(a1)
}
 108:	40a7853b          	subw	a0,a5,a0
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strlen>:

uint
strlen(const char *s)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cf91                	beqz	a5,138 <strlen+0x26>
 11e:	0505                	addi	a0,a0,1
 120:	87aa                	mv	a5,a0
 122:	4685                	li	a3,1
 124:	9e89                	subw	a3,a3,a0
 126:	00f6853b          	addw	a0,a3,a5
 12a:	0785                	addi	a5,a5,1
 12c:	fff7c703          	lbu	a4,-1(a5)
 130:	fb7d                	bnez	a4,126 <strlen+0x14>
    ;
  return n;
}
 132:	6422                	ld	s0,8(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret
  for(n = 0; s[n]; n++)
 138:	4501                	li	a0,0
 13a:	bfe5                	j	132 <strlen+0x20>

000000000000013c <memset>:

void*
memset(void *dst, int c, uint n)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 142:	ca19                	beqz	a2,158 <memset+0x1c>
 144:	87aa                	mv	a5,a0
 146:	1602                	slli	a2,a2,0x20
 148:	9201                	srli	a2,a2,0x20
 14a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 14e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 152:	0785                	addi	a5,a5,1
 154:	fee79de3          	bne	a5,a4,14e <memset+0x12>
  }
  return dst;
}
 158:	6422                	ld	s0,8(sp)
 15a:	0141                	addi	sp,sp,16
 15c:	8082                	ret

000000000000015e <strchr>:

char*
strchr(const char *s, char c)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e422                	sd	s0,8(sp)
 162:	0800                	addi	s0,sp,16
  for(; *s; s++)
 164:	00054783          	lbu	a5,0(a0)
 168:	cb99                	beqz	a5,17e <strchr+0x20>
    if(*s == c)
 16a:	00f58763          	beq	a1,a5,178 <strchr+0x1a>
  for(; *s; s++)
 16e:	0505                	addi	a0,a0,1
 170:	00054783          	lbu	a5,0(a0)
 174:	fbfd                	bnez	a5,16a <strchr+0xc>
      return (char*)s;
  return 0;
 176:	4501                	li	a0,0
}
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret
  return 0;
 17e:	4501                	li	a0,0
 180:	bfe5                	j	178 <strchr+0x1a>

0000000000000182 <gets>:

char*
gets(char *buf, int max)
{
 182:	711d                	addi	sp,sp,-96
 184:	ec86                	sd	ra,88(sp)
 186:	e8a2                	sd	s0,80(sp)
 188:	e4a6                	sd	s1,72(sp)
 18a:	e0ca                	sd	s2,64(sp)
 18c:	fc4e                	sd	s3,56(sp)
 18e:	f852                	sd	s4,48(sp)
 190:	f456                	sd	s5,40(sp)
 192:	f05a                	sd	s6,32(sp)
 194:	ec5e                	sd	s7,24(sp)
 196:	1080                	addi	s0,sp,96
 198:	8baa                	mv	s7,a0
 19a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19c:	892a                	mv	s2,a0
 19e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a0:	4aa9                	li	s5,10
 1a2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a4:	89a6                	mv	s3,s1
 1a6:	2485                	addiw	s1,s1,1
 1a8:	0344d663          	bge	s1,s4,1d4 <gets+0x52>
    cc = read(0, &c, 1);
 1ac:	4605                	li	a2,1
 1ae:	faf40593          	addi	a1,s0,-81
 1b2:	4501                	li	a0,0
 1b4:	1b2000ef          	jal	ra,366 <read>
    if(cc < 1)
 1b8:	00a05e63          	blez	a0,1d4 <gets+0x52>
    buf[i++] = c;
 1bc:	faf44783          	lbu	a5,-81(s0)
 1c0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c4:	01578763          	beq	a5,s5,1d2 <gets+0x50>
 1c8:	0905                	addi	s2,s2,1
 1ca:	fd679de3          	bne	a5,s6,1a4 <gets+0x22>
  for(i=0; i+1 < max; ){
 1ce:	89a6                	mv	s3,s1
 1d0:	a011                	j	1d4 <gets+0x52>
 1d2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d4:	99de                	add	s3,s3,s7
 1d6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1da:	855e                	mv	a0,s7
 1dc:	60e6                	ld	ra,88(sp)
 1de:	6446                	ld	s0,80(sp)
 1e0:	64a6                	ld	s1,72(sp)
 1e2:	6906                	ld	s2,64(sp)
 1e4:	79e2                	ld	s3,56(sp)
 1e6:	7a42                	ld	s4,48(sp)
 1e8:	7aa2                	ld	s5,40(sp)
 1ea:	7b02                	ld	s6,32(sp)
 1ec:	6be2                	ld	s7,24(sp)
 1ee:	6125                	addi	sp,sp,96
 1f0:	8082                	ret

00000000000001f2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f2:	1101                	addi	sp,sp,-32
 1f4:	ec06                	sd	ra,24(sp)
 1f6:	e822                	sd	s0,16(sp)
 1f8:	e426                	sd	s1,8(sp)
 1fa:	e04a                	sd	s2,0(sp)
 1fc:	1000                	addi	s0,sp,32
 1fe:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 200:	4581                	li	a1,0
 202:	18c000ef          	jal	ra,38e <open>
  if(fd < 0)
 206:	02054163          	bltz	a0,228 <stat+0x36>
 20a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20c:	85ca                	mv	a1,s2
 20e:	198000ef          	jal	ra,3a6 <fstat>
 212:	892a                	mv	s2,a0
  close(fd);
 214:	8526                	mv	a0,s1
 216:	160000ef          	jal	ra,376 <close>
  return r;
}
 21a:	854a                	mv	a0,s2
 21c:	60e2                	ld	ra,24(sp)
 21e:	6442                	ld	s0,16(sp)
 220:	64a2                	ld	s1,8(sp)
 222:	6902                	ld	s2,0(sp)
 224:	6105                	addi	sp,sp,32
 226:	8082                	ret
    return -1;
 228:	597d                	li	s2,-1
 22a:	bfc5                	j	21a <stat+0x28>

000000000000022c <atoi>:

int
atoi(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 232:	00054683          	lbu	a3,0(a0)
 236:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x680>
 23a:	0ff7f793          	zext.b	a5,a5
 23e:	4625                	li	a2,9
 240:	02f66863          	bltu	a2,a5,270 <atoi+0x44>
 244:	872a                	mv	a4,a0
  n = 0;
 246:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 248:	0705                	addi	a4,a4,1
 24a:	0025179b          	slliw	a5,a0,0x2
 24e:	9fa9                	addw	a5,a5,a0
 250:	0017979b          	slliw	a5,a5,0x1
 254:	9fb5                	addw	a5,a5,a3
 256:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25a:	00074683          	lbu	a3,0(a4)
 25e:	fd06879b          	addiw	a5,a3,-48
 262:	0ff7f793          	zext.b	a5,a5
 266:	fef671e3          	bgeu	a2,a5,248 <atoi+0x1c>
  return n;
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
  n = 0;
 270:	4501                	li	a0,0
 272:	bfe5                	j	26a <atoi+0x3e>

0000000000000274 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27a:	02b57463          	bgeu	a0,a1,2a2 <memmove+0x2e>
    while(n-- > 0)
 27e:	00c05f63          	blez	a2,29c <memmove+0x28>
 282:	1602                	slli	a2,a2,0x20
 284:	9201                	srli	a2,a2,0x20
 286:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28a:	872a                	mv	a4,a0
      *dst++ = *src++;
 28c:	0585                	addi	a1,a1,1
 28e:	0705                	addi	a4,a4,1
 290:	fff5c683          	lbu	a3,-1(a1)
 294:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 298:	fee79ae3          	bne	a5,a4,28c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
    dst += n;
 2a2:	00c50733          	add	a4,a0,a2
    src += n;
 2a6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a8:	fec05ae3          	blez	a2,29c <memmove+0x28>
 2ac:	fff6079b          	addiw	a5,a2,-1
 2b0:	1782                	slli	a5,a5,0x20
 2b2:	9381                	srli	a5,a5,0x20
 2b4:	fff7c793          	not	a5,a5
 2b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ba:	15fd                	addi	a1,a1,-1
 2bc:	177d                	addi	a4,a4,-1
 2be:	0005c683          	lbu	a3,0(a1)
 2c2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c6:	fee79ae3          	bne	a5,a4,2ba <memmove+0x46>
 2ca:	bfc9                	j	29c <memmove+0x28>

00000000000002cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d2:	ca05                	beqz	a2,302 <memcmp+0x36>
 2d4:	fff6069b          	addiw	a3,a2,-1
 2d8:	1682                	slli	a3,a3,0x20
 2da:	9281                	srli	a3,a3,0x20
 2dc:	0685                	addi	a3,a3,1
 2de:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e0:	00054783          	lbu	a5,0(a0)
 2e4:	0005c703          	lbu	a4,0(a1)
 2e8:	00e79863          	bne	a5,a4,2f8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ec:	0505                	addi	a0,a0,1
    p2++;
 2ee:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f0:	fed518e3          	bne	a0,a3,2e0 <memcmp+0x14>
  }
  return 0;
 2f4:	4501                	li	a0,0
 2f6:	a019                	j	2fc <memcmp+0x30>
      return *p1 - *p2;
 2f8:	40e7853b          	subw	a0,a5,a4
}
 2fc:	6422                	ld	s0,8(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
  return 0;
 302:	4501                	li	a0,0
 304:	bfe5                	j	2fc <memcmp+0x30>

0000000000000306 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 30e:	f67ff0ef          	jal	ra,274 <memmove>
}
 312:	60a2                	ld	ra,8(sp)
 314:	6402                	ld	s0,0(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret

000000000000031a <sbrk>:

char *
sbrk(int n) {
 31a:	1141                	addi	sp,sp,-16
 31c:	e406                	sd	ra,8(sp)
 31e:	e022                	sd	s0,0(sp)
 320:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 322:	4585                	li	a1,1
 324:	0b2000ef          	jal	ra,3d6 <sys_sbrk>
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret

0000000000000330 <sbrklazy>:

char *
sbrklazy(int n) {
 330:	1141                	addi	sp,sp,-16
 332:	e406                	sd	ra,8(sp)
 334:	e022                	sd	s0,0(sp)
 336:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 338:	4589                	li	a1,2
 33a:	09c000ef          	jal	ra,3d6 <sys_sbrk>
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 346:	4885                	li	a7,1
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <exit>:
.global exit
exit:
 li a7, SYS_exit
 34e:	4889                	li	a7,2
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <wait>:
.global wait
wait:
 li a7, SYS_wait
 356:	488d                	li	a7,3
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 35e:	4891                	li	a7,4
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <read>:
.global read
read:
 li a7, SYS_read
 366:	4895                	li	a7,5
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <write>:
.global write
write:
 li a7, SYS_write
 36e:	48c1                	li	a7,16
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <close>:
.global close
close:
 li a7, SYS_close
 376:	48d5                	li	a7,21
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <kill>:
.global kill
kill:
 li a7, SYS_kill
 37e:	4899                	li	a7,6
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <exec>:
.global exec
exec:
 li a7, SYS_exec
 386:	489d                	li	a7,7
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <open>:
.global open
open:
 li a7, SYS_open
 38e:	48bd                	li	a7,15
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 396:	48c5                	li	a7,17
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 39e:	48c9                	li	a7,18
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a6:	48a1                	li	a7,8
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <link>:
.global link
link:
 li a7, SYS_link
 3ae:	48cd                	li	a7,19
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b6:	48d1                	li	a7,20
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3be:	48a5                	li	a7,9
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c6:	48a9                	li	a7,10
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ce:	48ad                	li	a7,11
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3d6:	48b1                	li	a7,12
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <pause>:
.global pause
pause:
 li a7, SYS_pause
 3de:	48b5                	li	a7,13
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e6:	48b9                	li	a7,14
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ee:	1101                	addi	sp,sp,-32
 3f0:	ec06                	sd	ra,24(sp)
 3f2:	e822                	sd	s0,16(sp)
 3f4:	1000                	addi	s0,sp,32
 3f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fa:	4605                	li	a2,1
 3fc:	fef40593          	addi	a1,s0,-17
 400:	f6fff0ef          	jal	ra,36e <write>
}
 404:	60e2                	ld	ra,24(sp)
 406:	6442                	ld	s0,16(sp)
 408:	6105                	addi	sp,sp,32
 40a:	8082                	ret

000000000000040c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 40c:	715d                	addi	sp,sp,-80
 40e:	e486                	sd	ra,72(sp)
 410:	e0a2                	sd	s0,64(sp)
 412:	fc26                	sd	s1,56(sp)
 414:	f84a                	sd	s2,48(sp)
 416:	f44e                	sd	s3,40(sp)
 418:	0880                	addi	s0,sp,80
 41a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 41c:	c299                	beqz	a3,422 <printint+0x16>
 41e:	0805c163          	bltz	a1,4a0 <printint+0x94>
  neg = 0;
 422:	4881                	li	a7,0
 424:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 428:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 42a:	00000517          	auipc	a0,0x0
 42e:	52650513          	addi	a0,a0,1318 # 950 <digits>
 432:	883e                	mv	a6,a5
 434:	2785                	addiw	a5,a5,1
 436:	02c5f733          	remu	a4,a1,a2
 43a:	972a                	add	a4,a4,a0
 43c:	00074703          	lbu	a4,0(a4)
 440:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 444:	872e                	mv	a4,a1
 446:	02c5d5b3          	divu	a1,a1,a2
 44a:	0685                	addi	a3,a3,1
 44c:	fec773e3          	bgeu	a4,a2,432 <printint+0x26>
  if(neg)
 450:	00088b63          	beqz	a7,466 <printint+0x5a>
    buf[i++] = '-';
 454:	fd078793          	addi	a5,a5,-48
 458:	97a2                	add	a5,a5,s0
 45a:	02d00713          	li	a4,45
 45e:	fee78423          	sb	a4,-24(a5)
 462:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 466:	02f05663          	blez	a5,492 <printint+0x86>
 46a:	fb840713          	addi	a4,s0,-72
 46e:	00f704b3          	add	s1,a4,a5
 472:	fff70993          	addi	s3,a4,-1
 476:	99be                	add	s3,s3,a5
 478:	37fd                	addiw	a5,a5,-1
 47a:	1782                	slli	a5,a5,0x20
 47c:	9381                	srli	a5,a5,0x20
 47e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 482:	fff4c583          	lbu	a1,-1(s1)
 486:	854a                	mv	a0,s2
 488:	f67ff0ef          	jal	ra,3ee <putc>
  while(--i >= 0)
 48c:	14fd                	addi	s1,s1,-1
 48e:	ff349ae3          	bne	s1,s3,482 <printint+0x76>
}
 492:	60a6                	ld	ra,72(sp)
 494:	6406                	ld	s0,64(sp)
 496:	74e2                	ld	s1,56(sp)
 498:	7942                	ld	s2,48(sp)
 49a:	79a2                	ld	s3,40(sp)
 49c:	6161                	addi	sp,sp,80
 49e:	8082                	ret
    x = -xx;
 4a0:	40b005b3          	neg	a1,a1
    neg = 1;
 4a4:	4885                	li	a7,1
    x = -xx;
 4a6:	bfbd                	j	424 <printint+0x18>

00000000000004a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a8:	7119                	addi	sp,sp,-128
 4aa:	fc86                	sd	ra,120(sp)
 4ac:	f8a2                	sd	s0,112(sp)
 4ae:	f4a6                	sd	s1,104(sp)
 4b0:	f0ca                	sd	s2,96(sp)
 4b2:	ecce                	sd	s3,88(sp)
 4b4:	e8d2                	sd	s4,80(sp)
 4b6:	e4d6                	sd	s5,72(sp)
 4b8:	e0da                	sd	s6,64(sp)
 4ba:	fc5e                	sd	s7,56(sp)
 4bc:	f862                	sd	s8,48(sp)
 4be:	f466                	sd	s9,40(sp)
 4c0:	f06a                	sd	s10,32(sp)
 4c2:	ec6e                	sd	s11,24(sp)
 4c4:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c6:	0005c903          	lbu	s2,0(a1)
 4ca:	24090c63          	beqz	s2,722 <vprintf+0x27a>
 4ce:	8b2a                	mv	s6,a0
 4d0:	8a2e                	mv	s4,a1
 4d2:	8bb2                	mv	s7,a2
  state = 0;
 4d4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d6:	4481                	li	s1,0
 4d8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4da:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4de:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4e2:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4e6:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ea:	00000c97          	auipc	s9,0x0
 4ee:	466c8c93          	addi	s9,s9,1126 # 950 <digits>
 4f2:	a005                	j	512 <vprintf+0x6a>
        putc(fd, c0);
 4f4:	85ca                	mv	a1,s2
 4f6:	855a                	mv	a0,s6
 4f8:	ef7ff0ef          	jal	ra,3ee <putc>
 4fc:	a019                	j	502 <vprintf+0x5a>
    } else if(state == '%'){
 4fe:	03598263          	beq	s3,s5,522 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 502:	2485                	addiw	s1,s1,1
 504:	8726                	mv	a4,s1
 506:	009a07b3          	add	a5,s4,s1
 50a:	0007c903          	lbu	s2,0(a5)
 50e:	20090a63          	beqz	s2,722 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 512:	0009079b          	sext.w	a5,s2
    if(state == 0){
 516:	fe0994e3          	bnez	s3,4fe <vprintf+0x56>
      if(c0 == '%'){
 51a:	fd579de3          	bne	a5,s5,4f4 <vprintf+0x4c>
        state = '%';
 51e:	89be                	mv	s3,a5
 520:	b7cd                	j	502 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 522:	c3c1                	beqz	a5,5a2 <vprintf+0xfa>
 524:	00ea06b3          	add	a3,s4,a4
 528:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 52c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 52e:	c681                	beqz	a3,536 <vprintf+0x8e>
 530:	9752                	add	a4,a4,s4
 532:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 536:	03878e63          	beq	a5,s8,572 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 53a:	05a78863          	beq	a5,s10,58a <vprintf+0xe2>
      } else if(c0 == 'u'){
 53e:	0db78b63          	beq	a5,s11,614 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 542:	07800713          	li	a4,120
 546:	10e78d63          	beq	a5,a4,660 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 54a:	07000713          	li	a4,112
 54e:	14e78263          	beq	a5,a4,692 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 552:	06300713          	li	a4,99
 556:	16e78f63          	beq	a5,a4,6d4 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 55a:	07300713          	li	a4,115
 55e:	18e78563          	beq	a5,a4,6e8 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 562:	05579063          	bne	a5,s5,5a2 <vprintf+0xfa>
        putc(fd, '%');
 566:	85d6                	mv	a1,s5
 568:	855a                	mv	a0,s6
 56a:	e85ff0ef          	jal	ra,3ee <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 56e:	4981                	li	s3,0
 570:	bf49                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 572:	008b8913          	addi	s2,s7,8
 576:	4685                	li	a3,1
 578:	4629                	li	a2,10
 57a:	000ba583          	lw	a1,0(s7)
 57e:	855a                	mv	a0,s6
 580:	e8dff0ef          	jal	ra,40c <printint>
 584:	8bca                	mv	s7,s2
      state = 0;
 586:	4981                	li	s3,0
 588:	bfad                	j	502 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 58a:	03868663          	beq	a3,s8,5b6 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 58e:	05a68163          	beq	a3,s10,5d0 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 592:	09b68d63          	beq	a3,s11,62c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 596:	03a68f63          	beq	a3,s10,5d4 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 59a:	07800793          	li	a5,120
 59e:	0cf68d63          	beq	a3,a5,678 <vprintf+0x1d0>
        putc(fd, '%');
 5a2:	85d6                	mv	a1,s5
 5a4:	855a                	mv	a0,s6
 5a6:	e49ff0ef          	jal	ra,3ee <putc>
        putc(fd, c0);
 5aa:	85ca                	mv	a1,s2
 5ac:	855a                	mv	a0,s6
 5ae:	e41ff0ef          	jal	ra,3ee <putc>
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b7b9                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4685                	li	a3,1
 5bc:	4629                	li	a2,10
 5be:	000bb583          	ld	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e49ff0ef          	jal	ra,40c <printint>
        i += 1;
 5c8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ca:	8bca                	mv	s7,s2
      state = 0;
 5cc:	4981                	li	s3,0
        i += 1;
 5ce:	bf15                	j	502 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d0:	03860563          	beq	a2,s8,5fa <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d4:	07b60963          	beq	a2,s11,646 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5d8:	07800793          	li	a5,120
 5dc:	fcf613e3          	bne	a2,a5,5a2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e0:	008b8913          	addi	s2,s7,8
 5e4:	4681                	li	a3,0
 5e6:	4641                	li	a2,16
 5e8:	000bb583          	ld	a1,0(s7)
 5ec:	855a                	mv	a0,s6
 5ee:	e1fff0ef          	jal	ra,40c <printint>
        i += 2;
 5f2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f4:	8bca                	mv	s7,s2
      state = 0;
 5f6:	4981                	li	s3,0
        i += 2;
 5f8:	b729                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fa:	008b8913          	addi	s2,s7,8
 5fe:	4685                	li	a3,1
 600:	4629                	li	a2,10
 602:	000bb583          	ld	a1,0(s7)
 606:	855a                	mv	a0,s6
 608:	e05ff0ef          	jal	ra,40c <printint>
        i += 2;
 60c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 60e:	8bca                	mv	s7,s2
      state = 0;
 610:	4981                	li	s3,0
        i += 2;
 612:	bdc5                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 614:	008b8913          	addi	s2,s7,8
 618:	4681                	li	a3,0
 61a:	4629                	li	a2,10
 61c:	000be583          	lwu	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	debff0ef          	jal	ra,40c <printint>
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	bde1                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	008b8913          	addi	s2,s7,8
 630:	4681                	li	a3,0
 632:	4629                	li	a2,10
 634:	000bb583          	ld	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	dd3ff0ef          	jal	ra,40c <printint>
        i += 1;
 63e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 640:	8bca                	mv	s7,s2
      state = 0;
 642:	4981                	li	s3,0
        i += 1;
 644:	bd7d                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 646:	008b8913          	addi	s2,s7,8
 64a:	4681                	li	a3,0
 64c:	4629                	li	a2,10
 64e:	000bb583          	ld	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	db9ff0ef          	jal	ra,40c <printint>
        i += 2;
 658:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
        i += 2;
 65e:	b555                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4641                	li	a2,16
 668:	000be583          	lwu	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	d9fff0ef          	jal	ra,40c <printint>
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
 676:	b571                	j	502 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4641                	li	a2,16
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	d87ff0ef          	jal	ra,40c <printint>
        i += 1;
 68a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 1;
 690:	bd8d                	j	502 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 692:	008b8793          	addi	a5,s7,8
 696:	f8f43423          	sd	a5,-120(s0)
 69a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 69e:	03000593          	li	a1,48
 6a2:	855a                	mv	a0,s6
 6a4:	d4bff0ef          	jal	ra,3ee <putc>
  putc(fd, 'x');
 6a8:	07800593          	li	a1,120
 6ac:	855a                	mv	a0,s6
 6ae:	d41ff0ef          	jal	ra,3ee <putc>
 6b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b4:	03c9d793          	srli	a5,s3,0x3c
 6b8:	97e6                	add	a5,a5,s9
 6ba:	0007c583          	lbu	a1,0(a5)
 6be:	855a                	mv	a0,s6
 6c0:	d2fff0ef          	jal	ra,3ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c4:	0992                	slli	s3,s3,0x4
 6c6:	397d                	addiw	s2,s2,-1
 6c8:	fe0916e3          	bnez	s2,6b4 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6cc:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bd05                	j	502 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6d4:	008b8913          	addi	s2,s7,8
 6d8:	000bc583          	lbu	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	d11ff0ef          	jal	ra,3ee <putc>
 6e2:	8bca                	mv	s7,s2
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	bd31                	j	502 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6e8:	008b8993          	addi	s3,s7,8
 6ec:	000bb903          	ld	s2,0(s7)
 6f0:	00090f63          	beqz	s2,70e <vprintf+0x266>
        for(; *s; s++)
 6f4:	00094583          	lbu	a1,0(s2)
 6f8:	c195                	beqz	a1,71c <vprintf+0x274>
          putc(fd, *s);
 6fa:	855a                	mv	a0,s6
 6fc:	cf3ff0ef          	jal	ra,3ee <putc>
        for(; *s; s++)
 700:	0905                	addi	s2,s2,1
 702:	00094583          	lbu	a1,0(s2)
 706:	f9f5                	bnez	a1,6fa <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 708:	8bce                	mv	s7,s3
      state = 0;
 70a:	4981                	li	s3,0
 70c:	bbdd                	j	502 <vprintf+0x5a>
          s = "(null)";
 70e:	00000917          	auipc	s2,0x0
 712:	23a90913          	addi	s2,s2,570 # 948 <malloc+0x12a>
        for(; *s; s++)
 716:	02800593          	li	a1,40
 71a:	b7c5                	j	6fa <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 71c:	8bce                	mv	s7,s3
      state = 0;
 71e:	4981                	li	s3,0
 720:	b3cd                	j	502 <vprintf+0x5a>
    }
  }
}
 722:	70e6                	ld	ra,120(sp)
 724:	7446                	ld	s0,112(sp)
 726:	74a6                	ld	s1,104(sp)
 728:	7906                	ld	s2,96(sp)
 72a:	69e6                	ld	s3,88(sp)
 72c:	6a46                	ld	s4,80(sp)
 72e:	6aa6                	ld	s5,72(sp)
 730:	6b06                	ld	s6,64(sp)
 732:	7be2                	ld	s7,56(sp)
 734:	7c42                	ld	s8,48(sp)
 736:	7ca2                	ld	s9,40(sp)
 738:	7d02                	ld	s10,32(sp)
 73a:	6de2                	ld	s11,24(sp)
 73c:	6109                	addi	sp,sp,128
 73e:	8082                	ret

0000000000000740 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 740:	715d                	addi	sp,sp,-80
 742:	ec06                	sd	ra,24(sp)
 744:	e822                	sd	s0,16(sp)
 746:	1000                	addi	s0,sp,32
 748:	e010                	sd	a2,0(s0)
 74a:	e414                	sd	a3,8(s0)
 74c:	e818                	sd	a4,16(s0)
 74e:	ec1c                	sd	a5,24(s0)
 750:	03043023          	sd	a6,32(s0)
 754:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75c:	8622                	mv	a2,s0
 75e:	d4bff0ef          	jal	ra,4a8 <vprintf>
}
 762:	60e2                	ld	ra,24(sp)
 764:	6442                	ld	s0,16(sp)
 766:	6161                	addi	sp,sp,80
 768:	8082                	ret

000000000000076a <printf>:

void
printf(const char *fmt, ...)
{
 76a:	711d                	addi	sp,sp,-96
 76c:	ec06                	sd	ra,24(sp)
 76e:	e822                	sd	s0,16(sp)
 770:	1000                	addi	s0,sp,32
 772:	e40c                	sd	a1,8(s0)
 774:	e810                	sd	a2,16(s0)
 776:	ec14                	sd	a3,24(s0)
 778:	f018                	sd	a4,32(s0)
 77a:	f41c                	sd	a5,40(s0)
 77c:	03043823          	sd	a6,48(s0)
 780:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 784:	00840613          	addi	a2,s0,8
 788:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78c:	85aa                	mv	a1,a0
 78e:	4505                	li	a0,1
 790:	d19ff0ef          	jal	ra,4a8 <vprintf>
}
 794:	60e2                	ld	ra,24(sp)
 796:	6442                	ld	s0,16(sp)
 798:	6125                	addi	sp,sp,96
 79a:	8082                	ret

000000000000079c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79c:	1141                	addi	sp,sp,-16
 79e:	e422                	sd	s0,8(sp)
 7a0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a6:	00001797          	auipc	a5,0x1
 7aa:	85a7b783          	ld	a5,-1958(a5) # 1000 <freep>
 7ae:	a02d                	j	7d8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b0:	4618                	lw	a4,8(a2)
 7b2:	9f2d                	addw	a4,a4,a1
 7b4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b8:	6398                	ld	a4,0(a5)
 7ba:	6310                	ld	a2,0(a4)
 7bc:	a83d                	j	7fa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7be:	ff852703          	lw	a4,-8(a0)
 7c2:	9f31                	addw	a4,a4,a2
 7c4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c6:	ff053683          	ld	a3,-16(a0)
 7ca:	a091                	j	80e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7cc:	6398                	ld	a4,0(a5)
 7ce:	00e7e463          	bltu	a5,a4,7d6 <free+0x3a>
 7d2:	00e6ea63          	bltu	a3,a4,7e6 <free+0x4a>
{
 7d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d8:	fed7fae3          	bgeu	a5,a3,7cc <free+0x30>
 7dc:	6398                	ld	a4,0(a5)
 7de:	00e6e463          	bltu	a3,a4,7e6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e2:	fee7eae3          	bltu	a5,a4,7d6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e6:	ff852583          	lw	a1,-8(a0)
 7ea:	6390                	ld	a2,0(a5)
 7ec:	02059813          	slli	a6,a1,0x20
 7f0:	01c85713          	srli	a4,a6,0x1c
 7f4:	9736                	add	a4,a4,a3
 7f6:	fae60de3          	beq	a2,a4,7b0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fe:	4790                	lw	a2,8(a5)
 800:	02061593          	slli	a1,a2,0x20
 804:	01c5d713          	srli	a4,a1,0x1c
 808:	973e                	add	a4,a4,a5
 80a:	fae68ae3          	beq	a3,a4,7be <free+0x22>
    p->s.ptr = bp->s.ptr;
 80e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 810:	00000717          	auipc	a4,0x0
 814:	7ef73823          	sd	a5,2032(a4) # 1000 <freep>
}
 818:	6422                	ld	s0,8(sp)
 81a:	0141                	addi	sp,sp,16
 81c:	8082                	ret

000000000000081e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 81e:	7139                	addi	sp,sp,-64
 820:	fc06                	sd	ra,56(sp)
 822:	f822                	sd	s0,48(sp)
 824:	f426                	sd	s1,40(sp)
 826:	f04a                	sd	s2,32(sp)
 828:	ec4e                	sd	s3,24(sp)
 82a:	e852                	sd	s4,16(sp)
 82c:	e456                	sd	s5,8(sp)
 82e:	e05a                	sd	s6,0(sp)
 830:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 832:	02051493          	slli	s1,a0,0x20
 836:	9081                	srli	s1,s1,0x20
 838:	04bd                	addi	s1,s1,15
 83a:	8091                	srli	s1,s1,0x4
 83c:	0014899b          	addiw	s3,s1,1
 840:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 842:	00000517          	auipc	a0,0x0
 846:	7be53503          	ld	a0,1982(a0) # 1000 <freep>
 84a:	c515                	beqz	a0,876 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84e:	4798                	lw	a4,8(a5)
 850:	02977f63          	bgeu	a4,s1,88e <malloc+0x70>
 854:	8a4e                	mv	s4,s3
 856:	0009871b          	sext.w	a4,s3
 85a:	6685                	lui	a3,0x1
 85c:	00d77363          	bgeu	a4,a3,862 <malloc+0x44>
 860:	6a05                	lui	s4,0x1
 862:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 866:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 86a:	00000917          	auipc	s2,0x0
 86e:	79690913          	addi	s2,s2,1942 # 1000 <freep>
  if(p == SBRK_ERROR)
 872:	5afd                	li	s5,-1
 874:	a885                	j	8e4 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 876:	00000797          	auipc	a5,0x0
 87a:	79a78793          	addi	a5,a5,1946 # 1010 <base>
 87e:	00000717          	auipc	a4,0x0
 882:	78f73123          	sd	a5,1922(a4) # 1000 <freep>
 886:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 888:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 88c:	b7e1                	j	854 <malloc+0x36>
      if(p->s.size == nunits)
 88e:	02e48c63          	beq	s1,a4,8c6 <malloc+0xa8>
        p->s.size -= nunits;
 892:	4137073b          	subw	a4,a4,s3
 896:	c798                	sw	a4,8(a5)
        p += p->s.size;
 898:	02071693          	slli	a3,a4,0x20
 89c:	01c6d713          	srli	a4,a3,0x1c
 8a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a6:	00000717          	auipc	a4,0x0
 8aa:	74a73d23          	sd	a0,1882(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ae:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b2:	70e2                	ld	ra,56(sp)
 8b4:	7442                	ld	s0,48(sp)
 8b6:	74a2                	ld	s1,40(sp)
 8b8:	7902                	ld	s2,32(sp)
 8ba:	69e2                	ld	s3,24(sp)
 8bc:	6a42                	ld	s4,16(sp)
 8be:	6aa2                	ld	s5,8(sp)
 8c0:	6b02                	ld	s6,0(sp)
 8c2:	6121                	addi	sp,sp,64
 8c4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c6:	6398                	ld	a4,0(a5)
 8c8:	e118                	sd	a4,0(a0)
 8ca:	bff1                	j	8a6 <malloc+0x88>
  hp->s.size = nu;
 8cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d0:	0541                	addi	a0,a0,16
 8d2:	ecbff0ef          	jal	ra,79c <free>
  return freep;
 8d6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8da:	dd61                	beqz	a0,8b2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8de:	4798                	lw	a4,8(a5)
 8e0:	fa9777e3          	bgeu	a4,s1,88e <malloc+0x70>
    if(p == freep)
 8e4:	00093703          	ld	a4,0(s2)
 8e8:	853e                	mv	a0,a5
 8ea:	fef719e3          	bne	a4,a5,8dc <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 8ee:	8552                	mv	a0,s4
 8f0:	a2bff0ef          	jal	ra,31a <sbrk>
  if(p == SBRK_ERROR)
 8f4:	fd551ce3          	bne	a0,s5,8cc <malloc+0xae>
        return 0;
 8f8:	4501                	li	a0,0
 8fa:	bf65                	j	8b2 <malloc+0x94>
