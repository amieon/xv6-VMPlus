
user/_grep：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	02c000ef          	jal	ra,4a <matchhere>
  22:	e919                	bnez	a0,38 <matchstar+0x38>
  }while(*text!='\0' && (*text++==c || c=='.'));
  24:	0004c783          	lbu	a5,0(s1)
  28:	cb89                	beqz	a5,3a <matchstar+0x3a>
  2a:	0485                	addi	s1,s1,1
  2c:	2781                	sext.w	a5,a5
  2e:	ff2786e3          	beq	a5,s2,1a <matchstar+0x1a>
  32:	ff4904e3          	beq	s2,s4,1a <matchstar+0x1a>
  36:	a011                	j	3a <matchstar+0x3a>
      return 1;
  38:	4505                	li	a0,1
  return 0;
}
  3a:	70a2                	ld	ra,40(sp)
  3c:	7402                	ld	s0,32(sp)
  3e:	64e2                	ld	s1,24(sp)
  40:	6942                	ld	s2,16(sp)
  42:	69a2                	ld	s3,8(sp)
  44:	6a02                	ld	s4,0(sp)
  46:	6145                	addi	sp,sp,48
  48:	8082                	ret

000000000000004a <matchhere>:
  if(re[0] == '\0')
  4a:	00054703          	lbu	a4,0(a0)
  4e:	c73d                	beqz	a4,bc <matchhere+0x72>
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  58:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5a:	00154683          	lbu	a3,1(a0)
  5e:	02a00613          	li	a2,42
  62:	02c68563          	beq	a3,a2,8c <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  66:	02400613          	li	a2,36
  6a:	02c70863          	beq	a4,a2,9a <matchhere+0x50>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  6e:	0005c683          	lbu	a3,0(a1)
  return 0;
  72:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  74:	ca81                	beqz	a3,84 <matchhere+0x3a>
  76:	02e00613          	li	a2,46
  7a:	02c70b63          	beq	a4,a2,b0 <matchhere+0x66>
  return 0;
  7e:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  80:	02d70863          	beq	a4,a3,b0 <matchhere+0x66>
}
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret
    return matchstar(re[0], re+2, text);
  8c:	862e                	mv	a2,a1
  8e:	00250593          	addi	a1,a0,2
  92:	853a                	mv	a0,a4
  94:	f6dff0ef          	jal	ra,0 <matchstar>
  98:	b7f5                	j	84 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  9a:	c691                	beqz	a3,a6 <matchhere+0x5c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  9c:	0005c683          	lbu	a3,0(a1)
  a0:	fef9                	bnez	a3,7e <matchhere+0x34>
  return 0;
  a2:	4501                	li	a0,0
  a4:	b7c5                	j	84 <matchhere+0x3a>
    return *text == '\0';
  a6:	0005c503          	lbu	a0,0(a1)
  aa:	00153513          	seqz	a0,a0
  ae:	bfd9                	j	84 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b0:	0585                	addi	a1,a1,1
  b2:	00178513          	addi	a0,a5,1
  b6:	f95ff0ef          	jal	ra,4a <matchhere>
  ba:	b7e9                	j	84 <matchhere+0x3a>
    return 1;
  bc:	4505                	li	a0,1
}
  be:	8082                	ret

00000000000000c0 <match>:
{
  c0:	1101                	addi	sp,sp,-32
  c2:	ec06                	sd	ra,24(sp)
  c4:	e822                	sd	s0,16(sp)
  c6:	e426                	sd	s1,8(sp)
  c8:	e04a                	sd	s2,0(sp)
  ca:	1000                	addi	s0,sp,32
  cc:	892a                	mv	s2,a0
  ce:	84ae                	mv	s1,a1
  if(re[0] == '^')
  d0:	00054703          	lbu	a4,0(a0)
  d4:	05e00793          	li	a5,94
  d8:	00f70c63          	beq	a4,a5,f0 <match+0x30>
    if(matchhere(re, text))
  dc:	85a6                	mv	a1,s1
  de:	854a                	mv	a0,s2
  e0:	f6bff0ef          	jal	ra,4a <matchhere>
  e4:	e911                	bnez	a0,f8 <match+0x38>
  }while(*text++ != '\0');
  e6:	0485                	addi	s1,s1,1
  e8:	fff4c783          	lbu	a5,-1(s1)
  ec:	fbe5                	bnez	a5,dc <match+0x1c>
  ee:	a031                	j	fa <match+0x3a>
    return matchhere(re+1, text);
  f0:	0505                	addi	a0,a0,1
  f2:	f59ff0ef          	jal	ra,4a <matchhere>
  f6:	a011                	j	fa <match+0x3a>
      return 1;
  f8:	4505                	li	a0,1
}
  fa:	60e2                	ld	ra,24(sp)
  fc:	6442                	ld	s0,16(sp)
  fe:	64a2                	ld	s1,8(sp)
 100:	6902                	ld	s2,0(sp)
 102:	6105                	addi	sp,sp,32
 104:	8082                	ret

0000000000000106 <grep>:
{
 106:	715d                	addi	sp,sp,-80
 108:	e486                	sd	ra,72(sp)
 10a:	e0a2                	sd	s0,64(sp)
 10c:	fc26                	sd	s1,56(sp)
 10e:	f84a                	sd	s2,48(sp)
 110:	f44e                	sd	s3,40(sp)
 112:	f052                	sd	s4,32(sp)
 114:	ec56                	sd	s5,24(sp)
 116:	e85a                	sd	s6,16(sp)
 118:	e45e                	sd	s7,8(sp)
 11a:	0880                	addi	s0,sp,80
 11c:	89aa                	mv	s3,a0
 11e:	8b2e                	mv	s6,a1
  m = 0;
 120:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 122:	3ff00b93          	li	s7,1023
 126:	00001a97          	auipc	s5,0x1
 12a:	eeaa8a93          	addi	s5,s5,-278 # 1010 <buf>
 12e:	a835                	j	16a <grep+0x64>
      p = q+1;
 130:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 134:	45a9                	li	a1,10
 136:	854a                	mv	a0,s2
 138:	1ba000ef          	jal	ra,2f2 <strchr>
 13c:	84aa                	mv	s1,a0
 13e:	c505                	beqz	a0,166 <grep+0x60>
      *q = 0;
 140:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 144:	85ca                	mv	a1,s2
 146:	854e                	mv	a0,s3
 148:	f79ff0ef          	jal	ra,c0 <match>
 14c:	d175                	beqz	a0,130 <grep+0x2a>
        *q = '\n';
 14e:	47a9                	li	a5,10
 150:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 154:	00148613          	addi	a2,s1,1
 158:	4126063b          	subw	a2,a2,s2
 15c:	85ca                	mv	a1,s2
 15e:	4505                	li	a0,1
 160:	3a2000ef          	jal	ra,502 <write>
 164:	b7f1                	j	130 <grep+0x2a>
    if(m > 0){
 166:	03404363          	bgtz	s4,18c <grep+0x86>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 16a:	414b863b          	subw	a2,s7,s4
 16e:	014a85b3          	add	a1,s5,s4
 172:	855a                	mv	a0,s6
 174:	386000ef          	jal	ra,4fa <read>
 178:	02a05463          	blez	a0,1a0 <grep+0x9a>
    m += n;
 17c:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 180:	014a87b3          	add	a5,s5,s4
 184:	00078023          	sb	zero,0(a5)
    p = buf;
 188:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 18a:	b76d                	j	134 <grep+0x2e>
      m -= p - buf;
 18c:	415907b3          	sub	a5,s2,s5
 190:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 194:	8652                	mv	a2,s4
 196:	85ca                	mv	a1,s2
 198:	8556                	mv	a0,s5
 19a:	26e000ef          	jal	ra,408 <memmove>
 19e:	b7f1                	j	16a <grep+0x64>
}
 1a0:	60a6                	ld	ra,72(sp)
 1a2:	6406                	ld	s0,64(sp)
 1a4:	74e2                	ld	s1,56(sp)
 1a6:	7942                	ld	s2,48(sp)
 1a8:	79a2                	ld	s3,40(sp)
 1aa:	7a02                	ld	s4,32(sp)
 1ac:	6ae2                	ld	s5,24(sp)
 1ae:	6b42                	ld	s6,16(sp)
 1b0:	6ba2                	ld	s7,8(sp)
 1b2:	6161                	addi	sp,sp,80
 1b4:	8082                	ret

00000000000001b6 <main>:
{
 1b6:	7139                	addi	sp,sp,-64
 1b8:	fc06                	sd	ra,56(sp)
 1ba:	f822                	sd	s0,48(sp)
 1bc:	f426                	sd	s1,40(sp)
 1be:	f04a                	sd	s2,32(sp)
 1c0:	ec4e                	sd	s3,24(sp)
 1c2:	e852                	sd	s4,16(sp)
 1c4:	e456                	sd	s5,8(sp)
 1c6:	0080                	addi	s0,sp,64
  if(argc <= 1){
 1c8:	4785                	li	a5,1
 1ca:	04a7d663          	bge	a5,a0,216 <main+0x60>
  pattern = argv[1];
 1ce:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1d2:	4789                	li	a5,2
 1d4:	04a7db63          	bge	a5,a0,22a <main+0x74>
 1d8:	01058913          	addi	s2,a1,16
 1dc:	ffd5099b          	addiw	s3,a0,-3
 1e0:	02099793          	slli	a5,s3,0x20
 1e4:	01d7d993          	srli	s3,a5,0x1d
 1e8:	05e1                	addi	a1,a1,24
 1ea:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1ec:	4581                	li	a1,0
 1ee:	00093503          	ld	a0,0(s2)
 1f2:	330000ef          	jal	ra,522 <open>
 1f6:	84aa                	mv	s1,a0
 1f8:	04054063          	bltz	a0,238 <main+0x82>
    grep(pattern, fd);
 1fc:	85aa                	mv	a1,a0
 1fe:	8552                	mv	a0,s4
 200:	f07ff0ef          	jal	ra,106 <grep>
    close(fd);
 204:	8526                	mv	a0,s1
 206:	304000ef          	jal	ra,50a <close>
  for(i = 2; i < argc; i++){
 20a:	0921                	addi	s2,s2,8
 20c:	ff3910e3          	bne	s2,s3,1ec <main+0x36>
  exit(0);
 210:	4501                	li	a0,0
 212:	2d0000ef          	jal	ra,4e2 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 216:	00001597          	auipc	a1,0x1
 21a:	89a58593          	addi	a1,a1,-1894 # ab0 <malloc+0xde>
 21e:	4509                	li	a0,2
 220:	6d4000ef          	jal	ra,8f4 <fprintf>
    exit(1);
 224:	4505                	li	a0,1
 226:	2bc000ef          	jal	ra,4e2 <exit>
    grep(pattern, 0);
 22a:	4581                	li	a1,0
 22c:	8552                	mv	a0,s4
 22e:	ed9ff0ef          	jal	ra,106 <grep>
    exit(0);
 232:	4501                	li	a0,0
 234:	2ae000ef          	jal	ra,4e2 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 238:	00093583          	ld	a1,0(s2)
 23c:	00001517          	auipc	a0,0x1
 240:	89450513          	addi	a0,a0,-1900 # ad0 <malloc+0xfe>
 244:	6da000ef          	jal	ra,91e <printf>
      exit(1);
 248:	4505                	li	a0,1
 24a:	298000ef          	jal	ra,4e2 <exit>

000000000000024e <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e406                	sd	ra,8(sp)
 252:	e022                	sd	s0,0(sp)
 254:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 256:	f61ff0ef          	jal	ra,1b6 <main>
  exit(r);
 25a:	288000ef          	jal	ra,4e2 <exit>

000000000000025e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 264:	87aa                	mv	a5,a0
 266:	0585                	addi	a1,a1,1
 268:	0785                	addi	a5,a5,1
 26a:	fff5c703          	lbu	a4,-1(a1)
 26e:	fee78fa3          	sb	a4,-1(a5)
 272:	fb75                	bnez	a4,266 <strcpy+0x8>
    ;
  return os;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 280:	00054783          	lbu	a5,0(a0)
 284:	cb91                	beqz	a5,298 <strcmp+0x1e>
 286:	0005c703          	lbu	a4,0(a1)
 28a:	00f71763          	bne	a4,a5,298 <strcmp+0x1e>
    p++, q++;
 28e:	0505                	addi	a0,a0,1
 290:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 292:	00054783          	lbu	a5,0(a0)
 296:	fbe5                	bnez	a5,286 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 298:	0005c503          	lbu	a0,0(a1)
}
 29c:	40a7853b          	subw	a0,a5,a0
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <strlen>:

uint
strlen(const char *s)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	cf91                	beqz	a5,2cc <strlen+0x26>
 2b2:	0505                	addi	a0,a0,1
 2b4:	87aa                	mv	a5,a0
 2b6:	4685                	li	a3,1
 2b8:	9e89                	subw	a3,a3,a0
 2ba:	00f6853b          	addw	a0,a3,a5
 2be:	0785                	addi	a5,a5,1
 2c0:	fff7c703          	lbu	a4,-1(a5)
 2c4:	fb7d                	bnez	a4,2ba <strlen+0x14>
    ;
  return n;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  for(n = 0; s[n]; n++)
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <strlen+0x20>

00000000000002d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d6:	ca19                	beqz	a2,2ec <memset+0x1c>
 2d8:	87aa                	mv	a5,a0
 2da:	1602                	slli	a2,a2,0x20
 2dc:	9201                	srli	a2,a2,0x20
 2de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e6:	0785                	addi	a5,a5,1
 2e8:	fee79de3          	bne	a5,a4,2e2 <memset+0x12>
  }
  return dst;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <strchr>:

char*
strchr(const char *s, char c)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	cb99                	beqz	a5,312 <strchr+0x20>
    if(*s == c)
 2fe:	00f58763          	beq	a1,a5,30c <strchr+0x1a>
  for(; *s; s++)
 302:	0505                	addi	a0,a0,1
 304:	00054783          	lbu	a5,0(a0)
 308:	fbfd                	bnez	a5,2fe <strchr+0xc>
      return (char*)s;
  return 0;
 30a:	4501                	li	a0,0
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  return 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <strchr+0x1a>

0000000000000316 <gets>:

char*
gets(char *buf, int max)
{
 316:	711d                	addi	sp,sp,-96
 318:	ec86                	sd	ra,88(sp)
 31a:	e8a2                	sd	s0,80(sp)
 31c:	e4a6                	sd	s1,72(sp)
 31e:	e0ca                	sd	s2,64(sp)
 320:	fc4e                	sd	s3,56(sp)
 322:	f852                	sd	s4,48(sp)
 324:	f456                	sd	s5,40(sp)
 326:	f05a                	sd	s6,32(sp)
 328:	ec5e                	sd	s7,24(sp)
 32a:	1080                	addi	s0,sp,96
 32c:	8baa                	mv	s7,a0
 32e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 330:	892a                	mv	s2,a0
 332:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 334:	4aa9                	li	s5,10
 336:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 338:	89a6                	mv	s3,s1
 33a:	2485                	addiw	s1,s1,1
 33c:	0344d663          	bge	s1,s4,368 <gets+0x52>
    cc = read(0, &c, 1);
 340:	4605                	li	a2,1
 342:	faf40593          	addi	a1,s0,-81
 346:	4501                	li	a0,0
 348:	1b2000ef          	jal	ra,4fa <read>
    if(cc < 1)
 34c:	00a05e63          	blez	a0,368 <gets+0x52>
    buf[i++] = c;
 350:	faf44783          	lbu	a5,-81(s0)
 354:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 358:	01578763          	beq	a5,s5,366 <gets+0x50>
 35c:	0905                	addi	s2,s2,1
 35e:	fd679de3          	bne	a5,s6,338 <gets+0x22>
  for(i=0; i+1 < max; ){
 362:	89a6                	mv	s3,s1
 364:	a011                	j	368 <gets+0x52>
 366:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 368:	99de                	add	s3,s3,s7
 36a:	00098023          	sb	zero,0(s3)
  return buf;
}
 36e:	855e                	mv	a0,s7
 370:	60e6                	ld	ra,88(sp)
 372:	6446                	ld	s0,80(sp)
 374:	64a6                	ld	s1,72(sp)
 376:	6906                	ld	s2,64(sp)
 378:	79e2                	ld	s3,56(sp)
 37a:	7a42                	ld	s4,48(sp)
 37c:	7aa2                	ld	s5,40(sp)
 37e:	7b02                	ld	s6,32(sp)
 380:	6be2                	ld	s7,24(sp)
 382:	6125                	addi	sp,sp,96
 384:	8082                	ret

0000000000000386 <stat>:

int
stat(const char *n, struct stat *st)
{
 386:	1101                	addi	sp,sp,-32
 388:	ec06                	sd	ra,24(sp)
 38a:	e822                	sd	s0,16(sp)
 38c:	e426                	sd	s1,8(sp)
 38e:	e04a                	sd	s2,0(sp)
 390:	1000                	addi	s0,sp,32
 392:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 394:	4581                	li	a1,0
 396:	18c000ef          	jal	ra,522 <open>
  if(fd < 0)
 39a:	02054163          	bltz	a0,3bc <stat+0x36>
 39e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a0:	85ca                	mv	a1,s2
 3a2:	198000ef          	jal	ra,53a <fstat>
 3a6:	892a                	mv	s2,a0
  close(fd);
 3a8:	8526                	mv	a0,s1
 3aa:	160000ef          	jal	ra,50a <close>
  return r;
}
 3ae:	854a                	mv	a0,s2
 3b0:	60e2                	ld	ra,24(sp)
 3b2:	6442                	ld	s0,16(sp)
 3b4:	64a2                	ld	s1,8(sp)
 3b6:	6902                	ld	s2,0(sp)
 3b8:	6105                	addi	sp,sp,32
 3ba:	8082                	ret
    return -1;
 3bc:	597d                	li	s2,-1
 3be:	bfc5                	j	3ae <stat+0x28>

00000000000003c0 <atoi>:

int
atoi(const char *s)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c6:	00054683          	lbu	a3,0(a0)
 3ca:	fd06879b          	addiw	a5,a3,-48
 3ce:	0ff7f793          	zext.b	a5,a5
 3d2:	4625                	li	a2,9
 3d4:	02f66863          	bltu	a2,a5,404 <atoi+0x44>
 3d8:	872a                	mv	a4,a0
  n = 0;
 3da:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3dc:	0705                	addi	a4,a4,1
 3de:	0025179b          	slliw	a5,a0,0x2
 3e2:	9fa9                	addw	a5,a5,a0
 3e4:	0017979b          	slliw	a5,a5,0x1
 3e8:	9fb5                	addw	a5,a5,a3
 3ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3ee:	00074683          	lbu	a3,0(a4)
 3f2:	fd06879b          	addiw	a5,a3,-48
 3f6:	0ff7f793          	zext.b	a5,a5
 3fa:	fef671e3          	bgeu	a2,a5,3dc <atoi+0x1c>
  return n;
}
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
  n = 0;
 404:	4501                	li	a0,0
 406:	bfe5                	j	3fe <atoi+0x3e>

0000000000000408 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 408:	1141                	addi	sp,sp,-16
 40a:	e422                	sd	s0,8(sp)
 40c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 40e:	02b57463          	bgeu	a0,a1,436 <memmove+0x2e>
    while(n-- > 0)
 412:	00c05f63          	blez	a2,430 <memmove+0x28>
 416:	1602                	slli	a2,a2,0x20
 418:	9201                	srli	a2,a2,0x20
 41a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 41e:	872a                	mv	a4,a0
      *dst++ = *src++;
 420:	0585                	addi	a1,a1,1
 422:	0705                	addi	a4,a4,1
 424:	fff5c683          	lbu	a3,-1(a1)
 428:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 42c:	fee79ae3          	bne	a5,a4,420 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 430:	6422                	ld	s0,8(sp)
 432:	0141                	addi	sp,sp,16
 434:	8082                	ret
    dst += n;
 436:	00c50733          	add	a4,a0,a2
    src += n;
 43a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 43c:	fec05ae3          	blez	a2,430 <memmove+0x28>
 440:	fff6079b          	addiw	a5,a2,-1
 444:	1782                	slli	a5,a5,0x20
 446:	9381                	srli	a5,a5,0x20
 448:	fff7c793          	not	a5,a5
 44c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 44e:	15fd                	addi	a1,a1,-1
 450:	177d                	addi	a4,a4,-1
 452:	0005c683          	lbu	a3,0(a1)
 456:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 45a:	fee79ae3          	bne	a5,a4,44e <memmove+0x46>
 45e:	bfc9                	j	430 <memmove+0x28>

0000000000000460 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 460:	1141                	addi	sp,sp,-16
 462:	e422                	sd	s0,8(sp)
 464:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 466:	ca05                	beqz	a2,496 <memcmp+0x36>
 468:	fff6069b          	addiw	a3,a2,-1
 46c:	1682                	slli	a3,a3,0x20
 46e:	9281                	srli	a3,a3,0x20
 470:	0685                	addi	a3,a3,1
 472:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 474:	00054783          	lbu	a5,0(a0)
 478:	0005c703          	lbu	a4,0(a1)
 47c:	00e79863          	bne	a5,a4,48c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 480:	0505                	addi	a0,a0,1
    p2++;
 482:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 484:	fed518e3          	bne	a0,a3,474 <memcmp+0x14>
  }
  return 0;
 488:	4501                	li	a0,0
 48a:	a019                	j	490 <memcmp+0x30>
      return *p1 - *p2;
 48c:	40e7853b          	subw	a0,a5,a4
}
 490:	6422                	ld	s0,8(sp)
 492:	0141                	addi	sp,sp,16
 494:	8082                	ret
  return 0;
 496:	4501                	li	a0,0
 498:	bfe5                	j	490 <memcmp+0x30>

000000000000049a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 49a:	1141                	addi	sp,sp,-16
 49c:	e406                	sd	ra,8(sp)
 49e:	e022                	sd	s0,0(sp)
 4a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4a2:	f67ff0ef          	jal	ra,408 <memmove>
}
 4a6:	60a2                	ld	ra,8(sp)
 4a8:	6402                	ld	s0,0(sp)
 4aa:	0141                	addi	sp,sp,16
 4ac:	8082                	ret

00000000000004ae <sbrk>:

char *
sbrk(int n) {
 4ae:	1141                	addi	sp,sp,-16
 4b0:	e406                	sd	ra,8(sp)
 4b2:	e022                	sd	s0,0(sp)
 4b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4b6:	4585                	li	a1,1
 4b8:	0b2000ef          	jal	ra,56a <sys_sbrk>
}
 4bc:	60a2                	ld	ra,8(sp)
 4be:	6402                	ld	s0,0(sp)
 4c0:	0141                	addi	sp,sp,16
 4c2:	8082                	ret

00000000000004c4 <sbrklazy>:

char *
sbrklazy(int n) {
 4c4:	1141                	addi	sp,sp,-16
 4c6:	e406                	sd	ra,8(sp)
 4c8:	e022                	sd	s0,0(sp)
 4ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4cc:	4589                	li	a1,2
 4ce:	09c000ef          	jal	ra,56a <sys_sbrk>
}
 4d2:	60a2                	ld	ra,8(sp)
 4d4:	6402                	ld	s0,0(sp)
 4d6:	0141                	addi	sp,sp,16
 4d8:	8082                	ret

00000000000004da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4da:	4885                	li	a7,1
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4e2:	4889                	li	a7,2
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ea:	488d                	li	a7,3
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4f2:	4891                	li	a7,4
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <read>:
.global read
read:
 li a7, SYS_read
 4fa:	4895                	li	a7,5
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <write>:
.global write
write:
 li a7, SYS_write
 502:	48c1                	li	a7,16
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <close>:
.global close
close:
 li a7, SYS_close
 50a:	48d5                	li	a7,21
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <kill>:
.global kill
kill:
 li a7, SYS_kill
 512:	4899                	li	a7,6
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <exec>:
.global exec
exec:
 li a7, SYS_exec
 51a:	489d                	li	a7,7
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <open>:
.global open
open:
 li a7, SYS_open
 522:	48bd                	li	a7,15
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 52a:	48c5                	li	a7,17
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 532:	48c9                	li	a7,18
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 53a:	48a1                	li	a7,8
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <link>:
.global link
link:
 li a7, SYS_link
 542:	48cd                	li	a7,19
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 54a:	48d1                	li	a7,20
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 552:	48a5                	li	a7,9
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <dup>:
.global dup
dup:
 li a7, SYS_dup
 55a:	48a9                	li	a7,10
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 562:	48ad                	li	a7,11
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 56a:	48b1                	li	a7,12
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <pause>:
.global pause
pause:
 li a7, SYS_pause
 572:	48b5                	li	a7,13
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 57a:	48b9                	li	a7,14
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 582:	48d9                	li	a7,22
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 58a:	48dd                	li	a7,23
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 592:	48e1                	li	a7,24
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 59a:	48e5                	li	a7,25
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5a2:	1101                	addi	sp,sp,-32
 5a4:	ec06                	sd	ra,24(sp)
 5a6:	e822                	sd	s0,16(sp)
 5a8:	1000                	addi	s0,sp,32
 5aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ae:	4605                	li	a2,1
 5b0:	fef40593          	addi	a1,s0,-17
 5b4:	f4fff0ef          	jal	ra,502 <write>
}
 5b8:	60e2                	ld	ra,24(sp)
 5ba:	6442                	ld	s0,16(sp)
 5bc:	6105                	addi	sp,sp,32
 5be:	8082                	ret

00000000000005c0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5c0:	715d                	addi	sp,sp,-80
 5c2:	e486                	sd	ra,72(sp)
 5c4:	e0a2                	sd	s0,64(sp)
 5c6:	fc26                	sd	s1,56(sp)
 5c8:	f84a                	sd	s2,48(sp)
 5ca:	f44e                	sd	s3,40(sp)
 5cc:	0880                	addi	s0,sp,80
 5ce:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5d0:	c299                	beqz	a3,5d6 <printint+0x16>
 5d2:	0805c163          	bltz	a1,654 <printint+0x94>
  neg = 0;
 5d6:	4881                	li	a7,0
 5d8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5dc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5de:	00000517          	auipc	a0,0x0
 5e2:	51250513          	addi	a0,a0,1298 # af0 <digits>
 5e6:	883e                	mv	a6,a5
 5e8:	2785                	addiw	a5,a5,1
 5ea:	02c5f733          	remu	a4,a1,a2
 5ee:	972a                	add	a4,a4,a0
 5f0:	00074703          	lbu	a4,0(a4)
 5f4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5f8:	872e                	mv	a4,a1
 5fa:	02c5d5b3          	divu	a1,a1,a2
 5fe:	0685                	addi	a3,a3,1
 600:	fec773e3          	bgeu	a4,a2,5e6 <printint+0x26>
  if(neg)
 604:	00088b63          	beqz	a7,61a <printint+0x5a>
    buf[i++] = '-';
 608:	fd078793          	addi	a5,a5,-48
 60c:	97a2                	add	a5,a5,s0
 60e:	02d00713          	li	a4,45
 612:	fee78423          	sb	a4,-24(a5)
 616:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 61a:	02f05663          	blez	a5,646 <printint+0x86>
 61e:	fb840713          	addi	a4,s0,-72
 622:	00f704b3          	add	s1,a4,a5
 626:	fff70993          	addi	s3,a4,-1
 62a:	99be                	add	s3,s3,a5
 62c:	37fd                	addiw	a5,a5,-1
 62e:	1782                	slli	a5,a5,0x20
 630:	9381                	srli	a5,a5,0x20
 632:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 636:	fff4c583          	lbu	a1,-1(s1)
 63a:	854a                	mv	a0,s2
 63c:	f67ff0ef          	jal	ra,5a2 <putc>
  while(--i >= 0)
 640:	14fd                	addi	s1,s1,-1
 642:	ff349ae3          	bne	s1,s3,636 <printint+0x76>
}
 646:	60a6                	ld	ra,72(sp)
 648:	6406                	ld	s0,64(sp)
 64a:	74e2                	ld	s1,56(sp)
 64c:	7942                	ld	s2,48(sp)
 64e:	79a2                	ld	s3,40(sp)
 650:	6161                	addi	sp,sp,80
 652:	8082                	ret
    x = -xx;
 654:	40b005b3          	neg	a1,a1
    neg = 1;
 658:	4885                	li	a7,1
    x = -xx;
 65a:	bfbd                	j	5d8 <printint+0x18>

000000000000065c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 65c:	7119                	addi	sp,sp,-128
 65e:	fc86                	sd	ra,120(sp)
 660:	f8a2                	sd	s0,112(sp)
 662:	f4a6                	sd	s1,104(sp)
 664:	f0ca                	sd	s2,96(sp)
 666:	ecce                	sd	s3,88(sp)
 668:	e8d2                	sd	s4,80(sp)
 66a:	e4d6                	sd	s5,72(sp)
 66c:	e0da                	sd	s6,64(sp)
 66e:	fc5e                	sd	s7,56(sp)
 670:	f862                	sd	s8,48(sp)
 672:	f466                	sd	s9,40(sp)
 674:	f06a                	sd	s10,32(sp)
 676:	ec6e                	sd	s11,24(sp)
 678:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 67a:	0005c903          	lbu	s2,0(a1)
 67e:	24090c63          	beqz	s2,8d6 <vprintf+0x27a>
 682:	8b2a                	mv	s6,a0
 684:	8a2e                	mv	s4,a1
 686:	8bb2                	mv	s7,a2
  state = 0;
 688:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 68a:	4481                	li	s1,0
 68c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 68e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 692:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 696:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 69a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 69e:	00000c97          	auipc	s9,0x0
 6a2:	452c8c93          	addi	s9,s9,1106 # af0 <digits>
 6a6:	a005                	j	6c6 <vprintf+0x6a>
        putc(fd, c0);
 6a8:	85ca                	mv	a1,s2
 6aa:	855a                	mv	a0,s6
 6ac:	ef7ff0ef          	jal	ra,5a2 <putc>
 6b0:	a019                	j	6b6 <vprintf+0x5a>
    } else if(state == '%'){
 6b2:	03598263          	beq	s3,s5,6d6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6b6:	2485                	addiw	s1,s1,1
 6b8:	8726                	mv	a4,s1
 6ba:	009a07b3          	add	a5,s4,s1
 6be:	0007c903          	lbu	s2,0(a5)
 6c2:	20090a63          	beqz	s2,8d6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 6c6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6ca:	fe0994e3          	bnez	s3,6b2 <vprintf+0x56>
      if(c0 == '%'){
 6ce:	fd579de3          	bne	a5,s5,6a8 <vprintf+0x4c>
        state = '%';
 6d2:	89be                	mv	s3,a5
 6d4:	b7cd                	j	6b6 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6d6:	c3c1                	beqz	a5,756 <vprintf+0xfa>
 6d8:	00ea06b3          	add	a3,s4,a4
 6dc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6e0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6e2:	c681                	beqz	a3,6ea <vprintf+0x8e>
 6e4:	9752                	add	a4,a4,s4
 6e6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6ea:	03878e63          	beq	a5,s8,726 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 6ee:	05a78863          	beq	a5,s10,73e <vprintf+0xe2>
      } else if(c0 == 'u'){
 6f2:	0db78b63          	beq	a5,s11,7c8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6f6:	07800713          	li	a4,120
 6fa:	10e78d63          	beq	a5,a4,814 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6fe:	07000713          	li	a4,112
 702:	14e78263          	beq	a5,a4,846 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 706:	06300713          	li	a4,99
 70a:	16e78f63          	beq	a5,a4,888 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 70e:	07300713          	li	a4,115
 712:	18e78563          	beq	a5,a4,89c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 716:	05579063          	bne	a5,s5,756 <vprintf+0xfa>
        putc(fd, '%');
 71a:	85d6                	mv	a1,s5
 71c:	855a                	mv	a0,s6
 71e:	e85ff0ef          	jal	ra,5a2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 722:	4981                	li	s3,0
 724:	bf49                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 726:	008b8913          	addi	s2,s7,8
 72a:	4685                	li	a3,1
 72c:	4629                	li	a2,10
 72e:	000ba583          	lw	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	e8dff0ef          	jal	ra,5c0 <printint>
 738:	8bca                	mv	s7,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bfad                	j	6b6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 73e:	03868663          	beq	a3,s8,76a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 742:	05a68163          	beq	a3,s10,784 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 746:	09b68d63          	beq	a3,s11,7e0 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 74a:	03a68f63          	beq	a3,s10,788 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 74e:	07800793          	li	a5,120
 752:	0cf68d63          	beq	a3,a5,82c <vprintf+0x1d0>
        putc(fd, '%');
 756:	85d6                	mv	a1,s5
 758:	855a                	mv	a0,s6
 75a:	e49ff0ef          	jal	ra,5a2 <putc>
        putc(fd, c0);
 75e:	85ca                	mv	a1,s2
 760:	855a                	mv	a0,s6
 762:	e41ff0ef          	jal	ra,5a2 <putc>
      state = 0;
 766:	4981                	li	s3,0
 768:	b7b9                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 76a:	008b8913          	addi	s2,s7,8
 76e:	4685                	li	a3,1
 770:	4629                	li	a2,10
 772:	000bb583          	ld	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	e49ff0ef          	jal	ra,5c0 <printint>
        i += 1;
 77c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 77e:	8bca                	mv	s7,s2
      state = 0;
 780:	4981                	li	s3,0
        i += 1;
 782:	bf15                	j	6b6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 784:	03860563          	beq	a2,s8,7ae <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 788:	07b60963          	beq	a2,s11,7fa <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 78c:	07800793          	li	a5,120
 790:	fcf613e3          	bne	a2,a5,756 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 794:	008b8913          	addi	s2,s7,8
 798:	4681                	li	a3,0
 79a:	4641                	li	a2,16
 79c:	000bb583          	ld	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	e1fff0ef          	jal	ra,5c0 <printint>
        i += 2;
 7a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a8:	8bca                	mv	s7,s2
      state = 0;
 7aa:	4981                	li	s3,0
        i += 2;
 7ac:	b729                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ae:	008b8913          	addi	s2,s7,8
 7b2:	4685                	li	a3,1
 7b4:	4629                	li	a2,10
 7b6:	000bb583          	ld	a1,0(s7)
 7ba:	855a                	mv	a0,s6
 7bc:	e05ff0ef          	jal	ra,5c0 <printint>
        i += 2;
 7c0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7c2:	8bca                	mv	s7,s2
      state = 0;
 7c4:	4981                	li	s3,0
        i += 2;
 7c6:	bdc5                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7c8:	008b8913          	addi	s2,s7,8
 7cc:	4681                	li	a3,0
 7ce:	4629                	li	a2,10
 7d0:	000be583          	lwu	a1,0(s7)
 7d4:	855a                	mv	a0,s6
 7d6:	debff0ef          	jal	ra,5c0 <printint>
 7da:	8bca                	mv	s7,s2
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bde1                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e0:	008b8913          	addi	s2,s7,8
 7e4:	4681                	li	a3,0
 7e6:	4629                	li	a2,10
 7e8:	000bb583          	ld	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	dd3ff0ef          	jal	ra,5c0 <printint>
        i += 1;
 7f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f4:	8bca                	mv	s7,s2
      state = 0;
 7f6:	4981                	li	s3,0
        i += 1;
 7f8:	bd7d                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fa:	008b8913          	addi	s2,s7,8
 7fe:	4681                	li	a3,0
 800:	4629                	li	a2,10
 802:	000bb583          	ld	a1,0(s7)
 806:	855a                	mv	a0,s6
 808:	db9ff0ef          	jal	ra,5c0 <printint>
        i += 2;
 80c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 80e:	8bca                	mv	s7,s2
      state = 0;
 810:	4981                	li	s3,0
        i += 2;
 812:	b555                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 814:	008b8913          	addi	s2,s7,8
 818:	4681                	li	a3,0
 81a:	4641                	li	a2,16
 81c:	000be583          	lwu	a1,0(s7)
 820:	855a                	mv	a0,s6
 822:	d9fff0ef          	jal	ra,5c0 <printint>
 826:	8bca                	mv	s7,s2
      state = 0;
 828:	4981                	li	s3,0
 82a:	b571                	j	6b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 82c:	008b8913          	addi	s2,s7,8
 830:	4681                	li	a3,0
 832:	4641                	li	a2,16
 834:	000bb583          	ld	a1,0(s7)
 838:	855a                	mv	a0,s6
 83a:	d87ff0ef          	jal	ra,5c0 <printint>
        i += 1;
 83e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 840:	8bca                	mv	s7,s2
      state = 0;
 842:	4981                	li	s3,0
        i += 1;
 844:	bd8d                	j	6b6 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 846:	008b8793          	addi	a5,s7,8
 84a:	f8f43423          	sd	a5,-120(s0)
 84e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 852:	03000593          	li	a1,48
 856:	855a                	mv	a0,s6
 858:	d4bff0ef          	jal	ra,5a2 <putc>
  putc(fd, 'x');
 85c:	07800593          	li	a1,120
 860:	855a                	mv	a0,s6
 862:	d41ff0ef          	jal	ra,5a2 <putc>
 866:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 868:	03c9d793          	srli	a5,s3,0x3c
 86c:	97e6                	add	a5,a5,s9
 86e:	0007c583          	lbu	a1,0(a5)
 872:	855a                	mv	a0,s6
 874:	d2fff0ef          	jal	ra,5a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 878:	0992                	slli	s3,s3,0x4
 87a:	397d                	addiw	s2,s2,-1
 87c:	fe0916e3          	bnez	s2,868 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 880:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 884:	4981                	li	s3,0
 886:	bd05                	j	6b6 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 888:	008b8913          	addi	s2,s7,8
 88c:	000bc583          	lbu	a1,0(s7)
 890:	855a                	mv	a0,s6
 892:	d11ff0ef          	jal	ra,5a2 <putc>
 896:	8bca                	mv	s7,s2
      state = 0;
 898:	4981                	li	s3,0
 89a:	bd31                	j	6b6 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 89c:	008b8993          	addi	s3,s7,8
 8a0:	000bb903          	ld	s2,0(s7)
 8a4:	00090f63          	beqz	s2,8c2 <vprintf+0x266>
        for(; *s; s++)
 8a8:	00094583          	lbu	a1,0(s2)
 8ac:	c195                	beqz	a1,8d0 <vprintf+0x274>
          putc(fd, *s);
 8ae:	855a                	mv	a0,s6
 8b0:	cf3ff0ef          	jal	ra,5a2 <putc>
        for(; *s; s++)
 8b4:	0905                	addi	s2,s2,1
 8b6:	00094583          	lbu	a1,0(s2)
 8ba:	f9f5                	bnez	a1,8ae <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8bc:	8bce                	mv	s7,s3
      state = 0;
 8be:	4981                	li	s3,0
 8c0:	bbdd                	j	6b6 <vprintf+0x5a>
          s = "(null)";
 8c2:	00000917          	auipc	s2,0x0
 8c6:	22690913          	addi	s2,s2,550 # ae8 <malloc+0x116>
        for(; *s; s++)
 8ca:	02800593          	li	a1,40
 8ce:	b7c5                	j	8ae <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8d0:	8bce                	mv	s7,s3
      state = 0;
 8d2:	4981                	li	s3,0
 8d4:	b3cd                	j	6b6 <vprintf+0x5a>
    }
  }
}
 8d6:	70e6                	ld	ra,120(sp)
 8d8:	7446                	ld	s0,112(sp)
 8da:	74a6                	ld	s1,104(sp)
 8dc:	7906                	ld	s2,96(sp)
 8de:	69e6                	ld	s3,88(sp)
 8e0:	6a46                	ld	s4,80(sp)
 8e2:	6aa6                	ld	s5,72(sp)
 8e4:	6b06                	ld	s6,64(sp)
 8e6:	7be2                	ld	s7,56(sp)
 8e8:	7c42                	ld	s8,48(sp)
 8ea:	7ca2                	ld	s9,40(sp)
 8ec:	7d02                	ld	s10,32(sp)
 8ee:	6de2                	ld	s11,24(sp)
 8f0:	6109                	addi	sp,sp,128
 8f2:	8082                	ret

00000000000008f4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8f4:	715d                	addi	sp,sp,-80
 8f6:	ec06                	sd	ra,24(sp)
 8f8:	e822                	sd	s0,16(sp)
 8fa:	1000                	addi	s0,sp,32
 8fc:	e010                	sd	a2,0(s0)
 8fe:	e414                	sd	a3,8(s0)
 900:	e818                	sd	a4,16(s0)
 902:	ec1c                	sd	a5,24(s0)
 904:	03043023          	sd	a6,32(s0)
 908:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 90c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 910:	8622                	mv	a2,s0
 912:	d4bff0ef          	jal	ra,65c <vprintf>
}
 916:	60e2                	ld	ra,24(sp)
 918:	6442                	ld	s0,16(sp)
 91a:	6161                	addi	sp,sp,80
 91c:	8082                	ret

000000000000091e <printf>:

void
printf(const char *fmt, ...)
{
 91e:	711d                	addi	sp,sp,-96
 920:	ec06                	sd	ra,24(sp)
 922:	e822                	sd	s0,16(sp)
 924:	1000                	addi	s0,sp,32
 926:	e40c                	sd	a1,8(s0)
 928:	e810                	sd	a2,16(s0)
 92a:	ec14                	sd	a3,24(s0)
 92c:	f018                	sd	a4,32(s0)
 92e:	f41c                	sd	a5,40(s0)
 930:	03043823          	sd	a6,48(s0)
 934:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 938:	00840613          	addi	a2,s0,8
 93c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 940:	85aa                	mv	a1,a0
 942:	4505                	li	a0,1
 944:	d19ff0ef          	jal	ra,65c <vprintf>
}
 948:	60e2                	ld	ra,24(sp)
 94a:	6442                	ld	s0,16(sp)
 94c:	6125                	addi	sp,sp,96
 94e:	8082                	ret

0000000000000950 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 950:	1141                	addi	sp,sp,-16
 952:	e422                	sd	s0,8(sp)
 954:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 956:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95a:	00000797          	auipc	a5,0x0
 95e:	6a67b783          	ld	a5,1702(a5) # 1000 <freep>
 962:	a02d                	j	98c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 964:	4618                	lw	a4,8(a2)
 966:	9f2d                	addw	a4,a4,a1
 968:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 96c:	6398                	ld	a4,0(a5)
 96e:	6310                	ld	a2,0(a4)
 970:	a83d                	j	9ae <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 972:	ff852703          	lw	a4,-8(a0)
 976:	9f31                	addw	a4,a4,a2
 978:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 97a:	ff053683          	ld	a3,-16(a0)
 97e:	a091                	j	9c2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 980:	6398                	ld	a4,0(a5)
 982:	00e7e463          	bltu	a5,a4,98a <free+0x3a>
 986:	00e6ea63          	bltu	a3,a4,99a <free+0x4a>
{
 98a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 98c:	fed7fae3          	bgeu	a5,a3,980 <free+0x30>
 990:	6398                	ld	a4,0(a5)
 992:	00e6e463          	bltu	a3,a4,99a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 996:	fee7eae3          	bltu	a5,a4,98a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 99a:	ff852583          	lw	a1,-8(a0)
 99e:	6390                	ld	a2,0(a5)
 9a0:	02059813          	slli	a6,a1,0x20
 9a4:	01c85713          	srli	a4,a6,0x1c
 9a8:	9736                	add	a4,a4,a3
 9aa:	fae60de3          	beq	a2,a4,964 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9ae:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9b2:	4790                	lw	a2,8(a5)
 9b4:	02061593          	slli	a1,a2,0x20
 9b8:	01c5d713          	srli	a4,a1,0x1c
 9bc:	973e                	add	a4,a4,a5
 9be:	fae68ae3          	beq	a3,a4,972 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9c2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9c4:	00000717          	auipc	a4,0x0
 9c8:	62f73e23          	sd	a5,1596(a4) # 1000 <freep>
}
 9cc:	6422                	ld	s0,8(sp)
 9ce:	0141                	addi	sp,sp,16
 9d0:	8082                	ret

00000000000009d2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9d2:	7139                	addi	sp,sp,-64
 9d4:	fc06                	sd	ra,56(sp)
 9d6:	f822                	sd	s0,48(sp)
 9d8:	f426                	sd	s1,40(sp)
 9da:	f04a                	sd	s2,32(sp)
 9dc:	ec4e                	sd	s3,24(sp)
 9de:	e852                	sd	s4,16(sp)
 9e0:	e456                	sd	s5,8(sp)
 9e2:	e05a                	sd	s6,0(sp)
 9e4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e6:	02051493          	slli	s1,a0,0x20
 9ea:	9081                	srli	s1,s1,0x20
 9ec:	04bd                	addi	s1,s1,15
 9ee:	8091                	srli	s1,s1,0x4
 9f0:	0014899b          	addiw	s3,s1,1
 9f4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9f6:	00000517          	auipc	a0,0x0
 9fa:	60a53503          	ld	a0,1546(a0) # 1000 <freep>
 9fe:	c515                	beqz	a0,a2a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a00:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a02:	4798                	lw	a4,8(a5)
 a04:	02977f63          	bgeu	a4,s1,a42 <malloc+0x70>
 a08:	8a4e                	mv	s4,s3
 a0a:	0009871b          	sext.w	a4,s3
 a0e:	6685                	lui	a3,0x1
 a10:	00d77363          	bgeu	a4,a3,a16 <malloc+0x44>
 a14:	6a05                	lui	s4,0x1
 a16:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a1a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a1e:	00000917          	auipc	s2,0x0
 a22:	5e290913          	addi	s2,s2,1506 # 1000 <freep>
  if(p == SBRK_ERROR)
 a26:	5afd                	li	s5,-1
 a28:	a885                	j	a98 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 a2a:	00001797          	auipc	a5,0x1
 a2e:	9e678793          	addi	a5,a5,-1562 # 1410 <base>
 a32:	00000717          	auipc	a4,0x0
 a36:	5cf73723          	sd	a5,1486(a4) # 1000 <freep>
 a3a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a3c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a40:	b7e1                	j	a08 <malloc+0x36>
      if(p->s.size == nunits)
 a42:	02e48c63          	beq	s1,a4,a7a <malloc+0xa8>
        p->s.size -= nunits;
 a46:	4137073b          	subw	a4,a4,s3
 a4a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a4c:	02071693          	slli	a3,a4,0x20
 a50:	01c6d713          	srli	a4,a3,0x1c
 a54:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a56:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a5a:	00000717          	auipc	a4,0x0
 a5e:	5aa73323          	sd	a0,1446(a4) # 1000 <freep>
      return (void*)(p + 1);
 a62:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a66:	70e2                	ld	ra,56(sp)
 a68:	7442                	ld	s0,48(sp)
 a6a:	74a2                	ld	s1,40(sp)
 a6c:	7902                	ld	s2,32(sp)
 a6e:	69e2                	ld	s3,24(sp)
 a70:	6a42                	ld	s4,16(sp)
 a72:	6aa2                	ld	s5,8(sp)
 a74:	6b02                	ld	s6,0(sp)
 a76:	6121                	addi	sp,sp,64
 a78:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a7a:	6398                	ld	a4,0(a5)
 a7c:	e118                	sd	a4,0(a0)
 a7e:	bff1                	j	a5a <malloc+0x88>
  hp->s.size = nu;
 a80:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a84:	0541                	addi	a0,a0,16
 a86:	ecbff0ef          	jal	ra,950 <free>
  return freep;
 a8a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a8e:	dd61                	beqz	a0,a66 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a90:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a92:	4798                	lw	a4,8(a5)
 a94:	fa9777e3          	bgeu	a4,s1,a42 <malloc+0x70>
    if(p == freep)
 a98:	00093703          	ld	a4,0(s2)
 a9c:	853e                	mv	a0,a5
 a9e:	fef719e3          	bne	a4,a5,a90 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 aa2:	8552                	mv	a0,s4
 aa4:	a0bff0ef          	jal	ra,4ae <sbrk>
  if(p == SBRK_ERROR)
 aa8:	fd551ce3          	bne	a0,s5,a80 <malloc+0xae>
        return 0;
 aac:	4501                	li	a0,0
 aae:	bf65                	j	a66 <malloc+0x94>
