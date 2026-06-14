
user/_wc:     file format elf64-littleriscv


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
  3c:	9b8a0a13          	addi	s4,s4,-1608 # 9f0 <malloc+0xe2>
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
  7e:	392000ef          	jal	ra,410 <read>
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
  b2:	95a50513          	addi	a0,a0,-1702 # a08 <malloc+0xfa>
  b6:	79e000ef          	jal	ra,854 <printf>
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
  dc:	92050513          	addi	a0,a0,-1760 # 9f8 <malloc+0xea>
  e0:	774000ef          	jal	ra,854 <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	312000ef          	jal	ra,3f8 <exit>

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
 108:	1982                	slli	s3,s3,0x20
 10a:	0209d993          	srli	s3,s3,0x20
 10e:	098e                	slli	s3,s3,0x3
 110:	05c1                	addi	a1,a1,16
 112:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 114:	4581                	li	a1,0
 116:	6088                	ld	a0,0(s1)
 118:	320000ef          	jal	ra,438 <open>
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
 12a:	2f6000ef          	jal	ra,420 <close>
  for(i = 1; i < argc; i++){
 12e:	04a1                	addi	s1,s1,8
 130:	ff3492e3          	bne	s1,s3,114 <main+0x2a>
  }
  exit(0);
 134:	4501                	li	a0,0
 136:	2c2000ef          	jal	ra,3f8 <exit>
    wc(0, "");
 13a:	00001597          	auipc	a1,0x1
 13e:	8de58593          	addi	a1,a1,-1826 # a18 <malloc+0x10a>
 142:	4501                	li	a0,0
 144:	ebdff0ef          	jal	ra,0 <wc>
    exit(0);
 148:	4501                	li	a0,0
 14a:	2ae000ef          	jal	ra,3f8 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 14e:	608c                	ld	a1,0(s1)
 150:	00001517          	auipc	a0,0x1
 154:	8d050513          	addi	a0,a0,-1840 # a20 <malloc+0x112>
 158:	6fc000ef          	jal	ra,854 <printf>
      exit(1);
 15c:	4505                	li	a0,1
 15e:	29a000ef          	jal	ra,3f8 <exit>

0000000000000162 <start>:
 *   argv - 命令行参数数组
 */

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
 16e:	28a000ef          	jal	ra,3f8 <exit>

0000000000000172 <strcpy>:
 *   目标字符串s的指针
 */

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
 *   负数 - p小于q
 */

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
 *   字符串s的长度
 */

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
 *   目标内存区域dst的指针
 */

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
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

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
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

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
 25c:	1b4000ef          	jal	ra,410 <read>
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
 *   -1 - 失败
 */

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
 2aa:	18e000ef          	jal	ra,438 <open>
  if(fd < 0)
 2ae:	02054163          	bltz	a0,2d0 <stat+0x36>
 2b2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b4:	85ca                	mv	a1,s2
 2b6:	19a000ef          	jal	ra,450 <fstat>
 2ba:	892a                	mv	s2,a0
  close(fd);
 2bc:	8526                	mv	a0,s1
 2be:	162000ef          	jal	ra,420 <close>
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
 *   转换后的整数
 */

int
atoi(const char *s)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2da:	00054603          	lbu	a2,0(a0)
 2de:	fd06079b          	addiw	a5,a2,-48
 2e2:	0ff7f793          	andi	a5,a5,255
 2e6:	4725                	li	a4,9
 2e8:	02f76963          	bltu	a4,a5,31a <atoi+0x46>
 2ec:	86aa                	mv	a3,a0
  n = 0;
 2ee:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2f0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2f2:	0685                	addi	a3,a3,1
 2f4:	0025179b          	slliw	a5,a0,0x2
 2f8:	9fa9                	addw	a5,a5,a0
 2fa:	0017979b          	slliw	a5,a5,0x1
 2fe:	9fb1                	addw	a5,a5,a2
 300:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 304:	0006c603          	lbu	a2,0(a3)
 308:	fd06071b          	addiw	a4,a2,-48
 30c:	0ff77713          	andi	a4,a4,255
 310:	fee5f1e3          	bgeu	a1,a4,2f2 <atoi+0x1e>
  return n;
}
 314:	6422                	ld	s0,8(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret
  n = 0;
 31a:	4501                	li	a0,0
 31c:	bfe5                	j	314 <atoi+0x40>

000000000000031e <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 324:	02b57463          	bgeu	a0,a1,34c <memmove+0x2e>
    while(n-- > 0)
 328:	00c05f63          	blez	a2,346 <memmove+0x28>
 32c:	1602                	slli	a2,a2,0x20
 32e:	9201                	srli	a2,a2,0x20
 330:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 334:	872a                	mv	a4,a0
      *dst++ = *src++;
 336:	0585                	addi	a1,a1,1
 338:	0705                	addi	a4,a4,1
 33a:	fff5c683          	lbu	a3,-1(a1)
 33e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 342:	fee79ae3          	bne	a5,a4,336 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
    dst += n;
 34c:	00c50733          	add	a4,a0,a2
    src += n;
 350:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 352:	fec05ae3          	blez	a2,346 <memmove+0x28>
 356:	fff6079b          	addiw	a5,a2,-1
 35a:	1782                	slli	a5,a5,0x20
 35c:	9381                	srli	a5,a5,0x20
 35e:	fff7c793          	not	a5,a5
 362:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 364:	15fd                	addi	a1,a1,-1
 366:	177d                	addi	a4,a4,-1
 368:	0005c683          	lbu	a3,0(a1)
 36c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 370:	fee79ae3          	bne	a5,a4,364 <memmove+0x46>
 374:	bfc9                	j	346 <memmove+0x28>

0000000000000376 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 37c:	ca05                	beqz	a2,3ac <memcmp+0x36>
 37e:	fff6069b          	addiw	a3,a2,-1
 382:	1682                	slli	a3,a3,0x20
 384:	9281                	srli	a3,a3,0x20
 386:	0685                	addi	a3,a3,1
 388:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 38a:	00054783          	lbu	a5,0(a0)
 38e:	0005c703          	lbu	a4,0(a1)
 392:	00e79863          	bne	a5,a4,3a2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 396:	0505                	addi	a0,a0,1
    p2++;
 398:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39a:	fed518e3          	bne	a0,a3,38a <memcmp+0x14>
  }
  return 0;
 39e:	4501                	li	a0,0
 3a0:	a019                	j	3a6 <memcmp+0x30>
      return *p1 - *p2;
 3a2:	40e7853b          	subw	a0,a5,a4
}
 3a6:	6422                	ld	s0,8(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
  return 0;
 3ac:	4501                	li	a0,0
 3ae:	bfe5                	j	3a6 <memcmp+0x30>

00000000000003b0 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e406                	sd	ra,8(sp)
 3b4:	e022                	sd	s0,0(sp)
 3b6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b8:	f67ff0ef          	jal	ra,31e <memmove>
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e406                	sd	ra,8(sp)
 3c8:	e022                	sd	s0,0(sp)
 3ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3cc:	4585                	li	a1,1
 3ce:	0b2000ef          	jal	ra,480 <sys_sbrk>
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 3da:	1141                	addi	sp,sp,-16
 3dc:	e406                	sd	ra,8(sp)
 3de:	e022                	sd	s0,0(sp)
 3e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3e2:	4589                	li	a1,2
 3e4:	09c000ef          	jal	ra,480 <sys_sbrk>
}
 3e8:	60a2                	ld	ra,8(sp)
 3ea:	6402                	ld	s0,0(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret

00000000000003f0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f0:	4885                	li	a7,1
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f8:	4889                	li	a7,2
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <wait>:
.global wait
wait:
 li a7, SYS_wait
 400:	488d                	li	a7,3
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 408:	4891                	li	a7,4
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <read>:
.global read
read:
 li a7, SYS_read
 410:	4895                	li	a7,5
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <write>:
.global write
write:
 li a7, SYS_write
 418:	48c1                	li	a7,16
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <close>:
.global close
close:
 li a7, SYS_close
 420:	48d5                	li	a7,21
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <kill>:
.global kill
kill:
 li a7, SYS_kill
 428:	4899                	li	a7,6
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <exec>:
.global exec
exec:
 li a7, SYS_exec
 430:	489d                	li	a7,7
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <open>:
.global open
open:
 li a7, SYS_open
 438:	48bd                	li	a7,15
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 440:	48c5                	li	a7,17
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 448:	48c9                	li	a7,18
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 450:	48a1                	li	a7,8
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <link>:
.global link
link:
 li a7, SYS_link
 458:	48cd                	li	a7,19
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 460:	48d1                	li	a7,20
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 468:	48a5                	li	a7,9
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <dup>:
.global dup
dup:
 li a7, SYS_dup
 470:	48a9                	li	a7,10
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 478:	48ad                	li	a7,11
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 480:	48b1                	li	a7,12
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <pause>:
.global pause
pause:
 li a7, SYS_pause
 488:	48b5                	li	a7,13
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 490:	48b9                	li	a7,14
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 498:	48d9                	li	a7,22
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 4a0:	48dd                	li	a7,23
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 4a8:	48e1                	li	a7,24
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4b0:	48e5                	li	a7,25
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 4b8:	48e9                	li	a7,26
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 4c0:	48ed                	li	a7,27
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 4c8:	48f1                	li	a7,28
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 4d0:	48f5                	li	a7,29
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 4d8:	1101                	addi	sp,sp,-32
 4da:	ec06                	sd	ra,24(sp)
 4dc:	e822                	sd	s0,16(sp)
 4de:	1000                	addi	s0,sp,32
 4e0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e4:	4605                	li	a2,1
 4e6:	fef40593          	addi	a1,s0,-17
 4ea:	f2fff0ef          	jal	ra,418 <write>
}
 4ee:	60e2                	ld	ra,24(sp)
 4f0:	6442                	ld	s0,16(sp)
 4f2:	6105                	addi	sp,sp,32
 4f4:	8082                	ret

00000000000004f6 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 4f6:	715d                	addi	sp,sp,-80
 4f8:	e486                	sd	ra,72(sp)
 4fa:	e0a2                	sd	s0,64(sp)
 4fc:	fc26                	sd	s1,56(sp)
 4fe:	f84a                	sd	s2,48(sp)
 500:	f44e                	sd	s3,40(sp)
 502:	0880                	addi	s0,sp,80
 504:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 506:	c299                	beqz	a3,50c <printint+0x16>
 508:	0805c163          	bltz	a1,58a <printint+0x94>
  neg = 0;
 50c:	4881                	li	a7,0
 50e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 512:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 514:	00000517          	auipc	a0,0x0
 518:	52c50513          	addi	a0,a0,1324 # a40 <digits>
 51c:	883e                	mv	a6,a5
 51e:	2785                	addiw	a5,a5,1
 520:	02c5f733          	remu	a4,a1,a2
 524:	972a                	add	a4,a4,a0
 526:	00074703          	lbu	a4,0(a4)
 52a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 52e:	872e                	mv	a4,a1
 530:	02c5d5b3          	divu	a1,a1,a2
 534:	0685                	addi	a3,a3,1
 536:	fec773e3          	bgeu	a4,a2,51c <printint+0x26>
  if(neg)
 53a:	00088b63          	beqz	a7,550 <printint+0x5a>
    buf[i++] = '-';
 53e:	fd040713          	addi	a4,s0,-48
 542:	97ba                	add	a5,a5,a4
 544:	02d00713          	li	a4,45
 548:	fee78423          	sb	a4,-24(a5)
 54c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 550:	02f05663          	blez	a5,57c <printint+0x86>
 554:	fb840713          	addi	a4,s0,-72
 558:	00f704b3          	add	s1,a4,a5
 55c:	fff70993          	addi	s3,a4,-1
 560:	99be                	add	s3,s3,a5
 562:	37fd                	addiw	a5,a5,-1
 564:	1782                	slli	a5,a5,0x20
 566:	9381                	srli	a5,a5,0x20
 568:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 56c:	fff4c583          	lbu	a1,-1(s1)
 570:	854a                	mv	a0,s2
 572:	f67ff0ef          	jal	ra,4d8 <putc>
  while(--i >= 0)
 576:	14fd                	addi	s1,s1,-1
 578:	ff349ae3          	bne	s1,s3,56c <printint+0x76>
}
 57c:	60a6                	ld	ra,72(sp)
 57e:	6406                	ld	s0,64(sp)
 580:	74e2                	ld	s1,56(sp)
 582:	7942                	ld	s2,48(sp)
 584:	79a2                	ld	s3,40(sp)
 586:	6161                	addi	sp,sp,80
 588:	8082                	ret
    x = -xx;
 58a:	40b005b3          	neg	a1,a1
    neg = 1;
 58e:	4885                	li	a7,1
    x = -xx;
 590:	bfbd                	j	50e <printint+0x18>

0000000000000592 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 592:	7119                	addi	sp,sp,-128
 594:	fc86                	sd	ra,120(sp)
 596:	f8a2                	sd	s0,112(sp)
 598:	f4a6                	sd	s1,104(sp)
 59a:	f0ca                	sd	s2,96(sp)
 59c:	ecce                	sd	s3,88(sp)
 59e:	e8d2                	sd	s4,80(sp)
 5a0:	e4d6                	sd	s5,72(sp)
 5a2:	e0da                	sd	s6,64(sp)
 5a4:	fc5e                	sd	s7,56(sp)
 5a6:	f862                	sd	s8,48(sp)
 5a8:	f466                	sd	s9,40(sp)
 5aa:	f06a                	sd	s10,32(sp)
 5ac:	ec6e                	sd	s11,24(sp)
 5ae:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b0:	0005c903          	lbu	s2,0(a1)
 5b4:	24090c63          	beqz	s2,80c <vprintf+0x27a>
 5b8:	8b2a                	mv	s6,a0
 5ba:	8a2e                	mv	s4,a1
 5bc:	8bb2                	mv	s7,a2
  state = 0;
 5be:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c0:	4481                	li	s1,0
 5c2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5c4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5c8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5cc:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5d0:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d4:	00000c97          	auipc	s9,0x0
 5d8:	46cc8c93          	addi	s9,s9,1132 # a40 <digits>
 5dc:	a005                	j	5fc <vprintf+0x6a>
        putc(fd, c0);
 5de:	85ca                	mv	a1,s2
 5e0:	855a                	mv	a0,s6
 5e2:	ef7ff0ef          	jal	ra,4d8 <putc>
 5e6:	a019                	j	5ec <vprintf+0x5a>
    } else if(state == '%'){
 5e8:	03598263          	beq	s3,s5,60c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ec:	2485                	addiw	s1,s1,1
 5ee:	8726                	mv	a4,s1
 5f0:	009a07b3          	add	a5,s4,s1
 5f4:	0007c903          	lbu	s2,0(a5)
 5f8:	20090a63          	beqz	s2,80c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5fc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 600:	fe0994e3          	bnez	s3,5e8 <vprintf+0x56>
      if(c0 == '%'){
 604:	fd579de3          	bne	a5,s5,5de <vprintf+0x4c>
        state = '%';
 608:	89be                	mv	s3,a5
 60a:	b7cd                	j	5ec <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 60c:	c3c1                	beqz	a5,68c <vprintf+0xfa>
 60e:	00ea06b3          	add	a3,s4,a4
 612:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 616:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 618:	c681                	beqz	a3,620 <vprintf+0x8e>
 61a:	9752                	add	a4,a4,s4
 61c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 620:	03878e63          	beq	a5,s8,65c <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 624:	05a78863          	beq	a5,s10,674 <vprintf+0xe2>
      } else if(c0 == 'u'){
 628:	0db78b63          	beq	a5,s11,6fe <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 62c:	07800713          	li	a4,120
 630:	10e78d63          	beq	a5,a4,74a <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 634:	07000713          	li	a4,112
 638:	14e78263          	beq	a5,a4,77c <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 63c:	06300713          	li	a4,99
 640:	16e78f63          	beq	a5,a4,7be <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 644:	07300713          	li	a4,115
 648:	18e78563          	beq	a5,a4,7d2 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 64c:	05579063          	bne	a5,s5,68c <vprintf+0xfa>
        putc(fd, '%');
 650:	85d6                	mv	a1,s5
 652:	855a                	mv	a0,s6
 654:	e85ff0ef          	jal	ra,4d8 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 658:	4981                	li	s3,0
 65a:	bf49                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 65c:	008b8913          	addi	s2,s7,8
 660:	4685                	li	a3,1
 662:	4629                	li	a2,10
 664:	000ba583          	lw	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	e8dff0ef          	jal	ra,4f6 <printint>
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	bfad                	j	5ec <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 674:	03868663          	beq	a3,s8,6a0 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 678:	05a68163          	beq	a3,s10,6ba <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 67c:	09b68d63          	beq	a3,s11,716 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 680:	03a68f63          	beq	a3,s10,6be <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 684:	07800793          	li	a5,120
 688:	0cf68d63          	beq	a3,a5,762 <vprintf+0x1d0>
        putc(fd, '%');
 68c:	85d6                	mv	a1,s5
 68e:	855a                	mv	a0,s6
 690:	e49ff0ef          	jal	ra,4d8 <putc>
        putc(fd, c0);
 694:	85ca                	mv	a1,s2
 696:	855a                	mv	a0,s6
 698:	e41ff0ef          	jal	ra,4d8 <putc>
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b7b9                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4685                	li	a3,1
 6a6:	4629                	li	a2,10
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	e49ff0ef          	jal	ra,4f6 <printint>
        i += 1;
 6b2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 1;
 6b8:	bf15                	j	5ec <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ba:	03860563          	beq	a2,s8,6e4 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6be:	07b60963          	beq	a2,s11,730 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6c2:	07800793          	li	a5,120
 6c6:	fcf613e3          	bne	a2,a5,68c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ca:	008b8913          	addi	s2,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4641                	li	a2,16
 6d2:	000bb583          	ld	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	e1fff0ef          	jal	ra,4f6 <printint>
        i += 2;
 6dc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6de:	8bca                	mv	s7,s2
      state = 0;
 6e0:	4981                	li	s3,0
        i += 2;
 6e2:	b729                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e4:	008b8913          	addi	s2,s7,8
 6e8:	4685                	li	a3,1
 6ea:	4629                	li	a2,10
 6ec:	000bb583          	ld	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	e05ff0ef          	jal	ra,4f6 <printint>
        i += 2;
 6f6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f8:	8bca                	mv	s7,s2
      state = 0;
 6fa:	4981                	li	s3,0
        i += 2;
 6fc:	bdc5                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6fe:	008b8913          	addi	s2,s7,8
 702:	4681                	li	a3,0
 704:	4629                	li	a2,10
 706:	000be583          	lwu	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	debff0ef          	jal	ra,4f6 <printint>
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	bde1                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 716:	008b8913          	addi	s2,s7,8
 71a:	4681                	li	a3,0
 71c:	4629                	li	a2,10
 71e:	000bb583          	ld	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	dd3ff0ef          	jal	ra,4f6 <printint>
        i += 1;
 728:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 72a:	8bca                	mv	s7,s2
      state = 0;
 72c:	4981                	li	s3,0
        i += 1;
 72e:	bd7d                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 730:	008b8913          	addi	s2,s7,8
 734:	4681                	li	a3,0
 736:	4629                	li	a2,10
 738:	000bb583          	ld	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	db9ff0ef          	jal	ra,4f6 <printint>
        i += 2;
 742:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 744:	8bca                	mv	s7,s2
      state = 0;
 746:	4981                	li	s3,0
        i += 2;
 748:	b555                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 74a:	008b8913          	addi	s2,s7,8
 74e:	4681                	li	a3,0
 750:	4641                	li	a2,16
 752:	000be583          	lwu	a1,0(s7)
 756:	855a                	mv	a0,s6
 758:	d9fff0ef          	jal	ra,4f6 <printint>
 75c:	8bca                	mv	s7,s2
      state = 0;
 75e:	4981                	li	s3,0
 760:	b571                	j	5ec <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 762:	008b8913          	addi	s2,s7,8
 766:	4681                	li	a3,0
 768:	4641                	li	a2,16
 76a:	000bb583          	ld	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	d87ff0ef          	jal	ra,4f6 <printint>
        i += 1;
 774:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 776:	8bca                	mv	s7,s2
      state = 0;
 778:	4981                	li	s3,0
        i += 1;
 77a:	bd8d                	j	5ec <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 77c:	008b8793          	addi	a5,s7,8
 780:	f8f43423          	sd	a5,-120(s0)
 784:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 788:	03000593          	li	a1,48
 78c:	855a                	mv	a0,s6
 78e:	d4bff0ef          	jal	ra,4d8 <putc>
  putc(fd, 'x');
 792:	07800593          	li	a1,120
 796:	855a                	mv	a0,s6
 798:	d41ff0ef          	jal	ra,4d8 <putc>
 79c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79e:	03c9d793          	srli	a5,s3,0x3c
 7a2:	97e6                	add	a5,a5,s9
 7a4:	0007c583          	lbu	a1,0(a5)
 7a8:	855a                	mv	a0,s6
 7aa:	d2fff0ef          	jal	ra,4d8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ae:	0992                	slli	s3,s3,0x4
 7b0:	397d                	addiw	s2,s2,-1
 7b2:	fe0916e3          	bnez	s2,79e <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7b6:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	bd05                	j	5ec <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7be:	008b8913          	addi	s2,s7,8
 7c2:	000bc583          	lbu	a1,0(s7)
 7c6:	855a                	mv	a0,s6
 7c8:	d11ff0ef          	jal	ra,4d8 <putc>
 7cc:	8bca                	mv	s7,s2
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	bd31                	j	5ec <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7d2:	008b8993          	addi	s3,s7,8
 7d6:	000bb903          	ld	s2,0(s7)
 7da:	00090f63          	beqz	s2,7f8 <vprintf+0x266>
        for(; *s; s++)
 7de:	00094583          	lbu	a1,0(s2)
 7e2:	c195                	beqz	a1,806 <vprintf+0x274>
          putc(fd, *s);
 7e4:	855a                	mv	a0,s6
 7e6:	cf3ff0ef          	jal	ra,4d8 <putc>
        for(; *s; s++)
 7ea:	0905                	addi	s2,s2,1
 7ec:	00094583          	lbu	a1,0(s2)
 7f0:	f9f5                	bnez	a1,7e4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7f2:	8bce                	mv	s7,s3
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	bbdd                	j	5ec <vprintf+0x5a>
          s = "(null)";
 7f8:	00000917          	auipc	s2,0x0
 7fc:	24090913          	addi	s2,s2,576 # a38 <malloc+0x12a>
        for(; *s; s++)
 800:	02800593          	li	a1,40
 804:	b7c5                	j	7e4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 806:	8bce                	mv	s7,s3
      state = 0;
 808:	4981                	li	s3,0
 80a:	b3cd                	j	5ec <vprintf+0x5a>
    }
  }
}
 80c:	70e6                	ld	ra,120(sp)
 80e:	7446                	ld	s0,112(sp)
 810:	74a6                	ld	s1,104(sp)
 812:	7906                	ld	s2,96(sp)
 814:	69e6                	ld	s3,88(sp)
 816:	6a46                	ld	s4,80(sp)
 818:	6aa6                	ld	s5,72(sp)
 81a:	6b06                	ld	s6,64(sp)
 81c:	7be2                	ld	s7,56(sp)
 81e:	7c42                	ld	s8,48(sp)
 820:	7ca2                	ld	s9,40(sp)
 822:	7d02                	ld	s10,32(sp)
 824:	6de2                	ld	s11,24(sp)
 826:	6109                	addi	sp,sp,128
 828:	8082                	ret

000000000000082a <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 82a:	715d                	addi	sp,sp,-80
 82c:	ec06                	sd	ra,24(sp)
 82e:	e822                	sd	s0,16(sp)
 830:	1000                	addi	s0,sp,32
 832:	e010                	sd	a2,0(s0)
 834:	e414                	sd	a3,8(s0)
 836:	e818                	sd	a4,16(s0)
 838:	ec1c                	sd	a5,24(s0)
 83a:	03043023          	sd	a6,32(s0)
 83e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 842:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 846:	8622                	mv	a2,s0
 848:	d4bff0ef          	jal	ra,592 <vprintf>
}
 84c:	60e2                	ld	ra,24(sp)
 84e:	6442                	ld	s0,16(sp)
 850:	6161                	addi	sp,sp,80
 852:	8082                	ret

0000000000000854 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 854:	711d                	addi	sp,sp,-96
 856:	ec06                	sd	ra,24(sp)
 858:	e822                	sd	s0,16(sp)
 85a:	1000                	addi	s0,sp,32
 85c:	e40c                	sd	a1,8(s0)
 85e:	e810                	sd	a2,16(s0)
 860:	ec14                	sd	a3,24(s0)
 862:	f018                	sd	a4,32(s0)
 864:	f41c                	sd	a5,40(s0)
 866:	03043823          	sd	a6,48(s0)
 86a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 86e:	00840613          	addi	a2,s0,8
 872:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 876:	85aa                	mv	a1,a0
 878:	4505                	li	a0,1
 87a:	d19ff0ef          	jal	ra,592 <vprintf>
}
 87e:	60e2                	ld	ra,24(sp)
 880:	6442                	ld	s0,16(sp)
 882:	6125                	addi	sp,sp,96
 884:	8082                	ret

0000000000000886 <free>:
 *   无
 */

void
free(void *ap)
{
 886:	1141                	addi	sp,sp,-16
 888:	e422                	sd	s0,8(sp)
 88a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 88c:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 890:	00000797          	auipc	a5,0x0
 894:	7707b783          	ld	a5,1904(a5) # 1000 <freep>
 898:	a805                	j	8c8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 89a:	4618                	lw	a4,8(a2)
 89c:	9db9                	addw	a1,a1,a4
 89e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a2:	6398                	ld	a4,0(a5)
 8a4:	6318                	ld	a4,0(a4)
 8a6:	fee53823          	sd	a4,-16(a0)
 8aa:	a091                	j	8ee <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ac:	ff852703          	lw	a4,-8(a0)
 8b0:	9e39                	addw	a2,a2,a4
 8b2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8b4:	ff053703          	ld	a4,-16(a0)
 8b8:	e398                	sd	a4,0(a5)
 8ba:	a099                	j	900 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8bc:	6398                	ld	a4,0(a5)
 8be:	00e7e463          	bltu	a5,a4,8c6 <free+0x40>
 8c2:	00e6ea63          	bltu	a3,a4,8d6 <free+0x50>
{
 8c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c8:	fed7fae3          	bgeu	a5,a3,8bc <free+0x36>
 8cc:	6398                	ld	a4,0(a5)
 8ce:	00e6e463          	bltu	a3,a4,8d6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d2:	fee7eae3          	bltu	a5,a4,8c6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8d6:	ff852583          	lw	a1,-8(a0)
 8da:	6390                	ld	a2,0(a5)
 8dc:	02059713          	slli	a4,a1,0x20
 8e0:	9301                	srli	a4,a4,0x20
 8e2:	0712                	slli	a4,a4,0x4
 8e4:	9736                	add	a4,a4,a3
 8e6:	fae60ae3          	beq	a2,a4,89a <free+0x14>
    bp->s.ptr = p->s.ptr;
 8ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ee:	4790                	lw	a2,8(a5)
 8f0:	02061713          	slli	a4,a2,0x20
 8f4:	9301                	srli	a4,a4,0x20
 8f6:	0712                	slli	a4,a4,0x4
 8f8:	973e                	add	a4,a4,a5
 8fa:	fae689e3          	beq	a3,a4,8ac <free+0x26>
  } else
    p->s.ptr = bp;
 8fe:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 900:	00000717          	auipc	a4,0x0
 904:	70f73023          	sd	a5,1792(a4) # 1000 <freep>
}
 908:	6422                	ld	s0,8(sp)
 90a:	0141                	addi	sp,sp,16
 90c:	8082                	ret

000000000000090e <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 90e:	7139                	addi	sp,sp,-64
 910:	fc06                	sd	ra,56(sp)
 912:	f822                	sd	s0,48(sp)
 914:	f426                	sd	s1,40(sp)
 916:	f04a                	sd	s2,32(sp)
 918:	ec4e                	sd	s3,24(sp)
 91a:	e852                	sd	s4,16(sp)
 91c:	e456                	sd	s5,8(sp)
 91e:	e05a                	sd	s6,0(sp)
 920:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 922:	02051493          	slli	s1,a0,0x20
 926:	9081                	srli	s1,s1,0x20
 928:	04bd                	addi	s1,s1,15
 92a:	8091                	srli	s1,s1,0x4
 92c:	0014899b          	addiw	s3,s1,1
 930:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 932:	00000517          	auipc	a0,0x0
 936:	6ce53503          	ld	a0,1742(a0) # 1000 <freep>
 93a:	c515                	beqz	a0,966 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 93e:	4798                	lw	a4,8(a5)
 940:	02977f63          	bgeu	a4,s1,97e <malloc+0x70>
 944:	8a4e                	mv	s4,s3
 946:	0009871b          	sext.w	a4,s3
 94a:	6685                	lui	a3,0x1
 94c:	00d77363          	bgeu	a4,a3,952 <malloc+0x44>
 950:	6a05                	lui	s4,0x1
 952:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 956:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 95a:	00000917          	auipc	s2,0x0
 95e:	6a690913          	addi	s2,s2,1702 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 962:	5afd                	li	s5,-1
 964:	a0bd                	j	9d2 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 966:	00001797          	auipc	a5,0x1
 96a:	8aa78793          	addi	a5,a5,-1878 # 1210 <base>
 96e:	00000717          	auipc	a4,0x0
 972:	68f73923          	sd	a5,1682(a4) # 1000 <freep>
 976:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 978:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 97c:	b7e1                	j	944 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 97e:	02e48b63          	beq	s1,a4,9b4 <malloc+0xa6>
        p->s.size -= nunits;
 982:	4137073b          	subw	a4,a4,s3
 986:	c798                	sw	a4,8(a5)
        p += p->s.size;
 988:	1702                	slli	a4,a4,0x20
 98a:	9301                	srli	a4,a4,0x20
 98c:	0712                	slli	a4,a4,0x4
 98e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 990:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 994:	00000717          	auipc	a4,0x0
 998:	66a73623          	sd	a0,1644(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 99c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 9a0:	70e2                	ld	ra,56(sp)
 9a2:	7442                	ld	s0,48(sp)
 9a4:	74a2                	ld	s1,40(sp)
 9a6:	7902                	ld	s2,32(sp)
 9a8:	69e2                	ld	s3,24(sp)
 9aa:	6a42                	ld	s4,16(sp)
 9ac:	6aa2                	ld	s5,8(sp)
 9ae:	6b02                	ld	s6,0(sp)
 9b0:	6121                	addi	sp,sp,64
 9b2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9b4:	6398                	ld	a4,0(a5)
 9b6:	e118                	sd	a4,0(a0)
 9b8:	bff1                	j	994 <malloc+0x86>
  hp->s.size = nu;
 9ba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 9be:	0541                	addi	a0,a0,16
 9c0:	ec7ff0ef          	jal	ra,886 <free>
  return freep;
 9c4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9c8:	dd61                	beqz	a0,9a0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 9cc:	4798                	lw	a4,8(a5)
 9ce:	fa9778e3          	bgeu	a4,s1,97e <malloc+0x70>
    if(p == freep)
 9d2:	00093703          	ld	a4,0(s2)
 9d6:	853e                	mv	a0,a5
 9d8:	fef719e3          	bne	a4,a5,9ca <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 9dc:	8552                	mv	a0,s4
 9de:	9e7ff0ef          	jal	ra,3c4 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 9e2:	fd551ce3          	bne	a0,s5,9ba <malloc+0xac>
        return 0;  /* 内存分配失败 */
 9e6:	4501                	li	a0,0
 9e8:	bf65                	j	9a0 <malloc+0x92>
