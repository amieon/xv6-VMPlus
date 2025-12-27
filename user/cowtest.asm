
user/_cowtest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

int x = 1;

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  int pid = fork();
   8:	2d0000ef          	jal	ra,2d8 <fork>
  if(pid == 0){
   c:	e105                	bnez	a0,2c <main+0x2c>
    x = 2;
   e:	4789                	li	a5,2
  10:	00001717          	auipc	a4,0x1
  14:	fef72823          	sw	a5,-16(a4) # 1000 <x>
    printf("child: x=%d\n", x);
  18:	4589                	li	a1,2
  1a:	00001517          	auipc	a0,0x1
  1e:	87650513          	addi	a0,a0,-1930 # 890 <malloc+0xe0>
  22:	6da000ef          	jal	ra,6fc <printf>
    exit(0);
  26:	4501                	li	a0,0
  28:	2b8000ef          	jal	ra,2e0 <exit>
  }
  wait(0);
  2c:	4501                	li	a0,0
  2e:	2ba000ef          	jal	ra,2e8 <wait>
  printf("parent: x=%d\n", x);
  32:	00001597          	auipc	a1,0x1
  36:	fce5a583          	lw	a1,-50(a1) # 1000 <x>
  3a:	00001517          	auipc	a0,0x1
  3e:	86650513          	addi	a0,a0,-1946 # 8a0 <malloc+0xf0>
  42:	6ba000ef          	jal	ra,6fc <printf>
  exit(0);
  46:	4501                	li	a0,0
  48:	298000ef          	jal	ra,2e0 <exit>

000000000000004c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  4c:	1141                	addi	sp,sp,-16
  4e:	e406                	sd	ra,8(sp)
  50:	e022                	sd	s0,0(sp)
  52:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  54:	fadff0ef          	jal	ra,0 <main>
  exit(r);
  58:	288000ef          	jal	ra,2e0 <exit>

000000000000005c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e422                	sd	s0,8(sp)
  60:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  62:	87aa                	mv	a5,a0
  64:	0585                	addi	a1,a1,1
  66:	0785                	addi	a5,a5,1
  68:	fff5c703          	lbu	a4,-1(a1)
  6c:	fee78fa3          	sb	a4,-1(a5)
  70:	fb75                	bnez	a4,64 <strcpy+0x8>
    ;
  return os;
}
  72:	6422                	ld	s0,8(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7e:	00054783          	lbu	a5,0(a0)
  82:	cb91                	beqz	a5,96 <strcmp+0x1e>
  84:	0005c703          	lbu	a4,0(a1)
  88:	00f71763          	bne	a4,a5,96 <strcmp+0x1e>
    p++, q++;
  8c:	0505                	addi	a0,a0,1
  8e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  90:	00054783          	lbu	a5,0(a0)
  94:	fbe5                	bnez	a5,84 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  96:	0005c503          	lbu	a0,0(a1)
}
  9a:	40a7853b          	subw	a0,a5,a0
  9e:	6422                	ld	s0,8(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret

00000000000000a4 <strlen>:

uint
strlen(const char *s)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cf91                	beqz	a5,ca <strlen+0x26>
  b0:	0505                	addi	a0,a0,1
  b2:	87aa                	mv	a5,a0
  b4:	4685                	li	a3,1
  b6:	9e89                	subw	a3,a3,a0
  b8:	00f6853b          	addw	a0,a3,a5
  bc:	0785                	addi	a5,a5,1
  be:	fff7c703          	lbu	a4,-1(a5)
  c2:	fb7d                	bnez	a4,b8 <strlen+0x14>
    ;
  return n;
}
  c4:	6422                	ld	s0,8(sp)
  c6:	0141                	addi	sp,sp,16
  c8:	8082                	ret
  for(n = 0; s[n]; n++)
  ca:	4501                	li	a0,0
  cc:	bfe5                	j	c4 <strlen+0x20>

00000000000000ce <memset>:

void*
memset(void *dst, int c, uint n)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d4:	ca19                	beqz	a2,ea <memset+0x1c>
  d6:	87aa                	mv	a5,a0
  d8:	1602                	slli	a2,a2,0x20
  da:	9201                	srli	a2,a2,0x20
  dc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e4:	0785                	addi	a5,a5,1
  e6:	fee79de3          	bne	a5,a4,e0 <memset+0x12>
  }
  return dst;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strchr>:

char*
strchr(const char *s, char c)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb99                	beqz	a5,110 <strchr+0x20>
    if(*s == c)
  fc:	00f58763          	beq	a1,a5,10a <strchr+0x1a>
  for(; *s; s++)
 100:	0505                	addi	a0,a0,1
 102:	00054783          	lbu	a5,0(a0)
 106:	fbfd                	bnez	a5,fc <strchr+0xc>
      return (char*)s;
  return 0;
 108:	4501                	li	a0,0
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret
  return 0;
 110:	4501                	li	a0,0
 112:	bfe5                	j	10a <strchr+0x1a>

0000000000000114 <gets>:

char*
gets(char *buf, int max)
{
 114:	711d                	addi	sp,sp,-96
 116:	ec86                	sd	ra,88(sp)
 118:	e8a2                	sd	s0,80(sp)
 11a:	e4a6                	sd	s1,72(sp)
 11c:	e0ca                	sd	s2,64(sp)
 11e:	fc4e                	sd	s3,56(sp)
 120:	f852                	sd	s4,48(sp)
 122:	f456                	sd	s5,40(sp)
 124:	f05a                	sd	s6,32(sp)
 126:	ec5e                	sd	s7,24(sp)
 128:	1080                	addi	s0,sp,96
 12a:	8baa                	mv	s7,a0
 12c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12e:	892a                	mv	s2,a0
 130:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 132:	4aa9                	li	s5,10
 134:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 136:	89a6                	mv	s3,s1
 138:	2485                	addiw	s1,s1,1
 13a:	0344d663          	bge	s1,s4,166 <gets+0x52>
    cc = read(0, &c, 1);
 13e:	4605                	li	a2,1
 140:	faf40593          	addi	a1,s0,-81
 144:	4501                	li	a0,0
 146:	1b2000ef          	jal	ra,2f8 <read>
    if(cc < 1)
 14a:	00a05e63          	blez	a0,166 <gets+0x52>
    buf[i++] = c;
 14e:	faf44783          	lbu	a5,-81(s0)
 152:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 156:	01578763          	beq	a5,s5,164 <gets+0x50>
 15a:	0905                	addi	s2,s2,1
 15c:	fd679de3          	bne	a5,s6,136 <gets+0x22>
  for(i=0; i+1 < max; ){
 160:	89a6                	mv	s3,s1
 162:	a011                	j	166 <gets+0x52>
 164:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 166:	99de                	add	s3,s3,s7
 168:	00098023          	sb	zero,0(s3)
  return buf;
}
 16c:	855e                	mv	a0,s7
 16e:	60e6                	ld	ra,88(sp)
 170:	6446                	ld	s0,80(sp)
 172:	64a6                	ld	s1,72(sp)
 174:	6906                	ld	s2,64(sp)
 176:	79e2                	ld	s3,56(sp)
 178:	7a42                	ld	s4,48(sp)
 17a:	7aa2                	ld	s5,40(sp)
 17c:	7b02                	ld	s6,32(sp)
 17e:	6be2                	ld	s7,24(sp)
 180:	6125                	addi	sp,sp,96
 182:	8082                	ret

0000000000000184 <stat>:

int
stat(const char *n, struct stat *st)
{
 184:	1101                	addi	sp,sp,-32
 186:	ec06                	sd	ra,24(sp)
 188:	e822                	sd	s0,16(sp)
 18a:	e426                	sd	s1,8(sp)
 18c:	e04a                	sd	s2,0(sp)
 18e:	1000                	addi	s0,sp,32
 190:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 192:	4581                	li	a1,0
 194:	18c000ef          	jal	ra,320 <open>
  if(fd < 0)
 198:	02054163          	bltz	a0,1ba <stat+0x36>
 19c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 19e:	85ca                	mv	a1,s2
 1a0:	198000ef          	jal	ra,338 <fstat>
 1a4:	892a                	mv	s2,a0
  close(fd);
 1a6:	8526                	mv	a0,s1
 1a8:	160000ef          	jal	ra,308 <close>
  return r;
}
 1ac:	854a                	mv	a0,s2
 1ae:	60e2                	ld	ra,24(sp)
 1b0:	6442                	ld	s0,16(sp)
 1b2:	64a2                	ld	s1,8(sp)
 1b4:	6902                	ld	s2,0(sp)
 1b6:	6105                	addi	sp,sp,32
 1b8:	8082                	ret
    return -1;
 1ba:	597d                	li	s2,-1
 1bc:	bfc5                	j	1ac <stat+0x28>

00000000000001be <atoi>:

int
atoi(const char *s)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c4:	00054683          	lbu	a3,0(a0)
 1c8:	fd06879b          	addiw	a5,a3,-48
 1cc:	0ff7f793          	zext.b	a5,a5
 1d0:	4625                	li	a2,9
 1d2:	02f66863          	bltu	a2,a5,202 <atoi+0x44>
 1d6:	872a                	mv	a4,a0
  n = 0;
 1d8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1da:	0705                	addi	a4,a4,1
 1dc:	0025179b          	slliw	a5,a0,0x2
 1e0:	9fa9                	addw	a5,a5,a0
 1e2:	0017979b          	slliw	a5,a5,0x1
 1e6:	9fb5                	addw	a5,a5,a3
 1e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ec:	00074683          	lbu	a3,0(a4)
 1f0:	fd06879b          	addiw	a5,a3,-48
 1f4:	0ff7f793          	zext.b	a5,a5
 1f8:	fef671e3          	bgeu	a2,a5,1da <atoi+0x1c>
  return n;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
  n = 0;
 202:	4501                	li	a0,0
 204:	bfe5                	j	1fc <atoi+0x3e>

0000000000000206 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20c:	02b57463          	bgeu	a0,a1,234 <memmove+0x2e>
    while(n-- > 0)
 210:	00c05f63          	blez	a2,22e <memmove+0x28>
 214:	1602                	slli	a2,a2,0x20
 216:	9201                	srli	a2,a2,0x20
 218:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 21c:	872a                	mv	a4,a0
      *dst++ = *src++;
 21e:	0585                	addi	a1,a1,1
 220:	0705                	addi	a4,a4,1
 222:	fff5c683          	lbu	a3,-1(a1)
 226:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22a:	fee79ae3          	bne	a5,a4,21e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
    dst += n;
 234:	00c50733          	add	a4,a0,a2
    src += n;
 238:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 23a:	fec05ae3          	blez	a2,22e <memmove+0x28>
 23e:	fff6079b          	addiw	a5,a2,-1
 242:	1782                	slli	a5,a5,0x20
 244:	9381                	srli	a5,a5,0x20
 246:	fff7c793          	not	a5,a5
 24a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24c:	15fd                	addi	a1,a1,-1
 24e:	177d                	addi	a4,a4,-1
 250:	0005c683          	lbu	a3,0(a1)
 254:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 258:	fee79ae3          	bne	a5,a4,24c <memmove+0x46>
 25c:	bfc9                	j	22e <memmove+0x28>

000000000000025e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 264:	ca05                	beqz	a2,294 <memcmp+0x36>
 266:	fff6069b          	addiw	a3,a2,-1
 26a:	1682                	slli	a3,a3,0x20
 26c:	9281                	srli	a3,a3,0x20
 26e:	0685                	addi	a3,a3,1
 270:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 272:	00054783          	lbu	a5,0(a0)
 276:	0005c703          	lbu	a4,0(a1)
 27a:	00e79863          	bne	a5,a4,28a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 27e:	0505                	addi	a0,a0,1
    p2++;
 280:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 282:	fed518e3          	bne	a0,a3,272 <memcmp+0x14>
  }
  return 0;
 286:	4501                	li	a0,0
 288:	a019                	j	28e <memcmp+0x30>
      return *p1 - *p2;
 28a:	40e7853b          	subw	a0,a5,a4
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  return 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <memcmp+0x30>

0000000000000298 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e406                	sd	ra,8(sp)
 29c:	e022                	sd	s0,0(sp)
 29e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a0:	f67ff0ef          	jal	ra,206 <memmove>
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <sbrk>:

char *
sbrk(int n) {
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2b4:	4585                	li	a1,1
 2b6:	0b2000ef          	jal	ra,368 <sys_sbrk>
}
 2ba:	60a2                	ld	ra,8(sp)
 2bc:	6402                	ld	s0,0(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret

00000000000002c2 <sbrklazy>:

char *
sbrklazy(int n) {
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e406                	sd	ra,8(sp)
 2c6:	e022                	sd	s0,0(sp)
 2c8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2ca:	4589                	li	a1,2
 2cc:	09c000ef          	jal	ra,368 <sys_sbrk>
}
 2d0:	60a2                	ld	ra,8(sp)
 2d2:	6402                	ld	s0,0(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret

00000000000002d8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2d8:	4885                	li	a7,1
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e0:	4889                	li	a7,2
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2e8:	488d                	li	a7,3
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f0:	4891                	li	a7,4
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <read>:
.global read
read:
 li a7, SYS_read
 2f8:	4895                	li	a7,5
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <write>:
.global write
write:
 li a7, SYS_write
 300:	48c1                	li	a7,16
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <close>:
.global close
close:
 li a7, SYS_close
 308:	48d5                	li	a7,21
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <kill>:
.global kill
kill:
 li a7, SYS_kill
 310:	4899                	li	a7,6
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <exec>:
.global exec
exec:
 li a7, SYS_exec
 318:	489d                	li	a7,7
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <open>:
.global open
open:
 li a7, SYS_open
 320:	48bd                	li	a7,15
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 328:	48c5                	li	a7,17
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 330:	48c9                	li	a7,18
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 338:	48a1                	li	a7,8
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <link>:
.global link
link:
 li a7, SYS_link
 340:	48cd                	li	a7,19
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 348:	48d1                	li	a7,20
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 350:	48a5                	li	a7,9
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <dup>:
.global dup
dup:
 li a7, SYS_dup
 358:	48a9                	li	a7,10
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 360:	48ad                	li	a7,11
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 368:	48b1                	li	a7,12
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <pause>:
.global pause
pause:
 li a7, SYS_pause
 370:	48b5                	li	a7,13
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 378:	48b9                	li	a7,14
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 380:	1101                	addi	sp,sp,-32
 382:	ec06                	sd	ra,24(sp)
 384:	e822                	sd	s0,16(sp)
 386:	1000                	addi	s0,sp,32
 388:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38c:	4605                	li	a2,1
 38e:	fef40593          	addi	a1,s0,-17
 392:	f6fff0ef          	jal	ra,300 <write>
}
 396:	60e2                	ld	ra,24(sp)
 398:	6442                	ld	s0,16(sp)
 39a:	6105                	addi	sp,sp,32
 39c:	8082                	ret

000000000000039e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 39e:	715d                	addi	sp,sp,-80
 3a0:	e486                	sd	ra,72(sp)
 3a2:	e0a2                	sd	s0,64(sp)
 3a4:	fc26                	sd	s1,56(sp)
 3a6:	f84a                	sd	s2,48(sp)
 3a8:	f44e                	sd	s3,40(sp)
 3aa:	0880                	addi	s0,sp,80
 3ac:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ae:	c299                	beqz	a3,3b4 <printint+0x16>
 3b0:	0805c163          	bltz	a1,432 <printint+0x94>
  neg = 0;
 3b4:	4881                	li	a7,0
 3b6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ba:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3bc:	00000517          	auipc	a0,0x0
 3c0:	4fc50513          	addi	a0,a0,1276 # 8b8 <digits>
 3c4:	883e                	mv	a6,a5
 3c6:	2785                	addiw	a5,a5,1
 3c8:	02c5f733          	remu	a4,a1,a2
 3cc:	972a                	add	a4,a4,a0
 3ce:	00074703          	lbu	a4,0(a4)
 3d2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3d6:	872e                	mv	a4,a1
 3d8:	02c5d5b3          	divu	a1,a1,a2
 3dc:	0685                	addi	a3,a3,1
 3de:	fec773e3          	bgeu	a4,a2,3c4 <printint+0x26>
  if(neg)
 3e2:	00088b63          	beqz	a7,3f8 <printint+0x5a>
    buf[i++] = '-';
 3e6:	fd078793          	addi	a5,a5,-48
 3ea:	97a2                	add	a5,a5,s0
 3ec:	02d00713          	li	a4,45
 3f0:	fee78423          	sb	a4,-24(a5)
 3f4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3f8:	02f05663          	blez	a5,424 <printint+0x86>
 3fc:	fb840713          	addi	a4,s0,-72
 400:	00f704b3          	add	s1,a4,a5
 404:	fff70993          	addi	s3,a4,-1
 408:	99be                	add	s3,s3,a5
 40a:	37fd                	addiw	a5,a5,-1
 40c:	1782                	slli	a5,a5,0x20
 40e:	9381                	srli	a5,a5,0x20
 410:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 414:	fff4c583          	lbu	a1,-1(s1)
 418:	854a                	mv	a0,s2
 41a:	f67ff0ef          	jal	ra,380 <putc>
  while(--i >= 0)
 41e:	14fd                	addi	s1,s1,-1
 420:	ff349ae3          	bne	s1,s3,414 <printint+0x76>
}
 424:	60a6                	ld	ra,72(sp)
 426:	6406                	ld	s0,64(sp)
 428:	74e2                	ld	s1,56(sp)
 42a:	7942                	ld	s2,48(sp)
 42c:	79a2                	ld	s3,40(sp)
 42e:	6161                	addi	sp,sp,80
 430:	8082                	ret
    x = -xx;
 432:	40b005b3          	neg	a1,a1
    neg = 1;
 436:	4885                	li	a7,1
    x = -xx;
 438:	bfbd                	j	3b6 <printint+0x18>

000000000000043a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43a:	7119                	addi	sp,sp,-128
 43c:	fc86                	sd	ra,120(sp)
 43e:	f8a2                	sd	s0,112(sp)
 440:	f4a6                	sd	s1,104(sp)
 442:	f0ca                	sd	s2,96(sp)
 444:	ecce                	sd	s3,88(sp)
 446:	e8d2                	sd	s4,80(sp)
 448:	e4d6                	sd	s5,72(sp)
 44a:	e0da                	sd	s6,64(sp)
 44c:	fc5e                	sd	s7,56(sp)
 44e:	f862                	sd	s8,48(sp)
 450:	f466                	sd	s9,40(sp)
 452:	f06a                	sd	s10,32(sp)
 454:	ec6e                	sd	s11,24(sp)
 456:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 458:	0005c903          	lbu	s2,0(a1)
 45c:	24090c63          	beqz	s2,6b4 <vprintf+0x27a>
 460:	8b2a                	mv	s6,a0
 462:	8a2e                	mv	s4,a1
 464:	8bb2                	mv	s7,a2
  state = 0;
 466:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 468:	4481                	li	s1,0
 46a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 46c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 470:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 474:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 478:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 47c:	00000c97          	auipc	s9,0x0
 480:	43cc8c93          	addi	s9,s9,1084 # 8b8 <digits>
 484:	a005                	j	4a4 <vprintf+0x6a>
        putc(fd, c0);
 486:	85ca                	mv	a1,s2
 488:	855a                	mv	a0,s6
 48a:	ef7ff0ef          	jal	ra,380 <putc>
 48e:	a019                	j	494 <vprintf+0x5a>
    } else if(state == '%'){
 490:	03598263          	beq	s3,s5,4b4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 494:	2485                	addiw	s1,s1,1
 496:	8726                	mv	a4,s1
 498:	009a07b3          	add	a5,s4,s1
 49c:	0007c903          	lbu	s2,0(a5)
 4a0:	20090a63          	beqz	s2,6b4 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4a8:	fe0994e3          	bnez	s3,490 <vprintf+0x56>
      if(c0 == '%'){
 4ac:	fd579de3          	bne	a5,s5,486 <vprintf+0x4c>
        state = '%';
 4b0:	89be                	mv	s3,a5
 4b2:	b7cd                	j	494 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4b4:	c3c1                	beqz	a5,534 <vprintf+0xfa>
 4b6:	00ea06b3          	add	a3,s4,a4
 4ba:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4be:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4c0:	c681                	beqz	a3,4c8 <vprintf+0x8e>
 4c2:	9752                	add	a4,a4,s4
 4c4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4c8:	03878e63          	beq	a5,s8,504 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 4cc:	05a78863          	beq	a5,s10,51c <vprintf+0xe2>
      } else if(c0 == 'u'){
 4d0:	0db78b63          	beq	a5,s11,5a6 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4d4:	07800713          	li	a4,120
 4d8:	10e78d63          	beq	a5,a4,5f2 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4dc:	07000713          	li	a4,112
 4e0:	14e78263          	beq	a5,a4,624 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4e4:	06300713          	li	a4,99
 4e8:	16e78f63          	beq	a5,a4,666 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4ec:	07300713          	li	a4,115
 4f0:	18e78563          	beq	a5,a4,67a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4f4:	05579063          	bne	a5,s5,534 <vprintf+0xfa>
        putc(fd, '%');
 4f8:	85d6                	mv	a1,s5
 4fa:	855a                	mv	a0,s6
 4fc:	e85ff0ef          	jal	ra,380 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 500:	4981                	li	s3,0
 502:	bf49                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 504:	008b8913          	addi	s2,s7,8
 508:	4685                	li	a3,1
 50a:	4629                	li	a2,10
 50c:	000ba583          	lw	a1,0(s7)
 510:	855a                	mv	a0,s6
 512:	e8dff0ef          	jal	ra,39e <printint>
 516:	8bca                	mv	s7,s2
      state = 0;
 518:	4981                	li	s3,0
 51a:	bfad                	j	494 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 51c:	03868663          	beq	a3,s8,548 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 520:	05a68163          	beq	a3,s10,562 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 524:	09b68d63          	beq	a3,s11,5be <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 528:	03a68f63          	beq	a3,s10,566 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 52c:	07800793          	li	a5,120
 530:	0cf68d63          	beq	a3,a5,60a <vprintf+0x1d0>
        putc(fd, '%');
 534:	85d6                	mv	a1,s5
 536:	855a                	mv	a0,s6
 538:	e49ff0ef          	jal	ra,380 <putc>
        putc(fd, c0);
 53c:	85ca                	mv	a1,s2
 53e:	855a                	mv	a0,s6
 540:	e41ff0ef          	jal	ra,380 <putc>
      state = 0;
 544:	4981                	li	s3,0
 546:	b7b9                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 548:	008b8913          	addi	s2,s7,8
 54c:	4685                	li	a3,1
 54e:	4629                	li	a2,10
 550:	000bb583          	ld	a1,0(s7)
 554:	855a                	mv	a0,s6
 556:	e49ff0ef          	jal	ra,39e <printint>
        i += 1;
 55a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 55c:	8bca                	mv	s7,s2
      state = 0;
 55e:	4981                	li	s3,0
        i += 1;
 560:	bf15                	j	494 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 562:	03860563          	beq	a2,s8,58c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 566:	07b60963          	beq	a2,s11,5d8 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 56a:	07800793          	li	a5,120
 56e:	fcf613e3          	bne	a2,a5,534 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 572:	008b8913          	addi	s2,s7,8
 576:	4681                	li	a3,0
 578:	4641                	li	a2,16
 57a:	000bb583          	ld	a1,0(s7)
 57e:	855a                	mv	a0,s6
 580:	e1fff0ef          	jal	ra,39e <printint>
        i += 2;
 584:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
        i += 2;
 58a:	b729                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 58c:	008b8913          	addi	s2,s7,8
 590:	4685                	li	a3,1
 592:	4629                	li	a2,10
 594:	000bb583          	ld	a1,0(s7)
 598:	855a                	mv	a0,s6
 59a:	e05ff0ef          	jal	ra,39e <printint>
        i += 2;
 59e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a0:	8bca                	mv	s7,s2
      state = 0;
 5a2:	4981                	li	s3,0
        i += 2;
 5a4:	bdc5                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5a6:	008b8913          	addi	s2,s7,8
 5aa:	4681                	li	a3,0
 5ac:	4629                	li	a2,10
 5ae:	000be583          	lwu	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	debff0ef          	jal	ra,39e <printint>
 5b8:	8bca                	mv	s7,s2
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	bde1                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5be:	008b8913          	addi	s2,s7,8
 5c2:	4681                	li	a3,0
 5c4:	4629                	li	a2,10
 5c6:	000bb583          	ld	a1,0(s7)
 5ca:	855a                	mv	a0,s6
 5cc:	dd3ff0ef          	jal	ra,39e <printint>
        i += 1;
 5d0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d2:	8bca                	mv	s7,s2
      state = 0;
 5d4:	4981                	li	s3,0
        i += 1;
 5d6:	bd7d                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	4681                	li	a3,0
 5de:	4629                	li	a2,10
 5e0:	000bb583          	ld	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	db9ff0ef          	jal	ra,39e <printint>
        i += 2;
 5ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
        i += 2;
 5f0:	b555                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4681                	li	a3,0
 5f8:	4641                	li	a2,16
 5fa:	000be583          	lwu	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	d9fff0ef          	jal	ra,39e <printint>
 604:	8bca                	mv	s7,s2
      state = 0;
 606:	4981                	li	s3,0
 608:	b571                	j	494 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 60a:	008b8913          	addi	s2,s7,8
 60e:	4681                	li	a3,0
 610:	4641                	li	a2,16
 612:	000bb583          	ld	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	d87ff0ef          	jal	ra,39e <printint>
        i += 1;
 61c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
        i += 1;
 622:	bd8d                	j	494 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 624:	008b8793          	addi	a5,s7,8
 628:	f8f43423          	sd	a5,-120(s0)
 62c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 630:	03000593          	li	a1,48
 634:	855a                	mv	a0,s6
 636:	d4bff0ef          	jal	ra,380 <putc>
  putc(fd, 'x');
 63a:	07800593          	li	a1,120
 63e:	855a                	mv	a0,s6
 640:	d41ff0ef          	jal	ra,380 <putc>
 644:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 646:	03c9d793          	srli	a5,s3,0x3c
 64a:	97e6                	add	a5,a5,s9
 64c:	0007c583          	lbu	a1,0(a5)
 650:	855a                	mv	a0,s6
 652:	d2fff0ef          	jal	ra,380 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 656:	0992                	slli	s3,s3,0x4
 658:	397d                	addiw	s2,s2,-1
 65a:	fe0916e3          	bnez	s2,646 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 65e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 662:	4981                	li	s3,0
 664:	bd05                	j	494 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 666:	008b8913          	addi	s2,s7,8
 66a:	000bc583          	lbu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	d11ff0ef          	jal	ra,380 <putc>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	bd31                	j	494 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 67a:	008b8993          	addi	s3,s7,8
 67e:	000bb903          	ld	s2,0(s7)
 682:	00090f63          	beqz	s2,6a0 <vprintf+0x266>
        for(; *s; s++)
 686:	00094583          	lbu	a1,0(s2)
 68a:	c195                	beqz	a1,6ae <vprintf+0x274>
          putc(fd, *s);
 68c:	855a                	mv	a0,s6
 68e:	cf3ff0ef          	jal	ra,380 <putc>
        for(; *s; s++)
 692:	0905                	addi	s2,s2,1
 694:	00094583          	lbu	a1,0(s2)
 698:	f9f5                	bnez	a1,68c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 69a:	8bce                	mv	s7,s3
      state = 0;
 69c:	4981                	li	s3,0
 69e:	bbdd                	j	494 <vprintf+0x5a>
          s = "(null)";
 6a0:	00000917          	auipc	s2,0x0
 6a4:	21090913          	addi	s2,s2,528 # 8b0 <malloc+0x100>
        for(; *s; s++)
 6a8:	02800593          	li	a1,40
 6ac:	b7c5                	j	68c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6ae:	8bce                	mv	s7,s3
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b3cd                	j	494 <vprintf+0x5a>
    }
  }
}
 6b4:	70e6                	ld	ra,120(sp)
 6b6:	7446                	ld	s0,112(sp)
 6b8:	74a6                	ld	s1,104(sp)
 6ba:	7906                	ld	s2,96(sp)
 6bc:	69e6                	ld	s3,88(sp)
 6be:	6a46                	ld	s4,80(sp)
 6c0:	6aa6                	ld	s5,72(sp)
 6c2:	6b06                	ld	s6,64(sp)
 6c4:	7be2                	ld	s7,56(sp)
 6c6:	7c42                	ld	s8,48(sp)
 6c8:	7ca2                	ld	s9,40(sp)
 6ca:	7d02                	ld	s10,32(sp)
 6cc:	6de2                	ld	s11,24(sp)
 6ce:	6109                	addi	sp,sp,128
 6d0:	8082                	ret

00000000000006d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d2:	715d                	addi	sp,sp,-80
 6d4:	ec06                	sd	ra,24(sp)
 6d6:	e822                	sd	s0,16(sp)
 6d8:	1000                	addi	s0,sp,32
 6da:	e010                	sd	a2,0(s0)
 6dc:	e414                	sd	a3,8(s0)
 6de:	e818                	sd	a4,16(s0)
 6e0:	ec1c                	sd	a5,24(s0)
 6e2:	03043023          	sd	a6,32(s0)
 6e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ee:	8622                	mv	a2,s0
 6f0:	d4bff0ef          	jal	ra,43a <vprintf>
}
 6f4:	60e2                	ld	ra,24(sp)
 6f6:	6442                	ld	s0,16(sp)
 6f8:	6161                	addi	sp,sp,80
 6fa:	8082                	ret

00000000000006fc <printf>:

void
printf(const char *fmt, ...)
{
 6fc:	711d                	addi	sp,sp,-96
 6fe:	ec06                	sd	ra,24(sp)
 700:	e822                	sd	s0,16(sp)
 702:	1000                	addi	s0,sp,32
 704:	e40c                	sd	a1,8(s0)
 706:	e810                	sd	a2,16(s0)
 708:	ec14                	sd	a3,24(s0)
 70a:	f018                	sd	a4,32(s0)
 70c:	f41c                	sd	a5,40(s0)
 70e:	03043823          	sd	a6,48(s0)
 712:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 716:	00840613          	addi	a2,s0,8
 71a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 71e:	85aa                	mv	a1,a0
 720:	4505                	li	a0,1
 722:	d19ff0ef          	jal	ra,43a <vprintf>
}
 726:	60e2                	ld	ra,24(sp)
 728:	6442                	ld	s0,16(sp)
 72a:	6125                	addi	sp,sp,96
 72c:	8082                	ret

000000000000072e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 72e:	1141                	addi	sp,sp,-16
 730:	e422                	sd	s0,8(sp)
 732:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 734:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 738:	00001797          	auipc	a5,0x1
 73c:	8d87b783          	ld	a5,-1832(a5) # 1010 <freep>
 740:	a02d                	j	76a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 742:	4618                	lw	a4,8(a2)
 744:	9f2d                	addw	a4,a4,a1
 746:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 74a:	6398                	ld	a4,0(a5)
 74c:	6310                	ld	a2,0(a4)
 74e:	a83d                	j	78c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 750:	ff852703          	lw	a4,-8(a0)
 754:	9f31                	addw	a4,a4,a2
 756:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 758:	ff053683          	ld	a3,-16(a0)
 75c:	a091                	j	7a0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75e:	6398                	ld	a4,0(a5)
 760:	00e7e463          	bltu	a5,a4,768 <free+0x3a>
 764:	00e6ea63          	bltu	a3,a4,778 <free+0x4a>
{
 768:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76a:	fed7fae3          	bgeu	a5,a3,75e <free+0x30>
 76e:	6398                	ld	a4,0(a5)
 770:	00e6e463          	bltu	a3,a4,778 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 774:	fee7eae3          	bltu	a5,a4,768 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 778:	ff852583          	lw	a1,-8(a0)
 77c:	6390                	ld	a2,0(a5)
 77e:	02059813          	slli	a6,a1,0x20
 782:	01c85713          	srli	a4,a6,0x1c
 786:	9736                	add	a4,a4,a3
 788:	fae60de3          	beq	a2,a4,742 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 78c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 790:	4790                	lw	a2,8(a5)
 792:	02061593          	slli	a1,a2,0x20
 796:	01c5d713          	srli	a4,a1,0x1c
 79a:	973e                	add	a4,a4,a5
 79c:	fae68ae3          	beq	a3,a4,750 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7a0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7a2:	00001717          	auipc	a4,0x1
 7a6:	86f73723          	sd	a5,-1938(a4) # 1010 <freep>
}
 7aa:	6422                	ld	s0,8(sp)
 7ac:	0141                	addi	sp,sp,16
 7ae:	8082                	ret

00000000000007b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b0:	7139                	addi	sp,sp,-64
 7b2:	fc06                	sd	ra,56(sp)
 7b4:	f822                	sd	s0,48(sp)
 7b6:	f426                	sd	s1,40(sp)
 7b8:	f04a                	sd	s2,32(sp)
 7ba:	ec4e                	sd	s3,24(sp)
 7bc:	e852                	sd	s4,16(sp)
 7be:	e456                	sd	s5,8(sp)
 7c0:	e05a                	sd	s6,0(sp)
 7c2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c4:	02051493          	slli	s1,a0,0x20
 7c8:	9081                	srli	s1,s1,0x20
 7ca:	04bd                	addi	s1,s1,15
 7cc:	8091                	srli	s1,s1,0x4
 7ce:	0014899b          	addiw	s3,s1,1
 7d2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7d4:	00001517          	auipc	a0,0x1
 7d8:	83c53503          	ld	a0,-1988(a0) # 1010 <freep>
 7dc:	c515                	beqz	a0,808 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e0:	4798                	lw	a4,8(a5)
 7e2:	02977f63          	bgeu	a4,s1,820 <malloc+0x70>
 7e6:	8a4e                	mv	s4,s3
 7e8:	0009871b          	sext.w	a4,s3
 7ec:	6685                	lui	a3,0x1
 7ee:	00d77363          	bgeu	a4,a3,7f4 <malloc+0x44>
 7f2:	6a05                	lui	s4,0x1
 7f4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7fc:	00001917          	auipc	s2,0x1
 800:	81490913          	addi	s2,s2,-2028 # 1010 <freep>
  if(p == SBRK_ERROR)
 804:	5afd                	li	s5,-1
 806:	a885                	j	876 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 808:	00001797          	auipc	a5,0x1
 80c:	81878793          	addi	a5,a5,-2024 # 1020 <base>
 810:	00001717          	auipc	a4,0x1
 814:	80f73023          	sd	a5,-2048(a4) # 1010 <freep>
 818:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 81a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 81e:	b7e1                	j	7e6 <malloc+0x36>
      if(p->s.size == nunits)
 820:	02e48c63          	beq	s1,a4,858 <malloc+0xa8>
        p->s.size -= nunits;
 824:	4137073b          	subw	a4,a4,s3
 828:	c798                	sw	a4,8(a5)
        p += p->s.size;
 82a:	02071693          	slli	a3,a4,0x20
 82e:	01c6d713          	srli	a4,a3,0x1c
 832:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 834:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 838:	00000717          	auipc	a4,0x0
 83c:	7ca73c23          	sd	a0,2008(a4) # 1010 <freep>
      return (void*)(p + 1);
 840:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 844:	70e2                	ld	ra,56(sp)
 846:	7442                	ld	s0,48(sp)
 848:	74a2                	ld	s1,40(sp)
 84a:	7902                	ld	s2,32(sp)
 84c:	69e2                	ld	s3,24(sp)
 84e:	6a42                	ld	s4,16(sp)
 850:	6aa2                	ld	s5,8(sp)
 852:	6b02                	ld	s6,0(sp)
 854:	6121                	addi	sp,sp,64
 856:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 858:	6398                	ld	a4,0(a5)
 85a:	e118                	sd	a4,0(a0)
 85c:	bff1                	j	838 <malloc+0x88>
  hp->s.size = nu;
 85e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 862:	0541                	addi	a0,a0,16
 864:	ecbff0ef          	jal	ra,72e <free>
  return freep;
 868:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 86c:	dd61                	beqz	a0,844 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 870:	4798                	lw	a4,8(a5)
 872:	fa9777e3          	bgeu	a4,s1,820 <malloc+0x70>
    if(p == freep)
 876:	00093703          	ld	a4,0(s2)
 87a:	853e                	mv	a0,a5
 87c:	fef719e3          	bne	a4,a5,86e <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 880:	8552                	mv	a0,s4
 882:	a2bff0ef          	jal	ra,2ac <sbrk>
  if(p == SBRK_ERROR)
 886:	fd551ce3          	bne	a0,s5,85e <malloc+0xae>
        return 0;
 88a:	4501                	li	a0,0
 88c:	bf65                	j	844 <malloc+0x94>
