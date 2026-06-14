
user/_sh:     file format elf64-littleriscv


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
      16:	20e58593          	addi	a1,a1,526 # 1220 <malloc+0xe6>
      1a:	4509                	li	a0,2
      1c:	429000ef          	jal	ra,c44 <write>
  memset(buf, 0, nbuf);
      20:	864a                	mv	a2,s2
      22:	4581                	li	a1,0
      24:	8526                	mv	a0,s1
      26:	1eb000ef          	jal	ra,a10 <memset>
  gets(buf, nbuf);
      2a:	85ca                	mv	a1,s2
      2c:	8526                	mv	a0,s1
      2e:	229000ef          	jal	ra,a56 <gets>
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
      58:	1d458593          	addi	a1,a1,468 # 1228 <malloc+0xee>
      5c:	4509                	li	a0,2
      5e:	7f9000ef          	jal	ra,1056 <fprintf>
  exit(1);
      62:	4505                	li	a0,1
      64:	3c1000ef          	jal	ra,c24 <exit>

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
      70:	3ad000ef          	jal	ra,c1c <fork>
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
      86:	1ae50513          	addi	a0,a0,430 # 1230 <malloc+0xf6>
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
      ae:	28670713          	addi	a4,a4,646 # 1330 <malloc+0x1f6>
      b2:	97ba                	add	a5,a5,a4
      b4:	439c                	lw	a5,0(a5)
      b6:	97ba                	add	a5,a5,a4
      b8:	8782                	jr	a5
    exit(1);
      ba:	4505                	li	a0,1
      bc:	369000ef          	jal	ra,c24 <exit>
    panic("runcmd");
      c0:	00001517          	auipc	a0,0x1
      c4:	17850513          	addi	a0,a0,376 # 1238 <malloc+0xfe>
      c8:	f83ff0ef          	jal	ra,4a <panic>
    if(ecmd->argv[0] == 0)
      cc:	6508                	ld	a0,8(a0)
      ce:	c105                	beqz	a0,ee <runcmd+0x60>
    exec(ecmd->argv[0], ecmd->argv);
      d0:	00848593          	addi	a1,s1,8
      d4:	389000ef          	jal	ra,c5c <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
      d8:	6490                	ld	a2,8(s1)
      da:	00001597          	auipc	a1,0x1
      de:	16658593          	addi	a1,a1,358 # 1240 <malloc+0x106>
      e2:	4509                	li	a0,2
      e4:	773000ef          	jal	ra,1056 <fprintf>
  exit(0);
      e8:	4501                	li	a0,0
      ea:	33b000ef          	jal	ra,c24 <exit>
      exit(1);
      ee:	4505                	li	a0,1
      f0:	335000ef          	jal	ra,c24 <exit>
    close(rcmd->fd);
      f4:	5148                	lw	a0,36(a0)
      f6:	357000ef          	jal	ra,c4c <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      fa:	508c                	lw	a1,32(s1)
      fc:	6888                	ld	a0,16(s1)
      fe:	367000ef          	jal	ra,c64 <open>
     102:	00054563          	bltz	a0,10c <runcmd+0x7e>
    runcmd(rcmd->cmd);
     106:	6488                	ld	a0,8(s1)
     108:	f87ff0ef          	jal	ra,8e <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     10c:	6890                	ld	a2,16(s1)
     10e:	00001597          	auipc	a1,0x1
     112:	14258593          	addi	a1,a1,322 # 1250 <malloc+0x116>
     116:	4509                	li	a0,2
     118:	73f000ef          	jal	ra,1056 <fprintf>
      exit(1);
     11c:	4505                	li	a0,1
     11e:	307000ef          	jal	ra,c24 <exit>
    if(fork1() == 0)
     122:	f47ff0ef          	jal	ra,68 <fork1>
     126:	e501                	bnez	a0,12e <runcmd+0xa0>
      runcmd(lcmd->left);
     128:	6488                	ld	a0,8(s1)
     12a:	f65ff0ef          	jal	ra,8e <runcmd>
    wait(0);
     12e:	4501                	li	a0,0
     130:	2fd000ef          	jal	ra,c2c <wait>
    runcmd(lcmd->right);
     134:	6888                	ld	a0,16(s1)
     136:	f59ff0ef          	jal	ra,8e <runcmd>
    if(pipe(p) < 0)
     13a:	fd840513          	addi	a0,s0,-40
     13e:	2f7000ef          	jal	ra,c34 <pipe>
     142:	02054763          	bltz	a0,170 <runcmd+0xe2>
    if(fork1() == 0){
     146:	f23ff0ef          	jal	ra,68 <fork1>
     14a:	e90d                	bnez	a0,17c <runcmd+0xee>
      close(1);
     14c:	4505                	li	a0,1
     14e:	2ff000ef          	jal	ra,c4c <close>
      dup(p[1]);
     152:	fdc42503          	lw	a0,-36(s0)
     156:	347000ef          	jal	ra,c9c <dup>
      close(p[0]);
     15a:	fd842503          	lw	a0,-40(s0)
     15e:	2ef000ef          	jal	ra,c4c <close>
      close(p[1]);
     162:	fdc42503          	lw	a0,-36(s0)
     166:	2e7000ef          	jal	ra,c4c <close>
      runcmd(pcmd->left);
     16a:	6488                	ld	a0,8(s1)
     16c:	f23ff0ef          	jal	ra,8e <runcmd>
      panic("pipe");
     170:	00001517          	auipc	a0,0x1
     174:	0f050513          	addi	a0,a0,240 # 1260 <malloc+0x126>
     178:	ed3ff0ef          	jal	ra,4a <panic>
    if(fork1() == 0){
     17c:	eedff0ef          	jal	ra,68 <fork1>
     180:	e115                	bnez	a0,1a4 <runcmd+0x116>
      close(0);
     182:	2cb000ef          	jal	ra,c4c <close>
      dup(p[0]);
     186:	fd842503          	lw	a0,-40(s0)
     18a:	313000ef          	jal	ra,c9c <dup>
      close(p[0]);
     18e:	fd842503          	lw	a0,-40(s0)
     192:	2bb000ef          	jal	ra,c4c <close>
      close(p[1]);
     196:	fdc42503          	lw	a0,-36(s0)
     19a:	2b3000ef          	jal	ra,c4c <close>
      runcmd(pcmd->right);
     19e:	6888                	ld	a0,16(s1)
     1a0:	eefff0ef          	jal	ra,8e <runcmd>
    close(p[0]);
     1a4:	fd842503          	lw	a0,-40(s0)
     1a8:	2a5000ef          	jal	ra,c4c <close>
    close(p[1]);
     1ac:	fdc42503          	lw	a0,-36(s0)
     1b0:	29d000ef          	jal	ra,c4c <close>
    wait(0);
     1b4:	4501                	li	a0,0
     1b6:	277000ef          	jal	ra,c2c <wait>
    wait(0);
     1ba:	4501                	li	a0,0
     1bc:	271000ef          	jal	ra,c2c <wait>
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
     1de:	75d000ef          	jal	ra,113a <malloc>
     1e2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     1e4:	0a800613          	li	a2,168
     1e8:	4581                	li	a1,0
     1ea:	027000ef          	jal	ra,a10 <memset>
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
     220:	71b000ef          	jal	ra,113a <malloc>
     224:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     226:	02800613          	li	a2,40
     22a:	4581                	li	a1,0
     22c:	7e4000ef          	jal	ra,a10 <memset>
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
     272:	6c9000ef          	jal	ra,113a <malloc>
     276:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     278:	4661                	li	a2,24
     27a:	4581                	li	a1,0
     27c:	794000ef          	jal	ra,a10 <memset>
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
     2b0:	68b000ef          	jal	ra,113a <malloc>
     2b4:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2b6:	4661                	li	a2,24
     2b8:	4581                	li	a1,0
     2ba:	756000ef          	jal	ra,a10 <memset>
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
     2ea:	651000ef          	jal	ra,113a <malloc>
     2ee:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2f0:	4641                	li	a2,16
     2f2:	4581                	li	a1,0
     2f4:	71c000ef          	jal	ra,a10 <memset>
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
     334:	00b4fb63          	bgeu	s1,a1,34a <gettoken+0x3c>
     338:	0004c583          	lbu	a1,0(s1)
     33c:	854e                	mv	a0,s3
     33e:	6f4000ef          	jal	ra,a32 <strchr>
     342:	c501                	beqz	a0,34a <gettoken+0x3c>
    s++;
     344:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     346:	fe9919e3          	bne	s2,s1,338 <gettoken+0x2a>
  if(q)
     34a:	000a8463          	beqz	s5,352 <gettoken+0x44>
    *q = s;
     34e:	009ab023          	sd	s1,0(s5)
  ret = *s;
     352:	0004c783          	lbu	a5,0(s1)
     356:	00078a9b          	sext.w	s5,a5
  switch(*s){
     35a:	03c00713          	li	a4,60
     35e:	06f76363          	bltu	a4,a5,3c4 <gettoken+0xb6>
     362:	03a00713          	li	a4,58
     366:	00f76e63          	bltu	a4,a5,382 <gettoken+0x74>
     36a:	cf89                	beqz	a5,384 <gettoken+0x76>
     36c:	02600713          	li	a4,38
     370:	00e78963          	beq	a5,a4,382 <gettoken+0x74>
     374:	fd87879b          	addiw	a5,a5,-40
     378:	0ff7f793          	andi	a5,a5,255
     37c:	4705                	li	a4,1
     37e:	06f76a63          	bltu	a4,a5,3f2 <gettoken+0xe4>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     382:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     384:	000b0463          	beqz	s6,38c <gettoken+0x7e>
    *eq = s;
     388:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     38c:	00002997          	auipc	s3,0x2
     390:	c7c98993          	addi	s3,s3,-900 # 2008 <whitespace>
     394:	0124fb63          	bgeu	s1,s2,3aa <gettoken+0x9c>
     398:	0004c583          	lbu	a1,0(s1)
     39c:	854e                	mv	a0,s3
     39e:	694000ef          	jal	ra,a32 <strchr>
     3a2:	c501                	beqz	a0,3aa <gettoken+0x9c>
    s++;
     3a4:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     3a6:	fe9919e3          	bne	s2,s1,398 <gettoken+0x8a>
  *ps = s;
     3aa:	009a3023          	sd	s1,0(s4)
  return ret;
}
     3ae:	8556                	mv	a0,s5
     3b0:	70e2                	ld	ra,56(sp)
     3b2:	7442                	ld	s0,48(sp)
     3b4:	74a2                	ld	s1,40(sp)
     3b6:	7902                	ld	s2,32(sp)
     3b8:	69e2                	ld	s3,24(sp)
     3ba:	6a42                	ld	s4,16(sp)
     3bc:	6aa2                	ld	s5,8(sp)
     3be:	6b02                	ld	s6,0(sp)
     3c0:	6121                	addi	sp,sp,64
     3c2:	8082                	ret
  switch(*s){
     3c4:	03e00713          	li	a4,62
     3c8:	02e79163          	bne	a5,a4,3ea <gettoken+0xdc>
    s++;
     3cc:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     3d0:	0014c703          	lbu	a4,1(s1)
     3d4:	03e00793          	li	a5,62
      s++;
     3d8:	0489                	addi	s1,s1,2
      ret = '+';
     3da:	02b00a93          	li	s5,43
    if(*s == '>'){
     3de:	faf703e3          	beq	a4,a5,384 <gettoken+0x76>
    s++;
     3e2:	84b6                	mv	s1,a3
  ret = *s;
     3e4:	03e00a93          	li	s5,62
     3e8:	bf71                	j	384 <gettoken+0x76>
  switch(*s){
     3ea:	07c00713          	li	a4,124
     3ee:	f8e78ae3          	beq	a5,a4,382 <gettoken+0x74>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     3f2:	00002997          	auipc	s3,0x2
     3f6:	c1698993          	addi	s3,s3,-1002 # 2008 <whitespace>
     3fa:	00002a97          	auipc	s5,0x2
     3fe:	c06a8a93          	addi	s5,s5,-1018 # 2000 <symbols>
     402:	0324f163          	bgeu	s1,s2,424 <gettoken+0x116>
     406:	0004c583          	lbu	a1,0(s1)
     40a:	854e                	mv	a0,s3
     40c:	626000ef          	jal	ra,a32 <strchr>
     410:	e115                	bnez	a0,434 <gettoken+0x126>
     412:	0004c583          	lbu	a1,0(s1)
     416:	8556                	mv	a0,s5
     418:	61a000ef          	jal	ra,a32 <strchr>
     41c:	e909                	bnez	a0,42e <gettoken+0x120>
      s++;
     41e:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     420:	fe9913e3          	bne	s2,s1,406 <gettoken+0xf8>
  if(eq)
     424:	06100a93          	li	s5,97
     428:	f60b10e3          	bnez	s6,388 <gettoken+0x7a>
     42c:	bfbd                	j	3aa <gettoken+0x9c>
    ret = 'a';
     42e:	06100a93          	li	s5,97
     432:	bf89                	j	384 <gettoken+0x76>
     434:	06100a93          	li	s5,97
     438:	b7b1                	j	384 <gettoken+0x76>

000000000000043a <peek>:

int
peek(char **ps, char *es, char *toks)
{
     43a:	7139                	addi	sp,sp,-64
     43c:	fc06                	sd	ra,56(sp)
     43e:	f822                	sd	s0,48(sp)
     440:	f426                	sd	s1,40(sp)
     442:	f04a                	sd	s2,32(sp)
     444:	ec4e                	sd	s3,24(sp)
     446:	e852                	sd	s4,16(sp)
     448:	e456                	sd	s5,8(sp)
     44a:	0080                	addi	s0,sp,64
     44c:	8a2a                	mv	s4,a0
     44e:	892e                	mv	s2,a1
     450:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     452:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     454:	00002997          	auipc	s3,0x2
     458:	bb498993          	addi	s3,s3,-1100 # 2008 <whitespace>
     45c:	00b4fb63          	bgeu	s1,a1,472 <peek+0x38>
     460:	0004c583          	lbu	a1,0(s1)
     464:	854e                	mv	a0,s3
     466:	5cc000ef          	jal	ra,a32 <strchr>
     46a:	c501                	beqz	a0,472 <peek+0x38>
    s++;
     46c:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     46e:	fe9919e3          	bne	s2,s1,460 <peek+0x26>
  *ps = s;
     472:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     476:	0004c583          	lbu	a1,0(s1)
     47a:	4501                	li	a0,0
     47c:	e991                	bnez	a1,490 <peek+0x56>
}
     47e:	70e2                	ld	ra,56(sp)
     480:	7442                	ld	s0,48(sp)
     482:	74a2                	ld	s1,40(sp)
     484:	7902                	ld	s2,32(sp)
     486:	69e2                	ld	s3,24(sp)
     488:	6a42                	ld	s4,16(sp)
     48a:	6aa2                	ld	s5,8(sp)
     48c:	6121                	addi	sp,sp,64
     48e:	8082                	ret
  return *s && strchr(toks, *s);
     490:	8556                	mv	a0,s5
     492:	5a0000ef          	jal	ra,a32 <strchr>
     496:	00a03533          	snez	a0,a0
     49a:	b7d5                	j	47e <peek+0x44>

000000000000049c <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     49c:	7159                	addi	sp,sp,-112
     49e:	f486                	sd	ra,104(sp)
     4a0:	f0a2                	sd	s0,96(sp)
     4a2:	eca6                	sd	s1,88(sp)
     4a4:	e8ca                	sd	s2,80(sp)
     4a6:	e4ce                	sd	s3,72(sp)
     4a8:	e0d2                	sd	s4,64(sp)
     4aa:	fc56                	sd	s5,56(sp)
     4ac:	f85a                	sd	s6,48(sp)
     4ae:	f45e                	sd	s7,40(sp)
     4b0:	f062                	sd	s8,32(sp)
     4b2:	ec66                	sd	s9,24(sp)
     4b4:	1880                	addi	s0,sp,112
     4b6:	8a2a                	mv	s4,a0
     4b8:	89ae                	mv	s3,a1
     4ba:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     4bc:	00001b97          	auipc	s7,0x1
     4c0:	dccb8b93          	addi	s7,s7,-564 # 1288 <malloc+0x14e>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     4c4:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     4c8:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     4cc:	a00d                	j	4ee <parseredirs+0x52>
      panic("missing file for redirection");
     4ce:	00001517          	auipc	a0,0x1
     4d2:	d9a50513          	addi	a0,a0,-614 # 1268 <malloc+0x12e>
     4d6:	b75ff0ef          	jal	ra,4a <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     4da:	4701                	li	a4,0
     4dc:	4681                	li	a3,0
     4de:	f9043603          	ld	a2,-112(s0)
     4e2:	f9843583          	ld	a1,-104(s0)
     4e6:	8552                	mv	a0,s4
     4e8:	d17ff0ef          	jal	ra,1fe <redircmd>
     4ec:	8a2a                	mv	s4,a0
    switch(tok){
     4ee:	03e00b13          	li	s6,62
     4f2:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     4f6:	865e                	mv	a2,s7
     4f8:	85ca                	mv	a1,s2
     4fa:	854e                	mv	a0,s3
     4fc:	f3fff0ef          	jal	ra,43a <peek>
     500:	c125                	beqz	a0,560 <parseredirs+0xc4>
    tok = gettoken(ps, es, 0, 0);
     502:	4681                	li	a3,0
     504:	4601                	li	a2,0
     506:	85ca                	mv	a1,s2
     508:	854e                	mv	a0,s3
     50a:	e05ff0ef          	jal	ra,30e <gettoken>
     50e:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     510:	f9040693          	addi	a3,s0,-112
     514:	f9840613          	addi	a2,s0,-104
     518:	85ca                	mv	a1,s2
     51a:	854e                	mv	a0,s3
     51c:	df3ff0ef          	jal	ra,30e <gettoken>
     520:	fb8517e3          	bne	a0,s8,4ce <parseredirs+0x32>
    switch(tok){
     524:	fb948be3          	beq	s1,s9,4da <parseredirs+0x3e>
     528:	03648063          	beq	s1,s6,548 <parseredirs+0xac>
     52c:	fd5495e3          	bne	s1,s5,4f6 <parseredirs+0x5a>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     530:	4705                	li	a4,1
     532:	20100693          	li	a3,513
     536:	f9043603          	ld	a2,-112(s0)
     53a:	f9843583          	ld	a1,-104(s0)
     53e:	8552                	mv	a0,s4
     540:	cbfff0ef          	jal	ra,1fe <redircmd>
     544:	8a2a                	mv	s4,a0
      break;
     546:	b765                	j	4ee <parseredirs+0x52>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     548:	4705                	li	a4,1
     54a:	60100693          	li	a3,1537
     54e:	f9043603          	ld	a2,-112(s0)
     552:	f9843583          	ld	a1,-104(s0)
     556:	8552                	mv	a0,s4
     558:	ca7ff0ef          	jal	ra,1fe <redircmd>
     55c:	8a2a                	mv	s4,a0
      break;
     55e:	bf41                	j	4ee <parseredirs+0x52>
    }
  }
  return cmd;
}
     560:	8552                	mv	a0,s4
     562:	70a6                	ld	ra,104(sp)
     564:	7406                	ld	s0,96(sp)
     566:	64e6                	ld	s1,88(sp)
     568:	6946                	ld	s2,80(sp)
     56a:	69a6                	ld	s3,72(sp)
     56c:	6a06                	ld	s4,64(sp)
     56e:	7ae2                	ld	s5,56(sp)
     570:	7b42                	ld	s6,48(sp)
     572:	7ba2                	ld	s7,40(sp)
     574:	7c02                	ld	s8,32(sp)
     576:	6ce2                	ld	s9,24(sp)
     578:	6165                	addi	sp,sp,112
     57a:	8082                	ret

000000000000057c <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     57c:	7159                	addi	sp,sp,-112
     57e:	f486                	sd	ra,104(sp)
     580:	f0a2                	sd	s0,96(sp)
     582:	eca6                	sd	s1,88(sp)
     584:	e8ca                	sd	s2,80(sp)
     586:	e4ce                	sd	s3,72(sp)
     588:	e0d2                	sd	s4,64(sp)
     58a:	fc56                	sd	s5,56(sp)
     58c:	f85a                	sd	s6,48(sp)
     58e:	f45e                	sd	s7,40(sp)
     590:	f062                	sd	s8,32(sp)
     592:	ec66                	sd	s9,24(sp)
     594:	1880                	addi	s0,sp,112
     596:	8a2a                	mv	s4,a0
     598:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     59a:	00001617          	auipc	a2,0x1
     59e:	cf660613          	addi	a2,a2,-778 # 1290 <malloc+0x156>
     5a2:	e99ff0ef          	jal	ra,43a <peek>
     5a6:	e505                	bnez	a0,5ce <parseexec+0x52>
     5a8:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     5aa:	c27ff0ef          	jal	ra,1d0 <execcmd>
     5ae:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     5b0:	8656                	mv	a2,s5
     5b2:	85d2                	mv	a1,s4
     5b4:	ee9ff0ef          	jal	ra,49c <parseredirs>
     5b8:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     5ba:	008c0913          	addi	s2,s8,8
     5be:	00001b17          	auipc	s6,0x1
     5c2:	cf2b0b13          	addi	s6,s6,-782 # 12b0 <malloc+0x176>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     5c6:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     5ca:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     5cc:	a081                	j	60c <parseexec+0x90>
    return parseblock(ps, es);
     5ce:	85d6                	mv	a1,s5
     5d0:	8552                	mv	a0,s4
     5d2:	170000ef          	jal	ra,742 <parseblock>
     5d6:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     5d8:	8526                	mv	a0,s1
     5da:	70a6                	ld	ra,104(sp)
     5dc:	7406                	ld	s0,96(sp)
     5de:	64e6                	ld	s1,88(sp)
     5e0:	6946                	ld	s2,80(sp)
     5e2:	69a6                	ld	s3,72(sp)
     5e4:	6a06                	ld	s4,64(sp)
     5e6:	7ae2                	ld	s5,56(sp)
     5e8:	7b42                	ld	s6,48(sp)
     5ea:	7ba2                	ld	s7,40(sp)
     5ec:	7c02                	ld	s8,32(sp)
     5ee:	6ce2                	ld	s9,24(sp)
     5f0:	6165                	addi	sp,sp,112
     5f2:	8082                	ret
      panic("syntax");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	ca450513          	addi	a0,a0,-860 # 1298 <malloc+0x15e>
     5fc:	a4fff0ef          	jal	ra,4a <panic>
    ret = parseredirs(ret, ps, es);
     600:	8656                	mv	a2,s5
     602:	85d2                	mv	a1,s4
     604:	8526                	mv	a0,s1
     606:	e97ff0ef          	jal	ra,49c <parseredirs>
     60a:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     60c:	865a                	mv	a2,s6
     60e:	85d6                	mv	a1,s5
     610:	8552                	mv	a0,s4
     612:	e29ff0ef          	jal	ra,43a <peek>
     616:	ed15                	bnez	a0,652 <parseexec+0xd6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     618:	f9040693          	addi	a3,s0,-112
     61c:	f9840613          	addi	a2,s0,-104
     620:	85d6                	mv	a1,s5
     622:	8552                	mv	a0,s4
     624:	cebff0ef          	jal	ra,30e <gettoken>
     628:	c50d                	beqz	a0,652 <parseexec+0xd6>
    if(tok != 'a')
     62a:	fd9515e3          	bne	a0,s9,5f4 <parseexec+0x78>
    cmd->argv[argc] = q;
     62e:	f9843783          	ld	a5,-104(s0)
     632:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     636:	f9043783          	ld	a5,-112(s0)
     63a:	04f93823          	sd	a5,80(s2)
    argc++;
     63e:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     640:	0921                	addi	s2,s2,8
     642:	fb799fe3          	bne	s3,s7,600 <parseexec+0x84>
      panic("too many args");
     646:	00001517          	auipc	a0,0x1
     64a:	c5a50513          	addi	a0,a0,-934 # 12a0 <malloc+0x166>
     64e:	9fdff0ef          	jal	ra,4a <panic>
  cmd->argv[argc] = 0;
     652:	098e                	slli	s3,s3,0x3
     654:	99e2                	add	s3,s3,s8
     656:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     65a:	0409bc23          	sd	zero,88(s3)
  return ret;
     65e:	bfad                	j	5d8 <parseexec+0x5c>

0000000000000660 <parsepipe>:
{
     660:	7179                	addi	sp,sp,-48
     662:	f406                	sd	ra,40(sp)
     664:	f022                	sd	s0,32(sp)
     666:	ec26                	sd	s1,24(sp)
     668:	e84a                	sd	s2,16(sp)
     66a:	e44e                	sd	s3,8(sp)
     66c:	1800                	addi	s0,sp,48
     66e:	892a                	mv	s2,a0
     670:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     672:	f0bff0ef          	jal	ra,57c <parseexec>
     676:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     678:	00001617          	auipc	a2,0x1
     67c:	c4060613          	addi	a2,a2,-960 # 12b8 <malloc+0x17e>
     680:	85ce                	mv	a1,s3
     682:	854a                	mv	a0,s2
     684:	db7ff0ef          	jal	ra,43a <peek>
     688:	e909                	bnez	a0,69a <parsepipe+0x3a>
}
     68a:	8526                	mv	a0,s1
     68c:	70a2                	ld	ra,40(sp)
     68e:	7402                	ld	s0,32(sp)
     690:	64e2                	ld	s1,24(sp)
     692:	6942                	ld	s2,16(sp)
     694:	69a2                	ld	s3,8(sp)
     696:	6145                	addi	sp,sp,48
     698:	8082                	ret
    gettoken(ps, es, 0, 0);
     69a:	4681                	li	a3,0
     69c:	4601                	li	a2,0
     69e:	85ce                	mv	a1,s3
     6a0:	854a                	mv	a0,s2
     6a2:	c6dff0ef          	jal	ra,30e <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     6a6:	85ce                	mv	a1,s3
     6a8:	854a                	mv	a0,s2
     6aa:	fb7ff0ef          	jal	ra,660 <parsepipe>
     6ae:	85aa                	mv	a1,a0
     6b0:	8526                	mv	a0,s1
     6b2:	badff0ef          	jal	ra,25e <pipecmd>
     6b6:	84aa                	mv	s1,a0
  return cmd;
     6b8:	bfc9                	j	68a <parsepipe+0x2a>

00000000000006ba <parseline>:
{
     6ba:	7179                	addi	sp,sp,-48
     6bc:	f406                	sd	ra,40(sp)
     6be:	f022                	sd	s0,32(sp)
     6c0:	ec26                	sd	s1,24(sp)
     6c2:	e84a                	sd	s2,16(sp)
     6c4:	e44e                	sd	s3,8(sp)
     6c6:	e052                	sd	s4,0(sp)
     6c8:	1800                	addi	s0,sp,48
     6ca:	892a                	mv	s2,a0
     6cc:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     6ce:	f93ff0ef          	jal	ra,660 <parsepipe>
     6d2:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     6d4:	00001a17          	auipc	s4,0x1
     6d8:	beca0a13          	addi	s4,s4,-1044 # 12c0 <malloc+0x186>
     6dc:	a819                	j	6f2 <parseline+0x38>
    gettoken(ps, es, 0, 0);
     6de:	4681                	li	a3,0
     6e0:	4601                	li	a2,0
     6e2:	85ce                	mv	a1,s3
     6e4:	854a                	mv	a0,s2
     6e6:	c29ff0ef          	jal	ra,30e <gettoken>
    cmd = backcmd(cmd);
     6ea:	8526                	mv	a0,s1
     6ec:	befff0ef          	jal	ra,2da <backcmd>
     6f0:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     6f2:	8652                	mv	a2,s4
     6f4:	85ce                	mv	a1,s3
     6f6:	854a                	mv	a0,s2
     6f8:	d43ff0ef          	jal	ra,43a <peek>
     6fc:	f16d                	bnez	a0,6de <parseline+0x24>
  if(peek(ps, es, ";")){
     6fe:	00001617          	auipc	a2,0x1
     702:	bca60613          	addi	a2,a2,-1078 # 12c8 <malloc+0x18e>
     706:	85ce                	mv	a1,s3
     708:	854a                	mv	a0,s2
     70a:	d31ff0ef          	jal	ra,43a <peek>
     70e:	e911                	bnez	a0,722 <parseline+0x68>
}
     710:	8526                	mv	a0,s1
     712:	70a2                	ld	ra,40(sp)
     714:	7402                	ld	s0,32(sp)
     716:	64e2                	ld	s1,24(sp)
     718:	6942                	ld	s2,16(sp)
     71a:	69a2                	ld	s3,8(sp)
     71c:	6a02                	ld	s4,0(sp)
     71e:	6145                	addi	sp,sp,48
     720:	8082                	ret
    gettoken(ps, es, 0, 0);
     722:	4681                	li	a3,0
     724:	4601                	li	a2,0
     726:	85ce                	mv	a1,s3
     728:	854a                	mv	a0,s2
     72a:	be5ff0ef          	jal	ra,30e <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     72e:	85ce                	mv	a1,s3
     730:	854a                	mv	a0,s2
     732:	f89ff0ef          	jal	ra,6ba <parseline>
     736:	85aa                	mv	a1,a0
     738:	8526                	mv	a0,s1
     73a:	b63ff0ef          	jal	ra,29c <listcmd>
     73e:	84aa                	mv	s1,a0
  return cmd;
     740:	bfc1                	j	710 <parseline+0x56>

0000000000000742 <parseblock>:
{
     742:	7179                	addi	sp,sp,-48
     744:	f406                	sd	ra,40(sp)
     746:	f022                	sd	s0,32(sp)
     748:	ec26                	sd	s1,24(sp)
     74a:	e84a                	sd	s2,16(sp)
     74c:	e44e                	sd	s3,8(sp)
     74e:	1800                	addi	s0,sp,48
     750:	84aa                	mv	s1,a0
     752:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     754:	00001617          	auipc	a2,0x1
     758:	b3c60613          	addi	a2,a2,-1220 # 1290 <malloc+0x156>
     75c:	cdfff0ef          	jal	ra,43a <peek>
     760:	c539                	beqz	a0,7ae <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     762:	4681                	li	a3,0
     764:	4601                	li	a2,0
     766:	85ca                	mv	a1,s2
     768:	8526                	mv	a0,s1
     76a:	ba5ff0ef          	jal	ra,30e <gettoken>
  cmd = parseline(ps, es);
     76e:	85ca                	mv	a1,s2
     770:	8526                	mv	a0,s1
     772:	f49ff0ef          	jal	ra,6ba <parseline>
     776:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     778:	00001617          	auipc	a2,0x1
     77c:	b6860613          	addi	a2,a2,-1176 # 12e0 <malloc+0x1a6>
     780:	85ca                	mv	a1,s2
     782:	8526                	mv	a0,s1
     784:	cb7ff0ef          	jal	ra,43a <peek>
     788:	c90d                	beqz	a0,7ba <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     78a:	4681                	li	a3,0
     78c:	4601                	li	a2,0
     78e:	85ca                	mv	a1,s2
     790:	8526                	mv	a0,s1
     792:	b7dff0ef          	jal	ra,30e <gettoken>
  cmd = parseredirs(cmd, ps, es);
     796:	864a                	mv	a2,s2
     798:	85a6                	mv	a1,s1
     79a:	854e                	mv	a0,s3
     79c:	d01ff0ef          	jal	ra,49c <parseredirs>
}
     7a0:	70a2                	ld	ra,40(sp)
     7a2:	7402                	ld	s0,32(sp)
     7a4:	64e2                	ld	s1,24(sp)
     7a6:	6942                	ld	s2,16(sp)
     7a8:	69a2                	ld	s3,8(sp)
     7aa:	6145                	addi	sp,sp,48
     7ac:	8082                	ret
    panic("parseblock");
     7ae:	00001517          	auipc	a0,0x1
     7b2:	b2250513          	addi	a0,a0,-1246 # 12d0 <malloc+0x196>
     7b6:	895ff0ef          	jal	ra,4a <panic>
    panic("syntax - missing )");
     7ba:	00001517          	auipc	a0,0x1
     7be:	b2e50513          	addi	a0,a0,-1234 # 12e8 <malloc+0x1ae>
     7c2:	889ff0ef          	jal	ra,4a <panic>

00000000000007c6 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     7c6:	1101                	addi	sp,sp,-32
     7c8:	ec06                	sd	ra,24(sp)
     7ca:	e822                	sd	s0,16(sp)
     7cc:	e426                	sd	s1,8(sp)
     7ce:	1000                	addi	s0,sp,32
     7d0:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     7d2:	c131                	beqz	a0,816 <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     7d4:	4118                	lw	a4,0(a0)
     7d6:	4795                	li	a5,5
     7d8:	02e7ef63          	bltu	a5,a4,816 <nulterminate+0x50>
     7dc:	00056783          	lwu	a5,0(a0)
     7e0:	078a                	slli	a5,a5,0x2
     7e2:	00001717          	auipc	a4,0x1
     7e6:	b6670713          	addi	a4,a4,-1178 # 1348 <malloc+0x20e>
     7ea:	97ba                	add	a5,a5,a4
     7ec:	439c                	lw	a5,0(a5)
     7ee:	97ba                	add	a5,a5,a4
     7f0:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     7f2:	651c                	ld	a5,8(a0)
     7f4:	c38d                	beqz	a5,816 <nulterminate+0x50>
     7f6:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     7fa:	67b8                	ld	a4,72(a5)
     7fc:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     800:	07a1                	addi	a5,a5,8
     802:	ff87b703          	ld	a4,-8(a5)
     806:	fb75                	bnez	a4,7fa <nulterminate+0x34>
     808:	a039                	j	816 <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     80a:	6508                	ld	a0,8(a0)
     80c:	fbbff0ef          	jal	ra,7c6 <nulterminate>
    *rcmd->efile = 0;
     810:	6c9c                	ld	a5,24(s1)
     812:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     816:	8526                	mv	a0,s1
     818:	60e2                	ld	ra,24(sp)
     81a:	6442                	ld	s0,16(sp)
     81c:	64a2                	ld	s1,8(sp)
     81e:	6105                	addi	sp,sp,32
     820:	8082                	ret
    nulterminate(pcmd->left);
     822:	6508                	ld	a0,8(a0)
     824:	fa3ff0ef          	jal	ra,7c6 <nulterminate>
    nulterminate(pcmd->right);
     828:	6888                	ld	a0,16(s1)
     82a:	f9dff0ef          	jal	ra,7c6 <nulterminate>
    break;
     82e:	b7e5                	j	816 <nulterminate+0x50>
    nulterminate(lcmd->left);
     830:	6508                	ld	a0,8(a0)
     832:	f95ff0ef          	jal	ra,7c6 <nulterminate>
    nulterminate(lcmd->right);
     836:	6888                	ld	a0,16(s1)
     838:	f8fff0ef          	jal	ra,7c6 <nulterminate>
    break;
     83c:	bfe9                	j	816 <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     83e:	6508                	ld	a0,8(a0)
     840:	f87ff0ef          	jal	ra,7c6 <nulterminate>
    break;
     844:	bfc9                	j	816 <nulterminate+0x50>

0000000000000846 <parsecmd>:
{
     846:	7179                	addi	sp,sp,-48
     848:	f406                	sd	ra,40(sp)
     84a:	f022                	sd	s0,32(sp)
     84c:	ec26                	sd	s1,24(sp)
     84e:	e84a                	sd	s2,16(sp)
     850:	1800                	addi	s0,sp,48
     852:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     856:	84aa                	mv	s1,a0
     858:	18e000ef          	jal	ra,9e6 <strlen>
     85c:	1502                	slli	a0,a0,0x20
     85e:	9101                	srli	a0,a0,0x20
     860:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     862:	85a6                	mv	a1,s1
     864:	fd840513          	addi	a0,s0,-40
     868:	e53ff0ef          	jal	ra,6ba <parseline>
     86c:	892a                	mv	s2,a0
  peek(&s, es, "");
     86e:	00001617          	auipc	a2,0x1
     872:	a9260613          	addi	a2,a2,-1390 # 1300 <malloc+0x1c6>
     876:	85a6                	mv	a1,s1
     878:	fd840513          	addi	a0,s0,-40
     87c:	bbfff0ef          	jal	ra,43a <peek>
  if(s != es){
     880:	fd843603          	ld	a2,-40(s0)
     884:	00961c63          	bne	a2,s1,89c <parsecmd+0x56>
  nulterminate(cmd);
     888:	854a                	mv	a0,s2
     88a:	f3dff0ef          	jal	ra,7c6 <nulterminate>
}
     88e:	854a                	mv	a0,s2
     890:	70a2                	ld	ra,40(sp)
     892:	7402                	ld	s0,32(sp)
     894:	64e2                	ld	s1,24(sp)
     896:	6942                	ld	s2,16(sp)
     898:	6145                	addi	sp,sp,48
     89a:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     89c:	00001597          	auipc	a1,0x1
     8a0:	a6c58593          	addi	a1,a1,-1428 # 1308 <malloc+0x1ce>
     8a4:	4509                	li	a0,2
     8a6:	7b0000ef          	jal	ra,1056 <fprintf>
    panic("syntax");
     8aa:	00001517          	auipc	a0,0x1
     8ae:	9ee50513          	addi	a0,a0,-1554 # 1298 <malloc+0x15e>
     8b2:	f98ff0ef          	jal	ra,4a <panic>

00000000000008b6 <main>:
{
     8b6:	7139                	addi	sp,sp,-64
     8b8:	fc06                	sd	ra,56(sp)
     8ba:	f822                	sd	s0,48(sp)
     8bc:	f426                	sd	s1,40(sp)
     8be:	f04a                	sd	s2,32(sp)
     8c0:	ec4e                	sd	s3,24(sp)
     8c2:	e852                	sd	s4,16(sp)
     8c4:	e456                	sd	s5,8(sp)
     8c6:	e05a                	sd	s6,0(sp)
     8c8:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     8ca:	00001497          	auipc	s1,0x1
     8ce:	a4e48493          	addi	s1,s1,-1458 # 1318 <malloc+0x1de>
     8d2:	4589                	li	a1,2
     8d4:	8526                	mv	a0,s1
     8d6:	38e000ef          	jal	ra,c64 <open>
     8da:	00054763          	bltz	a0,8e8 <main+0x32>
    if(fd >= 3){
     8de:	4789                	li	a5,2
     8e0:	fea7d9e3          	bge	a5,a0,8d2 <main+0x1c>
      close(fd);
     8e4:	368000ef          	jal	ra,c4c <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     8e8:	00001a17          	auipc	s4,0x1
     8ec:	738a0a13          	addi	s4,s4,1848 # 2020 <buf.0>
    while (*cmd == ' ' || *cmd == '\t')
     8f0:	02000913          	li	s2,32
     8f4:	49a5                	li	s3,9
    if (*cmd == '\n') // is a blank command
     8f6:	4aa9                	li	s5,10
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     8f8:	06300b13          	li	s6,99
     8fc:	a805                	j	92c <main+0x76>
      cmd++;
     8fe:	0485                	addi	s1,s1,1
    while (*cmd == ' ' || *cmd == '\t')
     900:	0004c783          	lbu	a5,0(s1)
     904:	ff278de3          	beq	a5,s2,8fe <main+0x48>
     908:	ff378be3          	beq	a5,s3,8fe <main+0x48>
    if (*cmd == '\n') // is a blank command
     90c:	03578063          	beq	a5,s5,92c <main+0x76>
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     910:	01679863          	bne	a5,s6,920 <main+0x6a>
     914:	0014c703          	lbu	a4,1(s1)
     918:	06400793          	li	a5,100
     91c:	02f70463          	beq	a4,a5,944 <main+0x8e>
      if(fork1() == 0)
     920:	f48ff0ef          	jal	ra,68 <fork1>
     924:	cd29                	beqz	a0,97e <main+0xc8>
      wait(0);
     926:	4501                	li	a0,0
     928:	304000ef          	jal	ra,c2c <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     92c:	06400593          	li	a1,100
     930:	8552                	mv	a0,s4
     932:	eceff0ef          	jal	ra,0 <getcmd>
     936:	04054963          	bltz	a0,988 <main+0xd2>
    char *cmd = buf;
     93a:	00001497          	auipc	s1,0x1
     93e:	6e648493          	addi	s1,s1,1766 # 2020 <buf.0>
     942:	bf7d                	j	900 <main+0x4a>
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     944:	0024c783          	lbu	a5,2(s1)
     948:	fd279ce3          	bne	a5,s2,920 <main+0x6a>
      cmd[strlen(cmd)-1] = 0;  // chop \n
     94c:	8526                	mv	a0,s1
     94e:	098000ef          	jal	ra,9e6 <strlen>
     952:	fff5079b          	addiw	a5,a0,-1
     956:	1782                	slli	a5,a5,0x20
     958:	9381                	srli	a5,a5,0x20
     95a:	97a6                	add	a5,a5,s1
     95c:	00078023          	sb	zero,0(a5)
      if(chdir(cmd+3) < 0)
     960:	048d                	addi	s1,s1,3
     962:	8526                	mv	a0,s1
     964:	330000ef          	jal	ra,c94 <chdir>
     968:	fc0552e3          	bgez	a0,92c <main+0x76>
        fprintf(2, "cannot cd %s\n", cmd+3);
     96c:	8626                	mv	a2,s1
     96e:	00001597          	auipc	a1,0x1
     972:	9b258593          	addi	a1,a1,-1614 # 1320 <malloc+0x1e6>
     976:	4509                	li	a0,2
     978:	6de000ef          	jal	ra,1056 <fprintf>
     97c:	bf45                	j	92c <main+0x76>
        runcmd(parsecmd(cmd));
     97e:	8526                	mv	a0,s1
     980:	ec7ff0ef          	jal	ra,846 <parsecmd>
     984:	f0aff0ef          	jal	ra,8e <runcmd>
  exit(0);
     988:	4501                	li	a0,0
     98a:	29a000ef          	jal	ra,c24 <exit>

000000000000098e <start>:
 *   argv - 命令行参数数组
 */

void
start(int argc, char **argv)
{
     98e:	1141                	addi	sp,sp,-16
     990:	e406                	sd	ra,8(sp)
     992:	e022                	sd	s0,0(sp)
     994:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     996:	f21ff0ef          	jal	ra,8b6 <main>
  exit(r);
     99a:	28a000ef          	jal	ra,c24 <exit>

000000000000099e <strcpy>:
 *   目标字符串s的指针
 */

char*
strcpy(char *s, const char *t)
{
     99e:	1141                	addi	sp,sp,-16
     9a0:	e422                	sd	s0,8(sp)
     9a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     9a4:	87aa                	mv	a5,a0
     9a6:	0585                	addi	a1,a1,1
     9a8:	0785                	addi	a5,a5,1
     9aa:	fff5c703          	lbu	a4,-1(a1)
     9ae:	fee78fa3          	sb	a4,-1(a5)
     9b2:	fb75                	bnez	a4,9a6 <strcpy+0x8>
    ;
  return os;
}
     9b4:	6422                	ld	s0,8(sp)
     9b6:	0141                	addi	sp,sp,16
     9b8:	8082                	ret

00000000000009ba <strcmp>:
 *   负数 - p小于q
 */

int
strcmp(const char *p, const char *q)
{
     9ba:	1141                	addi	sp,sp,-16
     9bc:	e422                	sd	s0,8(sp)
     9be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     9c0:	00054783          	lbu	a5,0(a0)
     9c4:	cb91                	beqz	a5,9d8 <strcmp+0x1e>
     9c6:	0005c703          	lbu	a4,0(a1)
     9ca:	00f71763          	bne	a4,a5,9d8 <strcmp+0x1e>
    p++, q++;
     9ce:	0505                	addi	a0,a0,1
     9d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     9d2:	00054783          	lbu	a5,0(a0)
     9d6:	fbe5                	bnez	a5,9c6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     9d8:	0005c503          	lbu	a0,0(a1)
}
     9dc:	40a7853b          	subw	a0,a5,a0
     9e0:	6422                	ld	s0,8(sp)
     9e2:	0141                	addi	sp,sp,16
     9e4:	8082                	ret

00000000000009e6 <strlen>:
 *   字符串s的长度
 */

uint
strlen(const char *s)
{
     9e6:	1141                	addi	sp,sp,-16
     9e8:	e422                	sd	s0,8(sp)
     9ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     9ec:	00054783          	lbu	a5,0(a0)
     9f0:	cf91                	beqz	a5,a0c <strlen+0x26>
     9f2:	0505                	addi	a0,a0,1
     9f4:	87aa                	mv	a5,a0
     9f6:	4685                	li	a3,1
     9f8:	9e89                	subw	a3,a3,a0
     9fa:	00f6853b          	addw	a0,a3,a5
     9fe:	0785                	addi	a5,a5,1
     a00:	fff7c703          	lbu	a4,-1(a5)
     a04:	fb7d                	bnez	a4,9fa <strlen+0x14>
    ;
  return n;
}
     a06:	6422                	ld	s0,8(sp)
     a08:	0141                	addi	sp,sp,16
     a0a:	8082                	ret
  for(n = 0; s[n]; n++)
     a0c:	4501                	li	a0,0
     a0e:	bfe5                	j	a06 <strlen+0x20>

0000000000000a10 <memset>:
 *   目标内存区域dst的指针
 */

void*
memset(void *dst, int c, uint n)
{
     a10:	1141                	addi	sp,sp,-16
     a12:	e422                	sd	s0,8(sp)
     a14:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     a16:	ca19                	beqz	a2,a2c <memset+0x1c>
     a18:	87aa                	mv	a5,a0
     a1a:	1602                	slli	a2,a2,0x20
     a1c:	9201                	srli	a2,a2,0x20
     a1e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     a22:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     a26:	0785                	addi	a5,a5,1
     a28:	fee79de3          	bne	a5,a4,a22 <memset+0x12>
  }
  return dst;
}
     a2c:	6422                	ld	s0,8(sp)
     a2e:	0141                	addi	sp,sp,16
     a30:	8082                	ret

0000000000000a32 <strchr>:
 *   指向找到的字符的指针，如果未找到则返回NULL
 */

char*
strchr(const char *s, char c)
{
     a32:	1141                	addi	sp,sp,-16
     a34:	e422                	sd	s0,8(sp)
     a36:	0800                	addi	s0,sp,16
  for(; *s; s++)
     a38:	00054783          	lbu	a5,0(a0)
     a3c:	cb99                	beqz	a5,a52 <strchr+0x20>
    if(*s == c)
     a3e:	00f58763          	beq	a1,a5,a4c <strchr+0x1a>
  for(; *s; s++)
     a42:	0505                	addi	a0,a0,1
     a44:	00054783          	lbu	a5,0(a0)
     a48:	fbfd                	bnez	a5,a3e <strchr+0xc>
      return (char*)s;
  return 0;
     a4a:	4501                	li	a0,0
}
     a4c:	6422                	ld	s0,8(sp)
     a4e:	0141                	addi	sp,sp,16
     a50:	8082                	ret
  return 0;
     a52:	4501                	li	a0,0
     a54:	bfe5                	j	a4c <strchr+0x1a>

0000000000000a56 <gets>:
 *   指向缓冲区buf的指针，如果读取失败则返回NULL
 */

char*
gets(char *buf, int max)
{
     a56:	711d                	addi	sp,sp,-96
     a58:	ec86                	sd	ra,88(sp)
     a5a:	e8a2                	sd	s0,80(sp)
     a5c:	e4a6                	sd	s1,72(sp)
     a5e:	e0ca                	sd	s2,64(sp)
     a60:	fc4e                	sd	s3,56(sp)
     a62:	f852                	sd	s4,48(sp)
     a64:	f456                	sd	s5,40(sp)
     a66:	f05a                	sd	s6,32(sp)
     a68:	ec5e                	sd	s7,24(sp)
     a6a:	1080                	addi	s0,sp,96
     a6c:	8baa                	mv	s7,a0
     a6e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a70:	892a                	mv	s2,a0
     a72:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a74:	4aa9                	li	s5,10
     a76:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a78:	89a6                	mv	s3,s1
     a7a:	2485                	addiw	s1,s1,1
     a7c:	0344d663          	bge	s1,s4,aa8 <gets+0x52>
    cc = read(0, &c, 1);
     a80:	4605                	li	a2,1
     a82:	faf40593          	addi	a1,s0,-81
     a86:	4501                	li	a0,0
     a88:	1b4000ef          	jal	ra,c3c <read>
    if(cc < 1)
     a8c:	00a05e63          	blez	a0,aa8 <gets+0x52>
    buf[i++] = c;
     a90:	faf44783          	lbu	a5,-81(s0)
     a94:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     a98:	01578763          	beq	a5,s5,aa6 <gets+0x50>
     a9c:	0905                	addi	s2,s2,1
     a9e:	fd679de3          	bne	a5,s6,a78 <gets+0x22>
  for(i=0; i+1 < max; ){
     aa2:	89a6                	mv	s3,s1
     aa4:	a011                	j	aa8 <gets+0x52>
     aa6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     aa8:	99de                	add	s3,s3,s7
     aaa:	00098023          	sb	zero,0(s3)
  return buf;
}
     aae:	855e                	mv	a0,s7
     ab0:	60e6                	ld	ra,88(sp)
     ab2:	6446                	ld	s0,80(sp)
     ab4:	64a6                	ld	s1,72(sp)
     ab6:	6906                	ld	s2,64(sp)
     ab8:	79e2                	ld	s3,56(sp)
     aba:	7a42                	ld	s4,48(sp)
     abc:	7aa2                	ld	s5,40(sp)
     abe:	7b02                	ld	s6,32(sp)
     ac0:	6be2                	ld	s7,24(sp)
     ac2:	6125                	addi	sp,sp,96
     ac4:	8082                	ret

0000000000000ac6 <stat>:
 *   -1 - 失败
 */

int
stat(const char *n, struct stat *st)
{
     ac6:	1101                	addi	sp,sp,-32
     ac8:	ec06                	sd	ra,24(sp)
     aca:	e822                	sd	s0,16(sp)
     acc:	e426                	sd	s1,8(sp)
     ace:	e04a                	sd	s2,0(sp)
     ad0:	1000                	addi	s0,sp,32
     ad2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     ad4:	4581                	li	a1,0
     ad6:	18e000ef          	jal	ra,c64 <open>
  if(fd < 0)
     ada:	02054163          	bltz	a0,afc <stat+0x36>
     ade:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     ae0:	85ca                	mv	a1,s2
     ae2:	19a000ef          	jal	ra,c7c <fstat>
     ae6:	892a                	mv	s2,a0
  close(fd);
     ae8:	8526                	mv	a0,s1
     aea:	162000ef          	jal	ra,c4c <close>
  return r;
}
     aee:	854a                	mv	a0,s2
     af0:	60e2                	ld	ra,24(sp)
     af2:	6442                	ld	s0,16(sp)
     af4:	64a2                	ld	s1,8(sp)
     af6:	6902                	ld	s2,0(sp)
     af8:	6105                	addi	sp,sp,32
     afa:	8082                	ret
    return -1;
     afc:	597d                	li	s2,-1
     afe:	bfc5                	j	aee <stat+0x28>

0000000000000b00 <atoi>:
 *   转换后的整数
 */

int
atoi(const char *s)
{
     b00:	1141                	addi	sp,sp,-16
     b02:	e422                	sd	s0,8(sp)
     b04:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b06:	00054603          	lbu	a2,0(a0)
     b0a:	fd06079b          	addiw	a5,a2,-48
     b0e:	0ff7f793          	andi	a5,a5,255
     b12:	4725                	li	a4,9
     b14:	02f76963          	bltu	a4,a5,b46 <atoi+0x46>
     b18:	86aa                	mv	a3,a0
  n = 0;
     b1a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     b1c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     b1e:	0685                	addi	a3,a3,1
     b20:	0025179b          	slliw	a5,a0,0x2
     b24:	9fa9                	addw	a5,a5,a0
     b26:	0017979b          	slliw	a5,a5,0x1
     b2a:	9fb1                	addw	a5,a5,a2
     b2c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     b30:	0006c603          	lbu	a2,0(a3)
     b34:	fd06071b          	addiw	a4,a2,-48
     b38:	0ff77713          	andi	a4,a4,255
     b3c:	fee5f1e3          	bgeu	a1,a4,b1e <atoi+0x1e>
  return n;
}
     b40:	6422                	ld	s0,8(sp)
     b42:	0141                	addi	sp,sp,16
     b44:	8082                	ret
  n = 0;
     b46:	4501                	li	a0,0
     b48:	bfe5                	j	b40 <atoi+0x40>

0000000000000b4a <memmove>:
 *   目标内存区域vdst的指针
 */

void*
memmove(void *vdst, const void *vsrc, int n)
{
     b4a:	1141                	addi	sp,sp,-16
     b4c:	e422                	sd	s0,8(sp)
     b4e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     b50:	02b57463          	bgeu	a0,a1,b78 <memmove+0x2e>
    while(n-- > 0)
     b54:	00c05f63          	blez	a2,b72 <memmove+0x28>
     b58:	1602                	slli	a2,a2,0x20
     b5a:	9201                	srli	a2,a2,0x20
     b5c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     b60:	872a                	mv	a4,a0
      *dst++ = *src++;
     b62:	0585                	addi	a1,a1,1
     b64:	0705                	addi	a4,a4,1
     b66:	fff5c683          	lbu	a3,-1(a1)
     b6a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     b6e:	fee79ae3          	bne	a5,a4,b62 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     b72:	6422                	ld	s0,8(sp)
     b74:	0141                	addi	sp,sp,16
     b76:	8082                	ret
    dst += n;
     b78:	00c50733          	add	a4,a0,a2
    src += n;
     b7c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     b7e:	fec05ae3          	blez	a2,b72 <memmove+0x28>
     b82:	fff6079b          	addiw	a5,a2,-1
     b86:	1782                	slli	a5,a5,0x20
     b88:	9381                	srli	a5,a5,0x20
     b8a:	fff7c793          	not	a5,a5
     b8e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     b90:	15fd                	addi	a1,a1,-1
     b92:	177d                	addi	a4,a4,-1
     b94:	0005c683          	lbu	a3,0(a1)
     b98:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     b9c:	fee79ae3          	bne	a5,a4,b90 <memmove+0x46>
     ba0:	bfc9                	j	b72 <memmove+0x28>

0000000000000ba2 <memcmp>:
 *   负数 - s1小于s2
 */

int
memcmp(const void *s1, const void *s2, uint n)
{
     ba2:	1141                	addi	sp,sp,-16
     ba4:	e422                	sd	s0,8(sp)
     ba6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     ba8:	ca05                	beqz	a2,bd8 <memcmp+0x36>
     baa:	fff6069b          	addiw	a3,a2,-1
     bae:	1682                	slli	a3,a3,0x20
     bb0:	9281                	srli	a3,a3,0x20
     bb2:	0685                	addi	a3,a3,1
     bb4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     bb6:	00054783          	lbu	a5,0(a0)
     bba:	0005c703          	lbu	a4,0(a1)
     bbe:	00e79863          	bne	a5,a4,bce <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     bc2:	0505                	addi	a0,a0,1
    p2++;
     bc4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     bc6:	fed518e3          	bne	a0,a3,bb6 <memcmp+0x14>
  }
  return 0;
     bca:	4501                	li	a0,0
     bcc:	a019                	j	bd2 <memcmp+0x30>
      return *p1 - *p2;
     bce:	40e7853b          	subw	a0,a5,a4
}
     bd2:	6422                	ld	s0,8(sp)
     bd4:	0141                	addi	sp,sp,16
     bd6:	8082                	ret
  return 0;
     bd8:	4501                	li	a0,0
     bda:	bfe5                	j	bd2 <memcmp+0x30>

0000000000000bdc <memcpy>:
 *   目标内存区域dst的指针
 */

void *
memcpy(void *dst, const void *src, uint n)
{
     bdc:	1141                	addi	sp,sp,-16
     bde:	e406                	sd	ra,8(sp)
     be0:	e022                	sd	s0,0(sp)
     be2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     be4:	f67ff0ef          	jal	ra,b4a <memmove>
}
     be8:	60a2                	ld	ra,8(sp)
     bea:	6402                	ld	s0,0(sp)
     bec:	0141                	addi	sp,sp,16
     bee:	8082                	ret

0000000000000bf0 <sbrk>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrk(int n) {
     bf0:	1141                	addi	sp,sp,-16
     bf2:	e406                	sd	ra,8(sp)
     bf4:	e022                	sd	s0,0(sp)
     bf6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     bf8:	4585                	li	a1,1
     bfa:	0b2000ef          	jal	ra,cac <sys_sbrk>
}
     bfe:	60a2                	ld	ra,8(sp)
     c00:	6402                	ld	s0,0(sp)
     c02:	0141                	addi	sp,sp,16
     c04:	8082                	ret

0000000000000c06 <sbrklazy>:
 * 返回值：
 *   指向新分配内存的指针
 */

char *
sbrklazy(int n) {
     c06:	1141                	addi	sp,sp,-16
     c08:	e406                	sd	ra,8(sp)
     c0a:	e022                	sd	s0,0(sp)
     c0c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     c0e:	4589                	li	a1,2
     c10:	09c000ef          	jal	ra,cac <sys_sbrk>
}
     c14:	60a2                	ld	ra,8(sp)
     c16:	6402                	ld	s0,0(sp)
     c18:	0141                	addi	sp,sp,16
     c1a:	8082                	ret

0000000000000c1c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     c1c:	4885                	li	a7,1
 ecall
     c1e:	00000073          	ecall
 ret
     c22:	8082                	ret

0000000000000c24 <exit>:
.global exit
exit:
 li a7, SYS_exit
     c24:	4889                	li	a7,2
 ecall
     c26:	00000073          	ecall
 ret
     c2a:	8082                	ret

0000000000000c2c <wait>:
.global wait
wait:
 li a7, SYS_wait
     c2c:	488d                	li	a7,3
 ecall
     c2e:	00000073          	ecall
 ret
     c32:	8082                	ret

0000000000000c34 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     c34:	4891                	li	a7,4
 ecall
     c36:	00000073          	ecall
 ret
     c3a:	8082                	ret

0000000000000c3c <read>:
.global read
read:
 li a7, SYS_read
     c3c:	4895                	li	a7,5
 ecall
     c3e:	00000073          	ecall
 ret
     c42:	8082                	ret

0000000000000c44 <write>:
.global write
write:
 li a7, SYS_write
     c44:	48c1                	li	a7,16
 ecall
     c46:	00000073          	ecall
 ret
     c4a:	8082                	ret

0000000000000c4c <close>:
.global close
close:
 li a7, SYS_close
     c4c:	48d5                	li	a7,21
 ecall
     c4e:	00000073          	ecall
 ret
     c52:	8082                	ret

0000000000000c54 <kill>:
.global kill
kill:
 li a7, SYS_kill
     c54:	4899                	li	a7,6
 ecall
     c56:	00000073          	ecall
 ret
     c5a:	8082                	ret

0000000000000c5c <exec>:
.global exec
exec:
 li a7, SYS_exec
     c5c:	489d                	li	a7,7
 ecall
     c5e:	00000073          	ecall
 ret
     c62:	8082                	ret

0000000000000c64 <open>:
.global open
open:
 li a7, SYS_open
     c64:	48bd                	li	a7,15
 ecall
     c66:	00000073          	ecall
 ret
     c6a:	8082                	ret

0000000000000c6c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c6c:	48c5                	li	a7,17
 ecall
     c6e:	00000073          	ecall
 ret
     c72:	8082                	ret

0000000000000c74 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c74:	48c9                	li	a7,18
 ecall
     c76:	00000073          	ecall
 ret
     c7a:	8082                	ret

0000000000000c7c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c7c:	48a1                	li	a7,8
 ecall
     c7e:	00000073          	ecall
 ret
     c82:	8082                	ret

0000000000000c84 <link>:
.global link
link:
 li a7, SYS_link
     c84:	48cd                	li	a7,19
 ecall
     c86:	00000073          	ecall
 ret
     c8a:	8082                	ret

0000000000000c8c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c8c:	48d1                	li	a7,20
 ecall
     c8e:	00000073          	ecall
 ret
     c92:	8082                	ret

0000000000000c94 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c94:	48a5                	li	a7,9
 ecall
     c96:	00000073          	ecall
 ret
     c9a:	8082                	ret

0000000000000c9c <dup>:
.global dup
dup:
 li a7, SYS_dup
     c9c:	48a9                	li	a7,10
 ecall
     c9e:	00000073          	ecall
 ret
     ca2:	8082                	ret

0000000000000ca4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ca4:	48ad                	li	a7,11
 ecall
     ca6:	00000073          	ecall
 ret
     caa:	8082                	ret

0000000000000cac <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     cac:	48b1                	li	a7,12
 ecall
     cae:	00000073          	ecall
 ret
     cb2:	8082                	ret

0000000000000cb4 <pause>:
.global pause
pause:
 li a7, SYS_pause
     cb4:	48b5                	li	a7,13
 ecall
     cb6:	00000073          	ecall
 ret
     cba:	8082                	ret

0000000000000cbc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     cbc:	48b9                	li	a7,14
 ecall
     cbe:	00000073          	ecall
 ret
     cc2:	8082                	ret

0000000000000cc4 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
     cc4:	48d9                	li	a7,22
 ecall
     cc6:	00000073          	ecall
 ret
     cca:	8082                	ret

0000000000000ccc <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
     ccc:	48dd                	li	a7,23
 ecall
     cce:	00000073          	ecall
 ret
     cd2:	8082                	ret

0000000000000cd4 <shmctl>:
.global shmctl
shmctl:
 li a7, SYS_shmctl
     cd4:	48e1                	li	a7,24
 ecall
     cd6:	00000073          	ecall
 ret
     cda:	8082                	ret

0000000000000cdc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     cdc:	48e5                	li	a7,25
 ecall
     cde:	00000073          	ecall
 ret
     ce2:	8082                	ret

0000000000000ce4 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
     ce4:	48e9                	li	a7,26
 ecall
     ce6:	00000073          	ecall
 ret
     cea:	8082                	ret

0000000000000cec <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
     cec:	48ed                	li	a7,27
 ecall
     cee:	00000073          	ecall
 ret
     cf2:	8082                	ret

0000000000000cf4 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
     cf4:	48f1                	li	a7,28
 ecall
     cf6:	00000073          	ecall
 ret
     cfa:	8082                	ret

0000000000000cfc <vmstats>:
.global vmstats
vmstats:
 li a7, SYS_vmstats
     cfc:	48f5                	li	a7,29
 ecall
     cfe:	00000073          	ecall
 ret
     d02:	8082                	ret

0000000000000d04 <putc>:
 *   无
 */

static void
putc(int fd, char c)
{
     d04:	1101                	addi	sp,sp,-32
     d06:	ec06                	sd	ra,24(sp)
     d08:	e822                	sd	s0,16(sp)
     d0a:	1000                	addi	s0,sp,32
     d0c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     d10:	4605                	li	a2,1
     d12:	fef40593          	addi	a1,s0,-17
     d16:	f2fff0ef          	jal	ra,c44 <write>
}
     d1a:	60e2                	ld	ra,24(sp)
     d1c:	6442                	ld	s0,16(sp)
     d1e:	6105                	addi	sp,sp,32
     d20:	8082                	ret

0000000000000d22 <printint>:
 *   无
 */

static void
printint(int fd, long long xx, int base, int sgn)
{
     d22:	715d                	addi	sp,sp,-80
     d24:	e486                	sd	ra,72(sp)
     d26:	e0a2                	sd	s0,64(sp)
     d28:	fc26                	sd	s1,56(sp)
     d2a:	f84a                	sd	s2,48(sp)
     d2c:	f44e                	sd	s3,40(sp)
     d2e:	0880                	addi	s0,sp,80
     d30:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     d32:	c299                	beqz	a3,d38 <printint+0x16>
     d34:	0805c163          	bltz	a1,db6 <printint+0x94>
  neg = 0;
     d38:	4881                	li	a7,0
     d3a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     d3e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     d40:	00000517          	auipc	a0,0x0
     d44:	62850513          	addi	a0,a0,1576 # 1368 <digits>
     d48:	883e                	mv	a6,a5
     d4a:	2785                	addiw	a5,a5,1
     d4c:	02c5f733          	remu	a4,a1,a2
     d50:	972a                	add	a4,a4,a0
     d52:	00074703          	lbu	a4,0(a4)
     d56:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     d5a:	872e                	mv	a4,a1
     d5c:	02c5d5b3          	divu	a1,a1,a2
     d60:	0685                	addi	a3,a3,1
     d62:	fec773e3          	bgeu	a4,a2,d48 <printint+0x26>
  if(neg)
     d66:	00088b63          	beqz	a7,d7c <printint+0x5a>
    buf[i++] = '-';
     d6a:	fd040713          	addi	a4,s0,-48
     d6e:	97ba                	add	a5,a5,a4
     d70:	02d00713          	li	a4,45
     d74:	fee78423          	sb	a4,-24(a5)
     d78:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     d7c:	02f05663          	blez	a5,da8 <printint+0x86>
     d80:	fb840713          	addi	a4,s0,-72
     d84:	00f704b3          	add	s1,a4,a5
     d88:	fff70993          	addi	s3,a4,-1
     d8c:	99be                	add	s3,s3,a5
     d8e:	37fd                	addiw	a5,a5,-1
     d90:	1782                	slli	a5,a5,0x20
     d92:	9381                	srli	a5,a5,0x20
     d94:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     d98:	fff4c583          	lbu	a1,-1(s1)
     d9c:	854a                	mv	a0,s2
     d9e:	f67ff0ef          	jal	ra,d04 <putc>
  while(--i >= 0)
     da2:	14fd                	addi	s1,s1,-1
     da4:	ff349ae3          	bne	s1,s3,d98 <printint+0x76>
}
     da8:	60a6                	ld	ra,72(sp)
     daa:	6406                	ld	s0,64(sp)
     dac:	74e2                	ld	s1,56(sp)
     dae:	7942                	ld	s2,48(sp)
     db0:	79a2                	ld	s3,40(sp)
     db2:	6161                	addi	sp,sp,80
     db4:	8082                	ret
    x = -xx;
     db6:	40b005b3          	neg	a1,a1
    neg = 1;
     dba:	4885                	li	a7,1
    x = -xx;
     dbc:	bfbd                	j	d3a <printint+0x18>

0000000000000dbe <vprintf>:
 *   无
 */

void
vprintf(int fd, const char *fmt, va_list ap)
{
     dbe:	7119                	addi	sp,sp,-128
     dc0:	fc86                	sd	ra,120(sp)
     dc2:	f8a2                	sd	s0,112(sp)
     dc4:	f4a6                	sd	s1,104(sp)
     dc6:	f0ca                	sd	s2,96(sp)
     dc8:	ecce                	sd	s3,88(sp)
     dca:	e8d2                	sd	s4,80(sp)
     dcc:	e4d6                	sd	s5,72(sp)
     dce:	e0da                	sd	s6,64(sp)
     dd0:	fc5e                	sd	s7,56(sp)
     dd2:	f862                	sd	s8,48(sp)
     dd4:	f466                	sd	s9,40(sp)
     dd6:	f06a                	sd	s10,32(sp)
     dd8:	ec6e                	sd	s11,24(sp)
     dda:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     ddc:	0005c903          	lbu	s2,0(a1)
     de0:	24090c63          	beqz	s2,1038 <vprintf+0x27a>
     de4:	8b2a                	mv	s6,a0
     de6:	8a2e                	mv	s4,a1
     de8:	8bb2                	mv	s7,a2
  state = 0;
     dea:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     dec:	4481                	li	s1,0
     dee:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     df0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     df4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     df8:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     dfc:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     e00:	00000c97          	auipc	s9,0x0
     e04:	568c8c93          	addi	s9,s9,1384 # 1368 <digits>
     e08:	a005                	j	e28 <vprintf+0x6a>
        putc(fd, c0);
     e0a:	85ca                	mv	a1,s2
     e0c:	855a                	mv	a0,s6
     e0e:	ef7ff0ef          	jal	ra,d04 <putc>
     e12:	a019                	j	e18 <vprintf+0x5a>
    } else if(state == '%'){
     e14:	03598263          	beq	s3,s5,e38 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     e18:	2485                	addiw	s1,s1,1
     e1a:	8726                	mv	a4,s1
     e1c:	009a07b3          	add	a5,s4,s1
     e20:	0007c903          	lbu	s2,0(a5)
     e24:	20090a63          	beqz	s2,1038 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
     e28:	0009079b          	sext.w	a5,s2
    if(state == 0){
     e2c:	fe0994e3          	bnez	s3,e14 <vprintf+0x56>
      if(c0 == '%'){
     e30:	fd579de3          	bne	a5,s5,e0a <vprintf+0x4c>
        state = '%';
     e34:	89be                	mv	s3,a5
     e36:	b7cd                	j	e18 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
     e38:	c3c1                	beqz	a5,eb8 <vprintf+0xfa>
     e3a:	00ea06b3          	add	a3,s4,a4
     e3e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     e42:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     e44:	c681                	beqz	a3,e4c <vprintf+0x8e>
     e46:	9752                	add	a4,a4,s4
     e48:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     e4c:	03878e63          	beq	a5,s8,e88 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
     e50:	05a78863          	beq	a5,s10,ea0 <vprintf+0xe2>
      } else if(c0 == 'u'){
     e54:	0db78b63          	beq	a5,s11,f2a <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     e58:	07800713          	li	a4,120
     e5c:	10e78d63          	beq	a5,a4,f76 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     e60:	07000713          	li	a4,112
     e64:	14e78263          	beq	a5,a4,fa8 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     e68:	06300713          	li	a4,99
     e6c:	16e78f63          	beq	a5,a4,fea <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     e70:	07300713          	li	a4,115
     e74:	18e78563          	beq	a5,a4,ffe <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     e78:	05579063          	bne	a5,s5,eb8 <vprintf+0xfa>
        putc(fd, '%');
     e7c:	85d6                	mv	a1,s5
     e7e:	855a                	mv	a0,s6
     e80:	e85ff0ef          	jal	ra,d04 <putc>
        // 未知的%序列，原样输出以引起注意
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     e84:	4981                	li	s3,0
     e86:	bf49                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
     e88:	008b8913          	addi	s2,s7,8
     e8c:	4685                	li	a3,1
     e8e:	4629                	li	a2,10
     e90:	000ba583          	lw	a1,0(s7)
     e94:	855a                	mv	a0,s6
     e96:	e8dff0ef          	jal	ra,d22 <printint>
     e9a:	8bca                	mv	s7,s2
      state = 0;
     e9c:	4981                	li	s3,0
     e9e:	bfad                	j	e18 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
     ea0:	03868663          	beq	a3,s8,ecc <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     ea4:	05a68163          	beq	a3,s10,ee6 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
     ea8:	09b68d63          	beq	a3,s11,f42 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     eac:	03a68f63          	beq	a3,s10,eea <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
     eb0:	07800793          	li	a5,120
     eb4:	0cf68d63          	beq	a3,a5,f8e <vprintf+0x1d0>
        putc(fd, '%');
     eb8:	85d6                	mv	a1,s5
     eba:	855a                	mv	a0,s6
     ebc:	e49ff0ef          	jal	ra,d04 <putc>
        putc(fd, c0);
     ec0:	85ca                	mv	a1,s2
     ec2:	855a                	mv	a0,s6
     ec4:	e41ff0ef          	jal	ra,d04 <putc>
      state = 0;
     ec8:	4981                	li	s3,0
     eca:	b7b9                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ecc:	008b8913          	addi	s2,s7,8
     ed0:	4685                	li	a3,1
     ed2:	4629                	li	a2,10
     ed4:	000bb583          	ld	a1,0(s7)
     ed8:	855a                	mv	a0,s6
     eda:	e49ff0ef          	jal	ra,d22 <printint>
        i += 1;
     ede:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     ee0:	8bca                	mv	s7,s2
      state = 0;
     ee2:	4981                	li	s3,0
        i += 1;
     ee4:	bf15                	j	e18 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     ee6:	03860563          	beq	a2,s8,f10 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     eea:	07b60963          	beq	a2,s11,f5c <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     eee:	07800793          	li	a5,120
     ef2:	fcf613e3          	bne	a2,a5,eb8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ef6:	008b8913          	addi	s2,s7,8
     efa:	4681                	li	a3,0
     efc:	4641                	li	a2,16
     efe:	000bb583          	ld	a1,0(s7)
     f02:	855a                	mv	a0,s6
     f04:	e1fff0ef          	jal	ra,d22 <printint>
        i += 2;
     f08:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     f0a:	8bca                	mv	s7,s2
      state = 0;
     f0c:	4981                	li	s3,0
        i += 2;
     f0e:	b729                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     f10:	008b8913          	addi	s2,s7,8
     f14:	4685                	li	a3,1
     f16:	4629                	li	a2,10
     f18:	000bb583          	ld	a1,0(s7)
     f1c:	855a                	mv	a0,s6
     f1e:	e05ff0ef          	jal	ra,d22 <printint>
        i += 2;
     f22:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     f24:	8bca                	mv	s7,s2
      state = 0;
     f26:	4981                	li	s3,0
        i += 2;
     f28:	bdc5                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     f2a:	008b8913          	addi	s2,s7,8
     f2e:	4681                	li	a3,0
     f30:	4629                	li	a2,10
     f32:	000be583          	lwu	a1,0(s7)
     f36:	855a                	mv	a0,s6
     f38:	debff0ef          	jal	ra,d22 <printint>
     f3c:	8bca                	mv	s7,s2
      state = 0;
     f3e:	4981                	li	s3,0
     f40:	bde1                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f42:	008b8913          	addi	s2,s7,8
     f46:	4681                	li	a3,0
     f48:	4629                	li	a2,10
     f4a:	000bb583          	ld	a1,0(s7)
     f4e:	855a                	mv	a0,s6
     f50:	dd3ff0ef          	jal	ra,d22 <printint>
        i += 1;
     f54:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     f56:	8bca                	mv	s7,s2
      state = 0;
     f58:	4981                	li	s3,0
        i += 1;
     f5a:	bd7d                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f5c:	008b8913          	addi	s2,s7,8
     f60:	4681                	li	a3,0
     f62:	4629                	li	a2,10
     f64:	000bb583          	ld	a1,0(s7)
     f68:	855a                	mv	a0,s6
     f6a:	db9ff0ef          	jal	ra,d22 <printint>
        i += 2;
     f6e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     f70:	8bca                	mv	s7,s2
      state = 0;
     f72:	4981                	li	s3,0
        i += 2;
     f74:	b555                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     f76:	008b8913          	addi	s2,s7,8
     f7a:	4681                	li	a3,0
     f7c:	4641                	li	a2,16
     f7e:	000be583          	lwu	a1,0(s7)
     f82:	855a                	mv	a0,s6
     f84:	d9fff0ef          	jal	ra,d22 <printint>
     f88:	8bca                	mv	s7,s2
      state = 0;
     f8a:	4981                	li	s3,0
     f8c:	b571                	j	e18 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     f8e:	008b8913          	addi	s2,s7,8
     f92:	4681                	li	a3,0
     f94:	4641                	li	a2,16
     f96:	000bb583          	ld	a1,0(s7)
     f9a:	855a                	mv	a0,s6
     f9c:	d87ff0ef          	jal	ra,d22 <printint>
        i += 1;
     fa0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     fa2:	8bca                	mv	s7,s2
      state = 0;
     fa4:	4981                	li	s3,0
        i += 1;
     fa6:	bd8d                	j	e18 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
     fa8:	008b8793          	addi	a5,s7,8
     fac:	f8f43423          	sd	a5,-120(s0)
     fb0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     fb4:	03000593          	li	a1,48
     fb8:	855a                	mv	a0,s6
     fba:	d4bff0ef          	jal	ra,d04 <putc>
  putc(fd, 'x');
     fbe:	07800593          	li	a1,120
     fc2:	855a                	mv	a0,s6
     fc4:	d41ff0ef          	jal	ra,d04 <putc>
     fc8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     fca:	03c9d793          	srli	a5,s3,0x3c
     fce:	97e6                	add	a5,a5,s9
     fd0:	0007c583          	lbu	a1,0(a5)
     fd4:	855a                	mv	a0,s6
     fd6:	d2fff0ef          	jal	ra,d04 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     fda:	0992                	slli	s3,s3,0x4
     fdc:	397d                	addiw	s2,s2,-1
     fde:	fe0916e3          	bnez	s2,fca <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
     fe2:	f8843b83          	ld	s7,-120(s0)
      state = 0;
     fe6:	4981                	li	s3,0
     fe8:	bd05                	j	e18 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
     fea:	008b8913          	addi	s2,s7,8
     fee:	000bc583          	lbu	a1,0(s7)
     ff2:	855a                	mv	a0,s6
     ff4:	d11ff0ef          	jal	ra,d04 <putc>
     ff8:	8bca                	mv	s7,s2
      state = 0;
     ffa:	4981                	li	s3,0
     ffc:	bd31                	j	e18 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
     ffe:	008b8993          	addi	s3,s7,8
    1002:	000bb903          	ld	s2,0(s7)
    1006:	00090f63          	beqz	s2,1024 <vprintf+0x266>
        for(; *s; s++)
    100a:	00094583          	lbu	a1,0(s2)
    100e:	c195                	beqz	a1,1032 <vprintf+0x274>
          putc(fd, *s);
    1010:	855a                	mv	a0,s6
    1012:	cf3ff0ef          	jal	ra,d04 <putc>
        for(; *s; s++)
    1016:	0905                	addi	s2,s2,1
    1018:	00094583          	lbu	a1,0(s2)
    101c:	f9f5                	bnez	a1,1010 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
    101e:	8bce                	mv	s7,s3
      state = 0;
    1020:	4981                	li	s3,0
    1022:	bbdd                	j	e18 <vprintf+0x5a>
          s = "(null)";
    1024:	00000917          	auipc	s2,0x0
    1028:	33c90913          	addi	s2,s2,828 # 1360 <malloc+0x226>
        for(; *s; s++)
    102c:	02800593          	li	a1,40
    1030:	b7c5                	j	1010 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
    1032:	8bce                	mv	s7,s3
      state = 0;
    1034:	4981                	li	s3,0
    1036:	b3cd                	j	e18 <vprintf+0x5a>
    }
  }
}
    1038:	70e6                	ld	ra,120(sp)
    103a:	7446                	ld	s0,112(sp)
    103c:	74a6                	ld	s1,104(sp)
    103e:	7906                	ld	s2,96(sp)
    1040:	69e6                	ld	s3,88(sp)
    1042:	6a46                	ld	s4,80(sp)
    1044:	6aa6                	ld	s5,72(sp)
    1046:	6b06                	ld	s6,64(sp)
    1048:	7be2                	ld	s7,56(sp)
    104a:	7c42                	ld	s8,48(sp)
    104c:	7ca2                	ld	s9,40(sp)
    104e:	7d02                	ld	s10,32(sp)
    1050:	6de2                	ld	s11,24(sp)
    1052:	6109                	addi	sp,sp,128
    1054:	8082                	ret

0000000000001056 <fprintf>:
 *   无
 */

void
fprintf(int fd, const char *fmt, ...)
{
    1056:	715d                	addi	sp,sp,-80
    1058:	ec06                	sd	ra,24(sp)
    105a:	e822                	sd	s0,16(sp)
    105c:	1000                	addi	s0,sp,32
    105e:	e010                	sd	a2,0(s0)
    1060:	e414                	sd	a3,8(s0)
    1062:	e818                	sd	a4,16(s0)
    1064:	ec1c                	sd	a5,24(s0)
    1066:	03043023          	sd	a6,32(s0)
    106a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    106e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1072:	8622                	mv	a2,s0
    1074:	d4bff0ef          	jal	ra,dbe <vprintf>
}
    1078:	60e2                	ld	ra,24(sp)
    107a:	6442                	ld	s0,16(sp)
    107c:	6161                	addi	sp,sp,80
    107e:	8082                	ret

0000000000001080 <printf>:
 *   无
 */

void
printf(const char *fmt, ...)
{
    1080:	711d                	addi	sp,sp,-96
    1082:	ec06                	sd	ra,24(sp)
    1084:	e822                	sd	s0,16(sp)
    1086:	1000                	addi	s0,sp,32
    1088:	e40c                	sd	a1,8(s0)
    108a:	e810                	sd	a2,16(s0)
    108c:	ec14                	sd	a3,24(s0)
    108e:	f018                	sd	a4,32(s0)
    1090:	f41c                	sd	a5,40(s0)
    1092:	03043823          	sd	a6,48(s0)
    1096:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    109a:	00840613          	addi	a2,s0,8
    109e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    10a2:	85aa                	mv	a1,a0
    10a4:	4505                	li	a0,1
    10a6:	d19ff0ef          	jal	ra,dbe <vprintf>
}
    10aa:	60e2                	ld	ra,24(sp)
    10ac:	6442                	ld	s0,16(sp)
    10ae:	6125                	addi	sp,sp,96
    10b0:	8082                	ret

00000000000010b2 <free>:
 *   无
 */

void
free(void *ap)
{
    10b2:	1141                	addi	sp,sp,-16
    10b4:	e422                	sd	s0,8(sp)
    10b6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;  /* 获取内存块头部 */
    10b8:	ff050693          	addi	a3,a0,-16
  /* 查找合适的位置插入空闲块 */
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10bc:	00001797          	auipc	a5,0x1
    10c0:	f547b783          	ld	a5,-172(a5) # 2010 <freep>
    10c4:	a805                	j	10f4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  /* 检查是否可以与下一个块合并 */
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    10c6:	4618                	lw	a4,8(a2)
    10c8:	9db9                	addw	a1,a1,a4
    10ca:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    10ce:	6398                	ld	a4,0(a5)
    10d0:	6318                	ld	a4,0(a4)
    10d2:	fee53823          	sd	a4,-16(a0)
    10d6:	a091                	j	111a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  /* 检查是否可以与前一个块合并 */
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    10d8:	ff852703          	lw	a4,-8(a0)
    10dc:	9e39                	addw	a2,a2,a4
    10de:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    10e0:	ff053703          	ld	a4,-16(a0)
    10e4:	e398                	sd	a4,0(a5)
    10e6:	a099                	j	112c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10e8:	6398                	ld	a4,0(a5)
    10ea:	00e7e463          	bltu	a5,a4,10f2 <free+0x40>
    10ee:	00e6ea63          	bltu	a3,a4,1102 <free+0x50>
{
    10f2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10f4:	fed7fae3          	bgeu	a5,a3,10e8 <free+0x36>
    10f8:	6398                	ld	a4,0(a5)
    10fa:	00e6e463          	bltu	a3,a4,1102 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10fe:	fee7eae3          	bltu	a5,a4,10f2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1102:	ff852583          	lw	a1,-8(a0)
    1106:	6390                	ld	a2,0(a5)
    1108:	02059713          	slli	a4,a1,0x20
    110c:	9301                	srli	a4,a4,0x20
    110e:	0712                	slli	a4,a4,0x4
    1110:	9736                	add	a4,a4,a3
    1112:	fae60ae3          	beq	a2,a4,10c6 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1116:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    111a:	4790                	lw	a2,8(a5)
    111c:	02061713          	slli	a4,a2,0x20
    1120:	9301                	srli	a4,a4,0x20
    1122:	0712                	slli	a4,a4,0x4
    1124:	973e                	add	a4,a4,a5
    1126:	fae689e3          	beq	a3,a4,10d8 <free+0x26>
  } else
    p->s.ptr = bp;
    112a:	e394                	sd	a3,0(a5)
  /* 更新空闲链表头指针 */
  freep = p;
    112c:	00001717          	auipc	a4,0x1
    1130:	eef73223          	sd	a5,-284(a4) # 2010 <freep>
}
    1134:	6422                	ld	s0,8(sp)
    1136:	0141                	addi	sp,sp,16
    1138:	8082                	ret

000000000000113a <malloc>:
 *   指向分配的内存块的指针，失败则返回0
 */

void*
malloc(uint nbytes)
{
    113a:	7139                	addi	sp,sp,-64
    113c:	fc06                	sd	ra,56(sp)
    113e:	f822                	sd	s0,48(sp)
    1140:	f426                	sd	s1,40(sp)
    1142:	f04a                	sd	s2,32(sp)
    1144:	ec4e                	sd	s3,24(sp)
    1146:	e852                	sd	s4,16(sp)
    1148:	e456                	sd	s5,8(sp)
    114a:	e05a                	sd	s6,0(sp)
    114c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  /* 计算需要的头部数量 */
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    114e:	02051493          	slli	s1,a0,0x20
    1152:	9081                	srli	s1,s1,0x20
    1154:	04bd                	addi	s1,s1,15
    1156:	8091                	srli	s1,s1,0x4
    1158:	0014899b          	addiw	s3,s1,1
    115c:	0485                	addi	s1,s1,1
  /* 如果空闲链表为空，初始化链表 */
  if((prevp = freep) == 0){
    115e:	00001517          	auipc	a0,0x1
    1162:	eb253503          	ld	a0,-334(a0) # 2010 <freep>
    1166:	c515                	beqz	a0,1192 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  /* 遍历空闲链表寻找合适的块 */
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1168:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
    116a:	4798                	lw	a4,8(a5)
    116c:	02977f63          	bgeu	a4,s1,11aa <malloc+0x70>
    1170:	8a4e                	mv	s4,s3
    1172:	0009871b          	sext.w	a4,s3
    1176:	6685                	lui	a3,0x1
    1178:	00d77363          	bgeu	a4,a3,117e <malloc+0x44>
    117c:	6a05                	lui	s4,0x1
    117e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
    1182:	004a1a1b          	slliw	s4,s4,0x4
      }
      freep = prevp;  /* 更新空闲链表头指针 */
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    }
    /* 如果遍历完整个链表都没有找到合适的块，请求更多内存 */
    if(p == freep)
    1186:	00001917          	auipc	s2,0x1
    118a:	e8a90913          	addi	s2,s2,-374 # 2010 <freep>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
    118e:	5afd                	li	s5,-1
    1190:	a0bd                	j	11fe <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
    1192:	00001797          	auipc	a5,0x1
    1196:	ef678793          	addi	a5,a5,-266 # 2088 <base>
    119a:	00001717          	auipc	a4,0x1
    119e:	e6f73b23          	sd	a5,-394(a4) # 2010 <freep>
    11a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    11a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
    11a8:	b7e1                	j	1170 <malloc+0x36>
      if(p->s.size == nunits)  /* 块大小正好匹配 */
    11aa:	02e48b63          	beq	s1,a4,11e0 <malloc+0xa6>
        p->s.size -= nunits;
    11ae:	4137073b          	subw	a4,a4,s3
    11b2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    11b4:	1702                	slli	a4,a4,0x20
    11b6:	9301                	srli	a4,a4,0x20
    11b8:	0712                	slli	a4,a4,0x4
    11ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    11bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;  /* 更新空闲链表头指针 */
    11c0:	00001717          	auipc	a4,0x1
    11c4:	e4a73823          	sd	a0,-432(a4) # 2010 <freep>
      return (void*)(p + 1);  /* 返回实际数据区域的指针 */
    11c8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;  /* 内存分配失败 */
  }
}
    11cc:	70e2                	ld	ra,56(sp)
    11ce:	7442                	ld	s0,48(sp)
    11d0:	74a2                	ld	s1,40(sp)
    11d2:	7902                	ld	s2,32(sp)
    11d4:	69e2                	ld	s3,24(sp)
    11d6:	6a42                	ld	s4,16(sp)
    11d8:	6aa2                	ld	s5,8(sp)
    11da:	6b02                	ld	s6,0(sp)
    11dc:	6121                	addi	sp,sp,64
    11de:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    11e0:	6398                	ld	a4,0(a5)
    11e2:	e118                	sd	a4,0(a0)
    11e4:	bff1                	j	11c0 <malloc+0x86>
  hp->s.size = nu;
    11e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));  /* 将新分配的内存加入空闲链表 */
    11ea:	0541                	addi	a0,a0,16
    11ec:	ec7ff0ef          	jal	ra,10b2 <free>
  return freep;
    11f0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    11f4:	dd61                	beqz	a0,11cc <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    11f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){  /* 找到足够大的块 */
    11f8:	4798                	lw	a4,8(a5)
    11fa:	fa9778e3          	bgeu	a4,s1,11aa <malloc+0x70>
    if(p == freep)
    11fe:	00093703          	ld	a4,0(s2)
    1202:	853e                	mv	a0,a5
    1204:	fef719e3          	bne	a4,a5,11f6 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));  /* 调用sbrk扩展堆 */
    1208:	8552                	mv	a0,s4
    120a:	9e7ff0ef          	jal	ra,bf0 <sbrk>
  if(p == SBRK_ERROR)  /* 检查是否分配失败 */
    120e:	fd551ce3          	bne	a0,s5,11e6 <malloc+0xac>
        return 0;  /* 内存分配失败 */
    1212:	4501                	li	a0,0
    1214:	bf65                	j	11cc <malloc+0x92>
