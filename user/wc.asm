
user/_wc：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4981                	li	s3,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  2e:	00001d97          	auipc	s11,0x1
  32:	fe3d8d93          	addi	s11,s11,-29 # 1011 <buf+0x1>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	9a8a0a13          	addi	s4,s4,-1624 # 9e0 <malloc+0xe2>
        inword = 0;
  40:	4b01                	li	s6,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a035                	j	6e <wc+0x6e>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	1c0000ef          	jal	ra,206 <strchr>
  4a:	c919                	beqz	a0,60 <wc+0x60>
        inword = 0;
  4c:	89da                	mv	s3,s6
    for(i=0; i<n; i++){
  4e:	0485                	addi	s1,s1,1
  50:	01248d63          	beq	s1,s2,6a <wc+0x6a>
      if(buf[i] == '\n')
  54:	0004c583          	lbu	a1,0(s1)
  58:	ff5596e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  5c:	2b85                	addiw	s7,s7,1
  5e:	b7dd                	j	44 <wc+0x44>
      else if(!inword){
  60:	fe0997e3          	bnez	s3,4e <wc+0x4e>
        w++;
  64:	2c05                	addiw	s8,s8,1
        inword = 1;
  66:	4985                	li	s3,1
  68:	b7dd                	j	4e <wc+0x4e>
      c++;
  6a:	01ac8cbb          	addw	s9,s9,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  6e:	20000613          	li	a2,512
  72:	00001597          	auipc	a1,0x1
  76:	f9e58593          	addi	a1,a1,-98 # 1010 <buf>
  7a:	f8843503          	ld	a0,-120(s0)
  7e:	390000ef          	jal	ra,40e <read>
  82:	00a05f63          	blez	a0,a0 <wc+0xa0>
    for(i=0; i<n; i++){
  86:	00001497          	auipc	s1,0x1
  8a:	f8a48493          	addi	s1,s1,-118 # 1010 <buf>
  8e:	00050d1b          	sext.w	s10,a0
  92:	fff5091b          	addiw	s2,a0,-1
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	996e                	add	s2,s2,s11
  9e:	bf5d                	j	54 <wc+0x54>
      }
    }
  }
  if(n < 0){
  a0:	02054c63          	bltz	a0,d8 <wc+0xd8>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  a4:	f8043703          	ld	a4,-128(s0)
  a8:	86e6                	mv	a3,s9
  aa:	8662                	mv	a2,s8
  ac:	85de                	mv	a1,s7
  ae:	00001517          	auipc	a0,0x1
  b2:	94a50513          	addi	a0,a0,-1718 # 9f8 <malloc+0xfa>
  b6:	794000ef          	jal	ra,84a <printf>
}
  ba:	70e6                	ld	ra,120(sp)
  bc:	7446                	ld	s0,112(sp)
  be:	74a6                	ld	s1,104(sp)
  c0:	7906                	ld	s2,96(sp)
  c2:	69e6                	ld	s3,88(sp)
  c4:	6a46                	ld	s4,80(sp)
  c6:	6aa6                	ld	s5,72(sp)
  c8:	6b06                	ld	s6,64(sp)
  ca:	7be2                	ld	s7,56(sp)
  cc:	7c42                	ld	s8,48(sp)
  ce:	7ca2                	ld	s9,40(sp)
  d0:	7d02                	ld	s10,32(sp)
  d2:	6de2                	ld	s11,24(sp)
  d4:	6109                	addi	sp,sp,128
  d6:	8082                	ret
    printf("wc: read error\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	91050513          	addi	a0,a0,-1776 # 9e8 <malloc+0xea>
  e0:	76a000ef          	jal	ra,84a <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	310000ef          	jal	ra,3f6 <exit>

00000000000000ea <main>:

int
main(int argc, char *argv[])
{
  ea:	7179                	addi	sp,sp,-48
  ec:	f406                	sd	ra,40(sp)
  ee:	f022                	sd	s0,32(sp)
  f0:	ec26                	sd	s1,24(sp)
  f2:	e84a                	sd	s2,16(sp)
  f4:	e44e                	sd	s3,8(sp)
  f6:	e052                	sd	s4,0(sp)
  f8:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  fa:	4785                	li	a5,1
  fc:	02a7df63          	bge	a5,a0,13a <main+0x50>
 100:	00858493          	addi	s1,a1,8
 104:	ffe5099b          	addiw	s3,a0,-2
 108:	02099793          	slli	a5,s3,0x20
 10c:	01d7d993          	srli	s3,a5,0x1d
 110:	05c1                	addi	a1,a1,16
 112:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 114:	4581                	li	a1,0
 116:	6088                	ld	a0,0(s1)
 118:	31e000ef          	jal	ra,436 <open>
 11c:	892a                	mv	s2,a0
 11e:	02054863          	bltz	a0,14e <main+0x64>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 122:	608c                	ld	a1,0(s1)
 124:	eddff0ef          	jal	ra,0 <wc>
    close(fd);
 128:	854a                	mv	a0,s2
 12a:	2f4000ef          	jal	ra,41e <close>
  for(i = 1; i < argc; i++){
 12e:	04a1                	addi	s1,s1,8
 130:	ff3492e3          	bne	s1,s3,114 <main+0x2a>
  }
  exit(0);
 134:	4501                	li	a0,0
 136:	2c0000ef          	jal	ra,3f6 <exit>
    wc(0, "");
 13a:	00001597          	auipc	a1,0x1
 13e:	8ce58593          	addi	a1,a1,-1842 # a08 <malloc+0x10a>
 142:	4501                	li	a0,0
 144:	ebdff0ef          	jal	ra,0 <wc>
    exit(0);
 148:	4501                	li	a0,0
 14a:	2ac000ef          	jal	ra,3f6 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 14e:	608c                	ld	a1,0(s1)
 150:	00001517          	auipc	a0,0x1
 154:	8c050513          	addi	a0,a0,-1856 # a10 <malloc+0x112>
 158:	6f2000ef          	jal	ra,84a <printf>
      exit(1);
 15c:	4505                	li	a0,1
 15e:	298000ef          	jal	ra,3f6 <exit>

0000000000000162 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
 162:	1141                	addi	sp,sp,-16
 164:	e406                	sd	ra,8(sp)
 166:	e022                	sd	s0,0(sp)
 168:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 16a:	f81ff0ef          	jal	ra,ea <main>
  exit(r);
 16e:	288000ef          	jal	ra,3f6 <exit>

0000000000000172 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 178:	87aa                	mv	a5,a0
 17a:	0585                	addi	a1,a1,1
 17c:	0785                	addi	a5,a5,1
 17e:	fff5c703          	lbu	a4,-1(a1)
 182:	fee78fa3          	sb	a4,-1(a5)
 186:	fb75                	bnez	a4,17a <strcpy+0x8>
    ;
  return os;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb91                	beqz	a5,1ac <strcmp+0x1e>
 19a:	0005c703          	lbu	a4,0(a1)
 19e:	00f71763          	bne	a4,a5,1ac <strcmp+0x1e>
    p++, q++;
 1a2:	0505                	addi	a0,a0,1
 1a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbe5                	bnez	a5,19a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strlen>:

uint
strlen(const char *s)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cf91                	beqz	a5,1e0 <strlen+0x26>
 1c6:	0505                	addi	a0,a0,1
 1c8:	87aa                	mv	a5,a0
 1ca:	4685                	li	a3,1
 1cc:	9e89                	subw	a3,a3,a0
 1ce:	00f6853b          	addw	a0,a3,a5
 1d2:	0785                	addi	a5,a5,1
 1d4:	fff7c703          	lbu	a4,-1(a5)
 1d8:	fb7d                	bnez	a4,1ce <strlen+0x14>
    ;
  return n;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret
  for(n = 0; s[n]; n++)
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <strlen+0x20>

00000000000001e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ea:	ca19                	beqz	a2,200 <memset+0x1c>
 1ec:	87aa                	mv	a5,a0
 1ee:	1602                	slli	a2,a2,0x20
 1f0:	9201                	srli	a2,a2,0x20
 1f2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1fa:	0785                	addi	a5,a5,1
 1fc:	fee79de3          	bne	a5,a4,1f6 <memset+0x12>
  }
  return dst;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret

0000000000000206 <strchr>:

char*
strchr(const char *s, char c)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cb99                	beqz	a5,226 <strchr+0x20>
    if(*s == c)
 212:	00f58763          	beq	a1,a5,220 <strchr+0x1a>
  for(; *s; s++)
 216:	0505                	addi	a0,a0,1
 218:	00054783          	lbu	a5,0(a0)
 21c:	fbfd                	bnez	a5,212 <strchr+0xc>
      return (char*)s;
  return 0;
 21e:	4501                	li	a0,0
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret
  return 0;
 226:	4501                	li	a0,0
 228:	bfe5                	j	220 <strchr+0x1a>

000000000000022a <gets>:

char*
gets(char *buf, int max)
{
 22a:	711d                	addi	sp,sp,-96
 22c:	ec86                	sd	ra,88(sp)
 22e:	e8a2                	sd	s0,80(sp)
 230:	e4a6                	sd	s1,72(sp)
 232:	e0ca                	sd	s2,64(sp)
 234:	fc4e                	sd	s3,56(sp)
 236:	f852                	sd	s4,48(sp)
 238:	f456                	sd	s5,40(sp)
 23a:	f05a                	sd	s6,32(sp)
 23c:	ec5e                	sd	s7,24(sp)
 23e:	1080                	addi	s0,sp,96
 240:	8baa                	mv	s7,a0
 242:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 244:	892a                	mv	s2,a0
 246:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 248:	4aa9                	li	s5,10
 24a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 24c:	89a6                	mv	s3,s1
 24e:	2485                	addiw	s1,s1,1
 250:	0344d663          	bge	s1,s4,27c <gets+0x52>
    cc = read(0, &c, 1);
 254:	4605                	li	a2,1
 256:	faf40593          	addi	a1,s0,-81
 25a:	4501                	li	a0,0
 25c:	1b2000ef          	jal	ra,40e <read>
    if(cc < 1)
 260:	00a05e63          	blez	a0,27c <gets+0x52>
    buf[i++] = c;
 264:	faf44783          	lbu	a5,-81(s0)
 268:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 26c:	01578763          	beq	a5,s5,27a <gets+0x50>
 270:	0905                	addi	s2,s2,1
 272:	fd679de3          	bne	a5,s6,24c <gets+0x22>
  for(i=0; i+1 < max; ){
 276:	89a6                	mv	s3,s1
 278:	a011                	j	27c <gets+0x52>
 27a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27c:	99de                	add	s3,s3,s7
 27e:	00098023          	sb	zero,0(s3)
  return buf;
}
 282:	855e                	mv	a0,s7
 284:	60e6                	ld	ra,88(sp)
 286:	6446                	ld	s0,80(sp)
 288:	64a6                	ld	s1,72(sp)
 28a:	6906                	ld	s2,64(sp)
 28c:	79e2                	ld	s3,56(sp)
 28e:	7a42                	ld	s4,48(sp)
 290:	7aa2                	ld	s5,40(sp)
 292:	7b02                	ld	s6,32(sp)
 294:	6be2                	ld	s7,24(sp)
 296:	6125                	addi	sp,sp,96
 298:	8082                	ret

000000000000029a <stat>:

int
stat(const char *n, struct stat *st)
{
 29a:	1101                	addi	sp,sp,-32
 29c:	ec06                	sd	ra,24(sp)
 29e:	e822                	sd	s0,16(sp)
 2a0:	e426                	sd	s1,8(sp)
 2a2:	e04a                	sd	s2,0(sp)
 2a4:	1000                	addi	s0,sp,32
 2a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a8:	4581                	li	a1,0
 2aa:	18c000ef          	jal	ra,436 <open>
  if(fd < 0)
 2ae:	02054163          	bltz	a0,2d0 <stat+0x36>
 2b2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b4:	85ca                	mv	a1,s2
 2b6:	198000ef          	jal	ra,44e <fstat>
 2ba:	892a                	mv	s2,a0
  close(fd);
 2bc:	8526                	mv	a0,s1
 2be:	160000ef          	jal	ra,41e <close>
  return r;
}
 2c2:	854a                	mv	a0,s2
 2c4:	60e2                	ld	ra,24(sp)
 2c6:	6442                	ld	s0,16(sp)
 2c8:	64a2                	ld	s1,8(sp)
 2ca:	6902                	ld	s2,0(sp)
 2cc:	6105                	addi	sp,sp,32
 2ce:	8082                	ret
    return -1;
 2d0:	597d                	li	s2,-1
 2d2:	bfc5                	j	2c2 <stat+0x28>

00000000000002d4 <atoi>:

int
atoi(const char *s)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2da:	00054683          	lbu	a3,0(a0)
 2de:	fd06879b          	addiw	a5,a3,-48
 2e2:	0ff7f793          	zext.b	a5,a5
 2e6:	4625                	li	a2,9
 2e8:	02f66863          	bltu	a2,a5,318 <atoi+0x44>
 2ec:	872a                	mv	a4,a0
  n = 0;
 2ee:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2f0:	0705                	addi	a4,a4,1
 2f2:	0025179b          	slliw	a5,a0,0x2
 2f6:	9fa9                	addw	a5,a5,a0
 2f8:	0017979b          	slliw	a5,a5,0x1
 2fc:	9fb5                	addw	a5,a5,a3
 2fe:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 302:	00074683          	lbu	a3,0(a4)
 306:	fd06879b          	addiw	a5,a3,-48
 30a:	0ff7f793          	zext.b	a5,a5
 30e:	fef671e3          	bgeu	a2,a5,2f0 <atoi+0x1c>
  return n;
}
 312:	6422                	ld	s0,8(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
  n = 0;
 318:	4501                	li	a0,0
 31a:	bfe5                	j	312 <atoi+0x3e>

000000000000031c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 322:	02b57463          	bgeu	a0,a1,34a <memmove+0x2e>
    while(n-- > 0)
 326:	00c05f63          	blez	a2,344 <memmove+0x28>
 32a:	1602                	slli	a2,a2,0x20
 32c:	9201                	srli	a2,a2,0x20
 32e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 332:	872a                	mv	a4,a0
      *dst++ = *src++;
 334:	0585                	addi	a1,a1,1
 336:	0705                	addi	a4,a4,1
 338:	fff5c683          	lbu	a3,-1(a1)
 33c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 340:	fee79ae3          	bne	a5,a4,334 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
    dst += n;
 34a:	00c50733          	add	a4,a0,a2
    src += n;
 34e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 350:	fec05ae3          	blez	a2,344 <memmove+0x28>
 354:	fff6079b          	addiw	a5,a2,-1
 358:	1782                	slli	a5,a5,0x20
 35a:	9381                	srli	a5,a5,0x20
 35c:	fff7c793          	not	a5,a5
 360:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 362:	15fd                	addi	a1,a1,-1
 364:	177d                	addi	a4,a4,-1
 366:	0005c683          	lbu	a3,0(a1)
 36a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36e:	fee79ae3          	bne	a5,a4,362 <memmove+0x46>
 372:	bfc9                	j	344 <memmove+0x28>

0000000000000374 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 374:	1141                	addi	sp,sp,-16
 376:	e422                	sd	s0,8(sp)
 378:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 37a:	ca05                	beqz	a2,3aa <memcmp+0x36>
 37c:	fff6069b          	addiw	a3,a2,-1
 380:	1682                	slli	a3,a3,0x20
 382:	9281                	srli	a3,a3,0x20
 384:	0685                	addi	a3,a3,1
 386:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 388:	00054783          	lbu	a5,0(a0)
 38c:	0005c703          	lbu	a4,0(a1)
 390:	00e79863          	bne	a5,a4,3a0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 394:	0505                	addi	a0,a0,1
    p2++;
 396:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 398:	fed518e3          	bne	a0,a3,388 <memcmp+0x14>
  }
  return 0;
 39c:	4501                	li	a0,0
 39e:	a019                	j	3a4 <memcmp+0x30>
      return *p1 - *p2;
 3a0:	40e7853b          	subw	a0,a5,a4
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
  return 0;
 3aa:	4501                	li	a0,0
 3ac:	bfe5                	j	3a4 <memcmp+0x30>

00000000000003ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b6:	f67ff0ef          	jal	ra,31c <memmove>
}
 3ba:	60a2                	ld	ra,8(sp)
 3bc:	6402                	ld	s0,0(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret

00000000000003c2 <sbrk>:

char *
sbrk(int n) {
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e406                	sd	ra,8(sp)
 3c6:	e022                	sd	s0,0(sp)
 3c8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3ca:	4585                	li	a1,1
 3cc:	0b2000ef          	jal	ra,47e <sys_sbrk>
}
 3d0:	60a2                	ld	ra,8(sp)
 3d2:	6402                	ld	s0,0(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret

00000000000003d8 <sbrklazy>:

char *
sbrklazy(int n) {
 3d8:	1141                	addi	sp,sp,-16
 3da:	e406                	sd	ra,8(sp)
 3dc:	e022                	sd	s0,0(sp)
 3de:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3e0:	4589                	li	a1,2
 3e2:	09c000ef          	jal	ra,47e <sys_sbrk>
}
 3e6:	60a2                	ld	ra,8(sp)
 3e8:	6402                	ld	s0,0(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret

00000000000003ee <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ee:	4885                	li	a7,1
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f6:	4889                	li	a7,2
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <wait>:
.global wait
wait:
 li a7, SYS_wait
 3fe:	488d                	li	a7,3
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 406:	4891                	li	a7,4
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <read>:
.global read
read:
 li a7, SYS_read
 40e:	4895                	li	a7,5
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <write>:
.global write
write:
 li a7, SYS_write
 416:	48c1                	li	a7,16
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <close>:
.global close
close:
 li a7, SYS_close
 41e:	48d5                	li	a7,21
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <kill>:
.global kill
kill:
 li a7, SYS_kill
 426:	4899                	li	a7,6
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <exec>:
.global exec
exec:
 li a7, SYS_exec
 42e:	489d                	li	a7,7
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <open>:
.global open
open:
 li a7, SYS_open
 436:	48bd                	li	a7,15
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 43e:	48c5                	li	a7,17
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 446:	48c9                	li	a7,18
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 44e:	48a1                	li	a7,8
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <link>:
.global link
link:
 li a7, SYS_link
 456:	48cd                	li	a7,19
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 45e:	48d1                	li	a7,20
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 466:	48a5                	li	a7,9
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <dup>:
.global dup
dup:
 li a7, SYS_dup
 46e:	48a9                	li	a7,10
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 476:	48ad                	li	a7,11
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 47e:	48b1                	li	a7,12
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <pause>:
.global pause
pause:
 li a7, SYS_pause
 486:	48b5                	li	a7,13
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 48e:	48b9                	li	a7,14
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 496:	48d9                	li	a7,22
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 49e:	48dd                	li	a7,23
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 4a6:	48e1                	li	a7,24
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ae:	48e5                	li	a7,25
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 4b6:	48e9                	li	a7,26
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 4be:	48ed                	li	a7,27
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 4c6:	48f1                	li	a7,28
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ce:	1101                	addi	sp,sp,-32
 4d0:	ec06                	sd	ra,24(sp)
 4d2:	e822                	sd	s0,16(sp)
 4d4:	1000                	addi	s0,sp,32
 4d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4da:	4605                	li	a2,1
 4dc:	fef40593          	addi	a1,s0,-17
 4e0:	f37ff0ef          	jal	ra,416 <write>
}
 4e4:	60e2                	ld	ra,24(sp)
 4e6:	6442                	ld	s0,16(sp)
 4e8:	6105                	addi	sp,sp,32
 4ea:	8082                	ret

00000000000004ec <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ec:	715d                	addi	sp,sp,-80
 4ee:	e486                	sd	ra,72(sp)
 4f0:	e0a2                	sd	s0,64(sp)
 4f2:	fc26                	sd	s1,56(sp)
 4f4:	f84a                	sd	s2,48(sp)
 4f6:	f44e                	sd	s3,40(sp)
 4f8:	0880                	addi	s0,sp,80
 4fa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4fc:	c299                	beqz	a3,502 <printint+0x16>
 4fe:	0805c163          	bltz	a1,580 <printint+0x94>
  neg = 0;
 502:	4881                	li	a7,0
 504:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 508:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 50a:	00000517          	auipc	a0,0x0
 50e:	52650513          	addi	a0,a0,1318 # a30 <digits>
 512:	883e                	mv	a6,a5
 514:	2785                	addiw	a5,a5,1
 516:	02c5f733          	remu	a4,a1,a2
 51a:	972a                	add	a4,a4,a0
 51c:	00074703          	lbu	a4,0(a4)
 520:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 524:	872e                	mv	a4,a1
 526:	02c5d5b3          	divu	a1,a1,a2
 52a:	0685                	addi	a3,a3,1
 52c:	fec773e3          	bgeu	a4,a2,512 <printint+0x26>
  if(neg)
 530:	00088b63          	beqz	a7,546 <printint+0x5a>
    buf[i++] = '-';
 534:	fd078793          	addi	a5,a5,-48
 538:	97a2                	add	a5,a5,s0
 53a:	02d00713          	li	a4,45
 53e:	fee78423          	sb	a4,-24(a5)
 542:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 546:	02f05663          	blez	a5,572 <printint+0x86>
 54a:	fb840713          	addi	a4,s0,-72
 54e:	00f704b3          	add	s1,a4,a5
 552:	fff70993          	addi	s3,a4,-1
 556:	99be                	add	s3,s3,a5
 558:	37fd                	addiw	a5,a5,-1
 55a:	1782                	slli	a5,a5,0x20
 55c:	9381                	srli	a5,a5,0x20
 55e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 562:	fff4c583          	lbu	a1,-1(s1)
 566:	854a                	mv	a0,s2
 568:	f67ff0ef          	jal	ra,4ce <putc>
  while(--i >= 0)
 56c:	14fd                	addi	s1,s1,-1
 56e:	ff349ae3          	bne	s1,s3,562 <printint+0x76>
}
 572:	60a6                	ld	ra,72(sp)
 574:	6406                	ld	s0,64(sp)
 576:	74e2                	ld	s1,56(sp)
 578:	7942                	ld	s2,48(sp)
 57a:	79a2                	ld	s3,40(sp)
 57c:	6161                	addi	sp,sp,80
 57e:	8082                	ret
    x = -xx;
 580:	40b005b3          	neg	a1,a1
    neg = 1;
 584:	4885                	li	a7,1
    x = -xx;
 586:	bfbd                	j	504 <printint+0x18>

0000000000000588 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 588:	7119                	addi	sp,sp,-128
 58a:	fc86                	sd	ra,120(sp)
 58c:	f8a2                	sd	s0,112(sp)
 58e:	f4a6                	sd	s1,104(sp)
 590:	f0ca                	sd	s2,96(sp)
 592:	ecce                	sd	s3,88(sp)
 594:	e8d2                	sd	s4,80(sp)
 596:	e4d6                	sd	s5,72(sp)
 598:	e0da                	sd	s6,64(sp)
 59a:	fc5e                	sd	s7,56(sp)
 59c:	f862                	sd	s8,48(sp)
 59e:	f466                	sd	s9,40(sp)
 5a0:	f06a                	sd	s10,32(sp)
 5a2:	ec6e                	sd	s11,24(sp)
 5a4:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a6:	0005c903          	lbu	s2,0(a1)
 5aa:	24090c63          	beqz	s2,802 <vprintf+0x27a>
 5ae:	8b2a                	mv	s6,a0
 5b0:	8a2e                	mv	s4,a1
 5b2:	8bb2                	mv	s7,a2
  state = 0;
 5b4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b6:	4481                	li	s1,0
 5b8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ba:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5be:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5c2:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5c6:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ca:	00000c97          	auipc	s9,0x0
 5ce:	466c8c93          	addi	s9,s9,1126 # a30 <digits>
 5d2:	a005                	j	5f2 <vprintf+0x6a>
        putc(fd, c0);
 5d4:	85ca                	mv	a1,s2
 5d6:	855a                	mv	a0,s6
 5d8:	ef7ff0ef          	jal	ra,4ce <putc>
 5dc:	a019                	j	5e2 <vprintf+0x5a>
    } else if(state == '%'){
 5de:	03598263          	beq	s3,s5,602 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5e2:	2485                	addiw	s1,s1,1
 5e4:	8726                	mv	a4,s1
 5e6:	009a07b3          	add	a5,s4,s1
 5ea:	0007c903          	lbu	s2,0(a5)
 5ee:	20090a63          	beqz	s2,802 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5f2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f6:	fe0994e3          	bnez	s3,5de <vprintf+0x56>
      if(c0 == '%'){
 5fa:	fd579de3          	bne	a5,s5,5d4 <vprintf+0x4c>
        state = '%';
 5fe:	89be                	mv	s3,a5
 600:	b7cd                	j	5e2 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 602:	c3c1                	beqz	a5,682 <vprintf+0xfa>
 604:	00ea06b3          	add	a3,s4,a4
 608:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 60c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 60e:	c681                	beqz	a3,616 <vprintf+0x8e>
 610:	9752                	add	a4,a4,s4
 612:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 616:	03878e63          	beq	a5,s8,652 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 61a:	05a78863          	beq	a5,s10,66a <vprintf+0xe2>
      } else if(c0 == 'u'){
 61e:	0db78b63          	beq	a5,s11,6f4 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 622:	07800713          	li	a4,120
 626:	10e78d63          	beq	a5,a4,740 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 62a:	07000713          	li	a4,112
 62e:	14e78263          	beq	a5,a4,772 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 632:	06300713          	li	a4,99
 636:	16e78f63          	beq	a5,a4,7b4 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 63a:	07300713          	li	a4,115
 63e:	18e78563          	beq	a5,a4,7c8 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 642:	05579063          	bne	a5,s5,682 <vprintf+0xfa>
        putc(fd, '%');
 646:	85d6                	mv	a1,s5
 648:	855a                	mv	a0,s6
 64a:	e85ff0ef          	jal	ra,4ce <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 64e:	4981                	li	s3,0
 650:	bf49                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 652:	008b8913          	addi	s2,s7,8
 656:	4685                	li	a3,1
 658:	4629                	li	a2,10
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	e8dff0ef          	jal	ra,4ec <printint>
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bfad                	j	5e2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 66a:	03868663          	beq	a3,s8,696 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66e:	05a68163          	beq	a3,s10,6b0 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 672:	09b68d63          	beq	a3,s11,70c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 676:	03a68f63          	beq	a3,s10,6b4 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 67a:	07800793          	li	a5,120
 67e:	0cf68d63          	beq	a3,a5,758 <vprintf+0x1d0>
        putc(fd, '%');
 682:	85d6                	mv	a1,s5
 684:	855a                	mv	a0,s6
 686:	e49ff0ef          	jal	ra,4ce <putc>
        putc(fd, c0);
 68a:	85ca                	mv	a1,s2
 68c:	855a                	mv	a0,s6
 68e:	e41ff0ef          	jal	ra,4ce <putc>
      state = 0;
 692:	4981                	li	s3,0
 694:	b7b9                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 696:	008b8913          	addi	s2,s7,8
 69a:	4685                	li	a3,1
 69c:	4629                	li	a2,10
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	e49ff0ef          	jal	ra,4ec <printint>
        i += 1;
 6a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 1;
 6ae:	bf15                	j	5e2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b0:	03860563          	beq	a2,s8,6da <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6b4:	07b60963          	beq	a2,s11,726 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6b8:	07800793          	li	a5,120
 6bc:	fcf613e3          	bne	a2,a5,682 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e1fff0ef          	jal	ra,4ec <printint>
        i += 2;
 6d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	b729                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4685                	li	a3,1
 6e0:	4629                	li	a2,10
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	e05ff0ef          	jal	ra,4ec <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	bdc5                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4629                	li	a2,10
 6fc:	000be583          	lwu	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	debff0ef          	jal	ra,4ec <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bde1                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4629                	li	a2,10
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	dd3ff0ef          	jal	ra,4ec <printint>
        i += 1;
 71e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 1;
 724:	bd7d                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4629                	li	a2,10
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	db9ff0ef          	jal	ra,4ec <printint>
        i += 2;
 738:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
        i += 2;
 73e:	b555                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 740:	008b8913          	addi	s2,s7,8
 744:	4681                	li	a3,0
 746:	4641                	li	a2,16
 748:	000be583          	lwu	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	d9fff0ef          	jal	ra,4ec <printint>
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	b571                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 758:	008b8913          	addi	s2,s7,8
 75c:	4681                	li	a3,0
 75e:	4641                	li	a2,16
 760:	000bb583          	ld	a1,0(s7)
 764:	855a                	mv	a0,s6
 766:	d87ff0ef          	jal	ra,4ec <printint>
        i += 1;
 76a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 76c:	8bca                	mv	s7,s2
      state = 0;
 76e:	4981                	li	s3,0
        i += 1;
 770:	bd8d                	j	5e2 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 772:	008b8793          	addi	a5,s7,8
 776:	f8f43423          	sd	a5,-120(s0)
 77a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 77e:	03000593          	li	a1,48
 782:	855a                	mv	a0,s6
 784:	d4bff0ef          	jal	ra,4ce <putc>
  putc(fd, 'x');
 788:	07800593          	li	a1,120
 78c:	855a                	mv	a0,s6
 78e:	d41ff0ef          	jal	ra,4ce <putc>
 792:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 794:	03c9d793          	srli	a5,s3,0x3c
 798:	97e6                	add	a5,a5,s9
 79a:	0007c583          	lbu	a1,0(a5)
 79e:	855a                	mv	a0,s6
 7a0:	d2fff0ef          	jal	ra,4ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a4:	0992                	slli	s3,s3,0x4
 7a6:	397d                	addiw	s2,s2,-1
 7a8:	fe0916e3          	bnez	s2,794 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7ac:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	bd05                	j	5e2 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7b4:	008b8913          	addi	s2,s7,8
 7b8:	000bc583          	lbu	a1,0(s7)
 7bc:	855a                	mv	a0,s6
 7be:	d11ff0ef          	jal	ra,4ce <putc>
 7c2:	8bca                	mv	s7,s2
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bd31                	j	5e2 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7c8:	008b8993          	addi	s3,s7,8
 7cc:	000bb903          	ld	s2,0(s7)
 7d0:	00090f63          	beqz	s2,7ee <vprintf+0x266>
        for(; *s; s++)
 7d4:	00094583          	lbu	a1,0(s2)
 7d8:	c195                	beqz	a1,7fc <vprintf+0x274>
          putc(fd, *s);
 7da:	855a                	mv	a0,s6
 7dc:	cf3ff0ef          	jal	ra,4ce <putc>
        for(; *s; s++)
 7e0:	0905                	addi	s2,s2,1
 7e2:	00094583          	lbu	a1,0(s2)
 7e6:	f9f5                	bnez	a1,7da <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7e8:	8bce                	mv	s7,s3
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bbdd                	j	5e2 <vprintf+0x5a>
          s = "(null)";
 7ee:	00000917          	auipc	s2,0x0
 7f2:	23a90913          	addi	s2,s2,570 # a28 <malloc+0x12a>
        for(; *s; s++)
 7f6:	02800593          	li	a1,40
 7fa:	b7c5                	j	7da <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7fc:	8bce                	mv	s7,s3
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b3cd                	j	5e2 <vprintf+0x5a>
    }
  }
}
 802:	70e6                	ld	ra,120(sp)
 804:	7446                	ld	s0,112(sp)
 806:	74a6                	ld	s1,104(sp)
 808:	7906                	ld	s2,96(sp)
 80a:	69e6                	ld	s3,88(sp)
 80c:	6a46                	ld	s4,80(sp)
 80e:	6aa6                	ld	s5,72(sp)
 810:	6b06                	ld	s6,64(sp)
 812:	7be2                	ld	s7,56(sp)
 814:	7c42                	ld	s8,48(sp)
 816:	7ca2                	ld	s9,40(sp)
 818:	7d02                	ld	s10,32(sp)
 81a:	6de2                	ld	s11,24(sp)
 81c:	6109                	addi	sp,sp,128
 81e:	8082                	ret

0000000000000820 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 820:	715d                	addi	sp,sp,-80
 822:	ec06                	sd	ra,24(sp)
 824:	e822                	sd	s0,16(sp)
 826:	1000                	addi	s0,sp,32
 828:	e010                	sd	a2,0(s0)
 82a:	e414                	sd	a3,8(s0)
 82c:	e818                	sd	a4,16(s0)
 82e:	ec1c                	sd	a5,24(s0)
 830:	03043023          	sd	a6,32(s0)
 834:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83c:	8622                	mv	a2,s0
 83e:	d4bff0ef          	jal	ra,588 <vprintf>
}
 842:	60e2                	ld	ra,24(sp)
 844:	6442                	ld	s0,16(sp)
 846:	6161                	addi	sp,sp,80
 848:	8082                	ret

000000000000084a <printf>:

void
printf(const char *fmt, ...)
{
 84a:	711d                	addi	sp,sp,-96
 84c:	ec06                	sd	ra,24(sp)
 84e:	e822                	sd	s0,16(sp)
 850:	1000                	addi	s0,sp,32
 852:	e40c                	sd	a1,8(s0)
 854:	e810                	sd	a2,16(s0)
 856:	ec14                	sd	a3,24(s0)
 858:	f018                	sd	a4,32(s0)
 85a:	f41c                	sd	a5,40(s0)
 85c:	03043823          	sd	a6,48(s0)
 860:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 864:	00840613          	addi	a2,s0,8
 868:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 86c:	85aa                	mv	a1,a0
 86e:	4505                	li	a0,1
 870:	d19ff0ef          	jal	ra,588 <vprintf>
}
 874:	60e2                	ld	ra,24(sp)
 876:	6442                	ld	s0,16(sp)
 878:	6125                	addi	sp,sp,96
 87a:	8082                	ret

000000000000087c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87c:	1141                	addi	sp,sp,-16
 87e:	e422                	sd	s0,8(sp)
 880:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 882:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 886:	00000797          	auipc	a5,0x0
 88a:	77a7b783          	ld	a5,1914(a5) # 1000 <freep>
 88e:	a02d                	j	8b8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 890:	4618                	lw	a4,8(a2)
 892:	9f2d                	addw	a4,a4,a1
 894:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 898:	6398                	ld	a4,0(a5)
 89a:	6310                	ld	a2,0(a4)
 89c:	a83d                	j	8da <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 89e:	ff852703          	lw	a4,-8(a0)
 8a2:	9f31                	addw	a4,a4,a2
 8a4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8a6:	ff053683          	ld	a3,-16(a0)
 8aa:	a091                	j	8ee <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ac:	6398                	ld	a4,0(a5)
 8ae:	00e7e463          	bltu	a5,a4,8b6 <free+0x3a>
 8b2:	00e6ea63          	bltu	a3,a4,8c6 <free+0x4a>
{
 8b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b8:	fed7fae3          	bgeu	a5,a3,8ac <free+0x30>
 8bc:	6398                	ld	a4,0(a5)
 8be:	00e6e463          	bltu	a3,a4,8c6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c2:	fee7eae3          	bltu	a5,a4,8b6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8c6:	ff852583          	lw	a1,-8(a0)
 8ca:	6390                	ld	a2,0(a5)
 8cc:	02059813          	slli	a6,a1,0x20
 8d0:	01c85713          	srli	a4,a6,0x1c
 8d4:	9736                	add	a4,a4,a3
 8d6:	fae60de3          	beq	a2,a4,890 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8de:	4790                	lw	a2,8(a5)
 8e0:	02061593          	slli	a1,a2,0x20
 8e4:	01c5d713          	srli	a4,a1,0x1c
 8e8:	973e                	add	a4,a4,a5
 8ea:	fae68ae3          	beq	a3,a4,89e <free+0x22>
    p->s.ptr = bp->s.ptr;
 8ee:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f0:	00000717          	auipc	a4,0x0
 8f4:	70f73823          	sd	a5,1808(a4) # 1000 <freep>
}
 8f8:	6422                	ld	s0,8(sp)
 8fa:	0141                	addi	sp,sp,16
 8fc:	8082                	ret

00000000000008fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8fe:	7139                	addi	sp,sp,-64
 900:	fc06                	sd	ra,56(sp)
 902:	f822                	sd	s0,48(sp)
 904:	f426                	sd	s1,40(sp)
 906:	f04a                	sd	s2,32(sp)
 908:	ec4e                	sd	s3,24(sp)
 90a:	e852                	sd	s4,16(sp)
 90c:	e456                	sd	s5,8(sp)
 90e:	e05a                	sd	s6,0(sp)
 910:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 912:	02051493          	slli	s1,a0,0x20
 916:	9081                	srli	s1,s1,0x20
 918:	04bd                	addi	s1,s1,15
 91a:	8091                	srli	s1,s1,0x4
 91c:	0014899b          	addiw	s3,s1,1
 920:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 922:	00000517          	auipc	a0,0x0
 926:	6de53503          	ld	a0,1758(a0) # 1000 <freep>
 92a:	c515                	beqz	a0,956 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92e:	4798                	lw	a4,8(a5)
 930:	02977f63          	bgeu	a4,s1,96e <malloc+0x70>
 934:	8a4e                	mv	s4,s3
 936:	0009871b          	sext.w	a4,s3
 93a:	6685                	lui	a3,0x1
 93c:	00d77363          	bgeu	a4,a3,942 <malloc+0x44>
 940:	6a05                	lui	s4,0x1
 942:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 946:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 94a:	00000917          	auipc	s2,0x0
 94e:	6b690913          	addi	s2,s2,1718 # 1000 <freep>
  if(p == SBRK_ERROR)
 952:	5afd                	li	s5,-1
 954:	a885                	j	9c4 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 956:	00001797          	auipc	a5,0x1
 95a:	8ba78793          	addi	a5,a5,-1862 # 1210 <base>
 95e:	00000717          	auipc	a4,0x0
 962:	6af73123          	sd	a5,1698(a4) # 1000 <freep>
 966:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 968:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 96c:	b7e1                	j	934 <malloc+0x36>
      if(p->s.size == nunits)
 96e:	02e48c63          	beq	s1,a4,9a6 <malloc+0xa8>
        p->s.size -= nunits;
 972:	4137073b          	subw	a4,a4,s3
 976:	c798                	sw	a4,8(a5)
        p += p->s.size;
 978:	02071693          	slli	a3,a4,0x20
 97c:	01c6d713          	srli	a4,a3,0x1c
 980:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 982:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 986:	00000717          	auipc	a4,0x0
 98a:	66a73d23          	sd	a0,1658(a4) # 1000 <freep>
      return (void*)(p + 1);
 98e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 992:	70e2                	ld	ra,56(sp)
 994:	7442                	ld	s0,48(sp)
 996:	74a2                	ld	s1,40(sp)
 998:	7902                	ld	s2,32(sp)
 99a:	69e2                	ld	s3,24(sp)
 99c:	6a42                	ld	s4,16(sp)
 99e:	6aa2                	ld	s5,8(sp)
 9a0:	6b02                	ld	s6,0(sp)
 9a2:	6121                	addi	sp,sp,64
 9a4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9a6:	6398                	ld	a4,0(a5)
 9a8:	e118                	sd	a4,0(a0)
 9aa:	bff1                	j	986 <malloc+0x88>
  hp->s.size = nu;
 9ac:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b0:	0541                	addi	a0,a0,16
 9b2:	ecbff0ef          	jal	ra,87c <free>
  return freep;
 9b6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ba:	dd61                	beqz	a0,992 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9be:	4798                	lw	a4,8(a5)
 9c0:	fa9777e3          	bgeu	a4,s1,96e <malloc+0x70>
    if(p == freep)
 9c4:	00093703          	ld	a4,0(s2)
 9c8:	853e                	mv	a0,a5
 9ca:	fef719e3          	bne	a4,a5,9bc <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 9ce:	8552                	mv	a0,s4
 9d0:	9f3ff0ef          	jal	ra,3c2 <sbrk>
  if(p == SBRK_ERROR)
 9d4:	fd551ce3          	bne	a0,s5,9ac <malloc+0xae>
        return 0;
 9d8:	4501                	li	a0,0
 9da:	bf65                	j	992 <malloc+0x94>
