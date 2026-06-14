
user/_shm_sem_pc:     file format elf64-littleriscv


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
  1a:	3f8000ef          	jal	ra,412 <mmap>
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
  2c:	406000ef          	jal	ra,432 <sem_open>
  30:	00054963          	bltz	a0,42 <main+0x42>
  34:	4581                	li	a1,0
  36:	06500513          	li	a0,101
  3a:	3f8000ef          	jal	ra,432 <sem_open>
  3e:	02055463          	bgez	a0,66 <main+0x66>
    printf("sem_open fail\n");
  42:	00001517          	auipc	a0,0x1
  46:	93e50513          	addi	a0,a0,-1730 # 980 <malloc+0xf8>
  4a:	784000ef          	jal	ra,7ce <printf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	322000ef          	jal	ra,372 <exit>
    printf("mmap fail\n");
  54:	00001517          	auipc	a0,0x1
  58:	91c50513          	addi	a0,a0,-1764 # 970 <malloc+0xe8>
  5c:	772000ef          	jal	ra,7ce <printf>
    exit(1);
  60:	4505                	li	a0,1
  62:	310000ef          	jal	ra,372 <exit>
  }

  int pid = fork();
  66:	304000ef          	jal	ra,36a <fork>
  if(pid == 0){
  6a:	e905                	bnez	a0,9a <main+0x9a>
  6c:	44d1                	li	s1,20
    // consumer
    for(int i=1;i<=20;i++){
      sem_wait(sem_full);
      int v = p->x;
      printf("C got %d\n", v);
  6e:	00001997          	auipc	s3,0x1
  72:	92298993          	addi	s3,s3,-1758 # 990 <malloc+0x108>
      sem_wait(sem_full);
  76:	06500513          	li	a0,101
  7a:	3c0000ef          	jal	ra,43a <sem_wait>
      printf("C got %d\n", v);
  7e:	00092583          	lw	a1,0(s2)
  82:	854e                	mv	a0,s3
  84:	74a000ef          	jal	ra,7ce <printf>
      sem_post(sem_empty);
  88:	06400513          	li	a0,100
  8c:	3b6000ef          	jal	ra,442 <sem_post>
    for(int i=1;i<=20;i++){
  90:	34fd                	addiw	s1,s1,-1
  92:	f0f5                	bnez	s1,76 <main+0x76>
    }
    exit(0);
  94:	4501                	li	a0,0
  96:	2dc000ef          	jal	ra,372 <exit>
  }

  // producer
  for(int i=1;i<=20;i++){
  9a:	4485                	li	s1,1
    sem_wait(sem_empty);
    p->x = i;
    printf("P put %d\n", i);
  9c:	00001a17          	auipc	s4,0x1
  a0:	904a0a13          	addi	s4,s4,-1788 # 9a0 <malloc+0x118>
  for(int i=1;i<=20;i++){
  a4:	49d5                	li	s3,21
    sem_wait(sem_empty);
  a6:	06400513          	li	a0,100
  aa:	390000ef          	jal	ra,43a <sem_wait>
    p->x = i;
  ae:	00992023          	sw	s1,0(s2)
    printf("P put %d\n", i);
  b2:	85a6                	mv	a1,s1
  b4:	8552                	mv	a0,s4
  b6:	718000ef          	jal	ra,7ce <printf>
    sem_post(sem_full);
  ba:	06500513          	li	a0,101
  be:	384000ef          	jal	ra,442 <sem_post>
  for(int i=1;i<=20;i++){
  c2:	2485                	addiw	s1,s1,1
  c4:	ff3491e3          	bne	s1,s3,a6 <main+0xa6>
  }

  wait(0);
  c8:	4501                	li	a0,0
  ca:	2b0000ef          	jal	ra,37a <wait>
  munmap((char*)p, 4096);
  ce:	6585                	lui	a1,0x1
  d0:	854a                	mv	a0,s2
  d2:	348000ef          	jal	ra,41a <munmap>
  exit(0);
  d6:	4501                	li	a0,0
  d8:	29a000ef          	jal	ra,372 <exit>

00000000000000dc <start>:
 *   argv - 命令行参数数组
 */

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
  e8:	28a000ef          	jal	ra,372 <exit>

00000000000000ec <strcpy>:
 *   目标字符串s的指针
 */

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
  f4:	0585                	addi	a1,a1,1
  f6:	0785                	addi	a5,a5,1
  f8:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x647>
  fc:	fee78fa3          	sb	a4,-1(a5)
 100:	fb75                	bnez	a4,f4 <strcpy+0x8>
    ;
  return os;
}
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strcmp>:
 *   负数 - p小于q
 */

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
 *   字符串s的长度
 */

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
 *   目标内存区域dst的指针
 */

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
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

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
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

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
 1d6:	1b4000ef          	jal	ra,38a <read>
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
 *   -1 - 失败
 */

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
 224:	18e000ef          	jal	ra,3b2 <open>
  if(fd < 0)
 228:	02054163          	bltz	a0,24a <stat+0x36>
 22c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 22e:	85ca                	mv	a1,s2
 230:	19a000ef          	jal	ra,3ca <fstat>
 234:	892a                	mv	s2,a0
  close(fd);
 236:	8526                	mv	a0,s1
 238:	162000ef          	jal	ra,39a <close>
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
 *   转换后的整数
 */

int
atoi(const char *s)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 254:	00054603          	lbu	a2,0(a0)
 258:	fd06079b          	addiw	a5,a2,-48
 25c:	0ff7f793          	andi	a5,a5,255
 260:	4725                	li	a4,9
 262:	02f76963          	bltu	a4,a5,294 <atoi+0x46>
 266:	86aa                	mv	a3,a0
  n = 0;
 268:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 26a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 26c:	0685                	addi	a3,a3,1
 26e:	0025179b          	slliw	a5,a0,0x2
 272:	9fa9                	addw	a5,a5,a0
 274:	0017979b          	slliw	a5,a5,0x1
 278:	9fb1                	addw	a5,a5,a2
 27a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27e:	0006c603          	lbu	a2,0(a3)
 282:	fd06071b          	addiw	a4,a2,-48
 286:	0ff77713          	andi	a4,a4,255
 28a:	fee5f1e3          	bgeu	a1,a4,26c <atoi+0x1e>
  return n;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  n = 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <atoi+0x40>

0000000000000298 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29e:	02b57463          	bgeu	a0,a1,2c6 <memmove+0x2e>
    while(n-- > 0)
 2a2:	00c05f63          	blez	a2,2c0 <memmove+0x28>
 2a6:	1602                	slli	a2,a2,0x20
 2a8:	9201                	srli	a2,a2,0x20
 2aa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b0:	0585                	addi	a1,a1,1
 2b2:	0705                	addi	a4,a4,1
 2b4:	fff5c683          	lbu	a3,-1(a1)
 2b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2bc:	fee79ae3          	bne	a5,a4,2b0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
    dst += n;
 2c6:	00c50733          	add	a4,a0,a2
    src += n;
 2ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2cc:	fec05ae3          	blez	a2,2c0 <memmove+0x28>
 2d0:	fff6079b          	addiw	a5,a2,-1
 2d4:	1782                	slli	a5,a5,0x20
 2d6:	9381                	srli	a5,a5,0x20
 2d8:	fff7c793          	not	a5,a5
 2dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2de:	15fd                	addi	a1,a1,-1
 2e0:	177d                	addi	a4,a4,-1
 2e2:	0005c683          	lbu	a3,0(a1)
 2e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ea:	fee79ae3          	bne	a5,a4,2de <memmove+0x46>
 2ee:	bfc9                	j	2c0 <memmove+0x28>

00000000000002f0 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f6:	ca05                	beqz	a2,326 <memcmp+0x36>
 2f8:	fff6069b          	addiw	a3,a2,-1
 2fc:	1682                	slli	a3,a3,0x20
 2fe:	9281                	srli	a3,a3,0x20
 300:	0685                	addi	a3,a3,1
 302:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 304:	00054783          	lbu	a5,0(a0)
 308:	0005c703          	lbu	a4,0(a1)
 30c:	00e79863          	bne	a5,a4,31c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 310:	0505                	addi	a0,a0,1
    p2++;
 312:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 314:	fed518e3          	bne	a0,a3,304 <memcmp+0x14>
  }
  return 0;
 318:	4501                	li	a0,0
 31a:	a019                	j	320 <memcmp+0x30>
      return *p1 - *p2;
 31c:	40e7853b          	subw	a0,a5,a4
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  return 0;
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <memcmp+0x30>

000000000000032a <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 332:	f67ff0ef          	jal	ra,298 <memmove>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 346:	4585                	li	a1,1
 348:	0b2000ef          	jal	ra,3fa <sys_sbrk>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 35c:	4589                	li	a1,2
 35e:	09c000ef          	jal	ra,3fa <sys_sbrk>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 36a:	4885                	li	a7,1
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exit>:
.global exit
exit:
 li a7, SYS_exit
 372:	4889                	li	a7,2
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <wait>:
.global wait
wait:
 li a7, SYS_wait
 37a:	488d                	li	a7,3
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 382:	4891                	li	a7,4
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <read>:
.global read
read:
 li a7, SYS_read
 38a:	4895                	li	a7,5
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <write>:
.global write
write:
 li a7, SYS_write
 392:	48c1                	li	a7,16
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <close>:
.global close
close:
 li a7, SYS_close
 39a:	48d5                	li	a7,21
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a2:	4899                	li	a7,6
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 3aa:	489d                	li	a7,7
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <open>:
.global open
open:
 li a7, SYS_open
 3b2:	48bd                	li	a7,15
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ba:	48c5                	li	a7,17
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c2:	48c9                	li	a7,18
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ca:	48a1                	li	a7,8
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <link>:
.global link
link:
 li a7, SYS_link
 3d2:	48cd                	li	a7,19
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3da:	48d1                	li	a7,20
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e2:	48a5                	li	a7,9
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ea:	48a9                	li	a7,10
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f2:	48ad                	li	a7,11
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3fa:	48b1                	li	a7,12
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <pause>:
.global pause
pause:
 li a7, SYS_pause
 402:	48b5                	li	a7,13
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 40a:	48b9                	li	a7,14
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 412:	48d9                	li	a7,22
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 41a:	48dd                	li	a7,23
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 422:	48e1                	li	a7,24
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 42a:	48e5                	li	a7,25
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 432:	48e9                	li	a7,26
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 43a:	48ed                	li	a7,27
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 442:	48f1                	li	a7,28
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 44a:	48f5                	li	a7,29
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 452:	1101                	addi	sp,sp,-32
 454:	ec06                	sd	ra,24(sp)
 456:	e822                	sd	s0,16(sp)
 458:	1000                	addi	s0,sp,32
 45a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 45e:	4605                	li	a2,1
 460:	fef40593          	addi	a1,s0,-17
 464:	f2fff0ef          	jal	ra,392 <write>
}
 468:	60e2                	ld	ra,24(sp)
 46a:	6442                	ld	s0,16(sp)
 46c:	6105                	addi	sp,sp,32
 46e:	8082                	ret

0000000000000470 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 470:	715d                	addi	sp,sp,-80
 472:	e486                	sd	ra,72(sp)
 474:	e0a2                	sd	s0,64(sp)
 476:	fc26                	sd	s1,56(sp)
 478:	f84a                	sd	s2,48(sp)
 47a:	f44e                	sd	s3,40(sp)
 47c:	0880                	addi	s0,sp,80
 47e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 480:	c299                	beqz	a3,486 <printint+0x16>
 482:	0805c163          	bltz	a1,504 <printint+0x94>
  neg = 0;
 486:	4881                	li	a7,0
 488:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 48c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 48e:	00000517          	auipc	a0,0x0
 492:	52a50513          	addi	a0,a0,1322 # 9b8 <digits>
 496:	883e                	mv	a6,a5
 498:	2785                	addiw	a5,a5,1
 49a:	02c5f733          	remu	a4,a1,a2
 49e:	972a                	add	a4,a4,a0
 4a0:	00074703          	lbu	a4,0(a4)
 4a4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4a8:	872e                	mv	a4,a1
 4aa:	02c5d5b3          	divu	a1,a1,a2
 4ae:	0685                	addi	a3,a3,1
 4b0:	fec773e3          	bgeu	a4,a2,496 <printint+0x26>
  if(neg)
 4b4:	00088b63          	beqz	a7,4ca <printint+0x5a>
    buf[i++] = '-';
 4b8:	fd040713          	addi	a4,s0,-48
 4bc:	97ba                	add	a5,a5,a4
 4be:	02d00713          	li	a4,45
 4c2:	fee78423          	sb	a4,-24(a5)
 4c6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ca:	02f05663          	blez	a5,4f6 <printint+0x86>
 4ce:	fb840713          	addi	a4,s0,-72
 4d2:	00f704b3          	add	s1,a4,a5
 4d6:	fff70993          	addi	s3,a4,-1
 4da:	99be                	add	s3,s3,a5
 4dc:	37fd                	addiw	a5,a5,-1
 4de:	1782                	slli	a5,a5,0x20
 4e0:	9381                	srli	a5,a5,0x20
 4e2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4e6:	fff4c583          	lbu	a1,-1(s1)
 4ea:	854a                	mv	a0,s2
 4ec:	f67ff0ef          	jal	ra,452 <putc>
  while(--i >= 0)
 4f0:	14fd                	addi	s1,s1,-1
 4f2:	ff349ae3          	bne	s1,s3,4e6 <printint+0x76>
}
 4f6:	60a6                	ld	ra,72(sp)
 4f8:	6406                	ld	s0,64(sp)
 4fa:	74e2                	ld	s1,56(sp)
 4fc:	7942                	ld	s2,48(sp)
 4fe:	79a2                	ld	s3,40(sp)
 500:	6161                	addi	sp,sp,80
 502:	8082                	ret
    x = -xx;
 504:	40b005b3          	neg	a1,a1
    neg = 1;
 508:	4885                	li	a7,1
    x = -xx;
 50a:	bfbd                	j	488 <printint+0x18>

000000000000050c <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 50c:	7119                	addi	sp,sp,-128
 50e:	fc86                	sd	ra,120(sp)
 510:	f8a2                	sd	s0,112(sp)
 512:	f4a6                	sd	s1,104(sp)
 514:	f0ca                	sd	s2,96(sp)
 516:	ecce                	sd	s3,88(sp)
 518:	e8d2                	sd	s4,80(sp)
 51a:	e4d6                	sd	s5,72(sp)
 51c:	e0da                	sd	s6,64(sp)
 51e:	fc5e                	sd	s7,56(sp)
 520:	f862                	sd	s8,48(sp)
 522:	f466                	sd	s9,40(sp)
 524:	f06a                	sd	s10,32(sp)
 526:	ec6e                	sd	s11,24(sp)
 528:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52a:	0005c903          	lbu	s2,0(a1)
 52e:	24090c63          	beqz	s2,786 <vprintf+0x27a>
 532:	8b2a                	mv	s6,a0
 534:	8a2e                	mv	s4,a1
 536:	8bb2                	mv	s7,a2
  state = 0;
 538:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 53a:	4481                	li	s1,0
 53c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 53e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 542:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 546:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 54a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54e:	00000c97          	auipc	s9,0x0
 552:	46ac8c93          	addi	s9,s9,1130 # 9b8 <digits>
 556:	a005                	j	576 <vprintf+0x6a>
        putc(fd, c0);
 558:	85ca                	mv	a1,s2
 55a:	855a                	mv	a0,s6
 55c:	ef7ff0ef          	jal	ra,452 <putc>
 560:	a019                	j	566 <vprintf+0x5a>
    } else if(state == '%'){
 562:	03598263          	beq	s3,s5,586 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 566:	2485                	addiw	s1,s1,1
 568:	8726                	mv	a4,s1
 56a:	009a07b3          	add	a5,s4,s1
 56e:	0007c903          	lbu	s2,0(a5)
 572:	20090a63          	beqz	s2,786 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 576:	0009079b          	sext.w	a5,s2
    if(state == 0){
 57a:	fe0994e3          	bnez	s3,562 <vprintf+0x56>
      if(c0 == '%'){
 57e:	fd579de3          	bne	a5,s5,558 <vprintf+0x4c>
        state = '%';
 582:	89be                	mv	s3,a5
 584:	b7cd                	j	566 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 586:	c3c1                	beqz	a5,606 <vprintf+0xfa>
 588:	00ea06b3          	add	a3,s4,a4
 58c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 590:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 592:	c681                	beqz	a3,59a <vprintf+0x8e>
 594:	9752                	add	a4,a4,s4
 596:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 59a:	03878e63          	beq	a5,s8,5d6 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 59e:	05a78863          	beq	a5,s10,5ee <vprintf+0xe2>
      } else if(c0 == 'u'){
 5a2:	0db78b63          	beq	a5,s11,678 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a6:	07800713          	li	a4,120
 5aa:	10e78d63          	beq	a5,a4,6c4 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ae:	07000713          	li	a4,112
 5b2:	14e78263          	beq	a5,a4,6f6 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5b6:	06300713          	li	a4,99
 5ba:	16e78f63          	beq	a5,a4,738 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5be:	07300713          	li	a4,115
 5c2:	18e78563          	beq	a5,a4,74c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5c6:	05579063          	bne	a5,s5,606 <vprintf+0xfa>
        putc(fd, '%');
 5ca:	85d6                	mv	a1,s5
 5cc:	855a                	mv	a0,s6
 5ce:	e85ff0ef          	jal	ra,452 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	bf49                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4685                	li	a3,1
 5dc:	4629                	li	a2,10
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e8dff0ef          	jal	ra,470 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bfad                	j	566 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ee:	03868663          	beq	a3,s8,61a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f2:	05a68163          	beq	a3,s10,634 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5f6:	09b68d63          	beq	a3,s11,690 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5fa:	03a68f63          	beq	a3,s10,638 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5fe:	07800793          	li	a5,120
 602:	0cf68d63          	beq	a3,a5,6dc <vprintf+0x1d0>
        putc(fd, '%');
 606:	85d6                	mv	a1,s5
 608:	855a                	mv	a0,s6
 60a:	e49ff0ef          	jal	ra,452 <putc>
        putc(fd, c0);
 60e:	85ca                	mv	a1,s2
 610:	855a                	mv	a0,s6
 612:	e41ff0ef          	jal	ra,452 <putc>
      state = 0;
 616:	4981                	li	s3,0
 618:	b7b9                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4685                	li	a3,1
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	e49ff0ef          	jal	ra,470 <printint>
        i += 1;
 62c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 1;
 632:	bf15                	j	566 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 634:	03860563          	beq	a2,s8,65e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 638:	07b60963          	beq	a2,s11,6aa <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 63c:	07800793          	li	a5,120
 640:	fcf613e3          	bne	a2,a5,606 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 644:	008b8913          	addi	s2,s7,8
 648:	4681                	li	a3,0
 64a:	4641                	li	a2,16
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	e1fff0ef          	jal	ra,470 <printint>
        i += 2;
 656:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
        i += 2;
 65c:	b729                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65e:	008b8913          	addi	s2,s7,8
 662:	4685                	li	a3,1
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	e05ff0ef          	jal	ra,470 <printint>
        i += 2;
 670:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
        i += 2;
 676:	bdc5                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4629                	li	a2,10
 680:	000be583          	lwu	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	debff0ef          	jal	ra,470 <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bde1                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 690:	008b8913          	addi	s2,s7,8
 694:	4681                	li	a3,0
 696:	4629                	li	a2,10
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	dd3ff0ef          	jal	ra,470 <printint>
        i += 1;
 6a2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
        i += 1;
 6a8:	bd7d                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4629                	li	a2,10
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	db9ff0ef          	jal	ra,470 <printint>
        i += 2;
 6bc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
        i += 2;
 6c2:	b555                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4641                	li	a2,16
 6cc:	000be583          	lwu	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	d9fff0ef          	jal	ra,470 <printint>
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b571                	j	566 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	4681                	li	a3,0
 6e2:	4641                	li	a2,16
 6e4:	000bb583          	ld	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	d87ff0ef          	jal	ra,470 <printint>
        i += 1;
 6ee:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
        i += 1;
 6f4:	bd8d                	j	566 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6f6:	008b8793          	addi	a5,s7,8
 6fa:	f8f43423          	sd	a5,-120(s0)
 6fe:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 702:	03000593          	li	a1,48
 706:	855a                	mv	a0,s6
 708:	d4bff0ef          	jal	ra,452 <putc>
  putc(fd, 'x');
 70c:	07800593          	li	a1,120
 710:	855a                	mv	a0,s6
 712:	d41ff0ef          	jal	ra,452 <putc>
 716:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 718:	03c9d793          	srli	a5,s3,0x3c
 71c:	97e6                	add	a5,a5,s9
 71e:	0007c583          	lbu	a1,0(a5)
 722:	855a                	mv	a0,s6
 724:	d2fff0ef          	jal	ra,452 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 728:	0992                	slli	s3,s3,0x4
 72a:	397d                	addiw	s2,s2,-1
 72c:	fe0916e3          	bnez	s2,718 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 730:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 734:	4981                	li	s3,0
 736:	bd05                	j	566 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 738:	008b8913          	addi	s2,s7,8
 73c:	000bc583          	lbu	a1,0(s7)
 740:	855a                	mv	a0,s6
 742:	d11ff0ef          	jal	ra,452 <putc>
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
 74a:	bd31                	j	566 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 74c:	008b8993          	addi	s3,s7,8
 750:	000bb903          	ld	s2,0(s7)
 754:	00090f63          	beqz	s2,772 <vprintf+0x266>
        for(; *s; s++)
 758:	00094583          	lbu	a1,0(s2)
 75c:	c195                	beqz	a1,780 <vprintf+0x274>
          putc(fd, *s);
 75e:	855a                	mv	a0,s6
 760:	cf3ff0ef          	jal	ra,452 <putc>
        for(; *s; s++)
 764:	0905                	addi	s2,s2,1
 766:	00094583          	lbu	a1,0(s2)
 76a:	f9f5                	bnez	a1,75e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 76c:	8bce                	mv	s7,s3
      state = 0;
 76e:	4981                	li	s3,0
 770:	bbdd                	j	566 <vprintf+0x5a>
          s = "(null)";
 772:	00000917          	auipc	s2,0x0
 776:	23e90913          	addi	s2,s2,574 # 9b0 <malloc+0x128>
        for(; *s; s++)
 77a:	02800593          	li	a1,40
 77e:	b7c5                	j	75e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 780:	8bce                	mv	s7,s3
      state = 0;
 782:	4981                	li	s3,0
 784:	b3cd                	j	566 <vprintf+0x5a>
    }
  }
}
 786:	70e6                	ld	ra,120(sp)
 788:	7446                	ld	s0,112(sp)
 78a:	74a6                	ld	s1,104(sp)
 78c:	7906                	ld	s2,96(sp)
 78e:	69e6                	ld	s3,88(sp)
 790:	6a46                	ld	s4,80(sp)
 792:	6aa6                	ld	s5,72(sp)
 794:	6b06                	ld	s6,64(sp)
 796:	7be2                	ld	s7,56(sp)
 798:	7c42                	ld	s8,48(sp)
 79a:	7ca2                	ld	s9,40(sp)
 79c:	7d02                	ld	s10,32(sp)
 79e:	6de2                	ld	s11,24(sp)
 7a0:	6109                	addi	sp,sp,128
 7a2:	8082                	ret

00000000000007a4 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 7a4:	715d                	addi	sp,sp,-80
 7a6:	ec06                	sd	ra,24(sp)
 7a8:	e822                	sd	s0,16(sp)
 7aa:	1000                	addi	s0,sp,32
 7ac:	e010                	sd	a2,0(s0)
 7ae:	e414                	sd	a3,8(s0)
 7b0:	e818                	sd	a4,16(s0)
 7b2:	ec1c                	sd	a5,24(s0)
 7b4:	03043023          	sd	a6,32(s0)
 7b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c0:	8622                	mv	a2,s0
 7c2:	d4bff0ef          	jal	ra,50c <vprintf>
}
 7c6:	60e2                	ld	ra,24(sp)
 7c8:	6442                	ld	s0,16(sp)
 7ca:	6161                	addi	sp,sp,80
 7cc:	8082                	ret

00000000000007ce <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 7ce:	711d                	addi	sp,sp,-96
 7d0:	ec06                	sd	ra,24(sp)
 7d2:	e822                	sd	s0,16(sp)
 7d4:	1000                	addi	s0,sp,32
 7d6:	e40c                	sd	a1,8(s0)
 7d8:	e810                	sd	a2,16(s0)
 7da:	ec14                	sd	a3,24(s0)
 7dc:	f018                	sd	a4,32(s0)
 7de:	f41c                	sd	a5,40(s0)
 7e0:	03043823          	sd	a6,48(s0)
 7e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e8:	00840613          	addi	a2,s0,8
 7ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f0:	85aa                	mv	a1,a0
 7f2:	4505                	li	a0,1
 7f4:	d19ff0ef          	jal	ra,50c <vprintf>
}
 7f8:	60e2                	ld	ra,24(sp)
 7fa:	6442                	ld	s0,16(sp)
 7fc:	6125                	addi	sp,sp,96
 7fe:	8082                	ret

0000000000000800 <free>:
 *   无
 */

void
free(void *ap)
{
 800:	1141                	addi	sp,sp,-16
 802:	e422                	sd	s0,8(sp)
 804:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 806:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80a:	00000797          	auipc	a5,0x0
 80e:	7f67b783          	ld	a5,2038(a5) # 1000 <freep>
 812:	a805                	j	842 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 814:	4618                	lw	a4,8(a2)
 816:	9db9                	addw	a1,a1,a4
 818:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 81c:	6398                	ld	a4,0(a5)
 81e:	6318                	ld	a4,0(a4)
 820:	fee53823          	sd	a4,-16(a0)
 824:	a091                	j	868 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 826:	ff852703          	lw	a4,-8(a0)
 82a:	9e39                	addw	a2,a2,a4
 82c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 82e:	ff053703          	ld	a4,-16(a0)
 832:	e398                	sd	a4,0(a5)
 834:	a099                	j	87a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	6398                	ld	a4,0(a5)
 838:	00e7e463          	bltu	a5,a4,840 <free+0x40>
 83c:	00e6ea63          	bltu	a3,a4,850 <free+0x50>
{
 840:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 842:	fed7fae3          	bgeu	a5,a3,836 <free+0x36>
 846:	6398                	ld	a4,0(a5)
 848:	00e6e463          	bltu	a3,a4,850 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84c:	fee7eae3          	bltu	a5,a4,840 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 850:	ff852583          	lw	a1,-8(a0)
 854:	6390                	ld	a2,0(a5)
 856:	02059713          	slli	a4,a1,0x20
 85a:	9301                	srli	a4,a4,0x20
 85c:	0712                	slli	a4,a4,0x4
 85e:	9736                	add	a4,a4,a3
 860:	fae60ae3          	beq	a2,a4,814 <free+0x14>
    bp->s.ptr = p->s.ptr;
 864:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 868:	4790                	lw	a2,8(a5)
 86a:	02061713          	slli	a4,a2,0x20
 86e:	9301                	srli	a4,a4,0x20
 870:	0712                	slli	a4,a4,0x4
 872:	973e                	add	a4,a4,a5
 874:	fae689e3          	beq	a3,a4,826 <free+0x26>
  } else
    p->s.ptr = bp;
 878:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 87a:	00000717          	auipc	a4,0x0
 87e:	78f73323          	sd	a5,1926(a4) # 1000 <freep>
}
 882:	6422                	ld	s0,8(sp)
 884:	0141                	addi	sp,sp,16
 886:	8082                	ret

0000000000000888 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 888:	7139                	addi	sp,sp,-64
 88a:	fc06                	sd	ra,56(sp)
 88c:	f822                	sd	s0,48(sp)
 88e:	f426                	sd	s1,40(sp)
 890:	f04a                	sd	s2,32(sp)
 892:	ec4e                	sd	s3,24(sp)
 894:	e852                	sd	s4,16(sp)
 896:	e456                	sd	s5,8(sp)
 898:	e05a                	sd	s6,0(sp)
 89a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89c:	02051493          	slli	s1,a0,0x20
 8a0:	9081                	srli	s1,s1,0x20
 8a2:	04bd                	addi	s1,s1,15
 8a4:	8091                	srli	s1,s1,0x4
 8a6:	0014899b          	addiw	s3,s1,1
 8aa:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 8ac:	00000517          	auipc	a0,0x0
 8b0:	75453503          	ld	a0,1876(a0) # 1000 <freep>
 8b4:	c515                	beqz	a0,8e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8b8:	4798                	lw	a4,8(a5)
 8ba:	02977f63          	bgeu	a4,s1,8f8 <malloc+0x70>
 8be:	8a4e                	mv	s4,s3
 8c0:	0009871b          	sext.w	a4,s3
 8c4:	6685                	lui	a3,0x1
 8c6:	00d77363          	bgeu	a4,a3,8cc <malloc+0x44>
 8ca:	6a05                	lui	s4,0x1
 8cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8d0:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8d4:	00000917          	auipc	s2,0x0
 8d8:	72c90913          	addi	s2,s2,1836 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8dc:	5afd                	li	s5,-1
 8de:	a0bd                	j	94c <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8e0:	00000797          	auipc	a5,0x0
 8e4:	73078793          	addi	a5,a5,1840 # 1010 <base>
 8e8:	00000717          	auipc	a4,0x0
 8ec:	70f73c23          	sd	a5,1816(a4) # 1000 <freep>
 8f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8f6:	b7e1                	j	8be <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8f8:	02e48b63          	beq	s1,a4,92e <malloc+0xa6>
        p->s.size -= nunits;
 8fc:	4137073b          	subw	a4,a4,s3
 900:	c798                	sw	a4,8(a5)
        p += p->s.size;
 902:	1702                	slli	a4,a4,0x20
 904:	9301                	srli	a4,a4,0x20
 906:	0712                	slli	a4,a4,0x4
 908:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90a:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 90e:	00000717          	auipc	a4,0x0
 912:	6ea73923          	sd	a0,1778(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 916:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 91a:	70e2                	ld	ra,56(sp)
 91c:	7442                	ld	s0,48(sp)
 91e:	74a2                	ld	s1,40(sp)
 920:	7902                	ld	s2,32(sp)
 922:	69e2                	ld	s3,24(sp)
 924:	6a42                	ld	s4,16(sp)
 926:	6aa2                	ld	s5,8(sp)
 928:	6b02                	ld	s6,0(sp)
 92a:	6121                	addi	sp,sp,64
 92c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 92e:	6398                	ld	a4,0(a5)
 930:	e118                	sd	a4,0(a0)
 932:	bff1                	j	90e <malloc+0x86>
  hp->s.size = nu;
 934:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 938:	0541                	addi	a0,a0,16
 93a:	ec7ff0ef          	jal	ra,800 <free>
  return freep;
 93e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 942:	dd61                	beqz	a0,91a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 946:	4798                	lw	a4,8(a5)
 948:	fa9778e3          	bgeu	a4,s1,8f8 <malloc+0x70>
    if(p == freep)
 94c:	00093703          	ld	a4,0(s2)
 950:	853e                	mv	a0,a5
 952:	fef719e3          	bne	a4,a5,944 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 956:	8552                	mv	a0,s4
 958:	9e7ff0ef          	jal	ra,33e <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 95c:	fd551ce3          	bne	a0,s5,934 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 960:	4501                	li	a0,0
 962:	bf65                	j	91a <malloc+0x92>
