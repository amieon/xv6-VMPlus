
user/_shm_keep：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/shm.h"
#include "user.h"

int 
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  int key = 1;
  char *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
   a:	4705                	li	a4,1
   c:	468d                	li	a3,3
   e:	460d                	li	a2,3
  10:	6585                	lui	a1,0x1
  12:	4501                	li	a0,0
  14:	412000ef          	jal	ra,426 <mmap>
  if(p == (char*)-1){
  18:	57fd                	li	a5,-1
  1a:	04f50363          	beq	a0,a5,60 <main+0x60>
  1e:	84aa                	mv	s1,a0
    printf("mmap fail\n");
    exit(1);
  }

  int pid = fork();
  20:	35e000ef          	jal	ra,37e <fork>
  if(pid == 0){
  24:	e539                	bnez	a0,72 <main+0x72>
    // child：持有映射，写入，然后睡一会儿别退出
    p[0] = 99;
  26:	06300793          	li	a5,99
  2a:	00f48023          	sb	a5,0(s1)
    printf("child wrote 99\n");
  2e:	00001517          	auipc	a0,0x1
  32:	94250513          	addi	a0,a0,-1726 # 970 <malloc+0xfa>
  36:	78c000ef          	jal	ra,7c2 <printf>
    sleep(50);
  3a:	03200513          	li	a0,50
  3e:	400000ef          	jal	ra,43e <sleep>
    printf("child still sees %d\n", p[0]);
  42:	0004c583          	lbu	a1,0(s1)
  46:	00001517          	auipc	a0,0x1
  4a:	93a50513          	addi	a0,a0,-1734 # 980 <malloc+0x10a>
  4e:	774000ef          	jal	ra,7c2 <printf>
    munmap(p, 4096);
  52:	6585                	lui	a1,0x1
  54:	8526                	mv	a0,s1
  56:	3d8000ef          	jal	ra,42e <munmap>
    exit(0);
  5a:	4501                	li	a0,0
  5c:	32a000ef          	jal	ra,386 <exit>
    printf("mmap fail\n");
  60:	00001517          	auipc	a0,0x1
  64:	90050513          	addi	a0,a0,-1792 # 960 <malloc+0xea>
  68:	75a000ef          	jal	ra,7c2 <printf>
    exit(1);
  6c:	4505                	li	a0,1
  6e:	318000ef          	jal	ra,386 <exit>
  }

  // parent：等 child 写完
  sleep(20);
  72:	4551                	li	a0,20
  74:	3ca000ef          	jal	ra,43e <sleep>
  printf("parent sees %d before unmap\n", p[0]);
  78:	0004c583          	lbu	a1,0(s1)
  7c:	00001517          	auipc	a0,0x1
  80:	91c50513          	addi	a0,a0,-1764 # 998 <malloc+0x122>
  84:	73e000ef          	jal	ra,7c2 <printf>

  // parent 解除映射
  if(munmap(p, 4096) < 0){
  88:	6585                	lui	a1,0x1
  8a:	8526                	mv	a0,s1
  8c:	3a2000ef          	jal	ra,42e <munmap>
  90:	02054f63          	bltz	a0,ce <main+0xce>
    printf("parent munmap failed\n");
    exit(1);
  }

  // parent 再次 mmap 同 key（此时 child 还活着、refcnt>0）
  char *q = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
  94:	4705                	li	a4,1
  96:	468d                	li	a3,3
  98:	460d                	li	a2,3
  9a:	6585                	lui	a1,0x1
  9c:	4501                	li	a0,0
  9e:	388000ef          	jal	ra,426 <mmap>
  a2:	84aa                	mv	s1,a0
  if(q == (char*)-1){
  a4:	57fd                	li	a5,-1
  a6:	02f50d63          	beq	a0,a5,e0 <main+0xe0>
    printf("remap fail\n");
    exit(1);
  }

  printf("parent sees %d after remap\n", q[0]); // 预期仍是 99
  aa:	00054583          	lbu	a1,0(a0)
  ae:	00001517          	auipc	a0,0x1
  b2:	93250513          	addi	a0,a0,-1742 # 9e0 <malloc+0x16a>
  b6:	70c000ef          	jal	ra,7c2 <printf>

  wait(0);
  ba:	4501                	li	a0,0
  bc:	2d2000ef          	jal	ra,38e <wait>
  munmap(q, 4096);
  c0:	6585                	lui	a1,0x1
  c2:	8526                	mv	a0,s1
  c4:	36a000ef          	jal	ra,42e <munmap>
  exit(0);
  c8:	4501                	li	a0,0
  ca:	2bc000ef          	jal	ra,386 <exit>
    printf("parent munmap failed\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	8ea50513          	addi	a0,a0,-1814 # 9b8 <malloc+0x142>
  d6:	6ec000ef          	jal	ra,7c2 <printf>
    exit(1);
  da:	4505                	li	a0,1
  dc:	2aa000ef          	jal	ra,386 <exit>
    printf("remap fail\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	8f050513          	addi	a0,a0,-1808 # 9d0 <malloc+0x15a>
  e8:	6da000ef          	jal	ra,7c2 <printf>
    exit(1);
  ec:	4505                	li	a0,1
  ee:	298000ef          	jal	ra,386 <exit>

00000000000000f2 <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e406                	sd	ra,8(sp)
  f6:	e022                	sd	s0,0(sp)
  f8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  fa:	f07ff0ef          	jal	ra,0 <main>
  exit(r);
  fe:	288000ef          	jal	ra,386 <exit>

0000000000000102 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 108:	87aa                	mv	a5,a0
 10a:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
 10c:	0785                	addi	a5,a5,1
 10e:	fff5c703          	lbu	a4,-1(a1)
 112:	fee78fa3          	sb	a4,-1(a5)
 116:	fb75                	bnez	a4,10a <strcpy+0x8>
    ;
  return os;
}
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 124:	00054783          	lbu	a5,0(a0)
 128:	cb91                	beqz	a5,13c <strcmp+0x1e>
 12a:	0005c703          	lbu	a4,0(a1)
 12e:	00f71763          	bne	a4,a5,13c <strcmp+0x1e>
    p++, q++;
 132:	0505                	addi	a0,a0,1
 134:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 136:	00054783          	lbu	a5,0(a0)
 13a:	fbe5                	bnez	a5,12a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 13c:	0005c503          	lbu	a0,0(a1)
}
 140:	40a7853b          	subw	a0,a5,a0
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strlen>:

uint
strlen(const char *s)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 150:	00054783          	lbu	a5,0(a0)
 154:	cf91                	beqz	a5,170 <strlen+0x26>
 156:	0505                	addi	a0,a0,1
 158:	87aa                	mv	a5,a0
 15a:	4685                	li	a3,1
 15c:	9e89                	subw	a3,a3,a0
 15e:	00f6853b          	addw	a0,a3,a5
 162:	0785                	addi	a5,a5,1
 164:	fff7c703          	lbu	a4,-1(a5)
 168:	fb7d                	bnez	a4,15e <strlen+0x14>
    ;
  return n;
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  for(n = 0; s[n]; n++)
 170:	4501                	li	a0,0
 172:	bfe5                	j	16a <strlen+0x20>

0000000000000174 <memset>:

void*
memset(void *dst, int c, uint n)
{
 174:	1141                	addi	sp,sp,-16
 176:	e422                	sd	s0,8(sp)
 178:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17a:	ca19                	beqz	a2,190 <memset+0x1c>
 17c:	87aa                	mv	a5,a0
 17e:	1602                	slli	a2,a2,0x20
 180:	9201                	srli	a2,a2,0x20
 182:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 186:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18a:	0785                	addi	a5,a5,1
 18c:	fee79de3          	bne	a5,a4,186 <memset+0x12>
  }
  return dst;
}
 190:	6422                	ld	s0,8(sp)
 192:	0141                	addi	sp,sp,16
 194:	8082                	ret

0000000000000196 <strchr>:

char*
strchr(const char *s, char c)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	cb99                	beqz	a5,1b6 <strchr+0x20>
    if(*s == c)
 1a2:	00f58763          	beq	a1,a5,1b0 <strchr+0x1a>
  for(; *s; s++)
 1a6:	0505                	addi	a0,a0,1
 1a8:	00054783          	lbu	a5,0(a0)
 1ac:	fbfd                	bnez	a5,1a2 <strchr+0xc>
      return (char*)s;
  return 0;
 1ae:	4501                	li	a0,0
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret
  return 0;
 1b6:	4501                	li	a0,0
 1b8:	bfe5                	j	1b0 <strchr+0x1a>

00000000000001ba <gets>:

char*
gets(char *buf, int max)
{
 1ba:	711d                	addi	sp,sp,-96
 1bc:	ec86                	sd	ra,88(sp)
 1be:	e8a2                	sd	s0,80(sp)
 1c0:	e4a6                	sd	s1,72(sp)
 1c2:	e0ca                	sd	s2,64(sp)
 1c4:	fc4e                	sd	s3,56(sp)
 1c6:	f852                	sd	s4,48(sp)
 1c8:	f456                	sd	s5,40(sp)
 1ca:	f05a                	sd	s6,32(sp)
 1cc:	ec5e                	sd	s7,24(sp)
 1ce:	1080                	addi	s0,sp,96
 1d0:	8baa                	mv	s7,a0
 1d2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	892a                	mv	s2,a0
 1d6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d8:	4aa9                	li	s5,10
 1da:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1dc:	89a6                	mv	s3,s1
 1de:	2485                	addiw	s1,s1,1
 1e0:	0344d663          	bge	s1,s4,20c <gets+0x52>
    cc = read(0, &c, 1);
 1e4:	4605                	li	a2,1
 1e6:	faf40593          	addi	a1,s0,-81
 1ea:	4501                	li	a0,0
 1ec:	1b2000ef          	jal	ra,39e <read>
    if(cc < 1)
 1f0:	00a05e63          	blez	a0,20c <gets+0x52>
    buf[i++] = c;
 1f4:	faf44783          	lbu	a5,-81(s0)
 1f8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fc:	01578763          	beq	a5,s5,20a <gets+0x50>
 200:	0905                	addi	s2,s2,1
 202:	fd679de3          	bne	a5,s6,1dc <gets+0x22>
  for(i=0; i+1 < max; ){
 206:	89a6                	mv	s3,s1
 208:	a011                	j	20c <gets+0x52>
 20a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20c:	99de                	add	s3,s3,s7
 20e:	00098023          	sb	zero,0(s3)
  return buf;
}
 212:	855e                	mv	a0,s7
 214:	60e6                	ld	ra,88(sp)
 216:	6446                	ld	s0,80(sp)
 218:	64a6                	ld	s1,72(sp)
 21a:	6906                	ld	s2,64(sp)
 21c:	79e2                	ld	s3,56(sp)
 21e:	7a42                	ld	s4,48(sp)
 220:	7aa2                	ld	s5,40(sp)
 222:	7b02                	ld	s6,32(sp)
 224:	6be2                	ld	s7,24(sp)
 226:	6125                	addi	sp,sp,96
 228:	8082                	ret

000000000000022a <stat>:

int
stat(const char *n, struct stat *st)
{
 22a:	1101                	addi	sp,sp,-32
 22c:	ec06                	sd	ra,24(sp)
 22e:	e822                	sd	s0,16(sp)
 230:	e426                	sd	s1,8(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	18c000ef          	jal	ra,3c6 <open>
  if(fd < 0)
 23e:	02054163          	bltz	a0,260 <stat+0x36>
 242:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 244:	85ca                	mv	a1,s2
 246:	198000ef          	jal	ra,3de <fstat>
 24a:	892a                	mv	s2,a0
  close(fd);
 24c:	8526                	mv	a0,s1
 24e:	160000ef          	jal	ra,3ae <close>
  return r;
}
 252:	854a                	mv	a0,s2
 254:	60e2                	ld	ra,24(sp)
 256:	6442                	ld	s0,16(sp)
 258:	64a2                	ld	s1,8(sp)
 25a:	6902                	ld	s2,0(sp)
 25c:	6105                	addi	sp,sp,32
 25e:	8082                	ret
    return -1;
 260:	597d                	li	s2,-1
 262:	bfc5                	j	252 <stat+0x28>

0000000000000264 <atoi>:

int
atoi(const char *s)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26a:	00054683          	lbu	a3,0(a0)
 26e:	fd06879b          	addiw	a5,a3,-48
 272:	0ff7f793          	zext.b	a5,a5
 276:	4625                	li	a2,9
 278:	02f66863          	bltu	a2,a5,2a8 <atoi+0x44>
 27c:	872a                	mv	a4,a0
  n = 0;
 27e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 280:	0705                	addi	a4,a4,1
 282:	0025179b          	slliw	a5,a0,0x2
 286:	9fa9                	addw	a5,a5,a0
 288:	0017979b          	slliw	a5,a5,0x1
 28c:	9fb5                	addw	a5,a5,a3
 28e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 292:	00074683          	lbu	a3,0(a4)
 296:	fd06879b          	addiw	a5,a3,-48
 29a:	0ff7f793          	zext.b	a5,a5
 29e:	fef671e3          	bgeu	a2,a5,280 <atoi+0x1c>
  return n;
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
  n = 0;
 2a8:	4501                	li	a0,0
 2aa:	bfe5                	j	2a2 <atoi+0x3e>

00000000000002ac <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b2:	02b57463          	bgeu	a0,a1,2da <memmove+0x2e>
    while(n-- > 0)
 2b6:	00c05f63          	blez	a2,2d4 <memmove+0x28>
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c4:	0585                	addi	a1,a1,1
 2c6:	0705                	addi	a4,a4,1
 2c8:	fff5c683          	lbu	a3,-1(a1)
 2cc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
    dst += n;
 2da:	00c50733          	add	a4,a0,a2
    src += n;
 2de:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e0:	fec05ae3          	blez	a2,2d4 <memmove+0x28>
 2e4:	fff6079b          	addiw	a5,a2,-1
 2e8:	1782                	slli	a5,a5,0x20
 2ea:	9381                	srli	a5,a5,0x20
 2ec:	fff7c793          	not	a5,a5
 2f0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f2:	15fd                	addi	a1,a1,-1
 2f4:	177d                	addi	a4,a4,-1
 2f6:	0005c683          	lbu	a3,0(a1)
 2fa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fe:	fee79ae3          	bne	a5,a4,2f2 <memmove+0x46>
 302:	bfc9                	j	2d4 <memmove+0x28>

0000000000000304 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e422                	sd	s0,8(sp)
 308:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30a:	ca05                	beqz	a2,33a <memcmp+0x36>
 30c:	fff6069b          	addiw	a3,a2,-1
 310:	1682                	slli	a3,a3,0x20
 312:	9281                	srli	a3,a3,0x20
 314:	0685                	addi	a3,a3,1
 316:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 318:	00054783          	lbu	a5,0(a0)
 31c:	0005c703          	lbu	a4,0(a1)
 320:	00e79863          	bne	a5,a4,330 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 324:	0505                	addi	a0,a0,1
    p2++;
 326:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 328:	fed518e3          	bne	a0,a3,318 <memcmp+0x14>
  }
  return 0;
 32c:	4501                	li	a0,0
 32e:	a019                	j	334 <memcmp+0x30>
      return *p1 - *p2;
 330:	40e7853b          	subw	a0,a5,a4
}
 334:	6422                	ld	s0,8(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret
  return 0;
 33a:	4501                	li	a0,0
 33c:	bfe5                	j	334 <memcmp+0x30>

000000000000033e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 346:	f67ff0ef          	jal	ra,2ac <memmove>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <sbrk>:

char *
sbrk(int n) {
 352:	1141                	addi	sp,sp,-16
 354:	e406                	sd	ra,8(sp)
 356:	e022                	sd	s0,0(sp)
 358:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 35a:	4585                	li	a1,1
 35c:	0b2000ef          	jal	ra,40e <sys_sbrk>
}
 360:	60a2                	ld	ra,8(sp)
 362:	6402                	ld	s0,0(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret

0000000000000368 <sbrklazy>:

char *
sbrklazy(int n) {
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 370:	4589                	li	a1,2
 372:	09c000ef          	jal	ra,40e <sys_sbrk>
}
 376:	60a2                	ld	ra,8(sp)
 378:	6402                	ld	s0,0(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret

000000000000037e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37e:	4885                	li	a7,1
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <exit>:
.global exit
exit:
 li a7, SYS_exit
 386:	4889                	li	a7,2
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <wait>:
.global wait
wait:
 li a7, SYS_wait
 38e:	488d                	li	a7,3
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 396:	4891                	li	a7,4
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <read>:
.global read
read:
 li a7, SYS_read
 39e:	4895                	li	a7,5
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <write>:
.global write
write:
 li a7, SYS_write
 3a6:	48c1                	li	a7,16
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <close>:
.global close
close:
 li a7, SYS_close
 3ae:	48d5                	li	a7,21
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b6:	4899                	li	a7,6
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <exec>:
.global exec
exec:
 li a7, SYS_exec
 3be:	489d                	li	a7,7
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <open>:
.global open
open:
 li a7, SYS_open
 3c6:	48bd                	li	a7,15
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ce:	48c5                	li	a7,17
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d6:	48c9                	li	a7,18
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3de:	48a1                	li	a7,8
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <link>:
.global link
link:
 li a7, SYS_link
 3e6:	48cd                	li	a7,19
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ee:	48d1                	li	a7,20
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f6:	48a5                	li	a7,9
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fe:	48a9                	li	a7,10
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 406:	48ad                	li	a7,11
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 40e:	48b1                	li	a7,12
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <pause>:
.global pause
pause:
 li a7, SYS_pause
 416:	48b5                	li	a7,13
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41e:	48b9                	li	a7,14
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 426:	48d9                	li	a7,22
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 42e:	48dd                	li	a7,23
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 436:	48e1                	li	a7,24
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 43e:	48e5                	li	a7,25
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 446:	1101                	addi	sp,sp,-32
 448:	ec06                	sd	ra,24(sp)
 44a:	e822                	sd	s0,16(sp)
 44c:	1000                	addi	s0,sp,32
 44e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 452:	4605                	li	a2,1
 454:	fef40593          	addi	a1,s0,-17
 458:	f4fff0ef          	jal	ra,3a6 <write>
}
 45c:	60e2                	ld	ra,24(sp)
 45e:	6442                	ld	s0,16(sp)
 460:	6105                	addi	sp,sp,32
 462:	8082                	ret

0000000000000464 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 464:	715d                	addi	sp,sp,-80
 466:	e486                	sd	ra,72(sp)
 468:	e0a2                	sd	s0,64(sp)
 46a:	fc26                	sd	s1,56(sp)
 46c:	f84a                	sd	s2,48(sp)
 46e:	f44e                	sd	s3,40(sp)
 470:	0880                	addi	s0,sp,80
 472:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 474:	c299                	beqz	a3,47a <printint+0x16>
 476:	0805c163          	bltz	a1,4f8 <printint+0x94>
  neg = 0;
 47a:	4881                	li	a7,0
 47c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 480:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 482:	00000517          	auipc	a0,0x0
 486:	58650513          	addi	a0,a0,1414 # a08 <digits>
 48a:	883e                	mv	a6,a5
 48c:	2785                	addiw	a5,a5,1
 48e:	02c5f733          	remu	a4,a1,a2
 492:	972a                	add	a4,a4,a0
 494:	00074703          	lbu	a4,0(a4)
 498:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 49c:	872e                	mv	a4,a1
 49e:	02c5d5b3          	divu	a1,a1,a2
 4a2:	0685                	addi	a3,a3,1
 4a4:	fec773e3          	bgeu	a4,a2,48a <printint+0x26>
  if(neg)
 4a8:	00088b63          	beqz	a7,4be <printint+0x5a>
    buf[i++] = '-';
 4ac:	fd078793          	addi	a5,a5,-48
 4b0:	97a2                	add	a5,a5,s0
 4b2:	02d00713          	li	a4,45
 4b6:	fee78423          	sb	a4,-24(a5)
 4ba:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4be:	02f05663          	blez	a5,4ea <printint+0x86>
 4c2:	fb840713          	addi	a4,s0,-72
 4c6:	00f704b3          	add	s1,a4,a5
 4ca:	fff70993          	addi	s3,a4,-1
 4ce:	99be                	add	s3,s3,a5
 4d0:	37fd                	addiw	a5,a5,-1
 4d2:	1782                	slli	a5,a5,0x20
 4d4:	9381                	srli	a5,a5,0x20
 4d6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4da:	fff4c583          	lbu	a1,-1(s1)
 4de:	854a                	mv	a0,s2
 4e0:	f67ff0ef          	jal	ra,446 <putc>
  while(--i >= 0)
 4e4:	14fd                	addi	s1,s1,-1
 4e6:	ff349ae3          	bne	s1,s3,4da <printint+0x76>
}
 4ea:	60a6                	ld	ra,72(sp)
 4ec:	6406                	ld	s0,64(sp)
 4ee:	74e2                	ld	s1,56(sp)
 4f0:	7942                	ld	s2,48(sp)
 4f2:	79a2                	ld	s3,40(sp)
 4f4:	6161                	addi	sp,sp,80
 4f6:	8082                	ret
    x = -xx;
 4f8:	40b005b3          	neg	a1,a1
    neg = 1;
 4fc:	4885                	li	a7,1
    x = -xx;
 4fe:	bfbd                	j	47c <printint+0x18>

0000000000000500 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 500:	7119                	addi	sp,sp,-128
 502:	fc86                	sd	ra,120(sp)
 504:	f8a2                	sd	s0,112(sp)
 506:	f4a6                	sd	s1,104(sp)
 508:	f0ca                	sd	s2,96(sp)
 50a:	ecce                	sd	s3,88(sp)
 50c:	e8d2                	sd	s4,80(sp)
 50e:	e4d6                	sd	s5,72(sp)
 510:	e0da                	sd	s6,64(sp)
 512:	fc5e                	sd	s7,56(sp)
 514:	f862                	sd	s8,48(sp)
 516:	f466                	sd	s9,40(sp)
 518:	f06a                	sd	s10,32(sp)
 51a:	ec6e                	sd	s11,24(sp)
 51c:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51e:	0005c903          	lbu	s2,0(a1)
 522:	24090c63          	beqz	s2,77a <vprintf+0x27a>
 526:	8b2a                	mv	s6,a0
 528:	8a2e                	mv	s4,a1
 52a:	8bb2                	mv	s7,a2
  state = 0;
 52c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 52e:	4481                	li	s1,0
 530:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 532:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 536:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 53a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 53e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 542:	00000c97          	auipc	s9,0x0
 546:	4c6c8c93          	addi	s9,s9,1222 # a08 <digits>
 54a:	a005                	j	56a <vprintf+0x6a>
        putc(fd, c0);
 54c:	85ca                	mv	a1,s2
 54e:	855a                	mv	a0,s6
 550:	ef7ff0ef          	jal	ra,446 <putc>
 554:	a019                	j	55a <vprintf+0x5a>
    } else if(state == '%'){
 556:	03598263          	beq	s3,s5,57a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 55a:	2485                	addiw	s1,s1,1
 55c:	8726                	mv	a4,s1
 55e:	009a07b3          	add	a5,s4,s1
 562:	0007c903          	lbu	s2,0(a5)
 566:	20090a63          	beqz	s2,77a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 56a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 56e:	fe0994e3          	bnez	s3,556 <vprintf+0x56>
      if(c0 == '%'){
 572:	fd579de3          	bne	a5,s5,54c <vprintf+0x4c>
        state = '%';
 576:	89be                	mv	s3,a5
 578:	b7cd                	j	55a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 57a:	c3c1                	beqz	a5,5fa <vprintf+0xfa>
 57c:	00ea06b3          	add	a3,s4,a4
 580:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 584:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 586:	c681                	beqz	a3,58e <vprintf+0x8e>
 588:	9752                	add	a4,a4,s4
 58a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 58e:	03878e63          	beq	a5,s8,5ca <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 592:	05a78863          	beq	a5,s10,5e2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 596:	0db78b63          	beq	a5,s11,66c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 59a:	07800713          	li	a4,120
 59e:	10e78d63          	beq	a5,a4,6b8 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5a2:	07000713          	li	a4,112
 5a6:	14e78263          	beq	a5,a4,6ea <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5aa:	06300713          	li	a4,99
 5ae:	16e78f63          	beq	a5,a4,72c <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5b2:	07300713          	li	a4,115
 5b6:	18e78563          	beq	a5,a4,740 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ba:	05579063          	bne	a5,s5,5fa <vprintf+0xfa>
        putc(fd, '%');
 5be:	85d6                	mv	a1,s5
 5c0:	855a                	mv	a0,s6
 5c2:	e85ff0ef          	jal	ra,446 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bf49                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4685                	li	a3,1
 5d0:	4629                	li	a2,10
 5d2:	000ba583          	lw	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	e8dff0ef          	jal	ra,464 <printint>
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bfad                	j	55a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5e2:	03868663          	beq	a3,s8,60e <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e6:	05a68163          	beq	a3,s10,628 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5ea:	09b68d63          	beq	a3,s11,684 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5ee:	03a68f63          	beq	a3,s10,62c <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5f2:	07800793          	li	a5,120
 5f6:	0cf68d63          	beq	a3,a5,6d0 <vprintf+0x1d0>
        putc(fd, '%');
 5fa:	85d6                	mv	a1,s5
 5fc:	855a                	mv	a0,s6
 5fe:	e49ff0ef          	jal	ra,446 <putc>
        putc(fd, c0);
 602:	85ca                	mv	a1,s2
 604:	855a                	mv	a0,s6
 606:	e41ff0ef          	jal	ra,446 <putc>
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b7b9                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 60e:	008b8913          	addi	s2,s7,8
 612:	4685                	li	a3,1
 614:	4629                	li	a2,10
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	e49ff0ef          	jal	ra,464 <printint>
        i += 1;
 620:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 1;
 626:	bf15                	j	55a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 628:	03860563          	beq	a2,s8,652 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 62c:	07b60963          	beq	a2,s11,69e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 630:	07800793          	li	a5,120
 634:	fcf613e3          	bne	a2,a5,5fa <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 638:	008b8913          	addi	s2,s7,8
 63c:	4681                	li	a3,0
 63e:	4641                	li	a2,16
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e1fff0ef          	jal	ra,464 <printint>
        i += 2;
 64a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 2;
 650:	b729                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 652:	008b8913          	addi	s2,s7,8
 656:	4685                	li	a3,1
 658:	4629                	li	a2,10
 65a:	000bb583          	ld	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	e05ff0ef          	jal	ra,464 <printint>
        i += 2;
 664:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 666:	8bca                	mv	s7,s2
      state = 0;
 668:	4981                	li	s3,0
        i += 2;
 66a:	bdc5                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 66c:	008b8913          	addi	s2,s7,8
 670:	4681                	li	a3,0
 672:	4629                	li	a2,10
 674:	000be583          	lwu	a1,0(s7)
 678:	855a                	mv	a0,s6
 67a:	debff0ef          	jal	ra,464 <printint>
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	bde1                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 684:	008b8913          	addi	s2,s7,8
 688:	4681                	li	a3,0
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	dd3ff0ef          	jal	ra,464 <printint>
        i += 1;
 696:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 1;
 69c:	bd7d                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69e:	008b8913          	addi	s2,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4629                	li	a2,10
 6a6:	000bb583          	ld	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	db9ff0ef          	jal	ra,464 <printint>
        i += 2;
 6b0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b2:	8bca                	mv	s7,s2
      state = 0;
 6b4:	4981                	li	s3,0
        i += 2;
 6b6:	b555                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6b8:	008b8913          	addi	s2,s7,8
 6bc:	4681                	li	a3,0
 6be:	4641                	li	a2,16
 6c0:	000be583          	lwu	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	d9fff0ef          	jal	ra,464 <printint>
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b571                	j	55a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	4681                	li	a3,0
 6d6:	4641                	li	a2,16
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	d87ff0ef          	jal	ra,464 <printint>
        i += 1;
 6e2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e4:	8bca                	mv	s7,s2
      state = 0;
 6e6:	4981                	li	s3,0
        i += 1;
 6e8:	bd8d                	j	55a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6ea:	008b8793          	addi	a5,s7,8
 6ee:	f8f43423          	sd	a5,-120(s0)
 6f2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6f6:	03000593          	li	a1,48
 6fa:	855a                	mv	a0,s6
 6fc:	d4bff0ef          	jal	ra,446 <putc>
  putc(fd, 'x');
 700:	07800593          	li	a1,120
 704:	855a                	mv	a0,s6
 706:	d41ff0ef          	jal	ra,446 <putc>
 70a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70c:	03c9d793          	srli	a5,s3,0x3c
 710:	97e6                	add	a5,a5,s9
 712:	0007c583          	lbu	a1,0(a5)
 716:	855a                	mv	a0,s6
 718:	d2fff0ef          	jal	ra,446 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71c:	0992                	slli	s3,s3,0x4
 71e:	397d                	addiw	s2,s2,-1
 720:	fe0916e3          	bnez	s2,70c <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 724:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 728:	4981                	li	s3,0
 72a:	bd05                	j	55a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 72c:	008b8913          	addi	s2,s7,8
 730:	000bc583          	lbu	a1,0(s7)
 734:	855a                	mv	a0,s6
 736:	d11ff0ef          	jal	ra,446 <putc>
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
 73e:	bd31                	j	55a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 740:	008b8993          	addi	s3,s7,8
 744:	000bb903          	ld	s2,0(s7)
 748:	00090f63          	beqz	s2,766 <vprintf+0x266>
        for(; *s; s++)
 74c:	00094583          	lbu	a1,0(s2)
 750:	c195                	beqz	a1,774 <vprintf+0x274>
          putc(fd, *s);
 752:	855a                	mv	a0,s6
 754:	cf3ff0ef          	jal	ra,446 <putc>
        for(; *s; s++)
 758:	0905                	addi	s2,s2,1
 75a:	00094583          	lbu	a1,0(s2)
 75e:	f9f5                	bnez	a1,752 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 760:	8bce                	mv	s7,s3
      state = 0;
 762:	4981                	li	s3,0
 764:	bbdd                	j	55a <vprintf+0x5a>
          s = "(null)";
 766:	00000917          	auipc	s2,0x0
 76a:	29a90913          	addi	s2,s2,666 # a00 <malloc+0x18a>
        for(; *s; s++)
 76e:	02800593          	li	a1,40
 772:	b7c5                	j	752 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 774:	8bce                	mv	s7,s3
      state = 0;
 776:	4981                	li	s3,0
 778:	b3cd                	j	55a <vprintf+0x5a>
    }
  }
}
 77a:	70e6                	ld	ra,120(sp)
 77c:	7446                	ld	s0,112(sp)
 77e:	74a6                	ld	s1,104(sp)
 780:	7906                	ld	s2,96(sp)
 782:	69e6                	ld	s3,88(sp)
 784:	6a46                	ld	s4,80(sp)
 786:	6aa6                	ld	s5,72(sp)
 788:	6b06                	ld	s6,64(sp)
 78a:	7be2                	ld	s7,56(sp)
 78c:	7c42                	ld	s8,48(sp)
 78e:	7ca2                	ld	s9,40(sp)
 790:	7d02                	ld	s10,32(sp)
 792:	6de2                	ld	s11,24(sp)
 794:	6109                	addi	sp,sp,128
 796:	8082                	ret

0000000000000798 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 798:	715d                	addi	sp,sp,-80
 79a:	ec06                	sd	ra,24(sp)
 79c:	e822                	sd	s0,16(sp)
 79e:	1000                	addi	s0,sp,32
 7a0:	e010                	sd	a2,0(s0)
 7a2:	e414                	sd	a3,8(s0)
 7a4:	e818                	sd	a4,16(s0)
 7a6:	ec1c                	sd	a5,24(s0)
 7a8:	03043023          	sd	a6,32(s0)
 7ac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b4:	8622                	mv	a2,s0
 7b6:	d4bff0ef          	jal	ra,500 <vprintf>
}
 7ba:	60e2                	ld	ra,24(sp)
 7bc:	6442                	ld	s0,16(sp)
 7be:	6161                	addi	sp,sp,80
 7c0:	8082                	ret

00000000000007c2 <printf>:

void
printf(const char *fmt, ...)
{
 7c2:	711d                	addi	sp,sp,-96
 7c4:	ec06                	sd	ra,24(sp)
 7c6:	e822                	sd	s0,16(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	e40c                	sd	a1,8(s0)
 7cc:	e810                	sd	a2,16(s0)
 7ce:	ec14                	sd	a3,24(s0)
 7d0:	f018                	sd	a4,32(s0)
 7d2:	f41c                	sd	a5,40(s0)
 7d4:	03043823          	sd	a6,48(s0)
 7d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7dc:	00840613          	addi	a2,s0,8
 7e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e4:	85aa                	mv	a1,a0
 7e6:	4505                	li	a0,1
 7e8:	d19ff0ef          	jal	ra,500 <vprintf>
}
 7ec:	60e2                	ld	ra,24(sp)
 7ee:	6442                	ld	s0,16(sp)
 7f0:	6125                	addi	sp,sp,96
 7f2:	8082                	ret

00000000000007f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f4:	1141                	addi	sp,sp,-16
 7f6:	e422                	sd	s0,8(sp)
 7f8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fe:	00001797          	auipc	a5,0x1
 802:	8027b783          	ld	a5,-2046(a5) # 1000 <freep>
 806:	a02d                	j	830 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 808:	4618                	lw	a4,8(a2)
 80a:	9f2d                	addw	a4,a4,a1
 80c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 810:	6398                	ld	a4,0(a5)
 812:	6310                	ld	a2,0(a4)
 814:	a83d                	j	852 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 816:	ff852703          	lw	a4,-8(a0)
 81a:	9f31                	addw	a4,a4,a2
 81c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 81e:	ff053683          	ld	a3,-16(a0)
 822:	a091                	j	866 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 824:	6398                	ld	a4,0(a5)
 826:	00e7e463          	bltu	a5,a4,82e <free+0x3a>
 82a:	00e6ea63          	bltu	a3,a4,83e <free+0x4a>
{
 82e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 830:	fed7fae3          	bgeu	a5,a3,824 <free+0x30>
 834:	6398                	ld	a4,0(a5)
 836:	00e6e463          	bltu	a3,a4,83e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83a:	fee7eae3          	bltu	a5,a4,82e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 83e:	ff852583          	lw	a1,-8(a0)
 842:	6390                	ld	a2,0(a5)
 844:	02059813          	slli	a6,a1,0x20
 848:	01c85713          	srli	a4,a6,0x1c
 84c:	9736                	add	a4,a4,a3
 84e:	fae60de3          	beq	a2,a4,808 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 852:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 856:	4790                	lw	a2,8(a5)
 858:	02061593          	slli	a1,a2,0x20
 85c:	01c5d713          	srli	a4,a1,0x1c
 860:	973e                	add	a4,a4,a5
 862:	fae68ae3          	beq	a3,a4,816 <free+0x22>
    p->s.ptr = bp->s.ptr;
 866:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 868:	00000717          	auipc	a4,0x0
 86c:	78f73c23          	sd	a5,1944(a4) # 1000 <freep>
}
 870:	6422                	ld	s0,8(sp)
 872:	0141                	addi	sp,sp,16
 874:	8082                	ret

0000000000000876 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 876:	7139                	addi	sp,sp,-64
 878:	fc06                	sd	ra,56(sp)
 87a:	f822                	sd	s0,48(sp)
 87c:	f426                	sd	s1,40(sp)
 87e:	f04a                	sd	s2,32(sp)
 880:	ec4e                	sd	s3,24(sp)
 882:	e852                	sd	s4,16(sp)
 884:	e456                	sd	s5,8(sp)
 886:	e05a                	sd	s6,0(sp)
 888:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88a:	02051493          	slli	s1,a0,0x20
 88e:	9081                	srli	s1,s1,0x20
 890:	04bd                	addi	s1,s1,15
 892:	8091                	srli	s1,s1,0x4
 894:	0014899b          	addiw	s3,s1,1
 898:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 89a:	00000517          	auipc	a0,0x0
 89e:	76653503          	ld	a0,1894(a0) # 1000 <freep>
 8a2:	c515                	beqz	a0,8ce <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a6:	4798                	lw	a4,8(a5)
 8a8:	02977f63          	bgeu	a4,s1,8e6 <malloc+0x70>
 8ac:	8a4e                	mv	s4,s3
 8ae:	0009871b          	sext.w	a4,s3
 8b2:	6685                	lui	a3,0x1
 8b4:	00d77363          	bgeu	a4,a3,8ba <malloc+0x44>
 8b8:	6a05                	lui	s4,0x1
 8ba:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8be:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c2:	00000917          	auipc	s2,0x0
 8c6:	73e90913          	addi	s2,s2,1854 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ca:	5afd                	li	s5,-1
 8cc:	a885                	j	93c <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8ce:	00000797          	auipc	a5,0x0
 8d2:	74278793          	addi	a5,a5,1858 # 1010 <base>
 8d6:	00000717          	auipc	a4,0x0
 8da:	72f73523          	sd	a5,1834(a4) # 1000 <freep>
 8de:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e4:	b7e1                	j	8ac <malloc+0x36>
      if(p->s.size == nunits)
 8e6:	02e48c63          	beq	s1,a4,91e <malloc+0xa8>
        p->s.size -= nunits;
 8ea:	4137073b          	subw	a4,a4,s3
 8ee:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f0:	02071693          	slli	a3,a4,0x20
 8f4:	01c6d713          	srli	a4,a3,0x1c
 8f8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8fa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8fe:	00000717          	auipc	a4,0x0
 902:	70a73123          	sd	a0,1794(a4) # 1000 <freep>
      return (void*)(p + 1);
 906:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 90a:	70e2                	ld	ra,56(sp)
 90c:	7442                	ld	s0,48(sp)
 90e:	74a2                	ld	s1,40(sp)
 910:	7902                	ld	s2,32(sp)
 912:	69e2                	ld	s3,24(sp)
 914:	6a42                	ld	s4,16(sp)
 916:	6aa2                	ld	s5,8(sp)
 918:	6b02                	ld	s6,0(sp)
 91a:	6121                	addi	sp,sp,64
 91c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 91e:	6398                	ld	a4,0(a5)
 920:	e118                	sd	a4,0(a0)
 922:	bff1                	j	8fe <malloc+0x88>
  hp->s.size = nu;
 924:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 928:	0541                	addi	a0,a0,16
 92a:	ecbff0ef          	jal	ra,7f4 <free>
  return freep;
 92e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 932:	dd61                	beqz	a0,90a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 936:	4798                	lw	a4,8(a5)
 938:	fa9777e3          	bgeu	a4,s1,8e6 <malloc+0x70>
    if(p == freep)
 93c:	00093703          	ld	a4,0(s2)
 940:	853e                	mv	a0,a5
 942:	fef719e3          	bne	a4,a5,934 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 946:	8552                	mv	a0,s4
 948:	a0bff0ef          	jal	ra,352 <sbrk>
  if(p == SBRK_ERROR)
 94c:	fd551ce3          	bne	a0,s5,924 <malloc+0xae>
        return 0;
 950:	4501                	li	a0,0
 952:	bf65                	j	90a <malloc+0x94>
