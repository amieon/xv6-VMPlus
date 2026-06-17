
user/_cow_bench:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
           n, (int)(S.fork_copy_pages - cp0), (int)(S.fork_share_pages - sh0));
    free(p);
  }
}

int main(void){
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
  18:	0100                	addi	s0,sp,128
  printf("== COW fork benchmark ==\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	a5650513          	addi	a0,a0,-1450 # a70 <malloc+0xe4>
  22:	0b1000ef          	jal	ra,8d2 <printf>
  char *p = malloc(n*PG); memset(p, 1, n*PG);   // 触一遍，保证页 present + 可写
  26:	00200537          	lui	a0,0x200
  2a:	163000ef          	jal	ra,98c <malloc>
  2e:	84aa                	mv	s1,a0
  30:	00200637          	lui	a2,0x200
  34:	4585                	li	a1,1
  36:	22c000ef          	jal	ra,262 <memset>
static uint64 snap_cow(void)   { vmstats(&S); return S.cow_faults; }
  3a:	00001917          	auipc	s2,0x1
  3e:	fd690913          	addi	s2,s2,-42 # 1010 <S>
  42:	854a                	mv	a0,s2
  44:	50a000ef          	jal	ra,54e <vmstats>
  48:	00093983          	ld	s3,0(s2)
  if(fork() == 0) exit(0);
  4c:	422000ef          	jal	ra,46e <fork>
  50:	16050463          	beqz	a0,1b8 <main+0x1b8>
  wait(0);
  54:	4501                	li	a0,0
  56:	428000ef          	jal	ra,47e <wait>
static uint64 snap_cow(void)   { vmstats(&S); return S.cow_faults; }
  5a:	00001917          	auipc	s2,0x1
  5e:	fb690913          	addi	s2,s2,-74 # 1010 <S>
  62:	854a                	mv	a0,s2
  64:	4ea000ef          	jal	ra,54e <vmstats>
  printf("exp1 N=%d  cow_copies=%d  (expect ~0)\n", n, (int)(snap_cow()-c0));
  68:	00093603          	ld	a2,0(s2)
  6c:	4136063b          	subw	a2,a2,s3
  70:	20000593          	li	a1,512
  74:	00001517          	auipc	a0,0x1
  78:	a1c50513          	addi	a0,a0,-1508 # a90 <malloc+0x104>
  7c:	057000ef          	jal	ra,8d2 <printf>
  free(p);
  80:	8526                	mv	a0,s1
  82:	083000ef          	jal	ra,904 <free>
  int frac[] = {0, 25, 50, 75, 100};
  86:	f8042423          	sw	zero,-120(s0)
  8a:	47e5                	li	a5,25
  8c:	f8f42623          	sw	a5,-116(s0)
  90:	03200793          	li	a5,50
  94:	f8f42823          	sw	a5,-112(s0)
  98:	04b00793          	li	a5,75
  9c:	f8f42a23          	sw	a5,-108(s0)
  a0:	06400793          	li	a5,100
  a4:	f8f42c23          	sw	a5,-104(s0)
  for(int k = 0; k < 5; k++){
  a8:	f8840913          	addi	s2,s0,-120
  ac:	f9c40c93          	addi	s9,s0,-100
    int w = n * frac[k] / 100;
  b0:	06400c13          	li	s8,100
static uint64 snap_cow(void)   { vmstats(&S); return S.cow_faults; }
  b4:	00001497          	auipc	s1,0x1
  b8:	f5c48493          	addi	s1,s1,-164 # 1010 <S>
    printf("exp2 N=%d  write=%d%%  cow_copies=%d  (expect ~%d)\n",
  bc:	00001b97          	auipc	s7,0x1
  c0:	9fcb8b93          	addi	s7,s7,-1540 # ab8 <malloc+0x12c>
    int w = n * frac[k] / 100;
  c4:	00092a83          	lw	s5,0(s2)
  c8:	009a999b          	slliw	s3,s5,0x9
  cc:	0389c9bb          	divw	s3,s3,s8
    char *p = malloc(n*PG); memset(p, 1, n*PG);
  d0:	00200537          	lui	a0,0x200
  d4:	0b9000ef          	jal	ra,98c <malloc>
  d8:	8a2a                	mv	s4,a0
  da:	00200637          	lui	a2,0x200
  de:	4585                	li	a1,1
  e0:	182000ef          	jal	ra,262 <memset>
static uint64 snap_cow(void)   { vmstats(&S); return S.cow_faults; }
  e4:	8526                	mv	a0,s1
  e6:	468000ef          	jal	ra,54e <vmstats>
  ea:	0004bb03          	ld	s6,0(s1)
    if(fork() == 0){
  ee:	380000ef          	jal	ra,46e <fork>
  f2:	0e050263          	beqz	a0,1d6 <main+0x1d6>
    wait(0);
  f6:	4501                	li	a0,0
  f8:	386000ef          	jal	ra,47e <wait>
static uint64 snap_cow(void)   { vmstats(&S); return S.cow_faults; }
  fc:	8526                	mv	a0,s1
  fe:	450000ef          	jal	ra,54e <vmstats>
           n, frac[k], (int)(snap_cow()-c0), w);
 102:	6094                	ld	a3,0(s1)
    printf("exp2 N=%d  write=%d%%  cow_copies=%d  (expect ~%d)\n",
 104:	874e                	mv	a4,s3
 106:	416686bb          	subw	a3,a3,s6
 10a:	8656                	mv	a2,s5
 10c:	20000593          	li	a1,512
 110:	855e                	mv	a0,s7
 112:	7c0000ef          	jal	ra,8d2 <printf>
    free(p);
 116:	8552                	mv	a0,s4
 118:	7ec000ef          	jal	ra,904 <free>
  for(int k = 0; k < 5; k++){
 11c:	0911                	addi	s2,s2,4
 11e:	fb9913e3          	bne	s2,s9,c4 <main+0xc4>
  int sizes[] = {64,128,256,512};
 122:	04000793          	li	a5,64
 126:	f8f42423          	sw	a5,-120(s0)
 12a:	08000793          	li	a5,128
 12e:	f8f42623          	sw	a5,-116(s0)
 132:	10000793          	li	a5,256
 136:	f8f42823          	sw	a5,-112(s0)
 13a:	20000793          	li	a5,512
 13e:	f8f42a23          	sw	a5,-108(s0)
  for(int s = 0; s < 4; s++){
 142:	f8840993          	addi	s3,s0,-120
 146:	f9840c13          	addi	s8,s0,-104
    vmstats(&S); uint64 cp0 = S.fork_copy_pages, sh0 = S.fork_share_pages;
 14a:	00001497          	auipc	s1,0x1
 14e:	ec648493          	addi	s1,s1,-314 # 1010 <S>
    printf("exp3 N=%d  fork_copied=%d  fork_shared=%d\n",
 152:	00001b97          	auipc	s7,0x1
 156:	99eb8b93          	addi	s7,s7,-1634 # af0 <malloc+0x164>
    int n = sizes[s];
 15a:	0009aa83          	lw	s5,0(s3)
    char *p = malloc(n*PG); memset(p, 1, n*PG);   // 让 n 页驻留
 15e:	00ca991b          	slliw	s2,s5,0xc
 162:	854a                	mv	a0,s2
 164:	029000ef          	jal	ra,98c <malloc>
 168:	8a2a                	mv	s4,a0
 16a:	864a                	mv	a2,s2
 16c:	4585                	li	a1,1
 16e:	0f4000ef          	jal	ra,262 <memset>
    vmstats(&S); uint64 cp0 = S.fork_copy_pages, sh0 = S.fork_share_pages;
 172:	8526                	mv	a0,s1
 174:	3da000ef          	jal	ra,54e <vmstats>
 178:	0304b903          	ld	s2,48(s1)
 17c:	0384bb03          	ld	s6,56(s1)
    if(fork() == 0) exit(0);
 180:	2ee000ef          	jal	ra,46e <fork>
 184:	cd21                	beqz	a0,1dc <main+0x1dc>
    wait(0);
 186:	4501                	li	a0,0
 188:	2f6000ef          	jal	ra,47e <wait>
    vmstats(&S);
 18c:	8526                	mv	a0,s1
 18e:	3c0000ef          	jal	ra,54e <vmstats>
           n, (int)(S.fork_copy_pages - cp0), (int)(S.fork_share_pages - sh0));
 192:	7c94                	ld	a3,56(s1)
 194:	7890                	ld	a2,48(s1)
    printf("exp3 N=%d  fork_copied=%d  fork_shared=%d\n",
 196:	416686bb          	subw	a3,a3,s6
 19a:	4126063b          	subw	a2,a2,s2
 19e:	85d6                	mv	a1,s5
 1a0:	855e                	mv	a0,s7
 1a2:	730000ef          	jal	ra,8d2 <printf>
    free(p);
 1a6:	8552                	mv	a0,s4
 1a8:	75c000ef          	jal	ra,904 <free>
  for(int s = 0; s < 4; s++){
 1ac:	0991                	addi	s3,s3,4
 1ae:	fb8996e3          	bne	s3,s8,15a <main+0x15a>
  exp1(512);
  exp2(512);
  exp3();
  exit(0);
 1b2:	4501                	li	a0,0
 1b4:	2c2000ef          	jal	ra,476 <exit>
  if(fork() == 0) exit(0);
 1b8:	2be000ef          	jal	ra,476 <exit>
      for(int i = 0; i < w; i++) p[i*PG] = 7;   // 每页首字节 → 触发 cowbreak
 1bc:	00c79713          	slli	a4,a5,0xc
 1c0:	9752                	add	a4,a4,s4
 1c2:	00d70023          	sb	a3,0(a4)
 1c6:	0785                	addi	a5,a5,1
 1c8:	0007871b          	sext.w	a4,a5
 1cc:	ff3748e3          	blt	a4,s3,1bc <main+0x1bc>
      exit(0);
 1d0:	4501                	li	a0,0
 1d2:	2a4000ef          	jal	ra,476 <exit>
 1d6:	4781                	li	a5,0
      for(int i = 0; i < w; i++) p[i*PG] = 7;   // 每页首字节 → 触发 cowbreak
 1d8:	469d                	li	a3,7
 1da:	b7fd                	j	1c8 <main+0x1c8>
    if(fork() == 0) exit(0);
 1dc:	29a000ef          	jal	ra,476 <exit>

00000000000001e0 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e406                	sd	ra,8(sp)
 1e4:	e022                	sd	s0,0(sp)
 1e6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1e8:	e19ff0ef          	jal	ra,0 <main>
  exit(r);
 1ec:	28a000ef          	jal	ra,476 <exit>

00000000000001f0 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f6:	87aa                	mv	a5,a0
 1f8:	0585                	addi	a1,a1,1
 1fa:	0785                	addi	a5,a5,1
 1fc:	fff5c703          	lbu	a4,-1(a1)
 200:	fee78fa3          	sb	a4,-1(a5)
 204:	fb75                	bnez	a4,1f8 <strcpy+0x8>
    ;
  return os;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret

000000000000020c <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 212:	00054783          	lbu	a5,0(a0) # 200000 <base+0x1fefb0>
 216:	cb91                	beqz	a5,22a <strcmp+0x1e>
 218:	0005c703          	lbu	a4,0(a1)
 21c:	00f71763          	bne	a4,a5,22a <strcmp+0x1e>
    p++, q++;
 220:	0505                	addi	a0,a0,1
 222:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 224:	00054783          	lbu	a5,0(a0)
 228:	fbe5                	bnez	a5,218 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 22a:	0005c503          	lbu	a0,0(a1)
}
 22e:	40a7853b          	subw	a0,a5,a0
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 23e:	00054783          	lbu	a5,0(a0)
 242:	cf91                	beqz	a5,25e <strlen+0x26>
 244:	0505                	addi	a0,a0,1
 246:	87aa                	mv	a5,a0
 248:	4685                	li	a3,1
 24a:	9e89                	subw	a3,a3,a0
 24c:	00f6853b          	addw	a0,a3,a5
 250:	0785                	addi	a5,a5,1
 252:	fff7c703          	lbu	a4,-1(a5)
 256:	fb7d                	bnez	a4,24c <strlen+0x14>
    ;
  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  for(n = 0; s[n]; n++)
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <strlen+0x20>

0000000000000262 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 268:	ca19                	beqz	a2,27e <memset+0x1c>
 26a:	87aa                	mv	a5,a0
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 274:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 278:	0785                	addi	a5,a5,1
 27a:	fee79de3          	bne	a5,a4,274 <memset+0x12>
  }
  return dst;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret

0000000000000284 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  for(; *s; s++)
 28a:	00054783          	lbu	a5,0(a0)
 28e:	cb99                	beqz	a5,2a4 <strchr+0x20>
    if(*s == c)
 290:	00f58763          	beq	a1,a5,29e <strchr+0x1a>
  for(; *s; s++)
 294:	0505                	addi	a0,a0,1
 296:	00054783          	lbu	a5,0(a0)
 29a:	fbfd                	bnez	a5,290 <strchr+0xc>
      return (char*)s;
  return 0;
 29c:	4501                	li	a0,0
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  return 0;
 2a4:	4501                	li	a0,0
 2a6:	bfe5                	j	29e <strchr+0x1a>

00000000000002a8 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 2a8:	711d                	addi	sp,sp,-96
 2aa:	ec86                	sd	ra,88(sp)
 2ac:	e8a2                	sd	s0,80(sp)
 2ae:	e4a6                	sd	s1,72(sp)
 2b0:	e0ca                	sd	s2,64(sp)
 2b2:	fc4e                	sd	s3,56(sp)
 2b4:	f852                	sd	s4,48(sp)
 2b6:	f456                	sd	s5,40(sp)
 2b8:	f05a                	sd	s6,32(sp)
 2ba:	ec5e                	sd	s7,24(sp)
 2bc:	1080                	addi	s0,sp,96
 2be:	8baa                	mv	s7,a0
 2c0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c2:	892a                	mv	s2,a0
 2c4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c6:	4aa9                	li	s5,10
 2c8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ca:	89a6                	mv	s3,s1
 2cc:	2485                	addiw	s1,s1,1
 2ce:	0344d663          	bge	s1,s4,2fa <gets+0x52>
    cc = read(0, &c, 1);
 2d2:	4605                	li	a2,1
 2d4:	faf40593          	addi	a1,s0,-81
 2d8:	4501                	li	a0,0
 2da:	1b4000ef          	jal	ra,48e <read>
    if(cc < 1)
 2de:	00a05e63          	blez	a0,2fa <gets+0x52>
    buf[i++] = c;
 2e2:	faf44783          	lbu	a5,-81(s0)
 2e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ea:	01578763          	beq	a5,s5,2f8 <gets+0x50>
 2ee:	0905                	addi	s2,s2,1
 2f0:	fd679de3          	bne	a5,s6,2ca <gets+0x22>
  for(i=0; i+1 < max; ){
 2f4:	89a6                	mv	s3,s1
 2f6:	a011                	j	2fa <gets+0x52>
 2f8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2fa:	99de                	add	s3,s3,s7
 2fc:	00098023          	sb	zero,0(s3)
  return buf;
}
 300:	855e                	mv	a0,s7
 302:	60e6                	ld	ra,88(sp)
 304:	6446                	ld	s0,80(sp)
 306:	64a6                	ld	s1,72(sp)
 308:	6906                	ld	s2,64(sp)
 30a:	79e2                	ld	s3,56(sp)
 30c:	7a42                	ld	s4,48(sp)
 30e:	7aa2                	ld	s5,40(sp)
 310:	7b02                	ld	s6,32(sp)
 312:	6be2                	ld	s7,24(sp)
 314:	6125                	addi	sp,sp,96
 316:	8082                	ret

0000000000000318 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 318:	1101                	addi	sp,sp,-32
 31a:	ec06                	sd	ra,24(sp)
 31c:	e822                	sd	s0,16(sp)
 31e:	e426                	sd	s1,8(sp)
 320:	e04a                	sd	s2,0(sp)
 322:	1000                	addi	s0,sp,32
 324:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 326:	4581                	li	a1,0
 328:	18e000ef          	jal	ra,4b6 <open>
  if(fd < 0)
 32c:	02054163          	bltz	a0,34e <stat+0x36>
 330:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 332:	85ca                	mv	a1,s2
 334:	19a000ef          	jal	ra,4ce <fstat>
 338:	892a                	mv	s2,a0
  close(fd);
 33a:	8526                	mv	a0,s1
 33c:	162000ef          	jal	ra,49e <close>
  return r;
}
 340:	854a                	mv	a0,s2
 342:	60e2                	ld	ra,24(sp)
 344:	6442                	ld	s0,16(sp)
 346:	64a2                	ld	s1,8(sp)
 348:	6902                	ld	s2,0(sp)
 34a:	6105                	addi	sp,sp,32
 34c:	8082                	ret
    return -1;
 34e:	597d                	li	s2,-1
 350:	bfc5                	j	340 <stat+0x28>

0000000000000352 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 358:	00054603          	lbu	a2,0(a0)
 35c:	fd06079b          	addiw	a5,a2,-48
 360:	0ff7f793          	andi	a5,a5,255
 364:	4725                	li	a4,9
 366:	02f76963          	bltu	a4,a5,398 <atoi+0x46>
 36a:	86aa                	mv	a3,a0
  n = 0;
 36c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 36e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 370:	0685                	addi	a3,a3,1
 372:	0025179b          	slliw	a5,a0,0x2
 376:	9fa9                	addw	a5,a5,a0
 378:	0017979b          	slliw	a5,a5,0x1
 37c:	9fb1                	addw	a5,a5,a2
 37e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 382:	0006c603          	lbu	a2,0(a3)
 386:	fd06071b          	addiw	a4,a2,-48
 38a:	0ff77713          	andi	a4,a4,255
 38e:	fee5f1e3          	bgeu	a1,a4,370 <atoi+0x1e>
  return n;
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  n = 0;
 398:	4501                	li	a0,0
 39a:	bfe5                	j	392 <atoi+0x40>

000000000000039c <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e422                	sd	s0,8(sp)
 3a0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a2:	02b57463          	bgeu	a0,a1,3ca <memmove+0x2e>
    while(n-- > 0)
 3a6:	00c05f63          	blez	a2,3c4 <memmove+0x28>
 3aa:	1602                	slli	a2,a2,0x20
 3ac:	9201                	srli	a2,a2,0x20
 3ae:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b2:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b4:	0585                	addi	a1,a1,1
 3b6:	0705                	addi	a4,a4,1
 3b8:	fff5c683          	lbu	a3,-1(a1)
 3bc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c0:	fee79ae3          	bne	a5,a4,3b4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
    dst += n;
 3ca:	00c50733          	add	a4,a0,a2
    src += n;
 3ce:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3d0:	fec05ae3          	blez	a2,3c4 <memmove+0x28>
 3d4:	fff6079b          	addiw	a5,a2,-1
 3d8:	1782                	slli	a5,a5,0x20
 3da:	9381                	srli	a5,a5,0x20
 3dc:	fff7c793          	not	a5,a5
 3e0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e2:	15fd                	addi	a1,a1,-1
 3e4:	177d                	addi	a4,a4,-1
 3e6:	0005c683          	lbu	a3,0(a1)
 3ea:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ee:	fee79ae3          	bne	a5,a4,3e2 <memmove+0x46>
 3f2:	bfc9                	j	3c4 <memmove+0x28>

00000000000003f4 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e422                	sd	s0,8(sp)
 3f8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3fa:	ca05                	beqz	a2,42a <memcmp+0x36>
 3fc:	fff6069b          	addiw	a3,a2,-1
 400:	1682                	slli	a3,a3,0x20
 402:	9281                	srli	a3,a3,0x20
 404:	0685                	addi	a3,a3,1
 406:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 408:	00054783          	lbu	a5,0(a0)
 40c:	0005c703          	lbu	a4,0(a1)
 410:	00e79863          	bne	a5,a4,420 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 414:	0505                	addi	a0,a0,1
    p2++;
 416:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 418:	fed518e3          	bne	a0,a3,408 <memcmp+0x14>
  }
  return 0;
 41c:	4501                	li	a0,0
 41e:	a019                	j	424 <memcmp+0x30>
      return *p1 - *p2;
 420:	40e7853b          	subw	a0,a5,a4
}
 424:	6422                	ld	s0,8(sp)
 426:	0141                	addi	sp,sp,16
 428:	8082                	ret
  return 0;
 42a:	4501                	li	a0,0
 42c:	bfe5                	j	424 <memcmp+0x30>

000000000000042e <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 42e:	1141                	addi	sp,sp,-16
 430:	e406                	sd	ra,8(sp)
 432:	e022                	sd	s0,0(sp)
 434:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 436:	f67ff0ef          	jal	ra,39c <memmove>
}
 43a:	60a2                	ld	ra,8(sp)
 43c:	6402                	ld	s0,0(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret

0000000000000442 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 442:	1141                	addi	sp,sp,-16
 444:	e406                	sd	ra,8(sp)
 446:	e022                	sd	s0,0(sp)
 448:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 44a:	4585                	li	a1,1
 44c:	0b2000ef          	jal	ra,4fe <sys_sbrk>
}
 450:	60a2                	ld	ra,8(sp)
 452:	6402                	ld	s0,0(sp)
 454:	0141                	addi	sp,sp,16
 456:	8082                	ret

0000000000000458 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 458:	1141                	addi	sp,sp,-16
 45a:	e406                	sd	ra,8(sp)
 45c:	e022                	sd	s0,0(sp)
 45e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 460:	4589                	li	a1,2
 462:	09c000ef          	jal	ra,4fe <sys_sbrk>
}
 466:	60a2                	ld	ra,8(sp)
 468:	6402                	ld	s0,0(sp)
 46a:	0141                	addi	sp,sp,16
 46c:	8082                	ret

000000000000046e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 46e:	4885                	li	a7,1
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <exit>:
.global exit
exit:
 li a7, SYS_exit
 476:	4889                	li	a7,2
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <wait>:
.global wait
wait:
 li a7, SYS_wait
 47e:	488d                	li	a7,3
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 486:	4891                	li	a7,4
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <read>:
.global read
read:
 li a7, SYS_read
 48e:	4895                	li	a7,5
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <write>:
.global write
write:
 li a7, SYS_write
 496:	48c1                	li	a7,16
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <close>:
.global close
close:
 li a7, SYS_close
 49e:	48d5                	li	a7,21
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a6:	4899                	li	a7,6
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ae:	489d                	li	a7,7
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <open>:
.global open
open:
 li a7, SYS_open
 4b6:	48bd                	li	a7,15
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4be:	48c5                	li	a7,17
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c6:	48c9                	li	a7,18
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ce:	48a1                	li	a7,8
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <link>:
.global link
link:
 li a7, SYS_link
 4d6:	48cd                	li	a7,19
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4de:	48d1                	li	a7,20
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e6:	48a5                	li	a7,9
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ee:	48a9                	li	a7,10
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f6:	48ad                	li	a7,11
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4fe:	48b1                	li	a7,12
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <pause>:
.global pause
pause:
 li a7, SYS_pause
 506:	48b5                	li	a7,13
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 50e:	48b9                	li	a7,14
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 516:	48d9                	li	a7,22
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 51e:	48dd                	li	a7,23
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 526:	48e1                	li	a7,24
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 52e:	48e5                	li	a7,25
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 536:	48e9                	li	a7,26
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 53e:	48ed                	li	a7,27
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 546:	48f1                	li	a7,28
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 54e:	48f5                	li	a7,29
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 556:	1101                	addi	sp,sp,-32
 558:	ec06                	sd	ra,24(sp)
 55a:	e822                	sd	s0,16(sp)
 55c:	1000                	addi	s0,sp,32
 55e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 562:	4605                	li	a2,1
 564:	fef40593          	addi	a1,s0,-17
 568:	f2fff0ef          	jal	ra,496 <write>
}
 56c:	60e2                	ld	ra,24(sp)
 56e:	6442                	ld	s0,16(sp)
 570:	6105                	addi	sp,sp,32
 572:	8082                	ret

0000000000000574 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 574:	715d                	addi	sp,sp,-80
 576:	e486                	sd	ra,72(sp)
 578:	e0a2                	sd	s0,64(sp)
 57a:	fc26                	sd	s1,56(sp)
 57c:	f84a                	sd	s2,48(sp)
 57e:	f44e                	sd	s3,40(sp)
 580:	0880                	addi	s0,sp,80
 582:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 584:	c299                	beqz	a3,58a <printint+0x16>
 586:	0805c163          	bltz	a1,608 <printint+0x94>
  neg = 0;
 58a:	4881                	li	a7,0
 58c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 590:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 592:	00000517          	auipc	a0,0x0
 596:	59650513          	addi	a0,a0,1430 # b28 <digits>
 59a:	883e                	mv	a6,a5
 59c:	2785                	addiw	a5,a5,1
 59e:	02c5f733          	remu	a4,a1,a2
 5a2:	972a                	add	a4,a4,a0
 5a4:	00074703          	lbu	a4,0(a4)
 5a8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5ac:	872e                	mv	a4,a1
 5ae:	02c5d5b3          	divu	a1,a1,a2
 5b2:	0685                	addi	a3,a3,1
 5b4:	fec773e3          	bgeu	a4,a2,59a <printint+0x26>
  if(neg)
 5b8:	00088b63          	beqz	a7,5ce <printint+0x5a>
    buf[i++] = '-';
 5bc:	fd040713          	addi	a4,s0,-48
 5c0:	97ba                	add	a5,a5,a4
 5c2:	02d00713          	li	a4,45
 5c6:	fee78423          	sb	a4,-24(a5)
 5ca:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5ce:	02f05663          	blez	a5,5fa <printint+0x86>
 5d2:	fb840713          	addi	a4,s0,-72
 5d6:	00f704b3          	add	s1,a4,a5
 5da:	fff70993          	addi	s3,a4,-1
 5de:	99be                	add	s3,s3,a5
 5e0:	37fd                	addiw	a5,a5,-1
 5e2:	1782                	slli	a5,a5,0x20
 5e4:	9381                	srli	a5,a5,0x20
 5e6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5ea:	fff4c583          	lbu	a1,-1(s1)
 5ee:	854a                	mv	a0,s2
 5f0:	f67ff0ef          	jal	ra,556 <putc>
  while(--i >= 0)
 5f4:	14fd                	addi	s1,s1,-1
 5f6:	ff349ae3          	bne	s1,s3,5ea <printint+0x76>
}
 5fa:	60a6                	ld	ra,72(sp)
 5fc:	6406                	ld	s0,64(sp)
 5fe:	74e2                	ld	s1,56(sp)
 600:	7942                	ld	s2,48(sp)
 602:	79a2                	ld	s3,40(sp)
 604:	6161                	addi	sp,sp,80
 606:	8082                	ret
    x = -xx;
 608:	40b005b3          	neg	a1,a1
    neg = 1;
 60c:	4885                	li	a7,1
    x = -xx;
 60e:	bfbd                	j	58c <printint+0x18>

0000000000000610 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 610:	7119                	addi	sp,sp,-128
 612:	fc86                	sd	ra,120(sp)
 614:	f8a2                	sd	s0,112(sp)
 616:	f4a6                	sd	s1,104(sp)
 618:	f0ca                	sd	s2,96(sp)
 61a:	ecce                	sd	s3,88(sp)
 61c:	e8d2                	sd	s4,80(sp)
 61e:	e4d6                	sd	s5,72(sp)
 620:	e0da                	sd	s6,64(sp)
 622:	fc5e                	sd	s7,56(sp)
 624:	f862                	sd	s8,48(sp)
 626:	f466                	sd	s9,40(sp)
 628:	f06a                	sd	s10,32(sp)
 62a:	ec6e                	sd	s11,24(sp)
 62c:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 62e:	0005c903          	lbu	s2,0(a1)
 632:	24090c63          	beqz	s2,88a <vprintf+0x27a>
 636:	8b2a                	mv	s6,a0
 638:	8a2e                	mv	s4,a1
 63a:	8bb2                	mv	s7,a2
  state = 0;
 63c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 63e:	4481                	li	s1,0
 640:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 642:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 646:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 64a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 64e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 652:	00000c97          	auipc	s9,0x0
 656:	4d6c8c93          	addi	s9,s9,1238 # b28 <digits>
 65a:	a005                	j	67a <vprintf+0x6a>
        putc(fd, c0);
 65c:	85ca                	mv	a1,s2
 65e:	855a                	mv	a0,s6
 660:	ef7ff0ef          	jal	ra,556 <putc>
 664:	a019                	j	66a <vprintf+0x5a>
    } else if(state == '%'){
 666:	03598263          	beq	s3,s5,68a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 66a:	2485                	addiw	s1,s1,1
 66c:	8726                	mv	a4,s1
 66e:	009a07b3          	add	a5,s4,s1
 672:	0007c903          	lbu	s2,0(a5)
 676:	20090a63          	beqz	s2,88a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 67a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 67e:	fe0994e3          	bnez	s3,666 <vprintf+0x56>
      if(c0 == '%'){
 682:	fd579de3          	bne	a5,s5,65c <vprintf+0x4c>
        state = '%';
 686:	89be                	mv	s3,a5
 688:	b7cd                	j	66a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 68a:	c3c1                	beqz	a5,70a <vprintf+0xfa>
 68c:	00ea06b3          	add	a3,s4,a4
 690:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 694:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 696:	c681                	beqz	a3,69e <vprintf+0x8e>
 698:	9752                	add	a4,a4,s4
 69a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 69e:	03878e63          	beq	a5,s8,6da <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 6a2:	05a78863          	beq	a5,s10,6f2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 6a6:	0db78b63          	beq	a5,s11,77c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6aa:	07800713          	li	a4,120
 6ae:	10e78d63          	beq	a5,a4,7c8 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6b2:	07000713          	li	a4,112
 6b6:	14e78263          	beq	a5,a4,7fa <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6ba:	06300713          	li	a4,99
 6be:	16e78f63          	beq	a5,a4,83c <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6c2:	07300713          	li	a4,115
 6c6:	18e78563          	beq	a5,a4,850 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6ca:	05579063          	bne	a5,s5,70a <vprintf+0xfa>
        putc(fd, '%');
 6ce:	85d6                	mv	a1,s5
 6d0:	855a                	mv	a0,s6
 6d2:	e85ff0ef          	jal	ra,556 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bf49                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4685                	li	a3,1
 6e0:	4629                	li	a2,10
 6e2:	000ba583          	lw	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	e8dff0ef          	jal	ra,574 <printint>
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bfad                	j	66a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 6f2:	03868663          	beq	a3,s8,71e <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6f6:	05a68163          	beq	a3,s10,738 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 6fa:	09b68d63          	beq	a3,s11,794 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6fe:	03a68f63          	beq	a3,s10,73c <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 702:	07800793          	li	a5,120
 706:	0cf68d63          	beq	a3,a5,7e0 <vprintf+0x1d0>
        putc(fd, '%');
 70a:	85d6                	mv	a1,s5
 70c:	855a                	mv	a0,s6
 70e:	e49ff0ef          	jal	ra,556 <putc>
        putc(fd, c0);
 712:	85ca                	mv	a1,s2
 714:	855a                	mv	a0,s6
 716:	e41ff0ef          	jal	ra,556 <putc>
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b7b9                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 71e:	008b8913          	addi	s2,s7,8
 722:	4685                	li	a3,1
 724:	4629                	li	a2,10
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	e49ff0ef          	jal	ra,574 <printint>
        i += 1;
 730:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 732:	8bca                	mv	s7,s2
      state = 0;
 734:	4981                	li	s3,0
        i += 1;
 736:	bf15                	j	66a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 738:	03860563          	beq	a2,s8,762 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 73c:	07b60963          	beq	a2,s11,7ae <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 740:	07800793          	li	a5,120
 744:	fcf613e3          	bne	a2,a5,70a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 748:	008b8913          	addi	s2,s7,8
 74c:	4681                	li	a3,0
 74e:	4641                	li	a2,16
 750:	000bb583          	ld	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	e1fff0ef          	jal	ra,574 <printint>
        i += 2;
 75a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 75c:	8bca                	mv	s7,s2
      state = 0;
 75e:	4981                	li	s3,0
        i += 2;
 760:	b729                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 762:	008b8913          	addi	s2,s7,8
 766:	4685                	li	a3,1
 768:	4629                	li	a2,10
 76a:	000bb583          	ld	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	e05ff0ef          	jal	ra,574 <printint>
        i += 2;
 774:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 776:	8bca                	mv	s7,s2
      state = 0;
 778:	4981                	li	s3,0
        i += 2;
 77a:	bdc5                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 77c:	008b8913          	addi	s2,s7,8
 780:	4681                	li	a3,0
 782:	4629                	li	a2,10
 784:	000be583          	lwu	a1,0(s7)
 788:	855a                	mv	a0,s6
 78a:	debff0ef          	jal	ra,574 <printint>
 78e:	8bca                	mv	s7,s2
      state = 0;
 790:	4981                	li	s3,0
 792:	bde1                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 794:	008b8913          	addi	s2,s7,8
 798:	4681                	li	a3,0
 79a:	4629                	li	a2,10
 79c:	000bb583          	ld	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	dd3ff0ef          	jal	ra,574 <printint>
        i += 1;
 7a6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a8:	8bca                	mv	s7,s2
      state = 0;
 7aa:	4981                	li	s3,0
        i += 1;
 7ac:	bd7d                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ae:	008b8913          	addi	s2,s7,8
 7b2:	4681                	li	a3,0
 7b4:	4629                	li	a2,10
 7b6:	000bb583          	ld	a1,0(s7)
 7ba:	855a                	mv	a0,s6
 7bc:	db9ff0ef          	jal	ra,574 <printint>
        i += 2;
 7c0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c2:	8bca                	mv	s7,s2
      state = 0;
 7c4:	4981                	li	s3,0
        i += 2;
 7c6:	b555                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7c8:	008b8913          	addi	s2,s7,8
 7cc:	4681                	li	a3,0
 7ce:	4641                	li	a2,16
 7d0:	000be583          	lwu	a1,0(s7)
 7d4:	855a                	mv	a0,s6
 7d6:	d9fff0ef          	jal	ra,574 <printint>
 7da:	8bca                	mv	s7,s2
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	b571                	j	66a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7e0:	008b8913          	addi	s2,s7,8
 7e4:	4681                	li	a3,0
 7e6:	4641                	li	a2,16
 7e8:	000bb583          	ld	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	d87ff0ef          	jal	ra,574 <printint>
        i += 1;
 7f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7f4:	8bca                	mv	s7,s2
      state = 0;
 7f6:	4981                	li	s3,0
        i += 1;
 7f8:	bd8d                	j	66a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 7fa:	008b8793          	addi	a5,s7,8
 7fe:	f8f43423          	sd	a5,-120(s0)
 802:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 806:	03000593          	li	a1,48
 80a:	855a                	mv	a0,s6
 80c:	d4bff0ef          	jal	ra,556 <putc>
  putc(fd, 'x');
 810:	07800593          	li	a1,120
 814:	855a                	mv	a0,s6
 816:	d41ff0ef          	jal	ra,556 <putc>
 81a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 81c:	03c9d793          	srli	a5,s3,0x3c
 820:	97e6                	add	a5,a5,s9
 822:	0007c583          	lbu	a1,0(a5)
 826:	855a                	mv	a0,s6
 828:	d2fff0ef          	jal	ra,556 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 82c:	0992                	slli	s3,s3,0x4
 82e:	397d                	addiw	s2,s2,-1
 830:	fe0916e3          	bnez	s2,81c <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 834:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 838:	4981                	li	s3,0
 83a:	bd05                	j	66a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 83c:	008b8913          	addi	s2,s7,8
 840:	000bc583          	lbu	a1,0(s7)
 844:	855a                	mv	a0,s6
 846:	d11ff0ef          	jal	ra,556 <putc>
 84a:	8bca                	mv	s7,s2
      state = 0;
 84c:	4981                	li	s3,0
 84e:	bd31                	j	66a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 850:	008b8993          	addi	s3,s7,8
 854:	000bb903          	ld	s2,0(s7)
 858:	00090f63          	beqz	s2,876 <vprintf+0x266>
        for(; *s; s++)
 85c:	00094583          	lbu	a1,0(s2)
 860:	c195                	beqz	a1,884 <vprintf+0x274>
          putc(fd, *s);
 862:	855a                	mv	a0,s6
 864:	cf3ff0ef          	jal	ra,556 <putc>
        for(; *s; s++)
 868:	0905                	addi	s2,s2,1
 86a:	00094583          	lbu	a1,0(s2)
 86e:	f9f5                	bnez	a1,862 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 870:	8bce                	mv	s7,s3
      state = 0;
 872:	4981                	li	s3,0
 874:	bbdd                	j	66a <vprintf+0x5a>
          s = "(null)";
 876:	00000917          	auipc	s2,0x0
 87a:	2aa90913          	addi	s2,s2,682 # b20 <malloc+0x194>
        for(; *s; s++)
 87e:	02800593          	li	a1,40
 882:	b7c5                	j	862 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 884:	8bce                	mv	s7,s3
      state = 0;
 886:	4981                	li	s3,0
 888:	b3cd                	j	66a <vprintf+0x5a>
    }
  }
}
 88a:	70e6                	ld	ra,120(sp)
 88c:	7446                	ld	s0,112(sp)
 88e:	74a6                	ld	s1,104(sp)
 890:	7906                	ld	s2,96(sp)
 892:	69e6                	ld	s3,88(sp)
 894:	6a46                	ld	s4,80(sp)
 896:	6aa6                	ld	s5,72(sp)
 898:	6b06                	ld	s6,64(sp)
 89a:	7be2                	ld	s7,56(sp)
 89c:	7c42                	ld	s8,48(sp)
 89e:	7ca2                	ld	s9,40(sp)
 8a0:	7d02                	ld	s10,32(sp)
 8a2:	6de2                	ld	s11,24(sp)
 8a4:	6109                	addi	sp,sp,128
 8a6:	8082                	ret

00000000000008a8 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 8a8:	715d                	addi	sp,sp,-80
 8aa:	ec06                	sd	ra,24(sp)
 8ac:	e822                	sd	s0,16(sp)
 8ae:	1000                	addi	s0,sp,32
 8b0:	e010                	sd	a2,0(s0)
 8b2:	e414                	sd	a3,8(s0)
 8b4:	e818                	sd	a4,16(s0)
 8b6:	ec1c                	sd	a5,24(s0)
 8b8:	03043023          	sd	a6,32(s0)
 8bc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8c0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8c4:	8622                	mv	a2,s0
 8c6:	d4bff0ef          	jal	ra,610 <vprintf>
}
 8ca:	60e2                	ld	ra,24(sp)
 8cc:	6442                	ld	s0,16(sp)
 8ce:	6161                	addi	sp,sp,80
 8d0:	8082                	ret

00000000000008d2 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 8d2:	711d                	addi	sp,sp,-96
 8d4:	ec06                	sd	ra,24(sp)
 8d6:	e822                	sd	s0,16(sp)
 8d8:	1000                	addi	s0,sp,32
 8da:	e40c                	sd	a1,8(s0)
 8dc:	e810                	sd	a2,16(s0)
 8de:	ec14                	sd	a3,24(s0)
 8e0:	f018                	sd	a4,32(s0)
 8e2:	f41c                	sd	a5,40(s0)
 8e4:	03043823          	sd	a6,48(s0)
 8e8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ec:	00840613          	addi	a2,s0,8
 8f0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8f4:	85aa                	mv	a1,a0
 8f6:	4505                	li	a0,1
 8f8:	d19ff0ef          	jal	ra,610 <vprintf>
}
 8fc:	60e2                	ld	ra,24(sp)
 8fe:	6442                	ld	s0,16(sp)
 900:	6125                	addi	sp,sp,96
 902:	8082                	ret

0000000000000904 <free>:
 *   无
 */

void
free(void *ap)
{
 904:	1141                	addi	sp,sp,-16
 906:	e422                	sd	s0,8(sp)
 908:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 90a:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90e:	00000797          	auipc	a5,0x0
 912:	6f27b783          	ld	a5,1778(a5) # 1000 <freep>
 916:	a805                	j	946 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 918:	4618                	lw	a4,8(a2)
 91a:	9db9                	addw	a1,a1,a4
 91c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 920:	6398                	ld	a4,0(a5)
 922:	6318                	ld	a4,0(a4)
 924:	fee53823          	sd	a4,-16(a0)
 928:	a091                	j	96c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 92a:	ff852703          	lw	a4,-8(a0)
 92e:	9e39                	addw	a2,a2,a4
 930:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 932:	ff053703          	ld	a4,-16(a0)
 936:	e398                	sd	a4,0(a5)
 938:	a099                	j	97e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 93a:	6398                	ld	a4,0(a5)
 93c:	00e7e463          	bltu	a5,a4,944 <free+0x40>
 940:	00e6ea63          	bltu	a3,a4,954 <free+0x50>
{
 944:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 946:	fed7fae3          	bgeu	a5,a3,93a <free+0x36>
 94a:	6398                	ld	a4,0(a5)
 94c:	00e6e463          	bltu	a3,a4,954 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 950:	fee7eae3          	bltu	a5,a4,944 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 954:	ff852583          	lw	a1,-8(a0)
 958:	6390                	ld	a2,0(a5)
 95a:	02059713          	slli	a4,a1,0x20
 95e:	9301                	srli	a4,a4,0x20
 960:	0712                	slli	a4,a4,0x4
 962:	9736                	add	a4,a4,a3
 964:	fae60ae3          	beq	a2,a4,918 <free+0x14>
    bp->s.ptr = p->s.ptr;
 968:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 96c:	4790                	lw	a2,8(a5)
 96e:	02061713          	slli	a4,a2,0x20
 972:	9301                	srli	a4,a4,0x20
 974:	0712                	slli	a4,a4,0x4
 976:	973e                	add	a4,a4,a5
 978:	fae689e3          	beq	a3,a4,92a <free+0x26>
  } else
    p->s.ptr = bp;
 97c:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 97e:	00000717          	auipc	a4,0x0
 982:	68f73123          	sd	a5,1666(a4) # 1000 <freep>
}
 986:	6422                	ld	s0,8(sp)
 988:	0141                	addi	sp,sp,16
 98a:	8082                	ret

000000000000098c <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 98c:	7139                	addi	sp,sp,-64
 98e:	fc06                	sd	ra,56(sp)
 990:	f822                	sd	s0,48(sp)
 992:	f426                	sd	s1,40(sp)
 994:	f04a                	sd	s2,32(sp)
 996:	ec4e                	sd	s3,24(sp)
 998:	e852                	sd	s4,16(sp)
 99a:	e456                	sd	s5,8(sp)
 99c:	e05a                	sd	s6,0(sp)
 99e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9a0:	02051493          	slli	s1,a0,0x20
 9a4:	9081                	srli	s1,s1,0x20
 9a6:	04bd                	addi	s1,s1,15
 9a8:	8091                	srli	s1,s1,0x4
 9aa:	0014899b          	addiw	s3,s1,1
 9ae:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 9b0:	00000517          	auipc	a0,0x0
 9b4:	65053503          	ld	a0,1616(a0) # 1000 <freep>
 9b8:	c515                	beqz	a0,9e4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 9bc:	4798                	lw	a4,8(a5)
 9be:	02977f63          	bgeu	a4,s1,9fc <malloc+0x70>
 9c2:	8a4e                	mv	s4,s3
 9c4:	0009871b          	sext.w	a4,s3
 9c8:	6685                	lui	a3,0x1
 9ca:	00d77363          	bgeu	a4,a3,9d0 <malloc+0x44>
 9ce:	6a05                	lui	s4,0x1
 9d0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 9d4:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 9d8:	00000917          	auipc	s2,0x0
 9dc:	62890913          	addi	s2,s2,1576 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 9e0:	5afd                	li	s5,-1
 9e2:	a0bd                	j	a50 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 9e4:	00000797          	auipc	a5,0x0
 9e8:	66c78793          	addi	a5,a5,1644 # 1050 <base>
 9ec:	00000717          	auipc	a4,0x0
 9f0:	60f73a23          	sd	a5,1556(a4) # 1000 <freep>
 9f4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 9fa:	b7e1                	j	9c2 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 9fc:	02e48b63          	beq	s1,a4,a32 <malloc+0xa6>
        p->s.size -= nunits;
 a00:	4137073b          	subw	a4,a4,s3
 a04:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a06:	1702                	slli	a4,a4,0x20
 a08:	9301                	srli	a4,a4,0x20
 a0a:	0712                	slli	a4,a4,0x4
 a0c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a0e:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 a12:	00000717          	auipc	a4,0x0
 a16:	5ea73723          	sd	a0,1518(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 a1a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 a1e:	70e2                	ld	ra,56(sp)
 a20:	7442                	ld	s0,48(sp)
 a22:	74a2                	ld	s1,40(sp)
 a24:	7902                	ld	s2,32(sp)
 a26:	69e2                	ld	s3,24(sp)
 a28:	6a42                	ld	s4,16(sp)
 a2a:	6aa2                	ld	s5,8(sp)
 a2c:	6b02                	ld	s6,0(sp)
 a2e:	6121                	addi	sp,sp,64
 a30:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a32:	6398                	ld	a4,0(a5)
 a34:	e118                	sd	a4,0(a0)
 a36:	bff1                	j	a12 <malloc+0x86>
  hp->s.size = nu;
 a38:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 a3c:	0541                	addi	a0,a0,16
 a3e:	ec7ff0ef          	jal	ra,904 <free>
  return freep;
 a42:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a46:	dd61                	beqz	a0,a1e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a48:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 a4a:	4798                	lw	a4,8(a5)
 a4c:	fa9778e3          	bgeu	a4,s1,9fc <malloc+0x70>
    if(p == freep)
 a50:	00093703          	ld	a4,0(s2)
 a54:	853e                	mv	a0,a5
 a56:	fef719e3          	bne	a4,a5,a48 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 a5a:	8552                	mv	a0,s4
 a5c:	9e7ff0ef          	jal	ra,442 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 a60:	fd551ce3          	bne	a0,s5,a38 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 a64:	4501                	li	a0,0
 a66:	bf65                	j	a1e <malloc+0x92>
