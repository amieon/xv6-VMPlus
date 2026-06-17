
user/_cow_bench:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
         ok ? "PASS (no leak)" : "FAIL (leak!)");
}

int
main(void)
{
   0:	7115                	addi	sp,sp,-224
   2:	ed86                	sd	ra,216(sp)
   4:	e9a2                	sd	s0,208(sp)
   6:	e5a6                	sd	s1,200(sp)
   8:	e1ca                	sd	s2,192(sp)
   a:	fd4e                	sd	s3,184(sp)
   c:	f952                	sd	s4,176(sp)
   e:	f556                	sd	s5,168(sp)
  10:	f15a                	sd	s6,160(sp)
  12:	ed5e                	sd	s7,152(sp)
  14:	e962                	sd	s8,144(sp)
  16:	e566                	sd	s9,136(sp)
  18:	e16a                	sd	s10,128(sp)
  1a:	fcee                	sd	s11,120(sp)
  1c:	1180                	addi	s0,sp,224
  printf("=== Rigorous COW fork benchmark (TRIALS=%d) ===\n", TRIALS);
  1e:	45a9                	li	a1,10
  20:	00001517          	auipc	a0,0x1
  24:	e0850513          	addi	a0,a0,-504 # e28 <malloc+0x150>
  28:	3f7000ef          	jal	ra,c1e <printf>
  int Ns[] = {64, 128, 256, 512};
  2c:	04000793          	li	a5,64
  30:	f6f42c23          	sw	a5,-136(s0)
  34:	08000793          	li	a5,128
  38:	f6f42e23          	sw	a5,-132(s0)
  3c:	10000793          	li	a5,256
  40:	f8f42023          	sw	a5,-128(s0)
  44:	20000793          	li	a5,512
  48:	f8f42223          	sw	a5,-124(s0)
  printf("\n[Experiment B] fork-time page disposition vs resident set (TRIALS=%d)\n", TRIALS);
  4c:	45a9                	li	a1,10
  4e:	00001517          	auipc	a0,0x1
  52:	e1250513          	addi	a0,a0,-494 # e60 <malloc+0x188>
  56:	3c9000ef          	jal	ra,c1e <printf>
  printf("  expect COW: copied=0, shared grows with N ; EAGER: copied grows, shared=0\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	e4e50513          	addi	a0,a0,-434 # ea8 <malloc+0x1d0>
  62:	3bd000ef          	jal	ra,c1e <printf>
  for(int a = 0; a < 4; a++){
  66:	f7840793          	addi	a5,s0,-136
  6a:	f4f43c23          	sd	a5,-168(s0)
  uint64 cur = 0;  // pages grown so far
  6e:	f4043423          	sd	zero,-184(s0)
  72:	6d05                	lui	s10,0x1
    for(int i = 0; i < need; i++) seg[i*PG] = 1;   // touch only the NEW pages
  74:	4d85                	li	s11,1
    uint64 cpmn = (uint64)-1, cpmx = 0, shmn = (uint64)-1, shmx = 0;
  76:	4c81                	li	s9,0
static uint64 rd_copy(void)  { vmstats(&S); return S.fork_copy_pages; }
  78:	00002497          	auipc	s1,0x2
  7c:	fa848493          	addi	s1,s1,-88 # 2020 <S>
  80:	aa8d                	j	1f2 <main+0x1f2>
    if(seg == (char*)-1){ printf("  sbrk failed\n"); g_pass = 0; return; }
  82:	00001517          	auipc	a0,0x1
  86:	e7650513          	addi	a0,a0,-394 # ef8 <malloc+0x220>
  8a:	395000ef          	jal	ra,c1e <printf>
  8e:	00002797          	auipc	a5,0x2
  92:	f607a923          	sw	zero,-142(a5) # 2000 <g_pass>
  int Ns[] = {128, 256, 512};
  96:	08000793          	li	a5,128
  9a:	f6f42423          	sw	a5,-152(s0)
  9e:	10000793          	li	a5,256
  a2:	f6f42623          	sw	a5,-148(s0)
  a6:	20000793          	li	a5,512
  aa:	f6f42823          	sw	a5,-144(s0)
  int fr[] = {0, 25, 50, 75, 100};
  ae:	f6042c23          	sw	zero,-136(s0)
  b2:	47e5                	li	a5,25
  b4:	f6f42e23          	sw	a5,-132(s0)
  b8:	03200793          	li	a5,50
  bc:	f8f42023          	sw	a5,-128(s0)
  c0:	04b00793          	li	a5,75
  c4:	f8f42223          	sw	a5,-124(s0)
  c8:	06400793          	li	a5,100
  cc:	f8f42423          	sw	a5,-120(s0)
  printf("\n[Experiment A] run-time COW copy cost vs write footprint (TRIALS=%d)\n", TRIALS);
  d0:	45a9                	li	a1,10
  d2:	00001517          	auipc	a0,0x1
  d6:	e6650513          	addi	a0,a0,-410 # f38 <malloc+0x260>
  da:	345000ef          	jal	ra,c1e <printf>
  printf("  expect copied == written pages (slope=1) ; isolation must PASS\n");
  de:	00001517          	auipc	a0,0x1
  e2:	ea250513          	addi	a0,a0,-350 # f80 <malloc+0x2a8>
  e6:	339000ef          	jal	ra,c1e <printf>
  for(int a = 0; a < 3; a++){
  ea:	f6840793          	addi	a5,s0,-152
  ee:	f4f43023          	sd	a5,-192(s0)
  f2:	6905                	lui	s2,0x1
static uint64 rd_cow(void)   { vmstats(&S); return S.cow_faults; }
  f4:	00002a17          	auipc	s4,0x2
  f8:	f2ca0a13          	addi	s4,s4,-212 # 2020 <S>
    int N = Ns[a];
  fc:	f4043783          	ld	a5,-192(s0)
 100:	0007ab83          	lw	s7,0(a5)
        char *p = malloc(N * PG);
 104:	00cb979b          	slliw	a5,s7,0xc
 108:	f4f43823          	sd	a5,-176(s0)
 10c:	f7840793          	addi	a5,s0,-136
 110:	f4f43423          	sd	a5,-184(s0)
 114:	fffb879b          	addiw	a5,s7,-1
 118:	0007871b          	sext.w	a4,a5
 11c:	f2e43423          	sd	a4,-216(s0)
 120:	02079a93          	slli	s5,a5,0x20
 124:	020ada93          	srli	s5,s5,0x20
 128:	0ab2                	slli	s5,s5,0xc
 12a:	9aca                	add	s5,s5,s2
      int w = N * fr[b] / 100;
 12c:	f4843783          	ld	a5,-184(s0)
 130:	439c                	lw	a5,0(a5)
 132:	f2f43c23          	sd	a5,-200(s0)
 136:	02fb8b3b          	mulw	s6,s7,a5
 13a:	000b079b          	sext.w	a5,s6
 13e:	f2f43823          	sd	a5,-208(s0)
 142:	06400793          	li	a5,100
 146:	02fb4b3b          	divw	s6,s6,a5
 14a:	4c29                	li	s8,10
      int iso_ok = 1;
 14c:	4c85                	li	s9,1
      uint64 mn = (uint64)-1, mx = 0;
 14e:	f4043c23          	sd	zero,-168(s0)
 152:	5d7d                	li	s10,-1
        for(int i = 0; i < N; i++) p[i*PG] = PAT_A;   // parent baseline
 154:	44c5                	li	s1,17
 156:	a279                	j	2e4 <main+0x2e4>
      if(fork() == 0) exit(0);
 158:	66a000ef          	jal	ra,7c2 <exit>
    for(int t = 0; t < TRIALS; t++){
 15c:	39fd                	addiw	s3,s3,-1
 15e:	04098b63          	beqz	s3,1b4 <main+0x1b4>
static uint64 rd_copy(void)  { vmstats(&S); return S.fork_copy_pages; }
 162:	8526                	mv	a0,s1
 164:	736000ef          	jal	ra,89a <vmstats>
 168:	0304b903          	ld	s2,48(s1)
static uint64 rd_share(void) { vmstats(&S); return S.fork_share_pages; }
 16c:	8526                	mv	a0,s1
 16e:	72c000ef          	jal	ra,89a <vmstats>
 172:	0384ba03          	ld	s4,56(s1)
      if(fork() == 0) exit(0);
 176:	644000ef          	jal	ra,7ba <fork>
 17a:	dd79                	beqz	a0,158 <main+0x158>
      wait(0);
 17c:	8566                	mv	a0,s9
 17e:	64c000ef          	jal	ra,7ca <wait>
static uint64 rd_copy(void)  { vmstats(&S); return S.fork_copy_pages; }
 182:	8526                	mv	a0,s1
 184:	716000ef          	jal	ra,89a <vmstats>
      uint64 dc = rd_copy() - cp0, ds = rd_share() - sh0;
 188:	789c                	ld	a5,48(s1)
 18a:	41278933          	sub	s2,a5,s2
static uint64 rd_share(void) { vmstats(&S); return S.fork_share_pages; }
 18e:	8526                	mv	a0,s1
 190:	70a000ef          	jal	ra,89a <vmstats>
      uint64 dc = rd_copy() - cp0, ds = rd_share() - sh0;
 194:	7c9c                	ld	a5,56(s1)
 196:	41478a33          	sub	s4,a5,s4
      if(dc < cpmn) cpmn = dc;  
 19a:	01897363          	bgeu	s2,s8,1a0 <main+0x1a0>
 19e:	8c4a                	mv	s8,s2
      if(dc > cpmx) cpmx = dc;
 1a0:	012bf363          	bgeu	s7,s2,1a6 <main+0x1a6>
 1a4:	8bca                	mv	s7,s2
      if(ds < shmn) shmn = ds;  
 1a6:	016a7363          	bgeu	s4,s6,1ac <main+0x1ac>
 1aa:	8b52                	mv	s6,s4
      if(ds > shmx) shmx = ds;
 1ac:	fb4af8e3          	bgeu	s5,s4,15c <main+0x15c>
 1b0:	8ad2                	mv	s5,s4
 1b2:	b76d                	j	15c <main+0x15c>
    printf("  N=%d  copied=%d..%d  shared=%d..%d  det=%s\n",
 1b4:	000c061b          	sext.w	a2,s8
 1b8:	000b869b          	sext.w	a3,s7
 1bc:	000b071b          	sext.w	a4,s6
 1c0:	000a879b          	sext.w	a5,s5
 1c4:	00001817          	auipc	a6,0x1
 1c8:	bfc80813          	addi	a6,a6,-1028 # dc0 <malloc+0xe8>
 1cc:	077c0f63          	beq	s8,s7,24a <main+0x24a>
 1d0:	f5043583          	ld	a1,-176(s0)
 1d4:	00001517          	auipc	a0,0x1
 1d8:	d3450513          	addi	a0,a0,-716 # f08 <malloc+0x230>
 1dc:	243000ef          	jal	ra,c1e <printf>
  for(int a = 0; a < 4; a++){
 1e0:	f5843783          	ld	a5,-168(s0)
 1e4:	0791                	addi	a5,a5,4
 1e6:	f4f43c23          	sd	a5,-168(s0)
 1ea:	f8840713          	addi	a4,s0,-120
 1ee:	eae784e3          	beq	a5,a4,96 <main+0x96>
    int N = Ns[a];
 1f2:	f5843783          	ld	a5,-168(s0)
 1f6:	439c                	lw	a5,0(a5)
 1f8:	f4f43823          	sd	a5,-176(s0)
    int need = N - (int)cur;
 1fc:	f4843703          	ld	a4,-184(s0)
 200:	40e7893b          	subw	s2,a5,a4
 204:	0009099b          	sext.w	s3,s2
    char *seg = sbrk(need * PG);
 208:	00c9151b          	slliw	a0,s2,0xc
 20c:	582000ef          	jal	ra,78e <sbrk>
    if(seg == (char*)-1){ printf("  sbrk failed\n"); g_pass = 0; return; }
 210:	57fd                	li	a5,-1
 212:	e6f508e3          	beq	a0,a5,82 <main+0x82>
    for(int i = 0; i < need; i++) seg[i*PG] = 1;   // touch only the NEW pages
 216:	03305063          	blez	s3,236 <main+0x236>
 21a:	87aa                	mv	a5,a0
 21c:	fff9071b          	addiw	a4,s2,-1
 220:	1702                	slli	a4,a4,0x20
 222:	9301                	srli	a4,a4,0x20
 224:	0732                	slli	a4,a4,0xc
 226:	01a506b3          	add	a3,a0,s10
 22a:	9736                	add	a4,a4,a3
 22c:	01b78023          	sb	s11,0(a5)
 230:	97ea                	add	a5,a5,s10
 232:	fee79de3          	bne	a5,a4,22c <main+0x22c>
    cur = N;
 236:	f5043783          	ld	a5,-176(s0)
 23a:	f4f43423          	sd	a5,-184(s0)
 23e:	49a9                	li	s3,10
    uint64 cpmn = (uint64)-1, cpmx = 0, shmn = (uint64)-1, shmx = 0;
 240:	8ae6                	mv	s5,s9
 242:	5b7d                	li	s6,-1
 244:	8be6                	mv	s7,s9
 246:	5c7d                	li	s8,-1
 248:	bf29                	j	162 <main+0x162>
           (cpmn==cpmx && shmn==shmx) ? "yes" : "no");
 24a:	f95b13e3          	bne	s6,s5,1d0 <main+0x1d0>
    printf("  N=%d  copied=%d..%d  shared=%d..%d  det=%s\n",
 24e:	00001817          	auipc	a6,0x1
 252:	b7a80813          	addi	a6,a6,-1158 # dc8 <malloc+0xf0>
 256:	bfad                	j	1d0 <main+0x1d0>
          for(int i = 0; i < w; i++) p[i*PG] = PAT_B; // child writes -> cowbreak
 258:	06300793          	li	a5,99
 25c:	f3043703          	ld	a4,-208(s0)
 260:	02e7d963          	bge	a5,a4,292 <main+0x292>
 264:	87ce                	mv	a5,s3
 266:	86ce                	mv	a3,s3
 268:	872a                	mv	a4,a0
 26a:	07700593          	li	a1,119
 26e:	6605                	lui	a2,0x1
 270:	00b68023          	sb	a1,0(a3)
 274:	2705                	addiw	a4,a4,1
 276:	96b2                	add	a3,a3,a2
 278:	ff674ce3          	blt	a4,s6,270 <main+0x270>
          for(int i = 0; i < w; i++) if(p[i*PG] != PAT_B) exit(2); // own writes
 27c:	07700613          	li	a2,119
 280:	6685                	lui	a3,0x1
 282:	0007c703          	lbu	a4,0(a5)
 286:	04c71263          	bne	a4,a2,2ca <main+0x2ca>
 28a:	2505                	addiw	a0,a0,1
 28c:	97b6                	add	a5,a5,a3
 28e:	ff654ae3          	blt	a0,s6,282 <main+0x282>
          for(int i = w; i < N; i++) if(p[i*PG] != PAT_A) exit(3); // shared reads
 292:	037b5963          	bge	s6,s7,2c4 <main+0x2c4>
 296:	00cb179b          	slliw	a5,s6,0xc
 29a:	97ce                	add	a5,a5,s3
 29c:	f2843703          	ld	a4,-216(s0)
 2a0:	416706bb          	subw	a3,a4,s6
 2a4:	1682                	slli	a3,a3,0x20
 2a6:	9281                	srli	a3,a3,0x20
 2a8:	96da                	add	a3,a3,s6
 2aa:	06b2                	slli	a3,a3,0xc
 2ac:	6705                	lui	a4,0x1
 2ae:	99ba                	add	s3,s3,a4
 2b0:	96ce                	add	a3,a3,s3
 2b2:	45c5                	li	a1,17
 2b4:	6605                	lui	a2,0x1
 2b6:	0007c703          	lbu	a4,0(a5)
 2ba:	00b71b63          	bne	a4,a1,2d0 <main+0x2d0>
 2be:	97b2                	add	a5,a5,a2
 2c0:	fed79be3          	bne	a5,a3,2b6 <main+0x2b6>
          exit(0);
 2c4:	4501                	li	a0,0
 2c6:	4fc000ef          	jal	ra,7c2 <exit>
          for(int i = 0; i < w; i++) if(p[i*PG] != PAT_B) exit(2); // own writes
 2ca:	4509                	li	a0,2
 2cc:	4f6000ef          	jal	ra,7c2 <exit>
          for(int i = w; i < N; i++) if(p[i*PG] != PAT_A) exit(3); // shared reads
 2d0:	450d                	li	a0,3
 2d2:	4f0000ef          	jal	ra,7c2 <exit>
          if(p[i*PG] != PAT_A){ iso_ok = 0; break; }
 2d6:	4c81                	li	s9,0
        free(p);
 2d8:	854e                	mv	a0,s3
 2da:	177000ef          	jal	ra,c50 <free>
      for(int t = 0; t < TRIALS; t++){
 2de:	3c7d                	addiw	s8,s8,-1
 2e0:	080c0563          	beqz	s8,36a <main+0x36a>
        char *p = malloc(N * PG);
 2e4:	f5043503          	ld	a0,-176(s0)
 2e8:	1f1000ef          	jal	ra,cd8 <malloc>
 2ec:	89aa                	mv	s3,a0
        for(int i = 0; i < N; i++) p[i*PG] = PAT_A;   // parent baseline
 2ee:	01705a63          	blez	s7,302 <main+0x302>
 2f2:	87aa                	mv	a5,a0
 2f4:	00aa8733          	add	a4,s5,a0
 2f8:	00978023          	sb	s1,0(a5)
 2fc:	97ca                	add	a5,a5,s2
 2fe:	fee79de3          	bne	a5,a4,2f8 <main+0x2f8>
static uint64 rd_cow(void)   { vmstats(&S); return S.cow_faults; }
 302:	8552                	mv	a0,s4
 304:	596000ef          	jal	ra,89a <vmstats>
 308:	000a3d83          	ld	s11,0(s4)
        int pid = fork();
 30c:	4ae000ef          	jal	ra,7ba <fork>
        if(pid == 0){
 310:	d521                	beqz	a0,258 <main+0x258>
        int st = -1;
 312:	57fd                	li	a5,-1
 314:	f6f42223          	sw	a5,-156(s0)
        wait(&st);
 318:	f6440513          	addi	a0,s0,-156
 31c:	4ae000ef          	jal	ra,7ca <wait>
static uint64 rd_cow(void)   { vmstats(&S); return S.cow_faults; }
 320:	8552                	mv	a0,s4
 322:	578000ef          	jal	ra,89a <vmstats>
        uint64 d = rd_cow() - c0;
 326:	000a3783          	ld	a5,0(s4)
 32a:	41b78db3          	sub	s11,a5,s11
        if(d < mn) mn = d;  
 32e:	01adf363          	bgeu	s11,s10,334 <main+0x334>
 332:	8d6e                	mv	s10,s11
        if(d > mx) mx = d;
 334:	f5843783          	ld	a5,-168(s0)
 338:	01b7f463          	bgeu	a5,s11,340 <main+0x340>
 33c:	f5b43c23          	sd	s11,-168(s0)
        if(st != 0) iso_ok = 0;                       // child saw inconsistent view
 340:	f6442783          	lw	a5,-156(s0)
 344:	0017b793          	seqz	a5,a5
 348:	40f007b3          	neg	a5,a5
 34c:	00fcfcb3          	and	s9,s9,a5
        for(int i = 0; i < N; i++)                    // parent must still see all A
 350:	f97054e3          	blez	s7,2d8 <main+0x2d8>
 354:	87ce                	mv	a5,s3
 356:	013a86b3          	add	a3,s5,s3
          if(p[i*PG] != PAT_A){ iso_ok = 0; break; }
 35a:	0007c703          	lbu	a4,0(a5)
 35e:	f6971ce3          	bne	a4,s1,2d6 <main+0x2d6>
        for(int i = 0; i < N; i++)                    // parent must still see all A
 362:	97ca                	add	a5,a5,s2
 364:	fed79be3          	bne	a5,a3,35a <main+0x35a>
 368:	bf85                	j	2d8 <main+0x2d8>
      if(!iso_ok) g_pass = 0;
 36a:	180c9763          	bnez	s9,4f8 <main+0x4f8>
 36e:	00002797          	auipc	a5,0x2
 372:	c807a923          	sw	zero,-878(a5) # 2000 <g_pass>
      printf("  N=%d write=%d%% copied=%d..%d expect=%d det=%s iso=%s\n",
 376:	000d069b          	sext.w	a3,s10
 37a:	f5843783          	ld	a5,-168(s0)
 37e:	0007871b          	sext.w	a4,a5
 382:	08fd0f63          	beq	s10,a5,420 <main+0x420>
 386:	00001817          	auipc	a6,0x1
 38a:	a3a80813          	addi	a6,a6,-1478 # dc0 <malloc+0xe8>
 38e:	00001897          	auipc	a7,0x1
 392:	a4288893          	addi	a7,a7,-1470 # dd0 <malloc+0xf8>
 396:	87da                	mv	a5,s6
 398:	f3843603          	ld	a2,-200(s0)
 39c:	85de                	mv	a1,s7
 39e:	00001517          	auipc	a0,0x1
 3a2:	c2a50513          	addi	a0,a0,-982 # fc8 <malloc+0x2f0>
 3a6:	079000ef          	jal	ra,c1e <printf>
    for(int b = 0; b < 5; b++){
 3aa:	f4843783          	ld	a5,-184(s0)
 3ae:	0791                	addi	a5,a5,4
 3b0:	f4f43423          	sd	a5,-184(s0)
 3b4:	f8c40713          	addi	a4,s0,-116
 3b8:	d6e79ae3          	bne	a5,a4,12c <main+0x12c>
  for(int a = 0; a < 3; a++){
 3bc:	f4043783          	ld	a5,-192(s0)
 3c0:	0791                	addi	a5,a5,4
 3c2:	f4f43023          	sd	a5,-192(s0)
 3c6:	f7440713          	addi	a4,s0,-140
 3ca:	d2e799e3          	bne	a5,a4,fc <main+0xfc>
  printf("\n[Experiment C] alloc/free balance over %d fork/COW/exit cycles\n", cycles);
 3ce:	1f400593          	li	a1,500
 3d2:	00001517          	auipc	a0,0x1
 3d6:	c3650513          	addi	a0,a0,-970 # 1008 <malloc+0x330>
 3da:	045000ef          	jal	ra,c1e <printf>
  char *p = malloc(N * PG);                 // warm up: fix heap so loop never grows it
 3de:	00040537          	lui	a0,0x40
 3e2:	0f7000ef          	jal	ra,cd8 <malloc>
 3e6:	8a2a                	mv	s4,a0
  for(int i = 0; i < N; i++) p[i*PG] = PAT_A;
 3e8:	892a                	mv	s2,a0
 3ea:	000409b7          	lui	s3,0x40
 3ee:	99aa                	add	s3,s3,a0
  char *p = malloc(N * PG);                 // warm up: fix heap so loop never grows it
 3f0:	87aa                	mv	a5,a0
  for(int i = 0; i < N; i++) p[i*PG] = PAT_A;
 3f2:	46c5                	li	a3,17
 3f4:	6705                	lui	a4,0x1
 3f6:	00d78023          	sb	a3,0(a5)
 3fa:	97ba                	add	a5,a5,a4
 3fc:	ff379de3          	bne	a5,s3,3f6 <main+0x3f6>
static uint64 rd_live(void)  { vmstats(&S); return S.kalloc_cnt - S.kfree_cnt; }
 400:	00002497          	auipc	s1,0x2
 404:	c2048493          	addi	s1,s1,-992 # 2020 <S>
 408:	8526                	mv	a0,s1
 40a:	490000ef          	jal	ra,89a <vmstats>
 40e:	6c94                	ld	a3,24(s1)
 410:	60bc                	ld	a5,64(s1)
 412:	40f68ab3          	sub	s5,a3,a5
 416:	1f400493          	li	s1,500
    for(int i = 0; i < N; i++) p[i*PG] = PAT_A;   // re-arm parent pages
 41a:	4bc5                	li	s7,17
 41c:	6b05                	lui	s6,0x1
 41e:	a015                	j	442 <main+0x442>
      printf("  N=%d write=%d%% copied=%d..%d expect=%d det=%s iso=%s\n",
 420:	00001817          	auipc	a6,0x1
 424:	9a880813          	addi	a6,a6,-1624 # dc8 <malloc+0xf0>
 428:	00001897          	auipc	a7,0x1
 42c:	9a888893          	addi	a7,a7,-1624 # dd0 <malloc+0xf8>
 430:	b79d                	j	396 <main+0x396>
    if(fork() == 0){
 432:	388000ef          	jal	ra,7ba <fork>
 436:	cd09                	beqz	a0,450 <main+0x450>
    wait(0);
 438:	4501                	li	a0,0
 43a:	390000ef          	jal	ra,7ca <wait>
  for(int k = 0; k < cycles; k++){
 43e:	34fd                	addiw	s1,s1,-1
 440:	c495                	beqz	s1,46c <main+0x46c>
  char *p = malloc(N * PG);                 // warm up: fix heap so loop never grows it
 442:	87ca                	mv	a5,s2
    for(int i = 0; i < N; i++) p[i*PG] = PAT_A;   // re-arm parent pages
 444:	01778023          	sb	s7,0(a5)
 448:	97da                	add	a5,a5,s6
 44a:	ff379de3          	bne	a5,s3,444 <main+0x444>
 44e:	b7d5                	j	432 <main+0x432>
 450:	000207b7          	lui	a5,0x20
 454:	9a3e                	add	s4,s4,a5
      for(int i = 0; i < N/2; i++) p[i*PG] = PAT_B; // force COW copies in child
 456:	07700713          	li	a4,119
 45a:	6785                	lui	a5,0x1
 45c:	00e90023          	sb	a4,0(s2) # 1000 <malloc+0x328>
 460:	993e                	add	s2,s2,a5
 462:	ff2a1de3          	bne	s4,s2,45c <main+0x45c>
      exit(0);
 466:	4501                	li	a0,0
 468:	35a000ef          	jal	ra,7c2 <exit>
static uint64 rd_live(void)  { vmstats(&S); return S.kalloc_cnt - S.kfree_cnt; }
 46c:	00002917          	auipc	s2,0x2
 470:	bb490913          	addi	s2,s2,-1100 # 2020 <S>
 474:	854a                	mv	a0,s2
 476:	424000ef          	jal	ra,89a <vmstats>
 47a:	01893483          	ld	s1,24(s2)
 47e:	04093783          	ld	a5,64(s2)
 482:	8c9d                	sub	s1,s1,a5
  free(p);
 484:	8552                	mv	a0,s4
 486:	7ca000ef          	jal	ra,c50 <free>
  if(!ok) g_pass = 0;
 48a:	049a8c63          	beq	s5,s1,4e2 <main+0x4e2>
 48e:	00002797          	auipc	a5,0x2
 492:	b607a923          	sw	zero,-1166(a5) # 2000 <g_pass>
  printf("  live_pages before=%d after=%d delta=%d  %s\n",
 496:	000a859b          	sext.w	a1,s5
 49a:	0004861b          	sext.w	a2,s1
 49e:	415486bb          	subw	a3,s1,s5
 4a2:	00001717          	auipc	a4,0x1
 4a6:	93e70713          	addi	a4,a4,-1730 # de0 <malloc+0x108>
 4aa:	00001517          	auipc	a0,0x1
 4ae:	ba650513          	addi	a0,a0,-1114 # 1050 <malloc+0x378>
 4b2:	76c000ef          	jal	ra,c1e <printf>
  exp_fork_scaling();    // MUST be first: clean heap for a precise resident set
  exp_copy_vs_write();
  exp_leak();
  printf("\n=== OVERALL: %s ===\n", g_pass ? "ALL CHECKS PASS" : "SOME CHECKS FAILED");
 4b6:	00002797          	auipc	a5,0x2
 4ba:	b4a7a783          	lw	a5,-1206(a5) # 2000 <g_pass>
 4be:	00001597          	auipc	a1,0x1
 4c2:	94258593          	addi	a1,a1,-1726 # e00 <malloc+0x128>
 4c6:	e789                	bnez	a5,4d0 <main+0x4d0>
 4c8:	00001597          	auipc	a1,0x1
 4cc:	94858593          	addi	a1,a1,-1720 # e10 <malloc+0x138>
 4d0:	00001517          	auipc	a0,0x1
 4d4:	bb050513          	addi	a0,a0,-1104 # 1080 <malloc+0x3a8>
 4d8:	746000ef          	jal	ra,c1e <printf>
  exit(0);
 4dc:	4501                	li	a0,0
 4de:	2e4000ef          	jal	ra,7c2 <exit>
  printf("  live_pages before=%d after=%d delta=%d  %s\n",
 4e2:	000a859b          	sext.w	a1,s5
 4e6:	0004861b          	sext.w	a2,s1
 4ea:	415486bb          	subw	a3,s1,s5
 4ee:	00001717          	auipc	a4,0x1
 4f2:	90270713          	addi	a4,a4,-1790 # df0 <malloc+0x118>
 4f6:	bf55                	j	4aa <main+0x4aa>
      printf("  N=%d write=%d%% copied=%d..%d expect=%d det=%s iso=%s\n",
 4f8:	000d069b          	sext.w	a3,s10
 4fc:	f5843783          	ld	a5,-168(s0)
 500:	0007871b          	sext.w	a4,a5
 504:	00fd0b63          	beq	s10,a5,51a <main+0x51a>
 508:	00001817          	auipc	a6,0x1
 50c:	8b880813          	addi	a6,a6,-1864 # dc0 <malloc+0xe8>
 510:	00001897          	auipc	a7,0x1
 514:	8c888893          	addi	a7,a7,-1848 # dd8 <malloc+0x100>
 518:	bdbd                	j	396 <main+0x396>
 51a:	00001817          	auipc	a6,0x1
 51e:	8ae80813          	addi	a6,a6,-1874 # dc8 <malloc+0xf0>
 522:	00001897          	auipc	a7,0x1
 526:	8b688893          	addi	a7,a7,-1866 # dd8 <malloc+0x100>
 52a:	b5b5                	j	396 <main+0x396>

000000000000052c <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 52c:	1141                	addi	sp,sp,-16
 52e:	e406                	sd	ra,8(sp)
 530:	e022                	sd	s0,0(sp)
 532:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 534:	acdff0ef          	jal	ra,0 <main>
  exit(r);
 538:	28a000ef          	jal	ra,7c2 <exit>

000000000000053c <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 53c:	1141                	addi	sp,sp,-16
 53e:	e422                	sd	s0,8(sp)
 540:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 542:	87aa                	mv	a5,a0
 544:	0585                	addi	a1,a1,1
 546:	0785                	addi	a5,a5,1
 548:	fff5c703          	lbu	a4,-1(a1)
 54c:	fee78fa3          	sb	a4,-1(a5)
 550:	fb75                	bnez	a4,544 <strcpy+0x8>
    ;
  return os;
}
 552:	6422                	ld	s0,8(sp)
 554:	0141                	addi	sp,sp,16
 556:	8082                	ret

0000000000000558 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 558:	1141                	addi	sp,sp,-16
 55a:	e422                	sd	s0,8(sp)
 55c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 55e:	00054783          	lbu	a5,0(a0)
 562:	cb91                	beqz	a5,576 <strcmp+0x1e>
 564:	0005c703          	lbu	a4,0(a1)
 568:	00f71763          	bne	a4,a5,576 <strcmp+0x1e>
    p++, q++;
 56c:	0505                	addi	a0,a0,1
 56e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 570:	00054783          	lbu	a5,0(a0)
 574:	fbe5                	bnez	a5,564 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 576:	0005c503          	lbu	a0,0(a1)
}
 57a:	40a7853b          	subw	a0,a5,a0
 57e:	6422                	ld	s0,8(sp)
 580:	0141                	addi	sp,sp,16
 582:	8082                	ret

0000000000000584 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 584:	1141                	addi	sp,sp,-16
 586:	e422                	sd	s0,8(sp)
 588:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 58a:	00054783          	lbu	a5,0(a0)
 58e:	cf91                	beqz	a5,5aa <strlen+0x26>
 590:	0505                	addi	a0,a0,1
 592:	87aa                	mv	a5,a0
 594:	4685                	li	a3,1
 596:	9e89                	subw	a3,a3,a0
 598:	00f6853b          	addw	a0,a3,a5
 59c:	0785                	addi	a5,a5,1
 59e:	fff7c703          	lbu	a4,-1(a5)
 5a2:	fb7d                	bnez	a4,598 <strlen+0x14>
    ;
  return n;
}
 5a4:	6422                	ld	s0,8(sp)
 5a6:	0141                	addi	sp,sp,16
 5a8:	8082                	ret
  for(n = 0; s[n]; n++)
 5aa:	4501                	li	a0,0
 5ac:	bfe5                	j	5a4 <strlen+0x20>

00000000000005ae <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 5ae:	1141                	addi	sp,sp,-16
 5b0:	e422                	sd	s0,8(sp)
 5b2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 5b4:	ca19                	beqz	a2,5ca <memset+0x1c>
 5b6:	87aa                	mv	a5,a0
 5b8:	1602                	slli	a2,a2,0x20
 5ba:	9201                	srli	a2,a2,0x20
 5bc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 5c0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 5c4:	0785                	addi	a5,a5,1
 5c6:	fee79de3          	bne	a5,a4,5c0 <memset+0x12>
  }
  return dst;
}
 5ca:	6422                	ld	s0,8(sp)
 5cc:	0141                	addi	sp,sp,16
 5ce:	8082                	ret

00000000000005d0 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 5d0:	1141                	addi	sp,sp,-16
 5d2:	e422                	sd	s0,8(sp)
 5d4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 5d6:	00054783          	lbu	a5,0(a0)
 5da:	cb99                	beqz	a5,5f0 <strchr+0x20>
    if(*s == c)
 5dc:	00f58763          	beq	a1,a5,5ea <strchr+0x1a>
  for(; *s; s++)
 5e0:	0505                	addi	a0,a0,1
 5e2:	00054783          	lbu	a5,0(a0)
 5e6:	fbfd                	bnez	a5,5dc <strchr+0xc>
      return (char*)s;
  return 0;
 5e8:	4501                	li	a0,0
}
 5ea:	6422                	ld	s0,8(sp)
 5ec:	0141                	addi	sp,sp,16
 5ee:	8082                	ret
  return 0;
 5f0:	4501                	li	a0,0
 5f2:	bfe5                	j	5ea <strchr+0x1a>

00000000000005f4 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 5f4:	711d                	addi	sp,sp,-96
 5f6:	ec86                	sd	ra,88(sp)
 5f8:	e8a2                	sd	s0,80(sp)
 5fa:	e4a6                	sd	s1,72(sp)
 5fc:	e0ca                	sd	s2,64(sp)
 5fe:	fc4e                	sd	s3,56(sp)
 600:	f852                	sd	s4,48(sp)
 602:	f456                	sd	s5,40(sp)
 604:	f05a                	sd	s6,32(sp)
 606:	ec5e                	sd	s7,24(sp)
 608:	1080                	addi	s0,sp,96
 60a:	8baa                	mv	s7,a0
 60c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 60e:	892a                	mv	s2,a0
 610:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 612:	4aa9                	li	s5,10
 614:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 616:	89a6                	mv	s3,s1
 618:	2485                	addiw	s1,s1,1
 61a:	0344d663          	bge	s1,s4,646 <gets+0x52>
    cc = read(0, &c, 1);
 61e:	4605                	li	a2,1
 620:	faf40593          	addi	a1,s0,-81
 624:	4501                	li	a0,0
 626:	1b4000ef          	jal	ra,7da <read>
    if(cc < 1)
 62a:	00a05e63          	blez	a0,646 <gets+0x52>
    buf[i++] = c;
 62e:	faf44783          	lbu	a5,-81(s0)
 632:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 636:	01578763          	beq	a5,s5,644 <gets+0x50>
 63a:	0905                	addi	s2,s2,1
 63c:	fd679de3          	bne	a5,s6,616 <gets+0x22>
  for(i=0; i+1 < max; ){
 640:	89a6                	mv	s3,s1
 642:	a011                	j	646 <gets+0x52>
 644:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 646:	99de                	add	s3,s3,s7
 648:	00098023          	sb	zero,0(s3) # 40000 <base+0x3df98>
  return buf;
}
 64c:	855e                	mv	a0,s7
 64e:	60e6                	ld	ra,88(sp)
 650:	6446                	ld	s0,80(sp)
 652:	64a6                	ld	s1,72(sp)
 654:	6906                	ld	s2,64(sp)
 656:	79e2                	ld	s3,56(sp)
 658:	7a42                	ld	s4,48(sp)
 65a:	7aa2                	ld	s5,40(sp)
 65c:	7b02                	ld	s6,32(sp)
 65e:	6be2                	ld	s7,24(sp)
 660:	6125                	addi	sp,sp,96
 662:	8082                	ret

0000000000000664 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 664:	1101                	addi	sp,sp,-32
 666:	ec06                	sd	ra,24(sp)
 668:	e822                	sd	s0,16(sp)
 66a:	e426                	sd	s1,8(sp)
 66c:	e04a                	sd	s2,0(sp)
 66e:	1000                	addi	s0,sp,32
 670:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 672:	4581                	li	a1,0
 674:	18e000ef          	jal	ra,802 <open>
  if(fd < 0)
 678:	02054163          	bltz	a0,69a <stat+0x36>
 67c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 67e:	85ca                	mv	a1,s2
 680:	19a000ef          	jal	ra,81a <fstat>
 684:	892a                	mv	s2,a0
  close(fd);
 686:	8526                	mv	a0,s1
 688:	162000ef          	jal	ra,7ea <close>
  return r;
}
 68c:	854a                	mv	a0,s2
 68e:	60e2                	ld	ra,24(sp)
 690:	6442                	ld	s0,16(sp)
 692:	64a2                	ld	s1,8(sp)
 694:	6902                	ld	s2,0(sp)
 696:	6105                	addi	sp,sp,32
 698:	8082                	ret
    return -1;
 69a:	597d                	li	s2,-1
 69c:	bfc5                	j	68c <stat+0x28>

000000000000069e <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 69e:	1141                	addi	sp,sp,-16
 6a0:	e422                	sd	s0,8(sp)
 6a2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6a4:	00054603          	lbu	a2,0(a0)
 6a8:	fd06079b          	addiw	a5,a2,-48
 6ac:	0ff7f793          	andi	a5,a5,255
 6b0:	4725                	li	a4,9
 6b2:	02f76963          	bltu	a4,a5,6e4 <atoi+0x46>
 6b6:	86aa                	mv	a3,a0
  n = 0;
 6b8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 6ba:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 6bc:	0685                	addi	a3,a3,1
 6be:	0025179b          	slliw	a5,a0,0x2
 6c2:	9fa9                	addw	a5,a5,a0
 6c4:	0017979b          	slliw	a5,a5,0x1
 6c8:	9fb1                	addw	a5,a5,a2
 6ca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 6ce:	0006c603          	lbu	a2,0(a3) # 1000 <malloc+0x328>
 6d2:	fd06071b          	addiw	a4,a2,-48
 6d6:	0ff77713          	andi	a4,a4,255
 6da:	fee5f1e3          	bgeu	a1,a4,6bc <atoi+0x1e>
  return n;
}
 6de:	6422                	ld	s0,8(sp)
 6e0:	0141                	addi	sp,sp,16
 6e2:	8082                	ret
  n = 0;
 6e4:	4501                	li	a0,0
 6e6:	bfe5                	j	6de <atoi+0x40>

00000000000006e8 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6e8:	1141                	addi	sp,sp,-16
 6ea:	e422                	sd	s0,8(sp)
 6ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6ee:	02b57463          	bgeu	a0,a1,716 <memmove+0x2e>
    while(n-- > 0)
 6f2:	00c05f63          	blez	a2,710 <memmove+0x28>
 6f6:	1602                	slli	a2,a2,0x20
 6f8:	9201                	srli	a2,a2,0x20
 6fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 6fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 700:	0585                	addi	a1,a1,1
 702:	0705                	addi	a4,a4,1
 704:	fff5c683          	lbu	a3,-1(a1)
 708:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 70c:	fee79ae3          	bne	a5,a4,700 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 710:	6422                	ld	s0,8(sp)
 712:	0141                	addi	sp,sp,16
 714:	8082                	ret
    dst += n;
 716:	00c50733          	add	a4,a0,a2
    src += n;
 71a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 71c:	fec05ae3          	blez	a2,710 <memmove+0x28>
 720:	fff6079b          	addiw	a5,a2,-1
 724:	1782                	slli	a5,a5,0x20
 726:	9381                	srli	a5,a5,0x20
 728:	fff7c793          	not	a5,a5
 72c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 72e:	15fd                	addi	a1,a1,-1
 730:	177d                	addi	a4,a4,-1
 732:	0005c683          	lbu	a3,0(a1)
 736:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 73a:	fee79ae3          	bne	a5,a4,72e <memmove+0x46>
 73e:	bfc9                	j	710 <memmove+0x28>

0000000000000740 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 740:	1141                	addi	sp,sp,-16
 742:	e422                	sd	s0,8(sp)
 744:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 746:	ca05                	beqz	a2,776 <memcmp+0x36>
 748:	fff6069b          	addiw	a3,a2,-1
 74c:	1682                	slli	a3,a3,0x20
 74e:	9281                	srli	a3,a3,0x20
 750:	0685                	addi	a3,a3,1
 752:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 754:	00054783          	lbu	a5,0(a0)
 758:	0005c703          	lbu	a4,0(a1)
 75c:	00e79863          	bne	a5,a4,76c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 760:	0505                	addi	a0,a0,1
    p2++;
 762:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 764:	fed518e3          	bne	a0,a3,754 <memcmp+0x14>
  }
  return 0;
 768:	4501                	li	a0,0
 76a:	a019                	j	770 <memcmp+0x30>
      return *p1 - *p2;
 76c:	40e7853b          	subw	a0,a5,a4
}
 770:	6422                	ld	s0,8(sp)
 772:	0141                	addi	sp,sp,16
 774:	8082                	ret
  return 0;
 776:	4501                	li	a0,0
 778:	bfe5                	j	770 <memcmp+0x30>

000000000000077a <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 77a:	1141                	addi	sp,sp,-16
 77c:	e406                	sd	ra,8(sp)
 77e:	e022                	sd	s0,0(sp)
 780:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 782:	f67ff0ef          	jal	ra,6e8 <memmove>
}
 786:	60a2                	ld	ra,8(sp)
 788:	6402                	ld	s0,0(sp)
 78a:	0141                	addi	sp,sp,16
 78c:	8082                	ret

000000000000078e <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 78e:	1141                	addi	sp,sp,-16
 790:	e406                	sd	ra,8(sp)
 792:	e022                	sd	s0,0(sp)
 794:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 796:	4585                	li	a1,1
 798:	0b2000ef          	jal	ra,84a <sys_sbrk>
}
 79c:	60a2                	ld	ra,8(sp)
 79e:	6402                	ld	s0,0(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret

00000000000007a4 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 7a4:	1141                	addi	sp,sp,-16
 7a6:	e406                	sd	ra,8(sp)
 7a8:	e022                	sd	s0,0(sp)
 7aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 7ac:	4589                	li	a1,2
 7ae:	09c000ef          	jal	ra,84a <sys_sbrk>
}
 7b2:	60a2                	ld	ra,8(sp)
 7b4:	6402                	ld	s0,0(sp)
 7b6:	0141                	addi	sp,sp,16
 7b8:	8082                	ret

00000000000007ba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 7ba:	4885                	li	a7,1
 ecall
 7bc:	00000073          	ecall
 ret
 7c0:	8082                	ret

00000000000007c2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 7c2:	4889                	li	a7,2
 ecall
 7c4:	00000073          	ecall
 ret
 7c8:	8082                	ret

00000000000007ca <wait>:
.global wait
wait:
 li a7, SYS_wait
 7ca:	488d                	li	a7,3
 ecall
 7cc:	00000073          	ecall
 ret
 7d0:	8082                	ret

00000000000007d2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 7d2:	4891                	li	a7,4
 ecall
 7d4:	00000073          	ecall
 ret
 7d8:	8082                	ret

00000000000007da <read>:
.global read
read:
 li a7, SYS_read
 7da:	4895                	li	a7,5
 ecall
 7dc:	00000073          	ecall
 ret
 7e0:	8082                	ret

00000000000007e2 <write>:
.global write
write:
 li a7, SYS_write
 7e2:	48c1                	li	a7,16
 ecall
 7e4:	00000073          	ecall
 ret
 7e8:	8082                	ret

00000000000007ea <close>:
.global close
close:
 li a7, SYS_close
 7ea:	48d5                	li	a7,21
 ecall
 7ec:	00000073          	ecall
 ret
 7f0:	8082                	ret

00000000000007f2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 7f2:	4899                	li	a7,6
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <exec>:
.global exec
exec:
 li a7, SYS_exec
 7fa:	489d                	li	a7,7
 ecall
 7fc:	00000073          	ecall
 ret
 800:	8082                	ret

0000000000000802 <open>:
.global open
open:
 li a7, SYS_open
 802:	48bd                	li	a7,15
 ecall
 804:	00000073          	ecall
 ret
 808:	8082                	ret

000000000000080a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 80a:	48c5                	li	a7,17
 ecall
 80c:	00000073          	ecall
 ret
 810:	8082                	ret

0000000000000812 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 812:	48c9                	li	a7,18
 ecall
 814:	00000073          	ecall
 ret
 818:	8082                	ret

000000000000081a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 81a:	48a1                	li	a7,8
 ecall
 81c:	00000073          	ecall
 ret
 820:	8082                	ret

0000000000000822 <link>:
.global link
link:
 li a7, SYS_link
 822:	48cd                	li	a7,19
 ecall
 824:	00000073          	ecall
 ret
 828:	8082                	ret

000000000000082a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 82a:	48d1                	li	a7,20
 ecall
 82c:	00000073          	ecall
 ret
 830:	8082                	ret

0000000000000832 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 832:	48a5                	li	a7,9
 ecall
 834:	00000073          	ecall
 ret
 838:	8082                	ret

000000000000083a <dup>:
.global dup
dup:
 li a7, SYS_dup
 83a:	48a9                	li	a7,10
 ecall
 83c:	00000073          	ecall
 ret
 840:	8082                	ret

0000000000000842 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 842:	48ad                	li	a7,11
 ecall
 844:	00000073          	ecall
 ret
 848:	8082                	ret

000000000000084a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 84a:	48b1                	li	a7,12
 ecall
 84c:	00000073          	ecall
 ret
 850:	8082                	ret

0000000000000852 <pause>:
.global pause
pause:
 li a7, SYS_pause
 852:	48b5                	li	a7,13
 ecall
 854:	00000073          	ecall
 ret
 858:	8082                	ret

000000000000085a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 85a:	48b9                	li	a7,14
 ecall
 85c:	00000073          	ecall
 ret
 860:	8082                	ret

0000000000000862 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 862:	48d9                	li	a7,22
 ecall
 864:	00000073          	ecall
 ret
 868:	8082                	ret

000000000000086a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 86a:	48dd                	li	a7,23
 ecall
 86c:	00000073          	ecall
 ret
 870:	8082                	ret

0000000000000872 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 872:	48e1                	li	a7,24
 ecall
 874:	00000073          	ecall
 ret
 878:	8082                	ret

000000000000087a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 87a:	48e5                	li	a7,25
 ecall
 87c:	00000073          	ecall
 ret
 880:	8082                	ret

0000000000000882 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 882:	48e9                	li	a7,26
 ecall
 884:	00000073          	ecall
 ret
 888:	8082                	ret

000000000000088a <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 88a:	48ed                	li	a7,27
 ecall
 88c:	00000073          	ecall
 ret
 890:	8082                	ret

0000000000000892 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 892:	48f1                	li	a7,28
 ecall
 894:	00000073          	ecall
 ret
 898:	8082                	ret

000000000000089a <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 89a:	48f5                	li	a7,29
 ecall
 89c:	00000073          	ecall
 ret
 8a0:	8082                	ret

00000000000008a2 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 8a2:	1101                	addi	sp,sp,-32
 8a4:	ec06                	sd	ra,24(sp)
 8a6:	e822                	sd	s0,16(sp)
 8a8:	1000                	addi	s0,sp,32
 8aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 8ae:	4605                	li	a2,1
 8b0:	fef40593          	addi	a1,s0,-17
 8b4:	f2fff0ef          	jal	ra,7e2 <write>
}
 8b8:	60e2                	ld	ra,24(sp)
 8ba:	6442                	ld	s0,16(sp)
 8bc:	6105                	addi	sp,sp,32
 8be:	8082                	ret

00000000000008c0 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 8c0:	715d                	addi	sp,sp,-80
 8c2:	e486                	sd	ra,72(sp)
 8c4:	e0a2                	sd	s0,64(sp)
 8c6:	fc26                	sd	s1,56(sp)
 8c8:	f84a                	sd	s2,48(sp)
 8ca:	f44e                	sd	s3,40(sp)
 8cc:	0880                	addi	s0,sp,80
 8ce:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 8d0:	c299                	beqz	a3,8d6 <printint+0x16>
 8d2:	0805c163          	bltz	a1,954 <printint+0x94>
  neg = 0;
 8d6:	4881                	li	a7,0
 8d8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 8dc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 8de:	00000517          	auipc	a0,0x0
 8e2:	7c250513          	addi	a0,a0,1986 # 10a0 <digits>
 8e6:	883e                	mv	a6,a5
 8e8:	2785                	addiw	a5,a5,1
 8ea:	02c5f733          	remu	a4,a1,a2
 8ee:	972a                	add	a4,a4,a0
 8f0:	00074703          	lbu	a4,0(a4)
 8f4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 8f8:	872e                	mv	a4,a1
 8fa:	02c5d5b3          	divu	a1,a1,a2
 8fe:	0685                	addi	a3,a3,1
 900:	fec773e3          	bgeu	a4,a2,8e6 <printint+0x26>
  if(neg)
 904:	00088b63          	beqz	a7,91a <printint+0x5a>
    buf[i++] = '-';
 908:	fd040713          	addi	a4,s0,-48
 90c:	97ba                	add	a5,a5,a4
 90e:	02d00713          	li	a4,45
 912:	fee78423          	sb	a4,-24(a5)
 916:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 91a:	02f05663          	blez	a5,946 <printint+0x86>
 91e:	fb840713          	addi	a4,s0,-72
 922:	00f704b3          	add	s1,a4,a5
 926:	fff70993          	addi	s3,a4,-1
 92a:	99be                	add	s3,s3,a5
 92c:	37fd                	addiw	a5,a5,-1
 92e:	1782                	slli	a5,a5,0x20
 930:	9381                	srli	a5,a5,0x20
 932:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 936:	fff4c583          	lbu	a1,-1(s1)
 93a:	854a                	mv	a0,s2
 93c:	f67ff0ef          	jal	ra,8a2 <putc>
  while(--i >= 0)
 940:	14fd                	addi	s1,s1,-1
 942:	ff349ae3          	bne	s1,s3,936 <printint+0x76>
}
 946:	60a6                	ld	ra,72(sp)
 948:	6406                	ld	s0,64(sp)
 94a:	74e2                	ld	s1,56(sp)
 94c:	7942                	ld	s2,48(sp)
 94e:	79a2                	ld	s3,40(sp)
 950:	6161                	addi	sp,sp,80
 952:	8082                	ret
    x = -xx;
 954:	40b005b3          	neg	a1,a1
    neg = 1;
 958:	4885                	li	a7,1
    x = -xx;
 95a:	bfbd                	j	8d8 <printint+0x18>

000000000000095c <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 95c:	7119                	addi	sp,sp,-128
 95e:	fc86                	sd	ra,120(sp)
 960:	f8a2                	sd	s0,112(sp)
 962:	f4a6                	sd	s1,104(sp)
 964:	f0ca                	sd	s2,96(sp)
 966:	ecce                	sd	s3,88(sp)
 968:	e8d2                	sd	s4,80(sp)
 96a:	e4d6                	sd	s5,72(sp)
 96c:	e0da                	sd	s6,64(sp)
 96e:	fc5e                	sd	s7,56(sp)
 970:	f862                	sd	s8,48(sp)
 972:	f466                	sd	s9,40(sp)
 974:	f06a                	sd	s10,32(sp)
 976:	ec6e                	sd	s11,24(sp)
 978:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 97a:	0005c903          	lbu	s2,0(a1)
 97e:	24090c63          	beqz	s2,bd6 <vprintf+0x27a>
 982:	8b2a                	mv	s6,a0
 984:	8a2e                	mv	s4,a1
 986:	8bb2                	mv	s7,a2
  state = 0;
 988:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 98a:	4481                	li	s1,0
 98c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 98e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 992:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 996:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 99a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 99e:	00000c97          	auipc	s9,0x0
 9a2:	702c8c93          	addi	s9,s9,1794 # 10a0 <digits>
 9a6:	a005                	j	9c6 <vprintf+0x6a>
        putc(fd, c0);
 9a8:	85ca                	mv	a1,s2
 9aa:	855a                	mv	a0,s6
 9ac:	ef7ff0ef          	jal	ra,8a2 <putc>
 9b0:	a019                	j	9b6 <vprintf+0x5a>
    } else if(state == '%'){
 9b2:	03598263          	beq	s3,s5,9d6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 9b6:	2485                	addiw	s1,s1,1
 9b8:	8726                	mv	a4,s1
 9ba:	009a07b3          	add	a5,s4,s1
 9be:	0007c903          	lbu	s2,0(a5)
 9c2:	20090a63          	beqz	s2,bd6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 9c6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 9ca:	fe0994e3          	bnez	s3,9b2 <vprintf+0x56>
      if(c0 == '%'){
 9ce:	fd579de3          	bne	a5,s5,9a8 <vprintf+0x4c>
        state = '%';
 9d2:	89be                	mv	s3,a5
 9d4:	b7cd                	j	9b6 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 9d6:	c3c1                	beqz	a5,a56 <vprintf+0xfa>
 9d8:	00ea06b3          	add	a3,s4,a4
 9dc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 9e0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 9e2:	c681                	beqz	a3,9ea <vprintf+0x8e>
 9e4:	9752                	add	a4,a4,s4
 9e6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 9ea:	03878e63          	beq	a5,s8,a26 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 9ee:	05a78863          	beq	a5,s10,a3e <vprintf+0xe2>
      } else if(c0 == 'u'){
 9f2:	0db78b63          	beq	a5,s11,ac8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 9f6:	07800713          	li	a4,120
 9fa:	10e78d63          	beq	a5,a4,b14 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 9fe:	07000713          	li	a4,112
 a02:	14e78263          	beq	a5,a4,b46 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 a06:	06300713          	li	a4,99
 a0a:	16e78f63          	beq	a5,a4,b88 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 a0e:	07300713          	li	a4,115
 a12:	18e78563          	beq	a5,a4,b9c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 a16:	05579063          	bne	a5,s5,a56 <vprintf+0xfa>
        putc(fd, '%');
 a1a:	85d6                	mv	a1,s5
 a1c:	855a                	mv	a0,s6
 a1e:	e85ff0ef          	jal	ra,8a2 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 a22:	4981                	li	s3,0
 a24:	bf49                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 a26:	008b8913          	addi	s2,s7,8
 a2a:	4685                	li	a3,1
 a2c:	4629                	li	a2,10
 a2e:	000ba583          	lw	a1,0(s7)
 a32:	855a                	mv	a0,s6
 a34:	e8dff0ef          	jal	ra,8c0 <printint>
 a38:	8bca                	mv	s7,s2
      state = 0;
 a3a:	4981                	li	s3,0
 a3c:	bfad                	j	9b6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 a3e:	03868663          	beq	a3,s8,a6a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 a42:	05a68163          	beq	a3,s10,a84 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 a46:	09b68d63          	beq	a3,s11,ae0 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 a4a:	03a68f63          	beq	a3,s10,a88 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 a4e:	07800793          	li	a5,120
 a52:	0cf68d63          	beq	a3,a5,b2c <vprintf+0x1d0>
        putc(fd, '%');
 a56:	85d6                	mv	a1,s5
 a58:	855a                	mv	a0,s6
 a5a:	e49ff0ef          	jal	ra,8a2 <putc>
        putc(fd, c0);
 a5e:	85ca                	mv	a1,s2
 a60:	855a                	mv	a0,s6
 a62:	e41ff0ef          	jal	ra,8a2 <putc>
      state = 0;
 a66:	4981                	li	s3,0
 a68:	b7b9                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 a6a:	008b8913          	addi	s2,s7,8
 a6e:	4685                	li	a3,1
 a70:	4629                	li	a2,10
 a72:	000bb583          	ld	a1,0(s7)
 a76:	855a                	mv	a0,s6
 a78:	e49ff0ef          	jal	ra,8c0 <printint>
        i += 1;
 a7c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 a7e:	8bca                	mv	s7,s2
      state = 0;
 a80:	4981                	li	s3,0
        i += 1;
 a82:	bf15                	j	9b6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 a84:	03860563          	beq	a2,s8,aae <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 a88:	07b60963          	beq	a2,s11,afa <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 a8c:	07800793          	li	a5,120
 a90:	fcf613e3          	bne	a2,a5,a56 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a94:	008b8913          	addi	s2,s7,8
 a98:	4681                	li	a3,0
 a9a:	4641                	li	a2,16
 a9c:	000bb583          	ld	a1,0(s7)
 aa0:	855a                	mv	a0,s6
 aa2:	e1fff0ef          	jal	ra,8c0 <printint>
        i += 2;
 aa6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 aa8:	8bca                	mv	s7,s2
      state = 0;
 aaa:	4981                	li	s3,0
        i += 2;
 aac:	b729                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 aae:	008b8913          	addi	s2,s7,8
 ab2:	4685                	li	a3,1
 ab4:	4629                	li	a2,10
 ab6:	000bb583          	ld	a1,0(s7)
 aba:	855a                	mv	a0,s6
 abc:	e05ff0ef          	jal	ra,8c0 <printint>
        i += 2;
 ac0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 ac2:	8bca                	mv	s7,s2
      state = 0;
 ac4:	4981                	li	s3,0
        i += 2;
 ac6:	bdc5                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 ac8:	008b8913          	addi	s2,s7,8
 acc:	4681                	li	a3,0
 ace:	4629                	li	a2,10
 ad0:	000be583          	lwu	a1,0(s7)
 ad4:	855a                	mv	a0,s6
 ad6:	debff0ef          	jal	ra,8c0 <printint>
 ada:	8bca                	mv	s7,s2
      state = 0;
 adc:	4981                	li	s3,0
 ade:	bde1                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ae0:	008b8913          	addi	s2,s7,8
 ae4:	4681                	li	a3,0
 ae6:	4629                	li	a2,10
 ae8:	000bb583          	ld	a1,0(s7)
 aec:	855a                	mv	a0,s6
 aee:	dd3ff0ef          	jal	ra,8c0 <printint>
        i += 1;
 af2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 af4:	8bca                	mv	s7,s2
      state = 0;
 af6:	4981                	li	s3,0
        i += 1;
 af8:	bd7d                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 afa:	008b8913          	addi	s2,s7,8
 afe:	4681                	li	a3,0
 b00:	4629                	li	a2,10
 b02:	000bb583          	ld	a1,0(s7)
 b06:	855a                	mv	a0,s6
 b08:	db9ff0ef          	jal	ra,8c0 <printint>
        i += 2;
 b0c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 b0e:	8bca                	mv	s7,s2
      state = 0;
 b10:	4981                	li	s3,0
        i += 2;
 b12:	b555                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 b14:	008b8913          	addi	s2,s7,8
 b18:	4681                	li	a3,0
 b1a:	4641                	li	a2,16
 b1c:	000be583          	lwu	a1,0(s7)
 b20:	855a                	mv	a0,s6
 b22:	d9fff0ef          	jal	ra,8c0 <printint>
 b26:	8bca                	mv	s7,s2
      state = 0;
 b28:	4981                	li	s3,0
 b2a:	b571                	j	9b6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 b2c:	008b8913          	addi	s2,s7,8
 b30:	4681                	li	a3,0
 b32:	4641                	li	a2,16
 b34:	000bb583          	ld	a1,0(s7)
 b38:	855a                	mv	a0,s6
 b3a:	d87ff0ef          	jal	ra,8c0 <printint>
        i += 1;
 b3e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 b40:	8bca                	mv	s7,s2
      state = 0;
 b42:	4981                	li	s3,0
        i += 1;
 b44:	bd8d                	j	9b6 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 b46:	008b8793          	addi	a5,s7,8
 b4a:	f8f43423          	sd	a5,-120(s0)
 b4e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 b52:	03000593          	li	a1,48
 b56:	855a                	mv	a0,s6
 b58:	d4bff0ef          	jal	ra,8a2 <putc>
  putc(fd, 'x');
 b5c:	07800593          	li	a1,120
 b60:	855a                	mv	a0,s6
 b62:	d41ff0ef          	jal	ra,8a2 <putc>
 b66:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b68:	03c9d793          	srli	a5,s3,0x3c
 b6c:	97e6                	add	a5,a5,s9
 b6e:	0007c583          	lbu	a1,0(a5)
 b72:	855a                	mv	a0,s6
 b74:	d2fff0ef          	jal	ra,8a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 b78:	0992                	slli	s3,s3,0x4
 b7a:	397d                	addiw	s2,s2,-1
 b7c:	fe0916e3          	bnez	s2,b68 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 b80:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 b84:	4981                	li	s3,0
 b86:	bd05                	j	9b6 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 b88:	008b8913          	addi	s2,s7,8
 b8c:	000bc583          	lbu	a1,0(s7)
 b90:	855a                	mv	a0,s6
 b92:	d11ff0ef          	jal	ra,8a2 <putc>
 b96:	8bca                	mv	s7,s2
      state = 0;
 b98:	4981                	li	s3,0
 b9a:	bd31                	j	9b6 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 b9c:	008b8993          	addi	s3,s7,8
 ba0:	000bb903          	ld	s2,0(s7)
 ba4:	00090f63          	beqz	s2,bc2 <vprintf+0x266>
        for(; *s; s++)
 ba8:	00094583          	lbu	a1,0(s2)
 bac:	c195                	beqz	a1,bd0 <vprintf+0x274>
          putc(fd, *s);
 bae:	855a                	mv	a0,s6
 bb0:	cf3ff0ef          	jal	ra,8a2 <putc>
        for(; *s; s++)
 bb4:	0905                	addi	s2,s2,1
 bb6:	00094583          	lbu	a1,0(s2)
 bba:	f9f5                	bnez	a1,bae <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 bbc:	8bce                	mv	s7,s3
      state = 0;
 bbe:	4981                	li	s3,0
 bc0:	bbdd                	j	9b6 <vprintf+0x5a>
          s = "(null)";
 bc2:	00000917          	auipc	s2,0x0
 bc6:	4d690913          	addi	s2,s2,1238 # 1098 <malloc+0x3c0>
        for(; *s; s++)
 bca:	02800593          	li	a1,40
 bce:	b7c5                	j	bae <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 bd0:	8bce                	mv	s7,s3
      state = 0;
 bd2:	4981                	li	s3,0
 bd4:	b3cd                	j	9b6 <vprintf+0x5a>
    }
  }
}
 bd6:	70e6                	ld	ra,120(sp)
 bd8:	7446                	ld	s0,112(sp)
 bda:	74a6                	ld	s1,104(sp)
 bdc:	7906                	ld	s2,96(sp)
 bde:	69e6                	ld	s3,88(sp)
 be0:	6a46                	ld	s4,80(sp)
 be2:	6aa6                	ld	s5,72(sp)
 be4:	6b06                	ld	s6,64(sp)
 be6:	7be2                	ld	s7,56(sp)
 be8:	7c42                	ld	s8,48(sp)
 bea:	7ca2                	ld	s9,40(sp)
 bec:	7d02                	ld	s10,32(sp)
 bee:	6de2                	ld	s11,24(sp)
 bf0:	6109                	addi	sp,sp,128
 bf2:	8082                	ret

0000000000000bf4 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 bf4:	715d                	addi	sp,sp,-80
 bf6:	ec06                	sd	ra,24(sp)
 bf8:	e822                	sd	s0,16(sp)
 bfa:	1000                	addi	s0,sp,32
 bfc:	e010                	sd	a2,0(s0)
 bfe:	e414                	sd	a3,8(s0)
 c00:	e818                	sd	a4,16(s0)
 c02:	ec1c                	sd	a5,24(s0)
 c04:	03043023          	sd	a6,32(s0)
 c08:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c0c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c10:	8622                	mv	a2,s0
 c12:	d4bff0ef          	jal	ra,95c <vprintf>
}
 c16:	60e2                	ld	ra,24(sp)
 c18:	6442                	ld	s0,16(sp)
 c1a:	6161                	addi	sp,sp,80
 c1c:	8082                	ret

0000000000000c1e <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 c1e:	711d                	addi	sp,sp,-96
 c20:	ec06                	sd	ra,24(sp)
 c22:	e822                	sd	s0,16(sp)
 c24:	1000                	addi	s0,sp,32
 c26:	e40c                	sd	a1,8(s0)
 c28:	e810                	sd	a2,16(s0)
 c2a:	ec14                	sd	a3,24(s0)
 c2c:	f018                	sd	a4,32(s0)
 c2e:	f41c                	sd	a5,40(s0)
 c30:	03043823          	sd	a6,48(s0)
 c34:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c38:	00840613          	addi	a2,s0,8
 c3c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 c40:	85aa                	mv	a1,a0
 c42:	4505                	li	a0,1
 c44:	d19ff0ef          	jal	ra,95c <vprintf>
}
 c48:	60e2                	ld	ra,24(sp)
 c4a:	6442                	ld	s0,16(sp)
 c4c:	6125                	addi	sp,sp,96
 c4e:	8082                	ret

0000000000000c50 <free>:
 *   无
 */

void
free(void *ap)
{
 c50:	1141                	addi	sp,sp,-16
 c52:	e422                	sd	s0,8(sp)
 c54:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 c56:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c5a:	00001797          	auipc	a5,0x1
 c5e:	3b67b783          	ld	a5,950(a5) # 2010 <freep>
 c62:	a805                	j	c92 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 c64:	4618                	lw	a4,8(a2)
 c66:	9db9                	addw	a1,a1,a4
 c68:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 c6c:	6398                	ld	a4,0(a5)
 c6e:	6318                	ld	a4,0(a4)
 c70:	fee53823          	sd	a4,-16(a0)
 c74:	a091                	j	cb8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 c76:	ff852703          	lw	a4,-8(a0)
 c7a:	9e39                	addw	a2,a2,a4
 c7c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 c7e:	ff053703          	ld	a4,-16(a0)
 c82:	e398                	sd	a4,0(a5)
 c84:	a099                	j	cca <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c86:	6398                	ld	a4,0(a5)
 c88:	00e7e463          	bltu	a5,a4,c90 <free+0x40>
 c8c:	00e6ea63          	bltu	a3,a4,ca0 <free+0x50>
{
 c90:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c92:	fed7fae3          	bgeu	a5,a3,c86 <free+0x36>
 c96:	6398                	ld	a4,0(a5)
 c98:	00e6e463          	bltu	a3,a4,ca0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c9c:	fee7eae3          	bltu	a5,a4,c90 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ca0:	ff852583          	lw	a1,-8(a0)
 ca4:	6390                	ld	a2,0(a5)
 ca6:	02059713          	slli	a4,a1,0x20
 caa:	9301                	srli	a4,a4,0x20
 cac:	0712                	slli	a4,a4,0x4
 cae:	9736                	add	a4,a4,a3
 cb0:	fae60ae3          	beq	a2,a4,c64 <free+0x14>
    bp->s.ptr = p->s.ptr;
 cb4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 cb8:	4790                	lw	a2,8(a5)
 cba:	02061713          	slli	a4,a2,0x20
 cbe:	9301                	srli	a4,a4,0x20
 cc0:	0712                	slli	a4,a4,0x4
 cc2:	973e                	add	a4,a4,a5
 cc4:	fae689e3          	beq	a3,a4,c76 <free+0x26>
  } else
    p->s.ptr = bp;
 cc8:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 cca:	00001717          	auipc	a4,0x1
 cce:	34f73323          	sd	a5,838(a4) # 2010 <freep>
}
 cd2:	6422                	ld	s0,8(sp)
 cd4:	0141                	addi	sp,sp,16
 cd6:	8082                	ret

0000000000000cd8 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 cd8:	7139                	addi	sp,sp,-64
 cda:	fc06                	sd	ra,56(sp)
 cdc:	f822                	sd	s0,48(sp)
 cde:	f426                	sd	s1,40(sp)
 ce0:	f04a                	sd	s2,32(sp)
 ce2:	ec4e                	sd	s3,24(sp)
 ce4:	e852                	sd	s4,16(sp)
 ce6:	e456                	sd	s5,8(sp)
 ce8:	e05a                	sd	s6,0(sp)
 cea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 cec:	02051493          	slli	s1,a0,0x20
 cf0:	9081                	srli	s1,s1,0x20
 cf2:	04bd                	addi	s1,s1,15
 cf4:	8091                	srli	s1,s1,0x4
 cf6:	0014899b          	addiw	s3,s1,1
 cfa:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 cfc:	00001517          	auipc	a0,0x1
 d00:	31453503          	ld	a0,788(a0) # 2010 <freep>
 d04:	c515                	beqz	a0,d30 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d06:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 d08:	4798                	lw	a4,8(a5)
 d0a:	02977f63          	bgeu	a4,s1,d48 <malloc+0x70>
 d0e:	8a4e                	mv	s4,s3
 d10:	0009871b          	sext.w	a4,s3
 d14:	6685                	lui	a3,0x1
 d16:	00d77363          	bgeu	a4,a3,d1c <malloc+0x44>
 d1a:	6a05                	lui	s4,0x1
 d1c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 d20:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 d24:	00001917          	auipc	s2,0x1
 d28:	2ec90913          	addi	s2,s2,748 # 2010 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 d2c:	5afd                	li	s5,-1
 d2e:	a0bd                	j	d9c <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 d30:	00001797          	auipc	a5,0x1
 d34:	33878793          	addi	a5,a5,824 # 2068 <base>
 d38:	00001717          	auipc	a4,0x1
 d3c:	2cf73c23          	sd	a5,728(a4) # 2010 <freep>
 d40:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 d42:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 d46:	b7e1                	j	d0e <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 d48:	02e48b63          	beq	s1,a4,d7e <malloc+0xa6>
        p->s.size -= nunits;
 d4c:	4137073b          	subw	a4,a4,s3
 d50:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d52:	1702                	slli	a4,a4,0x20
 d54:	9301                	srli	a4,a4,0x20
 d56:	0712                	slli	a4,a4,0x4
 d58:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 d5a:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 d5e:	00001717          	auipc	a4,0x1
 d62:	2aa73923          	sd	a0,690(a4) # 2010 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 d66:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 d6a:	70e2                	ld	ra,56(sp)
 d6c:	7442                	ld	s0,48(sp)
 d6e:	74a2                	ld	s1,40(sp)
 d70:	7902                	ld	s2,32(sp)
 d72:	69e2                	ld	s3,24(sp)
 d74:	6a42                	ld	s4,16(sp)
 d76:	6aa2                	ld	s5,8(sp)
 d78:	6b02                	ld	s6,0(sp)
 d7a:	6121                	addi	sp,sp,64
 d7c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 d7e:	6398                	ld	a4,0(a5)
 d80:	e118                	sd	a4,0(a0)
 d82:	bff1                	j	d5e <malloc+0x86>
  hp->s.size = nu;
 d84:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 d88:	0541                	addi	a0,a0,16
 d8a:	ec7ff0ef          	jal	ra,c50 <free>
  return freep;
 d8e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 d92:	dd61                	beqz	a0,d6a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d94:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 d96:	4798                	lw	a4,8(a5)
 d98:	fa9778e3          	bgeu	a4,s1,d48 <malloc+0x70>
    if(p == freep)
 d9c:	00093703          	ld	a4,0(s2)
 da0:	853e                	mv	a0,a5
 da2:	fef719e3          	bne	a4,a5,d94 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 da6:	8552                	mv	a0,s4
 da8:	9e7ff0ef          	jal	ra,78e <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 dac:	fd551ce3          	bne	a0,s5,d84 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 db0:	4501                	li	a0,0
 db2:	bf65                	j	d6a <malloc+0x92>
