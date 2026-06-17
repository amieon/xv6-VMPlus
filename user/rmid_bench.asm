
user/_rmid_bench:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <chk>:

static struct vmstats_user A;
static int g_pass = 1;

static void chk(int cond, char *msg)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(cond) { printf("  [PASS] %s\n", msg); }
   8:	c919                	beqz	a0,1e <chk+0x1e>
   a:	00001517          	auipc	a0,0x1
   e:	b8650513          	addi	a0,a0,-1146 # b90 <malloc+0xe6>
  12:	1df000ef          	jal	ra,9f0 <printf>
  else     { printf("  [FAIL] %s\n", msg); g_pass = 0; }
}
  16:	60a2                	ld	ra,8(sp)
  18:	6402                	ld	s0,0(sp)
  1a:	0141                	addi	sp,sp,16
  1c:	8082                	ret
  else     { printf("  [FAIL] %s\n", msg); g_pass = 0; }
  1e:	00001517          	auipc	a0,0x1
  22:	b8250513          	addi	a0,a0,-1150 # ba0 <malloc+0xf6>
  26:	1cb000ef          	jal	ra,9f0 <printf>
  2a:	00001797          	auipc	a5,0x1
  2e:	fc07ab23          	sw	zero,-42(a5) # 1000 <g_pass>
}
  32:	b7d5                	j	16 <chk+0x16>

0000000000000034 <main>:

static uint64 freed(void) { vmstats(&A); return A.kfree_cnt; }

int
main(void)
{
  34:	7139                	addi	sp,sp,-64
  36:	fc06                	sd	ra,56(sp)
  38:	f822                	sd	s0,48(sp)
  3a:	f426                	sd	s1,40(sp)
  3c:	f04a                	sd	s2,32(sp)
  3e:	ec4e                	sd	s3,24(sp)
  40:	e852                	sd	s4,16(sp)
  42:	e456                	sd	s5,8(sp)
  44:	0080                	addi	s0,sp,64
  sem_open(S_CHILD, 0);
  46:	4581                	li	a1,0
  48:	19000513          	li	a0,400
  4c:	608000ef          	jal	ra,654 <sem_open>
  sem_open(S_PARENT, 0);
  50:	4581                	li	a1,0
  52:	19100513          	li	a0,401
  56:	5fe000ef          	jal	ra,654 <sem_open>

  // Parent attaches first and fills a known pattern.
  char *p = (char*)mmap(0, NPAGES*PG, PROT_READ|PROT_WRITE,
  5a:	03700713          	li	a4,55
  5e:	468d                	li	a3,3
  60:	460d                	li	a2,3
  62:	65a1                	lui	a1,0x8
  64:	4501                	li	a0,0
  66:	5ce000ef          	jal	ra,634 <mmap>
                        MAP_ANON|MAP_SHARED, KEY);
  if(p == (char*)-1){ printf("parent mmap failed\n"); exit(1); }
  6a:	57fd                	li	a5,-1
  6c:	04f50663          	beq	a0,a5,b8 <main+0x84>
  70:	892a                	mv	s2,a0
  72:	84aa                	mv	s1,a0
  74:	872a                	mv	a4,a0
  76:	0a000793          	li	a5,160
  for(int i = 0; i < NPAGES; i++) p[i*PG] = (char)(0xA0 + i);
  7a:	6605                	lui	a2,0x1
  7c:	0a800693          	li	a3,168
  80:	00f70023          	sb	a5,0(a4)
  84:	2785                	addiw	a5,a5,1
  86:	0ff7f793          	andi	a5,a5,255
  8a:	9732                	add	a4,a4,a2
  8c:	fed79ae3          	bne	a5,a3,80 <main+0x4c>

  printf("=== IPC_RMID deferred-reclamation test (NPAGES=%d) ===\n", NPAGES);
  90:	45a1                	li	a1,8
  92:	00001517          	auipc	a0,0x1
  96:	b6e50513          	addi	a0,a0,-1170 # c00 <malloc+0x156>
  9a:	157000ef          	jal	ra,9f0 <printf>

  int pid = fork();
  9e:	4ee000ef          	jal	ra,58c <fork>
  a2:	89aa                	mv	s3,a0
  if(pid == 0){
  a4:	0e051363          	bnez	a0,18a <main+0x156>
  a8:	874a                	mv	a4,s2
  aa:	0a000793          	li	a5,160
    // ---- child: shares the parent's mapping via fork (same address p),
    //      exactly like ipcbench -- a SINGLE reference, no second mmap. ----
    int ok = 1;
  ae:	4a05                	li	s4,1
    for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok = 0;
  b0:	6585                	lui	a1,0x1
  b2:	0a800613          	li	a2,168
  b6:	a005                	j	d6 <main+0xa2>
  if(p == (char*)-1){ printf("parent mmap failed\n"); exit(1); }
  b8:	00001517          	auipc	a0,0x1
  bc:	b3050513          	addi	a0,a0,-1232 # be8 <malloc+0x13e>
  c0:	131000ef          	jal	ra,9f0 <printf>
  c4:	4505                	li	a0,1
  c6:	4ce000ef          	jal	ra,594 <exit>
    for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok = 0;
  ca:	972e                	add	a4,a4,a1
  cc:	2785                	addiw	a5,a5,1
  ce:	0ff7f793          	andi	a5,a5,255
  d2:	00c78863          	beq	a5,a2,e2 <main+0xae>
  d6:	00074683          	lbu	a3,0(a4)
  da:	fef688e3          	beq	a3,a5,ca <main+0x96>
  de:	8a2a                	mv	s4,a0
  e0:	b7ed                	j	ca <main+0x96>
    if(!ok) printf("  [FAIL] child did not see parent's data\n");
  e2:	020a0363          	beqz	s4,108 <main+0xd4>

    sem_post(S_CHILD);          // tell parent: I'm attached + verified
  e6:	19000513          	li	a0,400
  ea:	57a000ef          	jal	ra,664 <sem_post>
    sem_wait(S_PARENT);         // wait until parent has done RMID
  ee:	19100513          	li	a0,401
  f2:	56a000ef          	jal	ra,65c <sem_wait>
  f6:	874a                	mv	a4,s2
  f8:	0a000793          	li	a5,160

    // A2 (child side): after RMID, an already-attached process still works.
    int ok2 = 1;
  fc:	4a85                	li	s5,1
    for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok2 = 0; // read
  fe:	854e                	mv	a0,s3
 100:	6585                	lui	a1,0x1
 102:	0a800613          	li	a2,168
 106:	a831                	j	122 <main+0xee>
    if(!ok) printf("  [FAIL] child did not see parent's data\n");
 108:	00001517          	auipc	a0,0x1
 10c:	b3050513          	addi	a0,a0,-1232 # c38 <malloc+0x18e>
 110:	0e1000ef          	jal	ra,9f0 <printf>
 114:	bfc9                	j	e6 <main+0xb2>
    for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok2 = 0; // read
 116:	972e                	add	a4,a4,a1
 118:	2785                	addiw	a5,a5,1
 11a:	0ff7f793          	andi	a5,a5,255
 11e:	00c78863          	beq	a5,a2,12e <main+0xfa>
 122:	00074683          	lbu	a3,0(a4)
 126:	fef688e3          	beq	a3,a5,116 <main+0xe2>
 12a:	8aaa                	mv	s5,a0
 12c:	b7ed                	j	116 <main+0xe2>
 12e:	05000793          	li	a5,80
    for(int i = 0; i < NPAGES; i++) p[i*PG] = (char)(0x50 + i);              // write
 132:	6685                	lui	a3,0x1
 134:	05800713          	li	a4,88
 138:	00f48023          	sb	a5,0(s1)
 13c:	2785                	addiw	a5,a5,1
 13e:	0ff7f793          	andi	a5,a5,255
 142:	94b6                	add	s1,s1,a3
 144:	fee79ae3          	bne	a5,a4,138 <main+0x104>
    if(!ok2) printf("  [FAIL] child lost access to data after RMID\n");
 148:	000a8f63          	beqz	s5,166 <main+0x132>

    munmap(p, NPAGES*PG);       // child detaches its single (inherited) reference
 14c:	65a1                	lui	a1,0x8
 14e:	854a                	mv	a0,s2
 150:	4ec000ef          	jal	ra,63c <munmap>
    sem_post(S_CHILD);          // tell parent: I've detached
 154:	19000513          	li	a0,400
 158:	50c000ef          	jal	ra,664 <sem_post>
    exit(ok && ok2 ? 0 : 1);
 15c:	020a0563          	beqz	s4,186 <main+0x152>
 160:	854e                	mv	a0,s3
 162:	432000ef          	jal	ra,594 <exit>
    if(!ok2) printf("  [FAIL] child lost access to data after RMID\n");
 166:	00001517          	auipc	a0,0x1
 16a:	b0250513          	addi	a0,a0,-1278 # c68 <malloc+0x1be>
 16e:	083000ef          	jal	ra,9f0 <printf>
    munmap(p, NPAGES*PG);       // child detaches its single (inherited) reference
 172:	65a1                	lui	a1,0x8
 174:	854a                	mv	a0,s2
 176:	4c6000ef          	jal	ra,63c <munmap>
    sem_post(S_CHILD);          // tell parent: I've detached
 17a:	19000513          	li	a0,400
 17e:	4e6000ef          	jal	ra,664 <sem_post>
    exit(ok && ok2 ? 0 : 1);
 182:	4985                	li	s3,1
 184:	bff1                	j	160 <main+0x12c>
 186:	89d6                	mv	s3,s5
 188:	bfe1                	j	160 <main+0x12c>
  }

  // ---- parent ----
  sem_wait(S_CHILD);            // wait until child is attached + verified
 18a:	19000513          	li	a0,400
 18e:	4ce000ef          	jal	ra,65c <sem_wait>

  // A1: mark for deletion, then a brand-new attach of the same key must fail.
  shmctl(KEY, IPC_RMID);
 192:	4581                	li	a1,0
 194:	03700513          	li	a0,55
 198:	4ac000ef          	jal	ra,644 <shmctl>
  char *late = (char*)mmap(0, NPAGES*PG, PROT_READ|PROT_WRITE,
 19c:	03700713          	li	a4,55
 1a0:	468d                	li	a3,3
 1a2:	460d                	li	a2,3
 1a4:	65a1                	lui	a1,0x8
 1a6:	4501                	li	a0,0
 1a8:	48c000ef          	jal	ra,634 <mmap>
 1ac:	89aa                	mv	s3,a0
                           MAP_ANON|MAP_SHARED, KEY);
  chk(late == (char*)-1, "A1: attach after RMID is rejected");
 1ae:	0505                	addi	a0,a0,1
 1b0:	00001597          	auipc	a1,0x1
 1b4:	ae858593          	addi	a1,a1,-1304 # c98 <malloc+0x1ee>
 1b8:	00153513          	seqz	a0,a0
 1bc:	e45ff0ef          	jal	ra,0 <chk>
  if(late != (char*)-1) munmap(late, NPAGES*PG);
 1c0:	57fd                	li	a5,-1
 1c2:	00f98663          	beq	s3,a5,1ce <main+0x19a>
 1c6:	65a1                	lui	a1,0x8
 1c8:	854e                	mv	a0,s3
 1ca:	472000ef          	jal	ra,63c <munmap>
static uint64 freed(void) { vmstats(&A); return A.kfree_cnt; }
 1ce:	00001997          	auipc	s3,0x1
 1d2:	e5298993          	addi	s3,s3,-430 # 1020 <A>
 1d6:	854e                	mv	a0,s3
 1d8:	494000ef          	jal	ra,66c <vmstats>
 1dc:	0409b983          	ld	s3,64(s3)
 1e0:	874a                	mv	a4,s2
 1e2:	0a000793          	li	a5,160

  // A2 (parent side): pages still alive & correct after RMID, with refs remaining.
  uint64 f0 = freed();
  int ok = 1;
 1e6:	4505                	li	a0,1
  for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0xA0 + i)) ok = 0;
 1e8:	4801                	li	a6,0
 1ea:	6585                	lui	a1,0x1
 1ec:	0a800613          	li	a2,168
 1f0:	a039                	j	1fe <main+0x1ca>
 1f2:	972e                	add	a4,a4,a1
 1f4:	2785                	addiw	a5,a5,1
 1f6:	0ff7f793          	andi	a5,a5,255
 1fa:	00c78863          	beq	a5,a2,20a <main+0x1d6>
 1fe:	00074683          	lbu	a3,0(a4)
 202:	fef688e3          	beq	a3,a5,1f2 <main+0x1be>
 206:	8542                	mv	a0,a6
 208:	b7ed                	j	1f2 <main+0x1be>
  chk(ok, "A2: parent still reads correct data after RMID");
 20a:	00001597          	auipc	a1,0x1
 20e:	ab658593          	addi	a1,a1,-1354 # cc0 <malloc+0x216>
 212:	defff0ef          	jal	ra,0 <chk>

  sem_post(S_PARENT);           // let child do its post-RMID access + detach
 216:	19100513          	li	a0,401
 21a:	44a000ef          	jal	ra,664 <sem_post>
  sem_wait(S_CHILD);            // wait until child has detached
 21e:	19000513          	li	a0,400
 222:	43a000ef          	jal	ra,65c <sem_wait>
static uint64 freed(void) { vmstats(&A); return A.kfree_cnt; }
 226:	00001a17          	auipc	s4,0x1
 22a:	dfaa0a13          	addi	s4,s4,-518 # 1020 <A>
 22e:	8552                	mv	a0,s4
 230:	43c000ef          	jal	ra,66c <vmstats>

  // Child detached but parent still holds a reference: pages must NOT be freed yet.
  uint64 f1 = freed();
  chk((int)(f1 - f0) == 0, "A2: pages NOT reclaimed while parent still attached");
 234:	040a2503          	lw	a0,64(s4)
 238:	2981                	sext.w	s3,s3
 23a:	41350533          	sub	a0,a0,s3
 23e:	00001597          	auipc	a1,0x1
 242:	ab258593          	addi	a1,a1,-1358 # cf0 <malloc+0x246>
 246:	00153513          	seqz	a0,a0
 24a:	db7ff0ef          	jal	ra,0 <chk>
 24e:	05000793          	li	a5,80

  // parent reads the child's post-RMID writes (proves shared pages stayed live)
  int ok3 = 1;
 252:	4505                	li	a0,1
  for(int i = 0; i < NPAGES; i++) if(p[i*PG] != (char)(0x50 + i)) ok3 = 0;
 254:	4581                	li	a1,0
 256:	6605                	lui	a2,0x1
 258:	05800693          	li	a3,88
 25c:	a039                	j	26a <main+0x236>
 25e:	94b2                	add	s1,s1,a2
 260:	2785                	addiw	a5,a5,1
 262:	0ff7f793          	andi	a5,a5,255
 266:	00d78863          	beq	a5,a3,276 <main+0x242>
 26a:	0004c703          	lbu	a4,0(s1)
 26e:	fef708e3          	beq	a4,a5,25e <main+0x22a>
 272:	852e                	mv	a0,a1
 274:	b7ed                	j	25e <main+0x22a>
  chk(ok3, "A2: parent sees child's post-RMID writes (pages stayed live)");
 276:	00001597          	auipc	a1,0x1
 27a:	ab258593          	addi	a1,a1,-1358 # d28 <malloc+0x27e>
 27e:	d83ff0ef          	jal	ra,0 <chk>

  // A3: parent is the last reference -> detaching it must reclaim the data pages.
  wait(0);                      // reap child FIRST: guarantee its reference is gone
 282:	4501                	li	a0,0
 284:	318000ef          	jal	ra,59c <wait>
static uint64 freed(void) { vmstats(&A); return A.kfree_cnt; }
 288:	00001997          	auipc	s3,0x1
 28c:	d9898993          	addi	s3,s3,-616 # 1020 <A>
 290:	854e                	mv	a0,s3
 292:	3da000ef          	jal	ra,66c <vmstats>
 296:	0409ba03          	ld	s4,64(s3)
  uint64 f2 = freed();
  munmap(p, NPAGES*PG);
 29a:	65a1                	lui	a1,0x8
 29c:	854a                	mv	a0,s2
 29e:	39e000ef          	jal	ra,63c <munmap>
static uint64 freed(void) { vmstats(&A); return A.kfree_cnt; }
 2a2:	854e                	mv	a0,s3
 2a4:	3c8000ef          	jal	ra,66c <vmstats>
  uint64 f3 = freed();
  int reclaimed = (int)(f3 - f2);
 2a8:	0409b483          	ld	s1,64(s3)
 2ac:	414484bb          	subw	s1,s1,s4
  chk(reclaimed >= NPAGES, "A3: last detach reclaims the data pages");
 2b0:	00001597          	auipc	a1,0x1
 2b4:	ab858593          	addi	a1,a1,-1352 # d68 <malloc+0x2be>
 2b8:	451d                	li	a0,7
 2ba:	00952533          	slt	a0,a0,s1
 2be:	d43ff0ef          	jal	ra,0 <chk>
  printf("  (pages freed at last detach = %d, expected >= %d data pages)\n",
 2c2:	4621                	li	a2,8
 2c4:	85a6                	mv	a1,s1
 2c6:	00001517          	auipc	a0,0x1
 2ca:	aca50513          	addi	a0,a0,-1334 # d90 <malloc+0x2e6>
 2ce:	722000ef          	jal	ra,9f0 <printf>
         reclaimed, NPAGES);

  printf("\n=== OVERALL: %s ===\n", g_pass ? "ALL RMID SEMANTICS VERIFIED" : "SOME CHECKS FAILED");
 2d2:	00001797          	auipc	a5,0x1
 2d6:	d2e7a783          	lw	a5,-722(a5) # 1000 <g_pass>
 2da:	00001597          	auipc	a1,0x1
 2de:	8d658593          	addi	a1,a1,-1834 # bb0 <malloc+0x106>
 2e2:	e789                	bnez	a5,2ec <main+0x2b8>
 2e4:	00001597          	auipc	a1,0x1
 2e8:	8ec58593          	addi	a1,a1,-1812 # bd0 <malloc+0x126>
 2ec:	00001517          	auipc	a0,0x1
 2f0:	ae450513          	addi	a0,a0,-1308 # dd0 <malloc+0x326>
 2f4:	6fc000ef          	jal	ra,9f0 <printf>
  exit(0);
 2f8:	4501                	li	a0,0
 2fa:	29a000ef          	jal	ra,594 <exit>

00000000000002fe <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 306:	d2fff0ef          	jal	ra,34 <main>
  exit(r);
 30a:	28a000ef          	jal	ra,594 <exit>

000000000000030e <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 314:	87aa                	mv	a5,a0
 316:	0585                	addi	a1,a1,1
 318:	0785                	addi	a5,a5,1
 31a:	fff5c703          	lbu	a4,-1(a1)
 31e:	fee78fa3          	sb	a4,-1(a5)
 322:	fb75                	bnez	a4,316 <strcpy+0x8>
    ;
  return os;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret

000000000000032a <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 330:	00054783          	lbu	a5,0(a0)
 334:	cb91                	beqz	a5,348 <strcmp+0x1e>
 336:	0005c703          	lbu	a4,0(a1)
 33a:	00f71763          	bne	a4,a5,348 <strcmp+0x1e>
    p++, q++;
 33e:	0505                	addi	a0,a0,1
 340:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 342:	00054783          	lbu	a5,0(a0)
 346:	fbe5                	bnez	a5,336 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 348:	0005c503          	lbu	a0,0(a1)
}
 34c:	40a7853b          	subw	a0,a5,a0
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 356:	1141                	addi	sp,sp,-16
 358:	e422                	sd	s0,8(sp)
 35a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 35c:	00054783          	lbu	a5,0(a0)
 360:	cf91                	beqz	a5,37c <strlen+0x26>
 362:	0505                	addi	a0,a0,1
 364:	87aa                	mv	a5,a0
 366:	4685                	li	a3,1
 368:	9e89                	subw	a3,a3,a0
 36a:	00f6853b          	addw	a0,a3,a5
 36e:	0785                	addi	a5,a5,1
 370:	fff7c703          	lbu	a4,-1(a5)
 374:	fb7d                	bnez	a4,36a <strlen+0x14>
    ;
  return n;
}
 376:	6422                	ld	s0,8(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret
  for(n = 0; s[n]; n++)
 37c:	4501                	li	a0,0
 37e:	bfe5                	j	376 <strlen+0x20>

0000000000000380 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 386:	ca19                	beqz	a2,39c <memset+0x1c>
 388:	87aa                	mv	a5,a0
 38a:	1602                	slli	a2,a2,0x20
 38c:	9201                	srli	a2,a2,0x20
 38e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 392:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 396:	0785                	addi	a5,a5,1
 398:	fee79de3          	bne	a5,a4,392 <memset+0x12>
  }
  return dst;
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret

00000000000003a2 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e422                	sd	s0,8(sp)
 3a6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3a8:	00054783          	lbu	a5,0(a0)
 3ac:	cb99                	beqz	a5,3c2 <strchr+0x20>
    if(*s == c)
 3ae:	00f58763          	beq	a1,a5,3bc <strchr+0x1a>
  for(; *s; s++)
 3b2:	0505                	addi	a0,a0,1
 3b4:	00054783          	lbu	a5,0(a0)
 3b8:	fbfd                	bnez	a5,3ae <strchr+0xc>
      return (char*)s;
  return 0;
 3ba:	4501                	li	a0,0
}
 3bc:	6422                	ld	s0,8(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret
  return 0;
 3c2:	4501                	li	a0,0
 3c4:	bfe5                	j	3bc <strchr+0x1a>

00000000000003c6 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 3c6:	711d                	addi	sp,sp,-96
 3c8:	ec86                	sd	ra,88(sp)
 3ca:	e8a2                	sd	s0,80(sp)
 3cc:	e4a6                	sd	s1,72(sp)
 3ce:	e0ca                	sd	s2,64(sp)
 3d0:	fc4e                	sd	s3,56(sp)
 3d2:	f852                	sd	s4,48(sp)
 3d4:	f456                	sd	s5,40(sp)
 3d6:	f05a                	sd	s6,32(sp)
 3d8:	ec5e                	sd	s7,24(sp)
 3da:	1080                	addi	s0,sp,96
 3dc:	8baa                	mv	s7,a0
 3de:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e0:	892a                	mv	s2,a0
 3e2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3e4:	4aa9                	li	s5,10
 3e6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3e8:	89a6                	mv	s3,s1
 3ea:	2485                	addiw	s1,s1,1
 3ec:	0344d663          	bge	s1,s4,418 <gets+0x52>
    cc = read(0, &c, 1);
 3f0:	4605                	li	a2,1
 3f2:	faf40593          	addi	a1,s0,-81
 3f6:	4501                	li	a0,0
 3f8:	1b4000ef          	jal	ra,5ac <read>
    if(cc < 1)
 3fc:	00a05e63          	blez	a0,418 <gets+0x52>
    buf[i++] = c;
 400:	faf44783          	lbu	a5,-81(s0)
 404:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 408:	01578763          	beq	a5,s5,416 <gets+0x50>
 40c:	0905                	addi	s2,s2,1
 40e:	fd679de3          	bne	a5,s6,3e8 <gets+0x22>
  for(i=0; i+1 < max; ){
 412:	89a6                	mv	s3,s1
 414:	a011                	j	418 <gets+0x52>
 416:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 418:	99de                	add	s3,s3,s7
 41a:	00098023          	sb	zero,0(s3)
  return buf;
}
 41e:	855e                	mv	a0,s7
 420:	60e6                	ld	ra,88(sp)
 422:	6446                	ld	s0,80(sp)
 424:	64a6                	ld	s1,72(sp)
 426:	6906                	ld	s2,64(sp)
 428:	79e2                	ld	s3,56(sp)
 42a:	7a42                	ld	s4,48(sp)
 42c:	7aa2                	ld	s5,40(sp)
 42e:	7b02                	ld	s6,32(sp)
 430:	6be2                	ld	s7,24(sp)
 432:	6125                	addi	sp,sp,96
 434:	8082                	ret

0000000000000436 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 436:	1101                	addi	sp,sp,-32
 438:	ec06                	sd	ra,24(sp)
 43a:	e822                	sd	s0,16(sp)
 43c:	e426                	sd	s1,8(sp)
 43e:	e04a                	sd	s2,0(sp)
 440:	1000                	addi	s0,sp,32
 442:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 444:	4581                	li	a1,0
 446:	18e000ef          	jal	ra,5d4 <open>
  if(fd < 0)
 44a:	02054163          	bltz	a0,46c <stat+0x36>
 44e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 450:	85ca                	mv	a1,s2
 452:	19a000ef          	jal	ra,5ec <fstat>
 456:	892a                	mv	s2,a0
  close(fd);
 458:	8526                	mv	a0,s1
 45a:	162000ef          	jal	ra,5bc <close>
  return r;
}
 45e:	854a                	mv	a0,s2
 460:	60e2                	ld	ra,24(sp)
 462:	6442                	ld	s0,16(sp)
 464:	64a2                	ld	s1,8(sp)
 466:	6902                	ld	s2,0(sp)
 468:	6105                	addi	sp,sp,32
 46a:	8082                	ret
    return -1;
 46c:	597d                	li	s2,-1
 46e:	bfc5                	j	45e <stat+0x28>

0000000000000470 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 470:	1141                	addi	sp,sp,-16
 472:	e422                	sd	s0,8(sp)
 474:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 476:	00054603          	lbu	a2,0(a0)
 47a:	fd06079b          	addiw	a5,a2,-48
 47e:	0ff7f793          	andi	a5,a5,255
 482:	4725                	li	a4,9
 484:	02f76963          	bltu	a4,a5,4b6 <atoi+0x46>
 488:	86aa                	mv	a3,a0
  n = 0;
 48a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 48c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 48e:	0685                	addi	a3,a3,1
 490:	0025179b          	slliw	a5,a0,0x2
 494:	9fa9                	addw	a5,a5,a0
 496:	0017979b          	slliw	a5,a5,0x1
 49a:	9fb1                	addw	a5,a5,a2
 49c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4a0:	0006c603          	lbu	a2,0(a3) # 1000 <g_pass>
 4a4:	fd06071b          	addiw	a4,a2,-48
 4a8:	0ff77713          	andi	a4,a4,255
 4ac:	fee5f1e3          	bgeu	a1,a4,48e <atoi+0x1e>
  return n;
}
 4b0:	6422                	ld	s0,8(sp)
 4b2:	0141                	addi	sp,sp,16
 4b4:	8082                	ret
  n = 0;
 4b6:	4501                	li	a0,0
 4b8:	bfe5                	j	4b0 <atoi+0x40>

00000000000004ba <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e422                	sd	s0,8(sp)
 4be:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4c0:	02b57463          	bgeu	a0,a1,4e8 <memmove+0x2e>
    while(n-- > 0)
 4c4:	00c05f63          	blez	a2,4e2 <memmove+0x28>
 4c8:	1602                	slli	a2,a2,0x20
 4ca:	9201                	srli	a2,a2,0x20
 4cc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4d0:	872a                	mv	a4,a0
      *dst++ = *src++;
 4d2:	0585                	addi	a1,a1,1
 4d4:	0705                	addi	a4,a4,1
 4d6:	fff5c683          	lbu	a3,-1(a1)
 4da:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4de:	fee79ae3          	bne	a5,a4,4d2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4e2:	6422                	ld	s0,8(sp)
 4e4:	0141                	addi	sp,sp,16
 4e6:	8082                	ret
    dst += n;
 4e8:	00c50733          	add	a4,a0,a2
    src += n;
 4ec:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4ee:	fec05ae3          	blez	a2,4e2 <memmove+0x28>
 4f2:	fff6079b          	addiw	a5,a2,-1
 4f6:	1782                	slli	a5,a5,0x20
 4f8:	9381                	srli	a5,a5,0x20
 4fa:	fff7c793          	not	a5,a5
 4fe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 500:	15fd                	addi	a1,a1,-1
 502:	177d                	addi	a4,a4,-1
 504:	0005c683          	lbu	a3,0(a1)
 508:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 50c:	fee79ae3          	bne	a5,a4,500 <memmove+0x46>
 510:	bfc9                	j	4e2 <memmove+0x28>

0000000000000512 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 512:	1141                	addi	sp,sp,-16
 514:	e422                	sd	s0,8(sp)
 516:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 518:	ca05                	beqz	a2,548 <memcmp+0x36>
 51a:	fff6069b          	addiw	a3,a2,-1
 51e:	1682                	slli	a3,a3,0x20
 520:	9281                	srli	a3,a3,0x20
 522:	0685                	addi	a3,a3,1
 524:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 526:	00054783          	lbu	a5,0(a0)
 52a:	0005c703          	lbu	a4,0(a1)
 52e:	00e79863          	bne	a5,a4,53e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 532:	0505                	addi	a0,a0,1
    p2++;
 534:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 536:	fed518e3          	bne	a0,a3,526 <memcmp+0x14>
  }
  return 0;
 53a:	4501                	li	a0,0
 53c:	a019                	j	542 <memcmp+0x30>
      return *p1 - *p2;
 53e:	40e7853b          	subw	a0,a5,a4
}
 542:	6422                	ld	s0,8(sp)
 544:	0141                	addi	sp,sp,16
 546:	8082                	ret
  return 0;
 548:	4501                	li	a0,0
 54a:	bfe5                	j	542 <memcmp+0x30>

000000000000054c <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 54c:	1141                	addi	sp,sp,-16
 54e:	e406                	sd	ra,8(sp)
 550:	e022                	sd	s0,0(sp)
 552:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 554:	f67ff0ef          	jal	ra,4ba <memmove>
}
 558:	60a2                	ld	ra,8(sp)
 55a:	6402                	ld	s0,0(sp)
 55c:	0141                	addi	sp,sp,16
 55e:	8082                	ret

0000000000000560 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 560:	1141                	addi	sp,sp,-16
 562:	e406                	sd	ra,8(sp)
 564:	e022                	sd	s0,0(sp)
 566:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 568:	4585                	li	a1,1
 56a:	0b2000ef          	jal	ra,61c <sys_sbrk>
}
 56e:	60a2                	ld	ra,8(sp)
 570:	6402                	ld	s0,0(sp)
 572:	0141                	addi	sp,sp,16
 574:	8082                	ret

0000000000000576 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 576:	1141                	addi	sp,sp,-16
 578:	e406                	sd	ra,8(sp)
 57a:	e022                	sd	s0,0(sp)
 57c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 57e:	4589                	li	a1,2
 580:	09c000ef          	jal	ra,61c <sys_sbrk>
}
 584:	60a2                	ld	ra,8(sp)
 586:	6402                	ld	s0,0(sp)
 588:	0141                	addi	sp,sp,16
 58a:	8082                	ret

000000000000058c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 58c:	4885                	li	a7,1
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <exit>:
.global exit
exit:
 li a7, SYS_exit
 594:	4889                	li	a7,2
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <wait>:
.global wait
wait:
 li a7, SYS_wait
 59c:	488d                	li	a7,3
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5a4:	4891                	li	a7,4
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <read>:
.global read
read:
 li a7, SYS_read
 5ac:	4895                	li	a7,5
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <write>:
.global write
write:
 li a7, SYS_write
 5b4:	48c1                	li	a7,16
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <close>:
.global close
close:
 li a7, SYS_close
 5bc:	48d5                	li	a7,21
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5c4:	4899                	li	a7,6
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <exec>:
.global exec
exec:
 li a7, SYS_exec
 5cc:	489d                	li	a7,7
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <open>:
.global open
open:
 li a7, SYS_open
 5d4:	48bd                	li	a7,15
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5dc:	48c5                	li	a7,17
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5e4:	48c9                	li	a7,18
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5ec:	48a1                	li	a7,8
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <link>:
.global link
link:
 li a7, SYS_link
 5f4:	48cd                	li	a7,19
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5fc:	48d1                	li	a7,20
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 604:	48a5                	li	a7,9
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <dup>:
.global dup
dup:
 li a7, SYS_dup
 60c:	48a9                	li	a7,10
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 614:	48ad                	li	a7,11
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 61c:	48b1                	li	a7,12
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <pause>:
.global pause
pause:
 li a7, SYS_pause
 624:	48b5                	li	a7,13
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 62c:	48b9                	li	a7,14
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 634:	48d9                	li	a7,22
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 63c:	48dd                	li	a7,23
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 644:	48e1                	li	a7,24
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 64c:	48e5                	li	a7,25
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 654:	48e9                	li	a7,26
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 65c:	48ed                	li	a7,27
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 664:	48f1                	li	a7,28
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 66c:	48f5                	li	a7,29
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 674:	1101                	addi	sp,sp,-32
 676:	ec06                	sd	ra,24(sp)
 678:	e822                	sd	s0,16(sp)
 67a:	1000                	addi	s0,sp,32
 67c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 680:	4605                	li	a2,1
 682:	fef40593          	addi	a1,s0,-17
 686:	f2fff0ef          	jal	ra,5b4 <write>
}
 68a:	60e2                	ld	ra,24(sp)
 68c:	6442                	ld	s0,16(sp)
 68e:	6105                	addi	sp,sp,32
 690:	8082                	ret

0000000000000692 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 692:	715d                	addi	sp,sp,-80
 694:	e486                	sd	ra,72(sp)
 696:	e0a2                	sd	s0,64(sp)
 698:	fc26                	sd	s1,56(sp)
 69a:	f84a                	sd	s2,48(sp)
 69c:	f44e                	sd	s3,40(sp)
 69e:	0880                	addi	s0,sp,80
 6a0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 6a2:	c299                	beqz	a3,6a8 <printint+0x16>
 6a4:	0805c163          	bltz	a1,726 <printint+0x94>
  neg = 0;
 6a8:	4881                	li	a7,0
 6aa:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6ae:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 6b0:	00000517          	auipc	a0,0x0
 6b4:	74050513          	addi	a0,a0,1856 # df0 <digits>
 6b8:	883e                	mv	a6,a5
 6ba:	2785                	addiw	a5,a5,1
 6bc:	02c5f733          	remu	a4,a1,a2
 6c0:	972a                	add	a4,a4,a0
 6c2:	00074703          	lbu	a4,0(a4)
 6c6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6ca:	872e                	mv	a4,a1
 6cc:	02c5d5b3          	divu	a1,a1,a2
 6d0:	0685                	addi	a3,a3,1
 6d2:	fec773e3          	bgeu	a4,a2,6b8 <printint+0x26>
  if(neg)
 6d6:	00088b63          	beqz	a7,6ec <printint+0x5a>
    buf[i++] = '-';
 6da:	fd040713          	addi	a4,s0,-48
 6de:	97ba                	add	a5,a5,a4
 6e0:	02d00713          	li	a4,45
 6e4:	fee78423          	sb	a4,-24(a5)
 6e8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 6ec:	02f05663          	blez	a5,718 <printint+0x86>
 6f0:	fb840713          	addi	a4,s0,-72
 6f4:	00f704b3          	add	s1,a4,a5
 6f8:	fff70993          	addi	s3,a4,-1
 6fc:	99be                	add	s3,s3,a5
 6fe:	37fd                	addiw	a5,a5,-1
 700:	1782                	slli	a5,a5,0x20
 702:	9381                	srli	a5,a5,0x20
 704:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 708:	fff4c583          	lbu	a1,-1(s1)
 70c:	854a                	mv	a0,s2
 70e:	f67ff0ef          	jal	ra,674 <putc>
  while(--i >= 0)
 712:	14fd                	addi	s1,s1,-1
 714:	ff349ae3          	bne	s1,s3,708 <printint+0x76>
}
 718:	60a6                	ld	ra,72(sp)
 71a:	6406                	ld	s0,64(sp)
 71c:	74e2                	ld	s1,56(sp)
 71e:	7942                	ld	s2,48(sp)
 720:	79a2                	ld	s3,40(sp)
 722:	6161                	addi	sp,sp,80
 724:	8082                	ret
    x = -xx;
 726:	40b005b3          	neg	a1,a1
    neg = 1;
 72a:	4885                	li	a7,1
    x = -xx;
 72c:	bfbd                	j	6aa <printint+0x18>

000000000000072e <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 72e:	7119                	addi	sp,sp,-128
 730:	fc86                	sd	ra,120(sp)
 732:	f8a2                	sd	s0,112(sp)
 734:	f4a6                	sd	s1,104(sp)
 736:	f0ca                	sd	s2,96(sp)
 738:	ecce                	sd	s3,88(sp)
 73a:	e8d2                	sd	s4,80(sp)
 73c:	e4d6                	sd	s5,72(sp)
 73e:	e0da                	sd	s6,64(sp)
 740:	fc5e                	sd	s7,56(sp)
 742:	f862                	sd	s8,48(sp)
 744:	f466                	sd	s9,40(sp)
 746:	f06a                	sd	s10,32(sp)
 748:	ec6e                	sd	s11,24(sp)
 74a:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 74c:	0005c903          	lbu	s2,0(a1)
 750:	24090c63          	beqz	s2,9a8 <vprintf+0x27a>
 754:	8b2a                	mv	s6,a0
 756:	8a2e                	mv	s4,a1
 758:	8bb2                	mv	s7,a2
  state = 0;
 75a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 75c:	4481                	li	s1,0
 75e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 760:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 764:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 768:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 76c:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 770:	00000c97          	auipc	s9,0x0
 774:	680c8c93          	addi	s9,s9,1664 # df0 <digits>
 778:	a005                	j	798 <vprintf+0x6a>
        putc(fd, c0);
 77a:	85ca                	mv	a1,s2
 77c:	855a                	mv	a0,s6
 77e:	ef7ff0ef          	jal	ra,674 <putc>
 782:	a019                	j	788 <vprintf+0x5a>
    } else if(state == '%'){
 784:	03598263          	beq	s3,s5,7a8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 788:	2485                	addiw	s1,s1,1
 78a:	8726                	mv	a4,s1
 78c:	009a07b3          	add	a5,s4,s1
 790:	0007c903          	lbu	s2,0(a5)
 794:	20090a63          	beqz	s2,9a8 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 798:	0009079b          	sext.w	a5,s2
    if(state == 0){
 79c:	fe0994e3          	bnez	s3,784 <vprintf+0x56>
      if(c0 == '%'){
 7a0:	fd579de3          	bne	a5,s5,77a <vprintf+0x4c>
        state = '%';
 7a4:	89be                	mv	s3,a5
 7a6:	b7cd                	j	788 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 7a8:	c3c1                	beqz	a5,828 <vprintf+0xfa>
 7aa:	00ea06b3          	add	a3,s4,a4
 7ae:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7b2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 7b4:	c681                	beqz	a3,7bc <vprintf+0x8e>
 7b6:	9752                	add	a4,a4,s4
 7b8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 7bc:	03878e63          	beq	a5,s8,7f8 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 7c0:	05a78863          	beq	a5,s10,810 <vprintf+0xe2>
      } else if(c0 == 'u'){
 7c4:	0db78b63          	beq	a5,s11,89a <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7c8:	07800713          	li	a4,120
 7cc:	10e78d63          	beq	a5,a4,8e6 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7d0:	07000713          	li	a4,112
 7d4:	14e78263          	beq	a5,a4,918 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7d8:	06300713          	li	a4,99
 7dc:	16e78f63          	beq	a5,a4,95a <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 7e0:	07300713          	li	a4,115
 7e4:	18e78563          	beq	a5,a4,96e <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7e8:	05579063          	bne	a5,s5,828 <vprintf+0xfa>
        putc(fd, '%');
 7ec:	85d6                	mv	a1,s5
 7ee:	855a                	mv	a0,s6
 7f0:	e85ff0ef          	jal	ra,674 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	bf49                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 7f8:	008b8913          	addi	s2,s7,8
 7fc:	4685                	li	a3,1
 7fe:	4629                	li	a2,10
 800:	000ba583          	lw	a1,0(s7)
 804:	855a                	mv	a0,s6
 806:	e8dff0ef          	jal	ra,692 <printint>
 80a:	8bca                	mv	s7,s2
      state = 0;
 80c:	4981                	li	s3,0
 80e:	bfad                	j	788 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 810:	03868663          	beq	a3,s8,83c <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 814:	05a68163          	beq	a3,s10,856 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 818:	09b68d63          	beq	a3,s11,8b2 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 81c:	03a68f63          	beq	a3,s10,85a <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 820:	07800793          	li	a5,120
 824:	0cf68d63          	beq	a3,a5,8fe <vprintf+0x1d0>
        putc(fd, '%');
 828:	85d6                	mv	a1,s5
 82a:	855a                	mv	a0,s6
 82c:	e49ff0ef          	jal	ra,674 <putc>
        putc(fd, c0);
 830:	85ca                	mv	a1,s2
 832:	855a                	mv	a0,s6
 834:	e41ff0ef          	jal	ra,674 <putc>
      state = 0;
 838:	4981                	li	s3,0
 83a:	b7b9                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 83c:	008b8913          	addi	s2,s7,8
 840:	4685                	li	a3,1
 842:	4629                	li	a2,10
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	e49ff0ef          	jal	ra,692 <printint>
        i += 1;
 84e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
        i += 1;
 854:	bf15                	j	788 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 856:	03860563          	beq	a2,s8,880 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 85a:	07b60963          	beq	a2,s11,8cc <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 85e:	07800793          	li	a5,120
 862:	fcf613e3          	bne	a2,a5,828 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 866:	008b8913          	addi	s2,s7,8
 86a:	4681                	li	a3,0
 86c:	4641                	li	a2,16
 86e:	000bb583          	ld	a1,0(s7)
 872:	855a                	mv	a0,s6
 874:	e1fff0ef          	jal	ra,692 <printint>
        i += 2;
 878:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 87a:	8bca                	mv	s7,s2
      state = 0;
 87c:	4981                	li	s3,0
        i += 2;
 87e:	b729                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 880:	008b8913          	addi	s2,s7,8
 884:	4685                	li	a3,1
 886:	4629                	li	a2,10
 888:	000bb583          	ld	a1,0(s7)
 88c:	855a                	mv	a0,s6
 88e:	e05ff0ef          	jal	ra,692 <printint>
        i += 2;
 892:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 894:	8bca                	mv	s7,s2
      state = 0;
 896:	4981                	li	s3,0
        i += 2;
 898:	bdc5                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 89a:	008b8913          	addi	s2,s7,8
 89e:	4681                	li	a3,0
 8a0:	4629                	li	a2,10
 8a2:	000be583          	lwu	a1,0(s7)
 8a6:	855a                	mv	a0,s6
 8a8:	debff0ef          	jal	ra,692 <printint>
 8ac:	8bca                	mv	s7,s2
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bde1                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b2:	008b8913          	addi	s2,s7,8
 8b6:	4681                	li	a3,0
 8b8:	4629                	li	a2,10
 8ba:	000bb583          	ld	a1,0(s7)
 8be:	855a                	mv	a0,s6
 8c0:	dd3ff0ef          	jal	ra,692 <printint>
        i += 1;
 8c4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8c6:	8bca                	mv	s7,s2
      state = 0;
 8c8:	4981                	li	s3,0
        i += 1;
 8ca:	bd7d                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8cc:	008b8913          	addi	s2,s7,8
 8d0:	4681                	li	a3,0
 8d2:	4629                	li	a2,10
 8d4:	000bb583          	ld	a1,0(s7)
 8d8:	855a                	mv	a0,s6
 8da:	db9ff0ef          	jal	ra,692 <printint>
        i += 2;
 8de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8e0:	8bca                	mv	s7,s2
      state = 0;
 8e2:	4981                	li	s3,0
        i += 2;
 8e4:	b555                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8e6:	008b8913          	addi	s2,s7,8
 8ea:	4681                	li	a3,0
 8ec:	4641                	li	a2,16
 8ee:	000be583          	lwu	a1,0(s7)
 8f2:	855a                	mv	a0,s6
 8f4:	d9fff0ef          	jal	ra,692 <printint>
 8f8:	8bca                	mv	s7,s2
      state = 0;
 8fa:	4981                	li	s3,0
 8fc:	b571                	j	788 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8fe:	008b8913          	addi	s2,s7,8
 902:	4681                	li	a3,0
 904:	4641                	li	a2,16
 906:	000bb583          	ld	a1,0(s7)
 90a:	855a                	mv	a0,s6
 90c:	d87ff0ef          	jal	ra,692 <printint>
        i += 1;
 910:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 912:	8bca                	mv	s7,s2
      state = 0;
 914:	4981                	li	s3,0
        i += 1;
 916:	bd8d                	j	788 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 918:	008b8793          	addi	a5,s7,8
 91c:	f8f43423          	sd	a5,-120(s0)
 920:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 924:	03000593          	li	a1,48
 928:	855a                	mv	a0,s6
 92a:	d4bff0ef          	jal	ra,674 <putc>
  putc(fd, 'x');
 92e:	07800593          	li	a1,120
 932:	855a                	mv	a0,s6
 934:	d41ff0ef          	jal	ra,674 <putc>
 938:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 93a:	03c9d793          	srli	a5,s3,0x3c
 93e:	97e6                	add	a5,a5,s9
 940:	0007c583          	lbu	a1,0(a5)
 944:	855a                	mv	a0,s6
 946:	d2fff0ef          	jal	ra,674 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 94a:	0992                	slli	s3,s3,0x4
 94c:	397d                	addiw	s2,s2,-1
 94e:	fe0916e3          	bnez	s2,93a <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 952:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 956:	4981                	li	s3,0
 958:	bd05                	j	788 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 95a:	008b8913          	addi	s2,s7,8
 95e:	000bc583          	lbu	a1,0(s7)
 962:	855a                	mv	a0,s6
 964:	d11ff0ef          	jal	ra,674 <putc>
 968:	8bca                	mv	s7,s2
      state = 0;
 96a:	4981                	li	s3,0
 96c:	bd31                	j	788 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 96e:	008b8993          	addi	s3,s7,8
 972:	000bb903          	ld	s2,0(s7)
 976:	00090f63          	beqz	s2,994 <vprintf+0x266>
        for(; *s; s++)
 97a:	00094583          	lbu	a1,0(s2)
 97e:	c195                	beqz	a1,9a2 <vprintf+0x274>
          putc(fd, *s);
 980:	855a                	mv	a0,s6
 982:	cf3ff0ef          	jal	ra,674 <putc>
        for(; *s; s++)
 986:	0905                	addi	s2,s2,1
 988:	00094583          	lbu	a1,0(s2)
 98c:	f9f5                	bnez	a1,980 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 98e:	8bce                	mv	s7,s3
      state = 0;
 990:	4981                	li	s3,0
 992:	bbdd                	j	788 <vprintf+0x5a>
          s = "(null)";
 994:	00000917          	auipc	s2,0x0
 998:	45490913          	addi	s2,s2,1108 # de8 <malloc+0x33e>
        for(; *s; s++)
 99c:	02800593          	li	a1,40
 9a0:	b7c5                	j	980 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 9a2:	8bce                	mv	s7,s3
      state = 0;
 9a4:	4981                	li	s3,0
 9a6:	b3cd                	j	788 <vprintf+0x5a>
    }
  }
}
 9a8:	70e6                	ld	ra,120(sp)
 9aa:	7446                	ld	s0,112(sp)
 9ac:	74a6                	ld	s1,104(sp)
 9ae:	7906                	ld	s2,96(sp)
 9b0:	69e6                	ld	s3,88(sp)
 9b2:	6a46                	ld	s4,80(sp)
 9b4:	6aa6                	ld	s5,72(sp)
 9b6:	6b06                	ld	s6,64(sp)
 9b8:	7be2                	ld	s7,56(sp)
 9ba:	7c42                	ld	s8,48(sp)
 9bc:	7ca2                	ld	s9,40(sp)
 9be:	7d02                	ld	s10,32(sp)
 9c0:	6de2                	ld	s11,24(sp)
 9c2:	6109                	addi	sp,sp,128
 9c4:	8082                	ret

00000000000009c6 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 9c6:	715d                	addi	sp,sp,-80
 9c8:	ec06                	sd	ra,24(sp)
 9ca:	e822                	sd	s0,16(sp)
 9cc:	1000                	addi	s0,sp,32
 9ce:	e010                	sd	a2,0(s0)
 9d0:	e414                	sd	a3,8(s0)
 9d2:	e818                	sd	a4,16(s0)
 9d4:	ec1c                	sd	a5,24(s0)
 9d6:	03043023          	sd	a6,32(s0)
 9da:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9de:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9e2:	8622                	mv	a2,s0
 9e4:	d4bff0ef          	jal	ra,72e <vprintf>
}
 9e8:	60e2                	ld	ra,24(sp)
 9ea:	6442                	ld	s0,16(sp)
 9ec:	6161                	addi	sp,sp,80
 9ee:	8082                	ret

00000000000009f0 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 9f0:	711d                	addi	sp,sp,-96
 9f2:	ec06                	sd	ra,24(sp)
 9f4:	e822                	sd	s0,16(sp)
 9f6:	1000                	addi	s0,sp,32
 9f8:	e40c                	sd	a1,8(s0)
 9fa:	e810                	sd	a2,16(s0)
 9fc:	ec14                	sd	a3,24(s0)
 9fe:	f018                	sd	a4,32(s0)
 a00:	f41c                	sd	a5,40(s0)
 a02:	03043823          	sd	a6,48(s0)
 a06:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a0a:	00840613          	addi	a2,s0,8
 a0e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a12:	85aa                	mv	a1,a0
 a14:	4505                	li	a0,1
 a16:	d19ff0ef          	jal	ra,72e <vprintf>
}
 a1a:	60e2                	ld	ra,24(sp)
 a1c:	6442                	ld	s0,16(sp)
 a1e:	6125                	addi	sp,sp,96
 a20:	8082                	ret

0000000000000a22 <free>:
 *   无
 */

void
free(void *ap)
{
 a22:	1141                	addi	sp,sp,-16
 a24:	e422                	sd	s0,8(sp)
 a26:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 a28:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a2c:	00000797          	auipc	a5,0x0
 a30:	5e47b783          	ld	a5,1508(a5) # 1010 <freep>
 a34:	a805                	j	a64 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a36:	4618                	lw	a4,8(a2)
 a38:	9db9                	addw	a1,a1,a4
 a3a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a3e:	6398                	ld	a4,0(a5)
 a40:	6318                	ld	a4,0(a4)
 a42:	fee53823          	sd	a4,-16(a0)
 a46:	a091                	j	a8a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a48:	ff852703          	lw	a4,-8(a0)
 a4c:	9e39                	addw	a2,a2,a4
 a4e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a50:	ff053703          	ld	a4,-16(a0)
 a54:	e398                	sd	a4,0(a5)
 a56:	a099                	j	a9c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a58:	6398                	ld	a4,0(a5)
 a5a:	00e7e463          	bltu	a5,a4,a62 <free+0x40>
 a5e:	00e6ea63          	bltu	a3,a4,a72 <free+0x50>
{
 a62:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a64:	fed7fae3          	bgeu	a5,a3,a58 <free+0x36>
 a68:	6398                	ld	a4,0(a5)
 a6a:	00e6e463          	bltu	a3,a4,a72 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a6e:	fee7eae3          	bltu	a5,a4,a62 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a72:	ff852583          	lw	a1,-8(a0)
 a76:	6390                	ld	a2,0(a5)
 a78:	02059713          	slli	a4,a1,0x20
 a7c:	9301                	srli	a4,a4,0x20
 a7e:	0712                	slli	a4,a4,0x4
 a80:	9736                	add	a4,a4,a3
 a82:	fae60ae3          	beq	a2,a4,a36 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a86:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a8a:	4790                	lw	a2,8(a5)
 a8c:	02061713          	slli	a4,a2,0x20
 a90:	9301                	srli	a4,a4,0x20
 a92:	0712                	slli	a4,a4,0x4
 a94:	973e                	add	a4,a4,a5
 a96:	fae689e3          	beq	a3,a4,a48 <free+0x26>
  } else
    p->s.ptr = bp;
 a9a:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 a9c:	00000717          	auipc	a4,0x0
 aa0:	56f73a23          	sd	a5,1396(a4) # 1010 <freep>
}
 aa4:	6422                	ld	s0,8(sp)
 aa6:	0141                	addi	sp,sp,16
 aa8:	8082                	ret

0000000000000aaa <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 aaa:	7139                	addi	sp,sp,-64
 aac:	fc06                	sd	ra,56(sp)
 aae:	f822                	sd	s0,48(sp)
 ab0:	f426                	sd	s1,40(sp)
 ab2:	f04a                	sd	s2,32(sp)
 ab4:	ec4e                	sd	s3,24(sp)
 ab6:	e852                	sd	s4,16(sp)
 ab8:	e456                	sd	s5,8(sp)
 aba:	e05a                	sd	s6,0(sp)
 abc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 abe:	02051493          	slli	s1,a0,0x20
 ac2:	9081                	srli	s1,s1,0x20
 ac4:	04bd                	addi	s1,s1,15
 ac6:	8091                	srli	s1,s1,0x4
 ac8:	0014899b          	addiw	s3,s1,1
 acc:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 ace:	00000517          	auipc	a0,0x0
 ad2:	54253503          	ld	a0,1346(a0) # 1010 <freep>
 ad6:	c515                	beqz	a0,b02 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 ada:	4798                	lw	a4,8(a5)
 adc:	02977f63          	bgeu	a4,s1,b1a <malloc+0x70>
 ae0:	8a4e                	mv	s4,s3
 ae2:	0009871b          	sext.w	a4,s3
 ae6:	6685                	lui	a3,0x1
 ae8:	00d77363          	bgeu	a4,a3,aee <malloc+0x44>
 aec:	6a05                	lui	s4,0x1
 aee:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 af2:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 af6:	00000917          	auipc	s2,0x0
 afa:	51a90913          	addi	s2,s2,1306 # 1010 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 afe:	5afd                	li	s5,-1
 b00:	a0bd                	j	b6e <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 b02:	00000797          	auipc	a5,0x0
 b06:	56678793          	addi	a5,a5,1382 # 1068 <base>
 b0a:	00000717          	auipc	a4,0x0
 b0e:	50f73323          	sd	a5,1286(a4) # 1010 <freep>
 b12:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b14:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 b18:	b7e1                	j	ae0 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 b1a:	02e48b63          	beq	s1,a4,b50 <malloc+0xa6>
        p->s.size -= nunits;
 b1e:	4137073b          	subw	a4,a4,s3
 b22:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b24:	1702                	slli	a4,a4,0x20
 b26:	9301                	srli	a4,a4,0x20
 b28:	0712                	slli	a4,a4,0x4
 b2a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b2c:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 b30:	00000717          	auipc	a4,0x0
 b34:	4ea73023          	sd	a0,1248(a4) # 1010 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 b38:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 b3c:	70e2                	ld	ra,56(sp)
 b3e:	7442                	ld	s0,48(sp)
 b40:	74a2                	ld	s1,40(sp)
 b42:	7902                	ld	s2,32(sp)
 b44:	69e2                	ld	s3,24(sp)
 b46:	6a42                	ld	s4,16(sp)
 b48:	6aa2                	ld	s5,8(sp)
 b4a:	6b02                	ld	s6,0(sp)
 b4c:	6121                	addi	sp,sp,64
 b4e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b50:	6398                	ld	a4,0(a5)
 b52:	e118                	sd	a4,0(a0)
 b54:	bff1                	j	b30 <malloc+0x86>
  hp->s.size = nu;
 b56:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 b5a:	0541                	addi	a0,a0,16
 b5c:	ec7ff0ef          	jal	ra,a22 <free>
  return freep;
 b60:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b64:	dd61                	beqz	a0,b3c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b66:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 b68:	4798                	lw	a4,8(a5)
 b6a:	fa9778e3          	bgeu	a4,s1,b1a <malloc+0x70>
    if(p == freep)
 b6e:	00093703          	ld	a4,0(s2)
 b72:	853e                	mv	a0,a5
 b74:	fef719e3          	bne	a4,a5,b66 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 b78:	8552                	mv	a0,s4
 b7a:	9e7ff0ef          	jal	ra,560 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 b7e:	fd551ce3          	bne	a0,s5,b56 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 b82:	4501                	li	a0,0
 b84:	bf65                	j	b3c <malloc+0x92>
