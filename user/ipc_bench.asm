
user/_ipc_bench:     file format elf64-littleriscv


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
  1e:	b7650513          	addi	a0,a0,-1162 # b90 <malloc+0xdc>
  22:	1d9000ef          	jal	ra,9fa <printf>
  printf("time: %d ticks\n", t1 - t0);
  26:	413a05bb          	subw	a1,s4,s3
  2a:	00001517          	auipc	a0,0x1
  2e:	b7650513          	addi	a0,a0,-1162 # ba0 <malloc+0xec>
  32:	1c9000ef          	jal	ra,9fa <printf>
  printf("kalloc: %d\n", (int)(b->kalloc_cnt - a->kalloc_cnt));
  36:	01893583          	ld	a1,24(s2)
  3a:	6c9c                	ld	a5,24(s1)
  3c:	9d9d                	subw	a1,a1,a5
  3e:	00001517          	auipc	a0,0x1
  42:	b7250513          	addi	a0,a0,-1166 # bb0 <malloc+0xfc>
  46:	1b5000ef          	jal	ra,9fa <printf>
  printf("copyin_bytes: %d\n", (int)(b->copyin_bytes - a->copyin_bytes));
  4a:	02093583          	ld	a1,32(s2)
  4e:	709c                	ld	a5,32(s1)
  50:	9d9d                	subw	a1,a1,a5
  52:	00001517          	auipc	a0,0x1
  56:	b6e50513          	addi	a0,a0,-1170 # bc0 <malloc+0x10c>
  5a:	1a1000ef          	jal	ra,9fa <printf>
  printf("copyout_bytes: %d\n", (int)(b->copyout_bytes - a->copyout_bytes));
  5e:	02893583          	ld	a1,40(s2)
  62:	749c                	ld	a5,40(s1)
  64:	9d9d                	subw	a1,a1,a5
  66:	00001517          	auipc	a0,0x1
  6a:	b7250513          	addi	a0,a0,-1166 # bd8 <malloc+0x124>
  6e:	18d000ef          	jal	ra,9fa <printf>
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
  90:	b6450513          	addi	a0,a0,-1180 # bf0 <malloc+0x13c>
  94:	167000ef          	jal	ra,9fa <printf>
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
  a8:	7105                	addi	sp,sp,-480
  aa:	ef86                	sd	ra,472(sp)
  ac:	eba2                	sd	s0,464(sp)
  ae:	e7a6                	sd	s1,456(sp)
  b0:	e3ca                	sd	s2,448(sp)
  b2:	ff4e                	sd	s3,440(sp)
  b4:	fb52                	sd	s4,432(sp)
  b6:	f756                	sd	s5,424(sp)
  b8:	f35a                	sd	s6,416(sp)
  ba:	ef5e                	sd	s7,408(sp)
  bc:	1380                	addi	s0,sp,480
  struct vmstats_user a,b;
  int t0,t1;

  // pipe
  vmstats(&a);
  be:	f7040513          	addi	a0,s0,-144
  c2:	5b4000ef          	jal	ra,676 <vmstats>
  t0 = uptime();
  c6:	570000ef          	jal	ra,636 <uptime>
  ca:	89aa                	mv	s3,a0
  if(pipe(pfd) < 0){
  cc:	e2840513          	addi	a0,s0,-472
  d0:	4de000ef          	jal	ra,5ae <pipe>
  d4:	06054363          	bltz	a0,13a <main+0x92>
  int pid = fork();
  d8:	4be000ef          	jal	ra,596 <fork>
  dc:	84aa                	mv	s1,a0
  if(pid == 0){
  de:	c53d                	beqz	a0,14c <main+0xa4>
  close(pfd[0]);
  e0:	e2842503          	lw	a0,-472(s0)
  e4:	4e2000ef          	jal	ra,5c6 <close>
  for(int i=0;i<CHUNK;i++) tmp[i] = (char)(i);
  e8:	e3040713          	addi	a4,s0,-464
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
 112:	e3040593          	addi	a1,s0,-464
 116:	e2c42503          	lw	a0,-468(s0)
 11a:	4a4000ef          	jal	ra,5be <write>
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
 13e:	ad650513          	addi	a0,a0,-1322 # c10 <malloc+0x15c>
 142:	0b9000ef          	jal	ra,9fa <printf>
    exit(1);
 146:	4505                	li	a0,1
 148:	456000ef          	jal	ra,59e <exit>
    close(pfd[1]);
 14c:	e2c42503          	lw	a0,-468(s0)
 150:	476000ef          	jal	ra,5c6 <close>
    while(got < TOTAL_BYTES){
 154:	00800937          	lui	s2,0x800
      int n = read(pfd[0], tmp, sizeof(tmp));
 158:	10000613          	li	a2,256
 15c:	e3040593          	addi	a1,s0,-464
 160:	e2842503          	lw	a0,-472(s0)
 164:	452000ef          	jal	ra,5b6 <read>
      if(n <= 0) break;
 168:	00a05563          	blez	a0,172 <main+0xca>
      got += n;
 16c:	9ca9                	addw	s1,s1,a0
    while(got < TOTAL_BYTES){
 16e:	ff24c5e3          	blt	s1,s2,158 <main+0xb0>
    close(pfd[0]);
 172:	e2842503          	lw	a0,-472(s0)
 176:	450000ef          	jal	ra,5c6 <close>
    exit(0);
 17a:	4501                	li	a0,0
 17c:	422000ef          	jal	ra,59e <exit>
      printf("pipe write fail\n");
 180:	00001517          	auipc	a0,0x1
 184:	aa050513          	addi	a0,a0,-1376 # c20 <malloc+0x16c>
 188:	073000ef          	jal	ra,9fa <printf>
  close(pfd[1]);
 18c:	e2c42503          	lw	a0,-468(s0)
 190:	436000ef          	jal	ra,5c6 <close>
  wait(0);
 194:	4501                	li	a0,0
 196:	410000ef          	jal	ra,5a6 <wait>
  bench_pipe();
  t1 = uptime();
 19a:	49c000ef          	jal	ra,636 <uptime>
 19e:	84aa                	mv	s1,a0
  vmstats(&b);
 1a0:	f3040513          	addi	a0,s0,-208
 1a4:	4d2000ef          	jal	ra,676 <vmstats>
  print_delta("PIPE IPC", t0, t1, &a, &b);
 1a8:	f3040713          	addi	a4,s0,-208
 1ac:	f7040693          	addi	a3,s0,-144
 1b0:	8626                	mv	a2,s1
 1b2:	85ce                	mv	a1,s3
 1b4:	00001517          	auipc	a0,0x1
 1b8:	a8450513          	addi	a0,a0,-1404 # c38 <malloc+0x184>
 1bc:	e45ff0ef          	jal	ra,0 <print_delta>

  // shm+sem
  vmstats(&a);
 1c0:	f7040513          	addi	a0,s0,-144
 1c4:	4b2000ef          	jal	ra,676 <vmstats>
  t0 = uptime();
 1c8:	46e000ef          	jal	ra,636 <uptime>
 1cc:	8aaa                	mv	s5,a0
  struct shmring *r = (struct shmring*)mmap(0, 4096*20, PROT_READ|PROT_WRITE,
 1ce:	4729                	li	a4,10
 1d0:	468d                	li	a3,3
 1d2:	460d                	li	a2,3
 1d4:	65d1                	lui	a1,0x14
 1d6:	4501                	li	a0,0
 1d8:	466000ef          	jal	ra,63e <mmap>
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
 1f4:	46a000ef          	jal	ra,65e <sem_open>
 1f8:	06054b63          	bltz	a0,26e <main+0x1c6>
 1fc:	4581                	li	a1,0
 1fe:	0c900513          	li	a0,201
 202:	45c000ef          	jal	ra,65e <sem_open>
 206:	06054463          	bltz	a0,26e <main+0x1c6>
  int pid = fork();
 20a:	38c000ef          	jal	ra,596 <fork>
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
 220:	446000ef          	jal	ra,666 <sem_wait>
      int idx = r->tail % NCHUNK;
 224:	40d8                	lw	a4,4(s1)
 226:	033767bb          	remw	a5,a4,s3
      volatile char x = r->buf[idx*CHUNK]; // 触碰一下，防止编译器全优化
 22a:	0087979b          	slliw	a5,a5,0x8
 22e:	97a6                	add	a5,a5,s1
 230:	0087c783          	lbu	a5,8(a5)
 234:	e2f40823          	sb	a5,-464(s0)
      (void)x;
 238:	e3044783          	lbu	a5,-464(s0)
      r->tail++;
 23c:	2705                	addiw	a4,a4,1
 23e:	c0d8                	sw	a4,4(s1)
      sem_post(sem_empty);
 240:	0c800513          	li	a0,200
 244:	42a000ef          	jal	ra,66e <sem_post>
    while(got < TOTAL_BYTES){
 248:	397d                	addiw	s2,s2,-1
 24a:	fc0919e3          	bnez	s2,21c <main+0x174>
    munmap((char*)r, 4096*20);
 24e:	65d1                	lui	a1,0x14
 250:	8526                	mv	a0,s1
 252:	3f4000ef          	jal	ra,646 <munmap>
    exit(0);
 256:	4501                	li	a0,0
 258:	346000ef          	jal	ra,59e <exit>
    printf("mmap shm fail\n");
 25c:	00001517          	auipc	a0,0x1
 260:	9ec50513          	addi	a0,a0,-1556 # c48 <malloc+0x194>
 264:	796000ef          	jal	ra,9fa <printf>
    exit(1);
 268:	4505                	li	a0,1
 26a:	334000ef          	jal	ra,59e <exit>
    printf("sem_open fail\n");
 26e:	00001517          	auipc	a0,0x1
 272:	9ea50513          	addi	a0,a0,-1558 # c58 <malloc+0x1a4>
 276:	784000ef          	jal	ra,9fa <printf>
    exit(1);
 27a:	4505                	li	a0,1
 27c:	322000ef          	jal	ra,59e <exit>
    r->head++;
 280:	2705                	addiw	a4,a4,1
 282:	c098                	sw	a4,0(s1)
    sem_post(sem_full);
 284:	0c900513          	li	a0,201
 288:	3e6000ef          	jal	ra,66e <sem_post>
  while(sent < TOTAL_BYTES){
 28c:	397d                	addiw	s2,s2,-1
 28e:	02090c63          	beqz	s2,2c6 <main+0x21e>
    sem_wait(sem_empty);
 292:	0c800513          	li	a0,200
 296:	3d0000ef          	jal	ra,666 <sem_wait>
    int idx = r->head % NCHUNK;
 29a:	4098                	lw	a4,0(s1)
 29c:	41f7579b          	sraiw	a5,a4,0x1f
 2a0:	0187d69b          	srliw	a3,a5,0x18
 2a4:	00e687bb          	addw	a5,a3,a4
 2a8:	0ff7f793          	andi	a5,a5,255
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
 2c8:	2de000ef          	jal	ra,5a6 <wait>
  munmap((char*)r, 4096*20);
 2cc:	65d1                	lui	a1,0x14
 2ce:	8526                	mv	a0,s1
 2d0:	376000ef          	jal	ra,646 <munmap>
  shmctl(shmkey, IPC_RMID);  // 可选：清理
 2d4:	4581                	li	a1,0
 2d6:	4529                	li	a0,10
 2d8:	376000ef          	jal	ra,64e <shmctl>
  bench_shm_sem();
  t1 = uptime();
 2dc:	35a000ef          	jal	ra,636 <uptime>
 2e0:	84aa                	mv	s1,a0
  vmstats(&b);
 2e2:	f3040513          	addi	a0,s0,-208
 2e6:	390000ef          	jal	ra,676 <vmstats>
  print_delta("SHM+SEM IPC", t0, t1, &a, &b);
 2ea:	f3040713          	addi	a4,s0,-208
 2ee:	f7040693          	addi	a3,s0,-144
 2f2:	8626                	mv	a2,s1
 2f4:	85d6                	mv	a1,s5
 2f6:	00001517          	auipc	a0,0x1
 2fa:	97250513          	addi	a0,a0,-1678 # c68 <malloc+0x1b4>
 2fe:	d03ff0ef          	jal	ra,0 <print_delta>

  exit(0);
 302:	4501                	li	a0,0
 304:	29a000ef          	jal	ra,59e <exit>

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
 314:	28a000ef          	jal	ra,59e <exit>

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
 320:	0585                	addi	a1,a1,1
 322:	0785                	addi	a5,a5,1
 324:	fff5c703          	lbu	a4,-1(a1) # 13fff <base+0x12fef>
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
 402:	1b4000ef          	jal	ra,5b6 <read>
    if(cc < 1)
 406:	00a05e63          	blez	a0,422 <gets+0x52>
    buf[i++] = c;
 40a:	faf44783          	lbu	a5,-81(s0)
 40e:	00f90023          	sb	a5,0(s2) # 8000 <base+0x6ff0>
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
 450:	18e000ef          	jal	ra,5de <open>
  if(fd < 0)
 454:	02054163          	bltz	a0,476 <stat+0x36>
 458:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 45a:	85ca                	mv	a1,s2
 45c:	19a000ef          	jal	ra,5f6 <fstat>
 460:	892a                	mv	s2,a0
  close(fd);
 462:	8526                	mv	a0,s1
 464:	162000ef          	jal	ra,5c6 <close>
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
 480:	00054603          	lbu	a2,0(a0)
 484:	fd06079b          	addiw	a5,a2,-48
 488:	0ff7f793          	andi	a5,a5,255
 48c:	4725                	li	a4,9
 48e:	02f76963          	bltu	a4,a5,4c0 <atoi+0x46>
 492:	86aa                	mv	a3,a0
  n = 0;
 494:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 496:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 498:	0685                	addi	a3,a3,1
 49a:	0025179b          	slliw	a5,a0,0x2
 49e:	9fa9                	addw	a5,a5,a0
 4a0:	0017979b          	slliw	a5,a5,0x1
 4a4:	9fb1                	addw	a5,a5,a2
 4a6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4aa:	0006c603          	lbu	a2,0(a3)
 4ae:	fd06071b          	addiw	a4,a2,-48
 4b2:	0ff77713          	andi	a4,a4,255
 4b6:	fee5f1e3          	bgeu	a1,a4,498 <atoi+0x1e>
  return n;
}
 4ba:	6422                	ld	s0,8(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret
  n = 0;
 4c0:	4501                	li	a0,0
 4c2:	bfe5                	j	4ba <atoi+0x40>

00000000000004c4 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c4:	1141                	addi	sp,sp,-16
 4c6:	e422                	sd	s0,8(sp)
 4c8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4ca:	02b57463          	bgeu	a0,a1,4f2 <memmove+0x2e>
    while(n-- > 0)
 4ce:	00c05f63          	blez	a2,4ec <memmove+0x28>
 4d2:	1602                	slli	a2,a2,0x20
 4d4:	9201                	srli	a2,a2,0x20
 4d6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4da:	872a                	mv	a4,a0
      *dst++ = *src++;
 4dc:	0585                	addi	a1,a1,1
 4de:	0705                	addi	a4,a4,1
 4e0:	fff5c683          	lbu	a3,-1(a1)
 4e4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4e8:	fee79ae3          	bne	a5,a4,4dc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ec:	6422                	ld	s0,8(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret
    dst += n;
 4f2:	00c50733          	add	a4,a0,a2
    src += n;
 4f6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4f8:	fec05ae3          	blez	a2,4ec <memmove+0x28>
 4fc:	fff6079b          	addiw	a5,a2,-1
 500:	1782                	slli	a5,a5,0x20
 502:	9381                	srli	a5,a5,0x20
 504:	fff7c793          	not	a5,a5
 508:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 50a:	15fd                	addi	a1,a1,-1
 50c:	177d                	addi	a4,a4,-1
 50e:	0005c683          	lbu	a3,0(a1)
 512:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 516:	fee79ae3          	bne	a5,a4,50a <memmove+0x46>
 51a:	bfc9                	j	4ec <memmove+0x28>

000000000000051c <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 51c:	1141                	addi	sp,sp,-16
 51e:	e422                	sd	s0,8(sp)
 520:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 522:	ca05                	beqz	a2,552 <memcmp+0x36>
 524:	fff6069b          	addiw	a3,a2,-1
 528:	1682                	slli	a3,a3,0x20
 52a:	9281                	srli	a3,a3,0x20
 52c:	0685                	addi	a3,a3,1
 52e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 530:	00054783          	lbu	a5,0(a0)
 534:	0005c703          	lbu	a4,0(a1)
 538:	00e79863          	bne	a5,a4,548 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 53c:	0505                	addi	a0,a0,1
    p2++;
 53e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 540:	fed518e3          	bne	a0,a3,530 <memcmp+0x14>
  }
  return 0;
 544:	4501                	li	a0,0
 546:	a019                	j	54c <memcmp+0x30>
      return *p1 - *p2;
 548:	40e7853b          	subw	a0,a5,a4
}
 54c:	6422                	ld	s0,8(sp)
 54e:	0141                	addi	sp,sp,16
 550:	8082                	ret
  return 0;
 552:	4501                	li	a0,0
 554:	bfe5                	j	54c <memcmp+0x30>

0000000000000556 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 556:	1141                	addi	sp,sp,-16
 558:	e406                	sd	ra,8(sp)
 55a:	e022                	sd	s0,0(sp)
 55c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 55e:	f67ff0ef          	jal	ra,4c4 <memmove>
}
 562:	60a2                	ld	ra,8(sp)
 564:	6402                	ld	s0,0(sp)
 566:	0141                	addi	sp,sp,16
 568:	8082                	ret

000000000000056a <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 56a:	1141                	addi	sp,sp,-16
 56c:	e406                	sd	ra,8(sp)
 56e:	e022                	sd	s0,0(sp)
 570:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 572:	4585                	li	a1,1
 574:	0b2000ef          	jal	ra,626 <sys_sbrk>
}
 578:	60a2                	ld	ra,8(sp)
 57a:	6402                	ld	s0,0(sp)
 57c:	0141                	addi	sp,sp,16
 57e:	8082                	ret

0000000000000580 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 580:	1141                	addi	sp,sp,-16
 582:	e406                	sd	ra,8(sp)
 584:	e022                	sd	s0,0(sp)
 586:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 588:	4589                	li	a1,2
 58a:	09c000ef          	jal	ra,626 <sys_sbrk>
}
 58e:	60a2                	ld	ra,8(sp)
 590:	6402                	ld	s0,0(sp)
 592:	0141                	addi	sp,sp,16
 594:	8082                	ret

0000000000000596 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 596:	4885                	li	a7,1
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <exit>:
.global exit
exit:
 li a7, SYS_exit
 59e:	4889                	li	a7,2
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5a6:	488d                	li	a7,3
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ae:	4891                	li	a7,4
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <read>:
.global read
read:
 li a7, SYS_read
 5b6:	4895                	li	a7,5
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <write>:
.global write
write:
 li a7, SYS_write
 5be:	48c1                	li	a7,16
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <close>:
.global close
close:
 li a7, SYS_close
 5c6:	48d5                	li	a7,21
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <kill>:
.global kill
kill:
 li a7, SYS_kill
 5ce:	4899                	li	a7,6
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5d6:	489d                	li	a7,7
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <open>:
.global open
open:
 li a7, SYS_open
 5de:	48bd                	li	a7,15
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5e6:	48c5                	li	a7,17
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5ee:	48c9                	li	a7,18
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5f6:	48a1                	li	a7,8
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <link>:
.global link
link:
 li a7, SYS_link
 5fe:	48cd                	li	a7,19
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 606:	48d1                	li	a7,20
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 60e:	48a5                	li	a7,9
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <dup>:
.global dup
dup:
 li a7, SYS_dup
 616:	48a9                	li	a7,10
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 61e:	48ad                	li	a7,11
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 626:	48b1                	li	a7,12
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <pause>:
.global pause
pause:
 li a7, SYS_pause
 62e:	48b5                	li	a7,13
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 636:	48b9                	li	a7,14
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 63e:	48d9                	li	a7,22
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 646:	48dd                	li	a7,23
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 64e:	48e1                	li	a7,24
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 656:	48e5                	li	a7,25
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 65e:	48e9                	li	a7,26
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 666:	48ed                	li	a7,27
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 66e:	48f1                	li	a7,28
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 676:	48f5                	li	a7,29
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 67e:	1101                	addi	sp,sp,-32
 680:	ec06                	sd	ra,24(sp)
 682:	e822                	sd	s0,16(sp)
 684:	1000                	addi	s0,sp,32
 686:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 68a:	4605                	li	a2,1
 68c:	fef40593          	addi	a1,s0,-17
 690:	f2fff0ef          	jal	ra,5be <write>
}
 694:	60e2                	ld	ra,24(sp)
 696:	6442                	ld	s0,16(sp)
 698:	6105                	addi	sp,sp,32
 69a:	8082                	ret

000000000000069c <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 69c:	715d                	addi	sp,sp,-80
 69e:	e486                	sd	ra,72(sp)
 6a0:	e0a2                	sd	s0,64(sp)
 6a2:	fc26                	sd	s1,56(sp)
 6a4:	f84a                	sd	s2,48(sp)
 6a6:	f44e                	sd	s3,40(sp)
 6a8:	0880                	addi	s0,sp,80
 6aa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 6ac:	c299                	beqz	a3,6b2 <printint+0x16>
 6ae:	0805c163          	bltz	a1,730 <printint+0x94>
  neg = 0;
 6b2:	4881                	li	a7,0
 6b4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6b8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 6ba:	00000517          	auipc	a0,0x0
 6be:	5c650513          	addi	a0,a0,1478 # c80 <digits>
 6c2:	883e                	mv	a6,a5
 6c4:	2785                	addiw	a5,a5,1
 6c6:	02c5f733          	remu	a4,a1,a2
 6ca:	972a                	add	a4,a4,a0
 6cc:	00074703          	lbu	a4,0(a4)
 6d0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6d4:	872e                	mv	a4,a1
 6d6:	02c5d5b3          	divu	a1,a1,a2
 6da:	0685                	addi	a3,a3,1
 6dc:	fec773e3          	bgeu	a4,a2,6c2 <printint+0x26>
  if(neg)
 6e0:	00088b63          	beqz	a7,6f6 <printint+0x5a>
    buf[i++] = '-';
 6e4:	fd040713          	addi	a4,s0,-48
 6e8:	97ba                	add	a5,a5,a4
 6ea:	02d00713          	li	a4,45
 6ee:	fee78423          	sb	a4,-24(a5)
 6f2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 6f6:	02f05663          	blez	a5,722 <printint+0x86>
 6fa:	fb840713          	addi	a4,s0,-72
 6fe:	00f704b3          	add	s1,a4,a5
 702:	fff70993          	addi	s3,a4,-1
 706:	99be                	add	s3,s3,a5
 708:	37fd                	addiw	a5,a5,-1
 70a:	1782                	slli	a5,a5,0x20
 70c:	9381                	srli	a5,a5,0x20
 70e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 712:	fff4c583          	lbu	a1,-1(s1)
 716:	854a                	mv	a0,s2
 718:	f67ff0ef          	jal	ra,67e <putc>
  while(--i >= 0)
 71c:	14fd                	addi	s1,s1,-1
 71e:	ff349ae3          	bne	s1,s3,712 <printint+0x76>
}
 722:	60a6                	ld	ra,72(sp)
 724:	6406                	ld	s0,64(sp)
 726:	74e2                	ld	s1,56(sp)
 728:	7942                	ld	s2,48(sp)
 72a:	79a2                	ld	s3,40(sp)
 72c:	6161                	addi	sp,sp,80
 72e:	8082                	ret
    x = -xx;
 730:	40b005b3          	neg	a1,a1
    neg = 1;
 734:	4885                	li	a7,1
    x = -xx;
 736:	bfbd                	j	6b4 <printint+0x18>

0000000000000738 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 738:	7119                	addi	sp,sp,-128
 73a:	fc86                	sd	ra,120(sp)
 73c:	f8a2                	sd	s0,112(sp)
 73e:	f4a6                	sd	s1,104(sp)
 740:	f0ca                	sd	s2,96(sp)
 742:	ecce                	sd	s3,88(sp)
 744:	e8d2                	sd	s4,80(sp)
 746:	e4d6                	sd	s5,72(sp)
 748:	e0da                	sd	s6,64(sp)
 74a:	fc5e                	sd	s7,56(sp)
 74c:	f862                	sd	s8,48(sp)
 74e:	f466                	sd	s9,40(sp)
 750:	f06a                	sd	s10,32(sp)
 752:	ec6e                	sd	s11,24(sp)
 754:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 756:	0005c903          	lbu	s2,0(a1)
 75a:	24090c63          	beqz	s2,9b2 <vprintf+0x27a>
 75e:	8b2a                	mv	s6,a0
 760:	8a2e                	mv	s4,a1
 762:	8bb2                	mv	s7,a2
  state = 0;
 764:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 766:	4481                	li	s1,0
 768:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 76a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 76e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 772:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 776:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77a:	00000c97          	auipc	s9,0x0
 77e:	506c8c93          	addi	s9,s9,1286 # c80 <digits>
 782:	a005                	j	7a2 <vprintf+0x6a>
        putc(fd, c0);
 784:	85ca                	mv	a1,s2
 786:	855a                	mv	a0,s6
 788:	ef7ff0ef          	jal	ra,67e <putc>
 78c:	a019                	j	792 <vprintf+0x5a>
    } else if(state == '%'){
 78e:	03598263          	beq	s3,s5,7b2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 792:	2485                	addiw	s1,s1,1
 794:	8726                	mv	a4,s1
 796:	009a07b3          	add	a5,s4,s1
 79a:	0007c903          	lbu	s2,0(a5)
 79e:	20090a63          	beqz	s2,9b2 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 7a2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7a6:	fe0994e3          	bnez	s3,78e <vprintf+0x56>
      if(c0 == '%'){
 7aa:	fd579de3          	bne	a5,s5,784 <vprintf+0x4c>
        state = '%';
 7ae:	89be                	mv	s3,a5
 7b0:	b7cd                	j	792 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 7b2:	c3c1                	beqz	a5,832 <vprintf+0xfa>
 7b4:	00ea06b3          	add	a3,s4,a4
 7b8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7bc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 7be:	c681                	beqz	a3,7c6 <vprintf+0x8e>
 7c0:	9752                	add	a4,a4,s4
 7c2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 7c6:	03878e63          	beq	a5,s8,802 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 7ca:	05a78863          	beq	a5,s10,81a <vprintf+0xe2>
      } else if(c0 == 'u'){
 7ce:	0db78b63          	beq	a5,s11,8a4 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7d2:	07800713          	li	a4,120
 7d6:	10e78d63          	beq	a5,a4,8f0 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7da:	07000713          	li	a4,112
 7de:	14e78263          	beq	a5,a4,922 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7e2:	06300713          	li	a4,99
 7e6:	16e78f63          	beq	a5,a4,964 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 7ea:	07300713          	li	a4,115
 7ee:	18e78563          	beq	a5,a4,978 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7f2:	05579063          	bne	a5,s5,832 <vprintf+0xfa>
        putc(fd, '%');
 7f6:	85d6                	mv	a1,s5
 7f8:	855a                	mv	a0,s6
 7fa:	e85ff0ef          	jal	ra,67e <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7fe:	4981                	li	s3,0
 800:	bf49                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 802:	008b8913          	addi	s2,s7,8 # 800008 <base+0x7feff8>
 806:	4685                	li	a3,1
 808:	4629                	li	a2,10
 80a:	000ba583          	lw	a1,0(s7)
 80e:	855a                	mv	a0,s6
 810:	e8dff0ef          	jal	ra,69c <printint>
 814:	8bca                	mv	s7,s2
      state = 0;
 816:	4981                	li	s3,0
 818:	bfad                	j	792 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 81a:	03868663          	beq	a3,s8,846 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 81e:	05a68163          	beq	a3,s10,860 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 822:	09b68d63          	beq	a3,s11,8bc <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 826:	03a68f63          	beq	a3,s10,864 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 82a:	07800793          	li	a5,120
 82e:	0cf68d63          	beq	a3,a5,908 <vprintf+0x1d0>
        putc(fd, '%');
 832:	85d6                	mv	a1,s5
 834:	855a                	mv	a0,s6
 836:	e49ff0ef          	jal	ra,67e <putc>
        putc(fd, c0);
 83a:	85ca                	mv	a1,s2
 83c:	855a                	mv	a0,s6
 83e:	e41ff0ef          	jal	ra,67e <putc>
      state = 0;
 842:	4981                	li	s3,0
 844:	b7b9                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 846:	008b8913          	addi	s2,s7,8
 84a:	4685                	li	a3,1
 84c:	4629                	li	a2,10
 84e:	000bb583          	ld	a1,0(s7)
 852:	855a                	mv	a0,s6
 854:	e49ff0ef          	jal	ra,69c <printint>
        i += 1;
 858:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 85a:	8bca                	mv	s7,s2
      state = 0;
 85c:	4981                	li	s3,0
        i += 1;
 85e:	bf15                	j	792 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 860:	03860563          	beq	a2,s8,88a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 864:	07b60963          	beq	a2,s11,8d6 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 868:	07800793          	li	a5,120
 86c:	fcf613e3          	bne	a2,a5,832 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 870:	008b8913          	addi	s2,s7,8
 874:	4681                	li	a3,0
 876:	4641                	li	a2,16
 878:	000bb583          	ld	a1,0(s7)
 87c:	855a                	mv	a0,s6
 87e:	e1fff0ef          	jal	ra,69c <printint>
        i += 2;
 882:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 884:	8bca                	mv	s7,s2
      state = 0;
 886:	4981                	li	s3,0
        i += 2;
 888:	b729                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 88a:	008b8913          	addi	s2,s7,8
 88e:	4685                	li	a3,1
 890:	4629                	li	a2,10
 892:	000bb583          	ld	a1,0(s7)
 896:	855a                	mv	a0,s6
 898:	e05ff0ef          	jal	ra,69c <printint>
        i += 2;
 89c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 89e:	8bca                	mv	s7,s2
      state = 0;
 8a0:	4981                	li	s3,0
        i += 2;
 8a2:	bdc5                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8a4:	008b8913          	addi	s2,s7,8
 8a8:	4681                	li	a3,0
 8aa:	4629                	li	a2,10
 8ac:	000be583          	lwu	a1,0(s7)
 8b0:	855a                	mv	a0,s6
 8b2:	debff0ef          	jal	ra,69c <printint>
 8b6:	8bca                	mv	s7,s2
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	bde1                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8bc:	008b8913          	addi	s2,s7,8
 8c0:	4681                	li	a3,0
 8c2:	4629                	li	a2,10
 8c4:	000bb583          	ld	a1,0(s7)
 8c8:	855a                	mv	a0,s6
 8ca:	dd3ff0ef          	jal	ra,69c <printint>
        i += 1;
 8ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d0:	8bca                	mv	s7,s2
      state = 0;
 8d2:	4981                	li	s3,0
        i += 1;
 8d4:	bd7d                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d6:	008b8913          	addi	s2,s7,8
 8da:	4681                	li	a3,0
 8dc:	4629                	li	a2,10
 8de:	000bb583          	ld	a1,0(s7)
 8e2:	855a                	mv	a0,s6
 8e4:	db9ff0ef          	jal	ra,69c <printint>
        i += 2;
 8e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ea:	8bca                	mv	s7,s2
      state = 0;
 8ec:	4981                	li	s3,0
        i += 2;
 8ee:	b555                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8f0:	008b8913          	addi	s2,s7,8
 8f4:	4681                	li	a3,0
 8f6:	4641                	li	a2,16
 8f8:	000be583          	lwu	a1,0(s7)
 8fc:	855a                	mv	a0,s6
 8fe:	d9fff0ef          	jal	ra,69c <printint>
 902:	8bca                	mv	s7,s2
      state = 0;
 904:	4981                	li	s3,0
 906:	b571                	j	792 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 908:	008b8913          	addi	s2,s7,8
 90c:	4681                	li	a3,0
 90e:	4641                	li	a2,16
 910:	000bb583          	ld	a1,0(s7)
 914:	855a                	mv	a0,s6
 916:	d87ff0ef          	jal	ra,69c <printint>
        i += 1;
 91a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 91c:	8bca                	mv	s7,s2
      state = 0;
 91e:	4981                	li	s3,0
        i += 1;
 920:	bd8d                	j	792 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 922:	008b8793          	addi	a5,s7,8
 926:	f8f43423          	sd	a5,-120(s0)
 92a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 92e:	03000593          	li	a1,48
 932:	855a                	mv	a0,s6
 934:	d4bff0ef          	jal	ra,67e <putc>
  putc(fd, 'x');
 938:	07800593          	li	a1,120
 93c:	855a                	mv	a0,s6
 93e:	d41ff0ef          	jal	ra,67e <putc>
 942:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 944:	03c9d793          	srli	a5,s3,0x3c
 948:	97e6                	add	a5,a5,s9
 94a:	0007c583          	lbu	a1,0(a5)
 94e:	855a                	mv	a0,s6
 950:	d2fff0ef          	jal	ra,67e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 954:	0992                	slli	s3,s3,0x4
 956:	397d                	addiw	s2,s2,-1
 958:	fe0916e3          	bnez	s2,944 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 95c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 960:	4981                	li	s3,0
 962:	bd05                	j	792 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 964:	008b8913          	addi	s2,s7,8
 968:	000bc583          	lbu	a1,0(s7)
 96c:	855a                	mv	a0,s6
 96e:	d11ff0ef          	jal	ra,67e <putc>
 972:	8bca                	mv	s7,s2
      state = 0;
 974:	4981                	li	s3,0
 976:	bd31                	j	792 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 978:	008b8993          	addi	s3,s7,8
 97c:	000bb903          	ld	s2,0(s7)
 980:	00090f63          	beqz	s2,99e <vprintf+0x266>
        for(; *s; s++)
 984:	00094583          	lbu	a1,0(s2)
 988:	c195                	beqz	a1,9ac <vprintf+0x274>
          putc(fd, *s);
 98a:	855a                	mv	a0,s6
 98c:	cf3ff0ef          	jal	ra,67e <putc>
        for(; *s; s++)
 990:	0905                	addi	s2,s2,1
 992:	00094583          	lbu	a1,0(s2)
 996:	f9f5                	bnez	a1,98a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 998:	8bce                	mv	s7,s3
      state = 0;
 99a:	4981                	li	s3,0
 99c:	bbdd                	j	792 <vprintf+0x5a>
          s = "(null)";
 99e:	00000917          	auipc	s2,0x0
 9a2:	2da90913          	addi	s2,s2,730 # c78 <malloc+0x1c4>
        for(; *s; s++)
 9a6:	02800593          	li	a1,40
 9aa:	b7c5                	j	98a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 9ac:	8bce                	mv	s7,s3
      state = 0;
 9ae:	4981                	li	s3,0
 9b0:	b3cd                	j	792 <vprintf+0x5a>
    }
  }
}
 9b2:	70e6                	ld	ra,120(sp)
 9b4:	7446                	ld	s0,112(sp)
 9b6:	74a6                	ld	s1,104(sp)
 9b8:	7906                	ld	s2,96(sp)
 9ba:	69e6                	ld	s3,88(sp)
 9bc:	6a46                	ld	s4,80(sp)
 9be:	6aa6                	ld	s5,72(sp)
 9c0:	6b06                	ld	s6,64(sp)
 9c2:	7be2                	ld	s7,56(sp)
 9c4:	7c42                	ld	s8,48(sp)
 9c6:	7ca2                	ld	s9,40(sp)
 9c8:	7d02                	ld	s10,32(sp)
 9ca:	6de2                	ld	s11,24(sp)
 9cc:	6109                	addi	sp,sp,128
 9ce:	8082                	ret

00000000000009d0 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 9d0:	715d                	addi	sp,sp,-80
 9d2:	ec06                	sd	ra,24(sp)
 9d4:	e822                	sd	s0,16(sp)
 9d6:	1000                	addi	s0,sp,32
 9d8:	e010                	sd	a2,0(s0)
 9da:	e414                	sd	a3,8(s0)
 9dc:	e818                	sd	a4,16(s0)
 9de:	ec1c                	sd	a5,24(s0)
 9e0:	03043023          	sd	a6,32(s0)
 9e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ec:	8622                	mv	a2,s0
 9ee:	d4bff0ef          	jal	ra,738 <vprintf>
}
 9f2:	60e2                	ld	ra,24(sp)
 9f4:	6442                	ld	s0,16(sp)
 9f6:	6161                	addi	sp,sp,80
 9f8:	8082                	ret

00000000000009fa <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 9fa:	711d                	addi	sp,sp,-96
 9fc:	ec06                	sd	ra,24(sp)
 9fe:	e822                	sd	s0,16(sp)
 a00:	1000                	addi	s0,sp,32
 a02:	e40c                	sd	a1,8(s0)
 a04:	e810                	sd	a2,16(s0)
 a06:	ec14                	sd	a3,24(s0)
 a08:	f018                	sd	a4,32(s0)
 a0a:	f41c                	sd	a5,40(s0)
 a0c:	03043823          	sd	a6,48(s0)
 a10:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a14:	00840613          	addi	a2,s0,8
 a18:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a1c:	85aa                	mv	a1,a0
 a1e:	4505                	li	a0,1
 a20:	d19ff0ef          	jal	ra,738 <vprintf>
}
 a24:	60e2                	ld	ra,24(sp)
 a26:	6442                	ld	s0,16(sp)
 a28:	6125                	addi	sp,sp,96
 a2a:	8082                	ret

0000000000000a2c <free>:
 *   无
 */

void
free(void *ap)
{
 a2c:	1141                	addi	sp,sp,-16
 a2e:	e422                	sd	s0,8(sp)
 a30:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 a32:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a36:	00000797          	auipc	a5,0x0
 a3a:	5ca7b783          	ld	a5,1482(a5) # 1000 <freep>
 a3e:	a805                	j	a6e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a40:	4618                	lw	a4,8(a2)
 a42:	9db9                	addw	a1,a1,a4
 a44:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a48:	6398                	ld	a4,0(a5)
 a4a:	6318                	ld	a4,0(a4)
 a4c:	fee53823          	sd	a4,-16(a0)
 a50:	a091                	j	a94 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a52:	ff852703          	lw	a4,-8(a0)
 a56:	9e39                	addw	a2,a2,a4
 a58:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a5a:	ff053703          	ld	a4,-16(a0)
 a5e:	e398                	sd	a4,0(a5)
 a60:	a099                	j	aa6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a62:	6398                	ld	a4,0(a5)
 a64:	00e7e463          	bltu	a5,a4,a6c <free+0x40>
 a68:	00e6ea63          	bltu	a3,a4,a7c <free+0x50>
{
 a6c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a6e:	fed7fae3          	bgeu	a5,a3,a62 <free+0x36>
 a72:	6398                	ld	a4,0(a5)
 a74:	00e6e463          	bltu	a3,a4,a7c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a78:	fee7eae3          	bltu	a5,a4,a6c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a7c:	ff852583          	lw	a1,-8(a0)
 a80:	6390                	ld	a2,0(a5)
 a82:	02059713          	slli	a4,a1,0x20
 a86:	9301                	srli	a4,a4,0x20
 a88:	0712                	slli	a4,a4,0x4
 a8a:	9736                	add	a4,a4,a3
 a8c:	fae60ae3          	beq	a2,a4,a40 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a90:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a94:	4790                	lw	a2,8(a5)
 a96:	02061713          	slli	a4,a2,0x20
 a9a:	9301                	srli	a4,a4,0x20
 a9c:	0712                	slli	a4,a4,0x4
 a9e:	973e                	add	a4,a4,a5
 aa0:	fae689e3          	beq	a3,a4,a52 <free+0x26>
  } else
    p->s.ptr = bp;
 aa4:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 aa6:	00000717          	auipc	a4,0x0
 aaa:	54f73d23          	sd	a5,1370(a4) # 1000 <freep>
}
 aae:	6422                	ld	s0,8(sp)
 ab0:	0141                	addi	sp,sp,16
 ab2:	8082                	ret

0000000000000ab4 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 ab4:	7139                	addi	sp,sp,-64
 ab6:	fc06                	sd	ra,56(sp)
 ab8:	f822                	sd	s0,48(sp)
 aba:	f426                	sd	s1,40(sp)
 abc:	f04a                	sd	s2,32(sp)
 abe:	ec4e                	sd	s3,24(sp)
 ac0:	e852                	sd	s4,16(sp)
 ac2:	e456                	sd	s5,8(sp)
 ac4:	e05a                	sd	s6,0(sp)
 ac6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ac8:	02051493          	slli	s1,a0,0x20
 acc:	9081                	srli	s1,s1,0x20
 ace:	04bd                	addi	s1,s1,15
 ad0:	8091                	srli	s1,s1,0x4
 ad2:	0014899b          	addiw	s3,s1,1
 ad6:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 ad8:	00000517          	auipc	a0,0x0
 adc:	52853503          	ld	a0,1320(a0) # 1000 <freep>
 ae0:	c515                	beqz	a0,b0c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 ae4:	4798                	lw	a4,8(a5)
 ae6:	02977f63          	bgeu	a4,s1,b24 <malloc+0x70>
 aea:	8a4e                	mv	s4,s3
 aec:	0009871b          	sext.w	a4,s3
 af0:	6685                	lui	a3,0x1
 af2:	00d77363          	bgeu	a4,a3,af8 <malloc+0x44>
 af6:	6a05                	lui	s4,0x1
 af8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 afc:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 b00:	00000917          	auipc	s2,0x0
 b04:	50090913          	addi	s2,s2,1280 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 b08:	5afd                	li	s5,-1
 b0a:	a0bd                	j	b78 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 b0c:	00000797          	auipc	a5,0x0
 b10:	50478793          	addi	a5,a5,1284 # 1010 <base>
 b14:	00000717          	auipc	a4,0x0
 b18:	4ef73623          	sd	a5,1260(a4) # 1000 <freep>
 b1c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b1e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 b22:	b7e1                	j	aea <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 b24:	02e48b63          	beq	s1,a4,b5a <malloc+0xa6>
        p->s.size -= nunits;
 b28:	4137073b          	subw	a4,a4,s3
 b2c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b2e:	1702                	slli	a4,a4,0x20
 b30:	9301                	srli	a4,a4,0x20
 b32:	0712                	slli	a4,a4,0x4
 b34:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b36:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 b3a:	00000717          	auipc	a4,0x0
 b3e:	4ca73323          	sd	a0,1222(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 b42:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 b46:	70e2                	ld	ra,56(sp)
 b48:	7442                	ld	s0,48(sp)
 b4a:	74a2                	ld	s1,40(sp)
 b4c:	7902                	ld	s2,32(sp)
 b4e:	69e2                	ld	s3,24(sp)
 b50:	6a42                	ld	s4,16(sp)
 b52:	6aa2                	ld	s5,8(sp)
 b54:	6b02                	ld	s6,0(sp)
 b56:	6121                	addi	sp,sp,64
 b58:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b5a:	6398                	ld	a4,0(a5)
 b5c:	e118                	sd	a4,0(a0)
 b5e:	bff1                	j	b3a <malloc+0x86>
  hp->s.size = nu;
 b60:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 b64:	0541                	addi	a0,a0,16
 b66:	ec7ff0ef          	jal	ra,a2c <free>
  return freep;
 b6a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b6e:	dd61                	beqz	a0,b46 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b70:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 b72:	4798                	lw	a4,8(a5)
 b74:	fa9778e3          	bgeu	a4,s1,b24 <malloc+0x70>
    if(p == freep)
 b78:	00093703          	ld	a4,0(s2)
 b7c:	853e                	mv	a0,a5
 b7e:	fef719e3          	bne	a4,a5,b70 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 b82:	8552                	mv	a0,s4
 b84:	9e7ff0ef          	jal	ra,56a <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 b88:	fd551ce3          	bne	a0,s5,b60 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 b8c:	4501                	li	a0,0
 b8e:	bf65                	j	b46 <malloc+0x92>
