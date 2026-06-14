
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
 * 返回值：
 *   指向格式化后的文件名的指针
 */
char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];  /* 用于存储格式化后的文件名，注意静态存储 */
  char *p;

  /* 从路径末尾开始查找最后一个斜杠 */
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	2b0000ef          	jal	ra,2c0 <strlen>
  14:	02051793          	slli	a5,a0,0x20
  18:	9381                	srli	a5,a5,0x20
  1a:	97a6                	add	a5,a5,s1
  1c:	02f00693          	li	a3,47
  20:	0097e963          	bltu	a5,s1,32 <fmtname+0x32>
  24:	0007c703          	lbu	a4,0(a5)
  28:	00d70563          	beq	a4,a3,32 <fmtname+0x32>
  2c:	17fd                	addi	a5,a5,-1
  2e:	fe97fbe3          	bgeu	a5,s1,24 <fmtname+0x24>
    ;
  p++;  /* 指向文件名的第一个字符 */
  32:	00178493          	addi	s1,a5,1

  /* 如果文件名长度大于等于DIRSIZ，直接返回原指针 */
  if(strlen(p) >= DIRSIZ)
  36:	8526                	mv	a0,s1
  38:	288000ef          	jal	ra,2c0 <strlen>
  3c:	2501                	sext.w	a0,a0
  3e:	47b5                	li	a5,13
  40:	00a7fa63          	bgeu	a5,a0,54 <fmtname+0x54>
  /* 否则将文件名复制到buf并在末尾填充空格以达到DIRSIZ长度 */
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';  /* 确保字符串以空字符结尾 */
  return buf;
}
  44:	8526                	mv	a0,s1
  46:	70a2                	ld	ra,40(sp)
  48:	7402                	ld	s0,32(sp)
  4a:	64e2                	ld	s1,24(sp)
  4c:	6942                	ld	s2,16(sp)
  4e:	69a2                	ld	s3,8(sp)
  50:	6145                	addi	sp,sp,48
  52:	8082                	ret
  memmove(buf, p, strlen(p));
  54:	8526                	mv	a0,s1
  56:	26a000ef          	jal	ra,2c0 <strlen>
  5a:	00001997          	auipc	s3,0x1
  5e:	fb698993          	addi	s3,s3,-74 # 1010 <buf.0>
  62:	0005061b          	sext.w	a2,a0
  66:	85a6                	mv	a1,s1
  68:	854e                	mv	a0,s3
  6a:	3ba000ef          	jal	ra,424 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6e:	8526                	mv	a0,s1
  70:	250000ef          	jal	ra,2c0 <strlen>
  74:	0005091b          	sext.w	s2,a0
  78:	8526                	mv	a0,s1
  7a:	246000ef          	jal	ra,2c0 <strlen>
  7e:	1902                	slli	s2,s2,0x20
  80:	02095913          	srli	s2,s2,0x20
  84:	4639                	li	a2,14
  86:	9e09                	subw	a2,a2,a0
  88:	02000593          	li	a1,32
  8c:	01298533          	add	a0,s3,s2
  90:	25a000ef          	jal	ra,2ea <memset>
  buf[sizeof(buf)-1] = '\0';  /* 确保字符串以空字符结尾 */
  94:	00098723          	sb	zero,14(s3)
  return buf;
  98:	84ce                	mv	s1,s3
  9a:	b76d                	j	44 <fmtname+0x44>

000000000000009c <ls>:
 * 返回值：
 *   无
 */
void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	24913c23          	sd	s1,600(sp)
  ac:	25213823          	sd	s2,592(sp)
  b0:	25313423          	sd	s3,584(sp)
  b4:	25413023          	sd	s4,576(sp)
  b8:	23513c23          	sd	s5,568(sp)
  bc:	1c80                	addi	s0,sp,624
  be:	892a                	mv	s2,a0
  int fd;
  struct dirent de;  /* 目录项结构 */
  struct stat st;    /* 文件状态结构 */

  /* 尝试打开路径 */
  if((fd = open(path, O_RDONLY)) < 0){
  c0:	4581                	li	a1,0
  c2:	47c000ef          	jal	ra,53e <open>
  c6:	06054963          	bltz	a0,138 <ls+0x9c>
  ca:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  /* 获取文件状态信息 */
  if(fstat(fd, &st) < 0){
  cc:	d9840593          	addi	a1,s0,-616
  d0:	486000ef          	jal	ra,556 <fstat>
  d4:	06054b63          	bltz	a0,14a <ls+0xae>
    close(fd);
    return;
  }

  /* 根据文件类型执行不同的处理逻辑 */
  switch(st.type){
  d8:	da041783          	lh	a5,-608(s0)
  dc:	0007869b          	sext.w	a3,a5
  e0:	4705                	li	a4,1
  e2:	08e68063          	beq	a3,a4,162 <ls+0xc6>
  e6:	37f9                	addiw	a5,a5,-2
  e8:	17c2                	slli	a5,a5,0x30
  ea:	93c1                	srli	a5,a5,0x30
  ec:	02f76263          	bltu	a4,a5,110 <ls+0x74>
  case T_DEVICE:  /* 设备文件 */
  case T_FILE:    /* 普通文件 */
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  f0:	854a                	mv	a0,s2
  f2:	f0fff0ef          	jal	ra,0 <fmtname>
  f6:	85aa                	mv	a1,a0
  f8:	da842703          	lw	a4,-600(s0)
  fc:	d9c42683          	lw	a3,-612(s0)
 100:	da041603          	lh	a2,-608(s0)
 104:	00001517          	auipc	a0,0x1
 108:	a1c50513          	addi	a0,a0,-1508 # b20 <malloc+0x10c>
 10c:	04f000ef          	jal	ra,95a <printf>
      /* 输出文件信息 */
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);  /* 关闭文件描述符 */
 110:	8526                	mv	a0,s1
 112:	414000ef          	jal	ra,526 <close>
}
 116:	26813083          	ld	ra,616(sp)
 11a:	26013403          	ld	s0,608(sp)
 11e:	25813483          	ld	s1,600(sp)
 122:	25013903          	ld	s2,592(sp)
 126:	24813983          	ld	s3,584(sp)
 12a:	24013a03          	ld	s4,576(sp)
 12e:	23813a83          	ld	s5,568(sp)
 132:	27010113          	addi	sp,sp,624
 136:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 138:	864a                	mv	a2,s2
 13a:	00001597          	auipc	a1,0x1
 13e:	9b658593          	addi	a1,a1,-1610 # af0 <malloc+0xdc>
 142:	4509                	li	a0,2
 144:	7ec000ef          	jal	ra,930 <fprintf>
    return;
 148:	b7f9                	j	116 <ls+0x7a>
    fprintf(2, "ls: cannot stat %s\n", path);
 14a:	864a                	mv	a2,s2
 14c:	00001597          	auipc	a1,0x1
 150:	9bc58593          	addi	a1,a1,-1604 # b08 <malloc+0xf4>
 154:	4509                	li	a0,2
 156:	7da000ef          	jal	ra,930 <fprintf>
    close(fd);
 15a:	8526                	mv	a0,s1
 15c:	3ca000ef          	jal	ra,526 <close>
    return;
 160:	bf5d                	j	116 <ls+0x7a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 162:	854a                	mv	a0,s2
 164:	15c000ef          	jal	ra,2c0 <strlen>
 168:	2541                	addiw	a0,a0,16
 16a:	20000793          	li	a5,512
 16e:	00a7f963          	bgeu	a5,a0,180 <ls+0xe4>
      printf("ls: path too long\n");
 172:	00001517          	auipc	a0,0x1
 176:	9be50513          	addi	a0,a0,-1602 # b30 <malloc+0x11c>
 17a:	7e0000ef          	jal	ra,95a <printf>
      break;
 17e:	bf49                	j	110 <ls+0x74>
    strcpy(buf, path);
 180:	85ca                	mv	a1,s2
 182:	dc040513          	addi	a0,s0,-576
 186:	0f2000ef          	jal	ra,278 <strcpy>
    p = buf+strlen(buf);
 18a:	dc040513          	addi	a0,s0,-576
 18e:	132000ef          	jal	ra,2c0 <strlen>
 192:	02051913          	slli	s2,a0,0x20
 196:	02095913          	srli	s2,s2,0x20
 19a:	dc040793          	addi	a5,s0,-576
 19e:	993e                	add	s2,s2,a5
    *p++ = '/';  /* 添加路径分隔符 */
 1a0:	00190993          	addi	s3,s2,1
 1a4:	02f00793          	li	a5,47
 1a8:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1ac:	00001a17          	auipc	s4,0x1
 1b0:	974a0a13          	addi	s4,s4,-1676 # b20 <malloc+0x10c>
        printf("ls: cannot stat %s\n", buf);
 1b4:	00001a97          	auipc	s5,0x1
 1b8:	954a8a93          	addi	s5,s5,-1708 # b08 <malloc+0xf4>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1bc:	a031                	j	1c8 <ls+0x12c>
        printf("ls: cannot stat %s\n", buf);
 1be:	dc040593          	addi	a1,s0,-576
 1c2:	8556                	mv	a0,s5
 1c4:	796000ef          	jal	ra,95a <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1c8:	4641                	li	a2,16
 1ca:	db040593          	addi	a1,s0,-592
 1ce:	8526                	mv	a0,s1
 1d0:	346000ef          	jal	ra,516 <read>
 1d4:	47c1                	li	a5,16
 1d6:	f2f51de3          	bne	a0,a5,110 <ls+0x74>
      if(de.inum == 0)  /* 跳过未使用的目录项 */
 1da:	db045783          	lhu	a5,-592(s0)
 1de:	d7ed                	beqz	a5,1c8 <ls+0x12c>
      memmove(p, de.name, DIRSIZ);
 1e0:	4639                	li	a2,14
 1e2:	db240593          	addi	a1,s0,-590
 1e6:	854e                	mv	a0,s3
 1e8:	23c000ef          	jal	ra,424 <memmove>
      p[DIRSIZ] = 0;
 1ec:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1f0:	d9840593          	addi	a1,s0,-616
 1f4:	dc040513          	addi	a0,s0,-576
 1f8:	1a8000ef          	jal	ra,3a0 <stat>
 1fc:	fc0541e3          	bltz	a0,1be <ls+0x122>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 200:	dc040513          	addi	a0,s0,-576
 204:	dfdff0ef          	jal	ra,0 <fmtname>
 208:	85aa                	mv	a1,a0
 20a:	da842703          	lw	a4,-600(s0)
 20e:	d9c42683          	lw	a3,-612(s0)
 212:	da041603          	lh	a2,-608(s0)
 216:	8552                	mv	a0,s4
 218:	742000ef          	jal	ra,95a <printf>
 21c:	b775                	j	1c8 <ls+0x12c>

000000000000021e <main>:
 * 返回值：
 *   始终返回0表示成功执行
 */
int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	e426                	sd	s1,8(sp)
 226:	e04a                	sd	s2,0(sp)
 228:	1000                	addi	s0,sp,32
  int i;

  /* 如果没有提供命令行参数，默认列出当前目录 */
  if(argc < 2){
 22a:	4785                	li	a5,1
 22c:	02a7d563          	bge	a5,a0,256 <main+0x38>
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	1902                	slli	s2,s2,0x20
 23a:	02095913          	srli	s2,s2,0x20
 23e:	090e                	slli	s2,s2,0x3
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  /* 否则遍历所有指定的路径并列出信息 */
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	ra,9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2ac000ef          	jal	ra,4fe <exit>
    ls(".");
 256:	00001517          	auipc	a0,0x1
 25a:	8f250513          	addi	a0,a0,-1806 # b48 <malloc+0x134>
 25e:	e3fff0ef          	jal	ra,9c <ls>
    exit(0);
 262:	4501                	li	a0,0
 264:	29a000ef          	jal	ra,4fe <exit>

0000000000000268 <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 270:	fafff0ef          	jal	ra,21e <main>
  exit(r);
 274:	28a000ef          	jal	ra,4fe <exit>

0000000000000278 <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 27e:	87aa                	mv	a5,a0
 280:	0585                	addi	a1,a1,1
 282:	0785                	addi	a5,a5,1
 284:	fff5c703          	lbu	a4,-1(a1)
 288:	fee78fa3          	sb	a4,-1(a5)
 28c:	fb75                	bnez	a4,280 <strcpy+0x8>
    ;
  return os;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cb91                	beqz	a5,2b2 <strcmp+0x1e>
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00f71763          	bne	a4,a5,2b2 <strcmp+0x1e>
    p++, q++;
 2a8:	0505                	addi	a0,a0,1
 2aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	fbe5                	bnez	a5,2a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b2:	0005c503          	lbu	a0,0(a1)
}
 2b6:	40a7853b          	subw	a0,a5,a0
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cf91                	beqz	a5,2e6 <strlen+0x26>
 2cc:	0505                	addi	a0,a0,1
 2ce:	87aa                	mv	a5,a0
 2d0:	4685                	li	a3,1
 2d2:	9e89                	subw	a3,a3,a0
 2d4:	00f6853b          	addw	a0,a3,a5
 2d8:	0785                	addi	a5,a5,1
 2da:	fff7c703          	lbu	a4,-1(a5)
 2de:	fb7d                	bnez	a4,2d4 <strlen+0x14>
    ;
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  for(n = 0; s[n]; n++)
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <strlen+0x20>

00000000000002ea <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1c>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x12>
  }
  return dst;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  for(; *s; s++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cb99                	beqz	a5,32c <strchr+0x20>
    if(*s == c)
 318:	00f58763          	beq	a1,a5,326 <strchr+0x1a>
  for(; *s; s++)
 31c:	0505                	addi	a0,a0,1
 31e:	00054783          	lbu	a5,0(a0)
 322:	fbfd                	bnez	a5,318 <strchr+0xc>
      return (char*)s;
  return 0;
 324:	4501                	li	a0,0
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret
  return 0;
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <strchr+0x1a>

0000000000000330 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
 330:	711d                	addi	sp,sp,-96
 332:	ec86                	sd	ra,88(sp)
 334:	e8a2                	sd	s0,80(sp)
 336:	e4a6                	sd	s1,72(sp)
 338:	e0ca                	sd	s2,64(sp)
 33a:	fc4e                	sd	s3,56(sp)
 33c:	f852                	sd	s4,48(sp)
 33e:	f456                	sd	s5,40(sp)
 340:	f05a                	sd	s6,32(sp)
 342:	ec5e                	sd	s7,24(sp)
 344:	1080                	addi	s0,sp,96
 346:	8baa                	mv	s7,a0
 348:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34a:	892a                	mv	s2,a0
 34c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 34e:	4aa9                	li	s5,10
 350:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 352:	89a6                	mv	s3,s1
 354:	2485                	addiw	s1,s1,1
 356:	0344d663          	bge	s1,s4,382 <gets+0x52>
    cc = read(0, &c, 1);
 35a:	4605                	li	a2,1
 35c:	faf40593          	addi	a1,s0,-81
 360:	4501                	li	a0,0
 362:	1b4000ef          	jal	ra,516 <read>
    if(cc < 1)
 366:	00a05e63          	blez	a0,382 <gets+0x52>
    buf[i++] = c;
 36a:	faf44783          	lbu	a5,-81(s0)
 36e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 372:	01578763          	beq	a5,s5,380 <gets+0x50>
 376:	0905                	addi	s2,s2,1
 378:	fd679de3          	bne	a5,s6,352 <gets+0x22>
  for(i=0; i+1 < max; ){
 37c:	89a6                	mv	s3,s1
 37e:	a011                	j	382 <gets+0x52>
 380:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 382:	99de                	add	s3,s3,s7
 384:	00098023          	sb	zero,0(s3)
  return buf;
}
 388:	855e                	mv	a0,s7
 38a:	60e6                	ld	ra,88(sp)
 38c:	6446                	ld	s0,80(sp)
 38e:	64a6                	ld	s1,72(sp)
 390:	6906                	ld	s2,64(sp)
 392:	79e2                	ld	s3,56(sp)
 394:	7a42                	ld	s4,48(sp)
 396:	7aa2                	ld	s5,40(sp)
 398:	7b02                	ld	s6,32(sp)
 39a:	6be2                	ld	s7,24(sp)
 39c:	6125                	addi	sp,sp,96
 39e:	8082                	ret

00000000000003a0 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
 3a0:	1101                	addi	sp,sp,-32
 3a2:	ec06                	sd	ra,24(sp)
 3a4:	e822                	sd	s0,16(sp)
 3a6:	e426                	sd	s1,8(sp)
 3a8:	e04a                	sd	s2,0(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ae:	4581                	li	a1,0
 3b0:	18e000ef          	jal	ra,53e <open>
  if(fd < 0)
 3b4:	02054163          	bltz	a0,3d6 <stat+0x36>
 3b8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ba:	85ca                	mv	a1,s2
 3bc:	19a000ef          	jal	ra,556 <fstat>
 3c0:	892a                	mv	s2,a0
  close(fd);
 3c2:	8526                	mv	a0,s1
 3c4:	162000ef          	jal	ra,526 <close>
  return r;
}
 3c8:	854a                	mv	a0,s2
 3ca:	60e2                	ld	ra,24(sp)
 3cc:	6442                	ld	s0,16(sp)
 3ce:	64a2                	ld	s1,8(sp)
 3d0:	6902                	ld	s2,0(sp)
 3d2:	6105                	addi	sp,sp,32
 3d4:	8082                	ret
    return -1;
 3d6:	597d                	li	s2,-1
 3d8:	bfc5                	j	3c8 <stat+0x28>

00000000000003da <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e422                	sd	s0,8(sp)
 3de:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e0:	00054603          	lbu	a2,0(a0)
 3e4:	fd06079b          	addiw	a5,a2,-48
 3e8:	0ff7f793          	andi	a5,a5,255
 3ec:	4725                	li	a4,9
 3ee:	02f76963          	bltu	a4,a5,420 <atoi+0x46>
 3f2:	86aa                	mv	a3,a0
  n = 0;
 3f4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3f6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3f8:	0685                	addi	a3,a3,1
 3fa:	0025179b          	slliw	a5,a0,0x2
 3fe:	9fa9                	addw	a5,a5,a0
 400:	0017979b          	slliw	a5,a5,0x1
 404:	9fb1                	addw	a5,a5,a2
 406:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40a:	0006c603          	lbu	a2,0(a3)
 40e:	fd06071b          	addiw	a4,a2,-48
 412:	0ff77713          	andi	a4,a4,255
 416:	fee5f1e3          	bgeu	a1,a4,3f8 <atoi+0x1e>
  return n;
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  n = 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <atoi+0x40>

0000000000000424 <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e422                	sd	s0,8(sp)
 428:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42a:	02b57463          	bgeu	a0,a1,452 <memmove+0x2e>
    while(n-- > 0)
 42e:	00c05f63          	blez	a2,44c <memmove+0x28>
 432:	1602                	slli	a2,a2,0x20
 434:	9201                	srli	a2,a2,0x20
 436:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43a:	872a                	mv	a4,a0
      *dst++ = *src++;
 43c:	0585                	addi	a1,a1,1
 43e:	0705                	addi	a4,a4,1
 440:	fff5c683          	lbu	a3,-1(a1)
 444:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 448:	fee79ae3          	bne	a5,a4,43c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
    dst += n;
 452:	00c50733          	add	a4,a0,a2
    src += n;
 456:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 458:	fec05ae3          	blez	a2,44c <memmove+0x28>
 45c:	fff6079b          	addiw	a5,a2,-1
 460:	1782                	slli	a5,a5,0x20
 462:	9381                	srli	a5,a5,0x20
 464:	fff7c793          	not	a5,a5
 468:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46a:	15fd                	addi	a1,a1,-1
 46c:	177d                	addi	a4,a4,-1
 46e:	0005c683          	lbu	a3,0(a1)
 472:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 476:	fee79ae3          	bne	a5,a4,46a <memmove+0x46>
 47a:	bfc9                	j	44c <memmove+0x28>

000000000000047c <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 482:	ca05                	beqz	a2,4b2 <memcmp+0x36>
 484:	fff6069b          	addiw	a3,a2,-1
 488:	1682                	slli	a3,a3,0x20
 48a:	9281                	srli	a3,a3,0x20
 48c:	0685                	addi	a3,a3,1
 48e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 490:	00054783          	lbu	a5,0(a0)
 494:	0005c703          	lbu	a4,0(a1)
 498:	00e79863          	bne	a5,a4,4a8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49c:	0505                	addi	a0,a0,1
    p2++;
 49e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a0:	fed518e3          	bne	a0,a3,490 <memcmp+0x14>
  }
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	a019                	j	4ac <memcmp+0x30>
      return *p1 - *p2;
 4a8:	40e7853b          	subw	a0,a5,a4
}
 4ac:	6422                	ld	s0,8(sp)
 4ae:	0141                	addi	sp,sp,16
 4b0:	8082                	ret
  return 0;
 4b2:	4501                	li	a0,0
 4b4:	bfe5                	j	4ac <memcmp+0x30>

00000000000004b6 <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e406                	sd	ra,8(sp)
 4ba:	e022                	sd	s0,0(sp)
 4bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4be:	f67ff0ef          	jal	ra,424 <memmove>
}
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret

00000000000004ca <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d2:	4585                	li	a1,1
 4d4:	0b2000ef          	jal	ra,586 <sys_sbrk>
}
 4d8:	60a2                	ld	ra,8(sp)
 4da:	6402                	ld	s0,0(sp)
 4dc:	0141                	addi	sp,sp,16
 4de:	8082                	ret

00000000000004e0 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4e8:	4589                	li	a1,2
 4ea:	09c000ef          	jal	ra,586 <sys_sbrk>
}
 4ee:	60a2                	ld	ra,8(sp)
 4f0:	6402                	ld	s0,0(sp)
 4f2:	0141                	addi	sp,sp,16
 4f4:	8082                	ret

00000000000004f6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f6:	4885                	li	a7,1
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <exit>:
.global exit
exit:
 li a7, SYS_exit
 4fe:	4889                	li	a7,2
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <wait>:
.global wait
wait:
 li a7, SYS_wait
 506:	488d                	li	a7,3
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 50e:	4891                	li	a7,4
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <read>:
.global read
read:
 li a7, SYS_read
 516:	4895                	li	a7,5
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <write>:
.global write
write:
 li a7, SYS_write
 51e:	48c1                	li	a7,16
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <close>:
.global close
close:
 li a7, SYS_close
 526:	48d5                	li	a7,21
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <kill>:
.global kill
kill:
 li a7, SYS_kill
 52e:	4899                	li	a7,6
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <exec>:
.global exec
exec:
 li a7, SYS_exec
 536:	489d                	li	a7,7
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <open>:
.global open
open:
 li a7, SYS_open
 53e:	48bd                	li	a7,15
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 546:	48c5                	li	a7,17
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 54e:	48c9                	li	a7,18
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 556:	48a1                	li	a7,8
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <link>:
.global link
link:
 li a7, SYS_link
 55e:	48cd                	li	a7,19
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 566:	48d1                	li	a7,20
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 56e:	48a5                	li	a7,9
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <dup>:
.global dup
dup:
 li a7, SYS_dup
 576:	48a9                	li	a7,10
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 57e:	48ad                	li	a7,11
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 586:	48b1                	li	a7,12
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <pause>:
.global pause
pause:
 li a7, SYS_pause
 58e:	48b5                	li	a7,13
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 596:	48b9                	li	a7,14
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 59e:	48d9                	li	a7,22
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 5a6:	48dd                	li	a7,23
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
 5ae:	48e1                	li	a7,24
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5b6:	48e5                	li	a7,25
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 5be:	48e9                	li	a7,26
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 5c6:	48ed                	li	a7,27
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 5ce:	48f1                	li	a7,28
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
 5d6:	48f5                	li	a7,29
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
 5de:	1101                	addi	sp,sp,-32
 5e0:	ec06                	sd	ra,24(sp)
 5e2:	e822                	sd	s0,16(sp)
 5e4:	1000                	addi	s0,sp,32
 5e6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ea:	4605                	li	a2,1
 5ec:	fef40593          	addi	a1,s0,-17
 5f0:	f2fff0ef          	jal	ra,51e <write>
}
 5f4:	60e2                	ld	ra,24(sp)
 5f6:	6442                	ld	s0,16(sp)
 5f8:	6105                	addi	sp,sp,32
 5fa:	8082                	ret

00000000000005fc <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
 5fc:	715d                	addi	sp,sp,-80
 5fe:	e486                	sd	ra,72(sp)
 600:	e0a2                	sd	s0,64(sp)
 602:	fc26                	sd	s1,56(sp)
 604:	f84a                	sd	s2,48(sp)
 606:	f44e                	sd	s3,40(sp)
 608:	0880                	addi	s0,sp,80
 60a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 60c:	c299                	beqz	a3,612 <printint+0x16>
 60e:	0805c163          	bltz	a1,690 <printint+0x94>
  neg = 0;
 612:	4881                	li	a7,0
 614:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 618:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 61a:	00000517          	auipc	a0,0x0
 61e:	53e50513          	addi	a0,a0,1342 # b58 <digits>
 622:	883e                	mv	a6,a5
 624:	2785                	addiw	a5,a5,1
 626:	02c5f733          	remu	a4,a1,a2
 62a:	972a                	add	a4,a4,a0
 62c:	00074703          	lbu	a4,0(a4)
 630:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 634:	872e                	mv	a4,a1
 636:	02c5d5b3          	divu	a1,a1,a2
 63a:	0685                	addi	a3,a3,1
 63c:	fec773e3          	bgeu	a4,a2,622 <printint+0x26>
  if(neg)
 640:	00088b63          	beqz	a7,656 <printint+0x5a>
    buf[i++] = '-';
 644:	fd040713          	addi	a4,s0,-48
 648:	97ba                	add	a5,a5,a4
 64a:	02d00713          	li	a4,45
 64e:	fee78423          	sb	a4,-24(a5)
 652:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 656:	02f05663          	blez	a5,682 <printint+0x86>
 65a:	fb840713          	addi	a4,s0,-72
 65e:	00f704b3          	add	s1,a4,a5
 662:	fff70993          	addi	s3,a4,-1
 666:	99be                	add	s3,s3,a5
 668:	37fd                	addiw	a5,a5,-1
 66a:	1782                	slli	a5,a5,0x20
 66c:	9381                	srli	a5,a5,0x20
 66e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 672:	fff4c583          	lbu	a1,-1(s1)
 676:	854a                	mv	a0,s2
 678:	f67ff0ef          	jal	ra,5de <putc>
  while(--i >= 0)
 67c:	14fd                	addi	s1,s1,-1
 67e:	ff349ae3          	bne	s1,s3,672 <printint+0x76>
}
 682:	60a6                	ld	ra,72(sp)
 684:	6406                	ld	s0,64(sp)
 686:	74e2                	ld	s1,56(sp)
 688:	7942                	ld	s2,48(sp)
 68a:	79a2                	ld	s3,40(sp)
 68c:	6161                	addi	sp,sp,80
 68e:	8082                	ret
    x = -xx;
 690:	40b005b3          	neg	a1,a1
    neg = 1;
 694:	4885                	li	a7,1
    x = -xx;
 696:	bfbd                	j	614 <printint+0x18>

0000000000000698 <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
 698:	7119                	addi	sp,sp,-128
 69a:	fc86                	sd	ra,120(sp)
 69c:	f8a2                	sd	s0,112(sp)
 69e:	f4a6                	sd	s1,104(sp)
 6a0:	f0ca                	sd	s2,96(sp)
 6a2:	ecce                	sd	s3,88(sp)
 6a4:	e8d2                	sd	s4,80(sp)
 6a6:	e4d6                	sd	s5,72(sp)
 6a8:	e0da                	sd	s6,64(sp)
 6aa:	fc5e                	sd	s7,56(sp)
 6ac:	f862                	sd	s8,48(sp)
 6ae:	f466                	sd	s9,40(sp)
 6b0:	f06a                	sd	s10,32(sp)
 6b2:	ec6e                	sd	s11,24(sp)
 6b4:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6b6:	0005c903          	lbu	s2,0(a1)
 6ba:	24090c63          	beqz	s2,912 <vprintf+0x27a>
 6be:	8b2a                	mv	s6,a0
 6c0:	8a2e                	mv	s4,a1
 6c2:	8bb2                	mv	s7,a2
  state = 0;
 6c4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6c6:	4481                	li	s1,0
 6c8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6ca:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6ce:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6d2:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6d6:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6da:	00000c97          	auipc	s9,0x0
 6de:	47ec8c93          	addi	s9,s9,1150 # b58 <digits>
 6e2:	a005                	j	702 <vprintf+0x6a>
        putc(fd, c0);
 6e4:	85ca                	mv	a1,s2
 6e6:	855a                	mv	a0,s6
 6e8:	ef7ff0ef          	jal	ra,5de <putc>
 6ec:	a019                	j	6f2 <vprintf+0x5a>
    } else if(state == '%'){
 6ee:	03598263          	beq	s3,s5,712 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6f2:	2485                	addiw	s1,s1,1
 6f4:	8726                	mv	a4,s1
 6f6:	009a07b3          	add	a5,s4,s1
 6fa:	0007c903          	lbu	s2,0(a5)
 6fe:	20090a63          	beqz	s2,912 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 702:	0009079b          	sext.w	a5,s2
    if(state == 0){
 706:	fe0994e3          	bnez	s3,6ee <vprintf+0x56>
      if(c0 == '%'){
 70a:	fd579de3          	bne	a5,s5,6e4 <vprintf+0x4c>
        state = '%';
 70e:	89be                	mv	s3,a5
 710:	b7cd                	j	6f2 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 712:	c3c1                	beqz	a5,792 <vprintf+0xfa>
 714:	00ea06b3          	add	a3,s4,a4
 718:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 71c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 71e:	c681                	beqz	a3,726 <vprintf+0x8e>
 720:	9752                	add	a4,a4,s4
 722:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 726:	03878e63          	beq	a5,s8,762 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 72a:	05a78863          	beq	a5,s10,77a <vprintf+0xe2>
      } else if(c0 == 'u'){
 72e:	0db78b63          	beq	a5,s11,804 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 732:	07800713          	li	a4,120
 736:	10e78d63          	beq	a5,a4,850 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 73a:	07000713          	li	a4,112
 73e:	14e78263          	beq	a5,a4,882 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 742:	06300713          	li	a4,99
 746:	16e78f63          	beq	a5,a4,8c4 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 74a:	07300713          	li	a4,115
 74e:	18e78563          	beq	a5,a4,8d8 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 752:	05579063          	bne	a5,s5,792 <vprintf+0xfa>
        putc(fd, '%');
 756:	85d6                	mv	a1,s5
 758:	855a                	mv	a0,s6
 75a:	e85ff0ef          	jal	ra,5de <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 75e:	4981                	li	s3,0
 760:	bf49                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 762:	008b8913          	addi	s2,s7,8
 766:	4685                	li	a3,1
 768:	4629                	li	a2,10
 76a:	000ba583          	lw	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	e8dff0ef          	jal	ra,5fc <printint>
 774:	8bca                	mv	s7,s2
      state = 0;
 776:	4981                	li	s3,0
 778:	bfad                	j	6f2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 77a:	03868663          	beq	a3,s8,7a6 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 77e:	05a68163          	beq	a3,s10,7c0 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 782:	09b68d63          	beq	a3,s11,81c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 786:	03a68f63          	beq	a3,s10,7c4 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 78a:	07800793          	li	a5,120
 78e:	0cf68d63          	beq	a3,a5,868 <vprintf+0x1d0>
        putc(fd, '%');
 792:	85d6                	mv	a1,s5
 794:	855a                	mv	a0,s6
 796:	e49ff0ef          	jal	ra,5de <putc>
        putc(fd, c0);
 79a:	85ca                	mv	a1,s2
 79c:	855a                	mv	a0,s6
 79e:	e41ff0ef          	jal	ra,5de <putc>
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b7b9                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a6:	008b8913          	addi	s2,s7,8
 7aa:	4685                	li	a3,1
 7ac:	4629                	li	a2,10
 7ae:	000bb583          	ld	a1,0(s7)
 7b2:	855a                	mv	a0,s6
 7b4:	e49ff0ef          	jal	ra,5fc <printint>
        i += 1;
 7b8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ba:	8bca                	mv	s7,s2
      state = 0;
 7bc:	4981                	li	s3,0
        i += 1;
 7be:	bf15                	j	6f2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7c0:	03860563          	beq	a2,s8,7ea <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7c4:	07b60963          	beq	a2,s11,836 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7c8:	07800793          	li	a5,120
 7cc:	fcf613e3          	bne	a2,a5,792 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d0:	008b8913          	addi	s2,s7,8
 7d4:	4681                	li	a3,0
 7d6:	4641                	li	a2,16
 7d8:	000bb583          	ld	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	e1fff0ef          	jal	ra,5fc <printint>
        i += 2;
 7e2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7e4:	8bca                	mv	s7,s2
      state = 0;
 7e6:	4981                	li	s3,0
        i += 2;
 7e8:	b729                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ea:	008b8913          	addi	s2,s7,8
 7ee:	4685                	li	a3,1
 7f0:	4629                	li	a2,10
 7f2:	000bb583          	ld	a1,0(s7)
 7f6:	855a                	mv	a0,s6
 7f8:	e05ff0ef          	jal	ra,5fc <printint>
        i += 2;
 7fc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7fe:	8bca                	mv	s7,s2
      state = 0;
 800:	4981                	li	s3,0
        i += 2;
 802:	bdc5                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 804:	008b8913          	addi	s2,s7,8
 808:	4681                	li	a3,0
 80a:	4629                	li	a2,10
 80c:	000be583          	lwu	a1,0(s7)
 810:	855a                	mv	a0,s6
 812:	debff0ef          	jal	ra,5fc <printint>
 816:	8bca                	mv	s7,s2
      state = 0;
 818:	4981                	li	s3,0
 81a:	bde1                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 81c:	008b8913          	addi	s2,s7,8
 820:	4681                	li	a3,0
 822:	4629                	li	a2,10
 824:	000bb583          	ld	a1,0(s7)
 828:	855a                	mv	a0,s6
 82a:	dd3ff0ef          	jal	ra,5fc <printint>
        i += 1;
 82e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 830:	8bca                	mv	s7,s2
      state = 0;
 832:	4981                	li	s3,0
        i += 1;
 834:	bd7d                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 836:	008b8913          	addi	s2,s7,8
 83a:	4681                	li	a3,0
 83c:	4629                	li	a2,10
 83e:	000bb583          	ld	a1,0(s7)
 842:	855a                	mv	a0,s6
 844:	db9ff0ef          	jal	ra,5fc <printint>
        i += 2;
 848:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 84a:	8bca                	mv	s7,s2
      state = 0;
 84c:	4981                	li	s3,0
        i += 2;
 84e:	b555                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 850:	008b8913          	addi	s2,s7,8
 854:	4681                	li	a3,0
 856:	4641                	li	a2,16
 858:	000be583          	lwu	a1,0(s7)
 85c:	855a                	mv	a0,s6
 85e:	d9fff0ef          	jal	ra,5fc <printint>
 862:	8bca                	mv	s7,s2
      state = 0;
 864:	4981                	li	s3,0
 866:	b571                	j	6f2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 868:	008b8913          	addi	s2,s7,8
 86c:	4681                	li	a3,0
 86e:	4641                	li	a2,16
 870:	000bb583          	ld	a1,0(s7)
 874:	855a                	mv	a0,s6
 876:	d87ff0ef          	jal	ra,5fc <printint>
        i += 1;
 87a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 87c:	8bca                	mv	s7,s2
      state = 0;
 87e:	4981                	li	s3,0
        i += 1;
 880:	bd8d                	j	6f2 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 882:	008b8793          	addi	a5,s7,8
 886:	f8f43423          	sd	a5,-120(s0)
 88a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 88e:	03000593          	li	a1,48
 892:	855a                	mv	a0,s6
 894:	d4bff0ef          	jal	ra,5de <putc>
  putc(fd, 'x');
 898:	07800593          	li	a1,120
 89c:	855a                	mv	a0,s6
 89e:	d41ff0ef          	jal	ra,5de <putc>
 8a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8a4:	03c9d793          	srli	a5,s3,0x3c
 8a8:	97e6                	add	a5,a5,s9
 8aa:	0007c583          	lbu	a1,0(a5)
 8ae:	855a                	mv	a0,s6
 8b0:	d2fff0ef          	jal	ra,5de <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8b4:	0992                	slli	s3,s3,0x4
 8b6:	397d                	addiw	s2,s2,-1
 8b8:	fe0916e3          	bnez	s2,8a4 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 8bc:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	bd05                	j	6f2 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 8c4:	008b8913          	addi	s2,s7,8
 8c8:	000bc583          	lbu	a1,0(s7)
 8cc:	855a                	mv	a0,s6
 8ce:	d11ff0ef          	jal	ra,5de <putc>
 8d2:	8bca                	mv	s7,s2
      state = 0;
 8d4:	4981                	li	s3,0
 8d6:	bd31                	j	6f2 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 8d8:	008b8993          	addi	s3,s7,8
 8dc:	000bb903          	ld	s2,0(s7)
 8e0:	00090f63          	beqz	s2,8fe <vprintf+0x266>
        for(; *s; s++)
 8e4:	00094583          	lbu	a1,0(s2)
 8e8:	c195                	beqz	a1,90c <vprintf+0x274>
          putc(fd, *s);
 8ea:	855a                	mv	a0,s6
 8ec:	cf3ff0ef          	jal	ra,5de <putc>
        for(; *s; s++)
 8f0:	0905                	addi	s2,s2,1
 8f2:	00094583          	lbu	a1,0(s2)
 8f6:	f9f5                	bnez	a1,8ea <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8f8:	8bce                	mv	s7,s3
      state = 0;
 8fa:	4981                	li	s3,0
 8fc:	bbdd                	j	6f2 <vprintf+0x5a>
          s = "(null)";
 8fe:	00000917          	auipc	s2,0x0
 902:	25290913          	addi	s2,s2,594 # b50 <malloc+0x13c>
        for(; *s; s++)
 906:	02800593          	li	a1,40
 90a:	b7c5                	j	8ea <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 90c:	8bce                	mv	s7,s3
      state = 0;
 90e:	4981                	li	s3,0
 910:	b3cd                	j	6f2 <vprintf+0x5a>
    }
  }
}
 912:	70e6                	ld	ra,120(sp)
 914:	7446                	ld	s0,112(sp)
 916:	74a6                	ld	s1,104(sp)
 918:	7906                	ld	s2,96(sp)
 91a:	69e6                	ld	s3,88(sp)
 91c:	6a46                	ld	s4,80(sp)
 91e:	6aa6                	ld	s5,72(sp)
 920:	6b06                	ld	s6,64(sp)
 922:	7be2                	ld	s7,56(sp)
 924:	7c42                	ld	s8,48(sp)
 926:	7ca2                	ld	s9,40(sp)
 928:	7d02                	ld	s10,32(sp)
 92a:	6de2                	ld	s11,24(sp)
 92c:	6109                	addi	sp,sp,128
 92e:	8082                	ret

0000000000000930 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
 930:	715d                	addi	sp,sp,-80
 932:	ec06                	sd	ra,24(sp)
 934:	e822                	sd	s0,16(sp)
 936:	1000                	addi	s0,sp,32
 938:	e010                	sd	a2,0(s0)
 93a:	e414                	sd	a3,8(s0)
 93c:	e818                	sd	a4,16(s0)
 93e:	ec1c                	sd	a5,24(s0)
 940:	03043023          	sd	a6,32(s0)
 944:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 948:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 94c:	8622                	mv	a2,s0
 94e:	d4bff0ef          	jal	ra,698 <vprintf>
}
 952:	60e2                	ld	ra,24(sp)
 954:	6442                	ld	s0,16(sp)
 956:	6161                	addi	sp,sp,80
 958:	8082                	ret

000000000000095a <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
 95a:	711d                	addi	sp,sp,-96
 95c:	ec06                	sd	ra,24(sp)
 95e:	e822                	sd	s0,16(sp)
 960:	1000                	addi	s0,sp,32
 962:	e40c                	sd	a1,8(s0)
 964:	e810                	sd	a2,16(s0)
 966:	ec14                	sd	a3,24(s0)
 968:	f018                	sd	a4,32(s0)
 96a:	f41c                	sd	a5,40(s0)
 96c:	03043823          	sd	a6,48(s0)
 970:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 974:	00840613          	addi	a2,s0,8
 978:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 97c:	85aa                	mv	a1,a0
 97e:	4505                	li	a0,1
 980:	d19ff0ef          	jal	ra,698 <vprintf>
}
 984:	60e2                	ld	ra,24(sp)
 986:	6442                	ld	s0,16(sp)
 988:	6125                	addi	sp,sp,96
 98a:	8082                	ret

000000000000098c <free>:
 *   无
 */

void
free(void *ap)
{
 98c:	1141                	addi	sp,sp,-16
 98e:	e422                	sd	s0,8(sp)
 990:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
 992:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 996:	00000797          	auipc	a5,0x0
 99a:	66a7b783          	ld	a5,1642(a5) # 1000 <freep>
 99e:	a805                	j	9ce <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a0:	4618                	lw	a4,8(a2)
 9a2:	9db9                	addw	a1,a1,a4
 9a4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a8:	6398                	ld	a4,0(a5)
 9aa:	6318                	ld	a4,0(a4)
 9ac:	fee53823          	sd	a4,-16(a0)
 9b0:	a091                	j	9f4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b2:	ff852703          	lw	a4,-8(a0)
 9b6:	9e39                	addw	a2,a2,a4
 9b8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9ba:	ff053703          	ld	a4,-16(a0)
 9be:	e398                	sd	a4,0(a5)
 9c0:	a099                	j	a06 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c2:	6398                	ld	a4,0(a5)
 9c4:	00e7e463          	bltu	a5,a4,9cc <free+0x40>
 9c8:	00e6ea63          	bltu	a3,a4,9dc <free+0x50>
{
 9cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ce:	fed7fae3          	bgeu	a5,a3,9c2 <free+0x36>
 9d2:	6398                	ld	a4,0(a5)
 9d4:	00e6e463          	bltu	a3,a4,9dc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d8:	fee7eae3          	bltu	a5,a4,9cc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9dc:	ff852583          	lw	a1,-8(a0)
 9e0:	6390                	ld	a2,0(a5)
 9e2:	02059713          	slli	a4,a1,0x20
 9e6:	9301                	srli	a4,a4,0x20
 9e8:	0712                	slli	a4,a4,0x4
 9ea:	9736                	add	a4,a4,a3
 9ec:	fae60ae3          	beq	a2,a4,9a0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9f4:	4790                	lw	a2,8(a5)
 9f6:	02061713          	slli	a4,a2,0x20
 9fa:	9301                	srli	a4,a4,0x20
 9fc:	0712                	slli	a4,a4,0x4
 9fe:	973e                	add	a4,a4,a5
 a00:	fae689e3          	beq	a3,a4,9b2 <free+0x26>
  } else
    p->s.ptr = bp;
 a04:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
 a06:	00000717          	auipc	a4,0x0
 a0a:	5ef73d23          	sd	a5,1530(a4) # 1000 <freep>
}
 a0e:	6422                	ld	s0,8(sp)
 a10:	0141                	addi	sp,sp,16
 a12:	8082                	ret

0000000000000a14 <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
 a14:	7139                	addi	sp,sp,-64
 a16:	fc06                	sd	ra,56(sp)
 a18:	f822                	sd	s0,48(sp)
 a1a:	f426                	sd	s1,40(sp)
 a1c:	f04a                	sd	s2,32(sp)
 a1e:	ec4e                	sd	s3,24(sp)
 a20:	e852                	sd	s4,16(sp)
 a22:	e456                	sd	s5,8(sp)
 a24:	e05a                	sd	s6,0(sp)
 a26:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a28:	02051493          	slli	s1,a0,0x20
 a2c:	9081                	srli	s1,s1,0x20
 a2e:	04bd                	addi	s1,s1,15
 a30:	8091                	srli	s1,s1,0x4
 a32:	0014899b          	addiw	s3,s1,1
 a36:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
 a38:	00000517          	auipc	a0,0x0
 a3c:	5c853503          	ld	a0,1480(a0) # 1000 <freep>
 a40:	c515                	beqz	a0,a6c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a42:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 a44:	4798                	lw	a4,8(a5)
 a46:	02977f63          	bgeu	a4,s1,a84 <malloc+0x70>
 a4a:	8a4e                	mv	s4,s3
 a4c:	0009871b          	sext.w	a4,s3
 a50:	6685                	lui	a3,0x1
 a52:	00d77363          	bgeu	a4,a3,a58 <malloc+0x44>
 a56:	6a05                	lui	s4,0x1
 a58:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 a5c:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
 a60:	00000917          	auipc	s2,0x0
 a64:	5a090913          	addi	s2,s2,1440 # 1000 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 a68:	5afd                	li	s5,-1
 a6a:	a0bd                	j	ad8 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 a6c:	00000797          	auipc	a5,0x0
 a70:	5b478793          	addi	a5,a5,1460 # 1020 <base>
 a74:	00000717          	auipc	a4,0x0
 a78:	58f73623          	sd	a5,1420(a4) # 1000 <freep>
 a7c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a7e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 a82:	b7e1                	j	a4a <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
 a84:	02e48b63          	beq	s1,a4,aba <malloc+0xa6>
        p->s.size -= nunits;
 a88:	4137073b          	subw	a4,a4,s3
 a8c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a8e:	1702                	slli	a4,a4,0x20
 a90:	9301                	srli	a4,a4,0x20
 a92:	0712                	slli	a4,a4,0x4
 a94:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a96:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
 a9a:	00000717          	auipc	a4,0x0
 a9e:	56a73323          	sd	a0,1382(a4) # 1000 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
 aa2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
 aa6:	70e2                	ld	ra,56(sp)
 aa8:	7442                	ld	s0,48(sp)
 aaa:	74a2                	ld	s1,40(sp)
 aac:	7902                	ld	s2,32(sp)
 aae:	69e2                	ld	s3,24(sp)
 ab0:	6a42                	ld	s4,16(sp)
 ab2:	6aa2                	ld	s5,8(sp)
 ab4:	6b02                	ld	s6,0(sp)
 ab6:	6121                	addi	sp,sp,64
 ab8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 aba:	6398                	ld	a4,0(a5)
 abc:	e118                	sd	a4,0(a0)
 abe:	bff1                	j	a9a <malloc+0x86>
  hp->s.size = nu;
 ac0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
 ac4:	0541                	addi	a0,a0,16
 ac6:	ec7ff0ef          	jal	ra,98c <free>
  return freep;
 aca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ace:	dd61                	beqz	a0,aa6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
 ad2:	4798                	lw	a4,8(a5)
 ad4:	fa9778e3          	bgeu	a4,s1,a84 <malloc+0x70>
    if(p == freep)
 ad8:	00093703          	ld	a4,0(s2)
 adc:	853e                	mv	a0,a5
 ade:	fef719e3          	bne	a4,a5,ad0 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
 ae2:	8552                	mv	a0,s4
 ae4:	9e7ff0ef          	jal	ra,4ca <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
 ae8:	fd551ce3          	bne	a0,s5,ac0 <malloc+0xac>
        return 0;  /* 内存分配失败 */
 aec:	4501                	li	a0,0
 aee:	bf65                	j	aa6 <malloc+0x92>
