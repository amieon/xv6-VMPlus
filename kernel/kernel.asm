
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	86813103          	ld	sp,-1944(sp) # 80008868 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdaaa97>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	e9678793          	addi	a5,a5,-362 # 80000f16 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7159                	addi	sp,sp,-112
    800000d2:	f486                	sd	ra,104(sp)
    800000d4:	f0a2                	sd	s0,96(sp)
    800000d6:	eca6                	sd	s1,88(sp)
    800000d8:	e8ca                	sd	s2,80(sp)
    800000da:	e4ce                	sd	s3,72(sp)
    800000dc:	e0d2                	sd	s4,64(sp)
    800000de:	fc56                	sd	s5,56(sp)
    800000e0:	f85a                	sd	s6,48(sp)
    800000e2:	f45e                	sd	s7,40(sp)
    800000e4:	f062                	sd	s8,32(sp)
    800000e6:	1880                	addi	s0,sp,112
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000e8:	04c05463          	blez	a2,80000130 <consolewrite+0x60>
    800000ec:	8a2a                	mv	s4,a0
    800000ee:	8aae                	mv	s5,a1
    800000f0:	89b2                	mv	s3,a2
  int i = 0;
    800000f2:	4901                	li	s2,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f4:	4bfd                	li	s7,31
    int nn = sizeof(buf);
    800000f6:	02000c13          	li	s8,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fa:	5b7d                	li	s6,-1
    800000fc:	a025                	j	80000124 <consolewrite+0x54>
    800000fe:	86a6                	mv	a3,s1
    80000100:	01590633          	add	a2,s2,s5
    80000104:	85d2                	mv	a1,s4
    80000106:	f9040513          	addi	a0,s0,-112
    8000010a:	5e2020ef          	jal	ra,800026ec <either_copyin>
    8000010e:	03650263          	beq	a0,s6,80000132 <consolewrite+0x62>
      break;
    uartwrite(buf, nn);
    80000112:	85a6                	mv	a1,s1
    80000114:	f9040513          	addi	a0,s0,-112
    80000118:	71c000ef          	jal	ra,80000834 <uartwrite>
    i += nn;
    8000011c:	0124893b          	addw	s2,s1,s2
  while(i < n){
    80000120:	01395963          	bge	s2,s3,80000132 <consolewrite+0x62>
    if(nn > n - i)
    80000124:	412984bb          	subw	s1,s3,s2
    80000128:	fc9bdbe3          	bge	s7,s1,800000fe <consolewrite+0x2e>
    int nn = sizeof(buf);
    8000012c:	84e2                	mv	s1,s8
    8000012e:	bfc1                	j	800000fe <consolewrite+0x2e>
  int i = 0;
    80000130:	4901                	li	s2,0
  }

  return i;
}
    80000132:	854a                	mv	a0,s2
    80000134:	70a6                	ld	ra,104(sp)
    80000136:	7406                	ld	s0,96(sp)
    80000138:	64e6                	ld	s1,88(sp)
    8000013a:	6946                	ld	s2,80(sp)
    8000013c:	69a6                	ld	s3,72(sp)
    8000013e:	6a06                	ld	s4,64(sp)
    80000140:	7ae2                	ld	s5,56(sp)
    80000142:	7b42                	ld	s6,48(sp)
    80000144:	7ba2                	ld	s7,40(sp)
    80000146:	7c02                	ld	s8,32(sp)
    80000148:	6165                	addi	sp,sp,112
    8000014a:	8082                	ret

000000008000014c <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014c:	7159                	addi	sp,sp,-112
    8000014e:	f486                	sd	ra,104(sp)
    80000150:	f0a2                	sd	s0,96(sp)
    80000152:	eca6                	sd	s1,88(sp)
    80000154:	e8ca                	sd	s2,80(sp)
    80000156:	e4ce                	sd	s3,72(sp)
    80000158:	e0d2                	sd	s4,64(sp)
    8000015a:	fc56                	sd	s5,56(sp)
    8000015c:	f85a                	sd	s6,48(sp)
    8000015e:	f45e                	sd	s7,40(sp)
    80000160:	f062                	sd	s8,32(sp)
    80000162:	ec66                	sd	s9,24(sp)
    80000164:	e86a                	sd	s10,16(sp)
    80000166:	1880                	addi	s0,sp,112
    80000168:	8aaa                	mv	s5,a0
    8000016a:	8a2e                	mv	s4,a1
    8000016c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000016e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000172:	00010517          	auipc	a0,0x10
    80000176:	73e50513          	addi	a0,a0,1854 # 800108b0 <cons>
    8000017a:	327000ef          	jal	ra,80000ca0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	73248493          	addi	s1,s1,1842 # 800108b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	7c290913          	addi	s2,s2,1986 # 80010948 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000018e:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000190:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000192:	4ca9                	li	s9,10
  while(n > 0){
    80000194:	07305363          	blez	s3,800001fa <consoleread+0xae>
    while(cons.r == cons.w){
    80000198:	0984a783          	lw	a5,152(s1)
    8000019c:	09c4a703          	lw	a4,156(s1)
    800001a0:	02f71163          	bne	a4,a5,800001c2 <consoleread+0x76>
      if(killed(myproc())){
    800001a4:	1a5010ef          	jal	ra,80001b48 <myproc>
    800001a8:	3d6020ef          	jal	ra,8000257e <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	194020ef          	jal	ra,80002346 <sleep>
    while(cons.r == cons.w){
    800001b6:	0984a783          	lw	a5,152(s1)
    800001ba:	09c4a703          	lw	a4,156(s1)
    800001be:	fef703e3          	beq	a4,a5,800001a4 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001c2:	0017871b          	addiw	a4,a5,1
    800001c6:	08e4ac23          	sw	a4,152(s1)
    800001ca:	07f7f713          	andi	a4,a5,127
    800001ce:	9726                	add	a4,a4,s1
    800001d0:	01874703          	lbu	a4,24(a4)
    800001d4:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001d8:	057d0f63          	beq	s10,s7,80000236 <consoleread+0xea>
    cbuf = c;
    800001dc:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001e0:	4685                	li	a3,1
    800001e2:	f9f40613          	addi	a2,s0,-97
    800001e6:	85d2                	mv	a1,s4
    800001e8:	8556                	mv	a0,s5
    800001ea:	4b8020ef          	jal	ra,800026a2 <either_copyout>
    800001ee:	01850663          	beq	a0,s8,800001fa <consoleread+0xae>
    dst++;
    800001f2:	0a05                	addi	s4,s4,1
    --n;
    800001f4:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001f6:	f99d1fe3          	bne	s10,s9,80000194 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001fa:	00010517          	auipc	a0,0x10
    800001fe:	6b650513          	addi	a0,a0,1718 # 800108b0 <cons>
    80000202:	337000ef          	jal	ra,80000d38 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	6a450513          	addi	a0,a0,1700 # 800108b0 <cons>
    80000214:	325000ef          	jal	ra,80000d38 <release>
        return -1;
    80000218:	557d                	li	a0,-1
}
    8000021a:	70a6                	ld	ra,104(sp)
    8000021c:	7406                	ld	s0,96(sp)
    8000021e:	64e6                	ld	s1,88(sp)
    80000220:	6946                	ld	s2,80(sp)
    80000222:	69a6                	ld	s3,72(sp)
    80000224:	6a06                	ld	s4,64(sp)
    80000226:	7ae2                	ld	s5,56(sp)
    80000228:	7b42                	ld	s6,48(sp)
    8000022a:	7ba2                	ld	s7,40(sp)
    8000022c:	7c02                	ld	s8,32(sp)
    8000022e:	6ce2                	ld	s9,24(sp)
    80000230:	6d42                	ld	s10,16(sp)
    80000232:	6165                	addi	sp,sp,112
    80000234:	8082                	ret
      if(n < target){
    80000236:	0009871b          	sext.w	a4,s3
    8000023a:	fd6770e3          	bgeu	a4,s6,800001fa <consoleread+0xae>
        cons.r--;
    8000023e:	00010717          	auipc	a4,0x10
    80000242:	70f72523          	sw	a5,1802(a4) # 80010948 <cons+0x98>
    80000246:	bf55                	j	800001fa <consoleread+0xae>

0000000080000248 <consputc>:
{
    80000248:	1141                	addi	sp,sp,-16
    8000024a:	e406                	sd	ra,8(sp)
    8000024c:	e022                	sd	s0,0(sp)
    8000024e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000250:	10000793          	li	a5,256
    80000254:	00f50863          	beq	a0,a5,80000264 <consputc+0x1c>
    uartputc_sync(c);
    80000258:	67c000ef          	jal	ra,800008d4 <uartputc_sync>
}
    8000025c:	60a2                	ld	ra,8(sp)
    8000025e:	6402                	ld	s0,0(sp)
    80000260:	0141                	addi	sp,sp,16
    80000262:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000264:	4521                	li	a0,8
    80000266:	66e000ef          	jal	ra,800008d4 <uartputc_sync>
    8000026a:	02000513          	li	a0,32
    8000026e:	666000ef          	jal	ra,800008d4 <uartputc_sync>
    80000272:	4521                	li	a0,8
    80000274:	660000ef          	jal	ra,800008d4 <uartputc_sync>
    80000278:	b7d5                	j	8000025c <consputc+0x14>

000000008000027a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000027a:	1101                	addi	sp,sp,-32
    8000027c:	ec06                	sd	ra,24(sp)
    8000027e:	e822                	sd	s0,16(sp)
    80000280:	e426                	sd	s1,8(sp)
    80000282:	e04a                	sd	s2,0(sp)
    80000284:	1000                	addi	s0,sp,32
    80000286:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80000288:	00010517          	auipc	a0,0x10
    8000028c:	62850513          	addi	a0,a0,1576 # 800108b0 <cons>
    80000290:	211000ef          	jal	ra,80000ca0 <acquire>

  switch(c){
    80000294:	47d5                	li	a5,21
    80000296:	0af48063          	beq	s1,a5,80000336 <consoleintr+0xbc>
    8000029a:	0297c663          	blt	a5,s1,800002c6 <consoleintr+0x4c>
    8000029e:	47a1                	li	a5,8
    800002a0:	0cf48f63          	beq	s1,a5,8000037e <consoleintr+0x104>
    800002a4:	47c1                	li	a5,16
    800002a6:	10f49063          	bne	s1,a5,800003a6 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800002aa:	48c020ef          	jal	ra,80002736 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	60250513          	addi	a0,a0,1538 # 800108b0 <cons>
    800002b6:	283000ef          	jal	ra,80000d38 <release>
}
    800002ba:	60e2                	ld	ra,24(sp)
    800002bc:	6442                	ld	s0,16(sp)
    800002be:	64a2                	ld	s1,8(sp)
    800002c0:	6902                	ld	s2,0(sp)
    800002c2:	6105                	addi	sp,sp,32
    800002c4:	8082                	ret
  switch(c){
    800002c6:	07f00793          	li	a5,127
    800002ca:	0af48a63          	beq	s1,a5,8000037e <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002ce:	00010717          	auipc	a4,0x10
    800002d2:	5e270713          	addi	a4,a4,1506 # 800108b0 <cons>
    800002d6:	0a072783          	lw	a5,160(a4)
    800002da:	09872703          	lw	a4,152(a4)
    800002de:	9f99                	subw	a5,a5,a4
    800002e0:	07f00713          	li	a4,127
    800002e4:	fcf765e3          	bltu	a4,a5,800002ae <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002e8:	47b5                	li	a5,13
    800002ea:	0cf48163          	beq	s1,a5,800003ac <consoleintr+0x132>
      consputc(c);
    800002ee:	8526                	mv	a0,s1
    800002f0:	f59ff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f4:	00010797          	auipc	a5,0x10
    800002f8:	5bc78793          	addi	a5,a5,1468 # 800108b0 <cons>
    800002fc:	0a07a683          	lw	a3,160(a5)
    80000300:	0016871b          	addiw	a4,a3,1
    80000304:	0007061b          	sext.w	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0af48f63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    8000031c:	4791                	li	a5,4
    8000031e:	0af48c63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    80000322:	00010797          	auipc	a5,0x10
    80000326:	6267a783          	lw	a5,1574(a5) # 80010948 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	57a70713          	addi	a4,a4,1402 # 800108b0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	56a48493          	addi	s1,s1,1386 # 800108b0 <cons>
    while(cons.e != cons.w &&
    8000034e:	4929                	li	s2,10
    80000350:	f4f70fe3          	beq	a4,a5,800002ae <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000354:	37fd                	addiw	a5,a5,-1
    80000356:	07f7f713          	andi	a4,a5,127
    8000035a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000035c:	01874703          	lbu	a4,24(a4)
    80000360:	f52707e3          	beq	a4,s2,800002ae <consoleintr+0x34>
      cons.e--;
    80000364:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000368:	10000513          	li	a0,256
    8000036c:	eddff0ef          	jal	ra,80000248 <consputc>
    while(cons.e != cons.w &&
    80000370:	0a04a783          	lw	a5,160(s1)
    80000374:	09c4a703          	lw	a4,156(s1)
    80000378:	fcf71ee3          	bne	a4,a5,80000354 <consoleintr+0xda>
    8000037c:	bf0d                	j	800002ae <consoleintr+0x34>
    if(cons.e != cons.w){
    8000037e:	00010717          	auipc	a4,0x10
    80000382:	53270713          	addi	a4,a4,1330 # 800108b0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	5af72e23          	sw	a5,1468(a4) # 80010950 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea9ff0ef          	jal	ra,80000248 <consputc>
    800003a4:	b729                	j	800002ae <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	f00484e3          	beqz	s1,800002ae <consoleintr+0x34>
    800003aa:	b715                	j	800002ce <consoleintr+0x54>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e9bff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00010797          	auipc	a5,0x10
    800003b6:	4fe78793          	addi	a5,a5,1278 # 800108b0 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00010797          	auipc	a5,0x10
    800003da:	56c7ab23          	sw	a2,1398(a5) # 8001094c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	56a50513          	addi	a0,a0,1386 # 80010948 <cons+0x98>
    800003e6:	7ad010ef          	jal	ra,80002392 <wakeup>
    800003ea:	b5d1                	j	800002ae <consoleintr+0x34>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00008597          	auipc	a1,0x8
    800003f8:	c1c58593          	addi	a1,a1,-996 # 80008010 <etext+0x10>
    800003fc:	00010517          	auipc	a0,0x10
    80000400:	4b450513          	addi	a0,a0,1204 # 800108b0 <cons>
    80000404:	01d000ef          	jal	ra,80000c20 <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0024a797          	auipc	a5,0x24a
    80000410:	62c78793          	addi	a5,a5,1580 # 8024aa38 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d3870713          	addi	a4,a4,-712 # 8000014c <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7139                	addi	sp,sp,-64
    80000432:	fc06                	sd	ra,56(sp)
    80000434:	f822                	sd	s0,48(sp)
    80000436:	f426                	sd	s1,40(sp)
    80000438:	f04a                	sd	s2,32(sp)
    8000043a:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000043c:	c219                	beqz	a2,80000442 <printint+0x12>
    8000043e:	06054e63          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000442:	4881                	li	a7,0
    80000444:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000448:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000044a:	00008617          	auipc	a2,0x8
    8000044e:	bee60613          	addi	a2,a2,-1042 # 80008038 <digits>
    80000452:	883e                	mv	a6,a5
    80000454:	2785                	addiw	a5,a5,1
    80000456:	02b57733          	remu	a4,a0,a1
    8000045a:	9732                	add	a4,a4,a2
    8000045c:	00074703          	lbu	a4,0(a4)
    80000460:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000464:	872a                	mv	a4,a0
    80000466:	02b55533          	divu	a0,a0,a1
    8000046a:	0685                	addi	a3,a3,1
    8000046c:	feb773e3          	bgeu	a4,a1,80000452 <printint+0x22>

  if(sign)
    80000470:	00088a63          	beqz	a7,80000484 <printint+0x54>
    buf[i++] = '-';
    80000474:	1781                	addi	a5,a5,-32
    80000476:	97a2                	add	a5,a5,s0
    80000478:	02d00713          	li	a4,45
    8000047c:	fee78423          	sb	a4,-24(a5)
    80000480:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000484:	02f05563          	blez	a5,800004ae <printint+0x7e>
    80000488:	fc840713          	addi	a4,s0,-56
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	da5ff0ef          	jal	ra,80000248 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
}
    800004ae:	70e2                	ld	ra,56(sp)
    800004b0:	7442                	ld	s0,48(sp)
    800004b2:	74a2                	ld	s1,40(sp)
    800004b4:	7902                	ld	s2,32(sp)
    800004b6:	6121                	addi	sp,sp,64
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b751                	j	80000444 <printint+0x14>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7131                	addi	sp,sp,-192
    800004c4:	fc86                	sd	ra,120(sp)
    800004c6:	f8a2                	sd	s0,112(sp)
    800004c8:	f4a6                	sd	s1,104(sp)
    800004ca:	f0ca                	sd	s2,96(sp)
    800004cc:	ecce                	sd	s3,88(sp)
    800004ce:	e8d2                	sd	s4,80(sp)
    800004d0:	e4d6                	sd	s5,72(sp)
    800004d2:	e0da                	sd	s6,64(sp)
    800004d4:	fc5e                	sd	s7,56(sp)
    800004d6:	f862                	sd	s8,48(sp)
    800004d8:	f466                	sd	s9,40(sp)
    800004da:	f06a                	sd	s10,32(sp)
    800004dc:	ec6e                	sd	s11,24(sp)
    800004de:	0100                	addi	s0,sp,128
    800004e0:	8a2a                	mv	s4,a0
    800004e2:	e40c                	sd	a1,8(s0)
    800004e4:	e810                	sd	a2,16(s0)
    800004e6:	ec14                	sd	a3,24(s0)
    800004e8:	f018                	sd	a4,32(s0)
    800004ea:	f41c                	sd	a5,40(s0)
    800004ec:	03043823          	sd	a6,48(s0)
    800004f0:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800004f4:	00008797          	auipc	a5,0x8
    800004f8:	3907a783          	lw	a5,912(a5) # 80008884 <panicking>
    800004fc:	cb9d                	beqz	a5,80000532 <printf+0x70>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004fe:	00840793          	addi	a5,s0,8
    80000502:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000506:	000a4503          	lbu	a0,0(s4)
    8000050a:	24050363          	beqz	a0,80000750 <printf+0x28e>
    8000050e:	4981                	li	s3,0
    if(cx != '%'){
    80000510:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000514:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000518:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000520:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000524:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000528:	00008b97          	auipc	s7,0x8
    8000052c:	b10b8b93          	addi	s7,s7,-1264 # 80008038 <digits>
    80000530:	a01d                	j	80000556 <printf+0x94>
    acquire(&pr.lock);
    80000532:	00010517          	auipc	a0,0x10
    80000536:	42650513          	addi	a0,a0,1062 # 80010958 <pr>
    8000053a:	766000ef          	jal	ra,80000ca0 <acquire>
    8000053e:	b7c1                	j	800004fe <printf+0x3c>
      consputc(cx);
    80000540:	d09ff0ef          	jal	ra,80000248 <consputc>
      continue;
    80000544:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000546:	0014899b          	addiw	s3,s1,1
    8000054a:	013a07b3          	add	a5,s4,s3
    8000054e:	0007c503          	lbu	a0,0(a5)
    80000552:	1e050f63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    80000556:	ff5515e3          	bne	a0,s5,80000540 <printf+0x7e>
    i++;
    8000055a:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000055e:	009a07b3          	add	a5,s4,s1
    80000562:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000566:	1e090563          	beqz	s2,80000750 <printf+0x28e>
    8000056a:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000056e:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000570:	c789                	beqz	a5,8000057a <printf+0xb8>
    80000572:	009a0733          	add	a4,s4,s1
    80000576:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000057a:	03690863          	beq	s2,s6,800005aa <printf+0xe8>
    } else if(c0 == 'l' && c1 == 'd'){
    8000057e:	05890263          	beq	s2,s8,800005c2 <printf+0x100>
    } else if(c0 == 'u'){
    80000582:	0d990163          	beq	s2,s9,80000644 <printf+0x182>
    } else if(c0 == 'x'){
    80000586:	11a90863          	beq	s2,s10,80000696 <printf+0x1d4>
    } else if(c0 == 'p'){
    8000058a:	15b90163          	beq	s2,s11,800006cc <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    8000058e:	06300793          	li	a5,99
    80000592:	16f90963          	beq	s2,a5,80000704 <printf+0x242>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90f63          	beq	s2,a5,80000718 <printf+0x256>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	03591c63          	bne	s2,s5,800005d6 <printf+0x114>
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	ca5ff0ef          	jal	ra,80000248 <consputc>
    800005a8:	bf79                	j	80000546 <printf+0x84>
      printint(va_arg(ap, int), 10, 1);
    800005aa:	f8843783          	ld	a5,-120(s0)
    800005ae:	00878713          	addi	a4,a5,8
    800005b2:	f8e43423          	sd	a4,-120(s0)
    800005b6:	4605                	li	a2,1
    800005b8:	45a9                	li	a1,10
    800005ba:	4388                	lw	a0,0(a5)
    800005bc:	e75ff0ef          	jal	ra,80000430 <printint>
    800005c0:	b759                	j	80000546 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c2:	03678163          	beq	a5,s6,800005e4 <printf+0x122>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005c6:	03878d63          	beq	a5,s8,80000600 <printf+0x13e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005ca:	09978a63          	beq	a5,s9,8000065e <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005ce:	03878b63          	beq	a5,s8,80000604 <printf+0x142>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d2:	0da78f63          	beq	a5,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005d6:	8556                	mv	a0,s5
    800005d8:	c71ff0ef          	jal	ra,80000248 <consputc>
      consputc(c0);
    800005dc:	854a                	mv	a0,s2
    800005de:	c6bff0ef          	jal	ra,80000248 <consputc>
    800005e2:	b795                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    800005e4:	f8843783          	ld	a5,-120(s0)
    800005e8:	00878713          	addi	a4,a5,8
    800005ec:	f8e43423          	sd	a4,-120(s0)
    800005f0:	4605                	li	a2,1
    800005f2:	45a9                	li	a1,10
    800005f4:	6388                	ld	a0,0(a5)
    800005f6:	e3bff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800005fa:	0029849b          	addiw	s1,s3,2
    800005fe:	b7a1                	j	80000546 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000600:	03668463          	beq	a3,s6,80000628 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000604:	07968b63          	beq	a3,s9,8000067a <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000608:	fda697e3          	bne	a3,s10,800005d6 <printf+0x114>
      printint(va_arg(ap, uint64), 16, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	45c1                	li	a1,16
    8000061c:	6388                	ld	a0,0(a5)
    8000061e:	e13ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000622:	0039849b          	addiw	s1,s3,3
    80000626:	b705                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4605                	li	a2,1
    80000636:	45a9                	li	a1,10
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b711                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint32), 10, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45a9                	li	a1,10
    80000654:	0007e503          	lwu	a0,0(a5)
    80000658:	dd9ff0ef          	jal	ra,80000430 <printint>
    8000065c:	b5ed                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45a9                	li	a1,10
    8000066e:	6388                	ld	a0,0(a5)
    80000670:	dc1ff0ef          	jal	ra,80000430 <printint>
      i += 1;
    80000674:	0029849b          	addiw	s1,s3,2
    80000678:	b5f9                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4601                	li	a2,0
    80000688:	45a9                	li	a1,10
    8000068a:	6388                	ld	a0,0(a5)
    8000068c:	da5ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000690:	0039849b          	addiw	s1,s3,3
    80000694:	bd4d                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint32), 16, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45c1                	li	a1,16
    800006a6:	0007e503          	lwu	a0,0(a5)
    800006aa:	d87ff0ef          	jal	ra,80000430 <printint>
    800006ae:	bd61                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	6388                	ld	a0,0(a5)
    800006c2:	d6fff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800006c6:	0029849b          	addiw	s1,s3,2
    800006ca:	bdb5                	j	80000546 <printf+0x84>
      printptr(va_arg(ap, uint64));
    800006cc:	f8843783          	ld	a5,-120(s0)
    800006d0:	00878713          	addi	a4,a5,8
    800006d4:	f8e43423          	sd	a4,-120(s0)
    800006d8:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006dc:	03000513          	li	a0,48
    800006e0:	b69ff0ef          	jal	ra,80000248 <consputc>
  consputc('x');
    800006e4:	856a                	mv	a0,s10
    800006e6:	b63ff0ef          	jal	ra,80000248 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	03c9d793          	srli	a5,s3,0x3c
    800006f0:	97de                	add	a5,a5,s7
    800006f2:	0007c503          	lbu	a0,0(a5)
    800006f6:	b53ff0ef          	jal	ra,80000248 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006fa:	0992                	slli	s3,s3,0x4
    800006fc:	397d                	addiw	s2,s2,-1
    800006fe:	fe0917e3          	bnez	s2,800006ec <printf+0x22a>
    80000702:	b591                	j	80000546 <printf+0x84>
      consputc(va_arg(ap, uint));
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	4388                	lw	a0,0(a5)
    80000712:	b37ff0ef          	jal	ra,80000248 <consputc>
    80000716:	bd05                	j	80000546 <printf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007b903          	ld	s2,0(a5)
    80000728:	00090d63          	beqz	s2,80000742 <printf+0x280>
      for(; *s; s++)
    8000072c:	00094503          	lbu	a0,0(s2)
    80000730:	e0050be3          	beqz	a0,80000546 <printf+0x84>
        consputc(*s);
    80000734:	b15ff0ef          	jal	ra,80000248 <consputc>
      for(; *s; s++)
    80000738:	0905                	addi	s2,s2,1
    8000073a:	00094503          	lbu	a0,0(s2)
    8000073e:	f97d                	bnez	a0,80000734 <printf+0x272>
    80000740:	b519                	j	80000546 <printf+0x84>
        s = "(null)";
    80000742:	00008917          	auipc	s2,0x8
    80000746:	8d690913          	addi	s2,s2,-1834 # 80008018 <etext+0x18>
      for(; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000750:	00008797          	auipc	a5,0x8
    80000754:	1347a783          	lw	a5,308(a5) # 80008884 <panicking>
    80000758:	c38d                	beqz	a5,8000077a <printf+0x2b8>
    release(&pr.lock);

  return 0;
}
    8000075a:	4501                	li	a0,0
    8000075c:	70e6                	ld	ra,120(sp)
    8000075e:	7446                	ld	s0,112(sp)
    80000760:	74a6                	ld	s1,104(sp)
    80000762:	7906                	ld	s2,96(sp)
    80000764:	69e6                	ld	s3,88(sp)
    80000766:	6a46                	ld	s4,80(sp)
    80000768:	6aa6                	ld	s5,72(sp)
    8000076a:	6b06                	ld	s6,64(sp)
    8000076c:	7be2                	ld	s7,56(sp)
    8000076e:	7c42                	ld	s8,48(sp)
    80000770:	7ca2                	ld	s9,40(sp)
    80000772:	7d02                	ld	s10,32(sp)
    80000774:	6de2                	ld	s11,24(sp)
    80000776:	6129                	addi	sp,sp,192
    80000778:	8082                	ret
    release(&pr.lock);
    8000077a:	00010517          	auipc	a0,0x10
    8000077e:	1de50513          	addi	a0,a0,478 # 80010958 <pr>
    80000782:	5b6000ef          	jal	ra,80000d38 <release>
  return 0;
    80000786:	bfd1                	j	8000075a <printf+0x298>

0000000080000788 <panic>:

void
panic(char *s)
{
    80000788:	1101                	addi	sp,sp,-32
    8000078a:	ec06                	sd	ra,24(sp)
    8000078c:	e822                	sd	s0,16(sp)
    8000078e:	e426                	sd	s1,8(sp)
    80000790:	e04a                	sd	s2,0(sp)
    80000792:	1000                	addi	s0,sp,32
    80000794:	84aa                	mv	s1,a0
  panicking = 1;
    80000796:	4905                	li	s2,1
    80000798:	00008797          	auipc	a5,0x8
    8000079c:	0f27a623          	sw	s2,236(a5) # 80008884 <panicking>
  printf("panic: ");
    800007a0:	00008517          	auipc	a0,0x8
    800007a4:	88050513          	addi	a0,a0,-1920 # 80008020 <etext+0x20>
    800007a8:	d1bff0ef          	jal	ra,800004c2 <printf>
  printf("%s\n", s);
    800007ac:	85a6                	mv	a1,s1
    800007ae:	00008517          	auipc	a0,0x8
    800007b2:	87a50513          	addi	a0,a0,-1926 # 80008028 <etext+0x28>
    800007b6:	d0dff0ef          	jal	ra,800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007ba:	00008797          	auipc	a5,0x8
    800007be:	0d27a323          	sw	s2,198(a5) # 80008880 <panicked>
  for(;;)
    800007c2:	a001                	j	800007c2 <panic+0x3a>

00000000800007c4 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007c4:	1141                	addi	sp,sp,-16
    800007c6:	e406                	sd	ra,8(sp)
    800007c8:	e022                	sd	s0,0(sp)
    800007ca:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	86458593          	addi	a1,a1,-1948 # 80008030 <etext+0x30>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	18450513          	addi	a0,a0,388 # 80010958 <pr>
    800007dc:	444000ef          	jal	ra,80000c20 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800007e8:	1141                	addi	sp,sp,-16
    800007ea:	e406                	sd	ra,8(sp)
    800007ec:	e022                	sd	s0,0(sp)
    800007ee:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007f0:	100007b7          	lui	a5,0x10000
    800007f4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f8:	f8000713          	li	a4,-128
    800007fc:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	470d                	li	a4,3
    80000802:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000806:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080a:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000080e:	469d                	li	a3,7
    80000810:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000814:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    80000818:	00008597          	auipc	a1,0x8
    8000081c:	83858593          	addi	a1,a1,-1992 # 80008050 <digits+0x18>
    80000820:	00010517          	auipc	a0,0x10
    80000824:	15050513          	addi	a0,a0,336 # 80010970 <tx_lock>
    80000828:	3f8000ef          	jal	ra,80000c20 <initlock>
}
    8000082c:	60a2                	ld	ra,8(sp)
    8000082e:	6402                	ld	s0,0(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret

0000000080000834 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000834:	715d                	addi	sp,sp,-80
    80000836:	e486                	sd	ra,72(sp)
    80000838:	e0a2                	sd	s0,64(sp)
    8000083a:	fc26                	sd	s1,56(sp)
    8000083c:	f84a                	sd	s2,48(sp)
    8000083e:	f44e                	sd	s3,40(sp)
    80000840:	f052                	sd	s4,32(sp)
    80000842:	ec56                	sd	s5,24(sp)
    80000844:	e85a                	sd	s6,16(sp)
    80000846:	e45e                	sd	s7,8(sp)
    80000848:	0880                	addi	s0,sp,80
    8000084a:	84aa                	mv	s1,a0
    8000084c:	892e                	mv	s2,a1
  acquire(&tx_lock);
    8000084e:	00010517          	auipc	a0,0x10
    80000852:	12250513          	addi	a0,a0,290 # 80010970 <tx_lock>
    80000856:	44a000ef          	jal	ra,80000ca0 <acquire>

  int i = 0;
  while(i < n){ 
    8000085a:	05205c63          	blez	s2,800008b2 <uartwrite+0x7e>
    8000085e:	8a26                	mv	s4,s1
    80000860:	0485                	addi	s1,s1,1
    80000862:	fff9079b          	addiw	a5,s2,-1
    80000866:	1782                	slli	a5,a5,0x20
    80000868:	9381                	srli	a5,a5,0x20
    8000086a:	00f48ab3          	add	s5,s1,a5
    while(tx_busy != 0){
    8000086e:	00008497          	auipc	s1,0x8
    80000872:	01e48493          	addi	s1,s1,30 # 8000888c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	00010997          	auipc	s3,0x10
    8000087a:	0fa98993          	addi	s3,s3,250 # 80010970 <tx_lock>
    8000087e:	00008917          	auipc	s2,0x8
    80000882:	00a90913          	addi	s2,s2,10 # 80008888 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000886:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    8000088a:	4b05                	li	s6,1
    8000088c:	a005                	j	800008ac <uartwrite+0x78>
      sleep(&tx_chan, &tx_lock);
    8000088e:	85ce                	mv	a1,s3
    80000890:	854a                	mv	a0,s2
    80000892:	2b5010ef          	jal	ra,80002346 <sleep>
    while(tx_busy != 0){
    80000896:	409c                	lw	a5,0(s1)
    80000898:	fbfd                	bnez	a5,8000088e <uartwrite+0x5a>
    WriteReg(THR, buf[i]);
    8000089a:	000a4783          	lbu	a5,0(s4)
    8000089e:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008a2:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008a6:	0a05                	addi	s4,s4,1
    800008a8:	015a0563          	beq	s4,s5,800008b2 <uartwrite+0x7e>
    while(tx_busy != 0){
    800008ac:	409c                	lw	a5,0(s1)
    800008ae:	f3e5                	bnez	a5,8000088e <uartwrite+0x5a>
    800008b0:	b7ed                	j	8000089a <uartwrite+0x66>
  }

  release(&tx_lock);
    800008b2:	00010517          	auipc	a0,0x10
    800008b6:	0be50513          	addi	a0,a0,190 # 80010970 <tx_lock>
    800008ba:	47e000ef          	jal	ra,80000d38 <release>
}
    800008be:	60a6                	ld	ra,72(sp)
    800008c0:	6406                	ld	s0,64(sp)
    800008c2:	74e2                	ld	s1,56(sp)
    800008c4:	7942                	ld	s2,48(sp)
    800008c6:	79a2                	ld	s3,40(sp)
    800008c8:	7a02                	ld	s4,32(sp)
    800008ca:	6ae2                	ld	s5,24(sp)
    800008cc:	6b42                	ld	s6,16(sp)
    800008ce:	6ba2                	ld	s7,8(sp)
    800008d0:	6161                	addi	sp,sp,80
    800008d2:	8082                	ret

00000000800008d4 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800008d4:	1101                	addi	sp,sp,-32
    800008d6:	ec06                	sd	ra,24(sp)
    800008d8:	e822                	sd	s0,16(sp)
    800008da:	e426                	sd	s1,8(sp)
    800008dc:	1000                	addi	s0,sp,32
    800008de:	84aa                	mv	s1,a0
  if(panicking == 0)
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	fa47a783          	lw	a5,-92(a5) # 80008884 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	f967a783          	lw	a5,-106(a5) # 80008880 <panicked>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800008f6:	c789                	beqz	a5,80000900 <uartputc_sync+0x2c>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc_sync+0x24>
    push_off();
    800008fa:	366000ef          	jal	ra,80000c60 <push_off>
    800008fe:	b7f5                	j	800008ea <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000900:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000904:	0207f793          	andi	a5,a5,32
    80000908:	dfe5                	beqz	a5,80000900 <uartputc_sync+0x2c>
    ;
  WriteReg(THR, c);
    8000090a:	0ff4f513          	zext.b	a0,s1
    8000090e:	100007b7          	lui	a5,0x10000
    80000912:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000916:	00008797          	auipc	a5,0x8
    8000091a:	f6e7a783          	lw	a5,-146(a5) # 80008884 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	3ba000ef          	jal	ra,80000ce4 <pop_off>
}
    8000092e:	bfcd                	j	80000920 <uartputc_sync+0x4c>

0000000080000930 <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000930:	1141                	addi	sp,sp,-16
    80000932:	e422                	sd	s0,8(sp)
    80000934:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000936:	100007b7          	lui	a5,0x10000
    8000093a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000093e:	8b85                	andi	a5,a5,1
    80000940:	cb81                	beqz	a5,80000950 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000942:	100007b7          	lui	a5,0x10000
    80000946:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000094a:	6422                	ld	s0,8(sp)
    8000094c:	0141                	addi	sp,sp,16
    8000094e:	8082                	ret
    return -1;
    80000950:	557d                	li	a0,-1
    80000952:	bfe5                	j	8000094a <uartgetc+0x1a>

0000000080000954 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000954:	1101                	addi	sp,sp,-32
    80000956:	ec06                	sd	ra,24(sp)
    80000958:	e822                	sd	s0,16(sp)
    8000095a:	e426                	sd	s1,8(sp)
    8000095c:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    8000095e:	100004b7          	lui	s1,0x10000
    80000962:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000966:	00010517          	auipc	a0,0x10
    8000096a:	00a50513          	addi	a0,a0,10 # 80010970 <tx_lock>
    8000096e:	332000ef          	jal	ra,80000ca0 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000972:	0054c783          	lbu	a5,5(s1)
    80000976:	0207f793          	andi	a5,a5,32
    8000097a:	eb89                	bnez	a5,8000098c <uartintr+0x38>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    8000097c:	00010517          	auipc	a0,0x10
    80000980:	ff450513          	addi	a0,a0,-12 # 80010970 <tx_lock>
    80000984:	3b4000ef          	jal	ra,80000d38 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00008797          	auipc	a5,0x8
    80000990:	f007a023          	sw	zero,-256(a5) # 8000888c <tx_busy>
    wakeup(&tx_chan);
    80000994:	00008517          	auipc	a0,0x8
    80000998:	ef450513          	addi	a0,a0,-268 # 80008888 <tx_chan>
    8000099c:	1f7010ef          	jal	ra,80002392 <wakeup>
    800009a0:	bff1                	j	8000097c <uartintr+0x28>
      break;
    consoleintr(c);
    800009a2:	8d9ff0ef          	jal	ra,8000027a <consoleintr>
    int c = uartgetc();
    800009a6:	f8bff0ef          	jal	ra,80000930 <uartgetc>
    if(c == -1)
    800009aa:	fe951ce3          	bne	a0,s1,800009a2 <uartintr+0x4e>
  }
}
    800009ae:	60e2                	ld	ra,24(sp)
    800009b0:	6442                	ld	s0,16(sp)
    800009b2:	64a2                	ld	s1,8(sp)
    800009b4:	6105                	addi	sp,sp,32
    800009b6:	8082                	ret

00000000800009b8 <kref_get>:
} kref;

//这三个函数作用差不多
//先加锁，在操作，最后释放锁再返回现在的引用数
int     
kref_get(void *pa){
    800009b8:	1101                	addi	sp,sp,-32
    800009ba:	ec06                	sd	ra,24(sp)
    800009bc:	e822                	sd	s0,16(sp)
    800009be:	e426                	sd	s1,8(sp)
    800009c0:	1000                	addi	s0,sp,32
    800009c2:	84aa                	mv	s1,a0
  int n;
  acquire(&kref.lock);
    800009c4:	00010517          	auipc	a0,0x10
    800009c8:	fe450513          	addi	a0,a0,-28 # 800109a8 <kref>
    800009cc:	2d4000ef          	jal	ra,80000ca0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d0:	00010517          	auipc	a0,0x10
    800009d4:	fd850513          	addi	a0,a0,-40 # 800109a8 <kref>
    800009d8:	80b1                	srli	s1,s1,0xc
    800009da:	0491                	addi	s1,s1,4
    800009dc:	048a                	slli	s1,s1,0x2
    800009de:	94aa                	add	s1,s1,a0
    800009e0:	4484                	lw	s1,8(s1)
  release(&kref.lock);
    800009e2:	356000ef          	jal	ra,80000d38 <release>
  return n;
}
    800009e6:	8526                	mv	a0,s1
    800009e8:	60e2                	ld	ra,24(sp)
    800009ea:	6442                	ld	s0,16(sp)
    800009ec:	64a2                	ld	s1,8(sp)
    800009ee:	6105                	addi	sp,sp,32
    800009f0:	8082                	ret

00000000800009f2 <kref_inc>:
int             
kref_inc(void *pa){
    800009f2:	1101                	addi	sp,sp,-32
    800009f4:	ec06                	sd	ra,24(sp)
    800009f6:	e822                	sd	s0,16(sp)
    800009f8:	e426                	sd	s1,8(sp)
    800009fa:	1000                	addi	s0,sp,32
    800009fc:	84aa                	mv	s1,a0
  int n;
  acquire(&kref.lock);
    800009fe:	00010517          	auipc	a0,0x10
    80000a02:	faa50513          	addi	a0,a0,-86 # 800109a8 <kref>
    80000a06:	29a000ef          	jal	ra,80000ca0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0a:	00c4d793          	srli	a5,s1,0xc
    80000a0e:	00010517          	auipc	a0,0x10
    80000a12:	f9a50513          	addi	a0,a0,-102 # 800109a8 <kref>
    80000a16:	0791                	addi	a5,a5,4
    80000a18:	078a                	slli	a5,a5,0x2
    80000a1a:	97aa                	add	a5,a5,a0
    80000a1c:	4798                	lw	a4,8(a5)
    80000a1e:	2705                	addiw	a4,a4,1
    80000a20:	0007049b          	sext.w	s1,a4
    80000a24:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000a26:	312000ef          	jal	ra,80000d38 <release>
  return n;
}
    80000a2a:	8526                	mv	a0,s1
    80000a2c:	60e2                	ld	ra,24(sp)
    80000a2e:	6442                	ld	s0,16(sp)
    80000a30:	64a2                	ld	s1,8(sp)
    80000a32:	6105                	addi	sp,sp,32
    80000a34:	8082                	ret

0000000080000a36 <kref_dec>:
int            
kref_dec(void *pa){
    80000a36:	1101                	addi	sp,sp,-32
    80000a38:	ec06                	sd	ra,24(sp)
    80000a3a:	e822                	sd	s0,16(sp)
    80000a3c:	e426                	sd	s1,8(sp)
    80000a3e:	1000                	addi	s0,sp,32
    80000a40:	84aa                	mv	s1,a0
  int n;
  acquire(&kref.lock);
    80000a42:	00010517          	auipc	a0,0x10
    80000a46:	f6650513          	addi	a0,a0,-154 # 800109a8 <kref>
    80000a4a:	256000ef          	jal	ra,80000ca0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a4e:	00c4d793          	srli	a5,s1,0xc
    80000a52:	00010517          	auipc	a0,0x10
    80000a56:	f5650513          	addi	a0,a0,-170 # 800109a8 <kref>
    80000a5a:	0791                	addi	a5,a5,4
    80000a5c:	078a                	slli	a5,a5,0x2
    80000a5e:	97aa                	add	a5,a5,a0
    80000a60:	4798                	lw	a4,8(a5)
    80000a62:	377d                	addiw	a4,a4,-1
    80000a64:	0007049b          	sext.w	s1,a4
    80000a68:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000a6a:	2ce000ef          	jal	ra,80000d38 <release>
  return n;
}
    80000a6e:	8526                	mv	a0,s1
    80000a70:	60e2                	ld	ra,24(sp)
    80000a72:	6442                	ld	s0,16(sp)
    80000a74:	64a2                	ld	s1,8(sp)
    80000a76:	6105                	addi	sp,sp,32
    80000a78:	8082                	ret

0000000080000a7a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a7a:	1101                	addi	sp,sp,-32
    80000a7c:	ec06                	sd	ra,24(sp)
    80000a7e:	e822                	sd	s0,16(sp)
    80000a80:	e426                	sd	s1,8(sp)
    80000a82:	e04a                	sd	s2,0(sp)
    80000a84:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a86:	03451793          	slli	a5,a0,0x34
    80000a8a:	e795                	bnez	a5,80000ab6 <kfree+0x3c>
    80000a8c:	84aa                	mv	s1,a0
    80000a8e:	00253797          	auipc	a5,0x253
    80000a92:	2da78793          	addi	a5,a5,730 # 80253d68 <end>
    80000a96:	02f56063          	bltu	a0,a5,80000ab6 <kfree+0x3c>
    80000a9a:	47c5                	li	a5,17
    80000a9c:	07ee                	slli	a5,a5,0x1b
    80000a9e:	00f57c63          	bgeu	a0,a5,80000ab6 <kfree+0x3c>
    panic("kfree");
  //如果某个进程将这个页free后引用数不为0
  //那么说明有其他进程要用到这个页，故不真正将其free了
  if(kref_dec(pa)>0)
    80000aa2:	f95ff0ef          	jal	ra,80000a36 <kref_dec>
    80000aa6:	00a05e63          	blez	a0,80000ac2 <kfree+0x48>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000aaa:	60e2                	ld	ra,24(sp)
    80000aac:	6442                	ld	s0,16(sp)
    80000aae:	64a2                	ld	s1,8(sp)
    80000ab0:	6902                	ld	s2,0(sp)
    80000ab2:	6105                	addi	sp,sp,32
    80000ab4:	8082                	ret
    panic("kfree");
    80000ab6:	00007517          	auipc	a0,0x7
    80000aba:	5a250513          	addi	a0,a0,1442 # 80008058 <digits+0x20>
    80000abe:	ccbff0ef          	jal	ra,80000788 <panic>
  memset(pa, 1, PGSIZE);
    80000ac2:	6605                	lui	a2,0x1
    80000ac4:	4585                	li	a1,1
    80000ac6:	8526                	mv	a0,s1
    80000ac8:	2ac000ef          	jal	ra,80000d74 <memset>
  acquire(&kmem.lock);
    80000acc:	00010917          	auipc	s2,0x10
    80000ad0:	ebc90913          	addi	s2,s2,-324 # 80010988 <kmem>
    80000ad4:	854a                	mv	a0,s2
    80000ad6:	1ca000ef          	jal	ra,80000ca0 <acquire>
  r->next = kmem.freelist;
    80000ada:	01893783          	ld	a5,24(s2)
    80000ade:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ae0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ae4:	854a                	mv	a0,s2
    80000ae6:	252000ef          	jal	ra,80000d38 <release>
    80000aea:	b7c1                	j	80000aaa <kfree+0x30>

0000000080000aec <freerange>:
{
    80000aec:	7139                	addi	sp,sp,-64
    80000aee:	fc06                	sd	ra,56(sp)
    80000af0:	f822                	sd	s0,48(sp)
    80000af2:	f426                	sd	s1,40(sp)
    80000af4:	f04a                	sd	s2,32(sp)
    80000af6:	ec4e                	sd	s3,24(sp)
    80000af8:	e852                	sd	s4,16(sp)
    80000afa:	e456                	sd	s5,8(sp)
    80000afc:	e05a                	sd	s6,0(sp)
    80000afe:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b00:	6785                	lui	a5,0x1
    80000b02:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b06:	953a                	add	a0,a0,a4
    80000b08:	777d                	lui	a4,0xfffff
    80000b0a:	00e574b3          	and	s1,a0,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b0e:	97a6                	add	a5,a5,s1
    80000b10:	02f5ef63          	bltu	a1,a5,80000b4e <freerange+0x62>
    80000b14:	89ae                	mv	s3,a1
    acquire(&kref.lock);
    80000b16:	00010917          	auipc	s2,0x10
    80000b1a:	e9290913          	addi	s2,s2,-366 # 800109a8 <kref>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b1e:	4b05                	li	s6,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b20:	6a85                	lui	s5,0x1
    80000b22:	6a09                	lui	s4,0x2
    acquire(&kref.lock);
    80000b24:	854a                	mv	a0,s2
    80000b26:	17a000ef          	jal	ra,80000ca0 <acquire>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b2a:	00c4d793          	srli	a5,s1,0xc
    80000b2e:	0791                	addi	a5,a5,4
    80000b30:	078a                	slli	a5,a5,0x2
    80000b32:	97ca                	add	a5,a5,s2
    80000b34:	0167a423          	sw	s6,8(a5)
    release(&kref.lock);
    80000b38:	854a                	mv	a0,s2
    80000b3a:	1fe000ef          	jal	ra,80000d38 <release>
    kfree(p);
    80000b3e:	8526                	mv	a0,s1
    80000b40:	f3bff0ef          	jal	ra,80000a7a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b44:	87a6                	mv	a5,s1
    80000b46:	94d6                	add	s1,s1,s5
    80000b48:	97d2                	add	a5,a5,s4
    80000b4a:	fcf9fde3          	bgeu	s3,a5,80000b24 <freerange+0x38>
}
    80000b4e:	70e2                	ld	ra,56(sp)
    80000b50:	7442                	ld	s0,48(sp)
    80000b52:	74a2                	ld	s1,40(sp)
    80000b54:	7902                	ld	s2,32(sp)
    80000b56:	69e2                	ld	s3,24(sp)
    80000b58:	6a42                	ld	s4,16(sp)
    80000b5a:	6aa2                	ld	s5,8(sp)
    80000b5c:	6b02                	ld	s6,0(sp)
    80000b5e:	6121                	addi	sp,sp,64
    80000b60:	8082                	ret

0000000080000b62 <kinit>:
{
    80000b62:	1141                	addi	sp,sp,-16
    80000b64:	e406                	sd	ra,8(sp)
    80000b66:	e022                	sd	s0,0(sp)
    80000b68:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b6a:	00007597          	auipc	a1,0x7
    80000b6e:	4f658593          	addi	a1,a1,1270 # 80008060 <digits+0x28>
    80000b72:	00010517          	auipc	a0,0x10
    80000b76:	e1650513          	addi	a0,a0,-490 # 80010988 <kmem>
    80000b7a:	0a6000ef          	jal	ra,80000c20 <initlock>
  initlock(&kref.lock, "kref");
    80000b7e:	00007597          	auipc	a1,0x7
    80000b82:	4ea58593          	addi	a1,a1,1258 # 80008068 <digits+0x30>
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	e2250513          	addi	a0,a0,-478 # 800109a8 <kref>
    80000b8e:	092000ef          	jal	ra,80000c20 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b92:	45c5                	li	a1,17
    80000b94:	05ee                	slli	a1,a1,0x1b
    80000b96:	00253517          	auipc	a0,0x253
    80000b9a:	1d250513          	addi	a0,a0,466 # 80253d68 <end>
    80000b9e:	f4fff0ef          	jal	ra,80000aec <freerange>
}
    80000ba2:	60a2                	ld	ra,8(sp)
    80000ba4:	6402                	ld	s0,0(sp)
    80000ba6:	0141                	addi	sp,sp,16
    80000ba8:	8082                	ret

0000000080000baa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000baa:	1101                	addi	sp,sp,-32
    80000bac:	ec06                	sd	ra,24(sp)
    80000bae:	e822                	sd	s0,16(sp)
    80000bb0:	e426                	sd	s1,8(sp)
    80000bb2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bb4:	00010497          	auipc	s1,0x10
    80000bb8:	dd448493          	addi	s1,s1,-556 # 80010988 <kmem>
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	0e2000ef          	jal	ra,80000ca0 <acquire>
  r = kmem.freelist;
    80000bc2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc4:	c4b9                	beqz	s1,80000c12 <kalloc+0x68>
    kmem.freelist = r->next;
    80000bc6:	609c                	ld	a5,0(s1)
    80000bc8:	00010517          	auipc	a0,0x10
    80000bcc:	dc050513          	addi	a0,a0,-576 # 80010988 <kmem>
    80000bd0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bd2:	166000ef          	jal	ra,80000d38 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bd6:	6605                	lui	a2,0x1
    80000bd8:	4595                	li	a1,5
    80000bda:	8526                	mv	a0,s1
    80000bdc:	198000ef          	jal	ra,80000d74 <memset>
  
  //alloc出页后，默认引用数为1
  if(r){
  acquire(&kref.lock);
    80000be0:	00010517          	auipc	a0,0x10
    80000be4:	dc850513          	addi	a0,a0,-568 # 800109a8 <kref>
    80000be8:	0b8000ef          	jal	ra,80000ca0 <acquire>
  kref.refcnt[PA2IDX(r)] = 1;
    80000bec:	00010517          	auipc	a0,0x10
    80000bf0:	dbc50513          	addi	a0,a0,-580 # 800109a8 <kref>
    80000bf4:	00c4d793          	srli	a5,s1,0xc
    80000bf8:	0791                	addi	a5,a5,4
    80000bfa:	078a                	slli	a5,a5,0x2
    80000bfc:	97aa                	add	a5,a5,a0
    80000bfe:	4705                	li	a4,1
    80000c00:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000c02:	136000ef          	jal	ra,80000d38 <release>
}

  return (void*)r;
}
    80000c06:	8526                	mv	a0,s1
    80000c08:	60e2                	ld	ra,24(sp)
    80000c0a:	6442                	ld	s0,16(sp)
    80000c0c:	64a2                	ld	s1,8(sp)
    80000c0e:	6105                	addi	sp,sp,32
    80000c10:	8082                	ret
  release(&kmem.lock);
    80000c12:	00010517          	auipc	a0,0x10
    80000c16:	d7650513          	addi	a0,a0,-650 # 80010988 <kmem>
    80000c1a:	11e000ef          	jal	ra,80000d38 <release>
  if(r){
    80000c1e:	b7e5                	j	80000c06 <kalloc+0x5c>

0000000080000c20 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c20:	1141                	addi	sp,sp,-16
    80000c22:	e422                	sd	s0,8(sp)
    80000c24:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c26:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c28:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c2c:	00053823          	sd	zero,16(a0)
}
    80000c30:	6422                	ld	s0,8(sp)
    80000c32:	0141                	addi	sp,sp,16
    80000c34:	8082                	ret

0000000080000c36 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c36:	411c                	lw	a5,0(a0)
    80000c38:	e399                	bnez	a5,80000c3e <holding+0x8>
    80000c3a:	4501                	li	a0,0
  return r;
}
    80000c3c:	8082                	ret
{
    80000c3e:	1101                	addi	sp,sp,-32
    80000c40:	ec06                	sd	ra,24(sp)
    80000c42:	e822                	sd	s0,16(sp)
    80000c44:	e426                	sd	s1,8(sp)
    80000c46:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c48:	6904                	ld	s1,16(a0)
    80000c4a:	6e3000ef          	jal	ra,80001b2c <mycpu>
    80000c4e:	40a48533          	sub	a0,s1,a0
    80000c52:	00153513          	seqz	a0,a0
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret

0000000080000c60 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c60:	1101                	addi	sp,sp,-32
    80000c62:	ec06                	sd	ra,24(sp)
    80000c64:	e822                	sd	s0,16(sp)
    80000c66:	e426                	sd	s1,8(sp)
    80000c68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100024f3          	csrr	s1,sstatus
    80000c6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c72:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c74:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c78:	6b5000ef          	jal	ra,80001b2c <mycpu>
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	cb99                	beqz	a5,80000c94 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c80:	6ad000ef          	jal	ra,80001b2c <mycpu>
    80000c84:	5d3c                	lw	a5,120(a0)
    80000c86:	2785                	addiw	a5,a5,1
    80000c88:	dd3c                	sw	a5,120(a0)
}
    80000c8a:	60e2                	ld	ra,24(sp)
    80000c8c:	6442                	ld	s0,16(sp)
    80000c8e:	64a2                	ld	s1,8(sp)
    80000c90:	6105                	addi	sp,sp,32
    80000c92:	8082                	ret
    mycpu()->intena = old;
    80000c94:	699000ef          	jal	ra,80001b2c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c98:	8085                	srli	s1,s1,0x1
    80000c9a:	8885                	andi	s1,s1,1
    80000c9c:	dd64                	sw	s1,124(a0)
    80000c9e:	b7cd                	j	80000c80 <push_off+0x20>

0000000080000ca0 <acquire>:
{
    80000ca0:	1101                	addi	sp,sp,-32
    80000ca2:	ec06                	sd	ra,24(sp)
    80000ca4:	e822                	sd	s0,16(sp)
    80000ca6:	e426                	sd	s1,8(sp)
    80000ca8:	1000                	addi	s0,sp,32
    80000caa:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cac:	fb5ff0ef          	jal	ra,80000c60 <push_off>
  if(holding(lk))
    80000cb0:	8526                	mv	a0,s1
    80000cb2:	f85ff0ef          	jal	ra,80000c36 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cb6:	4705                	li	a4,1
  if(holding(lk))
    80000cb8:	e105                	bnez	a0,80000cd8 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cba:	87ba                	mv	a5,a4
    80000cbc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cc0:	2781                	sext.w	a5,a5
    80000cc2:	ffe5                	bnez	a5,80000cba <acquire+0x1a>
  __sync_synchronize();
    80000cc4:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cc8:	665000ef          	jal	ra,80001b2c <mycpu>
    80000ccc:	e888                	sd	a0,16(s1)
}
    80000cce:	60e2                	ld	ra,24(sp)
    80000cd0:	6442                	ld	s0,16(sp)
    80000cd2:	64a2                	ld	s1,8(sp)
    80000cd4:	6105                	addi	sp,sp,32
    80000cd6:	8082                	ret
    panic("acquire");
    80000cd8:	00007517          	auipc	a0,0x7
    80000cdc:	39850513          	addi	a0,a0,920 # 80008070 <digits+0x38>
    80000ce0:	aa9ff0ef          	jal	ra,80000788 <panic>

0000000080000ce4 <pop_off>:

void
pop_off(void)
{
    80000ce4:	1141                	addi	sp,sp,-16
    80000ce6:	e406                	sd	ra,8(sp)
    80000ce8:	e022                	sd	s0,0(sp)
    80000cea:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cec:	641000ef          	jal	ra,80001b2c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cf0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cf4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cf6:	e78d                	bnez	a5,80000d20 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cf8:	5d3c                	lw	a5,120(a0)
    80000cfa:	02f05963          	blez	a5,80000d2c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000cfe:	37fd                	addiw	a5,a5,-1
    80000d00:	0007871b          	sext.w	a4,a5
    80000d04:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d06:	eb09                	bnez	a4,80000d18 <pop_off+0x34>
    80000d08:	5d7c                	lw	a5,124(a0)
    80000d0a:	c799                	beqz	a5,80000d18 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d10:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d14:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d18:	60a2                	ld	ra,8(sp)
    80000d1a:	6402                	ld	s0,0(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
    panic("pop_off - interruptible");
    80000d20:	00007517          	auipc	a0,0x7
    80000d24:	35850513          	addi	a0,a0,856 # 80008078 <digits+0x40>
    80000d28:	a61ff0ef          	jal	ra,80000788 <panic>
    panic("pop_off");
    80000d2c:	00007517          	auipc	a0,0x7
    80000d30:	36450513          	addi	a0,a0,868 # 80008090 <digits+0x58>
    80000d34:	a55ff0ef          	jal	ra,80000788 <panic>

0000000080000d38 <release>:
{
    80000d38:	1101                	addi	sp,sp,-32
    80000d3a:	ec06                	sd	ra,24(sp)
    80000d3c:	e822                	sd	s0,16(sp)
    80000d3e:	e426                	sd	s1,8(sp)
    80000d40:	1000                	addi	s0,sp,32
    80000d42:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d44:	ef3ff0ef          	jal	ra,80000c36 <holding>
    80000d48:	c105                	beqz	a0,80000d68 <release+0x30>
  lk->cpu = 0;
    80000d4a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d4e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d52:	0f50000f          	fence	iorw,ow
    80000d56:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d5a:	f8bff0ef          	jal	ra,80000ce4 <pop_off>
}
    80000d5e:	60e2                	ld	ra,24(sp)
    80000d60:	6442                	ld	s0,16(sp)
    80000d62:	64a2                	ld	s1,8(sp)
    80000d64:	6105                	addi	sp,sp,32
    80000d66:	8082                	ret
    panic("release");
    80000d68:	00007517          	auipc	a0,0x7
    80000d6c:	33050513          	addi	a0,a0,816 # 80008098 <digits+0x60>
    80000d70:	a19ff0ef          	jal	ra,80000788 <panic>

0000000080000d74 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d74:	1141                	addi	sp,sp,-16
    80000d76:	e422                	sd	s0,8(sp)
    80000d78:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d7a:	ca19                	beqz	a2,80000d90 <memset+0x1c>
    80000d7c:	87aa                	mv	a5,a0
    80000d7e:	1602                	slli	a2,a2,0x20
    80000d80:	9201                	srli	a2,a2,0x20
    80000d82:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d86:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d8a:	0785                	addi	a5,a5,1
    80000d8c:	fee79de3          	bne	a5,a4,80000d86 <memset+0x12>
  }
  return dst;
}
    80000d90:	6422                	ld	s0,8(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d9c:	ca05                	beqz	a2,80000dcc <memcmp+0x36>
    80000d9e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000da2:	1682                	slli	a3,a3,0x20
    80000da4:	9281                	srli	a3,a3,0x20
    80000da6:	0685                	addi	a3,a3,1
    80000da8:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	0005c703          	lbu	a4,0(a1)
    80000db2:	00e79863          	bne	a5,a4,80000dc2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dba:	fed518e3          	bne	a0,a3,80000daa <memcmp+0x14>
  }

  return 0;
    80000dbe:	4501                	li	a0,0
    80000dc0:	a019                	j	80000dc6 <memcmp+0x30>
      return *s1 - *s2;
    80000dc2:	40e7853b          	subw	a0,a5,a4
}
    80000dc6:	6422                	ld	s0,8(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret
  return 0;
    80000dcc:	4501                	li	a0,0
    80000dce:	bfe5                	j	80000dc6 <memcmp+0x30>

0000000080000dd0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dd0:	1141                	addi	sp,sp,-16
    80000dd2:	e422                	sd	s0,8(sp)
    80000dd4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000dd6:	c205                	beqz	a2,80000df6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dd8:	02a5e263          	bltu	a1,a0,80000dfc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ddc:	1602                	slli	a2,a2,0x20
    80000dde:	9201                	srli	a2,a2,0x20
    80000de0:	00c587b3          	add	a5,a1,a2
{
    80000de4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000de6:	0585                	addi	a1,a1,1
    80000de8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fdab299>
    80000dea:	fff5c683          	lbu	a3,-1(a1)
    80000dee:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000df2:	fef59ae3          	bne	a1,a5,80000de6 <memmove+0x16>

  return dst;
}
    80000df6:	6422                	ld	s0,8(sp)
    80000df8:	0141                	addi	sp,sp,16
    80000dfa:	8082                	ret
  if(s < d && s + n > d){
    80000dfc:	02061693          	slli	a3,a2,0x20
    80000e00:	9281                	srli	a3,a3,0x20
    80000e02:	00d58733          	add	a4,a1,a3
    80000e06:	fce57be3          	bgeu	a0,a4,80000ddc <memmove+0xc>
    d += n;
    80000e0a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e0c:	fff6079b          	addiw	a5,a2,-1
    80000e10:	1782                	slli	a5,a5,0x20
    80000e12:	9381                	srli	a5,a5,0x20
    80000e14:	fff7c793          	not	a5,a5
    80000e18:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e1a:	177d                	addi	a4,a4,-1
    80000e1c:	16fd                	addi	a3,a3,-1
    80000e1e:	00074603          	lbu	a2,0(a4)
    80000e22:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e26:	fee79ae3          	bne	a5,a4,80000e1a <memmove+0x4a>
    80000e2a:	b7f1                	j	80000df6 <memmove+0x26>

0000000080000e2c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e406                	sd	ra,8(sp)
    80000e30:	e022                	sd	s0,0(sp)
    80000e32:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e34:	f9dff0ef          	jal	ra,80000dd0 <memmove>
}
    80000e38:	60a2                	ld	ra,8(sp)
    80000e3a:	6402                	ld	s0,0(sp)
    80000e3c:	0141                	addi	sp,sp,16
    80000e3e:	8082                	ret

0000000080000e40 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e40:	1141                	addi	sp,sp,-16
    80000e42:	e422                	sd	s0,8(sp)
    80000e44:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e46:	ce11                	beqz	a2,80000e62 <strncmp+0x22>
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf89                	beqz	a5,80000e66 <strncmp+0x26>
    80000e4e:	0005c703          	lbu	a4,0(a1)
    80000e52:	00f71a63          	bne	a4,a5,80000e66 <strncmp+0x26>
    n--, p++, q++;
    80000e56:	367d                	addiw	a2,a2,-1
    80000e58:	0505                	addi	a0,a0,1
    80000e5a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e5c:	f675                	bnez	a2,80000e48 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e5e:	4501                	li	a0,0
    80000e60:	a809                	j	80000e72 <strncmp+0x32>
    80000e62:	4501                	li	a0,0
    80000e64:	a039                	j	80000e72 <strncmp+0x32>
  if(n == 0)
    80000e66:	ca09                	beqz	a2,80000e78 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e68:	00054503          	lbu	a0,0(a0)
    80000e6c:	0005c783          	lbu	a5,0(a1)
    80000e70:	9d1d                	subw	a0,a0,a5
}
    80000e72:	6422                	ld	s0,8(sp)
    80000e74:	0141                	addi	sp,sp,16
    80000e76:	8082                	ret
    return 0;
    80000e78:	4501                	li	a0,0
    80000e7a:	bfe5                	j	80000e72 <strncmp+0x32>

0000000080000e7c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e7c:	1141                	addi	sp,sp,-16
    80000e7e:	e422                	sd	s0,8(sp)
    80000e80:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e82:	872a                	mv	a4,a0
    80000e84:	8832                	mv	a6,a2
    80000e86:	367d                	addiw	a2,a2,-1
    80000e88:	01005963          	blez	a6,80000e9a <strncpy+0x1e>
    80000e8c:	0705                	addi	a4,a4,1
    80000e8e:	0005c783          	lbu	a5,0(a1)
    80000e92:	fef70fa3          	sb	a5,-1(a4)
    80000e96:	0585                	addi	a1,a1,1
    80000e98:	f7f5                	bnez	a5,80000e84 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e9a:	86ba                	mv	a3,a4
    80000e9c:	00c05c63          	blez	a2,80000eb4 <strncpy+0x38>
    *s++ = 0;
    80000ea0:	0685                	addi	a3,a3,1
    80000ea2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ea6:	40d707bb          	subw	a5,a4,a3
    80000eaa:	37fd                	addiw	a5,a5,-1
    80000eac:	010787bb          	addw	a5,a5,a6
    80000eb0:	fef048e3          	bgtz	a5,80000ea0 <strncpy+0x24>
  return os;
}
    80000eb4:	6422                	ld	s0,8(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret

0000000080000eba <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eba:	1141                	addi	sp,sp,-16
    80000ebc:	e422                	sd	s0,8(sp)
    80000ebe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ec0:	02c05363          	blez	a2,80000ee6 <safestrcpy+0x2c>
    80000ec4:	fff6069b          	addiw	a3,a2,-1
    80000ec8:	1682                	slli	a3,a3,0x20
    80000eca:	9281                	srli	a3,a3,0x20
    80000ecc:	96ae                	add	a3,a3,a1
    80000ece:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ed0:	00d58963          	beq	a1,a3,80000ee2 <safestrcpy+0x28>
    80000ed4:	0585                	addi	a1,a1,1
    80000ed6:	0785                	addi	a5,a5,1
    80000ed8:	fff5c703          	lbu	a4,-1(a1)
    80000edc:	fee78fa3          	sb	a4,-1(a5)
    80000ee0:	fb65                	bnez	a4,80000ed0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ee2:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ee6:	6422                	ld	s0,8(sp)
    80000ee8:	0141                	addi	sp,sp,16
    80000eea:	8082                	ret

0000000080000eec <strlen>:

int
strlen(const char *s)
{
    80000eec:	1141                	addi	sp,sp,-16
    80000eee:	e422                	sd	s0,8(sp)
    80000ef0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ef2:	00054783          	lbu	a5,0(a0)
    80000ef6:	cf91                	beqz	a5,80000f12 <strlen+0x26>
    80000ef8:	0505                	addi	a0,a0,1
    80000efa:	87aa                	mv	a5,a0
    80000efc:	4685                	li	a3,1
    80000efe:	9e89                	subw	a3,a3,a0
    80000f00:	00f6853b          	addw	a0,a3,a5
    80000f04:	0785                	addi	a5,a5,1
    80000f06:	fff7c703          	lbu	a4,-1(a5)
    80000f0a:	fb7d                	bnez	a4,80000f00 <strlen+0x14>
    ;
  return n;
}
    80000f0c:	6422                	ld	s0,8(sp)
    80000f0e:	0141                	addi	sp,sp,16
    80000f10:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f12:	4501                	li	a0,0
    80000f14:	bfe5                	j	80000f0c <strlen+0x20>

0000000080000f16 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e406                	sd	ra,8(sp)
    80000f1a:	e022                	sd	s0,0(sp)
    80000f1c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f1e:	3ff000ef          	jal	ra,80001b1c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f22:	00008717          	auipc	a4,0x8
    80000f26:	96e70713          	addi	a4,a4,-1682 # 80008890 <started>
  if(cpuid() == 0){
    80000f2a:	c51d                	beqz	a0,80000f58 <main+0x42>
    while(started == 0)
    80000f2c:	431c                	lw	a5,0(a4)
    80000f2e:	2781                	sext.w	a5,a5
    80000f30:	dff5                	beqz	a5,80000f2c <main+0x16>
      ;
    __sync_synchronize();
    80000f32:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f36:	3e7000ef          	jal	ra,80001b1c <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	17c50513          	addi	a0,a0,380 # 800080b8 <digits+0x80>
    80000f44:	d7eff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000f48:	080000ef          	jal	ra,80000fc8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	11d010ef          	jal	ra,80002868 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	5e5040ef          	jal	ra,80005d34 <plicinithart>
  }

  scheduler();        
    80000f54:	25a010ef          	jal	ra,800021ae <scheduler>
    consoleinit();
    80000f58:	c94ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000f5c:	869ff0ef          	jal	ra,800007c4 <printfinit>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	16850513          	addi	a0,a0,360 # 800080c8 <digits+0x90>
    80000f68:	d5aff0ef          	jal	ra,800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000f6c:	00007517          	auipc	a0,0x7
    80000f70:	13450513          	addi	a0,a0,308 # 800080a0 <digits+0x68>
    80000f74:	d4eff0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80000f78:	00007517          	auipc	a0,0x7
    80000f7c:	15050513          	addi	a0,a0,336 # 800080c8 <digits+0x90>
    80000f80:	d42ff0ef          	jal	ra,800004c2 <printf>
    kinit();         // physical page allocator
    80000f84:	bdfff0ef          	jal	ra,80000b62 <kinit>
    kvminit();       // create kernel page table
    80000f88:	2ca000ef          	jal	ra,80001252 <kvminit>
    kvminithart();   // turn on paging
    80000f8c:	03c000ef          	jal	ra,80000fc8 <kvminithart>
    procinit();      // process table
    80000f90:	2e5000ef          	jal	ra,80001a74 <procinit>
    trapinit();      // trap vectors
    80000f94:	0b1010ef          	jal	ra,80002844 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	0d1010ef          	jal	ra,80002868 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	583040ef          	jal	ra,80005d1e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	595040ef          	jal	ra,80005d34 <plicinithart>
    binit();         // buffer cache
    80000fa4:	4da020ef          	jal	ra,8000347e <binit>
    iinit();         // inode table
    80000fa8:	24b020ef          	jal	ra,800039f2 <iinit>
    fileinit();      // file table
    80000fac:	133030ef          	jal	ra,800048de <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	675040ef          	jal	ra,80005e24 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	7c1000ef          	jal	ra,80001f74 <userinit>
    __sync_synchronize();
    80000fb8:	0ff0000f          	fence
    started = 1;
    80000fbc:	4785                	li	a5,1
    80000fbe:	00008717          	auipc	a4,0x8
    80000fc2:	8cf72923          	sw	a5,-1838(a4) # 80008890 <started>
    80000fc6:	b779                	j	80000f54 <main+0x3e>

0000000080000fc8 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000fc8:	1141                	addi	sp,sp,-16
    80000fca:	e422                	sd	s0,8(sp)
    80000fcc:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fce:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fd2:	00008797          	auipc	a5,0x8
    80000fd6:	8c67b783          	ld	a5,-1850(a5) # 80008898 <kernel_pagetable>
    80000fda:	83b1                	srli	a5,a5,0xc
    80000fdc:	577d                	li	a4,-1
    80000fde:	177e                	slli	a4,a4,0x3f
    80000fe0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fe2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fe6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fea:	6422                	ld	s0,8(sp)
    80000fec:	0141                	addi	sp,sp,16
    80000fee:	8082                	ret

0000000080000ff0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ff0:	7139                	addi	sp,sp,-64
    80000ff2:	fc06                	sd	ra,56(sp)
    80000ff4:	f822                	sd	s0,48(sp)
    80000ff6:	f426                	sd	s1,40(sp)
    80000ff8:	f04a                	sd	s2,32(sp)
    80000ffa:	ec4e                	sd	s3,24(sp)
    80000ffc:	e852                	sd	s4,16(sp)
    80000ffe:	e456                	sd	s5,8(sp)
    80001000:	e05a                	sd	s6,0(sp)
    80001002:	0080                	addi	s0,sp,64
    80001004:	84aa                	mv	s1,a0
    80001006:	89ae                	mv	s3,a1
    80001008:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000100a:	57fd                	li	a5,-1
    8000100c:	83e9                	srli	a5,a5,0x1a
    8000100e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001010:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001012:	02b7fc63          	bgeu	a5,a1,8000104a <walk+0x5a>
    panic("walk");
    80001016:	00007517          	auipc	a0,0x7
    8000101a:	0ba50513          	addi	a0,a0,186 # 800080d0 <digits+0x98>
    8000101e:	f6aff0ef          	jal	ra,80000788 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001022:	060a8263          	beqz	s5,80001086 <walk+0x96>
    80001026:	b85ff0ef          	jal	ra,80000baa <kalloc>
    8000102a:	84aa                	mv	s1,a0
    8000102c:	c139                	beqz	a0,80001072 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000102e:	6605                	lui	a2,0x1
    80001030:	4581                	li	a1,0
    80001032:	d43ff0ef          	jal	ra,80000d74 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001036:	00c4d793          	srli	a5,s1,0xc
    8000103a:	07aa                	slli	a5,a5,0xa
    8000103c:	0017e793          	ori	a5,a5,1
    80001040:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001044:	3a5d                	addiw	s4,s4,-9 # 1ff7 <_entry-0x7fffe009>
    80001046:	036a0063          	beq	s4,s6,80001066 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000104a:	0149d933          	srl	s2,s3,s4
    8000104e:	1ff97913          	andi	s2,s2,511
    80001052:	090e                	slli	s2,s2,0x3
    80001054:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001056:	00093483          	ld	s1,0(s2)
    8000105a:	0014f793          	andi	a5,s1,1
    8000105e:	d3f1                	beqz	a5,80001022 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001060:	80a9                	srli	s1,s1,0xa
    80001062:	04b2                	slli	s1,s1,0xc
    80001064:	b7c5                	j	80001044 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001066:	00c9d513          	srli	a0,s3,0xc
    8000106a:	1ff57513          	andi	a0,a0,511
    8000106e:	050e                	slli	a0,a0,0x3
    80001070:	9526                	add	a0,a0,s1
}
    80001072:	70e2                	ld	ra,56(sp)
    80001074:	7442                	ld	s0,48(sp)
    80001076:	74a2                	ld	s1,40(sp)
    80001078:	7902                	ld	s2,32(sp)
    8000107a:	69e2                	ld	s3,24(sp)
    8000107c:	6a42                	ld	s4,16(sp)
    8000107e:	6aa2                	ld	s5,8(sp)
    80001080:	6b02                	ld	s6,0(sp)
    80001082:	6121                	addi	sp,sp,64
    80001084:	8082                	ret
        return 0;
    80001086:	4501                	li	a0,0
    80001088:	b7ed                	j	80001072 <walk+0x82>

000000008000108a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000108a:	57fd                	li	a5,-1
    8000108c:	83e9                	srli	a5,a5,0x1a
    8000108e:	00b7f463          	bgeu	a5,a1,80001096 <walkaddr+0xc>
    return 0;
    80001092:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001094:	8082                	ret
{
    80001096:	1141                	addi	sp,sp,-16
    80001098:	e406                	sd	ra,8(sp)
    8000109a:	e022                	sd	s0,0(sp)
    8000109c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000109e:	4601                	li	a2,0
    800010a0:	f51ff0ef          	jal	ra,80000ff0 <walk>
  if(pte == 0)
    800010a4:	c105                	beqz	a0,800010c4 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800010a6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010a8:	0117f693          	andi	a3,a5,17
    800010ac:	4745                	li	a4,17
    return 0;
    800010ae:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010b0:	00e68663          	beq	a3,a4,800010bc <walkaddr+0x32>
}
    800010b4:	60a2                	ld	ra,8(sp)
    800010b6:	6402                	ld	s0,0(sp)
    800010b8:	0141                	addi	sp,sp,16
    800010ba:	8082                	ret
  pa = PTE2PA(*pte);
    800010bc:	83a9                	srli	a5,a5,0xa
    800010be:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010c2:	bfcd                	j	800010b4 <walkaddr+0x2a>
    return 0;
    800010c4:	4501                	li	a0,0
    800010c6:	b7fd                	j	800010b4 <walkaddr+0x2a>

00000000800010c8 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010c8:	715d                	addi	sp,sp,-80
    800010ca:	e486                	sd	ra,72(sp)
    800010cc:	e0a2                	sd	s0,64(sp)
    800010ce:	fc26                	sd	s1,56(sp)
    800010d0:	f84a                	sd	s2,48(sp)
    800010d2:	f44e                	sd	s3,40(sp)
    800010d4:	f052                	sd	s4,32(sp)
    800010d6:	ec56                	sd	s5,24(sp)
    800010d8:	e85a                	sd	s6,16(sp)
    800010da:	e45e                	sd	s7,8(sp)
    800010dc:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010de:	03459793          	slli	a5,a1,0x34
    800010e2:	e7a9                	bnez	a5,8000112c <mappages+0x64>
    800010e4:	8aaa                	mv	s5,a0
    800010e6:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800010e8:	03461793          	slli	a5,a2,0x34
    800010ec:	e7b1                	bnez	a5,80001138 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800010ee:	ca39                	beqz	a2,80001144 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800010f0:	77fd                	lui	a5,0xfffff
    800010f2:	963e                	add	a2,a2,a5
    800010f4:	00b609b3          	add	s3,a2,a1
  a = va;
    800010f8:	892e                	mv	s2,a1
    800010fa:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010fe:	6b85                	lui	s7,0x1
    80001100:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001104:	4605                	li	a2,1
    80001106:	85ca                	mv	a1,s2
    80001108:	8556                	mv	a0,s5
    8000110a:	ee7ff0ef          	jal	ra,80000ff0 <walk>
    8000110e:	c539                	beqz	a0,8000115c <mappages+0x94>
    if(*pte & PTE_V)
    80001110:	611c                	ld	a5,0(a0)
    80001112:	8b85                	andi	a5,a5,1
    80001114:	ef95                	bnez	a5,80001150 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001116:	80b1                	srli	s1,s1,0xc
    80001118:	04aa                	slli	s1,s1,0xa
    8000111a:	0164e4b3          	or	s1,s1,s6
    8000111e:	0014e493          	ori	s1,s1,1
    80001122:	e104                	sd	s1,0(a0)
    if(a == last)
    80001124:	05390863          	beq	s2,s3,80001174 <mappages+0xac>
    a += PGSIZE;
    80001128:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000112a:	bfd9                	j	80001100 <mappages+0x38>
    panic("mappages: va not aligned");
    8000112c:	00007517          	auipc	a0,0x7
    80001130:	fac50513          	addi	a0,a0,-84 # 800080d8 <digits+0xa0>
    80001134:	e54ff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size not aligned");
    80001138:	00007517          	auipc	a0,0x7
    8000113c:	fc050513          	addi	a0,a0,-64 # 800080f8 <digits+0xc0>
    80001140:	e48ff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size");
    80001144:	00007517          	auipc	a0,0x7
    80001148:	fd450513          	addi	a0,a0,-44 # 80008118 <digits+0xe0>
    8000114c:	e3cff0ef          	jal	ra,80000788 <panic>
      panic("mappages: remap");
    80001150:	00007517          	auipc	a0,0x7
    80001154:	fd850513          	addi	a0,a0,-40 # 80008128 <digits+0xf0>
    80001158:	e30ff0ef          	jal	ra,80000788 <panic>
      return -1;
    8000115c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000115e:	60a6                	ld	ra,72(sp)
    80001160:	6406                	ld	s0,64(sp)
    80001162:	74e2                	ld	s1,56(sp)
    80001164:	7942                	ld	s2,48(sp)
    80001166:	79a2                	ld	s3,40(sp)
    80001168:	7a02                	ld	s4,32(sp)
    8000116a:	6ae2                	ld	s5,24(sp)
    8000116c:	6b42                	ld	s6,16(sp)
    8000116e:	6ba2                	ld	s7,8(sp)
    80001170:	6161                	addi	sp,sp,80
    80001172:	8082                	ret
  return 0;
    80001174:	4501                	li	a0,0
    80001176:	b7e5                	j	8000115e <mappages+0x96>

0000000080001178 <kvmmap>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
    80001180:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001182:	86b2                	mv	a3,a2
    80001184:	863e                	mv	a2,a5
    80001186:	f43ff0ef          	jal	ra,800010c8 <mappages>
    8000118a:	e509                	bnez	a0,80001194 <kvmmap+0x1c>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret
    panic("kvmmap");
    80001194:	00007517          	auipc	a0,0x7
    80001198:	fa450513          	addi	a0,a0,-92 # 80008138 <digits+0x100>
    8000119c:	decff0ef          	jal	ra,80000788 <panic>

00000000800011a0 <kvmmake>:
{
    800011a0:	1101                	addi	sp,sp,-32
    800011a2:	ec06                	sd	ra,24(sp)
    800011a4:	e822                	sd	s0,16(sp)
    800011a6:	e426                	sd	s1,8(sp)
    800011a8:	e04a                	sd	s2,0(sp)
    800011aa:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011ac:	9ffff0ef          	jal	ra,80000baa <kalloc>
    800011b0:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011b2:	6605                	lui	a2,0x1
    800011b4:	4581                	li	a1,0
    800011b6:	bbfff0ef          	jal	ra,80000d74 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ba:	4719                	li	a4,6
    800011bc:	6685                	lui	a3,0x1
    800011be:	10000637          	lui	a2,0x10000
    800011c2:	100005b7          	lui	a1,0x10000
    800011c6:	8526                	mv	a0,s1
    800011c8:	fb1ff0ef          	jal	ra,80001178 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011cc:	4719                	li	a4,6
    800011ce:	6685                	lui	a3,0x1
    800011d0:	10001637          	lui	a2,0x10001
    800011d4:	100015b7          	lui	a1,0x10001
    800011d8:	8526                	mv	a0,s1
    800011da:	f9fff0ef          	jal	ra,80001178 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011de:	4719                	li	a4,6
    800011e0:	040006b7          	lui	a3,0x4000
    800011e4:	0c000637          	lui	a2,0xc000
    800011e8:	0c0005b7          	lui	a1,0xc000
    800011ec:	8526                	mv	a0,s1
    800011ee:	f8bff0ef          	jal	ra,80001178 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f2:	00007917          	auipc	s2,0x7
    800011f6:	e0e90913          	addi	s2,s2,-498 # 80008000 <etext>
    800011fa:	4729                	li	a4,10
    800011fc:	80007697          	auipc	a3,0x80007
    80001200:	e0468693          	addi	a3,a3,-508 # 8000 <_entry-0x7fff8000>
    80001204:	4605                	li	a2,1
    80001206:	067e                	slli	a2,a2,0x1f
    80001208:	85b2                	mv	a1,a2
    8000120a:	8526                	mv	a0,s1
    8000120c:	f6dff0ef          	jal	ra,80001178 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001210:	4719                	li	a4,6
    80001212:	46c5                	li	a3,17
    80001214:	06ee                	slli	a3,a3,0x1b
    80001216:	412686b3          	sub	a3,a3,s2
    8000121a:	864a                	mv	a2,s2
    8000121c:	85ca                	mv	a1,s2
    8000121e:	8526                	mv	a0,s1
    80001220:	f59ff0ef          	jal	ra,80001178 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001224:	4729                	li	a4,10
    80001226:	6685                	lui	a3,0x1
    80001228:	00006617          	auipc	a2,0x6
    8000122c:	dd860613          	addi	a2,a2,-552 # 80007000 <_trampoline>
    80001230:	040005b7          	lui	a1,0x4000
    80001234:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001236:	05b2                	slli	a1,a1,0xc
    80001238:	8526                	mv	a0,s1
    8000123a:	f3fff0ef          	jal	ra,80001178 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	7aa000ef          	jal	ra,800019ea <proc_mapstacks>
}
    80001244:	8526                	mv	a0,s1
    80001246:	60e2                	ld	ra,24(sp)
    80001248:	6442                	ld	s0,16(sp)
    8000124a:	64a2                	ld	s1,8(sp)
    8000124c:	6902                	ld	s2,0(sp)
    8000124e:	6105                	addi	sp,sp,32
    80001250:	8082                	ret

0000000080001252 <kvminit>:
{
    80001252:	1141                	addi	sp,sp,-16
    80001254:	e406                	sd	ra,8(sp)
    80001256:	e022                	sd	s0,0(sp)
    80001258:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125a:	f47ff0ef          	jal	ra,800011a0 <kvmmake>
    8000125e:	00007797          	auipc	a5,0x7
    80001262:	62a7bd23          	sd	a0,1594(a5) # 80008898 <kernel_pagetable>
}
    80001266:	60a2                	ld	ra,8(sp)
    80001268:	6402                	ld	s0,0(sp)
    8000126a:	0141                	addi	sp,sp,16
    8000126c:	8082                	ret

000000008000126e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000126e:	1101                	addi	sp,sp,-32
    80001270:	ec06                	sd	ra,24(sp)
    80001272:	e822                	sd	s0,16(sp)
    80001274:	e426                	sd	s1,8(sp)
    80001276:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001278:	933ff0ef          	jal	ra,80000baa <kalloc>
    8000127c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000127e:	c509                	beqz	a0,80001288 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001280:	6605                	lui	a2,0x1
    80001282:	4581                	li	a1,0
    80001284:	af1ff0ef          	jal	ra,80000d74 <memset>
  return pagetable;
}
    80001288:	8526                	mv	a0,s1
    8000128a:	60e2                	ld	ra,24(sp)
    8000128c:	6442                	ld	s0,16(sp)
    8000128e:	64a2                	ld	s1,8(sp)
    80001290:	6105                	addi	sp,sp,32
    80001292:	8082                	ret

0000000080001294 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001294:	7139                	addi	sp,sp,-64
    80001296:	fc06                	sd	ra,56(sp)
    80001298:	f822                	sd	s0,48(sp)
    8000129a:	f426                	sd	s1,40(sp)
    8000129c:	f04a                	sd	s2,32(sp)
    8000129e:	ec4e                	sd	s3,24(sp)
    800012a0:	e852                	sd	s4,16(sp)
    800012a2:	e456                	sd	s5,8(sp)
    800012a4:	e05a                	sd	s6,0(sp)
    800012a6:	0080                	addi	s0,sp,64
  
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012a8:	03459793          	slli	a5,a1,0x34
    800012ac:	e785                	bnez	a5,800012d4 <uvmunmap+0x40>
    800012ae:	8a2a                	mv	s4,a0
    800012b0:	892e                	mv	s2,a1
    800012b2:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012b4:	0632                	slli	a2,a2,0xc
    800012b6:	00b609b3          	add	s3,a2,a1
    800012ba:	6b05                	lui	s6,0x1
    800012bc:	0335e763          	bltu	a1,s3,800012ea <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012c0:	70e2                	ld	ra,56(sp)
    800012c2:	7442                	ld	s0,48(sp)
    800012c4:	74a2                	ld	s1,40(sp)
    800012c6:	7902                	ld	s2,32(sp)
    800012c8:	69e2                	ld	s3,24(sp)
    800012ca:	6a42                	ld	s4,16(sp)
    800012cc:	6aa2                	ld	s5,8(sp)
    800012ce:	6b02                	ld	s6,0(sp)
    800012d0:	6121                	addi	sp,sp,64
    800012d2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80008140 <digits+0x108>
    800012dc:	cacff0ef          	jal	ra,80000788 <panic>
    *pte = 0;
    800012e0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e4:	995a                	add	s2,s2,s6
    800012e6:	fd397de3          	bgeu	s2,s3,800012c0 <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800012ea:	4601                	li	a2,0
    800012ec:	85ca                	mv	a1,s2
    800012ee:	8552                	mv	a0,s4
    800012f0:	d01ff0ef          	jal	ra,80000ff0 <walk>
    800012f4:	84aa                	mv	s1,a0
    800012f6:	d57d                	beqz	a0,800012e4 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800012f8:	611c                	ld	a5,0(a0)
    800012fa:	0017f713          	andi	a4,a5,1
    800012fe:	d37d                	beqz	a4,800012e4 <uvmunmap+0x50>
    if(do_free){
    80001300:	fe0a80e3          	beqz	s5,800012e0 <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    80001304:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001306:	00c79513          	slli	a0,a5,0xc
    8000130a:	f70ff0ef          	jal	ra,80000a7a <kfree>
    8000130e:	bfc9                	j	800012e0 <uvmunmap+0x4c>

0000000080001310 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001310:	1101                	addi	sp,sp,-32
    80001312:	ec06                	sd	ra,24(sp)
    80001314:	e822                	sd	s0,16(sp)
    80001316:	e426                	sd	s1,8(sp)
    80001318:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000131a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000131c:	00b67d63          	bgeu	a2,a1,80001336 <uvmdealloc+0x26>
    80001320:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001322:	6785                	lui	a5,0x1
    80001324:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001326:	00f60733          	add	a4,a2,a5
    8000132a:	76fd                	lui	a3,0xfffff
    8000132c:	8f75                	and	a4,a4,a3
    8000132e:	97ae                	add	a5,a5,a1
    80001330:	8ff5                	and	a5,a5,a3
    80001332:	00f76863          	bltu	a4,a5,80001342 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001336:	8526                	mv	a0,s1
    80001338:	60e2                	ld	ra,24(sp)
    8000133a:	6442                	ld	s0,16(sp)
    8000133c:	64a2                	ld	s1,8(sp)
    8000133e:	6105                	addi	sp,sp,32
    80001340:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001342:	8f99                	sub	a5,a5,a4
    80001344:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001346:	4685                	li	a3,1
    80001348:	0007861b          	sext.w	a2,a5
    8000134c:	85ba                	mv	a1,a4
    8000134e:	f47ff0ef          	jal	ra,80001294 <uvmunmap>
    80001352:	b7d5                	j	80001336 <uvmdealloc+0x26>

0000000080001354 <uvmalloc>:
  if(newsz < oldsz)
    80001354:	08b66963          	bltu	a2,a1,800013e6 <uvmalloc+0x92>
{
    80001358:	7139                	addi	sp,sp,-64
    8000135a:	fc06                	sd	ra,56(sp)
    8000135c:	f822                	sd	s0,48(sp)
    8000135e:	f426                	sd	s1,40(sp)
    80001360:	f04a                	sd	s2,32(sp)
    80001362:	ec4e                	sd	s3,24(sp)
    80001364:	e852                	sd	s4,16(sp)
    80001366:	e456                	sd	s5,8(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	0080                	addi	s0,sp,64
    8000136c:	8aaa                	mv	s5,a0
    8000136e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001370:	6785                	lui	a5,0x1
    80001372:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001374:	95be                	add	a1,a1,a5
    80001376:	77fd                	lui	a5,0xfffff
    80001378:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000137c:	06c9f763          	bgeu	s3,a2,800013ea <uvmalloc+0x96>
    80001380:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001382:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001386:	825ff0ef          	jal	ra,80000baa <kalloc>
    8000138a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000138c:	c11d                	beqz	a0,800013b2 <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	9e3ff0ef          	jal	ra,80000d74 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001396:	875a                	mv	a4,s6
    80001398:	86a6                	mv	a3,s1
    8000139a:	6605                	lui	a2,0x1
    8000139c:	85ca                	mv	a1,s2
    8000139e:	8556                	mv	a0,s5
    800013a0:	d29ff0ef          	jal	ra,800010c8 <mappages>
    800013a4:	e51d                	bnez	a0,800013d2 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013a6:	6785                	lui	a5,0x1
    800013a8:	993e                	add	s2,s2,a5
    800013aa:	fd496ee3          	bltu	s2,s4,80001386 <uvmalloc+0x32>
  return newsz;
    800013ae:	8552                	mv	a0,s4
    800013b0:	a039                	j	800013be <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    800013b2:	864e                	mv	a2,s3
    800013b4:	85ca                	mv	a1,s2
    800013b6:	8556                	mv	a0,s5
    800013b8:	f59ff0ef          	jal	ra,80001310 <uvmdealloc>
      return 0;
    800013bc:	4501                	li	a0,0
}
    800013be:	70e2                	ld	ra,56(sp)
    800013c0:	7442                	ld	s0,48(sp)
    800013c2:	74a2                	ld	s1,40(sp)
    800013c4:	7902                	ld	s2,32(sp)
    800013c6:	69e2                	ld	s3,24(sp)
    800013c8:	6a42                	ld	s4,16(sp)
    800013ca:	6aa2                	ld	s5,8(sp)
    800013cc:	6b02                	ld	s6,0(sp)
    800013ce:	6121                	addi	sp,sp,64
    800013d0:	8082                	ret
      kfree(mem);
    800013d2:	8526                	mv	a0,s1
    800013d4:	ea6ff0ef          	jal	ra,80000a7a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013d8:	864e                	mv	a2,s3
    800013da:	85ca                	mv	a1,s2
    800013dc:	8556                	mv	a0,s5
    800013de:	f33ff0ef          	jal	ra,80001310 <uvmdealloc>
      return 0;
    800013e2:	4501                	li	a0,0
    800013e4:	bfe9                	j	800013be <uvmalloc+0x6a>
    return oldsz;
    800013e6:	852e                	mv	a0,a1
}
    800013e8:	8082                	ret
  return newsz;
    800013ea:	8532                	mv	a0,a2
    800013ec:	bfc9                	j	800013be <uvmalloc+0x6a>

00000000800013ee <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013ee:	7179                	addi	sp,sp,-48
    800013f0:	f406                	sd	ra,40(sp)
    800013f2:	f022                	sd	s0,32(sp)
    800013f4:	ec26                	sd	s1,24(sp)
    800013f6:	e84a                	sd	s2,16(sp)
    800013f8:	e44e                	sd	s3,8(sp)
    800013fa:	e052                	sd	s4,0(sp)
    800013fc:	1800                	addi	s0,sp,48
    800013fe:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001400:	84aa                	mv	s1,a0
    80001402:	6905                	lui	s2,0x1
    80001404:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001406:	4985                	li	s3,1
    80001408:	a819                	j	8000141e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000140a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000140c:	00c79513          	slli	a0,a5,0xc
    80001410:	fdfff0ef          	jal	ra,800013ee <freewalk>
      pagetable[i] = 0;
    80001414:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001418:	04a1                	addi	s1,s1,8
    8000141a:	01248f63          	beq	s1,s2,80001438 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000141e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001420:	00f7f713          	andi	a4,a5,15
    80001424:	ff3703e3          	beq	a4,s3,8000140a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001428:	8b85                	andi	a5,a5,1
    8000142a:	d7fd                	beqz	a5,80001418 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000142c:	00007517          	auipc	a0,0x7
    80001430:	d2c50513          	addi	a0,a0,-724 # 80008158 <digits+0x120>
    80001434:	b54ff0ef          	jal	ra,80000788 <panic>
    }
  }
  kfree((void*)pagetable);
    80001438:	8552                	mv	a0,s4
    8000143a:	e40ff0ef          	jal	ra,80000a7a <kfree>
}
    8000143e:	70a2                	ld	ra,40(sp)
    80001440:	7402                	ld	s0,32(sp)
    80001442:	64e2                	ld	s1,24(sp)
    80001444:	6942                	ld	s2,16(sp)
    80001446:	69a2                	ld	s3,8(sp)
    80001448:	6a02                	ld	s4,0(sp)
    8000144a:	6145                	addi	sp,sp,48
    8000144c:	8082                	ret

000000008000144e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000144e:	1101                	addi	sp,sp,-32
    80001450:	ec06                	sd	ra,24(sp)
    80001452:	e822                	sd	s0,16(sp)
    80001454:	e426                	sd	s1,8(sp)
    80001456:	1000                	addi	s0,sp,32
    80001458:	84aa                	mv	s1,a0
  if(sz > 0)
    8000145a:	e989                	bnez	a1,8000146c <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000145c:	8526                	mv	a0,s1
    8000145e:	f91ff0ef          	jal	ra,800013ee <freewalk>
}
    80001462:	60e2                	ld	ra,24(sp)
    80001464:	6442                	ld	s0,16(sp)
    80001466:	64a2                	ld	s1,8(sp)
    80001468:	6105                	addi	sp,sp,32
    8000146a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000146c:	6785                	lui	a5,0x1
    8000146e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001470:	95be                	add	a1,a1,a5
    80001472:	4685                	li	a3,1
    80001474:	00c5d613          	srli	a2,a1,0xc
    80001478:	4581                	li	a1,0
    8000147a:	e1bff0ef          	jal	ra,80001294 <uvmunmap>
    8000147e:	bff9                	j	8000145c <uvmfree+0xe>

0000000080001480 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001480:	ce55                	beqz	a2,8000153c <uvmcopy+0xbc>
{
    80001482:	715d                	addi	sp,sp,-80
    80001484:	e486                	sd	ra,72(sp)
    80001486:	e0a2                	sd	s0,64(sp)
    80001488:	fc26                	sd	s1,56(sp)
    8000148a:	f84a                	sd	s2,48(sp)
    8000148c:	f44e                	sd	s3,40(sp)
    8000148e:	f052                	sd	s4,32(sp)
    80001490:	ec56                	sd	s5,24(sp)
    80001492:	e85a                	sd	s6,16(sp)
    80001494:	e45e                	sd	s7,8(sp)
    80001496:	0880                	addi	s0,sp,80
    80001498:	8a2a                	mv	s4,a0
    8000149a:	8aae                	mv	s5,a1
    8000149c:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000149e:	4901                	li	s2,0
    if(flags & PTE_W){
      // 子进程和父进程映射要只读 + COW
      flags = (flags & ~PTE_W) | PTE_COW;

      // 父进程也要
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014a0:	7b7d                	lui	s6,0xfffff
    800014a2:	002b5b13          	srli	s6,s6,0x2
    800014a6:	a02d                	j	800014d0 <uvmcopy+0x50>
    pa = PTE2PA(*pte);
    800014a8:	82a9                	srli	a3,a3,0xa
    800014aa:	00c69493          	slli	s1,a3,0xc
    }

    // 共享同一物理页：引用计数 +1
    kref_inc((void*)pa);
    800014ae:	8526                	mv	a0,s1
    800014b0:	d42ff0ef          	jal	ra,800009f2 <kref_inc>

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800014b4:	875e                	mv	a4,s7
    800014b6:	86a6                	mv	a3,s1
    800014b8:	6605                	lui	a2,0x1
    800014ba:	85ca                	mv	a1,s2
    800014bc:	8556                	mv	a0,s5
    800014be:	c0bff0ef          	jal	ra,800010c8 <mappages>
    800014c2:	e529                	bnez	a0,8000150c <uvmcopy+0x8c>
    800014c4:	12000073          	sfence.vma
  for(i = 0; i < sz; i += PGSIZE){
    800014c8:	6785                	lui	a5,0x1
    800014ca:	993e                	add	s2,s2,a5
    800014cc:	05397c63          	bgeu	s2,s3,80001524 <uvmcopy+0xa4>
    pte = walk(old, i, 0);
    800014d0:	4601                	li	a2,0
    800014d2:	85ca                	mv	a1,s2
    800014d4:	8552                	mv	a0,s4
    800014d6:	b1bff0ef          	jal	ra,80000ff0 <walk>
    if(pte == 0)
    800014da:	d57d                	beqz	a0,800014c8 <uvmcopy+0x48>
    if((*pte & PTE_V) == 0)
    800014dc:	6114                	ld	a3,0(a0)
    800014de:	0016f793          	andi	a5,a3,1
    800014e2:	d3fd                	beqz	a5,800014c8 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    800014e4:	0006879b          	sext.w	a5,a3
    if((flags & PTE_U) == 0)
    800014e8:	0106f713          	andi	a4,a3,16
    800014ec:	df71                	beqz	a4,800014c8 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    800014ee:	3ff7fb93          	andi	s7,a5,1023
    if(flags & PTE_W){
    800014f2:	8b91                	andi	a5,a5,4
    800014f4:	dbd5                	beqz	a5,800014a8 <uvmcopy+0x28>
      flags = (flags & ~PTE_W) | PTE_COW;
    800014f6:	efbbf793          	andi	a5,s7,-261
    800014fa:	1007eb93          	ori	s7,a5,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014fe:	0166f733          	and	a4,a3,s6
    80001502:	8fd9                	or	a5,a5,a4
    80001504:	1017e793          	ori	a5,a5,257
    80001508:	e11c                	sd	a5,0(a0)
    8000150a:	bf79                	j	800014a8 <uvmcopy+0x28>
      // map 失败要回滚 refcnt
      kref_dec((void*)pa);
    8000150c:	8526                	mv	a0,s1
    8000150e:	d28ff0ef          	jal	ra,80000a36 <kref_dec>
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调 kfree()， kfree 再对 refcnt--。
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001512:	4685                	li	a3,1
    80001514:	00c95613          	srli	a2,s2,0xc
    80001518:	4581                	li	a1,0
    8000151a:	8556                	mv	a0,s5
    8000151c:	d79ff0ef          	jal	ra,80001294 <uvmunmap>
  return -1;
    80001520:	557d                	li	a0,-1
    80001522:	a011                	j	80001526 <uvmcopy+0xa6>
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	60a6                	ld	ra,72(sp)
    80001528:	6406                	ld	s0,64(sp)
    8000152a:	74e2                	ld	s1,56(sp)
    8000152c:	7942                	ld	s2,48(sp)
    8000152e:	79a2                	ld	s3,40(sp)
    80001530:	7a02                	ld	s4,32(sp)
    80001532:	6ae2                	ld	s5,24(sp)
    80001534:	6b42                	ld	s6,16(sp)
    80001536:	6ba2                	ld	s7,8(sp)
    80001538:	6161                	addi	sp,sp,80
    8000153a:	8082                	ret
  return 0;
    8000153c:	4501                	li	a0,0
}
    8000153e:	8082                	ret

0000000080001540 <cowbreak>:
int
cowbreak(pagetable_t pagetable, uint64 va)
{
    80001540:	7179                	addi	sp,sp,-48
    80001542:	f406                	sd	ra,40(sp)
    80001544:	f022                	sd	s0,32(sp)
    80001546:	ec26                	sd	s1,24(sp)
    80001548:	e84a                	sd	s2,16(sp)
    8000154a:	e44e                	sd	s3,8(sp)
    8000154c:	e052                	sd	s4,0(sp)
    8000154e:	1800                	addi	s0,sp,48
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
    80001550:	4601                	li	a2,0
    80001552:	77fd                	lui	a5,0xfffff
    80001554:	8dfd                	and	a1,a1,a5
    80001556:	a9bff0ef          	jal	ra,80000ff0 <walk>
  if(pte == 0)
    8000155a:	cd41                	beqz	a0,800015f2 <cowbreak+0xb2>
    8000155c:	89aa                	mv	s3,a0
    return -1;
  if((*pte & PTE_V) == 0)
    8000155e:	6104                	ld	s1,0(a0)
    return -1;
  if((*pte & PTE_U) == 0)
    80001560:	0114f713          	andi	a4,s1,17
    80001564:	47c5                	li	a5,17
    80001566:	08f71863          	bne	a4,a5,800015f6 <cowbreak+0xb6>
    return -1;

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    8000156a:	1044f793          	andi	a5,s1,260
    8000156e:	10000713          	li	a4,256
    80001572:	08e79463          	bne	a5,a4,800015fa <cowbreak+0xba>
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);
    80001576:	3ff4f913          	andi	s2,s1,1023
  uint64 pa_old = PTE2PA(*pte);
    8000157a:	00a4da13          	srli	s4,s1,0xa
    8000157e:	0a32                	slli	s4,s4,0xc

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    80001580:	8552                	mv	a0,s4
    80001582:	c36ff0ef          	jal	ra,800009b8 <kref_get>
    80001586:	4785                	li	a5,1
    80001588:	04f50463          	beq	a0,a5,800015d0 <cowbreak+0x90>
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    sfence_vma();
    return 0;
  }

  char *mem = kalloc();
    8000158c:	e1eff0ef          	jal	ra,80000baa <kalloc>
    80001590:	84aa                	mv	s1,a0
  if(mem == 0)
    80001592:	c535                	beqz	a0,800015fe <cowbreak+0xbe>
    return -1;

  memmove(mem, (void*)pa_old, PGSIZE);
    80001594:	6605                	lui	a2,0x1
    80001596:	85d2                	mv	a1,s4
    80001598:	839ff0ef          	jal	ra,80000dd0 <memmove>

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);
    8000159c:	8552                	mv	a0,s4
    8000159e:	c98ff0ef          	jal	ra,80000a36 <kref_dec>

  // 更新 PTE：指向新页，变可写，清掉 COW
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015a2:	80b1                	srli	s1,s1,0xc
    800015a4:	04aa                	slli	s1,s1,0xa
    800015a6:	00496913          	ori	s2,s2,4
    800015aa:	eff97913          	andi	s2,s2,-257
    800015ae:	0124e4b3          	or	s1,s1,s2
    800015b2:	0014e493          	ori	s1,s1,1
    800015b6:	0099b023          	sd	s1,0(s3)
    800015ba:	12000073          	sfence.vma

  sfence_vma();
  return 0;
    800015be:	4501                	li	a0,0
}
    800015c0:	70a2                	ld	ra,40(sp)
    800015c2:	7402                	ld	s0,32(sp)
    800015c4:	64e2                	ld	s1,24(sp)
    800015c6:	6942                	ld	s2,16(sp)
    800015c8:	69a2                	ld	s3,8(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	6145                	addi	sp,sp,48
    800015ce:	8082                	ret
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015d0:	00496913          	ori	s2,s2,4
    800015d4:	eff97913          	andi	s2,s2,-257
    800015d8:	77fd                	lui	a5,0xfffff
    800015da:	8389                	srli	a5,a5,0x2
    800015dc:	8cfd                	and	s1,s1,a5
    800015de:	00996933          	or	s2,s2,s1
    800015e2:	00196913          	ori	s2,s2,1
    800015e6:	0129b023          	sd	s2,0(s3)
    800015ea:	12000073          	sfence.vma
    return 0;
    800015ee:	4501                	li	a0,0
    800015f0:	bfc1                	j	800015c0 <cowbreak+0x80>
    return -1;
    800015f2:	557d                	li	a0,-1
    800015f4:	b7f1                	j	800015c0 <cowbreak+0x80>
    return -1;
    800015f6:	557d                	li	a0,-1
    800015f8:	b7e1                	j	800015c0 <cowbreak+0x80>
    return -1;
    800015fa:	557d                	li	a0,-1
    800015fc:	b7d1                	j	800015c0 <cowbreak+0x80>
    return -1;
    800015fe:	557d                	li	a0,-1
    80001600:	b7c1                	j	800015c0 <cowbreak+0x80>

0000000080001602 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001602:	1141                	addi	sp,sp,-16
    80001604:	e406                	sd	ra,8(sp)
    80001606:	e022                	sd	s0,0(sp)
    80001608:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000160a:	4601                	li	a2,0
    8000160c:	9e5ff0ef          	jal	ra,80000ff0 <walk>
  if(pte == 0)
    80001610:	c901                	beqz	a0,80001620 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001612:	611c                	ld	a5,0(a0)
    80001614:	9bbd                	andi	a5,a5,-17
    80001616:	e11c                	sd	a5,0(a0)
}
    80001618:	60a2                	ld	ra,8(sp)
    8000161a:	6402                	ld	s0,0(sp)
    8000161c:	0141                	addi	sp,sp,16
    8000161e:	8082                	ret
    panic("uvmclear");
    80001620:	00007517          	auipc	a0,0x7
    80001624:	b4850513          	addi	a0,a0,-1208 # 80008168 <digits+0x130>
    80001628:	960ff0ef          	jal	ra,80000788 <panic>

000000008000162c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000162c:	c2cd                	beqz	a3,800016ce <copyinstr+0xa2>
{
    8000162e:	715d                	addi	sp,sp,-80
    80001630:	e486                	sd	ra,72(sp)
    80001632:	e0a2                	sd	s0,64(sp)
    80001634:	fc26                	sd	s1,56(sp)
    80001636:	f84a                	sd	s2,48(sp)
    80001638:	f44e                	sd	s3,40(sp)
    8000163a:	f052                	sd	s4,32(sp)
    8000163c:	ec56                	sd	s5,24(sp)
    8000163e:	e85a                	sd	s6,16(sp)
    80001640:	e45e                	sd	s7,8(sp)
    80001642:	0880                	addi	s0,sp,80
    80001644:	8a2a                	mv	s4,a0
    80001646:	8b2e                	mv	s6,a1
    80001648:	8bb2                	mv	s7,a2
    8000164a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000164c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164e:	6985                	lui	s3,0x1
    80001650:	a02d                	j	8000167a <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001652:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdab298>
    80001656:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001658:	37fd                	addiw	a5,a5,-1
    8000165a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000165e:	60a6                	ld	ra,72(sp)
    80001660:	6406                	ld	s0,64(sp)
    80001662:	74e2                	ld	s1,56(sp)
    80001664:	7942                	ld	s2,48(sp)
    80001666:	79a2                	ld	s3,40(sp)
    80001668:	7a02                	ld	s4,32(sp)
    8000166a:	6ae2                	ld	s5,24(sp)
    8000166c:	6b42                	ld	s6,16(sp)
    8000166e:	6ba2                	ld	s7,8(sp)
    80001670:	6161                	addi	sp,sp,80
    80001672:	8082                	ret
    srcva = va0 + PGSIZE;
    80001674:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001678:	c4b9                	beqz	s1,800016c6 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    8000167a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000167e:	85ca                	mv	a1,s2
    80001680:	8552                	mv	a0,s4
    80001682:	a09ff0ef          	jal	ra,8000108a <walkaddr>
    if(pa0 == 0)
    80001686:	c131                	beqz	a0,800016ca <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80001688:	417906b3          	sub	a3,s2,s7
    8000168c:	96ce                	add	a3,a3,s3
    8000168e:	00d4f363          	bgeu	s1,a3,80001694 <copyinstr+0x68>
    80001692:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001694:	955e                	add	a0,a0,s7
    80001696:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000169a:	dee9                	beqz	a3,80001674 <copyinstr+0x48>
    8000169c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000169e:	41650633          	sub	a2,a0,s6
    800016a2:	fff48593          	addi	a1,s1,-1
    800016a6:	95da                	add	a1,a1,s6
    while(n > 0){
    800016a8:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800016aa:	00f60733          	add	a4,a2,a5
    800016ae:	00074703          	lbu	a4,0(a4)
    800016b2:	d345                	beqz	a4,80001652 <copyinstr+0x26>
        *dst = *p;
    800016b4:	00e78023          	sb	a4,0(a5)
      --max;
    800016b8:	40f584b3          	sub	s1,a1,a5
      dst++;
    800016bc:	0785                	addi	a5,a5,1
    while(n > 0){
    800016be:	fed796e3          	bne	a5,a3,800016aa <copyinstr+0x7e>
      dst++;
    800016c2:	8b3e                	mv	s6,a5
    800016c4:	bf45                	j	80001674 <copyinstr+0x48>
    800016c6:	4781                	li	a5,0
    800016c8:	bf41                	j	80001658 <copyinstr+0x2c>
      return -1;
    800016ca:	557d                	li	a0,-1
    800016cc:	bf49                	j	8000165e <copyinstr+0x32>
  int got_null = 0;
    800016ce:	4781                	li	a5,0
  if(got_null){
    800016d0:	37fd                	addiw	a5,a5,-1
    800016d2:	0007851b          	sext.w	a0,a5
}
    800016d6:	8082                	ret

00000000800016d8 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800016d8:	1141                	addi	sp,sp,-16
    800016da:	e406                	sd	ra,8(sp)
    800016dc:	e022                	sd	s0,0(sp)
    800016de:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800016e0:	4601                	li	a2,0
    800016e2:	90fff0ef          	jal	ra,80000ff0 <walk>
  if (pte == 0) {
    800016e6:	c519                	beqz	a0,800016f4 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800016e8:	6108                	ld	a0,0(a0)
    return 0;
    800016ea:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800016ec:	60a2                	ld	ra,8(sp)
    800016ee:	6402                	ld	s0,0(sp)
    800016f0:	0141                	addi	sp,sp,16
    800016f2:	8082                	ret
    return 0;
    800016f4:	4501                	li	a0,0
    800016f6:	bfdd                	j	800016ec <ismapped+0x14>

00000000800016f8 <vmfault>:
{
    800016f8:	7179                	addi	sp,sp,-48
    800016fa:	f406                	sd	ra,40(sp)
    800016fc:	f022                	sd	s0,32(sp)
    800016fe:	ec26                	sd	s1,24(sp)
    80001700:	e84a                	sd	s2,16(sp)
    80001702:	e44e                	sd	s3,8(sp)
    80001704:	e052                	sd	s4,0(sp)
    80001706:	1800                	addi	s0,sp,48
    80001708:	89aa                	mv	s3,a0
    8000170a:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000170c:	43c000ef          	jal	ra,80001b48 <myproc>
  if (va >= p->sz)
    80001710:	653c                	ld	a5,72(a0)
    80001712:	00f4ec63          	bltu	s1,a5,8000172a <vmfault+0x32>
    return 0;
    80001716:	4981                	li	s3,0
}
    80001718:	854e                	mv	a0,s3
    8000171a:	70a2                	ld	ra,40(sp)
    8000171c:	7402                	ld	s0,32(sp)
    8000171e:	64e2                	ld	s1,24(sp)
    80001720:	6942                	ld	s2,16(sp)
    80001722:	69a2                	ld	s3,8(sp)
    80001724:	6a02                	ld	s4,0(sp)
    80001726:	6145                	addi	sp,sp,48
    80001728:	8082                	ret
    8000172a:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000172c:	77fd                	lui	a5,0xfffff
    8000172e:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001730:	85a6                	mv	a1,s1
    80001732:	854e                	mv	a0,s3
    80001734:	fa5ff0ef          	jal	ra,800016d8 <ismapped>
    return 0;
    80001738:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000173a:	fd79                	bnez	a0,80001718 <vmfault+0x20>
  mem = (uint64) kalloc();
    8000173c:	c6eff0ef          	jal	ra,80000baa <kalloc>
    80001740:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001742:	d979                	beqz	a0,80001718 <vmfault+0x20>
  mem = (uint64) kalloc();
    80001744:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001746:	6605                	lui	a2,0x1
    80001748:	4581                	li	a1,0
    8000174a:	e2aff0ef          	jal	ra,80000d74 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000174e:	4759                	li	a4,22
    80001750:	86d2                	mv	a3,s4
    80001752:	6605                	lui	a2,0x1
    80001754:	85a6                	mv	a1,s1
    80001756:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    8000175a:	96fff0ef          	jal	ra,800010c8 <mappages>
    8000175e:	dd4d                	beqz	a0,80001718 <vmfault+0x20>
    kfree((void *)mem);
    80001760:	8552                	mv	a0,s4
    80001762:	b18ff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    80001766:	4981                	li	s3,0
    80001768:	bf45                	j	80001718 <vmfault+0x20>

000000008000176a <copyout>:
  while(len > 0){
    8000176a:	c6e1                	beqz	a3,80001832 <copyout+0xc8>
{
    8000176c:	711d                	addi	sp,sp,-96
    8000176e:	ec86                	sd	ra,88(sp)
    80001770:	e8a2                	sd	s0,80(sp)
    80001772:	e4a6                	sd	s1,72(sp)
    80001774:	e0ca                	sd	s2,64(sp)
    80001776:	fc4e                	sd	s3,56(sp)
    80001778:	f852                	sd	s4,48(sp)
    8000177a:	f456                	sd	s5,40(sp)
    8000177c:	f05a                	sd	s6,32(sp)
    8000177e:	ec5e                	sd	s7,24(sp)
    80001780:	e862                	sd	s8,16(sp)
    80001782:	e466                	sd	s9,8(sp)
    80001784:	e06a                	sd	s10,0(sp)
    80001786:	1080                	addi	s0,sp,96
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8bae                	mv	s7,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001790:	74fd                	lui	s1,0xfffff
    80001792:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001794:	57fd                	li	a5,-1
    80001796:	83e9                	srli	a5,a5,0x1a
    80001798:	0897ef63          	bltu	a5,s1,80001836 <copyout+0xcc>
    8000179c:	6d05                	lui	s10,0x1
    8000179e:	8cbe                	mv	s9,a5
    800017a0:	a82d                	j	800017da <copyout+0x70>
    if((*pte & PTE_W) == 0)
    800017a2:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
    800017a6:	8b91                	andi	a5,a5,4
    800017a8:	cfd9                	beqz	a5,80001846 <copyout+0xdc>
    n = PGSIZE - (dstva - va0);
    800017aa:	01a48a33          	add	s4,s1,s10
    800017ae:	417a09b3          	sub	s3,s4,s7
    800017b2:	013af363          	bgeu	s5,s3,800017b8 <copyout+0x4e>
    800017b6:	89d6                	mv	s3,s5
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017b8:	409b8533          	sub	a0,s7,s1
    800017bc:	0009861b          	sext.w	a2,s3
    800017c0:	85e2                	mv	a1,s8
    800017c2:	954a                	add	a0,a0,s2
    800017c4:	e0cff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    800017c8:	413a8ab3          	sub	s5,s5,s3
    src += n;
    800017cc:	9c4e                	add	s8,s8,s3
  while(len > 0){
    800017ce:	060a8063          	beqz	s5,8000182e <copyout+0xc4>
    if(va0 >= MAXVA)
    800017d2:	074ce463          	bltu	s9,s4,8000183a <copyout+0xd0>
    va0 = PGROUNDDOWN(dstva);
    800017d6:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    800017d8:	8bd2                	mv	s7,s4
    pa0 = walkaddr(pagetable, va0);
    800017da:	85a6                	mv	a1,s1
    800017dc:	855a                	mv	a0,s6
    800017de:	8adff0ef          	jal	ra,8000108a <walkaddr>
    800017e2:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800017e4:	e901                	bnez	a0,800017f4 <copyout+0x8a>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800017e6:	4601                	li	a2,0
    800017e8:	85a6                	mv	a1,s1
    800017ea:	855a                	mv	a0,s6
    800017ec:	f0dff0ef          	jal	ra,800016f8 <vmfault>
    800017f0:	892a                	mv	s2,a0
    800017f2:	c531                	beqz	a0,8000183e <copyout+0xd4>
    pte = walk(pagetable, va0, 0);
    800017f4:	4601                	li	a2,0
    800017f6:	85a6                	mv	a1,s1
    800017f8:	855a                	mv	a0,s6
    800017fa:	ff6ff0ef          	jal	ra,80000ff0 <walk>
    800017fe:	89aa                	mv	s3,a0
    if(pte && (*pte & PTE_COW)){
    80001800:	d14d                	beqz	a0,800017a2 <copyout+0x38>
    80001802:	611c                	ld	a5,0(a0)
    80001804:	1007f793          	andi	a5,a5,256
    80001808:	dfc9                	beqz	a5,800017a2 <copyout+0x38>
      if(cowbreak(pagetable, va0) < 0)
    8000180a:	85a6                	mv	a1,s1
    8000180c:	855a                	mv	a0,s6
    8000180e:	d33ff0ef          	jal	ra,80001540 <cowbreak>
    80001812:	02054863          	bltz	a0,80001842 <copyout+0xd8>
      pte = walk(pagetable, va0, 0);
    80001816:	4601                	li	a2,0
    80001818:	85a6                	mv	a1,s1
    8000181a:	855a                	mv	a0,s6
    8000181c:	fd4ff0ef          	jal	ra,80000ff0 <walk>
    80001820:	89aa                	mv	s3,a0
      pa0 = walkaddr(pagetable, va0);
    80001822:	85a6                	mv	a1,s1
    80001824:	855a                	mv	a0,s6
    80001826:	865ff0ef          	jal	ra,8000108a <walkaddr>
    8000182a:	892a                	mv	s2,a0
    8000182c:	bf9d                	j	800017a2 <copyout+0x38>
  return 0;
    8000182e:	4501                	li	a0,0
    80001830:	a821                	j	80001848 <copyout+0xde>
    80001832:	4501                	li	a0,0
}
    80001834:	8082                	ret
      return -1;
    80001836:	557d                	li	a0,-1
    80001838:	a801                	j	80001848 <copyout+0xde>
    8000183a:	557d                	li	a0,-1
    8000183c:	a031                	j	80001848 <copyout+0xde>
        return -1;
    8000183e:	557d                	li	a0,-1
    80001840:	a021                	j	80001848 <copyout+0xde>
        return -1;
    80001842:	557d                	li	a0,-1
    80001844:	a011                	j	80001848 <copyout+0xde>
      return -1;
    80001846:	557d                	li	a0,-1
}
    80001848:	60e6                	ld	ra,88(sp)
    8000184a:	6446                	ld	s0,80(sp)
    8000184c:	64a6                	ld	s1,72(sp)
    8000184e:	6906                	ld	s2,64(sp)
    80001850:	79e2                	ld	s3,56(sp)
    80001852:	7a42                	ld	s4,48(sp)
    80001854:	7aa2                	ld	s5,40(sp)
    80001856:	7b02                	ld	s6,32(sp)
    80001858:	6be2                	ld	s7,24(sp)
    8000185a:	6c42                	ld	s8,16(sp)
    8000185c:	6ca2                	ld	s9,8(sp)
    8000185e:	6d02                	ld	s10,0(sp)
    80001860:	6125                	addi	sp,sp,96
    80001862:	8082                	ret

0000000080001864 <copyin>:
  while(len > 0){
    80001864:	c6c9                	beqz	a3,800018ee <copyin+0x8a>
{
    80001866:	715d                	addi	sp,sp,-80
    80001868:	e486                	sd	ra,72(sp)
    8000186a:	e0a2                	sd	s0,64(sp)
    8000186c:	fc26                	sd	s1,56(sp)
    8000186e:	f84a                	sd	s2,48(sp)
    80001870:	f44e                	sd	s3,40(sp)
    80001872:	f052                	sd	s4,32(sp)
    80001874:	ec56                	sd	s5,24(sp)
    80001876:	e85a                	sd	s6,16(sp)
    80001878:	e45e                	sd	s7,8(sp)
    8000187a:	e062                	sd	s8,0(sp)
    8000187c:	0880                	addi	s0,sp,80
    8000187e:	8baa                	mv	s7,a0
    80001880:	8aae                	mv	s5,a1
    80001882:	8932                	mv	s2,a2
    80001884:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001886:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001888:	6b05                	lui	s6,0x1
    8000188a:	a035                	j	800018b6 <copyin+0x52>
    8000188c:	412984b3          	sub	s1,s3,s2
    80001890:	94da                	add	s1,s1,s6
    80001892:	009a7363          	bgeu	s4,s1,80001898 <copyin+0x34>
    80001896:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001898:	413905b3          	sub	a1,s2,s3
    8000189c:	0004861b          	sext.w	a2,s1
    800018a0:	95aa                	add	a1,a1,a0
    800018a2:	8556                	mv	a0,s5
    800018a4:	d2cff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    800018a8:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800018ac:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800018ae:	01698933          	add	s2,s3,s6
  while(len > 0){
    800018b2:	020a0163          	beqz	s4,800018d4 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    800018b6:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800018ba:	85ce                	mv	a1,s3
    800018bc:	855e                	mv	a0,s7
    800018be:	fccff0ef          	jal	ra,8000108a <walkaddr>
    if(pa0 == 0) {
    800018c2:	f569                	bnez	a0,8000188c <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800018c4:	4601                	li	a2,0
    800018c6:	85ce                	mv	a1,s3
    800018c8:	855e                	mv	a0,s7
    800018ca:	e2fff0ef          	jal	ra,800016f8 <vmfault>
    800018ce:	fd5d                	bnez	a0,8000188c <copyin+0x28>
        return -1;
    800018d0:	557d                	li	a0,-1
    800018d2:	a011                	j	800018d6 <copyin+0x72>
  return 0;
    800018d4:	4501                	li	a0,0
}
    800018d6:	60a6                	ld	ra,72(sp)
    800018d8:	6406                	ld	s0,64(sp)
    800018da:	74e2                	ld	s1,56(sp)
    800018dc:	7942                	ld	s2,48(sp)
    800018de:	79a2                	ld	s3,40(sp)
    800018e0:	7a02                	ld	s4,32(sp)
    800018e2:	6ae2                	ld	s5,24(sp)
    800018e4:	6b42                	ld	s6,16(sp)
    800018e6:	6ba2                	ld	s7,8(sp)
    800018e8:	6c02                	ld	s8,0(sp)
    800018ea:	6161                	addi	sp,sp,80
    800018ec:	8082                	ret
  return 0;
    800018ee:	4501                	li	a0,0
}
    800018f0:	8082                	ret

00000000800018f2 <vmafault>:


uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    800018f2:	7139                	addi	sp,sp,-64
    800018f4:	fc06                	sd	ra,56(sp)
    800018f6:	f822                	sd	s0,48(sp)
    800018f8:	f426                	sd	s1,40(sp)
    800018fa:	f04a                	sd	s2,32(sp)
    800018fc:	ec4e                	sd	s3,24(sp)
    800018fe:	e852                	sd	s4,16(sp)
    80001900:	e456                	sd	s5,8(sp)
    80001902:	0080                	addi	s0,sp,64
    80001904:	8a2a                	mv	s4,a0
    80001906:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);
    80001908:	77fd                	lui	a5,0xfffff
    8000190a:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va);
    8000190e:	85ce                	mv	a1,s3
    80001910:	654010ef          	jal	ra,80002f64 <vma_find>
  if(v == 0) return 0;
    80001914:	c569                	beqz	a0,800019de <vmafault+0xec>
    80001916:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001918:	00090663          	beqz	s2,80001924 <vmafault+0x32>
    8000191c:	4d1c                	lw	a5,24(a0)
    8000191e:	8b89                	andi	a5,a5,2
    return 0;
    80001920:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001922:	c789                	beqz	a5,8000192c <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0)
    80001924:	4c9c                	lw	a5,24(s1)
    80001926:	8b85                	andi	a5,a5,1
    return 0;
    80001928:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0)
    8000192a:	eb99                	bnez	a5,80001940 <vmafault+0x4e>
    if(v->is_shm) kref_dec((void*)pa);
    else kfree((void*)pa);
    return 0;
  }
  return (uint64)pa;
}
    8000192c:	854a                	mv	a0,s2
    8000192e:	70e2                	ld	ra,56(sp)
    80001930:	7442                	ld	s0,48(sp)
    80001932:	74a2                	ld	s1,40(sp)
    80001934:	7902                	ld	s2,32(sp)
    80001936:	69e2                	ld	s3,24(sp)
    80001938:	6a42                	ld	s4,16(sp)
    8000193a:	6aa2                	ld	s5,8(sp)
    8000193c:	6121                	addi	sp,sp,64
    8000193e:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    80001940:	4601                	li	a2,0
    80001942:	85ce                	mv	a1,s3
    80001944:	050a3503          	ld	a0,80(s4)
    80001948:	ea8ff0ef          	jal	ra,80000ff0 <walk>
  if(pte && (*pte & PTE_V)){
    8000194c:	c115                	beqz	a0,80001970 <vmafault+0x7e>
    8000194e:	611c                	ld	a5,0(a0)
    80001950:	0017f913          	andi	s2,a5,1
    80001954:	00090e63          	beqz	s2,80001970 <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    80001958:	4c98                	lw	a4,24(s1)
    8000195a:	8b09                	andi	a4,a4,2
    8000195c:	c359                	beqz	a4,800019e2 <vmafault+0xf0>
    8000195e:	0047f713          	andi	a4,a5,4
    80001962:	e351                	bnez	a4,800019e6 <vmafault+0xf4>
      *pte |= PTE_W;
    80001964:	0047e793          	ori	a5,a5,4
    80001968:	e11c                	sd	a5,0(a0)
    8000196a:	12000073          	sfence.vma
      return 1;
    8000196e:	bf7d                	j	8000192c <vmafault+0x3a>
  int idx = (va - v->start) / PGSIZE;
    80001970:	648c                	ld	a1,8(s1)
  if(v->is_shm){
    80001972:	509c                	lw	a5,32(s1)
    80001974:	cf89                	beqz	a5,8000198e <vmafault+0x9c>
  int idx = (va - v->start) / PGSIZE;
    80001976:	40b985b3          	sub	a1,s3,a1
    8000197a:	81b1                	srli	a1,a1,0xc
    pa = shm_getpa(v->shm_key, idx);
    8000197c:	2581                	sext.w	a1,a1
    8000197e:	50c8                	lw	a0,36(s1)
    80001980:	349040ef          	jal	ra,800064c8 <shm_getpa>
    80001984:	892a                	mv	s2,a0
    if(pa == 0) return 0;
    80001986:	d15d                	beqz	a0,8000192c <vmafault+0x3a>
    kref_inc((void*)pa);
    80001988:	86aff0ef          	jal	ra,800009f2 <kref_inc>
    8000198c:	a819                	j	800019a2 <vmafault+0xb0>
    char *mem = kalloc();
    8000198e:	a1cff0ef          	jal	ra,80000baa <kalloc>
    80001992:	8aaa                	mv	s5,a0
    if(mem == 0) return 0;
    80001994:	4901                	li	s2,0
    80001996:	d959                	beqz	a0,8000192c <vmafault+0x3a>
    memset(mem, 0, PGSIZE);
    80001998:	6605                	lui	a2,0x1
    8000199a:	4581                	li	a1,0
    8000199c:	bd8ff0ef          	jal	ra,80000d74 <memset>
    pa = (uint64)mem;
    800019a0:	8956                	mv	s2,s5
  if(v->prot & PROT_READ)  perm |= PTE_R;
    800019a2:	4c9c                	lw	a5,24(s1)
    800019a4:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;
    800019a8:	4741                	li	a4,16
  if(v->prot & PROT_READ)  perm |= PTE_R;
    800019aa:	c291                	beqz	a3,800019ae <vmafault+0xbc>
    800019ac:	4749                	li	a4,18
  if(v->prot & PROT_WRITE) perm |= PTE_W;
    800019ae:	8b89                	andi	a5,a5,2
    800019b0:	c399                	beqz	a5,800019b6 <vmafault+0xc4>
    800019b2:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    800019b6:	86ca                	mv	a3,s2
    800019b8:	6605                	lui	a2,0x1
    800019ba:	85ce                	mv	a1,s3
    800019bc:	050a3503          	ld	a0,80(s4)
    800019c0:	f08ff0ef          	jal	ra,800010c8 <mappages>
    800019c4:	d525                	beqz	a0,8000192c <vmafault+0x3a>
    if(v->is_shm) kref_dec((void*)pa);
    800019c6:	509c                	lw	a5,32(s1)
    800019c8:	c791                	beqz	a5,800019d4 <vmafault+0xe2>
    800019ca:	854a                	mv	a0,s2
    800019cc:	86aff0ef          	jal	ra,80000a36 <kref_dec>
    return 0;
    800019d0:	4901                	li	s2,0
    800019d2:	bfa9                	j	8000192c <vmafault+0x3a>
    else kfree((void*)pa);
    800019d4:	854a                	mv	a0,s2
    800019d6:	8a4ff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    800019da:	4901                	li	s2,0
    800019dc:	bf81                	j	8000192c <vmafault+0x3a>
  if(v == 0) return 0;
    800019de:	4901                	li	s2,0
    800019e0:	b7b1                	j	8000192c <vmafault+0x3a>
    return 0;
    800019e2:	4901                	li	s2,0
    800019e4:	b7a1                	j	8000192c <vmafault+0x3a>
    800019e6:	4901                	li	s2,0
    800019e8:	b791                	j	8000192c <vmafault+0x3a>

00000000800019ea <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800019ea:	7139                	addi	sp,sp,-64
    800019ec:	fc06                	sd	ra,56(sp)
    800019ee:	f822                	sd	s0,48(sp)
    800019f0:	f426                	sd	s1,40(sp)
    800019f2:	f04a                	sd	s2,32(sp)
    800019f4:	ec4e                	sd	s3,24(sp)
    800019f6:	e852                	sd	s4,16(sp)
    800019f8:	e456                	sd	s5,8(sp)
    800019fa:	e05a                	sd	s6,0(sp)
    800019fc:	0080                	addi	s0,sp,64
    800019fe:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a00:	0022f497          	auipc	s1,0x22f
    80001a04:	3f048493          	addi	s1,s1,1008 # 80230df0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a08:	8b26                	mv	s6,s1
    80001a0a:	00006a97          	auipc	s5,0x6
    80001a0e:	5f6a8a93          	addi	s5,s5,1526 # 80008000 <etext>
    80001a12:	04000937          	lui	s2,0x4000
    80001a16:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a18:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a1a:	0023fa17          	auipc	s4,0x23f
    80001a1e:	dd6a0a13          	addi	s4,s4,-554 # 802407f0 <tickslock>
    char *pa = kalloc();
    80001a22:	988ff0ef          	jal	ra,80000baa <kalloc>
    80001a26:	862a                	mv	a2,a0
    if(pa == 0)
    80001a28:	c121                	beqz	a0,80001a68 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001a2a:	416485b3          	sub	a1,s1,s6
    80001a2e:	858d                	srai	a1,a1,0x3
    80001a30:	000ab783          	ld	a5,0(s5)
    80001a34:	02f585b3          	mul	a1,a1,a5
    80001a38:	2585                	addiw	a1,a1,1
    80001a3a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a3e:	4719                	li	a4,6
    80001a40:	6685                	lui	a3,0x1
    80001a42:	40b905b3          	sub	a1,s2,a1
    80001a46:	854e                	mv	a0,s3
    80001a48:	f30ff0ef          	jal	ra,80001178 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a4c:	3e848493          	addi	s1,s1,1000
    80001a50:	fd4499e3          	bne	s1,s4,80001a22 <proc_mapstacks+0x38>
  }
}
    80001a54:	70e2                	ld	ra,56(sp)
    80001a56:	7442                	ld	s0,48(sp)
    80001a58:	74a2                	ld	s1,40(sp)
    80001a5a:	7902                	ld	s2,32(sp)
    80001a5c:	69e2                	ld	s3,24(sp)
    80001a5e:	6a42                	ld	s4,16(sp)
    80001a60:	6aa2                	ld	s5,8(sp)
    80001a62:	6b02                	ld	s6,0(sp)
    80001a64:	6121                	addi	sp,sp,64
    80001a66:	8082                	ret
      panic("kalloc");
    80001a68:	00006517          	auipc	a0,0x6
    80001a6c:	71050513          	addi	a0,a0,1808 # 80008178 <digits+0x140>
    80001a70:	d19fe0ef          	jal	ra,80000788 <panic>

0000000080001a74 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a74:	7139                	addi	sp,sp,-64
    80001a76:	fc06                	sd	ra,56(sp)
    80001a78:	f822                	sd	s0,48(sp)
    80001a7a:	f426                	sd	s1,40(sp)
    80001a7c:	f04a                	sd	s2,32(sp)
    80001a7e:	ec4e                	sd	s3,24(sp)
    80001a80:	e852                	sd	s4,16(sp)
    80001a82:	e456                	sd	s5,8(sp)
    80001a84:	e05a                	sd	s6,0(sp)
    80001a86:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a88:	00006597          	auipc	a1,0x6
    80001a8c:	6f858593          	addi	a1,a1,1784 # 80008180 <digits+0x148>
    80001a90:	0022f517          	auipc	a0,0x22f
    80001a94:	f3050513          	addi	a0,a0,-208 # 802309c0 <pid_lock>
    80001a98:	988ff0ef          	jal	ra,80000c20 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a9c:	00006597          	auipc	a1,0x6
    80001aa0:	6ec58593          	addi	a1,a1,1772 # 80008188 <digits+0x150>
    80001aa4:	0022f517          	auipc	a0,0x22f
    80001aa8:	f3450513          	addi	a0,a0,-204 # 802309d8 <wait_lock>
    80001aac:	974ff0ef          	jal	ra,80000c20 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab0:	0022f497          	auipc	s1,0x22f
    80001ab4:	34048493          	addi	s1,s1,832 # 80230df0 <proc>
      initlock(&p->lock, "proc");
    80001ab8:	00006b17          	auipc	s6,0x6
    80001abc:	6e0b0b13          	addi	s6,s6,1760 # 80008198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001ac0:	8aa6                	mv	s5,s1
    80001ac2:	00006a17          	auipc	s4,0x6
    80001ac6:	53ea0a13          	addi	s4,s4,1342 # 80008000 <etext>
    80001aca:	04000937          	lui	s2,0x4000
    80001ace:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ad0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad2:	0023f997          	auipc	s3,0x23f
    80001ad6:	d1e98993          	addi	s3,s3,-738 # 802407f0 <tickslock>
      initlock(&p->lock, "proc");
    80001ada:	85da                	mv	a1,s6
    80001adc:	8526                	mv	a0,s1
    80001ade:	942ff0ef          	jal	ra,80000c20 <initlock>
      p->state = UNUSED;
    80001ae2:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001ae6:	415487b3          	sub	a5,s1,s5
    80001aea:	878d                	srai	a5,a5,0x3
    80001aec:	000a3703          	ld	a4,0(s4)
    80001af0:	02e787b3          	mul	a5,a5,a4
    80001af4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdab299>
    80001af6:	00d7979b          	slliw	a5,a5,0xd
    80001afa:	40f907b3          	sub	a5,s2,a5
    80001afe:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b00:	3e848493          	addi	s1,s1,1000
    80001b04:	fd349be3          	bne	s1,s3,80001ada <procinit+0x66>
  }
}
    80001b08:	70e2                	ld	ra,56(sp)
    80001b0a:	7442                	ld	s0,48(sp)
    80001b0c:	74a2                	ld	s1,40(sp)
    80001b0e:	7902                	ld	s2,32(sp)
    80001b10:	69e2                	ld	s3,24(sp)
    80001b12:	6a42                	ld	s4,16(sp)
    80001b14:	6aa2                	ld	s5,8(sp)
    80001b16:	6b02                	ld	s6,0(sp)
    80001b18:	6121                	addi	sp,sp,64
    80001b1a:	8082                	ret

0000000080001b1c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b1c:	1141                	addi	sp,sp,-16
    80001b1e:	e422                	sd	s0,8(sp)
    80001b20:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b22:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b24:	2501                	sext.w	a0,a0
    80001b26:	6422                	ld	s0,8(sp)
    80001b28:	0141                	addi	sp,sp,16
    80001b2a:	8082                	ret

0000000080001b2c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001b2c:	1141                	addi	sp,sp,-16
    80001b2e:	e422                	sd	s0,8(sp)
    80001b30:	0800                	addi	s0,sp,16
    80001b32:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b34:	2781                	sext.w	a5,a5
    80001b36:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b38:	0022f517          	auipc	a0,0x22f
    80001b3c:	eb850513          	addi	a0,a0,-328 # 802309f0 <cpus>
    80001b40:	953e                	add	a0,a0,a5
    80001b42:	6422                	ld	s0,8(sp)
    80001b44:	0141                	addi	sp,sp,16
    80001b46:	8082                	ret

0000000080001b48 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  push_off();
    80001b52:	90eff0ef          	jal	ra,80000c60 <push_off>
    80001b56:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b58:	2781                	sext.w	a5,a5
    80001b5a:	079e                	slli	a5,a5,0x7
    80001b5c:	0022f717          	auipc	a4,0x22f
    80001b60:	e6470713          	addi	a4,a4,-412 # 802309c0 <pid_lock>
    80001b64:	97ba                	add	a5,a5,a4
    80001b66:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b68:	97cff0ef          	jal	ra,80000ce4 <pop_off>
  return p;
}
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	60e2                	ld	ra,24(sp)
    80001b70:	6442                	ld	s0,16(sp)
    80001b72:	64a2                	ld	s1,8(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret

0000000080001b78 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b78:	7179                	addi	sp,sp,-48
    80001b7a:	f406                	sd	ra,40(sp)
    80001b7c:	f022                	sd	s0,32(sp)
    80001b7e:	ec26                	sd	s1,24(sp)
    80001b80:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b82:	fc7ff0ef          	jal	ra,80001b48 <myproc>
    80001b86:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b88:	9b0ff0ef          	jal	ra,80000d38 <release>

  if (first) {
    80001b8c:	00007797          	auipc	a5,0x7
    80001b90:	cc47a783          	lw	a5,-828(a5) # 80008850 <first.1>
    80001b94:	cf8d                	beqz	a5,80001bce <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b96:	4505                	li	a0,1
    80001b98:	30c020ef          	jal	ra,80003ea4 <fsinit>

    first = 0;
    80001b9c:	00007797          	auipc	a5,0x7
    80001ba0:	ca07aa23          	sw	zero,-844(a5) # 80008850 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001ba4:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001ba8:	00006517          	auipc	a0,0x6
    80001bac:	5f850513          	addi	a0,a0,1528 # 800081a0 <digits+0x168>
    80001bb0:	fca43823          	sd	a0,-48(s0)
    80001bb4:	fc043c23          	sd	zero,-40(s0)
    80001bb8:	fd040593          	addi	a1,s0,-48
    80001bbc:	396030ef          	jal	ra,80004f52 <kexec>
    80001bc0:	6cbc                	ld	a5,88(s1)
    80001bc2:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001bc4:	6cbc                	ld	a5,88(s1)
    80001bc6:	7bb8                	ld	a4,112(a5)
    80001bc8:	57fd                	li	a5,-1
    80001bca:	02f70d63          	beq	a4,a5,80001c04 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001bce:	4b3000ef          	jal	ra,80002880 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001bd2:	68a8                	ld	a0,80(s1)
    80001bd4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001bd6:	04000737          	lui	a4,0x4000
    80001bda:	00005797          	auipc	a5,0x5
    80001bde:	4c278793          	addi	a5,a5,1218 # 8000709c <userret>
    80001be2:	00005697          	auipc	a3,0x5
    80001be6:	41e68693          	addi	a3,a3,1054 # 80007000 <_trampoline>
    80001bea:	8f95                	sub	a5,a5,a3
    80001bec:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001bee:	0732                	slli	a4,a4,0xc
    80001bf0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001bf2:	577d                	li	a4,-1
    80001bf4:	177e                	slli	a4,a4,0x3f
    80001bf6:	8d59                	or	a0,a0,a4
    80001bf8:	9782                	jalr	a5
}
    80001bfa:	70a2                	ld	ra,40(sp)
    80001bfc:	7402                	ld	s0,32(sp)
    80001bfe:	64e2                	ld	s1,24(sp)
    80001c00:	6145                	addi	sp,sp,48
    80001c02:	8082                	ret
      panic("exec");
    80001c04:	00006517          	auipc	a0,0x6
    80001c08:	5a450513          	addi	a0,a0,1444 # 800081a8 <digits+0x170>
    80001c0c:	b7dfe0ef          	jal	ra,80000788 <panic>

0000000080001c10 <allocpid>:
{
    80001c10:	1101                	addi	sp,sp,-32
    80001c12:	ec06                	sd	ra,24(sp)
    80001c14:	e822                	sd	s0,16(sp)
    80001c16:	e426                	sd	s1,8(sp)
    80001c18:	e04a                	sd	s2,0(sp)
    80001c1a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c1c:	0022f917          	auipc	s2,0x22f
    80001c20:	da490913          	addi	s2,s2,-604 # 802309c0 <pid_lock>
    80001c24:	854a                	mv	a0,s2
    80001c26:	87aff0ef          	jal	ra,80000ca0 <acquire>
  pid = nextpid;
    80001c2a:	00007797          	auipc	a5,0x7
    80001c2e:	c2a78793          	addi	a5,a5,-982 # 80008854 <nextpid>
    80001c32:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c34:	0014871b          	addiw	a4,s1,1
    80001c38:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c3a:	854a                	mv	a0,s2
    80001c3c:	8fcff0ef          	jal	ra,80000d38 <release>
}
    80001c40:	8526                	mv	a0,s1
    80001c42:	60e2                	ld	ra,24(sp)
    80001c44:	6442                	ld	s0,16(sp)
    80001c46:	64a2                	ld	s1,8(sp)
    80001c48:	6902                	ld	s2,0(sp)
    80001c4a:	6105                	addi	sp,sp,32
    80001c4c:	8082                	ret

0000000080001c4e <delete_shm_from_vmas>:
delete_shm_from_vmas(struct vma *vmas){
    80001c4e:	7139                	addi	sp,sp,-64
    80001c50:	fc06                	sd	ra,56(sp)
    80001c52:	f822                	sd	s0,48(sp)
    80001c54:	f426                	sd	s1,40(sp)
    80001c56:	f04a                	sd	s2,32(sp)
    80001c58:	ec4e                	sd	s3,24(sp)
    80001c5a:	e852                	sd	s4,16(sp)
    80001c5c:	e456                	sd	s5,8(sp)
    80001c5e:	0080                	addi	s0,sp,64
    80001c60:	8a2a                	mv	s4,a0
    80001c62:	84aa                	mv	s1,a0
  for(int i = 0; i < NVMA; i++){
    80001c64:	4901                	li	s2,0
    80001c66:	02850a93          	addi	s5,a0,40
    80001c6a:	49c1                	li	s3,16
    80001c6c:	a025                	j	80001c94 <delete_shm_from_vmas+0x46>
    for(int j = 0; j < i; j++){
    80001c6e:	02878793          	addi	a5,a5,40
    80001c72:	00d78a63          	beq	a5,a3,80001c86 <delete_shm_from_vmas+0x38>
      if(vmas[j].used && vmas[j].is_shm && vmas[j].shm_key == key){
    80001c76:	4398                	lw	a4,0(a5)
    80001c78:	db7d                	beqz	a4,80001c6e <delete_shm_from_vmas+0x20>
    80001c7a:	5398                	lw	a4,32(a5)
    80001c7c:	db6d                	beqz	a4,80001c6e <delete_shm_from_vmas+0x20>
    80001c7e:	53d8                	lw	a4,36(a5)
    80001c80:	fea717e3          	bne	a4,a0,80001c6e <delete_shm_from_vmas+0x20>
    80001c84:	a019                	j	80001c8a <delete_shm_from_vmas+0x3c>
    shm_put(key);
    80001c86:	74a040ef          	jal	ra,800063d0 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001c8a:	2905                	addiw	s2,s2,1
    80001c8c:	02848493          	addi	s1,s1,40
    80001c90:	03390463          	beq	s2,s3,80001cb8 <delete_shm_from_vmas+0x6a>
    if(!vmas[i].used || !vmas[i].is_shm) continue;
    80001c94:	409c                	lw	a5,0(s1)
    80001c96:	dbf5                	beqz	a5,80001c8a <delete_shm_from_vmas+0x3c>
    80001c98:	509c                	lw	a5,32(s1)
    80001c9a:	dbe5                	beqz	a5,80001c8a <delete_shm_from_vmas+0x3c>
    int key = vmas[i].shm_key;
    80001c9c:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001c9e:	ff2054e3          	blez	s2,80001c86 <delete_shm_from_vmas+0x38>
    80001ca2:	fff9079b          	addiw	a5,s2,-1
    80001ca6:	1782                	slli	a5,a5,0x20
    80001ca8:	9381                	srli	a5,a5,0x20
    80001caa:	00279693          	slli	a3,a5,0x2
    80001cae:	96be                	add	a3,a3,a5
    80001cb0:	068e                	slli	a3,a3,0x3
    80001cb2:	96d6                	add	a3,a3,s5
    80001cb4:	87d2                	mv	a5,s4
    80001cb6:	b7c1                	j	80001c76 <delete_shm_from_vmas+0x28>
}
    80001cb8:	70e2                	ld	ra,56(sp)
    80001cba:	7442                	ld	s0,48(sp)
    80001cbc:	74a2                	ld	s1,40(sp)
    80001cbe:	7902                	ld	s2,32(sp)
    80001cc0:	69e2                	ld	s3,24(sp)
    80001cc2:	6a42                	ld	s4,16(sp)
    80001cc4:	6aa2                	ld	s5,8(sp)
    80001cc6:	6121                	addi	sp,sp,64
    80001cc8:	8082                	ret

0000000080001cca <delete_shm_from_proc>:
delete_shm_from_proc(struct proc *p){
    80001cca:	7139                	addi	sp,sp,-64
    80001ccc:	fc06                	sd	ra,56(sp)
    80001cce:	f822                	sd	s0,48(sp)
    80001cd0:	f426                	sd	s1,40(sp)
    80001cd2:	f04a                	sd	s2,32(sp)
    80001cd4:	ec4e                	sd	s3,24(sp)
    80001cd6:	e852                	sd	s4,16(sp)
    80001cd8:	e456                	sd	s5,8(sp)
    80001cda:	0080                	addi	s0,sp,64
  for(int i = 0; i < NVMA; i++){
    80001cdc:	16850a93          	addi	s5,a0,360
delete_shm_from_proc(struct proc *p){
    80001ce0:	84d6                	mv	s1,s5
  for(int i = 0; i < NVMA; i++){
    80001ce2:	4901                	li	s2,0
    80001ce4:	19050a13          	addi	s4,a0,400
    80001ce8:	49c1                	li	s3,16
    80001cea:	a025                	j	80001d12 <delete_shm_from_proc+0x48>
    for(int j = 0; j < i; j++){
    80001cec:	02878793          	addi	a5,a5,40
    80001cf0:	00d78a63          	beq	a5,a3,80001d04 <delete_shm_from_proc+0x3a>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001cf4:	4398                	lw	a4,0(a5)
    80001cf6:	db7d                	beqz	a4,80001cec <delete_shm_from_proc+0x22>
    80001cf8:	5398                	lw	a4,32(a5)
    80001cfa:	db6d                	beqz	a4,80001cec <delete_shm_from_proc+0x22>
    80001cfc:	53d8                	lw	a4,36(a5)
    80001cfe:	fea717e3          	bne	a4,a0,80001cec <delete_shm_from_proc+0x22>
    80001d02:	a019                	j	80001d08 <delete_shm_from_proc+0x3e>
    shm_put(key);
    80001d04:	6cc040ef          	jal	ra,800063d0 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001d08:	2905                	addiw	s2,s2,1
    80001d0a:	02848493          	addi	s1,s1,40
    80001d0e:	03390463          	beq	s2,s3,80001d36 <delete_shm_from_proc+0x6c>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001d12:	409c                	lw	a5,0(s1)
    80001d14:	dbf5                	beqz	a5,80001d08 <delete_shm_from_proc+0x3e>
    80001d16:	509c                	lw	a5,32(s1)
    80001d18:	dbe5                	beqz	a5,80001d08 <delete_shm_from_proc+0x3e>
    int key = p->vmas[i].shm_key;
    80001d1a:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d1c:	ff2054e3          	blez	s2,80001d04 <delete_shm_from_proc+0x3a>
    80001d20:	fff9079b          	addiw	a5,s2,-1
    80001d24:	1782                	slli	a5,a5,0x20
    80001d26:	9381                	srli	a5,a5,0x20
    80001d28:	00279693          	slli	a3,a5,0x2
    80001d2c:	96be                	add	a3,a3,a5
    80001d2e:	068e                	slli	a3,a3,0x3
    80001d30:	96d2                	add	a3,a3,s4
    80001d32:	87d6                	mv	a5,s5
    80001d34:	b7c1                	j	80001cf4 <delete_shm_from_proc+0x2a>
}
    80001d36:	70e2                	ld	ra,56(sp)
    80001d38:	7442                	ld	s0,48(sp)
    80001d3a:	74a2                	ld	s1,40(sp)
    80001d3c:	7902                	ld	s2,32(sp)
    80001d3e:	69e2                	ld	s3,24(sp)
    80001d40:	6a42                	ld	s4,16(sp)
    80001d42:	6aa2                	ld	s5,8(sp)
    80001d44:	6121                	addi	sp,sp,64
    80001d46:	8082                	ret

0000000080001d48 <proc_pagetable>:
{
    80001d48:	1101                	addi	sp,sp,-32
    80001d4a:	ec06                	sd	ra,24(sp)
    80001d4c:	e822                	sd	s0,16(sp)
    80001d4e:	e426                	sd	s1,8(sp)
    80001d50:	e04a                	sd	s2,0(sp)
    80001d52:	1000                	addi	s0,sp,32
    80001d54:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d56:	d18ff0ef          	jal	ra,8000126e <uvmcreate>
    80001d5a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d5c:	cd05                	beqz	a0,80001d94 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d5e:	4729                	li	a4,10
    80001d60:	00005697          	auipc	a3,0x5
    80001d64:	2a068693          	addi	a3,a3,672 # 80007000 <_trampoline>
    80001d68:	6605                	lui	a2,0x1
    80001d6a:	040005b7          	lui	a1,0x4000
    80001d6e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d70:	05b2                	slli	a1,a1,0xc
    80001d72:	b56ff0ef          	jal	ra,800010c8 <mappages>
    80001d76:	02054663          	bltz	a0,80001da2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d7a:	4719                	li	a4,6
    80001d7c:	05893683          	ld	a3,88(s2)
    80001d80:	6605                	lui	a2,0x1
    80001d82:	020005b7          	lui	a1,0x2000
    80001d86:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d88:	05b6                	slli	a1,a1,0xd
    80001d8a:	8526                	mv	a0,s1
    80001d8c:	b3cff0ef          	jal	ra,800010c8 <mappages>
    80001d90:	00054f63          	bltz	a0,80001dae <proc_pagetable+0x66>
}
    80001d94:	8526                	mv	a0,s1
    80001d96:	60e2                	ld	ra,24(sp)
    80001d98:	6442                	ld	s0,16(sp)
    80001d9a:	64a2                	ld	s1,8(sp)
    80001d9c:	6902                	ld	s2,0(sp)
    80001d9e:	6105                	addi	sp,sp,32
    80001da0:	8082                	ret
    uvmfree(pagetable, 0);
    80001da2:	4581                	li	a1,0
    80001da4:	8526                	mv	a0,s1
    80001da6:	ea8ff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001daa:	4481                	li	s1,0
    80001dac:	b7e5                	j	80001d94 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dae:	4681                	li	a3,0
    80001db0:	4605                	li	a2,1
    80001db2:	040005b7          	lui	a1,0x4000
    80001db6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001db8:	05b2                	slli	a1,a1,0xc
    80001dba:	8526                	mv	a0,s1
    80001dbc:	cd8ff0ef          	jal	ra,80001294 <uvmunmap>
    uvmfree(pagetable, 0);
    80001dc0:	4581                	li	a1,0
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	e8aff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001dc8:	4481                	li	s1,0
    80001dca:	b7e9                	j	80001d94 <proc_pagetable+0x4c>

0000000080001dcc <vma_unmap_pagetable>:
{
    80001dcc:	7179                	addi	sp,sp,-48
    80001dce:	f406                	sd	ra,40(sp)
    80001dd0:	f022                	sd	s0,32(sp)
    80001dd2:	ec26                	sd	s1,24(sp)
    80001dd4:	e84a                	sd	s2,16(sp)
    80001dd6:	e44e                	sd	s3,8(sp)
    80001dd8:	1800                	addi	s0,sp,48
    80001dda:	89aa                	mv	s3,a0
    80001ddc:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001dde:	28058913          	addi	s2,a1,640
    80001de2:	a811                	j	80001df6 <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001de4:	4685                	li	a3,1
    80001de6:	8231                	srli	a2,a2,0xc
    80001de8:	854e                	mv	a0,s3
    80001dea:	caaff0ef          	jal	ra,80001294 <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001dee:	02848493          	addi	s1,s1,40
    80001df2:	01248b63          	beq	s1,s2,80001e08 <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001df6:	409c                	lw	a5,0(s1)
    80001df8:	dbfd                	beqz	a5,80001dee <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001dfa:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001dfc:	689c                	ld	a5,16(s1)
    80001dfe:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001e02:	feb786e3          	beq	a5,a1,80001dee <vma_unmap_pagetable+0x22>
    80001e06:	bff9                	j	80001de4 <vma_unmap_pagetable+0x18>
}
    80001e08:	70a2                	ld	ra,40(sp)
    80001e0a:	7402                	ld	s0,32(sp)
    80001e0c:	64e2                	ld	s1,24(sp)
    80001e0e:	6942                	ld	s2,16(sp)
    80001e10:	69a2                	ld	s3,8(sp)
    80001e12:	6145                	addi	sp,sp,48
    80001e14:	8082                	ret

0000000080001e16 <proc_freepagetable>:
{
    80001e16:	1101                	addi	sp,sp,-32
    80001e18:	ec06                	sd	ra,24(sp)
    80001e1a:	e822                	sd	s0,16(sp)
    80001e1c:	e426                	sd	s1,8(sp)
    80001e1e:	e04a                	sd	s2,0(sp)
    80001e20:	1000                	addi	s0,sp,32
    80001e22:	84aa                	mv	s1,a0
    80001e24:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e26:	4681                	li	a3,0
    80001e28:	4605                	li	a2,1
    80001e2a:	040005b7          	lui	a1,0x4000
    80001e2e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e30:	05b2                	slli	a1,a1,0xc
    80001e32:	c62ff0ef          	jal	ra,80001294 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e36:	4681                	li	a3,0
    80001e38:	4605                	li	a2,1
    80001e3a:	020005b7          	lui	a1,0x2000
    80001e3e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e40:	05b6                	slli	a1,a1,0xd
    80001e42:	8526                	mv	a0,s1
    80001e44:	c50ff0ef          	jal	ra,80001294 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e48:	85ca                	mv	a1,s2
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	e02ff0ef          	jal	ra,8000144e <uvmfree>
}
    80001e50:	60e2                	ld	ra,24(sp)
    80001e52:	6442                	ld	s0,16(sp)
    80001e54:	64a2                	ld	s1,8(sp)
    80001e56:	6902                	ld	s2,0(sp)
    80001e58:	6105                	addi	sp,sp,32
    80001e5a:	8082                	ret

0000000080001e5c <freeproc>:
{
    80001e5c:	1101                	addi	sp,sp,-32
    80001e5e:	ec06                	sd	ra,24(sp)
    80001e60:	e822                	sd	s0,16(sp)
    80001e62:	e426                	sd	s1,8(sp)
    80001e64:	e04a                	sd	s2,0(sp)
    80001e66:	1000                	addi	s0,sp,32
    80001e68:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e6a:	6d28                	ld	a0,88(a0)
    80001e6c:	c119                	beqz	a0,80001e72 <freeproc+0x16>
    kfree((void*)p->trapframe);
    80001e6e:	c0dfe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001e72:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001e76:	68a8                	ld	a0,80(s1)
    80001e78:	c105                	beqz	a0,80001e98 <freeproc+0x3c>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001e7a:	16848913          	addi	s2,s1,360
    80001e7e:	85ca                	mv	a1,s2
    80001e80:	f4dff0ef          	jal	ra,80001dcc <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001e84:	28000613          	li	a2,640
    80001e88:	4581                	li	a1,0
    80001e8a:	854a                	mv	a0,s2
    80001e8c:	ee9fe0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001e90:	64ac                	ld	a1,72(s1)
    80001e92:	68a8                	ld	a0,80(s1)
    80001e94:	f83ff0ef          	jal	ra,80001e16 <proc_freepagetable>
  delete_shm_from_proc(p);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	e31ff0ef          	jal	ra,80001cca <delete_shm_from_proc>
  p->pagetable = 0;
    80001e9e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ea2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ea6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001eaa:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001eae:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001eb2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001eb6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001eba:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ebe:	0004ac23          	sw	zero,24(s1)
}
    80001ec2:	60e2                	ld	ra,24(sp)
    80001ec4:	6442                	ld	s0,16(sp)
    80001ec6:	64a2                	ld	s1,8(sp)
    80001ec8:	6902                	ld	s2,0(sp)
    80001eca:	6105                	addi	sp,sp,32
    80001ecc:	8082                	ret

0000000080001ece <allocproc>:
{
    80001ece:	1101                	addi	sp,sp,-32
    80001ed0:	ec06                	sd	ra,24(sp)
    80001ed2:	e822                	sd	s0,16(sp)
    80001ed4:	e426                	sd	s1,8(sp)
    80001ed6:	e04a                	sd	s2,0(sp)
    80001ed8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eda:	0022f497          	auipc	s1,0x22f
    80001ede:	f1648493          	addi	s1,s1,-234 # 80230df0 <proc>
    80001ee2:	0023f917          	auipc	s2,0x23f
    80001ee6:	90e90913          	addi	s2,s2,-1778 # 802407f0 <tickslock>
    acquire(&p->lock);
    80001eea:	8526                	mv	a0,s1
    80001eec:	db5fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001ef0:	4c9c                	lw	a5,24(s1)
    80001ef2:	cb91                	beqz	a5,80001f06 <allocproc+0x38>
      release(&p->lock);
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	e43fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001efa:	3e848493          	addi	s1,s1,1000
    80001efe:	ff2496e3          	bne	s1,s2,80001eea <allocproc+0x1c>
  return 0;
    80001f02:	4481                	li	s1,0
    80001f04:	a089                	j	80001f46 <allocproc+0x78>
  p->pid = allocpid();
    80001f06:	d0bff0ef          	jal	ra,80001c10 <allocpid>
    80001f0a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f0c:	4785                	li	a5,1
    80001f0e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001f10:	c9bfe0ef          	jal	ra,80000baa <kalloc>
    80001f14:	892a                	mv	s2,a0
    80001f16:	eca8                	sd	a0,88(s1)
    80001f18:	cd15                	beqz	a0,80001f54 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	e2dff0ef          	jal	ra,80001d48 <proc_pagetable>
    80001f20:	892a                	mv	s2,a0
    80001f22:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001f24:	c121                	beqz	a0,80001f64 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001f26:	07000613          	li	a2,112
    80001f2a:	4581                	li	a1,0
    80001f2c:	06048513          	addi	a0,s1,96
    80001f30:	e45fe0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    80001f34:	00000797          	auipc	a5,0x0
    80001f38:	c4478793          	addi	a5,a5,-956 # 80001b78 <forkret>
    80001f3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f3e:	60bc                	ld	a5,64(s1)
    80001f40:	6705                	lui	a4,0x1
    80001f42:	97ba                	add	a5,a5,a4
    80001f44:	f4bc                	sd	a5,104(s1)
}
    80001f46:	8526                	mv	a0,s1
    80001f48:	60e2                	ld	ra,24(sp)
    80001f4a:	6442                	ld	s0,16(sp)
    80001f4c:	64a2                	ld	s1,8(sp)
    80001f4e:	6902                	ld	s2,0(sp)
    80001f50:	6105                	addi	sp,sp,32
    80001f52:	8082                	ret
    freeproc(p);
    80001f54:	8526                	mv	a0,s1
    80001f56:	f07ff0ef          	jal	ra,80001e5c <freeproc>
    release(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	dddfe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001f60:	84ca                	mv	s1,s2
    80001f62:	b7d5                	j	80001f46 <allocproc+0x78>
    freeproc(p);
    80001f64:	8526                	mv	a0,s1
    80001f66:	ef7ff0ef          	jal	ra,80001e5c <freeproc>
    release(&p->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	dcdfe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001f70:	84ca                	mv	s1,s2
    80001f72:	bfd1                	j	80001f46 <allocproc+0x78>

0000000080001f74 <userinit>:
{
    80001f74:	1101                	addi	sp,sp,-32
    80001f76:	ec06                	sd	ra,24(sp)
    80001f78:	e822                	sd	s0,16(sp)
    80001f7a:	e426                	sd	s1,8(sp)
    80001f7c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f7e:	f51ff0ef          	jal	ra,80001ece <allocproc>
    80001f82:	84aa                	mv	s1,a0
  initproc = p;
    80001f84:	00007797          	auipc	a5,0x7
    80001f88:	90a7be23          	sd	a0,-1764(a5) # 800088a0 <initproc>
  p->cwd = namei("/");
    80001f8c:	00006517          	auipc	a0,0x6
    80001f90:	22450513          	addi	a0,a0,548 # 800081b0 <digits+0x178>
    80001f94:	414020ef          	jal	ra,800043a8 <namei>
    80001f98:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f9c:	478d                	li	a5,3
    80001f9e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fa0:	8526                	mv	a0,s1
    80001fa2:	d97fe0ef          	jal	ra,80000d38 <release>
}
    80001fa6:	60e2                	ld	ra,24(sp)
    80001fa8:	6442                	ld	s0,16(sp)
    80001faa:	64a2                	ld	s1,8(sp)
    80001fac:	6105                	addi	sp,sp,32
    80001fae:	8082                	ret

0000000080001fb0 <growproc>:
{
    80001fb0:	1101                	addi	sp,sp,-32
    80001fb2:	ec06                	sd	ra,24(sp)
    80001fb4:	e822                	sd	s0,16(sp)
    80001fb6:	e426                	sd	s1,8(sp)
    80001fb8:	e04a                	sd	s2,0(sp)
    80001fba:	1000                	addi	s0,sp,32
    80001fbc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fbe:	b8bff0ef          	jal	ra,80001b48 <myproc>
    80001fc2:	892a                	mv	s2,a0
  sz = p->sz;
    80001fc4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001fc6:	02905963          	blez	s1,80001ff8 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001fca:	00b48633          	add	a2,s1,a1
    80001fce:	020007b7          	lui	a5,0x2000
    80001fd2:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001fd4:	07b6                	slli	a5,a5,0xd
    80001fd6:	02c7ea63          	bltu	a5,a2,8000200a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001fda:	4691                	li	a3,4
    80001fdc:	6928                	ld	a0,80(a0)
    80001fde:	b76ff0ef          	jal	ra,80001354 <uvmalloc>
    80001fe2:	85aa                	mv	a1,a0
    80001fe4:	c50d                	beqz	a0,8000200e <growproc+0x5e>
  p->sz = sz;
    80001fe6:	04b93423          	sd	a1,72(s2)
  return 0;
    80001fea:	4501                	li	a0,0
}
    80001fec:	60e2                	ld	ra,24(sp)
    80001fee:	6442                	ld	s0,16(sp)
    80001ff0:	64a2                	ld	s1,8(sp)
    80001ff2:	6902                	ld	s2,0(sp)
    80001ff4:	6105                	addi	sp,sp,32
    80001ff6:	8082                	ret
  } else if(n < 0){
    80001ff8:	fe04d7e3          	bgez	s1,80001fe6 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ffc:	00b48633          	add	a2,s1,a1
    80002000:	6928                	ld	a0,80(a0)
    80002002:	b0eff0ef          	jal	ra,80001310 <uvmdealloc>
    80002006:	85aa                	mv	a1,a0
    80002008:	bff9                	j	80001fe6 <growproc+0x36>
      return -1;
    8000200a:	557d                	li	a0,-1
    8000200c:	b7c5                	j	80001fec <growproc+0x3c>
      return -1;
    8000200e:	557d                	li	a0,-1
    80002010:	bff1                	j	80001fec <growproc+0x3c>

0000000080002012 <kfork>:
{
    80002012:	715d                	addi	sp,sp,-80
    80002014:	e486                	sd	ra,72(sp)
    80002016:	e0a2                	sd	s0,64(sp)
    80002018:	fc26                	sd	s1,56(sp)
    8000201a:	f84a                	sd	s2,48(sp)
    8000201c:	f44e                	sd	s3,40(sp)
    8000201e:	f052                	sd	s4,32(sp)
    80002020:	ec56                	sd	s5,24(sp)
    80002022:	e85a                	sd	s6,16(sp)
    80002024:	e45e                	sd	s7,8(sp)
    80002026:	e062                	sd	s8,0(sp)
    80002028:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    8000202a:	b1fff0ef          	jal	ra,80001b48 <myproc>
    8000202e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002030:	e9fff0ef          	jal	ra,80001ece <allocproc>
    80002034:	12050963          	beqz	a0,80002166 <kfork+0x154>
    80002038:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000203a:	048ab603          	ld	a2,72(s5)
    8000203e:	692c                	ld	a1,80(a0)
    80002040:	050ab503          	ld	a0,80(s5)
    80002044:	c3cff0ef          	jal	ra,80001480 <uvmcopy>
    80002048:	04054863          	bltz	a0,80002098 <kfork+0x86>
  np->sz = p->sz;
    8000204c:	048ab783          	ld	a5,72(s5)
    80002050:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002054:	058ab683          	ld	a3,88(s5)
    80002058:	87b6                	mv	a5,a3
    8000205a:	0589b703          	ld	a4,88(s3)
    8000205e:	12068693          	addi	a3,a3,288
    80002062:	0007b803          	ld	a6,0(a5)
    80002066:	6788                	ld	a0,8(a5)
    80002068:	6b8c                	ld	a1,16(a5)
    8000206a:	6f90                	ld	a2,24(a5)
    8000206c:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002070:	e708                	sd	a0,8(a4)
    80002072:	eb0c                	sd	a1,16(a4)
    80002074:	ef10                	sd	a2,24(a4)
    80002076:	02078793          	addi	a5,a5,32
    8000207a:	02070713          	addi	a4,a4,32
    8000207e:	fed792e3          	bne	a5,a3,80002062 <kfork+0x50>
  np->trapframe->a0 = 0;
    80002082:	0589b783          	ld	a5,88(s3)
    80002086:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000208a:	0d0a8493          	addi	s1,s5,208
    8000208e:	0d098913          	addi	s2,s3,208
    80002092:	150a8a13          	addi	s4,s5,336
    80002096:	a829                	j	800020b0 <kfork+0x9e>
    freeproc(np);
    80002098:	854e                	mv	a0,s3
    8000209a:	dc3ff0ef          	jal	ra,80001e5c <freeproc>
    release(&np->lock);
    8000209e:	854e                	mv	a0,s3
    800020a0:	c99fe0ef          	jal	ra,80000d38 <release>
    return -1;
    800020a4:	5c7d                	li	s8,-1
    800020a6:	a05d                	j	8000214c <kfork+0x13a>
  for(i = 0; i < NOFILE; i++)
    800020a8:	04a1                	addi	s1,s1,8
    800020aa:	0921                	addi	s2,s2,8
    800020ac:	01448963          	beq	s1,s4,800020be <kfork+0xac>
    if(p->ofile[i])
    800020b0:	6088                	ld	a0,0(s1)
    800020b2:	d97d                	beqz	a0,800020a8 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    800020b4:	0ad020ef          	jal	ra,80004960 <filedup>
    800020b8:	00a93023          	sd	a0,0(s2)
    800020bc:	b7f5                	j	800020a8 <kfork+0x96>
  np->cwd = idup(p->cwd);
    800020be:	150ab503          	ld	a0,336(s5)
    800020c2:	2bd010ef          	jal	ra,80003b7e <idup>
    800020c6:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020ca:	4641                	li	a2,16
    800020cc:	158a8593          	addi	a1,s5,344
    800020d0:	15898513          	addi	a0,s3,344
    800020d4:	de7fe0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    800020d8:	0309ac03          	lw	s8,48(s3)
  release(&np->lock);
    800020dc:	854e                	mv	a0,s3
    800020de:	c5bfe0ef          	jal	ra,80000d38 <release>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    800020e2:	16898b13          	addi	s6,s3,360
    800020e6:	28000613          	li	a2,640
    800020ea:	168a8593          	addi	a1,s5,360
    800020ee:	855a                	mv	a0,s6
    800020f0:	ce1fe0ef          	jal	ra,80000dd0 <memmove>
    800020f4:	84da                	mv	s1,s6
  for(int i = 0; i < NVMA; i++){
    800020f6:	4901                	li	s2,0
    800020f8:	19098b93          	addi	s7,s3,400
    800020fc:	4a41                	li	s4,16
    800020fe:	a069                	j	80002188 <kfork+0x176>
    for(int j = 0; j < i; j++){
    80002100:	02878793          	addi	a5,a5,40
    80002104:	06d78363          	beq	a5,a3,8000216a <kfork+0x158>
      if(np->vmas[j].used && np->vmas[j].is_shm && np->vmas[j].shm_key == key){
    80002108:	4398                	lw	a4,0(a5)
    8000210a:	db7d                	beqz	a4,80002100 <kfork+0xee>
    8000210c:	5398                	lw	a4,32(a5)
    8000210e:	db6d                	beqz	a4,80002100 <kfork+0xee>
    80002110:	53d8                	lw	a4,36(a5)
    80002112:	fea717e3          	bne	a4,a0,80002100 <kfork+0xee>
    80002116:	a0a5                	j	8000217e <kfork+0x16c>
        freeproc(np);
    80002118:	854e                	mv	a0,s3
    8000211a:	d43ff0ef          	jal	ra,80001e5c <freeproc>
        return -1;
    8000211e:	5c7d                	li	s8,-1
    80002120:	a035                	j	8000214c <kfork+0x13a>
  acquire(&wait_lock);
    80002122:	0022f497          	auipc	s1,0x22f
    80002126:	8b648493          	addi	s1,s1,-1866 # 802309d8 <wait_lock>
    8000212a:	8526                	mv	a0,s1
    8000212c:	b75fe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    80002130:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002134:	8526                	mv	a0,s1
    80002136:	c03fe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    8000213a:	854e                	mv	a0,s3
    8000213c:	b65fe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    80002140:	478d                	li	a5,3
    80002142:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002146:	854e                	mv	a0,s3
    80002148:	bf1fe0ef          	jal	ra,80000d38 <release>
}
    8000214c:	8562                	mv	a0,s8
    8000214e:	60a6                	ld	ra,72(sp)
    80002150:	6406                	ld	s0,64(sp)
    80002152:	74e2                	ld	s1,56(sp)
    80002154:	7942                	ld	s2,48(sp)
    80002156:	79a2                	ld	s3,40(sp)
    80002158:	7a02                	ld	s4,32(sp)
    8000215a:	6ae2                	ld	s5,24(sp)
    8000215c:	6b42                	ld	s6,16(sp)
    8000215e:	6ba2                	ld	s7,8(sp)
    80002160:	6c02                	ld	s8,0(sp)
    80002162:	6161                	addi	sp,sp,80
    80002164:	8082                	ret
    return -1;
    80002166:	5c7d                	li	s8,-1
    80002168:	b7d5                	j	8000214c <kfork+0x13a>
    int npages = (np->vmas[i].end - np->vmas[i].start) / PGSIZE;
    8000216a:	699c                	ld	a5,16(a1)
    8000216c:	6598                	ld	a4,8(a1)
    8000216e:	40e785b3          	sub	a1,a5,a4
    80002172:	81b1                	srli	a1,a1,0xc
    if(shm_get(key, npages) < 0){
    80002174:	2581                	sext.w	a1,a1
    80002176:	146040ef          	jal	ra,800062bc <shm_get>
    8000217a:	f8054fe3          	bltz	a0,80002118 <kfork+0x106>
  for(int i = 0; i < NVMA; i++){
    8000217e:	2905                	addiw	s2,s2,1
    80002180:	02848493          	addi	s1,s1,40
    80002184:	f9490fe3          	beq	s2,s4,80002122 <kfork+0x110>
    if(!np->vmas[i].used || !np->vmas[i].is_shm) continue;
    80002188:	85a6                	mv	a1,s1
    8000218a:	409c                	lw	a5,0(s1)
    8000218c:	dbed                	beqz	a5,8000217e <kfork+0x16c>
    8000218e:	509c                	lw	a5,32(s1)
    80002190:	d7fd                	beqz	a5,8000217e <kfork+0x16c>
    int key = np->vmas[i].shm_key;
    80002192:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80002194:	fd205be3          	blez	s2,8000216a <kfork+0x158>
    80002198:	fff9079b          	addiw	a5,s2,-1
    8000219c:	1782                	slli	a5,a5,0x20
    8000219e:	9381                	srli	a5,a5,0x20
    800021a0:	00279693          	slli	a3,a5,0x2
    800021a4:	96be                	add	a3,a3,a5
    800021a6:	068e                	slli	a3,a3,0x3
    800021a8:	96de                	add	a3,a3,s7
    800021aa:	87da                	mv	a5,s6
    800021ac:	bfb1                	j	80002108 <kfork+0xf6>

00000000800021ae <scheduler>:
{
    800021ae:	715d                	addi	sp,sp,-80
    800021b0:	e486                	sd	ra,72(sp)
    800021b2:	e0a2                	sd	s0,64(sp)
    800021b4:	fc26                	sd	s1,56(sp)
    800021b6:	f84a                	sd	s2,48(sp)
    800021b8:	f44e                	sd	s3,40(sp)
    800021ba:	f052                	sd	s4,32(sp)
    800021bc:	ec56                	sd	s5,24(sp)
    800021be:	e85a                	sd	s6,16(sp)
    800021c0:	e45e                	sd	s7,8(sp)
    800021c2:	e062                	sd	s8,0(sp)
    800021c4:	0880                	addi	s0,sp,80
    800021c6:	8792                	mv	a5,tp
  int id = r_tp();
    800021c8:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021ca:	00779b13          	slli	s6,a5,0x7
    800021ce:	0022e717          	auipc	a4,0x22e
    800021d2:	7f270713          	addi	a4,a4,2034 # 802309c0 <pid_lock>
    800021d6:	975a                	add	a4,a4,s6
    800021d8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800021dc:	0022f717          	auipc	a4,0x22f
    800021e0:	81c70713          	addi	a4,a4,-2020 # 802309f8 <cpus+0x8>
    800021e4:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800021e6:	4c11                	li	s8,4
        c->proc = p;
    800021e8:	079e                	slli	a5,a5,0x7
    800021ea:	0022ea17          	auipc	s4,0x22e
    800021ee:	7d6a0a13          	addi	s4,s4,2006 # 802309c0 <pid_lock>
    800021f2:	9a3e                	add	s4,s4,a5
        found = 1;
    800021f4:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800021f6:	0023e997          	auipc	s3,0x23e
    800021fa:	5fa98993          	addi	s3,s3,1530 # 802407f0 <tickslock>
    800021fe:	a83d                	j	8000223c <scheduler+0x8e>
      release(&p->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	b37fe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002206:	3e848493          	addi	s1,s1,1000
    8000220a:	03348563          	beq	s1,s3,80002234 <scheduler+0x86>
      acquire(&p->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	a91fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    80002214:	4c9c                	lw	a5,24(s1)
    80002216:	ff2795e3          	bne	a5,s2,80002200 <scheduler+0x52>
        p->state = RUNNING;
    8000221a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000221e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002222:	06048593          	addi	a1,s1,96
    80002226:	855a                	mv	a0,s6
    80002228:	5b2000ef          	jal	ra,800027da <swtch>
        c->proc = 0;
    8000222c:	020a3823          	sd	zero,48(s4)
        found = 1;
    80002230:	8ade                	mv	s5,s7
    80002232:	b7f9                	j	80002200 <scheduler+0x52>
    if(found == 0) {
    80002234:	000a9463          	bnez	s5,8000223c <scheduler+0x8e>
      asm volatile("wfi");
    80002238:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000223c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002240:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002244:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002248:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000224c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000224e:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002252:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002254:	0022f497          	auipc	s1,0x22f
    80002258:	b9c48493          	addi	s1,s1,-1124 # 80230df0 <proc>
      if(p->state == RUNNABLE) {
    8000225c:	490d                	li	s2,3
    8000225e:	bf45                	j	8000220e <scheduler+0x60>

0000000080002260 <sched>:
{
    80002260:	7179                	addi	sp,sp,-48
    80002262:	f406                	sd	ra,40(sp)
    80002264:	f022                	sd	s0,32(sp)
    80002266:	ec26                	sd	s1,24(sp)
    80002268:	e84a                	sd	s2,16(sp)
    8000226a:	e44e                	sd	s3,8(sp)
    8000226c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000226e:	8dbff0ef          	jal	ra,80001b48 <myproc>
    80002272:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002274:	9c3fe0ef          	jal	ra,80000c36 <holding>
    80002278:	c92d                	beqz	a0,800022ea <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000227a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000227c:	2781                	sext.w	a5,a5
    8000227e:	079e                	slli	a5,a5,0x7
    80002280:	0022e717          	auipc	a4,0x22e
    80002284:	74070713          	addi	a4,a4,1856 # 802309c0 <pid_lock>
    80002288:	97ba                	add	a5,a5,a4
    8000228a:	0a87a703          	lw	a4,168(a5)
    8000228e:	4785                	li	a5,1
    80002290:	06f71363          	bne	a4,a5,800022f6 <sched+0x96>
  if(p->state == RUNNING)
    80002294:	4c98                	lw	a4,24(s1)
    80002296:	4791                	li	a5,4
    80002298:	06f70563          	beq	a4,a5,80002302 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000229c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022a0:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022a2:	e7b5                	bnez	a5,8000230e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022a4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022a6:	0022e917          	auipc	s2,0x22e
    800022aa:	71a90913          	addi	s2,s2,1818 # 802309c0 <pid_lock>
    800022ae:	2781                	sext.w	a5,a5
    800022b0:	079e                	slli	a5,a5,0x7
    800022b2:	97ca                	add	a5,a5,s2
    800022b4:	0ac7a983          	lw	s3,172(a5)
    800022b8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800022ba:	2781                	sext.w	a5,a5
    800022bc:	079e                	slli	a5,a5,0x7
    800022be:	0022e597          	auipc	a1,0x22e
    800022c2:	73a58593          	addi	a1,a1,1850 # 802309f8 <cpus+0x8>
    800022c6:	95be                	add	a1,a1,a5
    800022c8:	06048513          	addi	a0,s1,96
    800022cc:	50e000ef          	jal	ra,800027da <swtch>
    800022d0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022d2:	2781                	sext.w	a5,a5
    800022d4:	079e                	slli	a5,a5,0x7
    800022d6:	993e                	add	s2,s2,a5
    800022d8:	0b392623          	sw	s3,172(s2)
}
    800022dc:	70a2                	ld	ra,40(sp)
    800022de:	7402                	ld	s0,32(sp)
    800022e0:	64e2                	ld	s1,24(sp)
    800022e2:	6942                	ld	s2,16(sp)
    800022e4:	69a2                	ld	s3,8(sp)
    800022e6:	6145                	addi	sp,sp,48
    800022e8:	8082                	ret
    panic("sched p->lock");
    800022ea:	00006517          	auipc	a0,0x6
    800022ee:	ece50513          	addi	a0,a0,-306 # 800081b8 <digits+0x180>
    800022f2:	c96fe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    800022f6:	00006517          	auipc	a0,0x6
    800022fa:	ed250513          	addi	a0,a0,-302 # 800081c8 <digits+0x190>
    800022fe:	c8afe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    80002302:	00006517          	auipc	a0,0x6
    80002306:	ed650513          	addi	a0,a0,-298 # 800081d8 <digits+0x1a0>
    8000230a:	c7efe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    8000230e:	00006517          	auipc	a0,0x6
    80002312:	eda50513          	addi	a0,a0,-294 # 800081e8 <digits+0x1b0>
    80002316:	c72fe0ef          	jal	ra,80000788 <panic>

000000008000231a <yield>:
{
    8000231a:	1101                	addi	sp,sp,-32
    8000231c:	ec06                	sd	ra,24(sp)
    8000231e:	e822                	sd	s0,16(sp)
    80002320:	e426                	sd	s1,8(sp)
    80002322:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002324:	825ff0ef          	jal	ra,80001b48 <myproc>
    80002328:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000232a:	977fe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    8000232e:	478d                	li	a5,3
    80002330:	cc9c                	sw	a5,24(s1)
  sched();
    80002332:	f2fff0ef          	jal	ra,80002260 <sched>
  release(&p->lock);
    80002336:	8526                	mv	a0,s1
    80002338:	a01fe0ef          	jal	ra,80000d38 <release>
}
    8000233c:	60e2                	ld	ra,24(sp)
    8000233e:	6442                	ld	s0,16(sp)
    80002340:	64a2                	ld	s1,8(sp)
    80002342:	6105                	addi	sp,sp,32
    80002344:	8082                	ret

0000000080002346 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002346:	7179                	addi	sp,sp,-48
    80002348:	f406                	sd	ra,40(sp)
    8000234a:	f022                	sd	s0,32(sp)
    8000234c:	ec26                	sd	s1,24(sp)
    8000234e:	e84a                	sd	s2,16(sp)
    80002350:	e44e                	sd	s3,8(sp)
    80002352:	1800                	addi	s0,sp,48
    80002354:	89aa                	mv	s3,a0
    80002356:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002358:	ff0ff0ef          	jal	ra,80001b48 <myproc>
    8000235c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000235e:	943fe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    80002362:	854a                	mv	a0,s2
    80002364:	9d5fe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    80002368:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000236c:	4789                	li	a5,2
    8000236e:	cc9c                	sw	a5,24(s1)

  sched();
    80002370:	ef1ff0ef          	jal	ra,80002260 <sched>

  // Tidy up.
  p->chan = 0;
    80002374:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	9bffe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    8000237e:	854a                	mv	a0,s2
    80002380:	921fe0ef          	jal	ra,80000ca0 <acquire>
}
    80002384:	70a2                	ld	ra,40(sp)
    80002386:	7402                	ld	s0,32(sp)
    80002388:	64e2                	ld	s1,24(sp)
    8000238a:	6942                	ld	s2,16(sp)
    8000238c:	69a2                	ld	s3,8(sp)
    8000238e:	6145                	addi	sp,sp,48
    80002390:	8082                	ret

0000000080002392 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002392:	7139                	addi	sp,sp,-64
    80002394:	fc06                	sd	ra,56(sp)
    80002396:	f822                	sd	s0,48(sp)
    80002398:	f426                	sd	s1,40(sp)
    8000239a:	f04a                	sd	s2,32(sp)
    8000239c:	ec4e                	sd	s3,24(sp)
    8000239e:	e852                	sd	s4,16(sp)
    800023a0:	e456                	sd	s5,8(sp)
    800023a2:	0080                	addi	s0,sp,64
    800023a4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800023a6:	0022f497          	auipc	s1,0x22f
    800023aa:	a4a48493          	addi	s1,s1,-1462 # 80230df0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800023ae:	4989                	li	s3,2
        p->state = RUNNABLE;
    800023b0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800023b2:	0023e917          	auipc	s2,0x23e
    800023b6:	43e90913          	addi	s2,s2,1086 # 802407f0 <tickslock>
    800023ba:	a801                	j	800023ca <wakeup+0x38>
      }
      release(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	97bfe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023c2:	3e848493          	addi	s1,s1,1000
    800023c6:	03248263          	beq	s1,s2,800023ea <wakeup+0x58>
    if(p != myproc()){
    800023ca:	f7eff0ef          	jal	ra,80001b48 <myproc>
    800023ce:	fea48ae3          	beq	s1,a0,800023c2 <wakeup+0x30>
      acquire(&p->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	8cdfe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800023d8:	4c9c                	lw	a5,24(s1)
    800023da:	ff3791e3          	bne	a5,s3,800023bc <wakeup+0x2a>
    800023de:	709c                	ld	a5,32(s1)
    800023e0:	fd479ee3          	bne	a5,s4,800023bc <wakeup+0x2a>
        p->state = RUNNABLE;
    800023e4:	0154ac23          	sw	s5,24(s1)
    800023e8:	bfd1                	j	800023bc <wakeup+0x2a>
    }
  }
}
    800023ea:	70e2                	ld	ra,56(sp)
    800023ec:	7442                	ld	s0,48(sp)
    800023ee:	74a2                	ld	s1,40(sp)
    800023f0:	7902                	ld	s2,32(sp)
    800023f2:	69e2                	ld	s3,24(sp)
    800023f4:	6a42                	ld	s4,16(sp)
    800023f6:	6aa2                	ld	s5,8(sp)
    800023f8:	6121                	addi	sp,sp,64
    800023fa:	8082                	ret

00000000800023fc <reparent>:
{
    800023fc:	7179                	addi	sp,sp,-48
    800023fe:	f406                	sd	ra,40(sp)
    80002400:	f022                	sd	s0,32(sp)
    80002402:	ec26                	sd	s1,24(sp)
    80002404:	e84a                	sd	s2,16(sp)
    80002406:	e44e                	sd	s3,8(sp)
    80002408:	e052                	sd	s4,0(sp)
    8000240a:	1800                	addi	s0,sp,48
    8000240c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000240e:	0022f497          	auipc	s1,0x22f
    80002412:	9e248493          	addi	s1,s1,-1566 # 80230df0 <proc>
      pp->parent = initproc;
    80002416:	00006a17          	auipc	s4,0x6
    8000241a:	48aa0a13          	addi	s4,s4,1162 # 800088a0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000241e:	0023e997          	auipc	s3,0x23e
    80002422:	3d298993          	addi	s3,s3,978 # 802407f0 <tickslock>
    80002426:	a029                	j	80002430 <reparent+0x34>
    80002428:	3e848493          	addi	s1,s1,1000
    8000242c:	01348b63          	beq	s1,s3,80002442 <reparent+0x46>
    if(pp->parent == p){
    80002430:	7c9c                	ld	a5,56(s1)
    80002432:	ff279be3          	bne	a5,s2,80002428 <reparent+0x2c>
      pp->parent = initproc;
    80002436:	000a3503          	ld	a0,0(s4)
    8000243a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000243c:	f57ff0ef          	jal	ra,80002392 <wakeup>
    80002440:	b7e5                	j	80002428 <reparent+0x2c>
}
    80002442:	70a2                	ld	ra,40(sp)
    80002444:	7402                	ld	s0,32(sp)
    80002446:	64e2                	ld	s1,24(sp)
    80002448:	6942                	ld	s2,16(sp)
    8000244a:	69a2                	ld	s3,8(sp)
    8000244c:	6a02                	ld	s4,0(sp)
    8000244e:	6145                	addi	sp,sp,48
    80002450:	8082                	ret

0000000080002452 <kexit>:
{
    80002452:	7179                	addi	sp,sp,-48
    80002454:	f406                	sd	ra,40(sp)
    80002456:	f022                	sd	s0,32(sp)
    80002458:	ec26                	sd	s1,24(sp)
    8000245a:	e84a                	sd	s2,16(sp)
    8000245c:	e44e                	sd	s3,8(sp)
    8000245e:	e052                	sd	s4,0(sp)
    80002460:	1800                	addi	s0,sp,48
    80002462:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002464:	ee4ff0ef          	jal	ra,80001b48 <myproc>
    80002468:	89aa                	mv	s3,a0
  if(p == initproc)
    8000246a:	00006797          	auipc	a5,0x6
    8000246e:	4367b783          	ld	a5,1078(a5) # 800088a0 <initproc>
    80002472:	0d050493          	addi	s1,a0,208
    80002476:	15050913          	addi	s2,a0,336
    8000247a:	00a79f63          	bne	a5,a0,80002498 <kexit+0x46>
    panic("init exiting");
    8000247e:	00006517          	auipc	a0,0x6
    80002482:	d8250513          	addi	a0,a0,-638 # 80008200 <digits+0x1c8>
    80002486:	b02fe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    8000248a:	51c020ef          	jal	ra,800049a6 <fileclose>
      p->ofile[fd] = 0;
    8000248e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002492:	04a1                	addi	s1,s1,8
    80002494:	01248563          	beq	s1,s2,8000249e <kexit+0x4c>
    if(p->ofile[fd]){
    80002498:	6088                	ld	a0,0(s1)
    8000249a:	f965                	bnez	a0,8000248a <kexit+0x38>
    8000249c:	bfdd                	j	80002492 <kexit+0x40>
  begin_op();
    8000249e:	0fe020ef          	jal	ra,8000459c <begin_op>
  iput(p->cwd);
    800024a2:	1509b503          	ld	a0,336(s3)
    800024a6:	08d010ef          	jal	ra,80003d32 <iput>
  end_op();
    800024aa:	160020ef          	jal	ra,8000460a <end_op>
  p->cwd = 0;
    800024ae:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800024b2:	0022e497          	auipc	s1,0x22e
    800024b6:	52648493          	addi	s1,s1,1318 # 802309d8 <wait_lock>
    800024ba:	8526                	mv	a0,s1
    800024bc:	fe4fe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    800024c0:	854e                	mv	a0,s3
    800024c2:	f3bff0ef          	jal	ra,800023fc <reparent>
  wakeup(p->parent);
    800024c6:	0389b503          	ld	a0,56(s3)
    800024ca:	ec9ff0ef          	jal	ra,80002392 <wakeup>
  acquire(&p->lock);
    800024ce:	854e                	mv	a0,s3
    800024d0:	fd0fe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    800024d4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800024d8:	4795                	li	a5,5
    800024da:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800024de:	8526                	mv	a0,s1
    800024e0:	859fe0ef          	jal	ra,80000d38 <release>
  sched();
    800024e4:	d7dff0ef          	jal	ra,80002260 <sched>
  panic("zombie exit");
    800024e8:	00006517          	auipc	a0,0x6
    800024ec:	d2850513          	addi	a0,a0,-728 # 80008210 <digits+0x1d8>
    800024f0:	a98fe0ef          	jal	ra,80000788 <panic>

00000000800024f4 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800024f4:	7179                	addi	sp,sp,-48
    800024f6:	f406                	sd	ra,40(sp)
    800024f8:	f022                	sd	s0,32(sp)
    800024fa:	ec26                	sd	s1,24(sp)
    800024fc:	e84a                	sd	s2,16(sp)
    800024fe:	e44e                	sd	s3,8(sp)
    80002500:	1800                	addi	s0,sp,48
    80002502:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002504:	0022f497          	auipc	s1,0x22f
    80002508:	8ec48493          	addi	s1,s1,-1812 # 80230df0 <proc>
    8000250c:	0023e997          	auipc	s3,0x23e
    80002510:	2e498993          	addi	s3,s3,740 # 802407f0 <tickslock>
    acquire(&p->lock);
    80002514:	8526                	mv	a0,s1
    80002516:	f8afe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    8000251a:	589c                	lw	a5,48(s1)
    8000251c:	01278b63          	beq	a5,s2,80002532 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	817fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002526:	3e848493          	addi	s1,s1,1000
    8000252a:	ff3495e3          	bne	s1,s3,80002514 <kkill+0x20>
  }
  return -1;
    8000252e:	557d                	li	a0,-1
    80002530:	a819                	j	80002546 <kkill+0x52>
      p->killed = 1;
    80002532:	4785                	li	a5,1
    80002534:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002536:	4c98                	lw	a4,24(s1)
    80002538:	4789                	li	a5,2
    8000253a:	00f70d63          	beq	a4,a5,80002554 <kkill+0x60>
      release(&p->lock);
    8000253e:	8526                	mv	a0,s1
    80002540:	ff8fe0ef          	jal	ra,80000d38 <release>
      return 0;
    80002544:	4501                	li	a0,0
}
    80002546:	70a2                	ld	ra,40(sp)
    80002548:	7402                	ld	s0,32(sp)
    8000254a:	64e2                	ld	s1,24(sp)
    8000254c:	6942                	ld	s2,16(sp)
    8000254e:	69a2                	ld	s3,8(sp)
    80002550:	6145                	addi	sp,sp,48
    80002552:	8082                	ret
        p->state = RUNNABLE;
    80002554:	478d                	li	a5,3
    80002556:	cc9c                	sw	a5,24(s1)
    80002558:	b7dd                	j	8000253e <kkill+0x4a>

000000008000255a <setkilled>:

void
setkilled(struct proc *p)
{
    8000255a:	1101                	addi	sp,sp,-32
    8000255c:	ec06                	sd	ra,24(sp)
    8000255e:	e822                	sd	s0,16(sp)
    80002560:	e426                	sd	s1,8(sp)
    80002562:	1000                	addi	s0,sp,32
    80002564:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002566:	f3afe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    8000256a:	4785                	li	a5,1
    8000256c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000256e:	8526                	mv	a0,s1
    80002570:	fc8fe0ef          	jal	ra,80000d38 <release>
}
    80002574:	60e2                	ld	ra,24(sp)
    80002576:	6442                	ld	s0,16(sp)
    80002578:	64a2                	ld	s1,8(sp)
    8000257a:	6105                	addi	sp,sp,32
    8000257c:	8082                	ret

000000008000257e <killed>:

int
killed(struct proc *p)
{
    8000257e:	1101                	addi	sp,sp,-32
    80002580:	ec06                	sd	ra,24(sp)
    80002582:	e822                	sd	s0,16(sp)
    80002584:	e426                	sd	s1,8(sp)
    80002586:	e04a                	sd	s2,0(sp)
    80002588:	1000                	addi	s0,sp,32
    8000258a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000258c:	f14fe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    80002590:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	fa2fe0ef          	jal	ra,80000d38 <release>
  return k;
}
    8000259a:	854a                	mv	a0,s2
    8000259c:	60e2                	ld	ra,24(sp)
    8000259e:	6442                	ld	s0,16(sp)
    800025a0:	64a2                	ld	s1,8(sp)
    800025a2:	6902                	ld	s2,0(sp)
    800025a4:	6105                	addi	sp,sp,32
    800025a6:	8082                	ret

00000000800025a8 <kwait>:
{
    800025a8:	715d                	addi	sp,sp,-80
    800025aa:	e486                	sd	ra,72(sp)
    800025ac:	e0a2                	sd	s0,64(sp)
    800025ae:	fc26                	sd	s1,56(sp)
    800025b0:	f84a                	sd	s2,48(sp)
    800025b2:	f44e                	sd	s3,40(sp)
    800025b4:	f052                	sd	s4,32(sp)
    800025b6:	ec56                	sd	s5,24(sp)
    800025b8:	e85a                	sd	s6,16(sp)
    800025ba:	e45e                	sd	s7,8(sp)
    800025bc:	e062                	sd	s8,0(sp)
    800025be:	0880                	addi	s0,sp,80
    800025c0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025c2:	d86ff0ef          	jal	ra,80001b48 <myproc>
    800025c6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800025c8:	0022e517          	auipc	a0,0x22e
    800025cc:	41050513          	addi	a0,a0,1040 # 802309d8 <wait_lock>
    800025d0:	ed0fe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    800025d4:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800025d6:	4a15                	li	s4,5
        havekids = 1;
    800025d8:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025da:	0023e997          	auipc	s3,0x23e
    800025de:	21698993          	addi	s3,s3,534 # 802407f0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025e2:	0022ec17          	auipc	s8,0x22e
    800025e6:	3f6c0c13          	addi	s8,s8,1014 # 802309d8 <wait_lock>
    havekids = 0;
    800025ea:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ec:	0022f497          	auipc	s1,0x22f
    800025f0:	80448493          	addi	s1,s1,-2044 # 80230df0 <proc>
    800025f4:	a899                	j	8000264a <kwait+0xa2>
          pid = pp->pid;
    800025f6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025fa:	000b0c63          	beqz	s6,80002612 <kwait+0x6a>
    800025fe:	4691                	li	a3,4
    80002600:	02c48613          	addi	a2,s1,44
    80002604:	85da                	mv	a1,s6
    80002606:	05093503          	ld	a0,80(s2)
    8000260a:	960ff0ef          	jal	ra,8000176a <copyout>
    8000260e:	00054f63          	bltz	a0,8000262c <kwait+0x84>
          freeproc(pp);
    80002612:	8526                	mv	a0,s1
    80002614:	849ff0ef          	jal	ra,80001e5c <freeproc>
          release(&pp->lock);
    80002618:	8526                	mv	a0,s1
    8000261a:	f1efe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    8000261e:	0022e517          	auipc	a0,0x22e
    80002622:	3ba50513          	addi	a0,a0,954 # 802309d8 <wait_lock>
    80002626:	f12fe0ef          	jal	ra,80000d38 <release>
          return pid;
    8000262a:	a891                	j	8000267e <kwait+0xd6>
            release(&pp->lock);
    8000262c:	8526                	mv	a0,s1
    8000262e:	f0afe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    80002632:	0022e517          	auipc	a0,0x22e
    80002636:	3a650513          	addi	a0,a0,934 # 802309d8 <wait_lock>
    8000263a:	efefe0ef          	jal	ra,80000d38 <release>
            return -1;
    8000263e:	59fd                	li	s3,-1
    80002640:	a83d                	j	8000267e <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002642:	3e848493          	addi	s1,s1,1000
    80002646:	03348063          	beq	s1,s3,80002666 <kwait+0xbe>
      if(pp->parent == p){
    8000264a:	7c9c                	ld	a5,56(s1)
    8000264c:	ff279be3          	bne	a5,s2,80002642 <kwait+0x9a>
        acquire(&pp->lock);
    80002650:	8526                	mv	a0,s1
    80002652:	e4efe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    80002656:	4c9c                	lw	a5,24(s1)
    80002658:	f9478fe3          	beq	a5,s4,800025f6 <kwait+0x4e>
        release(&pp->lock);
    8000265c:	8526                	mv	a0,s1
    8000265e:	edafe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    80002662:	8756                	mv	a4,s5
    80002664:	bff9                	j	80002642 <kwait+0x9a>
    if(!havekids || killed(p)){
    80002666:	c709                	beqz	a4,80002670 <kwait+0xc8>
    80002668:	854a                	mv	a0,s2
    8000266a:	f15ff0ef          	jal	ra,8000257e <killed>
    8000266e:	c50d                	beqz	a0,80002698 <kwait+0xf0>
      release(&wait_lock);
    80002670:	0022e517          	auipc	a0,0x22e
    80002674:	36850513          	addi	a0,a0,872 # 802309d8 <wait_lock>
    80002678:	ec0fe0ef          	jal	ra,80000d38 <release>
      return -1;
    8000267c:	59fd                	li	s3,-1
}
    8000267e:	854e                	mv	a0,s3
    80002680:	60a6                	ld	ra,72(sp)
    80002682:	6406                	ld	s0,64(sp)
    80002684:	74e2                	ld	s1,56(sp)
    80002686:	7942                	ld	s2,48(sp)
    80002688:	79a2                	ld	s3,40(sp)
    8000268a:	7a02                	ld	s4,32(sp)
    8000268c:	6ae2                	ld	s5,24(sp)
    8000268e:	6b42                	ld	s6,16(sp)
    80002690:	6ba2                	ld	s7,8(sp)
    80002692:	6c02                	ld	s8,0(sp)
    80002694:	6161                	addi	sp,sp,80
    80002696:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002698:	85e2                	mv	a1,s8
    8000269a:	854a                	mv	a0,s2
    8000269c:	cabff0ef          	jal	ra,80002346 <sleep>
    havekids = 0;
    800026a0:	b7a9                	j	800025ea <kwait+0x42>

00000000800026a2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026a2:	7179                	addi	sp,sp,-48
    800026a4:	f406                	sd	ra,40(sp)
    800026a6:	f022                	sd	s0,32(sp)
    800026a8:	ec26                	sd	s1,24(sp)
    800026aa:	e84a                	sd	s2,16(sp)
    800026ac:	e44e                	sd	s3,8(sp)
    800026ae:	e052                	sd	s4,0(sp)
    800026b0:	1800                	addi	s0,sp,48
    800026b2:	84aa                	mv	s1,a0
    800026b4:	892e                	mv	s2,a1
    800026b6:	89b2                	mv	s3,a2
    800026b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026ba:	c8eff0ef          	jal	ra,80001b48 <myproc>
  if(user_dst){
    800026be:	cc99                	beqz	s1,800026dc <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800026c0:	86d2                	mv	a3,s4
    800026c2:	864e                	mv	a2,s3
    800026c4:	85ca                	mv	a1,s2
    800026c6:	6928                	ld	a0,80(a0)
    800026c8:	8a2ff0ef          	jal	ra,8000176a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026cc:	70a2                	ld	ra,40(sp)
    800026ce:	7402                	ld	s0,32(sp)
    800026d0:	64e2                	ld	s1,24(sp)
    800026d2:	6942                	ld	s2,16(sp)
    800026d4:	69a2                	ld	s3,8(sp)
    800026d6:	6a02                	ld	s4,0(sp)
    800026d8:	6145                	addi	sp,sp,48
    800026da:	8082                	ret
    memmove((char *)dst, src, len);
    800026dc:	000a061b          	sext.w	a2,s4
    800026e0:	85ce                	mv	a1,s3
    800026e2:	854a                	mv	a0,s2
    800026e4:	eecfe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    800026e8:	8526                	mv	a0,s1
    800026ea:	b7cd                	j	800026cc <either_copyout+0x2a>

00000000800026ec <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026ec:	7179                	addi	sp,sp,-48
    800026ee:	f406                	sd	ra,40(sp)
    800026f0:	f022                	sd	s0,32(sp)
    800026f2:	ec26                	sd	s1,24(sp)
    800026f4:	e84a                	sd	s2,16(sp)
    800026f6:	e44e                	sd	s3,8(sp)
    800026f8:	e052                	sd	s4,0(sp)
    800026fa:	1800                	addi	s0,sp,48
    800026fc:	892a                	mv	s2,a0
    800026fe:	84ae                	mv	s1,a1
    80002700:	89b2                	mv	s3,a2
    80002702:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002704:	c44ff0ef          	jal	ra,80001b48 <myproc>
  if(user_src){
    80002708:	cc99                	beqz	s1,80002726 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000270a:	86d2                	mv	a3,s4
    8000270c:	864e                	mv	a2,s3
    8000270e:	85ca                	mv	a1,s2
    80002710:	6928                	ld	a0,80(a0)
    80002712:	952ff0ef          	jal	ra,80001864 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002716:	70a2                	ld	ra,40(sp)
    80002718:	7402                	ld	s0,32(sp)
    8000271a:	64e2                	ld	s1,24(sp)
    8000271c:	6942                	ld	s2,16(sp)
    8000271e:	69a2                	ld	s3,8(sp)
    80002720:	6a02                	ld	s4,0(sp)
    80002722:	6145                	addi	sp,sp,48
    80002724:	8082                	ret
    memmove(dst, (char*)src, len);
    80002726:	000a061b          	sext.w	a2,s4
    8000272a:	85ce                	mv	a1,s3
    8000272c:	854a                	mv	a0,s2
    8000272e:	ea2fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    80002732:	8526                	mv	a0,s1
    80002734:	b7cd                	j	80002716 <either_copyin+0x2a>

0000000080002736 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002736:	715d                	addi	sp,sp,-80
    80002738:	e486                	sd	ra,72(sp)
    8000273a:	e0a2                	sd	s0,64(sp)
    8000273c:	fc26                	sd	s1,56(sp)
    8000273e:	f84a                	sd	s2,48(sp)
    80002740:	f44e                	sd	s3,40(sp)
    80002742:	f052                	sd	s4,32(sp)
    80002744:	ec56                	sd	s5,24(sp)
    80002746:	e85a                	sd	s6,16(sp)
    80002748:	e45e                	sd	s7,8(sp)
    8000274a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000274c:	00006517          	auipc	a0,0x6
    80002750:	97c50513          	addi	a0,a0,-1668 # 800080c8 <digits+0x90>
    80002754:	d6ffd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002758:	0022e497          	auipc	s1,0x22e
    8000275c:	7f048493          	addi	s1,s1,2032 # 80230f48 <proc+0x158>
    80002760:	0023e917          	auipc	s2,0x23e
    80002764:	1e890913          	addi	s2,s2,488 # 80240948 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002768:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000276a:	00006997          	auipc	s3,0x6
    8000276e:	ab698993          	addi	s3,s3,-1354 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    80002772:	00006a97          	auipc	s5,0x6
    80002776:	ab6a8a93          	addi	s5,s5,-1354 # 80008228 <digits+0x1f0>
    printf("\n");
    8000277a:	00006a17          	auipc	s4,0x6
    8000277e:	94ea0a13          	addi	s4,s4,-1714 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002782:	00006b97          	auipc	s7,0x6
    80002786:	ae6b8b93          	addi	s7,s7,-1306 # 80008268 <states.0>
    8000278a:	a829                	j	800027a4 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000278c:	ed86a583          	lw	a1,-296(a3)
    80002790:	8556                	mv	a0,s5
    80002792:	d31fd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80002796:	8552                	mv	a0,s4
    80002798:	d2bfd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000279c:	3e848493          	addi	s1,s1,1000
    800027a0:	03248263          	beq	s1,s2,800027c4 <procdump+0x8e>
    if(p->state == UNUSED)
    800027a4:	86a6                	mv	a3,s1
    800027a6:	ec04a783          	lw	a5,-320(s1)
    800027aa:	dbed                	beqz	a5,8000279c <procdump+0x66>
      state = "???";
    800027ac:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ae:	fcfb6fe3          	bltu	s6,a5,8000278c <procdump+0x56>
    800027b2:	02079713          	slli	a4,a5,0x20
    800027b6:	01d75793          	srli	a5,a4,0x1d
    800027ba:	97de                	add	a5,a5,s7
    800027bc:	6390                	ld	a2,0(a5)
    800027be:	f679                	bnez	a2,8000278c <procdump+0x56>
      state = "???";
    800027c0:	864e                	mv	a2,s3
    800027c2:	b7e9                	j	8000278c <procdump+0x56>
  }
}
    800027c4:	60a6                	ld	ra,72(sp)
    800027c6:	6406                	ld	s0,64(sp)
    800027c8:	74e2                	ld	s1,56(sp)
    800027ca:	7942                	ld	s2,48(sp)
    800027cc:	79a2                	ld	s3,40(sp)
    800027ce:	7a02                	ld	s4,32(sp)
    800027d0:	6ae2                	ld	s5,24(sp)
    800027d2:	6b42                	ld	s6,16(sp)
    800027d4:	6ba2                	ld	s7,8(sp)
    800027d6:	6161                	addi	sp,sp,80
    800027d8:	8082                	ret

00000000800027da <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800027da:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800027de:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800027e2:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800027e4:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800027e6:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800027ea:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800027ee:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800027f2:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800027f6:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800027fa:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800027fe:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002802:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002806:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000280a:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000280e:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002812:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002816:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002818:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000281a:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000281e:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002822:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002826:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000282a:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000282e:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002832:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002836:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000283a:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000283e:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002842:	8082                	ret

0000000080002844 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002844:	1141                	addi	sp,sp,-16
    80002846:	e406                	sd	ra,8(sp)
    80002848:	e022                	sd	s0,0(sp)
    8000284a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000284c:	00006597          	auipc	a1,0x6
    80002850:	a4c58593          	addi	a1,a1,-1460 # 80008298 <states.0+0x30>
    80002854:	0023e517          	auipc	a0,0x23e
    80002858:	f9c50513          	addi	a0,a0,-100 # 802407f0 <tickslock>
    8000285c:	bc4fe0ef          	jal	ra,80000c20 <initlock>
}
    80002860:	60a2                	ld	ra,8(sp)
    80002862:	6402                	ld	s0,0(sp)
    80002864:	0141                	addi	sp,sp,16
    80002866:	8082                	ret

0000000080002868 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002868:	1141                	addi	sp,sp,-16
    8000286a:	e422                	sd	s0,8(sp)
    8000286c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000286e:	00003797          	auipc	a5,0x3
    80002872:	45278793          	addi	a5,a5,1106 # 80005cc0 <kernelvec>
    80002876:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000287a:	6422                	ld	s0,8(sp)
    8000287c:	0141                	addi	sp,sp,16
    8000287e:	8082                	ret

0000000080002880 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002880:	1141                	addi	sp,sp,-16
    80002882:	e406                	sd	ra,8(sp)
    80002884:	e022                	sd	s0,0(sp)
    80002886:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002888:	ac0ff0ef          	jal	ra,80001b48 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000288c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002890:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002892:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002896:	04000737          	lui	a4,0x4000
    8000289a:	00004797          	auipc	a5,0x4
    8000289e:	76678793          	addi	a5,a5,1894 # 80007000 <_trampoline>
    800028a2:	00004697          	auipc	a3,0x4
    800028a6:	75e68693          	addi	a3,a3,1886 # 80007000 <_trampoline>
    800028aa:	8f95                	sub	a5,a5,a3
    800028ac:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800028ae:	0732                	slli	a4,a4,0xc
    800028b0:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028b2:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028b6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028b8:	18002773          	csrr	a4,satp
    800028bc:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028be:	6d38                	ld	a4,88(a0)
    800028c0:	613c                	ld	a5,64(a0)
    800028c2:	6685                	lui	a3,0x1
    800028c4:	97b6                	add	a5,a5,a3
    800028c6:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028c8:	6d3c                	ld	a5,88(a0)
    800028ca:	00000717          	auipc	a4,0x0
    800028ce:	0f470713          	addi	a4,a4,244 # 800029be <usertrap>
    800028d2:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028d4:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028d6:	8712                	mv	a4,tp
    800028d8:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028da:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028de:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028e2:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028e6:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028ea:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028ec:	6f9c                	ld	a5,24(a5)
    800028ee:	14179073          	csrw	sepc,a5
}
    800028f2:	60a2                	ld	ra,8(sp)
    800028f4:	6402                	ld	s0,0(sp)
    800028f6:	0141                	addi	sp,sp,16
    800028f8:	8082                	ret

00000000800028fa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028fa:	1101                	addi	sp,sp,-32
    800028fc:	ec06                	sd	ra,24(sp)
    800028fe:	e822                	sd	s0,16(sp)
    80002900:	e426                	sd	s1,8(sp)
    80002902:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002904:	a18ff0ef          	jal	ra,80001b1c <cpuid>
    80002908:	cd19                	beqz	a0,80002926 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000290a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000290e:	000f4737          	lui	a4,0xf4
    80002912:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002916:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002918:	14d79073          	csrw	0x14d,a5
}
    8000291c:	60e2                	ld	ra,24(sp)
    8000291e:	6442                	ld	s0,16(sp)
    80002920:	64a2                	ld	s1,8(sp)
    80002922:	6105                	addi	sp,sp,32
    80002924:	8082                	ret
    acquire(&tickslock);
    80002926:	0023e497          	auipc	s1,0x23e
    8000292a:	eca48493          	addi	s1,s1,-310 # 802407f0 <tickslock>
    8000292e:	8526                	mv	a0,s1
    80002930:	b70fe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    80002934:	00006517          	auipc	a0,0x6
    80002938:	f7450513          	addi	a0,a0,-140 # 800088a8 <ticks>
    8000293c:	411c                	lw	a5,0(a0)
    8000293e:	2785                	addiw	a5,a5,1
    80002940:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002942:	a51ff0ef          	jal	ra,80002392 <wakeup>
    release(&tickslock);
    80002946:	8526                	mv	a0,s1
    80002948:	bf0fe0ef          	jal	ra,80000d38 <release>
    8000294c:	bf7d                	j	8000290a <clockintr+0x10>

000000008000294e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000294e:	1101                	addi	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	e426                	sd	s1,8(sp)
    80002956:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002958:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000295c:	57fd                	li	a5,-1
    8000295e:	17fe                	slli	a5,a5,0x3f
    80002960:	07a5                	addi	a5,a5,9
    80002962:	00f70d63          	beq	a4,a5,8000297c <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002966:	57fd                	li	a5,-1
    80002968:	17fe                	slli	a5,a5,0x3f
    8000296a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000296c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000296e:	04f70463          	beq	a4,a5,800029b6 <devintr+0x68>
  }
}
    80002972:	60e2                	ld	ra,24(sp)
    80002974:	6442                	ld	s0,16(sp)
    80002976:	64a2                	ld	s1,8(sp)
    80002978:	6105                	addi	sp,sp,32
    8000297a:	8082                	ret
    int irq = plic_claim();
    8000297c:	3ec030ef          	jal	ra,80005d68 <plic_claim>
    80002980:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002982:	47a9                	li	a5,10
    80002984:	02f50363          	beq	a0,a5,800029aa <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002988:	4785                	li	a5,1
    8000298a:	02f50363          	beq	a0,a5,800029b0 <devintr+0x62>
    return 1;
    8000298e:	4505                	li	a0,1
    } else if(irq){
    80002990:	d0ed                	beqz	s1,80002972 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002992:	85a6                	mv	a1,s1
    80002994:	00006517          	auipc	a0,0x6
    80002998:	90c50513          	addi	a0,a0,-1780 # 800082a0 <states.0+0x38>
    8000299c:	b27fd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    800029a0:	8526                	mv	a0,s1
    800029a2:	3e6030ef          	jal	ra,80005d88 <plic_complete>
    return 1;
    800029a6:	4505                	li	a0,1
    800029a8:	b7e9                	j	80002972 <devintr+0x24>
      uartintr();
    800029aa:	fabfd0ef          	jal	ra,80000954 <uartintr>
    800029ae:	bfcd                	j	800029a0 <devintr+0x52>
      virtio_disk_intr();
    800029b0:	045030ef          	jal	ra,800061f4 <virtio_disk_intr>
    800029b4:	b7f5                	j	800029a0 <devintr+0x52>
    clockintr();
    800029b6:	f45ff0ef          	jal	ra,800028fa <clockintr>
    return 2;
    800029ba:	4509                	li	a0,2
    800029bc:	bf5d                	j	80002972 <devintr+0x24>

00000000800029be <usertrap>:
{
    800029be:	7179                	addi	sp,sp,-48
    800029c0:	f406                	sd	ra,40(sp)
    800029c2:	f022                	sd	s0,32(sp)
    800029c4:	ec26                	sd	s1,24(sp)
    800029c6:	e84a                	sd	s2,16(sp)
    800029c8:	e44e                	sd	s3,8(sp)
    800029ca:	e052                	sd	s4,0(sp)
    800029cc:	1800                	addi	s0,sp,48
    800029ce:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029d2:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029da:	1007f793          	andi	a5,a5,256
    800029de:	e3bd                	bnez	a5,80002a44 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e0:	00003797          	auipc	a5,0x3
    800029e4:	2e078793          	addi	a5,a5,736 # 80005cc0 <kernelvec>
    800029e8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029ec:	95cff0ef          	jal	ra,80001b48 <myproc>
    800029f0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029f2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029f4:	14102773          	csrr	a4,sepc
    800029f8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029fa:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800029fe:	47a1                	li	a5,8
    80002a00:	04f70863          	beq	a4,a5,80002a50 <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002a04:	f4bff0ef          	jal	ra,8000294e <devintr>
    80002a08:	892a                	mv	s2,a0
    80002a0a:	0c051e63          	bnez	a0,80002ae6 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002a0e:	47b5                	li	a5,13
    80002a10:	08f98663          	beq	s3,a5,80002a9c <usertrap+0xde>
    80002a14:	47bd                	li	a5,15
    80002a16:	0af99363          	bne	s3,a5,80002abc <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002a1a:	85d2                	mv	a1,s4
    80002a1c:	68a8                	ld	a0,80(s1)
    80002a1e:	b23fe0ef          	jal	ra,80001540 <cowbreak>
    80002a22:	c531                	beqz	a0,80002a6e <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    80002a24:	4605                	li	a2,1
    80002a26:	85d2                	mv	a1,s4
    80002a28:	8526                	mv	a0,s1
    80002a2a:	ec9fe0ef          	jal	ra,800018f2 <vmafault>
    80002a2e:	e121                	bnez	a0,80002a6e <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    80002a30:	4601                	li	a2,0
    80002a32:	85d2                	mv	a1,s4
    80002a34:	68a8                	ld	a0,80(s1)
    80002a36:	cc3fe0ef          	jal	ra,800016f8 <vmfault>
    80002a3a:	e915                	bnez	a0,80002a6e <usertrap+0xb0>
        setkilled(p);
    80002a3c:	8526                	mv	a0,s1
    80002a3e:	b1dff0ef          	jal	ra,8000255a <setkilled>
    80002a42:	a035                	j	80002a6e <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002a44:	00006517          	auipc	a0,0x6
    80002a48:	87c50513          	addi	a0,a0,-1924 # 800082c0 <states.0+0x58>
    80002a4c:	d3dfd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    80002a50:	b2fff0ef          	jal	ra,8000257e <killed>
    80002a54:	e121                	bnez	a0,80002a94 <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002a56:	6cb8                	ld	a4,88(s1)
    80002a58:	6f1c                	ld	a5,24(a4)
    80002a5a:	0791                	addi	a5,a5,4
    80002a5c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a5e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a62:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a66:	10079073          	csrw	sstatus,a5
    syscall();
    80002a6a:	27c000ef          	jal	ra,80002ce6 <syscall>
  if(killed(p))
    80002a6e:	8526                	mv	a0,s1
    80002a70:	b0fff0ef          	jal	ra,8000257e <killed>
    80002a74:	ed35                	bnez	a0,80002af0 <usertrap+0x132>
  prepare_return();
    80002a76:	e0bff0ef          	jal	ra,80002880 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a7a:	68a8                	ld	a0,80(s1)
    80002a7c:	8131                	srli	a0,a0,0xc
    80002a7e:	57fd                	li	a5,-1
    80002a80:	17fe                	slli	a5,a5,0x3f
    80002a82:	8d5d                	or	a0,a0,a5
}
    80002a84:	70a2                	ld	ra,40(sp)
    80002a86:	7402                	ld	s0,32(sp)
    80002a88:	64e2                	ld	s1,24(sp)
    80002a8a:	6942                	ld	s2,16(sp)
    80002a8c:	69a2                	ld	s3,8(sp)
    80002a8e:	6a02                	ld	s4,0(sp)
    80002a90:	6145                	addi	sp,sp,48
    80002a92:	8082                	ret
      kexit(-1);
    80002a94:	557d                	li	a0,-1
    80002a96:	9bdff0ef          	jal	ra,80002452 <kexit>
    80002a9a:	bf75                	j	80002a56 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002a9c:	4601                	li	a2,0
    80002a9e:	85d2                	mv	a1,s4
    80002aa0:	8526                	mv	a0,s1
    80002aa2:	e51fe0ef          	jal	ra,800018f2 <vmafault>
    80002aa6:	f561                	bnez	a0,80002a6e <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002aa8:	4605                	li	a2,1
    80002aaa:	85d2                	mv	a1,s4
    80002aac:	68a8                	ld	a0,80(s1)
    80002aae:	c4bfe0ef          	jal	ra,800016f8 <vmfault>
    80002ab2:	fd55                	bnez	a0,80002a6e <usertrap+0xb0>
        setkilled(p);
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	aa5ff0ef          	jal	ra,8000255a <setkilled>
    80002aba:	bf55                	j	80002a6e <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002abc:	5890                	lw	a2,48(s1)
    80002abe:	85ce                	mv	a1,s3
    80002ac0:	00006517          	auipc	a0,0x6
    80002ac4:	82050513          	addi	a0,a0,-2016 # 800082e0 <states.0+0x78>
    80002ac8:	9fbfd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002acc:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002ad0:	8652                	mv	a2,s4
    80002ad2:	00006517          	auipc	a0,0x6
    80002ad6:	83e50513          	addi	a0,a0,-1986 # 80008310 <states.0+0xa8>
    80002ada:	9e9fd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	a7bff0ef          	jal	ra,8000255a <setkilled>
    80002ae4:	b769                	j	80002a6e <usertrap+0xb0>
  if(killed(p))
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	a97ff0ef          	jal	ra,8000257e <killed>
    80002aec:	c511                	beqz	a0,80002af8 <usertrap+0x13a>
    80002aee:	a011                	j	80002af2 <usertrap+0x134>
    80002af0:	4901                	li	s2,0
    kexit(-1);
    80002af2:	557d                	li	a0,-1
    80002af4:	95fff0ef          	jal	ra,80002452 <kexit>
  if(which_dev == 2)
    80002af8:	4789                	li	a5,2
    80002afa:	f6f91ee3          	bne	s2,a5,80002a76 <usertrap+0xb8>
    yield();
    80002afe:	81dff0ef          	jal	ra,8000231a <yield>
    80002b02:	bf95                	j	80002a76 <usertrap+0xb8>

0000000080002b04 <kerneltrap>:
{
    80002b04:	7179                	addi	sp,sp,-48
    80002b06:	f406                	sd	ra,40(sp)
    80002b08:	f022                	sd	s0,32(sp)
    80002b0a:	ec26                	sd	s1,24(sp)
    80002b0c:	e84a                	sd	s2,16(sp)
    80002b0e:	e44e                	sd	s3,8(sp)
    80002b10:	1800                	addi	s0,sp,48
    80002b12:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b16:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b1e:	1004f793          	andi	a5,s1,256
    80002b22:	c795                	beqz	a5,80002b4e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b24:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b28:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b2a:	eb85                	bnez	a5,80002b5a <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002b2c:	e23ff0ef          	jal	ra,8000294e <devintr>
    80002b30:	c91d                	beqz	a0,80002b66 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002b32:	4789                	li	a5,2
    80002b34:	04f50a63          	beq	a0,a5,80002b88 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b38:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b3c:	10049073          	csrw	sstatus,s1
}
    80002b40:	70a2                	ld	ra,40(sp)
    80002b42:	7402                	ld	s0,32(sp)
    80002b44:	64e2                	ld	s1,24(sp)
    80002b46:	6942                	ld	s2,16(sp)
    80002b48:	69a2                	ld	s3,8(sp)
    80002b4a:	6145                	addi	sp,sp,48
    80002b4c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b4e:	00005517          	auipc	a0,0x5
    80002b52:	7ea50513          	addi	a0,a0,2026 # 80008338 <states.0+0xd0>
    80002b56:	c33fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	80650513          	addi	a0,a0,-2042 # 80008360 <states.0+0xf8>
    80002b62:	c27fd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b66:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b6a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002b6e:	85ce                	mv	a1,s3
    80002b70:	00006517          	auipc	a0,0x6
    80002b74:	81050513          	addi	a0,a0,-2032 # 80008380 <states.0+0x118>
    80002b78:	94bfd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002b7c:	00006517          	auipc	a0,0x6
    80002b80:	82c50513          	addi	a0,a0,-2004 # 800083a8 <states.0+0x140>
    80002b84:	c05fd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002b88:	fc1fe0ef          	jal	ra,80001b48 <myproc>
    80002b8c:	d555                	beqz	a0,80002b38 <kerneltrap+0x34>
    yield();
    80002b8e:	f8cff0ef          	jal	ra,8000231a <yield>
    80002b92:	b75d                	j	80002b38 <kerneltrap+0x34>

0000000080002b94 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b94:	1101                	addi	sp,sp,-32
    80002b96:	ec06                	sd	ra,24(sp)
    80002b98:	e822                	sd	s0,16(sp)
    80002b9a:	e426                	sd	s1,8(sp)
    80002b9c:	1000                	addi	s0,sp,32
    80002b9e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ba0:	fa9fe0ef          	jal	ra,80001b48 <myproc>
  switch (n) {
    80002ba4:	4795                	li	a5,5
    80002ba6:	0497e163          	bltu	a5,s1,80002be8 <argraw+0x54>
    80002baa:	048a                	slli	s1,s1,0x2
    80002bac:	00006717          	auipc	a4,0x6
    80002bb0:	83470713          	addi	a4,a4,-1996 # 800083e0 <states.0+0x178>
    80002bb4:	94ba                	add	s1,s1,a4
    80002bb6:	409c                	lw	a5,0(s1)
    80002bb8:	97ba                	add	a5,a5,a4
    80002bba:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bbc:	6d3c                	ld	a5,88(a0)
    80002bbe:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bc0:	60e2                	ld	ra,24(sp)
    80002bc2:	6442                	ld	s0,16(sp)
    80002bc4:	64a2                	ld	s1,8(sp)
    80002bc6:	6105                	addi	sp,sp,32
    80002bc8:	8082                	ret
    return p->trapframe->a1;
    80002bca:	6d3c                	ld	a5,88(a0)
    80002bcc:	7fa8                	ld	a0,120(a5)
    80002bce:	bfcd                	j	80002bc0 <argraw+0x2c>
    return p->trapframe->a2;
    80002bd0:	6d3c                	ld	a5,88(a0)
    80002bd2:	63c8                	ld	a0,128(a5)
    80002bd4:	b7f5                	j	80002bc0 <argraw+0x2c>
    return p->trapframe->a3;
    80002bd6:	6d3c                	ld	a5,88(a0)
    80002bd8:	67c8                	ld	a0,136(a5)
    80002bda:	b7dd                	j	80002bc0 <argraw+0x2c>
    return p->trapframe->a4;
    80002bdc:	6d3c                	ld	a5,88(a0)
    80002bde:	6bc8                	ld	a0,144(a5)
    80002be0:	b7c5                	j	80002bc0 <argraw+0x2c>
    return p->trapframe->a5;
    80002be2:	6d3c                	ld	a5,88(a0)
    80002be4:	6fc8                	ld	a0,152(a5)
    80002be6:	bfe9                	j	80002bc0 <argraw+0x2c>
  panic("argraw");
    80002be8:	00005517          	auipc	a0,0x5
    80002bec:	7d050513          	addi	a0,a0,2000 # 800083b8 <states.0+0x150>
    80002bf0:	b99fd0ef          	jal	ra,80000788 <panic>

0000000080002bf4 <fetchaddr>:
{
    80002bf4:	1101                	addi	sp,sp,-32
    80002bf6:	ec06                	sd	ra,24(sp)
    80002bf8:	e822                	sd	s0,16(sp)
    80002bfa:	e426                	sd	s1,8(sp)
    80002bfc:	e04a                	sd	s2,0(sp)
    80002bfe:	1000                	addi	s0,sp,32
    80002c00:	84aa                	mv	s1,a0
    80002c02:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c04:	f45fe0ef          	jal	ra,80001b48 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c08:	653c                	ld	a5,72(a0)
    80002c0a:	02f4f663          	bgeu	s1,a5,80002c36 <fetchaddr+0x42>
    80002c0e:	00848713          	addi	a4,s1,8
    80002c12:	02e7e463          	bltu	a5,a4,80002c3a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c16:	46a1                	li	a3,8
    80002c18:	8626                	mv	a2,s1
    80002c1a:	85ca                	mv	a1,s2
    80002c1c:	6928                	ld	a0,80(a0)
    80002c1e:	c47fe0ef          	jal	ra,80001864 <copyin>
    80002c22:	00a03533          	snez	a0,a0
    80002c26:	40a00533          	neg	a0,a0
}
    80002c2a:	60e2                	ld	ra,24(sp)
    80002c2c:	6442                	ld	s0,16(sp)
    80002c2e:	64a2                	ld	s1,8(sp)
    80002c30:	6902                	ld	s2,0(sp)
    80002c32:	6105                	addi	sp,sp,32
    80002c34:	8082                	ret
    return -1;
    80002c36:	557d                	li	a0,-1
    80002c38:	bfcd                	j	80002c2a <fetchaddr+0x36>
    80002c3a:	557d                	li	a0,-1
    80002c3c:	b7fd                	j	80002c2a <fetchaddr+0x36>

0000000080002c3e <fetchstr>:
{
    80002c3e:	7179                	addi	sp,sp,-48
    80002c40:	f406                	sd	ra,40(sp)
    80002c42:	f022                	sd	s0,32(sp)
    80002c44:	ec26                	sd	s1,24(sp)
    80002c46:	e84a                	sd	s2,16(sp)
    80002c48:	e44e                	sd	s3,8(sp)
    80002c4a:	1800                	addi	s0,sp,48
    80002c4c:	892a                	mv	s2,a0
    80002c4e:	84ae                	mv	s1,a1
    80002c50:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c52:	ef7fe0ef          	jal	ra,80001b48 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c56:	86ce                	mv	a3,s3
    80002c58:	864a                	mv	a2,s2
    80002c5a:	85a6                	mv	a1,s1
    80002c5c:	6928                	ld	a0,80(a0)
    80002c5e:	9cffe0ef          	jal	ra,8000162c <copyinstr>
    80002c62:	00054c63          	bltz	a0,80002c7a <fetchstr+0x3c>
  return strlen(buf);
    80002c66:	8526                	mv	a0,s1
    80002c68:	a84fe0ef          	jal	ra,80000eec <strlen>
}
    80002c6c:	70a2                	ld	ra,40(sp)
    80002c6e:	7402                	ld	s0,32(sp)
    80002c70:	64e2                	ld	s1,24(sp)
    80002c72:	6942                	ld	s2,16(sp)
    80002c74:	69a2                	ld	s3,8(sp)
    80002c76:	6145                	addi	sp,sp,48
    80002c78:	8082                	ret
    return -1;
    80002c7a:	557d                	li	a0,-1
    80002c7c:	bfc5                	j	80002c6c <fetchstr+0x2e>

0000000080002c7e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c7e:	1101                	addi	sp,sp,-32
    80002c80:	ec06                	sd	ra,24(sp)
    80002c82:	e822                	sd	s0,16(sp)
    80002c84:	e426                	sd	s1,8(sp)
    80002c86:	1000                	addi	s0,sp,32
    80002c88:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c8a:	f0bff0ef          	jal	ra,80002b94 <argraw>
    80002c8e:	c088                	sw	a0,0(s1)
}
    80002c90:	60e2                	ld	ra,24(sp)
    80002c92:	6442                	ld	s0,16(sp)
    80002c94:	64a2                	ld	s1,8(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret

0000000080002c9a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c9a:	1101                	addi	sp,sp,-32
    80002c9c:	ec06                	sd	ra,24(sp)
    80002c9e:	e822                	sd	s0,16(sp)
    80002ca0:	e426                	sd	s1,8(sp)
    80002ca2:	1000                	addi	s0,sp,32
    80002ca4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ca6:	eefff0ef          	jal	ra,80002b94 <argraw>
    80002caa:	e088                	sd	a0,0(s1)
}
    80002cac:	60e2                	ld	ra,24(sp)
    80002cae:	6442                	ld	s0,16(sp)
    80002cb0:	64a2                	ld	s1,8(sp)
    80002cb2:	6105                	addi	sp,sp,32
    80002cb4:	8082                	ret

0000000080002cb6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002cb6:	7179                	addi	sp,sp,-48
    80002cb8:	f406                	sd	ra,40(sp)
    80002cba:	f022                	sd	s0,32(sp)
    80002cbc:	ec26                	sd	s1,24(sp)
    80002cbe:	e84a                	sd	s2,16(sp)
    80002cc0:	1800                	addi	s0,sp,48
    80002cc2:	84ae                	mv	s1,a1
    80002cc4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002cc6:	fd840593          	addi	a1,s0,-40
    80002cca:	fd1ff0ef          	jal	ra,80002c9a <argaddr>
  return fetchstr(addr, buf, max);
    80002cce:	864a                	mv	a2,s2
    80002cd0:	85a6                	mv	a1,s1
    80002cd2:	fd843503          	ld	a0,-40(s0)
    80002cd6:	f69ff0ef          	jal	ra,80002c3e <fetchstr>
}
    80002cda:	70a2                	ld	ra,40(sp)
    80002cdc:	7402                	ld	s0,32(sp)
    80002cde:	64e2                	ld	s1,24(sp)
    80002ce0:	6942                	ld	s2,16(sp)
    80002ce2:	6145                	addi	sp,sp,48
    80002ce4:	8082                	ret

0000000080002ce6 <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80002ce6:	1101                	addi	sp,sp,-32
    80002ce8:	ec06                	sd	ra,24(sp)
    80002cea:	e822                	sd	s0,16(sp)
    80002cec:	e426                	sd	s1,8(sp)
    80002cee:	e04a                	sd	s2,0(sp)
    80002cf0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002cf2:	e57fe0ef          	jal	ra,80001b48 <myproc>
    80002cf6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002cf8:	05853903          	ld	s2,88(a0)
    80002cfc:	0a893783          	ld	a5,168(s2)
    80002d00:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d04:	37fd                	addiw	a5,a5,-1
    80002d06:	4759                	li	a4,22
    80002d08:	00f76f63          	bltu	a4,a5,80002d26 <syscall+0x40>
    80002d0c:	00369713          	slli	a4,a3,0x3
    80002d10:	00005797          	auipc	a5,0x5
    80002d14:	6e878793          	addi	a5,a5,1768 # 800083f8 <syscalls>
    80002d18:	97ba                	add	a5,a5,a4
    80002d1a:	639c                	ld	a5,0(a5)
    80002d1c:	c789                	beqz	a5,80002d26 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d1e:	9782                	jalr	a5
    80002d20:	06a93823          	sd	a0,112(s2)
    80002d24:	a829                	j	80002d3e <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d26:	15848613          	addi	a2,s1,344
    80002d2a:	588c                	lw	a1,48(s1)
    80002d2c:	00005517          	auipc	a0,0x5
    80002d30:	69450513          	addi	a0,a0,1684 # 800083c0 <states.0+0x158>
    80002d34:	f8efd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d38:	6cbc                	ld	a5,88(s1)
    80002d3a:	577d                	li	a4,-1
    80002d3c:	fbb8                	sd	a4,112(a5)
  }
}
    80002d3e:	60e2                	ld	ra,24(sp)
    80002d40:	6442                	ld	s0,16(sp)
    80002d42:	64a2                	ld	s1,8(sp)
    80002d44:	6902                	ld	s2,0(sp)
    80002d46:	6105                	addi	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <proc_has_shm_key>:
  }
  return best;
}
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
    80002d4a:	1141                	addi	sp,sp,-16
    80002d4c:	e422                	sd	s0,8(sp)
    80002d4e:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002d50:	16850793          	addi	a5,a0,360
    80002d54:	3e850513          	addi	a0,a0,1000
    80002d58:	a029                	j	80002d62 <proc_has_shm_key+0x18>
    80002d5a:	02878793          	addi	a5,a5,40
    80002d5e:	00a78d63          	beq	a5,a0,80002d78 <proc_has_shm_key+0x2e>
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    80002d62:	fef60ce3          	beq	a2,a5,80002d5a <proc_has_shm_key+0x10>
    if(v->used && v->is_shm && v->shm_key == key)
    80002d66:	4398                	lw	a4,0(a5)
    80002d68:	db6d                	beqz	a4,80002d5a <proc_has_shm_key+0x10>
    80002d6a:	5398                	lw	a4,32(a5)
    80002d6c:	d77d                	beqz	a4,80002d5a <proc_has_shm_key+0x10>
    80002d6e:	53d8                	lw	a4,36(a5)
    80002d70:	feb715e3          	bne	a4,a1,80002d5a <proc_has_shm_key+0x10>
      return 1;
    80002d74:	4505                	li	a0,1
    80002d76:	a011                	j	80002d7a <proc_has_shm_key+0x30>
  }
  return 0;
    80002d78:	4501                	li	a0,0
}
    80002d7a:	6422                	ld	s0,8(sp)
    80002d7c:	0141                	addi	sp,sp,16
    80002d7e:	8082                	ret

0000000080002d80 <sys_exit>:
{
    80002d80:	1101                	addi	sp,sp,-32
    80002d82:	ec06                	sd	ra,24(sp)
    80002d84:	e822                	sd	s0,16(sp)
    80002d86:	1000                	addi	s0,sp,32
  argint(0, &n);
    80002d88:	fec40593          	addi	a1,s0,-20
    80002d8c:	4501                	li	a0,0
    80002d8e:	ef1ff0ef          	jal	ra,80002c7e <argint>
  kexit(n);
    80002d92:	fec42503          	lw	a0,-20(s0)
    80002d96:	ebcff0ef          	jal	ra,80002452 <kexit>
}
    80002d9a:	4501                	li	a0,0
    80002d9c:	60e2                	ld	ra,24(sp)
    80002d9e:	6442                	ld	s0,16(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <sys_getpid>:
{
    80002da4:	1141                	addi	sp,sp,-16
    80002da6:	e406                	sd	ra,8(sp)
    80002da8:	e022                	sd	s0,0(sp)
    80002daa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dac:	d9dfe0ef          	jal	ra,80001b48 <myproc>
}
    80002db0:	5908                	lw	a0,48(a0)
    80002db2:	60a2                	ld	ra,8(sp)
    80002db4:	6402                	ld	s0,0(sp)
    80002db6:	0141                	addi	sp,sp,16
    80002db8:	8082                	ret

0000000080002dba <sys_fork>:
{
    80002dba:	1141                	addi	sp,sp,-16
    80002dbc:	e406                	sd	ra,8(sp)
    80002dbe:	e022                	sd	s0,0(sp)
    80002dc0:	0800                	addi	s0,sp,16
  return kfork();
    80002dc2:	a50ff0ef          	jal	ra,80002012 <kfork>
}
    80002dc6:	60a2                	ld	ra,8(sp)
    80002dc8:	6402                	ld	s0,0(sp)
    80002dca:	0141                	addi	sp,sp,16
    80002dcc:	8082                	ret

0000000080002dce <sys_wait>:
{
    80002dce:	1101                	addi	sp,sp,-32
    80002dd0:	ec06                	sd	ra,24(sp)
    80002dd2:	e822                	sd	s0,16(sp)
    80002dd4:	1000                	addi	s0,sp,32
  argaddr(0, &p);
    80002dd6:	fe840593          	addi	a1,s0,-24
    80002dda:	4501                	li	a0,0
    80002ddc:	ebfff0ef          	jal	ra,80002c9a <argaddr>
  return kwait(p);
    80002de0:	fe843503          	ld	a0,-24(s0)
    80002de4:	fc4ff0ef          	jal	ra,800025a8 <kwait>
}
    80002de8:	60e2                	ld	ra,24(sp)
    80002dea:	6442                	ld	s0,16(sp)
    80002dec:	6105                	addi	sp,sp,32
    80002dee:	8082                	ret

0000000080002df0 <sys_sbrk>:
{
    80002df0:	7179                	addi	sp,sp,-48
    80002df2:	f406                	sd	ra,40(sp)
    80002df4:	f022                	sd	s0,32(sp)
    80002df6:	ec26                	sd	s1,24(sp)
    80002df8:	1800                	addi	s0,sp,48
  argint(0, &n);
    80002dfa:	fd840593          	addi	a1,s0,-40
    80002dfe:	4501                	li	a0,0
    80002e00:	e7fff0ef          	jal	ra,80002c7e <argint>
  argint(1, &t);
    80002e04:	fdc40593          	addi	a1,s0,-36
    80002e08:	4505                	li	a0,1
    80002e0a:	e75ff0ef          	jal	ra,80002c7e <argint>
  addr = myproc()->sz;
    80002e0e:	d3bfe0ef          	jal	ra,80001b48 <myproc>
    80002e12:	6524                	ld	s1,72(a0)
  if(t == SBRK_EAGER || n < 0) {
    80002e14:	fdc42703          	lw	a4,-36(s0)
    80002e18:	4785                	li	a5,1
    80002e1a:	02f70763          	beq	a4,a5,80002e48 <sys_sbrk+0x58>
    80002e1e:	fd842783          	lw	a5,-40(s0)
    80002e22:	0207c363          	bltz	a5,80002e48 <sys_sbrk+0x58>
    if(addr + n < addr)
    80002e26:	97a6                	add	a5,a5,s1
    80002e28:	0297ee63          	bltu	a5,s1,80002e64 <sys_sbrk+0x74>
    if(addr + n > TRAPFRAME)
    80002e2c:	02000737          	lui	a4,0x2000
    80002e30:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002e32:	0736                	slli	a4,a4,0xd
    80002e34:	02f76a63          	bltu	a4,a5,80002e68 <sys_sbrk+0x78>
    myproc()->sz += n;
    80002e38:	d11fe0ef          	jal	ra,80001b48 <myproc>
    80002e3c:	fd842703          	lw	a4,-40(s0)
    80002e40:	653c                	ld	a5,72(a0)
    80002e42:	97ba                	add	a5,a5,a4
    80002e44:	e53c                	sd	a5,72(a0)
    80002e46:	a039                	j	80002e54 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002e48:	fd842503          	lw	a0,-40(s0)
    80002e4c:	964ff0ef          	jal	ra,80001fb0 <growproc>
    80002e50:	00054863          	bltz	a0,80002e60 <sys_sbrk+0x70>
}
    80002e54:	8526                	mv	a0,s1
    80002e56:	70a2                	ld	ra,40(sp)
    80002e58:	7402                	ld	s0,32(sp)
    80002e5a:	64e2                	ld	s1,24(sp)
    80002e5c:	6145                	addi	sp,sp,48
    80002e5e:	8082                	ret
      return -1;
    80002e60:	54fd                	li	s1,-1
    80002e62:	bfcd                	j	80002e54 <sys_sbrk+0x64>
      return -1;
    80002e64:	54fd                	li	s1,-1
    80002e66:	b7fd                	j	80002e54 <sys_sbrk+0x64>
      return -1;
    80002e68:	54fd                	li	s1,-1
    80002e6a:	b7ed                	j	80002e54 <sys_sbrk+0x64>

0000000080002e6c <sys_pause>:
{
    80002e6c:	7139                	addi	sp,sp,-64
    80002e6e:	fc06                	sd	ra,56(sp)
    80002e70:	f822                	sd	s0,48(sp)
    80002e72:	f426                	sd	s1,40(sp)
    80002e74:	f04a                	sd	s2,32(sp)
    80002e76:	ec4e                	sd	s3,24(sp)
    80002e78:	0080                	addi	s0,sp,64
  argint(0, &n);
    80002e7a:	fcc40593          	addi	a1,s0,-52
    80002e7e:	4501                	li	a0,0
    80002e80:	dffff0ef          	jal	ra,80002c7e <argint>
  if(n < 0)
    80002e84:	fcc42783          	lw	a5,-52(s0)
    80002e88:	0607c563          	bltz	a5,80002ef2 <sys_pause+0x86>
  acquire(&tickslock);
    80002e8c:	0023e517          	auipc	a0,0x23e
    80002e90:	96450513          	addi	a0,a0,-1692 # 802407f0 <tickslock>
    80002e94:	e0dfd0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002e98:	00006917          	auipc	s2,0x6
    80002e9c:	a1092903          	lw	s2,-1520(s2) # 800088a8 <ticks>
  while(ticks - ticks0 < n){
    80002ea0:	fcc42783          	lw	a5,-52(s0)
    80002ea4:	cb8d                	beqz	a5,80002ed6 <sys_pause+0x6a>
    sleep(&ticks, &tickslock);
    80002ea6:	0023e997          	auipc	s3,0x23e
    80002eaa:	94a98993          	addi	s3,s3,-1718 # 802407f0 <tickslock>
    80002eae:	00006497          	auipc	s1,0x6
    80002eb2:	9fa48493          	addi	s1,s1,-1542 # 800088a8 <ticks>
    if(killed(myproc())){
    80002eb6:	c93fe0ef          	jal	ra,80001b48 <myproc>
    80002eba:	ec4ff0ef          	jal	ra,8000257e <killed>
    80002ebe:	ed0d                	bnez	a0,80002ef8 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002ec0:	85ce                	mv	a1,s3
    80002ec2:	8526                	mv	a0,s1
    80002ec4:	c82ff0ef          	jal	ra,80002346 <sleep>
  while(ticks - ticks0 < n){
    80002ec8:	409c                	lw	a5,0(s1)
    80002eca:	412787bb          	subw	a5,a5,s2
    80002ece:	fcc42703          	lw	a4,-52(s0)
    80002ed2:	fee7e2e3          	bltu	a5,a4,80002eb6 <sys_pause+0x4a>
  release(&tickslock);
    80002ed6:	0023e517          	auipc	a0,0x23e
    80002eda:	91a50513          	addi	a0,a0,-1766 # 802407f0 <tickslock>
    80002ede:	e5bfd0ef          	jal	ra,80000d38 <release>
  return 0;
    80002ee2:	4501                	li	a0,0
}
    80002ee4:	70e2                	ld	ra,56(sp)
    80002ee6:	7442                	ld	s0,48(sp)
    80002ee8:	74a2                	ld	s1,40(sp)
    80002eea:	7902                	ld	s2,32(sp)
    80002eec:	69e2                	ld	s3,24(sp)
    80002eee:	6121                	addi	sp,sp,64
    80002ef0:	8082                	ret
    n = 0;
    80002ef2:	fc042623          	sw	zero,-52(s0)
    80002ef6:	bf59                	j	80002e8c <sys_pause+0x20>
      release(&tickslock);
    80002ef8:	0023e517          	auipc	a0,0x23e
    80002efc:	8f850513          	addi	a0,a0,-1800 # 802407f0 <tickslock>
    80002f00:	e39fd0ef          	jal	ra,80000d38 <release>
      return -1;
    80002f04:	557d                	li	a0,-1
    80002f06:	bff9                	j	80002ee4 <sys_pause+0x78>

0000000080002f08 <sys_kill>:
{
    80002f08:	1101                	addi	sp,sp,-32
    80002f0a:	ec06                	sd	ra,24(sp)
    80002f0c:	e822                	sd	s0,16(sp)
    80002f0e:	1000                	addi	s0,sp,32
  argint(0, &pid);
    80002f10:	fec40593          	addi	a1,s0,-20
    80002f14:	4501                	li	a0,0
    80002f16:	d69ff0ef          	jal	ra,80002c7e <argint>
  return kkill(pid);
    80002f1a:	fec42503          	lw	a0,-20(s0)
    80002f1e:	dd6ff0ef          	jal	ra,800024f4 <kkill>
}
    80002f22:	60e2                	ld	ra,24(sp)
    80002f24:	6442                	ld	s0,16(sp)
    80002f26:	6105                	addi	sp,sp,32
    80002f28:	8082                	ret

0000000080002f2a <sys_uptime>:
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002f34:	0023e517          	auipc	a0,0x23e
    80002f38:	8bc50513          	addi	a0,a0,-1860 # 802407f0 <tickslock>
    80002f3c:	d65fd0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    80002f40:	00006497          	auipc	s1,0x6
    80002f44:	9684a483          	lw	s1,-1688(s1) # 800088a8 <ticks>
  release(&tickslock);
    80002f48:	0023e517          	auipc	a0,0x23e
    80002f4c:	8a850513          	addi	a0,a0,-1880 # 802407f0 <tickslock>
    80002f50:	de9fd0ef          	jal	ra,80000d38 <release>
}
    80002f54:	02049513          	slli	a0,s1,0x20
    80002f58:	9101                	srli	a0,a0,0x20
    80002f5a:	60e2                	ld	ra,24(sp)
    80002f5c:	6442                	ld	s0,16(sp)
    80002f5e:	64a2                	ld	s1,8(sp)
    80002f60:	6105                	addi	sp,sp,32
    80002f62:	8082                	ret

0000000080002f64 <vma_find>:
{
    80002f64:	1141                	addi	sp,sp,-16
    80002f66:	e422                	sd	s0,8(sp)
    80002f68:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002f6a:	16850793          	addi	a5,a0,360
    80002f6e:	4701                	li	a4,0
    80002f70:	4841                	li	a6,16
    80002f72:	a031                	j	80002f7e <vma_find+0x1a>
    80002f74:	2705                	addiw	a4,a4,1
    80002f76:	02878793          	addi	a5,a5,40
    80002f7a:	03070263          	beq	a4,a6,80002f9e <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    80002f7e:	4394                	lw	a3,0(a5)
    80002f80:	daf5                	beqz	a3,80002f74 <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    80002f82:	6794                	ld	a3,8(a5)
    80002f84:	fed5e8e3          	bltu	a1,a3,80002f74 <vma_find+0x10>
    80002f88:	6b94                	ld	a3,16(a5)
    80002f8a:	fed5f5e3          	bgeu	a1,a3,80002f74 <vma_find+0x10>
      return &p->vmas[i];
    80002f8e:	00271793          	slli	a5,a4,0x2
    80002f92:	97ba                	add	a5,a5,a4
    80002f94:	078e                	slli	a5,a5,0x3
    80002f96:	16878793          	addi	a5,a5,360
    80002f9a:	953e                	add	a0,a0,a5
    80002f9c:	a011                	j	80002fa0 <vma_find+0x3c>
  return 0;
    80002f9e:	4501                	li	a0,0
}
    80002fa0:	6422                	ld	s0,8(sp)
    80002fa2:	0141                	addi	sp,sp,16
    80002fa4:	8082                	ret

0000000080002fa6 <sys_mmap>:
uint64
sys_mmap(void)
{
    80002fa6:	711d                	addi	sp,sp,-96
    80002fa8:	ec86                	sd	ra,88(sp)
    80002faa:	e8a2                	sd	s0,80(sp)
    80002fac:	e4a6                	sd	s1,72(sp)
    80002fae:	e0ca                	sd	s2,64(sp)
    80002fb0:	fc4e                	sd	s3,56(sp)
    80002fb2:	f852                	sd	s4,48(sp)
    80002fb4:	f456                	sd	s5,40(sp)
    80002fb6:	1080                	addi	s0,sp,96
  uint64 addr;
  int len, prot, flags, key = -1;
    80002fb8:	57fd                	li	a5,-1
    80002fba:	faf42423          	sw	a5,-88(s0)

  argaddr(0, &addr);
    80002fbe:	fb840593          	addi	a1,s0,-72
    80002fc2:	4501                	li	a0,0
    80002fc4:	cd7ff0ef          	jal	ra,80002c9a <argaddr>
  argint(1, &len);
    80002fc8:	fb440593          	addi	a1,s0,-76
    80002fcc:	4505                	li	a0,1
    80002fce:	cb1ff0ef          	jal	ra,80002c7e <argint>
  argint(2, &prot);
    80002fd2:	fb040593          	addi	a1,s0,-80
    80002fd6:	4509                	li	a0,2
    80002fd8:	ca7ff0ef          	jal	ra,80002c7e <argint>
  argint(3, &flags);
    80002fdc:	fac40593          	addi	a1,s0,-84
    80002fe0:	450d                	li	a0,3
    80002fe2:	c9dff0ef          	jal	ra,80002c7e <argint>
  argint(4, &key);
    80002fe6:	fa840593          	addi	a1,s0,-88
    80002fea:	4511                	li	a0,4
    80002fec:	c93ff0ef          	jal	ra,80002c7e <argint>

  if(len <= 0) return -1;
    80002ff0:	fb442983          	lw	s3,-76(s0)
    80002ff4:	15305063          	blez	s3,80003134 <sys_mmap+0x18e>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return -1;                
  if(plen > (MMAPTOP - MMAPBASE)) return -1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return -1;  
    80002ff8:	fb042903          	lw	s2,-80(s0)
    80002ffc:	ffc97913          	andi	s2,s2,-4
    80003000:	54fd                	li	s1,-1
    80003002:	12091a63          	bnez	s2,80003136 <sys_mmap+0x190>
  if((flags & MAP_ANON) == 0) return -1;
    80003006:	fac42783          	lw	a5,-84(s0)
    8000300a:	8b85                	andi	a5,a5,1
    8000300c:	12078563          	beqz	a5,80003136 <sys_mmap+0x190>
  if(addr != 0) return -1;            
    80003010:	fb843a03          	ld	s4,-72(s0)
    80003014:	120a1163          	bnez	s4,80003136 <sys_mmap+0x190>

  struct proc *p = myproc();
    80003018:	b31fe0ef          	jal	ra,80001b48 <myproc>
    8000301c:	8aaa                	mv	s5,a0
  for(int i = 0; i < NVMA; i++){
    8000301e:	16850313          	addi	t1,a0,360
  struct proc *p = myproc();
    80003022:	879a                	mv	a5,t1
  for(int i = 0; i < NVMA; i++){
    80003024:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    80003026:	4398                	lw	a4,0(a5)
    80003028:	cb01                	beqz	a4,80003038 <sys_mmap+0x92>
  for(int i = 0; i < NVMA; i++){
    8000302a:	2905                	addiw	s2,s2,1
    8000302c:	02878793          	addi	a5,a5,40
    80003030:	fed91be3          	bne	s2,a3,80003026 <sys_mmap+0x80>

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    80003034:	54fd                	li	s1,-1
    80003036:	a201                	j	80003136 <sys_mmap+0x190>
  uint64 plen = PGROUNDUP((uint64)len);
    80003038:	6785                	lui	a5,0x1
    8000303a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000303c:	99be                	add	s3,s3,a5
    8000303e:	777d                	lui	a4,0xfffff
    80003040:	00e9feb3          	and	t4,s3,a4
  len = PGROUNDUP(len);
    80003044:	97f6                	add	a5,a5,t4
    80003046:	00e7f833          	and	a6,a5,a4
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    8000304a:	400005b7          	lui	a1,0x40000
    8000304e:	95c2                	add	a1,a1,a6
    80003050:	400004b7          	lui	s1,0x40000
    80003054:	3e8a8613          	addi	a2,s5,1000
    va = PGROUNDUP(jump);
    80003058:	6e05                	lui	t3,0x1
    8000305a:	1e7d                	addi	t3,t3,-1 # fff <_entry-0x7ffff001>
    8000305c:	7f7d                	lui	t5,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    8000305e:	f3fff8b7          	lui	a7,0xf3fff
    80003062:	08ba                	slli	a7,a7,0xe
    80003064:	01a8d893          	srli	a7,a7,0x1a
    80003068:	a81d                	j	8000309e <sys_mmap+0xf8>
      if(best == 0 || e < best) best = e;
    8000306a:	853a                	mv	a0,a4
  for(int i=0;i<NVMA;i++){
    8000306c:	02878793          	addi	a5,a5,40
    80003070:	00c78f63          	beq	a5,a2,8000308e <sys_mmap+0xe8>
    if(!p->vmas[i].used) continue;
    80003074:	4398                	lw	a4,0(a5)
    80003076:	db7d                	beqz	a4,8000306c <sys_mmap+0xc6>
    if(!(end <= s || start >= e)){
    80003078:	6798                	ld	a4,8(a5)
    8000307a:	feb779e3          	bgeu	a4,a1,8000306c <sys_mmap+0xc6>
    uint64 e = p->vmas[i].end;
    8000307e:	6b98                	ld	a4,16(a5)
    if(!(end <= s || start >= e)){
    80003080:	fee4f6e3          	bgeu	s1,a4,8000306c <sys_mmap+0xc6>
      if(best == 0 || e < best) best = e;
    80003084:	d17d                	beqz	a0,8000306a <sys_mmap+0xc4>
    80003086:	fea773e3          	bgeu	a4,a0,8000306c <sys_mmap+0xc6>
    8000308a:	853a                	mv	a0,a4
    8000308c:	b7c5                	j	8000306c <sys_mmap+0xc6>
    if(jump == 0){
    8000308e:	c919                	beqz	a0,800030a4 <sys_mmap+0xfe>
    va = PGROUNDUP(jump);
    80003090:	9572                	add	a0,a0,t3
    80003092:	01e574b3          	and	s1,a0,t5
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003096:	009805b3          	add	a1,a6,s1
    8000309a:	0ab8e863          	bltu	a7,a1,8000314a <sys_mmap+0x1a4>
  struct proc *p = myproc();
    8000309e:	879a                	mv	a5,t1
  uint64 best = 0;
    800030a0:	8552                	mv	a0,s4
    800030a2:	bfc9                	j	80003074 <sys_mmap+0xce>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) return (uint64)-1;
    800030a4:	c4cd                	beqz	s1,8000314e <sys_mmap+0x1a8>
  
  v->used = 1;
    800030a6:	00291793          	slli	a5,s2,0x2
    800030aa:	97ca                	add	a5,a5,s2
    800030ac:	078e                	slli	a5,a5,0x3
    800030ae:	97d6                	add	a5,a5,s5
    800030b0:	4705                	li	a4,1
    800030b2:	16e7a423          	sw	a4,360(a5)
  v->start = va;
    800030b6:	1697b823          	sd	s1,368(a5)
  v->end = va + plen;
    800030ba:	9ea6                	add	t4,t4,s1
    800030bc:	17d7bc23          	sd	t4,376(a5)
  v->prot = prot;
    800030c0:	fb042703          	lw	a4,-80(s0)
    800030c4:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    800030c8:	fac42703          	lw	a4,-84(s0)
    800030cc:	18e7a223          	sw	a4,388(a5)
  v->is_shm = 0;
    800030d0:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    800030d4:	56fd                	li	a3,-1
    800030d6:	18d7a623          	sw	a3,396(a5)

  if(va < MMAPBASE || va + plen > MMAPTOP) return (uint64)-1;
    800030da:	400007b7          	lui	a5,0x40000
    800030de:	06f4ea63          	bltu	s1,a5,80003152 <sys_mmap+0x1ac>
    800030e2:	010007b7          	lui	a5,0x1000
    800030e6:	17f5                	addi	a5,a5,-3 # fffffd <_entry-0x7f000003>
    800030e8:	07ba                	slli	a5,a5,0xe
    800030ea:	07d7e663          	bltu	a5,t4,80003156 <sys_mmap+0x1b0>

  if(flags & MAP_SHARED){
    800030ee:	8b09                	andi	a4,a4,2
    800030f0:	c339                	beqz	a4,80003136 <sys_mmap+0x190>
    if(key < 0) return (uint64)-1;
    800030f2:	fa842a03          	lw	s4,-88(s0)
    800030f6:	060a4263          	bltz	s4,8000315a <sys_mmap+0x1b4>
    int npages = plen / PGSIZE;

    // 只有当前进程之前没有引用该 key，才 shm_get 一次
    if(!proc_has_shm_key(p, key, 0)){
    800030fa:	4601                	li	a2,0
    800030fc:	85d2                	mv	a1,s4
    800030fe:	8556                	mv	a0,s5
    80003100:	c4bff0ef          	jal	ra,80002d4a <proc_has_shm_key>
    80003104:	cd19                	beqz	a0,80003122 <sys_mmap+0x17c>
      if(shm_get(key, npages) < 0)
        return (uint64)-1;
    }

    v->is_shm = 1;
    80003106:	00291793          	slli	a5,s2,0x2
    8000310a:	01278733          	add	a4,a5,s2
    8000310e:	070e                	slli	a4,a4,0x3
    80003110:	9756                	add	a4,a4,s5
    80003112:	4685                	li	a3,1
    80003114:	18d72423          	sw	a3,392(a4) # fffffffffffff188 <end+0xffffffff7fdab420>
    v->shm_key = key;
    80003118:	fa842783          	lw	a5,-88(s0)
    8000311c:	18f72623          	sw	a5,396(a4)
    80003120:	a819                	j	80003136 <sys_mmap+0x190>
      if(shm_get(key, npages) < 0)
    80003122:	40c9d593          	srai	a1,s3,0xc
    80003126:	8552                	mv	a0,s4
    80003128:	194030ef          	jal	ra,800062bc <shm_get>
    8000312c:	fc055de3          	bgez	a0,80003106 <sys_mmap+0x160>
        return (uint64)-1;
    80003130:	54fd                	li	s1,-1
    80003132:	a011                	j	80003136 <sys_mmap+0x190>
  if(len <= 0) return -1;
    80003134:	54fd                	li	s1,-1
  }


  return va;
}
    80003136:	8526                	mv	a0,s1
    80003138:	60e6                	ld	ra,88(sp)
    8000313a:	6446                	ld	s0,80(sp)
    8000313c:	64a6                	ld	s1,72(sp)
    8000313e:	6906                	ld	s2,64(sp)
    80003140:	79e2                	ld	s3,56(sp)
    80003142:	7a42                	ld	s4,48(sp)
    80003144:	7aa2                	ld	s5,40(sp)
    80003146:	6125                	addi	sp,sp,96
    80003148:	8082                	ret
  if(va == 0) return (uint64)-1;
    8000314a:	54fd                	li	s1,-1
    8000314c:	b7ed                	j	80003136 <sys_mmap+0x190>
    8000314e:	54fd                	li	s1,-1
    80003150:	b7dd                	j	80003136 <sys_mmap+0x190>
  if(va < MMAPBASE || va + plen > MMAPTOP) return (uint64)-1;
    80003152:	54fd                	li	s1,-1
    80003154:	b7cd                	j	80003136 <sys_mmap+0x190>
    80003156:	54fd                	li	s1,-1
    80003158:	bff9                	j	80003136 <sys_mmap+0x190>
    if(key < 0) return (uint64)-1;
    8000315a:	54fd                	li	s1,-1
    8000315c:	bfe9                	j	80003136 <sys_mmap+0x190>

000000008000315e <sys_munmap>:
}


uint64
sys_munmap(void)
{
    8000315e:	7159                	addi	sp,sp,-112
    80003160:	f486                	sd	ra,104(sp)
    80003162:	f0a2                	sd	s0,96(sp)
    80003164:	eca6                	sd	s1,88(sp)
    80003166:	e8ca                	sd	s2,80(sp)
    80003168:	e4ce                	sd	s3,72(sp)
    8000316a:	e0d2                	sd	s4,64(sp)
    8000316c:	fc56                	sd	s5,56(sp)
    8000316e:	f85a                	sd	s6,48(sp)
    80003170:	f45e                	sd	s7,40(sp)
    80003172:	f062                	sd	s8,32(sp)
    80003174:	ec66                	sd	s9,24(sp)
    80003176:	e86a                	sd	s10,16(sp)
    80003178:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    8000317a:	9cffe0ef          	jal	ra,80001b48 <myproc>
    8000317e:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    80003180:	f9840593          	addi	a1,s0,-104
    80003184:	4501                	li	a0,0
    80003186:	b15ff0ef          	jal	ra,80002c9a <argaddr>
  argint(1, &len);
    8000318a:	f9440593          	addi	a1,s0,-108
    8000318e:	4505                	li	a0,1
    80003190:	aefff0ef          	jal	ra,80002c7e <argint>

  if(len <= 0) return (uint64)-1;
    80003194:	f9442683          	lw	a3,-108(s0)
    80003198:	2cd05f63          	blez	a3,80003476 <sys_munmap+0x318>


  uint64 a = PGROUNDDOWN(uaddr);
    8000319c:	f9843783          	ld	a5,-104(s0)
    800031a0:	767d                	lui	a2,0xfffff
    800031a2:	00c7fa33          	and	s4,a5,a2
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    800031a6:	6705                	lui	a4,0x1
    800031a8:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    800031aa:	00e78933          	add	s2,a5,a4
    800031ae:	9936                	add	s2,s2,a3
    800031b0:	00c97933          	and	s2,s2,a2
  if(b < a) return (uint64)-1;  // 溢出了
    800031b4:	557d                	li	a0,-1
    800031b6:	17496d63          	bltu	s2,s4,80003330 <sys_munmap+0x1d2>
    800031ba:	168a8b13          	addi	s6,s5,360
    800031be:	3e8a8993          	addi	s3,s5,1000
    800031c2:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    800031c4:	4801                	li	a6,0
    800031c6:	a029                	j	800031d0 <sys_munmap+0x72>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    800031c8:	02878793          	addi	a5,a5,40
    800031cc:	01378663          	beq	a5,s3,800031d8 <sys_munmap+0x7a>
    800031d0:	4398                	lw	a4,0(a5)
    800031d2:	fb7d                	bnez	a4,800031c8 <sys_munmap+0x6a>
    800031d4:	2805                	addiw	a6,a6,1
    800031d6:	bfcd                	j	800031c8 <sys_munmap+0x6a>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    800031d8:	8552                	mv	a0,s4
  int need_splits = 0;
    800031da:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    800031dc:	4881                	li	a7,0
    800031de:	45c1                	li	a1,16
    800031e0:	537d                	li	t1,-1
  while(cur < b){
    800031e2:	072a6163          	bltu	s4,s2,80003244 <sys_munmap+0xe6>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    800031e6:	43f85513          	srai	a0,a6,0x3f
    800031ea:	a299                	j	80003330 <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    800031ec:	2705                	addiw	a4,a4,1
    800031ee:	02878793          	addi	a5,a5,40
    800031f2:	04b70c63          	beq	a4,a1,8000324a <sys_munmap+0xec>
    if(!p->vmas[i].used) continue;
    800031f6:	4394                	lw	a3,0(a5)
    800031f8:	daf5                	beqz	a3,800031ec <sys_munmap+0x8e>
    if(!(b <= s || a >= e))   // overlap
    800031fa:	6794                	ld	a3,8(a5)
    800031fc:	ff26f8e3          	bgeu	a3,s2,800031ec <sys_munmap+0x8e>
    80003200:	6b94                	ld	a3,16(a5)
    80003202:	fed575e3          	bgeu	a0,a3,800031ec <sys_munmap+0x8e>
    if(vi < 0){
    80003206:	04074563          	bltz	a4,80003250 <sys_munmap+0xf2>
    uint64 seg_start = cur > v->start ? cur : v->start;
    8000320a:	00271793          	slli	a5,a4,0x2
    8000320e:	97ba                	add	a5,a5,a4
    80003210:	078e                	slli	a5,a5,0x3
    80003212:	97d6                	add	a5,a5,s5
    80003214:	1707b683          	ld	a3,368(a5)
    80003218:	8636                	mv	a2,a3
    8000321a:	00a6f363          	bgeu	a3,a0,80003220 <sys_munmap+0xc2>
    8000321e:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003220:	00271793          	slli	a5,a4,0x2
    80003224:	97ba                	add	a5,a5,a4
    80003226:	078e                	slli	a5,a5,0x3
    80003228:	97d6                	add	a5,a5,s5
    8000322a:	1787b783          	ld	a5,376(a5)
    8000322e:	853e                	mv	a0,a5
    80003230:	00f97363          	bgeu	s2,a5,80003236 <sys_munmap+0xd8>
    80003234:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    80003236:	00c6f563          	bgeu	a3,a2,80003240 <sys_munmap+0xe2>
    8000323a:	00f57363          	bgeu	a0,a5,80003240 <sys_munmap+0xe2>
      need_splits++;
    8000323e:	2e05                	addiw	t3,t3,1
  while(cur < b){
    80003240:	03257a63          	bgeu	a0,s2,80003274 <sys_munmap+0x116>
  int free_slots = 0;
    80003244:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003246:	8746                	mv	a4,a7
    80003248:	b77d                	j	800031f6 <sys_munmap+0x98>
    8000324a:	87da                	mv	a5,s6
    8000324c:	869a                	mv	a3,t1
    8000324e:	a801                	j	8000325e <sys_munmap+0x100>
    80003250:	87da                	mv	a5,s6
    80003252:	869a                	mv	a3,t1
    80003254:	a029                	j	8000325e <sys_munmap+0x100>
  for(int i = 0; i < NVMA; i++){
    80003256:	02878793          	addi	a5,a5,40
    8000325a:	01378b63          	beq	a5,s3,80003270 <sys_munmap+0x112>
    if(!p->vmas[i].used) continue;
    8000325e:	4398                	lw	a4,0(a5)
    80003260:	db7d                	beqz	a4,80003256 <sys_munmap+0xf8>
    uint64 s = p->vmas[i].start;
    80003262:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    80003264:	fea769e3          	bltu	a4,a0,80003256 <sys_munmap+0xf8>
    80003268:	fed777e3          	bgeu	a4,a3,80003256 <sys_munmap+0xf8>
    8000326c:	86ba                	mv	a3,a4
    8000326e:	b7e5                	j	80003256 <sys_munmap+0xf8>
      if(ns == (uint64)-1 || ns >= b) break;
    80003270:	0126e963          	bltu	a3,s2,80003282 <sys_munmap+0x124>
    // 不做任何事，保持一致性
    return (uint64)-1;
    80003274:	557d                	li	a0,-1
  if(need_splits > free_slots){
    80003276:	0bc84d63          	blt	a6,t3,80003330 <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    8000327a:	4c01                	li	s8,0
    8000327c:	4bc1                	li	s7,16
    8000327e:	5cfd                	li	s9,-1
    80003280:	aac5                	j	80003470 <sys_munmap+0x312>
    80003282:	8536                	mv	a0,a3
    80003284:	b7c1                	j	80003244 <sys_munmap+0xe6>
    80003286:	2485                	addiw	s1,s1,1 # 40000001 <_entry-0x3fffffff>
    80003288:	02878793          	addi	a5,a5,40
    8000328c:	07748c63          	beq	s1,s7,80003304 <sys_munmap+0x1a6>
    if(!p->vmas[i].used) continue;
    80003290:	4398                	lw	a4,0(a5)
    80003292:	db75                	beqz	a4,80003286 <sys_munmap+0x128>
    if(!(b <= s || a >= e))   // overlap
    80003294:	6798                	ld	a4,8(a5)
    80003296:	ff2778e3          	bgeu	a4,s2,80003286 <sys_munmap+0x128>
    8000329a:	6b98                	ld	a4,16(a5)
    8000329c:	feea75e3          	bgeu	s4,a4,80003286 <sys_munmap+0x128>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    800032a0:	0604c563          	bltz	s1,8000330a <sys_munmap+0x1ac>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    800032a4:	00249793          	slli	a5,s1,0x2
    800032a8:	97a6                	add	a5,a5,s1
    800032aa:	078e                	slli	a5,a5,0x3
    800032ac:	97d6                	add	a5,a5,s5
    800032ae:	1707bd03          	ld	s10,368(a5)
    800032b2:	014d7363          	bgeu	s10,s4,800032b8 <sys_munmap+0x15a>
    800032b6:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    800032b8:	00249793          	slli	a5,s1,0x2
    800032bc:	97a6                	add	a5,a5,s1
    800032be:	078e                	slli	a5,a5,0x3
    800032c0:	97d6                	add	a5,a5,s5
    800032c2:	1787ba03          	ld	s4,376(a5)
    800032c6:	01497363          	bgeu	s2,s4,800032cc <sys_munmap+0x16e>
    800032ca:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    800032cc:	094d6263          	bltu	s10,s4,80003350 <sys_munmap+0x1f2>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    800032d0:	00249793          	slli	a5,s1,0x2
    800032d4:	97a6                	add	a5,a5,s1
    800032d6:	078e                	slli	a5,a5,0x3
    800032d8:	97d6                	add	a5,a5,s5
    800032da:	1707b783          	ld	a5,368(a5)
    800032de:	11a7e463          	bltu	a5,s10,800033e6 <sys_munmap+0x288>
    800032e2:	00249793          	slli	a5,s1,0x2
    800032e6:	97a6                	add	a5,a5,s1
    800032e8:	078e                	slli	a5,a5,0x3
    800032ea:	97d6                	add	a5,a5,s5
    800032ec:	1787b783          	ld	a5,376(a5)
    800032f0:	06fa7a63          	bgeu	s4,a5,80003364 <sys_munmap+0x206>
      // 覆盖整条VMA删除
      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    800032f4:	00249793          	slli	a5,s1,0x2
    800032f8:	97a6                	add	a5,a5,s1
    800032fa:	078e                	slli	a5,a5,0x3
    800032fc:	97d6                	add	a5,a5,s5
    800032fe:	1747b823          	sd	s4,368(a5)
    80003302:	a2ad                	j	8000346c <sys_munmap+0x30e>
    80003304:	87da                	mv	a5,s6
    80003306:	86e6                	mv	a3,s9
    80003308:	a801                	j	80003318 <sys_munmap+0x1ba>
    8000330a:	87da                	mv	a5,s6
    8000330c:	86e6                	mv	a3,s9
    8000330e:	a029                	j	80003318 <sys_munmap+0x1ba>
  for(int i = 0; i < NVMA; i++){
    80003310:	02878793          	addi	a5,a5,40
    80003314:	01378b63          	beq	a5,s3,8000332a <sys_munmap+0x1cc>
    if(!p->vmas[i].used) continue;
    80003318:	4398                	lw	a4,0(a5)
    8000331a:	db7d                	beqz	a4,80003310 <sys_munmap+0x1b2>
    uint64 s = p->vmas[i].start;
    8000331c:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    8000331e:	ff4769e3          	bltu	a4,s4,80003310 <sys_munmap+0x1b2>
    80003322:	fed777e3          	bgeu	a4,a3,80003310 <sys_munmap+0x1b2>
    80003326:	86ba                	mv	a3,a4
    80003328:	b7e5                	j	80003310 <sys_munmap+0x1b2>
      if(ns == (uint64)-1 || ns >= b) break;
    8000332a:	0326e163          	bltu	a3,s2,8000334c <sys_munmap+0x1ee>
    }

    cur = seg_end;
  }

  return 0;
    8000332e:	4501                	li	a0,0
}
    80003330:	70a6                	ld	ra,104(sp)
    80003332:	7406                	ld	s0,96(sp)
    80003334:	64e6                	ld	s1,88(sp)
    80003336:	6946                	ld	s2,80(sp)
    80003338:	69a6                	ld	s3,72(sp)
    8000333a:	6a06                	ld	s4,64(sp)
    8000333c:	7ae2                	ld	s5,56(sp)
    8000333e:	7b42                	ld	s6,48(sp)
    80003340:	7ba2                	ld	s7,40(sp)
    80003342:	7c02                	ld	s8,32(sp)
    80003344:	6ce2                	ld	s9,24(sp)
    80003346:	6d42                	ld	s10,16(sp)
    80003348:	6165                	addi	sp,sp,112
    8000334a:	8082                	ret
    8000334c:	8a36                	mv	s4,a3
    8000334e:	a20d                	j	80003470 <sys_munmap+0x312>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    80003350:	41aa0633          	sub	a2,s4,s10
    80003354:	4685                	li	a3,1
    80003356:	8231                	srli	a2,a2,0xc
    80003358:	85ea                	mv	a1,s10
    8000335a:	050ab503          	ld	a0,80(s5)
    8000335e:	f37fd0ef          	jal	ra,80001294 <uvmunmap>
    80003362:	b7bd                	j	800032d0 <sys_munmap+0x172>
  if(v->used == 0) return;
    80003364:	00249793          	slli	a5,s1,0x2
    80003368:	97a6                	add	a5,a5,s1
    8000336a:	078e                	slli	a5,a5,0x3
    8000336c:	97d6                	add	a5,a5,s5
    8000336e:	1687a783          	lw	a5,360(a5)
    80003372:	0e078d63          	beqz	a5,8000346c <sys_munmap+0x30e>
  if(v->is_shm){
    80003376:	00249793          	slli	a5,s1,0x2
    8000337a:	97a6                	add	a5,a5,s1
    8000337c:	078e                	slli	a5,a5,0x3
    8000337e:	97d6                	add	a5,a5,s5
    80003380:	1887a783          	lw	a5,392(a5)
    80003384:	c785                	beqz	a5,800033ac <sys_munmap+0x24e>
    int key = v->shm_key;
    80003386:	00249793          	slli	a5,s1,0x2
    8000338a:	00978733          	add	a4,a5,s1
    8000338e:	070e                	slli	a4,a4,0x3
    80003390:	9756                	add	a4,a4,s5
    80003392:	18c72d03          	lw	s10,396(a4)
    struct vma *v = &p->vmas[vi];
    80003396:	00978633          	add	a2,a5,s1
    8000339a:	060e                	slli	a2,a2,0x3
    8000339c:	16860613          	addi	a2,a2,360 # fffffffffffff168 <end+0xffffffff7fdab400>
    if(!proc_has_shm_key(p, key, v)){
    800033a0:	9656                	add	a2,a2,s5
    800033a2:	85ea                	mv	a1,s10
    800033a4:	8556                	mv	a0,s5
    800033a6:	9a5ff0ef          	jal	ra,80002d4a <proc_has_shm_key>
    800033aa:	c915                	beqz	a0,800033de <sys_munmap+0x280>
  v->used = 0;
    800033ac:	00249713          	slli	a4,s1,0x2
    800033b0:	009707b3          	add	a5,a4,s1
    800033b4:	078e                	slli	a5,a5,0x3
    800033b6:	97d6                	add	a5,a5,s5
    800033b8:	1607a423          	sw	zero,360(a5)
  v->start = v->end = 0;
    800033bc:	1607bc23          	sd	zero,376(a5)
    800033c0:	1607b823          	sd	zero,368(a5)
  v->prot = v->flags = 0;
    800033c4:	1807a223          	sw	zero,388(a5)
    800033c8:	1807a023          	sw	zero,384(a5)
  v->is_shm = 0;
    800033cc:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    800033d0:	009707b3          	add	a5,a4,s1
    800033d4:	078e                	slli	a5,a5,0x3
    800033d6:	97d6                	add	a5,a5,s5
    800033d8:	1997a623          	sw	s9,396(a5)
    800033dc:	a841                	j	8000346c <sys_munmap+0x30e>
      shm_put(key);
    800033de:	856a                	mv	a0,s10
    800033e0:	7f1020ef          	jal	ra,800063d0 <shm_put>
    800033e4:	b7e1                	j	800033ac <sys_munmap+0x24e>
    } else if(seg_start > v->start && seg_end >= v->end){
    800033e6:	00249793          	slli	a5,s1,0x2
    800033ea:	97a6                	add	a5,a5,s1
    800033ec:	078e                	slli	a5,a5,0x3
    800033ee:	97d6                	add	a5,a5,s5
    800033f0:	1787b783          	ld	a5,376(a5)
    800033f4:	00fa6a63          	bltu	s4,a5,80003408 <sys_munmap+0x2aa>
      v->end = seg_start;
    800033f8:	00249793          	slli	a5,s1,0x2
    800033fc:	97a6                	add	a5,a5,s1
    800033fe:	078e                	slli	a5,a5,0x3
    80003400:	97d6                	add	a5,a5,s5
    80003402:	17a7bc23          	sd	s10,376(a5)
    80003406:	a09d                	j	8000346c <sys_munmap+0x30e>
    80003408:	875a                	mv	a4,s6
    8000340a:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    8000340c:	4314                	lw	a3,0(a4)
    8000340e:	c699                	beqz	a3,8000341c <sys_munmap+0x2be>
  for(int i = 0; i < NVMA; i++){
    80003410:	2785                	addiw	a5,a5,1
    80003412:	02870713          	addi	a4,a4,40
    80003416:	ff779be3          	bne	a5,s7,8000340c <sys_munmap+0x2ae>
  return -1;
    8000341a:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    8000341c:	00279593          	slli	a1,a5,0x2
    80003420:	00f586b3          	add	a3,a1,a5
    80003424:	068e                	slli	a3,a3,0x3
    80003426:	96d6                	add	a3,a3,s5
    80003428:	00249613          	slli	a2,s1,0x2
    8000342c:	00960733          	add	a4,a2,s1
    80003430:	070e                	slli	a4,a4,0x3
    80003432:	9756                	add	a4,a4,s5
    80003434:	16873303          	ld	t1,360(a4)
    80003438:	17873883          	ld	a7,376(a4)
    8000343c:	18073803          	ld	a6,384(a4)
    80003440:	18873503          	ld	a0,392(a4)
    80003444:	1666b423          	sd	t1,360(a3) # 1168 <_entry-0x7fffee98>
    80003448:	1716bc23          	sd	a7,376(a3)
    8000344c:	1906b023          	sd	a6,384(a3)
    80003450:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    80003454:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    80003458:	17873703          	ld	a4,376(a4)
    8000345c:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    80003460:	009607b3          	add	a5,a2,s1
    80003464:	078e                	slli	a5,a5,0x3
    80003466:	97d6                	add	a5,a5,s5
    80003468:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    8000346c:	012a7763          	bgeu	s4,s2,8000347a <sys_munmap+0x31c>
  int need_splits = 0;
    80003470:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003472:	84e2                	mv	s1,s8
    80003474:	bd31                	j	80003290 <sys_munmap+0x132>
  if(len <= 0) return (uint64)-1;
    80003476:	557d                	li	a0,-1
    80003478:	bd65                	j	80003330 <sys_munmap+0x1d2>
  return 0;
    8000347a:	4501                	li	a0,0
    8000347c:	bd55                	j	80003330 <sys_munmap+0x1d2>

000000008000347e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000347e:	7179                	addi	sp,sp,-48
    80003480:	f406                	sd	ra,40(sp)
    80003482:	f022                	sd	s0,32(sp)
    80003484:	ec26                	sd	s1,24(sp)
    80003486:	e84a                	sd	s2,16(sp)
    80003488:	e44e                	sd	s3,8(sp)
    8000348a:	e052                	sd	s4,0(sp)
    8000348c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000348e:	00005597          	auipc	a1,0x5
    80003492:	02a58593          	addi	a1,a1,42 # 800084b8 <syscalls+0xc0>
    80003496:	0023d517          	auipc	a0,0x23d
    8000349a:	37250513          	addi	a0,a0,882 # 80240808 <bcache>
    8000349e:	f82fd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034a2:	00245797          	auipc	a5,0x245
    800034a6:	36678793          	addi	a5,a5,870 # 80248808 <bcache+0x8000>
    800034aa:	00245717          	auipc	a4,0x245
    800034ae:	5c670713          	addi	a4,a4,1478 # 80248a70 <bcache+0x8268>
    800034b2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034b6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034ba:	0023d497          	auipc	s1,0x23d
    800034be:	36648493          	addi	s1,s1,870 # 80240820 <bcache+0x18>
    b->next = bcache.head.next;
    800034c2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034c4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034c6:	00005a17          	auipc	s4,0x5
    800034ca:	ffaa0a13          	addi	s4,s4,-6 # 800084c0 <syscalls+0xc8>
    b->next = bcache.head.next;
    800034ce:	2b893783          	ld	a5,696(s2)
    800034d2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034d4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034d8:	85d2                	mv	a1,s4
    800034da:	01048513          	addi	a0,s1,16
    800034de:	302010ef          	jal	ra,800047e0 <initsleeplock>
    bcache.head.next->prev = b;
    800034e2:	2b893783          	ld	a5,696(s2)
    800034e6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034e8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034ec:	45848493          	addi	s1,s1,1112
    800034f0:	fd349fe3          	bne	s1,s3,800034ce <binit+0x50>
  }
}
    800034f4:	70a2                	ld	ra,40(sp)
    800034f6:	7402                	ld	s0,32(sp)
    800034f8:	64e2                	ld	s1,24(sp)
    800034fa:	6942                	ld	s2,16(sp)
    800034fc:	69a2                	ld	s3,8(sp)
    800034fe:	6a02                	ld	s4,0(sp)
    80003500:	6145                	addi	sp,sp,48
    80003502:	8082                	ret

0000000080003504 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003504:	7179                	addi	sp,sp,-48
    80003506:	f406                	sd	ra,40(sp)
    80003508:	f022                	sd	s0,32(sp)
    8000350a:	ec26                	sd	s1,24(sp)
    8000350c:	e84a                	sd	s2,16(sp)
    8000350e:	e44e                	sd	s3,8(sp)
    80003510:	1800                	addi	s0,sp,48
    80003512:	892a                	mv	s2,a0
    80003514:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003516:	0023d517          	auipc	a0,0x23d
    8000351a:	2f250513          	addi	a0,a0,754 # 80240808 <bcache>
    8000351e:	f82fd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003522:	00245497          	auipc	s1,0x245
    80003526:	59e4b483          	ld	s1,1438(s1) # 80248ac0 <bcache+0x82b8>
    8000352a:	00245797          	auipc	a5,0x245
    8000352e:	54678793          	addi	a5,a5,1350 # 80248a70 <bcache+0x8268>
    80003532:	02f48b63          	beq	s1,a5,80003568 <bread+0x64>
    80003536:	873e                	mv	a4,a5
    80003538:	a021                	j	80003540 <bread+0x3c>
    8000353a:	68a4                	ld	s1,80(s1)
    8000353c:	02e48663          	beq	s1,a4,80003568 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003540:	449c                	lw	a5,8(s1)
    80003542:	ff279ce3          	bne	a5,s2,8000353a <bread+0x36>
    80003546:	44dc                	lw	a5,12(s1)
    80003548:	ff3799e3          	bne	a5,s3,8000353a <bread+0x36>
      b->refcnt++;
    8000354c:	40bc                	lw	a5,64(s1)
    8000354e:	2785                	addiw	a5,a5,1
    80003550:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003552:	0023d517          	auipc	a0,0x23d
    80003556:	2b650513          	addi	a0,a0,694 # 80240808 <bcache>
    8000355a:	fdefd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    8000355e:	01048513          	addi	a0,s1,16
    80003562:	2b4010ef          	jal	ra,80004816 <acquiresleep>
      return b;
    80003566:	a889                	j	800035b8 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003568:	00245497          	auipc	s1,0x245
    8000356c:	5504b483          	ld	s1,1360(s1) # 80248ab8 <bcache+0x82b0>
    80003570:	00245797          	auipc	a5,0x245
    80003574:	50078793          	addi	a5,a5,1280 # 80248a70 <bcache+0x8268>
    80003578:	00f48863          	beq	s1,a5,80003588 <bread+0x84>
    8000357c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000357e:	40bc                	lw	a5,64(s1)
    80003580:	cb91                	beqz	a5,80003594 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003582:	64a4                	ld	s1,72(s1)
    80003584:	fee49de3          	bne	s1,a4,8000357e <bread+0x7a>
  panic("bget: no buffers");
    80003588:	00005517          	auipc	a0,0x5
    8000358c:	f4050513          	addi	a0,a0,-192 # 800084c8 <syscalls+0xd0>
    80003590:	9f8fd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    80003594:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003598:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000359c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035a0:	4785                	li	a5,1
    800035a2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035a4:	0023d517          	auipc	a0,0x23d
    800035a8:	26450513          	addi	a0,a0,612 # 80240808 <bcache>
    800035ac:	f8cfd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    800035b0:	01048513          	addi	a0,s1,16
    800035b4:	262010ef          	jal	ra,80004816 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035b8:	409c                	lw	a5,0(s1)
    800035ba:	cb89                	beqz	a5,800035cc <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035bc:	8526                	mv	a0,s1
    800035be:	70a2                	ld	ra,40(sp)
    800035c0:	7402                	ld	s0,32(sp)
    800035c2:	64e2                	ld	s1,24(sp)
    800035c4:	6942                	ld	s2,16(sp)
    800035c6:	69a2                	ld	s3,8(sp)
    800035c8:	6145                	addi	sp,sp,48
    800035ca:	8082                	ret
    virtio_disk_rw(b, 0);
    800035cc:	4581                	li	a1,0
    800035ce:	8526                	mv	a0,s1
    800035d0:	20b020ef          	jal	ra,80005fda <virtio_disk_rw>
    b->valid = 1;
    800035d4:	4785                	li	a5,1
    800035d6:	c09c                	sw	a5,0(s1)
  return b;
    800035d8:	b7d5                	j	800035bc <bread+0xb8>

00000000800035da <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035da:	1101                	addi	sp,sp,-32
    800035dc:	ec06                	sd	ra,24(sp)
    800035de:	e822                	sd	s0,16(sp)
    800035e0:	e426                	sd	s1,8(sp)
    800035e2:	1000                	addi	s0,sp,32
    800035e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035e6:	0541                	addi	a0,a0,16
    800035e8:	2ac010ef          	jal	ra,80004894 <holdingsleep>
    800035ec:	c911                	beqz	a0,80003600 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035ee:	4585                	li	a1,1
    800035f0:	8526                	mv	a0,s1
    800035f2:	1e9020ef          	jal	ra,80005fda <virtio_disk_rw>
}
    800035f6:	60e2                	ld	ra,24(sp)
    800035f8:	6442                	ld	s0,16(sp)
    800035fa:	64a2                	ld	s1,8(sp)
    800035fc:	6105                	addi	sp,sp,32
    800035fe:	8082                	ret
    panic("bwrite");
    80003600:	00005517          	auipc	a0,0x5
    80003604:	ee050513          	addi	a0,a0,-288 # 800084e0 <syscalls+0xe8>
    80003608:	980fd0ef          	jal	ra,80000788 <panic>

000000008000360c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	e426                	sd	s1,8(sp)
    80003614:	e04a                	sd	s2,0(sp)
    80003616:	1000                	addi	s0,sp,32
    80003618:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000361a:	01050913          	addi	s2,a0,16
    8000361e:	854a                	mv	a0,s2
    80003620:	274010ef          	jal	ra,80004894 <holdingsleep>
    80003624:	c13d                	beqz	a0,8000368a <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80003626:	854a                	mv	a0,s2
    80003628:	234010ef          	jal	ra,8000485c <releasesleep>

  acquire(&bcache.lock);
    8000362c:	0023d517          	auipc	a0,0x23d
    80003630:	1dc50513          	addi	a0,a0,476 # 80240808 <bcache>
    80003634:	e6cfd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80003638:	40bc                	lw	a5,64(s1)
    8000363a:	37fd                	addiw	a5,a5,-1
    8000363c:	0007871b          	sext.w	a4,a5
    80003640:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003642:	eb05                	bnez	a4,80003672 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003644:	68bc                	ld	a5,80(s1)
    80003646:	64b8                	ld	a4,72(s1)
    80003648:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000364a:	64bc                	ld	a5,72(s1)
    8000364c:	68b8                	ld	a4,80(s1)
    8000364e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003650:	00245797          	auipc	a5,0x245
    80003654:	1b878793          	addi	a5,a5,440 # 80248808 <bcache+0x8000>
    80003658:	2b87b703          	ld	a4,696(a5)
    8000365c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000365e:	00245717          	auipc	a4,0x245
    80003662:	41270713          	addi	a4,a4,1042 # 80248a70 <bcache+0x8268>
    80003666:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003668:	2b87b703          	ld	a4,696(a5)
    8000366c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000366e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003672:	0023d517          	auipc	a0,0x23d
    80003676:	19650513          	addi	a0,a0,406 # 80240808 <bcache>
    8000367a:	ebefd0ef          	jal	ra,80000d38 <release>
}
    8000367e:	60e2                	ld	ra,24(sp)
    80003680:	6442                	ld	s0,16(sp)
    80003682:	64a2                	ld	s1,8(sp)
    80003684:	6902                	ld	s2,0(sp)
    80003686:	6105                	addi	sp,sp,32
    80003688:	8082                	ret
    panic("brelse");
    8000368a:	00005517          	auipc	a0,0x5
    8000368e:	e5e50513          	addi	a0,a0,-418 # 800084e8 <syscalls+0xf0>
    80003692:	8f6fd0ef          	jal	ra,80000788 <panic>

0000000080003696 <bpin>:

void
bpin(struct buf *b) {
    80003696:	1101                	addi	sp,sp,-32
    80003698:	ec06                	sd	ra,24(sp)
    8000369a:	e822                	sd	s0,16(sp)
    8000369c:	e426                	sd	s1,8(sp)
    8000369e:	1000                	addi	s0,sp,32
    800036a0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036a2:	0023d517          	auipc	a0,0x23d
    800036a6:	16650513          	addi	a0,a0,358 # 80240808 <bcache>
    800036aa:	df6fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    800036ae:	40bc                	lw	a5,64(s1)
    800036b0:	2785                	addiw	a5,a5,1
    800036b2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036b4:	0023d517          	auipc	a0,0x23d
    800036b8:	15450513          	addi	a0,a0,340 # 80240808 <bcache>
    800036bc:	e7cfd0ef          	jal	ra,80000d38 <release>
}
    800036c0:	60e2                	ld	ra,24(sp)
    800036c2:	6442                	ld	s0,16(sp)
    800036c4:	64a2                	ld	s1,8(sp)
    800036c6:	6105                	addi	sp,sp,32
    800036c8:	8082                	ret

00000000800036ca <bunpin>:

void
bunpin(struct buf *b) {
    800036ca:	1101                	addi	sp,sp,-32
    800036cc:	ec06                	sd	ra,24(sp)
    800036ce:	e822                	sd	s0,16(sp)
    800036d0:	e426                	sd	s1,8(sp)
    800036d2:	1000                	addi	s0,sp,32
    800036d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036d6:	0023d517          	auipc	a0,0x23d
    800036da:	13250513          	addi	a0,a0,306 # 80240808 <bcache>
    800036de:	dc2fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    800036e2:	40bc                	lw	a5,64(s1)
    800036e4:	37fd                	addiw	a5,a5,-1
    800036e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036e8:	0023d517          	auipc	a0,0x23d
    800036ec:	12050513          	addi	a0,a0,288 # 80240808 <bcache>
    800036f0:	e48fd0ef          	jal	ra,80000d38 <release>
}
    800036f4:	60e2                	ld	ra,24(sp)
    800036f6:	6442                	ld	s0,16(sp)
    800036f8:	64a2                	ld	s1,8(sp)
    800036fa:	6105                	addi	sp,sp,32
    800036fc:	8082                	ret

00000000800036fe <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036fe:	1101                	addi	sp,sp,-32
    80003700:	ec06                	sd	ra,24(sp)
    80003702:	e822                	sd	s0,16(sp)
    80003704:	e426                	sd	s1,8(sp)
    80003706:	e04a                	sd	s2,0(sp)
    80003708:	1000                	addi	s0,sp,32
    8000370a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000370c:	00d5d59b          	srliw	a1,a1,0xd
    80003710:	00245797          	auipc	a5,0x245
    80003714:	7d47a783          	lw	a5,2004(a5) # 80248ee4 <sb+0x1c>
    80003718:	9dbd                	addw	a1,a1,a5
    8000371a:	debff0ef          	jal	ra,80003504 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000371e:	0074f713          	andi	a4,s1,7
    80003722:	4785                	li	a5,1
    80003724:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003728:	14ce                	slli	s1,s1,0x33
    8000372a:	90d9                	srli	s1,s1,0x36
    8000372c:	00950733          	add	a4,a0,s1
    80003730:	05874703          	lbu	a4,88(a4)
    80003734:	00e7f6b3          	and	a3,a5,a4
    80003738:	c29d                	beqz	a3,8000375e <bfree+0x60>
    8000373a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000373c:	94aa                	add	s1,s1,a0
    8000373e:	fff7c793          	not	a5,a5
    80003742:	8f7d                	and	a4,a4,a5
    80003744:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003748:	7d7000ef          	jal	ra,8000471e <log_write>
  brelse(bp);
    8000374c:	854a                	mv	a0,s2
    8000374e:	ebfff0ef          	jal	ra,8000360c <brelse>
}
    80003752:	60e2                	ld	ra,24(sp)
    80003754:	6442                	ld	s0,16(sp)
    80003756:	64a2                	ld	s1,8(sp)
    80003758:	6902                	ld	s2,0(sp)
    8000375a:	6105                	addi	sp,sp,32
    8000375c:	8082                	ret
    panic("freeing free block");
    8000375e:	00005517          	auipc	a0,0x5
    80003762:	d9250513          	addi	a0,a0,-622 # 800084f0 <syscalls+0xf8>
    80003766:	822fd0ef          	jal	ra,80000788 <panic>

000000008000376a <balloc>:
{
    8000376a:	711d                	addi	sp,sp,-96
    8000376c:	ec86                	sd	ra,88(sp)
    8000376e:	e8a2                	sd	s0,80(sp)
    80003770:	e4a6                	sd	s1,72(sp)
    80003772:	e0ca                	sd	s2,64(sp)
    80003774:	fc4e                	sd	s3,56(sp)
    80003776:	f852                	sd	s4,48(sp)
    80003778:	f456                	sd	s5,40(sp)
    8000377a:	f05a                	sd	s6,32(sp)
    8000377c:	ec5e                	sd	s7,24(sp)
    8000377e:	e862                	sd	s8,16(sp)
    80003780:	e466                	sd	s9,8(sp)
    80003782:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003784:	00245797          	auipc	a5,0x245
    80003788:	7487a783          	lw	a5,1864(a5) # 80248ecc <sb+0x4>
    8000378c:	cff1                	beqz	a5,80003868 <balloc+0xfe>
    8000378e:	8baa                	mv	s7,a0
    80003790:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003792:	00245b17          	auipc	s6,0x245
    80003796:	736b0b13          	addi	s6,s6,1846 # 80248ec8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000379a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000379c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000379e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037a0:	6c89                	lui	s9,0x2
    800037a2:	a0b5                	j	8000380e <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037a4:	97ca                	add	a5,a5,s2
    800037a6:	8e55                	or	a2,a2,a3
    800037a8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800037ac:	854a                	mv	a0,s2
    800037ae:	771000ef          	jal	ra,8000471e <log_write>
        brelse(bp);
    800037b2:	854a                	mv	a0,s2
    800037b4:	e59ff0ef          	jal	ra,8000360c <brelse>
  bp = bread(dev, bno);
    800037b8:	85a6                	mv	a1,s1
    800037ba:	855e                	mv	a0,s7
    800037bc:	d49ff0ef          	jal	ra,80003504 <bread>
    800037c0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800037c2:	40000613          	li	a2,1024
    800037c6:	4581                	li	a1,0
    800037c8:	05850513          	addi	a0,a0,88
    800037cc:	da8fd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    800037d0:	854a                	mv	a0,s2
    800037d2:	74d000ef          	jal	ra,8000471e <log_write>
  brelse(bp);
    800037d6:	854a                	mv	a0,s2
    800037d8:	e35ff0ef          	jal	ra,8000360c <brelse>
}
    800037dc:	8526                	mv	a0,s1
    800037de:	60e6                	ld	ra,88(sp)
    800037e0:	6446                	ld	s0,80(sp)
    800037e2:	64a6                	ld	s1,72(sp)
    800037e4:	6906                	ld	s2,64(sp)
    800037e6:	79e2                	ld	s3,56(sp)
    800037e8:	7a42                	ld	s4,48(sp)
    800037ea:	7aa2                	ld	s5,40(sp)
    800037ec:	7b02                	ld	s6,32(sp)
    800037ee:	6be2                	ld	s7,24(sp)
    800037f0:	6c42                	ld	s8,16(sp)
    800037f2:	6ca2                	ld	s9,8(sp)
    800037f4:	6125                	addi	sp,sp,96
    800037f6:	8082                	ret
    brelse(bp);
    800037f8:	854a                	mv	a0,s2
    800037fa:	e13ff0ef          	jal	ra,8000360c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037fe:	015c87bb          	addw	a5,s9,s5
    80003802:	00078a9b          	sext.w	s5,a5
    80003806:	004b2703          	lw	a4,4(s6)
    8000380a:	04eaff63          	bgeu	s5,a4,80003868 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    8000380e:	41fad79b          	sraiw	a5,s5,0x1f
    80003812:	0137d79b          	srliw	a5,a5,0x13
    80003816:	015787bb          	addw	a5,a5,s5
    8000381a:	40d7d79b          	sraiw	a5,a5,0xd
    8000381e:	01cb2583          	lw	a1,28(s6)
    80003822:	9dbd                	addw	a1,a1,a5
    80003824:	855e                	mv	a0,s7
    80003826:	cdfff0ef          	jal	ra,80003504 <bread>
    8000382a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000382c:	004b2503          	lw	a0,4(s6)
    80003830:	000a849b          	sext.w	s1,s5
    80003834:	8762                	mv	a4,s8
    80003836:	fca4f1e3          	bgeu	s1,a0,800037f8 <balloc+0x8e>
      m = 1 << (bi % 8);
    8000383a:	00777693          	andi	a3,a4,7
    8000383e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003842:	41f7579b          	sraiw	a5,a4,0x1f
    80003846:	01d7d79b          	srliw	a5,a5,0x1d
    8000384a:	9fb9                	addw	a5,a5,a4
    8000384c:	4037d79b          	sraiw	a5,a5,0x3
    80003850:	00f90633          	add	a2,s2,a5
    80003854:	05864603          	lbu	a2,88(a2)
    80003858:	00c6f5b3          	and	a1,a3,a2
    8000385c:	d5a1                	beqz	a1,800037a4 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000385e:	2705                	addiw	a4,a4,1
    80003860:	2485                	addiw	s1,s1,1
    80003862:	fd471ae3          	bne	a4,s4,80003836 <balloc+0xcc>
    80003866:	bf49                	j	800037f8 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003868:	00005517          	auipc	a0,0x5
    8000386c:	ca050513          	addi	a0,a0,-864 # 80008508 <syscalls+0x110>
    80003870:	c53fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003874:	4481                	li	s1,0
    80003876:	b79d                	j	800037dc <balloc+0x72>

0000000080003878 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003878:	7179                	addi	sp,sp,-48
    8000387a:	f406                	sd	ra,40(sp)
    8000387c:	f022                	sd	s0,32(sp)
    8000387e:	ec26                	sd	s1,24(sp)
    80003880:	e84a                	sd	s2,16(sp)
    80003882:	e44e                	sd	s3,8(sp)
    80003884:	e052                	sd	s4,0(sp)
    80003886:	1800                	addi	s0,sp,48
    80003888:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000388a:	47ad                	li	a5,11
    8000388c:	02b7e663          	bltu	a5,a1,800038b8 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80003890:	02059793          	slli	a5,a1,0x20
    80003894:	01e7d593          	srli	a1,a5,0x1e
    80003898:	00b504b3          	add	s1,a0,a1
    8000389c:	0504a903          	lw	s2,80(s1)
    800038a0:	06091663          	bnez	s2,8000390c <bmap+0x94>
      addr = balloc(ip->dev);
    800038a4:	4108                	lw	a0,0(a0)
    800038a6:	ec5ff0ef          	jal	ra,8000376a <balloc>
    800038aa:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038ae:	04090f63          	beqz	s2,8000390c <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    800038b2:	0524a823          	sw	s2,80(s1)
    800038b6:	a899                	j	8000390c <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    800038b8:	ff45849b          	addiw	s1,a1,-12
    800038bc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038c0:	0ff00793          	li	a5,255
    800038c4:	06e7eb63          	bltu	a5,a4,8000393a <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800038c8:	08052903          	lw	s2,128(a0)
    800038cc:	00091b63          	bnez	s2,800038e2 <bmap+0x6a>
      addr = balloc(ip->dev);
    800038d0:	4108                	lw	a0,0(a0)
    800038d2:	e99ff0ef          	jal	ra,8000376a <balloc>
    800038d6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038da:	02090963          	beqz	s2,8000390c <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800038de:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800038e2:	85ca                	mv	a1,s2
    800038e4:	0009a503          	lw	a0,0(s3)
    800038e8:	c1dff0ef          	jal	ra,80003504 <bread>
    800038ec:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038ee:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038f2:	02049713          	slli	a4,s1,0x20
    800038f6:	01e75593          	srli	a1,a4,0x1e
    800038fa:	00b784b3          	add	s1,a5,a1
    800038fe:	0004a903          	lw	s2,0(s1)
    80003902:	00090e63          	beqz	s2,8000391e <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003906:	8552                	mv	a0,s4
    80003908:	d05ff0ef          	jal	ra,8000360c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000390c:	854a                	mv	a0,s2
    8000390e:	70a2                	ld	ra,40(sp)
    80003910:	7402                	ld	s0,32(sp)
    80003912:	64e2                	ld	s1,24(sp)
    80003914:	6942                	ld	s2,16(sp)
    80003916:	69a2                	ld	s3,8(sp)
    80003918:	6a02                	ld	s4,0(sp)
    8000391a:	6145                	addi	sp,sp,48
    8000391c:	8082                	ret
      addr = balloc(ip->dev);
    8000391e:	0009a503          	lw	a0,0(s3)
    80003922:	e49ff0ef          	jal	ra,8000376a <balloc>
    80003926:	0005091b          	sext.w	s2,a0
      if(addr){
    8000392a:	fc090ee3          	beqz	s2,80003906 <bmap+0x8e>
        a[bn] = addr;
    8000392e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003932:	8552                	mv	a0,s4
    80003934:	5eb000ef          	jal	ra,8000471e <log_write>
    80003938:	b7f9                	j	80003906 <bmap+0x8e>
  panic("bmap: out of range");
    8000393a:	00005517          	auipc	a0,0x5
    8000393e:	be650513          	addi	a0,a0,-1050 # 80008520 <syscalls+0x128>
    80003942:	e47fc0ef          	jal	ra,80000788 <panic>

0000000080003946 <iget>:
{
    80003946:	7179                	addi	sp,sp,-48
    80003948:	f406                	sd	ra,40(sp)
    8000394a:	f022                	sd	s0,32(sp)
    8000394c:	ec26                	sd	s1,24(sp)
    8000394e:	e84a                	sd	s2,16(sp)
    80003950:	e44e                	sd	s3,8(sp)
    80003952:	e052                	sd	s4,0(sp)
    80003954:	1800                	addi	s0,sp,48
    80003956:	89aa                	mv	s3,a0
    80003958:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000395a:	00245517          	auipc	a0,0x245
    8000395e:	58e50513          	addi	a0,a0,1422 # 80248ee8 <itable>
    80003962:	b3efd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003966:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003968:	00245497          	auipc	s1,0x245
    8000396c:	59848493          	addi	s1,s1,1432 # 80248f00 <itable+0x18>
    80003970:	00247697          	auipc	a3,0x247
    80003974:	02068693          	addi	a3,a3,32 # 8024a990 <log>
    80003978:	a039                	j	80003986 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000397a:	02090963          	beqz	s2,800039ac <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000397e:	08848493          	addi	s1,s1,136
    80003982:	02d48863          	beq	s1,a3,800039b2 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003986:	449c                	lw	a5,8(s1)
    80003988:	fef059e3          	blez	a5,8000397a <iget+0x34>
    8000398c:	4098                	lw	a4,0(s1)
    8000398e:	ff3716e3          	bne	a4,s3,8000397a <iget+0x34>
    80003992:	40d8                	lw	a4,4(s1)
    80003994:	ff4713e3          	bne	a4,s4,8000397a <iget+0x34>
      ip->ref++;
    80003998:	2785                	addiw	a5,a5,1
    8000399a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000399c:	00245517          	auipc	a0,0x245
    800039a0:	54c50513          	addi	a0,a0,1356 # 80248ee8 <itable>
    800039a4:	b94fd0ef          	jal	ra,80000d38 <release>
      return ip;
    800039a8:	8926                	mv	s2,s1
    800039aa:	a02d                	j	800039d4 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039ac:	fbe9                	bnez	a5,8000397e <iget+0x38>
    800039ae:	8926                	mv	s2,s1
    800039b0:	b7f9                	j	8000397e <iget+0x38>
  if(empty == 0)
    800039b2:	02090a63          	beqz	s2,800039e6 <iget+0xa0>
  ip->dev = dev;
    800039b6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039ba:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039be:	4785                	li	a5,1
    800039c0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039c4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039c8:	00245517          	auipc	a0,0x245
    800039cc:	52050513          	addi	a0,a0,1312 # 80248ee8 <itable>
    800039d0:	b68fd0ef          	jal	ra,80000d38 <release>
}
    800039d4:	854a                	mv	a0,s2
    800039d6:	70a2                	ld	ra,40(sp)
    800039d8:	7402                	ld	s0,32(sp)
    800039da:	64e2                	ld	s1,24(sp)
    800039dc:	6942                	ld	s2,16(sp)
    800039de:	69a2                	ld	s3,8(sp)
    800039e0:	6a02                	ld	s4,0(sp)
    800039e2:	6145                	addi	sp,sp,48
    800039e4:	8082                	ret
    panic("iget: no inodes");
    800039e6:	00005517          	auipc	a0,0x5
    800039ea:	b5250513          	addi	a0,a0,-1198 # 80008538 <syscalls+0x140>
    800039ee:	d9bfc0ef          	jal	ra,80000788 <panic>

00000000800039f2 <iinit>:
{
    800039f2:	7179                	addi	sp,sp,-48
    800039f4:	f406                	sd	ra,40(sp)
    800039f6:	f022                	sd	s0,32(sp)
    800039f8:	ec26                	sd	s1,24(sp)
    800039fa:	e84a                	sd	s2,16(sp)
    800039fc:	e44e                	sd	s3,8(sp)
    800039fe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a00:	00005597          	auipc	a1,0x5
    80003a04:	b4858593          	addi	a1,a1,-1208 # 80008548 <syscalls+0x150>
    80003a08:	00245517          	auipc	a0,0x245
    80003a0c:	4e050513          	addi	a0,a0,1248 # 80248ee8 <itable>
    80003a10:	a10fd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a14:	00245497          	auipc	s1,0x245
    80003a18:	4fc48493          	addi	s1,s1,1276 # 80248f10 <itable+0x28>
    80003a1c:	00247997          	auipc	s3,0x247
    80003a20:	f8498993          	addi	s3,s3,-124 # 8024a9a0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a24:	00005917          	auipc	s2,0x5
    80003a28:	b2c90913          	addi	s2,s2,-1236 # 80008550 <syscalls+0x158>
    80003a2c:	85ca                	mv	a1,s2
    80003a2e:	8526                	mv	a0,s1
    80003a30:	5b1000ef          	jal	ra,800047e0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a34:	08848493          	addi	s1,s1,136
    80003a38:	ff349ae3          	bne	s1,s3,80003a2c <iinit+0x3a>
}
    80003a3c:	70a2                	ld	ra,40(sp)
    80003a3e:	7402                	ld	s0,32(sp)
    80003a40:	64e2                	ld	s1,24(sp)
    80003a42:	6942                	ld	s2,16(sp)
    80003a44:	69a2                	ld	s3,8(sp)
    80003a46:	6145                	addi	sp,sp,48
    80003a48:	8082                	ret

0000000080003a4a <ialloc>:
{
    80003a4a:	715d                	addi	sp,sp,-80
    80003a4c:	e486                	sd	ra,72(sp)
    80003a4e:	e0a2                	sd	s0,64(sp)
    80003a50:	fc26                	sd	s1,56(sp)
    80003a52:	f84a                	sd	s2,48(sp)
    80003a54:	f44e                	sd	s3,40(sp)
    80003a56:	f052                	sd	s4,32(sp)
    80003a58:	ec56                	sd	s5,24(sp)
    80003a5a:	e85a                	sd	s6,16(sp)
    80003a5c:	e45e                	sd	s7,8(sp)
    80003a5e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a60:	00245717          	auipc	a4,0x245
    80003a64:	47472703          	lw	a4,1140(a4) # 80248ed4 <sb+0xc>
    80003a68:	4785                	li	a5,1
    80003a6a:	04e7f663          	bgeu	a5,a4,80003ab6 <ialloc+0x6c>
    80003a6e:	8aaa                	mv	s5,a0
    80003a70:	8bae                	mv	s7,a1
    80003a72:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a74:	00245a17          	auipc	s4,0x245
    80003a78:	454a0a13          	addi	s4,s4,1108 # 80248ec8 <sb>
    80003a7c:	00048b1b          	sext.w	s6,s1
    80003a80:	0044d593          	srli	a1,s1,0x4
    80003a84:	018a2783          	lw	a5,24(s4)
    80003a88:	9dbd                	addw	a1,a1,a5
    80003a8a:	8556                	mv	a0,s5
    80003a8c:	a79ff0ef          	jal	ra,80003504 <bread>
    80003a90:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a92:	05850993          	addi	s3,a0,88
    80003a96:	00f4f793          	andi	a5,s1,15
    80003a9a:	079a                	slli	a5,a5,0x6
    80003a9c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a9e:	00099783          	lh	a5,0(s3)
    80003aa2:	cf85                	beqz	a5,80003ada <ialloc+0x90>
    brelse(bp);
    80003aa4:	b69ff0ef          	jal	ra,8000360c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aa8:	0485                	addi	s1,s1,1
    80003aaa:	00ca2703          	lw	a4,12(s4)
    80003aae:	0004879b          	sext.w	a5,s1
    80003ab2:	fce7e5e3          	bltu	a5,a4,80003a7c <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ab6:	00005517          	auipc	a0,0x5
    80003aba:	aa250513          	addi	a0,a0,-1374 # 80008558 <syscalls+0x160>
    80003abe:	a05fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003ac2:	4501                	li	a0,0
}
    80003ac4:	60a6                	ld	ra,72(sp)
    80003ac6:	6406                	ld	s0,64(sp)
    80003ac8:	74e2                	ld	s1,56(sp)
    80003aca:	7942                	ld	s2,48(sp)
    80003acc:	79a2                	ld	s3,40(sp)
    80003ace:	7a02                	ld	s4,32(sp)
    80003ad0:	6ae2                	ld	s5,24(sp)
    80003ad2:	6b42                	ld	s6,16(sp)
    80003ad4:	6ba2                	ld	s7,8(sp)
    80003ad6:	6161                	addi	sp,sp,80
    80003ad8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ada:	04000613          	li	a2,64
    80003ade:	4581                	li	a1,0
    80003ae0:	854e                	mv	a0,s3
    80003ae2:	a92fd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    80003ae6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003aea:	854a                	mv	a0,s2
    80003aec:	433000ef          	jal	ra,8000471e <log_write>
      brelse(bp);
    80003af0:	854a                	mv	a0,s2
    80003af2:	b1bff0ef          	jal	ra,8000360c <brelse>
      return iget(dev, inum);
    80003af6:	85da                	mv	a1,s6
    80003af8:	8556                	mv	a0,s5
    80003afa:	e4dff0ef          	jal	ra,80003946 <iget>
    80003afe:	b7d9                	j	80003ac4 <ialloc+0x7a>

0000000080003b00 <iupdate>:
{
    80003b00:	1101                	addi	sp,sp,-32
    80003b02:	ec06                	sd	ra,24(sp)
    80003b04:	e822                	sd	s0,16(sp)
    80003b06:	e426                	sd	s1,8(sp)
    80003b08:	e04a                	sd	s2,0(sp)
    80003b0a:	1000                	addi	s0,sp,32
    80003b0c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b0e:	415c                	lw	a5,4(a0)
    80003b10:	0047d79b          	srliw	a5,a5,0x4
    80003b14:	00245597          	auipc	a1,0x245
    80003b18:	3cc5a583          	lw	a1,972(a1) # 80248ee0 <sb+0x18>
    80003b1c:	9dbd                	addw	a1,a1,a5
    80003b1e:	4108                	lw	a0,0(a0)
    80003b20:	9e5ff0ef          	jal	ra,80003504 <bread>
    80003b24:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b26:	05850793          	addi	a5,a0,88
    80003b2a:	40d8                	lw	a4,4(s1)
    80003b2c:	8b3d                	andi	a4,a4,15
    80003b2e:	071a                	slli	a4,a4,0x6
    80003b30:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b32:	04449703          	lh	a4,68(s1)
    80003b36:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b3a:	04649703          	lh	a4,70(s1)
    80003b3e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b42:	04849703          	lh	a4,72(s1)
    80003b46:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b4a:	04a49703          	lh	a4,74(s1)
    80003b4e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b52:	44f8                	lw	a4,76(s1)
    80003b54:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b56:	03400613          	li	a2,52
    80003b5a:	05048593          	addi	a1,s1,80
    80003b5e:	00c78513          	addi	a0,a5,12
    80003b62:	a6efd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003b66:	854a                	mv	a0,s2
    80003b68:	3b7000ef          	jal	ra,8000471e <log_write>
  brelse(bp);
    80003b6c:	854a                	mv	a0,s2
    80003b6e:	a9fff0ef          	jal	ra,8000360c <brelse>
}
    80003b72:	60e2                	ld	ra,24(sp)
    80003b74:	6442                	ld	s0,16(sp)
    80003b76:	64a2                	ld	s1,8(sp)
    80003b78:	6902                	ld	s2,0(sp)
    80003b7a:	6105                	addi	sp,sp,32
    80003b7c:	8082                	ret

0000000080003b7e <idup>:
{
    80003b7e:	1101                	addi	sp,sp,-32
    80003b80:	ec06                	sd	ra,24(sp)
    80003b82:	e822                	sd	s0,16(sp)
    80003b84:	e426                	sd	s1,8(sp)
    80003b86:	1000                	addi	s0,sp,32
    80003b88:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b8a:	00245517          	auipc	a0,0x245
    80003b8e:	35e50513          	addi	a0,a0,862 # 80248ee8 <itable>
    80003b92:	90efd0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    80003b96:	449c                	lw	a5,8(s1)
    80003b98:	2785                	addiw	a5,a5,1
    80003b9a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b9c:	00245517          	auipc	a0,0x245
    80003ba0:	34c50513          	addi	a0,a0,844 # 80248ee8 <itable>
    80003ba4:	994fd0ef          	jal	ra,80000d38 <release>
}
    80003ba8:	8526                	mv	a0,s1
    80003baa:	60e2                	ld	ra,24(sp)
    80003bac:	6442                	ld	s0,16(sp)
    80003bae:	64a2                	ld	s1,8(sp)
    80003bb0:	6105                	addi	sp,sp,32
    80003bb2:	8082                	ret

0000000080003bb4 <ilock>:
{
    80003bb4:	1101                	addi	sp,sp,-32
    80003bb6:	ec06                	sd	ra,24(sp)
    80003bb8:	e822                	sd	s0,16(sp)
    80003bba:	e426                	sd	s1,8(sp)
    80003bbc:	e04a                	sd	s2,0(sp)
    80003bbe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bc0:	c105                	beqz	a0,80003be0 <ilock+0x2c>
    80003bc2:	84aa                	mv	s1,a0
    80003bc4:	451c                	lw	a5,8(a0)
    80003bc6:	00f05d63          	blez	a5,80003be0 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003bca:	0541                	addi	a0,a0,16
    80003bcc:	44b000ef          	jal	ra,80004816 <acquiresleep>
  if(ip->valid == 0){
    80003bd0:	40bc                	lw	a5,64(s1)
    80003bd2:	cf89                	beqz	a5,80003bec <ilock+0x38>
}
    80003bd4:	60e2                	ld	ra,24(sp)
    80003bd6:	6442                	ld	s0,16(sp)
    80003bd8:	64a2                	ld	s1,8(sp)
    80003bda:	6902                	ld	s2,0(sp)
    80003bdc:	6105                	addi	sp,sp,32
    80003bde:	8082                	ret
    panic("ilock");
    80003be0:	00005517          	auipc	a0,0x5
    80003be4:	99050513          	addi	a0,a0,-1648 # 80008570 <syscalls+0x178>
    80003be8:	ba1fc0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bec:	40dc                	lw	a5,4(s1)
    80003bee:	0047d79b          	srliw	a5,a5,0x4
    80003bf2:	00245597          	auipc	a1,0x245
    80003bf6:	2ee5a583          	lw	a1,750(a1) # 80248ee0 <sb+0x18>
    80003bfa:	9dbd                	addw	a1,a1,a5
    80003bfc:	4088                	lw	a0,0(s1)
    80003bfe:	907ff0ef          	jal	ra,80003504 <bread>
    80003c02:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c04:	05850593          	addi	a1,a0,88
    80003c08:	40dc                	lw	a5,4(s1)
    80003c0a:	8bbd                	andi	a5,a5,15
    80003c0c:	079a                	slli	a5,a5,0x6
    80003c0e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c10:	00059783          	lh	a5,0(a1)
    80003c14:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c18:	00259783          	lh	a5,2(a1)
    80003c1c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c20:	00459783          	lh	a5,4(a1)
    80003c24:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c28:	00659783          	lh	a5,6(a1)
    80003c2c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c30:	459c                	lw	a5,8(a1)
    80003c32:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c34:	03400613          	li	a2,52
    80003c38:	05b1                	addi	a1,a1,12
    80003c3a:	05048513          	addi	a0,s1,80
    80003c3e:	992fd0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    80003c42:	854a                	mv	a0,s2
    80003c44:	9c9ff0ef          	jal	ra,8000360c <brelse>
    ip->valid = 1;
    80003c48:	4785                	li	a5,1
    80003c4a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c4c:	04449783          	lh	a5,68(s1)
    80003c50:	f3d1                	bnez	a5,80003bd4 <ilock+0x20>
      panic("ilock: no type");
    80003c52:	00005517          	auipc	a0,0x5
    80003c56:	92650513          	addi	a0,a0,-1754 # 80008578 <syscalls+0x180>
    80003c5a:	b2ffc0ef          	jal	ra,80000788 <panic>

0000000080003c5e <iunlock>:
{
    80003c5e:	1101                	addi	sp,sp,-32
    80003c60:	ec06                	sd	ra,24(sp)
    80003c62:	e822                	sd	s0,16(sp)
    80003c64:	e426                	sd	s1,8(sp)
    80003c66:	e04a                	sd	s2,0(sp)
    80003c68:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c6a:	c505                	beqz	a0,80003c92 <iunlock+0x34>
    80003c6c:	84aa                	mv	s1,a0
    80003c6e:	01050913          	addi	s2,a0,16
    80003c72:	854a                	mv	a0,s2
    80003c74:	421000ef          	jal	ra,80004894 <holdingsleep>
    80003c78:	cd09                	beqz	a0,80003c92 <iunlock+0x34>
    80003c7a:	449c                	lw	a5,8(s1)
    80003c7c:	00f05b63          	blez	a5,80003c92 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003c80:	854a                	mv	a0,s2
    80003c82:	3db000ef          	jal	ra,8000485c <releasesleep>
}
    80003c86:	60e2                	ld	ra,24(sp)
    80003c88:	6442                	ld	s0,16(sp)
    80003c8a:	64a2                	ld	s1,8(sp)
    80003c8c:	6902                	ld	s2,0(sp)
    80003c8e:	6105                	addi	sp,sp,32
    80003c90:	8082                	ret
    panic("iunlock");
    80003c92:	00005517          	auipc	a0,0x5
    80003c96:	8f650513          	addi	a0,a0,-1802 # 80008588 <syscalls+0x190>
    80003c9a:	aeffc0ef          	jal	ra,80000788 <panic>

0000000080003c9e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c9e:	7179                	addi	sp,sp,-48
    80003ca0:	f406                	sd	ra,40(sp)
    80003ca2:	f022                	sd	s0,32(sp)
    80003ca4:	ec26                	sd	s1,24(sp)
    80003ca6:	e84a                	sd	s2,16(sp)
    80003ca8:	e44e                	sd	s3,8(sp)
    80003caa:	e052                	sd	s4,0(sp)
    80003cac:	1800                	addi	s0,sp,48
    80003cae:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cb0:	05050493          	addi	s1,a0,80
    80003cb4:	08050913          	addi	s2,a0,128
    80003cb8:	a021                	j	80003cc0 <itrunc+0x22>
    80003cba:	0491                	addi	s1,s1,4
    80003cbc:	01248b63          	beq	s1,s2,80003cd2 <itrunc+0x34>
    if(ip->addrs[i]){
    80003cc0:	408c                	lw	a1,0(s1)
    80003cc2:	dde5                	beqz	a1,80003cba <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cc4:	0009a503          	lw	a0,0(s3)
    80003cc8:	a37ff0ef          	jal	ra,800036fe <bfree>
      ip->addrs[i] = 0;
    80003ccc:	0004a023          	sw	zero,0(s1)
    80003cd0:	b7ed                	j	80003cba <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cd2:	0809a583          	lw	a1,128(s3)
    80003cd6:	ed91                	bnez	a1,80003cf2 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cd8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003cdc:	854e                	mv	a0,s3
    80003cde:	e23ff0ef          	jal	ra,80003b00 <iupdate>
}
    80003ce2:	70a2                	ld	ra,40(sp)
    80003ce4:	7402                	ld	s0,32(sp)
    80003ce6:	64e2                	ld	s1,24(sp)
    80003ce8:	6942                	ld	s2,16(sp)
    80003cea:	69a2                	ld	s3,8(sp)
    80003cec:	6a02                	ld	s4,0(sp)
    80003cee:	6145                	addi	sp,sp,48
    80003cf0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cf2:	0009a503          	lw	a0,0(s3)
    80003cf6:	80fff0ef          	jal	ra,80003504 <bread>
    80003cfa:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003cfc:	05850493          	addi	s1,a0,88
    80003d00:	45850913          	addi	s2,a0,1112
    80003d04:	a021                	j	80003d0c <itrunc+0x6e>
    80003d06:	0491                	addi	s1,s1,4
    80003d08:	01248963          	beq	s1,s2,80003d1a <itrunc+0x7c>
      if(a[j])
    80003d0c:	408c                	lw	a1,0(s1)
    80003d0e:	dde5                	beqz	a1,80003d06 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003d10:	0009a503          	lw	a0,0(s3)
    80003d14:	9ebff0ef          	jal	ra,800036fe <bfree>
    80003d18:	b7fd                	j	80003d06 <itrunc+0x68>
    brelse(bp);
    80003d1a:	8552                	mv	a0,s4
    80003d1c:	8f1ff0ef          	jal	ra,8000360c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d20:	0809a583          	lw	a1,128(s3)
    80003d24:	0009a503          	lw	a0,0(s3)
    80003d28:	9d7ff0ef          	jal	ra,800036fe <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d2c:	0809a023          	sw	zero,128(s3)
    80003d30:	b765                	j	80003cd8 <itrunc+0x3a>

0000000080003d32 <iput>:
{
    80003d32:	1101                	addi	sp,sp,-32
    80003d34:	ec06                	sd	ra,24(sp)
    80003d36:	e822                	sd	s0,16(sp)
    80003d38:	e426                	sd	s1,8(sp)
    80003d3a:	e04a                	sd	s2,0(sp)
    80003d3c:	1000                	addi	s0,sp,32
    80003d3e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d40:	00245517          	auipc	a0,0x245
    80003d44:	1a850513          	addi	a0,a0,424 # 80248ee8 <itable>
    80003d48:	f59fc0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d4c:	4498                	lw	a4,8(s1)
    80003d4e:	4785                	li	a5,1
    80003d50:	02f70163          	beq	a4,a5,80003d72 <iput+0x40>
  ip->ref--;
    80003d54:	449c                	lw	a5,8(s1)
    80003d56:	37fd                	addiw	a5,a5,-1
    80003d58:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d5a:	00245517          	auipc	a0,0x245
    80003d5e:	18e50513          	addi	a0,a0,398 # 80248ee8 <itable>
    80003d62:	fd7fc0ef          	jal	ra,80000d38 <release>
}
    80003d66:	60e2                	ld	ra,24(sp)
    80003d68:	6442                	ld	s0,16(sp)
    80003d6a:	64a2                	ld	s1,8(sp)
    80003d6c:	6902                	ld	s2,0(sp)
    80003d6e:	6105                	addi	sp,sp,32
    80003d70:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d72:	40bc                	lw	a5,64(s1)
    80003d74:	d3e5                	beqz	a5,80003d54 <iput+0x22>
    80003d76:	04a49783          	lh	a5,74(s1)
    80003d7a:	ffe9                	bnez	a5,80003d54 <iput+0x22>
    acquiresleep(&ip->lock);
    80003d7c:	01048913          	addi	s2,s1,16
    80003d80:	854a                	mv	a0,s2
    80003d82:	295000ef          	jal	ra,80004816 <acquiresleep>
    release(&itable.lock);
    80003d86:	00245517          	auipc	a0,0x245
    80003d8a:	16250513          	addi	a0,a0,354 # 80248ee8 <itable>
    80003d8e:	fabfc0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    80003d92:	8526                	mv	a0,s1
    80003d94:	f0bff0ef          	jal	ra,80003c9e <itrunc>
    ip->type = 0;
    80003d98:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d9c:	8526                	mv	a0,s1
    80003d9e:	d63ff0ef          	jal	ra,80003b00 <iupdate>
    ip->valid = 0;
    80003da2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003da6:	854a                	mv	a0,s2
    80003da8:	2b5000ef          	jal	ra,8000485c <releasesleep>
    acquire(&itable.lock);
    80003dac:	00245517          	auipc	a0,0x245
    80003db0:	13c50513          	addi	a0,a0,316 # 80248ee8 <itable>
    80003db4:	eedfc0ef          	jal	ra,80000ca0 <acquire>
    80003db8:	bf71                	j	80003d54 <iput+0x22>

0000000080003dba <iunlockput>:
{
    80003dba:	1101                	addi	sp,sp,-32
    80003dbc:	ec06                	sd	ra,24(sp)
    80003dbe:	e822                	sd	s0,16(sp)
    80003dc0:	e426                	sd	s1,8(sp)
    80003dc2:	1000                	addi	s0,sp,32
    80003dc4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dc6:	e99ff0ef          	jal	ra,80003c5e <iunlock>
  iput(ip);
    80003dca:	8526                	mv	a0,s1
    80003dcc:	f67ff0ef          	jal	ra,80003d32 <iput>
}
    80003dd0:	60e2                	ld	ra,24(sp)
    80003dd2:	6442                	ld	s0,16(sp)
    80003dd4:	64a2                	ld	s1,8(sp)
    80003dd6:	6105                	addi	sp,sp,32
    80003dd8:	8082                	ret

0000000080003dda <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003dda:	00245717          	auipc	a4,0x245
    80003dde:	0fa72703          	lw	a4,250(a4) # 80248ed4 <sb+0xc>
    80003de2:	4785                	li	a5,1
    80003de4:	0ae7ff63          	bgeu	a5,a4,80003ea2 <ireclaim+0xc8>
{
    80003de8:	7139                	addi	sp,sp,-64
    80003dea:	fc06                	sd	ra,56(sp)
    80003dec:	f822                	sd	s0,48(sp)
    80003dee:	f426                	sd	s1,40(sp)
    80003df0:	f04a                	sd	s2,32(sp)
    80003df2:	ec4e                	sd	s3,24(sp)
    80003df4:	e852                	sd	s4,16(sp)
    80003df6:	e456                	sd	s5,8(sp)
    80003df8:	e05a                	sd	s6,0(sp)
    80003dfa:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003dfc:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003dfe:	00050a1b          	sext.w	s4,a0
    80003e02:	00245a97          	auipc	s5,0x245
    80003e06:	0c6a8a93          	addi	s5,s5,198 # 80248ec8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003e0a:	00004b17          	auipc	s6,0x4
    80003e0e:	786b0b13          	addi	s6,s6,1926 # 80008590 <syscalls+0x198>
    80003e12:	a099                	j	80003e58 <ireclaim+0x7e>
    80003e14:	85ce                	mv	a1,s3
    80003e16:	855a                	mv	a0,s6
    80003e18:	eaafc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    80003e1c:	85ce                	mv	a1,s3
    80003e1e:	8552                	mv	a0,s4
    80003e20:	b27ff0ef          	jal	ra,80003946 <iget>
    80003e24:	89aa                	mv	s3,a0
    brelse(bp);
    80003e26:	854a                	mv	a0,s2
    80003e28:	fe4ff0ef          	jal	ra,8000360c <brelse>
    if (ip) {
    80003e2c:	00098f63          	beqz	s3,80003e4a <ireclaim+0x70>
      begin_op();
    80003e30:	76c000ef          	jal	ra,8000459c <begin_op>
      ilock(ip);
    80003e34:	854e                	mv	a0,s3
    80003e36:	d7fff0ef          	jal	ra,80003bb4 <ilock>
      iunlock(ip);
    80003e3a:	854e                	mv	a0,s3
    80003e3c:	e23ff0ef          	jal	ra,80003c5e <iunlock>
      iput(ip);
    80003e40:	854e                	mv	a0,s3
    80003e42:	ef1ff0ef          	jal	ra,80003d32 <iput>
      end_op();
    80003e46:	7c4000ef          	jal	ra,8000460a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003e4a:	0485                	addi	s1,s1,1
    80003e4c:	00caa703          	lw	a4,12(s5)
    80003e50:	0004879b          	sext.w	a5,s1
    80003e54:	02e7fd63          	bgeu	a5,a4,80003e8e <ireclaim+0xb4>
    80003e58:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003e5c:	0044d593          	srli	a1,s1,0x4
    80003e60:	018aa783          	lw	a5,24(s5)
    80003e64:	9dbd                	addw	a1,a1,a5
    80003e66:	8552                	mv	a0,s4
    80003e68:	e9cff0ef          	jal	ra,80003504 <bread>
    80003e6c:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003e6e:	05850793          	addi	a5,a0,88
    80003e72:	00f9f713          	andi	a4,s3,15
    80003e76:	071a                	slli	a4,a4,0x6
    80003e78:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003e7a:	00079703          	lh	a4,0(a5)
    80003e7e:	c701                	beqz	a4,80003e86 <ireclaim+0xac>
    80003e80:	00679783          	lh	a5,6(a5)
    80003e84:	dbc1                	beqz	a5,80003e14 <ireclaim+0x3a>
    brelse(bp);
    80003e86:	854a                	mv	a0,s2
    80003e88:	f84ff0ef          	jal	ra,8000360c <brelse>
    if (ip) {
    80003e8c:	bf7d                	j	80003e4a <ireclaim+0x70>
}
    80003e8e:	70e2                	ld	ra,56(sp)
    80003e90:	7442                	ld	s0,48(sp)
    80003e92:	74a2                	ld	s1,40(sp)
    80003e94:	7902                	ld	s2,32(sp)
    80003e96:	69e2                	ld	s3,24(sp)
    80003e98:	6a42                	ld	s4,16(sp)
    80003e9a:	6aa2                	ld	s5,8(sp)
    80003e9c:	6b02                	ld	s6,0(sp)
    80003e9e:	6121                	addi	sp,sp,64
    80003ea0:	8082                	ret
    80003ea2:	8082                	ret

0000000080003ea4 <fsinit>:
fsinit(int dev) {
    80003ea4:	7179                	addi	sp,sp,-48
    80003ea6:	f406                	sd	ra,40(sp)
    80003ea8:	f022                	sd	s0,32(sp)
    80003eaa:	ec26                	sd	s1,24(sp)
    80003eac:	e84a                	sd	s2,16(sp)
    80003eae:	e44e                	sd	s3,8(sp)
    80003eb0:	1800                	addi	s0,sp,48
    80003eb2:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003eb4:	4585                	li	a1,1
    80003eb6:	e4eff0ef          	jal	ra,80003504 <bread>
    80003eba:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ebc:	00245997          	auipc	s3,0x245
    80003ec0:	00c98993          	addi	s3,s3,12 # 80248ec8 <sb>
    80003ec4:	02000613          	li	a2,32
    80003ec8:	05850593          	addi	a1,a0,88
    80003ecc:	854e                	mv	a0,s3
    80003ece:	f03fc0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    80003ed2:	854a                	mv	a0,s2
    80003ed4:	f38ff0ef          	jal	ra,8000360c <brelse>
  if(sb.magic != FSMAGIC)
    80003ed8:	0009a703          	lw	a4,0(s3)
    80003edc:	102037b7          	lui	a5,0x10203
    80003ee0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ee4:	02f71363          	bne	a4,a5,80003f0a <fsinit+0x66>
  initlog(dev, &sb);
    80003ee8:	00245597          	auipc	a1,0x245
    80003eec:	fe058593          	addi	a1,a1,-32 # 80248ec8 <sb>
    80003ef0:	8526                	mv	a0,s1
    80003ef2:	61e000ef          	jal	ra,80004510 <initlog>
  ireclaim(dev);
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	ee3ff0ef          	jal	ra,80003dda <ireclaim>
}
    80003efc:	70a2                	ld	ra,40(sp)
    80003efe:	7402                	ld	s0,32(sp)
    80003f00:	64e2                	ld	s1,24(sp)
    80003f02:	6942                	ld	s2,16(sp)
    80003f04:	69a2                	ld	s3,8(sp)
    80003f06:	6145                	addi	sp,sp,48
    80003f08:	8082                	ret
    panic("invalid file system");
    80003f0a:	00004517          	auipc	a0,0x4
    80003f0e:	6a650513          	addi	a0,a0,1702 # 800085b0 <syscalls+0x1b8>
    80003f12:	877fc0ef          	jal	ra,80000788 <panic>

0000000080003f16 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f16:	1141                	addi	sp,sp,-16
    80003f18:	e422                	sd	s0,8(sp)
    80003f1a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f1c:	411c                	lw	a5,0(a0)
    80003f1e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f20:	415c                	lw	a5,4(a0)
    80003f22:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f24:	04451783          	lh	a5,68(a0)
    80003f28:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f2c:	04a51783          	lh	a5,74(a0)
    80003f30:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f34:	04c56783          	lwu	a5,76(a0)
    80003f38:	e99c                	sd	a5,16(a1)
}
    80003f3a:	6422                	ld	s0,8(sp)
    80003f3c:	0141                	addi	sp,sp,16
    80003f3e:	8082                	ret

0000000080003f40 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f40:	457c                	lw	a5,76(a0)
    80003f42:	0cd7ef63          	bltu	a5,a3,80004020 <readi+0xe0>
{
    80003f46:	7159                	addi	sp,sp,-112
    80003f48:	f486                	sd	ra,104(sp)
    80003f4a:	f0a2                	sd	s0,96(sp)
    80003f4c:	eca6                	sd	s1,88(sp)
    80003f4e:	e8ca                	sd	s2,80(sp)
    80003f50:	e4ce                	sd	s3,72(sp)
    80003f52:	e0d2                	sd	s4,64(sp)
    80003f54:	fc56                	sd	s5,56(sp)
    80003f56:	f85a                	sd	s6,48(sp)
    80003f58:	f45e                	sd	s7,40(sp)
    80003f5a:	f062                	sd	s8,32(sp)
    80003f5c:	ec66                	sd	s9,24(sp)
    80003f5e:	e86a                	sd	s10,16(sp)
    80003f60:	e46e                	sd	s11,8(sp)
    80003f62:	1880                	addi	s0,sp,112
    80003f64:	8b2a                	mv	s6,a0
    80003f66:	8bae                	mv	s7,a1
    80003f68:	8a32                	mv	s4,a2
    80003f6a:	84b6                	mv	s1,a3
    80003f6c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f6e:	9f35                	addw	a4,a4,a3
    return 0;
    80003f70:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f72:	08d76663          	bltu	a4,a3,80003ffe <readi+0xbe>
  if(off + n > ip->size)
    80003f76:	00e7f463          	bgeu	a5,a4,80003f7e <readi+0x3e>
    n = ip->size - off;
    80003f7a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f7e:	080a8f63          	beqz	s5,8000401c <readi+0xdc>
    80003f82:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f84:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f88:	5c7d                	li	s8,-1
    80003f8a:	a80d                	j	80003fbc <readi+0x7c>
    80003f8c:	020d1d93          	slli	s11,s10,0x20
    80003f90:	020ddd93          	srli	s11,s11,0x20
    80003f94:	05890613          	addi	a2,s2,88
    80003f98:	86ee                	mv	a3,s11
    80003f9a:	963a                	add	a2,a2,a4
    80003f9c:	85d2                	mv	a1,s4
    80003f9e:	855e                	mv	a0,s7
    80003fa0:	f02fe0ef          	jal	ra,800026a2 <either_copyout>
    80003fa4:	05850763          	beq	a0,s8,80003ff2 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fa8:	854a                	mv	a0,s2
    80003faa:	e62ff0ef          	jal	ra,8000360c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fae:	013d09bb          	addw	s3,s10,s3
    80003fb2:	009d04bb          	addw	s1,s10,s1
    80003fb6:	9a6e                	add	s4,s4,s11
    80003fb8:	0559f163          	bgeu	s3,s5,80003ffa <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003fbc:	00a4d59b          	srliw	a1,s1,0xa
    80003fc0:	855a                	mv	a0,s6
    80003fc2:	8b7ff0ef          	jal	ra,80003878 <bmap>
    80003fc6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fca:	c985                	beqz	a1,80003ffa <readi+0xba>
    bp = bread(ip->dev, addr);
    80003fcc:	000b2503          	lw	a0,0(s6)
    80003fd0:	d34ff0ef          	jal	ra,80003504 <bread>
    80003fd4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fd6:	3ff4f713          	andi	a4,s1,1023
    80003fda:	40ec87bb          	subw	a5,s9,a4
    80003fde:	413a86bb          	subw	a3,s5,s3
    80003fe2:	8d3e                	mv	s10,a5
    80003fe4:	2781                	sext.w	a5,a5
    80003fe6:	0006861b          	sext.w	a2,a3
    80003fea:	faf671e3          	bgeu	a2,a5,80003f8c <readi+0x4c>
    80003fee:	8d36                	mv	s10,a3
    80003ff0:	bf71                	j	80003f8c <readi+0x4c>
      brelse(bp);
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	e18ff0ef          	jal	ra,8000360c <brelse>
      tot = -1;
    80003ff8:	59fd                	li	s3,-1
  }
  return tot;
    80003ffa:	0009851b          	sext.w	a0,s3
}
    80003ffe:	70a6                	ld	ra,104(sp)
    80004000:	7406                	ld	s0,96(sp)
    80004002:	64e6                	ld	s1,88(sp)
    80004004:	6946                	ld	s2,80(sp)
    80004006:	69a6                	ld	s3,72(sp)
    80004008:	6a06                	ld	s4,64(sp)
    8000400a:	7ae2                	ld	s5,56(sp)
    8000400c:	7b42                	ld	s6,48(sp)
    8000400e:	7ba2                	ld	s7,40(sp)
    80004010:	7c02                	ld	s8,32(sp)
    80004012:	6ce2                	ld	s9,24(sp)
    80004014:	6d42                	ld	s10,16(sp)
    80004016:	6da2                	ld	s11,8(sp)
    80004018:	6165                	addi	sp,sp,112
    8000401a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000401c:	89d6                	mv	s3,s5
    8000401e:	bff1                	j	80003ffa <readi+0xba>
    return 0;
    80004020:	4501                	li	a0,0
}
    80004022:	8082                	ret

0000000080004024 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004024:	457c                	lw	a5,76(a0)
    80004026:	0ed7ea63          	bltu	a5,a3,8000411a <writei+0xf6>
{
    8000402a:	7159                	addi	sp,sp,-112
    8000402c:	f486                	sd	ra,104(sp)
    8000402e:	f0a2                	sd	s0,96(sp)
    80004030:	eca6                	sd	s1,88(sp)
    80004032:	e8ca                	sd	s2,80(sp)
    80004034:	e4ce                	sd	s3,72(sp)
    80004036:	e0d2                	sd	s4,64(sp)
    80004038:	fc56                	sd	s5,56(sp)
    8000403a:	f85a                	sd	s6,48(sp)
    8000403c:	f45e                	sd	s7,40(sp)
    8000403e:	f062                	sd	s8,32(sp)
    80004040:	ec66                	sd	s9,24(sp)
    80004042:	e86a                	sd	s10,16(sp)
    80004044:	e46e                	sd	s11,8(sp)
    80004046:	1880                	addi	s0,sp,112
    80004048:	8aaa                	mv	s5,a0
    8000404a:	8bae                	mv	s7,a1
    8000404c:	8a32                	mv	s4,a2
    8000404e:	8936                	mv	s2,a3
    80004050:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004052:	00e687bb          	addw	a5,a3,a4
    80004056:	0cd7e463          	bltu	a5,a3,8000411e <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000405a:	00043737          	lui	a4,0x43
    8000405e:	0cf76263          	bltu	a4,a5,80004122 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004062:	0a0b0a63          	beqz	s6,80004116 <writei+0xf2>
    80004066:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004068:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000406c:	5c7d                	li	s8,-1
    8000406e:	a825                	j	800040a6 <writei+0x82>
    80004070:	020d1d93          	slli	s11,s10,0x20
    80004074:	020ddd93          	srli	s11,s11,0x20
    80004078:	05848513          	addi	a0,s1,88
    8000407c:	86ee                	mv	a3,s11
    8000407e:	8652                	mv	a2,s4
    80004080:	85de                	mv	a1,s7
    80004082:	953a                	add	a0,a0,a4
    80004084:	e68fe0ef          	jal	ra,800026ec <either_copyin>
    80004088:	05850a63          	beq	a0,s8,800040dc <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000408c:	8526                	mv	a0,s1
    8000408e:	690000ef          	jal	ra,8000471e <log_write>
    brelse(bp);
    80004092:	8526                	mv	a0,s1
    80004094:	d78ff0ef          	jal	ra,8000360c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004098:	013d09bb          	addw	s3,s10,s3
    8000409c:	012d093b          	addw	s2,s10,s2
    800040a0:	9a6e                	add	s4,s4,s11
    800040a2:	0569f063          	bgeu	s3,s6,800040e2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800040a6:	00a9559b          	srliw	a1,s2,0xa
    800040aa:	8556                	mv	a0,s5
    800040ac:	fccff0ef          	jal	ra,80003878 <bmap>
    800040b0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800040b4:	c59d                	beqz	a1,800040e2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800040b6:	000aa503          	lw	a0,0(s5)
    800040ba:	c4aff0ef          	jal	ra,80003504 <bread>
    800040be:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c0:	3ff97713          	andi	a4,s2,1023
    800040c4:	40ec87bb          	subw	a5,s9,a4
    800040c8:	413b06bb          	subw	a3,s6,s3
    800040cc:	8d3e                	mv	s10,a5
    800040ce:	2781                	sext.w	a5,a5
    800040d0:	0006861b          	sext.w	a2,a3
    800040d4:	f8f67ee3          	bgeu	a2,a5,80004070 <writei+0x4c>
    800040d8:	8d36                	mv	s10,a3
    800040da:	bf59                	j	80004070 <writei+0x4c>
      brelse(bp);
    800040dc:	8526                	mv	a0,s1
    800040de:	d2eff0ef          	jal	ra,8000360c <brelse>
  }

  if(off > ip->size)
    800040e2:	04caa783          	lw	a5,76(s5)
    800040e6:	0127f463          	bgeu	a5,s2,800040ee <writei+0xca>
    ip->size = off;
    800040ea:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040ee:	8556                	mv	a0,s5
    800040f0:	a11ff0ef          	jal	ra,80003b00 <iupdate>

  return tot;
    800040f4:	0009851b          	sext.w	a0,s3
}
    800040f8:	70a6                	ld	ra,104(sp)
    800040fa:	7406                	ld	s0,96(sp)
    800040fc:	64e6                	ld	s1,88(sp)
    800040fe:	6946                	ld	s2,80(sp)
    80004100:	69a6                	ld	s3,72(sp)
    80004102:	6a06                	ld	s4,64(sp)
    80004104:	7ae2                	ld	s5,56(sp)
    80004106:	7b42                	ld	s6,48(sp)
    80004108:	7ba2                	ld	s7,40(sp)
    8000410a:	7c02                	ld	s8,32(sp)
    8000410c:	6ce2                	ld	s9,24(sp)
    8000410e:	6d42                	ld	s10,16(sp)
    80004110:	6da2                	ld	s11,8(sp)
    80004112:	6165                	addi	sp,sp,112
    80004114:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004116:	89da                	mv	s3,s6
    80004118:	bfd9                	j	800040ee <writei+0xca>
    return -1;
    8000411a:	557d                	li	a0,-1
}
    8000411c:	8082                	ret
    return -1;
    8000411e:	557d                	li	a0,-1
    80004120:	bfe1                	j	800040f8 <writei+0xd4>
    return -1;
    80004122:	557d                	li	a0,-1
    80004124:	bfd1                	j	800040f8 <writei+0xd4>

0000000080004126 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004126:	1141                	addi	sp,sp,-16
    80004128:	e406                	sd	ra,8(sp)
    8000412a:	e022                	sd	s0,0(sp)
    8000412c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000412e:	4639                	li	a2,14
    80004130:	d11fc0ef          	jal	ra,80000e40 <strncmp>
}
    80004134:	60a2                	ld	ra,8(sp)
    80004136:	6402                	ld	s0,0(sp)
    80004138:	0141                	addi	sp,sp,16
    8000413a:	8082                	ret

000000008000413c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000413c:	7139                	addi	sp,sp,-64
    8000413e:	fc06                	sd	ra,56(sp)
    80004140:	f822                	sd	s0,48(sp)
    80004142:	f426                	sd	s1,40(sp)
    80004144:	f04a                	sd	s2,32(sp)
    80004146:	ec4e                	sd	s3,24(sp)
    80004148:	e852                	sd	s4,16(sp)
    8000414a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000414c:	04451703          	lh	a4,68(a0)
    80004150:	4785                	li	a5,1
    80004152:	00f71a63          	bne	a4,a5,80004166 <dirlookup+0x2a>
    80004156:	892a                	mv	s2,a0
    80004158:	89ae                	mv	s3,a1
    8000415a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000415c:	457c                	lw	a5,76(a0)
    8000415e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004160:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004162:	e39d                	bnez	a5,80004188 <dirlookup+0x4c>
    80004164:	a095                	j	800041c8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004166:	00004517          	auipc	a0,0x4
    8000416a:	46250513          	addi	a0,a0,1122 # 800085c8 <syscalls+0x1d0>
    8000416e:	e1afc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80004172:	00004517          	auipc	a0,0x4
    80004176:	46e50513          	addi	a0,a0,1134 # 800085e0 <syscalls+0x1e8>
    8000417a:	e0efc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000417e:	24c1                	addiw	s1,s1,16
    80004180:	04c92783          	lw	a5,76(s2)
    80004184:	04f4f163          	bgeu	s1,a5,800041c6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004188:	4741                	li	a4,16
    8000418a:	86a6                	mv	a3,s1
    8000418c:	fc040613          	addi	a2,s0,-64
    80004190:	4581                	li	a1,0
    80004192:	854a                	mv	a0,s2
    80004194:	dadff0ef          	jal	ra,80003f40 <readi>
    80004198:	47c1                	li	a5,16
    8000419a:	fcf51ce3          	bne	a0,a5,80004172 <dirlookup+0x36>
    if(de.inum == 0)
    8000419e:	fc045783          	lhu	a5,-64(s0)
    800041a2:	dff1                	beqz	a5,8000417e <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800041a4:	fc240593          	addi	a1,s0,-62
    800041a8:	854e                	mv	a0,s3
    800041aa:	f7dff0ef          	jal	ra,80004126 <namecmp>
    800041ae:	f961                	bnez	a0,8000417e <dirlookup+0x42>
      if(poff)
    800041b0:	000a0463          	beqz	s4,800041b8 <dirlookup+0x7c>
        *poff = off;
    800041b4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041b8:	fc045583          	lhu	a1,-64(s0)
    800041bc:	00092503          	lw	a0,0(s2)
    800041c0:	f86ff0ef          	jal	ra,80003946 <iget>
    800041c4:	a011                	j	800041c8 <dirlookup+0x8c>
  return 0;
    800041c6:	4501                	li	a0,0
}
    800041c8:	70e2                	ld	ra,56(sp)
    800041ca:	7442                	ld	s0,48(sp)
    800041cc:	74a2                	ld	s1,40(sp)
    800041ce:	7902                	ld	s2,32(sp)
    800041d0:	69e2                	ld	s3,24(sp)
    800041d2:	6a42                	ld	s4,16(sp)
    800041d4:	6121                	addi	sp,sp,64
    800041d6:	8082                	ret

00000000800041d8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041d8:	711d                	addi	sp,sp,-96
    800041da:	ec86                	sd	ra,88(sp)
    800041dc:	e8a2                	sd	s0,80(sp)
    800041de:	e4a6                	sd	s1,72(sp)
    800041e0:	e0ca                	sd	s2,64(sp)
    800041e2:	fc4e                	sd	s3,56(sp)
    800041e4:	f852                	sd	s4,48(sp)
    800041e6:	f456                	sd	s5,40(sp)
    800041e8:	f05a                	sd	s6,32(sp)
    800041ea:	ec5e                	sd	s7,24(sp)
    800041ec:	e862                	sd	s8,16(sp)
    800041ee:	e466                	sd	s9,8(sp)
    800041f0:	e06a                	sd	s10,0(sp)
    800041f2:	1080                	addi	s0,sp,96
    800041f4:	84aa                	mv	s1,a0
    800041f6:	8b2e                	mv	s6,a1
    800041f8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041fa:	00054703          	lbu	a4,0(a0)
    800041fe:	02f00793          	li	a5,47
    80004202:	00f70f63          	beq	a4,a5,80004220 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004206:	943fd0ef          	jal	ra,80001b48 <myproc>
    8000420a:	15053503          	ld	a0,336(a0)
    8000420e:	971ff0ef          	jal	ra,80003b7e <idup>
    80004212:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004214:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004218:	4cb5                	li	s9,13
  len = path - s;
    8000421a:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000421c:	4c05                	li	s8,1
    8000421e:	a879                	j	800042bc <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80004220:	4585                	li	a1,1
    80004222:	4505                	li	a0,1
    80004224:	f22ff0ef          	jal	ra,80003946 <iget>
    80004228:	8a2a                	mv	s4,a0
    8000422a:	b7ed                	j	80004214 <namex+0x3c>
      iunlockput(ip);
    8000422c:	8552                	mv	a0,s4
    8000422e:	b8dff0ef          	jal	ra,80003dba <iunlockput>
      return 0;
    80004232:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004234:	8552                	mv	a0,s4
    80004236:	60e6                	ld	ra,88(sp)
    80004238:	6446                	ld	s0,80(sp)
    8000423a:	64a6                	ld	s1,72(sp)
    8000423c:	6906                	ld	s2,64(sp)
    8000423e:	79e2                	ld	s3,56(sp)
    80004240:	7a42                	ld	s4,48(sp)
    80004242:	7aa2                	ld	s5,40(sp)
    80004244:	7b02                	ld	s6,32(sp)
    80004246:	6be2                	ld	s7,24(sp)
    80004248:	6c42                	ld	s8,16(sp)
    8000424a:	6ca2                	ld	s9,8(sp)
    8000424c:	6d02                	ld	s10,0(sp)
    8000424e:	6125                	addi	sp,sp,96
    80004250:	8082                	ret
      iunlock(ip);
    80004252:	8552                	mv	a0,s4
    80004254:	a0bff0ef          	jal	ra,80003c5e <iunlock>
      return ip;
    80004258:	bff1                	j	80004234 <namex+0x5c>
      iunlockput(ip);
    8000425a:	8552                	mv	a0,s4
    8000425c:	b5fff0ef          	jal	ra,80003dba <iunlockput>
      return 0;
    80004260:	8a4e                	mv	s4,s3
    80004262:	bfc9                	j	80004234 <namex+0x5c>
  len = path - s;
    80004264:	40998633          	sub	a2,s3,s1
    80004268:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000426c:	09acd063          	bge	s9,s10,800042ec <namex+0x114>
    memmove(name, s, DIRSIZ);
    80004270:	4639                	li	a2,14
    80004272:	85a6                	mv	a1,s1
    80004274:	8556                	mv	a0,s5
    80004276:	b5bfc0ef          	jal	ra,80000dd0 <memmove>
    8000427a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000427c:	0004c783          	lbu	a5,0(s1)
    80004280:	01279763          	bne	a5,s2,8000428e <namex+0xb6>
    path++;
    80004284:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004286:	0004c783          	lbu	a5,0(s1)
    8000428a:	ff278de3          	beq	a5,s2,80004284 <namex+0xac>
    ilock(ip);
    8000428e:	8552                	mv	a0,s4
    80004290:	925ff0ef          	jal	ra,80003bb4 <ilock>
    if(ip->type != T_DIR){
    80004294:	044a1783          	lh	a5,68(s4)
    80004298:	f9879ae3          	bne	a5,s8,8000422c <namex+0x54>
    if(nameiparent && *path == '\0'){
    8000429c:	000b0563          	beqz	s6,800042a6 <namex+0xce>
    800042a0:	0004c783          	lbu	a5,0(s1)
    800042a4:	d7dd                	beqz	a5,80004252 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042a6:	865e                	mv	a2,s7
    800042a8:	85d6                	mv	a1,s5
    800042aa:	8552                	mv	a0,s4
    800042ac:	e91ff0ef          	jal	ra,8000413c <dirlookup>
    800042b0:	89aa                	mv	s3,a0
    800042b2:	d545                	beqz	a0,8000425a <namex+0x82>
    iunlockput(ip);
    800042b4:	8552                	mv	a0,s4
    800042b6:	b05ff0ef          	jal	ra,80003dba <iunlockput>
    ip = next;
    800042ba:	8a4e                	mv	s4,s3
  while(*path == '/')
    800042bc:	0004c783          	lbu	a5,0(s1)
    800042c0:	01279763          	bne	a5,s2,800042ce <namex+0xf6>
    path++;
    800042c4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042c6:	0004c783          	lbu	a5,0(s1)
    800042ca:	ff278de3          	beq	a5,s2,800042c4 <namex+0xec>
  if(*path == 0)
    800042ce:	cb8d                	beqz	a5,80004300 <namex+0x128>
  while(*path != '/' && *path != 0)
    800042d0:	0004c783          	lbu	a5,0(s1)
    800042d4:	89a6                	mv	s3,s1
  len = path - s;
    800042d6:	8d5e                	mv	s10,s7
    800042d8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800042da:	01278963          	beq	a5,s2,800042ec <namex+0x114>
    800042de:	d3d9                	beqz	a5,80004264 <namex+0x8c>
    path++;
    800042e0:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800042e2:	0009c783          	lbu	a5,0(s3)
    800042e6:	ff279ce3          	bne	a5,s2,800042de <namex+0x106>
    800042ea:	bfad                	j	80004264 <namex+0x8c>
    memmove(name, s, len);
    800042ec:	2601                	sext.w	a2,a2
    800042ee:	85a6                	mv	a1,s1
    800042f0:	8556                	mv	a0,s5
    800042f2:	adffc0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    800042f6:	9d56                	add	s10,s10,s5
    800042f8:	000d0023          	sb	zero,0(s10) # 1000 <_entry-0x7ffff000>
    800042fc:	84ce                	mv	s1,s3
    800042fe:	bfbd                	j	8000427c <namex+0xa4>
  if(nameiparent){
    80004300:	f20b0ae3          	beqz	s6,80004234 <namex+0x5c>
    iput(ip);
    80004304:	8552                	mv	a0,s4
    80004306:	a2dff0ef          	jal	ra,80003d32 <iput>
    return 0;
    8000430a:	4a01                	li	s4,0
    8000430c:	b725                	j	80004234 <namex+0x5c>

000000008000430e <dirlink>:
{
    8000430e:	7139                	addi	sp,sp,-64
    80004310:	fc06                	sd	ra,56(sp)
    80004312:	f822                	sd	s0,48(sp)
    80004314:	f426                	sd	s1,40(sp)
    80004316:	f04a                	sd	s2,32(sp)
    80004318:	ec4e                	sd	s3,24(sp)
    8000431a:	e852                	sd	s4,16(sp)
    8000431c:	0080                	addi	s0,sp,64
    8000431e:	892a                	mv	s2,a0
    80004320:	8a2e                	mv	s4,a1
    80004322:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004324:	4601                	li	a2,0
    80004326:	e17ff0ef          	jal	ra,8000413c <dirlookup>
    8000432a:	e52d                	bnez	a0,80004394 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000432c:	04c92483          	lw	s1,76(s2)
    80004330:	c48d                	beqz	s1,8000435a <dirlink+0x4c>
    80004332:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004334:	4741                	li	a4,16
    80004336:	86a6                	mv	a3,s1
    80004338:	fc040613          	addi	a2,s0,-64
    8000433c:	4581                	li	a1,0
    8000433e:	854a                	mv	a0,s2
    80004340:	c01ff0ef          	jal	ra,80003f40 <readi>
    80004344:	47c1                	li	a5,16
    80004346:	04f51b63          	bne	a0,a5,8000439c <dirlink+0x8e>
    if(de.inum == 0)
    8000434a:	fc045783          	lhu	a5,-64(s0)
    8000434e:	c791                	beqz	a5,8000435a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004350:	24c1                	addiw	s1,s1,16
    80004352:	04c92783          	lw	a5,76(s2)
    80004356:	fcf4efe3          	bltu	s1,a5,80004334 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000435a:	4639                	li	a2,14
    8000435c:	85d2                	mv	a1,s4
    8000435e:	fc240513          	addi	a0,s0,-62
    80004362:	b1bfc0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    80004366:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000436a:	4741                	li	a4,16
    8000436c:	86a6                	mv	a3,s1
    8000436e:	fc040613          	addi	a2,s0,-64
    80004372:	4581                	li	a1,0
    80004374:	854a                	mv	a0,s2
    80004376:	cafff0ef          	jal	ra,80004024 <writei>
    8000437a:	1541                	addi	a0,a0,-16
    8000437c:	00a03533          	snez	a0,a0
    80004380:	40a00533          	neg	a0,a0
}
    80004384:	70e2                	ld	ra,56(sp)
    80004386:	7442                	ld	s0,48(sp)
    80004388:	74a2                	ld	s1,40(sp)
    8000438a:	7902                	ld	s2,32(sp)
    8000438c:	69e2                	ld	s3,24(sp)
    8000438e:	6a42                	ld	s4,16(sp)
    80004390:	6121                	addi	sp,sp,64
    80004392:	8082                	ret
    iput(ip);
    80004394:	99fff0ef          	jal	ra,80003d32 <iput>
    return -1;
    80004398:	557d                	li	a0,-1
    8000439a:	b7ed                	j	80004384 <dirlink+0x76>
      panic("dirlink read");
    8000439c:	00004517          	auipc	a0,0x4
    800043a0:	25450513          	addi	a0,a0,596 # 800085f0 <syscalls+0x1f8>
    800043a4:	be4fc0ef          	jal	ra,80000788 <panic>

00000000800043a8 <namei>:

struct inode*
namei(char *path)
{
    800043a8:	1101                	addi	sp,sp,-32
    800043aa:	ec06                	sd	ra,24(sp)
    800043ac:	e822                	sd	s0,16(sp)
    800043ae:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043b0:	fe040613          	addi	a2,s0,-32
    800043b4:	4581                	li	a1,0
    800043b6:	e23ff0ef          	jal	ra,800041d8 <namex>
}
    800043ba:	60e2                	ld	ra,24(sp)
    800043bc:	6442                	ld	s0,16(sp)
    800043be:	6105                	addi	sp,sp,32
    800043c0:	8082                	ret

00000000800043c2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043c2:	1141                	addi	sp,sp,-16
    800043c4:	e406                	sd	ra,8(sp)
    800043c6:	e022                	sd	s0,0(sp)
    800043c8:	0800                	addi	s0,sp,16
    800043ca:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043cc:	4585                	li	a1,1
    800043ce:	e0bff0ef          	jal	ra,800041d8 <namex>
}
    800043d2:	60a2                	ld	ra,8(sp)
    800043d4:	6402                	ld	s0,0(sp)
    800043d6:	0141                	addi	sp,sp,16
    800043d8:	8082                	ret

00000000800043da <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043da:	1101                	addi	sp,sp,-32
    800043dc:	ec06                	sd	ra,24(sp)
    800043de:	e822                	sd	s0,16(sp)
    800043e0:	e426                	sd	s1,8(sp)
    800043e2:	e04a                	sd	s2,0(sp)
    800043e4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043e6:	00246917          	auipc	s2,0x246
    800043ea:	5aa90913          	addi	s2,s2,1450 # 8024a990 <log>
    800043ee:	01892583          	lw	a1,24(s2)
    800043f2:	02492503          	lw	a0,36(s2)
    800043f6:	90eff0ef          	jal	ra,80003504 <bread>
    800043fa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043fc:	02892683          	lw	a3,40(s2)
    80004400:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004402:	02d05863          	blez	a3,80004432 <write_head+0x58>
    80004406:	00246797          	auipc	a5,0x246
    8000440a:	5b678793          	addi	a5,a5,1462 # 8024a9bc <log+0x2c>
    8000440e:	05c50713          	addi	a4,a0,92
    80004412:	36fd                	addiw	a3,a3,-1
    80004414:	02069613          	slli	a2,a3,0x20
    80004418:	01e65693          	srli	a3,a2,0x1e
    8000441c:	00246617          	auipc	a2,0x246
    80004420:	5a460613          	addi	a2,a2,1444 # 8024a9c0 <log+0x30>
    80004424:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004426:	4390                	lw	a2,0(a5)
    80004428:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000442a:	0791                	addi	a5,a5,4
    8000442c:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000442e:	fed79ce3          	bne	a5,a3,80004426 <write_head+0x4c>
  }
  bwrite(buf);
    80004432:	8526                	mv	a0,s1
    80004434:	9a6ff0ef          	jal	ra,800035da <bwrite>
  brelse(buf);
    80004438:	8526                	mv	a0,s1
    8000443a:	9d2ff0ef          	jal	ra,8000360c <brelse>
}
    8000443e:	60e2                	ld	ra,24(sp)
    80004440:	6442                	ld	s0,16(sp)
    80004442:	64a2                	ld	s1,8(sp)
    80004444:	6902                	ld	s2,0(sp)
    80004446:	6105                	addi	sp,sp,32
    80004448:	8082                	ret

000000008000444a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000444a:	00246797          	auipc	a5,0x246
    8000444e:	56e7a783          	lw	a5,1390(a5) # 8024a9b8 <log+0x28>
    80004452:	0af05e63          	blez	a5,8000450e <install_trans+0xc4>
{
    80004456:	715d                	addi	sp,sp,-80
    80004458:	e486                	sd	ra,72(sp)
    8000445a:	e0a2                	sd	s0,64(sp)
    8000445c:	fc26                	sd	s1,56(sp)
    8000445e:	f84a                	sd	s2,48(sp)
    80004460:	f44e                	sd	s3,40(sp)
    80004462:	f052                	sd	s4,32(sp)
    80004464:	ec56                	sd	s5,24(sp)
    80004466:	e85a                	sd	s6,16(sp)
    80004468:	e45e                	sd	s7,8(sp)
    8000446a:	0880                	addi	s0,sp,80
    8000446c:	8b2a                	mv	s6,a0
    8000446e:	00246a97          	auipc	s5,0x246
    80004472:	54ea8a93          	addi	s5,s5,1358 # 8024a9bc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004476:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004478:	00004b97          	auipc	s7,0x4
    8000447c:	188b8b93          	addi	s7,s7,392 # 80008600 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004480:	00246a17          	auipc	s4,0x246
    80004484:	510a0a13          	addi	s4,s4,1296 # 8024a990 <log>
    80004488:	a025                	j	800044b0 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000448a:	000aa603          	lw	a2,0(s5)
    8000448e:	85ce                	mv	a1,s3
    80004490:	855e                	mv	a0,s7
    80004492:	830fc0ef          	jal	ra,800004c2 <printf>
    80004496:	a839                	j	800044b4 <install_trans+0x6a>
    brelse(lbuf);
    80004498:	854a                	mv	a0,s2
    8000449a:	972ff0ef          	jal	ra,8000360c <brelse>
    brelse(dbuf);
    8000449e:	8526                	mv	a0,s1
    800044a0:	96cff0ef          	jal	ra,8000360c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044a4:	2985                	addiw	s3,s3,1
    800044a6:	0a91                	addi	s5,s5,4
    800044a8:	028a2783          	lw	a5,40(s4)
    800044ac:	04f9d663          	bge	s3,a5,800044f8 <install_trans+0xae>
    if(recovering) {
    800044b0:	fc0b1de3          	bnez	s6,8000448a <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044b4:	018a2583          	lw	a1,24(s4)
    800044b8:	013585bb          	addw	a1,a1,s3
    800044bc:	2585                	addiw	a1,a1,1
    800044be:	024a2503          	lw	a0,36(s4)
    800044c2:	842ff0ef          	jal	ra,80003504 <bread>
    800044c6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044c8:	000aa583          	lw	a1,0(s5)
    800044cc:	024a2503          	lw	a0,36(s4)
    800044d0:	834ff0ef          	jal	ra,80003504 <bread>
    800044d4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044d6:	40000613          	li	a2,1024
    800044da:	05890593          	addi	a1,s2,88
    800044de:	05850513          	addi	a0,a0,88
    800044e2:	8effc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800044e6:	8526                	mv	a0,s1
    800044e8:	8f2ff0ef          	jal	ra,800035da <bwrite>
    if(recovering == 0)
    800044ec:	fa0b16e3          	bnez	s6,80004498 <install_trans+0x4e>
      bunpin(dbuf);
    800044f0:	8526                	mv	a0,s1
    800044f2:	9d8ff0ef          	jal	ra,800036ca <bunpin>
    800044f6:	b74d                	j	80004498 <install_trans+0x4e>
}
    800044f8:	60a6                	ld	ra,72(sp)
    800044fa:	6406                	ld	s0,64(sp)
    800044fc:	74e2                	ld	s1,56(sp)
    800044fe:	7942                	ld	s2,48(sp)
    80004500:	79a2                	ld	s3,40(sp)
    80004502:	7a02                	ld	s4,32(sp)
    80004504:	6ae2                	ld	s5,24(sp)
    80004506:	6b42                	ld	s6,16(sp)
    80004508:	6ba2                	ld	s7,8(sp)
    8000450a:	6161                	addi	sp,sp,80
    8000450c:	8082                	ret
    8000450e:	8082                	ret

0000000080004510 <initlog>:
{
    80004510:	7179                	addi	sp,sp,-48
    80004512:	f406                	sd	ra,40(sp)
    80004514:	f022                	sd	s0,32(sp)
    80004516:	ec26                	sd	s1,24(sp)
    80004518:	e84a                	sd	s2,16(sp)
    8000451a:	e44e                	sd	s3,8(sp)
    8000451c:	1800                	addi	s0,sp,48
    8000451e:	892a                	mv	s2,a0
    80004520:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004522:	00246497          	auipc	s1,0x246
    80004526:	46e48493          	addi	s1,s1,1134 # 8024a990 <log>
    8000452a:	00004597          	auipc	a1,0x4
    8000452e:	0f658593          	addi	a1,a1,246 # 80008620 <syscalls+0x228>
    80004532:	8526                	mv	a0,s1
    80004534:	eecfc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    80004538:	0149a583          	lw	a1,20(s3)
    8000453c:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000453e:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004542:	854a                	mv	a0,s2
    80004544:	fc1fe0ef          	jal	ra,80003504 <bread>
  log.lh.n = lh->n;
    80004548:	4d34                	lw	a3,88(a0)
    8000454a:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000454c:	02d05663          	blez	a3,80004578 <initlog+0x68>
    80004550:	05c50793          	addi	a5,a0,92
    80004554:	00246717          	auipc	a4,0x246
    80004558:	46870713          	addi	a4,a4,1128 # 8024a9bc <log+0x2c>
    8000455c:	36fd                	addiw	a3,a3,-1
    8000455e:	02069613          	slli	a2,a3,0x20
    80004562:	01e65693          	srli	a3,a2,0x1e
    80004566:	06050613          	addi	a2,a0,96
    8000456a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000456c:	4390                	lw	a2,0(a5)
    8000456e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004570:	0791                	addi	a5,a5,4
    80004572:	0711                	addi	a4,a4,4
    80004574:	fed79ce3          	bne	a5,a3,8000456c <initlog+0x5c>
  brelse(buf);
    80004578:	894ff0ef          	jal	ra,8000360c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000457c:	4505                	li	a0,1
    8000457e:	ecdff0ef          	jal	ra,8000444a <install_trans>
  log.lh.n = 0;
    80004582:	00246797          	auipc	a5,0x246
    80004586:	4207ab23          	sw	zero,1078(a5) # 8024a9b8 <log+0x28>
  write_head(); // clear the log
    8000458a:	e51ff0ef          	jal	ra,800043da <write_head>
}
    8000458e:	70a2                	ld	ra,40(sp)
    80004590:	7402                	ld	s0,32(sp)
    80004592:	64e2                	ld	s1,24(sp)
    80004594:	6942                	ld	s2,16(sp)
    80004596:	69a2                	ld	s3,8(sp)
    80004598:	6145                	addi	sp,sp,48
    8000459a:	8082                	ret

000000008000459c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000459c:	1101                	addi	sp,sp,-32
    8000459e:	ec06                	sd	ra,24(sp)
    800045a0:	e822                	sd	s0,16(sp)
    800045a2:	e426                	sd	s1,8(sp)
    800045a4:	e04a                	sd	s2,0(sp)
    800045a6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045a8:	00246517          	auipc	a0,0x246
    800045ac:	3e850513          	addi	a0,a0,1000 # 8024a990 <log>
    800045b0:	ef0fc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    800045b4:	00246497          	auipc	s1,0x246
    800045b8:	3dc48493          	addi	s1,s1,988 # 8024a990 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800045bc:	4979                	li	s2,30
    800045be:	a029                	j	800045c8 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800045c0:	85a6                	mv	a1,s1
    800045c2:	8526                	mv	a0,s1
    800045c4:	d83fd0ef          	jal	ra,80002346 <sleep>
    if(log.committing){
    800045c8:	509c                	lw	a5,32(s1)
    800045ca:	fbfd                	bnez	a5,800045c0 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800045cc:	4cd8                	lw	a4,28(s1)
    800045ce:	2705                	addiw	a4,a4,1
    800045d0:	0007069b          	sext.w	a3,a4
    800045d4:	0027179b          	slliw	a5,a4,0x2
    800045d8:	9fb9                	addw	a5,a5,a4
    800045da:	0017979b          	slliw	a5,a5,0x1
    800045de:	5498                	lw	a4,40(s1)
    800045e0:	9fb9                	addw	a5,a5,a4
    800045e2:	00f95763          	bge	s2,a5,800045f0 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045e6:	85a6                	mv	a1,s1
    800045e8:	8526                	mv	a0,s1
    800045ea:	d5dfd0ef          	jal	ra,80002346 <sleep>
    800045ee:	bfe9                	j	800045c8 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800045f0:	00246517          	auipc	a0,0x246
    800045f4:	3a050513          	addi	a0,a0,928 # 8024a990 <log>
    800045f8:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    800045fa:	f3efc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    800045fe:	60e2                	ld	ra,24(sp)
    80004600:	6442                	ld	s0,16(sp)
    80004602:	64a2                	ld	s1,8(sp)
    80004604:	6902                	ld	s2,0(sp)
    80004606:	6105                	addi	sp,sp,32
    80004608:	8082                	ret

000000008000460a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000460a:	7139                	addi	sp,sp,-64
    8000460c:	fc06                	sd	ra,56(sp)
    8000460e:	f822                	sd	s0,48(sp)
    80004610:	f426                	sd	s1,40(sp)
    80004612:	f04a                	sd	s2,32(sp)
    80004614:	ec4e                	sd	s3,24(sp)
    80004616:	e852                	sd	s4,16(sp)
    80004618:	e456                	sd	s5,8(sp)
    8000461a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000461c:	00246497          	auipc	s1,0x246
    80004620:	37448493          	addi	s1,s1,884 # 8024a990 <log>
    80004624:	8526                	mv	a0,s1
    80004626:	e7afc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    8000462a:	4cdc                	lw	a5,28(s1)
    8000462c:	37fd                	addiw	a5,a5,-1
    8000462e:	0007891b          	sext.w	s2,a5
    80004632:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004634:	509c                	lw	a5,32(s1)
    80004636:	ef9d                	bnez	a5,80004674 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004638:	04091463          	bnez	s2,80004680 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000463c:	00246497          	auipc	s1,0x246
    80004640:	35448493          	addi	s1,s1,852 # 8024a990 <log>
    80004644:	4785                	li	a5,1
    80004646:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004648:	8526                	mv	a0,s1
    8000464a:	eeefc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000464e:	549c                	lw	a5,40(s1)
    80004650:	04f04b63          	bgtz	a5,800046a6 <end_op+0x9c>
    acquire(&log.lock);
    80004654:	00246497          	auipc	s1,0x246
    80004658:	33c48493          	addi	s1,s1,828 # 8024a990 <log>
    8000465c:	8526                	mv	a0,s1
    8000465e:	e42fc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    80004662:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004666:	8526                	mv	a0,s1
    80004668:	d2bfd0ef          	jal	ra,80002392 <wakeup>
    release(&log.lock);
    8000466c:	8526                	mv	a0,s1
    8000466e:	ecafc0ef          	jal	ra,80000d38 <release>
}
    80004672:	a00d                	j	80004694 <end_op+0x8a>
    panic("log.committing");
    80004674:	00004517          	auipc	a0,0x4
    80004678:	fb450513          	addi	a0,a0,-76 # 80008628 <syscalls+0x230>
    8000467c:	90cfc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    80004680:	00246497          	auipc	s1,0x246
    80004684:	31048493          	addi	s1,s1,784 # 8024a990 <log>
    80004688:	8526                	mv	a0,s1
    8000468a:	d09fd0ef          	jal	ra,80002392 <wakeup>
  release(&log.lock);
    8000468e:	8526                	mv	a0,s1
    80004690:	ea8fc0ef          	jal	ra,80000d38 <release>
}
    80004694:	70e2                	ld	ra,56(sp)
    80004696:	7442                	ld	s0,48(sp)
    80004698:	74a2                	ld	s1,40(sp)
    8000469a:	7902                	ld	s2,32(sp)
    8000469c:	69e2                	ld	s3,24(sp)
    8000469e:	6a42                	ld	s4,16(sp)
    800046a0:	6aa2                	ld	s5,8(sp)
    800046a2:	6121                	addi	sp,sp,64
    800046a4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800046a6:	00246a97          	auipc	s5,0x246
    800046aa:	316a8a93          	addi	s5,s5,790 # 8024a9bc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046ae:	00246a17          	auipc	s4,0x246
    800046b2:	2e2a0a13          	addi	s4,s4,738 # 8024a990 <log>
    800046b6:	018a2583          	lw	a1,24(s4)
    800046ba:	012585bb          	addw	a1,a1,s2
    800046be:	2585                	addiw	a1,a1,1
    800046c0:	024a2503          	lw	a0,36(s4)
    800046c4:	e41fe0ef          	jal	ra,80003504 <bread>
    800046c8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046ca:	000aa583          	lw	a1,0(s5)
    800046ce:	024a2503          	lw	a0,36(s4)
    800046d2:	e33fe0ef          	jal	ra,80003504 <bread>
    800046d6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046d8:	40000613          	li	a2,1024
    800046dc:	05850593          	addi	a1,a0,88
    800046e0:	05848513          	addi	a0,s1,88
    800046e4:	eecfc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    800046e8:	8526                	mv	a0,s1
    800046ea:	ef1fe0ef          	jal	ra,800035da <bwrite>
    brelse(from);
    800046ee:	854e                	mv	a0,s3
    800046f0:	f1dfe0ef          	jal	ra,8000360c <brelse>
    brelse(to);
    800046f4:	8526                	mv	a0,s1
    800046f6:	f17fe0ef          	jal	ra,8000360c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046fa:	2905                	addiw	s2,s2,1
    800046fc:	0a91                	addi	s5,s5,4
    800046fe:	028a2783          	lw	a5,40(s4)
    80004702:	faf94ae3          	blt	s2,a5,800046b6 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004706:	cd5ff0ef          	jal	ra,800043da <write_head>
    install_trans(0); // Now install writes to home locations
    8000470a:	4501                	li	a0,0
    8000470c:	d3fff0ef          	jal	ra,8000444a <install_trans>
    log.lh.n = 0;
    80004710:	00246797          	auipc	a5,0x246
    80004714:	2a07a423          	sw	zero,680(a5) # 8024a9b8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004718:	cc3ff0ef          	jal	ra,800043da <write_head>
    8000471c:	bf25                	j	80004654 <end_op+0x4a>

000000008000471e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000471e:	1101                	addi	sp,sp,-32
    80004720:	ec06                	sd	ra,24(sp)
    80004722:	e822                	sd	s0,16(sp)
    80004724:	e426                	sd	s1,8(sp)
    80004726:	e04a                	sd	s2,0(sp)
    80004728:	1000                	addi	s0,sp,32
    8000472a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000472c:	00246917          	auipc	s2,0x246
    80004730:	26490913          	addi	s2,s2,612 # 8024a990 <log>
    80004734:	854a                	mv	a0,s2
    80004736:	d6afc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000473a:	02892603          	lw	a2,40(s2)
    8000473e:	47f5                	li	a5,29
    80004740:	04c7cc63          	blt	a5,a2,80004798 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004744:	00246797          	auipc	a5,0x246
    80004748:	2687a783          	lw	a5,616(a5) # 8024a9ac <log+0x1c>
    8000474c:	04f05c63          	blez	a5,800047a4 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004750:	4781                	li	a5,0
    80004752:	04c05f63          	blez	a2,800047b0 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004756:	44cc                	lw	a1,12(s1)
    80004758:	00246717          	auipc	a4,0x246
    8000475c:	26470713          	addi	a4,a4,612 # 8024a9bc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004760:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004762:	4314                	lw	a3,0(a4)
    80004764:	04b68663          	beq	a3,a1,800047b0 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004768:	2785                	addiw	a5,a5,1
    8000476a:	0711                	addi	a4,a4,4
    8000476c:	fef61be3          	bne	a2,a5,80004762 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004770:	0621                	addi	a2,a2,8
    80004772:	060a                	slli	a2,a2,0x2
    80004774:	00246797          	auipc	a5,0x246
    80004778:	21c78793          	addi	a5,a5,540 # 8024a990 <log>
    8000477c:	97b2                	add	a5,a5,a2
    8000477e:	44d8                	lw	a4,12(s1)
    80004780:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004782:	8526                	mv	a0,s1
    80004784:	f13fe0ef          	jal	ra,80003696 <bpin>
    log.lh.n++;
    80004788:	00246717          	auipc	a4,0x246
    8000478c:	20870713          	addi	a4,a4,520 # 8024a990 <log>
    80004790:	571c                	lw	a5,40(a4)
    80004792:	2785                	addiw	a5,a5,1
    80004794:	d71c                	sw	a5,40(a4)
    80004796:	a80d                	j	800047c8 <log_write+0xaa>
    panic("too big a transaction");
    80004798:	00004517          	auipc	a0,0x4
    8000479c:	ea050513          	addi	a0,a0,-352 # 80008638 <syscalls+0x240>
    800047a0:	fe9fb0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    800047a4:	00004517          	auipc	a0,0x4
    800047a8:	eac50513          	addi	a0,a0,-340 # 80008650 <syscalls+0x258>
    800047ac:	fddfb0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    800047b0:	00878693          	addi	a3,a5,8
    800047b4:	068a                	slli	a3,a3,0x2
    800047b6:	00246717          	auipc	a4,0x246
    800047ba:	1da70713          	addi	a4,a4,474 # 8024a990 <log>
    800047be:	9736                	add	a4,a4,a3
    800047c0:	44d4                	lw	a3,12(s1)
    800047c2:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047c4:	faf60fe3          	beq	a2,a5,80004782 <log_write+0x64>
  }
  release(&log.lock);
    800047c8:	00246517          	auipc	a0,0x246
    800047cc:	1c850513          	addi	a0,a0,456 # 8024a990 <log>
    800047d0:	d68fc0ef          	jal	ra,80000d38 <release>
}
    800047d4:	60e2                	ld	ra,24(sp)
    800047d6:	6442                	ld	s0,16(sp)
    800047d8:	64a2                	ld	s1,8(sp)
    800047da:	6902                	ld	s2,0(sp)
    800047dc:	6105                	addi	sp,sp,32
    800047de:	8082                	ret

00000000800047e0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047e0:	1101                	addi	sp,sp,-32
    800047e2:	ec06                	sd	ra,24(sp)
    800047e4:	e822                	sd	s0,16(sp)
    800047e6:	e426                	sd	s1,8(sp)
    800047e8:	e04a                	sd	s2,0(sp)
    800047ea:	1000                	addi	s0,sp,32
    800047ec:	84aa                	mv	s1,a0
    800047ee:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047f0:	00004597          	auipc	a1,0x4
    800047f4:	e8058593          	addi	a1,a1,-384 # 80008670 <syscalls+0x278>
    800047f8:	0521                	addi	a0,a0,8
    800047fa:	c26fc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    800047fe:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004802:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004806:	0204a423          	sw	zero,40(s1)
}
    8000480a:	60e2                	ld	ra,24(sp)
    8000480c:	6442                	ld	s0,16(sp)
    8000480e:	64a2                	ld	s1,8(sp)
    80004810:	6902                	ld	s2,0(sp)
    80004812:	6105                	addi	sp,sp,32
    80004814:	8082                	ret

0000000080004816 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004816:	1101                	addi	sp,sp,-32
    80004818:	ec06                	sd	ra,24(sp)
    8000481a:	e822                	sd	s0,16(sp)
    8000481c:	e426                	sd	s1,8(sp)
    8000481e:	e04a                	sd	s2,0(sp)
    80004820:	1000                	addi	s0,sp,32
    80004822:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004824:	00850913          	addi	s2,a0,8
    80004828:	854a                	mv	a0,s2
    8000482a:	c76fc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    8000482e:	409c                	lw	a5,0(s1)
    80004830:	c799                	beqz	a5,8000483e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004832:	85ca                	mv	a1,s2
    80004834:	8526                	mv	a0,s1
    80004836:	b11fd0ef          	jal	ra,80002346 <sleep>
  while (lk->locked) {
    8000483a:	409c                	lw	a5,0(s1)
    8000483c:	fbfd                	bnez	a5,80004832 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000483e:	4785                	li	a5,1
    80004840:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004842:	b06fd0ef          	jal	ra,80001b48 <myproc>
    80004846:	591c                	lw	a5,48(a0)
    80004848:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000484a:	854a                	mv	a0,s2
    8000484c:	cecfc0ef          	jal	ra,80000d38 <release>
}
    80004850:	60e2                	ld	ra,24(sp)
    80004852:	6442                	ld	s0,16(sp)
    80004854:	64a2                	ld	s1,8(sp)
    80004856:	6902                	ld	s2,0(sp)
    80004858:	6105                	addi	sp,sp,32
    8000485a:	8082                	ret

000000008000485c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000485c:	1101                	addi	sp,sp,-32
    8000485e:	ec06                	sd	ra,24(sp)
    80004860:	e822                	sd	s0,16(sp)
    80004862:	e426                	sd	s1,8(sp)
    80004864:	e04a                	sd	s2,0(sp)
    80004866:	1000                	addi	s0,sp,32
    80004868:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000486a:	00850913          	addi	s2,a0,8
    8000486e:	854a                	mv	a0,s2
    80004870:	c30fc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    80004874:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004878:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000487c:	8526                	mv	a0,s1
    8000487e:	b15fd0ef          	jal	ra,80002392 <wakeup>
  release(&lk->lk);
    80004882:	854a                	mv	a0,s2
    80004884:	cb4fc0ef          	jal	ra,80000d38 <release>
}
    80004888:	60e2                	ld	ra,24(sp)
    8000488a:	6442                	ld	s0,16(sp)
    8000488c:	64a2                	ld	s1,8(sp)
    8000488e:	6902                	ld	s2,0(sp)
    80004890:	6105                	addi	sp,sp,32
    80004892:	8082                	ret

0000000080004894 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004894:	7179                	addi	sp,sp,-48
    80004896:	f406                	sd	ra,40(sp)
    80004898:	f022                	sd	s0,32(sp)
    8000489a:	ec26                	sd	s1,24(sp)
    8000489c:	e84a                	sd	s2,16(sp)
    8000489e:	e44e                	sd	s3,8(sp)
    800048a0:	1800                	addi	s0,sp,48
    800048a2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048a4:	00850913          	addi	s2,a0,8
    800048a8:	854a                	mv	a0,s2
    800048aa:	bf6fc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048ae:	409c                	lw	a5,0(s1)
    800048b0:	ef89                	bnez	a5,800048ca <holdingsleep+0x36>
    800048b2:	4481                	li	s1,0
  release(&lk->lk);
    800048b4:	854a                	mv	a0,s2
    800048b6:	c82fc0ef          	jal	ra,80000d38 <release>
  return r;
}
    800048ba:	8526                	mv	a0,s1
    800048bc:	70a2                	ld	ra,40(sp)
    800048be:	7402                	ld	s0,32(sp)
    800048c0:	64e2                	ld	s1,24(sp)
    800048c2:	6942                	ld	s2,16(sp)
    800048c4:	69a2                	ld	s3,8(sp)
    800048c6:	6145                	addi	sp,sp,48
    800048c8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048ca:	0284a983          	lw	s3,40(s1)
    800048ce:	a7afd0ef          	jal	ra,80001b48 <myproc>
    800048d2:	5904                	lw	s1,48(a0)
    800048d4:	413484b3          	sub	s1,s1,s3
    800048d8:	0014b493          	seqz	s1,s1
    800048dc:	bfe1                	j	800048b4 <holdingsleep+0x20>

00000000800048de <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048de:	1141                	addi	sp,sp,-16
    800048e0:	e406                	sd	ra,8(sp)
    800048e2:	e022                	sd	s0,0(sp)
    800048e4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048e6:	00004597          	auipc	a1,0x4
    800048ea:	d9a58593          	addi	a1,a1,-614 # 80008680 <syscalls+0x288>
    800048ee:	00246517          	auipc	a0,0x246
    800048f2:	1ea50513          	addi	a0,a0,490 # 8024aad8 <ftable>
    800048f6:	b2afc0ef          	jal	ra,80000c20 <initlock>
}
    800048fa:	60a2                	ld	ra,8(sp)
    800048fc:	6402                	ld	s0,0(sp)
    800048fe:	0141                	addi	sp,sp,16
    80004900:	8082                	ret

0000000080004902 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004902:	1101                	addi	sp,sp,-32
    80004904:	ec06                	sd	ra,24(sp)
    80004906:	e822                	sd	s0,16(sp)
    80004908:	e426                	sd	s1,8(sp)
    8000490a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000490c:	00246517          	auipc	a0,0x246
    80004910:	1cc50513          	addi	a0,a0,460 # 8024aad8 <ftable>
    80004914:	b8cfc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004918:	00246497          	auipc	s1,0x246
    8000491c:	1d848493          	addi	s1,s1,472 # 8024aaf0 <ftable+0x18>
    80004920:	00247717          	auipc	a4,0x247
    80004924:	17070713          	addi	a4,a4,368 # 8024ba90 <disk>
    if(f->ref == 0){
    80004928:	40dc                	lw	a5,4(s1)
    8000492a:	cf89                	beqz	a5,80004944 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000492c:	02848493          	addi	s1,s1,40
    80004930:	fee49ce3          	bne	s1,a4,80004928 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004934:	00246517          	auipc	a0,0x246
    80004938:	1a450513          	addi	a0,a0,420 # 8024aad8 <ftable>
    8000493c:	bfcfc0ef          	jal	ra,80000d38 <release>
  return 0;
    80004940:	4481                	li	s1,0
    80004942:	a809                	j	80004954 <filealloc+0x52>
      f->ref = 1;
    80004944:	4785                	li	a5,1
    80004946:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004948:	00246517          	auipc	a0,0x246
    8000494c:	19050513          	addi	a0,a0,400 # 8024aad8 <ftable>
    80004950:	be8fc0ef          	jal	ra,80000d38 <release>
}
    80004954:	8526                	mv	a0,s1
    80004956:	60e2                	ld	ra,24(sp)
    80004958:	6442                	ld	s0,16(sp)
    8000495a:	64a2                	ld	s1,8(sp)
    8000495c:	6105                	addi	sp,sp,32
    8000495e:	8082                	ret

0000000080004960 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004960:	1101                	addi	sp,sp,-32
    80004962:	ec06                	sd	ra,24(sp)
    80004964:	e822                	sd	s0,16(sp)
    80004966:	e426                	sd	s1,8(sp)
    80004968:	1000                	addi	s0,sp,32
    8000496a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000496c:	00246517          	auipc	a0,0x246
    80004970:	16c50513          	addi	a0,a0,364 # 8024aad8 <ftable>
    80004974:	b2cfc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004978:	40dc                	lw	a5,4(s1)
    8000497a:	02f05063          	blez	a5,8000499a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000497e:	2785                	addiw	a5,a5,1
    80004980:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004982:	00246517          	auipc	a0,0x246
    80004986:	15650513          	addi	a0,a0,342 # 8024aad8 <ftable>
    8000498a:	baefc0ef          	jal	ra,80000d38 <release>
  return f;
}
    8000498e:	8526                	mv	a0,s1
    80004990:	60e2                	ld	ra,24(sp)
    80004992:	6442                	ld	s0,16(sp)
    80004994:	64a2                	ld	s1,8(sp)
    80004996:	6105                	addi	sp,sp,32
    80004998:	8082                	ret
    panic("filedup");
    8000499a:	00004517          	auipc	a0,0x4
    8000499e:	cee50513          	addi	a0,a0,-786 # 80008688 <syscalls+0x290>
    800049a2:	de7fb0ef          	jal	ra,80000788 <panic>

00000000800049a6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049a6:	7139                	addi	sp,sp,-64
    800049a8:	fc06                	sd	ra,56(sp)
    800049aa:	f822                	sd	s0,48(sp)
    800049ac:	f426                	sd	s1,40(sp)
    800049ae:	f04a                	sd	s2,32(sp)
    800049b0:	ec4e                	sd	s3,24(sp)
    800049b2:	e852                	sd	s4,16(sp)
    800049b4:	e456                	sd	s5,8(sp)
    800049b6:	0080                	addi	s0,sp,64
    800049b8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049ba:	00246517          	auipc	a0,0x246
    800049be:	11e50513          	addi	a0,a0,286 # 8024aad8 <ftable>
    800049c2:	adefc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    800049c6:	40dc                	lw	a5,4(s1)
    800049c8:	04f05963          	blez	a5,80004a1a <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800049cc:	37fd                	addiw	a5,a5,-1
    800049ce:	0007871b          	sext.w	a4,a5
    800049d2:	c0dc                	sw	a5,4(s1)
    800049d4:	04e04963          	bgtz	a4,80004a26 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049d8:	0004a903          	lw	s2,0(s1)
    800049dc:	0094ca83          	lbu	s5,9(s1)
    800049e0:	0104ba03          	ld	s4,16(s1)
    800049e4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049e8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049ec:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049f0:	00246517          	auipc	a0,0x246
    800049f4:	0e850513          	addi	a0,a0,232 # 8024aad8 <ftable>
    800049f8:	b40fc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    800049fc:	4785                	li	a5,1
    800049fe:	04f90363          	beq	s2,a5,80004a44 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a02:	3979                	addiw	s2,s2,-2
    80004a04:	4785                	li	a5,1
    80004a06:	0327e663          	bltu	a5,s2,80004a32 <fileclose+0x8c>
    begin_op();
    80004a0a:	b93ff0ef          	jal	ra,8000459c <begin_op>
    iput(ff.ip);
    80004a0e:	854e                	mv	a0,s3
    80004a10:	b22ff0ef          	jal	ra,80003d32 <iput>
    end_op();
    80004a14:	bf7ff0ef          	jal	ra,8000460a <end_op>
    80004a18:	a829                	j	80004a32 <fileclose+0x8c>
    panic("fileclose");
    80004a1a:	00004517          	auipc	a0,0x4
    80004a1e:	c7650513          	addi	a0,a0,-906 # 80008690 <syscalls+0x298>
    80004a22:	d67fb0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    80004a26:	00246517          	auipc	a0,0x246
    80004a2a:	0b250513          	addi	a0,a0,178 # 8024aad8 <ftable>
    80004a2e:	b0afc0ef          	jal	ra,80000d38 <release>
  }
}
    80004a32:	70e2                	ld	ra,56(sp)
    80004a34:	7442                	ld	s0,48(sp)
    80004a36:	74a2                	ld	s1,40(sp)
    80004a38:	7902                	ld	s2,32(sp)
    80004a3a:	69e2                	ld	s3,24(sp)
    80004a3c:	6a42                	ld	s4,16(sp)
    80004a3e:	6aa2                	ld	s5,8(sp)
    80004a40:	6121                	addi	sp,sp,64
    80004a42:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a44:	85d6                	mv	a1,s5
    80004a46:	8552                	mv	a0,s4
    80004a48:	2ec000ef          	jal	ra,80004d34 <pipeclose>
    80004a4c:	b7dd                	j	80004a32 <fileclose+0x8c>

0000000080004a4e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a4e:	715d                	addi	sp,sp,-80
    80004a50:	e486                	sd	ra,72(sp)
    80004a52:	e0a2                	sd	s0,64(sp)
    80004a54:	fc26                	sd	s1,56(sp)
    80004a56:	f84a                	sd	s2,48(sp)
    80004a58:	f44e                	sd	s3,40(sp)
    80004a5a:	0880                	addi	s0,sp,80
    80004a5c:	84aa                	mv	s1,a0
    80004a5e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a60:	8e8fd0ef          	jal	ra,80001b48 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a64:	409c                	lw	a5,0(s1)
    80004a66:	37f9                	addiw	a5,a5,-2
    80004a68:	4705                	li	a4,1
    80004a6a:	02f76f63          	bltu	a4,a5,80004aa8 <filestat+0x5a>
    80004a6e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a70:	6c88                	ld	a0,24(s1)
    80004a72:	942ff0ef          	jal	ra,80003bb4 <ilock>
    stati(f->ip, &st);
    80004a76:	fb840593          	addi	a1,s0,-72
    80004a7a:	6c88                	ld	a0,24(s1)
    80004a7c:	c9aff0ef          	jal	ra,80003f16 <stati>
    iunlock(f->ip);
    80004a80:	6c88                	ld	a0,24(s1)
    80004a82:	9dcff0ef          	jal	ra,80003c5e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a86:	46e1                	li	a3,24
    80004a88:	fb840613          	addi	a2,s0,-72
    80004a8c:	85ce                	mv	a1,s3
    80004a8e:	05093503          	ld	a0,80(s2)
    80004a92:	cd9fc0ef          	jal	ra,8000176a <copyout>
    80004a96:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a9a:	60a6                	ld	ra,72(sp)
    80004a9c:	6406                	ld	s0,64(sp)
    80004a9e:	74e2                	ld	s1,56(sp)
    80004aa0:	7942                	ld	s2,48(sp)
    80004aa2:	79a2                	ld	s3,40(sp)
    80004aa4:	6161                	addi	sp,sp,80
    80004aa6:	8082                	ret
  return -1;
    80004aa8:	557d                	li	a0,-1
    80004aaa:	bfc5                	j	80004a9a <filestat+0x4c>

0000000080004aac <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004aac:	7179                	addi	sp,sp,-48
    80004aae:	f406                	sd	ra,40(sp)
    80004ab0:	f022                	sd	s0,32(sp)
    80004ab2:	ec26                	sd	s1,24(sp)
    80004ab4:	e84a                	sd	s2,16(sp)
    80004ab6:	e44e                	sd	s3,8(sp)
    80004ab8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004aba:	00854783          	lbu	a5,8(a0)
    80004abe:	cbc1                	beqz	a5,80004b4e <fileread+0xa2>
    80004ac0:	84aa                	mv	s1,a0
    80004ac2:	89ae                	mv	s3,a1
    80004ac4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ac6:	411c                	lw	a5,0(a0)
    80004ac8:	4705                	li	a4,1
    80004aca:	04e78363          	beq	a5,a4,80004b10 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ace:	470d                	li	a4,3
    80004ad0:	04e78563          	beq	a5,a4,80004b1a <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ad4:	4709                	li	a4,2
    80004ad6:	06e79663          	bne	a5,a4,80004b42 <fileread+0x96>
    ilock(f->ip);
    80004ada:	6d08                	ld	a0,24(a0)
    80004adc:	8d8ff0ef          	jal	ra,80003bb4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ae0:	874a                	mv	a4,s2
    80004ae2:	5094                	lw	a3,32(s1)
    80004ae4:	864e                	mv	a2,s3
    80004ae6:	4585                	li	a1,1
    80004ae8:	6c88                	ld	a0,24(s1)
    80004aea:	c56ff0ef          	jal	ra,80003f40 <readi>
    80004aee:	892a                	mv	s2,a0
    80004af0:	00a05563          	blez	a0,80004afa <fileread+0x4e>
      f->off += r;
    80004af4:	509c                	lw	a5,32(s1)
    80004af6:	9fa9                	addw	a5,a5,a0
    80004af8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004afa:	6c88                	ld	a0,24(s1)
    80004afc:	962ff0ef          	jal	ra,80003c5e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b00:	854a                	mv	a0,s2
    80004b02:	70a2                	ld	ra,40(sp)
    80004b04:	7402                	ld	s0,32(sp)
    80004b06:	64e2                	ld	s1,24(sp)
    80004b08:	6942                	ld	s2,16(sp)
    80004b0a:	69a2                	ld	s3,8(sp)
    80004b0c:	6145                	addi	sp,sp,48
    80004b0e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b10:	6908                	ld	a0,16(a0)
    80004b12:	34e000ef          	jal	ra,80004e60 <piperead>
    80004b16:	892a                	mv	s2,a0
    80004b18:	b7e5                	j	80004b00 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b1a:	02451783          	lh	a5,36(a0)
    80004b1e:	03079693          	slli	a3,a5,0x30
    80004b22:	92c1                	srli	a3,a3,0x30
    80004b24:	4725                	li	a4,9
    80004b26:	02d76663          	bltu	a4,a3,80004b52 <fileread+0xa6>
    80004b2a:	0792                	slli	a5,a5,0x4
    80004b2c:	00246717          	auipc	a4,0x246
    80004b30:	f0c70713          	addi	a4,a4,-244 # 8024aa38 <devsw>
    80004b34:	97ba                	add	a5,a5,a4
    80004b36:	639c                	ld	a5,0(a5)
    80004b38:	cf99                	beqz	a5,80004b56 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004b3a:	4505                	li	a0,1
    80004b3c:	9782                	jalr	a5
    80004b3e:	892a                	mv	s2,a0
    80004b40:	b7c1                	j	80004b00 <fileread+0x54>
    panic("fileread");
    80004b42:	00004517          	auipc	a0,0x4
    80004b46:	b5e50513          	addi	a0,a0,-1186 # 800086a0 <syscalls+0x2a8>
    80004b4a:	c3ffb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004b4e:	597d                	li	s2,-1
    80004b50:	bf45                	j	80004b00 <fileread+0x54>
      return -1;
    80004b52:	597d                	li	s2,-1
    80004b54:	b775                	j	80004b00 <fileread+0x54>
    80004b56:	597d                	li	s2,-1
    80004b58:	b765                	j	80004b00 <fileread+0x54>

0000000080004b5a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b5a:	715d                	addi	sp,sp,-80
    80004b5c:	e486                	sd	ra,72(sp)
    80004b5e:	e0a2                	sd	s0,64(sp)
    80004b60:	fc26                	sd	s1,56(sp)
    80004b62:	f84a                	sd	s2,48(sp)
    80004b64:	f44e                	sd	s3,40(sp)
    80004b66:	f052                	sd	s4,32(sp)
    80004b68:	ec56                	sd	s5,24(sp)
    80004b6a:	e85a                	sd	s6,16(sp)
    80004b6c:	e45e                	sd	s7,8(sp)
    80004b6e:	e062                	sd	s8,0(sp)
    80004b70:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b72:	00954783          	lbu	a5,9(a0)
    80004b76:	0e078863          	beqz	a5,80004c66 <filewrite+0x10c>
    80004b7a:	892a                	mv	s2,a0
    80004b7c:	8b2e                	mv	s6,a1
    80004b7e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b80:	411c                	lw	a5,0(a0)
    80004b82:	4705                	li	a4,1
    80004b84:	02e78263          	beq	a5,a4,80004ba8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b88:	470d                	li	a4,3
    80004b8a:	02e78463          	beq	a5,a4,80004bb2 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b8e:	4709                	li	a4,2
    80004b90:	0ce79563          	bne	a5,a4,80004c5a <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b94:	0ac05163          	blez	a2,80004c36 <filewrite+0xdc>
    int i = 0;
    80004b98:	4981                	li	s3,0
    80004b9a:	6b85                	lui	s7,0x1
    80004b9c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ba0:	6c05                	lui	s8,0x1
    80004ba2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004ba6:	a041                	j	80004c26 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004ba8:	6908                	ld	a0,16(a0)
    80004baa:	1e2000ef          	jal	ra,80004d8c <pipewrite>
    80004bae:	8a2a                	mv	s4,a0
    80004bb0:	a071                	j	80004c3c <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bb2:	02451783          	lh	a5,36(a0)
    80004bb6:	03079693          	slli	a3,a5,0x30
    80004bba:	92c1                	srli	a3,a3,0x30
    80004bbc:	4725                	li	a4,9
    80004bbe:	0ad76663          	bltu	a4,a3,80004c6a <filewrite+0x110>
    80004bc2:	0792                	slli	a5,a5,0x4
    80004bc4:	00246717          	auipc	a4,0x246
    80004bc8:	e7470713          	addi	a4,a4,-396 # 8024aa38 <devsw>
    80004bcc:	97ba                	add	a5,a5,a4
    80004bce:	679c                	ld	a5,8(a5)
    80004bd0:	cfd9                	beqz	a5,80004c6e <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004bd2:	4505                	li	a0,1
    80004bd4:	9782                	jalr	a5
    80004bd6:	8a2a                	mv	s4,a0
    80004bd8:	a095                	j	80004c3c <filewrite+0xe2>
    80004bda:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bde:	9bfff0ef          	jal	ra,8000459c <begin_op>
      ilock(f->ip);
    80004be2:	01893503          	ld	a0,24(s2)
    80004be6:	fcffe0ef          	jal	ra,80003bb4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004bea:	8756                	mv	a4,s5
    80004bec:	02092683          	lw	a3,32(s2)
    80004bf0:	01698633          	add	a2,s3,s6
    80004bf4:	4585                	li	a1,1
    80004bf6:	01893503          	ld	a0,24(s2)
    80004bfa:	c2aff0ef          	jal	ra,80004024 <writei>
    80004bfe:	84aa                	mv	s1,a0
    80004c00:	00a05763          	blez	a0,80004c0e <filewrite+0xb4>
        f->off += r;
    80004c04:	02092783          	lw	a5,32(s2)
    80004c08:	9fa9                	addw	a5,a5,a0
    80004c0a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c0e:	01893503          	ld	a0,24(s2)
    80004c12:	84cff0ef          	jal	ra,80003c5e <iunlock>
      end_op();
    80004c16:	9f5ff0ef          	jal	ra,8000460a <end_op>

      if(r != n1){
    80004c1a:	009a9f63          	bne	s5,s1,80004c38 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004c1e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c22:	0149db63          	bge	s3,s4,80004c38 <filewrite+0xde>
      int n1 = n - i;
    80004c26:	413a04bb          	subw	s1,s4,s3
    80004c2a:	0004879b          	sext.w	a5,s1
    80004c2e:	fafbd6e3          	bge	s7,a5,80004bda <filewrite+0x80>
    80004c32:	84e2                	mv	s1,s8
    80004c34:	b75d                	j	80004bda <filewrite+0x80>
    int i = 0;
    80004c36:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c38:	013a1f63          	bne	s4,s3,80004c56 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c3c:	8552                	mv	a0,s4
    80004c3e:	60a6                	ld	ra,72(sp)
    80004c40:	6406                	ld	s0,64(sp)
    80004c42:	74e2                	ld	s1,56(sp)
    80004c44:	7942                	ld	s2,48(sp)
    80004c46:	79a2                	ld	s3,40(sp)
    80004c48:	7a02                	ld	s4,32(sp)
    80004c4a:	6ae2                	ld	s5,24(sp)
    80004c4c:	6b42                	ld	s6,16(sp)
    80004c4e:	6ba2                	ld	s7,8(sp)
    80004c50:	6c02                	ld	s8,0(sp)
    80004c52:	6161                	addi	sp,sp,80
    80004c54:	8082                	ret
    ret = (i == n ? n : -1);
    80004c56:	5a7d                	li	s4,-1
    80004c58:	b7d5                	j	80004c3c <filewrite+0xe2>
    panic("filewrite");
    80004c5a:	00004517          	auipc	a0,0x4
    80004c5e:	a5650513          	addi	a0,a0,-1450 # 800086b0 <syscalls+0x2b8>
    80004c62:	b27fb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004c66:	5a7d                	li	s4,-1
    80004c68:	bfd1                	j	80004c3c <filewrite+0xe2>
      return -1;
    80004c6a:	5a7d                	li	s4,-1
    80004c6c:	bfc1                	j	80004c3c <filewrite+0xe2>
    80004c6e:	5a7d                	li	s4,-1
    80004c70:	b7f1                	j	80004c3c <filewrite+0xe2>

0000000080004c72 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c72:	7179                	addi	sp,sp,-48
    80004c74:	f406                	sd	ra,40(sp)
    80004c76:	f022                	sd	s0,32(sp)
    80004c78:	ec26                	sd	s1,24(sp)
    80004c7a:	e84a                	sd	s2,16(sp)
    80004c7c:	e44e                	sd	s3,8(sp)
    80004c7e:	e052                	sd	s4,0(sp)
    80004c80:	1800                	addi	s0,sp,48
    80004c82:	84aa                	mv	s1,a0
    80004c84:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c86:	0005b023          	sd	zero,0(a1)
    80004c8a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c8e:	c75ff0ef          	jal	ra,80004902 <filealloc>
    80004c92:	e088                	sd	a0,0(s1)
    80004c94:	cd35                	beqz	a0,80004d10 <pipealloc+0x9e>
    80004c96:	c6dff0ef          	jal	ra,80004902 <filealloc>
    80004c9a:	00aa3023          	sd	a0,0(s4)
    80004c9e:	c52d                	beqz	a0,80004d08 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ca0:	f0bfb0ef          	jal	ra,80000baa <kalloc>
    80004ca4:	892a                	mv	s2,a0
    80004ca6:	cd31                	beqz	a0,80004d02 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004ca8:	4985                	li	s3,1
    80004caa:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004cae:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004cb2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004cb6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cba:	00004597          	auipc	a1,0x4
    80004cbe:	a0658593          	addi	a1,a1,-1530 # 800086c0 <syscalls+0x2c8>
    80004cc2:	f5ffb0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    80004cc6:	609c                	ld	a5,0(s1)
    80004cc8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ccc:	609c                	ld	a5,0(s1)
    80004cce:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004cd2:	609c                	ld	a5,0(s1)
    80004cd4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004cd8:	609c                	ld	a5,0(s1)
    80004cda:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004cde:	000a3783          	ld	a5,0(s4)
    80004ce2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ce6:	000a3783          	ld	a5,0(s4)
    80004cea:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004cee:	000a3783          	ld	a5,0(s4)
    80004cf2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004cf6:	000a3783          	ld	a5,0(s4)
    80004cfa:	0127b823          	sd	s2,16(a5)
  return 0;
    80004cfe:	4501                	li	a0,0
    80004d00:	a005                	j	80004d20 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d02:	6088                	ld	a0,0(s1)
    80004d04:	e501                	bnez	a0,80004d0c <pipealloc+0x9a>
    80004d06:	a029                	j	80004d10 <pipealloc+0x9e>
    80004d08:	6088                	ld	a0,0(s1)
    80004d0a:	c11d                	beqz	a0,80004d30 <pipealloc+0xbe>
    fileclose(*f0);
    80004d0c:	c9bff0ef          	jal	ra,800049a6 <fileclose>
  if(*f1)
    80004d10:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d14:	557d                	li	a0,-1
  if(*f1)
    80004d16:	c789                	beqz	a5,80004d20 <pipealloc+0xae>
    fileclose(*f1);
    80004d18:	853e                	mv	a0,a5
    80004d1a:	c8dff0ef          	jal	ra,800049a6 <fileclose>
  return -1;
    80004d1e:	557d                	li	a0,-1
}
    80004d20:	70a2                	ld	ra,40(sp)
    80004d22:	7402                	ld	s0,32(sp)
    80004d24:	64e2                	ld	s1,24(sp)
    80004d26:	6942                	ld	s2,16(sp)
    80004d28:	69a2                	ld	s3,8(sp)
    80004d2a:	6a02                	ld	s4,0(sp)
    80004d2c:	6145                	addi	sp,sp,48
    80004d2e:	8082                	ret
  return -1;
    80004d30:	557d                	li	a0,-1
    80004d32:	b7fd                	j	80004d20 <pipealloc+0xae>

0000000080004d34 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d34:	1101                	addi	sp,sp,-32
    80004d36:	ec06                	sd	ra,24(sp)
    80004d38:	e822                	sd	s0,16(sp)
    80004d3a:	e426                	sd	s1,8(sp)
    80004d3c:	e04a                	sd	s2,0(sp)
    80004d3e:	1000                	addi	s0,sp,32
    80004d40:	84aa                	mv	s1,a0
    80004d42:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d44:	f5dfb0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    80004d48:	02090763          	beqz	s2,80004d76 <pipeclose+0x42>
    pi->writeopen = 0;
    80004d4c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d50:	21848513          	addi	a0,s1,536
    80004d54:	e3efd0ef          	jal	ra,80002392 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d58:	2204b783          	ld	a5,544(s1)
    80004d5c:	e785                	bnez	a5,80004d84 <pipeclose+0x50>
    release(&pi->lock);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	fd9fb0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    80004d64:	8526                	mv	a0,s1
    80004d66:	d15fb0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80004d6a:	60e2                	ld	ra,24(sp)
    80004d6c:	6442                	ld	s0,16(sp)
    80004d6e:	64a2                	ld	s1,8(sp)
    80004d70:	6902                	ld	s2,0(sp)
    80004d72:	6105                	addi	sp,sp,32
    80004d74:	8082                	ret
    pi->readopen = 0;
    80004d76:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d7a:	21c48513          	addi	a0,s1,540
    80004d7e:	e14fd0ef          	jal	ra,80002392 <wakeup>
    80004d82:	bfd9                	j	80004d58 <pipeclose+0x24>
    release(&pi->lock);
    80004d84:	8526                	mv	a0,s1
    80004d86:	fb3fb0ef          	jal	ra,80000d38 <release>
}
    80004d8a:	b7c5                	j	80004d6a <pipeclose+0x36>

0000000080004d8c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d8c:	711d                	addi	sp,sp,-96
    80004d8e:	ec86                	sd	ra,88(sp)
    80004d90:	e8a2                	sd	s0,80(sp)
    80004d92:	e4a6                	sd	s1,72(sp)
    80004d94:	e0ca                	sd	s2,64(sp)
    80004d96:	fc4e                	sd	s3,56(sp)
    80004d98:	f852                	sd	s4,48(sp)
    80004d9a:	f456                	sd	s5,40(sp)
    80004d9c:	f05a                	sd	s6,32(sp)
    80004d9e:	ec5e                	sd	s7,24(sp)
    80004da0:	e862                	sd	s8,16(sp)
    80004da2:	1080                	addi	s0,sp,96
    80004da4:	84aa                	mv	s1,a0
    80004da6:	8aae                	mv	s5,a1
    80004da8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004daa:	d9ffc0ef          	jal	ra,80001b48 <myproc>
    80004dae:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004db0:	8526                	mv	a0,s1
    80004db2:	eeffb0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    80004db6:	09405c63          	blez	s4,80004e4e <pipewrite+0xc2>
  int i = 0;
    80004dba:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004dbc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004dbe:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004dc2:	21c48b93          	addi	s7,s1,540
    80004dc6:	a81d                	j	80004dfc <pipewrite+0x70>
      release(&pi->lock);
    80004dc8:	8526                	mv	a0,s1
    80004dca:	f6ffb0ef          	jal	ra,80000d38 <release>
      return -1;
    80004dce:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004dd0:	854a                	mv	a0,s2
    80004dd2:	60e6                	ld	ra,88(sp)
    80004dd4:	6446                	ld	s0,80(sp)
    80004dd6:	64a6                	ld	s1,72(sp)
    80004dd8:	6906                	ld	s2,64(sp)
    80004dda:	79e2                	ld	s3,56(sp)
    80004ddc:	7a42                	ld	s4,48(sp)
    80004dde:	7aa2                	ld	s5,40(sp)
    80004de0:	7b02                	ld	s6,32(sp)
    80004de2:	6be2                	ld	s7,24(sp)
    80004de4:	6c42                	ld	s8,16(sp)
    80004de6:	6125                	addi	sp,sp,96
    80004de8:	8082                	ret
      wakeup(&pi->nread);
    80004dea:	8562                	mv	a0,s8
    80004dec:	da6fd0ef          	jal	ra,80002392 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004df0:	85a6                	mv	a1,s1
    80004df2:	855e                	mv	a0,s7
    80004df4:	d52fd0ef          	jal	ra,80002346 <sleep>
  while(i < n){
    80004df8:	05495c63          	bge	s2,s4,80004e50 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004dfc:	2204a783          	lw	a5,544(s1)
    80004e00:	d7e1                	beqz	a5,80004dc8 <pipewrite+0x3c>
    80004e02:	854e                	mv	a0,s3
    80004e04:	f7afd0ef          	jal	ra,8000257e <killed>
    80004e08:	f161                	bnez	a0,80004dc8 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e0a:	2184a783          	lw	a5,536(s1)
    80004e0e:	21c4a703          	lw	a4,540(s1)
    80004e12:	2007879b          	addiw	a5,a5,512
    80004e16:	fcf70ae3          	beq	a4,a5,80004dea <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e1a:	4685                	li	a3,1
    80004e1c:	01590633          	add	a2,s2,s5
    80004e20:	faf40593          	addi	a1,s0,-81
    80004e24:	0509b503          	ld	a0,80(s3)
    80004e28:	a3dfc0ef          	jal	ra,80001864 <copyin>
    80004e2c:	03650263          	beq	a0,s6,80004e50 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e30:	21c4a783          	lw	a5,540(s1)
    80004e34:	0017871b          	addiw	a4,a5,1
    80004e38:	20e4ae23          	sw	a4,540(s1)
    80004e3c:	1ff7f793          	andi	a5,a5,511
    80004e40:	97a6                	add	a5,a5,s1
    80004e42:	faf44703          	lbu	a4,-81(s0)
    80004e46:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e4a:	2905                	addiw	s2,s2,1
    80004e4c:	b775                	j	80004df8 <pipewrite+0x6c>
  int i = 0;
    80004e4e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004e50:	21848513          	addi	a0,s1,536
    80004e54:	d3efd0ef          	jal	ra,80002392 <wakeup>
  release(&pi->lock);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	edffb0ef          	jal	ra,80000d38 <release>
  return i;
    80004e5e:	bf8d                	j	80004dd0 <pipewrite+0x44>

0000000080004e60 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e60:	715d                	addi	sp,sp,-80
    80004e62:	e486                	sd	ra,72(sp)
    80004e64:	e0a2                	sd	s0,64(sp)
    80004e66:	fc26                	sd	s1,56(sp)
    80004e68:	f84a                	sd	s2,48(sp)
    80004e6a:	f44e                	sd	s3,40(sp)
    80004e6c:	f052                	sd	s4,32(sp)
    80004e6e:	ec56                	sd	s5,24(sp)
    80004e70:	e85a                	sd	s6,16(sp)
    80004e72:	0880                	addi	s0,sp,80
    80004e74:	84aa                	mv	s1,a0
    80004e76:	892e                	mv	s2,a1
    80004e78:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e7a:	ccffc0ef          	jal	ra,80001b48 <myproc>
    80004e7e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e80:	8526                	mv	a0,s1
    80004e82:	e1ffb0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e86:	2184a703          	lw	a4,536(s1)
    80004e8a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e8e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e92:	02f71363          	bne	a4,a5,80004eb8 <piperead+0x58>
    80004e96:	2244a783          	lw	a5,548(s1)
    80004e9a:	cf99                	beqz	a5,80004eb8 <piperead+0x58>
    if(killed(pr)){
    80004e9c:	8552                	mv	a0,s4
    80004e9e:	ee0fd0ef          	jal	ra,8000257e <killed>
    80004ea2:	e151                	bnez	a0,80004f26 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ea4:	85a6                	mv	a1,s1
    80004ea6:	854e                	mv	a0,s3
    80004ea8:	c9efd0ef          	jal	ra,80002346 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004eac:	2184a703          	lw	a4,536(s1)
    80004eb0:	21c4a783          	lw	a5,540(s1)
    80004eb4:	fef701e3          	beq	a4,a5,80004e96 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004eb8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004eba:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ebc:	05505363          	blez	s5,80004f02 <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    80004ec0:	2184a783          	lw	a5,536(s1)
    80004ec4:	21c4a703          	lw	a4,540(s1)
    80004ec8:	02f70d63          	beq	a4,a5,80004f02 <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004ecc:	1ff7f793          	andi	a5,a5,511
    80004ed0:	97a6                	add	a5,a5,s1
    80004ed2:	0187c783          	lbu	a5,24(a5)
    80004ed6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004eda:	4685                	li	a3,1
    80004edc:	fbf40613          	addi	a2,s0,-65
    80004ee0:	85ca                	mv	a1,s2
    80004ee2:	050a3503          	ld	a0,80(s4)
    80004ee6:	885fc0ef          	jal	ra,8000176a <copyout>
    80004eea:	05650363          	beq	a0,s6,80004f30 <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004eee:	2184a783          	lw	a5,536(s1)
    80004ef2:	2785                	addiw	a5,a5,1
    80004ef4:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ef8:	2985                	addiw	s3,s3,1
    80004efa:	0905                	addi	s2,s2,1
    80004efc:	fd3a92e3          	bne	s5,s3,80004ec0 <piperead+0x60>
    80004f00:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f02:	21c48513          	addi	a0,s1,540
    80004f06:	c8cfd0ef          	jal	ra,80002392 <wakeup>
  release(&pi->lock);
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	e2dfb0ef          	jal	ra,80000d38 <release>
  return i;
}
    80004f10:	854e                	mv	a0,s3
    80004f12:	60a6                	ld	ra,72(sp)
    80004f14:	6406                	ld	s0,64(sp)
    80004f16:	74e2                	ld	s1,56(sp)
    80004f18:	7942                	ld	s2,48(sp)
    80004f1a:	79a2                	ld	s3,40(sp)
    80004f1c:	7a02                	ld	s4,32(sp)
    80004f1e:	6ae2                	ld	s5,24(sp)
    80004f20:	6b42                	ld	s6,16(sp)
    80004f22:	6161                	addi	sp,sp,80
    80004f24:	8082                	ret
      release(&pi->lock);
    80004f26:	8526                	mv	a0,s1
    80004f28:	e11fb0ef          	jal	ra,80000d38 <release>
      return -1;
    80004f2c:	59fd                	li	s3,-1
    80004f2e:	b7cd                	j	80004f10 <piperead+0xb0>
      if(i == 0)
    80004f30:	fc0999e3          	bnez	s3,80004f02 <piperead+0xa2>
        i = -1;
    80004f34:	89aa                	mv	s3,a0
    80004f36:	b7f1                	j	80004f02 <piperead+0xa2>

0000000080004f38 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004f38:	1141                	addi	sp,sp,-16
    80004f3a:	e422                	sd	s0,8(sp)
    80004f3c:	0800                	addi	s0,sp,16
    80004f3e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f40:	8905                	andi	a0,a0,1
    80004f42:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004f44:	8b89                	andi	a5,a5,2
    80004f46:	c399                	beqz	a5,80004f4c <flags2perm+0x14>
      perm |= PTE_W;
    80004f48:	00456513          	ori	a0,a0,4
    return perm;
}
    80004f4c:	6422                	ld	s0,8(sp)
    80004f4e:	0141                	addi	sp,sp,16
    80004f50:	8082                	ret

0000000080004f52 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004f52:	b5010113          	addi	sp,sp,-1200
    80004f56:	4a113423          	sd	ra,1192(sp)
    80004f5a:	4a813023          	sd	s0,1184(sp)
    80004f5e:	48913c23          	sd	s1,1176(sp)
    80004f62:	49213823          	sd	s2,1168(sp)
    80004f66:	49313423          	sd	s3,1160(sp)
    80004f6a:	49413023          	sd	s4,1152(sp)
    80004f6e:	47513c23          	sd	s5,1144(sp)
    80004f72:	47613823          	sd	s6,1136(sp)
    80004f76:	47713423          	sd	s7,1128(sp)
    80004f7a:	47813023          	sd	s8,1120(sp)
    80004f7e:	45913c23          	sd	s9,1112(sp)
    80004f82:	45a13823          	sd	s10,1104(sp)
    80004f86:	45b13423          	sd	s11,1096(sp)
    80004f8a:	4b010413          	addi	s0,sp,1200
    80004f8e:	84aa                	mv	s1,a0
    80004f90:	b6a43023          	sd	a0,-1184(s0)
    80004f94:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f98:	bb1fc0ef          	jal	ra,80001b48 <myproc>
    80004f9c:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    80004fa0:	dfcff0ef          	jal	ra,8000459c <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	c02ff0ef          	jal	ra,800043a8 <namei>
    80004faa:	cd25                	beqz	a0,80005022 <kexec+0xd0>
    80004fac:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004fae:	c07fe0ef          	jal	ra,80003bb4 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004fb2:	04000713          	li	a4,64
    80004fb6:	4681                	li	a3,0
    80004fb8:	e5040613          	addi	a2,s0,-432
    80004fbc:	4581                	li	a1,0
    80004fbe:	8556                	mv	a0,s5
    80004fc0:	f81fe0ef          	jal	ra,80003f40 <readi>
    80004fc4:	04000793          	li	a5,64
    80004fc8:	00f51a63          	bne	a0,a5,80004fdc <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004fcc:	e5042703          	lw	a4,-432(s0)
    80004fd0:	464c47b7          	lui	a5,0x464c4
    80004fd4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fd8:	04f70963          	beq	a4,a5,8000502a <kexec+0xd8>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    memset(p->vmas, 0, sizeof(p->vmas));
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    80004fdc:	8556                	mv	a0,s5
    80004fde:	dddfe0ef          	jal	ra,80003dba <iunlockput>
    end_op();
    80004fe2:	e28ff0ef          	jal	ra,8000460a <end_op>
  }
  return -1;
    80004fe6:	557d                	li	a0,-1
}
    80004fe8:	4a813083          	ld	ra,1192(sp)
    80004fec:	4a013403          	ld	s0,1184(sp)
    80004ff0:	49813483          	ld	s1,1176(sp)
    80004ff4:	49013903          	ld	s2,1168(sp)
    80004ff8:	48813983          	ld	s3,1160(sp)
    80004ffc:	48013a03          	ld	s4,1152(sp)
    80005000:	47813a83          	ld	s5,1144(sp)
    80005004:	47013b03          	ld	s6,1136(sp)
    80005008:	46813b83          	ld	s7,1128(sp)
    8000500c:	46013c03          	ld	s8,1120(sp)
    80005010:	45813c83          	ld	s9,1112(sp)
    80005014:	45013d03          	ld	s10,1104(sp)
    80005018:	44813d83          	ld	s11,1096(sp)
    8000501c:	4b010113          	addi	sp,sp,1200
    80005020:	8082                	ret
    end_op();
    80005022:	de8ff0ef          	jal	ra,8000460a <end_op>
    return -1;
    80005026:	557d                	li	a0,-1
    80005028:	b7c1                	j	80004fe8 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    8000502a:	b7843503          	ld	a0,-1160(s0)
    8000502e:	d1bfc0ef          	jal	ra,80001d48 <proc_pagetable>
    80005032:	8baa                	mv	s7,a0
    80005034:	d545                	beqz	a0,80004fdc <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005036:	e7042783          	lw	a5,-400(s0)
    8000503a:	e8845703          	lhu	a4,-376(s0)
    8000503e:	0e070d63          	beqz	a4,80005138 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005042:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005046:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000504a:	6a05                	lui	s4,0x1
    8000504c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005050:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005054:	6d85                	lui	s11,0x1
    80005056:	7d7d                	lui	s10,0xfffff
    80005058:	a09d                	j	800050be <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000505a:	00003517          	auipc	a0,0x3
    8000505e:	66e50513          	addi	a0,a0,1646 # 800086c8 <syscalls+0x2d0>
    80005062:	f26fb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005066:	874a                	mv	a4,s2
    80005068:	009c86bb          	addw	a3,s9,s1
    8000506c:	4581                	li	a1,0
    8000506e:	8556                	mv	a0,s5
    80005070:	ed1fe0ef          	jal	ra,80003f40 <readi>
    80005074:	2501                	sext.w	a0,a0
    80005076:	0ea91f63          	bne	s2,a0,80005174 <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    8000507a:	009d84bb          	addw	s1,s11,s1
    8000507e:	013d09bb          	addw	s3,s10,s3
    80005082:	0364f063          	bgeu	s1,s6,800050a2 <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80005086:	02049593          	slli	a1,s1,0x20
    8000508a:	9181                	srli	a1,a1,0x20
    8000508c:	95e2                	add	a1,a1,s8
    8000508e:	855e                	mv	a0,s7
    80005090:	ffbfb0ef          	jal	ra,8000108a <walkaddr>
    80005094:	862a                	mv	a2,a0
    if(pa == 0)
    80005096:	d171                	beqz	a0,8000505a <kexec+0x108>
      n = PGSIZE;
    80005098:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000509a:	fd49f6e3          	bgeu	s3,s4,80005066 <kexec+0x114>
      n = sz - i;
    8000509e:	894e                	mv	s2,s3
    800050a0:	b7d9                	j	80005066 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050a2:	b8843783          	ld	a5,-1144(s0)
    800050a6:	0017869b          	addiw	a3,a5,1
    800050aa:	b8d43423          	sd	a3,-1144(s0)
    800050ae:	b8043783          	ld	a5,-1152(s0)
    800050b2:	0387879b          	addiw	a5,a5,56
    800050b6:	e8845703          	lhu	a4,-376(s0)
    800050ba:	08e6d163          	bge	a3,a4,8000513c <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050be:	2781                	sext.w	a5,a5
    800050c0:	b8f43023          	sd	a5,-1152(s0)
    800050c4:	03800713          	li	a4,56
    800050c8:	86be                	mv	a3,a5
    800050ca:	e1840613          	addi	a2,s0,-488
    800050ce:	4581                	li	a1,0
    800050d0:	8556                	mv	a0,s5
    800050d2:	e6ffe0ef          	jal	ra,80003f40 <readi>
    800050d6:	03800793          	li	a5,56
    800050da:	08f51d63          	bne	a0,a5,80005174 <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    800050de:	e1842783          	lw	a5,-488(s0)
    800050e2:	4705                	li	a4,1
    800050e4:	fae79fe3          	bne	a5,a4,800050a2 <kexec+0x150>
    if(ph.memsz < ph.filesz)
    800050e8:	e4043483          	ld	s1,-448(s0)
    800050ec:	e3843783          	ld	a5,-456(s0)
    800050f0:	08f4e263          	bltu	s1,a5,80005174 <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050f4:	e2843783          	ld	a5,-472(s0)
    800050f8:	94be                	add	s1,s1,a5
    800050fa:	06f4ed63          	bltu	s1,a5,80005174 <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    800050fe:	b5843703          	ld	a4,-1192(s0)
    80005102:	8ff9                	and	a5,a5,a4
    80005104:	eba5                	bnez	a5,80005174 <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005106:	e1c42503          	lw	a0,-484(s0)
    8000510a:	e2fff0ef          	jal	ra,80004f38 <flags2perm>
    8000510e:	86aa                	mv	a3,a0
    80005110:	8626                	mv	a2,s1
    80005112:	b7043583          	ld	a1,-1168(s0)
    80005116:	855e                	mv	a0,s7
    80005118:	a3cfc0ef          	jal	ra,80001354 <uvmalloc>
    8000511c:	b6a43823          	sd	a0,-1168(s0)
    80005120:	c931                	beqz	a0,80005174 <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005122:	e2843c03          	ld	s8,-472(s0)
    80005126:	e2042c83          	lw	s9,-480(s0)
    8000512a:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000512e:	f60b0ae3          	beqz	s6,800050a2 <kexec+0x150>
    80005132:	89da                	mv	s3,s6
    80005134:	4481                	li	s1,0
    80005136:	bf81                	j	80005086 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005138:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    8000513c:	8556                	mv	a0,s5
    8000513e:	c7dfe0ef          	jal	ra,80003dba <iunlockput>
  end_op();
    80005142:	cc8ff0ef          	jal	ra,8000460a <end_op>
  p = myproc();
    80005146:	a03fc0ef          	jal	ra,80001b48 <myproc>
    8000514a:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    8000514e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005152:	6785                	lui	a5,0x1
    80005154:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005156:	b7043703          	ld	a4,-1168(s0)
    8000515a:	00f705b3          	add	a1,a4,a5
    8000515e:	77fd                	lui	a5,0xfffff
    80005160:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005162:	4691                	li	a3,4
    80005164:	6609                	lui	a2,0x2
    80005166:	962e                	add	a2,a2,a1
    80005168:	855e                	mv	a0,s7
    8000516a:	9eafc0ef          	jal	ra,80001354 <uvmalloc>
    8000516e:	8b2a                	mv	s6,a0
  ip = 0;
    80005170:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005172:	ed0d                	bnez	a0,800051ac <kexec+0x25a>
    delete_shm_from_proc(p);
    80005174:	b7843903          	ld	s2,-1160(s0)
    80005178:	854a                	mv	a0,s2
    8000517a:	b51fc0ef          	jal	ra,80001cca <delete_shm_from_proc>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    8000517e:	16890493          	addi	s1,s2,360
    80005182:	85a6                	mv	a1,s1
    80005184:	05093503          	ld	a0,80(s2)
    80005188:	c45fc0ef          	jal	ra,80001dcc <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    8000518c:	28000613          	li	a2,640
    80005190:	4581                	li	a1,0
    80005192:	8526                	mv	a0,s1
    80005194:	be1fb0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80005198:	04893583          	ld	a1,72(s2)
    8000519c:	05093503          	ld	a0,80(s2)
    800051a0:	c77fc0ef          	jal	ra,80001e16 <proc_freepagetable>
  if(ip){
    800051a4:	e20a9ce3          	bnez	s5,80004fdc <kexec+0x8a>
  return -1;
    800051a8:	557d                	li	a0,-1
    800051aa:	bd3d                	j	80004fe8 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800051ac:	75f9                	lui	a1,0xffffe
    800051ae:	95aa                	add	a1,a1,a0
    800051b0:	855e                	mv	a0,s7
    800051b2:	c50fc0ef          	jal	ra,80001602 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800051b6:	7c7d                	lui	s8,0xfffff
    800051b8:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800051ba:	b6843783          	ld	a5,-1176(s0)
    800051be:	6388                	ld	a0,0(a5)
    800051c0:	c125                	beqz	a0,80005220 <kexec+0x2ce>
    800051c2:	e9040993          	addi	s3,s0,-368
    800051c6:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    800051ca:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800051cc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051ce:	d1ffb0ef          	jal	ra,80000eec <strlen>
    800051d2:	0015079b          	addiw	a5,a0,1
    800051d6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051da:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800051de:	11896963          	bltu	s2,s8,800052f0 <kexec+0x39e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051e2:	b6843d03          	ld	s10,-1176(s0)
    800051e6:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdab298>
    800051ea:	8552                	mv	a0,s4
    800051ec:	d01fb0ef          	jal	ra,80000eec <strlen>
    800051f0:	0015069b          	addiw	a3,a0,1
    800051f4:	8652                	mv	a2,s4
    800051f6:	85ca                	mv	a1,s2
    800051f8:	855e                	mv	a0,s7
    800051fa:	d70fc0ef          	jal	ra,8000176a <copyout>
    800051fe:	0e054b63          	bltz	a0,800052f4 <kexec+0x3a2>
    ustack[argc] = sp;
    80005202:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005206:	0485                	addi	s1,s1,1
    80005208:	008d0793          	addi	a5,s10,8
    8000520c:	b6f43423          	sd	a5,-1176(s0)
    80005210:	008d3503          	ld	a0,8(s10)
    80005214:	c901                	beqz	a0,80005224 <kexec+0x2d2>
    if(argc >= MAXARG)
    80005216:	09a1                	addi	s3,s3,8
    80005218:	fb599be3          	bne	s3,s5,800051ce <kexec+0x27c>
  ip = 0;
    8000521c:	4a81                	li	s5,0
    8000521e:	bf99                	j	80005174 <kexec+0x222>
  sp = sz;
    80005220:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005222:	4481                	li	s1,0
  ustack[argc] = 0;
    80005224:	00349793          	slli	a5,s1,0x3
    80005228:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdab228>
    8000522c:	97a2                	add	a5,a5,s0
    8000522e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005232:	00148693          	addi	a3,s1,1
    80005236:	068e                	slli	a3,a3,0x3
    80005238:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000523c:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005240:	4a81                	li	s5,0
  if(sp < stackbase)
    80005242:	f38969e3          	bltu	s2,s8,80005174 <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005246:	e9040613          	addi	a2,s0,-368
    8000524a:	85ca                	mv	a1,s2
    8000524c:	855e                	mv	a0,s7
    8000524e:	d1cfc0ef          	jal	ra,8000176a <copyout>
    80005252:	0a054363          	bltz	a0,800052f8 <kexec+0x3a6>
  p->trapframe->a1 = sp;
    80005256:	b7843783          	ld	a5,-1160(s0)
    8000525a:	6fbc                	ld	a5,88(a5)
    8000525c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005260:	b6043783          	ld	a5,-1184(s0)
    80005264:	0007c703          	lbu	a4,0(a5)
    80005268:	cf11                	beqz	a4,80005284 <kexec+0x332>
    8000526a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000526c:	02f00693          	li	a3,47
    80005270:	a039                	j	8000527e <kexec+0x32c>
      last = s+1;
    80005272:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    80005276:	0785                	addi	a5,a5,1
    80005278:	fff7c703          	lbu	a4,-1(a5)
    8000527c:	c701                	beqz	a4,80005284 <kexec+0x332>
    if(*s == '/')
    8000527e:	fed71ce3          	bne	a4,a3,80005276 <kexec+0x324>
    80005282:	bfc5                	j	80005272 <kexec+0x320>
  safestrcpy(p->name, last, sizeof(p->name));
    80005284:	4641                	li	a2,16
    80005286:	b6043583          	ld	a1,-1184(s0)
    8000528a:	b7843983          	ld	s3,-1160(s0)
    8000528e:	15898513          	addi	a0,s3,344
    80005292:	c29fb0ef          	jal	ra,80000eba <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    80005296:	16898a13          	addi	s4,s3,360
    8000529a:	28000613          	li	a2,640
    8000529e:	85d2                	mv	a1,s4
    800052a0:	b9840513          	addi	a0,s0,-1128
    800052a4:	b2dfb0ef          	jal	ra,80000dd0 <memmove>
  oldpagetable = p->pagetable;
    800052a8:	86ce                	mv	a3,s3
    800052aa:	0509b983          	ld	s3,80(s3)
  p->pagetable = pagetable;
    800052ae:	0576b823          	sd	s7,80(a3)
  p->sz = sz;
    800052b2:	0566b423          	sd	s6,72(a3)
  p->trapframe->epc = elf.entry;
    800052b6:	6ebc                	ld	a5,88(a3)
    800052b8:	e6843703          	ld	a4,-408(s0)
    800052bc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    800052be:	6ebc                	ld	a5,88(a3)
    800052c0:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    800052c4:	28000613          	li	a2,640
    800052c8:	4581                	li	a1,0
    800052ca:	8552                	mv	a0,s4
    800052cc:	aa9fb0ef          	jal	ra,80000d74 <memset>
  delete_shm_from_vmas(oldvmas);
    800052d0:	b9840513          	addi	a0,s0,-1128
    800052d4:	97bfc0ef          	jal	ra,80001c4e <delete_shm_from_vmas>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    800052d8:	b9840593          	addi	a1,s0,-1128
    800052dc:	854e                	mv	a0,s3
    800052de:	aeffc0ef          	jal	ra,80001dcc <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    800052e2:	85e6                	mv	a1,s9
    800052e4:	854e                	mv	a0,s3
    800052e6:	b31fc0ef          	jal	ra,80001e16 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052ea:	0004851b          	sext.w	a0,s1
    800052ee:	b9ed                	j	80004fe8 <kexec+0x96>
  ip = 0;
    800052f0:	4a81                	li	s5,0
    800052f2:	b549                	j	80005174 <kexec+0x222>
    800052f4:	4a81                	li	s5,0
    800052f6:	bdbd                	j	80005174 <kexec+0x222>
    800052f8:	4a81                	li	s5,0
    800052fa:	bdad                	j	80005174 <kexec+0x222>

00000000800052fc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052fc:	7179                	addi	sp,sp,-48
    800052fe:	f406                	sd	ra,40(sp)
    80005300:	f022                	sd	s0,32(sp)
    80005302:	ec26                	sd	s1,24(sp)
    80005304:	e84a                	sd	s2,16(sp)
    80005306:	1800                	addi	s0,sp,48
    80005308:	892e                	mv	s2,a1
    8000530a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000530c:	fdc40593          	addi	a1,s0,-36
    80005310:	96ffd0ef          	jal	ra,80002c7e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005314:	fdc42703          	lw	a4,-36(s0)
    80005318:	47bd                	li	a5,15
    8000531a:	02e7e963          	bltu	a5,a4,8000534c <argfd+0x50>
    8000531e:	82bfc0ef          	jal	ra,80001b48 <myproc>
    80005322:	fdc42703          	lw	a4,-36(s0)
    80005326:	01a70793          	addi	a5,a4,26
    8000532a:	078e                	slli	a5,a5,0x3
    8000532c:	953e                	add	a0,a0,a5
    8000532e:	611c                	ld	a5,0(a0)
    80005330:	c385                	beqz	a5,80005350 <argfd+0x54>
    return -1;
  if(pfd)
    80005332:	00090463          	beqz	s2,8000533a <argfd+0x3e>
    *pfd = fd;
    80005336:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000533a:	4501                	li	a0,0
  if(pf)
    8000533c:	c091                	beqz	s1,80005340 <argfd+0x44>
    *pf = f;
    8000533e:	e09c                	sd	a5,0(s1)
}
    80005340:	70a2                	ld	ra,40(sp)
    80005342:	7402                	ld	s0,32(sp)
    80005344:	64e2                	ld	s1,24(sp)
    80005346:	6942                	ld	s2,16(sp)
    80005348:	6145                	addi	sp,sp,48
    8000534a:	8082                	ret
    return -1;
    8000534c:	557d                	li	a0,-1
    8000534e:	bfcd                	j	80005340 <argfd+0x44>
    80005350:	557d                	li	a0,-1
    80005352:	b7fd                	j	80005340 <argfd+0x44>

0000000080005354 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005354:	1101                	addi	sp,sp,-32
    80005356:	ec06                	sd	ra,24(sp)
    80005358:	e822                	sd	s0,16(sp)
    8000535a:	e426                	sd	s1,8(sp)
    8000535c:	1000                	addi	s0,sp,32
    8000535e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005360:	fe8fc0ef          	jal	ra,80001b48 <myproc>
    80005364:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005366:	0d050793          	addi	a5,a0,208
    8000536a:	4501                	li	a0,0
    8000536c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000536e:	6398                	ld	a4,0(a5)
    80005370:	cb19                	beqz	a4,80005386 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005372:	2505                	addiw	a0,a0,1
    80005374:	07a1                	addi	a5,a5,8
    80005376:	fed51ce3          	bne	a0,a3,8000536e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000537a:	557d                	li	a0,-1
}
    8000537c:	60e2                	ld	ra,24(sp)
    8000537e:	6442                	ld	s0,16(sp)
    80005380:	64a2                	ld	s1,8(sp)
    80005382:	6105                	addi	sp,sp,32
    80005384:	8082                	ret
      p->ofile[fd] = f;
    80005386:	01a50793          	addi	a5,a0,26
    8000538a:	078e                	slli	a5,a5,0x3
    8000538c:	963e                	add	a2,a2,a5
    8000538e:	e204                	sd	s1,0(a2)
      return fd;
    80005390:	b7f5                	j	8000537c <fdalloc+0x28>

0000000080005392 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005392:	715d                	addi	sp,sp,-80
    80005394:	e486                	sd	ra,72(sp)
    80005396:	e0a2                	sd	s0,64(sp)
    80005398:	fc26                	sd	s1,56(sp)
    8000539a:	f84a                	sd	s2,48(sp)
    8000539c:	f44e                	sd	s3,40(sp)
    8000539e:	f052                	sd	s4,32(sp)
    800053a0:	ec56                	sd	s5,24(sp)
    800053a2:	e85a                	sd	s6,16(sp)
    800053a4:	0880                	addi	s0,sp,80
    800053a6:	8b2e                	mv	s6,a1
    800053a8:	89b2                	mv	s3,a2
    800053aa:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053ac:	fb040593          	addi	a1,s0,-80
    800053b0:	812ff0ef          	jal	ra,800043c2 <nameiparent>
    800053b4:	84aa                	mv	s1,a0
    800053b6:	10050b63          	beqz	a0,800054cc <create+0x13a>
    return 0;

  ilock(dp);
    800053ba:	ffafe0ef          	jal	ra,80003bb4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800053be:	4601                	li	a2,0
    800053c0:	fb040593          	addi	a1,s0,-80
    800053c4:	8526                	mv	a0,s1
    800053c6:	d77fe0ef          	jal	ra,8000413c <dirlookup>
    800053ca:	8aaa                	mv	s5,a0
    800053cc:	c521                	beqz	a0,80005414 <create+0x82>
    iunlockput(dp);
    800053ce:	8526                	mv	a0,s1
    800053d0:	9ebfe0ef          	jal	ra,80003dba <iunlockput>
    ilock(ip);
    800053d4:	8556                	mv	a0,s5
    800053d6:	fdefe0ef          	jal	ra,80003bb4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053da:	000b059b          	sext.w	a1,s6
    800053de:	4789                	li	a5,2
    800053e0:	02f59563          	bne	a1,a5,8000540a <create+0x78>
    800053e4:	044ad783          	lhu	a5,68(s5)
    800053e8:	37f9                	addiw	a5,a5,-2
    800053ea:	17c2                	slli	a5,a5,0x30
    800053ec:	93c1                	srli	a5,a5,0x30
    800053ee:	4705                	li	a4,1
    800053f0:	00f76d63          	bltu	a4,a5,8000540a <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053f4:	8556                	mv	a0,s5
    800053f6:	60a6                	ld	ra,72(sp)
    800053f8:	6406                	ld	s0,64(sp)
    800053fa:	74e2                	ld	s1,56(sp)
    800053fc:	7942                	ld	s2,48(sp)
    800053fe:	79a2                	ld	s3,40(sp)
    80005400:	7a02                	ld	s4,32(sp)
    80005402:	6ae2                	ld	s5,24(sp)
    80005404:	6b42                	ld	s6,16(sp)
    80005406:	6161                	addi	sp,sp,80
    80005408:	8082                	ret
    iunlockput(ip);
    8000540a:	8556                	mv	a0,s5
    8000540c:	9affe0ef          	jal	ra,80003dba <iunlockput>
    return 0;
    80005410:	4a81                	li	s5,0
    80005412:	b7cd                	j	800053f4 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005414:	85da                	mv	a1,s6
    80005416:	4088                	lw	a0,0(s1)
    80005418:	e32fe0ef          	jal	ra,80003a4a <ialloc>
    8000541c:	8a2a                	mv	s4,a0
    8000541e:	cd1d                	beqz	a0,8000545c <create+0xca>
  ilock(ip);
    80005420:	f94fe0ef          	jal	ra,80003bb4 <ilock>
  ip->major = major;
    80005424:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005428:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000542c:	4905                	li	s2,1
    8000542e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005432:	8552                	mv	a0,s4
    80005434:	eccfe0ef          	jal	ra,80003b00 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005438:	000b059b          	sext.w	a1,s6
    8000543c:	03258563          	beq	a1,s2,80005466 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80005440:	004a2603          	lw	a2,4(s4)
    80005444:	fb040593          	addi	a1,s0,-80
    80005448:	8526                	mv	a0,s1
    8000544a:	ec5fe0ef          	jal	ra,8000430e <dirlink>
    8000544e:	06054363          	bltz	a0,800054b4 <create+0x122>
  iunlockput(dp);
    80005452:	8526                	mv	a0,s1
    80005454:	967fe0ef          	jal	ra,80003dba <iunlockput>
  return ip;
    80005458:	8ad2                	mv	s5,s4
    8000545a:	bf69                	j	800053f4 <create+0x62>
    iunlockput(dp);
    8000545c:	8526                	mv	a0,s1
    8000545e:	95dfe0ef          	jal	ra,80003dba <iunlockput>
    return 0;
    80005462:	8ad2                	mv	s5,s4
    80005464:	bf41                	j	800053f4 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005466:	004a2603          	lw	a2,4(s4)
    8000546a:	00003597          	auipc	a1,0x3
    8000546e:	27e58593          	addi	a1,a1,638 # 800086e8 <syscalls+0x2f0>
    80005472:	8552                	mv	a0,s4
    80005474:	e9bfe0ef          	jal	ra,8000430e <dirlink>
    80005478:	02054e63          	bltz	a0,800054b4 <create+0x122>
    8000547c:	40d0                	lw	a2,4(s1)
    8000547e:	00003597          	auipc	a1,0x3
    80005482:	27258593          	addi	a1,a1,626 # 800086f0 <syscalls+0x2f8>
    80005486:	8552                	mv	a0,s4
    80005488:	e87fe0ef          	jal	ra,8000430e <dirlink>
    8000548c:	02054463          	bltz	a0,800054b4 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80005490:	004a2603          	lw	a2,4(s4)
    80005494:	fb040593          	addi	a1,s0,-80
    80005498:	8526                	mv	a0,s1
    8000549a:	e75fe0ef          	jal	ra,8000430e <dirlink>
    8000549e:	00054b63          	bltz	a0,800054b4 <create+0x122>
    dp->nlink++;  // for ".."
    800054a2:	04a4d783          	lhu	a5,74(s1)
    800054a6:	2785                	addiw	a5,a5,1
    800054a8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054ac:	8526                	mv	a0,s1
    800054ae:	e52fe0ef          	jal	ra,80003b00 <iupdate>
    800054b2:	b745                	j	80005452 <create+0xc0>
  ip->nlink = 0;
    800054b4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054b8:	8552                	mv	a0,s4
    800054ba:	e46fe0ef          	jal	ra,80003b00 <iupdate>
  iunlockput(ip);
    800054be:	8552                	mv	a0,s4
    800054c0:	8fbfe0ef          	jal	ra,80003dba <iunlockput>
  iunlockput(dp);
    800054c4:	8526                	mv	a0,s1
    800054c6:	8f5fe0ef          	jal	ra,80003dba <iunlockput>
  return 0;
    800054ca:	b72d                	j	800053f4 <create+0x62>
    return 0;
    800054cc:	8aaa                	mv	s5,a0
    800054ce:	b71d                	j	800053f4 <create+0x62>

00000000800054d0 <sys_dup>:
{
    800054d0:	7179                	addi	sp,sp,-48
    800054d2:	f406                	sd	ra,40(sp)
    800054d4:	f022                	sd	s0,32(sp)
    800054d6:	ec26                	sd	s1,24(sp)
    800054d8:	e84a                	sd	s2,16(sp)
    800054da:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054dc:	fd840613          	addi	a2,s0,-40
    800054e0:	4581                	li	a1,0
    800054e2:	4501                	li	a0,0
    800054e4:	e19ff0ef          	jal	ra,800052fc <argfd>
    return -1;
    800054e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054ea:	00054f63          	bltz	a0,80005508 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    800054ee:	fd843903          	ld	s2,-40(s0)
    800054f2:	854a                	mv	a0,s2
    800054f4:	e61ff0ef          	jal	ra,80005354 <fdalloc>
    800054f8:	84aa                	mv	s1,a0
    return -1;
    800054fa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054fc:	00054663          	bltz	a0,80005508 <sys_dup+0x38>
  filedup(f);
    80005500:	854a                	mv	a0,s2
    80005502:	c5eff0ef          	jal	ra,80004960 <filedup>
  return fd;
    80005506:	87a6                	mv	a5,s1
}
    80005508:	853e                	mv	a0,a5
    8000550a:	70a2                	ld	ra,40(sp)
    8000550c:	7402                	ld	s0,32(sp)
    8000550e:	64e2                	ld	s1,24(sp)
    80005510:	6942                	ld	s2,16(sp)
    80005512:	6145                	addi	sp,sp,48
    80005514:	8082                	ret

0000000080005516 <sys_read>:
{
    80005516:	7179                	addi	sp,sp,-48
    80005518:	f406                	sd	ra,40(sp)
    8000551a:	f022                	sd	s0,32(sp)
    8000551c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000551e:	fd840593          	addi	a1,s0,-40
    80005522:	4505                	li	a0,1
    80005524:	f76fd0ef          	jal	ra,80002c9a <argaddr>
  argint(2, &n);
    80005528:	fe440593          	addi	a1,s0,-28
    8000552c:	4509                	li	a0,2
    8000552e:	f50fd0ef          	jal	ra,80002c7e <argint>
  if(argfd(0, 0, &f) < 0)
    80005532:	fe840613          	addi	a2,s0,-24
    80005536:	4581                	li	a1,0
    80005538:	4501                	li	a0,0
    8000553a:	dc3ff0ef          	jal	ra,800052fc <argfd>
    8000553e:	87aa                	mv	a5,a0
    return -1;
    80005540:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005542:	0007ca63          	bltz	a5,80005556 <sys_read+0x40>
  return fileread(f, p, n);
    80005546:	fe442603          	lw	a2,-28(s0)
    8000554a:	fd843583          	ld	a1,-40(s0)
    8000554e:	fe843503          	ld	a0,-24(s0)
    80005552:	d5aff0ef          	jal	ra,80004aac <fileread>
}
    80005556:	70a2                	ld	ra,40(sp)
    80005558:	7402                	ld	s0,32(sp)
    8000555a:	6145                	addi	sp,sp,48
    8000555c:	8082                	ret

000000008000555e <sys_write>:
{
    8000555e:	7179                	addi	sp,sp,-48
    80005560:	f406                	sd	ra,40(sp)
    80005562:	f022                	sd	s0,32(sp)
    80005564:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005566:	fd840593          	addi	a1,s0,-40
    8000556a:	4505                	li	a0,1
    8000556c:	f2efd0ef          	jal	ra,80002c9a <argaddr>
  argint(2, &n);
    80005570:	fe440593          	addi	a1,s0,-28
    80005574:	4509                	li	a0,2
    80005576:	f08fd0ef          	jal	ra,80002c7e <argint>
  if(argfd(0, 0, &f) < 0)
    8000557a:	fe840613          	addi	a2,s0,-24
    8000557e:	4581                	li	a1,0
    80005580:	4501                	li	a0,0
    80005582:	d7bff0ef          	jal	ra,800052fc <argfd>
    80005586:	87aa                	mv	a5,a0
    return -1;
    80005588:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000558a:	0007ca63          	bltz	a5,8000559e <sys_write+0x40>
  return filewrite(f, p, n);
    8000558e:	fe442603          	lw	a2,-28(s0)
    80005592:	fd843583          	ld	a1,-40(s0)
    80005596:	fe843503          	ld	a0,-24(s0)
    8000559a:	dc0ff0ef          	jal	ra,80004b5a <filewrite>
}
    8000559e:	70a2                	ld	ra,40(sp)
    800055a0:	7402                	ld	s0,32(sp)
    800055a2:	6145                	addi	sp,sp,48
    800055a4:	8082                	ret

00000000800055a6 <sys_close>:
{
    800055a6:	1101                	addi	sp,sp,-32
    800055a8:	ec06                	sd	ra,24(sp)
    800055aa:	e822                	sd	s0,16(sp)
    800055ac:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055ae:	fe040613          	addi	a2,s0,-32
    800055b2:	fec40593          	addi	a1,s0,-20
    800055b6:	4501                	li	a0,0
    800055b8:	d45ff0ef          	jal	ra,800052fc <argfd>
    return -1;
    800055bc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055be:	02054063          	bltz	a0,800055de <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800055c2:	d86fc0ef          	jal	ra,80001b48 <myproc>
    800055c6:	fec42783          	lw	a5,-20(s0)
    800055ca:	07e9                	addi	a5,a5,26
    800055cc:	078e                	slli	a5,a5,0x3
    800055ce:	953e                	add	a0,a0,a5
    800055d0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800055d4:	fe043503          	ld	a0,-32(s0)
    800055d8:	bceff0ef          	jal	ra,800049a6 <fileclose>
  return 0;
    800055dc:	4781                	li	a5,0
}
    800055de:	853e                	mv	a0,a5
    800055e0:	60e2                	ld	ra,24(sp)
    800055e2:	6442                	ld	s0,16(sp)
    800055e4:	6105                	addi	sp,sp,32
    800055e6:	8082                	ret

00000000800055e8 <sys_fstat>:
{
    800055e8:	1101                	addi	sp,sp,-32
    800055ea:	ec06                	sd	ra,24(sp)
    800055ec:	e822                	sd	s0,16(sp)
    800055ee:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055f0:	fe040593          	addi	a1,s0,-32
    800055f4:	4505                	li	a0,1
    800055f6:	ea4fd0ef          	jal	ra,80002c9a <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055fa:	fe840613          	addi	a2,s0,-24
    800055fe:	4581                	li	a1,0
    80005600:	4501                	li	a0,0
    80005602:	cfbff0ef          	jal	ra,800052fc <argfd>
    80005606:	87aa                	mv	a5,a0
    return -1;
    80005608:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000560a:	0007c863          	bltz	a5,8000561a <sys_fstat+0x32>
  return filestat(f, st);
    8000560e:	fe043583          	ld	a1,-32(s0)
    80005612:	fe843503          	ld	a0,-24(s0)
    80005616:	c38ff0ef          	jal	ra,80004a4e <filestat>
}
    8000561a:	60e2                	ld	ra,24(sp)
    8000561c:	6442                	ld	s0,16(sp)
    8000561e:	6105                	addi	sp,sp,32
    80005620:	8082                	ret

0000000080005622 <sys_link>:
{
    80005622:	7169                	addi	sp,sp,-304
    80005624:	f606                	sd	ra,296(sp)
    80005626:	f222                	sd	s0,288(sp)
    80005628:	ee26                	sd	s1,280(sp)
    8000562a:	ea4a                	sd	s2,272(sp)
    8000562c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000562e:	08000613          	li	a2,128
    80005632:	ed040593          	addi	a1,s0,-304
    80005636:	4501                	li	a0,0
    80005638:	e7efd0ef          	jal	ra,80002cb6 <argstr>
    return -1;
    8000563c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000563e:	0c054663          	bltz	a0,8000570a <sys_link+0xe8>
    80005642:	08000613          	li	a2,128
    80005646:	f5040593          	addi	a1,s0,-176
    8000564a:	4505                	li	a0,1
    8000564c:	e6afd0ef          	jal	ra,80002cb6 <argstr>
    return -1;
    80005650:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005652:	0a054c63          	bltz	a0,8000570a <sys_link+0xe8>
  begin_op();
    80005656:	f47fe0ef          	jal	ra,8000459c <begin_op>
  if((ip = namei(old)) == 0){
    8000565a:	ed040513          	addi	a0,s0,-304
    8000565e:	d4bfe0ef          	jal	ra,800043a8 <namei>
    80005662:	84aa                	mv	s1,a0
    80005664:	c525                	beqz	a0,800056cc <sys_link+0xaa>
  ilock(ip);
    80005666:	d4efe0ef          	jal	ra,80003bb4 <ilock>
  if(ip->type == T_DIR){
    8000566a:	04449703          	lh	a4,68(s1)
    8000566e:	4785                	li	a5,1
    80005670:	06f70263          	beq	a4,a5,800056d4 <sys_link+0xb2>
  ip->nlink++;
    80005674:	04a4d783          	lhu	a5,74(s1)
    80005678:	2785                	addiw	a5,a5,1
    8000567a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000567e:	8526                	mv	a0,s1
    80005680:	c80fe0ef          	jal	ra,80003b00 <iupdate>
  iunlock(ip);
    80005684:	8526                	mv	a0,s1
    80005686:	dd8fe0ef          	jal	ra,80003c5e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000568a:	fd040593          	addi	a1,s0,-48
    8000568e:	f5040513          	addi	a0,s0,-176
    80005692:	d31fe0ef          	jal	ra,800043c2 <nameiparent>
    80005696:	892a                	mv	s2,a0
    80005698:	c921                	beqz	a0,800056e8 <sys_link+0xc6>
  ilock(dp);
    8000569a:	d1afe0ef          	jal	ra,80003bb4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000569e:	00092703          	lw	a4,0(s2)
    800056a2:	409c                	lw	a5,0(s1)
    800056a4:	02f71f63          	bne	a4,a5,800056e2 <sys_link+0xc0>
    800056a8:	40d0                	lw	a2,4(s1)
    800056aa:	fd040593          	addi	a1,s0,-48
    800056ae:	854a                	mv	a0,s2
    800056b0:	c5ffe0ef          	jal	ra,8000430e <dirlink>
    800056b4:	02054763          	bltz	a0,800056e2 <sys_link+0xc0>
  iunlockput(dp);
    800056b8:	854a                	mv	a0,s2
    800056ba:	f00fe0ef          	jal	ra,80003dba <iunlockput>
  iput(ip);
    800056be:	8526                	mv	a0,s1
    800056c0:	e72fe0ef          	jal	ra,80003d32 <iput>
  end_op();
    800056c4:	f47fe0ef          	jal	ra,8000460a <end_op>
  return 0;
    800056c8:	4781                	li	a5,0
    800056ca:	a081                	j	8000570a <sys_link+0xe8>
    end_op();
    800056cc:	f3ffe0ef          	jal	ra,8000460a <end_op>
    return -1;
    800056d0:	57fd                	li	a5,-1
    800056d2:	a825                	j	8000570a <sys_link+0xe8>
    iunlockput(ip);
    800056d4:	8526                	mv	a0,s1
    800056d6:	ee4fe0ef          	jal	ra,80003dba <iunlockput>
    end_op();
    800056da:	f31fe0ef          	jal	ra,8000460a <end_op>
    return -1;
    800056de:	57fd                	li	a5,-1
    800056e0:	a02d                	j	8000570a <sys_link+0xe8>
    iunlockput(dp);
    800056e2:	854a                	mv	a0,s2
    800056e4:	ed6fe0ef          	jal	ra,80003dba <iunlockput>
  ilock(ip);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ccafe0ef          	jal	ra,80003bb4 <ilock>
  ip->nlink--;
    800056ee:	04a4d783          	lhu	a5,74(s1)
    800056f2:	37fd                	addiw	a5,a5,-1
    800056f4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056f8:	8526                	mv	a0,s1
    800056fa:	c06fe0ef          	jal	ra,80003b00 <iupdate>
  iunlockput(ip);
    800056fe:	8526                	mv	a0,s1
    80005700:	ebafe0ef          	jal	ra,80003dba <iunlockput>
  end_op();
    80005704:	f07fe0ef          	jal	ra,8000460a <end_op>
  return -1;
    80005708:	57fd                	li	a5,-1
}
    8000570a:	853e                	mv	a0,a5
    8000570c:	70b2                	ld	ra,296(sp)
    8000570e:	7412                	ld	s0,288(sp)
    80005710:	64f2                	ld	s1,280(sp)
    80005712:	6952                	ld	s2,272(sp)
    80005714:	6155                	addi	sp,sp,304
    80005716:	8082                	ret

0000000080005718 <sys_unlink>:
{
    80005718:	7151                	addi	sp,sp,-240
    8000571a:	f586                	sd	ra,232(sp)
    8000571c:	f1a2                	sd	s0,224(sp)
    8000571e:	eda6                	sd	s1,216(sp)
    80005720:	e9ca                	sd	s2,208(sp)
    80005722:	e5ce                	sd	s3,200(sp)
    80005724:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005726:	08000613          	li	a2,128
    8000572a:	f3040593          	addi	a1,s0,-208
    8000572e:	4501                	li	a0,0
    80005730:	d86fd0ef          	jal	ra,80002cb6 <argstr>
    80005734:	12054b63          	bltz	a0,8000586a <sys_unlink+0x152>
  begin_op();
    80005738:	e65fe0ef          	jal	ra,8000459c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000573c:	fb040593          	addi	a1,s0,-80
    80005740:	f3040513          	addi	a0,s0,-208
    80005744:	c7ffe0ef          	jal	ra,800043c2 <nameiparent>
    80005748:	84aa                	mv	s1,a0
    8000574a:	c54d                	beqz	a0,800057f4 <sys_unlink+0xdc>
  ilock(dp);
    8000574c:	c68fe0ef          	jal	ra,80003bb4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005750:	00003597          	auipc	a1,0x3
    80005754:	f9858593          	addi	a1,a1,-104 # 800086e8 <syscalls+0x2f0>
    80005758:	fb040513          	addi	a0,s0,-80
    8000575c:	9cbfe0ef          	jal	ra,80004126 <namecmp>
    80005760:	10050a63          	beqz	a0,80005874 <sys_unlink+0x15c>
    80005764:	00003597          	auipc	a1,0x3
    80005768:	f8c58593          	addi	a1,a1,-116 # 800086f0 <syscalls+0x2f8>
    8000576c:	fb040513          	addi	a0,s0,-80
    80005770:	9b7fe0ef          	jal	ra,80004126 <namecmp>
    80005774:	10050063          	beqz	a0,80005874 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005778:	f2c40613          	addi	a2,s0,-212
    8000577c:	fb040593          	addi	a1,s0,-80
    80005780:	8526                	mv	a0,s1
    80005782:	9bbfe0ef          	jal	ra,8000413c <dirlookup>
    80005786:	892a                	mv	s2,a0
    80005788:	0e050663          	beqz	a0,80005874 <sys_unlink+0x15c>
  ilock(ip);
    8000578c:	c28fe0ef          	jal	ra,80003bb4 <ilock>
  if(ip->nlink < 1)
    80005790:	04a91783          	lh	a5,74(s2)
    80005794:	06f05463          	blez	a5,800057fc <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005798:	04491703          	lh	a4,68(s2)
    8000579c:	4785                	li	a5,1
    8000579e:	06f70563          	beq	a4,a5,80005808 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800057a2:	4641                	li	a2,16
    800057a4:	4581                	li	a1,0
    800057a6:	fc040513          	addi	a0,s0,-64
    800057aa:	dcafb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057ae:	4741                	li	a4,16
    800057b0:	f2c42683          	lw	a3,-212(s0)
    800057b4:	fc040613          	addi	a2,s0,-64
    800057b8:	4581                	li	a1,0
    800057ba:	8526                	mv	a0,s1
    800057bc:	869fe0ef          	jal	ra,80004024 <writei>
    800057c0:	47c1                	li	a5,16
    800057c2:	08f51563          	bne	a0,a5,8000584c <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800057c6:	04491703          	lh	a4,68(s2)
    800057ca:	4785                	li	a5,1
    800057cc:	08f70663          	beq	a4,a5,80005858 <sys_unlink+0x140>
  iunlockput(dp);
    800057d0:	8526                	mv	a0,s1
    800057d2:	de8fe0ef          	jal	ra,80003dba <iunlockput>
  ip->nlink--;
    800057d6:	04a95783          	lhu	a5,74(s2)
    800057da:	37fd                	addiw	a5,a5,-1
    800057dc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057e0:	854a                	mv	a0,s2
    800057e2:	b1efe0ef          	jal	ra,80003b00 <iupdate>
  iunlockput(ip);
    800057e6:	854a                	mv	a0,s2
    800057e8:	dd2fe0ef          	jal	ra,80003dba <iunlockput>
  end_op();
    800057ec:	e1ffe0ef          	jal	ra,8000460a <end_op>
  return 0;
    800057f0:	4501                	li	a0,0
    800057f2:	a079                	j	80005880 <sys_unlink+0x168>
    end_op();
    800057f4:	e17fe0ef          	jal	ra,8000460a <end_op>
    return -1;
    800057f8:	557d                	li	a0,-1
    800057fa:	a059                	j	80005880 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800057fc:	00003517          	auipc	a0,0x3
    80005800:	efc50513          	addi	a0,a0,-260 # 800086f8 <syscalls+0x300>
    80005804:	f85fa0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005808:	04c92703          	lw	a4,76(s2)
    8000580c:	02000793          	li	a5,32
    80005810:	f8e7f9e3          	bgeu	a5,a4,800057a2 <sys_unlink+0x8a>
    80005814:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005818:	4741                	li	a4,16
    8000581a:	86ce                	mv	a3,s3
    8000581c:	f1840613          	addi	a2,s0,-232
    80005820:	4581                	li	a1,0
    80005822:	854a                	mv	a0,s2
    80005824:	f1cfe0ef          	jal	ra,80003f40 <readi>
    80005828:	47c1                	li	a5,16
    8000582a:	00f51b63          	bne	a0,a5,80005840 <sys_unlink+0x128>
    if(de.inum != 0)
    8000582e:	f1845783          	lhu	a5,-232(s0)
    80005832:	ef95                	bnez	a5,8000586e <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005834:	29c1                	addiw	s3,s3,16
    80005836:	04c92783          	lw	a5,76(s2)
    8000583a:	fcf9efe3          	bltu	s3,a5,80005818 <sys_unlink+0x100>
    8000583e:	b795                	j	800057a2 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005840:	00003517          	auipc	a0,0x3
    80005844:	ed050513          	addi	a0,a0,-304 # 80008710 <syscalls+0x318>
    80005848:	f41fa0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    8000584c:	00003517          	auipc	a0,0x3
    80005850:	edc50513          	addi	a0,a0,-292 # 80008728 <syscalls+0x330>
    80005854:	f35fa0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005858:	04a4d783          	lhu	a5,74(s1)
    8000585c:	37fd                	addiw	a5,a5,-1
    8000585e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005862:	8526                	mv	a0,s1
    80005864:	a9cfe0ef          	jal	ra,80003b00 <iupdate>
    80005868:	b7a5                	j	800057d0 <sys_unlink+0xb8>
    return -1;
    8000586a:	557d                	li	a0,-1
    8000586c:	a811                	j	80005880 <sys_unlink+0x168>
    iunlockput(ip);
    8000586e:	854a                	mv	a0,s2
    80005870:	d4afe0ef          	jal	ra,80003dba <iunlockput>
  iunlockput(dp);
    80005874:	8526                	mv	a0,s1
    80005876:	d44fe0ef          	jal	ra,80003dba <iunlockput>
  end_op();
    8000587a:	d91fe0ef          	jal	ra,8000460a <end_op>
  return -1;
    8000587e:	557d                	li	a0,-1
}
    80005880:	70ae                	ld	ra,232(sp)
    80005882:	740e                	ld	s0,224(sp)
    80005884:	64ee                	ld	s1,216(sp)
    80005886:	694e                	ld	s2,208(sp)
    80005888:	69ae                	ld	s3,200(sp)
    8000588a:	616d                	addi	sp,sp,240
    8000588c:	8082                	ret

000000008000588e <sys_open>:

uint64
sys_open(void)
{
    8000588e:	7131                	addi	sp,sp,-192
    80005890:	fd06                	sd	ra,184(sp)
    80005892:	f922                	sd	s0,176(sp)
    80005894:	f526                	sd	s1,168(sp)
    80005896:	f14a                	sd	s2,160(sp)
    80005898:	ed4e                	sd	s3,152(sp)
    8000589a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000589c:	f4c40593          	addi	a1,s0,-180
    800058a0:	4505                	li	a0,1
    800058a2:	bdcfd0ef          	jal	ra,80002c7e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058a6:	08000613          	li	a2,128
    800058aa:	f5040593          	addi	a1,s0,-176
    800058ae:	4501                	li	a0,0
    800058b0:	c06fd0ef          	jal	ra,80002cb6 <argstr>
    800058b4:	87aa                	mv	a5,a0
    return -1;
    800058b6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058b8:	0807cd63          	bltz	a5,80005952 <sys_open+0xc4>

  begin_op();
    800058bc:	ce1fe0ef          	jal	ra,8000459c <begin_op>

  if(omode & O_CREATE){
    800058c0:	f4c42783          	lw	a5,-180(s0)
    800058c4:	2007f793          	andi	a5,a5,512
    800058c8:	c3c5                	beqz	a5,80005968 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800058ca:	4681                	li	a3,0
    800058cc:	4601                	li	a2,0
    800058ce:	4589                	li	a1,2
    800058d0:	f5040513          	addi	a0,s0,-176
    800058d4:	abfff0ef          	jal	ra,80005392 <create>
    800058d8:	84aa                	mv	s1,a0
    if(ip == 0){
    800058da:	c159                	beqz	a0,80005960 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058dc:	04449703          	lh	a4,68(s1)
    800058e0:	478d                	li	a5,3
    800058e2:	00f71763          	bne	a4,a5,800058f0 <sys_open+0x62>
    800058e6:	0464d703          	lhu	a4,70(s1)
    800058ea:	47a5                	li	a5,9
    800058ec:	0ae7e963          	bltu	a5,a4,8000599e <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058f0:	812ff0ef          	jal	ra,80004902 <filealloc>
    800058f4:	89aa                	mv	s3,a0
    800058f6:	0c050963          	beqz	a0,800059c8 <sys_open+0x13a>
    800058fa:	a5bff0ef          	jal	ra,80005354 <fdalloc>
    800058fe:	892a                	mv	s2,a0
    80005900:	0c054163          	bltz	a0,800059c2 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005904:	04449703          	lh	a4,68(s1)
    80005908:	478d                	li	a5,3
    8000590a:	0af70163          	beq	a4,a5,800059ac <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000590e:	4789                	li	a5,2
    80005910:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005914:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005918:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000591c:	f4c42783          	lw	a5,-180(s0)
    80005920:	0017c713          	xori	a4,a5,1
    80005924:	8b05                	andi	a4,a4,1
    80005926:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000592a:	0037f713          	andi	a4,a5,3
    8000592e:	00e03733          	snez	a4,a4
    80005932:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005936:	4007f793          	andi	a5,a5,1024
    8000593a:	c791                	beqz	a5,80005946 <sys_open+0xb8>
    8000593c:	04449703          	lh	a4,68(s1)
    80005940:	4789                	li	a5,2
    80005942:	06f70c63          	beq	a4,a5,800059ba <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005946:	8526                	mv	a0,s1
    80005948:	b16fe0ef          	jal	ra,80003c5e <iunlock>
  end_op();
    8000594c:	cbffe0ef          	jal	ra,8000460a <end_op>

  return fd;
    80005950:	854a                	mv	a0,s2
}
    80005952:	70ea                	ld	ra,184(sp)
    80005954:	744a                	ld	s0,176(sp)
    80005956:	74aa                	ld	s1,168(sp)
    80005958:	790a                	ld	s2,160(sp)
    8000595a:	69ea                	ld	s3,152(sp)
    8000595c:	6129                	addi	sp,sp,192
    8000595e:	8082                	ret
      end_op();
    80005960:	cabfe0ef          	jal	ra,8000460a <end_op>
      return -1;
    80005964:	557d                	li	a0,-1
    80005966:	b7f5                	j	80005952 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005968:	f5040513          	addi	a0,s0,-176
    8000596c:	a3dfe0ef          	jal	ra,800043a8 <namei>
    80005970:	84aa                	mv	s1,a0
    80005972:	c115                	beqz	a0,80005996 <sys_open+0x108>
    ilock(ip);
    80005974:	a40fe0ef          	jal	ra,80003bb4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005978:	04449703          	lh	a4,68(s1)
    8000597c:	4785                	li	a5,1
    8000597e:	f4f71fe3          	bne	a4,a5,800058dc <sys_open+0x4e>
    80005982:	f4c42783          	lw	a5,-180(s0)
    80005986:	d7ad                	beqz	a5,800058f0 <sys_open+0x62>
      iunlockput(ip);
    80005988:	8526                	mv	a0,s1
    8000598a:	c30fe0ef          	jal	ra,80003dba <iunlockput>
      end_op();
    8000598e:	c7dfe0ef          	jal	ra,8000460a <end_op>
      return -1;
    80005992:	557d                	li	a0,-1
    80005994:	bf7d                	j	80005952 <sys_open+0xc4>
      end_op();
    80005996:	c75fe0ef          	jal	ra,8000460a <end_op>
      return -1;
    8000599a:	557d                	li	a0,-1
    8000599c:	bf5d                	j	80005952 <sys_open+0xc4>
    iunlockput(ip);
    8000599e:	8526                	mv	a0,s1
    800059a0:	c1afe0ef          	jal	ra,80003dba <iunlockput>
    end_op();
    800059a4:	c67fe0ef          	jal	ra,8000460a <end_op>
    return -1;
    800059a8:	557d                	li	a0,-1
    800059aa:	b765                	j	80005952 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800059ac:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059b0:	04649783          	lh	a5,70(s1)
    800059b4:	02f99223          	sh	a5,36(s3)
    800059b8:	b785                	j	80005918 <sys_open+0x8a>
    itrunc(ip);
    800059ba:	8526                	mv	a0,s1
    800059bc:	ae2fe0ef          	jal	ra,80003c9e <itrunc>
    800059c0:	b759                	j	80005946 <sys_open+0xb8>
      fileclose(f);
    800059c2:	854e                	mv	a0,s3
    800059c4:	fe3fe0ef          	jal	ra,800049a6 <fileclose>
    iunlockput(ip);
    800059c8:	8526                	mv	a0,s1
    800059ca:	bf0fe0ef          	jal	ra,80003dba <iunlockput>
    end_op();
    800059ce:	c3dfe0ef          	jal	ra,8000460a <end_op>
    return -1;
    800059d2:	557d                	li	a0,-1
    800059d4:	bfbd                	j	80005952 <sys_open+0xc4>

00000000800059d6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059d6:	7175                	addi	sp,sp,-144
    800059d8:	e506                	sd	ra,136(sp)
    800059da:	e122                	sd	s0,128(sp)
    800059dc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059de:	bbffe0ef          	jal	ra,8000459c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059e2:	08000613          	li	a2,128
    800059e6:	f7040593          	addi	a1,s0,-144
    800059ea:	4501                	li	a0,0
    800059ec:	acafd0ef          	jal	ra,80002cb6 <argstr>
    800059f0:	02054363          	bltz	a0,80005a16 <sys_mkdir+0x40>
    800059f4:	4681                	li	a3,0
    800059f6:	4601                	li	a2,0
    800059f8:	4585                	li	a1,1
    800059fa:	f7040513          	addi	a0,s0,-144
    800059fe:	995ff0ef          	jal	ra,80005392 <create>
    80005a02:	c911                	beqz	a0,80005a16 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a04:	bb6fe0ef          	jal	ra,80003dba <iunlockput>
  end_op();
    80005a08:	c03fe0ef          	jal	ra,8000460a <end_op>
  return 0;
    80005a0c:	4501                	li	a0,0
}
    80005a0e:	60aa                	ld	ra,136(sp)
    80005a10:	640a                	ld	s0,128(sp)
    80005a12:	6149                	addi	sp,sp,144
    80005a14:	8082                	ret
    end_op();
    80005a16:	bf5fe0ef          	jal	ra,8000460a <end_op>
    return -1;
    80005a1a:	557d                	li	a0,-1
    80005a1c:	bfcd                	j	80005a0e <sys_mkdir+0x38>

0000000080005a1e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a1e:	7135                	addi	sp,sp,-160
    80005a20:	ed06                	sd	ra,152(sp)
    80005a22:	e922                	sd	s0,144(sp)
    80005a24:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a26:	b77fe0ef          	jal	ra,8000459c <begin_op>
  argint(1, &major);
    80005a2a:	f6c40593          	addi	a1,s0,-148
    80005a2e:	4505                	li	a0,1
    80005a30:	a4efd0ef          	jal	ra,80002c7e <argint>
  argint(2, &minor);
    80005a34:	f6840593          	addi	a1,s0,-152
    80005a38:	4509                	li	a0,2
    80005a3a:	a44fd0ef          	jal	ra,80002c7e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a3e:	08000613          	li	a2,128
    80005a42:	f7040593          	addi	a1,s0,-144
    80005a46:	4501                	li	a0,0
    80005a48:	a6efd0ef          	jal	ra,80002cb6 <argstr>
    80005a4c:	02054563          	bltz	a0,80005a76 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a50:	f6841683          	lh	a3,-152(s0)
    80005a54:	f6c41603          	lh	a2,-148(s0)
    80005a58:	458d                	li	a1,3
    80005a5a:	f7040513          	addi	a0,s0,-144
    80005a5e:	935ff0ef          	jal	ra,80005392 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a62:	c911                	beqz	a0,80005a76 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a64:	b56fe0ef          	jal	ra,80003dba <iunlockput>
  end_op();
    80005a68:	ba3fe0ef          	jal	ra,8000460a <end_op>
  return 0;
    80005a6c:	4501                	li	a0,0
}
    80005a6e:	60ea                	ld	ra,152(sp)
    80005a70:	644a                	ld	s0,144(sp)
    80005a72:	610d                	addi	sp,sp,160
    80005a74:	8082                	ret
    end_op();
    80005a76:	b95fe0ef          	jal	ra,8000460a <end_op>
    return -1;
    80005a7a:	557d                	li	a0,-1
    80005a7c:	bfcd                	j	80005a6e <sys_mknod+0x50>

0000000080005a7e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a7e:	7135                	addi	sp,sp,-160
    80005a80:	ed06                	sd	ra,152(sp)
    80005a82:	e922                	sd	s0,144(sp)
    80005a84:	e526                	sd	s1,136(sp)
    80005a86:	e14a                	sd	s2,128(sp)
    80005a88:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a8a:	8befc0ef          	jal	ra,80001b48 <myproc>
    80005a8e:	892a                	mv	s2,a0
  
  begin_op();
    80005a90:	b0dfe0ef          	jal	ra,8000459c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a94:	08000613          	li	a2,128
    80005a98:	f6040593          	addi	a1,s0,-160
    80005a9c:	4501                	li	a0,0
    80005a9e:	a18fd0ef          	jal	ra,80002cb6 <argstr>
    80005aa2:	04054163          	bltz	a0,80005ae4 <sys_chdir+0x66>
    80005aa6:	f6040513          	addi	a0,s0,-160
    80005aaa:	8fffe0ef          	jal	ra,800043a8 <namei>
    80005aae:	84aa                	mv	s1,a0
    80005ab0:	c915                	beqz	a0,80005ae4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ab2:	902fe0ef          	jal	ra,80003bb4 <ilock>
  if(ip->type != T_DIR){
    80005ab6:	04449703          	lh	a4,68(s1)
    80005aba:	4785                	li	a5,1
    80005abc:	02f71863          	bne	a4,a5,80005aec <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ac0:	8526                	mv	a0,s1
    80005ac2:	99cfe0ef          	jal	ra,80003c5e <iunlock>
  iput(p->cwd);
    80005ac6:	15093503          	ld	a0,336(s2)
    80005aca:	a68fe0ef          	jal	ra,80003d32 <iput>
  end_op();
    80005ace:	b3dfe0ef          	jal	ra,8000460a <end_op>
  p->cwd = ip;
    80005ad2:	14993823          	sd	s1,336(s2)
  return 0;
    80005ad6:	4501                	li	a0,0
}
    80005ad8:	60ea                	ld	ra,152(sp)
    80005ada:	644a                	ld	s0,144(sp)
    80005adc:	64aa                	ld	s1,136(sp)
    80005ade:	690a                	ld	s2,128(sp)
    80005ae0:	610d                	addi	sp,sp,160
    80005ae2:	8082                	ret
    end_op();
    80005ae4:	b27fe0ef          	jal	ra,8000460a <end_op>
    return -1;
    80005ae8:	557d                	li	a0,-1
    80005aea:	b7fd                	j	80005ad8 <sys_chdir+0x5a>
    iunlockput(ip);
    80005aec:	8526                	mv	a0,s1
    80005aee:	accfe0ef          	jal	ra,80003dba <iunlockput>
    end_op();
    80005af2:	b19fe0ef          	jal	ra,8000460a <end_op>
    return -1;
    80005af6:	557d                	li	a0,-1
    80005af8:	b7c5                	j	80005ad8 <sys_chdir+0x5a>

0000000080005afa <sys_exec>:

uint64
sys_exec(void)
{
    80005afa:	7145                	addi	sp,sp,-464
    80005afc:	e786                	sd	ra,456(sp)
    80005afe:	e3a2                	sd	s0,448(sp)
    80005b00:	ff26                	sd	s1,440(sp)
    80005b02:	fb4a                	sd	s2,432(sp)
    80005b04:	f74e                	sd	s3,424(sp)
    80005b06:	f352                	sd	s4,416(sp)
    80005b08:	ef56                	sd	s5,408(sp)
    80005b0a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b0c:	e3840593          	addi	a1,s0,-456
    80005b10:	4505                	li	a0,1
    80005b12:	988fd0ef          	jal	ra,80002c9a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b16:	08000613          	li	a2,128
    80005b1a:	f4040593          	addi	a1,s0,-192
    80005b1e:	4501                	li	a0,0
    80005b20:	996fd0ef          	jal	ra,80002cb6 <argstr>
    80005b24:	87aa                	mv	a5,a0
    return -1;
    80005b26:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b28:	0a07c563          	bltz	a5,80005bd2 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005b2c:	10000613          	li	a2,256
    80005b30:	4581                	li	a1,0
    80005b32:	e4040513          	addi	a0,s0,-448
    80005b36:	a3efb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b3a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b3e:	89a6                	mv	s3,s1
    80005b40:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b42:	02000a13          	li	s4,32
    80005b46:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b4a:	00391513          	slli	a0,s2,0x3
    80005b4e:	e3040593          	addi	a1,s0,-464
    80005b52:	e3843783          	ld	a5,-456(s0)
    80005b56:	953e                	add	a0,a0,a5
    80005b58:	89cfd0ef          	jal	ra,80002bf4 <fetchaddr>
    80005b5c:	02054663          	bltz	a0,80005b88 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005b60:	e3043783          	ld	a5,-464(s0)
    80005b64:	cf8d                	beqz	a5,80005b9e <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b66:	844fb0ef          	jal	ra,80000baa <kalloc>
    80005b6a:	85aa                	mv	a1,a0
    80005b6c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b70:	cd01                	beqz	a0,80005b88 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b72:	6605                	lui	a2,0x1
    80005b74:	e3043503          	ld	a0,-464(s0)
    80005b78:	8c6fd0ef          	jal	ra,80002c3e <fetchstr>
    80005b7c:	00054663          	bltz	a0,80005b88 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005b80:	0905                	addi	s2,s2,1
    80005b82:	09a1                	addi	s3,s3,8
    80005b84:	fd4911e3          	bne	s2,s4,80005b46 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b88:	f4040913          	addi	s2,s0,-192
    80005b8c:	6088                	ld	a0,0(s1)
    80005b8e:	c129                	beqz	a0,80005bd0 <sys_exec+0xd6>
    kfree(argv[i]);
    80005b90:	eebfa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b94:	04a1                	addi	s1,s1,8
    80005b96:	ff249be3          	bne	s1,s2,80005b8c <sys_exec+0x92>
  return -1;
    80005b9a:	557d                	li	a0,-1
    80005b9c:	a81d                	j	80005bd2 <sys_exec+0xd8>
      argv[i] = 0;
    80005b9e:	0a8e                	slli	s5,s5,0x3
    80005ba0:	fc0a8793          	addi	a5,s5,-64
    80005ba4:	00878ab3          	add	s5,a5,s0
    80005ba8:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005bac:	e4040593          	addi	a1,s0,-448
    80005bb0:	f4040513          	addi	a0,s0,-192
    80005bb4:	b9eff0ef          	jal	ra,80004f52 <kexec>
    80005bb8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bba:	f4040993          	addi	s3,s0,-192
    80005bbe:	6088                	ld	a0,0(s1)
    80005bc0:	c511                	beqz	a0,80005bcc <sys_exec+0xd2>
    kfree(argv[i]);
    80005bc2:	eb9fa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bc6:	04a1                	addi	s1,s1,8
    80005bc8:	ff349be3          	bne	s1,s3,80005bbe <sys_exec+0xc4>
  return ret;
    80005bcc:	854a                	mv	a0,s2
    80005bce:	a011                	j	80005bd2 <sys_exec+0xd8>
  return -1;
    80005bd0:	557d                	li	a0,-1
}
    80005bd2:	60be                	ld	ra,456(sp)
    80005bd4:	641e                	ld	s0,448(sp)
    80005bd6:	74fa                	ld	s1,440(sp)
    80005bd8:	795a                	ld	s2,432(sp)
    80005bda:	79ba                	ld	s3,424(sp)
    80005bdc:	7a1a                	ld	s4,416(sp)
    80005bde:	6afa                	ld	s5,408(sp)
    80005be0:	6179                	addi	sp,sp,464
    80005be2:	8082                	ret

0000000080005be4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005be4:	7139                	addi	sp,sp,-64
    80005be6:	fc06                	sd	ra,56(sp)
    80005be8:	f822                	sd	s0,48(sp)
    80005bea:	f426                	sd	s1,40(sp)
    80005bec:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bee:	f5bfb0ef          	jal	ra,80001b48 <myproc>
    80005bf2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005bf4:	fd840593          	addi	a1,s0,-40
    80005bf8:	4501                	li	a0,0
    80005bfa:	8a0fd0ef          	jal	ra,80002c9a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005bfe:	fc840593          	addi	a1,s0,-56
    80005c02:	fd040513          	addi	a0,s0,-48
    80005c06:	86cff0ef          	jal	ra,80004c72 <pipealloc>
    return -1;
    80005c0a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c0c:	0a054463          	bltz	a0,80005cb4 <sys_pipe+0xd0>
  fd0 = -1;
    80005c10:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c14:	fd043503          	ld	a0,-48(s0)
    80005c18:	f3cff0ef          	jal	ra,80005354 <fdalloc>
    80005c1c:	fca42223          	sw	a0,-60(s0)
    80005c20:	08054163          	bltz	a0,80005ca2 <sys_pipe+0xbe>
    80005c24:	fc843503          	ld	a0,-56(s0)
    80005c28:	f2cff0ef          	jal	ra,80005354 <fdalloc>
    80005c2c:	fca42023          	sw	a0,-64(s0)
    80005c30:	06054063          	bltz	a0,80005c90 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c34:	4691                	li	a3,4
    80005c36:	fc440613          	addi	a2,s0,-60
    80005c3a:	fd843583          	ld	a1,-40(s0)
    80005c3e:	68a8                	ld	a0,80(s1)
    80005c40:	b2bfb0ef          	jal	ra,8000176a <copyout>
    80005c44:	00054e63          	bltz	a0,80005c60 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c48:	4691                	li	a3,4
    80005c4a:	fc040613          	addi	a2,s0,-64
    80005c4e:	fd843583          	ld	a1,-40(s0)
    80005c52:	0591                	addi	a1,a1,4
    80005c54:	68a8                	ld	a0,80(s1)
    80005c56:	b15fb0ef          	jal	ra,8000176a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c5a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c5c:	04055c63          	bgez	a0,80005cb4 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005c60:	fc442783          	lw	a5,-60(s0)
    80005c64:	07e9                	addi	a5,a5,26
    80005c66:	078e                	slli	a5,a5,0x3
    80005c68:	97a6                	add	a5,a5,s1
    80005c6a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c6e:	fc042783          	lw	a5,-64(s0)
    80005c72:	07e9                	addi	a5,a5,26
    80005c74:	078e                	slli	a5,a5,0x3
    80005c76:	94be                	add	s1,s1,a5
    80005c78:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c7c:	fd043503          	ld	a0,-48(s0)
    80005c80:	d27fe0ef          	jal	ra,800049a6 <fileclose>
    fileclose(wf);
    80005c84:	fc843503          	ld	a0,-56(s0)
    80005c88:	d1ffe0ef          	jal	ra,800049a6 <fileclose>
    return -1;
    80005c8c:	57fd                	li	a5,-1
    80005c8e:	a01d                	j	80005cb4 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005c90:	fc442783          	lw	a5,-60(s0)
    80005c94:	0007c763          	bltz	a5,80005ca2 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005c98:	07e9                	addi	a5,a5,26
    80005c9a:	078e                	slli	a5,a5,0x3
    80005c9c:	97a6                	add	a5,a5,s1
    80005c9e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ca2:	fd043503          	ld	a0,-48(s0)
    80005ca6:	d01fe0ef          	jal	ra,800049a6 <fileclose>
    fileclose(wf);
    80005caa:	fc843503          	ld	a0,-56(s0)
    80005cae:	cf9fe0ef          	jal	ra,800049a6 <fileclose>
    return -1;
    80005cb2:	57fd                	li	a5,-1
}
    80005cb4:	853e                	mv	a0,a5
    80005cb6:	70e2                	ld	ra,56(sp)
    80005cb8:	7442                	ld	s0,48(sp)
    80005cba:	74a2                	ld	s1,40(sp)
    80005cbc:	6121                	addi	sp,sp,64
    80005cbe:	8082                	ret

0000000080005cc0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005cc0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005cc2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005cc4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005cc6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005cc8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005cca:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005ccc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005cce:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005cd0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005cd2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005cd4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005cd6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005cd8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005cda:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005cdc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005cde:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005ce0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005ce2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005ce4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005ce6:	e1ffc0ef          	jal	ra,80002b04 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005cea:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005cec:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005cee:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005cf0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005cf2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005cf4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005cf6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005cf8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005cfa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005cfc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005cfe:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005d00:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005d02:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005d04:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005d06:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005d08:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005d0a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005d0c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005d0e:	10200073          	sret
	...

0000000080005d1e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d1e:	1141                	addi	sp,sp,-16
    80005d20:	e422                	sd	s0,8(sp)
    80005d22:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d24:	0c0007b7          	lui	a5,0xc000
    80005d28:	4705                	li	a4,1
    80005d2a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d2c:	c3d8                	sw	a4,4(a5)
}
    80005d2e:	6422                	ld	s0,8(sp)
    80005d30:	0141                	addi	sp,sp,16
    80005d32:	8082                	ret

0000000080005d34 <plicinithart>:

void
plicinithart(void)
{
    80005d34:	1141                	addi	sp,sp,-16
    80005d36:	e406                	sd	ra,8(sp)
    80005d38:	e022                	sd	s0,0(sp)
    80005d3a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d3c:	de1fb0ef          	jal	ra,80001b1c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d40:	0085171b          	slliw	a4,a0,0x8
    80005d44:	0c0027b7          	lui	a5,0xc002
    80005d48:	97ba                	add	a5,a5,a4
    80005d4a:	40200713          	li	a4,1026
    80005d4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d52:	00d5151b          	slliw	a0,a0,0xd
    80005d56:	0c2017b7          	lui	a5,0xc201
    80005d5a:	97aa                	add	a5,a5,a0
    80005d5c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d60:	60a2                	ld	ra,8(sp)
    80005d62:	6402                	ld	s0,0(sp)
    80005d64:	0141                	addi	sp,sp,16
    80005d66:	8082                	ret

0000000080005d68 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d68:	1141                	addi	sp,sp,-16
    80005d6a:	e406                	sd	ra,8(sp)
    80005d6c:	e022                	sd	s0,0(sp)
    80005d6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d70:	dadfb0ef          	jal	ra,80001b1c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d74:	00d5151b          	slliw	a0,a0,0xd
    80005d78:	0c2017b7          	lui	a5,0xc201
    80005d7c:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d7e:	43c8                	lw	a0,4(a5)
    80005d80:	60a2                	ld	ra,8(sp)
    80005d82:	6402                	ld	s0,0(sp)
    80005d84:	0141                	addi	sp,sp,16
    80005d86:	8082                	ret

0000000080005d88 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d88:	1101                	addi	sp,sp,-32
    80005d8a:	ec06                	sd	ra,24(sp)
    80005d8c:	e822                	sd	s0,16(sp)
    80005d8e:	e426                	sd	s1,8(sp)
    80005d90:	1000                	addi	s0,sp,32
    80005d92:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d94:	d89fb0ef          	jal	ra,80001b1c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d98:	00d5151b          	slliw	a0,a0,0xd
    80005d9c:	0c2017b7          	lui	a5,0xc201
    80005da0:	97aa                	add	a5,a5,a0
    80005da2:	c3c4                	sw	s1,4(a5)
}
    80005da4:	60e2                	ld	ra,24(sp)
    80005da6:	6442                	ld	s0,16(sp)
    80005da8:	64a2                	ld	s1,8(sp)
    80005daa:	6105                	addi	sp,sp,32
    80005dac:	8082                	ret

0000000080005dae <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005dae:	1141                	addi	sp,sp,-16
    80005db0:	e406                	sd	ra,8(sp)
    80005db2:	e022                	sd	s0,0(sp)
    80005db4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005db6:	479d                	li	a5,7
    80005db8:	04a7ca63          	blt	a5,a0,80005e0c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005dbc:	00246797          	auipc	a5,0x246
    80005dc0:	cd478793          	addi	a5,a5,-812 # 8024ba90 <disk>
    80005dc4:	97aa                	add	a5,a5,a0
    80005dc6:	0187c783          	lbu	a5,24(a5)
    80005dca:	e7b9                	bnez	a5,80005e18 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005dcc:	00451693          	slli	a3,a0,0x4
    80005dd0:	00246797          	auipc	a5,0x246
    80005dd4:	cc078793          	addi	a5,a5,-832 # 8024ba90 <disk>
    80005dd8:	6398                	ld	a4,0(a5)
    80005dda:	9736                	add	a4,a4,a3
    80005ddc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005de0:	6398                	ld	a4,0(a5)
    80005de2:	9736                	add	a4,a4,a3
    80005de4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005de8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005dec:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005df0:	97aa                	add	a5,a5,a0
    80005df2:	4705                	li	a4,1
    80005df4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005df8:	00246517          	auipc	a0,0x246
    80005dfc:	cb050513          	addi	a0,a0,-848 # 8024baa8 <disk+0x18>
    80005e00:	d92fc0ef          	jal	ra,80002392 <wakeup>
}
    80005e04:	60a2                	ld	ra,8(sp)
    80005e06:	6402                	ld	s0,0(sp)
    80005e08:	0141                	addi	sp,sp,16
    80005e0a:	8082                	ret
    panic("free_desc 1");
    80005e0c:	00003517          	auipc	a0,0x3
    80005e10:	92c50513          	addi	a0,a0,-1748 # 80008738 <syscalls+0x340>
    80005e14:	975fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005e18:	00003517          	auipc	a0,0x3
    80005e1c:	93050513          	addi	a0,a0,-1744 # 80008748 <syscalls+0x350>
    80005e20:	969fa0ef          	jal	ra,80000788 <panic>

0000000080005e24 <virtio_disk_init>:
{
    80005e24:	1101                	addi	sp,sp,-32
    80005e26:	ec06                	sd	ra,24(sp)
    80005e28:	e822                	sd	s0,16(sp)
    80005e2a:	e426                	sd	s1,8(sp)
    80005e2c:	e04a                	sd	s2,0(sp)
    80005e2e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e30:	00003597          	auipc	a1,0x3
    80005e34:	92858593          	addi	a1,a1,-1752 # 80008758 <syscalls+0x360>
    80005e38:	00246517          	auipc	a0,0x246
    80005e3c:	d8050513          	addi	a0,a0,-640 # 8024bbb8 <disk+0x128>
    80005e40:	de1fa0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e44:	100017b7          	lui	a5,0x10001
    80005e48:	4398                	lw	a4,0(a5)
    80005e4a:	2701                	sext.w	a4,a4
    80005e4c:	747277b7          	lui	a5,0x74727
    80005e50:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e54:	12f71f63          	bne	a4,a5,80005f92 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e58:	100017b7          	lui	a5,0x10001
    80005e5c:	43dc                	lw	a5,4(a5)
    80005e5e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e60:	4709                	li	a4,2
    80005e62:	12e79863          	bne	a5,a4,80005f92 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e66:	100017b7          	lui	a5,0x10001
    80005e6a:	479c                	lw	a5,8(a5)
    80005e6c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e6e:	12e79263          	bne	a5,a4,80005f92 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e72:	100017b7          	lui	a5,0x10001
    80005e76:	47d8                	lw	a4,12(a5)
    80005e78:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e7a:	554d47b7          	lui	a5,0x554d4
    80005e7e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e82:	10f71863          	bne	a4,a5,80005f92 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e86:	100017b7          	lui	a5,0x10001
    80005e8a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8e:	4705                	li	a4,1
    80005e90:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e92:	470d                	li	a4,3
    80005e94:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e96:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e98:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e9c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47daa9f7>
    80005ea0:	8f75                	and	a4,a4,a3
    80005ea2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ea4:	472d                	li	a4,11
    80005ea6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005ea8:	5bbc                	lw	a5,112(a5)
    80005eaa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005eae:	8ba1                	andi	a5,a5,8
    80005eb0:	0e078763          	beqz	a5,80005f9e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005eb4:	100017b7          	lui	a5,0x10001
    80005eb8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005ebc:	43fc                	lw	a5,68(a5)
    80005ebe:	2781                	sext.w	a5,a5
    80005ec0:	0e079563          	bnez	a5,80005faa <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ec4:	100017b7          	lui	a5,0x10001
    80005ec8:	5bdc                	lw	a5,52(a5)
    80005eca:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ecc:	0e078563          	beqz	a5,80005fb6 <virtio_disk_init+0x192>
  if(max < NUM)
    80005ed0:	471d                	li	a4,7
    80005ed2:	0ef77863          	bgeu	a4,a5,80005fc2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80005ed6:	cd5fa0ef          	jal	ra,80000baa <kalloc>
    80005eda:	00246497          	auipc	s1,0x246
    80005ede:	bb648493          	addi	s1,s1,-1098 # 8024ba90 <disk>
    80005ee2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ee4:	cc7fa0ef          	jal	ra,80000baa <kalloc>
    80005ee8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005eea:	cc1fa0ef          	jal	ra,80000baa <kalloc>
    80005eee:	87aa                	mv	a5,a0
    80005ef0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ef2:	6088                	ld	a0,0(s1)
    80005ef4:	cd69                	beqz	a0,80005fce <virtio_disk_init+0x1aa>
    80005ef6:	00246717          	auipc	a4,0x246
    80005efa:	ba273703          	ld	a4,-1118(a4) # 8024ba98 <disk+0x8>
    80005efe:	cb61                	beqz	a4,80005fce <virtio_disk_init+0x1aa>
    80005f00:	c7f9                	beqz	a5,80005fce <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80005f02:	6605                	lui	a2,0x1
    80005f04:	4581                	li	a1,0
    80005f06:	e6ffa0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f0a:	00246497          	auipc	s1,0x246
    80005f0e:	b8648493          	addi	s1,s1,-1146 # 8024ba90 <disk>
    80005f12:	6605                	lui	a2,0x1
    80005f14:	4581                	li	a1,0
    80005f16:	6488                	ld	a0,8(s1)
    80005f18:	e5dfa0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f1c:	6605                	lui	a2,0x1
    80005f1e:	4581                	li	a1,0
    80005f20:	6888                	ld	a0,16(s1)
    80005f22:	e53fa0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f26:	100017b7          	lui	a5,0x10001
    80005f2a:	4721                	li	a4,8
    80005f2c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f2e:	4098                	lw	a4,0(s1)
    80005f30:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f34:	40d8                	lw	a4,4(s1)
    80005f36:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f3a:	6498                	ld	a4,8(s1)
    80005f3c:	0007069b          	sext.w	a3,a4
    80005f40:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f44:	9701                	srai	a4,a4,0x20
    80005f46:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f4a:	6898                	ld	a4,16(s1)
    80005f4c:	0007069b          	sext.w	a3,a4
    80005f50:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f54:	9701                	srai	a4,a4,0x20
    80005f56:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f5a:	4705                	li	a4,1
    80005f5c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f5e:	00e48c23          	sb	a4,24(s1)
    80005f62:	00e48ca3          	sb	a4,25(s1)
    80005f66:	00e48d23          	sb	a4,26(s1)
    80005f6a:	00e48da3          	sb	a4,27(s1)
    80005f6e:	00e48e23          	sb	a4,28(s1)
    80005f72:	00e48ea3          	sb	a4,29(s1)
    80005f76:	00e48f23          	sb	a4,30(s1)
    80005f7a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f7e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f82:	0727a823          	sw	s2,112(a5)
}
    80005f86:	60e2                	ld	ra,24(sp)
    80005f88:	6442                	ld	s0,16(sp)
    80005f8a:	64a2                	ld	s1,8(sp)
    80005f8c:	6902                	ld	s2,0(sp)
    80005f8e:	6105                	addi	sp,sp,32
    80005f90:	8082                	ret
    panic("could not find virtio disk");
    80005f92:	00002517          	auipc	a0,0x2
    80005f96:	7d650513          	addi	a0,a0,2006 # 80008768 <syscalls+0x370>
    80005f9a:	feefa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f9e:	00002517          	auipc	a0,0x2
    80005fa2:	7ea50513          	addi	a0,a0,2026 # 80008788 <syscalls+0x390>
    80005fa6:	fe2fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    80005faa:	00002517          	auipc	a0,0x2
    80005fae:	7fe50513          	addi	a0,a0,2046 # 800087a8 <syscalls+0x3b0>
    80005fb2:	fd6fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80005fb6:	00003517          	auipc	a0,0x3
    80005fba:	81250513          	addi	a0,a0,-2030 # 800087c8 <syscalls+0x3d0>
    80005fbe:	fcafa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80005fc2:	00003517          	auipc	a0,0x3
    80005fc6:	82650513          	addi	a0,a0,-2010 # 800087e8 <syscalls+0x3f0>
    80005fca:	fbefa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    80005fce:	00003517          	auipc	a0,0x3
    80005fd2:	83a50513          	addi	a0,a0,-1990 # 80008808 <syscalls+0x410>
    80005fd6:	fb2fa0ef          	jal	ra,80000788 <panic>

0000000080005fda <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fda:	7119                	addi	sp,sp,-128
    80005fdc:	fc86                	sd	ra,120(sp)
    80005fde:	f8a2                	sd	s0,112(sp)
    80005fe0:	f4a6                	sd	s1,104(sp)
    80005fe2:	f0ca                	sd	s2,96(sp)
    80005fe4:	ecce                	sd	s3,88(sp)
    80005fe6:	e8d2                	sd	s4,80(sp)
    80005fe8:	e4d6                	sd	s5,72(sp)
    80005fea:	e0da                	sd	s6,64(sp)
    80005fec:	fc5e                	sd	s7,56(sp)
    80005fee:	f862                	sd	s8,48(sp)
    80005ff0:	f466                	sd	s9,40(sp)
    80005ff2:	f06a                	sd	s10,32(sp)
    80005ff4:	ec6e                	sd	s11,24(sp)
    80005ff6:	0100                	addi	s0,sp,128
    80005ff8:	8aaa                	mv	s5,a0
    80005ffa:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ffc:	00c52d03          	lw	s10,12(a0)
    80006000:	001d1d1b          	slliw	s10,s10,0x1
    80006004:	1d02                	slli	s10,s10,0x20
    80006006:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000600a:	00246517          	auipc	a0,0x246
    8000600e:	bae50513          	addi	a0,a0,-1106 # 8024bbb8 <disk+0x128>
    80006012:	c8ffa0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80006016:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006018:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000601a:	00246b97          	auipc	s7,0x246
    8000601e:	a76b8b93          	addi	s7,s7,-1418 # 8024ba90 <disk>
  for(int i = 0; i < 3; i++){
    80006022:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006024:	00246c97          	auipc	s9,0x246
    80006028:	b94c8c93          	addi	s9,s9,-1132 # 8024bbb8 <disk+0x128>
    8000602c:	a8a9                	j	80006086 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    8000602e:	00fb8733          	add	a4,s7,a5
    80006032:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006036:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006038:	0207c563          	bltz	a5,80006062 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000603c:	2905                	addiw	s2,s2,1
    8000603e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006040:	05690863          	beq	s2,s6,80006090 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80006044:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006046:	00246717          	auipc	a4,0x246
    8000604a:	a4a70713          	addi	a4,a4,-1462 # 8024ba90 <disk>
    8000604e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006050:	01874683          	lbu	a3,24(a4)
    80006054:	fee9                	bnez	a3,8000602e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006056:	2785                	addiw	a5,a5,1
    80006058:	0705                	addi	a4,a4,1
    8000605a:	fe979be3          	bne	a5,s1,80006050 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000605e:	57fd                	li	a5,-1
    80006060:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006062:	01205b63          	blez	s2,80006078 <virtio_disk_rw+0x9e>
    80006066:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006068:	000a2503          	lw	a0,0(s4)
    8000606c:	d43ff0ef          	jal	ra,80005dae <free_desc>
      for(int j = 0; j < i; j++)
    80006070:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    80006072:	0a11                	addi	s4,s4,4
    80006074:	ff2d9ae3          	bne	s11,s2,80006068 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006078:	85e6                	mv	a1,s9
    8000607a:	00246517          	auipc	a0,0x246
    8000607e:	a2e50513          	addi	a0,a0,-1490 # 8024baa8 <disk+0x18>
    80006082:	ac4fc0ef          	jal	ra,80002346 <sleep>
  for(int i = 0; i < 3; i++){
    80006086:	f8040a13          	addi	s4,s0,-128
{
    8000608a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000608c:	894e                	mv	s2,s3
    8000608e:	bf5d                	j	80006044 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006090:	f8042503          	lw	a0,-128(s0)
    80006094:	00a50713          	addi	a4,a0,10
    80006098:	0712                	slli	a4,a4,0x4

  if(write)
    8000609a:	00246797          	auipc	a5,0x246
    8000609e:	9f678793          	addi	a5,a5,-1546 # 8024ba90 <disk>
    800060a2:	00e786b3          	add	a3,a5,a4
    800060a6:	01803633          	snez	a2,s8
    800060aa:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060ac:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060b0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060b4:	f6070613          	addi	a2,a4,-160
    800060b8:	6394                	ld	a3,0(a5)
    800060ba:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060bc:	00870593          	addi	a1,a4,8
    800060c0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060c2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060c4:	0007b803          	ld	a6,0(a5)
    800060c8:	9642                	add	a2,a2,a6
    800060ca:	46c1                	li	a3,16
    800060cc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060ce:	4585                	li	a1,1
    800060d0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800060d4:	f8442683          	lw	a3,-124(s0)
    800060d8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060dc:	0692                	slli	a3,a3,0x4
    800060de:	9836                	add	a6,a6,a3
    800060e0:	058a8613          	addi	a2,s5,88
    800060e4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800060e8:	0007b803          	ld	a6,0(a5)
    800060ec:	96c2                	add	a3,a3,a6
    800060ee:	40000613          	li	a2,1024
    800060f2:	c690                	sw	a2,8(a3)
  if(write)
    800060f4:	001c3613          	seqz	a2,s8
    800060f8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060fc:	00166613          	ori	a2,a2,1
    80006100:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006104:	f8842603          	lw	a2,-120(s0)
    80006108:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000610c:	00250693          	addi	a3,a0,2
    80006110:	0692                	slli	a3,a3,0x4
    80006112:	96be                	add	a3,a3,a5
    80006114:	58fd                	li	a7,-1
    80006116:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000611a:	0612                	slli	a2,a2,0x4
    8000611c:	9832                	add	a6,a6,a2
    8000611e:	f9070713          	addi	a4,a4,-112
    80006122:	973e                	add	a4,a4,a5
    80006124:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006128:	6398                	ld	a4,0(a5)
    8000612a:	9732                	add	a4,a4,a2
    8000612c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000612e:	4609                	li	a2,2
    80006130:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006134:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006138:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    8000613c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006140:	6794                	ld	a3,8(a5)
    80006142:	0026d703          	lhu	a4,2(a3)
    80006146:	8b1d                	andi	a4,a4,7
    80006148:	0706                	slli	a4,a4,0x1
    8000614a:	96ba                	add	a3,a3,a4
    8000614c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006150:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006154:	6798                	ld	a4,8(a5)
    80006156:	00275783          	lhu	a5,2(a4)
    8000615a:	2785                	addiw	a5,a5,1
    8000615c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006160:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006164:	100017b7          	lui	a5,0x10001
    80006168:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000616c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006170:	00246917          	auipc	s2,0x246
    80006174:	a4890913          	addi	s2,s2,-1464 # 8024bbb8 <disk+0x128>
  while(b->disk == 1) {
    80006178:	4485                	li	s1,1
    8000617a:	00b79a63          	bne	a5,a1,8000618e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    8000617e:	85ca                	mv	a1,s2
    80006180:	8556                	mv	a0,s5
    80006182:	9c4fc0ef          	jal	ra,80002346 <sleep>
  while(b->disk == 1) {
    80006186:	004aa783          	lw	a5,4(s5)
    8000618a:	fe978ae3          	beq	a5,s1,8000617e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    8000618e:	f8042903          	lw	s2,-128(s0)
    80006192:	00290713          	addi	a4,s2,2
    80006196:	0712                	slli	a4,a4,0x4
    80006198:	00246797          	auipc	a5,0x246
    8000619c:	8f878793          	addi	a5,a5,-1800 # 8024ba90 <disk>
    800061a0:	97ba                	add	a5,a5,a4
    800061a2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061a6:	00246997          	auipc	s3,0x246
    800061aa:	8ea98993          	addi	s3,s3,-1814 # 8024ba90 <disk>
    800061ae:	00491713          	slli	a4,s2,0x4
    800061b2:	0009b783          	ld	a5,0(s3)
    800061b6:	97ba                	add	a5,a5,a4
    800061b8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061bc:	854a                	mv	a0,s2
    800061be:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061c2:	bedff0ef          	jal	ra,80005dae <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061c6:	8885                	andi	s1,s1,1
    800061c8:	f0fd                	bnez	s1,800061ae <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061ca:	00246517          	auipc	a0,0x246
    800061ce:	9ee50513          	addi	a0,a0,-1554 # 8024bbb8 <disk+0x128>
    800061d2:	b67fa0ef          	jal	ra,80000d38 <release>
}
    800061d6:	70e6                	ld	ra,120(sp)
    800061d8:	7446                	ld	s0,112(sp)
    800061da:	74a6                	ld	s1,104(sp)
    800061dc:	7906                	ld	s2,96(sp)
    800061de:	69e6                	ld	s3,88(sp)
    800061e0:	6a46                	ld	s4,80(sp)
    800061e2:	6aa6                	ld	s5,72(sp)
    800061e4:	6b06                	ld	s6,64(sp)
    800061e6:	7be2                	ld	s7,56(sp)
    800061e8:	7c42                	ld	s8,48(sp)
    800061ea:	7ca2                	ld	s9,40(sp)
    800061ec:	7d02                	ld	s10,32(sp)
    800061ee:	6de2                	ld	s11,24(sp)
    800061f0:	6109                	addi	sp,sp,128
    800061f2:	8082                	ret

00000000800061f4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061f4:	1101                	addi	sp,sp,-32
    800061f6:	ec06                	sd	ra,24(sp)
    800061f8:	e822                	sd	s0,16(sp)
    800061fa:	e426                	sd	s1,8(sp)
    800061fc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061fe:	00246497          	auipc	s1,0x246
    80006202:	89248493          	addi	s1,s1,-1902 # 8024ba90 <disk>
    80006206:	00246517          	auipc	a0,0x246
    8000620a:	9b250513          	addi	a0,a0,-1614 # 8024bbb8 <disk+0x128>
    8000620e:	a93fa0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006212:	10001737          	lui	a4,0x10001
    80006216:	533c                	lw	a5,96(a4)
    80006218:	8b8d                	andi	a5,a5,3
    8000621a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000621c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006220:	689c                	ld	a5,16(s1)
    80006222:	0204d703          	lhu	a4,32(s1)
    80006226:	0027d783          	lhu	a5,2(a5)
    8000622a:	04f70663          	beq	a4,a5,80006276 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000622e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006232:	6898                	ld	a4,16(s1)
    80006234:	0204d783          	lhu	a5,32(s1)
    80006238:	8b9d                	andi	a5,a5,7
    8000623a:	078e                	slli	a5,a5,0x3
    8000623c:	97ba                	add	a5,a5,a4
    8000623e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006240:	00278713          	addi	a4,a5,2
    80006244:	0712                	slli	a4,a4,0x4
    80006246:	9726                	add	a4,a4,s1
    80006248:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000624c:	e321                	bnez	a4,8000628c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000624e:	0789                	addi	a5,a5,2
    80006250:	0792                	slli	a5,a5,0x4
    80006252:	97a6                	add	a5,a5,s1
    80006254:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006256:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000625a:	938fc0ef          	jal	ra,80002392 <wakeup>

    disk.used_idx += 1;
    8000625e:	0204d783          	lhu	a5,32(s1)
    80006262:	2785                	addiw	a5,a5,1
    80006264:	17c2                	slli	a5,a5,0x30
    80006266:	93c1                	srli	a5,a5,0x30
    80006268:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000626c:	6898                	ld	a4,16(s1)
    8000626e:	00275703          	lhu	a4,2(a4)
    80006272:	faf71ee3          	bne	a4,a5,8000622e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80006276:	00246517          	auipc	a0,0x246
    8000627a:	94250513          	addi	a0,a0,-1726 # 8024bbb8 <disk+0x128>
    8000627e:	abbfa0ef          	jal	ra,80000d38 <release>
}
    80006282:	60e2                	ld	ra,24(sp)
    80006284:	6442                	ld	s0,16(sp)
    80006286:	64a2                	ld	s1,8(sp)
    80006288:	6105                	addi	sp,sp,32
    8000628a:	8082                	ret
      panic("virtio_disk_intr status");
    8000628c:	00002517          	auipc	a0,0x2
    80006290:	59450513          	addi	a0,a0,1428 # 80008820 <syscalls+0x428>
    80006294:	cf4fa0ef          	jal	ra,80000788 <panic>

0000000080006298 <shm_init>:
  struct shmobj obj[NSHM];
} shmt;

void
shm_init(void)
{
    80006298:	1141                	addi	sp,sp,-16
    8000629a:	e406                	sd	ra,8(sp)
    8000629c:	e022                	sd	s0,0(sp)
    8000629e:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    800062a0:	00002597          	auipc	a1,0x2
    800062a4:	59858593          	addi	a1,a1,1432 # 80008838 <syscalls+0x440>
    800062a8:	00246517          	auipc	a0,0x246
    800062ac:	92850513          	addi	a0,a0,-1752 # 8024bbd0 <shmt>
    800062b0:	971fa0ef          	jal	ra,80000c20 <initlock>
}
    800062b4:	60a2                	ld	ra,8(sp)
    800062b6:	6402                	ld	s0,0(sp)
    800062b8:	0141                	addi	sp,sp,16
    800062ba:	8082                	ret

00000000800062bc <shm_get>:

// 找到或创建 key 对应对象，返回 index；失败返回 -1
int
shm_get(int key, int npages)
{
    800062bc:	7179                	addi	sp,sp,-48
    800062be:	f406                	sd	ra,40(sp)
    800062c0:	f022                	sd	s0,32(sp)
    800062c2:	ec26                	sd	s1,24(sp)
    800062c4:	e84a                	sd	s2,16(sp)
    800062c6:	e44e                	sd	s3,8(sp)
    800062c8:	1800                	addi	s0,sp,48
    800062ca:	892a                	mv	s2,a0
    800062cc:	89ae                	mv	s3,a1
  acquire(&shmt.lock);
    800062ce:	00246517          	auipc	a0,0x246
    800062d2:	90250513          	addi	a0,a0,-1790 # 8024bbd0 <shmt>
    800062d6:	9cbfa0ef          	jal	ra,80000ca0 <acquire>

  // 先找已有
  for(int i=0;i<NSHM;i++){
    800062da:	00246697          	auipc	a3,0x246
    800062de:	90e68693          	addi	a3,a3,-1778 # 8024bbe8 <shmt+0x18>
  acquire(&shmt.lock);
    800062e2:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    800062e4:	4481                	li	s1,0
    800062e6:	6605                	lui	a2,0x1
    800062e8:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    800062ec:	4841                	li	a6,16
    800062ee:	a811                	j	80006302 <shm_get+0x46>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    800062f0:	853a                	mv	a0,a4
    800062f2:	a47fa0ef          	jal	ra,80000d38 <release>
        return -1;
    800062f6:	54fd                	li	s1,-1
    800062f8:	a8a5                	j	80006370 <shm_get+0xb4>
  for(int i=0;i<NSHM;i++){
    800062fa:	2485                	addiw	s1,s1,1
    800062fc:	97b2                	add	a5,a5,a2
    800062fe:	05048763          	beq	s1,a6,8000634c <shm_get+0x90>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006302:	4398                	lw	a4,0(a5)
    80006304:	db7d                	beqz	a4,800062fa <shm_get+0x3e>
    80006306:	43d8                	lw	a4,4(a5)
    80006308:	ff2719e3          	bne	a4,s2,800062fa <shm_get+0x3e>
      if(npages > shmt.obj[i].npages){
    8000630c:	6785                	lui	a5,0x1
    8000630e:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006312:	02f487b3          	mul	a5,s1,a5
    80006316:	00246717          	auipc	a4,0x246
    8000631a:	8ba70713          	addi	a4,a4,-1862 # 8024bbd0 <shmt>
    8000631e:	97ba                	add	a5,a5,a4
    80006320:	539c                	lw	a5,32(a5)
    80006322:	fd37c7e3          	blt	a5,s3,800062f0 <shm_get+0x34>
      }
      shmt.obj[i].refcnt++;
    80006326:	00246517          	auipc	a0,0x246
    8000632a:	8aa50513          	addi	a0,a0,-1878 # 8024bbd0 <shmt>
    8000632e:	6785                	lui	a5,0x1
    80006330:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006334:	02e48733          	mul	a4,s1,a4
    80006338:	972a                	add	a4,a4,a0
    8000633a:	97ba                	add	a5,a5,a4
    8000633c:	8287a703          	lw	a4,-2008(a5)
    80006340:	2705                	addiw	a4,a4,1
    80006342:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    80006346:	9f3fa0ef          	jal	ra,80000d38 <release>
      return i;
    8000634a:	a01d                	j	80006370 <shm_get+0xb4>
    }
  }

  // 再创建
  for(int i=0;i<NSHM;i++){
    8000634c:	4481                	li	s1,0
    8000634e:	6705                	lui	a4,0x1
    80006350:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006354:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    80006356:	429c                	lw	a5,0(a3)
    80006358:	c785                	beqz	a5,80006380 <shm_get+0xc4>
  for(int i=0;i<NSHM;i++){
    8000635a:	2485                	addiw	s1,s1,1
    8000635c:	96ba                	add	a3,a3,a4
    8000635e:	fec49ce3          	bne	s1,a2,80006356 <shm_get+0x9a>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    80006362:	00246517          	auipc	a0,0x246
    80006366:	86e50513          	addi	a0,a0,-1938 # 8024bbd0 <shmt>
    8000636a:	9cffa0ef          	jal	ra,80000d38 <release>
  return -1;
    8000636e:	54fd                	li	s1,-1
}
    80006370:	8526                	mv	a0,s1
    80006372:	70a2                	ld	ra,40(sp)
    80006374:	7402                	ld	s0,32(sp)
    80006376:	64e2                	ld	s1,24(sp)
    80006378:	6942                	ld	s2,16(sp)
    8000637a:	69a2                	ld	s3,8(sp)
    8000637c:	6145                	addi	sp,sp,48
    8000637e:	8082                	ret
      shmt.obj[i].used = 1;
    80006380:	00246617          	auipc	a2,0x246
    80006384:	85060613          	addi	a2,a2,-1968 # 8024bbd0 <shmt>
    80006388:	6785                	lui	a5,0x1
    8000638a:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000638e:	02d486b3          	mul	a3,s1,a3
    80006392:	00d60733          	add	a4,a2,a3
    80006396:	4585                	li	a1,1
    80006398:	cf0c                	sw	a1,24(a4)
      shmt.obj[i].key = key;
    8000639a:	01272e23          	sw	s2,28(a4)
      shmt.obj[i].npages = npages;
    8000639e:	03372023          	sw	s3,32(a4)
      shmt.obj[i].refcnt = 1;
    800063a2:	97ba                	add	a5,a5,a4
    800063a4:	82b7a423          	sw	a1,-2008(a5)
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
    800063a8:	02868793          	addi	a5,a3,40
    800063ac:	97b2                	add	a5,a5,a2
    800063ae:	00246717          	auipc	a4,0x246
    800063b2:	04a70713          	addi	a4,a4,74 # 8024c3f8 <shmt+0x828>
    800063b6:	9736                	add	a4,a4,a3
    800063b8:	0007b023          	sd	zero,0(a5)
    800063bc:	07a1                	addi	a5,a5,8
    800063be:	fee79de3          	bne	a5,a4,800063b8 <shm_get+0xfc>
      release(&shmt.lock);
    800063c2:	00246517          	auipc	a0,0x246
    800063c6:	80e50513          	addi	a0,a0,-2034 # 8024bbd0 <shmt>
    800063ca:	96ffa0ef          	jal	ra,80000d38 <release>
      return i;
    800063ce:	b74d                	j	80006370 <shm_get+0xb4>

00000000800063d0 <shm_put>:

// refcnt--，若为 0 则释放对象里的所有页（kfree 会走页 refcnt，安全）
void
shm_put(int key)
{
    800063d0:	7179                	addi	sp,sp,-48
    800063d2:	f406                	sd	ra,40(sp)
    800063d4:	f022                	sd	s0,32(sp)
    800063d6:	ec26                	sd	s1,24(sp)
    800063d8:	e84a                	sd	s2,16(sp)
    800063da:	e44e                	sd	s3,8(sp)
    800063dc:	e052                	sd	s4,0(sp)
    800063de:	1800                	addi	s0,sp,48
    800063e0:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    800063e2:	00245517          	auipc	a0,0x245
    800063e6:	7ee50513          	addi	a0,a0,2030 # 8024bbd0 <shmt>
    800063ea:	8b7fa0ef          	jal	ra,80000ca0 <acquire>
  for(int i=0;i<NSHM;i++){
    800063ee:	00245797          	auipc	a5,0x245
    800063f2:	7fa78793          	addi	a5,a5,2042 # 8024bbe8 <shmt+0x18>
    800063f6:	4481                	li	s1,0
    800063f8:	6685                	lui	a3,0x1
    800063fa:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    800063fe:	4641                	li	a2,16
    80006400:	a09d                	j	80006466 <shm_put+0x96>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
    80006402:	00002517          	auipc	a0,0x2
    80006406:	43e50513          	addi	a0,a0,1086 # 80008840 <syscalls+0x448>
    8000640a:	b7efa0ef          	jal	ra,80000788 <panic>
      shmt.obj[i].refcnt--;
      if(shmt.obj[i].refcnt == 0){
        for(int j=0;j<shmt.obj[i].npages;j++){
    8000640e:	2985                	addiw	s3,s3,1
    80006410:	0921                	addi	s2,s2,8
    80006412:	020a2783          	lw	a5,32(s4)
    80006416:	00f9da63          	bge	s3,a5,8000642a <shm_put+0x5a>
          if(shmt.obj[i].pa[j]){
    8000641a:	00093503          	ld	a0,0(s2)
    8000641e:	d965                	beqz	a0,8000640e <shm_put+0x3e>
            kfree((void*)shmt.obj[i].pa[j]);
    80006420:	e5afa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    80006424:	00093023          	sd	zero,0(s2)
    80006428:	b7dd                	j	8000640e <shm_put+0x3e>
          }
        }
        shmt.obj[i].used = 0;
    8000642a:	6785                	lui	a5,0x1
    8000642c:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006430:	02f484b3          	mul	s1,s1,a5
    80006434:	00245797          	auipc	a5,0x245
    80006438:	79c78793          	addi	a5,a5,1948 # 8024bbd0 <shmt>
    8000643c:	97a6                	add	a5,a5,s1
    8000643e:	0007ac23          	sw	zero,24(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    80006442:	00245517          	auipc	a0,0x245
    80006446:	78e50513          	addi	a0,a0,1934 # 8024bbd0 <shmt>
    8000644a:	8effa0ef          	jal	ra,80000d38 <release>
}
    8000644e:	70a2                	ld	ra,40(sp)
    80006450:	7402                	ld	s0,32(sp)
    80006452:	64e2                	ld	s1,24(sp)
    80006454:	6942                	ld	s2,16(sp)
    80006456:	69a2                	ld	s3,8(sp)
    80006458:	6a02                	ld	s4,0(sp)
    8000645a:	6145                	addi	sp,sp,48
    8000645c:	8082                	ret
  for(int i=0;i<NSHM;i++){
    8000645e:	2485                	addiw	s1,s1,1
    80006460:	97b6                	add	a5,a5,a3
    80006462:	fec480e3          	beq	s1,a2,80006442 <shm_put+0x72>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006466:	4398                	lw	a4,0(a5)
    80006468:	db7d                	beqz	a4,8000645e <shm_put+0x8e>
    8000646a:	43d8                	lw	a4,4(a5)
    8000646c:	ff2719e3          	bne	a4,s2,8000645e <shm_put+0x8e>
      if(shmt.obj[i].refcnt < 1)
    80006470:	6785                	lui	a5,0x1
    80006472:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006476:	02d486b3          	mul	a3,s1,a3
    8000647a:	00245717          	auipc	a4,0x245
    8000647e:	75670713          	addi	a4,a4,1878 # 8024bbd0 <shmt>
    80006482:	9736                	add	a4,a4,a3
    80006484:	97ba                	add	a5,a5,a4
    80006486:	8287a783          	lw	a5,-2008(a5)
    8000648a:	f6f05ce3          	blez	a5,80006402 <shm_put+0x32>
      shmt.obj[i].refcnt--;
    8000648e:	37fd                	addiw	a5,a5,-1
    80006490:	0007899b          	sext.w	s3,a5
    80006494:	6705                	lui	a4,0x1
    80006496:	81870613          	addi	a2,a4,-2024 # 818 <_entry-0x7ffff7e8>
    8000649a:	02c48633          	mul	a2,s1,a2
    8000649e:	00245697          	auipc	a3,0x245
    800064a2:	73268693          	addi	a3,a3,1842 # 8024bbd0 <shmt>
    800064a6:	96b2                	add	a3,a3,a2
    800064a8:	9736                	add	a4,a4,a3
    800064aa:	82f72423          	sw	a5,-2008(a4)
      if(shmt.obj[i].refcnt == 0){
    800064ae:	f8099ae3          	bnez	s3,80006442 <shm_put+0x72>
        for(int j=0;j<shmt.obj[i].npages;j++){
    800064b2:	529c                	lw	a5,32(a3)
    800064b4:	f6f05be3          	blez	a5,8000642a <shm_put+0x5a>
    800064b8:	00245797          	auipc	a5,0x245
    800064bc:	74078793          	addi	a5,a5,1856 # 8024bbf8 <shmt+0x28>
    800064c0:	00f60933          	add	s2,a2,a5
    800064c4:	8a36                	mv	s4,a3
    800064c6:	bf91                	j	8000641a <shm_put+0x4a>

00000000800064c8 <shm_getpa>:

// 取某页的 pa；若未分配则分配（lazy），返回 pa 或 0
uint64
shm_getpa(int key, int page_index)
{
    800064c8:	7179                	addi	sp,sp,-48
    800064ca:	f406                	sd	ra,40(sp)
    800064cc:	f022                	sd	s0,32(sp)
    800064ce:	ec26                	sd	s1,24(sp)
    800064d0:	e84a                	sd	s2,16(sp)
    800064d2:	e44e                	sd	s3,8(sp)
    800064d4:	e052                	sd	s4,0(sp)
    800064d6:	1800                	addi	s0,sp,48
    800064d8:	892a                	mv	s2,a0
    800064da:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    800064dc:	00245517          	auipc	a0,0x245
    800064e0:	6f450513          	addi	a0,a0,1780 # 8024bbd0 <shmt>
    800064e4:	fbcfa0ef          	jal	ra,80000ca0 <acquire>

  for(int i=0;i<NSHM;i++){
    800064e8:	00245797          	auipc	a5,0x245
    800064ec:	70078793          	addi	a5,a5,1792 # 8024bbe8 <shmt+0x18>
    800064f0:	4481                	li	s1,0
    800064f2:	6685                	lui	a3,0x1
    800064f4:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    800064f8:	4641                	li	a2,16
    800064fa:	a82d                	j	80006534 <shm_getpa+0x6c>
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
        pa = 0;
        break;
      }
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    800064fc:	eaefa0ef          	jal	ra,80000baa <kalloc>
    80006500:	8a2a                	mv	s4,a0
        if(mem == 0){
    80006502:	cd41                	beqz	a0,8000659a <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        memset(mem, 0, PGSIZE);
    80006504:	6605                	lui	a2,0x1
    80006506:	4581                	li	a1,0
    80006508:	86dfa0ef          	jal	ra,80000d74 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    8000650c:	00649793          	slli	a5,s1,0x6
    80006510:	97a6                	add	a5,a5,s1
    80006512:	078a                	slli	a5,a5,0x2
    80006514:	8f85                	sub	a5,a5,s1
    80006516:	97ce                	add	a5,a5,s3
    80006518:	0791                	addi	a5,a5,4
    8000651a:	078e                	slli	a5,a5,0x3
    8000651c:	00245717          	auipc	a4,0x245
    80006520:	6b470713          	addi	a4,a4,1716 # 8024bbd0 <shmt>
    80006524:	97ba                	add	a5,a5,a4
    80006526:	0147b423          	sd	s4,8(a5)
    8000652a:	a0b9                	j	80006578 <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    8000652c:	2485                	addiw	s1,s1,1
    8000652e:	97b6                	add	a5,a5,a3
    80006530:	06c48463          	beq	s1,a2,80006598 <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006534:	4398                	lw	a4,0(a5)
    80006536:	db7d                	beqz	a4,8000652c <shm_getpa+0x64>
    80006538:	43d8                	lw	a4,4(a5)
    8000653a:	ff2719e3          	bne	a4,s2,8000652c <shm_getpa+0x64>
        pa = 0;
    8000653e:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    80006540:	0409cd63          	bltz	s3,8000659a <shm_getpa+0xd2>
    80006544:	6785                	lui	a5,0x1
    80006546:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000654a:	02f487b3          	mul	a5,s1,a5
    8000654e:	00245717          	auipc	a4,0x245
    80006552:	68270713          	addi	a4,a4,1666 # 8024bbd0 <shmt>
    80006556:	97ba                	add	a5,a5,a4
    80006558:	539c                	lw	a5,32(a5)
    8000655a:	04f9d063          	bge	s3,a5,8000659a <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    8000655e:	00649793          	slli	a5,s1,0x6
    80006562:	97a6                	add	a5,a5,s1
    80006564:	078a                	slli	a5,a5,0x2
    80006566:	8f85                	sub	a5,a5,s1
    80006568:	97ce                	add	a5,a5,s3
    8000656a:	0791                	addi	a5,a5,4
    8000656c:	078e                	slli	a5,a5,0x3
    8000656e:	97ba                	add	a5,a5,a4
    80006570:	0087b903          	ld	s2,8(a5)
    80006574:	f80904e3          	beqz	s2,800064fc <shm_getpa+0x34>
      }
      pa = shmt.obj[i].pa[page_index];
    80006578:	00649793          	slli	a5,s1,0x6
    8000657c:	97a6                	add	a5,a5,s1
    8000657e:	078a                	slli	a5,a5,0x2
    80006580:	8f85                	sub	a5,a5,s1
    80006582:	97ce                	add	a5,a5,s3
    80006584:	0791                	addi	a5,a5,4
    80006586:	078e                	slli	a5,a5,0x3
    80006588:	00245717          	auipc	a4,0x245
    8000658c:	64870713          	addi	a4,a4,1608 # 8024bbd0 <shmt>
    80006590:	97ba                	add	a5,a5,a4
    80006592:	0087b903          	ld	s2,8(a5)
      break;
    80006596:	a011                	j	8000659a <shm_getpa+0xd2>
  uint64 pa = 0;
    80006598:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    8000659a:	00245517          	auipc	a0,0x245
    8000659e:	63650513          	addi	a0,a0,1590 # 8024bbd0 <shmt>
    800065a2:	f96fa0ef          	jal	ra,80000d38 <release>
  return pa;
}
    800065a6:	854a                	mv	a0,s2
    800065a8:	70a2                	ld	ra,40(sp)
    800065aa:	7402                	ld	s0,32(sp)
    800065ac:	64e2                	ld	s1,24(sp)
    800065ae:	6942                	ld	s2,16(sp)
    800065b0:	69a2                	ld	s3,8(sp)
    800065b2:	6a02                	ld	s4,0(sp)
    800065b4:	6145                	addi	sp,sp,48
    800065b6:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
