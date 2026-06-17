
user/_sem_vs_busy:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <worker>:
  volatile int flag;           // parent -> busy waiter: released
};

// background worker: do measurable work until told to stop
static void worker(struct ctl *c)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  while(c->stop == 0) c->work++;
   8:	491c                	lw	a5,16(a0)
   a:	2781                	sext.w	a5,a5
   c:	e799                	bnez	a5,1a <worker+0x1a>
   e:	611c                	ld	a5,0(a0)
  10:	0785                	addi	a5,a5,1
  12:	e11c                	sd	a5,0(a0)
  14:	491c                	lw	a5,16(a0)
  16:	2781                	sext.w	a5,a5
  18:	dbfd                	beqz	a5,e <worker+0xe>
  munmap((void*)c, 4096);
  1a:	6585                	lui	a1,0x1
  1c:	53a000ef          	jal	ra,556 <munmap>
  exit(0);
  20:	4501                	li	a0,0
  22:	48c000ef          	jal	ra,4ae <exit>

0000000000000026 <main>:
  return (int)(c->work / 1000);
}

int
main(void)
{
  26:	711d                	addi	sp,sp,-96
  28:	ec86                	sd	ra,88(sp)
  2a:	e8a2                	sd	s0,80(sp)
  2c:	e4a6                	sd	s1,72(sp)
  2e:	e0ca                	sd	s2,64(sp)
  30:	fc4e                	sd	s3,56(sp)
  32:	f852                	sd	s4,48(sp)
  34:	f456                	sd	s5,40(sp)
  36:	f05a                	sd	s6,32(sp)
  38:	ec5e                	sd	s7,24(sp)
  3a:	e862                	sd	s8,16(sp)
  3c:	e466                	sd	s9,8(sp)
  3e:	e06a                	sd	s10,0(sp)
  40:	1080                	addi	s0,sp,96
  struct ctl *c = (struct ctl*)mmap(0, 4096, PROT_READ|PROT_WRITE,
  42:	04d00713          	li	a4,77
  46:	468d                	li	a3,3
  48:	460d                	li	a2,3
  4a:	6585                	lui	a1,0x1
  4c:	4501                	li	a0,0
  4e:	500000ef          	jal	ra,54e <mmap>
                                    MAP_ANON|MAP_SHARED, KEY);
  if(c == (void*)-1){ printf("mmap failed\n"); exit(1); }
  52:	57fd                	li	a5,-1
  54:	12f50e63          	beq	a0,a5,190 <main+0x16a>
  58:	84aa                	mv	s1,a0

  printf("=== Blocking semaphore vs busy-wait (WINDOW=%d ticks, TRIALS=%d) ===\n",
  5a:	4615                	li	a2,5
  5c:	03200593          	li	a1,50
  60:	00001517          	auipc	a0,0x1
  64:	a5050513          	addi	a0,a0,-1456 # ab0 <malloc+0xec>
  68:	0a3000ef          	jal	ra,90a <printf>
         WINDOW, TRIALS);
  printf("NOTE: run single-CPU ( make CPUS=1 qemu ) or there is no contention to see\n");
  6c:	00001517          	auipc	a0,0x1
  70:	a8c50513          	addi	a0,a0,-1396 # af8 <malloc+0x134>
  74:	097000ef          	jal	ra,90a <printf>
  printf("metric: useful work a concurrent worker completes during the wait window\n");
  78:	00001517          	auipc	a0,0x1
  7c:	ad050513          	addi	a0,a0,-1328 # b48 <malloc+0x184>
  80:	08b000ef          	jal	ra,90a <printf>

  int sumb = 0, sums = 0, last_spin = 0;
  for(int t = 0; t < TRIALS; t++){
  84:	4a01                	li	s4,0
  int sumb = 0, sums = 0, last_spin = 0;
  86:	4c01                	li	s8,0
  88:	4b81                	li	s7,0
  c->stop = 1;                               // stop worker
  8a:	4b05                	li	s6,1
  return (int)(c->work / 1000);
  8c:	3e800a93          	li	s5,1000
    int bw = run_block(c);
    int sp = 0;
    int sw = run_busy(c, &sp);
    sumb += bw; sums += sw; last_spin = sp;
    printf("  trial %d: worker_blocking=%dK  worker_busy=%dK  wasted_spins=%dK\n",
  90:	00001d17          	auipc	s10,0x1
  94:	b08d0d13          	addi	s10,s10,-1272 # b98 <malloc+0x1d4>
  for(int t = 0; t < TRIALS; t++){
  98:	4c95                	li	s9,5
  c->work = 0; c->spins = 0; c->stop = 0; c->flag = 0;
  9a:	0004b023          	sd	zero,0(s1)
  9e:	0004b423          	sd	zero,8(s1)
  a2:	0004a823          	sw	zero,16(s1)
  a6:	0004aa23          	sw	zero,20(s1)
  sem_open(SEM, 0);                          // val 0 -> sem_wait will block
  aa:	4581                	li	a1,0
  ac:	12c00513          	li	a0,300
  b0:	4be000ef          	jal	ra,56e <sem_open>
  if(fork() == 0) worker(c);                 // worker child
  b4:	3f2000ef          	jal	ra,4a6 <fork>
  b8:	0e050563          	beqz	a0,1a2 <main+0x17c>
  if(fork() == 0){                           // blocking waiter child
  bc:	3ea000ef          	jal	ra,4a6 <fork>
  c0:	0e050463          	beqz	a0,1a8 <main+0x182>
  sleep(WINDOW);                             // measurement window
  c4:	03200513          	li	a0,50
  c8:	49e000ef          	jal	ra,566 <sleep>
  sem_post(SEM);                             // release the blocking waiter
  cc:	12c00513          	li	a0,300
  d0:	4ae000ef          	jal	ra,57e <sem_post>
  wait(0);                                   // reap waiter
  d4:	4501                	li	a0,0
  d6:	3e0000ef          	jal	ra,4b6 <wait>
  c->stop = 1;                               // stop worker
  da:	0164a823          	sw	s6,16(s1)
  wait(0);                                   // reap worker
  de:	4501                	li	a0,0
  e0:	3d6000ef          	jal	ra,4b6 <wait>
  return (int)(c->work / 1000);
  e4:	0004b903          	ld	s2,0(s1)
  e8:	03595933          	divu	s2,s2,s5
  ec:	2901                	sext.w	s2,s2
  c->work = 0; c->spins = 0; c->stop = 0; c->flag = 0;
  ee:	0004b023          	sd	zero,0(s1)
  f2:	0004b423          	sd	zero,8(s1)
  f6:	0004a823          	sw	zero,16(s1)
  fa:	0004aa23          	sw	zero,20(s1)
  if(fork() == 0) worker(c);                 // worker child
  fe:	3a8000ef          	jal	ra,4a6 <fork>
 102:	cd55                	beqz	a0,1be <main+0x198>
  if(fork() == 0){                           // busy waiter child
 104:	3a2000ef          	jal	ra,4a6 <fork>
 108:	c169                	beqz	a0,1ca <main+0x1a4>
  sleep(WINDOW);
 10a:	03200513          	li	a0,50
 10e:	458000ef          	jal	ra,566 <sleep>
  c->flag = 1;                               // release the busy waiter
 112:	0164aa23          	sw	s6,20(s1)
  wait(0);
 116:	4501                	li	a0,0
 118:	39e000ef          	jal	ra,4b6 <wait>
  c->stop = 1;
 11c:	0164a823          	sw	s6,16(s1)
  wait(0);
 120:	4501                	li	a0,0
 122:	394000ef          	jal	ra,4b6 <wait>
  *spinsK = (int)(c->spins / 1000);
 126:	0084b983          	ld	s3,8(s1)
 12a:	0359d9b3          	divu	s3,s3,s5
 12e:	2981                	sext.w	s3,s3
  return (int)(c->work / 1000);
 130:	6094                	ld	a3,0(s1)
 132:	0356d6b3          	divu	a3,a3,s5
    sumb += bw; sums += sw; last_spin = sp;
 136:	012b8bbb          	addw	s7,s7,s2
 13a:	00dc0c3b          	addw	s8,s8,a3
    printf("  trial %d: worker_blocking=%dK  worker_busy=%dK  wasted_spins=%dK\n",
 13e:	874e                	mv	a4,s3
 140:	2681                	sext.w	a3,a3
 142:	864a                	mv	a2,s2
 144:	85d2                	mv	a1,s4
 146:	856a                	mv	a0,s10
 148:	7c2000ef          	jal	ra,90a <printf>
  for(int t = 0; t < TRIALS; t++){
 14c:	2a05                	addiw	s4,s4,1
 14e:	f59a16e3          	bne	s4,s9,9a <main+0x74>
           t, bw, sw, sp);
  }

  int mb = sumb / TRIALS, ms = sums / TRIALS;
 152:	4795                	li	a5,5
 154:	02fbcbbb          	divw	s7,s7,a5
 158:	02fc493b          	divw	s2,s8,a5
  printf("\nmean: worker_blocking=%dK  worker_busy=%dK  (spinner burned ~%dK spins/window)\n",
 15c:	86ce                	mv	a3,s3
 15e:	0009061b          	sext.w	a2,s2
 162:	000b859b          	sext.w	a1,s7
 166:	00001517          	auipc	a0,0x1
 16a:	a7a50513          	addi	a0,a0,-1414 # be0 <malloc+0x21c>
 16e:	79c000ef          	jal	ra,90a <printf>
         mb, ms, last_spin);
  if(ms > 0){
 172:	4791                	li	a5,4
 174:	0787c563          	blt	a5,s8,1de <main+0x1b8>
    printf("blocking lets the worker do %d.%dx more useful work\n", r10/10, r10%10);
    printf("=> busy-wait wasted ~%d%% of the CPU that blocking returned to useful work\n",
           100 - (ms * 100 / mb));
  }

  munmap((void*)c, 4096);
 178:	6585                	lui	a1,0x1
 17a:	8526                	mv	a0,s1
 17c:	3da000ef          	jal	ra,556 <munmap>
  shmctl(KEY, IPC_RMID);
 180:	4581                	li	a1,0
 182:	04d00513          	li	a0,77
 186:	3d8000ef          	jal	ra,55e <shmctl>
  exit(0);
 18a:	4501                	li	a0,0
 18c:	322000ef          	jal	ra,4ae <exit>
  if(c == (void*)-1){ printf("mmap failed\n"); exit(1); }
 190:	00001517          	auipc	a0,0x1
 194:	91050513          	addi	a0,a0,-1776 # aa0 <malloc+0xdc>
 198:	772000ef          	jal	ra,90a <printf>
 19c:	4505                	li	a0,1
 19e:	310000ef          	jal	ra,4ae <exit>
  if(fork() == 0) worker(c);                 // worker child
 1a2:	8526                	mv	a0,s1
 1a4:	e5dff0ef          	jal	ra,0 <worker>
    sem_wait(SEM);
 1a8:	12c00513          	li	a0,300
 1ac:	3ca000ef          	jal	ra,576 <sem_wait>
    munmap((void*)c, 4096);
 1b0:	6585                	lui	a1,0x1
 1b2:	8526                	mv	a0,s1
 1b4:	3a2000ef          	jal	ra,556 <munmap>
    exit(0);
 1b8:	4501                	li	a0,0
 1ba:	2f4000ef          	jal	ra,4ae <exit>
  if(fork() == 0) worker(c);                 // worker child
 1be:	8526                	mv	a0,s1
 1c0:	e41ff0ef          	jal	ra,0 <worker>
    while(c->flag == 0) c->spins++;          // spin, burning CPU
 1c4:	649c                	ld	a5,8(s1)
 1c6:	0785                	addi	a5,a5,1
 1c8:	e49c                	sd	a5,8(s1)
 1ca:	48dc                	lw	a5,20(s1)
 1cc:	2781                	sext.w	a5,a5
 1ce:	dbfd                	beqz	a5,1c4 <main+0x19e>
    munmap((void*)c, 4096);
 1d0:	6585                	lui	a1,0x1
 1d2:	8526                	mv	a0,s1
 1d4:	382000ef          	jal	ra,556 <munmap>
    exit(0);
 1d8:	4501                	li	a0,0
 1da:	2d4000ef          	jal	ra,4ae <exit>
    int r10 = mb * 10 / ms;                  // ratio x10 for one decimal
 1de:	45a9                	li	a1,10
 1e0:	037587bb          	mulw	a5,a1,s7
 1e4:	0327c7bb          	divw	a5,a5,s2
    printf("blocking lets the worker do %d.%dx more useful work\n", r10/10, r10%10);
 1e8:	02b7e63b          	remw	a2,a5,a1
 1ec:	02b7c5bb          	divw	a1,a5,a1
 1f0:	00001517          	auipc	a0,0x1
 1f4:	a4850513          	addi	a0,a0,-1464 # c38 <malloc+0x274>
 1f8:	712000ef          	jal	ra,90a <printf>
           100 - (ms * 100 / mb));
 1fc:	06400593          	li	a1,100
 200:	032587bb          	mulw	a5,a1,s2
 204:	0377c7bb          	divw	a5,a5,s7
    printf("=> busy-wait wasted ~%d%% of the CPU that blocking returned to useful work\n",
 208:	9d9d                	subw	a1,a1,a5
 20a:	00001517          	auipc	a0,0x1
 20e:	a6650513          	addi	a0,a0,-1434 # c70 <malloc+0x2ac>
 212:	6f8000ef          	jal	ra,90a <printf>
 216:	b78d                	j	178 <main+0x152>

0000000000000218 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e406                	sd	ra,8(sp)
 21c:	e022                	sd	s0,0(sp)
 21e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 220:	e07ff0ef          	jal	ra,26 <main>
  exit(r);
 224:	28a000ef          	jal	ra,4ae <exit>

0000000000000228 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 22e:	87aa                	mv	a5,a0
 230:	0585                	addi	a1,a1,1
 232:	0785                	addi	a5,a5,1
 234:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x337>
 238:	fee78fa3          	sb	a4,-1(a5)
 23c:	fb75                	bnez	a4,230 <strcpy+0x8>
    ;
  return os;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret

0000000000000244 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 24a:	00054783          	lbu	a5,0(a0)
 24e:	cb91                	beqz	a5,262 <strcmp+0x1e>
 250:	0005c703          	lbu	a4,0(a1)
 254:	00f71763          	bne	a4,a5,262 <strcmp+0x1e>
    p++, q++;
 258:	0505                	addi	a0,a0,1
 25a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 25c:	00054783          	lbu	a5,0(a0)
 260:	fbe5                	bnez	a5,250 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 262:	0005c503          	lbu	a0,0(a1)
}
 266:	40a7853b          	subw	a0,a5,a0
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret

0000000000000270 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 276:	00054783          	lbu	a5,0(a0)
 27a:	cf91                	beqz	a5,296 <strlen+0x26>
 27c:	0505                	addi	a0,a0,1
 27e:	87aa                	mv	a5,a0
 280:	4685                	li	a3,1
 282:	9e89                	subw	a3,a3,a0
 284:	00f6853b          	addw	a0,a3,a5
 288:	0785                	addi	a5,a5,1
 28a:	fff7c703          	lbu	a4,-1(a5)
 28e:	fb7d                	bnez	a4,284 <strlen+0x14>
    ;
  return n;
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  for(n = 0; s[n]; n++)
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <strlen+0x20>

000000000000029a <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2a0:	ca19                	beqz	a2,2b6 <memset+0x1c>
 2a2:	87aa                	mv	a5,a0
 2a4:	1602                	slli	a2,a2,0x20
 2a6:	9201                	srli	a2,a2,0x20
 2a8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2ac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2b0:	0785                	addi	a5,a5,1
 2b2:	fee79de3          	bne	a5,a4,2ac <memset+0x12>
  }
  return dst;
}
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e422                	sd	s0,8(sp)
 2c0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	cb99                	beqz	a5,2dc <strchr+0x20>
    if(*s == c)
 2c8:	00f58763          	beq	a1,a5,2d6 <strchr+0x1a>
  for(; *s; s++)
 2cc:	0505                	addi	a0,a0,1
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	fbfd                	bnez	a5,2c8 <strchr+0xc>
      return (char*)s;
  return 0;
 2d4:	4501                	li	a0,0
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  return 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <strchr+0x1a>

00000000000002e0 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 2e0:	711d                	addi	sp,sp,-96
 2e2:	ec86                	sd	ra,88(sp)
 2e4:	e8a2                	sd	s0,80(sp)
 2e6:	e4a6                	sd	s1,72(sp)
 2e8:	e0ca                	sd	s2,64(sp)
 2ea:	fc4e                	sd	s3,56(sp)
 2ec:	f852                	sd	s4,48(sp)
 2ee:	f456                	sd	s5,40(sp)
 2f0:	f05a                	sd	s6,32(sp)
 2f2:	ec5e                	sd	s7,24(sp)
 2f4:	1080                	addi	s0,sp,96
 2f6:	8baa                	mv	s7,a0
 2f8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2fa:	892a                	mv	s2,a0
 2fc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2fe:	4aa9                	li	s5,10
 300:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 302:	89a6                	mv	s3,s1
 304:	2485                	addiw	s1,s1,1
 306:	0344d663          	bge	s1,s4,332 <gets+0x52>
    cc = read(0, &c, 1);
 30a:	4605                	li	a2,1
 30c:	faf40593          	addi	a1,s0,-81
 310:	4501                	li	a0,0
 312:	1b4000ef          	jal	ra,4c6 <read>
    if(cc < 1)
 316:	00a05e63          	blez	a0,332 <gets+0x52>
    buf[i++] = c;
 31a:	faf44783          	lbu	a5,-81(s0)
 31e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 322:	01578763          	beq	a5,s5,330 <gets+0x50>
 326:	0905                	addi	s2,s2,1
 328:	fd679de3          	bne	a5,s6,302 <gets+0x22>
  for(i=0; i+1 < max; ){
 32c:	89a6                	mv	s3,s1
 32e:	a011                	j	332 <gets+0x52>
 330:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 332:	99de                	add	s3,s3,s7
 334:	00098023          	sb	zero,0(s3)
  return buf;
}
 338:	855e                	mv	a0,s7
 33a:	60e6                	ld	ra,88(sp)
 33c:	6446                	ld	s0,80(sp)
 33e:	64a6                	ld	s1,72(sp)
 340:	6906                	ld	s2,64(sp)
 342:	79e2                	ld	s3,56(sp)
 344:	7a42                	ld	s4,48(sp)
 346:	7aa2                	ld	s5,40(sp)
 348:	7b02                	ld	s6,32(sp)
 34a:	6be2                	ld	s7,24(sp)
 34c:	6125                	addi	sp,sp,96
 34e:	8082                	ret

0000000000000350 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 350:	1101                	addi	sp,sp,-32
 352:	ec06                	sd	ra,24(sp)
 354:	e822                	sd	s0,16(sp)
 356:	e426                	sd	s1,8(sp)
 358:	e04a                	sd	s2,0(sp)
 35a:	1000                	addi	s0,sp,32
 35c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 35e:	4581                	li	a1,0
 360:	18e000ef          	jal	ra,4ee <open>
  if(fd < 0)
 364:	02054163          	bltz	a0,386 <stat+0x36>
 368:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 36a:	85ca                	mv	a1,s2
 36c:	19a000ef          	jal	ra,506 <fstat>
 370:	892a                	mv	s2,a0
  close(fd);
 372:	8526                	mv	a0,s1
 374:	162000ef          	jal	ra,4d6 <close>
  return r;
}
 378:	854a                	mv	a0,s2
 37a:	60e2                	ld	ra,24(sp)
 37c:	6442                	ld	s0,16(sp)
 37e:	64a2                	ld	s1,8(sp)
 380:	6902                	ld	s2,0(sp)
 382:	6105                	addi	sp,sp,32
 384:	8082                	ret
    return -1;
 386:	597d                	li	s2,-1
 388:	bfc5                	j	378 <stat+0x28>

000000000000038a <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e422                	sd	s0,8(sp)
 38e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 390:	00054603          	lbu	a2,0(a0)
 394:	fd06079b          	addiw	a5,a2,-48
 398:	0ff7f793          	andi	a5,a5,255
 39c:	4725                	li	a4,9
 39e:	02f76963          	bltu	a4,a5,3d0 <atoi+0x46>
 3a2:	86aa                	mv	a3,a0
  n = 0;
 3a4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3a6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3a8:	0685                	addi	a3,a3,1
 3aa:	0025179b          	slliw	a5,a0,0x2
 3ae:	9fa9                	addw	a5,a5,a0
 3b0:	0017979b          	slliw	a5,a5,0x1
 3b4:	9fb1                	addw	a5,a5,a2
 3b6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3ba:	0006c603          	lbu	a2,0(a3)
 3be:	fd06071b          	addiw	a4,a2,-48
 3c2:	0ff77713          	andi	a4,a4,255
 3c6:	fee5f1e3          	bgeu	a1,a4,3a8 <atoi+0x1e>
  return n;
}
 3ca:	6422                	ld	s0,8(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret
  n = 0;
 3d0:	4501                	li	a0,0
 3d2:	bfe5                	j	3ca <atoi+0x40>

00000000000003d4 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e422                	sd	s0,8(sp)
 3d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3da:	02b57463          	bgeu	a0,a1,402 <memmove+0x2e>
    while(n-- > 0)
 3de:	00c05f63          	blez	a2,3fc <memmove+0x28>
 3e2:	1602                	slli	a2,a2,0x20
 3e4:	9201                	srli	a2,a2,0x20
 3e6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ec:	0585                	addi	a1,a1,1
 3ee:	0705                	addi	a4,a4,1
 3f0:	fff5c683          	lbu	a3,-1(a1)
 3f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f8:	fee79ae3          	bne	a5,a4,3ec <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
    dst += n;
 402:	00c50733          	add	a4,a0,a2
    src += n;
 406:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 408:	fec05ae3          	blez	a2,3fc <memmove+0x28>
 40c:	fff6079b          	addiw	a5,a2,-1
 410:	1782                	slli	a5,a5,0x20
 412:	9381                	srli	a5,a5,0x20
 414:	fff7c793          	not	a5,a5
 418:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 41a:	15fd                	addi	a1,a1,-1
 41c:	177d                	addi	a4,a4,-1
 41e:	0005c683          	lbu	a3,0(a1)
 422:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 426:	fee79ae3          	bne	a5,a4,41a <memmove+0x46>
 42a:	bfc9                	j	3fc <memmove+0x28>

000000000000042c <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e422                	sd	s0,8(sp)
 430:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 432:	ca05                	beqz	a2,462 <memcmp+0x36>
 434:	fff6069b          	addiw	a3,a2,-1
 438:	1682                	slli	a3,a3,0x20
 43a:	9281                	srli	a3,a3,0x20
 43c:	0685                	addi	a3,a3,1
 43e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 440:	00054783          	lbu	a5,0(a0)
 444:	0005c703          	lbu	a4,0(a1)
 448:	00e79863          	bne	a5,a4,458 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 44c:	0505                	addi	a0,a0,1
    p2++;
 44e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 450:	fed518e3          	bne	a0,a3,440 <memcmp+0x14>
  }
  return 0;
 454:	4501                	li	a0,0
 456:	a019                	j	45c <memcmp+0x30>
      return *p1 - *p2;
 458:	40e7853b          	subw	a0,a5,a4
}
 45c:	6422                	ld	s0,8(sp)
 45e:	0141                	addi	sp,sp,16
 460:	8082                	ret
  return 0;
 462:	4501                	li	a0,0
 464:	bfe5                	j	45c <memcmp+0x30>

0000000000000466 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 466:	1141                	addi	sp,sp,-16
 468:	e406                	sd	ra,8(sp)
 46a:	e022                	sd	s0,0(sp)
 46c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 46e:	f67ff0ef          	jal	ra,3d4 <memmove>
}
 472:	60a2                	ld	ra,8(sp)
 474:	6402                	ld	s0,0(sp)
 476:	0141                	addi	sp,sp,16
 478:	8082                	ret

000000000000047a <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 47a:	1141                	addi	sp,sp,-16
 47c:	e406                	sd	ra,8(sp)
 47e:	e022                	sd	s0,0(sp)
 480:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 482:	4585                	li	a1,1
 484:	0b2000ef          	jal	ra,536 <sys_sbrk>
}
 488:	60a2                	ld	ra,8(sp)
 48a:	6402                	ld	s0,0(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret

0000000000000490 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 498:	4589                	li	a1,2
 49a:	09c000ef          	jal	ra,536 <sys_sbrk>
}
 49e:	60a2                	ld	ra,8(sp)
 4a0:	6402                	ld	s0,0(sp)
 4a2:	0141                	addi	sp,sp,16
 4a4:	8082                	ret

00000000000004a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a6:	4885                	li	a7,1
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ae:	4889                	li	a7,2
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b6:	488d                	li	a7,3
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4be:	4891                	li	a7,4
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <read>:
.global read
read:
 li a7, SYS_read
 4c6:	4895                	li	a7,5
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <write>:
.global write
write:
 li a7, SYS_write
 4ce:	48c1                	li	a7,16
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <close>:
.global close
close:
 li a7, SYS_close
 4d6:	48d5                	li	a7,21
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <kill>:
.global kill
kill:
 li a7, SYS_kill
 4de:	4899                	li	a7,6
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e6:	489d                	li	a7,7
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <open>:
.global open
open:
 li a7, SYS_open
 4ee:	48bd                	li	a7,15
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f6:	48c5                	li	a7,17
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4fe:	48c9                	li	a7,18
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 506:	48a1                	li	a7,8
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <link>:
.global link
link:
 li a7, SYS_link
 50e:	48cd                	li	a7,19
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 516:	48d1                	li	a7,20
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 51e:	48a5                	li	a7,9
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <dup>:
.global dup
dup:
 li a7, SYS_dup
 526:	48a9                	li	a7,10
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 52e:	48ad                	li	a7,11
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 536:	48b1                	li	a7,12
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <pause>:
.global pause
pause:
 li a7, SYS_pause
 53e:	48b5                	li	a7,13
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 546:	48b9                	li	a7,14
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 54e:	48d9                	li	a7,22
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 556:	48dd                	li	a7,23
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 55e:	48e1                	li	a7,24
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 566:	48e5                	li	a7,25
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 56e:	48e9                	li	a7,26
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 576:	48ed                	li	a7,27
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 57e:	48f1                	li	a7,28
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 586:	48f5                	li	a7,29
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 58e:	1101                	addi	sp,sp,-32
 590:	ec06                	sd	ra,24(sp)
 592:	e822                	sd	s0,16(sp)
 594:	1000                	addi	s0,sp,32
 596:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 59a:	4605                	li	a2,1
 59c:	fef40593          	addi	a1,s0,-17
 5a0:	f2fff0ef          	jal	ra,4ce <write>
}
 5a4:	60e2                	ld	ra,24(sp)
 5a6:	6442                	ld	s0,16(sp)
 5a8:	6105                	addi	sp,sp,32
 5aa:	8082                	ret

00000000000005ac <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 5ac:	715d                	addi	sp,sp,-80
 5ae:	e486                	sd	ra,72(sp)
 5b0:	e0a2                	sd	s0,64(sp)
 5b2:	fc26                	sd	s1,56(sp)
 5b4:	f84a                	sd	s2,48(sp)
 5b6:	f44e                	sd	s3,40(sp)
 5b8:	0880                	addi	s0,sp,80
 5ba:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5bc:	c299                	beqz	a3,5c2 <printint+0x16>
 5be:	0805c163          	bltz	a1,640 <printint+0x94>
  neg = 0;
 5c2:	4881                	li	a7,0
 5c4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5c8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5ca:	00000517          	auipc	a0,0x0
 5ce:	6fe50513          	addi	a0,a0,1790 # cc8 <digits>
 5d2:	883e                	mv	a6,a5
 5d4:	2785                	addiw	a5,a5,1
 5d6:	02c5f733          	remu	a4,a1,a2
 5da:	972a                	add	a4,a4,a0
 5dc:	00074703          	lbu	a4,0(a4)
 5e0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5e4:	872e                	mv	a4,a1
 5e6:	02c5d5b3          	divu	a1,a1,a2
 5ea:	0685                	addi	a3,a3,1
 5ec:	fec773e3          	bgeu	a4,a2,5d2 <printint+0x26>
  if(neg)
 5f0:	00088b63          	beqz	a7,606 <printint+0x5a>
    buf[i++] = '-';
 5f4:	fd040713          	addi	a4,s0,-48
 5f8:	97ba                	add	a5,a5,a4
 5fa:	02d00713          	li	a4,45
 5fe:	fee78423          	sb	a4,-24(a5)
 602:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 606:	02f05663          	blez	a5,632 <printint+0x86>
 60a:	fb840713          	addi	a4,s0,-72
 60e:	00f704b3          	add	s1,a4,a5
 612:	fff70993          	addi	s3,a4,-1
 616:	99be                	add	s3,s3,a5
 618:	37fd                	addiw	a5,a5,-1
 61a:	1782                	slli	a5,a5,0x20
 61c:	9381                	srli	a5,a5,0x20
 61e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 622:	fff4c583          	lbu	a1,-1(s1)
 626:	854a                	mv	a0,s2
 628:	f67ff0ef          	jal	ra,58e <putc>
  while(--i >= 0)
 62c:	14fd                	addi	s1,s1,-1
 62e:	ff349ae3          	bne	s1,s3,622 <printint+0x76>
}
 632:	60a6                	ld	ra,72(sp)
 634:	6406                	ld	s0,64(sp)
 636:	74e2                	ld	s1,56(sp)
 638:	7942                	ld	s2,48(sp)
 63a:	79a2                	ld	s3,40(sp)
 63c:	6161                	addi	sp,sp,80
 63e:	8082                	ret
    x = -xx;
 640:	40b005b3          	neg	a1,a1
    neg = 1;
 644:	4885                	li	a7,1
    x = -xx;
 646:	bfbd                	j	5c4 <printint+0x18>

0000000000000648 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 648:	7119                	addi	sp,sp,-128
 64a:	fc86                	sd	ra,120(sp)
 64c:	f8a2                	sd	s0,112(sp)
 64e:	f4a6                	sd	s1,104(sp)
 650:	f0ca                	sd	s2,96(sp)
 652:	ecce                	sd	s3,88(sp)
 654:	e8d2                	sd	s4,80(sp)
 656:	e4d6                	sd	s5,72(sp)
 658:	e0da                	sd	s6,64(sp)
 65a:	fc5e                	sd	s7,56(sp)
 65c:	f862                	sd	s8,48(sp)
 65e:	f466                	sd	s9,40(sp)
 660:	f06a                	sd	s10,32(sp)
 662:	ec6e                	sd	s11,24(sp)
 664:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 666:	0005c903          	lbu	s2,0(a1)
 66a:	24090c63          	beqz	s2,8c2 <vprintf+0x27a>
 66e:	8b2a                	mv	s6,a0
 670:	8a2e                	mv	s4,a1
 672:	8bb2                	mv	s7,a2
  state = 0;
 674:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 676:	4481                	li	s1,0
 678:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 67a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 67e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 682:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 686:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68a:	00000c97          	auipc	s9,0x0
 68e:	63ec8c93          	addi	s9,s9,1598 # cc8 <digits>
 692:	a005                	j	6b2 <vprintf+0x6a>
        putc(fd, c0);
 694:	85ca                	mv	a1,s2
 696:	855a                	mv	a0,s6
 698:	ef7ff0ef          	jal	ra,58e <putc>
 69c:	a019                	j	6a2 <vprintf+0x5a>
    } else if(state == '%'){
 69e:	03598263          	beq	s3,s5,6c2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6a2:	2485                	addiw	s1,s1,1
 6a4:	8726                	mv	a4,s1
 6a6:	009a07b3          	add	a5,s4,s1
 6aa:	0007c903          	lbu	s2,0(a5)
 6ae:	20090a63          	beqz	s2,8c2 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 6b2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6b6:	fe0994e3          	bnez	s3,69e <vprintf+0x56>
      if(c0 == '%'){
 6ba:	fd579de3          	bne	a5,s5,694 <vprintf+0x4c>
        state = '%';
 6be:	89be                	mv	s3,a5
 6c0:	b7cd                	j	6a2 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6c2:	c3c1                	beqz	a5,742 <vprintf+0xfa>
 6c4:	00ea06b3          	add	a3,s4,a4
 6c8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6cc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6ce:	c681                	beqz	a3,6d6 <vprintf+0x8e>
 6d0:	9752                	add	a4,a4,s4
 6d2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6d6:	03878e63          	beq	a5,s8,712 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 6da:	05a78863          	beq	a5,s10,72a <vprintf+0xe2>
      } else if(c0 == 'u'){
 6de:	0db78b63          	beq	a5,s11,7b4 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6e2:	07800713          	li	a4,120
 6e6:	10e78d63          	beq	a5,a4,800 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6ea:	07000713          	li	a4,112
 6ee:	14e78263          	beq	a5,a4,832 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6f2:	06300713          	li	a4,99
 6f6:	16e78f63          	beq	a5,a4,874 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6fa:	07300713          	li	a4,115
 6fe:	18e78563          	beq	a5,a4,888 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 702:	05579063          	bne	a5,s5,742 <vprintf+0xfa>
        putc(fd, '%');
 706:	85d6                	mv	a1,s5
 708:	855a                	mv	a0,s6
 70a:	e85ff0ef          	jal	ra,58e <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 70e:	4981                	li	s3,0
 710:	bf49                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 712:	008b8913          	addi	s2,s7,8
 716:	4685                	li	a3,1
 718:	4629                	li	a2,10
 71a:	000ba583          	lw	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	e8dff0ef          	jal	ra,5ac <printint>
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	bfad                	j	6a2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 72a:	03868663          	beq	a3,s8,756 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 72e:	05a68163          	beq	a3,s10,770 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 732:	09b68d63          	beq	a3,s11,7cc <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 736:	03a68f63          	beq	a3,s10,774 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 73a:	07800793          	li	a5,120
 73e:	0cf68d63          	beq	a3,a5,818 <vprintf+0x1d0>
        putc(fd, '%');
 742:	85d6                	mv	a1,s5
 744:	855a                	mv	a0,s6
 746:	e49ff0ef          	jal	ra,58e <putc>
        putc(fd, c0);
 74a:	85ca                	mv	a1,s2
 74c:	855a                	mv	a0,s6
 74e:	e41ff0ef          	jal	ra,58e <putc>
      state = 0;
 752:	4981                	li	s3,0
 754:	b7b9                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 756:	008b8913          	addi	s2,s7,8
 75a:	4685                	li	a3,1
 75c:	4629                	li	a2,10
 75e:	000bb583          	ld	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	e49ff0ef          	jal	ra,5ac <printint>
        i += 1;
 768:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 76a:	8bca                	mv	s7,s2
      state = 0;
 76c:	4981                	li	s3,0
        i += 1;
 76e:	bf15                	j	6a2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 770:	03860563          	beq	a2,s8,79a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 774:	07b60963          	beq	a2,s11,7e6 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 778:	07800793          	li	a5,120
 77c:	fcf613e3          	bne	a2,a5,742 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 780:	008b8913          	addi	s2,s7,8
 784:	4681                	li	a3,0
 786:	4641                	li	a2,16
 788:	000bb583          	ld	a1,0(s7)
 78c:	855a                	mv	a0,s6
 78e:	e1fff0ef          	jal	ra,5ac <printint>
        i += 2;
 792:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 794:	8bca                	mv	s7,s2
      state = 0;
 796:	4981                	li	s3,0
        i += 2;
 798:	b729                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 79a:	008b8913          	addi	s2,s7,8
 79e:	4685                	li	a3,1
 7a0:	4629                	li	a2,10
 7a2:	000bb583          	ld	a1,0(s7)
 7a6:	855a                	mv	a0,s6
 7a8:	e05ff0ef          	jal	ra,5ac <printint>
        i += 2;
 7ac:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ae:	8bca                	mv	s7,s2
      state = 0;
 7b0:	4981                	li	s3,0
        i += 2;
 7b2:	bdc5                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7b4:	008b8913          	addi	s2,s7,8
 7b8:	4681                	li	a3,0
 7ba:	4629                	li	a2,10
 7bc:	000be583          	lwu	a1,0(s7)
 7c0:	855a                	mv	a0,s6
 7c2:	debff0ef          	jal	ra,5ac <printint>
 7c6:	8bca                	mv	s7,s2
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	bde1                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7cc:	008b8913          	addi	s2,s7,8
 7d0:	4681                	li	a3,0
 7d2:	4629                	li	a2,10
 7d4:	000bb583          	ld	a1,0(s7)
 7d8:	855a                	mv	a0,s6
 7da:	dd3ff0ef          	jal	ra,5ac <printint>
        i += 1;
 7de:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e0:	8bca                	mv	s7,s2
      state = 0;
 7e2:	4981                	li	s3,0
        i += 1;
 7e4:	bd7d                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e6:	008b8913          	addi	s2,s7,8
 7ea:	4681                	li	a3,0
 7ec:	4629                	li	a2,10
 7ee:	000bb583          	ld	a1,0(s7)
 7f2:	855a                	mv	a0,s6
 7f4:	db9ff0ef          	jal	ra,5ac <printint>
        i += 2;
 7f8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fa:	8bca                	mv	s7,s2
      state = 0;
 7fc:	4981                	li	s3,0
        i += 2;
 7fe:	b555                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 800:	008b8913          	addi	s2,s7,8
 804:	4681                	li	a3,0
 806:	4641                	li	a2,16
 808:	000be583          	lwu	a1,0(s7)
 80c:	855a                	mv	a0,s6
 80e:	d9fff0ef          	jal	ra,5ac <printint>
 812:	8bca                	mv	s7,s2
      state = 0;
 814:	4981                	li	s3,0
 816:	b571                	j	6a2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 818:	008b8913          	addi	s2,s7,8
 81c:	4681                	li	a3,0
 81e:	4641                	li	a2,16
 820:	000bb583          	ld	a1,0(s7)
 824:	855a                	mv	a0,s6
 826:	d87ff0ef          	jal	ra,5ac <printint>
        i += 1;
 82a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 82c:	8bca                	mv	s7,s2
      state = 0;
 82e:	4981                	li	s3,0
        i += 1;
 830:	bd8d                	j	6a2 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 832:	008b8793          	addi	a5,s7,8
 836:	f8f43423          	sd	a5,-120(s0)
 83a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 83e:	03000593          	li	a1,48
 842:	855a                	mv	a0,s6
 844:	d4bff0ef          	jal	ra,58e <putc>
  putc(fd, 'x');
 848:	07800593          	li	a1,120
 84c:	855a                	mv	a0,s6
 84e:	d41ff0ef          	jal	ra,58e <putc>
 852:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 854:	03c9d793          	srli	a5,s3,0x3c
 858:	97e6                	add	a5,a5,s9
 85a:	0007c583          	lbu	a1,0(a5)
 85e:	855a                	mv	a0,s6
 860:	d2fff0ef          	jal	ra,58e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 864:	0992                	slli	s3,s3,0x4
 866:	397d                	addiw	s2,s2,-1
 868:	fe0916e3          	bnez	s2,854 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 86c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 870:	4981                	li	s3,0
 872:	bd05                	j	6a2 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 874:	008b8913          	addi	s2,s7,8
 878:	000bc583          	lbu	a1,0(s7)
 87c:	855a                	mv	a0,s6
 87e:	d11ff0ef          	jal	ra,58e <putc>
 882:	8bca                	mv	s7,s2
      state = 0;
 884:	4981                	li	s3,0
 886:	bd31                	j	6a2 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 888:	008b8993          	addi	s3,s7,8
 88c:	000bb903          	ld	s2,0(s7)
 890:	00090f63          	beqz	s2,8ae <vprintf+0x266>
        for(; *s; s++)
 894:	00094583          	lbu	a1,0(s2)
 898:	c195                	beqz	a1,8bc <vprintf+0x274>
          putc(fd, *s);
 89a:	855a                	mv	a0,s6
 89c:	cf3ff0ef          	jal	ra,58e <putc>
        for(; *s; s++)
 8a0:	0905                	addi	s2,s2,1
 8a2:	00094583          	lbu	a1,0(s2)
 8a6:	f9f5                	bnez	a1,89a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8a8:	8bce                	mv	s7,s3
      state = 0;
 8aa:	4981                	li	s3,0
 8ac:	bbdd                	j	6a2 <vprintf+0x5a>
          s = "(null)";
 8ae:	00000917          	auipc	s2,0x0
 8b2:	41290913          	addi	s2,s2,1042 # cc0 <malloc+0x2fc>
        for(; *s; s++)
 8b6:	02800593          	li	a1,40
 8ba:	b7c5                	j	89a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8bc:	8bce                	mv	s7,s3
      state = 0;
 8be:	4981                	li	s3,0
 8c0:	b3cd                	j	6a2 <vprintf+0x5a>
    }
  }
}
 8c2:	70e6                	ld	ra,120(sp)
 8c4:	7446                	ld	s0,112(sp)
 8c6:	74a6                	ld	s1,104(sp)
 8c8:	7906                	ld	s2,96(sp)
 8ca:	69e6                	ld	s3,88(sp)
 8cc:	6a46                	ld	s4,80(sp)
 8ce:	6aa6                	ld	s5,72(sp)
 8d0:	6b06                	ld	s6,64(sp)
 8d2:	7be2                	ld	s7,56(sp)
 8d4:	7c42                	ld	s8,48(sp)
 8d6:	7ca2                	ld	s9,40(sp)
 8d8:	7d02                	ld	s10,32(sp)
 8da:	6de2                	ld	s11,24(sp)
 8dc:	6109                	addi	sp,sp,128
 8de:	8082                	ret

00000000000008e0 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 8e0:	715d                	addi	sp,sp,-80
 8e2:	ec06                	sd	ra,24(sp)
 8e4:	e822                	sd	s0,16(sp)
 8e6:	1000                	addi	s0,sp,32
 8e8:	e010                	sd	a2,0(s0)
 8ea:	e414                	sd	a3,8(s0)
 8ec:	e818                	sd	a4,16(s0)
 8ee:	ec1c                	sd	a5,24(s0)
 8f0:	03043023          	sd	a6,32(s0)
 8f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8f8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8fc:	8622                	mv	a2,s0
 8fe:	d4bff0ef          	jal	ra,648 <vprintf>
}
 902:	60e2                	ld	ra,24(sp)
 904:	6442                	ld	s0,16(sp)
 906:	6161                	addi	sp,sp,80
 908:	8082                	ret

000000000000090a <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 90a:	711d                	addi	sp,sp,-96
 90c:	ec06                	sd	ra,24(sp)
 90e:	e822                	sd	s0,16(sp)
 910:	1000                	addi	s0,sp,32
 912:	e40c                	sd	a1,8(s0)
 914:	e810                	sd	a2,16(s0)
 916:	ec14                	sd	a3,24(s0)
 918:	f018                	sd	a4,32(s0)
 91a:	f41c                	sd	a5,40(s0)
 91c:	03043823          	sd	a6,48(s0)
 920:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 924:	00840613          	addi	a2,s0,8
 928:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 92c:	85aa                	mv	a1,a0
 92e:	4505                	li	a0,1
 930:	d19ff0ef          	jal	ra,648 <vprintf>
}
 934:	60e2                	ld	ra,24(sp)
 936:	6442                	ld	s0,16(sp)
 938:	6125                	addi	sp,sp,96
 93a:	8082                	ret

000000000000093c <free>:
 *   无
 */

void
free(void *ap)
{
 93c:	1141                	addi	sp,sp,-16
 93e:	e422                	sd	s0,8(sp)
 940:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 942:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 946:	00000797          	auipc	a5,0x0
 94a:	6ba7b783          	ld	a5,1722(a5) # 1000 <freep>
 94e:	a805                	j	97e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 950:	4618                	lw	a4,8(a2)
 952:	9db9                	addw	a1,a1,a4
 954:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 958:	6398                	ld	a4,0(a5)
 95a:	6318                	ld	a4,0(a4)
 95c:	fee53823          	sd	a4,-16(a0)
 960:	a091                	j	9a4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 962:	ff852703          	lw	a4,-8(a0)
 966:	9e39                	addw	a2,a2,a4
 968:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 96a:	ff053703          	ld	a4,-16(a0)
 96e:	e398                	sd	a4,0(a5)
 970:	a099                	j	9b6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 972:	6398                	ld	a4,0(a5)
 974:	00e7e463          	bltu	a5,a4,97c <free+0x40>
 978:	00e6ea63          	bltu	a3,a4,98c <free+0x50>
{
 97c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97e:	fed7fae3          	bgeu	a5,a3,972 <free+0x36>
 982:	6398                	ld	a4,0(a5)
 984:	00e6e463          	bltu	a3,a4,98c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 988:	fee7eae3          	bltu	a5,a4,97c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 98c:	ff852583          	lw	a1,-8(a0)
 990:	6390                	ld	a2,0(a5)
 992:	02059713          	slli	a4,a1,0x20
 996:	9301                	srli	a4,a4,0x20
 998:	0712                	slli	a4,a4,0x4
 99a:	9736                	add	a4,a4,a3
 99c:	fae60ae3          	beq	a2,a4,950 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9a0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9a4:	4790                	lw	a2,8(a5)
 9a6:	02061713          	slli	a4,a2,0x20
 9aa:	9301                	srli	a4,a4,0x20
 9ac:	0712                	slli	a4,a4,0x4
 9ae:	973e                	add	a4,a4,a5
 9b0:	fae689e3          	beq	a3,a4,962 <free+0x26>
  } else
    p->s.ptr = bp;
 9b4:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 9b6:	00000717          	auipc	a4,0x0
 9ba:	64f73523          	sd	a5,1610(a4) # 1000 <freep>
}
 9be:	6422                	ld	s0,8(sp)
 9c0:	0141                	addi	sp,sp,16
 9c2:	8082                	ret

00000000000009c4 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 9c4:	7139                	addi	sp,sp,-64
 9c6:	fc06                	sd	ra,56(sp)
 9c8:	f822                	sd	s0,48(sp)
 9ca:	f426                	sd	s1,40(sp)
 9cc:	f04a                	sd	s2,32(sp)
 9ce:	ec4e                	sd	s3,24(sp)
 9d0:	e852                	sd	s4,16(sp)
 9d2:	e456                	sd	s5,8(sp)
 9d4:	e05a                	sd	s6,0(sp)
 9d6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d8:	02051493          	slli	s1,a0,0x20
 9dc:	9081                	srli	s1,s1,0x20
 9de:	04bd                	addi	s1,s1,15
 9e0:	8091                	srli	s1,s1,0x4
 9e2:	0014899b          	addiw	s3,s1,1
 9e6:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 9e8:	00000517          	auipc	a0,0x0
 9ec:	61853503          	ld	a0,1560(a0) # 1000 <freep>
 9f0:	c515                	beqz	a0,a1c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 9f4:	4798                	lw	a4,8(a5)
 9f6:	02977f63          	bgeu	a4,s1,a34 <malloc+0x70>
 9fa:	8a4e                	mv	s4,s3
 9fc:	0009871b          	sext.w	a4,s3
 a00:	6685                	lui	a3,0x1
 a02:	00d77363          	bgeu	a4,a3,a08 <malloc+0x44>
 a06:	6a05                	lui	s4,0x1
 a08:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 a0c:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 a10:	00000917          	auipc	s2,0x0
 a14:	5f090913          	addi	s2,s2,1520 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 a18:	5afd                	li	s5,-1
 a1a:	a0bd                	j	a88 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 a1c:	00000797          	auipc	a5,0x0
 a20:	5f478793          	addi	a5,a5,1524 # 1010 <base>
 a24:	00000717          	auipc	a4,0x0
 a28:	5cf73e23          	sd	a5,1500(a4) # 1000 <freep>
 a2c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a2e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 a32:	b7e1                	j	9fa <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 a34:	02e48b63          	beq	s1,a4,a6a <malloc+0xa6>
        p->s.size -= nunits;
 a38:	4137073b          	subw	a4,a4,s3
 a3c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a3e:	1702                	slli	a4,a4,0x20
 a40:	9301                	srli	a4,a4,0x20
 a42:	0712                	slli	a4,a4,0x4
 a44:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a46:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 a4a:	00000717          	auipc	a4,0x0
 a4e:	5aa73b23          	sd	a0,1462(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 a52:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 a56:	70e2                	ld	ra,56(sp)
 a58:	7442                	ld	s0,48(sp)
 a5a:	74a2                	ld	s1,40(sp)
 a5c:	7902                	ld	s2,32(sp)
 a5e:	69e2                	ld	s3,24(sp)
 a60:	6a42                	ld	s4,16(sp)
 a62:	6aa2                	ld	s5,8(sp)
 a64:	6b02                	ld	s6,0(sp)
 a66:	6121                	addi	sp,sp,64
 a68:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a6a:	6398                	ld	a4,0(a5)
 a6c:	e118                	sd	a4,0(a0)
 a6e:	bff1                	j	a4a <malloc+0x86>
  hp->s.size = nu;
 a70:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 a74:	0541                	addi	a0,a0,16
 a76:	ec7ff0ef          	jal	ra,93c <free>
  return freep;
 a7a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a7e:	dd61                	beqz	a0,a56 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a80:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 a82:	4798                	lw	a4,8(a5)
 a84:	fa9778e3          	bgeu	a4,s1,a34 <malloc+0x70>
    if(p == freep)
 a88:	00093703          	ld	a4,0(s2)
 a8c:	853e                	mv	a0,a5
 a8e:	fef719e3          	bne	a4,a5,a80 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 a92:	8552                	mv	a0,s4
 a94:	9e7ff0ef          	jal	ra,47a <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 a98:	fd551ce3          	bne	a0,s5,a70 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 a9c:	4501                	li	a0,0
 a9e:	bf65                	j	a56 <malloc+0x92>
