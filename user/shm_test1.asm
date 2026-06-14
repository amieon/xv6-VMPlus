
user/_shm_test1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
 *   无
 * 
 * 返回值：
 *   成功时返回0，失败时返回1
 */
int main(void){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   * - 长度4096字节
   * - 可读写权限
   * - 匿名映射 + 共享映射
   * - 键值为1
   */
  char *p = mmap(0, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, key);
   a:	4705                	li	a4,1
   c:	468d                	li	a3,3
   e:	460d                	li	a2,3
  10:	6585                	lui	a1,0x1
  12:	4501                	li	a0,0
  14:	3ce000ef          	jal	ra,3e2 <mmap>
  if(p == (char*)-1){ 
  18:	57fd                	li	a5,-1
  1a:	04f50563          	beq	a0,a5,64 <main+0x64>
  1e:	84aa                	mv	s1,a0
    printf("mmap fail\n"); 
    exit(1); 
  }

  /* 创建子进程 */
  int pid = fork();
  20:	31a000ef          	jal	ra,33a <fork>
  
  if(pid == 0){
  24:	e929                	bnez	a0,76 <main+0x76>
  26:	009897b7          	lui	a5,0x989
  2a:	67f78793          	addi	a5,a5,1663 # 98967f <base+0x98866f>
    // 子进程执行路径
    /* 短暂延迟，确保父进程有足够时间写入数据 */
    for(int i=1; i<10000000; ++i)
  2e:	37fd                	addiw	a5,a5,-1
  30:	fffd                	bnez	a5,2e <main+0x2e>
        ;
    
    /* 读取共享内存中的值并打印 */
    printf("child sees: %d\n", p[0]);
  32:	0004c583          	lbu	a1,0(s1)
  36:	00001517          	auipc	a0,0x1
  3a:	91a50513          	addi	a0,a0,-1766 # 950 <malloc+0xf8>
  3e:	760000ef          	jal	ra,79e <printf>
    
    /* 修改共享内存中的值 */
    p[0] = 42;
  42:	02a00793          	li	a5,42
  46:	00f48023          	sb	a5,0(s1)
    printf("child wrote 42\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	91650513          	addi	a0,a0,-1770 # 960 <malloc+0x108>
  52:	74c000ef          	jal	ra,79e <printf>
    
    /* 解除共享内存映射 */
    munmap(p, 4096);
  56:	6585                	lui	a1,0x1
  58:	8526                	mv	a0,s1
  5a:	390000ef          	jal	ra,3ea <munmap>
    exit(0);
  5e:	4501                	li	a0,0
  60:	2e2000ef          	jal	ra,342 <exit>
    printf("mmap fail\n"); 
  64:	00001517          	auipc	a0,0x1
  68:	8dc50513          	addi	a0,a0,-1828 # 940 <malloc+0xe8>
  6c:	732000ef          	jal	ra,79e <printf>
    exit(1); 
  70:	4505                	li	a0,1
  72:	2d0000ef          	jal	ra,342 <exit>
  } else {
    // 父进程执行路径
    /* 向共享内存写入初始值 */
    p[0] = 7;
  76:	479d                	li	a5,7
  78:	00f48023          	sb	a5,0(s1)
    printf("parent wrote 7\n");
  7c:	00001517          	auipc	a0,0x1
  80:	8f450513          	addi	a0,a0,-1804 # 970 <malloc+0x118>
  84:	71a000ef          	jal	ra,79e <printf>
    
    /* 等待子进程结束 */
    wait(0);
  88:	4501                	li	a0,0
  8a:	2c0000ef          	jal	ra,34a <wait>
    
    /* 读取子进程修改后的值并打印 */
    printf("parent sees after child: %d\n", p[0]);
  8e:	0004c583          	lbu	a1,0(s1)
  92:	00001517          	auipc	a0,0x1
  96:	8ee50513          	addi	a0,a0,-1810 # 980 <malloc+0x128>
  9a:	704000ef          	jal	ra,79e <printf>
    
    /* 解除共享内存映射 */
    munmap(p, 4096);
  9e:	6585                	lui	a1,0x1
  a0:	8526                	mv	a0,s1
  a2:	348000ef          	jal	ra,3ea <munmap>
    exit(0);
  a6:	4501                	li	a0,0
  a8:	29a000ef          	jal	ra,342 <exit>

00000000000000ac <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e406                	sd	ra,8(sp)
  b0:	e022                	sd	s0,0(sp)
  b2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  b4:	f4dff0ef          	jal	ra,0 <main>
  exit(r);
  b8:	28a000ef          	jal	ra,342 <exit>

00000000000000bc <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c2:	87aa                	mv	a5,a0
  c4:	0585                	addi	a1,a1,1
  c6:	0785                	addi	a5,a5,1
  c8:	fff5c703          	lbu	a4,-1(a1) # fff <digits+0x657>
  cc:	fee78fa3          	sb	a4,-1(a5)
  d0:	fb75                	bnez	a4,c4 <strcpy+0x8>
    ;
  return os;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb91                	beqz	a5,f6 <strcmp+0x1e>
  e4:	0005c703          	lbu	a4,0(a1)
  e8:	00f71763          	bne	a4,a5,f6 <strcmp+0x1e>
    p++, q++;
  ec:	0505                	addi	a0,a0,1
  ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	fbe5                	bnez	a5,e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f6:	0005c503          	lbu	a0,0(a1)
}
  fa:	40a7853b          	subw	a0,a5,a0
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cf91                	beqz	a5,12a <strlen+0x26>
 110:	0505                	addi	a0,a0,1
 112:	87aa                	mv	a5,a0
 114:	4685                	li	a3,1
 116:	9e89                	subw	a3,a3,a0
 118:	00f6853b          	addw	a0,a3,a5
 11c:	0785                	addi	a5,a5,1
 11e:	fff7c703          	lbu	a4,-1(a5)
 122:	fb7d                	bnez	a4,118 <strlen+0x14>
    ;
  return n;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  for(n = 0; s[n]; n++)
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strlen+0x20>

000000000000012e <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 134:	ca19                	beqz	a2,14a <memset+0x1c>
 136:	87aa                	mv	a5,a0
 138:	1602                	slli	a2,a2,0x20
 13a:	9201                	srli	a2,a2,0x20
 13c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 140:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 144:	0785                	addi	a5,a5,1
 146:	fee79de3          	bne	a5,a4,140 <memset+0x12>
  }
  return dst;
}
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  for(; *s; s++)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cb99                	beqz	a5,170 <strchr+0x20>
    if(*s == c)
 15c:	00f58763          	beq	a1,a5,16a <strchr+0x1a>
  for(; *s; s++)
 160:	0505                	addi	a0,a0,1
 162:	00054783          	lbu	a5,0(a0)
 166:	fbfd                	bnez	a5,15c <strchr+0xc>
      return (char*)s;
  return 0;
 168:	4501                	li	a0,0
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  return 0;
 170:	4501                	li	a0,0
 172:	bfe5                	j	16a <strchr+0x1a>

0000000000000174 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 174:	711d                	addi	sp,sp,-96
 176:	ec86                	sd	ra,88(sp)
 178:	e8a2                	sd	s0,80(sp)
 17a:	e4a6                	sd	s1,72(sp)
 17c:	e0ca                	sd	s2,64(sp)
 17e:	fc4e                	sd	s3,56(sp)
 180:	f852                	sd	s4,48(sp)
 182:	f456                	sd	s5,40(sp)
 184:	f05a                	sd	s6,32(sp)
 186:	ec5e                	sd	s7,24(sp)
 188:	1080                	addi	s0,sp,96
 18a:	8baa                	mv	s7,a0
 18c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18e:	892a                	mv	s2,a0
 190:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 192:	4aa9                	li	s5,10
 194:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 196:	89a6                	mv	s3,s1
 198:	2485                	addiw	s1,s1,1
 19a:	0344d663          	bge	s1,s4,1c6 <gets+0x52>
    cc = read(0, &c, 1);
 19e:	4605                	li	a2,1
 1a0:	faf40593          	addi	a1,s0,-81
 1a4:	4501                	li	a0,0
 1a6:	1b4000ef          	jal	ra,35a <read>
    if(cc < 1)
 1aa:	00a05e63          	blez	a0,1c6 <gets+0x52>
    buf[i++] = c;
 1ae:	faf44783          	lbu	a5,-81(s0)
 1b2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b6:	01578763          	beq	a5,s5,1c4 <gets+0x50>
 1ba:	0905                	addi	s2,s2,1
 1bc:	fd679de3          	bne	a5,s6,196 <gets+0x22>
  for(i=0; i+1 < max; ){
 1c0:	89a6                	mv	s3,s1
 1c2:	a011                	j	1c6 <gets+0x52>
 1c4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c6:	99de                	add	s3,s3,s7
 1c8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1cc:	855e                	mv	a0,s7
 1ce:	60e6                	ld	ra,88(sp)
 1d0:	6446                	ld	s0,80(sp)
 1d2:	64a6                	ld	s1,72(sp)
 1d4:	6906                	ld	s2,64(sp)
 1d6:	79e2                	ld	s3,56(sp)
 1d8:	7a42                	ld	s4,48(sp)
 1da:	7aa2                	ld	s5,40(sp)
 1dc:	7b02                	ld	s6,32(sp)
 1de:	6be2                	ld	s7,24(sp)
 1e0:	6125                	addi	sp,sp,96
 1e2:	8082                	ret

00000000000001e4 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 1e4:	1101                	addi	sp,sp,-32
 1e6:	ec06                	sd	ra,24(sp)
 1e8:	e822                	sd	s0,16(sp)
 1ea:	e426                	sd	s1,8(sp)
 1ec:	e04a                	sd	s2,0(sp)
 1ee:	1000                	addi	s0,sp,32
 1f0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f2:	4581                	li	a1,0
 1f4:	18e000ef          	jal	ra,382 <open>
  if(fd < 0)
 1f8:	02054163          	bltz	a0,21a <stat+0x36>
 1fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fe:	85ca                	mv	a1,s2
 200:	19a000ef          	jal	ra,39a <fstat>
 204:	892a                	mv	s2,a0
  close(fd);
 206:	8526                	mv	a0,s1
 208:	162000ef          	jal	ra,36a <close>
  return r;
}
 20c:	854a                	mv	a0,s2
 20e:	60e2                	ld	ra,24(sp)
 210:	6442                	ld	s0,16(sp)
 212:	64a2                	ld	s1,8(sp)
 214:	6902                	ld	s2,0(sp)
 216:	6105                	addi	sp,sp,32
 218:	8082                	ret
    return -1;
 21a:	597d                	li	s2,-1
 21c:	bfc5                	j	20c <stat+0x28>

000000000000021e <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 224:	00054603          	lbu	a2,0(a0)
 228:	fd06079b          	addiw	a5,a2,-48
 22c:	0ff7f793          	andi	a5,a5,255
 230:	4725                	li	a4,9
 232:	02f76963          	bltu	a4,a5,264 <atoi+0x46>
 236:	86aa                	mv	a3,a0
  n = 0;
 238:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 23a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 23c:	0685                	addi	a3,a3,1
 23e:	0025179b          	slliw	a5,a0,0x2
 242:	9fa9                	addw	a5,a5,a0
 244:	0017979b          	slliw	a5,a5,0x1
 248:	9fb1                	addw	a5,a5,a2
 24a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24e:	0006c603          	lbu	a2,0(a3)
 252:	fd06071b          	addiw	a4,a2,-48
 256:	0ff77713          	andi	a4,a4,255
 25a:	fee5f1e3          	bgeu	a1,a4,23c <atoi+0x1e>
  return n;
}
 25e:	6422                	ld	s0,8(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
  n = 0;
 264:	4501                	li	a0,0
 266:	bfe5                	j	25e <atoi+0x40>

0000000000000268 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e422                	sd	s0,8(sp)
 26c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26e:	02b57463          	bgeu	a0,a1,296 <memmove+0x2e>
    while(n-- > 0)
 272:	00c05f63          	blez	a2,290 <memmove+0x28>
 276:	1602                	slli	a2,a2,0x20
 278:	9201                	srli	a2,a2,0x20
 27a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27e:	872a                	mv	a4,a0
      *dst++ = *src++;
 280:	0585                	addi	a1,a1,1
 282:	0705                	addi	a4,a4,1
 284:	fff5c683          	lbu	a3,-1(a1)
 288:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28c:	fee79ae3          	bne	a5,a4,280 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
    dst += n;
 296:	00c50733          	add	a4,a0,a2
    src += n;
 29a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 29c:	fec05ae3          	blez	a2,290 <memmove+0x28>
 2a0:	fff6079b          	addiw	a5,a2,-1
 2a4:	1782                	slli	a5,a5,0x20
 2a6:	9381                	srli	a5,a5,0x20
 2a8:	fff7c793          	not	a5,a5
 2ac:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ae:	15fd                	addi	a1,a1,-1
 2b0:	177d                	addi	a4,a4,-1
 2b2:	0005c683          	lbu	a3,0(a1)
 2b6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ba:	fee79ae3          	bne	a5,a4,2ae <memmove+0x46>
 2be:	bfc9                	j	290 <memmove+0x28>

00000000000002c0 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c6:	ca05                	beqz	a2,2f6 <memcmp+0x36>
 2c8:	fff6069b          	addiw	a3,a2,-1
 2cc:	1682                	slli	a3,a3,0x20
 2ce:	9281                	srli	a3,a3,0x20
 2d0:	0685                	addi	a3,a3,1
 2d2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d4:	00054783          	lbu	a5,0(a0)
 2d8:	0005c703          	lbu	a4,0(a1)
 2dc:	00e79863          	bne	a5,a4,2ec <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e0:	0505                	addi	a0,a0,1
    p2++;
 2e2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e4:	fed518e3          	bne	a0,a3,2d4 <memcmp+0x14>
  }
  return 0;
 2e8:	4501                	li	a0,0
 2ea:	a019                	j	2f0 <memcmp+0x30>
      return *p1 - *p2;
 2ec:	40e7853b          	subw	a0,a5,a4
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	bfe5                	j	2f0 <memcmp+0x30>

00000000000002fa <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e406                	sd	ra,8(sp)
 2fe:	e022                	sd	s0,0(sp)
 300:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 302:	f67ff0ef          	jal	ra,268 <memmove>
}
 306:	60a2                	ld	ra,8(sp)
 308:	6402                	ld	s0,0(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 316:	4585                	li	a1,1
 318:	0b2000ef          	jal	ra,3ca <sys_sbrk>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 32c:	4589                	li	a1,2
 32e:	09c000ef          	jal	ra,3ca <sys_sbrk>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 33a:	4885                	li	a7,1
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <exit>:
.global exit
exit:
 li a7, SYS_exit
 342:	4889                	li	a7,2
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <wait>:
.global wait
wait:
 li a7, SYS_wait
 34a:	488d                	li	a7,3
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 352:	4891                	li	a7,4
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <read>:
.global read
read:
 li a7, SYS_read
 35a:	4895                	li	a7,5
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <write>:
.global write
write:
 li a7, SYS_write
 362:	48c1                	li	a7,16
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <close>:
.global close
close:
 li a7, SYS_close
 36a:	48d5                	li	a7,21
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <kill>:
.global kill
kill:
 li a7, SYS_kill
 372:	4899                	li	a7,6
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <exec>:
.global exec
exec:
 li a7, SYS_exec
 37a:	489d                	li	a7,7
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <open>:
.global open
open:
 li a7, SYS_open
 382:	48bd                	li	a7,15
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 38a:	48c5                	li	a7,17
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 392:	48c9                	li	a7,18
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 39a:	48a1                	li	a7,8
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <link>:
.global link
link:
 li a7, SYS_link
 3a2:	48cd                	li	a7,19
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3aa:	48d1                	li	a7,20
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b2:	48a5                	li	a7,9
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ba:	48a9                	li	a7,10
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c2:	48ad                	li	a7,11
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ca:	48b1                	li	a7,12
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d2:	48b5                	li	a7,13
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3da:	48b9                	li	a7,14
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 3e2:	48d9                	li	a7,22
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 3ea:	48dd                	li	a7,23
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 3f2:	48e1                	li	a7,24
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3fa:	48e5                	li	a7,25
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 402:	48e9                	li	a7,26
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 40a:	48ed                	li	a7,27
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 412:	48f1                	li	a7,28
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 41a:	48f5                	li	a7,29
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 422:	1101                	addi	sp,sp,-32
 424:	ec06                	sd	ra,24(sp)
 426:	e822                	sd	s0,16(sp)
 428:	1000                	addi	s0,sp,32
 42a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 42e:	4605                	li	a2,1
 430:	fef40593          	addi	a1,s0,-17
 434:	f2fff0ef          	jal	ra,362 <write>
}
 438:	60e2                	ld	ra,24(sp)
 43a:	6442                	ld	s0,16(sp)
 43c:	6105                	addi	sp,sp,32
 43e:	8082                	ret

0000000000000440 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 440:	715d                	addi	sp,sp,-80
 442:	e486                	sd	ra,72(sp)
 444:	e0a2                	sd	s0,64(sp)
 446:	fc26                	sd	s1,56(sp)
 448:	f84a                	sd	s2,48(sp)
 44a:	f44e                	sd	s3,40(sp)
 44c:	0880                	addi	s0,sp,80
 44e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 450:	c299                	beqz	a3,456 <printint+0x16>
 452:	0805c163          	bltz	a1,4d4 <printint+0x94>
  neg = 0;
 456:	4881                	li	a7,0
 458:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 45c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 45e:	00000517          	auipc	a0,0x0
 462:	54a50513          	addi	a0,a0,1354 # 9a8 <digits>
 466:	883e                	mv	a6,a5
 468:	2785                	addiw	a5,a5,1
 46a:	02c5f733          	remu	a4,a1,a2
 46e:	972a                	add	a4,a4,a0
 470:	00074703          	lbu	a4,0(a4)
 474:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 478:	872e                	mv	a4,a1
 47a:	02c5d5b3          	divu	a1,a1,a2
 47e:	0685                	addi	a3,a3,1
 480:	fec773e3          	bgeu	a4,a2,466 <printint+0x26>
  if(neg)
 484:	00088b63          	beqz	a7,49a <printint+0x5a>
    buf[i++] = '-';
 488:	fd040713          	addi	a4,s0,-48
 48c:	97ba                	add	a5,a5,a4
 48e:	02d00713          	li	a4,45
 492:	fee78423          	sb	a4,-24(a5)
 496:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 49a:	02f05663          	blez	a5,4c6 <printint+0x86>
 49e:	fb840713          	addi	a4,s0,-72
 4a2:	00f704b3          	add	s1,a4,a5
 4a6:	fff70993          	addi	s3,a4,-1
 4aa:	99be                	add	s3,s3,a5
 4ac:	37fd                	addiw	a5,a5,-1
 4ae:	1782                	slli	a5,a5,0x20
 4b0:	9381                	srli	a5,a5,0x20
 4b2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4b6:	fff4c583          	lbu	a1,-1(s1)
 4ba:	854a                	mv	a0,s2
 4bc:	f67ff0ef          	jal	ra,422 <putc>
  while(--i >= 0)
 4c0:	14fd                	addi	s1,s1,-1
 4c2:	ff349ae3          	bne	s1,s3,4b6 <printint+0x76>
}
 4c6:	60a6                	ld	ra,72(sp)
 4c8:	6406                	ld	s0,64(sp)
 4ca:	74e2                	ld	s1,56(sp)
 4cc:	7942                	ld	s2,48(sp)
 4ce:	79a2                	ld	s3,40(sp)
 4d0:	6161                	addi	sp,sp,80
 4d2:	8082                	ret
    x = -xx;
 4d4:	40b005b3          	neg	a1,a1
    neg = 1;
 4d8:	4885                	li	a7,1
    x = -xx;
 4da:	bfbd                	j	458 <printint+0x18>

00000000000004dc <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 4dc:	7119                	addi	sp,sp,-128
 4de:	fc86                	sd	ra,120(sp)
 4e0:	f8a2                	sd	s0,112(sp)
 4e2:	f4a6                	sd	s1,104(sp)
 4e4:	f0ca                	sd	s2,96(sp)
 4e6:	ecce                	sd	s3,88(sp)
 4e8:	e8d2                	sd	s4,80(sp)
 4ea:	e4d6                	sd	s5,72(sp)
 4ec:	e0da                	sd	s6,64(sp)
 4ee:	fc5e                	sd	s7,56(sp)
 4f0:	f862                	sd	s8,48(sp)
 4f2:	f466                	sd	s9,40(sp)
 4f4:	f06a                	sd	s10,32(sp)
 4f6:	ec6e                	sd	s11,24(sp)
 4f8:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4fa:	0005c903          	lbu	s2,0(a1)
 4fe:	24090c63          	beqz	s2,756 <vprintf+0x27a>
 502:	8b2a                	mv	s6,a0
 504:	8a2e                	mv	s4,a1
 506:	8bb2                	mv	s7,a2
  state = 0;
 508:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 50a:	4481                	li	s1,0
 50c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 50e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 512:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 516:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 51a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 51e:	00000c97          	auipc	s9,0x0
 522:	48ac8c93          	addi	s9,s9,1162 # 9a8 <digits>
 526:	a005                	j	546 <vprintf+0x6a>
        putc(fd, c0);
 528:	85ca                	mv	a1,s2
 52a:	855a                	mv	a0,s6
 52c:	ef7ff0ef          	jal	ra,422 <putc>
 530:	a019                	j	536 <vprintf+0x5a>
    } else if(state == '%'){
 532:	03598263          	beq	s3,s5,556 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 536:	2485                	addiw	s1,s1,1
 538:	8726                	mv	a4,s1
 53a:	009a07b3          	add	a5,s4,s1
 53e:	0007c903          	lbu	s2,0(a5)
 542:	20090a63          	beqz	s2,756 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 546:	0009079b          	sext.w	a5,s2
    if(state == 0){
 54a:	fe0994e3          	bnez	s3,532 <vprintf+0x56>
      if(c0 == '%'){
 54e:	fd579de3          	bne	a5,s5,528 <vprintf+0x4c>
        state = '%';
 552:	89be                	mv	s3,a5
 554:	b7cd                	j	536 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 556:	c3c1                	beqz	a5,5d6 <vprintf+0xfa>
 558:	00ea06b3          	add	a3,s4,a4
 55c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 560:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 562:	c681                	beqz	a3,56a <vprintf+0x8e>
 564:	9752                	add	a4,a4,s4
 566:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 56a:	03878e63          	beq	a5,s8,5a6 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 56e:	05a78863          	beq	a5,s10,5be <vprintf+0xe2>
      } else if(c0 == 'u'){
 572:	0db78b63          	beq	a5,s11,648 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 576:	07800713          	li	a4,120
 57a:	10e78d63          	beq	a5,a4,694 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 57e:	07000713          	li	a4,112
 582:	14e78263          	beq	a5,a4,6c6 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 586:	06300713          	li	a4,99
 58a:	16e78f63          	beq	a5,a4,708 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 58e:	07300713          	li	a4,115
 592:	18e78563          	beq	a5,a4,71c <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 596:	05579063          	bne	a5,s5,5d6 <vprintf+0xfa>
        putc(fd, '%');
 59a:	85d6                	mv	a1,s5
 59c:	855a                	mv	a0,s6
 59e:	e85ff0ef          	jal	ra,422 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	bf49                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5a6:	008b8913          	addi	s2,s7,8
 5aa:	4685                	li	a3,1
 5ac:	4629                	li	a2,10
 5ae:	000ba583          	lw	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	e8dff0ef          	jal	ra,440 <printint>
 5b8:	8bca                	mv	s7,s2
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	bfad                	j	536 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5be:	03868663          	beq	a3,s8,5ea <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c2:	05a68163          	beq	a3,s10,604 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5c6:	09b68d63          	beq	a3,s11,660 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5ca:	03a68f63          	beq	a3,s10,608 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5ce:	07800793          	li	a5,120
 5d2:	0cf68d63          	beq	a3,a5,6ac <vprintf+0x1d0>
        putc(fd, '%');
 5d6:	85d6                	mv	a1,s5
 5d8:	855a                	mv	a0,s6
 5da:	e49ff0ef          	jal	ra,422 <putc>
        putc(fd, c0);
 5de:	85ca                	mv	a1,s2
 5e0:	855a                	mv	a0,s6
 5e2:	e41ff0ef          	jal	ra,422 <putc>
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b7b9                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000bb583          	ld	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	e49ff0ef          	jal	ra,440 <printint>
        i += 1;
 5fc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fe:	8bca                	mv	s7,s2
      state = 0;
 600:	4981                	li	s3,0
        i += 1;
 602:	bf15                	j	536 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 604:	03860563          	beq	a2,s8,62e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 608:	07b60963          	beq	a2,s11,67a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 60c:	07800793          	li	a5,120
 610:	fcf613e3          	bne	a2,a5,5d6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	008b8913          	addi	s2,s7,8
 618:	4681                	li	a3,0
 61a:	4641                	li	a2,16
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	e1fff0ef          	jal	ra,440 <printint>
        i += 2;
 626:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
        i += 2;
 62c:	b729                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	008b8913          	addi	s2,s7,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e05ff0ef          	jal	ra,440 <printint>
        i += 2;
 640:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	bdc5                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4629                	li	a2,10
 650:	000be583          	lwu	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	debff0ef          	jal	ra,440 <printint>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bde1                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4629                	li	a2,10
 668:	000bb583          	ld	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	dd3ff0ef          	jal	ra,440 <printint>
        i += 1;
 672:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
        i += 1;
 678:	bd7d                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	db9ff0ef          	jal	ra,440 <printint>
        i += 2;
 68c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 2;
 692:	b555                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4641                	li	a2,16
 69c:	000be583          	lwu	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	d9fff0ef          	jal	ra,440 <printint>
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	b571                	j	536 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4641                	li	a2,16
 6b4:	000bb583          	ld	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	d87ff0ef          	jal	ra,440 <printint>
        i += 1;
 6be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
        i += 1;
 6c4:	bd8d                	j	536 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6c6:	008b8793          	addi	a5,s7,8
 6ca:	f8f43423          	sd	a5,-120(s0)
 6ce:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d2:	03000593          	li	a1,48
 6d6:	855a                	mv	a0,s6
 6d8:	d4bff0ef          	jal	ra,422 <putc>
  putc(fd, 'x');
 6dc:	07800593          	li	a1,120
 6e0:	855a                	mv	a0,s6
 6e2:	d41ff0ef          	jal	ra,422 <putc>
 6e6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e8:	03c9d793          	srli	a5,s3,0x3c
 6ec:	97e6                	add	a5,a5,s9
 6ee:	0007c583          	lbu	a1,0(a5)
 6f2:	855a                	mv	a0,s6
 6f4:	d2fff0ef          	jal	ra,422 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f8:	0992                	slli	s3,s3,0x4
 6fa:	397d                	addiw	s2,s2,-1
 6fc:	fe0916e3          	bnez	s2,6e8 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 700:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 704:	4981                	li	s3,0
 706:	bd05                	j	536 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 708:	008b8913          	addi	s2,s7,8
 70c:	000bc583          	lbu	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	d11ff0ef          	jal	ra,422 <putc>
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
 71a:	bd31                	j	536 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 71c:	008b8993          	addi	s3,s7,8
 720:	000bb903          	ld	s2,0(s7)
 724:	00090f63          	beqz	s2,742 <vprintf+0x266>
        for(; *s; s++)
 728:	00094583          	lbu	a1,0(s2)
 72c:	c195                	beqz	a1,750 <vprintf+0x274>
          putc(fd, *s);
 72e:	855a                	mv	a0,s6
 730:	cf3ff0ef          	jal	ra,422 <putc>
        for(; *s; s++)
 734:	0905                	addi	s2,s2,1
 736:	00094583          	lbu	a1,0(s2)
 73a:	f9f5                	bnez	a1,72e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 73c:	8bce                	mv	s7,s3
      state = 0;
 73e:	4981                	li	s3,0
 740:	bbdd                	j	536 <vprintf+0x5a>
          s = "(null)";
 742:	00000917          	auipc	s2,0x0
 746:	25e90913          	addi	s2,s2,606 # 9a0 <malloc+0x148>
        for(; *s; s++)
 74a:	02800593          	li	a1,40
 74e:	b7c5                	j	72e <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 750:	8bce                	mv	s7,s3
      state = 0;
 752:	4981                	li	s3,0
 754:	b3cd                	j	536 <vprintf+0x5a>
    }
  }
}
 756:	70e6                	ld	ra,120(sp)
 758:	7446                	ld	s0,112(sp)
 75a:	74a6                	ld	s1,104(sp)
 75c:	7906                	ld	s2,96(sp)
 75e:	69e6                	ld	s3,88(sp)
 760:	6a46                	ld	s4,80(sp)
 762:	6aa6                	ld	s5,72(sp)
 764:	6b06                	ld	s6,64(sp)
 766:	7be2                	ld	s7,56(sp)
 768:	7c42                	ld	s8,48(sp)
 76a:	7ca2                	ld	s9,40(sp)
 76c:	7d02                	ld	s10,32(sp)
 76e:	6de2                	ld	s11,24(sp)
 770:	6109                	addi	sp,sp,128
 772:	8082                	ret

0000000000000774 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 774:	715d                	addi	sp,sp,-80
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	e010                	sd	a2,0(s0)
 77e:	e414                	sd	a3,8(s0)
 780:	e818                	sd	a4,16(s0)
 782:	ec1c                	sd	a5,24(s0)
 784:	03043023          	sd	a6,32(s0)
 788:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 790:	8622                	mv	a2,s0
 792:	d4bff0ef          	jal	ra,4dc <vprintf>
}
 796:	60e2                	ld	ra,24(sp)
 798:	6442                	ld	s0,16(sp)
 79a:	6161                	addi	sp,sp,80
 79c:	8082                	ret

000000000000079e <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 79e:	711d                	addi	sp,sp,-96
 7a0:	ec06                	sd	ra,24(sp)
 7a2:	e822                	sd	s0,16(sp)
 7a4:	1000                	addi	s0,sp,32
 7a6:	e40c                	sd	a1,8(s0)
 7a8:	e810                	sd	a2,16(s0)
 7aa:	ec14                	sd	a3,24(s0)
 7ac:	f018                	sd	a4,32(s0)
 7ae:	f41c                	sd	a5,40(s0)
 7b0:	03043823          	sd	a6,48(s0)
 7b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b8:	00840613          	addi	a2,s0,8
 7bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c0:	85aa                	mv	a1,a0
 7c2:	4505                	li	a0,1
 7c4:	d19ff0ef          	jal	ra,4dc <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6125                	addi	sp,sp,96
 7ce:	8082                	ret

00000000000007d0 <free>:
 *   无
 */

void
free(void *ap)
{
 7d0:	1141                	addi	sp,sp,-16
 7d2:	e422                	sd	s0,8(sp)
 7d4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 7d6:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	00001797          	auipc	a5,0x1
 7de:	8267b783          	ld	a5,-2010(a5) # 1000 <freep>
 7e2:	a805                	j	812 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e4:	4618                	lw	a4,8(a2)
 7e6:	9db9                	addw	a1,a1,a4
 7e8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ec:	6398                	ld	a4,0(a5)
 7ee:	6318                	ld	a4,0(a4)
 7f0:	fee53823          	sd	a4,-16(a0)
 7f4:	a091                	j	838 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f6:	ff852703          	lw	a4,-8(a0)
 7fa:	9e39                	addw	a2,a2,a4
 7fc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7fe:	ff053703          	ld	a4,-16(a0)
 802:	e398                	sd	a4,0(a5)
 804:	a099                	j	84a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 806:	6398                	ld	a4,0(a5)
 808:	00e7e463          	bltu	a5,a4,810 <free+0x40>
 80c:	00e6ea63          	bltu	a3,a4,820 <free+0x50>
{
 810:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 812:	fed7fae3          	bgeu	a5,a3,806 <free+0x36>
 816:	6398                	ld	a4,0(a5)
 818:	00e6e463          	bltu	a3,a4,820 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	fee7eae3          	bltu	a5,a4,810 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 820:	ff852583          	lw	a1,-8(a0)
 824:	6390                	ld	a2,0(a5)
 826:	02059713          	slli	a4,a1,0x20
 82a:	9301                	srli	a4,a4,0x20
 82c:	0712                	slli	a4,a4,0x4
 82e:	9736                	add	a4,a4,a3
 830:	fae60ae3          	beq	a2,a4,7e4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 834:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 838:	4790                	lw	a2,8(a5)
 83a:	02061713          	slli	a4,a2,0x20
 83e:	9301                	srli	a4,a4,0x20
 840:	0712                	slli	a4,a4,0x4
 842:	973e                	add	a4,a4,a5
 844:	fae689e3          	beq	a3,a4,7f6 <free+0x26>
  } else
    p->s.ptr = bp;
 848:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 84a:	00000717          	auipc	a4,0x0
 84e:	7af73b23          	sd	a5,1974(a4) # 1000 <freep>
}
 852:	6422                	ld	s0,8(sp)
 854:	0141                	addi	sp,sp,16
 856:	8082                	ret

0000000000000858 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 858:	7139                	addi	sp,sp,-64
 85a:	fc06                	sd	ra,56(sp)
 85c:	f822                	sd	s0,48(sp)
 85e:	f426                	sd	s1,40(sp)
 860:	f04a                	sd	s2,32(sp)
 862:	ec4e                	sd	s3,24(sp)
 864:	e852                	sd	s4,16(sp)
 866:	e456                	sd	s5,8(sp)
 868:	e05a                	sd	s6,0(sp)
 86a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 86c:	02051493          	slli	s1,a0,0x20
 870:	9081                	srli	s1,s1,0x20
 872:	04bd                	addi	s1,s1,15
 874:	8091                	srli	s1,s1,0x4
 876:	0014899b          	addiw	s3,s1,1
 87a:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 87c:	00000517          	auipc	a0,0x0
 880:	78453503          	ld	a0,1924(a0) # 1000 <freep>
 884:	c515                	beqz	a0,8b0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 886:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 888:	4798                	lw	a4,8(a5)
 88a:	02977f63          	bgeu	a4,s1,8c8 <malloc+0x70>
 88e:	8a4e                	mv	s4,s3
 890:	0009871b          	sext.w	a4,s3
 894:	6685                	lui	a3,0x1
 896:	00d77363          	bgeu	a4,a3,89c <malloc+0x44>
 89a:	6a05                	lui	s4,0x1
 89c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 8a0:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 8a4:	00000917          	auipc	s2,0x0
 8a8:	75c90913          	addi	s2,s2,1884 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 8ac:	5afd                	li	s5,-1
 8ae:	a0bd                	j	91c <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8b0:	00000797          	auipc	a5,0x0
 8b4:	76078793          	addi	a5,a5,1888 # 1010 <base>
 8b8:	00000717          	auipc	a4,0x0
 8bc:	74f73423          	sd	a5,1864(a4) # 1000 <freep>
 8c0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 8c6:	b7e1                	j	88e <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 8c8:	02e48b63          	beq	s1,a4,8fe <malloc+0xa6>
        p->s.size -= nunits;
 8cc:	4137073b          	subw	a4,a4,s3
 8d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d2:	1702                	slli	a4,a4,0x20
 8d4:	9301                	srli	a4,a4,0x20
 8d6:	0712                	slli	a4,a4,0x4
 8d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8da:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 8de:	00000717          	auipc	a4,0x0
 8e2:	72a73123          	sd	a0,1826(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 8e6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 8ea:	70e2                	ld	ra,56(sp)
 8ec:	7442                	ld	s0,48(sp)
 8ee:	74a2                	ld	s1,40(sp)
 8f0:	7902                	ld	s2,32(sp)
 8f2:	69e2                	ld	s3,24(sp)
 8f4:	6a42                	ld	s4,16(sp)
 8f6:	6aa2                	ld	s5,8(sp)
 8f8:	6b02                	ld	s6,0(sp)
 8fa:	6121                	addi	sp,sp,64
 8fc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8fe:	6398                	ld	a4,0(a5)
 900:	e118                	sd	a4,0(a0)
 902:	bff1                	j	8de <malloc+0x86>
  hp->s.size = nu;
 904:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 908:	0541                	addi	a0,a0,16
 90a:	ec7ff0ef          	jal	ra,7d0 <free>
  return freep;
 90e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 912:	dd61                	beqz	a0,8ea <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 914:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 916:	4798                	lw	a4,8(a5)
 918:	fa9778e3          	bgeu	a4,s1,8c8 <malloc+0x70>
    if(p == freep)
 91c:	00093703          	ld	a4,0(s2)
 920:	853e                	mv	a0,a5
 922:	fef719e3          	bne	a4,a5,914 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 926:	8552                	mv	a0,s4
 928:	9e7ff0ef          	jal	ra,30e <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 92c:	fd551ce3          	bne	a0,s5,904 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 930:	4501                	li	a0,0
 932:	bf65                	j	8ea <malloc+0x92>
