
user/_grind：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	ra,0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7159                	addi	sp,sp,-112
      76:	f486                	sd	ra,104(sp)
      78:	f0a2                	sd	s0,96(sp)
      7a:	eca6                	sd	s1,88(sp)
      7c:	e8ca                	sd	s2,80(sp)
      7e:	e4ce                	sd	s3,72(sp)
      80:	e0d2                	sd	s4,64(sp)
      82:	fc56                	sd	s5,56(sp)
      84:	f85a                	sd	s6,48(sp)
      86:	1880                	addi	s0,sp,112
      88:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8a:	4501                	li	a0,0
      8c:	2a1000ef          	jal	ra,b2c <sbrk>
      90:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      92:	00001517          	auipc	a0,0x1
      96:	0be50513          	addi	a0,a0,190 # 1150 <malloc+0xe0>
      9a:	32f000ef          	jal	ra,bc8 <mkdir>
  if(chdir("grindir") != 0){
      9e:	00001517          	auipc	a0,0x1
      a2:	0b250513          	addi	a0,a0,178 # 1150 <malloc+0xe0>
      a6:	32b000ef          	jal	ra,bd0 <chdir>
      aa:	c911                	beqz	a0,be <go+0x4a>
    printf("grind: chdir grindir failed\n");
      ac:	00001517          	auipc	a0,0x1
      b0:	0ac50513          	addi	a0,a0,172 # 1158 <malloc+0xe8>
      b4:	709000ef          	jal	ra,fbc <printf>
    exit(1);
      b8:	4505                	li	a0,1
      ba:	2a7000ef          	jal	ra,b60 <exit>
  }
  chdir("/");
      be:	00001517          	auipc	a0,0x1
      c2:	0ba50513          	addi	a0,a0,186 # 1178 <malloc+0x108>
      c6:	30b000ef          	jal	ra,bd0 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      ca:	00001997          	auipc	s3,0x1
      ce:	0be98993          	addi	s3,s3,190 # 1188 <malloc+0x118>
      d2:	c489                	beqz	s1,dc <go+0x68>
      d4:	00001997          	auipc	s3,0x1
      d8:	0ac98993          	addi	s3,s3,172 # 1180 <malloc+0x110>
    iters++;
      dc:	4485                	li	s1,1
  int fd = -1;
      de:	5a7d                	li	s4,-1
      e0:	00001917          	auipc	s2,0x1
      e4:	35890913          	addi	s2,s2,856 # 1438 <malloc+0x3c8>
      e8:	a035                	j	114 <go+0xa0>
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
      ea:	20200593          	li	a1,514
      ee:	00001517          	auipc	a0,0x1
      f2:	0a250513          	addi	a0,a0,162 # 1190 <malloc+0x120>
      f6:	2ab000ef          	jal	ra,ba0 <open>
      fa:	28f000ef          	jal	ra,b88 <close>
    iters++;
      fe:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     100:	1f400793          	li	a5,500
     104:	02f4f7b3          	remu	a5,s1,a5
     108:	e791                	bnez	a5,114 <go+0xa0>
      write(1, which_child?"B":"A", 1);
     10a:	4605                	li	a2,1
     10c:	85ce                	mv	a1,s3
     10e:	4505                	li	a0,1
     110:	271000ef          	jal	ra,b80 <write>
    int what = rand() % 23;
     114:	f45ff0ef          	jal	ra,58 <rand>
     118:	47dd                	li	a5,23
     11a:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     11e:	4785                	li	a5,1
     120:	fcf505e3          	beq	a0,a5,ea <go+0x76>
    } else if(what == 2){
     124:	47d9                	li	a5,22
     126:	fca7ece3          	bltu	a5,a0,fe <go+0x8a>
     12a:	050a                	slli	a0,a0,0x2
     12c:	954a                	add	a0,a0,s2
     12e:	411c                	lw	a5,0(a0)
     130:	97ca                	add	a5,a5,s2
     132:	8782                	jr	a5
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     134:	20200593          	li	a1,514
     138:	00001517          	auipc	a0,0x1
     13c:	06850513          	addi	a0,a0,104 # 11a0 <malloc+0x130>
     140:	261000ef          	jal	ra,ba0 <open>
     144:	245000ef          	jal	ra,b88 <close>
     148:	bf5d                	j	fe <go+0x8a>
    } else if(what == 3){
      unlink("grindir/../a");
     14a:	00001517          	auipc	a0,0x1
     14e:	04650513          	addi	a0,a0,70 # 1190 <malloc+0x120>
     152:	25f000ef          	jal	ra,bb0 <unlink>
     156:	b765                	j	fe <go+0x8a>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     158:	00001517          	auipc	a0,0x1
     15c:	ff850513          	addi	a0,a0,-8 # 1150 <malloc+0xe0>
     160:	271000ef          	jal	ra,bd0 <chdir>
     164:	ed11                	bnez	a0,180 <go+0x10c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     166:	00001517          	auipc	a0,0x1
     16a:	05250513          	addi	a0,a0,82 # 11b8 <malloc+0x148>
     16e:	243000ef          	jal	ra,bb0 <unlink>
      chdir("/");
     172:	00001517          	auipc	a0,0x1
     176:	00650513          	addi	a0,a0,6 # 1178 <malloc+0x108>
     17a:	257000ef          	jal	ra,bd0 <chdir>
     17e:	b741                	j	fe <go+0x8a>
        printf("grind: chdir grindir failed\n");
     180:	00001517          	auipc	a0,0x1
     184:	fd850513          	addi	a0,a0,-40 # 1158 <malloc+0xe8>
     188:	635000ef          	jal	ra,fbc <printf>
        exit(1);
     18c:	4505                	li	a0,1
     18e:	1d3000ef          	jal	ra,b60 <exit>
    } else if(what == 5){
      close(fd);
     192:	8552                	mv	a0,s4
     194:	1f5000ef          	jal	ra,b88 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     198:	20200593          	li	a1,514
     19c:	00001517          	auipc	a0,0x1
     1a0:	02450513          	addi	a0,a0,36 # 11c0 <malloc+0x150>
     1a4:	1fd000ef          	jal	ra,ba0 <open>
     1a8:	8a2a                	mv	s4,a0
     1aa:	bf91                	j	fe <go+0x8a>
    } else if(what == 6){
      close(fd);
     1ac:	8552                	mv	a0,s4
     1ae:	1db000ef          	jal	ra,b88 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     1b2:	20200593          	li	a1,514
     1b6:	00001517          	auipc	a0,0x1
     1ba:	01a50513          	addi	a0,a0,26 # 11d0 <malloc+0x160>
     1be:	1e3000ef          	jal	ra,ba0 <open>
     1c2:	8a2a                	mv	s4,a0
     1c4:	bf2d                	j	fe <go+0x8a>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     1c6:	3e700613          	li	a2,999
     1ca:	00002597          	auipc	a1,0x2
     1ce:	e5658593          	addi	a1,a1,-426 # 2020 <buf.0>
     1d2:	8552                	mv	a0,s4
     1d4:	1ad000ef          	jal	ra,b80 <write>
     1d8:	b71d                	j	fe <go+0x8a>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     1da:	3e700613          	li	a2,999
     1de:	00002597          	auipc	a1,0x2
     1e2:	e4258593          	addi	a1,a1,-446 # 2020 <buf.0>
     1e6:	8552                	mv	a0,s4
     1e8:	191000ef          	jal	ra,b78 <read>
     1ec:	bf09                	j	fe <go+0x8a>
    } else if(what == 9){
      mkdir("grindir/../a");
     1ee:	00001517          	auipc	a0,0x1
     1f2:	fa250513          	addi	a0,a0,-94 # 1190 <malloc+0x120>
     1f6:	1d3000ef          	jal	ra,bc8 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     1fa:	20200593          	li	a1,514
     1fe:	00001517          	auipc	a0,0x1
     202:	fea50513          	addi	a0,a0,-22 # 11e8 <malloc+0x178>
     206:	19b000ef          	jal	ra,ba0 <open>
     20a:	17f000ef          	jal	ra,b88 <close>
      unlink("a/a");
     20e:	00001517          	auipc	a0,0x1
     212:	fea50513          	addi	a0,a0,-22 # 11f8 <malloc+0x188>
     216:	19b000ef          	jal	ra,bb0 <unlink>
     21a:	b5d5                	j	fe <go+0x8a>
    } else if(what == 10){
      mkdir("/../b");
     21c:	00001517          	auipc	a0,0x1
     220:	fe450513          	addi	a0,a0,-28 # 1200 <malloc+0x190>
     224:	1a5000ef          	jal	ra,bc8 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     228:	20200593          	li	a1,514
     22c:	00001517          	auipc	a0,0x1
     230:	fdc50513          	addi	a0,a0,-36 # 1208 <malloc+0x198>
     234:	16d000ef          	jal	ra,ba0 <open>
     238:	151000ef          	jal	ra,b88 <close>
      unlink("b/b");
     23c:	00001517          	auipc	a0,0x1
     240:	fdc50513          	addi	a0,a0,-36 # 1218 <malloc+0x1a8>
     244:	16d000ef          	jal	ra,bb0 <unlink>
     248:	bd5d                	j	fe <go+0x8a>
    } else if(what == 11){
      unlink("b");
     24a:	00001517          	auipc	a0,0x1
     24e:	f9650513          	addi	a0,a0,-106 # 11e0 <malloc+0x170>
     252:	15f000ef          	jal	ra,bb0 <unlink>
      link("../grindir/./../a", "../b");
     256:	00001597          	auipc	a1,0x1
     25a:	f6258593          	addi	a1,a1,-158 # 11b8 <malloc+0x148>
     25e:	00001517          	auipc	a0,0x1
     262:	fc250513          	addi	a0,a0,-62 # 1220 <malloc+0x1b0>
     266:	15b000ef          	jal	ra,bc0 <link>
     26a:	bd51                	j	fe <go+0x8a>
    } else if(what == 12){
      unlink("../grindir/../a");
     26c:	00001517          	auipc	a0,0x1
     270:	fcc50513          	addi	a0,a0,-52 # 1238 <malloc+0x1c8>
     274:	13d000ef          	jal	ra,bb0 <unlink>
      link(".././b", "/grindir/../a");
     278:	00001597          	auipc	a1,0x1
     27c:	f4858593          	addi	a1,a1,-184 # 11c0 <malloc+0x150>
     280:	00001517          	auipc	a0,0x1
     284:	fc850513          	addi	a0,a0,-56 # 1248 <malloc+0x1d8>
     288:	139000ef          	jal	ra,bc0 <link>
     28c:	bd8d                	j	fe <go+0x8a>
    } else if(what == 13){
      int pid = fork();
     28e:	0cb000ef          	jal	ra,b58 <fork>
      if(pid == 0){
     292:	c519                	beqz	a0,2a0 <go+0x22c>
        exit(0);
      } else if(pid < 0){
     294:	00054863          	bltz	a0,2a4 <go+0x230>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     298:	4501                	li	a0,0
     29a:	0cf000ef          	jal	ra,b68 <wait>
     29e:	b585                	j	fe <go+0x8a>
        exit(0);
     2a0:	0c1000ef          	jal	ra,b60 <exit>
        printf("grind: fork failed\n");
     2a4:	00001517          	auipc	a0,0x1
     2a8:	fac50513          	addi	a0,a0,-84 # 1250 <malloc+0x1e0>
     2ac:	511000ef          	jal	ra,fbc <printf>
        exit(1);
     2b0:	4505                	li	a0,1
     2b2:	0af000ef          	jal	ra,b60 <exit>
    } else if(what == 14){
      int pid = fork();
     2b6:	0a3000ef          	jal	ra,b58 <fork>
      if(pid == 0){
     2ba:	c519                	beqz	a0,2c8 <go+0x254>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     2bc:	00054d63          	bltz	a0,2d6 <go+0x262>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2c0:	4501                	li	a0,0
     2c2:	0a7000ef          	jal	ra,b68 <wait>
     2c6:	bd25                	j	fe <go+0x8a>
        fork();
     2c8:	091000ef          	jal	ra,b58 <fork>
        fork();
     2cc:	08d000ef          	jal	ra,b58 <fork>
        exit(0);
     2d0:	4501                	li	a0,0
     2d2:	08f000ef          	jal	ra,b60 <exit>
        printf("grind: fork failed\n");
     2d6:	00001517          	auipc	a0,0x1
     2da:	f7a50513          	addi	a0,a0,-134 # 1250 <malloc+0x1e0>
     2de:	4df000ef          	jal	ra,fbc <printf>
        exit(1);
     2e2:	4505                	li	a0,1
     2e4:	07d000ef          	jal	ra,b60 <exit>
    } else if(what == 15){
      sbrk(6011);
     2e8:	6505                	lui	a0,0x1
     2ea:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x2db>
     2ee:	03f000ef          	jal	ra,b2c <sbrk>
     2f2:	b531                	j	fe <go+0x8a>
    } else if(what == 16){
      if(sbrk(0) > break0)
     2f4:	4501                	li	a0,0
     2f6:	037000ef          	jal	ra,b2c <sbrk>
     2fa:	e0aaf2e3          	bgeu	s5,a0,fe <go+0x8a>
        sbrk(-(sbrk(0) - break0));
     2fe:	4501                	li	a0,0
     300:	02d000ef          	jal	ra,b2c <sbrk>
     304:	40aa853b          	subw	a0,s5,a0
     308:	025000ef          	jal	ra,b2c <sbrk>
     30c:	bbcd                	j	fe <go+0x8a>
    } else if(what == 17){
      int pid = fork();
     30e:	04b000ef          	jal	ra,b58 <fork>
     312:	8b2a                	mv	s6,a0
      if(pid == 0){
     314:	c10d                	beqz	a0,336 <go+0x2c2>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     316:	02054d63          	bltz	a0,350 <go+0x2dc>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     31a:	00001517          	auipc	a0,0x1
     31e:	f4e50513          	addi	a0,a0,-178 # 1268 <malloc+0x1f8>
     322:	0af000ef          	jal	ra,bd0 <chdir>
     326:	ed15                	bnez	a0,362 <go+0x2ee>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     328:	855a                	mv	a0,s6
     32a:	067000ef          	jal	ra,b90 <kill>
      wait(0);
     32e:	4501                	li	a0,0
     330:	039000ef          	jal	ra,b68 <wait>
     334:	b3e9                	j	fe <go+0x8a>
        close(open("a", O_CREATE|O_RDWR));
     336:	20200593          	li	a1,514
     33a:	00001517          	auipc	a0,0x1
     33e:	ef650513          	addi	a0,a0,-266 # 1230 <malloc+0x1c0>
     342:	05f000ef          	jal	ra,ba0 <open>
     346:	043000ef          	jal	ra,b88 <close>
        exit(0);
     34a:	4501                	li	a0,0
     34c:	015000ef          	jal	ra,b60 <exit>
        printf("grind: fork failed\n");
     350:	00001517          	auipc	a0,0x1
     354:	f0050513          	addi	a0,a0,-256 # 1250 <malloc+0x1e0>
     358:	465000ef          	jal	ra,fbc <printf>
        exit(1);
     35c:	4505                	li	a0,1
     35e:	003000ef          	jal	ra,b60 <exit>
        printf("grind: chdir failed\n");
     362:	00001517          	auipc	a0,0x1
     366:	f1650513          	addi	a0,a0,-234 # 1278 <malloc+0x208>
     36a:	453000ef          	jal	ra,fbc <printf>
        exit(1);
     36e:	4505                	li	a0,1
     370:	7f0000ef          	jal	ra,b60 <exit>
    } else if(what == 18){
      int pid = fork();
     374:	7e4000ef          	jal	ra,b58 <fork>
      if(pid == 0){
     378:	c519                	beqz	a0,386 <go+0x312>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     37a:	00054d63          	bltz	a0,394 <go+0x320>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     37e:	4501                	li	a0,0
     380:	7e8000ef          	jal	ra,b68 <wait>
     384:	bbad                	j	fe <go+0x8a>
        kill(getpid());
     386:	05b000ef          	jal	ra,be0 <getpid>
     38a:	007000ef          	jal	ra,b90 <kill>
        exit(0);
     38e:	4501                	li	a0,0
     390:	7d0000ef          	jal	ra,b60 <exit>
        printf("grind: fork failed\n");
     394:	00001517          	auipc	a0,0x1
     398:	ebc50513          	addi	a0,a0,-324 # 1250 <malloc+0x1e0>
     39c:	421000ef          	jal	ra,fbc <printf>
        exit(1);
     3a0:	4505                	li	a0,1
     3a2:	7be000ef          	jal	ra,b60 <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     3a6:	fa840513          	addi	a0,s0,-88
     3aa:	7c6000ef          	jal	ra,b70 <pipe>
     3ae:	02054363          	bltz	a0,3d4 <go+0x360>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     3b2:	7a6000ef          	jal	ra,b58 <fork>
      if(pid == 0){
     3b6:	c905                	beqz	a0,3e6 <go+0x372>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     3b8:	08054263          	bltz	a0,43c <go+0x3c8>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     3bc:	fa842503          	lw	a0,-88(s0)
     3c0:	7c8000ef          	jal	ra,b88 <close>
      close(fds[1]);
     3c4:	fac42503          	lw	a0,-84(s0)
     3c8:	7c0000ef          	jal	ra,b88 <close>
      wait(0);
     3cc:	4501                	li	a0,0
     3ce:	79a000ef          	jal	ra,b68 <wait>
     3d2:	b335                	j	fe <go+0x8a>
        printf("grind: pipe failed\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	ebc50513          	addi	a0,a0,-324 # 1290 <malloc+0x220>
     3dc:	3e1000ef          	jal	ra,fbc <printf>
        exit(1);
     3e0:	4505                	li	a0,1
     3e2:	77e000ef          	jal	ra,b60 <exit>
        fork();
     3e6:	772000ef          	jal	ra,b58 <fork>
        fork();
     3ea:	76e000ef          	jal	ra,b58 <fork>
        if(write(fds[1], "x", 1) != 1)
     3ee:	4605                	li	a2,1
     3f0:	00001597          	auipc	a1,0x1
     3f4:	eb858593          	addi	a1,a1,-328 # 12a8 <malloc+0x238>
     3f8:	fac42503          	lw	a0,-84(s0)
     3fc:	784000ef          	jal	ra,b80 <write>
     400:	4785                	li	a5,1
     402:	00f51f63          	bne	a0,a5,420 <go+0x3ac>
        if(read(fds[0], &c, 1) != 1)
     406:	4605                	li	a2,1
     408:	fa040593          	addi	a1,s0,-96
     40c:	fa842503          	lw	a0,-88(s0)
     410:	768000ef          	jal	ra,b78 <read>
     414:	4785                	li	a5,1
     416:	00f51c63          	bne	a0,a5,42e <go+0x3ba>
        exit(0);
     41a:	4501                	li	a0,0
     41c:	744000ef          	jal	ra,b60 <exit>
          printf("grind: pipe write failed\n");
     420:	00001517          	auipc	a0,0x1
     424:	e9050513          	addi	a0,a0,-368 # 12b0 <malloc+0x240>
     428:	395000ef          	jal	ra,fbc <printf>
     42c:	bfe9                	j	406 <go+0x392>
          printf("grind: pipe read failed\n");
     42e:	00001517          	auipc	a0,0x1
     432:	ea250513          	addi	a0,a0,-350 # 12d0 <malloc+0x260>
     436:	387000ef          	jal	ra,fbc <printf>
     43a:	b7c5                	j	41a <go+0x3a6>
        printf("grind: fork failed\n");
     43c:	00001517          	auipc	a0,0x1
     440:	e1450513          	addi	a0,a0,-492 # 1250 <malloc+0x1e0>
     444:	379000ef          	jal	ra,fbc <printf>
        exit(1);
     448:	4505                	li	a0,1
     44a:	716000ef          	jal	ra,b60 <exit>
    } else if(what == 20){
      int pid = fork();
     44e:	70a000ef          	jal	ra,b58 <fork>
      if(pid == 0){
     452:	c519                	beqz	a0,460 <go+0x3ec>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     454:	04054f63          	bltz	a0,4b2 <go+0x43e>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     458:	4501                	li	a0,0
     45a:	70e000ef          	jal	ra,b68 <wait>
     45e:	b145                	j	fe <go+0x8a>
        unlink("a");
     460:	00001517          	auipc	a0,0x1
     464:	dd050513          	addi	a0,a0,-560 # 1230 <malloc+0x1c0>
     468:	748000ef          	jal	ra,bb0 <unlink>
        mkdir("a");
     46c:	00001517          	auipc	a0,0x1
     470:	dc450513          	addi	a0,a0,-572 # 1230 <malloc+0x1c0>
     474:	754000ef          	jal	ra,bc8 <mkdir>
        chdir("a");
     478:	00001517          	auipc	a0,0x1
     47c:	db850513          	addi	a0,a0,-584 # 1230 <malloc+0x1c0>
     480:	750000ef          	jal	ra,bd0 <chdir>
        unlink("../a");
     484:	00001517          	auipc	a0,0x1
     488:	d1450513          	addi	a0,a0,-748 # 1198 <malloc+0x128>
     48c:	724000ef          	jal	ra,bb0 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     490:	20200593          	li	a1,514
     494:	00001517          	auipc	a0,0x1
     498:	e1450513          	addi	a0,a0,-492 # 12a8 <malloc+0x238>
     49c:	704000ef          	jal	ra,ba0 <open>
        unlink("x");
     4a0:	00001517          	auipc	a0,0x1
     4a4:	e0850513          	addi	a0,a0,-504 # 12a8 <malloc+0x238>
     4a8:	708000ef          	jal	ra,bb0 <unlink>
        exit(0);
     4ac:	4501                	li	a0,0
     4ae:	6b2000ef          	jal	ra,b60 <exit>
        printf("grind: fork failed\n");
     4b2:	00001517          	auipc	a0,0x1
     4b6:	d9e50513          	addi	a0,a0,-610 # 1250 <malloc+0x1e0>
     4ba:	303000ef          	jal	ra,fbc <printf>
        exit(1);
     4be:	4505                	li	a0,1
     4c0:	6a0000ef          	jal	ra,b60 <exit>
    } else if(what == 21){
      unlink("c");
     4c4:	00001517          	auipc	a0,0x1
     4c8:	e2c50513          	addi	a0,a0,-468 # 12f0 <malloc+0x280>
     4cc:	6e4000ef          	jal	ra,bb0 <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     4d0:	20200593          	li	a1,514
     4d4:	00001517          	auipc	a0,0x1
     4d8:	e1c50513          	addi	a0,a0,-484 # 12f0 <malloc+0x280>
     4dc:	6c4000ef          	jal	ra,ba0 <open>
     4e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     4e2:	04054763          	bltz	a0,530 <go+0x4bc>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     4e6:	4605                	li	a2,1
     4e8:	00001597          	auipc	a1,0x1
     4ec:	dc058593          	addi	a1,a1,-576 # 12a8 <malloc+0x238>
     4f0:	690000ef          	jal	ra,b80 <write>
     4f4:	4785                	li	a5,1
     4f6:	04f51663          	bne	a0,a5,542 <go+0x4ce>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     4fa:	fa840593          	addi	a1,s0,-88
     4fe:	855a                	mv	a0,s6
     500:	6b8000ef          	jal	ra,bb8 <fstat>
     504:	e921                	bnez	a0,554 <go+0x4e0>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     506:	fb843583          	ld	a1,-72(s0)
     50a:	4785                	li	a5,1
     50c:	04f59d63          	bne	a1,a5,566 <go+0x4f2>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     510:	fac42583          	lw	a1,-84(s0)
     514:	0c800793          	li	a5,200
     518:	06b7e163          	bltu	a5,a1,57a <go+0x506>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     51c:	855a                	mv	a0,s6
     51e:	66a000ef          	jal	ra,b88 <close>
      unlink("c");
     522:	00001517          	auipc	a0,0x1
     526:	dce50513          	addi	a0,a0,-562 # 12f0 <malloc+0x280>
     52a:	686000ef          	jal	ra,bb0 <unlink>
     52e:	bec1                	j	fe <go+0x8a>
        printf("grind: create c failed\n");
     530:	00001517          	auipc	a0,0x1
     534:	dc850513          	addi	a0,a0,-568 # 12f8 <malloc+0x288>
     538:	285000ef          	jal	ra,fbc <printf>
        exit(1);
     53c:	4505                	li	a0,1
     53e:	622000ef          	jal	ra,b60 <exit>
        printf("grind: write c failed\n");
     542:	00001517          	auipc	a0,0x1
     546:	dce50513          	addi	a0,a0,-562 # 1310 <malloc+0x2a0>
     54a:	273000ef          	jal	ra,fbc <printf>
        exit(1);
     54e:	4505                	li	a0,1
     550:	610000ef          	jal	ra,b60 <exit>
        printf("grind: fstat failed\n");
     554:	00001517          	auipc	a0,0x1
     558:	dd450513          	addi	a0,a0,-556 # 1328 <malloc+0x2b8>
     55c:	261000ef          	jal	ra,fbc <printf>
        exit(1);
     560:	4505                	li	a0,1
     562:	5fe000ef          	jal	ra,b60 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     566:	2581                	sext.w	a1,a1
     568:	00001517          	auipc	a0,0x1
     56c:	dd850513          	addi	a0,a0,-552 # 1340 <malloc+0x2d0>
     570:	24d000ef          	jal	ra,fbc <printf>
        exit(1);
     574:	4505                	li	a0,1
     576:	5ea000ef          	jal	ra,b60 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     57a:	00001517          	auipc	a0,0x1
     57e:	dee50513          	addi	a0,a0,-530 # 1368 <malloc+0x2f8>
     582:	23b000ef          	jal	ra,fbc <printf>
        exit(1);
     586:	4505                	li	a0,1
     588:	5d8000ef          	jal	ra,b60 <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     58c:	f9840513          	addi	a0,s0,-104
     590:	5e0000ef          	jal	ra,b70 <pipe>
     594:	0c054263          	bltz	a0,658 <go+0x5e4>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     598:	fa040513          	addi	a0,s0,-96
     59c:	5d4000ef          	jal	ra,b70 <pipe>
     5a0:	0c054663          	bltz	a0,66c <go+0x5f8>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     5a4:	5b4000ef          	jal	ra,b58 <fork>
      if(pid1 == 0){
     5a8:	0c050c63          	beqz	a0,680 <go+0x60c>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     5ac:	14054e63          	bltz	a0,708 <go+0x694>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     5b0:	5a8000ef          	jal	ra,b58 <fork>
      if(pid2 == 0){
     5b4:	16050463          	beqz	a0,71c <go+0x6a8>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     5b8:	20054263          	bltz	a0,7bc <go+0x748>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     5bc:	f9842503          	lw	a0,-104(s0)
     5c0:	5c8000ef          	jal	ra,b88 <close>
      close(aa[1]);
     5c4:	f9c42503          	lw	a0,-100(s0)
     5c8:	5c0000ef          	jal	ra,b88 <close>
      close(bb[1]);
     5cc:	fa442503          	lw	a0,-92(s0)
     5d0:	5b8000ef          	jal	ra,b88 <close>
      char buf[4] = { 0, 0, 0, 0 };
     5d4:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     5d8:	4605                	li	a2,1
     5da:	f9040593          	addi	a1,s0,-112
     5de:	fa042503          	lw	a0,-96(s0)
     5e2:	596000ef          	jal	ra,b78 <read>
      read(bb[0], buf+1, 1);
     5e6:	4605                	li	a2,1
     5e8:	f9140593          	addi	a1,s0,-111
     5ec:	fa042503          	lw	a0,-96(s0)
     5f0:	588000ef          	jal	ra,b78 <read>
      read(bb[0], buf+2, 1);
     5f4:	4605                	li	a2,1
     5f6:	f9240593          	addi	a1,s0,-110
     5fa:	fa042503          	lw	a0,-96(s0)
     5fe:	57a000ef          	jal	ra,b78 <read>
      close(bb[0]);
     602:	fa042503          	lw	a0,-96(s0)
     606:	582000ef          	jal	ra,b88 <close>
      int st1, st2;
      wait(&st1);
     60a:	f9440513          	addi	a0,s0,-108
     60e:	55a000ef          	jal	ra,b68 <wait>
      wait(&st2);
     612:	fa840513          	addi	a0,s0,-88
     616:	552000ef          	jal	ra,b68 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     61a:	f9442783          	lw	a5,-108(s0)
     61e:	fa842703          	lw	a4,-88(s0)
     622:	8fd9                	or	a5,a5,a4
     624:	eb99                	bnez	a5,63a <go+0x5c6>
     626:	00001597          	auipc	a1,0x1
     62a:	de258593          	addi	a1,a1,-542 # 1408 <malloc+0x398>
     62e:	f9040513          	addi	a0,s0,-112
     632:	2c6000ef          	jal	ra,8f8 <strcmp>
     636:	ac0504e3          	beqz	a0,fe <go+0x8a>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     63a:	f9040693          	addi	a3,s0,-112
     63e:	fa842603          	lw	a2,-88(s0)
     642:	f9442583          	lw	a1,-108(s0)
     646:	00001517          	auipc	a0,0x1
     64a:	dca50513          	addi	a0,a0,-566 # 1410 <malloc+0x3a0>
     64e:	16f000ef          	jal	ra,fbc <printf>
        exit(1);
     652:	4505                	li	a0,1
     654:	50c000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: pipe failed\n");
     658:	00001597          	auipc	a1,0x1
     65c:	c3858593          	addi	a1,a1,-968 # 1290 <malloc+0x220>
     660:	4509                	li	a0,2
     662:	131000ef          	jal	ra,f92 <fprintf>
        exit(1);
     666:	4505                	li	a0,1
     668:	4f8000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: pipe failed\n");
     66c:	00001597          	auipc	a1,0x1
     670:	c2458593          	addi	a1,a1,-988 # 1290 <malloc+0x220>
     674:	4509                	li	a0,2
     676:	11d000ef          	jal	ra,f92 <fprintf>
        exit(1);
     67a:	4505                	li	a0,1
     67c:	4e4000ef          	jal	ra,b60 <exit>
        close(bb[0]);
     680:	fa042503          	lw	a0,-96(s0)
     684:	504000ef          	jal	ra,b88 <close>
        close(bb[1]);
     688:	fa442503          	lw	a0,-92(s0)
     68c:	4fc000ef          	jal	ra,b88 <close>
        close(aa[0]);
     690:	f9842503          	lw	a0,-104(s0)
     694:	4f4000ef          	jal	ra,b88 <close>
        close(1);
     698:	4505                	li	a0,1
     69a:	4ee000ef          	jal	ra,b88 <close>
        if(dup(aa[1]) != 1){
     69e:	f9c42503          	lw	a0,-100(s0)
     6a2:	536000ef          	jal	ra,bd8 <dup>
     6a6:	4785                	li	a5,1
     6a8:	00f50c63          	beq	a0,a5,6c0 <go+0x64c>
          fprintf(2, "grind: dup failed\n");
     6ac:	00001597          	auipc	a1,0x1
     6b0:	ce458593          	addi	a1,a1,-796 # 1390 <malloc+0x320>
     6b4:	4509                	li	a0,2
     6b6:	0dd000ef          	jal	ra,f92 <fprintf>
          exit(1);
     6ba:	4505                	li	a0,1
     6bc:	4a4000ef          	jal	ra,b60 <exit>
        close(aa[1]);
     6c0:	f9c42503          	lw	a0,-100(s0)
     6c4:	4c4000ef          	jal	ra,b88 <close>
        char *args[3] = { "echo", "hi", 0 };
     6c8:	00001797          	auipc	a5,0x1
     6cc:	ce078793          	addi	a5,a5,-800 # 13a8 <malloc+0x338>
     6d0:	faf43423          	sd	a5,-88(s0)
     6d4:	00001797          	auipc	a5,0x1
     6d8:	cdc78793          	addi	a5,a5,-804 # 13b0 <malloc+0x340>
     6dc:	faf43823          	sd	a5,-80(s0)
     6e0:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     6e4:	fa840593          	addi	a1,s0,-88
     6e8:	00001517          	auipc	a0,0x1
     6ec:	cd050513          	addi	a0,a0,-816 # 13b8 <malloc+0x348>
     6f0:	4a8000ef          	jal	ra,b98 <exec>
        fprintf(2, "grind: echo: not found\n");
     6f4:	00001597          	auipc	a1,0x1
     6f8:	cd458593          	addi	a1,a1,-812 # 13c8 <malloc+0x358>
     6fc:	4509                	li	a0,2
     6fe:	095000ef          	jal	ra,f92 <fprintf>
        exit(2);
     702:	4509                	li	a0,2
     704:	45c000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: fork failed\n");
     708:	00001597          	auipc	a1,0x1
     70c:	b4858593          	addi	a1,a1,-1208 # 1250 <malloc+0x1e0>
     710:	4509                	li	a0,2
     712:	081000ef          	jal	ra,f92 <fprintf>
        exit(3);
     716:	450d                	li	a0,3
     718:	448000ef          	jal	ra,b60 <exit>
        close(aa[1]);
     71c:	f9c42503          	lw	a0,-100(s0)
     720:	468000ef          	jal	ra,b88 <close>
        close(bb[0]);
     724:	fa042503          	lw	a0,-96(s0)
     728:	460000ef          	jal	ra,b88 <close>
        close(0);
     72c:	4501                	li	a0,0
     72e:	45a000ef          	jal	ra,b88 <close>
        if(dup(aa[0]) != 0){
     732:	f9842503          	lw	a0,-104(s0)
     736:	4a2000ef          	jal	ra,bd8 <dup>
     73a:	c919                	beqz	a0,750 <go+0x6dc>
          fprintf(2, "grind: dup failed\n");
     73c:	00001597          	auipc	a1,0x1
     740:	c5458593          	addi	a1,a1,-940 # 1390 <malloc+0x320>
     744:	4509                	li	a0,2
     746:	04d000ef          	jal	ra,f92 <fprintf>
          exit(4);
     74a:	4511                	li	a0,4
     74c:	414000ef          	jal	ra,b60 <exit>
        close(aa[0]);
     750:	f9842503          	lw	a0,-104(s0)
     754:	434000ef          	jal	ra,b88 <close>
        close(1);
     758:	4505                	li	a0,1
     75a:	42e000ef          	jal	ra,b88 <close>
        if(dup(bb[1]) != 1){
     75e:	fa442503          	lw	a0,-92(s0)
     762:	476000ef          	jal	ra,bd8 <dup>
     766:	4785                	li	a5,1
     768:	00f50c63          	beq	a0,a5,780 <go+0x70c>
          fprintf(2, "grind: dup failed\n");
     76c:	00001597          	auipc	a1,0x1
     770:	c2458593          	addi	a1,a1,-988 # 1390 <malloc+0x320>
     774:	4509                	li	a0,2
     776:	01d000ef          	jal	ra,f92 <fprintf>
          exit(5);
     77a:	4515                	li	a0,5
     77c:	3e4000ef          	jal	ra,b60 <exit>
        close(bb[1]);
     780:	fa442503          	lw	a0,-92(s0)
     784:	404000ef          	jal	ra,b88 <close>
        char *args[2] = { "cat", 0 };
     788:	00001797          	auipc	a5,0x1
     78c:	c5878793          	addi	a5,a5,-936 # 13e0 <malloc+0x370>
     790:	faf43423          	sd	a5,-88(s0)
     794:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     798:	fa840593          	addi	a1,s0,-88
     79c:	00001517          	auipc	a0,0x1
     7a0:	c4c50513          	addi	a0,a0,-948 # 13e8 <malloc+0x378>
     7a4:	3f4000ef          	jal	ra,b98 <exec>
        fprintf(2, "grind: cat: not found\n");
     7a8:	00001597          	auipc	a1,0x1
     7ac:	c4858593          	addi	a1,a1,-952 # 13f0 <malloc+0x380>
     7b0:	4509                	li	a0,2
     7b2:	7e0000ef          	jal	ra,f92 <fprintf>
        exit(6);
     7b6:	4519                	li	a0,6
     7b8:	3a8000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: fork failed\n");
     7bc:	00001597          	auipc	a1,0x1
     7c0:	a9458593          	addi	a1,a1,-1388 # 1250 <malloc+0x1e0>
     7c4:	4509                	li	a0,2
     7c6:	7cc000ef          	jal	ra,f92 <fprintf>
        exit(7);
     7ca:	451d                	li	a0,7
     7cc:	394000ef          	jal	ra,b60 <exit>

00000000000007d0 <iter>:
  }
}

void
iter()
{
     7d0:	7179                	addi	sp,sp,-48
     7d2:	f406                	sd	ra,40(sp)
     7d4:	f022                	sd	s0,32(sp)
     7d6:	ec26                	sd	s1,24(sp)
     7d8:	e84a                	sd	s2,16(sp)
     7da:	1800                	addi	s0,sp,48
  unlink("a");
     7dc:	00001517          	auipc	a0,0x1
     7e0:	a5450513          	addi	a0,a0,-1452 # 1230 <malloc+0x1c0>
     7e4:	3cc000ef          	jal	ra,bb0 <unlink>
  unlink("b");
     7e8:	00001517          	auipc	a0,0x1
     7ec:	9f850513          	addi	a0,a0,-1544 # 11e0 <malloc+0x170>
     7f0:	3c0000ef          	jal	ra,bb0 <unlink>
  
  int pid1 = fork();
     7f4:	364000ef          	jal	ra,b58 <fork>
  if(pid1 < 0){
     7f8:	00054f63          	bltz	a0,816 <iter+0x46>
     7fc:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     7fe:	e50d                	bnez	a0,828 <iter+0x58>
    rand_next ^= 31;
     800:	00002717          	auipc	a4,0x2
     804:	80070713          	addi	a4,a4,-2048 # 2000 <rand_next>
     808:	631c                	ld	a5,0(a4)
     80a:	01f7c793          	xori	a5,a5,31
     80e:	e31c                	sd	a5,0(a4)
    go(0);
     810:	4501                	li	a0,0
     812:	863ff0ef          	jal	ra,74 <go>
    printf("grind: fork failed\n");
     816:	00001517          	auipc	a0,0x1
     81a:	a3a50513          	addi	a0,a0,-1478 # 1250 <malloc+0x1e0>
     81e:	79e000ef          	jal	ra,fbc <printf>
    exit(1);
     822:	4505                	li	a0,1
     824:	33c000ef          	jal	ra,b60 <exit>
    exit(0);
  }

  int pid2 = fork();
     828:	330000ef          	jal	ra,b58 <fork>
     82c:	892a                	mv	s2,a0
  if(pid2 < 0){
     82e:	02054063          	bltz	a0,84e <iter+0x7e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     832:	e51d                	bnez	a0,860 <iter+0x90>
    rand_next ^= 7177;
     834:	00001697          	auipc	a3,0x1
     838:	7cc68693          	addi	a3,a3,1996 # 2000 <rand_next>
     83c:	629c                	ld	a5,0(a3)
     83e:	6709                	lui	a4,0x2
     840:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x769>
     844:	8fb9                	xor	a5,a5,a4
     846:	e29c                	sd	a5,0(a3)
    go(1);
     848:	4505                	li	a0,1
     84a:	82bff0ef          	jal	ra,74 <go>
    printf("grind: fork failed\n");
     84e:	00001517          	auipc	a0,0x1
     852:	a0250513          	addi	a0,a0,-1534 # 1250 <malloc+0x1e0>
     856:	766000ef          	jal	ra,fbc <printf>
    exit(1);
     85a:	4505                	li	a0,1
     85c:	304000ef          	jal	ra,b60 <exit>
    exit(0);
  }

  int st1 = -1;
     860:	57fd                	li	a5,-1
     862:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     866:	fdc40513          	addi	a0,s0,-36
     86a:	2fe000ef          	jal	ra,b68 <wait>
  if(st1 != 0){
     86e:	fdc42783          	lw	a5,-36(s0)
     872:	eb99                	bnez	a5,888 <iter+0xb8>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     874:	57fd                	li	a5,-1
     876:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     87a:	fd840513          	addi	a0,s0,-40
     87e:	2ea000ef          	jal	ra,b68 <wait>

  exit(0);
     882:	4501                	li	a0,0
     884:	2dc000ef          	jal	ra,b60 <exit>
    kill(pid1);
     888:	8526                	mv	a0,s1
     88a:	306000ef          	jal	ra,b90 <kill>
    kill(pid2);
     88e:	854a                	mv	a0,s2
     890:	300000ef          	jal	ra,b90 <kill>
     894:	b7c5                	j	874 <iter+0xa4>

0000000000000896 <main>:
}

int
main()
{
     896:	1101                	addi	sp,sp,-32
     898:	ec06                	sd	ra,24(sp)
     89a:	e822                	sd	s0,16(sp)
     89c:	e426                	sd	s1,8(sp)
     89e:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    pause(20);
    rand_next += 1;
     8a0:	00001497          	auipc	s1,0x1
     8a4:	76048493          	addi	s1,s1,1888 # 2000 <rand_next>
     8a8:	a809                	j	8ba <main+0x24>
      iter();
     8aa:	f27ff0ef          	jal	ra,7d0 <iter>
    pause(20);
     8ae:	4551                	li	a0,20
     8b0:	340000ef          	jal	ra,bf0 <pause>
    rand_next += 1;
     8b4:	609c                	ld	a5,0(s1)
     8b6:	0785                	addi	a5,a5,1
     8b8:	e09c                	sd	a5,0(s1)
    int pid = fork();
     8ba:	29e000ef          	jal	ra,b58 <fork>
    if(pid == 0){
     8be:	d575                	beqz	a0,8aa <main+0x14>
    if(pid > 0){
     8c0:	fea057e3          	blez	a0,8ae <main+0x18>
      wait(0);
     8c4:	4501                	li	a0,0
     8c6:	2a2000ef          	jal	ra,b68 <wait>
     8ca:	b7d5                	j	8ae <main+0x18>

00000000000008cc <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
     8cc:	1141                	addi	sp,sp,-16
     8ce:	e406                	sd	ra,8(sp)
     8d0:	e022                	sd	s0,0(sp)
     8d2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     8d4:	fc3ff0ef          	jal	ra,896 <main>
  exit(r);
     8d8:	288000ef          	jal	ra,b60 <exit>

00000000000008dc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     8dc:	1141                	addi	sp,sp,-16
     8de:	e422                	sd	s0,8(sp)
     8e0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     8e2:	87aa                	mv	a5,a0
     8e4:	0585                	addi	a1,a1,1
     8e6:	0785                	addi	a5,a5,1
     8e8:	fff5c703          	lbu	a4,-1(a1)
     8ec:	fee78fa3          	sb	a4,-1(a5)
     8f0:	fb75                	bnez	a4,8e4 <strcpy+0x8>
    ;
  return os;
}
     8f2:	6422                	ld	s0,8(sp)
     8f4:	0141                	addi	sp,sp,16
     8f6:	8082                	ret

00000000000008f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     8f8:	1141                	addi	sp,sp,-16
     8fa:	e422                	sd	s0,8(sp)
     8fc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     8fe:	00054783          	lbu	a5,0(a0)
     902:	cb91                	beqz	a5,916 <strcmp+0x1e>
     904:	0005c703          	lbu	a4,0(a1)
     908:	00f71763          	bne	a4,a5,916 <strcmp+0x1e>
    p++, q++;
     90c:	0505                	addi	a0,a0,1
     90e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     910:	00054783          	lbu	a5,0(a0)
     914:	fbe5                	bnez	a5,904 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     916:	0005c503          	lbu	a0,0(a1)
}
     91a:	40a7853b          	subw	a0,a5,a0
     91e:	6422                	ld	s0,8(sp)
     920:	0141                	addi	sp,sp,16
     922:	8082                	ret

0000000000000924 <strlen>:

uint
strlen(const char *s)
{
     924:	1141                	addi	sp,sp,-16
     926:	e422                	sd	s0,8(sp)
     928:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     92a:	00054783          	lbu	a5,0(a0)
     92e:	cf91                	beqz	a5,94a <strlen+0x26>
     930:	0505                	addi	a0,a0,1
     932:	87aa                	mv	a5,a0
     934:	4685                	li	a3,1
     936:	9e89                	subw	a3,a3,a0
     938:	00f6853b          	addw	a0,a3,a5
     93c:	0785                	addi	a5,a5,1
     93e:	fff7c703          	lbu	a4,-1(a5)
     942:	fb7d                	bnez	a4,938 <strlen+0x14>
    ;
  return n;
}
     944:	6422                	ld	s0,8(sp)
     946:	0141                	addi	sp,sp,16
     948:	8082                	ret
  for(n = 0; s[n]; n++)
     94a:	4501                	li	a0,0
     94c:	bfe5                	j	944 <strlen+0x20>

000000000000094e <memset>:

void*
memset(void *dst, int c, uint n)
{
     94e:	1141                	addi	sp,sp,-16
     950:	e422                	sd	s0,8(sp)
     952:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     954:	ca19                	beqz	a2,96a <memset+0x1c>
     956:	87aa                	mv	a5,a0
     958:	1602                	slli	a2,a2,0x20
     95a:	9201                	srli	a2,a2,0x20
     95c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     960:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     964:	0785                	addi	a5,a5,1
     966:	fee79de3          	bne	a5,a4,960 <memset+0x12>
  }
  return dst;
}
     96a:	6422                	ld	s0,8(sp)
     96c:	0141                	addi	sp,sp,16
     96e:	8082                	ret

0000000000000970 <strchr>:

char*
strchr(const char *s, char c)
{
     970:	1141                	addi	sp,sp,-16
     972:	e422                	sd	s0,8(sp)
     974:	0800                	addi	s0,sp,16
  for(; *s; s++)
     976:	00054783          	lbu	a5,0(a0)
     97a:	cb99                	beqz	a5,990 <strchr+0x20>
    if(*s == c)
     97c:	00f58763          	beq	a1,a5,98a <strchr+0x1a>
  for(; *s; s++)
     980:	0505                	addi	a0,a0,1
     982:	00054783          	lbu	a5,0(a0)
     986:	fbfd                	bnez	a5,97c <strchr+0xc>
      return (char*)s;
  return 0;
     988:	4501                	li	a0,0
}
     98a:	6422                	ld	s0,8(sp)
     98c:	0141                	addi	sp,sp,16
     98e:	8082                	ret
  return 0;
     990:	4501                	li	a0,0
     992:	bfe5                	j	98a <strchr+0x1a>

0000000000000994 <gets>:

char*
gets(char *buf, int max)
{
     994:	711d                	addi	sp,sp,-96
     996:	ec86                	sd	ra,88(sp)
     998:	e8a2                	sd	s0,80(sp)
     99a:	e4a6                	sd	s1,72(sp)
     99c:	e0ca                	sd	s2,64(sp)
     99e:	fc4e                	sd	s3,56(sp)
     9a0:	f852                	sd	s4,48(sp)
     9a2:	f456                	sd	s5,40(sp)
     9a4:	f05a                	sd	s6,32(sp)
     9a6:	ec5e                	sd	s7,24(sp)
     9a8:	1080                	addi	s0,sp,96
     9aa:	8baa                	mv	s7,a0
     9ac:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9ae:	892a                	mv	s2,a0
     9b0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     9b2:	4aa9                	li	s5,10
     9b4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     9b6:	89a6                	mv	s3,s1
     9b8:	2485                	addiw	s1,s1,1
     9ba:	0344d663          	bge	s1,s4,9e6 <gets+0x52>
    cc = read(0, &c, 1);
     9be:	4605                	li	a2,1
     9c0:	faf40593          	addi	a1,s0,-81
     9c4:	4501                	li	a0,0
     9c6:	1b2000ef          	jal	ra,b78 <read>
    if(cc < 1)
     9ca:	00a05e63          	blez	a0,9e6 <gets+0x52>
    buf[i++] = c;
     9ce:	faf44783          	lbu	a5,-81(s0)
     9d2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     9d6:	01578763          	beq	a5,s5,9e4 <gets+0x50>
     9da:	0905                	addi	s2,s2,1
     9dc:	fd679de3          	bne	a5,s6,9b6 <gets+0x22>
  for(i=0; i+1 < max; ){
     9e0:	89a6                	mv	s3,s1
     9e2:	a011                	j	9e6 <gets+0x52>
     9e4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     9e6:	99de                	add	s3,s3,s7
     9e8:	00098023          	sb	zero,0(s3)
  return buf;
}
     9ec:	855e                	mv	a0,s7
     9ee:	60e6                	ld	ra,88(sp)
     9f0:	6446                	ld	s0,80(sp)
     9f2:	64a6                	ld	s1,72(sp)
     9f4:	6906                	ld	s2,64(sp)
     9f6:	79e2                	ld	s3,56(sp)
     9f8:	7a42                	ld	s4,48(sp)
     9fa:	7aa2                	ld	s5,40(sp)
     9fc:	7b02                	ld	s6,32(sp)
     9fe:	6be2                	ld	s7,24(sp)
     a00:	6125                	addi	sp,sp,96
     a02:	8082                	ret

0000000000000a04 <stat>:

int
stat(const char *n, struct stat *st)
{
     a04:	1101                	addi	sp,sp,-32
     a06:	ec06                	sd	ra,24(sp)
     a08:	e822                	sd	s0,16(sp)
     a0a:	e426                	sd	s1,8(sp)
     a0c:	e04a                	sd	s2,0(sp)
     a0e:	1000                	addi	s0,sp,32
     a10:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a12:	4581                	li	a1,0
     a14:	18c000ef          	jal	ra,ba0 <open>
  if(fd < 0)
     a18:	02054163          	bltz	a0,a3a <stat+0x36>
     a1c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a1e:	85ca                	mv	a1,s2
     a20:	198000ef          	jal	ra,bb8 <fstat>
     a24:	892a                	mv	s2,a0
  close(fd);
     a26:	8526                	mv	a0,s1
     a28:	160000ef          	jal	ra,b88 <close>
  return r;
}
     a2c:	854a                	mv	a0,s2
     a2e:	60e2                	ld	ra,24(sp)
     a30:	6442                	ld	s0,16(sp)
     a32:	64a2                	ld	s1,8(sp)
     a34:	6902                	ld	s2,0(sp)
     a36:	6105                	addi	sp,sp,32
     a38:	8082                	ret
    return -1;
     a3a:	597d                	li	s2,-1
     a3c:	bfc5                	j	a2c <stat+0x28>

0000000000000a3e <atoi>:

int
atoi(const char *s)
{
     a3e:	1141                	addi	sp,sp,-16
     a40:	e422                	sd	s0,8(sp)
     a42:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a44:	00054683          	lbu	a3,0(a0)
     a48:	fd06879b          	addiw	a5,a3,-48
     a4c:	0ff7f793          	zext.b	a5,a5
     a50:	4625                	li	a2,9
     a52:	02f66863          	bltu	a2,a5,a82 <atoi+0x44>
     a56:	872a                	mv	a4,a0
  n = 0;
     a58:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     a5a:	0705                	addi	a4,a4,1
     a5c:	0025179b          	slliw	a5,a0,0x2
     a60:	9fa9                	addw	a5,a5,a0
     a62:	0017979b          	slliw	a5,a5,0x1
     a66:	9fb5                	addw	a5,a5,a3
     a68:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a6c:	00074683          	lbu	a3,0(a4)
     a70:	fd06879b          	addiw	a5,a3,-48
     a74:	0ff7f793          	zext.b	a5,a5
     a78:	fef671e3          	bgeu	a2,a5,a5a <atoi+0x1c>
  return n;
}
     a7c:	6422                	ld	s0,8(sp)
     a7e:	0141                	addi	sp,sp,16
     a80:	8082                	ret
  n = 0;
     a82:	4501                	li	a0,0
     a84:	bfe5                	j	a7c <atoi+0x3e>

0000000000000a86 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     a86:	1141                	addi	sp,sp,-16
     a88:	e422                	sd	s0,8(sp)
     a8a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     a8c:	02b57463          	bgeu	a0,a1,ab4 <memmove+0x2e>
    while(n-- > 0)
     a90:	00c05f63          	blez	a2,aae <memmove+0x28>
     a94:	1602                	slli	a2,a2,0x20
     a96:	9201                	srli	a2,a2,0x20
     a98:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     a9c:	872a                	mv	a4,a0
      *dst++ = *src++;
     a9e:	0585                	addi	a1,a1,1
     aa0:	0705                	addi	a4,a4,1
     aa2:	fff5c683          	lbu	a3,-1(a1)
     aa6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     aaa:	fee79ae3          	bne	a5,a4,a9e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     aae:	6422                	ld	s0,8(sp)
     ab0:	0141                	addi	sp,sp,16
     ab2:	8082                	ret
    dst += n;
     ab4:	00c50733          	add	a4,a0,a2
    src += n;
     ab8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     aba:	fec05ae3          	blez	a2,aae <memmove+0x28>
     abe:	fff6079b          	addiw	a5,a2,-1
     ac2:	1782                	slli	a5,a5,0x20
     ac4:	9381                	srli	a5,a5,0x20
     ac6:	fff7c793          	not	a5,a5
     aca:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     acc:	15fd                	addi	a1,a1,-1
     ace:	177d                	addi	a4,a4,-1
     ad0:	0005c683          	lbu	a3,0(a1)
     ad4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     ad8:	fee79ae3          	bne	a5,a4,acc <memmove+0x46>
     adc:	bfc9                	j	aae <memmove+0x28>

0000000000000ade <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     ade:	1141                	addi	sp,sp,-16
     ae0:	e422                	sd	s0,8(sp)
     ae2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     ae4:	ca05                	beqz	a2,b14 <memcmp+0x36>
     ae6:	fff6069b          	addiw	a3,a2,-1
     aea:	1682                	slli	a3,a3,0x20
     aec:	9281                	srli	a3,a3,0x20
     aee:	0685                	addi	a3,a3,1
     af0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     af2:	00054783          	lbu	a5,0(a0)
     af6:	0005c703          	lbu	a4,0(a1)
     afa:	00e79863          	bne	a5,a4,b0a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     afe:	0505                	addi	a0,a0,1
    p2++;
     b00:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b02:	fed518e3          	bne	a0,a3,af2 <memcmp+0x14>
  }
  return 0;
     b06:	4501                	li	a0,0
     b08:	a019                	j	b0e <memcmp+0x30>
      return *p1 - *p2;
     b0a:	40e7853b          	subw	a0,a5,a4
}
     b0e:	6422                	ld	s0,8(sp)
     b10:	0141                	addi	sp,sp,16
     b12:	8082                	ret
  return 0;
     b14:	4501                	li	a0,0
     b16:	bfe5                	j	b0e <memcmp+0x30>

0000000000000b18 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b18:	1141                	addi	sp,sp,-16
     b1a:	e406                	sd	ra,8(sp)
     b1c:	e022                	sd	s0,0(sp)
     b1e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b20:	f67ff0ef          	jal	ra,a86 <memmove>
}
     b24:	60a2                	ld	ra,8(sp)
     b26:	6402                	ld	s0,0(sp)
     b28:	0141                	addi	sp,sp,16
     b2a:	8082                	ret

0000000000000b2c <sbrk>:

char *
sbrk(int n) {
     b2c:	1141                	addi	sp,sp,-16
     b2e:	e406                	sd	ra,8(sp)
     b30:	e022                	sd	s0,0(sp)
     b32:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     b34:	4585                	li	a1,1
     b36:	0b2000ef          	jal	ra,be8 <sys_sbrk>
}
     b3a:	60a2                	ld	ra,8(sp)
     b3c:	6402                	ld	s0,0(sp)
     b3e:	0141                	addi	sp,sp,16
     b40:	8082                	ret

0000000000000b42 <sbrklazy>:

char *
sbrklazy(int n) {
     b42:	1141                	addi	sp,sp,-16
     b44:	e406                	sd	ra,8(sp)
     b46:	e022                	sd	s0,0(sp)
     b48:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     b4a:	4589                	li	a1,2
     b4c:	09c000ef          	jal	ra,be8 <sys_sbrk>
}
     b50:	60a2                	ld	ra,8(sp)
     b52:	6402                	ld	s0,0(sp)
     b54:	0141                	addi	sp,sp,16
     b56:	8082                	ret

0000000000000b58 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     b58:	4885                	li	a7,1
 ecall
     b5a:	00000073          	ecall
 ret
     b5e:	8082                	ret

0000000000000b60 <exit>:
.global exit
exit:
 li a7, SYS_exit
     b60:	4889                	li	a7,2
 ecall
     b62:	00000073          	ecall
 ret
     b66:	8082                	ret

0000000000000b68 <wait>:
.global wait
wait:
 li a7, SYS_wait
     b68:	488d                	li	a7,3
 ecall
     b6a:	00000073          	ecall
 ret
     b6e:	8082                	ret

0000000000000b70 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     b70:	4891                	li	a7,4
 ecall
     b72:	00000073          	ecall
 ret
     b76:	8082                	ret

0000000000000b78 <read>:
.global read
read:
 li a7, SYS_read
     b78:	4895                	li	a7,5
 ecall
     b7a:	00000073          	ecall
 ret
     b7e:	8082                	ret

0000000000000b80 <write>:
.global write
write:
 li a7, SYS_write
     b80:	48c1                	li	a7,16
 ecall
     b82:	00000073          	ecall
 ret
     b86:	8082                	ret

0000000000000b88 <close>:
.global close
close:
 li a7, SYS_close
     b88:	48d5                	li	a7,21
 ecall
     b8a:	00000073          	ecall
 ret
     b8e:	8082                	ret

0000000000000b90 <kill>:
.global kill
kill:
 li a7, SYS_kill
     b90:	4899                	li	a7,6
 ecall
     b92:	00000073          	ecall
 ret
     b96:	8082                	ret

0000000000000b98 <exec>:
.global exec
exec:
 li a7, SYS_exec
     b98:	489d                	li	a7,7
 ecall
     b9a:	00000073          	ecall
 ret
     b9e:	8082                	ret

0000000000000ba0 <open>:
.global open
open:
 li a7, SYS_open
     ba0:	48bd                	li	a7,15
 ecall
     ba2:	00000073          	ecall
 ret
     ba6:	8082                	ret

0000000000000ba8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ba8:	48c5                	li	a7,17
 ecall
     baa:	00000073          	ecall
 ret
     bae:	8082                	ret

0000000000000bb0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     bb0:	48c9                	li	a7,18
 ecall
     bb2:	00000073          	ecall
 ret
     bb6:	8082                	ret

0000000000000bb8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     bb8:	48a1                	li	a7,8
 ecall
     bba:	00000073          	ecall
 ret
     bbe:	8082                	ret

0000000000000bc0 <link>:
.global link
link:
 li a7, SYS_link
     bc0:	48cd                	li	a7,19
 ecall
     bc2:	00000073          	ecall
 ret
     bc6:	8082                	ret

0000000000000bc8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     bc8:	48d1                	li	a7,20
 ecall
     bca:	00000073          	ecall
 ret
     bce:	8082                	ret

0000000000000bd0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     bd0:	48a5                	li	a7,9
 ecall
     bd2:	00000073          	ecall
 ret
     bd6:	8082                	ret

0000000000000bd8 <dup>:
.global dup
dup:
 li a7, SYS_dup
     bd8:	48a9                	li	a7,10
 ecall
     bda:	00000073          	ecall
 ret
     bde:	8082                	ret

0000000000000be0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     be0:	48ad                	li	a7,11
 ecall
     be2:	00000073          	ecall
 ret
     be6:	8082                	ret

0000000000000be8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     be8:	48b1                	li	a7,12
 ecall
     bea:	00000073          	ecall
 ret
     bee:	8082                	ret

0000000000000bf0 <pause>:
.global pause
pause:
 li a7, SYS_pause
     bf0:	48b5                	li	a7,13
 ecall
     bf2:	00000073          	ecall
 ret
     bf6:	8082                	ret

0000000000000bf8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     bf8:	48b9                	li	a7,14
 ecall
     bfa:	00000073          	ecall
 ret
     bfe:	8082                	ret

0000000000000c00 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
     c00:	48d9                	li	a7,22
 ecall
     c02:	00000073          	ecall
 ret
     c06:	8082                	ret

0000000000000c08 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
     c08:	48dd                	li	a7,23
 ecall
     c0a:	00000073          	ecall
 ret
     c0e:	8082                	ret

0000000000000c10 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
     c10:	48e1                	li	a7,24
 ecall
     c12:	00000073          	ecall
 ret
     c16:	8082                	ret

0000000000000c18 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     c18:	48e5                	li	a7,25
 ecall
     c1a:	00000073          	ecall
 ret
     c1e:	8082                	ret

0000000000000c20 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
     c20:	48e9                	li	a7,26
 ecall
     c22:	00000073          	ecall
 ret
     c26:	8082                	ret

0000000000000c28 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
     c28:	48ed                	li	a7,27
 ecall
     c2a:	00000073          	ecall
 ret
     c2e:	8082                	ret

0000000000000c30 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
     c30:	48f1                	li	a7,28
 ecall
     c32:	00000073          	ecall
 ret
     c36:	8082                	ret

0000000000000c38 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
     c38:	48f5                	li	a7,29
 ecall
     c3a:	00000073          	ecall
 ret
     c3e:	8082                	ret

0000000000000c40 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c40:	1101                	addi	sp,sp,-32
     c42:	ec06                	sd	ra,24(sp)
     c44:	e822                	sd	s0,16(sp)
     c46:	1000                	addi	s0,sp,32
     c48:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c4c:	4605                	li	a2,1
     c4e:	fef40593          	addi	a1,s0,-17
     c52:	f2fff0ef          	jal	ra,b80 <write>
}
     c56:	60e2                	ld	ra,24(sp)
     c58:	6442                	ld	s0,16(sp)
     c5a:	6105                	addi	sp,sp,32
     c5c:	8082                	ret

0000000000000c5e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c5e:	715d                	addi	sp,sp,-80
     c60:	e486                	sd	ra,72(sp)
     c62:	e0a2                	sd	s0,64(sp)
     c64:	fc26                	sd	s1,56(sp)
     c66:	f84a                	sd	s2,48(sp)
     c68:	f44e                	sd	s3,40(sp)
     c6a:	0880                	addi	s0,sp,80
     c6c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     c6e:	c299                	beqz	a3,c74 <printint+0x16>
     c70:	0805c163          	bltz	a1,cf2 <printint+0x94>
  neg = 0;
     c74:	4881                	li	a7,0
     c76:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     c7a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     c7c:	00001517          	auipc	a0,0x1
     c80:	82450513          	addi	a0,a0,-2012 # 14a0 <digits>
     c84:	883e                	mv	a6,a5
     c86:	2785                	addiw	a5,a5,1
     c88:	02c5f733          	remu	a4,a1,a2
     c8c:	972a                	add	a4,a4,a0
     c8e:	00074703          	lbu	a4,0(a4)
     c92:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     c96:	872e                	mv	a4,a1
     c98:	02c5d5b3          	divu	a1,a1,a2
     c9c:	0685                	addi	a3,a3,1
     c9e:	fec773e3          	bgeu	a4,a2,c84 <printint+0x26>
  if(neg)
     ca2:	00088b63          	beqz	a7,cb8 <printint+0x5a>
    buf[i++] = '-';
     ca6:	fd078793          	addi	a5,a5,-48
     caa:	97a2                	add	a5,a5,s0
     cac:	02d00713          	li	a4,45
     cb0:	fee78423          	sb	a4,-24(a5)
     cb4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     cb8:	02f05663          	blez	a5,ce4 <printint+0x86>
     cbc:	fb840713          	addi	a4,s0,-72
     cc0:	00f704b3          	add	s1,a4,a5
     cc4:	fff70993          	addi	s3,a4,-1
     cc8:	99be                	add	s3,s3,a5
     cca:	37fd                	addiw	a5,a5,-1
     ccc:	1782                	slli	a5,a5,0x20
     cce:	9381                	srli	a5,a5,0x20
     cd0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     cd4:	fff4c583          	lbu	a1,-1(s1)
     cd8:	854a                	mv	a0,s2
     cda:	f67ff0ef          	jal	ra,c40 <putc>
  while(--i >= 0)
     cde:	14fd                	addi	s1,s1,-1
     ce0:	ff349ae3          	bne	s1,s3,cd4 <printint+0x76>
}
     ce4:	60a6                	ld	ra,72(sp)
     ce6:	6406                	ld	s0,64(sp)
     ce8:	74e2                	ld	s1,56(sp)
     cea:	7942                	ld	s2,48(sp)
     cec:	79a2                	ld	s3,40(sp)
     cee:	6161                	addi	sp,sp,80
     cf0:	8082                	ret
    x = -xx;
     cf2:	40b005b3          	neg	a1,a1
    neg = 1;
     cf6:	4885                	li	a7,1
    x = -xx;
     cf8:	bfbd                	j	c76 <printint+0x18>

0000000000000cfa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     cfa:	7119                	addi	sp,sp,-128
     cfc:	fc86                	sd	ra,120(sp)
     cfe:	f8a2                	sd	s0,112(sp)
     d00:	f4a6                	sd	s1,104(sp)
     d02:	f0ca                	sd	s2,96(sp)
     d04:	ecce                	sd	s3,88(sp)
     d06:	e8d2                	sd	s4,80(sp)
     d08:	e4d6                	sd	s5,72(sp)
     d0a:	e0da                	sd	s6,64(sp)
     d0c:	fc5e                	sd	s7,56(sp)
     d0e:	f862                	sd	s8,48(sp)
     d10:	f466                	sd	s9,40(sp)
     d12:	f06a                	sd	s10,32(sp)
     d14:	ec6e                	sd	s11,24(sp)
     d16:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d18:	0005c903          	lbu	s2,0(a1)
     d1c:	24090c63          	beqz	s2,f74 <vprintf+0x27a>
     d20:	8b2a                	mv	s6,a0
     d22:	8a2e                	mv	s4,a1
     d24:	8bb2                	mv	s7,a2
  state = 0;
     d26:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d28:	4481                	li	s1,0
     d2a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d2c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d30:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d34:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d38:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d3c:	00000c97          	auipc	s9,0x0
     d40:	764c8c93          	addi	s9,s9,1892 # 14a0 <digits>
     d44:	a005                	j	d64 <vprintf+0x6a>
        putc(fd, c0);
     d46:	85ca                	mv	a1,s2
     d48:	855a                	mv	a0,s6
     d4a:	ef7ff0ef          	jal	ra,c40 <putc>
     d4e:	a019                	j	d54 <vprintf+0x5a>
    } else if(state == '%'){
     d50:	03598263          	beq	s3,s5,d74 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     d54:	2485                	addiw	s1,s1,1
     d56:	8726                	mv	a4,s1
     d58:	009a07b3          	add	a5,s4,s1
     d5c:	0007c903          	lbu	s2,0(a5)
     d60:	20090a63          	beqz	s2,f74 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
     d64:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d68:	fe0994e3          	bnez	s3,d50 <vprintf+0x56>
      if(c0 == '%'){
     d6c:	fd579de3          	bne	a5,s5,d46 <vprintf+0x4c>
        state = '%';
     d70:	89be                	mv	s3,a5
     d72:	b7cd                	j	d54 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d74:	c3c1                	beqz	a5,df4 <vprintf+0xfa>
     d76:	00ea06b3          	add	a3,s4,a4
     d7a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d7e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d80:	c681                	beqz	a3,d88 <vprintf+0x8e>
     d82:	9752                	add	a4,a4,s4
     d84:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     d88:	03878e63          	beq	a5,s8,dc4 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
     d8c:	05a78863          	beq	a5,s10,ddc <vprintf+0xe2>
      } else if(c0 == 'u'){
     d90:	0db78b63          	beq	a5,s11,e66 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     d94:	07800713          	li	a4,120
     d98:	10e78d63          	beq	a5,a4,eb2 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     d9c:	07000713          	li	a4,112
     da0:	14e78263          	beq	a5,a4,ee4 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     da4:	06300713          	li	a4,99
     da8:	16e78f63          	beq	a5,a4,f26 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     dac:	07300713          	li	a4,115
     db0:	18e78563          	beq	a5,a4,f3a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     db4:	05579063          	bne	a5,s5,df4 <vprintf+0xfa>
        putc(fd, '%');
     db8:	85d6                	mv	a1,s5
     dba:	855a                	mv	a0,s6
     dbc:	e85ff0ef          	jal	ra,c40 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     dc0:	4981                	li	s3,0
     dc2:	bf49                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
     dc4:	008b8913          	addi	s2,s7,8
     dc8:	4685                	li	a3,1
     dca:	4629                	li	a2,10
     dcc:	000ba583          	lw	a1,0(s7)
     dd0:	855a                	mv	a0,s6
     dd2:	e8dff0ef          	jal	ra,c5e <printint>
     dd6:	8bca                	mv	s7,s2
      state = 0;
     dd8:	4981                	li	s3,0
     dda:	bfad                	j	d54 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
     ddc:	03868663          	beq	a3,s8,e08 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     de0:	05a68163          	beq	a3,s10,e22 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
     de4:	09b68d63          	beq	a3,s11,e7e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     de8:	03a68f63          	beq	a3,s10,e26 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
     dec:	07800793          	li	a5,120
     df0:	0cf68d63          	beq	a3,a5,eca <vprintf+0x1d0>
        putc(fd, '%');
     df4:	85d6                	mv	a1,s5
     df6:	855a                	mv	a0,s6
     df8:	e49ff0ef          	jal	ra,c40 <putc>
        putc(fd, c0);
     dfc:	85ca                	mv	a1,s2
     dfe:	855a                	mv	a0,s6
     e00:	e41ff0ef          	jal	ra,c40 <putc>
      state = 0;
     e04:	4981                	li	s3,0
     e06:	b7b9                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e08:	008b8913          	addi	s2,s7,8
     e0c:	4685                	li	a3,1
     e0e:	4629                	li	a2,10
     e10:	000bb583          	ld	a1,0(s7)
     e14:	855a                	mv	a0,s6
     e16:	e49ff0ef          	jal	ra,c5e <printint>
        i += 1;
     e1a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     e1c:	8bca                	mv	s7,s2
      state = 0;
     e1e:	4981                	li	s3,0
        i += 1;
     e20:	bf15                	j	d54 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e22:	03860563          	beq	a2,s8,e4c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e26:	07b60963          	beq	a2,s11,e98 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e2a:	07800793          	li	a5,120
     e2e:	fcf613e3          	bne	a2,a5,df4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e32:	008b8913          	addi	s2,s7,8
     e36:	4681                	li	a3,0
     e38:	4641                	li	a2,16
     e3a:	000bb583          	ld	a1,0(s7)
     e3e:	855a                	mv	a0,s6
     e40:	e1fff0ef          	jal	ra,c5e <printint>
        i += 2;
     e44:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e46:	8bca                	mv	s7,s2
      state = 0;
     e48:	4981                	li	s3,0
        i += 2;
     e4a:	b729                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e4c:	008b8913          	addi	s2,s7,8
     e50:	4685                	li	a3,1
     e52:	4629                	li	a2,10
     e54:	000bb583          	ld	a1,0(s7)
     e58:	855a                	mv	a0,s6
     e5a:	e05ff0ef          	jal	ra,c5e <printint>
        i += 2;
     e5e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e60:	8bca                	mv	s7,s2
      state = 0;
     e62:	4981                	li	s3,0
        i += 2;
     e64:	bdc5                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     e66:	008b8913          	addi	s2,s7,8
     e6a:	4681                	li	a3,0
     e6c:	4629                	li	a2,10
     e6e:	000be583          	lwu	a1,0(s7)
     e72:	855a                	mv	a0,s6
     e74:	debff0ef          	jal	ra,c5e <printint>
     e78:	8bca                	mv	s7,s2
      state = 0;
     e7a:	4981                	li	s3,0
     e7c:	bde1                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e7e:	008b8913          	addi	s2,s7,8
     e82:	4681                	li	a3,0
     e84:	4629                	li	a2,10
     e86:	000bb583          	ld	a1,0(s7)
     e8a:	855a                	mv	a0,s6
     e8c:	dd3ff0ef          	jal	ra,c5e <printint>
        i += 1;
     e90:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     e92:	8bca                	mv	s7,s2
      state = 0;
     e94:	4981                	li	s3,0
        i += 1;
     e96:	bd7d                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e98:	008b8913          	addi	s2,s7,8
     e9c:	4681                	li	a3,0
     e9e:	4629                	li	a2,10
     ea0:	000bb583          	ld	a1,0(s7)
     ea4:	855a                	mv	a0,s6
     ea6:	db9ff0ef          	jal	ra,c5e <printint>
        i += 2;
     eaa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     eac:	8bca                	mv	s7,s2
      state = 0;
     eae:	4981                	li	s3,0
        i += 2;
     eb0:	b555                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     eb2:	008b8913          	addi	s2,s7,8
     eb6:	4681                	li	a3,0
     eb8:	4641                	li	a2,16
     eba:	000be583          	lwu	a1,0(s7)
     ebe:	855a                	mv	a0,s6
     ec0:	d9fff0ef          	jal	ra,c5e <printint>
     ec4:	8bca                	mv	s7,s2
      state = 0;
     ec6:	4981                	li	s3,0
     ec8:	b571                	j	d54 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     eca:	008b8913          	addi	s2,s7,8
     ece:	4681                	li	a3,0
     ed0:	4641                	li	a2,16
     ed2:	000bb583          	ld	a1,0(s7)
     ed6:	855a                	mv	a0,s6
     ed8:	d87ff0ef          	jal	ra,c5e <printint>
        i += 1;
     edc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     ede:	8bca                	mv	s7,s2
      state = 0;
     ee0:	4981                	li	s3,0
        i += 1;
     ee2:	bd8d                	j	d54 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
     ee4:	008b8793          	addi	a5,s7,8
     ee8:	f8f43423          	sd	a5,-120(s0)
     eec:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     ef0:	03000593          	li	a1,48
     ef4:	855a                	mv	a0,s6
     ef6:	d4bff0ef          	jal	ra,c40 <putc>
  putc(fd, 'x');
     efa:	07800593          	li	a1,120
     efe:	855a                	mv	a0,s6
     f00:	d41ff0ef          	jal	ra,c40 <putc>
     f04:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f06:	03c9d793          	srli	a5,s3,0x3c
     f0a:	97e6                	add	a5,a5,s9
     f0c:	0007c583          	lbu	a1,0(a5)
     f10:	855a                	mv	a0,s6
     f12:	d2fff0ef          	jal	ra,c40 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f16:	0992                	slli	s3,s3,0x4
     f18:	397d                	addiw	s2,s2,-1
     f1a:	fe0916e3          	bnez	s2,f06 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
     f1e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
     f22:	4981                	li	s3,0
     f24:	bd05                	j	d54 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
     f26:	008b8913          	addi	s2,s7,8
     f2a:	000bc583          	lbu	a1,0(s7)
     f2e:	855a                	mv	a0,s6
     f30:	d11ff0ef          	jal	ra,c40 <putc>
     f34:	8bca                	mv	s7,s2
      state = 0;
     f36:	4981                	li	s3,0
     f38:	bd31                	j	d54 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
     f3a:	008b8993          	addi	s3,s7,8
     f3e:	000bb903          	ld	s2,0(s7)
     f42:	00090f63          	beqz	s2,f60 <vprintf+0x266>
        for(; *s; s++)
     f46:	00094583          	lbu	a1,0(s2)
     f4a:	c195                	beqz	a1,f6e <vprintf+0x274>
          putc(fd, *s);
     f4c:	855a                	mv	a0,s6
     f4e:	cf3ff0ef          	jal	ra,c40 <putc>
        for(; *s; s++)
     f52:	0905                	addi	s2,s2,1
     f54:	00094583          	lbu	a1,0(s2)
     f58:	f9f5                	bnez	a1,f4c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
     f5a:	8bce                	mv	s7,s3
      state = 0;
     f5c:	4981                	li	s3,0
     f5e:	bbdd                	j	d54 <vprintf+0x5a>
          s = "(null)";
     f60:	00000917          	auipc	s2,0x0
     f64:	53890913          	addi	s2,s2,1336 # 1498 <malloc+0x428>
        for(; *s; s++)
     f68:	02800593          	li	a1,40
     f6c:	b7c5                	j	f4c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
     f6e:	8bce                	mv	s7,s3
      state = 0;
     f70:	4981                	li	s3,0
     f72:	b3cd                	j	d54 <vprintf+0x5a>
    }
  }
}
     f74:	70e6                	ld	ra,120(sp)
     f76:	7446                	ld	s0,112(sp)
     f78:	74a6                	ld	s1,104(sp)
     f7a:	7906                	ld	s2,96(sp)
     f7c:	69e6                	ld	s3,88(sp)
     f7e:	6a46                	ld	s4,80(sp)
     f80:	6aa6                	ld	s5,72(sp)
     f82:	6b06                	ld	s6,64(sp)
     f84:	7be2                	ld	s7,56(sp)
     f86:	7c42                	ld	s8,48(sp)
     f88:	7ca2                	ld	s9,40(sp)
     f8a:	7d02                	ld	s10,32(sp)
     f8c:	6de2                	ld	s11,24(sp)
     f8e:	6109                	addi	sp,sp,128
     f90:	8082                	ret

0000000000000f92 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f92:	715d                	addi	sp,sp,-80
     f94:	ec06                	sd	ra,24(sp)
     f96:	e822                	sd	s0,16(sp)
     f98:	1000                	addi	s0,sp,32
     f9a:	e010                	sd	a2,0(s0)
     f9c:	e414                	sd	a3,8(s0)
     f9e:	e818                	sd	a4,16(s0)
     fa0:	ec1c                	sd	a5,24(s0)
     fa2:	03043023          	sd	a6,32(s0)
     fa6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     faa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     fae:	8622                	mv	a2,s0
     fb0:	d4bff0ef          	jal	ra,cfa <vprintf>
}
     fb4:	60e2                	ld	ra,24(sp)
     fb6:	6442                	ld	s0,16(sp)
     fb8:	6161                	addi	sp,sp,80
     fba:	8082                	ret

0000000000000fbc <printf>:

void
printf(const char *fmt, ...)
{
     fbc:	711d                	addi	sp,sp,-96
     fbe:	ec06                	sd	ra,24(sp)
     fc0:	e822                	sd	s0,16(sp)
     fc2:	1000                	addi	s0,sp,32
     fc4:	e40c                	sd	a1,8(s0)
     fc6:	e810                	sd	a2,16(s0)
     fc8:	ec14                	sd	a3,24(s0)
     fca:	f018                	sd	a4,32(s0)
     fcc:	f41c                	sd	a5,40(s0)
     fce:	03043823          	sd	a6,48(s0)
     fd2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     fd6:	00840613          	addi	a2,s0,8
     fda:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     fde:	85aa                	mv	a1,a0
     fe0:	4505                	li	a0,1
     fe2:	d19ff0ef          	jal	ra,cfa <vprintf>
}
     fe6:	60e2                	ld	ra,24(sp)
     fe8:	6442                	ld	s0,16(sp)
     fea:	6125                	addi	sp,sp,96
     fec:	8082                	ret

0000000000000fee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fee:	1141                	addi	sp,sp,-16
     ff0:	e422                	sd	s0,8(sp)
     ff2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     ff4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ff8:	00001797          	auipc	a5,0x1
     ffc:	0187b783          	ld	a5,24(a5) # 2010 <freep>
    1000:	a02d                	j	102a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1002:	4618                	lw	a4,8(a2)
    1004:	9f2d                	addw	a4,a4,a1
    1006:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    100a:	6398                	ld	a4,0(a5)
    100c:	6310                	ld	a2,0(a4)
    100e:	a83d                	j	104c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1010:	ff852703          	lw	a4,-8(a0)
    1014:	9f31                	addw	a4,a4,a2
    1016:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1018:	ff053683          	ld	a3,-16(a0)
    101c:	a091                	j	1060 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    101e:	6398                	ld	a4,0(a5)
    1020:	00e7e463          	bltu	a5,a4,1028 <free+0x3a>
    1024:	00e6ea63          	bltu	a3,a4,1038 <free+0x4a>
{
    1028:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    102a:	fed7fae3          	bgeu	a5,a3,101e <free+0x30>
    102e:	6398                	ld	a4,0(a5)
    1030:	00e6e463          	bltu	a3,a4,1038 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1034:	fee7eae3          	bltu	a5,a4,1028 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1038:	ff852583          	lw	a1,-8(a0)
    103c:	6390                	ld	a2,0(a5)
    103e:	02059813          	slli	a6,a1,0x20
    1042:	01c85713          	srli	a4,a6,0x1c
    1046:	9736                	add	a4,a4,a3
    1048:	fae60de3          	beq	a2,a4,1002 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    104c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1050:	4790                	lw	a2,8(a5)
    1052:	02061593          	slli	a1,a2,0x20
    1056:	01c5d713          	srli	a4,a1,0x1c
    105a:	973e                	add	a4,a4,a5
    105c:	fae68ae3          	beq	a3,a4,1010 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1060:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1062:	00001717          	auipc	a4,0x1
    1066:	faf73723          	sd	a5,-82(a4) # 2010 <freep>
}
    106a:	6422                	ld	s0,8(sp)
    106c:	0141                	addi	sp,sp,16
    106e:	8082                	ret

0000000000001070 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1070:	7139                	addi	sp,sp,-64
    1072:	fc06                	sd	ra,56(sp)
    1074:	f822                	sd	s0,48(sp)
    1076:	f426                	sd	s1,40(sp)
    1078:	f04a                	sd	s2,32(sp)
    107a:	ec4e                	sd	s3,24(sp)
    107c:	e852                	sd	s4,16(sp)
    107e:	e456                	sd	s5,8(sp)
    1080:	e05a                	sd	s6,0(sp)
    1082:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1084:	02051493          	slli	s1,a0,0x20
    1088:	9081                	srli	s1,s1,0x20
    108a:	04bd                	addi	s1,s1,15
    108c:	8091                	srli	s1,s1,0x4
    108e:	0014899b          	addiw	s3,s1,1
    1092:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1094:	00001517          	auipc	a0,0x1
    1098:	f7c53503          	ld	a0,-132(a0) # 2010 <freep>
    109c:	c515                	beqz	a0,10c8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    109e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10a0:	4798                	lw	a4,8(a5)
    10a2:	02977f63          	bgeu	a4,s1,10e0 <malloc+0x70>
    10a6:	8a4e                	mv	s4,s3
    10a8:	0009871b          	sext.w	a4,s3
    10ac:	6685                	lui	a3,0x1
    10ae:	00d77363          	bgeu	a4,a3,10b4 <malloc+0x44>
    10b2:	6a05                	lui	s4,0x1
    10b4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10b8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10bc:	00001917          	auipc	s2,0x1
    10c0:	f5490913          	addi	s2,s2,-172 # 2010 <freep>
  if(p == SBRK_ERROR)
    10c4:	5afd                	li	s5,-1
    10c6:	a885                	j	1136 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
    10c8:	00001797          	auipc	a5,0x1
    10cc:	34078793          	addi	a5,a5,832 # 2408 <base>
    10d0:	00001717          	auipc	a4,0x1
    10d4:	f4f73023          	sd	a5,-192(a4) # 2010 <freep>
    10d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    10da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    10de:	b7e1                	j	10a6 <malloc+0x36>
      if(p->s.size == nunits)
    10e0:	02e48c63          	beq	s1,a4,1118 <malloc+0xa8>
        p->s.size -= nunits;
    10e4:	4137073b          	subw	a4,a4,s3
    10e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
    10ea:	02071693          	slli	a3,a4,0x20
    10ee:	01c6d713          	srli	a4,a3,0x1c
    10f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    10f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    10f8:	00001717          	auipc	a4,0x1
    10fc:	f0a73c23          	sd	a0,-232(a4) # 2010 <freep>
      return (void*)(p + 1);
    1100:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1104:	70e2                	ld	ra,56(sp)
    1106:	7442                	ld	s0,48(sp)
    1108:	74a2                	ld	s1,40(sp)
    110a:	7902                	ld	s2,32(sp)
    110c:	69e2                	ld	s3,24(sp)
    110e:	6a42                	ld	s4,16(sp)
    1110:	6aa2                	ld	s5,8(sp)
    1112:	6b02                	ld	s6,0(sp)
    1114:	6121                	addi	sp,sp,64
    1116:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1118:	6398                	ld	a4,0(a5)
    111a:	e118                	sd	a4,0(a0)
    111c:	bff1                	j	10f8 <malloc+0x88>
  hp->s.size = nu;
    111e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1122:	0541                	addi	a0,a0,16
    1124:	ecbff0ef          	jal	ra,fee <free>
  return freep;
    1128:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    112c:	dd61                	beqz	a0,1104 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    112e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1130:	4798                	lw	a4,8(a5)
    1132:	fa9777e3          	bgeu	a4,s1,10e0 <malloc+0x70>
    if(p == freep)
    1136:	00093703          	ld	a4,0(s2)
    113a:	853e                	mv	a0,a5
    113c:	fef719e3          	bne	a4,a5,112e <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
    1140:	8552                	mv	a0,s4
    1142:	9ebff0ef          	jal	ra,b2c <sbrk>
  if(p == SBRK_ERROR)
    1146:	fd551ce3          	bne	a0,s5,111e <malloc+0xae>
        return 0;
    114a:	4501                	li	a0,0
    114c:	bf65                	j	1104 <malloc+0x94>
