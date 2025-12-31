
user/_usertests：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
       e:	00008797          	auipc	a5,0x8
      12:	86a78793          	addi	a5,a5,-1942 # 7878 <malloc+0x2658>
      16:	638c                	ld	a1,0(a5)
      18:	6790                	ld	a2,8(a5)
      1a:	6b94                	ld	a3,16(a5)
      1c:	6f98                	ld	a4,24(a5)
      1e:	739c                	ld	a5,32(a5)
      20:	fab43423          	sd	a1,-88(s0)
      24:	fac43823          	sd	a2,-80(s0)
      28:	fad43c23          	sd	a3,-72(s0)
      2c:	fce43023          	sd	a4,-64(s0)
      30:	fcf43423          	sd	a5,-56(s0)
                     0xffffffffffffffff };

  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      34:	fa840493          	addi	s1,s0,-88
      38:	fd040993          	addi	s3,s0,-48
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      3c:	0004b903          	ld	s2,0(s1)
      40:	20100593          	li	a1,513
      44:	854a                	mv	a0,s2
      46:	52b040ef          	jal	ra,4d70 <open>
    if(fd >= 0){
      4a:	00055c63          	bgez	a0,62 <copyinstr1+0x62>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      4e:	04a1                	addi	s1,s1,8
      50:	ff3496e3          	bne	s1,s3,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      exit(1);
    }
  }
}
      54:	60e6                	ld	ra,88(sp)
      56:	6446                	ld	s0,80(sp)
      58:	64a6                	ld	s1,72(sp)
      5a:	6906                	ld	s2,64(sp)
      5c:	79e2                	ld	s3,56(sp)
      5e:	6125                	addi	sp,sp,96
      60:	8082                	ret
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      62:	862a                	mv	a2,a0
      64:	85ca                	mv	a1,s2
      66:	00005517          	auipc	a0,0x5
      6a:	29a50513          	addi	a0,a0,666 # 5300 <malloc+0xe0>
      6e:	0fe050ef          	jal	ra,516c <printf>
      exit(1);
      72:	4505                	li	a0,1
      74:	4bd040ef          	jal	ra,4d30 <exit>

0000000000000078 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      78:	00009797          	auipc	a5,0x9
      7c:	53078793          	addi	a5,a5,1328 # 95a8 <uninit>
      80:	0000c697          	auipc	a3,0xc
      84:	c3868693          	addi	a3,a3,-968 # bcb8 <buf>
    if(uninit[i] != '\0'){
      88:	0007c703          	lbu	a4,0(a5)
      8c:	e709                	bnez	a4,96 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      8e:	0785                	addi	a5,a5,1
      90:	fed79ce3          	bne	a5,a3,88 <bsstest+0x10>
      94:	8082                	ret
{
      96:	1141                	addi	sp,sp,-16
      98:	e406                	sd	ra,8(sp)
      9a:	e022                	sd	s0,0(sp)
      9c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      9e:	85aa                	mv	a1,a0
      a0:	00005517          	auipc	a0,0x5
      a4:	28050513          	addi	a0,a0,640 # 5320 <malloc+0x100>
      a8:	0c4050ef          	jal	ra,516c <printf>
      exit(1);
      ac:	4505                	li	a0,1
      ae:	483040ef          	jal	ra,4d30 <exit>

00000000000000b2 <opentest>:
{
      b2:	1101                	addi	sp,sp,-32
      b4:	ec06                	sd	ra,24(sp)
      b6:	e822                	sd	s0,16(sp)
      b8:	e426                	sd	s1,8(sp)
      ba:	1000                	addi	s0,sp,32
      bc:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      be:	4581                	li	a1,0
      c0:	00005517          	auipc	a0,0x5
      c4:	27850513          	addi	a0,a0,632 # 5338 <malloc+0x118>
      c8:	4a9040ef          	jal	ra,4d70 <open>
  if(fd < 0){
      cc:	02054263          	bltz	a0,f0 <opentest+0x3e>
  close(fd);
      d0:	489040ef          	jal	ra,4d58 <close>
  fd = open("doesnotexist", 0);
      d4:	4581                	li	a1,0
      d6:	00005517          	auipc	a0,0x5
      da:	28250513          	addi	a0,a0,642 # 5358 <malloc+0x138>
      de:	493040ef          	jal	ra,4d70 <open>
  if(fd >= 0){
      e2:	02055163          	bgez	a0,104 <opentest+0x52>
}
      e6:	60e2                	ld	ra,24(sp)
      e8:	6442                	ld	s0,16(sp)
      ea:	64a2                	ld	s1,8(sp)
      ec:	6105                	addi	sp,sp,32
      ee:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f0:	85a6                	mv	a1,s1
      f2:	00005517          	auipc	a0,0x5
      f6:	24e50513          	addi	a0,a0,590 # 5340 <malloc+0x120>
      fa:	072050ef          	jal	ra,516c <printf>
    exit(1);
      fe:	4505                	li	a0,1
     100:	431040ef          	jal	ra,4d30 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     104:	85a6                	mv	a1,s1
     106:	00005517          	auipc	a0,0x5
     10a:	26250513          	addi	a0,a0,610 # 5368 <malloc+0x148>
     10e:	05e050ef          	jal	ra,516c <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	41d040ef          	jal	ra,4d30 <exit>

0000000000000118 <truncate2>:
{
     118:	7179                	addi	sp,sp,-48
     11a:	f406                	sd	ra,40(sp)
     11c:	f022                	sd	s0,32(sp)
     11e:	ec26                	sd	s1,24(sp)
     120:	e84a                	sd	s2,16(sp)
     122:	e44e                	sd	s3,8(sp)
     124:	1800                	addi	s0,sp,48
     126:	89aa                	mv	s3,a0
  unlink("truncfile");
     128:	00005517          	auipc	a0,0x5
     12c:	26850513          	addi	a0,a0,616 # 5390 <malloc+0x170>
     130:	451040ef          	jal	ra,4d80 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     134:	60100593          	li	a1,1537
     138:	00005517          	auipc	a0,0x5
     13c:	25850513          	addi	a0,a0,600 # 5390 <malloc+0x170>
     140:	431040ef          	jal	ra,4d70 <open>
     144:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     146:	4611                	li	a2,4
     148:	00005597          	auipc	a1,0x5
     14c:	25858593          	addi	a1,a1,600 # 53a0 <malloc+0x180>
     150:	401040ef          	jal	ra,4d50 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     154:	40100593          	li	a1,1025
     158:	00005517          	auipc	a0,0x5
     15c:	23850513          	addi	a0,a0,568 # 5390 <malloc+0x170>
     160:	411040ef          	jal	ra,4d70 <open>
     164:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     166:	4605                	li	a2,1
     168:	00005597          	auipc	a1,0x5
     16c:	24058593          	addi	a1,a1,576 # 53a8 <malloc+0x188>
     170:	8526                	mv	a0,s1
     172:	3df040ef          	jal	ra,4d50 <write>
  if(n != -1){
     176:	57fd                	li	a5,-1
     178:	02f51563          	bne	a0,a5,1a2 <truncate2+0x8a>
  unlink("truncfile");
     17c:	00005517          	auipc	a0,0x5
     180:	21450513          	addi	a0,a0,532 # 5390 <malloc+0x170>
     184:	3fd040ef          	jal	ra,4d80 <unlink>
  close(fd1);
     188:	8526                	mv	a0,s1
     18a:	3cf040ef          	jal	ra,4d58 <close>
  close(fd2);
     18e:	854a                	mv	a0,s2
     190:	3c9040ef          	jal	ra,4d58 <close>
}
     194:	70a2                	ld	ra,40(sp)
     196:	7402                	ld	s0,32(sp)
     198:	64e2                	ld	s1,24(sp)
     19a:	6942                	ld	s2,16(sp)
     19c:	69a2                	ld	s3,8(sp)
     19e:	6145                	addi	sp,sp,48
     1a0:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1a2:	862a                	mv	a2,a0
     1a4:	85ce                	mv	a1,s3
     1a6:	00005517          	auipc	a0,0x5
     1aa:	20a50513          	addi	a0,a0,522 # 53b0 <malloc+0x190>
     1ae:	7bf040ef          	jal	ra,516c <printf>
    exit(1);
     1b2:	4505                	li	a0,1
     1b4:	37d040ef          	jal	ra,4d30 <exit>

00000000000001b8 <createtest>:
{
     1b8:	7179                	addi	sp,sp,-48
     1ba:	f406                	sd	ra,40(sp)
     1bc:	f022                	sd	s0,32(sp)
     1be:	ec26                	sd	s1,24(sp)
     1c0:	e84a                	sd	s2,16(sp)
     1c2:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1c4:	06100793          	li	a5,97
     1c8:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1cc:	fc040d23          	sb	zero,-38(s0)
     1d0:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     1d4:	06400913          	li	s2,100
    name[1] = '0' + i;
     1d8:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     1dc:	20200593          	li	a1,514
     1e0:	fd840513          	addi	a0,s0,-40
     1e4:	38d040ef          	jal	ra,4d70 <open>
    close(fd);
     1e8:	371040ef          	jal	ra,4d58 <close>
  for(i = 0; i < N; i++){
     1ec:	2485                	addiw	s1,s1,1
     1ee:	0ff4f493          	zext.b	s1,s1
     1f2:	ff2493e3          	bne	s1,s2,1d8 <createtest+0x20>
  name[0] = 'a';
     1f6:	06100793          	li	a5,97
     1fa:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1fe:	fc040d23          	sb	zero,-38(s0)
     202:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     206:	06400913          	li	s2,100
    name[1] = '0' + i;
     20a:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     20e:	fd840513          	addi	a0,s0,-40
     212:	36f040ef          	jal	ra,4d80 <unlink>
  for(i = 0; i < N; i++){
     216:	2485                	addiw	s1,s1,1
     218:	0ff4f493          	zext.b	s1,s1
     21c:	ff2497e3          	bne	s1,s2,20a <createtest+0x52>
}
     220:	70a2                	ld	ra,40(sp)
     222:	7402                	ld	s0,32(sp)
     224:	64e2                	ld	s1,24(sp)
     226:	6942                	ld	s2,16(sp)
     228:	6145                	addi	sp,sp,48
     22a:	8082                	ret

000000000000022c <bigwrite>:
{
     22c:	715d                	addi	sp,sp,-80
     22e:	e486                	sd	ra,72(sp)
     230:	e0a2                	sd	s0,64(sp)
     232:	fc26                	sd	s1,56(sp)
     234:	f84a                	sd	s2,48(sp)
     236:	f44e                	sd	s3,40(sp)
     238:	f052                	sd	s4,32(sp)
     23a:	ec56                	sd	s5,24(sp)
     23c:	e85a                	sd	s6,16(sp)
     23e:	e45e                	sd	s7,8(sp)
     240:	0880                	addi	s0,sp,80
     242:	8baa                	mv	s7,a0
  unlink("bigwrite");
     244:	00005517          	auipc	a0,0x5
     248:	19450513          	addi	a0,a0,404 # 53d8 <malloc+0x1b8>
     24c:	335040ef          	jal	ra,4d80 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     250:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     254:	00005a97          	auipc	s5,0x5
     258:	184a8a93          	addi	s5,s5,388 # 53d8 <malloc+0x1b8>
      int cc = write(fd, buf, sz);
     25c:	0000ca17          	auipc	s4,0xc
     260:	a5ca0a13          	addi	s4,s4,-1444 # bcb8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     264:	6b0d                	lui	s6,0x3
     266:	1c9b0b13          	addi	s6,s6,457 # 31c9 <rmdot+0x6d>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     26a:	20200593          	li	a1,514
     26e:	8556                	mv	a0,s5
     270:	301040ef          	jal	ra,4d70 <open>
     274:	892a                	mv	s2,a0
    if(fd < 0){
     276:	04054563          	bltz	a0,2c0 <bigwrite+0x94>
      int cc = write(fd, buf, sz);
     27a:	8626                	mv	a2,s1
     27c:	85d2                	mv	a1,s4
     27e:	2d3040ef          	jal	ra,4d50 <write>
     282:	89aa                	mv	s3,a0
      if(cc != sz){
     284:	04a49863          	bne	s1,a0,2d4 <bigwrite+0xa8>
      int cc = write(fd, buf, sz);
     288:	8626                	mv	a2,s1
     28a:	85d2                	mv	a1,s4
     28c:	854a                	mv	a0,s2
     28e:	2c3040ef          	jal	ra,4d50 <write>
      if(cc != sz){
     292:	04951263          	bne	a0,s1,2d6 <bigwrite+0xaa>
    close(fd);
     296:	854a                	mv	a0,s2
     298:	2c1040ef          	jal	ra,4d58 <close>
    unlink("bigwrite");
     29c:	8556                	mv	a0,s5
     29e:	2e3040ef          	jal	ra,4d80 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a2:	1d74849b          	addiw	s1,s1,471
     2a6:	fd6492e3          	bne	s1,s6,26a <bigwrite+0x3e>
}
     2aa:	60a6                	ld	ra,72(sp)
     2ac:	6406                	ld	s0,64(sp)
     2ae:	74e2                	ld	s1,56(sp)
     2b0:	7942                	ld	s2,48(sp)
     2b2:	79a2                	ld	s3,40(sp)
     2b4:	7a02                	ld	s4,32(sp)
     2b6:	6ae2                	ld	s5,24(sp)
     2b8:	6b42                	ld	s6,16(sp)
     2ba:	6ba2                	ld	s7,8(sp)
     2bc:	6161                	addi	sp,sp,80
     2be:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     2c0:	85de                	mv	a1,s7
     2c2:	00005517          	auipc	a0,0x5
     2c6:	12650513          	addi	a0,a0,294 # 53e8 <malloc+0x1c8>
     2ca:	6a3040ef          	jal	ra,516c <printf>
      exit(1);
     2ce:	4505                	li	a0,1
     2d0:	261040ef          	jal	ra,4d30 <exit>
      if(cc != sz){
     2d4:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     2d6:	86aa                	mv	a3,a0
     2d8:	864e                	mv	a2,s3
     2da:	85de                	mv	a1,s7
     2dc:	00005517          	auipc	a0,0x5
     2e0:	12c50513          	addi	a0,a0,300 # 5408 <malloc+0x1e8>
     2e4:	689040ef          	jal	ra,516c <printf>
        exit(1);
     2e8:	4505                	li	a0,1
     2ea:	247040ef          	jal	ra,4d30 <exit>

00000000000002ee <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     2ee:	7179                	addi	sp,sp,-48
     2f0:	f406                	sd	ra,40(sp)
     2f2:	f022                	sd	s0,32(sp)
     2f4:	ec26                	sd	s1,24(sp)
     2f6:	e84a                	sd	s2,16(sp)
     2f8:	e44e                	sd	s3,8(sp)
     2fa:	e052                	sd	s4,0(sp)
     2fc:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     2fe:	00005517          	auipc	a0,0x5
     302:	12250513          	addi	a0,a0,290 # 5420 <malloc+0x200>
     306:	27b040ef          	jal	ra,4d80 <unlink>
     30a:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     30e:	00005997          	auipc	s3,0x5
     312:	11298993          	addi	s3,s3,274 # 5420 <malloc+0x200>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     316:	5a7d                	li	s4,-1
     318:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     31c:	20100593          	li	a1,513
     320:	854e                	mv	a0,s3
     322:	24f040ef          	jal	ra,4d70 <open>
     326:	84aa                	mv	s1,a0
    if(fd < 0){
     328:	04054d63          	bltz	a0,382 <badwrite+0x94>
    write(fd, (char*)0xffffffffffL, 1);
     32c:	4605                	li	a2,1
     32e:	85d2                	mv	a1,s4
     330:	221040ef          	jal	ra,4d50 <write>
    close(fd);
     334:	8526                	mv	a0,s1
     336:	223040ef          	jal	ra,4d58 <close>
    unlink("junk");
     33a:	854e                	mv	a0,s3
     33c:	245040ef          	jal	ra,4d80 <unlink>
  for(int i = 0; i < assumed_free; i++){
     340:	397d                	addiw	s2,s2,-1
     342:	fc091de3          	bnez	s2,31c <badwrite+0x2e>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     346:	20100593          	li	a1,513
     34a:	00005517          	auipc	a0,0x5
     34e:	0d650513          	addi	a0,a0,214 # 5420 <malloc+0x200>
     352:	21f040ef          	jal	ra,4d70 <open>
     356:	84aa                	mv	s1,a0
  if(fd < 0){
     358:	02054e63          	bltz	a0,394 <badwrite+0xa6>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     35c:	4605                	li	a2,1
     35e:	00005597          	auipc	a1,0x5
     362:	04a58593          	addi	a1,a1,74 # 53a8 <malloc+0x188>
     366:	1eb040ef          	jal	ra,4d50 <write>
     36a:	4785                	li	a5,1
     36c:	02f50d63          	beq	a0,a5,3a6 <badwrite+0xb8>
    printf("write failed\n");
     370:	00005517          	auipc	a0,0x5
     374:	0d050513          	addi	a0,a0,208 # 5440 <malloc+0x220>
     378:	5f5040ef          	jal	ra,516c <printf>
    exit(1);
     37c:	4505                	li	a0,1
     37e:	1b3040ef          	jal	ra,4d30 <exit>
      printf("open junk failed\n");
     382:	00005517          	auipc	a0,0x5
     386:	0a650513          	addi	a0,a0,166 # 5428 <malloc+0x208>
     38a:	5e3040ef          	jal	ra,516c <printf>
      exit(1);
     38e:	4505                	li	a0,1
     390:	1a1040ef          	jal	ra,4d30 <exit>
    printf("open junk failed\n");
     394:	00005517          	auipc	a0,0x5
     398:	09450513          	addi	a0,a0,148 # 5428 <malloc+0x208>
     39c:	5d1040ef          	jal	ra,516c <printf>
    exit(1);
     3a0:	4505                	li	a0,1
     3a2:	18f040ef          	jal	ra,4d30 <exit>
  }
  close(fd);
     3a6:	8526                	mv	a0,s1
     3a8:	1b1040ef          	jal	ra,4d58 <close>
  unlink("junk");
     3ac:	00005517          	auipc	a0,0x5
     3b0:	07450513          	addi	a0,a0,116 # 5420 <malloc+0x200>
     3b4:	1cd040ef          	jal	ra,4d80 <unlink>

  exit(0);
     3b8:	4501                	li	a0,0
     3ba:	177040ef          	jal	ra,4d30 <exit>

00000000000003be <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     3be:	715d                	addi	sp,sp,-80
     3c0:	e486                	sd	ra,72(sp)
     3c2:	e0a2                	sd	s0,64(sp)
     3c4:	fc26                	sd	s1,56(sp)
     3c6:	f84a                	sd	s2,48(sp)
     3c8:	f44e                	sd	s3,40(sp)
     3ca:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     3cc:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     3ce:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     3d2:	40000993          	li	s3,1024
    name[0] = 'z';
     3d6:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     3da:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     3de:	41f4d71b          	sraiw	a4,s1,0x1f
     3e2:	01b7571b          	srliw	a4,a4,0x1b
     3e6:	009707bb          	addw	a5,a4,s1
     3ea:	4057d69b          	sraiw	a3,a5,0x5
     3ee:	0306869b          	addiw	a3,a3,48
     3f2:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     3f6:	8bfd                	andi	a5,a5,31
     3f8:	9f99                	subw	a5,a5,a4
     3fa:	0307879b          	addiw	a5,a5,48
     3fe:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     402:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     406:	fb040513          	addi	a0,s0,-80
     40a:	177040ef          	jal	ra,4d80 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     40e:	60200593          	li	a1,1538
     412:	fb040513          	addi	a0,s0,-80
     416:	15b040ef          	jal	ra,4d70 <open>
    if(fd < 0){
     41a:	00054763          	bltz	a0,428 <outofinodes+0x6a>
      // failure is eventually expected.
      break;
    }
    close(fd);
     41e:	13b040ef          	jal	ra,4d58 <close>
  for(int i = 0; i < nzz; i++){
     422:	2485                	addiw	s1,s1,1
     424:	fb3499e3          	bne	s1,s3,3d6 <outofinodes+0x18>
     428:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     42a:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     42e:	40000993          	li	s3,1024
    name[0] = 'z';
     432:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     436:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     43a:	41f4d71b          	sraiw	a4,s1,0x1f
     43e:	01b7571b          	srliw	a4,a4,0x1b
     442:	009707bb          	addw	a5,a4,s1
     446:	4057d69b          	sraiw	a3,a5,0x5
     44a:	0306869b          	addiw	a3,a3,48
     44e:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     452:	8bfd                	andi	a5,a5,31
     454:	9f99                	subw	a5,a5,a4
     456:	0307879b          	addiw	a5,a5,48
     45a:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     45e:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     462:	fb040513          	addi	a0,s0,-80
     466:	11b040ef          	jal	ra,4d80 <unlink>
  for(int i = 0; i < nzz; i++){
     46a:	2485                	addiw	s1,s1,1
     46c:	fd3493e3          	bne	s1,s3,432 <outofinodes+0x74>
  }
}
     470:	60a6                	ld	ra,72(sp)
     472:	6406                	ld	s0,64(sp)
     474:	74e2                	ld	s1,56(sp)
     476:	7942                	ld	s2,48(sp)
     478:	79a2                	ld	s3,40(sp)
     47a:	6161                	addi	sp,sp,80
     47c:	8082                	ret

000000000000047e <copyin>:
{
     47e:	7159                	addi	sp,sp,-112
     480:	f486                	sd	ra,104(sp)
     482:	f0a2                	sd	s0,96(sp)
     484:	eca6                	sd	s1,88(sp)
     486:	e8ca                	sd	s2,80(sp)
     488:	e4ce                	sd	s3,72(sp)
     48a:	e0d2                	sd	s4,64(sp)
     48c:	fc56                	sd	s5,56(sp)
     48e:	1880                	addi	s0,sp,112
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     490:	00007797          	auipc	a5,0x7
     494:	3e878793          	addi	a5,a5,1000 # 7878 <malloc+0x2658>
     498:	638c                	ld	a1,0(a5)
     49a:	6790                	ld	a2,8(a5)
     49c:	6b94                	ld	a3,16(a5)
     49e:	6f98                	ld	a4,24(a5)
     4a0:	739c                	ld	a5,32(a5)
     4a2:	f8b43c23          	sd	a1,-104(s0)
     4a6:	fac43023          	sd	a2,-96(s0)
     4aa:	fad43423          	sd	a3,-88(s0)
     4ae:	fae43823          	sd	a4,-80(s0)
     4b2:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     4b6:	f9840913          	addi	s2,s0,-104
     4ba:	fc040a93          	addi	s5,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4be:	00005a17          	auipc	s4,0x5
     4c2:	f92a0a13          	addi	s4,s4,-110 # 5450 <malloc+0x230>
    uint64 addr = addrs[ai];
     4c6:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4ca:	20100593          	li	a1,513
     4ce:	8552                	mv	a0,s4
     4d0:	0a1040ef          	jal	ra,4d70 <open>
     4d4:	84aa                	mv	s1,a0
    if(fd < 0){
     4d6:	06054763          	bltz	a0,544 <copyin+0xc6>
    int n = write(fd, (void*)addr, 8192);
     4da:	6609                	lui	a2,0x2
     4dc:	85ce                	mv	a1,s3
     4de:	073040ef          	jal	ra,4d50 <write>
    if(n >= 0){
     4e2:	06055a63          	bgez	a0,556 <copyin+0xd8>
    close(fd);
     4e6:	8526                	mv	a0,s1
     4e8:	071040ef          	jal	ra,4d58 <close>
    unlink("copyin1");
     4ec:	8552                	mv	a0,s4
     4ee:	093040ef          	jal	ra,4d80 <unlink>
    n = write(1, (char*)addr, 8192);
     4f2:	6609                	lui	a2,0x2
     4f4:	85ce                	mv	a1,s3
     4f6:	4505                	li	a0,1
     4f8:	059040ef          	jal	ra,4d50 <write>
    if(n > 0){
     4fc:	06a04863          	bgtz	a0,56c <copyin+0xee>
    if(pipe(fds) < 0){
     500:	f9040513          	addi	a0,s0,-112
     504:	03d040ef          	jal	ra,4d40 <pipe>
     508:	06054d63          	bltz	a0,582 <copyin+0x104>
    n = write(fds[1], (char*)addr, 8192);
     50c:	6609                	lui	a2,0x2
     50e:	85ce                	mv	a1,s3
     510:	f9442503          	lw	a0,-108(s0)
     514:	03d040ef          	jal	ra,4d50 <write>
    if(n > 0){
     518:	06a04e63          	bgtz	a0,594 <copyin+0x116>
    close(fds[0]);
     51c:	f9042503          	lw	a0,-112(s0)
     520:	039040ef          	jal	ra,4d58 <close>
    close(fds[1]);
     524:	f9442503          	lw	a0,-108(s0)
     528:	031040ef          	jal	ra,4d58 <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     52c:	0921                	addi	s2,s2,8
     52e:	f9591ce3          	bne	s2,s5,4c6 <copyin+0x48>
}
     532:	70a6                	ld	ra,104(sp)
     534:	7406                	ld	s0,96(sp)
     536:	64e6                	ld	s1,88(sp)
     538:	6946                	ld	s2,80(sp)
     53a:	69a6                	ld	s3,72(sp)
     53c:	6a06                	ld	s4,64(sp)
     53e:	7ae2                	ld	s5,56(sp)
     540:	6165                	addi	sp,sp,112
     542:	8082                	ret
      printf("open(copyin1) failed\n");
     544:	00005517          	auipc	a0,0x5
     548:	f1450513          	addi	a0,a0,-236 # 5458 <malloc+0x238>
     54c:	421040ef          	jal	ra,516c <printf>
      exit(1);
     550:	4505                	li	a0,1
     552:	7de040ef          	jal	ra,4d30 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", (void*)addr, n);
     556:	862a                	mv	a2,a0
     558:	85ce                	mv	a1,s3
     55a:	00005517          	auipc	a0,0x5
     55e:	f1650513          	addi	a0,a0,-234 # 5470 <malloc+0x250>
     562:	40b040ef          	jal	ra,516c <printf>
      exit(1);
     566:	4505                	li	a0,1
     568:	7c8040ef          	jal	ra,4d30 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     56c:	862a                	mv	a2,a0
     56e:	85ce                	mv	a1,s3
     570:	00005517          	auipc	a0,0x5
     574:	f3050513          	addi	a0,a0,-208 # 54a0 <malloc+0x280>
     578:	3f5040ef          	jal	ra,516c <printf>
      exit(1);
     57c:	4505                	li	a0,1
     57e:	7b2040ef          	jal	ra,4d30 <exit>
      printf("pipe() failed\n");
     582:	00005517          	auipc	a0,0x5
     586:	f4e50513          	addi	a0,a0,-178 # 54d0 <malloc+0x2b0>
     58a:	3e3040ef          	jal	ra,516c <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	7a0040ef          	jal	ra,4d30 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     594:	862a                	mv	a2,a0
     596:	85ce                	mv	a1,s3
     598:	00005517          	auipc	a0,0x5
     59c:	f4850513          	addi	a0,a0,-184 # 54e0 <malloc+0x2c0>
     5a0:	3cd040ef          	jal	ra,516c <printf>
      exit(1);
     5a4:	4505                	li	a0,1
     5a6:	78a040ef          	jal	ra,4d30 <exit>

00000000000005aa <copyout>:
{
     5aa:	7119                	addi	sp,sp,-128
     5ac:	fc86                	sd	ra,120(sp)
     5ae:	f8a2                	sd	s0,112(sp)
     5b0:	f4a6                	sd	s1,104(sp)
     5b2:	f0ca                	sd	s2,96(sp)
     5b4:	ecce                	sd	s3,88(sp)
     5b6:	e8d2                	sd	s4,80(sp)
     5b8:	e4d6                	sd	s5,72(sp)
     5ba:	e0da                	sd	s6,64(sp)
     5bc:	0100                	addi	s0,sp,128
  uint64 addrs[] = { 0LL, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     5be:	00007797          	auipc	a5,0x7
     5c2:	2ba78793          	addi	a5,a5,698 # 7878 <malloc+0x2658>
     5c6:	7788                	ld	a0,40(a5)
     5c8:	7b8c                	ld	a1,48(a5)
     5ca:	7f90                	ld	a2,56(a5)
     5cc:	63b4                	ld	a3,64(a5)
     5ce:	67b8                	ld	a4,72(a5)
     5d0:	6bbc                	ld	a5,80(a5)
     5d2:	f8a43823          	sd	a0,-112(s0)
     5d6:	f8b43c23          	sd	a1,-104(s0)
     5da:	fac43023          	sd	a2,-96(s0)
     5de:	fad43423          	sd	a3,-88(s0)
     5e2:	fae43823          	sd	a4,-80(s0)
     5e6:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     5ea:	f9040913          	addi	s2,s0,-112
     5ee:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
     5f2:	00005a17          	auipc	s4,0x5
     5f6:	f1ea0a13          	addi	s4,s4,-226 # 5510 <malloc+0x2f0>
    n = write(fds[1], "x", 1);
     5fa:	00005a97          	auipc	s5,0x5
     5fe:	daea8a93          	addi	s5,s5,-594 # 53a8 <malloc+0x188>
    uint64 addr = addrs[ai];
     602:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     606:	4581                	li	a1,0
     608:	8552                	mv	a0,s4
     60a:	766040ef          	jal	ra,4d70 <open>
     60e:	84aa                	mv	s1,a0
    if(fd < 0){
     610:	06054763          	bltz	a0,67e <copyout+0xd4>
    int n = read(fd, (void*)addr, 8192);
     614:	6609                	lui	a2,0x2
     616:	85ce                	mv	a1,s3
     618:	730040ef          	jal	ra,4d48 <read>
    if(n > 0){
     61c:	06a04a63          	bgtz	a0,690 <copyout+0xe6>
    close(fd);
     620:	8526                	mv	a0,s1
     622:	736040ef          	jal	ra,4d58 <close>
    if(pipe(fds) < 0){
     626:	f8840513          	addi	a0,s0,-120
     62a:	716040ef          	jal	ra,4d40 <pipe>
     62e:	06054c63          	bltz	a0,6a6 <copyout+0xfc>
    n = write(fds[1], "x", 1);
     632:	4605                	li	a2,1
     634:	85d6                	mv	a1,s5
     636:	f8c42503          	lw	a0,-116(s0)
     63a:	716040ef          	jal	ra,4d50 <write>
    if(n != 1){
     63e:	4785                	li	a5,1
     640:	06f51c63          	bne	a0,a5,6b8 <copyout+0x10e>
    n = read(fds[0], (void*)addr, 8192);
     644:	6609                	lui	a2,0x2
     646:	85ce                	mv	a1,s3
     648:	f8842503          	lw	a0,-120(s0)
     64c:	6fc040ef          	jal	ra,4d48 <read>
    if(n > 0){
     650:	06a04d63          	bgtz	a0,6ca <copyout+0x120>
    close(fds[0]);
     654:	f8842503          	lw	a0,-120(s0)
     658:	700040ef          	jal	ra,4d58 <close>
    close(fds[1]);
     65c:	f8c42503          	lw	a0,-116(s0)
     660:	6f8040ef          	jal	ra,4d58 <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     664:	0921                	addi	s2,s2,8
     666:	f9691ee3          	bne	s2,s6,602 <copyout+0x58>
}
     66a:	70e6                	ld	ra,120(sp)
     66c:	7446                	ld	s0,112(sp)
     66e:	74a6                	ld	s1,104(sp)
     670:	7906                	ld	s2,96(sp)
     672:	69e6                	ld	s3,88(sp)
     674:	6a46                	ld	s4,80(sp)
     676:	6aa6                	ld	s5,72(sp)
     678:	6b06                	ld	s6,64(sp)
     67a:	6109                	addi	sp,sp,128
     67c:	8082                	ret
      printf("open(README) failed\n");
     67e:	00005517          	auipc	a0,0x5
     682:	e9a50513          	addi	a0,a0,-358 # 5518 <malloc+0x2f8>
     686:	2e7040ef          	jal	ra,516c <printf>
      exit(1);
     68a:	4505                	li	a0,1
     68c:	6a4040ef          	jal	ra,4d30 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     690:	862a                	mv	a2,a0
     692:	85ce                	mv	a1,s3
     694:	00005517          	auipc	a0,0x5
     698:	e9c50513          	addi	a0,a0,-356 # 5530 <malloc+0x310>
     69c:	2d1040ef          	jal	ra,516c <printf>
      exit(1);
     6a0:	4505                	li	a0,1
     6a2:	68e040ef          	jal	ra,4d30 <exit>
      printf("pipe() failed\n");
     6a6:	00005517          	auipc	a0,0x5
     6aa:	e2a50513          	addi	a0,a0,-470 # 54d0 <malloc+0x2b0>
     6ae:	2bf040ef          	jal	ra,516c <printf>
      exit(1);
     6b2:	4505                	li	a0,1
     6b4:	67c040ef          	jal	ra,4d30 <exit>
      printf("pipe write failed\n");
     6b8:	00005517          	auipc	a0,0x5
     6bc:	ea850513          	addi	a0,a0,-344 # 5560 <malloc+0x340>
     6c0:	2ad040ef          	jal	ra,516c <printf>
      exit(1);
     6c4:	4505                	li	a0,1
     6c6:	66a040ef          	jal	ra,4d30 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     6ca:	862a                	mv	a2,a0
     6cc:	85ce                	mv	a1,s3
     6ce:	00005517          	auipc	a0,0x5
     6d2:	eaa50513          	addi	a0,a0,-342 # 5578 <malloc+0x358>
     6d6:	297040ef          	jal	ra,516c <printf>
      exit(1);
     6da:	4505                	li	a0,1
     6dc:	654040ef          	jal	ra,4d30 <exit>

00000000000006e0 <truncate1>:
{
     6e0:	711d                	addi	sp,sp,-96
     6e2:	ec86                	sd	ra,88(sp)
     6e4:	e8a2                	sd	s0,80(sp)
     6e6:	e4a6                	sd	s1,72(sp)
     6e8:	e0ca                	sd	s2,64(sp)
     6ea:	fc4e                	sd	s3,56(sp)
     6ec:	f852                	sd	s4,48(sp)
     6ee:	f456                	sd	s5,40(sp)
     6f0:	1080                	addi	s0,sp,96
     6f2:	8aaa                	mv	s5,a0
  unlink("truncfile");
     6f4:	00005517          	auipc	a0,0x5
     6f8:	c9c50513          	addi	a0,a0,-868 # 5390 <malloc+0x170>
     6fc:	684040ef          	jal	ra,4d80 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     700:	60100593          	li	a1,1537
     704:	00005517          	auipc	a0,0x5
     708:	c8c50513          	addi	a0,a0,-884 # 5390 <malloc+0x170>
     70c:	664040ef          	jal	ra,4d70 <open>
     710:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     712:	4611                	li	a2,4
     714:	00005597          	auipc	a1,0x5
     718:	c8c58593          	addi	a1,a1,-884 # 53a0 <malloc+0x180>
     71c:	634040ef          	jal	ra,4d50 <write>
  close(fd1);
     720:	8526                	mv	a0,s1
     722:	636040ef          	jal	ra,4d58 <close>
  int fd2 = open("truncfile", O_RDONLY);
     726:	4581                	li	a1,0
     728:	00005517          	auipc	a0,0x5
     72c:	c6850513          	addi	a0,a0,-920 # 5390 <malloc+0x170>
     730:	640040ef          	jal	ra,4d70 <open>
     734:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     736:	02000613          	li	a2,32
     73a:	fa040593          	addi	a1,s0,-96
     73e:	60a040ef          	jal	ra,4d48 <read>
  if(n != 4){
     742:	4791                	li	a5,4
     744:	0af51863          	bne	a0,a5,7f4 <truncate1+0x114>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     748:	40100593          	li	a1,1025
     74c:	00005517          	auipc	a0,0x5
     750:	c4450513          	addi	a0,a0,-956 # 5390 <malloc+0x170>
     754:	61c040ef          	jal	ra,4d70 <open>
     758:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     75a:	4581                	li	a1,0
     75c:	00005517          	auipc	a0,0x5
     760:	c3450513          	addi	a0,a0,-972 # 5390 <malloc+0x170>
     764:	60c040ef          	jal	ra,4d70 <open>
     768:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     76a:	02000613          	li	a2,32
     76e:	fa040593          	addi	a1,s0,-96
     772:	5d6040ef          	jal	ra,4d48 <read>
     776:	8a2a                	mv	s4,a0
  if(n != 0){
     778:	e949                	bnez	a0,80a <truncate1+0x12a>
  n = read(fd2, buf, sizeof(buf));
     77a:	02000613          	li	a2,32
     77e:	fa040593          	addi	a1,s0,-96
     782:	8526                	mv	a0,s1
     784:	5c4040ef          	jal	ra,4d48 <read>
     788:	8a2a                	mv	s4,a0
  if(n != 0){
     78a:	e155                	bnez	a0,82e <truncate1+0x14e>
  write(fd1, "abcdef", 6);
     78c:	4619                	li	a2,6
     78e:	00005597          	auipc	a1,0x5
     792:	e7a58593          	addi	a1,a1,-390 # 5608 <malloc+0x3e8>
     796:	854e                	mv	a0,s3
     798:	5b8040ef          	jal	ra,4d50 <write>
  n = read(fd3, buf, sizeof(buf));
     79c:	02000613          	li	a2,32
     7a0:	fa040593          	addi	a1,s0,-96
     7a4:	854a                	mv	a0,s2
     7a6:	5a2040ef          	jal	ra,4d48 <read>
  if(n != 6){
     7aa:	4799                	li	a5,6
     7ac:	0af51363          	bne	a0,a5,852 <truncate1+0x172>
  n = read(fd2, buf, sizeof(buf));
     7b0:	02000613          	li	a2,32
     7b4:	fa040593          	addi	a1,s0,-96
     7b8:	8526                	mv	a0,s1
     7ba:	58e040ef          	jal	ra,4d48 <read>
  if(n != 2){
     7be:	4789                	li	a5,2
     7c0:	0af51463          	bne	a0,a5,868 <truncate1+0x188>
  unlink("truncfile");
     7c4:	00005517          	auipc	a0,0x5
     7c8:	bcc50513          	addi	a0,a0,-1076 # 5390 <malloc+0x170>
     7cc:	5b4040ef          	jal	ra,4d80 <unlink>
  close(fd1);
     7d0:	854e                	mv	a0,s3
     7d2:	586040ef          	jal	ra,4d58 <close>
  close(fd2);
     7d6:	8526                	mv	a0,s1
     7d8:	580040ef          	jal	ra,4d58 <close>
  close(fd3);
     7dc:	854a                	mv	a0,s2
     7de:	57a040ef          	jal	ra,4d58 <close>
}
     7e2:	60e6                	ld	ra,88(sp)
     7e4:	6446                	ld	s0,80(sp)
     7e6:	64a6                	ld	s1,72(sp)
     7e8:	6906                	ld	s2,64(sp)
     7ea:	79e2                	ld	s3,56(sp)
     7ec:	7a42                	ld	s4,48(sp)
     7ee:	7aa2                	ld	s5,40(sp)
     7f0:	6125                	addi	sp,sp,96
     7f2:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     7f4:	862a                	mv	a2,a0
     7f6:	85d6                	mv	a1,s5
     7f8:	00005517          	auipc	a0,0x5
     7fc:	db050513          	addi	a0,a0,-592 # 55a8 <malloc+0x388>
     800:	16d040ef          	jal	ra,516c <printf>
    exit(1);
     804:	4505                	li	a0,1
     806:	52a040ef          	jal	ra,4d30 <exit>
    printf("aaa fd3=%d\n", fd3);
     80a:	85ca                	mv	a1,s2
     80c:	00005517          	auipc	a0,0x5
     810:	dbc50513          	addi	a0,a0,-580 # 55c8 <malloc+0x3a8>
     814:	159040ef          	jal	ra,516c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     818:	8652                	mv	a2,s4
     81a:	85d6                	mv	a1,s5
     81c:	00005517          	auipc	a0,0x5
     820:	dbc50513          	addi	a0,a0,-580 # 55d8 <malloc+0x3b8>
     824:	149040ef          	jal	ra,516c <printf>
    exit(1);
     828:	4505                	li	a0,1
     82a:	506040ef          	jal	ra,4d30 <exit>
    printf("bbb fd2=%d\n", fd2);
     82e:	85a6                	mv	a1,s1
     830:	00005517          	auipc	a0,0x5
     834:	dc850513          	addi	a0,a0,-568 # 55f8 <malloc+0x3d8>
     838:	135040ef          	jal	ra,516c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     83c:	8652                	mv	a2,s4
     83e:	85d6                	mv	a1,s5
     840:	00005517          	auipc	a0,0x5
     844:	d9850513          	addi	a0,a0,-616 # 55d8 <malloc+0x3b8>
     848:	125040ef          	jal	ra,516c <printf>
    exit(1);
     84c:	4505                	li	a0,1
     84e:	4e2040ef          	jal	ra,4d30 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     852:	862a                	mv	a2,a0
     854:	85d6                	mv	a1,s5
     856:	00005517          	auipc	a0,0x5
     85a:	dba50513          	addi	a0,a0,-582 # 5610 <malloc+0x3f0>
     85e:	10f040ef          	jal	ra,516c <printf>
    exit(1);
     862:	4505                	li	a0,1
     864:	4cc040ef          	jal	ra,4d30 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     868:	862a                	mv	a2,a0
     86a:	85d6                	mv	a1,s5
     86c:	00005517          	auipc	a0,0x5
     870:	dc450513          	addi	a0,a0,-572 # 5630 <malloc+0x410>
     874:	0f9040ef          	jal	ra,516c <printf>
    exit(1);
     878:	4505                	li	a0,1
     87a:	4b6040ef          	jal	ra,4d30 <exit>

000000000000087e <writetest>:
{
     87e:	7139                	addi	sp,sp,-64
     880:	fc06                	sd	ra,56(sp)
     882:	f822                	sd	s0,48(sp)
     884:	f426                	sd	s1,40(sp)
     886:	f04a                	sd	s2,32(sp)
     888:	ec4e                	sd	s3,24(sp)
     88a:	e852                	sd	s4,16(sp)
     88c:	e456                	sd	s5,8(sp)
     88e:	e05a                	sd	s6,0(sp)
     890:	0080                	addi	s0,sp,64
     892:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     894:	20200593          	li	a1,514
     898:	00005517          	auipc	a0,0x5
     89c:	db850513          	addi	a0,a0,-584 # 5650 <malloc+0x430>
     8a0:	4d0040ef          	jal	ra,4d70 <open>
  if(fd < 0){
     8a4:	08054f63          	bltz	a0,942 <writetest+0xc4>
     8a8:	892a                	mv	s2,a0
     8aa:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8ac:	00005997          	auipc	s3,0x5
     8b0:	dcc98993          	addi	s3,s3,-564 # 5678 <malloc+0x458>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8b4:	00005a97          	auipc	s5,0x5
     8b8:	dfca8a93          	addi	s5,s5,-516 # 56b0 <malloc+0x490>
  for(i = 0; i < N; i++){
     8bc:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8c0:	4629                	li	a2,10
     8c2:	85ce                	mv	a1,s3
     8c4:	854a                	mv	a0,s2
     8c6:	48a040ef          	jal	ra,4d50 <write>
     8ca:	47a9                	li	a5,10
     8cc:	08f51563          	bne	a0,a5,956 <writetest+0xd8>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8d0:	4629                	li	a2,10
     8d2:	85d6                	mv	a1,s5
     8d4:	854a                	mv	a0,s2
     8d6:	47a040ef          	jal	ra,4d50 <write>
     8da:	47a9                	li	a5,10
     8dc:	08f51863          	bne	a0,a5,96c <writetest+0xee>
  for(i = 0; i < N; i++){
     8e0:	2485                	addiw	s1,s1,1
     8e2:	fd449fe3          	bne	s1,s4,8c0 <writetest+0x42>
  close(fd);
     8e6:	854a                	mv	a0,s2
     8e8:	470040ef          	jal	ra,4d58 <close>
  fd = open("small", O_RDONLY);
     8ec:	4581                	li	a1,0
     8ee:	00005517          	auipc	a0,0x5
     8f2:	d6250513          	addi	a0,a0,-670 # 5650 <malloc+0x430>
     8f6:	47a040ef          	jal	ra,4d70 <open>
     8fa:	84aa                	mv	s1,a0
  if(fd < 0){
     8fc:	08054363          	bltz	a0,982 <writetest+0x104>
  i = read(fd, buf, N*SZ*2);
     900:	7d000613          	li	a2,2000
     904:	0000b597          	auipc	a1,0xb
     908:	3b458593          	addi	a1,a1,948 # bcb8 <buf>
     90c:	43c040ef          	jal	ra,4d48 <read>
  if(i != N*SZ*2){
     910:	7d000793          	li	a5,2000
     914:	08f51163          	bne	a0,a5,996 <writetest+0x118>
  close(fd);
     918:	8526                	mv	a0,s1
     91a:	43e040ef          	jal	ra,4d58 <close>
  if(unlink("small") < 0){
     91e:	00005517          	auipc	a0,0x5
     922:	d3250513          	addi	a0,a0,-718 # 5650 <malloc+0x430>
     926:	45a040ef          	jal	ra,4d80 <unlink>
     92a:	08054063          	bltz	a0,9aa <writetest+0x12c>
}
     92e:	70e2                	ld	ra,56(sp)
     930:	7442                	ld	s0,48(sp)
     932:	74a2                	ld	s1,40(sp)
     934:	7902                	ld	s2,32(sp)
     936:	69e2                	ld	s3,24(sp)
     938:	6a42                	ld	s4,16(sp)
     93a:	6aa2                	ld	s5,8(sp)
     93c:	6b02                	ld	s6,0(sp)
     93e:	6121                	addi	sp,sp,64
     940:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     942:	85da                	mv	a1,s6
     944:	00005517          	auipc	a0,0x5
     948:	d1450513          	addi	a0,a0,-748 # 5658 <malloc+0x438>
     94c:	021040ef          	jal	ra,516c <printf>
    exit(1);
     950:	4505                	li	a0,1
     952:	3de040ef          	jal	ra,4d30 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     956:	8626                	mv	a2,s1
     958:	85da                	mv	a1,s6
     95a:	00005517          	auipc	a0,0x5
     95e:	d2e50513          	addi	a0,a0,-722 # 5688 <malloc+0x468>
     962:	00b040ef          	jal	ra,516c <printf>
      exit(1);
     966:	4505                	li	a0,1
     968:	3c8040ef          	jal	ra,4d30 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     96c:	8626                	mv	a2,s1
     96e:	85da                	mv	a1,s6
     970:	00005517          	auipc	a0,0x5
     974:	d5050513          	addi	a0,a0,-688 # 56c0 <malloc+0x4a0>
     978:	7f4040ef          	jal	ra,516c <printf>
      exit(1);
     97c:	4505                	li	a0,1
     97e:	3b2040ef          	jal	ra,4d30 <exit>
    printf("%s: error: open small failed!\n", s);
     982:	85da                	mv	a1,s6
     984:	00005517          	auipc	a0,0x5
     988:	d6450513          	addi	a0,a0,-668 # 56e8 <malloc+0x4c8>
     98c:	7e0040ef          	jal	ra,516c <printf>
    exit(1);
     990:	4505                	li	a0,1
     992:	39e040ef          	jal	ra,4d30 <exit>
    printf("%s: read failed\n", s);
     996:	85da                	mv	a1,s6
     998:	00005517          	auipc	a0,0x5
     99c:	d7050513          	addi	a0,a0,-656 # 5708 <malloc+0x4e8>
     9a0:	7cc040ef          	jal	ra,516c <printf>
    exit(1);
     9a4:	4505                	li	a0,1
     9a6:	38a040ef          	jal	ra,4d30 <exit>
    printf("%s: unlink small failed\n", s);
     9aa:	85da                	mv	a1,s6
     9ac:	00005517          	auipc	a0,0x5
     9b0:	d7450513          	addi	a0,a0,-652 # 5720 <malloc+0x500>
     9b4:	7b8040ef          	jal	ra,516c <printf>
    exit(1);
     9b8:	4505                	li	a0,1
     9ba:	376040ef          	jal	ra,4d30 <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	d6a50513          	addi	a0,a0,-662 # 5740 <malloc+0x520>
     9de:	392040ef          	jal	ra,4d70 <open>
     9e2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9e6:	0000b917          	auipc	s2,0xb
     9ea:	2d290913          	addi	s2,s2,722 # bcb8 <buf>
  for(i = 0; i < MAXFILE; i++){
     9ee:	10c00a13          	li	s4,268
  if(fd < 0){
     9f2:	06054463          	bltz	a0,a5a <writebig+0x9c>
    ((int*)buf)[0] = i;
     9f6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fa:	40000613          	li	a2,1024
     9fe:	85ca                	mv	a1,s2
     a00:	854e                	mv	a0,s3
     a02:	34e040ef          	jal	ra,4d50 <write>
     a06:	40000793          	li	a5,1024
     a0a:	06f51263          	bne	a0,a5,a6e <writebig+0xb0>
  for(i = 0; i < MAXFILE; i++){
     a0e:	2485                	addiw	s1,s1,1
     a10:	ff4493e3          	bne	s1,s4,9f6 <writebig+0x38>
  close(fd);
     a14:	854e                	mv	a0,s3
     a16:	342040ef          	jal	ra,4d58 <close>
  fd = open("big", O_RDONLY);
     a1a:	4581                	li	a1,0
     a1c:	00005517          	auipc	a0,0x5
     a20:	d2450513          	addi	a0,a0,-732 # 5740 <malloc+0x520>
     a24:	34c040ef          	jal	ra,4d70 <open>
     a28:	89aa                	mv	s3,a0
  n = 0;
     a2a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a2c:	0000b917          	auipc	s2,0xb
     a30:	28c90913          	addi	s2,s2,652 # bcb8 <buf>
  if(fd < 0){
     a34:	04054863          	bltz	a0,a84 <writebig+0xc6>
    i = read(fd, buf, BSIZE);
     a38:	40000613          	li	a2,1024
     a3c:	85ca                	mv	a1,s2
     a3e:	854e                	mv	a0,s3
     a40:	308040ef          	jal	ra,4d48 <read>
    if(i == 0){
     a44:	c931                	beqz	a0,a98 <writebig+0xda>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	08f51a63          	bne	a0,a5,ade <writebig+0x120>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0a969163          	bne	a3,s1,af4 <writebig+0x136>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	b7c5                	j	a38 <writebig+0x7a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00005517          	auipc	a0,0x5
     a60:	cec50513          	addi	a0,a0,-788 # 5748 <malloc+0x528>
     a64:	708040ef          	jal	ra,516c <printf>
    exit(1);
     a68:	4505                	li	a0,1
     a6a:	2c6040ef          	jal	ra,4d30 <exit>
      printf("%s: error: write big file failed i=%d\n", s, i);
     a6e:	8626                	mv	a2,s1
     a70:	85d6                	mv	a1,s5
     a72:	00005517          	auipc	a0,0x5
     a76:	cf650513          	addi	a0,a0,-778 # 5768 <malloc+0x548>
     a7a:	6f2040ef          	jal	ra,516c <printf>
      exit(1);
     a7e:	4505                	li	a0,1
     a80:	2b0040ef          	jal	ra,4d30 <exit>
    printf("%s: error: open big failed!\n", s);
     a84:	85d6                	mv	a1,s5
     a86:	00005517          	auipc	a0,0x5
     a8a:	d0a50513          	addi	a0,a0,-758 # 5790 <malloc+0x570>
     a8e:	6de040ef          	jal	ra,516c <printf>
    exit(1);
     a92:	4505                	li	a0,1
     a94:	29c040ef          	jal	ra,4d30 <exit>
      if(n != MAXFILE){
     a98:	10c00793          	li	a5,268
     a9c:	02f49663          	bne	s1,a5,ac8 <writebig+0x10a>
  close(fd);
     aa0:	854e                	mv	a0,s3
     aa2:	2b6040ef          	jal	ra,4d58 <close>
  if(unlink("big") < 0){
     aa6:	00005517          	auipc	a0,0x5
     aaa:	c9a50513          	addi	a0,a0,-870 # 5740 <malloc+0x520>
     aae:	2d2040ef          	jal	ra,4d80 <unlink>
     ab2:	04054c63          	bltz	a0,b0a <writebig+0x14c>
}
     ab6:	70e2                	ld	ra,56(sp)
     ab8:	7442                	ld	s0,48(sp)
     aba:	74a2                	ld	s1,40(sp)
     abc:	7902                	ld	s2,32(sp)
     abe:	69e2                	ld	s3,24(sp)
     ac0:	6a42                	ld	s4,16(sp)
     ac2:	6aa2                	ld	s5,8(sp)
     ac4:	6121                	addi	sp,sp,64
     ac6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ac8:	8626                	mv	a2,s1
     aca:	85d6                	mv	a1,s5
     acc:	00005517          	auipc	a0,0x5
     ad0:	ce450513          	addi	a0,a0,-796 # 57b0 <malloc+0x590>
     ad4:	698040ef          	jal	ra,516c <printf>
        exit(1);
     ad8:	4505                	li	a0,1
     ada:	256040ef          	jal	ra,4d30 <exit>
      printf("%s: read failed %d\n", s, i);
     ade:	862a                	mv	a2,a0
     ae0:	85d6                	mv	a1,s5
     ae2:	00005517          	auipc	a0,0x5
     ae6:	cf650513          	addi	a0,a0,-778 # 57d8 <malloc+0x5b8>
     aea:	682040ef          	jal	ra,516c <printf>
      exit(1);
     aee:	4505                	li	a0,1
     af0:	240040ef          	jal	ra,4d30 <exit>
      printf("%s: read content of block %d is %d\n", s,
     af4:	8626                	mv	a2,s1
     af6:	85d6                	mv	a1,s5
     af8:	00005517          	auipc	a0,0x5
     afc:	cf850513          	addi	a0,a0,-776 # 57f0 <malloc+0x5d0>
     b00:	66c040ef          	jal	ra,516c <printf>
      exit(1);
     b04:	4505                	li	a0,1
     b06:	22a040ef          	jal	ra,4d30 <exit>
    printf("%s: unlink big failed\n", s);
     b0a:	85d6                	mv	a1,s5
     b0c:	00005517          	auipc	a0,0x5
     b10:	d0c50513          	addi	a0,a0,-756 # 5818 <malloc+0x5f8>
     b14:	658040ef          	jal	ra,516c <printf>
    exit(1);
     b18:	4505                	li	a0,1
     b1a:	216040ef          	jal	ra,4d30 <exit>

0000000000000b1e <unlinkread>:
{
     b1e:	7179                	addi	sp,sp,-48
     b20:	f406                	sd	ra,40(sp)
     b22:	f022                	sd	s0,32(sp)
     b24:	ec26                	sd	s1,24(sp)
     b26:	e84a                	sd	s2,16(sp)
     b28:	e44e                	sd	s3,8(sp)
     b2a:	1800                	addi	s0,sp,48
     b2c:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b2e:	20200593          	li	a1,514
     b32:	00005517          	auipc	a0,0x5
     b36:	cfe50513          	addi	a0,a0,-770 # 5830 <malloc+0x610>
     b3a:	236040ef          	jal	ra,4d70 <open>
  if(fd < 0){
     b3e:	0a054f63          	bltz	a0,bfc <unlinkread+0xde>
     b42:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b44:	4615                	li	a2,5
     b46:	00005597          	auipc	a1,0x5
     b4a:	d1a58593          	addi	a1,a1,-742 # 5860 <malloc+0x640>
     b4e:	202040ef          	jal	ra,4d50 <write>
  close(fd);
     b52:	8526                	mv	a0,s1
     b54:	204040ef          	jal	ra,4d58 <close>
  fd = open("unlinkread", O_RDWR);
     b58:	4589                	li	a1,2
     b5a:	00005517          	auipc	a0,0x5
     b5e:	cd650513          	addi	a0,a0,-810 # 5830 <malloc+0x610>
     b62:	20e040ef          	jal	ra,4d70 <open>
     b66:	84aa                	mv	s1,a0
  if(fd < 0){
     b68:	0a054463          	bltz	a0,c10 <unlinkread+0xf2>
  if(unlink("unlinkread") != 0){
     b6c:	00005517          	auipc	a0,0x5
     b70:	cc450513          	addi	a0,a0,-828 # 5830 <malloc+0x610>
     b74:	20c040ef          	jal	ra,4d80 <unlink>
     b78:	e555                	bnez	a0,c24 <unlinkread+0x106>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     b7a:	20200593          	li	a1,514
     b7e:	00005517          	auipc	a0,0x5
     b82:	cb250513          	addi	a0,a0,-846 # 5830 <malloc+0x610>
     b86:	1ea040ef          	jal	ra,4d70 <open>
     b8a:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     b8c:	460d                	li	a2,3
     b8e:	00005597          	auipc	a1,0x5
     b92:	d1a58593          	addi	a1,a1,-742 # 58a8 <malloc+0x688>
     b96:	1ba040ef          	jal	ra,4d50 <write>
  close(fd1);
     b9a:	854a                	mv	a0,s2
     b9c:	1bc040ef          	jal	ra,4d58 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     ba0:	660d                	lui	a2,0x3
     ba2:	0000b597          	auipc	a1,0xb
     ba6:	11658593          	addi	a1,a1,278 # bcb8 <buf>
     baa:	8526                	mv	a0,s1
     bac:	19c040ef          	jal	ra,4d48 <read>
     bb0:	4795                	li	a5,5
     bb2:	08f51363          	bne	a0,a5,c38 <unlinkread+0x11a>
  if(buf[0] != 'h'){
     bb6:	0000b717          	auipc	a4,0xb
     bba:	10274703          	lbu	a4,258(a4) # bcb8 <buf>
     bbe:	06800793          	li	a5,104
     bc2:	08f71563          	bne	a4,a5,c4c <unlinkread+0x12e>
  if(write(fd, buf, 10) != 10){
     bc6:	4629                	li	a2,10
     bc8:	0000b597          	auipc	a1,0xb
     bcc:	0f058593          	addi	a1,a1,240 # bcb8 <buf>
     bd0:	8526                	mv	a0,s1
     bd2:	17e040ef          	jal	ra,4d50 <write>
     bd6:	47a9                	li	a5,10
     bd8:	08f51463          	bne	a0,a5,c60 <unlinkread+0x142>
  close(fd);
     bdc:	8526                	mv	a0,s1
     bde:	17a040ef          	jal	ra,4d58 <close>
  unlink("unlinkread");
     be2:	00005517          	auipc	a0,0x5
     be6:	c4e50513          	addi	a0,a0,-946 # 5830 <malloc+0x610>
     bea:	196040ef          	jal	ra,4d80 <unlink>
}
     bee:	70a2                	ld	ra,40(sp)
     bf0:	7402                	ld	s0,32(sp)
     bf2:	64e2                	ld	s1,24(sp)
     bf4:	6942                	ld	s2,16(sp)
     bf6:	69a2                	ld	s3,8(sp)
     bf8:	6145                	addi	sp,sp,48
     bfa:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     bfc:	85ce                	mv	a1,s3
     bfe:	00005517          	auipc	a0,0x5
     c02:	c4250513          	addi	a0,a0,-958 # 5840 <malloc+0x620>
     c06:	566040ef          	jal	ra,516c <printf>
    exit(1);
     c0a:	4505                	li	a0,1
     c0c:	124040ef          	jal	ra,4d30 <exit>
    printf("%s: open unlinkread failed\n", s);
     c10:	85ce                	mv	a1,s3
     c12:	00005517          	auipc	a0,0x5
     c16:	c5650513          	addi	a0,a0,-938 # 5868 <malloc+0x648>
     c1a:	552040ef          	jal	ra,516c <printf>
    exit(1);
     c1e:	4505                	li	a0,1
     c20:	110040ef          	jal	ra,4d30 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     c24:	85ce                	mv	a1,s3
     c26:	00005517          	auipc	a0,0x5
     c2a:	c6250513          	addi	a0,a0,-926 # 5888 <malloc+0x668>
     c2e:	53e040ef          	jal	ra,516c <printf>
    exit(1);
     c32:	4505                	li	a0,1
     c34:	0fc040ef          	jal	ra,4d30 <exit>
    printf("%s: unlinkread read failed", s);
     c38:	85ce                	mv	a1,s3
     c3a:	00005517          	auipc	a0,0x5
     c3e:	c7650513          	addi	a0,a0,-906 # 58b0 <malloc+0x690>
     c42:	52a040ef          	jal	ra,516c <printf>
    exit(1);
     c46:	4505                	li	a0,1
     c48:	0e8040ef          	jal	ra,4d30 <exit>
    printf("%s: unlinkread wrong data\n", s);
     c4c:	85ce                	mv	a1,s3
     c4e:	00005517          	auipc	a0,0x5
     c52:	c8250513          	addi	a0,a0,-894 # 58d0 <malloc+0x6b0>
     c56:	516040ef          	jal	ra,516c <printf>
    exit(1);
     c5a:	4505                	li	a0,1
     c5c:	0d4040ef          	jal	ra,4d30 <exit>
    printf("%s: unlinkread write failed\n", s);
     c60:	85ce                	mv	a1,s3
     c62:	00005517          	auipc	a0,0x5
     c66:	c8e50513          	addi	a0,a0,-882 # 58f0 <malloc+0x6d0>
     c6a:	502040ef          	jal	ra,516c <printf>
    exit(1);
     c6e:	4505                	li	a0,1
     c70:	0c0040ef          	jal	ra,4d30 <exit>

0000000000000c74 <linktest>:
{
     c74:	1101                	addi	sp,sp,-32
     c76:	ec06                	sd	ra,24(sp)
     c78:	e822                	sd	s0,16(sp)
     c7a:	e426                	sd	s1,8(sp)
     c7c:	e04a                	sd	s2,0(sp)
     c7e:	1000                	addi	s0,sp,32
     c80:	892a                	mv	s2,a0
  unlink("lf1");
     c82:	00005517          	auipc	a0,0x5
     c86:	c8e50513          	addi	a0,a0,-882 # 5910 <malloc+0x6f0>
     c8a:	0f6040ef          	jal	ra,4d80 <unlink>
  unlink("lf2");
     c8e:	00005517          	auipc	a0,0x5
     c92:	c8a50513          	addi	a0,a0,-886 # 5918 <malloc+0x6f8>
     c96:	0ea040ef          	jal	ra,4d80 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     c9a:	20200593          	li	a1,514
     c9e:	00005517          	auipc	a0,0x5
     ca2:	c7250513          	addi	a0,a0,-910 # 5910 <malloc+0x6f0>
     ca6:	0ca040ef          	jal	ra,4d70 <open>
  if(fd < 0){
     caa:	0c054f63          	bltz	a0,d88 <linktest+0x114>
     cae:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     cb0:	4615                	li	a2,5
     cb2:	00005597          	auipc	a1,0x5
     cb6:	bae58593          	addi	a1,a1,-1106 # 5860 <malloc+0x640>
     cba:	096040ef          	jal	ra,4d50 <write>
     cbe:	4795                	li	a5,5
     cc0:	0cf51e63          	bne	a0,a5,d9c <linktest+0x128>
  close(fd);
     cc4:	8526                	mv	a0,s1
     cc6:	092040ef          	jal	ra,4d58 <close>
  if(link("lf1", "lf2") < 0){
     cca:	00005597          	auipc	a1,0x5
     cce:	c4e58593          	addi	a1,a1,-946 # 5918 <malloc+0x6f8>
     cd2:	00005517          	auipc	a0,0x5
     cd6:	c3e50513          	addi	a0,a0,-962 # 5910 <malloc+0x6f0>
     cda:	0b6040ef          	jal	ra,4d90 <link>
     cde:	0c054963          	bltz	a0,db0 <linktest+0x13c>
  unlink("lf1");
     ce2:	00005517          	auipc	a0,0x5
     ce6:	c2e50513          	addi	a0,a0,-978 # 5910 <malloc+0x6f0>
     cea:	096040ef          	jal	ra,4d80 <unlink>
  if(open("lf1", 0) >= 0){
     cee:	4581                	li	a1,0
     cf0:	00005517          	auipc	a0,0x5
     cf4:	c2050513          	addi	a0,a0,-992 # 5910 <malloc+0x6f0>
     cf8:	078040ef          	jal	ra,4d70 <open>
     cfc:	0c055463          	bgez	a0,dc4 <linktest+0x150>
  fd = open("lf2", 0);
     d00:	4581                	li	a1,0
     d02:	00005517          	auipc	a0,0x5
     d06:	c1650513          	addi	a0,a0,-1002 # 5918 <malloc+0x6f8>
     d0a:	066040ef          	jal	ra,4d70 <open>
     d0e:	84aa                	mv	s1,a0
  if(fd < 0){
     d10:	0c054463          	bltz	a0,dd8 <linktest+0x164>
  if(read(fd, buf, sizeof(buf)) != SZ){
     d14:	660d                	lui	a2,0x3
     d16:	0000b597          	auipc	a1,0xb
     d1a:	fa258593          	addi	a1,a1,-94 # bcb8 <buf>
     d1e:	02a040ef          	jal	ra,4d48 <read>
     d22:	4795                	li	a5,5
     d24:	0cf51463          	bne	a0,a5,dec <linktest+0x178>
  close(fd);
     d28:	8526                	mv	a0,s1
     d2a:	02e040ef          	jal	ra,4d58 <close>
  if(link("lf2", "lf2") >= 0){
     d2e:	00005597          	auipc	a1,0x5
     d32:	bea58593          	addi	a1,a1,-1046 # 5918 <malloc+0x6f8>
     d36:	852e                	mv	a0,a1
     d38:	058040ef          	jal	ra,4d90 <link>
     d3c:	0c055263          	bgez	a0,e00 <linktest+0x18c>
  unlink("lf2");
     d40:	00005517          	auipc	a0,0x5
     d44:	bd850513          	addi	a0,a0,-1064 # 5918 <malloc+0x6f8>
     d48:	038040ef          	jal	ra,4d80 <unlink>
  if(link("lf2", "lf1") >= 0){
     d4c:	00005597          	auipc	a1,0x5
     d50:	bc458593          	addi	a1,a1,-1084 # 5910 <malloc+0x6f0>
     d54:	00005517          	auipc	a0,0x5
     d58:	bc450513          	addi	a0,a0,-1084 # 5918 <malloc+0x6f8>
     d5c:	034040ef          	jal	ra,4d90 <link>
     d60:	0a055a63          	bgez	a0,e14 <linktest+0x1a0>
  if(link(".", "lf1") >= 0){
     d64:	00005597          	auipc	a1,0x5
     d68:	bac58593          	addi	a1,a1,-1108 # 5910 <malloc+0x6f0>
     d6c:	00005517          	auipc	a0,0x5
     d70:	cb450513          	addi	a0,a0,-844 # 5a20 <malloc+0x800>
     d74:	01c040ef          	jal	ra,4d90 <link>
     d78:	0a055863          	bgez	a0,e28 <linktest+0x1b4>
}
     d7c:	60e2                	ld	ra,24(sp)
     d7e:	6442                	ld	s0,16(sp)
     d80:	64a2                	ld	s1,8(sp)
     d82:	6902                	ld	s2,0(sp)
     d84:	6105                	addi	sp,sp,32
     d86:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     d88:	85ca                	mv	a1,s2
     d8a:	00005517          	auipc	a0,0x5
     d8e:	b9650513          	addi	a0,a0,-1130 # 5920 <malloc+0x700>
     d92:	3da040ef          	jal	ra,516c <printf>
    exit(1);
     d96:	4505                	li	a0,1
     d98:	799030ef          	jal	ra,4d30 <exit>
    printf("%s: write lf1 failed\n", s);
     d9c:	85ca                	mv	a1,s2
     d9e:	00005517          	auipc	a0,0x5
     da2:	b9a50513          	addi	a0,a0,-1126 # 5938 <malloc+0x718>
     da6:	3c6040ef          	jal	ra,516c <printf>
    exit(1);
     daa:	4505                	li	a0,1
     dac:	785030ef          	jal	ra,4d30 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     db0:	85ca                	mv	a1,s2
     db2:	00005517          	auipc	a0,0x5
     db6:	b9e50513          	addi	a0,a0,-1122 # 5950 <malloc+0x730>
     dba:	3b2040ef          	jal	ra,516c <printf>
    exit(1);
     dbe:	4505                	li	a0,1
     dc0:	771030ef          	jal	ra,4d30 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     dc4:	85ca                	mv	a1,s2
     dc6:	00005517          	auipc	a0,0x5
     dca:	baa50513          	addi	a0,a0,-1110 # 5970 <malloc+0x750>
     dce:	39e040ef          	jal	ra,516c <printf>
    exit(1);
     dd2:	4505                	li	a0,1
     dd4:	75d030ef          	jal	ra,4d30 <exit>
    printf("%s: open lf2 failed\n", s);
     dd8:	85ca                	mv	a1,s2
     dda:	00005517          	auipc	a0,0x5
     dde:	bc650513          	addi	a0,a0,-1082 # 59a0 <malloc+0x780>
     de2:	38a040ef          	jal	ra,516c <printf>
    exit(1);
     de6:	4505                	li	a0,1
     de8:	749030ef          	jal	ra,4d30 <exit>
    printf("%s: read lf2 failed\n", s);
     dec:	85ca                	mv	a1,s2
     dee:	00005517          	auipc	a0,0x5
     df2:	bca50513          	addi	a0,a0,-1078 # 59b8 <malloc+0x798>
     df6:	376040ef          	jal	ra,516c <printf>
    exit(1);
     dfa:	4505                	li	a0,1
     dfc:	735030ef          	jal	ra,4d30 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     e00:	85ca                	mv	a1,s2
     e02:	00005517          	auipc	a0,0x5
     e06:	bce50513          	addi	a0,a0,-1074 # 59d0 <malloc+0x7b0>
     e0a:	362040ef          	jal	ra,516c <printf>
    exit(1);
     e0e:	4505                	li	a0,1
     e10:	721030ef          	jal	ra,4d30 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     e14:	85ca                	mv	a1,s2
     e16:	00005517          	auipc	a0,0x5
     e1a:	be250513          	addi	a0,a0,-1054 # 59f8 <malloc+0x7d8>
     e1e:	34e040ef          	jal	ra,516c <printf>
    exit(1);
     e22:	4505                	li	a0,1
     e24:	70d030ef          	jal	ra,4d30 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     e28:	85ca                	mv	a1,s2
     e2a:	00005517          	auipc	a0,0x5
     e2e:	bfe50513          	addi	a0,a0,-1026 # 5a28 <malloc+0x808>
     e32:	33a040ef          	jal	ra,516c <printf>
    exit(1);
     e36:	4505                	li	a0,1
     e38:	6f9030ef          	jal	ra,4d30 <exit>

0000000000000e3c <validatetest>:
{
     e3c:	7139                	addi	sp,sp,-64
     e3e:	fc06                	sd	ra,56(sp)
     e40:	f822                	sd	s0,48(sp)
     e42:	f426                	sd	s1,40(sp)
     e44:	f04a                	sd	s2,32(sp)
     e46:	ec4e                	sd	s3,24(sp)
     e48:	e852                	sd	s4,16(sp)
     e4a:	e456                	sd	s5,8(sp)
     e4c:	e05a                	sd	s6,0(sp)
     e4e:	0080                	addi	s0,sp,64
     e50:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e52:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
     e54:	00005997          	auipc	s3,0x5
     e58:	bf498993          	addi	s3,s3,-1036 # 5a48 <malloc+0x828>
     e5c:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e5e:	6a85                	lui	s5,0x1
     e60:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
     e64:	85a6                	mv	a1,s1
     e66:	854e                	mv	a0,s3
     e68:	729030ef          	jal	ra,4d90 <link>
     e6c:	01251f63          	bne	a0,s2,e8a <validatetest+0x4e>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e70:	94d6                	add	s1,s1,s5
     e72:	ff4499e3          	bne	s1,s4,e64 <validatetest+0x28>
}
     e76:	70e2                	ld	ra,56(sp)
     e78:	7442                	ld	s0,48(sp)
     e7a:	74a2                	ld	s1,40(sp)
     e7c:	7902                	ld	s2,32(sp)
     e7e:	69e2                	ld	s3,24(sp)
     e80:	6a42                	ld	s4,16(sp)
     e82:	6aa2                	ld	s5,8(sp)
     e84:	6b02                	ld	s6,0(sp)
     e86:	6121                	addi	sp,sp,64
     e88:	8082                	ret
      printf("%s: link should not succeed\n", s);
     e8a:	85da                	mv	a1,s6
     e8c:	00005517          	auipc	a0,0x5
     e90:	bcc50513          	addi	a0,a0,-1076 # 5a58 <malloc+0x838>
     e94:	2d8040ef          	jal	ra,516c <printf>
      exit(1);
     e98:	4505                	li	a0,1
     e9a:	697030ef          	jal	ra,4d30 <exit>

0000000000000e9e <bigdir>:
{
     e9e:	715d                	addi	sp,sp,-80
     ea0:	e486                	sd	ra,72(sp)
     ea2:	e0a2                	sd	s0,64(sp)
     ea4:	fc26                	sd	s1,56(sp)
     ea6:	f84a                	sd	s2,48(sp)
     ea8:	f44e                	sd	s3,40(sp)
     eaa:	f052                	sd	s4,32(sp)
     eac:	ec56                	sd	s5,24(sp)
     eae:	e85a                	sd	s6,16(sp)
     eb0:	0880                	addi	s0,sp,80
     eb2:	89aa                	mv	s3,a0
  unlink("bd");
     eb4:	00005517          	auipc	a0,0x5
     eb8:	bc450513          	addi	a0,a0,-1084 # 5a78 <malloc+0x858>
     ebc:	6c5030ef          	jal	ra,4d80 <unlink>
  fd = open("bd", O_CREATE);
     ec0:	20000593          	li	a1,512
     ec4:	00005517          	auipc	a0,0x5
     ec8:	bb450513          	addi	a0,a0,-1100 # 5a78 <malloc+0x858>
     ecc:	6a5030ef          	jal	ra,4d70 <open>
  if(fd < 0){
     ed0:	0c054163          	bltz	a0,f92 <bigdir+0xf4>
  close(fd);
     ed4:	685030ef          	jal	ra,4d58 <close>
  for(i = 0; i < N; i++){
     ed8:	4901                	li	s2,0
    name[0] = 'x';
     eda:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     ede:	00005a17          	auipc	s4,0x5
     ee2:	b9aa0a13          	addi	s4,s4,-1126 # 5a78 <malloc+0x858>
  for(i = 0; i < N; i++){
     ee6:	1f400b13          	li	s6,500
    name[0] = 'x';
     eea:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     eee:	41f9571b          	sraiw	a4,s2,0x1f
     ef2:	01a7571b          	srliw	a4,a4,0x1a
     ef6:	012707bb          	addw	a5,a4,s2
     efa:	4067d69b          	sraiw	a3,a5,0x6
     efe:	0306869b          	addiw	a3,a3,48
     f02:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f06:	03f7f793          	andi	a5,a5,63
     f0a:	9f99                	subw	a5,a5,a4
     f0c:	0307879b          	addiw	a5,a5,48
     f10:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f14:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     f18:	fb040593          	addi	a1,s0,-80
     f1c:	8552                	mv	a0,s4
     f1e:	673030ef          	jal	ra,4d90 <link>
     f22:	84aa                	mv	s1,a0
     f24:	e149                	bnez	a0,fa6 <bigdir+0x108>
  for(i = 0; i < N; i++){
     f26:	2905                	addiw	s2,s2,1
     f28:	fd6911e3          	bne	s2,s6,eea <bigdir+0x4c>
  unlink("bd");
     f2c:	00005517          	auipc	a0,0x5
     f30:	b4c50513          	addi	a0,a0,-1204 # 5a78 <malloc+0x858>
     f34:	64d030ef          	jal	ra,4d80 <unlink>
    name[0] = 'x';
     f38:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
     f3c:	1f400a13          	li	s4,500
    name[0] = 'x';
     f40:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
     f44:	41f4d71b          	sraiw	a4,s1,0x1f
     f48:	01a7571b          	srliw	a4,a4,0x1a
     f4c:	009707bb          	addw	a5,a4,s1
     f50:	4067d69b          	sraiw	a3,a5,0x6
     f54:	0306869b          	addiw	a3,a3,48
     f58:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f5c:	03f7f793          	andi	a5,a5,63
     f60:	9f99                	subw	a5,a5,a4
     f62:	0307879b          	addiw	a5,a5,48
     f66:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f6a:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
     f6e:	fb040513          	addi	a0,s0,-80
     f72:	60f030ef          	jal	ra,4d80 <unlink>
     f76:	e529                	bnez	a0,fc0 <bigdir+0x122>
  for(i = 0; i < N; i++){
     f78:	2485                	addiw	s1,s1,1
     f7a:	fd4493e3          	bne	s1,s4,f40 <bigdir+0xa2>
}
     f7e:	60a6                	ld	ra,72(sp)
     f80:	6406                	ld	s0,64(sp)
     f82:	74e2                	ld	s1,56(sp)
     f84:	7942                	ld	s2,48(sp)
     f86:	79a2                	ld	s3,40(sp)
     f88:	7a02                	ld	s4,32(sp)
     f8a:	6ae2                	ld	s5,24(sp)
     f8c:	6b42                	ld	s6,16(sp)
     f8e:	6161                	addi	sp,sp,80
     f90:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     f92:	85ce                	mv	a1,s3
     f94:	00005517          	auipc	a0,0x5
     f98:	aec50513          	addi	a0,a0,-1300 # 5a80 <malloc+0x860>
     f9c:	1d0040ef          	jal	ra,516c <printf>
    exit(1);
     fa0:	4505                	li	a0,1
     fa2:	58f030ef          	jal	ra,4d30 <exit>
      printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, name);
     fa6:	fb040693          	addi	a3,s0,-80
     faa:	864a                	mv	a2,s2
     fac:	85ce                	mv	a1,s3
     fae:	00005517          	auipc	a0,0x5
     fb2:	af250513          	addi	a0,a0,-1294 # 5aa0 <malloc+0x880>
     fb6:	1b6040ef          	jal	ra,516c <printf>
      exit(1);
     fba:	4505                	li	a0,1
     fbc:	575030ef          	jal	ra,4d30 <exit>
      printf("%s: bigdir unlink failed", s);
     fc0:	85ce                	mv	a1,s3
     fc2:	00005517          	auipc	a0,0x5
     fc6:	b0650513          	addi	a0,a0,-1274 # 5ac8 <malloc+0x8a8>
     fca:	1a2040ef          	jal	ra,516c <printf>
      exit(1);
     fce:	4505                	li	a0,1
     fd0:	561030ef          	jal	ra,4d30 <exit>

0000000000000fd4 <pgbug>:
{
     fd4:	7179                	addi	sp,sp,-48
     fd6:	f406                	sd	ra,40(sp)
     fd8:	f022                	sd	s0,32(sp)
     fda:	ec26                	sd	s1,24(sp)
     fdc:	1800                	addi	s0,sp,48
  argv[0] = 0;
     fde:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
     fe2:	00007497          	auipc	s1,0x7
     fe6:	01e48493          	addi	s1,s1,30 # 8000 <big>
     fea:	fd840593          	addi	a1,s0,-40
     fee:	6088                	ld	a0,0(s1)
     ff0:	579030ef          	jal	ra,4d68 <exec>
  pipe(big);
     ff4:	6088                	ld	a0,0(s1)
     ff6:	54b030ef          	jal	ra,4d40 <pipe>
  exit(0);
     ffa:	4501                	li	a0,0
     ffc:	535030ef          	jal	ra,4d30 <exit>

0000000000001000 <badarg>:
{
    1000:	7139                	addi	sp,sp,-64
    1002:	fc06                	sd	ra,56(sp)
    1004:	f822                	sd	s0,48(sp)
    1006:	f426                	sd	s1,40(sp)
    1008:	f04a                	sd	s2,32(sp)
    100a:	ec4e                	sd	s3,24(sp)
    100c:	0080                	addi	s0,sp,64
    100e:	64b1                	lui	s1,0xc
    1010:	35048493          	addi	s1,s1,848 # c350 <buf+0x698>
    argv[0] = (char*)0xffffffff;
    1014:	597d                	li	s2,-1
    1016:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    101a:	00004997          	auipc	s3,0x4
    101e:	31e98993          	addi	s3,s3,798 # 5338 <malloc+0x118>
    argv[0] = (char*)0xffffffff;
    1022:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1026:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    102a:	fc040593          	addi	a1,s0,-64
    102e:	854e                	mv	a0,s3
    1030:	539030ef          	jal	ra,4d68 <exec>
  for(int i = 0; i < 50000; i++){
    1034:	34fd                	addiw	s1,s1,-1
    1036:	f4f5                	bnez	s1,1022 <badarg+0x22>
  exit(0);
    1038:	4501                	li	a0,0
    103a:	4f7030ef          	jal	ra,4d30 <exit>

000000000000103e <copyinstr2>:
{
    103e:	7155                	addi	sp,sp,-208
    1040:	e586                	sd	ra,200(sp)
    1042:	e1a2                	sd	s0,192(sp)
    1044:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1046:	f6840793          	addi	a5,s0,-152
    104a:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    104e:	07800713          	li	a4,120
    1052:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1056:	0785                	addi	a5,a5,1
    1058:	fed79de3          	bne	a5,a3,1052 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    105c:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1060:	f6840513          	addi	a0,s0,-152
    1064:	51d030ef          	jal	ra,4d80 <unlink>
  if(ret != -1){
    1068:	57fd                	li	a5,-1
    106a:	0cf51263          	bne	a0,a5,112e <copyinstr2+0xf0>
  int fd = open(b, O_CREATE | O_WRONLY);
    106e:	20100593          	li	a1,513
    1072:	f6840513          	addi	a0,s0,-152
    1076:	4fb030ef          	jal	ra,4d70 <open>
  if(fd != -1){
    107a:	57fd                	li	a5,-1
    107c:	0cf51563          	bne	a0,a5,1146 <copyinstr2+0x108>
  ret = link(b, b);
    1080:	f6840593          	addi	a1,s0,-152
    1084:	852e                	mv	a0,a1
    1086:	50b030ef          	jal	ra,4d90 <link>
  if(ret != -1){
    108a:	57fd                	li	a5,-1
    108c:	0cf51963          	bne	a0,a5,115e <copyinstr2+0x120>
  char *args[] = { "xx", 0 };
    1090:	00006797          	auipc	a5,0x6
    1094:	b8878793          	addi	a5,a5,-1144 # 6c18 <malloc+0x19f8>
    1098:	f4f43c23          	sd	a5,-168(s0)
    109c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    10a0:	f5840593          	addi	a1,s0,-168
    10a4:	f6840513          	addi	a0,s0,-152
    10a8:	4c1030ef          	jal	ra,4d68 <exec>
  if(ret != -1){
    10ac:	57fd                	li	a5,-1
    10ae:	0cf51563          	bne	a0,a5,1178 <copyinstr2+0x13a>
  int pid = fork();
    10b2:	477030ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    10b6:	0c054d63          	bltz	a0,1190 <copyinstr2+0x152>
  if(pid == 0){
    10ba:	0e051863          	bnez	a0,11aa <copyinstr2+0x16c>
    10be:	00007797          	auipc	a5,0x7
    10c2:	4e278793          	addi	a5,a5,1250 # 85a0 <big.0>
    10c6:	00008697          	auipc	a3,0x8
    10ca:	4da68693          	addi	a3,a3,1242 # 95a0 <big.0+0x1000>
      big[i] = 'x';
    10ce:	07800713          	li	a4,120
    10d2:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    10d6:	0785                	addi	a5,a5,1
    10d8:	fed79de3          	bne	a5,a3,10d2 <copyinstr2+0x94>
    big[PGSIZE] = '\0';
    10dc:	00008797          	auipc	a5,0x8
    10e0:	4c078223          	sb	zero,1220(a5) # 95a0 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    10e4:	00006797          	auipc	a5,0x6
    10e8:	79478793          	addi	a5,a5,1940 # 7878 <malloc+0x2658>
    10ec:	6fb0                	ld	a2,88(a5)
    10ee:	73b4                	ld	a3,96(a5)
    10f0:	77b8                	ld	a4,104(a5)
    10f2:	7bbc                	ld	a5,112(a5)
    10f4:	f2c43823          	sd	a2,-208(s0)
    10f8:	f2d43c23          	sd	a3,-200(s0)
    10fc:	f4e43023          	sd	a4,-192(s0)
    1100:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1104:	f3040593          	addi	a1,s0,-208
    1108:	00004517          	auipc	a0,0x4
    110c:	23050513          	addi	a0,a0,560 # 5338 <malloc+0x118>
    1110:	459030ef          	jal	ra,4d68 <exec>
    if(ret != -1){
    1114:	57fd                	li	a5,-1
    1116:	08f50663          	beq	a0,a5,11a2 <copyinstr2+0x164>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    111a:	55fd                	li	a1,-1
    111c:	00005517          	auipc	a0,0x5
    1120:	a5450513          	addi	a0,a0,-1452 # 5b70 <malloc+0x950>
    1124:	048040ef          	jal	ra,516c <printf>
      exit(1);
    1128:	4505                	li	a0,1
    112a:	407030ef          	jal	ra,4d30 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    112e:	862a                	mv	a2,a0
    1130:	f6840593          	addi	a1,s0,-152
    1134:	00005517          	auipc	a0,0x5
    1138:	9b450513          	addi	a0,a0,-1612 # 5ae8 <malloc+0x8c8>
    113c:	030040ef          	jal	ra,516c <printf>
    exit(1);
    1140:	4505                	li	a0,1
    1142:	3ef030ef          	jal	ra,4d30 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1146:	862a                	mv	a2,a0
    1148:	f6840593          	addi	a1,s0,-152
    114c:	00005517          	auipc	a0,0x5
    1150:	9bc50513          	addi	a0,a0,-1604 # 5b08 <malloc+0x8e8>
    1154:	018040ef          	jal	ra,516c <printf>
    exit(1);
    1158:	4505                	li	a0,1
    115a:	3d7030ef          	jal	ra,4d30 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    115e:	86aa                	mv	a3,a0
    1160:	f6840613          	addi	a2,s0,-152
    1164:	85b2                	mv	a1,a2
    1166:	00005517          	auipc	a0,0x5
    116a:	9c250513          	addi	a0,a0,-1598 # 5b28 <malloc+0x908>
    116e:	7ff030ef          	jal	ra,516c <printf>
    exit(1);
    1172:	4505                	li	a0,1
    1174:	3bd030ef          	jal	ra,4d30 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1178:	567d                	li	a2,-1
    117a:	f6840593          	addi	a1,s0,-152
    117e:	00005517          	auipc	a0,0x5
    1182:	9d250513          	addi	a0,a0,-1582 # 5b50 <malloc+0x930>
    1186:	7e7030ef          	jal	ra,516c <printf>
    exit(1);
    118a:	4505                	li	a0,1
    118c:	3a5030ef          	jal	ra,4d30 <exit>
    printf("fork failed\n");
    1190:	00006517          	auipc	a0,0x6
    1194:	fe050513          	addi	a0,a0,-32 # 7170 <malloc+0x1f50>
    1198:	7d5030ef          	jal	ra,516c <printf>
    exit(1);
    119c:	4505                	li	a0,1
    119e:	393030ef          	jal	ra,4d30 <exit>
    exit(747); // OK
    11a2:	2eb00513          	li	a0,747
    11a6:	38b030ef          	jal	ra,4d30 <exit>
  int st = 0;
    11aa:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    11ae:	f5440513          	addi	a0,s0,-172
    11b2:	387030ef          	jal	ra,4d38 <wait>
  if(st != 747){
    11b6:	f5442703          	lw	a4,-172(s0)
    11ba:	2eb00793          	li	a5,747
    11be:	00f71663          	bne	a4,a5,11ca <copyinstr2+0x18c>
}
    11c2:	60ae                	ld	ra,200(sp)
    11c4:	640e                	ld	s0,192(sp)
    11c6:	6169                	addi	sp,sp,208
    11c8:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    11ca:	00005517          	auipc	a0,0x5
    11ce:	9ce50513          	addi	a0,a0,-1586 # 5b98 <malloc+0x978>
    11d2:	79b030ef          	jal	ra,516c <printf>
    exit(1);
    11d6:	4505                	li	a0,1
    11d8:	359030ef          	jal	ra,4d30 <exit>

00000000000011dc <truncate3>:
{
    11dc:	7159                	addi	sp,sp,-112
    11de:	f486                	sd	ra,104(sp)
    11e0:	f0a2                	sd	s0,96(sp)
    11e2:	eca6                	sd	s1,88(sp)
    11e4:	e8ca                	sd	s2,80(sp)
    11e6:	e4ce                	sd	s3,72(sp)
    11e8:	e0d2                	sd	s4,64(sp)
    11ea:	fc56                	sd	s5,56(sp)
    11ec:	1880                	addi	s0,sp,112
    11ee:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    11f0:	60100593          	li	a1,1537
    11f4:	00004517          	auipc	a0,0x4
    11f8:	19c50513          	addi	a0,a0,412 # 5390 <malloc+0x170>
    11fc:	375030ef          	jal	ra,4d70 <open>
    1200:	359030ef          	jal	ra,4d58 <close>
  pid = fork();
    1204:	325030ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    1208:	06054263          	bltz	a0,126c <truncate3+0x90>
  if(pid == 0){
    120c:	ed59                	bnez	a0,12aa <truncate3+0xce>
    120e:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    1212:	00004a17          	auipc	s4,0x4
    1216:	17ea0a13          	addi	s4,s4,382 # 5390 <malloc+0x170>
      int n = write(fd, "1234567890", 10);
    121a:	00005a97          	auipc	s5,0x5
    121e:	9dea8a93          	addi	s5,s5,-1570 # 5bf8 <malloc+0x9d8>
      int fd = open("truncfile", O_WRONLY);
    1222:	4585                	li	a1,1
    1224:	8552                	mv	a0,s4
    1226:	34b030ef          	jal	ra,4d70 <open>
    122a:	84aa                	mv	s1,a0
      if(fd < 0){
    122c:	04054a63          	bltz	a0,1280 <truncate3+0xa4>
      int n = write(fd, "1234567890", 10);
    1230:	4629                	li	a2,10
    1232:	85d6                	mv	a1,s5
    1234:	31d030ef          	jal	ra,4d50 <write>
      if(n != 10){
    1238:	47a9                	li	a5,10
    123a:	04f51d63          	bne	a0,a5,1294 <truncate3+0xb8>
      close(fd);
    123e:	8526                	mv	a0,s1
    1240:	319030ef          	jal	ra,4d58 <close>
      fd = open("truncfile", O_RDONLY);
    1244:	4581                	li	a1,0
    1246:	8552                	mv	a0,s4
    1248:	329030ef          	jal	ra,4d70 <open>
    124c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    124e:	02000613          	li	a2,32
    1252:	f9840593          	addi	a1,s0,-104
    1256:	2f3030ef          	jal	ra,4d48 <read>
      close(fd);
    125a:	8526                	mv	a0,s1
    125c:	2fd030ef          	jal	ra,4d58 <close>
    for(int i = 0; i < 100; i++){
    1260:	39fd                	addiw	s3,s3,-1
    1262:	fc0990e3          	bnez	s3,1222 <truncate3+0x46>
    exit(0);
    1266:	4501                	li	a0,0
    1268:	2c9030ef          	jal	ra,4d30 <exit>
    printf("%s: fork failed\n", s);
    126c:	85ca                	mv	a1,s2
    126e:	00005517          	auipc	a0,0x5
    1272:	95a50513          	addi	a0,a0,-1702 # 5bc8 <malloc+0x9a8>
    1276:	6f7030ef          	jal	ra,516c <printf>
    exit(1);
    127a:	4505                	li	a0,1
    127c:	2b5030ef          	jal	ra,4d30 <exit>
        printf("%s: open failed\n", s);
    1280:	85ca                	mv	a1,s2
    1282:	00005517          	auipc	a0,0x5
    1286:	95e50513          	addi	a0,a0,-1698 # 5be0 <malloc+0x9c0>
    128a:	6e3030ef          	jal	ra,516c <printf>
        exit(1);
    128e:	4505                	li	a0,1
    1290:	2a1030ef          	jal	ra,4d30 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1294:	862a                	mv	a2,a0
    1296:	85ca                	mv	a1,s2
    1298:	00005517          	auipc	a0,0x5
    129c:	97050513          	addi	a0,a0,-1680 # 5c08 <malloc+0x9e8>
    12a0:	6cd030ef          	jal	ra,516c <printf>
        exit(1);
    12a4:	4505                	li	a0,1
    12a6:	28b030ef          	jal	ra,4d30 <exit>
    12aa:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12ae:	00004a17          	auipc	s4,0x4
    12b2:	0e2a0a13          	addi	s4,s4,226 # 5390 <malloc+0x170>
    int n = write(fd, "xxx", 3);
    12b6:	00005a97          	auipc	s5,0x5
    12ba:	972a8a93          	addi	s5,s5,-1678 # 5c28 <malloc+0xa08>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12be:	60100593          	li	a1,1537
    12c2:	8552                	mv	a0,s4
    12c4:	2ad030ef          	jal	ra,4d70 <open>
    12c8:	84aa                	mv	s1,a0
    if(fd < 0){
    12ca:	02054d63          	bltz	a0,1304 <truncate3+0x128>
    int n = write(fd, "xxx", 3);
    12ce:	460d                	li	a2,3
    12d0:	85d6                	mv	a1,s5
    12d2:	27f030ef          	jal	ra,4d50 <write>
    if(n != 3){
    12d6:	478d                	li	a5,3
    12d8:	04f51063          	bne	a0,a5,1318 <truncate3+0x13c>
    close(fd);
    12dc:	8526                	mv	a0,s1
    12de:	27b030ef          	jal	ra,4d58 <close>
  for(int i = 0; i < 150; i++){
    12e2:	39fd                	addiw	s3,s3,-1
    12e4:	fc099de3          	bnez	s3,12be <truncate3+0xe2>
  wait(&xstatus);
    12e8:	fbc40513          	addi	a0,s0,-68
    12ec:	24d030ef          	jal	ra,4d38 <wait>
  unlink("truncfile");
    12f0:	00004517          	auipc	a0,0x4
    12f4:	0a050513          	addi	a0,a0,160 # 5390 <malloc+0x170>
    12f8:	289030ef          	jal	ra,4d80 <unlink>
  exit(xstatus);
    12fc:	fbc42503          	lw	a0,-68(s0)
    1300:	231030ef          	jal	ra,4d30 <exit>
      printf("%s: open failed\n", s);
    1304:	85ca                	mv	a1,s2
    1306:	00005517          	auipc	a0,0x5
    130a:	8da50513          	addi	a0,a0,-1830 # 5be0 <malloc+0x9c0>
    130e:	65f030ef          	jal	ra,516c <printf>
      exit(1);
    1312:	4505                	li	a0,1
    1314:	21d030ef          	jal	ra,4d30 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1318:	862a                	mv	a2,a0
    131a:	85ca                	mv	a1,s2
    131c:	00005517          	auipc	a0,0x5
    1320:	91450513          	addi	a0,a0,-1772 # 5c30 <malloc+0xa10>
    1324:	649030ef          	jal	ra,516c <printf>
      exit(1);
    1328:	4505                	li	a0,1
    132a:	207030ef          	jal	ra,4d30 <exit>

000000000000132e <exectest>:
{
    132e:	715d                	addi	sp,sp,-80
    1330:	e486                	sd	ra,72(sp)
    1332:	e0a2                	sd	s0,64(sp)
    1334:	fc26                	sd	s1,56(sp)
    1336:	f84a                	sd	s2,48(sp)
    1338:	0880                	addi	s0,sp,80
    133a:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    133c:	00004797          	auipc	a5,0x4
    1340:	ffc78793          	addi	a5,a5,-4 # 5338 <malloc+0x118>
    1344:	fcf43023          	sd	a5,-64(s0)
    1348:	00005797          	auipc	a5,0x5
    134c:	90878793          	addi	a5,a5,-1784 # 5c50 <malloc+0xa30>
    1350:	fcf43423          	sd	a5,-56(s0)
    1354:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1358:	00005517          	auipc	a0,0x5
    135c:	90050513          	addi	a0,a0,-1792 # 5c58 <malloc+0xa38>
    1360:	221030ef          	jal	ra,4d80 <unlink>
  pid = fork();
    1364:	1c5030ef          	jal	ra,4d28 <fork>
  if(pid < 0) {
    1368:	02054e63          	bltz	a0,13a4 <exectest+0x76>
    136c:	84aa                	mv	s1,a0
  if(pid == 0) {
    136e:	e92d                	bnez	a0,13e0 <exectest+0xb2>
    close(1);
    1370:	4505                	li	a0,1
    1372:	1e7030ef          	jal	ra,4d58 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1376:	20100593          	li	a1,513
    137a:	00005517          	auipc	a0,0x5
    137e:	8de50513          	addi	a0,a0,-1826 # 5c58 <malloc+0xa38>
    1382:	1ef030ef          	jal	ra,4d70 <open>
    if(fd < 0) {
    1386:	02054963          	bltz	a0,13b8 <exectest+0x8a>
    if(fd != 1) {
    138a:	4785                	li	a5,1
    138c:	04f50063          	beq	a0,a5,13cc <exectest+0x9e>
      printf("%s: wrong fd\n", s);
    1390:	85ca                	mv	a1,s2
    1392:	00005517          	auipc	a0,0x5
    1396:	8e650513          	addi	a0,a0,-1818 # 5c78 <malloc+0xa58>
    139a:	5d3030ef          	jal	ra,516c <printf>
      exit(1);
    139e:	4505                	li	a0,1
    13a0:	191030ef          	jal	ra,4d30 <exit>
     printf("%s: fork failed\n", s);
    13a4:	85ca                	mv	a1,s2
    13a6:	00005517          	auipc	a0,0x5
    13aa:	82250513          	addi	a0,a0,-2014 # 5bc8 <malloc+0x9a8>
    13ae:	5bf030ef          	jal	ra,516c <printf>
     exit(1);
    13b2:	4505                	li	a0,1
    13b4:	17d030ef          	jal	ra,4d30 <exit>
      printf("%s: create failed\n", s);
    13b8:	85ca                	mv	a1,s2
    13ba:	00005517          	auipc	a0,0x5
    13be:	8a650513          	addi	a0,a0,-1882 # 5c60 <malloc+0xa40>
    13c2:	5ab030ef          	jal	ra,516c <printf>
      exit(1);
    13c6:	4505                	li	a0,1
    13c8:	169030ef          	jal	ra,4d30 <exit>
    if(exec("echo", echoargv) < 0){
    13cc:	fc040593          	addi	a1,s0,-64
    13d0:	00004517          	auipc	a0,0x4
    13d4:	f6850513          	addi	a0,a0,-152 # 5338 <malloc+0x118>
    13d8:	191030ef          	jal	ra,4d68 <exec>
    13dc:	00054d63          	bltz	a0,13f6 <exectest+0xc8>
  if (wait(&xstatus) != pid) {
    13e0:	fdc40513          	addi	a0,s0,-36
    13e4:	155030ef          	jal	ra,4d38 <wait>
    13e8:	02951163          	bne	a0,s1,140a <exectest+0xdc>
  if(xstatus != 0)
    13ec:	fdc42503          	lw	a0,-36(s0)
    13f0:	c50d                	beqz	a0,141a <exectest+0xec>
    exit(xstatus);
    13f2:	13f030ef          	jal	ra,4d30 <exit>
      printf("%s: exec echo failed\n", s);
    13f6:	85ca                	mv	a1,s2
    13f8:	00005517          	auipc	a0,0x5
    13fc:	89050513          	addi	a0,a0,-1904 # 5c88 <malloc+0xa68>
    1400:	56d030ef          	jal	ra,516c <printf>
      exit(1);
    1404:	4505                	li	a0,1
    1406:	12b030ef          	jal	ra,4d30 <exit>
    printf("%s: wait failed!\n", s);
    140a:	85ca                	mv	a1,s2
    140c:	00005517          	auipc	a0,0x5
    1410:	89450513          	addi	a0,a0,-1900 # 5ca0 <malloc+0xa80>
    1414:	559030ef          	jal	ra,516c <printf>
    1418:	bfd1                	j	13ec <exectest+0xbe>
  fd = open("echo-ok", O_RDONLY);
    141a:	4581                	li	a1,0
    141c:	00005517          	auipc	a0,0x5
    1420:	83c50513          	addi	a0,a0,-1988 # 5c58 <malloc+0xa38>
    1424:	14d030ef          	jal	ra,4d70 <open>
  if(fd < 0) {
    1428:	02054463          	bltz	a0,1450 <exectest+0x122>
  if (read(fd, buf, 2) != 2) {
    142c:	4609                	li	a2,2
    142e:	fb840593          	addi	a1,s0,-72
    1432:	117030ef          	jal	ra,4d48 <read>
    1436:	4789                	li	a5,2
    1438:	02f50663          	beq	a0,a5,1464 <exectest+0x136>
    printf("%s: read failed\n", s);
    143c:	85ca                	mv	a1,s2
    143e:	00004517          	auipc	a0,0x4
    1442:	2ca50513          	addi	a0,a0,714 # 5708 <malloc+0x4e8>
    1446:	527030ef          	jal	ra,516c <printf>
    exit(1);
    144a:	4505                	li	a0,1
    144c:	0e5030ef          	jal	ra,4d30 <exit>
    printf("%s: open failed\n", s);
    1450:	85ca                	mv	a1,s2
    1452:	00004517          	auipc	a0,0x4
    1456:	78e50513          	addi	a0,a0,1934 # 5be0 <malloc+0x9c0>
    145a:	513030ef          	jal	ra,516c <printf>
    exit(1);
    145e:	4505                	li	a0,1
    1460:	0d1030ef          	jal	ra,4d30 <exit>
  unlink("echo-ok");
    1464:	00004517          	auipc	a0,0x4
    1468:	7f450513          	addi	a0,a0,2036 # 5c58 <malloc+0xa38>
    146c:	115030ef          	jal	ra,4d80 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1470:	fb844703          	lbu	a4,-72(s0)
    1474:	04f00793          	li	a5,79
    1478:	00f71863          	bne	a4,a5,1488 <exectest+0x15a>
    147c:	fb944703          	lbu	a4,-71(s0)
    1480:	04b00793          	li	a5,75
    1484:	00f70c63          	beq	a4,a5,149c <exectest+0x16e>
    printf("%s: wrong output\n", s);
    1488:	85ca                	mv	a1,s2
    148a:	00005517          	auipc	a0,0x5
    148e:	82e50513          	addi	a0,a0,-2002 # 5cb8 <malloc+0xa98>
    1492:	4db030ef          	jal	ra,516c <printf>
    exit(1);
    1496:	4505                	li	a0,1
    1498:	099030ef          	jal	ra,4d30 <exit>
    exit(0);
    149c:	4501                	li	a0,0
    149e:	093030ef          	jal	ra,4d30 <exit>

00000000000014a2 <pipe1>:
{
    14a2:	711d                	addi	sp,sp,-96
    14a4:	ec86                	sd	ra,88(sp)
    14a6:	e8a2                	sd	s0,80(sp)
    14a8:	e4a6                	sd	s1,72(sp)
    14aa:	e0ca                	sd	s2,64(sp)
    14ac:	fc4e                	sd	s3,56(sp)
    14ae:	f852                	sd	s4,48(sp)
    14b0:	f456                	sd	s5,40(sp)
    14b2:	f05a                	sd	s6,32(sp)
    14b4:	ec5e                	sd	s7,24(sp)
    14b6:	1080                	addi	s0,sp,96
    14b8:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    14ba:	fa840513          	addi	a0,s0,-88
    14be:	083030ef          	jal	ra,4d40 <pipe>
    14c2:	e52d                	bnez	a0,152c <pipe1+0x8a>
    14c4:	84aa                	mv	s1,a0
  pid = fork();
    14c6:	063030ef          	jal	ra,4d28 <fork>
    14ca:	8a2a                	mv	s4,a0
  if(pid == 0){
    14cc:	c935                	beqz	a0,1540 <pipe1+0x9e>
  } else if(pid > 0){
    14ce:	14a05063          	blez	a0,160e <pipe1+0x16c>
    close(fds[1]);
    14d2:	fac42503          	lw	a0,-84(s0)
    14d6:	083030ef          	jal	ra,4d58 <close>
    total = 0;
    14da:	8a26                	mv	s4,s1
    cc = 1;
    14dc:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    14de:	0000aa97          	auipc	s5,0xa
    14e2:	7daa8a93          	addi	s5,s5,2010 # bcb8 <buf>
      if(cc > sizeof(buf))
    14e6:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    14e8:	864e                	mv	a2,s3
    14ea:	85d6                	mv	a1,s5
    14ec:	fa842503          	lw	a0,-88(s0)
    14f0:	059030ef          	jal	ra,4d48 <read>
    14f4:	0ea05163          	blez	a0,15d6 <pipe1+0x134>
      for(i = 0; i < n; i++){
    14f8:	0000a717          	auipc	a4,0xa
    14fc:	7c070713          	addi	a4,a4,1984 # bcb8 <buf>
    1500:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1504:	00074683          	lbu	a3,0(a4)
    1508:	0ff4f793          	zext.b	a5,s1
    150c:	2485                	addiw	s1,s1,1
    150e:	0af69263          	bne	a3,a5,15b2 <pipe1+0x110>
      for(i = 0; i < n; i++){
    1512:	0705                	addi	a4,a4,1
    1514:	fec498e3          	bne	s1,a2,1504 <pipe1+0x62>
      total += n;
    1518:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    151c:	0019979b          	slliw	a5,s3,0x1
    1520:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    1524:	fd3b72e3          	bgeu	s6,s3,14e8 <pipe1+0x46>
        cc = sizeof(buf);
    1528:	89da                	mv	s3,s6
    152a:	bf7d                	j	14e8 <pipe1+0x46>
    printf("%s: pipe() failed\n", s);
    152c:	85ca                	mv	a1,s2
    152e:	00004517          	auipc	a0,0x4
    1532:	7a250513          	addi	a0,a0,1954 # 5cd0 <malloc+0xab0>
    1536:	437030ef          	jal	ra,516c <printf>
    exit(1);
    153a:	4505                	li	a0,1
    153c:	7f4030ef          	jal	ra,4d30 <exit>
    close(fds[0]);
    1540:	fa842503          	lw	a0,-88(s0)
    1544:	015030ef          	jal	ra,4d58 <close>
    for(n = 0; n < N; n++){
    1548:	0000ab17          	auipc	s6,0xa
    154c:	770b0b13          	addi	s6,s6,1904 # bcb8 <buf>
    1550:	416004bb          	negw	s1,s6
    1554:	0ff4f493          	zext.b	s1,s1
    1558:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    155c:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    155e:	6a85                	lui	s5,0x1
    1560:	42da8a93          	addi	s5,s5,1069 # 142d <exectest+0xff>
{
    1564:	87da                	mv	a5,s6
        buf[i] = seq++;
    1566:	0097873b          	addw	a4,a5,s1
    156a:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    156e:	0785                	addi	a5,a5,1
    1570:	fef99be3          	bne	s3,a5,1566 <pipe1+0xc4>
        buf[i] = seq++;
    1574:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1578:	40900613          	li	a2,1033
    157c:	85de                	mv	a1,s7
    157e:	fac42503          	lw	a0,-84(s0)
    1582:	7ce030ef          	jal	ra,4d50 <write>
    1586:	40900793          	li	a5,1033
    158a:	00f51a63          	bne	a0,a5,159e <pipe1+0xfc>
    for(n = 0; n < N; n++){
    158e:	24a5                	addiw	s1,s1,9
    1590:	0ff4f493          	zext.b	s1,s1
    1594:	fd5a18e3          	bne	s4,s5,1564 <pipe1+0xc2>
    exit(0);
    1598:	4501                	li	a0,0
    159a:	796030ef          	jal	ra,4d30 <exit>
        printf("%s: pipe1 oops 1\n", s);
    159e:	85ca                	mv	a1,s2
    15a0:	00004517          	auipc	a0,0x4
    15a4:	74850513          	addi	a0,a0,1864 # 5ce8 <malloc+0xac8>
    15a8:	3c5030ef          	jal	ra,516c <printf>
        exit(1);
    15ac:	4505                	li	a0,1
    15ae:	782030ef          	jal	ra,4d30 <exit>
          printf("%s: pipe1 oops 2\n", s);
    15b2:	85ca                	mv	a1,s2
    15b4:	00004517          	auipc	a0,0x4
    15b8:	74c50513          	addi	a0,a0,1868 # 5d00 <malloc+0xae0>
    15bc:	3b1030ef          	jal	ra,516c <printf>
}
    15c0:	60e6                	ld	ra,88(sp)
    15c2:	6446                	ld	s0,80(sp)
    15c4:	64a6                	ld	s1,72(sp)
    15c6:	6906                	ld	s2,64(sp)
    15c8:	79e2                	ld	s3,56(sp)
    15ca:	7a42                	ld	s4,48(sp)
    15cc:	7aa2                	ld	s5,40(sp)
    15ce:	7b02                	ld	s6,32(sp)
    15d0:	6be2                	ld	s7,24(sp)
    15d2:	6125                	addi	sp,sp,96
    15d4:	8082                	ret
    if(total != N * SZ){
    15d6:	6785                	lui	a5,0x1
    15d8:	42d78793          	addi	a5,a5,1069 # 142d <exectest+0xff>
    15dc:	00fa0d63          	beq	s4,a5,15f6 <pipe1+0x154>
      printf("%s: pipe1 oops 3 total %d\n", s, total);
    15e0:	8652                	mv	a2,s4
    15e2:	85ca                	mv	a1,s2
    15e4:	00004517          	auipc	a0,0x4
    15e8:	73450513          	addi	a0,a0,1844 # 5d18 <malloc+0xaf8>
    15ec:	381030ef          	jal	ra,516c <printf>
      exit(1);
    15f0:	4505                	li	a0,1
    15f2:	73e030ef          	jal	ra,4d30 <exit>
    close(fds[0]);
    15f6:	fa842503          	lw	a0,-88(s0)
    15fa:	75e030ef          	jal	ra,4d58 <close>
    wait(&xstatus);
    15fe:	fa440513          	addi	a0,s0,-92
    1602:	736030ef          	jal	ra,4d38 <wait>
    exit(xstatus);
    1606:	fa442503          	lw	a0,-92(s0)
    160a:	726030ef          	jal	ra,4d30 <exit>
    printf("%s: fork() failed\n", s);
    160e:	85ca                	mv	a1,s2
    1610:	00004517          	auipc	a0,0x4
    1614:	72850513          	addi	a0,a0,1832 # 5d38 <malloc+0xb18>
    1618:	355030ef          	jal	ra,516c <printf>
    exit(1);
    161c:	4505                	li	a0,1
    161e:	712030ef          	jal	ra,4d30 <exit>

0000000000001622 <exitwait>:
{
    1622:	7139                	addi	sp,sp,-64
    1624:	fc06                	sd	ra,56(sp)
    1626:	f822                	sd	s0,48(sp)
    1628:	f426                	sd	s1,40(sp)
    162a:	f04a                	sd	s2,32(sp)
    162c:	ec4e                	sd	s3,24(sp)
    162e:	e852                	sd	s4,16(sp)
    1630:	0080                	addi	s0,sp,64
    1632:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1634:	4901                	li	s2,0
    1636:	06400993          	li	s3,100
    pid = fork();
    163a:	6ee030ef          	jal	ra,4d28 <fork>
    163e:	84aa                	mv	s1,a0
    if(pid < 0){
    1640:	02054863          	bltz	a0,1670 <exitwait+0x4e>
    if(pid){
    1644:	c525                	beqz	a0,16ac <exitwait+0x8a>
      if(wait(&xstate) != pid){
    1646:	fcc40513          	addi	a0,s0,-52
    164a:	6ee030ef          	jal	ra,4d38 <wait>
    164e:	02951b63          	bne	a0,s1,1684 <exitwait+0x62>
      if(i != xstate) {
    1652:	fcc42783          	lw	a5,-52(s0)
    1656:	05279163          	bne	a5,s2,1698 <exitwait+0x76>
  for(i = 0; i < 100; i++){
    165a:	2905                	addiw	s2,s2,1
    165c:	fd391fe3          	bne	s2,s3,163a <exitwait+0x18>
}
    1660:	70e2                	ld	ra,56(sp)
    1662:	7442                	ld	s0,48(sp)
    1664:	74a2                	ld	s1,40(sp)
    1666:	7902                	ld	s2,32(sp)
    1668:	69e2                	ld	s3,24(sp)
    166a:	6a42                	ld	s4,16(sp)
    166c:	6121                	addi	sp,sp,64
    166e:	8082                	ret
      printf("%s: fork failed\n", s);
    1670:	85d2                	mv	a1,s4
    1672:	00004517          	auipc	a0,0x4
    1676:	55650513          	addi	a0,a0,1366 # 5bc8 <malloc+0x9a8>
    167a:	2f3030ef          	jal	ra,516c <printf>
      exit(1);
    167e:	4505                	li	a0,1
    1680:	6b0030ef          	jal	ra,4d30 <exit>
        printf("%s: wait wrong pid\n", s);
    1684:	85d2                	mv	a1,s4
    1686:	00004517          	auipc	a0,0x4
    168a:	6ca50513          	addi	a0,a0,1738 # 5d50 <malloc+0xb30>
    168e:	2df030ef          	jal	ra,516c <printf>
        exit(1);
    1692:	4505                	li	a0,1
    1694:	69c030ef          	jal	ra,4d30 <exit>
        printf("%s: wait wrong exit status\n", s);
    1698:	85d2                	mv	a1,s4
    169a:	00004517          	auipc	a0,0x4
    169e:	6ce50513          	addi	a0,a0,1742 # 5d68 <malloc+0xb48>
    16a2:	2cb030ef          	jal	ra,516c <printf>
        exit(1);
    16a6:	4505                	li	a0,1
    16a8:	688030ef          	jal	ra,4d30 <exit>
      exit(i);
    16ac:	854a                	mv	a0,s2
    16ae:	682030ef          	jal	ra,4d30 <exit>

00000000000016b2 <twochildren>:
{
    16b2:	1101                	addi	sp,sp,-32
    16b4:	ec06                	sd	ra,24(sp)
    16b6:	e822                	sd	s0,16(sp)
    16b8:	e426                	sd	s1,8(sp)
    16ba:	e04a                	sd	s2,0(sp)
    16bc:	1000                	addi	s0,sp,32
    16be:	892a                	mv	s2,a0
    16c0:	3e800493          	li	s1,1000
    int pid1 = fork();
    16c4:	664030ef          	jal	ra,4d28 <fork>
    if(pid1 < 0){
    16c8:	02054663          	bltz	a0,16f4 <twochildren+0x42>
    if(pid1 == 0){
    16cc:	cd15                	beqz	a0,1708 <twochildren+0x56>
      int pid2 = fork();
    16ce:	65a030ef          	jal	ra,4d28 <fork>
      if(pid2 < 0){
    16d2:	02054d63          	bltz	a0,170c <twochildren+0x5a>
      if(pid2 == 0){
    16d6:	c529                	beqz	a0,1720 <twochildren+0x6e>
        wait(0);
    16d8:	4501                	li	a0,0
    16da:	65e030ef          	jal	ra,4d38 <wait>
        wait(0);
    16de:	4501                	li	a0,0
    16e0:	658030ef          	jal	ra,4d38 <wait>
  for(int i = 0; i < 1000; i++){
    16e4:	34fd                	addiw	s1,s1,-1
    16e6:	fcf9                	bnez	s1,16c4 <twochildren+0x12>
}
    16e8:	60e2                	ld	ra,24(sp)
    16ea:	6442                	ld	s0,16(sp)
    16ec:	64a2                	ld	s1,8(sp)
    16ee:	6902                	ld	s2,0(sp)
    16f0:	6105                	addi	sp,sp,32
    16f2:	8082                	ret
      printf("%s: fork failed\n", s);
    16f4:	85ca                	mv	a1,s2
    16f6:	00004517          	auipc	a0,0x4
    16fa:	4d250513          	addi	a0,a0,1234 # 5bc8 <malloc+0x9a8>
    16fe:	26f030ef          	jal	ra,516c <printf>
      exit(1);
    1702:	4505                	li	a0,1
    1704:	62c030ef          	jal	ra,4d30 <exit>
      exit(0);
    1708:	628030ef          	jal	ra,4d30 <exit>
        printf("%s: fork failed\n", s);
    170c:	85ca                	mv	a1,s2
    170e:	00004517          	auipc	a0,0x4
    1712:	4ba50513          	addi	a0,a0,1210 # 5bc8 <malloc+0x9a8>
    1716:	257030ef          	jal	ra,516c <printf>
        exit(1);
    171a:	4505                	li	a0,1
    171c:	614030ef          	jal	ra,4d30 <exit>
        exit(0);
    1720:	610030ef          	jal	ra,4d30 <exit>

0000000000001724 <forkfork>:
{
    1724:	7179                	addi	sp,sp,-48
    1726:	f406                	sd	ra,40(sp)
    1728:	f022                	sd	s0,32(sp)
    172a:	ec26                	sd	s1,24(sp)
    172c:	1800                	addi	s0,sp,48
    172e:	84aa                	mv	s1,a0
    int pid = fork();
    1730:	5f8030ef          	jal	ra,4d28 <fork>
    if(pid < 0){
    1734:	02054b63          	bltz	a0,176a <forkfork+0x46>
    if(pid == 0){
    1738:	c139                	beqz	a0,177e <forkfork+0x5a>
    int pid = fork();
    173a:	5ee030ef          	jal	ra,4d28 <fork>
    if(pid < 0){
    173e:	02054663          	bltz	a0,176a <forkfork+0x46>
    if(pid == 0){
    1742:	cd15                	beqz	a0,177e <forkfork+0x5a>
    wait(&xstatus);
    1744:	fdc40513          	addi	a0,s0,-36
    1748:	5f0030ef          	jal	ra,4d38 <wait>
    if(xstatus != 0) {
    174c:	fdc42783          	lw	a5,-36(s0)
    1750:	ebb9                	bnez	a5,17a6 <forkfork+0x82>
    wait(&xstatus);
    1752:	fdc40513          	addi	a0,s0,-36
    1756:	5e2030ef          	jal	ra,4d38 <wait>
    if(xstatus != 0) {
    175a:	fdc42783          	lw	a5,-36(s0)
    175e:	e7a1                	bnez	a5,17a6 <forkfork+0x82>
}
    1760:	70a2                	ld	ra,40(sp)
    1762:	7402                	ld	s0,32(sp)
    1764:	64e2                	ld	s1,24(sp)
    1766:	6145                	addi	sp,sp,48
    1768:	8082                	ret
      printf("%s: fork failed", s);
    176a:	85a6                	mv	a1,s1
    176c:	00004517          	auipc	a0,0x4
    1770:	61c50513          	addi	a0,a0,1564 # 5d88 <malloc+0xb68>
    1774:	1f9030ef          	jal	ra,516c <printf>
      exit(1);
    1778:	4505                	li	a0,1
    177a:	5b6030ef          	jal	ra,4d30 <exit>
{
    177e:	0c800493          	li	s1,200
        int pid1 = fork();
    1782:	5a6030ef          	jal	ra,4d28 <fork>
        if(pid1 < 0){
    1786:	00054b63          	bltz	a0,179c <forkfork+0x78>
        if(pid1 == 0){
    178a:	cd01                	beqz	a0,17a2 <forkfork+0x7e>
        wait(0);
    178c:	4501                	li	a0,0
    178e:	5aa030ef          	jal	ra,4d38 <wait>
      for(int j = 0; j < 200; j++){
    1792:	34fd                	addiw	s1,s1,-1
    1794:	f4fd                	bnez	s1,1782 <forkfork+0x5e>
      exit(0);
    1796:	4501                	li	a0,0
    1798:	598030ef          	jal	ra,4d30 <exit>
          exit(1);
    179c:	4505                	li	a0,1
    179e:	592030ef          	jal	ra,4d30 <exit>
          exit(0);
    17a2:	58e030ef          	jal	ra,4d30 <exit>
      printf("%s: fork in child failed", s);
    17a6:	85a6                	mv	a1,s1
    17a8:	00004517          	auipc	a0,0x4
    17ac:	5f050513          	addi	a0,a0,1520 # 5d98 <malloc+0xb78>
    17b0:	1bd030ef          	jal	ra,516c <printf>
      exit(1);
    17b4:	4505                	li	a0,1
    17b6:	57a030ef          	jal	ra,4d30 <exit>

00000000000017ba <reparent2>:
{
    17ba:	1101                	addi	sp,sp,-32
    17bc:	ec06                	sd	ra,24(sp)
    17be:	e822                	sd	s0,16(sp)
    17c0:	e426                	sd	s1,8(sp)
    17c2:	1000                	addi	s0,sp,32
    17c4:	32000493          	li	s1,800
    int pid1 = fork();
    17c8:	560030ef          	jal	ra,4d28 <fork>
    if(pid1 < 0){
    17cc:	00054b63          	bltz	a0,17e2 <reparent2+0x28>
    if(pid1 == 0){
    17d0:	c115                	beqz	a0,17f4 <reparent2+0x3a>
    wait(0);
    17d2:	4501                	li	a0,0
    17d4:	564030ef          	jal	ra,4d38 <wait>
  for(int i = 0; i < 800; i++){
    17d8:	34fd                	addiw	s1,s1,-1
    17da:	f4fd                	bnez	s1,17c8 <reparent2+0xe>
  exit(0);
    17dc:	4501                	li	a0,0
    17de:	552030ef          	jal	ra,4d30 <exit>
      printf("fork failed\n");
    17e2:	00006517          	auipc	a0,0x6
    17e6:	98e50513          	addi	a0,a0,-1650 # 7170 <malloc+0x1f50>
    17ea:	183030ef          	jal	ra,516c <printf>
      exit(1);
    17ee:	4505                	li	a0,1
    17f0:	540030ef          	jal	ra,4d30 <exit>
      fork();
    17f4:	534030ef          	jal	ra,4d28 <fork>
      fork();
    17f8:	530030ef          	jal	ra,4d28 <fork>
      exit(0);
    17fc:	4501                	li	a0,0
    17fe:	532030ef          	jal	ra,4d30 <exit>

0000000000001802 <createdelete>:
{
    1802:	7175                	addi	sp,sp,-144
    1804:	e506                	sd	ra,136(sp)
    1806:	e122                	sd	s0,128(sp)
    1808:	fca6                	sd	s1,120(sp)
    180a:	f8ca                	sd	s2,112(sp)
    180c:	f4ce                	sd	s3,104(sp)
    180e:	f0d2                	sd	s4,96(sp)
    1810:	ecd6                	sd	s5,88(sp)
    1812:	e8da                	sd	s6,80(sp)
    1814:	e4de                	sd	s7,72(sp)
    1816:	e0e2                	sd	s8,64(sp)
    1818:	fc66                	sd	s9,56(sp)
    181a:	0900                	addi	s0,sp,144
    181c:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    181e:	4901                	li	s2,0
    1820:	4991                	li	s3,4
    pid = fork();
    1822:	506030ef          	jal	ra,4d28 <fork>
    1826:	84aa                	mv	s1,a0
    if(pid < 0){
    1828:	02054d63          	bltz	a0,1862 <createdelete+0x60>
    if(pid == 0){
    182c:	c529                	beqz	a0,1876 <createdelete+0x74>
  for(pi = 0; pi < NCHILD; pi++){
    182e:	2905                	addiw	s2,s2,1
    1830:	ff3919e3          	bne	s2,s3,1822 <createdelete+0x20>
    1834:	4491                	li	s1,4
    wait(&xstatus);
    1836:	f7c40513          	addi	a0,s0,-132
    183a:	4fe030ef          	jal	ra,4d38 <wait>
    if(xstatus != 0)
    183e:	f7c42903          	lw	s2,-132(s0)
    1842:	0a091e63          	bnez	s2,18fe <createdelete+0xfc>
  for(pi = 0; pi < NCHILD; pi++){
    1846:	34fd                	addiw	s1,s1,-1
    1848:	f4fd                	bnez	s1,1836 <createdelete+0x34>
  name[0] = name[1] = name[2] = 0;
    184a:	f8040123          	sb	zero,-126(s0)
    184e:	03000993          	li	s3,48
    1852:	5a7d                	li	s4,-1
    1854:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1858:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    185a:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    185c:	07400a93          	li	s5,116
    1860:	a20d                	j	1982 <createdelete+0x180>
      printf("%s: fork failed\n", s);
    1862:	85e6                	mv	a1,s9
    1864:	00004517          	auipc	a0,0x4
    1868:	36450513          	addi	a0,a0,868 # 5bc8 <malloc+0x9a8>
    186c:	101030ef          	jal	ra,516c <printf>
      exit(1);
    1870:	4505                	li	a0,1
    1872:	4be030ef          	jal	ra,4d30 <exit>
      name[0] = 'p' + pi;
    1876:	0709091b          	addiw	s2,s2,112
    187a:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    187e:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1882:	4951                	li	s2,20
    1884:	a831                	j	18a0 <createdelete+0x9e>
          printf("%s: create failed\n", s);
    1886:	85e6                	mv	a1,s9
    1888:	00004517          	auipc	a0,0x4
    188c:	3d850513          	addi	a0,a0,984 # 5c60 <malloc+0xa40>
    1890:	0dd030ef          	jal	ra,516c <printf>
          exit(1);
    1894:	4505                	li	a0,1
    1896:	49a030ef          	jal	ra,4d30 <exit>
      for(i = 0; i < N; i++){
    189a:	2485                	addiw	s1,s1,1
    189c:	05248e63          	beq	s1,s2,18f8 <createdelete+0xf6>
        name[1] = '0' + i;
    18a0:	0304879b          	addiw	a5,s1,48
    18a4:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    18a8:	20200593          	li	a1,514
    18ac:	f8040513          	addi	a0,s0,-128
    18b0:	4c0030ef          	jal	ra,4d70 <open>
        if(fd < 0){
    18b4:	fc0549e3          	bltz	a0,1886 <createdelete+0x84>
        close(fd);
    18b8:	4a0030ef          	jal	ra,4d58 <close>
        if(i > 0 && (i % 2 ) == 0){
    18bc:	fc905fe3          	blez	s1,189a <createdelete+0x98>
    18c0:	0014f793          	andi	a5,s1,1
    18c4:	fbf9                	bnez	a5,189a <createdelete+0x98>
          name[1] = '0' + (i / 2);
    18c6:	01f4d79b          	srliw	a5,s1,0x1f
    18ca:	9fa5                	addw	a5,a5,s1
    18cc:	4017d79b          	sraiw	a5,a5,0x1
    18d0:	0307879b          	addiw	a5,a5,48
    18d4:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    18d8:	f8040513          	addi	a0,s0,-128
    18dc:	4a4030ef          	jal	ra,4d80 <unlink>
    18e0:	fa055de3          	bgez	a0,189a <createdelete+0x98>
            printf("%s: unlink failed\n", s);
    18e4:	85e6                	mv	a1,s9
    18e6:	00004517          	auipc	a0,0x4
    18ea:	4d250513          	addi	a0,a0,1234 # 5db8 <malloc+0xb98>
    18ee:	07f030ef          	jal	ra,516c <printf>
            exit(1);
    18f2:	4505                	li	a0,1
    18f4:	43c030ef          	jal	ra,4d30 <exit>
      exit(0);
    18f8:	4501                	li	a0,0
    18fa:	436030ef          	jal	ra,4d30 <exit>
      exit(1);
    18fe:	4505                	li	a0,1
    1900:	430030ef          	jal	ra,4d30 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1904:	f8040613          	addi	a2,s0,-128
    1908:	85e6                	mv	a1,s9
    190a:	00004517          	auipc	a0,0x4
    190e:	4c650513          	addi	a0,a0,1222 # 5dd0 <malloc+0xbb0>
    1912:	05b030ef          	jal	ra,516c <printf>
        exit(1);
    1916:	4505                	li	a0,1
    1918:	418030ef          	jal	ra,4d30 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    191c:	034b7d63          	bgeu	s6,s4,1956 <createdelete+0x154>
      if(fd >= 0)
    1920:	02055863          	bgez	a0,1950 <createdelete+0x14e>
    for(pi = 0; pi < NCHILD; pi++){
    1924:	2485                	addiw	s1,s1,1
    1926:	0ff4f493          	zext.b	s1,s1
    192a:	05548463          	beq	s1,s5,1972 <createdelete+0x170>
      name[0] = 'p' + pi;
    192e:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1932:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1936:	4581                	li	a1,0
    1938:	f8040513          	addi	a0,s0,-128
    193c:	434030ef          	jal	ra,4d70 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1940:	00090463          	beqz	s2,1948 <createdelete+0x146>
    1944:	fd2bdce3          	bge	s7,s2,191c <createdelete+0x11a>
    1948:	fa054ee3          	bltz	a0,1904 <createdelete+0x102>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    194c:	014b7763          	bgeu	s6,s4,195a <createdelete+0x158>
        close(fd);
    1950:	408030ef          	jal	ra,4d58 <close>
    1954:	bfc1                	j	1924 <createdelete+0x122>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1956:	fc0547e3          	bltz	a0,1924 <createdelete+0x122>
        printf("%s: oops createdelete %s did exist\n", s, name);
    195a:	f8040613          	addi	a2,s0,-128
    195e:	85e6                	mv	a1,s9
    1960:	00004517          	auipc	a0,0x4
    1964:	49850513          	addi	a0,a0,1176 # 5df8 <malloc+0xbd8>
    1968:	005030ef          	jal	ra,516c <printf>
        exit(1);
    196c:	4505                	li	a0,1
    196e:	3c2030ef          	jal	ra,4d30 <exit>
  for(i = 0; i < N; i++){
    1972:	2905                	addiw	s2,s2,1
    1974:	2a05                	addiw	s4,s4,1
    1976:	2985                	addiw	s3,s3,1
    1978:	0ff9f993          	zext.b	s3,s3
    197c:	47d1                	li	a5,20
    197e:	02f90863          	beq	s2,a5,19ae <createdelete+0x1ac>
    for(pi = 0; pi < NCHILD; pi++){
    1982:	84e2                	mv	s1,s8
    1984:	b76d                	j	192e <createdelete+0x12c>
  for(i = 0; i < N; i++){
    1986:	2905                	addiw	s2,s2,1
    1988:	0ff97913          	zext.b	s2,s2
    198c:	03490a63          	beq	s2,s4,19c0 <createdelete+0x1be>
  name[0] = name[1] = name[2] = 0;
    1990:	84d6                	mv	s1,s5
      name[0] = 'p' + pi;
    1992:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1996:	f92400a3          	sb	s2,-127(s0)
      unlink(name);
    199a:	f8040513          	addi	a0,s0,-128
    199e:	3e2030ef          	jal	ra,4d80 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    19a2:	2485                	addiw	s1,s1,1
    19a4:	0ff4f493          	zext.b	s1,s1
    19a8:	ff3495e3          	bne	s1,s3,1992 <createdelete+0x190>
    19ac:	bfe9                	j	1986 <createdelete+0x184>
    19ae:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    19b2:	07000a93          	li	s5,112
    for(pi = 0; pi < NCHILD; pi++){
    19b6:	07400993          	li	s3,116
  for(i = 0; i < N; i++){
    19ba:	04400a13          	li	s4,68
    19be:	bfc9                	j	1990 <createdelete+0x18e>
}
    19c0:	60aa                	ld	ra,136(sp)
    19c2:	640a                	ld	s0,128(sp)
    19c4:	74e6                	ld	s1,120(sp)
    19c6:	7946                	ld	s2,112(sp)
    19c8:	79a6                	ld	s3,104(sp)
    19ca:	7a06                	ld	s4,96(sp)
    19cc:	6ae6                	ld	s5,88(sp)
    19ce:	6b46                	ld	s6,80(sp)
    19d0:	6ba6                	ld	s7,72(sp)
    19d2:	6c06                	ld	s8,64(sp)
    19d4:	7ce2                	ld	s9,56(sp)
    19d6:	6149                	addi	sp,sp,144
    19d8:	8082                	ret

00000000000019da <linkunlink>:
{
    19da:	711d                	addi	sp,sp,-96
    19dc:	ec86                	sd	ra,88(sp)
    19de:	e8a2                	sd	s0,80(sp)
    19e0:	e4a6                	sd	s1,72(sp)
    19e2:	e0ca                	sd	s2,64(sp)
    19e4:	fc4e                	sd	s3,56(sp)
    19e6:	f852                	sd	s4,48(sp)
    19e8:	f456                	sd	s5,40(sp)
    19ea:	f05a                	sd	s6,32(sp)
    19ec:	ec5e                	sd	s7,24(sp)
    19ee:	e862                	sd	s8,16(sp)
    19f0:	e466                	sd	s9,8(sp)
    19f2:	1080                	addi	s0,sp,96
    19f4:	84aa                	mv	s1,a0
  unlink("x");
    19f6:	00004517          	auipc	a0,0x4
    19fa:	9b250513          	addi	a0,a0,-1614 # 53a8 <malloc+0x188>
    19fe:	382030ef          	jal	ra,4d80 <unlink>
  pid = fork();
    1a02:	326030ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    1a06:	02054b63          	bltz	a0,1a3c <linkunlink+0x62>
    1a0a:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1a0c:	4c85                	li	s9,1
    1a0e:	e119                	bnez	a0,1a14 <linkunlink+0x3a>
    1a10:	06100c93          	li	s9,97
    1a14:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1a18:	41c659b7          	lui	s3,0x41c65
    1a1c:	e6d9899b          	addiw	s3,s3,-403 # 41c64e6d <base+0x41c561b5>
    1a20:	690d                	lui	s2,0x3
    1a22:	0399091b          	addiw	s2,s2,57 # 3039 <subdir+0x4cb>
    if((x % 3) == 0){
    1a26:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1a28:	4b05                	li	s6,1
      unlink("x");
    1a2a:	00004a97          	auipc	s5,0x4
    1a2e:	97ea8a93          	addi	s5,s5,-1666 # 53a8 <malloc+0x188>
      link("cat", "x");
    1a32:	00004b97          	auipc	s7,0x4
    1a36:	3eeb8b93          	addi	s7,s7,1006 # 5e20 <malloc+0xc00>
    1a3a:	a025                	j	1a62 <linkunlink+0x88>
    printf("%s: fork failed\n", s);
    1a3c:	85a6                	mv	a1,s1
    1a3e:	00004517          	auipc	a0,0x4
    1a42:	18a50513          	addi	a0,a0,394 # 5bc8 <malloc+0x9a8>
    1a46:	726030ef          	jal	ra,516c <printf>
    exit(1);
    1a4a:	4505                	li	a0,1
    1a4c:	2e4030ef          	jal	ra,4d30 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1a50:	20200593          	li	a1,514
    1a54:	8556                	mv	a0,s5
    1a56:	31a030ef          	jal	ra,4d70 <open>
    1a5a:	2fe030ef          	jal	ra,4d58 <close>
  for(i = 0; i < 100; i++){
    1a5e:	34fd                	addiw	s1,s1,-1
    1a60:	c48d                	beqz	s1,1a8a <linkunlink+0xb0>
    x = x * 1103515245 + 12345;
    1a62:	033c87bb          	mulw	a5,s9,s3
    1a66:	012787bb          	addw	a5,a5,s2
    1a6a:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1a6e:	0347f7bb          	remuw	a5,a5,s4
    1a72:	dff9                	beqz	a5,1a50 <linkunlink+0x76>
    } else if((x % 3) == 1){
    1a74:	01678663          	beq	a5,s6,1a80 <linkunlink+0xa6>
      unlink("x");
    1a78:	8556                	mv	a0,s5
    1a7a:	306030ef          	jal	ra,4d80 <unlink>
    1a7e:	b7c5                	j	1a5e <linkunlink+0x84>
      link("cat", "x");
    1a80:	85d6                	mv	a1,s5
    1a82:	855e                	mv	a0,s7
    1a84:	30c030ef          	jal	ra,4d90 <link>
    1a88:	bfd9                	j	1a5e <linkunlink+0x84>
  if(pid)
    1a8a:	020c0263          	beqz	s8,1aae <linkunlink+0xd4>
    wait(0);
    1a8e:	4501                	li	a0,0
    1a90:	2a8030ef          	jal	ra,4d38 <wait>
}
    1a94:	60e6                	ld	ra,88(sp)
    1a96:	6446                	ld	s0,80(sp)
    1a98:	64a6                	ld	s1,72(sp)
    1a9a:	6906                	ld	s2,64(sp)
    1a9c:	79e2                	ld	s3,56(sp)
    1a9e:	7a42                	ld	s4,48(sp)
    1aa0:	7aa2                	ld	s5,40(sp)
    1aa2:	7b02                	ld	s6,32(sp)
    1aa4:	6be2                	ld	s7,24(sp)
    1aa6:	6c42                	ld	s8,16(sp)
    1aa8:	6ca2                	ld	s9,8(sp)
    1aaa:	6125                	addi	sp,sp,96
    1aac:	8082                	ret
    exit(0);
    1aae:	4501                	li	a0,0
    1ab0:	280030ef          	jal	ra,4d30 <exit>

0000000000001ab4 <forktest>:
{
    1ab4:	7179                	addi	sp,sp,-48
    1ab6:	f406                	sd	ra,40(sp)
    1ab8:	f022                	sd	s0,32(sp)
    1aba:	ec26                	sd	s1,24(sp)
    1abc:	e84a                	sd	s2,16(sp)
    1abe:	e44e                	sd	s3,8(sp)
    1ac0:	1800                	addi	s0,sp,48
    1ac2:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1ac4:	4481                	li	s1,0
    1ac6:	3e800913          	li	s2,1000
    pid = fork();
    1aca:	25e030ef          	jal	ra,4d28 <fork>
    if(pid < 0)
    1ace:	02054263          	bltz	a0,1af2 <forktest+0x3e>
    if(pid == 0)
    1ad2:	cd11                	beqz	a0,1aee <forktest+0x3a>
  for(n=0; n<N; n++){
    1ad4:	2485                	addiw	s1,s1,1
    1ad6:	ff249ae3          	bne	s1,s2,1aca <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1ada:	85ce                	mv	a1,s3
    1adc:	00004517          	auipc	a0,0x4
    1ae0:	36450513          	addi	a0,a0,868 # 5e40 <malloc+0xc20>
    1ae4:	688030ef          	jal	ra,516c <printf>
    exit(1);
    1ae8:	4505                	li	a0,1
    1aea:	246030ef          	jal	ra,4d30 <exit>
      exit(0);
    1aee:	242030ef          	jal	ra,4d30 <exit>
  if (n == 0) {
    1af2:	c89d                	beqz	s1,1b28 <forktest+0x74>
  if(n == N){
    1af4:	3e800793          	li	a5,1000
    1af8:	fef481e3          	beq	s1,a5,1ada <forktest+0x26>
  for(; n > 0; n--){
    1afc:	00905963          	blez	s1,1b0e <forktest+0x5a>
    if(wait(0) < 0){
    1b00:	4501                	li	a0,0
    1b02:	236030ef          	jal	ra,4d38 <wait>
    1b06:	02054b63          	bltz	a0,1b3c <forktest+0x88>
  for(; n > 0; n--){
    1b0a:	34fd                	addiw	s1,s1,-1
    1b0c:	f8f5                	bnez	s1,1b00 <forktest+0x4c>
  if(wait(0) != -1){
    1b0e:	4501                	li	a0,0
    1b10:	228030ef          	jal	ra,4d38 <wait>
    1b14:	57fd                	li	a5,-1
    1b16:	02f51d63          	bne	a0,a5,1b50 <forktest+0x9c>
}
    1b1a:	70a2                	ld	ra,40(sp)
    1b1c:	7402                	ld	s0,32(sp)
    1b1e:	64e2                	ld	s1,24(sp)
    1b20:	6942                	ld	s2,16(sp)
    1b22:	69a2                	ld	s3,8(sp)
    1b24:	6145                	addi	sp,sp,48
    1b26:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1b28:	85ce                	mv	a1,s3
    1b2a:	00004517          	auipc	a0,0x4
    1b2e:	2fe50513          	addi	a0,a0,766 # 5e28 <malloc+0xc08>
    1b32:	63a030ef          	jal	ra,516c <printf>
    exit(1);
    1b36:	4505                	li	a0,1
    1b38:	1f8030ef          	jal	ra,4d30 <exit>
      printf("%s: wait stopped early\n", s);
    1b3c:	85ce                	mv	a1,s3
    1b3e:	00004517          	auipc	a0,0x4
    1b42:	32a50513          	addi	a0,a0,810 # 5e68 <malloc+0xc48>
    1b46:	626030ef          	jal	ra,516c <printf>
      exit(1);
    1b4a:	4505                	li	a0,1
    1b4c:	1e4030ef          	jal	ra,4d30 <exit>
    printf("%s: wait got too many\n", s);
    1b50:	85ce                	mv	a1,s3
    1b52:	00004517          	auipc	a0,0x4
    1b56:	32e50513          	addi	a0,a0,814 # 5e80 <malloc+0xc60>
    1b5a:	612030ef          	jal	ra,516c <printf>
    exit(1);
    1b5e:	4505                	li	a0,1
    1b60:	1d0030ef          	jal	ra,4d30 <exit>

0000000000001b64 <kernmem>:
{
    1b64:	715d                	addi	sp,sp,-80
    1b66:	e486                	sd	ra,72(sp)
    1b68:	e0a2                	sd	s0,64(sp)
    1b6a:	fc26                	sd	s1,56(sp)
    1b6c:	f84a                	sd	s2,48(sp)
    1b6e:	f44e                	sd	s3,40(sp)
    1b70:	f052                	sd	s4,32(sp)
    1b72:	ec56                	sd	s5,24(sp)
    1b74:	0880                	addi	s0,sp,80
    1b76:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1b78:	4485                	li	s1,1
    1b7a:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1b7c:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1b7e:	69b1                	lui	s3,0xc
    1b80:	35098993          	addi	s3,s3,848 # c350 <buf+0x698>
    1b84:	1003d937          	lui	s2,0x1003d
    1b88:	090e                	slli	s2,s2,0x3
    1b8a:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002e7c8>
    pid = fork();
    1b8e:	19a030ef          	jal	ra,4d28 <fork>
    if(pid < 0){
    1b92:	02054763          	bltz	a0,1bc0 <kernmem+0x5c>
    if(pid == 0){
    1b96:	cd1d                	beqz	a0,1bd4 <kernmem+0x70>
    wait(&xstatus);
    1b98:	fbc40513          	addi	a0,s0,-68
    1b9c:	19c030ef          	jal	ra,4d38 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1ba0:	fbc42783          	lw	a5,-68(s0)
    1ba4:	05579563          	bne	a5,s5,1bee <kernmem+0x8a>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1ba8:	94ce                	add	s1,s1,s3
    1baa:	ff2492e3          	bne	s1,s2,1b8e <kernmem+0x2a>
}
    1bae:	60a6                	ld	ra,72(sp)
    1bb0:	6406                	ld	s0,64(sp)
    1bb2:	74e2                	ld	s1,56(sp)
    1bb4:	7942                	ld	s2,48(sp)
    1bb6:	79a2                	ld	s3,40(sp)
    1bb8:	7a02                	ld	s4,32(sp)
    1bba:	6ae2                	ld	s5,24(sp)
    1bbc:	6161                	addi	sp,sp,80
    1bbe:	8082                	ret
      printf("%s: fork failed\n", s);
    1bc0:	85d2                	mv	a1,s4
    1bc2:	00004517          	auipc	a0,0x4
    1bc6:	00650513          	addi	a0,a0,6 # 5bc8 <malloc+0x9a8>
    1bca:	5a2030ef          	jal	ra,516c <printf>
      exit(1);
    1bce:	4505                	li	a0,1
    1bd0:	160030ef          	jal	ra,4d30 <exit>
      printf("%s: oops could read %p = %x\n", s, a, *a);
    1bd4:	0004c683          	lbu	a3,0(s1)
    1bd8:	8626                	mv	a2,s1
    1bda:	85d2                	mv	a1,s4
    1bdc:	00004517          	auipc	a0,0x4
    1be0:	2bc50513          	addi	a0,a0,700 # 5e98 <malloc+0xc78>
    1be4:	588030ef          	jal	ra,516c <printf>
      exit(1);
    1be8:	4505                	li	a0,1
    1bea:	146030ef          	jal	ra,4d30 <exit>
      exit(1);
    1bee:	4505                	li	a0,1
    1bf0:	140030ef          	jal	ra,4d30 <exit>

0000000000001bf4 <MAXVAplus>:
{
    1bf4:	7179                	addi	sp,sp,-48
    1bf6:	f406                	sd	ra,40(sp)
    1bf8:	f022                	sd	s0,32(sp)
    1bfa:	ec26                	sd	s1,24(sp)
    1bfc:	e84a                	sd	s2,16(sp)
    1bfe:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    1c00:	4785                	li	a5,1
    1c02:	179a                	slli	a5,a5,0x26
    1c04:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    1c08:	fd843783          	ld	a5,-40(s0)
    1c0c:	cb85                	beqz	a5,1c3c <MAXVAplus+0x48>
    1c0e:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    1c10:	54fd                	li	s1,-1
    pid = fork();
    1c12:	116030ef          	jal	ra,4d28 <fork>
    if(pid < 0){
    1c16:	02054963          	bltz	a0,1c48 <MAXVAplus+0x54>
    if(pid == 0){
    1c1a:	c129                	beqz	a0,1c5c <MAXVAplus+0x68>
    wait(&xstatus);
    1c1c:	fd440513          	addi	a0,s0,-44
    1c20:	118030ef          	jal	ra,4d38 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1c24:	fd442783          	lw	a5,-44(s0)
    1c28:	04979c63          	bne	a5,s1,1c80 <MAXVAplus+0x8c>
  for( ; a != 0; a <<= 1){
    1c2c:	fd843783          	ld	a5,-40(s0)
    1c30:	0786                	slli	a5,a5,0x1
    1c32:	fcf43c23          	sd	a5,-40(s0)
    1c36:	fd843783          	ld	a5,-40(s0)
    1c3a:	ffe1                	bnez	a5,1c12 <MAXVAplus+0x1e>
}
    1c3c:	70a2                	ld	ra,40(sp)
    1c3e:	7402                	ld	s0,32(sp)
    1c40:	64e2                	ld	s1,24(sp)
    1c42:	6942                	ld	s2,16(sp)
    1c44:	6145                	addi	sp,sp,48
    1c46:	8082                	ret
      printf("%s: fork failed\n", s);
    1c48:	85ca                	mv	a1,s2
    1c4a:	00004517          	auipc	a0,0x4
    1c4e:	f7e50513          	addi	a0,a0,-130 # 5bc8 <malloc+0x9a8>
    1c52:	51a030ef          	jal	ra,516c <printf>
      exit(1);
    1c56:	4505                	li	a0,1
    1c58:	0d8030ef          	jal	ra,4d30 <exit>
      *(char*)a = 99;
    1c5c:	fd843783          	ld	a5,-40(s0)
    1c60:	06300713          	li	a4,99
    1c64:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %p\n", s, (void*)a);
    1c68:	fd843603          	ld	a2,-40(s0)
    1c6c:	85ca                	mv	a1,s2
    1c6e:	00004517          	auipc	a0,0x4
    1c72:	24a50513          	addi	a0,a0,586 # 5eb8 <malloc+0xc98>
    1c76:	4f6030ef          	jal	ra,516c <printf>
      exit(1);
    1c7a:	4505                	li	a0,1
    1c7c:	0b4030ef          	jal	ra,4d30 <exit>
      exit(1);
    1c80:	4505                	li	a0,1
    1c82:	0ae030ef          	jal	ra,4d30 <exit>

0000000000001c86 <stacktest>:
{
    1c86:	7179                	addi	sp,sp,-48
    1c88:	f406                	sd	ra,40(sp)
    1c8a:	f022                	sd	s0,32(sp)
    1c8c:	ec26                	sd	s1,24(sp)
    1c8e:	1800                	addi	s0,sp,48
    1c90:	84aa                	mv	s1,a0
  pid = fork();
    1c92:	096030ef          	jal	ra,4d28 <fork>
  if(pid == 0) {
    1c96:	cd11                	beqz	a0,1cb2 <stacktest+0x2c>
  } else if(pid < 0){
    1c98:	02054c63          	bltz	a0,1cd0 <stacktest+0x4a>
  wait(&xstatus);
    1c9c:	fdc40513          	addi	a0,s0,-36
    1ca0:	098030ef          	jal	ra,4d38 <wait>
  if(xstatus == -1)  // kernel killed child?
    1ca4:	fdc42503          	lw	a0,-36(s0)
    1ca8:	57fd                	li	a5,-1
    1caa:	02f50d63          	beq	a0,a5,1ce4 <stacktest+0x5e>
    exit(xstatus);
    1cae:	082030ef          	jal	ra,4d30 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1cb2:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %d\n", s, *sp);
    1cb4:	77fd                	lui	a5,0xfffff
    1cb6:	97ba                	add	a5,a5,a4
    1cb8:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xffffffffffff0348>
    1cbc:	85a6                	mv	a1,s1
    1cbe:	00004517          	auipc	a0,0x4
    1cc2:	21250513          	addi	a0,a0,530 # 5ed0 <malloc+0xcb0>
    1cc6:	4a6030ef          	jal	ra,516c <printf>
    exit(1);
    1cca:	4505                	li	a0,1
    1ccc:	064030ef          	jal	ra,4d30 <exit>
    printf("%s: fork failed\n", s);
    1cd0:	85a6                	mv	a1,s1
    1cd2:	00004517          	auipc	a0,0x4
    1cd6:	ef650513          	addi	a0,a0,-266 # 5bc8 <malloc+0x9a8>
    1cda:	492030ef          	jal	ra,516c <printf>
    exit(1);
    1cde:	4505                	li	a0,1
    1ce0:	050030ef          	jal	ra,4d30 <exit>
    exit(0);
    1ce4:	4501                	li	a0,0
    1ce6:	04a030ef          	jal	ra,4d30 <exit>

0000000000001cea <nowrite>:
{
    1cea:	7159                	addi	sp,sp,-112
    1cec:	f486                	sd	ra,104(sp)
    1cee:	f0a2                	sd	s0,96(sp)
    1cf0:	eca6                	sd	s1,88(sp)
    1cf2:	e8ca                	sd	s2,80(sp)
    1cf4:	e4ce                	sd	s3,72(sp)
    1cf6:	1880                	addi	s0,sp,112
    1cf8:	89aa                	mv	s3,a0
  uint64 addrs[] = { 0, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
    1cfa:	00006797          	auipc	a5,0x6
    1cfe:	b7e78793          	addi	a5,a5,-1154 # 7878 <malloc+0x2658>
    1d02:	7788                	ld	a0,40(a5)
    1d04:	7b8c                	ld	a1,48(a5)
    1d06:	7f90                	ld	a2,56(a5)
    1d08:	63b4                	ld	a3,64(a5)
    1d0a:	67b8                	ld	a4,72(a5)
    1d0c:	6bbc                	ld	a5,80(a5)
    1d0e:	f8a43c23          	sd	a0,-104(s0)
    1d12:	fab43023          	sd	a1,-96(s0)
    1d16:	fac43423          	sd	a2,-88(s0)
    1d1a:	fad43823          	sd	a3,-80(s0)
    1d1e:	fae43c23          	sd	a4,-72(s0)
    1d22:	fcf43023          	sd	a5,-64(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d26:	4481                	li	s1,0
    1d28:	4919                	li	s2,6
    pid = fork();
    1d2a:	7ff020ef          	jal	ra,4d28 <fork>
    if(pid == 0) {
    1d2e:	c105                	beqz	a0,1d4e <nowrite+0x64>
    } else if(pid < 0){
    1d30:	04054263          	bltz	a0,1d74 <nowrite+0x8a>
    wait(&xstatus);
    1d34:	fcc40513          	addi	a0,s0,-52
    1d38:	000030ef          	jal	ra,4d38 <wait>
    if(xstatus == 0){
    1d3c:	fcc42783          	lw	a5,-52(s0)
    1d40:	c7a1                	beqz	a5,1d88 <nowrite+0x9e>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d42:	2485                	addiw	s1,s1,1
    1d44:	ff2493e3          	bne	s1,s2,1d2a <nowrite+0x40>
  exit(0);
    1d48:	4501                	li	a0,0
    1d4a:	7e7020ef          	jal	ra,4d30 <exit>
      volatile int *addr = (int *) addrs[ai];
    1d4e:	048e                	slli	s1,s1,0x3
    1d50:	fd048793          	addi	a5,s1,-48
    1d54:	008784b3          	add	s1,a5,s0
    1d58:	fc84b603          	ld	a2,-56(s1)
      *addr = 10;
    1d5c:	47a9                	li	a5,10
    1d5e:	c21c                	sw	a5,0(a2)
      printf("%s: write to %p did not fail!\n", s, addr);
    1d60:	85ce                	mv	a1,s3
    1d62:	00004517          	auipc	a0,0x4
    1d66:	19650513          	addi	a0,a0,406 # 5ef8 <malloc+0xcd8>
    1d6a:	402030ef          	jal	ra,516c <printf>
      exit(0);
    1d6e:	4501                	li	a0,0
    1d70:	7c1020ef          	jal	ra,4d30 <exit>
      printf("%s: fork failed\n", s);
    1d74:	85ce                	mv	a1,s3
    1d76:	00004517          	auipc	a0,0x4
    1d7a:	e5250513          	addi	a0,a0,-430 # 5bc8 <malloc+0x9a8>
    1d7e:	3ee030ef          	jal	ra,516c <printf>
      exit(1);
    1d82:	4505                	li	a0,1
    1d84:	7ad020ef          	jal	ra,4d30 <exit>
      exit(1);
    1d88:	4505                	li	a0,1
    1d8a:	7a7020ef          	jal	ra,4d30 <exit>

0000000000001d8e <manywrites>:
{
    1d8e:	711d                	addi	sp,sp,-96
    1d90:	ec86                	sd	ra,88(sp)
    1d92:	e8a2                	sd	s0,80(sp)
    1d94:	e4a6                	sd	s1,72(sp)
    1d96:	e0ca                	sd	s2,64(sp)
    1d98:	fc4e                	sd	s3,56(sp)
    1d9a:	f852                	sd	s4,48(sp)
    1d9c:	f456                	sd	s5,40(sp)
    1d9e:	f05a                	sd	s6,32(sp)
    1da0:	ec5e                	sd	s7,24(sp)
    1da2:	1080                	addi	s0,sp,96
    1da4:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1da6:	4981                	li	s3,0
    1da8:	4911                	li	s2,4
    int pid = fork();
    1daa:	77f020ef          	jal	ra,4d28 <fork>
    1dae:	84aa                	mv	s1,a0
    if(pid < 0){
    1db0:	02054563          	bltz	a0,1dda <manywrites+0x4c>
    if(pid == 0){
    1db4:	cd05                	beqz	a0,1dec <manywrites+0x5e>
  for(int ci = 0; ci < nchildren; ci++){
    1db6:	2985                	addiw	s3,s3,1
    1db8:	ff2999e3          	bne	s3,s2,1daa <manywrites+0x1c>
    1dbc:	4491                	li	s1,4
    int st = 0;
    1dbe:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1dc2:	fa840513          	addi	a0,s0,-88
    1dc6:	773020ef          	jal	ra,4d38 <wait>
    if(st != 0)
    1dca:	fa842503          	lw	a0,-88(s0)
    1dce:	e169                	bnez	a0,1e90 <manywrites+0x102>
  for(int ci = 0; ci < nchildren; ci++){
    1dd0:	34fd                	addiw	s1,s1,-1
    1dd2:	f4f5                	bnez	s1,1dbe <manywrites+0x30>
  exit(0);
    1dd4:	4501                	li	a0,0
    1dd6:	75b020ef          	jal	ra,4d30 <exit>
      printf("fork failed\n");
    1dda:	00005517          	auipc	a0,0x5
    1dde:	39650513          	addi	a0,a0,918 # 7170 <malloc+0x1f50>
    1de2:	38a030ef          	jal	ra,516c <printf>
      exit(1);
    1de6:	4505                	li	a0,1
    1de8:	749020ef          	jal	ra,4d30 <exit>
      name[0] = 'b';
    1dec:	06200793          	li	a5,98
    1df0:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1df4:	0619879b          	addiw	a5,s3,97
    1df8:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1dfc:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1e00:	fa840513          	addi	a0,s0,-88
    1e04:	77d020ef          	jal	ra,4d80 <unlink>
    1e08:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1e0a:	0000ab17          	auipc	s6,0xa
    1e0e:	eaeb0b13          	addi	s6,s6,-338 # bcb8 <buf>
        for(int i = 0; i < ci+1; i++){
    1e12:	8a26                	mv	s4,s1
    1e14:	0209c863          	bltz	s3,1e44 <manywrites+0xb6>
          int fd = open(name, O_CREATE | O_RDWR);
    1e18:	20200593          	li	a1,514
    1e1c:	fa840513          	addi	a0,s0,-88
    1e20:	751020ef          	jal	ra,4d70 <open>
    1e24:	892a                	mv	s2,a0
          if(fd < 0){
    1e26:	02054d63          	bltz	a0,1e60 <manywrites+0xd2>
          int cc = write(fd, buf, sz);
    1e2a:	660d                	lui	a2,0x3
    1e2c:	85da                	mv	a1,s6
    1e2e:	723020ef          	jal	ra,4d50 <write>
          if(cc != sz){
    1e32:	678d                	lui	a5,0x3
    1e34:	04f51263          	bne	a0,a5,1e78 <manywrites+0xea>
          close(fd);
    1e38:	854a                	mv	a0,s2
    1e3a:	71f020ef          	jal	ra,4d58 <close>
        for(int i = 0; i < ci+1; i++){
    1e3e:	2a05                	addiw	s4,s4,1
    1e40:	fd49dce3          	bge	s3,s4,1e18 <manywrites+0x8a>
        unlink(name);
    1e44:	fa840513          	addi	a0,s0,-88
    1e48:	739020ef          	jal	ra,4d80 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1e4c:	3bfd                	addiw	s7,s7,-1
    1e4e:	fc0b92e3          	bnez	s7,1e12 <manywrites+0x84>
      unlink(name);
    1e52:	fa840513          	addi	a0,s0,-88
    1e56:	72b020ef          	jal	ra,4d80 <unlink>
      exit(0);
    1e5a:	4501                	li	a0,0
    1e5c:	6d5020ef          	jal	ra,4d30 <exit>
            printf("%s: cannot create %s\n", s, name);
    1e60:	fa840613          	addi	a2,s0,-88
    1e64:	85d6                	mv	a1,s5
    1e66:	00004517          	auipc	a0,0x4
    1e6a:	0b250513          	addi	a0,a0,178 # 5f18 <malloc+0xcf8>
    1e6e:	2fe030ef          	jal	ra,516c <printf>
            exit(1);
    1e72:	4505                	li	a0,1
    1e74:	6bd020ef          	jal	ra,4d30 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1e78:	86aa                	mv	a3,a0
    1e7a:	660d                	lui	a2,0x3
    1e7c:	85d6                	mv	a1,s5
    1e7e:	00003517          	auipc	a0,0x3
    1e82:	58a50513          	addi	a0,a0,1418 # 5408 <malloc+0x1e8>
    1e86:	2e6030ef          	jal	ra,516c <printf>
            exit(1);
    1e8a:	4505                	li	a0,1
    1e8c:	6a5020ef          	jal	ra,4d30 <exit>
      exit(st);
    1e90:	6a1020ef          	jal	ra,4d30 <exit>

0000000000001e94 <copyinstr3>:
{
    1e94:	7179                	addi	sp,sp,-48
    1e96:	f406                	sd	ra,40(sp)
    1e98:	f022                	sd	s0,32(sp)
    1e9a:	ec26                	sd	s1,24(sp)
    1e9c:	1800                	addi	s0,sp,48
  sbrk(8192);
    1e9e:	6509                	lui	a0,0x2
    1ea0:	65d020ef          	jal	ra,4cfc <sbrk>
  uint64 top = (uint64) sbrk(0);
    1ea4:	4501                	li	a0,0
    1ea6:	657020ef          	jal	ra,4cfc <sbrk>
  if((top % PGSIZE) != 0){
    1eaa:	03451793          	slli	a5,a0,0x34
    1eae:	e7bd                	bnez	a5,1f1c <copyinstr3+0x88>
  top = (uint64) sbrk(0);
    1eb0:	4501                	li	a0,0
    1eb2:	64b020ef          	jal	ra,4cfc <sbrk>
  if(top % PGSIZE){
    1eb6:	03451793          	slli	a5,a0,0x34
    1eba:	ebad                	bnez	a5,1f2c <copyinstr3+0x98>
  char *b = (char *) (top - 1);
    1ebc:	fff50493          	addi	s1,a0,-1 # 1fff <rwsbrk+0x67>
  *b = 'x';
    1ec0:	07800793          	li	a5,120
    1ec4:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1ec8:	8526                	mv	a0,s1
    1eca:	6b7020ef          	jal	ra,4d80 <unlink>
  if(ret != -1){
    1ece:	57fd                	li	a5,-1
    1ed0:	06f51763          	bne	a0,a5,1f3e <copyinstr3+0xaa>
  int fd = open(b, O_CREATE | O_WRONLY);
    1ed4:	20100593          	li	a1,513
    1ed8:	8526                	mv	a0,s1
    1eda:	697020ef          	jal	ra,4d70 <open>
  if(fd != -1){
    1ede:	57fd                	li	a5,-1
    1ee0:	06f51a63          	bne	a0,a5,1f54 <copyinstr3+0xc0>
  ret = link(b, b);
    1ee4:	85a6                	mv	a1,s1
    1ee6:	8526                	mv	a0,s1
    1ee8:	6a9020ef          	jal	ra,4d90 <link>
  if(ret != -1){
    1eec:	57fd                	li	a5,-1
    1eee:	06f51e63          	bne	a0,a5,1f6a <copyinstr3+0xd6>
  char *args[] = { "xx", 0 };
    1ef2:	00005797          	auipc	a5,0x5
    1ef6:	d2678793          	addi	a5,a5,-730 # 6c18 <malloc+0x19f8>
    1efa:	fcf43823          	sd	a5,-48(s0)
    1efe:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1f02:	fd040593          	addi	a1,s0,-48
    1f06:	8526                	mv	a0,s1
    1f08:	661020ef          	jal	ra,4d68 <exec>
  if(ret != -1){
    1f0c:	57fd                	li	a5,-1
    1f0e:	06f51a63          	bne	a0,a5,1f82 <copyinstr3+0xee>
}
    1f12:	70a2                	ld	ra,40(sp)
    1f14:	7402                	ld	s0,32(sp)
    1f16:	64e2                	ld	s1,24(sp)
    1f18:	6145                	addi	sp,sp,48
    1f1a:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1f1c:	0347d513          	srli	a0,a5,0x34
    1f20:	6785                	lui	a5,0x1
    1f22:	40a7853b          	subw	a0,a5,a0
    1f26:	5d7020ef          	jal	ra,4cfc <sbrk>
    1f2a:	b759                	j	1eb0 <copyinstr3+0x1c>
    printf("oops\n");
    1f2c:	00004517          	auipc	a0,0x4
    1f30:	00450513          	addi	a0,a0,4 # 5f30 <malloc+0xd10>
    1f34:	238030ef          	jal	ra,516c <printf>
    exit(1);
    1f38:	4505                	li	a0,1
    1f3a:	5f7020ef          	jal	ra,4d30 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1f3e:	862a                	mv	a2,a0
    1f40:	85a6                	mv	a1,s1
    1f42:	00004517          	auipc	a0,0x4
    1f46:	ba650513          	addi	a0,a0,-1114 # 5ae8 <malloc+0x8c8>
    1f4a:	222030ef          	jal	ra,516c <printf>
    exit(1);
    1f4e:	4505                	li	a0,1
    1f50:	5e1020ef          	jal	ra,4d30 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1f54:	862a                	mv	a2,a0
    1f56:	85a6                	mv	a1,s1
    1f58:	00004517          	auipc	a0,0x4
    1f5c:	bb050513          	addi	a0,a0,-1104 # 5b08 <malloc+0x8e8>
    1f60:	20c030ef          	jal	ra,516c <printf>
    exit(1);
    1f64:	4505                	li	a0,1
    1f66:	5cb020ef          	jal	ra,4d30 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1f6a:	86aa                	mv	a3,a0
    1f6c:	8626                	mv	a2,s1
    1f6e:	85a6                	mv	a1,s1
    1f70:	00004517          	auipc	a0,0x4
    1f74:	bb850513          	addi	a0,a0,-1096 # 5b28 <malloc+0x908>
    1f78:	1f4030ef          	jal	ra,516c <printf>
    exit(1);
    1f7c:	4505                	li	a0,1
    1f7e:	5b3020ef          	jal	ra,4d30 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1f82:	567d                	li	a2,-1
    1f84:	85a6                	mv	a1,s1
    1f86:	00004517          	auipc	a0,0x4
    1f8a:	bca50513          	addi	a0,a0,-1078 # 5b50 <malloc+0x930>
    1f8e:	1de030ef          	jal	ra,516c <printf>
    exit(1);
    1f92:	4505                	li	a0,1
    1f94:	59d020ef          	jal	ra,4d30 <exit>

0000000000001f98 <rwsbrk>:
{
    1f98:	1101                	addi	sp,sp,-32
    1f9a:	ec06                	sd	ra,24(sp)
    1f9c:	e822                	sd	s0,16(sp)
    1f9e:	e426                	sd	s1,8(sp)
    1fa0:	e04a                	sd	s2,0(sp)
    1fa2:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1fa4:	6509                	lui	a0,0x2
    1fa6:	557020ef          	jal	ra,4cfc <sbrk>
  if(a == (uint64) SBRK_ERROR) {
    1faa:	57fd                	li	a5,-1
    1fac:	04f50863          	beq	a0,a5,1ffc <rwsbrk+0x64>
    1fb0:	84aa                	mv	s1,a0
  if (sbrk(-8192) == SBRK_ERROR) {
    1fb2:	7579                	lui	a0,0xffffe
    1fb4:	549020ef          	jal	ra,4cfc <sbrk>
    1fb8:	57fd                	li	a5,-1
    1fba:	04f50a63          	beq	a0,a5,200e <rwsbrk+0x76>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1fbe:	20100593          	li	a1,513
    1fc2:	00004517          	auipc	a0,0x4
    1fc6:	fae50513          	addi	a0,a0,-82 # 5f70 <malloc+0xd50>
    1fca:	5a7020ef          	jal	ra,4d70 <open>
    1fce:	892a                	mv	s2,a0
  if(fd < 0){
    1fd0:	04054863          	bltz	a0,2020 <rwsbrk+0x88>
  n = write(fd, (void*)(a+PGSIZE), 1024);
    1fd4:	6785                	lui	a5,0x1
    1fd6:	94be                	add	s1,s1,a5
    1fd8:	40000613          	li	a2,1024
    1fdc:	85a6                	mv	a1,s1
    1fde:	573020ef          	jal	ra,4d50 <write>
    1fe2:	862a                	mv	a2,a0
  if(n >= 0){
    1fe4:	04054763          	bltz	a0,2032 <rwsbrk+0x9a>
    printf("write(fd, %p, 1024) returned %d, not -1\n", (void*)a+PGSIZE, n);
    1fe8:	85a6                	mv	a1,s1
    1fea:	00004517          	auipc	a0,0x4
    1fee:	fa650513          	addi	a0,a0,-90 # 5f90 <malloc+0xd70>
    1ff2:	17a030ef          	jal	ra,516c <printf>
    exit(1);
    1ff6:	4505                	li	a0,1
    1ff8:	539020ef          	jal	ra,4d30 <exit>
    printf("sbrk(rwsbrk) failed\n");
    1ffc:	00004517          	auipc	a0,0x4
    2000:	f3c50513          	addi	a0,a0,-196 # 5f38 <malloc+0xd18>
    2004:	168030ef          	jal	ra,516c <printf>
    exit(1);
    2008:	4505                	li	a0,1
    200a:	527020ef          	jal	ra,4d30 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    200e:	00004517          	auipc	a0,0x4
    2012:	f4250513          	addi	a0,a0,-190 # 5f50 <malloc+0xd30>
    2016:	156030ef          	jal	ra,516c <printf>
    exit(1);
    201a:	4505                	li	a0,1
    201c:	515020ef          	jal	ra,4d30 <exit>
    printf("open(rwsbrk) failed\n");
    2020:	00004517          	auipc	a0,0x4
    2024:	f5850513          	addi	a0,a0,-168 # 5f78 <malloc+0xd58>
    2028:	144030ef          	jal	ra,516c <printf>
    exit(1);
    202c:	4505                	li	a0,1
    202e:	503020ef          	jal	ra,4d30 <exit>
  close(fd);
    2032:	854a                	mv	a0,s2
    2034:	525020ef          	jal	ra,4d58 <close>
  unlink("rwsbrk");
    2038:	00004517          	auipc	a0,0x4
    203c:	f3850513          	addi	a0,a0,-200 # 5f70 <malloc+0xd50>
    2040:	541020ef          	jal	ra,4d80 <unlink>
  fd = open("README", O_RDONLY);
    2044:	4581                	li	a1,0
    2046:	00003517          	auipc	a0,0x3
    204a:	4ca50513          	addi	a0,a0,1226 # 5510 <malloc+0x2f0>
    204e:	523020ef          	jal	ra,4d70 <open>
    2052:	892a                	mv	s2,a0
  if(fd < 0){
    2054:	02054363          	bltz	a0,207a <rwsbrk+0xe2>
  n = read(fd, (void*)(a+PGSIZE), 10);
    2058:	4629                	li	a2,10
    205a:	85a6                	mv	a1,s1
    205c:	4ed020ef          	jal	ra,4d48 <read>
    2060:	862a                	mv	a2,a0
  if(n >= 0){
    2062:	02054563          	bltz	a0,208c <rwsbrk+0xf4>
    printf("read(fd, %p, 10) returned %d, not -1\n", (void*)a+PGSIZE, n);
    2066:	85a6                	mv	a1,s1
    2068:	00004517          	auipc	a0,0x4
    206c:	f5850513          	addi	a0,a0,-168 # 5fc0 <malloc+0xda0>
    2070:	0fc030ef          	jal	ra,516c <printf>
    exit(1);
    2074:	4505                	li	a0,1
    2076:	4bb020ef          	jal	ra,4d30 <exit>
    printf("open(README) failed\n");
    207a:	00003517          	auipc	a0,0x3
    207e:	49e50513          	addi	a0,a0,1182 # 5518 <malloc+0x2f8>
    2082:	0ea030ef          	jal	ra,516c <printf>
    exit(1);
    2086:	4505                	li	a0,1
    2088:	4a9020ef          	jal	ra,4d30 <exit>
  close(fd);
    208c:	854a                	mv	a0,s2
    208e:	4cb020ef          	jal	ra,4d58 <close>
  exit(0);
    2092:	4501                	li	a0,0
    2094:	49d020ef          	jal	ra,4d30 <exit>

0000000000002098 <sbrkbasic>:
{
    2098:	7139                	addi	sp,sp,-64
    209a:	fc06                	sd	ra,56(sp)
    209c:	f822                	sd	s0,48(sp)
    209e:	f426                	sd	s1,40(sp)
    20a0:	f04a                	sd	s2,32(sp)
    20a2:	ec4e                	sd	s3,24(sp)
    20a4:	e852                	sd	s4,16(sp)
    20a6:	0080                	addi	s0,sp,64
    20a8:	8a2a                	mv	s4,a0
  pid = fork();
    20aa:	47f020ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    20ae:	02054863          	bltz	a0,20de <sbrkbasic+0x46>
  if(pid == 0){
    20b2:	e131                	bnez	a0,20f6 <sbrkbasic+0x5e>
    a = sbrk(TOOMUCH);
    20b4:	40000537          	lui	a0,0x40000
    20b8:	445020ef          	jal	ra,4cfc <sbrk>
    if(a == (char*)SBRK_ERROR){
    20bc:	57fd                	li	a5,-1
    20be:	02f50963          	beq	a0,a5,20f0 <sbrkbasic+0x58>
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20c2:	400007b7          	lui	a5,0x40000
    20c6:	97aa                	add	a5,a5,a0
      *b = 99;
    20c8:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20cc:	6705                	lui	a4,0x1
      *b = 99;
    20ce:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff1348>
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20d2:	953a                	add	a0,a0,a4
    20d4:	fef51de3          	bne	a0,a5,20ce <sbrkbasic+0x36>
    exit(1);
    20d8:	4505                	li	a0,1
    20da:	457020ef          	jal	ra,4d30 <exit>
    printf("fork failed in sbrkbasic\n");
    20de:	00004517          	auipc	a0,0x4
    20e2:	f0a50513          	addi	a0,a0,-246 # 5fe8 <malloc+0xdc8>
    20e6:	086030ef          	jal	ra,516c <printf>
    exit(1);
    20ea:	4505                	li	a0,1
    20ec:	445020ef          	jal	ra,4d30 <exit>
      exit(0);
    20f0:	4501                	li	a0,0
    20f2:	43f020ef          	jal	ra,4d30 <exit>
  wait(&xstatus);
    20f6:	fcc40513          	addi	a0,s0,-52
    20fa:	43f020ef          	jal	ra,4d38 <wait>
  if(xstatus == 1){
    20fe:	fcc42703          	lw	a4,-52(s0)
    2102:	4785                	li	a5,1
    2104:	00f70b63          	beq	a4,a5,211a <sbrkbasic+0x82>
  a = sbrk(0);
    2108:	4501                	li	a0,0
    210a:	3f3020ef          	jal	ra,4cfc <sbrk>
    210e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2110:	4901                	li	s2,0
    2112:	6985                	lui	s3,0x1
    2114:	38898993          	addi	s3,s3,904 # 1388 <exectest+0x5a>
    2118:	a821                	j	2130 <sbrkbasic+0x98>
    printf("%s: too much memory allocated!\n", s);
    211a:	85d2                	mv	a1,s4
    211c:	00004517          	auipc	a0,0x4
    2120:	eec50513          	addi	a0,a0,-276 # 6008 <malloc+0xde8>
    2124:	048030ef          	jal	ra,516c <printf>
    exit(1);
    2128:	4505                	li	a0,1
    212a:	407020ef          	jal	ra,4d30 <exit>
    a = b + 1;
    212e:	84be                	mv	s1,a5
    b = sbrk(1);
    2130:	4505                	li	a0,1
    2132:	3cb020ef          	jal	ra,4cfc <sbrk>
    if(b != a){
    2136:	04951263          	bne	a0,s1,217a <sbrkbasic+0xe2>
    *b = 1;
    213a:	4785                	li	a5,1
    213c:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2140:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2144:	2905                	addiw	s2,s2,1
    2146:	ff3914e3          	bne	s2,s3,212e <sbrkbasic+0x96>
  pid = fork();
    214a:	3df020ef          	jal	ra,4d28 <fork>
    214e:	892a                	mv	s2,a0
  if(pid < 0){
    2150:	04054263          	bltz	a0,2194 <sbrkbasic+0xfc>
  c = sbrk(1);
    2154:	4505                	li	a0,1
    2156:	3a7020ef          	jal	ra,4cfc <sbrk>
  c = sbrk(1);
    215a:	4505                	li	a0,1
    215c:	3a1020ef          	jal	ra,4cfc <sbrk>
  if(c != a + 1){
    2160:	0489                	addi	s1,s1,2
    2162:	04a48363          	beq	s1,a0,21a8 <sbrkbasic+0x110>
    printf("%s: sbrk test failed post-fork\n", s);
    2166:	85d2                	mv	a1,s4
    2168:	00004517          	auipc	a0,0x4
    216c:	f0050513          	addi	a0,a0,-256 # 6068 <malloc+0xe48>
    2170:	7fd020ef          	jal	ra,516c <printf>
    exit(1);
    2174:	4505                	li	a0,1
    2176:	3bb020ef          	jal	ra,4d30 <exit>
      printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
    217a:	872a                	mv	a4,a0
    217c:	86a6                	mv	a3,s1
    217e:	864a                	mv	a2,s2
    2180:	85d2                	mv	a1,s4
    2182:	00004517          	auipc	a0,0x4
    2186:	ea650513          	addi	a0,a0,-346 # 6028 <malloc+0xe08>
    218a:	7e3020ef          	jal	ra,516c <printf>
      exit(1);
    218e:	4505                	li	a0,1
    2190:	3a1020ef          	jal	ra,4d30 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2194:	85d2                	mv	a1,s4
    2196:	00004517          	auipc	a0,0x4
    219a:	eb250513          	addi	a0,a0,-334 # 6048 <malloc+0xe28>
    219e:	7cf020ef          	jal	ra,516c <printf>
    exit(1);
    21a2:	4505                	li	a0,1
    21a4:	38d020ef          	jal	ra,4d30 <exit>
  if(pid == 0)
    21a8:	00091563          	bnez	s2,21b2 <sbrkbasic+0x11a>
    exit(0);
    21ac:	4501                	li	a0,0
    21ae:	383020ef          	jal	ra,4d30 <exit>
  wait(&xstatus);
    21b2:	fcc40513          	addi	a0,s0,-52
    21b6:	383020ef          	jal	ra,4d38 <wait>
  exit(xstatus);
    21ba:	fcc42503          	lw	a0,-52(s0)
    21be:	373020ef          	jal	ra,4d30 <exit>

00000000000021c2 <sbrkmuch>:
{
    21c2:	7179                	addi	sp,sp,-48
    21c4:	f406                	sd	ra,40(sp)
    21c6:	f022                	sd	s0,32(sp)
    21c8:	ec26                	sd	s1,24(sp)
    21ca:	e84a                	sd	s2,16(sp)
    21cc:	e44e                	sd	s3,8(sp)
    21ce:	e052                	sd	s4,0(sp)
    21d0:	1800                	addi	s0,sp,48
    21d2:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    21d4:	4501                	li	a0,0
    21d6:	327020ef          	jal	ra,4cfc <sbrk>
    21da:	892a                	mv	s2,a0
  a = sbrk(0);
    21dc:	4501                	li	a0,0
    21de:	31f020ef          	jal	ra,4cfc <sbrk>
    21e2:	84aa                	mv	s1,a0
  p = sbrk(amt);
    21e4:	06400537          	lui	a0,0x6400
    21e8:	9d05                	subw	a0,a0,s1
    21ea:	313020ef          	jal	ra,4cfc <sbrk>
  if (p != a) {
    21ee:	08a49763          	bne	s1,a0,227c <sbrkmuch+0xba>
  *lastaddr = 99;
    21f2:	064007b7          	lui	a5,0x6400
    21f6:	06300713          	li	a4,99
    21fa:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f1347>
  a = sbrk(0);
    21fe:	4501                	li	a0,0
    2200:	2fd020ef          	jal	ra,4cfc <sbrk>
    2204:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2206:	757d                	lui	a0,0xfffff
    2208:	2f5020ef          	jal	ra,4cfc <sbrk>
  if(c == (char*)SBRK_ERROR){
    220c:	57fd                	li	a5,-1
    220e:	08f50163          	beq	a0,a5,2290 <sbrkmuch+0xce>
  c = sbrk(0);
    2212:	4501                	li	a0,0
    2214:	2e9020ef          	jal	ra,4cfc <sbrk>
  if(c != a - PGSIZE){
    2218:	77fd                	lui	a5,0xfffff
    221a:	97a6                	add	a5,a5,s1
    221c:	08f51463          	bne	a0,a5,22a4 <sbrkmuch+0xe2>
  a = sbrk(0);
    2220:	4501                	li	a0,0
    2222:	2db020ef          	jal	ra,4cfc <sbrk>
    2226:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2228:	6505                	lui	a0,0x1
    222a:	2d3020ef          	jal	ra,4cfc <sbrk>
    222e:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2230:	08a49663          	bne	s1,a0,22bc <sbrkmuch+0xfa>
    2234:	4501                	li	a0,0
    2236:	2c7020ef          	jal	ra,4cfc <sbrk>
    223a:	6785                	lui	a5,0x1
    223c:	97a6                	add	a5,a5,s1
    223e:	06f51f63          	bne	a0,a5,22bc <sbrkmuch+0xfa>
  if(*lastaddr == 99){
    2242:	064007b7          	lui	a5,0x6400
    2246:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f1347>
    224a:	06300793          	li	a5,99
    224e:	08f70363          	beq	a4,a5,22d4 <sbrkmuch+0x112>
  a = sbrk(0);
    2252:	4501                	li	a0,0
    2254:	2a9020ef          	jal	ra,4cfc <sbrk>
    2258:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    225a:	4501                	li	a0,0
    225c:	2a1020ef          	jal	ra,4cfc <sbrk>
    2260:	40a9053b          	subw	a0,s2,a0
    2264:	299020ef          	jal	ra,4cfc <sbrk>
  if(c != a){
    2268:	08a49063          	bne	s1,a0,22e8 <sbrkmuch+0x126>
}
    226c:	70a2                	ld	ra,40(sp)
    226e:	7402                	ld	s0,32(sp)
    2270:	64e2                	ld	s1,24(sp)
    2272:	6942                	ld	s2,16(sp)
    2274:	69a2                	ld	s3,8(sp)
    2276:	6a02                	ld	s4,0(sp)
    2278:	6145                	addi	sp,sp,48
    227a:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    227c:	85ce                	mv	a1,s3
    227e:	00004517          	auipc	a0,0x4
    2282:	e0a50513          	addi	a0,a0,-502 # 6088 <malloc+0xe68>
    2286:	6e7020ef          	jal	ra,516c <printf>
    exit(1);
    228a:	4505                	li	a0,1
    228c:	2a5020ef          	jal	ra,4d30 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2290:	85ce                	mv	a1,s3
    2292:	00004517          	auipc	a0,0x4
    2296:	e3e50513          	addi	a0,a0,-450 # 60d0 <malloc+0xeb0>
    229a:	6d3020ef          	jal	ra,516c <printf>
    exit(1);
    229e:	4505                	li	a0,1
    22a0:	291020ef          	jal	ra,4d30 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a, c);
    22a4:	86aa                	mv	a3,a0
    22a6:	8626                	mv	a2,s1
    22a8:	85ce                	mv	a1,s3
    22aa:	00004517          	auipc	a0,0x4
    22ae:	e4650513          	addi	a0,a0,-442 # 60f0 <malloc+0xed0>
    22b2:	6bb020ef          	jal	ra,516c <printf>
    exit(1);
    22b6:	4505                	li	a0,1
    22b8:	279020ef          	jal	ra,4d30 <exit>
    printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
    22bc:	86d2                	mv	a3,s4
    22be:	8626                	mv	a2,s1
    22c0:	85ce                	mv	a1,s3
    22c2:	00004517          	auipc	a0,0x4
    22c6:	e6e50513          	addi	a0,a0,-402 # 6130 <malloc+0xf10>
    22ca:	6a3020ef          	jal	ra,516c <printf>
    exit(1);
    22ce:	4505                	li	a0,1
    22d0:	261020ef          	jal	ra,4d30 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    22d4:	85ce                	mv	a1,s3
    22d6:	00004517          	auipc	a0,0x4
    22da:	e8a50513          	addi	a0,a0,-374 # 6160 <malloc+0xf40>
    22de:	68f020ef          	jal	ra,516c <printf>
    exit(1);
    22e2:	4505                	li	a0,1
    22e4:	24d020ef          	jal	ra,4d30 <exit>
    printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
    22e8:	86aa                	mv	a3,a0
    22ea:	8626                	mv	a2,s1
    22ec:	85ce                	mv	a1,s3
    22ee:	00004517          	auipc	a0,0x4
    22f2:	eaa50513          	addi	a0,a0,-342 # 6198 <malloc+0xf78>
    22f6:	677020ef          	jal	ra,516c <printf>
    exit(1);
    22fa:	4505                	li	a0,1
    22fc:	235020ef          	jal	ra,4d30 <exit>

0000000000002300 <sbrkarg>:
{
    2300:	7179                	addi	sp,sp,-48
    2302:	f406                	sd	ra,40(sp)
    2304:	f022                	sd	s0,32(sp)
    2306:	ec26                	sd	s1,24(sp)
    2308:	e84a                	sd	s2,16(sp)
    230a:	e44e                	sd	s3,8(sp)
    230c:	1800                	addi	s0,sp,48
    230e:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2310:	6505                	lui	a0,0x1
    2312:	1eb020ef          	jal	ra,4cfc <sbrk>
    2316:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2318:	20100593          	li	a1,513
    231c:	00004517          	auipc	a0,0x4
    2320:	ea450513          	addi	a0,a0,-348 # 61c0 <malloc+0xfa0>
    2324:	24d020ef          	jal	ra,4d70 <open>
    2328:	84aa                	mv	s1,a0
  unlink("sbrk");
    232a:	00004517          	auipc	a0,0x4
    232e:	e9650513          	addi	a0,a0,-362 # 61c0 <malloc+0xfa0>
    2332:	24f020ef          	jal	ra,4d80 <unlink>
  if(fd < 0)  {
    2336:	0204c963          	bltz	s1,2368 <sbrkarg+0x68>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    233a:	6605                	lui	a2,0x1
    233c:	85ca                	mv	a1,s2
    233e:	8526                	mv	a0,s1
    2340:	211020ef          	jal	ra,4d50 <write>
    2344:	02054c63          	bltz	a0,237c <sbrkarg+0x7c>
  close(fd);
    2348:	8526                	mv	a0,s1
    234a:	20f020ef          	jal	ra,4d58 <close>
  a = sbrk(PGSIZE);
    234e:	6505                	lui	a0,0x1
    2350:	1ad020ef          	jal	ra,4cfc <sbrk>
  if(pipe((int *) a) != 0){
    2354:	1ed020ef          	jal	ra,4d40 <pipe>
    2358:	ed05                	bnez	a0,2390 <sbrkarg+0x90>
}
    235a:	70a2                	ld	ra,40(sp)
    235c:	7402                	ld	s0,32(sp)
    235e:	64e2                	ld	s1,24(sp)
    2360:	6942                	ld	s2,16(sp)
    2362:	69a2                	ld	s3,8(sp)
    2364:	6145                	addi	sp,sp,48
    2366:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2368:	85ce                	mv	a1,s3
    236a:	00004517          	auipc	a0,0x4
    236e:	e5e50513          	addi	a0,a0,-418 # 61c8 <malloc+0xfa8>
    2372:	5fb020ef          	jal	ra,516c <printf>
    exit(1);
    2376:	4505                	li	a0,1
    2378:	1b9020ef          	jal	ra,4d30 <exit>
    printf("%s: write sbrk failed\n", s);
    237c:	85ce                	mv	a1,s3
    237e:	00004517          	auipc	a0,0x4
    2382:	e6250513          	addi	a0,a0,-414 # 61e0 <malloc+0xfc0>
    2386:	5e7020ef          	jal	ra,516c <printf>
    exit(1);
    238a:	4505                	li	a0,1
    238c:	1a5020ef          	jal	ra,4d30 <exit>
    printf("%s: pipe() failed\n", s);
    2390:	85ce                	mv	a1,s3
    2392:	00004517          	auipc	a0,0x4
    2396:	93e50513          	addi	a0,a0,-1730 # 5cd0 <malloc+0xab0>
    239a:	5d3020ef          	jal	ra,516c <printf>
    exit(1);
    239e:	4505                	li	a0,1
    23a0:	191020ef          	jal	ra,4d30 <exit>

00000000000023a4 <argptest>:
{
    23a4:	1101                	addi	sp,sp,-32
    23a6:	ec06                	sd	ra,24(sp)
    23a8:	e822                	sd	s0,16(sp)
    23aa:	e426                	sd	s1,8(sp)
    23ac:	e04a                	sd	s2,0(sp)
    23ae:	1000                	addi	s0,sp,32
    23b0:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    23b2:	4581                	li	a1,0
    23b4:	00004517          	auipc	a0,0x4
    23b8:	e4450513          	addi	a0,a0,-444 # 61f8 <malloc+0xfd8>
    23bc:	1b5020ef          	jal	ra,4d70 <open>
  if (fd < 0) {
    23c0:	02054563          	bltz	a0,23ea <argptest+0x46>
    23c4:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    23c6:	4501                	li	a0,0
    23c8:	135020ef          	jal	ra,4cfc <sbrk>
    23cc:	567d                	li	a2,-1
    23ce:	fff50593          	addi	a1,a0,-1
    23d2:	8526                	mv	a0,s1
    23d4:	175020ef          	jal	ra,4d48 <read>
  close(fd);
    23d8:	8526                	mv	a0,s1
    23da:	17f020ef          	jal	ra,4d58 <close>
}
    23de:	60e2                	ld	ra,24(sp)
    23e0:	6442                	ld	s0,16(sp)
    23e2:	64a2                	ld	s1,8(sp)
    23e4:	6902                	ld	s2,0(sp)
    23e6:	6105                	addi	sp,sp,32
    23e8:	8082                	ret
    printf("%s: open failed\n", s);
    23ea:	85ca                	mv	a1,s2
    23ec:	00003517          	auipc	a0,0x3
    23f0:	7f450513          	addi	a0,a0,2036 # 5be0 <malloc+0x9c0>
    23f4:	579020ef          	jal	ra,516c <printf>
    exit(1);
    23f8:	4505                	li	a0,1
    23fa:	137020ef          	jal	ra,4d30 <exit>

00000000000023fe <sbrkbugs>:
{
    23fe:	1141                	addi	sp,sp,-16
    2400:	e406                	sd	ra,8(sp)
    2402:	e022                	sd	s0,0(sp)
    2404:	0800                	addi	s0,sp,16
  int pid = fork();
    2406:	123020ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    240a:	00054c63          	bltz	a0,2422 <sbrkbugs+0x24>
  if(pid == 0){
    240e:	e11d                	bnez	a0,2434 <sbrkbugs+0x36>
    int sz = (uint64) sbrk(0);
    2410:	0ed020ef          	jal	ra,4cfc <sbrk>
    sbrk(-sz);
    2414:	40a0053b          	negw	a0,a0
    2418:	0e5020ef          	jal	ra,4cfc <sbrk>
    exit(0);
    241c:	4501                	li	a0,0
    241e:	113020ef          	jal	ra,4d30 <exit>
    printf("fork failed\n");
    2422:	00005517          	auipc	a0,0x5
    2426:	d4e50513          	addi	a0,a0,-690 # 7170 <malloc+0x1f50>
    242a:	543020ef          	jal	ra,516c <printf>
    exit(1);
    242e:	4505                	li	a0,1
    2430:	101020ef          	jal	ra,4d30 <exit>
  wait(0);
    2434:	4501                	li	a0,0
    2436:	103020ef          	jal	ra,4d38 <wait>
  pid = fork();
    243a:	0ef020ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    243e:	00054f63          	bltz	a0,245c <sbrkbugs+0x5e>
  if(pid == 0){
    2442:	e515                	bnez	a0,246e <sbrkbugs+0x70>
    int sz = (uint64) sbrk(0);
    2444:	0b9020ef          	jal	ra,4cfc <sbrk>
    sbrk(-(sz - 3500));
    2448:	6785                	lui	a5,0x1
    244a:	dac7879b          	addiw	a5,a5,-596 # dac <linktest+0x138>
    244e:	40a7853b          	subw	a0,a5,a0
    2452:	0ab020ef          	jal	ra,4cfc <sbrk>
    exit(0);
    2456:	4501                	li	a0,0
    2458:	0d9020ef          	jal	ra,4d30 <exit>
    printf("fork failed\n");
    245c:	00005517          	auipc	a0,0x5
    2460:	d1450513          	addi	a0,a0,-748 # 7170 <malloc+0x1f50>
    2464:	509020ef          	jal	ra,516c <printf>
    exit(1);
    2468:	4505                	li	a0,1
    246a:	0c7020ef          	jal	ra,4d30 <exit>
  wait(0);
    246e:	4501                	li	a0,0
    2470:	0c9020ef          	jal	ra,4d38 <wait>
  pid = fork();
    2474:	0b5020ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    2478:	02054263          	bltz	a0,249c <sbrkbugs+0x9e>
  if(pid == 0){
    247c:	e90d                	bnez	a0,24ae <sbrkbugs+0xb0>
    sbrk((10*PGSIZE + 2048) - (uint64)sbrk(0));
    247e:	07f020ef          	jal	ra,4cfc <sbrk>
    2482:	67ad                	lui	a5,0xb
    2484:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x1258>
    2488:	40a7853b          	subw	a0,a5,a0
    248c:	071020ef          	jal	ra,4cfc <sbrk>
    sbrk(-10);
    2490:	5559                	li	a0,-10
    2492:	06b020ef          	jal	ra,4cfc <sbrk>
    exit(0);
    2496:	4501                	li	a0,0
    2498:	099020ef          	jal	ra,4d30 <exit>
    printf("fork failed\n");
    249c:	00005517          	auipc	a0,0x5
    24a0:	cd450513          	addi	a0,a0,-812 # 7170 <malloc+0x1f50>
    24a4:	4c9020ef          	jal	ra,516c <printf>
    exit(1);
    24a8:	4505                	li	a0,1
    24aa:	087020ef          	jal	ra,4d30 <exit>
  wait(0);
    24ae:	4501                	li	a0,0
    24b0:	089020ef          	jal	ra,4d38 <wait>
  exit(0);
    24b4:	4501                	li	a0,0
    24b6:	07b020ef          	jal	ra,4d30 <exit>

00000000000024ba <sbrklast>:
{
    24ba:	7179                	addi	sp,sp,-48
    24bc:	f406                	sd	ra,40(sp)
    24be:	f022                	sd	s0,32(sp)
    24c0:	ec26                	sd	s1,24(sp)
    24c2:	e84a                	sd	s2,16(sp)
    24c4:	e44e                	sd	s3,8(sp)
    24c6:	e052                	sd	s4,0(sp)
    24c8:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    24ca:	4501                	li	a0,0
    24cc:	031020ef          	jal	ra,4cfc <sbrk>
  if((top % PGSIZE) != 0)
    24d0:	03451793          	slli	a5,a0,0x34
    24d4:	ebad                	bnez	a5,2546 <sbrklast+0x8c>
  sbrk(PGSIZE);
    24d6:	6505                	lui	a0,0x1
    24d8:	025020ef          	jal	ra,4cfc <sbrk>
  sbrk(10);
    24dc:	4529                	li	a0,10
    24de:	01f020ef          	jal	ra,4cfc <sbrk>
  sbrk(-20);
    24e2:	5531                	li	a0,-20
    24e4:	019020ef          	jal	ra,4cfc <sbrk>
  top = (uint64) sbrk(0);
    24e8:	4501                	li	a0,0
    24ea:	013020ef          	jal	ra,4cfc <sbrk>
    24ee:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    24f0:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0x122>
  p[0] = 'x';
    24f4:	07800a13          	li	s4,120
    24f8:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    24fc:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2500:	20200593          	li	a1,514
    2504:	854a                	mv	a0,s2
    2506:	06b020ef          	jal	ra,4d70 <open>
    250a:	89aa                	mv	s3,a0
  write(fd, p, 1);
    250c:	4605                	li	a2,1
    250e:	85ca                	mv	a1,s2
    2510:	041020ef          	jal	ra,4d50 <write>
  close(fd);
    2514:	854e                	mv	a0,s3
    2516:	043020ef          	jal	ra,4d58 <close>
  fd = open(p, O_RDWR);
    251a:	4589                	li	a1,2
    251c:	854a                	mv	a0,s2
    251e:	053020ef          	jal	ra,4d70 <open>
  p[0] = '\0';
    2522:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2526:	4605                	li	a2,1
    2528:	85ca                	mv	a1,s2
    252a:	01f020ef          	jal	ra,4d48 <read>
  if(p[0] != 'x')
    252e:	fc04c783          	lbu	a5,-64(s1)
    2532:	03479263          	bne	a5,s4,2556 <sbrklast+0x9c>
}
    2536:	70a2                	ld	ra,40(sp)
    2538:	7402                	ld	s0,32(sp)
    253a:	64e2                	ld	s1,24(sp)
    253c:	6942                	ld	s2,16(sp)
    253e:	69a2                	ld	s3,8(sp)
    2540:	6a02                	ld	s4,0(sp)
    2542:	6145                	addi	sp,sp,48
    2544:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2546:	0347d513          	srli	a0,a5,0x34
    254a:	6785                	lui	a5,0x1
    254c:	40a7853b          	subw	a0,a5,a0
    2550:	7ac020ef          	jal	ra,4cfc <sbrk>
    2554:	b749                	j	24d6 <sbrklast+0x1c>
    exit(1);
    2556:	4505                	li	a0,1
    2558:	7d8020ef          	jal	ra,4d30 <exit>

000000000000255c <sbrk8000>:
{
    255c:	1141                	addi	sp,sp,-16
    255e:	e406                	sd	ra,8(sp)
    2560:	e022                	sd	s0,0(sp)
    2562:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2564:	80000537          	lui	a0,0x80000
    2568:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff134c>
    256a:	792020ef          	jal	ra,4cfc <sbrk>
  volatile char *top = sbrk(0);
    256e:	4501                	li	a0,0
    2570:	78c020ef          	jal	ra,4cfc <sbrk>
  *(top-1) = *(top-1) + 1;
    2574:	fff54783          	lbu	a5,-1(a0)
    2578:	2785                	addiw	a5,a5,1 # 1001 <badarg+0x1>
    257a:	0ff7f793          	zext.b	a5,a5
    257e:	fef50fa3          	sb	a5,-1(a0)
}
    2582:	60a2                	ld	ra,8(sp)
    2584:	6402                	ld	s0,0(sp)
    2586:	0141                	addi	sp,sp,16
    2588:	8082                	ret

000000000000258a <execout>:
{
    258a:	715d                	addi	sp,sp,-80
    258c:	e486                	sd	ra,72(sp)
    258e:	e0a2                	sd	s0,64(sp)
    2590:	fc26                	sd	s1,56(sp)
    2592:	f84a                	sd	s2,48(sp)
    2594:	f44e                	sd	s3,40(sp)
    2596:	f052                	sd	s4,32(sp)
    2598:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    259a:	4901                	li	s2,0
    259c:	49bd                	li	s3,15
    int pid = fork();
    259e:	78a020ef          	jal	ra,4d28 <fork>
    25a2:	84aa                	mv	s1,a0
    if(pid < 0){
    25a4:	00054c63          	bltz	a0,25bc <execout+0x32>
    } else if(pid == 0){
    25a8:	c11d                	beqz	a0,25ce <execout+0x44>
      wait((int*)0);
    25aa:	4501                	li	a0,0
    25ac:	78c020ef          	jal	ra,4d38 <wait>
  for(int avail = 0; avail < 15; avail++){
    25b0:	2905                	addiw	s2,s2,1
    25b2:	ff3916e3          	bne	s2,s3,259e <execout+0x14>
  exit(0);
    25b6:	4501                	li	a0,0
    25b8:	778020ef          	jal	ra,4d30 <exit>
      printf("fork failed\n");
    25bc:	00005517          	auipc	a0,0x5
    25c0:	bb450513          	addi	a0,a0,-1100 # 7170 <malloc+0x1f50>
    25c4:	3a9020ef          	jal	ra,516c <printf>
      exit(1);
    25c8:	4505                	li	a0,1
    25ca:	766020ef          	jal	ra,4d30 <exit>
        if(a == SBRK_ERROR)
    25ce:	59fd                	li	s3,-1
        *(a + PGSIZE - 1) = 1;
    25d0:	4a05                	li	s4,1
        char *a = sbrk(PGSIZE);
    25d2:	6505                	lui	a0,0x1
    25d4:	728020ef          	jal	ra,4cfc <sbrk>
        if(a == SBRK_ERROR)
    25d8:	01350763          	beq	a0,s3,25e6 <execout+0x5c>
        *(a + PGSIZE - 1) = 1;
    25dc:	6785                	lui	a5,0x1
    25de:	953e                	add	a0,a0,a5
    25e0:	ff450fa3          	sb	s4,-1(a0) # fff <pgbug+0x2b>
      while(1){
    25e4:	b7fd                	j	25d2 <execout+0x48>
      for(int i = 0; i < avail; i++)
    25e6:	01205863          	blez	s2,25f6 <execout+0x6c>
        sbrk(-PGSIZE);
    25ea:	757d                	lui	a0,0xfffff
    25ec:	710020ef          	jal	ra,4cfc <sbrk>
      for(int i = 0; i < avail; i++)
    25f0:	2485                	addiw	s1,s1,1
    25f2:	ff249ce3          	bne	s1,s2,25ea <execout+0x60>
      close(1);
    25f6:	4505                	li	a0,1
    25f8:	760020ef          	jal	ra,4d58 <close>
      char *args[] = { "echo", "x", 0 };
    25fc:	00003517          	auipc	a0,0x3
    2600:	d3c50513          	addi	a0,a0,-708 # 5338 <malloc+0x118>
    2604:	faa43c23          	sd	a0,-72(s0)
    2608:	00003797          	auipc	a5,0x3
    260c:	da078793          	addi	a5,a5,-608 # 53a8 <malloc+0x188>
    2610:	fcf43023          	sd	a5,-64(s0)
    2614:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2618:	fb840593          	addi	a1,s0,-72
    261c:	74c020ef          	jal	ra,4d68 <exec>
      exit(0);
    2620:	4501                	li	a0,0
    2622:	70e020ef          	jal	ra,4d30 <exit>

0000000000002626 <fourteen>:
{
    2626:	1101                	addi	sp,sp,-32
    2628:	ec06                	sd	ra,24(sp)
    262a:	e822                	sd	s0,16(sp)
    262c:	e426                	sd	s1,8(sp)
    262e:	1000                	addi	s0,sp,32
    2630:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2632:	00004517          	auipc	a0,0x4
    2636:	d9e50513          	addi	a0,a0,-610 # 63d0 <malloc+0x11b0>
    263a:	75e020ef          	jal	ra,4d98 <mkdir>
    263e:	e555                	bnez	a0,26ea <fourteen+0xc4>
  if(mkdir("12345678901234/123456789012345") != 0){
    2640:	00004517          	auipc	a0,0x4
    2644:	be850513          	addi	a0,a0,-1048 # 6228 <malloc+0x1008>
    2648:	750020ef          	jal	ra,4d98 <mkdir>
    264c:	e94d                	bnez	a0,26fe <fourteen+0xd8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    264e:	20000593          	li	a1,512
    2652:	00004517          	auipc	a0,0x4
    2656:	c2e50513          	addi	a0,a0,-978 # 6280 <malloc+0x1060>
    265a:	716020ef          	jal	ra,4d70 <open>
  if(fd < 0){
    265e:	0a054a63          	bltz	a0,2712 <fourteen+0xec>
  close(fd);
    2662:	6f6020ef          	jal	ra,4d58 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2666:	4581                	li	a1,0
    2668:	00004517          	auipc	a0,0x4
    266c:	c9050513          	addi	a0,a0,-880 # 62f8 <malloc+0x10d8>
    2670:	700020ef          	jal	ra,4d70 <open>
  if(fd < 0){
    2674:	0a054963          	bltz	a0,2726 <fourteen+0x100>
  close(fd);
    2678:	6e0020ef          	jal	ra,4d58 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    267c:	00004517          	auipc	a0,0x4
    2680:	cec50513          	addi	a0,a0,-788 # 6368 <malloc+0x1148>
    2684:	714020ef          	jal	ra,4d98 <mkdir>
    2688:	c94d                	beqz	a0,273a <fourteen+0x114>
  if(mkdir("123456789012345/12345678901234") == 0){
    268a:	00004517          	auipc	a0,0x4
    268e:	d3650513          	addi	a0,a0,-714 # 63c0 <malloc+0x11a0>
    2692:	706020ef          	jal	ra,4d98 <mkdir>
    2696:	cd45                	beqz	a0,274e <fourteen+0x128>
  unlink("123456789012345/12345678901234");
    2698:	00004517          	auipc	a0,0x4
    269c:	d2850513          	addi	a0,a0,-728 # 63c0 <malloc+0x11a0>
    26a0:	6e0020ef          	jal	ra,4d80 <unlink>
  unlink("12345678901234/12345678901234");
    26a4:	00004517          	auipc	a0,0x4
    26a8:	cc450513          	addi	a0,a0,-828 # 6368 <malloc+0x1148>
    26ac:	6d4020ef          	jal	ra,4d80 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    26b0:	00004517          	auipc	a0,0x4
    26b4:	c4850513          	addi	a0,a0,-952 # 62f8 <malloc+0x10d8>
    26b8:	6c8020ef          	jal	ra,4d80 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    26bc:	00004517          	auipc	a0,0x4
    26c0:	bc450513          	addi	a0,a0,-1084 # 6280 <malloc+0x1060>
    26c4:	6bc020ef          	jal	ra,4d80 <unlink>
  unlink("12345678901234/123456789012345");
    26c8:	00004517          	auipc	a0,0x4
    26cc:	b6050513          	addi	a0,a0,-1184 # 6228 <malloc+0x1008>
    26d0:	6b0020ef          	jal	ra,4d80 <unlink>
  unlink("12345678901234");
    26d4:	00004517          	auipc	a0,0x4
    26d8:	cfc50513          	addi	a0,a0,-772 # 63d0 <malloc+0x11b0>
    26dc:	6a4020ef          	jal	ra,4d80 <unlink>
}
    26e0:	60e2                	ld	ra,24(sp)
    26e2:	6442                	ld	s0,16(sp)
    26e4:	64a2                	ld	s1,8(sp)
    26e6:	6105                	addi	sp,sp,32
    26e8:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    26ea:	85a6                	mv	a1,s1
    26ec:	00004517          	auipc	a0,0x4
    26f0:	b1450513          	addi	a0,a0,-1260 # 6200 <malloc+0xfe0>
    26f4:	279020ef          	jal	ra,516c <printf>
    exit(1);
    26f8:	4505                	li	a0,1
    26fa:	636020ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    26fe:	85a6                	mv	a1,s1
    2700:	00004517          	auipc	a0,0x4
    2704:	b4850513          	addi	a0,a0,-1208 # 6248 <malloc+0x1028>
    2708:	265020ef          	jal	ra,516c <printf>
    exit(1);
    270c:	4505                	li	a0,1
    270e:	622020ef          	jal	ra,4d30 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2712:	85a6                	mv	a1,s1
    2714:	00004517          	auipc	a0,0x4
    2718:	b9c50513          	addi	a0,a0,-1124 # 62b0 <malloc+0x1090>
    271c:	251020ef          	jal	ra,516c <printf>
    exit(1);
    2720:	4505                	li	a0,1
    2722:	60e020ef          	jal	ra,4d30 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2726:	85a6                	mv	a1,s1
    2728:	00004517          	auipc	a0,0x4
    272c:	c0050513          	addi	a0,a0,-1024 # 6328 <malloc+0x1108>
    2730:	23d020ef          	jal	ra,516c <printf>
    exit(1);
    2734:	4505                	li	a0,1
    2736:	5fa020ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    273a:	85a6                	mv	a1,s1
    273c:	00004517          	auipc	a0,0x4
    2740:	c4c50513          	addi	a0,a0,-948 # 6388 <malloc+0x1168>
    2744:	229020ef          	jal	ra,516c <printf>
    exit(1);
    2748:	4505                	li	a0,1
    274a:	5e6020ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    274e:	85a6                	mv	a1,s1
    2750:	00004517          	auipc	a0,0x4
    2754:	c9050513          	addi	a0,a0,-880 # 63e0 <malloc+0x11c0>
    2758:	215020ef          	jal	ra,516c <printf>
    exit(1);
    275c:	4505                	li	a0,1
    275e:	5d2020ef          	jal	ra,4d30 <exit>

0000000000002762 <diskfull>:
{
    2762:	b8010113          	addi	sp,sp,-1152
    2766:	46113c23          	sd	ra,1144(sp)
    276a:	46813823          	sd	s0,1136(sp)
    276e:	46913423          	sd	s1,1128(sp)
    2772:	47213023          	sd	s2,1120(sp)
    2776:	45313c23          	sd	s3,1112(sp)
    277a:	45413823          	sd	s4,1104(sp)
    277e:	45513423          	sd	s5,1096(sp)
    2782:	45613023          	sd	s6,1088(sp)
    2786:	43713c23          	sd	s7,1080(sp)
    278a:	43813823          	sd	s8,1072(sp)
    278e:	43913423          	sd	s9,1064(sp)
    2792:	48010413          	addi	s0,sp,1152
    2796:	8caa                	mv	s9,a0
  unlink("diskfulldir");
    2798:	00004517          	auipc	a0,0x4
    279c:	c8050513          	addi	a0,a0,-896 # 6418 <malloc+0x11f8>
    27a0:	5e0020ef          	jal	ra,4d80 <unlink>
    27a4:	03000993          	li	s3,48
    name[0] = 'b';
    27a8:	06200b13          	li	s6,98
    name[1] = 'i';
    27ac:	06900a93          	li	s5,105
    name[2] = 'g';
    27b0:	06700a13          	li	s4,103
    27b4:	10c00b93          	li	s7,268
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    27b8:	07f00c13          	li	s8,127
    27bc:	aab9                	j	291a <diskfull+0x1b8>
      printf("%s: could not create file %s\n", s, name);
    27be:	b8040613          	addi	a2,s0,-1152
    27c2:	85e6                	mv	a1,s9
    27c4:	00004517          	auipc	a0,0x4
    27c8:	c6450513          	addi	a0,a0,-924 # 6428 <malloc+0x1208>
    27cc:	1a1020ef          	jal	ra,516c <printf>
      break;
    27d0:	a039                	j	27de <diskfull+0x7c>
        close(fd);
    27d2:	854a                	mv	a0,s2
    27d4:	584020ef          	jal	ra,4d58 <close>
    close(fd);
    27d8:	854a                	mv	a0,s2
    27da:	57e020ef          	jal	ra,4d58 <close>
  for(int i = 0; i < nzz; i++){
    27de:	4481                	li	s1,0
    name[0] = 'z';
    27e0:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    27e4:	08000993          	li	s3,128
    name[0] = 'z';
    27e8:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    27ec:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    27f0:	41f4d71b          	sraiw	a4,s1,0x1f
    27f4:	01b7571b          	srliw	a4,a4,0x1b
    27f8:	009707bb          	addw	a5,a4,s1
    27fc:	4057d69b          	sraiw	a3,a5,0x5
    2800:	0306869b          	addiw	a3,a3,48
    2804:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    2808:	8bfd                	andi	a5,a5,31
    280a:	9f99                	subw	a5,a5,a4
    280c:	0307879b          	addiw	a5,a5,48
    2810:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    2814:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    2818:	ba040513          	addi	a0,s0,-1120
    281c:	564020ef          	jal	ra,4d80 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2820:	60200593          	li	a1,1538
    2824:	ba040513          	addi	a0,s0,-1120
    2828:	548020ef          	jal	ra,4d70 <open>
    if(fd < 0)
    282c:	00054763          	bltz	a0,283a <diskfull+0xd8>
    close(fd);
    2830:	528020ef          	jal	ra,4d58 <close>
  for(int i = 0; i < nzz; i++){
    2834:	2485                	addiw	s1,s1,1
    2836:	fb3499e3          	bne	s1,s3,27e8 <diskfull+0x86>
  if(mkdir("diskfulldir") == 0)
    283a:	00004517          	auipc	a0,0x4
    283e:	bde50513          	addi	a0,a0,-1058 # 6418 <malloc+0x11f8>
    2842:	556020ef          	jal	ra,4d98 <mkdir>
    2846:	12050063          	beqz	a0,2966 <diskfull+0x204>
  unlink("diskfulldir");
    284a:	00004517          	auipc	a0,0x4
    284e:	bce50513          	addi	a0,a0,-1074 # 6418 <malloc+0x11f8>
    2852:	52e020ef          	jal	ra,4d80 <unlink>
  for(int i = 0; i < nzz; i++){
    2856:	4481                	li	s1,0
    name[0] = 'z';
    2858:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    285c:	08000993          	li	s3,128
    name[0] = 'z';
    2860:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    2864:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    2868:	41f4d71b          	sraiw	a4,s1,0x1f
    286c:	01b7571b          	srliw	a4,a4,0x1b
    2870:	009707bb          	addw	a5,a4,s1
    2874:	4057d69b          	sraiw	a3,a5,0x5
    2878:	0306869b          	addiw	a3,a3,48
    287c:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    2880:	8bfd                	andi	a5,a5,31
    2882:	9f99                	subw	a5,a5,a4
    2884:	0307879b          	addiw	a5,a5,48
    2888:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    288c:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    2890:	ba040513          	addi	a0,s0,-1120
    2894:	4ec020ef          	jal	ra,4d80 <unlink>
  for(int i = 0; i < nzz; i++){
    2898:	2485                	addiw	s1,s1,1
    289a:	fd3493e3          	bne	s1,s3,2860 <diskfull+0xfe>
    289e:	03000493          	li	s1,48
    name[0] = 'b';
    28a2:	06200a93          	li	s5,98
    name[1] = 'i';
    28a6:	06900a13          	li	s4,105
    name[2] = 'g';
    28aa:	06700993          	li	s3,103
  for(int i = 0; '0' + i < 0177; i++){
    28ae:	07f00913          	li	s2,127
    name[0] = 'b';
    28b2:	bb540023          	sb	s5,-1120(s0)
    name[1] = 'i';
    28b6:	bb4400a3          	sb	s4,-1119(s0)
    name[2] = 'g';
    28ba:	bb340123          	sb	s3,-1118(s0)
    name[3] = '0' + i;
    28be:	ba9401a3          	sb	s1,-1117(s0)
    name[4] = '\0';
    28c2:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    28c6:	ba040513          	addi	a0,s0,-1120
    28ca:	4b6020ef          	jal	ra,4d80 <unlink>
  for(int i = 0; '0' + i < 0177; i++){
    28ce:	2485                	addiw	s1,s1,1
    28d0:	0ff4f493          	zext.b	s1,s1
    28d4:	fd249fe3          	bne	s1,s2,28b2 <diskfull+0x150>
}
    28d8:	47813083          	ld	ra,1144(sp)
    28dc:	47013403          	ld	s0,1136(sp)
    28e0:	46813483          	ld	s1,1128(sp)
    28e4:	46013903          	ld	s2,1120(sp)
    28e8:	45813983          	ld	s3,1112(sp)
    28ec:	45013a03          	ld	s4,1104(sp)
    28f0:	44813a83          	ld	s5,1096(sp)
    28f4:	44013b03          	ld	s6,1088(sp)
    28f8:	43813b83          	ld	s7,1080(sp)
    28fc:	43013c03          	ld	s8,1072(sp)
    2900:	42813c83          	ld	s9,1064(sp)
    2904:	48010113          	addi	sp,sp,1152
    2908:	8082                	ret
    close(fd);
    290a:	854a                	mv	a0,s2
    290c:	44c020ef          	jal	ra,4d58 <close>
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    2910:	2985                	addiw	s3,s3,1
    2912:	0ff9f993          	zext.b	s3,s3
    2916:	ed8984e3          	beq	s3,s8,27de <diskfull+0x7c>
    name[0] = 'b';
    291a:	b9640023          	sb	s6,-1152(s0)
    name[1] = 'i';
    291e:	b95400a3          	sb	s5,-1151(s0)
    name[2] = 'g';
    2922:	b9440123          	sb	s4,-1150(s0)
    name[3] = '0' + fi;
    2926:	b93401a3          	sb	s3,-1149(s0)
    name[4] = '\0';
    292a:	b8040223          	sb	zero,-1148(s0)
    unlink(name);
    292e:	b8040513          	addi	a0,s0,-1152
    2932:	44e020ef          	jal	ra,4d80 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2936:	60200593          	li	a1,1538
    293a:	b8040513          	addi	a0,s0,-1152
    293e:	432020ef          	jal	ra,4d70 <open>
    2942:	892a                	mv	s2,a0
    if(fd < 0){
    2944:	e6054de3          	bltz	a0,27be <diskfull+0x5c>
    2948:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    294a:	40000613          	li	a2,1024
    294e:	ba040593          	addi	a1,s0,-1120
    2952:	854a                	mv	a0,s2
    2954:	3fc020ef          	jal	ra,4d50 <write>
    2958:	40000793          	li	a5,1024
    295c:	e6f51be3          	bne	a0,a5,27d2 <diskfull+0x70>
    for(int i = 0; i < MAXFILE; i++){
    2960:	34fd                	addiw	s1,s1,-1
    2962:	f4e5                	bnez	s1,294a <diskfull+0x1e8>
    2964:	b75d                	j	290a <diskfull+0x1a8>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    2966:	85e6                	mv	a1,s9
    2968:	00004517          	auipc	a0,0x4
    296c:	ae050513          	addi	a0,a0,-1312 # 6448 <malloc+0x1228>
    2970:	7fc020ef          	jal	ra,516c <printf>
    2974:	bdd9                	j	284a <diskfull+0xe8>

0000000000002976 <iputtest>:
{
    2976:	1101                	addi	sp,sp,-32
    2978:	ec06                	sd	ra,24(sp)
    297a:	e822                	sd	s0,16(sp)
    297c:	e426                	sd	s1,8(sp)
    297e:	1000                	addi	s0,sp,32
    2980:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2982:	00004517          	auipc	a0,0x4
    2986:	af650513          	addi	a0,a0,-1290 # 6478 <malloc+0x1258>
    298a:	40e020ef          	jal	ra,4d98 <mkdir>
    298e:	02054f63          	bltz	a0,29cc <iputtest+0x56>
  if(chdir("iputdir") < 0){
    2992:	00004517          	auipc	a0,0x4
    2996:	ae650513          	addi	a0,a0,-1306 # 6478 <malloc+0x1258>
    299a:	406020ef          	jal	ra,4da0 <chdir>
    299e:	04054163          	bltz	a0,29e0 <iputtest+0x6a>
  if(unlink("../iputdir") < 0){
    29a2:	00004517          	auipc	a0,0x4
    29a6:	b1650513          	addi	a0,a0,-1258 # 64b8 <malloc+0x1298>
    29aa:	3d6020ef          	jal	ra,4d80 <unlink>
    29ae:	04054363          	bltz	a0,29f4 <iputtest+0x7e>
  if(chdir("/") < 0){
    29b2:	00004517          	auipc	a0,0x4
    29b6:	b3650513          	addi	a0,a0,-1226 # 64e8 <malloc+0x12c8>
    29ba:	3e6020ef          	jal	ra,4da0 <chdir>
    29be:	04054563          	bltz	a0,2a08 <iputtest+0x92>
}
    29c2:	60e2                	ld	ra,24(sp)
    29c4:	6442                	ld	s0,16(sp)
    29c6:	64a2                	ld	s1,8(sp)
    29c8:	6105                	addi	sp,sp,32
    29ca:	8082                	ret
    printf("%s: mkdir failed\n", s);
    29cc:	85a6                	mv	a1,s1
    29ce:	00004517          	auipc	a0,0x4
    29d2:	ab250513          	addi	a0,a0,-1358 # 6480 <malloc+0x1260>
    29d6:	796020ef          	jal	ra,516c <printf>
    exit(1);
    29da:	4505                	li	a0,1
    29dc:	354020ef          	jal	ra,4d30 <exit>
    printf("%s: chdir iputdir failed\n", s);
    29e0:	85a6                	mv	a1,s1
    29e2:	00004517          	auipc	a0,0x4
    29e6:	ab650513          	addi	a0,a0,-1354 # 6498 <malloc+0x1278>
    29ea:	782020ef          	jal	ra,516c <printf>
    exit(1);
    29ee:	4505                	li	a0,1
    29f0:	340020ef          	jal	ra,4d30 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    29f4:	85a6                	mv	a1,s1
    29f6:	00004517          	auipc	a0,0x4
    29fa:	ad250513          	addi	a0,a0,-1326 # 64c8 <malloc+0x12a8>
    29fe:	76e020ef          	jal	ra,516c <printf>
    exit(1);
    2a02:	4505                	li	a0,1
    2a04:	32c020ef          	jal	ra,4d30 <exit>
    printf("%s: chdir / failed\n", s);
    2a08:	85a6                	mv	a1,s1
    2a0a:	00004517          	auipc	a0,0x4
    2a0e:	ae650513          	addi	a0,a0,-1306 # 64f0 <malloc+0x12d0>
    2a12:	75a020ef          	jal	ra,516c <printf>
    exit(1);
    2a16:	4505                	li	a0,1
    2a18:	318020ef          	jal	ra,4d30 <exit>

0000000000002a1c <exitiputtest>:
{
    2a1c:	7179                	addi	sp,sp,-48
    2a1e:	f406                	sd	ra,40(sp)
    2a20:	f022                	sd	s0,32(sp)
    2a22:	ec26                	sd	s1,24(sp)
    2a24:	1800                	addi	s0,sp,48
    2a26:	84aa                	mv	s1,a0
  pid = fork();
    2a28:	300020ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    2a2c:	02054e63          	bltz	a0,2a68 <exitiputtest+0x4c>
  if(pid == 0){
    2a30:	e541                	bnez	a0,2ab8 <exitiputtest+0x9c>
    if(mkdir("iputdir") < 0){
    2a32:	00004517          	auipc	a0,0x4
    2a36:	a4650513          	addi	a0,a0,-1466 # 6478 <malloc+0x1258>
    2a3a:	35e020ef          	jal	ra,4d98 <mkdir>
    2a3e:	02054f63          	bltz	a0,2a7c <exitiputtest+0x60>
    if(chdir("iputdir") < 0){
    2a42:	00004517          	auipc	a0,0x4
    2a46:	a3650513          	addi	a0,a0,-1482 # 6478 <malloc+0x1258>
    2a4a:	356020ef          	jal	ra,4da0 <chdir>
    2a4e:	04054163          	bltz	a0,2a90 <exitiputtest+0x74>
    if(unlink("../iputdir") < 0){
    2a52:	00004517          	auipc	a0,0x4
    2a56:	a6650513          	addi	a0,a0,-1434 # 64b8 <malloc+0x1298>
    2a5a:	326020ef          	jal	ra,4d80 <unlink>
    2a5e:	04054363          	bltz	a0,2aa4 <exitiputtest+0x88>
    exit(0);
    2a62:	4501                	li	a0,0
    2a64:	2cc020ef          	jal	ra,4d30 <exit>
    printf("%s: fork failed\n", s);
    2a68:	85a6                	mv	a1,s1
    2a6a:	00003517          	auipc	a0,0x3
    2a6e:	15e50513          	addi	a0,a0,350 # 5bc8 <malloc+0x9a8>
    2a72:	6fa020ef          	jal	ra,516c <printf>
    exit(1);
    2a76:	4505                	li	a0,1
    2a78:	2b8020ef          	jal	ra,4d30 <exit>
      printf("%s: mkdir failed\n", s);
    2a7c:	85a6                	mv	a1,s1
    2a7e:	00004517          	auipc	a0,0x4
    2a82:	a0250513          	addi	a0,a0,-1534 # 6480 <malloc+0x1260>
    2a86:	6e6020ef          	jal	ra,516c <printf>
      exit(1);
    2a8a:	4505                	li	a0,1
    2a8c:	2a4020ef          	jal	ra,4d30 <exit>
      printf("%s: child chdir failed\n", s);
    2a90:	85a6                	mv	a1,s1
    2a92:	00004517          	auipc	a0,0x4
    2a96:	a7650513          	addi	a0,a0,-1418 # 6508 <malloc+0x12e8>
    2a9a:	6d2020ef          	jal	ra,516c <printf>
      exit(1);
    2a9e:	4505                	li	a0,1
    2aa0:	290020ef          	jal	ra,4d30 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2aa4:	85a6                	mv	a1,s1
    2aa6:	00004517          	auipc	a0,0x4
    2aaa:	a2250513          	addi	a0,a0,-1502 # 64c8 <malloc+0x12a8>
    2aae:	6be020ef          	jal	ra,516c <printf>
      exit(1);
    2ab2:	4505                	li	a0,1
    2ab4:	27c020ef          	jal	ra,4d30 <exit>
  wait(&xstatus);
    2ab8:	fdc40513          	addi	a0,s0,-36
    2abc:	27c020ef          	jal	ra,4d38 <wait>
  exit(xstatus);
    2ac0:	fdc42503          	lw	a0,-36(s0)
    2ac4:	26c020ef          	jal	ra,4d30 <exit>

0000000000002ac8 <dirtest>:
{
    2ac8:	1101                	addi	sp,sp,-32
    2aca:	ec06                	sd	ra,24(sp)
    2acc:	e822                	sd	s0,16(sp)
    2ace:	e426                	sd	s1,8(sp)
    2ad0:	1000                	addi	s0,sp,32
    2ad2:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2ad4:	00004517          	auipc	a0,0x4
    2ad8:	a4c50513          	addi	a0,a0,-1460 # 6520 <malloc+0x1300>
    2adc:	2bc020ef          	jal	ra,4d98 <mkdir>
    2ae0:	02054f63          	bltz	a0,2b1e <dirtest+0x56>
  if(chdir("dir0") < 0){
    2ae4:	00004517          	auipc	a0,0x4
    2ae8:	a3c50513          	addi	a0,a0,-1476 # 6520 <malloc+0x1300>
    2aec:	2b4020ef          	jal	ra,4da0 <chdir>
    2af0:	04054163          	bltz	a0,2b32 <dirtest+0x6a>
  if(chdir("..") < 0){
    2af4:	00004517          	auipc	a0,0x4
    2af8:	a4c50513          	addi	a0,a0,-1460 # 6540 <malloc+0x1320>
    2afc:	2a4020ef          	jal	ra,4da0 <chdir>
    2b00:	04054363          	bltz	a0,2b46 <dirtest+0x7e>
  if(unlink("dir0") < 0){
    2b04:	00004517          	auipc	a0,0x4
    2b08:	a1c50513          	addi	a0,a0,-1508 # 6520 <malloc+0x1300>
    2b0c:	274020ef          	jal	ra,4d80 <unlink>
    2b10:	04054563          	bltz	a0,2b5a <dirtest+0x92>
}
    2b14:	60e2                	ld	ra,24(sp)
    2b16:	6442                	ld	s0,16(sp)
    2b18:	64a2                	ld	s1,8(sp)
    2b1a:	6105                	addi	sp,sp,32
    2b1c:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2b1e:	85a6                	mv	a1,s1
    2b20:	00004517          	auipc	a0,0x4
    2b24:	96050513          	addi	a0,a0,-1696 # 6480 <malloc+0x1260>
    2b28:	644020ef          	jal	ra,516c <printf>
    exit(1);
    2b2c:	4505                	li	a0,1
    2b2e:	202020ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2b32:	85a6                	mv	a1,s1
    2b34:	00004517          	auipc	a0,0x4
    2b38:	9f450513          	addi	a0,a0,-1548 # 6528 <malloc+0x1308>
    2b3c:	630020ef          	jal	ra,516c <printf>
    exit(1);
    2b40:	4505                	li	a0,1
    2b42:	1ee020ef          	jal	ra,4d30 <exit>
    printf("%s: chdir .. failed\n", s);
    2b46:	85a6                	mv	a1,s1
    2b48:	00004517          	auipc	a0,0x4
    2b4c:	a0050513          	addi	a0,a0,-1536 # 6548 <malloc+0x1328>
    2b50:	61c020ef          	jal	ra,516c <printf>
    exit(1);
    2b54:	4505                	li	a0,1
    2b56:	1da020ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2b5a:	85a6                	mv	a1,s1
    2b5c:	00004517          	auipc	a0,0x4
    2b60:	a0450513          	addi	a0,a0,-1532 # 6560 <malloc+0x1340>
    2b64:	608020ef          	jal	ra,516c <printf>
    exit(1);
    2b68:	4505                	li	a0,1
    2b6a:	1c6020ef          	jal	ra,4d30 <exit>

0000000000002b6e <subdir>:
{
    2b6e:	1101                	addi	sp,sp,-32
    2b70:	ec06                	sd	ra,24(sp)
    2b72:	e822                	sd	s0,16(sp)
    2b74:	e426                	sd	s1,8(sp)
    2b76:	e04a                	sd	s2,0(sp)
    2b78:	1000                	addi	s0,sp,32
    2b7a:	892a                	mv	s2,a0
  unlink("ff");
    2b7c:	00004517          	auipc	a0,0x4
    2b80:	b2c50513          	addi	a0,a0,-1236 # 66a8 <malloc+0x1488>
    2b84:	1fc020ef          	jal	ra,4d80 <unlink>
  if(mkdir("dd") != 0){
    2b88:	00004517          	auipc	a0,0x4
    2b8c:	9f050513          	addi	a0,a0,-1552 # 6578 <malloc+0x1358>
    2b90:	208020ef          	jal	ra,4d98 <mkdir>
    2b94:	2e051263          	bnez	a0,2e78 <subdir+0x30a>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2b98:	20200593          	li	a1,514
    2b9c:	00004517          	auipc	a0,0x4
    2ba0:	9fc50513          	addi	a0,a0,-1540 # 6598 <malloc+0x1378>
    2ba4:	1cc020ef          	jal	ra,4d70 <open>
    2ba8:	84aa                	mv	s1,a0
  if(fd < 0){
    2baa:	2e054163          	bltz	a0,2e8c <subdir+0x31e>
  write(fd, "ff", 2);
    2bae:	4609                	li	a2,2
    2bb0:	00004597          	auipc	a1,0x4
    2bb4:	af858593          	addi	a1,a1,-1288 # 66a8 <malloc+0x1488>
    2bb8:	198020ef          	jal	ra,4d50 <write>
  close(fd);
    2bbc:	8526                	mv	a0,s1
    2bbe:	19a020ef          	jal	ra,4d58 <close>
  if(unlink("dd") >= 0){
    2bc2:	00004517          	auipc	a0,0x4
    2bc6:	9b650513          	addi	a0,a0,-1610 # 6578 <malloc+0x1358>
    2bca:	1b6020ef          	jal	ra,4d80 <unlink>
    2bce:	2c055963          	bgez	a0,2ea0 <subdir+0x332>
  if(mkdir("/dd/dd") != 0){
    2bd2:	00004517          	auipc	a0,0x4
    2bd6:	a1e50513          	addi	a0,a0,-1506 # 65f0 <malloc+0x13d0>
    2bda:	1be020ef          	jal	ra,4d98 <mkdir>
    2bde:	2c051b63          	bnez	a0,2eb4 <subdir+0x346>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2be2:	20200593          	li	a1,514
    2be6:	00004517          	auipc	a0,0x4
    2bea:	a3250513          	addi	a0,a0,-1486 # 6618 <malloc+0x13f8>
    2bee:	182020ef          	jal	ra,4d70 <open>
    2bf2:	84aa                	mv	s1,a0
  if(fd < 0){
    2bf4:	2c054a63          	bltz	a0,2ec8 <subdir+0x35a>
  write(fd, "FF", 2);
    2bf8:	4609                	li	a2,2
    2bfa:	00004597          	auipc	a1,0x4
    2bfe:	a4e58593          	addi	a1,a1,-1458 # 6648 <malloc+0x1428>
    2c02:	14e020ef          	jal	ra,4d50 <write>
  close(fd);
    2c06:	8526                	mv	a0,s1
    2c08:	150020ef          	jal	ra,4d58 <close>
  fd = open("dd/dd/../ff", 0);
    2c0c:	4581                	li	a1,0
    2c0e:	00004517          	auipc	a0,0x4
    2c12:	a4250513          	addi	a0,a0,-1470 # 6650 <malloc+0x1430>
    2c16:	15a020ef          	jal	ra,4d70 <open>
    2c1a:	84aa                	mv	s1,a0
  if(fd < 0){
    2c1c:	2c054063          	bltz	a0,2edc <subdir+0x36e>
  cc = read(fd, buf, sizeof(buf));
    2c20:	660d                	lui	a2,0x3
    2c22:	00009597          	auipc	a1,0x9
    2c26:	09658593          	addi	a1,a1,150 # bcb8 <buf>
    2c2a:	11e020ef          	jal	ra,4d48 <read>
  if(cc != 2 || buf[0] != 'f'){
    2c2e:	4789                	li	a5,2
    2c30:	2cf51063          	bne	a0,a5,2ef0 <subdir+0x382>
    2c34:	00009717          	auipc	a4,0x9
    2c38:	08474703          	lbu	a4,132(a4) # bcb8 <buf>
    2c3c:	06600793          	li	a5,102
    2c40:	2af71863          	bne	a4,a5,2ef0 <subdir+0x382>
  close(fd);
    2c44:	8526                	mv	a0,s1
    2c46:	112020ef          	jal	ra,4d58 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2c4a:	00004597          	auipc	a1,0x4
    2c4e:	a5658593          	addi	a1,a1,-1450 # 66a0 <malloc+0x1480>
    2c52:	00004517          	auipc	a0,0x4
    2c56:	9c650513          	addi	a0,a0,-1594 # 6618 <malloc+0x13f8>
    2c5a:	136020ef          	jal	ra,4d90 <link>
    2c5e:	2a051363          	bnez	a0,2f04 <subdir+0x396>
  if(unlink("dd/dd/ff") != 0){
    2c62:	00004517          	auipc	a0,0x4
    2c66:	9b650513          	addi	a0,a0,-1610 # 6618 <malloc+0x13f8>
    2c6a:	116020ef          	jal	ra,4d80 <unlink>
    2c6e:	2a051563          	bnez	a0,2f18 <subdir+0x3aa>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2c72:	4581                	li	a1,0
    2c74:	00004517          	auipc	a0,0x4
    2c78:	9a450513          	addi	a0,a0,-1628 # 6618 <malloc+0x13f8>
    2c7c:	0f4020ef          	jal	ra,4d70 <open>
    2c80:	2a055663          	bgez	a0,2f2c <subdir+0x3be>
  if(chdir("dd") != 0){
    2c84:	00004517          	auipc	a0,0x4
    2c88:	8f450513          	addi	a0,a0,-1804 # 6578 <malloc+0x1358>
    2c8c:	114020ef          	jal	ra,4da0 <chdir>
    2c90:	2a051863          	bnez	a0,2f40 <subdir+0x3d2>
  if(chdir("dd/../../dd") != 0){
    2c94:	00004517          	auipc	a0,0x4
    2c98:	aa450513          	addi	a0,a0,-1372 # 6738 <malloc+0x1518>
    2c9c:	104020ef          	jal	ra,4da0 <chdir>
    2ca0:	2a051a63          	bnez	a0,2f54 <subdir+0x3e6>
  if(chdir("dd/../../../dd") != 0){
    2ca4:	00004517          	auipc	a0,0x4
    2ca8:	ac450513          	addi	a0,a0,-1340 # 6768 <malloc+0x1548>
    2cac:	0f4020ef          	jal	ra,4da0 <chdir>
    2cb0:	2a051c63          	bnez	a0,2f68 <subdir+0x3fa>
  if(chdir("./..") != 0){
    2cb4:	00004517          	auipc	a0,0x4
    2cb8:	aec50513          	addi	a0,a0,-1300 # 67a0 <malloc+0x1580>
    2cbc:	0e4020ef          	jal	ra,4da0 <chdir>
    2cc0:	2a051e63          	bnez	a0,2f7c <subdir+0x40e>
  fd = open("dd/dd/ffff", 0);
    2cc4:	4581                	li	a1,0
    2cc6:	00004517          	auipc	a0,0x4
    2cca:	9da50513          	addi	a0,a0,-1574 # 66a0 <malloc+0x1480>
    2cce:	0a2020ef          	jal	ra,4d70 <open>
    2cd2:	84aa                	mv	s1,a0
  if(fd < 0){
    2cd4:	2a054e63          	bltz	a0,2f90 <subdir+0x422>
  if(read(fd, buf, sizeof(buf)) != 2){
    2cd8:	660d                	lui	a2,0x3
    2cda:	00009597          	auipc	a1,0x9
    2cde:	fde58593          	addi	a1,a1,-34 # bcb8 <buf>
    2ce2:	066020ef          	jal	ra,4d48 <read>
    2ce6:	4789                	li	a5,2
    2ce8:	2af51e63          	bne	a0,a5,2fa4 <subdir+0x436>
  close(fd);
    2cec:	8526                	mv	a0,s1
    2cee:	06a020ef          	jal	ra,4d58 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2cf2:	4581                	li	a1,0
    2cf4:	00004517          	auipc	a0,0x4
    2cf8:	92450513          	addi	a0,a0,-1756 # 6618 <malloc+0x13f8>
    2cfc:	074020ef          	jal	ra,4d70 <open>
    2d00:	2a055c63          	bgez	a0,2fb8 <subdir+0x44a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2d04:	20200593          	li	a1,514
    2d08:	00004517          	auipc	a0,0x4
    2d0c:	b2850513          	addi	a0,a0,-1240 # 6830 <malloc+0x1610>
    2d10:	060020ef          	jal	ra,4d70 <open>
    2d14:	2a055c63          	bgez	a0,2fcc <subdir+0x45e>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2d18:	20200593          	li	a1,514
    2d1c:	00004517          	auipc	a0,0x4
    2d20:	b4450513          	addi	a0,a0,-1212 # 6860 <malloc+0x1640>
    2d24:	04c020ef          	jal	ra,4d70 <open>
    2d28:	2a055c63          	bgez	a0,2fe0 <subdir+0x472>
  if(open("dd", O_CREATE) >= 0){
    2d2c:	20000593          	li	a1,512
    2d30:	00004517          	auipc	a0,0x4
    2d34:	84850513          	addi	a0,a0,-1976 # 6578 <malloc+0x1358>
    2d38:	038020ef          	jal	ra,4d70 <open>
    2d3c:	2a055c63          	bgez	a0,2ff4 <subdir+0x486>
  if(open("dd", O_RDWR) >= 0){
    2d40:	4589                	li	a1,2
    2d42:	00004517          	auipc	a0,0x4
    2d46:	83650513          	addi	a0,a0,-1994 # 6578 <malloc+0x1358>
    2d4a:	026020ef          	jal	ra,4d70 <open>
    2d4e:	2a055d63          	bgez	a0,3008 <subdir+0x49a>
  if(open("dd", O_WRONLY) >= 0){
    2d52:	4585                	li	a1,1
    2d54:	00004517          	auipc	a0,0x4
    2d58:	82450513          	addi	a0,a0,-2012 # 6578 <malloc+0x1358>
    2d5c:	014020ef          	jal	ra,4d70 <open>
    2d60:	2a055e63          	bgez	a0,301c <subdir+0x4ae>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2d64:	00004597          	auipc	a1,0x4
    2d68:	b8c58593          	addi	a1,a1,-1140 # 68f0 <malloc+0x16d0>
    2d6c:	00004517          	auipc	a0,0x4
    2d70:	ac450513          	addi	a0,a0,-1340 # 6830 <malloc+0x1610>
    2d74:	01c020ef          	jal	ra,4d90 <link>
    2d78:	2a050c63          	beqz	a0,3030 <subdir+0x4c2>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2d7c:	00004597          	auipc	a1,0x4
    2d80:	b7458593          	addi	a1,a1,-1164 # 68f0 <malloc+0x16d0>
    2d84:	00004517          	auipc	a0,0x4
    2d88:	adc50513          	addi	a0,a0,-1316 # 6860 <malloc+0x1640>
    2d8c:	004020ef          	jal	ra,4d90 <link>
    2d90:	2a050a63          	beqz	a0,3044 <subdir+0x4d6>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2d94:	00004597          	auipc	a1,0x4
    2d98:	90c58593          	addi	a1,a1,-1780 # 66a0 <malloc+0x1480>
    2d9c:	00003517          	auipc	a0,0x3
    2da0:	7fc50513          	addi	a0,a0,2044 # 6598 <malloc+0x1378>
    2da4:	7ed010ef          	jal	ra,4d90 <link>
    2da8:	2a050863          	beqz	a0,3058 <subdir+0x4ea>
  if(mkdir("dd/ff/ff") == 0){
    2dac:	00004517          	auipc	a0,0x4
    2db0:	a8450513          	addi	a0,a0,-1404 # 6830 <malloc+0x1610>
    2db4:	7e5010ef          	jal	ra,4d98 <mkdir>
    2db8:	2a050a63          	beqz	a0,306c <subdir+0x4fe>
  if(mkdir("dd/xx/ff") == 0){
    2dbc:	00004517          	auipc	a0,0x4
    2dc0:	aa450513          	addi	a0,a0,-1372 # 6860 <malloc+0x1640>
    2dc4:	7d5010ef          	jal	ra,4d98 <mkdir>
    2dc8:	2a050c63          	beqz	a0,3080 <subdir+0x512>
  if(mkdir("dd/dd/ffff") == 0){
    2dcc:	00004517          	auipc	a0,0x4
    2dd0:	8d450513          	addi	a0,a0,-1836 # 66a0 <malloc+0x1480>
    2dd4:	7c5010ef          	jal	ra,4d98 <mkdir>
    2dd8:	2a050e63          	beqz	a0,3094 <subdir+0x526>
  if(unlink("dd/xx/ff") == 0){
    2ddc:	00004517          	auipc	a0,0x4
    2de0:	a8450513          	addi	a0,a0,-1404 # 6860 <malloc+0x1640>
    2de4:	79d010ef          	jal	ra,4d80 <unlink>
    2de8:	2c050063          	beqz	a0,30a8 <subdir+0x53a>
  if(unlink("dd/ff/ff") == 0){
    2dec:	00004517          	auipc	a0,0x4
    2df0:	a4450513          	addi	a0,a0,-1468 # 6830 <malloc+0x1610>
    2df4:	78d010ef          	jal	ra,4d80 <unlink>
    2df8:	2c050263          	beqz	a0,30bc <subdir+0x54e>
  if(chdir("dd/ff") == 0){
    2dfc:	00003517          	auipc	a0,0x3
    2e00:	79c50513          	addi	a0,a0,1948 # 6598 <malloc+0x1378>
    2e04:	79d010ef          	jal	ra,4da0 <chdir>
    2e08:	2c050463          	beqz	a0,30d0 <subdir+0x562>
  if(chdir("dd/xx") == 0){
    2e0c:	00004517          	auipc	a0,0x4
    2e10:	c3450513          	addi	a0,a0,-972 # 6a40 <malloc+0x1820>
    2e14:	78d010ef          	jal	ra,4da0 <chdir>
    2e18:	2c050663          	beqz	a0,30e4 <subdir+0x576>
  if(unlink("dd/dd/ffff") != 0){
    2e1c:	00004517          	auipc	a0,0x4
    2e20:	88450513          	addi	a0,a0,-1916 # 66a0 <malloc+0x1480>
    2e24:	75d010ef          	jal	ra,4d80 <unlink>
    2e28:	2c051863          	bnez	a0,30f8 <subdir+0x58a>
  if(unlink("dd/ff") != 0){
    2e2c:	00003517          	auipc	a0,0x3
    2e30:	76c50513          	addi	a0,a0,1900 # 6598 <malloc+0x1378>
    2e34:	74d010ef          	jal	ra,4d80 <unlink>
    2e38:	2c051a63          	bnez	a0,310c <subdir+0x59e>
  if(unlink("dd") == 0){
    2e3c:	00003517          	auipc	a0,0x3
    2e40:	73c50513          	addi	a0,a0,1852 # 6578 <malloc+0x1358>
    2e44:	73d010ef          	jal	ra,4d80 <unlink>
    2e48:	2c050c63          	beqz	a0,3120 <subdir+0x5b2>
  if(unlink("dd/dd") < 0){
    2e4c:	00004517          	auipc	a0,0x4
    2e50:	c6450513          	addi	a0,a0,-924 # 6ab0 <malloc+0x1890>
    2e54:	72d010ef          	jal	ra,4d80 <unlink>
    2e58:	2c054e63          	bltz	a0,3134 <subdir+0x5c6>
  if(unlink("dd") < 0){
    2e5c:	00003517          	auipc	a0,0x3
    2e60:	71c50513          	addi	a0,a0,1820 # 6578 <malloc+0x1358>
    2e64:	71d010ef          	jal	ra,4d80 <unlink>
    2e68:	2e054063          	bltz	a0,3148 <subdir+0x5da>
}
    2e6c:	60e2                	ld	ra,24(sp)
    2e6e:	6442                	ld	s0,16(sp)
    2e70:	64a2                	ld	s1,8(sp)
    2e72:	6902                	ld	s2,0(sp)
    2e74:	6105                	addi	sp,sp,32
    2e76:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2e78:	85ca                	mv	a1,s2
    2e7a:	00003517          	auipc	a0,0x3
    2e7e:	70650513          	addi	a0,a0,1798 # 6580 <malloc+0x1360>
    2e82:	2ea020ef          	jal	ra,516c <printf>
    exit(1);
    2e86:	4505                	li	a0,1
    2e88:	6a9010ef          	jal	ra,4d30 <exit>
    printf("%s: create dd/ff failed\n", s);
    2e8c:	85ca                	mv	a1,s2
    2e8e:	00003517          	auipc	a0,0x3
    2e92:	71250513          	addi	a0,a0,1810 # 65a0 <malloc+0x1380>
    2e96:	2d6020ef          	jal	ra,516c <printf>
    exit(1);
    2e9a:	4505                	li	a0,1
    2e9c:	695010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2ea0:	85ca                	mv	a1,s2
    2ea2:	00003517          	auipc	a0,0x3
    2ea6:	71e50513          	addi	a0,a0,1822 # 65c0 <malloc+0x13a0>
    2eaa:	2c2020ef          	jal	ra,516c <printf>
    exit(1);
    2eae:	4505                	li	a0,1
    2eb0:	681010ef          	jal	ra,4d30 <exit>
    printf("%s: subdir mkdir dd/dd failed\n", s);
    2eb4:	85ca                	mv	a1,s2
    2eb6:	00003517          	auipc	a0,0x3
    2eba:	74250513          	addi	a0,a0,1858 # 65f8 <malloc+0x13d8>
    2ebe:	2ae020ef          	jal	ra,516c <printf>
    exit(1);
    2ec2:	4505                	li	a0,1
    2ec4:	66d010ef          	jal	ra,4d30 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2ec8:	85ca                	mv	a1,s2
    2eca:	00003517          	auipc	a0,0x3
    2ece:	75e50513          	addi	a0,a0,1886 # 6628 <malloc+0x1408>
    2ed2:	29a020ef          	jal	ra,516c <printf>
    exit(1);
    2ed6:	4505                	li	a0,1
    2ed8:	659010ef          	jal	ra,4d30 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2edc:	85ca                	mv	a1,s2
    2ede:	00003517          	auipc	a0,0x3
    2ee2:	78250513          	addi	a0,a0,1922 # 6660 <malloc+0x1440>
    2ee6:	286020ef          	jal	ra,516c <printf>
    exit(1);
    2eea:	4505                	li	a0,1
    2eec:	645010ef          	jal	ra,4d30 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2ef0:	85ca                	mv	a1,s2
    2ef2:	00003517          	auipc	a0,0x3
    2ef6:	78e50513          	addi	a0,a0,1934 # 6680 <malloc+0x1460>
    2efa:	272020ef          	jal	ra,516c <printf>
    exit(1);
    2efe:	4505                	li	a0,1
    2f00:	631010ef          	jal	ra,4d30 <exit>
    printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
    2f04:	85ca                	mv	a1,s2
    2f06:	00003517          	auipc	a0,0x3
    2f0a:	7aa50513          	addi	a0,a0,1962 # 66b0 <malloc+0x1490>
    2f0e:	25e020ef          	jal	ra,516c <printf>
    exit(1);
    2f12:	4505                	li	a0,1
    2f14:	61d010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2f18:	85ca                	mv	a1,s2
    2f1a:	00003517          	auipc	a0,0x3
    2f1e:	7be50513          	addi	a0,a0,1982 # 66d8 <malloc+0x14b8>
    2f22:	24a020ef          	jal	ra,516c <printf>
    exit(1);
    2f26:	4505                	li	a0,1
    2f28:	609010ef          	jal	ra,4d30 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2f2c:	85ca                	mv	a1,s2
    2f2e:	00003517          	auipc	a0,0x3
    2f32:	7ca50513          	addi	a0,a0,1994 # 66f8 <malloc+0x14d8>
    2f36:	236020ef          	jal	ra,516c <printf>
    exit(1);
    2f3a:	4505                	li	a0,1
    2f3c:	5f5010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dd failed\n", s);
    2f40:	85ca                	mv	a1,s2
    2f42:	00003517          	auipc	a0,0x3
    2f46:	7de50513          	addi	a0,a0,2014 # 6720 <malloc+0x1500>
    2f4a:	222020ef          	jal	ra,516c <printf>
    exit(1);
    2f4e:	4505                	li	a0,1
    2f50:	5e1010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2f54:	85ca                	mv	a1,s2
    2f56:	00003517          	auipc	a0,0x3
    2f5a:	7f250513          	addi	a0,a0,2034 # 6748 <malloc+0x1528>
    2f5e:	20e020ef          	jal	ra,516c <printf>
    exit(1);
    2f62:	4505                	li	a0,1
    2f64:	5cd010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dd/../../../dd failed\n", s);
    2f68:	85ca                	mv	a1,s2
    2f6a:	00004517          	auipc	a0,0x4
    2f6e:	80e50513          	addi	a0,a0,-2034 # 6778 <malloc+0x1558>
    2f72:	1fa020ef          	jal	ra,516c <printf>
    exit(1);
    2f76:	4505                	li	a0,1
    2f78:	5b9010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir ./.. failed\n", s);
    2f7c:	85ca                	mv	a1,s2
    2f7e:	00004517          	auipc	a0,0x4
    2f82:	82a50513          	addi	a0,a0,-2006 # 67a8 <malloc+0x1588>
    2f86:	1e6020ef          	jal	ra,516c <printf>
    exit(1);
    2f8a:	4505                	li	a0,1
    2f8c:	5a5010ef          	jal	ra,4d30 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2f90:	85ca                	mv	a1,s2
    2f92:	00004517          	auipc	a0,0x4
    2f96:	82e50513          	addi	a0,a0,-2002 # 67c0 <malloc+0x15a0>
    2f9a:	1d2020ef          	jal	ra,516c <printf>
    exit(1);
    2f9e:	4505                	li	a0,1
    2fa0:	591010ef          	jal	ra,4d30 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2fa4:	85ca                	mv	a1,s2
    2fa6:	00004517          	auipc	a0,0x4
    2faa:	83a50513          	addi	a0,a0,-1990 # 67e0 <malloc+0x15c0>
    2fae:	1be020ef          	jal	ra,516c <printf>
    exit(1);
    2fb2:	4505                	li	a0,1
    2fb4:	57d010ef          	jal	ra,4d30 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    2fb8:	85ca                	mv	a1,s2
    2fba:	00004517          	auipc	a0,0x4
    2fbe:	84650513          	addi	a0,a0,-1978 # 6800 <malloc+0x15e0>
    2fc2:	1aa020ef          	jal	ra,516c <printf>
    exit(1);
    2fc6:	4505                	li	a0,1
    2fc8:	569010ef          	jal	ra,4d30 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2fcc:	85ca                	mv	a1,s2
    2fce:	00004517          	auipc	a0,0x4
    2fd2:	87250513          	addi	a0,a0,-1934 # 6840 <malloc+0x1620>
    2fd6:	196020ef          	jal	ra,516c <printf>
    exit(1);
    2fda:	4505                	li	a0,1
    2fdc:	555010ef          	jal	ra,4d30 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2fe0:	85ca                	mv	a1,s2
    2fe2:	00004517          	auipc	a0,0x4
    2fe6:	88e50513          	addi	a0,a0,-1906 # 6870 <malloc+0x1650>
    2fea:	182020ef          	jal	ra,516c <printf>
    exit(1);
    2fee:	4505                	li	a0,1
    2ff0:	541010ef          	jal	ra,4d30 <exit>
    printf("%s: create dd succeeded!\n", s);
    2ff4:	85ca                	mv	a1,s2
    2ff6:	00004517          	auipc	a0,0x4
    2ffa:	89a50513          	addi	a0,a0,-1894 # 6890 <malloc+0x1670>
    2ffe:	16e020ef          	jal	ra,516c <printf>
    exit(1);
    3002:	4505                	li	a0,1
    3004:	52d010ef          	jal	ra,4d30 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3008:	85ca                	mv	a1,s2
    300a:	00004517          	auipc	a0,0x4
    300e:	8a650513          	addi	a0,a0,-1882 # 68b0 <malloc+0x1690>
    3012:	15a020ef          	jal	ra,516c <printf>
    exit(1);
    3016:	4505                	li	a0,1
    3018:	519010ef          	jal	ra,4d30 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    301c:	85ca                	mv	a1,s2
    301e:	00004517          	auipc	a0,0x4
    3022:	8b250513          	addi	a0,a0,-1870 # 68d0 <malloc+0x16b0>
    3026:	146020ef          	jal	ra,516c <printf>
    exit(1);
    302a:	4505                	li	a0,1
    302c:	505010ef          	jal	ra,4d30 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3030:	85ca                	mv	a1,s2
    3032:	00004517          	auipc	a0,0x4
    3036:	8ce50513          	addi	a0,a0,-1842 # 6900 <malloc+0x16e0>
    303a:	132020ef          	jal	ra,516c <printf>
    exit(1);
    303e:	4505                	li	a0,1
    3040:	4f1010ef          	jal	ra,4d30 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3044:	85ca                	mv	a1,s2
    3046:	00004517          	auipc	a0,0x4
    304a:	8e250513          	addi	a0,a0,-1822 # 6928 <malloc+0x1708>
    304e:	11e020ef          	jal	ra,516c <printf>
    exit(1);
    3052:	4505                	li	a0,1
    3054:	4dd010ef          	jal	ra,4d30 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3058:	85ca                	mv	a1,s2
    305a:	00004517          	auipc	a0,0x4
    305e:	8f650513          	addi	a0,a0,-1802 # 6950 <malloc+0x1730>
    3062:	10a020ef          	jal	ra,516c <printf>
    exit(1);
    3066:	4505                	li	a0,1
    3068:	4c9010ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    306c:	85ca                	mv	a1,s2
    306e:	00004517          	auipc	a0,0x4
    3072:	90a50513          	addi	a0,a0,-1782 # 6978 <malloc+0x1758>
    3076:	0f6020ef          	jal	ra,516c <printf>
    exit(1);
    307a:	4505                	li	a0,1
    307c:	4b5010ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3080:	85ca                	mv	a1,s2
    3082:	00004517          	auipc	a0,0x4
    3086:	91650513          	addi	a0,a0,-1770 # 6998 <malloc+0x1778>
    308a:	0e2020ef          	jal	ra,516c <printf>
    exit(1);
    308e:	4505                	li	a0,1
    3090:	4a1010ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3094:	85ca                	mv	a1,s2
    3096:	00004517          	auipc	a0,0x4
    309a:	92250513          	addi	a0,a0,-1758 # 69b8 <malloc+0x1798>
    309e:	0ce020ef          	jal	ra,516c <printf>
    exit(1);
    30a2:	4505                	li	a0,1
    30a4:	48d010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    30a8:	85ca                	mv	a1,s2
    30aa:	00004517          	auipc	a0,0x4
    30ae:	93650513          	addi	a0,a0,-1738 # 69e0 <malloc+0x17c0>
    30b2:	0ba020ef          	jal	ra,516c <printf>
    exit(1);
    30b6:	4505                	li	a0,1
    30b8:	479010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    30bc:	85ca                	mv	a1,s2
    30be:	00004517          	auipc	a0,0x4
    30c2:	94250513          	addi	a0,a0,-1726 # 6a00 <malloc+0x17e0>
    30c6:	0a6020ef          	jal	ra,516c <printf>
    exit(1);
    30ca:	4505                	li	a0,1
    30cc:	465010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    30d0:	85ca                	mv	a1,s2
    30d2:	00004517          	auipc	a0,0x4
    30d6:	94e50513          	addi	a0,a0,-1714 # 6a20 <malloc+0x1800>
    30da:	092020ef          	jal	ra,516c <printf>
    exit(1);
    30de:	4505                	li	a0,1
    30e0:	451010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    30e4:	85ca                	mv	a1,s2
    30e6:	00004517          	auipc	a0,0x4
    30ea:	96250513          	addi	a0,a0,-1694 # 6a48 <malloc+0x1828>
    30ee:	07e020ef          	jal	ra,516c <printf>
    exit(1);
    30f2:	4505                	li	a0,1
    30f4:	43d010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    30f8:	85ca                	mv	a1,s2
    30fa:	00003517          	auipc	a0,0x3
    30fe:	5de50513          	addi	a0,a0,1502 # 66d8 <malloc+0x14b8>
    3102:	06a020ef          	jal	ra,516c <printf>
    exit(1);
    3106:	4505                	li	a0,1
    3108:	429010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    310c:	85ca                	mv	a1,s2
    310e:	00004517          	auipc	a0,0x4
    3112:	95a50513          	addi	a0,a0,-1702 # 6a68 <malloc+0x1848>
    3116:	056020ef          	jal	ra,516c <printf>
    exit(1);
    311a:	4505                	li	a0,1
    311c:	415010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3120:	85ca                	mv	a1,s2
    3122:	00004517          	auipc	a0,0x4
    3126:	96650513          	addi	a0,a0,-1690 # 6a88 <malloc+0x1868>
    312a:	042020ef          	jal	ra,516c <printf>
    exit(1);
    312e:	4505                	li	a0,1
    3130:	401010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3134:	85ca                	mv	a1,s2
    3136:	00004517          	auipc	a0,0x4
    313a:	98250513          	addi	a0,a0,-1662 # 6ab8 <malloc+0x1898>
    313e:	02e020ef          	jal	ra,516c <printf>
    exit(1);
    3142:	4505                	li	a0,1
    3144:	3ed010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dd failed\n", s);
    3148:	85ca                	mv	a1,s2
    314a:	00004517          	auipc	a0,0x4
    314e:	98e50513          	addi	a0,a0,-1650 # 6ad8 <malloc+0x18b8>
    3152:	01a020ef          	jal	ra,516c <printf>
    exit(1);
    3156:	4505                	li	a0,1
    3158:	3d9010ef          	jal	ra,4d30 <exit>

000000000000315c <rmdot>:
{
    315c:	1101                	addi	sp,sp,-32
    315e:	ec06                	sd	ra,24(sp)
    3160:	e822                	sd	s0,16(sp)
    3162:	e426                	sd	s1,8(sp)
    3164:	1000                	addi	s0,sp,32
    3166:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3168:	00004517          	auipc	a0,0x4
    316c:	98850513          	addi	a0,a0,-1656 # 6af0 <malloc+0x18d0>
    3170:	429010ef          	jal	ra,4d98 <mkdir>
    3174:	e53d                	bnez	a0,31e2 <rmdot+0x86>
  if(chdir("dots") != 0){
    3176:	00004517          	auipc	a0,0x4
    317a:	97a50513          	addi	a0,a0,-1670 # 6af0 <malloc+0x18d0>
    317e:	423010ef          	jal	ra,4da0 <chdir>
    3182:	e935                	bnez	a0,31f6 <rmdot+0x9a>
  if(unlink(".") == 0){
    3184:	00003517          	auipc	a0,0x3
    3188:	89c50513          	addi	a0,a0,-1892 # 5a20 <malloc+0x800>
    318c:	3f5010ef          	jal	ra,4d80 <unlink>
    3190:	cd2d                	beqz	a0,320a <rmdot+0xae>
  if(unlink("..") == 0){
    3192:	00003517          	auipc	a0,0x3
    3196:	3ae50513          	addi	a0,a0,942 # 6540 <malloc+0x1320>
    319a:	3e7010ef          	jal	ra,4d80 <unlink>
    319e:	c141                	beqz	a0,321e <rmdot+0xc2>
  if(chdir("/") != 0){
    31a0:	00003517          	auipc	a0,0x3
    31a4:	34850513          	addi	a0,a0,840 # 64e8 <malloc+0x12c8>
    31a8:	3f9010ef          	jal	ra,4da0 <chdir>
    31ac:	e159                	bnez	a0,3232 <rmdot+0xd6>
  if(unlink("dots/.") == 0){
    31ae:	00004517          	auipc	a0,0x4
    31b2:	9aa50513          	addi	a0,a0,-1622 # 6b58 <malloc+0x1938>
    31b6:	3cb010ef          	jal	ra,4d80 <unlink>
    31ba:	c551                	beqz	a0,3246 <rmdot+0xea>
  if(unlink("dots/..") == 0){
    31bc:	00004517          	auipc	a0,0x4
    31c0:	9c450513          	addi	a0,a0,-1596 # 6b80 <malloc+0x1960>
    31c4:	3bd010ef          	jal	ra,4d80 <unlink>
    31c8:	c949                	beqz	a0,325a <rmdot+0xfe>
  if(unlink("dots") != 0){
    31ca:	00004517          	auipc	a0,0x4
    31ce:	92650513          	addi	a0,a0,-1754 # 6af0 <malloc+0x18d0>
    31d2:	3af010ef          	jal	ra,4d80 <unlink>
    31d6:	ed41                	bnez	a0,326e <rmdot+0x112>
}
    31d8:	60e2                	ld	ra,24(sp)
    31da:	6442                	ld	s0,16(sp)
    31dc:	64a2                	ld	s1,8(sp)
    31de:	6105                	addi	sp,sp,32
    31e0:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    31e2:	85a6                	mv	a1,s1
    31e4:	00004517          	auipc	a0,0x4
    31e8:	91450513          	addi	a0,a0,-1772 # 6af8 <malloc+0x18d8>
    31ec:	781010ef          	jal	ra,516c <printf>
    exit(1);
    31f0:	4505                	li	a0,1
    31f2:	33f010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dots failed\n", s);
    31f6:	85a6                	mv	a1,s1
    31f8:	00004517          	auipc	a0,0x4
    31fc:	91850513          	addi	a0,a0,-1768 # 6b10 <malloc+0x18f0>
    3200:	76d010ef          	jal	ra,516c <printf>
    exit(1);
    3204:	4505                	li	a0,1
    3206:	32b010ef          	jal	ra,4d30 <exit>
    printf("%s: rm . worked!\n", s);
    320a:	85a6                	mv	a1,s1
    320c:	00004517          	auipc	a0,0x4
    3210:	91c50513          	addi	a0,a0,-1764 # 6b28 <malloc+0x1908>
    3214:	759010ef          	jal	ra,516c <printf>
    exit(1);
    3218:	4505                	li	a0,1
    321a:	317010ef          	jal	ra,4d30 <exit>
    printf("%s: rm .. worked!\n", s);
    321e:	85a6                	mv	a1,s1
    3220:	00004517          	auipc	a0,0x4
    3224:	92050513          	addi	a0,a0,-1760 # 6b40 <malloc+0x1920>
    3228:	745010ef          	jal	ra,516c <printf>
    exit(1);
    322c:	4505                	li	a0,1
    322e:	303010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir / failed\n", s);
    3232:	85a6                	mv	a1,s1
    3234:	00003517          	auipc	a0,0x3
    3238:	2bc50513          	addi	a0,a0,700 # 64f0 <malloc+0x12d0>
    323c:	731010ef          	jal	ra,516c <printf>
    exit(1);
    3240:	4505                	li	a0,1
    3242:	2ef010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3246:	85a6                	mv	a1,s1
    3248:	00004517          	auipc	a0,0x4
    324c:	91850513          	addi	a0,a0,-1768 # 6b60 <malloc+0x1940>
    3250:	71d010ef          	jal	ra,516c <printf>
    exit(1);
    3254:	4505                	li	a0,1
    3256:	2db010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    325a:	85a6                	mv	a1,s1
    325c:	00004517          	auipc	a0,0x4
    3260:	92c50513          	addi	a0,a0,-1748 # 6b88 <malloc+0x1968>
    3264:	709010ef          	jal	ra,516c <printf>
    exit(1);
    3268:	4505                	li	a0,1
    326a:	2c7010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dots failed!\n", s);
    326e:	85a6                	mv	a1,s1
    3270:	00004517          	auipc	a0,0x4
    3274:	93850513          	addi	a0,a0,-1736 # 6ba8 <malloc+0x1988>
    3278:	6f5010ef          	jal	ra,516c <printf>
    exit(1);
    327c:	4505                	li	a0,1
    327e:	2b3010ef          	jal	ra,4d30 <exit>

0000000000003282 <dirfile>:
{
    3282:	1101                	addi	sp,sp,-32
    3284:	ec06                	sd	ra,24(sp)
    3286:	e822                	sd	s0,16(sp)
    3288:	e426                	sd	s1,8(sp)
    328a:	e04a                	sd	s2,0(sp)
    328c:	1000                	addi	s0,sp,32
    328e:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3290:	20000593          	li	a1,512
    3294:	00004517          	auipc	a0,0x4
    3298:	93450513          	addi	a0,a0,-1740 # 6bc8 <malloc+0x19a8>
    329c:	2d5010ef          	jal	ra,4d70 <open>
  if(fd < 0){
    32a0:	0c054563          	bltz	a0,336a <dirfile+0xe8>
  close(fd);
    32a4:	2b5010ef          	jal	ra,4d58 <close>
  if(chdir("dirfile") == 0){
    32a8:	00004517          	auipc	a0,0x4
    32ac:	92050513          	addi	a0,a0,-1760 # 6bc8 <malloc+0x19a8>
    32b0:	2f1010ef          	jal	ra,4da0 <chdir>
    32b4:	c569                	beqz	a0,337e <dirfile+0xfc>
  fd = open("dirfile/xx", 0);
    32b6:	4581                	li	a1,0
    32b8:	00004517          	auipc	a0,0x4
    32bc:	95850513          	addi	a0,a0,-1704 # 6c10 <malloc+0x19f0>
    32c0:	2b1010ef          	jal	ra,4d70 <open>
  if(fd >= 0){
    32c4:	0c055763          	bgez	a0,3392 <dirfile+0x110>
  fd = open("dirfile/xx", O_CREATE);
    32c8:	20000593          	li	a1,512
    32cc:	00004517          	auipc	a0,0x4
    32d0:	94450513          	addi	a0,a0,-1724 # 6c10 <malloc+0x19f0>
    32d4:	29d010ef          	jal	ra,4d70 <open>
  if(fd >= 0){
    32d8:	0c055763          	bgez	a0,33a6 <dirfile+0x124>
  if(mkdir("dirfile/xx") == 0){
    32dc:	00004517          	auipc	a0,0x4
    32e0:	93450513          	addi	a0,a0,-1740 # 6c10 <malloc+0x19f0>
    32e4:	2b5010ef          	jal	ra,4d98 <mkdir>
    32e8:	0c050963          	beqz	a0,33ba <dirfile+0x138>
  if(unlink("dirfile/xx") == 0){
    32ec:	00004517          	auipc	a0,0x4
    32f0:	92450513          	addi	a0,a0,-1756 # 6c10 <malloc+0x19f0>
    32f4:	28d010ef          	jal	ra,4d80 <unlink>
    32f8:	0c050b63          	beqz	a0,33ce <dirfile+0x14c>
  if(link("README", "dirfile/xx") == 0){
    32fc:	00004597          	auipc	a1,0x4
    3300:	91458593          	addi	a1,a1,-1772 # 6c10 <malloc+0x19f0>
    3304:	00002517          	auipc	a0,0x2
    3308:	20c50513          	addi	a0,a0,524 # 5510 <malloc+0x2f0>
    330c:	285010ef          	jal	ra,4d90 <link>
    3310:	0c050963          	beqz	a0,33e2 <dirfile+0x160>
  if(unlink("dirfile") != 0){
    3314:	00004517          	auipc	a0,0x4
    3318:	8b450513          	addi	a0,a0,-1868 # 6bc8 <malloc+0x19a8>
    331c:	265010ef          	jal	ra,4d80 <unlink>
    3320:	0c051b63          	bnez	a0,33f6 <dirfile+0x174>
  fd = open(".", O_RDWR);
    3324:	4589                	li	a1,2
    3326:	00002517          	auipc	a0,0x2
    332a:	6fa50513          	addi	a0,a0,1786 # 5a20 <malloc+0x800>
    332e:	243010ef          	jal	ra,4d70 <open>
  if(fd >= 0){
    3332:	0c055c63          	bgez	a0,340a <dirfile+0x188>
  fd = open(".", 0);
    3336:	4581                	li	a1,0
    3338:	00002517          	auipc	a0,0x2
    333c:	6e850513          	addi	a0,a0,1768 # 5a20 <malloc+0x800>
    3340:	231010ef          	jal	ra,4d70 <open>
    3344:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3346:	4605                	li	a2,1
    3348:	00002597          	auipc	a1,0x2
    334c:	06058593          	addi	a1,a1,96 # 53a8 <malloc+0x188>
    3350:	201010ef          	jal	ra,4d50 <write>
    3354:	0ca04563          	bgtz	a0,341e <dirfile+0x19c>
  close(fd);
    3358:	8526                	mv	a0,s1
    335a:	1ff010ef          	jal	ra,4d58 <close>
}
    335e:	60e2                	ld	ra,24(sp)
    3360:	6442                	ld	s0,16(sp)
    3362:	64a2                	ld	s1,8(sp)
    3364:	6902                	ld	s2,0(sp)
    3366:	6105                	addi	sp,sp,32
    3368:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    336a:	85ca                	mv	a1,s2
    336c:	00004517          	auipc	a0,0x4
    3370:	86450513          	addi	a0,a0,-1948 # 6bd0 <malloc+0x19b0>
    3374:	5f9010ef          	jal	ra,516c <printf>
    exit(1);
    3378:	4505                	li	a0,1
    337a:	1b7010ef          	jal	ra,4d30 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    337e:	85ca                	mv	a1,s2
    3380:	00004517          	auipc	a0,0x4
    3384:	87050513          	addi	a0,a0,-1936 # 6bf0 <malloc+0x19d0>
    3388:	5e5010ef          	jal	ra,516c <printf>
    exit(1);
    338c:	4505                	li	a0,1
    338e:	1a3010ef          	jal	ra,4d30 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3392:	85ca                	mv	a1,s2
    3394:	00004517          	auipc	a0,0x4
    3398:	88c50513          	addi	a0,a0,-1908 # 6c20 <malloc+0x1a00>
    339c:	5d1010ef          	jal	ra,516c <printf>
    exit(1);
    33a0:	4505                	li	a0,1
    33a2:	18f010ef          	jal	ra,4d30 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33a6:	85ca                	mv	a1,s2
    33a8:	00004517          	auipc	a0,0x4
    33ac:	87850513          	addi	a0,a0,-1928 # 6c20 <malloc+0x1a00>
    33b0:	5bd010ef          	jal	ra,516c <printf>
    exit(1);
    33b4:	4505                	li	a0,1
    33b6:	17b010ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    33ba:	85ca                	mv	a1,s2
    33bc:	00004517          	auipc	a0,0x4
    33c0:	88c50513          	addi	a0,a0,-1908 # 6c48 <malloc+0x1a28>
    33c4:	5a9010ef          	jal	ra,516c <printf>
    exit(1);
    33c8:	4505                	li	a0,1
    33ca:	167010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    33ce:	85ca                	mv	a1,s2
    33d0:	00004517          	auipc	a0,0x4
    33d4:	8a050513          	addi	a0,a0,-1888 # 6c70 <malloc+0x1a50>
    33d8:	595010ef          	jal	ra,516c <printf>
    exit(1);
    33dc:	4505                	li	a0,1
    33de:	153010ef          	jal	ra,4d30 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    33e2:	85ca                	mv	a1,s2
    33e4:	00004517          	auipc	a0,0x4
    33e8:	8b450513          	addi	a0,a0,-1868 # 6c98 <malloc+0x1a78>
    33ec:	581010ef          	jal	ra,516c <printf>
    exit(1);
    33f0:	4505                	li	a0,1
    33f2:	13f010ef          	jal	ra,4d30 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    33f6:	85ca                	mv	a1,s2
    33f8:	00004517          	auipc	a0,0x4
    33fc:	8c850513          	addi	a0,a0,-1848 # 6cc0 <malloc+0x1aa0>
    3400:	56d010ef          	jal	ra,516c <printf>
    exit(1);
    3404:	4505                	li	a0,1
    3406:	12b010ef          	jal	ra,4d30 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    340a:	85ca                	mv	a1,s2
    340c:	00004517          	auipc	a0,0x4
    3410:	8d450513          	addi	a0,a0,-1836 # 6ce0 <malloc+0x1ac0>
    3414:	559010ef          	jal	ra,516c <printf>
    exit(1);
    3418:	4505                	li	a0,1
    341a:	117010ef          	jal	ra,4d30 <exit>
    printf("%s: write . succeeded!\n", s);
    341e:	85ca                	mv	a1,s2
    3420:	00004517          	auipc	a0,0x4
    3424:	8e850513          	addi	a0,a0,-1816 # 6d08 <malloc+0x1ae8>
    3428:	545010ef          	jal	ra,516c <printf>
    exit(1);
    342c:	4505                	li	a0,1
    342e:	103010ef          	jal	ra,4d30 <exit>

0000000000003432 <iref>:
{
    3432:	7139                	addi	sp,sp,-64
    3434:	fc06                	sd	ra,56(sp)
    3436:	f822                	sd	s0,48(sp)
    3438:	f426                	sd	s1,40(sp)
    343a:	f04a                	sd	s2,32(sp)
    343c:	ec4e                	sd	s3,24(sp)
    343e:	e852                	sd	s4,16(sp)
    3440:	e456                	sd	s5,8(sp)
    3442:	e05a                	sd	s6,0(sp)
    3444:	0080                	addi	s0,sp,64
    3446:	8b2a                	mv	s6,a0
    3448:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    344c:	00004a17          	auipc	s4,0x4
    3450:	8d4a0a13          	addi	s4,s4,-1836 # 6d20 <malloc+0x1b00>
    mkdir("");
    3454:	00003497          	auipc	s1,0x3
    3458:	3d448493          	addi	s1,s1,980 # 6828 <malloc+0x1608>
    link("README", "");
    345c:	00002a97          	auipc	s5,0x2
    3460:	0b4a8a93          	addi	s5,s5,180 # 5510 <malloc+0x2f0>
    fd = open("xx", O_CREATE);
    3464:	00003997          	auipc	s3,0x3
    3468:	7b498993          	addi	s3,s3,1972 # 6c18 <malloc+0x19f8>
    346c:	a835                	j	34a8 <iref+0x76>
      printf("%s: mkdir irefd failed\n", s);
    346e:	85da                	mv	a1,s6
    3470:	00004517          	auipc	a0,0x4
    3474:	8b850513          	addi	a0,a0,-1864 # 6d28 <malloc+0x1b08>
    3478:	4f5010ef          	jal	ra,516c <printf>
      exit(1);
    347c:	4505                	li	a0,1
    347e:	0b3010ef          	jal	ra,4d30 <exit>
      printf("%s: chdir irefd failed\n", s);
    3482:	85da                	mv	a1,s6
    3484:	00004517          	auipc	a0,0x4
    3488:	8bc50513          	addi	a0,a0,-1860 # 6d40 <malloc+0x1b20>
    348c:	4e1010ef          	jal	ra,516c <printf>
      exit(1);
    3490:	4505                	li	a0,1
    3492:	09f010ef          	jal	ra,4d30 <exit>
      close(fd);
    3496:	0c3010ef          	jal	ra,4d58 <close>
    349a:	a82d                	j	34d4 <iref+0xa2>
    unlink("xx");
    349c:	854e                	mv	a0,s3
    349e:	0e3010ef          	jal	ra,4d80 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    34a2:	397d                	addiw	s2,s2,-1
    34a4:	04090263          	beqz	s2,34e8 <iref+0xb6>
    if(mkdir("irefd") != 0){
    34a8:	8552                	mv	a0,s4
    34aa:	0ef010ef          	jal	ra,4d98 <mkdir>
    34ae:	f161                	bnez	a0,346e <iref+0x3c>
    if(chdir("irefd") != 0){
    34b0:	8552                	mv	a0,s4
    34b2:	0ef010ef          	jal	ra,4da0 <chdir>
    34b6:	f571                	bnez	a0,3482 <iref+0x50>
    mkdir("");
    34b8:	8526                	mv	a0,s1
    34ba:	0df010ef          	jal	ra,4d98 <mkdir>
    link("README", "");
    34be:	85a6                	mv	a1,s1
    34c0:	8556                	mv	a0,s5
    34c2:	0cf010ef          	jal	ra,4d90 <link>
    fd = open("", O_CREATE);
    34c6:	20000593          	li	a1,512
    34ca:	8526                	mv	a0,s1
    34cc:	0a5010ef          	jal	ra,4d70 <open>
    if(fd >= 0)
    34d0:	fc0553e3          	bgez	a0,3496 <iref+0x64>
    fd = open("xx", O_CREATE);
    34d4:	20000593          	li	a1,512
    34d8:	854e                	mv	a0,s3
    34da:	097010ef          	jal	ra,4d70 <open>
    if(fd >= 0)
    34de:	fa054fe3          	bltz	a0,349c <iref+0x6a>
      close(fd);
    34e2:	077010ef          	jal	ra,4d58 <close>
    34e6:	bf5d                	j	349c <iref+0x6a>
    34e8:	03300493          	li	s1,51
    chdir("..");
    34ec:	00003997          	auipc	s3,0x3
    34f0:	05498993          	addi	s3,s3,84 # 6540 <malloc+0x1320>
    unlink("irefd");
    34f4:	00004917          	auipc	s2,0x4
    34f8:	82c90913          	addi	s2,s2,-2004 # 6d20 <malloc+0x1b00>
    chdir("..");
    34fc:	854e                	mv	a0,s3
    34fe:	0a3010ef          	jal	ra,4da0 <chdir>
    unlink("irefd");
    3502:	854a                	mv	a0,s2
    3504:	07d010ef          	jal	ra,4d80 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3508:	34fd                	addiw	s1,s1,-1
    350a:	f8ed                	bnez	s1,34fc <iref+0xca>
  chdir("/");
    350c:	00003517          	auipc	a0,0x3
    3510:	fdc50513          	addi	a0,a0,-36 # 64e8 <malloc+0x12c8>
    3514:	08d010ef          	jal	ra,4da0 <chdir>
}
    3518:	70e2                	ld	ra,56(sp)
    351a:	7442                	ld	s0,48(sp)
    351c:	74a2                	ld	s1,40(sp)
    351e:	7902                	ld	s2,32(sp)
    3520:	69e2                	ld	s3,24(sp)
    3522:	6a42                	ld	s4,16(sp)
    3524:	6aa2                	ld	s5,8(sp)
    3526:	6b02                	ld	s6,0(sp)
    3528:	6121                	addi	sp,sp,64
    352a:	8082                	ret

000000000000352c <openiputtest>:
{
    352c:	7179                	addi	sp,sp,-48
    352e:	f406                	sd	ra,40(sp)
    3530:	f022                	sd	s0,32(sp)
    3532:	ec26                	sd	s1,24(sp)
    3534:	1800                	addi	s0,sp,48
    3536:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3538:	00004517          	auipc	a0,0x4
    353c:	82050513          	addi	a0,a0,-2016 # 6d58 <malloc+0x1b38>
    3540:	059010ef          	jal	ra,4d98 <mkdir>
    3544:	02054a63          	bltz	a0,3578 <openiputtest+0x4c>
  pid = fork();
    3548:	7e0010ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    354c:	04054063          	bltz	a0,358c <openiputtest+0x60>
  if(pid == 0){
    3550:	e939                	bnez	a0,35a6 <openiputtest+0x7a>
    int fd = open("oidir", O_RDWR);
    3552:	4589                	li	a1,2
    3554:	00004517          	auipc	a0,0x4
    3558:	80450513          	addi	a0,a0,-2044 # 6d58 <malloc+0x1b38>
    355c:	015010ef          	jal	ra,4d70 <open>
    if(fd >= 0){
    3560:	04054063          	bltz	a0,35a0 <openiputtest+0x74>
      printf("%s: open directory for write succeeded\n", s);
    3564:	85a6                	mv	a1,s1
    3566:	00004517          	auipc	a0,0x4
    356a:	81250513          	addi	a0,a0,-2030 # 6d78 <malloc+0x1b58>
    356e:	3ff010ef          	jal	ra,516c <printf>
      exit(1);
    3572:	4505                	li	a0,1
    3574:	7bc010ef          	jal	ra,4d30 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3578:	85a6                	mv	a1,s1
    357a:	00003517          	auipc	a0,0x3
    357e:	7e650513          	addi	a0,a0,2022 # 6d60 <malloc+0x1b40>
    3582:	3eb010ef          	jal	ra,516c <printf>
    exit(1);
    3586:	4505                	li	a0,1
    3588:	7a8010ef          	jal	ra,4d30 <exit>
    printf("%s: fork failed\n", s);
    358c:	85a6                	mv	a1,s1
    358e:	00002517          	auipc	a0,0x2
    3592:	63a50513          	addi	a0,a0,1594 # 5bc8 <malloc+0x9a8>
    3596:	3d7010ef          	jal	ra,516c <printf>
    exit(1);
    359a:	4505                	li	a0,1
    359c:	794010ef          	jal	ra,4d30 <exit>
    exit(0);
    35a0:	4501                	li	a0,0
    35a2:	78e010ef          	jal	ra,4d30 <exit>
  pause(1);
    35a6:	4505                	li	a0,1
    35a8:	019010ef          	jal	ra,4dc0 <pause>
  if(unlink("oidir") != 0){
    35ac:	00003517          	auipc	a0,0x3
    35b0:	7ac50513          	addi	a0,a0,1964 # 6d58 <malloc+0x1b38>
    35b4:	7cc010ef          	jal	ra,4d80 <unlink>
    35b8:	c919                	beqz	a0,35ce <openiputtest+0xa2>
    printf("%s: unlink failed\n", s);
    35ba:	85a6                	mv	a1,s1
    35bc:	00002517          	auipc	a0,0x2
    35c0:	7fc50513          	addi	a0,a0,2044 # 5db8 <malloc+0xb98>
    35c4:	3a9010ef          	jal	ra,516c <printf>
    exit(1);
    35c8:	4505                	li	a0,1
    35ca:	766010ef          	jal	ra,4d30 <exit>
  wait(&xstatus);
    35ce:	fdc40513          	addi	a0,s0,-36
    35d2:	766010ef          	jal	ra,4d38 <wait>
  exit(xstatus);
    35d6:	fdc42503          	lw	a0,-36(s0)
    35da:	756010ef          	jal	ra,4d30 <exit>

00000000000035de <forkforkfork>:
{
    35de:	1101                	addi	sp,sp,-32
    35e0:	ec06                	sd	ra,24(sp)
    35e2:	e822                	sd	s0,16(sp)
    35e4:	e426                	sd	s1,8(sp)
    35e6:	1000                	addi	s0,sp,32
    35e8:	84aa                	mv	s1,a0
  unlink("stopforking");
    35ea:	00003517          	auipc	a0,0x3
    35ee:	7b650513          	addi	a0,a0,1974 # 6da0 <malloc+0x1b80>
    35f2:	78e010ef          	jal	ra,4d80 <unlink>
  int pid = fork();
    35f6:	732010ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    35fa:	02054b63          	bltz	a0,3630 <forkforkfork+0x52>
  if(pid == 0){
    35fe:	c139                	beqz	a0,3644 <forkforkfork+0x66>
  pause(20); // two seconds
    3600:	4551                	li	a0,20
    3602:	7be010ef          	jal	ra,4dc0 <pause>
  close(open("stopforking", O_CREATE|O_RDWR));
    3606:	20200593          	li	a1,514
    360a:	00003517          	auipc	a0,0x3
    360e:	79650513          	addi	a0,a0,1942 # 6da0 <malloc+0x1b80>
    3612:	75e010ef          	jal	ra,4d70 <open>
    3616:	742010ef          	jal	ra,4d58 <close>
  wait(0);
    361a:	4501                	li	a0,0
    361c:	71c010ef          	jal	ra,4d38 <wait>
  pause(10); // one second
    3620:	4529                	li	a0,10
    3622:	79e010ef          	jal	ra,4dc0 <pause>
}
    3626:	60e2                	ld	ra,24(sp)
    3628:	6442                	ld	s0,16(sp)
    362a:	64a2                	ld	s1,8(sp)
    362c:	6105                	addi	sp,sp,32
    362e:	8082                	ret
    printf("%s: fork failed", s);
    3630:	85a6                	mv	a1,s1
    3632:	00002517          	auipc	a0,0x2
    3636:	75650513          	addi	a0,a0,1878 # 5d88 <malloc+0xb68>
    363a:	333010ef          	jal	ra,516c <printf>
    exit(1);
    363e:	4505                	li	a0,1
    3640:	6f0010ef          	jal	ra,4d30 <exit>
      int fd = open("stopforking", 0);
    3644:	00003497          	auipc	s1,0x3
    3648:	75c48493          	addi	s1,s1,1884 # 6da0 <malloc+0x1b80>
    364c:	4581                	li	a1,0
    364e:	8526                	mv	a0,s1
    3650:	720010ef          	jal	ra,4d70 <open>
      if(fd >= 0){
    3654:	00055e63          	bgez	a0,3670 <forkforkfork+0x92>
      if(fork() < 0){
    3658:	6d0010ef          	jal	ra,4d28 <fork>
    365c:	fe0558e3          	bgez	a0,364c <forkforkfork+0x6e>
        close(open("stopforking", O_CREATE|O_RDWR));
    3660:	20200593          	li	a1,514
    3664:	8526                	mv	a0,s1
    3666:	70a010ef          	jal	ra,4d70 <open>
    366a:	6ee010ef          	jal	ra,4d58 <close>
    366e:	bff9                	j	364c <forkforkfork+0x6e>
        exit(0);
    3670:	4501                	li	a0,0
    3672:	6be010ef          	jal	ra,4d30 <exit>

0000000000003676 <killstatus>:
{
    3676:	7139                	addi	sp,sp,-64
    3678:	fc06                	sd	ra,56(sp)
    367a:	f822                	sd	s0,48(sp)
    367c:	f426                	sd	s1,40(sp)
    367e:	f04a                	sd	s2,32(sp)
    3680:	ec4e                	sd	s3,24(sp)
    3682:	e852                	sd	s4,16(sp)
    3684:	0080                	addi	s0,sp,64
    3686:	8a2a                	mv	s4,a0
    3688:	06400913          	li	s2,100
    if(xst != -1) {
    368c:	59fd                	li	s3,-1
    int pid1 = fork();
    368e:	69a010ef          	jal	ra,4d28 <fork>
    3692:	84aa                	mv	s1,a0
    if(pid1 < 0){
    3694:	02054763          	bltz	a0,36c2 <killstatus+0x4c>
    if(pid1 == 0){
    3698:	cd1d                	beqz	a0,36d6 <killstatus+0x60>
    pause(1);
    369a:	4505                	li	a0,1
    369c:	724010ef          	jal	ra,4dc0 <pause>
    kill(pid1);
    36a0:	8526                	mv	a0,s1
    36a2:	6be010ef          	jal	ra,4d60 <kill>
    wait(&xst);
    36a6:	fcc40513          	addi	a0,s0,-52
    36aa:	68e010ef          	jal	ra,4d38 <wait>
    if(xst != -1) {
    36ae:	fcc42783          	lw	a5,-52(s0)
    36b2:	03379563          	bne	a5,s3,36dc <killstatus+0x66>
  for(int i = 0; i < 100; i++){
    36b6:	397d                	addiw	s2,s2,-1
    36b8:	fc091be3          	bnez	s2,368e <killstatus+0x18>
  exit(0);
    36bc:	4501                	li	a0,0
    36be:	672010ef          	jal	ra,4d30 <exit>
      printf("%s: fork failed\n", s);
    36c2:	85d2                	mv	a1,s4
    36c4:	00002517          	auipc	a0,0x2
    36c8:	50450513          	addi	a0,a0,1284 # 5bc8 <malloc+0x9a8>
    36cc:	2a1010ef          	jal	ra,516c <printf>
      exit(1);
    36d0:	4505                	li	a0,1
    36d2:	65e010ef          	jal	ra,4d30 <exit>
        getpid();
    36d6:	6da010ef          	jal	ra,4db0 <getpid>
      while(1) {
    36da:	bff5                	j	36d6 <killstatus+0x60>
       printf("%s: status should be -1\n", s);
    36dc:	85d2                	mv	a1,s4
    36de:	00003517          	auipc	a0,0x3
    36e2:	6d250513          	addi	a0,a0,1746 # 6db0 <malloc+0x1b90>
    36e6:	287010ef          	jal	ra,516c <printf>
       exit(1);
    36ea:	4505                	li	a0,1
    36ec:	644010ef          	jal	ra,4d30 <exit>

00000000000036f0 <preempt>:
{
    36f0:	7139                	addi	sp,sp,-64
    36f2:	fc06                	sd	ra,56(sp)
    36f4:	f822                	sd	s0,48(sp)
    36f6:	f426                	sd	s1,40(sp)
    36f8:	f04a                	sd	s2,32(sp)
    36fa:	ec4e                	sd	s3,24(sp)
    36fc:	e852                	sd	s4,16(sp)
    36fe:	0080                	addi	s0,sp,64
    3700:	892a                	mv	s2,a0
  pid1 = fork();
    3702:	626010ef          	jal	ra,4d28 <fork>
  if(pid1 < 0) {
    3706:	00054563          	bltz	a0,3710 <preempt+0x20>
    370a:	84aa                	mv	s1,a0
  if(pid1 == 0)
    370c:	ed01                	bnez	a0,3724 <preempt+0x34>
    for(;;)
    370e:	a001                	j	370e <preempt+0x1e>
    printf("%s: fork failed", s);
    3710:	85ca                	mv	a1,s2
    3712:	00002517          	auipc	a0,0x2
    3716:	67650513          	addi	a0,a0,1654 # 5d88 <malloc+0xb68>
    371a:	253010ef          	jal	ra,516c <printf>
    exit(1);
    371e:	4505                	li	a0,1
    3720:	610010ef          	jal	ra,4d30 <exit>
  pid2 = fork();
    3724:	604010ef          	jal	ra,4d28 <fork>
    3728:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    372a:	00054463          	bltz	a0,3732 <preempt+0x42>
  if(pid2 == 0)
    372e:	ed01                	bnez	a0,3746 <preempt+0x56>
    for(;;)
    3730:	a001                	j	3730 <preempt+0x40>
    printf("%s: fork failed\n", s);
    3732:	85ca                	mv	a1,s2
    3734:	00002517          	auipc	a0,0x2
    3738:	49450513          	addi	a0,a0,1172 # 5bc8 <malloc+0x9a8>
    373c:	231010ef          	jal	ra,516c <printf>
    exit(1);
    3740:	4505                	li	a0,1
    3742:	5ee010ef          	jal	ra,4d30 <exit>
  pipe(pfds);
    3746:	fc840513          	addi	a0,s0,-56
    374a:	5f6010ef          	jal	ra,4d40 <pipe>
  pid3 = fork();
    374e:	5da010ef          	jal	ra,4d28 <fork>
    3752:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    3754:	02054863          	bltz	a0,3784 <preempt+0x94>
  if(pid3 == 0){
    3758:	e921                	bnez	a0,37a8 <preempt+0xb8>
    close(pfds[0]);
    375a:	fc842503          	lw	a0,-56(s0)
    375e:	5fa010ef          	jal	ra,4d58 <close>
    if(write(pfds[1], "x", 1) != 1)
    3762:	4605                	li	a2,1
    3764:	00002597          	auipc	a1,0x2
    3768:	c4458593          	addi	a1,a1,-956 # 53a8 <malloc+0x188>
    376c:	fcc42503          	lw	a0,-52(s0)
    3770:	5e0010ef          	jal	ra,4d50 <write>
    3774:	4785                	li	a5,1
    3776:	02f51163          	bne	a0,a5,3798 <preempt+0xa8>
    close(pfds[1]);
    377a:	fcc42503          	lw	a0,-52(s0)
    377e:	5da010ef          	jal	ra,4d58 <close>
    for(;;)
    3782:	a001                	j	3782 <preempt+0x92>
     printf("%s: fork failed\n", s);
    3784:	85ca                	mv	a1,s2
    3786:	00002517          	auipc	a0,0x2
    378a:	44250513          	addi	a0,a0,1090 # 5bc8 <malloc+0x9a8>
    378e:	1df010ef          	jal	ra,516c <printf>
     exit(1);
    3792:	4505                	li	a0,1
    3794:	59c010ef          	jal	ra,4d30 <exit>
      printf("%s: preempt write error", s);
    3798:	85ca                	mv	a1,s2
    379a:	00003517          	auipc	a0,0x3
    379e:	63650513          	addi	a0,a0,1590 # 6dd0 <malloc+0x1bb0>
    37a2:	1cb010ef          	jal	ra,516c <printf>
    37a6:	bfd1                	j	377a <preempt+0x8a>
  close(pfds[1]);
    37a8:	fcc42503          	lw	a0,-52(s0)
    37ac:	5ac010ef          	jal	ra,4d58 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    37b0:	660d                	lui	a2,0x3
    37b2:	00008597          	auipc	a1,0x8
    37b6:	50658593          	addi	a1,a1,1286 # bcb8 <buf>
    37ba:	fc842503          	lw	a0,-56(s0)
    37be:	58a010ef          	jal	ra,4d48 <read>
    37c2:	4785                	li	a5,1
    37c4:	02f50163          	beq	a0,a5,37e6 <preempt+0xf6>
    printf("%s: preempt read error", s);
    37c8:	85ca                	mv	a1,s2
    37ca:	00003517          	auipc	a0,0x3
    37ce:	61e50513          	addi	a0,a0,1566 # 6de8 <malloc+0x1bc8>
    37d2:	19b010ef          	jal	ra,516c <printf>
}
    37d6:	70e2                	ld	ra,56(sp)
    37d8:	7442                	ld	s0,48(sp)
    37da:	74a2                	ld	s1,40(sp)
    37dc:	7902                	ld	s2,32(sp)
    37de:	69e2                	ld	s3,24(sp)
    37e0:	6a42                	ld	s4,16(sp)
    37e2:	6121                	addi	sp,sp,64
    37e4:	8082                	ret
  close(pfds[0]);
    37e6:	fc842503          	lw	a0,-56(s0)
    37ea:	56e010ef          	jal	ra,4d58 <close>
  printf("kill... ");
    37ee:	00003517          	auipc	a0,0x3
    37f2:	61250513          	addi	a0,a0,1554 # 6e00 <malloc+0x1be0>
    37f6:	177010ef          	jal	ra,516c <printf>
  kill(pid1);
    37fa:	8526                	mv	a0,s1
    37fc:	564010ef          	jal	ra,4d60 <kill>
  kill(pid2);
    3800:	854e                	mv	a0,s3
    3802:	55e010ef          	jal	ra,4d60 <kill>
  kill(pid3);
    3806:	8552                	mv	a0,s4
    3808:	558010ef          	jal	ra,4d60 <kill>
  printf("wait... ");
    380c:	00003517          	auipc	a0,0x3
    3810:	60450513          	addi	a0,a0,1540 # 6e10 <malloc+0x1bf0>
    3814:	159010ef          	jal	ra,516c <printf>
  wait(0);
    3818:	4501                	li	a0,0
    381a:	51e010ef          	jal	ra,4d38 <wait>
  wait(0);
    381e:	4501                	li	a0,0
    3820:	518010ef          	jal	ra,4d38 <wait>
  wait(0);
    3824:	4501                	li	a0,0
    3826:	512010ef          	jal	ra,4d38 <wait>
    382a:	b775                	j	37d6 <preempt+0xe6>

000000000000382c <reparent>:
{
    382c:	7179                	addi	sp,sp,-48
    382e:	f406                	sd	ra,40(sp)
    3830:	f022                	sd	s0,32(sp)
    3832:	ec26                	sd	s1,24(sp)
    3834:	e84a                	sd	s2,16(sp)
    3836:	e44e                	sd	s3,8(sp)
    3838:	e052                	sd	s4,0(sp)
    383a:	1800                	addi	s0,sp,48
    383c:	89aa                	mv	s3,a0
  int master_pid = getpid();
    383e:	572010ef          	jal	ra,4db0 <getpid>
    3842:	8a2a                	mv	s4,a0
    3844:	0c800913          	li	s2,200
    int pid = fork();
    3848:	4e0010ef          	jal	ra,4d28 <fork>
    384c:	84aa                	mv	s1,a0
    if(pid < 0){
    384e:	00054e63          	bltz	a0,386a <reparent+0x3e>
    if(pid){
    3852:	c121                	beqz	a0,3892 <reparent+0x66>
      if(wait(0) != pid){
    3854:	4501                	li	a0,0
    3856:	4e2010ef          	jal	ra,4d38 <wait>
    385a:	02951263          	bne	a0,s1,387e <reparent+0x52>
  for(int i = 0; i < 200; i++){
    385e:	397d                	addiw	s2,s2,-1
    3860:	fe0914e3          	bnez	s2,3848 <reparent+0x1c>
  exit(0);
    3864:	4501                	li	a0,0
    3866:	4ca010ef          	jal	ra,4d30 <exit>
      printf("%s: fork failed\n", s);
    386a:	85ce                	mv	a1,s3
    386c:	00002517          	auipc	a0,0x2
    3870:	35c50513          	addi	a0,a0,860 # 5bc8 <malloc+0x9a8>
    3874:	0f9010ef          	jal	ra,516c <printf>
      exit(1);
    3878:	4505                	li	a0,1
    387a:	4b6010ef          	jal	ra,4d30 <exit>
        printf("%s: wait wrong pid\n", s);
    387e:	85ce                	mv	a1,s3
    3880:	00002517          	auipc	a0,0x2
    3884:	4d050513          	addi	a0,a0,1232 # 5d50 <malloc+0xb30>
    3888:	0e5010ef          	jal	ra,516c <printf>
        exit(1);
    388c:	4505                	li	a0,1
    388e:	4a2010ef          	jal	ra,4d30 <exit>
      int pid2 = fork();
    3892:	496010ef          	jal	ra,4d28 <fork>
      if(pid2 < 0){
    3896:	00054563          	bltz	a0,38a0 <reparent+0x74>
      exit(0);
    389a:	4501                	li	a0,0
    389c:	494010ef          	jal	ra,4d30 <exit>
        kill(master_pid);
    38a0:	8552                	mv	a0,s4
    38a2:	4be010ef          	jal	ra,4d60 <kill>
        exit(1);
    38a6:	4505                	li	a0,1
    38a8:	488010ef          	jal	ra,4d30 <exit>

00000000000038ac <sbrkfail>:
{
    38ac:	7175                	addi	sp,sp,-144
    38ae:	e506                	sd	ra,136(sp)
    38b0:	e122                	sd	s0,128(sp)
    38b2:	fca6                	sd	s1,120(sp)
    38b4:	f8ca                	sd	s2,112(sp)
    38b6:	f4ce                	sd	s3,104(sp)
    38b8:	f0d2                	sd	s4,96(sp)
    38ba:	ecd6                	sd	s5,88(sp)
    38bc:	e8da                	sd	s6,80(sp)
    38be:	e4de                	sd	s7,72(sp)
    38c0:	0900                	addi	s0,sp,144
    38c2:	8b2a                	mv	s6,a0
  if(pipe(fds) != 0){
    38c4:	fa040513          	addi	a0,s0,-96
    38c8:	478010ef          	jal	ra,4d40 <pipe>
    38cc:	e919                	bnez	a0,38e2 <sbrkfail+0x36>
    38ce:	8aaa                	mv	s5,a0
    38d0:	f7040493          	addi	s1,s0,-144
    38d4:	f9840993          	addi	s3,s0,-104
    38d8:	8926                	mv	s2,s1
    if(pids[i] != -1) {
    38da:	5a7d                	li	s4,-1
      if(scratch == '0')
    38dc:	03000b93          	li	s7,48
    38e0:	a08d                	j	3942 <sbrkfail+0x96>
    printf("%s: pipe() failed\n", s);
    38e2:	85da                	mv	a1,s6
    38e4:	00002517          	auipc	a0,0x2
    38e8:	3ec50513          	addi	a0,a0,1004 # 5cd0 <malloc+0xab0>
    38ec:	081010ef          	jal	ra,516c <printf>
    exit(1);
    38f0:	4505                	li	a0,1
    38f2:	43e010ef          	jal	ra,4d30 <exit>
      if (sbrk(BIG - (uint64)sbrk(0)) ==  (char*)SBRK_ERROR)
    38f6:	406010ef          	jal	ra,4cfc <sbrk>
    38fa:	064007b7          	lui	a5,0x6400
    38fe:	40a7853b          	subw	a0,a5,a0
    3902:	3fa010ef          	jal	ra,4cfc <sbrk>
    3906:	57fd                	li	a5,-1
    3908:	02f50063          	beq	a0,a5,3928 <sbrkfail+0x7c>
        write(fds[1], "1", 1);
    390c:	4605                	li	a2,1
    390e:	00004597          	auipc	a1,0x4
    3912:	c8a58593          	addi	a1,a1,-886 # 7598 <malloc+0x2378>
    3916:	fa442503          	lw	a0,-92(s0)
    391a:	436010ef          	jal	ra,4d50 <write>
      for(;;) pause(1000);
    391e:	3e800513          	li	a0,1000
    3922:	49e010ef          	jal	ra,4dc0 <pause>
    3926:	bfe5                	j	391e <sbrkfail+0x72>
        write(fds[1], "0", 1);
    3928:	4605                	li	a2,1
    392a:	00003597          	auipc	a1,0x3
    392e:	4f658593          	addi	a1,a1,1270 # 6e20 <malloc+0x1c00>
    3932:	fa442503          	lw	a0,-92(s0)
    3936:	41a010ef          	jal	ra,4d50 <write>
    393a:	b7d5                	j	391e <sbrkfail+0x72>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    393c:	0911                	addi	s2,s2,4
    393e:	03390663          	beq	s2,s3,396a <sbrkfail+0xbe>
    if((pids[i] = fork()) == 0){
    3942:	3e6010ef          	jal	ra,4d28 <fork>
    3946:	00a92023          	sw	a0,0(s2)
    394a:	d555                	beqz	a0,38f6 <sbrkfail+0x4a>
    if(pids[i] != -1) {
    394c:	ff4508e3          	beq	a0,s4,393c <sbrkfail+0x90>
      read(fds[0], &scratch, 1);
    3950:	4605                	li	a2,1
    3952:	f9f40593          	addi	a1,s0,-97
    3956:	fa042503          	lw	a0,-96(s0)
    395a:	3ee010ef          	jal	ra,4d48 <read>
      if(scratch == '0')
    395e:	f9f44783          	lbu	a5,-97(s0)
    3962:	fd779de3          	bne	a5,s7,393c <sbrkfail+0x90>
        failed = 1;
    3966:	4a85                	li	s5,1
    3968:	bfd1                	j	393c <sbrkfail+0x90>
  if(!failed) {
    396a:	000a8863          	beqz	s5,397a <sbrkfail+0xce>
  c = sbrk(PGSIZE);
    396e:	6505                	lui	a0,0x1
    3970:	38c010ef          	jal	ra,4cfc <sbrk>
    3974:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    3976:	597d                	li	s2,-1
    3978:	a821                	j	3990 <sbrkfail+0xe4>
    printf("%s: no allocation failed; allocate more?\n", s);
    397a:	85da                	mv	a1,s6
    397c:	00003517          	auipc	a0,0x3
    3980:	4ac50513          	addi	a0,a0,1196 # 6e28 <malloc+0x1c08>
    3984:	7e8010ef          	jal	ra,516c <printf>
    3988:	b7dd                	j	396e <sbrkfail+0xc2>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    398a:	0491                	addi	s1,s1,4
    398c:	01348b63          	beq	s1,s3,39a2 <sbrkfail+0xf6>
    if(pids[i] == -1)
    3990:	4088                	lw	a0,0(s1)
    3992:	ff250ce3          	beq	a0,s2,398a <sbrkfail+0xde>
    kill(pids[i]);
    3996:	3ca010ef          	jal	ra,4d60 <kill>
    wait(0);
    399a:	4501                	li	a0,0
    399c:	39c010ef          	jal	ra,4d38 <wait>
    39a0:	b7ed                	j	398a <sbrkfail+0xde>
  if(c == (char*)SBRK_ERROR){
    39a2:	57fd                	li	a5,-1
    39a4:	02fa0a63          	beq	s4,a5,39d8 <sbrkfail+0x12c>
  pid = fork();
    39a8:	380010ef          	jal	ra,4d28 <fork>
  if(pid < 0){
    39ac:	04054063          	bltz	a0,39ec <sbrkfail+0x140>
  if(pid == 0){
    39b0:	e939                	bnez	a0,3a06 <sbrkfail+0x15a>
    a = sbrk(10*BIG);
    39b2:	3e800537          	lui	a0,0x3e800
    39b6:	346010ef          	jal	ra,4cfc <sbrk>
    if(a == (char*)SBRK_ERROR){
    39ba:	57fd                	li	a5,-1
    39bc:	04f50263          	beq	a0,a5,3a00 <sbrkfail+0x154>
    printf("%s: allocate a lot of memory succeeded %d\n", s, 10*BIG);
    39c0:	3e800637          	lui	a2,0x3e800
    39c4:	85da                	mv	a1,s6
    39c6:	00003517          	auipc	a0,0x3
    39ca:	4b250513          	addi	a0,a0,1202 # 6e78 <malloc+0x1c58>
    39ce:	79e010ef          	jal	ra,516c <printf>
    exit(1);
    39d2:	4505                	li	a0,1
    39d4:	35c010ef          	jal	ra,4d30 <exit>
    printf("%s: failed sbrk leaked memory\n", s);
    39d8:	85da                	mv	a1,s6
    39da:	00003517          	auipc	a0,0x3
    39de:	47e50513          	addi	a0,a0,1150 # 6e58 <malloc+0x1c38>
    39e2:	78a010ef          	jal	ra,516c <printf>
    exit(1);
    39e6:	4505                	li	a0,1
    39e8:	348010ef          	jal	ra,4d30 <exit>
    printf("%s: fork failed\n", s);
    39ec:	85da                	mv	a1,s6
    39ee:	00002517          	auipc	a0,0x2
    39f2:	1da50513          	addi	a0,a0,474 # 5bc8 <malloc+0x9a8>
    39f6:	776010ef          	jal	ra,516c <printf>
    exit(1);
    39fa:	4505                	li	a0,1
    39fc:	334010ef          	jal	ra,4d30 <exit>
      exit(0);
    3a00:	4501                	li	a0,0
    3a02:	32e010ef          	jal	ra,4d30 <exit>
  wait(&xstatus);
    3a06:	fac40513          	addi	a0,s0,-84
    3a0a:	32e010ef          	jal	ra,4d38 <wait>
  if(xstatus != 0)
    3a0e:	fac42783          	lw	a5,-84(s0)
    3a12:	ef81                	bnez	a5,3a2a <sbrkfail+0x17e>
}
    3a14:	60aa                	ld	ra,136(sp)
    3a16:	640a                	ld	s0,128(sp)
    3a18:	74e6                	ld	s1,120(sp)
    3a1a:	7946                	ld	s2,112(sp)
    3a1c:	79a6                	ld	s3,104(sp)
    3a1e:	7a06                	ld	s4,96(sp)
    3a20:	6ae6                	ld	s5,88(sp)
    3a22:	6b46                	ld	s6,80(sp)
    3a24:	6ba6                	ld	s7,72(sp)
    3a26:	6149                	addi	sp,sp,144
    3a28:	8082                	ret
    exit(1);
    3a2a:	4505                	li	a0,1
    3a2c:	304010ef          	jal	ra,4d30 <exit>

0000000000003a30 <mem>:
{
    3a30:	7139                	addi	sp,sp,-64
    3a32:	fc06                	sd	ra,56(sp)
    3a34:	f822                	sd	s0,48(sp)
    3a36:	f426                	sd	s1,40(sp)
    3a38:	f04a                	sd	s2,32(sp)
    3a3a:	ec4e                	sd	s3,24(sp)
    3a3c:	0080                	addi	s0,sp,64
    3a3e:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3a40:	2e8010ef          	jal	ra,4d28 <fork>
    m1 = 0;
    3a44:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3a46:	6909                	lui	s2,0x2
    3a48:	71190913          	addi	s2,s2,1809 # 2711 <fourteen+0xeb>
  if((pid = fork()) == 0){
    3a4c:	cd11                	beqz	a0,3a68 <mem+0x38>
    wait(&xstatus);
    3a4e:	fcc40513          	addi	a0,s0,-52
    3a52:	2e6010ef          	jal	ra,4d38 <wait>
    if(xstatus == -1){
    3a56:	fcc42503          	lw	a0,-52(s0)
    3a5a:	57fd                	li	a5,-1
    3a5c:	04f50363          	beq	a0,a5,3aa2 <mem+0x72>
    exit(xstatus);
    3a60:	2d0010ef          	jal	ra,4d30 <exit>
      *(char**)m2 = m1;
    3a64:	e104                	sd	s1,0(a0)
      m1 = m2;
    3a66:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3a68:	854a                	mv	a0,s2
    3a6a:	7b6010ef          	jal	ra,5220 <malloc>
    3a6e:	f97d                	bnez	a0,3a64 <mem+0x34>
    while(m1){
    3a70:	c491                	beqz	s1,3a7c <mem+0x4c>
      m2 = *(char**)m1;
    3a72:	8526                	mv	a0,s1
    3a74:	6084                	ld	s1,0(s1)
      free(m1);
    3a76:	728010ef          	jal	ra,519e <free>
    while(m1){
    3a7a:	fce5                	bnez	s1,3a72 <mem+0x42>
    m1 = malloc(1024*20);
    3a7c:	6515                	lui	a0,0x5
    3a7e:	7a2010ef          	jal	ra,5220 <malloc>
    if(m1 == 0){
    3a82:	c511                	beqz	a0,3a8e <mem+0x5e>
    free(m1);
    3a84:	71a010ef          	jal	ra,519e <free>
    exit(0);
    3a88:	4501                	li	a0,0
    3a8a:	2a6010ef          	jal	ra,4d30 <exit>
      printf("%s: couldn't allocate mem?!!\n", s);
    3a8e:	85ce                	mv	a1,s3
    3a90:	00003517          	auipc	a0,0x3
    3a94:	41850513          	addi	a0,a0,1048 # 6ea8 <malloc+0x1c88>
    3a98:	6d4010ef          	jal	ra,516c <printf>
      exit(1);
    3a9c:	4505                	li	a0,1
    3a9e:	292010ef          	jal	ra,4d30 <exit>
      exit(0);
    3aa2:	4501                	li	a0,0
    3aa4:	28c010ef          	jal	ra,4d30 <exit>

0000000000003aa8 <sharedfd>:
{
    3aa8:	7159                	addi	sp,sp,-112
    3aaa:	f486                	sd	ra,104(sp)
    3aac:	f0a2                	sd	s0,96(sp)
    3aae:	eca6                	sd	s1,88(sp)
    3ab0:	e8ca                	sd	s2,80(sp)
    3ab2:	e4ce                	sd	s3,72(sp)
    3ab4:	e0d2                	sd	s4,64(sp)
    3ab6:	fc56                	sd	s5,56(sp)
    3ab8:	f85a                	sd	s6,48(sp)
    3aba:	f45e                	sd	s7,40(sp)
    3abc:	1880                	addi	s0,sp,112
    3abe:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3ac0:	00003517          	auipc	a0,0x3
    3ac4:	40850513          	addi	a0,a0,1032 # 6ec8 <malloc+0x1ca8>
    3ac8:	2b8010ef          	jal	ra,4d80 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3acc:	20200593          	li	a1,514
    3ad0:	00003517          	auipc	a0,0x3
    3ad4:	3f850513          	addi	a0,a0,1016 # 6ec8 <malloc+0x1ca8>
    3ad8:	298010ef          	jal	ra,4d70 <open>
  if(fd < 0){
    3adc:	04054263          	bltz	a0,3b20 <sharedfd+0x78>
    3ae0:	892a                	mv	s2,a0
  pid = fork();
    3ae2:	246010ef          	jal	ra,4d28 <fork>
    3ae6:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3ae8:	06300593          	li	a1,99
    3aec:	c119                	beqz	a0,3af2 <sharedfd+0x4a>
    3aee:	07000593          	li	a1,112
    3af2:	4629                	li	a2,10
    3af4:	fa040513          	addi	a0,s0,-96
    3af8:	026010ef          	jal	ra,4b1e <memset>
    3afc:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3b00:	4629                	li	a2,10
    3b02:	fa040593          	addi	a1,s0,-96
    3b06:	854a                	mv	a0,s2
    3b08:	248010ef          	jal	ra,4d50 <write>
    3b0c:	47a9                	li	a5,10
    3b0e:	02f51363          	bne	a0,a5,3b34 <sharedfd+0x8c>
  for(i = 0; i < N; i++){
    3b12:	34fd                	addiw	s1,s1,-1
    3b14:	f4f5                	bnez	s1,3b00 <sharedfd+0x58>
  if(pid == 0) {
    3b16:	02099963          	bnez	s3,3b48 <sharedfd+0xa0>
    exit(0);
    3b1a:	4501                	li	a0,0
    3b1c:	214010ef          	jal	ra,4d30 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    3b20:	85d2                	mv	a1,s4
    3b22:	00003517          	auipc	a0,0x3
    3b26:	3b650513          	addi	a0,a0,950 # 6ed8 <malloc+0x1cb8>
    3b2a:	642010ef          	jal	ra,516c <printf>
    exit(1);
    3b2e:	4505                	li	a0,1
    3b30:	200010ef          	jal	ra,4d30 <exit>
      printf("%s: write sharedfd failed\n", s);
    3b34:	85d2                	mv	a1,s4
    3b36:	00003517          	auipc	a0,0x3
    3b3a:	3ca50513          	addi	a0,a0,970 # 6f00 <malloc+0x1ce0>
    3b3e:	62e010ef          	jal	ra,516c <printf>
      exit(1);
    3b42:	4505                	li	a0,1
    3b44:	1ec010ef          	jal	ra,4d30 <exit>
    wait(&xstatus);
    3b48:	f9c40513          	addi	a0,s0,-100
    3b4c:	1ec010ef          	jal	ra,4d38 <wait>
    if(xstatus != 0)
    3b50:	f9c42983          	lw	s3,-100(s0)
    3b54:	00098563          	beqz	s3,3b5e <sharedfd+0xb6>
      exit(xstatus);
    3b58:	854e                	mv	a0,s3
    3b5a:	1d6010ef          	jal	ra,4d30 <exit>
  close(fd);
    3b5e:	854a                	mv	a0,s2
    3b60:	1f8010ef          	jal	ra,4d58 <close>
  fd = open("sharedfd", 0);
    3b64:	4581                	li	a1,0
    3b66:	00003517          	auipc	a0,0x3
    3b6a:	36250513          	addi	a0,a0,866 # 6ec8 <malloc+0x1ca8>
    3b6e:	202010ef          	jal	ra,4d70 <open>
    3b72:	8baa                	mv	s7,a0
  nc = np = 0;
    3b74:	8ace                	mv	s5,s3
  if(fd < 0){
    3b76:	02054363          	bltz	a0,3b9c <sharedfd+0xf4>
    3b7a:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    3b7e:	06300493          	li	s1,99
      if(buf[i] == 'p')
    3b82:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3b86:	4629                	li	a2,10
    3b88:	fa040593          	addi	a1,s0,-96
    3b8c:	855e                	mv	a0,s7
    3b8e:	1ba010ef          	jal	ra,4d48 <read>
    3b92:	02a05b63          	blez	a0,3bc8 <sharedfd+0x120>
    3b96:	fa040793          	addi	a5,s0,-96
    3b9a:	a839                	j	3bb8 <sharedfd+0x110>
    printf("%s: cannot open sharedfd for reading\n", s);
    3b9c:	85d2                	mv	a1,s4
    3b9e:	00003517          	auipc	a0,0x3
    3ba2:	38250513          	addi	a0,a0,898 # 6f20 <malloc+0x1d00>
    3ba6:	5c6010ef          	jal	ra,516c <printf>
    exit(1);
    3baa:	4505                	li	a0,1
    3bac:	184010ef          	jal	ra,4d30 <exit>
        nc++;
    3bb0:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    3bb2:	0785                	addi	a5,a5,1 # 6400001 <base+0x63f1349>
    3bb4:	fd2789e3          	beq	a5,s2,3b86 <sharedfd+0xde>
      if(buf[i] == 'c')
    3bb8:	0007c703          	lbu	a4,0(a5)
    3bbc:	fe970ae3          	beq	a4,s1,3bb0 <sharedfd+0x108>
      if(buf[i] == 'p')
    3bc0:	ff6719e3          	bne	a4,s6,3bb2 <sharedfd+0x10a>
        np++;
    3bc4:	2a85                	addiw	s5,s5,1
    3bc6:	b7f5                	j	3bb2 <sharedfd+0x10a>
  close(fd);
    3bc8:	855e                	mv	a0,s7
    3bca:	18e010ef          	jal	ra,4d58 <close>
  unlink("sharedfd");
    3bce:	00003517          	auipc	a0,0x3
    3bd2:	2fa50513          	addi	a0,a0,762 # 6ec8 <malloc+0x1ca8>
    3bd6:	1aa010ef          	jal	ra,4d80 <unlink>
  if(nc == N*SZ && np == N*SZ){
    3bda:	6789                	lui	a5,0x2
    3bdc:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0xea>
    3be0:	00f99763          	bne	s3,a5,3bee <sharedfd+0x146>
    3be4:	6789                	lui	a5,0x2
    3be6:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0xea>
    3bea:	00fa8c63          	beq	s5,a5,3c02 <sharedfd+0x15a>
    printf("%s: nc/np test fails\n", s);
    3bee:	85d2                	mv	a1,s4
    3bf0:	00003517          	auipc	a0,0x3
    3bf4:	35850513          	addi	a0,a0,856 # 6f48 <malloc+0x1d28>
    3bf8:	574010ef          	jal	ra,516c <printf>
    exit(1);
    3bfc:	4505                	li	a0,1
    3bfe:	132010ef          	jal	ra,4d30 <exit>
    exit(0);
    3c02:	4501                	li	a0,0
    3c04:	12c010ef          	jal	ra,4d30 <exit>

0000000000003c08 <fourfiles>:
{
    3c08:	7171                	addi	sp,sp,-176
    3c0a:	f506                	sd	ra,168(sp)
    3c0c:	f122                	sd	s0,160(sp)
    3c0e:	ed26                	sd	s1,152(sp)
    3c10:	e94a                	sd	s2,144(sp)
    3c12:	e54e                	sd	s3,136(sp)
    3c14:	e152                	sd	s4,128(sp)
    3c16:	fcd6                	sd	s5,120(sp)
    3c18:	f8da                	sd	s6,112(sp)
    3c1a:	f4de                	sd	s7,104(sp)
    3c1c:	f0e2                	sd	s8,96(sp)
    3c1e:	ece6                	sd	s9,88(sp)
    3c20:	e8ea                	sd	s10,80(sp)
    3c22:	e4ee                	sd	s11,72(sp)
    3c24:	1900                	addi	s0,sp,176
    3c26:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    3c2a:	00003797          	auipc	a5,0x3
    3c2e:	33678793          	addi	a5,a5,822 # 6f60 <malloc+0x1d40>
    3c32:	f6f43823          	sd	a5,-144(s0)
    3c36:	00003797          	auipc	a5,0x3
    3c3a:	33278793          	addi	a5,a5,818 # 6f68 <malloc+0x1d48>
    3c3e:	f6f43c23          	sd	a5,-136(s0)
    3c42:	00003797          	auipc	a5,0x3
    3c46:	32e78793          	addi	a5,a5,814 # 6f70 <malloc+0x1d50>
    3c4a:	f8f43023          	sd	a5,-128(s0)
    3c4e:	00003797          	auipc	a5,0x3
    3c52:	32a78793          	addi	a5,a5,810 # 6f78 <malloc+0x1d58>
    3c56:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    3c5a:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    3c5e:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    3c60:	4481                	li	s1,0
    3c62:	4a11                	li	s4,4
    fname = names[pi];
    3c64:	00093983          	ld	s3,0(s2)
    unlink(fname);
    3c68:	854e                	mv	a0,s3
    3c6a:	116010ef          	jal	ra,4d80 <unlink>
    pid = fork();
    3c6e:	0ba010ef          	jal	ra,4d28 <fork>
    if(pid < 0){
    3c72:	04054263          	bltz	a0,3cb6 <fourfiles+0xae>
    if(pid == 0){
    3c76:	c939                	beqz	a0,3ccc <fourfiles+0xc4>
  for(pi = 0; pi < NCHILD; pi++){
    3c78:	2485                	addiw	s1,s1,1
    3c7a:	0921                	addi	s2,s2,8
    3c7c:	ff4494e3          	bne	s1,s4,3c64 <fourfiles+0x5c>
    3c80:	4491                	li	s1,4
    wait(&xstatus);
    3c82:	f6c40513          	addi	a0,s0,-148
    3c86:	0b2010ef          	jal	ra,4d38 <wait>
    if(xstatus != 0)
    3c8a:	f6c42b03          	lw	s6,-148(s0)
    3c8e:	0a0b1a63          	bnez	s6,3d42 <fourfiles+0x13a>
  for(pi = 0; pi < NCHILD; pi++){
    3c92:	34fd                	addiw	s1,s1,-1
    3c94:	f4fd                	bnez	s1,3c82 <fourfiles+0x7a>
    3c96:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3c9a:	00008a17          	auipc	s4,0x8
    3c9e:	01ea0a13          	addi	s4,s4,30 # bcb8 <buf>
    3ca2:	00008a97          	auipc	s5,0x8
    3ca6:	017a8a93          	addi	s5,s5,23 # bcb9 <buf+0x1>
    if(total != N*SZ){
    3caa:	6d85                	lui	s11,0x1
    3cac:	770d8d93          	addi	s11,s11,1904 # 1770 <forkfork+0x4c>
  for(i = 0; i < NCHILD; i++){
    3cb0:	03400d13          	li	s10,52
    3cb4:	a8dd                	j	3daa <fourfiles+0x1a2>
      printf("%s: fork failed\n", s);
    3cb6:	f5843583          	ld	a1,-168(s0)
    3cba:	00002517          	auipc	a0,0x2
    3cbe:	f0e50513          	addi	a0,a0,-242 # 5bc8 <malloc+0x9a8>
    3cc2:	4aa010ef          	jal	ra,516c <printf>
      exit(1);
    3cc6:	4505                	li	a0,1
    3cc8:	068010ef          	jal	ra,4d30 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3ccc:	20200593          	li	a1,514
    3cd0:	854e                	mv	a0,s3
    3cd2:	09e010ef          	jal	ra,4d70 <open>
    3cd6:	892a                	mv	s2,a0
      if(fd < 0){
    3cd8:	04054163          	bltz	a0,3d1a <fourfiles+0x112>
      memset(buf, '0'+pi, SZ);
    3cdc:	1f400613          	li	a2,500
    3ce0:	0304859b          	addiw	a1,s1,48
    3ce4:	00008517          	auipc	a0,0x8
    3ce8:	fd450513          	addi	a0,a0,-44 # bcb8 <buf>
    3cec:	633000ef          	jal	ra,4b1e <memset>
    3cf0:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    3cf2:	00008997          	auipc	s3,0x8
    3cf6:	fc698993          	addi	s3,s3,-58 # bcb8 <buf>
    3cfa:	1f400613          	li	a2,500
    3cfe:	85ce                	mv	a1,s3
    3d00:	854a                	mv	a0,s2
    3d02:	04e010ef          	jal	ra,4d50 <write>
    3d06:	85aa                	mv	a1,a0
    3d08:	1f400793          	li	a5,500
    3d0c:	02f51263          	bne	a0,a5,3d30 <fourfiles+0x128>
      for(i = 0; i < N; i++){
    3d10:	34fd                	addiw	s1,s1,-1
    3d12:	f4e5                	bnez	s1,3cfa <fourfiles+0xf2>
      exit(0);
    3d14:	4501                	li	a0,0
    3d16:	01a010ef          	jal	ra,4d30 <exit>
        printf("%s: create failed\n", s);
    3d1a:	f5843583          	ld	a1,-168(s0)
    3d1e:	00002517          	auipc	a0,0x2
    3d22:	f4250513          	addi	a0,a0,-190 # 5c60 <malloc+0xa40>
    3d26:	446010ef          	jal	ra,516c <printf>
        exit(1);
    3d2a:	4505                	li	a0,1
    3d2c:	004010ef          	jal	ra,4d30 <exit>
          printf("write failed %d\n", n);
    3d30:	00003517          	auipc	a0,0x3
    3d34:	25050513          	addi	a0,a0,592 # 6f80 <malloc+0x1d60>
    3d38:	434010ef          	jal	ra,516c <printf>
          exit(1);
    3d3c:	4505                	li	a0,1
    3d3e:	7f3000ef          	jal	ra,4d30 <exit>
      exit(xstatus);
    3d42:	855a                	mv	a0,s6
    3d44:	7ed000ef          	jal	ra,4d30 <exit>
          printf("%s: wrong char\n", s);
    3d48:	f5843583          	ld	a1,-168(s0)
    3d4c:	00003517          	auipc	a0,0x3
    3d50:	24c50513          	addi	a0,a0,588 # 6f98 <malloc+0x1d78>
    3d54:	418010ef          	jal	ra,516c <printf>
          exit(1);
    3d58:	4505                	li	a0,1
    3d5a:	7d7000ef          	jal	ra,4d30 <exit>
      total += n;
    3d5e:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3d62:	660d                	lui	a2,0x3
    3d64:	85d2                	mv	a1,s4
    3d66:	854e                	mv	a0,s3
    3d68:	7e1000ef          	jal	ra,4d48 <read>
    3d6c:	02a05363          	blez	a0,3d92 <fourfiles+0x18a>
    3d70:	00008797          	auipc	a5,0x8
    3d74:	f4878793          	addi	a5,a5,-184 # bcb8 <buf>
    3d78:	fff5069b          	addiw	a3,a0,-1
    3d7c:	1682                	slli	a3,a3,0x20
    3d7e:	9281                	srli	a3,a3,0x20
    3d80:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    3d82:	0007c703          	lbu	a4,0(a5)
    3d86:	fc9711e3          	bne	a4,s1,3d48 <fourfiles+0x140>
      for(j = 0; j < n; j++){
    3d8a:	0785                	addi	a5,a5,1
    3d8c:	fed79be3          	bne	a5,a3,3d82 <fourfiles+0x17a>
    3d90:	b7f9                	j	3d5e <fourfiles+0x156>
    close(fd);
    3d92:	854e                	mv	a0,s3
    3d94:	7c5000ef          	jal	ra,4d58 <close>
    if(total != N*SZ){
    3d98:	03b91463          	bne	s2,s11,3dc0 <fourfiles+0x1b8>
    unlink(fname);
    3d9c:	8566                	mv	a0,s9
    3d9e:	7e3000ef          	jal	ra,4d80 <unlink>
  for(i = 0; i < NCHILD; i++){
    3da2:	0c21                	addi	s8,s8,8
    3da4:	2b85                	addiw	s7,s7,1
    3da6:	03ab8763          	beq	s7,s10,3dd4 <fourfiles+0x1cc>
    fname = names[i];
    3daa:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    3dae:	4581                	li	a1,0
    3db0:	8566                	mv	a0,s9
    3db2:	7bf000ef          	jal	ra,4d70 <open>
    3db6:	89aa                	mv	s3,a0
    total = 0;
    3db8:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    3dba:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3dbe:	b755                	j	3d62 <fourfiles+0x15a>
      printf("wrong length %d\n", total);
    3dc0:	85ca                	mv	a1,s2
    3dc2:	00003517          	auipc	a0,0x3
    3dc6:	1e650513          	addi	a0,a0,486 # 6fa8 <malloc+0x1d88>
    3dca:	3a2010ef          	jal	ra,516c <printf>
      exit(1);
    3dce:	4505                	li	a0,1
    3dd0:	761000ef          	jal	ra,4d30 <exit>
}
    3dd4:	70aa                	ld	ra,168(sp)
    3dd6:	740a                	ld	s0,160(sp)
    3dd8:	64ea                	ld	s1,152(sp)
    3dda:	694a                	ld	s2,144(sp)
    3ddc:	69aa                	ld	s3,136(sp)
    3dde:	6a0a                	ld	s4,128(sp)
    3de0:	7ae6                	ld	s5,120(sp)
    3de2:	7b46                	ld	s6,112(sp)
    3de4:	7ba6                	ld	s7,104(sp)
    3de6:	7c06                	ld	s8,96(sp)
    3de8:	6ce6                	ld	s9,88(sp)
    3dea:	6d46                	ld	s10,80(sp)
    3dec:	6da6                	ld	s11,72(sp)
    3dee:	614d                	addi	sp,sp,176
    3df0:	8082                	ret

0000000000003df2 <concreate>:
{
    3df2:	7135                	addi	sp,sp,-160
    3df4:	ed06                	sd	ra,152(sp)
    3df6:	e922                	sd	s0,144(sp)
    3df8:	e526                	sd	s1,136(sp)
    3dfa:	e14a                	sd	s2,128(sp)
    3dfc:	fcce                	sd	s3,120(sp)
    3dfe:	f8d2                	sd	s4,112(sp)
    3e00:	f4d6                	sd	s5,104(sp)
    3e02:	f0da                	sd	s6,96(sp)
    3e04:	ecde                	sd	s7,88(sp)
    3e06:	1100                	addi	s0,sp,160
    3e08:	89aa                	mv	s3,a0
  file[0] = 'C';
    3e0a:	04300793          	li	a5,67
    3e0e:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    3e12:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    3e16:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    3e18:	4b0d                	li	s6,3
    3e1a:	4a85                	li	s5,1
      link("C0", file);
    3e1c:	00003b97          	auipc	s7,0x3
    3e20:	1a4b8b93          	addi	s7,s7,420 # 6fc0 <malloc+0x1da0>
  for(i = 0; i < N; i++){
    3e24:	02800a13          	li	s4,40
    3e28:	a41d                	j	404e <concreate+0x25c>
      link("C0", file);
    3e2a:	fa840593          	addi	a1,s0,-88
    3e2e:	855e                	mv	a0,s7
    3e30:	761000ef          	jal	ra,4d90 <link>
    if(pid == 0) {
    3e34:	a411                	j	4038 <concreate+0x246>
    } else if(pid == 0 && (i % 5) == 1){
    3e36:	4795                	li	a5,5
    3e38:	02f9693b          	remw	s2,s2,a5
    3e3c:	4785                	li	a5,1
    3e3e:	02f90563          	beq	s2,a5,3e68 <concreate+0x76>
      fd = open(file, O_CREATE | O_RDWR);
    3e42:	20200593          	li	a1,514
    3e46:	fa840513          	addi	a0,s0,-88
    3e4a:	727000ef          	jal	ra,4d70 <open>
      if(fd < 0){
    3e4e:	1e055063          	bgez	a0,402e <concreate+0x23c>
        printf("concreate create %s failed\n", file);
    3e52:	fa840593          	addi	a1,s0,-88
    3e56:	00003517          	auipc	a0,0x3
    3e5a:	17250513          	addi	a0,a0,370 # 6fc8 <malloc+0x1da8>
    3e5e:	30e010ef          	jal	ra,516c <printf>
        exit(1);
    3e62:	4505                	li	a0,1
    3e64:	6cd000ef          	jal	ra,4d30 <exit>
      link("C0", file);
    3e68:	fa840593          	addi	a1,s0,-88
    3e6c:	00003517          	auipc	a0,0x3
    3e70:	15450513          	addi	a0,a0,340 # 6fc0 <malloc+0x1da0>
    3e74:	71d000ef          	jal	ra,4d90 <link>
      exit(0);
    3e78:	4501                	li	a0,0
    3e7a:	6b7000ef          	jal	ra,4d30 <exit>
        exit(1);
    3e7e:	4505                	li	a0,1
    3e80:	6b1000ef          	jal	ra,4d30 <exit>
  memset(fa, 0, sizeof(fa));
    3e84:	02800613          	li	a2,40
    3e88:	4581                	li	a1,0
    3e8a:	f8040513          	addi	a0,s0,-128
    3e8e:	491000ef          	jal	ra,4b1e <memset>
  fd = open(".", 0);
    3e92:	4581                	li	a1,0
    3e94:	00002517          	auipc	a0,0x2
    3e98:	b8c50513          	addi	a0,a0,-1140 # 5a20 <malloc+0x800>
    3e9c:	6d5000ef          	jal	ra,4d70 <open>
    3ea0:	892a                	mv	s2,a0
  n = 0;
    3ea2:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3ea4:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    3ea8:	02700b13          	li	s6,39
      fa[i] = 1;
    3eac:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    3eae:	4641                	li	a2,16
    3eb0:	f7040593          	addi	a1,s0,-144
    3eb4:	854a                	mv	a0,s2
    3eb6:	693000ef          	jal	ra,4d48 <read>
    3eba:	06a05a63          	blez	a0,3f2e <concreate+0x13c>
    if(de.inum == 0)
    3ebe:	f7045783          	lhu	a5,-144(s0)
    3ec2:	d7f5                	beqz	a5,3eae <concreate+0xbc>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3ec4:	f7244783          	lbu	a5,-142(s0)
    3ec8:	ff4793e3          	bne	a5,s4,3eae <concreate+0xbc>
    3ecc:	f7444783          	lbu	a5,-140(s0)
    3ed0:	fff9                	bnez	a5,3eae <concreate+0xbc>
      i = de.name[1] - '0';
    3ed2:	f7344783          	lbu	a5,-141(s0)
    3ed6:	fd07879b          	addiw	a5,a5,-48
    3eda:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    3ede:	02eb6063          	bltu	s6,a4,3efe <concreate+0x10c>
      if(fa[i]){
    3ee2:	fb070793          	addi	a5,a4,-80
    3ee6:	97a2                	add	a5,a5,s0
    3ee8:	fd07c783          	lbu	a5,-48(a5)
    3eec:	e78d                	bnez	a5,3f16 <concreate+0x124>
      fa[i] = 1;
    3eee:	fb070793          	addi	a5,a4,-80
    3ef2:	00878733          	add	a4,a5,s0
    3ef6:	fd770823          	sb	s7,-48(a4)
      n++;
    3efa:	2a85                	addiw	s5,s5,1
    3efc:	bf4d                	j	3eae <concreate+0xbc>
        printf("%s: concreate weird file %s\n", s, de.name);
    3efe:	f7240613          	addi	a2,s0,-142
    3f02:	85ce                	mv	a1,s3
    3f04:	00003517          	auipc	a0,0x3
    3f08:	0e450513          	addi	a0,a0,228 # 6fe8 <malloc+0x1dc8>
    3f0c:	260010ef          	jal	ra,516c <printf>
        exit(1);
    3f10:	4505                	li	a0,1
    3f12:	61f000ef          	jal	ra,4d30 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    3f16:	f7240613          	addi	a2,s0,-142
    3f1a:	85ce                	mv	a1,s3
    3f1c:	00003517          	auipc	a0,0x3
    3f20:	0ec50513          	addi	a0,a0,236 # 7008 <malloc+0x1de8>
    3f24:	248010ef          	jal	ra,516c <printf>
        exit(1);
    3f28:	4505                	li	a0,1
    3f2a:	607000ef          	jal	ra,4d30 <exit>
  close(fd);
    3f2e:	854a                	mv	a0,s2
    3f30:	629000ef          	jal	ra,4d58 <close>
  if(n != N){
    3f34:	02800793          	li	a5,40
    3f38:	00fa9763          	bne	s5,a5,3f46 <concreate+0x154>
    if(((i % 3) == 0 && pid == 0) ||
    3f3c:	4a8d                	li	s5,3
    3f3e:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    3f40:	02800a13          	li	s4,40
    3f44:	a079                	j	3fd2 <concreate+0x1e0>
    printf("%s: concreate not enough files in directory listing\n", s);
    3f46:	85ce                	mv	a1,s3
    3f48:	00003517          	auipc	a0,0x3
    3f4c:	0e850513          	addi	a0,a0,232 # 7030 <malloc+0x1e10>
    3f50:	21c010ef          	jal	ra,516c <printf>
    exit(1);
    3f54:	4505                	li	a0,1
    3f56:	5db000ef          	jal	ra,4d30 <exit>
      printf("%s: fork failed\n", s);
    3f5a:	85ce                	mv	a1,s3
    3f5c:	00002517          	auipc	a0,0x2
    3f60:	c6c50513          	addi	a0,a0,-916 # 5bc8 <malloc+0x9a8>
    3f64:	208010ef          	jal	ra,516c <printf>
      exit(1);
    3f68:	4505                	li	a0,1
    3f6a:	5c7000ef          	jal	ra,4d30 <exit>
      close(open(file, 0));
    3f6e:	4581                	li	a1,0
    3f70:	fa840513          	addi	a0,s0,-88
    3f74:	5fd000ef          	jal	ra,4d70 <open>
    3f78:	5e1000ef          	jal	ra,4d58 <close>
      close(open(file, 0));
    3f7c:	4581                	li	a1,0
    3f7e:	fa840513          	addi	a0,s0,-88
    3f82:	5ef000ef          	jal	ra,4d70 <open>
    3f86:	5d3000ef          	jal	ra,4d58 <close>
      close(open(file, 0));
    3f8a:	4581                	li	a1,0
    3f8c:	fa840513          	addi	a0,s0,-88
    3f90:	5e1000ef          	jal	ra,4d70 <open>
    3f94:	5c5000ef          	jal	ra,4d58 <close>
      close(open(file, 0));
    3f98:	4581                	li	a1,0
    3f9a:	fa840513          	addi	a0,s0,-88
    3f9e:	5d3000ef          	jal	ra,4d70 <open>
    3fa2:	5b7000ef          	jal	ra,4d58 <close>
      close(open(file, 0));
    3fa6:	4581                	li	a1,0
    3fa8:	fa840513          	addi	a0,s0,-88
    3fac:	5c5000ef          	jal	ra,4d70 <open>
    3fb0:	5a9000ef          	jal	ra,4d58 <close>
      close(open(file, 0));
    3fb4:	4581                	li	a1,0
    3fb6:	fa840513          	addi	a0,s0,-88
    3fba:	5b7000ef          	jal	ra,4d70 <open>
    3fbe:	59b000ef          	jal	ra,4d58 <close>
    if(pid == 0)
    3fc2:	06090363          	beqz	s2,4028 <concreate+0x236>
      wait(0);
    3fc6:	4501                	li	a0,0
    3fc8:	571000ef          	jal	ra,4d38 <wait>
  for(i = 0; i < N; i++){
    3fcc:	2485                	addiw	s1,s1,1
    3fce:	0b448963          	beq	s1,s4,4080 <concreate+0x28e>
    file[1] = '0' + i;
    3fd2:	0304879b          	addiw	a5,s1,48
    3fd6:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    3fda:	54f000ef          	jal	ra,4d28 <fork>
    3fde:	892a                	mv	s2,a0
    if(pid < 0){
    3fe0:	f6054de3          	bltz	a0,3f5a <concreate+0x168>
    if(((i % 3) == 0 && pid == 0) ||
    3fe4:	0354e73b          	remw	a4,s1,s5
    3fe8:	00a767b3          	or	a5,a4,a0
    3fec:	2781                	sext.w	a5,a5
    3fee:	d3c1                	beqz	a5,3f6e <concreate+0x17c>
    3ff0:	01671363          	bne	a4,s6,3ff6 <concreate+0x204>
       ((i % 3) == 1 && pid != 0)){
    3ff4:	fd2d                	bnez	a0,3f6e <concreate+0x17c>
      unlink(file);
    3ff6:	fa840513          	addi	a0,s0,-88
    3ffa:	587000ef          	jal	ra,4d80 <unlink>
      unlink(file);
    3ffe:	fa840513          	addi	a0,s0,-88
    4002:	57f000ef          	jal	ra,4d80 <unlink>
      unlink(file);
    4006:	fa840513          	addi	a0,s0,-88
    400a:	577000ef          	jal	ra,4d80 <unlink>
      unlink(file);
    400e:	fa840513          	addi	a0,s0,-88
    4012:	56f000ef          	jal	ra,4d80 <unlink>
      unlink(file);
    4016:	fa840513          	addi	a0,s0,-88
    401a:	567000ef          	jal	ra,4d80 <unlink>
      unlink(file);
    401e:	fa840513          	addi	a0,s0,-88
    4022:	55f000ef          	jal	ra,4d80 <unlink>
    4026:	bf71                	j	3fc2 <concreate+0x1d0>
      exit(0);
    4028:	4501                	li	a0,0
    402a:	507000ef          	jal	ra,4d30 <exit>
      close(fd);
    402e:	52b000ef          	jal	ra,4d58 <close>
    if(pid == 0) {
    4032:	b599                	j	3e78 <concreate+0x86>
      close(fd);
    4034:	525000ef          	jal	ra,4d58 <close>
      wait(&xstatus);
    4038:	f6c40513          	addi	a0,s0,-148
    403c:	4fd000ef          	jal	ra,4d38 <wait>
      if(xstatus != 0)
    4040:	f6c42483          	lw	s1,-148(s0)
    4044:	e2049de3          	bnez	s1,3e7e <concreate+0x8c>
  for(i = 0; i < N; i++){
    4048:	2905                	addiw	s2,s2,1
    404a:	e3490de3          	beq	s2,s4,3e84 <concreate+0x92>
    file[1] = '0' + i;
    404e:	0309079b          	addiw	a5,s2,48
    4052:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4056:	fa840513          	addi	a0,s0,-88
    405a:	527000ef          	jal	ra,4d80 <unlink>
    pid = fork();
    405e:	4cb000ef          	jal	ra,4d28 <fork>
    if(pid && (i % 3) == 1){
    4062:	dc050ae3          	beqz	a0,3e36 <concreate+0x44>
    4066:	036967bb          	remw	a5,s2,s6
    406a:	dd5780e3          	beq	a5,s5,3e2a <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    406e:	20200593          	li	a1,514
    4072:	fa840513          	addi	a0,s0,-88
    4076:	4fb000ef          	jal	ra,4d70 <open>
      if(fd < 0){
    407a:	fa055de3          	bgez	a0,4034 <concreate+0x242>
    407e:	bbd1                	j	3e52 <concreate+0x60>
}
    4080:	60ea                	ld	ra,152(sp)
    4082:	644a                	ld	s0,144(sp)
    4084:	64aa                	ld	s1,136(sp)
    4086:	690a                	ld	s2,128(sp)
    4088:	79e6                	ld	s3,120(sp)
    408a:	7a46                	ld	s4,112(sp)
    408c:	7aa6                	ld	s5,104(sp)
    408e:	7b06                	ld	s6,96(sp)
    4090:	6be6                	ld	s7,88(sp)
    4092:	610d                	addi	sp,sp,160
    4094:	8082                	ret

0000000000004096 <bigfile>:
{
    4096:	7139                	addi	sp,sp,-64
    4098:	fc06                	sd	ra,56(sp)
    409a:	f822                	sd	s0,48(sp)
    409c:	f426                	sd	s1,40(sp)
    409e:	f04a                	sd	s2,32(sp)
    40a0:	ec4e                	sd	s3,24(sp)
    40a2:	e852                	sd	s4,16(sp)
    40a4:	e456                	sd	s5,8(sp)
    40a6:	0080                	addi	s0,sp,64
    40a8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    40aa:	00003517          	auipc	a0,0x3
    40ae:	fbe50513          	addi	a0,a0,-66 # 7068 <malloc+0x1e48>
    40b2:	4cf000ef          	jal	ra,4d80 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    40b6:	20200593          	li	a1,514
    40ba:	00003517          	auipc	a0,0x3
    40be:	fae50513          	addi	a0,a0,-82 # 7068 <malloc+0x1e48>
    40c2:	4af000ef          	jal	ra,4d70 <open>
    40c6:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    40c8:	4481                	li	s1,0
    memset(buf, i, SZ);
    40ca:	00008917          	auipc	s2,0x8
    40ce:	bee90913          	addi	s2,s2,-1042 # bcb8 <buf>
  for(i = 0; i < N; i++){
    40d2:	4a51                	li	s4,20
  if(fd < 0){
    40d4:	08054663          	bltz	a0,4160 <bigfile+0xca>
    memset(buf, i, SZ);
    40d8:	25800613          	li	a2,600
    40dc:	85a6                	mv	a1,s1
    40de:	854a                	mv	a0,s2
    40e0:	23f000ef          	jal	ra,4b1e <memset>
    if(write(fd, buf, SZ) != SZ){
    40e4:	25800613          	li	a2,600
    40e8:	85ca                	mv	a1,s2
    40ea:	854e                	mv	a0,s3
    40ec:	465000ef          	jal	ra,4d50 <write>
    40f0:	25800793          	li	a5,600
    40f4:	08f51063          	bne	a0,a5,4174 <bigfile+0xde>
  for(i = 0; i < N; i++){
    40f8:	2485                	addiw	s1,s1,1
    40fa:	fd449fe3          	bne	s1,s4,40d8 <bigfile+0x42>
  close(fd);
    40fe:	854e                	mv	a0,s3
    4100:	459000ef          	jal	ra,4d58 <close>
  fd = open("bigfile.dat", 0);
    4104:	4581                	li	a1,0
    4106:	00003517          	auipc	a0,0x3
    410a:	f6250513          	addi	a0,a0,-158 # 7068 <malloc+0x1e48>
    410e:	463000ef          	jal	ra,4d70 <open>
    4112:	8a2a                	mv	s4,a0
  total = 0;
    4114:	4981                	li	s3,0
  for(i = 0; ; i++){
    4116:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4118:	00008917          	auipc	s2,0x8
    411c:	ba090913          	addi	s2,s2,-1120 # bcb8 <buf>
  if(fd < 0){
    4120:	06054463          	bltz	a0,4188 <bigfile+0xf2>
    cc = read(fd, buf, SZ/2);
    4124:	12c00613          	li	a2,300
    4128:	85ca                	mv	a1,s2
    412a:	8552                	mv	a0,s4
    412c:	41d000ef          	jal	ra,4d48 <read>
    if(cc < 0){
    4130:	06054663          	bltz	a0,419c <bigfile+0x106>
    if(cc == 0)
    4134:	c155                	beqz	a0,41d8 <bigfile+0x142>
    if(cc != SZ/2){
    4136:	12c00793          	li	a5,300
    413a:	06f51b63          	bne	a0,a5,41b0 <bigfile+0x11a>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    413e:	01f4d79b          	srliw	a5,s1,0x1f
    4142:	9fa5                	addw	a5,a5,s1
    4144:	4017d79b          	sraiw	a5,a5,0x1
    4148:	00094703          	lbu	a4,0(s2)
    414c:	06f71c63          	bne	a4,a5,41c4 <bigfile+0x12e>
    4150:	12b94703          	lbu	a4,299(s2)
    4154:	06f71863          	bne	a4,a5,41c4 <bigfile+0x12e>
    total += cc;
    4158:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    415c:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    415e:	b7d9                	j	4124 <bigfile+0x8e>
    printf("%s: cannot create bigfile", s);
    4160:	85d6                	mv	a1,s5
    4162:	00003517          	auipc	a0,0x3
    4166:	f1650513          	addi	a0,a0,-234 # 7078 <malloc+0x1e58>
    416a:	002010ef          	jal	ra,516c <printf>
    exit(1);
    416e:	4505                	li	a0,1
    4170:	3c1000ef          	jal	ra,4d30 <exit>
      printf("%s: write bigfile failed\n", s);
    4174:	85d6                	mv	a1,s5
    4176:	00003517          	auipc	a0,0x3
    417a:	f2250513          	addi	a0,a0,-222 # 7098 <malloc+0x1e78>
    417e:	7ef000ef          	jal	ra,516c <printf>
      exit(1);
    4182:	4505                	li	a0,1
    4184:	3ad000ef          	jal	ra,4d30 <exit>
    printf("%s: cannot open bigfile\n", s);
    4188:	85d6                	mv	a1,s5
    418a:	00003517          	auipc	a0,0x3
    418e:	f2e50513          	addi	a0,a0,-210 # 70b8 <malloc+0x1e98>
    4192:	7db000ef          	jal	ra,516c <printf>
    exit(1);
    4196:	4505                	li	a0,1
    4198:	399000ef          	jal	ra,4d30 <exit>
      printf("%s: read bigfile failed\n", s);
    419c:	85d6                	mv	a1,s5
    419e:	00003517          	auipc	a0,0x3
    41a2:	f3a50513          	addi	a0,a0,-198 # 70d8 <malloc+0x1eb8>
    41a6:	7c7000ef          	jal	ra,516c <printf>
      exit(1);
    41aa:	4505                	li	a0,1
    41ac:	385000ef          	jal	ra,4d30 <exit>
      printf("%s: short read bigfile\n", s);
    41b0:	85d6                	mv	a1,s5
    41b2:	00003517          	auipc	a0,0x3
    41b6:	f4650513          	addi	a0,a0,-186 # 70f8 <malloc+0x1ed8>
    41ba:	7b3000ef          	jal	ra,516c <printf>
      exit(1);
    41be:	4505                	li	a0,1
    41c0:	371000ef          	jal	ra,4d30 <exit>
      printf("%s: read bigfile wrong data\n", s);
    41c4:	85d6                	mv	a1,s5
    41c6:	00003517          	auipc	a0,0x3
    41ca:	f4a50513          	addi	a0,a0,-182 # 7110 <malloc+0x1ef0>
    41ce:	79f000ef          	jal	ra,516c <printf>
      exit(1);
    41d2:	4505                	li	a0,1
    41d4:	35d000ef          	jal	ra,4d30 <exit>
  close(fd);
    41d8:	8552                	mv	a0,s4
    41da:	37f000ef          	jal	ra,4d58 <close>
  if(total != N*SZ){
    41de:	678d                	lui	a5,0x3
    41e0:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x372>
    41e4:	02f99163          	bne	s3,a5,4206 <bigfile+0x170>
  unlink("bigfile.dat");
    41e8:	00003517          	auipc	a0,0x3
    41ec:	e8050513          	addi	a0,a0,-384 # 7068 <malloc+0x1e48>
    41f0:	391000ef          	jal	ra,4d80 <unlink>
}
    41f4:	70e2                	ld	ra,56(sp)
    41f6:	7442                	ld	s0,48(sp)
    41f8:	74a2                	ld	s1,40(sp)
    41fa:	7902                	ld	s2,32(sp)
    41fc:	69e2                	ld	s3,24(sp)
    41fe:	6a42                	ld	s4,16(sp)
    4200:	6aa2                	ld	s5,8(sp)
    4202:	6121                	addi	sp,sp,64
    4204:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4206:	85d6                	mv	a1,s5
    4208:	00003517          	auipc	a0,0x3
    420c:	f2850513          	addi	a0,a0,-216 # 7130 <malloc+0x1f10>
    4210:	75d000ef          	jal	ra,516c <printf>
    exit(1);
    4214:	4505                	li	a0,1
    4216:	31b000ef          	jal	ra,4d30 <exit>

000000000000421a <bigargtest>:
{
    421a:	7121                	addi	sp,sp,-448
    421c:	ff06                	sd	ra,440(sp)
    421e:	fb22                	sd	s0,432(sp)
    4220:	f726                	sd	s1,424(sp)
    4222:	0380                	addi	s0,sp,448
    4224:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    4226:	00003517          	auipc	a0,0x3
    422a:	f2a50513          	addi	a0,a0,-214 # 7150 <malloc+0x1f30>
    422e:	353000ef          	jal	ra,4d80 <unlink>
  pid = fork();
    4232:	2f7000ef          	jal	ra,4d28 <fork>
  if(pid == 0){
    4236:	c915                	beqz	a0,426a <bigargtest+0x50>
  } else if(pid < 0){
    4238:	08054a63          	bltz	a0,42cc <bigargtest+0xb2>
  wait(&xstatus);
    423c:	fdc40513          	addi	a0,s0,-36
    4240:	2f9000ef          	jal	ra,4d38 <wait>
  if(xstatus != 0)
    4244:	fdc42503          	lw	a0,-36(s0)
    4248:	ed41                	bnez	a0,42e0 <bigargtest+0xc6>
  fd = open("bigarg-ok", 0);
    424a:	4581                	li	a1,0
    424c:	00003517          	auipc	a0,0x3
    4250:	f0450513          	addi	a0,a0,-252 # 7150 <malloc+0x1f30>
    4254:	31d000ef          	jal	ra,4d70 <open>
  if(fd < 0){
    4258:	08054663          	bltz	a0,42e4 <bigargtest+0xca>
  close(fd);
    425c:	2fd000ef          	jal	ra,4d58 <close>
}
    4260:	70fa                	ld	ra,440(sp)
    4262:	745a                	ld	s0,432(sp)
    4264:	74ba                	ld	s1,424(sp)
    4266:	6139                	addi	sp,sp,448
    4268:	8082                	ret
    memset(big, ' ', sizeof(big));
    426a:	19000613          	li	a2,400
    426e:	02000593          	li	a1,32
    4272:	e4840513          	addi	a0,s0,-440
    4276:	0a9000ef          	jal	ra,4b1e <memset>
    big[sizeof(big)-1] = '\0';
    427a:	fc040ba3          	sb	zero,-41(s0)
    for(i = 0; i < MAXARG-1; i++)
    427e:	00004797          	auipc	a5,0x4
    4282:	22278793          	addi	a5,a5,546 # 84a0 <args.1>
    4286:	00004697          	auipc	a3,0x4
    428a:	31268693          	addi	a3,a3,786 # 8598 <args.1+0xf8>
      args[i] = big;
    428e:	e4840713          	addi	a4,s0,-440
    4292:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    4294:	07a1                	addi	a5,a5,8
    4296:	fed79ee3          	bne	a5,a3,4292 <bigargtest+0x78>
    args[MAXARG-1] = 0;
    429a:	00004597          	auipc	a1,0x4
    429e:	20658593          	addi	a1,a1,518 # 84a0 <args.1>
    42a2:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    42a6:	00001517          	auipc	a0,0x1
    42aa:	09250513          	addi	a0,a0,146 # 5338 <malloc+0x118>
    42ae:	2bb000ef          	jal	ra,4d68 <exec>
    fd = open("bigarg-ok", O_CREATE);
    42b2:	20000593          	li	a1,512
    42b6:	00003517          	auipc	a0,0x3
    42ba:	e9a50513          	addi	a0,a0,-358 # 7150 <malloc+0x1f30>
    42be:	2b3000ef          	jal	ra,4d70 <open>
    close(fd);
    42c2:	297000ef          	jal	ra,4d58 <close>
    exit(0);
    42c6:	4501                	li	a0,0
    42c8:	269000ef          	jal	ra,4d30 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    42cc:	85a6                	mv	a1,s1
    42ce:	00003517          	auipc	a0,0x3
    42d2:	e9250513          	addi	a0,a0,-366 # 7160 <malloc+0x1f40>
    42d6:	697000ef          	jal	ra,516c <printf>
    exit(1);
    42da:	4505                	li	a0,1
    42dc:	255000ef          	jal	ra,4d30 <exit>
    exit(xstatus);
    42e0:	251000ef          	jal	ra,4d30 <exit>
    printf("%s: bigarg test failed!\n", s);
    42e4:	85a6                	mv	a1,s1
    42e6:	00003517          	auipc	a0,0x3
    42ea:	e9a50513          	addi	a0,a0,-358 # 7180 <malloc+0x1f60>
    42ee:	67f000ef          	jal	ra,516c <printf>
    exit(1);
    42f2:	4505                	li	a0,1
    42f4:	23d000ef          	jal	ra,4d30 <exit>

00000000000042f8 <lazy_alloc>:
{
    42f8:	1141                	addi	sp,sp,-16
    42fa:	e406                	sd	ra,8(sp)
    42fc:	e022                	sd	s0,0(sp)
    42fe:	0800                	addi	s0,sp,16
  prev_end = sbrklazy(REGION_SZ);
    4300:	40000537          	lui	a0,0x40000
    4304:	20f000ef          	jal	ra,4d12 <sbrklazy>
  if (prev_end == (char *) SBRK_ERROR) {
    4308:	57fd                	li	a5,-1
    430a:	02f50a63          	beq	a0,a5,433e <lazy_alloc+0x46>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    430e:	6605                	lui	a2,0x1
    4310:	962a                	add	a2,a2,a0
    4312:	400017b7          	lui	a5,0x40001
    4316:	00f50733          	add	a4,a0,a5
    431a:	87b2                	mv	a5,a2
    431c:	000406b7          	lui	a3,0x40
    *(char **)i = i;
    4320:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    4322:	97b6                	add	a5,a5,a3
    4324:	fee79ee3          	bne	a5,a4,4320 <lazy_alloc+0x28>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4328:	000406b7          	lui	a3,0x40
    if (*(char **)i != i) {
    432c:	621c                	ld	a5,0(a2)
    432e:	02c79163          	bne	a5,a2,4350 <lazy_alloc+0x58>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4332:	9636                	add	a2,a2,a3
    4334:	fee61ce3          	bne	a2,a4,432c <lazy_alloc+0x34>
  exit(0);
    4338:	4501                	li	a0,0
    433a:	1f7000ef          	jal	ra,4d30 <exit>
    printf("sbrklazy() failed\n");
    433e:	00003517          	auipc	a0,0x3
    4342:	e6250513          	addi	a0,a0,-414 # 71a0 <malloc+0x1f80>
    4346:	627000ef          	jal	ra,516c <printf>
    exit(1);
    434a:	4505                	li	a0,1
    434c:	1e5000ef          	jal	ra,4d30 <exit>
      printf("failed to read value from memory\n");
    4350:	00003517          	auipc	a0,0x3
    4354:	e6850513          	addi	a0,a0,-408 # 71b8 <malloc+0x1f98>
    4358:	615000ef          	jal	ra,516c <printf>
      exit(1);
    435c:	4505                	li	a0,1
    435e:	1d3000ef          	jal	ra,4d30 <exit>

0000000000004362 <lazy_unmap>:
{
    4362:	7139                	addi	sp,sp,-64
    4364:	fc06                	sd	ra,56(sp)
    4366:	f822                	sd	s0,48(sp)
    4368:	f426                	sd	s1,40(sp)
    436a:	f04a                	sd	s2,32(sp)
    436c:	ec4e                	sd	s3,24(sp)
    436e:	0080                	addi	s0,sp,64
  prev_end = sbrklazy(REGION_SZ);
    4370:	40000537          	lui	a0,0x40000
    4374:	19f000ef          	jal	ra,4d12 <sbrklazy>
  if (prev_end == (char*)SBRK_ERROR) {
    4378:	57fd                	li	a5,-1
    437a:	04f50363          	beq	a0,a5,43c0 <lazy_unmap+0x5e>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    437e:	6905                	lui	s2,0x1
    4380:	992a                	add	s2,s2,a0
    4382:	400017b7          	lui	a5,0x40001
    4386:	00f504b3          	add	s1,a0,a5
    438a:	87ca                	mv	a5,s2
    438c:	01000737          	lui	a4,0x1000
    *(char **)i = i;
    4390:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    4392:	97ba                	add	a5,a5,a4
    4394:	fef49ee3          	bne	s1,a5,4390 <lazy_unmap+0x2e>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4398:	010009b7          	lui	s3,0x1000
    pid = fork();
    439c:	18d000ef          	jal	ra,4d28 <fork>
    if (pid < 0) {
    43a0:	02054963          	bltz	a0,43d2 <lazy_unmap+0x70>
    } else if (pid == 0) {
    43a4:	c121                	beqz	a0,43e4 <lazy_unmap+0x82>
      wait(&status);
    43a6:	fcc40513          	addi	a0,s0,-52
    43aa:	18f000ef          	jal	ra,4d38 <wait>
      if (status == 0) {
    43ae:	fcc42783          	lw	a5,-52(s0)
    43b2:	c3b1                	beqz	a5,43f6 <lazy_unmap+0x94>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    43b4:	994e                	add	s2,s2,s3
    43b6:	ff2493e3          	bne	s1,s2,439c <lazy_unmap+0x3a>
  exit(0);
    43ba:	4501                	li	a0,0
    43bc:	175000ef          	jal	ra,4d30 <exit>
    printf("sbrklazy() failed\n");
    43c0:	00003517          	auipc	a0,0x3
    43c4:	de050513          	addi	a0,a0,-544 # 71a0 <malloc+0x1f80>
    43c8:	5a5000ef          	jal	ra,516c <printf>
    exit(1);
    43cc:	4505                	li	a0,1
    43ce:	163000ef          	jal	ra,4d30 <exit>
      printf("error forking\n");
    43d2:	00003517          	auipc	a0,0x3
    43d6:	e0e50513          	addi	a0,a0,-498 # 71e0 <malloc+0x1fc0>
    43da:	593000ef          	jal	ra,516c <printf>
      exit(1);
    43de:	4505                	li	a0,1
    43e0:	151000ef          	jal	ra,4d30 <exit>
      sbrklazy(-1L * REGION_SZ);
    43e4:	c0000537          	lui	a0,0xc0000
    43e8:	12b000ef          	jal	ra,4d12 <sbrklazy>
      *(char **)i = i;
    43ec:	01293023          	sd	s2,0(s2) # 1000 <badarg>
      exit(0);
    43f0:	4501                	li	a0,0
    43f2:	13f000ef          	jal	ra,4d30 <exit>
        printf("memory not unmapped\n");
    43f6:	00003517          	auipc	a0,0x3
    43fa:	dfa50513          	addi	a0,a0,-518 # 71f0 <malloc+0x1fd0>
    43fe:	56f000ef          	jal	ra,516c <printf>
        exit(1);
    4402:	4505                	li	a0,1
    4404:	12d000ef          	jal	ra,4d30 <exit>

0000000000004408 <lazy_copy>:
{
    4408:	7159                	addi	sp,sp,-112
    440a:	f486                	sd	ra,104(sp)
    440c:	f0a2                	sd	s0,96(sp)
    440e:	eca6                	sd	s1,88(sp)
    4410:	e8ca                	sd	s2,80(sp)
    4412:	e4ce                	sd	s3,72(sp)
    4414:	e0d2                	sd	s4,64(sp)
    4416:	fc56                	sd	s5,56(sp)
    4418:	f85a                	sd	s6,48(sp)
    441a:	1880                	addi	s0,sp,112
    char *p = sbrk(0);
    441c:	4501                	li	a0,0
    441e:	0df000ef          	jal	ra,4cfc <sbrk>
    4422:	84aa                	mv	s1,a0
    sbrklazy(4*PGSIZE);
    4424:	6511                	lui	a0,0x4
    4426:	0ed000ef          	jal	ra,4d12 <sbrklazy>
    open(p + 8192, 0);
    442a:	4581                	li	a1,0
    442c:	6509                	lui	a0,0x2
    442e:	9526                	add	a0,a0,s1
    4430:	141000ef          	jal	ra,4d70 <open>
    void *xx = sbrk(0);
    4434:	4501                	li	a0,0
    4436:	0c7000ef          	jal	ra,4cfc <sbrk>
    443a:	84aa                	mv	s1,a0
    void *ret = sbrk(-(((uint64) xx)+1));
    443c:	fff54513          	not	a0,a0
    4440:	2501                	sext.w	a0,a0
    4442:	0bb000ef          	jal	ra,4cfc <sbrk>
    if(ret != xx){
    4446:	00a48c63          	beq	s1,a0,445e <lazy_copy+0x56>
    444a:	85aa                	mv	a1,a0
      printf("sbrk(sbrk(0)+1) returned %p, not old sz\n", ret);
    444c:	00003517          	auipc	a0,0x3
    4450:	dbc50513          	addi	a0,a0,-580 # 7208 <malloc+0x1fe8>
    4454:	519000ef          	jal	ra,516c <printf>
      exit(1);
    4458:	4505                	li	a0,1
    445a:	0d7000ef          	jal	ra,4d30 <exit>
  unsigned long bad[] = {
    445e:	00003797          	auipc	a5,0x3
    4462:	41a78793          	addi	a5,a5,1050 # 7878 <malloc+0x2658>
    4466:	7fa8                	ld	a0,120(a5)
    4468:	63cc                	ld	a1,128(a5)
    446a:	67d0                	ld	a2,136(a5)
    446c:	6bd4                	ld	a3,144(a5)
    446e:	6fd8                	ld	a4,152(a5)
    4470:	73dc                	ld	a5,160(a5)
    4472:	f8a43823          	sd	a0,-112(s0)
    4476:	f8b43c23          	sd	a1,-104(s0)
    447a:	fac43023          	sd	a2,-96(s0)
    447e:	fad43423          	sd	a3,-88(s0)
    4482:	fae43823          	sd	a4,-80(s0)
    4486:	faf43c23          	sd	a5,-72(s0)
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    448a:	f9040913          	addi	s2,s0,-112
    448e:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
    4492:	00001a17          	auipc	s4,0x1
    4496:	07ea0a13          	addi	s4,s4,126 # 5510 <malloc+0x2f0>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    449a:	00001a97          	auipc	s5,0x1
    449e:	f86a8a93          	addi	s5,s5,-122 # 5420 <malloc+0x200>
    int fd = open("README", 0);
    44a2:	4581                	li	a1,0
    44a4:	8552                	mv	a0,s4
    44a6:	0cb000ef          	jal	ra,4d70 <open>
    44aa:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    44ac:	04054663          	bltz	a0,44f8 <lazy_copy+0xf0>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    44b0:	00093983          	ld	s3,0(s2)
    44b4:	20000613          	li	a2,512
    44b8:	85ce                	mv	a1,s3
    44ba:	08f000ef          	jal	ra,4d48 <read>
    44be:	04055663          	bgez	a0,450a <lazy_copy+0x102>
    close(fd);
    44c2:	8526                	mv	a0,s1
    44c4:	095000ef          	jal	ra,4d58 <close>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    44c8:	60200593          	li	a1,1538
    44cc:	8556                	mv	a0,s5
    44ce:	0a3000ef          	jal	ra,4d70 <open>
    44d2:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    44d4:	04054463          	bltz	a0,451c <lazy_copy+0x114>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    44d8:	20000613          	li	a2,512
    44dc:	85ce                	mv	a1,s3
    44de:	073000ef          	jal	ra,4d50 <write>
    44e2:	04055663          	bgez	a0,452e <lazy_copy+0x126>
    close(fd);
    44e6:	8526                	mv	a0,s1
    44e8:	071000ef          	jal	ra,4d58 <close>
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    44ec:	0921                	addi	s2,s2,8
    44ee:	fb691ae3          	bne	s2,s6,44a2 <lazy_copy+0x9a>
  exit(0);
    44f2:	4501                	li	a0,0
    44f4:	03d000ef          	jal	ra,4d30 <exit>
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    44f8:	00003517          	auipc	a0,0x3
    44fc:	d4050513          	addi	a0,a0,-704 # 7238 <malloc+0x2018>
    4500:	46d000ef          	jal	ra,516c <printf>
    4504:	4505                	li	a0,1
    4506:	02b000ef          	jal	ra,4d30 <exit>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    450a:	00003517          	auipc	a0,0x3
    450e:	d4650513          	addi	a0,a0,-698 # 7250 <malloc+0x2030>
    4512:	45b000ef          	jal	ra,516c <printf>
    4516:	4505                	li	a0,1
    4518:	019000ef          	jal	ra,4d30 <exit>
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    451c:	00003517          	auipc	a0,0x3
    4520:	d4450513          	addi	a0,a0,-700 # 7260 <malloc+0x2040>
    4524:	449000ef          	jal	ra,516c <printf>
    4528:	4505                	li	a0,1
    452a:	007000ef          	jal	ra,4d30 <exit>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    452e:	00003517          	auipc	a0,0x3
    4532:	d4a50513          	addi	a0,a0,-694 # 7278 <malloc+0x2058>
    4536:	437000ef          	jal	ra,516c <printf>
    453a:	4505                	li	a0,1
    453c:	7f4000ef          	jal	ra,4d30 <exit>

0000000000004540 <lazy_sbrk>:
{
    4540:	1101                	addi	sp,sp,-32
    4542:	ec06                	sd	ra,24(sp)
    4544:	e822                	sd	s0,16(sp)
    4546:	e426                	sd	s1,8(sp)
    4548:	e04a                	sd	s2,0(sp)
    454a:	1000                	addi	s0,sp,32
  char *p = sbrk(0);
    454c:	4501                	li	a0,0
    454e:	7ae000ef          	jal	ra,4cfc <sbrk>
    4552:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA-(1<<30)) {
    4554:	0ff00793          	li	a5,255
    4558:	07fa                	slli	a5,a5,0x1e
    455a:	00f57d63          	bgeu	a0,a5,4574 <lazy_sbrk+0x34>
    455e:	893e                	mv	s2,a5
    p = sbrklazy(1<<30);
    4560:	40000537          	lui	a0,0x40000
    4564:	7ae000ef          	jal	ra,4d12 <sbrklazy>
    p = sbrklazy(0);
    4568:	4501                	li	a0,0
    456a:	7a8000ef          	jal	ra,4d12 <sbrklazy>
    456e:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA-(1<<30)) {
    4570:	ff2568e3          	bltu	a0,s2,4560 <lazy_sbrk+0x20>
  int n = TRAPFRAME-PGSIZE-(uint64)p;
    4574:	7975                	lui	s2,0xffffd
    4576:	4099093b          	subw	s2,s2,s1
  char *p1 = sbrklazy(n);
    457a:	854a                	mv	a0,s2
    457c:	796000ef          	jal	ra,4d12 <sbrklazy>
    4580:	862a                	mv	a2,a0
  if (p1 < 0 || p1 != p) {
    4582:	00950d63          	beq	a0,s1,459c <lazy_sbrk+0x5c>
    printf("sbrklazy(%d) returned %p, not expected %p\n", n, p1, p);
    4586:	86a6                	mv	a3,s1
    4588:	85ca                	mv	a1,s2
    458a:	00003517          	auipc	a0,0x3
    458e:	d0650513          	addi	a0,a0,-762 # 7290 <malloc+0x2070>
    4592:	3db000ef          	jal	ra,516c <printf>
    exit(1);
    4596:	4505                	li	a0,1
    4598:	798000ef          	jal	ra,4d30 <exit>
  p = sbrk(PGSIZE);
    459c:	6505                	lui	a0,0x1
    459e:	75e000ef          	jal	ra,4cfc <sbrk>
    45a2:	862a                	mv	a2,a0
  if (p < 0 || (uint64)p != TRAPFRAME-PGSIZE) {
    45a4:	040007b7          	lui	a5,0x4000
    45a8:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff1345>
    45aa:	07b2                	slli	a5,a5,0xc
    45ac:	00f50c63          	beq	a0,a5,45c4 <lazy_sbrk+0x84>
    printf("sbrk(%d) returned %p, not expected TRAPFRAME-PGSIZE\n", PGSIZE, p);
    45b0:	6585                	lui	a1,0x1
    45b2:	00003517          	auipc	a0,0x3
    45b6:	d0e50513          	addi	a0,a0,-754 # 72c0 <malloc+0x20a0>
    45ba:	3b3000ef          	jal	ra,516c <printf>
    exit(1);
    45be:	4505                	li	a0,1
    45c0:	770000ef          	jal	ra,4d30 <exit>
  p[0] = 1;
    45c4:	040007b7          	lui	a5,0x4000
    45c8:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff1345>
    45ca:	07b2                	slli	a5,a5,0xc
    45cc:	4705                	li	a4,1
    45ce:	00e78023          	sb	a4,0(a5)
  if (p[1] != 0) {
    45d2:	0017c783          	lbu	a5,1(a5)
    45d6:	cb91                	beqz	a5,45ea <lazy_sbrk+0xaa>
    printf("sbrk() returned non-zero-filled memory\n");
    45d8:	00003517          	auipc	a0,0x3
    45dc:	d2050513          	addi	a0,a0,-736 # 72f8 <malloc+0x20d8>
    45e0:	38d000ef          	jal	ra,516c <printf>
    exit(1);
    45e4:	4505                	li	a0,1
    45e6:	74a000ef          	jal	ra,4d30 <exit>
  p = sbrk(1);
    45ea:	4505                	li	a0,1
    45ec:	710000ef          	jal	ra,4cfc <sbrk>
    45f0:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    45f2:	57fd                	li	a5,-1
    45f4:	00f50b63          	beq	a0,a5,460a <lazy_sbrk+0xca>
    printf("sbrk(1) returned %p, expected error\n", p);
    45f8:	00003517          	auipc	a0,0x3
    45fc:	d2850513          	addi	a0,a0,-728 # 7320 <malloc+0x2100>
    4600:	36d000ef          	jal	ra,516c <printf>
    exit(1);
    4604:	4505                	li	a0,1
    4606:	72a000ef          	jal	ra,4d30 <exit>
  p = sbrklazy(1);
    460a:	4505                	li	a0,1
    460c:	706000ef          	jal	ra,4d12 <sbrklazy>
    4610:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4612:	57fd                	li	a5,-1
    4614:	00f50b63          	beq	a0,a5,462a <lazy_sbrk+0xea>
    printf("sbrklazy(1) returned %p, expected error\n", p);
    4618:	00003517          	auipc	a0,0x3
    461c:	d3050513          	addi	a0,a0,-720 # 7348 <malloc+0x2128>
    4620:	34d000ef          	jal	ra,516c <printf>
    exit(1);
    4624:	4505                	li	a0,1
    4626:	70a000ef          	jal	ra,4d30 <exit>
  exit(0);
    462a:	4501                	li	a0,0
    462c:	704000ef          	jal	ra,4d30 <exit>

0000000000004630 <fsfull>:
{
    4630:	7171                	addi	sp,sp,-176
    4632:	f506                	sd	ra,168(sp)
    4634:	f122                	sd	s0,160(sp)
    4636:	ed26                	sd	s1,152(sp)
    4638:	e94a                	sd	s2,144(sp)
    463a:	e54e                	sd	s3,136(sp)
    463c:	e152                	sd	s4,128(sp)
    463e:	fcd6                	sd	s5,120(sp)
    4640:	f8da                	sd	s6,112(sp)
    4642:	f4de                	sd	s7,104(sp)
    4644:	f0e2                	sd	s8,96(sp)
    4646:	ece6                	sd	s9,88(sp)
    4648:	e8ea                	sd	s10,80(sp)
    464a:	e4ee                	sd	s11,72(sp)
    464c:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    464e:	00003517          	auipc	a0,0x3
    4652:	d2a50513          	addi	a0,a0,-726 # 7378 <malloc+0x2158>
    4656:	317000ef          	jal	ra,516c <printf>
  for(nfiles = 0; ; nfiles++){
    465a:	4481                	li	s1,0
    name[0] = 'f';
    465c:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4660:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4664:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4668:	4b29                	li	s6,10
    printf("writing %s\n", name);
    466a:	00003c97          	auipc	s9,0x3
    466e:	d1ec8c93          	addi	s9,s9,-738 # 7388 <malloc+0x2168>
    int total = 0;
    4672:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4674:	00007a17          	auipc	s4,0x7
    4678:	644a0a13          	addi	s4,s4,1604 # bcb8 <buf>
    name[0] = 'f';
    467c:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4680:	0384c7bb          	divw	a5,s1,s8
    4684:	0307879b          	addiw	a5,a5,48
    4688:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    468c:	0384e7bb          	remw	a5,s1,s8
    4690:	0377c7bb          	divw	a5,a5,s7
    4694:	0307879b          	addiw	a5,a5,48
    4698:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    469c:	0374e7bb          	remw	a5,s1,s7
    46a0:	0367c7bb          	divw	a5,a5,s6
    46a4:	0307879b          	addiw	a5,a5,48
    46a8:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    46ac:	0364e7bb          	remw	a5,s1,s6
    46b0:	0307879b          	addiw	a5,a5,48
    46b4:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    46b8:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    46bc:	f5040593          	addi	a1,s0,-176
    46c0:	8566                	mv	a0,s9
    46c2:	2ab000ef          	jal	ra,516c <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    46c6:	20200593          	li	a1,514
    46ca:	f5040513          	addi	a0,s0,-176
    46ce:	6a2000ef          	jal	ra,4d70 <open>
    46d2:	892a                	mv	s2,a0
    if(fd < 0){
    46d4:	0a055063          	bgez	a0,4774 <fsfull+0x144>
      printf("open %s failed\n", name);
    46d8:	f5040593          	addi	a1,s0,-176
    46dc:	00003517          	auipc	a0,0x3
    46e0:	cbc50513          	addi	a0,a0,-836 # 7398 <malloc+0x2178>
    46e4:	289000ef          	jal	ra,516c <printf>
  while(nfiles >= 0){
    46e8:	0604c163          	bltz	s1,474a <fsfull+0x11a>
    name[0] = 'f';
    46ec:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    46f0:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    46f4:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    46f8:	4929                	li	s2,10
  while(nfiles >= 0){
    46fa:	5afd                	li	s5,-1
    name[0] = 'f';
    46fc:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4700:	0344c7bb          	divw	a5,s1,s4
    4704:	0307879b          	addiw	a5,a5,48
    4708:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    470c:	0344e7bb          	remw	a5,s1,s4
    4710:	0337c7bb          	divw	a5,a5,s3
    4714:	0307879b          	addiw	a5,a5,48
    4718:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    471c:	0334e7bb          	remw	a5,s1,s3
    4720:	0327c7bb          	divw	a5,a5,s2
    4724:	0307879b          	addiw	a5,a5,48
    4728:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    472c:	0324e7bb          	remw	a5,s1,s2
    4730:	0307879b          	addiw	a5,a5,48
    4734:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4738:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    473c:	f5040513          	addi	a0,s0,-176
    4740:	640000ef          	jal	ra,4d80 <unlink>
    nfiles--;
    4744:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4746:	fb549be3          	bne	s1,s5,46fc <fsfull+0xcc>
  printf("fsfull test finished\n");
    474a:	00003517          	auipc	a0,0x3
    474e:	c6e50513          	addi	a0,a0,-914 # 73b8 <malloc+0x2198>
    4752:	21b000ef          	jal	ra,516c <printf>
}
    4756:	70aa                	ld	ra,168(sp)
    4758:	740a                	ld	s0,160(sp)
    475a:	64ea                	ld	s1,152(sp)
    475c:	694a                	ld	s2,144(sp)
    475e:	69aa                	ld	s3,136(sp)
    4760:	6a0a                	ld	s4,128(sp)
    4762:	7ae6                	ld	s5,120(sp)
    4764:	7b46                	ld	s6,112(sp)
    4766:	7ba6                	ld	s7,104(sp)
    4768:	7c06                	ld	s8,96(sp)
    476a:	6ce6                	ld	s9,88(sp)
    476c:	6d46                	ld	s10,80(sp)
    476e:	6da6                	ld	s11,72(sp)
    4770:	614d                	addi	sp,sp,176
    4772:	8082                	ret
    int total = 0;
    4774:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4776:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    477a:	40000613          	li	a2,1024
    477e:	85d2                	mv	a1,s4
    4780:	854a                	mv	a0,s2
    4782:	5ce000ef          	jal	ra,4d50 <write>
      if(cc < BSIZE)
    4786:	00aad563          	bge	s5,a0,4790 <fsfull+0x160>
      total += cc;
    478a:	00a989bb          	addw	s3,s3,a0
    while(1){
    478e:	b7f5                	j	477a <fsfull+0x14a>
    printf("wrote %d bytes\n", total);
    4790:	85ce                	mv	a1,s3
    4792:	00003517          	auipc	a0,0x3
    4796:	c1650513          	addi	a0,a0,-1002 # 73a8 <malloc+0x2188>
    479a:	1d3000ef          	jal	ra,516c <printf>
    close(fd);
    479e:	854a                	mv	a0,s2
    47a0:	5b8000ef          	jal	ra,4d58 <close>
    if(total == 0)
    47a4:	f40982e3          	beqz	s3,46e8 <fsfull+0xb8>
  for(nfiles = 0; ; nfiles++){
    47a8:	2485                	addiw	s1,s1,1
    47aa:	bdc9                	j	467c <fsfull+0x4c>

00000000000047ac <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    47ac:	7179                	addi	sp,sp,-48
    47ae:	f406                	sd	ra,40(sp)
    47b0:	f022                	sd	s0,32(sp)
    47b2:	ec26                	sd	s1,24(sp)
    47b4:	e84a                	sd	s2,16(sp)
    47b6:	1800                	addi	s0,sp,48
    47b8:	84aa                	mv	s1,a0
    47ba:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    47bc:	00003517          	auipc	a0,0x3
    47c0:	c1450513          	addi	a0,a0,-1004 # 73d0 <malloc+0x21b0>
    47c4:	1a9000ef          	jal	ra,516c <printf>
  if((pid = fork()) < 0) {
    47c8:	560000ef          	jal	ra,4d28 <fork>
    47cc:	02054a63          	bltz	a0,4800 <run+0x54>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    47d0:	c129                	beqz	a0,4812 <run+0x66>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    47d2:	fdc40513          	addi	a0,s0,-36
    47d6:	562000ef          	jal	ra,4d38 <wait>
    if(xstatus != 0) 
    47da:	fdc42783          	lw	a5,-36(s0)
    47de:	cf9d                	beqz	a5,481c <run+0x70>
      printf("FAILED\n");
    47e0:	00003517          	auipc	a0,0x3
    47e4:	c1850513          	addi	a0,a0,-1000 # 73f8 <malloc+0x21d8>
    47e8:	185000ef          	jal	ra,516c <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    47ec:	fdc42503          	lw	a0,-36(s0)
  }
}
    47f0:	00153513          	seqz	a0,a0
    47f4:	70a2                	ld	ra,40(sp)
    47f6:	7402                	ld	s0,32(sp)
    47f8:	64e2                	ld	s1,24(sp)
    47fa:	6942                	ld	s2,16(sp)
    47fc:	6145                	addi	sp,sp,48
    47fe:	8082                	ret
    printf("runtest: fork error\n");
    4800:	00003517          	auipc	a0,0x3
    4804:	be050513          	addi	a0,a0,-1056 # 73e0 <malloc+0x21c0>
    4808:	165000ef          	jal	ra,516c <printf>
    exit(1);
    480c:	4505                	li	a0,1
    480e:	522000ef          	jal	ra,4d30 <exit>
    f(s);
    4812:	854a                	mv	a0,s2
    4814:	9482                	jalr	s1
    exit(0);
    4816:	4501                	li	a0,0
    4818:	518000ef          	jal	ra,4d30 <exit>
      printf("OK\n");
    481c:	00003517          	auipc	a0,0x3
    4820:	be450513          	addi	a0,a0,-1052 # 7400 <malloc+0x21e0>
    4824:	149000ef          	jal	ra,516c <printf>
    4828:	b7d1                	j	47ec <run+0x40>

000000000000482a <runtests>:

int
runtests(struct test *tests, char *justone, int continuous) {
    482a:	7139                	addi	sp,sp,-64
    482c:	fc06                	sd	ra,56(sp)
    482e:	f822                	sd	s0,48(sp)
    4830:	f426                	sd	s1,40(sp)
    4832:	f04a                	sd	s2,32(sp)
    4834:	ec4e                	sd	s3,24(sp)
    4836:	e852                	sd	s4,16(sp)
    4838:	e456                	sd	s5,8(sp)
    483a:	0080                	addi	s0,sp,64
    483c:	84aa                	mv	s1,a0
  int ntests = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    483e:	6508                	ld	a0,8(a0)
    4840:	c921                	beqz	a0,4890 <runtests+0x66>
    4842:	892e                	mv	s2,a1
    4844:	8a32                	mv	s4,a2
  int ntests = 0;
    4846:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      ntests++;
      if(!run(t->f, t->s)){
        if(continuous != 2){
    4848:	4a89                	li	s5,2
    484a:	a021                	j	4852 <runtests+0x28>
  for (struct test *t = tests; t->s != 0; t++) {
    484c:	04c1                	addi	s1,s1,16
    484e:	6488                	ld	a0,8(s1)
    4850:	c515                	beqz	a0,487c <runtests+0x52>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    4852:	00090663          	beqz	s2,485e <runtests+0x34>
    4856:	85ca                	mv	a1,s2
    4858:	270000ef          	jal	ra,4ac8 <strcmp>
    485c:	f965                	bnez	a0,484c <runtests+0x22>
      ntests++;
    485e:	2985                	addiw	s3,s3,1 # 1000001 <base+0xff1349>
      if(!run(t->f, t->s)){
    4860:	648c                	ld	a1,8(s1)
    4862:	6088                	ld	a0,0(s1)
    4864:	f49ff0ef          	jal	ra,47ac <run>
    4868:	f175                	bnez	a0,484c <runtests+0x22>
        if(continuous != 2){
    486a:	ff5a01e3          	beq	s4,s5,484c <runtests+0x22>
          printf("SOME TESTS FAILED\n");
    486e:	00003517          	auipc	a0,0x3
    4872:	b9a50513          	addi	a0,a0,-1126 # 7408 <malloc+0x21e8>
    4876:	0f7000ef          	jal	ra,516c <printf>
          return -1;
    487a:	59fd                	li	s3,-1
        }
      }
    }
  }
  return ntests;
}
    487c:	854e                	mv	a0,s3
    487e:	70e2                	ld	ra,56(sp)
    4880:	7442                	ld	s0,48(sp)
    4882:	74a2                	ld	s1,40(sp)
    4884:	7902                	ld	s2,32(sp)
    4886:	69e2                	ld	s3,24(sp)
    4888:	6a42                	ld	s4,16(sp)
    488a:	6aa2                	ld	s5,8(sp)
    488c:	6121                	addi	sp,sp,64
    488e:	8082                	ret
  int ntests = 0;
    4890:	4981                	li	s3,0
    4892:	b7ed                	j	487c <runtests+0x52>

0000000000004894 <countfree>:


// use sbrk() to count how many free physical memory pages there are.
int
countfree()
{
    4894:	7179                	addi	sp,sp,-48
    4896:	f406                	sd	ra,40(sp)
    4898:	f022                	sd	s0,32(sp)
    489a:	ec26                	sd	s1,24(sp)
    489c:	e84a                	sd	s2,16(sp)
    489e:	e44e                	sd	s3,8(sp)
    48a0:	1800                	addi	s0,sp,48
  int n = 0;
  uint64 sz0 = (uint64)sbrk(0);
    48a2:	4501                	li	a0,0
    48a4:	458000ef          	jal	ra,4cfc <sbrk>
    48a8:	89aa                	mv	s3,a0
  int n = 0;
    48aa:	4481                	li	s1,0
  while(1){
    char *a = sbrk(PGSIZE);
    if(a == SBRK_ERROR){
    48ac:	597d                	li	s2,-1
    48ae:	a011                	j	48b2 <countfree+0x1e>
      break;
    }
    n += 1;
    48b0:	2485                	addiw	s1,s1,1
    char *a = sbrk(PGSIZE);
    48b2:	6505                	lui	a0,0x1
    48b4:	448000ef          	jal	ra,4cfc <sbrk>
    if(a == SBRK_ERROR){
    48b8:	ff251ce3          	bne	a0,s2,48b0 <countfree+0x1c>
  }
  sbrk(-((uint64)sbrk(0) - sz0));  
    48bc:	4501                	li	a0,0
    48be:	43e000ef          	jal	ra,4cfc <sbrk>
    48c2:	40a9853b          	subw	a0,s3,a0
    48c6:	436000ef          	jal	ra,4cfc <sbrk>
  return n;
}
    48ca:	8526                	mv	a0,s1
    48cc:	70a2                	ld	ra,40(sp)
    48ce:	7402                	ld	s0,32(sp)
    48d0:	64e2                	ld	s1,24(sp)
    48d2:	6942                	ld	s2,16(sp)
    48d4:	69a2                	ld	s3,8(sp)
    48d6:	6145                	addi	sp,sp,48
    48d8:	8082                	ret

00000000000048da <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    48da:	7159                	addi	sp,sp,-112
    48dc:	f486                	sd	ra,104(sp)
    48de:	f0a2                	sd	s0,96(sp)
    48e0:	eca6                	sd	s1,88(sp)
    48e2:	e8ca                	sd	s2,80(sp)
    48e4:	e4ce                	sd	s3,72(sp)
    48e6:	e0d2                	sd	s4,64(sp)
    48e8:	fc56                	sd	s5,56(sp)
    48ea:	f85a                	sd	s6,48(sp)
    48ec:	f45e                	sd	s7,40(sp)
    48ee:	f062                	sd	s8,32(sp)
    48f0:	ec66                	sd	s9,24(sp)
    48f2:	e86a                	sd	s10,16(sp)
    48f4:	e46e                	sd	s11,8(sp)
    48f6:	1880                	addi	s0,sp,112
    48f8:	8aaa                	mv	s5,a0
    48fa:	89ae                	mv	s3,a1
    48fc:	8a32                	mv	s4,a2
  do {
    printf("usertests starting\n");
    48fe:	00003b97          	auipc	s7,0x3
    4902:	b22b8b93          	addi	s7,s7,-1246 # 7420 <malloc+0x2200>
    int free0 = countfree();
    int free1 = 0;
    int ntests = 0;
    int n;
    n = runtests(quicktests, justone, continuous);
    4906:	00003b17          	auipc	s6,0x3
    490a:	70ab0b13          	addi	s6,s6,1802 # 8010 <quicktests>
    if (n < 0) {
      if(continuous != 2) {
    490e:	4c09                	li	s8,2
      } else {
        ntests += n;
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    4910:	00003d17          	auipc	s10,0x3
    4914:	b48d0d13          	addi	s10,s10,-1208 # 7458 <malloc+0x2238>
      n = runtests(slowtests, justone, continuous);
    4918:	00004c97          	auipc	s9,0x4
    491c:	b08c8c93          	addi	s9,s9,-1272 # 8420 <slowtests>
        printf("usertests slow tests starting\n");
    4920:	00003d97          	auipc	s11,0x3
    4924:	b18d8d93          	addi	s11,s11,-1256 # 7438 <malloc+0x2218>
    4928:	a835                	j	4964 <drivetests+0x8a>
      if(continuous != 2) {
    492a:	09899a63          	bne	s3,s8,49be <drivetests+0xe4>
    int ntests = 0;
    492e:	4481                	li	s1,0
    4930:	a881                	j	4980 <drivetests+0xa6>
        printf("usertests slow tests starting\n");
    4932:	856e                	mv	a0,s11
    4934:	039000ef          	jal	ra,516c <printf>
    4938:	a881                	j	4988 <drivetests+0xae>
        if(continuous != 2) {
    493a:	09899463          	bne	s3,s8,49c2 <drivetests+0xe8>
    if((free1 = countfree()) < free0) {
    493e:	f57ff0ef          	jal	ra,4894 <countfree>
    4942:	01255c63          	bge	a0,s2,495a <drivetests+0x80>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    4946:	864a                	mv	a2,s2
    4948:	85aa                	mv	a1,a0
    494a:	856a                	mv	a0,s10
    494c:	021000ef          	jal	ra,516c <printf>
      if(continuous != 2) {
    4950:	a8a1                	j	49a8 <drivetests+0xce>
    if((free1 = countfree()) < free0) {
    4952:	f43ff0ef          	jal	ra,4894 <countfree>
    4956:	05254263          	blt	a0,s2,499a <drivetests+0xc0>
        return 1;
      }
    }
    if (justone != 0 && ntests == 0) {
    495a:	000a0363          	beqz	s4,4960 <drivetests+0x86>
    495e:	c8a1                	beqz	s1,49ae <drivetests+0xd4>
      printf("NO TESTS EXECUTED\n");
      return 1;
    }
  } while(continuous);
    4960:	06098563          	beqz	s3,49ca <drivetests+0xf0>
    printf("usertests starting\n");
    4964:	855e                	mv	a0,s7
    4966:	007000ef          	jal	ra,516c <printf>
    int free0 = countfree();
    496a:	f2bff0ef          	jal	ra,4894 <countfree>
    496e:	892a                	mv	s2,a0
    n = runtests(quicktests, justone, continuous);
    4970:	864e                	mv	a2,s3
    4972:	85d2                	mv	a1,s4
    4974:	855a                	mv	a0,s6
    4976:	eb5ff0ef          	jal	ra,482a <runtests>
    497a:	84aa                	mv	s1,a0
    if (n < 0) {
    497c:	fa0547e3          	bltz	a0,492a <drivetests+0x50>
    if(!quick) {
    4980:	fc0a99e3          	bnez	s5,4952 <drivetests+0x78>
      if (justone == 0)
    4984:	fa0a07e3          	beqz	s4,4932 <drivetests+0x58>
      n = runtests(slowtests, justone, continuous);
    4988:	864e                	mv	a2,s3
    498a:	85d2                	mv	a1,s4
    498c:	8566                	mv	a0,s9
    498e:	e9dff0ef          	jal	ra,482a <runtests>
      if (n < 0) {
    4992:	fa0544e3          	bltz	a0,493a <drivetests+0x60>
        ntests += n;
    4996:	9ca9                	addw	s1,s1,a0
    4998:	bf6d                	j	4952 <drivetests+0x78>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    499a:	864a                	mv	a2,s2
    499c:	85aa                	mv	a1,a0
    499e:	856a                	mv	a0,s10
    49a0:	7cc000ef          	jal	ra,516c <printf>
      if(continuous != 2) {
    49a4:	03899163          	bne	s3,s8,49c6 <drivetests+0xec>
    if (justone != 0 && ntests == 0) {
    49a8:	fa0a0ee3          	beqz	s4,4964 <drivetests+0x8a>
    49ac:	fcc5                	bnez	s1,4964 <drivetests+0x8a>
      printf("NO TESTS EXECUTED\n");
    49ae:	00003517          	auipc	a0,0x3
    49b2:	ada50513          	addi	a0,a0,-1318 # 7488 <malloc+0x2268>
    49b6:	7b6000ef          	jal	ra,516c <printf>
      return 1;
    49ba:	4505                	li	a0,1
    49bc:	a801                	j	49cc <drivetests+0xf2>
        return 1;
    49be:	4505                	li	a0,1
    49c0:	a031                	j	49cc <drivetests+0xf2>
          return 1;
    49c2:	4505                	li	a0,1
    49c4:	a021                	j	49cc <drivetests+0xf2>
        return 1;
    49c6:	4505                	li	a0,1
    49c8:	a011                	j	49cc <drivetests+0xf2>
  return 0;
    49ca:	854e                	mv	a0,s3
}
    49cc:	70a6                	ld	ra,104(sp)
    49ce:	7406                	ld	s0,96(sp)
    49d0:	64e6                	ld	s1,88(sp)
    49d2:	6946                	ld	s2,80(sp)
    49d4:	69a6                	ld	s3,72(sp)
    49d6:	6a06                	ld	s4,64(sp)
    49d8:	7ae2                	ld	s5,56(sp)
    49da:	7b42                	ld	s6,48(sp)
    49dc:	7ba2                	ld	s7,40(sp)
    49de:	7c02                	ld	s8,32(sp)
    49e0:	6ce2                	ld	s9,24(sp)
    49e2:	6d42                	ld	s10,16(sp)
    49e4:	6da2                	ld	s11,8(sp)
    49e6:	6165                	addi	sp,sp,112
    49e8:	8082                	ret

00000000000049ea <main>:

int
main(int argc, char *argv[])
{
    49ea:	1101                	addi	sp,sp,-32
    49ec:	ec06                	sd	ra,24(sp)
    49ee:	e822                	sd	s0,16(sp)
    49f0:	e426                	sd	s1,8(sp)
    49f2:	e04a                	sd	s2,0(sp)
    49f4:	1000                	addi	s0,sp,32
    49f6:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    49f8:	4789                	li	a5,2
    49fa:	00f50e63          	beq	a0,a5,4a16 <main+0x2c>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    49fe:	4785                	li	a5,1
    4a00:	06a7c363          	blt	a5,a0,4a66 <main+0x7c>
  char *justone = 0;
    4a04:	4601                	li	a2,0
  int quick = 0;
    4a06:	4501                	li	a0,0
  int continuous = 0;
    4a08:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    4a0a:	ed1ff0ef          	jal	ra,48da <drivetests>
    4a0e:	cd35                	beqz	a0,4a8a <main+0xa0>
    exit(1);
    4a10:	4505                	li	a0,1
    4a12:	31e000ef          	jal	ra,4d30 <exit>
    4a16:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    4a18:	00003597          	auipc	a1,0x3
    4a1c:	a8858593          	addi	a1,a1,-1400 # 74a0 <malloc+0x2280>
    4a20:	00893503          	ld	a0,8(s2) # ffffffffffffd008 <base+0xfffffffffffee350>
    4a24:	0a4000ef          	jal	ra,4ac8 <strcmp>
    4a28:	85aa                	mv	a1,a0
    4a2a:	c539                	beqz	a0,4a78 <main+0x8e>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    4a2c:	00003597          	auipc	a1,0x3
    4a30:	acc58593          	addi	a1,a1,-1332 # 74f8 <malloc+0x22d8>
    4a34:	00893503          	ld	a0,8(s2)
    4a38:	090000ef          	jal	ra,4ac8 <strcmp>
    4a3c:	c521                	beqz	a0,4a84 <main+0x9a>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    4a3e:	00003597          	auipc	a1,0x3
    4a42:	ab258593          	addi	a1,a1,-1358 # 74f0 <malloc+0x22d0>
    4a46:	00893503          	ld	a0,8(s2)
    4a4a:	07e000ef          	jal	ra,4ac8 <strcmp>
    4a4e:	c905                	beqz	a0,4a7e <main+0x94>
  } else if(argc == 2 && argv[1][0] != '-'){
    4a50:	00893603          	ld	a2,8(s2)
    4a54:	00064703          	lbu	a4,0(a2) # 1000 <badarg>
    4a58:	02d00793          	li	a5,45
    4a5c:	00f70563          	beq	a4,a5,4a66 <main+0x7c>
  int quick = 0;
    4a60:	4501                	li	a0,0
  int continuous = 0;
    4a62:	4581                	li	a1,0
    4a64:	b75d                	j	4a0a <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    4a66:	00003517          	auipc	a0,0x3
    4a6a:	a4250513          	addi	a0,a0,-1470 # 74a8 <malloc+0x2288>
    4a6e:	6fe000ef          	jal	ra,516c <printf>
    exit(1);
    4a72:	4505                	li	a0,1
    4a74:	2bc000ef          	jal	ra,4d30 <exit>
  char *justone = 0;
    4a78:	4601                	li	a2,0
    quick = 1;
    4a7a:	4505                	li	a0,1
    4a7c:	b779                	j	4a0a <main+0x20>
    continuous = 2;
    4a7e:	85a6                	mv	a1,s1
  char *justone = 0;
    4a80:	4601                	li	a2,0
    4a82:	b761                	j	4a0a <main+0x20>
    4a84:	4601                	li	a2,0
    continuous = 1;
    4a86:	4585                	li	a1,1
    4a88:	b749                	j	4a0a <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    4a8a:	00003517          	auipc	a0,0x3
    4a8e:	a4e50513          	addi	a0,a0,-1458 # 74d8 <malloc+0x22b8>
    4a92:	6da000ef          	jal	ra,516c <printf>
  exit(0);
    4a96:	4501                	li	a0,0
    4a98:	298000ef          	jal	ra,4d30 <exit>

0000000000004a9c <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
    4a9c:	1141                	addi	sp,sp,-16
    4a9e:	e406                	sd	ra,8(sp)
    4aa0:	e022                	sd	s0,0(sp)
    4aa2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
    4aa4:	f47ff0ef          	jal	ra,49ea <main>
  exit(r);
    4aa8:	288000ef          	jal	ra,4d30 <exit>

0000000000004aac <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    4aac:	1141                	addi	sp,sp,-16
    4aae:	e422                	sd	s0,8(sp)
    4ab0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    4ab2:	87aa                	mv	a5,a0
    4ab4:	0585                	addi	a1,a1,1
    4ab6:	0785                	addi	a5,a5,1
    4ab8:	fff5c703          	lbu	a4,-1(a1)
    4abc:	fee78fa3          	sb	a4,-1(a5)
    4ac0:	fb75                	bnez	a4,4ab4 <strcpy+0x8>
    ;
  return os;
}
    4ac2:	6422                	ld	s0,8(sp)
    4ac4:	0141                	addi	sp,sp,16
    4ac6:	8082                	ret

0000000000004ac8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    4ac8:	1141                	addi	sp,sp,-16
    4aca:	e422                	sd	s0,8(sp)
    4acc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    4ace:	00054783          	lbu	a5,0(a0)
    4ad2:	cb91                	beqz	a5,4ae6 <strcmp+0x1e>
    4ad4:	0005c703          	lbu	a4,0(a1)
    4ad8:	00f71763          	bne	a4,a5,4ae6 <strcmp+0x1e>
    p++, q++;
    4adc:	0505                	addi	a0,a0,1
    4ade:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    4ae0:	00054783          	lbu	a5,0(a0)
    4ae4:	fbe5                	bnez	a5,4ad4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    4ae6:	0005c503          	lbu	a0,0(a1)
}
    4aea:	40a7853b          	subw	a0,a5,a0
    4aee:	6422                	ld	s0,8(sp)
    4af0:	0141                	addi	sp,sp,16
    4af2:	8082                	ret

0000000000004af4 <strlen>:

uint
strlen(const char *s)
{
    4af4:	1141                	addi	sp,sp,-16
    4af6:	e422                	sd	s0,8(sp)
    4af8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4afa:	00054783          	lbu	a5,0(a0)
    4afe:	cf91                	beqz	a5,4b1a <strlen+0x26>
    4b00:	0505                	addi	a0,a0,1
    4b02:	87aa                	mv	a5,a0
    4b04:	4685                	li	a3,1
    4b06:	9e89                	subw	a3,a3,a0
    4b08:	00f6853b          	addw	a0,a3,a5
    4b0c:	0785                	addi	a5,a5,1
    4b0e:	fff7c703          	lbu	a4,-1(a5)
    4b12:	fb7d                	bnez	a4,4b08 <strlen+0x14>
    ;
  return n;
}
    4b14:	6422                	ld	s0,8(sp)
    4b16:	0141                	addi	sp,sp,16
    4b18:	8082                	ret
  for(n = 0; s[n]; n++)
    4b1a:	4501                	li	a0,0
    4b1c:	bfe5                	j	4b14 <strlen+0x20>

0000000000004b1e <memset>:

void*
memset(void *dst, int c, uint n)
{
    4b1e:	1141                	addi	sp,sp,-16
    4b20:	e422                	sd	s0,8(sp)
    4b22:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    4b24:	ca19                	beqz	a2,4b3a <memset+0x1c>
    4b26:	87aa                	mv	a5,a0
    4b28:	1602                	slli	a2,a2,0x20
    4b2a:	9201                	srli	a2,a2,0x20
    4b2c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    4b30:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    4b34:	0785                	addi	a5,a5,1
    4b36:	fee79de3          	bne	a5,a4,4b30 <memset+0x12>
  }
  return dst;
}
    4b3a:	6422                	ld	s0,8(sp)
    4b3c:	0141                	addi	sp,sp,16
    4b3e:	8082                	ret

0000000000004b40 <strchr>:

char*
strchr(const char *s, char c)
{
    4b40:	1141                	addi	sp,sp,-16
    4b42:	e422                	sd	s0,8(sp)
    4b44:	0800                	addi	s0,sp,16
  for(; *s; s++)
    4b46:	00054783          	lbu	a5,0(a0)
    4b4a:	cb99                	beqz	a5,4b60 <strchr+0x20>
    if(*s == c)
    4b4c:	00f58763          	beq	a1,a5,4b5a <strchr+0x1a>
  for(; *s; s++)
    4b50:	0505                	addi	a0,a0,1
    4b52:	00054783          	lbu	a5,0(a0)
    4b56:	fbfd                	bnez	a5,4b4c <strchr+0xc>
      return (char*)s;
  return 0;
    4b58:	4501                	li	a0,0
}
    4b5a:	6422                	ld	s0,8(sp)
    4b5c:	0141                	addi	sp,sp,16
    4b5e:	8082                	ret
  return 0;
    4b60:	4501                	li	a0,0
    4b62:	bfe5                	j	4b5a <strchr+0x1a>

0000000000004b64 <gets>:

char*
gets(char *buf, int max)
{
    4b64:	711d                	addi	sp,sp,-96
    4b66:	ec86                	sd	ra,88(sp)
    4b68:	e8a2                	sd	s0,80(sp)
    4b6a:	e4a6                	sd	s1,72(sp)
    4b6c:	e0ca                	sd	s2,64(sp)
    4b6e:	fc4e                	sd	s3,56(sp)
    4b70:	f852                	sd	s4,48(sp)
    4b72:	f456                	sd	s5,40(sp)
    4b74:	f05a                	sd	s6,32(sp)
    4b76:	ec5e                	sd	s7,24(sp)
    4b78:	1080                	addi	s0,sp,96
    4b7a:	8baa                	mv	s7,a0
    4b7c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4b7e:	892a                	mv	s2,a0
    4b80:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    4b82:	4aa9                	li	s5,10
    4b84:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    4b86:	89a6                	mv	s3,s1
    4b88:	2485                	addiw	s1,s1,1
    4b8a:	0344d663          	bge	s1,s4,4bb6 <gets+0x52>
    cc = read(0, &c, 1);
    4b8e:	4605                	li	a2,1
    4b90:	faf40593          	addi	a1,s0,-81
    4b94:	4501                	li	a0,0
    4b96:	1b2000ef          	jal	ra,4d48 <read>
    if(cc < 1)
    4b9a:	00a05e63          	blez	a0,4bb6 <gets+0x52>
    buf[i++] = c;
    4b9e:	faf44783          	lbu	a5,-81(s0)
    4ba2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4ba6:	01578763          	beq	a5,s5,4bb4 <gets+0x50>
    4baa:	0905                	addi	s2,s2,1
    4bac:	fd679de3          	bne	a5,s6,4b86 <gets+0x22>
  for(i=0; i+1 < max; ){
    4bb0:	89a6                	mv	s3,s1
    4bb2:	a011                	j	4bb6 <gets+0x52>
    4bb4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    4bb6:	99de                	add	s3,s3,s7
    4bb8:	00098023          	sb	zero,0(s3)
  return buf;
}
    4bbc:	855e                	mv	a0,s7
    4bbe:	60e6                	ld	ra,88(sp)
    4bc0:	6446                	ld	s0,80(sp)
    4bc2:	64a6                	ld	s1,72(sp)
    4bc4:	6906                	ld	s2,64(sp)
    4bc6:	79e2                	ld	s3,56(sp)
    4bc8:	7a42                	ld	s4,48(sp)
    4bca:	7aa2                	ld	s5,40(sp)
    4bcc:	7b02                	ld	s6,32(sp)
    4bce:	6be2                	ld	s7,24(sp)
    4bd0:	6125                	addi	sp,sp,96
    4bd2:	8082                	ret

0000000000004bd4 <stat>:

int
stat(const char *n, struct stat *st)
{
    4bd4:	1101                	addi	sp,sp,-32
    4bd6:	ec06                	sd	ra,24(sp)
    4bd8:	e822                	sd	s0,16(sp)
    4bda:	e426                	sd	s1,8(sp)
    4bdc:	e04a                	sd	s2,0(sp)
    4bde:	1000                	addi	s0,sp,32
    4be0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4be2:	4581                	li	a1,0
    4be4:	18c000ef          	jal	ra,4d70 <open>
  if(fd < 0)
    4be8:	02054163          	bltz	a0,4c0a <stat+0x36>
    4bec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    4bee:	85ca                	mv	a1,s2
    4bf0:	198000ef          	jal	ra,4d88 <fstat>
    4bf4:	892a                	mv	s2,a0
  close(fd);
    4bf6:	8526                	mv	a0,s1
    4bf8:	160000ef          	jal	ra,4d58 <close>
  return r;
}
    4bfc:	854a                	mv	a0,s2
    4bfe:	60e2                	ld	ra,24(sp)
    4c00:	6442                	ld	s0,16(sp)
    4c02:	64a2                	ld	s1,8(sp)
    4c04:	6902                	ld	s2,0(sp)
    4c06:	6105                	addi	sp,sp,32
    4c08:	8082                	ret
    return -1;
    4c0a:	597d                	li	s2,-1
    4c0c:	bfc5                	j	4bfc <stat+0x28>

0000000000004c0e <atoi>:

int
atoi(const char *s)
{
    4c0e:	1141                	addi	sp,sp,-16
    4c10:	e422                	sd	s0,8(sp)
    4c12:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    4c14:	00054683          	lbu	a3,0(a0)
    4c18:	fd06879b          	addiw	a5,a3,-48 # 3ffd0 <base+0x31318>
    4c1c:	0ff7f793          	zext.b	a5,a5
    4c20:	4625                	li	a2,9
    4c22:	02f66863          	bltu	a2,a5,4c52 <atoi+0x44>
    4c26:	872a                	mv	a4,a0
  n = 0;
    4c28:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    4c2a:	0705                	addi	a4,a4,1 # 1000001 <base+0xff1349>
    4c2c:	0025179b          	slliw	a5,a0,0x2
    4c30:	9fa9                	addw	a5,a5,a0
    4c32:	0017979b          	slliw	a5,a5,0x1
    4c36:	9fb5                	addw	a5,a5,a3
    4c38:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    4c3c:	00074683          	lbu	a3,0(a4)
    4c40:	fd06879b          	addiw	a5,a3,-48
    4c44:	0ff7f793          	zext.b	a5,a5
    4c48:	fef671e3          	bgeu	a2,a5,4c2a <atoi+0x1c>
  return n;
}
    4c4c:	6422                	ld	s0,8(sp)
    4c4e:	0141                	addi	sp,sp,16
    4c50:	8082                	ret
  n = 0;
    4c52:	4501                	li	a0,0
    4c54:	bfe5                	j	4c4c <atoi+0x3e>

0000000000004c56 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4c56:	1141                	addi	sp,sp,-16
    4c58:	e422                	sd	s0,8(sp)
    4c5a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4c5c:	02b57463          	bgeu	a0,a1,4c84 <memmove+0x2e>
    while(n-- > 0)
    4c60:	00c05f63          	blez	a2,4c7e <memmove+0x28>
    4c64:	1602                	slli	a2,a2,0x20
    4c66:	9201                	srli	a2,a2,0x20
    4c68:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4c6c:	872a                	mv	a4,a0
      *dst++ = *src++;
    4c6e:	0585                	addi	a1,a1,1
    4c70:	0705                	addi	a4,a4,1
    4c72:	fff5c683          	lbu	a3,-1(a1)
    4c76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    4c7a:	fee79ae3          	bne	a5,a4,4c6e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    4c7e:	6422                	ld	s0,8(sp)
    4c80:	0141                	addi	sp,sp,16
    4c82:	8082                	ret
    dst += n;
    4c84:	00c50733          	add	a4,a0,a2
    src += n;
    4c88:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    4c8a:	fec05ae3          	blez	a2,4c7e <memmove+0x28>
    4c8e:	fff6079b          	addiw	a5,a2,-1
    4c92:	1782                	slli	a5,a5,0x20
    4c94:	9381                	srli	a5,a5,0x20
    4c96:	fff7c793          	not	a5,a5
    4c9a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    4c9c:	15fd                	addi	a1,a1,-1
    4c9e:	177d                	addi	a4,a4,-1
    4ca0:	0005c683          	lbu	a3,0(a1)
    4ca4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    4ca8:	fee79ae3          	bne	a5,a4,4c9c <memmove+0x46>
    4cac:	bfc9                	j	4c7e <memmove+0x28>

0000000000004cae <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    4cae:	1141                	addi	sp,sp,-16
    4cb0:	e422                	sd	s0,8(sp)
    4cb2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    4cb4:	ca05                	beqz	a2,4ce4 <memcmp+0x36>
    4cb6:	fff6069b          	addiw	a3,a2,-1
    4cba:	1682                	slli	a3,a3,0x20
    4cbc:	9281                	srli	a3,a3,0x20
    4cbe:	0685                	addi	a3,a3,1
    4cc0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    4cc2:	00054783          	lbu	a5,0(a0)
    4cc6:	0005c703          	lbu	a4,0(a1)
    4cca:	00e79863          	bne	a5,a4,4cda <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    4cce:	0505                	addi	a0,a0,1
    p2++;
    4cd0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    4cd2:	fed518e3          	bne	a0,a3,4cc2 <memcmp+0x14>
  }
  return 0;
    4cd6:	4501                	li	a0,0
    4cd8:	a019                	j	4cde <memcmp+0x30>
      return *p1 - *p2;
    4cda:	40e7853b          	subw	a0,a5,a4
}
    4cde:	6422                	ld	s0,8(sp)
    4ce0:	0141                	addi	sp,sp,16
    4ce2:	8082                	ret
  return 0;
    4ce4:	4501                	li	a0,0
    4ce6:	bfe5                	j	4cde <memcmp+0x30>

0000000000004ce8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4ce8:	1141                	addi	sp,sp,-16
    4cea:	e406                	sd	ra,8(sp)
    4cec:	e022                	sd	s0,0(sp)
    4cee:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    4cf0:	f67ff0ef          	jal	ra,4c56 <memmove>
}
    4cf4:	60a2                	ld	ra,8(sp)
    4cf6:	6402                	ld	s0,0(sp)
    4cf8:	0141                	addi	sp,sp,16
    4cfa:	8082                	ret

0000000000004cfc <sbrk>:

char *
sbrk(int n) {
    4cfc:	1141                	addi	sp,sp,-16
    4cfe:	e406                	sd	ra,8(sp)
    4d00:	e022                	sd	s0,0(sp)
    4d02:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    4d04:	4585                	li	a1,1
    4d06:	0b2000ef          	jal	ra,4db8 <sys_sbrk>
}
    4d0a:	60a2                	ld	ra,8(sp)
    4d0c:	6402                	ld	s0,0(sp)
    4d0e:	0141                	addi	sp,sp,16
    4d10:	8082                	ret

0000000000004d12 <sbrklazy>:

char *
sbrklazy(int n) {
    4d12:	1141                	addi	sp,sp,-16
    4d14:	e406                	sd	ra,8(sp)
    4d16:	e022                	sd	s0,0(sp)
    4d18:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    4d1a:	4589                	li	a1,2
    4d1c:	09c000ef          	jal	ra,4db8 <sys_sbrk>
}
    4d20:	60a2                	ld	ra,8(sp)
    4d22:	6402                	ld	s0,0(sp)
    4d24:	0141                	addi	sp,sp,16
    4d26:	8082                	ret

0000000000004d28 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    4d28:	4885                	li	a7,1
 ecall
    4d2a:	00000073          	ecall
 ret
    4d2e:	8082                	ret

0000000000004d30 <exit>:
.global exit
exit:
 li a7, SYS_exit
    4d30:	4889                	li	a7,2
 ecall
    4d32:	00000073          	ecall
 ret
    4d36:	8082                	ret

0000000000004d38 <wait>:
.global wait
wait:
 li a7, SYS_wait
    4d38:	488d                	li	a7,3
 ecall
    4d3a:	00000073          	ecall
 ret
    4d3e:	8082                	ret

0000000000004d40 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    4d40:	4891                	li	a7,4
 ecall
    4d42:	00000073          	ecall
 ret
    4d46:	8082                	ret

0000000000004d48 <read>:
.global read
read:
 li a7, SYS_read
    4d48:	4895                	li	a7,5
 ecall
    4d4a:	00000073          	ecall
 ret
    4d4e:	8082                	ret

0000000000004d50 <write>:
.global write
write:
 li a7, SYS_write
    4d50:	48c1                	li	a7,16
 ecall
    4d52:	00000073          	ecall
 ret
    4d56:	8082                	ret

0000000000004d58 <close>:
.global close
close:
 li a7, SYS_close
    4d58:	48d5                	li	a7,21
 ecall
    4d5a:	00000073          	ecall
 ret
    4d5e:	8082                	ret

0000000000004d60 <kill>:
.global kill
kill:
 li a7, SYS_kill
    4d60:	4899                	li	a7,6
 ecall
    4d62:	00000073          	ecall
 ret
    4d66:	8082                	ret

0000000000004d68 <exec>:
.global exec
exec:
 li a7, SYS_exec
    4d68:	489d                	li	a7,7
 ecall
    4d6a:	00000073          	ecall
 ret
    4d6e:	8082                	ret

0000000000004d70 <open>:
.global open
open:
 li a7, SYS_open
    4d70:	48bd                	li	a7,15
 ecall
    4d72:	00000073          	ecall
 ret
    4d76:	8082                	ret

0000000000004d78 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    4d78:	48c5                	li	a7,17
 ecall
    4d7a:	00000073          	ecall
 ret
    4d7e:	8082                	ret

0000000000004d80 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4d80:	48c9                	li	a7,18
 ecall
    4d82:	00000073          	ecall
 ret
    4d86:	8082                	ret

0000000000004d88 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4d88:	48a1                	li	a7,8
 ecall
    4d8a:	00000073          	ecall
 ret
    4d8e:	8082                	ret

0000000000004d90 <link>:
.global link
link:
 li a7, SYS_link
    4d90:	48cd                	li	a7,19
 ecall
    4d92:	00000073          	ecall
 ret
    4d96:	8082                	ret

0000000000004d98 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    4d98:	48d1                	li	a7,20
 ecall
    4d9a:	00000073          	ecall
 ret
    4d9e:	8082                	ret

0000000000004da0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4da0:	48a5                	li	a7,9
 ecall
    4da2:	00000073          	ecall
 ret
    4da6:	8082                	ret

0000000000004da8 <dup>:
.global dup
dup:
 li a7, SYS_dup
    4da8:	48a9                	li	a7,10
 ecall
    4daa:	00000073          	ecall
 ret
    4dae:	8082                	ret

0000000000004db0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4db0:	48ad                	li	a7,11
 ecall
    4db2:	00000073          	ecall
 ret
    4db6:	8082                	ret

0000000000004db8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    4db8:	48b1                	li	a7,12
 ecall
    4dba:	00000073          	ecall
 ret
    4dbe:	8082                	ret

0000000000004dc0 <pause>:
.global pause
pause:
 li a7, SYS_pause
    4dc0:	48b5                	li	a7,13
 ecall
    4dc2:	00000073          	ecall
 ret
    4dc6:	8082                	ret

0000000000004dc8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    4dc8:	48b9                	li	a7,14
 ecall
    4dca:	00000073          	ecall
 ret
    4dce:	8082                	ret

0000000000004dd0 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
    4dd0:	48d9                	li	a7,22
 ecall
    4dd2:	00000073          	ecall
 ret
    4dd6:	8082                	ret

0000000000004dd8 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
    4dd8:	48dd                	li	a7,23
 ecall
    4dda:	00000073          	ecall
 ret
    4dde:	8082                	ret

0000000000004de0 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
    4de0:	48e1                	li	a7,24
 ecall
    4de2:	00000073          	ecall
 ret
    4de6:	8082                	ret

0000000000004de8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    4de8:	48e5                	li	a7,25
 ecall
    4dea:	00000073          	ecall
 ret
    4dee:	8082                	ret

0000000000004df0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4df0:	1101                	addi	sp,sp,-32
    4df2:	ec06                	sd	ra,24(sp)
    4df4:	e822                	sd	s0,16(sp)
    4df6:	1000                	addi	s0,sp,32
    4df8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    4dfc:	4605                	li	a2,1
    4dfe:	fef40593          	addi	a1,s0,-17
    4e02:	f4fff0ef          	jal	ra,4d50 <write>
}
    4e06:	60e2                	ld	ra,24(sp)
    4e08:	6442                	ld	s0,16(sp)
    4e0a:	6105                	addi	sp,sp,32
    4e0c:	8082                	ret

0000000000004e0e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    4e0e:	715d                	addi	sp,sp,-80
    4e10:	e486                	sd	ra,72(sp)
    4e12:	e0a2                	sd	s0,64(sp)
    4e14:	fc26                	sd	s1,56(sp)
    4e16:	f84a                	sd	s2,48(sp)
    4e18:	f44e                	sd	s3,40(sp)
    4e1a:	0880                	addi	s0,sp,80
    4e1c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    4e1e:	c299                	beqz	a3,4e24 <printint+0x16>
    4e20:	0805c163          	bltz	a1,4ea2 <printint+0x94>
  neg = 0;
    4e24:	4881                	li	a7,0
    4e26:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    4e2a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    4e2c:	00003517          	auipc	a0,0x3
    4e30:	afc50513          	addi	a0,a0,-1284 # 7928 <digits>
    4e34:	883e                	mv	a6,a5
    4e36:	2785                	addiw	a5,a5,1
    4e38:	02c5f733          	remu	a4,a1,a2
    4e3c:	972a                	add	a4,a4,a0
    4e3e:	00074703          	lbu	a4,0(a4)
    4e42:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    4e46:	872e                	mv	a4,a1
    4e48:	02c5d5b3          	divu	a1,a1,a2
    4e4c:	0685                	addi	a3,a3,1
    4e4e:	fec773e3          	bgeu	a4,a2,4e34 <printint+0x26>
  if(neg)
    4e52:	00088b63          	beqz	a7,4e68 <printint+0x5a>
    buf[i++] = '-';
    4e56:	fd078793          	addi	a5,a5,-48
    4e5a:	97a2                	add	a5,a5,s0
    4e5c:	02d00713          	li	a4,45
    4e60:	fee78423          	sb	a4,-24(a5)
    4e64:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    4e68:	02f05663          	blez	a5,4e94 <printint+0x86>
    4e6c:	fb840713          	addi	a4,s0,-72
    4e70:	00f704b3          	add	s1,a4,a5
    4e74:	fff70993          	addi	s3,a4,-1
    4e78:	99be                	add	s3,s3,a5
    4e7a:	37fd                	addiw	a5,a5,-1
    4e7c:	1782                	slli	a5,a5,0x20
    4e7e:	9381                	srli	a5,a5,0x20
    4e80:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    4e84:	fff4c583          	lbu	a1,-1(s1)
    4e88:	854a                	mv	a0,s2
    4e8a:	f67ff0ef          	jal	ra,4df0 <putc>
  while(--i >= 0)
    4e8e:	14fd                	addi	s1,s1,-1
    4e90:	ff349ae3          	bne	s1,s3,4e84 <printint+0x76>
}
    4e94:	60a6                	ld	ra,72(sp)
    4e96:	6406                	ld	s0,64(sp)
    4e98:	74e2                	ld	s1,56(sp)
    4e9a:	7942                	ld	s2,48(sp)
    4e9c:	79a2                	ld	s3,40(sp)
    4e9e:	6161                	addi	sp,sp,80
    4ea0:	8082                	ret
    x = -xx;
    4ea2:	40b005b3          	neg	a1,a1
    neg = 1;
    4ea6:	4885                	li	a7,1
    x = -xx;
    4ea8:	bfbd                	j	4e26 <printint+0x18>

0000000000004eaa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4eaa:	7119                	addi	sp,sp,-128
    4eac:	fc86                	sd	ra,120(sp)
    4eae:	f8a2                	sd	s0,112(sp)
    4eb0:	f4a6                	sd	s1,104(sp)
    4eb2:	f0ca                	sd	s2,96(sp)
    4eb4:	ecce                	sd	s3,88(sp)
    4eb6:	e8d2                	sd	s4,80(sp)
    4eb8:	e4d6                	sd	s5,72(sp)
    4eba:	e0da                	sd	s6,64(sp)
    4ebc:	fc5e                	sd	s7,56(sp)
    4ebe:	f862                	sd	s8,48(sp)
    4ec0:	f466                	sd	s9,40(sp)
    4ec2:	f06a                	sd	s10,32(sp)
    4ec4:	ec6e                	sd	s11,24(sp)
    4ec6:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4ec8:	0005c903          	lbu	s2,0(a1)
    4ecc:	24090c63          	beqz	s2,5124 <vprintf+0x27a>
    4ed0:	8b2a                	mv	s6,a0
    4ed2:	8a2e                	mv	s4,a1
    4ed4:	8bb2                	mv	s7,a2
  state = 0;
    4ed6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    4ed8:	4481                	li	s1,0
    4eda:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    4edc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    4ee0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    4ee4:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    4ee8:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4eec:	00003c97          	auipc	s9,0x3
    4ef0:	a3cc8c93          	addi	s9,s9,-1476 # 7928 <digits>
    4ef4:	a005                	j	4f14 <vprintf+0x6a>
        putc(fd, c0);
    4ef6:	85ca                	mv	a1,s2
    4ef8:	855a                	mv	a0,s6
    4efa:	ef7ff0ef          	jal	ra,4df0 <putc>
    4efe:	a019                	j	4f04 <vprintf+0x5a>
    } else if(state == '%'){
    4f00:	03598263          	beq	s3,s5,4f24 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    4f04:	2485                	addiw	s1,s1,1
    4f06:	8726                	mv	a4,s1
    4f08:	009a07b3          	add	a5,s4,s1
    4f0c:	0007c903          	lbu	s2,0(a5)
    4f10:	20090a63          	beqz	s2,5124 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
    4f14:	0009079b          	sext.w	a5,s2
    if(state == 0){
    4f18:	fe0994e3          	bnez	s3,4f00 <vprintf+0x56>
      if(c0 == '%'){
    4f1c:	fd579de3          	bne	a5,s5,4ef6 <vprintf+0x4c>
        state = '%';
    4f20:	89be                	mv	s3,a5
    4f22:	b7cd                	j	4f04 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
    4f24:	c3c1                	beqz	a5,4fa4 <vprintf+0xfa>
    4f26:	00ea06b3          	add	a3,s4,a4
    4f2a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    4f2e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    4f30:	c681                	beqz	a3,4f38 <vprintf+0x8e>
    4f32:	9752                	add	a4,a4,s4
    4f34:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    4f38:	03878e63          	beq	a5,s8,4f74 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
    4f3c:	05a78863          	beq	a5,s10,4f8c <vprintf+0xe2>
      } else if(c0 == 'u'){
    4f40:	0db78b63          	beq	a5,s11,5016 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    4f44:	07800713          	li	a4,120
    4f48:	10e78d63          	beq	a5,a4,5062 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    4f4c:	07000713          	li	a4,112
    4f50:	14e78263          	beq	a5,a4,5094 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    4f54:	06300713          	li	a4,99
    4f58:	16e78f63          	beq	a5,a4,50d6 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    4f5c:	07300713          	li	a4,115
    4f60:	18e78563          	beq	a5,a4,50ea <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    4f64:	05579063          	bne	a5,s5,4fa4 <vprintf+0xfa>
        putc(fd, '%');
    4f68:	85d6                	mv	a1,s5
    4f6a:	855a                	mv	a0,s6
    4f6c:	e85ff0ef          	jal	ra,4df0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    4f70:	4981                	li	s3,0
    4f72:	bf49                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
    4f74:	008b8913          	addi	s2,s7,8
    4f78:	4685                	li	a3,1
    4f7a:	4629                	li	a2,10
    4f7c:	000ba583          	lw	a1,0(s7)
    4f80:	855a                	mv	a0,s6
    4f82:	e8dff0ef          	jal	ra,4e0e <printint>
    4f86:	8bca                	mv	s7,s2
      state = 0;
    4f88:	4981                	li	s3,0
    4f8a:	bfad                	j	4f04 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
    4f8c:	03868663          	beq	a3,s8,4fb8 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4f90:	05a68163          	beq	a3,s10,4fd2 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
    4f94:	09b68d63          	beq	a3,s11,502e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    4f98:	03a68f63          	beq	a3,s10,4fd6 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
    4f9c:	07800793          	li	a5,120
    4fa0:	0cf68d63          	beq	a3,a5,507a <vprintf+0x1d0>
        putc(fd, '%');
    4fa4:	85d6                	mv	a1,s5
    4fa6:	855a                	mv	a0,s6
    4fa8:	e49ff0ef          	jal	ra,4df0 <putc>
        putc(fd, c0);
    4fac:	85ca                	mv	a1,s2
    4fae:	855a                	mv	a0,s6
    4fb0:	e41ff0ef          	jal	ra,4df0 <putc>
      state = 0;
    4fb4:	4981                	li	s3,0
    4fb6:	b7b9                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    4fb8:	008b8913          	addi	s2,s7,8
    4fbc:	4685                	li	a3,1
    4fbe:	4629                	li	a2,10
    4fc0:	000bb583          	ld	a1,0(s7)
    4fc4:	855a                	mv	a0,s6
    4fc6:	e49ff0ef          	jal	ra,4e0e <printint>
        i += 1;
    4fca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    4fcc:	8bca                	mv	s7,s2
      state = 0;
    4fce:	4981                	li	s3,0
        i += 1;
    4fd0:	bf15                	j	4f04 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4fd2:	03860563          	beq	a2,s8,4ffc <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    4fd6:	07b60963          	beq	a2,s11,5048 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    4fda:	07800793          	li	a5,120
    4fde:	fcf613e3          	bne	a2,a5,4fa4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    4fe2:	008b8913          	addi	s2,s7,8
    4fe6:	4681                	li	a3,0
    4fe8:	4641                	li	a2,16
    4fea:	000bb583          	ld	a1,0(s7)
    4fee:	855a                	mv	a0,s6
    4ff0:	e1fff0ef          	jal	ra,4e0e <printint>
        i += 2;
    4ff4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    4ff6:	8bca                	mv	s7,s2
      state = 0;
    4ff8:	4981                	li	s3,0
        i += 2;
    4ffa:	b729                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    4ffc:	008b8913          	addi	s2,s7,8
    5000:	4685                	li	a3,1
    5002:	4629                	li	a2,10
    5004:	000bb583          	ld	a1,0(s7)
    5008:	855a                	mv	a0,s6
    500a:	e05ff0ef          	jal	ra,4e0e <printint>
        i += 2;
    500e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    5010:	8bca                	mv	s7,s2
      state = 0;
    5012:	4981                	li	s3,0
        i += 2;
    5014:	bdc5                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    5016:	008b8913          	addi	s2,s7,8
    501a:	4681                	li	a3,0
    501c:	4629                	li	a2,10
    501e:	000be583          	lwu	a1,0(s7)
    5022:	855a                	mv	a0,s6
    5024:	debff0ef          	jal	ra,4e0e <printint>
    5028:	8bca                	mv	s7,s2
      state = 0;
    502a:	4981                	li	s3,0
    502c:	bde1                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    502e:	008b8913          	addi	s2,s7,8
    5032:	4681                	li	a3,0
    5034:	4629                	li	a2,10
    5036:	000bb583          	ld	a1,0(s7)
    503a:	855a                	mv	a0,s6
    503c:	dd3ff0ef          	jal	ra,4e0e <printint>
        i += 1;
    5040:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    5042:	8bca                	mv	s7,s2
      state = 0;
    5044:	4981                	li	s3,0
        i += 1;
    5046:	bd7d                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5048:	008b8913          	addi	s2,s7,8
    504c:	4681                	li	a3,0
    504e:	4629                	li	a2,10
    5050:	000bb583          	ld	a1,0(s7)
    5054:	855a                	mv	a0,s6
    5056:	db9ff0ef          	jal	ra,4e0e <printint>
        i += 2;
    505a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    505c:	8bca                	mv	s7,s2
      state = 0;
    505e:	4981                	li	s3,0
        i += 2;
    5060:	b555                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    5062:	008b8913          	addi	s2,s7,8
    5066:	4681                	li	a3,0
    5068:	4641                	li	a2,16
    506a:	000be583          	lwu	a1,0(s7)
    506e:	855a                	mv	a0,s6
    5070:	d9fff0ef          	jal	ra,4e0e <printint>
    5074:	8bca                	mv	s7,s2
      state = 0;
    5076:	4981                	li	s3,0
    5078:	b571                	j	4f04 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    507a:	008b8913          	addi	s2,s7,8
    507e:	4681                	li	a3,0
    5080:	4641                	li	a2,16
    5082:	000bb583          	ld	a1,0(s7)
    5086:	855a                	mv	a0,s6
    5088:	d87ff0ef          	jal	ra,4e0e <printint>
        i += 1;
    508c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    508e:	8bca                	mv	s7,s2
      state = 0;
    5090:	4981                	li	s3,0
        i += 1;
    5092:	bd8d                	j	4f04 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
    5094:	008b8793          	addi	a5,s7,8
    5098:	f8f43423          	sd	a5,-120(s0)
    509c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    50a0:	03000593          	li	a1,48
    50a4:	855a                	mv	a0,s6
    50a6:	d4bff0ef          	jal	ra,4df0 <putc>
  putc(fd, 'x');
    50aa:	07800593          	li	a1,120
    50ae:	855a                	mv	a0,s6
    50b0:	d41ff0ef          	jal	ra,4df0 <putc>
    50b4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    50b6:	03c9d793          	srli	a5,s3,0x3c
    50ba:	97e6                	add	a5,a5,s9
    50bc:	0007c583          	lbu	a1,0(a5)
    50c0:	855a                	mv	a0,s6
    50c2:	d2fff0ef          	jal	ra,4df0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    50c6:	0992                	slli	s3,s3,0x4
    50c8:	397d                	addiw	s2,s2,-1
    50ca:	fe0916e3          	bnez	s2,50b6 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
    50ce:	f8843b83          	ld	s7,-120(s0)
      state = 0;
    50d2:	4981                	li	s3,0
    50d4:	bd05                	j	4f04 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
    50d6:	008b8913          	addi	s2,s7,8
    50da:	000bc583          	lbu	a1,0(s7)
    50de:	855a                	mv	a0,s6
    50e0:	d11ff0ef          	jal	ra,4df0 <putc>
    50e4:	8bca                	mv	s7,s2
      state = 0;
    50e6:	4981                	li	s3,0
    50e8:	bd31                	j	4f04 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
    50ea:	008b8993          	addi	s3,s7,8
    50ee:	000bb903          	ld	s2,0(s7)
    50f2:	00090f63          	beqz	s2,5110 <vprintf+0x266>
        for(; *s; s++)
    50f6:	00094583          	lbu	a1,0(s2)
    50fa:	c195                	beqz	a1,511e <vprintf+0x274>
          putc(fd, *s);
    50fc:	855a                	mv	a0,s6
    50fe:	cf3ff0ef          	jal	ra,4df0 <putc>
        for(; *s; s++)
    5102:	0905                	addi	s2,s2,1
    5104:	00094583          	lbu	a1,0(s2)
    5108:	f9f5                	bnez	a1,50fc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
    510a:	8bce                	mv	s7,s3
      state = 0;
    510c:	4981                	li	s3,0
    510e:	bbdd                	j	4f04 <vprintf+0x5a>
          s = "(null)";
    5110:	00003917          	auipc	s2,0x3
    5114:	81090913          	addi	s2,s2,-2032 # 7920 <malloc+0x2700>
        for(; *s; s++)
    5118:	02800593          	li	a1,40
    511c:	b7c5                	j	50fc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
    511e:	8bce                	mv	s7,s3
      state = 0;
    5120:	4981                	li	s3,0
    5122:	b3cd                	j	4f04 <vprintf+0x5a>
    }
  }
}
    5124:	70e6                	ld	ra,120(sp)
    5126:	7446                	ld	s0,112(sp)
    5128:	74a6                	ld	s1,104(sp)
    512a:	7906                	ld	s2,96(sp)
    512c:	69e6                	ld	s3,88(sp)
    512e:	6a46                	ld	s4,80(sp)
    5130:	6aa6                	ld	s5,72(sp)
    5132:	6b06                	ld	s6,64(sp)
    5134:	7be2                	ld	s7,56(sp)
    5136:	7c42                	ld	s8,48(sp)
    5138:	7ca2                	ld	s9,40(sp)
    513a:	7d02                	ld	s10,32(sp)
    513c:	6de2                	ld	s11,24(sp)
    513e:	6109                	addi	sp,sp,128
    5140:	8082                	ret

0000000000005142 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5142:	715d                	addi	sp,sp,-80
    5144:	ec06                	sd	ra,24(sp)
    5146:	e822                	sd	s0,16(sp)
    5148:	1000                	addi	s0,sp,32
    514a:	e010                	sd	a2,0(s0)
    514c:	e414                	sd	a3,8(s0)
    514e:	e818                	sd	a4,16(s0)
    5150:	ec1c                	sd	a5,24(s0)
    5152:	03043023          	sd	a6,32(s0)
    5156:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    515a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    515e:	8622                	mv	a2,s0
    5160:	d4bff0ef          	jal	ra,4eaa <vprintf>
}
    5164:	60e2                	ld	ra,24(sp)
    5166:	6442                	ld	s0,16(sp)
    5168:	6161                	addi	sp,sp,80
    516a:	8082                	ret

000000000000516c <printf>:

void
printf(const char *fmt, ...)
{
    516c:	711d                	addi	sp,sp,-96
    516e:	ec06                	sd	ra,24(sp)
    5170:	e822                	sd	s0,16(sp)
    5172:	1000                	addi	s0,sp,32
    5174:	e40c                	sd	a1,8(s0)
    5176:	e810                	sd	a2,16(s0)
    5178:	ec14                	sd	a3,24(s0)
    517a:	f018                	sd	a4,32(s0)
    517c:	f41c                	sd	a5,40(s0)
    517e:	03043823          	sd	a6,48(s0)
    5182:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5186:	00840613          	addi	a2,s0,8
    518a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    518e:	85aa                	mv	a1,a0
    5190:	4505                	li	a0,1
    5192:	d19ff0ef          	jal	ra,4eaa <vprintf>
}
    5196:	60e2                	ld	ra,24(sp)
    5198:	6442                	ld	s0,16(sp)
    519a:	6125                	addi	sp,sp,96
    519c:	8082                	ret

000000000000519e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    519e:	1141                	addi	sp,sp,-16
    51a0:	e422                	sd	s0,8(sp)
    51a2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    51a4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    51a8:	00003797          	auipc	a5,0x3
    51ac:	2e87b783          	ld	a5,744(a5) # 8490 <freep>
    51b0:	a02d                	j	51da <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    51b2:	4618                	lw	a4,8(a2)
    51b4:	9f2d                	addw	a4,a4,a1
    51b6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    51ba:	6398                	ld	a4,0(a5)
    51bc:	6310                	ld	a2,0(a4)
    51be:	a83d                	j	51fc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    51c0:	ff852703          	lw	a4,-8(a0)
    51c4:	9f31                	addw	a4,a4,a2
    51c6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    51c8:	ff053683          	ld	a3,-16(a0)
    51cc:	a091                	j	5210 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    51ce:	6398                	ld	a4,0(a5)
    51d0:	00e7e463          	bltu	a5,a4,51d8 <free+0x3a>
    51d4:	00e6ea63          	bltu	a3,a4,51e8 <free+0x4a>
{
    51d8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    51da:	fed7fae3          	bgeu	a5,a3,51ce <free+0x30>
    51de:	6398                	ld	a4,0(a5)
    51e0:	00e6e463          	bltu	a3,a4,51e8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    51e4:	fee7eae3          	bltu	a5,a4,51d8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    51e8:	ff852583          	lw	a1,-8(a0)
    51ec:	6390                	ld	a2,0(a5)
    51ee:	02059813          	slli	a6,a1,0x20
    51f2:	01c85713          	srli	a4,a6,0x1c
    51f6:	9736                	add	a4,a4,a3
    51f8:	fae60de3          	beq	a2,a4,51b2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    51fc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5200:	4790                	lw	a2,8(a5)
    5202:	02061593          	slli	a1,a2,0x20
    5206:	01c5d713          	srli	a4,a1,0x1c
    520a:	973e                	add	a4,a4,a5
    520c:	fae68ae3          	beq	a3,a4,51c0 <free+0x22>
    p->s.ptr = bp->s.ptr;
    5210:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    5212:	00003717          	auipc	a4,0x3
    5216:	26f73f23          	sd	a5,638(a4) # 8490 <freep>
}
    521a:	6422                	ld	s0,8(sp)
    521c:	0141                	addi	sp,sp,16
    521e:	8082                	ret

0000000000005220 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5220:	7139                	addi	sp,sp,-64
    5222:	fc06                	sd	ra,56(sp)
    5224:	f822                	sd	s0,48(sp)
    5226:	f426                	sd	s1,40(sp)
    5228:	f04a                	sd	s2,32(sp)
    522a:	ec4e                	sd	s3,24(sp)
    522c:	e852                	sd	s4,16(sp)
    522e:	e456                	sd	s5,8(sp)
    5230:	e05a                	sd	s6,0(sp)
    5232:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5234:	02051493          	slli	s1,a0,0x20
    5238:	9081                	srli	s1,s1,0x20
    523a:	04bd                	addi	s1,s1,15
    523c:	8091                	srli	s1,s1,0x4
    523e:	0014899b          	addiw	s3,s1,1
    5242:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5244:	00003517          	auipc	a0,0x3
    5248:	24c53503          	ld	a0,588(a0) # 8490 <freep>
    524c:	c515                	beqz	a0,5278 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    524e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5250:	4798                	lw	a4,8(a5)
    5252:	02977f63          	bgeu	a4,s1,5290 <malloc+0x70>
    5256:	8a4e                	mv	s4,s3
    5258:	0009871b          	sext.w	a4,s3
    525c:	6685                	lui	a3,0x1
    525e:	00d77363          	bgeu	a4,a3,5264 <malloc+0x44>
    5262:	6a05                	lui	s4,0x1
    5264:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5268:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    526c:	00003917          	auipc	s2,0x3
    5270:	22490913          	addi	s2,s2,548 # 8490 <freep>
  if(p == SBRK_ERROR)
    5274:	5afd                	li	s5,-1
    5276:	a885                	j	52e6 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
    5278:	0000a797          	auipc	a5,0xa
    527c:	a4078793          	addi	a5,a5,-1472 # ecb8 <base>
    5280:	00003717          	auipc	a4,0x3
    5284:	20f73823          	sd	a5,528(a4) # 8490 <freep>
    5288:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    528a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    528e:	b7e1                	j	5256 <malloc+0x36>
      if(p->s.size == nunits)
    5290:	02e48c63          	beq	s1,a4,52c8 <malloc+0xa8>
        p->s.size -= nunits;
    5294:	4137073b          	subw	a4,a4,s3
    5298:	c798                	sw	a4,8(a5)
        p += p->s.size;
    529a:	02071693          	slli	a3,a4,0x20
    529e:	01c6d713          	srli	a4,a3,0x1c
    52a2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    52a4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    52a8:	00003717          	auipc	a4,0x3
    52ac:	1ea73423          	sd	a0,488(a4) # 8490 <freep>
      return (void*)(p + 1);
    52b0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    52b4:	70e2                	ld	ra,56(sp)
    52b6:	7442                	ld	s0,48(sp)
    52b8:	74a2                	ld	s1,40(sp)
    52ba:	7902                	ld	s2,32(sp)
    52bc:	69e2                	ld	s3,24(sp)
    52be:	6a42                	ld	s4,16(sp)
    52c0:	6aa2                	ld	s5,8(sp)
    52c2:	6b02                	ld	s6,0(sp)
    52c4:	6121                	addi	sp,sp,64
    52c6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    52c8:	6398                	ld	a4,0(a5)
    52ca:	e118                	sd	a4,0(a0)
    52cc:	bff1                	j	52a8 <malloc+0x88>
  hp->s.size = nu;
    52ce:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    52d2:	0541                	addi	a0,a0,16
    52d4:	ecbff0ef          	jal	ra,519e <free>
  return freep;
    52d8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    52dc:	dd61                	beqz	a0,52b4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    52de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    52e0:	4798                	lw	a4,8(a5)
    52e2:	fa9777e3          	bgeu	a4,s1,5290 <malloc+0x70>
    if(p == freep)
    52e6:	00093703          	ld	a4,0(s2)
    52ea:	853e                	mv	a0,a5
    52ec:	fef719e3          	bne	a4,a5,52de <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
    52f0:	8552                	mv	a0,s4
    52f2:	a0bff0ef          	jal	ra,4cfc <sbrk>
  if(p == SBRK_ERROR)
    52f6:	fd551ce3          	bne	a0,s5,52ce <malloc+0xae>
        return 0;
    52fa:	4501                	li	a0,0
    52fc:	bf65                	j	52b4 <malloc+0x94>
