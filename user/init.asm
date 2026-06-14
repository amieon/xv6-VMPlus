
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	94250513          	addi	a0,a0,-1726 # 950 <malloc+0xe8>
  16:	37c000ef          	jal	ra,392 <open>
  1a:	04054563          	bltz	a0,64 <main+0x64>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  1e:	4501                	li	a0,0
  20:	3aa000ef          	jal	ra,3ca <dup>
  dup(0);  // stderr
  24:	4501                	li	a0,0
  26:	3a4000ef          	jal	ra,3ca <dup>

  for(;;){
    printf("init: starting sh\n");
  2a:	00001917          	auipc	s2,0x1
  2e:	92e90913          	addi	s2,s2,-1746 # 958 <malloc+0xf0>
  32:	854a                	mv	a0,s2
  34:	77a000ef          	jal	ra,7ae <printf>
    pid = fork();
  38:	312000ef          	jal	ra,34a <fork>
  3c:	84aa                	mv	s1,a0
    if(pid < 0){
  3e:	04054363          	bltz	a0,84 <main+0x84>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  42:	c931                	beqz	a0,96 <main+0x96>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  44:	4501                	li	a0,0
  46:	314000ef          	jal	ra,35a <wait>
      if(wpid == pid){
  4a:	fea484e3          	beq	s1,a0,32 <main+0x32>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  4e:	fe055be3          	bgez	a0,44 <main+0x44>
        printf("init: wait returned an error\n");
  52:	00001517          	auipc	a0,0x1
  56:	95650513          	addi	a0,a0,-1706 # 9a8 <malloc+0x140>
  5a:	754000ef          	jal	ra,7ae <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	2f2000ef          	jal	ra,352 <exit>
    mknod("console", CONSOLE, 0);
  64:	4601                	li	a2,0
  66:	4585                	li	a1,1
  68:	00001517          	auipc	a0,0x1
  6c:	8e850513          	addi	a0,a0,-1816 # 950 <malloc+0xe8>
  70:	32a000ef          	jal	ra,39a <mknod>
    open("console", O_RDWR);
  74:	4589                	li	a1,2
  76:	00001517          	auipc	a0,0x1
  7a:	8da50513          	addi	a0,a0,-1830 # 950 <malloc+0xe8>
  7e:	314000ef          	jal	ra,392 <open>
  82:	bf71                	j	1e <main+0x1e>
      printf("init: fork failed\n");
  84:	00001517          	auipc	a0,0x1
  88:	8ec50513          	addi	a0,a0,-1812 # 970 <malloc+0x108>
  8c:	722000ef          	jal	ra,7ae <printf>
      exit(1);
  90:	4505                	li	a0,1
  92:	2c0000ef          	jal	ra,352 <exit>
      exec("sh", argv);
  96:	00001597          	auipc	a1,0x1
  9a:	f6a58593          	addi	a1,a1,-150 # 1000 <argv>
  9e:	00001517          	auipc	a0,0x1
  a2:	8ea50513          	addi	a0,a0,-1814 # 988 <malloc+0x120>
  a6:	2e4000ef          	jal	ra,38a <exec>
      printf("init: exec sh failed\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	8e650513          	addi	a0,a0,-1818 # 990 <malloc+0x128>
  b2:	6fc000ef          	jal	ra,7ae <printf>
      exit(1);
  b6:	4505                	li	a0,1
  b8:	29a000ef          	jal	ra,352 <exit>

00000000000000bc <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e406                	sd	ra,8(sp)
  c0:	e022                	sd	s0,0(sp)
  c2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  c4:	f3dff0ef          	jal	ra,0 <main>
  exit(r);
  c8:	28a000ef          	jal	ra,352 <exit>

00000000000000cc <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d2:	87aa                	mv	a5,a0
  d4:	0585                	addi	a1,a1,1
  d6:	0785                	addi	a5,a5,1
  d8:	fff5c703          	lbu	a4,-1(a1)
  dc:	fee78fa3          	sb	a4,-1(a5)
  e0:	fb75                	bnez	a4,d4 <strcpy+0x8>
    ;
  return os;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x1e>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x1e>
    p++, q++;
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 106:	0005c503          	lbu	a0,0(a1)
}
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cf91                	beqz	a5,13a <strlen+0x26>
 120:	0505                	addi	a0,a0,1
 122:	87aa                	mv	a5,a0
 124:	4685                	li	a3,1
 126:	9e89                	subw	a3,a3,a0
 128:	00f6853b          	addw	a0,a3,a5
 12c:	0785                	addi	a5,a5,1
 12e:	fff7c703          	lbu	a4,-1(a5)
 132:	fb7d                	bnez	a4,128 <strlen+0x14>
    ;
  return n;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret
  for(n = 0; s[n]; n++)
 13a:	4501                	li	a0,0
 13c:	bfe5                	j	134 <strlen+0x20>

000000000000013e <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 144:	ca19                	beqz	a2,15a <memset+0x1c>
 146:	87aa                	mv	a5,a0
 148:	1602                	slli	a2,a2,0x20
 14a:	9201                	srli	a2,a2,0x20
 14c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 150:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 154:	0785                	addi	a5,a5,1
 156:	fee79de3          	bne	a5,a4,150 <memset+0x12>
  }
  return dst;
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  for(; *s; s++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cb99                	beqz	a5,180 <strchr+0x20>
    if(*s == c)
 16c:	00f58763          	beq	a1,a5,17a <strchr+0x1a>
  for(; *s; s++)
 170:	0505                	addi	a0,a0,1
 172:	00054783          	lbu	a5,0(a0)
 176:	fbfd                	bnez	a5,16c <strchr+0xc>
      return (char*)s;
  return 0;
 178:	4501                	li	a0,0
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  return 0;
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strchr+0x1a>

0000000000000184 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 184:	711d                	addi	sp,sp,-96
 186:	ec86                	sd	ra,88(sp)
 188:	e8a2                	sd	s0,80(sp)
 18a:	e4a6                	sd	s1,72(sp)
 18c:	e0ca                	sd	s2,64(sp)
 18e:	fc4e                	sd	s3,56(sp)
 190:	f852                	sd	s4,48(sp)
 192:	f456                	sd	s5,40(sp)
 194:	f05a                	sd	s6,32(sp)
 196:	ec5e                	sd	s7,24(sp)
 198:	1080                	addi	s0,sp,96
 19a:	8baa                	mv	s7,a0
 19c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19e:	892a                	mv	s2,a0
 1a0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a2:	4aa9                	li	s5,10
 1a4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a6:	89a6                	mv	s3,s1
 1a8:	2485                	addiw	s1,s1,1
 1aa:	0344d663          	bge	s1,s4,1d6 <gets+0x52>
    cc = read(0, &c, 1);
 1ae:	4605                	li	a2,1
 1b0:	faf40593          	addi	a1,s0,-81
 1b4:	4501                	li	a0,0
 1b6:	1b4000ef          	jal	ra,36a <read>
    if(cc < 1)
 1ba:	00a05e63          	blez	a0,1d6 <gets+0x52>
    buf[i++] = c;
 1be:	faf44783          	lbu	a5,-81(s0)
 1c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c6:	01578763          	beq	a5,s5,1d4 <gets+0x50>
 1ca:	0905                	addi	s2,s2,1
 1cc:	fd679de3          	bne	a5,s6,1a6 <gets+0x22>
  for(i=0; i+1 < max; ){
 1d0:	89a6                	mv	s3,s1
 1d2:	a011                	j	1d6 <gets+0x52>
 1d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d6:	99de                	add	s3,s3,s7
 1d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1dc:	855e                	mv	a0,s7
 1de:	60e6                	ld	ra,88(sp)
 1e0:	6446                	ld	s0,80(sp)
 1e2:	64a6                	ld	s1,72(sp)
 1e4:	6906                	ld	s2,64(sp)
 1e6:	79e2                	ld	s3,56(sp)
 1e8:	7a42                	ld	s4,48(sp)
 1ea:	7aa2                	ld	s5,40(sp)
 1ec:	7b02                	ld	s6,32(sp)
 1ee:	6be2                	ld	s7,24(sp)
 1f0:	6125                	addi	sp,sp,96
 1f2:	8082                	ret

00000000000001f4 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 1f4:	1101                	addi	sp,sp,-32
 1f6:	ec06                	sd	ra,24(sp)
 1f8:	e822                	sd	s0,16(sp)
 1fa:	e426                	sd	s1,8(sp)
 1fc:	e04a                	sd	s2,0(sp)
 1fe:	1000                	addi	s0,sp,32
 200:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 202:	4581                	li	a1,0
 204:	18e000ef          	jal	ra,392 <open>
  if(fd < 0)
 208:	02054163          	bltz	a0,22a <stat+0x36>
 20c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20e:	85ca                	mv	a1,s2
 210:	19a000ef          	jal	ra,3aa <fstat>
 214:	892a                	mv	s2,a0
  close(fd);
 216:	8526                	mv	a0,s1
 218:	162000ef          	jal	ra,37a <close>
  return r;
}
 21c:	854a                	mv	a0,s2
 21e:	60e2                	ld	ra,24(sp)
 220:	6442                	ld	s0,16(sp)
 222:	64a2                	ld	s1,8(sp)
 224:	6902                	ld	s2,0(sp)
 226:	6105                	addi	sp,sp,32
 228:	8082                	ret
    return -1;
 22a:	597d                	li	s2,-1
 22c:	bfc5                	j	21c <stat+0x28>

000000000000022e <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 234:	00054603          	lbu	a2,0(a0)
 238:	fd06079b          	addiw	a5,a2,-48
 23c:	0ff7f793          	andi	a5,a5,255
 240:	4725                	li	a4,9
 242:	02f76963          	bltu	a4,a5,274 <atoi+0x46>
 246:	86aa                	mv	a3,a0
  n = 0;
 248:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 24a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 24c:	0685                	addi	a3,a3,1
 24e:	0025179b          	slliw	a5,a0,0x2
 252:	9fa9                	addw	a5,a5,a0
 254:	0017979b          	slliw	a5,a5,0x1
 258:	9fb1                	addw	a5,a5,a2
 25a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25e:	0006c603          	lbu	a2,0(a3)
 262:	fd06071b          	addiw	a4,a2,-48
 266:	0ff77713          	andi	a4,a4,255
 26a:	fee5f1e3          	bgeu	a1,a4,24c <atoi+0x1e>
  return n;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret
  n = 0;
 274:	4501                	li	a0,0
 276:	bfe5                	j	26e <atoi+0x40>

0000000000000278 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27e:	02b57463          	bgeu	a0,a1,2a6 <memmove+0x2e>
    while(n-- > 0)
 282:	00c05f63          	blez	a2,2a0 <memmove+0x28>
 286:	1602                	slli	a2,a2,0x20
 288:	9201                	srli	a2,a2,0x20
 28a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28e:	872a                	mv	a4,a0
      *dst++ = *src++;
 290:	0585                	addi	a1,a1,1
 292:	0705                	addi	a4,a4,1
 294:	fff5c683          	lbu	a3,-1(a1)
 298:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29c:	fee79ae3          	bne	a5,a4,290 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
    dst += n;
 2a6:	00c50733          	add	a4,a0,a2
    src += n;
 2aa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ac:	fec05ae3          	blez	a2,2a0 <memmove+0x28>
 2b0:	fff6079b          	addiw	a5,a2,-1
 2b4:	1782                	slli	a5,a5,0x20
 2b6:	9381                	srli	a5,a5,0x20
 2b8:	fff7c793          	not	a5,a5
 2bc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2be:	15fd                	addi	a1,a1,-1
 2c0:	177d                	addi	a4,a4,-1
 2c2:	0005c683          	lbu	a3,0(a1)
 2c6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ca:	fee79ae3          	bne	a5,a4,2be <memmove+0x46>
 2ce:	bfc9                	j	2a0 <memmove+0x28>

00000000000002d0 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d6:	ca05                	beqz	a2,306 <memcmp+0x36>
 2d8:	fff6069b          	addiw	a3,a2,-1
 2dc:	1682                	slli	a3,a3,0x20
 2de:	9281                	srli	a3,a3,0x20
 2e0:	0685                	addi	a3,a3,1
 2e2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	0005c703          	lbu	a4,0(a1)
 2ec:	00e79863          	bne	a5,a4,2fc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f0:	0505                	addi	a0,a0,1
    p2++;
 2f2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f4:	fed518e3          	bne	a0,a3,2e4 <memcmp+0x14>
  }
  return 0;
 2f8:	4501                	li	a0,0
 2fa:	a019                	j	300 <memcmp+0x30>
      return *p1 - *p2;
 2fc:	40e7853b          	subw	a0,a5,a4
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret
  return 0;
 306:	4501                	li	a0,0
 308:	bfe5                	j	300 <memcmp+0x30>

000000000000030a <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e406                	sd	ra,8(sp)
 30e:	e022                	sd	s0,0(sp)
 310:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 312:	f67ff0ef          	jal	ra,278 <memmove>
}
 316:	60a2                	ld	ra,8(sp)
 318:	6402                	ld	s0,0(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret

000000000000031e <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 31e:	1141                	addi	sp,sp,-16
 320:	e406                	sd	ra,8(sp)
 322:	e022                	sd	s0,0(sp)
 324:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 326:	4585                	li	a1,1
 328:	0b2000ef          	jal	ra,3da <sys_sbrk>
}
 32c:	60a2                	ld	ra,8(sp)
 32e:	6402                	ld	s0,0(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 33c:	4589                	li	a1,2
 33e:	09c000ef          	jal	ra,3da <sys_sbrk>
}
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34a:	4885                	li	a7,1
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exit>:
.global exit
exit:
 li a7, SYS_exit
 352:	4889                	li	a7,2
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <wait>:
.global wait
wait:
 li a7, SYS_wait
 35a:	488d                	li	a7,3
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 362:	4891                	li	a7,4
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <read>:
.global read
read:
 li a7, SYS_read
 36a:	4895                	li	a7,5
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <write>:
.global write
write:
 li a7, SYS_write
 372:	48c1                	li	a7,16
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <close>:
.global close
close:
 li a7, SYS_close
 37a:	48d5                	li	a7,21
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <kill>:
.global kill
kill:
 li a7, SYS_kill
 382:	4899                	li	a7,6
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <exec>:
.global exec
exec:
 li a7, SYS_exec
 38a:	489d                	li	a7,7
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <open>:
.global open
open:
 li a7, SYS_open
 392:	48bd                	li	a7,15
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39a:	48c5                	li	a7,17
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a2:	48c9                	li	a7,18
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3aa:	48a1                	li	a7,8
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <link>:
.global link
link:
 li a7, SYS_link
 3b2:	48cd                	li	a7,19
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ba:	48d1                	li	a7,20
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c2:	48a5                	li	a7,9
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ca:	48a9                	li	a7,10
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d2:	48ad                	li	a7,11
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3da:	48b1                	li	a7,12
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e2:	48b5                	li	a7,13
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ea:	48b9                	li	a7,14
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3f2:	48d9                	li	a7,22
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3fa:	48dd                	li	a7,23
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 402:	48e1                	li	a7,24
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40a:	48e5                	li	a7,25
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 412:	48e9                	li	a7,26
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 41a:	48ed                	li	a7,27
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 422:	48f1                	li	a7,28
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 42a:	48f5                	li	a7,29
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 432:	1101                	addi	sp,sp,-32
 434:	ec06                	sd	ra,24(sp)
 436:	e822                	sd	s0,16(sp)
 438:	1000                	addi	s0,sp,32
 43a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43e:	4605                	li	a2,1
 440:	fef40593          	addi	a1,s0,-17
 444:	f2fff0ef          	jal	ra,372 <write>
}
 448:	60e2                	ld	ra,24(sp)
 44a:	6442                	ld	s0,16(sp)
 44c:	6105                	addi	sp,sp,32
 44e:	8082                	ret

0000000000000450 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 450:	715d                	addi	sp,sp,-80
 452:	e486                	sd	ra,72(sp)
 454:	e0a2                	sd	s0,64(sp)
 456:	fc26                	sd	s1,56(sp)
 458:	f84a                	sd	s2,48(sp)
 45a:	f44e                	sd	s3,40(sp)
 45c:	0880                	addi	s0,sp,80
 45e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 460:	c299                	beqz	a3,466 <printint+0x16>
 462:	0805c163          	bltz	a1,4e4 <printint+0x94>
  neg = 0;
 466:	4881                	li	a7,0
 468:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 46c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 46e:	00000517          	auipc	a0,0x0
 472:	56250513          	addi	a0,a0,1378 # 9d0 <digits>
 476:	883e                	mv	a6,a5
 478:	2785                	addiw	a5,a5,1
 47a:	02c5f733          	remu	a4,a1,a2
 47e:	972a                	add	a4,a4,a0
 480:	00074703          	lbu	a4,0(a4)
 484:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 488:	872e                	mv	a4,a1
 48a:	02c5d5b3          	divu	a1,a1,a2
 48e:	0685                	addi	a3,a3,1
 490:	fec773e3          	bgeu	a4,a2,476 <printint+0x26>
  if(neg)
 494:	00088b63          	beqz	a7,4aa <printint+0x5a>
    buf[i++] = '-';
 498:	fd040713          	addi	a4,s0,-48
 49c:	97ba                	add	a5,a5,a4
 49e:	02d00713          	li	a4,45
 4a2:	fee78423          	sb	a4,-24(a5)
 4a6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4aa:	02f05663          	blez	a5,4d6 <printint+0x86>
 4ae:	fb840713          	addi	a4,s0,-72
 4b2:	00f704b3          	add	s1,a4,a5
 4b6:	fff70993          	addi	s3,a4,-1
 4ba:	99be                	add	s3,s3,a5
 4bc:	37fd                	addiw	a5,a5,-1
 4be:	1782                	slli	a5,a5,0x20
 4c0:	9381                	srli	a5,a5,0x20
 4c2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4c6:	fff4c583          	lbu	a1,-1(s1)
 4ca:	854a                	mv	a0,s2
 4cc:	f67ff0ef          	jal	ra,432 <putc>
  while(--i >= 0)
 4d0:	14fd                	addi	s1,s1,-1
 4d2:	ff349ae3          	bne	s1,s3,4c6 <printint+0x76>
}
 4d6:	60a6                	ld	ra,72(sp)
 4d8:	6406                	ld	s0,64(sp)
 4da:	74e2                	ld	s1,56(sp)
 4dc:	7942                	ld	s2,48(sp)
 4de:	79a2                	ld	s3,40(sp)
 4e0:	6161                	addi	sp,sp,80
 4e2:	8082                	ret
    x = -xx;
 4e4:	40b005b3          	neg	a1,a1
    neg = 1;
 4e8:	4885                	li	a7,1
    x = -xx;
 4ea:	bfbd                	j	468 <printint+0x18>

00000000000004ec <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ec:	7119                	addi	sp,sp,-128
 4ee:	fc86                	sd	ra,120(sp)
 4f0:	f8a2                	sd	s0,112(sp)
 4f2:	f4a6                	sd	s1,104(sp)
 4f4:	f0ca                	sd	s2,96(sp)
 4f6:	ecce                	sd	s3,88(sp)
 4f8:	e8d2                	sd	s4,80(sp)
 4fa:	e4d6                	sd	s5,72(sp)
 4fc:	e0da                	sd	s6,64(sp)
 4fe:	fc5e                	sd	s7,56(sp)
 500:	f862                	sd	s8,48(sp)
 502:	f466                	sd	s9,40(sp)
 504:	f06a                	sd	s10,32(sp)
 506:	ec6e                	sd	s11,24(sp)
 508:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50a:	0005c903          	lbu	s2,0(a1)
 50e:	24090c63          	beqz	s2,766 <vprintf+0x27a>
 512:	8b2a                	mv	s6,a0
 514:	8a2e                	mv	s4,a1
 516:	8bb2                	mv	s7,a2
  state = 0;
 518:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 51a:	4481                	li	s1,0
 51c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 51e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 522:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 526:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 52a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 52e:	00000c97          	auipc	s9,0x0
 532:	4a2c8c93          	addi	s9,s9,1186 # 9d0 <digits>
 536:	a005                	j	556 <vprintf+0x6a>
        putc(fd, c0);
 538:	85ca                	mv	a1,s2
 53a:	855a                	mv	a0,s6
 53c:	ef7ff0ef          	jal	ra,432 <putc>
 540:	a019                	j	546 <vprintf+0x5a>
    } else if(state == '%'){
 542:	03598263          	beq	s3,s5,566 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 546:	2485                	addiw	s1,s1,1
 548:	8726                	mv	a4,s1
 54a:	009a07b3          	add	a5,s4,s1
 54e:	0007c903          	lbu	s2,0(a5)
 552:	20090a63          	beqz	s2,766 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 556:	0009079b          	sext.w	a5,s2
    if(state == 0){
 55a:	fe0994e3          	bnez	s3,542 <vprintf+0x56>
      if(c0 == '%'){
 55e:	fd579de3          	bne	a5,s5,538 <vprintf+0x4c>
        state = '%';
 562:	89be                	mv	s3,a5
 564:	b7cd                	j	546 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 566:	c3c1                	beqz	a5,5e6 <vprintf+0xfa>
 568:	00ea06b3          	add	a3,s4,a4
 56c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 570:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 572:	c681                	beqz	a3,57a <vprintf+0x8e>
 574:	9752                	add	a4,a4,s4
 576:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 57a:	03878e63          	beq	a5,s8,5b6 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 57e:	05a78863          	beq	a5,s10,5ce <vprintf+0xe2>
      } else if(c0 == 'u'){
 582:	0db78b63          	beq	a5,s11,658 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 586:	07800713          	li	a4,120
 58a:	10e78d63          	beq	a5,a4,6a4 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 58e:	07000713          	li	a4,112
 592:	14e78263          	beq	a5,a4,6d6 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 596:	06300713          	li	a4,99
 59a:	16e78f63          	beq	a5,a4,718 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 59e:	07300713          	li	a4,115
 5a2:	18e78563          	beq	a5,a4,72c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5a6:	05579063          	bne	a5,s5,5e6 <vprintf+0xfa>
        putc(fd, '%');
 5aa:	85d6                	mv	a1,s5
 5ac:	855a                	mv	a0,s6
 5ae:	e85ff0ef          	jal	ra,432 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bf49                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4685                	li	a3,1
 5bc:	4629                	li	a2,10
 5be:	000ba583          	lw	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e8dff0ef          	jal	ra,450 <printint>
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	bfad                	j	546 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ce:	03868663          	beq	a3,s8,5fa <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d2:	05a68163          	beq	a3,s10,614 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5d6:	09b68d63          	beq	a3,s11,670 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5da:	03a68f63          	beq	a3,s10,618 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5de:	07800793          	li	a5,120
 5e2:	0cf68d63          	beq	a3,a5,6bc <vprintf+0x1d0>
        putc(fd, '%');
 5e6:	85d6                	mv	a1,s5
 5e8:	855a                	mv	a0,s6
 5ea:	e49ff0ef          	jal	ra,432 <putc>
        putc(fd, c0);
 5ee:	85ca                	mv	a1,s2
 5f0:	855a                	mv	a0,s6
 5f2:	e41ff0ef          	jal	ra,432 <putc>
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	b7b9                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fa:	008b8913          	addi	s2,s7,8
 5fe:	4685                	li	a3,1
 600:	4629                	li	a2,10
 602:	000bb583          	ld	a1,0(s7)
 606:	855a                	mv	a0,s6
 608:	e49ff0ef          	jal	ra,450 <printint>
        i += 1;
 60c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 60e:	8bca                	mv	s7,s2
      state = 0;
 610:	4981                	li	s3,0
        i += 1;
 612:	bf15                	j	546 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 614:	03860563          	beq	a2,s8,63e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 618:	07b60963          	beq	a2,s11,68a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 61c:	07800793          	li	a5,120
 620:	fcf613e3          	bne	a2,a5,5e6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 624:	008b8913          	addi	s2,s7,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	e1fff0ef          	jal	ra,450 <printint>
        i += 2;
 636:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
        i += 2;
 63c:	b729                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63e:	008b8913          	addi	s2,s7,8
 642:	4685                	li	a3,1
 644:	4629                	li	a2,10
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	e05ff0ef          	jal	ra,450 <printint>
        i += 2;
 650:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
        i += 2;
 656:	bdc5                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000be583          	lwu	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	debff0ef          	jal	ra,450 <printint>
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bde1                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 670:	008b8913          	addi	s2,s7,8
 674:	4681                	li	a3,0
 676:	4629                	li	a2,10
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	dd3ff0ef          	jal	ra,450 <printint>
        i += 1;
 682:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 1;
 688:	bd7d                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4681                	li	a3,0
 690:	4629                	li	a2,10
 692:	000bb583          	ld	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	db9ff0ef          	jal	ra,450 <printint>
        i += 2;
 69c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
        i += 2;
 6a2:	b555                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4641                	li	a2,16
 6ac:	000be583          	lwu	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	d9fff0ef          	jal	ra,450 <printint>
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b571                	j	546 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4641                	li	a2,16
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	d87ff0ef          	jal	ra,450 <printint>
        i += 1;
 6ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 1;
 6d4:	bd8d                	j	546 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6d6:	008b8793          	addi	a5,s7,8
 6da:	f8f43423          	sd	a5,-120(s0)
 6de:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e2:	03000593          	li	a1,48
 6e6:	855a                	mv	a0,s6
 6e8:	d4bff0ef          	jal	ra,432 <putc>
  putc(fd, 'x');
 6ec:	07800593          	li	a1,120
 6f0:	855a                	mv	a0,s6
 6f2:	d41ff0ef          	jal	ra,432 <putc>
 6f6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f8:	03c9d793          	srli	a5,s3,0x3c
 6fc:	97e6                	add	a5,a5,s9
 6fe:	0007c583          	lbu	a1,0(a5)
 702:	855a                	mv	a0,s6
 704:	d2fff0ef          	jal	ra,432 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 708:	0992                	slli	s3,s3,0x4
 70a:	397d                	addiw	s2,s2,-1
 70c:	fe0916e3          	bnez	s2,6f8 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 710:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 714:	4981                	li	s3,0
 716:	bd05                	j	546 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 718:	008b8913          	addi	s2,s7,8
 71c:	000bc583          	lbu	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	d11ff0ef          	jal	ra,432 <putc>
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	bd31                	j	546 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 72c:	008b8993          	addi	s3,s7,8
 730:	000bb903          	ld	s2,0(s7)
 734:	00090f63          	beqz	s2,752 <vprintf+0x266>
        for(; *s; s++)
 738:	00094583          	lbu	a1,0(s2)
 73c:	c195                	beqz	a1,760 <vprintf+0x274>
          putc(fd, *s);
 73e:	855a                	mv	a0,s6
 740:	cf3ff0ef          	jal	ra,432 <putc>
        for(; *s; s++)
 744:	0905                	addi	s2,s2,1
 746:	00094583          	lbu	a1,0(s2)
 74a:	f9f5                	bnez	a1,73e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 74c:	8bce                	mv	s7,s3
      state = 0;
 74e:	4981                	li	s3,0
 750:	bbdd                	j	546 <vprintf+0x5a>
          s = "(null)";
 752:	00000917          	auipc	s2,0x0
 756:	27690913          	addi	s2,s2,630 # 9c8 <malloc+0x160>
        for(; *s; s++)
 75a:	02800593          	li	a1,40
 75e:	b7c5                	j	73e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 760:	8bce                	mv	s7,s3
      state = 0;
 762:	4981                	li	s3,0
 764:	b3cd                	j	546 <vprintf+0x5a>
    }
  }
}
 766:	70e6                	ld	ra,120(sp)
 768:	7446                	ld	s0,112(sp)
 76a:	74a6                	ld	s1,104(sp)
 76c:	7906                	ld	s2,96(sp)
 76e:	69e6                	ld	s3,88(sp)
 770:	6a46                	ld	s4,80(sp)
 772:	6aa6                	ld	s5,72(sp)
 774:	6b06                	ld	s6,64(sp)
 776:	7be2                	ld	s7,56(sp)
 778:	7c42                	ld	s8,48(sp)
 77a:	7ca2                	ld	s9,40(sp)
 77c:	7d02                	ld	s10,32(sp)
 77e:	6de2                	ld	s11,24(sp)
 780:	6109                	addi	sp,sp,128
 782:	8082                	ret

0000000000000784 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 784:	715d                	addi	sp,sp,-80
 786:	ec06                	sd	ra,24(sp)
 788:	e822                	sd	s0,16(sp)
 78a:	1000                	addi	s0,sp,32
 78c:	e010                	sd	a2,0(s0)
 78e:	e414                	sd	a3,8(s0)
 790:	e818                	sd	a4,16(s0)
 792:	ec1c                	sd	a5,24(s0)
 794:	03043023          	sd	a6,32(s0)
 798:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a0:	8622                	mv	a2,s0
 7a2:	d4bff0ef          	jal	ra,4ec <vprintf>
}
 7a6:	60e2                	ld	ra,24(sp)
 7a8:	6442                	ld	s0,16(sp)
 7aa:	6161                	addi	sp,sp,80
 7ac:	8082                	ret

00000000000007ae <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7ae:	711d                	addi	sp,sp,-96
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e40c                	sd	a1,8(s0)
 7b8:	e810                	sd	a2,16(s0)
 7ba:	ec14                	sd	a3,24(s0)
 7bc:	f018                	sd	a4,32(s0)
 7be:	f41c                	sd	a5,40(s0)
 7c0:	03043823          	sd	a6,48(s0)
 7c4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c8:	00840613          	addi	a2,s0,8
 7cc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d0:	85aa                	mv	a1,a0
 7d2:	4505                	li	a0,1
 7d4:	d19ff0ef          	jal	ra,4ec <vprintf>
}
 7d8:	60e2                	ld	ra,24(sp)
 7da:	6442                	ld	s0,16(sp)
 7dc:	6125                	addi	sp,sp,96
 7de:	8082                	ret

00000000000007e0 <free>:
 *   无
 */

void
free(void *ap)
{
 7e0:	1141                	addi	sp,sp,-16
 7e2:	e422                	sd	s0,8(sp)
 7e4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7e6:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ea:	00001797          	auipc	a5,0x1
 7ee:	8267b783          	ld	a5,-2010(a5) # 1010 <freep>
 7f2:	a805                	j	822 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f4:	4618                	lw	a4,8(a2)
 7f6:	9db9                	addw	a1,a1,a4
 7f8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fc:	6398                	ld	a4,0(a5)
 7fe:	6318                	ld	a4,0(a4)
 800:	fee53823          	sd	a4,-16(a0)
 804:	a091                	j	848 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 806:	ff852703          	lw	a4,-8(a0)
 80a:	9e39                	addw	a2,a2,a4
 80c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 80e:	ff053703          	ld	a4,-16(a0)
 812:	e398                	sd	a4,0(a5)
 814:	a099                	j	85a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 816:	6398                	ld	a4,0(a5)
 818:	00e7e463          	bltu	a5,a4,820 <free+0x40>
 81c:	00e6ea63          	bltu	a3,a4,830 <free+0x50>
{
 820:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 822:	fed7fae3          	bgeu	a5,a3,816 <free+0x36>
 826:	6398                	ld	a4,0(a5)
 828:	00e6e463          	bltu	a3,a4,830 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82c:	fee7eae3          	bltu	a5,a4,820 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 830:	ff852583          	lw	a1,-8(a0)
 834:	6390                	ld	a2,0(a5)
 836:	02059713          	slli	a4,a1,0x20
 83a:	9301                	srli	a4,a4,0x20
 83c:	0712                	slli	a4,a4,0x4
 83e:	9736                	add	a4,a4,a3
 840:	fae60ae3          	beq	a2,a4,7f4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 844:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 848:	4790                	lw	a2,8(a5)
 84a:	02061713          	slli	a4,a2,0x20
 84e:	9301                	srli	a4,a4,0x20
 850:	0712                	slli	a4,a4,0x4
 852:	973e                	add	a4,a4,a5
 854:	fae689e3          	beq	a3,a4,806 <free+0x26>
  } else
    p->s.ptr = bp;
 858:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 85a:	00000717          	auipc	a4,0x0
 85e:	7af73b23          	sd	a5,1974(a4) # 1010 <freep>
}
 862:	6422                	ld	s0,8(sp)
 864:	0141                	addi	sp,sp,16
 866:	8082                	ret

0000000000000868 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 868:	7139                	addi	sp,sp,-64
 86a:	fc06                	sd	ra,56(sp)
 86c:	f822                	sd	s0,48(sp)
 86e:	f426                	sd	s1,40(sp)
 870:	f04a                	sd	s2,32(sp)
 872:	ec4e                	sd	s3,24(sp)
 874:	e852                	sd	s4,16(sp)
 876:	e456                	sd	s5,8(sp)
 878:	e05a                	sd	s6,0(sp)
 87a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87c:	02051493          	slli	s1,a0,0x20
 880:	9081                	srli	s1,s1,0x20
 882:	04bd                	addi	s1,s1,15
 884:	8091                	srli	s1,s1,0x4
 886:	0014899b          	addiw	s3,s1,1
 88a:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 88c:	00000517          	auipc	a0,0x0
 890:	78453503          	ld	a0,1924(a0) # 1010 <freep>
 894:	c515                	beqz	a0,8c0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 896:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 898:	4798                	lw	a4,8(a5)
 89a:	02977f63          	bgeu	a4,s1,8d8 <malloc+0x70>
 89e:	8a4e                	mv	s4,s3
 8a0:	0009871b          	sext.w	a4,s3
 8a4:	6685                	lui	a3,0x1
 8a6:	00d77363          	bgeu	a4,a3,8ac <malloc+0x44>
 8aa:	6a05                	lui	s4,0x1
 8ac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8b0:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8b4:	00000917          	auipc	s2,0x0
 8b8:	75c90913          	addi	s2,s2,1884 # 1010 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8bc:	5afd                	li	s5,-1
 8be:	a0bd                	j	92c <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8c0:	00000797          	auipc	a5,0x0
 8c4:	76078793          	addi	a5,a5,1888 # 1020 <base>
 8c8:	00000717          	auipc	a4,0x0
 8cc:	74f73423          	sd	a5,1864(a4) # 1010 <freep>
 8d0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8d6:	b7e1                	j	89e <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8d8:	02e48b63          	beq	s1,a4,90e <malloc+0xa6>
        p->s.size -= nunits;
 8dc:	4137073b          	subw	a4,a4,s3
 8e0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e2:	1702                	slli	a4,a4,0x20
 8e4:	9301                	srli	a4,a4,0x20
 8e6:	0712                	slli	a4,a4,0x4
 8e8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ea:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8ee:	00000717          	auipc	a4,0x0
 8f2:	72a73123          	sd	a0,1826(a4) # 1010 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 8f6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 8fa:	70e2                	ld	ra,56(sp)
 8fc:	7442                	ld	s0,48(sp)
 8fe:	74a2                	ld	s1,40(sp)
 900:	7902                	ld	s2,32(sp)
 902:	69e2                	ld	s3,24(sp)
 904:	6a42                	ld	s4,16(sp)
 906:	6aa2                	ld	s5,8(sp)
 908:	6b02                	ld	s6,0(sp)
 90a:	6121                	addi	sp,sp,64
 90c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90e:	6398                	ld	a4,0(a5)
 910:	e118                	sd	a4,0(a0)
 912:	bff1                	j	8ee <malloc+0x86>
  hp->s.size = nu;
 914:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 918:	0541                	addi	a0,a0,16
 91a:	ec7ff0ef          	jal	ra,7e0 <free>
  return freep;
 91e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 922:	dd61                	beqz	a0,8fa <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 926:	4798                	lw	a4,8(a5)
 928:	fa9778e3          	bgeu	a4,s1,8d8 <malloc+0x70>
    if(p == freep)
 92c:	00093703          	ld	a4,0(s2)
 930:	853e                	mv	a0,a5
 932:	fef719e3          	bne	a4,a5,924 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 936:	8552                	mv	a0,s4
 938:	9e7ff0ef          	jal	ra,31e <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 93c:	fd551ce3          	bne	a0,s5,914 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 940:	4501                	li	a0,0
 942:	bf65                	j	8fa <malloc+0x92>
