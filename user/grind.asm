
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
      96:	08e50513          	addi	a0,a0,142 # 1120 <malloc+0xe0>
      9a:	32f000ef          	jal	ra,bc8 <mkdir>
  if(chdir("grindir") != 0){
      9e:	00001517          	auipc	a0,0x1
      a2:	08250513          	addi	a0,a0,130 # 1120 <malloc+0xe0>
      a6:	32b000ef          	jal	ra,bd0 <chdir>
      aa:	c911                	beqz	a0,be <go+0x4a>
    printf("grind: chdir grindir failed\n");
      ac:	00001517          	auipc	a0,0x1
      b0:	07c50513          	addi	a0,a0,124 # 1128 <malloc+0xe8>
      b4:	6d9000ef          	jal	ra,f8c <printf>
    exit(1);
      b8:	4505                	li	a0,1
      ba:	2a7000ef          	jal	ra,b60 <exit>
  }
  chdir("/");
      be:	00001517          	auipc	a0,0x1
      c2:	08a50513          	addi	a0,a0,138 # 1148 <malloc+0x108>
      c6:	30b000ef          	jal	ra,bd0 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      ca:	00001997          	auipc	s3,0x1
      ce:	08e98993          	addi	s3,s3,142 # 1158 <malloc+0x118>
      d2:	c489                	beqz	s1,dc <go+0x68>
      d4:	00001997          	auipc	s3,0x1
      d8:	07c98993          	addi	s3,s3,124 # 1150 <malloc+0x110>
    iters++;
      dc:	4485                	li	s1,1
  int fd = -1;
      de:	5a7d                	li	s4,-1
      e0:	00001917          	auipc	s2,0x1
      e4:	32890913          	addi	s2,s2,808 # 1408 <malloc+0x3c8>
      e8:	a035                	j	114 <go+0xa0>
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
      ea:	20200593          	li	a1,514
      ee:	00001517          	auipc	a0,0x1
      f2:	07250513          	addi	a0,a0,114 # 1160 <malloc+0x120>
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
     13c:	03850513          	addi	a0,a0,56 # 1170 <malloc+0x130>
     140:	261000ef          	jal	ra,ba0 <open>
     144:	245000ef          	jal	ra,b88 <close>
     148:	bf5d                	j	fe <go+0x8a>
    } else if(what == 3){
      unlink("grindir/../a");
     14a:	00001517          	auipc	a0,0x1
     14e:	01650513          	addi	a0,a0,22 # 1160 <malloc+0x120>
     152:	25f000ef          	jal	ra,bb0 <unlink>
     156:	b765                	j	fe <go+0x8a>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     158:	00001517          	auipc	a0,0x1
     15c:	fc850513          	addi	a0,a0,-56 # 1120 <malloc+0xe0>
     160:	271000ef          	jal	ra,bd0 <chdir>
     164:	ed11                	bnez	a0,180 <go+0x10c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     166:	00001517          	auipc	a0,0x1
     16a:	02250513          	addi	a0,a0,34 # 1188 <malloc+0x148>
     16e:	243000ef          	jal	ra,bb0 <unlink>
      chdir("/");
     172:	00001517          	auipc	a0,0x1
     176:	fd650513          	addi	a0,a0,-42 # 1148 <malloc+0x108>
     17a:	257000ef          	jal	ra,bd0 <chdir>
     17e:	b741                	j	fe <go+0x8a>
        printf("grind: chdir grindir failed\n");
     180:	00001517          	auipc	a0,0x1
     184:	fa850513          	addi	a0,a0,-88 # 1128 <malloc+0xe8>
     188:	605000ef          	jal	ra,f8c <printf>
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
     1a0:	ff450513          	addi	a0,a0,-12 # 1190 <malloc+0x150>
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
     1ba:	fea50513          	addi	a0,a0,-22 # 11a0 <malloc+0x160>
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
     1f2:	f7250513          	addi	a0,a0,-142 # 1160 <malloc+0x120>
     1f6:	1d3000ef          	jal	ra,bc8 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     1fa:	20200593          	li	a1,514
     1fe:	00001517          	auipc	a0,0x1
     202:	fba50513          	addi	a0,a0,-70 # 11b8 <malloc+0x178>
     206:	19b000ef          	jal	ra,ba0 <open>
     20a:	17f000ef          	jal	ra,b88 <close>
      unlink("a/a");
     20e:	00001517          	auipc	a0,0x1
     212:	fba50513          	addi	a0,a0,-70 # 11c8 <malloc+0x188>
     216:	19b000ef          	jal	ra,bb0 <unlink>
     21a:	b5d5                	j	fe <go+0x8a>
    } else if(what == 10){
      mkdir("/../b");
     21c:	00001517          	auipc	a0,0x1
     220:	fb450513          	addi	a0,a0,-76 # 11d0 <malloc+0x190>
     224:	1a5000ef          	jal	ra,bc8 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     228:	20200593          	li	a1,514
     22c:	00001517          	auipc	a0,0x1
     230:	fac50513          	addi	a0,a0,-84 # 11d8 <malloc+0x198>
     234:	16d000ef          	jal	ra,ba0 <open>
     238:	151000ef          	jal	ra,b88 <close>
      unlink("b/b");
     23c:	00001517          	auipc	a0,0x1
     240:	fac50513          	addi	a0,a0,-84 # 11e8 <malloc+0x1a8>
     244:	16d000ef          	jal	ra,bb0 <unlink>
     248:	bd5d                	j	fe <go+0x8a>
    } else if(what == 11){
      unlink("b");
     24a:	00001517          	auipc	a0,0x1
     24e:	f6650513          	addi	a0,a0,-154 # 11b0 <malloc+0x170>
     252:	15f000ef          	jal	ra,bb0 <unlink>
      link("../grindir/./../a", "../b");
     256:	00001597          	auipc	a1,0x1
     25a:	f3258593          	addi	a1,a1,-206 # 1188 <malloc+0x148>
     25e:	00001517          	auipc	a0,0x1
     262:	f9250513          	addi	a0,a0,-110 # 11f0 <malloc+0x1b0>
     266:	15b000ef          	jal	ra,bc0 <link>
     26a:	bd51                	j	fe <go+0x8a>
    } else if(what == 12){
      unlink("../grindir/../a");
     26c:	00001517          	auipc	a0,0x1
     270:	f9c50513          	addi	a0,a0,-100 # 1208 <malloc+0x1c8>
     274:	13d000ef          	jal	ra,bb0 <unlink>
      link(".././b", "/grindir/../a");
     278:	00001597          	auipc	a1,0x1
     27c:	f1858593          	addi	a1,a1,-232 # 1190 <malloc+0x150>
     280:	00001517          	auipc	a0,0x1
     284:	f9850513          	addi	a0,a0,-104 # 1218 <malloc+0x1d8>
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
     2a8:	f7c50513          	addi	a0,a0,-132 # 1220 <malloc+0x1e0>
     2ac:	4e1000ef          	jal	ra,f8c <printf>
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
     2da:	f4a50513          	addi	a0,a0,-182 # 1220 <malloc+0x1e0>
     2de:	4af000ef          	jal	ra,f8c <printf>
        exit(1);
     2e2:	4505                	li	a0,1
     2e4:	07d000ef          	jal	ra,b60 <exit>
    } else if(what == 15){
      sbrk(6011);
     2e8:	6505                	lui	a0,0x1
     2ea:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x30b>
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
     31e:	f1e50513          	addi	a0,a0,-226 # 1238 <malloc+0x1f8>
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
     33e:	ec650513          	addi	a0,a0,-314 # 1200 <malloc+0x1c0>
     342:	05f000ef          	jal	ra,ba0 <open>
     346:	043000ef          	jal	ra,b88 <close>
        exit(0);
     34a:	4501                	li	a0,0
     34c:	015000ef          	jal	ra,b60 <exit>
        printf("grind: fork failed\n");
     350:	00001517          	auipc	a0,0x1
     354:	ed050513          	addi	a0,a0,-304 # 1220 <malloc+0x1e0>
     358:	435000ef          	jal	ra,f8c <printf>
        exit(1);
     35c:	4505                	li	a0,1
     35e:	003000ef          	jal	ra,b60 <exit>
        printf("grind: chdir failed\n");
     362:	00001517          	auipc	a0,0x1
     366:	ee650513          	addi	a0,a0,-282 # 1248 <malloc+0x208>
     36a:	423000ef          	jal	ra,f8c <printf>
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
     398:	e8c50513          	addi	a0,a0,-372 # 1220 <malloc+0x1e0>
     39c:	3f1000ef          	jal	ra,f8c <printf>
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
     3d8:	e8c50513          	addi	a0,a0,-372 # 1260 <malloc+0x220>
     3dc:	3b1000ef          	jal	ra,f8c <printf>
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
     3f4:	e8858593          	addi	a1,a1,-376 # 1278 <malloc+0x238>
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
     424:	e6050513          	addi	a0,a0,-416 # 1280 <malloc+0x240>
     428:	365000ef          	jal	ra,f8c <printf>
     42c:	bfe9                	j	406 <go+0x392>
          printf("grind: pipe read failed\n");
     42e:	00001517          	auipc	a0,0x1
     432:	e7250513          	addi	a0,a0,-398 # 12a0 <malloc+0x260>
     436:	357000ef          	jal	ra,f8c <printf>
     43a:	b7c5                	j	41a <go+0x3a6>
        printf("grind: fork failed\n");
     43c:	00001517          	auipc	a0,0x1
     440:	de450513          	addi	a0,a0,-540 # 1220 <malloc+0x1e0>
     444:	349000ef          	jal	ra,f8c <printf>
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
     464:	da050513          	addi	a0,a0,-608 # 1200 <malloc+0x1c0>
     468:	748000ef          	jal	ra,bb0 <unlink>
        mkdir("a");
     46c:	00001517          	auipc	a0,0x1
     470:	d9450513          	addi	a0,a0,-620 # 1200 <malloc+0x1c0>
     474:	754000ef          	jal	ra,bc8 <mkdir>
        chdir("a");
     478:	00001517          	auipc	a0,0x1
     47c:	d8850513          	addi	a0,a0,-632 # 1200 <malloc+0x1c0>
     480:	750000ef          	jal	ra,bd0 <chdir>
        unlink("../a");
     484:	00001517          	auipc	a0,0x1
     488:	ce450513          	addi	a0,a0,-796 # 1168 <malloc+0x128>
     48c:	724000ef          	jal	ra,bb0 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     490:	20200593          	li	a1,514
     494:	00001517          	auipc	a0,0x1
     498:	de450513          	addi	a0,a0,-540 # 1278 <malloc+0x238>
     49c:	704000ef          	jal	ra,ba0 <open>
        unlink("x");
     4a0:	00001517          	auipc	a0,0x1
     4a4:	dd850513          	addi	a0,a0,-552 # 1278 <malloc+0x238>
     4a8:	708000ef          	jal	ra,bb0 <unlink>
        exit(0);
     4ac:	4501                	li	a0,0
     4ae:	6b2000ef          	jal	ra,b60 <exit>
        printf("grind: fork failed\n");
     4b2:	00001517          	auipc	a0,0x1
     4b6:	d6e50513          	addi	a0,a0,-658 # 1220 <malloc+0x1e0>
     4ba:	2d3000ef          	jal	ra,f8c <printf>
        exit(1);
     4be:	4505                	li	a0,1
     4c0:	6a0000ef          	jal	ra,b60 <exit>
    } else if(what == 21){
      unlink("c");
     4c4:	00001517          	auipc	a0,0x1
     4c8:	dfc50513          	addi	a0,a0,-516 # 12c0 <malloc+0x280>
     4cc:	6e4000ef          	jal	ra,bb0 <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     4d0:	20200593          	li	a1,514
     4d4:	00001517          	auipc	a0,0x1
     4d8:	dec50513          	addi	a0,a0,-532 # 12c0 <malloc+0x280>
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
     4ec:	d9058593          	addi	a1,a1,-624 # 1278 <malloc+0x238>
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
     526:	d9e50513          	addi	a0,a0,-610 # 12c0 <malloc+0x280>
     52a:	686000ef          	jal	ra,bb0 <unlink>
     52e:	bec1                	j	fe <go+0x8a>
        printf("grind: create c failed\n");
     530:	00001517          	auipc	a0,0x1
     534:	d9850513          	addi	a0,a0,-616 # 12c8 <malloc+0x288>
     538:	255000ef          	jal	ra,f8c <printf>
        exit(1);
     53c:	4505                	li	a0,1
     53e:	622000ef          	jal	ra,b60 <exit>
        printf("grind: write c failed\n");
     542:	00001517          	auipc	a0,0x1
     546:	d9e50513          	addi	a0,a0,-610 # 12e0 <malloc+0x2a0>
     54a:	243000ef          	jal	ra,f8c <printf>
        exit(1);
     54e:	4505                	li	a0,1
     550:	610000ef          	jal	ra,b60 <exit>
        printf("grind: fstat failed\n");
     554:	00001517          	auipc	a0,0x1
     558:	da450513          	addi	a0,a0,-604 # 12f8 <malloc+0x2b8>
     55c:	231000ef          	jal	ra,f8c <printf>
        exit(1);
     560:	4505                	li	a0,1
     562:	5fe000ef          	jal	ra,b60 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     566:	2581                	sext.w	a1,a1
     568:	00001517          	auipc	a0,0x1
     56c:	da850513          	addi	a0,a0,-600 # 1310 <malloc+0x2d0>
     570:	21d000ef          	jal	ra,f8c <printf>
        exit(1);
     574:	4505                	li	a0,1
     576:	5ea000ef          	jal	ra,b60 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     57a:	00001517          	auipc	a0,0x1
     57e:	dbe50513          	addi	a0,a0,-578 # 1338 <malloc+0x2f8>
     582:	20b000ef          	jal	ra,f8c <printf>
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
     62a:	db258593          	addi	a1,a1,-590 # 13d8 <malloc+0x398>
     62e:	f9040513          	addi	a0,s0,-112
     632:	2c6000ef          	jal	ra,8f8 <strcmp>
     636:	ac0504e3          	beqz	a0,fe <go+0x8a>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     63a:	f9040693          	addi	a3,s0,-112
     63e:	fa842603          	lw	a2,-88(s0)
     642:	f9442583          	lw	a1,-108(s0)
     646:	00001517          	auipc	a0,0x1
     64a:	d9a50513          	addi	a0,a0,-614 # 13e0 <malloc+0x3a0>
     64e:	13f000ef          	jal	ra,f8c <printf>
        exit(1);
     652:	4505                	li	a0,1
     654:	50c000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: pipe failed\n");
     658:	00001597          	auipc	a1,0x1
     65c:	c0858593          	addi	a1,a1,-1016 # 1260 <malloc+0x220>
     660:	4509                	li	a0,2
     662:	101000ef          	jal	ra,f62 <fprintf>
        exit(1);
     666:	4505                	li	a0,1
     668:	4f8000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: pipe failed\n");
     66c:	00001597          	auipc	a1,0x1
     670:	bf458593          	addi	a1,a1,-1036 # 1260 <malloc+0x220>
     674:	4509                	li	a0,2
     676:	0ed000ef          	jal	ra,f62 <fprintf>
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
     6b0:	cb458593          	addi	a1,a1,-844 # 1360 <malloc+0x320>
     6b4:	4509                	li	a0,2
     6b6:	0ad000ef          	jal	ra,f62 <fprintf>
          exit(1);
     6ba:	4505                	li	a0,1
     6bc:	4a4000ef          	jal	ra,b60 <exit>
        close(aa[1]);
     6c0:	f9c42503          	lw	a0,-100(s0)
     6c4:	4c4000ef          	jal	ra,b88 <close>
        char *args[3] = { "echo", "hi", 0 };
     6c8:	00001797          	auipc	a5,0x1
     6cc:	cb078793          	addi	a5,a5,-848 # 1378 <malloc+0x338>
     6d0:	faf43423          	sd	a5,-88(s0)
     6d4:	00001797          	auipc	a5,0x1
     6d8:	cac78793          	addi	a5,a5,-852 # 1380 <malloc+0x340>
     6dc:	faf43823          	sd	a5,-80(s0)
     6e0:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     6e4:	fa840593          	addi	a1,s0,-88
     6e8:	00001517          	auipc	a0,0x1
     6ec:	ca050513          	addi	a0,a0,-864 # 1388 <malloc+0x348>
     6f0:	4a8000ef          	jal	ra,b98 <exec>
        fprintf(2, "grind: echo: not found\n");
     6f4:	00001597          	auipc	a1,0x1
     6f8:	ca458593          	addi	a1,a1,-860 # 1398 <malloc+0x358>
     6fc:	4509                	li	a0,2
     6fe:	065000ef          	jal	ra,f62 <fprintf>
        exit(2);
     702:	4509                	li	a0,2
     704:	45c000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: fork failed\n");
     708:	00001597          	auipc	a1,0x1
     70c:	b1858593          	addi	a1,a1,-1256 # 1220 <malloc+0x1e0>
     710:	4509                	li	a0,2
     712:	051000ef          	jal	ra,f62 <fprintf>
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
     740:	c2458593          	addi	a1,a1,-988 # 1360 <malloc+0x320>
     744:	4509                	li	a0,2
     746:	01d000ef          	jal	ra,f62 <fprintf>
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
     770:	bf458593          	addi	a1,a1,-1036 # 1360 <malloc+0x320>
     774:	4509                	li	a0,2
     776:	7ec000ef          	jal	ra,f62 <fprintf>
          exit(5);
     77a:	4515                	li	a0,5
     77c:	3e4000ef          	jal	ra,b60 <exit>
        close(bb[1]);
     780:	fa442503          	lw	a0,-92(s0)
     784:	404000ef          	jal	ra,b88 <close>
        char *args[2] = { "cat", 0 };
     788:	00001797          	auipc	a5,0x1
     78c:	c2878793          	addi	a5,a5,-984 # 13b0 <malloc+0x370>
     790:	faf43423          	sd	a5,-88(s0)
     794:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     798:	fa840593          	addi	a1,s0,-88
     79c:	00001517          	auipc	a0,0x1
     7a0:	c1c50513          	addi	a0,a0,-996 # 13b8 <malloc+0x378>
     7a4:	3f4000ef          	jal	ra,b98 <exec>
        fprintf(2, "grind: cat: not found\n");
     7a8:	00001597          	auipc	a1,0x1
     7ac:	c1858593          	addi	a1,a1,-1000 # 13c0 <malloc+0x380>
     7b0:	4509                	li	a0,2
     7b2:	7b0000ef          	jal	ra,f62 <fprintf>
        exit(6);
     7b6:	4519                	li	a0,6
     7b8:	3a8000ef          	jal	ra,b60 <exit>
        fprintf(2, "grind: fork failed\n");
     7bc:	00001597          	auipc	a1,0x1
     7c0:	a6458593          	addi	a1,a1,-1436 # 1220 <malloc+0x1e0>
     7c4:	4509                	li	a0,2
     7c6:	79c000ef          	jal	ra,f62 <fprintf>
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
     7e0:	a2450513          	addi	a0,a0,-1500 # 1200 <malloc+0x1c0>
     7e4:	3cc000ef          	jal	ra,bb0 <unlink>
  unlink("b");
     7e8:	00001517          	auipc	a0,0x1
     7ec:	9c850513          	addi	a0,a0,-1592 # 11b0 <malloc+0x170>
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
     81a:	a0a50513          	addi	a0,a0,-1526 # 1220 <malloc+0x1e0>
     81e:	76e000ef          	jal	ra,f8c <printf>
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
     840:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x799>
     844:	8fb9                	xor	a5,a5,a4
     846:	e29c                	sd	a5,0(a3)
    go(1);
     848:	4505                	li	a0,1
     84a:	82bff0ef          	jal	ra,74 <go>
    printf("grind: fork failed\n");
     84e:	00001517          	auipc	a0,0x1
     852:	9d250513          	addi	a0,a0,-1582 # 1220 <malloc+0x1e0>
     856:	736000ef          	jal	ra,f8c <printf>
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
//
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

0000000000000c10 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c10:	1101                	addi	sp,sp,-32
     c12:	ec06                	sd	ra,24(sp)
     c14:	e822                	sd	s0,16(sp)
     c16:	1000                	addi	s0,sp,32
     c18:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c1c:	4605                	li	a2,1
     c1e:	fef40593          	addi	a1,s0,-17
     c22:	f5fff0ef          	jal	ra,b80 <write>
}
     c26:	60e2                	ld	ra,24(sp)
     c28:	6442                	ld	s0,16(sp)
     c2a:	6105                	addi	sp,sp,32
     c2c:	8082                	ret

0000000000000c2e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c2e:	715d                	addi	sp,sp,-80
     c30:	e486                	sd	ra,72(sp)
     c32:	e0a2                	sd	s0,64(sp)
     c34:	fc26                	sd	s1,56(sp)
     c36:	f84a                	sd	s2,48(sp)
     c38:	f44e                	sd	s3,40(sp)
     c3a:	0880                	addi	s0,sp,80
     c3c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     c3e:	c299                	beqz	a3,c44 <printint+0x16>
     c40:	0805c163          	bltz	a1,cc2 <printint+0x94>
  neg = 0;
     c44:	4881                	li	a7,0
     c46:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     c4a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     c4c:	00001517          	auipc	a0,0x1
     c50:	82450513          	addi	a0,a0,-2012 # 1470 <digits>
     c54:	883e                	mv	a6,a5
     c56:	2785                	addiw	a5,a5,1
     c58:	02c5f733          	remu	a4,a1,a2
     c5c:	972a                	add	a4,a4,a0
     c5e:	00074703          	lbu	a4,0(a4)
     c62:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     c66:	872e                	mv	a4,a1
     c68:	02c5d5b3          	divu	a1,a1,a2
     c6c:	0685                	addi	a3,a3,1
     c6e:	fec773e3          	bgeu	a4,a2,c54 <printint+0x26>
  if(neg)
     c72:	00088b63          	beqz	a7,c88 <printint+0x5a>
    buf[i++] = '-';
     c76:	fd078793          	addi	a5,a5,-48
     c7a:	97a2                	add	a5,a5,s0
     c7c:	02d00713          	li	a4,45
     c80:	fee78423          	sb	a4,-24(a5)
     c84:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     c88:	02f05663          	blez	a5,cb4 <printint+0x86>
     c8c:	fb840713          	addi	a4,s0,-72
     c90:	00f704b3          	add	s1,a4,a5
     c94:	fff70993          	addi	s3,a4,-1
     c98:	99be                	add	s3,s3,a5
     c9a:	37fd                	addiw	a5,a5,-1
     c9c:	1782                	slli	a5,a5,0x20
     c9e:	9381                	srli	a5,a5,0x20
     ca0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     ca4:	fff4c583          	lbu	a1,-1(s1)
     ca8:	854a                	mv	a0,s2
     caa:	f67ff0ef          	jal	ra,c10 <putc>
  while(--i >= 0)
     cae:	14fd                	addi	s1,s1,-1
     cb0:	ff349ae3          	bne	s1,s3,ca4 <printint+0x76>
}
     cb4:	60a6                	ld	ra,72(sp)
     cb6:	6406                	ld	s0,64(sp)
     cb8:	74e2                	ld	s1,56(sp)
     cba:	7942                	ld	s2,48(sp)
     cbc:	79a2                	ld	s3,40(sp)
     cbe:	6161                	addi	sp,sp,80
     cc0:	8082                	ret
    x = -xx;
     cc2:	40b005b3          	neg	a1,a1
    neg = 1;
     cc6:	4885                	li	a7,1
    x = -xx;
     cc8:	bfbd                	j	c46 <printint+0x18>

0000000000000cca <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     cca:	7119                	addi	sp,sp,-128
     ccc:	fc86                	sd	ra,120(sp)
     cce:	f8a2                	sd	s0,112(sp)
     cd0:	f4a6                	sd	s1,104(sp)
     cd2:	f0ca                	sd	s2,96(sp)
     cd4:	ecce                	sd	s3,88(sp)
     cd6:	e8d2                	sd	s4,80(sp)
     cd8:	e4d6                	sd	s5,72(sp)
     cda:	e0da                	sd	s6,64(sp)
     cdc:	fc5e                	sd	s7,56(sp)
     cde:	f862                	sd	s8,48(sp)
     ce0:	f466                	sd	s9,40(sp)
     ce2:	f06a                	sd	s10,32(sp)
     ce4:	ec6e                	sd	s11,24(sp)
     ce6:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     ce8:	0005c903          	lbu	s2,0(a1)
     cec:	24090c63          	beqz	s2,f44 <vprintf+0x27a>
     cf0:	8b2a                	mv	s6,a0
     cf2:	8a2e                	mv	s4,a1
     cf4:	8bb2                	mv	s7,a2
  state = 0;
     cf6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     cf8:	4481                	li	s1,0
     cfa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     cfc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d00:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d04:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d08:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d0c:	00000c97          	auipc	s9,0x0
     d10:	764c8c93          	addi	s9,s9,1892 # 1470 <digits>
     d14:	a005                	j	d34 <vprintf+0x6a>
        putc(fd, c0);
     d16:	85ca                	mv	a1,s2
     d18:	855a                	mv	a0,s6
     d1a:	ef7ff0ef          	jal	ra,c10 <putc>
     d1e:	a019                	j	d24 <vprintf+0x5a>
    } else if(state == '%'){
     d20:	03598263          	beq	s3,s5,d44 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     d24:	2485                	addiw	s1,s1,1
     d26:	8726                	mv	a4,s1
     d28:	009a07b3          	add	a5,s4,s1
     d2c:	0007c903          	lbu	s2,0(a5)
     d30:	20090a63          	beqz	s2,f44 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
     d34:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d38:	fe0994e3          	bnez	s3,d20 <vprintf+0x56>
      if(c0 == '%'){
     d3c:	fd579de3          	bne	a5,s5,d16 <vprintf+0x4c>
        state = '%';
     d40:	89be                	mv	s3,a5
     d42:	b7cd                	j	d24 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d44:	c3c1                	beqz	a5,dc4 <vprintf+0xfa>
     d46:	00ea06b3          	add	a3,s4,a4
     d4a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d4e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d50:	c681                	beqz	a3,d58 <vprintf+0x8e>
     d52:	9752                	add	a4,a4,s4
     d54:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     d58:	03878e63          	beq	a5,s8,d94 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
     d5c:	05a78863          	beq	a5,s10,dac <vprintf+0xe2>
      } else if(c0 == 'u'){
     d60:	0db78b63          	beq	a5,s11,e36 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     d64:	07800713          	li	a4,120
     d68:	10e78d63          	beq	a5,a4,e82 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     d6c:	07000713          	li	a4,112
     d70:	14e78263          	beq	a5,a4,eb4 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     d74:	06300713          	li	a4,99
     d78:	16e78f63          	beq	a5,a4,ef6 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     d7c:	07300713          	li	a4,115
     d80:	18e78563          	beq	a5,a4,f0a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     d84:	05579063          	bne	a5,s5,dc4 <vprintf+0xfa>
        putc(fd, '%');
     d88:	85d6                	mv	a1,s5
     d8a:	855a                	mv	a0,s6
     d8c:	e85ff0ef          	jal	ra,c10 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     d90:	4981                	li	s3,0
     d92:	bf49                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
     d94:	008b8913          	addi	s2,s7,8
     d98:	4685                	li	a3,1
     d9a:	4629                	li	a2,10
     d9c:	000ba583          	lw	a1,0(s7)
     da0:	855a                	mv	a0,s6
     da2:	e8dff0ef          	jal	ra,c2e <printint>
     da6:	8bca                	mv	s7,s2
      state = 0;
     da8:	4981                	li	s3,0
     daa:	bfad                	j	d24 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
     dac:	03868663          	beq	a3,s8,dd8 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     db0:	05a68163          	beq	a3,s10,df2 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
     db4:	09b68d63          	beq	a3,s11,e4e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     db8:	03a68f63          	beq	a3,s10,df6 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
     dbc:	07800793          	li	a5,120
     dc0:	0cf68d63          	beq	a3,a5,e9a <vprintf+0x1d0>
        putc(fd, '%');
     dc4:	85d6                	mv	a1,s5
     dc6:	855a                	mv	a0,s6
     dc8:	e49ff0ef          	jal	ra,c10 <putc>
        putc(fd, c0);
     dcc:	85ca                	mv	a1,s2
     dce:	855a                	mv	a0,s6
     dd0:	e41ff0ef          	jal	ra,c10 <putc>
      state = 0;
     dd4:	4981                	li	s3,0
     dd6:	b7b9                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     dd8:	008b8913          	addi	s2,s7,8
     ddc:	4685                	li	a3,1
     dde:	4629                	li	a2,10
     de0:	000bb583          	ld	a1,0(s7)
     de4:	855a                	mv	a0,s6
     de6:	e49ff0ef          	jal	ra,c2e <printint>
        i += 1;
     dea:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     dec:	8bca                	mv	s7,s2
      state = 0;
     dee:	4981                	li	s3,0
        i += 1;
     df0:	bf15                	j	d24 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     df2:	03860563          	beq	a2,s8,e1c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     df6:	07b60963          	beq	a2,s11,e68 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     dfa:	07800793          	li	a5,120
     dfe:	fcf613e3          	bne	a2,a5,dc4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e02:	008b8913          	addi	s2,s7,8
     e06:	4681                	li	a3,0
     e08:	4641                	li	a2,16
     e0a:	000bb583          	ld	a1,0(s7)
     e0e:	855a                	mv	a0,s6
     e10:	e1fff0ef          	jal	ra,c2e <printint>
        i += 2;
     e14:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e16:	8bca                	mv	s7,s2
      state = 0;
     e18:	4981                	li	s3,0
        i += 2;
     e1a:	b729                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e1c:	008b8913          	addi	s2,s7,8
     e20:	4685                	li	a3,1
     e22:	4629                	li	a2,10
     e24:	000bb583          	ld	a1,0(s7)
     e28:	855a                	mv	a0,s6
     e2a:	e05ff0ef          	jal	ra,c2e <printint>
        i += 2;
     e2e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e30:	8bca                	mv	s7,s2
      state = 0;
     e32:	4981                	li	s3,0
        i += 2;
     e34:	bdc5                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     e36:	008b8913          	addi	s2,s7,8
     e3a:	4681                	li	a3,0
     e3c:	4629                	li	a2,10
     e3e:	000be583          	lwu	a1,0(s7)
     e42:	855a                	mv	a0,s6
     e44:	debff0ef          	jal	ra,c2e <printint>
     e48:	8bca                	mv	s7,s2
      state = 0;
     e4a:	4981                	li	s3,0
     e4c:	bde1                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e4e:	008b8913          	addi	s2,s7,8
     e52:	4681                	li	a3,0
     e54:	4629                	li	a2,10
     e56:	000bb583          	ld	a1,0(s7)
     e5a:	855a                	mv	a0,s6
     e5c:	dd3ff0ef          	jal	ra,c2e <printint>
        i += 1;
     e60:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     e62:	8bca                	mv	s7,s2
      state = 0;
     e64:	4981                	li	s3,0
        i += 1;
     e66:	bd7d                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e68:	008b8913          	addi	s2,s7,8
     e6c:	4681                	li	a3,0
     e6e:	4629                	li	a2,10
     e70:	000bb583          	ld	a1,0(s7)
     e74:	855a                	mv	a0,s6
     e76:	db9ff0ef          	jal	ra,c2e <printint>
        i += 2;
     e7a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     e7c:	8bca                	mv	s7,s2
      state = 0;
     e7e:	4981                	li	s3,0
        i += 2;
     e80:	b555                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     e82:	008b8913          	addi	s2,s7,8
     e86:	4681                	li	a3,0
     e88:	4641                	li	a2,16
     e8a:	000be583          	lwu	a1,0(s7)
     e8e:	855a                	mv	a0,s6
     e90:	d9fff0ef          	jal	ra,c2e <printint>
     e94:	8bca                	mv	s7,s2
      state = 0;
     e96:	4981                	li	s3,0
     e98:	b571                	j	d24 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e9a:	008b8913          	addi	s2,s7,8
     e9e:	4681                	li	a3,0
     ea0:	4641                	li	a2,16
     ea2:	000bb583          	ld	a1,0(s7)
     ea6:	855a                	mv	a0,s6
     ea8:	d87ff0ef          	jal	ra,c2e <printint>
        i += 1;
     eac:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     eae:	8bca                	mv	s7,s2
      state = 0;
     eb0:	4981                	li	s3,0
        i += 1;
     eb2:	bd8d                	j	d24 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
     eb4:	008b8793          	addi	a5,s7,8
     eb8:	f8f43423          	sd	a5,-120(s0)
     ebc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     ec0:	03000593          	li	a1,48
     ec4:	855a                	mv	a0,s6
     ec6:	d4bff0ef          	jal	ra,c10 <putc>
  putc(fd, 'x');
     eca:	07800593          	li	a1,120
     ece:	855a                	mv	a0,s6
     ed0:	d41ff0ef          	jal	ra,c10 <putc>
     ed4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     ed6:	03c9d793          	srli	a5,s3,0x3c
     eda:	97e6                	add	a5,a5,s9
     edc:	0007c583          	lbu	a1,0(a5)
     ee0:	855a                	mv	a0,s6
     ee2:	d2fff0ef          	jal	ra,c10 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     ee6:	0992                	slli	s3,s3,0x4
     ee8:	397d                	addiw	s2,s2,-1
     eea:	fe0916e3          	bnez	s2,ed6 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
     eee:	f8843b83          	ld	s7,-120(s0)
      state = 0;
     ef2:	4981                	li	s3,0
     ef4:	bd05                	j	d24 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
     ef6:	008b8913          	addi	s2,s7,8
     efa:	000bc583          	lbu	a1,0(s7)
     efe:	855a                	mv	a0,s6
     f00:	d11ff0ef          	jal	ra,c10 <putc>
     f04:	8bca                	mv	s7,s2
      state = 0;
     f06:	4981                	li	s3,0
     f08:	bd31                	j	d24 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
     f0a:	008b8993          	addi	s3,s7,8
     f0e:	000bb903          	ld	s2,0(s7)
     f12:	00090f63          	beqz	s2,f30 <vprintf+0x266>
        for(; *s; s++)
     f16:	00094583          	lbu	a1,0(s2)
     f1a:	c195                	beqz	a1,f3e <vprintf+0x274>
          putc(fd, *s);
     f1c:	855a                	mv	a0,s6
     f1e:	cf3ff0ef          	jal	ra,c10 <putc>
        for(; *s; s++)
     f22:	0905                	addi	s2,s2,1
     f24:	00094583          	lbu	a1,0(s2)
     f28:	f9f5                	bnez	a1,f1c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
     f2a:	8bce                	mv	s7,s3
      state = 0;
     f2c:	4981                	li	s3,0
     f2e:	bbdd                	j	d24 <vprintf+0x5a>
          s = "(null)";
     f30:	00000917          	auipc	s2,0x0
     f34:	53890913          	addi	s2,s2,1336 # 1468 <malloc+0x428>
        for(; *s; s++)
     f38:	02800593          	li	a1,40
     f3c:	b7c5                	j	f1c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
     f3e:	8bce                	mv	s7,s3
      state = 0;
     f40:	4981                	li	s3,0
     f42:	b3cd                	j	d24 <vprintf+0x5a>
    }
  }
}
     f44:	70e6                	ld	ra,120(sp)
     f46:	7446                	ld	s0,112(sp)
     f48:	74a6                	ld	s1,104(sp)
     f4a:	7906                	ld	s2,96(sp)
     f4c:	69e6                	ld	s3,88(sp)
     f4e:	6a46                	ld	s4,80(sp)
     f50:	6aa6                	ld	s5,72(sp)
     f52:	6b06                	ld	s6,64(sp)
     f54:	7be2                	ld	s7,56(sp)
     f56:	7c42                	ld	s8,48(sp)
     f58:	7ca2                	ld	s9,40(sp)
     f5a:	7d02                	ld	s10,32(sp)
     f5c:	6de2                	ld	s11,24(sp)
     f5e:	6109                	addi	sp,sp,128
     f60:	8082                	ret

0000000000000f62 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f62:	715d                	addi	sp,sp,-80
     f64:	ec06                	sd	ra,24(sp)
     f66:	e822                	sd	s0,16(sp)
     f68:	1000                	addi	s0,sp,32
     f6a:	e010                	sd	a2,0(s0)
     f6c:	e414                	sd	a3,8(s0)
     f6e:	e818                	sd	a4,16(s0)
     f70:	ec1c                	sd	a5,24(s0)
     f72:	03043023          	sd	a6,32(s0)
     f76:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     f7a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     f7e:	8622                	mv	a2,s0
     f80:	d4bff0ef          	jal	ra,cca <vprintf>
}
     f84:	60e2                	ld	ra,24(sp)
     f86:	6442                	ld	s0,16(sp)
     f88:	6161                	addi	sp,sp,80
     f8a:	8082                	ret

0000000000000f8c <printf>:

void
printf(const char *fmt, ...)
{
     f8c:	711d                	addi	sp,sp,-96
     f8e:	ec06                	sd	ra,24(sp)
     f90:	e822                	sd	s0,16(sp)
     f92:	1000                	addi	s0,sp,32
     f94:	e40c                	sd	a1,8(s0)
     f96:	e810                	sd	a2,16(s0)
     f98:	ec14                	sd	a3,24(s0)
     f9a:	f018                	sd	a4,32(s0)
     f9c:	f41c                	sd	a5,40(s0)
     f9e:	03043823          	sd	a6,48(s0)
     fa2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     fa6:	00840613          	addi	a2,s0,8
     faa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     fae:	85aa                	mv	a1,a0
     fb0:	4505                	li	a0,1
     fb2:	d19ff0ef          	jal	ra,cca <vprintf>
}
     fb6:	60e2                	ld	ra,24(sp)
     fb8:	6442                	ld	s0,16(sp)
     fba:	6125                	addi	sp,sp,96
     fbc:	8082                	ret

0000000000000fbe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fbe:	1141                	addi	sp,sp,-16
     fc0:	e422                	sd	s0,8(sp)
     fc2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     fc4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fc8:	00001797          	auipc	a5,0x1
     fcc:	0487b783          	ld	a5,72(a5) # 2010 <freep>
     fd0:	a02d                	j	ffa <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     fd2:	4618                	lw	a4,8(a2)
     fd4:	9f2d                	addw	a4,a4,a1
     fd6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     fda:	6398                	ld	a4,0(a5)
     fdc:	6310                	ld	a2,0(a4)
     fde:	a83d                	j	101c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
     fe0:	ff852703          	lw	a4,-8(a0)
     fe4:	9f31                	addw	a4,a4,a2
     fe6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
     fe8:	ff053683          	ld	a3,-16(a0)
     fec:	a091                	j	1030 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fee:	6398                	ld	a4,0(a5)
     ff0:	00e7e463          	bltu	a5,a4,ff8 <free+0x3a>
     ff4:	00e6ea63          	bltu	a3,a4,1008 <free+0x4a>
{
     ff8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ffa:	fed7fae3          	bgeu	a5,a3,fee <free+0x30>
     ffe:	6398                	ld	a4,0(a5)
    1000:	00e6e463          	bltu	a3,a4,1008 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1004:	fee7eae3          	bltu	a5,a4,ff8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1008:	ff852583          	lw	a1,-8(a0)
    100c:	6390                	ld	a2,0(a5)
    100e:	02059813          	slli	a6,a1,0x20
    1012:	01c85713          	srli	a4,a6,0x1c
    1016:	9736                	add	a4,a4,a3
    1018:	fae60de3          	beq	a2,a4,fd2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    101c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1020:	4790                	lw	a2,8(a5)
    1022:	02061593          	slli	a1,a2,0x20
    1026:	01c5d713          	srli	a4,a1,0x1c
    102a:	973e                	add	a4,a4,a5
    102c:	fae68ae3          	beq	a3,a4,fe0 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1030:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1032:	00001717          	auipc	a4,0x1
    1036:	fcf73f23          	sd	a5,-34(a4) # 2010 <freep>
}
    103a:	6422                	ld	s0,8(sp)
    103c:	0141                	addi	sp,sp,16
    103e:	8082                	ret

0000000000001040 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1040:	7139                	addi	sp,sp,-64
    1042:	fc06                	sd	ra,56(sp)
    1044:	f822                	sd	s0,48(sp)
    1046:	f426                	sd	s1,40(sp)
    1048:	f04a                	sd	s2,32(sp)
    104a:	ec4e                	sd	s3,24(sp)
    104c:	e852                	sd	s4,16(sp)
    104e:	e456                	sd	s5,8(sp)
    1050:	e05a                	sd	s6,0(sp)
    1052:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1054:	02051493          	slli	s1,a0,0x20
    1058:	9081                	srli	s1,s1,0x20
    105a:	04bd                	addi	s1,s1,15
    105c:	8091                	srli	s1,s1,0x4
    105e:	0014899b          	addiw	s3,s1,1
    1062:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1064:	00001517          	auipc	a0,0x1
    1068:	fac53503          	ld	a0,-84(a0) # 2010 <freep>
    106c:	c515                	beqz	a0,1098 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    106e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1070:	4798                	lw	a4,8(a5)
    1072:	02977f63          	bgeu	a4,s1,10b0 <malloc+0x70>
    1076:	8a4e                	mv	s4,s3
    1078:	0009871b          	sext.w	a4,s3
    107c:	6685                	lui	a3,0x1
    107e:	00d77363          	bgeu	a4,a3,1084 <malloc+0x44>
    1082:	6a05                	lui	s4,0x1
    1084:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1088:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    108c:	00001917          	auipc	s2,0x1
    1090:	f8490913          	addi	s2,s2,-124 # 2010 <freep>
  if(p == SBRK_ERROR)
    1094:	5afd                	li	s5,-1
    1096:	a885                	j	1106 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
    1098:	00001797          	auipc	a5,0x1
    109c:	37078793          	addi	a5,a5,880 # 2408 <base>
    10a0:	00001717          	auipc	a4,0x1
    10a4:	f6f73823          	sd	a5,-144(a4) # 2010 <freep>
    10a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    10aa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    10ae:	b7e1                	j	1076 <malloc+0x36>
      if(p->s.size == nunits)
    10b0:	02e48c63          	beq	s1,a4,10e8 <malloc+0xa8>
        p->s.size -= nunits;
    10b4:	4137073b          	subw	a4,a4,s3
    10b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
    10ba:	02071693          	slli	a3,a4,0x20
    10be:	01c6d713          	srli	a4,a3,0x1c
    10c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    10c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    10c8:	00001717          	auipc	a4,0x1
    10cc:	f4a73423          	sd	a0,-184(a4) # 2010 <freep>
      return (void*)(p + 1);
    10d0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    10d4:	70e2                	ld	ra,56(sp)
    10d6:	7442                	ld	s0,48(sp)
    10d8:	74a2                	ld	s1,40(sp)
    10da:	7902                	ld	s2,32(sp)
    10dc:	69e2                	ld	s3,24(sp)
    10de:	6a42                	ld	s4,16(sp)
    10e0:	6aa2                	ld	s5,8(sp)
    10e2:	6b02                	ld	s6,0(sp)
    10e4:	6121                	addi	sp,sp,64
    10e6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    10e8:	6398                	ld	a4,0(a5)
    10ea:	e118                	sd	a4,0(a0)
    10ec:	bff1                	j	10c8 <malloc+0x88>
  hp->s.size = nu;
    10ee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    10f2:	0541                	addi	a0,a0,16
    10f4:	ecbff0ef          	jal	ra,fbe <free>
  return freep;
    10f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    10fc:	dd61                	beqz	a0,10d4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1100:	4798                	lw	a4,8(a5)
    1102:	fa9777e3          	bgeu	a4,s1,10b0 <malloc+0x70>
    if(p == freep)
    1106:	00093703          	ld	a4,0(s2)
    110a:	853e                	mv	a0,a5
    110c:	fef719e3          	bne	a4,a5,10fe <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
    1110:	8552                	mv	a0,s4
    1112:	a1bff0ef          	jal	ra,b2c <sbrk>
  if(p == SBRK_ERROR)
    1116:	fd551ce3          	bne	a0,s5,10ee <malloc+0xae>
        return 0;
    111a:	4501                	li	a0,0
    111c:	bf65                	j	10d4 <malloc+0x94>
