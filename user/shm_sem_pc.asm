
user/_shm_sem_pc：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  int x;
};

int
main(void)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int key = 2;
  struct shmblk *p = (struct shmblk*)mmap(0, 4096, PROT_READ|PROT_WRITE,
  10:	4709                	li	a4,2
  12:	468d                	li	a3,3
  14:	460d                	li	a2,3
  16:	6585                	lui	a1,0x1
  18:	4501                	li	a0,0
  1a:	3f6000ef          	jal	ra,410 <mmap>
                                         MAP_ANON|MAP_SHARED, key);
  if(p == (void*)-1){
  1e:	57fd                	li	a5,-1
  20:	02f50a63          	beq	a0,a5,54 <main+0x54>
  24:	892a                	mv	s2,a0

  // sem key 我建议用不同 key，避免混淆
  int sem_empty = 100;
  int sem_full  = 101;

  if(sem_open(sem_empty, 1) < 0 || sem_open(sem_full, 0) < 0){
  26:	4585                	li	a1,1
  28:	06400513          	li	a0,100
  2c:	404000ef          	jal	ra,430 <sem_open>
  30:	00054963          	bltz	a0,42 <main+0x42>
  34:	4581                	li	a1,0
  36:	06500513          	li	a0,101
  3a:	3f6000ef          	jal	ra,430 <sem_open>
  3e:	02055463          	bgez	a0,66 <main+0x66>
    printf("sem_open fail\n");
  42:	00001517          	auipc	a0,0x1
  46:	92e50513          	addi	a0,a0,-1746 # 970 <malloc+0xf8>
  4a:	77a000ef          	jal	ra,7c4 <printf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	320000ef          	jal	ra,370 <exit>
    printf("mmap fail\n");
  54:	00001517          	auipc	a0,0x1
  58:	90c50513          	addi	a0,a0,-1780 # 960 <malloc+0xe8>
  5c:	768000ef          	jal	ra,7c4 <printf>
    exit(1);
  60:	4505                	li	a0,1
  62:	30e000ef          	jal	ra,370 <exit>
  }

  int pid = fork();
  66:	302000ef          	jal	ra,368 <fork>
  if(pid == 0){
  6a:	e905                	bnez	a0,9a <main+0x9a>
  6c:	44d1                	li	s1,20
    // consumer
    for(int i=1;i<=20;i++){
      sem_wait(sem_full);
      int v = p->x;
      printf("C got %d\n", v);
  6e:	00001997          	auipc	s3,0x1
  72:	91298993          	addi	s3,s3,-1774 # 980 <malloc+0x108>
      sem_wait(sem_full);
  76:	06500513          	li	a0,101
  7a:	3be000ef          	jal	ra,438 <sem_wait>
      printf("C got %d\n", v);
  7e:	00092583          	lw	a1,0(s2)
  82:	854e                	mv	a0,s3
  84:	740000ef          	jal	ra,7c4 <printf>
      sem_post(sem_empty);
  88:	06400513          	li	a0,100
  8c:	3b4000ef          	jal	ra,440 <sem_post>
    for(int i=1;i<=20;i++){
  90:	34fd                	addiw	s1,s1,-1
  92:	f0f5                	bnez	s1,76 <main+0x76>
    }
    exit(0);
  94:	4501                	li	a0,0
  96:	2da000ef          	jal	ra,370 <exit>
  }

  // producer
  for(int i=1;i<=20;i++){
  9a:	4485                	li	s1,1
    sem_wait(sem_empty);
    p->x = i;
    printf("P put %d\n", i);
  9c:	00001a17          	auipc	s4,0x1
  a0:	8f4a0a13          	addi	s4,s4,-1804 # 990 <malloc+0x118>
  for(int i=1;i<=20;i++){
  a4:	49d5                	li	s3,21
    sem_wait(sem_empty);
  a6:	06400513          	li	a0,100
  aa:	38e000ef          	jal	ra,438 <sem_wait>
    p->x = i;
  ae:	00992023          	sw	s1,0(s2)
    printf("P put %d\n", i);
  b2:	85a6                	mv	a1,s1
  b4:	8552                	mv	a0,s4
  b6:	70e000ef          	jal	ra,7c4 <printf>
    sem_post(sem_full);
  ba:	06500513          	li	a0,101
  be:	382000ef          	jal	ra,440 <sem_post>
  for(int i=1;i<=20;i++){
  c2:	2485                	addiw	s1,s1,1
  c4:	ff3491e3          	bne	s1,s3,a6 <main+0xa6>
  }

  wait(0);
  c8:	4501                	li	a0,0
  ca:	2ae000ef          	jal	ra,378 <wait>
  munmap((char*)p, 4096);
  ce:	6585                	lui	a1,0x1
  d0:	854a                	mv	a0,s2
  d2:	346000ef          	jal	ra,418 <munmap>
  exit(0);
  d6:	4501                	li	a0,0
  d8:	298000ef          	jal	ra,370 <exit>

00000000000000dc <start>:
// wrapper so that it's OK if main() does not call exit().
//

void
start(int argc, char **argv)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e406                	sd	ra,8(sp)
  e0:	e022                	sd	s0,0(sp)
  e2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e4:	f1dff0ef          	jal	ra,0 <main>
  exit(r);
  e8:	288000ef          	jal	ra,370 <exit>

00000000000000ec <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f2:	87aa                	mv	a5,a0
  f4:	0585                	addi	a1,a1,1 # 1001 <freep+0x1>
  f6:	0785                	addi	a5,a5,1
  f8:	fff5c703          	lbu	a4,-1(a1)
  fc:	fee78fa3          	sb	a4,-1(a5)
 100:	fb75                	bnez	a4,f4 <strcpy+0x8>
    ;
  return os;
}
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cb91                	beqz	a5,126 <strcmp+0x1e>
 114:	0005c703          	lbu	a4,0(a1)
 118:	00f71763          	bne	a4,a5,126 <strcmp+0x1e>
    p++, q++;
 11c:	0505                	addi	a0,a0,1
 11e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 120:	00054783          	lbu	a5,0(a0)
 124:	fbe5                	bnez	a5,114 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 126:	0005c503          	lbu	a0,0(a1)
}
 12a:	40a7853b          	subw	a0,a5,a0
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strlen>:

uint
strlen(const char *s)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cf91                	beqz	a5,15a <strlen+0x26>
 140:	0505                	addi	a0,a0,1
 142:	87aa                	mv	a5,a0
 144:	4685                	li	a3,1
 146:	9e89                	subw	a3,a3,a0
 148:	00f6853b          	addw	a0,a3,a5
 14c:	0785                	addi	a5,a5,1
 14e:	fff7c703          	lbu	a4,-1(a5)
 152:	fb7d                	bnez	a4,148 <strlen+0x14>
    ;
  return n;
}
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret
  for(n = 0; s[n]; n++)
 15a:	4501                	li	a0,0
 15c:	bfe5                	j	154 <strlen+0x20>

000000000000015e <memset>:

void*
memset(void *dst, int c, uint n)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e422                	sd	s0,8(sp)
 162:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 164:	ca19                	beqz	a2,17a <memset+0x1c>
 166:	87aa                	mv	a5,a0
 168:	1602                	slli	a2,a2,0x20
 16a:	9201                	srli	a2,a2,0x20
 16c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 170:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 174:	0785                	addi	a5,a5,1
 176:	fee79de3          	bne	a5,a4,170 <memset+0x12>
  }
  return dst;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strchr>:

char*
strchr(const char *s, char c)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  for(; *s; s++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cb99                	beqz	a5,1a0 <strchr+0x20>
    if(*s == c)
 18c:	00f58763          	beq	a1,a5,19a <strchr+0x1a>
  for(; *s; s++)
 190:	0505                	addi	a0,a0,1
 192:	00054783          	lbu	a5,0(a0)
 196:	fbfd                	bnez	a5,18c <strchr+0xc>
      return (char*)s;
  return 0;
 198:	4501                	li	a0,0
}
 19a:	6422                	ld	s0,8(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret
  return 0;
 1a0:	4501                	li	a0,0
 1a2:	bfe5                	j	19a <strchr+0x1a>

00000000000001a4 <gets>:

char*
gets(char *buf, int max)
{
 1a4:	711d                	addi	sp,sp,-96
 1a6:	ec86                	sd	ra,88(sp)
 1a8:	e8a2                	sd	s0,80(sp)
 1aa:	e4a6                	sd	s1,72(sp)
 1ac:	e0ca                	sd	s2,64(sp)
 1ae:	fc4e                	sd	s3,56(sp)
 1b0:	f852                	sd	s4,48(sp)
 1b2:	f456                	sd	s5,40(sp)
 1b4:	f05a                	sd	s6,32(sp)
 1b6:	ec5e                	sd	s7,24(sp)
 1b8:	1080                	addi	s0,sp,96
 1ba:	8baa                	mv	s7,a0
 1bc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1be:	892a                	mv	s2,a0
 1c0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1c2:	4aa9                	li	s5,10
 1c4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c6:	89a6                	mv	s3,s1
 1c8:	2485                	addiw	s1,s1,1
 1ca:	0344d663          	bge	s1,s4,1f6 <gets+0x52>
    cc = read(0, &c, 1);
 1ce:	4605                	li	a2,1
 1d0:	faf40593          	addi	a1,s0,-81
 1d4:	4501                	li	a0,0
 1d6:	1b2000ef          	jal	ra,388 <read>
    if(cc < 1)
 1da:	00a05e63          	blez	a0,1f6 <gets+0x52>
    buf[i++] = c;
 1de:	faf44783          	lbu	a5,-81(s0)
 1e2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e6:	01578763          	beq	a5,s5,1f4 <gets+0x50>
 1ea:	0905                	addi	s2,s2,1
 1ec:	fd679de3          	bne	a5,s6,1c6 <gets+0x22>
  for(i=0; i+1 < max; ){
 1f0:	89a6                	mv	s3,s1
 1f2:	a011                	j	1f6 <gets+0x52>
 1f4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f6:	99de                	add	s3,s3,s7
 1f8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1fc:	855e                	mv	a0,s7
 1fe:	60e6                	ld	ra,88(sp)
 200:	6446                	ld	s0,80(sp)
 202:	64a6                	ld	s1,72(sp)
 204:	6906                	ld	s2,64(sp)
 206:	79e2                	ld	s3,56(sp)
 208:	7a42                	ld	s4,48(sp)
 20a:	7aa2                	ld	s5,40(sp)
 20c:	7b02                	ld	s6,32(sp)
 20e:	6be2                	ld	s7,24(sp)
 210:	6125                	addi	sp,sp,96
 212:	8082                	ret

0000000000000214 <stat>:

int
stat(const char *n, struct stat *st)
{
 214:	1101                	addi	sp,sp,-32
 216:	ec06                	sd	ra,24(sp)
 218:	e822                	sd	s0,16(sp)
 21a:	e426                	sd	s1,8(sp)
 21c:	e04a                	sd	s2,0(sp)
 21e:	1000                	addi	s0,sp,32
 220:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	4581                	li	a1,0
 224:	18c000ef          	jal	ra,3b0 <open>
  if(fd < 0)
 228:	02054163          	bltz	a0,24a <stat+0x36>
 22c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 22e:	85ca                	mv	a1,s2
 230:	198000ef          	jal	ra,3c8 <fstat>
 234:	892a                	mv	s2,a0
  close(fd);
 236:	8526                	mv	a0,s1
 238:	160000ef          	jal	ra,398 <close>
  return r;
}
 23c:	854a                	mv	a0,s2
 23e:	60e2                	ld	ra,24(sp)
 240:	6442                	ld	s0,16(sp)
 242:	64a2                	ld	s1,8(sp)
 244:	6902                	ld	s2,0(sp)
 246:	6105                	addi	sp,sp,32
 248:	8082                	ret
    return -1;
 24a:	597d                	li	s2,-1
 24c:	bfc5                	j	23c <stat+0x28>

000000000000024e <atoi>:

int
atoi(const char *s)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 254:	00054683          	lbu	a3,0(a0)
 258:	fd06879b          	addiw	a5,a3,-48
 25c:	0ff7f793          	zext.b	a5,a5
 260:	4625                	li	a2,9
 262:	02f66863          	bltu	a2,a5,292 <atoi+0x44>
 266:	872a                	mv	a4,a0
  n = 0;
 268:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 26a:	0705                	addi	a4,a4,1
 26c:	0025179b          	slliw	a5,a0,0x2
 270:	9fa9                	addw	a5,a5,a0
 272:	0017979b          	slliw	a5,a5,0x1
 276:	9fb5                	addw	a5,a5,a3
 278:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27c:	00074683          	lbu	a3,0(a4)
 280:	fd06879b          	addiw	a5,a3,-48
 284:	0ff7f793          	zext.b	a5,a5
 288:	fef671e3          	bgeu	a2,a5,26a <atoi+0x1c>
  return n;
}
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret
  n = 0;
 292:	4501                	li	a0,0
 294:	bfe5                	j	28c <atoi+0x3e>

0000000000000296 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29c:	02b57463          	bgeu	a0,a1,2c4 <memmove+0x2e>
    while(n-- > 0)
 2a0:	00c05f63          	blez	a2,2be <memmove+0x28>
 2a4:	1602                	slli	a2,a2,0x20
 2a6:	9201                	srli	a2,a2,0x20
 2a8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ae:	0585                	addi	a1,a1,1
 2b0:	0705                	addi	a4,a4,1
 2b2:	fff5c683          	lbu	a3,-1(a1)
 2b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ba:	fee79ae3          	bne	a5,a4,2ae <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret
    dst += n;
 2c4:	00c50733          	add	a4,a0,a2
    src += n;
 2c8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ca:	fec05ae3          	blez	a2,2be <memmove+0x28>
 2ce:	fff6079b          	addiw	a5,a2,-1
 2d2:	1782                	slli	a5,a5,0x20
 2d4:	9381                	srli	a5,a5,0x20
 2d6:	fff7c793          	not	a5,a5
 2da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2dc:	15fd                	addi	a1,a1,-1
 2de:	177d                	addi	a4,a4,-1
 2e0:	0005c683          	lbu	a3,0(a1)
 2e4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e8:	fee79ae3          	bne	a5,a4,2dc <memmove+0x46>
 2ec:	bfc9                	j	2be <memmove+0x28>

00000000000002ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f4:	ca05                	beqz	a2,324 <memcmp+0x36>
 2f6:	fff6069b          	addiw	a3,a2,-1
 2fa:	1682                	slli	a3,a3,0x20
 2fc:	9281                	srli	a3,a3,0x20
 2fe:	0685                	addi	a3,a3,1
 300:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 302:	00054783          	lbu	a5,0(a0)
 306:	0005c703          	lbu	a4,0(a1)
 30a:	00e79863          	bne	a5,a4,31a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 30e:	0505                	addi	a0,a0,1
    p2++;
 310:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 312:	fed518e3          	bne	a0,a3,302 <memcmp+0x14>
  }
  return 0;
 316:	4501                	li	a0,0
 318:	a019                	j	31e <memcmp+0x30>
      return *p1 - *p2;
 31a:	40e7853b          	subw	a0,a5,a4
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
  return 0;
 324:	4501                	li	a0,0
 326:	bfe5                	j	31e <memcmp+0x30>

0000000000000328 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 330:	f67ff0ef          	jal	ra,296 <memmove>
}
 334:	60a2                	ld	ra,8(sp)
 336:	6402                	ld	s0,0(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret

000000000000033c <sbrk>:

char *
sbrk(int n) {
 33c:	1141                	addi	sp,sp,-16
 33e:	e406                	sd	ra,8(sp)
 340:	e022                	sd	s0,0(sp)
 342:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 344:	4585                	li	a1,1
 346:	0b2000ef          	jal	ra,3f8 <sys_sbrk>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <sbrklazy>:

char *
sbrklazy(int n) {
 352:	1141                	addi	sp,sp,-16
 354:	e406                	sd	ra,8(sp)
 356:	e022                	sd	s0,0(sp)
 358:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 35a:	4589                	li	a1,2
 35c:	09c000ef          	jal	ra,3f8 <sys_sbrk>
}
 360:	60a2                	ld	ra,8(sp)
 362:	6402                	ld	s0,0(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret

0000000000000368 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 368:	4885                	li	a7,1
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <exit>:
.global exit
exit:
 li a7, SYS_exit
 370:	4889                	li	a7,2
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <wait>:
.global wait
wait:
 li a7, SYS_wait
 378:	488d                	li	a7,3
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 380:	4891                	li	a7,4
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <read>:
.global read
read:
 li a7, SYS_read
 388:	4895                	li	a7,5
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <write>:
.global write
write:
 li a7, SYS_write
 390:	48c1                	li	a7,16
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <close>:
.global close
close:
 li a7, SYS_close
 398:	48d5                	li	a7,21
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a0:	4899                	li	a7,6
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a8:	489d                	li	a7,7
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <open>:
.global open
open:
 li a7, SYS_open
 3b0:	48bd                	li	a7,15
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b8:	48c5                	li	a7,17
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c0:	48c9                	li	a7,18
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c8:	48a1                	li	a7,8
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <link>:
.global link
link:
 li a7, SYS_link
 3d0:	48cd                	li	a7,19
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d8:	48d1                	li	a7,20
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e0:	48a5                	li	a7,9
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e8:	48a9                	li	a7,10
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f0:	48ad                	li	a7,11
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3f8:	48b1                	li	a7,12
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <pause>:
.global pause
pause:
 li a7, SYS_pause
 400:	48b5                	li	a7,13
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 408:	48b9                	li	a7,14
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 410:	48d9                	li	a7,22
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 418:	48dd                	li	a7,23
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 420:	48e1                	li	a7,24
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 428:	48e5                	li	a7,25
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 430:	48e9                	li	a7,26
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 438:	48ed                	li	a7,27
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 440:	48f1                	li	a7,28
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 448:	1101                	addi	sp,sp,-32
 44a:	ec06                	sd	ra,24(sp)
 44c:	e822                	sd	s0,16(sp)
 44e:	1000                	addi	s0,sp,32
 450:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 454:	4605                	li	a2,1
 456:	fef40593          	addi	a1,s0,-17
 45a:	f37ff0ef          	jal	ra,390 <write>
}
 45e:	60e2                	ld	ra,24(sp)
 460:	6442                	ld	s0,16(sp)
 462:	6105                	addi	sp,sp,32
 464:	8082                	ret

0000000000000466 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 466:	715d                	addi	sp,sp,-80
 468:	e486                	sd	ra,72(sp)
 46a:	e0a2                	sd	s0,64(sp)
 46c:	fc26                	sd	s1,56(sp)
 46e:	f84a                	sd	s2,48(sp)
 470:	f44e                	sd	s3,40(sp)
 472:	0880                	addi	s0,sp,80
 474:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 476:	c299                	beqz	a3,47c <printint+0x16>
 478:	0805c163          	bltz	a1,4fa <printint+0x94>
  neg = 0;
 47c:	4881                	li	a7,0
 47e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 482:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 484:	00000517          	auipc	a0,0x0
 488:	52450513          	addi	a0,a0,1316 # 9a8 <digits>
 48c:	883e                	mv	a6,a5
 48e:	2785                	addiw	a5,a5,1
 490:	02c5f733          	remu	a4,a1,a2
 494:	972a                	add	a4,a4,a0
 496:	00074703          	lbu	a4,0(a4)
 49a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 49e:	872e                	mv	a4,a1
 4a0:	02c5d5b3          	divu	a1,a1,a2
 4a4:	0685                	addi	a3,a3,1
 4a6:	fec773e3          	bgeu	a4,a2,48c <printint+0x26>
  if(neg)
 4aa:	00088b63          	beqz	a7,4c0 <printint+0x5a>
    buf[i++] = '-';
 4ae:	fd078793          	addi	a5,a5,-48
 4b2:	97a2                	add	a5,a5,s0
 4b4:	02d00713          	li	a4,45
 4b8:	fee78423          	sb	a4,-24(a5)
 4bc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4c0:	02f05663          	blez	a5,4ec <printint+0x86>
 4c4:	fb840713          	addi	a4,s0,-72
 4c8:	00f704b3          	add	s1,a4,a5
 4cc:	fff70993          	addi	s3,a4,-1
 4d0:	99be                	add	s3,s3,a5
 4d2:	37fd                	addiw	a5,a5,-1
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4dc:	fff4c583          	lbu	a1,-1(s1)
 4e0:	854a                	mv	a0,s2
 4e2:	f67ff0ef          	jal	ra,448 <putc>
  while(--i >= 0)
 4e6:	14fd                	addi	s1,s1,-1
 4e8:	ff349ae3          	bne	s1,s3,4dc <printint+0x76>
}
 4ec:	60a6                	ld	ra,72(sp)
 4ee:	6406                	ld	s0,64(sp)
 4f0:	74e2                	ld	s1,56(sp)
 4f2:	7942                	ld	s2,48(sp)
 4f4:	79a2                	ld	s3,40(sp)
 4f6:	6161                	addi	sp,sp,80
 4f8:	8082                	ret
    x = -xx;
 4fa:	40b005b3          	neg	a1,a1
    neg = 1;
 4fe:	4885                	li	a7,1
    x = -xx;
 500:	bfbd                	j	47e <printint+0x18>

0000000000000502 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 502:	7119                	addi	sp,sp,-128
 504:	fc86                	sd	ra,120(sp)
 506:	f8a2                	sd	s0,112(sp)
 508:	f4a6                	sd	s1,104(sp)
 50a:	f0ca                	sd	s2,96(sp)
 50c:	ecce                	sd	s3,88(sp)
 50e:	e8d2                	sd	s4,80(sp)
 510:	e4d6                	sd	s5,72(sp)
 512:	e0da                	sd	s6,64(sp)
 514:	fc5e                	sd	s7,56(sp)
 516:	f862                	sd	s8,48(sp)
 518:	f466                	sd	s9,40(sp)
 51a:	f06a                	sd	s10,32(sp)
 51c:	ec6e                	sd	s11,24(sp)
 51e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 520:	0005c903          	lbu	s2,0(a1)
 524:	24090c63          	beqz	s2,77c <vprintf+0x27a>
 528:	8b2a                	mv	s6,a0
 52a:	8a2e                	mv	s4,a1
 52c:	8bb2                	mv	s7,a2
  state = 0;
 52e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 530:	4481                	li	s1,0
 532:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 534:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 538:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 53c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 540:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 544:	00000c97          	auipc	s9,0x0
 548:	464c8c93          	addi	s9,s9,1124 # 9a8 <digits>
 54c:	a005                	j	56c <vprintf+0x6a>
        putc(fd, c0);
 54e:	85ca                	mv	a1,s2
 550:	855a                	mv	a0,s6
 552:	ef7ff0ef          	jal	ra,448 <putc>
 556:	a019                	j	55c <vprintf+0x5a>
    } else if(state == '%'){
 558:	03598263          	beq	s3,s5,57c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 55c:	2485                	addiw	s1,s1,1
 55e:	8726                	mv	a4,s1
 560:	009a07b3          	add	a5,s4,s1
 564:	0007c903          	lbu	s2,0(a5)
 568:	20090a63          	beqz	s2,77c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 56c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 570:	fe0994e3          	bnez	s3,558 <vprintf+0x56>
      if(c0 == '%'){
 574:	fd579de3          	bne	a5,s5,54e <vprintf+0x4c>
        state = '%';
 578:	89be                	mv	s3,a5
 57a:	b7cd                	j	55c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 57c:	c3c1                	beqz	a5,5fc <vprintf+0xfa>
 57e:	00ea06b3          	add	a3,s4,a4
 582:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 586:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 588:	c681                	beqz	a3,590 <vprintf+0x8e>
 58a:	9752                	add	a4,a4,s4
 58c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 590:	03878e63          	beq	a5,s8,5cc <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 594:	05a78863          	beq	a5,s10,5e4 <vprintf+0xe2>
      } else if(c0 == 'u'){
 598:	0db78b63          	beq	a5,s11,66e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 59c:	07800713          	li	a4,120
 5a0:	10e78d63          	beq	a5,a4,6ba <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5a4:	07000713          	li	a4,112
 5a8:	14e78263          	beq	a5,a4,6ec <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5ac:	06300713          	li	a4,99
 5b0:	16e78f63          	beq	a5,a4,72e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5b4:	07300713          	li	a4,115
 5b8:	18e78563          	beq	a5,a4,742 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5bc:	05579063          	bne	a5,s5,5fc <vprintf+0xfa>
        putc(fd, '%');
 5c0:	85d6                	mv	a1,s5
 5c2:	855a                	mv	a0,s6
 5c4:	e85ff0ef          	jal	ra,448 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bf49                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4685                	li	a3,1
 5d2:	4629                	li	a2,10
 5d4:	000ba583          	lw	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	e8dff0ef          	jal	ra,466 <printint>
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bfad                	j	55c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5e4:	03868663          	beq	a3,s8,610 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e8:	05a68163          	beq	a3,s10,62a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5ec:	09b68d63          	beq	a3,s11,686 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f0:	03a68f63          	beq	a3,s10,62e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5f4:	07800793          	li	a5,120
 5f8:	0cf68d63          	beq	a3,a5,6d2 <vprintf+0x1d0>
        putc(fd, '%');
 5fc:	85d6                	mv	a1,s5
 5fe:	855a                	mv	a0,s6
 600:	e49ff0ef          	jal	ra,448 <putc>
        putc(fd, c0);
 604:	85ca                	mv	a1,s2
 606:	855a                	mv	a0,s6
 608:	e41ff0ef          	jal	ra,448 <putc>
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b7b9                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 610:	008b8913          	addi	s2,s7,8
 614:	4685                	li	a3,1
 616:	4629                	li	a2,10
 618:	000bb583          	ld	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	e49ff0ef          	jal	ra,466 <printint>
        i += 1;
 622:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 624:	8bca                	mv	s7,s2
      state = 0;
 626:	4981                	li	s3,0
        i += 1;
 628:	bf15                	j	55c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 62a:	03860563          	beq	a2,s8,654 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 62e:	07b60963          	beq	a2,s11,6a0 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 632:	07800793          	li	a5,120
 636:	fcf613e3          	bne	a2,a5,5fc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4681                	li	a3,0
 640:	4641                	li	a2,16
 642:	000bb583          	ld	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	e1fff0ef          	jal	ra,466 <printint>
        i += 2;
 64c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
        i += 2;
 652:	b729                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 654:	008b8913          	addi	s2,s7,8
 658:	4685                	li	a3,1
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	e05ff0ef          	jal	ra,466 <printint>
        i += 2;
 666:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 2;
 66c:	bdc5                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000be583          	lwu	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	debff0ef          	jal	ra,466 <printint>
 680:	8bca                	mv	s7,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	bde1                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 686:	008b8913          	addi	s2,s7,8
 68a:	4681                	li	a3,0
 68c:	4629                	li	a2,10
 68e:	000bb583          	ld	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	dd3ff0ef          	jal	ra,466 <printint>
        i += 1;
 698:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
        i += 1;
 69e:	bd7d                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4629                	li	a2,10
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	db9ff0ef          	jal	ra,466 <printint>
        i += 2;
 6b2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 2;
 6b8:	b555                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ba:	008b8913          	addi	s2,s7,8
 6be:	4681                	li	a3,0
 6c0:	4641                	li	a2,16
 6c2:	000be583          	lwu	a1,0(s7)
 6c6:	855a                	mv	a0,s6
 6c8:	d9fff0ef          	jal	ra,466 <printint>
 6cc:	8bca                	mv	s7,s2
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b571                	j	55c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	4681                	li	a3,0
 6d8:	4641                	li	a2,16
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	d87ff0ef          	jal	ra,466 <printint>
        i += 1;
 6e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
        i += 1;
 6ea:	bd8d                	j	55c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6ec:	008b8793          	addi	a5,s7,8
 6f0:	f8f43423          	sd	a5,-120(s0)
 6f4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6f8:	03000593          	li	a1,48
 6fc:	855a                	mv	a0,s6
 6fe:	d4bff0ef          	jal	ra,448 <putc>
  putc(fd, 'x');
 702:	07800593          	li	a1,120
 706:	855a                	mv	a0,s6
 708:	d41ff0ef          	jal	ra,448 <putc>
 70c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70e:	03c9d793          	srli	a5,s3,0x3c
 712:	97e6                	add	a5,a5,s9
 714:	0007c583          	lbu	a1,0(a5)
 718:	855a                	mv	a0,s6
 71a:	d2fff0ef          	jal	ra,448 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71e:	0992                	slli	s3,s3,0x4
 720:	397d                	addiw	s2,s2,-1
 722:	fe0916e3          	bnez	s2,70e <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 726:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bd05                	j	55c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 72e:	008b8913          	addi	s2,s7,8
 732:	000bc583          	lbu	a1,0(s7)
 736:	855a                	mv	a0,s6
 738:	d11ff0ef          	jal	ra,448 <putc>
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	bd31                	j	55c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 742:	008b8993          	addi	s3,s7,8
 746:	000bb903          	ld	s2,0(s7)
 74a:	00090f63          	beqz	s2,768 <vprintf+0x266>
        for(; *s; s++)
 74e:	00094583          	lbu	a1,0(s2)
 752:	c195                	beqz	a1,776 <vprintf+0x274>
          putc(fd, *s);
 754:	855a                	mv	a0,s6
 756:	cf3ff0ef          	jal	ra,448 <putc>
        for(; *s; s++)
 75a:	0905                	addi	s2,s2,1
 75c:	00094583          	lbu	a1,0(s2)
 760:	f9f5                	bnez	a1,754 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 762:	8bce                	mv	s7,s3
      state = 0;
 764:	4981                	li	s3,0
 766:	bbdd                	j	55c <vprintf+0x5a>
          s = "(null)";
 768:	00000917          	auipc	s2,0x0
 76c:	23890913          	addi	s2,s2,568 # 9a0 <malloc+0x128>
        for(; *s; s++)
 770:	02800593          	li	a1,40
 774:	b7c5                	j	754 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 776:	8bce                	mv	s7,s3
      state = 0;
 778:	4981                	li	s3,0
 77a:	b3cd                	j	55c <vprintf+0x5a>
    }
  }
}
 77c:	70e6                	ld	ra,120(sp)
 77e:	7446                	ld	s0,112(sp)
 780:	74a6                	ld	s1,104(sp)
 782:	7906                	ld	s2,96(sp)
 784:	69e6                	ld	s3,88(sp)
 786:	6a46                	ld	s4,80(sp)
 788:	6aa6                	ld	s5,72(sp)
 78a:	6b06                	ld	s6,64(sp)
 78c:	7be2                	ld	s7,56(sp)
 78e:	7c42                	ld	s8,48(sp)
 790:	7ca2                	ld	s9,40(sp)
 792:	7d02                	ld	s10,32(sp)
 794:	6de2                	ld	s11,24(sp)
 796:	6109                	addi	sp,sp,128
 798:	8082                	ret

000000000000079a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 79a:	715d                	addi	sp,sp,-80
 79c:	ec06                	sd	ra,24(sp)
 79e:	e822                	sd	s0,16(sp)
 7a0:	1000                	addi	s0,sp,32
 7a2:	e010                	sd	a2,0(s0)
 7a4:	e414                	sd	a3,8(s0)
 7a6:	e818                	sd	a4,16(s0)
 7a8:	ec1c                	sd	a5,24(s0)
 7aa:	03043023          	sd	a6,32(s0)
 7ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b6:	8622                	mv	a2,s0
 7b8:	d4bff0ef          	jal	ra,502 <vprintf>
}
 7bc:	60e2                	ld	ra,24(sp)
 7be:	6442                	ld	s0,16(sp)
 7c0:	6161                	addi	sp,sp,80
 7c2:	8082                	ret

00000000000007c4 <printf>:

void
printf(const char *fmt, ...)
{
 7c4:	711d                	addi	sp,sp,-96
 7c6:	ec06                	sd	ra,24(sp)
 7c8:	e822                	sd	s0,16(sp)
 7ca:	1000                	addi	s0,sp,32
 7cc:	e40c                	sd	a1,8(s0)
 7ce:	e810                	sd	a2,16(s0)
 7d0:	ec14                	sd	a3,24(s0)
 7d2:	f018                	sd	a4,32(s0)
 7d4:	f41c                	sd	a5,40(s0)
 7d6:	03043823          	sd	a6,48(s0)
 7da:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7de:	00840613          	addi	a2,s0,8
 7e2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e6:	85aa                	mv	a1,a0
 7e8:	4505                	li	a0,1
 7ea:	d19ff0ef          	jal	ra,502 <vprintf>
}
 7ee:	60e2                	ld	ra,24(sp)
 7f0:	6442                	ld	s0,16(sp)
 7f2:	6125                	addi	sp,sp,96
 7f4:	8082                	ret

00000000000007f6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f6:	1141                	addi	sp,sp,-16
 7f8:	e422                	sd	s0,8(sp)
 7fa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 800:	00001797          	auipc	a5,0x1
 804:	8007b783          	ld	a5,-2048(a5) # 1000 <freep>
 808:	a02d                	j	832 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 80a:	4618                	lw	a4,8(a2)
 80c:	9f2d                	addw	a4,a4,a1
 80e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 812:	6398                	ld	a4,0(a5)
 814:	6310                	ld	a2,0(a4)
 816:	a83d                	j	854 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 818:	ff852703          	lw	a4,-8(a0)
 81c:	9f31                	addw	a4,a4,a2
 81e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 820:	ff053683          	ld	a3,-16(a0)
 824:	a091                	j	868 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 826:	6398                	ld	a4,0(a5)
 828:	00e7e463          	bltu	a5,a4,830 <free+0x3a>
 82c:	00e6ea63          	bltu	a3,a4,840 <free+0x4a>
{
 830:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 832:	fed7fae3          	bgeu	a5,a3,826 <free+0x30>
 836:	6398                	ld	a4,0(a5)
 838:	00e6e463          	bltu	a3,a4,840 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83c:	fee7eae3          	bltu	a5,a4,830 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 840:	ff852583          	lw	a1,-8(a0)
 844:	6390                	ld	a2,0(a5)
 846:	02059813          	slli	a6,a1,0x20
 84a:	01c85713          	srli	a4,a6,0x1c
 84e:	9736                	add	a4,a4,a3
 850:	fae60de3          	beq	a2,a4,80a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 854:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 858:	4790                	lw	a2,8(a5)
 85a:	02061593          	slli	a1,a2,0x20
 85e:	01c5d713          	srli	a4,a1,0x1c
 862:	973e                	add	a4,a4,a5
 864:	fae68ae3          	beq	a3,a4,818 <free+0x22>
    p->s.ptr = bp->s.ptr;
 868:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 86a:	00000717          	auipc	a4,0x0
 86e:	78f73b23          	sd	a5,1942(a4) # 1000 <freep>
}
 872:	6422                	ld	s0,8(sp)
 874:	0141                	addi	sp,sp,16
 876:	8082                	ret

0000000000000878 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 878:	7139                	addi	sp,sp,-64
 87a:	fc06                	sd	ra,56(sp)
 87c:	f822                	sd	s0,48(sp)
 87e:	f426                	sd	s1,40(sp)
 880:	f04a                	sd	s2,32(sp)
 882:	ec4e                	sd	s3,24(sp)
 884:	e852                	sd	s4,16(sp)
 886:	e456                	sd	s5,8(sp)
 888:	e05a                	sd	s6,0(sp)
 88a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88c:	02051493          	slli	s1,a0,0x20
 890:	9081                	srli	s1,s1,0x20
 892:	04bd                	addi	s1,s1,15
 894:	8091                	srli	s1,s1,0x4
 896:	0014899b          	addiw	s3,s1,1
 89a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 89c:	00000517          	auipc	a0,0x0
 8a0:	76453503          	ld	a0,1892(a0) # 1000 <freep>
 8a4:	c515                	beqz	a0,8d0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a8:	4798                	lw	a4,8(a5)
 8aa:	02977f63          	bgeu	a4,s1,8e8 <malloc+0x70>
 8ae:	8a4e                	mv	s4,s3
 8b0:	0009871b          	sext.w	a4,s3
 8b4:	6685                	lui	a3,0x1
 8b6:	00d77363          	bgeu	a4,a3,8bc <malloc+0x44>
 8ba:	6a05                	lui	s4,0x1
 8bc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c4:	00000917          	auipc	s2,0x0
 8c8:	73c90913          	addi	s2,s2,1852 # 1000 <freep>
  if(p == SBRK_ERROR)
 8cc:	5afd                	li	s5,-1
 8ce:	a885                	j	93e <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 8d0:	00000797          	auipc	a5,0x0
 8d4:	74078793          	addi	a5,a5,1856 # 1010 <base>
 8d8:	00000717          	auipc	a4,0x0
 8dc:	72f73423          	sd	a5,1832(a4) # 1000 <freep>
 8e0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e6:	b7e1                	j	8ae <malloc+0x36>
      if(p->s.size == nunits)
 8e8:	02e48c63          	beq	s1,a4,920 <malloc+0xa8>
        p->s.size -= nunits;
 8ec:	4137073b          	subw	a4,a4,s3
 8f0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f2:	02071693          	slli	a3,a4,0x20
 8f6:	01c6d713          	srli	a4,a3,0x1c
 8fa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8fc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 900:	00000717          	auipc	a4,0x0
 904:	70a73023          	sd	a0,1792(a4) # 1000 <freep>
      return (void*)(p + 1);
 908:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 90c:	70e2                	ld	ra,56(sp)
 90e:	7442                	ld	s0,48(sp)
 910:	74a2                	ld	s1,40(sp)
 912:	7902                	ld	s2,32(sp)
 914:	69e2                	ld	s3,24(sp)
 916:	6a42                	ld	s4,16(sp)
 918:	6aa2                	ld	s5,8(sp)
 91a:	6b02                	ld	s6,0(sp)
 91c:	6121                	addi	sp,sp,64
 91e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 920:	6398                	ld	a4,0(a5)
 922:	e118                	sd	a4,0(a0)
 924:	bff1                	j	900 <malloc+0x88>
  hp->s.size = nu;
 926:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 92a:	0541                	addi	a0,a0,16
 92c:	ecbff0ef          	jal	ra,7f6 <free>
  return freep;
 930:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 934:	dd61                	beqz	a0,90c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 936:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 938:	4798                	lw	a4,8(a5)
 93a:	fa9777e3          	bgeu	a4,s1,8e8 <malloc+0x70>
    if(p == freep)
 93e:	00093703          	ld	a4,0(s2)
 942:	853e                	mv	a0,a5
 944:	fef719e3          	bne	a4,a5,936 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 948:	8552                	mv	a0,s4
 94a:	9f3ff0ef          	jal	ra,33c <sbrk>
  if(p == SBRK_ERROR)
 94e:	fd551ce3          	bne	a0,s5,926 <malloc+0xae>
        return 0;
 952:	4501                	li	a0,0
 954:	bf65                	j	90c <malloc+0x94>
