
user/_ipc_bench:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <measure>:
}

// ----------------------------- driver -----------------------------
// run one transport REPS times at a given total size, report mean ticks + deltas
static void measure(const char *tag, int is_shm, int total, int reps)
{
   0:	7151                	addi	sp,sp,-240
   2:	f586                	sd	ra,232(sp)
   4:	f1a2                	sd	s0,224(sp)
   6:	eda6                	sd	s1,216(sp)
   8:	e9ca                	sd	s2,208(sp)
   a:	e5ce                	sd	s3,200(sp)
   c:	e1d2                	sd	s4,192(sp)
   e:	fd56                	sd	s5,184(sp)
  10:	f95a                	sd	s6,176(sp)
  12:	f55e                	sd	s7,168(sp)
  14:	f162                	sd	s8,160(sp)
  16:	ed66                	sd	s9,152(sp)
  18:	e96a                	sd	s10,144(sp)
  1a:	e56e                	sd	s11,136(sp)
  1c:	1980                	addi	s0,sp,240
  1e:	f4a43423          	sd	a0,-184(s0)
  22:	f6b43823          	sd	a1,-144(s0)
  26:	8cb2                	mv	s9,a2
  28:	8c36                	mv	s8,a3
  int t_sum = 0, t_min = 0x7fffffff, t_max = 0;
  int fail = 0;

  vmstats(&A);
  2a:	00001517          	auipc	a0,0x1
  2e:	ff650513          	addi	a0,a0,-10 # 1020 <A>
  32:	0df000ef          	jal	ra,910 <vmstats>
  for(int k = 0; k < reps; k++){
  36:	45805563          	blez	s8,480 <measure+0x480>
  int nchunks = total / CHUNK;
  3a:	41fcdb1b          	sraiw	s6,s9,0x1f
  3e:	014b5b1b          	srliw	s6,s6,0x14
  42:	019b0b3b          	addw	s6,s6,s9
  46:	40cb5b1b          	sraiw	s6,s6,0xc
  for(int k = 0; k < reps; k++){
  4a:	f6043023          	sd	zero,-160(s0)
  int fail = 0;
  4e:	f6043423          	sd	zero,-152(s0)
  int t_sum = 0, t_min = 0x7fffffff, t_max = 0;
  52:	f6043c23          	sd	zero,-136(s0)
  56:	80000bb7          	lui	s7,0x80000
  5a:	fffbcb93          	not	s7,s7
  5e:	4d01                	li	s10,0
  for(int c = 0; c < nchunks; c++){
  60:	6a05                	lui	s4,0x1
  62:	00001797          	auipc	a5,0x1
  66:	04f78793          	addi	a5,a5,79 # 10b1 <local.0+0x1>
  6a:	40f007bb          	negw	a5,a5
  6e:	0ff7f793          	andi	a5,a5,255
  72:	f4f43023          	sd	a5,-192(s0)
  p[0] = (char)seq;
  76:	00001a97          	auipc	s5,0x1
  7a:	03aa8a93          	addi	s5,s5,58 # 10b0 <local.0>
  7e:	a259                	j	204 <measure+0x204>
  if(r == (void*)-1){ printf("mmap shm failed\n"); return -1; }
  80:	00001517          	auipc	a0,0x1
  84:	dc050513          	addi	a0,a0,-576 # e40 <malloc+0xf2>
  88:	40d000ef          	jal	ra,c94 <printf>
  8c:	54fd                	li	s1,-1
  8e:	a22d                	j	1b8 <measure+0x1b8>
    printf("sem_open failed\n"); munmap((void*)r, sizeof(struct shmring)); return -1;
  90:	00001517          	auipc	a0,0x1
  94:	dc850513          	addi	a0,a0,-568 # e58 <malloc+0x10a>
  98:	3fd000ef          	jal	ra,c94 <printf>
  9c:	65c5                	lui	a1,0x11
  9e:	8526                	mv	a0,s1
  a0:	041000ef          	jal	ra,8e0 <munmap>
  a4:	54fd                	li	s1,-1
  a6:	aa09                	j	1b8 <measure+0x1b8>
    for(int c = 0; c < nchunks; c++){
  a8:	6785                	lui	a5,0x1
  aa:	08fcc263          	blt	s9,a5,12e <measure+0x12e>
  ae:	89aa                	mv	s3,a0
      memmove(local, &r->buf[idx*CHUNK], CHUNK);   // real copy OUT (== pipe read)
  b0:	00003a17          	auipc	s4,0x3
  b4:	000a0a13          	mv	s4,s4
  if(p[CHUNK-1] != (char)(seq + CHUNK - 1)) return 0;   // sample, not full scan
  b8:	00004a97          	auipc	s5,0x4
  bc:	ff8a8a93          	addi	s5,s5,-8 # 40b0 <base>
  c0:	a819                	j	d6 <measure+0xd6>
      if(!check_chunk(local, c)){ ok = 0; break; }
  c2:	37fd                	addiw	a5,a5,-1
  c4:	fffac703          	lbu	a4,-1(s5)
  c8:	0ff7f793          	andi	a5,a5,255
  cc:	04f71763          	bne	a4,a5,11a <measure+0x11a>
    for(int c = 0; c < nchunks; c++){
  d0:	2985                	addiw	s3,s3,1
  d2:	0569dc63          	bge	s3,s6,12a <measure+0x12a>
      sem_wait(SEM_FULL);              // wait for a filled slot
  d6:	0c900513          	li	a0,201
  da:	027000ef          	jal	ra,900 <sem_wait>
      int idx = r->tail % SLOTS;
  de:	40dc                	lw	a5,4(s1)
  e0:	41f7d71b          	sraiw	a4,a5,0x1f
  e4:	01c7571b          	srliw	a4,a4,0x1c
  e8:	00f705bb          	addw	a1,a4,a5
  ec:	89bd                	andi	a1,a1,15
  ee:	9d99                	subw	a1,a1,a4
      memmove(local, &r->buf[idx*CHUNK], CHUNK);   // real copy OUT (== pipe read)
  f0:	2585                	addiw	a1,a1,1
  f2:	00c5959b          	slliw	a1,a1,0xc
  f6:	6605                	lui	a2,0x1
  f8:	95a6                	add	a1,a1,s1
  fa:	8552                	mv	a0,s4
  fc:	662000ef          	jal	ra,75e <memmove>
      r->tail++;
 100:	40dc                	lw	a5,4(s1)
 102:	2785                	addiw	a5,a5,1
 104:	c0dc                	sw	a5,4(s1)
      sem_post(SEM_EMPTY);             // hand the slot back
 106:	0c800513          	li	a0,200
 10a:	7fe000ef          	jal	ra,908 <sem_post>
  if(p[0] != (char)seq) return 0;
 10e:	0ff9f793          	andi	a5,s3,255
 112:	000a4703          	lbu	a4,0(s4) # 30b0 <local.2>
 116:	faf706e3          	beq	a4,a5,c2 <measure+0xc2>
    munmap((void*)r, sizeof(struct shmring));
 11a:	65c5                	lui	a1,0x11
 11c:	8526                	mv	a0,s1
 11e:	7c2000ef          	jal	ra,8e0 <munmap>
    exit(ok ? 0 : 1);
 122:	00193513          	seqz	a0,s2
 126:	712000ef          	jal	ra,838 <exit>
    int ok = 1;
 12a:	4905                	li	s2,1
 12c:	b7fd                	j	11a <measure+0x11a>
 12e:	4905                	li	s2,1
 130:	b7ed                	j	11a <measure+0x11a>
    sem_wait(SEM_EMPTY);               // wait for a free slot
 132:	0c800513          	li	a0,200
 136:	7ca000ef          	jal	ra,900 <sem_wait>
    int idx = r->head % SLOTS;
 13a:	409c                	lw	a5,0(s1)
 13c:	41f7d71b          	sraiw	a4,a5,0x1f
 140:	01c7571b          	srliw	a4,a4,0x1c
 144:	9fb9                	addw	a5,a5,a4
 146:	8bbd                	andi	a5,a5,15
 148:	9f99                	subw	a5,a5,a4
    fill_chunk(&r->buf[idx*CHUNK], c); // real copy IN (== pipe write)
 14a:	00c7979b          	slliw	a5,a5,0xc
 14e:	0007871b          	sext.w	a4,a5
 152:	00fd86bb          	addw	a3,s11,a5
 156:	96a6                	add	a3,a3,s1
  p[0] = (char)seq;
 158:	0ff97613          	andi	a2,s2,255
 15c:	00e487b3          	add	a5,s1,a4
 160:	97d2                	add	a5,a5,s4
 162:	00c78023          	sb	a2,0(a5) # 1000 <g_pass>
  for(int i = 1; i < CHUNK; i++) p[i] = (char)(seq + i);
 166:	00168713          	addi	a4,a3,1
 16a:	96d2                	add	a3,a3,s4
  p[0] = (char)seq;
 16c:	87ba                	mv	a5,a4
  for(int i = 1; i < CHUNK; i++) p[i] = (char)(seq + i);
 16e:	40e9873b          	subw	a4,s3,a4
 172:	9e39                	addw	a2,a2,a4
 174:	00f6073b          	addw	a4,a2,a5
 178:	00e78023          	sb	a4,0(a5)
 17c:	0785                	addi	a5,a5,1
 17e:	fed79be3          	bne	a5,a3,174 <measure+0x174>
    r->head++;
 182:	409c                	lw	a5,0(s1)
 184:	2785                	addiw	a5,a5,1
 186:	c09c                	sw	a5,0(s1)
    sem_post(SEM_FULL);                // mark slot filled
 188:	0c900513          	li	a0,201
 18c:	77c000ef          	jal	ra,908 <sem_post>
  for(int c = 0; c < nchunks; c++){    // producer
 190:	2905                	addiw	s2,s2,1
 192:	fb6940e3          	blt	s2,s6,132 <measure+0x132>
  int st = -1; wait(&st);
 196:	57fd                	li	a5,-1
 198:	f8f42423          	sw	a5,-120(s0)
 19c:	f8840513          	addi	a0,s0,-120
 1a0:	6a0000ef          	jal	ra,840 <wait>
  munmap((void*)r, sizeof(struct shmring));
 1a4:	65c5                	lui	a1,0x11
 1a6:	8526                	mv	a0,s1
 1a8:	738000ef          	jal	ra,8e0 <munmap>
  shmctl(SHMKEY, IPC_RMID);            // tear down so next size starts clean
 1ac:	4581                	li	a1,0
 1ae:	4529                	li	a0,10
 1b0:	738000ef          	jal	ra,8e8 <shmctl>
  return st;
 1b4:	f8842483          	lw	s1,-120(s0)
    int t0 = uptime();
    int rc = is_shm ? run_shm(total) : run_pipe(total);
    int t1 = uptime();
 1b8:	718000ef          	jal	ra,8d0 <uptime>
 1bc:	87aa                	mv	a5,a0
    if(rc != 0) fail = 1;
 1be:	c481                	beqz	s1,1c6 <measure+0x1c6>
 1c0:	4705                	li	a4,1
 1c2:	f6e43423          	sd	a4,-152(s0)
    int dt = t1 - t0;
 1c6:	f5043703          	ld	a4,-176(s0)
 1ca:	9f99                	subw	a5,a5,a4
    t_sum += dt;
 1cc:	01a78d3b          	addw	s10,a5,s10
    if(dt < t_min) t_min = dt;
 1d0:	873e                	mv	a4,a5
 1d2:	0007869b          	sext.w	a3,a5
 1d6:	00dbd363          	bge	s7,a3,1dc <measure+0x1dc>
 1da:	875e                	mv	a4,s7
 1dc:	00070b9b          	sext.w	s7,a4
    if(dt > t_max) t_max = dt;
 1e0:	873e                	mv	a4,a5
 1e2:	2781                	sext.w	a5,a5
 1e4:	f7843683          	ld	a3,-136(s0)
 1e8:	00d7d363          	bge	a5,a3,1ee <measure+0x1ee>
 1ec:	8736                	mv	a4,a3
 1ee:	0007079b          	sext.w	a5,a4
 1f2:	f6f43c23          	sd	a5,-136(s0)
  for(int k = 0; k < reps; k++){
 1f6:	f6043783          	ld	a5,-160(s0)
 1fa:	2785                	addiw	a5,a5,1
 1fc:	f6f43023          	sd	a5,-160(s0)
 200:	1afc0363          	beq	s8,a5,3a6 <measure+0x3a6>
    int t0 = uptime();
 204:	6cc000ef          	jal	ra,8d0 <uptime>
 208:	f4a43823          	sd	a0,-176(s0)
    int rc = is_shm ? run_shm(total) : run_pipe(total);
 20c:	f7043783          	ld	a5,-144(s0)
 210:	cba9                	beqz	a5,262 <measure+0x262>
  struct shmring *r = (struct shmring*)mmap(0, sizeof(struct shmring),
 212:	4729                	li	a4,10
 214:	468d                	li	a3,3
 216:	460d                	li	a2,3
 218:	65c5                	lui	a1,0x11
 21a:	4501                	li	a0,0
 21c:	6bc000ef          	jal	ra,8d8 <mmap>
 220:	84aa                	mv	s1,a0
  if(r == (void*)-1){ printf("mmap shm failed\n"); return -1; }
 222:	57fd                	li	a5,-1
 224:	e4f50ee3          	beq	a0,a5,80 <measure+0x80>
  r->head = 0; r->tail = 0;
 228:	00052023          	sw	zero,0(a0)
 22c:	00052223          	sw	zero,4(a0)
  if(sem_open(SEM_EMPTY, SLOTS) < 0 || sem_open(SEM_FULL, 0) < 0){
 230:	45c1                	li	a1,16
 232:	0c800513          	li	a0,200
 236:	6c2000ef          	jal	ra,8f8 <sem_open>
 23a:	e4054be3          	bltz	a0,90 <measure+0x90>
 23e:	4581                	li	a1,0
 240:	0c900513          	li	a0,201
 244:	6b4000ef          	jal	ra,8f8 <sem_open>
 248:	e40544e3          	bltz	a0,90 <measure+0x90>
  int pid = fork();
 24c:	5e4000ef          	jal	ra,830 <fork>
 250:	892a                	mv	s2,a0
  if(pid == 0){                        // consumer
 252:	e4050be3          	beqz	a0,a8 <measure+0xa8>
  for(int c = 0; c < nchunks; c++){    // producer
 256:	4901                	li	s2,0
    fill_chunk(&r->buf[idx*CHUNK], c); // real copy IN (== pipe write)
 258:	6d85                	lui	s11,0x1
  for(int i = 1; i < CHUNK; i++) p[i] = (char)(seq + i);
 25a:	4985                	li	s3,1
  for(int c = 0; c < nchunks; c++){    // producer
 25c:	ed4cdbe3          	bge	s9,s4,132 <measure+0x132>
 260:	bf1d                	j	196 <measure+0x196>
  if(pipe(pfd) < 0){ printf("pipe() failed\n"); return -1; }
 262:	f8840513          	addi	a0,s0,-120
 266:	5e2000ef          	jal	ra,848 <pipe>
 26a:	08054e63          	bltz	a0,306 <measure+0x306>
  int pid = fork();
 26e:	5c2000ef          	jal	ra,830 <fork>
 272:	84aa                	mv	s1,a0
  if(pid == 0){                       // consumer
 274:	c14d                	beqz	a0,316 <measure+0x316>
  close(pfd[0]);                       // producer
 276:	f8842503          	lw	a0,-120(s0)
 27a:	5e6000ef          	jal	ra,860 <close>
  for(int c = 0; c < nchunks; c++){
 27e:	074cc663          	blt	s9,s4,2ea <measure+0x2ea>
 282:	f4043483          	ld	s1,-192(s0)
 286:	f7043783          	ld	a5,-144(s0)
 28a:	f4f43c23          	sd	a5,-168(s0)
 28e:	00002917          	auipc	s2,0x2
 292:	e2290913          	addi	s2,s2,-478 # 20b0 <local.1>
      int n = write(pfd[1], local + sent, CHUNK - sent);
 296:	6d85                	lui	s11,0x1
  p[0] = (char)seq;
 298:	f5843783          	ld	a5,-168(s0)
 29c:	00fa8023          	sb	a5,0(s5)
 2a0:	00001797          	auipc	a5,0x1
 2a4:	e1178793          	addi	a5,a5,-495 # 10b1 <local.0+0x1>
 2a8:	2485                	addiw	s1,s1,1
 2aa:	0ff4f493          	andi	s1,s1,255
  for(int i = 1; i < CHUNK; i++) p[i] = (char)(seq + i);
 2ae:	0097873b          	addw	a4,a5,s1
 2b2:	00e78023          	sb	a4,0(a5)
 2b6:	0785                	addi	a5,a5,1
 2b8:	ff279be3          	bne	a5,s2,2ae <measure+0x2ae>
    int sent = 0;
 2bc:	f7043983          	ld	s3,-144(s0)
      int n = write(pfd[1], local + sent, CHUNK - sent);
 2c0:	413d863b          	subw	a2,s11,s3
 2c4:	013a85b3          	add	a1,s5,s3
 2c8:	f8c42503          	lw	a0,-116(s0)
 2cc:	58c000ef          	jal	ra,858 <write>
      if(n <= 0){ close(pfd[1]); wait(0); return -1; }
 2d0:	0ca05263          	blez	a0,394 <measure+0x394>
      sent += n;
 2d4:	013509bb          	addw	s3,a0,s3
    while(sent < CHUNK){
 2d8:	ff49c4e3          	blt	s3,s4,2c0 <measure+0x2c0>
  for(int c = 0; c < nchunks; c++){
 2dc:	f5843783          	ld	a5,-168(s0)
 2e0:	2785                	addiw	a5,a5,1
 2e2:	f4f43c23          	sd	a5,-168(s0)
 2e6:	fb67c9e3          	blt	a5,s6,298 <measure+0x298>
  close(pfd[1]);
 2ea:	f8c42503          	lw	a0,-116(s0)
 2ee:	572000ef          	jal	ra,860 <close>
  int st = -1; wait(&st);
 2f2:	57fd                	li	a5,-1
 2f4:	f8f42223          	sw	a5,-124(s0)
 2f8:	f8440513          	addi	a0,s0,-124
 2fc:	544000ef          	jal	ra,840 <wait>
  return st;
 300:	f8442483          	lw	s1,-124(s0)
 304:	bd55                	j	1b8 <measure+0x1b8>
  if(pipe(pfd) < 0){ printf("pipe() failed\n"); return -1; }
 306:	00001517          	auipc	a0,0x1
 30a:	b6a50513          	addi	a0,a0,-1174 # e70 <malloc+0x122>
 30e:	187000ef          	jal	ra,c94 <printf>
 312:	54fd                	li	s1,-1
 314:	b555                	j	1b8 <measure+0x1b8>
    close(pfd[1]);
 316:	f8c42503          	lw	a0,-116(s0)
 31a:	546000ef          	jal	ra,860 <close>
    for(int c = 0; c < nchunks; c++){
 31e:	6785                	lui	a5,0x1
 320:	8926                	mv	s2,s1
 322:	00fcce63          	blt	s9,a5,33e <measure+0x33e>
      int got = 0;
 326:	8c26                	mv	s8,s1
        int n = read(pfd[0], local + got, CHUNK - got);
 328:	6b85                	lui	s7,0x1
 32a:	00002997          	auipc	s3,0x2
 32e:	d8698993          	addi	s3,s3,-634 # 20b0 <local.1>
      while(got < CHUNK){             // pipe may deliver partial chunks
 332:	6a85                	lui	s5,0x1
  if(p[CHUNK-1] != (char)(seq + CHUNK - 1)) return 0;   // sample, not full scan
 334:	00003a17          	auipc	s4,0x3
 338:	d7ca0a13          	addi	s4,s4,-644 # 30b0 <local.2>
 33c:	a01d                	j	362 <measure+0x362>
    int ok = 1;
 33e:	4485                	li	s1,1
 340:	a091                	j	384 <measure+0x384>
  if(p[0] != (char)seq) return 0;
 342:	0ff97793          	andi	a5,s2,255
 346:	0009c703          	lbu	a4,0(s3)
 34a:	02f71d63          	bne	a4,a5,384 <measure+0x384>
      if(!ok || !check_chunk(local, c)){ ok = 0; break; }
 34e:	37fd                	addiw	a5,a5,-1
 350:	fffa4703          	lbu	a4,-1(s4)
 354:	0ff7f793          	andi	a5,a5,255
 358:	02f71663          	bne	a4,a5,384 <measure+0x384>
    for(int c = 0; c < nchunks; c++){
 35c:	2905                	addiw	s2,s2,1
 35e:	03695263          	bge	s2,s6,382 <measure+0x382>
      int got = 0;
 362:	8ce2                	mv	s9,s8
        int n = read(pfd[0], local + got, CHUNK - got);
 364:	419b863b          	subw	a2,s7,s9
 368:	019985b3          	add	a1,s3,s9
 36c:	f8842503          	lw	a0,-120(s0)
 370:	4e0000ef          	jal	ra,850 <read>
        if(n <= 0){ ok = 0; break; }
 374:	00a05863          	blez	a0,384 <measure+0x384>
        got += n;
 378:	01950cbb          	addw	s9,a0,s9
      while(got < CHUNK){             // pipe may deliver partial chunks
 37c:	ff5cc4e3          	blt	s9,s5,364 <measure+0x364>
 380:	b7c9                	j	342 <measure+0x342>
 382:	4485                	li	s1,1
    close(pfd[0]);
 384:	f8842503          	lw	a0,-120(s0)
 388:	4d8000ef          	jal	ra,860 <close>
    exit(ok ? 0 : 1);
 38c:	0014b513          	seqz	a0,s1
 390:	4a8000ef          	jal	ra,838 <exit>
      if(n <= 0){ close(pfd[1]); wait(0); return -1; }
 394:	f8c42503          	lw	a0,-116(s0)
 398:	4c8000ef          	jal	ra,860 <close>
 39c:	4501                	li	a0,0
 39e:	4a2000ef          	jal	ra,840 <wait>
 3a2:	54fd                	li	s1,-1
 3a4:	bd11                	j	1b8 <measure+0x1b8>
  }
  vmstats(&B);
 3a6:	00001517          	auipc	a0,0x1
 3aa:	cc250513          	addi	a0,a0,-830 # 1068 <B>
 3ae:	562000ef          	jal	ra,910 <vmstats>

  if(fail){ g_pass = 0; }
 3b2:	f6843783          	ld	a5,-152(s0)
 3b6:	c789                	beqz	a5,3c0 <measure+0x3c0>
 3b8:	00001797          	auipc	a5,0x1
 3bc:	c407a423          	sw	zero,-952(a5) # 1000 <g_pass>
  int kb = total / 1024;
 3c0:	41fcd61b          	sraiw	a2,s9,0x1f
 3c4:	0166561b          	srliw	a2,a2,0x16
 3c8:	0196063b          	addw	a2,a2,s9
 3cc:	40a6561b          	sraiw	a2,a2,0xa
  int mean10 = (t_sum * 10) / reps;    // mean ticks * 10 (one decimal, no float)
 3d0:	002d179b          	slliw	a5,s10,0x2
 3d4:	01a787bb          	addw	a5,a5,s10
 3d8:	0017979b          	slliw	a5,a5,0x1
 3dc:	0387c7bb          	divw	a5,a5,s8
  // byte counters are summed over reps; divide to get per-transfer
  int cin  = (int)((B.copyin_bytes  - A.copyin_bytes)  / reps);
 3e0:	00001717          	auipc	a4,0x1
 3e4:	c4070713          	addi	a4,a4,-960 # 1020 <A>
 3e8:	7734                	ld	a3,104(a4)
 3ea:	730c                	ld	a1,32(a4)
 3ec:	8e8d                	sub	a3,a3,a1
 3ee:	0386d6b3          	divu	a3,a3,s8
 3f2:	2681                	sext.w	a3,a3
  int cout = (int)((B.copyout_bytes - A.copyout_bytes) / reps);
 3f4:	7b2c                	ld	a1,112(a4)
 3f6:	7708                	ld	a0,40(a4)
 3f8:	8d89                	sub	a1,a1,a0
 3fa:	0385d5b3          	divu	a1,a1,s8
 3fe:	2581                	sext.w	a1,a1
  int shf  = (int)((B.shm_faults    - A.shm_faults)    / reps);
 400:	6f28                	ld	a0,88(a4)
 402:	01073803          	ld	a6,16(a4)
 406:	41050533          	sub	a0,a0,a6
 40a:	03855533          	divu	a0,a0,s8
 40e:	2501                	sext.w	a0,a0
  int laf  = (int)((B.lazy_faults   - A.lazy_faults)   / reps);
 410:	05073803          	ld	a6,80(a4)
 414:	6718                	ld	a4,8(a4)
 416:	40e80833          	sub	a6,a6,a4
 41a:	03885833          	divu	a6,a6,s8
 41e:	2801                	sext.w	a6,a6

  printf("%s size=%dKB reps=%d ticks_mean=%d.%d min=%d max=%d copyin=%d copyout=%d shmflt=%d lazyflt=%d %s\n",
 420:	48a9                	li	a7,10
 422:	0317c73b          	divw	a4,a5,a7
 426:	0317e7bb          	remw	a5,a5,a7
 42a:	00001897          	auipc	a7,0x1
 42e:	a0688893          	addi	a7,a7,-1530 # e30 <malloc+0xe2>
 432:	f6843483          	ld	s1,-152(s0)
 436:	e489                	bnez	s1,440 <measure+0x440>
 438:	00001897          	auipc	a7,0x1
 43c:	a0088893          	addi	a7,a7,-1536 # e38 <malloc+0xea>
 440:	f046                	sd	a7,32(sp)
 442:	ec42                	sd	a6,24(sp)
 444:	e82a                	sd	a0,16(sp)
 446:	e42e                	sd	a1,8(sp)
 448:	e036                	sd	a3,0(sp)
 44a:	f7843883          	ld	a7,-136(s0)
 44e:	885e                	mv	a6,s7
 450:	86e2                	mv	a3,s8
 452:	f4843583          	ld	a1,-184(s0)
 456:	00001517          	auipc	a0,0x1
 45a:	a2a50513          	addi	a0,a0,-1494 # e80 <malloc+0x132>
 45e:	037000ef          	jal	ra,c94 <printf>
         tag, kb, reps, mean10/10, mean10%10, t_min, t_max,
         cin, cout, shf, laf, fail ? "FAIL" : "ok");
}
 462:	70ae                	ld	ra,232(sp)
 464:	740e                	ld	s0,224(sp)
 466:	64ee                	ld	s1,216(sp)
 468:	694e                	ld	s2,208(sp)
 46a:	69ae                	ld	s3,200(sp)
 46c:	6a0e                	ld	s4,192(sp)
 46e:	7aea                	ld	s5,184(sp)
 470:	7b4a                	ld	s6,176(sp)
 472:	7baa                	ld	s7,168(sp)
 474:	7c0a                	ld	s8,160(sp)
 476:	6cea                	ld	s9,152(sp)
 478:	6d4a                	ld	s10,144(sp)
 47a:	6daa                	ld	s11,136(sp)
 47c:	616d                	addi	sp,sp,240
 47e:	8082                	ret
  vmstats(&B);
 480:	00001517          	auipc	a0,0x1
 484:	be850513          	addi	a0,a0,-1048 # 1068 <B>
 488:	488000ef          	jal	ra,910 <vmstats>
  int fail = 0;
 48c:	f6043423          	sd	zero,-152(s0)
  int t_sum = 0, t_min = 0x7fffffff, t_max = 0;
 490:	f6043c23          	sd	zero,-136(s0)
 494:	80000bb7          	lui	s7,0x80000
 498:	fffbcb93          	not	s7,s7
 49c:	4d01                	li	s10,0
 49e:	b70d                	j	3c0 <measure+0x3c0>

00000000000004a0 <main>:

int
main(void)
{
 4a0:	7159                	addi	sp,sp,-112
 4a2:	f486                	sd	ra,104(sp)
 4a4:	f0a2                	sd	s0,96(sp)
 4a6:	eca6                	sd	s1,88(sp)
 4a8:	e8ca                	sd	s2,80(sp)
 4aa:	e4ce                	sd	s3,72(sp)
 4ac:	e0d2                	sd	s4,64(sp)
 4ae:	fc56                	sd	s5,56(sp)
 4b0:	f85a                	sd	s6,48(sp)
 4b2:	1880                	addi	s0,sp,112
  // (size in KB, reps) -- more reps for small sizes so ticks is measurable
  int sizesKB[] = {64, 256, 1024, 4096, 8192};
 4b4:	04000793          	li	a5,64
 4b8:	faf42423          	sw	a5,-88(s0)
 4bc:	10000793          	li	a5,256
 4c0:	faf42623          	sw	a5,-84(s0)
 4c4:	40000793          	li	a5,1024
 4c8:	faf42823          	sw	a5,-80(s0)
 4cc:	6785                	lui	a5,0x1
 4ce:	faf42a23          	sw	a5,-76(s0)
 4d2:	6789                	lui	a5,0x2
 4d4:	faf42c23          	sw	a5,-72(s0)
  int reps[]    = {50, 20,  8,    3,    2};
 4d8:	03200793          	li	a5,50
 4dc:	f8f42823          	sw	a5,-112(s0)
 4e0:	47d1                	li	a5,20
 4e2:	f8f42a23          	sw	a5,-108(s0)
 4e6:	47a1                	li	a5,8
 4e8:	f8f42c23          	sw	a5,-104(s0)
 4ec:	478d                	li	a5,3
 4ee:	f8f42e23          	sw	a5,-100(s0)
 4f2:	4789                	li	a5,2
 4f4:	faf42023          	sw	a5,-96(s0)
  int n = 5;

  printf("=== IPC benchmark: pipe vs SHM+SEM (CHUNK=%d, SLOTS=%d) ===\n", CHUNK, SLOTS);
 4f8:	4641                	li	a2,16
 4fa:	6585                	lui	a1,0x1
 4fc:	00001517          	auipc	a0,0x1
 500:	a1450513          	addi	a0,a0,-1516 # f10 <malloc+0x1c2>
 504:	790000ef          	jal	ra,c94 <printf>
  printf("--- PIPE ---\n");
 508:	00001517          	auipc	a0,0x1
 50c:	a4850513          	addi	a0,a0,-1464 # f50 <malloc+0x202>
 510:	784000ef          	jal	ra,c94 <printf>
  for(int i = 0; i < n; i++) measure("PIPE", 0, sizesKB[i]*1024, reps[i]);
 514:	fa840493          	addi	s1,s0,-88
 518:	f9040993          	addi	s3,s0,-112
 51c:	fbc40a93          	addi	s5,s0,-68
  printf("--- PIPE ---\n");
 520:	8a4e                	mv	s4,s3
 522:	8926                	mv	s2,s1
  for(int i = 0; i < n; i++) measure("PIPE", 0, sizesKB[i]*1024, reps[i]);
 524:	00001b17          	auipc	s6,0x1
 528:	a3cb0b13          	addi	s6,s6,-1476 # f60 <malloc+0x212>
 52c:	00092603          	lw	a2,0(s2)
 530:	000a2683          	lw	a3,0(s4)
 534:	00a6161b          	slliw	a2,a2,0xa
 538:	4581                	li	a1,0
 53a:	855a                	mv	a0,s6
 53c:	ac5ff0ef          	jal	ra,0 <measure>
 540:	0911                	addi	s2,s2,4
 542:	0a11                	addi	s4,s4,4
 544:	ff5914e3          	bne	s2,s5,52c <main+0x8c>
  printf("--- SHM+SEM ---\n");
 548:	00001517          	auipc	a0,0x1
 54c:	a2050513          	addi	a0,a0,-1504 # f68 <malloc+0x21a>
 550:	744000ef          	jal	ra,c94 <printf>
  for(int i = 0; i < n; i++) measure("SHM ", 1, sizesKB[i]*1024, reps[i]);
 554:	00001917          	auipc	s2,0x1
 558:	a2c90913          	addi	s2,s2,-1492 # f80 <malloc+0x232>
 55c:	4090                	lw	a2,0(s1)
 55e:	0009a683          	lw	a3,0(s3)
 562:	00a6161b          	slliw	a2,a2,0xa
 566:	4585                	li	a1,1
 568:	854a                	mv	a0,s2
 56a:	a97ff0ef          	jal	ra,0 <measure>
 56e:	0491                	addi	s1,s1,4
 570:	0991                	addi	s3,s3,4
 572:	ff5495e3          	bne	s1,s5,55c <main+0xbc>

  printf("\n=== correctness: %s ===\n", g_pass ? "ALL TRANSFERS VERIFIED" : "SOME FAILED");
 576:	00001797          	auipc	a5,0x1
 57a:	a8a7a783          	lw	a5,-1398(a5) # 1000 <g_pass>
 57e:	00001597          	auipc	a1,0x1
 582:	96a58593          	addi	a1,a1,-1686 # ee8 <malloc+0x19a>
 586:	e789                	bnez	a5,590 <main+0xf0>
 588:	00001597          	auipc	a1,0x1
 58c:	97858593          	addi	a1,a1,-1672 # f00 <malloc+0x1b2>
 590:	00001517          	auipc	a0,0x1
 594:	9f850513          	addi	a0,a0,-1544 # f88 <malloc+0x23a>
 598:	6fc000ef          	jal	ra,c94 <printf>
  exit(0);
 59c:	4501                	li	a0,0
 59e:	29a000ef          	jal	ra,838 <exit>

00000000000005a2 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 5a2:	1141                	addi	sp,sp,-16
 5a4:	e406                	sd	ra,8(sp)
 5a6:	e022                	sd	s0,0(sp)
 5a8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 5aa:	ef7ff0ef          	jal	ra,4a0 <main>
  exit(r);
 5ae:	28a000ef          	jal	ra,838 <exit>

00000000000005b2 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 5b2:	1141                	addi	sp,sp,-16
 5b4:	e422                	sd	s0,8(sp)
 5b6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 5b8:	87aa                	mv	a5,a0
 5ba:	0585                	addi	a1,a1,1
 5bc:	0785                	addi	a5,a5,1
 5be:	fff5c703          	lbu	a4,-1(a1)
 5c2:	fee78fa3          	sb	a4,-1(a5)
 5c6:	fb75                	bnez	a4,5ba <strcpy+0x8>
    ;
  return os;
}
 5c8:	6422                	ld	s0,8(sp)
 5ca:	0141                	addi	sp,sp,16
 5cc:	8082                	ret

00000000000005ce <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 5ce:	1141                	addi	sp,sp,-16
 5d0:	e422                	sd	s0,8(sp)
 5d2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 5d4:	00054783          	lbu	a5,0(a0)
 5d8:	cb91                	beqz	a5,5ec <strcmp+0x1e>
 5da:	0005c703          	lbu	a4,0(a1)
 5de:	00f71763          	bne	a4,a5,5ec <strcmp+0x1e>
    p++, q++;
 5e2:	0505                	addi	a0,a0,1
 5e4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 5e6:	00054783          	lbu	a5,0(a0)
 5ea:	fbe5                	bnez	a5,5da <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 5ec:	0005c503          	lbu	a0,0(a1)
}
 5f0:	40a7853b          	subw	a0,a5,a0
 5f4:	6422                	ld	s0,8(sp)
 5f6:	0141                	addi	sp,sp,16
 5f8:	8082                	ret

00000000000005fa <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 5fa:	1141                	addi	sp,sp,-16
 5fc:	e422                	sd	s0,8(sp)
 5fe:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 600:	00054783          	lbu	a5,0(a0)
 604:	cf91                	beqz	a5,620 <strlen+0x26>
 606:	0505                	addi	a0,a0,1
 608:	87aa                	mv	a5,a0
 60a:	4685                	li	a3,1
 60c:	9e89                	subw	a3,a3,a0
 60e:	00f6853b          	addw	a0,a3,a5
 612:	0785                	addi	a5,a5,1
 614:	fff7c703          	lbu	a4,-1(a5)
 618:	fb7d                	bnez	a4,60e <strlen+0x14>
    ;
  return n;
}
 61a:	6422                	ld	s0,8(sp)
 61c:	0141                	addi	sp,sp,16
 61e:	8082                	ret
  for(n = 0; s[n]; n++)
 620:	4501                	li	a0,0
 622:	bfe5                	j	61a <strlen+0x20>

0000000000000624 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 624:	1141                	addi	sp,sp,-16
 626:	e422                	sd	s0,8(sp)
 628:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 62a:	ca19                	beqz	a2,640 <memset+0x1c>
 62c:	87aa                	mv	a5,a0
 62e:	1602                	slli	a2,a2,0x20
 630:	9201                	srli	a2,a2,0x20
 632:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 636:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 63a:	0785                	addi	a5,a5,1
 63c:	fee79de3          	bne	a5,a4,636 <memset+0x12>
  }
  return dst;
}
 640:	6422                	ld	s0,8(sp)
 642:	0141                	addi	sp,sp,16
 644:	8082                	ret

0000000000000646 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 646:	1141                	addi	sp,sp,-16
 648:	e422                	sd	s0,8(sp)
 64a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 64c:	00054783          	lbu	a5,0(a0)
 650:	cb99                	beqz	a5,666 <strchr+0x20>
    if(*s == c)
 652:	00f58763          	beq	a1,a5,660 <strchr+0x1a>
  for(; *s; s++)
 656:	0505                	addi	a0,a0,1
 658:	00054783          	lbu	a5,0(a0)
 65c:	fbfd                	bnez	a5,652 <strchr+0xc>
      return (char*)s;
  return 0;
 65e:	4501                	li	a0,0
}
 660:	6422                	ld	s0,8(sp)
 662:	0141                	addi	sp,sp,16
 664:	8082                	ret
  return 0;
 666:	4501                	li	a0,0
 668:	bfe5                	j	660 <strchr+0x1a>

000000000000066a <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 66a:	711d                	addi	sp,sp,-96
 66c:	ec86                	sd	ra,88(sp)
 66e:	e8a2                	sd	s0,80(sp)
 670:	e4a6                	sd	s1,72(sp)
 672:	e0ca                	sd	s2,64(sp)
 674:	fc4e                	sd	s3,56(sp)
 676:	f852                	sd	s4,48(sp)
 678:	f456                	sd	s5,40(sp)
 67a:	f05a                	sd	s6,32(sp)
 67c:	ec5e                	sd	s7,24(sp)
 67e:	1080                	addi	s0,sp,96
 680:	8baa                	mv	s7,a0
 682:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 684:	892a                	mv	s2,a0
 686:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 688:	4aa9                	li	s5,10
 68a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 68c:	89a6                	mv	s3,s1
 68e:	2485                	addiw	s1,s1,1
 690:	0344d663          	bge	s1,s4,6bc <gets+0x52>
    cc = read(0, &c, 1);
 694:	4605                	li	a2,1
 696:	faf40593          	addi	a1,s0,-81
 69a:	4501                	li	a0,0
 69c:	1b4000ef          	jal	ra,850 <read>
    if(cc < 1)
 6a0:	00a05e63          	blez	a0,6bc <gets+0x52>
    buf[i++] = c;
 6a4:	faf44783          	lbu	a5,-81(s0)
 6a8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 6ac:	01578763          	beq	a5,s5,6ba <gets+0x50>
 6b0:	0905                	addi	s2,s2,1
 6b2:	fd679de3          	bne	a5,s6,68c <gets+0x22>
  for(i=0; i+1 < max; ){
 6b6:	89a6                	mv	s3,s1
 6b8:	a011                	j	6bc <gets+0x52>
 6ba:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 6bc:	99de                	add	s3,s3,s7
 6be:	00098023          	sb	zero,0(s3)
  return buf;
}
 6c2:	855e                	mv	a0,s7
 6c4:	60e6                	ld	ra,88(sp)
 6c6:	6446                	ld	s0,80(sp)
 6c8:	64a6                	ld	s1,72(sp)
 6ca:	6906                	ld	s2,64(sp)
 6cc:	79e2                	ld	s3,56(sp)
 6ce:	7a42                	ld	s4,48(sp)
 6d0:	7aa2                	ld	s5,40(sp)
 6d2:	7b02                	ld	s6,32(sp)
 6d4:	6be2                	ld	s7,24(sp)
 6d6:	6125                	addi	sp,sp,96
 6d8:	8082                	ret

00000000000006da <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 6da:	1101                	addi	sp,sp,-32
 6dc:	ec06                	sd	ra,24(sp)
 6de:	e822                	sd	s0,16(sp)
 6e0:	e426                	sd	s1,8(sp)
 6e2:	e04a                	sd	s2,0(sp)
 6e4:	1000                	addi	s0,sp,32
 6e6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6e8:	4581                	li	a1,0
 6ea:	18e000ef          	jal	ra,878 <open>
  if(fd < 0)
 6ee:	02054163          	bltz	a0,710 <stat+0x36>
 6f2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6f4:	85ca                	mv	a1,s2
 6f6:	19a000ef          	jal	ra,890 <fstat>
 6fa:	892a                	mv	s2,a0
  close(fd);
 6fc:	8526                	mv	a0,s1
 6fe:	162000ef          	jal	ra,860 <close>
  return r;
}
 702:	854a                	mv	a0,s2
 704:	60e2                	ld	ra,24(sp)
 706:	6442                	ld	s0,16(sp)
 708:	64a2                	ld	s1,8(sp)
 70a:	6902                	ld	s2,0(sp)
 70c:	6105                	addi	sp,sp,32
 70e:	8082                	ret
    return -1;
 710:	597d                	li	s2,-1
 712:	bfc5                	j	702 <stat+0x28>

0000000000000714 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 714:	1141                	addi	sp,sp,-16
 716:	e422                	sd	s0,8(sp)
 718:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 71a:	00054603          	lbu	a2,0(a0)
 71e:	fd06079b          	addiw	a5,a2,-48
 722:	0ff7f793          	andi	a5,a5,255
 726:	4725                	li	a4,9
 728:	02f76963          	bltu	a4,a5,75a <atoi+0x46>
 72c:	86aa                	mv	a3,a0
  n = 0;
 72e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 730:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 732:	0685                	addi	a3,a3,1
 734:	0025179b          	slliw	a5,a0,0x2
 738:	9fa9                	addw	a5,a5,a0
 73a:	0017979b          	slliw	a5,a5,0x1
 73e:	9fb1                	addw	a5,a5,a2
 740:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 744:	0006c603          	lbu	a2,0(a3)
 748:	fd06071b          	addiw	a4,a2,-48
 74c:	0ff77713          	andi	a4,a4,255
 750:	fee5f1e3          	bgeu	a1,a4,732 <atoi+0x1e>
  return n;
}
 754:	6422                	ld	s0,8(sp)
 756:	0141                	addi	sp,sp,16
 758:	8082                	ret
  n = 0;
 75a:	4501                	li	a0,0
 75c:	bfe5                	j	754 <atoi+0x40>

000000000000075e <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 75e:	1141                	addi	sp,sp,-16
 760:	e422                	sd	s0,8(sp)
 762:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 764:	02b57463          	bgeu	a0,a1,78c <memmove+0x2e>
    while(n-- > 0)
 768:	00c05f63          	blez	a2,786 <memmove+0x28>
 76c:	1602                	slli	a2,a2,0x20
 76e:	9201                	srli	a2,a2,0x20
 770:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 774:	872a                	mv	a4,a0
      *dst++ = *src++;
 776:	0585                	addi	a1,a1,1
 778:	0705                	addi	a4,a4,1
 77a:	fff5c683          	lbu	a3,-1(a1)
 77e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 782:	fee79ae3          	bne	a5,a4,776 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 786:	6422                	ld	s0,8(sp)
 788:	0141                	addi	sp,sp,16
 78a:	8082                	ret
    dst += n;
 78c:	00c50733          	add	a4,a0,a2
    src += n;
 790:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 792:	fec05ae3          	blez	a2,786 <memmove+0x28>
 796:	fff6079b          	addiw	a5,a2,-1
 79a:	1782                	slli	a5,a5,0x20
 79c:	9381                	srli	a5,a5,0x20
 79e:	fff7c793          	not	a5,a5
 7a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 7a4:	15fd                	addi	a1,a1,-1
 7a6:	177d                	addi	a4,a4,-1
 7a8:	0005c683          	lbu	a3,0(a1)
 7ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 7b0:	fee79ae3          	bne	a5,a4,7a4 <memmove+0x46>
 7b4:	bfc9                	j	786 <memmove+0x28>

00000000000007b6 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 7b6:	1141                	addi	sp,sp,-16
 7b8:	e422                	sd	s0,8(sp)
 7ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 7bc:	ca05                	beqz	a2,7ec <memcmp+0x36>
 7be:	fff6069b          	addiw	a3,a2,-1
 7c2:	1682                	slli	a3,a3,0x20
 7c4:	9281                	srli	a3,a3,0x20
 7c6:	0685                	addi	a3,a3,1
 7c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 7ca:	00054783          	lbu	a5,0(a0)
 7ce:	0005c703          	lbu	a4,0(a1)
 7d2:	00e79863          	bne	a5,a4,7e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 7d6:	0505                	addi	a0,a0,1
    p2++;
 7d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 7da:	fed518e3          	bne	a0,a3,7ca <memcmp+0x14>
  }
  return 0;
 7de:	4501                	li	a0,0
 7e0:	a019                	j	7e6 <memcmp+0x30>
      return *p1 - *p2;
 7e2:	40e7853b          	subw	a0,a5,a4
}
 7e6:	6422                	ld	s0,8(sp)
 7e8:	0141                	addi	sp,sp,16
 7ea:	8082                	ret
  return 0;
 7ec:	4501                	li	a0,0
 7ee:	bfe5                	j	7e6 <memcmp+0x30>

00000000000007f0 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 7f0:	1141                	addi	sp,sp,-16
 7f2:	e406                	sd	ra,8(sp)
 7f4:	e022                	sd	s0,0(sp)
 7f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7f8:	f67ff0ef          	jal	ra,75e <memmove>
}
 7fc:	60a2                	ld	ra,8(sp)
 7fe:	6402                	ld	s0,0(sp)
 800:	0141                	addi	sp,sp,16
 802:	8082                	ret

0000000000000804 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 804:	1141                	addi	sp,sp,-16
 806:	e406                	sd	ra,8(sp)
 808:	e022                	sd	s0,0(sp)
 80a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 80c:	4585                	li	a1,1
 80e:	0b2000ef          	jal	ra,8c0 <sys_sbrk>
}
 812:	60a2                	ld	ra,8(sp)
 814:	6402                	ld	s0,0(sp)
 816:	0141                	addi	sp,sp,16
 818:	8082                	ret

000000000000081a <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 81a:	1141                	addi	sp,sp,-16
 81c:	e406                	sd	ra,8(sp)
 81e:	e022                	sd	s0,0(sp)
 820:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 822:	4589                	li	a1,2
 824:	09c000ef          	jal	ra,8c0 <sys_sbrk>
}
 828:	60a2                	ld	ra,8(sp)
 82a:	6402                	ld	s0,0(sp)
 82c:	0141                	addi	sp,sp,16
 82e:	8082                	ret

0000000000000830 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 830:	4885                	li	a7,1
 ecall
 832:	00000073          	ecall
 ret
 836:	8082                	ret

0000000000000838 <exit>:
.global exit
exit:
 li a7, SYS_exit
 838:	4889                	li	a7,2
 ecall
 83a:	00000073          	ecall
 ret
 83e:	8082                	ret

0000000000000840 <wait>:
.global wait
wait:
 li a7, SYS_wait
 840:	488d                	li	a7,3
 ecall
 842:	00000073          	ecall
 ret
 846:	8082                	ret

0000000000000848 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 848:	4891                	li	a7,4
 ecall
 84a:	00000073          	ecall
 ret
 84e:	8082                	ret

0000000000000850 <read>:
.global read
read:
 li a7, SYS_read
 850:	4895                	li	a7,5
 ecall
 852:	00000073          	ecall
 ret
 856:	8082                	ret

0000000000000858 <write>:
.global write
write:
 li a7, SYS_write
 858:	48c1                	li	a7,16
 ecall
 85a:	00000073          	ecall
 ret
 85e:	8082                	ret

0000000000000860 <close>:
.global close
close:
 li a7, SYS_close
 860:	48d5                	li	a7,21
 ecall
 862:	00000073          	ecall
 ret
 866:	8082                	ret

0000000000000868 <kill>:
.global kill
kill:
 li a7, SYS_kill
 868:	4899                	li	a7,6
 ecall
 86a:	00000073          	ecall
 ret
 86e:	8082                	ret

0000000000000870 <exec>:
.global exec
exec:
 li a7, SYS_exec
 870:	489d                	li	a7,7
 ecall
 872:	00000073          	ecall
 ret
 876:	8082                	ret

0000000000000878 <open>:
.global open
open:
 li a7, SYS_open
 878:	48bd                	li	a7,15
 ecall
 87a:	00000073          	ecall
 ret
 87e:	8082                	ret

0000000000000880 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 880:	48c5                	li	a7,17
 ecall
 882:	00000073          	ecall
 ret
 886:	8082                	ret

0000000000000888 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 888:	48c9                	li	a7,18
 ecall
 88a:	00000073          	ecall
 ret
 88e:	8082                	ret

0000000000000890 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 890:	48a1                	li	a7,8
 ecall
 892:	00000073          	ecall
 ret
 896:	8082                	ret

0000000000000898 <link>:
.global link
link:
 li a7, SYS_link
 898:	48cd                	li	a7,19
 ecall
 89a:	00000073          	ecall
 ret
 89e:	8082                	ret

00000000000008a0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 8a0:	48d1                	li	a7,20
 ecall
 8a2:	00000073          	ecall
 ret
 8a6:	8082                	ret

00000000000008a8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 8a8:	48a5                	li	a7,9
 ecall
 8aa:	00000073          	ecall
 ret
 8ae:	8082                	ret

00000000000008b0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 8b0:	48a9                	li	a7,10
 ecall
 8b2:	00000073          	ecall
 ret
 8b6:	8082                	ret

00000000000008b8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 8b8:	48ad                	li	a7,11
 ecall
 8ba:	00000073          	ecall
 ret
 8be:	8082                	ret

00000000000008c0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 8c0:	48b1                	li	a7,12
 ecall
 8c2:	00000073          	ecall
 ret
 8c6:	8082                	ret

00000000000008c8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 8c8:	48b5                	li	a7,13
 ecall
 8ca:	00000073          	ecall
 ret
 8ce:	8082                	ret

00000000000008d0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 8d0:	48b9                	li	a7,14
 ecall
 8d2:	00000073          	ecall
 ret
 8d6:	8082                	ret

00000000000008d8 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 8d8:	48d9                	li	a7,22
 ecall
 8da:	00000073          	ecall
 ret
 8de:	8082                	ret

00000000000008e0 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 8e0:	48dd                	li	a7,23
 ecall
 8e2:	00000073          	ecall
 ret
 8e6:	8082                	ret

00000000000008e8 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 8e8:	48e1                	li	a7,24
 ecall
 8ea:	00000073          	ecall
 ret
 8ee:	8082                	ret

00000000000008f0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 8f0:	48e5                	li	a7,25
 ecall
 8f2:	00000073          	ecall
 ret
 8f6:	8082                	ret

00000000000008f8 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 8f8:	48e9                	li	a7,26
 ecall
 8fa:	00000073          	ecall
 ret
 8fe:	8082                	ret

0000000000000900 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 900:	48ed                	li	a7,27
 ecall
 902:	00000073          	ecall
 ret
 906:	8082                	ret

0000000000000908 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 908:	48f1                	li	a7,28
 ecall
 90a:	00000073          	ecall
 ret
 90e:	8082                	ret

0000000000000910 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 910:	48f5                	li	a7,29
 ecall
 912:	00000073          	ecall
 ret
 916:	8082                	ret

0000000000000918 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 918:	1101                	addi	sp,sp,-32
 91a:	ec06                	sd	ra,24(sp)
 91c:	e822                	sd	s0,16(sp)
 91e:	1000                	addi	s0,sp,32
 920:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 924:	4605                	li	a2,1
 926:	fef40593          	addi	a1,s0,-17
 92a:	f2fff0ef          	jal	ra,858 <write>
}
 92e:	60e2                	ld	ra,24(sp)
 930:	6442                	ld	s0,16(sp)
 932:	6105                	addi	sp,sp,32
 934:	8082                	ret

0000000000000936 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 936:	715d                	addi	sp,sp,-80
 938:	e486                	sd	ra,72(sp)
 93a:	e0a2                	sd	s0,64(sp)
 93c:	fc26                	sd	s1,56(sp)
 93e:	f84a                	sd	s2,48(sp)
 940:	f44e                	sd	s3,40(sp)
 942:	0880                	addi	s0,sp,80
 944:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 946:	c299                	beqz	a3,94c <printint+0x16>
 948:	0805c163          	bltz	a1,9ca <printint+0x94>
  neg = 0;
 94c:	4881                	li	a7,0
 94e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 952:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 954:	00000517          	auipc	a0,0x0
 958:	65c50513          	addi	a0,a0,1628 # fb0 <digits>
 95c:	883e                	mv	a6,a5
 95e:	2785                	addiw	a5,a5,1
 960:	02c5f733          	remu	a4,a1,a2
 964:	972a                	add	a4,a4,a0
 966:	00074703          	lbu	a4,0(a4)
 96a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 96e:	872e                	mv	a4,a1
 970:	02c5d5b3          	divu	a1,a1,a2
 974:	0685                	addi	a3,a3,1
 976:	fec773e3          	bgeu	a4,a2,95c <printint+0x26>
  if(neg)
 97a:	00088b63          	beqz	a7,990 <printint+0x5a>
    buf[i++] = '-';
 97e:	fd040713          	addi	a4,s0,-48
 982:	97ba                	add	a5,a5,a4
 984:	02d00713          	li	a4,45
 988:	fee78423          	sb	a4,-24(a5)
 98c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 990:	02f05663          	blez	a5,9bc <printint+0x86>
 994:	fb840713          	addi	a4,s0,-72
 998:	00f704b3          	add	s1,a4,a5
 99c:	fff70993          	addi	s3,a4,-1
 9a0:	99be                	add	s3,s3,a5
 9a2:	37fd                	addiw	a5,a5,-1
 9a4:	1782                	slli	a5,a5,0x20
 9a6:	9381                	srli	a5,a5,0x20
 9a8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 9ac:	fff4c583          	lbu	a1,-1(s1)
 9b0:	854a                	mv	a0,s2
 9b2:	f67ff0ef          	jal	ra,918 <putc>
  while(--i >= 0)
 9b6:	14fd                	addi	s1,s1,-1
 9b8:	ff349ae3          	bne	s1,s3,9ac <printint+0x76>
}
 9bc:	60a6                	ld	ra,72(sp)
 9be:	6406                	ld	s0,64(sp)
 9c0:	74e2                	ld	s1,56(sp)
 9c2:	7942                	ld	s2,48(sp)
 9c4:	79a2                	ld	s3,40(sp)
 9c6:	6161                	addi	sp,sp,80
 9c8:	8082                	ret
    x = -xx;
 9ca:	40b005b3          	neg	a1,a1
    neg = 1;
 9ce:	4885                	li	a7,1
    x = -xx;
 9d0:	bfbd                	j	94e <printint+0x18>

00000000000009d2 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 9d2:	7119                	addi	sp,sp,-128
 9d4:	fc86                	sd	ra,120(sp)
 9d6:	f8a2                	sd	s0,112(sp)
 9d8:	f4a6                	sd	s1,104(sp)
 9da:	f0ca                	sd	s2,96(sp)
 9dc:	ecce                	sd	s3,88(sp)
 9de:	e8d2                	sd	s4,80(sp)
 9e0:	e4d6                	sd	s5,72(sp)
 9e2:	e0da                	sd	s6,64(sp)
 9e4:	fc5e                	sd	s7,56(sp)
 9e6:	f862                	sd	s8,48(sp)
 9e8:	f466                	sd	s9,40(sp)
 9ea:	f06a                	sd	s10,32(sp)
 9ec:	ec6e                	sd	s11,24(sp)
 9ee:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 9f0:	0005c903          	lbu	s2,0(a1)
 9f4:	24090c63          	beqz	s2,c4c <vprintf+0x27a>
 9f8:	8b2a                	mv	s6,a0
 9fa:	8a2e                	mv	s4,a1
 9fc:	8bb2                	mv	s7,a2
  state = 0;
 9fe:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 a00:	4481                	li	s1,0
 a02:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 a04:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 a08:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 a0c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 a10:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a14:	00000c97          	auipc	s9,0x0
 a18:	59cc8c93          	addi	s9,s9,1436 # fb0 <digits>
 a1c:	a005                	j	a3c <vprintf+0x6a>
        putc(fd, c0);
 a1e:	85ca                	mv	a1,s2
 a20:	855a                	mv	a0,s6
 a22:	ef7ff0ef          	jal	ra,918 <putc>
 a26:	a019                	j	a2c <vprintf+0x5a>
    } else if(state == '%'){
 a28:	03598263          	beq	s3,s5,a4c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 a2c:	2485                	addiw	s1,s1,1
 a2e:	8726                	mv	a4,s1
 a30:	009a07b3          	add	a5,s4,s1
 a34:	0007c903          	lbu	s2,0(a5)
 a38:	20090a63          	beqz	s2,c4c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 a3c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 a40:	fe0994e3          	bnez	s3,a28 <vprintf+0x56>
      if(c0 == '%'){
 a44:	fd579de3          	bne	a5,s5,a1e <vprintf+0x4c>
        state = '%';
 a48:	89be                	mv	s3,a5
 a4a:	b7cd                	j	a2c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 a4c:	c3c1                	beqz	a5,acc <vprintf+0xfa>
 a4e:	00ea06b3          	add	a3,s4,a4
 a52:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 a56:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 a58:	c681                	beqz	a3,a60 <vprintf+0x8e>
 a5a:	9752                	add	a4,a4,s4
 a5c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 a60:	03878e63          	beq	a5,s8,a9c <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 a64:	05a78863          	beq	a5,s10,ab4 <vprintf+0xe2>
      } else if(c0 == 'u'){
 a68:	0db78b63          	beq	a5,s11,b3e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 a6c:	07800713          	li	a4,120
 a70:	10e78d63          	beq	a5,a4,b8a <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 a74:	07000713          	li	a4,112
 a78:	14e78263          	beq	a5,a4,bbc <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 a7c:	06300713          	li	a4,99
 a80:	16e78f63          	beq	a5,a4,bfe <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 a84:	07300713          	li	a4,115
 a88:	18e78563          	beq	a5,a4,c12 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 a8c:	05579063          	bne	a5,s5,acc <vprintf+0xfa>
        putc(fd, '%');
 a90:	85d6                	mv	a1,s5
 a92:	855a                	mv	a0,s6
 a94:	e85ff0ef          	jal	ra,918 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 a98:	4981                	li	s3,0
 a9a:	bf49                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 a9c:	008b8913          	addi	s2,s7,8 # ffffffff80000008 <base+0xffffffff7fffbf58>
 aa0:	4685                	li	a3,1
 aa2:	4629                	li	a2,10
 aa4:	000ba583          	lw	a1,0(s7)
 aa8:	855a                	mv	a0,s6
 aaa:	e8dff0ef          	jal	ra,936 <printint>
 aae:	8bca                	mv	s7,s2
      state = 0;
 ab0:	4981                	li	s3,0
 ab2:	bfad                	j	a2c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 ab4:	03868663          	beq	a3,s8,ae0 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 ab8:	05a68163          	beq	a3,s10,afa <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 abc:	09b68d63          	beq	a3,s11,b56 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 ac0:	03a68f63          	beq	a3,s10,afe <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 ac4:	07800793          	li	a5,120
 ac8:	0cf68d63          	beq	a3,a5,ba2 <vprintf+0x1d0>
        putc(fd, '%');
 acc:	85d6                	mv	a1,s5
 ace:	855a                	mv	a0,s6
 ad0:	e49ff0ef          	jal	ra,918 <putc>
        putc(fd, c0);
 ad4:	85ca                	mv	a1,s2
 ad6:	855a                	mv	a0,s6
 ad8:	e41ff0ef          	jal	ra,918 <putc>
      state = 0;
 adc:	4981                	li	s3,0
 ade:	b7b9                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 ae0:	008b8913          	addi	s2,s7,8
 ae4:	4685                	li	a3,1
 ae6:	4629                	li	a2,10
 ae8:	000bb583          	ld	a1,0(s7)
 aec:	855a                	mv	a0,s6
 aee:	e49ff0ef          	jal	ra,936 <printint>
        i += 1;
 af2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 af4:	8bca                	mv	s7,s2
      state = 0;
 af6:	4981                	li	s3,0
        i += 1;
 af8:	bf15                	j	a2c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 afa:	03860563          	beq	a2,s8,b24 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 afe:	07b60963          	beq	a2,s11,b70 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 b02:	07800793          	li	a5,120
 b06:	fcf613e3          	bne	a2,a5,acc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 b0a:	008b8913          	addi	s2,s7,8
 b0e:	4681                	li	a3,0
 b10:	4641                	li	a2,16
 b12:	000bb583          	ld	a1,0(s7)
 b16:	855a                	mv	a0,s6
 b18:	e1fff0ef          	jal	ra,936 <printint>
        i += 2;
 b1c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 b1e:	8bca                	mv	s7,s2
      state = 0;
 b20:	4981                	li	s3,0
        i += 2;
 b22:	b729                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 b24:	008b8913          	addi	s2,s7,8
 b28:	4685                	li	a3,1
 b2a:	4629                	li	a2,10
 b2c:	000bb583          	ld	a1,0(s7)
 b30:	855a                	mv	a0,s6
 b32:	e05ff0ef          	jal	ra,936 <printint>
        i += 2;
 b36:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 b38:	8bca                	mv	s7,s2
      state = 0;
 b3a:	4981                	li	s3,0
        i += 2;
 b3c:	bdc5                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 b3e:	008b8913          	addi	s2,s7,8
 b42:	4681                	li	a3,0
 b44:	4629                	li	a2,10
 b46:	000be583          	lwu	a1,0(s7)
 b4a:	855a                	mv	a0,s6
 b4c:	debff0ef          	jal	ra,936 <printint>
 b50:	8bca                	mv	s7,s2
      state = 0;
 b52:	4981                	li	s3,0
 b54:	bde1                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b56:	008b8913          	addi	s2,s7,8
 b5a:	4681                	li	a3,0
 b5c:	4629                	li	a2,10
 b5e:	000bb583          	ld	a1,0(s7)
 b62:	855a                	mv	a0,s6
 b64:	dd3ff0ef          	jal	ra,936 <printint>
        i += 1;
 b68:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 b6a:	8bca                	mv	s7,s2
      state = 0;
 b6c:	4981                	li	s3,0
        i += 1;
 b6e:	bd7d                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b70:	008b8913          	addi	s2,s7,8
 b74:	4681                	li	a3,0
 b76:	4629                	li	a2,10
 b78:	000bb583          	ld	a1,0(s7)
 b7c:	855a                	mv	a0,s6
 b7e:	db9ff0ef          	jal	ra,936 <printint>
        i += 2;
 b82:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 b84:	8bca                	mv	s7,s2
      state = 0;
 b86:	4981                	li	s3,0
        i += 2;
 b88:	b555                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 b8a:	008b8913          	addi	s2,s7,8
 b8e:	4681                	li	a3,0
 b90:	4641                	li	a2,16
 b92:	000be583          	lwu	a1,0(s7)
 b96:	855a                	mv	a0,s6
 b98:	d9fff0ef          	jal	ra,936 <printint>
 b9c:	8bca                	mv	s7,s2
      state = 0;
 b9e:	4981                	li	s3,0
 ba0:	b571                	j	a2c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 ba2:	008b8913          	addi	s2,s7,8
 ba6:	4681                	li	a3,0
 ba8:	4641                	li	a2,16
 baa:	000bb583          	ld	a1,0(s7)
 bae:	855a                	mv	a0,s6
 bb0:	d87ff0ef          	jal	ra,936 <printint>
        i += 1;
 bb4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 bb6:	8bca                	mv	s7,s2
      state = 0;
 bb8:	4981                	li	s3,0
        i += 1;
 bba:	bd8d                	j	a2c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 bbc:	008b8793          	addi	a5,s7,8
 bc0:	f8f43423          	sd	a5,-120(s0)
 bc4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 bc8:	03000593          	li	a1,48
 bcc:	855a                	mv	a0,s6
 bce:	d4bff0ef          	jal	ra,918 <putc>
  putc(fd, 'x');
 bd2:	07800593          	li	a1,120
 bd6:	855a                	mv	a0,s6
 bd8:	d41ff0ef          	jal	ra,918 <putc>
 bdc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bde:	03c9d793          	srli	a5,s3,0x3c
 be2:	97e6                	add	a5,a5,s9
 be4:	0007c583          	lbu	a1,0(a5)
 be8:	855a                	mv	a0,s6
 bea:	d2fff0ef          	jal	ra,918 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bee:	0992                	slli	s3,s3,0x4
 bf0:	397d                	addiw	s2,s2,-1
 bf2:	fe0916e3          	bnez	s2,bde <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 bf6:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 bfa:	4981                	li	s3,0
 bfc:	bd05                	j	a2c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 bfe:	008b8913          	addi	s2,s7,8
 c02:	000bc583          	lbu	a1,0(s7)
 c06:	855a                	mv	a0,s6
 c08:	d11ff0ef          	jal	ra,918 <putc>
 c0c:	8bca                	mv	s7,s2
      state = 0;
 c0e:	4981                	li	s3,0
 c10:	bd31                	j	a2c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 c12:	008b8993          	addi	s3,s7,8
 c16:	000bb903          	ld	s2,0(s7)
 c1a:	00090f63          	beqz	s2,c38 <vprintf+0x266>
        for(; *s; s++)
 c1e:	00094583          	lbu	a1,0(s2)
 c22:	c195                	beqz	a1,c46 <vprintf+0x274>
          putc(fd, *s);
 c24:	855a                	mv	a0,s6
 c26:	cf3ff0ef          	jal	ra,918 <putc>
        for(; *s; s++)
 c2a:	0905                	addi	s2,s2,1
 c2c:	00094583          	lbu	a1,0(s2)
 c30:	f9f5                	bnez	a1,c24 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 c32:	8bce                	mv	s7,s3
      state = 0;
 c34:	4981                	li	s3,0
 c36:	bbdd                	j	a2c <vprintf+0x5a>
          s = "(null)";
 c38:	00000917          	auipc	s2,0x0
 c3c:	37090913          	addi	s2,s2,880 # fa8 <malloc+0x25a>
        for(; *s; s++)
 c40:	02800593          	li	a1,40
 c44:	b7c5                	j	c24 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 c46:	8bce                	mv	s7,s3
      state = 0;
 c48:	4981                	li	s3,0
 c4a:	b3cd                	j	a2c <vprintf+0x5a>
    }
  }
}
 c4c:	70e6                	ld	ra,120(sp)
 c4e:	7446                	ld	s0,112(sp)
 c50:	74a6                	ld	s1,104(sp)
 c52:	7906                	ld	s2,96(sp)
 c54:	69e6                	ld	s3,88(sp)
 c56:	6a46                	ld	s4,80(sp)
 c58:	6aa6                	ld	s5,72(sp)
 c5a:	6b06                	ld	s6,64(sp)
 c5c:	7be2                	ld	s7,56(sp)
 c5e:	7c42                	ld	s8,48(sp)
 c60:	7ca2                	ld	s9,40(sp)
 c62:	7d02                	ld	s10,32(sp)
 c64:	6de2                	ld	s11,24(sp)
 c66:	6109                	addi	sp,sp,128
 c68:	8082                	ret

0000000000000c6a <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 c6a:	715d                	addi	sp,sp,-80
 c6c:	ec06                	sd	ra,24(sp)
 c6e:	e822                	sd	s0,16(sp)
 c70:	1000                	addi	s0,sp,32
 c72:	e010                	sd	a2,0(s0)
 c74:	e414                	sd	a3,8(s0)
 c76:	e818                	sd	a4,16(s0)
 c78:	ec1c                	sd	a5,24(s0)
 c7a:	03043023          	sd	a6,32(s0)
 c7e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c82:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c86:	8622                	mv	a2,s0
 c88:	d4bff0ef          	jal	ra,9d2 <vprintf>
}
 c8c:	60e2                	ld	ra,24(sp)
 c8e:	6442                	ld	s0,16(sp)
 c90:	6161                	addi	sp,sp,80
 c92:	8082                	ret

0000000000000c94 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 c94:	711d                	addi	sp,sp,-96
 c96:	ec06                	sd	ra,24(sp)
 c98:	e822                	sd	s0,16(sp)
 c9a:	1000                	addi	s0,sp,32
 c9c:	e40c                	sd	a1,8(s0)
 c9e:	e810                	sd	a2,16(s0)
 ca0:	ec14                	sd	a3,24(s0)
 ca2:	f018                	sd	a4,32(s0)
 ca4:	f41c                	sd	a5,40(s0)
 ca6:	03043823          	sd	a6,48(s0)
 caa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cae:	00840613          	addi	a2,s0,8
 cb2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cb6:	85aa                	mv	a1,a0
 cb8:	4505                	li	a0,1
 cba:	d19ff0ef          	jal	ra,9d2 <vprintf>
}
 cbe:	60e2                	ld	ra,24(sp)
 cc0:	6442                	ld	s0,16(sp)
 cc2:	6125                	addi	sp,sp,96
 cc4:	8082                	ret

0000000000000cc6 <free>:
 *   无
 */

void
free(void *ap)
{
 cc6:	1141                	addi	sp,sp,-16
 cc8:	e422                	sd	s0,8(sp)
 cca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 ccc:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cd0:	00000797          	auipc	a5,0x0
 cd4:	3407b783          	ld	a5,832(a5) # 1010 <freep>
 cd8:	a805                	j	d08 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cda:	4618                	lw	a4,8(a2)
 cdc:	9db9                	addw	a1,a1,a4
 cde:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ce2:	6398                	ld	a4,0(a5)
 ce4:	6318                	ld	a4,0(a4)
 ce6:	fee53823          	sd	a4,-16(a0)
 cea:	a091                	j	d2e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 cec:	ff852703          	lw	a4,-8(a0)
 cf0:	9e39                	addw	a2,a2,a4
 cf2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 cf4:	ff053703          	ld	a4,-16(a0)
 cf8:	e398                	sd	a4,0(a5)
 cfa:	a099                	j	d40 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cfc:	6398                	ld	a4,0(a5)
 cfe:	00e7e463          	bltu	a5,a4,d06 <free+0x40>
 d02:	00e6ea63          	bltu	a3,a4,d16 <free+0x50>
{
 d06:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d08:	fed7fae3          	bgeu	a5,a3,cfc <free+0x36>
 d0c:	6398                	ld	a4,0(a5)
 d0e:	00e6e463          	bltu	a3,a4,d16 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d12:	fee7eae3          	bltu	a5,a4,d06 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 d16:	ff852583          	lw	a1,-8(a0)
 d1a:	6390                	ld	a2,0(a5)
 d1c:	02059713          	slli	a4,a1,0x20
 d20:	9301                	srli	a4,a4,0x20
 d22:	0712                	slli	a4,a4,0x4
 d24:	9736                	add	a4,a4,a3
 d26:	fae60ae3          	beq	a2,a4,cda <free+0x14>
    bp->s.ptr = p->s.ptr;
 d2a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d2e:	4790                	lw	a2,8(a5)
 d30:	02061713          	slli	a4,a2,0x20
 d34:	9301                	srli	a4,a4,0x20
 d36:	0712                	slli	a4,a4,0x4
 d38:	973e                	add	a4,a4,a5
 d3a:	fae689e3          	beq	a3,a4,cec <free+0x26>
  } else
    p->s.ptr = bp;
 d3e:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 d40:	00000717          	auipc	a4,0x0
 d44:	2cf73823          	sd	a5,720(a4) # 1010 <freep>
}
 d48:	6422                	ld	s0,8(sp)
 d4a:	0141                	addi	sp,sp,16
 d4c:	8082                	ret

0000000000000d4e <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 d4e:	7139                	addi	sp,sp,-64
 d50:	fc06                	sd	ra,56(sp)
 d52:	f822                	sd	s0,48(sp)
 d54:	f426                	sd	s1,40(sp)
 d56:	f04a                	sd	s2,32(sp)
 d58:	ec4e                	sd	s3,24(sp)
 d5a:	e852                	sd	s4,16(sp)
 d5c:	e456                	sd	s5,8(sp)
 d5e:	e05a                	sd	s6,0(sp)
 d60:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d62:	02051493          	slli	s1,a0,0x20
 d66:	9081                	srli	s1,s1,0x20
 d68:	04bd                	addi	s1,s1,15
 d6a:	8091                	srli	s1,s1,0x4
 d6c:	0014899b          	addiw	s3,s1,1
 d70:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 d72:	00000517          	auipc	a0,0x0
 d76:	29e53503          	ld	a0,670(a0) # 1010 <freep>
 d7a:	c515                	beqz	a0,da6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d7c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 d7e:	4798                	lw	a4,8(a5)
 d80:	02977f63          	bgeu	a4,s1,dbe <malloc+0x70>
 d84:	8a4e                	mv	s4,s3
 d86:	0009871b          	sext.w	a4,s3
 d8a:	6685                	lui	a3,0x1
 d8c:	00d77363          	bgeu	a4,a3,d92 <malloc+0x44>
 d90:	6a05                	lui	s4,0x1
 d92:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 d96:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 d9a:	00000917          	auipc	s2,0x0
 d9e:	27690913          	addi	s2,s2,630 # 1010 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 da2:	5afd                	li	s5,-1
 da4:	a0bd                	j	e12 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 da6:	00003797          	auipc	a5,0x3
 daa:	30a78793          	addi	a5,a5,778 # 40b0 <base>
 dae:	00000717          	auipc	a4,0x0
 db2:	26f73123          	sd	a5,610(a4) # 1010 <freep>
 db6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 db8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 dbc:	b7e1                	j	d84 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 dbe:	02e48b63          	beq	s1,a4,df4 <malloc+0xa6>
        p->s.size -= nunits;
 dc2:	4137073b          	subw	a4,a4,s3
 dc6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 dc8:	1702                	slli	a4,a4,0x20
 dca:	9301                	srli	a4,a4,0x20
 dcc:	0712                	slli	a4,a4,0x4
 dce:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 dd0:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 dd4:	00000717          	auipc	a4,0x0
 dd8:	22a73e23          	sd	a0,572(a4) # 1010 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 ddc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 de0:	70e2                	ld	ra,56(sp)
 de2:	7442                	ld	s0,48(sp)
 de4:	74a2                	ld	s1,40(sp)
 de6:	7902                	ld	s2,32(sp)
 de8:	69e2                	ld	s3,24(sp)
 dea:	6a42                	ld	s4,16(sp)
 dec:	6aa2                	ld	s5,8(sp)
 dee:	6b02                	ld	s6,0(sp)
 df0:	6121                	addi	sp,sp,64
 df2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 df4:	6398                	ld	a4,0(a5)
 df6:	e118                	sd	a4,0(a0)
 df8:	bff1                	j	dd4 <malloc+0x86>
  hp->s.size = nu;
 dfa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 dfe:	0541                	addi	a0,a0,16
 e00:	ec7ff0ef          	jal	ra,cc6 <free>
  return freep;
 e04:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e08:	dd61                	beqz	a0,de0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 e0c:	4798                	lw	a4,8(a5)
 e0e:	fa9778e3          	bgeu	a4,s1,dbe <malloc+0x70>
    if(p == freep)
 e12:	00093703          	ld	a4,0(s2)
 e16:	853e                	mv	a0,a5
 e18:	fef719e3          	bne	a4,a5,e0a <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 e1c:	8552                	mv	a0,s4
 e1e:	9e7ff0ef          	jal	ra,804 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 e22:	fd551ce3          	bne	a0,s5,dfa <malloc+0xac>
        return 0;  /* 内存分配失败 */
 e26:	4501                	li	a0,0
 e28:	bf65                	j	de0 <malloc+0x92>
