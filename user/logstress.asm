
user/_logstress：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
main(int argc, char **argv)
{
  int fd, n;
  enum { N = 250, SZ=2000 };
  
  for (int i = 1; i < argc; i++){
   0:	4785                	li	a5,1
   2:	0ea7de63          	bge	a5,a0,fe <main+0xfe>
{
   6:	7139                	addi	sp,sp,-64
   8:	fc06                	sd	ra,56(sp)
   a:	f822                	sd	s0,48(sp)
   c:	f426                	sd	s1,40(sp)
   e:	f04a                	sd	s2,32(sp)
  10:	ec4e                	sd	s3,24(sp)
  12:	e852                	sd	s4,16(sp)
  14:	0080                	addi	s0,sp,64
  16:	892a                	mv	s2,a0
  18:	89ae                	mv	s3,a1
  for (int i = 1; i < argc; i++){
  1a:	4485                	li	s1,1
  1c:	a011                	j	20 <main+0x20>
  1e:	84be                	mv	s1,a5
    int pid1 = fork();
  20:	36e000ef          	jal	ra,38e <fork>
    if(pid1 < 0){
  24:	00054963          	bltz	a0,36 <main+0x36>
      printf("%s: fork failed\n", argv[0]);
      exit(1);
    }
    if(pid1 == 0) {
  28:	c115                	beqz	a0,4c <main+0x4c>
  for (int i = 1; i < argc; i++){
  2a:	0014879b          	addiw	a5,s1,1
  2e:	fef918e3          	bne	s2,a5,1e <main+0x1e>
  32:	4905                	li	s2,1
  34:	a879                	j	d2 <main+0xd2>
      printf("%s: fork failed\n", argv[0]);
  36:	0009b583          	ld	a1,0(s3)
  3a:	00001517          	auipc	a0,0x1
  3e:	93650513          	addi	a0,a0,-1738 # 970 <malloc+0xea>
  42:	790000ef          	jal	ra,7d2 <printf>
      exit(1);
  46:	4505                	li	a0,1
  48:	34e000ef          	jal	ra,396 <exit>
      fd = open(argv[i], O_CREATE | O_RDWR);
  4c:	00349a13          	slli	s4,s1,0x3
  50:	9a4e                	add	s4,s4,s3
  52:	20200593          	li	a1,514
  56:	000a3503          	ld	a0,0(s4)
  5a:	37c000ef          	jal	ra,3d6 <open>
  5e:	892a                	mv	s2,a0
      if(fd < 0){
  60:	04054163          	bltz	a0,a2 <main+0xa2>
        printf("%s: create %s failed\n", argv[0], argv[i]);
        exit(1);
      }
      memset(buf, '0'+i, SZ);
  64:	7d000613          	li	a2,2000
  68:	0304859b          	addiw	a1,s1,48
  6c:	00001517          	auipc	a0,0x1
  70:	fa450513          	addi	a0,a0,-92 # 1010 <buf>
  74:	110000ef          	jal	ra,184 <memset>
  78:	0fa00493          	li	s1,250
      for(i = 0; i < N; i++){
        if((n = write(fd, buf, SZ)) != SZ){
  7c:	00001997          	auipc	s3,0x1
  80:	f9498993          	addi	s3,s3,-108 # 1010 <buf>
  84:	7d000613          	li	a2,2000
  88:	85ce                	mv	a1,s3
  8a:	854a                	mv	a0,s2
  8c:	32a000ef          	jal	ra,3b6 <write>
  90:	7d000793          	li	a5,2000
  94:	02f51463          	bne	a0,a5,bc <main+0xbc>
      for(i = 0; i < N; i++){
  98:	34fd                	addiw	s1,s1,-1
  9a:	f4ed                	bnez	s1,84 <main+0x84>
          printf("write failed %d\n", n);
          exit(1);
        }
      }
      exit(0);
  9c:	4501                	li	a0,0
  9e:	2f8000ef          	jal	ra,396 <exit>
        printf("%s: create %s failed\n", argv[0], argv[i]);
  a2:	000a3603          	ld	a2,0(s4)
  a6:	0009b583          	ld	a1,0(s3)
  aa:	00001517          	auipc	a0,0x1
  ae:	8de50513          	addi	a0,a0,-1826 # 988 <malloc+0x102>
  b2:	720000ef          	jal	ra,7d2 <printf>
        exit(1);
  b6:	4505                	li	a0,1
  b8:	2de000ef          	jal	ra,396 <exit>
          printf("write failed %d\n", n);
  bc:	85aa                	mv	a1,a0
  be:	00001517          	auipc	a0,0x1
  c2:	8e250513          	addi	a0,a0,-1822 # 9a0 <malloc+0x11a>
  c6:	70c000ef          	jal	ra,7d2 <printf>
          exit(1);
  ca:	4505                	li	a0,1
  cc:	2ca000ef          	jal	ra,396 <exit>
    }
  }
  int xstatus;
  for(int i = 1; i < argc; i++){
  d0:	893e                	mv	s2,a5
    wait(&xstatus);
  d2:	fcc40513          	addi	a0,s0,-52
  d6:	2c8000ef          	jal	ra,39e <wait>
    if(xstatus != 0)
  da:	fcc42503          	lw	a0,-52(s0)
  de:	ed11                	bnez	a0,fa <main+0xfa>
  for(int i = 1; i < argc; i++){
  e0:	0019079b          	addiw	a5,s2,1
  e4:	ff2496e3          	bne	s1,s2,d0 <main+0xd0>
      exit(xstatus);
  }
  return 0;
}
  e8:	4501                	li	a0,0
  ea:	70e2                	ld	ra,56(sp)
  ec:	7442                	ld	s0,48(sp)
  ee:	74a2                	ld	s1,40(sp)
  f0:	7902                	ld	s2,32(sp)
  f2:	69e2                	ld	s3,24(sp)
  f4:	6a42                	ld	s4,16(sp)
  f6:	6121                	addi	sp,sp,64
  f8:	8082                	ret
      exit(xstatus);
  fa:	29c000ef          	jal	ra,396 <exit>
}
  fe:	4501                	li	a0,0
 100:	8082                	ret

0000000000000102 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 10a:	ef7ff0ef          	jal	ra,0 <main>
  exit(r);
 10e:	288000ef          	jal	ra,396 <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	87aa                	mv	a5,a0
 11a:	0585                	addi	a1,a1,1
 11c:	0785                	addi	a5,a5,1
 11e:	fff5c703          	lbu	a4,-1(a1)
 122:	fee78fa3          	sb	a4,-1(a5)
 126:	fb75                	bnez	a4,11a <strcpy+0x8>
    ;
  return os;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb91                	beqz	a5,14c <strcmp+0x1e>
 13a:	0005c703          	lbu	a4,0(a1)
 13e:	00f71763          	bne	a4,a5,14c <strcmp+0x1e>
    p++, q++;
 142:	0505                	addi	a0,a0,1
 144:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbe5                	bnez	a5,13a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14c:	0005c503          	lbu	a0,0(a1)
}
 150:	40a7853b          	subw	a0,a5,a0
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret

000000000000015a <strlen>:

uint
strlen(const char *s)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf91                	beqz	a5,180 <strlen+0x26>
 166:	0505                	addi	a0,a0,1
 168:	87aa                	mv	a5,a0
 16a:	4685                	li	a3,1
 16c:	9e89                	subw	a3,a3,a0
 16e:	00f6853b          	addw	a0,a3,a5
 172:	0785                	addi	a5,a5,1
 174:	fff7c703          	lbu	a4,-1(a5)
 178:	fb7d                	bnez	a4,16e <strlen+0x14>
    ;
  return n;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  for(n = 0; s[n]; n++)
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strlen+0x20>

0000000000000184 <memset>:

void*
memset(void *dst, int c, uint n)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18a:	ca19                	beqz	a2,1a0 <memset+0x1c>
 18c:	87aa                	mv	a5,a0
 18e:	1602                	slli	a2,a2,0x20
 190:	9201                	srli	a2,a2,0x20
 192:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	addi	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x12>
  }
  return dst;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb99                	beqz	a5,1c6 <strchr+0x20>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1a>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xc>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <strchr+0x1a>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	addi	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	1080                	addi	s0,sp,96
 1e0:	8baa                	mv	s7,a0
 1e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	892a                	mv	s2,a0
 1e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e8:	4aa9                	li	s5,10
 1ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	2485                	addiw	s1,s1,1
 1f0:	0344d663          	bge	s1,s4,21c <gets+0x52>
    cc = read(0, &c, 1);
 1f4:	4605                	li	a2,1
 1f6:	faf40593          	addi	a1,s0,-81
 1fa:	4501                	li	a0,0
 1fc:	1b2000ef          	jal	ra,3ae <read>
    if(cc < 1)
 200:	00a05e63          	blez	a0,21c <gets+0x52>
    buf[i++] = c;
 204:	faf44783          	lbu	a5,-81(s0)
 208:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20c:	01578763          	beq	a5,s5,21a <gets+0x50>
 210:	0905                	addi	s2,s2,1
 212:	fd679de3          	bne	a5,s6,1ec <gets+0x22>
  for(i=0; i+1 < max; ){
 216:	89a6                	mv	s3,s1
 218:	a011                	j	21c <gets+0x52>
 21a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21c:	99de                	add	s3,s3,s7
 21e:	00098023          	sb	zero,0(s3)
  return buf;
}
 222:	855e                	mv	a0,s7
 224:	60e6                	ld	ra,88(sp)
 226:	6446                	ld	s0,80(sp)
 228:	64a6                	ld	s1,72(sp)
 22a:	6906                	ld	s2,64(sp)
 22c:	79e2                	ld	s3,56(sp)
 22e:	7a42                	ld	s4,48(sp)
 230:	7aa2                	ld	s5,40(sp)
 232:	7b02                	ld	s6,32(sp)
 234:	6be2                	ld	s7,24(sp)
 236:	6125                	addi	sp,sp,96
 238:	8082                	ret

000000000000023a <stat>:

int
stat(const char *n, struct stat *st)
{
 23a:	1101                	addi	sp,sp,-32
 23c:	ec06                	sd	ra,24(sp)
 23e:	e822                	sd	s0,16(sp)
 240:	e426                	sd	s1,8(sp)
 242:	e04a                	sd	s2,0(sp)
 244:	1000                	addi	s0,sp,32
 246:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 248:	4581                	li	a1,0
 24a:	18c000ef          	jal	ra,3d6 <open>
  if(fd < 0)
 24e:	02054163          	bltz	a0,270 <stat+0x36>
 252:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 254:	85ca                	mv	a1,s2
 256:	198000ef          	jal	ra,3ee <fstat>
 25a:	892a                	mv	s2,a0
  close(fd);
 25c:	8526                	mv	a0,s1
 25e:	160000ef          	jal	ra,3be <close>
  return r;
}
 262:	854a                	mv	a0,s2
 264:	60e2                	ld	ra,24(sp)
 266:	6442                	ld	s0,16(sp)
 268:	64a2                	ld	s1,8(sp)
 26a:	6902                	ld	s2,0(sp)
 26c:	6105                	addi	sp,sp,32
 26e:	8082                	ret
    return -1;
 270:	597d                	li	s2,-1
 272:	bfc5                	j	262 <stat+0x28>

0000000000000274 <atoi>:

int
atoi(const char *s)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27a:	00054683          	lbu	a3,0(a0)
 27e:	fd06879b          	addiw	a5,a3,-48
 282:	0ff7f793          	zext.b	a5,a5
 286:	4625                	li	a2,9
 288:	02f66863          	bltu	a2,a5,2b8 <atoi+0x44>
 28c:	872a                	mv	a4,a0
  n = 0;
 28e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 290:	0705                	addi	a4,a4,1
 292:	0025179b          	slliw	a5,a0,0x2
 296:	9fa9                	addw	a5,a5,a0
 298:	0017979b          	slliw	a5,a5,0x1
 29c:	9fb5                	addw	a5,a5,a3
 29e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a2:	00074683          	lbu	a3,0(a4)
 2a6:	fd06879b          	addiw	a5,a3,-48
 2aa:	0ff7f793          	zext.b	a5,a5
 2ae:	fef671e3          	bgeu	a2,a5,290 <atoi+0x1c>
  return n;
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
  n = 0;
 2b8:	4501                	li	a0,0
 2ba:	bfe5                	j	2b2 <atoi+0x3e>

00000000000002bc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e422                	sd	s0,8(sp)
 2c0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c2:	02b57463          	bgeu	a0,a1,2ea <memmove+0x2e>
    while(n-- > 0)
 2c6:	00c05f63          	blez	a2,2e4 <memmove+0x28>
 2ca:	1602                	slli	a2,a2,0x20
 2cc:	9201                	srli	a2,a2,0x20
 2ce:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d4:	0585                	addi	a1,a1,1
 2d6:	0705                	addi	a4,a4,1
 2d8:	fff5c683          	lbu	a3,-1(a1)
 2dc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
    dst += n;
 2ea:	00c50733          	add	a4,a0,a2
    src += n;
 2ee:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f0:	fec05ae3          	blez	a2,2e4 <memmove+0x28>
 2f4:	fff6079b          	addiw	a5,a2,-1
 2f8:	1782                	slli	a5,a5,0x20
 2fa:	9381                	srli	a5,a5,0x20
 2fc:	fff7c793          	not	a5,a5
 300:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 302:	15fd                	addi	a1,a1,-1
 304:	177d                	addi	a4,a4,-1
 306:	0005c683          	lbu	a3,0(a1)
 30a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30e:	fee79ae3          	bne	a5,a4,302 <memmove+0x46>
 312:	bfc9                	j	2e4 <memmove+0x28>

0000000000000314 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 31a:	ca05                	beqz	a2,34a <memcmp+0x36>
 31c:	fff6069b          	addiw	a3,a2,-1
 320:	1682                	slli	a3,a3,0x20
 322:	9281                	srli	a3,a3,0x20
 324:	0685                	addi	a3,a3,1
 326:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 328:	00054783          	lbu	a5,0(a0)
 32c:	0005c703          	lbu	a4,0(a1)
 330:	00e79863          	bne	a5,a4,340 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 334:	0505                	addi	a0,a0,1
    p2++;
 336:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 338:	fed518e3          	bne	a0,a3,328 <memcmp+0x14>
  }
  return 0;
 33c:	4501                	li	a0,0
 33e:	a019                	j	344 <memcmp+0x30>
      return *p1 - *p2;
 340:	40e7853b          	subw	a0,a5,a4
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
  return 0;
 34a:	4501                	li	a0,0
 34c:	bfe5                	j	344 <memcmp+0x30>

000000000000034e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e406                	sd	ra,8(sp)
 352:	e022                	sd	s0,0(sp)
 354:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 356:	f67ff0ef          	jal	ra,2bc <memmove>
}
 35a:	60a2                	ld	ra,8(sp)
 35c:	6402                	ld	s0,0(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret

0000000000000362 <sbrk>:

char *
sbrk(int n) {
 362:	1141                	addi	sp,sp,-16
 364:	e406                	sd	ra,8(sp)
 366:	e022                	sd	s0,0(sp)
 368:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 36a:	4585                	li	a1,1
 36c:	0b2000ef          	jal	ra,41e <sys_sbrk>
}
 370:	60a2                	ld	ra,8(sp)
 372:	6402                	ld	s0,0(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <sbrklazy>:

char *
sbrklazy(int n) {
 378:	1141                	addi	sp,sp,-16
 37a:	e406                	sd	ra,8(sp)
 37c:	e022                	sd	s0,0(sp)
 37e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 380:	4589                	li	a1,2
 382:	09c000ef          	jal	ra,41e <sys_sbrk>
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret

000000000000038e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38e:	4885                	li	a7,1
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <exit>:
.global exit
exit:
 li a7, SYS_exit
 396:	4889                	li	a7,2
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <wait>:
.global wait
wait:
 li a7, SYS_wait
 39e:	488d                	li	a7,3
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a6:	4891                	li	a7,4
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <read>:
.global read
read:
 li a7, SYS_read
 3ae:	4895                	li	a7,5
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <write>:
.global write
write:
 li a7, SYS_write
 3b6:	48c1                	li	a7,16
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <close>:
.global close
close:
 li a7, SYS_close
 3be:	48d5                	li	a7,21
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c6:	4899                	li	a7,6
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ce:	489d                	li	a7,7
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <open>:
.global open
open:
 li a7, SYS_open
 3d6:	48bd                	li	a7,15
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3de:	48c5                	li	a7,17
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e6:	48c9                	li	a7,18
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ee:	48a1                	li	a7,8
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <link>:
.global link
link:
 li a7, SYS_link
 3f6:	48cd                	li	a7,19
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fe:	48d1                	li	a7,20
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 406:	48a5                	li	a7,9
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <dup>:
.global dup
dup:
 li a7, SYS_dup
 40e:	48a9                	li	a7,10
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 416:	48ad                	li	a7,11
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 41e:	48b1                	li	a7,12
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <pause>:
.global pause
pause:
 li a7, SYS_pause
 426:	48b5                	li	a7,13
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42e:	48b9                	li	a7,14
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 436:	48d9                	li	a7,22
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 43e:	48dd                	li	a7,23
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 446:	48e1                	li	a7,24
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44e:	48e5                	li	a7,25
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 456:	1101                	addi	sp,sp,-32
 458:	ec06                	sd	ra,24(sp)
 45a:	e822                	sd	s0,16(sp)
 45c:	1000                	addi	s0,sp,32
 45e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 462:	4605                	li	a2,1
 464:	fef40593          	addi	a1,s0,-17
 468:	f4fff0ef          	jal	ra,3b6 <write>
}
 46c:	60e2                	ld	ra,24(sp)
 46e:	6442                	ld	s0,16(sp)
 470:	6105                	addi	sp,sp,32
 472:	8082                	ret

0000000000000474 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 474:	715d                	addi	sp,sp,-80
 476:	e486                	sd	ra,72(sp)
 478:	e0a2                	sd	s0,64(sp)
 47a:	fc26                	sd	s1,56(sp)
 47c:	f84a                	sd	s2,48(sp)
 47e:	f44e                	sd	s3,40(sp)
 480:	0880                	addi	s0,sp,80
 482:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 484:	c299                	beqz	a3,48a <printint+0x16>
 486:	0805c163          	bltz	a1,508 <printint+0x94>
  neg = 0;
 48a:	4881                	li	a7,0
 48c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 490:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 492:	00000517          	auipc	a0,0x0
 496:	52e50513          	addi	a0,a0,1326 # 9c0 <digits>
 49a:	883e                	mv	a6,a5
 49c:	2785                	addiw	a5,a5,1
 49e:	02c5f733          	remu	a4,a1,a2
 4a2:	972a                	add	a4,a4,a0
 4a4:	00074703          	lbu	a4,0(a4)
 4a8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ac:	872e                	mv	a4,a1
 4ae:	02c5d5b3          	divu	a1,a1,a2
 4b2:	0685                	addi	a3,a3,1
 4b4:	fec773e3          	bgeu	a4,a2,49a <printint+0x26>
  if(neg)
 4b8:	00088b63          	beqz	a7,4ce <printint+0x5a>
    buf[i++] = '-';
 4bc:	fd078793          	addi	a5,a5,-48
 4c0:	97a2                	add	a5,a5,s0
 4c2:	02d00713          	li	a4,45
 4c6:	fee78423          	sb	a4,-24(a5)
 4ca:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ce:	02f05663          	blez	a5,4fa <printint+0x86>
 4d2:	fb840713          	addi	a4,s0,-72
 4d6:	00f704b3          	add	s1,a4,a5
 4da:	fff70993          	addi	s3,a4,-1
 4de:	99be                	add	s3,s3,a5
 4e0:	37fd                	addiw	a5,a5,-1
 4e2:	1782                	slli	a5,a5,0x20
 4e4:	9381                	srli	a5,a5,0x20
 4e6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4ea:	fff4c583          	lbu	a1,-1(s1)
 4ee:	854a                	mv	a0,s2
 4f0:	f67ff0ef          	jal	ra,456 <putc>
  while(--i >= 0)
 4f4:	14fd                	addi	s1,s1,-1
 4f6:	ff349ae3          	bne	s1,s3,4ea <printint+0x76>
}
 4fa:	60a6                	ld	ra,72(sp)
 4fc:	6406                	ld	s0,64(sp)
 4fe:	74e2                	ld	s1,56(sp)
 500:	7942                	ld	s2,48(sp)
 502:	79a2                	ld	s3,40(sp)
 504:	6161                	addi	sp,sp,80
 506:	8082                	ret
    x = -xx;
 508:	40b005b3          	neg	a1,a1
    neg = 1;
 50c:	4885                	li	a7,1
    x = -xx;
 50e:	bfbd                	j	48c <printint+0x18>

0000000000000510 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 510:	7119                	addi	sp,sp,-128
 512:	fc86                	sd	ra,120(sp)
 514:	f8a2                	sd	s0,112(sp)
 516:	f4a6                	sd	s1,104(sp)
 518:	f0ca                	sd	s2,96(sp)
 51a:	ecce                	sd	s3,88(sp)
 51c:	e8d2                	sd	s4,80(sp)
 51e:	e4d6                	sd	s5,72(sp)
 520:	e0da                	sd	s6,64(sp)
 522:	fc5e                	sd	s7,56(sp)
 524:	f862                	sd	s8,48(sp)
 526:	f466                	sd	s9,40(sp)
 528:	f06a                	sd	s10,32(sp)
 52a:	ec6e                	sd	s11,24(sp)
 52c:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52e:	0005c903          	lbu	s2,0(a1)
 532:	24090c63          	beqz	s2,78a <vprintf+0x27a>
 536:	8b2a                	mv	s6,a0
 538:	8a2e                	mv	s4,a1
 53a:	8bb2                	mv	s7,a2
  state = 0;
 53c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 53e:	4481                	li	s1,0
 540:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 542:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 546:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 54a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 54e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 552:	00000c97          	auipc	s9,0x0
 556:	46ec8c93          	addi	s9,s9,1134 # 9c0 <digits>
 55a:	a005                	j	57a <vprintf+0x6a>
        putc(fd, c0);
 55c:	85ca                	mv	a1,s2
 55e:	855a                	mv	a0,s6
 560:	ef7ff0ef          	jal	ra,456 <putc>
 564:	a019                	j	56a <vprintf+0x5a>
    } else if(state == '%'){
 566:	03598263          	beq	s3,s5,58a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 56a:	2485                	addiw	s1,s1,1
 56c:	8726                	mv	a4,s1
 56e:	009a07b3          	add	a5,s4,s1
 572:	0007c903          	lbu	s2,0(a5)
 576:	20090a63          	beqz	s2,78a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 57a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 57e:	fe0994e3          	bnez	s3,566 <vprintf+0x56>
      if(c0 == '%'){
 582:	fd579de3          	bne	a5,s5,55c <vprintf+0x4c>
        state = '%';
 586:	89be                	mv	s3,a5
 588:	b7cd                	j	56a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 58a:	c3c1                	beqz	a5,60a <vprintf+0xfa>
 58c:	00ea06b3          	add	a3,s4,a4
 590:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 594:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 596:	c681                	beqz	a3,59e <vprintf+0x8e>
 598:	9752                	add	a4,a4,s4
 59a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 59e:	03878e63          	beq	a5,s8,5da <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5a2:	05a78863          	beq	a5,s10,5f2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 5a6:	0db78b63          	beq	a5,s11,67c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5aa:	07800713          	li	a4,120
 5ae:	10e78d63          	beq	a5,a4,6c8 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5b2:	07000713          	li	a4,112
 5b6:	14e78263          	beq	a5,a4,6fa <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5ba:	06300713          	li	a4,99
 5be:	16e78f63          	beq	a5,a4,73c <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5c2:	07300713          	li	a4,115
 5c6:	18e78563          	beq	a5,a4,750 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ca:	05579063          	bne	a5,s5,60a <vprintf+0xfa>
        putc(fd, '%');
 5ce:	85d6                	mv	a1,s5
 5d0:	855a                	mv	a0,s6
 5d2:	e85ff0ef          	jal	ra,456 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	bf49                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4685                	li	a3,1
 5e0:	4629                	li	a2,10
 5e2:	000ba583          	lw	a1,0(s7)
 5e6:	855a                	mv	a0,s6
 5e8:	e8dff0ef          	jal	ra,474 <printint>
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bfad                	j	56a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5f2:	03868663          	beq	a3,s8,61e <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f6:	05a68163          	beq	a3,s10,638 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5fa:	09b68d63          	beq	a3,s11,694 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5fe:	03a68f63          	beq	a3,s10,63c <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 602:	07800793          	li	a5,120
 606:	0cf68d63          	beq	a3,a5,6e0 <vprintf+0x1d0>
        putc(fd, '%');
 60a:	85d6                	mv	a1,s5
 60c:	855a                	mv	a0,s6
 60e:	e49ff0ef          	jal	ra,456 <putc>
        putc(fd, c0);
 612:	85ca                	mv	a1,s2
 614:	855a                	mv	a0,s6
 616:	e41ff0ef          	jal	ra,456 <putc>
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b7b9                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 61e:	008b8913          	addi	s2,s7,8
 622:	4685                	li	a3,1
 624:	4629                	li	a2,10
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	e49ff0ef          	jal	ra,474 <printint>
        i += 1;
 630:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 1;
 636:	bf15                	j	56a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 638:	03860563          	beq	a2,s8,662 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 63c:	07b60963          	beq	a2,s11,6ae <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 640:	07800793          	li	a5,120
 644:	fcf613e3          	bne	a2,a5,60a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e1fff0ef          	jal	ra,474 <printint>
        i += 2;
 65a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	b729                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 662:	008b8913          	addi	s2,s7,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000bb583          	ld	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	e05ff0ef          	jal	ra,474 <printint>
        i += 2;
 674:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
        i += 2;
 67a:	bdc5                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 67c:	008b8913          	addi	s2,s7,8
 680:	4681                	li	a3,0
 682:	4629                	li	a2,10
 684:	000be583          	lwu	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	debff0ef          	jal	ra,474 <printint>
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
 692:	bde1                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	dd3ff0ef          	jal	ra,474 <printint>
        i += 1;
 6a6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 1;
 6ac:	bd7d                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000bb583          	ld	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	db9ff0ef          	jal	ra,474 <printint>
        i += 2;
 6c0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
        i += 2;
 6c6:	b555                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4641                	li	a2,16
 6d0:	000be583          	lwu	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	d9fff0ef          	jal	ra,474 <printint>
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b571                	j	56a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4641                	li	a2,16
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	d87ff0ef          	jal	ra,474 <printint>
        i += 1;
 6f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 1;
 6f8:	bd8d                	j	56a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6fa:	008b8793          	addi	a5,s7,8
 6fe:	f8f43423          	sd	a5,-120(s0)
 702:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 706:	03000593          	li	a1,48
 70a:	855a                	mv	a0,s6
 70c:	d4bff0ef          	jal	ra,456 <putc>
  putc(fd, 'x');
 710:	07800593          	li	a1,120
 714:	855a                	mv	a0,s6
 716:	d41ff0ef          	jal	ra,456 <putc>
 71a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71c:	03c9d793          	srli	a5,s3,0x3c
 720:	97e6                	add	a5,a5,s9
 722:	0007c583          	lbu	a1,0(a5)
 726:	855a                	mv	a0,s6
 728:	d2fff0ef          	jal	ra,456 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 72c:	0992                	slli	s3,s3,0x4
 72e:	397d                	addiw	s2,s2,-1
 730:	fe0916e3          	bnez	s2,71c <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 734:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 738:	4981                	li	s3,0
 73a:	bd05                	j	56a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 73c:	008b8913          	addi	s2,s7,8
 740:	000bc583          	lbu	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	d11ff0ef          	jal	ra,456 <putc>
 74a:	8bca                	mv	s7,s2
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bd31                	j	56a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 750:	008b8993          	addi	s3,s7,8
 754:	000bb903          	ld	s2,0(s7)
 758:	00090f63          	beqz	s2,776 <vprintf+0x266>
        for(; *s; s++)
 75c:	00094583          	lbu	a1,0(s2)
 760:	c195                	beqz	a1,784 <vprintf+0x274>
          putc(fd, *s);
 762:	855a                	mv	a0,s6
 764:	cf3ff0ef          	jal	ra,456 <putc>
        for(; *s; s++)
 768:	0905                	addi	s2,s2,1
 76a:	00094583          	lbu	a1,0(s2)
 76e:	f9f5                	bnez	a1,762 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 770:	8bce                	mv	s7,s3
      state = 0;
 772:	4981                	li	s3,0
 774:	bbdd                	j	56a <vprintf+0x5a>
          s = "(null)";
 776:	00000917          	auipc	s2,0x0
 77a:	24290913          	addi	s2,s2,578 # 9b8 <malloc+0x132>
        for(; *s; s++)
 77e:	02800593          	li	a1,40
 782:	b7c5                	j	762 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 784:	8bce                	mv	s7,s3
      state = 0;
 786:	4981                	li	s3,0
 788:	b3cd                	j	56a <vprintf+0x5a>
    }
  }
}
 78a:	70e6                	ld	ra,120(sp)
 78c:	7446                	ld	s0,112(sp)
 78e:	74a6                	ld	s1,104(sp)
 790:	7906                	ld	s2,96(sp)
 792:	69e6                	ld	s3,88(sp)
 794:	6a46                	ld	s4,80(sp)
 796:	6aa6                	ld	s5,72(sp)
 798:	6b06                	ld	s6,64(sp)
 79a:	7be2                	ld	s7,56(sp)
 79c:	7c42                	ld	s8,48(sp)
 79e:	7ca2                	ld	s9,40(sp)
 7a0:	7d02                	ld	s10,32(sp)
 7a2:	6de2                	ld	s11,24(sp)
 7a4:	6109                	addi	sp,sp,128
 7a6:	8082                	ret

00000000000007a8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a8:	715d                	addi	sp,sp,-80
 7aa:	ec06                	sd	ra,24(sp)
 7ac:	e822                	sd	s0,16(sp)
 7ae:	1000                	addi	s0,sp,32
 7b0:	e010                	sd	a2,0(s0)
 7b2:	e414                	sd	a3,8(s0)
 7b4:	e818                	sd	a4,16(s0)
 7b6:	ec1c                	sd	a5,24(s0)
 7b8:	03043023          	sd	a6,32(s0)
 7bc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c4:	8622                	mv	a2,s0
 7c6:	d4bff0ef          	jal	ra,510 <vprintf>
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	6161                	addi	sp,sp,80
 7d0:	8082                	ret

00000000000007d2 <printf>:

void
printf(const char *fmt, ...)
{
 7d2:	711d                	addi	sp,sp,-96
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	1000                	addi	s0,sp,32
 7da:	e40c                	sd	a1,8(s0)
 7dc:	e810                	sd	a2,16(s0)
 7de:	ec14                	sd	a3,24(s0)
 7e0:	f018                	sd	a4,32(s0)
 7e2:	f41c                	sd	a5,40(s0)
 7e4:	03043823          	sd	a6,48(s0)
 7e8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ec:	00840613          	addi	a2,s0,8
 7f0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f4:	85aa                	mv	a1,a0
 7f6:	4505                	li	a0,1
 7f8:	d19ff0ef          	jal	ra,510 <vprintf>
}
 7fc:	60e2                	ld	ra,24(sp)
 7fe:	6442                	ld	s0,16(sp)
 800:	6125                	addi	sp,sp,96
 802:	8082                	ret

0000000000000804 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 804:	1141                	addi	sp,sp,-16
 806:	e422                	sd	s0,8(sp)
 808:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	00000797          	auipc	a5,0x0
 812:	7f27b783          	ld	a5,2034(a5) # 1000 <freep>
 816:	a02d                	j	840 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 818:	4618                	lw	a4,8(a2)
 81a:	9f2d                	addw	a4,a4,a1
 81c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 820:	6398                	ld	a4,0(a5)
 822:	6310                	ld	a2,0(a4)
 824:	a83d                	j	862 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 826:	ff852703          	lw	a4,-8(a0)
 82a:	9f31                	addw	a4,a4,a2
 82c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 82e:	ff053683          	ld	a3,-16(a0)
 832:	a091                	j	876 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 834:	6398                	ld	a4,0(a5)
 836:	00e7e463          	bltu	a5,a4,83e <free+0x3a>
 83a:	00e6ea63          	bltu	a3,a4,84e <free+0x4a>
{
 83e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 840:	fed7fae3          	bgeu	a5,a3,834 <free+0x30>
 844:	6398                	ld	a4,0(a5)
 846:	00e6e463          	bltu	a3,a4,84e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84a:	fee7eae3          	bltu	a5,a4,83e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 84e:	ff852583          	lw	a1,-8(a0)
 852:	6390                	ld	a2,0(a5)
 854:	02059813          	slli	a6,a1,0x20
 858:	01c85713          	srli	a4,a6,0x1c
 85c:	9736                	add	a4,a4,a3
 85e:	fae60de3          	beq	a2,a4,818 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 862:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 866:	4790                	lw	a2,8(a5)
 868:	02061593          	slli	a1,a2,0x20
 86c:	01c5d713          	srli	a4,a1,0x1c
 870:	973e                	add	a4,a4,a5
 872:	fae68ae3          	beq	a3,a4,826 <free+0x22>
    p->s.ptr = bp->s.ptr;
 876:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 878:	00000717          	auipc	a4,0x0
 87c:	78f73423          	sd	a5,1928(a4) # 1000 <freep>
}
 880:	6422                	ld	s0,8(sp)
 882:	0141                	addi	sp,sp,16
 884:	8082                	ret

0000000000000886 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 886:	7139                	addi	sp,sp,-64
 888:	fc06                	sd	ra,56(sp)
 88a:	f822                	sd	s0,48(sp)
 88c:	f426                	sd	s1,40(sp)
 88e:	f04a                	sd	s2,32(sp)
 890:	ec4e                	sd	s3,24(sp)
 892:	e852                	sd	s4,16(sp)
 894:	e456                	sd	s5,8(sp)
 896:	e05a                	sd	s6,0(sp)
 898:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89a:	02051493          	slli	s1,a0,0x20
 89e:	9081                	srli	s1,s1,0x20
 8a0:	04bd                	addi	s1,s1,15
 8a2:	8091                	srli	s1,s1,0x4
 8a4:	0014899b          	addiw	s3,s1,1
 8a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8aa:	00000517          	auipc	a0,0x0
 8ae:	75653503          	ld	a0,1878(a0) # 1000 <freep>
 8b2:	c515                	beqz	a0,8de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b6:	4798                	lw	a4,8(a5)
 8b8:	02977f63          	bgeu	a4,s1,8f6 <malloc+0x70>
 8bc:	8a4e                	mv	s4,s3
 8be:	0009871b          	sext.w	a4,s3
 8c2:	6685                	lui	a3,0x1
 8c4:	00d77363          	bgeu	a4,a3,8ca <malloc+0x44>
 8c8:	6a05                	lui	s4,0x1
 8ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d2:	00000917          	auipc	s2,0x0
 8d6:	72e90913          	addi	s2,s2,1838 # 1000 <freep>
  if(p == SBRK_ERROR)
 8da:	5afd                	li	s5,-1
 8dc:	a885                	j	94c <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8de:	00001797          	auipc	a5,0x1
 8e2:	92a78793          	addi	a5,a5,-1750 # 1208 <base>
 8e6:	00000717          	auipc	a4,0x0
 8ea:	70f73d23          	sd	a5,1818(a4) # 1000 <freep>
 8ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f4:	b7e1                	j	8bc <malloc+0x36>
      if(p->s.size == nunits)
 8f6:	02e48c63          	beq	s1,a4,92e <malloc+0xa8>
        p->s.size -= nunits;
 8fa:	4137073b          	subw	a4,a4,s3
 8fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 900:	02071693          	slli	a3,a4,0x20
 904:	01c6d713          	srli	a4,a3,0x1c
 908:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90e:	00000717          	auipc	a4,0x0
 912:	6ea73923          	sd	a0,1778(a4) # 1000 <freep>
      return (void*)(p + 1);
 916:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 91a:	70e2                	ld	ra,56(sp)
 91c:	7442                	ld	s0,48(sp)
 91e:	74a2                	ld	s1,40(sp)
 920:	7902                	ld	s2,32(sp)
 922:	69e2                	ld	s3,24(sp)
 924:	6a42                	ld	s4,16(sp)
 926:	6aa2                	ld	s5,8(sp)
 928:	6b02                	ld	s6,0(sp)
 92a:	6121                	addi	sp,sp,64
 92c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 92e:	6398                	ld	a4,0(a5)
 930:	e118                	sd	a4,0(a0)
 932:	bff1                	j	90e <malloc+0x88>
  hp->s.size = nu;
 934:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 938:	0541                	addi	a0,a0,16
 93a:	ecbff0ef          	jal	ra,804 <free>
  return freep;
 93e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 942:	dd61                	beqz	a0,91a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 946:	4798                	lw	a4,8(a5)
 948:	fa9777e3          	bgeu	a4,s1,8f6 <malloc+0x70>
    if(p == freep)
 94c:	00093703          	ld	a4,0(s2)
 950:	853e                	mv	a0,a5
 952:	fef719e3          	bne	a4,a5,944 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 956:	8552                	mv	a0,s4
 958:	a0bff0ef          	jal	ra,362 <sbrk>
  if(p == SBRK_ERROR)
 95c:	fd551ce3          	bne	a0,s5,934 <malloc+0xae>
        return 0;
 960:	4501                	li	a0,0
 962:	bf65                	j	91a <malloc+0x94>
