
user/_lazy_bench:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
         (lf_mn==K && lf_mx==K) ? "PASS" : "FAIL");
}

int
main(void)
{
   0:	7131                	addi	sp,sp,-192
   2:	fd06                	sd	ra,184(sp)
   4:	f922                	sd	s0,176(sp)
   6:	f526                	sd	s1,168(sp)
   8:	f14a                	sd	s2,160(sp)
   a:	ed4e                	sd	s3,152(sp)
   c:	e952                	sd	s4,144(sp)
   e:	e556                	sd	s5,136(sp)
  10:	e15a                	sd	s6,128(sp)
  12:	fcde                	sd	s7,120(sp)
  14:	f8e2                	sd	s8,112(sp)
  16:	f4e6                	sd	s9,104(sp)
  18:	f0ea                	sd	s10,96(sp)
  1a:	ecee                	sd	s11,88(sp)
  1c:	0180                	addi	s0,sp,192
  int Ks[] = {0, 32, 64, 128, 256};
  1e:	f6042c23          	sw	zero,-136(s0)
  22:	02000793          	li	a5,32
  26:	f6f42e23          	sw	a5,-132(s0)
  2a:	04000793          	li	a5,64
  2e:	f8f42023          	sw	a5,-128(s0)
  32:	08000793          	li	a5,128
  36:	f8f42223          	sw	a5,-124(s0)
  3a:	10000793          	li	a5,256
  3e:	f8f42423          	sw	a5,-120(s0)
  printf("=== Lazy (demand) allocation benchmark (map %d pages, TRIALS=%d) ===\n",
  42:	4615                	li	a2,5
  44:	10000593          	li	a1,256
  48:	00001517          	auipc	a0,0x1
  4c:	af050513          	addi	a0,a0,-1296 # b38 <malloc+0x11e>
  50:	111000ef          	jal	ra,960 <printf>
         MAPPAGES, TRIALS);
  printf("thesis: allocated pages == TOUCHED pages, not MAPPED pages\n");
  54:	00001517          	auipc	a0,0x1
  58:	b2c50513          	addi	a0,a0,-1236 # b80 <malloc+0x166>
  5c:	105000ef          	jal	ra,960 <printf>
  for(int i = 0; i < 5; i++) run_k(Ks[i]);
  60:	f7840793          	addi	a5,s0,-136
  64:	f6f43023          	sd	a5,-160(s0)
  int lf_mn = 0x7fffffff, lf_mx = 0, ka_mn = 0x7fffffff, ka_mx = 0;
  68:	4d01                	li	s10,0
  6a:	800007b7          	lui	a5,0x80000
  6e:	fff7c793          	not	a5,a5
  72:	f4f43c23          	sd	a5,-168(s0)
    vmstats(&A);
  76:	00001917          	auipc	s2,0x1
  7a:	faa90913          	addi	s2,s2,-86 # 1020 <A>
  7e:	a295                	j	1e2 <main+0x1e2>
    if(p == (char*)-1){ printf("  mmap failed\n"); g_pass = 0; return; }
  80:	00001517          	auipc	a0,0x1
  84:	b4050513          	addi	a0,a0,-1216 # bc0 <malloc+0x1a6>
  88:	0d9000ef          	jal	ra,960 <printf>
  8c:	00001797          	auipc	a5,0x1
  90:	f7478793          	addi	a5,a5,-140 # 1000 <g_pass>
  94:	0007a023          	sw	zero,0(a5)
  98:	aa25                	j	1d0 <main+0x1d0>
  9a:	00070b1b          	sext.w	s6,a4
    munmap(p, MAPPAGES*PG);
  9e:	001005b7          	lui	a1,0x100
  a2:	854e                	mv	a0,s3
  a4:	508000ef          	jal	ra,5ac <munmap>
  for(int t = 0; t < TRIALS; t++){
  a8:	3afd                	addiw	s5,s5,-1
  aa:	0c0a8063          	beqz	s5,16a <main+0x16a>
    vmstats(&A);
  ae:	854a                	mv	a0,s2
  b0:	52c000ef          	jal	ra,5dc <vmstats>
    char *p = (char*)mmap(0, MAPPAGES*PG, PROT_READ|PROT_WRITE, MAP_ANON, 0);
  b4:	876a                	mv	a4,s10
  b6:	4685                	li	a3,1
  b8:	460d                	li	a2,3
  ba:	001005b7          	lui	a1,0x100
  be:	856a                	mv	a0,s10
  c0:	4e4000ef          	jal	ra,5a4 <mmap>
  c4:	89aa                	mv	s3,a0
    if(p == (char*)-1){ printf("  mmap failed\n"); g_pass = 0; return; }
  c6:	57fd                	li	a5,-1
  c8:	faf50ce3          	beq	a0,a5,80 <main+0x80>
    vmstats(&B);
  cc:	00001517          	auipc	a0,0x1
  d0:	f9c50513          	addi	a0,a0,-100 # 1068 <B>
  d4:	508000ef          	jal	ra,5dc <vmstats>
    int map_alloc = (int)(B.kalloc_cnt - A.kalloc_cnt);   // expect ~0 (metadata only)
  d8:	06093783          	ld	a5,96(s2)
  dc:	01893703          	ld	a4,24(s2)
  e0:	9f99                	subw	a5,a5,a4
  e2:	873e                	mv	a4,a5
  e4:	2781                	sext.w	a5,a5
  e6:	0187d363          	bge	a5,s8,ec <main+0xec>
  ea:	8762                	mv	a4,s8
  ec:	00070c1b          	sext.w	s8,a4
    vmstats(&A);
  f0:	854a                	mv	a0,s2
  f2:	4ea000ef          	jal	ra,5dc <vmstats>
    for(int i = 0; i < K; i++) p[i*PG] = 1;               // one write per page
  f6:	01b05d63          	blez	s11,110 <main+0x110>
  fa:	87ce                	mv	a5,s3
  fc:	f6843703          	ld	a4,-152(s0)
 100:	013706b3          	add	a3,a4,s3
 104:	4705                	li	a4,1
 106:	00e78023          	sb	a4,0(a5)
 10a:	97a6                	add	a5,a5,s1
 10c:	fed79de3          	bne	a5,a3,106 <main+0x106>
    vmstats(&B);
 110:	00001517          	auipc	a0,0x1
 114:	f5850513          	addi	a0,a0,-168 # 1068 <B>
 118:	4c4000ef          	jal	ra,5dc <vmstats>
    int lf = (int)(B.lazy_faults - A.lazy_faults);
 11c:	05093703          	ld	a4,80(s2)
 120:	00893783          	ld	a5,8(s2)
 124:	9f1d                	subw	a4,a4,a5
    int ka = (int)(B.kalloc_cnt  - A.kalloc_cnt);
 126:	06093783          	ld	a5,96(s2)
 12a:	01893683          	ld	a3,24(s2)
 12e:	9f95                	subw	a5,a5,a3
    if(lf < lf_mn) lf_mn = lf;
 130:	86ba                	mv	a3,a4
 132:	0007061b          	sext.w	a2,a4
 136:	00ca5363          	bge	s4,a2,13c <main+0x13c>
 13a:	86d2                	mv	a3,s4
 13c:	00068a1b          	sext.w	s4,a3
    if(lf > lf_mx) lf_mx = lf;
 140:	86ba                	mv	a3,a4
 142:	2701                	sext.w	a4,a4
 144:	01775363          	bge	a4,s7,14a <main+0x14a>
 148:	86de                	mv	a3,s7
 14a:	00068b9b          	sext.w	s7,a3
    if(ka < ka_mn) ka_mn = ka;
 14e:	873e                	mv	a4,a5
 150:	0007869b          	sext.w	a3,a5
 154:	00dcd363          	bge	s9,a3,15a <main+0x15a>
 158:	8766                	mv	a4,s9
 15a:	00070c9b          	sext.w	s9,a4
    if(ka > ka_mx) ka_mx = ka;
 15e:	873e                	mv	a4,a5
 160:	2781                	sext.w	a5,a5
 162:	f367dce3          	bge	a5,s6,9a <main+0x9a>
 166:	875a                	mv	a4,s6
 168:	bf0d                	j	9a <main+0x9a>
  chk(lf_mn == K && lf_mx == K, "lazy_faults != K");
 16a:	0b4d8163          	beq	s11,s4,20c <main+0x20c>
  if(!cond){ g_pass = 0; printf("  [FAIL] %s\n", msg); }
 16e:	00001797          	auipc	a5,0x1
 172:	e9278793          	addi	a5,a5,-366 # 1000 <g_pass>
 176:	0007a023          	sw	zero,0(a5)
 17a:	00001597          	auipc	a1,0x1
 17e:	ad658593          	addi	a1,a1,-1322 # c50 <malloc+0x236>
 182:	00001517          	auipc	a0,0x1
 186:	ae650513          	addi	a0,a0,-1306 # c68 <malloc+0x24e>
 18a:	7d6000ef          	jal	ra,960 <printf>
  int pt = ka_mx - K;          // extra pages beyond data = on-demand page-table pages
 18e:	41bb07bb          	subw	a5,s6,s11
  if(pt < 0) pt = 0;
 192:	0007889b          	sext.w	a7,a5
 196:	fff8c893          	not	a7,a7
 19a:	43f8d893          	srai	a7,a7,0x3f
 19e:	0117f7b3          	and	a5,a5,a7
 1a2:	0007889b          	sext.w	a7,a5
  printf("  mapped=%d touched=%d  lazy_faults=%d..%d (data)  kalloc=%d..%d (data+%d ptbl)  map_only_alloc=%d  %s\n",
 1a6:	00001797          	auipc	a5,0x1
 1aa:	95a78793          	addi	a5,a5,-1702 # b00 <malloc+0xe6>
 1ae:	074d8d63          	beq	s11,s4,228 <main+0x228>
 1b2:	e43e                	sd	a5,8(sp)
 1b4:	e062                	sd	s8,0(sp)
 1b6:	885a                	mv	a6,s6
 1b8:	87e6                	mv	a5,s9
 1ba:	875e                	mv	a4,s7
 1bc:	86d2                	mv	a3,s4
 1be:	866e                	mv	a2,s11
 1c0:	10000593          	li	a1,256
 1c4:	00001517          	auipc	a0,0x1
 1c8:	a0c50513          	addi	a0,a0,-1524 # bd0 <malloc+0x1b6>
 1cc:	794000ef          	jal	ra,960 <printf>
  for(int i = 0; i < 5; i++) run_k(Ks[i]);
 1d0:	f6043783          	ld	a5,-160(s0)
 1d4:	0791                	addi	a5,a5,4
 1d6:	f6f43023          	sd	a5,-160(s0)
 1da:	f8c40713          	addi	a4,s0,-116
 1de:	06e78063          	beq	a5,a4,23e <main+0x23e>
 1e2:	f6043783          	ld	a5,-160(s0)
 1e6:	0007ad83          	lw	s11,0(a5)
  for(int t = 0; t < TRIALS; t++){
 1ea:	fffd879b          	addiw	a5,s11,-1
 1ee:	1782                	slli	a5,a5,0x20
 1f0:	9381                	srli	a5,a5,0x20
  for(int i = 0; i < 5; i++) run_k(Ks[i]);
 1f2:	4a95                	li	s5,5
  int lf_mn = 0x7fffffff, lf_mx = 0, ka_mn = 0x7fffffff, ka_mx = 0;
 1f4:	8b6a                	mv	s6,s10
 1f6:	f5843a03          	ld	s4,-168(s0)
 1fa:	8cd2                	mv	s9,s4
 1fc:	8bea                	mv	s7,s10
  int map_alloc_max = 0;        // pages allocated by the bare mmap (must be 0)
 1fe:	8c6a                	mv	s8,s10
 200:	0785                	addi	a5,a5,1
 202:	07b2                	slli	a5,a5,0xc
 204:	f6f43423          	sd	a5,-152(s0)
    for(int i = 0; i < K; i++) p[i*PG] = 1;               // one write per page
 208:	6485                	lui	s1,0x1
 20a:	b555                	j	ae <main+0xae>
  chk(lf_mn == K && lf_mx == K, "lazy_faults != K");
 20c:	f77d91e3          	bne	s11,s7,16e <main+0x16e>
  int pt = ka_mx - K;          // extra pages beyond data = on-demand page-table pages
 210:	41bb07bb          	subw	a5,s6,s11
  if(pt < 0) pt = 0;
 214:	88be                	mv	a7,a5
 216:	2781                	sext.w	a5,a5
 218:	0407c963          	bltz	a5,26a <main+0x26a>
 21c:	2881                	sext.w	a7,a7
  printf("  mapped=%d touched=%d  lazy_faults=%d..%d (data)  kalloc=%d..%d (data+%d ptbl)  map_only_alloc=%d  %s\n",
 21e:	00001797          	auipc	a5,0x1
 222:	8ea78793          	addi	a5,a5,-1814 # b08 <malloc+0xee>
 226:	b771                	j	1b2 <main+0x1b2>
 228:	00001797          	auipc	a5,0x1
 22c:	8d878793          	addi	a5,a5,-1832 # b00 <malloc+0xe6>
         (lf_mn==K && lf_mx==K) ? "PASS" : "FAIL");
 230:	f97d91e3          	bne	s11,s7,1b2 <main+0x1b2>
  printf("  mapped=%d touched=%d  lazy_faults=%d..%d (data)  kalloc=%d..%d (data+%d ptbl)  map_only_alloc=%d  %s\n",
 234:	00001797          	auipc	a5,0x1
 238:	8d478793          	addi	a5,a5,-1836 # b08 <malloc+0xee>
 23c:	bf9d                	j	1b2 <main+0x1b2>
  printf("\n=== OVERALL: %s ===\n", g_pass ? "ALL CHECKS PASS" : "SOME CHECKS FAILED");
 23e:	00001797          	auipc	a5,0x1
 242:	dc27a783          	lw	a5,-574(a5) # 1000 <g_pass>
 246:	00001597          	auipc	a1,0x1
 24a:	8ca58593          	addi	a1,a1,-1846 # b10 <malloc+0xf6>
 24e:	e789                	bnez	a5,258 <main+0x258>
 250:	00001597          	auipc	a1,0x1
 254:	8d058593          	addi	a1,a1,-1840 # b20 <malloc+0x106>
 258:	00001517          	auipc	a0,0x1
 25c:	9e050513          	addi	a0,a0,-1568 # c38 <malloc+0x21e>
 260:	700000ef          	jal	ra,960 <printf>
  exit(0);
 264:	4501                	li	a0,0
 266:	29e000ef          	jal	ra,504 <exit>
 26a:	4881                	li	a7,0
 26c:	bf45                	j	21c <main+0x21c>

000000000000026e <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e406                	sd	ra,8(sp)
 272:	e022                	sd	s0,0(sp)
 274:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 276:	d8bff0ef          	jal	ra,0 <main>
  exit(r);
 27a:	28a000ef          	jal	ra,504 <exit>

000000000000027e <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 284:	87aa                	mv	a5,a0
 286:	0585                	addi	a1,a1,1
 288:	0785                	addi	a5,a5,1
 28a:	fff5c703          	lbu	a4,-1(a1)
 28e:	fee78fa3          	sb	a4,-1(a5)
 292:	fb75                	bnez	a4,286 <strcpy+0x8>
    ;
  return os;
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret

000000000000029a <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	cb91                	beqz	a5,2b8 <strcmp+0x1e>
 2a6:	0005c703          	lbu	a4,0(a1)
 2aa:	00f71763          	bne	a4,a5,2b8 <strcmp+0x1e>
    p++, q++;
 2ae:	0505                	addi	a0,a0,1
 2b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b2:	00054783          	lbu	a5,0(a0)
 2b6:	fbe5                	bnez	a5,2a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b8:	0005c503          	lbu	a0,0(a1)
}
 2bc:	40a7853b          	subw	a0,a5,a0
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2cc:	00054783          	lbu	a5,0(a0)
 2d0:	cf91                	beqz	a5,2ec <strlen+0x26>
 2d2:	0505                	addi	a0,a0,1
 2d4:	87aa                	mv	a5,a0
 2d6:	4685                	li	a3,1
 2d8:	9e89                	subw	a3,a3,a0
 2da:	00f6853b          	addw	a0,a3,a5
 2de:	0785                	addi	a5,a5,1
 2e0:	fff7c703          	lbu	a4,-1(a5)
 2e4:	fb7d                	bnez	a4,2da <strlen+0x14>
    ;
  return n;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  for(n = 0; s[n]; n++)
 2ec:	4501                	li	a0,0
 2ee:	bfe5                	j	2e6 <strlen+0x20>

00000000000002f0 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f6:	ca19                	beqz	a2,30c <memset+0x1c>
 2f8:	87aa                	mv	a5,a0
 2fa:	1602                	slli	a2,a2,0x20
 2fc:	9201                	srli	a2,a2,0x20
 2fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 302:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 306:	0785                	addi	a5,a5,1
 308:	fee79de3          	bne	a5,a4,302 <memset+0x12>
  }
  return dst;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  for(; *s; s++)
 318:	00054783          	lbu	a5,0(a0)
 31c:	cb99                	beqz	a5,332 <strchr+0x20>
    if(*s == c)
 31e:	00f58763          	beq	a1,a5,32c <strchr+0x1a>
  for(; *s; s++)
 322:	0505                	addi	a0,a0,1
 324:	00054783          	lbu	a5,0(a0)
 328:	fbfd                	bnez	a5,31e <strchr+0xc>
      return (char*)s;
  return 0;
 32a:	4501                	li	a0,0
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  return 0;
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <strchr+0x1a>

0000000000000336 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 336:	711d                	addi	sp,sp,-96
 338:	ec86                	sd	ra,88(sp)
 33a:	e8a2                	sd	s0,80(sp)
 33c:	e4a6                	sd	s1,72(sp)
 33e:	e0ca                	sd	s2,64(sp)
 340:	fc4e                	sd	s3,56(sp)
 342:	f852                	sd	s4,48(sp)
 344:	f456                	sd	s5,40(sp)
 346:	f05a                	sd	s6,32(sp)
 348:	ec5e                	sd	s7,24(sp)
 34a:	1080                	addi	s0,sp,96
 34c:	8baa                	mv	s7,a0
 34e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 350:	892a                	mv	s2,a0
 352:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 354:	4aa9                	li	s5,10
 356:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 358:	89a6                	mv	s3,s1
 35a:	2485                	addiw	s1,s1,1
 35c:	0344d663          	bge	s1,s4,388 <gets+0x52>
    cc = read(0, &c, 1);
 360:	4605                	li	a2,1
 362:	faf40593          	addi	a1,s0,-81
 366:	4501                	li	a0,0
 368:	1b4000ef          	jal	ra,51c <read>
    if(cc < 1)
 36c:	00a05e63          	blez	a0,388 <gets+0x52>
    buf[i++] = c;
 370:	faf44783          	lbu	a5,-81(s0)
 374:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 378:	01578763          	beq	a5,s5,386 <gets+0x50>
 37c:	0905                	addi	s2,s2,1
 37e:	fd679de3          	bne	a5,s6,358 <gets+0x22>
  for(i=0; i+1 < max; ){
 382:	89a6                	mv	s3,s1
 384:	a011                	j	388 <gets+0x52>
 386:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 388:	99de                	add	s3,s3,s7
 38a:	00098023          	sb	zero,0(s3)
  return buf;
}
 38e:	855e                	mv	a0,s7
 390:	60e6                	ld	ra,88(sp)
 392:	6446                	ld	s0,80(sp)
 394:	64a6                	ld	s1,72(sp)
 396:	6906                	ld	s2,64(sp)
 398:	79e2                	ld	s3,56(sp)
 39a:	7a42                	ld	s4,48(sp)
 39c:	7aa2                	ld	s5,40(sp)
 39e:	7b02                	ld	s6,32(sp)
 3a0:	6be2                	ld	s7,24(sp)
 3a2:	6125                	addi	sp,sp,96
 3a4:	8082                	ret

00000000000003a6 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 3a6:	1101                	addi	sp,sp,-32
 3a8:	ec06                	sd	ra,24(sp)
 3aa:	e822                	sd	s0,16(sp)
 3ac:	e426                	sd	s1,8(sp)
 3ae:	e04a                	sd	s2,0(sp)
 3b0:	1000                	addi	s0,sp,32
 3b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b4:	4581                	li	a1,0
 3b6:	18e000ef          	jal	ra,544 <open>
  if(fd < 0)
 3ba:	02054163          	bltz	a0,3dc <stat+0x36>
 3be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c0:	85ca                	mv	a1,s2
 3c2:	19a000ef          	jal	ra,55c <fstat>
 3c6:	892a                	mv	s2,a0
  close(fd);
 3c8:	8526                	mv	a0,s1
 3ca:	162000ef          	jal	ra,52c <close>
  return r;
}
 3ce:	854a                	mv	a0,s2
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	64a2                	ld	s1,8(sp)
 3d6:	6902                	ld	s2,0(sp)
 3d8:	6105                	addi	sp,sp,32
 3da:	8082                	ret
    return -1;
 3dc:	597d                	li	s2,-1
 3de:	bfc5                	j	3ce <stat+0x28>

00000000000003e0 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e6:	00054603          	lbu	a2,0(a0)
 3ea:	fd06079b          	addiw	a5,a2,-48
 3ee:	0ff7f793          	andi	a5,a5,255
 3f2:	4725                	li	a4,9
 3f4:	02f76963          	bltu	a4,a5,426 <atoi+0x46>
 3f8:	86aa                	mv	a3,a0
  n = 0;
 3fa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3fc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3fe:	0685                	addi	a3,a3,1
 400:	0025179b          	slliw	a5,a0,0x2
 404:	9fa9                	addw	a5,a5,a0
 406:	0017979b          	slliw	a5,a5,0x1
 40a:	9fb1                	addw	a5,a5,a2
 40c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 410:	0006c603          	lbu	a2,0(a3)
 414:	fd06071b          	addiw	a4,a2,-48
 418:	0ff77713          	andi	a4,a4,255
 41c:	fee5f1e3          	bgeu	a1,a4,3fe <atoi+0x1e>
  return n;
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
  n = 0;
 426:	4501                	li	a0,0
 428:	bfe5                	j	420 <atoi+0x40>

000000000000042a <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 42a:	1141                	addi	sp,sp,-16
 42c:	e422                	sd	s0,8(sp)
 42e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 430:	02b57463          	bgeu	a0,a1,458 <memmove+0x2e>
    while(n-- > 0)
 434:	00c05f63          	blez	a2,452 <memmove+0x28>
 438:	1602                	slli	a2,a2,0x20
 43a:	9201                	srli	a2,a2,0x20
 43c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 440:	872a                	mv	a4,a0
      *dst++ = *src++;
 442:	0585                	addi	a1,a1,1
 444:	0705                	addi	a4,a4,1
 446:	fff5c683          	lbu	a3,-1(a1)
 44a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44e:	fee79ae3          	bne	a5,a4,442 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 452:	6422                	ld	s0,8(sp)
 454:	0141                	addi	sp,sp,16
 456:	8082                	ret
    dst += n;
 458:	00c50733          	add	a4,a0,a2
    src += n;
 45c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45e:	fec05ae3          	blez	a2,452 <memmove+0x28>
 462:	fff6079b          	addiw	a5,a2,-1
 466:	1782                	slli	a5,a5,0x20
 468:	9381                	srli	a5,a5,0x20
 46a:	fff7c793          	not	a5,a5
 46e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 470:	15fd                	addi	a1,a1,-1
 472:	177d                	addi	a4,a4,-1
 474:	0005c683          	lbu	a3,0(a1)
 478:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 47c:	fee79ae3          	bne	a5,a4,470 <memmove+0x46>
 480:	bfc9                	j	452 <memmove+0x28>

0000000000000482 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 482:	1141                	addi	sp,sp,-16
 484:	e422                	sd	s0,8(sp)
 486:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 488:	ca05                	beqz	a2,4b8 <memcmp+0x36>
 48a:	fff6069b          	addiw	a3,a2,-1
 48e:	1682                	slli	a3,a3,0x20
 490:	9281                	srli	a3,a3,0x20
 492:	0685                	addi	a3,a3,1
 494:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 496:	00054783          	lbu	a5,0(a0)
 49a:	0005c703          	lbu	a4,0(a1)
 49e:	00e79863          	bne	a5,a4,4ae <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4a2:	0505                	addi	a0,a0,1
    p2++;
 4a4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a6:	fed518e3          	bne	a0,a3,496 <memcmp+0x14>
  }
  return 0;
 4aa:	4501                	li	a0,0
 4ac:	a019                	j	4b2 <memcmp+0x30>
      return *p1 - *p2;
 4ae:	40e7853b          	subw	a0,a5,a4
}
 4b2:	6422                	ld	s0,8(sp)
 4b4:	0141                	addi	sp,sp,16
 4b6:	8082                	ret
  return 0;
 4b8:	4501                	li	a0,0
 4ba:	bfe5                	j	4b2 <memcmp+0x30>

00000000000004bc <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 4bc:	1141                	addi	sp,sp,-16
 4be:	e406                	sd	ra,8(sp)
 4c0:	e022                	sd	s0,0(sp)
 4c2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c4:	f67ff0ef          	jal	ra,42a <memmove>
}
 4c8:	60a2                	ld	ra,8(sp)
 4ca:	6402                	ld	s0,0(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret

00000000000004d0 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 4d0:	1141                	addi	sp,sp,-16
 4d2:	e406                	sd	ra,8(sp)
 4d4:	e022                	sd	s0,0(sp)
 4d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d8:	4585                	li	a1,1
 4da:	0b2000ef          	jal	ra,58c <sys_sbrk>
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 4e6:	1141                	addi	sp,sp,-16
 4e8:	e406                	sd	ra,8(sp)
 4ea:	e022                	sd	s0,0(sp)
 4ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ee:	4589                	li	a1,2
 4f0:	09c000ef          	jal	ra,58c <sys_sbrk>
}
 4f4:	60a2                	ld	ra,8(sp)
 4f6:	6402                	ld	s0,0(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret

00000000000004fc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4fc:	4885                	li	a7,1
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <exit>:
.global exit
exit:
 li a7, SYS_exit
 504:	4889                	li	a7,2
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <wait>:
.global wait
wait:
 li a7, SYS_wait
 50c:	488d                	li	a7,3
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 514:	4891                	li	a7,4
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <read>:
.global read
read:
 li a7, SYS_read
 51c:	4895                	li	a7,5
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <write>:
.global write
write:
 li a7, SYS_write
 524:	48c1                	li	a7,16
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <close>:
.global close
close:
 li a7, SYS_close
 52c:	48d5                	li	a7,21
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <kill>:
.global kill
kill:
 li a7, SYS_kill
 534:	4899                	li	a7,6
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <exec>:
.global exec
exec:
 li a7, SYS_exec
 53c:	489d                	li	a7,7
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <open>:
.global open
open:
 li a7, SYS_open
 544:	48bd                	li	a7,15
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 54c:	48c5                	li	a7,17
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 554:	48c9                	li	a7,18
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 55c:	48a1                	li	a7,8
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <link>:
.global link
link:
 li a7, SYS_link
 564:	48cd                	li	a7,19
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 56c:	48d1                	li	a7,20
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 574:	48a5                	li	a7,9
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <dup>:
.global dup
dup:
 li a7, SYS_dup
 57c:	48a9                	li	a7,10
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 584:	48ad                	li	a7,11
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 58c:	48b1                	li	a7,12
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <pause>:
.global pause
pause:
 li a7, SYS_pause
 594:	48b5                	li	a7,13
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 59c:	48b9                	li	a7,14
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 5a4:	48d9                	li	a7,22
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 5ac:	48dd                	li	a7,23
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 5b4:	48e1                	li	a7,24
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5bc:	48e5                	li	a7,25
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 5c4:	48e9                	li	a7,26
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 5cc:	48ed                	li	a7,27
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 5d4:	48f1                	li	a7,28
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 5dc:	48f5                	li	a7,29
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 5e4:	1101                	addi	sp,sp,-32
 5e6:	ec06                	sd	ra,24(sp)
 5e8:	e822                	sd	s0,16(sp)
 5ea:	1000                	addi	s0,sp,32
 5ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5f0:	4605                	li	a2,1
 5f2:	fef40593          	addi	a1,s0,-17
 5f6:	f2fff0ef          	jal	ra,524 <write>
}
 5fa:	60e2                	ld	ra,24(sp)
 5fc:	6442                	ld	s0,16(sp)
 5fe:	6105                	addi	sp,sp,32
 600:	8082                	ret

0000000000000602 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 602:	715d                	addi	sp,sp,-80
 604:	e486                	sd	ra,72(sp)
 606:	e0a2                	sd	s0,64(sp)
 608:	fc26                	sd	s1,56(sp)
 60a:	f84a                	sd	s2,48(sp)
 60c:	f44e                	sd	s3,40(sp)
 60e:	0880                	addi	s0,sp,80
 610:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 612:	c299                	beqz	a3,618 <printint+0x16>
 614:	0805c163          	bltz	a1,696 <printint+0x94>
  neg = 0;
 618:	4881                	li	a7,0
 61a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 61e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 620:	00000517          	auipc	a0,0x0
 624:	66050513          	addi	a0,a0,1632 # c80 <digits>
 628:	883e                	mv	a6,a5
 62a:	2785                	addiw	a5,a5,1
 62c:	02c5f733          	remu	a4,a1,a2
 630:	972a                	add	a4,a4,a0
 632:	00074703          	lbu	a4,0(a4)
 636:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 63a:	872e                	mv	a4,a1
 63c:	02c5d5b3          	divu	a1,a1,a2
 640:	0685                	addi	a3,a3,1
 642:	fec773e3          	bgeu	a4,a2,628 <printint+0x26>
  if(neg)
 646:	00088b63          	beqz	a7,65c <printint+0x5a>
    buf[i++] = '-';
 64a:	fd040713          	addi	a4,s0,-48
 64e:	97ba                	add	a5,a5,a4
 650:	02d00713          	li	a4,45
 654:	fee78423          	sb	a4,-24(a5)
 658:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 65c:	02f05663          	blez	a5,688 <printint+0x86>
 660:	fb840713          	addi	a4,s0,-72
 664:	00f704b3          	add	s1,a4,a5
 668:	fff70993          	addi	s3,a4,-1
 66c:	99be                	add	s3,s3,a5
 66e:	37fd                	addiw	a5,a5,-1
 670:	1782                	slli	a5,a5,0x20
 672:	9381                	srli	a5,a5,0x20
 674:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 678:	fff4c583          	lbu	a1,-1(s1) # fff <digits+0x37f>
 67c:	854a                	mv	a0,s2
 67e:	f67ff0ef          	jal	ra,5e4 <putc>
  while(--i >= 0)
 682:	14fd                	addi	s1,s1,-1
 684:	ff349ae3          	bne	s1,s3,678 <printint+0x76>
}
 688:	60a6                	ld	ra,72(sp)
 68a:	6406                	ld	s0,64(sp)
 68c:	74e2                	ld	s1,56(sp)
 68e:	7942                	ld	s2,48(sp)
 690:	79a2                	ld	s3,40(sp)
 692:	6161                	addi	sp,sp,80
 694:	8082                	ret
    x = -xx;
 696:	40b005b3          	neg	a1,a1
    neg = 1;
 69a:	4885                	li	a7,1
    x = -xx;
 69c:	bfbd                	j	61a <printint+0x18>

000000000000069e <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 69e:	7119                	addi	sp,sp,-128
 6a0:	fc86                	sd	ra,120(sp)
 6a2:	f8a2                	sd	s0,112(sp)
 6a4:	f4a6                	sd	s1,104(sp)
 6a6:	f0ca                	sd	s2,96(sp)
 6a8:	ecce                	sd	s3,88(sp)
 6aa:	e8d2                	sd	s4,80(sp)
 6ac:	e4d6                	sd	s5,72(sp)
 6ae:	e0da                	sd	s6,64(sp)
 6b0:	fc5e                	sd	s7,56(sp)
 6b2:	f862                	sd	s8,48(sp)
 6b4:	f466                	sd	s9,40(sp)
 6b6:	f06a                	sd	s10,32(sp)
 6b8:	ec6e                	sd	s11,24(sp)
 6ba:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6bc:	0005c903          	lbu	s2,0(a1)
 6c0:	24090c63          	beqz	s2,918 <vprintf+0x27a>
 6c4:	8b2a                	mv	s6,a0
 6c6:	8a2e                	mv	s4,a1
 6c8:	8bb2                	mv	s7,a2
  state = 0;
 6ca:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6cc:	4481                	li	s1,0
 6ce:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6d0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6d4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6d8:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6dc:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e0:	00000c97          	auipc	s9,0x0
 6e4:	5a0c8c93          	addi	s9,s9,1440 # c80 <digits>
 6e8:	a005                	j	708 <vprintf+0x6a>
        putc(fd, c0);
 6ea:	85ca                	mv	a1,s2
 6ec:	855a                	mv	a0,s6
 6ee:	ef7ff0ef          	jal	ra,5e4 <putc>
 6f2:	a019                	j	6f8 <vprintf+0x5a>
    } else if(state == '%'){
 6f4:	03598263          	beq	s3,s5,718 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6f8:	2485                	addiw	s1,s1,1
 6fa:	8726                	mv	a4,s1
 6fc:	009a07b3          	add	a5,s4,s1
 700:	0007c903          	lbu	s2,0(a5)
 704:	20090a63          	beqz	s2,918 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 708:	0009079b          	sext.w	a5,s2
    if(state == 0){
 70c:	fe0994e3          	bnez	s3,6f4 <vprintf+0x56>
      if(c0 == '%'){
 710:	fd579de3          	bne	a5,s5,6ea <vprintf+0x4c>
        state = '%';
 714:	89be                	mv	s3,a5
 716:	b7cd                	j	6f8 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 718:	c3c1                	beqz	a5,798 <vprintf+0xfa>
 71a:	00ea06b3          	add	a3,s4,a4
 71e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 722:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 724:	c681                	beqz	a3,72c <vprintf+0x8e>
 726:	9752                	add	a4,a4,s4
 728:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 72c:	03878e63          	beq	a5,s8,768 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 730:	05a78863          	beq	a5,s10,780 <vprintf+0xe2>
      } else if(c0 == 'u'){
 734:	0db78b63          	beq	a5,s11,80a <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 738:	07800713          	li	a4,120
 73c:	10e78d63          	beq	a5,a4,856 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 740:	07000713          	li	a4,112
 744:	14e78263          	beq	a5,a4,888 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 748:	06300713          	li	a4,99
 74c:	16e78f63          	beq	a5,a4,8ca <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 750:	07300713          	li	a4,115
 754:	18e78563          	beq	a5,a4,8de <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 758:	05579063          	bne	a5,s5,798 <vprintf+0xfa>
        putc(fd, '%');
 75c:	85d6                	mv	a1,s5
 75e:	855a                	mv	a0,s6
 760:	e85ff0ef          	jal	ra,5e4 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 764:	4981                	li	s3,0
 766:	bf49                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 768:	008b8913          	addi	s2,s7,8
 76c:	4685                	li	a3,1
 76e:	4629                	li	a2,10
 770:	000ba583          	lw	a1,0(s7)
 774:	855a                	mv	a0,s6
 776:	e8dff0ef          	jal	ra,602 <printint>
 77a:	8bca                	mv	s7,s2
      state = 0;
 77c:	4981                	li	s3,0
 77e:	bfad                	j	6f8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 780:	03868663          	beq	a3,s8,7ac <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 784:	05a68163          	beq	a3,s10,7c6 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 788:	09b68d63          	beq	a3,s11,822 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 78c:	03a68f63          	beq	a3,s10,7ca <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 790:	07800793          	li	a5,120
 794:	0cf68d63          	beq	a3,a5,86e <vprintf+0x1d0>
        putc(fd, '%');
 798:	85d6                	mv	a1,s5
 79a:	855a                	mv	a0,s6
 79c:	e49ff0ef          	jal	ra,5e4 <putc>
        putc(fd, c0);
 7a0:	85ca                	mv	a1,s2
 7a2:	855a                	mv	a0,s6
 7a4:	e41ff0ef          	jal	ra,5e4 <putc>
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b7b9                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ac:	008b8913          	addi	s2,s7,8
 7b0:	4685                	li	a3,1
 7b2:	4629                	li	a2,10
 7b4:	000bb583          	ld	a1,0(s7)
 7b8:	855a                	mv	a0,s6
 7ba:	e49ff0ef          	jal	ra,602 <printint>
        i += 1;
 7be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7c0:	8bca                	mv	s7,s2
      state = 0;
 7c2:	4981                	li	s3,0
        i += 1;
 7c4:	bf15                	j	6f8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7c6:	03860563          	beq	a2,s8,7f0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7ca:	07b60963          	beq	a2,s11,83c <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7ce:	07800793          	li	a5,120
 7d2:	fcf613e3          	bne	a2,a5,798 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d6:	008b8913          	addi	s2,s7,8
 7da:	4681                	li	a3,0
 7dc:	4641                	li	a2,16
 7de:	000bb583          	ld	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	e1fff0ef          	jal	ra,602 <printint>
        i += 2;
 7e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ea:	8bca                	mv	s7,s2
      state = 0;
 7ec:	4981                	li	s3,0
        i += 2;
 7ee:	b729                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7f0:	008b8913          	addi	s2,s7,8
 7f4:	4685                	li	a3,1
 7f6:	4629                	li	a2,10
 7f8:	000bb583          	ld	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	e05ff0ef          	jal	ra,602 <printint>
        i += 2;
 802:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 804:	8bca                	mv	s7,s2
      state = 0;
 806:	4981                	li	s3,0
        i += 2;
 808:	bdc5                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 80a:	008b8913          	addi	s2,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000be583          	lwu	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	debff0ef          	jal	ra,602 <printint>
 81c:	8bca                	mv	s7,s2
      state = 0;
 81e:	4981                	li	s3,0
 820:	bde1                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 822:	008b8913          	addi	s2,s7,8
 826:	4681                	li	a3,0
 828:	4629                	li	a2,10
 82a:	000bb583          	ld	a1,0(s7)
 82e:	855a                	mv	a0,s6
 830:	dd3ff0ef          	jal	ra,602 <printint>
        i += 1;
 834:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 836:	8bca                	mv	s7,s2
      state = 0;
 838:	4981                	li	s3,0
        i += 1;
 83a:	bd7d                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 83c:	008b8913          	addi	s2,s7,8
 840:	4681                	li	a3,0
 842:	4629                	li	a2,10
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	db9ff0ef          	jal	ra,602 <printint>
        i += 2;
 84e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
        i += 2;
 854:	b555                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 856:	008b8913          	addi	s2,s7,8
 85a:	4681                	li	a3,0
 85c:	4641                	li	a2,16
 85e:	000be583          	lwu	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	d9fff0ef          	jal	ra,602 <printint>
 868:	8bca                	mv	s7,s2
      state = 0;
 86a:	4981                	li	s3,0
 86c:	b571                	j	6f8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 86e:	008b8913          	addi	s2,s7,8
 872:	4681                	li	a3,0
 874:	4641                	li	a2,16
 876:	000bb583          	ld	a1,0(s7)
 87a:	855a                	mv	a0,s6
 87c:	d87ff0ef          	jal	ra,602 <printint>
        i += 1;
 880:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 882:	8bca                	mv	s7,s2
      state = 0;
 884:	4981                	li	s3,0
        i += 1;
 886:	bd8d                	j	6f8 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 888:	008b8793          	addi	a5,s7,8
 88c:	f8f43423          	sd	a5,-120(s0)
 890:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 894:	03000593          	li	a1,48
 898:	855a                	mv	a0,s6
 89a:	d4bff0ef          	jal	ra,5e4 <putc>
  putc(fd, 'x');
 89e:	07800593          	li	a1,120
 8a2:	855a                	mv	a0,s6
 8a4:	d41ff0ef          	jal	ra,5e4 <putc>
 8a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8aa:	03c9d793          	srli	a5,s3,0x3c
 8ae:	97e6                	add	a5,a5,s9
 8b0:	0007c583          	lbu	a1,0(a5)
 8b4:	855a                	mv	a0,s6
 8b6:	d2fff0ef          	jal	ra,5e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8ba:	0992                	slli	s3,s3,0x4
 8bc:	397d                	addiw	s2,s2,-1
 8be:	fe0916e3          	bnez	s2,8aa <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 8c2:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 8c6:	4981                	li	s3,0
 8c8:	bd05                	j	6f8 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 8ca:	008b8913          	addi	s2,s7,8
 8ce:	000bc583          	lbu	a1,0(s7)
 8d2:	855a                	mv	a0,s6
 8d4:	d11ff0ef          	jal	ra,5e4 <putc>
 8d8:	8bca                	mv	s7,s2
      state = 0;
 8da:	4981                	li	s3,0
 8dc:	bd31                	j	6f8 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 8de:	008b8993          	addi	s3,s7,8
 8e2:	000bb903          	ld	s2,0(s7)
 8e6:	00090f63          	beqz	s2,904 <vprintf+0x266>
        for(; *s; s++)
 8ea:	00094583          	lbu	a1,0(s2)
 8ee:	c195                	beqz	a1,912 <vprintf+0x274>
          putc(fd, *s);
 8f0:	855a                	mv	a0,s6
 8f2:	cf3ff0ef          	jal	ra,5e4 <putc>
        for(; *s; s++)
 8f6:	0905                	addi	s2,s2,1
 8f8:	00094583          	lbu	a1,0(s2)
 8fc:	f9f5                	bnez	a1,8f0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8fe:	8bce                	mv	s7,s3
      state = 0;
 900:	4981                	li	s3,0
 902:	bbdd                	j	6f8 <vprintf+0x5a>
          s = "(null)";
 904:	00000917          	auipc	s2,0x0
 908:	37490913          	addi	s2,s2,884 # c78 <malloc+0x25e>
        for(; *s; s++)
 90c:	02800593          	li	a1,40
 910:	b7c5                	j	8f0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 912:	8bce                	mv	s7,s3
      state = 0;
 914:	4981                	li	s3,0
 916:	b3cd                	j	6f8 <vprintf+0x5a>
    }
  }
}
 918:	70e6                	ld	ra,120(sp)
 91a:	7446                	ld	s0,112(sp)
 91c:	74a6                	ld	s1,104(sp)
 91e:	7906                	ld	s2,96(sp)
 920:	69e6                	ld	s3,88(sp)
 922:	6a46                	ld	s4,80(sp)
 924:	6aa6                	ld	s5,72(sp)
 926:	6b06                	ld	s6,64(sp)
 928:	7be2                	ld	s7,56(sp)
 92a:	7c42                	ld	s8,48(sp)
 92c:	7ca2                	ld	s9,40(sp)
 92e:	7d02                	ld	s10,32(sp)
 930:	6de2                	ld	s11,24(sp)
 932:	6109                	addi	sp,sp,128
 934:	8082                	ret

0000000000000936 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 936:	715d                	addi	sp,sp,-80
 938:	ec06                	sd	ra,24(sp)
 93a:	e822                	sd	s0,16(sp)
 93c:	1000                	addi	s0,sp,32
 93e:	e010                	sd	a2,0(s0)
 940:	e414                	sd	a3,8(s0)
 942:	e818                	sd	a4,16(s0)
 944:	ec1c                	sd	a5,24(s0)
 946:	03043023          	sd	a6,32(s0)
 94a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 94e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 952:	8622                	mv	a2,s0
 954:	d4bff0ef          	jal	ra,69e <vprintf>
}
 958:	60e2                	ld	ra,24(sp)
 95a:	6442                	ld	s0,16(sp)
 95c:	6161                	addi	sp,sp,80
 95e:	8082                	ret

0000000000000960 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 960:	711d                	addi	sp,sp,-96
 962:	ec06                	sd	ra,24(sp)
 964:	e822                	sd	s0,16(sp)
 966:	1000                	addi	s0,sp,32
 968:	e40c                	sd	a1,8(s0)
 96a:	e810                	sd	a2,16(s0)
 96c:	ec14                	sd	a3,24(s0)
 96e:	f018                	sd	a4,32(s0)
 970:	f41c                	sd	a5,40(s0)
 972:	03043823          	sd	a6,48(s0)
 976:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 97a:	00840613          	addi	a2,s0,8
 97e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 982:	85aa                	mv	a1,a0
 984:	4505                	li	a0,1
 986:	d19ff0ef          	jal	ra,69e <vprintf>
}
 98a:	60e2                	ld	ra,24(sp)
 98c:	6442                	ld	s0,16(sp)
 98e:	6125                	addi	sp,sp,96
 990:	8082                	ret

0000000000000992 <free>:
 *   无
 */

void
free(void *ap)
{
 992:	1141                	addi	sp,sp,-16
 994:	e422                	sd	s0,8(sp)
 996:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 998:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99c:	00000797          	auipc	a5,0x0
 9a0:	6747b783          	ld	a5,1652(a5) # 1010 <freep>
 9a4:	a805                	j	9d4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a6:	4618                	lw	a4,8(a2)
 9a8:	9db9                	addw	a1,a1,a4
 9aa:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ae:	6398                	ld	a4,0(a5)
 9b0:	6318                	ld	a4,0(a4)
 9b2:	fee53823          	sd	a4,-16(a0)
 9b6:	a091                	j	9fa <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b8:	ff852703          	lw	a4,-8(a0)
 9bc:	9e39                	addw	a2,a2,a4
 9be:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9c0:	ff053703          	ld	a4,-16(a0)
 9c4:	e398                	sd	a4,0(a5)
 9c6:	a099                	j	a0c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c8:	6398                	ld	a4,0(a5)
 9ca:	00e7e463          	bltu	a5,a4,9d2 <free+0x40>
 9ce:	00e6ea63          	bltu	a3,a4,9e2 <free+0x50>
{
 9d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d4:	fed7fae3          	bgeu	a5,a3,9c8 <free+0x36>
 9d8:	6398                	ld	a4,0(a5)
 9da:	00e6e463          	bltu	a3,a4,9e2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9de:	fee7eae3          	bltu	a5,a4,9d2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9e2:	ff852583          	lw	a1,-8(a0)
 9e6:	6390                	ld	a2,0(a5)
 9e8:	02059713          	slli	a4,a1,0x20
 9ec:	9301                	srli	a4,a4,0x20
 9ee:	0712                	slli	a4,a4,0x4
 9f0:	9736                	add	a4,a4,a3
 9f2:	fae60ae3          	beq	a2,a4,9a6 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9fa:	4790                	lw	a2,8(a5)
 9fc:	02061713          	slli	a4,a2,0x20
 a00:	9301                	srli	a4,a4,0x20
 a02:	0712                	slli	a4,a4,0x4
 a04:	973e                	add	a4,a4,a5
 a06:	fae689e3          	beq	a3,a4,9b8 <free+0x26>
  } else
    p->s.ptr = bp;
 a0a:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 a0c:	00000717          	auipc	a4,0x0
 a10:	60f73223          	sd	a5,1540(a4) # 1010 <freep>
}
 a14:	6422                	ld	s0,8(sp)
 a16:	0141                	addi	sp,sp,16
 a18:	8082                	ret

0000000000000a1a <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 a1a:	7139                	addi	sp,sp,-64
 a1c:	fc06                	sd	ra,56(sp)
 a1e:	f822                	sd	s0,48(sp)
 a20:	f426                	sd	s1,40(sp)
 a22:	f04a                	sd	s2,32(sp)
 a24:	ec4e                	sd	s3,24(sp)
 a26:	e852                	sd	s4,16(sp)
 a28:	e456                	sd	s5,8(sp)
 a2a:	e05a                	sd	s6,0(sp)
 a2c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a2e:	02051493          	slli	s1,a0,0x20
 a32:	9081                	srli	s1,s1,0x20
 a34:	04bd                	addi	s1,s1,15
 a36:	8091                	srli	s1,s1,0x4
 a38:	0014899b          	addiw	s3,s1,1
 a3c:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 a3e:	00000517          	auipc	a0,0x0
 a42:	5d253503          	ld	a0,1490(a0) # 1010 <freep>
 a46:	c515                	beqz	a0,a72 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a48:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 a4a:	4798                	lw	a4,8(a5)
 a4c:	02977f63          	bgeu	a4,s1,a8a <malloc+0x70>
 a50:	8a4e                	mv	s4,s3
 a52:	0009871b          	sext.w	a4,s3
 a56:	6685                	lui	a3,0x1
 a58:	00d77363          	bgeu	a4,a3,a5e <malloc+0x44>
 a5c:	6a05                	lui	s4,0x1
 a5e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 a62:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 a66:	00000917          	auipc	s2,0x0
 a6a:	5aa90913          	addi	s2,s2,1450 # 1010 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 a6e:	5afd                	li	s5,-1
 a70:	a0bd                	j	ade <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 a72:	00000797          	auipc	a5,0x0
 a76:	63e78793          	addi	a5,a5,1598 # 10b0 <base>
 a7a:	00000717          	auipc	a4,0x0
 a7e:	58f73b23          	sd	a5,1430(a4) # 1010 <freep>
 a82:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a84:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 a88:	b7e1                	j	a50 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 a8a:	02e48b63          	beq	s1,a4,ac0 <malloc+0xa6>
        p->s.size -= nunits;
 a8e:	4137073b          	subw	a4,a4,s3
 a92:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a94:	1702                	slli	a4,a4,0x20
 a96:	9301                	srli	a4,a4,0x20
 a98:	0712                	slli	a4,a4,0x4
 a9a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a9c:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 aa0:	00000717          	auipc	a4,0x0
 aa4:	56a73823          	sd	a0,1392(a4) # 1010 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 aa8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 aac:	70e2                	ld	ra,56(sp)
 aae:	7442                	ld	s0,48(sp)
 ab0:	74a2                	ld	s1,40(sp)
 ab2:	7902                	ld	s2,32(sp)
 ab4:	69e2                	ld	s3,24(sp)
 ab6:	6a42                	ld	s4,16(sp)
 ab8:	6aa2                	ld	s5,8(sp)
 aba:	6b02                	ld	s6,0(sp)
 abc:	6121                	addi	sp,sp,64
 abe:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ac0:	6398                	ld	a4,0(a5)
 ac2:	e118                	sd	a4,0(a0)
 ac4:	bff1                	j	aa0 <malloc+0x86>
  hp->s.size = nu;
 ac6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 aca:	0541                	addi	a0,a0,16
 acc:	ec7ff0ef          	jal	ra,992 <free>
  return freep;
 ad0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ad4:	dd61                	beqz	a0,aac <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 ad8:	4798                	lw	a4,8(a5)
 ada:	fa9778e3          	bgeu	a4,s1,a8a <malloc+0x70>
    if(p == freep)
 ade:	00093703          	ld	a4,0(s2)
 ae2:	853e                	mv	a0,a5
 ae4:	fef719e3          	bne	a4,a5,ad6 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 ae8:	8552                	mv	a0,s4
 aea:	9e7ff0ef          	jal	ra,4d0 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 aee:	fd551ce3          	bne	a0,s5,ac6 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 af2:	4501                	li	a0,0
 af4:	bf65                	j	aac <malloc+0x92>
