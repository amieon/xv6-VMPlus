
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
  3c:	9b8a0a13          	addi	s4,s4,-1608 # 9f0 <malloc+0xea>
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
  b2:	95a50513          	addi	a0,a0,-1702 # a08 <malloc+0x102>
  b6:	79c000ef          	jal	ra,852 <printf>
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
  dc:	92050513          	addi	a0,a0,-1760 # 9f8 <malloc+0xf2>
  e0:	772000ef          	jal	ra,852 <printf>
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
 13e:	8de58593          	addi	a1,a1,-1826 # a18 <malloc+0x112>
 142:	4501                	li	a0,0
 144:	ebdff0ef          	jal	ra,0 <wc>
    exit(0);
 148:	4501                	li	a0,0
 14a:	2ac000ef          	jal	ra,3f6 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 14e:	608c                	ld	a1,0(s1)
 150:	00001517          	auipc	a0,0x1
 154:	8d050513          	addi	a0,a0,-1840 # a20 <malloc+0x11a>
 158:	6fa000ef          	jal	ra,852 <printf>
      exit(1);
 15c:	4505                	li	a0,1
 15e:	298000ef          	jal	ra,3f6 <exit>

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
 16e:	288000ef          	jal	ra,3f6 <exit>

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
 *   目标内存区域vdst的指针
 */

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
 *   负数 - s1小于s2
 */

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
 *   目标内存区域dst的指针
 */

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
 * 返回值：
 *   指向新分配内存的指针
 */

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
 * 返回值：
 *   指向新分配内存的指针
 */

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

00000000000004ce <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 4ce:	48f5                	li	a7,29
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 4d6:	1101                	addi	sp,sp,-32
 4d8:	ec06                	sd	ra,24(sp)
 4da:	e822                	sd	s0,16(sp)
 4dc:	1000                	addi	s0,sp,32
 4de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e2:	4605                	li	a2,1
 4e4:	fef40593          	addi	a1,s0,-17
 4e8:	f2fff0ef          	jal	ra,416 <write>
}
 4ec:	60e2                	ld	ra,24(sp)
 4ee:	6442                	ld	s0,16(sp)
 4f0:	6105                	addi	sp,sp,32
 4f2:	8082                	ret

00000000000004f4 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 4f4:	715d                	addi	sp,sp,-80
 4f6:	e486                	sd	ra,72(sp)
 4f8:	e0a2                	sd	s0,64(sp)
 4fa:	fc26                	sd	s1,56(sp)
 4fc:	f84a                	sd	s2,48(sp)
 4fe:	f44e                	sd	s3,40(sp)
 500:	0880                	addi	s0,sp,80
 502:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 504:	c299                	beqz	a3,50a <printint+0x16>
 506:	0805c163          	bltz	a1,588 <printint+0x94>
  neg = 0;
 50a:	4881                	li	a7,0
 50c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 510:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 512:	00000517          	auipc	a0,0x0
 516:	52e50513          	addi	a0,a0,1326 # a40 <digits>
 51a:	883e                	mv	a6,a5
 51c:	2785                	addiw	a5,a5,1
 51e:	02c5f733          	remu	a4,a1,a2
 522:	972a                	add	a4,a4,a0
 524:	00074703          	lbu	a4,0(a4)
 528:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 52c:	872e                	mv	a4,a1
 52e:	02c5d5b3          	divu	a1,a1,a2
 532:	0685                	addi	a3,a3,1
 534:	fec773e3          	bgeu	a4,a2,51a <printint+0x26>
  if(neg)
 538:	00088b63          	beqz	a7,54e <printint+0x5a>
    buf[i++] = '-';
 53c:	fd078793          	addi	a5,a5,-48
 540:	97a2                	add	a5,a5,s0
 542:	02d00713          	li	a4,45
 546:	fee78423          	sb	a4,-24(a5)
 54a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 54e:	02f05663          	blez	a5,57a <printint+0x86>
 552:	fb840713          	addi	a4,s0,-72
 556:	00f704b3          	add	s1,a4,a5
 55a:	fff70993          	addi	s3,a4,-1
 55e:	99be                	add	s3,s3,a5
 560:	37fd                	addiw	a5,a5,-1
 562:	1782                	slli	a5,a5,0x20
 564:	9381                	srli	a5,a5,0x20
 566:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 56a:	fff4c583          	lbu	a1,-1(s1)
 56e:	854a                	mv	a0,s2
 570:	f67ff0ef          	jal	ra,4d6 <putc>
  while(--i >= 0)
 574:	14fd                	addi	s1,s1,-1
 576:	ff349ae3          	bne	s1,s3,56a <printint+0x76>
}
 57a:	60a6                	ld	ra,72(sp)
 57c:	6406                	ld	s0,64(sp)
 57e:	74e2                	ld	s1,56(sp)
 580:	7942                	ld	s2,48(sp)
 582:	79a2                	ld	s3,40(sp)
 584:	6161                	addi	sp,sp,80
 586:	8082                	ret
    x = -xx;
 588:	40b005b3          	neg	a1,a1
    neg = 1;
 58c:	4885                	li	a7,1
    x = -xx;
 58e:	bfbd                	j	50c <printint+0x18>

0000000000000590 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 590:	7119                	addi	sp,sp,-128
 592:	fc86                	sd	ra,120(sp)
 594:	f8a2                	sd	s0,112(sp)
 596:	f4a6                	sd	s1,104(sp)
 598:	f0ca                	sd	s2,96(sp)
 59a:	ecce                	sd	s3,88(sp)
 59c:	e8d2                	sd	s4,80(sp)
 59e:	e4d6                	sd	s5,72(sp)
 5a0:	e0da                	sd	s6,64(sp)
 5a2:	fc5e                	sd	s7,56(sp)
 5a4:	f862                	sd	s8,48(sp)
 5a6:	f466                	sd	s9,40(sp)
 5a8:	f06a                	sd	s10,32(sp)
 5aa:	ec6e                	sd	s11,24(sp)
 5ac:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ae:	0005c903          	lbu	s2,0(a1)
 5b2:	24090c63          	beqz	s2,80a <vprintf+0x27a>
 5b6:	8b2a                	mv	s6,a0
 5b8:	8a2e                	mv	s4,a1
 5ba:	8bb2                	mv	s7,a2
  state = 0;
 5bc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5be:	4481                	li	s1,0
 5c0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5c2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5c6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5ca:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ce:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d2:	00000c97          	auipc	s9,0x0
 5d6:	46ec8c93          	addi	s9,s9,1134 # a40 <digits>
 5da:	a005                	j	5fa <vprintf+0x6a>
        putc(fd, c0);
 5dc:	85ca                	mv	a1,s2
 5de:	855a                	mv	a0,s6
 5e0:	ef7ff0ef          	jal	ra,4d6 <putc>
 5e4:	a019                	j	5ea <vprintf+0x5a>
    } else if(state == '%'){
 5e6:	03598263          	beq	s3,s5,60a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ea:	2485                	addiw	s1,s1,1
 5ec:	8726                	mv	a4,s1
 5ee:	009a07b3          	add	a5,s4,s1
 5f2:	0007c903          	lbu	s2,0(a5)
 5f6:	20090a63          	beqz	s2,80a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5fa:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5fe:	fe0994e3          	bnez	s3,5e6 <vprintf+0x56>
      if(c0 == '%'){
 602:	fd579de3          	bne	a5,s5,5dc <vprintf+0x4c>
        state = '%';
 606:	89be                	mv	s3,a5
 608:	b7cd                	j	5ea <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 60a:	c3c1                	beqz	a5,68a <vprintf+0xfa>
 60c:	00ea06b3          	add	a3,s4,a4
 610:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 614:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 616:	c681                	beqz	a3,61e <vprintf+0x8e>
 618:	9752                	add	a4,a4,s4
 61a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 61e:	03878e63          	beq	a5,s8,65a <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 622:	05a78863          	beq	a5,s10,672 <vprintf+0xe2>
      } else if(c0 == 'u'){
 626:	0db78b63          	beq	a5,s11,6fc <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 62a:	07800713          	li	a4,120
 62e:	10e78d63          	beq	a5,a4,748 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 632:	07000713          	li	a4,112
 636:	14e78263          	beq	a5,a4,77a <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 63a:	06300713          	li	a4,99
 63e:	16e78f63          	beq	a5,a4,7bc <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 642:	07300713          	li	a4,115
 646:	18e78563          	beq	a5,a4,7d0 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 64a:	05579063          	bne	a5,s5,68a <vprintf+0xfa>
        putc(fd, '%');
 64e:	85d6                	mv	a1,s5
 650:	855a                	mv	a0,s6
 652:	e85ff0ef          	jal	ra,4d6 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 656:	4981                	li	s3,0
 658:	bf49                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4685                	li	a3,1
 660:	4629                	li	a2,10
 662:	000ba583          	lw	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	e8dff0ef          	jal	ra,4f4 <printint>
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	bfad                	j	5ea <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 672:	03868663          	beq	a3,s8,69e <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 676:	05a68163          	beq	a3,s10,6b8 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 67a:	09b68d63          	beq	a3,s11,714 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 67e:	03a68f63          	beq	a3,s10,6bc <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 682:	07800793          	li	a5,120
 686:	0cf68d63          	beq	a3,a5,760 <vprintf+0x1d0>
        putc(fd, '%');
 68a:	85d6                	mv	a1,s5
 68c:	855a                	mv	a0,s6
 68e:	e49ff0ef          	jal	ra,4d6 <putc>
        putc(fd, c0);
 692:	85ca                	mv	a1,s2
 694:	855a                	mv	a0,s6
 696:	e41ff0ef          	jal	ra,4d6 <putc>
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b7b9                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 69e:	008b8913          	addi	s2,s7,8
 6a2:	4685                	li	a3,1
 6a4:	4629                	li	a2,10
 6a6:	000bb583          	ld	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	e49ff0ef          	jal	ra,4f4 <printint>
        i += 1;
 6b0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b2:	8bca                	mv	s7,s2
      state = 0;
 6b4:	4981                	li	s3,0
        i += 1;
 6b6:	bf15                	j	5ea <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b8:	03860563          	beq	a2,s8,6e2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6bc:	07b60963          	beq	a2,s11,72e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6c0:	07800793          	li	a5,120
 6c4:	fcf613e3          	bne	a2,a5,68a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4641                	li	a2,16
 6d0:	000bb583          	ld	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	e1fff0ef          	jal	ra,4f4 <printint>
        i += 2;
 6da:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6dc:	8bca                	mv	s7,s2
      state = 0;
 6de:	4981                	li	s3,0
        i += 2;
 6e0:	b729                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	4685                	li	a3,1
 6e8:	4629                	li	a2,10
 6ea:	000bb583          	ld	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	e05ff0ef          	jal	ra,4f4 <printint>
        i += 2;
 6f4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f6:	8bca                	mv	s7,s2
      state = 0;
 6f8:	4981                	li	s3,0
        i += 2;
 6fa:	bdc5                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6fc:	008b8913          	addi	s2,s7,8
 700:	4681                	li	a3,0
 702:	4629                	li	a2,10
 704:	000be583          	lwu	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	debff0ef          	jal	ra,4f4 <printint>
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
 712:	bde1                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 714:	008b8913          	addi	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4629                	li	a2,10
 71c:	000bb583          	ld	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	dd3ff0ef          	jal	ra,4f4 <printint>
        i += 1;
 726:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
        i += 1;
 72c:	bd7d                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 72e:	008b8913          	addi	s2,s7,8
 732:	4681                	li	a3,0
 734:	4629                	li	a2,10
 736:	000bb583          	ld	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	db9ff0ef          	jal	ra,4f4 <printint>
        i += 2;
 740:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
        i += 2;
 746:	b555                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 748:	008b8913          	addi	s2,s7,8
 74c:	4681                	li	a3,0
 74e:	4641                	li	a2,16
 750:	000be583          	lwu	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	d9fff0ef          	jal	ra,4f4 <printint>
 75a:	8bca                	mv	s7,s2
      state = 0;
 75c:	4981                	li	s3,0
 75e:	b571                	j	5ea <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 760:	008b8913          	addi	s2,s7,8
 764:	4681                	li	a3,0
 766:	4641                	li	a2,16
 768:	000bb583          	ld	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	d87ff0ef          	jal	ra,4f4 <printint>
        i += 1;
 772:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 774:	8bca                	mv	s7,s2
      state = 0;
 776:	4981                	li	s3,0
        i += 1;
 778:	bd8d                	j	5ea <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 77a:	008b8793          	addi	a5,s7,8
 77e:	f8f43423          	sd	a5,-120(s0)
 782:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 786:	03000593          	li	a1,48
 78a:	855a                	mv	a0,s6
 78c:	d4bff0ef          	jal	ra,4d6 <putc>
  putc(fd, 'x');
 790:	07800593          	li	a1,120
 794:	855a                	mv	a0,s6
 796:	d41ff0ef          	jal	ra,4d6 <putc>
 79a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79c:	03c9d793          	srli	a5,s3,0x3c
 7a0:	97e6                	add	a5,a5,s9
 7a2:	0007c583          	lbu	a1,0(a5)
 7a6:	855a                	mv	a0,s6
 7a8:	d2fff0ef          	jal	ra,4d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ac:	0992                	slli	s3,s3,0x4
 7ae:	397d                	addiw	s2,s2,-1
 7b0:	fe0916e3          	bnez	s2,79c <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7b4:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	bd05                	j	5ea <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7bc:	008b8913          	addi	s2,s7,8
 7c0:	000bc583          	lbu	a1,0(s7)
 7c4:	855a                	mv	a0,s6
 7c6:	d11ff0ef          	jal	ra,4d6 <putc>
 7ca:	8bca                	mv	s7,s2
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	bd31                	j	5ea <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7d0:	008b8993          	addi	s3,s7,8
 7d4:	000bb903          	ld	s2,0(s7)
 7d8:	00090f63          	beqz	s2,7f6 <vprintf+0x266>
        for(; *s; s++)
 7dc:	00094583          	lbu	a1,0(s2)
 7e0:	c195                	beqz	a1,804 <vprintf+0x274>
          putc(fd, *s);
 7e2:	855a                	mv	a0,s6
 7e4:	cf3ff0ef          	jal	ra,4d6 <putc>
        for(; *s; s++)
 7e8:	0905                	addi	s2,s2,1
 7ea:	00094583          	lbu	a1,0(s2)
 7ee:	f9f5                	bnez	a1,7e2 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7f0:	8bce                	mv	s7,s3
      state = 0;
 7f2:	4981                	li	s3,0
 7f4:	bbdd                	j	5ea <vprintf+0x5a>
          s = "(null)";
 7f6:	00000917          	auipc	s2,0x0
 7fa:	24290913          	addi	s2,s2,578 # a38 <malloc+0x132>
        for(; *s; s++)
 7fe:	02800593          	li	a1,40
 802:	b7c5                	j	7e2 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 804:	8bce                	mv	s7,s3
      state = 0;
 806:	4981                	li	s3,0
 808:	b3cd                	j	5ea <vprintf+0x5a>
    }
  }
}
 80a:	70e6                	ld	ra,120(sp)
 80c:	7446                	ld	s0,112(sp)
 80e:	74a6                	ld	s1,104(sp)
 810:	7906                	ld	s2,96(sp)
 812:	69e6                	ld	s3,88(sp)
 814:	6a46                	ld	s4,80(sp)
 816:	6aa6                	ld	s5,72(sp)
 818:	6b06                	ld	s6,64(sp)
 81a:	7be2                	ld	s7,56(sp)
 81c:	7c42                	ld	s8,48(sp)
 81e:	7ca2                	ld	s9,40(sp)
 820:	7d02                	ld	s10,32(sp)
 822:	6de2                	ld	s11,24(sp)
 824:	6109                	addi	sp,sp,128
 826:	8082                	ret

0000000000000828 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 828:	715d                	addi	sp,sp,-80
 82a:	ec06                	sd	ra,24(sp)
 82c:	e822                	sd	s0,16(sp)
 82e:	1000                	addi	s0,sp,32
 830:	e010                	sd	a2,0(s0)
 832:	e414                	sd	a3,8(s0)
 834:	e818                	sd	a4,16(s0)
 836:	ec1c                	sd	a5,24(s0)
 838:	03043023          	sd	a6,32(s0)
 83c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 840:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 844:	8622                	mv	a2,s0
 846:	d4bff0ef          	jal	ra,590 <vprintf>
}
 84a:	60e2                	ld	ra,24(sp)
 84c:	6442                	ld	s0,16(sp)
 84e:	6161                	addi	sp,sp,80
 850:	8082                	ret

0000000000000852 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 852:	711d                	addi	sp,sp,-96
 854:	ec06                	sd	ra,24(sp)
 856:	e822                	sd	s0,16(sp)
 858:	1000                	addi	s0,sp,32
 85a:	e40c                	sd	a1,8(s0)
 85c:	e810                	sd	a2,16(s0)
 85e:	ec14                	sd	a3,24(s0)
 860:	f018                	sd	a4,32(s0)
 862:	f41c                	sd	a5,40(s0)
 864:	03043823          	sd	a6,48(s0)
 868:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 86c:	00840613          	addi	a2,s0,8
 870:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 874:	85aa                	mv	a1,a0
 876:	4505                	li	a0,1
 878:	d19ff0ef          	jal	ra,590 <vprintf>
}
 87c:	60e2                	ld	ra,24(sp)
 87e:	6442                	ld	s0,16(sp)
 880:	6125                	addi	sp,sp,96
 882:	8082                	ret

0000000000000884 <free>:
 *   无
 */

void
free(void *ap)
{
 884:	1141                	addi	sp,sp,-16
 886:	e422                	sd	s0,8(sp)
 888:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 88a:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88e:	00000797          	auipc	a5,0x0
 892:	7727b783          	ld	a5,1906(a5) # 1000 <freep>
 896:	a02d                	j	8c0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 898:	4618                	lw	a4,8(a2)
 89a:	9f2d                	addw	a4,a4,a1
 89c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	6398                	ld	a4,0(a5)
 8a2:	6310                	ld	a2,0(a4)
 8a4:	a83d                	j	8e2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a6:	ff852703          	lw	a4,-8(a0)
 8aa:	9f31                	addw	a4,a4,a2
 8ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ae:	ff053683          	ld	a3,-16(a0)
 8b2:	a091                	j	8f6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b4:	6398                	ld	a4,0(a5)
 8b6:	00e7e463          	bltu	a5,a4,8be <free+0x3a>
 8ba:	00e6ea63          	bltu	a3,a4,8ce <free+0x4a>
{
 8be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c0:	fed7fae3          	bgeu	a5,a3,8b4 <free+0x30>
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e6e463          	bltu	a3,a4,8ce <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ca:	fee7eae3          	bltu	a5,a4,8be <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ce:	ff852583          	lw	a1,-8(a0)
 8d2:	6390                	ld	a2,0(a5)
 8d4:	02059813          	slli	a6,a1,0x20
 8d8:	01c85713          	srli	a4,a6,0x1c
 8dc:	9736                	add	a4,a4,a3
 8de:	fae60de3          	beq	a2,a4,898 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e6:	4790                	lw	a2,8(a5)
 8e8:	02061593          	slli	a1,a2,0x20
 8ec:	01c5d713          	srli	a4,a1,0x1c
 8f0:	973e                	add	a4,a4,a5
 8f2:	fae68ae3          	beq	a3,a4,8a6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  /* 更新空闲链表头指针 */
  freep = p;
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70f73423          	sd	a5,1800(a4) # 1000 <freep>
}
 900:	6422                	ld	s0,8(sp)
 902:	0141                	addi	sp,sp,16
 904:	8082                	ret

0000000000000906 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 906:	7139                	addi	sp,sp,-64
 908:	fc06                	sd	ra,56(sp)
 90a:	f822                	sd	s0,48(sp)
 90c:	f426                	sd	s1,40(sp)
 90e:	f04a                	sd	s2,32(sp)
 910:	ec4e                	sd	s3,24(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
 918:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91a:	02051493          	slli	s1,a0,0x20
 91e:	9081                	srli	s1,s1,0x20
 920:	04bd                	addi	s1,s1,15
 922:	8091                	srli	s1,s1,0x4
 924:	0014899b          	addiw	s3,s1,1
 928:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 92a:	00000517          	auipc	a0,0x0
 92e:	6d653503          	ld	a0,1750(a0) # 1000 <freep>
 932:	c515                	beqz	a0,95e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 936:	4798                	lw	a4,8(a5)
 938:	02977f63          	bgeu	a4,s1,976 <malloc+0x70>
 93c:	8a4e                	mv	s4,s3
 93e:	0009871b          	sext.w	a4,s3
 942:	6685                	lui	a3,0x1
 944:	00d77363          	bgeu	a4,a3,94a <malloc+0x44>
 948:	6a05                	lui	s4,0x1
 94a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 94e:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 952:	00000917          	auipc	s2,0x0
 956:	6ae90913          	addi	s2,s2,1710 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 95a:	5afd                	li	s5,-1
 95c:	a885                	j	9cc <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 95e:	00001797          	auipc	a5,0x1
 962:	8b278793          	addi	a5,a5,-1870 # 1210 <base>
 966:	00000717          	auipc	a4,0x0
 96a:	68f73d23          	sd	a5,1690(a4) # 1000 <freep>
 96e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 970:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 974:	b7e1                	j	93c <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 976:	02e48c63          	beq	s1,a4,9ae <malloc+0xa8>
        p->s.size -= nunits;
 97a:	4137073b          	subw	a4,a4,s3
 97e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 980:	02071693          	slli	a3,a4,0x20
 984:	01c6d713          	srli	a4,a3,0x1c
 988:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98a:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 98e:	00000717          	auipc	a4,0x0
 992:	66a73923          	sd	a0,1650(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 996:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 99a:	70e2                	ld	ra,56(sp)
 99c:	7442                	ld	s0,48(sp)
 99e:	74a2                	ld	s1,40(sp)
 9a0:	7902                	ld	s2,32(sp)
 9a2:	69e2                	ld	s3,24(sp)
 9a4:	6a42                	ld	s4,16(sp)
 9a6:	6aa2                	ld	s5,8(sp)
 9a8:	6b02                	ld	s6,0(sp)
 9aa:	6121                	addi	sp,sp,64
 9ac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9ae:	6398                	ld	a4,0(a5)
 9b0:	e118                	sd	a4,0(a0)
 9b2:	bff1                	j	98e <malloc+0x88>
  hp->s.size = nu;
 9b4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 9b8:	0541                	addi	a0,a0,16
 9ba:	ecbff0ef          	jal	ra,884 <free>
  return freep;
 9be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9c2:	dd61                	beqz	a0,99a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 9c6:	4798                	lw	a4,8(a5)
 9c8:	fa9777e3          	bgeu	a4,s1,976 <malloc+0x70>
    if(p == freep)
 9cc:	00093703          	ld	a4,0(s2)
 9d0:	853e                	mv	a0,a5
 9d2:	fef719e3          	bne	a4,a5,9c4 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 9d6:	8552                	mv	a0,s4
 9d8:	9ebff0ef          	jal	ra,3c2 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 9dc:	fd551ce3          	bne	a0,s5,9b4 <malloc+0xae>
        return 0;  /* 内存分配失败 */
 9e0:	4501                	li	a0,0
 9e2:	bf65                	j	99a <malloc+0x94>
