
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
  5c:	8e850513          	addi	a0,a0,-1816 # 940 <malloc+0xea>
  60:	742000ef          	jal	ra,7a2 <printf>
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
  9a:	8ea50513          	addi	a0,a0,-1814 # 980 <malloc+0x12a>
  9e:	704000ef          	jal	ra,7a2 <printf>
  exit(0);
  a2:	4501                	li	a0,0
  a4:	2aa000ef          	jal	ra,34e <exit>
      printf("FAIL: parent page %d changed to %c\n", k, p[k*4096]);
  a8:	00001517          	auipc	a0,0x1
  ac:	8b050513          	addi	a0,a0,-1872 # 958 <malloc+0x102>
  b0:	6f2000ef          	jal	ra,7a2 <printf>
      exit(1);
  b4:	4505                	li	a0,1
  b6:	298000ef          	jal	ra,34e <exit>

00000000000000ba <start>:
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
 236:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x640>
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

00000000000003ee <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3ee:	48d9                	li	a7,22
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3f6:	48dd                	li	a7,23
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3fe:	48e1                	li	a7,24
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 406:	48e5                	li	a7,25
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 40e:	48e9                	li	a7,26
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 416:	48ed                	li	a7,27
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 41e:	48f1                	li	a7,28
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 426:	1101                	addi	sp,sp,-32
 428:	ec06                	sd	ra,24(sp)
 42a:	e822                	sd	s0,16(sp)
 42c:	1000                	addi	s0,sp,32
 42e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 432:	4605                	li	a2,1
 434:	fef40593          	addi	a1,s0,-17
 438:	f37ff0ef          	jal	ra,36e <write>
}
 43c:	60e2                	ld	ra,24(sp)
 43e:	6442                	ld	s0,16(sp)
 440:	6105                	addi	sp,sp,32
 442:	8082                	ret

0000000000000444 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 444:	715d                	addi	sp,sp,-80
 446:	e486                	sd	ra,72(sp)
 448:	e0a2                	sd	s0,64(sp)
 44a:	fc26                	sd	s1,56(sp)
 44c:	f84a                	sd	s2,48(sp)
 44e:	f44e                	sd	s3,40(sp)
 450:	0880                	addi	s0,sp,80
 452:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 454:	c299                	beqz	a3,45a <printint+0x16>
 456:	0805c163          	bltz	a1,4d8 <printint+0x94>
  neg = 0;
 45a:	4881                	li	a7,0
 45c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 460:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 462:	00000517          	auipc	a0,0x0
 466:	52e50513          	addi	a0,a0,1326 # 990 <digits>
 46a:	883e                	mv	a6,a5
 46c:	2785                	addiw	a5,a5,1
 46e:	02c5f733          	remu	a4,a1,a2
 472:	972a                	add	a4,a4,a0
 474:	00074703          	lbu	a4,0(a4)
 478:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 47c:	872e                	mv	a4,a1
 47e:	02c5d5b3          	divu	a1,a1,a2
 482:	0685                	addi	a3,a3,1
 484:	fec773e3          	bgeu	a4,a2,46a <printint+0x26>
  if(neg)
 488:	00088b63          	beqz	a7,49e <printint+0x5a>
    buf[i++] = '-';
 48c:	fd078793          	addi	a5,a5,-48
 490:	97a2                	add	a5,a5,s0
 492:	02d00713          	li	a4,45
 496:	fee78423          	sb	a4,-24(a5)
 49a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 49e:	02f05663          	blez	a5,4ca <printint+0x86>
 4a2:	fb840713          	addi	a4,s0,-72
 4a6:	00f704b3          	add	s1,a4,a5
 4aa:	fff70993          	addi	s3,a4,-1
 4ae:	99be                	add	s3,s3,a5
 4b0:	37fd                	addiw	a5,a5,-1
 4b2:	1782                	slli	a5,a5,0x20
 4b4:	9381                	srli	a5,a5,0x20
 4b6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4ba:	fff4c583          	lbu	a1,-1(s1)
 4be:	854a                	mv	a0,s2
 4c0:	f67ff0ef          	jal	ra,426 <putc>
  while(--i >= 0)
 4c4:	14fd                	addi	s1,s1,-1
 4c6:	ff349ae3          	bne	s1,s3,4ba <printint+0x76>
}
 4ca:	60a6                	ld	ra,72(sp)
 4cc:	6406                	ld	s0,64(sp)
 4ce:	74e2                	ld	s1,56(sp)
 4d0:	7942                	ld	s2,48(sp)
 4d2:	79a2                	ld	s3,40(sp)
 4d4:	6161                	addi	sp,sp,80
 4d6:	8082                	ret
    x = -xx;
 4d8:	40b005b3          	neg	a1,a1
    neg = 1;
 4dc:	4885                	li	a7,1
    x = -xx;
 4de:	bfbd                	j	45c <printint+0x18>

00000000000004e0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e0:	7119                	addi	sp,sp,-128
 4e2:	fc86                	sd	ra,120(sp)
 4e4:	f8a2                	sd	s0,112(sp)
 4e6:	f4a6                	sd	s1,104(sp)
 4e8:	f0ca                	sd	s2,96(sp)
 4ea:	ecce                	sd	s3,88(sp)
 4ec:	e8d2                	sd	s4,80(sp)
 4ee:	e4d6                	sd	s5,72(sp)
 4f0:	e0da                	sd	s6,64(sp)
 4f2:	fc5e                	sd	s7,56(sp)
 4f4:	f862                	sd	s8,48(sp)
 4f6:	f466                	sd	s9,40(sp)
 4f8:	f06a                	sd	s10,32(sp)
 4fa:	ec6e                	sd	s11,24(sp)
 4fc:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4fe:	0005c903          	lbu	s2,0(a1)
 502:	24090c63          	beqz	s2,75a <vprintf+0x27a>
 506:	8b2a                	mv	s6,a0
 508:	8a2e                	mv	s4,a1
 50a:	8bb2                	mv	s7,a2
  state = 0;
 50c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 50e:	4481                	li	s1,0
 510:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 512:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 516:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 51a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 51e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 522:	00000c97          	auipc	s9,0x0
 526:	46ec8c93          	addi	s9,s9,1134 # 990 <digits>
 52a:	a005                	j	54a <vprintf+0x6a>
        putc(fd, c0);
 52c:	85ca                	mv	a1,s2
 52e:	855a                	mv	a0,s6
 530:	ef7ff0ef          	jal	ra,426 <putc>
 534:	a019                	j	53a <vprintf+0x5a>
    } else if(state == '%'){
 536:	03598263          	beq	s3,s5,55a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 53a:	2485                	addiw	s1,s1,1
 53c:	8726                	mv	a4,s1
 53e:	009a07b3          	add	a5,s4,s1
 542:	0007c903          	lbu	s2,0(a5)
 546:	20090a63          	beqz	s2,75a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 54a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 54e:	fe0994e3          	bnez	s3,536 <vprintf+0x56>
      if(c0 == '%'){
 552:	fd579de3          	bne	a5,s5,52c <vprintf+0x4c>
        state = '%';
 556:	89be                	mv	s3,a5
 558:	b7cd                	j	53a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 55a:	c3c1                	beqz	a5,5da <vprintf+0xfa>
 55c:	00ea06b3          	add	a3,s4,a4
 560:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 564:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 566:	c681                	beqz	a3,56e <vprintf+0x8e>
 568:	9752                	add	a4,a4,s4
 56a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 56e:	03878e63          	beq	a5,s8,5aa <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 572:	05a78863          	beq	a5,s10,5c2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 576:	0db78b63          	beq	a5,s11,64c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 57a:	07800713          	li	a4,120
 57e:	10e78d63          	beq	a5,a4,698 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 582:	07000713          	li	a4,112
 586:	14e78263          	beq	a5,a4,6ca <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 58a:	06300713          	li	a4,99
 58e:	16e78f63          	beq	a5,a4,70c <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 592:	07300713          	li	a4,115
 596:	18e78563          	beq	a5,a4,720 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 59a:	05579063          	bne	a5,s5,5da <vprintf+0xfa>
        putc(fd, '%');
 59e:	85d6                	mv	a1,s5
 5a0:	855a                	mv	a0,s6
 5a2:	e85ff0ef          	jal	ra,426 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	bf49                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5aa:	008b8913          	addi	s2,s7,8
 5ae:	4685                	li	a3,1
 5b0:	4629                	li	a2,10
 5b2:	000ba583          	lw	a1,0(s7)
 5b6:	855a                	mv	a0,s6
 5b8:	e8dff0ef          	jal	ra,444 <printint>
 5bc:	8bca                	mv	s7,s2
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bfad                	j	53a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5c2:	03868663          	beq	a3,s8,5ee <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c6:	05a68163          	beq	a3,s10,608 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5ca:	09b68d63          	beq	a3,s11,664 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5ce:	03a68f63          	beq	a3,s10,60c <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5d2:	07800793          	li	a5,120
 5d6:	0cf68d63          	beq	a3,a5,6b0 <vprintf+0x1d0>
        putc(fd, '%');
 5da:	85d6                	mv	a1,s5
 5dc:	855a                	mv	a0,s6
 5de:	e49ff0ef          	jal	ra,426 <putc>
        putc(fd, c0);
 5e2:	85ca                	mv	a1,s2
 5e4:	855a                	mv	a0,s6
 5e6:	e41ff0ef          	jal	ra,426 <putc>
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b7b9                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4685                	li	a3,1
 5f4:	4629                	li	a2,10
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	e49ff0ef          	jal	ra,444 <printint>
        i += 1;
 600:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
        i += 1;
 606:	bf15                	j	53a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 608:	03860563          	beq	a2,s8,632 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 60c:	07b60963          	beq	a2,s11,67e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 610:	07800793          	li	a5,120
 614:	fcf613e3          	bne	a2,a5,5da <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 618:	008b8913          	addi	s2,s7,8
 61c:	4681                	li	a3,0
 61e:	4641                	li	a2,16
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	e1fff0ef          	jal	ra,444 <printint>
        i += 2;
 62a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 2;
 630:	b729                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 632:	008b8913          	addi	s2,s7,8
 636:	4685                	li	a3,1
 638:	4629                	li	a2,10
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	e05ff0ef          	jal	ra,444 <printint>
        i += 2;
 644:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
        i += 2;
 64a:	bdc5                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000be583          	lwu	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	debff0ef          	jal	ra,444 <printint>
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	bde1                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	dd3ff0ef          	jal	ra,444 <printint>
        i += 1;
 676:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
        i += 1;
 67c:	bd7d                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4629                	li	a2,10
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	db9ff0ef          	jal	ra,444 <printint>
        i += 2;
 690:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
        i += 2;
 696:	b555                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000be583          	lwu	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	d9fff0ef          	jal	ra,444 <printint>
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b571                	j	53a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b0:	008b8913          	addi	s2,s7,8
 6b4:	4681                	li	a3,0
 6b6:	4641                	li	a2,16
 6b8:	000bb583          	ld	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	d87ff0ef          	jal	ra,444 <printint>
        i += 1;
 6c2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c4:	8bca                	mv	s7,s2
      state = 0;
 6c6:	4981                	li	s3,0
        i += 1;
 6c8:	bd8d                	j	53a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6ca:	008b8793          	addi	a5,s7,8
 6ce:	f8f43423          	sd	a5,-120(s0)
 6d2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d6:	03000593          	li	a1,48
 6da:	855a                	mv	a0,s6
 6dc:	d4bff0ef          	jal	ra,426 <putc>
  putc(fd, 'x');
 6e0:	07800593          	li	a1,120
 6e4:	855a                	mv	a0,s6
 6e6:	d41ff0ef          	jal	ra,426 <putc>
 6ea:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ec:	03c9d793          	srli	a5,s3,0x3c
 6f0:	97e6                	add	a5,a5,s9
 6f2:	0007c583          	lbu	a1,0(a5)
 6f6:	855a                	mv	a0,s6
 6f8:	d2fff0ef          	jal	ra,426 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fc:	0992                	slli	s3,s3,0x4
 6fe:	397d                	addiw	s2,s2,-1
 700:	fe0916e3          	bnez	s2,6ec <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 704:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd05                	j	53a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 70c:	008b8913          	addi	s2,s7,8
 710:	000bc583          	lbu	a1,0(s7)
 714:	855a                	mv	a0,s6
 716:	d11ff0ef          	jal	ra,426 <putc>
 71a:	8bca                	mv	s7,s2
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bd31                	j	53a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 720:	008b8993          	addi	s3,s7,8
 724:	000bb903          	ld	s2,0(s7)
 728:	00090f63          	beqz	s2,746 <vprintf+0x266>
        for(; *s; s++)
 72c:	00094583          	lbu	a1,0(s2)
 730:	c195                	beqz	a1,754 <vprintf+0x274>
          putc(fd, *s);
 732:	855a                	mv	a0,s6
 734:	cf3ff0ef          	jal	ra,426 <putc>
        for(; *s; s++)
 738:	0905                	addi	s2,s2,1
 73a:	00094583          	lbu	a1,0(s2)
 73e:	f9f5                	bnez	a1,732 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 740:	8bce                	mv	s7,s3
      state = 0;
 742:	4981                	li	s3,0
 744:	bbdd                	j	53a <vprintf+0x5a>
          s = "(null)";
 746:	00000917          	auipc	s2,0x0
 74a:	24290913          	addi	s2,s2,578 # 988 <malloc+0x132>
        for(; *s; s++)
 74e:	02800593          	li	a1,40
 752:	b7c5                	j	732 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 754:	8bce                	mv	s7,s3
      state = 0;
 756:	4981                	li	s3,0
 758:	b3cd                	j	53a <vprintf+0x5a>
    }
  }
}
 75a:	70e6                	ld	ra,120(sp)
 75c:	7446                	ld	s0,112(sp)
 75e:	74a6                	ld	s1,104(sp)
 760:	7906                	ld	s2,96(sp)
 762:	69e6                	ld	s3,88(sp)
 764:	6a46                	ld	s4,80(sp)
 766:	6aa6                	ld	s5,72(sp)
 768:	6b06                	ld	s6,64(sp)
 76a:	7be2                	ld	s7,56(sp)
 76c:	7c42                	ld	s8,48(sp)
 76e:	7ca2                	ld	s9,40(sp)
 770:	7d02                	ld	s10,32(sp)
 772:	6de2                	ld	s11,24(sp)
 774:	6109                	addi	sp,sp,128
 776:	8082                	ret

0000000000000778 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 778:	715d                	addi	sp,sp,-80
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e010                	sd	a2,0(s0)
 782:	e414                	sd	a3,8(s0)
 784:	e818                	sd	a4,16(s0)
 786:	ec1c                	sd	a5,24(s0)
 788:	03043023          	sd	a6,32(s0)
 78c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 790:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 794:	8622                	mv	a2,s0
 796:	d4bff0ef          	jal	ra,4e0 <vprintf>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6161                	addi	sp,sp,80
 7a0:	8082                	ret

00000000000007a2 <printf>:

void
printf(const char *fmt, ...)
{
 7a2:	711d                	addi	sp,sp,-96
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e40c                	sd	a1,8(s0)
 7ac:	e810                	sd	a2,16(s0)
 7ae:	ec14                	sd	a3,24(s0)
 7b0:	f018                	sd	a4,32(s0)
 7b2:	f41c                	sd	a5,40(s0)
 7b4:	03043823          	sd	a6,48(s0)
 7b8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7bc:	00840613          	addi	a2,s0,8
 7c0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c4:	85aa                	mv	a1,a0
 7c6:	4505                	li	a0,1
 7c8:	d19ff0ef          	jal	ra,4e0 <vprintf>
}
 7cc:	60e2                	ld	ra,24(sp)
 7ce:	6442                	ld	s0,16(sp)
 7d0:	6125                	addi	sp,sp,96
 7d2:	8082                	ret

00000000000007d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d4:	1141                	addi	sp,sp,-16
 7d6:	e422                	sd	s0,8(sp)
 7d8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7da:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7de:	00001797          	auipc	a5,0x1
 7e2:	8227b783          	ld	a5,-2014(a5) # 1000 <freep>
 7e6:	a02d                	j	810 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e8:	4618                	lw	a4,8(a2)
 7ea:	9f2d                	addw	a4,a4,a1
 7ec:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f0:	6398                	ld	a4,0(a5)
 7f2:	6310                	ld	a2,0(a4)
 7f4:	a83d                	j	832 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f6:	ff852703          	lw	a4,-8(a0)
 7fa:	9f31                	addw	a4,a4,a2
 7fc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fe:	ff053683          	ld	a3,-16(a0)
 802:	a091                	j	846 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 804:	6398                	ld	a4,0(a5)
 806:	00e7e463          	bltu	a5,a4,80e <free+0x3a>
 80a:	00e6ea63          	bltu	a3,a4,81e <free+0x4a>
{
 80e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 810:	fed7fae3          	bgeu	a5,a3,804 <free+0x30>
 814:	6398                	ld	a4,0(a5)
 816:	00e6e463          	bltu	a3,a4,81e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81a:	fee7eae3          	bltu	a5,a4,80e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 81e:	ff852583          	lw	a1,-8(a0)
 822:	6390                	ld	a2,0(a5)
 824:	02059813          	slli	a6,a1,0x20
 828:	01c85713          	srli	a4,a6,0x1c
 82c:	9736                	add	a4,a4,a3
 82e:	fae60de3          	beq	a2,a4,7e8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 836:	4790                	lw	a2,8(a5)
 838:	02061593          	slli	a1,a2,0x20
 83c:	01c5d713          	srli	a4,a1,0x1c
 840:	973e                	add	a4,a4,a5
 842:	fae68ae3          	beq	a3,a4,7f6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 846:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 848:	00000717          	auipc	a4,0x0
 84c:	7af73c23          	sd	a5,1976(a4) # 1000 <freep>
}
 850:	6422                	ld	s0,8(sp)
 852:	0141                	addi	sp,sp,16
 854:	8082                	ret

0000000000000856 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 856:	7139                	addi	sp,sp,-64
 858:	fc06                	sd	ra,56(sp)
 85a:	f822                	sd	s0,48(sp)
 85c:	f426                	sd	s1,40(sp)
 85e:	f04a                	sd	s2,32(sp)
 860:	ec4e                	sd	s3,24(sp)
 862:	e852                	sd	s4,16(sp)
 864:	e456                	sd	s5,8(sp)
 866:	e05a                	sd	s6,0(sp)
 868:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 86a:	02051493          	slli	s1,a0,0x20
 86e:	9081                	srli	s1,s1,0x20
 870:	04bd                	addi	s1,s1,15
 872:	8091                	srli	s1,s1,0x4
 874:	0014899b          	addiw	s3,s1,1
 878:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 87a:	00000517          	auipc	a0,0x0
 87e:	78653503          	ld	a0,1926(a0) # 1000 <freep>
 882:	c515                	beqz	a0,8ae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 886:	4798                	lw	a4,8(a5)
 888:	02977f63          	bgeu	a4,s1,8c6 <malloc+0x70>
 88c:	8a4e                	mv	s4,s3
 88e:	0009871b          	sext.w	a4,s3
 892:	6685                	lui	a3,0x1
 894:	00d77363          	bgeu	a4,a3,89a <malloc+0x44>
 898:	6a05                	lui	s4,0x1
 89a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a2:	00000917          	auipc	s2,0x0
 8a6:	75e90913          	addi	s2,s2,1886 # 1000 <freep>
  if(p == SBRK_ERROR)
 8aa:	5afd                	li	s5,-1
 8ac:	a885                	j	91c <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8ae:	00000797          	auipc	a5,0x0
 8b2:	76278793          	addi	a5,a5,1890 # 1010 <base>
 8b6:	00000717          	auipc	a4,0x0
 8ba:	74f73523          	sd	a5,1866(a4) # 1000 <freep>
 8be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c4:	b7e1                	j	88c <malloc+0x36>
      if(p->s.size == nunits)
 8c6:	02e48c63          	beq	s1,a4,8fe <malloc+0xa8>
        p->s.size -= nunits;
 8ca:	4137073b          	subw	a4,a4,s3
 8ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d0:	02071693          	slli	a3,a4,0x20
 8d4:	01c6d713          	srli	a4,a3,0x1c
 8d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8de:	00000717          	auipc	a4,0x0
 8e2:	72a73123          	sd	a0,1826(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ea:	70e2                	ld	ra,56(sp)
 8ec:	7442                	ld	s0,48(sp)
 8ee:	74a2                	ld	s1,40(sp)
 8f0:	7902                	ld	s2,32(sp)
 8f2:	69e2                	ld	s3,24(sp)
 8f4:	6a42                	ld	s4,16(sp)
 8f6:	6aa2                	ld	s5,8(sp)
 8f8:	6b02                	ld	s6,0(sp)
 8fa:	6121                	addi	sp,sp,64
 8fc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8fe:	6398                	ld	a4,0(a5)
 900:	e118                	sd	a4,0(a0)
 902:	bff1                	j	8de <malloc+0x88>
  hp->s.size = nu;
 904:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 908:	0541                	addi	a0,a0,16
 90a:	ecbff0ef          	jal	ra,7d4 <free>
  return freep;
 90e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 912:	dd61                	beqz	a0,8ea <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 914:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 916:	4798                	lw	a4,8(a5)
 918:	fa9777e3          	bgeu	a4,s1,8c6 <malloc+0x70>
    if(p == freep)
 91c:	00093703          	ld	a4,0(s2)
 920:	853e                	mv	a0,a5
 922:	fef719e3          	bne	a4,a5,914 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 926:	8552                	mv	a0,s4
 928:	9f3ff0ef          	jal	ra,31a <sbrk>
  if(p == SBRK_ERROR)
 92c:	fd551ce3          	bne	a0,s5,904 <malloc+0xae>
        return 0;
 930:	4501                	li	a0,0
 932:	bf65                	j	8ea <malloc+0x94>
