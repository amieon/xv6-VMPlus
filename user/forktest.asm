
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	12a000ef          	jal	ra,136 <strlen>
  10:	0005061b          	sext.w	a2,a0
  14:	85a6                	mv	a1,s1
  16:	4505                	li	a0,1
  18:	37c000ef          	jal	ra,394 <write>
}
  1c:	60e2                	ld	ra,24(sp)
  1e:	6442                	ld	s0,16(sp)
  20:	64a2                	ld	s1,8(sp)
  22:	6105                	addi	sp,sp,32
  24:	8082                	ret

0000000000000026 <forktest>:

void
forktest(void)
{
  26:	1101                	addi	sp,sp,-32
  28:	ec06                	sd	ra,24(sp)
  2a:	e822                	sd	s0,16(sp)
  2c:	e426                	sd	s1,8(sp)
  2e:	e04a                	sd	s2,0(sp)
  30:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  32:	00000517          	auipc	a0,0x0
  36:	42650513          	addi	a0,a0,1062 # 458 <vmstats+0xc>
  3a:	fc7ff0ef          	jal	ra,0 <print>

  for(n=0; n<N; n++){
  3e:	4481                	li	s1,0
  40:	3e800913          	li	s2,1000
    pid = fork();
  44:	328000ef          	jal	ra,36c <fork>
    if(pid < 0)
  48:	02054163          	bltz	a0,6a <forktest+0x44>
      break;
    if(pid == 0)
  4c:	cd09                	beqz	a0,66 <forktest+0x40>
  for(n=0; n<N; n++){
  4e:	2485                	addiw	s1,s1,1
  50:	ff249ae3          	bne	s1,s2,44 <forktest+0x1e>
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  54:	00000517          	auipc	a0,0x0
  58:	41450513          	addi	a0,a0,1044 # 468 <vmstats+0x1c>
  5c:	fa5ff0ef          	jal	ra,0 <print>
    exit(1);
  60:	4505                	li	a0,1
  62:	312000ef          	jal	ra,374 <exit>
      exit(0);
  66:	30e000ef          	jal	ra,374 <exit>
  if(n == N){
  6a:	3e800793          	li	a5,1000
  6e:	fef483e3          	beq	s1,a5,54 <forktest+0x2e>
  }

  for(; n > 0; n--){
  72:	00905963          	blez	s1,84 <forktest+0x5e>
    if(wait(0) < 0){
  76:	4501                	li	a0,0
  78:	304000ef          	jal	ra,37c <wait>
  7c:	02054663          	bltz	a0,a8 <forktest+0x82>
  for(; n > 0; n--){
  80:	34fd                	addiw	s1,s1,-1
  82:	f8f5                	bnez	s1,76 <forktest+0x50>
      print("wait stopped early\n");
      exit(1);
    }
  }

  if(wait(0) != -1){
  84:	4501                	li	a0,0
  86:	2f6000ef          	jal	ra,37c <wait>
  8a:	57fd                	li	a5,-1
  8c:	02f51763          	bne	a0,a5,ba <forktest+0x94>
    print("wait got too many\n");
    exit(1);
  }

  print("fork test OK\n");
  90:	00000517          	auipc	a0,0x0
  94:	42850513          	addi	a0,a0,1064 # 4b8 <vmstats+0x6c>
  98:	f69ff0ef          	jal	ra,0 <print>
}
  9c:	60e2                	ld	ra,24(sp)
  9e:	6442                	ld	s0,16(sp)
  a0:	64a2                	ld	s1,8(sp)
  a2:	6902                	ld	s2,0(sp)
  a4:	6105                	addi	sp,sp,32
  a6:	8082                	ret
      print("wait stopped early\n");
  a8:	00000517          	auipc	a0,0x0
  ac:	3e050513          	addi	a0,a0,992 # 488 <vmstats+0x3c>
  b0:	f51ff0ef          	jal	ra,0 <print>
      exit(1);
  b4:	4505                	li	a0,1
  b6:	2be000ef          	jal	ra,374 <exit>
    print("wait got too many\n");
  ba:	00000517          	auipc	a0,0x0
  be:	3e650513          	addi	a0,a0,998 # 4a0 <vmstats+0x54>
  c2:	f3fff0ef          	jal	ra,0 <print>
    exit(1);
  c6:	4505                	li	a0,1
  c8:	2ac000ef          	jal	ra,374 <exit>

00000000000000cc <main>:

int
main(void)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
  forktest();
  d4:	f53ff0ef          	jal	ra,26 <forktest>
  exit(0);
  d8:	4501                	li	a0,0
  da:	29a000ef          	jal	ra,374 <exit>

00000000000000de <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e406                	sd	ra,8(sp)
  e2:	e022                	sd	s0,0(sp)
  e4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e6:	fe7ff0ef          	jal	ra,cc <main>
  exit(r);
  ea:	28a000ef          	jal	ra,374 <exit>

00000000000000ee <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f4:	87aa                	mv	a5,a0
  f6:	0585                	addi	a1,a1,1
  f8:	0785                	addi	a5,a5,1
  fa:	fff5c703          	lbu	a4,-1(a1)
  fe:	fee78fa3          	sb	a4,-1(a5)
 102:	fb75                	bnez	a4,f6 <strcpy+0x8>
    ;
  return os;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb91                	beqz	a5,128 <strcmp+0x1e>
 116:	0005c703          	lbu	a4,0(a1)
 11a:	00f71763          	bne	a4,a5,128 <strcmp+0x1e>
    p++, q++;
 11e:	0505                	addi	a0,a0,1
 120:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 122:	00054783          	lbu	a5,0(a0)
 126:	fbe5                	bnez	a5,116 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 128:	0005c503          	lbu	a0,0(a1)
}
 12c:	40a7853b          	subw	a0,a5,a0
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cf91                	beqz	a5,15c <strlen+0x26>
 142:	0505                	addi	a0,a0,1
 144:	87aa                	mv	a5,a0
 146:	4685                	li	a3,1
 148:	9e89                	subw	a3,a3,a0
 14a:	00f6853b          	addw	a0,a3,a5
 14e:	0785                	addi	a5,a5,1
 150:	fff7c703          	lbu	a4,-1(a5)
 154:	fb7d                	bnez	a4,14a <strlen+0x14>
    ;
  return n;
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  for(n = 0; s[n]; n++)
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strlen+0x20>

0000000000000160 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 166:	ca19                	beqz	a2,17c <memset+0x1c>
 168:	87aa                	mv	a5,a0
 16a:	1602                	slli	a2,a2,0x20
 16c:	9201                	srli	a2,a2,0x20
 16e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 172:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 176:	0785                	addi	a5,a5,1
 178:	fee79de3          	bne	a5,a4,172 <memset+0x12>
  }
  return dst;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  for(; *s; s++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cb99                	beqz	a5,1a2 <strchr+0x20>
    if(*s == c)
 18e:	00f58763          	beq	a1,a5,19c <strchr+0x1a>
  for(; *s; s++)
 192:	0505                	addi	a0,a0,1
 194:	00054783          	lbu	a5,0(a0)
 198:	fbfd                	bnez	a5,18e <strchr+0xc>
      return (char*)s;
  return 0;
 19a:	4501                	li	a0,0
}
 19c:	6422                	ld	s0,8(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret
  return 0;
 1a2:	4501                	li	a0,0
 1a4:	bfe5                	j	19c <strchr+0x1a>

00000000000001a6 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 1a6:	711d                	addi	sp,sp,-96
 1a8:	ec86                	sd	ra,88(sp)
 1aa:	e8a2                	sd	s0,80(sp)
 1ac:	e4a6                	sd	s1,72(sp)
 1ae:	e0ca                	sd	s2,64(sp)
 1b0:	fc4e                	sd	s3,56(sp)
 1b2:	f852                	sd	s4,48(sp)
 1b4:	f456                	sd	s5,40(sp)
 1b6:	f05a                	sd	s6,32(sp)
 1b8:	ec5e                	sd	s7,24(sp)
 1ba:	1080                	addi	s0,sp,96
 1bc:	8baa                	mv	s7,a0
 1be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c0:	892a                	mv	s2,a0
 1c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1c4:	4aa9                	li	s5,10
 1c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c8:	89a6                	mv	s3,s1
 1ca:	2485                	addiw	s1,s1,1
 1cc:	0344d663          	bge	s1,s4,1f8 <gets+0x52>
    cc = read(0, &c, 1);
 1d0:	4605                	li	a2,1
 1d2:	faf40593          	addi	a1,s0,-81
 1d6:	4501                	li	a0,0
 1d8:	1b4000ef          	jal	ra,38c <read>
    if(cc < 1)
 1dc:	00a05e63          	blez	a0,1f8 <gets+0x52>
    buf[i++] = c;
 1e0:	faf44783          	lbu	a5,-81(s0)
 1e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e8:	01578763          	beq	a5,s5,1f6 <gets+0x50>
 1ec:	0905                	addi	s2,s2,1
 1ee:	fd679de3          	bne	a5,s6,1c8 <gets+0x22>
  for(i=0; i+1 < max; ){
 1f2:	89a6                	mv	s3,s1
 1f4:	a011                	j	1f8 <gets+0x52>
 1f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f8:	99de                	add	s3,s3,s7
 1fa:	00098023          	sb	zero,0(s3)
  return buf;
}
 1fe:	855e                	mv	a0,s7
 200:	60e6                	ld	ra,88(sp)
 202:	6446                	ld	s0,80(sp)
 204:	64a6                	ld	s1,72(sp)
 206:	6906                	ld	s2,64(sp)
 208:	79e2                	ld	s3,56(sp)
 20a:	7a42                	ld	s4,48(sp)
 20c:	7aa2                	ld	s5,40(sp)
 20e:	7b02                	ld	s6,32(sp)
 210:	6be2                	ld	s7,24(sp)
 212:	6125                	addi	sp,sp,96
 214:	8082                	ret

0000000000000216 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 216:	1101                	addi	sp,sp,-32
 218:	ec06                	sd	ra,24(sp)
 21a:	e822                	sd	s0,16(sp)
 21c:	e426                	sd	s1,8(sp)
 21e:	e04a                	sd	s2,0(sp)
 220:	1000                	addi	s0,sp,32
 222:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 224:	4581                	li	a1,0
 226:	18e000ef          	jal	ra,3b4 <open>
  if(fd < 0)
 22a:	02054163          	bltz	a0,24c <stat+0x36>
 22e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 230:	85ca                	mv	a1,s2
 232:	19a000ef          	jal	ra,3cc <fstat>
 236:	892a                	mv	s2,a0
  close(fd);
 238:	8526                	mv	a0,s1
 23a:	162000ef          	jal	ra,39c <close>
  return r;
}
 23e:	854a                	mv	a0,s2
 240:	60e2                	ld	ra,24(sp)
 242:	6442                	ld	s0,16(sp)
 244:	64a2                	ld	s1,8(sp)
 246:	6902                	ld	s2,0(sp)
 248:	6105                	addi	sp,sp,32
 24a:	8082                	ret
    return -1;
 24c:	597d                	li	s2,-1
 24e:	bfc5                	j	23e <stat+0x28>

0000000000000250 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 256:	00054603          	lbu	a2,0(a0)
 25a:	fd06079b          	addiw	a5,a2,-48
 25e:	0ff7f793          	andi	a5,a5,255
 262:	4725                	li	a4,9
 264:	02f76963          	bltu	a4,a5,296 <atoi+0x46>
 268:	86aa                	mv	a3,a0
  n = 0;
 26a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 26c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 26e:	0685                	addi	a3,a3,1
 270:	0025179b          	slliw	a5,a0,0x2
 274:	9fa9                	addw	a5,a5,a0
 276:	0017979b          	slliw	a5,a5,0x1
 27a:	9fb1                	addw	a5,a5,a2
 27c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 280:	0006c603          	lbu	a2,0(a3)
 284:	fd06071b          	addiw	a4,a2,-48
 288:	0ff77713          	andi	a4,a4,255
 28c:	fee5f1e3          	bgeu	a1,a4,26e <atoi+0x1e>
  return n;
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  n = 0;
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <atoi+0x40>

000000000000029a <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a0:	02b57463          	bgeu	a0,a1,2c8 <memmove+0x2e>
    while(n-- > 0)
 2a4:	00c05f63          	blez	a2,2c2 <memmove+0x28>
 2a8:	1602                	slli	a2,a2,0x20
 2aa:	9201                	srli	a2,a2,0x20
 2ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b2:	0585                	addi	a1,a1,1
 2b4:	0705                	addi	a4,a4,1
 2b6:	fff5c683          	lbu	a3,-1(a1)
 2ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2be:	fee79ae3          	bne	a5,a4,2b2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
    dst += n;
 2c8:	00c50733          	add	a4,a0,a2
    src += n;
 2cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ce:	fec05ae3          	blez	a2,2c2 <memmove+0x28>
 2d2:	fff6079b          	addiw	a5,a2,-1
 2d6:	1782                	slli	a5,a5,0x20
 2d8:	9381                	srli	a5,a5,0x20
 2da:	fff7c793          	not	a5,a5
 2de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e0:	15fd                	addi	a1,a1,-1
 2e2:	177d                	addi	a4,a4,-1
 2e4:	0005c683          	lbu	a3,0(a1)
 2e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ec:	fee79ae3          	bne	a5,a4,2e0 <memmove+0x46>
 2f0:	bfc9                	j	2c2 <memmove+0x28>

00000000000002f2 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f8:	ca05                	beqz	a2,328 <memcmp+0x36>
 2fa:	fff6069b          	addiw	a3,a2,-1
 2fe:	1682                	slli	a3,a3,0x20
 300:	9281                	srli	a3,a3,0x20
 302:	0685                	addi	a3,a3,1
 304:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 306:	00054783          	lbu	a5,0(a0)
 30a:	0005c703          	lbu	a4,0(a1)
 30e:	00e79863          	bne	a5,a4,31e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 312:	0505                	addi	a0,a0,1
    p2++;
 314:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 316:	fed518e3          	bne	a0,a3,306 <memcmp+0x14>
  }
  return 0;
 31a:	4501                	li	a0,0
 31c:	a019                	j	322 <memcmp+0x30>
      return *p1 - *p2;
 31e:	40e7853b          	subw	a0,a5,a4
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
  return 0;
 328:	4501                	li	a0,0
 32a:	bfe5                	j	322 <memcmp+0x30>

000000000000032c <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e406                	sd	ra,8(sp)
 330:	e022                	sd	s0,0(sp)
 332:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 334:	f67ff0ef          	jal	ra,29a <memmove>
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 340:	1141                	addi	sp,sp,-16
 342:	e406                	sd	ra,8(sp)
 344:	e022                	sd	s0,0(sp)
 346:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 348:	4585                	li	a1,1
 34a:	0b2000ef          	jal	ra,3fc <sys_sbrk>
}
 34e:	60a2                	ld	ra,8(sp)
 350:	6402                	ld	s0,0(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 356:	1141                	addi	sp,sp,-16
 358:	e406                	sd	ra,8(sp)
 35a:	e022                	sd	s0,0(sp)
 35c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 35e:	4589                	li	a1,2
 360:	09c000ef          	jal	ra,3fc <sys_sbrk>
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 36c:	4885                	li	a7,1
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <exit>:
.global exit
exit:
 li a7, SYS_exit
 374:	4889                	li	a7,2
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <wait>:
.global wait
wait:
 li a7, SYS_wait
 37c:	488d                	li	a7,3
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 384:	4891                	li	a7,4
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <read>:
.global read
read:
 li a7, SYS_read
 38c:	4895                	li	a7,5
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <write>:
.global write
write:
 li a7, SYS_write
 394:	48c1                	li	a7,16
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <close>:
.global close
close:
 li a7, SYS_close
 39c:	48d5                	li	a7,21
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a4:	4899                	li	a7,6
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ac:	489d                	li	a7,7
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <open>:
.global open
open:
 li a7, SYS_open
 3b4:	48bd                	li	a7,15
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3bc:	48c5                	li	a7,17
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c4:	48c9                	li	a7,18
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3cc:	48a1                	li	a7,8
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <link>:
.global link
link:
 li a7, SYS_link
 3d4:	48cd                	li	a7,19
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3dc:	48d1                	li	a7,20
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e4:	48a5                	li	a7,9
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ec:	48a9                	li	a7,10
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f4:	48ad                	li	a7,11
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3fc:	48b1                	li	a7,12
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <pause>:
.global pause
pause:
 li a7, SYS_pause
 404:	48b5                	li	a7,13
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 40c:	48b9                	li	a7,14
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 414:	48d9                	li	a7,22
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 41c:	48dd                	li	a7,23
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 424:	48e1                	li	a7,24
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 42c:	48e5                	li	a7,25
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 434:	48e9                	li	a7,26
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 43c:	48ed                	li	a7,27
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 444:	48f1                	li	a7,28
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 44c:	48f5                	li	a7,29
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret
