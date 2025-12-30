
user/_mmap_ro_kill：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"


int main(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *p = mmap(0, 4096, PROT_READ, MAP_ANON, 1);
   a:	4705                	li	a4,1
   c:	4685                	li	a3,1
   e:	4605                	li	a2,1
  10:	6585                	lui	a1,0x1
  12:	4501                	li	a0,0
  14:	35e000ef          	jal	ra,372 <mmap>
  18:	84aa                	mv	s1,a0
  printf("about to write (should die)\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	87650513          	addi	a0,a0,-1930 # 890 <malloc+0xde>
  22:	6dc000ef          	jal	ra,6fe <printf>
  p[0] = 1; // 应该被 kill
  26:	4785                	li	a5,1
  28:	00f48023          	sb	a5,0(s1)
  printf("FAIL: still alive\n");
  2c:	00001517          	auipc	a0,0x1
  30:	88450513          	addi	a0,a0,-1916 # 8b0 <malloc+0xfe>
  34:	6ca000ef          	jal	ra,6fe <printf>
  exit(1);
  38:	4505                	li	a0,1
  3a:	298000ef          	jal	ra,2d2 <exit>

000000000000003e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e406                	sd	ra,8(sp)
  42:	e022                	sd	s0,0(sp)
  44:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  46:	fbbff0ef          	jal	ra,0 <main>
  exit(r);
  4a:	288000ef          	jal	ra,2d2 <exit>

000000000000004e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e422                	sd	s0,8(sp)
  52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  54:	87aa                	mv	a5,a0
  56:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
  58:	0785                	addi	a5,a5,1
  5a:	fff5c703          	lbu	a4,-1(a1)
  5e:	fee78fa3          	sb	a4,-1(a5)
  62:	fb75                	bnez	a4,56 <strcpy+0x8>
    ;
  return os;
}
  64:	6422                	ld	s0,8(sp)
  66:	0141                	addi	sp,sp,16
  68:	8082                	ret

000000000000006a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  6a:	1141                	addi	sp,sp,-16
  6c:	e422                	sd	s0,8(sp)
  6e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  70:	00054783          	lbu	a5,0(a0)
  74:	cb91                	beqz	a5,88 <strcmp+0x1e>
  76:	0005c703          	lbu	a4,0(a1)
  7a:	00f71763          	bne	a4,a5,88 <strcmp+0x1e>
    p++, q++;
  7e:	0505                	addi	a0,a0,1
  80:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	fbe5                	bnez	a5,76 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  88:	0005c503          	lbu	a0,0(a1)
}
  8c:	40a7853b          	subw	a0,a5,a0
  90:	6422                	ld	s0,8(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret

0000000000000096 <strlen>:

uint
strlen(const char *s)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cf91                	beqz	a5,bc <strlen+0x26>
  a2:	0505                	addi	a0,a0,1
  a4:	87aa                	mv	a5,a0
  a6:	4685                	li	a3,1
  a8:	9e89                	subw	a3,a3,a0
  aa:	00f6853b          	addw	a0,a3,a5
  ae:	0785                	addi	a5,a5,1
  b0:	fff7c703          	lbu	a4,-1(a5)
  b4:	fb7d                	bnez	a4,aa <strlen+0x14>
    ;
  return n;
}
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret
  for(n = 0; s[n]; n++)
  bc:	4501                	li	a0,0
  be:	bfe5                	j	b6 <strlen+0x20>

00000000000000c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c6:	ca19                	beqz	a2,dc <memset+0x1c>
  c8:	87aa                	mv	a5,a0
  ca:	1602                	slli	a2,a2,0x20
  cc:	9201                	srli	a2,a2,0x20
  ce:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d6:	0785                	addi	a5,a5,1
  d8:	fee79de3          	bne	a5,a4,d2 <memset+0x12>
  }
  return dst;
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <strchr>:

char*
strchr(const char *s, char c)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e422                	sd	s0,8(sp)
  e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	cb99                	beqz	a5,102 <strchr+0x20>
    if(*s == c)
  ee:	00f58763          	beq	a1,a5,fc <strchr+0x1a>
  for(; *s; s++)
  f2:	0505                	addi	a0,a0,1
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbfd                	bnez	a5,ee <strchr+0xc>
      return (char*)s;
  return 0;
  fa:	4501                	li	a0,0
}
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret
  return 0;
 102:	4501                	li	a0,0
 104:	bfe5                	j	fc <strchr+0x1a>

0000000000000106 <gets>:

char*
gets(char *buf, int max)
{
 106:	711d                	addi	sp,sp,-96
 108:	ec86                	sd	ra,88(sp)
 10a:	e8a2                	sd	s0,80(sp)
 10c:	e4a6                	sd	s1,72(sp)
 10e:	e0ca                	sd	s2,64(sp)
 110:	fc4e                	sd	s3,56(sp)
 112:	f852                	sd	s4,48(sp)
 114:	f456                	sd	s5,40(sp)
 116:	f05a                	sd	s6,32(sp)
 118:	ec5e                	sd	s7,24(sp)
 11a:	1080                	addi	s0,sp,96
 11c:	8baa                	mv	s7,a0
 11e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 120:	892a                	mv	s2,a0
 122:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 124:	4aa9                	li	s5,10
 126:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 128:	89a6                	mv	s3,s1
 12a:	2485                	addiw	s1,s1,1
 12c:	0344d663          	bge	s1,s4,158 <gets+0x52>
    cc = read(0, &c, 1);
 130:	4605                	li	a2,1
 132:	faf40593          	addi	a1,s0,-81
 136:	4501                	li	a0,0
 138:	1b2000ef          	jal	ra,2ea <read>
    if(cc < 1)
 13c:	00a05e63          	blez	a0,158 <gets+0x52>
    buf[i++] = c;
 140:	faf44783          	lbu	a5,-81(s0)
 144:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 148:	01578763          	beq	a5,s5,156 <gets+0x50>
 14c:	0905                	addi	s2,s2,1
 14e:	fd679de3          	bne	a5,s6,128 <gets+0x22>
  for(i=0; i+1 < max; ){
 152:	89a6                	mv	s3,s1
 154:	a011                	j	158 <gets+0x52>
 156:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 158:	99de                	add	s3,s3,s7
 15a:	00098023          	sb	zero,0(s3)
  return buf;
}
 15e:	855e                	mv	a0,s7
 160:	60e6                	ld	ra,88(sp)
 162:	6446                	ld	s0,80(sp)
 164:	64a6                	ld	s1,72(sp)
 166:	6906                	ld	s2,64(sp)
 168:	79e2                	ld	s3,56(sp)
 16a:	7a42                	ld	s4,48(sp)
 16c:	7aa2                	ld	s5,40(sp)
 16e:	7b02                	ld	s6,32(sp)
 170:	6be2                	ld	s7,24(sp)
 172:	6125                	addi	sp,sp,96
 174:	8082                	ret

0000000000000176 <stat>:

int
stat(const char *n, struct stat *st)
{
 176:	1101                	addi	sp,sp,-32
 178:	ec06                	sd	ra,24(sp)
 17a:	e822                	sd	s0,16(sp)
 17c:	e426                	sd	s1,8(sp)
 17e:	e04a                	sd	s2,0(sp)
 180:	1000                	addi	s0,sp,32
 182:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 184:	4581                	li	a1,0
 186:	18c000ef          	jal	ra,312 <open>
  if(fd < 0)
 18a:	02054163          	bltz	a0,1ac <stat+0x36>
 18e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 190:	85ca                	mv	a1,s2
 192:	198000ef          	jal	ra,32a <fstat>
 196:	892a                	mv	s2,a0
  close(fd);
 198:	8526                	mv	a0,s1
 19a:	160000ef          	jal	ra,2fa <close>
  return r;
}
 19e:	854a                	mv	a0,s2
 1a0:	60e2                	ld	ra,24(sp)
 1a2:	6442                	ld	s0,16(sp)
 1a4:	64a2                	ld	s1,8(sp)
 1a6:	6902                	ld	s2,0(sp)
 1a8:	6105                	addi	sp,sp,32
 1aa:	8082                	ret
    return -1;
 1ac:	597d                	li	s2,-1
 1ae:	bfc5                	j	19e <stat+0x28>

00000000000001b0 <atoi>:

int
atoi(const char *s)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1b6:	00054683          	lbu	a3,0(a0)
 1ba:	fd06879b          	addiw	a5,a3,-48
 1be:	0ff7f793          	zext.b	a5,a5
 1c2:	4625                	li	a2,9
 1c4:	02f66863          	bltu	a2,a5,1f4 <atoi+0x44>
 1c8:	872a                	mv	a4,a0
  n = 0;
 1ca:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1cc:	0705                	addi	a4,a4,1
 1ce:	0025179b          	slliw	a5,a0,0x2
 1d2:	9fa9                	addw	a5,a5,a0
 1d4:	0017979b          	slliw	a5,a5,0x1
 1d8:	9fb5                	addw	a5,a5,a3
 1da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1de:	00074683          	lbu	a3,0(a4)
 1e2:	fd06879b          	addiw	a5,a3,-48
 1e6:	0ff7f793          	zext.b	a5,a5
 1ea:	fef671e3          	bgeu	a2,a5,1cc <atoi+0x1c>
  return n;
}
 1ee:	6422                	ld	s0,8(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret
  n = 0;
 1f4:	4501                	li	a0,0
 1f6:	bfe5                	j	1ee <atoi+0x3e>

00000000000001f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1fe:	02b57463          	bgeu	a0,a1,226 <memmove+0x2e>
    while(n-- > 0)
 202:	00c05f63          	blez	a2,220 <memmove+0x28>
 206:	1602                	slli	a2,a2,0x20
 208:	9201                	srli	a2,a2,0x20
 20a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 20e:	872a                	mv	a4,a0
      *dst++ = *src++;
 210:	0585                	addi	a1,a1,1
 212:	0705                	addi	a4,a4,1
 214:	fff5c683          	lbu	a3,-1(a1)
 218:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 21c:	fee79ae3          	bne	a5,a4,210 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret
    dst += n;
 226:	00c50733          	add	a4,a0,a2
    src += n;
 22a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 22c:	fec05ae3          	blez	a2,220 <memmove+0x28>
 230:	fff6079b          	addiw	a5,a2,-1
 234:	1782                	slli	a5,a5,0x20
 236:	9381                	srli	a5,a5,0x20
 238:	fff7c793          	not	a5,a5
 23c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 23e:	15fd                	addi	a1,a1,-1
 240:	177d                	addi	a4,a4,-1
 242:	0005c683          	lbu	a3,0(a1)
 246:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 24a:	fee79ae3          	bne	a5,a4,23e <memmove+0x46>
 24e:	bfc9                	j	220 <memmove+0x28>

0000000000000250 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 256:	ca05                	beqz	a2,286 <memcmp+0x36>
 258:	fff6069b          	addiw	a3,a2,-1
 25c:	1682                	slli	a3,a3,0x20
 25e:	9281                	srli	a3,a3,0x20
 260:	0685                	addi	a3,a3,1
 262:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 264:	00054783          	lbu	a5,0(a0)
 268:	0005c703          	lbu	a4,0(a1)
 26c:	00e79863          	bne	a5,a4,27c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 270:	0505                	addi	a0,a0,1
    p2++;
 272:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 274:	fed518e3          	bne	a0,a3,264 <memcmp+0x14>
  }
  return 0;
 278:	4501                	li	a0,0
 27a:	a019                	j	280 <memcmp+0x30>
      return *p1 - *p2;
 27c:	40e7853b          	subw	a0,a5,a4
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
  return 0;
 286:	4501                	li	a0,0
 288:	bfe5                	j	280 <memcmp+0x30>

000000000000028a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e406                	sd	ra,8(sp)
 28e:	e022                	sd	s0,0(sp)
 290:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 292:	f67ff0ef          	jal	ra,1f8 <memmove>
}
 296:	60a2                	ld	ra,8(sp)
 298:	6402                	ld	s0,0(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret

000000000000029e <sbrk>:

char *
sbrk(int n) {
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2a6:	4585                	li	a1,1
 2a8:	0b2000ef          	jal	ra,35a <sys_sbrk>
}
 2ac:	60a2                	ld	ra,8(sp)
 2ae:	6402                	ld	s0,0(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret

00000000000002b4 <sbrklazy>:

char *
sbrklazy(int n) {
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2bc:	4589                	li	a1,2
 2be:	09c000ef          	jal	ra,35a <sys_sbrk>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ca:	4885                	li	a7,1
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d2:	4889                	li	a7,2
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <wait>:
.global wait
wait:
 li a7, SYS_wait
 2da:	488d                	li	a7,3
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e2:	4891                	li	a7,4
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <read>:
.global read
read:
 li a7, SYS_read
 2ea:	4895                	li	a7,5
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <write>:
.global write
write:
 li a7, SYS_write
 2f2:	48c1                	li	a7,16
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <close>:
.global close
close:
 li a7, SYS_close
 2fa:	48d5                	li	a7,21
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <kill>:
.global kill
kill:
 li a7, SYS_kill
 302:	4899                	li	a7,6
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <exec>:
.global exec
exec:
 li a7, SYS_exec
 30a:	489d                	li	a7,7
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <open>:
.global open
open:
 li a7, SYS_open
 312:	48bd                	li	a7,15
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31a:	48c5                	li	a7,17
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 322:	48c9                	li	a7,18
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32a:	48a1                	li	a7,8
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <link>:
.global link
link:
 li a7, SYS_link
 332:	48cd                	li	a7,19
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33a:	48d1                	li	a7,20
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 342:	48a5                	li	a7,9
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <dup>:
.global dup
dup:
 li a7, SYS_dup
 34a:	48a9                	li	a7,10
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 352:	48ad                	li	a7,11
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 35a:	48b1                	li	a7,12
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <pause>:
.global pause
pause:
 li a7, SYS_pause
 362:	48b5                	li	a7,13
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36a:	48b9                	li	a7,14
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 372:	48d9                	li	a7,22
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 37a:	48dd                	li	a7,23
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	1000                	addi	s0,sp,32
 38a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38e:	4605                	li	a2,1
 390:	fef40593          	addi	a1,s0,-17
 394:	f5fff0ef          	jal	ra,2f2 <write>
}
 398:	60e2                	ld	ra,24(sp)
 39a:	6442                	ld	s0,16(sp)
 39c:	6105                	addi	sp,sp,32
 39e:	8082                	ret

00000000000003a0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3a0:	715d                	addi	sp,sp,-80
 3a2:	e486                	sd	ra,72(sp)
 3a4:	e0a2                	sd	s0,64(sp)
 3a6:	fc26                	sd	s1,56(sp)
 3a8:	f84a                	sd	s2,48(sp)
 3aa:	f44e                	sd	s3,40(sp)
 3ac:	0880                	addi	s0,sp,80
 3ae:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3b0:	c299                	beqz	a3,3b6 <printint+0x16>
 3b2:	0805c163          	bltz	a1,434 <printint+0x94>
  neg = 0;
 3b6:	4881                	li	a7,0
 3b8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3bc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3be:	00000517          	auipc	a0,0x0
 3c2:	51250513          	addi	a0,a0,1298 # 8d0 <digits>
 3c6:	883e                	mv	a6,a5
 3c8:	2785                	addiw	a5,a5,1
 3ca:	02c5f733          	remu	a4,a1,a2
 3ce:	972a                	add	a4,a4,a0
 3d0:	00074703          	lbu	a4,0(a4)
 3d4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3d8:	872e                	mv	a4,a1
 3da:	02c5d5b3          	divu	a1,a1,a2
 3de:	0685                	addi	a3,a3,1
 3e0:	fec773e3          	bgeu	a4,a2,3c6 <printint+0x26>
  if(neg)
 3e4:	00088b63          	beqz	a7,3fa <printint+0x5a>
    buf[i++] = '-';
 3e8:	fd078793          	addi	a5,a5,-48
 3ec:	97a2                	add	a5,a5,s0
 3ee:	02d00713          	li	a4,45
 3f2:	fee78423          	sb	a4,-24(a5)
 3f6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3fa:	02f05663          	blez	a5,426 <printint+0x86>
 3fe:	fb840713          	addi	a4,s0,-72
 402:	00f704b3          	add	s1,a4,a5
 406:	fff70993          	addi	s3,a4,-1
 40a:	99be                	add	s3,s3,a5
 40c:	37fd                	addiw	a5,a5,-1
 40e:	1782                	slli	a5,a5,0x20
 410:	9381                	srli	a5,a5,0x20
 412:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 416:	fff4c583          	lbu	a1,-1(s1)
 41a:	854a                	mv	a0,s2
 41c:	f67ff0ef          	jal	ra,382 <putc>
  while(--i >= 0)
 420:	14fd                	addi	s1,s1,-1
 422:	ff349ae3          	bne	s1,s3,416 <printint+0x76>
}
 426:	60a6                	ld	ra,72(sp)
 428:	6406                	ld	s0,64(sp)
 42a:	74e2                	ld	s1,56(sp)
 42c:	7942                	ld	s2,48(sp)
 42e:	79a2                	ld	s3,40(sp)
 430:	6161                	addi	sp,sp,80
 432:	8082                	ret
    x = -xx;
 434:	40b005b3          	neg	a1,a1
    neg = 1;
 438:	4885                	li	a7,1
    x = -xx;
 43a:	bfbd                	j	3b8 <printint+0x18>

000000000000043c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43c:	7119                	addi	sp,sp,-128
 43e:	fc86                	sd	ra,120(sp)
 440:	f8a2                	sd	s0,112(sp)
 442:	f4a6                	sd	s1,104(sp)
 444:	f0ca                	sd	s2,96(sp)
 446:	ecce                	sd	s3,88(sp)
 448:	e8d2                	sd	s4,80(sp)
 44a:	e4d6                	sd	s5,72(sp)
 44c:	e0da                	sd	s6,64(sp)
 44e:	fc5e                	sd	s7,56(sp)
 450:	f862                	sd	s8,48(sp)
 452:	f466                	sd	s9,40(sp)
 454:	f06a                	sd	s10,32(sp)
 456:	ec6e                	sd	s11,24(sp)
 458:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 45a:	0005c903          	lbu	s2,0(a1)
 45e:	24090c63          	beqz	s2,6b6 <vprintf+0x27a>
 462:	8b2a                	mv	s6,a0
 464:	8a2e                	mv	s4,a1
 466:	8bb2                	mv	s7,a2
  state = 0;
 468:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 46a:	4481                	li	s1,0
 46c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 46e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 472:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 476:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 47a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 47e:	00000c97          	auipc	s9,0x0
 482:	452c8c93          	addi	s9,s9,1106 # 8d0 <digits>
 486:	a005                	j	4a6 <vprintf+0x6a>
        putc(fd, c0);
 488:	85ca                	mv	a1,s2
 48a:	855a                	mv	a0,s6
 48c:	ef7ff0ef          	jal	ra,382 <putc>
 490:	a019                	j	496 <vprintf+0x5a>
    } else if(state == '%'){
 492:	03598263          	beq	s3,s5,4b6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 496:	2485                	addiw	s1,s1,1
 498:	8726                	mv	a4,s1
 49a:	009a07b3          	add	a5,s4,s1
 49e:	0007c903          	lbu	s2,0(a5)
 4a2:	20090a63          	beqz	s2,6b6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4a6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4aa:	fe0994e3          	bnez	s3,492 <vprintf+0x56>
      if(c0 == '%'){
 4ae:	fd579de3          	bne	a5,s5,488 <vprintf+0x4c>
        state = '%';
 4b2:	89be                	mv	s3,a5
 4b4:	b7cd                	j	496 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4b6:	c3c1                	beqz	a5,536 <vprintf+0xfa>
 4b8:	00ea06b3          	add	a3,s4,a4
 4bc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4c0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4c2:	c681                	beqz	a3,4ca <vprintf+0x8e>
 4c4:	9752                	add	a4,a4,s4
 4c6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4ca:	03878e63          	beq	a5,s8,506 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 4ce:	05a78863          	beq	a5,s10,51e <vprintf+0xe2>
      } else if(c0 == 'u'){
 4d2:	0db78b63          	beq	a5,s11,5a8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4d6:	07800713          	li	a4,120
 4da:	10e78d63          	beq	a5,a4,5f4 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4de:	07000713          	li	a4,112
 4e2:	14e78263          	beq	a5,a4,626 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4e6:	06300713          	li	a4,99
 4ea:	16e78f63          	beq	a5,a4,668 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4ee:	07300713          	li	a4,115
 4f2:	18e78563          	beq	a5,a4,67c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4f6:	05579063          	bne	a5,s5,536 <vprintf+0xfa>
        putc(fd, '%');
 4fa:	85d6                	mv	a1,s5
 4fc:	855a                	mv	a0,s6
 4fe:	e85ff0ef          	jal	ra,382 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 502:	4981                	li	s3,0
 504:	bf49                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 506:	008b8913          	addi	s2,s7,8
 50a:	4685                	li	a3,1
 50c:	4629                	li	a2,10
 50e:	000ba583          	lw	a1,0(s7)
 512:	855a                	mv	a0,s6
 514:	e8dff0ef          	jal	ra,3a0 <printint>
 518:	8bca                	mv	s7,s2
      state = 0;
 51a:	4981                	li	s3,0
 51c:	bfad                	j	496 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 51e:	03868663          	beq	a3,s8,54a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 522:	05a68163          	beq	a3,s10,564 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 526:	09b68d63          	beq	a3,s11,5c0 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 52a:	03a68f63          	beq	a3,s10,568 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 52e:	07800793          	li	a5,120
 532:	0cf68d63          	beq	a3,a5,60c <vprintf+0x1d0>
        putc(fd, '%');
 536:	85d6                	mv	a1,s5
 538:	855a                	mv	a0,s6
 53a:	e49ff0ef          	jal	ra,382 <putc>
        putc(fd, c0);
 53e:	85ca                	mv	a1,s2
 540:	855a                	mv	a0,s6
 542:	e41ff0ef          	jal	ra,382 <putc>
      state = 0;
 546:	4981                	li	s3,0
 548:	b7b9                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4685                	li	a3,1
 550:	4629                	li	a2,10
 552:	000bb583          	ld	a1,0(s7)
 556:	855a                	mv	a0,s6
 558:	e49ff0ef          	jal	ra,3a0 <printint>
        i += 1;
 55c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 55e:	8bca                	mv	s7,s2
      state = 0;
 560:	4981                	li	s3,0
        i += 1;
 562:	bf15                	j	496 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 564:	03860563          	beq	a2,s8,58e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 568:	07b60963          	beq	a2,s11,5da <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 56c:	07800793          	li	a5,120
 570:	fcf613e3          	bne	a2,a5,536 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 574:	008b8913          	addi	s2,s7,8
 578:	4681                	li	a3,0
 57a:	4641                	li	a2,16
 57c:	000bb583          	ld	a1,0(s7)
 580:	855a                	mv	a0,s6
 582:	e1fff0ef          	jal	ra,3a0 <printint>
        i += 2;
 586:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 588:	8bca                	mv	s7,s2
      state = 0;
 58a:	4981                	li	s3,0
        i += 2;
 58c:	b729                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 58e:	008b8913          	addi	s2,s7,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000bb583          	ld	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	e05ff0ef          	jal	ra,3a0 <printint>
        i += 2;
 5a0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
        i += 2;
 5a6:	bdc5                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5a8:	008b8913          	addi	s2,s7,8
 5ac:	4681                	li	a3,0
 5ae:	4629                	li	a2,10
 5b0:	000be583          	lwu	a1,0(s7)
 5b4:	855a                	mv	a0,s6
 5b6:	debff0ef          	jal	ra,3a0 <printint>
 5ba:	8bca                	mv	s7,s2
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	bde1                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4681                	li	a3,0
 5c6:	4629                	li	a2,10
 5c8:	000bb583          	ld	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	dd3ff0ef          	jal	ra,3a0 <printint>
        i += 1;
 5d2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
        i += 1;
 5d8:	bd7d                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4681                	li	a3,0
 5e0:	4629                	li	a2,10
 5e2:	000bb583          	ld	a1,0(s7)
 5e6:	855a                	mv	a0,s6
 5e8:	db9ff0ef          	jal	ra,3a0 <printint>
        i += 2;
 5ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ee:	8bca                	mv	s7,s2
      state = 0;
 5f0:	4981                	li	s3,0
        i += 2;
 5f2:	b555                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4641                	li	a2,16
 5fc:	000be583          	lwu	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	d9fff0ef          	jal	ra,3a0 <printint>
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
 60a:	b571                	j	496 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4641                	li	a2,16
 614:	000bb583          	ld	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	d87ff0ef          	jal	ra,3a0 <printint>
        i += 1;
 61e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 620:	8bca                	mv	s7,s2
      state = 0;
 622:	4981                	li	s3,0
        i += 1;
 624:	bd8d                	j	496 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 626:	008b8793          	addi	a5,s7,8
 62a:	f8f43423          	sd	a5,-120(s0)
 62e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 632:	03000593          	li	a1,48
 636:	855a                	mv	a0,s6
 638:	d4bff0ef          	jal	ra,382 <putc>
  putc(fd, 'x');
 63c:	07800593          	li	a1,120
 640:	855a                	mv	a0,s6
 642:	d41ff0ef          	jal	ra,382 <putc>
 646:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 648:	03c9d793          	srli	a5,s3,0x3c
 64c:	97e6                	add	a5,a5,s9
 64e:	0007c583          	lbu	a1,0(a5)
 652:	855a                	mv	a0,s6
 654:	d2fff0ef          	jal	ra,382 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 658:	0992                	slli	s3,s3,0x4
 65a:	397d                	addiw	s2,s2,-1
 65c:	fe0916e3          	bnez	s2,648 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 660:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 664:	4981                	li	s3,0
 666:	bd05                	j	496 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 668:	008b8913          	addi	s2,s7,8
 66c:	000bc583          	lbu	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	d11ff0ef          	jal	ra,382 <putc>
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
 67a:	bd31                	j	496 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 67c:	008b8993          	addi	s3,s7,8
 680:	000bb903          	ld	s2,0(s7)
 684:	00090f63          	beqz	s2,6a2 <vprintf+0x266>
        for(; *s; s++)
 688:	00094583          	lbu	a1,0(s2)
 68c:	c195                	beqz	a1,6b0 <vprintf+0x274>
          putc(fd, *s);
 68e:	855a                	mv	a0,s6
 690:	cf3ff0ef          	jal	ra,382 <putc>
        for(; *s; s++)
 694:	0905                	addi	s2,s2,1
 696:	00094583          	lbu	a1,0(s2)
 69a:	f9f5                	bnez	a1,68e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 69c:	8bce                	mv	s7,s3
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bbdd                	j	496 <vprintf+0x5a>
          s = "(null)";
 6a2:	00000917          	auipc	s2,0x0
 6a6:	22690913          	addi	s2,s2,550 # 8c8 <malloc+0x116>
        for(; *s; s++)
 6aa:	02800593          	li	a1,40
 6ae:	b7c5                	j	68e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6b0:	8bce                	mv	s7,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b3cd                	j	496 <vprintf+0x5a>
    }
  }
}
 6b6:	70e6                	ld	ra,120(sp)
 6b8:	7446                	ld	s0,112(sp)
 6ba:	74a6                	ld	s1,104(sp)
 6bc:	7906                	ld	s2,96(sp)
 6be:	69e6                	ld	s3,88(sp)
 6c0:	6a46                	ld	s4,80(sp)
 6c2:	6aa6                	ld	s5,72(sp)
 6c4:	6b06                	ld	s6,64(sp)
 6c6:	7be2                	ld	s7,56(sp)
 6c8:	7c42                	ld	s8,48(sp)
 6ca:	7ca2                	ld	s9,40(sp)
 6cc:	7d02                	ld	s10,32(sp)
 6ce:	6de2                	ld	s11,24(sp)
 6d0:	6109                	addi	sp,sp,128
 6d2:	8082                	ret

00000000000006d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d4:	715d                	addi	sp,sp,-80
 6d6:	ec06                	sd	ra,24(sp)
 6d8:	e822                	sd	s0,16(sp)
 6da:	1000                	addi	s0,sp,32
 6dc:	e010                	sd	a2,0(s0)
 6de:	e414                	sd	a3,8(s0)
 6e0:	e818                	sd	a4,16(s0)
 6e2:	ec1c                	sd	a5,24(s0)
 6e4:	03043023          	sd	a6,32(s0)
 6e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f0:	8622                	mv	a2,s0
 6f2:	d4bff0ef          	jal	ra,43c <vprintf>
}
 6f6:	60e2                	ld	ra,24(sp)
 6f8:	6442                	ld	s0,16(sp)
 6fa:	6161                	addi	sp,sp,80
 6fc:	8082                	ret

00000000000006fe <printf>:

void
printf(const char *fmt, ...)
{
 6fe:	711d                	addi	sp,sp,-96
 700:	ec06                	sd	ra,24(sp)
 702:	e822                	sd	s0,16(sp)
 704:	1000                	addi	s0,sp,32
 706:	e40c                	sd	a1,8(s0)
 708:	e810                	sd	a2,16(s0)
 70a:	ec14                	sd	a3,24(s0)
 70c:	f018                	sd	a4,32(s0)
 70e:	f41c                	sd	a5,40(s0)
 710:	03043823          	sd	a6,48(s0)
 714:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 718:	00840613          	addi	a2,s0,8
 71c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 720:	85aa                	mv	a1,a0
 722:	4505                	li	a0,1
 724:	d19ff0ef          	jal	ra,43c <vprintf>
}
 728:	60e2                	ld	ra,24(sp)
 72a:	6442                	ld	s0,16(sp)
 72c:	6125                	addi	sp,sp,96
 72e:	8082                	ret

0000000000000730 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 730:	1141                	addi	sp,sp,-16
 732:	e422                	sd	s0,8(sp)
 734:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 736:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73a:	00001797          	auipc	a5,0x1
 73e:	8c67b783          	ld	a5,-1850(a5) # 1000 <freep>
 742:	a02d                	j	76c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 744:	4618                	lw	a4,8(a2)
 746:	9f2d                	addw	a4,a4,a1
 748:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 74c:	6398                	ld	a4,0(a5)
 74e:	6310                	ld	a2,0(a4)
 750:	a83d                	j	78e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 752:	ff852703          	lw	a4,-8(a0)
 756:	9f31                	addw	a4,a4,a2
 758:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 75a:	ff053683          	ld	a3,-16(a0)
 75e:	a091                	j	7a2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 760:	6398                	ld	a4,0(a5)
 762:	00e7e463          	bltu	a5,a4,76a <free+0x3a>
 766:	00e6ea63          	bltu	a3,a4,77a <free+0x4a>
{
 76a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76c:	fed7fae3          	bgeu	a5,a3,760 <free+0x30>
 770:	6398                	ld	a4,0(a5)
 772:	00e6e463          	bltu	a3,a4,77a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 776:	fee7eae3          	bltu	a5,a4,76a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 77a:	ff852583          	lw	a1,-8(a0)
 77e:	6390                	ld	a2,0(a5)
 780:	02059813          	slli	a6,a1,0x20
 784:	01c85713          	srli	a4,a6,0x1c
 788:	9736                	add	a4,a4,a3
 78a:	fae60de3          	beq	a2,a4,744 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 78e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 792:	4790                	lw	a2,8(a5)
 794:	02061593          	slli	a1,a2,0x20
 798:	01c5d713          	srli	a4,a1,0x1c
 79c:	973e                	add	a4,a4,a5
 79e:	fae68ae3          	beq	a3,a4,752 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7a2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7a4:	00001717          	auipc	a4,0x1
 7a8:	84f73e23          	sd	a5,-1956(a4) # 1000 <freep>
}
 7ac:	6422                	ld	s0,8(sp)
 7ae:	0141                	addi	sp,sp,16
 7b0:	8082                	ret

00000000000007b2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b2:	7139                	addi	sp,sp,-64
 7b4:	fc06                	sd	ra,56(sp)
 7b6:	f822                	sd	s0,48(sp)
 7b8:	f426                	sd	s1,40(sp)
 7ba:	f04a                	sd	s2,32(sp)
 7bc:	ec4e                	sd	s3,24(sp)
 7be:	e852                	sd	s4,16(sp)
 7c0:	e456                	sd	s5,8(sp)
 7c2:	e05a                	sd	s6,0(sp)
 7c4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c6:	02051493          	slli	s1,a0,0x20
 7ca:	9081                	srli	s1,s1,0x20
 7cc:	04bd                	addi	s1,s1,15
 7ce:	8091                	srli	s1,s1,0x4
 7d0:	0014899b          	addiw	s3,s1,1
 7d4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7d6:	00001517          	auipc	a0,0x1
 7da:	82a53503          	ld	a0,-2006(a0) # 1000 <freep>
 7de:	c515                	beqz	a0,80a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e2:	4798                	lw	a4,8(a5)
 7e4:	02977f63          	bgeu	a4,s1,822 <malloc+0x70>
 7e8:	8a4e                	mv	s4,s3
 7ea:	0009871b          	sext.w	a4,s3
 7ee:	6685                	lui	a3,0x1
 7f0:	00d77363          	bgeu	a4,a3,7f6 <malloc+0x44>
 7f4:	6a05                	lui	s4,0x1
 7f6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7fa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7fe:	00001917          	auipc	s2,0x1
 802:	80290913          	addi	s2,s2,-2046 # 1000 <freep>
  if(p == SBRK_ERROR)
 806:	5afd                	li	s5,-1
 808:	a885                	j	878 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 80a:	00001797          	auipc	a5,0x1
 80e:	80678793          	addi	a5,a5,-2042 # 1010 <base>
 812:	00000717          	auipc	a4,0x0
 816:	7ef73723          	sd	a5,2030(a4) # 1000 <freep>
 81a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 81c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 820:	b7e1                	j	7e8 <malloc+0x36>
      if(p->s.size == nunits)
 822:	02e48c63          	beq	s1,a4,85a <malloc+0xa8>
        p->s.size -= nunits;
 826:	4137073b          	subw	a4,a4,s3
 82a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 82c:	02071693          	slli	a3,a4,0x20
 830:	01c6d713          	srli	a4,a3,0x1c
 834:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 836:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 83a:	00000717          	auipc	a4,0x0
 83e:	7ca73323          	sd	a0,1990(a4) # 1000 <freep>
      return (void*)(p + 1);
 842:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 846:	70e2                	ld	ra,56(sp)
 848:	7442                	ld	s0,48(sp)
 84a:	74a2                	ld	s1,40(sp)
 84c:	7902                	ld	s2,32(sp)
 84e:	69e2                	ld	s3,24(sp)
 850:	6a42                	ld	s4,16(sp)
 852:	6aa2                	ld	s5,8(sp)
 854:	6b02                	ld	s6,0(sp)
 856:	6121                	addi	sp,sp,64
 858:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 85a:	6398                	ld	a4,0(a5)
 85c:	e118                	sd	a4,0(a0)
 85e:	bff1                	j	83a <malloc+0x88>
  hp->s.size = nu;
 860:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 864:	0541                	addi	a0,a0,16
 866:	ecbff0ef          	jal	ra,730 <free>
  return freep;
 86a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 86e:	dd61                	beqz	a0,846 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	fa9777e3          	bgeu	a4,s1,822 <malloc+0x70>
    if(p == freep)
 878:	00093703          	ld	a4,0(s2)
 87c:	853e                	mv	a0,a5
 87e:	fef719e3          	bne	a4,a5,870 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 882:	8552                	mv	a0,s4
 884:	a1bff0ef          	jal	ra,29e <sbrk>
  if(p == SBRK_ERROR)
 888:	fd551ce3          	bne	a0,s5,860 <malloc+0xae>
        return 0;
 88c:	4501                	li	a0,0
 88e:	bf65                	j	846 <malloc+0x94>
