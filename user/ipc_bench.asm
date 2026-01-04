
user/_ipc_bench：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_delta>:
};

static void
print_delta(char *tag, int t0, int t1,
            struct vmstats_user *a, struct vmstats_user *b)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	89ae                	mv	s3,a1
  12:	8a32                	mv	s4,a2
  14:	84b6                	mv	s1,a3
  16:	893a                	mv	s2,a4
  printf("\n=== %s ===\n", tag);
  18:	85aa                	mv	a1,a0
  1a:	00001517          	auipc	a0,0x1
  1e:	b7650513          	addi	a0,a0,-1162 # b90 <malloc+0xe4>
  22:	1d7000ef          	jal	ra,9f8 <printf>
  printf("time: %d ticks\n", t1 - t0);
  26:	413a05bb          	subw	a1,s4,s3
  2a:	00001517          	auipc	a0,0x1
  2e:	b7650513          	addi	a0,a0,-1162 # ba0 <malloc+0xf4>
  32:	1c7000ef          	jal	ra,9f8 <printf>
  printf("kalloc: %d\n", (int)(b->kalloc_cnt - a->kalloc_cnt));
  36:	01893583          	ld	a1,24(s2)
  3a:	6c9c                	ld	a5,24(s1)
  3c:	9d9d                	subw	a1,a1,a5
  3e:	00001517          	auipc	a0,0x1
  42:	b7250513          	addi	a0,a0,-1166 # bb0 <malloc+0x104>
  46:	1b3000ef          	jal	ra,9f8 <printf>
  printf("copyin_bytes: %d\n", (int)(b->copyin_bytes - a->copyin_bytes));
  4a:	02093583          	ld	a1,32(s2)
  4e:	709c                	ld	a5,32(s1)
  50:	9d9d                	subw	a1,a1,a5
  52:	00001517          	auipc	a0,0x1
  56:	b6e50513          	addi	a0,a0,-1170 # bc0 <malloc+0x114>
  5a:	19f000ef          	jal	ra,9f8 <printf>
  printf("copyout_bytes: %d\n", (int)(b->copyout_bytes - a->copyout_bytes));
  5e:	02893583          	ld	a1,40(s2)
  62:	749c                	ld	a5,40(s1)
  64:	9d9d                	subw	a1,a1,a5
  66:	00001517          	auipc	a0,0x1
  6a:	b7250513          	addi	a0,a0,-1166 # bd8 <malloc+0x12c>
  6e:	18b000ef          	jal	ra,9f8 <printf>
  printf("faults: cow=%d lazy=%d shm=%d\n",
         (int)(b->cow_faults - a->cow_faults),
         (int)(b->lazy_faults - a->lazy_faults),
         (int)(b->shm_faults - a->shm_faults));
  72:	01093503          	ld	a0,16(s2)
  76:	6894                	ld	a3,16(s1)
         (int)(b->lazy_faults - a->lazy_faults),
  78:	00893603          	ld	a2,8(s2)
  7c:	6498                	ld	a4,8(s1)
         (int)(b->cow_faults - a->cow_faults),
  7e:	00093583          	ld	a1,0(s2)
  82:	609c                	ld	a5,0(s1)
  printf("faults: cow=%d lazy=%d shm=%d\n",
  84:	40d506bb          	subw	a3,a0,a3
  88:	9e19                	subw	a2,a2,a4
  8a:	9d9d                	subw	a1,a1,a5
  8c:	00001517          	auipc	a0,0x1
  90:	b6450513          	addi	a0,a0,-1180 # bf0 <malloc+0x144>
  94:	165000ef          	jal	ra,9f8 <printf>
}
  98:	70a2                	ld	ra,40(sp)
  9a:	7402                	ld	s0,32(sp)
  9c:	64e2                	ld	s1,24(sp)
  9e:	6942                	ld	s2,16(sp)
  a0:	69a2                	ld	s3,8(sp)
  a2:	6a02                	ld	s4,0(sp)
  a4:	6145                	addi	sp,sp,48
  a6:	8082                	ret

00000000000000a8 <main>:
  shmctl(shmkey, IPC_RMID);  // 可选：清理
}

int
main(void)
{
  a8:	7121                	addi	sp,sp,-448
  aa:	ff06                	sd	ra,440(sp)
  ac:	fb22                	sd	s0,432(sp)
  ae:	f726                	sd	s1,424(sp)
  b0:	f34a                	sd	s2,416(sp)
  b2:	ef4e                	sd	s3,408(sp)
  b4:	eb52                	sd	s4,400(sp)
  b6:	e756                	sd	s5,392(sp)
  b8:	e35a                	sd	s6,384(sp)
  ba:	fede                	sd	s7,376(sp)
  bc:	0380                	addi	s0,sp,448
  struct vmstats_user a,b;
  int t0,t1;

  // pipe
  vmstats(&a);
  be:	f8040513          	addi	a0,s0,-128
  c2:	5b2000ef          	jal	ra,674 <vmstats>
  t0 = uptime();
  c6:	56e000ef          	jal	ra,634 <uptime>
  ca:	89aa                	mv	s3,a0
  if(pipe(pfd) < 0){
  cc:	e4840513          	addi	a0,s0,-440
  d0:	4dc000ef          	jal	ra,5ac <pipe>
  d4:	06054363          	bltz	a0,13a <main+0x92>
  int pid = fork();
  d8:	4bc000ef          	jal	ra,594 <fork>
  dc:	84aa                	mv	s1,a0
  if(pid == 0){
  de:	c53d                	beqz	a0,14c <main+0xa4>
  close(pfd[0]);
  e0:	e4842503          	lw	a0,-440(s0)
  e4:	4e0000ef          	jal	ra,5c4 <close>
  for(int i=0;i<CHUNK;i++) tmp[i] = (char)(i);
  e8:	e5040713          	addi	a4,s0,-432
  ec:	4781                	li	a5,0
  ee:	10000693          	li	a3,256
  f2:	00f70023          	sb	a5,0(a4)
  f6:	2785                	addiw	a5,a5,1
  f8:	0705                	addi	a4,a4,1
  fa:	fed79ce3          	bne	a5,a3,f2 <main+0x4a>
    int n = CHUNK;
  fe:	893e                	mv	s2,a5
  int sent = 0;
 100:	4a01                	li	s4,0
  while(sent < TOTAL_BYTES){
 102:	00800bb7          	lui	s7,0x800
    if(TOTAL_BYTES - sent < n) n = TOTAL_BYTES - sent;
 106:	00800b37          	lui	s6,0x800
 10a:	0ff00a93          	li	s5,255
    int n = CHUNK;
 10e:	84be                	mv	s1,a5
    if(write(pfd[1], tmp, n) != n){
 110:	864a                	mv	a2,s2
 112:	e5040593          	addi	a1,s0,-432
 116:	e4c42503          	lw	a0,-436(s0)
 11a:	4a2000ef          	jal	ra,5bc <write>
 11e:	06a91163          	bne	s2,a0,180 <main+0xd8>
    sent += n;
 122:	0149093b          	addw	s2,s2,s4
 126:	00090a1b          	sext.w	s4,s2
  while(sent < TOTAL_BYTES){
 12a:	077a5163          	bge	s4,s7,18c <main+0xe4>
    if(TOTAL_BYTES - sent < n) n = TOTAL_BYTES - sent;
 12e:	412b093b          	subw	s2,s6,s2
 132:	fd2adfe3          	bge	s5,s2,110 <main+0x68>
    int n = CHUNK;
 136:	8926                	mv	s2,s1
 138:	bfe1                	j	110 <main+0x68>
    printf("pipe failed\n");
 13a:	00001517          	auipc	a0,0x1
 13e:	ad650513          	addi	a0,a0,-1322 # c10 <malloc+0x164>
 142:	0b7000ef          	jal	ra,9f8 <printf>
    exit(1);
 146:	4505                	li	a0,1
 148:	454000ef          	jal	ra,59c <exit>
    close(pfd[1]);
 14c:	e4c42503          	lw	a0,-436(s0)
 150:	474000ef          	jal	ra,5c4 <close>
    while(got < TOTAL_BYTES){
 154:	00800937          	lui	s2,0x800
      int n = read(pfd[0], tmp, sizeof(tmp));
 158:	10000613          	li	a2,256
 15c:	e5040593          	addi	a1,s0,-432
 160:	e4842503          	lw	a0,-440(s0)
 164:	450000ef          	jal	ra,5b4 <read>
      if(n <= 0) break;
 168:	00a05563          	blez	a0,172 <main+0xca>
      got += n;
 16c:	9ca9                	addw	s1,s1,a0
    while(got < TOTAL_BYTES){
 16e:	ff24c5e3          	blt	s1,s2,158 <main+0xb0>
    close(pfd[0]);
 172:	e4842503          	lw	a0,-440(s0)
 176:	44e000ef          	jal	ra,5c4 <close>
    exit(0);
 17a:	4501                	li	a0,0
 17c:	420000ef          	jal	ra,59c <exit>
      printf("pipe write fail\n");
 180:	00001517          	auipc	a0,0x1
 184:	aa050513          	addi	a0,a0,-1376 # c20 <malloc+0x174>
 188:	071000ef          	jal	ra,9f8 <printf>
  close(pfd[1]);
 18c:	e4c42503          	lw	a0,-436(s0)
 190:	434000ef          	jal	ra,5c4 <close>
  wait(0);
 194:	4501                	li	a0,0
 196:	40e000ef          	jal	ra,5a4 <wait>
  bench_pipe();
  t1 = uptime();
 19a:	49a000ef          	jal	ra,634 <uptime>
 19e:	84aa                	mv	s1,a0
  vmstats(&b);
 1a0:	f5040513          	addi	a0,s0,-176
 1a4:	4d0000ef          	jal	ra,674 <vmstats>
  print_delta("PIPE IPC", t0, t1, &a, &b);
 1a8:	f5040713          	addi	a4,s0,-176
 1ac:	f8040693          	addi	a3,s0,-128
 1b0:	8626                	mv	a2,s1
 1b2:	85ce                	mv	a1,s3
 1b4:	00001517          	auipc	a0,0x1
 1b8:	a8450513          	addi	a0,a0,-1404 # c38 <malloc+0x18c>
 1bc:	e45ff0ef          	jal	ra,0 <print_delta>

  // shm+sem
  vmstats(&a);
 1c0:	f8040513          	addi	a0,s0,-128
 1c4:	4b0000ef          	jal	ra,674 <vmstats>
  t0 = uptime();
 1c8:	46c000ef          	jal	ra,634 <uptime>
 1cc:	8aaa                	mv	s5,a0
  struct shmring *r = (struct shmring*)mmap(0, 4096*20, PROT_READ|PROT_WRITE,
 1ce:	4729                	li	a4,10
 1d0:	468d                	li	a3,3
 1d2:	460d                	li	a2,3
 1d4:	65d1                	lui	a1,0x14
 1d6:	4501                	li	a0,0
 1d8:	464000ef          	jal	ra,63c <mmap>
 1dc:	84aa                	mv	s1,a0
  if(r == (void*)-1){
 1de:	57fd                	li	a5,-1
 1e0:	06f50e63          	beq	a0,a5,25c <main+0x1b4>
  r->head = r->tail = 0;
 1e4:	00052223          	sw	zero,4(a0)
 1e8:	00052023          	sw	zero,0(a0)
  if(sem_open(sem_empty, NCHUNK) < 0 || sem_open(sem_full, 0) < 0){
 1ec:	10000593          	li	a1,256
 1f0:	0c800513          	li	a0,200
 1f4:	468000ef          	jal	ra,65c <sem_open>
 1f8:	06054b63          	bltz	a0,26e <main+0x1c6>
 1fc:	4581                	li	a1,0
 1fe:	0c900513          	li	a0,201
 202:	45a000ef          	jal	ra,65c <sem_open>
 206:	06054463          	bltz	a0,26e <main+0x1c6>
  int pid = fork();
 20a:	38a000ef          	jal	ra,594 <fork>
  if(pid == 0){
 20e:	6921                	lui	s2,0x8
    for(int i=0;i<CHUNK;i++){
 210:	4981                	li	s3,0
 212:	10000a13          	li	s4,256
  if(pid == 0){
 216:	ed35                	bnez	a0,292 <main+0x1ea>
      int idx = r->tail % NCHUNK;
 218:	10000993          	li	s3,256
      sem_wait(sem_full);
 21c:	0c900513          	li	a0,201
 220:	444000ef          	jal	ra,664 <sem_wait>
      int idx = r->tail % NCHUNK;
 224:	40d8                	lw	a4,4(s1)
 226:	033767bb          	remw	a5,a4,s3
      volatile char x = r->buf[idx*CHUNK]; // 触碰一下，防止编译器全优化
 22a:	0087979b          	slliw	a5,a5,0x8
 22e:	97a6                	add	a5,a5,s1
 230:	0087c783          	lbu	a5,8(a5)
 234:	e4f40823          	sb	a5,-432(s0)
      (void)x;
 238:	e5044783          	lbu	a5,-432(s0)
      r->tail++;
 23c:	2705                	addiw	a4,a4,1
 23e:	c0d8                	sw	a4,4(s1)
      sem_post(sem_empty);
 240:	0c800513          	li	a0,200
 244:	428000ef          	jal	ra,66c <sem_post>
    while(got < TOTAL_BYTES){
 248:	397d                	addiw	s2,s2,-1 # 7fff <base+0x6fef>
 24a:	fc0919e3          	bnez	s2,21c <main+0x174>
    munmap((char*)r, 4096*20);
 24e:	65d1                	lui	a1,0x14
 250:	8526                	mv	a0,s1
 252:	3f2000ef          	jal	ra,644 <munmap>
    exit(0);
 256:	4501                	li	a0,0
 258:	344000ef          	jal	ra,59c <exit>
    printf("mmap shm fail\n");
 25c:	00001517          	auipc	a0,0x1
 260:	9ec50513          	addi	a0,a0,-1556 # c48 <malloc+0x19c>
 264:	794000ef          	jal	ra,9f8 <printf>
    exit(1);
 268:	4505                	li	a0,1
 26a:	332000ef          	jal	ra,59c <exit>
    printf("sem_open fail\n");
 26e:	00001517          	auipc	a0,0x1
 272:	9ea50513          	addi	a0,a0,-1558 # c58 <malloc+0x1ac>
 276:	782000ef          	jal	ra,9f8 <printf>
    exit(1);
 27a:	4505                	li	a0,1
 27c:	320000ef          	jal	ra,59c <exit>
    r->head++;
 280:	2705                	addiw	a4,a4,1
 282:	c098                	sw	a4,0(s1)
    sem_post(sem_full);
 284:	0c900513          	li	a0,201
 288:	3e4000ef          	jal	ra,66c <sem_post>
  while(sent < TOTAL_BYTES){
 28c:	397d                	addiw	s2,s2,-1
 28e:	02090c63          	beqz	s2,2c6 <main+0x21e>
    sem_wait(sem_empty);
 292:	0c800513          	li	a0,200
 296:	3ce000ef          	jal	ra,664 <sem_wait>
    int idx = r->head % NCHUNK;
 29a:	4098                	lw	a4,0(s1)
 29c:	41f7569b          	sraiw	a3,a4,0x1f
 2a0:	0186d69b          	srliw	a3,a3,0x18
 2a4:	00e687bb          	addw	a5,a3,a4
 2a8:	0ff7f793          	zext.b	a5,a5
 2ac:	9f95                	subw	a5,a5,a3
      r->buf[idx*CHUNK + i] = (char)(sent + i);
 2ae:	0087979b          	slliw	a5,a5,0x8
 2b2:	27a1                	addiw	a5,a5,8
 2b4:	97a6                	add	a5,a5,s1
    for(int i=0;i<CHUNK;i++){
 2b6:	86ce                	mv	a3,s3
      r->buf[idx*CHUNK + i] = (char)(sent + i);
 2b8:	00d78023          	sb	a3,0(a5)
    for(int i=0;i<CHUNK;i++){
 2bc:	2685                	addiw	a3,a3,1
 2be:	0785                	addi	a5,a5,1
 2c0:	ff469ce3          	bne	a3,s4,2b8 <main+0x210>
 2c4:	bf75                	j	280 <main+0x1d8>
  wait(0);
 2c6:	4501                	li	a0,0
 2c8:	2dc000ef          	jal	ra,5a4 <wait>
  munmap((char*)r, 4096*20);
 2cc:	65d1                	lui	a1,0x14
 2ce:	8526                	mv	a0,s1
 2d0:	374000ef          	jal	ra,644 <munmap>
  shmctl(shmkey, IPC_RMID);  // 可选：清理
 2d4:	4581                	li	a1,0
 2d6:	4529                	li	a0,10
 2d8:	374000ef          	jal	ra,64c <shmctl>
  bench_shm_sem();
  t1 = uptime();
 2dc:	358000ef          	jal	ra,634 <uptime>
 2e0:	84aa                	mv	s1,a0
  vmstats(&b);
 2e2:	f5040513          	addi	a0,s0,-176
 2e6:	38e000ef          	jal	ra,674 <vmstats>
  print_delta("SHM+SEM IPC", t0, t1, &a, &b);
 2ea:	f5040713          	addi	a4,s0,-176
 2ee:	f8040693          	addi	a3,s0,-128
 2f2:	8626                	mv	a2,s1
 2f4:	85d6                	mv	a1,s5
 2f6:	00001517          	auipc	a0,0x1
 2fa:	97250513          	addi	a0,a0,-1678 # c68 <malloc+0x1bc>
 2fe:	d03ff0ef          	jal	ra,0 <print_delta>

  exit(0);
 302:	4501                	li	a0,0
 304:	298000ef          	jal	ra,59c <exit>

0000000000000308 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 310:	d99ff0ef          	jal	ra,a8 <main>
  exit(r);
 314:	288000ef          	jal	ra,59c <exit>

0000000000000318 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e422                	sd	s0,8(sp)
 31c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 31e:	87aa                	mv	a5,a0
 320:	0585                	addi	a1,a1,1 # 14001 <base+0x12ff1>
 322:	0785                	addi	a5,a5,1
 324:	fff5c703          	lbu	a4,-1(a1)
 328:	fee78fa3          	sb	a4,-1(a5)
 32c:	fb75                	bnez	a4,320 <strcpy+0x8>
    ;
  return os;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 334:	1141                	addi	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 33a:	00054783          	lbu	a5,0(a0)
 33e:	cb91                	beqz	a5,352 <strcmp+0x1e>
 340:	0005c703          	lbu	a4,0(a1)
 344:	00f71763          	bne	a4,a5,352 <strcmp+0x1e>
    p++, q++;
 348:	0505                	addi	a0,a0,1
 34a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 34c:	00054783          	lbu	a5,0(a0)
 350:	fbe5                	bnez	a5,340 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 352:	0005c503          	lbu	a0,0(a1)
}
 356:	40a7853b          	subw	a0,a5,a0
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret

0000000000000360 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 366:	00054783          	lbu	a5,0(a0)
 36a:	cf91                	beqz	a5,386 <strlen+0x26>
 36c:	0505                	addi	a0,a0,1
 36e:	87aa                	mv	a5,a0
 370:	4685                	li	a3,1
 372:	9e89                	subw	a3,a3,a0
 374:	00f6853b          	addw	a0,a3,a5
 378:	0785                	addi	a5,a5,1
 37a:	fff7c703          	lbu	a4,-1(a5)
 37e:	fb7d                	bnez	a4,374 <strlen+0x14>
    ;
  return n;
}
 380:	6422                	ld	s0,8(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret
  for(n = 0; s[n]; n++)
 386:	4501                	li	a0,0
 388:	bfe5                	j	380 <strlen+0x20>

000000000000038a <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e422                	sd	s0,8(sp)
 38e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 390:	ca19                	beqz	a2,3a6 <memset+0x1c>
 392:	87aa                	mv	a5,a0
 394:	1602                	slli	a2,a2,0x20
 396:	9201                	srli	a2,a2,0x20
 398:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 39c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3a0:	0785                	addi	a5,a5,1
 3a2:	fee79de3          	bne	a5,a4,39c <memset+0x12>
  }
  return dst;
}
 3a6:	6422                	ld	s0,8(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret

00000000000003ac <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e422                	sd	s0,8(sp)
 3b0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3b2:	00054783          	lbu	a5,0(a0)
 3b6:	cb99                	beqz	a5,3cc <strchr+0x20>
    if(*s == c)
 3b8:	00f58763          	beq	a1,a5,3c6 <strchr+0x1a>
  for(; *s; s++)
 3bc:	0505                	addi	a0,a0,1
 3be:	00054783          	lbu	a5,0(a0)
 3c2:	fbfd                	bnez	a5,3b8 <strchr+0xc>
      return (char*)s;
  return 0;
 3c4:	4501                	li	a0,0
}
 3c6:	6422                	ld	s0,8(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret
  return 0;
 3cc:	4501                	li	a0,0
 3ce:	bfe5                	j	3c6 <strchr+0x1a>

00000000000003d0 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 3d0:	711d                	addi	sp,sp,-96
 3d2:	ec86                	sd	ra,88(sp)
 3d4:	e8a2                	sd	s0,80(sp)
 3d6:	e4a6                	sd	s1,72(sp)
 3d8:	e0ca                	sd	s2,64(sp)
 3da:	fc4e                	sd	s3,56(sp)
 3dc:	f852                	sd	s4,48(sp)
 3de:	f456                	sd	s5,40(sp)
 3e0:	f05a                	sd	s6,32(sp)
 3e2:	ec5e                	sd	s7,24(sp)
 3e4:	1080                	addi	s0,sp,96
 3e6:	8baa                	mv	s7,a0
 3e8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ea:	892a                	mv	s2,a0
 3ec:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ee:	4aa9                	li	s5,10
 3f0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3f2:	89a6                	mv	s3,s1
 3f4:	2485                	addiw	s1,s1,1
 3f6:	0344d663          	bge	s1,s4,422 <gets+0x52>
    cc = read(0, &c, 1);
 3fa:	4605                	li	a2,1
 3fc:	faf40593          	addi	a1,s0,-81
 400:	4501                	li	a0,0
 402:	1b2000ef          	jal	ra,5b4 <read>
    if(cc < 1)
 406:	00a05e63          	blez	a0,422 <gets+0x52>
    buf[i++] = c;
 40a:	faf44783          	lbu	a5,-81(s0)
 40e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 412:	01578763          	beq	a5,s5,420 <gets+0x50>
 416:	0905                	addi	s2,s2,1
 418:	fd679de3          	bne	a5,s6,3f2 <gets+0x22>
  for(i=0; i+1 < max; ){
 41c:	89a6                	mv	s3,s1
 41e:	a011                	j	422 <gets+0x52>
 420:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 422:	99de                	add	s3,s3,s7
 424:	00098023          	sb	zero,0(s3)
  return buf;
}
 428:	855e                	mv	a0,s7
 42a:	60e6                	ld	ra,88(sp)
 42c:	6446                	ld	s0,80(sp)
 42e:	64a6                	ld	s1,72(sp)
 430:	6906                	ld	s2,64(sp)
 432:	79e2                	ld	s3,56(sp)
 434:	7a42                	ld	s4,48(sp)
 436:	7aa2                	ld	s5,40(sp)
 438:	7b02                	ld	s6,32(sp)
 43a:	6be2                	ld	s7,24(sp)
 43c:	6125                	addi	sp,sp,96
 43e:	8082                	ret

0000000000000440 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 440:	1101                	addi	sp,sp,-32
 442:	ec06                	sd	ra,24(sp)
 444:	e822                	sd	s0,16(sp)
 446:	e426                	sd	s1,8(sp)
 448:	e04a                	sd	s2,0(sp)
 44a:	1000                	addi	s0,sp,32
 44c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 44e:	4581                	li	a1,0
 450:	18c000ef          	jal	ra,5dc <open>
  if(fd < 0)
 454:	02054163          	bltz	a0,476 <stat+0x36>
 458:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 45a:	85ca                	mv	a1,s2
 45c:	198000ef          	jal	ra,5f4 <fstat>
 460:	892a                	mv	s2,a0
  close(fd);
 462:	8526                	mv	a0,s1
 464:	160000ef          	jal	ra,5c4 <close>
  return r;
}
 468:	854a                	mv	a0,s2
 46a:	60e2                	ld	ra,24(sp)
 46c:	6442                	ld	s0,16(sp)
 46e:	64a2                	ld	s1,8(sp)
 470:	6902                	ld	s2,0(sp)
 472:	6105                	addi	sp,sp,32
 474:	8082                	ret
    return -1;
 476:	597d                	li	s2,-1
 478:	bfc5                	j	468 <stat+0x28>

000000000000047a <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 47a:	1141                	addi	sp,sp,-16
 47c:	e422                	sd	s0,8(sp)
 47e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 480:	00054683          	lbu	a3,0(a0)
 484:	fd06879b          	addiw	a5,a3,-48
 488:	0ff7f793          	zext.b	a5,a5
 48c:	4625                	li	a2,9
 48e:	02f66863          	bltu	a2,a5,4be <atoi+0x44>
 492:	872a                	mv	a4,a0
  n = 0;
 494:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 496:	0705                	addi	a4,a4,1
 498:	0025179b          	slliw	a5,a0,0x2
 49c:	9fa9                	addw	a5,a5,a0
 49e:	0017979b          	slliw	a5,a5,0x1
 4a2:	9fb5                	addw	a5,a5,a3
 4a4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4a8:	00074683          	lbu	a3,0(a4)
 4ac:	fd06879b          	addiw	a5,a3,-48
 4b0:	0ff7f793          	zext.b	a5,a5
 4b4:	fef671e3          	bgeu	a2,a5,496 <atoi+0x1c>
  return n;
}
 4b8:	6422                	ld	s0,8(sp)
 4ba:	0141                	addi	sp,sp,16
 4bc:	8082                	ret
  n = 0;
 4be:	4501                	li	a0,0
 4c0:	bfe5                	j	4b8 <atoi+0x3e>

00000000000004c2 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c2:	1141                	addi	sp,sp,-16
 4c4:	e422                	sd	s0,8(sp)
 4c6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4c8:	02b57463          	bgeu	a0,a1,4f0 <memmove+0x2e>
    while(n-- > 0)
 4cc:	00c05f63          	blez	a2,4ea <memmove+0x28>
 4d0:	1602                	slli	a2,a2,0x20
 4d2:	9201                	srli	a2,a2,0x20
 4d4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4d8:	872a                	mv	a4,a0
      *dst++ = *src++;
 4da:	0585                	addi	a1,a1,1
 4dc:	0705                	addi	a4,a4,1
 4de:	fff5c683          	lbu	a3,-1(a1)
 4e2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4e6:	fee79ae3          	bne	a5,a4,4da <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ea:	6422                	ld	s0,8(sp)
 4ec:	0141                	addi	sp,sp,16
 4ee:	8082                	ret
    dst += n;
 4f0:	00c50733          	add	a4,a0,a2
    src += n;
 4f4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4f6:	fec05ae3          	blez	a2,4ea <memmove+0x28>
 4fa:	fff6079b          	addiw	a5,a2,-1
 4fe:	1782                	slli	a5,a5,0x20
 500:	9381                	srli	a5,a5,0x20
 502:	fff7c793          	not	a5,a5
 506:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 508:	15fd                	addi	a1,a1,-1
 50a:	177d                	addi	a4,a4,-1
 50c:	0005c683          	lbu	a3,0(a1)
 510:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 514:	fee79ae3          	bne	a5,a4,508 <memmove+0x46>
 518:	bfc9                	j	4ea <memmove+0x28>

000000000000051a <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 51a:	1141                	addi	sp,sp,-16
 51c:	e422                	sd	s0,8(sp)
 51e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 520:	ca05                	beqz	a2,550 <memcmp+0x36>
 522:	fff6069b          	addiw	a3,a2,-1
 526:	1682                	slli	a3,a3,0x20
 528:	9281                	srli	a3,a3,0x20
 52a:	0685                	addi	a3,a3,1
 52c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 52e:	00054783          	lbu	a5,0(a0)
 532:	0005c703          	lbu	a4,0(a1)
 536:	00e79863          	bne	a5,a4,546 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 53a:	0505                	addi	a0,a0,1
    p2++;
 53c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 53e:	fed518e3          	bne	a0,a3,52e <memcmp+0x14>
  }
  return 0;
 542:	4501                	li	a0,0
 544:	a019                	j	54a <memcmp+0x30>
      return *p1 - *p2;
 546:	40e7853b          	subw	a0,a5,a4
}
 54a:	6422                	ld	s0,8(sp)
 54c:	0141                	addi	sp,sp,16
 54e:	8082                	ret
  return 0;
 550:	4501                	li	a0,0
 552:	bfe5                	j	54a <memcmp+0x30>

0000000000000554 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 554:	1141                	addi	sp,sp,-16
 556:	e406                	sd	ra,8(sp)
 558:	e022                	sd	s0,0(sp)
 55a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 55c:	f67ff0ef          	jal	ra,4c2 <memmove>
}
 560:	60a2                	ld	ra,8(sp)
 562:	6402                	ld	s0,0(sp)
 564:	0141                	addi	sp,sp,16
 566:	8082                	ret

0000000000000568 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 568:	1141                	addi	sp,sp,-16
 56a:	e406                	sd	ra,8(sp)
 56c:	e022                	sd	s0,0(sp)
 56e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 570:	4585                	li	a1,1
 572:	0b2000ef          	jal	ra,624 <sys_sbrk>
}
 576:	60a2                	ld	ra,8(sp)
 578:	6402                	ld	s0,0(sp)
 57a:	0141                	addi	sp,sp,16
 57c:	8082                	ret

000000000000057e <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 57e:	1141                	addi	sp,sp,-16
 580:	e406                	sd	ra,8(sp)
 582:	e022                	sd	s0,0(sp)
 584:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 586:	4589                	li	a1,2
 588:	09c000ef          	jal	ra,624 <sys_sbrk>
}
 58c:	60a2                	ld	ra,8(sp)
 58e:	6402                	ld	s0,0(sp)
 590:	0141                	addi	sp,sp,16
 592:	8082                	ret

0000000000000594 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 594:	4885                	li	a7,1
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <exit>:
.global exit
exit:
 li a7, SYS_exit
 59c:	4889                	li	a7,2
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5a4:	488d                	li	a7,3
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ac:	4891                	li	a7,4
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <read>:
.global read
read:
 li a7, SYS_read
 5b4:	4895                	li	a7,5
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <write>:
.global write
write:
 li a7, SYS_write
 5bc:	48c1                	li	a7,16
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <close>:
.global close
close:
 li a7, SYS_close
 5c4:	48d5                	li	a7,21
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <kill>:
.global kill
kill:
 li a7, SYS_kill
 5cc:	4899                	li	a7,6
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5d4:	489d                	li	a7,7
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <open>:
.global open
open:
 li a7, SYS_open
 5dc:	48bd                	li	a7,15
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5e4:	48c5                	li	a7,17
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5ec:	48c9                	li	a7,18
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5f4:	48a1                	li	a7,8
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <link>:
.global link
link:
 li a7, SYS_link
 5fc:	48cd                	li	a7,19
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 604:	48d1                	li	a7,20
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 60c:	48a5                	li	a7,9
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <dup>:
.global dup
dup:
 li a7, SYS_dup
 614:	48a9                	li	a7,10
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 61c:	48ad                	li	a7,11
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 624:	48b1                	li	a7,12
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <pause>:
.global pause
pause:
 li a7, SYS_pause
 62c:	48b5                	li	a7,13
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 634:	48b9                	li	a7,14
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 63c:	48d9                	li	a7,22
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 644:	48dd                	li	a7,23
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 64c:	48e1                	li	a7,24
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 654:	48e5                	li	a7,25
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 65c:	48e9                	li	a7,26
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 664:	48ed                	li	a7,27
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 66c:	48f1                	li	a7,28
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 674:	48f5                	li	a7,29
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 67c:	1101                	addi	sp,sp,-32
 67e:	ec06                	sd	ra,24(sp)
 680:	e822                	sd	s0,16(sp)
 682:	1000                	addi	s0,sp,32
 684:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 688:	4605                	li	a2,1
 68a:	fef40593          	addi	a1,s0,-17
 68e:	f2fff0ef          	jal	ra,5bc <write>
}
 692:	60e2                	ld	ra,24(sp)
 694:	6442                	ld	s0,16(sp)
 696:	6105                	addi	sp,sp,32
 698:	8082                	ret

000000000000069a <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 69a:	715d                	addi	sp,sp,-80
 69c:	e486                	sd	ra,72(sp)
 69e:	e0a2                	sd	s0,64(sp)
 6a0:	fc26                	sd	s1,56(sp)
 6a2:	f84a                	sd	s2,48(sp)
 6a4:	f44e                	sd	s3,40(sp)
 6a6:	0880                	addi	s0,sp,80
 6a8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 6aa:	c299                	beqz	a3,6b0 <printint+0x16>
 6ac:	0805c163          	bltz	a1,72e <printint+0x94>
  neg = 0;
 6b0:	4881                	li	a7,0
 6b2:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6b6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 6b8:	00000517          	auipc	a0,0x0
 6bc:	5c850513          	addi	a0,a0,1480 # c80 <digits>
 6c0:	883e                	mv	a6,a5
 6c2:	2785                	addiw	a5,a5,1
 6c4:	02c5f733          	remu	a4,a1,a2
 6c8:	972a                	add	a4,a4,a0
 6ca:	00074703          	lbu	a4,0(a4)
 6ce:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6d2:	872e                	mv	a4,a1
 6d4:	02c5d5b3          	divu	a1,a1,a2
 6d8:	0685                	addi	a3,a3,1
 6da:	fec773e3          	bgeu	a4,a2,6c0 <printint+0x26>
  if(neg)
 6de:	00088b63          	beqz	a7,6f4 <printint+0x5a>
    buf[i++] = '-';
 6e2:	fd078793          	addi	a5,a5,-48
 6e6:	97a2                	add	a5,a5,s0
 6e8:	02d00713          	li	a4,45
 6ec:	fee78423          	sb	a4,-24(a5)
 6f0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 6f4:	02f05663          	blez	a5,720 <printint+0x86>
 6f8:	fb840713          	addi	a4,s0,-72
 6fc:	00f704b3          	add	s1,a4,a5
 700:	fff70993          	addi	s3,a4,-1
 704:	99be                	add	s3,s3,a5
 706:	37fd                	addiw	a5,a5,-1
 708:	1782                	slli	a5,a5,0x20
 70a:	9381                	srli	a5,a5,0x20
 70c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 710:	fff4c583          	lbu	a1,-1(s1)
 714:	854a                	mv	a0,s2
 716:	f67ff0ef          	jal	ra,67c <putc>
  while(--i >= 0)
 71a:	14fd                	addi	s1,s1,-1
 71c:	ff349ae3          	bne	s1,s3,710 <printint+0x76>
}
 720:	60a6                	ld	ra,72(sp)
 722:	6406                	ld	s0,64(sp)
 724:	74e2                	ld	s1,56(sp)
 726:	7942                	ld	s2,48(sp)
 728:	79a2                	ld	s3,40(sp)
 72a:	6161                	addi	sp,sp,80
 72c:	8082                	ret
    x = -xx;
 72e:	40b005b3          	neg	a1,a1
    neg = 1;
 732:	4885                	li	a7,1
    x = -xx;
 734:	bfbd                	j	6b2 <printint+0x18>

0000000000000736 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 736:	7119                	addi	sp,sp,-128
 738:	fc86                	sd	ra,120(sp)
 73a:	f8a2                	sd	s0,112(sp)
 73c:	f4a6                	sd	s1,104(sp)
 73e:	f0ca                	sd	s2,96(sp)
 740:	ecce                	sd	s3,88(sp)
 742:	e8d2                	sd	s4,80(sp)
 744:	e4d6                	sd	s5,72(sp)
 746:	e0da                	sd	s6,64(sp)
 748:	fc5e                	sd	s7,56(sp)
 74a:	f862                	sd	s8,48(sp)
 74c:	f466                	sd	s9,40(sp)
 74e:	f06a                	sd	s10,32(sp)
 750:	ec6e                	sd	s11,24(sp)
 752:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 754:	0005c903          	lbu	s2,0(a1)
 758:	24090c63          	beqz	s2,9b0 <vprintf+0x27a>
 75c:	8b2a                	mv	s6,a0
 75e:	8a2e                	mv	s4,a1
 760:	8bb2                	mv	s7,a2
  state = 0;
 762:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 764:	4481                	li	s1,0
 766:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 768:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 76c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 770:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 774:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 778:	00000c97          	auipc	s9,0x0
 77c:	508c8c93          	addi	s9,s9,1288 # c80 <digits>
 780:	a005                	j	7a0 <vprintf+0x6a>
        putc(fd, c0);
 782:	85ca                	mv	a1,s2
 784:	855a                	mv	a0,s6
 786:	ef7ff0ef          	jal	ra,67c <putc>
 78a:	a019                	j	790 <vprintf+0x5a>
    } else if(state == '%'){
 78c:	03598263          	beq	s3,s5,7b0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 790:	2485                	addiw	s1,s1,1
 792:	8726                	mv	a4,s1
 794:	009a07b3          	add	a5,s4,s1
 798:	0007c903          	lbu	s2,0(a5)
 79c:	20090a63          	beqz	s2,9b0 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 7a0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7a4:	fe0994e3          	bnez	s3,78c <vprintf+0x56>
      if(c0 == '%'){
 7a8:	fd579de3          	bne	a5,s5,782 <vprintf+0x4c>
        state = '%';
 7ac:	89be                	mv	s3,a5
 7ae:	b7cd                	j	790 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 7b0:	c3c1                	beqz	a5,830 <vprintf+0xfa>
 7b2:	00ea06b3          	add	a3,s4,a4
 7b6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7ba:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 7bc:	c681                	beqz	a3,7c4 <vprintf+0x8e>
 7be:	9752                	add	a4,a4,s4
 7c0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 7c4:	03878e63          	beq	a5,s8,800 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 7c8:	05a78863          	beq	a5,s10,818 <vprintf+0xe2>
      } else if(c0 == 'u'){
 7cc:	0db78b63          	beq	a5,s11,8a2 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7d0:	07800713          	li	a4,120
 7d4:	10e78d63          	beq	a5,a4,8ee <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7d8:	07000713          	li	a4,112
 7dc:	14e78263          	beq	a5,a4,920 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7e0:	06300713          	li	a4,99
 7e4:	16e78f63          	beq	a5,a4,962 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 7e8:	07300713          	li	a4,115
 7ec:	18e78563          	beq	a5,a4,976 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7f0:	05579063          	bne	a5,s5,830 <vprintf+0xfa>
        putc(fd, '%');
 7f4:	85d6                	mv	a1,s5
 7f6:	855a                	mv	a0,s6
 7f8:	e85ff0ef          	jal	ra,67c <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	bf49                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 800:	008b8913          	addi	s2,s7,8 # 800008 <base+0x7feff8>
 804:	4685                	li	a3,1
 806:	4629                	li	a2,10
 808:	000ba583          	lw	a1,0(s7)
 80c:	855a                	mv	a0,s6
 80e:	e8dff0ef          	jal	ra,69a <printint>
 812:	8bca                	mv	s7,s2
      state = 0;
 814:	4981                	li	s3,0
 816:	bfad                	j	790 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 818:	03868663          	beq	a3,s8,844 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 81c:	05a68163          	beq	a3,s10,85e <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 820:	09b68d63          	beq	a3,s11,8ba <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 824:	03a68f63          	beq	a3,s10,862 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 828:	07800793          	li	a5,120
 82c:	0cf68d63          	beq	a3,a5,906 <vprintf+0x1d0>
        putc(fd, '%');
 830:	85d6                	mv	a1,s5
 832:	855a                	mv	a0,s6
 834:	e49ff0ef          	jal	ra,67c <putc>
        putc(fd, c0);
 838:	85ca                	mv	a1,s2
 83a:	855a                	mv	a0,s6
 83c:	e41ff0ef          	jal	ra,67c <putc>
      state = 0;
 840:	4981                	li	s3,0
 842:	b7b9                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 844:	008b8913          	addi	s2,s7,8
 848:	4685                	li	a3,1
 84a:	4629                	li	a2,10
 84c:	000bb583          	ld	a1,0(s7)
 850:	855a                	mv	a0,s6
 852:	e49ff0ef          	jal	ra,69a <printint>
        i += 1;
 856:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 858:	8bca                	mv	s7,s2
      state = 0;
 85a:	4981                	li	s3,0
        i += 1;
 85c:	bf15                	j	790 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 85e:	03860563          	beq	a2,s8,888 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 862:	07b60963          	beq	a2,s11,8d4 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 866:	07800793          	li	a5,120
 86a:	fcf613e3          	bne	a2,a5,830 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 86e:	008b8913          	addi	s2,s7,8
 872:	4681                	li	a3,0
 874:	4641                	li	a2,16
 876:	000bb583          	ld	a1,0(s7)
 87a:	855a                	mv	a0,s6
 87c:	e1fff0ef          	jal	ra,69a <printint>
        i += 2;
 880:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 882:	8bca                	mv	s7,s2
      state = 0;
 884:	4981                	li	s3,0
        i += 2;
 886:	b729                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 888:	008b8913          	addi	s2,s7,8
 88c:	4685                	li	a3,1
 88e:	4629                	li	a2,10
 890:	000bb583          	ld	a1,0(s7)
 894:	855a                	mv	a0,s6
 896:	e05ff0ef          	jal	ra,69a <printint>
        i += 2;
 89a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 89c:	8bca                	mv	s7,s2
      state = 0;
 89e:	4981                	li	s3,0
        i += 2;
 8a0:	bdc5                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8a2:	008b8913          	addi	s2,s7,8
 8a6:	4681                	li	a3,0
 8a8:	4629                	li	a2,10
 8aa:	000be583          	lwu	a1,0(s7)
 8ae:	855a                	mv	a0,s6
 8b0:	debff0ef          	jal	ra,69a <printint>
 8b4:	8bca                	mv	s7,s2
      state = 0;
 8b6:	4981                	li	s3,0
 8b8:	bde1                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ba:	008b8913          	addi	s2,s7,8
 8be:	4681                	li	a3,0
 8c0:	4629                	li	a2,10
 8c2:	000bb583          	ld	a1,0(s7)
 8c6:	855a                	mv	a0,s6
 8c8:	dd3ff0ef          	jal	ra,69a <printint>
        i += 1;
 8cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ce:	8bca                	mv	s7,s2
      state = 0;
 8d0:	4981                	li	s3,0
        i += 1;
 8d2:	bd7d                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d4:	008b8913          	addi	s2,s7,8
 8d8:	4681                	li	a3,0
 8da:	4629                	li	a2,10
 8dc:	000bb583          	ld	a1,0(s7)
 8e0:	855a                	mv	a0,s6
 8e2:	db9ff0ef          	jal	ra,69a <printint>
        i += 2;
 8e6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8e8:	8bca                	mv	s7,s2
      state = 0;
 8ea:	4981                	li	s3,0
        i += 2;
 8ec:	b555                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8ee:	008b8913          	addi	s2,s7,8
 8f2:	4681                	li	a3,0
 8f4:	4641                	li	a2,16
 8f6:	000be583          	lwu	a1,0(s7)
 8fa:	855a                	mv	a0,s6
 8fc:	d9fff0ef          	jal	ra,69a <printint>
 900:	8bca                	mv	s7,s2
      state = 0;
 902:	4981                	li	s3,0
 904:	b571                	j	790 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 906:	008b8913          	addi	s2,s7,8
 90a:	4681                	li	a3,0
 90c:	4641                	li	a2,16
 90e:	000bb583          	ld	a1,0(s7)
 912:	855a                	mv	a0,s6
 914:	d87ff0ef          	jal	ra,69a <printint>
        i += 1;
 918:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 91a:	8bca                	mv	s7,s2
      state = 0;
 91c:	4981                	li	s3,0
        i += 1;
 91e:	bd8d                	j	790 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 920:	008b8793          	addi	a5,s7,8
 924:	f8f43423          	sd	a5,-120(s0)
 928:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 92c:	03000593          	li	a1,48
 930:	855a                	mv	a0,s6
 932:	d4bff0ef          	jal	ra,67c <putc>
  putc(fd, 'x');
 936:	07800593          	li	a1,120
 93a:	855a                	mv	a0,s6
 93c:	d41ff0ef          	jal	ra,67c <putc>
 940:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 942:	03c9d793          	srli	a5,s3,0x3c
 946:	97e6                	add	a5,a5,s9
 948:	0007c583          	lbu	a1,0(a5)
 94c:	855a                	mv	a0,s6
 94e:	d2fff0ef          	jal	ra,67c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 952:	0992                	slli	s3,s3,0x4
 954:	397d                	addiw	s2,s2,-1
 956:	fe0916e3          	bnez	s2,942 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 95a:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 95e:	4981                	li	s3,0
 960:	bd05                	j	790 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 962:	008b8913          	addi	s2,s7,8
 966:	000bc583          	lbu	a1,0(s7)
 96a:	855a                	mv	a0,s6
 96c:	d11ff0ef          	jal	ra,67c <putc>
 970:	8bca                	mv	s7,s2
      state = 0;
 972:	4981                	li	s3,0
 974:	bd31                	j	790 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 976:	008b8993          	addi	s3,s7,8
 97a:	000bb903          	ld	s2,0(s7)
 97e:	00090f63          	beqz	s2,99c <vprintf+0x266>
        for(; *s; s++)
 982:	00094583          	lbu	a1,0(s2)
 986:	c195                	beqz	a1,9aa <vprintf+0x274>
          putc(fd, *s);
 988:	855a                	mv	a0,s6
 98a:	cf3ff0ef          	jal	ra,67c <putc>
        for(; *s; s++)
 98e:	0905                	addi	s2,s2,1
 990:	00094583          	lbu	a1,0(s2)
 994:	f9f5                	bnez	a1,988 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 996:	8bce                	mv	s7,s3
      state = 0;
 998:	4981                	li	s3,0
 99a:	bbdd                	j	790 <vprintf+0x5a>
          s = "(null)";
 99c:	00000917          	auipc	s2,0x0
 9a0:	2dc90913          	addi	s2,s2,732 # c78 <malloc+0x1cc>
        for(; *s; s++)
 9a4:	02800593          	li	a1,40
 9a8:	b7c5                	j	988 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 9aa:	8bce                	mv	s7,s3
      state = 0;
 9ac:	4981                	li	s3,0
 9ae:	b3cd                	j	790 <vprintf+0x5a>
    }
  }
}
 9b0:	70e6                	ld	ra,120(sp)
 9b2:	7446                	ld	s0,112(sp)
 9b4:	74a6                	ld	s1,104(sp)
 9b6:	7906                	ld	s2,96(sp)
 9b8:	69e6                	ld	s3,88(sp)
 9ba:	6a46                	ld	s4,80(sp)
 9bc:	6aa6                	ld	s5,72(sp)
 9be:	6b06                	ld	s6,64(sp)
 9c0:	7be2                	ld	s7,56(sp)
 9c2:	7c42                	ld	s8,48(sp)
 9c4:	7ca2                	ld	s9,40(sp)
 9c6:	7d02                	ld	s10,32(sp)
 9c8:	6de2                	ld	s11,24(sp)
 9ca:	6109                	addi	sp,sp,128
 9cc:	8082                	ret

00000000000009ce <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 9ce:	715d                	addi	sp,sp,-80
 9d0:	ec06                	sd	ra,24(sp)
 9d2:	e822                	sd	s0,16(sp)
 9d4:	1000                	addi	s0,sp,32
 9d6:	e010                	sd	a2,0(s0)
 9d8:	e414                	sd	a3,8(s0)
 9da:	e818                	sd	a4,16(s0)
 9dc:	ec1c                	sd	a5,24(s0)
 9de:	03043023          	sd	a6,32(s0)
 9e2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9e6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ea:	8622                	mv	a2,s0
 9ec:	d4bff0ef          	jal	ra,736 <vprintf>
}
 9f0:	60e2                	ld	ra,24(sp)
 9f2:	6442                	ld	s0,16(sp)
 9f4:	6161                	addi	sp,sp,80
 9f6:	8082                	ret

00000000000009f8 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 9f8:	711d                	addi	sp,sp,-96
 9fa:	ec06                	sd	ra,24(sp)
 9fc:	e822                	sd	s0,16(sp)
 9fe:	1000                	addi	s0,sp,32
 a00:	e40c                	sd	a1,8(s0)
 a02:	e810                	sd	a2,16(s0)
 a04:	ec14                	sd	a3,24(s0)
 a06:	f018                	sd	a4,32(s0)
 a08:	f41c                	sd	a5,40(s0)
 a0a:	03043823          	sd	a6,48(s0)
 a0e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a12:	00840613          	addi	a2,s0,8
 a16:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a1a:	85aa                	mv	a1,a0
 a1c:	4505                	li	a0,1
 a1e:	d19ff0ef          	jal	ra,736 <vprintf>
}
 a22:	60e2                	ld	ra,24(sp)
 a24:	6442                	ld	s0,16(sp)
 a26:	6125                	addi	sp,sp,96
 a28:	8082                	ret

0000000000000a2a <free>:
 *   无
 */

void
free(void *ap)
{
 a2a:	1141                	addi	sp,sp,-16
 a2c:	e422                	sd	s0,8(sp)
 a2e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 a30:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a34:	00000797          	auipc	a5,0x0
 a38:	5cc7b783          	ld	a5,1484(a5) # 1000 <freep>
 a3c:	a02d                	j	a66 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a3e:	4618                	lw	a4,8(a2)
 a40:	9f2d                	addw	a4,a4,a1
 a42:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a46:	6398                	ld	a4,0(a5)
 a48:	6310                	ld	a2,0(a4)
 a4a:	a83d                	j	a88 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a4c:	ff852703          	lw	a4,-8(a0)
 a50:	9f31                	addw	a4,a4,a2
 a52:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a54:	ff053683          	ld	a3,-16(a0)
 a58:	a091                	j	a9c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a5a:	6398                	ld	a4,0(a5)
 a5c:	00e7e463          	bltu	a5,a4,a64 <free+0x3a>
 a60:	00e6ea63          	bltu	a3,a4,a74 <free+0x4a>
{
 a64:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a66:	fed7fae3          	bgeu	a5,a3,a5a <free+0x30>
 a6a:	6398                	ld	a4,0(a5)
 a6c:	00e6e463          	bltu	a3,a4,a74 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a70:	fee7eae3          	bltu	a5,a4,a64 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a74:	ff852583          	lw	a1,-8(a0)
 a78:	6390                	ld	a2,0(a5)
 a7a:	02059813          	slli	a6,a1,0x20
 a7e:	01c85713          	srli	a4,a6,0x1c
 a82:	9736                	add	a4,a4,a3
 a84:	fae60de3          	beq	a2,a4,a3e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a88:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a8c:	4790                	lw	a2,8(a5)
 a8e:	02061593          	slli	a1,a2,0x20
 a92:	01c5d713          	srli	a4,a1,0x1c
 a96:	973e                	add	a4,a4,a5
 a98:	fae68ae3          	beq	a3,a4,a4c <free+0x22>
    p->s.ptr = bp->s.ptr;
 a9c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  /* 更新空闲链表头指针 */
  freep = p;
 a9e:	00000717          	auipc	a4,0x0
 aa2:	56f73123          	sd	a5,1378(a4) # 1000 <freep>
}
 aa6:	6422                	ld	s0,8(sp)
 aa8:	0141                	addi	sp,sp,16
 aaa:	8082                	ret

0000000000000aac <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 aac:	7139                	addi	sp,sp,-64
 aae:	fc06                	sd	ra,56(sp)
 ab0:	f822                	sd	s0,48(sp)
 ab2:	f426                	sd	s1,40(sp)
 ab4:	f04a                	sd	s2,32(sp)
 ab6:	ec4e                	sd	s3,24(sp)
 ab8:	e852                	sd	s4,16(sp)
 aba:	e456                	sd	s5,8(sp)
 abc:	e05a                	sd	s6,0(sp)
 abe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ac0:	02051493          	slli	s1,a0,0x20
 ac4:	9081                	srli	s1,s1,0x20
 ac6:	04bd                	addi	s1,s1,15
 ac8:	8091                	srli	s1,s1,0x4
 aca:	0014899b          	addiw	s3,s1,1
 ace:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 ad0:	00000517          	auipc	a0,0x0
 ad4:	53053503          	ld	a0,1328(a0) # 1000 <freep>
 ad8:	c515                	beqz	a0,b04 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ada:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 adc:	4798                	lw	a4,8(a5)
 ade:	02977f63          	bgeu	a4,s1,b1c <malloc+0x70>
 ae2:	8a4e                	mv	s4,s3
 ae4:	0009871b          	sext.w	a4,s3
 ae8:	6685                	lui	a3,0x1
 aea:	00d77363          	bgeu	a4,a3,af0 <malloc+0x44>
 aee:	6a05                	lui	s4,0x1
 af0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 af4:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 af8:	00000917          	auipc	s2,0x0
 afc:	50890913          	addi	s2,s2,1288 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 b00:	5afd                	li	s5,-1
 b02:	a885                	j	b72 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 b04:	00000797          	auipc	a5,0x0
 b08:	50c78793          	addi	a5,a5,1292 # 1010 <base>
 b0c:	00000717          	auipc	a4,0x0
 b10:	4ef73a23          	sd	a5,1268(a4) # 1000 <freep>
 b14:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b16:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 b1a:	b7e1                	j	ae2 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 b1c:	02e48c63          	beq	s1,a4,b54 <malloc+0xa8>
        p->s.size -= nunits;
 b20:	4137073b          	subw	a4,a4,s3
 b24:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b26:	02071693          	slli	a3,a4,0x20
 b2a:	01c6d713          	srli	a4,a3,0x1c
 b2e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b30:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 b34:	00000717          	auipc	a4,0x0
 b38:	4ca73623          	sd	a0,1228(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 b3c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 b40:	70e2                	ld	ra,56(sp)
 b42:	7442                	ld	s0,48(sp)
 b44:	74a2                	ld	s1,40(sp)
 b46:	7902                	ld	s2,32(sp)
 b48:	69e2                	ld	s3,24(sp)
 b4a:	6a42                	ld	s4,16(sp)
 b4c:	6aa2                	ld	s5,8(sp)
 b4e:	6b02                	ld	s6,0(sp)
 b50:	6121                	addi	sp,sp,64
 b52:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b54:	6398                	ld	a4,0(a5)
 b56:	e118                	sd	a4,0(a0)
 b58:	bff1                	j	b34 <malloc+0x88>
  hp->s.size = nu;
 b5a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 b5e:	0541                	addi	a0,a0,16
 b60:	ecbff0ef          	jal	ra,a2a <free>
  return freep;
 b64:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b68:	dd61                	beqz	a0,b40 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b6a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 b6c:	4798                	lw	a4,8(a5)
 b6e:	fa9777e3          	bgeu	a4,s1,b1c <malloc+0x70>
    if(p == freep)
 b72:	00093703          	ld	a4,0(s2)
 b76:	853e                	mv	a0,a5
 b78:	fef719e3          	bne	a4,a5,b6a <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 b7c:	8552                	mv	a0,s4
 b7e:	9ebff0ef          	jal	ra,568 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 b82:	fd551ce3          	bne	a0,s5,b5a <malloc+0xae>
        return 0;  /* 内存分配失败 */
 b86:	4501                	li	a0,0
 b88:	bf65                	j	b40 <malloc+0x94>
