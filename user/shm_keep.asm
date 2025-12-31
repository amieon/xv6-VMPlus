
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
  32:	95250513          	addi	a0,a0,-1710 # 980 <malloc+0xf2>
  36:	7a4000ef          	jal	ra,7da <printf>
    sleep(50);
  3a:	03200513          	li	a0,50
  3e:	400000ef          	jal	ra,43e <sleep>
    printf("child still sees %d\n", p[0]);
  42:	0004c583          	lbu	a1,0(s1)
  46:	00001517          	auipc	a0,0x1
  4a:	94a50513          	addi	a0,a0,-1718 # 990 <malloc+0x102>
  4e:	78c000ef          	jal	ra,7da <printf>
    munmap(p, 4096);
  52:	6585                	lui	a1,0x1
  54:	8526                	mv	a0,s1
  56:	3d8000ef          	jal	ra,42e <munmap>
    exit(0);
  5a:	4501                	li	a0,0
  5c:	32a000ef          	jal	ra,386 <exit>
    printf("mmap fail\n");
  60:	00001517          	auipc	a0,0x1
  64:	91050513          	addi	a0,a0,-1776 # 970 <malloc+0xe2>
  68:	772000ef          	jal	ra,7da <printf>
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
  80:	92c50513          	addi	a0,a0,-1748 # 9a8 <malloc+0x11a>
  84:	756000ef          	jal	ra,7da <printf>

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
  b2:	94250513          	addi	a0,a0,-1726 # 9f0 <malloc+0x162>
  b6:	724000ef          	jal	ra,7da <printf>

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
  d2:	8fa50513          	addi	a0,a0,-1798 # 9c8 <malloc+0x13a>
  d6:	704000ef          	jal	ra,7da <printf>
    exit(1);
  da:	4505                	li	a0,1
  dc:	2aa000ef          	jal	ra,386 <exit>
    printf("remap fail\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	90050513          	addi	a0,a0,-1792 # 9e0 <malloc+0x152>
  e8:	6f2000ef          	jal	ra,7da <printf>
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

0000000000000446 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 446:	48e9                	li	a7,26
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 44e:	48ed                	li	a7,27
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 456:	48f1                	li	a7,28
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45e:	1101                	addi	sp,sp,-32
 460:	ec06                	sd	ra,24(sp)
 462:	e822                	sd	s0,16(sp)
 464:	1000                	addi	s0,sp,32
 466:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 46a:	4605                	li	a2,1
 46c:	fef40593          	addi	a1,s0,-17
 470:	f37ff0ef          	jal	ra,3a6 <write>
}
 474:	60e2                	ld	ra,24(sp)
 476:	6442                	ld	s0,16(sp)
 478:	6105                	addi	sp,sp,32
 47a:	8082                	ret

000000000000047c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 47c:	715d                	addi	sp,sp,-80
 47e:	e486                	sd	ra,72(sp)
 480:	e0a2                	sd	s0,64(sp)
 482:	fc26                	sd	s1,56(sp)
 484:	f84a                	sd	s2,48(sp)
 486:	f44e                	sd	s3,40(sp)
 488:	0880                	addi	s0,sp,80
 48a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 48c:	c299                	beqz	a3,492 <printint+0x16>
 48e:	0805c163          	bltz	a1,510 <printint+0x94>
  neg = 0;
 492:	4881                	li	a7,0
 494:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 498:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 49a:	00000517          	auipc	a0,0x0
 49e:	57e50513          	addi	a0,a0,1406 # a18 <digits>
 4a2:	883e                	mv	a6,a5
 4a4:	2785                	addiw	a5,a5,1
 4a6:	02c5f733          	remu	a4,a1,a2
 4aa:	972a                	add	a4,a4,a0
 4ac:	00074703          	lbu	a4,0(a4)
 4b0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4b4:	872e                	mv	a4,a1
 4b6:	02c5d5b3          	divu	a1,a1,a2
 4ba:	0685                	addi	a3,a3,1
 4bc:	fec773e3          	bgeu	a4,a2,4a2 <printint+0x26>
  if(neg)
 4c0:	00088b63          	beqz	a7,4d6 <printint+0x5a>
    buf[i++] = '-';
 4c4:	fd078793          	addi	a5,a5,-48
 4c8:	97a2                	add	a5,a5,s0
 4ca:	02d00713          	li	a4,45
 4ce:	fee78423          	sb	a4,-24(a5)
 4d2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4d6:	02f05663          	blez	a5,502 <printint+0x86>
 4da:	fb840713          	addi	a4,s0,-72
 4de:	00f704b3          	add	s1,a4,a5
 4e2:	fff70993          	addi	s3,a4,-1
 4e6:	99be                	add	s3,s3,a5
 4e8:	37fd                	addiw	a5,a5,-1
 4ea:	1782                	slli	a5,a5,0x20
 4ec:	9381                	srli	a5,a5,0x20
 4ee:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4f2:	fff4c583          	lbu	a1,-1(s1)
 4f6:	854a                	mv	a0,s2
 4f8:	f67ff0ef          	jal	ra,45e <putc>
  while(--i >= 0)
 4fc:	14fd                	addi	s1,s1,-1
 4fe:	ff349ae3          	bne	s1,s3,4f2 <printint+0x76>
}
 502:	60a6                	ld	ra,72(sp)
 504:	6406                	ld	s0,64(sp)
 506:	74e2                	ld	s1,56(sp)
 508:	7942                	ld	s2,48(sp)
 50a:	79a2                	ld	s3,40(sp)
 50c:	6161                	addi	sp,sp,80
 50e:	8082                	ret
    x = -xx;
 510:	40b005b3          	neg	a1,a1
    neg = 1;
 514:	4885                	li	a7,1
    x = -xx;
 516:	bfbd                	j	494 <printint+0x18>

0000000000000518 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 518:	7119                	addi	sp,sp,-128
 51a:	fc86                	sd	ra,120(sp)
 51c:	f8a2                	sd	s0,112(sp)
 51e:	f4a6                	sd	s1,104(sp)
 520:	f0ca                	sd	s2,96(sp)
 522:	ecce                	sd	s3,88(sp)
 524:	e8d2                	sd	s4,80(sp)
 526:	e4d6                	sd	s5,72(sp)
 528:	e0da                	sd	s6,64(sp)
 52a:	fc5e                	sd	s7,56(sp)
 52c:	f862                	sd	s8,48(sp)
 52e:	f466                	sd	s9,40(sp)
 530:	f06a                	sd	s10,32(sp)
 532:	ec6e                	sd	s11,24(sp)
 534:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 536:	0005c903          	lbu	s2,0(a1)
 53a:	24090c63          	beqz	s2,792 <vprintf+0x27a>
 53e:	8b2a                	mv	s6,a0
 540:	8a2e                	mv	s4,a1
 542:	8bb2                	mv	s7,a2
  state = 0;
 544:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 546:	4481                	li	s1,0
 548:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 54a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 54e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 552:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 556:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 55a:	00000c97          	auipc	s9,0x0
 55e:	4bec8c93          	addi	s9,s9,1214 # a18 <digits>
 562:	a005                	j	582 <vprintf+0x6a>
        putc(fd, c0);
 564:	85ca                	mv	a1,s2
 566:	855a                	mv	a0,s6
 568:	ef7ff0ef          	jal	ra,45e <putc>
 56c:	a019                	j	572 <vprintf+0x5a>
    } else if(state == '%'){
 56e:	03598263          	beq	s3,s5,592 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 572:	2485                	addiw	s1,s1,1
 574:	8726                	mv	a4,s1
 576:	009a07b3          	add	a5,s4,s1
 57a:	0007c903          	lbu	s2,0(a5)
 57e:	20090a63          	beqz	s2,792 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 582:	0009079b          	sext.w	a5,s2
    if(state == 0){
 586:	fe0994e3          	bnez	s3,56e <vprintf+0x56>
      if(c0 == '%'){
 58a:	fd579de3          	bne	a5,s5,564 <vprintf+0x4c>
        state = '%';
 58e:	89be                	mv	s3,a5
 590:	b7cd                	j	572 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 592:	c3c1                	beqz	a5,612 <vprintf+0xfa>
 594:	00ea06b3          	add	a3,s4,a4
 598:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 59c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 59e:	c681                	beqz	a3,5a6 <vprintf+0x8e>
 5a0:	9752                	add	a4,a4,s4
 5a2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5a6:	03878e63          	beq	a5,s8,5e2 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5aa:	05a78863          	beq	a5,s10,5fa <vprintf+0xe2>
      } else if(c0 == 'u'){
 5ae:	0db78b63          	beq	a5,s11,684 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5b2:	07800713          	li	a4,120
 5b6:	10e78d63          	beq	a5,a4,6d0 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ba:	07000713          	li	a4,112
 5be:	14e78263          	beq	a5,a4,702 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5c2:	06300713          	li	a4,99
 5c6:	16e78f63          	beq	a5,a4,744 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5ca:	07300713          	li	a4,115
 5ce:	18e78563          	beq	a5,a4,758 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5d2:	05579063          	bne	a5,s5,612 <vprintf+0xfa>
        putc(fd, '%');
 5d6:	85d6                	mv	a1,s5
 5d8:	855a                	mv	a0,s6
 5da:	e85ff0ef          	jal	ra,45e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bf49                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4685                	li	a3,1
 5e8:	4629                	li	a2,10
 5ea:	000ba583          	lw	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	e8dff0ef          	jal	ra,47c <printint>
 5f4:	8bca                	mv	s7,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bfad                	j	572 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5fa:	03868663          	beq	a3,s8,626 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fe:	05a68163          	beq	a3,s10,640 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 602:	09b68d63          	beq	a3,s11,69c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 606:	03a68f63          	beq	a3,s10,644 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 60a:	07800793          	li	a5,120
 60e:	0cf68d63          	beq	a3,a5,6e8 <vprintf+0x1d0>
        putc(fd, '%');
 612:	85d6                	mv	a1,s5
 614:	855a                	mv	a0,s6
 616:	e49ff0ef          	jal	ra,45e <putc>
        putc(fd, c0);
 61a:	85ca                	mv	a1,s2
 61c:	855a                	mv	a0,s6
 61e:	e41ff0ef          	jal	ra,45e <putc>
      state = 0;
 622:	4981                	li	s3,0
 624:	b7b9                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	008b8913          	addi	s2,s7,8
 62a:	4685                	li	a3,1
 62c:	4629                	li	a2,10
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	e49ff0ef          	jal	ra,47c <printint>
        i += 1;
 638:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
        i += 1;
 63e:	bf15                	j	572 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 640:	03860563          	beq	a2,s8,66a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 644:	07b60963          	beq	a2,s11,6b6 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 648:	07800793          	li	a5,120
 64c:	fcf613e3          	bne	a2,a5,612 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	008b8913          	addi	s2,s7,8
 654:	4681                	li	a3,0
 656:	4641                	li	a2,16
 658:	000bb583          	ld	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	e1fff0ef          	jal	ra,47c <printint>
        i += 2;
 662:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
        i += 2;
 668:	b729                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4685                	li	a3,1
 670:	4629                	li	a2,10
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	e05ff0ef          	jal	ra,47c <printint>
        i += 2;
 67c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 2;
 682:	bdc5                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 684:	008b8913          	addi	s2,s7,8
 688:	4681                	li	a3,0
 68a:	4629                	li	a2,10
 68c:	000be583          	lwu	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	debff0ef          	jal	ra,47c <printint>
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bde1                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69c:	008b8913          	addi	s2,s7,8
 6a0:	4681                	li	a3,0
 6a2:	4629                	li	a2,10
 6a4:	000bb583          	ld	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	dd3ff0ef          	jal	ra,47c <printint>
        i += 1;
 6ae:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
        i += 1;
 6b4:	bd7d                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4629                	li	a2,10
 6be:	000bb583          	ld	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	db9ff0ef          	jal	ra,47c <printint>
        i += 2;
 6c8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
        i += 2;
 6ce:	b555                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	4681                	li	a3,0
 6d6:	4641                	li	a2,16
 6d8:	000be583          	lwu	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	d9fff0ef          	jal	ra,47c <printint>
 6e2:	8bca                	mv	s7,s2
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b571                	j	572 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e8:	008b8913          	addi	s2,s7,8
 6ec:	4681                	li	a3,0
 6ee:	4641                	li	a2,16
 6f0:	000bb583          	ld	a1,0(s7)
 6f4:	855a                	mv	a0,s6
 6f6:	d87ff0ef          	jal	ra,47c <printint>
        i += 1;
 6fa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
        i += 1;
 700:	bd8d                	j	572 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 702:	008b8793          	addi	a5,s7,8
 706:	f8f43423          	sd	a5,-120(s0)
 70a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 70e:	03000593          	li	a1,48
 712:	855a                	mv	a0,s6
 714:	d4bff0ef          	jal	ra,45e <putc>
  putc(fd, 'x');
 718:	07800593          	li	a1,120
 71c:	855a                	mv	a0,s6
 71e:	d41ff0ef          	jal	ra,45e <putc>
 722:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 724:	03c9d793          	srli	a5,s3,0x3c
 728:	97e6                	add	a5,a5,s9
 72a:	0007c583          	lbu	a1,0(a5)
 72e:	855a                	mv	a0,s6
 730:	d2fff0ef          	jal	ra,45e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 734:	0992                	slli	s3,s3,0x4
 736:	397d                	addiw	s2,s2,-1
 738:	fe0916e3          	bnez	s2,724 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 73c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 740:	4981                	li	s3,0
 742:	bd05                	j	572 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 744:	008b8913          	addi	s2,s7,8
 748:	000bc583          	lbu	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	d11ff0ef          	jal	ra,45e <putc>
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	bd31                	j	572 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 758:	008b8993          	addi	s3,s7,8
 75c:	000bb903          	ld	s2,0(s7)
 760:	00090f63          	beqz	s2,77e <vprintf+0x266>
        for(; *s; s++)
 764:	00094583          	lbu	a1,0(s2)
 768:	c195                	beqz	a1,78c <vprintf+0x274>
          putc(fd, *s);
 76a:	855a                	mv	a0,s6
 76c:	cf3ff0ef          	jal	ra,45e <putc>
        for(; *s; s++)
 770:	0905                	addi	s2,s2,1
 772:	00094583          	lbu	a1,0(s2)
 776:	f9f5                	bnez	a1,76a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 778:	8bce                	mv	s7,s3
      state = 0;
 77a:	4981                	li	s3,0
 77c:	bbdd                	j	572 <vprintf+0x5a>
          s = "(null)";
 77e:	00000917          	auipc	s2,0x0
 782:	29290913          	addi	s2,s2,658 # a10 <malloc+0x182>
        for(; *s; s++)
 786:	02800593          	li	a1,40
 78a:	b7c5                	j	76a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 78c:	8bce                	mv	s7,s3
      state = 0;
 78e:	4981                	li	s3,0
 790:	b3cd                	j	572 <vprintf+0x5a>
    }
  }
}
 792:	70e6                	ld	ra,120(sp)
 794:	7446                	ld	s0,112(sp)
 796:	74a6                	ld	s1,104(sp)
 798:	7906                	ld	s2,96(sp)
 79a:	69e6                	ld	s3,88(sp)
 79c:	6a46                	ld	s4,80(sp)
 79e:	6aa6                	ld	s5,72(sp)
 7a0:	6b06                	ld	s6,64(sp)
 7a2:	7be2                	ld	s7,56(sp)
 7a4:	7c42                	ld	s8,48(sp)
 7a6:	7ca2                	ld	s9,40(sp)
 7a8:	7d02                	ld	s10,32(sp)
 7aa:	6de2                	ld	s11,24(sp)
 7ac:	6109                	addi	sp,sp,128
 7ae:	8082                	ret

00000000000007b0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b0:	715d                	addi	sp,sp,-80
 7b2:	ec06                	sd	ra,24(sp)
 7b4:	e822                	sd	s0,16(sp)
 7b6:	1000                	addi	s0,sp,32
 7b8:	e010                	sd	a2,0(s0)
 7ba:	e414                	sd	a3,8(s0)
 7bc:	e818                	sd	a4,16(s0)
 7be:	ec1c                	sd	a5,24(s0)
 7c0:	03043023          	sd	a6,32(s0)
 7c4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7cc:	8622                	mv	a2,s0
 7ce:	d4bff0ef          	jal	ra,518 <vprintf>
}
 7d2:	60e2                	ld	ra,24(sp)
 7d4:	6442                	ld	s0,16(sp)
 7d6:	6161                	addi	sp,sp,80
 7d8:	8082                	ret

00000000000007da <printf>:

void
printf(const char *fmt, ...)
{
 7da:	711d                	addi	sp,sp,-96
 7dc:	ec06                	sd	ra,24(sp)
 7de:	e822                	sd	s0,16(sp)
 7e0:	1000                	addi	s0,sp,32
 7e2:	e40c                	sd	a1,8(s0)
 7e4:	e810                	sd	a2,16(s0)
 7e6:	ec14                	sd	a3,24(s0)
 7e8:	f018                	sd	a4,32(s0)
 7ea:	f41c                	sd	a5,40(s0)
 7ec:	03043823          	sd	a6,48(s0)
 7f0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f4:	00840613          	addi	a2,s0,8
 7f8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fc:	85aa                	mv	a1,a0
 7fe:	4505                	li	a0,1
 800:	d19ff0ef          	jal	ra,518 <vprintf>
}
 804:	60e2                	ld	ra,24(sp)
 806:	6442                	ld	s0,16(sp)
 808:	6125                	addi	sp,sp,96
 80a:	8082                	ret

000000000000080c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80c:	1141                	addi	sp,sp,-16
 80e:	e422                	sd	s0,8(sp)
 810:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 812:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 816:	00000797          	auipc	a5,0x0
 81a:	7ea7b783          	ld	a5,2026(a5) # 1000 <freep>
 81e:	a02d                	j	848 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 820:	4618                	lw	a4,8(a2)
 822:	9f2d                	addw	a4,a4,a1
 824:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 828:	6398                	ld	a4,0(a5)
 82a:	6310                	ld	a2,0(a4)
 82c:	a83d                	j	86a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 82e:	ff852703          	lw	a4,-8(a0)
 832:	9f31                	addw	a4,a4,a2
 834:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 836:	ff053683          	ld	a3,-16(a0)
 83a:	a091                	j	87e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83c:	6398                	ld	a4,0(a5)
 83e:	00e7e463          	bltu	a5,a4,846 <free+0x3a>
 842:	00e6ea63          	bltu	a3,a4,856 <free+0x4a>
{
 846:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	fed7fae3          	bgeu	a5,a3,83c <free+0x30>
 84c:	6398                	ld	a4,0(a5)
 84e:	00e6e463          	bltu	a3,a4,856 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 852:	fee7eae3          	bltu	a5,a4,846 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 856:	ff852583          	lw	a1,-8(a0)
 85a:	6390                	ld	a2,0(a5)
 85c:	02059813          	slli	a6,a1,0x20
 860:	01c85713          	srli	a4,a6,0x1c
 864:	9736                	add	a4,a4,a3
 866:	fae60de3          	beq	a2,a4,820 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 86a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 86e:	4790                	lw	a2,8(a5)
 870:	02061593          	slli	a1,a2,0x20
 874:	01c5d713          	srli	a4,a1,0x1c
 878:	973e                	add	a4,a4,a5
 87a:	fae68ae3          	beq	a3,a4,82e <free+0x22>
    p->s.ptr = bp->s.ptr;
 87e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 880:	00000717          	auipc	a4,0x0
 884:	78f73023          	sd	a5,1920(a4) # 1000 <freep>
}
 888:	6422                	ld	s0,8(sp)
 88a:	0141                	addi	sp,sp,16
 88c:	8082                	ret

000000000000088e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 88e:	7139                	addi	sp,sp,-64
 890:	fc06                	sd	ra,56(sp)
 892:	f822                	sd	s0,48(sp)
 894:	f426                	sd	s1,40(sp)
 896:	f04a                	sd	s2,32(sp)
 898:	ec4e                	sd	s3,24(sp)
 89a:	e852                	sd	s4,16(sp)
 89c:	e456                	sd	s5,8(sp)
 89e:	e05a                	sd	s6,0(sp)
 8a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a2:	02051493          	slli	s1,a0,0x20
 8a6:	9081                	srli	s1,s1,0x20
 8a8:	04bd                	addi	s1,s1,15
 8aa:	8091                	srli	s1,s1,0x4
 8ac:	0014899b          	addiw	s3,s1,1
 8b0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b2:	00000517          	auipc	a0,0x0
 8b6:	74e53503          	ld	a0,1870(a0) # 1000 <freep>
 8ba:	c515                	beqz	a0,8e6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	02977f63          	bgeu	a4,s1,8fe <malloc+0x70>
 8c4:	8a4e                	mv	s4,s3
 8c6:	0009871b          	sext.w	a4,s3
 8ca:	6685                	lui	a3,0x1
 8cc:	00d77363          	bgeu	a4,a3,8d2 <malloc+0x44>
 8d0:	6a05                	lui	s4,0x1
 8d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8da:	00000917          	auipc	s2,0x0
 8de:	72690913          	addi	s2,s2,1830 # 1000 <freep>
  if(p == SBRK_ERROR)
 8e2:	5afd                	li	s5,-1
 8e4:	a885                	j	954 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8e6:	00000797          	auipc	a5,0x0
 8ea:	72a78793          	addi	a5,a5,1834 # 1010 <base>
 8ee:	00000717          	auipc	a4,0x0
 8f2:	70f73923          	sd	a5,1810(a4) # 1000 <freep>
 8f6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8fc:	b7e1                	j	8c4 <malloc+0x36>
      if(p->s.size == nunits)
 8fe:	02e48c63          	beq	s1,a4,936 <malloc+0xa8>
        p->s.size -= nunits;
 902:	4137073b          	subw	a4,a4,s3
 906:	c798                	sw	a4,8(a5)
        p += p->s.size;
 908:	02071693          	slli	a3,a4,0x20
 90c:	01c6d713          	srli	a4,a3,0x1c
 910:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 912:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 916:	00000717          	auipc	a4,0x0
 91a:	6ea73523          	sd	a0,1770(a4) # 1000 <freep>
      return (void*)(p + 1);
 91e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 922:	70e2                	ld	ra,56(sp)
 924:	7442                	ld	s0,48(sp)
 926:	74a2                	ld	s1,40(sp)
 928:	7902                	ld	s2,32(sp)
 92a:	69e2                	ld	s3,24(sp)
 92c:	6a42                	ld	s4,16(sp)
 92e:	6aa2                	ld	s5,8(sp)
 930:	6b02                	ld	s6,0(sp)
 932:	6121                	addi	sp,sp,64
 934:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 936:	6398                	ld	a4,0(a5)
 938:	e118                	sd	a4,0(a0)
 93a:	bff1                	j	916 <malloc+0x88>
  hp->s.size = nu;
 93c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 940:	0541                	addi	a0,a0,16
 942:	ecbff0ef          	jal	ra,80c <free>
  return freep;
 946:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 94a:	dd61                	beqz	a0,922 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94e:	4798                	lw	a4,8(a5)
 950:	fa9777e3          	bgeu	a4,s1,8fe <malloc+0x70>
    if(p == freep)
 954:	00093703          	ld	a4,0(s2)
 958:	853e                	mv	a0,a5
 95a:	fef719e3          	bne	a4,a5,94c <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 95e:	8552                	mv	a0,s4
 960:	9f3ff0ef          	jal	ra,352 <sbrk>
  if(p == SBRK_ERROR)
 964:	fd551ce3          	bne	a0,s5,93c <malloc+0xae>
        return 0;
 968:	4501                	li	a0,0
 96a:	bf65                	j	922 <malloc+0x94>
