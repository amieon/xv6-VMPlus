
user/_cow_multipage:     file format elf64-littleriscv


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
   c:	310000ef          	jal	ra,31c <sbrk>
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
  28:	0ff7f793          	andi	a5,a5,255
  2c:	9536                	add	a0,a0,a3
  2e:	fee79ae3          	bne	a5,a4,22 <main+0x22>

  int pid = fork();
  32:	316000ef          	jal	ra,348 <fork>
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
  4c:	0ff7f793          	andi	a5,a5,255
  50:	94b6                	add	s1,s1,a3
  52:	fee79ae3          	bne	a5,a4,46 <main+0x46>
    printf("child wrote %d pages\n", NP);
  56:	45a1                	li	a1,8
  58:	00001517          	auipc	a0,0x1
  5c:	8f850513          	addi	a0,a0,-1800 # 950 <malloc+0xea>
  60:	74c000ef          	jal	ra,7ac <printf>
    exit(0);
  64:	4501                	li	a0,0
  66:	2ea000ef          	jal	ra,350 <exit>
  if(p == (char*)-1) exit(1);
  6a:	4505                	li	a0,1
  6c:	2e4000ef          	jal	ra,350 <exit>
  if(pid < 0) exit(1);
  70:	4505                	li	a0,1
  72:	2de000ef          	jal	ra,350 <exit>
  }

  wait(0);
  76:	4501                	li	a0,0
  78:	2e0000ef          	jal	ra,358 <wait>
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
  9a:	8fa50513          	addi	a0,a0,-1798 # 990 <malloc+0x12a>
  9e:	70e000ef          	jal	ra,7ac <printf>
  exit(0);
  a2:	4501                	li	a0,0
  a4:	2ac000ef          	jal	ra,350 <exit>
      printf("FAIL: parent page %d changed to %c\n", k, p[k*4096]);
  a8:	00001517          	auipc	a0,0x1
  ac:	8c050513          	addi	a0,a0,-1856 # 968 <malloc+0x102>
  b0:	6fc000ef          	jal	ra,7ac <printf>
      exit(1);
  b4:	4505                	li	a0,1
  b6:	29a000ef          	jal	ra,350 <exit>

00000000000000ba <start>:
 *   argv - 命令行参数数组
 */

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
  c6:	28a000ef          	jal	ra,350 <exit>

00000000000000ca <strcpy>:
 *   目标字符串s的指针
 */

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
 *   负数 - p小于q
 */

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
 *   字符串s的长度
 */

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
 *   目标内存区域dst的指针
 */

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
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

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
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

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
 1b4:	1b4000ef          	jal	ra,368 <read>
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
 *   -1 - 失败
 */

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
 202:	18e000ef          	jal	ra,390 <open>
  if(fd < 0)
 206:	02054163          	bltz	a0,228 <stat+0x36>
 20a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20c:	85ca                	mv	a1,s2
 20e:	19a000ef          	jal	ra,3a8 <fstat>
 212:	892a                	mv	s2,a0
  close(fd);
 214:	8526                	mv	a0,s1
 216:	162000ef          	jal	ra,378 <close>
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
 *   转换后的整数
 */

int
atoi(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 232:	00054603          	lbu	a2,0(a0)
 236:	fd06079b          	addiw	a5,a2,-48
 23a:	0ff7f793          	andi	a5,a5,255
 23e:	4725                	li	a4,9
 240:	02f76963          	bltu	a4,a5,272 <atoi+0x46>
 244:	86aa                	mv	a3,a0
  n = 0;
 246:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 248:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 24a:	0685                	addi	a3,a3,1
 24c:	0025179b          	slliw	a5,a0,0x2
 250:	9fa9                	addw	a5,a5,a0
 252:	0017979b          	slliw	a5,a5,0x1
 256:	9fb1                	addw	a5,a5,a2
 258:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25c:	0006c603          	lbu	a2,0(a3) # 1000 <freep>
 260:	fd06071b          	addiw	a4,a2,-48
 264:	0ff77713          	andi	a4,a4,255
 268:	fee5f1e3          	bgeu	a1,a4,24a <atoi+0x1e>
  return n;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  n = 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <atoi+0x40>

0000000000000276 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27c:	02b57463          	bgeu	a0,a1,2a4 <memmove+0x2e>
    while(n-- > 0)
 280:	00c05f63          	blez	a2,29e <memmove+0x28>
 284:	1602                	slli	a2,a2,0x20
 286:	9201                	srli	a2,a2,0x20
 288:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28c:	872a                	mv	a4,a0
      *dst++ = *src++;
 28e:	0585                	addi	a1,a1,1
 290:	0705                	addi	a4,a4,1
 292:	fff5c683          	lbu	a3,-1(a1)
 296:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29a:	fee79ae3          	bne	a5,a4,28e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
    dst += n;
 2a4:	00c50733          	add	a4,a0,a2
    src += n;
 2a8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2aa:	fec05ae3          	blez	a2,29e <memmove+0x28>
 2ae:	fff6079b          	addiw	a5,a2,-1
 2b2:	1782                	slli	a5,a5,0x20
 2b4:	9381                	srli	a5,a5,0x20
 2b6:	fff7c793          	not	a5,a5
 2ba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2bc:	15fd                	addi	a1,a1,-1
 2be:	177d                	addi	a4,a4,-1
 2c0:	0005c683          	lbu	a3,0(a1)
 2c4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c8:	fee79ae3          	bne	a5,a4,2bc <memmove+0x46>
 2cc:	bfc9                	j	29e <memmove+0x28>

00000000000002ce <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d4:	ca05                	beqz	a2,304 <memcmp+0x36>
 2d6:	fff6069b          	addiw	a3,a2,-1
 2da:	1682                	slli	a3,a3,0x20
 2dc:	9281                	srli	a3,a3,0x20
 2de:	0685                	addi	a3,a3,1
 2e0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	0005c703          	lbu	a4,0(a1)
 2ea:	00e79863          	bne	a5,a4,2fa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ee:	0505                	addi	a0,a0,1
    p2++;
 2f0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f2:	fed518e3          	bne	a0,a3,2e2 <memcmp+0x14>
  }
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	a019                	j	2fe <memcmp+0x30>
      return *p1 - *p2;
 2fa:	40e7853b          	subw	a0,a5,a4
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  return 0;
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <memcmp+0x30>

0000000000000308 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 310:	f67ff0ef          	jal	ra,276 <memmove>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 324:	4585                	li	a1,1
 326:	0b2000ef          	jal	ra,3d8 <sys_sbrk>
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 332:	1141                	addi	sp,sp,-16
 334:	e406                	sd	ra,8(sp)
 336:	e022                	sd	s0,0(sp)
 338:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 33a:	4589                	li	a1,2
 33c:	09c000ef          	jal	ra,3d8 <sys_sbrk>
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret

0000000000000348 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 348:	4885                	li	a7,1
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <exit>:
.global exit
exit:
 li a7, SYS_exit
 350:	4889                	li	a7,2
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <wait>:
.global wait
wait:
 li a7, SYS_wait
 358:	488d                	li	a7,3
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 360:	4891                	li	a7,4
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <read>:
.global read
read:
 li a7, SYS_read
 368:	4895                	li	a7,5
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <write>:
.global write
write:
 li a7, SYS_write
 370:	48c1                	li	a7,16
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <close>:
.global close
close:
 li a7, SYS_close
 378:	48d5                	li	a7,21
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <kill>:
.global kill
kill:
 li a7, SYS_kill
 380:	4899                	li	a7,6
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exec>:
.global exec
exec:
 li a7, SYS_exec
 388:	489d                	li	a7,7
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <open>:
.global open
open:
 li a7, SYS_open
 390:	48bd                	li	a7,15
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 398:	48c5                	li	a7,17
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a0:	48c9                	li	a7,18
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a8:	48a1                	li	a7,8
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <link>:
.global link
link:
 li a7, SYS_link
 3b0:	48cd                	li	a7,19
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b8:	48d1                	li	a7,20
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c0:	48a5                	li	a7,9
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c8:	48a9                	li	a7,10
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d0:	48ad                	li	a7,11
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3d8:	48b1                	li	a7,12
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e0:	48b5                	li	a7,13
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e8:	48b9                	li	a7,14
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3f0:	48d9                	li	a7,22
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3f8:	48dd                	li	a7,23
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 400:	48e1                	li	a7,24
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 408:	48e5                	li	a7,25
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 410:	48e9                	li	a7,26
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 418:	48ed                	li	a7,27
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 420:	48f1                	li	a7,28
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 428:	48f5                	li	a7,29
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 430:	1101                	addi	sp,sp,-32
 432:	ec06                	sd	ra,24(sp)
 434:	e822                	sd	s0,16(sp)
 436:	1000                	addi	s0,sp,32
 438:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43c:	4605                	li	a2,1
 43e:	fef40593          	addi	a1,s0,-17
 442:	f2fff0ef          	jal	ra,370 <write>
}
 446:	60e2                	ld	ra,24(sp)
 448:	6442                	ld	s0,16(sp)
 44a:	6105                	addi	sp,sp,32
 44c:	8082                	ret

000000000000044e <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 44e:	715d                	addi	sp,sp,-80
 450:	e486                	sd	ra,72(sp)
 452:	e0a2                	sd	s0,64(sp)
 454:	fc26                	sd	s1,56(sp)
 456:	f84a                	sd	s2,48(sp)
 458:	f44e                	sd	s3,40(sp)
 45a:	0880                	addi	s0,sp,80
 45c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 45e:	c299                	beqz	a3,464 <printint+0x16>
 460:	0805c163          	bltz	a1,4e2 <printint+0x94>
  neg = 0;
 464:	4881                	li	a7,0
 466:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 46a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 46c:	00000517          	auipc	a0,0x0
 470:	53450513          	addi	a0,a0,1332 # 9a0 <digits>
 474:	883e                	mv	a6,a5
 476:	2785                	addiw	a5,a5,1
 478:	02c5f733          	remu	a4,a1,a2
 47c:	972a                	add	a4,a4,a0
 47e:	00074703          	lbu	a4,0(a4)
 482:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 486:	872e                	mv	a4,a1
 488:	02c5d5b3          	divu	a1,a1,a2
 48c:	0685                	addi	a3,a3,1
 48e:	fec773e3          	bgeu	a4,a2,474 <printint+0x26>
  if(neg)
 492:	00088b63          	beqz	a7,4a8 <printint+0x5a>
    buf[i++] = '-';
 496:	fd040713          	addi	a4,s0,-48
 49a:	97ba                	add	a5,a5,a4
 49c:	02d00713          	li	a4,45
 4a0:	fee78423          	sb	a4,-24(a5)
 4a4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4a8:	02f05663          	blez	a5,4d4 <printint+0x86>
 4ac:	fb840713          	addi	a4,s0,-72
 4b0:	00f704b3          	add	s1,a4,a5
 4b4:	fff70993          	addi	s3,a4,-1
 4b8:	99be                	add	s3,s3,a5
 4ba:	37fd                	addiw	a5,a5,-1
 4bc:	1782                	slli	a5,a5,0x20
 4be:	9381                	srli	a5,a5,0x20
 4c0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4c4:	fff4c583          	lbu	a1,-1(s1)
 4c8:	854a                	mv	a0,s2
 4ca:	f67ff0ef          	jal	ra,430 <putc>
  while(--i >= 0)
 4ce:	14fd                	addi	s1,s1,-1
 4d0:	ff349ae3          	bne	s1,s3,4c4 <printint+0x76>
}
 4d4:	60a6                	ld	ra,72(sp)
 4d6:	6406                	ld	s0,64(sp)
 4d8:	74e2                	ld	s1,56(sp)
 4da:	7942                	ld	s2,48(sp)
 4dc:	79a2                	ld	s3,40(sp)
 4de:	6161                	addi	sp,sp,80
 4e0:	8082                	ret
    x = -xx;
 4e2:	40b005b3          	neg	a1,a1
    neg = 1;
 4e6:	4885                	li	a7,1
    x = -xx;
 4e8:	bfbd                	j	466 <printint+0x18>

00000000000004ea <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ea:	7119                	addi	sp,sp,-128
 4ec:	fc86                	sd	ra,120(sp)
 4ee:	f8a2                	sd	s0,112(sp)
 4f0:	f4a6                	sd	s1,104(sp)
 4f2:	f0ca                	sd	s2,96(sp)
 4f4:	ecce                	sd	s3,88(sp)
 4f6:	e8d2                	sd	s4,80(sp)
 4f8:	e4d6                	sd	s5,72(sp)
 4fa:	e0da                	sd	s6,64(sp)
 4fc:	fc5e                	sd	s7,56(sp)
 4fe:	f862                	sd	s8,48(sp)
 500:	f466                	sd	s9,40(sp)
 502:	f06a                	sd	s10,32(sp)
 504:	ec6e                	sd	s11,24(sp)
 506:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 508:	0005c903          	lbu	s2,0(a1)
 50c:	24090c63          	beqz	s2,764 <vprintf+0x27a>
 510:	8b2a                	mv	s6,a0
 512:	8a2e                	mv	s4,a1
 514:	8bb2                	mv	s7,a2
  state = 0;
 516:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 518:	4481                	li	s1,0
 51a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 51c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 520:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 524:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 528:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 52c:	00000c97          	auipc	s9,0x0
 530:	474c8c93          	addi	s9,s9,1140 # 9a0 <digits>
 534:	a005                	j	554 <vprintf+0x6a>
        putc(fd, c0);
 536:	85ca                	mv	a1,s2
 538:	855a                	mv	a0,s6
 53a:	ef7ff0ef          	jal	ra,430 <putc>
 53e:	a019                	j	544 <vprintf+0x5a>
    } else if(state == '%'){
 540:	03598263          	beq	s3,s5,564 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 544:	2485                	addiw	s1,s1,1
 546:	8726                	mv	a4,s1
 548:	009a07b3          	add	a5,s4,s1
 54c:	0007c903          	lbu	s2,0(a5)
 550:	20090a63          	beqz	s2,764 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 554:	0009079b          	sext.w	a5,s2
    if(state == 0){
 558:	fe0994e3          	bnez	s3,540 <vprintf+0x56>
      if(c0 == '%'){
 55c:	fd579de3          	bne	a5,s5,536 <vprintf+0x4c>
        state = '%';
 560:	89be                	mv	s3,a5
 562:	b7cd                	j	544 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 564:	c3c1                	beqz	a5,5e4 <vprintf+0xfa>
 566:	00ea06b3          	add	a3,s4,a4
 56a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 56e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 570:	c681                	beqz	a3,578 <vprintf+0x8e>
 572:	9752                	add	a4,a4,s4
 574:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 578:	03878e63          	beq	a5,s8,5b4 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 57c:	05a78863          	beq	a5,s10,5cc <vprintf+0xe2>
      } else if(c0 == 'u'){
 580:	0db78b63          	beq	a5,s11,656 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 584:	07800713          	li	a4,120
 588:	10e78d63          	beq	a5,a4,6a2 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 58c:	07000713          	li	a4,112
 590:	14e78263          	beq	a5,a4,6d4 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 594:	06300713          	li	a4,99
 598:	16e78f63          	beq	a5,a4,716 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 59c:	07300713          	li	a4,115
 5a0:	18e78563          	beq	a5,a4,72a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5a4:	05579063          	bne	a5,s5,5e4 <vprintf+0xfa>
        putc(fd, '%');
 5a8:	85d6                	mv	a1,s5
 5aa:	855a                	mv	a0,s6
 5ac:	e85ff0ef          	jal	ra,430 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bf49                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4685                	li	a3,1
 5ba:	4629                	li	a2,10
 5bc:	000ba583          	lw	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e8dff0ef          	jal	ra,44e <printint>
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bfad                	j	544 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5cc:	03868663          	beq	a3,s8,5f8 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d0:	05a68163          	beq	a3,s10,612 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5d4:	09b68d63          	beq	a3,s11,66e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d8:	03a68f63          	beq	a3,s10,616 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5dc:	07800793          	li	a5,120
 5e0:	0cf68d63          	beq	a3,a5,6ba <vprintf+0x1d0>
        putc(fd, '%');
 5e4:	85d6                	mv	a1,s5
 5e6:	855a                	mv	a0,s6
 5e8:	e49ff0ef          	jal	ra,430 <putc>
        putc(fd, c0);
 5ec:	85ca                	mv	a1,s2
 5ee:	855a                	mv	a0,s6
 5f0:	e41ff0ef          	jal	ra,430 <putc>
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b7b9                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f8:	008b8913          	addi	s2,s7,8
 5fc:	4685                	li	a3,1
 5fe:	4629                	li	a2,10
 600:	000bb583          	ld	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	e49ff0ef          	jal	ra,44e <printint>
        i += 1;
 60a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
        i += 1;
 610:	bf15                	j	544 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 612:	03860563          	beq	a2,s8,63c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 616:	07b60963          	beq	a2,s11,688 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 61a:	07800793          	li	a5,120
 61e:	fcf613e3          	bne	a2,a5,5e4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4641                	li	a2,16
 62a:	000bb583          	ld	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	e1fff0ef          	jal	ra,44e <printint>
        i += 2;
 634:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
        i += 2;
 63a:	b729                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63c:	008b8913          	addi	s2,s7,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000bb583          	ld	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	e05ff0ef          	jal	ra,44e <printint>
        i += 2;
 64e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
        i += 2;
 654:	bdc5                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 656:	008b8913          	addi	s2,s7,8
 65a:	4681                	li	a3,0
 65c:	4629                	li	a2,10
 65e:	000be583          	lwu	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	debff0ef          	jal	ra,44e <printint>
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
 66c:	bde1                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000bb583          	ld	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	dd3ff0ef          	jal	ra,44e <printint>
        i += 1;
 680:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
        i += 1;
 686:	bd7d                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	008b8913          	addi	s2,s7,8
 68c:	4681                	li	a3,0
 68e:	4629                	li	a2,10
 690:	000bb583          	ld	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	db9ff0ef          	jal	ra,44e <printint>
        i += 2;
 69a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 69c:	8bca                	mv	s7,s2
      state = 0;
 69e:	4981                	li	s3,0
        i += 2;
 6a0:	b555                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6a2:	008b8913          	addi	s2,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4641                	li	a2,16
 6aa:	000be583          	lwu	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	d9fff0ef          	jal	ra,44e <printint>
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b571                	j	544 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ba:	008b8913          	addi	s2,s7,8
 6be:	4681                	li	a3,0
 6c0:	4641                	li	a2,16
 6c2:	000bb583          	ld	a1,0(s7)
 6c6:	855a                	mv	a0,s6
 6c8:	d87ff0ef          	jal	ra,44e <printint>
        i += 1;
 6cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ce:	8bca                	mv	s7,s2
      state = 0;
 6d0:	4981                	li	s3,0
        i += 1;
 6d2:	bd8d                	j	544 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6d4:	008b8793          	addi	a5,s7,8
 6d8:	f8f43423          	sd	a5,-120(s0)
 6dc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e0:	03000593          	li	a1,48
 6e4:	855a                	mv	a0,s6
 6e6:	d4bff0ef          	jal	ra,430 <putc>
  putc(fd, 'x');
 6ea:	07800593          	li	a1,120
 6ee:	855a                	mv	a0,s6
 6f0:	d41ff0ef          	jal	ra,430 <putc>
 6f4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f6:	03c9d793          	srli	a5,s3,0x3c
 6fa:	97e6                	add	a5,a5,s9
 6fc:	0007c583          	lbu	a1,0(a5)
 700:	855a                	mv	a0,s6
 702:	d2fff0ef          	jal	ra,430 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 706:	0992                	slli	s3,s3,0x4
 708:	397d                	addiw	s2,s2,-1
 70a:	fe0916e3          	bnez	s2,6f6 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 70e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 712:	4981                	li	s3,0
 714:	bd05                	j	544 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 716:	008b8913          	addi	s2,s7,8
 71a:	000bc583          	lbu	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	d11ff0ef          	jal	ra,430 <putc>
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	bd31                	j	544 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 72a:	008b8993          	addi	s3,s7,8
 72e:	000bb903          	ld	s2,0(s7)
 732:	00090f63          	beqz	s2,750 <vprintf+0x266>
        for(; *s; s++)
 736:	00094583          	lbu	a1,0(s2)
 73a:	c195                	beqz	a1,75e <vprintf+0x274>
          putc(fd, *s);
 73c:	855a                	mv	a0,s6
 73e:	cf3ff0ef          	jal	ra,430 <putc>
        for(; *s; s++)
 742:	0905                	addi	s2,s2,1
 744:	00094583          	lbu	a1,0(s2)
 748:	f9f5                	bnez	a1,73c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 74a:	8bce                	mv	s7,s3
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bbdd                	j	544 <vprintf+0x5a>
          s = "(null)";
 750:	00000917          	auipc	s2,0x0
 754:	24890913          	addi	s2,s2,584 # 998 <malloc+0x132>
        for(; *s; s++)
 758:	02800593          	li	a1,40
 75c:	b7c5                	j	73c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 75e:	8bce                	mv	s7,s3
      state = 0;
 760:	4981                	li	s3,0
 762:	b3cd                	j	544 <vprintf+0x5a>
    }
  }
}
 764:	70e6                	ld	ra,120(sp)
 766:	7446                	ld	s0,112(sp)
 768:	74a6                	ld	s1,104(sp)
 76a:	7906                	ld	s2,96(sp)
 76c:	69e6                	ld	s3,88(sp)
 76e:	6a46                	ld	s4,80(sp)
 770:	6aa6                	ld	s5,72(sp)
 772:	6b06                	ld	s6,64(sp)
 774:	7be2                	ld	s7,56(sp)
 776:	7c42                	ld	s8,48(sp)
 778:	7ca2                	ld	s9,40(sp)
 77a:	7d02                	ld	s10,32(sp)
 77c:	6de2                	ld	s11,24(sp)
 77e:	6109                	addi	sp,sp,128
 780:	8082                	ret

0000000000000782 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 782:	715d                	addi	sp,sp,-80
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e010                	sd	a2,0(s0)
 78c:	e414                	sd	a3,8(s0)
 78e:	e818                	sd	a4,16(s0)
 790:	ec1c                	sd	a5,24(s0)
 792:	03043023          	sd	a6,32(s0)
 796:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 79e:	8622                	mv	a2,s0
 7a0:	d4bff0ef          	jal	ra,4ea <vprintf>
}
 7a4:	60e2                	ld	ra,24(sp)
 7a6:	6442                	ld	s0,16(sp)
 7a8:	6161                	addi	sp,sp,80
 7aa:	8082                	ret

00000000000007ac <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7ac:	711d                	addi	sp,sp,-96
 7ae:	ec06                	sd	ra,24(sp)
 7b0:	e822                	sd	s0,16(sp)
 7b2:	1000                	addi	s0,sp,32
 7b4:	e40c                	sd	a1,8(s0)
 7b6:	e810                	sd	a2,16(s0)
 7b8:	ec14                	sd	a3,24(s0)
 7ba:	f018                	sd	a4,32(s0)
 7bc:	f41c                	sd	a5,40(s0)
 7be:	03043823          	sd	a6,48(s0)
 7c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	00840613          	addi	a2,s0,8
 7ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ce:	85aa                	mv	a1,a0
 7d0:	4505                	li	a0,1
 7d2:	d19ff0ef          	jal	ra,4ea <vprintf>
}
 7d6:	60e2                	ld	ra,24(sp)
 7d8:	6442                	ld	s0,16(sp)
 7da:	6125                	addi	sp,sp,96
 7dc:	8082                	ret

00000000000007de <free>:
 *   无
 */

void
free(void *ap)
{
 7de:	1141                	addi	sp,sp,-16
 7e0:	e422                	sd	s0,8(sp)
 7e2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7e4:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	00001797          	auipc	a5,0x1
 7ec:	8187b783          	ld	a5,-2024(a5) # 1000 <freep>
 7f0:	a805                	j	820 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f2:	4618                	lw	a4,8(a2)
 7f4:	9db9                	addw	a1,a1,a4
 7f6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fa:	6398                	ld	a4,0(a5)
 7fc:	6318                	ld	a4,0(a4)
 7fe:	fee53823          	sd	a4,-16(a0)
 802:	a091                	j	846 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 804:	ff852703          	lw	a4,-8(a0)
 808:	9e39                	addw	a2,a2,a4
 80a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 80c:	ff053703          	ld	a4,-16(a0)
 810:	e398                	sd	a4,0(a5)
 812:	a099                	j	858 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 814:	6398                	ld	a4,0(a5)
 816:	00e7e463          	bltu	a5,a4,81e <free+0x40>
 81a:	00e6ea63          	bltu	a3,a4,82e <free+0x50>
{
 81e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	fed7fae3          	bgeu	a5,a3,814 <free+0x36>
 824:	6398                	ld	a4,0(a5)
 826:	00e6e463          	bltu	a3,a4,82e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82a:	fee7eae3          	bltu	a5,a4,81e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 82e:	ff852583          	lw	a1,-8(a0)
 832:	6390                	ld	a2,0(a5)
 834:	02059713          	slli	a4,a1,0x20
 838:	9301                	srli	a4,a4,0x20
 83a:	0712                	slli	a4,a4,0x4
 83c:	9736                	add	a4,a4,a3
 83e:	fae60ae3          	beq	a2,a4,7f2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 842:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 846:	4790                	lw	a2,8(a5)
 848:	02061713          	slli	a4,a2,0x20
 84c:	9301                	srli	a4,a4,0x20
 84e:	0712                	slli	a4,a4,0x4
 850:	973e                	add	a4,a4,a5
 852:	fae689e3          	beq	a3,a4,804 <free+0x26>
  } else
    p->s.ptr = bp;
 856:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 858:	00000717          	auipc	a4,0x0
 85c:	7af73423          	sd	a5,1960(a4) # 1000 <freep>
}
 860:	6422                	ld	s0,8(sp)
 862:	0141                	addi	sp,sp,16
 864:	8082                	ret

0000000000000866 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 866:	7139                	addi	sp,sp,-64
 868:	fc06                	sd	ra,56(sp)
 86a:	f822                	sd	s0,48(sp)
 86c:	f426                	sd	s1,40(sp)
 86e:	f04a                	sd	s2,32(sp)
 870:	ec4e                	sd	s3,24(sp)
 872:	e852                	sd	s4,16(sp)
 874:	e456                	sd	s5,8(sp)
 876:	e05a                	sd	s6,0(sp)
 878:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87a:	02051493          	slli	s1,a0,0x20
 87e:	9081                	srli	s1,s1,0x20
 880:	04bd                	addi	s1,s1,15
 882:	8091                	srli	s1,s1,0x4
 884:	0014899b          	addiw	s3,s1,1
 888:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 88a:	00000517          	auipc	a0,0x0
 88e:	77653503          	ld	a0,1910(a0) # 1000 <freep>
 892:	c515                	beqz	a0,8be <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 894:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 896:	4798                	lw	a4,8(a5)
 898:	02977f63          	bgeu	a4,s1,8d6 <malloc+0x70>
 89c:	8a4e                	mv	s4,s3
 89e:	0009871b          	sext.w	a4,s3
 8a2:	6685                	lui	a3,0x1
 8a4:	00d77363          	bgeu	a4,a3,8aa <malloc+0x44>
 8a8:	6a05                	lui	s4,0x1
 8aa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8ae:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8b2:	00000917          	auipc	s2,0x0
 8b6:	74e90913          	addi	s2,s2,1870 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8ba:	5afd                	li	s5,-1
 8bc:	a0bd                	j	92a <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8be:	00000797          	auipc	a5,0x0
 8c2:	75278793          	addi	a5,a5,1874 # 1010 <base>
 8c6:	00000717          	auipc	a4,0x0
 8ca:	72f73d23          	sd	a5,1850(a4) # 1000 <freep>
 8ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8d4:	b7e1                	j	89c <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8d6:	02e48b63          	beq	s1,a4,90c <malloc+0xa6>
        p->s.size -= nunits;
 8da:	4137073b          	subw	a4,a4,s3
 8de:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e0:	1702                	slli	a4,a4,0x20
 8e2:	9301                	srli	a4,a4,0x20
 8e4:	0712                	slli	a4,a4,0x4
 8e6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e8:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8ec:	00000717          	auipc	a4,0x0
 8f0:	70a73a23          	sd	a0,1812(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 8f4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 8f8:	70e2                	ld	ra,56(sp)
 8fa:	7442                	ld	s0,48(sp)
 8fc:	74a2                	ld	s1,40(sp)
 8fe:	7902                	ld	s2,32(sp)
 900:	69e2                	ld	s3,24(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	6121                	addi	sp,sp,64
 90a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90c:	6398                	ld	a4,0(a5)
 90e:	e118                	sd	a4,0(a0)
 910:	bff1                	j	8ec <malloc+0x86>
  hp->s.size = nu;
 912:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 916:	0541                	addi	a0,a0,16
 918:	ec7ff0ef          	jal	ra,7de <free>
  return freep;
 91c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 920:	dd61                	beqz	a0,8f8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 922:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 924:	4798                	lw	a4,8(a5)
 926:	fa9778e3          	bgeu	a4,s1,8d6 <malloc+0x70>
    if(p == freep)
 92a:	00093703          	ld	a4,0(s2)
 92e:	853e                	mv	a0,a5
 930:	fef719e3          	bne	a4,a5,922 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 934:	8552                	mv	a0,s4
 936:	9e7ff0ef          	jal	ra,31c <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 93a:	fd551ce3          	bne	a0,s5,912 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 93e:	4501                	li	a0,0
 940:	bf65                	j	8f8 <malloc+0x92>
