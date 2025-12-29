
user/_sh：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	1de58593          	addi	a1,a1,478 # 11f0 <malloc+0xe6>
      1a:	4509                	li	a0,2
      1c:	42f000ef          	jal	ra,c4a <write>
  memset(buf, 0, nbuf);
      20:	864a                	mv	a2,s2
      22:	4581                	li	a1,0
      24:	8526                	mv	a0,s1
      26:	1f3000ef          	jal	ra,a18 <memset>
  gets(buf, nbuf);
      2a:	85ca                	mv	a1,s2
      2c:	8526                	mv	a0,s1
      2e:	231000ef          	jal	ra,a5e <gets>
  if(buf[0] == 0) // EOF
      32:	0004c503          	lbu	a0,0(s1)
      36:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      3a:	40a00533          	neg	a0,a0
      3e:	60e2                	ld	ra,24(sp)
      40:	6442                	ld	s0,16(sp)
      42:	64a2                	ld	s1,8(sp)
      44:	6902                	ld	s2,0(sp)
      46:	6105                	addi	sp,sp,32
      48:	8082                	ret

000000000000004a <panic>:
  exit(0);
}

void
panic(char *s)
{
      4a:	1141                	addi	sp,sp,-16
      4c:	e406                	sd	ra,8(sp)
      4e:	e022                	sd	s0,0(sp)
      50:	0800                	addi	s0,sp,16
      52:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      54:	00001597          	auipc	a1,0x1
      58:	1a458593          	addi	a1,a1,420 # 11f8 <malloc+0xee>
      5c:	4509                	li	a0,2
      5e:	7cf000ef          	jal	ra,102c <fprintf>
  exit(1);
      62:	4505                	li	a0,1
      64:	3c7000ef          	jal	ra,c2a <exit>

0000000000000068 <fork1>:
}

int
fork1(void)
{
      68:	1141                	addi	sp,sp,-16
      6a:	e406                	sd	ra,8(sp)
      6c:	e022                	sd	s0,0(sp)
      6e:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      70:	3b3000ef          	jal	ra,c22 <fork>
  if(pid == -1)
      74:	57fd                	li	a5,-1
      76:	00f50663          	beq	a0,a5,82 <fork1+0x1a>
    panic("fork");
  return pid;
}
      7a:	60a2                	ld	ra,8(sp)
      7c:	6402                	ld	s0,0(sp)
      7e:	0141                	addi	sp,sp,16
      80:	8082                	ret
    panic("fork");
      82:	00001517          	auipc	a0,0x1
      86:	17e50513          	addi	a0,a0,382 # 1200 <malloc+0xf6>
      8a:	fc1ff0ef          	jal	ra,4a <panic>

000000000000008e <runcmd>:
{
      8e:	7179                	addi	sp,sp,-48
      90:	f406                	sd	ra,40(sp)
      92:	f022                	sd	s0,32(sp)
      94:	ec26                	sd	s1,24(sp)
      96:	1800                	addi	s0,sp,48
  if(cmd == 0)
      98:	c10d                	beqz	a0,ba <runcmd+0x2c>
      9a:	84aa                	mv	s1,a0
  switch(cmd->type){
      9c:	4118                	lw	a4,0(a0)
      9e:	4795                	li	a5,5
      a0:	02e7e063          	bltu	a5,a4,c0 <runcmd+0x32>
      a4:	00056783          	lwu	a5,0(a0)
      a8:	078a                	slli	a5,a5,0x2
      aa:	00001717          	auipc	a4,0x1
      ae:	25670713          	addi	a4,a4,598 # 1300 <malloc+0x1f6>
      b2:	97ba                	add	a5,a5,a4
      b4:	439c                	lw	a5,0(a5)
      b6:	97ba                	add	a5,a5,a4
      b8:	8782                	jr	a5
    exit(1);
      ba:	4505                	li	a0,1
      bc:	36f000ef          	jal	ra,c2a <exit>
    panic("runcmd");
      c0:	00001517          	auipc	a0,0x1
      c4:	14850513          	addi	a0,a0,328 # 1208 <malloc+0xfe>
      c8:	f83ff0ef          	jal	ra,4a <panic>
    if(ecmd->argv[0] == 0)
      cc:	6508                	ld	a0,8(a0)
      ce:	c105                	beqz	a0,ee <runcmd+0x60>
    exec(ecmd->argv[0], ecmd->argv);
      d0:	00848593          	addi	a1,s1,8
      d4:	38f000ef          	jal	ra,c62 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
      d8:	6490                	ld	a2,8(s1)
      da:	00001597          	auipc	a1,0x1
      de:	13658593          	addi	a1,a1,310 # 1210 <malloc+0x106>
      e2:	4509                	li	a0,2
      e4:	749000ef          	jal	ra,102c <fprintf>
  exit(0);
      e8:	4501                	li	a0,0
      ea:	341000ef          	jal	ra,c2a <exit>
      exit(1);
      ee:	4505                	li	a0,1
      f0:	33b000ef          	jal	ra,c2a <exit>
    close(rcmd->fd);
      f4:	5148                	lw	a0,36(a0)
      f6:	35d000ef          	jal	ra,c52 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      fa:	508c                	lw	a1,32(s1)
      fc:	6888                	ld	a0,16(s1)
      fe:	36d000ef          	jal	ra,c6a <open>
     102:	00054563          	bltz	a0,10c <runcmd+0x7e>
    runcmd(rcmd->cmd);
     106:	6488                	ld	a0,8(s1)
     108:	f87ff0ef          	jal	ra,8e <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     10c:	6890                	ld	a2,16(s1)
     10e:	00001597          	auipc	a1,0x1
     112:	11258593          	addi	a1,a1,274 # 1220 <malloc+0x116>
     116:	4509                	li	a0,2
     118:	715000ef          	jal	ra,102c <fprintf>
      exit(1);
     11c:	4505                	li	a0,1
     11e:	30d000ef          	jal	ra,c2a <exit>
    if(fork1() == 0)
     122:	f47ff0ef          	jal	ra,68 <fork1>
     126:	e501                	bnez	a0,12e <runcmd+0xa0>
      runcmd(lcmd->left);
     128:	6488                	ld	a0,8(s1)
     12a:	f65ff0ef          	jal	ra,8e <runcmd>
    wait(0);
     12e:	4501                	li	a0,0
     130:	303000ef          	jal	ra,c32 <wait>
    runcmd(lcmd->right);
     134:	6888                	ld	a0,16(s1)
     136:	f59ff0ef          	jal	ra,8e <runcmd>
    if(pipe(p) < 0)
     13a:	fd840513          	addi	a0,s0,-40
     13e:	2fd000ef          	jal	ra,c3a <pipe>
     142:	02054763          	bltz	a0,170 <runcmd+0xe2>
    if(fork1() == 0){
     146:	f23ff0ef          	jal	ra,68 <fork1>
     14a:	e90d                	bnez	a0,17c <runcmd+0xee>
      close(1);
     14c:	4505                	li	a0,1
     14e:	305000ef          	jal	ra,c52 <close>
      dup(p[1]);
     152:	fdc42503          	lw	a0,-36(s0)
     156:	34d000ef          	jal	ra,ca2 <dup>
      close(p[0]);
     15a:	fd842503          	lw	a0,-40(s0)
     15e:	2f5000ef          	jal	ra,c52 <close>
      close(p[1]);
     162:	fdc42503          	lw	a0,-36(s0)
     166:	2ed000ef          	jal	ra,c52 <close>
      runcmd(pcmd->left);
     16a:	6488                	ld	a0,8(s1)
     16c:	f23ff0ef          	jal	ra,8e <runcmd>
      panic("pipe");
     170:	00001517          	auipc	a0,0x1
     174:	0c050513          	addi	a0,a0,192 # 1230 <malloc+0x126>
     178:	ed3ff0ef          	jal	ra,4a <panic>
    if(fork1() == 0){
     17c:	eedff0ef          	jal	ra,68 <fork1>
     180:	e115                	bnez	a0,1a4 <runcmd+0x116>
      close(0);
     182:	2d1000ef          	jal	ra,c52 <close>
      dup(p[0]);
     186:	fd842503          	lw	a0,-40(s0)
     18a:	319000ef          	jal	ra,ca2 <dup>
      close(p[0]);
     18e:	fd842503          	lw	a0,-40(s0)
     192:	2c1000ef          	jal	ra,c52 <close>
      close(p[1]);
     196:	fdc42503          	lw	a0,-36(s0)
     19a:	2b9000ef          	jal	ra,c52 <close>
      runcmd(pcmd->right);
     19e:	6888                	ld	a0,16(s1)
     1a0:	eefff0ef          	jal	ra,8e <runcmd>
    close(p[0]);
     1a4:	fd842503          	lw	a0,-40(s0)
     1a8:	2ab000ef          	jal	ra,c52 <close>
    close(p[1]);
     1ac:	fdc42503          	lw	a0,-36(s0)
     1b0:	2a3000ef          	jal	ra,c52 <close>
    wait(0);
     1b4:	4501                	li	a0,0
     1b6:	27d000ef          	jal	ra,c32 <wait>
    wait(0);
     1ba:	4501                	li	a0,0
     1bc:	277000ef          	jal	ra,c32 <wait>
    break;
     1c0:	b725                	j	e8 <runcmd+0x5a>
    if(fork1() == 0)
     1c2:	ea7ff0ef          	jal	ra,68 <fork1>
     1c6:	f20511e3          	bnez	a0,e8 <runcmd+0x5a>
      runcmd(bcmd->cmd);
     1ca:	6488                	ld	a0,8(s1)
     1cc:	ec3ff0ef          	jal	ra,8e <runcmd>

00000000000001d0 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     1d0:	1101                	addi	sp,sp,-32
     1d2:	ec06                	sd	ra,24(sp)
     1d4:	e822                	sd	s0,16(sp)
     1d6:	e426                	sd	s1,8(sp)
     1d8:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     1da:	0a800513          	li	a0,168
     1de:	72d000ef          	jal	ra,110a <malloc>
     1e2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     1e4:	0a800613          	li	a2,168
     1e8:	4581                	li	a1,0
     1ea:	02f000ef          	jal	ra,a18 <memset>
  cmd->type = EXEC;
     1ee:	4785                	li	a5,1
     1f0:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     1f2:	8526                	mv	a0,s1
     1f4:	60e2                	ld	ra,24(sp)
     1f6:	6442                	ld	s0,16(sp)
     1f8:	64a2                	ld	s1,8(sp)
     1fa:	6105                	addi	sp,sp,32
     1fc:	8082                	ret

00000000000001fe <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     1fe:	7139                	addi	sp,sp,-64
     200:	fc06                	sd	ra,56(sp)
     202:	f822                	sd	s0,48(sp)
     204:	f426                	sd	s1,40(sp)
     206:	f04a                	sd	s2,32(sp)
     208:	ec4e                	sd	s3,24(sp)
     20a:	e852                	sd	s4,16(sp)
     20c:	e456                	sd	s5,8(sp)
     20e:	e05a                	sd	s6,0(sp)
     210:	0080                	addi	s0,sp,64
     212:	8b2a                	mv	s6,a0
     214:	8aae                	mv	s5,a1
     216:	8a32                	mv	s4,a2
     218:	89b6                	mv	s3,a3
     21a:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     21c:	02800513          	li	a0,40
     220:	6eb000ef          	jal	ra,110a <malloc>
     224:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     226:	02800613          	li	a2,40
     22a:	4581                	li	a1,0
     22c:	7ec000ef          	jal	ra,a18 <memset>
  cmd->type = REDIR;
     230:	4789                	li	a5,2
     232:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     234:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     238:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     23c:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     240:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     244:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     248:	8526                	mv	a0,s1
     24a:	70e2                	ld	ra,56(sp)
     24c:	7442                	ld	s0,48(sp)
     24e:	74a2                	ld	s1,40(sp)
     250:	7902                	ld	s2,32(sp)
     252:	69e2                	ld	s3,24(sp)
     254:	6a42                	ld	s4,16(sp)
     256:	6aa2                	ld	s5,8(sp)
     258:	6b02                	ld	s6,0(sp)
     25a:	6121                	addi	sp,sp,64
     25c:	8082                	ret

000000000000025e <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     25e:	7179                	addi	sp,sp,-48
     260:	f406                	sd	ra,40(sp)
     262:	f022                	sd	s0,32(sp)
     264:	ec26                	sd	s1,24(sp)
     266:	e84a                	sd	s2,16(sp)
     268:	e44e                	sd	s3,8(sp)
     26a:	1800                	addi	s0,sp,48
     26c:	89aa                	mv	s3,a0
     26e:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     270:	4561                	li	a0,24
     272:	699000ef          	jal	ra,110a <malloc>
     276:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     278:	4661                	li	a2,24
     27a:	4581                	li	a1,0
     27c:	79c000ef          	jal	ra,a18 <memset>
  cmd->type = PIPE;
     280:	478d                	li	a5,3
     282:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     284:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     288:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     28c:	8526                	mv	a0,s1
     28e:	70a2                	ld	ra,40(sp)
     290:	7402                	ld	s0,32(sp)
     292:	64e2                	ld	s1,24(sp)
     294:	6942                	ld	s2,16(sp)
     296:	69a2                	ld	s3,8(sp)
     298:	6145                	addi	sp,sp,48
     29a:	8082                	ret

000000000000029c <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     29c:	7179                	addi	sp,sp,-48
     29e:	f406                	sd	ra,40(sp)
     2a0:	f022                	sd	s0,32(sp)
     2a2:	ec26                	sd	s1,24(sp)
     2a4:	e84a                	sd	s2,16(sp)
     2a6:	e44e                	sd	s3,8(sp)
     2a8:	1800                	addi	s0,sp,48
     2aa:	89aa                	mv	s3,a0
     2ac:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2ae:	4561                	li	a0,24
     2b0:	65b000ef          	jal	ra,110a <malloc>
     2b4:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2b6:	4661                	li	a2,24
     2b8:	4581                	li	a1,0
     2ba:	75e000ef          	jal	ra,a18 <memset>
  cmd->type = LIST;
     2be:	4791                	li	a5,4
     2c0:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     2c2:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     2c6:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     2ca:	8526                	mv	a0,s1
     2cc:	70a2                	ld	ra,40(sp)
     2ce:	7402                	ld	s0,32(sp)
     2d0:	64e2                	ld	s1,24(sp)
     2d2:	6942                	ld	s2,16(sp)
     2d4:	69a2                	ld	s3,8(sp)
     2d6:	6145                	addi	sp,sp,48
     2d8:	8082                	ret

00000000000002da <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     2da:	1101                	addi	sp,sp,-32
     2dc:	ec06                	sd	ra,24(sp)
     2de:	e822                	sd	s0,16(sp)
     2e0:	e426                	sd	s1,8(sp)
     2e2:	e04a                	sd	s2,0(sp)
     2e4:	1000                	addi	s0,sp,32
     2e6:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2e8:	4541                	li	a0,16
     2ea:	621000ef          	jal	ra,110a <malloc>
     2ee:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2f0:	4641                	li	a2,16
     2f2:	4581                	li	a1,0
     2f4:	724000ef          	jal	ra,a18 <memset>
  cmd->type = BACK;
     2f8:	4795                	li	a5,5
     2fa:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2fc:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     300:	8526                	mv	a0,s1
     302:	60e2                	ld	ra,24(sp)
     304:	6442                	ld	s0,16(sp)
     306:	64a2                	ld	s1,8(sp)
     308:	6902                	ld	s2,0(sp)
     30a:	6105                	addi	sp,sp,32
     30c:	8082                	ret

000000000000030e <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     30e:	7139                	addi	sp,sp,-64
     310:	fc06                	sd	ra,56(sp)
     312:	f822                	sd	s0,48(sp)
     314:	f426                	sd	s1,40(sp)
     316:	f04a                	sd	s2,32(sp)
     318:	ec4e                	sd	s3,24(sp)
     31a:	e852                	sd	s4,16(sp)
     31c:	e456                	sd	s5,8(sp)
     31e:	e05a                	sd	s6,0(sp)
     320:	0080                	addi	s0,sp,64
     322:	8a2a                	mv	s4,a0
     324:	892e                	mv	s2,a1
     326:	8ab2                	mv	s5,a2
     328:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     32a:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     32c:	00002997          	auipc	s3,0x2
     330:	cdc98993          	addi	s3,s3,-804 # 2008 <whitespace>
     334:	00b4fc63          	bgeu	s1,a1,34c <gettoken+0x3e>
     338:	0004c583          	lbu	a1,0(s1)
     33c:	854e                	mv	a0,s3
     33e:	6fc000ef          	jal	ra,a3a <strchr>
     342:	c509                	beqz	a0,34c <gettoken+0x3e>
    s++;
     344:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     346:	fe9919e3          	bne	s2,s1,338 <gettoken+0x2a>
    s++;
     34a:	84ca                	mv	s1,s2
  if(q)
     34c:	000a8463          	beqz	s5,354 <gettoken+0x46>
    *q = s;
     350:	009ab023          	sd	s1,0(s5)
  ret = *s;
     354:	0004c783          	lbu	a5,0(s1)
     358:	00078a9b          	sext.w	s5,a5
  switch(*s){
     35c:	03c00713          	li	a4,60
     360:	06f76463          	bltu	a4,a5,3c8 <gettoken+0xba>
     364:	03a00713          	li	a4,58
     368:	00f76e63          	bltu	a4,a5,384 <gettoken+0x76>
     36c:	cf89                	beqz	a5,386 <gettoken+0x78>
     36e:	02600713          	li	a4,38
     372:	00e78963          	beq	a5,a4,384 <gettoken+0x76>
     376:	fd87879b          	addiw	a5,a5,-40
     37a:	0ff7f793          	zext.b	a5,a5
     37e:	4705                	li	a4,1
     380:	06f76b63          	bltu	a4,a5,3f6 <gettoken+0xe8>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     384:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     386:	000b0463          	beqz	s6,38e <gettoken+0x80>
    *eq = s;
     38a:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     38e:	00002997          	auipc	s3,0x2
     392:	c7a98993          	addi	s3,s3,-902 # 2008 <whitespace>
     396:	0124fc63          	bgeu	s1,s2,3ae <gettoken+0xa0>
     39a:	0004c583          	lbu	a1,0(s1)
     39e:	854e                	mv	a0,s3
     3a0:	69a000ef          	jal	ra,a3a <strchr>
     3a4:	c509                	beqz	a0,3ae <gettoken+0xa0>
    s++;
     3a6:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     3a8:	fe9919e3          	bne	s2,s1,39a <gettoken+0x8c>
    s++;
     3ac:	84ca                	mv	s1,s2
  *ps = s;
     3ae:	009a3023          	sd	s1,0(s4)
  return ret;
}
     3b2:	8556                	mv	a0,s5
     3b4:	70e2                	ld	ra,56(sp)
     3b6:	7442                	ld	s0,48(sp)
     3b8:	74a2                	ld	s1,40(sp)
     3ba:	7902                	ld	s2,32(sp)
     3bc:	69e2                	ld	s3,24(sp)
     3be:	6a42                	ld	s4,16(sp)
     3c0:	6aa2                	ld	s5,8(sp)
     3c2:	6b02                	ld	s6,0(sp)
     3c4:	6121                	addi	sp,sp,64
     3c6:	8082                	ret
  switch(*s){
     3c8:	03e00713          	li	a4,62
     3cc:	02e79163          	bne	a5,a4,3ee <gettoken+0xe0>
    s++;
     3d0:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     3d4:	0014c703          	lbu	a4,1(s1)
     3d8:	03e00793          	li	a5,62
      s++;
     3dc:	0489                	addi	s1,s1,2
      ret = '+';
     3de:	02b00a93          	li	s5,43
    if(*s == '>'){
     3e2:	faf702e3          	beq	a4,a5,386 <gettoken+0x78>
    s++;
     3e6:	84b6                	mv	s1,a3
  ret = *s;
     3e8:	03e00a93          	li	s5,62
     3ec:	bf69                	j	386 <gettoken+0x78>
  switch(*s){
     3ee:	07c00713          	li	a4,124
     3f2:	f8e789e3          	beq	a5,a4,384 <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     3f6:	00002997          	auipc	s3,0x2
     3fa:	c1298993          	addi	s3,s3,-1006 # 2008 <whitespace>
     3fe:	00002a97          	auipc	s5,0x2
     402:	c02a8a93          	addi	s5,s5,-1022 # 2000 <symbols>
     406:	0324f263          	bgeu	s1,s2,42a <gettoken+0x11c>
     40a:	0004c583          	lbu	a1,0(s1)
     40e:	854e                	mv	a0,s3
     410:	62a000ef          	jal	ra,a3a <strchr>
     414:	e11d                	bnez	a0,43a <gettoken+0x12c>
     416:	0004c583          	lbu	a1,0(s1)
     41a:	8556                	mv	a0,s5
     41c:	61e000ef          	jal	ra,a3a <strchr>
     420:	e911                	bnez	a0,434 <gettoken+0x126>
      s++;
     422:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     424:	fe9913e3          	bne	s2,s1,40a <gettoken+0xfc>
      s++;
     428:	84ca                	mv	s1,s2
  if(eq)
     42a:	06100a93          	li	s5,97
     42e:	f40b1ee3          	bnez	s6,38a <gettoken+0x7c>
     432:	bfb5                	j	3ae <gettoken+0xa0>
    ret = 'a';
     434:	06100a93          	li	s5,97
     438:	b7b9                	j	386 <gettoken+0x78>
     43a:	06100a93          	li	s5,97
     43e:	b7a1                	j	386 <gettoken+0x78>

0000000000000440 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     440:	7139                	addi	sp,sp,-64
     442:	fc06                	sd	ra,56(sp)
     444:	f822                	sd	s0,48(sp)
     446:	f426                	sd	s1,40(sp)
     448:	f04a                	sd	s2,32(sp)
     44a:	ec4e                	sd	s3,24(sp)
     44c:	e852                	sd	s4,16(sp)
     44e:	e456                	sd	s5,8(sp)
     450:	0080                	addi	s0,sp,64
     452:	8a2a                	mv	s4,a0
     454:	892e                	mv	s2,a1
     456:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     458:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     45a:	00002997          	auipc	s3,0x2
     45e:	bae98993          	addi	s3,s3,-1106 # 2008 <whitespace>
     462:	00b4fc63          	bgeu	s1,a1,47a <peek+0x3a>
     466:	0004c583          	lbu	a1,0(s1)
     46a:	854e                	mv	a0,s3
     46c:	5ce000ef          	jal	ra,a3a <strchr>
     470:	c509                	beqz	a0,47a <peek+0x3a>
    s++;
     472:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     474:	fe9919e3          	bne	s2,s1,466 <peek+0x26>
    s++;
     478:	84ca                	mv	s1,s2
  *ps = s;
     47a:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     47e:	0004c583          	lbu	a1,0(s1)
     482:	4501                	li	a0,0
     484:	e991                	bnez	a1,498 <peek+0x58>
}
     486:	70e2                	ld	ra,56(sp)
     488:	7442                	ld	s0,48(sp)
     48a:	74a2                	ld	s1,40(sp)
     48c:	7902                	ld	s2,32(sp)
     48e:	69e2                	ld	s3,24(sp)
     490:	6a42                	ld	s4,16(sp)
     492:	6aa2                	ld	s5,8(sp)
     494:	6121                	addi	sp,sp,64
     496:	8082                	ret
  return *s && strchr(toks, *s);
     498:	8556                	mv	a0,s5
     49a:	5a0000ef          	jal	ra,a3a <strchr>
     49e:	00a03533          	snez	a0,a0
     4a2:	b7d5                	j	486 <peek+0x46>

00000000000004a4 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     4a4:	7159                	addi	sp,sp,-112
     4a6:	f486                	sd	ra,104(sp)
     4a8:	f0a2                	sd	s0,96(sp)
     4aa:	eca6                	sd	s1,88(sp)
     4ac:	e8ca                	sd	s2,80(sp)
     4ae:	e4ce                	sd	s3,72(sp)
     4b0:	e0d2                	sd	s4,64(sp)
     4b2:	fc56                	sd	s5,56(sp)
     4b4:	f85a                	sd	s6,48(sp)
     4b6:	f45e                	sd	s7,40(sp)
     4b8:	f062                	sd	s8,32(sp)
     4ba:	ec66                	sd	s9,24(sp)
     4bc:	1880                	addi	s0,sp,112
     4be:	8a2a                	mv	s4,a0
     4c0:	89ae                	mv	s3,a1
     4c2:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     4c4:	00001b97          	auipc	s7,0x1
     4c8:	d94b8b93          	addi	s7,s7,-620 # 1258 <malloc+0x14e>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     4cc:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     4d0:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     4d4:	a00d                	j	4f6 <parseredirs+0x52>
      panic("missing file for redirection");
     4d6:	00001517          	auipc	a0,0x1
     4da:	d6250513          	addi	a0,a0,-670 # 1238 <malloc+0x12e>
     4de:	b6dff0ef          	jal	ra,4a <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     4e2:	4701                	li	a4,0
     4e4:	4681                	li	a3,0
     4e6:	f9043603          	ld	a2,-112(s0)
     4ea:	f9843583          	ld	a1,-104(s0)
     4ee:	8552                	mv	a0,s4
     4f0:	d0fff0ef          	jal	ra,1fe <redircmd>
     4f4:	8a2a                	mv	s4,a0
    switch(tok){
     4f6:	03e00b13          	li	s6,62
     4fa:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     4fe:	865e                	mv	a2,s7
     500:	85ca                	mv	a1,s2
     502:	854e                	mv	a0,s3
     504:	f3dff0ef          	jal	ra,440 <peek>
     508:	c125                	beqz	a0,568 <parseredirs+0xc4>
    tok = gettoken(ps, es, 0, 0);
     50a:	4681                	li	a3,0
     50c:	4601                	li	a2,0
     50e:	85ca                	mv	a1,s2
     510:	854e                	mv	a0,s3
     512:	dfdff0ef          	jal	ra,30e <gettoken>
     516:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     518:	f9040693          	addi	a3,s0,-112
     51c:	f9840613          	addi	a2,s0,-104
     520:	85ca                	mv	a1,s2
     522:	854e                	mv	a0,s3
     524:	debff0ef          	jal	ra,30e <gettoken>
     528:	fb8517e3          	bne	a0,s8,4d6 <parseredirs+0x32>
    switch(tok){
     52c:	fb948be3          	beq	s1,s9,4e2 <parseredirs+0x3e>
     530:	03648063          	beq	s1,s6,550 <parseredirs+0xac>
     534:	fd5495e3          	bne	s1,s5,4fe <parseredirs+0x5a>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     538:	4705                	li	a4,1
     53a:	20100693          	li	a3,513
     53e:	f9043603          	ld	a2,-112(s0)
     542:	f9843583          	ld	a1,-104(s0)
     546:	8552                	mv	a0,s4
     548:	cb7ff0ef          	jal	ra,1fe <redircmd>
     54c:	8a2a                	mv	s4,a0
      break;
     54e:	b765                	j	4f6 <parseredirs+0x52>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     550:	4705                	li	a4,1
     552:	60100693          	li	a3,1537
     556:	f9043603          	ld	a2,-112(s0)
     55a:	f9843583          	ld	a1,-104(s0)
     55e:	8552                	mv	a0,s4
     560:	c9fff0ef          	jal	ra,1fe <redircmd>
     564:	8a2a                	mv	s4,a0
      break;
     566:	bf41                	j	4f6 <parseredirs+0x52>
    }
  }
  return cmd;
}
     568:	8552                	mv	a0,s4
     56a:	70a6                	ld	ra,104(sp)
     56c:	7406                	ld	s0,96(sp)
     56e:	64e6                	ld	s1,88(sp)
     570:	6946                	ld	s2,80(sp)
     572:	69a6                	ld	s3,72(sp)
     574:	6a06                	ld	s4,64(sp)
     576:	7ae2                	ld	s5,56(sp)
     578:	7b42                	ld	s6,48(sp)
     57a:	7ba2                	ld	s7,40(sp)
     57c:	7c02                	ld	s8,32(sp)
     57e:	6ce2                	ld	s9,24(sp)
     580:	6165                	addi	sp,sp,112
     582:	8082                	ret

0000000000000584 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     584:	7159                	addi	sp,sp,-112
     586:	f486                	sd	ra,104(sp)
     588:	f0a2                	sd	s0,96(sp)
     58a:	eca6                	sd	s1,88(sp)
     58c:	e8ca                	sd	s2,80(sp)
     58e:	e4ce                	sd	s3,72(sp)
     590:	e0d2                	sd	s4,64(sp)
     592:	fc56                	sd	s5,56(sp)
     594:	f85a                	sd	s6,48(sp)
     596:	f45e                	sd	s7,40(sp)
     598:	f062                	sd	s8,32(sp)
     59a:	ec66                	sd	s9,24(sp)
     59c:	1880                	addi	s0,sp,112
     59e:	8a2a                	mv	s4,a0
     5a0:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     5a2:	00001617          	auipc	a2,0x1
     5a6:	cbe60613          	addi	a2,a2,-834 # 1260 <malloc+0x156>
     5aa:	e97ff0ef          	jal	ra,440 <peek>
     5ae:	e505                	bnez	a0,5d6 <parseexec+0x52>
     5b0:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     5b2:	c1fff0ef          	jal	ra,1d0 <execcmd>
     5b6:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     5b8:	8656                	mv	a2,s5
     5ba:	85d2                	mv	a1,s4
     5bc:	ee9ff0ef          	jal	ra,4a4 <parseredirs>
     5c0:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     5c2:	008c0913          	addi	s2,s8,8
     5c6:	00001b17          	auipc	s6,0x1
     5ca:	cbab0b13          	addi	s6,s6,-838 # 1280 <malloc+0x176>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     5ce:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     5d2:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     5d4:	a081                	j	614 <parseexec+0x90>
    return parseblock(ps, es);
     5d6:	85d6                	mv	a1,s5
     5d8:	8552                	mv	a0,s4
     5da:	170000ef          	jal	ra,74a <parseblock>
     5de:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     5e0:	8526                	mv	a0,s1
     5e2:	70a6                	ld	ra,104(sp)
     5e4:	7406                	ld	s0,96(sp)
     5e6:	64e6                	ld	s1,88(sp)
     5e8:	6946                	ld	s2,80(sp)
     5ea:	69a6                	ld	s3,72(sp)
     5ec:	6a06                	ld	s4,64(sp)
     5ee:	7ae2                	ld	s5,56(sp)
     5f0:	7b42                	ld	s6,48(sp)
     5f2:	7ba2                	ld	s7,40(sp)
     5f4:	7c02                	ld	s8,32(sp)
     5f6:	6ce2                	ld	s9,24(sp)
     5f8:	6165                	addi	sp,sp,112
     5fa:	8082                	ret
      panic("syntax");
     5fc:	00001517          	auipc	a0,0x1
     600:	c6c50513          	addi	a0,a0,-916 # 1268 <malloc+0x15e>
     604:	a47ff0ef          	jal	ra,4a <panic>
    ret = parseredirs(ret, ps, es);
     608:	8656                	mv	a2,s5
     60a:	85d2                	mv	a1,s4
     60c:	8526                	mv	a0,s1
     60e:	e97ff0ef          	jal	ra,4a4 <parseredirs>
     612:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     614:	865a                	mv	a2,s6
     616:	85d6                	mv	a1,s5
     618:	8552                	mv	a0,s4
     61a:	e27ff0ef          	jal	ra,440 <peek>
     61e:	ed15                	bnez	a0,65a <parseexec+0xd6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     620:	f9040693          	addi	a3,s0,-112
     624:	f9840613          	addi	a2,s0,-104
     628:	85d6                	mv	a1,s5
     62a:	8552                	mv	a0,s4
     62c:	ce3ff0ef          	jal	ra,30e <gettoken>
     630:	c50d                	beqz	a0,65a <parseexec+0xd6>
    if(tok != 'a')
     632:	fd9515e3          	bne	a0,s9,5fc <parseexec+0x78>
    cmd->argv[argc] = q;
     636:	f9843783          	ld	a5,-104(s0)
     63a:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     63e:	f9043783          	ld	a5,-112(s0)
     642:	04f93823          	sd	a5,80(s2)
    argc++;
     646:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     648:	0921                	addi	s2,s2,8
     64a:	fb799fe3          	bne	s3,s7,608 <parseexec+0x84>
      panic("too many args");
     64e:	00001517          	auipc	a0,0x1
     652:	c2250513          	addi	a0,a0,-990 # 1270 <malloc+0x166>
     656:	9f5ff0ef          	jal	ra,4a <panic>
  cmd->argv[argc] = 0;
     65a:	098e                	slli	s3,s3,0x3
     65c:	9c4e                	add	s8,s8,s3
     65e:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     662:	040c3c23          	sd	zero,88(s8)
  return ret;
     666:	bfad                	j	5e0 <parseexec+0x5c>

0000000000000668 <parsepipe>:
{
     668:	7179                	addi	sp,sp,-48
     66a:	f406                	sd	ra,40(sp)
     66c:	f022                	sd	s0,32(sp)
     66e:	ec26                	sd	s1,24(sp)
     670:	e84a                	sd	s2,16(sp)
     672:	e44e                	sd	s3,8(sp)
     674:	1800                	addi	s0,sp,48
     676:	892a                	mv	s2,a0
     678:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     67a:	f0bff0ef          	jal	ra,584 <parseexec>
     67e:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     680:	00001617          	auipc	a2,0x1
     684:	c0860613          	addi	a2,a2,-1016 # 1288 <malloc+0x17e>
     688:	85ce                	mv	a1,s3
     68a:	854a                	mv	a0,s2
     68c:	db5ff0ef          	jal	ra,440 <peek>
     690:	e909                	bnez	a0,6a2 <parsepipe+0x3a>
}
     692:	8526                	mv	a0,s1
     694:	70a2                	ld	ra,40(sp)
     696:	7402                	ld	s0,32(sp)
     698:	64e2                	ld	s1,24(sp)
     69a:	6942                	ld	s2,16(sp)
     69c:	69a2                	ld	s3,8(sp)
     69e:	6145                	addi	sp,sp,48
     6a0:	8082                	ret
    gettoken(ps, es, 0, 0);
     6a2:	4681                	li	a3,0
     6a4:	4601                	li	a2,0
     6a6:	85ce                	mv	a1,s3
     6a8:	854a                	mv	a0,s2
     6aa:	c65ff0ef          	jal	ra,30e <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     6ae:	85ce                	mv	a1,s3
     6b0:	854a                	mv	a0,s2
     6b2:	fb7ff0ef          	jal	ra,668 <parsepipe>
     6b6:	85aa                	mv	a1,a0
     6b8:	8526                	mv	a0,s1
     6ba:	ba5ff0ef          	jal	ra,25e <pipecmd>
     6be:	84aa                	mv	s1,a0
  return cmd;
     6c0:	bfc9                	j	692 <parsepipe+0x2a>

00000000000006c2 <parseline>:
{
     6c2:	7179                	addi	sp,sp,-48
     6c4:	f406                	sd	ra,40(sp)
     6c6:	f022                	sd	s0,32(sp)
     6c8:	ec26                	sd	s1,24(sp)
     6ca:	e84a                	sd	s2,16(sp)
     6cc:	e44e                	sd	s3,8(sp)
     6ce:	e052                	sd	s4,0(sp)
     6d0:	1800                	addi	s0,sp,48
     6d2:	892a                	mv	s2,a0
     6d4:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     6d6:	f93ff0ef          	jal	ra,668 <parsepipe>
     6da:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     6dc:	00001a17          	auipc	s4,0x1
     6e0:	bb4a0a13          	addi	s4,s4,-1100 # 1290 <malloc+0x186>
     6e4:	a819                	j	6fa <parseline+0x38>
    gettoken(ps, es, 0, 0);
     6e6:	4681                	li	a3,0
     6e8:	4601                	li	a2,0
     6ea:	85ce                	mv	a1,s3
     6ec:	854a                	mv	a0,s2
     6ee:	c21ff0ef          	jal	ra,30e <gettoken>
    cmd = backcmd(cmd);
     6f2:	8526                	mv	a0,s1
     6f4:	be7ff0ef          	jal	ra,2da <backcmd>
     6f8:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     6fa:	8652                	mv	a2,s4
     6fc:	85ce                	mv	a1,s3
     6fe:	854a                	mv	a0,s2
     700:	d41ff0ef          	jal	ra,440 <peek>
     704:	f16d                	bnez	a0,6e6 <parseline+0x24>
  if(peek(ps, es, ";")){
     706:	00001617          	auipc	a2,0x1
     70a:	b9260613          	addi	a2,a2,-1134 # 1298 <malloc+0x18e>
     70e:	85ce                	mv	a1,s3
     710:	854a                	mv	a0,s2
     712:	d2fff0ef          	jal	ra,440 <peek>
     716:	e911                	bnez	a0,72a <parseline+0x68>
}
     718:	8526                	mv	a0,s1
     71a:	70a2                	ld	ra,40(sp)
     71c:	7402                	ld	s0,32(sp)
     71e:	64e2                	ld	s1,24(sp)
     720:	6942                	ld	s2,16(sp)
     722:	69a2                	ld	s3,8(sp)
     724:	6a02                	ld	s4,0(sp)
     726:	6145                	addi	sp,sp,48
     728:	8082                	ret
    gettoken(ps, es, 0, 0);
     72a:	4681                	li	a3,0
     72c:	4601                	li	a2,0
     72e:	85ce                	mv	a1,s3
     730:	854a                	mv	a0,s2
     732:	bddff0ef          	jal	ra,30e <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     736:	85ce                	mv	a1,s3
     738:	854a                	mv	a0,s2
     73a:	f89ff0ef          	jal	ra,6c2 <parseline>
     73e:	85aa                	mv	a1,a0
     740:	8526                	mv	a0,s1
     742:	b5bff0ef          	jal	ra,29c <listcmd>
     746:	84aa                	mv	s1,a0
  return cmd;
     748:	bfc1                	j	718 <parseline+0x56>

000000000000074a <parseblock>:
{
     74a:	7179                	addi	sp,sp,-48
     74c:	f406                	sd	ra,40(sp)
     74e:	f022                	sd	s0,32(sp)
     750:	ec26                	sd	s1,24(sp)
     752:	e84a                	sd	s2,16(sp)
     754:	e44e                	sd	s3,8(sp)
     756:	1800                	addi	s0,sp,48
     758:	84aa                	mv	s1,a0
     75a:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     75c:	00001617          	auipc	a2,0x1
     760:	b0460613          	addi	a2,a2,-1276 # 1260 <malloc+0x156>
     764:	cddff0ef          	jal	ra,440 <peek>
     768:	c539                	beqz	a0,7b6 <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     76a:	4681                	li	a3,0
     76c:	4601                	li	a2,0
     76e:	85ca                	mv	a1,s2
     770:	8526                	mv	a0,s1
     772:	b9dff0ef          	jal	ra,30e <gettoken>
  cmd = parseline(ps, es);
     776:	85ca                	mv	a1,s2
     778:	8526                	mv	a0,s1
     77a:	f49ff0ef          	jal	ra,6c2 <parseline>
     77e:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     780:	00001617          	auipc	a2,0x1
     784:	b3060613          	addi	a2,a2,-1232 # 12b0 <malloc+0x1a6>
     788:	85ca                	mv	a1,s2
     78a:	8526                	mv	a0,s1
     78c:	cb5ff0ef          	jal	ra,440 <peek>
     790:	c90d                	beqz	a0,7c2 <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     792:	4681                	li	a3,0
     794:	4601                	li	a2,0
     796:	85ca                	mv	a1,s2
     798:	8526                	mv	a0,s1
     79a:	b75ff0ef          	jal	ra,30e <gettoken>
  cmd = parseredirs(cmd, ps, es);
     79e:	864a                	mv	a2,s2
     7a0:	85a6                	mv	a1,s1
     7a2:	854e                	mv	a0,s3
     7a4:	d01ff0ef          	jal	ra,4a4 <parseredirs>
}
     7a8:	70a2                	ld	ra,40(sp)
     7aa:	7402                	ld	s0,32(sp)
     7ac:	64e2                	ld	s1,24(sp)
     7ae:	6942                	ld	s2,16(sp)
     7b0:	69a2                	ld	s3,8(sp)
     7b2:	6145                	addi	sp,sp,48
     7b4:	8082                	ret
    panic("parseblock");
     7b6:	00001517          	auipc	a0,0x1
     7ba:	aea50513          	addi	a0,a0,-1302 # 12a0 <malloc+0x196>
     7be:	88dff0ef          	jal	ra,4a <panic>
    panic("syntax - missing )");
     7c2:	00001517          	auipc	a0,0x1
     7c6:	af650513          	addi	a0,a0,-1290 # 12b8 <malloc+0x1ae>
     7ca:	881ff0ef          	jal	ra,4a <panic>

00000000000007ce <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     7ce:	1101                	addi	sp,sp,-32
     7d0:	ec06                	sd	ra,24(sp)
     7d2:	e822                	sd	s0,16(sp)
     7d4:	e426                	sd	s1,8(sp)
     7d6:	1000                	addi	s0,sp,32
     7d8:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     7da:	c131                	beqz	a0,81e <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     7dc:	4118                	lw	a4,0(a0)
     7de:	4795                	li	a5,5
     7e0:	02e7ef63          	bltu	a5,a4,81e <nulterminate+0x50>
     7e4:	00056783          	lwu	a5,0(a0)
     7e8:	078a                	slli	a5,a5,0x2
     7ea:	00001717          	auipc	a4,0x1
     7ee:	b2e70713          	addi	a4,a4,-1234 # 1318 <malloc+0x20e>
     7f2:	97ba                	add	a5,a5,a4
     7f4:	439c                	lw	a5,0(a5)
     7f6:	97ba                	add	a5,a5,a4
     7f8:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     7fa:	651c                	ld	a5,8(a0)
     7fc:	c38d                	beqz	a5,81e <nulterminate+0x50>
     7fe:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     802:	67b8                	ld	a4,72(a5)
     804:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     808:	07a1                	addi	a5,a5,8
     80a:	ff87b703          	ld	a4,-8(a5)
     80e:	fb75                	bnez	a4,802 <nulterminate+0x34>
     810:	a039                	j	81e <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     812:	6508                	ld	a0,8(a0)
     814:	fbbff0ef          	jal	ra,7ce <nulterminate>
    *rcmd->efile = 0;
     818:	6c9c                	ld	a5,24(s1)
     81a:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     81e:	8526                	mv	a0,s1
     820:	60e2                	ld	ra,24(sp)
     822:	6442                	ld	s0,16(sp)
     824:	64a2                	ld	s1,8(sp)
     826:	6105                	addi	sp,sp,32
     828:	8082                	ret
    nulterminate(pcmd->left);
     82a:	6508                	ld	a0,8(a0)
     82c:	fa3ff0ef          	jal	ra,7ce <nulterminate>
    nulterminate(pcmd->right);
     830:	6888                	ld	a0,16(s1)
     832:	f9dff0ef          	jal	ra,7ce <nulterminate>
    break;
     836:	b7e5                	j	81e <nulterminate+0x50>
    nulterminate(lcmd->left);
     838:	6508                	ld	a0,8(a0)
     83a:	f95ff0ef          	jal	ra,7ce <nulterminate>
    nulterminate(lcmd->right);
     83e:	6888                	ld	a0,16(s1)
     840:	f8fff0ef          	jal	ra,7ce <nulterminate>
    break;
     844:	bfe9                	j	81e <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     846:	6508                	ld	a0,8(a0)
     848:	f87ff0ef          	jal	ra,7ce <nulterminate>
    break;
     84c:	bfc9                	j	81e <nulterminate+0x50>

000000000000084e <parsecmd>:
{
     84e:	7179                	addi	sp,sp,-48
     850:	f406                	sd	ra,40(sp)
     852:	f022                	sd	s0,32(sp)
     854:	ec26                	sd	s1,24(sp)
     856:	e84a                	sd	s2,16(sp)
     858:	1800                	addi	s0,sp,48
     85a:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     85e:	84aa                	mv	s1,a0
     860:	18e000ef          	jal	ra,9ee <strlen>
     864:	1502                	slli	a0,a0,0x20
     866:	9101                	srli	a0,a0,0x20
     868:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     86a:	85a6                	mv	a1,s1
     86c:	fd840513          	addi	a0,s0,-40
     870:	e53ff0ef          	jal	ra,6c2 <parseline>
     874:	892a                	mv	s2,a0
  peek(&s, es, "");
     876:	00001617          	auipc	a2,0x1
     87a:	a5a60613          	addi	a2,a2,-1446 # 12d0 <malloc+0x1c6>
     87e:	85a6                	mv	a1,s1
     880:	fd840513          	addi	a0,s0,-40
     884:	bbdff0ef          	jal	ra,440 <peek>
  if(s != es){
     888:	fd843603          	ld	a2,-40(s0)
     88c:	00961c63          	bne	a2,s1,8a4 <parsecmd+0x56>
  nulterminate(cmd);
     890:	854a                	mv	a0,s2
     892:	f3dff0ef          	jal	ra,7ce <nulterminate>
}
     896:	854a                	mv	a0,s2
     898:	70a2                	ld	ra,40(sp)
     89a:	7402                	ld	s0,32(sp)
     89c:	64e2                	ld	s1,24(sp)
     89e:	6942                	ld	s2,16(sp)
     8a0:	6145                	addi	sp,sp,48
     8a2:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     8a4:	00001597          	auipc	a1,0x1
     8a8:	a3458593          	addi	a1,a1,-1484 # 12d8 <malloc+0x1ce>
     8ac:	4509                	li	a0,2
     8ae:	77e000ef          	jal	ra,102c <fprintf>
    panic("syntax");
     8b2:	00001517          	auipc	a0,0x1
     8b6:	9b650513          	addi	a0,a0,-1610 # 1268 <malloc+0x15e>
     8ba:	f90ff0ef          	jal	ra,4a <panic>

00000000000008be <main>:
{
     8be:	7139                	addi	sp,sp,-64
     8c0:	fc06                	sd	ra,56(sp)
     8c2:	f822                	sd	s0,48(sp)
     8c4:	f426                	sd	s1,40(sp)
     8c6:	f04a                	sd	s2,32(sp)
     8c8:	ec4e                	sd	s3,24(sp)
     8ca:	e852                	sd	s4,16(sp)
     8cc:	e456                	sd	s5,8(sp)
     8ce:	e05a                	sd	s6,0(sp)
     8d0:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     8d2:	00001497          	auipc	s1,0x1
     8d6:	a1648493          	addi	s1,s1,-1514 # 12e8 <malloc+0x1de>
     8da:	4589                	li	a1,2
     8dc:	8526                	mv	a0,s1
     8de:	38c000ef          	jal	ra,c6a <open>
     8e2:	00054763          	bltz	a0,8f0 <main+0x32>
    if(fd >= 3){
     8e6:	4789                	li	a5,2
     8e8:	fea7d9e3          	bge	a5,a0,8da <main+0x1c>
      close(fd);
     8ec:	366000ef          	jal	ra,c52 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     8f0:	00001a17          	auipc	s4,0x1
     8f4:	730a0a13          	addi	s4,s4,1840 # 2020 <buf.0>
    while (*cmd == ' ' || *cmd == '\t')
     8f8:	02000913          	li	s2,32
     8fc:	49a5                	li	s3,9
    if (*cmd == '\n') // is a blank command
     8fe:	4aa9                	li	s5,10
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     900:	06300b13          	li	s6,99
     904:	a805                	j	934 <main+0x76>
      cmd++;
     906:	0485                	addi	s1,s1,1
    while (*cmd == ' ' || *cmd == '\t')
     908:	0004c783          	lbu	a5,0(s1)
     90c:	ff278de3          	beq	a5,s2,906 <main+0x48>
     910:	ff378be3          	beq	a5,s3,906 <main+0x48>
    if (*cmd == '\n') // is a blank command
     914:	03578063          	beq	a5,s5,934 <main+0x76>
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     918:	01679863          	bne	a5,s6,928 <main+0x6a>
     91c:	0014c703          	lbu	a4,1(s1)
     920:	06400793          	li	a5,100
     924:	02f70463          	beq	a4,a5,94c <main+0x8e>
      if(fork1() == 0)
     928:	f40ff0ef          	jal	ra,68 <fork1>
     92c:	cd29                	beqz	a0,986 <main+0xc8>
      wait(0);
     92e:	4501                	li	a0,0
     930:	302000ef          	jal	ra,c32 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     934:	06400593          	li	a1,100
     938:	8552                	mv	a0,s4
     93a:	ec6ff0ef          	jal	ra,0 <getcmd>
     93e:	04054963          	bltz	a0,990 <main+0xd2>
    char *cmd = buf;
     942:	00001497          	auipc	s1,0x1
     946:	6de48493          	addi	s1,s1,1758 # 2020 <buf.0>
     94a:	bf7d                	j	908 <main+0x4a>
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     94c:	0024c783          	lbu	a5,2(s1)
     950:	fd279ce3          	bne	a5,s2,928 <main+0x6a>
      cmd[strlen(cmd)-1] = 0;  // chop \n
     954:	8526                	mv	a0,s1
     956:	098000ef          	jal	ra,9ee <strlen>
     95a:	fff5079b          	addiw	a5,a0,-1
     95e:	1782                	slli	a5,a5,0x20
     960:	9381                	srli	a5,a5,0x20
     962:	97a6                	add	a5,a5,s1
     964:	00078023          	sb	zero,0(a5)
      if(chdir(cmd+3) < 0)
     968:	048d                	addi	s1,s1,3
     96a:	8526                	mv	a0,s1
     96c:	32e000ef          	jal	ra,c9a <chdir>
     970:	fc0552e3          	bgez	a0,934 <main+0x76>
        fprintf(2, "cannot cd %s\n", cmd+3);
     974:	8626                	mv	a2,s1
     976:	00001597          	auipc	a1,0x1
     97a:	97a58593          	addi	a1,a1,-1670 # 12f0 <malloc+0x1e6>
     97e:	4509                	li	a0,2
     980:	6ac000ef          	jal	ra,102c <fprintf>
     984:	bf45                	j	934 <main+0x76>
        runcmd(parsecmd(cmd));
     986:	8526                	mv	a0,s1
     988:	ec7ff0ef          	jal	ra,84e <parsecmd>
     98c:	f02ff0ef          	jal	ra,8e <runcmd>
  exit(0);
     990:	4501                	li	a0,0
     992:	298000ef          	jal	ra,c2a <exit>

0000000000000996 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     996:	1141                	addi	sp,sp,-16
     998:	e406                	sd	ra,8(sp)
     99a:	e022                	sd	s0,0(sp)
     99c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     99e:	f21ff0ef          	jal	ra,8be <main>
  exit(r);
     9a2:	288000ef          	jal	ra,c2a <exit>

00000000000009a6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     9a6:	1141                	addi	sp,sp,-16
     9a8:	e422                	sd	s0,8(sp)
     9aa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     9ac:	87aa                	mv	a5,a0
     9ae:	0585                	addi	a1,a1,1
     9b0:	0785                	addi	a5,a5,1
     9b2:	fff5c703          	lbu	a4,-1(a1)
     9b6:	fee78fa3          	sb	a4,-1(a5)
     9ba:	fb75                	bnez	a4,9ae <strcpy+0x8>
    ;
  return os;
}
     9bc:	6422                	ld	s0,8(sp)
     9be:	0141                	addi	sp,sp,16
     9c0:	8082                	ret

00000000000009c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     9c2:	1141                	addi	sp,sp,-16
     9c4:	e422                	sd	s0,8(sp)
     9c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     9c8:	00054783          	lbu	a5,0(a0)
     9cc:	cb91                	beqz	a5,9e0 <strcmp+0x1e>
     9ce:	0005c703          	lbu	a4,0(a1)
     9d2:	00f71763          	bne	a4,a5,9e0 <strcmp+0x1e>
    p++, q++;
     9d6:	0505                	addi	a0,a0,1
     9d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     9da:	00054783          	lbu	a5,0(a0)
     9de:	fbe5                	bnez	a5,9ce <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     9e0:	0005c503          	lbu	a0,0(a1)
}
     9e4:	40a7853b          	subw	a0,a5,a0
     9e8:	6422                	ld	s0,8(sp)
     9ea:	0141                	addi	sp,sp,16
     9ec:	8082                	ret

00000000000009ee <strlen>:

uint
strlen(const char *s)
{
     9ee:	1141                	addi	sp,sp,-16
     9f0:	e422                	sd	s0,8(sp)
     9f2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     9f4:	00054783          	lbu	a5,0(a0)
     9f8:	cf91                	beqz	a5,a14 <strlen+0x26>
     9fa:	0505                	addi	a0,a0,1
     9fc:	87aa                	mv	a5,a0
     9fe:	4685                	li	a3,1
     a00:	9e89                	subw	a3,a3,a0
     a02:	00f6853b          	addw	a0,a3,a5
     a06:	0785                	addi	a5,a5,1
     a08:	fff7c703          	lbu	a4,-1(a5)
     a0c:	fb7d                	bnez	a4,a02 <strlen+0x14>
    ;
  return n;
}
     a0e:	6422                	ld	s0,8(sp)
     a10:	0141                	addi	sp,sp,16
     a12:	8082                	ret
  for(n = 0; s[n]; n++)
     a14:	4501                	li	a0,0
     a16:	bfe5                	j	a0e <strlen+0x20>

0000000000000a18 <memset>:

void*
memset(void *dst, int c, uint n)
{
     a18:	1141                	addi	sp,sp,-16
     a1a:	e422                	sd	s0,8(sp)
     a1c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     a1e:	ca19                	beqz	a2,a34 <memset+0x1c>
     a20:	87aa                	mv	a5,a0
     a22:	1602                	slli	a2,a2,0x20
     a24:	9201                	srli	a2,a2,0x20
     a26:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     a2a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     a2e:	0785                	addi	a5,a5,1
     a30:	fee79de3          	bne	a5,a4,a2a <memset+0x12>
  }
  return dst;
}
     a34:	6422                	ld	s0,8(sp)
     a36:	0141                	addi	sp,sp,16
     a38:	8082                	ret

0000000000000a3a <strchr>:

char*
strchr(const char *s, char c)
{
     a3a:	1141                	addi	sp,sp,-16
     a3c:	e422                	sd	s0,8(sp)
     a3e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     a40:	00054783          	lbu	a5,0(a0)
     a44:	cb99                	beqz	a5,a5a <strchr+0x20>
    if(*s == c)
     a46:	00f58763          	beq	a1,a5,a54 <strchr+0x1a>
  for(; *s; s++)
     a4a:	0505                	addi	a0,a0,1
     a4c:	00054783          	lbu	a5,0(a0)
     a50:	fbfd                	bnez	a5,a46 <strchr+0xc>
      return (char*)s;
  return 0;
     a52:	4501                	li	a0,0
}
     a54:	6422                	ld	s0,8(sp)
     a56:	0141                	addi	sp,sp,16
     a58:	8082                	ret
  return 0;
     a5a:	4501                	li	a0,0
     a5c:	bfe5                	j	a54 <strchr+0x1a>

0000000000000a5e <gets>:

char*
gets(char *buf, int max)
{
     a5e:	711d                	addi	sp,sp,-96
     a60:	ec86                	sd	ra,88(sp)
     a62:	e8a2                	sd	s0,80(sp)
     a64:	e4a6                	sd	s1,72(sp)
     a66:	e0ca                	sd	s2,64(sp)
     a68:	fc4e                	sd	s3,56(sp)
     a6a:	f852                	sd	s4,48(sp)
     a6c:	f456                	sd	s5,40(sp)
     a6e:	f05a                	sd	s6,32(sp)
     a70:	ec5e                	sd	s7,24(sp)
     a72:	1080                	addi	s0,sp,96
     a74:	8baa                	mv	s7,a0
     a76:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a78:	892a                	mv	s2,a0
     a7a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a7c:	4aa9                	li	s5,10
     a7e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a80:	89a6                	mv	s3,s1
     a82:	2485                	addiw	s1,s1,1
     a84:	0344d663          	bge	s1,s4,ab0 <gets+0x52>
    cc = read(0, &c, 1);
     a88:	4605                	li	a2,1
     a8a:	faf40593          	addi	a1,s0,-81
     a8e:	4501                	li	a0,0
     a90:	1b2000ef          	jal	ra,c42 <read>
    if(cc < 1)
     a94:	00a05e63          	blez	a0,ab0 <gets+0x52>
    buf[i++] = c;
     a98:	faf44783          	lbu	a5,-81(s0)
     a9c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     aa0:	01578763          	beq	a5,s5,aae <gets+0x50>
     aa4:	0905                	addi	s2,s2,1
     aa6:	fd679de3          	bne	a5,s6,a80 <gets+0x22>
  for(i=0; i+1 < max; ){
     aaa:	89a6                	mv	s3,s1
     aac:	a011                	j	ab0 <gets+0x52>
     aae:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ab0:	99de                	add	s3,s3,s7
     ab2:	00098023          	sb	zero,0(s3)
  return buf;
}
     ab6:	855e                	mv	a0,s7
     ab8:	60e6                	ld	ra,88(sp)
     aba:	6446                	ld	s0,80(sp)
     abc:	64a6                	ld	s1,72(sp)
     abe:	6906                	ld	s2,64(sp)
     ac0:	79e2                	ld	s3,56(sp)
     ac2:	7a42                	ld	s4,48(sp)
     ac4:	7aa2                	ld	s5,40(sp)
     ac6:	7b02                	ld	s6,32(sp)
     ac8:	6be2                	ld	s7,24(sp)
     aca:	6125                	addi	sp,sp,96
     acc:	8082                	ret

0000000000000ace <stat>:

int
stat(const char *n, struct stat *st)
{
     ace:	1101                	addi	sp,sp,-32
     ad0:	ec06                	sd	ra,24(sp)
     ad2:	e822                	sd	s0,16(sp)
     ad4:	e426                	sd	s1,8(sp)
     ad6:	e04a                	sd	s2,0(sp)
     ad8:	1000                	addi	s0,sp,32
     ada:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     adc:	4581                	li	a1,0
     ade:	18c000ef          	jal	ra,c6a <open>
  if(fd < 0)
     ae2:	02054163          	bltz	a0,b04 <stat+0x36>
     ae6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     ae8:	85ca                	mv	a1,s2
     aea:	198000ef          	jal	ra,c82 <fstat>
     aee:	892a                	mv	s2,a0
  close(fd);
     af0:	8526                	mv	a0,s1
     af2:	160000ef          	jal	ra,c52 <close>
  return r;
}
     af6:	854a                	mv	a0,s2
     af8:	60e2                	ld	ra,24(sp)
     afa:	6442                	ld	s0,16(sp)
     afc:	64a2                	ld	s1,8(sp)
     afe:	6902                	ld	s2,0(sp)
     b00:	6105                	addi	sp,sp,32
     b02:	8082                	ret
    return -1;
     b04:	597d                	li	s2,-1
     b06:	bfc5                	j	af6 <stat+0x28>

0000000000000b08 <atoi>:

int
atoi(const char *s)
{
     b08:	1141                	addi	sp,sp,-16
     b0a:	e422                	sd	s0,8(sp)
     b0c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b0e:	00054683          	lbu	a3,0(a0)
     b12:	fd06879b          	addiw	a5,a3,-48
     b16:	0ff7f793          	zext.b	a5,a5
     b1a:	4625                	li	a2,9
     b1c:	02f66863          	bltu	a2,a5,b4c <atoi+0x44>
     b20:	872a                	mv	a4,a0
  n = 0;
     b22:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     b24:	0705                	addi	a4,a4,1
     b26:	0025179b          	slliw	a5,a0,0x2
     b2a:	9fa9                	addw	a5,a5,a0
     b2c:	0017979b          	slliw	a5,a5,0x1
     b30:	9fb5                	addw	a5,a5,a3
     b32:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     b36:	00074683          	lbu	a3,0(a4)
     b3a:	fd06879b          	addiw	a5,a3,-48
     b3e:	0ff7f793          	zext.b	a5,a5
     b42:	fef671e3          	bgeu	a2,a5,b24 <atoi+0x1c>
  return n;
}
     b46:	6422                	ld	s0,8(sp)
     b48:	0141                	addi	sp,sp,16
     b4a:	8082                	ret
  n = 0;
     b4c:	4501                	li	a0,0
     b4e:	bfe5                	j	b46 <atoi+0x3e>

0000000000000b50 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     b50:	1141                	addi	sp,sp,-16
     b52:	e422                	sd	s0,8(sp)
     b54:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     b56:	02b57463          	bgeu	a0,a1,b7e <memmove+0x2e>
    while(n-- > 0)
     b5a:	00c05f63          	blez	a2,b78 <memmove+0x28>
     b5e:	1602                	slli	a2,a2,0x20
     b60:	9201                	srli	a2,a2,0x20
     b62:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     b66:	872a                	mv	a4,a0
      *dst++ = *src++;
     b68:	0585                	addi	a1,a1,1
     b6a:	0705                	addi	a4,a4,1
     b6c:	fff5c683          	lbu	a3,-1(a1)
     b70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     b74:	fee79ae3          	bne	a5,a4,b68 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     b78:	6422                	ld	s0,8(sp)
     b7a:	0141                	addi	sp,sp,16
     b7c:	8082                	ret
    dst += n;
     b7e:	00c50733          	add	a4,a0,a2
    src += n;
     b82:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     b84:	fec05ae3          	blez	a2,b78 <memmove+0x28>
     b88:	fff6079b          	addiw	a5,a2,-1
     b8c:	1782                	slli	a5,a5,0x20
     b8e:	9381                	srli	a5,a5,0x20
     b90:	fff7c793          	not	a5,a5
     b94:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     b96:	15fd                	addi	a1,a1,-1
     b98:	177d                	addi	a4,a4,-1
     b9a:	0005c683          	lbu	a3,0(a1)
     b9e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     ba2:	fee79ae3          	bne	a5,a4,b96 <memmove+0x46>
     ba6:	bfc9                	j	b78 <memmove+0x28>

0000000000000ba8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     ba8:	1141                	addi	sp,sp,-16
     baa:	e422                	sd	s0,8(sp)
     bac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     bae:	ca05                	beqz	a2,bde <memcmp+0x36>
     bb0:	fff6069b          	addiw	a3,a2,-1
     bb4:	1682                	slli	a3,a3,0x20
     bb6:	9281                	srli	a3,a3,0x20
     bb8:	0685                	addi	a3,a3,1
     bba:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     bbc:	00054783          	lbu	a5,0(a0)
     bc0:	0005c703          	lbu	a4,0(a1)
     bc4:	00e79863          	bne	a5,a4,bd4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     bc8:	0505                	addi	a0,a0,1
    p2++;
     bca:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     bcc:	fed518e3          	bne	a0,a3,bbc <memcmp+0x14>
  }
  return 0;
     bd0:	4501                	li	a0,0
     bd2:	a019                	j	bd8 <memcmp+0x30>
      return *p1 - *p2;
     bd4:	40e7853b          	subw	a0,a5,a4
}
     bd8:	6422                	ld	s0,8(sp)
     bda:	0141                	addi	sp,sp,16
     bdc:	8082                	ret
  return 0;
     bde:	4501                	li	a0,0
     be0:	bfe5                	j	bd8 <memcmp+0x30>

0000000000000be2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     be2:	1141                	addi	sp,sp,-16
     be4:	e406                	sd	ra,8(sp)
     be6:	e022                	sd	s0,0(sp)
     be8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     bea:	f67ff0ef          	jal	ra,b50 <memmove>
}
     bee:	60a2                	ld	ra,8(sp)
     bf0:	6402                	ld	s0,0(sp)
     bf2:	0141                	addi	sp,sp,16
     bf4:	8082                	ret

0000000000000bf6 <sbrk>:

char *
sbrk(int n) {
     bf6:	1141                	addi	sp,sp,-16
     bf8:	e406                	sd	ra,8(sp)
     bfa:	e022                	sd	s0,0(sp)
     bfc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     bfe:	4585                	li	a1,1
     c00:	0b2000ef          	jal	ra,cb2 <sys_sbrk>
}
     c04:	60a2                	ld	ra,8(sp)
     c06:	6402                	ld	s0,0(sp)
     c08:	0141                	addi	sp,sp,16
     c0a:	8082                	ret

0000000000000c0c <sbrklazy>:

char *
sbrklazy(int n) {
     c0c:	1141                	addi	sp,sp,-16
     c0e:	e406                	sd	ra,8(sp)
     c10:	e022                	sd	s0,0(sp)
     c12:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     c14:	4589                	li	a1,2
     c16:	09c000ef          	jal	ra,cb2 <sys_sbrk>
}
     c1a:	60a2                	ld	ra,8(sp)
     c1c:	6402                	ld	s0,0(sp)
     c1e:	0141                	addi	sp,sp,16
     c20:	8082                	ret

0000000000000c22 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     c22:	4885                	li	a7,1
 ecall
     c24:	00000073          	ecall
 ret
     c28:	8082                	ret

0000000000000c2a <exit>:
.global exit
exit:
 li a7, SYS_exit
     c2a:	4889                	li	a7,2
 ecall
     c2c:	00000073          	ecall
 ret
     c30:	8082                	ret

0000000000000c32 <wait>:
.global wait
wait:
 li a7, SYS_wait
     c32:	488d                	li	a7,3
 ecall
     c34:	00000073          	ecall
 ret
     c38:	8082                	ret

0000000000000c3a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     c3a:	4891                	li	a7,4
 ecall
     c3c:	00000073          	ecall
 ret
     c40:	8082                	ret

0000000000000c42 <read>:
.global read
read:
 li a7, SYS_read
     c42:	4895                	li	a7,5
 ecall
     c44:	00000073          	ecall
 ret
     c48:	8082                	ret

0000000000000c4a <write>:
.global write
write:
 li a7, SYS_write
     c4a:	48c1                	li	a7,16
 ecall
     c4c:	00000073          	ecall
 ret
     c50:	8082                	ret

0000000000000c52 <close>:
.global close
close:
 li a7, SYS_close
     c52:	48d5                	li	a7,21
 ecall
     c54:	00000073          	ecall
 ret
     c58:	8082                	ret

0000000000000c5a <kill>:
.global kill
kill:
 li a7, SYS_kill
     c5a:	4899                	li	a7,6
 ecall
     c5c:	00000073          	ecall
 ret
     c60:	8082                	ret

0000000000000c62 <exec>:
.global exec
exec:
 li a7, SYS_exec
     c62:	489d                	li	a7,7
 ecall
     c64:	00000073          	ecall
 ret
     c68:	8082                	ret

0000000000000c6a <open>:
.global open
open:
 li a7, SYS_open
     c6a:	48bd                	li	a7,15
 ecall
     c6c:	00000073          	ecall
 ret
     c70:	8082                	ret

0000000000000c72 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c72:	48c5                	li	a7,17
 ecall
     c74:	00000073          	ecall
 ret
     c78:	8082                	ret

0000000000000c7a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c7a:	48c9                	li	a7,18
 ecall
     c7c:	00000073          	ecall
 ret
     c80:	8082                	ret

0000000000000c82 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c82:	48a1                	li	a7,8
 ecall
     c84:	00000073          	ecall
 ret
     c88:	8082                	ret

0000000000000c8a <link>:
.global link
link:
 li a7, SYS_link
     c8a:	48cd                	li	a7,19
 ecall
     c8c:	00000073          	ecall
 ret
     c90:	8082                	ret

0000000000000c92 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c92:	48d1                	li	a7,20
 ecall
     c94:	00000073          	ecall
 ret
     c98:	8082                	ret

0000000000000c9a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c9a:	48a5                	li	a7,9
 ecall
     c9c:	00000073          	ecall
 ret
     ca0:	8082                	ret

0000000000000ca2 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ca2:	48a9                	li	a7,10
 ecall
     ca4:	00000073          	ecall
 ret
     ca8:	8082                	ret

0000000000000caa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     caa:	48ad                	li	a7,11
 ecall
     cac:	00000073          	ecall
 ret
     cb0:	8082                	ret

0000000000000cb2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     cb2:	48b1                	li	a7,12
 ecall
     cb4:	00000073          	ecall
 ret
     cb8:	8082                	ret

0000000000000cba <pause>:
.global pause
pause:
 li a7, SYS_pause
     cba:	48b5                	li	a7,13
 ecall
     cbc:	00000073          	ecall
 ret
     cc0:	8082                	ret

0000000000000cc2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     cc2:	48b9                	li	a7,14
 ecall
     cc4:	00000073          	ecall
 ret
     cc8:	8082                	ret

0000000000000cca <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
     cca:	48d9                	li	a7,22
 ecall
     ccc:	00000073          	ecall
 ret
     cd0:	8082                	ret

0000000000000cd2 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
     cd2:	48dd                	li	a7,23
 ecall
     cd4:	00000073          	ecall
 ret
     cd8:	8082                	ret

0000000000000cda <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     cda:	1101                	addi	sp,sp,-32
     cdc:	ec06                	sd	ra,24(sp)
     cde:	e822                	sd	s0,16(sp)
     ce0:	1000                	addi	s0,sp,32
     ce2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     ce6:	4605                	li	a2,1
     ce8:	fef40593          	addi	a1,s0,-17
     cec:	f5fff0ef          	jal	ra,c4a <write>
}
     cf0:	60e2                	ld	ra,24(sp)
     cf2:	6442                	ld	s0,16(sp)
     cf4:	6105                	addi	sp,sp,32
     cf6:	8082                	ret

0000000000000cf8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     cf8:	715d                	addi	sp,sp,-80
     cfa:	e486                	sd	ra,72(sp)
     cfc:	e0a2                	sd	s0,64(sp)
     cfe:	fc26                	sd	s1,56(sp)
     d00:	f84a                	sd	s2,48(sp)
     d02:	f44e                	sd	s3,40(sp)
     d04:	0880                	addi	s0,sp,80
     d06:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     d08:	c299                	beqz	a3,d0e <printint+0x16>
     d0a:	0805c163          	bltz	a1,d8c <printint+0x94>
  neg = 0;
     d0e:	4881                	li	a7,0
     d10:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     d14:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     d16:	00000517          	auipc	a0,0x0
     d1a:	62250513          	addi	a0,a0,1570 # 1338 <digits>
     d1e:	883e                	mv	a6,a5
     d20:	2785                	addiw	a5,a5,1
     d22:	02c5f733          	remu	a4,a1,a2
     d26:	972a                	add	a4,a4,a0
     d28:	00074703          	lbu	a4,0(a4)
     d2c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     d30:	872e                	mv	a4,a1
     d32:	02c5d5b3          	divu	a1,a1,a2
     d36:	0685                	addi	a3,a3,1
     d38:	fec773e3          	bgeu	a4,a2,d1e <printint+0x26>
  if(neg)
     d3c:	00088b63          	beqz	a7,d52 <printint+0x5a>
    buf[i++] = '-';
     d40:	fd078793          	addi	a5,a5,-48
     d44:	97a2                	add	a5,a5,s0
     d46:	02d00713          	li	a4,45
     d4a:	fee78423          	sb	a4,-24(a5)
     d4e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     d52:	02f05663          	blez	a5,d7e <printint+0x86>
     d56:	fb840713          	addi	a4,s0,-72
     d5a:	00f704b3          	add	s1,a4,a5
     d5e:	fff70993          	addi	s3,a4,-1
     d62:	99be                	add	s3,s3,a5
     d64:	37fd                	addiw	a5,a5,-1
     d66:	1782                	slli	a5,a5,0x20
     d68:	9381                	srli	a5,a5,0x20
     d6a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     d6e:	fff4c583          	lbu	a1,-1(s1)
     d72:	854a                	mv	a0,s2
     d74:	f67ff0ef          	jal	ra,cda <putc>
  while(--i >= 0)
     d78:	14fd                	addi	s1,s1,-1
     d7a:	ff349ae3          	bne	s1,s3,d6e <printint+0x76>
}
     d7e:	60a6                	ld	ra,72(sp)
     d80:	6406                	ld	s0,64(sp)
     d82:	74e2                	ld	s1,56(sp)
     d84:	7942                	ld	s2,48(sp)
     d86:	79a2                	ld	s3,40(sp)
     d88:	6161                	addi	sp,sp,80
     d8a:	8082                	ret
    x = -xx;
     d8c:	40b005b3          	neg	a1,a1
    neg = 1;
     d90:	4885                	li	a7,1
    x = -xx;
     d92:	bfbd                	j	d10 <printint+0x18>

0000000000000d94 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d94:	7119                	addi	sp,sp,-128
     d96:	fc86                	sd	ra,120(sp)
     d98:	f8a2                	sd	s0,112(sp)
     d9a:	f4a6                	sd	s1,104(sp)
     d9c:	f0ca                	sd	s2,96(sp)
     d9e:	ecce                	sd	s3,88(sp)
     da0:	e8d2                	sd	s4,80(sp)
     da2:	e4d6                	sd	s5,72(sp)
     da4:	e0da                	sd	s6,64(sp)
     da6:	fc5e                	sd	s7,56(sp)
     da8:	f862                	sd	s8,48(sp)
     daa:	f466                	sd	s9,40(sp)
     dac:	f06a                	sd	s10,32(sp)
     dae:	ec6e                	sd	s11,24(sp)
     db0:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     db2:	0005c903          	lbu	s2,0(a1)
     db6:	24090c63          	beqz	s2,100e <vprintf+0x27a>
     dba:	8b2a                	mv	s6,a0
     dbc:	8a2e                	mv	s4,a1
     dbe:	8bb2                	mv	s7,a2
  state = 0;
     dc0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     dc2:	4481                	li	s1,0
     dc4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     dc6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     dca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     dce:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     dd2:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     dd6:	00000c97          	auipc	s9,0x0
     dda:	562c8c93          	addi	s9,s9,1378 # 1338 <digits>
     dde:	a005                	j	dfe <vprintf+0x6a>
        putc(fd, c0);
     de0:	85ca                	mv	a1,s2
     de2:	855a                	mv	a0,s6
     de4:	ef7ff0ef          	jal	ra,cda <putc>
     de8:	a019                	j	dee <vprintf+0x5a>
    } else if(state == '%'){
     dea:	03598263          	beq	s3,s5,e0e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     dee:	2485                	addiw	s1,s1,1
     df0:	8726                	mv	a4,s1
     df2:	009a07b3          	add	a5,s4,s1
     df6:	0007c903          	lbu	s2,0(a5)
     dfa:	20090a63          	beqz	s2,100e <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
     dfe:	0009079b          	sext.w	a5,s2
    if(state == 0){
     e02:	fe0994e3          	bnez	s3,dea <vprintf+0x56>
      if(c0 == '%'){
     e06:	fd579de3          	bne	a5,s5,de0 <vprintf+0x4c>
        state = '%';
     e0a:	89be                	mv	s3,a5
     e0c:	b7cd                	j	dee <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
     e0e:	c3c1                	beqz	a5,e8e <vprintf+0xfa>
     e10:	00ea06b3          	add	a3,s4,a4
     e14:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     e18:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     e1a:	c681                	beqz	a3,e22 <vprintf+0x8e>
     e1c:	9752                	add	a4,a4,s4
     e1e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     e22:	03878e63          	beq	a5,s8,e5e <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
     e26:	05a78863          	beq	a5,s10,e76 <vprintf+0xe2>
      } else if(c0 == 'u'){
     e2a:	0db78b63          	beq	a5,s11,f00 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     e2e:	07800713          	li	a4,120
     e32:	10e78d63          	beq	a5,a4,f4c <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     e36:	07000713          	li	a4,112
     e3a:	14e78263          	beq	a5,a4,f7e <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     e3e:	06300713          	li	a4,99
     e42:	16e78f63          	beq	a5,a4,fc0 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     e46:	07300713          	li	a4,115
     e4a:	18e78563          	beq	a5,a4,fd4 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     e4e:	05579063          	bne	a5,s5,e8e <vprintf+0xfa>
        putc(fd, '%');
     e52:	85d6                	mv	a1,s5
     e54:	855a                	mv	a0,s6
     e56:	e85ff0ef          	jal	ra,cda <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     e5a:	4981                	li	s3,0
     e5c:	bf49                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
     e5e:	008b8913          	addi	s2,s7,8
     e62:	4685                	li	a3,1
     e64:	4629                	li	a2,10
     e66:	000ba583          	lw	a1,0(s7)
     e6a:	855a                	mv	a0,s6
     e6c:	e8dff0ef          	jal	ra,cf8 <printint>
     e70:	8bca                	mv	s7,s2
      state = 0;
     e72:	4981                	li	s3,0
     e74:	bfad                	j	dee <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
     e76:	03868663          	beq	a3,s8,ea2 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e7a:	05a68163          	beq	a3,s10,ebc <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
     e7e:	09b68d63          	beq	a3,s11,f18 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e82:	03a68f63          	beq	a3,s10,ec0 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
     e86:	07800793          	li	a5,120
     e8a:	0cf68d63          	beq	a3,a5,f64 <vprintf+0x1d0>
        putc(fd, '%');
     e8e:	85d6                	mv	a1,s5
     e90:	855a                	mv	a0,s6
     e92:	e49ff0ef          	jal	ra,cda <putc>
        putc(fd, c0);
     e96:	85ca                	mv	a1,s2
     e98:	855a                	mv	a0,s6
     e9a:	e41ff0ef          	jal	ra,cda <putc>
      state = 0;
     e9e:	4981                	li	s3,0
     ea0:	b7b9                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ea2:	008b8913          	addi	s2,s7,8
     ea6:	4685                	li	a3,1
     ea8:	4629                	li	a2,10
     eaa:	000bb583          	ld	a1,0(s7)
     eae:	855a                	mv	a0,s6
     eb0:	e49ff0ef          	jal	ra,cf8 <printint>
        i += 1;
     eb4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     eb6:	8bca                	mv	s7,s2
      state = 0;
     eb8:	4981                	li	s3,0
        i += 1;
     eba:	bf15                	j	dee <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     ebc:	03860563          	beq	a2,s8,ee6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     ec0:	07b60963          	beq	a2,s11,f32 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     ec4:	07800793          	li	a5,120
     ec8:	fcf613e3          	bne	a2,a5,e8e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ecc:	008b8913          	addi	s2,s7,8
     ed0:	4681                	li	a3,0
     ed2:	4641                	li	a2,16
     ed4:	000bb583          	ld	a1,0(s7)
     ed8:	855a                	mv	a0,s6
     eda:	e1fff0ef          	jal	ra,cf8 <printint>
        i += 2;
     ede:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     ee0:	8bca                	mv	s7,s2
      state = 0;
     ee2:	4981                	li	s3,0
        i += 2;
     ee4:	b729                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ee6:	008b8913          	addi	s2,s7,8
     eea:	4685                	li	a3,1
     eec:	4629                	li	a2,10
     eee:	000bb583          	ld	a1,0(s7)
     ef2:	855a                	mv	a0,s6
     ef4:	e05ff0ef          	jal	ra,cf8 <printint>
        i += 2;
     ef8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     efa:	8bca                	mv	s7,s2
      state = 0;
     efc:	4981                	li	s3,0
        i += 2;
     efe:	bdc5                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     f00:	008b8913          	addi	s2,s7,8
     f04:	4681                	li	a3,0
     f06:	4629                	li	a2,10
     f08:	000be583          	lwu	a1,0(s7)
     f0c:	855a                	mv	a0,s6
     f0e:	debff0ef          	jal	ra,cf8 <printint>
     f12:	8bca                	mv	s7,s2
      state = 0;
     f14:	4981                	li	s3,0
     f16:	bde1                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f18:	008b8913          	addi	s2,s7,8
     f1c:	4681                	li	a3,0
     f1e:	4629                	li	a2,10
     f20:	000bb583          	ld	a1,0(s7)
     f24:	855a                	mv	a0,s6
     f26:	dd3ff0ef          	jal	ra,cf8 <printint>
        i += 1;
     f2a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     f2c:	8bca                	mv	s7,s2
      state = 0;
     f2e:	4981                	li	s3,0
        i += 1;
     f30:	bd7d                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f32:	008b8913          	addi	s2,s7,8
     f36:	4681                	li	a3,0
     f38:	4629                	li	a2,10
     f3a:	000bb583          	ld	a1,0(s7)
     f3e:	855a                	mv	a0,s6
     f40:	db9ff0ef          	jal	ra,cf8 <printint>
        i += 2;
     f44:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     f46:	8bca                	mv	s7,s2
      state = 0;
     f48:	4981                	li	s3,0
        i += 2;
     f4a:	b555                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     f4c:	008b8913          	addi	s2,s7,8
     f50:	4681                	li	a3,0
     f52:	4641                	li	a2,16
     f54:	000be583          	lwu	a1,0(s7)
     f58:	855a                	mv	a0,s6
     f5a:	d9fff0ef          	jal	ra,cf8 <printint>
     f5e:	8bca                	mv	s7,s2
      state = 0;
     f60:	4981                	li	s3,0
     f62:	b571                	j	dee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     f64:	008b8913          	addi	s2,s7,8
     f68:	4681                	li	a3,0
     f6a:	4641                	li	a2,16
     f6c:	000bb583          	ld	a1,0(s7)
     f70:	855a                	mv	a0,s6
     f72:	d87ff0ef          	jal	ra,cf8 <printint>
        i += 1;
     f76:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     f78:	8bca                	mv	s7,s2
      state = 0;
     f7a:	4981                	li	s3,0
        i += 1;
     f7c:	bd8d                	j	dee <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
     f7e:	008b8793          	addi	a5,s7,8
     f82:	f8f43423          	sd	a5,-120(s0)
     f86:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     f8a:	03000593          	li	a1,48
     f8e:	855a                	mv	a0,s6
     f90:	d4bff0ef          	jal	ra,cda <putc>
  putc(fd, 'x');
     f94:	07800593          	li	a1,120
     f98:	855a                	mv	a0,s6
     f9a:	d41ff0ef          	jal	ra,cda <putc>
     f9e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     fa0:	03c9d793          	srli	a5,s3,0x3c
     fa4:	97e6                	add	a5,a5,s9
     fa6:	0007c583          	lbu	a1,0(a5)
     faa:	855a                	mv	a0,s6
     fac:	d2fff0ef          	jal	ra,cda <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     fb0:	0992                	slli	s3,s3,0x4
     fb2:	397d                	addiw	s2,s2,-1
     fb4:	fe0916e3          	bnez	s2,fa0 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
     fb8:	f8843b83          	ld	s7,-120(s0)
      state = 0;
     fbc:	4981                	li	s3,0
     fbe:	bd05                	j	dee <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
     fc0:	008b8913          	addi	s2,s7,8
     fc4:	000bc583          	lbu	a1,0(s7)
     fc8:	855a                	mv	a0,s6
     fca:	d11ff0ef          	jal	ra,cda <putc>
     fce:	8bca                	mv	s7,s2
      state = 0;
     fd0:	4981                	li	s3,0
     fd2:	bd31                	j	dee <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
     fd4:	008b8993          	addi	s3,s7,8
     fd8:	000bb903          	ld	s2,0(s7)
     fdc:	00090f63          	beqz	s2,ffa <vprintf+0x266>
        for(; *s; s++)
     fe0:	00094583          	lbu	a1,0(s2)
     fe4:	c195                	beqz	a1,1008 <vprintf+0x274>
          putc(fd, *s);
     fe6:	855a                	mv	a0,s6
     fe8:	cf3ff0ef          	jal	ra,cda <putc>
        for(; *s; s++)
     fec:	0905                	addi	s2,s2,1
     fee:	00094583          	lbu	a1,0(s2)
     ff2:	f9f5                	bnez	a1,fe6 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
     ff4:	8bce                	mv	s7,s3
      state = 0;
     ff6:	4981                	li	s3,0
     ff8:	bbdd                	j	dee <vprintf+0x5a>
          s = "(null)";
     ffa:	00000917          	auipc	s2,0x0
     ffe:	33690913          	addi	s2,s2,822 # 1330 <malloc+0x226>
        for(; *s; s++)
    1002:	02800593          	li	a1,40
    1006:	b7c5                	j	fe6 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
    1008:	8bce                	mv	s7,s3
      state = 0;
    100a:	4981                	li	s3,0
    100c:	b3cd                	j	dee <vprintf+0x5a>
    }
  }
}
    100e:	70e6                	ld	ra,120(sp)
    1010:	7446                	ld	s0,112(sp)
    1012:	74a6                	ld	s1,104(sp)
    1014:	7906                	ld	s2,96(sp)
    1016:	69e6                	ld	s3,88(sp)
    1018:	6a46                	ld	s4,80(sp)
    101a:	6aa6                	ld	s5,72(sp)
    101c:	6b06                	ld	s6,64(sp)
    101e:	7be2                	ld	s7,56(sp)
    1020:	7c42                	ld	s8,48(sp)
    1022:	7ca2                	ld	s9,40(sp)
    1024:	7d02                	ld	s10,32(sp)
    1026:	6de2                	ld	s11,24(sp)
    1028:	6109                	addi	sp,sp,128
    102a:	8082                	ret

000000000000102c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    102c:	715d                	addi	sp,sp,-80
    102e:	ec06                	sd	ra,24(sp)
    1030:	e822                	sd	s0,16(sp)
    1032:	1000                	addi	s0,sp,32
    1034:	e010                	sd	a2,0(s0)
    1036:	e414                	sd	a3,8(s0)
    1038:	e818                	sd	a4,16(s0)
    103a:	ec1c                	sd	a5,24(s0)
    103c:	03043023          	sd	a6,32(s0)
    1040:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1044:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1048:	8622                	mv	a2,s0
    104a:	d4bff0ef          	jal	ra,d94 <vprintf>
}
    104e:	60e2                	ld	ra,24(sp)
    1050:	6442                	ld	s0,16(sp)
    1052:	6161                	addi	sp,sp,80
    1054:	8082                	ret

0000000000001056 <printf>:

void
printf(const char *fmt, ...)
{
    1056:	711d                	addi	sp,sp,-96
    1058:	ec06                	sd	ra,24(sp)
    105a:	e822                	sd	s0,16(sp)
    105c:	1000                	addi	s0,sp,32
    105e:	e40c                	sd	a1,8(s0)
    1060:	e810                	sd	a2,16(s0)
    1062:	ec14                	sd	a3,24(s0)
    1064:	f018                	sd	a4,32(s0)
    1066:	f41c                	sd	a5,40(s0)
    1068:	03043823          	sd	a6,48(s0)
    106c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1070:	00840613          	addi	a2,s0,8
    1074:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1078:	85aa                	mv	a1,a0
    107a:	4505                	li	a0,1
    107c:	d19ff0ef          	jal	ra,d94 <vprintf>
}
    1080:	60e2                	ld	ra,24(sp)
    1082:	6442                	ld	s0,16(sp)
    1084:	6125                	addi	sp,sp,96
    1086:	8082                	ret

0000000000001088 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1088:	1141                	addi	sp,sp,-16
    108a:	e422                	sd	s0,8(sp)
    108c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    108e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1092:	00001797          	auipc	a5,0x1
    1096:	f7e7b783          	ld	a5,-130(a5) # 2010 <freep>
    109a:	a02d                	j	10c4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    109c:	4618                	lw	a4,8(a2)
    109e:	9f2d                	addw	a4,a4,a1
    10a0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    10a4:	6398                	ld	a4,0(a5)
    10a6:	6310                	ld	a2,0(a4)
    10a8:	a83d                	j	10e6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    10aa:	ff852703          	lw	a4,-8(a0)
    10ae:	9f31                	addw	a4,a4,a2
    10b0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    10b2:	ff053683          	ld	a3,-16(a0)
    10b6:	a091                	j	10fa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10b8:	6398                	ld	a4,0(a5)
    10ba:	00e7e463          	bltu	a5,a4,10c2 <free+0x3a>
    10be:	00e6ea63          	bltu	a3,a4,10d2 <free+0x4a>
{
    10c2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10c4:	fed7fae3          	bgeu	a5,a3,10b8 <free+0x30>
    10c8:	6398                	ld	a4,0(a5)
    10ca:	00e6e463          	bltu	a3,a4,10d2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10ce:	fee7eae3          	bltu	a5,a4,10c2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    10d2:	ff852583          	lw	a1,-8(a0)
    10d6:	6390                	ld	a2,0(a5)
    10d8:	02059813          	slli	a6,a1,0x20
    10dc:	01c85713          	srli	a4,a6,0x1c
    10e0:	9736                	add	a4,a4,a3
    10e2:	fae60de3          	beq	a2,a4,109c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    10e6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    10ea:	4790                	lw	a2,8(a5)
    10ec:	02061593          	slli	a1,a2,0x20
    10f0:	01c5d713          	srli	a4,a1,0x1c
    10f4:	973e                	add	a4,a4,a5
    10f6:	fae68ae3          	beq	a3,a4,10aa <free+0x22>
    p->s.ptr = bp->s.ptr;
    10fa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    10fc:	00001717          	auipc	a4,0x1
    1100:	f0f73a23          	sd	a5,-236(a4) # 2010 <freep>
}
    1104:	6422                	ld	s0,8(sp)
    1106:	0141                	addi	sp,sp,16
    1108:	8082                	ret

000000000000110a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    110a:	7139                	addi	sp,sp,-64
    110c:	fc06                	sd	ra,56(sp)
    110e:	f822                	sd	s0,48(sp)
    1110:	f426                	sd	s1,40(sp)
    1112:	f04a                	sd	s2,32(sp)
    1114:	ec4e                	sd	s3,24(sp)
    1116:	e852                	sd	s4,16(sp)
    1118:	e456                	sd	s5,8(sp)
    111a:	e05a                	sd	s6,0(sp)
    111c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    111e:	02051493          	slli	s1,a0,0x20
    1122:	9081                	srli	s1,s1,0x20
    1124:	04bd                	addi	s1,s1,15
    1126:	8091                	srli	s1,s1,0x4
    1128:	0014899b          	addiw	s3,s1,1
    112c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    112e:	00001517          	auipc	a0,0x1
    1132:	ee253503          	ld	a0,-286(a0) # 2010 <freep>
    1136:	c515                	beqz	a0,1162 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1138:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    113a:	4798                	lw	a4,8(a5)
    113c:	02977f63          	bgeu	a4,s1,117a <malloc+0x70>
    1140:	8a4e                	mv	s4,s3
    1142:	0009871b          	sext.w	a4,s3
    1146:	6685                	lui	a3,0x1
    1148:	00d77363          	bgeu	a4,a3,114e <malloc+0x44>
    114c:	6a05                	lui	s4,0x1
    114e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1152:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1156:	00001917          	auipc	s2,0x1
    115a:	eba90913          	addi	s2,s2,-326 # 2010 <freep>
  if(p == SBRK_ERROR)
    115e:	5afd                	li	s5,-1
    1160:	a885                	j	11d0 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
    1162:	00001797          	auipc	a5,0x1
    1166:	f2678793          	addi	a5,a5,-218 # 2088 <base>
    116a:	00001717          	auipc	a4,0x1
    116e:	eaf73323          	sd	a5,-346(a4) # 2010 <freep>
    1172:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1174:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1178:	b7e1                	j	1140 <malloc+0x36>
      if(p->s.size == nunits)
    117a:	02e48c63          	beq	s1,a4,11b2 <malloc+0xa8>
        p->s.size -= nunits;
    117e:	4137073b          	subw	a4,a4,s3
    1182:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1184:	02071693          	slli	a3,a4,0x20
    1188:	01c6d713          	srli	a4,a3,0x1c
    118c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    118e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1192:	00001717          	auipc	a4,0x1
    1196:	e6a73f23          	sd	a0,-386(a4) # 2010 <freep>
      return (void*)(p + 1);
    119a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    119e:	70e2                	ld	ra,56(sp)
    11a0:	7442                	ld	s0,48(sp)
    11a2:	74a2                	ld	s1,40(sp)
    11a4:	7902                	ld	s2,32(sp)
    11a6:	69e2                	ld	s3,24(sp)
    11a8:	6a42                	ld	s4,16(sp)
    11aa:	6aa2                	ld	s5,8(sp)
    11ac:	6b02                	ld	s6,0(sp)
    11ae:	6121                	addi	sp,sp,64
    11b0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    11b2:	6398                	ld	a4,0(a5)
    11b4:	e118                	sd	a4,0(a0)
    11b6:	bff1                	j	1192 <malloc+0x88>
  hp->s.size = nu;
    11b8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    11bc:	0541                	addi	a0,a0,16
    11be:	ecbff0ef          	jal	ra,1088 <free>
  return freep;
    11c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    11c6:	dd61                	beqz	a0,119e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    11c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    11ca:	4798                	lw	a4,8(a5)
    11cc:	fa9777e3          	bgeu	a4,s1,117a <malloc+0x70>
    if(p == freep)
    11d0:	00093703          	ld	a4,0(s2)
    11d4:	853e                	mv	a0,a5
    11d6:	fef719e3          	bne	a4,a5,11c8 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
    11da:	8552                	mv	a0,s4
    11dc:	a1bff0ef          	jal	ra,bf6 <sbrk>
  if(p == SBRK_ERROR)
    11e0:	fd551ce3          	bne	a0,s5,11b8 <malloc+0xae>
        return 0;
    11e4:	4501                	li	a0,0
    11e6:	bf65                	j	119e <malloc+0x94>
