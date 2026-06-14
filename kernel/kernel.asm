
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8f010113          	addi	sp,sp,-1808 # 800088f0 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdaa60f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	ea678793          	addi	a5,a5,-346 # 80000f26 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
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
    8000010a:	72e020ef          	jal	ra,80002838 <either_copyin>
    8000010e:	03650263          	beq	a0,s6,80000132 <consolewrite+0x62>
      break;
    uartwrite(buf, nn);
    80000112:	85a6                	mv	a1,s1
    80000114:	f9040513          	addi	a0,s0,-112
    80000118:	71e000ef          	jal	ra,80000836 <uartwrite>
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
    80000176:	77e50513          	addi	a0,a0,1918 # 800108f0 <cons>
    8000017a:	337000ef          	jal	ra,80000cb0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	77248493          	addi	s1,s1,1906 # 800108f0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00011917          	auipc	s2,0x11
    8000018a:	80290913          	addi	s2,s2,-2046 # 80010988 <cons+0x98>
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
    800001a4:	1f7010ef          	jal	ra,80001b9a <myproc>
    800001a8:	522020ef          	jal	ra,800026ca <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	2e0020ef          	jal	ra,80002492 <sleep>
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
    800001ea:	604020ef          	jal	ra,800027ee <either_copyout>
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
    800001fe:	6f650513          	addi	a0,a0,1782 # 800108f0 <cons>
    80000202:	347000ef          	jal	ra,80000d48 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	6e450513          	addi	a0,a0,1764 # 800108f0 <cons>
    80000214:	335000ef          	jal	ra,80000d48 <release>
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
    80000242:	74f72523          	sw	a5,1866(a4) # 80010988 <cons+0x98>
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
    8000028c:	66850513          	addi	a0,a0,1640 # 800108f0 <cons>
    80000290:	221000ef          	jal	ra,80000cb0 <acquire>

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
    800002aa:	5d8020ef          	jal	ra,80002882 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	64250513          	addi	a0,a0,1602 # 800108f0 <cons>
    800002b6:	293000ef          	jal	ra,80000d48 <release>
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
    800002d2:	62270713          	addi	a4,a4,1570 # 800108f0 <cons>
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
    800002f8:	5fc78793          	addi	a5,a5,1532 # 800108f0 <cons>
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
    80000326:	6667a783          	lw	a5,1638(a5) # 80010988 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	5ba70713          	addi	a4,a4,1466 # 800108f0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	5aa48493          	addi	s1,s1,1450 # 800108f0 <cons>
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
    80000382:	57270713          	addi	a4,a4,1394 # 800108f0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	5ef72e23          	sw	a5,1532(a4) # 80010990 <cons+0xa0>
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
    800003b6:	53e78793          	addi	a5,a5,1342 # 800108f0 <cons>
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
    800003da:	5ac7ab23          	sw	a2,1462(a5) # 8001098c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	5aa50513          	addi	a0,a0,1450 # 80010988 <cons+0x98>
    800003e6:	0f8020ef          	jal	ra,800024de <wakeup>
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
    80000400:	4f450513          	addi	a0,a0,1268 # 800108f0 <cons>
    80000404:	02d000ef          	jal	ra,80000c30 <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0024a797          	auipc	a5,0x24a
    80000410:	66c78793          	addi	a5,a5,1644 # 8024aa78 <devsw>
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
    8000043e:	06054f63          	bltz	a0,800004bc <printint+0x8c>
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
    80000470:	00088b63          	beqz	a7,80000486 <printint+0x56>
    buf[i++] = '-';
    80000474:	fe040713          	addi	a4,s0,-32
    80000478:	97ba                	add	a5,a5,a4
    8000047a:	02d00713          	li	a4,45
    8000047e:	fee78423          	sb	a4,-24(a5)
    80000482:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000486:	02f05563          	blez	a5,800004b0 <printint+0x80>
    8000048a:	fc840713          	addi	a4,s0,-56
    8000048e:	00f704b3          	add	s1,a4,a5
    80000492:	fff70913          	addi	s2,a4,-1
    80000496:	993e                	add	s2,s2,a5
    80000498:	37fd                	addiw	a5,a5,-1
    8000049a:	1782                	slli	a5,a5,0x20
    8000049c:	9381                	srli	a5,a5,0x20
    8000049e:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a2:	fff4c503          	lbu	a0,-1(s1)
    800004a6:	da3ff0ef          	jal	ra,80000248 <consputc>
  while(--i >= 0)
    800004aa:	14fd                	addi	s1,s1,-1
    800004ac:	ff249be3          	bne	s1,s2,800004a2 <printint+0x72>
}
    800004b0:	70e2                	ld	ra,56(sp)
    800004b2:	7442                	ld	s0,48(sp)
    800004b4:	74a2                	ld	s1,40(sp)
    800004b6:	7902                	ld	s2,32(sp)
    800004b8:	6121                	addi	sp,sp,64
    800004ba:	8082                	ret
    x = -xx;
    800004bc:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004c0:	4885                	li	a7,1
    x = -xx;
    800004c2:	b749                	j	80000444 <printint+0x14>

00000000800004c4 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c4:	7131                	addi	sp,sp,-192
    800004c6:	fc86                	sd	ra,120(sp)
    800004c8:	f8a2                	sd	s0,112(sp)
    800004ca:	f4a6                	sd	s1,104(sp)
    800004cc:	f0ca                	sd	s2,96(sp)
    800004ce:	ecce                	sd	s3,88(sp)
    800004d0:	e8d2                	sd	s4,80(sp)
    800004d2:	e4d6                	sd	s5,72(sp)
    800004d4:	e0da                	sd	s6,64(sp)
    800004d6:	fc5e                	sd	s7,56(sp)
    800004d8:	f862                	sd	s8,48(sp)
    800004da:	f466                	sd	s9,40(sp)
    800004dc:	f06a                	sd	s10,32(sp)
    800004de:	ec6e                	sd	s11,24(sp)
    800004e0:	0100                	addi	s0,sp,128
    800004e2:	8a2a                	mv	s4,a0
    800004e4:	e40c                	sd	a1,8(s0)
    800004e6:	e810                	sd	a2,16(s0)
    800004e8:	ec14                	sd	a3,24(s0)
    800004ea:	f018                	sd	a4,32(s0)
    800004ec:	f41c                	sd	a5,40(s0)
    800004ee:	03043823          	sd	a6,48(s0)
    800004f2:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800004f6:	00008797          	auipc	a5,0x8
    800004fa:	3ae7a783          	lw	a5,942(a5) # 800088a4 <panicking>
    800004fe:	cb9d                	beqz	a5,80000534 <printf+0x70>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000500:	00840793          	addi	a5,s0,8
    80000504:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000508:	000a4503          	lbu	a0,0(s4)
    8000050c:	24050363          	beqz	a0,80000752 <printf+0x28e>
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000052a:	00008b97          	auipc	s7,0x8
    8000052e:	b0eb8b93          	addi	s7,s7,-1266 # 80008038 <digits>
    80000532:	a01d                	j	80000558 <printf+0x94>
    acquire(&pr.lock);
    80000534:	00010517          	auipc	a0,0x10
    80000538:	46450513          	addi	a0,a0,1124 # 80010998 <pr>
    8000053c:	774000ef          	jal	ra,80000cb0 <acquire>
    80000540:	b7c1                	j	80000500 <printf+0x3c>
      consputc(cx);
    80000542:	d07ff0ef          	jal	ra,80000248 <consputc>
      continue;
    80000546:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000548:	0014899b          	addiw	s3,s1,1
    8000054c:	013a07b3          	add	a5,s4,s3
    80000550:	0007c503          	lbu	a0,0(a5)
    80000554:	1e050f63          	beqz	a0,80000752 <printf+0x28e>
    if(cx != '%'){
    80000558:	ff5515e3          	bne	a0,s5,80000542 <printf+0x7e>
    i++;
    8000055c:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000560:	009a07b3          	add	a5,s4,s1
    80000564:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000568:	1e090563          	beqz	s2,80000752 <printf+0x28e>
    8000056c:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000570:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000572:	c789                	beqz	a5,8000057c <printf+0xb8>
    80000574:	009a0733          	add	a4,s4,s1
    80000578:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000057c:	03690863          	beq	s2,s6,800005ac <printf+0xe8>
    } else if(c0 == 'l' && c1 == 'd'){
    80000580:	05890263          	beq	s2,s8,800005c4 <printf+0x100>
    } else if(c0 == 'u'){
    80000584:	0d990163          	beq	s2,s9,80000646 <printf+0x182>
    } else if(c0 == 'x'){
    80000588:	11a90863          	beq	s2,s10,80000698 <printf+0x1d4>
    } else if(c0 == 'p'){
    8000058c:	15b90163          	beq	s2,s11,800006ce <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    80000590:	06300793          	li	a5,99
    80000594:	16f90963          	beq	s2,a5,80000706 <printf+0x242>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80000598:	07300793          	li	a5,115
    8000059c:	16f90f63          	beq	s2,a5,8000071a <printf+0x256>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a0:	03591c63          	bne	s2,s5,800005d8 <printf+0x114>
      consputc('%');
    800005a4:	8556                	mv	a0,s5
    800005a6:	ca3ff0ef          	jal	ra,80000248 <consputc>
    800005aa:	bf79                	j	80000548 <printf+0x84>
      printint(va_arg(ap, int), 10, 1);
    800005ac:	f8843783          	ld	a5,-120(s0)
    800005b0:	00878713          	addi	a4,a5,8
    800005b4:	f8e43423          	sd	a4,-120(s0)
    800005b8:	4605                	li	a2,1
    800005ba:	45a9                	li	a1,10
    800005bc:	4388                	lw	a0,0(a5)
    800005be:	e73ff0ef          	jal	ra,80000430 <printint>
    800005c2:	b759                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c4:	03678163          	beq	a5,s6,800005e6 <printf+0x122>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005c8:	03878d63          	beq	a5,s8,80000602 <printf+0x13e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005cc:	09978a63          	beq	a5,s9,80000660 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005d0:	03878b63          	beq	a5,s8,80000606 <printf+0x142>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	0da78f63          	beq	a5,s10,800006b2 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005d8:	8556                	mv	a0,s5
    800005da:	c6fff0ef          	jal	ra,80000248 <consputc>
      consputc(c0);
    800005de:	854a                	mv	a0,s2
    800005e0:	c69ff0ef          	jal	ra,80000248 <consputc>
    800005e4:	b795                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    800005e6:	f8843783          	ld	a5,-120(s0)
    800005ea:	00878713          	addi	a4,a5,8
    800005ee:	f8e43423          	sd	a4,-120(s0)
    800005f2:	4605                	li	a2,1
    800005f4:	45a9                	li	a1,10
    800005f6:	6388                	ld	a0,0(a5)
    800005f8:	e39ff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800005fc:	0029849b          	addiw	s1,s3,2
    80000600:	b7a1                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000602:	03668463          	beq	a3,s6,8000062a <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000606:	07968b63          	beq	a3,s9,8000067c <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000060a:	fda697e3          	bne	a3,s10,800005d8 <printf+0x114>
      printint(va_arg(ap, uint64), 16, 0);
    8000060e:	f8843783          	ld	a5,-120(s0)
    80000612:	00878713          	addi	a4,a5,8
    80000616:	f8e43423          	sd	a4,-120(s0)
    8000061a:	4601                	li	a2,0
    8000061c:	45c1                	li	a1,16
    8000061e:	6388                	ld	a0,0(a5)
    80000620:	e11ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000624:	0039849b          	addiw	s1,s3,3
    80000628:	b705                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    8000062a:	f8843783          	ld	a5,-120(s0)
    8000062e:	00878713          	addi	a4,a5,8
    80000632:	f8e43423          	sd	a4,-120(s0)
    80000636:	4605                	li	a2,1
    80000638:	45a9                	li	a1,10
    8000063a:	6388                	ld	a0,0(a5)
    8000063c:	df5ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000640:	0039849b          	addiw	s1,s3,3
    80000644:	b711                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 10, 0);
    80000646:	f8843783          	ld	a5,-120(s0)
    8000064a:	00878713          	addi	a4,a5,8
    8000064e:	f8e43423          	sd	a4,-120(s0)
    80000652:	4601                	li	a2,0
    80000654:	45a9                	li	a1,10
    80000656:	0007e503          	lwu	a0,0(a5)
    8000065a:	dd7ff0ef          	jal	ra,80000430 <printint>
    8000065e:	b5ed                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	dbfff0ef          	jal	ra,80000430 <printint>
      i += 1;
    80000676:	0029849b          	addiw	s1,s3,2
    8000067a:	b5f9                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	6388                	ld	a0,0(a5)
    8000068e:	da3ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000692:	0039849b          	addiw	s1,s3,3
    80000696:	bd4d                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 16, 0);
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	4601                	li	a2,0
    800006a6:	45c1                	li	a1,16
    800006a8:	0007e503          	lwu	a0,0(a5)
    800006ac:	d85ff0ef          	jal	ra,80000430 <printint>
    800006b0:	bd61                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 16, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45c1                	li	a1,16
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	d6dff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800006c8:	0029849b          	addiw	s1,s3,2
    800006cc:	bdb5                	j	80000548 <printf+0x84>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	b67ff0ef          	jal	ra,80000248 <consputc>
  consputc('x');
    800006e6:	856a                	mv	a0,s10
    800006e8:	b61ff0ef          	jal	ra,80000248 <consputc>
    800006ec:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ee:	03c9d793          	srli	a5,s3,0x3c
    800006f2:	97de                	add	a5,a5,s7
    800006f4:	0007c503          	lbu	a0,0(a5)
    800006f8:	b51ff0ef          	jal	ra,80000248 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006fc:	0992                	slli	s3,s3,0x4
    800006fe:	397d                	addiw	s2,s2,-1
    80000700:	fe0917e3          	bnez	s2,800006ee <printf+0x22a>
    80000704:	b591                	j	80000548 <printf+0x84>
      consputc(va_arg(ap, uint));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	4388                	lw	a0,0(a5)
    80000714:	b35ff0ef          	jal	ra,80000248 <consputc>
    80000718:	bd05                	j	80000548 <printf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    8000071a:	f8843783          	ld	a5,-120(s0)
    8000071e:	00878713          	addi	a4,a5,8
    80000722:	f8e43423          	sd	a4,-120(s0)
    80000726:	0007b903          	ld	s2,0(a5)
    8000072a:	00090d63          	beqz	s2,80000744 <printf+0x280>
      for(; *s; s++)
    8000072e:	00094503          	lbu	a0,0(s2)
    80000732:	e0050be3          	beqz	a0,80000548 <printf+0x84>
        consputc(*s);
    80000736:	b13ff0ef          	jal	ra,80000248 <consputc>
      for(; *s; s++)
    8000073a:	0905                	addi	s2,s2,1
    8000073c:	00094503          	lbu	a0,0(s2)
    80000740:	f97d                	bnez	a0,80000736 <printf+0x272>
    80000742:	b519                	j	80000548 <printf+0x84>
        s = "(null)";
    80000744:	00008917          	auipc	s2,0x8
    80000748:	8d490913          	addi	s2,s2,-1836 # 80008018 <etext+0x18>
      for(; *s; s++)
    8000074c:	02800513          	li	a0,40
    80000750:	b7dd                	j	80000736 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000752:	00008797          	auipc	a5,0x8
    80000756:	1527a783          	lw	a5,338(a5) # 800088a4 <panicking>
    8000075a:	c38d                	beqz	a5,8000077c <printf+0x2b8>
    release(&pr.lock);

  return 0;
}
    8000075c:	4501                	li	a0,0
    8000075e:	70e6                	ld	ra,120(sp)
    80000760:	7446                	ld	s0,112(sp)
    80000762:	74a6                	ld	s1,104(sp)
    80000764:	7906                	ld	s2,96(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6a46                	ld	s4,80(sp)
    8000076a:	6aa6                	ld	s5,72(sp)
    8000076c:	6b06                	ld	s6,64(sp)
    8000076e:	7be2                	ld	s7,56(sp)
    80000770:	7c42                	ld	s8,48(sp)
    80000772:	7ca2                	ld	s9,40(sp)
    80000774:	7d02                	ld	s10,32(sp)
    80000776:	6de2                	ld	s11,24(sp)
    80000778:	6129                	addi	sp,sp,192
    8000077a:	8082                	ret
    release(&pr.lock);
    8000077c:	00010517          	auipc	a0,0x10
    80000780:	21c50513          	addi	a0,a0,540 # 80010998 <pr>
    80000784:	5c4000ef          	jal	ra,80000d48 <release>
  return 0;
    80000788:	bfd1                	j	8000075c <printf+0x298>

000000008000078a <panic>:

void
panic(char *s)
{
    8000078a:	1101                	addi	sp,sp,-32
    8000078c:	ec06                	sd	ra,24(sp)
    8000078e:	e822                	sd	s0,16(sp)
    80000790:	e426                	sd	s1,8(sp)
    80000792:	e04a                	sd	s2,0(sp)
    80000794:	1000                	addi	s0,sp,32
    80000796:	84aa                	mv	s1,a0
  panicking = 1;
    80000798:	4905                	li	s2,1
    8000079a:	00008797          	auipc	a5,0x8
    8000079e:	1127a523          	sw	s2,266(a5) # 800088a4 <panicking>
  printf("panic: ");
    800007a2:	00008517          	auipc	a0,0x8
    800007a6:	87e50513          	addi	a0,a0,-1922 # 80008020 <etext+0x20>
    800007aa:	d1bff0ef          	jal	ra,800004c4 <printf>
  printf("%s\n", s);
    800007ae:	85a6                	mv	a1,s1
    800007b0:	00008517          	auipc	a0,0x8
    800007b4:	87850513          	addi	a0,a0,-1928 # 80008028 <etext+0x28>
    800007b8:	d0dff0ef          	jal	ra,800004c4 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007bc:	00008797          	auipc	a5,0x8
    800007c0:	0f27a223          	sw	s2,228(a5) # 800088a0 <panicked>
  for(;;)
    800007c4:	a001                	j	800007c4 <panic+0x3a>

00000000800007c6 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007c6:	1141                	addi	sp,sp,-16
    800007c8:	e406                	sd	ra,8(sp)
    800007ca:	e022                	sd	s0,0(sp)
    800007cc:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007ce:	00008597          	auipc	a1,0x8
    800007d2:	86258593          	addi	a1,a1,-1950 # 80008030 <etext+0x30>
    800007d6:	00010517          	auipc	a0,0x10
    800007da:	1c250513          	addi	a0,a0,450 # 80010998 <pr>
    800007de:	452000ef          	jal	ra,80000c30 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800007ea:	1141                	addi	sp,sp,-16
    800007ec:	e406                	sd	ra,8(sp)
    800007ee:	e022                	sd	s0,0(sp)
    800007f0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007f2:	100007b7          	lui	a5,0x10000
    800007f6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007fa:	f8000713          	li	a4,-128
    800007fe:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000802:	470d                	li	a4,3
    80000804:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000808:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000810:	469d                	li	a3,7
    80000812:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000816:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    8000081a:	00008597          	auipc	a1,0x8
    8000081e:	83658593          	addi	a1,a1,-1994 # 80008050 <digits+0x18>
    80000822:	00010517          	auipc	a0,0x10
    80000826:	18e50513          	addi	a0,a0,398 # 800109b0 <tx_lock>
    8000082a:	406000ef          	jal	ra,80000c30 <initlock>
}
    8000082e:	60a2                	ld	ra,8(sp)
    80000830:	6402                	ld	s0,0(sp)
    80000832:	0141                	addi	sp,sp,16
    80000834:	8082                	ret

0000000080000836 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000836:	715d                	addi	sp,sp,-80
    80000838:	e486                	sd	ra,72(sp)
    8000083a:	e0a2                	sd	s0,64(sp)
    8000083c:	fc26                	sd	s1,56(sp)
    8000083e:	f84a                	sd	s2,48(sp)
    80000840:	f44e                	sd	s3,40(sp)
    80000842:	f052                	sd	s4,32(sp)
    80000844:	ec56                	sd	s5,24(sp)
    80000846:	e85a                	sd	s6,16(sp)
    80000848:	e45e                	sd	s7,8(sp)
    8000084a:	0880                	addi	s0,sp,80
    8000084c:	84aa                	mv	s1,a0
    8000084e:	8aae                	mv	s5,a1
  acquire(&tx_lock);
    80000850:	00010517          	auipc	a0,0x10
    80000854:	16050513          	addi	a0,a0,352 # 800109b0 <tx_lock>
    80000858:	458000ef          	jal	ra,80000cb0 <acquire>

  int i = 0;
  while(i < n){ 
    8000085c:	05505b63          	blez	s5,800008b2 <uartwrite+0x7c>
    80000860:	8a26                	mv	s4,s1
    80000862:	0485                	addi	s1,s1,1
    80000864:	3afd                	addiw	s5,s5,-1
    80000866:	1a82                	slli	s5,s5,0x20
    80000868:	020ada93          	srli	s5,s5,0x20
    8000086c:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    8000086e:	00008497          	auipc	s1,0x8
    80000872:	03e48493          	addi	s1,s1,62 # 800088ac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	00010997          	auipc	s3,0x10
    8000087a:	13a98993          	addi	s3,s3,314 # 800109b0 <tx_lock>
    8000087e:	00008917          	auipc	s2,0x8
    80000882:	02a90913          	addi	s2,s2,42 # 800088a8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000886:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    8000088a:	4b05                	li	s6,1
    8000088c:	a005                	j	800008ac <uartwrite+0x76>
      sleep(&tx_chan, &tx_lock);
    8000088e:	85ce                	mv	a1,s3
    80000890:	854a                	mv	a0,s2
    80000892:	401010ef          	jal	ra,80002492 <sleep>
    while(tx_busy != 0){
    80000896:	409c                	lw	a5,0(s1)
    80000898:	fbfd                	bnez	a5,8000088e <uartwrite+0x58>
    WriteReg(THR, buf[i]);
    8000089a:	000a4783          	lbu	a5,0(s4)
    8000089e:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008a2:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008a6:	0a05                	addi	s4,s4,1
    800008a8:	015a0563          	beq	s4,s5,800008b2 <uartwrite+0x7c>
    while(tx_busy != 0){
    800008ac:	409c                	lw	a5,0(s1)
    800008ae:	f3e5                	bnez	a5,8000088e <uartwrite+0x58>
    800008b0:	b7ed                	j	8000089a <uartwrite+0x64>
  }

  release(&tx_lock);
    800008b2:	00010517          	auipc	a0,0x10
    800008b6:	0fe50513          	addi	a0,a0,254 # 800109b0 <tx_lock>
    800008ba:	48e000ef          	jal	ra,80000d48 <release>
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
    800008e4:	fc47a783          	lw	a5,-60(a5) # 800088a4 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	fb67a783          	lw	a5,-74(a5) # 800088a0 <panicked>
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
    800008fa:	376000ef          	jal	ra,80000c70 <push_off>
    800008fe:	b7f5                	j	800008ea <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000900:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000904:	0207f793          	andi	a5,a5,32
    80000908:	dfe5                	beqz	a5,80000900 <uartputc_sync+0x2c>
    ;
  WriteReg(THR, c);
    8000090a:	0ff4f513          	andi	a0,s1,255
    8000090e:	100007b7          	lui	a5,0x10000
    80000912:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000916:	00008797          	auipc	a5,0x8
    8000091a:	f8e7a783          	lw	a5,-114(a5) # 800088a4 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	3ca000ef          	jal	ra,80000cf4 <pop_off>
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
    80000940:	cb91                	beqz	a5,80000954 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000942:	100007b7          	lui	a5,0x10000
    80000946:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000094a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000094e:	6422                	ld	s0,8(sp)
    80000950:	0141                	addi	sp,sp,16
    80000952:	8082                	ret
    return -1;
    80000954:	557d                	li	a0,-1
    80000956:	bfe5                	j	8000094e <uartgetc+0x1e>

0000000080000958 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000958:	1101                	addi	sp,sp,-32
    8000095a:	ec06                	sd	ra,24(sp)
    8000095c:	e822                	sd	s0,16(sp)
    8000095e:	e426                	sd	s1,8(sp)
    80000960:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000962:	100004b7          	lui	s1,0x10000
    80000966:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    8000096a:	00010517          	auipc	a0,0x10
    8000096e:	04650513          	addi	a0,a0,70 # 800109b0 <tx_lock>
    80000972:	33e000ef          	jal	ra,80000cb0 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000976:	0054c783          	lbu	a5,5(s1)
    8000097a:	0207f793          	andi	a5,a5,32
    8000097e:	eb89                	bnez	a5,80000990 <uartintr+0x38>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000980:	00010517          	auipc	a0,0x10
    80000984:	03050513          	addi	a0,a0,48 # 800109b0 <tx_lock>
    80000988:	3c0000ef          	jal	ra,80000d48 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00008797          	auipc	a5,0x8
    80000994:	f007ae23          	sw	zero,-228(a5) # 800088ac <tx_busy>
    wakeup(&tx_chan);
    80000998:	00008517          	auipc	a0,0x8
    8000099c:	f1050513          	addi	a0,a0,-240 # 800088a8 <tx_chan>
    800009a0:	33f010ef          	jal	ra,800024de <wakeup>
    800009a4:	bff1                	j	80000980 <uartintr+0x28>
      break;
    consoleintr(c);
    800009a6:	8d5ff0ef          	jal	ra,8000027a <consoleintr>
    int c = uartgetc();
    800009aa:	f87ff0ef          	jal	ra,80000930 <uartgetc>
    if(c == -1)
    800009ae:	fe951ce3          	bne	a0,s1,800009a6 <uartintr+0x4e>
  }
}
    800009b2:	60e2                	ld	ra,24(sp)
    800009b4:	6442                	ld	s0,16(sp)
    800009b6:	64a2                	ld	s1,8(sp)
    800009b8:	6105                	addi	sp,sp,32
    800009ba:	8082                	ret

00000000800009bc <kref_get>:
 * 注意：
 *   - 此函数需要通过PA2IDX将物理地址转换为引用计数数组的索引
 *   - 操作过程中会获取kref锁以保证线程安全
 */
int     
kref_get(void *pa){
    800009bc:	1101                	addi	sp,sp,-32
    800009be:	ec06                	sd	ra,24(sp)
    800009c0:	e822                	sd	s0,16(sp)
    800009c2:	e426                	sd	s1,8(sp)
    800009c4:	1000                	addi	s0,sp,32
    800009c6:	84aa                	mv	s1,a0
  int n;
  acquire(&kref.lock);
    800009c8:	00010517          	auipc	a0,0x10
    800009cc:	02050513          	addi	a0,a0,32 # 800109e8 <kref>
    800009d0:	2e0000ef          	jal	ra,80000cb0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d4:	00010517          	auipc	a0,0x10
    800009d8:	01450513          	addi	a0,a0,20 # 800109e8 <kref>
    800009dc:	80b1                	srli	s1,s1,0xc
    800009de:	0491                	addi	s1,s1,4
    800009e0:	048a                	slli	s1,s1,0x2
    800009e2:	94aa                	add	s1,s1,a0
    800009e4:	4484                	lw	s1,8(s1)
  release(&kref.lock);
    800009e6:	362000ef          	jal	ra,80000d48 <release>
  return n;
}
    800009ea:	8526                	mv	a0,s1
    800009ec:	60e2                	ld	ra,24(sp)
    800009ee:	6442                	ld	s0,16(sp)
    800009f0:	64a2                	ld	s1,8(sp)
    800009f2:	6105                	addi	sp,sp,32
    800009f4:	8082                	ret

00000000800009f6 <kref_inc>:
 *   - 当物理页被多个进程共享时（如COW机制）
 *   - 当物理页被共享内存对象引用时
 *   - 任何需要延长物理页生命周期的场景
 */
int             
kref_inc(void *pa){
    800009f6:	1101                	addi	sp,sp,-32
    800009f8:	ec06                	sd	ra,24(sp)
    800009fa:	e822                	sd	s0,16(sp)
    800009fc:	e426                	sd	s1,8(sp)
    800009fe:	1000                	addi	s0,sp,32
    80000a00:	84aa                	mv	s1,a0
  int n;
  acquire(&kref.lock);
    80000a02:	00010517          	auipc	a0,0x10
    80000a06:	fe650513          	addi	a0,a0,-26 # 800109e8 <kref>
    80000a0a:	2a6000ef          	jal	ra,80000cb0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0e:	00c4d793          	srli	a5,s1,0xc
    80000a12:	00010517          	auipc	a0,0x10
    80000a16:	fd650513          	addi	a0,a0,-42 # 800109e8 <kref>
    80000a1a:	0791                	addi	a5,a5,4
    80000a1c:	078a                	slli	a5,a5,0x2
    80000a1e:	97aa                	add	a5,a5,a0
    80000a20:	4798                	lw	a4,8(a5)
    80000a22:	2705                	addiw	a4,a4,1
    80000a24:	0007049b          	sext.w	s1,a4
    80000a28:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000a2a:	31e000ef          	jal	ra,80000d48 <release>
  return n;
}
    80000a2e:	8526                	mv	a0,s1
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6105                	addi	sp,sp,32
    80000a38:	8082                	ret

0000000080000a3a <kref_dec>:
 * 注意：
 *   - 当引用计数减为0时，调用者应负责释放该物理页
 *   - 操作过程中会获取kref锁以保证线程安全
 */
int            
kref_dec(void *pa){
    80000a3a:	1101                	addi	sp,sp,-32
    80000a3c:	ec06                	sd	ra,24(sp)
    80000a3e:	e822                	sd	s0,16(sp)
    80000a40:	e426                	sd	s1,8(sp)
    80000a42:	1000                	addi	s0,sp,32
    80000a44:	84aa                	mv	s1,a0
  int n;
  acquire(&kref.lock);
    80000a46:	00010517          	auipc	a0,0x10
    80000a4a:	fa250513          	addi	a0,a0,-94 # 800109e8 <kref>
    80000a4e:	262000ef          	jal	ra,80000cb0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a52:	00c4d793          	srli	a5,s1,0xc
    80000a56:	00010517          	auipc	a0,0x10
    80000a5a:	f9250513          	addi	a0,a0,-110 # 800109e8 <kref>
    80000a5e:	0791                	addi	a5,a5,4
    80000a60:	078a                	slli	a5,a5,0x2
    80000a62:	97aa                	add	a5,a5,a0
    80000a64:	4798                	lw	a4,8(a5)
    80000a66:	377d                	addiw	a4,a4,-1
    80000a68:	0007049b          	sext.w	s1,a4
    80000a6c:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000a6e:	2da000ef          	jal	ra,80000d48 <release>
  return n;
}
    80000a72:	8526                	mv	a0,s1
    80000a74:	60e2                	ld	ra,24(sp)
    80000a76:	6442                	ld	s0,16(sp)
    80000a78:	64a2                	ld	s1,8(sp)
    80000a7a:	6105                	addi	sp,sp,32
    80000a7c:	8082                	ret

0000000080000a7e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a7e:	1101                	addi	sp,sp,-32
    80000a80:	ec06                	sd	ra,24(sp)
    80000a82:	e822                	sd	s0,16(sp)
    80000a84:	e426                	sd	s1,8(sp)
    80000a86:	e04a                	sd	s2,0(sp)
    80000a88:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a8a:	03451793          	slli	a5,a0,0x34
    80000a8e:	e795                	bnez	a5,80000aba <kfree+0x3c>
    80000a90:	84aa                	mv	s1,a0
    80000a92:	00253797          	auipc	a5,0x253
    80000a96:	75e78793          	addi	a5,a5,1886 # 802541f0 <end>
    80000a9a:	02f56063          	bltu	a0,a5,80000aba <kfree+0x3c>
    80000a9e:	47c5                	li	a5,17
    80000aa0:	07ee                	slli	a5,a5,0x1b
    80000aa2:	00f57c63          	bgeu	a0,a5,80000aba <kfree+0x3c>
   * 检查引用计数，决定是否真正释放物理页
   * 
   * 如果减少引用计数后仍大于0，说明还有其他进程或组件在使用该页
   * 此时不释放物理页，直接返回
   */
  if(kref_dec(pa) > 0)
    80000aa6:	f95ff0ef          	jal	ra,80000a3a <kref_dec>
    80000aaa:	00a05e63          	blez	a0,80000ac6 <kfree+0x48>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000aae:	60e2                	ld	ra,24(sp)
    80000ab0:	6442                	ld	s0,16(sp)
    80000ab2:	64a2                	ld	s1,8(sp)
    80000ab4:	6902                	ld	s2,0(sp)
    80000ab6:	6105                	addi	sp,sp,32
    80000ab8:	8082                	ret
    panic("kfree");
    80000aba:	00007517          	auipc	a0,0x7
    80000abe:	59e50513          	addi	a0,a0,1438 # 80008058 <digits+0x20>
    80000ac2:	cc9ff0ef          	jal	ra,8000078a <panic>
  memset(pa, 1, PGSIZE);
    80000ac6:	6605                	lui	a2,0x1
    80000ac8:	4585                	li	a1,1
    80000aca:	8526                	mv	a0,s1
    80000acc:	2b8000ef          	jal	ra,80000d84 <memset>
  acquire(&kmem.lock);
    80000ad0:	00010917          	auipc	s2,0x10
    80000ad4:	ef890913          	addi	s2,s2,-264 # 800109c8 <kmem>
    80000ad8:	854a                	mv	a0,s2
    80000ada:	1d6000ef          	jal	ra,80000cb0 <acquire>
  r->next = kmem.freelist;
    80000ade:	01893783          	ld	a5,24(s2)
    80000ae2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ae4:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ae8:	854a                	mv	a0,s2
    80000aea:	25e000ef          	jal	ra,80000d48 <release>
    80000aee:	b7c1                	j	80000aae <kfree+0x30>

0000000080000af0 <freerange>:
{
    80000af0:	7139                	addi	sp,sp,-64
    80000af2:	fc06                	sd	ra,56(sp)
    80000af4:	f822                	sd	s0,48(sp)
    80000af6:	f426                	sd	s1,40(sp)
    80000af8:	f04a                	sd	s2,32(sp)
    80000afa:	ec4e                	sd	s3,24(sp)
    80000afc:	e852                	sd	s4,16(sp)
    80000afe:	e456                	sd	s5,8(sp)
    80000b00:	e05a                	sd	s6,0(sp)
    80000b02:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b04:	6785                	lui	a5,0x1
    80000b06:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b0a:	9526                	add	a0,a0,s1
    80000b0c:	74fd                	lui	s1,0xfffff
    80000b0e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b10:	97a6                	add	a5,a5,s1
    80000b12:	02f5ef63          	bltu	a1,a5,80000b50 <freerange+0x60>
    80000b16:	89ae                	mv	s3,a1
    acquire(&kref.lock);
    80000b18:	00010917          	auipc	s2,0x10
    80000b1c:	ed090913          	addi	s2,s2,-304 # 800109e8 <kref>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b20:	4b05                	li	s6,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b22:	6a85                	lui	s5,0x1
    80000b24:	6a09                	lui	s4,0x2
    acquire(&kref.lock);
    80000b26:	854a                	mv	a0,s2
    80000b28:	188000ef          	jal	ra,80000cb0 <acquire>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b2c:	00c4d793          	srli	a5,s1,0xc
    80000b30:	0791                	addi	a5,a5,4
    80000b32:	078a                	slli	a5,a5,0x2
    80000b34:	97ca                	add	a5,a5,s2
    80000b36:	0167a423          	sw	s6,8(a5)
    release(&kref.lock);
    80000b3a:	854a                	mv	a0,s2
    80000b3c:	20c000ef          	jal	ra,80000d48 <release>
    kfree(p);
    80000b40:	8526                	mv	a0,s1
    80000b42:	f3dff0ef          	jal	ra,80000a7e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b46:	87a6                	mv	a5,s1
    80000b48:	94d6                	add	s1,s1,s5
    80000b4a:	97d2                	add	a5,a5,s4
    80000b4c:	fcf9fde3          	bgeu	s3,a5,80000b26 <freerange+0x36>
}
    80000b50:	70e2                	ld	ra,56(sp)
    80000b52:	7442                	ld	s0,48(sp)
    80000b54:	74a2                	ld	s1,40(sp)
    80000b56:	7902                	ld	s2,32(sp)
    80000b58:	69e2                	ld	s3,24(sp)
    80000b5a:	6a42                	ld	s4,16(sp)
    80000b5c:	6aa2                	ld	s5,8(sp)
    80000b5e:	6b02                	ld	s6,0(sp)
    80000b60:	6121                	addi	sp,sp,64
    80000b62:	8082                	ret

0000000080000b64 <kinit>:
{
    80000b64:	1141                	addi	sp,sp,-16
    80000b66:	e406                	sd	ra,8(sp)
    80000b68:	e022                	sd	s0,0(sp)
    80000b6a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b6c:	00007597          	auipc	a1,0x7
    80000b70:	4f458593          	addi	a1,a1,1268 # 80008060 <digits+0x28>
    80000b74:	00010517          	auipc	a0,0x10
    80000b78:	e5450513          	addi	a0,a0,-428 # 800109c8 <kmem>
    80000b7c:	0b4000ef          	jal	ra,80000c30 <initlock>
  initlock(&kref.lock, "kref");
    80000b80:	00007597          	auipc	a1,0x7
    80000b84:	4e858593          	addi	a1,a1,1256 # 80008068 <digits+0x30>
    80000b88:	00010517          	auipc	a0,0x10
    80000b8c:	e6050513          	addi	a0,a0,-416 # 800109e8 <kref>
    80000b90:	0a0000ef          	jal	ra,80000c30 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b94:	45c5                	li	a1,17
    80000b96:	05ee                	slli	a1,a1,0x1b
    80000b98:	00253517          	auipc	a0,0x253
    80000b9c:	65850513          	addi	a0,a0,1624 # 802541f0 <end>
    80000ba0:	f51ff0ef          	jal	ra,80000af0 <freerange>
}
    80000ba4:	60a2                	ld	ra,8(sp)
    80000ba6:	6402                	ld	s0,0(sp)
    80000ba8:	0141                	addi	sp,sp,16
    80000baa:	8082                	ret

0000000080000bac <kalloc>:
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.

void *
kalloc(void)
{
    80000bac:	1101                	addi	sp,sp,-32
    80000bae:	ec06                	sd	ra,24(sp)
    80000bb0:	e822                	sd	s0,16(sp)
    80000bb2:	e426                	sd	s1,8(sp)
    80000bb4:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bb6:	00010497          	auipc	s1,0x10
    80000bba:	e1248493          	addi	s1,s1,-494 # 800109c8 <kmem>
    80000bbe:	8526                	mv	a0,s1
    80000bc0:	0f0000ef          	jal	ra,80000cb0 <acquire>
  r = kmem.freelist;
    80000bc4:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc6:	ccb1                	beqz	s1,80000c22 <kalloc+0x76>
    kmem.freelist = r->next;
    80000bc8:	609c                	ld	a5,0(s1)
    80000bca:	00010517          	auipc	a0,0x10
    80000bce:	dfe50513          	addi	a0,a0,-514 # 800109c8 <kmem>
    80000bd2:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bd4:	174000ef          	jal	ra,80000d48 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bd8:	6605                	lui	a2,0x1
    80000bda:	4595                	li	a1,5
    80000bdc:	8526                	mv	a0,s1
    80000bde:	1a6000ef          	jal	ra,80000d84 <memset>
   * 初始化新分配页的引用计数
   * 
   * 新分配的物理页默认引用计数为1，表示被当前调用者拥有
   */
  if(r){
    acquire(&kref.lock);
    80000be2:	00010517          	auipc	a0,0x10
    80000be6:	e0650513          	addi	a0,a0,-506 # 800109e8 <kref>
    80000bea:	0c6000ef          	jal	ra,80000cb0 <acquire>
    kref.refcnt[PA2IDX(r)] = 1;
    80000bee:	00010517          	auipc	a0,0x10
    80000bf2:	dfa50513          	addi	a0,a0,-518 # 800109e8 <kref>
    80000bf6:	00c4d793          	srli	a5,s1,0xc
    80000bfa:	0791                	addi	a5,a5,4
    80000bfc:	078a                	slli	a5,a5,0x2
    80000bfe:	97aa                	add	a5,a5,a0
    80000c00:	4705                	li	a4,1
    80000c02:	c798                	sw	a4,8(a5)
    release(&kref.lock);
    80000c04:	144000ef          	jal	ra,80000d48 <release>
  }
  extern uint64 kalloc_cnt;
  kalloc_cnt++;
    80000c08:	00008717          	auipc	a4,0x8
    80000c0c:	cd870713          	addi	a4,a4,-808 # 800088e0 <kalloc_cnt>
    80000c10:	631c                	ld	a5,0(a4)
    80000c12:	0785                	addi	a5,a5,1
    80000c14:	e31c                	sd	a5,0(a4)


  return (void*)r;
}
    80000c16:	8526                	mv	a0,s1
    80000c18:	60e2                	ld	ra,24(sp)
    80000c1a:	6442                	ld	s0,16(sp)
    80000c1c:	64a2                	ld	s1,8(sp)
    80000c1e:	6105                	addi	sp,sp,32
    80000c20:	8082                	ret
  release(&kmem.lock);
    80000c22:	00010517          	auipc	a0,0x10
    80000c26:	da650513          	addi	a0,a0,-602 # 800109c8 <kmem>
    80000c2a:	11e000ef          	jal	ra,80000d48 <release>
  if(r){
    80000c2e:	bfe9                	j	80000c08 <kalloc+0x5c>

0000000080000c30 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c30:	1141                	addi	sp,sp,-16
    80000c32:	e422                	sd	s0,8(sp)
    80000c34:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c36:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c38:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c3c:	00053823          	sd	zero,16(a0)
}
    80000c40:	6422                	ld	s0,8(sp)
    80000c42:	0141                	addi	sp,sp,16
    80000c44:	8082                	ret

0000000080000c46 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c46:	411c                	lw	a5,0(a0)
    80000c48:	e399                	bnez	a5,80000c4e <holding+0x8>
    80000c4a:	4501                	li	a0,0
  return r;
}
    80000c4c:	8082                	ret
{
    80000c4e:	1101                	addi	sp,sp,-32
    80000c50:	ec06                	sd	ra,24(sp)
    80000c52:	e822                	sd	s0,16(sp)
    80000c54:	e426                	sd	s1,8(sp)
    80000c56:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c58:	6904                	ld	s1,16(a0)
    80000c5a:	725000ef          	jal	ra,80001b7e <mycpu>
    80000c5e:	40a48533          	sub	a0,s1,a0
    80000c62:	00153513          	seqz	a0,a0
}
    80000c66:	60e2                	ld	ra,24(sp)
    80000c68:	6442                	ld	s0,16(sp)
    80000c6a:	64a2                	ld	s1,8(sp)
    80000c6c:	6105                	addi	sp,sp,32
    80000c6e:	8082                	ret

0000000080000c70 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c70:	1101                	addi	sp,sp,-32
    80000c72:	ec06                	sd	ra,24(sp)
    80000c74:	e822                	sd	s0,16(sp)
    80000c76:	e426                	sd	s1,8(sp)
    80000c78:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7a:	100024f3          	csrr	s1,sstatus
    80000c7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c82:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c84:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c88:	6f7000ef          	jal	ra,80001b7e <mycpu>
    80000c8c:	5d3c                	lw	a5,120(a0)
    80000c8e:	cb99                	beqz	a5,80000ca4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c90:	6ef000ef          	jal	ra,80001b7e <mycpu>
    80000c94:	5d3c                	lw	a5,120(a0)
    80000c96:	2785                	addiw	a5,a5,1
    80000c98:	dd3c                	sw	a5,120(a0)
}
    80000c9a:	60e2                	ld	ra,24(sp)
    80000c9c:	6442                	ld	s0,16(sp)
    80000c9e:	64a2                	ld	s1,8(sp)
    80000ca0:	6105                	addi	sp,sp,32
    80000ca2:	8082                	ret
    mycpu()->intena = old;
    80000ca4:	6db000ef          	jal	ra,80001b7e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ca8:	8085                	srli	s1,s1,0x1
    80000caa:	8885                	andi	s1,s1,1
    80000cac:	dd64                	sw	s1,124(a0)
    80000cae:	b7cd                	j	80000c90 <push_off+0x20>

0000000080000cb0 <acquire>:
{
    80000cb0:	1101                	addi	sp,sp,-32
    80000cb2:	ec06                	sd	ra,24(sp)
    80000cb4:	e822                	sd	s0,16(sp)
    80000cb6:	e426                	sd	s1,8(sp)
    80000cb8:	1000                	addi	s0,sp,32
    80000cba:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cbc:	fb5ff0ef          	jal	ra,80000c70 <push_off>
  if(holding(lk))
    80000cc0:	8526                	mv	a0,s1
    80000cc2:	f85ff0ef          	jal	ra,80000c46 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cc6:	4705                	li	a4,1
  if(holding(lk))
    80000cc8:	e105                	bnez	a0,80000ce8 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cca:	87ba                	mv	a5,a4
    80000ccc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cd0:	2781                	sext.w	a5,a5
    80000cd2:	ffe5                	bnez	a5,80000cca <acquire+0x1a>
  __sync_synchronize();
    80000cd4:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cd8:	6a7000ef          	jal	ra,80001b7e <mycpu>
    80000cdc:	e888                	sd	a0,16(s1)
}
    80000cde:	60e2                	ld	ra,24(sp)
    80000ce0:	6442                	ld	s0,16(sp)
    80000ce2:	64a2                	ld	s1,8(sp)
    80000ce4:	6105                	addi	sp,sp,32
    80000ce6:	8082                	ret
    panic("acquire");
    80000ce8:	00007517          	auipc	a0,0x7
    80000cec:	38850513          	addi	a0,a0,904 # 80008070 <digits+0x38>
    80000cf0:	a9bff0ef          	jal	ra,8000078a <panic>

0000000080000cf4 <pop_off>:

void
pop_off(void)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e406                	sd	ra,8(sp)
    80000cf8:	e022                	sd	s0,0(sp)
    80000cfa:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cfc:	683000ef          	jal	ra,80001b7e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d04:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d06:	e78d                	bnez	a5,80000d30 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d08:	5d3c                	lw	a5,120(a0)
    80000d0a:	02f05963          	blez	a5,80000d3c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000d0e:	37fd                	addiw	a5,a5,-1
    80000d10:	0007871b          	sext.w	a4,a5
    80000d14:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d16:	eb09                	bnez	a4,80000d28 <pop_off+0x34>
    80000d18:	5d7c                	lw	a5,124(a0)
    80000d1a:	c799                	beqz	a5,80000d28 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d20:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d24:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d28:	60a2                	ld	ra,8(sp)
    80000d2a:	6402                	ld	s0,0(sp)
    80000d2c:	0141                	addi	sp,sp,16
    80000d2e:	8082                	ret
    panic("pop_off - interruptible");
    80000d30:	00007517          	auipc	a0,0x7
    80000d34:	34850513          	addi	a0,a0,840 # 80008078 <digits+0x40>
    80000d38:	a53ff0ef          	jal	ra,8000078a <panic>
    panic("pop_off");
    80000d3c:	00007517          	auipc	a0,0x7
    80000d40:	35450513          	addi	a0,a0,852 # 80008090 <digits+0x58>
    80000d44:	a47ff0ef          	jal	ra,8000078a <panic>

0000000080000d48 <release>:
{
    80000d48:	1101                	addi	sp,sp,-32
    80000d4a:	ec06                	sd	ra,24(sp)
    80000d4c:	e822                	sd	s0,16(sp)
    80000d4e:	e426                	sd	s1,8(sp)
    80000d50:	1000                	addi	s0,sp,32
    80000d52:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d54:	ef3ff0ef          	jal	ra,80000c46 <holding>
    80000d58:	c105                	beqz	a0,80000d78 <release+0x30>
  lk->cpu = 0;
    80000d5a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d5e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d62:	0f50000f          	fence	iorw,ow
    80000d66:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d6a:	f8bff0ef          	jal	ra,80000cf4 <pop_off>
}
    80000d6e:	60e2                	ld	ra,24(sp)
    80000d70:	6442                	ld	s0,16(sp)
    80000d72:	64a2                	ld	s1,8(sp)
    80000d74:	6105                	addi	sp,sp,32
    80000d76:	8082                	ret
    panic("release");
    80000d78:	00007517          	auipc	a0,0x7
    80000d7c:	32050513          	addi	a0,a0,800 # 80008098 <digits+0x60>
    80000d80:	a0bff0ef          	jal	ra,8000078a <panic>

0000000080000d84 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e422                	sd	s0,8(sp)
    80000d88:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d8a:	ca19                	beqz	a2,80000da0 <memset+0x1c>
    80000d8c:	87aa                	mv	a5,a0
    80000d8e:	1602                	slli	a2,a2,0x20
    80000d90:	9201                	srli	a2,a2,0x20
    80000d92:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d96:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d9a:	0785                	addi	a5,a5,1
    80000d9c:	fee79de3          	bne	a5,a4,80000d96 <memset+0x12>
  }
  return dst;
}
    80000da0:	6422                	ld	s0,8(sp)
    80000da2:	0141                	addi	sp,sp,16
    80000da4:	8082                	ret

0000000080000da6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e422                	sd	s0,8(sp)
    80000daa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dac:	ca05                	beqz	a2,80000ddc <memcmp+0x36>
    80000dae:	fff6069b          	addiw	a3,a2,-1
    80000db2:	1682                	slli	a3,a3,0x20
    80000db4:	9281                	srli	a3,a3,0x20
    80000db6:	0685                	addi	a3,a3,1
    80000db8:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dba:	00054783          	lbu	a5,0(a0)
    80000dbe:	0005c703          	lbu	a4,0(a1)
    80000dc2:	00e79863          	bne	a5,a4,80000dd2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dc6:	0505                	addi	a0,a0,1
    80000dc8:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dca:	fed518e3          	bne	a0,a3,80000dba <memcmp+0x14>
  }

  return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	a019                	j	80000dd6 <memcmp+0x30>
      return *s1 - *s2;
    80000dd2:	40e7853b          	subw	a0,a5,a4
}
    80000dd6:	6422                	ld	s0,8(sp)
    80000dd8:	0141                	addi	sp,sp,16
    80000dda:	8082                	ret
  return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	bfe5                	j	80000dd6 <memcmp+0x30>

0000000080000de0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000de6:	c205                	beqz	a2,80000e06 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000de8:	02a5e263          	bltu	a1,a0,80000e0c <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dec:	1602                	slli	a2,a2,0x20
    80000dee:	9201                	srli	a2,a2,0x20
    80000df0:	00c587b3          	add	a5,a1,a2
{
    80000df4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000df6:	0585                	addi	a1,a1,1
    80000df8:	0705                	addi	a4,a4,1
    80000dfa:	fff5c683          	lbu	a3,-1(a1)
    80000dfe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e02:	fef59ae3          	bne	a1,a5,80000df6 <memmove+0x16>

  return dst;
}
    80000e06:	6422                	ld	s0,8(sp)
    80000e08:	0141                	addi	sp,sp,16
    80000e0a:	8082                	ret
  if(s < d && s + n > d){
    80000e0c:	02061693          	slli	a3,a2,0x20
    80000e10:	9281                	srli	a3,a3,0x20
    80000e12:	00d58733          	add	a4,a1,a3
    80000e16:	fce57be3          	bgeu	a0,a4,80000dec <memmove+0xc>
    d += n;
    80000e1a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e1c:	fff6079b          	addiw	a5,a2,-1
    80000e20:	1782                	slli	a5,a5,0x20
    80000e22:	9381                	srli	a5,a5,0x20
    80000e24:	fff7c793          	not	a5,a5
    80000e28:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e2a:	177d                	addi	a4,a4,-1
    80000e2c:	16fd                	addi	a3,a3,-1
    80000e2e:	00074603          	lbu	a2,0(a4)
    80000e32:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e36:	fee79ae3          	bne	a5,a4,80000e2a <memmove+0x4a>
    80000e3a:	b7f1                	j	80000e06 <memmove+0x26>

0000000080000e3c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e44:	f9dff0ef          	jal	ra,80000de0 <memmove>
}
    80000e48:	60a2                	ld	ra,8(sp)
    80000e4a:	6402                	ld	s0,0(sp)
    80000e4c:	0141                	addi	sp,sp,16
    80000e4e:	8082                	ret

0000000080000e50 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e50:	1141                	addi	sp,sp,-16
    80000e52:	e422                	sd	s0,8(sp)
    80000e54:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e56:	ce11                	beqz	a2,80000e72 <strncmp+0x22>
    80000e58:	00054783          	lbu	a5,0(a0)
    80000e5c:	cf89                	beqz	a5,80000e76 <strncmp+0x26>
    80000e5e:	0005c703          	lbu	a4,0(a1)
    80000e62:	00f71a63          	bne	a4,a5,80000e76 <strncmp+0x26>
    n--, p++, q++;
    80000e66:	367d                	addiw	a2,a2,-1
    80000e68:	0505                	addi	a0,a0,1
    80000e6a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e6c:	f675                	bnez	a2,80000e58 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e6e:	4501                	li	a0,0
    80000e70:	a809                	j	80000e82 <strncmp+0x32>
    80000e72:	4501                	li	a0,0
    80000e74:	a039                	j	80000e82 <strncmp+0x32>
  if(n == 0)
    80000e76:	ca09                	beqz	a2,80000e88 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e78:	00054503          	lbu	a0,0(a0)
    80000e7c:	0005c783          	lbu	a5,0(a1)
    80000e80:	9d1d                	subw	a0,a0,a5
}
    80000e82:	6422                	ld	s0,8(sp)
    80000e84:	0141                	addi	sp,sp,16
    80000e86:	8082                	ret
    return 0;
    80000e88:	4501                	li	a0,0
    80000e8a:	bfe5                	j	80000e82 <strncmp+0x32>

0000000080000e8c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e422                	sd	s0,8(sp)
    80000e90:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e92:	872a                	mv	a4,a0
    80000e94:	8832                	mv	a6,a2
    80000e96:	367d                	addiw	a2,a2,-1
    80000e98:	01005963          	blez	a6,80000eaa <strncpy+0x1e>
    80000e9c:	0705                	addi	a4,a4,1
    80000e9e:	0005c783          	lbu	a5,0(a1)
    80000ea2:	fef70fa3          	sb	a5,-1(a4)
    80000ea6:	0585                	addi	a1,a1,1
    80000ea8:	f7f5                	bnez	a5,80000e94 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000eaa:	86ba                	mv	a3,a4
    80000eac:	00c05c63          	blez	a2,80000ec4 <strncpy+0x38>
    *s++ = 0;
    80000eb0:	0685                	addi	a3,a3,1
    80000eb2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000eb6:	fff6c793          	not	a5,a3
    80000eba:	9fb9                	addw	a5,a5,a4
    80000ebc:	010787bb          	addw	a5,a5,a6
    80000ec0:	fef048e3          	bgtz	a5,80000eb0 <strncpy+0x24>
  return os;
}
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e422                	sd	s0,8(sp)
    80000ece:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ed0:	02c05363          	blez	a2,80000ef6 <safestrcpy+0x2c>
    80000ed4:	fff6069b          	addiw	a3,a2,-1
    80000ed8:	1682                	slli	a3,a3,0x20
    80000eda:	9281                	srli	a3,a3,0x20
    80000edc:	96ae                	add	a3,a3,a1
    80000ede:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ee0:	00d58963          	beq	a1,a3,80000ef2 <safestrcpy+0x28>
    80000ee4:	0585                	addi	a1,a1,1
    80000ee6:	0785                	addi	a5,a5,1
    80000ee8:	fff5c703          	lbu	a4,-1(a1)
    80000eec:	fee78fa3          	sb	a4,-1(a5)
    80000ef0:	fb65                	bnez	a4,80000ee0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ef2:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ef6:	6422                	ld	s0,8(sp)
    80000ef8:	0141                	addi	sp,sp,16
    80000efa:	8082                	ret

0000000080000efc <strlen>:

int
strlen(const char *s)
{
    80000efc:	1141                	addi	sp,sp,-16
    80000efe:	e422                	sd	s0,8(sp)
    80000f00:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f02:	00054783          	lbu	a5,0(a0)
    80000f06:	cf91                	beqz	a5,80000f22 <strlen+0x26>
    80000f08:	0505                	addi	a0,a0,1
    80000f0a:	87aa                	mv	a5,a0
    80000f0c:	4685                	li	a3,1
    80000f0e:	9e89                	subw	a3,a3,a0
    80000f10:	00f6853b          	addw	a0,a3,a5
    80000f14:	0785                	addi	a5,a5,1
    80000f16:	fff7c703          	lbu	a4,-1(a5)
    80000f1a:	fb7d                	bnez	a4,80000f10 <strlen+0x14>
    ;
  return n;
}
    80000f1c:	6422                	ld	s0,8(sp)
    80000f1e:	0141                	addi	sp,sp,16
    80000f20:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f22:	4501                	li	a0,0
    80000f24:	bfe5                	j	80000f1c <strlen+0x20>

0000000080000f26 <main>:
 * - 其他CPU等待初始化完成后启动
 * - 所有CPU最终都进入调度器
 */
void
main()
{
    80000f26:	1141                	addi	sp,sp,-16
    80000f28:	e406                	sd	ra,8(sp)
    80000f2a:	e022                	sd	s0,0(sp)
    80000f2c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f2e:	441000ef          	jal	ra,80001b6e <cpuid>
    seminit();

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f32:	00008717          	auipc	a4,0x8
    80000f36:	97e70713          	addi	a4,a4,-1666 # 800088b0 <started>
  if(cpuid() == 0){
    80000f3a:	c51d                	beqz	a0,80000f68 <main+0x42>
    while(started == 0)
    80000f3c:	431c                	lw	a5,0(a4)
    80000f3e:	2781                	sext.w	a5,a5
    80000f40:	dff5                	beqz	a5,80000f3c <main+0x16>
      ;
    __sync_synchronize();
    80000f42:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f46:	429000ef          	jal	ra,80001b6e <cpuid>
    80000f4a:	85aa                	mv	a1,a0
    80000f4c:	00007517          	auipc	a0,0x7
    80000f50:	16c50513          	addi	a0,a0,364 # 800080b8 <digits+0x80>
    80000f54:	d70ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000f58:	08c000ef          	jal	ra,80000fe4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f5c:	257010ef          	jal	ra,800029b2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f60:	0c4050ef          	jal	ra,80006024 <plicinithart>
  }

  scheduler();        
    80000f64:	396010ef          	jal	ra,800022fa <scheduler>
    consoleinit();
    80000f68:	c84ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000f6c:	85bff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000f70:	00007517          	auipc	a0,0x7
    80000f74:	15850513          	addi	a0,a0,344 # 800080c8 <digits+0x90>
    80000f78:	d4cff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000f7c:	00007517          	auipc	a0,0x7
    80000f80:	12450513          	addi	a0,a0,292 # 800080a0 <digits+0x68>
    80000f84:	d40ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000f88:	00007517          	auipc	a0,0x7
    80000f8c:	14050513          	addi	a0,a0,320 # 800080c8 <digits+0x90>
    80000f90:	d34ff0ef          	jal	ra,800004c4 <printf>
    vmstatsinit();
    80000f94:	543050ef          	jal	ra,80006cd6 <vmstatsinit>
    kinit();         // physical page allocator
    80000f98:	bcdff0ef          	jal	ra,80000b64 <kinit>
    kvminit();       // create kernel page table
    80000f9c:	2d2000ef          	jal	ra,8000126e <kvminit>
    kvminithart();   // turn on paging
    80000fa0:	044000ef          	jal	ra,80000fe4 <kvminithart>
    procinit();      // process table
    80000fa4:	323000ef          	jal	ra,80001ac6 <procinit>
    trapinit();      // trap vectors
    80000fa8:	1e7010ef          	jal	ra,8000298e <trapinit>
    trapinithart();  // install kernel trap vector
    80000fac:	207010ef          	jal	ra,800029b2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fb0:	05e050ef          	jal	ra,8000600e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fb4:	070050ef          	jal	ra,80006024 <plicinithart>
    binit();         // buffer cache
    80000fb8:	7a6020ef          	jal	ra,8000375e <binit>
    iinit();         // inode table
    80000fbc:	51b020ef          	jal	ra,80003cd6 <iinit>
    fileinit();      // file table
    80000fc0:	3fb030ef          	jal	ra,80004bba <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc4:	150050ef          	jal	ra,80006114 <virtio_disk_init>
    userinit();      // first user process
    80000fc8:	0f6010ef          	jal	ra,800020be <userinit>
    shm_init();
    80000fcc:	5c0050ef          	jal	ra,8000658c <shm_init>
    seminit();
    80000fd0:	2c9050ef          	jal	ra,80006a98 <seminit>
    __sync_synchronize();
    80000fd4:	0ff0000f          	fence
    started = 1;
    80000fd8:	4785                	li	a5,1
    80000fda:	00008717          	auipc	a4,0x8
    80000fde:	8cf72b23          	sw	a5,-1834(a4) # 800088b0 <started>
    80000fe2:	b749                	j	80000f64 <main+0x3e>

0000000080000fe4 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000fe4:	1141                	addi	sp,sp,-16
    80000fe6:	e422                	sd	s0,8(sp)
    80000fe8:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fea:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fee:	00008797          	auipc	a5,0x8
    80000ff2:	8ca7b783          	ld	a5,-1846(a5) # 800088b8 <kernel_pagetable>
    80000ff6:	83b1                	srli	a5,a5,0xc
    80000ff8:	577d                	li	a4,-1
    80000ffa:	177e                	slli	a4,a4,0x3f
    80000ffc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ffe:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001002:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001006:	6422                	ld	s0,8(sp)
    80001008:	0141                	addi	sp,sp,16
    8000100a:	8082                	ret

000000008000100c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000100c:	7139                	addi	sp,sp,-64
    8000100e:	fc06                	sd	ra,56(sp)
    80001010:	f822                	sd	s0,48(sp)
    80001012:	f426                	sd	s1,40(sp)
    80001014:	f04a                	sd	s2,32(sp)
    80001016:	ec4e                	sd	s3,24(sp)
    80001018:	e852                	sd	s4,16(sp)
    8000101a:	e456                	sd	s5,8(sp)
    8000101c:	e05a                	sd	s6,0(sp)
    8000101e:	0080                	addi	s0,sp,64
    80001020:	84aa                	mv	s1,a0
    80001022:	89ae                	mv	s3,a1
    80001024:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000102c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000102e:	02b7fc63          	bgeu	a5,a1,80001066 <walk+0x5a>
    panic("walk");
    80001032:	00007517          	auipc	a0,0x7
    80001036:	09e50513          	addi	a0,a0,158 # 800080d0 <digits+0x98>
    8000103a:	f50ff0ef          	jal	ra,8000078a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000103e:	060a8263          	beqz	s5,800010a2 <walk+0x96>
    80001042:	b6bff0ef          	jal	ra,80000bac <kalloc>
    80001046:	84aa                	mv	s1,a0
    80001048:	c139                	beqz	a0,8000108e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000104a:	6605                	lui	a2,0x1
    8000104c:	4581                	li	a1,0
    8000104e:	d37ff0ef          	jal	ra,80000d84 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001052:	00c4d793          	srli	a5,s1,0xc
    80001056:	07aa                	slli	a5,a5,0xa
    80001058:	0017e793          	ori	a5,a5,1
    8000105c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001060:	3a5d                	addiw	s4,s4,-9
    80001062:	036a0063          	beq	s4,s6,80001082 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001066:	0149d933          	srl	s2,s3,s4
    8000106a:	1ff97913          	andi	s2,s2,511
    8000106e:	090e                	slli	s2,s2,0x3
    80001070:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001072:	00093483          	ld	s1,0(s2)
    80001076:	0014f793          	andi	a5,s1,1
    8000107a:	d3f1                	beqz	a5,8000103e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000107c:	80a9                	srli	s1,s1,0xa
    8000107e:	04b2                	slli	s1,s1,0xc
    80001080:	b7c5                	j	80001060 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001082:	00c9d513          	srli	a0,s3,0xc
    80001086:	1ff57513          	andi	a0,a0,511
    8000108a:	050e                	slli	a0,a0,0x3
    8000108c:	9526                	add	a0,a0,s1
}
    8000108e:	70e2                	ld	ra,56(sp)
    80001090:	7442                	ld	s0,48(sp)
    80001092:	74a2                	ld	s1,40(sp)
    80001094:	7902                	ld	s2,32(sp)
    80001096:	69e2                	ld	s3,24(sp)
    80001098:	6a42                	ld	s4,16(sp)
    8000109a:	6aa2                	ld	s5,8(sp)
    8000109c:	6b02                	ld	s6,0(sp)
    8000109e:	6121                	addi	sp,sp,64
    800010a0:	8082                	ret
        return 0;
    800010a2:	4501                	li	a0,0
    800010a4:	b7ed                	j	8000108e <walk+0x82>

00000000800010a6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010a6:	57fd                	li	a5,-1
    800010a8:	83e9                	srli	a5,a5,0x1a
    800010aa:	00b7f463          	bgeu	a5,a1,800010b2 <walkaddr+0xc>
    return 0;
    800010ae:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010b0:	8082                	ret
{
    800010b2:	1141                	addi	sp,sp,-16
    800010b4:	e406                	sd	ra,8(sp)
    800010b6:	e022                	sd	s0,0(sp)
    800010b8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ba:	4601                	li	a2,0
    800010bc:	f51ff0ef          	jal	ra,8000100c <walk>
  if(pte == 0)
    800010c0:	c105                	beqz	a0,800010e0 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800010c2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010c4:	0117f693          	andi	a3,a5,17
    800010c8:	4745                	li	a4,17
    return 0;
    800010ca:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010cc:	00e68663          	beq	a3,a4,800010d8 <walkaddr+0x32>
}
    800010d0:	60a2                	ld	ra,8(sp)
    800010d2:	6402                	ld	s0,0(sp)
    800010d4:	0141                	addi	sp,sp,16
    800010d6:	8082                	ret
  pa = PTE2PA(*pte);
    800010d8:	00a7d513          	srli	a0,a5,0xa
    800010dc:	0532                	slli	a0,a0,0xc
  return pa;
    800010de:	bfcd                	j	800010d0 <walkaddr+0x2a>
    return 0;
    800010e0:	4501                	li	a0,0
    800010e2:	b7fd                	j	800010d0 <walkaddr+0x2a>

00000000800010e4 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010e4:	715d                	addi	sp,sp,-80
    800010e6:	e486                	sd	ra,72(sp)
    800010e8:	e0a2                	sd	s0,64(sp)
    800010ea:	fc26                	sd	s1,56(sp)
    800010ec:	f84a                	sd	s2,48(sp)
    800010ee:	f44e                	sd	s3,40(sp)
    800010f0:	f052                	sd	s4,32(sp)
    800010f2:	ec56                	sd	s5,24(sp)
    800010f4:	e85a                	sd	s6,16(sp)
    800010f6:	e45e                	sd	s7,8(sp)
    800010f8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010fa:	03459793          	slli	a5,a1,0x34
    800010fe:	e7a9                	bnez	a5,80001148 <mappages+0x64>
    80001100:	8aaa                	mv	s5,a0
    80001102:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001104:	03461793          	slli	a5,a2,0x34
    80001108:	e7b1                	bnez	a5,80001154 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000110a:	ca39                	beqz	a2,80001160 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000110c:	79fd                	lui	s3,0xfffff
    8000110e:	964e                	add	a2,a2,s3
    80001110:	00b609b3          	add	s3,a2,a1
  a = va;
    80001114:	892e                	mv	s2,a1
    80001116:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000111a:	6b85                	lui	s7,0x1
    8000111c:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001120:	4605                	li	a2,1
    80001122:	85ca                	mv	a1,s2
    80001124:	8556                	mv	a0,s5
    80001126:	ee7ff0ef          	jal	ra,8000100c <walk>
    8000112a:	c539                	beqz	a0,80001178 <mappages+0x94>
    if(*pte & PTE_V)
    8000112c:	611c                	ld	a5,0(a0)
    8000112e:	8b85                	andi	a5,a5,1
    80001130:	ef95                	bnez	a5,8000116c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001132:	80b1                	srli	s1,s1,0xc
    80001134:	04aa                	slli	s1,s1,0xa
    80001136:	0164e4b3          	or	s1,s1,s6
    8000113a:	0014e493          	ori	s1,s1,1
    8000113e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001140:	05390863          	beq	s2,s3,80001190 <mappages+0xac>
    a += PGSIZE;
    80001144:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001146:	bfd9                	j	8000111c <mappages+0x38>
    panic("mappages: va not aligned");
    80001148:	00007517          	auipc	a0,0x7
    8000114c:	f9050513          	addi	a0,a0,-112 # 800080d8 <digits+0xa0>
    80001150:	e3aff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size not aligned");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	fa450513          	addi	a0,a0,-92 # 800080f8 <digits+0xc0>
    8000115c:	e2eff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size");
    80001160:	00007517          	auipc	a0,0x7
    80001164:	fb850513          	addi	a0,a0,-72 # 80008118 <digits+0xe0>
    80001168:	e22ff0ef          	jal	ra,8000078a <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	fbc50513          	addi	a0,a0,-68 # 80008128 <digits+0xf0>
    80001174:	e16ff0ef          	jal	ra,8000078a <panic>
      return -1;
    80001178:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117a:	60a6                	ld	ra,72(sp)
    8000117c:	6406                	ld	s0,64(sp)
    8000117e:	74e2                	ld	s1,56(sp)
    80001180:	7942                	ld	s2,48(sp)
    80001182:	79a2                	ld	s3,40(sp)
    80001184:	7a02                	ld	s4,32(sp)
    80001186:	6ae2                	ld	s5,24(sp)
    80001188:	6b42                	ld	s6,16(sp)
    8000118a:	6ba2                	ld	s7,8(sp)
    8000118c:	6161                	addi	sp,sp,80
    8000118e:	8082                	ret
  return 0;
    80001190:	4501                	li	a0,0
    80001192:	b7e5                	j	8000117a <mappages+0x96>

0000000080001194 <kvmmap>:
{
    80001194:	1141                	addi	sp,sp,-16
    80001196:	e406                	sd	ra,8(sp)
    80001198:	e022                	sd	s0,0(sp)
    8000119a:	0800                	addi	s0,sp,16
    8000119c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000119e:	86b2                	mv	a3,a2
    800011a0:	863e                	mv	a2,a5
    800011a2:	f43ff0ef          	jal	ra,800010e4 <mappages>
    800011a6:	e509                	bnez	a0,800011b0 <kvmmap+0x1c>
}
    800011a8:	60a2                	ld	ra,8(sp)
    800011aa:	6402                	ld	s0,0(sp)
    800011ac:	0141                	addi	sp,sp,16
    800011ae:	8082                	ret
    panic("kvmmap");
    800011b0:	00007517          	auipc	a0,0x7
    800011b4:	f8850513          	addi	a0,a0,-120 # 80008138 <digits+0x100>
    800011b8:	dd2ff0ef          	jal	ra,8000078a <panic>

00000000800011bc <kvmmake>:
{
    800011bc:	1101                	addi	sp,sp,-32
    800011be:	ec06                	sd	ra,24(sp)
    800011c0:	e822                	sd	s0,16(sp)
    800011c2:	e426                	sd	s1,8(sp)
    800011c4:	e04a                	sd	s2,0(sp)
    800011c6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011c8:	9e5ff0ef          	jal	ra,80000bac <kalloc>
    800011cc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011ce:	6605                	lui	a2,0x1
    800011d0:	4581                	li	a1,0
    800011d2:	bb3ff0ef          	jal	ra,80000d84 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011d6:	4719                	li	a4,6
    800011d8:	6685                	lui	a3,0x1
    800011da:	10000637          	lui	a2,0x10000
    800011de:	100005b7          	lui	a1,0x10000
    800011e2:	8526                	mv	a0,s1
    800011e4:	fb1ff0ef          	jal	ra,80001194 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011e8:	4719                	li	a4,6
    800011ea:	6685                	lui	a3,0x1
    800011ec:	10001637          	lui	a2,0x10001
    800011f0:	100015b7          	lui	a1,0x10001
    800011f4:	8526                	mv	a0,s1
    800011f6:	f9fff0ef          	jal	ra,80001194 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011fa:	4719                	li	a4,6
    800011fc:	040006b7          	lui	a3,0x4000
    80001200:	0c000637          	lui	a2,0xc000
    80001204:	0c0005b7          	lui	a1,0xc000
    80001208:	8526                	mv	a0,s1
    8000120a:	f8bff0ef          	jal	ra,80001194 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000120e:	00007917          	auipc	s2,0x7
    80001212:	df290913          	addi	s2,s2,-526 # 80008000 <etext>
    80001216:	4729                	li	a4,10
    80001218:	80007697          	auipc	a3,0x80007
    8000121c:	de868693          	addi	a3,a3,-536 # 8000 <_entry-0x7fff8000>
    80001220:	4605                	li	a2,1
    80001222:	067e                	slli	a2,a2,0x1f
    80001224:	85b2                	mv	a1,a2
    80001226:	8526                	mv	a0,s1
    80001228:	f6dff0ef          	jal	ra,80001194 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000122c:	4719                	li	a4,6
    8000122e:	46c5                	li	a3,17
    80001230:	06ee                	slli	a3,a3,0x1b
    80001232:	412686b3          	sub	a3,a3,s2
    80001236:	864a                	mv	a2,s2
    80001238:	85ca                	mv	a1,s2
    8000123a:	8526                	mv	a0,s1
    8000123c:	f59ff0ef          	jal	ra,80001194 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001240:	4729                	li	a4,10
    80001242:	6685                	lui	a3,0x1
    80001244:	00006617          	auipc	a2,0x6
    80001248:	dbc60613          	addi	a2,a2,-580 # 80007000 <_trampoline>
    8000124c:	040005b7          	lui	a1,0x4000
    80001250:	15fd                	addi	a1,a1,-1
    80001252:	05b2                	slli	a1,a1,0xc
    80001254:	8526                	mv	a0,s1
    80001256:	f3fff0ef          	jal	ra,80001194 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000125a:	8526                	mv	a0,s1
    8000125c:	7e0000ef          	jal	ra,80001a3c <proc_mapstacks>
}
    80001260:	8526                	mv	a0,s1
    80001262:	60e2                	ld	ra,24(sp)
    80001264:	6442                	ld	s0,16(sp)
    80001266:	64a2                	ld	s1,8(sp)
    80001268:	6902                	ld	s2,0(sp)
    8000126a:	6105                	addi	sp,sp,32
    8000126c:	8082                	ret

000000008000126e <kvminit>:
{
    8000126e:	1141                	addi	sp,sp,-16
    80001270:	e406                	sd	ra,8(sp)
    80001272:	e022                	sd	s0,0(sp)
    80001274:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001276:	f47ff0ef          	jal	ra,800011bc <kvmmake>
    8000127a:	00007797          	auipc	a5,0x7
    8000127e:	62a7bf23          	sd	a0,1598(a5) # 800088b8 <kernel_pagetable>
}
    80001282:	60a2                	ld	ra,8(sp)
    80001284:	6402                	ld	s0,0(sp)
    80001286:	0141                	addi	sp,sp,16
    80001288:	8082                	ret

000000008000128a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000128a:	1101                	addi	sp,sp,-32
    8000128c:	ec06                	sd	ra,24(sp)
    8000128e:	e822                	sd	s0,16(sp)
    80001290:	e426                	sd	s1,8(sp)
    80001292:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001294:	919ff0ef          	jal	ra,80000bac <kalloc>
    80001298:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000129a:	c509                	beqz	a0,800012a4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000129c:	6605                	lui	a2,0x1
    8000129e:	4581                	li	a1,0
    800012a0:	ae5ff0ef          	jal	ra,80000d84 <memset>
  return pagetable;
}
    800012a4:	8526                	mv	a0,s1
    800012a6:	60e2                	ld	ra,24(sp)
    800012a8:	6442                	ld	s0,16(sp)
    800012aa:	64a2                	ld	s1,8(sp)
    800012ac:	6105                	addi	sp,sp,32
    800012ae:	8082                	ret

00000000800012b0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012b0:	7139                	addi	sp,sp,-64
    800012b2:	fc06                	sd	ra,56(sp)
    800012b4:	f822                	sd	s0,48(sp)
    800012b6:	f426                	sd	s1,40(sp)
    800012b8:	f04a                	sd	s2,32(sp)
    800012ba:	ec4e                	sd	s3,24(sp)
    800012bc:	e852                	sd	s4,16(sp)
    800012be:	e456                	sd	s5,8(sp)
    800012c0:	e05a                	sd	s6,0(sp)
    800012c2:	0080                	addi	s0,sp,64
  
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c4:	03459793          	slli	a5,a1,0x34
    800012c8:	e785                	bnez	a5,800012f0 <uvmunmap+0x40>
    800012ca:	8a2a                	mv	s4,a0
    800012cc:	892e                	mv	s2,a1
    800012ce:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d0:	0632                	slli	a2,a2,0xc
    800012d2:	00b609b3          	add	s3,a2,a1
    800012d6:	6b05                	lui	s6,0x1
    800012d8:	0335e763          	bltu	a1,s3,80001306 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012dc:	70e2                	ld	ra,56(sp)
    800012de:	7442                	ld	s0,48(sp)
    800012e0:	74a2                	ld	s1,40(sp)
    800012e2:	7902                	ld	s2,32(sp)
    800012e4:	69e2                	ld	s3,24(sp)
    800012e6:	6a42                	ld	s4,16(sp)
    800012e8:	6aa2                	ld	s5,8(sp)
    800012ea:	6b02                	ld	s6,0(sp)
    800012ec:	6121                	addi	sp,sp,64
    800012ee:	8082                	ret
    panic("uvmunmap: not aligned");
    800012f0:	00007517          	auipc	a0,0x7
    800012f4:	e5050513          	addi	a0,a0,-432 # 80008140 <digits+0x108>
    800012f8:	c92ff0ef          	jal	ra,8000078a <panic>
    *pte = 0;
    800012fc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001300:	995a                	add	s2,s2,s6
    80001302:	fd397de3          	bgeu	s2,s3,800012dc <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001306:	4601                	li	a2,0
    80001308:	85ca                	mv	a1,s2
    8000130a:	8552                	mv	a0,s4
    8000130c:	d01ff0ef          	jal	ra,8000100c <walk>
    80001310:	84aa                	mv	s1,a0
    80001312:	d57d                	beqz	a0,80001300 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001314:	611c                	ld	a5,0(a0)
    80001316:	0017f713          	andi	a4,a5,1
    8000131a:	d37d                	beqz	a4,80001300 <uvmunmap+0x50>
    if(do_free){
    8000131c:	fe0a80e3          	beqz	s5,800012fc <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    80001320:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001322:	00c79513          	slli	a0,a5,0xc
    80001326:	f58ff0ef          	jal	ra,80000a7e <kfree>
    8000132a:	bfc9                	j	800012fc <uvmunmap+0x4c>

000000008000132c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000132c:	1101                	addi	sp,sp,-32
    8000132e:	ec06                	sd	ra,24(sp)
    80001330:	e822                	sd	s0,16(sp)
    80001332:	e426                	sd	s1,8(sp)
    80001334:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001336:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001338:	00b67d63          	bgeu	a2,a1,80001352 <uvmdealloc+0x26>
    8000133c:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000133e:	6785                	lui	a5,0x1
    80001340:	17fd                	addi	a5,a5,-1
    80001342:	00f60733          	add	a4,a2,a5
    80001346:	767d                	lui	a2,0xfffff
    80001348:	8f71                	and	a4,a4,a2
    8000134a:	97ae                	add	a5,a5,a1
    8000134c:	8ff1                	and	a5,a5,a2
    8000134e:	00f76863          	bltu	a4,a5,8000135e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001352:	8526                	mv	a0,s1
    80001354:	60e2                	ld	ra,24(sp)
    80001356:	6442                	ld	s0,16(sp)
    80001358:	64a2                	ld	s1,8(sp)
    8000135a:	6105                	addi	sp,sp,32
    8000135c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000135e:	8f99                	sub	a5,a5,a4
    80001360:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001362:	4685                	li	a3,1
    80001364:	0007861b          	sext.w	a2,a5
    80001368:	85ba                	mv	a1,a4
    8000136a:	f47ff0ef          	jal	ra,800012b0 <uvmunmap>
    8000136e:	b7d5                	j	80001352 <uvmdealloc+0x26>

0000000080001370 <uvmalloc>:
  if(newsz < oldsz)
    80001370:	08b66963          	bltu	a2,a1,80001402 <uvmalloc+0x92>
{
    80001374:	7139                	addi	sp,sp,-64
    80001376:	fc06                	sd	ra,56(sp)
    80001378:	f822                	sd	s0,48(sp)
    8000137a:	f426                	sd	s1,40(sp)
    8000137c:	f04a                	sd	s2,32(sp)
    8000137e:	ec4e                	sd	s3,24(sp)
    80001380:	e852                	sd	s4,16(sp)
    80001382:	e456                	sd	s5,8(sp)
    80001384:	e05a                	sd	s6,0(sp)
    80001386:	0080                	addi	s0,sp,64
    80001388:	8aaa                	mv	s5,a0
    8000138a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000138c:	6985                	lui	s3,0x1
    8000138e:	19fd                	addi	s3,s3,-1
    80001390:	95ce                	add	a1,a1,s3
    80001392:	79fd                	lui	s3,0xfffff
    80001394:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001398:	06c9f763          	bgeu	s3,a2,80001406 <uvmalloc+0x96>
    8000139c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000139e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800013a2:	80bff0ef          	jal	ra,80000bac <kalloc>
    800013a6:	84aa                	mv	s1,a0
    if(mem == 0){
    800013a8:	c11d                	beqz	a0,800013ce <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    800013aa:	6605                	lui	a2,0x1
    800013ac:	4581                	li	a1,0
    800013ae:	9d7ff0ef          	jal	ra,80000d84 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013b2:	875a                	mv	a4,s6
    800013b4:	86a6                	mv	a3,s1
    800013b6:	6605                	lui	a2,0x1
    800013b8:	85ca                	mv	a1,s2
    800013ba:	8556                	mv	a0,s5
    800013bc:	d29ff0ef          	jal	ra,800010e4 <mappages>
    800013c0:	e51d                	bnez	a0,800013ee <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013c2:	6785                	lui	a5,0x1
    800013c4:	993e                	add	s2,s2,a5
    800013c6:	fd496ee3          	bltu	s2,s4,800013a2 <uvmalloc+0x32>
  return newsz;
    800013ca:	8552                	mv	a0,s4
    800013cc:	a039                	j	800013da <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    800013ce:	864e                	mv	a2,s3
    800013d0:	85ca                	mv	a1,s2
    800013d2:	8556                	mv	a0,s5
    800013d4:	f59ff0ef          	jal	ra,8000132c <uvmdealloc>
      return 0;
    800013d8:	4501                	li	a0,0
}
    800013da:	70e2                	ld	ra,56(sp)
    800013dc:	7442                	ld	s0,48(sp)
    800013de:	74a2                	ld	s1,40(sp)
    800013e0:	7902                	ld	s2,32(sp)
    800013e2:	69e2                	ld	s3,24(sp)
    800013e4:	6a42                	ld	s4,16(sp)
    800013e6:	6aa2                	ld	s5,8(sp)
    800013e8:	6b02                	ld	s6,0(sp)
    800013ea:	6121                	addi	sp,sp,64
    800013ec:	8082                	ret
      kfree(mem);
    800013ee:	8526                	mv	a0,s1
    800013f0:	e8eff0ef          	jal	ra,80000a7e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f4:	864e                	mv	a2,s3
    800013f6:	85ca                	mv	a1,s2
    800013f8:	8556                	mv	a0,s5
    800013fa:	f33ff0ef          	jal	ra,8000132c <uvmdealloc>
      return 0;
    800013fe:	4501                	li	a0,0
    80001400:	bfe9                	j	800013da <uvmalloc+0x6a>
    return oldsz;
    80001402:	852e                	mv	a0,a1
}
    80001404:	8082                	ret
  return newsz;
    80001406:	8532                	mv	a0,a2
    80001408:	bfc9                	j	800013da <uvmalloc+0x6a>

000000008000140a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000140a:	7179                	addi	sp,sp,-48
    8000140c:	f406                	sd	ra,40(sp)
    8000140e:	f022                	sd	s0,32(sp)
    80001410:	ec26                	sd	s1,24(sp)
    80001412:	e84a                	sd	s2,16(sp)
    80001414:	e44e                	sd	s3,8(sp)
    80001416:	e052                	sd	s4,0(sp)
    80001418:	1800                	addi	s0,sp,48
    8000141a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000141c:	84aa                	mv	s1,a0
    8000141e:	6905                	lui	s2,0x1
    80001420:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001422:	4985                	li	s3,1
    80001424:	a811                	j	80001438 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001426:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001428:	0532                	slli	a0,a0,0xc
    8000142a:	fe1ff0ef          	jal	ra,8000140a <freewalk>
      pagetable[i] = 0;
    8000142e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001432:	04a1                	addi	s1,s1,8
    80001434:	01248f63          	beq	s1,s2,80001452 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001438:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000143a:	00f57793          	andi	a5,a0,15
    8000143e:	ff3784e3          	beq	a5,s3,80001426 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001442:	8905                	andi	a0,a0,1
    80001444:	d57d                	beqz	a0,80001432 <freewalk+0x28>
      panic("freewalk: leaf");
    80001446:	00007517          	auipc	a0,0x7
    8000144a:	d1250513          	addi	a0,a0,-750 # 80008158 <digits+0x120>
    8000144e:	b3cff0ef          	jal	ra,8000078a <panic>
    }
  }
  kfree((void*)pagetable);
    80001452:	8552                	mv	a0,s4
    80001454:	e2aff0ef          	jal	ra,80000a7e <kfree>
}
    80001458:	70a2                	ld	ra,40(sp)
    8000145a:	7402                	ld	s0,32(sp)
    8000145c:	64e2                	ld	s1,24(sp)
    8000145e:	6942                	ld	s2,16(sp)
    80001460:	69a2                	ld	s3,8(sp)
    80001462:	6a02                	ld	s4,0(sp)
    80001464:	6145                	addi	sp,sp,48
    80001466:	8082                	ret

0000000080001468 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001468:	1101                	addi	sp,sp,-32
    8000146a:	ec06                	sd	ra,24(sp)
    8000146c:	e822                	sd	s0,16(sp)
    8000146e:	e426                	sd	s1,8(sp)
    80001470:	1000                	addi	s0,sp,32
    80001472:	84aa                	mv	s1,a0
  if(sz > 0)
    80001474:	e989                	bnez	a1,80001486 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001476:	8526                	mv	a0,s1
    80001478:	f93ff0ef          	jal	ra,8000140a <freewalk>
}
    8000147c:	60e2                	ld	ra,24(sp)
    8000147e:	6442                	ld	s0,16(sp)
    80001480:	64a2                	ld	s1,8(sp)
    80001482:	6105                	addi	sp,sp,32
    80001484:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001486:	6605                	lui	a2,0x1
    80001488:	167d                	addi	a2,a2,-1
    8000148a:	962e                	add	a2,a2,a1
    8000148c:	4685                	li	a3,1
    8000148e:	8231                	srli	a2,a2,0xc
    80001490:	4581                	li	a1,0
    80001492:	e1fff0ef          	jal	ra,800012b0 <uvmunmap>
    80001496:	b7c5                	j	80001476 <uvmfree+0xe>

0000000080001498 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001498:	ce55                	beqz	a2,80001554 <uvmcopy+0xbc>
{
    8000149a:	715d                	addi	sp,sp,-80
    8000149c:	e486                	sd	ra,72(sp)
    8000149e:	e0a2                	sd	s0,64(sp)
    800014a0:	fc26                	sd	s1,56(sp)
    800014a2:	f84a                	sd	s2,48(sp)
    800014a4:	f44e                	sd	s3,40(sp)
    800014a6:	f052                	sd	s4,32(sp)
    800014a8:	ec56                	sd	s5,24(sp)
    800014aa:	e85a                	sd	s6,16(sp)
    800014ac:	e45e                	sd	s7,8(sp)
    800014ae:	0880                	addi	s0,sp,80
    800014b0:	8a2a                	mv	s4,a0
    800014b2:	8aae                	mv	s5,a1
    800014b4:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014b6:	4901                	li	s2,0
    if(flags & PTE_W){
      // 子进程和父进程的映射都设置为只读 + COW 标志
      flags = (flags & ~PTE_W) | PTE_COW;

      // 更新父进程的页表项
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014b8:	7b7d                	lui	s6,0xfffff
    800014ba:	002b5b13          	srli	s6,s6,0x2
    800014be:	a02d                	j	800014e8 <uvmcopy+0x50>
    pa = PTE2PA(*pte);
    800014c0:	82a9                	srli	a3,a3,0xa
    800014c2:	00c69493          	slli	s1,a3,0xc
    }

    // 共享同一物理页：增加物理页的引用计数
    kref_inc((void*)pa);
    800014c6:	8526                	mv	a0,s1
    800014c8:	d2eff0ef          	jal	ra,800009f6 <kref_inc>

    // 在子进程中建立映射
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800014cc:	875e                	mv	a4,s7
    800014ce:	86a6                	mv	a3,s1
    800014d0:	6605                	lui	a2,0x1
    800014d2:	85ca                	mv	a1,s2
    800014d4:	8556                	mv	a0,s5
    800014d6:	c0fff0ef          	jal	ra,800010e4 <mappages>
    800014da:	e529                	bnez	a0,80001524 <uvmcopy+0x8c>
    800014dc:	12000073          	sfence.vma
  for(i = 0; i < sz; i += PGSIZE){
    800014e0:	6785                	lui	a5,0x1
    800014e2:	993e                	add	s2,s2,a5
    800014e4:	05397c63          	bgeu	s2,s3,8000153c <uvmcopy+0xa4>
    pte = walk(old, i, 0);
    800014e8:	4601                	li	a2,0
    800014ea:	85ca                	mv	a1,s2
    800014ec:	8552                	mv	a0,s4
    800014ee:	b1fff0ef          	jal	ra,8000100c <walk>
    if(pte == 0)
    800014f2:	d57d                	beqz	a0,800014e0 <uvmcopy+0x48>
    if((*pte & PTE_V) == 0)
    800014f4:	6114                	ld	a3,0(a0)
    800014f6:	0016f793          	andi	a5,a3,1
    800014fa:	d3fd                	beqz	a5,800014e0 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    800014fc:	0006879b          	sext.w	a5,a3
    if((flags & PTE_U) == 0)
    80001500:	0106f713          	andi	a4,a3,16
    80001504:	df71                	beqz	a4,800014e0 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    80001506:	3ff7fb93          	andi	s7,a5,1023
    if(flags & PTE_W){
    8000150a:	8b91                	andi	a5,a5,4
    8000150c:	dbd5                	beqz	a5,800014c0 <uvmcopy+0x28>
      flags = (flags & ~PTE_W) | PTE_COW;
    8000150e:	efbbf793          	andi	a5,s7,-261
    80001512:	1007eb93          	ori	s7,a5,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001516:	0166f733          	and	a4,a3,s6
    8000151a:	8fd9                	or	a5,a5,a4
    8000151c:	1017e793          	ori	a5,a5,257
    80001520:	e11c                	sd	a5,0(a0)
    80001522:	bf79                	j	800014c0 <uvmcopy+0x28>
      // 映射失败，回滚引用计数
      kref_dec((void*)pa);
    80001524:	8526                	mv	a0,s1
    80001526:	d14ff0ef          	jal	ra,80000a3a <kref_dec>
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调用 kfree()，kfree 会自动减少引用计数
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000152a:	4685                	li	a3,1
    8000152c:	00c95613          	srli	a2,s2,0xc
    80001530:	4581                	li	a1,0
    80001532:	8556                	mv	a0,s5
    80001534:	d7dff0ef          	jal	ra,800012b0 <uvmunmap>
  return -1;
    80001538:	557d                	li	a0,-1
    8000153a:	a011                	j	8000153e <uvmcopy+0xa6>
  return 0;
    8000153c:	4501                	li	a0,0
}
    8000153e:	60a6                	ld	ra,72(sp)
    80001540:	6406                	ld	s0,64(sp)
    80001542:	74e2                	ld	s1,56(sp)
    80001544:	7942                	ld	s2,48(sp)
    80001546:	79a2                	ld	s3,40(sp)
    80001548:	7a02                	ld	s4,32(sp)
    8000154a:	6ae2                	ld	s5,24(sp)
    8000154c:	6b42                	ld	s6,16(sp)
    8000154e:	6ba2                	ld	s7,8(sp)
    80001550:	6161                	addi	sp,sp,80
    80001552:	8082                	ret
  return 0;
    80001554:	4501                	li	a0,0
}
    80001556:	8082                	ret

0000000080001558 <cowbreak>:
 *   - 该函数会在页表更新后刷新 TLB，确保更改立即生效
 *   - 当需要复制页面时，会更新 COW 统计信息
 */
int
cowbreak(pagetable_t pagetable, uint64 va)
{
    80001558:	7179                	addi	sp,sp,-48
    8000155a:	f406                	sd	ra,40(sp)
    8000155c:	f022                	sd	s0,32(sp)
    8000155e:	ec26                	sd	s1,24(sp)
    80001560:	e84a                	sd	s2,16(sp)
    80001562:	e44e                	sd	s3,8(sp)
    80001564:	e052                	sd	s4,0(sp)
    80001566:	1800                	addi	s0,sp,48
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
    80001568:	4601                	li	a2,0
    8000156a:	77fd                	lui	a5,0xfffff
    8000156c:	8dfd                	and	a1,a1,a5
    8000156e:	a9fff0ef          	jal	ra,8000100c <walk>
  if(pte == 0)
    80001572:	cd51                	beqz	a0,8000160e <cowbreak+0xb6>
    80001574:	89aa                	mv	s3,a0
    return -1;                 // 页表项不存在
  if((*pte & PTE_V) == 0)
    80001576:	6104                	ld	s1,0(a0)
    return -1;                 // 虚拟地址未映射到物理页
  if((*pte & PTE_U) == 0)
    80001578:	0114f713          	andi	a4,s1,17
    8000157c:	47c5                	li	a5,17
    8000157e:	08f71a63          	bne	a4,a5,80001612 <cowbreak+0xba>
    return -1;                 // 非用户页

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    80001582:	1044f793          	andi	a5,s1,260
    80001586:	10000713          	li	a4,256
    8000158a:	08e79663          	bne	a5,a4,80001616 <cowbreak+0xbe>
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);
    8000158e:	3ff4f913          	andi	s2,s1,1023
  uint64 pa_old = PTE2PA(*pte);
    80001592:	00a4da13          	srli	s4,s1,0xa
    80001596:	0a32                	slli	s4,s4,0xc

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    80001598:	8552                	mv	a0,s4
    8000159a:	c22ff0ef          	jal	ra,800009bc <kref_get>
    8000159e:	4785                	li	a5,1
    800015a0:	04f50663          	beq	a0,a5,800015ec <cowbreak+0x94>
    sfence_vma();              // 刷新 TLB
    return 0;
  }

  // 分配新物理页
  char *mem = kalloc();
    800015a4:	e08ff0ef          	jal	ra,80000bac <kalloc>
    800015a8:	84aa                	mv	s1,a0
  if(mem == 0)
    800015aa:	c925                	beqz	a0,8000161a <cowbreak+0xc2>
    return -1;                 // 内存分配失败

  // 复制旧页内容到新页
  memmove(mem, (void*)pa_old, PGSIZE);
    800015ac:	6605                	lui	a2,0x1
    800015ae:	85d2                	mv	a1,s4
    800015b0:	831ff0ef          	jal	ra,80000de0 <memmove>

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);
    800015b4:	8552                	mv	a0,s4
    800015b6:	c84ff0ef          	jal	ra,80000a3a <kref_dec>

  // 更新 PTE：指向新页，变可写，清掉 COW 标志
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015ba:	80b1                	srli	s1,s1,0xc
    800015bc:	04aa                	slli	s1,s1,0xa
    800015be:	00496913          	ori	s2,s2,4
    800015c2:	eff97913          	andi	s2,s2,-257
    800015c6:	0124e4b3          	or	s1,s1,s2
    800015ca:	0014e493          	ori	s1,s1,1
    800015ce:	0099b023          	sd	s1,0(s3) # fffffffffffff000 <end+0xffffffff7fdaae10>
    800015d2:	12000073          	sfence.vma

  sfence_vma();                // 刷新 TLB
  vmstats_inc_cow();           // 更新 COW 统计信息
    800015d6:	782050ef          	jal	ra,80006d58 <vmstats_inc_cow>

  return 0;
    800015da:	4501                	li	a0,0
}
    800015dc:	70a2                	ld	ra,40(sp)
    800015de:	7402                	ld	s0,32(sp)
    800015e0:	64e2                	ld	s1,24(sp)
    800015e2:	6942                	ld	s2,16(sp)
    800015e4:	69a2                	ld	s3,8(sp)
    800015e6:	6a02                	ld	s4,0(sp)
    800015e8:	6145                	addi	sp,sp,48
    800015ea:	8082                	ret
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015ec:	00496913          	ori	s2,s2,4
    800015f0:	eff97913          	andi	s2,s2,-257
    800015f4:	77fd                	lui	a5,0xfffff
    800015f6:	8389                	srli	a5,a5,0x2
    800015f8:	8cfd                	and	s1,s1,a5
    800015fa:	00996933          	or	s2,s2,s1
    800015fe:	00196913          	ori	s2,s2,1
    80001602:	0129b023          	sd	s2,0(s3)
    80001606:	12000073          	sfence.vma
    return 0;
    8000160a:	4501                	li	a0,0
    8000160c:	bfc1                	j	800015dc <cowbreak+0x84>
    return -1;                 // 页表项不存在
    8000160e:	557d                	li	a0,-1
    80001610:	b7f1                	j	800015dc <cowbreak+0x84>
    return -1;                 // 非用户页
    80001612:	557d                	li	a0,-1
    80001614:	b7e1                	j	800015dc <cowbreak+0x84>
    return -1;
    80001616:	557d                	li	a0,-1
    80001618:	b7d1                	j	800015dc <cowbreak+0x84>
    return -1;                 // 内存分配失败
    8000161a:	557d                	li	a0,-1
    8000161c:	b7c1                	j	800015dc <cowbreak+0x84>

000000008000161e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000161e:	1141                	addi	sp,sp,-16
    80001620:	e406                	sd	ra,8(sp)
    80001622:	e022                	sd	s0,0(sp)
    80001624:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001626:	4601                	li	a2,0
    80001628:	9e5ff0ef          	jal	ra,8000100c <walk>
  if(pte == 0)
    8000162c:	c901                	beqz	a0,8000163c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000162e:	611c                	ld	a5,0(a0)
    80001630:	9bbd                	andi	a5,a5,-17
    80001632:	e11c                	sd	a5,0(a0)
}
    80001634:	60a2                	ld	ra,8(sp)
    80001636:	6402                	ld	s0,0(sp)
    80001638:	0141                	addi	sp,sp,16
    8000163a:	8082                	ret
    panic("uvmclear");
    8000163c:	00007517          	auipc	a0,0x7
    80001640:	b2c50513          	addi	a0,a0,-1236 # 80008168 <digits+0x130>
    80001644:	946ff0ef          	jal	ra,8000078a <panic>

0000000080001648 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001648:	c2d5                	beqz	a3,800016ec <copyinstr+0xa4>
{
    8000164a:	715d                	addi	sp,sp,-80
    8000164c:	e486                	sd	ra,72(sp)
    8000164e:	e0a2                	sd	s0,64(sp)
    80001650:	fc26                	sd	s1,56(sp)
    80001652:	f84a                	sd	s2,48(sp)
    80001654:	f44e                	sd	s3,40(sp)
    80001656:	f052                	sd	s4,32(sp)
    80001658:	ec56                	sd	s5,24(sp)
    8000165a:	e85a                	sd	s6,16(sp)
    8000165c:	e45e                	sd	s7,8(sp)
    8000165e:	0880                	addi	s0,sp,80
    80001660:	8a2a                	mv	s4,a0
    80001662:	8b2e                	mv	s6,a1
    80001664:	8bb2                	mv	s7,a2
    80001666:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001668:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000166a:	6985                	lui	s3,0x1
    8000166c:	a035                	j	80001698 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000166e:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdaae10>
    80001672:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001674:	0017b793          	seqz	a5,a5
    80001678:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000167c:	60a6                	ld	ra,72(sp)
    8000167e:	6406                	ld	s0,64(sp)
    80001680:	74e2                	ld	s1,56(sp)
    80001682:	7942                	ld	s2,48(sp)
    80001684:	79a2                	ld	s3,40(sp)
    80001686:	7a02                	ld	s4,32(sp)
    80001688:	6ae2                	ld	s5,24(sp)
    8000168a:	6b42                	ld	s6,16(sp)
    8000168c:	6ba2                	ld	s7,8(sp)
    8000168e:	6161                	addi	sp,sp,80
    80001690:	8082                	ret
    srcva = va0 + PGSIZE;
    80001692:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001696:	c4b9                	beqz	s1,800016e4 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001698:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000169c:	85ca                	mv	a1,s2
    8000169e:	8552                	mv	a0,s4
    800016a0:	a07ff0ef          	jal	ra,800010a6 <walkaddr>
    if(pa0 == 0)
    800016a4:	c131                	beqz	a0,800016e8 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    800016a6:	41790833          	sub	a6,s2,s7
    800016aa:	984e                	add	a6,a6,s3
    if(n > max)
    800016ac:	0104f363          	bgeu	s1,a6,800016b2 <copyinstr+0x6a>
    800016b0:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016b2:	955e                	add	a0,a0,s7
    800016b4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016b8:	fc080de3          	beqz	a6,80001692 <copyinstr+0x4a>
    800016bc:	985a                	add	a6,a6,s6
    800016be:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016c0:	41650633          	sub	a2,a0,s6
    800016c4:	14fd                	addi	s1,s1,-1
    800016c6:	9b26                	add	s6,s6,s1
    800016c8:	00f60733          	add	a4,a2,a5
    800016cc:	00074703          	lbu	a4,0(a4)
    800016d0:	df59                	beqz	a4,8000166e <copyinstr+0x26>
        *dst = *p;
    800016d2:	00e78023          	sb	a4,0(a5)
      --max;
    800016d6:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016da:	0785                	addi	a5,a5,1
    while(n > 0){
    800016dc:	ff0796e3          	bne	a5,a6,800016c8 <copyinstr+0x80>
      dst++;
    800016e0:	8b42                	mv	s6,a6
    800016e2:	bf45                	j	80001692 <copyinstr+0x4a>
    800016e4:	4781                	li	a5,0
    800016e6:	b779                	j	80001674 <copyinstr+0x2c>
      return -1;
    800016e8:	557d                	li	a0,-1
    800016ea:	bf49                	j	8000167c <copyinstr+0x34>
  int got_null = 0;
    800016ec:	4781                	li	a5,0
  if(got_null){
    800016ee:	0017b793          	seqz	a5,a5
    800016f2:	40f00533          	neg	a0,a5
}
    800016f6:	8082                	ret

00000000800016f8 <ismapped>:
 *   - 仅检查映射存在性，不检查权限
 *   - 用于 vmfault 和其他内存管理函数中的辅助检查
 */
int
ismapped(pagetable_t pagetable, uint64 va)
{
    800016f8:	1141                	addi	sp,sp,-16
    800016fa:	e406                	sd	ra,8(sp)
    800016fc:	e022                	sd	s0,0(sp)
    800016fe:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001700:	4601                	li	a2,0
    80001702:	90bff0ef          	jal	ra,8000100c <walk>
  if (pte == 0) {               // 页表项不存在
    80001706:	c519                	beqz	a0,80001714 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001708:	6108                	ld	a0,0(a0)
    return 0;
    8000170a:	8905                	andi	a0,a0,1
    return 1;                   // 页表项存在且有效
  }
  return 0;                     // 页表项存在但无效
}
    8000170c:	60a2                	ld	ra,8(sp)
    8000170e:	6402                	ld	s0,0(sp)
    80001710:	0141                	addi	sp,sp,16
    80001712:	8082                	ret
    return 0;
    80001714:	4501                	li	a0,0
    80001716:	bfdd                	j	8000170c <ismapped+0x14>

0000000080001718 <vmfault>:
{
    80001718:	7179                	addi	sp,sp,-48
    8000171a:	f406                	sd	ra,40(sp)
    8000171c:	f022                	sd	s0,32(sp)
    8000171e:	ec26                	sd	s1,24(sp)
    80001720:	e84a                	sd	s2,16(sp)
    80001722:	e44e                	sd	s3,8(sp)
    80001724:	e052                	sd	s4,0(sp)
    80001726:	1800                	addi	s0,sp,48
    80001728:	89aa                	mv	s3,a0
    8000172a:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000172c:	46e000ef          	jal	ra,80001b9a <myproc>
  if (va >= p->sz)              // 检查虚拟地址是否在进程地址空间范围内
    80001730:	653c                	ld	a5,72(a0)
    80001732:	00f4ec63          	bltu	s1,a5,8000174a <vmfault+0x32>
    return 0;
    80001736:	4981                	li	s3,0
}
    80001738:	854e                	mv	a0,s3
    8000173a:	70a2                	ld	ra,40(sp)
    8000173c:	7402                	ld	s0,32(sp)
    8000173e:	64e2                	ld	s1,24(sp)
    80001740:	6942                	ld	s2,16(sp)
    80001742:	69a2                	ld	s3,8(sp)
    80001744:	6a02                	ld	s4,0(sp)
    80001746:	6145                	addi	sp,sp,48
    80001748:	8082                	ret
    8000174a:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);         // 向下对齐到页边界
    8000174c:	75fd                	lui	a1,0xfffff
    8000174e:	8ced                	and	s1,s1,a1
  if(ismapped(pagetable, va)) { // 检查是否已映射
    80001750:	85a6                	mv	a1,s1
    80001752:	854e                	mv	a0,s3
    80001754:	fa5ff0ef          	jal	ra,800016f8 <ismapped>
    return 0;
    80001758:	4981                	li	s3,0
  if(ismapped(pagetable, va)) { // 检查是否已映射
    8000175a:	fd79                	bnez	a0,80001738 <vmfault+0x20>
  mem = (uint64) kalloc();      // 分配新物理页
    8000175c:	c50ff0ef          	jal	ra,80000bac <kalloc>
    80001760:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001762:	d979                	beqz	a0,80001738 <vmfault+0x20>
  mem = (uint64) kalloc();      // 分配新物理页
    80001764:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE); // 初始化为0
    80001766:	6605                	lui	a2,0x1
    80001768:	4581                	li	a1,0
    8000176a:	e1aff0ef          	jal	ra,80000d84 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000176e:	4759                	li	a4,22
    80001770:	86d2                	mv	a3,s4
    80001772:	6605                	lui	a2,0x1
    80001774:	85a6                	mv	a1,s1
    80001776:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    8000177a:	96bff0ef          	jal	ra,800010e4 <mappages>
    8000177e:	dd4d                	beqz	a0,80001738 <vmfault+0x20>
    kfree((void *)mem);         // 映射失败，释放物理页
    80001780:	8552                	mv	a0,s4
    80001782:	afcff0ef          	jal	ra,80000a7e <kfree>
    return 0;
    80001786:	4981                	li	s3,0
    80001788:	bf45                	j	80001738 <vmfault+0x20>

000000008000178a <copyout>:
  while(len > 0){
    8000178a:	cef1                	beqz	a3,80001866 <copyout+0xdc>
{
    8000178c:	7159                	addi	sp,sp,-112
    8000178e:	f486                	sd	ra,104(sp)
    80001790:	f0a2                	sd	s0,96(sp)
    80001792:	eca6                	sd	s1,88(sp)
    80001794:	e8ca                	sd	s2,80(sp)
    80001796:	e4ce                	sd	s3,72(sp)
    80001798:	e0d2                	sd	s4,64(sp)
    8000179a:	fc56                	sd	s5,56(sp)
    8000179c:	f85a                	sd	s6,48(sp)
    8000179e:	f45e                	sd	s7,40(sp)
    800017a0:	f062                	sd	s8,32(sp)
    800017a2:	ec66                	sd	s9,24(sp)
    800017a4:	e86a                	sd	s10,16(sp)
    800017a6:	e46e                	sd	s11,8(sp)
    800017a8:	1880                	addi	s0,sp,112
    800017aa:	8aaa                	mv	s5,a0
    800017ac:	8b2e                	mv	s6,a1
    800017ae:	8bb2                	mv	s7,a2
    800017b0:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800017b2:	74fd                	lui	s1,0xfffff
    800017b4:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800017b6:	57fd                	li	a5,-1
    800017b8:	83e9                	srli	a5,a5,0x1a
    800017ba:	0a97e863          	bltu	a5,s1,8000186a <copyout+0xe0>
    800017be:	6d05                	lui	s10,0x1
    copyout_bytes += n;
    800017c0:	00007c17          	auipc	s8,0x7
    800017c4:	110c0c13          	addi	s8,s8,272 # 800088d0 <copyout_bytes>
    if(va0 >= MAXVA)
    800017c8:	8cbe                	mv	s9,a5
    800017ca:	a091                	j	8000180e <copyout+0x84>
    if((*pte & PTE_W) == 0)
    800017cc:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
    800017d0:	8b91                	andi	a5,a5,4
    800017d2:	c7c5                	beqz	a5,8000187a <copyout+0xf0>
    n = PGSIZE - (dstva - va0);
    800017d4:	01a48db3          	add	s11,s1,s10
    800017d8:	416d89b3          	sub	s3,s11,s6
    if(n > len)
    800017dc:	013a7363          	bgeu	s4,s3,800017e2 <copyout+0x58>
    800017e0:	89d2                	mv	s3,s4
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017e2:	409b0533          	sub	a0,s6,s1
    800017e6:	0009861b          	sext.w	a2,s3
    800017ea:	85de                	mv	a1,s7
    800017ec:	954a                	add	a0,a0,s2
    800017ee:	df2ff0ef          	jal	ra,80000de0 <memmove>
    len -= n;
    800017f2:	413a0a33          	sub	s4,s4,s3
    src += n;
    800017f6:	9bce                	add	s7,s7,s3
    copyout_bytes += n;
    800017f8:	000c3783          	ld	a5,0(s8)
    800017fc:	99be                	add	s3,s3,a5
    800017fe:	013c3023          	sd	s3,0(s8)
  while(len > 0){
    80001802:	060a0063          	beqz	s4,80001862 <copyout+0xd8>
    if(va0 >= MAXVA)
    80001806:	07bce463          	bltu	s9,s11,8000186e <copyout+0xe4>
    va0 = PGROUNDDOWN(dstva);
    8000180a:	84ee                	mv	s1,s11
    dstva = va0 + PGSIZE;
    8000180c:	8b6e                	mv	s6,s11
    pa0 = walkaddr(pagetable, va0);
    8000180e:	85a6                	mv	a1,s1
    80001810:	8556                	mv	a0,s5
    80001812:	895ff0ef          	jal	ra,800010a6 <walkaddr>
    80001816:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001818:	e901                	bnez	a0,80001828 <copyout+0x9e>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000181a:	4601                	li	a2,0
    8000181c:	85a6                	mv	a1,s1
    8000181e:	8556                	mv	a0,s5
    80001820:	ef9ff0ef          	jal	ra,80001718 <vmfault>
    80001824:	892a                	mv	s2,a0
    80001826:	c531                	beqz	a0,80001872 <copyout+0xe8>
    pte = walk(pagetable, va0, 0);
    80001828:	4601                	li	a2,0
    8000182a:	85a6                	mv	a1,s1
    8000182c:	8556                	mv	a0,s5
    8000182e:	fdeff0ef          	jal	ra,8000100c <walk>
    80001832:	89aa                	mv	s3,a0
    if(pte && (*pte & PTE_COW)){
    80001834:	dd41                	beqz	a0,800017cc <copyout+0x42>
    80001836:	611c                	ld	a5,0(a0)
    80001838:	1007f793          	andi	a5,a5,256
    8000183c:	dbc1                	beqz	a5,800017cc <copyout+0x42>
      if(cowbreak(pagetable, va0) < 0)
    8000183e:	85a6                	mv	a1,s1
    80001840:	8556                	mv	a0,s5
    80001842:	d17ff0ef          	jal	ra,80001558 <cowbreak>
    80001846:	02054863          	bltz	a0,80001876 <copyout+0xec>
      pte = walk(pagetable, va0, 0);
    8000184a:	4601                	li	a2,0
    8000184c:	85a6                	mv	a1,s1
    8000184e:	8556                	mv	a0,s5
    80001850:	fbcff0ef          	jal	ra,8000100c <walk>
    80001854:	89aa                	mv	s3,a0
      pa0 = walkaddr(pagetable, va0);
    80001856:	85a6                	mv	a1,s1
    80001858:	8556                	mv	a0,s5
    8000185a:	84dff0ef          	jal	ra,800010a6 <walkaddr>
    8000185e:	892a                	mv	s2,a0
    80001860:	b7b5                	j	800017cc <copyout+0x42>
  return 0;
    80001862:	4501                	li	a0,0
    80001864:	a821                	j	8000187c <copyout+0xf2>
    80001866:	4501                	li	a0,0
}
    80001868:	8082                	ret
      return -1;
    8000186a:	557d                	li	a0,-1
    8000186c:	a801                	j	8000187c <copyout+0xf2>
    8000186e:	557d                	li	a0,-1
    80001870:	a031                	j	8000187c <copyout+0xf2>
        return -1;
    80001872:	557d                	li	a0,-1
    80001874:	a021                	j	8000187c <copyout+0xf2>
        return -1;
    80001876:	557d                	li	a0,-1
    80001878:	a011                	j	8000187c <copyout+0xf2>
      return -1;
    8000187a:	557d                	li	a0,-1
}
    8000187c:	70a6                	ld	ra,104(sp)
    8000187e:	7406                	ld	s0,96(sp)
    80001880:	64e6                	ld	s1,88(sp)
    80001882:	6946                	ld	s2,80(sp)
    80001884:	69a6                	ld	s3,72(sp)
    80001886:	6a06                	ld	s4,64(sp)
    80001888:	7ae2                	ld	s5,56(sp)
    8000188a:	7b42                	ld	s6,48(sp)
    8000188c:	7ba2                	ld	s7,40(sp)
    8000188e:	7c02                	ld	s8,32(sp)
    80001890:	6ce2                	ld	s9,24(sp)
    80001892:	6d42                	ld	s10,16(sp)
    80001894:	6da2                	ld	s11,8(sp)
    80001896:	6165                	addi	sp,sp,112
    80001898:	8082                	ret

000000008000189a <copyin>:
  while(len > 0){
    8000189a:	c2c5                	beqz	a3,8000193a <copyin+0xa0>
{
    8000189c:	711d                	addi	sp,sp,-96
    8000189e:	ec86                	sd	ra,88(sp)
    800018a0:	e8a2                	sd	s0,80(sp)
    800018a2:	e4a6                	sd	s1,72(sp)
    800018a4:	e0ca                	sd	s2,64(sp)
    800018a6:	fc4e                	sd	s3,56(sp)
    800018a8:	f852                	sd	s4,48(sp)
    800018aa:	f456                	sd	s5,40(sp)
    800018ac:	f05a                	sd	s6,32(sp)
    800018ae:	ec5e                	sd	s7,24(sp)
    800018b0:	e862                	sd	s8,16(sp)
    800018b2:	e466                	sd	s9,8(sp)
    800018b4:	1080                	addi	s0,sp,96
    800018b6:	8c2a                	mv	s8,a0
    800018b8:	8aae                	mv	s5,a1
    800018ba:	8932                	mv	s2,a2
    800018bc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800018be:	7cfd                	lui	s9,0xfffff
    n = PGSIZE - (srcva - va0);
    800018c0:	6b85                	lui	s7,0x1
    copyin_bytes += n; 
    800018c2:	00007b17          	auipc	s6,0x7
    800018c6:	016b0b13          	addi	s6,s6,22 # 800088d8 <copyin_bytes>
    800018ca:	a81d                	j	80001900 <copyin+0x66>
    n = PGSIZE - (srcva - va0);
    800018cc:	412984b3          	sub	s1,s3,s2
    800018d0:	94de                	add	s1,s1,s7
    if(n > len)
    800018d2:	009a7363          	bgeu	s4,s1,800018d8 <copyin+0x3e>
    800018d6:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018d8:	413905b3          	sub	a1,s2,s3
    800018dc:	0004861b          	sext.w	a2,s1
    800018e0:	95aa                	add	a1,a1,a0
    800018e2:	8556                	mv	a0,s5
    800018e4:	cfcff0ef          	jal	ra,80000de0 <memmove>
    len -= n;
    800018e8:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800018ec:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800018ee:	01798933          	add	s2,s3,s7
    copyin_bytes += n; 
    800018f2:	000b3783          	ld	a5,0(s6)
    800018f6:	94be                	add	s1,s1,a5
    800018f8:	009b3023          	sd	s1,0(s6)
  while(len > 0){
    800018fc:	020a0163          	beqz	s4,8000191e <copyin+0x84>
    va0 = PGROUNDDOWN(srcva);
    80001900:	019979b3          	and	s3,s2,s9
    pa0 = walkaddr(pagetable, va0);
    80001904:	85ce                	mv	a1,s3
    80001906:	8562                	mv	a0,s8
    80001908:	f9eff0ef          	jal	ra,800010a6 <walkaddr>
    if(pa0 == 0) {
    8000190c:	f161                	bnez	a0,800018cc <copyin+0x32>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000190e:	4601                	li	a2,0
    80001910:	85ce                	mv	a1,s3
    80001912:	8562                	mv	a0,s8
    80001914:	e05ff0ef          	jal	ra,80001718 <vmfault>
    80001918:	f955                	bnez	a0,800018cc <copyin+0x32>
        return -1;
    8000191a:	557d                	li	a0,-1
    8000191c:	a011                	j	80001920 <copyin+0x86>
  return 0;
    8000191e:	4501                	li	a0,0
}
    80001920:	60e6                	ld	ra,88(sp)
    80001922:	6446                	ld	s0,80(sp)
    80001924:	64a6                	ld	s1,72(sp)
    80001926:	6906                	ld	s2,64(sp)
    80001928:	79e2                	ld	s3,56(sp)
    8000192a:	7a42                	ld	s4,48(sp)
    8000192c:	7aa2                	ld	s5,40(sp)
    8000192e:	7b02                	ld	s6,32(sp)
    80001930:	6be2                	ld	s7,24(sp)
    80001932:	6c42                	ld	s8,16(sp)
    80001934:	6ca2                	ld	s9,8(sp)
    80001936:	6125                	addi	sp,sp,96
    80001938:	8082                	ret
  return 0;
    8000193a:	4501                	li	a0,0
}
    8000193c:	8082                	ret

000000008000193e <vmafault>:
 *   - 支持匿名映射和共享内存映射两种类型
 *   - 失败时会自动回滚已分配的资源（如物理页）
 */
uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    8000193e:	7139                	addi	sp,sp,-64
    80001940:	fc06                	sd	ra,56(sp)
    80001942:	f822                	sd	s0,48(sp)
    80001944:	f426                	sd	s1,40(sp)
    80001946:	f04a                	sd	s2,32(sp)
    80001948:	ec4e                	sd	s3,24(sp)
    8000194a:	e852                	sd	s4,16(sp)
    8000194c:	e456                	sd	s5,8(sp)
    8000194e:	0080                	addi	s0,sp,64
    80001950:	8a2a                	mv	s4,a0
    80001952:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);         // 向下对齐到页边界
    80001954:	77fd                	lui	a5,0xfffff
    80001956:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va); // 查找虚拟地址所属的 VMA
    8000195a:	85ce                	mv	a1,s3
    8000195c:	752010ef          	jal	ra,800030ae <vma_find>
  if(v == 0) return 0;          // 不在任何 VMA 范围内
    80001960:	c961                	beqz	a0,80001a30 <vmafault+0xf2>
    80001962:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001964:	00090663          	beqz	s2,80001970 <vmafault+0x32>
    80001968:	4d1c                	lw	a5,24(a0)
    8000196a:	8b89                	andi	a5,a5,2
    return 0;
    8000196c:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    8000196e:	c789                	beqz	a5,80001978 <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0) // VMA 不允许读 -> 不处理
    80001970:	4c9c                	lw	a5,24(s1)
    80001972:	8b85                	andi	a5,a5,1
    return 0;
    80001974:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0) // VMA 不允许读 -> 不处理
    80001976:	eb99                	bnez	a5,8000198c <vmafault+0x4e>
    else kfree((void*)pa);            // 释放普通物理页
    return 0;
  }
  vmstats_inc_lazy();            // 更新惰性分配统计信息
  return (uint64)pa;             // 返回物理页地址
}
    80001978:	854a                	mv	a0,s2
    8000197a:	70e2                	ld	ra,56(sp)
    8000197c:	7442                	ld	s0,48(sp)
    8000197e:	74a2                	ld	s1,40(sp)
    80001980:	7902                	ld	s2,32(sp)
    80001982:	69e2                	ld	s3,24(sp)
    80001984:	6a42                	ld	s4,16(sp)
    80001986:	6aa2                	ld	s5,8(sp)
    80001988:	6121                	addi	sp,sp,64
    8000198a:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    8000198c:	4601                	li	a2,0
    8000198e:	85ce                	mv	a1,s3
    80001990:	050a3503          	ld	a0,80(s4) # 2050 <_entry-0x7fffdfb0>
    80001994:	e78ff0ef          	jal	ra,8000100c <walk>
  if(pte && (*pte & PTE_V)){     // 如果已经映射
    80001998:	c115                	beqz	a0,800019bc <vmafault+0x7e>
    8000199a:	611c                	ld	a5,0(a0)
    8000199c:	0017f913          	andi	s2,a5,1
    800019a0:	00090e63          	beqz	s2,800019bc <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    800019a4:	4c98                	lw	a4,24(s1)
    800019a6:	8b09                	andi	a4,a4,2
    800019a8:	c751                	beqz	a4,80001a34 <vmafault+0xf6>
    800019aa:	0047f713          	andi	a4,a5,4
    800019ae:	e749                	bnez	a4,80001a38 <vmafault+0xfa>
      *pte |= PTE_W;
    800019b0:	0047e793          	ori	a5,a5,4
    800019b4:	e11c                	sd	a5,0(a0)
    800019b6:	12000073          	sfence.vma
      return 1;                  // 返回成功标志
    800019ba:	bf7d                	j	80001978 <vmafault+0x3a>
  if(v->is_shm){                 // 共享内存 VMA
    800019bc:	509c                	lw	a5,32(s1)
    800019be:	cf91                	beqz	a5,800019da <vmafault+0x9c>
  int idx = (va - v->start) / PGSIZE; // 计算页在 VMA 中的索引
    800019c0:	648c                	ld	a1,8(s1)
    800019c2:	40b985b3          	sub	a1,s3,a1
    800019c6:	81b1                	srli	a1,a1,0xc
    pa = shm_getpa(v->shm_key, idx); // 从共享内存对象获取物理页
    800019c8:	2581                	sext.w	a1,a1
    800019ca:	50c8                	lw	a0,36(s1)
    800019cc:	627040ef          	jal	ra,800067f2 <shm_getpa>
    800019d0:	892a                	mv	s2,a0
    if(pa == 0) return 0;        // 获取失败
    800019d2:	d15d                	beqz	a0,80001978 <vmafault+0x3a>
    kref_inc((void*)pa);         // 增加共享页的引用计数
    800019d4:	822ff0ef          	jal	ra,800009f6 <kref_inc>
    800019d8:	a819                	j	800019ee <vmafault+0xb0>
    char *mem = kalloc();        // 分配新的物理页
    800019da:	9d2ff0ef          	jal	ra,80000bac <kalloc>
    800019de:	8aaa                	mv	s5,a0
    if(mem == 0) return 0;      // 分配失败
    800019e0:	4901                	li	s2,0
    800019e2:	d959                	beqz	a0,80001978 <vmafault+0x3a>
    memset(mem, 0, PGSIZE);     // 初始化为0
    800019e4:	6605                	lui	a2,0x1
    800019e6:	4581                	li	a1,0
    800019e8:	b9cff0ef          	jal	ra,80000d84 <memset>
    pa = (uint64)mem;
    800019ec:	8956                	mv	s2,s5
  if(v->prot & PROT_READ)  perm |= PTE_R; // 读权限
    800019ee:	4c9c                	lw	a5,24(s1)
    800019f0:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;              // 用户页标志
    800019f4:	4741                	li	a4,16
  if(v->prot & PROT_READ)  perm |= PTE_R; // 读权限
    800019f6:	c291                	beqz	a3,800019fa <vmafault+0xbc>
    800019f8:	4749                	li	a4,18
  if(v->prot & PROT_WRITE) perm |= PTE_W; // 写权限
    800019fa:	8b89                	andi	a5,a5,2
    800019fc:	c399                	beqz	a5,80001a02 <vmafault+0xc4>
    800019fe:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    80001a02:	86ca                	mv	a3,s2
    80001a04:	6605                	lui	a2,0x1
    80001a06:	85ce                	mv	a1,s3
    80001a08:	050a3503          	ld	a0,80(s4)
    80001a0c:	ed8ff0ef          	jal	ra,800010e4 <mappages>
    80001a10:	cd09                	beqz	a0,80001a2a <vmafault+0xec>
    if(v->is_shm) kref_dec((void*)pa); // 减少共享页引用计数
    80001a12:	509c                	lw	a5,32(s1)
    80001a14:	c791                	beqz	a5,80001a20 <vmafault+0xe2>
    80001a16:	854a                	mv	a0,s2
    80001a18:	822ff0ef          	jal	ra,80000a3a <kref_dec>
    return 0;
    80001a1c:	4901                	li	s2,0
    80001a1e:	bfa9                	j	80001978 <vmafault+0x3a>
    else kfree((void*)pa);            // 释放普通物理页
    80001a20:	854a                	mv	a0,s2
    80001a22:	85cff0ef          	jal	ra,80000a7e <kfree>
    return 0;
    80001a26:	4901                	li	s2,0
    80001a28:	bf81                	j	80001978 <vmafault+0x3a>
  vmstats_inc_lazy();            // 更新惰性分配统计信息
    80001a2a:	35c050ef          	jal	ra,80006d86 <vmstats_inc_lazy>
  return (uint64)pa;             // 返回物理页地址
    80001a2e:	b7a9                	j	80001978 <vmafault+0x3a>
  if(v == 0) return 0;          // 不在任何 VMA 范围内
    80001a30:	4901                	li	s2,0
    80001a32:	b799                	j	80001978 <vmafault+0x3a>
    return 0;
    80001a34:	4901                	li	s2,0
    80001a36:	b789                	j	80001978 <vmafault+0x3a>
    80001a38:	4901                	li	s2,0
    80001a3a:	bf3d                	j	80001978 <vmafault+0x3a>

0000000080001a3c <proc_mapstacks>:
 * 参数：
 *   kpgtbl - 内核页表
 */
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001a3c:	7139                	addi	sp,sp,-64
    80001a3e:	fc06                	sd	ra,56(sp)
    80001a40:	f822                	sd	s0,48(sp)
    80001a42:	f426                	sd	s1,40(sp)
    80001a44:	f04a                	sd	s2,32(sp)
    80001a46:	ec4e                	sd	s3,24(sp)
    80001a48:	e852                	sd	s4,16(sp)
    80001a4a:	e456                	sd	s5,8(sp)
    80001a4c:	e05a                	sd	s6,0(sp)
    80001a4e:	0080                	addi	s0,sp,64
    80001a50:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a52:	0022f497          	auipc	s1,0x22f
    80001a56:	3de48493          	addi	s1,s1,990 # 80230e30 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a5a:	8b26                	mv	s6,s1
    80001a5c:	00006a97          	auipc	s5,0x6
    80001a60:	5a4a8a93          	addi	s5,s5,1444 # 80008000 <etext>
    80001a64:	04000937          	lui	s2,0x4000
    80001a68:	197d                	addi	s2,s2,-1
    80001a6a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a6c:	0023fa17          	auipc	s4,0x23f
    80001a70:	dc4a0a13          	addi	s4,s4,-572 # 80240830 <tickslock>
    char *pa = kalloc();
    80001a74:	938ff0ef          	jal	ra,80000bac <kalloc>
    80001a78:	862a                	mv	a2,a0
    if(pa == 0)
    80001a7a:	c121                	beqz	a0,80001aba <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001a7c:	416485b3          	sub	a1,s1,s6
    80001a80:	858d                	srai	a1,a1,0x3
    80001a82:	000ab783          	ld	a5,0(s5)
    80001a86:	02f585b3          	mul	a1,a1,a5
    80001a8a:	2585                	addiw	a1,a1,1
    80001a8c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a90:	4719                	li	a4,6
    80001a92:	6685                	lui	a3,0x1
    80001a94:	40b905b3          	sub	a1,s2,a1
    80001a98:	854e                	mv	a0,s3
    80001a9a:	efaff0ef          	jal	ra,80001194 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a9e:	3e848493          	addi	s1,s1,1000
    80001aa2:	fd4499e3          	bne	s1,s4,80001a74 <proc_mapstacks+0x38>
  }
}
    80001aa6:	70e2                	ld	ra,56(sp)
    80001aa8:	7442                	ld	s0,48(sp)
    80001aaa:	74a2                	ld	s1,40(sp)
    80001aac:	7902                	ld	s2,32(sp)
    80001aae:	69e2                	ld	s3,24(sp)
    80001ab0:	6a42                	ld	s4,16(sp)
    80001ab2:	6aa2                	ld	s5,8(sp)
    80001ab4:	6b02                	ld	s6,0(sp)
    80001ab6:	6121                	addi	sp,sp,64
    80001ab8:	8082                	ret
      panic("kalloc");
    80001aba:	00006517          	auipc	a0,0x6
    80001abe:	6be50513          	addi	a0,a0,1726 # 80008178 <digits+0x140>
    80001ac2:	cc9fe0ef          	jal	ra,8000078a <panic>

0000000080001ac6 <procinit>:
 * 2. 为每个进程分配锁并初始化状态为UNUSED
 * 3. 设置每个进程的内核栈地址
 */
void
procinit(void)
{
    80001ac6:	7139                	addi	sp,sp,-64
    80001ac8:	fc06                	sd	ra,56(sp)
    80001aca:	f822                	sd	s0,48(sp)
    80001acc:	f426                	sd	s1,40(sp)
    80001ace:	f04a                	sd	s2,32(sp)
    80001ad0:	ec4e                	sd	s3,24(sp)
    80001ad2:	e852                	sd	s4,16(sp)
    80001ad4:	e456                	sd	s5,8(sp)
    80001ad6:	e05a                	sd	s6,0(sp)
    80001ad8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001ada:	00006597          	auipc	a1,0x6
    80001ade:	6a658593          	addi	a1,a1,1702 # 80008180 <digits+0x148>
    80001ae2:	0022f517          	auipc	a0,0x22f
    80001ae6:	f1e50513          	addi	a0,a0,-226 # 80230a00 <pid_lock>
    80001aea:	946ff0ef          	jal	ra,80000c30 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001aee:	00006597          	auipc	a1,0x6
    80001af2:	69a58593          	addi	a1,a1,1690 # 80008188 <digits+0x150>
    80001af6:	0022f517          	auipc	a0,0x22f
    80001afa:	f2250513          	addi	a0,a0,-222 # 80230a18 <wait_lock>
    80001afe:	932ff0ef          	jal	ra,80000c30 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b02:	0022f497          	auipc	s1,0x22f
    80001b06:	32e48493          	addi	s1,s1,814 # 80230e30 <proc>
      initlock(&p->lock, "proc");
    80001b0a:	00006b17          	auipc	s6,0x6
    80001b0e:	68eb0b13          	addi	s6,s6,1678 # 80008198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001b12:	8aa6                	mv	s5,s1
    80001b14:	00006a17          	auipc	s4,0x6
    80001b18:	4eca0a13          	addi	s4,s4,1260 # 80008000 <etext>
    80001b1c:	04000937          	lui	s2,0x4000
    80001b20:	197d                	addi	s2,s2,-1
    80001b22:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b24:	0023f997          	auipc	s3,0x23f
    80001b28:	d0c98993          	addi	s3,s3,-756 # 80240830 <tickslock>
      initlock(&p->lock, "proc");
    80001b2c:	85da                	mv	a1,s6
    80001b2e:	8526                	mv	a0,s1
    80001b30:	900ff0ef          	jal	ra,80000c30 <initlock>
      p->state = UNUSED;
    80001b34:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001b38:	415487b3          	sub	a5,s1,s5
    80001b3c:	878d                	srai	a5,a5,0x3
    80001b3e:	000a3703          	ld	a4,0(s4)
    80001b42:	02e787b3          	mul	a5,a5,a4
    80001b46:	2785                	addiw	a5,a5,1
    80001b48:	00d7979b          	slliw	a5,a5,0xd
    80001b4c:	40f907b3          	sub	a5,s2,a5
    80001b50:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b52:	3e848493          	addi	s1,s1,1000
    80001b56:	fd349be3          	bne	s1,s3,80001b2c <procinit+0x66>
  }
}
    80001b5a:	70e2                	ld	ra,56(sp)
    80001b5c:	7442                	ld	s0,48(sp)
    80001b5e:	74a2                	ld	s1,40(sp)
    80001b60:	7902                	ld	s2,32(sp)
    80001b62:	69e2                	ld	s3,24(sp)
    80001b64:	6a42                	ld	s4,16(sp)
    80001b66:	6aa2                	ld	s5,8(sp)
    80001b68:	6b02                	ld	s6,0(sp)
    80001b6a:	6121                	addi	sp,sp,64
    80001b6c:	8082                	ret

0000000080001b6e <cpuid>:
 * 返回值：
 *   当前CPU的ID
 */
int
cpuid()
{
    80001b6e:	1141                	addi	sp,sp,-16
    80001b70:	e422                	sd	s0,8(sp)
    80001b72:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b74:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b76:	2501                	sext.w	a0,a0
    80001b78:	6422                	ld	s0,8(sp)
    80001b7a:	0141                	addi	sp,sp,16
    80001b7c:	8082                	ret

0000000080001b7e <mycpu>:
 * 返回值：
 *   当前CPU的cpu结构体指针
 */
struct cpu*
mycpu(void)
{
    80001b7e:	1141                	addi	sp,sp,-16
    80001b80:	e422                	sd	s0,8(sp)
    80001b82:	0800                	addi	s0,sp,16
    80001b84:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b86:	2781                	sext.w	a5,a5
    80001b88:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b8a:	0022f517          	auipc	a0,0x22f
    80001b8e:	ea650513          	addi	a0,a0,-346 # 80230a30 <cpus>
    80001b92:	953e                	add	a0,a0,a5
    80001b94:	6422                	ld	s0,8(sp)
    80001b96:	0141                	addi	sp,sp,16
    80001b98:	8082                	ret

0000000080001b9a <myproc>:
 * 返回值：
 *   当前进程的proc结构体指针，如果没有则返回0
 */
struct proc*
myproc(void)
{
    80001b9a:	1101                	addi	sp,sp,-32
    80001b9c:	ec06                	sd	ra,24(sp)
    80001b9e:	e822                	sd	s0,16(sp)
    80001ba0:	e426                	sd	s1,8(sp)
    80001ba2:	1000                	addi	s0,sp,32
  push_off();
    80001ba4:	8ccff0ef          	jal	ra,80000c70 <push_off>
    80001ba8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001baa:	2781                	sext.w	a5,a5
    80001bac:	079e                	slli	a5,a5,0x7
    80001bae:	0022f717          	auipc	a4,0x22f
    80001bb2:	e5270713          	addi	a4,a4,-430 # 80230a00 <pid_lock>
    80001bb6:	97ba                	add	a5,a5,a4
    80001bb8:	7b84                	ld	s1,48(a5)
  pop_off();
    80001bba:	93aff0ef          	jal	ra,80000cf4 <pop_off>
  return p;
}
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	60e2                	ld	ra,24(sp)
    80001bc2:	6442                	ld	s0,16(sp)
    80001bc4:	64a2                	ld	s1,8(sp)
    80001bc6:	6105                	addi	sp,sp,32
    80001bc8:	8082                	ret

0000000080001bca <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001bca:	7179                	addi	sp,sp,-48
    80001bcc:	f406                	sd	ra,40(sp)
    80001bce:	f022                	sd	s0,32(sp)
    80001bd0:	ec26                	sd	s1,24(sp)
    80001bd2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001bd4:	fc7ff0ef          	jal	ra,80001b9a <myproc>
    80001bd8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001bda:	96eff0ef          	jal	ra,80000d48 <release>

  if (first) {
    80001bde:	00007797          	auipc	a5,0x7
    80001be2:	cb27a783          	lw	a5,-846(a5) # 80008890 <first.1>
    80001be6:	cf8d                	beqz	a5,80001c20 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001be8:	4505                	li	a0,1
    80001bea:	59c020ef          	jal	ra,80004186 <fsinit>

    first = 0;
    80001bee:	00007797          	auipc	a5,0x7
    80001bf2:	ca07a123          	sw	zero,-862(a5) # 80008890 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001bf6:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001bfa:	00006517          	auipc	a0,0x6
    80001bfe:	5a650513          	addi	a0,a0,1446 # 800081a0 <digits+0x168>
    80001c02:	fca43823          	sd	a0,-48(s0)
    80001c06:	fc043c23          	sd	zero,-40(s0)
    80001c0a:	fd040593          	addi	a1,s0,-48
    80001c0e:	620030ef          	jal	ra,8000522e <kexec>
    80001c12:	6cbc                	ld	a5,88(s1)
    80001c14:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001c16:	6cbc                	ld	a5,88(s1)
    80001c18:	7bb8                	ld	a4,112(a5)
    80001c1a:	57fd                	li	a5,-1
    80001c1c:	02f70d63          	beq	a4,a5,80001c56 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001c20:	5ab000ef          	jal	ra,800029ca <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c24:	68a8                	ld	a0,80(s1)
    80001c26:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c28:	04000737          	lui	a4,0x4000
    80001c2c:	00005797          	auipc	a5,0x5
    80001c30:	47078793          	addi	a5,a5,1136 # 8000709c <userret>
    80001c34:	00005697          	auipc	a3,0x5
    80001c38:	3cc68693          	addi	a3,a3,972 # 80007000 <_trampoline>
    80001c3c:	8f95                	sub	a5,a5,a3
    80001c3e:	177d                	addi	a4,a4,-1
    80001c40:	0732                	slli	a4,a4,0xc
    80001c42:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c44:	577d                	li	a4,-1
    80001c46:	177e                	slli	a4,a4,0x3f
    80001c48:	8d59                	or	a0,a0,a4
    80001c4a:	9782                	jalr	a5
}
    80001c4c:	70a2                	ld	ra,40(sp)
    80001c4e:	7402                	ld	s0,32(sp)
    80001c50:	64e2                	ld	s1,24(sp)
    80001c52:	6145                	addi	sp,sp,48
    80001c54:	8082                	ret
      panic("exec");
    80001c56:	00006517          	auipc	a0,0x6
    80001c5a:	55250513          	addi	a0,a0,1362 # 800081a8 <digits+0x170>
    80001c5e:	b2dfe0ef          	jal	ra,8000078a <panic>

0000000080001c62 <allocpid>:
{
    80001c62:	1101                	addi	sp,sp,-32
    80001c64:	ec06                	sd	ra,24(sp)
    80001c66:	e822                	sd	s0,16(sp)
    80001c68:	e426                	sd	s1,8(sp)
    80001c6a:	e04a                	sd	s2,0(sp)
    80001c6c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c6e:	0022f917          	auipc	s2,0x22f
    80001c72:	d9290913          	addi	s2,s2,-622 # 80230a00 <pid_lock>
    80001c76:	854a                	mv	a0,s2
    80001c78:	838ff0ef          	jal	ra,80000cb0 <acquire>
  pid = nextpid;
    80001c7c:	00007797          	auipc	a5,0x7
    80001c80:	c1878793          	addi	a5,a5,-1000 # 80008894 <nextpid>
    80001c84:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c86:	0014871b          	addiw	a4,s1,1
    80001c8a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c8c:	854a                	mv	a0,s2
    80001c8e:	8baff0ef          	jal	ra,80000d48 <release>
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6902                	ld	s2,0(sp)
    80001c9c:	6105                	addi	sp,sp,32
    80001c9e:	8082                	ret

0000000080001ca0 <delete_shm_from_vmas>:
delete_shm_from_vmas(struct vma *vmas){
    80001ca0:	7139                	addi	sp,sp,-64
    80001ca2:	fc06                	sd	ra,56(sp)
    80001ca4:	f822                	sd	s0,48(sp)
    80001ca6:	f426                	sd	s1,40(sp)
    80001ca8:	f04a                	sd	s2,32(sp)
    80001caa:	ec4e                	sd	s3,24(sp)
    80001cac:	e852                	sd	s4,16(sp)
    80001cae:	e456                	sd	s5,8(sp)
    80001cb0:	0080                	addi	s0,sp,64
    80001cb2:	8a2a                	mv	s4,a0
    80001cb4:	84aa                	mv	s1,a0
  for(int i = 0; i < NVMA; i++){
    80001cb6:	4901                	li	s2,0
    80001cb8:	02850a93          	addi	s5,a0,40
    80001cbc:	49c1                	li	s3,16
    80001cbe:	a025                	j	80001ce6 <delete_shm_from_vmas+0x46>
    for(int j = 0; j < i; j++){
    80001cc0:	02878793          	addi	a5,a5,40
    80001cc4:	00d78a63          	beq	a5,a3,80001cd8 <delete_shm_from_vmas+0x38>
      if(vmas[j].used && vmas[j].is_shm && vmas[j].shm_key == key){
    80001cc8:	4398                	lw	a4,0(a5)
    80001cca:	db7d                	beqz	a4,80001cc0 <delete_shm_from_vmas+0x20>
    80001ccc:	5398                	lw	a4,32(a5)
    80001cce:	db6d                	beqz	a4,80001cc0 <delete_shm_from_vmas+0x20>
    80001cd0:	53d8                	lw	a4,36(a5)
    80001cd2:	fea717e3          	bne	a4,a0,80001cc0 <delete_shm_from_vmas+0x20>
    80001cd6:	a019                	j	80001cdc <delete_shm_from_vmas+0x3c>
    shm_put(key);
    80001cd8:	21d040ef          	jal	ra,800066f4 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001cdc:	2905                	addiw	s2,s2,1
    80001cde:	02848493          	addi	s1,s1,40
    80001ce2:	03390563          	beq	s2,s3,80001d0c <delete_shm_from_vmas+0x6c>
    if(!vmas[i].used || !vmas[i].is_shm) continue;
    80001ce6:	409c                	lw	a5,0(s1)
    80001ce8:	dbf5                	beqz	a5,80001cdc <delete_shm_from_vmas+0x3c>
    80001cea:	509c                	lw	a5,32(s1)
    80001cec:	dbe5                	beqz	a5,80001cdc <delete_shm_from_vmas+0x3c>
    int key = vmas[i].shm_key;
    80001cee:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001cf0:	ff2054e3          	blez	s2,80001cd8 <delete_shm_from_vmas+0x38>
    80001cf4:	fff9069b          	addiw	a3,s2,-1
    80001cf8:	02069793          	slli	a5,a3,0x20
    80001cfc:	9381                	srli	a5,a5,0x20
    80001cfe:	00279693          	slli	a3,a5,0x2
    80001d02:	96be                	add	a3,a3,a5
    80001d04:	068e                	slli	a3,a3,0x3
    80001d06:	96d6                	add	a3,a3,s5
    80001d08:	87d2                	mv	a5,s4
    80001d0a:	bf7d                	j	80001cc8 <delete_shm_from_vmas+0x28>
}
    80001d0c:	70e2                	ld	ra,56(sp)
    80001d0e:	7442                	ld	s0,48(sp)
    80001d10:	74a2                	ld	s1,40(sp)
    80001d12:	7902                	ld	s2,32(sp)
    80001d14:	69e2                	ld	s3,24(sp)
    80001d16:	6a42                	ld	s4,16(sp)
    80001d18:	6aa2                	ld	s5,8(sp)
    80001d1a:	6121                	addi	sp,sp,64
    80001d1c:	8082                	ret

0000000080001d1e <delete_shm_from_proc>:
delete_shm_from_proc(struct proc *p){
    80001d1e:	7139                	addi	sp,sp,-64
    80001d20:	fc06                	sd	ra,56(sp)
    80001d22:	f822                	sd	s0,48(sp)
    80001d24:	f426                	sd	s1,40(sp)
    80001d26:	f04a                	sd	s2,32(sp)
    80001d28:	ec4e                	sd	s3,24(sp)
    80001d2a:	e852                	sd	s4,16(sp)
    80001d2c:	e456                	sd	s5,8(sp)
    80001d2e:	0080                	addi	s0,sp,64
  for(int i = 0; i < NVMA; i++){
    80001d30:	16850a93          	addi	s5,a0,360
delete_shm_from_proc(struct proc *p){
    80001d34:	84d6                	mv	s1,s5
  for(int i = 0; i < NVMA; i++){
    80001d36:	4901                	li	s2,0
    80001d38:	19050a13          	addi	s4,a0,400
    80001d3c:	49c1                	li	s3,16
    80001d3e:	a025                	j	80001d66 <delete_shm_from_proc+0x48>
    for(int j = 0; j < i; j++){
    80001d40:	02878793          	addi	a5,a5,40
    80001d44:	00d78a63          	beq	a5,a3,80001d58 <delete_shm_from_proc+0x3a>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001d48:	4398                	lw	a4,0(a5)
    80001d4a:	db7d                	beqz	a4,80001d40 <delete_shm_from_proc+0x22>
    80001d4c:	5398                	lw	a4,32(a5)
    80001d4e:	db6d                	beqz	a4,80001d40 <delete_shm_from_proc+0x22>
    80001d50:	53d8                	lw	a4,36(a5)
    80001d52:	fea717e3          	bne	a4,a0,80001d40 <delete_shm_from_proc+0x22>
    80001d56:	a019                	j	80001d5c <delete_shm_from_proc+0x3e>
    shm_put(key);
    80001d58:	19d040ef          	jal	ra,800066f4 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001d5c:	2905                	addiw	s2,s2,1
    80001d5e:	02848493          	addi	s1,s1,40
    80001d62:	03390563          	beq	s2,s3,80001d8c <delete_shm_from_proc+0x6e>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001d66:	409c                	lw	a5,0(s1)
    80001d68:	dbf5                	beqz	a5,80001d5c <delete_shm_from_proc+0x3e>
    80001d6a:	509c                	lw	a5,32(s1)
    80001d6c:	dbe5                	beqz	a5,80001d5c <delete_shm_from_proc+0x3e>
    int key = p->vmas[i].shm_key;
    80001d6e:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d70:	ff2054e3          	blez	s2,80001d58 <delete_shm_from_proc+0x3a>
    80001d74:	fff9069b          	addiw	a3,s2,-1
    80001d78:	02069793          	slli	a5,a3,0x20
    80001d7c:	9381                	srli	a5,a5,0x20
    80001d7e:	00279693          	slli	a3,a5,0x2
    80001d82:	96be                	add	a3,a3,a5
    80001d84:	068e                	slli	a3,a3,0x3
    80001d86:	96d2                	add	a3,a3,s4
    80001d88:	87d6                	mv	a5,s5
    80001d8a:	bf7d                	j	80001d48 <delete_shm_from_proc+0x2a>
}
    80001d8c:	70e2                	ld	ra,56(sp)
    80001d8e:	7442                	ld	s0,48(sp)
    80001d90:	74a2                	ld	s1,40(sp)
    80001d92:	7902                	ld	s2,32(sp)
    80001d94:	69e2                	ld	s3,24(sp)
    80001d96:	6a42                	ld	s4,16(sp)
    80001d98:	6aa2                	ld	s5,8(sp)
    80001d9a:	6121                	addi	sp,sp,64
    80001d9c:	8082                	ret

0000000080001d9e <vma_release_all>:
{
    80001d9e:	7139                	addi	sp,sp,-64
    80001da0:	fc06                	sd	ra,56(sp)
    80001da2:	f822                	sd	s0,48(sp)
    80001da4:	f426                	sd	s1,40(sp)
    80001da6:	f04a                	sd	s2,32(sp)
    80001da8:	ec4e                	sd	s3,24(sp)
    80001daa:	e852                	sd	s4,16(sp)
    80001dac:	e456                	sd	s5,8(sp)
    80001dae:	e05a                	sd	s6,0(sp)
    80001db0:	0080                	addi	s0,sp,64
    80001db2:	8b2a                	mv	s6,a0
  for(int i = 0; i < NVMA; i++){
    80001db4:	16850493          	addi	s1,a0,360
    80001db8:	3e850a13          	addi	s4,a0,1000
{
    80001dbc:	8926                	mv	s2,s1
    80001dbe:	a029                	j	80001dc8 <vma_release_all+0x2a>
  for(int i = 0; i < NVMA; i++){
    80001dc0:	02890913          	addi	s2,s2,40
    80001dc4:	03490663          	beq	s2,s4,80001df0 <vma_release_all+0x52>
    if(!v->used) continue;
    80001dc8:	00092783          	lw	a5,0(s2)
    80001dcc:	dbf5                	beqz	a5,80001dc0 <vma_release_all+0x22>
    uint64 start = v->start;
    80001dce:	00893583          	ld	a1,8(s2)
    uint64 end   = v->end;
    80001dd2:	01093603          	ld	a2,16(s2)
    if(end <= start) continue;
    80001dd6:	fec5f5e3          	bgeu	a1,a2,80001dc0 <vma_release_all+0x22>
    int do_free = (v->is_shm ? 0 : 1);
    80001dda:	02092683          	lw	a3,32(s2)
    uint64 npages = (end - start) / PGSIZE;
    80001dde:	8e0d                	sub	a2,a2,a1
    uvmunmap(p->pagetable, start, npages, do_free);
    80001de0:	0016b693          	seqz	a3,a3
    80001de4:	8231                	srli	a2,a2,0xc
    80001de6:	050b3503          	ld	a0,80(s6)
    80001dea:	cc6ff0ef          	jal	ra,800012b0 <uvmunmap>
    80001dee:	bfc9                	j	80001dc0 <vma_release_all+0x22>
    80001df0:	8926                	mv	s2,s1
  for(int i = 0; i < NVMA; i++){
    80001df2:	4981                	li	s3,0
    80001df4:	190b0b13          	addi	s6,s6,400
    80001df8:	4ac1                	li	s5,16
    80001dfa:	a891                	j	80001e4e <vma_release_all+0xb0>
    for(int j = 0; j < i; j++){
    80001dfc:	02878793          	addi	a5,a5,40
    80001e00:	04d78063          	beq	a5,a3,80001e40 <vma_release_all+0xa2>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001e04:	4398                	lw	a4,0(a5)
    80001e06:	db7d                	beqz	a4,80001dfc <vma_release_all+0x5e>
    80001e08:	5398                	lw	a4,32(a5)
    80001e0a:	db6d                	beqz	a4,80001dfc <vma_release_all+0x5e>
    80001e0c:	53d8                	lw	a4,36(a5)
    80001e0e:	fea717e3          	bne	a4,a0,80001dfc <vma_release_all+0x5e>
    80001e12:	a80d                	j	80001e44 <vma_release_all+0xa6>
      p->vmas[i].shm_key = -1;
    80001e14:	577d                	li	a4,-1
    80001e16:	a029                	j	80001e20 <vma_release_all+0x82>
  for(int i = 0; i < NVMA; i++){
    80001e18:	02848493          	addi	s1,s1,40
    80001e1c:	05448f63          	beq	s1,s4,80001e7a <vma_release_all+0xdc>
    if(p->vmas[i].used){
    80001e20:	409c                	lw	a5,0(s1)
    80001e22:	dbfd                	beqz	a5,80001e18 <vma_release_all+0x7a>
      p->vmas[i].used = 0;
    80001e24:	0004a023          	sw	zero,0(s1)
      p->vmas[i].is_shm = 0;
    80001e28:	0204a023          	sw	zero,32(s1)
      p->vmas[i].shm_key = -1;
    80001e2c:	d0d8                	sw	a4,36(s1)
      p->vmas[i].start = p->vmas[i].end = 0;
    80001e2e:	0004b823          	sd	zero,16(s1)
    80001e32:	0004b423          	sd	zero,8(s1)
      p->vmas[i].prot = p->vmas[i].flags = 0;
    80001e36:	0004ae23          	sw	zero,28(s1)
    80001e3a:	0004ac23          	sw	zero,24(s1)
    80001e3e:	bfe9                	j	80001e18 <vma_release_all+0x7a>
    shm_put(key);
    80001e40:	0b5040ef          	jal	ra,800066f4 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001e44:	2985                	addiw	s3,s3,1
    80001e46:	02890913          	addi	s2,s2,40
    80001e4a:	fd5985e3          	beq	s3,s5,80001e14 <vma_release_all+0x76>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001e4e:	00092783          	lw	a5,0(s2)
    80001e52:	dbed                	beqz	a5,80001e44 <vma_release_all+0xa6>
    80001e54:	02092783          	lw	a5,32(s2)
    80001e58:	d7f5                	beqz	a5,80001e44 <vma_release_all+0xa6>
    int key = p->vmas[i].shm_key;
    80001e5a:	02492503          	lw	a0,36(s2)
    for(int j = 0; j < i; j++){
    80001e5e:	ff3051e3          	blez	s3,80001e40 <vma_release_all+0xa2>
    80001e62:	fff9869b          	addiw	a3,s3,-1
    80001e66:	02069793          	slli	a5,a3,0x20
    80001e6a:	9381                	srli	a5,a5,0x20
    80001e6c:	00279693          	slli	a3,a5,0x2
    80001e70:	96be                	add	a3,a3,a5
    80001e72:	068e                	slli	a3,a3,0x3
    80001e74:	96da                	add	a3,a3,s6
    80001e76:	87a6                	mv	a5,s1
    80001e78:	b771                	j	80001e04 <vma_release_all+0x66>
}
    80001e7a:	70e2                	ld	ra,56(sp)
    80001e7c:	7442                	ld	s0,48(sp)
    80001e7e:	74a2                	ld	s1,40(sp)
    80001e80:	7902                	ld	s2,32(sp)
    80001e82:	69e2                	ld	s3,24(sp)
    80001e84:	6a42                	ld	s4,16(sp)
    80001e86:	6aa2                	ld	s5,8(sp)
    80001e88:	6b02                	ld	s6,0(sp)
    80001e8a:	6121                	addi	sp,sp,64
    80001e8c:	8082                	ret

0000000080001e8e <proc_pagetable>:
{
    80001e8e:	1101                	addi	sp,sp,-32
    80001e90:	ec06                	sd	ra,24(sp)
    80001e92:	e822                	sd	s0,16(sp)
    80001e94:	e426                	sd	s1,8(sp)
    80001e96:	e04a                	sd	s2,0(sp)
    80001e98:	1000                	addi	s0,sp,32
    80001e9a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e9c:	beeff0ef          	jal	ra,8000128a <uvmcreate>
    80001ea0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ea2:	cd05                	beqz	a0,80001eda <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ea4:	4729                	li	a4,10
    80001ea6:	00005697          	auipc	a3,0x5
    80001eaa:	15a68693          	addi	a3,a3,346 # 80007000 <_trampoline>
    80001eae:	6605                	lui	a2,0x1
    80001eb0:	040005b7          	lui	a1,0x4000
    80001eb4:	15fd                	addi	a1,a1,-1
    80001eb6:	05b2                	slli	a1,a1,0xc
    80001eb8:	a2cff0ef          	jal	ra,800010e4 <mappages>
    80001ebc:	02054663          	bltz	a0,80001ee8 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ec0:	4719                	li	a4,6
    80001ec2:	05893683          	ld	a3,88(s2)
    80001ec6:	6605                	lui	a2,0x1
    80001ec8:	020005b7          	lui	a1,0x2000
    80001ecc:	15fd                	addi	a1,a1,-1
    80001ece:	05b6                	slli	a1,a1,0xd
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	a12ff0ef          	jal	ra,800010e4 <mappages>
    80001ed6:	00054f63          	bltz	a0,80001ef4 <proc_pagetable+0x66>
}
    80001eda:	8526                	mv	a0,s1
    80001edc:	60e2                	ld	ra,24(sp)
    80001ede:	6442                	ld	s0,16(sp)
    80001ee0:	64a2                	ld	s1,8(sp)
    80001ee2:	6902                	ld	s2,0(sp)
    80001ee4:	6105                	addi	sp,sp,32
    80001ee6:	8082                	ret
    uvmfree(pagetable, 0);
    80001ee8:	4581                	li	a1,0
    80001eea:	8526                	mv	a0,s1
    80001eec:	d7cff0ef          	jal	ra,80001468 <uvmfree>
    return 0;
    80001ef0:	4481                	li	s1,0
    80001ef2:	b7e5                	j	80001eda <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ef4:	4681                	li	a3,0
    80001ef6:	4605                	li	a2,1
    80001ef8:	040005b7          	lui	a1,0x4000
    80001efc:	15fd                	addi	a1,a1,-1
    80001efe:	05b2                	slli	a1,a1,0xc
    80001f00:	8526                	mv	a0,s1
    80001f02:	baeff0ef          	jal	ra,800012b0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f06:	4581                	li	a1,0
    80001f08:	8526                	mv	a0,s1
    80001f0a:	d5eff0ef          	jal	ra,80001468 <uvmfree>
    return 0;
    80001f0e:	4481                	li	s1,0
    80001f10:	b7e9                	j	80001eda <proc_pagetable+0x4c>

0000000080001f12 <vma_unmap_pagetable>:
{
    80001f12:	7179                	addi	sp,sp,-48
    80001f14:	f406                	sd	ra,40(sp)
    80001f16:	f022                	sd	s0,32(sp)
    80001f18:	ec26                	sd	s1,24(sp)
    80001f1a:	e84a                	sd	s2,16(sp)
    80001f1c:	e44e                	sd	s3,8(sp)
    80001f1e:	1800                	addi	s0,sp,48
    80001f20:	89aa                	mv	s3,a0
    80001f22:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001f24:	28058913          	addi	s2,a1,640 # 4000280 <_entry-0x7bfffd80>
    80001f28:	a811                	j	80001f3c <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001f2a:	4685                	li	a3,1
    80001f2c:	8231                	srli	a2,a2,0xc
    80001f2e:	854e                	mv	a0,s3
    80001f30:	b80ff0ef          	jal	ra,800012b0 <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001f34:	02848493          	addi	s1,s1,40
    80001f38:	01248b63          	beq	s1,s2,80001f4e <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001f3c:	409c                	lw	a5,0(s1)
    80001f3e:	dbfd                	beqz	a5,80001f34 <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001f40:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001f42:	689c                	ld	a5,16(s1)
    80001f44:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001f48:	feb786e3          	beq	a5,a1,80001f34 <vma_unmap_pagetable+0x22>
    80001f4c:	bff9                	j	80001f2a <vma_unmap_pagetable+0x18>
}
    80001f4e:	70a2                	ld	ra,40(sp)
    80001f50:	7402                	ld	s0,32(sp)
    80001f52:	64e2                	ld	s1,24(sp)
    80001f54:	6942                	ld	s2,16(sp)
    80001f56:	69a2                	ld	s3,8(sp)
    80001f58:	6145                	addi	sp,sp,48
    80001f5a:	8082                	ret

0000000080001f5c <proc_freepagetable>:
{
    80001f5c:	1101                	addi	sp,sp,-32
    80001f5e:	ec06                	sd	ra,24(sp)
    80001f60:	e822                	sd	s0,16(sp)
    80001f62:	e426                	sd	s1,8(sp)
    80001f64:	e04a                	sd	s2,0(sp)
    80001f66:	1000                	addi	s0,sp,32
    80001f68:	84aa                	mv	s1,a0
    80001f6a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f6c:	4681                	li	a3,0
    80001f6e:	4605                	li	a2,1
    80001f70:	040005b7          	lui	a1,0x4000
    80001f74:	15fd                	addi	a1,a1,-1
    80001f76:	05b2                	slli	a1,a1,0xc
    80001f78:	b38ff0ef          	jal	ra,800012b0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f7c:	4681                	li	a3,0
    80001f7e:	4605                	li	a2,1
    80001f80:	020005b7          	lui	a1,0x2000
    80001f84:	15fd                	addi	a1,a1,-1
    80001f86:	05b6                	slli	a1,a1,0xd
    80001f88:	8526                	mv	a0,s1
    80001f8a:	b26ff0ef          	jal	ra,800012b0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f8e:	85ca                	mv	a1,s2
    80001f90:	8526                	mv	a0,s1
    80001f92:	cd6ff0ef          	jal	ra,80001468 <uvmfree>
}
    80001f96:	60e2                	ld	ra,24(sp)
    80001f98:	6442                	ld	s0,16(sp)
    80001f9a:	64a2                	ld	s1,8(sp)
    80001f9c:	6902                	ld	s2,0(sp)
    80001f9e:	6105                	addi	sp,sp,32
    80001fa0:	8082                	ret

0000000080001fa2 <freeproc>:
{
    80001fa2:	1101                	addi	sp,sp,-32
    80001fa4:	ec06                	sd	ra,24(sp)
    80001fa6:	e822                	sd	s0,16(sp)
    80001fa8:	e426                	sd	s1,8(sp)
    80001faa:	e04a                	sd	s2,0(sp)
    80001fac:	1000                	addi	s0,sp,32
    80001fae:	84aa                	mv	s1,a0
  vma_release_all(p);
    80001fb0:	defff0ef          	jal	ra,80001d9e <vma_release_all>
  if(p->trapframe)
    80001fb4:	6ca8                	ld	a0,88(s1)
    80001fb6:	c119                	beqz	a0,80001fbc <freeproc+0x1a>
    kfree((void*)p->trapframe);
    80001fb8:	ac7fe0ef          	jal	ra,80000a7e <kfree>
  p->trapframe = 0;
    80001fbc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001fc0:	68a8                	ld	a0,80(s1)
    80001fc2:	c105                	beqz	a0,80001fe2 <freeproc+0x40>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001fc4:	16848913          	addi	s2,s1,360
    80001fc8:	85ca                	mv	a1,s2
    80001fca:	f49ff0ef          	jal	ra,80001f12 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001fce:	28000613          	li	a2,640
    80001fd2:	4581                	li	a1,0
    80001fd4:	854a                	mv	a0,s2
    80001fd6:	daffe0ef          	jal	ra,80000d84 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001fda:	64ac                	ld	a1,72(s1)
    80001fdc:	68a8                	ld	a0,80(s1)
    80001fde:	f7fff0ef          	jal	ra,80001f5c <proc_freepagetable>
  delete_shm_from_proc(p);
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	d3bff0ef          	jal	ra,80001d1e <delete_shm_from_proc>
  p->pagetable = 0;
    80001fe8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001fec:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ff0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ff4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ff8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ffc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002000:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002004:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002008:	0004ac23          	sw	zero,24(s1)
}
    8000200c:	60e2                	ld	ra,24(sp)
    8000200e:	6442                	ld	s0,16(sp)
    80002010:	64a2                	ld	s1,8(sp)
    80002012:	6902                	ld	s2,0(sp)
    80002014:	6105                	addi	sp,sp,32
    80002016:	8082                	ret

0000000080002018 <allocproc>:
{
    80002018:	1101                	addi	sp,sp,-32
    8000201a:	ec06                	sd	ra,24(sp)
    8000201c:	e822                	sd	s0,16(sp)
    8000201e:	e426                	sd	s1,8(sp)
    80002020:	e04a                	sd	s2,0(sp)
    80002022:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002024:	0022f497          	auipc	s1,0x22f
    80002028:	e0c48493          	addi	s1,s1,-500 # 80230e30 <proc>
    8000202c:	0023f917          	auipc	s2,0x23f
    80002030:	80490913          	addi	s2,s2,-2044 # 80240830 <tickslock>
    acquire(&p->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	c7bfe0ef          	jal	ra,80000cb0 <acquire>
    if(p->state == UNUSED) {
    8000203a:	4c9c                	lw	a5,24(s1)
    8000203c:	cb91                	beqz	a5,80002050 <allocproc+0x38>
      release(&p->lock);
    8000203e:	8526                	mv	a0,s1
    80002040:	d09fe0ef          	jal	ra,80000d48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002044:	3e848493          	addi	s1,s1,1000
    80002048:	ff2496e3          	bne	s1,s2,80002034 <allocproc+0x1c>
  return 0;
    8000204c:	4481                	li	s1,0
    8000204e:	a089                	j	80002090 <allocproc+0x78>
  p->pid = allocpid();
    80002050:	c13ff0ef          	jal	ra,80001c62 <allocpid>
    80002054:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002056:	4785                	li	a5,1
    80002058:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000205a:	b53fe0ef          	jal	ra,80000bac <kalloc>
    8000205e:	892a                	mv	s2,a0
    80002060:	eca8                	sd	a0,88(s1)
    80002062:	cd15                	beqz	a0,8000209e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80002064:	8526                	mv	a0,s1
    80002066:	e29ff0ef          	jal	ra,80001e8e <proc_pagetable>
    8000206a:	892a                	mv	s2,a0
    8000206c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000206e:	c121                	beqz	a0,800020ae <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80002070:	07000613          	li	a2,112
    80002074:	4581                	li	a1,0
    80002076:	06048513          	addi	a0,s1,96
    8000207a:	d0bfe0ef          	jal	ra,80000d84 <memset>
  p->context.ra = (uint64)forkret;
    8000207e:	00000797          	auipc	a5,0x0
    80002082:	b4c78793          	addi	a5,a5,-1204 # 80001bca <forkret>
    80002086:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002088:	60bc                	ld	a5,64(s1)
    8000208a:	6705                	lui	a4,0x1
    8000208c:	97ba                	add	a5,a5,a4
    8000208e:	f4bc                	sd	a5,104(s1)
}
    80002090:	8526                	mv	a0,s1
    80002092:	60e2                	ld	ra,24(sp)
    80002094:	6442                	ld	s0,16(sp)
    80002096:	64a2                	ld	s1,8(sp)
    80002098:	6902                	ld	s2,0(sp)
    8000209a:	6105                	addi	sp,sp,32
    8000209c:	8082                	ret
    freeproc(p);
    8000209e:	8526                	mv	a0,s1
    800020a0:	f03ff0ef          	jal	ra,80001fa2 <freeproc>
    release(&p->lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	ca3fe0ef          	jal	ra,80000d48 <release>
    return 0;
    800020aa:	84ca                	mv	s1,s2
    800020ac:	b7d5                	j	80002090 <allocproc+0x78>
    freeproc(p);
    800020ae:	8526                	mv	a0,s1
    800020b0:	ef3ff0ef          	jal	ra,80001fa2 <freeproc>
    release(&p->lock);
    800020b4:	8526                	mv	a0,s1
    800020b6:	c93fe0ef          	jal	ra,80000d48 <release>
    return 0;
    800020ba:	84ca                	mv	s1,s2
    800020bc:	bfd1                	j	80002090 <allocproc+0x78>

00000000800020be <userinit>:
{
    800020be:	1101                	addi	sp,sp,-32
    800020c0:	ec06                	sd	ra,24(sp)
    800020c2:	e822                	sd	s0,16(sp)
    800020c4:	e426                	sd	s1,8(sp)
    800020c6:	1000                	addi	s0,sp,32
  p = allocproc();
    800020c8:	f51ff0ef          	jal	ra,80002018 <allocproc>
    800020cc:	84aa                	mv	s1,a0
  initproc = p;
    800020ce:	00006797          	auipc	a5,0x6
    800020d2:	7ea7b923          	sd	a0,2034(a5) # 800088c0 <initproc>
  p->cwd = namei("/");
    800020d6:	00006517          	auipc	a0,0x6
    800020da:	0da50513          	addi	a0,a0,218 # 800081b0 <digits+0x178>
    800020de:	5a6020ef          	jal	ra,80004684 <namei>
    800020e2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800020e6:	478d                	li	a5,3
    800020e8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	c5dfe0ef          	jal	ra,80000d48 <release>
}
    800020f0:	60e2                	ld	ra,24(sp)
    800020f2:	6442                	ld	s0,16(sp)
    800020f4:	64a2                	ld	s1,8(sp)
    800020f6:	6105                	addi	sp,sp,32
    800020f8:	8082                	ret

00000000800020fa <growproc>:
{
    800020fa:	1101                	addi	sp,sp,-32
    800020fc:	ec06                	sd	ra,24(sp)
    800020fe:	e822                	sd	s0,16(sp)
    80002100:	e426                	sd	s1,8(sp)
    80002102:	e04a                	sd	s2,0(sp)
    80002104:	1000                	addi	s0,sp,32
    80002106:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002108:	a93ff0ef          	jal	ra,80001b9a <myproc>
    8000210c:	892a                	mv	s2,a0
  sz = p->sz;
    8000210e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80002110:	02905963          	blez	s1,80002142 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80002114:	00b48633          	add	a2,s1,a1
    80002118:	020007b7          	lui	a5,0x2000
    8000211c:	17fd                	addi	a5,a5,-1
    8000211e:	07b6                	slli	a5,a5,0xd
    80002120:	02c7ea63          	bltu	a5,a2,80002154 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002124:	4691                	li	a3,4
    80002126:	6928                	ld	a0,80(a0)
    80002128:	a48ff0ef          	jal	ra,80001370 <uvmalloc>
    8000212c:	85aa                	mv	a1,a0
    8000212e:	c50d                	beqz	a0,80002158 <growproc+0x5e>
  p->sz = sz;
    80002130:	04b93423          	sd	a1,72(s2)
  return 0;
    80002134:	4501                	li	a0,0
}
    80002136:	60e2                	ld	ra,24(sp)
    80002138:	6442                	ld	s0,16(sp)
    8000213a:	64a2                	ld	s1,8(sp)
    8000213c:	6902                	ld	s2,0(sp)
    8000213e:	6105                	addi	sp,sp,32
    80002140:	8082                	ret
  } else if(n < 0){
    80002142:	fe04d7e3          	bgez	s1,80002130 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002146:	00b48633          	add	a2,s1,a1
    8000214a:	6928                	ld	a0,80(a0)
    8000214c:	9e0ff0ef          	jal	ra,8000132c <uvmdealloc>
    80002150:	85aa                	mv	a1,a0
    80002152:	bff9                	j	80002130 <growproc+0x36>
      return -1;
    80002154:	557d                	li	a0,-1
    80002156:	b7c5                	j	80002136 <growproc+0x3c>
      return -1;
    80002158:	557d                	li	a0,-1
    8000215a:	bff1                	j	80002136 <growproc+0x3c>

000000008000215c <kfork>:
{
    8000215c:	715d                	addi	sp,sp,-80
    8000215e:	e486                	sd	ra,72(sp)
    80002160:	e0a2                	sd	s0,64(sp)
    80002162:	fc26                	sd	s1,56(sp)
    80002164:	f84a                	sd	s2,48(sp)
    80002166:	f44e                	sd	s3,40(sp)
    80002168:	f052                	sd	s4,32(sp)
    8000216a:	ec56                	sd	s5,24(sp)
    8000216c:	e85a                	sd	s6,16(sp)
    8000216e:	e45e                	sd	s7,8(sp)
    80002170:	e062                	sd	s8,0(sp)
    80002172:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    80002174:	a27ff0ef          	jal	ra,80001b9a <myproc>
    80002178:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000217a:	e9fff0ef          	jal	ra,80002018 <allocproc>
    8000217e:	12050963          	beqz	a0,800022b0 <kfork+0x154>
    80002182:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002184:	048ab603          	ld	a2,72(s5)
    80002188:	692c                	ld	a1,80(a0)
    8000218a:	050ab503          	ld	a0,80(s5)
    8000218e:	b0aff0ef          	jal	ra,80001498 <uvmcopy>
    80002192:	04054863          	bltz	a0,800021e2 <kfork+0x86>
  np->sz = p->sz;
    80002196:	048ab783          	ld	a5,72(s5)
    8000219a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000219e:	058ab683          	ld	a3,88(s5)
    800021a2:	87b6                	mv	a5,a3
    800021a4:	0589b703          	ld	a4,88(s3)
    800021a8:	12068693          	addi	a3,a3,288
    800021ac:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    800021b0:	6788                	ld	a0,8(a5)
    800021b2:	6b8c                	ld	a1,16(a5)
    800021b4:	6f90                	ld	a2,24(a5)
    800021b6:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800021ba:	e708                	sd	a0,8(a4)
    800021bc:	eb0c                	sd	a1,16(a4)
    800021be:	ef10                	sd	a2,24(a4)
    800021c0:	02078793          	addi	a5,a5,32
    800021c4:	02070713          	addi	a4,a4,32
    800021c8:	fed792e3          	bne	a5,a3,800021ac <kfork+0x50>
  np->trapframe->a0 = 0;
    800021cc:	0589b783          	ld	a5,88(s3)
    800021d0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800021d4:	0d0a8493          	addi	s1,s5,208
    800021d8:	0d098913          	addi	s2,s3,208
    800021dc:	150a8a13          	addi	s4,s5,336
    800021e0:	a829                	j	800021fa <kfork+0x9e>
    freeproc(np);
    800021e2:	854e                	mv	a0,s3
    800021e4:	dbfff0ef          	jal	ra,80001fa2 <freeproc>
    release(&np->lock);
    800021e8:	854e                	mv	a0,s3
    800021ea:	b5ffe0ef          	jal	ra,80000d48 <release>
    return -1;
    800021ee:	5c7d                	li	s8,-1
    800021f0:	a05d                	j	80002296 <kfork+0x13a>
  for(i = 0; i < NOFILE; i++)
    800021f2:	04a1                	addi	s1,s1,8
    800021f4:	0921                	addi	s2,s2,8
    800021f6:	01448963          	beq	s1,s4,80002208 <kfork+0xac>
    if(p->ofile[i])
    800021fa:	6088                	ld	a0,0(s1)
    800021fc:	d97d                	beqz	a0,800021f2 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    800021fe:	23f020ef          	jal	ra,80004c3c <filedup>
    80002202:	00a93023          	sd	a0,0(s2)
    80002206:	b7f5                	j	800021f2 <kfork+0x96>
  np->cwd = idup(p->cwd);
    80002208:	150ab503          	ld	a0,336(s5)
    8000220c:	455010ef          	jal	ra,80003e60 <idup>
    80002210:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002214:	4641                	li	a2,16
    80002216:	158a8593          	addi	a1,s5,344
    8000221a:	15898513          	addi	a0,s3,344
    8000221e:	cadfe0ef          	jal	ra,80000eca <safestrcpy>
  pid = np->pid;
    80002222:	0309ac03          	lw	s8,48(s3)
  release(&np->lock);
    80002226:	854e                	mv	a0,s3
    80002228:	b21fe0ef          	jal	ra,80000d48 <release>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    8000222c:	16898b13          	addi	s6,s3,360
    80002230:	28000613          	li	a2,640
    80002234:	168a8593          	addi	a1,s5,360
    80002238:	855a                	mv	a0,s6
    8000223a:	ba7fe0ef          	jal	ra,80000de0 <memmove>
    8000223e:	84da                	mv	s1,s6
  for(int i = 0; i < NVMA; i++){
    80002240:	4901                	li	s2,0
    80002242:	19098b93          	addi	s7,s3,400
    80002246:	4a41                	li	s4,16
    80002248:	a069                	j	800022d2 <kfork+0x176>
    for(int j = 0; j < i; j++){
    8000224a:	02878793          	addi	a5,a5,40
    8000224e:	06d78363          	beq	a5,a3,800022b4 <kfork+0x158>
      if(np->vmas[j].used && np->vmas[j].is_shm && np->vmas[j].shm_key == key){
    80002252:	4398                	lw	a4,0(a5)
    80002254:	db7d                	beqz	a4,8000224a <kfork+0xee>
    80002256:	5398                	lw	a4,32(a5)
    80002258:	db6d                	beqz	a4,8000224a <kfork+0xee>
    8000225a:	53d8                	lw	a4,36(a5)
    8000225c:	fea717e3          	bne	a4,a0,8000224a <kfork+0xee>
    80002260:	a0a5                	j	800022c8 <kfork+0x16c>
        freeproc(np);
    80002262:	854e                	mv	a0,s3
    80002264:	d3fff0ef          	jal	ra,80001fa2 <freeproc>
        return -1;
    80002268:	5c7d                	li	s8,-1
    8000226a:	a035                	j	80002296 <kfork+0x13a>
  acquire(&wait_lock);
    8000226c:	0022e497          	auipc	s1,0x22e
    80002270:	7ac48493          	addi	s1,s1,1964 # 80230a18 <wait_lock>
    80002274:	8526                	mv	a0,s1
    80002276:	a3bfe0ef          	jal	ra,80000cb0 <acquire>
  np->parent = p;
    8000227a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	ac9fe0ef          	jal	ra,80000d48 <release>
  acquire(&np->lock);
    80002284:	854e                	mv	a0,s3
    80002286:	a2bfe0ef          	jal	ra,80000cb0 <acquire>
  np->state = RUNNABLE;
    8000228a:	478d                	li	a5,3
    8000228c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002290:	854e                	mv	a0,s3
    80002292:	ab7fe0ef          	jal	ra,80000d48 <release>
}
    80002296:	8562                	mv	a0,s8
    80002298:	60a6                	ld	ra,72(sp)
    8000229a:	6406                	ld	s0,64(sp)
    8000229c:	74e2                	ld	s1,56(sp)
    8000229e:	7942                	ld	s2,48(sp)
    800022a0:	79a2                	ld	s3,40(sp)
    800022a2:	7a02                	ld	s4,32(sp)
    800022a4:	6ae2                	ld	s5,24(sp)
    800022a6:	6b42                	ld	s6,16(sp)
    800022a8:	6ba2                	ld	s7,8(sp)
    800022aa:	6c02                	ld	s8,0(sp)
    800022ac:	6161                	addi	sp,sp,80
    800022ae:	8082                	ret
    return -1;
    800022b0:	5c7d                	li	s8,-1
    800022b2:	b7d5                	j	80002296 <kfork+0x13a>
    int npages = (np->vmas[i].end - np->vmas[i].start) / PGSIZE;
    800022b4:	699c                	ld	a5,16(a1)
    800022b6:	658c                	ld	a1,8(a1)
    800022b8:	40b785b3          	sub	a1,a5,a1
    800022bc:	81b1                	srli	a1,a1,0xc
    if(shm_get(key, npages) < 0){
    800022be:	2581                	sext.w	a1,a1
    800022c0:	2f0040ef          	jal	ra,800065b0 <shm_get>
    800022c4:	f8054fe3          	bltz	a0,80002262 <kfork+0x106>
  for(int i = 0; i < NVMA; i++){
    800022c8:	2905                	addiw	s2,s2,1
    800022ca:	02848493          	addi	s1,s1,40
    800022ce:	f9490fe3          	beq	s2,s4,8000226c <kfork+0x110>
    if(!np->vmas[i].used || !np->vmas[i].is_shm) continue;
    800022d2:	85a6                	mv	a1,s1
    800022d4:	409c                	lw	a5,0(s1)
    800022d6:	dbed                	beqz	a5,800022c8 <kfork+0x16c>
    800022d8:	509c                	lw	a5,32(s1)
    800022da:	d7fd                	beqz	a5,800022c8 <kfork+0x16c>
    int key = np->vmas[i].shm_key;
    800022dc:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    800022de:	fd205be3          	blez	s2,800022b4 <kfork+0x158>
    800022e2:	fff9069b          	addiw	a3,s2,-1
    800022e6:	02069793          	slli	a5,a3,0x20
    800022ea:	9381                	srli	a5,a5,0x20
    800022ec:	00279693          	slli	a3,a5,0x2
    800022f0:	96be                	add	a3,a3,a5
    800022f2:	068e                	slli	a3,a3,0x3
    800022f4:	96de                	add	a3,a3,s7
    800022f6:	87da                	mv	a5,s6
    800022f8:	bfa9                	j	80002252 <kfork+0xf6>

00000000800022fa <scheduler>:
{
    800022fa:	715d                	addi	sp,sp,-80
    800022fc:	e486                	sd	ra,72(sp)
    800022fe:	e0a2                	sd	s0,64(sp)
    80002300:	fc26                	sd	s1,56(sp)
    80002302:	f84a                	sd	s2,48(sp)
    80002304:	f44e                	sd	s3,40(sp)
    80002306:	f052                	sd	s4,32(sp)
    80002308:	ec56                	sd	s5,24(sp)
    8000230a:	e85a                	sd	s6,16(sp)
    8000230c:	e45e                	sd	s7,8(sp)
    8000230e:	e062                	sd	s8,0(sp)
    80002310:	0880                	addi	s0,sp,80
    80002312:	8792                	mv	a5,tp
  int id = r_tp();
    80002314:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002316:	00779b13          	slli	s6,a5,0x7
    8000231a:	0022e717          	auipc	a4,0x22e
    8000231e:	6e670713          	addi	a4,a4,1766 # 80230a00 <pid_lock>
    80002322:	975a                	add	a4,a4,s6
    80002324:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002328:	0022e717          	auipc	a4,0x22e
    8000232c:	71070713          	addi	a4,a4,1808 # 80230a38 <cpus+0x8>
    80002330:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002332:	4c11                	li	s8,4
        c->proc = p;
    80002334:	079e                	slli	a5,a5,0x7
    80002336:	0022ea17          	auipc	s4,0x22e
    8000233a:	6caa0a13          	addi	s4,s4,1738 # 80230a00 <pid_lock>
    8000233e:	9a3e                	add	s4,s4,a5
        found = 1;
    80002340:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002342:	0023e997          	auipc	s3,0x23e
    80002346:	4ee98993          	addi	s3,s3,1262 # 80240830 <tickslock>
    8000234a:	a83d                	j	80002388 <scheduler+0x8e>
      release(&p->lock);
    8000234c:	8526                	mv	a0,s1
    8000234e:	9fbfe0ef          	jal	ra,80000d48 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002352:	3e848493          	addi	s1,s1,1000
    80002356:	03348563          	beq	s1,s3,80002380 <scheduler+0x86>
      acquire(&p->lock);
    8000235a:	8526                	mv	a0,s1
    8000235c:	955fe0ef          	jal	ra,80000cb0 <acquire>
      if(p->state == RUNNABLE) {
    80002360:	4c9c                	lw	a5,24(s1)
    80002362:	ff2795e3          	bne	a5,s2,8000234c <scheduler+0x52>
        p->state = RUNNING;
    80002366:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000236a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000236e:	06048593          	addi	a1,s1,96
    80002372:	855a                	mv	a0,s6
    80002374:	5b0000ef          	jal	ra,80002924 <swtch>
        c->proc = 0;
    80002378:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000237c:	8ade                	mv	s5,s7
    8000237e:	b7f9                	j	8000234c <scheduler+0x52>
    if(found == 0) {
    80002380:	000a9463          	bnez	s5,80002388 <scheduler+0x8e>
      asm volatile("wfi");
    80002384:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002388:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000238c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002390:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002394:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002398:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000239a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000239e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800023a0:	0022f497          	auipc	s1,0x22f
    800023a4:	a9048493          	addi	s1,s1,-1392 # 80230e30 <proc>
      if(p->state == RUNNABLE) {
    800023a8:	490d                	li	s2,3
    800023aa:	bf45                	j	8000235a <scheduler+0x60>

00000000800023ac <sched>:
{
    800023ac:	7179                	addi	sp,sp,-48
    800023ae:	f406                	sd	ra,40(sp)
    800023b0:	f022                	sd	s0,32(sp)
    800023b2:	ec26                	sd	s1,24(sp)
    800023b4:	e84a                	sd	s2,16(sp)
    800023b6:	e44e                	sd	s3,8(sp)
    800023b8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023ba:	fe0ff0ef          	jal	ra,80001b9a <myproc>
    800023be:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023c0:	887fe0ef          	jal	ra,80000c46 <holding>
    800023c4:	c92d                	beqz	a0,80002436 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023c6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023c8:	2781                	sext.w	a5,a5
    800023ca:	079e                	slli	a5,a5,0x7
    800023cc:	0022e717          	auipc	a4,0x22e
    800023d0:	63470713          	addi	a4,a4,1588 # 80230a00 <pid_lock>
    800023d4:	97ba                	add	a5,a5,a4
    800023d6:	0a87a703          	lw	a4,168(a5)
    800023da:	4785                	li	a5,1
    800023dc:	06f71363          	bne	a4,a5,80002442 <sched+0x96>
  if(p->state == RUNNING)
    800023e0:	4c98                	lw	a4,24(s1)
    800023e2:	4791                	li	a5,4
    800023e4:	06f70563          	beq	a4,a5,8000244e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023e8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023ec:	8b89                	andi	a5,a5,2
  if(intr_get())
    800023ee:	e7b5                	bnez	a5,8000245a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023f0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023f2:	0022e917          	auipc	s2,0x22e
    800023f6:	60e90913          	addi	s2,s2,1550 # 80230a00 <pid_lock>
    800023fa:	2781                	sext.w	a5,a5
    800023fc:	079e                	slli	a5,a5,0x7
    800023fe:	97ca                	add	a5,a5,s2
    80002400:	0ac7a983          	lw	s3,172(a5)
    80002404:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002406:	2781                	sext.w	a5,a5
    80002408:	079e                	slli	a5,a5,0x7
    8000240a:	0022e597          	auipc	a1,0x22e
    8000240e:	62e58593          	addi	a1,a1,1582 # 80230a38 <cpus+0x8>
    80002412:	95be                	add	a1,a1,a5
    80002414:	06048513          	addi	a0,s1,96
    80002418:	50c000ef          	jal	ra,80002924 <swtch>
    8000241c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000241e:	2781                	sext.w	a5,a5
    80002420:	079e                	slli	a5,a5,0x7
    80002422:	97ca                	add	a5,a5,s2
    80002424:	0b37a623          	sw	s3,172(a5)
}
    80002428:	70a2                	ld	ra,40(sp)
    8000242a:	7402                	ld	s0,32(sp)
    8000242c:	64e2                	ld	s1,24(sp)
    8000242e:	6942                	ld	s2,16(sp)
    80002430:	69a2                	ld	s3,8(sp)
    80002432:	6145                	addi	sp,sp,48
    80002434:	8082                	ret
    panic("sched p->lock");
    80002436:	00006517          	auipc	a0,0x6
    8000243a:	d8250513          	addi	a0,a0,-638 # 800081b8 <digits+0x180>
    8000243e:	b4cfe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80002442:	00006517          	auipc	a0,0x6
    80002446:	d8650513          	addi	a0,a0,-634 # 800081c8 <digits+0x190>
    8000244a:	b40fe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    8000244e:	00006517          	auipc	a0,0x6
    80002452:	d8a50513          	addi	a0,a0,-630 # 800081d8 <digits+0x1a0>
    80002456:	b34fe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    8000245a:	00006517          	auipc	a0,0x6
    8000245e:	d8e50513          	addi	a0,a0,-626 # 800081e8 <digits+0x1b0>
    80002462:	b28fe0ef          	jal	ra,8000078a <panic>

0000000080002466 <yield>:
{
    80002466:	1101                	addi	sp,sp,-32
    80002468:	ec06                	sd	ra,24(sp)
    8000246a:	e822                	sd	s0,16(sp)
    8000246c:	e426                	sd	s1,8(sp)
    8000246e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002470:	f2aff0ef          	jal	ra,80001b9a <myproc>
    80002474:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002476:	83bfe0ef          	jal	ra,80000cb0 <acquire>
  p->state = RUNNABLE;
    8000247a:	478d                	li	a5,3
    8000247c:	cc9c                	sw	a5,24(s1)
  sched();
    8000247e:	f2fff0ef          	jal	ra,800023ac <sched>
  release(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	8c5fe0ef          	jal	ra,80000d48 <release>
}
    80002488:	60e2                	ld	ra,24(sp)
    8000248a:	6442                	ld	s0,16(sp)
    8000248c:	64a2                	ld	s1,8(sp)
    8000248e:	6105                	addi	sp,sp,32
    80002490:	8082                	ret

0000000080002492 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002492:	7179                	addi	sp,sp,-48
    80002494:	f406                	sd	ra,40(sp)
    80002496:	f022                	sd	s0,32(sp)
    80002498:	ec26                	sd	s1,24(sp)
    8000249a:	e84a                	sd	s2,16(sp)
    8000249c:	e44e                	sd	s3,8(sp)
    8000249e:	1800                	addi	s0,sp,48
    800024a0:	89aa                	mv	s3,a0
    800024a2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024a4:	ef6ff0ef          	jal	ra,80001b9a <myproc>
    800024a8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800024aa:	807fe0ef          	jal	ra,80000cb0 <acquire>
  release(lk);
    800024ae:	854a                	mv	a0,s2
    800024b0:	899fe0ef          	jal	ra,80000d48 <release>

  // Go to sleep.
  p->chan = chan;
    800024b4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024b8:	4789                	li	a5,2
    800024ba:	cc9c                	sw	a5,24(s1)

  sched();
    800024bc:	ef1ff0ef          	jal	ra,800023ac <sched>

  // Tidy up.
  p->chan = 0;
    800024c0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	883fe0ef          	jal	ra,80000d48 <release>
  acquire(lk);
    800024ca:	854a                	mv	a0,s2
    800024cc:	fe4fe0ef          	jal	ra,80000cb0 <acquire>
}
    800024d0:	70a2                	ld	ra,40(sp)
    800024d2:	7402                	ld	s0,32(sp)
    800024d4:	64e2                	ld	s1,24(sp)
    800024d6:	6942                	ld	s2,16(sp)
    800024d8:	69a2                	ld	s3,8(sp)
    800024da:	6145                	addi	sp,sp,48
    800024dc:	8082                	ret

00000000800024de <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800024de:	7139                	addi	sp,sp,-64
    800024e0:	fc06                	sd	ra,56(sp)
    800024e2:	f822                	sd	s0,48(sp)
    800024e4:	f426                	sd	s1,40(sp)
    800024e6:	f04a                	sd	s2,32(sp)
    800024e8:	ec4e                	sd	s3,24(sp)
    800024ea:	e852                	sd	s4,16(sp)
    800024ec:	e456                	sd	s5,8(sp)
    800024ee:	0080                	addi	s0,sp,64
    800024f0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800024f2:	0022f497          	auipc	s1,0x22f
    800024f6:	93e48493          	addi	s1,s1,-1730 # 80230e30 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800024fa:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024fc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800024fe:	0023e917          	auipc	s2,0x23e
    80002502:	33290913          	addi	s2,s2,818 # 80240830 <tickslock>
    80002506:	a801                	j	80002516 <wakeup+0x38>
      }
      release(&p->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	83ffe0ef          	jal	ra,80000d48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000250e:	3e848493          	addi	s1,s1,1000
    80002512:	03248263          	beq	s1,s2,80002536 <wakeup+0x58>
    if(p != myproc()){
    80002516:	e84ff0ef          	jal	ra,80001b9a <myproc>
    8000251a:	fea48ae3          	beq	s1,a0,8000250e <wakeup+0x30>
      acquire(&p->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	f90fe0ef          	jal	ra,80000cb0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002524:	4c9c                	lw	a5,24(s1)
    80002526:	ff3791e3          	bne	a5,s3,80002508 <wakeup+0x2a>
    8000252a:	709c                	ld	a5,32(s1)
    8000252c:	fd479ee3          	bne	a5,s4,80002508 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002530:	0154ac23          	sw	s5,24(s1)
    80002534:	bfd1                	j	80002508 <wakeup+0x2a>
    }
  }
}
    80002536:	70e2                	ld	ra,56(sp)
    80002538:	7442                	ld	s0,48(sp)
    8000253a:	74a2                	ld	s1,40(sp)
    8000253c:	7902                	ld	s2,32(sp)
    8000253e:	69e2                	ld	s3,24(sp)
    80002540:	6a42                	ld	s4,16(sp)
    80002542:	6aa2                	ld	s5,8(sp)
    80002544:	6121                	addi	sp,sp,64
    80002546:	8082                	ret

0000000080002548 <reparent>:
{
    80002548:	7179                	addi	sp,sp,-48
    8000254a:	f406                	sd	ra,40(sp)
    8000254c:	f022                	sd	s0,32(sp)
    8000254e:	ec26                	sd	s1,24(sp)
    80002550:	e84a                	sd	s2,16(sp)
    80002552:	e44e                	sd	s3,8(sp)
    80002554:	e052                	sd	s4,0(sp)
    80002556:	1800                	addi	s0,sp,48
    80002558:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000255a:	0022f497          	auipc	s1,0x22f
    8000255e:	8d648493          	addi	s1,s1,-1834 # 80230e30 <proc>
      pp->parent = initproc;
    80002562:	00006a17          	auipc	s4,0x6
    80002566:	35ea0a13          	addi	s4,s4,862 # 800088c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000256a:	0023e997          	auipc	s3,0x23e
    8000256e:	2c698993          	addi	s3,s3,710 # 80240830 <tickslock>
    80002572:	a029                	j	8000257c <reparent+0x34>
    80002574:	3e848493          	addi	s1,s1,1000
    80002578:	01348b63          	beq	s1,s3,8000258e <reparent+0x46>
    if(pp->parent == p){
    8000257c:	7c9c                	ld	a5,56(s1)
    8000257e:	ff279be3          	bne	a5,s2,80002574 <reparent+0x2c>
      pp->parent = initproc;
    80002582:	000a3503          	ld	a0,0(s4)
    80002586:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002588:	f57ff0ef          	jal	ra,800024de <wakeup>
    8000258c:	b7e5                	j	80002574 <reparent+0x2c>
}
    8000258e:	70a2                	ld	ra,40(sp)
    80002590:	7402                	ld	s0,32(sp)
    80002592:	64e2                	ld	s1,24(sp)
    80002594:	6942                	ld	s2,16(sp)
    80002596:	69a2                	ld	s3,8(sp)
    80002598:	6a02                	ld	s4,0(sp)
    8000259a:	6145                	addi	sp,sp,48
    8000259c:	8082                	ret

000000008000259e <kexit>:
{
    8000259e:	7179                	addi	sp,sp,-48
    800025a0:	f406                	sd	ra,40(sp)
    800025a2:	f022                	sd	s0,32(sp)
    800025a4:	ec26                	sd	s1,24(sp)
    800025a6:	e84a                	sd	s2,16(sp)
    800025a8:	e44e                	sd	s3,8(sp)
    800025aa:	e052                	sd	s4,0(sp)
    800025ac:	1800                	addi	s0,sp,48
    800025ae:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025b0:	deaff0ef          	jal	ra,80001b9a <myproc>
    800025b4:	89aa                	mv	s3,a0
  if(p == initproc)
    800025b6:	00006797          	auipc	a5,0x6
    800025ba:	30a7b783          	ld	a5,778(a5) # 800088c0 <initproc>
    800025be:	0d050493          	addi	s1,a0,208
    800025c2:	15050913          	addi	s2,a0,336
    800025c6:	00a79f63          	bne	a5,a0,800025e4 <kexit+0x46>
    panic("init exiting");
    800025ca:	00006517          	auipc	a0,0x6
    800025ce:	c3650513          	addi	a0,a0,-970 # 80008200 <digits+0x1c8>
    800025d2:	9b8fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    800025d6:	6ac020ef          	jal	ra,80004c82 <fileclose>
      p->ofile[fd] = 0;
    800025da:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800025de:	04a1                	addi	s1,s1,8
    800025e0:	01248563          	beq	s1,s2,800025ea <kexit+0x4c>
    if(p->ofile[fd]){
    800025e4:	6088                	ld	a0,0(s1)
    800025e6:	f965                	bnez	a0,800025d6 <kexit+0x38>
    800025e8:	bfdd                	j	800025de <kexit+0x40>
  begin_op();
    800025ea:	28a020ef          	jal	ra,80004874 <begin_op>
  iput(p->cwd);
    800025ee:	1509b503          	ld	a0,336(s3)
    800025f2:	223010ef          	jal	ra,80004014 <iput>
  end_op();
    800025f6:	2ee020ef          	jal	ra,800048e4 <end_op>
  p->cwd = 0;
    800025fa:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025fe:	0022e497          	auipc	s1,0x22e
    80002602:	41a48493          	addi	s1,s1,1050 # 80230a18 <wait_lock>
    80002606:	8526                	mv	a0,s1
    80002608:	ea8fe0ef          	jal	ra,80000cb0 <acquire>
  reparent(p);
    8000260c:	854e                	mv	a0,s3
    8000260e:	f3bff0ef          	jal	ra,80002548 <reparent>
  wakeup(p->parent);
    80002612:	0389b503          	ld	a0,56(s3)
    80002616:	ec9ff0ef          	jal	ra,800024de <wakeup>
  acquire(&p->lock);
    8000261a:	854e                	mv	a0,s3
    8000261c:	e94fe0ef          	jal	ra,80000cb0 <acquire>
  p->xstate = status;
    80002620:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002624:	4795                	li	a5,5
    80002626:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000262a:	8526                	mv	a0,s1
    8000262c:	f1cfe0ef          	jal	ra,80000d48 <release>
  sched();
    80002630:	d7dff0ef          	jal	ra,800023ac <sched>
  panic("zombie exit");
    80002634:	00006517          	auipc	a0,0x6
    80002638:	bdc50513          	addi	a0,a0,-1060 # 80008210 <digits+0x1d8>
    8000263c:	94efe0ef          	jal	ra,8000078a <panic>

0000000080002640 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002640:	7179                	addi	sp,sp,-48
    80002642:	f406                	sd	ra,40(sp)
    80002644:	f022                	sd	s0,32(sp)
    80002646:	ec26                	sd	s1,24(sp)
    80002648:	e84a                	sd	s2,16(sp)
    8000264a:	e44e                	sd	s3,8(sp)
    8000264c:	1800                	addi	s0,sp,48
    8000264e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002650:	0022e497          	auipc	s1,0x22e
    80002654:	7e048493          	addi	s1,s1,2016 # 80230e30 <proc>
    80002658:	0023e997          	auipc	s3,0x23e
    8000265c:	1d898993          	addi	s3,s3,472 # 80240830 <tickslock>
    acquire(&p->lock);
    80002660:	8526                	mv	a0,s1
    80002662:	e4efe0ef          	jal	ra,80000cb0 <acquire>
    if(p->pid == pid){
    80002666:	589c                	lw	a5,48(s1)
    80002668:	01278b63          	beq	a5,s2,8000267e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000266c:	8526                	mv	a0,s1
    8000266e:	edafe0ef          	jal	ra,80000d48 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002672:	3e848493          	addi	s1,s1,1000
    80002676:	ff3495e3          	bne	s1,s3,80002660 <kkill+0x20>
  }
  return -1;
    8000267a:	557d                	li	a0,-1
    8000267c:	a819                	j	80002692 <kkill+0x52>
      p->killed = 1;
    8000267e:	4785                	li	a5,1
    80002680:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002682:	4c98                	lw	a4,24(s1)
    80002684:	4789                	li	a5,2
    80002686:	00f70d63          	beq	a4,a5,800026a0 <kkill+0x60>
      release(&p->lock);
    8000268a:	8526                	mv	a0,s1
    8000268c:	ebcfe0ef          	jal	ra,80000d48 <release>
      return 0;
    80002690:	4501                	li	a0,0
}
    80002692:	70a2                	ld	ra,40(sp)
    80002694:	7402                	ld	s0,32(sp)
    80002696:	64e2                	ld	s1,24(sp)
    80002698:	6942                	ld	s2,16(sp)
    8000269a:	69a2                	ld	s3,8(sp)
    8000269c:	6145                	addi	sp,sp,48
    8000269e:	8082                	ret
        p->state = RUNNABLE;
    800026a0:	478d                	li	a5,3
    800026a2:	cc9c                	sw	a5,24(s1)
    800026a4:	b7dd                	j	8000268a <kkill+0x4a>

00000000800026a6 <setkilled>:

void
setkilled(struct proc *p)
{
    800026a6:	1101                	addi	sp,sp,-32
    800026a8:	ec06                	sd	ra,24(sp)
    800026aa:	e822                	sd	s0,16(sp)
    800026ac:	e426                	sd	s1,8(sp)
    800026ae:	1000                	addi	s0,sp,32
    800026b0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026b2:	dfefe0ef          	jal	ra,80000cb0 <acquire>
  p->killed = 1;
    800026b6:	4785                	li	a5,1
    800026b8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026ba:	8526                	mv	a0,s1
    800026bc:	e8cfe0ef          	jal	ra,80000d48 <release>
}
    800026c0:	60e2                	ld	ra,24(sp)
    800026c2:	6442                	ld	s0,16(sp)
    800026c4:	64a2                	ld	s1,8(sp)
    800026c6:	6105                	addi	sp,sp,32
    800026c8:	8082                	ret

00000000800026ca <killed>:

int
killed(struct proc *p)
{
    800026ca:	1101                	addi	sp,sp,-32
    800026cc:	ec06                	sd	ra,24(sp)
    800026ce:	e822                	sd	s0,16(sp)
    800026d0:	e426                	sd	s1,8(sp)
    800026d2:	e04a                	sd	s2,0(sp)
    800026d4:	1000                	addi	s0,sp,32
    800026d6:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800026d8:	dd8fe0ef          	jal	ra,80000cb0 <acquire>
  k = p->killed;
    800026dc:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800026e0:	8526                	mv	a0,s1
    800026e2:	e66fe0ef          	jal	ra,80000d48 <release>
  return k;
}
    800026e6:	854a                	mv	a0,s2
    800026e8:	60e2                	ld	ra,24(sp)
    800026ea:	6442                	ld	s0,16(sp)
    800026ec:	64a2                	ld	s1,8(sp)
    800026ee:	6902                	ld	s2,0(sp)
    800026f0:	6105                	addi	sp,sp,32
    800026f2:	8082                	ret

00000000800026f4 <kwait>:
{
    800026f4:	715d                	addi	sp,sp,-80
    800026f6:	e486                	sd	ra,72(sp)
    800026f8:	e0a2                	sd	s0,64(sp)
    800026fa:	fc26                	sd	s1,56(sp)
    800026fc:	f84a                	sd	s2,48(sp)
    800026fe:	f44e                	sd	s3,40(sp)
    80002700:	f052                	sd	s4,32(sp)
    80002702:	ec56                	sd	s5,24(sp)
    80002704:	e85a                	sd	s6,16(sp)
    80002706:	e45e                	sd	s7,8(sp)
    80002708:	e062                	sd	s8,0(sp)
    8000270a:	0880                	addi	s0,sp,80
    8000270c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000270e:	c8cff0ef          	jal	ra,80001b9a <myproc>
    80002712:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002714:	0022e517          	auipc	a0,0x22e
    80002718:	30450513          	addi	a0,a0,772 # 80230a18 <wait_lock>
    8000271c:	d94fe0ef          	jal	ra,80000cb0 <acquire>
    havekids = 0;
    80002720:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002722:	4a15                	li	s4,5
        havekids = 1;
    80002724:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002726:	0023e997          	auipc	s3,0x23e
    8000272a:	10a98993          	addi	s3,s3,266 # 80240830 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000272e:	0022ec17          	auipc	s8,0x22e
    80002732:	2eac0c13          	addi	s8,s8,746 # 80230a18 <wait_lock>
    havekids = 0;
    80002736:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002738:	0022e497          	auipc	s1,0x22e
    8000273c:	6f848493          	addi	s1,s1,1784 # 80230e30 <proc>
    80002740:	a899                	j	80002796 <kwait+0xa2>
          pid = pp->pid;
    80002742:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002746:	000b0c63          	beqz	s6,8000275e <kwait+0x6a>
    8000274a:	4691                	li	a3,4
    8000274c:	02c48613          	addi	a2,s1,44
    80002750:	85da                	mv	a1,s6
    80002752:	05093503          	ld	a0,80(s2)
    80002756:	834ff0ef          	jal	ra,8000178a <copyout>
    8000275a:	00054f63          	bltz	a0,80002778 <kwait+0x84>
          freeproc(pp);
    8000275e:	8526                	mv	a0,s1
    80002760:	843ff0ef          	jal	ra,80001fa2 <freeproc>
          release(&pp->lock);
    80002764:	8526                	mv	a0,s1
    80002766:	de2fe0ef          	jal	ra,80000d48 <release>
          release(&wait_lock);
    8000276a:	0022e517          	auipc	a0,0x22e
    8000276e:	2ae50513          	addi	a0,a0,686 # 80230a18 <wait_lock>
    80002772:	dd6fe0ef          	jal	ra,80000d48 <release>
          return pid;
    80002776:	a891                	j	800027ca <kwait+0xd6>
            release(&pp->lock);
    80002778:	8526                	mv	a0,s1
    8000277a:	dcefe0ef          	jal	ra,80000d48 <release>
            release(&wait_lock);
    8000277e:	0022e517          	auipc	a0,0x22e
    80002782:	29a50513          	addi	a0,a0,666 # 80230a18 <wait_lock>
    80002786:	dc2fe0ef          	jal	ra,80000d48 <release>
            return -1;
    8000278a:	59fd                	li	s3,-1
    8000278c:	a83d                	j	800027ca <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000278e:	3e848493          	addi	s1,s1,1000
    80002792:	03348063          	beq	s1,s3,800027b2 <kwait+0xbe>
      if(pp->parent == p){
    80002796:	7c9c                	ld	a5,56(s1)
    80002798:	ff279be3          	bne	a5,s2,8000278e <kwait+0x9a>
        acquire(&pp->lock);
    8000279c:	8526                	mv	a0,s1
    8000279e:	d12fe0ef          	jal	ra,80000cb0 <acquire>
        if(pp->state == ZOMBIE){
    800027a2:	4c9c                	lw	a5,24(s1)
    800027a4:	f9478fe3          	beq	a5,s4,80002742 <kwait+0x4e>
        release(&pp->lock);
    800027a8:	8526                	mv	a0,s1
    800027aa:	d9efe0ef          	jal	ra,80000d48 <release>
        havekids = 1;
    800027ae:	8756                	mv	a4,s5
    800027b0:	bff9                	j	8000278e <kwait+0x9a>
    if(!havekids || killed(p)){
    800027b2:	c709                	beqz	a4,800027bc <kwait+0xc8>
    800027b4:	854a                	mv	a0,s2
    800027b6:	f15ff0ef          	jal	ra,800026ca <killed>
    800027ba:	c50d                	beqz	a0,800027e4 <kwait+0xf0>
      release(&wait_lock);
    800027bc:	0022e517          	auipc	a0,0x22e
    800027c0:	25c50513          	addi	a0,a0,604 # 80230a18 <wait_lock>
    800027c4:	d84fe0ef          	jal	ra,80000d48 <release>
      return -1;
    800027c8:	59fd                	li	s3,-1
}
    800027ca:	854e                	mv	a0,s3
    800027cc:	60a6                	ld	ra,72(sp)
    800027ce:	6406                	ld	s0,64(sp)
    800027d0:	74e2                	ld	s1,56(sp)
    800027d2:	7942                	ld	s2,48(sp)
    800027d4:	79a2                	ld	s3,40(sp)
    800027d6:	7a02                	ld	s4,32(sp)
    800027d8:	6ae2                	ld	s5,24(sp)
    800027da:	6b42                	ld	s6,16(sp)
    800027dc:	6ba2                	ld	s7,8(sp)
    800027de:	6c02                	ld	s8,0(sp)
    800027e0:	6161                	addi	sp,sp,80
    800027e2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027e4:	85e2                	mv	a1,s8
    800027e6:	854a                	mv	a0,s2
    800027e8:	cabff0ef          	jal	ra,80002492 <sleep>
    havekids = 0;
    800027ec:	b7a9                	j	80002736 <kwait+0x42>

00000000800027ee <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027ee:	7179                	addi	sp,sp,-48
    800027f0:	f406                	sd	ra,40(sp)
    800027f2:	f022                	sd	s0,32(sp)
    800027f4:	ec26                	sd	s1,24(sp)
    800027f6:	e84a                	sd	s2,16(sp)
    800027f8:	e44e                	sd	s3,8(sp)
    800027fa:	e052                	sd	s4,0(sp)
    800027fc:	1800                	addi	s0,sp,48
    800027fe:	84aa                	mv	s1,a0
    80002800:	892e                	mv	s2,a1
    80002802:	89b2                	mv	s3,a2
    80002804:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002806:	b94ff0ef          	jal	ra,80001b9a <myproc>
  if(user_dst){
    8000280a:	cc99                	beqz	s1,80002828 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000280c:	86d2                	mv	a3,s4
    8000280e:	864e                	mv	a2,s3
    80002810:	85ca                	mv	a1,s2
    80002812:	6928                	ld	a0,80(a0)
    80002814:	f77fe0ef          	jal	ra,8000178a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002818:	70a2                	ld	ra,40(sp)
    8000281a:	7402                	ld	s0,32(sp)
    8000281c:	64e2                	ld	s1,24(sp)
    8000281e:	6942                	ld	s2,16(sp)
    80002820:	69a2                	ld	s3,8(sp)
    80002822:	6a02                	ld	s4,0(sp)
    80002824:	6145                	addi	sp,sp,48
    80002826:	8082                	ret
    memmove((char *)dst, src, len);
    80002828:	000a061b          	sext.w	a2,s4
    8000282c:	85ce                	mv	a1,s3
    8000282e:	854a                	mv	a0,s2
    80002830:	db0fe0ef          	jal	ra,80000de0 <memmove>
    return 0;
    80002834:	8526                	mv	a0,s1
    80002836:	b7cd                	j	80002818 <either_copyout+0x2a>

0000000080002838 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002838:	7179                	addi	sp,sp,-48
    8000283a:	f406                	sd	ra,40(sp)
    8000283c:	f022                	sd	s0,32(sp)
    8000283e:	ec26                	sd	s1,24(sp)
    80002840:	e84a                	sd	s2,16(sp)
    80002842:	e44e                	sd	s3,8(sp)
    80002844:	e052                	sd	s4,0(sp)
    80002846:	1800                	addi	s0,sp,48
    80002848:	892a                	mv	s2,a0
    8000284a:	84ae                	mv	s1,a1
    8000284c:	89b2                	mv	s3,a2
    8000284e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002850:	b4aff0ef          	jal	ra,80001b9a <myproc>
  if(user_src){
    80002854:	cc99                	beqz	s1,80002872 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002856:	86d2                	mv	a3,s4
    80002858:	864e                	mv	a2,s3
    8000285a:	85ca                	mv	a1,s2
    8000285c:	6928                	ld	a0,80(a0)
    8000285e:	83cff0ef          	jal	ra,8000189a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002862:	70a2                	ld	ra,40(sp)
    80002864:	7402                	ld	s0,32(sp)
    80002866:	64e2                	ld	s1,24(sp)
    80002868:	6942                	ld	s2,16(sp)
    8000286a:	69a2                	ld	s3,8(sp)
    8000286c:	6a02                	ld	s4,0(sp)
    8000286e:	6145                	addi	sp,sp,48
    80002870:	8082                	ret
    memmove(dst, (char*)src, len);
    80002872:	000a061b          	sext.w	a2,s4
    80002876:	85ce                	mv	a1,s3
    80002878:	854a                	mv	a0,s2
    8000287a:	d66fe0ef          	jal	ra,80000de0 <memmove>
    return 0;
    8000287e:	8526                	mv	a0,s1
    80002880:	b7cd                	j	80002862 <either_copyin+0x2a>

0000000080002882 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002882:	715d                	addi	sp,sp,-80
    80002884:	e486                	sd	ra,72(sp)
    80002886:	e0a2                	sd	s0,64(sp)
    80002888:	fc26                	sd	s1,56(sp)
    8000288a:	f84a                	sd	s2,48(sp)
    8000288c:	f44e                	sd	s3,40(sp)
    8000288e:	f052                	sd	s4,32(sp)
    80002890:	ec56                	sd	s5,24(sp)
    80002892:	e85a                	sd	s6,16(sp)
    80002894:	e45e                	sd	s7,8(sp)
    80002896:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002898:	00006517          	auipc	a0,0x6
    8000289c:	83050513          	addi	a0,a0,-2000 # 800080c8 <digits+0x90>
    800028a0:	c25fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028a4:	0022e497          	auipc	s1,0x22e
    800028a8:	6e448493          	addi	s1,s1,1764 # 80230f88 <proc+0x158>
    800028ac:	0023e917          	auipc	s2,0x23e
    800028b0:	0dc90913          	addi	s2,s2,220 # 80240988 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028b4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800028b6:	00006997          	auipc	s3,0x6
    800028ba:	96a98993          	addi	s3,s3,-1686 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    800028be:	00006a97          	auipc	s5,0x6
    800028c2:	96aa8a93          	addi	s5,s5,-1686 # 80008228 <digits+0x1f0>
    printf("\n");
    800028c6:	00006a17          	auipc	s4,0x6
    800028ca:	802a0a13          	addi	s4,s4,-2046 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028ce:	00006b97          	auipc	s7,0x6
    800028d2:	99ab8b93          	addi	s7,s7,-1638 # 80008268 <states.0>
    800028d6:	a829                	j	800028f0 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800028d8:	ed86a583          	lw	a1,-296(a3)
    800028dc:	8556                	mv	a0,s5
    800028de:	be7fd0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    800028e2:	8552                	mv	a0,s4
    800028e4:	be1fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028e8:	3e848493          	addi	s1,s1,1000
    800028ec:	03248163          	beq	s1,s2,8000290e <procdump+0x8c>
    if(p->state == UNUSED)
    800028f0:	86a6                	mv	a3,s1
    800028f2:	ec04a783          	lw	a5,-320(s1)
    800028f6:	dbed                	beqz	a5,800028e8 <procdump+0x66>
      state = "???";
    800028f8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028fa:	fcfb6fe3          	bltu	s6,a5,800028d8 <procdump+0x56>
    800028fe:	1782                	slli	a5,a5,0x20
    80002900:	9381                	srli	a5,a5,0x20
    80002902:	078e                	slli	a5,a5,0x3
    80002904:	97de                	add	a5,a5,s7
    80002906:	6390                	ld	a2,0(a5)
    80002908:	fa61                	bnez	a2,800028d8 <procdump+0x56>
      state = "???";
    8000290a:	864e                	mv	a2,s3
    8000290c:	b7f1                	j	800028d8 <procdump+0x56>
  }
}
    8000290e:	60a6                	ld	ra,72(sp)
    80002910:	6406                	ld	s0,64(sp)
    80002912:	74e2                	ld	s1,56(sp)
    80002914:	7942                	ld	s2,48(sp)
    80002916:	79a2                	ld	s3,40(sp)
    80002918:	7a02                	ld	s4,32(sp)
    8000291a:	6ae2                	ld	s5,24(sp)
    8000291c:	6b42                	ld	s6,16(sp)
    8000291e:	6ba2                	ld	s7,8(sp)
    80002920:	6161                	addi	sp,sp,80
    80002922:	8082                	ret

0000000080002924 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002924:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002928:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000292c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000292e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002930:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002934:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002938:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000293c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002940:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002944:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002948:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000294c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002950:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002954:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002958:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000295c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002960:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002962:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002964:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002968:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000296c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002970:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002974:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002978:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000297c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002980:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002984:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002988:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000298c:	8082                	ret

000000008000298e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000298e:	1141                	addi	sp,sp,-16
    80002990:	e406                	sd	ra,8(sp)
    80002992:	e022                	sd	s0,0(sp)
    80002994:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002996:	00006597          	auipc	a1,0x6
    8000299a:	90258593          	addi	a1,a1,-1790 # 80008298 <states.0+0x30>
    8000299e:	0023e517          	auipc	a0,0x23e
    800029a2:	e9250513          	addi	a0,a0,-366 # 80240830 <tickslock>
    800029a6:	a8afe0ef          	jal	ra,80000c30 <initlock>
}
    800029aa:	60a2                	ld	ra,8(sp)
    800029ac:	6402                	ld	s0,0(sp)
    800029ae:	0141                	addi	sp,sp,16
    800029b0:	8082                	ret

00000000800029b2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029b2:	1141                	addi	sp,sp,-16
    800029b4:	e422                	sd	s0,8(sp)
    800029b6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029b8:	00003797          	auipc	a5,0x3
    800029bc:	5f878793          	addi	a5,a5,1528 # 80005fb0 <kernelvec>
    800029c0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029c4:	6422                	ld	s0,8(sp)
    800029c6:	0141                	addi	sp,sp,16
    800029c8:	8082                	ret

00000000800029ca <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800029ca:	1141                	addi	sp,sp,-16
    800029cc:	e406                	sd	ra,8(sp)
    800029ce:	e022                	sd	s0,0(sp)
    800029d0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029d2:	9c8ff0ef          	jal	ra,80001b9a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029da:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029dc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029e0:	04000737          	lui	a4,0x4000
    800029e4:	00004797          	auipc	a5,0x4
    800029e8:	61c78793          	addi	a5,a5,1564 # 80007000 <_trampoline>
    800029ec:	00004697          	auipc	a3,0x4
    800029f0:	61468693          	addi	a3,a3,1556 # 80007000 <_trampoline>
    800029f4:	8f95                	sub	a5,a5,a3
    800029f6:	177d                	addi	a4,a4,-1
    800029f8:	0732                	slli	a4,a4,0xc
    800029fa:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029fc:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a00:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a02:	18002773          	csrr	a4,satp
    80002a06:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a08:	6d38                	ld	a4,88(a0)
    80002a0a:	613c                	ld	a5,64(a0)
    80002a0c:	6685                	lui	a3,0x1
    80002a0e:	97b6                	add	a5,a5,a3
    80002a10:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a12:	6d3c                	ld	a5,88(a0)
    80002a14:	00000717          	auipc	a4,0x0
    80002a18:	0f470713          	addi	a4,a4,244 # 80002b08 <usertrap>
    80002a1c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a1e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a20:	8712                	mv	a4,tp
    80002a22:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a24:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a28:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a2c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a30:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a34:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a36:	6f9c                	ld	a5,24(a5)
    80002a38:	14179073          	csrw	sepc,a5
}
    80002a3c:	60a2                	ld	ra,8(sp)
    80002a3e:	6402                	ld	s0,0(sp)
    80002a40:	0141                	addi	sp,sp,16
    80002a42:	8082                	ret

0000000080002a44 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a44:	1101                	addi	sp,sp,-32
    80002a46:	ec06                	sd	ra,24(sp)
    80002a48:	e822                	sd	s0,16(sp)
    80002a4a:	e426                	sd	s1,8(sp)
    80002a4c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002a4e:	920ff0ef          	jal	ra,80001b6e <cpuid>
    80002a52:	cd19                	beqz	a0,80002a70 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a54:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a58:	000f4737          	lui	a4,0xf4
    80002a5c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a60:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a62:	14d79073          	csrw	0x14d,a5
}
    80002a66:	60e2                	ld	ra,24(sp)
    80002a68:	6442                	ld	s0,16(sp)
    80002a6a:	64a2                	ld	s1,8(sp)
    80002a6c:	6105                	addi	sp,sp,32
    80002a6e:	8082                	ret
    acquire(&tickslock);
    80002a70:	0023e497          	auipc	s1,0x23e
    80002a74:	dc048493          	addi	s1,s1,-576 # 80240830 <tickslock>
    80002a78:	8526                	mv	a0,s1
    80002a7a:	a36fe0ef          	jal	ra,80000cb0 <acquire>
    ticks++;
    80002a7e:	00006517          	auipc	a0,0x6
    80002a82:	e4a50513          	addi	a0,a0,-438 # 800088c8 <ticks>
    80002a86:	411c                	lw	a5,0(a0)
    80002a88:	2785                	addiw	a5,a5,1
    80002a8a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002a8c:	a53ff0ef          	jal	ra,800024de <wakeup>
    release(&tickslock);
    80002a90:	8526                	mv	a0,s1
    80002a92:	ab6fe0ef          	jal	ra,80000d48 <release>
    80002a96:	bf7d                	j	80002a54 <clockintr+0x10>

0000000080002a98 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a98:	1101                	addi	sp,sp,-32
    80002a9a:	ec06                	sd	ra,24(sp)
    80002a9c:	e822                	sd	s0,16(sp)
    80002a9e:	e426                	sd	s1,8(sp)
    80002aa0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002aa6:	57fd                	li	a5,-1
    80002aa8:	17fe                	slli	a5,a5,0x3f
    80002aaa:	07a5                	addi	a5,a5,9
    80002aac:	00f70d63          	beq	a4,a5,80002ac6 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002ab0:	57fd                	li	a5,-1
    80002ab2:	17fe                	slli	a5,a5,0x3f
    80002ab4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002ab6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002ab8:	04f70463          	beq	a4,a5,80002b00 <devintr+0x68>
  }
}
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6105                	addi	sp,sp,32
    80002ac4:	8082                	ret
    int irq = plic_claim();
    80002ac6:	592030ef          	jal	ra,80006058 <plic_claim>
    80002aca:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002acc:	47a9                	li	a5,10
    80002ace:	02f50363          	beq	a0,a5,80002af4 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002ad2:	4785                	li	a5,1
    80002ad4:	02f50363          	beq	a0,a5,80002afa <devintr+0x62>
    return 1;
    80002ad8:	4505                	li	a0,1
    } else if(irq){
    80002ada:	d0ed                	beqz	s1,80002abc <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002adc:	85a6                	mv	a1,s1
    80002ade:	00005517          	auipc	a0,0x5
    80002ae2:	7c250513          	addi	a0,a0,1986 # 800082a0 <states.0+0x38>
    80002ae6:	9dffd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002aea:	8526                	mv	a0,s1
    80002aec:	58c030ef          	jal	ra,80006078 <plic_complete>
    return 1;
    80002af0:	4505                	li	a0,1
    80002af2:	b7e9                	j	80002abc <devintr+0x24>
      uartintr();
    80002af4:	e65fd0ef          	jal	ra,80000958 <uartintr>
    80002af8:	bfcd                	j	80002aea <devintr+0x52>
      virtio_disk_intr();
    80002afa:	1ef030ef          	jal	ra,800064e8 <virtio_disk_intr>
    80002afe:	b7f5                	j	80002aea <devintr+0x52>
    clockintr();
    80002b00:	f45ff0ef          	jal	ra,80002a44 <clockintr>
    return 2;
    80002b04:	4509                	li	a0,2
    80002b06:	bf5d                	j	80002abc <devintr+0x24>

0000000080002b08 <usertrap>:
{
    80002b08:	7179                	addi	sp,sp,-48
    80002b0a:	f406                	sd	ra,40(sp)
    80002b0c:	f022                	sd	s0,32(sp)
    80002b0e:	ec26                	sd	s1,24(sp)
    80002b10:	e84a                	sd	s2,16(sp)
    80002b12:	e44e                	sd	s3,8(sp)
    80002b14:	e052                	sd	s4,0(sp)
    80002b16:	1800                	addi	s0,sp,48
    80002b18:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b1c:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b20:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b24:	1007f793          	andi	a5,a5,256
    80002b28:	e3bd                	bnez	a5,80002b8e <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b2a:	00003797          	auipc	a5,0x3
    80002b2e:	48678793          	addi	a5,a5,1158 # 80005fb0 <kernelvec>
    80002b32:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b36:	864ff0ef          	jal	ra,80001b9a <myproc>
    80002b3a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b3c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b3e:	14102773          	csrr	a4,sepc
    80002b42:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b44:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b48:	47a1                	li	a5,8
    80002b4a:	04f70863          	beq	a4,a5,80002b9a <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002b4e:	f4bff0ef          	jal	ra,80002a98 <devintr>
    80002b52:	892a                	mv	s2,a0
    80002b54:	0c051e63          	bnez	a0,80002c30 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002b58:	47b5                	li	a5,13
    80002b5a:	08f98663          	beq	s3,a5,80002be6 <usertrap+0xde>
    80002b5e:	47bd                	li	a5,15
    80002b60:	0af99363          	bne	s3,a5,80002c06 <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002b64:	85d2                	mv	a1,s4
    80002b66:	68a8                	ld	a0,80(s1)
    80002b68:	9f1fe0ef          	jal	ra,80001558 <cowbreak>
    80002b6c:	c531                	beqz	a0,80002bb8 <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    80002b6e:	4605                	li	a2,1
    80002b70:	85d2                	mv	a1,s4
    80002b72:	8526                	mv	a0,s1
    80002b74:	dcbfe0ef          	jal	ra,8000193e <vmafault>
    80002b78:	e121                	bnez	a0,80002bb8 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    80002b7a:	4601                	li	a2,0
    80002b7c:	85d2                	mv	a1,s4
    80002b7e:	68a8                	ld	a0,80(s1)
    80002b80:	b99fe0ef          	jal	ra,80001718 <vmfault>
    80002b84:	e915                	bnez	a0,80002bb8 <usertrap+0xb0>
        setkilled(p);
    80002b86:	8526                	mv	a0,s1
    80002b88:	b1fff0ef          	jal	ra,800026a6 <setkilled>
    80002b8c:	a035                	j	80002bb8 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002b8e:	00005517          	auipc	a0,0x5
    80002b92:	73250513          	addi	a0,a0,1842 # 800082c0 <states.0+0x58>
    80002b96:	bf5fd0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    80002b9a:	b31ff0ef          	jal	ra,800026ca <killed>
    80002b9e:	e121                	bnez	a0,80002bde <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002ba0:	6cb8                	ld	a4,88(s1)
    80002ba2:	6f1c                	ld	a5,24(a4)
    80002ba4:	0791                	addi	a5,a5,4
    80002ba6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bb0:	10079073          	csrw	sstatus,a5
    syscall();
    80002bb4:	27c000ef          	jal	ra,80002e30 <syscall>
  if(killed(p))
    80002bb8:	8526                	mv	a0,s1
    80002bba:	b11ff0ef          	jal	ra,800026ca <killed>
    80002bbe:	ed35                	bnez	a0,80002c3a <usertrap+0x132>
  prepare_return();
    80002bc0:	e0bff0ef          	jal	ra,800029ca <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bc4:	68a8                	ld	a0,80(s1)
    80002bc6:	8131                	srli	a0,a0,0xc
    80002bc8:	57fd                	li	a5,-1
    80002bca:	17fe                	slli	a5,a5,0x3f
    80002bcc:	8d5d                	or	a0,a0,a5
}
    80002bce:	70a2                	ld	ra,40(sp)
    80002bd0:	7402                	ld	s0,32(sp)
    80002bd2:	64e2                	ld	s1,24(sp)
    80002bd4:	6942                	ld	s2,16(sp)
    80002bd6:	69a2                	ld	s3,8(sp)
    80002bd8:	6a02                	ld	s4,0(sp)
    80002bda:	6145                	addi	sp,sp,48
    80002bdc:	8082                	ret
      kexit(-1);
    80002bde:	557d                	li	a0,-1
    80002be0:	9bfff0ef          	jal	ra,8000259e <kexit>
    80002be4:	bf75                	j	80002ba0 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002be6:	4601                	li	a2,0
    80002be8:	85d2                	mv	a1,s4
    80002bea:	8526                	mv	a0,s1
    80002bec:	d53fe0ef          	jal	ra,8000193e <vmafault>
    80002bf0:	f561                	bnez	a0,80002bb8 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002bf2:	4605                	li	a2,1
    80002bf4:	85d2                	mv	a1,s4
    80002bf6:	68a8                	ld	a0,80(s1)
    80002bf8:	b21fe0ef          	jal	ra,80001718 <vmfault>
    80002bfc:	fd55                	bnez	a0,80002bb8 <usertrap+0xb0>
        setkilled(p);
    80002bfe:	8526                	mv	a0,s1
    80002c00:	aa7ff0ef          	jal	ra,800026a6 <setkilled>
    80002c04:	bf55                	j	80002bb8 <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002c06:	5890                	lw	a2,48(s1)
    80002c08:	85ce                	mv	a1,s3
    80002c0a:	00005517          	auipc	a0,0x5
    80002c0e:	6d650513          	addi	a0,a0,1750 # 800082e0 <states.0+0x78>
    80002c12:	8b3fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c16:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002c1a:	8652                	mv	a2,s4
    80002c1c:	00005517          	auipc	a0,0x5
    80002c20:	6f450513          	addi	a0,a0,1780 # 80008310 <states.0+0xa8>
    80002c24:	8a1fd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002c28:	8526                	mv	a0,s1
    80002c2a:	a7dff0ef          	jal	ra,800026a6 <setkilled>
    80002c2e:	b769                	j	80002bb8 <usertrap+0xb0>
  if(killed(p))
    80002c30:	8526                	mv	a0,s1
    80002c32:	a99ff0ef          	jal	ra,800026ca <killed>
    80002c36:	c511                	beqz	a0,80002c42 <usertrap+0x13a>
    80002c38:	a011                	j	80002c3c <usertrap+0x134>
    80002c3a:	4901                	li	s2,0
    kexit(-1);
    80002c3c:	557d                	li	a0,-1
    80002c3e:	961ff0ef          	jal	ra,8000259e <kexit>
  if(which_dev == 2)
    80002c42:	4789                	li	a5,2
    80002c44:	f6f91ee3          	bne	s2,a5,80002bc0 <usertrap+0xb8>
    yield();
    80002c48:	81fff0ef          	jal	ra,80002466 <yield>
    80002c4c:	bf95                	j	80002bc0 <usertrap+0xb8>

0000000080002c4e <kerneltrap>:
{
    80002c4e:	7179                	addi	sp,sp,-48
    80002c50:	f406                	sd	ra,40(sp)
    80002c52:	f022                	sd	s0,32(sp)
    80002c54:	ec26                	sd	s1,24(sp)
    80002c56:	e84a                	sd	s2,16(sp)
    80002c58:	e44e                	sd	s3,8(sp)
    80002c5a:	1800                	addi	s0,sp,48
    80002c5c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c60:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c64:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c68:	1004f793          	andi	a5,s1,256
    80002c6c:	c795                	beqz	a5,80002c98 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c6e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c72:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c74:	eb85                	bnez	a5,80002ca4 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002c76:	e23ff0ef          	jal	ra,80002a98 <devintr>
    80002c7a:	c91d                	beqz	a0,80002cb0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002c7c:	4789                	li	a5,2
    80002c7e:	04f50a63          	beq	a0,a5,80002cd2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c82:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c86:	10049073          	csrw	sstatus,s1
}
    80002c8a:	70a2                	ld	ra,40(sp)
    80002c8c:	7402                	ld	s0,32(sp)
    80002c8e:	64e2                	ld	s1,24(sp)
    80002c90:	6942                	ld	s2,16(sp)
    80002c92:	69a2                	ld	s3,8(sp)
    80002c94:	6145                	addi	sp,sp,48
    80002c96:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c98:	00005517          	auipc	a0,0x5
    80002c9c:	6a050513          	addi	a0,a0,1696 # 80008338 <states.0+0xd0>
    80002ca0:	aebfd0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80002ca4:	00005517          	auipc	a0,0x5
    80002ca8:	6bc50513          	addi	a0,a0,1724 # 80008360 <states.0+0xf8>
    80002cac:	adffd0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cb4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002cb8:	85ce                	mv	a1,s3
    80002cba:	00005517          	auipc	a0,0x5
    80002cbe:	6c650513          	addi	a0,a0,1734 # 80008380 <states.0+0x118>
    80002cc2:	803fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002cc6:	00005517          	auipc	a0,0x5
    80002cca:	6e250513          	addi	a0,a0,1762 # 800083a8 <states.0+0x140>
    80002cce:	abdfd0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    80002cd2:	ec9fe0ef          	jal	ra,80001b9a <myproc>
    80002cd6:	d555                	beqz	a0,80002c82 <kerneltrap+0x34>
    yield();
    80002cd8:	f8eff0ef          	jal	ra,80002466 <yield>
    80002cdc:	b75d                	j	80002c82 <kerneltrap+0x34>

0000000080002cde <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cde:	1101                	addi	sp,sp,-32
    80002ce0:	ec06                	sd	ra,24(sp)
    80002ce2:	e822                	sd	s0,16(sp)
    80002ce4:	e426                	sd	s1,8(sp)
    80002ce6:	1000                	addi	s0,sp,32
    80002ce8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cea:	eb1fe0ef          	jal	ra,80001b9a <myproc>
  switch (n) {
    80002cee:	4795                	li	a5,5
    80002cf0:	0497e163          	bltu	a5,s1,80002d32 <argraw+0x54>
    80002cf4:	048a                	slli	s1,s1,0x2
    80002cf6:	00005717          	auipc	a4,0x5
    80002cfa:	6ea70713          	addi	a4,a4,1770 # 800083e0 <states.0+0x178>
    80002cfe:	94ba                	add	s1,s1,a4
    80002d00:	409c                	lw	a5,0(s1)
    80002d02:	97ba                	add	a5,a5,a4
    80002d04:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d06:	6d3c                	ld	a5,88(a0)
    80002d08:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d0a:	60e2                	ld	ra,24(sp)
    80002d0c:	6442                	ld	s0,16(sp)
    80002d0e:	64a2                	ld	s1,8(sp)
    80002d10:	6105                	addi	sp,sp,32
    80002d12:	8082                	ret
    return p->trapframe->a1;
    80002d14:	6d3c                	ld	a5,88(a0)
    80002d16:	7fa8                	ld	a0,120(a5)
    80002d18:	bfcd                	j	80002d0a <argraw+0x2c>
    return p->trapframe->a2;
    80002d1a:	6d3c                	ld	a5,88(a0)
    80002d1c:	63c8                	ld	a0,128(a5)
    80002d1e:	b7f5                	j	80002d0a <argraw+0x2c>
    return p->trapframe->a3;
    80002d20:	6d3c                	ld	a5,88(a0)
    80002d22:	67c8                	ld	a0,136(a5)
    80002d24:	b7dd                	j	80002d0a <argraw+0x2c>
    return p->trapframe->a4;
    80002d26:	6d3c                	ld	a5,88(a0)
    80002d28:	6bc8                	ld	a0,144(a5)
    80002d2a:	b7c5                	j	80002d0a <argraw+0x2c>
    return p->trapframe->a5;
    80002d2c:	6d3c                	ld	a5,88(a0)
    80002d2e:	6fc8                	ld	a0,152(a5)
    80002d30:	bfe9                	j	80002d0a <argraw+0x2c>
  panic("argraw");
    80002d32:	00005517          	auipc	a0,0x5
    80002d36:	68650513          	addi	a0,a0,1670 # 800083b8 <states.0+0x150>
    80002d3a:	a51fd0ef          	jal	ra,8000078a <panic>

0000000080002d3e <fetchaddr>:
{
    80002d3e:	1101                	addi	sp,sp,-32
    80002d40:	ec06                	sd	ra,24(sp)
    80002d42:	e822                	sd	s0,16(sp)
    80002d44:	e426                	sd	s1,8(sp)
    80002d46:	e04a                	sd	s2,0(sp)
    80002d48:	1000                	addi	s0,sp,32
    80002d4a:	84aa                	mv	s1,a0
    80002d4c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d4e:	e4dfe0ef          	jal	ra,80001b9a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d52:	653c                	ld	a5,72(a0)
    80002d54:	02f4f663          	bgeu	s1,a5,80002d80 <fetchaddr+0x42>
    80002d58:	00848713          	addi	a4,s1,8
    80002d5c:	02e7e463          	bltu	a5,a4,80002d84 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d60:	46a1                	li	a3,8
    80002d62:	8626                	mv	a2,s1
    80002d64:	85ca                	mv	a1,s2
    80002d66:	6928                	ld	a0,80(a0)
    80002d68:	b33fe0ef          	jal	ra,8000189a <copyin>
    80002d6c:	00a03533          	snez	a0,a0
    80002d70:	40a00533          	neg	a0,a0
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	64a2                	ld	s1,8(sp)
    80002d7a:	6902                	ld	s2,0(sp)
    80002d7c:	6105                	addi	sp,sp,32
    80002d7e:	8082                	ret
    return -1;
    80002d80:	557d                	li	a0,-1
    80002d82:	bfcd                	j	80002d74 <fetchaddr+0x36>
    80002d84:	557d                	li	a0,-1
    80002d86:	b7fd                	j	80002d74 <fetchaddr+0x36>

0000000080002d88 <fetchstr>:
{
    80002d88:	7179                	addi	sp,sp,-48
    80002d8a:	f406                	sd	ra,40(sp)
    80002d8c:	f022                	sd	s0,32(sp)
    80002d8e:	ec26                	sd	s1,24(sp)
    80002d90:	e84a                	sd	s2,16(sp)
    80002d92:	e44e                	sd	s3,8(sp)
    80002d94:	1800                	addi	s0,sp,48
    80002d96:	892a                	mv	s2,a0
    80002d98:	84ae                	mv	s1,a1
    80002d9a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d9c:	dfffe0ef          	jal	ra,80001b9a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002da0:	86ce                	mv	a3,s3
    80002da2:	864a                	mv	a2,s2
    80002da4:	85a6                	mv	a1,s1
    80002da6:	6928                	ld	a0,80(a0)
    80002da8:	8a1fe0ef          	jal	ra,80001648 <copyinstr>
    80002dac:	00054c63          	bltz	a0,80002dc4 <fetchstr+0x3c>
  return strlen(buf);
    80002db0:	8526                	mv	a0,s1
    80002db2:	94afe0ef          	jal	ra,80000efc <strlen>
}
    80002db6:	70a2                	ld	ra,40(sp)
    80002db8:	7402                	ld	s0,32(sp)
    80002dba:	64e2                	ld	s1,24(sp)
    80002dbc:	6942                	ld	s2,16(sp)
    80002dbe:	69a2                	ld	s3,8(sp)
    80002dc0:	6145                	addi	sp,sp,48
    80002dc2:	8082                	ret
    return -1;
    80002dc4:	557d                	li	a0,-1
    80002dc6:	bfc5                	j	80002db6 <fetchstr+0x2e>

0000000080002dc8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dc8:	1101                	addi	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	e426                	sd	s1,8(sp)
    80002dd0:	1000                	addi	s0,sp,32
    80002dd2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd4:	f0bff0ef          	jal	ra,80002cde <argraw>
    80002dd8:	c088                	sw	a0,0(s1)
}
    80002dda:	60e2                	ld	ra,24(sp)
    80002ddc:	6442                	ld	s0,16(sp)
    80002dde:	64a2                	ld	s1,8(sp)
    80002de0:	6105                	addi	sp,sp,32
    80002de2:	8082                	ret

0000000080002de4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	1000                	addi	s0,sp,32
    80002dee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df0:	eefff0ef          	jal	ra,80002cde <argraw>
    80002df4:	e088                	sd	a0,0(s1)
}
    80002df6:	60e2                	ld	ra,24(sp)
    80002df8:	6442                	ld	s0,16(sp)
    80002dfa:	64a2                	ld	s1,8(sp)
    80002dfc:	6105                	addi	sp,sp,32
    80002dfe:	8082                	ret

0000000080002e00 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e00:	7179                	addi	sp,sp,-48
    80002e02:	f406                	sd	ra,40(sp)
    80002e04:	f022                	sd	s0,32(sp)
    80002e06:	ec26                	sd	s1,24(sp)
    80002e08:	e84a                	sd	s2,16(sp)
    80002e0a:	1800                	addi	s0,sp,48
    80002e0c:	84ae                	mv	s1,a1
    80002e0e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e10:	fd840593          	addi	a1,s0,-40
    80002e14:	fd1ff0ef          	jal	ra,80002de4 <argaddr>
  return fetchstr(addr, buf, max);
    80002e18:	864a                	mv	a2,s2
    80002e1a:	85a6                	mv	a1,s1
    80002e1c:	fd843503          	ld	a0,-40(s0)
    80002e20:	f69ff0ef          	jal	ra,80002d88 <fetchstr>
}
    80002e24:	70a2                	ld	ra,40(sp)
    80002e26:	7402                	ld	s0,32(sp)
    80002e28:	64e2                	ld	s1,24(sp)
    80002e2a:	6942                	ld	s2,16(sp)
    80002e2c:	6145                	addi	sp,sp,48
    80002e2e:	8082                	ret

0000000080002e30 <syscall>:
[SYS_vmstats]    sys_vmstats,
};

void
syscall(void)
{
    80002e30:	1101                	addi	sp,sp,-32
    80002e32:	ec06                	sd	ra,24(sp)
    80002e34:	e822                	sd	s0,16(sp)
    80002e36:	e426                	sd	s1,8(sp)
    80002e38:	e04a                	sd	s2,0(sp)
    80002e3a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e3c:	d5ffe0ef          	jal	ra,80001b9a <myproc>
    80002e40:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e42:	05853903          	ld	s2,88(a0)
    80002e46:	0a893783          	ld	a5,168(s2)
    80002e4a:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e4e:	37fd                	addiw	a5,a5,-1
    80002e50:	4771                	li	a4,28
    80002e52:	00f76f63          	bltu	a4,a5,80002e70 <syscall+0x40>
    80002e56:	00369713          	slli	a4,a3,0x3
    80002e5a:	00005797          	auipc	a5,0x5
    80002e5e:	59e78793          	addi	a5,a5,1438 # 800083f8 <syscalls>
    80002e62:	97ba                	add	a5,a5,a4
    80002e64:	639c                	ld	a5,0(a5)
    80002e66:	c789                	beqz	a5,80002e70 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e68:	9782                	jalr	a5
    80002e6a:	06a93823          	sd	a0,112(s2)
    80002e6e:	a829                	j	80002e88 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e70:	15848613          	addi	a2,s1,344
    80002e74:	588c                	lw	a1,48(s1)
    80002e76:	00005517          	auipc	a0,0x5
    80002e7a:	54a50513          	addi	a0,a0,1354 # 800083c0 <states.0+0x158>
    80002e7e:	e46fd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e82:	6cbc                	ld	a5,88(s1)
    80002e84:	577d                	li	a4,-1
    80002e86:	fbb8                	sd	a4,112(a5)
  }
}
    80002e88:	60e2                	ld	ra,24(sp)
    80002e8a:	6442                	ld	s0,16(sp)
    80002e8c:	64a2                	ld	s1,8(sp)
    80002e8e:	6902                	ld	s2,0(sp)
    80002e90:	6105                	addi	sp,sp,32
    80002e92:	8082                	ret

0000000080002e94 <proc_has_shm_key>:
 * 用途：
 *   用于判断进程是否还有其他VMA引用同一个共享内存对象
 */
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
    80002e94:	1141                	addi	sp,sp,-16
    80002e96:	e422                	sd	s0,8(sp)
    80002e98:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002e9a:	16850793          	addi	a5,a0,360
    80002e9e:	3e850513          	addi	a0,a0,1000
    80002ea2:	a029                	j	80002eac <proc_has_shm_key+0x18>
    80002ea4:	02878793          	addi	a5,a5,40
    80002ea8:	00a78d63          	beq	a5,a0,80002ec2 <proc_has_shm_key+0x2e>
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    80002eac:	fef60ce3          	beq	a2,a5,80002ea4 <proc_has_shm_key+0x10>
    if(v->used && v->is_shm && v->shm_key == key)
    80002eb0:	4398                	lw	a4,0(a5)
    80002eb2:	db6d                	beqz	a4,80002ea4 <proc_has_shm_key+0x10>
    80002eb4:	5398                	lw	a4,32(a5)
    80002eb6:	d77d                	beqz	a4,80002ea4 <proc_has_shm_key+0x10>
    80002eb8:	53d8                	lw	a4,36(a5)
    80002eba:	feb715e3          	bne	a4,a1,80002ea4 <proc_has_shm_key+0x10>
      return 1;
    80002ebe:	4505                	li	a0,1
    80002ec0:	a011                	j	80002ec4 <proc_has_shm_key+0x30>
  }
  return 0;
    80002ec2:	4501                	li	a0,0
}
    80002ec4:	6422                	ld	s0,8(sp)
    80002ec6:	0141                	addi	sp,sp,16
    80002ec8:	8082                	ret

0000000080002eca <sys_exit>:
{
    80002eca:	1101                	addi	sp,sp,-32
    80002ecc:	ec06                	sd	ra,24(sp)
    80002ece:	e822                	sd	s0,16(sp)
    80002ed0:	1000                	addi	s0,sp,32
  argint(0, &n);
    80002ed2:	fec40593          	addi	a1,s0,-20
    80002ed6:	4501                	li	a0,0
    80002ed8:	ef1ff0ef          	jal	ra,80002dc8 <argint>
  kexit(n);
    80002edc:	fec42503          	lw	a0,-20(s0)
    80002ee0:	ebeff0ef          	jal	ra,8000259e <kexit>
}
    80002ee4:	4501                	li	a0,0
    80002ee6:	60e2                	ld	ra,24(sp)
    80002ee8:	6442                	ld	s0,16(sp)
    80002eea:	6105                	addi	sp,sp,32
    80002eec:	8082                	ret

0000000080002eee <sys_getpid>:
{
    80002eee:	1141                	addi	sp,sp,-16
    80002ef0:	e406                	sd	ra,8(sp)
    80002ef2:	e022                	sd	s0,0(sp)
    80002ef4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ef6:	ca5fe0ef          	jal	ra,80001b9a <myproc>
}
    80002efa:	5908                	lw	a0,48(a0)
    80002efc:	60a2                	ld	ra,8(sp)
    80002efe:	6402                	ld	s0,0(sp)
    80002f00:	0141                	addi	sp,sp,16
    80002f02:	8082                	ret

0000000080002f04 <sys_fork>:
{
    80002f04:	1141                	addi	sp,sp,-16
    80002f06:	e406                	sd	ra,8(sp)
    80002f08:	e022                	sd	s0,0(sp)
    80002f0a:	0800                	addi	s0,sp,16
  return kfork();
    80002f0c:	a50ff0ef          	jal	ra,8000215c <kfork>
}
    80002f10:	60a2                	ld	ra,8(sp)
    80002f12:	6402                	ld	s0,0(sp)
    80002f14:	0141                	addi	sp,sp,16
    80002f16:	8082                	ret

0000000080002f18 <sys_wait>:
{
    80002f18:	1101                	addi	sp,sp,-32
    80002f1a:	ec06                	sd	ra,24(sp)
    80002f1c:	e822                	sd	s0,16(sp)
    80002f1e:	1000                	addi	s0,sp,32
  argaddr(0, &p);
    80002f20:	fe840593          	addi	a1,s0,-24
    80002f24:	4501                	li	a0,0
    80002f26:	ebfff0ef          	jal	ra,80002de4 <argaddr>
  return kwait(p);
    80002f2a:	fe843503          	ld	a0,-24(s0)
    80002f2e:	fc6ff0ef          	jal	ra,800026f4 <kwait>
}
    80002f32:	60e2                	ld	ra,24(sp)
    80002f34:	6442                	ld	s0,16(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret

0000000080002f3a <sys_sbrk>:
{
    80002f3a:	7179                	addi	sp,sp,-48
    80002f3c:	f406                	sd	ra,40(sp)
    80002f3e:	f022                	sd	s0,32(sp)
    80002f40:	ec26                	sd	s1,24(sp)
    80002f42:	1800                	addi	s0,sp,48
  argint(0, &n);
    80002f44:	fd840593          	addi	a1,s0,-40
    80002f48:	4501                	li	a0,0
    80002f4a:	e7fff0ef          	jal	ra,80002dc8 <argint>
  argint(1, &t);
    80002f4e:	fdc40593          	addi	a1,s0,-36
    80002f52:	4505                	li	a0,1
    80002f54:	e75ff0ef          	jal	ra,80002dc8 <argint>
  addr = myproc()->sz;
    80002f58:	c43fe0ef          	jal	ra,80001b9a <myproc>
    80002f5c:	6524                	ld	s1,72(a0)
  if(t == SBRK_EAGER || n < 0) {
    80002f5e:	fdc42703          	lw	a4,-36(s0)
    80002f62:	4785                	li	a5,1
    80002f64:	02f70763          	beq	a4,a5,80002f92 <sys_sbrk+0x58>
    80002f68:	fd842783          	lw	a5,-40(s0)
    80002f6c:	0207c363          	bltz	a5,80002f92 <sys_sbrk+0x58>
    if(addr + n < addr)
    80002f70:	97a6                	add	a5,a5,s1
    80002f72:	0297ee63          	bltu	a5,s1,80002fae <sys_sbrk+0x74>
    if(addr + n > TRAPFRAME)
    80002f76:	02000737          	lui	a4,0x2000
    80002f7a:	177d                	addi	a4,a4,-1
    80002f7c:	0736                	slli	a4,a4,0xd
    80002f7e:	02f76a63          	bltu	a4,a5,80002fb2 <sys_sbrk+0x78>
    myproc()->sz += n;
    80002f82:	c19fe0ef          	jal	ra,80001b9a <myproc>
    80002f86:	fd842703          	lw	a4,-40(s0)
    80002f8a:	653c                	ld	a5,72(a0)
    80002f8c:	97ba                	add	a5,a5,a4
    80002f8e:	e53c                	sd	a5,72(a0)
    80002f90:	a039                	j	80002f9e <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002f92:	fd842503          	lw	a0,-40(s0)
    80002f96:	964ff0ef          	jal	ra,800020fa <growproc>
    80002f9a:	00054863          	bltz	a0,80002faa <sys_sbrk+0x70>
}
    80002f9e:	8526                	mv	a0,s1
    80002fa0:	70a2                	ld	ra,40(sp)
    80002fa2:	7402                	ld	s0,32(sp)
    80002fa4:	64e2                	ld	s1,24(sp)
    80002fa6:	6145                	addi	sp,sp,48
    80002fa8:	8082                	ret
      return -1;
    80002faa:	54fd                	li	s1,-1
    80002fac:	bfcd                	j	80002f9e <sys_sbrk+0x64>
      return -1;
    80002fae:	54fd                	li	s1,-1
    80002fb0:	b7fd                	j	80002f9e <sys_sbrk+0x64>
      return -1;
    80002fb2:	54fd                	li	s1,-1
    80002fb4:	b7ed                	j	80002f9e <sys_sbrk+0x64>

0000000080002fb6 <sys_pause>:
{
    80002fb6:	7139                	addi	sp,sp,-64
    80002fb8:	fc06                	sd	ra,56(sp)
    80002fba:	f822                	sd	s0,48(sp)
    80002fbc:	f426                	sd	s1,40(sp)
    80002fbe:	f04a                	sd	s2,32(sp)
    80002fc0:	ec4e                	sd	s3,24(sp)
    80002fc2:	0080                	addi	s0,sp,64
  argint(0, &n);
    80002fc4:	fcc40593          	addi	a1,s0,-52
    80002fc8:	4501                	li	a0,0
    80002fca:	dffff0ef          	jal	ra,80002dc8 <argint>
  if(n < 0)
    80002fce:	fcc42783          	lw	a5,-52(s0)
    80002fd2:	0607c563          	bltz	a5,8000303c <sys_pause+0x86>
  acquire(&tickslock);
    80002fd6:	0023e517          	auipc	a0,0x23e
    80002fda:	85a50513          	addi	a0,a0,-1958 # 80240830 <tickslock>
    80002fde:	cd3fd0ef          	jal	ra,80000cb0 <acquire>
  ticks0 = ticks;
    80002fe2:	00006917          	auipc	s2,0x6
    80002fe6:	8e692903          	lw	s2,-1818(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    80002fea:	fcc42783          	lw	a5,-52(s0)
    80002fee:	cb8d                	beqz	a5,80003020 <sys_pause+0x6a>
    sleep(&ticks, &tickslock);
    80002ff0:	0023e997          	auipc	s3,0x23e
    80002ff4:	84098993          	addi	s3,s3,-1984 # 80240830 <tickslock>
    80002ff8:	00006497          	auipc	s1,0x6
    80002ffc:	8d048493          	addi	s1,s1,-1840 # 800088c8 <ticks>
    if(killed(myproc())){
    80003000:	b9bfe0ef          	jal	ra,80001b9a <myproc>
    80003004:	ec6ff0ef          	jal	ra,800026ca <killed>
    80003008:	ed0d                	bnez	a0,80003042 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000300a:	85ce                	mv	a1,s3
    8000300c:	8526                	mv	a0,s1
    8000300e:	c84ff0ef          	jal	ra,80002492 <sleep>
  while(ticks - ticks0 < n){
    80003012:	409c                	lw	a5,0(s1)
    80003014:	412787bb          	subw	a5,a5,s2
    80003018:	fcc42703          	lw	a4,-52(s0)
    8000301c:	fee7e2e3          	bltu	a5,a4,80003000 <sys_pause+0x4a>
  release(&tickslock);
    80003020:	0023e517          	auipc	a0,0x23e
    80003024:	81050513          	addi	a0,a0,-2032 # 80240830 <tickslock>
    80003028:	d21fd0ef          	jal	ra,80000d48 <release>
  return 0;
    8000302c:	4501                	li	a0,0
}
    8000302e:	70e2                	ld	ra,56(sp)
    80003030:	7442                	ld	s0,48(sp)
    80003032:	74a2                	ld	s1,40(sp)
    80003034:	7902                	ld	s2,32(sp)
    80003036:	69e2                	ld	s3,24(sp)
    80003038:	6121                	addi	sp,sp,64
    8000303a:	8082                	ret
    n = 0;
    8000303c:	fc042623          	sw	zero,-52(s0)
    80003040:	bf59                	j	80002fd6 <sys_pause+0x20>
      release(&tickslock);
    80003042:	0023d517          	auipc	a0,0x23d
    80003046:	7ee50513          	addi	a0,a0,2030 # 80240830 <tickslock>
    8000304a:	cfffd0ef          	jal	ra,80000d48 <release>
      return -1;
    8000304e:	557d                	li	a0,-1
    80003050:	bff9                	j	8000302e <sys_pause+0x78>

0000000080003052 <sys_kill>:
{
    80003052:	1101                	addi	sp,sp,-32
    80003054:	ec06                	sd	ra,24(sp)
    80003056:	e822                	sd	s0,16(sp)
    80003058:	1000                	addi	s0,sp,32
  argint(0, &pid);
    8000305a:	fec40593          	addi	a1,s0,-20
    8000305e:	4501                	li	a0,0
    80003060:	d69ff0ef          	jal	ra,80002dc8 <argint>
  return kkill(pid);
    80003064:	fec42503          	lw	a0,-20(s0)
    80003068:	dd8ff0ef          	jal	ra,80002640 <kkill>
}
    8000306c:	60e2                	ld	ra,24(sp)
    8000306e:	6442                	ld	s0,16(sp)
    80003070:	6105                	addi	sp,sp,32
    80003072:	8082                	ret

0000000080003074 <sys_uptime>:
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	e426                	sd	s1,8(sp)
    8000307c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000307e:	0023d517          	auipc	a0,0x23d
    80003082:	7b250513          	addi	a0,a0,1970 # 80240830 <tickslock>
    80003086:	c2bfd0ef          	jal	ra,80000cb0 <acquire>
  xticks = ticks;
    8000308a:	00006497          	auipc	s1,0x6
    8000308e:	83e4a483          	lw	s1,-1986(s1) # 800088c8 <ticks>
  release(&tickslock);
    80003092:	0023d517          	auipc	a0,0x23d
    80003096:	79e50513          	addi	a0,a0,1950 # 80240830 <tickslock>
    8000309a:	caffd0ef          	jal	ra,80000d48 <release>
}
    8000309e:	02049513          	slli	a0,s1,0x20
    800030a2:	9101                	srli	a0,a0,0x20
    800030a4:	60e2                	ld	ra,24(sp)
    800030a6:	6442                	ld	s0,16(sp)
    800030a8:	64a2                	ld	s1,8(sp)
    800030aa:	6105                	addi	sp,sp,32
    800030ac:	8082                	ret

00000000800030ae <vma_find>:
{
    800030ae:	1141                	addi	sp,sp,-16
    800030b0:	e422                	sd	s0,8(sp)
    800030b2:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    800030b4:	16850793          	addi	a5,a0,360
    800030b8:	4701                	li	a4,0
    800030ba:	4841                	li	a6,16
    800030bc:	a031                	j	800030c8 <vma_find+0x1a>
    800030be:	2705                	addiw	a4,a4,1
    800030c0:	02878793          	addi	a5,a5,40
    800030c4:	03070263          	beq	a4,a6,800030e8 <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    800030c8:	4394                	lw	a3,0(a5)
    800030ca:	daf5                	beqz	a3,800030be <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    800030cc:	6794                	ld	a3,8(a5)
    800030ce:	fed5e8e3          	bltu	a1,a3,800030be <vma_find+0x10>
    800030d2:	6b94                	ld	a3,16(a5)
    800030d4:	fed5f5e3          	bgeu	a1,a3,800030be <vma_find+0x10>
      return &p->vmas[i];
    800030d8:	00271793          	slli	a5,a4,0x2
    800030dc:	97ba                	add	a5,a5,a4
    800030de:	078e                	slli	a5,a5,0x3
    800030e0:	16878793          	addi	a5,a5,360
    800030e4:	953e                	add	a0,a0,a5
    800030e6:	a011                	j	800030ea <vma_find+0x3c>
  return 0;  // 没有找到包含该虚拟地址的VMA
    800030e8:	4501                	li	a0,0
}
    800030ea:	6422                	ld	s0,8(sp)
    800030ec:	0141                	addi	sp,sp,16
    800030ee:	8082                	ret

00000000800030f0 <sys_mmap>:

uint64
sys_mmap(void)
{
    800030f0:	7119                	addi	sp,sp,-128
    800030f2:	fc86                	sd	ra,120(sp)
    800030f4:	f8a2                	sd	s0,112(sp)
    800030f6:	f4a6                	sd	s1,104(sp)
    800030f8:	f0ca                	sd	s2,96(sp)
    800030fa:	ecce                	sd	s3,88(sp)
    800030fc:	e8d2                	sd	s4,80(sp)
    800030fe:	e4d6                	sd	s5,72(sp)
    80003100:	e0da                	sd	s6,64(sp)
    80003102:	fc5e                	sd	s7,56(sp)
    80003104:	f862                	sd	s8,48(sp)
    80003106:	f466                	sd	s9,40(sp)
    80003108:	0100                	addi	s0,sp,128
  uint64 addr;
  int len, prot, flags, key = -1;
    8000310a:	57fd                	li	a5,-1
    8000310c:	f8f42423          	sw	a5,-120(s0)
  int did_shm_get = 0;
  int need_get = 0;
  int npages = 0;

  argaddr(0, &addr);
    80003110:	f9840593          	addi	a1,s0,-104
    80003114:	4501                	li	a0,0
    80003116:	ccfff0ef          	jal	ra,80002de4 <argaddr>
  argint(1, &len);
    8000311a:	f9440593          	addi	a1,s0,-108
    8000311e:	4505                	li	a0,1
    80003120:	ca9ff0ef          	jal	ra,80002dc8 <argint>
  argint(2, &prot);
    80003124:	f9040593          	addi	a1,s0,-112
    80003128:	4509                	li	a0,2
    8000312a:	c9fff0ef          	jal	ra,80002dc8 <argint>
  argint(3, &flags);
    8000312e:	f8c40593          	addi	a1,s0,-116
    80003132:	450d                	li	a0,3
    80003134:	c95ff0ef          	jal	ra,80002dc8 <argint>
  argint(4, &key);
    80003138:	f8840593          	addi	a1,s0,-120
    8000313c:	4511                	li	a0,4
    8000313e:	c8bff0ef          	jal	ra,80002dc8 <argint>

  if(len <= 0) return (uint64)-1;
    80003142:	f9442783          	lw	a5,-108(s0)
    80003146:	1af05b63          	blez	a5,800032fc <sys_mmap+0x20c>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return (uint64)-1;
  if(plen > (MMAPTOP - MMAPBASE)) return (uint64)-1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return (uint64)-1;
    8000314a:	f9042903          	lw	s2,-112(s0)
    8000314e:	ffc97913          	andi	s2,s2,-4
    80003152:	54fd                	li	s1,-1
    80003154:	1a091563          	bnez	s2,800032fe <sys_mmap+0x20e>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    80003158:	f8c42703          	lw	a4,-116(s0)
    8000315c:	8b05                	andi	a4,a4,1
    8000315e:	1a070063          	beqz	a4,800032fe <sys_mmap+0x20e>
  if(addr != 0) return (uint64)-1;
    80003162:	f9843a03          	ld	s4,-104(s0)
    80003166:	180a1c63          	bnez	s4,800032fe <sys_mmap+0x20e>
  uint64 plen = PGROUNDUP((uint64)len);
    8000316a:	6985                	lui	s3,0x1
    8000316c:	19fd                	addi	s3,s3,-1
    8000316e:	99be                	add	s3,s3,a5

  struct proc *p = myproc();
    80003170:	a2bfe0ef          	jal	ra,80001b9a <myproc>
    80003174:	8aaa                	mv	s5,a0

  //先把“是否需要 shm_get”算出来（此时还没创建/污染 vma）
  if(flags & MAP_SHARED){
    80003176:	f8c42b83          	lw	s7,-116(s0)
    8000317a:	002bfb93          	andi	s7,s7,2
    8000317e:	020b8563          	beqz	s7,800031a8 <sys_mmap+0xb8>
    if(key < 0) return (uint64)-1;
    80003182:	f8842503          	lw	a0,-120(s0)
    80003186:	16054c63          	bltz	a0,800032fe <sys_mmap+0x20e>
    npages = plen / PGSIZE;
    8000318a:	40c9dc13          	srai	s8,s3,0xc

    // rmid 后禁止新 attach
    if(shm_is_deleted(key))
    8000318e:	063030ef          	jal	ra,800069f0 <shm_is_deleted>
    80003192:	16051663          	bnez	a0,800032fe <sys_mmap+0x20e>
      return (uint64)-1;

    // 按进程计数：本进程首次引用才 shm_get
    if(!proc_has_shm_key(p, key, 0))
    80003196:	4601                	li	a2,0
    80003198:	f8842583          	lw	a1,-120(s0)
    8000319c:	8556                	mv	a0,s5
    8000319e:	cf7ff0ef          	jal	ra,80002e94 <proc_has_shm_key>
  int need_get = 0;
    800031a2:	00153b93          	seqz	s7,a0
    800031a6:	a011                	j	800031aa <sys_mmap+0xba>
  int npages = 0;
    800031a8:	8c5e                	mv	s8,s7
  for(int i = 0; i < NVMA; i++){
    800031aa:	168a8b13          	addi	s6,s5,360
  int npages = 0;
    800031ae:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    800031b0:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    800031b2:	4398                	lw	a4,0(a5)
    800031b4:	cb01                	beqz	a4,800031c4 <sys_mmap+0xd4>
  for(int i = 0; i < NVMA; i++){
    800031b6:	2905                	addiw	s2,s2,1
    800031b8:	02878793          	addi	a5,a5,40
    800031bc:	fed91be3          	bne	s2,a3,800031b2 <sys_mmap+0xc2>
      need_get = 1;
  }

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    800031c0:	54fd                	li	s1,-1
    800031c2:	aa35                	j	800032fe <sys_mmap+0x20e>
  uint64 plen = PGROUNDUP((uint64)len);
    800031c4:	74fd                	lui	s1,0xfffff
    800031c6:	0099f9b3          	and	s3,s3,s1
      return &p->vmas[i];
    800031ca:	00291c93          	slli	s9,s2,0x2
    800031ce:	012c8533          	add	a0,s9,s2
    800031d2:	050e                	slli	a0,a0,0x3
    800031d4:	16850513          	addi	a0,a0,360

  // 先清空这条 slot，避免失败时留下脏状态
  memset(v, 0, sizeof(*v));
    800031d8:	02800613          	li	a2,40
    800031dc:	4581                	li	a1,0
    800031de:	9556                	add	a0,a0,s5
    800031e0:	ba5fd0ef          	jal	ra,80000d84 <memset>
  v->shm_key = -1;
    800031e4:	012c87b3          	add	a5,s9,s2
    800031e8:	078e                	slli	a5,a5,0x3
    800031ea:	97d6                	add	a5,a5,s5
    800031ec:	577d                	li	a4,-1
    800031ee:	18e7a623          	sw	a4,396(a5)
  len = PGROUNDUP(len);  // 将长度向上对齐到页边界
    800031f2:	6805                	lui	a6,0x1
    800031f4:	187d                	addi	a6,a6,-1
    800031f6:	984e                	add	a6,a6,s3
    800031f8:	00987833          	and	a6,a6,s1
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    800031fc:	400005b7          	lui	a1,0x40000
    80003200:	95c2                	add	a1,a1,a6
    80003202:	400004b7          	lui	s1,0x40000
    80003206:	3e8a8613          	addi	a2,s5,1000
    va = PGROUNDUP(jump);
    8000320a:	6305                	lui	t1,0x1
    8000320c:	137d                	addi	t1,t1,-1
    8000320e:	7e7d                	lui	t3,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003210:	f3fff8b7          	lui	a7,0xf3fff
    80003214:	08ba                	slli	a7,a7,0xe
    80003216:	01a8d893          	srli	a7,a7,0x1a
    8000321a:	a81d                	j	80003250 <sys_mmap+0x160>
      if(best == 0 || e < best) best = e;
    8000321c:	8536                	mv	a0,a3
  for(int i=0; i<NVMA; i++){
    8000321e:	02878793          	addi	a5,a5,40
    80003222:	00c78f63          	beq	a5,a2,80003240 <sys_mmap+0x150>
    if(!p->vmas[i].used) continue;
    80003226:	4398                	lw	a4,0(a5)
    80003228:	db7d                	beqz	a4,8000321e <sys_mmap+0x12e>
    uint64 e = p->vmas[i].end;
    8000322a:	6b94                	ld	a3,16(a5)
    if(!(end <= s || start >= e)){
    8000322c:	6798                	ld	a4,8(a5)
    8000322e:	feb778e3          	bgeu	a4,a1,8000321e <sys_mmap+0x12e>
    80003232:	fed4f6e3          	bgeu	s1,a3,8000321e <sys_mmap+0x12e>
      if(best == 0 || e < best) best = e;
    80003236:	d17d                	beqz	a0,8000321c <sys_mmap+0x12c>
    80003238:	fea6f3e3          	bgeu	a3,a0,8000321e <sys_mmap+0x12e>
    8000323c:	8536                	mv	a0,a3
    8000323e:	b7c5                	j	8000321e <sys_mmap+0x12e>
    if(jump == 0){
    80003240:	c919                	beqz	a0,80003256 <sys_mmap+0x166>
    va = PGROUNDUP(jump);
    80003242:	951a                	add	a0,a0,t1
    80003244:	01c574b3          	and	s1,a0,t3
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003248:	009805b3          	add	a1,a6,s1
    8000324c:	06b8ed63          	bltu	a7,a1,800032c6 <sys_mmap+0x1d6>
  int npages = 0;
    80003250:	87da                	mv	a5,s6
  uint64 best = 0;
    80003252:	8552                	mv	a0,s4
    80003254:	bfc9                	j	80003226 <sys_mmap+0x136>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) goto bad;
  if(va < MMAPBASE || va + plen > MMAPTOP) goto bad;
    80003256:	400007b7          	lui	a5,0x40000
    8000325a:	06f4e663          	bltu	s1,a5,800032c6 <sys_mmap+0x1d6>
    8000325e:	99a6                	add	s3,s3,s1
    80003260:	010007b7          	lui	a5,0x1000
    80003264:	17f5                	addi	a5,a5,-3
    80003266:	07ba                	slli	a5,a5,0xe
    80003268:	0537ef63          	bltu	a5,s3,800032c6 <sys_mmap+0x1d6>

  // 先写入 vma 基本信息
  v->used  = 1;
    8000326c:	00291793          	slli	a5,s2,0x2
    80003270:	97ca                	add	a5,a5,s2
    80003272:	078e                	slli	a5,a5,0x3
    80003274:	97d6                	add	a5,a5,s5
    80003276:	4705                	li	a4,1
    80003278:	16e7a423          	sw	a4,360(a5) # 1000168 <_entry-0x7efffe98>
  v->start = va;
    8000327c:	1697b823          	sd	s1,368(a5)
  v->end   = va + plen;
    80003280:	1737bc23          	sd	s3,376(a5)
  v->prot  = prot;
    80003284:	f9042703          	lw	a4,-112(s0)
    80003288:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    8000328c:	f8c42703          	lw	a4,-116(s0)
    80003290:	18e7a223          	sw	a4,388(a5)

  if(flags & MAP_SHARED){
    80003294:	8b09                	andi	a4,a4,2
    80003296:	c725                	beqz	a4,800032fe <sys_mmap+0x20e>
    if(need_get){
    80003298:	020b9063          	bnez	s7,800032b8 <sys_mmap+0x1c8>
      if(shm_get(key, npages) < 0)
        goto bad;
      did_shm_get = 1;
    }
    v->is_shm = 1;
    8000329c:	00291793          	slli	a5,s2,0x2
    800032a0:	01278733          	add	a4,a5,s2
    800032a4:	070e                	slli	a4,a4,0x3
    800032a6:	9756                	add	a4,a4,s5
    800032a8:	4685                	li	a3,1
    800032aa:	18d72423          	sw	a3,392(a4) # 2000188 <_entry-0x7dfffe78>
    v->shm_key = key;
    800032ae:	f8842783          	lw	a5,-120(s0)
    800032b2:	18f72623          	sw	a5,396(a4)
    800032b6:	a0a1                	j	800032fe <sys_mmap+0x20e>
      if(shm_get(key, npages) < 0)
    800032b8:	85e2                	mv	a1,s8
    800032ba:	f8842503          	lw	a0,-120(s0)
    800032be:	2f2030ef          	jal	ra,800065b0 <shm_get>
    800032c2:	fc055de3          	bgez	a0,8000329c <sys_mmap+0x1ac>
bad:
  if(did_shm_get){
    shm_put(key);
  }
  if(v){
    v->used = 0;
    800032c6:	00291713          	slli	a4,s2,0x2
    800032ca:	012707b3          	add	a5,a4,s2
    800032ce:	078e                	slli	a5,a5,0x3
    800032d0:	97d6                	add	a5,a5,s5
    800032d2:	1607a423          	sw	zero,360(a5)
    v->is_shm = 0;
    800032d6:	1807a423          	sw	zero,392(a5)
    v->shm_key = -1;
    800032da:	56fd                	li	a3,-1
    800032dc:	18d7a623          	sw	a3,396(a5)
    v->start = v->end = 0;
    800032e0:	1607bc23          	sd	zero,376(a5)
    800032e4:	1607b823          	sd	zero,368(a5)
    v->prot = v->flags = 0;
    800032e8:	1807a223          	sw	zero,388(a5)
    800032ec:	012707b3          	add	a5,a4,s2
    800032f0:	078e                	slli	a5,a5,0x3
    800032f2:	9abe                	add	s5,s5,a5
    800032f4:	180aa023          	sw	zero,384(s5)
  }
  return (uint64)-1;
    800032f8:	54fd                	li	s1,-1
    800032fa:	a011                	j	800032fe <sys_mmap+0x20e>
  if(len <= 0) return (uint64)-1;
    800032fc:	54fd                	li	s1,-1
}
    800032fe:	8526                	mv	a0,s1
    80003300:	70e6                	ld	ra,120(sp)
    80003302:	7446                	ld	s0,112(sp)
    80003304:	74a6                	ld	s1,104(sp)
    80003306:	7906                	ld	s2,96(sp)
    80003308:	69e6                	ld	s3,88(sp)
    8000330a:	6a46                	ld	s4,80(sp)
    8000330c:	6aa6                	ld	s5,72(sp)
    8000330e:	6b06                	ld	s6,64(sp)
    80003310:	7be2                	ld	s7,56(sp)
    80003312:	7c42                	ld	s8,48(sp)
    80003314:	7ca2                	ld	s9,40(sp)
    80003316:	6109                	addi	sp,sp,128
    80003318:	8082                	ret

000000008000331a <sys_munmap>:
}


uint64
sys_munmap(void)
{
    8000331a:	7159                	addi	sp,sp,-112
    8000331c:	f486                	sd	ra,104(sp)
    8000331e:	f0a2                	sd	s0,96(sp)
    80003320:	eca6                	sd	s1,88(sp)
    80003322:	e8ca                	sd	s2,80(sp)
    80003324:	e4ce                	sd	s3,72(sp)
    80003326:	e0d2                	sd	s4,64(sp)
    80003328:	fc56                	sd	s5,56(sp)
    8000332a:	f85a                	sd	s6,48(sp)
    8000332c:	f45e                	sd	s7,40(sp)
    8000332e:	f062                	sd	s8,32(sp)
    80003330:	ec66                	sd	s9,24(sp)
    80003332:	e86a                	sd	s10,16(sp)
    80003334:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    80003336:	865fe0ef          	jal	ra,80001b9a <myproc>
    8000333a:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    8000333c:	f9840593          	addi	a1,s0,-104
    80003340:	4501                	li	a0,0
    80003342:	aa3ff0ef          	jal	ra,80002de4 <argaddr>
  argint(1, &len);
    80003346:	f9440593          	addi	a1,s0,-108
    8000334a:	4505                	li	a0,1
    8000334c:	a7dff0ef          	jal	ra,80002dc8 <argint>

  if(len <= 0) return (uint64)-1;
    80003350:	f9442703          	lw	a4,-108(s0)
    80003354:	2ce05e63          	blez	a4,80003630 <sys_munmap+0x316>


  uint64 a = PGROUNDDOWN(uaddr);
    80003358:	f9843783          	ld	a5,-104(s0)
    8000335c:	76fd                	lui	a3,0xfffff
    8000335e:	00d7fa33          	and	s4,a5,a3
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    80003362:	6905                	lui	s2,0x1
    80003364:	197d                	addi	s2,s2,-1
    80003366:	993e                	add	s2,s2,a5
    80003368:	993a                	add	s2,s2,a4
    8000336a:	00d97933          	and	s2,s2,a3
  if(b < a) return (uint64)-1;  // 溢出了
    8000336e:	557d                	li	a0,-1
    80003370:	17496d63          	bltu	s2,s4,800034ea <sys_munmap+0x1d0>
    80003374:	168a8b13          	addi	s6,s5,360
    80003378:	3e8a8993          	addi	s3,s5,1000
    8000337c:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    8000337e:	4801                	li	a6,0
    80003380:	a029                	j	8000338a <sys_munmap+0x70>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    80003382:	02878793          	addi	a5,a5,40
    80003386:	01378663          	beq	a5,s3,80003392 <sys_munmap+0x78>
    8000338a:	4398                	lw	a4,0(a5)
    8000338c:	fb7d                	bnez	a4,80003382 <sys_munmap+0x68>
    8000338e:	2805                	addiw	a6,a6,1
    80003390:	bfcd                	j	80003382 <sys_munmap+0x68>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    80003392:	8552                	mv	a0,s4
  int need_splits = 0;
    80003394:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    80003396:	4881                	li	a7,0
    80003398:	45c1                	li	a1,16
    8000339a:	537d                	li	t1,-1
  while(cur < b){
    8000339c:	072a6163          	bltu	s4,s2,800033fe <sys_munmap+0xe4>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    800033a0:	43f85513          	srai	a0,a6,0x3f
    800033a4:	a299                	j	800034ea <sys_munmap+0x1d0>
  for(int i = 0; i < NVMA; i++){
    800033a6:	2705                	addiw	a4,a4,1
    800033a8:	02878793          	addi	a5,a5,40
    800033ac:	04b70c63          	beq	a4,a1,80003404 <sys_munmap+0xea>
    if(!p->vmas[i].used) continue;
    800033b0:	4394                	lw	a3,0(a5)
    800033b2:	daf5                	beqz	a3,800033a6 <sys_munmap+0x8c>
    if(!(b <= s || a >= e))   // 存在地址重叠
    800033b4:	6794                	ld	a3,8(a5)
    800033b6:	ff26f8e3          	bgeu	a3,s2,800033a6 <sys_munmap+0x8c>
    800033ba:	6b94                	ld	a3,16(a5)
    800033bc:	fed575e3          	bgeu	a0,a3,800033a6 <sys_munmap+0x8c>
    if(vi < 0){
    800033c0:	04074563          	bltz	a4,8000340a <sys_munmap+0xf0>
    uint64 seg_start = cur > v->start ? cur : v->start;
    800033c4:	00271793          	slli	a5,a4,0x2
    800033c8:	97ba                	add	a5,a5,a4
    800033ca:	078e                	slli	a5,a5,0x3
    800033cc:	97d6                	add	a5,a5,s5
    800033ce:	1707b683          	ld	a3,368(a5)
    800033d2:	8636                	mv	a2,a3
    800033d4:	00a6f363          	bgeu	a3,a0,800033da <sys_munmap+0xc0>
    800033d8:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    800033da:	00271793          	slli	a5,a4,0x2
    800033de:	97ba                	add	a5,a5,a4
    800033e0:	078e                	slli	a5,a5,0x3
    800033e2:	97d6                	add	a5,a5,s5
    800033e4:	1787b783          	ld	a5,376(a5)
    800033e8:	853e                	mv	a0,a5
    800033ea:	00f97363          	bgeu	s2,a5,800033f0 <sys_munmap+0xd6>
    800033ee:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    800033f0:	00c6f563          	bgeu	a3,a2,800033fa <sys_munmap+0xe0>
    800033f4:	00f57363          	bgeu	a0,a5,800033fa <sys_munmap+0xe0>
      need_splits++;
    800033f8:	2e05                	addiw	t3,t3,1
  while(cur < b){
    800033fa:	03257a63          	bgeu	a0,s2,8000342e <sys_munmap+0x114>
  int free_slots = 0;
    800033fe:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003400:	8746                	mv	a4,a7
    80003402:	b77d                	j	800033b0 <sys_munmap+0x96>
    80003404:	87da                	mv	a5,s6
    80003406:	869a                	mv	a3,t1
    80003408:	a801                	j	80003418 <sys_munmap+0xfe>
    8000340a:	87da                	mv	a5,s6
    8000340c:	869a                	mv	a3,t1
    8000340e:	a029                	j	80003418 <sys_munmap+0xfe>
  for(int i = 0; i < NVMA; i++){
    80003410:	02878793          	addi	a5,a5,40
    80003414:	01378b63          	beq	a5,s3,8000342a <sys_munmap+0x110>
    if(!p->vmas[i].used) continue;
    80003418:	4398                	lw	a4,0(a5)
    8000341a:	db7d                	beqz	a4,80003410 <sys_munmap+0xf6>
    uint64 s = p->vmas[i].start;
    8000341c:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    8000341e:	fea769e3          	bltu	a4,a0,80003410 <sys_munmap+0xf6>
    80003422:	fed777e3          	bgeu	a4,a3,80003410 <sys_munmap+0xf6>
    80003426:	86ba                	mv	a3,a4
    80003428:	b7e5                	j	80003410 <sys_munmap+0xf6>
      if(ns == (uint64)-1 || ns >= b) break;
    8000342a:	0126e963          	bltu	a3,s2,8000343c <sys_munmap+0x122>
    // 不做任何事，保持一致性
    return (uint64)-1;
    8000342e:	557d                	li	a0,-1
  if(need_splits > free_slots){
    80003430:	0bc84d63          	blt	a6,t3,800034ea <sys_munmap+0x1d0>
  for(int i = 0; i < NVMA; i++){
    80003434:	4c01                	li	s8,0
    80003436:	4bc1                	li	s7,16
    80003438:	5cfd                	li	s9,-1
    8000343a:	aac5                	j	8000362a <sys_munmap+0x310>
    8000343c:	8536                	mv	a0,a3
    8000343e:	b7c1                	j	800033fe <sys_munmap+0xe4>
    80003440:	2485                	addiw	s1,s1,1
    80003442:	02878793          	addi	a5,a5,40
    80003446:	07748c63          	beq	s1,s7,800034be <sys_munmap+0x1a4>
    if(!p->vmas[i].used) continue;
    8000344a:	4398                	lw	a4,0(a5)
    8000344c:	db75                	beqz	a4,80003440 <sys_munmap+0x126>
    if(!(b <= s || a >= e))   // 存在地址重叠
    8000344e:	6798                	ld	a4,8(a5)
    80003450:	ff2778e3          	bgeu	a4,s2,80003440 <sys_munmap+0x126>
    80003454:	6b98                	ld	a4,16(a5)
    80003456:	feea75e3          	bgeu	s4,a4,80003440 <sys_munmap+0x126>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    8000345a:	0604c563          	bltz	s1,800034c4 <sys_munmap+0x1aa>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    8000345e:	00249793          	slli	a5,s1,0x2
    80003462:	97a6                	add	a5,a5,s1
    80003464:	078e                	slli	a5,a5,0x3
    80003466:	97d6                	add	a5,a5,s5
    80003468:	1707bd03          	ld	s10,368(a5)
    8000346c:	014d7363          	bgeu	s10,s4,80003472 <sys_munmap+0x158>
    80003470:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003472:	00249793          	slli	a5,s1,0x2
    80003476:	97a6                	add	a5,a5,s1
    80003478:	078e                	slli	a5,a5,0x3
    8000347a:	97d6                	add	a5,a5,s5
    8000347c:	1787ba03          	ld	s4,376(a5)
    80003480:	01497363          	bgeu	s2,s4,80003486 <sys_munmap+0x16c>
    80003484:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    80003486:	094d6263          	bltu	s10,s4,8000350a <sys_munmap+0x1f0>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    8000348a:	00249793          	slli	a5,s1,0x2
    8000348e:	97a6                	add	a5,a5,s1
    80003490:	078e                	slli	a5,a5,0x3
    80003492:	97d6                	add	a5,a5,s5
    80003494:	1707b783          	ld	a5,368(a5)
    80003498:	11a7e463          	bltu	a5,s10,800035a0 <sys_munmap+0x286>
    8000349c:	00249793          	slli	a5,s1,0x2
    800034a0:	97a6                	add	a5,a5,s1
    800034a2:	078e                	slli	a5,a5,0x3
    800034a4:	97d6                	add	a5,a5,s5
    800034a6:	1787b783          	ld	a5,376(a5)
    800034aa:	06fa7a63          	bgeu	s4,a5,8000351e <sys_munmap+0x204>
      //  v->shm_key, v->used, (void *)v->start, (void *)v->end);

      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    800034ae:	00249793          	slli	a5,s1,0x2
    800034b2:	97a6                	add	a5,a5,s1
    800034b4:	078e                	slli	a5,a5,0x3
    800034b6:	97d6                	add	a5,a5,s5
    800034b8:	1747b823          	sd	s4,368(a5)
    800034bc:	a2ad                	j	80003626 <sys_munmap+0x30c>
    800034be:	87da                	mv	a5,s6
    800034c0:	86e6                	mv	a3,s9
    800034c2:	a801                	j	800034d2 <sys_munmap+0x1b8>
    800034c4:	87da                	mv	a5,s6
    800034c6:	86e6                	mv	a3,s9
    800034c8:	a029                	j	800034d2 <sys_munmap+0x1b8>
  for(int i = 0; i < NVMA; i++){
    800034ca:	02878793          	addi	a5,a5,40
    800034ce:	01378b63          	beq	a5,s3,800034e4 <sys_munmap+0x1ca>
    if(!p->vmas[i].used) continue;
    800034d2:	4398                	lw	a4,0(a5)
    800034d4:	db7d                	beqz	a4,800034ca <sys_munmap+0x1b0>
    uint64 s = p->vmas[i].start;
    800034d6:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    800034d8:	ff4769e3          	bltu	a4,s4,800034ca <sys_munmap+0x1b0>
    800034dc:	fed777e3          	bgeu	a4,a3,800034ca <sys_munmap+0x1b0>
    800034e0:	86ba                	mv	a3,a4
    800034e2:	b7e5                	j	800034ca <sys_munmap+0x1b0>
      if(ns == (uint64)-1 || ns >= b) break;
    800034e4:	0326e163          	bltu	a3,s2,80003506 <sys_munmap+0x1ec>
    }

    cur = seg_end;
  }
  //shm_dump(1);
  return 0;
    800034e8:	4501                	li	a0,0
}
    800034ea:	70a6                	ld	ra,104(sp)
    800034ec:	7406                	ld	s0,96(sp)
    800034ee:	64e6                	ld	s1,88(sp)
    800034f0:	6946                	ld	s2,80(sp)
    800034f2:	69a6                	ld	s3,72(sp)
    800034f4:	6a06                	ld	s4,64(sp)
    800034f6:	7ae2                	ld	s5,56(sp)
    800034f8:	7b42                	ld	s6,48(sp)
    800034fa:	7ba2                	ld	s7,40(sp)
    800034fc:	7c02                	ld	s8,32(sp)
    800034fe:	6ce2                	ld	s9,24(sp)
    80003500:	6d42                	ld	s10,16(sp)
    80003502:	6165                	addi	sp,sp,112
    80003504:	8082                	ret
    80003506:	8a36                	mv	s4,a3
    80003508:	a20d                	j	8000362a <sys_munmap+0x310>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    8000350a:	41aa0633          	sub	a2,s4,s10
    8000350e:	4685                	li	a3,1
    80003510:	8231                	srli	a2,a2,0xc
    80003512:	85ea                	mv	a1,s10
    80003514:	050ab503          	ld	a0,80(s5)
    80003518:	d99fd0ef          	jal	ra,800012b0 <uvmunmap>
    8000351c:	b7bd                	j	8000348a <sys_munmap+0x170>
  if(v->used == 0) return;
    8000351e:	00249793          	slli	a5,s1,0x2
    80003522:	97a6                	add	a5,a5,s1
    80003524:	078e                	slli	a5,a5,0x3
    80003526:	97d6                	add	a5,a5,s5
    80003528:	1687a783          	lw	a5,360(a5)
    8000352c:	0e078d63          	beqz	a5,80003626 <sys_munmap+0x30c>
  if(v->is_shm){
    80003530:	00249793          	slli	a5,s1,0x2
    80003534:	97a6                	add	a5,a5,s1
    80003536:	078e                	slli	a5,a5,0x3
    80003538:	97d6                	add	a5,a5,s5
    8000353a:	1887a783          	lw	a5,392(a5)
    8000353e:	c785                	beqz	a5,80003566 <sys_munmap+0x24c>
    int key = v->shm_key;
    80003540:	00249793          	slli	a5,s1,0x2
    80003544:	00978733          	add	a4,a5,s1
    80003548:	070e                	slli	a4,a4,0x3
    8000354a:	9756                	add	a4,a4,s5
    8000354c:	18c72d03          	lw	s10,396(a4)
    struct vma *v = &p->vmas[vi];
    80003550:	00978633          	add	a2,a5,s1
    80003554:	060e                	slli	a2,a2,0x3
    80003556:	16860613          	addi	a2,a2,360 # 1168 <_entry-0x7fffee98>
    if(!proc_has_shm_key(p, key, v)){
    8000355a:	9656                	add	a2,a2,s5
    8000355c:	85ea                	mv	a1,s10
    8000355e:	8556                	mv	a0,s5
    80003560:	935ff0ef          	jal	ra,80002e94 <proc_has_shm_key>
    80003564:	c915                	beqz	a0,80003598 <sys_munmap+0x27e>
  v->used = 0;
    80003566:	00249713          	slli	a4,s1,0x2
    8000356a:	009707b3          	add	a5,a4,s1
    8000356e:	078e                	slli	a5,a5,0x3
    80003570:	97d6                	add	a5,a5,s5
    80003572:	1607a423          	sw	zero,360(a5)
  v->start = v->end = 0;
    80003576:	1607bc23          	sd	zero,376(a5)
    8000357a:	1607b823          	sd	zero,368(a5)
  v->prot = v->flags = 0;
    8000357e:	1807a223          	sw	zero,388(a5)
    80003582:	1807a023          	sw	zero,384(a5)
  v->is_shm = 0;
    80003586:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    8000358a:	009707b3          	add	a5,a4,s1
    8000358e:	078e                	slli	a5,a5,0x3
    80003590:	97d6                	add	a5,a5,s5
    80003592:	1997a623          	sw	s9,396(a5)
    80003596:	a841                	j	80003626 <sys_munmap+0x30c>
      shm_put(key);  // 没有其他引用，释放共享内存
    80003598:	856a                	mv	a0,s10
    8000359a:	15a030ef          	jal	ra,800066f4 <shm_put>
    8000359e:	b7e1                	j	80003566 <sys_munmap+0x24c>
    } else if(seg_start > v->start && seg_end >= v->end){
    800035a0:	00249793          	slli	a5,s1,0x2
    800035a4:	97a6                	add	a5,a5,s1
    800035a6:	078e                	slli	a5,a5,0x3
    800035a8:	97d6                	add	a5,a5,s5
    800035aa:	1787b783          	ld	a5,376(a5)
    800035ae:	00fa6a63          	bltu	s4,a5,800035c2 <sys_munmap+0x2a8>
      v->end = seg_start;
    800035b2:	00249793          	slli	a5,s1,0x2
    800035b6:	97a6                	add	a5,a5,s1
    800035b8:	078e                	slli	a5,a5,0x3
    800035ba:	97d6                	add	a5,a5,s5
    800035bc:	17a7bc23          	sd	s10,376(a5)
    800035c0:	a09d                	j	80003626 <sys_munmap+0x30c>
    800035c2:	875a                	mv	a4,s6
    800035c4:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    800035c6:	4314                	lw	a3,0(a4)
    800035c8:	c699                	beqz	a3,800035d6 <sys_munmap+0x2bc>
  for(int i = 0; i < NVMA; i++){
    800035ca:	2785                	addiw	a5,a5,1
    800035cc:	02870713          	addi	a4,a4,40
    800035d0:	ff779be3          	bne	a5,s7,800035c6 <sys_munmap+0x2ac>
  return -1;  // 没有空闲的VMA索引
    800035d4:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    800035d6:	00279593          	slli	a1,a5,0x2
    800035da:	00f586b3          	add	a3,a1,a5
    800035de:	068e                	slli	a3,a3,0x3
    800035e0:	96d6                	add	a3,a3,s5
    800035e2:	00249613          	slli	a2,s1,0x2
    800035e6:	00960733          	add	a4,a2,s1
    800035ea:	070e                	slli	a4,a4,0x3
    800035ec:	9756                	add	a4,a4,s5
    800035ee:	16873303          	ld	t1,360(a4)
    800035f2:	17873883          	ld	a7,376(a4)
    800035f6:	18073803          	ld	a6,384(a4)
    800035fa:	18873503          	ld	a0,392(a4)
    800035fe:	1666b423          	sd	t1,360(a3) # fffffffffffff168 <end+0xffffffff7fdaaf78>
    80003602:	1716bc23          	sd	a7,376(a3)
    80003606:	1906b023          	sd	a6,384(a3)
    8000360a:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    8000360e:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    80003612:	17873703          	ld	a4,376(a4)
    80003616:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    8000361a:	009607b3          	add	a5,a2,s1
    8000361e:	078e                	slli	a5,a5,0x3
    80003620:	97d6                	add	a5,a5,s5
    80003622:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    80003626:	012a7763          	bgeu	s4,s2,80003634 <sys_munmap+0x31a>
  int need_splits = 0;
    8000362a:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    8000362c:	84e2                	mv	s1,s8
    8000362e:	bd31                	j	8000344a <sys_munmap+0x130>
  if(len <= 0) return (uint64)-1;
    80003630:	557d                	li	a0,-1
    80003632:	bd65                	j	800034ea <sys_munmap+0x1d0>
  return 0;
    80003634:	4501                	li	a0,0
    80003636:	bd55                	j	800034ea <sys_munmap+0x1d0>

0000000080003638 <sys_shmctl>:

uint64
sys_shmctl(void)
{
    80003638:	1101                	addi	sp,sp,-32
    8000363a:	ec06                	sd	ra,24(sp)
    8000363c:	e822                	sd	s0,16(sp)
    8000363e:	1000                	addi	s0,sp,32
  int key, cmd;
  argint(0, &key);
    80003640:	fec40593          	addi	a1,s0,-20
    80003644:	4501                	li	a0,0
    80003646:	f82ff0ef          	jal	ra,80002dc8 <argint>
  argint(1, &cmd);
    8000364a:	fe840593          	addi	a1,s0,-24
    8000364e:	4505                	li	a0,1
    80003650:	f78ff0ef          	jal	ra,80002dc8 <argint>
  return shm_ctl(key, cmd);
    80003654:	fe842583          	lw	a1,-24(s0)
    80003658:	fec42503          	lw	a0,-20(s0)
    8000365c:	28a030ef          	jal	ra,800068e6 <shm_ctl>
}
    80003660:	60e2                	ld	ra,24(sp)
    80003662:	6442                	ld	s0,16(sp)
    80003664:	6105                	addi	sp,sp,32
    80003666:	8082                	ret

0000000080003668 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003668:	7139                	addi	sp,sp,-64
    8000366a:	fc06                	sd	ra,56(sp)
    8000366c:	f822                	sd	s0,48(sp)
    8000366e:	f426                	sd	s1,40(sp)
    80003670:	f04a                	sd	s2,32(sp)
    80003672:	ec4e                	sd	s3,24(sp)
    80003674:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003676:	fcc40593          	addi	a1,s0,-52
    8000367a:	4501                	li	a0,0
    8000367c:	f4cff0ef          	jal	ra,80002dc8 <argint>
  if(n < 0)
    80003680:	fcc42783          	lw	a5,-52(s0)
    return -1;
    80003684:	557d                	li	a0,-1
  if(n < 0)
    80003686:	0407ce63          	bltz	a5,800036e2 <sys_sleep+0x7a>

  acquire(&tickslock);
    8000368a:	0023d517          	auipc	a0,0x23d
    8000368e:	1a650513          	addi	a0,a0,422 # 80240830 <tickslock>
    80003692:	e1efd0ef          	jal	ra,80000cb0 <acquire>
  ticks0 = ticks;
    80003696:	00005917          	auipc	s2,0x5
    8000369a:	23292903          	lw	s2,562(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    8000369e:	fcc42783          	lw	a5,-52(s0)
    800036a2:	cb8d                	beqz	a5,800036d4 <sys_sleep+0x6c>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);  
    800036a4:	0023d997          	auipc	s3,0x23d
    800036a8:	18c98993          	addi	s3,s3,396 # 80240830 <tickslock>
    800036ac:	00005497          	auipc	s1,0x5
    800036b0:	21c48493          	addi	s1,s1,540 # 800088c8 <ticks>
    if(killed(myproc())){
    800036b4:	ce6fe0ef          	jal	ra,80001b9a <myproc>
    800036b8:	812ff0ef          	jal	ra,800026ca <killed>
    800036bc:	e915                	bnez	a0,800036f0 <sys_sleep+0x88>
    sleep(&ticks, &tickslock);  
    800036be:	85ce                	mv	a1,s3
    800036c0:	8526                	mv	a0,s1
    800036c2:	dd1fe0ef          	jal	ra,80002492 <sleep>
  while(ticks - ticks0 < n){
    800036c6:	409c                	lw	a5,0(s1)
    800036c8:	412787bb          	subw	a5,a5,s2
    800036cc:	fcc42703          	lw	a4,-52(s0)
    800036d0:	fee7e2e3          	bltu	a5,a4,800036b4 <sys_sleep+0x4c>
  }
  release(&tickslock);
    800036d4:	0023d517          	auipc	a0,0x23d
    800036d8:	15c50513          	addi	a0,a0,348 # 80240830 <tickslock>
    800036dc:	e6cfd0ef          	jal	ra,80000d48 <release>
  return 0;
    800036e0:	4501                	li	a0,0
}
    800036e2:	70e2                	ld	ra,56(sp)
    800036e4:	7442                	ld	s0,48(sp)
    800036e6:	74a2                	ld	s1,40(sp)
    800036e8:	7902                	ld	s2,32(sp)
    800036ea:	69e2                	ld	s3,24(sp)
    800036ec:	6121                	addi	sp,sp,64
    800036ee:	8082                	ret
      release(&tickslock);
    800036f0:	0023d517          	auipc	a0,0x23d
    800036f4:	14050513          	addi	a0,a0,320 # 80240830 <tickslock>
    800036f8:	e50fd0ef          	jal	ra,80000d48 <release>
      return -1;
    800036fc:	557d                	li	a0,-1
    800036fe:	b7d5                	j	800036e2 <sys_sleep+0x7a>

0000000080003700 <sys_vmstats>:


uint64
sys_vmstats(void)
{
    80003700:	715d                	addi	sp,sp,-80
    80003702:	e486                	sd	ra,72(sp)
    80003704:	e0a2                	sd	s0,64(sp)
    80003706:	0880                	addi	s0,sp,80
  uint64 uaddr;
  argaddr(0, &uaddr);
    80003708:	fe840593          	addi	a1,s0,-24
    8000370c:	4501                	li	a0,0
    8000370e:	ed6ff0ef          	jal	ra,80002de4 <argaddr>

  struct vmstats_user s;
  vmstats_snapshot(&s);
    80003712:	fb840513          	addi	a0,s0,-72
    80003716:	5e4030ef          	jal	ra,80006cfa <vmstats_snapshot>

  extern uint64 kalloc_cnt, copyin_bytes, copyout_bytes;
  s.kalloc_cnt = kalloc_cnt;
    8000371a:	00005797          	auipc	a5,0x5
    8000371e:	1c67b783          	ld	a5,454(a5) # 800088e0 <kalloc_cnt>
    80003722:	fcf43823          	sd	a5,-48(s0)
  s.copyin_bytes = copyin_bytes;
    80003726:	00005797          	auipc	a5,0x5
    8000372a:	1b27b783          	ld	a5,434(a5) # 800088d8 <copyin_bytes>
    8000372e:	fcf43c23          	sd	a5,-40(s0)
  s.copyout_bytes = copyout_bytes;
    80003732:	00005797          	auipc	a5,0x5
    80003736:	19e7b783          	ld	a5,414(a5) # 800088d0 <copyout_bytes>
    8000373a:	fef43023          	sd	a5,-32(s0)

  if(copyout(myproc()->pagetable, uaddr, (char*)&s, sizeof(s)) < 0)
    8000373e:	c5cfe0ef          	jal	ra,80001b9a <myproc>
    80003742:	03000693          	li	a3,48
    80003746:	fb840613          	addi	a2,s0,-72
    8000374a:	fe843583          	ld	a1,-24(s0)
    8000374e:	6928                	ld	a0,80(a0)
    80003750:	83afe0ef          	jal	ra,8000178a <copyout>
    return -1;
  return 0;
    80003754:	957d                	srai	a0,a0,0x3f
    80003756:	60a6                	ld	ra,72(sp)
    80003758:	6406                	ld	s0,64(sp)
    8000375a:	6161                	addi	sp,sp,80
    8000375c:	8082                	ret

000000008000375e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000375e:	7179                	addi	sp,sp,-48
    80003760:	f406                	sd	ra,40(sp)
    80003762:	f022                	sd	s0,32(sp)
    80003764:	ec26                	sd	s1,24(sp)
    80003766:	e84a                	sd	s2,16(sp)
    80003768:	e44e                	sd	s3,8(sp)
    8000376a:	e052                	sd	s4,0(sp)
    8000376c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000376e:	00005597          	auipc	a1,0x5
    80003772:	d7a58593          	addi	a1,a1,-646 # 800084e8 <syscalls+0xf0>
    80003776:	0023d517          	auipc	a0,0x23d
    8000377a:	0d250513          	addi	a0,a0,210 # 80240848 <bcache>
    8000377e:	cb2fd0ef          	jal	ra,80000c30 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003782:	00245797          	auipc	a5,0x245
    80003786:	0c678793          	addi	a5,a5,198 # 80248848 <bcache+0x8000>
    8000378a:	00245717          	auipc	a4,0x245
    8000378e:	32670713          	addi	a4,a4,806 # 80248ab0 <bcache+0x8268>
    80003792:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003796:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000379a:	0023d497          	auipc	s1,0x23d
    8000379e:	0c648493          	addi	s1,s1,198 # 80240860 <bcache+0x18>
    b->next = bcache.head.next;
    800037a2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800037a4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800037a6:	00005a17          	auipc	s4,0x5
    800037aa:	d4aa0a13          	addi	s4,s4,-694 # 800084f0 <syscalls+0xf8>
    b->next = bcache.head.next;
    800037ae:	2b893783          	ld	a5,696(s2)
    800037b2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800037b4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800037b8:	85d2                	mv	a1,s4
    800037ba:	01048513          	addi	a0,s1,16
    800037be:	2fe010ef          	jal	ra,80004abc <initsleeplock>
    bcache.head.next->prev = b;
    800037c2:	2b893783          	ld	a5,696(s2)
    800037c6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800037c8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037cc:	45848493          	addi	s1,s1,1112
    800037d0:	fd349fe3          	bne	s1,s3,800037ae <binit+0x50>
  }
}
    800037d4:	70a2                	ld	ra,40(sp)
    800037d6:	7402                	ld	s0,32(sp)
    800037d8:	64e2                	ld	s1,24(sp)
    800037da:	6942                	ld	s2,16(sp)
    800037dc:	69a2                	ld	s3,8(sp)
    800037de:	6a02                	ld	s4,0(sp)
    800037e0:	6145                	addi	sp,sp,48
    800037e2:	8082                	ret

00000000800037e4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800037e4:	7179                	addi	sp,sp,-48
    800037e6:	f406                	sd	ra,40(sp)
    800037e8:	f022                	sd	s0,32(sp)
    800037ea:	ec26                	sd	s1,24(sp)
    800037ec:	e84a                	sd	s2,16(sp)
    800037ee:	e44e                	sd	s3,8(sp)
    800037f0:	1800                	addi	s0,sp,48
    800037f2:	892a                	mv	s2,a0
    800037f4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800037f6:	0023d517          	auipc	a0,0x23d
    800037fa:	05250513          	addi	a0,a0,82 # 80240848 <bcache>
    800037fe:	cb2fd0ef          	jal	ra,80000cb0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003802:	00245497          	auipc	s1,0x245
    80003806:	2fe4b483          	ld	s1,766(s1) # 80248b00 <bcache+0x82b8>
    8000380a:	00245797          	auipc	a5,0x245
    8000380e:	2a678793          	addi	a5,a5,678 # 80248ab0 <bcache+0x8268>
    80003812:	02f48b63          	beq	s1,a5,80003848 <bread+0x64>
    80003816:	873e                	mv	a4,a5
    80003818:	a021                	j	80003820 <bread+0x3c>
    8000381a:	68a4                	ld	s1,80(s1)
    8000381c:	02e48663          	beq	s1,a4,80003848 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003820:	449c                	lw	a5,8(s1)
    80003822:	ff279ce3          	bne	a5,s2,8000381a <bread+0x36>
    80003826:	44dc                	lw	a5,12(s1)
    80003828:	ff3799e3          	bne	a5,s3,8000381a <bread+0x36>
      b->refcnt++;
    8000382c:	40bc                	lw	a5,64(s1)
    8000382e:	2785                	addiw	a5,a5,1
    80003830:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003832:	0023d517          	auipc	a0,0x23d
    80003836:	01650513          	addi	a0,a0,22 # 80240848 <bcache>
    8000383a:	d0efd0ef          	jal	ra,80000d48 <release>
      acquiresleep(&b->lock);
    8000383e:	01048513          	addi	a0,s1,16
    80003842:	2b0010ef          	jal	ra,80004af2 <acquiresleep>
      return b;
    80003846:	a889                	j	80003898 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003848:	00245497          	auipc	s1,0x245
    8000384c:	2b04b483          	ld	s1,688(s1) # 80248af8 <bcache+0x82b0>
    80003850:	00245797          	auipc	a5,0x245
    80003854:	26078793          	addi	a5,a5,608 # 80248ab0 <bcache+0x8268>
    80003858:	00f48863          	beq	s1,a5,80003868 <bread+0x84>
    8000385c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000385e:	40bc                	lw	a5,64(s1)
    80003860:	cb91                	beqz	a5,80003874 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003862:	64a4                	ld	s1,72(s1)
    80003864:	fee49de3          	bne	s1,a4,8000385e <bread+0x7a>
  panic("bget: no buffers");
    80003868:	00005517          	auipc	a0,0x5
    8000386c:	c9050513          	addi	a0,a0,-880 # 800084f8 <syscalls+0x100>
    80003870:	f1bfc0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80003874:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003878:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000387c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003880:	4785                	li	a5,1
    80003882:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003884:	0023d517          	auipc	a0,0x23d
    80003888:	fc450513          	addi	a0,a0,-60 # 80240848 <bcache>
    8000388c:	cbcfd0ef          	jal	ra,80000d48 <release>
      acquiresleep(&b->lock);
    80003890:	01048513          	addi	a0,s1,16
    80003894:	25e010ef          	jal	ra,80004af2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003898:	409c                	lw	a5,0(s1)
    8000389a:	cb89                	beqz	a5,800038ac <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000389c:	8526                	mv	a0,s1
    8000389e:	70a2                	ld	ra,40(sp)
    800038a0:	7402                	ld	s0,32(sp)
    800038a2:	64e2                	ld	s1,24(sp)
    800038a4:	6942                	ld	s2,16(sp)
    800038a6:	69a2                	ld	s3,8(sp)
    800038a8:	6145                	addi	sp,sp,48
    800038aa:	8082                	ret
    virtio_disk_rw(b, 0);
    800038ac:	4581                	li	a1,0
    800038ae:	8526                	mv	a0,s1
    800038b0:	21d020ef          	jal	ra,800062cc <virtio_disk_rw>
    b->valid = 1;
    800038b4:	4785                	li	a5,1
    800038b6:	c09c                	sw	a5,0(s1)
  return b;
    800038b8:	b7d5                	j	8000389c <bread+0xb8>

00000000800038ba <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800038ba:	1101                	addi	sp,sp,-32
    800038bc:	ec06                	sd	ra,24(sp)
    800038be:	e822                	sd	s0,16(sp)
    800038c0:	e426                	sd	s1,8(sp)
    800038c2:	1000                	addi	s0,sp,32
    800038c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038c6:	0541                	addi	a0,a0,16
    800038c8:	2a8010ef          	jal	ra,80004b70 <holdingsleep>
    800038cc:	c911                	beqz	a0,800038e0 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800038ce:	4585                	li	a1,1
    800038d0:	8526                	mv	a0,s1
    800038d2:	1fb020ef          	jal	ra,800062cc <virtio_disk_rw>
}
    800038d6:	60e2                	ld	ra,24(sp)
    800038d8:	6442                	ld	s0,16(sp)
    800038da:	64a2                	ld	s1,8(sp)
    800038dc:	6105                	addi	sp,sp,32
    800038de:	8082                	ret
    panic("bwrite");
    800038e0:	00005517          	auipc	a0,0x5
    800038e4:	c3050513          	addi	a0,a0,-976 # 80008510 <syscalls+0x118>
    800038e8:	ea3fc0ef          	jal	ra,8000078a <panic>

00000000800038ec <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800038ec:	1101                	addi	sp,sp,-32
    800038ee:	ec06                	sd	ra,24(sp)
    800038f0:	e822                	sd	s0,16(sp)
    800038f2:	e426                	sd	s1,8(sp)
    800038f4:	e04a                	sd	s2,0(sp)
    800038f6:	1000                	addi	s0,sp,32
    800038f8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038fa:	01050913          	addi	s2,a0,16
    800038fe:	854a                	mv	a0,s2
    80003900:	270010ef          	jal	ra,80004b70 <holdingsleep>
    80003904:	c13d                	beqz	a0,8000396a <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80003906:	854a                	mv	a0,s2
    80003908:	230010ef          	jal	ra,80004b38 <releasesleep>

  acquire(&bcache.lock);
    8000390c:	0023d517          	auipc	a0,0x23d
    80003910:	f3c50513          	addi	a0,a0,-196 # 80240848 <bcache>
    80003914:	b9cfd0ef          	jal	ra,80000cb0 <acquire>
  b->refcnt--;
    80003918:	40bc                	lw	a5,64(s1)
    8000391a:	37fd                	addiw	a5,a5,-1
    8000391c:	0007871b          	sext.w	a4,a5
    80003920:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003922:	eb05                	bnez	a4,80003952 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003924:	68bc                	ld	a5,80(s1)
    80003926:	64b8                	ld	a4,72(s1)
    80003928:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000392a:	64bc                	ld	a5,72(s1)
    8000392c:	68b8                	ld	a4,80(s1)
    8000392e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003930:	00245797          	auipc	a5,0x245
    80003934:	f1878793          	addi	a5,a5,-232 # 80248848 <bcache+0x8000>
    80003938:	2b87b703          	ld	a4,696(a5)
    8000393c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000393e:	00245717          	auipc	a4,0x245
    80003942:	17270713          	addi	a4,a4,370 # 80248ab0 <bcache+0x8268>
    80003946:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003948:	2b87b703          	ld	a4,696(a5)
    8000394c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000394e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003952:	0023d517          	auipc	a0,0x23d
    80003956:	ef650513          	addi	a0,a0,-266 # 80240848 <bcache>
    8000395a:	beefd0ef          	jal	ra,80000d48 <release>
}
    8000395e:	60e2                	ld	ra,24(sp)
    80003960:	6442                	ld	s0,16(sp)
    80003962:	64a2                	ld	s1,8(sp)
    80003964:	6902                	ld	s2,0(sp)
    80003966:	6105                	addi	sp,sp,32
    80003968:	8082                	ret
    panic("brelse");
    8000396a:	00005517          	auipc	a0,0x5
    8000396e:	bae50513          	addi	a0,a0,-1106 # 80008518 <syscalls+0x120>
    80003972:	e19fc0ef          	jal	ra,8000078a <panic>

0000000080003976 <bpin>:

void
bpin(struct buf *b) {
    80003976:	1101                	addi	sp,sp,-32
    80003978:	ec06                	sd	ra,24(sp)
    8000397a:	e822                	sd	s0,16(sp)
    8000397c:	e426                	sd	s1,8(sp)
    8000397e:	1000                	addi	s0,sp,32
    80003980:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003982:	0023d517          	auipc	a0,0x23d
    80003986:	ec650513          	addi	a0,a0,-314 # 80240848 <bcache>
    8000398a:	b26fd0ef          	jal	ra,80000cb0 <acquire>
  b->refcnt++;
    8000398e:	40bc                	lw	a5,64(s1)
    80003990:	2785                	addiw	a5,a5,1
    80003992:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003994:	0023d517          	auipc	a0,0x23d
    80003998:	eb450513          	addi	a0,a0,-332 # 80240848 <bcache>
    8000399c:	bacfd0ef          	jal	ra,80000d48 <release>
}
    800039a0:	60e2                	ld	ra,24(sp)
    800039a2:	6442                	ld	s0,16(sp)
    800039a4:	64a2                	ld	s1,8(sp)
    800039a6:	6105                	addi	sp,sp,32
    800039a8:	8082                	ret

00000000800039aa <bunpin>:

void
bunpin(struct buf *b) {
    800039aa:	1101                	addi	sp,sp,-32
    800039ac:	ec06                	sd	ra,24(sp)
    800039ae:	e822                	sd	s0,16(sp)
    800039b0:	e426                	sd	s1,8(sp)
    800039b2:	1000                	addi	s0,sp,32
    800039b4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039b6:	0023d517          	auipc	a0,0x23d
    800039ba:	e9250513          	addi	a0,a0,-366 # 80240848 <bcache>
    800039be:	af2fd0ef          	jal	ra,80000cb0 <acquire>
  b->refcnt--;
    800039c2:	40bc                	lw	a5,64(s1)
    800039c4:	37fd                	addiw	a5,a5,-1
    800039c6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039c8:	0023d517          	auipc	a0,0x23d
    800039cc:	e8050513          	addi	a0,a0,-384 # 80240848 <bcache>
    800039d0:	b78fd0ef          	jal	ra,80000d48 <release>
}
    800039d4:	60e2                	ld	ra,24(sp)
    800039d6:	6442                	ld	s0,16(sp)
    800039d8:	64a2                	ld	s1,8(sp)
    800039da:	6105                	addi	sp,sp,32
    800039dc:	8082                	ret

00000000800039de <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800039de:	1101                	addi	sp,sp,-32
    800039e0:	ec06                	sd	ra,24(sp)
    800039e2:	e822                	sd	s0,16(sp)
    800039e4:	e426                	sd	s1,8(sp)
    800039e6:	e04a                	sd	s2,0(sp)
    800039e8:	1000                	addi	s0,sp,32
    800039ea:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800039ec:	00d5d59b          	srliw	a1,a1,0xd
    800039f0:	00245797          	auipc	a5,0x245
    800039f4:	5347a783          	lw	a5,1332(a5) # 80248f24 <sb+0x1c>
    800039f8:	9dbd                	addw	a1,a1,a5
    800039fa:	debff0ef          	jal	ra,800037e4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800039fe:	0074f713          	andi	a4,s1,7
    80003a02:	4785                	li	a5,1
    80003a04:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a08:	14ce                	slli	s1,s1,0x33
    80003a0a:	90d9                	srli	s1,s1,0x36
    80003a0c:	00950733          	add	a4,a0,s1
    80003a10:	05874703          	lbu	a4,88(a4)
    80003a14:	00e7f6b3          	and	a3,a5,a4
    80003a18:	c29d                	beqz	a3,80003a3e <bfree+0x60>
    80003a1a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a1c:	94aa                	add	s1,s1,a0
    80003a1e:	fff7c793          	not	a5,a5
    80003a22:	8ff9                	and	a5,a5,a4
    80003a24:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003a28:	7d1000ef          	jal	ra,800049f8 <log_write>
  brelse(bp);
    80003a2c:	854a                	mv	a0,s2
    80003a2e:	ebfff0ef          	jal	ra,800038ec <brelse>
}
    80003a32:	60e2                	ld	ra,24(sp)
    80003a34:	6442                	ld	s0,16(sp)
    80003a36:	64a2                	ld	s1,8(sp)
    80003a38:	6902                	ld	s2,0(sp)
    80003a3a:	6105                	addi	sp,sp,32
    80003a3c:	8082                	ret
    panic("freeing free block");
    80003a3e:	00005517          	auipc	a0,0x5
    80003a42:	ae250513          	addi	a0,a0,-1310 # 80008520 <syscalls+0x128>
    80003a46:	d45fc0ef          	jal	ra,8000078a <panic>

0000000080003a4a <balloc>:
{
    80003a4a:	711d                	addi	sp,sp,-96
    80003a4c:	ec86                	sd	ra,88(sp)
    80003a4e:	e8a2                	sd	s0,80(sp)
    80003a50:	e4a6                	sd	s1,72(sp)
    80003a52:	e0ca                	sd	s2,64(sp)
    80003a54:	fc4e                	sd	s3,56(sp)
    80003a56:	f852                	sd	s4,48(sp)
    80003a58:	f456                	sd	s5,40(sp)
    80003a5a:	f05a                	sd	s6,32(sp)
    80003a5c:	ec5e                	sd	s7,24(sp)
    80003a5e:	e862                	sd	s8,16(sp)
    80003a60:	e466                	sd	s9,8(sp)
    80003a62:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a64:	00245797          	auipc	a5,0x245
    80003a68:	4a87a783          	lw	a5,1192(a5) # 80248f0c <sb+0x4>
    80003a6c:	0e078163          	beqz	a5,80003b4e <balloc+0x104>
    80003a70:	8baa                	mv	s7,a0
    80003a72:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a74:	00245b17          	auipc	s6,0x245
    80003a78:	494b0b13          	addi	s6,s6,1172 # 80248f08 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a7c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a7e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a80:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a82:	6c89                	lui	s9,0x2
    80003a84:	a0b5                	j	80003af0 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a86:	974a                	add	a4,a4,s2
    80003a88:	8fd5                	or	a5,a5,a3
    80003a8a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003a8e:	854a                	mv	a0,s2
    80003a90:	769000ef          	jal	ra,800049f8 <log_write>
        brelse(bp);
    80003a94:	854a                	mv	a0,s2
    80003a96:	e57ff0ef          	jal	ra,800038ec <brelse>
  bp = bread(dev, bno);
    80003a9a:	85a6                	mv	a1,s1
    80003a9c:	855e                	mv	a0,s7
    80003a9e:	d47ff0ef          	jal	ra,800037e4 <bread>
    80003aa2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003aa4:	40000613          	li	a2,1024
    80003aa8:	4581                	li	a1,0
    80003aaa:	05850513          	addi	a0,a0,88
    80003aae:	ad6fd0ef          	jal	ra,80000d84 <memset>
  log_write(bp);
    80003ab2:	854a                	mv	a0,s2
    80003ab4:	745000ef          	jal	ra,800049f8 <log_write>
  brelse(bp);
    80003ab8:	854a                	mv	a0,s2
    80003aba:	e33ff0ef          	jal	ra,800038ec <brelse>
}
    80003abe:	8526                	mv	a0,s1
    80003ac0:	60e6                	ld	ra,88(sp)
    80003ac2:	6446                	ld	s0,80(sp)
    80003ac4:	64a6                	ld	s1,72(sp)
    80003ac6:	6906                	ld	s2,64(sp)
    80003ac8:	79e2                	ld	s3,56(sp)
    80003aca:	7a42                	ld	s4,48(sp)
    80003acc:	7aa2                	ld	s5,40(sp)
    80003ace:	7b02                	ld	s6,32(sp)
    80003ad0:	6be2                	ld	s7,24(sp)
    80003ad2:	6c42                	ld	s8,16(sp)
    80003ad4:	6ca2                	ld	s9,8(sp)
    80003ad6:	6125                	addi	sp,sp,96
    80003ad8:	8082                	ret
    brelse(bp);
    80003ada:	854a                	mv	a0,s2
    80003adc:	e11ff0ef          	jal	ra,800038ec <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003ae0:	015c87bb          	addw	a5,s9,s5
    80003ae4:	00078a9b          	sext.w	s5,a5
    80003ae8:	004b2703          	lw	a4,4(s6)
    80003aec:	06eaf163          	bgeu	s5,a4,80003b4e <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80003af0:	41fad79b          	sraiw	a5,s5,0x1f
    80003af4:	0137d79b          	srliw	a5,a5,0x13
    80003af8:	015787bb          	addw	a5,a5,s5
    80003afc:	40d7d79b          	sraiw	a5,a5,0xd
    80003b00:	01cb2583          	lw	a1,28(s6)
    80003b04:	9dbd                	addw	a1,a1,a5
    80003b06:	855e                	mv	a0,s7
    80003b08:	cddff0ef          	jal	ra,800037e4 <bread>
    80003b0c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b0e:	004b2503          	lw	a0,4(s6)
    80003b12:	000a849b          	sext.w	s1,s5
    80003b16:	8662                	mv	a2,s8
    80003b18:	fca4f1e3          	bgeu	s1,a0,80003ada <balloc+0x90>
      m = 1 << (bi % 8);
    80003b1c:	41f6579b          	sraiw	a5,a2,0x1f
    80003b20:	01d7d69b          	srliw	a3,a5,0x1d
    80003b24:	00c6873b          	addw	a4,a3,a2
    80003b28:	00777793          	andi	a5,a4,7
    80003b2c:	9f95                	subw	a5,a5,a3
    80003b2e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b32:	4037571b          	sraiw	a4,a4,0x3
    80003b36:	00e906b3          	add	a3,s2,a4
    80003b3a:	0586c683          	lbu	a3,88(a3)
    80003b3e:	00d7f5b3          	and	a1,a5,a3
    80003b42:	d1b1                	beqz	a1,80003a86 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b44:	2605                	addiw	a2,a2,1
    80003b46:	2485                	addiw	s1,s1,1
    80003b48:	fd4618e3          	bne	a2,s4,80003b18 <balloc+0xce>
    80003b4c:	b779                	j	80003ada <balloc+0x90>
  printf("balloc: out of blocks\n");
    80003b4e:	00005517          	auipc	a0,0x5
    80003b52:	9ea50513          	addi	a0,a0,-1558 # 80008538 <syscalls+0x140>
    80003b56:	96ffc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003b5a:	4481                	li	s1,0
    80003b5c:	b78d                	j	80003abe <balloc+0x74>

0000000080003b5e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b5e:	7179                	addi	sp,sp,-48
    80003b60:	f406                	sd	ra,40(sp)
    80003b62:	f022                	sd	s0,32(sp)
    80003b64:	ec26                	sd	s1,24(sp)
    80003b66:	e84a                	sd	s2,16(sp)
    80003b68:	e44e                	sd	s3,8(sp)
    80003b6a:	e052                	sd	s4,0(sp)
    80003b6c:	1800                	addi	s0,sp,48
    80003b6e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b70:	47ad                	li	a5,11
    80003b72:	02b7e563          	bltu	a5,a1,80003b9c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003b76:	02059493          	slli	s1,a1,0x20
    80003b7a:	9081                	srli	s1,s1,0x20
    80003b7c:	048a                	slli	s1,s1,0x2
    80003b7e:	94aa                	add	s1,s1,a0
    80003b80:	0504a903          	lw	s2,80(s1)
    80003b84:	06091663          	bnez	s2,80003bf0 <bmap+0x92>
      addr = balloc(ip->dev);
    80003b88:	4108                	lw	a0,0(a0)
    80003b8a:	ec1ff0ef          	jal	ra,80003a4a <balloc>
    80003b8e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b92:	04090f63          	beqz	s2,80003bf0 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80003b96:	0524a823          	sw	s2,80(s1)
    80003b9a:	a899                	j	80003bf0 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b9c:	ff45849b          	addiw	s1,a1,-12
    80003ba0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003ba4:	0ff00793          	li	a5,255
    80003ba8:	06e7eb63          	bltu	a5,a4,80003c1e <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003bac:	08052903          	lw	s2,128(a0)
    80003bb0:	00091b63          	bnez	s2,80003bc6 <bmap+0x68>
      addr = balloc(ip->dev);
    80003bb4:	4108                	lw	a0,0(a0)
    80003bb6:	e95ff0ef          	jal	ra,80003a4a <balloc>
    80003bba:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bbe:	02090963          	beqz	s2,80003bf0 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003bc2:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003bc6:	85ca                	mv	a1,s2
    80003bc8:	0009a503          	lw	a0,0(s3)
    80003bcc:	c19ff0ef          	jal	ra,800037e4 <bread>
    80003bd0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bd2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bd6:	02049593          	slli	a1,s1,0x20
    80003bda:	9181                	srli	a1,a1,0x20
    80003bdc:	058a                	slli	a1,a1,0x2
    80003bde:	00b784b3          	add	s1,a5,a1
    80003be2:	0004a903          	lw	s2,0(s1)
    80003be6:	00090e63          	beqz	s2,80003c02 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003bea:	8552                	mv	a0,s4
    80003bec:	d01ff0ef          	jal	ra,800038ec <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003bf0:	854a                	mv	a0,s2
    80003bf2:	70a2                	ld	ra,40(sp)
    80003bf4:	7402                	ld	s0,32(sp)
    80003bf6:	64e2                	ld	s1,24(sp)
    80003bf8:	6942                	ld	s2,16(sp)
    80003bfa:	69a2                	ld	s3,8(sp)
    80003bfc:	6a02                	ld	s4,0(sp)
    80003bfe:	6145                	addi	sp,sp,48
    80003c00:	8082                	ret
      addr = balloc(ip->dev);
    80003c02:	0009a503          	lw	a0,0(s3)
    80003c06:	e45ff0ef          	jal	ra,80003a4a <balloc>
    80003c0a:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c0e:	fc090ee3          	beqz	s2,80003bea <bmap+0x8c>
        a[bn] = addr;
    80003c12:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c16:	8552                	mv	a0,s4
    80003c18:	5e1000ef          	jal	ra,800049f8 <log_write>
    80003c1c:	b7f9                	j	80003bea <bmap+0x8c>
  panic("bmap: out of range");
    80003c1e:	00005517          	auipc	a0,0x5
    80003c22:	93250513          	addi	a0,a0,-1742 # 80008550 <syscalls+0x158>
    80003c26:	b65fc0ef          	jal	ra,8000078a <panic>

0000000080003c2a <iget>:
{
    80003c2a:	7179                	addi	sp,sp,-48
    80003c2c:	f406                	sd	ra,40(sp)
    80003c2e:	f022                	sd	s0,32(sp)
    80003c30:	ec26                	sd	s1,24(sp)
    80003c32:	e84a                	sd	s2,16(sp)
    80003c34:	e44e                	sd	s3,8(sp)
    80003c36:	e052                	sd	s4,0(sp)
    80003c38:	1800                	addi	s0,sp,48
    80003c3a:	89aa                	mv	s3,a0
    80003c3c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c3e:	00245517          	auipc	a0,0x245
    80003c42:	2ea50513          	addi	a0,a0,746 # 80248f28 <itable>
    80003c46:	86afd0ef          	jal	ra,80000cb0 <acquire>
  empty = 0;
    80003c4a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c4c:	00245497          	auipc	s1,0x245
    80003c50:	2f448493          	addi	s1,s1,756 # 80248f40 <itable+0x18>
    80003c54:	00247697          	auipc	a3,0x247
    80003c58:	d7c68693          	addi	a3,a3,-644 # 8024a9d0 <log>
    80003c5c:	a039                	j	80003c6a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c5e:	02090963          	beqz	s2,80003c90 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c62:	08848493          	addi	s1,s1,136
    80003c66:	02d48863          	beq	s1,a3,80003c96 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c6a:	449c                	lw	a5,8(s1)
    80003c6c:	fef059e3          	blez	a5,80003c5e <iget+0x34>
    80003c70:	4098                	lw	a4,0(s1)
    80003c72:	ff3716e3          	bne	a4,s3,80003c5e <iget+0x34>
    80003c76:	40d8                	lw	a4,4(s1)
    80003c78:	ff4713e3          	bne	a4,s4,80003c5e <iget+0x34>
      ip->ref++;
    80003c7c:	2785                	addiw	a5,a5,1
    80003c7e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c80:	00245517          	auipc	a0,0x245
    80003c84:	2a850513          	addi	a0,a0,680 # 80248f28 <itable>
    80003c88:	8c0fd0ef          	jal	ra,80000d48 <release>
      return ip;
    80003c8c:	8926                	mv	s2,s1
    80003c8e:	a02d                	j	80003cb8 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c90:	fbe9                	bnez	a5,80003c62 <iget+0x38>
    80003c92:	8926                	mv	s2,s1
    80003c94:	b7f9                	j	80003c62 <iget+0x38>
  if(empty == 0)
    80003c96:	02090a63          	beqz	s2,80003cca <iget+0xa0>
  ip->dev = dev;
    80003c9a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c9e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ca2:	4785                	li	a5,1
    80003ca4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ca8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003cac:	00245517          	auipc	a0,0x245
    80003cb0:	27c50513          	addi	a0,a0,636 # 80248f28 <itable>
    80003cb4:	894fd0ef          	jal	ra,80000d48 <release>
}
    80003cb8:	854a                	mv	a0,s2
    80003cba:	70a2                	ld	ra,40(sp)
    80003cbc:	7402                	ld	s0,32(sp)
    80003cbe:	64e2                	ld	s1,24(sp)
    80003cc0:	6942                	ld	s2,16(sp)
    80003cc2:	69a2                	ld	s3,8(sp)
    80003cc4:	6a02                	ld	s4,0(sp)
    80003cc6:	6145                	addi	sp,sp,48
    80003cc8:	8082                	ret
    panic("iget: no inodes");
    80003cca:	00005517          	auipc	a0,0x5
    80003cce:	89e50513          	addi	a0,a0,-1890 # 80008568 <syscalls+0x170>
    80003cd2:	ab9fc0ef          	jal	ra,8000078a <panic>

0000000080003cd6 <iinit>:
{
    80003cd6:	7179                	addi	sp,sp,-48
    80003cd8:	f406                	sd	ra,40(sp)
    80003cda:	f022                	sd	s0,32(sp)
    80003cdc:	ec26                	sd	s1,24(sp)
    80003cde:	e84a                	sd	s2,16(sp)
    80003ce0:	e44e                	sd	s3,8(sp)
    80003ce2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ce4:	00005597          	auipc	a1,0x5
    80003ce8:	89458593          	addi	a1,a1,-1900 # 80008578 <syscalls+0x180>
    80003cec:	00245517          	auipc	a0,0x245
    80003cf0:	23c50513          	addi	a0,a0,572 # 80248f28 <itable>
    80003cf4:	f3dfc0ef          	jal	ra,80000c30 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003cf8:	00245497          	auipc	s1,0x245
    80003cfc:	25848493          	addi	s1,s1,600 # 80248f50 <itable+0x28>
    80003d00:	00247997          	auipc	s3,0x247
    80003d04:	ce098993          	addi	s3,s3,-800 # 8024a9e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d08:	00005917          	auipc	s2,0x5
    80003d0c:	87890913          	addi	s2,s2,-1928 # 80008580 <syscalls+0x188>
    80003d10:	85ca                	mv	a1,s2
    80003d12:	8526                	mv	a0,s1
    80003d14:	5a9000ef          	jal	ra,80004abc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d18:	08848493          	addi	s1,s1,136
    80003d1c:	ff349ae3          	bne	s1,s3,80003d10 <iinit+0x3a>
}
    80003d20:	70a2                	ld	ra,40(sp)
    80003d22:	7402                	ld	s0,32(sp)
    80003d24:	64e2                	ld	s1,24(sp)
    80003d26:	6942                	ld	s2,16(sp)
    80003d28:	69a2                	ld	s3,8(sp)
    80003d2a:	6145                	addi	sp,sp,48
    80003d2c:	8082                	ret

0000000080003d2e <ialloc>:
{
    80003d2e:	715d                	addi	sp,sp,-80
    80003d30:	e486                	sd	ra,72(sp)
    80003d32:	e0a2                	sd	s0,64(sp)
    80003d34:	fc26                	sd	s1,56(sp)
    80003d36:	f84a                	sd	s2,48(sp)
    80003d38:	f44e                	sd	s3,40(sp)
    80003d3a:	f052                	sd	s4,32(sp)
    80003d3c:	ec56                	sd	s5,24(sp)
    80003d3e:	e85a                	sd	s6,16(sp)
    80003d40:	e45e                	sd	s7,8(sp)
    80003d42:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d44:	00245717          	auipc	a4,0x245
    80003d48:	1d072703          	lw	a4,464(a4) # 80248f14 <sb+0xc>
    80003d4c:	4785                	li	a5,1
    80003d4e:	04e7f663          	bgeu	a5,a4,80003d9a <ialloc+0x6c>
    80003d52:	8aaa                	mv	s5,a0
    80003d54:	8bae                	mv	s7,a1
    80003d56:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d58:	00245a17          	auipc	s4,0x245
    80003d5c:	1b0a0a13          	addi	s4,s4,432 # 80248f08 <sb>
    80003d60:	00048b1b          	sext.w	s6,s1
    80003d64:	0044d793          	srli	a5,s1,0x4
    80003d68:	018a2583          	lw	a1,24(s4)
    80003d6c:	9dbd                	addw	a1,a1,a5
    80003d6e:	8556                	mv	a0,s5
    80003d70:	a75ff0ef          	jal	ra,800037e4 <bread>
    80003d74:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d76:	05850993          	addi	s3,a0,88
    80003d7a:	00f4f793          	andi	a5,s1,15
    80003d7e:	079a                	slli	a5,a5,0x6
    80003d80:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d82:	00099783          	lh	a5,0(s3)
    80003d86:	cf85                	beqz	a5,80003dbe <ialloc+0x90>
    brelse(bp);
    80003d88:	b65ff0ef          	jal	ra,800038ec <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d8c:	0485                	addi	s1,s1,1
    80003d8e:	00ca2703          	lw	a4,12(s4)
    80003d92:	0004879b          	sext.w	a5,s1
    80003d96:	fce7e5e3          	bltu	a5,a4,80003d60 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d9a:	00004517          	auipc	a0,0x4
    80003d9e:	7ee50513          	addi	a0,a0,2030 # 80008588 <syscalls+0x190>
    80003da2:	f22fc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003da6:	4501                	li	a0,0
}
    80003da8:	60a6                	ld	ra,72(sp)
    80003daa:	6406                	ld	s0,64(sp)
    80003dac:	74e2                	ld	s1,56(sp)
    80003dae:	7942                	ld	s2,48(sp)
    80003db0:	79a2                	ld	s3,40(sp)
    80003db2:	7a02                	ld	s4,32(sp)
    80003db4:	6ae2                	ld	s5,24(sp)
    80003db6:	6b42                	ld	s6,16(sp)
    80003db8:	6ba2                	ld	s7,8(sp)
    80003dba:	6161                	addi	sp,sp,80
    80003dbc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003dbe:	04000613          	li	a2,64
    80003dc2:	4581                	li	a1,0
    80003dc4:	854e                	mv	a0,s3
    80003dc6:	fbffc0ef          	jal	ra,80000d84 <memset>
      dip->type = type;
    80003dca:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003dce:	854a                	mv	a0,s2
    80003dd0:	429000ef          	jal	ra,800049f8 <log_write>
      brelse(bp);
    80003dd4:	854a                	mv	a0,s2
    80003dd6:	b17ff0ef          	jal	ra,800038ec <brelse>
      return iget(dev, inum);
    80003dda:	85da                	mv	a1,s6
    80003ddc:	8556                	mv	a0,s5
    80003dde:	e4dff0ef          	jal	ra,80003c2a <iget>
    80003de2:	b7d9                	j	80003da8 <ialloc+0x7a>

0000000080003de4 <iupdate>:
{
    80003de4:	1101                	addi	sp,sp,-32
    80003de6:	ec06                	sd	ra,24(sp)
    80003de8:	e822                	sd	s0,16(sp)
    80003dea:	e426                	sd	s1,8(sp)
    80003dec:	e04a                	sd	s2,0(sp)
    80003dee:	1000                	addi	s0,sp,32
    80003df0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003df2:	415c                	lw	a5,4(a0)
    80003df4:	0047d79b          	srliw	a5,a5,0x4
    80003df8:	00245597          	auipc	a1,0x245
    80003dfc:	1285a583          	lw	a1,296(a1) # 80248f20 <sb+0x18>
    80003e00:	9dbd                	addw	a1,a1,a5
    80003e02:	4108                	lw	a0,0(a0)
    80003e04:	9e1ff0ef          	jal	ra,800037e4 <bread>
    80003e08:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e0a:	05850793          	addi	a5,a0,88
    80003e0e:	40c8                	lw	a0,4(s1)
    80003e10:	893d                	andi	a0,a0,15
    80003e12:	051a                	slli	a0,a0,0x6
    80003e14:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e16:	04449703          	lh	a4,68(s1)
    80003e1a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e1e:	04649703          	lh	a4,70(s1)
    80003e22:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e26:	04849703          	lh	a4,72(s1)
    80003e2a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e2e:	04a49703          	lh	a4,74(s1)
    80003e32:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e36:	44f8                	lw	a4,76(s1)
    80003e38:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e3a:	03400613          	li	a2,52
    80003e3e:	05048593          	addi	a1,s1,80
    80003e42:	0531                	addi	a0,a0,12
    80003e44:	f9dfc0ef          	jal	ra,80000de0 <memmove>
  log_write(bp);
    80003e48:	854a                	mv	a0,s2
    80003e4a:	3af000ef          	jal	ra,800049f8 <log_write>
  brelse(bp);
    80003e4e:	854a                	mv	a0,s2
    80003e50:	a9dff0ef          	jal	ra,800038ec <brelse>
}
    80003e54:	60e2                	ld	ra,24(sp)
    80003e56:	6442                	ld	s0,16(sp)
    80003e58:	64a2                	ld	s1,8(sp)
    80003e5a:	6902                	ld	s2,0(sp)
    80003e5c:	6105                	addi	sp,sp,32
    80003e5e:	8082                	ret

0000000080003e60 <idup>:
{
    80003e60:	1101                	addi	sp,sp,-32
    80003e62:	ec06                	sd	ra,24(sp)
    80003e64:	e822                	sd	s0,16(sp)
    80003e66:	e426                	sd	s1,8(sp)
    80003e68:	1000                	addi	s0,sp,32
    80003e6a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e6c:	00245517          	auipc	a0,0x245
    80003e70:	0bc50513          	addi	a0,a0,188 # 80248f28 <itable>
    80003e74:	e3dfc0ef          	jal	ra,80000cb0 <acquire>
  ip->ref++;
    80003e78:	449c                	lw	a5,8(s1)
    80003e7a:	2785                	addiw	a5,a5,1
    80003e7c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e7e:	00245517          	auipc	a0,0x245
    80003e82:	0aa50513          	addi	a0,a0,170 # 80248f28 <itable>
    80003e86:	ec3fc0ef          	jal	ra,80000d48 <release>
}
    80003e8a:	8526                	mv	a0,s1
    80003e8c:	60e2                	ld	ra,24(sp)
    80003e8e:	6442                	ld	s0,16(sp)
    80003e90:	64a2                	ld	s1,8(sp)
    80003e92:	6105                	addi	sp,sp,32
    80003e94:	8082                	ret

0000000080003e96 <ilock>:
{
    80003e96:	1101                	addi	sp,sp,-32
    80003e98:	ec06                	sd	ra,24(sp)
    80003e9a:	e822                	sd	s0,16(sp)
    80003e9c:	e426                	sd	s1,8(sp)
    80003e9e:	e04a                	sd	s2,0(sp)
    80003ea0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ea2:	c105                	beqz	a0,80003ec2 <ilock+0x2c>
    80003ea4:	84aa                	mv	s1,a0
    80003ea6:	451c                	lw	a5,8(a0)
    80003ea8:	00f05d63          	blez	a5,80003ec2 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003eac:	0541                	addi	a0,a0,16
    80003eae:	445000ef          	jal	ra,80004af2 <acquiresleep>
  if(ip->valid == 0){
    80003eb2:	40bc                	lw	a5,64(s1)
    80003eb4:	cf89                	beqz	a5,80003ece <ilock+0x38>
}
    80003eb6:	60e2                	ld	ra,24(sp)
    80003eb8:	6442                	ld	s0,16(sp)
    80003eba:	64a2                	ld	s1,8(sp)
    80003ebc:	6902                	ld	s2,0(sp)
    80003ebe:	6105                	addi	sp,sp,32
    80003ec0:	8082                	ret
    panic("ilock");
    80003ec2:	00004517          	auipc	a0,0x4
    80003ec6:	6de50513          	addi	a0,a0,1758 # 800085a0 <syscalls+0x1a8>
    80003eca:	8c1fc0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ece:	40dc                	lw	a5,4(s1)
    80003ed0:	0047d79b          	srliw	a5,a5,0x4
    80003ed4:	00245597          	auipc	a1,0x245
    80003ed8:	04c5a583          	lw	a1,76(a1) # 80248f20 <sb+0x18>
    80003edc:	9dbd                	addw	a1,a1,a5
    80003ede:	4088                	lw	a0,0(s1)
    80003ee0:	905ff0ef          	jal	ra,800037e4 <bread>
    80003ee4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ee6:	05850593          	addi	a1,a0,88
    80003eea:	40dc                	lw	a5,4(s1)
    80003eec:	8bbd                	andi	a5,a5,15
    80003eee:	079a                	slli	a5,a5,0x6
    80003ef0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ef2:	00059783          	lh	a5,0(a1)
    80003ef6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003efa:	00259783          	lh	a5,2(a1)
    80003efe:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f02:	00459783          	lh	a5,4(a1)
    80003f06:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f0a:	00659783          	lh	a5,6(a1)
    80003f0e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f12:	459c                	lw	a5,8(a1)
    80003f14:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f16:	03400613          	li	a2,52
    80003f1a:	05b1                	addi	a1,a1,12
    80003f1c:	05048513          	addi	a0,s1,80
    80003f20:	ec1fc0ef          	jal	ra,80000de0 <memmove>
    brelse(bp);
    80003f24:	854a                	mv	a0,s2
    80003f26:	9c7ff0ef          	jal	ra,800038ec <brelse>
    ip->valid = 1;
    80003f2a:	4785                	li	a5,1
    80003f2c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f2e:	04449783          	lh	a5,68(s1)
    80003f32:	f3d1                	bnez	a5,80003eb6 <ilock+0x20>
      panic("ilock: no type");
    80003f34:	00004517          	auipc	a0,0x4
    80003f38:	67450513          	addi	a0,a0,1652 # 800085a8 <syscalls+0x1b0>
    80003f3c:	84ffc0ef          	jal	ra,8000078a <panic>

0000000080003f40 <iunlock>:
{
    80003f40:	1101                	addi	sp,sp,-32
    80003f42:	ec06                	sd	ra,24(sp)
    80003f44:	e822                	sd	s0,16(sp)
    80003f46:	e426                	sd	s1,8(sp)
    80003f48:	e04a                	sd	s2,0(sp)
    80003f4a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f4c:	c505                	beqz	a0,80003f74 <iunlock+0x34>
    80003f4e:	84aa                	mv	s1,a0
    80003f50:	01050913          	addi	s2,a0,16
    80003f54:	854a                	mv	a0,s2
    80003f56:	41b000ef          	jal	ra,80004b70 <holdingsleep>
    80003f5a:	cd09                	beqz	a0,80003f74 <iunlock+0x34>
    80003f5c:	449c                	lw	a5,8(s1)
    80003f5e:	00f05b63          	blez	a5,80003f74 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003f62:	854a                	mv	a0,s2
    80003f64:	3d5000ef          	jal	ra,80004b38 <releasesleep>
}
    80003f68:	60e2                	ld	ra,24(sp)
    80003f6a:	6442                	ld	s0,16(sp)
    80003f6c:	64a2                	ld	s1,8(sp)
    80003f6e:	6902                	ld	s2,0(sp)
    80003f70:	6105                	addi	sp,sp,32
    80003f72:	8082                	ret
    panic("iunlock");
    80003f74:	00004517          	auipc	a0,0x4
    80003f78:	64450513          	addi	a0,a0,1604 # 800085b8 <syscalls+0x1c0>
    80003f7c:	80ffc0ef          	jal	ra,8000078a <panic>

0000000080003f80 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003f80:	7179                	addi	sp,sp,-48
    80003f82:	f406                	sd	ra,40(sp)
    80003f84:	f022                	sd	s0,32(sp)
    80003f86:	ec26                	sd	s1,24(sp)
    80003f88:	e84a                	sd	s2,16(sp)
    80003f8a:	e44e                	sd	s3,8(sp)
    80003f8c:	e052                	sd	s4,0(sp)
    80003f8e:	1800                	addi	s0,sp,48
    80003f90:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f92:	05050493          	addi	s1,a0,80
    80003f96:	08050913          	addi	s2,a0,128
    80003f9a:	a021                	j	80003fa2 <itrunc+0x22>
    80003f9c:	0491                	addi	s1,s1,4
    80003f9e:	01248b63          	beq	s1,s2,80003fb4 <itrunc+0x34>
    if(ip->addrs[i]){
    80003fa2:	408c                	lw	a1,0(s1)
    80003fa4:	dde5                	beqz	a1,80003f9c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fa6:	0009a503          	lw	a0,0(s3)
    80003faa:	a35ff0ef          	jal	ra,800039de <bfree>
      ip->addrs[i] = 0;
    80003fae:	0004a023          	sw	zero,0(s1)
    80003fb2:	b7ed                	j	80003f9c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003fb4:	0809a583          	lw	a1,128(s3)
    80003fb8:	ed91                	bnez	a1,80003fd4 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fba:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003fbe:	854e                	mv	a0,s3
    80003fc0:	e25ff0ef          	jal	ra,80003de4 <iupdate>
}
    80003fc4:	70a2                	ld	ra,40(sp)
    80003fc6:	7402                	ld	s0,32(sp)
    80003fc8:	64e2                	ld	s1,24(sp)
    80003fca:	6942                	ld	s2,16(sp)
    80003fcc:	69a2                	ld	s3,8(sp)
    80003fce:	6a02                	ld	s4,0(sp)
    80003fd0:	6145                	addi	sp,sp,48
    80003fd2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003fd4:	0009a503          	lw	a0,0(s3)
    80003fd8:	80dff0ef          	jal	ra,800037e4 <bread>
    80003fdc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003fde:	05850493          	addi	s1,a0,88
    80003fe2:	45850913          	addi	s2,a0,1112
    80003fe6:	a021                	j	80003fee <itrunc+0x6e>
    80003fe8:	0491                	addi	s1,s1,4
    80003fea:	01248963          	beq	s1,s2,80003ffc <itrunc+0x7c>
      if(a[j])
    80003fee:	408c                	lw	a1,0(s1)
    80003ff0:	dde5                	beqz	a1,80003fe8 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003ff2:	0009a503          	lw	a0,0(s3)
    80003ff6:	9e9ff0ef          	jal	ra,800039de <bfree>
    80003ffa:	b7fd                	j	80003fe8 <itrunc+0x68>
    brelse(bp);
    80003ffc:	8552                	mv	a0,s4
    80003ffe:	8efff0ef          	jal	ra,800038ec <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004002:	0809a583          	lw	a1,128(s3)
    80004006:	0009a503          	lw	a0,0(s3)
    8000400a:	9d5ff0ef          	jal	ra,800039de <bfree>
    ip->addrs[NDIRECT] = 0;
    8000400e:	0809a023          	sw	zero,128(s3)
    80004012:	b765                	j	80003fba <itrunc+0x3a>

0000000080004014 <iput>:
{
    80004014:	1101                	addi	sp,sp,-32
    80004016:	ec06                	sd	ra,24(sp)
    80004018:	e822                	sd	s0,16(sp)
    8000401a:	e426                	sd	s1,8(sp)
    8000401c:	e04a                	sd	s2,0(sp)
    8000401e:	1000                	addi	s0,sp,32
    80004020:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004022:	00245517          	auipc	a0,0x245
    80004026:	f0650513          	addi	a0,a0,-250 # 80248f28 <itable>
    8000402a:	c87fc0ef          	jal	ra,80000cb0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000402e:	4498                	lw	a4,8(s1)
    80004030:	4785                	li	a5,1
    80004032:	02f70163          	beq	a4,a5,80004054 <iput+0x40>
  ip->ref--;
    80004036:	449c                	lw	a5,8(s1)
    80004038:	37fd                	addiw	a5,a5,-1
    8000403a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000403c:	00245517          	auipc	a0,0x245
    80004040:	eec50513          	addi	a0,a0,-276 # 80248f28 <itable>
    80004044:	d05fc0ef          	jal	ra,80000d48 <release>
}
    80004048:	60e2                	ld	ra,24(sp)
    8000404a:	6442                	ld	s0,16(sp)
    8000404c:	64a2                	ld	s1,8(sp)
    8000404e:	6902                	ld	s2,0(sp)
    80004050:	6105                	addi	sp,sp,32
    80004052:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004054:	40bc                	lw	a5,64(s1)
    80004056:	d3e5                	beqz	a5,80004036 <iput+0x22>
    80004058:	04a49783          	lh	a5,74(s1)
    8000405c:	ffe9                	bnez	a5,80004036 <iput+0x22>
    acquiresleep(&ip->lock);
    8000405e:	01048913          	addi	s2,s1,16
    80004062:	854a                	mv	a0,s2
    80004064:	28f000ef          	jal	ra,80004af2 <acquiresleep>
    release(&itable.lock);
    80004068:	00245517          	auipc	a0,0x245
    8000406c:	ec050513          	addi	a0,a0,-320 # 80248f28 <itable>
    80004070:	cd9fc0ef          	jal	ra,80000d48 <release>
    itrunc(ip);
    80004074:	8526                	mv	a0,s1
    80004076:	f0bff0ef          	jal	ra,80003f80 <itrunc>
    ip->type = 0;
    8000407a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000407e:	8526                	mv	a0,s1
    80004080:	d65ff0ef          	jal	ra,80003de4 <iupdate>
    ip->valid = 0;
    80004084:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004088:	854a                	mv	a0,s2
    8000408a:	2af000ef          	jal	ra,80004b38 <releasesleep>
    acquire(&itable.lock);
    8000408e:	00245517          	auipc	a0,0x245
    80004092:	e9a50513          	addi	a0,a0,-358 # 80248f28 <itable>
    80004096:	c1bfc0ef          	jal	ra,80000cb0 <acquire>
    8000409a:	bf71                	j	80004036 <iput+0x22>

000000008000409c <iunlockput>:
{
    8000409c:	1101                	addi	sp,sp,-32
    8000409e:	ec06                	sd	ra,24(sp)
    800040a0:	e822                	sd	s0,16(sp)
    800040a2:	e426                	sd	s1,8(sp)
    800040a4:	1000                	addi	s0,sp,32
    800040a6:	84aa                	mv	s1,a0
  iunlock(ip);
    800040a8:	e99ff0ef          	jal	ra,80003f40 <iunlock>
  iput(ip);
    800040ac:	8526                	mv	a0,s1
    800040ae:	f67ff0ef          	jal	ra,80004014 <iput>
}
    800040b2:	60e2                	ld	ra,24(sp)
    800040b4:	6442                	ld	s0,16(sp)
    800040b6:	64a2                	ld	s1,8(sp)
    800040b8:	6105                	addi	sp,sp,32
    800040ba:	8082                	ret

00000000800040bc <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800040bc:	00245717          	auipc	a4,0x245
    800040c0:	e5872703          	lw	a4,-424(a4) # 80248f14 <sb+0xc>
    800040c4:	4785                	li	a5,1
    800040c6:	0ae7ff63          	bgeu	a5,a4,80004184 <ireclaim+0xc8>
{
    800040ca:	7139                	addi	sp,sp,-64
    800040cc:	fc06                	sd	ra,56(sp)
    800040ce:	f822                	sd	s0,48(sp)
    800040d0:	f426                	sd	s1,40(sp)
    800040d2:	f04a                	sd	s2,32(sp)
    800040d4:	ec4e                	sd	s3,24(sp)
    800040d6:	e852                	sd	s4,16(sp)
    800040d8:	e456                	sd	s5,8(sp)
    800040da:	e05a                	sd	s6,0(sp)
    800040dc:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800040de:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800040e0:	00050a1b          	sext.w	s4,a0
    800040e4:	00245a97          	auipc	s5,0x245
    800040e8:	e24a8a93          	addi	s5,s5,-476 # 80248f08 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800040ec:	00004b17          	auipc	s6,0x4
    800040f0:	4d4b0b13          	addi	s6,s6,1236 # 800085c0 <syscalls+0x1c8>
    800040f4:	a099                	j	8000413a <ireclaim+0x7e>
    800040f6:	85ce                	mv	a1,s3
    800040f8:	855a                	mv	a0,s6
    800040fa:	bcafc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    800040fe:	85ce                	mv	a1,s3
    80004100:	8552                	mv	a0,s4
    80004102:	b29ff0ef          	jal	ra,80003c2a <iget>
    80004106:	89aa                	mv	s3,a0
    brelse(bp);
    80004108:	854a                	mv	a0,s2
    8000410a:	fe2ff0ef          	jal	ra,800038ec <brelse>
    if (ip) {
    8000410e:	00098f63          	beqz	s3,8000412c <ireclaim+0x70>
      begin_op();
    80004112:	762000ef          	jal	ra,80004874 <begin_op>
      ilock(ip);
    80004116:	854e                	mv	a0,s3
    80004118:	d7fff0ef          	jal	ra,80003e96 <ilock>
      iunlock(ip);
    8000411c:	854e                	mv	a0,s3
    8000411e:	e23ff0ef          	jal	ra,80003f40 <iunlock>
      iput(ip);
    80004122:	854e                	mv	a0,s3
    80004124:	ef1ff0ef          	jal	ra,80004014 <iput>
      end_op();
    80004128:	7bc000ef          	jal	ra,800048e4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000412c:	0485                	addi	s1,s1,1
    8000412e:	00caa703          	lw	a4,12(s5)
    80004132:	0004879b          	sext.w	a5,s1
    80004136:	02e7fd63          	bgeu	a5,a4,80004170 <ireclaim+0xb4>
    8000413a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000413e:	0044d793          	srli	a5,s1,0x4
    80004142:	018aa583          	lw	a1,24(s5)
    80004146:	9dbd                	addw	a1,a1,a5
    80004148:	8552                	mv	a0,s4
    8000414a:	e9aff0ef          	jal	ra,800037e4 <bread>
    8000414e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80004150:	05850793          	addi	a5,a0,88
    80004154:	00f9f713          	andi	a4,s3,15
    80004158:	071a                	slli	a4,a4,0x6
    8000415a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000415c:	00079703          	lh	a4,0(a5)
    80004160:	c701                	beqz	a4,80004168 <ireclaim+0xac>
    80004162:	00679783          	lh	a5,6(a5)
    80004166:	dbc1                	beqz	a5,800040f6 <ireclaim+0x3a>
    brelse(bp);
    80004168:	854a                	mv	a0,s2
    8000416a:	f82ff0ef          	jal	ra,800038ec <brelse>
    if (ip) {
    8000416e:	bf7d                	j	8000412c <ireclaim+0x70>
}
    80004170:	70e2                	ld	ra,56(sp)
    80004172:	7442                	ld	s0,48(sp)
    80004174:	74a2                	ld	s1,40(sp)
    80004176:	7902                	ld	s2,32(sp)
    80004178:	69e2                	ld	s3,24(sp)
    8000417a:	6a42                	ld	s4,16(sp)
    8000417c:	6aa2                	ld	s5,8(sp)
    8000417e:	6b02                	ld	s6,0(sp)
    80004180:	6121                	addi	sp,sp,64
    80004182:	8082                	ret
    80004184:	8082                	ret

0000000080004186 <fsinit>:
fsinit(int dev) {
    80004186:	7179                	addi	sp,sp,-48
    80004188:	f406                	sd	ra,40(sp)
    8000418a:	f022                	sd	s0,32(sp)
    8000418c:	ec26                	sd	s1,24(sp)
    8000418e:	e84a                	sd	s2,16(sp)
    80004190:	e44e                	sd	s3,8(sp)
    80004192:	1800                	addi	s0,sp,48
    80004194:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80004196:	4585                	li	a1,1
    80004198:	e4cff0ef          	jal	ra,800037e4 <bread>
    8000419c:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000419e:	00245997          	auipc	s3,0x245
    800041a2:	d6a98993          	addi	s3,s3,-662 # 80248f08 <sb>
    800041a6:	02000613          	li	a2,32
    800041aa:	05850593          	addi	a1,a0,88
    800041ae:	854e                	mv	a0,s3
    800041b0:	c31fc0ef          	jal	ra,80000de0 <memmove>
  brelse(bp);
    800041b4:	854a                	mv	a0,s2
    800041b6:	f36ff0ef          	jal	ra,800038ec <brelse>
  if(sb.magic != FSMAGIC)
    800041ba:	0009a703          	lw	a4,0(s3)
    800041be:	102037b7          	lui	a5,0x10203
    800041c2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800041c6:	02f71363          	bne	a4,a5,800041ec <fsinit+0x66>
  initlog(dev, &sb);
    800041ca:	00245597          	auipc	a1,0x245
    800041ce:	d3e58593          	addi	a1,a1,-706 # 80248f08 <sb>
    800041d2:	8526                	mv	a0,s1
    800041d4:	616000ef          	jal	ra,800047ea <initlog>
  ireclaim(dev);
    800041d8:	8526                	mv	a0,s1
    800041da:	ee3ff0ef          	jal	ra,800040bc <ireclaim>
}
    800041de:	70a2                	ld	ra,40(sp)
    800041e0:	7402                	ld	s0,32(sp)
    800041e2:	64e2                	ld	s1,24(sp)
    800041e4:	6942                	ld	s2,16(sp)
    800041e6:	69a2                	ld	s3,8(sp)
    800041e8:	6145                	addi	sp,sp,48
    800041ea:	8082                	ret
    panic("invalid file system");
    800041ec:	00004517          	auipc	a0,0x4
    800041f0:	3f450513          	addi	a0,a0,1012 # 800085e0 <syscalls+0x1e8>
    800041f4:	d96fc0ef          	jal	ra,8000078a <panic>

00000000800041f8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041f8:	1141                	addi	sp,sp,-16
    800041fa:	e422                	sd	s0,8(sp)
    800041fc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041fe:	411c                	lw	a5,0(a0)
    80004200:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004202:	415c                	lw	a5,4(a0)
    80004204:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004206:	04451783          	lh	a5,68(a0)
    8000420a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000420e:	04a51783          	lh	a5,74(a0)
    80004212:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004216:	04c56783          	lwu	a5,76(a0)
    8000421a:	e99c                	sd	a5,16(a1)
}
    8000421c:	6422                	ld	s0,8(sp)
    8000421e:	0141                	addi	sp,sp,16
    80004220:	8082                	ret

0000000080004222 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004222:	457c                	lw	a5,76(a0)
    80004224:	0cd7ef63          	bltu	a5,a3,80004302 <readi+0xe0>
{
    80004228:	7159                	addi	sp,sp,-112
    8000422a:	f486                	sd	ra,104(sp)
    8000422c:	f0a2                	sd	s0,96(sp)
    8000422e:	eca6                	sd	s1,88(sp)
    80004230:	e8ca                	sd	s2,80(sp)
    80004232:	e4ce                	sd	s3,72(sp)
    80004234:	e0d2                	sd	s4,64(sp)
    80004236:	fc56                	sd	s5,56(sp)
    80004238:	f85a                	sd	s6,48(sp)
    8000423a:	f45e                	sd	s7,40(sp)
    8000423c:	f062                	sd	s8,32(sp)
    8000423e:	ec66                	sd	s9,24(sp)
    80004240:	e86a                	sd	s10,16(sp)
    80004242:	e46e                	sd	s11,8(sp)
    80004244:	1880                	addi	s0,sp,112
    80004246:	8b2a                	mv	s6,a0
    80004248:	8bae                	mv	s7,a1
    8000424a:	8a32                	mv	s4,a2
    8000424c:	84b6                	mv	s1,a3
    8000424e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004250:	9f35                	addw	a4,a4,a3
    return 0;
    80004252:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004254:	08d76663          	bltu	a4,a3,800042e0 <readi+0xbe>
  if(off + n > ip->size)
    80004258:	00e7f463          	bgeu	a5,a4,80004260 <readi+0x3e>
    n = ip->size - off;
    8000425c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004260:	080a8f63          	beqz	s5,800042fe <readi+0xdc>
    80004264:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004266:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000426a:	5c7d                	li	s8,-1
    8000426c:	a80d                	j	8000429e <readi+0x7c>
    8000426e:	020d1d93          	slli	s11,s10,0x20
    80004272:	020ddd93          	srli	s11,s11,0x20
    80004276:	05890793          	addi	a5,s2,88
    8000427a:	86ee                	mv	a3,s11
    8000427c:	963e                	add	a2,a2,a5
    8000427e:	85d2                	mv	a1,s4
    80004280:	855e                	mv	a0,s7
    80004282:	d6cfe0ef          	jal	ra,800027ee <either_copyout>
    80004286:	05850763          	beq	a0,s8,800042d4 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000428a:	854a                	mv	a0,s2
    8000428c:	e60ff0ef          	jal	ra,800038ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004290:	013d09bb          	addw	s3,s10,s3
    80004294:	009d04bb          	addw	s1,s10,s1
    80004298:	9a6e                	add	s4,s4,s11
    8000429a:	0559f163          	bgeu	s3,s5,800042dc <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    8000429e:	00a4d59b          	srliw	a1,s1,0xa
    800042a2:	855a                	mv	a0,s6
    800042a4:	8bbff0ef          	jal	ra,80003b5e <bmap>
    800042a8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042ac:	c985                	beqz	a1,800042dc <readi+0xba>
    bp = bread(ip->dev, addr);
    800042ae:	000b2503          	lw	a0,0(s6)
    800042b2:	d32ff0ef          	jal	ra,800037e4 <bread>
    800042b6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042b8:	3ff4f613          	andi	a2,s1,1023
    800042bc:	40cc87bb          	subw	a5,s9,a2
    800042c0:	413a873b          	subw	a4,s5,s3
    800042c4:	8d3e                	mv	s10,a5
    800042c6:	2781                	sext.w	a5,a5
    800042c8:	0007069b          	sext.w	a3,a4
    800042cc:	faf6f1e3          	bgeu	a3,a5,8000426e <readi+0x4c>
    800042d0:	8d3a                	mv	s10,a4
    800042d2:	bf71                	j	8000426e <readi+0x4c>
      brelse(bp);
    800042d4:	854a                	mv	a0,s2
    800042d6:	e16ff0ef          	jal	ra,800038ec <brelse>
      tot = -1;
    800042da:	59fd                	li	s3,-1
  }
  return tot;
    800042dc:	0009851b          	sext.w	a0,s3
}
    800042e0:	70a6                	ld	ra,104(sp)
    800042e2:	7406                	ld	s0,96(sp)
    800042e4:	64e6                	ld	s1,88(sp)
    800042e6:	6946                	ld	s2,80(sp)
    800042e8:	69a6                	ld	s3,72(sp)
    800042ea:	6a06                	ld	s4,64(sp)
    800042ec:	7ae2                	ld	s5,56(sp)
    800042ee:	7b42                	ld	s6,48(sp)
    800042f0:	7ba2                	ld	s7,40(sp)
    800042f2:	7c02                	ld	s8,32(sp)
    800042f4:	6ce2                	ld	s9,24(sp)
    800042f6:	6d42                	ld	s10,16(sp)
    800042f8:	6da2                	ld	s11,8(sp)
    800042fa:	6165                	addi	sp,sp,112
    800042fc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042fe:	89d6                	mv	s3,s5
    80004300:	bff1                	j	800042dc <readi+0xba>
    return 0;
    80004302:	4501                	li	a0,0
}
    80004304:	8082                	ret

0000000080004306 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004306:	457c                	lw	a5,76(a0)
    80004308:	0ed7ea63          	bltu	a5,a3,800043fc <writei+0xf6>
{
    8000430c:	7159                	addi	sp,sp,-112
    8000430e:	f486                	sd	ra,104(sp)
    80004310:	f0a2                	sd	s0,96(sp)
    80004312:	eca6                	sd	s1,88(sp)
    80004314:	e8ca                	sd	s2,80(sp)
    80004316:	e4ce                	sd	s3,72(sp)
    80004318:	e0d2                	sd	s4,64(sp)
    8000431a:	fc56                	sd	s5,56(sp)
    8000431c:	f85a                	sd	s6,48(sp)
    8000431e:	f45e                	sd	s7,40(sp)
    80004320:	f062                	sd	s8,32(sp)
    80004322:	ec66                	sd	s9,24(sp)
    80004324:	e86a                	sd	s10,16(sp)
    80004326:	e46e                	sd	s11,8(sp)
    80004328:	1880                	addi	s0,sp,112
    8000432a:	8aaa                	mv	s5,a0
    8000432c:	8bae                	mv	s7,a1
    8000432e:	8a32                	mv	s4,a2
    80004330:	8936                	mv	s2,a3
    80004332:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004334:	00e687bb          	addw	a5,a3,a4
    80004338:	0cd7e463          	bltu	a5,a3,80004400 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000433c:	00043737          	lui	a4,0x43
    80004340:	0cf76263          	bltu	a4,a5,80004404 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004344:	0a0b0a63          	beqz	s6,800043f8 <writei+0xf2>
    80004348:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000434a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000434e:	5c7d                	li	s8,-1
    80004350:	a825                	j	80004388 <writei+0x82>
    80004352:	020d1d93          	slli	s11,s10,0x20
    80004356:	020ddd93          	srli	s11,s11,0x20
    8000435a:	05848793          	addi	a5,s1,88
    8000435e:	86ee                	mv	a3,s11
    80004360:	8652                	mv	a2,s4
    80004362:	85de                	mv	a1,s7
    80004364:	953e                	add	a0,a0,a5
    80004366:	cd2fe0ef          	jal	ra,80002838 <either_copyin>
    8000436a:	05850a63          	beq	a0,s8,800043be <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000436e:	8526                	mv	a0,s1
    80004370:	688000ef          	jal	ra,800049f8 <log_write>
    brelse(bp);
    80004374:	8526                	mv	a0,s1
    80004376:	d76ff0ef          	jal	ra,800038ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000437a:	013d09bb          	addw	s3,s10,s3
    8000437e:	012d093b          	addw	s2,s10,s2
    80004382:	9a6e                	add	s4,s4,s11
    80004384:	0569f063          	bgeu	s3,s6,800043c4 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004388:	00a9559b          	srliw	a1,s2,0xa
    8000438c:	8556                	mv	a0,s5
    8000438e:	fd0ff0ef          	jal	ra,80003b5e <bmap>
    80004392:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004396:	c59d                	beqz	a1,800043c4 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004398:	000aa503          	lw	a0,0(s5)
    8000439c:	c48ff0ef          	jal	ra,800037e4 <bread>
    800043a0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043a2:	3ff97513          	andi	a0,s2,1023
    800043a6:	40ac87bb          	subw	a5,s9,a0
    800043aa:	413b073b          	subw	a4,s6,s3
    800043ae:	8d3e                	mv	s10,a5
    800043b0:	2781                	sext.w	a5,a5
    800043b2:	0007069b          	sext.w	a3,a4
    800043b6:	f8f6fee3          	bgeu	a3,a5,80004352 <writei+0x4c>
    800043ba:	8d3a                	mv	s10,a4
    800043bc:	bf59                	j	80004352 <writei+0x4c>
      brelse(bp);
    800043be:	8526                	mv	a0,s1
    800043c0:	d2cff0ef          	jal	ra,800038ec <brelse>
  }

  if(off > ip->size)
    800043c4:	04caa783          	lw	a5,76(s5)
    800043c8:	0127f463          	bgeu	a5,s2,800043d0 <writei+0xca>
    ip->size = off;
    800043cc:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043d0:	8556                	mv	a0,s5
    800043d2:	a13ff0ef          	jal	ra,80003de4 <iupdate>

  return tot;
    800043d6:	0009851b          	sext.w	a0,s3
}
    800043da:	70a6                	ld	ra,104(sp)
    800043dc:	7406                	ld	s0,96(sp)
    800043de:	64e6                	ld	s1,88(sp)
    800043e0:	6946                	ld	s2,80(sp)
    800043e2:	69a6                	ld	s3,72(sp)
    800043e4:	6a06                	ld	s4,64(sp)
    800043e6:	7ae2                	ld	s5,56(sp)
    800043e8:	7b42                	ld	s6,48(sp)
    800043ea:	7ba2                	ld	s7,40(sp)
    800043ec:	7c02                	ld	s8,32(sp)
    800043ee:	6ce2                	ld	s9,24(sp)
    800043f0:	6d42                	ld	s10,16(sp)
    800043f2:	6da2                	ld	s11,8(sp)
    800043f4:	6165                	addi	sp,sp,112
    800043f6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043f8:	89da                	mv	s3,s6
    800043fa:	bfd9                	j	800043d0 <writei+0xca>
    return -1;
    800043fc:	557d                	li	a0,-1
}
    800043fe:	8082                	ret
    return -1;
    80004400:	557d                	li	a0,-1
    80004402:	bfe1                	j	800043da <writei+0xd4>
    return -1;
    80004404:	557d                	li	a0,-1
    80004406:	bfd1                	j	800043da <writei+0xd4>

0000000080004408 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004408:	1141                	addi	sp,sp,-16
    8000440a:	e406                	sd	ra,8(sp)
    8000440c:	e022                	sd	s0,0(sp)
    8000440e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004410:	4639                	li	a2,14
    80004412:	a3ffc0ef          	jal	ra,80000e50 <strncmp>
}
    80004416:	60a2                	ld	ra,8(sp)
    80004418:	6402                	ld	s0,0(sp)
    8000441a:	0141                	addi	sp,sp,16
    8000441c:	8082                	ret

000000008000441e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000441e:	7139                	addi	sp,sp,-64
    80004420:	fc06                	sd	ra,56(sp)
    80004422:	f822                	sd	s0,48(sp)
    80004424:	f426                	sd	s1,40(sp)
    80004426:	f04a                	sd	s2,32(sp)
    80004428:	ec4e                	sd	s3,24(sp)
    8000442a:	e852                	sd	s4,16(sp)
    8000442c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000442e:	04451703          	lh	a4,68(a0)
    80004432:	4785                	li	a5,1
    80004434:	00f71a63          	bne	a4,a5,80004448 <dirlookup+0x2a>
    80004438:	892a                	mv	s2,a0
    8000443a:	89ae                	mv	s3,a1
    8000443c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000443e:	457c                	lw	a5,76(a0)
    80004440:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004442:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004444:	e39d                	bnez	a5,8000446a <dirlookup+0x4c>
    80004446:	a095                	j	800044aa <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004448:	00004517          	auipc	a0,0x4
    8000444c:	1b050513          	addi	a0,a0,432 # 800085f8 <syscalls+0x200>
    80004450:	b3afc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    80004454:	00004517          	auipc	a0,0x4
    80004458:	1bc50513          	addi	a0,a0,444 # 80008610 <syscalls+0x218>
    8000445c:	b2efc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004460:	24c1                	addiw	s1,s1,16
    80004462:	04c92783          	lw	a5,76(s2)
    80004466:	04f4f163          	bgeu	s1,a5,800044a8 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000446a:	4741                	li	a4,16
    8000446c:	86a6                	mv	a3,s1
    8000446e:	fc040613          	addi	a2,s0,-64
    80004472:	4581                	li	a1,0
    80004474:	854a                	mv	a0,s2
    80004476:	dadff0ef          	jal	ra,80004222 <readi>
    8000447a:	47c1                	li	a5,16
    8000447c:	fcf51ce3          	bne	a0,a5,80004454 <dirlookup+0x36>
    if(de.inum == 0)
    80004480:	fc045783          	lhu	a5,-64(s0)
    80004484:	dff1                	beqz	a5,80004460 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80004486:	fc240593          	addi	a1,s0,-62
    8000448a:	854e                	mv	a0,s3
    8000448c:	f7dff0ef          	jal	ra,80004408 <namecmp>
    80004490:	f961                	bnez	a0,80004460 <dirlookup+0x42>
      if(poff)
    80004492:	000a0463          	beqz	s4,8000449a <dirlookup+0x7c>
        *poff = off;
    80004496:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000449a:	fc045583          	lhu	a1,-64(s0)
    8000449e:	00092503          	lw	a0,0(s2)
    800044a2:	f88ff0ef          	jal	ra,80003c2a <iget>
    800044a6:	a011                	j	800044aa <dirlookup+0x8c>
  return 0;
    800044a8:	4501                	li	a0,0
}
    800044aa:	70e2                	ld	ra,56(sp)
    800044ac:	7442                	ld	s0,48(sp)
    800044ae:	74a2                	ld	s1,40(sp)
    800044b0:	7902                	ld	s2,32(sp)
    800044b2:	69e2                	ld	s3,24(sp)
    800044b4:	6a42                	ld	s4,16(sp)
    800044b6:	6121                	addi	sp,sp,64
    800044b8:	8082                	ret

00000000800044ba <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044ba:	711d                	addi	sp,sp,-96
    800044bc:	ec86                	sd	ra,88(sp)
    800044be:	e8a2                	sd	s0,80(sp)
    800044c0:	e4a6                	sd	s1,72(sp)
    800044c2:	e0ca                	sd	s2,64(sp)
    800044c4:	fc4e                	sd	s3,56(sp)
    800044c6:	f852                	sd	s4,48(sp)
    800044c8:	f456                	sd	s5,40(sp)
    800044ca:	f05a                	sd	s6,32(sp)
    800044cc:	ec5e                	sd	s7,24(sp)
    800044ce:	e862                	sd	s8,16(sp)
    800044d0:	e466                	sd	s9,8(sp)
    800044d2:	1080                	addi	s0,sp,96
    800044d4:	84aa                	mv	s1,a0
    800044d6:	8aae                	mv	s5,a1
    800044d8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800044da:	00054703          	lbu	a4,0(a0)
    800044de:	02f00793          	li	a5,47
    800044e2:	00f70f63          	beq	a4,a5,80004500 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800044e6:	eb4fd0ef          	jal	ra,80001b9a <myproc>
    800044ea:	15053503          	ld	a0,336(a0)
    800044ee:	973ff0ef          	jal	ra,80003e60 <idup>
    800044f2:	89aa                	mv	s3,a0
  while(*path == '/')
    800044f4:	02f00913          	li	s2,47
  len = path - s;
    800044f8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800044fa:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800044fc:	4b85                	li	s7,1
    800044fe:	a861                	j	80004596 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80004500:	4585                	li	a1,1
    80004502:	4505                	li	a0,1
    80004504:	f26ff0ef          	jal	ra,80003c2a <iget>
    80004508:	89aa                	mv	s3,a0
    8000450a:	b7ed                	j	800044f4 <namex+0x3a>
      iunlockput(ip);
    8000450c:	854e                	mv	a0,s3
    8000450e:	b8fff0ef          	jal	ra,8000409c <iunlockput>
      return 0;
    80004512:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004514:	854e                	mv	a0,s3
    80004516:	60e6                	ld	ra,88(sp)
    80004518:	6446                	ld	s0,80(sp)
    8000451a:	64a6                	ld	s1,72(sp)
    8000451c:	6906                	ld	s2,64(sp)
    8000451e:	79e2                	ld	s3,56(sp)
    80004520:	7a42                	ld	s4,48(sp)
    80004522:	7aa2                	ld	s5,40(sp)
    80004524:	7b02                	ld	s6,32(sp)
    80004526:	6be2                	ld	s7,24(sp)
    80004528:	6c42                	ld	s8,16(sp)
    8000452a:	6ca2                	ld	s9,8(sp)
    8000452c:	6125                	addi	sp,sp,96
    8000452e:	8082                	ret
      iunlock(ip);
    80004530:	854e                	mv	a0,s3
    80004532:	a0fff0ef          	jal	ra,80003f40 <iunlock>
      return ip;
    80004536:	bff9                	j	80004514 <namex+0x5a>
      iunlockput(ip);
    80004538:	854e                	mv	a0,s3
    8000453a:	b63ff0ef          	jal	ra,8000409c <iunlockput>
      return 0;
    8000453e:	89e6                	mv	s3,s9
    80004540:	bfd1                	j	80004514 <namex+0x5a>
  len = path - s;
    80004542:	40b48633          	sub	a2,s1,a1
    80004546:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000454a:	079c5c63          	bge	s8,s9,800045c2 <namex+0x108>
    memmove(name, s, DIRSIZ);
    8000454e:	4639                	li	a2,14
    80004550:	8552                	mv	a0,s4
    80004552:	88ffc0ef          	jal	ra,80000de0 <memmove>
  while(*path == '/')
    80004556:	0004c783          	lbu	a5,0(s1)
    8000455a:	01279763          	bne	a5,s2,80004568 <namex+0xae>
    path++;
    8000455e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004560:	0004c783          	lbu	a5,0(s1)
    80004564:	ff278de3          	beq	a5,s2,8000455e <namex+0xa4>
    ilock(ip);
    80004568:	854e                	mv	a0,s3
    8000456a:	92dff0ef          	jal	ra,80003e96 <ilock>
    if(ip->type != T_DIR){
    8000456e:	04499783          	lh	a5,68(s3)
    80004572:	f9779de3          	bne	a5,s7,8000450c <namex+0x52>
    if(nameiparent && *path == '\0'){
    80004576:	000a8563          	beqz	s5,80004580 <namex+0xc6>
    8000457a:	0004c783          	lbu	a5,0(s1)
    8000457e:	dbcd                	beqz	a5,80004530 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004580:	865a                	mv	a2,s6
    80004582:	85d2                	mv	a1,s4
    80004584:	854e                	mv	a0,s3
    80004586:	e99ff0ef          	jal	ra,8000441e <dirlookup>
    8000458a:	8caa                	mv	s9,a0
    8000458c:	d555                	beqz	a0,80004538 <namex+0x7e>
    iunlockput(ip);
    8000458e:	854e                	mv	a0,s3
    80004590:	b0dff0ef          	jal	ra,8000409c <iunlockput>
    ip = next;
    80004594:	89e6                	mv	s3,s9
  while(*path == '/')
    80004596:	0004c783          	lbu	a5,0(s1)
    8000459a:	05279363          	bne	a5,s2,800045e0 <namex+0x126>
    path++;
    8000459e:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045a0:	0004c783          	lbu	a5,0(s1)
    800045a4:	ff278de3          	beq	a5,s2,8000459e <namex+0xe4>
  if(*path == 0)
    800045a8:	c78d                	beqz	a5,800045d2 <namex+0x118>
    path++;
    800045aa:	85a6                	mv	a1,s1
  len = path - s;
    800045ac:	8cda                	mv	s9,s6
    800045ae:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800045b0:	01278963          	beq	a5,s2,800045c2 <namex+0x108>
    800045b4:	d7d9                	beqz	a5,80004542 <namex+0x88>
    path++;
    800045b6:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800045b8:	0004c783          	lbu	a5,0(s1)
    800045bc:	ff279ce3          	bne	a5,s2,800045b4 <namex+0xfa>
    800045c0:	b749                	j	80004542 <namex+0x88>
    memmove(name, s, len);
    800045c2:	2601                	sext.w	a2,a2
    800045c4:	8552                	mv	a0,s4
    800045c6:	81bfc0ef          	jal	ra,80000de0 <memmove>
    name[len] = 0;
    800045ca:	9cd2                	add	s9,s9,s4
    800045cc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800045d0:	b759                	j	80004556 <namex+0x9c>
  if(nameiparent){
    800045d2:	f40a81e3          	beqz	s5,80004514 <namex+0x5a>
    iput(ip);
    800045d6:	854e                	mv	a0,s3
    800045d8:	a3dff0ef          	jal	ra,80004014 <iput>
    return 0;
    800045dc:	4981                	li	s3,0
    800045de:	bf1d                	j	80004514 <namex+0x5a>
  if(*path == 0)
    800045e0:	dbed                	beqz	a5,800045d2 <namex+0x118>
  while(*path != '/' && *path != 0)
    800045e2:	0004c783          	lbu	a5,0(s1)
    800045e6:	85a6                	mv	a1,s1
    800045e8:	b7f1                	j	800045b4 <namex+0xfa>

00000000800045ea <dirlink>:
{
    800045ea:	7139                	addi	sp,sp,-64
    800045ec:	fc06                	sd	ra,56(sp)
    800045ee:	f822                	sd	s0,48(sp)
    800045f0:	f426                	sd	s1,40(sp)
    800045f2:	f04a                	sd	s2,32(sp)
    800045f4:	ec4e                	sd	s3,24(sp)
    800045f6:	e852                	sd	s4,16(sp)
    800045f8:	0080                	addi	s0,sp,64
    800045fa:	892a                	mv	s2,a0
    800045fc:	8a2e                	mv	s4,a1
    800045fe:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004600:	4601                	li	a2,0
    80004602:	e1dff0ef          	jal	ra,8000441e <dirlookup>
    80004606:	e52d                	bnez	a0,80004670 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004608:	04c92483          	lw	s1,76(s2)
    8000460c:	c48d                	beqz	s1,80004636 <dirlink+0x4c>
    8000460e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004610:	4741                	li	a4,16
    80004612:	86a6                	mv	a3,s1
    80004614:	fc040613          	addi	a2,s0,-64
    80004618:	4581                	li	a1,0
    8000461a:	854a                	mv	a0,s2
    8000461c:	c07ff0ef          	jal	ra,80004222 <readi>
    80004620:	47c1                	li	a5,16
    80004622:	04f51b63          	bne	a0,a5,80004678 <dirlink+0x8e>
    if(de.inum == 0)
    80004626:	fc045783          	lhu	a5,-64(s0)
    8000462a:	c791                	beqz	a5,80004636 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000462c:	24c1                	addiw	s1,s1,16
    8000462e:	04c92783          	lw	a5,76(s2)
    80004632:	fcf4efe3          	bltu	s1,a5,80004610 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004636:	4639                	li	a2,14
    80004638:	85d2                	mv	a1,s4
    8000463a:	fc240513          	addi	a0,s0,-62
    8000463e:	84ffc0ef          	jal	ra,80000e8c <strncpy>
  de.inum = inum;
    80004642:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004646:	4741                	li	a4,16
    80004648:	86a6                	mv	a3,s1
    8000464a:	fc040613          	addi	a2,s0,-64
    8000464e:	4581                	li	a1,0
    80004650:	854a                	mv	a0,s2
    80004652:	cb5ff0ef          	jal	ra,80004306 <writei>
    80004656:	1541                	addi	a0,a0,-16
    80004658:	00a03533          	snez	a0,a0
    8000465c:	40a00533          	neg	a0,a0
}
    80004660:	70e2                	ld	ra,56(sp)
    80004662:	7442                	ld	s0,48(sp)
    80004664:	74a2                	ld	s1,40(sp)
    80004666:	7902                	ld	s2,32(sp)
    80004668:	69e2                	ld	s3,24(sp)
    8000466a:	6a42                	ld	s4,16(sp)
    8000466c:	6121                	addi	sp,sp,64
    8000466e:	8082                	ret
    iput(ip);
    80004670:	9a5ff0ef          	jal	ra,80004014 <iput>
    return -1;
    80004674:	557d                	li	a0,-1
    80004676:	b7ed                	j	80004660 <dirlink+0x76>
      panic("dirlink read");
    80004678:	00004517          	auipc	a0,0x4
    8000467c:	fa850513          	addi	a0,a0,-88 # 80008620 <syscalls+0x228>
    80004680:	90afc0ef          	jal	ra,8000078a <panic>

0000000080004684 <namei>:

struct inode*
namei(char *path)
{
    80004684:	1101                	addi	sp,sp,-32
    80004686:	ec06                	sd	ra,24(sp)
    80004688:	e822                	sd	s0,16(sp)
    8000468a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000468c:	fe040613          	addi	a2,s0,-32
    80004690:	4581                	li	a1,0
    80004692:	e29ff0ef          	jal	ra,800044ba <namex>
}
    80004696:	60e2                	ld	ra,24(sp)
    80004698:	6442                	ld	s0,16(sp)
    8000469a:	6105                	addi	sp,sp,32
    8000469c:	8082                	ret

000000008000469e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000469e:	1141                	addi	sp,sp,-16
    800046a0:	e406                	sd	ra,8(sp)
    800046a2:	e022                	sd	s0,0(sp)
    800046a4:	0800                	addi	s0,sp,16
    800046a6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800046a8:	4585                	li	a1,1
    800046aa:	e11ff0ef          	jal	ra,800044ba <namex>
}
    800046ae:	60a2                	ld	ra,8(sp)
    800046b0:	6402                	ld	s0,0(sp)
    800046b2:	0141                	addi	sp,sp,16
    800046b4:	8082                	ret

00000000800046b6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800046b6:	1101                	addi	sp,sp,-32
    800046b8:	ec06                	sd	ra,24(sp)
    800046ba:	e822                	sd	s0,16(sp)
    800046bc:	e426                	sd	s1,8(sp)
    800046be:	e04a                	sd	s2,0(sp)
    800046c0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800046c2:	00246917          	auipc	s2,0x246
    800046c6:	30e90913          	addi	s2,s2,782 # 8024a9d0 <log>
    800046ca:	01892583          	lw	a1,24(s2)
    800046ce:	02492503          	lw	a0,36(s2)
    800046d2:	912ff0ef          	jal	ra,800037e4 <bread>
    800046d6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046d8:	02892683          	lw	a3,40(s2)
    800046dc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046de:	02d05763          	blez	a3,8000470c <write_head+0x56>
    800046e2:	00246797          	auipc	a5,0x246
    800046e6:	31a78793          	addi	a5,a5,794 # 8024a9fc <log+0x2c>
    800046ea:	05c50713          	addi	a4,a0,92
    800046ee:	36fd                	addiw	a3,a3,-1
    800046f0:	1682                	slli	a3,a3,0x20
    800046f2:	9281                	srli	a3,a3,0x20
    800046f4:	068a                	slli	a3,a3,0x2
    800046f6:	00246617          	auipc	a2,0x246
    800046fa:	30a60613          	addi	a2,a2,778 # 8024aa00 <log+0x30>
    800046fe:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004700:	4390                	lw	a2,0(a5)
    80004702:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004704:	0791                	addi	a5,a5,4
    80004706:	0711                	addi	a4,a4,4
    80004708:	fed79ce3          	bne	a5,a3,80004700 <write_head+0x4a>
  }
  bwrite(buf);
    8000470c:	8526                	mv	a0,s1
    8000470e:	9acff0ef          	jal	ra,800038ba <bwrite>
  brelse(buf);
    80004712:	8526                	mv	a0,s1
    80004714:	9d8ff0ef          	jal	ra,800038ec <brelse>
}
    80004718:	60e2                	ld	ra,24(sp)
    8000471a:	6442                	ld	s0,16(sp)
    8000471c:	64a2                	ld	s1,8(sp)
    8000471e:	6902                	ld	s2,0(sp)
    80004720:	6105                	addi	sp,sp,32
    80004722:	8082                	ret

0000000080004724 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004724:	00246797          	auipc	a5,0x246
    80004728:	2d47a783          	lw	a5,724(a5) # 8024a9f8 <log+0x28>
    8000472c:	0af05e63          	blez	a5,800047e8 <install_trans+0xc4>
{
    80004730:	715d                	addi	sp,sp,-80
    80004732:	e486                	sd	ra,72(sp)
    80004734:	e0a2                	sd	s0,64(sp)
    80004736:	fc26                	sd	s1,56(sp)
    80004738:	f84a                	sd	s2,48(sp)
    8000473a:	f44e                	sd	s3,40(sp)
    8000473c:	f052                	sd	s4,32(sp)
    8000473e:	ec56                	sd	s5,24(sp)
    80004740:	e85a                	sd	s6,16(sp)
    80004742:	e45e                	sd	s7,8(sp)
    80004744:	0880                	addi	s0,sp,80
    80004746:	8b2a                	mv	s6,a0
    80004748:	00246a97          	auipc	s5,0x246
    8000474c:	2b4a8a93          	addi	s5,s5,692 # 8024a9fc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004750:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004752:	00004b97          	auipc	s7,0x4
    80004756:	edeb8b93          	addi	s7,s7,-290 # 80008630 <syscalls+0x238>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000475a:	00246a17          	auipc	s4,0x246
    8000475e:	276a0a13          	addi	s4,s4,630 # 8024a9d0 <log>
    80004762:	a025                	j	8000478a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004764:	000aa603          	lw	a2,0(s5)
    80004768:	85ce                	mv	a1,s3
    8000476a:	855e                	mv	a0,s7
    8000476c:	d59fb0ef          	jal	ra,800004c4 <printf>
    80004770:	a839                	j	8000478e <install_trans+0x6a>
    brelse(lbuf);
    80004772:	854a                	mv	a0,s2
    80004774:	978ff0ef          	jal	ra,800038ec <brelse>
    brelse(dbuf);
    80004778:	8526                	mv	a0,s1
    8000477a:	972ff0ef          	jal	ra,800038ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000477e:	2985                	addiw	s3,s3,1
    80004780:	0a91                	addi	s5,s5,4
    80004782:	028a2783          	lw	a5,40(s4)
    80004786:	04f9d663          	bge	s3,a5,800047d2 <install_trans+0xae>
    if(recovering) {
    8000478a:	fc0b1de3          	bnez	s6,80004764 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000478e:	018a2583          	lw	a1,24(s4)
    80004792:	013585bb          	addw	a1,a1,s3
    80004796:	2585                	addiw	a1,a1,1
    80004798:	024a2503          	lw	a0,36(s4)
    8000479c:	848ff0ef          	jal	ra,800037e4 <bread>
    800047a0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800047a2:	000aa583          	lw	a1,0(s5)
    800047a6:	024a2503          	lw	a0,36(s4)
    800047aa:	83aff0ef          	jal	ra,800037e4 <bread>
    800047ae:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047b0:	40000613          	li	a2,1024
    800047b4:	05890593          	addi	a1,s2,88
    800047b8:	05850513          	addi	a0,a0,88
    800047bc:	e24fc0ef          	jal	ra,80000de0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800047c0:	8526                	mv	a0,s1
    800047c2:	8f8ff0ef          	jal	ra,800038ba <bwrite>
    if(recovering == 0)
    800047c6:	fa0b16e3          	bnez	s6,80004772 <install_trans+0x4e>
      bunpin(dbuf);
    800047ca:	8526                	mv	a0,s1
    800047cc:	9deff0ef          	jal	ra,800039aa <bunpin>
    800047d0:	b74d                	j	80004772 <install_trans+0x4e>
}
    800047d2:	60a6                	ld	ra,72(sp)
    800047d4:	6406                	ld	s0,64(sp)
    800047d6:	74e2                	ld	s1,56(sp)
    800047d8:	7942                	ld	s2,48(sp)
    800047da:	79a2                	ld	s3,40(sp)
    800047dc:	7a02                	ld	s4,32(sp)
    800047de:	6ae2                	ld	s5,24(sp)
    800047e0:	6b42                	ld	s6,16(sp)
    800047e2:	6ba2                	ld	s7,8(sp)
    800047e4:	6161                	addi	sp,sp,80
    800047e6:	8082                	ret
    800047e8:	8082                	ret

00000000800047ea <initlog>:
{
    800047ea:	7179                	addi	sp,sp,-48
    800047ec:	f406                	sd	ra,40(sp)
    800047ee:	f022                	sd	s0,32(sp)
    800047f0:	ec26                	sd	s1,24(sp)
    800047f2:	e84a                	sd	s2,16(sp)
    800047f4:	e44e                	sd	s3,8(sp)
    800047f6:	1800                	addi	s0,sp,48
    800047f8:	892a                	mv	s2,a0
    800047fa:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047fc:	00246497          	auipc	s1,0x246
    80004800:	1d448493          	addi	s1,s1,468 # 8024a9d0 <log>
    80004804:	00004597          	auipc	a1,0x4
    80004808:	e4c58593          	addi	a1,a1,-436 # 80008650 <syscalls+0x258>
    8000480c:	8526                	mv	a0,s1
    8000480e:	c22fc0ef          	jal	ra,80000c30 <initlock>
  log.start = sb->logstart;
    80004812:	0149a583          	lw	a1,20(s3)
    80004816:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004818:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000481c:	854a                	mv	a0,s2
    8000481e:	fc7fe0ef          	jal	ra,800037e4 <bread>
  log.lh.n = lh->n;
    80004822:	4d34                	lw	a3,88(a0)
    80004824:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004826:	02d05563          	blez	a3,80004850 <initlog+0x66>
    8000482a:	05c50793          	addi	a5,a0,92
    8000482e:	00246717          	auipc	a4,0x246
    80004832:	1ce70713          	addi	a4,a4,462 # 8024a9fc <log+0x2c>
    80004836:	36fd                	addiw	a3,a3,-1
    80004838:	1682                	slli	a3,a3,0x20
    8000483a:	9281                	srli	a3,a3,0x20
    8000483c:	068a                	slli	a3,a3,0x2
    8000483e:	06050613          	addi	a2,a0,96
    80004842:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004844:	4390                	lw	a2,0(a5)
    80004846:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004848:	0791                	addi	a5,a5,4
    8000484a:	0711                	addi	a4,a4,4
    8000484c:	fed79ce3          	bne	a5,a3,80004844 <initlog+0x5a>
  brelse(buf);
    80004850:	89cff0ef          	jal	ra,800038ec <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004854:	4505                	li	a0,1
    80004856:	ecfff0ef          	jal	ra,80004724 <install_trans>
  log.lh.n = 0;
    8000485a:	00246797          	auipc	a5,0x246
    8000485e:	1807af23          	sw	zero,414(a5) # 8024a9f8 <log+0x28>
  write_head(); // clear the log
    80004862:	e55ff0ef          	jal	ra,800046b6 <write_head>
}
    80004866:	70a2                	ld	ra,40(sp)
    80004868:	7402                	ld	s0,32(sp)
    8000486a:	64e2                	ld	s1,24(sp)
    8000486c:	6942                	ld	s2,16(sp)
    8000486e:	69a2                	ld	s3,8(sp)
    80004870:	6145                	addi	sp,sp,48
    80004872:	8082                	ret

0000000080004874 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004874:	1101                	addi	sp,sp,-32
    80004876:	ec06                	sd	ra,24(sp)
    80004878:	e822                	sd	s0,16(sp)
    8000487a:	e426                	sd	s1,8(sp)
    8000487c:	e04a                	sd	s2,0(sp)
    8000487e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004880:	00246517          	auipc	a0,0x246
    80004884:	15050513          	addi	a0,a0,336 # 8024a9d0 <log>
    80004888:	c28fc0ef          	jal	ra,80000cb0 <acquire>
  while(1){
    if(log.committing){
    8000488c:	00246497          	auipc	s1,0x246
    80004890:	14448493          	addi	s1,s1,324 # 8024a9d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004894:	4979                	li	s2,30
    80004896:	a029                	j	800048a0 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004898:	85a6                	mv	a1,s1
    8000489a:	8526                	mv	a0,s1
    8000489c:	bf7fd0ef          	jal	ra,80002492 <sleep>
    if(log.committing){
    800048a0:	509c                	lw	a5,32(s1)
    800048a2:	fbfd                	bnez	a5,80004898 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800048a4:	4cdc                	lw	a5,28(s1)
    800048a6:	0017871b          	addiw	a4,a5,1
    800048aa:	0007069b          	sext.w	a3,a4
    800048ae:	0027179b          	slliw	a5,a4,0x2
    800048b2:	9fb9                	addw	a5,a5,a4
    800048b4:	0017979b          	slliw	a5,a5,0x1
    800048b8:	5498                	lw	a4,40(s1)
    800048ba:	9fb9                	addw	a5,a5,a4
    800048bc:	00f95763          	bge	s2,a5,800048ca <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048c0:	85a6                	mv	a1,s1
    800048c2:	8526                	mv	a0,s1
    800048c4:	bcffd0ef          	jal	ra,80002492 <sleep>
    800048c8:	bfe1                	j	800048a0 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800048ca:	00246517          	auipc	a0,0x246
    800048ce:	10650513          	addi	a0,a0,262 # 8024a9d0 <log>
    800048d2:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    800048d4:	c74fc0ef          	jal	ra,80000d48 <release>
      break;
    }
  }
}
    800048d8:	60e2                	ld	ra,24(sp)
    800048da:	6442                	ld	s0,16(sp)
    800048dc:	64a2                	ld	s1,8(sp)
    800048de:	6902                	ld	s2,0(sp)
    800048e0:	6105                	addi	sp,sp,32
    800048e2:	8082                	ret

00000000800048e4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048e4:	7139                	addi	sp,sp,-64
    800048e6:	fc06                	sd	ra,56(sp)
    800048e8:	f822                	sd	s0,48(sp)
    800048ea:	f426                	sd	s1,40(sp)
    800048ec:	f04a                	sd	s2,32(sp)
    800048ee:	ec4e                	sd	s3,24(sp)
    800048f0:	e852                	sd	s4,16(sp)
    800048f2:	e456                	sd	s5,8(sp)
    800048f4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800048f6:	00246497          	auipc	s1,0x246
    800048fa:	0da48493          	addi	s1,s1,218 # 8024a9d0 <log>
    800048fe:	8526                	mv	a0,s1
    80004900:	bb0fc0ef          	jal	ra,80000cb0 <acquire>
  log.outstanding -= 1;
    80004904:	4cdc                	lw	a5,28(s1)
    80004906:	37fd                	addiw	a5,a5,-1
    80004908:	0007891b          	sext.w	s2,a5
    8000490c:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000490e:	509c                	lw	a5,32(s1)
    80004910:	ef9d                	bnez	a5,8000494e <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004912:	04091463          	bnez	s2,8000495a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004916:	00246497          	auipc	s1,0x246
    8000491a:	0ba48493          	addi	s1,s1,186 # 8024a9d0 <log>
    8000491e:	4785                	li	a5,1
    80004920:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004922:	8526                	mv	a0,s1
    80004924:	c24fc0ef          	jal	ra,80000d48 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004928:	549c                	lw	a5,40(s1)
    8000492a:	04f04b63          	bgtz	a5,80004980 <end_op+0x9c>
    acquire(&log.lock);
    8000492e:	00246497          	auipc	s1,0x246
    80004932:	0a248493          	addi	s1,s1,162 # 8024a9d0 <log>
    80004936:	8526                	mv	a0,s1
    80004938:	b78fc0ef          	jal	ra,80000cb0 <acquire>
    log.committing = 0;
    8000493c:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004940:	8526                	mv	a0,s1
    80004942:	b9dfd0ef          	jal	ra,800024de <wakeup>
    release(&log.lock);
    80004946:	8526                	mv	a0,s1
    80004948:	c00fc0ef          	jal	ra,80000d48 <release>
}
    8000494c:	a00d                	j	8000496e <end_op+0x8a>
    panic("log.committing");
    8000494e:	00004517          	auipc	a0,0x4
    80004952:	d0a50513          	addi	a0,a0,-758 # 80008658 <syscalls+0x260>
    80004956:	e35fb0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    8000495a:	00246497          	auipc	s1,0x246
    8000495e:	07648493          	addi	s1,s1,118 # 8024a9d0 <log>
    80004962:	8526                	mv	a0,s1
    80004964:	b7bfd0ef          	jal	ra,800024de <wakeup>
  release(&log.lock);
    80004968:	8526                	mv	a0,s1
    8000496a:	bdefc0ef          	jal	ra,80000d48 <release>
}
    8000496e:	70e2                	ld	ra,56(sp)
    80004970:	7442                	ld	s0,48(sp)
    80004972:	74a2                	ld	s1,40(sp)
    80004974:	7902                	ld	s2,32(sp)
    80004976:	69e2                	ld	s3,24(sp)
    80004978:	6a42                	ld	s4,16(sp)
    8000497a:	6aa2                	ld	s5,8(sp)
    8000497c:	6121                	addi	sp,sp,64
    8000497e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004980:	00246a97          	auipc	s5,0x246
    80004984:	07ca8a93          	addi	s5,s5,124 # 8024a9fc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004988:	00246a17          	auipc	s4,0x246
    8000498c:	048a0a13          	addi	s4,s4,72 # 8024a9d0 <log>
    80004990:	018a2583          	lw	a1,24(s4)
    80004994:	012585bb          	addw	a1,a1,s2
    80004998:	2585                	addiw	a1,a1,1
    8000499a:	024a2503          	lw	a0,36(s4)
    8000499e:	e47fe0ef          	jal	ra,800037e4 <bread>
    800049a2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049a4:	000aa583          	lw	a1,0(s5)
    800049a8:	024a2503          	lw	a0,36(s4)
    800049ac:	e39fe0ef          	jal	ra,800037e4 <bread>
    800049b0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049b2:	40000613          	li	a2,1024
    800049b6:	05850593          	addi	a1,a0,88
    800049ba:	05848513          	addi	a0,s1,88
    800049be:	c22fc0ef          	jal	ra,80000de0 <memmove>
    bwrite(to);  // write the log
    800049c2:	8526                	mv	a0,s1
    800049c4:	ef7fe0ef          	jal	ra,800038ba <bwrite>
    brelse(from);
    800049c8:	854e                	mv	a0,s3
    800049ca:	f23fe0ef          	jal	ra,800038ec <brelse>
    brelse(to);
    800049ce:	8526                	mv	a0,s1
    800049d0:	f1dfe0ef          	jal	ra,800038ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049d4:	2905                	addiw	s2,s2,1
    800049d6:	0a91                	addi	s5,s5,4
    800049d8:	028a2783          	lw	a5,40(s4)
    800049dc:	faf94ae3          	blt	s2,a5,80004990 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800049e0:	cd7ff0ef          	jal	ra,800046b6 <write_head>
    install_trans(0); // Now install writes to home locations
    800049e4:	4501                	li	a0,0
    800049e6:	d3fff0ef          	jal	ra,80004724 <install_trans>
    log.lh.n = 0;
    800049ea:	00246797          	auipc	a5,0x246
    800049ee:	0007a723          	sw	zero,14(a5) # 8024a9f8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800049f2:	cc5ff0ef          	jal	ra,800046b6 <write_head>
    800049f6:	bf25                	j	8000492e <end_op+0x4a>

00000000800049f8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800049f8:	1101                	addi	sp,sp,-32
    800049fa:	ec06                	sd	ra,24(sp)
    800049fc:	e822                	sd	s0,16(sp)
    800049fe:	e426                	sd	s1,8(sp)
    80004a00:	e04a                	sd	s2,0(sp)
    80004a02:	1000                	addi	s0,sp,32
    80004a04:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a06:	00246917          	auipc	s2,0x246
    80004a0a:	fca90913          	addi	s2,s2,-54 # 8024a9d0 <log>
    80004a0e:	854a                	mv	a0,s2
    80004a10:	aa0fc0ef          	jal	ra,80000cb0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004a14:	02892603          	lw	a2,40(s2)
    80004a18:	47f5                	li	a5,29
    80004a1a:	04c7cc63          	blt	a5,a2,80004a72 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a1e:	00246797          	auipc	a5,0x246
    80004a22:	fce7a783          	lw	a5,-50(a5) # 8024a9ec <log+0x1c>
    80004a26:	04f05c63          	blez	a5,80004a7e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a2a:	4781                	li	a5,0
    80004a2c:	04c05f63          	blez	a2,80004a8a <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a30:	44cc                	lw	a1,12(s1)
    80004a32:	00246717          	auipc	a4,0x246
    80004a36:	fca70713          	addi	a4,a4,-54 # 8024a9fc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004a3a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a3c:	4314                	lw	a3,0(a4)
    80004a3e:	04b68663          	beq	a3,a1,80004a8a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004a42:	2785                	addiw	a5,a5,1
    80004a44:	0711                	addi	a4,a4,4
    80004a46:	fef61be3          	bne	a2,a5,80004a3c <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a4a:	0621                	addi	a2,a2,8
    80004a4c:	060a                	slli	a2,a2,0x2
    80004a4e:	00246797          	auipc	a5,0x246
    80004a52:	f8278793          	addi	a5,a5,-126 # 8024a9d0 <log>
    80004a56:	963e                	add	a2,a2,a5
    80004a58:	44dc                	lw	a5,12(s1)
    80004a5a:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004a5c:	8526                	mv	a0,s1
    80004a5e:	f19fe0ef          	jal	ra,80003976 <bpin>
    log.lh.n++;
    80004a62:	00246717          	auipc	a4,0x246
    80004a66:	f6e70713          	addi	a4,a4,-146 # 8024a9d0 <log>
    80004a6a:	571c                	lw	a5,40(a4)
    80004a6c:	2785                	addiw	a5,a5,1
    80004a6e:	d71c                	sw	a5,40(a4)
    80004a70:	a815                	j	80004aa4 <log_write+0xac>
    panic("too big a transaction");
    80004a72:	00004517          	auipc	a0,0x4
    80004a76:	bf650513          	addi	a0,a0,-1034 # 80008668 <syscalls+0x270>
    80004a7a:	d11fb0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80004a7e:	00004517          	auipc	a0,0x4
    80004a82:	c0250513          	addi	a0,a0,-1022 # 80008680 <syscalls+0x288>
    80004a86:	d05fb0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80004a8a:	00878713          	addi	a4,a5,8
    80004a8e:	00271693          	slli	a3,a4,0x2
    80004a92:	00246717          	auipc	a4,0x246
    80004a96:	f3e70713          	addi	a4,a4,-194 # 8024a9d0 <log>
    80004a9a:	9736                	add	a4,a4,a3
    80004a9c:	44d4                	lw	a3,12(s1)
    80004a9e:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004aa0:	faf60ee3          	beq	a2,a5,80004a5c <log_write+0x64>
  }
  release(&log.lock);
    80004aa4:	00246517          	auipc	a0,0x246
    80004aa8:	f2c50513          	addi	a0,a0,-212 # 8024a9d0 <log>
    80004aac:	a9cfc0ef          	jal	ra,80000d48 <release>
}
    80004ab0:	60e2                	ld	ra,24(sp)
    80004ab2:	6442                	ld	s0,16(sp)
    80004ab4:	64a2                	ld	s1,8(sp)
    80004ab6:	6902                	ld	s2,0(sp)
    80004ab8:	6105                	addi	sp,sp,32
    80004aba:	8082                	ret

0000000080004abc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004abc:	1101                	addi	sp,sp,-32
    80004abe:	ec06                	sd	ra,24(sp)
    80004ac0:	e822                	sd	s0,16(sp)
    80004ac2:	e426                	sd	s1,8(sp)
    80004ac4:	e04a                	sd	s2,0(sp)
    80004ac6:	1000                	addi	s0,sp,32
    80004ac8:	84aa                	mv	s1,a0
    80004aca:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004acc:	00004597          	auipc	a1,0x4
    80004ad0:	bd458593          	addi	a1,a1,-1068 # 800086a0 <syscalls+0x2a8>
    80004ad4:	0521                	addi	a0,a0,8
    80004ad6:	95afc0ef          	jal	ra,80000c30 <initlock>
  lk->name = name;
    80004ada:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004ade:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ae2:	0204a423          	sw	zero,40(s1)
}
    80004ae6:	60e2                	ld	ra,24(sp)
    80004ae8:	6442                	ld	s0,16(sp)
    80004aea:	64a2                	ld	s1,8(sp)
    80004aec:	6902                	ld	s2,0(sp)
    80004aee:	6105                	addi	sp,sp,32
    80004af0:	8082                	ret

0000000080004af2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004af2:	1101                	addi	sp,sp,-32
    80004af4:	ec06                	sd	ra,24(sp)
    80004af6:	e822                	sd	s0,16(sp)
    80004af8:	e426                	sd	s1,8(sp)
    80004afa:	e04a                	sd	s2,0(sp)
    80004afc:	1000                	addi	s0,sp,32
    80004afe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b00:	00850913          	addi	s2,a0,8
    80004b04:	854a                	mv	a0,s2
    80004b06:	9aafc0ef          	jal	ra,80000cb0 <acquire>
  while (lk->locked) {
    80004b0a:	409c                	lw	a5,0(s1)
    80004b0c:	c799                	beqz	a5,80004b1a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004b0e:	85ca                	mv	a1,s2
    80004b10:	8526                	mv	a0,s1
    80004b12:	981fd0ef          	jal	ra,80002492 <sleep>
  while (lk->locked) {
    80004b16:	409c                	lw	a5,0(s1)
    80004b18:	fbfd                	bnez	a5,80004b0e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004b1a:	4785                	li	a5,1
    80004b1c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b1e:	87cfd0ef          	jal	ra,80001b9a <myproc>
    80004b22:	591c                	lw	a5,48(a0)
    80004b24:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b26:	854a                	mv	a0,s2
    80004b28:	a20fc0ef          	jal	ra,80000d48 <release>
}
    80004b2c:	60e2                	ld	ra,24(sp)
    80004b2e:	6442                	ld	s0,16(sp)
    80004b30:	64a2                	ld	s1,8(sp)
    80004b32:	6902                	ld	s2,0(sp)
    80004b34:	6105                	addi	sp,sp,32
    80004b36:	8082                	ret

0000000080004b38 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b38:	1101                	addi	sp,sp,-32
    80004b3a:	ec06                	sd	ra,24(sp)
    80004b3c:	e822                	sd	s0,16(sp)
    80004b3e:	e426                	sd	s1,8(sp)
    80004b40:	e04a                	sd	s2,0(sp)
    80004b42:	1000                	addi	s0,sp,32
    80004b44:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b46:	00850913          	addi	s2,a0,8
    80004b4a:	854a                	mv	a0,s2
    80004b4c:	964fc0ef          	jal	ra,80000cb0 <acquire>
  lk->locked = 0;
    80004b50:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b54:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	985fd0ef          	jal	ra,800024de <wakeup>
  release(&lk->lk);
    80004b5e:	854a                	mv	a0,s2
    80004b60:	9e8fc0ef          	jal	ra,80000d48 <release>
}
    80004b64:	60e2                	ld	ra,24(sp)
    80004b66:	6442                	ld	s0,16(sp)
    80004b68:	64a2                	ld	s1,8(sp)
    80004b6a:	6902                	ld	s2,0(sp)
    80004b6c:	6105                	addi	sp,sp,32
    80004b6e:	8082                	ret

0000000080004b70 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b70:	7179                	addi	sp,sp,-48
    80004b72:	f406                	sd	ra,40(sp)
    80004b74:	f022                	sd	s0,32(sp)
    80004b76:	ec26                	sd	s1,24(sp)
    80004b78:	e84a                	sd	s2,16(sp)
    80004b7a:	e44e                	sd	s3,8(sp)
    80004b7c:	1800                	addi	s0,sp,48
    80004b7e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b80:	00850913          	addi	s2,a0,8
    80004b84:	854a                	mv	a0,s2
    80004b86:	92afc0ef          	jal	ra,80000cb0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b8a:	409c                	lw	a5,0(s1)
    80004b8c:	ef89                	bnez	a5,80004ba6 <holdingsleep+0x36>
    80004b8e:	4481                	li	s1,0
  release(&lk->lk);
    80004b90:	854a                	mv	a0,s2
    80004b92:	9b6fc0ef          	jal	ra,80000d48 <release>
  return r;
}
    80004b96:	8526                	mv	a0,s1
    80004b98:	70a2                	ld	ra,40(sp)
    80004b9a:	7402                	ld	s0,32(sp)
    80004b9c:	64e2                	ld	s1,24(sp)
    80004b9e:	6942                	ld	s2,16(sp)
    80004ba0:	69a2                	ld	s3,8(sp)
    80004ba2:	6145                	addi	sp,sp,48
    80004ba4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ba6:	0284a983          	lw	s3,40(s1)
    80004baa:	ff1fc0ef          	jal	ra,80001b9a <myproc>
    80004bae:	5904                	lw	s1,48(a0)
    80004bb0:	413484b3          	sub	s1,s1,s3
    80004bb4:	0014b493          	seqz	s1,s1
    80004bb8:	bfe1                	j	80004b90 <holdingsleep+0x20>

0000000080004bba <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004bba:	1141                	addi	sp,sp,-16
    80004bbc:	e406                	sd	ra,8(sp)
    80004bbe:	e022                	sd	s0,0(sp)
    80004bc0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004bc2:	00004597          	auipc	a1,0x4
    80004bc6:	aee58593          	addi	a1,a1,-1298 # 800086b0 <syscalls+0x2b8>
    80004bca:	00246517          	auipc	a0,0x246
    80004bce:	f4e50513          	addi	a0,a0,-178 # 8024ab18 <ftable>
    80004bd2:	85efc0ef          	jal	ra,80000c30 <initlock>
}
    80004bd6:	60a2                	ld	ra,8(sp)
    80004bd8:	6402                	ld	s0,0(sp)
    80004bda:	0141                	addi	sp,sp,16
    80004bdc:	8082                	ret

0000000080004bde <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004bde:	1101                	addi	sp,sp,-32
    80004be0:	ec06                	sd	ra,24(sp)
    80004be2:	e822                	sd	s0,16(sp)
    80004be4:	e426                	sd	s1,8(sp)
    80004be6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004be8:	00246517          	auipc	a0,0x246
    80004bec:	f3050513          	addi	a0,a0,-208 # 8024ab18 <ftable>
    80004bf0:	8c0fc0ef          	jal	ra,80000cb0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bf4:	00246497          	auipc	s1,0x246
    80004bf8:	f3c48493          	addi	s1,s1,-196 # 8024ab30 <ftable+0x18>
    80004bfc:	00247717          	auipc	a4,0x247
    80004c00:	ed470713          	addi	a4,a4,-300 # 8024bad0 <disk>
    if(f->ref == 0){
    80004c04:	40dc                	lw	a5,4(s1)
    80004c06:	cf89                	beqz	a5,80004c20 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c08:	02848493          	addi	s1,s1,40
    80004c0c:	fee49ce3          	bne	s1,a4,80004c04 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c10:	00246517          	auipc	a0,0x246
    80004c14:	f0850513          	addi	a0,a0,-248 # 8024ab18 <ftable>
    80004c18:	930fc0ef          	jal	ra,80000d48 <release>
  return 0;
    80004c1c:	4481                	li	s1,0
    80004c1e:	a809                	j	80004c30 <filealloc+0x52>
      f->ref = 1;
    80004c20:	4785                	li	a5,1
    80004c22:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c24:	00246517          	auipc	a0,0x246
    80004c28:	ef450513          	addi	a0,a0,-268 # 8024ab18 <ftable>
    80004c2c:	91cfc0ef          	jal	ra,80000d48 <release>
}
    80004c30:	8526                	mv	a0,s1
    80004c32:	60e2                	ld	ra,24(sp)
    80004c34:	6442                	ld	s0,16(sp)
    80004c36:	64a2                	ld	s1,8(sp)
    80004c38:	6105                	addi	sp,sp,32
    80004c3a:	8082                	ret

0000000080004c3c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c3c:	1101                	addi	sp,sp,-32
    80004c3e:	ec06                	sd	ra,24(sp)
    80004c40:	e822                	sd	s0,16(sp)
    80004c42:	e426                	sd	s1,8(sp)
    80004c44:	1000                	addi	s0,sp,32
    80004c46:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c48:	00246517          	auipc	a0,0x246
    80004c4c:	ed050513          	addi	a0,a0,-304 # 8024ab18 <ftable>
    80004c50:	860fc0ef          	jal	ra,80000cb0 <acquire>
  if(f->ref < 1)
    80004c54:	40dc                	lw	a5,4(s1)
    80004c56:	02f05063          	blez	a5,80004c76 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004c5a:	2785                	addiw	a5,a5,1
    80004c5c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c5e:	00246517          	auipc	a0,0x246
    80004c62:	eba50513          	addi	a0,a0,-326 # 8024ab18 <ftable>
    80004c66:	8e2fc0ef          	jal	ra,80000d48 <release>
  return f;
}
    80004c6a:	8526                	mv	a0,s1
    80004c6c:	60e2                	ld	ra,24(sp)
    80004c6e:	6442                	ld	s0,16(sp)
    80004c70:	64a2                	ld	s1,8(sp)
    80004c72:	6105                	addi	sp,sp,32
    80004c74:	8082                	ret
    panic("filedup");
    80004c76:	00004517          	auipc	a0,0x4
    80004c7a:	a4250513          	addi	a0,a0,-1470 # 800086b8 <syscalls+0x2c0>
    80004c7e:	b0dfb0ef          	jal	ra,8000078a <panic>

0000000080004c82 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c82:	7139                	addi	sp,sp,-64
    80004c84:	fc06                	sd	ra,56(sp)
    80004c86:	f822                	sd	s0,48(sp)
    80004c88:	f426                	sd	s1,40(sp)
    80004c8a:	f04a                	sd	s2,32(sp)
    80004c8c:	ec4e                	sd	s3,24(sp)
    80004c8e:	e852                	sd	s4,16(sp)
    80004c90:	e456                	sd	s5,8(sp)
    80004c92:	0080                	addi	s0,sp,64
    80004c94:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c96:	00246517          	auipc	a0,0x246
    80004c9a:	e8250513          	addi	a0,a0,-382 # 8024ab18 <ftable>
    80004c9e:	812fc0ef          	jal	ra,80000cb0 <acquire>
  if(f->ref < 1)
    80004ca2:	40dc                	lw	a5,4(s1)
    80004ca4:	04f05963          	blez	a5,80004cf6 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004ca8:	37fd                	addiw	a5,a5,-1
    80004caa:	0007871b          	sext.w	a4,a5
    80004cae:	c0dc                	sw	a5,4(s1)
    80004cb0:	04e04963          	bgtz	a4,80004d02 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004cb4:	0004a903          	lw	s2,0(s1)
    80004cb8:	0094ca83          	lbu	s5,9(s1)
    80004cbc:	0104ba03          	ld	s4,16(s1)
    80004cc0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004cc4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004cc8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ccc:	00246517          	auipc	a0,0x246
    80004cd0:	e4c50513          	addi	a0,a0,-436 # 8024ab18 <ftable>
    80004cd4:	874fc0ef          	jal	ra,80000d48 <release>

  if(ff.type == FD_PIPE){
    80004cd8:	4785                	li	a5,1
    80004cda:	04f90363          	beq	s2,a5,80004d20 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cde:	3979                	addiw	s2,s2,-2
    80004ce0:	4785                	li	a5,1
    80004ce2:	0327e663          	bltu	a5,s2,80004d0e <fileclose+0x8c>
    begin_op();
    80004ce6:	b8fff0ef          	jal	ra,80004874 <begin_op>
    iput(ff.ip);
    80004cea:	854e                	mv	a0,s3
    80004cec:	b28ff0ef          	jal	ra,80004014 <iput>
    end_op();
    80004cf0:	bf5ff0ef          	jal	ra,800048e4 <end_op>
    80004cf4:	a829                	j	80004d0e <fileclose+0x8c>
    panic("fileclose");
    80004cf6:	00004517          	auipc	a0,0x4
    80004cfa:	9ca50513          	addi	a0,a0,-1590 # 800086c0 <syscalls+0x2c8>
    80004cfe:	a8dfb0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80004d02:	00246517          	auipc	a0,0x246
    80004d06:	e1650513          	addi	a0,a0,-490 # 8024ab18 <ftable>
    80004d0a:	83efc0ef          	jal	ra,80000d48 <release>
  }
}
    80004d0e:	70e2                	ld	ra,56(sp)
    80004d10:	7442                	ld	s0,48(sp)
    80004d12:	74a2                	ld	s1,40(sp)
    80004d14:	7902                	ld	s2,32(sp)
    80004d16:	69e2                	ld	s3,24(sp)
    80004d18:	6a42                	ld	s4,16(sp)
    80004d1a:	6aa2                	ld	s5,8(sp)
    80004d1c:	6121                	addi	sp,sp,64
    80004d1e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d20:	85d6                	mv	a1,s5
    80004d22:	8552                	mv	a0,s4
    80004d24:	2ec000ef          	jal	ra,80005010 <pipeclose>
    80004d28:	b7dd                	j	80004d0e <fileclose+0x8c>

0000000080004d2a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d2a:	715d                	addi	sp,sp,-80
    80004d2c:	e486                	sd	ra,72(sp)
    80004d2e:	e0a2                	sd	s0,64(sp)
    80004d30:	fc26                	sd	s1,56(sp)
    80004d32:	f84a                	sd	s2,48(sp)
    80004d34:	f44e                	sd	s3,40(sp)
    80004d36:	0880                	addi	s0,sp,80
    80004d38:	84aa                	mv	s1,a0
    80004d3a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d3c:	e5ffc0ef          	jal	ra,80001b9a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d40:	409c                	lw	a5,0(s1)
    80004d42:	37f9                	addiw	a5,a5,-2
    80004d44:	4705                	li	a4,1
    80004d46:	02f76f63          	bltu	a4,a5,80004d84 <filestat+0x5a>
    80004d4a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d4c:	6c88                	ld	a0,24(s1)
    80004d4e:	948ff0ef          	jal	ra,80003e96 <ilock>
    stati(f->ip, &st);
    80004d52:	fb840593          	addi	a1,s0,-72
    80004d56:	6c88                	ld	a0,24(s1)
    80004d58:	ca0ff0ef          	jal	ra,800041f8 <stati>
    iunlock(f->ip);
    80004d5c:	6c88                	ld	a0,24(s1)
    80004d5e:	9e2ff0ef          	jal	ra,80003f40 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d62:	46e1                	li	a3,24
    80004d64:	fb840613          	addi	a2,s0,-72
    80004d68:	85ce                	mv	a1,s3
    80004d6a:	05093503          	ld	a0,80(s2)
    80004d6e:	a1dfc0ef          	jal	ra,8000178a <copyout>
    80004d72:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d76:	60a6                	ld	ra,72(sp)
    80004d78:	6406                	ld	s0,64(sp)
    80004d7a:	74e2                	ld	s1,56(sp)
    80004d7c:	7942                	ld	s2,48(sp)
    80004d7e:	79a2                	ld	s3,40(sp)
    80004d80:	6161                	addi	sp,sp,80
    80004d82:	8082                	ret
  return -1;
    80004d84:	557d                	li	a0,-1
    80004d86:	bfc5                	j	80004d76 <filestat+0x4c>

0000000080004d88 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d88:	7179                	addi	sp,sp,-48
    80004d8a:	f406                	sd	ra,40(sp)
    80004d8c:	f022                	sd	s0,32(sp)
    80004d8e:	ec26                	sd	s1,24(sp)
    80004d90:	e84a                	sd	s2,16(sp)
    80004d92:	e44e                	sd	s3,8(sp)
    80004d94:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d96:	00854783          	lbu	a5,8(a0)
    80004d9a:	cbc1                	beqz	a5,80004e2a <fileread+0xa2>
    80004d9c:	84aa                	mv	s1,a0
    80004d9e:	89ae                	mv	s3,a1
    80004da0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004da2:	411c                	lw	a5,0(a0)
    80004da4:	4705                	li	a4,1
    80004da6:	04e78363          	beq	a5,a4,80004dec <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004daa:	470d                	li	a4,3
    80004dac:	04e78563          	beq	a5,a4,80004df6 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004db0:	4709                	li	a4,2
    80004db2:	06e79663          	bne	a5,a4,80004e1e <fileread+0x96>
    ilock(f->ip);
    80004db6:	6d08                	ld	a0,24(a0)
    80004db8:	8deff0ef          	jal	ra,80003e96 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dbc:	874a                	mv	a4,s2
    80004dbe:	5094                	lw	a3,32(s1)
    80004dc0:	864e                	mv	a2,s3
    80004dc2:	4585                	li	a1,1
    80004dc4:	6c88                	ld	a0,24(s1)
    80004dc6:	c5cff0ef          	jal	ra,80004222 <readi>
    80004dca:	892a                	mv	s2,a0
    80004dcc:	00a05563          	blez	a0,80004dd6 <fileread+0x4e>
      f->off += r;
    80004dd0:	509c                	lw	a5,32(s1)
    80004dd2:	9fa9                	addw	a5,a5,a0
    80004dd4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004dd6:	6c88                	ld	a0,24(s1)
    80004dd8:	968ff0ef          	jal	ra,80003f40 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ddc:	854a                	mv	a0,s2
    80004dde:	70a2                	ld	ra,40(sp)
    80004de0:	7402                	ld	s0,32(sp)
    80004de2:	64e2                	ld	s1,24(sp)
    80004de4:	6942                	ld	s2,16(sp)
    80004de6:	69a2                	ld	s3,8(sp)
    80004de8:	6145                	addi	sp,sp,48
    80004dea:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004dec:	6908                	ld	a0,16(a0)
    80004dee:	34e000ef          	jal	ra,8000513c <piperead>
    80004df2:	892a                	mv	s2,a0
    80004df4:	b7e5                	j	80004ddc <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004df6:	02451783          	lh	a5,36(a0)
    80004dfa:	03079693          	slli	a3,a5,0x30
    80004dfe:	92c1                	srli	a3,a3,0x30
    80004e00:	4725                	li	a4,9
    80004e02:	02d76663          	bltu	a4,a3,80004e2e <fileread+0xa6>
    80004e06:	0792                	slli	a5,a5,0x4
    80004e08:	00246717          	auipc	a4,0x246
    80004e0c:	c7070713          	addi	a4,a4,-912 # 8024aa78 <devsw>
    80004e10:	97ba                	add	a5,a5,a4
    80004e12:	639c                	ld	a5,0(a5)
    80004e14:	cf99                	beqz	a5,80004e32 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004e16:	4505                	li	a0,1
    80004e18:	9782                	jalr	a5
    80004e1a:	892a                	mv	s2,a0
    80004e1c:	b7c1                	j	80004ddc <fileread+0x54>
    panic("fileread");
    80004e1e:	00004517          	auipc	a0,0x4
    80004e22:	8b250513          	addi	a0,a0,-1870 # 800086d0 <syscalls+0x2d8>
    80004e26:	965fb0ef          	jal	ra,8000078a <panic>
    return -1;
    80004e2a:	597d                	li	s2,-1
    80004e2c:	bf45                	j	80004ddc <fileread+0x54>
      return -1;
    80004e2e:	597d                	li	s2,-1
    80004e30:	b775                	j	80004ddc <fileread+0x54>
    80004e32:	597d                	li	s2,-1
    80004e34:	b765                	j	80004ddc <fileread+0x54>

0000000080004e36 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e36:	715d                	addi	sp,sp,-80
    80004e38:	e486                	sd	ra,72(sp)
    80004e3a:	e0a2                	sd	s0,64(sp)
    80004e3c:	fc26                	sd	s1,56(sp)
    80004e3e:	f84a                	sd	s2,48(sp)
    80004e40:	f44e                	sd	s3,40(sp)
    80004e42:	f052                	sd	s4,32(sp)
    80004e44:	ec56                	sd	s5,24(sp)
    80004e46:	e85a                	sd	s6,16(sp)
    80004e48:	e45e                	sd	s7,8(sp)
    80004e4a:	e062                	sd	s8,0(sp)
    80004e4c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e4e:	00954783          	lbu	a5,9(a0)
    80004e52:	0e078863          	beqz	a5,80004f42 <filewrite+0x10c>
    80004e56:	892a                	mv	s2,a0
    80004e58:	8aae                	mv	s5,a1
    80004e5a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e5c:	411c                	lw	a5,0(a0)
    80004e5e:	4705                	li	a4,1
    80004e60:	02e78263          	beq	a5,a4,80004e84 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e64:	470d                	li	a4,3
    80004e66:	02e78463          	beq	a5,a4,80004e8e <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e6a:	4709                	li	a4,2
    80004e6c:	0ce79563          	bne	a5,a4,80004f36 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e70:	0ac05163          	blez	a2,80004f12 <filewrite+0xdc>
    int i = 0;
    80004e74:	4981                	li	s3,0
    80004e76:	6b05                	lui	s6,0x1
    80004e78:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e7c:	6b85                	lui	s7,0x1
    80004e7e:	c00b8b9b          	addiw	s7,s7,-1024
    80004e82:	a041                	j	80004f02 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004e84:	6908                	ld	a0,16(a0)
    80004e86:	1e2000ef          	jal	ra,80005068 <pipewrite>
    80004e8a:	8a2a                	mv	s4,a0
    80004e8c:	a071                	j	80004f18 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e8e:	02451783          	lh	a5,36(a0)
    80004e92:	03079693          	slli	a3,a5,0x30
    80004e96:	92c1                	srli	a3,a3,0x30
    80004e98:	4725                	li	a4,9
    80004e9a:	0ad76663          	bltu	a4,a3,80004f46 <filewrite+0x110>
    80004e9e:	0792                	slli	a5,a5,0x4
    80004ea0:	00246717          	auipc	a4,0x246
    80004ea4:	bd870713          	addi	a4,a4,-1064 # 8024aa78 <devsw>
    80004ea8:	97ba                	add	a5,a5,a4
    80004eaa:	679c                	ld	a5,8(a5)
    80004eac:	cfd9                	beqz	a5,80004f4a <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004eae:	4505                	li	a0,1
    80004eb0:	9782                	jalr	a5
    80004eb2:	8a2a                	mv	s4,a0
    80004eb4:	a095                	j	80004f18 <filewrite+0xe2>
    80004eb6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004eba:	9bbff0ef          	jal	ra,80004874 <begin_op>
      ilock(f->ip);
    80004ebe:	01893503          	ld	a0,24(s2)
    80004ec2:	fd5fe0ef          	jal	ra,80003e96 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ec6:	8762                	mv	a4,s8
    80004ec8:	02092683          	lw	a3,32(s2)
    80004ecc:	01598633          	add	a2,s3,s5
    80004ed0:	4585                	li	a1,1
    80004ed2:	01893503          	ld	a0,24(s2)
    80004ed6:	c30ff0ef          	jal	ra,80004306 <writei>
    80004eda:	84aa                	mv	s1,a0
    80004edc:	00a05763          	blez	a0,80004eea <filewrite+0xb4>
        f->off += r;
    80004ee0:	02092783          	lw	a5,32(s2)
    80004ee4:	9fa9                	addw	a5,a5,a0
    80004ee6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004eea:	01893503          	ld	a0,24(s2)
    80004eee:	852ff0ef          	jal	ra,80003f40 <iunlock>
      end_op();
    80004ef2:	9f3ff0ef          	jal	ra,800048e4 <end_op>

      if(r != n1){
    80004ef6:	009c1f63          	bne	s8,s1,80004f14 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004efa:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004efe:	0149db63          	bge	s3,s4,80004f14 <filewrite+0xde>
      int n1 = n - i;
    80004f02:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004f06:	84be                	mv	s1,a5
    80004f08:	2781                	sext.w	a5,a5
    80004f0a:	fafb56e3          	bge	s6,a5,80004eb6 <filewrite+0x80>
    80004f0e:	84de                	mv	s1,s7
    80004f10:	b75d                	j	80004eb6 <filewrite+0x80>
    int i = 0;
    80004f12:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f14:	013a1f63          	bne	s4,s3,80004f32 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f18:	8552                	mv	a0,s4
    80004f1a:	60a6                	ld	ra,72(sp)
    80004f1c:	6406                	ld	s0,64(sp)
    80004f1e:	74e2                	ld	s1,56(sp)
    80004f20:	7942                	ld	s2,48(sp)
    80004f22:	79a2                	ld	s3,40(sp)
    80004f24:	7a02                	ld	s4,32(sp)
    80004f26:	6ae2                	ld	s5,24(sp)
    80004f28:	6b42                	ld	s6,16(sp)
    80004f2a:	6ba2                	ld	s7,8(sp)
    80004f2c:	6c02                	ld	s8,0(sp)
    80004f2e:	6161                	addi	sp,sp,80
    80004f30:	8082                	ret
    ret = (i == n ? n : -1);
    80004f32:	5a7d                	li	s4,-1
    80004f34:	b7d5                	j	80004f18 <filewrite+0xe2>
    panic("filewrite");
    80004f36:	00003517          	auipc	a0,0x3
    80004f3a:	7aa50513          	addi	a0,a0,1962 # 800086e0 <syscalls+0x2e8>
    80004f3e:	84dfb0ef          	jal	ra,8000078a <panic>
    return -1;
    80004f42:	5a7d                	li	s4,-1
    80004f44:	bfd1                	j	80004f18 <filewrite+0xe2>
      return -1;
    80004f46:	5a7d                	li	s4,-1
    80004f48:	bfc1                	j	80004f18 <filewrite+0xe2>
    80004f4a:	5a7d                	li	s4,-1
    80004f4c:	b7f1                	j	80004f18 <filewrite+0xe2>

0000000080004f4e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f4e:	7179                	addi	sp,sp,-48
    80004f50:	f406                	sd	ra,40(sp)
    80004f52:	f022                	sd	s0,32(sp)
    80004f54:	ec26                	sd	s1,24(sp)
    80004f56:	e84a                	sd	s2,16(sp)
    80004f58:	e44e                	sd	s3,8(sp)
    80004f5a:	e052                	sd	s4,0(sp)
    80004f5c:	1800                	addi	s0,sp,48
    80004f5e:	84aa                	mv	s1,a0
    80004f60:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f62:	0005b023          	sd	zero,0(a1)
    80004f66:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f6a:	c75ff0ef          	jal	ra,80004bde <filealloc>
    80004f6e:	e088                	sd	a0,0(s1)
    80004f70:	cd35                	beqz	a0,80004fec <pipealloc+0x9e>
    80004f72:	c6dff0ef          	jal	ra,80004bde <filealloc>
    80004f76:	00aa3023          	sd	a0,0(s4)
    80004f7a:	c52d                	beqz	a0,80004fe4 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f7c:	c31fb0ef          	jal	ra,80000bac <kalloc>
    80004f80:	892a                	mv	s2,a0
    80004f82:	cd31                	beqz	a0,80004fde <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004f84:	4985                	li	s3,1
    80004f86:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f8a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f8e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f92:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f96:	00003597          	auipc	a1,0x3
    80004f9a:	75a58593          	addi	a1,a1,1882 # 800086f0 <syscalls+0x2f8>
    80004f9e:	c93fb0ef          	jal	ra,80000c30 <initlock>
  (*f0)->type = FD_PIPE;
    80004fa2:	609c                	ld	a5,0(s1)
    80004fa4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004fa8:	609c                	ld	a5,0(s1)
    80004faa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004fae:	609c                	ld	a5,0(s1)
    80004fb0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004fb4:	609c                	ld	a5,0(s1)
    80004fb6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004fba:	000a3783          	ld	a5,0(s4)
    80004fbe:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004fc2:	000a3783          	ld	a5,0(s4)
    80004fc6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004fca:	000a3783          	ld	a5,0(s4)
    80004fce:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004fd2:	000a3783          	ld	a5,0(s4)
    80004fd6:	0127b823          	sd	s2,16(a5)
  return 0;
    80004fda:	4501                	li	a0,0
    80004fdc:	a005                	j	80004ffc <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004fde:	6088                	ld	a0,0(s1)
    80004fe0:	e501                	bnez	a0,80004fe8 <pipealloc+0x9a>
    80004fe2:	a029                	j	80004fec <pipealloc+0x9e>
    80004fe4:	6088                	ld	a0,0(s1)
    80004fe6:	c11d                	beqz	a0,8000500c <pipealloc+0xbe>
    fileclose(*f0);
    80004fe8:	c9bff0ef          	jal	ra,80004c82 <fileclose>
  if(*f1)
    80004fec:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ff0:	557d                	li	a0,-1
  if(*f1)
    80004ff2:	c789                	beqz	a5,80004ffc <pipealloc+0xae>
    fileclose(*f1);
    80004ff4:	853e                	mv	a0,a5
    80004ff6:	c8dff0ef          	jal	ra,80004c82 <fileclose>
  return -1;
    80004ffa:	557d                	li	a0,-1
}
    80004ffc:	70a2                	ld	ra,40(sp)
    80004ffe:	7402                	ld	s0,32(sp)
    80005000:	64e2                	ld	s1,24(sp)
    80005002:	6942                	ld	s2,16(sp)
    80005004:	69a2                	ld	s3,8(sp)
    80005006:	6a02                	ld	s4,0(sp)
    80005008:	6145                	addi	sp,sp,48
    8000500a:	8082                	ret
  return -1;
    8000500c:	557d                	li	a0,-1
    8000500e:	b7fd                	j	80004ffc <pipealloc+0xae>

0000000080005010 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005010:	1101                	addi	sp,sp,-32
    80005012:	ec06                	sd	ra,24(sp)
    80005014:	e822                	sd	s0,16(sp)
    80005016:	e426                	sd	s1,8(sp)
    80005018:	e04a                	sd	s2,0(sp)
    8000501a:	1000                	addi	s0,sp,32
    8000501c:	84aa                	mv	s1,a0
    8000501e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005020:	c91fb0ef          	jal	ra,80000cb0 <acquire>
  if(writable){
    80005024:	02090763          	beqz	s2,80005052 <pipeclose+0x42>
    pi->writeopen = 0;
    80005028:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000502c:	21848513          	addi	a0,s1,536
    80005030:	caefd0ef          	jal	ra,800024de <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005034:	2204b783          	ld	a5,544(s1)
    80005038:	e785                	bnez	a5,80005060 <pipeclose+0x50>
    release(&pi->lock);
    8000503a:	8526                	mv	a0,s1
    8000503c:	d0dfb0ef          	jal	ra,80000d48 <release>
    kfree((char*)pi);
    80005040:	8526                	mv	a0,s1
    80005042:	a3dfb0ef          	jal	ra,80000a7e <kfree>
  } else
    release(&pi->lock);
}
    80005046:	60e2                	ld	ra,24(sp)
    80005048:	6442                	ld	s0,16(sp)
    8000504a:	64a2                	ld	s1,8(sp)
    8000504c:	6902                	ld	s2,0(sp)
    8000504e:	6105                	addi	sp,sp,32
    80005050:	8082                	ret
    pi->readopen = 0;
    80005052:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005056:	21c48513          	addi	a0,s1,540
    8000505a:	c84fd0ef          	jal	ra,800024de <wakeup>
    8000505e:	bfd9                	j	80005034 <pipeclose+0x24>
    release(&pi->lock);
    80005060:	8526                	mv	a0,s1
    80005062:	ce7fb0ef          	jal	ra,80000d48 <release>
}
    80005066:	b7c5                	j	80005046 <pipeclose+0x36>

0000000080005068 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005068:	711d                	addi	sp,sp,-96
    8000506a:	ec86                	sd	ra,88(sp)
    8000506c:	e8a2                	sd	s0,80(sp)
    8000506e:	e4a6                	sd	s1,72(sp)
    80005070:	e0ca                	sd	s2,64(sp)
    80005072:	fc4e                	sd	s3,56(sp)
    80005074:	f852                	sd	s4,48(sp)
    80005076:	f456                	sd	s5,40(sp)
    80005078:	f05a                	sd	s6,32(sp)
    8000507a:	ec5e                	sd	s7,24(sp)
    8000507c:	e862                	sd	s8,16(sp)
    8000507e:	1080                	addi	s0,sp,96
    80005080:	84aa                	mv	s1,a0
    80005082:	8aae                	mv	s5,a1
    80005084:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005086:	b15fc0ef          	jal	ra,80001b9a <myproc>
    8000508a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000508c:	8526                	mv	a0,s1
    8000508e:	c23fb0ef          	jal	ra,80000cb0 <acquire>
  while(i < n){
    80005092:	09405c63          	blez	s4,8000512a <pipewrite+0xc2>
  int i = 0;
    80005096:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005098:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000509a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000509e:	21c48b93          	addi	s7,s1,540
    800050a2:	a81d                	j	800050d8 <pipewrite+0x70>
      release(&pi->lock);
    800050a4:	8526                	mv	a0,s1
    800050a6:	ca3fb0ef          	jal	ra,80000d48 <release>
      return -1;
    800050aa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050ac:	854a                	mv	a0,s2
    800050ae:	60e6                	ld	ra,88(sp)
    800050b0:	6446                	ld	s0,80(sp)
    800050b2:	64a6                	ld	s1,72(sp)
    800050b4:	6906                	ld	s2,64(sp)
    800050b6:	79e2                	ld	s3,56(sp)
    800050b8:	7a42                	ld	s4,48(sp)
    800050ba:	7aa2                	ld	s5,40(sp)
    800050bc:	7b02                	ld	s6,32(sp)
    800050be:	6be2                	ld	s7,24(sp)
    800050c0:	6c42                	ld	s8,16(sp)
    800050c2:	6125                	addi	sp,sp,96
    800050c4:	8082                	ret
      wakeup(&pi->nread);
    800050c6:	8562                	mv	a0,s8
    800050c8:	c16fd0ef          	jal	ra,800024de <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050cc:	85a6                	mv	a1,s1
    800050ce:	855e                	mv	a0,s7
    800050d0:	bc2fd0ef          	jal	ra,80002492 <sleep>
  while(i < n){
    800050d4:	05495c63          	bge	s2,s4,8000512c <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800050d8:	2204a783          	lw	a5,544(s1)
    800050dc:	d7e1                	beqz	a5,800050a4 <pipewrite+0x3c>
    800050de:	854e                	mv	a0,s3
    800050e0:	deafd0ef          	jal	ra,800026ca <killed>
    800050e4:	f161                	bnez	a0,800050a4 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050e6:	2184a783          	lw	a5,536(s1)
    800050ea:	21c4a703          	lw	a4,540(s1)
    800050ee:	2007879b          	addiw	a5,a5,512
    800050f2:	fcf70ae3          	beq	a4,a5,800050c6 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050f6:	4685                	li	a3,1
    800050f8:	01590633          	add	a2,s2,s5
    800050fc:	faf40593          	addi	a1,s0,-81
    80005100:	0509b503          	ld	a0,80(s3)
    80005104:	f96fc0ef          	jal	ra,8000189a <copyin>
    80005108:	03650263          	beq	a0,s6,8000512c <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000510c:	21c4a783          	lw	a5,540(s1)
    80005110:	0017871b          	addiw	a4,a5,1
    80005114:	20e4ae23          	sw	a4,540(s1)
    80005118:	1ff7f793          	andi	a5,a5,511
    8000511c:	97a6                	add	a5,a5,s1
    8000511e:	faf44703          	lbu	a4,-81(s0)
    80005122:	00e78c23          	sb	a4,24(a5)
      i++;
    80005126:	2905                	addiw	s2,s2,1
    80005128:	b775                	j	800050d4 <pipewrite+0x6c>
  int i = 0;
    8000512a:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000512c:	21848513          	addi	a0,s1,536
    80005130:	baefd0ef          	jal	ra,800024de <wakeup>
  release(&pi->lock);
    80005134:	8526                	mv	a0,s1
    80005136:	c13fb0ef          	jal	ra,80000d48 <release>
  return i;
    8000513a:	bf8d                	j	800050ac <pipewrite+0x44>

000000008000513c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000513c:	715d                	addi	sp,sp,-80
    8000513e:	e486                	sd	ra,72(sp)
    80005140:	e0a2                	sd	s0,64(sp)
    80005142:	fc26                	sd	s1,56(sp)
    80005144:	f84a                	sd	s2,48(sp)
    80005146:	f44e                	sd	s3,40(sp)
    80005148:	f052                	sd	s4,32(sp)
    8000514a:	ec56                	sd	s5,24(sp)
    8000514c:	e85a                	sd	s6,16(sp)
    8000514e:	0880                	addi	s0,sp,80
    80005150:	84aa                	mv	s1,a0
    80005152:	892e                	mv	s2,a1
    80005154:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005156:	a45fc0ef          	jal	ra,80001b9a <myproc>
    8000515a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000515c:	8526                	mv	a0,s1
    8000515e:	b53fb0ef          	jal	ra,80000cb0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005162:	2184a703          	lw	a4,536(s1)
    80005166:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000516a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000516e:	02f71363          	bne	a4,a5,80005194 <piperead+0x58>
    80005172:	2244a783          	lw	a5,548(s1)
    80005176:	cf99                	beqz	a5,80005194 <piperead+0x58>
    if(killed(pr)){
    80005178:	8552                	mv	a0,s4
    8000517a:	d50fd0ef          	jal	ra,800026ca <killed>
    8000517e:	e149                	bnez	a0,80005200 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005180:	85a6                	mv	a1,s1
    80005182:	854e                	mv	a0,s3
    80005184:	b0efd0ef          	jal	ra,80002492 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005188:	2184a703          	lw	a4,536(s1)
    8000518c:	21c4a783          	lw	a5,540(s1)
    80005190:	fef701e3          	beq	a4,a5,80005172 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005194:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005196:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005198:	05505263          	blez	s5,800051dc <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    8000519c:	2184a783          	lw	a5,536(s1)
    800051a0:	21c4a703          	lw	a4,540(s1)
    800051a4:	02f70c63          	beq	a4,a5,800051dc <piperead+0xa0>
    ch = pi->data[pi->nread % PIPESIZE];
    800051a8:	1ff7f793          	andi	a5,a5,511
    800051ac:	97a6                	add	a5,a5,s1
    800051ae:	0187c783          	lbu	a5,24(a5)
    800051b2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800051b6:	4685                	li	a3,1
    800051b8:	fbf40613          	addi	a2,s0,-65
    800051bc:	85ca                	mv	a1,s2
    800051be:	050a3503          	ld	a0,80(s4)
    800051c2:	dc8fc0ef          	jal	ra,8000178a <copyout>
    800051c6:	05650263          	beq	a0,s6,8000520a <piperead+0xce>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800051ca:	2184a783          	lw	a5,536(s1)
    800051ce:	2785                	addiw	a5,a5,1
    800051d0:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051d4:	2985                	addiw	s3,s3,1
    800051d6:	0905                	addi	s2,s2,1
    800051d8:	fd3a92e3          	bne	s5,s3,8000519c <piperead+0x60>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051dc:	21c48513          	addi	a0,s1,540
    800051e0:	afefd0ef          	jal	ra,800024de <wakeup>
  release(&pi->lock);
    800051e4:	8526                	mv	a0,s1
    800051e6:	b63fb0ef          	jal	ra,80000d48 <release>
  return i;
}
    800051ea:	854e                	mv	a0,s3
    800051ec:	60a6                	ld	ra,72(sp)
    800051ee:	6406                	ld	s0,64(sp)
    800051f0:	74e2                	ld	s1,56(sp)
    800051f2:	7942                	ld	s2,48(sp)
    800051f4:	79a2                	ld	s3,40(sp)
    800051f6:	7a02                	ld	s4,32(sp)
    800051f8:	6ae2                	ld	s5,24(sp)
    800051fa:	6b42                	ld	s6,16(sp)
    800051fc:	6161                	addi	sp,sp,80
    800051fe:	8082                	ret
      release(&pi->lock);
    80005200:	8526                	mv	a0,s1
    80005202:	b47fb0ef          	jal	ra,80000d48 <release>
      return -1;
    80005206:	59fd                	li	s3,-1
    80005208:	b7cd                	j	800051ea <piperead+0xae>
      if(i == 0)
    8000520a:	fc0999e3          	bnez	s3,800051dc <piperead+0xa0>
        i = -1;
    8000520e:	89aa                	mv	s3,a0
    80005210:	b7f1                	j	800051dc <piperead+0xa0>

0000000080005212 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005212:	1141                	addi	sp,sp,-16
    80005214:	e422                	sd	s0,8(sp)
    80005216:	0800                	addi	s0,sp,16
    80005218:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000521a:	8905                	andi	a0,a0,1
    8000521c:	c111                	beqz	a0,80005220 <flags2perm+0xe>
      perm = PTE_X;
    8000521e:	4521                	li	a0,8
    if(flags & 0x2)
    80005220:	8b89                	andi	a5,a5,2
    80005222:	c399                	beqz	a5,80005228 <flags2perm+0x16>
      perm |= PTE_W;
    80005224:	00456513          	ori	a0,a0,4
    return perm;
}
    80005228:	6422                	ld	s0,8(sp)
    8000522a:	0141                	addi	sp,sp,16
    8000522c:	8082                	ret

000000008000522e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000522e:	b5010113          	addi	sp,sp,-1200
    80005232:	4a113423          	sd	ra,1192(sp)
    80005236:	4a813023          	sd	s0,1184(sp)
    8000523a:	48913c23          	sd	s1,1176(sp)
    8000523e:	49213823          	sd	s2,1168(sp)
    80005242:	49313423          	sd	s3,1160(sp)
    80005246:	49413023          	sd	s4,1152(sp)
    8000524a:	47513c23          	sd	s5,1144(sp)
    8000524e:	47613823          	sd	s6,1136(sp)
    80005252:	47713423          	sd	s7,1128(sp)
    80005256:	47813023          	sd	s8,1120(sp)
    8000525a:	45913c23          	sd	s9,1112(sp)
    8000525e:	45a13823          	sd	s10,1104(sp)
    80005262:	45b13423          	sd	s11,1096(sp)
    80005266:	4b010413          	addi	s0,sp,1200
    8000526a:	84aa                	mv	s1,a0
    8000526c:	b6a43023          	sd	a0,-1184(s0)
    80005270:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005274:	927fc0ef          	jal	ra,80001b9a <myproc>
    80005278:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    8000527c:	df8ff0ef          	jal	ra,80004874 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80005280:	8526                	mv	a0,s1
    80005282:	c02ff0ef          	jal	ra,80004684 <namei>
    80005286:	cd25                	beqz	a0,800052fe <kexec+0xd0>
    80005288:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000528a:	c0dfe0ef          	jal	ra,80003e96 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000528e:	04000713          	li	a4,64
    80005292:	4681                	li	a3,0
    80005294:	e5040613          	addi	a2,s0,-432
    80005298:	4581                	li	a1,0
    8000529a:	8556                	mv	a0,s5
    8000529c:	f87fe0ef          	jal	ra,80004222 <readi>
    800052a0:	04000793          	li	a5,64
    800052a4:	00f51a63          	bne	a0,a5,800052b8 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800052a8:	e5042703          	lw	a4,-432(s0)
    800052ac:	464c47b7          	lui	a5,0x464c4
    800052b0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052b4:	04f70963          	beq	a4,a5,80005306 <kexec+0xd8>
    memset(p->vmas, 0, sizeof(p->vmas));
    vma_release_all(p);
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    800052b8:	8556                	mv	a0,s5
    800052ba:	de3fe0ef          	jal	ra,8000409c <iunlockput>
    end_op();
    800052be:	e26ff0ef          	jal	ra,800048e4 <end_op>
  }
  return -1;
    800052c2:	557d                	li	a0,-1
}
    800052c4:	4a813083          	ld	ra,1192(sp)
    800052c8:	4a013403          	ld	s0,1184(sp)
    800052cc:	49813483          	ld	s1,1176(sp)
    800052d0:	49013903          	ld	s2,1168(sp)
    800052d4:	48813983          	ld	s3,1160(sp)
    800052d8:	48013a03          	ld	s4,1152(sp)
    800052dc:	47813a83          	ld	s5,1144(sp)
    800052e0:	47013b03          	ld	s6,1136(sp)
    800052e4:	46813b83          	ld	s7,1128(sp)
    800052e8:	46013c03          	ld	s8,1120(sp)
    800052ec:	45813c83          	ld	s9,1112(sp)
    800052f0:	45013d03          	ld	s10,1104(sp)
    800052f4:	44813d83          	ld	s11,1096(sp)
    800052f8:	4b010113          	addi	sp,sp,1200
    800052fc:	8082                	ret
    end_op();
    800052fe:	de6ff0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005302:	557d                	li	a0,-1
    80005304:	b7c1                	j	800052c4 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80005306:	b7843503          	ld	a0,-1160(s0)
    8000530a:	b85fc0ef          	jal	ra,80001e8e <proc_pagetable>
    8000530e:	8baa                	mv	s7,a0
    80005310:	d545                	beqz	a0,800052b8 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005312:	e7042783          	lw	a5,-400(s0)
    80005316:	e8845703          	lhu	a4,-376(s0)
    8000531a:	0e070d63          	beqz	a4,80005414 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000531e:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005322:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005326:	6a05                	lui	s4,0x1
    80005328:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000532c:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005330:	6d85                	lui	s11,0x1
    80005332:	7d7d                	lui	s10,0xfffff
    80005334:	a09d                	j	8000539a <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005336:	00003517          	auipc	a0,0x3
    8000533a:	3c250513          	addi	a0,a0,962 # 800086f8 <syscalls+0x300>
    8000533e:	c4cfb0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005342:	874a                	mv	a4,s2
    80005344:	009c86bb          	addw	a3,s9,s1
    80005348:	4581                	li	a1,0
    8000534a:	8556                	mv	a0,s5
    8000534c:	ed7fe0ef          	jal	ra,80004222 <readi>
    80005350:	2501                	sext.w	a0,a0
    80005352:	0ea91e63          	bne	s2,a0,8000544e <kexec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80005356:	009d84bb          	addw	s1,s11,s1
    8000535a:	013d09bb          	addw	s3,s10,s3
    8000535e:	0364f063          	bgeu	s1,s6,8000537e <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80005362:	02049593          	slli	a1,s1,0x20
    80005366:	9181                	srli	a1,a1,0x20
    80005368:	95e2                	add	a1,a1,s8
    8000536a:	855e                	mv	a0,s7
    8000536c:	d3bfb0ef          	jal	ra,800010a6 <walkaddr>
    80005370:	862a                	mv	a2,a0
    if(pa == 0)
    80005372:	d171                	beqz	a0,80005336 <kexec+0x108>
      n = PGSIZE;
    80005374:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005376:	fd49f6e3          	bgeu	s3,s4,80005342 <kexec+0x114>
      n = sz - i;
    8000537a:	894e                	mv	s2,s3
    8000537c:	b7d9                	j	80005342 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000537e:	b8843783          	ld	a5,-1144(s0)
    80005382:	0017869b          	addiw	a3,a5,1
    80005386:	b8d43423          	sd	a3,-1144(s0)
    8000538a:	b8043783          	ld	a5,-1152(s0)
    8000538e:	0387879b          	addiw	a5,a5,56
    80005392:	e8845703          	lhu	a4,-376(s0)
    80005396:	08e6d163          	bge	a3,a4,80005418 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000539a:	2781                	sext.w	a5,a5
    8000539c:	b8f43023          	sd	a5,-1152(s0)
    800053a0:	03800713          	li	a4,56
    800053a4:	86be                	mv	a3,a5
    800053a6:	e1840613          	addi	a2,s0,-488
    800053aa:	4581                	li	a1,0
    800053ac:	8556                	mv	a0,s5
    800053ae:	e75fe0ef          	jal	ra,80004222 <readi>
    800053b2:	03800793          	li	a5,56
    800053b6:	08f51c63          	bne	a0,a5,8000544e <kexec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    800053ba:	e1842783          	lw	a5,-488(s0)
    800053be:	4705                	li	a4,1
    800053c0:	fae79fe3          	bne	a5,a4,8000537e <kexec+0x150>
    if(ph.memsz < ph.filesz)
    800053c4:	e4043483          	ld	s1,-448(s0)
    800053c8:	e3843783          	ld	a5,-456(s0)
    800053cc:	08f4e163          	bltu	s1,a5,8000544e <kexec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053d0:	e2843783          	ld	a5,-472(s0)
    800053d4:	94be                	add	s1,s1,a5
    800053d6:	06f4ec63          	bltu	s1,a5,8000544e <kexec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    800053da:	b5843703          	ld	a4,-1192(s0)
    800053de:	8ff9                	and	a5,a5,a4
    800053e0:	e7bd                	bnez	a5,8000544e <kexec+0x220>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053e2:	e1c42503          	lw	a0,-484(s0)
    800053e6:	e2dff0ef          	jal	ra,80005212 <flags2perm>
    800053ea:	86aa                	mv	a3,a0
    800053ec:	8626                	mv	a2,s1
    800053ee:	b7043583          	ld	a1,-1168(s0)
    800053f2:	855e                	mv	a0,s7
    800053f4:	f7dfb0ef          	jal	ra,80001370 <uvmalloc>
    800053f8:	b6a43823          	sd	a0,-1168(s0)
    800053fc:	c929                	beqz	a0,8000544e <kexec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053fe:	e2843c03          	ld	s8,-472(s0)
    80005402:	e2042c83          	lw	s9,-480(s0)
    80005406:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000540a:	f60b0ae3          	beqz	s6,8000537e <kexec+0x150>
    8000540e:	89da                	mv	s3,s6
    80005410:	4481                	li	s1,0
    80005412:	bf81                	j	80005362 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005414:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    80005418:	8556                	mv	a0,s5
    8000541a:	c83fe0ef          	jal	ra,8000409c <iunlockput>
  end_op();
    8000541e:	cc6ff0ef          	jal	ra,800048e4 <end_op>
  p = myproc();
    80005422:	f78fc0ef          	jal	ra,80001b9a <myproc>
    80005426:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    8000542a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000542e:	6585                	lui	a1,0x1
    80005430:	15fd                	addi	a1,a1,-1
    80005432:	b7043783          	ld	a5,-1168(s0)
    80005436:	95be                	add	a1,a1,a5
    80005438:	77fd                	lui	a5,0xfffff
    8000543a:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000543c:	4691                	li	a3,4
    8000543e:	6609                	lui	a2,0x2
    80005440:	962e                	add	a2,a2,a1
    80005442:	855e                	mv	a0,s7
    80005444:	f2dfb0ef          	jal	ra,80001370 <uvmalloc>
    80005448:	8b2a                	mv	s6,a0
  ip = 0;
    8000544a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000544c:	e121                	bnez	a0,8000548c <kexec+0x25e>
    delete_shm_from_proc(p);
    8000544e:	b7843903          	ld	s2,-1160(s0)
    80005452:	854a                	mv	a0,s2
    80005454:	8cbfc0ef          	jal	ra,80001d1e <delete_shm_from_proc>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80005458:	16890493          	addi	s1,s2,360
    8000545c:	85a6                	mv	a1,s1
    8000545e:	05093503          	ld	a0,80(s2)
    80005462:	ab1fc0ef          	jal	ra,80001f12 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80005466:	28000613          	li	a2,640
    8000546a:	4581                	li	a1,0
    8000546c:	8526                	mv	a0,s1
    8000546e:	917fb0ef          	jal	ra,80000d84 <memset>
    vma_release_all(p);
    80005472:	854a                	mv	a0,s2
    80005474:	92bfc0ef          	jal	ra,80001d9e <vma_release_all>
    proc_freepagetable(p->pagetable, p->sz);
    80005478:	04893583          	ld	a1,72(s2)
    8000547c:	05093503          	ld	a0,80(s2)
    80005480:	addfc0ef          	jal	ra,80001f5c <proc_freepagetable>
  if(ip){
    80005484:	e20a9ae3          	bnez	s5,800052b8 <kexec+0x8a>
  return -1;
    80005488:	557d                	li	a0,-1
    8000548a:	bd2d                	j	800052c4 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000548c:	75f9                	lui	a1,0xffffe
    8000548e:	95aa                	add	a1,a1,a0
    80005490:	855e                	mv	a0,s7
    80005492:	98cfc0ef          	jal	ra,8000161e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80005496:	7c7d                	lui	s8,0xfffff
    80005498:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000549a:	b6843783          	ld	a5,-1176(s0)
    8000549e:	6388                	ld	a0,0(a5)
    800054a0:	c125                	beqz	a0,80005500 <kexec+0x2d2>
    800054a2:	e9040993          	addi	s3,s0,-368
    800054a6:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    800054aa:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800054ac:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800054ae:	a4ffb0ef          	jal	ra,80000efc <strlen>
    800054b2:	0015079b          	addiw	a5,a0,1
    800054b6:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054ba:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800054be:	11896d63          	bltu	s2,s8,800055d8 <kexec+0x3aa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054c2:	b6843d03          	ld	s10,-1176(s0)
    800054c6:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdaae10>
    800054ca:	8552                	mv	a0,s4
    800054cc:	a31fb0ef          	jal	ra,80000efc <strlen>
    800054d0:	0015069b          	addiw	a3,a0,1
    800054d4:	8652                	mv	a2,s4
    800054d6:	85ca                	mv	a1,s2
    800054d8:	855e                	mv	a0,s7
    800054da:	ab0fc0ef          	jal	ra,8000178a <copyout>
    800054de:	0e054f63          	bltz	a0,800055dc <kexec+0x3ae>
    ustack[argc] = sp;
    800054e2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800054e6:	0485                	addi	s1,s1,1
    800054e8:	008d0793          	addi	a5,s10,8
    800054ec:	b6f43423          	sd	a5,-1176(s0)
    800054f0:	008d3503          	ld	a0,8(s10)
    800054f4:	c901                	beqz	a0,80005504 <kexec+0x2d6>
    if(argc >= MAXARG)
    800054f6:	09a1                	addi	s3,s3,8
    800054f8:	fb599be3          	bne	s3,s5,800054ae <kexec+0x280>
  ip = 0;
    800054fc:	4a81                	li	s5,0
    800054fe:	bf81                	j	8000544e <kexec+0x220>
  sp = sz;
    80005500:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005502:	4481                	li	s1,0
  ustack[argc] = 0;
    80005504:	00349793          	slli	a5,s1,0x3
    80005508:	f9040713          	addi	a4,s0,-112
    8000550c:	97ba                	add	a5,a5,a4
    8000550e:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7fdaad10>
  sp -= (argc+1) * sizeof(uint64);
    80005512:	00148693          	addi	a3,s1,1
    80005516:	068e                	slli	a3,a3,0x3
    80005518:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000551c:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005520:	4a81                	li	s5,0
  if(sp < stackbase)
    80005522:	f38966e3          	bltu	s2,s8,8000544e <kexec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005526:	e9040613          	addi	a2,s0,-368
    8000552a:	85ca                	mv	a1,s2
    8000552c:	855e                	mv	a0,s7
    8000552e:	a5cfc0ef          	jal	ra,8000178a <copyout>
    80005532:	0a054763          	bltz	a0,800055e0 <kexec+0x3b2>
  p->trapframe->a1 = sp;
    80005536:	b7843783          	ld	a5,-1160(s0)
    8000553a:	6fbc                	ld	a5,88(a5)
    8000553c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005540:	b6043783          	ld	a5,-1184(s0)
    80005544:	0007c703          	lbu	a4,0(a5)
    80005548:	cf11                	beqz	a4,80005564 <kexec+0x336>
    8000554a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000554c:	02f00693          	li	a3,47
    80005550:	a039                	j	8000555e <kexec+0x330>
      last = s+1;
    80005552:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    80005556:	0785                	addi	a5,a5,1
    80005558:	fff7c703          	lbu	a4,-1(a5)
    8000555c:	c701                	beqz	a4,80005564 <kexec+0x336>
    if(*s == '/')
    8000555e:	fed71ce3          	bne	a4,a3,80005556 <kexec+0x328>
    80005562:	bfc5                	j	80005552 <kexec+0x324>
  safestrcpy(p->name, last, sizeof(p->name));
    80005564:	4641                	li	a2,16
    80005566:	b6043583          	ld	a1,-1184(s0)
    8000556a:	b7843a83          	ld	s5,-1160(s0)
    8000556e:	158a8513          	addi	a0,s5,344
    80005572:	959fb0ef          	jal	ra,80000eca <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    80005576:	168a8a13          	addi	s4,s5,360
    8000557a:	28000613          	li	a2,640
    8000557e:	85d2                	mv	a1,s4
    80005580:	b9840513          	addi	a0,s0,-1128
    80005584:	85dfb0ef          	jal	ra,80000de0 <memmove>
  oldpagetable = p->pagetable;
    80005588:	050ab983          	ld	s3,80(s5)
  vma_release_all(p);
    8000558c:	8556                	mv	a0,s5
    8000558e:	811fc0ef          	jal	ra,80001d9e <vma_release_all>
  p->pagetable = pagetable;
    80005592:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005596:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;
    8000559a:	058ab783          	ld	a5,88(s5)
    8000559e:	e6843703          	ld	a4,-408(s0)
    800055a2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    800055a4:	058ab783          	ld	a5,88(s5)
    800055a8:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    800055ac:	28000613          	li	a2,640
    800055b0:	4581                	li	a1,0
    800055b2:	8552                	mv	a0,s4
    800055b4:	fd0fb0ef          	jal	ra,80000d84 <memset>
  delete_shm_from_vmas(oldvmas);
    800055b8:	b9840513          	addi	a0,s0,-1128
    800055bc:	ee4fc0ef          	jal	ra,80001ca0 <delete_shm_from_vmas>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    800055c0:	b9840593          	addi	a1,s0,-1128
    800055c4:	854e                	mv	a0,s3
    800055c6:	94dfc0ef          	jal	ra,80001f12 <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    800055ca:	85e6                	mv	a1,s9
    800055cc:	854e                	mv	a0,s3
    800055ce:	98ffc0ef          	jal	ra,80001f5c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800055d2:	0004851b          	sext.w	a0,s1
    800055d6:	b1fd                	j	800052c4 <kexec+0x96>
  ip = 0;
    800055d8:	4a81                	li	s5,0
    800055da:	bd95                	j	8000544e <kexec+0x220>
    800055dc:	4a81                	li	s5,0
    800055de:	bd85                	j	8000544e <kexec+0x220>
    800055e0:	4a81                	li	s5,0
    800055e2:	b5b5                	j	8000544e <kexec+0x220>

00000000800055e4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055e4:	7179                	addi	sp,sp,-48
    800055e6:	f406                	sd	ra,40(sp)
    800055e8:	f022                	sd	s0,32(sp)
    800055ea:	ec26                	sd	s1,24(sp)
    800055ec:	e84a                	sd	s2,16(sp)
    800055ee:	1800                	addi	s0,sp,48
    800055f0:	892e                	mv	s2,a1
    800055f2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800055f4:	fdc40593          	addi	a1,s0,-36
    800055f8:	fd0fd0ef          	jal	ra,80002dc8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055fc:	fdc42703          	lw	a4,-36(s0)
    80005600:	47bd                	li	a5,15
    80005602:	02e7e963          	bltu	a5,a4,80005634 <argfd+0x50>
    80005606:	d94fc0ef          	jal	ra,80001b9a <myproc>
    8000560a:	fdc42703          	lw	a4,-36(s0)
    8000560e:	01a70793          	addi	a5,a4,26
    80005612:	078e                	slli	a5,a5,0x3
    80005614:	953e                	add	a0,a0,a5
    80005616:	611c                	ld	a5,0(a0)
    80005618:	c385                	beqz	a5,80005638 <argfd+0x54>
    return -1;
  if(pfd)
    8000561a:	00090463          	beqz	s2,80005622 <argfd+0x3e>
    *pfd = fd;
    8000561e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005622:	4501                	li	a0,0
  if(pf)
    80005624:	c091                	beqz	s1,80005628 <argfd+0x44>
    *pf = f;
    80005626:	e09c                	sd	a5,0(s1)
}
    80005628:	70a2                	ld	ra,40(sp)
    8000562a:	7402                	ld	s0,32(sp)
    8000562c:	64e2                	ld	s1,24(sp)
    8000562e:	6942                	ld	s2,16(sp)
    80005630:	6145                	addi	sp,sp,48
    80005632:	8082                	ret
    return -1;
    80005634:	557d                	li	a0,-1
    80005636:	bfcd                	j	80005628 <argfd+0x44>
    80005638:	557d                	li	a0,-1
    8000563a:	b7fd                	j	80005628 <argfd+0x44>

000000008000563c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000563c:	1101                	addi	sp,sp,-32
    8000563e:	ec06                	sd	ra,24(sp)
    80005640:	e822                	sd	s0,16(sp)
    80005642:	e426                	sd	s1,8(sp)
    80005644:	1000                	addi	s0,sp,32
    80005646:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005648:	d52fc0ef          	jal	ra,80001b9a <myproc>
    8000564c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000564e:	0d050793          	addi	a5,a0,208
    80005652:	4501                	li	a0,0
    80005654:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005656:	6398                	ld	a4,0(a5)
    80005658:	cb19                	beqz	a4,8000566e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000565a:	2505                	addiw	a0,a0,1
    8000565c:	07a1                	addi	a5,a5,8
    8000565e:	fed51ce3          	bne	a0,a3,80005656 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005662:	557d                	li	a0,-1
}
    80005664:	60e2                	ld	ra,24(sp)
    80005666:	6442                	ld	s0,16(sp)
    80005668:	64a2                	ld	s1,8(sp)
    8000566a:	6105                	addi	sp,sp,32
    8000566c:	8082                	ret
      p->ofile[fd] = f;
    8000566e:	01a50793          	addi	a5,a0,26
    80005672:	078e                	slli	a5,a5,0x3
    80005674:	963e                	add	a2,a2,a5
    80005676:	e204                	sd	s1,0(a2)
      return fd;
    80005678:	b7f5                	j	80005664 <fdalloc+0x28>

000000008000567a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000567a:	715d                	addi	sp,sp,-80
    8000567c:	e486                	sd	ra,72(sp)
    8000567e:	e0a2                	sd	s0,64(sp)
    80005680:	fc26                	sd	s1,56(sp)
    80005682:	f84a                	sd	s2,48(sp)
    80005684:	f44e                	sd	s3,40(sp)
    80005686:	f052                	sd	s4,32(sp)
    80005688:	ec56                	sd	s5,24(sp)
    8000568a:	e85a                	sd	s6,16(sp)
    8000568c:	0880                	addi	s0,sp,80
    8000568e:	8b2e                	mv	s6,a1
    80005690:	89b2                	mv	s3,a2
    80005692:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005694:	fb040593          	addi	a1,s0,-80
    80005698:	806ff0ef          	jal	ra,8000469e <nameiparent>
    8000569c:	84aa                	mv	s1,a0
    8000569e:	10050b63          	beqz	a0,800057b4 <create+0x13a>
    return 0;

  ilock(dp);
    800056a2:	ff4fe0ef          	jal	ra,80003e96 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056a6:	4601                	li	a2,0
    800056a8:	fb040593          	addi	a1,s0,-80
    800056ac:	8526                	mv	a0,s1
    800056ae:	d71fe0ef          	jal	ra,8000441e <dirlookup>
    800056b2:	8aaa                	mv	s5,a0
    800056b4:	c521                	beqz	a0,800056fc <create+0x82>
    iunlockput(dp);
    800056b6:	8526                	mv	a0,s1
    800056b8:	9e5fe0ef          	jal	ra,8000409c <iunlockput>
    ilock(ip);
    800056bc:	8556                	mv	a0,s5
    800056be:	fd8fe0ef          	jal	ra,80003e96 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056c2:	000b059b          	sext.w	a1,s6
    800056c6:	4789                	li	a5,2
    800056c8:	02f59563          	bne	a1,a5,800056f2 <create+0x78>
    800056cc:	044ad783          	lhu	a5,68(s5)
    800056d0:	37f9                	addiw	a5,a5,-2
    800056d2:	17c2                	slli	a5,a5,0x30
    800056d4:	93c1                	srli	a5,a5,0x30
    800056d6:	4705                	li	a4,1
    800056d8:	00f76d63          	bltu	a4,a5,800056f2 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800056dc:	8556                	mv	a0,s5
    800056de:	60a6                	ld	ra,72(sp)
    800056e0:	6406                	ld	s0,64(sp)
    800056e2:	74e2                	ld	s1,56(sp)
    800056e4:	7942                	ld	s2,48(sp)
    800056e6:	79a2                	ld	s3,40(sp)
    800056e8:	7a02                	ld	s4,32(sp)
    800056ea:	6ae2                	ld	s5,24(sp)
    800056ec:	6b42                	ld	s6,16(sp)
    800056ee:	6161                	addi	sp,sp,80
    800056f0:	8082                	ret
    iunlockput(ip);
    800056f2:	8556                	mv	a0,s5
    800056f4:	9a9fe0ef          	jal	ra,8000409c <iunlockput>
    return 0;
    800056f8:	4a81                	li	s5,0
    800056fa:	b7cd                	j	800056dc <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    800056fc:	85da                	mv	a1,s6
    800056fe:	4088                	lw	a0,0(s1)
    80005700:	e2efe0ef          	jal	ra,80003d2e <ialloc>
    80005704:	8a2a                	mv	s4,a0
    80005706:	cd1d                	beqz	a0,80005744 <create+0xca>
  ilock(ip);
    80005708:	f8efe0ef          	jal	ra,80003e96 <ilock>
  ip->major = major;
    8000570c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005710:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005714:	4905                	li	s2,1
    80005716:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000571a:	8552                	mv	a0,s4
    8000571c:	ec8fe0ef          	jal	ra,80003de4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005720:	000b059b          	sext.w	a1,s6
    80005724:	03258563          	beq	a1,s2,8000574e <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80005728:	004a2603          	lw	a2,4(s4)
    8000572c:	fb040593          	addi	a1,s0,-80
    80005730:	8526                	mv	a0,s1
    80005732:	eb9fe0ef          	jal	ra,800045ea <dirlink>
    80005736:	06054363          	bltz	a0,8000579c <create+0x122>
  iunlockput(dp);
    8000573a:	8526                	mv	a0,s1
    8000573c:	961fe0ef          	jal	ra,8000409c <iunlockput>
  return ip;
    80005740:	8ad2                	mv	s5,s4
    80005742:	bf69                	j	800056dc <create+0x62>
    iunlockput(dp);
    80005744:	8526                	mv	a0,s1
    80005746:	957fe0ef          	jal	ra,8000409c <iunlockput>
    return 0;
    8000574a:	8ad2                	mv	s5,s4
    8000574c:	bf41                	j	800056dc <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000574e:	004a2603          	lw	a2,4(s4)
    80005752:	00003597          	auipc	a1,0x3
    80005756:	fc658593          	addi	a1,a1,-58 # 80008718 <syscalls+0x320>
    8000575a:	8552                	mv	a0,s4
    8000575c:	e8ffe0ef          	jal	ra,800045ea <dirlink>
    80005760:	02054e63          	bltz	a0,8000579c <create+0x122>
    80005764:	40d0                	lw	a2,4(s1)
    80005766:	00003597          	auipc	a1,0x3
    8000576a:	fba58593          	addi	a1,a1,-70 # 80008720 <syscalls+0x328>
    8000576e:	8552                	mv	a0,s4
    80005770:	e7bfe0ef          	jal	ra,800045ea <dirlink>
    80005774:	02054463          	bltz	a0,8000579c <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80005778:	004a2603          	lw	a2,4(s4)
    8000577c:	fb040593          	addi	a1,s0,-80
    80005780:	8526                	mv	a0,s1
    80005782:	e69fe0ef          	jal	ra,800045ea <dirlink>
    80005786:	00054b63          	bltz	a0,8000579c <create+0x122>
    dp->nlink++;  // for ".."
    8000578a:	04a4d783          	lhu	a5,74(s1)
    8000578e:	2785                	addiw	a5,a5,1
    80005790:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005794:	8526                	mv	a0,s1
    80005796:	e4efe0ef          	jal	ra,80003de4 <iupdate>
    8000579a:	b745                	j	8000573a <create+0xc0>
  ip->nlink = 0;
    8000579c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057a0:	8552                	mv	a0,s4
    800057a2:	e42fe0ef          	jal	ra,80003de4 <iupdate>
  iunlockput(ip);
    800057a6:	8552                	mv	a0,s4
    800057a8:	8f5fe0ef          	jal	ra,8000409c <iunlockput>
  iunlockput(dp);
    800057ac:	8526                	mv	a0,s1
    800057ae:	8effe0ef          	jal	ra,8000409c <iunlockput>
  return 0;
    800057b2:	b72d                	j	800056dc <create+0x62>
    return 0;
    800057b4:	8aaa                	mv	s5,a0
    800057b6:	b71d                	j	800056dc <create+0x62>

00000000800057b8 <sys_dup>:
{
    800057b8:	7179                	addi	sp,sp,-48
    800057ba:	f406                	sd	ra,40(sp)
    800057bc:	f022                	sd	s0,32(sp)
    800057be:	ec26                	sd	s1,24(sp)
    800057c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057c2:	fd840613          	addi	a2,s0,-40
    800057c6:	4581                	li	a1,0
    800057c8:	4501                	li	a0,0
    800057ca:	e1bff0ef          	jal	ra,800055e4 <argfd>
    return -1;
    800057ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057d0:	00054f63          	bltz	a0,800057ee <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    800057d4:	fd843503          	ld	a0,-40(s0)
    800057d8:	e65ff0ef          	jal	ra,8000563c <fdalloc>
    800057dc:	84aa                	mv	s1,a0
    return -1;
    800057de:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057e0:	00054763          	bltz	a0,800057ee <sys_dup+0x36>
  filedup(f);
    800057e4:	fd843503          	ld	a0,-40(s0)
    800057e8:	c54ff0ef          	jal	ra,80004c3c <filedup>
  return fd;
    800057ec:	87a6                	mv	a5,s1
}
    800057ee:	853e                	mv	a0,a5
    800057f0:	70a2                	ld	ra,40(sp)
    800057f2:	7402                	ld	s0,32(sp)
    800057f4:	64e2                	ld	s1,24(sp)
    800057f6:	6145                	addi	sp,sp,48
    800057f8:	8082                	ret

00000000800057fa <sys_read>:
{
    800057fa:	7179                	addi	sp,sp,-48
    800057fc:	f406                	sd	ra,40(sp)
    800057fe:	f022                	sd	s0,32(sp)
    80005800:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005802:	fd840593          	addi	a1,s0,-40
    80005806:	4505                	li	a0,1
    80005808:	ddcfd0ef          	jal	ra,80002de4 <argaddr>
  argint(2, &n);
    8000580c:	fe440593          	addi	a1,s0,-28
    80005810:	4509                	li	a0,2
    80005812:	db6fd0ef          	jal	ra,80002dc8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005816:	fe840613          	addi	a2,s0,-24
    8000581a:	4581                	li	a1,0
    8000581c:	4501                	li	a0,0
    8000581e:	dc7ff0ef          	jal	ra,800055e4 <argfd>
    80005822:	87aa                	mv	a5,a0
    return -1;
    80005824:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005826:	0007ca63          	bltz	a5,8000583a <sys_read+0x40>
  return fileread(f, p, n);
    8000582a:	fe442603          	lw	a2,-28(s0)
    8000582e:	fd843583          	ld	a1,-40(s0)
    80005832:	fe843503          	ld	a0,-24(s0)
    80005836:	d52ff0ef          	jal	ra,80004d88 <fileread>
}
    8000583a:	70a2                	ld	ra,40(sp)
    8000583c:	7402                	ld	s0,32(sp)
    8000583e:	6145                	addi	sp,sp,48
    80005840:	8082                	ret

0000000080005842 <sys_write>:
{
    80005842:	7179                	addi	sp,sp,-48
    80005844:	f406                	sd	ra,40(sp)
    80005846:	f022                	sd	s0,32(sp)
    80005848:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000584a:	fd840593          	addi	a1,s0,-40
    8000584e:	4505                	li	a0,1
    80005850:	d94fd0ef          	jal	ra,80002de4 <argaddr>
  argint(2, &n);
    80005854:	fe440593          	addi	a1,s0,-28
    80005858:	4509                	li	a0,2
    8000585a:	d6efd0ef          	jal	ra,80002dc8 <argint>
  if(argfd(0, 0, &f) < 0)
    8000585e:	fe840613          	addi	a2,s0,-24
    80005862:	4581                	li	a1,0
    80005864:	4501                	li	a0,0
    80005866:	d7fff0ef          	jal	ra,800055e4 <argfd>
    8000586a:	87aa                	mv	a5,a0
    return -1;
    8000586c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000586e:	0007ca63          	bltz	a5,80005882 <sys_write+0x40>
  return filewrite(f, p, n);
    80005872:	fe442603          	lw	a2,-28(s0)
    80005876:	fd843583          	ld	a1,-40(s0)
    8000587a:	fe843503          	ld	a0,-24(s0)
    8000587e:	db8ff0ef          	jal	ra,80004e36 <filewrite>
}
    80005882:	70a2                	ld	ra,40(sp)
    80005884:	7402                	ld	s0,32(sp)
    80005886:	6145                	addi	sp,sp,48
    80005888:	8082                	ret

000000008000588a <sys_close>:
{
    8000588a:	1101                	addi	sp,sp,-32
    8000588c:	ec06                	sd	ra,24(sp)
    8000588e:	e822                	sd	s0,16(sp)
    80005890:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005892:	fe040613          	addi	a2,s0,-32
    80005896:	fec40593          	addi	a1,s0,-20
    8000589a:	4501                	li	a0,0
    8000589c:	d49ff0ef          	jal	ra,800055e4 <argfd>
    return -1;
    800058a0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058a2:	02054063          	bltz	a0,800058c2 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800058a6:	af4fc0ef          	jal	ra,80001b9a <myproc>
    800058aa:	fec42783          	lw	a5,-20(s0)
    800058ae:	07e9                	addi	a5,a5,26
    800058b0:	078e                	slli	a5,a5,0x3
    800058b2:	97aa                	add	a5,a5,a0
    800058b4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800058b8:	fe043503          	ld	a0,-32(s0)
    800058bc:	bc6ff0ef          	jal	ra,80004c82 <fileclose>
  return 0;
    800058c0:	4781                	li	a5,0
}
    800058c2:	853e                	mv	a0,a5
    800058c4:	60e2                	ld	ra,24(sp)
    800058c6:	6442                	ld	s0,16(sp)
    800058c8:	6105                	addi	sp,sp,32
    800058ca:	8082                	ret

00000000800058cc <sys_fstat>:
{
    800058cc:	1101                	addi	sp,sp,-32
    800058ce:	ec06                	sd	ra,24(sp)
    800058d0:	e822                	sd	s0,16(sp)
    800058d2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800058d4:	fe040593          	addi	a1,s0,-32
    800058d8:	4505                	li	a0,1
    800058da:	d0afd0ef          	jal	ra,80002de4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800058de:	fe840613          	addi	a2,s0,-24
    800058e2:	4581                	li	a1,0
    800058e4:	4501                	li	a0,0
    800058e6:	cffff0ef          	jal	ra,800055e4 <argfd>
    800058ea:	87aa                	mv	a5,a0
    return -1;
    800058ec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058ee:	0007c863          	bltz	a5,800058fe <sys_fstat+0x32>
  return filestat(f, st);
    800058f2:	fe043583          	ld	a1,-32(s0)
    800058f6:	fe843503          	ld	a0,-24(s0)
    800058fa:	c30ff0ef          	jal	ra,80004d2a <filestat>
}
    800058fe:	60e2                	ld	ra,24(sp)
    80005900:	6442                	ld	s0,16(sp)
    80005902:	6105                	addi	sp,sp,32
    80005904:	8082                	ret

0000000080005906 <sys_link>:
{
    80005906:	7169                	addi	sp,sp,-304
    80005908:	f606                	sd	ra,296(sp)
    8000590a:	f222                	sd	s0,288(sp)
    8000590c:	ee26                	sd	s1,280(sp)
    8000590e:	ea4a                	sd	s2,272(sp)
    80005910:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005912:	08000613          	li	a2,128
    80005916:	ed040593          	addi	a1,s0,-304
    8000591a:	4501                	li	a0,0
    8000591c:	ce4fd0ef          	jal	ra,80002e00 <argstr>
    return -1;
    80005920:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005922:	0c054663          	bltz	a0,800059ee <sys_link+0xe8>
    80005926:	08000613          	li	a2,128
    8000592a:	f5040593          	addi	a1,s0,-176
    8000592e:	4505                	li	a0,1
    80005930:	cd0fd0ef          	jal	ra,80002e00 <argstr>
    return -1;
    80005934:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005936:	0a054c63          	bltz	a0,800059ee <sys_link+0xe8>
  begin_op();
    8000593a:	f3bfe0ef          	jal	ra,80004874 <begin_op>
  if((ip = namei(old)) == 0){
    8000593e:	ed040513          	addi	a0,s0,-304
    80005942:	d43fe0ef          	jal	ra,80004684 <namei>
    80005946:	84aa                	mv	s1,a0
    80005948:	c525                	beqz	a0,800059b0 <sys_link+0xaa>
  ilock(ip);
    8000594a:	d4cfe0ef          	jal	ra,80003e96 <ilock>
  if(ip->type == T_DIR){
    8000594e:	04449703          	lh	a4,68(s1)
    80005952:	4785                	li	a5,1
    80005954:	06f70263          	beq	a4,a5,800059b8 <sys_link+0xb2>
  ip->nlink++;
    80005958:	04a4d783          	lhu	a5,74(s1)
    8000595c:	2785                	addiw	a5,a5,1
    8000595e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005962:	8526                	mv	a0,s1
    80005964:	c80fe0ef          	jal	ra,80003de4 <iupdate>
  iunlock(ip);
    80005968:	8526                	mv	a0,s1
    8000596a:	dd6fe0ef          	jal	ra,80003f40 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000596e:	fd040593          	addi	a1,s0,-48
    80005972:	f5040513          	addi	a0,s0,-176
    80005976:	d29fe0ef          	jal	ra,8000469e <nameiparent>
    8000597a:	892a                	mv	s2,a0
    8000597c:	c921                	beqz	a0,800059cc <sys_link+0xc6>
  ilock(dp);
    8000597e:	d18fe0ef          	jal	ra,80003e96 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005982:	00092703          	lw	a4,0(s2)
    80005986:	409c                	lw	a5,0(s1)
    80005988:	02f71f63          	bne	a4,a5,800059c6 <sys_link+0xc0>
    8000598c:	40d0                	lw	a2,4(s1)
    8000598e:	fd040593          	addi	a1,s0,-48
    80005992:	854a                	mv	a0,s2
    80005994:	c57fe0ef          	jal	ra,800045ea <dirlink>
    80005998:	02054763          	bltz	a0,800059c6 <sys_link+0xc0>
  iunlockput(dp);
    8000599c:	854a                	mv	a0,s2
    8000599e:	efefe0ef          	jal	ra,8000409c <iunlockput>
  iput(ip);
    800059a2:	8526                	mv	a0,s1
    800059a4:	e70fe0ef          	jal	ra,80004014 <iput>
  end_op();
    800059a8:	f3dfe0ef          	jal	ra,800048e4 <end_op>
  return 0;
    800059ac:	4781                	li	a5,0
    800059ae:	a081                	j	800059ee <sys_link+0xe8>
    end_op();
    800059b0:	f35fe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    800059b4:	57fd                	li	a5,-1
    800059b6:	a825                	j	800059ee <sys_link+0xe8>
    iunlockput(ip);
    800059b8:	8526                	mv	a0,s1
    800059ba:	ee2fe0ef          	jal	ra,8000409c <iunlockput>
    end_op();
    800059be:	f27fe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    800059c2:	57fd                	li	a5,-1
    800059c4:	a02d                	j	800059ee <sys_link+0xe8>
    iunlockput(dp);
    800059c6:	854a                	mv	a0,s2
    800059c8:	ed4fe0ef          	jal	ra,8000409c <iunlockput>
  ilock(ip);
    800059cc:	8526                	mv	a0,s1
    800059ce:	cc8fe0ef          	jal	ra,80003e96 <ilock>
  ip->nlink--;
    800059d2:	04a4d783          	lhu	a5,74(s1)
    800059d6:	37fd                	addiw	a5,a5,-1
    800059d8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059dc:	8526                	mv	a0,s1
    800059de:	c06fe0ef          	jal	ra,80003de4 <iupdate>
  iunlockput(ip);
    800059e2:	8526                	mv	a0,s1
    800059e4:	eb8fe0ef          	jal	ra,8000409c <iunlockput>
  end_op();
    800059e8:	efdfe0ef          	jal	ra,800048e4 <end_op>
  return -1;
    800059ec:	57fd                	li	a5,-1
}
    800059ee:	853e                	mv	a0,a5
    800059f0:	70b2                	ld	ra,296(sp)
    800059f2:	7412                	ld	s0,288(sp)
    800059f4:	64f2                	ld	s1,280(sp)
    800059f6:	6952                	ld	s2,272(sp)
    800059f8:	6155                	addi	sp,sp,304
    800059fa:	8082                	ret

00000000800059fc <sys_unlink>:
{
    800059fc:	7151                	addi	sp,sp,-240
    800059fe:	f586                	sd	ra,232(sp)
    80005a00:	f1a2                	sd	s0,224(sp)
    80005a02:	eda6                	sd	s1,216(sp)
    80005a04:	e9ca                	sd	s2,208(sp)
    80005a06:	e5ce                	sd	s3,200(sp)
    80005a08:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a0a:	08000613          	li	a2,128
    80005a0e:	f3040593          	addi	a1,s0,-208
    80005a12:	4501                	li	a0,0
    80005a14:	becfd0ef          	jal	ra,80002e00 <argstr>
    80005a18:	12054b63          	bltz	a0,80005b4e <sys_unlink+0x152>
  begin_op();
    80005a1c:	e59fe0ef          	jal	ra,80004874 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a20:	fb040593          	addi	a1,s0,-80
    80005a24:	f3040513          	addi	a0,s0,-208
    80005a28:	c77fe0ef          	jal	ra,8000469e <nameiparent>
    80005a2c:	84aa                	mv	s1,a0
    80005a2e:	c54d                	beqz	a0,80005ad8 <sys_unlink+0xdc>
  ilock(dp);
    80005a30:	c66fe0ef          	jal	ra,80003e96 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a34:	00003597          	auipc	a1,0x3
    80005a38:	ce458593          	addi	a1,a1,-796 # 80008718 <syscalls+0x320>
    80005a3c:	fb040513          	addi	a0,s0,-80
    80005a40:	9c9fe0ef          	jal	ra,80004408 <namecmp>
    80005a44:	10050a63          	beqz	a0,80005b58 <sys_unlink+0x15c>
    80005a48:	00003597          	auipc	a1,0x3
    80005a4c:	cd858593          	addi	a1,a1,-808 # 80008720 <syscalls+0x328>
    80005a50:	fb040513          	addi	a0,s0,-80
    80005a54:	9b5fe0ef          	jal	ra,80004408 <namecmp>
    80005a58:	10050063          	beqz	a0,80005b58 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a5c:	f2c40613          	addi	a2,s0,-212
    80005a60:	fb040593          	addi	a1,s0,-80
    80005a64:	8526                	mv	a0,s1
    80005a66:	9b9fe0ef          	jal	ra,8000441e <dirlookup>
    80005a6a:	892a                	mv	s2,a0
    80005a6c:	0e050663          	beqz	a0,80005b58 <sys_unlink+0x15c>
  ilock(ip);
    80005a70:	c26fe0ef          	jal	ra,80003e96 <ilock>
  if(ip->nlink < 1)
    80005a74:	04a91783          	lh	a5,74(s2)
    80005a78:	06f05463          	blez	a5,80005ae0 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a7c:	04491703          	lh	a4,68(s2)
    80005a80:	4785                	li	a5,1
    80005a82:	06f70563          	beq	a4,a5,80005aec <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80005a86:	4641                	li	a2,16
    80005a88:	4581                	li	a1,0
    80005a8a:	fc040513          	addi	a0,s0,-64
    80005a8e:	af6fb0ef          	jal	ra,80000d84 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a92:	4741                	li	a4,16
    80005a94:	f2c42683          	lw	a3,-212(s0)
    80005a98:	fc040613          	addi	a2,s0,-64
    80005a9c:	4581                	li	a1,0
    80005a9e:	8526                	mv	a0,s1
    80005aa0:	867fe0ef          	jal	ra,80004306 <writei>
    80005aa4:	47c1                	li	a5,16
    80005aa6:	08f51563          	bne	a0,a5,80005b30 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80005aaa:	04491703          	lh	a4,68(s2)
    80005aae:	4785                	li	a5,1
    80005ab0:	08f70663          	beq	a4,a5,80005b3c <sys_unlink+0x140>
  iunlockput(dp);
    80005ab4:	8526                	mv	a0,s1
    80005ab6:	de6fe0ef          	jal	ra,8000409c <iunlockput>
  ip->nlink--;
    80005aba:	04a95783          	lhu	a5,74(s2)
    80005abe:	37fd                	addiw	a5,a5,-1
    80005ac0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ac4:	854a                	mv	a0,s2
    80005ac6:	b1efe0ef          	jal	ra,80003de4 <iupdate>
  iunlockput(ip);
    80005aca:	854a                	mv	a0,s2
    80005acc:	dd0fe0ef          	jal	ra,8000409c <iunlockput>
  end_op();
    80005ad0:	e15fe0ef          	jal	ra,800048e4 <end_op>
  return 0;
    80005ad4:	4501                	li	a0,0
    80005ad6:	a079                	j	80005b64 <sys_unlink+0x168>
    end_op();
    80005ad8:	e0dfe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005adc:	557d                	li	a0,-1
    80005ade:	a059                	j	80005b64 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005ae0:	00003517          	auipc	a0,0x3
    80005ae4:	c4850513          	addi	a0,a0,-952 # 80008728 <syscalls+0x330>
    80005ae8:	ca3fa0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005aec:	04c92703          	lw	a4,76(s2)
    80005af0:	02000793          	li	a5,32
    80005af4:	f8e7f9e3          	bgeu	a5,a4,80005a86 <sys_unlink+0x8a>
    80005af8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005afc:	4741                	li	a4,16
    80005afe:	86ce                	mv	a3,s3
    80005b00:	f1840613          	addi	a2,s0,-232
    80005b04:	4581                	li	a1,0
    80005b06:	854a                	mv	a0,s2
    80005b08:	f1afe0ef          	jal	ra,80004222 <readi>
    80005b0c:	47c1                	li	a5,16
    80005b0e:	00f51b63          	bne	a0,a5,80005b24 <sys_unlink+0x128>
    if(de.inum != 0)
    80005b12:	f1845783          	lhu	a5,-232(s0)
    80005b16:	ef95                	bnez	a5,80005b52 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b18:	29c1                	addiw	s3,s3,16
    80005b1a:	04c92783          	lw	a5,76(s2)
    80005b1e:	fcf9efe3          	bltu	s3,a5,80005afc <sys_unlink+0x100>
    80005b22:	b795                	j	80005a86 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005b24:	00003517          	auipc	a0,0x3
    80005b28:	c1c50513          	addi	a0,a0,-996 # 80008740 <syscalls+0x348>
    80005b2c:	c5ffa0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80005b30:	00003517          	auipc	a0,0x3
    80005b34:	c2850513          	addi	a0,a0,-984 # 80008758 <syscalls+0x360>
    80005b38:	c53fa0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80005b3c:	04a4d783          	lhu	a5,74(s1)
    80005b40:	37fd                	addiw	a5,a5,-1
    80005b42:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b46:	8526                	mv	a0,s1
    80005b48:	a9cfe0ef          	jal	ra,80003de4 <iupdate>
    80005b4c:	b7a5                	j	80005ab4 <sys_unlink+0xb8>
    return -1;
    80005b4e:	557d                	li	a0,-1
    80005b50:	a811                	j	80005b64 <sys_unlink+0x168>
    iunlockput(ip);
    80005b52:	854a                	mv	a0,s2
    80005b54:	d48fe0ef          	jal	ra,8000409c <iunlockput>
  iunlockput(dp);
    80005b58:	8526                	mv	a0,s1
    80005b5a:	d42fe0ef          	jal	ra,8000409c <iunlockput>
  end_op();
    80005b5e:	d87fe0ef          	jal	ra,800048e4 <end_op>
  return -1;
    80005b62:	557d                	li	a0,-1
}
    80005b64:	70ae                	ld	ra,232(sp)
    80005b66:	740e                	ld	s0,224(sp)
    80005b68:	64ee                	ld	s1,216(sp)
    80005b6a:	694e                	ld	s2,208(sp)
    80005b6c:	69ae                	ld	s3,200(sp)
    80005b6e:	616d                	addi	sp,sp,240
    80005b70:	8082                	ret

0000000080005b72 <sys_open>:

uint64
sys_open(void)
{
    80005b72:	7131                	addi	sp,sp,-192
    80005b74:	fd06                	sd	ra,184(sp)
    80005b76:	f922                	sd	s0,176(sp)
    80005b78:	f526                	sd	s1,168(sp)
    80005b7a:	f14a                	sd	s2,160(sp)
    80005b7c:	ed4e                	sd	s3,152(sp)
    80005b7e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b80:	f4c40593          	addi	a1,s0,-180
    80005b84:	4505                	li	a0,1
    80005b86:	a42fd0ef          	jal	ra,80002dc8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b8a:	08000613          	li	a2,128
    80005b8e:	f5040593          	addi	a1,s0,-176
    80005b92:	4501                	li	a0,0
    80005b94:	a6cfd0ef          	jal	ra,80002e00 <argstr>
    80005b98:	87aa                	mv	a5,a0
    return -1;
    80005b9a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b9c:	0807cd63          	bltz	a5,80005c36 <sys_open+0xc4>

  begin_op();
    80005ba0:	cd5fe0ef          	jal	ra,80004874 <begin_op>

  if(omode & O_CREATE){
    80005ba4:	f4c42783          	lw	a5,-180(s0)
    80005ba8:	2007f793          	andi	a5,a5,512
    80005bac:	c3c5                	beqz	a5,80005c4c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005bae:	4681                	li	a3,0
    80005bb0:	4601                	li	a2,0
    80005bb2:	4589                	li	a1,2
    80005bb4:	f5040513          	addi	a0,s0,-176
    80005bb8:	ac3ff0ef          	jal	ra,8000567a <create>
    80005bbc:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bbe:	c159                	beqz	a0,80005c44 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bc0:	04449703          	lh	a4,68(s1)
    80005bc4:	478d                	li	a5,3
    80005bc6:	00f71763          	bne	a4,a5,80005bd4 <sys_open+0x62>
    80005bca:	0464d703          	lhu	a4,70(s1)
    80005bce:	47a5                	li	a5,9
    80005bd0:	0ae7e963          	bltu	a5,a4,80005c82 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bd4:	80aff0ef          	jal	ra,80004bde <filealloc>
    80005bd8:	89aa                	mv	s3,a0
    80005bda:	0c050963          	beqz	a0,80005cac <sys_open+0x13a>
    80005bde:	a5fff0ef          	jal	ra,8000563c <fdalloc>
    80005be2:	892a                	mv	s2,a0
    80005be4:	0c054163          	bltz	a0,80005ca6 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005be8:	04449703          	lh	a4,68(s1)
    80005bec:	478d                	li	a5,3
    80005bee:	0af70163          	beq	a4,a5,80005c90 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005bf2:	4789                	li	a5,2
    80005bf4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005bf8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005bfc:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c00:	f4c42783          	lw	a5,-180(s0)
    80005c04:	0017c713          	xori	a4,a5,1
    80005c08:	8b05                	andi	a4,a4,1
    80005c0a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c0e:	0037f713          	andi	a4,a5,3
    80005c12:	00e03733          	snez	a4,a4
    80005c16:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c1a:	4007f793          	andi	a5,a5,1024
    80005c1e:	c791                	beqz	a5,80005c2a <sys_open+0xb8>
    80005c20:	04449703          	lh	a4,68(s1)
    80005c24:	4789                	li	a5,2
    80005c26:	06f70c63          	beq	a4,a5,80005c9e <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	b14fe0ef          	jal	ra,80003f40 <iunlock>
  end_op();
    80005c30:	cb5fe0ef          	jal	ra,800048e4 <end_op>

  return fd;
    80005c34:	854a                	mv	a0,s2
}
    80005c36:	70ea                	ld	ra,184(sp)
    80005c38:	744a                	ld	s0,176(sp)
    80005c3a:	74aa                	ld	s1,168(sp)
    80005c3c:	790a                	ld	s2,160(sp)
    80005c3e:	69ea                	ld	s3,152(sp)
    80005c40:	6129                	addi	sp,sp,192
    80005c42:	8082                	ret
      end_op();
    80005c44:	ca1fe0ef          	jal	ra,800048e4 <end_op>
      return -1;
    80005c48:	557d                	li	a0,-1
    80005c4a:	b7f5                	j	80005c36 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005c4c:	f5040513          	addi	a0,s0,-176
    80005c50:	a35fe0ef          	jal	ra,80004684 <namei>
    80005c54:	84aa                	mv	s1,a0
    80005c56:	c115                	beqz	a0,80005c7a <sys_open+0x108>
    ilock(ip);
    80005c58:	a3efe0ef          	jal	ra,80003e96 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c5c:	04449703          	lh	a4,68(s1)
    80005c60:	4785                	li	a5,1
    80005c62:	f4f71fe3          	bne	a4,a5,80005bc0 <sys_open+0x4e>
    80005c66:	f4c42783          	lw	a5,-180(s0)
    80005c6a:	d7ad                	beqz	a5,80005bd4 <sys_open+0x62>
      iunlockput(ip);
    80005c6c:	8526                	mv	a0,s1
    80005c6e:	c2efe0ef          	jal	ra,8000409c <iunlockput>
      end_op();
    80005c72:	c73fe0ef          	jal	ra,800048e4 <end_op>
      return -1;
    80005c76:	557d                	li	a0,-1
    80005c78:	bf7d                	j	80005c36 <sys_open+0xc4>
      end_op();
    80005c7a:	c6bfe0ef          	jal	ra,800048e4 <end_op>
      return -1;
    80005c7e:	557d                	li	a0,-1
    80005c80:	bf5d                	j	80005c36 <sys_open+0xc4>
    iunlockput(ip);
    80005c82:	8526                	mv	a0,s1
    80005c84:	c18fe0ef          	jal	ra,8000409c <iunlockput>
    end_op();
    80005c88:	c5dfe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005c8c:	557d                	li	a0,-1
    80005c8e:	b765                	j	80005c36 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005c90:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c94:	04649783          	lh	a5,70(s1)
    80005c98:	02f99223          	sh	a5,36(s3)
    80005c9c:	b785                	j	80005bfc <sys_open+0x8a>
    itrunc(ip);
    80005c9e:	8526                	mv	a0,s1
    80005ca0:	ae0fe0ef          	jal	ra,80003f80 <itrunc>
    80005ca4:	b759                	j	80005c2a <sys_open+0xb8>
      fileclose(f);
    80005ca6:	854e                	mv	a0,s3
    80005ca8:	fdbfe0ef          	jal	ra,80004c82 <fileclose>
    iunlockput(ip);
    80005cac:	8526                	mv	a0,s1
    80005cae:	beefe0ef          	jal	ra,8000409c <iunlockput>
    end_op();
    80005cb2:	c33fe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005cb6:	557d                	li	a0,-1
    80005cb8:	bfbd                	j	80005c36 <sys_open+0xc4>

0000000080005cba <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005cba:	7175                	addi	sp,sp,-144
    80005cbc:	e506                	sd	ra,136(sp)
    80005cbe:	e122                	sd	s0,128(sp)
    80005cc0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cc2:	bb3fe0ef          	jal	ra,80004874 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005cc6:	08000613          	li	a2,128
    80005cca:	f7040593          	addi	a1,s0,-144
    80005cce:	4501                	li	a0,0
    80005cd0:	930fd0ef          	jal	ra,80002e00 <argstr>
    80005cd4:	02054363          	bltz	a0,80005cfa <sys_mkdir+0x40>
    80005cd8:	4681                	li	a3,0
    80005cda:	4601                	li	a2,0
    80005cdc:	4585                	li	a1,1
    80005cde:	f7040513          	addi	a0,s0,-144
    80005ce2:	999ff0ef          	jal	ra,8000567a <create>
    80005ce6:	c911                	beqz	a0,80005cfa <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ce8:	bb4fe0ef          	jal	ra,8000409c <iunlockput>
  end_op();
    80005cec:	bf9fe0ef          	jal	ra,800048e4 <end_op>
  return 0;
    80005cf0:	4501                	li	a0,0
}
    80005cf2:	60aa                	ld	ra,136(sp)
    80005cf4:	640a                	ld	s0,128(sp)
    80005cf6:	6149                	addi	sp,sp,144
    80005cf8:	8082                	ret
    end_op();
    80005cfa:	bebfe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005cfe:	557d                	li	a0,-1
    80005d00:	bfcd                	j	80005cf2 <sys_mkdir+0x38>

0000000080005d02 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d02:	7135                	addi	sp,sp,-160
    80005d04:	ed06                	sd	ra,152(sp)
    80005d06:	e922                	sd	s0,144(sp)
    80005d08:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d0a:	b6bfe0ef          	jal	ra,80004874 <begin_op>
  argint(1, &major);
    80005d0e:	f6c40593          	addi	a1,s0,-148
    80005d12:	4505                	li	a0,1
    80005d14:	8b4fd0ef          	jal	ra,80002dc8 <argint>
  argint(2, &minor);
    80005d18:	f6840593          	addi	a1,s0,-152
    80005d1c:	4509                	li	a0,2
    80005d1e:	8aafd0ef          	jal	ra,80002dc8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d22:	08000613          	li	a2,128
    80005d26:	f7040593          	addi	a1,s0,-144
    80005d2a:	4501                	li	a0,0
    80005d2c:	8d4fd0ef          	jal	ra,80002e00 <argstr>
    80005d30:	02054563          	bltz	a0,80005d5a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d34:	f6841683          	lh	a3,-152(s0)
    80005d38:	f6c41603          	lh	a2,-148(s0)
    80005d3c:	458d                	li	a1,3
    80005d3e:	f7040513          	addi	a0,s0,-144
    80005d42:	939ff0ef          	jal	ra,8000567a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d46:	c911                	beqz	a0,80005d5a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d48:	b54fe0ef          	jal	ra,8000409c <iunlockput>
  end_op();
    80005d4c:	b99fe0ef          	jal	ra,800048e4 <end_op>
  return 0;
    80005d50:	4501                	li	a0,0
}
    80005d52:	60ea                	ld	ra,152(sp)
    80005d54:	644a                	ld	s0,144(sp)
    80005d56:	610d                	addi	sp,sp,160
    80005d58:	8082                	ret
    end_op();
    80005d5a:	b8bfe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005d5e:	557d                	li	a0,-1
    80005d60:	bfcd                	j	80005d52 <sys_mknod+0x50>

0000000080005d62 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d62:	7135                	addi	sp,sp,-160
    80005d64:	ed06                	sd	ra,152(sp)
    80005d66:	e922                	sd	s0,144(sp)
    80005d68:	e526                	sd	s1,136(sp)
    80005d6a:	e14a                	sd	s2,128(sp)
    80005d6c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d6e:	e2dfb0ef          	jal	ra,80001b9a <myproc>
    80005d72:	892a                	mv	s2,a0
  
  begin_op();
    80005d74:	b01fe0ef          	jal	ra,80004874 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d78:	08000613          	li	a2,128
    80005d7c:	f6040593          	addi	a1,s0,-160
    80005d80:	4501                	li	a0,0
    80005d82:	87efd0ef          	jal	ra,80002e00 <argstr>
    80005d86:	04054163          	bltz	a0,80005dc8 <sys_chdir+0x66>
    80005d8a:	f6040513          	addi	a0,s0,-160
    80005d8e:	8f7fe0ef          	jal	ra,80004684 <namei>
    80005d92:	84aa                	mv	s1,a0
    80005d94:	c915                	beqz	a0,80005dc8 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d96:	900fe0ef          	jal	ra,80003e96 <ilock>
  if(ip->type != T_DIR){
    80005d9a:	04449703          	lh	a4,68(s1)
    80005d9e:	4785                	li	a5,1
    80005da0:	02f71863          	bne	a4,a5,80005dd0 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005da4:	8526                	mv	a0,s1
    80005da6:	99afe0ef          	jal	ra,80003f40 <iunlock>
  iput(p->cwd);
    80005daa:	15093503          	ld	a0,336(s2)
    80005dae:	a66fe0ef          	jal	ra,80004014 <iput>
  end_op();
    80005db2:	b33fe0ef          	jal	ra,800048e4 <end_op>
  p->cwd = ip;
    80005db6:	14993823          	sd	s1,336(s2)
  return 0;
    80005dba:	4501                	li	a0,0
}
    80005dbc:	60ea                	ld	ra,152(sp)
    80005dbe:	644a                	ld	s0,144(sp)
    80005dc0:	64aa                	ld	s1,136(sp)
    80005dc2:	690a                	ld	s2,128(sp)
    80005dc4:	610d                	addi	sp,sp,160
    80005dc6:	8082                	ret
    end_op();
    80005dc8:	b1dfe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005dcc:	557d                	li	a0,-1
    80005dce:	b7fd                	j	80005dbc <sys_chdir+0x5a>
    iunlockput(ip);
    80005dd0:	8526                	mv	a0,s1
    80005dd2:	acafe0ef          	jal	ra,8000409c <iunlockput>
    end_op();
    80005dd6:	b0ffe0ef          	jal	ra,800048e4 <end_op>
    return -1;
    80005dda:	557d                	li	a0,-1
    80005ddc:	b7c5                	j	80005dbc <sys_chdir+0x5a>

0000000080005dde <sys_exec>:

uint64
sys_exec(void)
{
    80005dde:	7145                	addi	sp,sp,-464
    80005de0:	e786                	sd	ra,456(sp)
    80005de2:	e3a2                	sd	s0,448(sp)
    80005de4:	ff26                	sd	s1,440(sp)
    80005de6:	fb4a                	sd	s2,432(sp)
    80005de8:	f74e                	sd	s3,424(sp)
    80005dea:	f352                	sd	s4,416(sp)
    80005dec:	ef56                	sd	s5,408(sp)
    80005dee:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005df0:	e3840593          	addi	a1,s0,-456
    80005df4:	4505                	li	a0,1
    80005df6:	feffc0ef          	jal	ra,80002de4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005dfa:	08000613          	li	a2,128
    80005dfe:	f4040593          	addi	a1,s0,-192
    80005e02:	4501                	li	a0,0
    80005e04:	ffdfc0ef          	jal	ra,80002e00 <argstr>
    80005e08:	87aa                	mv	a5,a0
    return -1;
    80005e0a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e0c:	0a07c463          	bltz	a5,80005eb4 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005e10:	10000613          	li	a2,256
    80005e14:	4581                	li	a1,0
    80005e16:	e4040513          	addi	a0,s0,-448
    80005e1a:	f6bfa0ef          	jal	ra,80000d84 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e1e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e22:	89a6                	mv	s3,s1
    80005e24:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e26:	02000a13          	li	s4,32
    80005e2a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e2e:	00391793          	slli	a5,s2,0x3
    80005e32:	e3040593          	addi	a1,s0,-464
    80005e36:	e3843503          	ld	a0,-456(s0)
    80005e3a:	953e                	add	a0,a0,a5
    80005e3c:	f03fc0ef          	jal	ra,80002d3e <fetchaddr>
    80005e40:	02054663          	bltz	a0,80005e6c <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005e44:	e3043783          	ld	a5,-464(s0)
    80005e48:	cf8d                	beqz	a5,80005e82 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e4a:	d63fa0ef          	jal	ra,80000bac <kalloc>
    80005e4e:	85aa                	mv	a1,a0
    80005e50:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e54:	cd01                	beqz	a0,80005e6c <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e56:	6605                	lui	a2,0x1
    80005e58:	e3043503          	ld	a0,-464(s0)
    80005e5c:	f2dfc0ef          	jal	ra,80002d88 <fetchstr>
    80005e60:	00054663          	bltz	a0,80005e6c <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005e64:	0905                	addi	s2,s2,1
    80005e66:	09a1                	addi	s3,s3,8
    80005e68:	fd4911e3          	bne	s2,s4,80005e2a <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e6c:	10048913          	addi	s2,s1,256
    80005e70:	6088                	ld	a0,0(s1)
    80005e72:	c121                	beqz	a0,80005eb2 <sys_exec+0xd4>
    kfree(argv[i]);
    80005e74:	c0bfa0ef          	jal	ra,80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e78:	04a1                	addi	s1,s1,8
    80005e7a:	ff249be3          	bne	s1,s2,80005e70 <sys_exec+0x92>
  return -1;
    80005e7e:	557d                	li	a0,-1
    80005e80:	a815                	j	80005eb4 <sys_exec+0xd6>
      argv[i] = 0;
    80005e82:	0a8e                	slli	s5,s5,0x3
    80005e84:	fc040793          	addi	a5,s0,-64
    80005e88:	9abe                	add	s5,s5,a5
    80005e8a:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005e8e:	e4040593          	addi	a1,s0,-448
    80005e92:	f4040513          	addi	a0,s0,-192
    80005e96:	b98ff0ef          	jal	ra,8000522e <kexec>
    80005e9a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e9c:	10048993          	addi	s3,s1,256
    80005ea0:	6088                	ld	a0,0(s1)
    80005ea2:	c511                	beqz	a0,80005eae <sys_exec+0xd0>
    kfree(argv[i]);
    80005ea4:	bdbfa0ef          	jal	ra,80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ea8:	04a1                	addi	s1,s1,8
    80005eaa:	ff349be3          	bne	s1,s3,80005ea0 <sys_exec+0xc2>
  return ret;
    80005eae:	854a                	mv	a0,s2
    80005eb0:	a011                	j	80005eb4 <sys_exec+0xd6>
  return -1;
    80005eb2:	557d                	li	a0,-1
}
    80005eb4:	60be                	ld	ra,456(sp)
    80005eb6:	641e                	ld	s0,448(sp)
    80005eb8:	74fa                	ld	s1,440(sp)
    80005eba:	795a                	ld	s2,432(sp)
    80005ebc:	79ba                	ld	s3,424(sp)
    80005ebe:	7a1a                	ld	s4,416(sp)
    80005ec0:	6afa                	ld	s5,408(sp)
    80005ec2:	6179                	addi	sp,sp,464
    80005ec4:	8082                	ret

0000000080005ec6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ec6:	7139                	addi	sp,sp,-64
    80005ec8:	fc06                	sd	ra,56(sp)
    80005eca:	f822                	sd	s0,48(sp)
    80005ecc:	f426                	sd	s1,40(sp)
    80005ece:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ed0:	ccbfb0ef          	jal	ra,80001b9a <myproc>
    80005ed4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ed6:	fd840593          	addi	a1,s0,-40
    80005eda:	4501                	li	a0,0
    80005edc:	f09fc0ef          	jal	ra,80002de4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ee0:	fc840593          	addi	a1,s0,-56
    80005ee4:	fd040513          	addi	a0,s0,-48
    80005ee8:	866ff0ef          	jal	ra,80004f4e <pipealloc>
    return -1;
    80005eec:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005eee:	0a054463          	bltz	a0,80005f96 <sys_pipe+0xd0>
  fd0 = -1;
    80005ef2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ef6:	fd043503          	ld	a0,-48(s0)
    80005efa:	f42ff0ef          	jal	ra,8000563c <fdalloc>
    80005efe:	fca42223          	sw	a0,-60(s0)
    80005f02:	08054163          	bltz	a0,80005f84 <sys_pipe+0xbe>
    80005f06:	fc843503          	ld	a0,-56(s0)
    80005f0a:	f32ff0ef          	jal	ra,8000563c <fdalloc>
    80005f0e:	fca42023          	sw	a0,-64(s0)
    80005f12:	06054063          	bltz	a0,80005f72 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f16:	4691                	li	a3,4
    80005f18:	fc440613          	addi	a2,s0,-60
    80005f1c:	fd843583          	ld	a1,-40(s0)
    80005f20:	68a8                	ld	a0,80(s1)
    80005f22:	869fb0ef          	jal	ra,8000178a <copyout>
    80005f26:	00054e63          	bltz	a0,80005f42 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f2a:	4691                	li	a3,4
    80005f2c:	fc040613          	addi	a2,s0,-64
    80005f30:	fd843583          	ld	a1,-40(s0)
    80005f34:	0591                	addi	a1,a1,4
    80005f36:	68a8                	ld	a0,80(s1)
    80005f38:	853fb0ef          	jal	ra,8000178a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f3c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f3e:	04055c63          	bgez	a0,80005f96 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005f42:	fc442783          	lw	a5,-60(s0)
    80005f46:	07e9                	addi	a5,a5,26
    80005f48:	078e                	slli	a5,a5,0x3
    80005f4a:	97a6                	add	a5,a5,s1
    80005f4c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f50:	fc042503          	lw	a0,-64(s0)
    80005f54:	0569                	addi	a0,a0,26
    80005f56:	050e                	slli	a0,a0,0x3
    80005f58:	94aa                	add	s1,s1,a0
    80005f5a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f5e:	fd043503          	ld	a0,-48(s0)
    80005f62:	d21fe0ef          	jal	ra,80004c82 <fileclose>
    fileclose(wf);
    80005f66:	fc843503          	ld	a0,-56(s0)
    80005f6a:	d19fe0ef          	jal	ra,80004c82 <fileclose>
    return -1;
    80005f6e:	57fd                	li	a5,-1
    80005f70:	a01d                	j	80005f96 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005f72:	fc442783          	lw	a5,-60(s0)
    80005f76:	0007c763          	bltz	a5,80005f84 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005f7a:	07e9                	addi	a5,a5,26
    80005f7c:	078e                	slli	a5,a5,0x3
    80005f7e:	94be                	add	s1,s1,a5
    80005f80:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f84:	fd043503          	ld	a0,-48(s0)
    80005f88:	cfbfe0ef          	jal	ra,80004c82 <fileclose>
    fileclose(wf);
    80005f8c:	fc843503          	ld	a0,-56(s0)
    80005f90:	cf3fe0ef          	jal	ra,80004c82 <fileclose>
    return -1;
    80005f94:	57fd                	li	a5,-1
}
    80005f96:	853e                	mv	a0,a5
    80005f98:	70e2                	ld	ra,56(sp)
    80005f9a:	7442                	ld	s0,48(sp)
    80005f9c:	74a2                	ld	s1,40(sp)
    80005f9e:	6121                	addi	sp,sp,64
    80005fa0:	8082                	ret
	...

0000000080005fb0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005fb0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005fb2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005fb4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005fb6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005fb8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005fba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005fbc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005fbe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005fc0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005fc2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005fc4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005fc6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005fc8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005fca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005fcc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005fce:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005fd0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005fd2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005fd4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005fd6:	c79fc0ef          	jal	ra,80002c4e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005fda:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005fdc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005fde:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005fe0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005fe2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005fe4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005fe6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005fe8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005fea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005fec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005fee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005ff0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005ff2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005ff4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005ff6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005ff8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005ffa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005ffc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005ffe:	10200073          	sret
	...

000000008000600e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000600e:	1141                	addi	sp,sp,-16
    80006010:	e422                	sd	s0,8(sp)
    80006012:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006014:	0c0007b7          	lui	a5,0xc000
    80006018:	4705                	li	a4,1
    8000601a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000601c:	c3d8                	sw	a4,4(a5)
}
    8000601e:	6422                	ld	s0,8(sp)
    80006020:	0141                	addi	sp,sp,16
    80006022:	8082                	ret

0000000080006024 <plicinithart>:

void
plicinithart(void)
{
    80006024:	1141                	addi	sp,sp,-16
    80006026:	e406                	sd	ra,8(sp)
    80006028:	e022                	sd	s0,0(sp)
    8000602a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000602c:	b43fb0ef          	jal	ra,80001b6e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006030:	0085171b          	slliw	a4,a0,0x8
    80006034:	0c0027b7          	lui	a5,0xc002
    80006038:	97ba                	add	a5,a5,a4
    8000603a:	40200713          	li	a4,1026
    8000603e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006042:	00d5151b          	slliw	a0,a0,0xd
    80006046:	0c2017b7          	lui	a5,0xc201
    8000604a:	953e                	add	a0,a0,a5
    8000604c:	00052023          	sw	zero,0(a0)
}
    80006050:	60a2                	ld	ra,8(sp)
    80006052:	6402                	ld	s0,0(sp)
    80006054:	0141                	addi	sp,sp,16
    80006056:	8082                	ret

0000000080006058 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006058:	1141                	addi	sp,sp,-16
    8000605a:	e406                	sd	ra,8(sp)
    8000605c:	e022                	sd	s0,0(sp)
    8000605e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006060:	b0ffb0ef          	jal	ra,80001b6e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006064:	00d5179b          	slliw	a5,a0,0xd
    80006068:	0c201537          	lui	a0,0xc201
    8000606c:	953e                	add	a0,a0,a5
  return irq;
}
    8000606e:	4148                	lw	a0,4(a0)
    80006070:	60a2                	ld	ra,8(sp)
    80006072:	6402                	ld	s0,0(sp)
    80006074:	0141                	addi	sp,sp,16
    80006076:	8082                	ret

0000000080006078 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006078:	1101                	addi	sp,sp,-32
    8000607a:	ec06                	sd	ra,24(sp)
    8000607c:	e822                	sd	s0,16(sp)
    8000607e:	e426                	sd	s1,8(sp)
    80006080:	1000                	addi	s0,sp,32
    80006082:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006084:	aebfb0ef          	jal	ra,80001b6e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006088:	00d5151b          	slliw	a0,a0,0xd
    8000608c:	0c2017b7          	lui	a5,0xc201
    80006090:	97aa                	add	a5,a5,a0
    80006092:	c3c4                	sw	s1,4(a5)
}
    80006094:	60e2                	ld	ra,24(sp)
    80006096:	6442                	ld	s0,16(sp)
    80006098:	64a2                	ld	s1,8(sp)
    8000609a:	6105                	addi	sp,sp,32
    8000609c:	8082                	ret

000000008000609e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000609e:	1141                	addi	sp,sp,-16
    800060a0:	e406                	sd	ra,8(sp)
    800060a2:	e022                	sd	s0,0(sp)
    800060a4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060a6:	479d                	li	a5,7
    800060a8:	04a7ca63          	blt	a5,a0,800060fc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800060ac:	00246797          	auipc	a5,0x246
    800060b0:	a2478793          	addi	a5,a5,-1500 # 8024bad0 <disk>
    800060b4:	97aa                	add	a5,a5,a0
    800060b6:	0187c783          	lbu	a5,24(a5)
    800060ba:	e7b9                	bnez	a5,80006108 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060bc:	00451613          	slli	a2,a0,0x4
    800060c0:	00246797          	auipc	a5,0x246
    800060c4:	a1078793          	addi	a5,a5,-1520 # 8024bad0 <disk>
    800060c8:	6394                	ld	a3,0(a5)
    800060ca:	96b2                	add	a3,a3,a2
    800060cc:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800060d0:	6398                	ld	a4,0(a5)
    800060d2:	9732                	add	a4,a4,a2
    800060d4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800060d8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800060dc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800060e0:	953e                	add	a0,a0,a5
    800060e2:	4785                	li	a5,1
    800060e4:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800060e8:	00246517          	auipc	a0,0x246
    800060ec:	a0050513          	addi	a0,a0,-1536 # 8024bae8 <disk+0x18>
    800060f0:	beefc0ef          	jal	ra,800024de <wakeup>
}
    800060f4:	60a2                	ld	ra,8(sp)
    800060f6:	6402                	ld	s0,0(sp)
    800060f8:	0141                	addi	sp,sp,16
    800060fa:	8082                	ret
    panic("free_desc 1");
    800060fc:	00002517          	auipc	a0,0x2
    80006100:	66c50513          	addi	a0,a0,1644 # 80008768 <syscalls+0x370>
    80006104:	e86fa0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80006108:	00002517          	auipc	a0,0x2
    8000610c:	67050513          	addi	a0,a0,1648 # 80008778 <syscalls+0x380>
    80006110:	e7afa0ef          	jal	ra,8000078a <panic>

0000000080006114 <virtio_disk_init>:
{
    80006114:	1101                	addi	sp,sp,-32
    80006116:	ec06                	sd	ra,24(sp)
    80006118:	e822                	sd	s0,16(sp)
    8000611a:	e426                	sd	s1,8(sp)
    8000611c:	e04a                	sd	s2,0(sp)
    8000611e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006120:	00002597          	auipc	a1,0x2
    80006124:	66858593          	addi	a1,a1,1640 # 80008788 <syscalls+0x390>
    80006128:	00246517          	auipc	a0,0x246
    8000612c:	ad050513          	addi	a0,a0,-1328 # 8024bbf8 <disk+0x128>
    80006130:	b01fa0ef          	jal	ra,80000c30 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006134:	100017b7          	lui	a5,0x10001
    80006138:	4398                	lw	a4,0(a5)
    8000613a:	2701                	sext.w	a4,a4
    8000613c:	747277b7          	lui	a5,0x74727
    80006140:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006144:	14f71063          	bne	a4,a5,80006284 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006148:	100017b7          	lui	a5,0x10001
    8000614c:	43dc                	lw	a5,4(a5)
    8000614e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006150:	4709                	li	a4,2
    80006152:	12e79963          	bne	a5,a4,80006284 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006156:	100017b7          	lui	a5,0x10001
    8000615a:	479c                	lw	a5,8(a5)
    8000615c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000615e:	12e79363          	bne	a5,a4,80006284 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006162:	100017b7          	lui	a5,0x10001
    80006166:	47d8                	lw	a4,12(a5)
    80006168:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000616a:	554d47b7          	lui	a5,0x554d4
    8000616e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006172:	10f71963          	bne	a4,a5,80006284 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006176:	100017b7          	lui	a5,0x10001
    8000617a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000617e:	4705                	li	a4,1
    80006180:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006182:	470d                	li	a4,3
    80006184:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006186:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006188:	c7ffe737          	lui	a4,0xc7ffe
    8000618c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47daa56f>
    80006190:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006192:	2701                	sext.w	a4,a4
    80006194:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006196:	472d                	li	a4,11
    80006198:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000619a:	5bbc                	lw	a5,112(a5)
    8000619c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061a0:	8ba1                	andi	a5,a5,8
    800061a2:	0e078763          	beqz	a5,80006290 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061a6:	100017b7          	lui	a5,0x10001
    800061aa:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800061ae:	43fc                	lw	a5,68(a5)
    800061b0:	2781                	sext.w	a5,a5
    800061b2:	0e079563          	bnez	a5,8000629c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061b6:	100017b7          	lui	a5,0x10001
    800061ba:	5bdc                	lw	a5,52(a5)
    800061bc:	2781                	sext.w	a5,a5
  if(max == 0)
    800061be:	0e078563          	beqz	a5,800062a8 <virtio_disk_init+0x194>
  if(max < NUM)
    800061c2:	471d                	li	a4,7
    800061c4:	0ef77863          	bgeu	a4,a5,800062b4 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    800061c8:	9e5fa0ef          	jal	ra,80000bac <kalloc>
    800061cc:	00246497          	auipc	s1,0x246
    800061d0:	90448493          	addi	s1,s1,-1788 # 8024bad0 <disk>
    800061d4:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800061d6:	9d7fa0ef          	jal	ra,80000bac <kalloc>
    800061da:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800061dc:	9d1fa0ef          	jal	ra,80000bac <kalloc>
    800061e0:	87aa                	mv	a5,a0
    800061e2:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061e4:	6088                	ld	a0,0(s1)
    800061e6:	cd69                	beqz	a0,800062c0 <virtio_disk_init+0x1ac>
    800061e8:	00246717          	auipc	a4,0x246
    800061ec:	8f073703          	ld	a4,-1808(a4) # 8024bad8 <disk+0x8>
    800061f0:	cb61                	beqz	a4,800062c0 <virtio_disk_init+0x1ac>
    800061f2:	c7f9                	beqz	a5,800062c0 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    800061f4:	6605                	lui	a2,0x1
    800061f6:	4581                	li	a1,0
    800061f8:	b8dfa0ef          	jal	ra,80000d84 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061fc:	00246497          	auipc	s1,0x246
    80006200:	8d448493          	addi	s1,s1,-1836 # 8024bad0 <disk>
    80006204:	6605                	lui	a2,0x1
    80006206:	4581                	li	a1,0
    80006208:	6488                	ld	a0,8(s1)
    8000620a:	b7bfa0ef          	jal	ra,80000d84 <memset>
  memset(disk.used, 0, PGSIZE);
    8000620e:	6605                	lui	a2,0x1
    80006210:	4581                	li	a1,0
    80006212:	6888                	ld	a0,16(s1)
    80006214:	b71fa0ef          	jal	ra,80000d84 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006218:	100017b7          	lui	a5,0x10001
    8000621c:	4721                	li	a4,8
    8000621e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006220:	4098                	lw	a4,0(s1)
    80006222:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006226:	40d8                	lw	a4,4(s1)
    80006228:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000622c:	6498                	ld	a4,8(s1)
    8000622e:	0007069b          	sext.w	a3,a4
    80006232:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006236:	9701                	srai	a4,a4,0x20
    80006238:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000623c:	6898                	ld	a4,16(s1)
    8000623e:	0007069b          	sext.w	a3,a4
    80006242:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006246:	9701                	srai	a4,a4,0x20
    80006248:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000624c:	4705                	li	a4,1
    8000624e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006250:	00e48c23          	sb	a4,24(s1)
    80006254:	00e48ca3          	sb	a4,25(s1)
    80006258:	00e48d23          	sb	a4,26(s1)
    8000625c:	00e48da3          	sb	a4,27(s1)
    80006260:	00e48e23          	sb	a4,28(s1)
    80006264:	00e48ea3          	sb	a4,29(s1)
    80006268:	00e48f23          	sb	a4,30(s1)
    8000626c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006270:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006274:	0727a823          	sw	s2,112(a5)
}
    80006278:	60e2                	ld	ra,24(sp)
    8000627a:	6442                	ld	s0,16(sp)
    8000627c:	64a2                	ld	s1,8(sp)
    8000627e:	6902                	ld	s2,0(sp)
    80006280:	6105                	addi	sp,sp,32
    80006282:	8082                	ret
    panic("could not find virtio disk");
    80006284:	00002517          	auipc	a0,0x2
    80006288:	51450513          	addi	a0,a0,1300 # 80008798 <syscalls+0x3a0>
    8000628c:	cfefa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    80006290:	00002517          	auipc	a0,0x2
    80006294:	52850513          	addi	a0,a0,1320 # 800087b8 <syscalls+0x3c0>
    80006298:	cf2fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    8000629c:	00002517          	auipc	a0,0x2
    800062a0:	53c50513          	addi	a0,a0,1340 # 800087d8 <syscalls+0x3e0>
    800062a4:	ce6fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    800062a8:	00002517          	auipc	a0,0x2
    800062ac:	55050513          	addi	a0,a0,1360 # 800087f8 <syscalls+0x400>
    800062b0:	cdafa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    800062b4:	00002517          	auipc	a0,0x2
    800062b8:	56450513          	addi	a0,a0,1380 # 80008818 <syscalls+0x420>
    800062bc:	ccefa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    800062c0:	00002517          	auipc	a0,0x2
    800062c4:	57850513          	addi	a0,a0,1400 # 80008838 <syscalls+0x440>
    800062c8:	cc2fa0ef          	jal	ra,8000078a <panic>

00000000800062cc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062cc:	7119                	addi	sp,sp,-128
    800062ce:	fc86                	sd	ra,120(sp)
    800062d0:	f8a2                	sd	s0,112(sp)
    800062d2:	f4a6                	sd	s1,104(sp)
    800062d4:	f0ca                	sd	s2,96(sp)
    800062d6:	ecce                	sd	s3,88(sp)
    800062d8:	e8d2                	sd	s4,80(sp)
    800062da:	e4d6                	sd	s5,72(sp)
    800062dc:	e0da                	sd	s6,64(sp)
    800062de:	fc5e                	sd	s7,56(sp)
    800062e0:	f862                	sd	s8,48(sp)
    800062e2:	f466                	sd	s9,40(sp)
    800062e4:	f06a                	sd	s10,32(sp)
    800062e6:	ec6e                	sd	s11,24(sp)
    800062e8:	0100                	addi	s0,sp,128
    800062ea:	8aaa                	mv	s5,a0
    800062ec:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062ee:	00c52d03          	lw	s10,12(a0)
    800062f2:	001d1d1b          	slliw	s10,s10,0x1
    800062f6:	1d02                	slli	s10,s10,0x20
    800062f8:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800062fc:	00246517          	auipc	a0,0x246
    80006300:	8fc50513          	addi	a0,a0,-1796 # 8024bbf8 <disk+0x128>
    80006304:	9adfa0ef          	jal	ra,80000cb0 <acquire>
  for(int i = 0; i < 3; i++){
    80006308:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000630a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000630c:	00245b97          	auipc	s7,0x245
    80006310:	7c4b8b93          	addi	s7,s7,1988 # 8024bad0 <disk>
  for(int i = 0; i < 3; i++){
    80006314:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006316:	00246c97          	auipc	s9,0x246
    8000631a:	8e2c8c93          	addi	s9,s9,-1822 # 8024bbf8 <disk+0x128>
    8000631e:	a8a9                	j	80006378 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006320:	00fb8733          	add	a4,s7,a5
    80006324:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006328:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000632a:	0207c563          	bltz	a5,80006354 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000632e:	2905                	addiw	s2,s2,1
    80006330:	0611                	addi	a2,a2,4
    80006332:	05690863          	beq	s2,s6,80006382 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80006336:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006338:	00245717          	auipc	a4,0x245
    8000633c:	79870713          	addi	a4,a4,1944 # 8024bad0 <disk>
    80006340:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006342:	01874683          	lbu	a3,24(a4)
    80006346:	fee9                	bnez	a3,80006320 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006348:	2785                	addiw	a5,a5,1
    8000634a:	0705                	addi	a4,a4,1
    8000634c:	fe979be3          	bne	a5,s1,80006342 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006350:	57fd                	li	a5,-1
    80006352:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006354:	01205b63          	blez	s2,8000636a <virtio_disk_rw+0x9e>
    80006358:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000635a:	000a2503          	lw	a0,0(s4)
    8000635e:	d41ff0ef          	jal	ra,8000609e <free_desc>
      for(int j = 0; j < i; j++)
    80006362:	2d85                	addiw	s11,s11,1
    80006364:	0a11                	addi	s4,s4,4
    80006366:	ffb91ae3          	bne	s2,s11,8000635a <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000636a:	85e6                	mv	a1,s9
    8000636c:	00245517          	auipc	a0,0x245
    80006370:	77c50513          	addi	a0,a0,1916 # 8024bae8 <disk+0x18>
    80006374:	91efc0ef          	jal	ra,80002492 <sleep>
  for(int i = 0; i < 3; i++){
    80006378:	f8040a13          	addi	s4,s0,-128
{
    8000637c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000637e:	894e                	mv	s2,s3
    80006380:	bf5d                	j	80006336 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006382:	f8042583          	lw	a1,-128(s0)
    80006386:	00a58793          	addi	a5,a1,10
    8000638a:	0792                	slli	a5,a5,0x4

  if(write)
    8000638c:	00245617          	auipc	a2,0x245
    80006390:	74460613          	addi	a2,a2,1860 # 8024bad0 <disk>
    80006394:	00f60733          	add	a4,a2,a5
    80006398:	018036b3          	snez	a3,s8
    8000639c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000639e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800063a2:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063a6:	f6078693          	addi	a3,a5,-160
    800063aa:	6218                	ld	a4,0(a2)
    800063ac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063ae:	00878513          	addi	a0,a5,8
    800063b2:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063b4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063b6:	6208                	ld	a0,0(a2)
    800063b8:	96aa                	add	a3,a3,a0
    800063ba:	4741                	li	a4,16
    800063bc:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063be:	4705                	li	a4,1
    800063c0:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063c4:	f8442703          	lw	a4,-124(s0)
    800063c8:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063cc:	0712                	slli	a4,a4,0x4
    800063ce:	953a                	add	a0,a0,a4
    800063d0:	058a8693          	addi	a3,s5,88
    800063d4:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063d6:	6208                	ld	a0,0(a2)
    800063d8:	972a                	add	a4,a4,a0
    800063da:	40000693          	li	a3,1024
    800063de:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063e0:	001c3c13          	seqz	s8,s8
    800063e4:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063e6:	001c6c13          	ori	s8,s8,1
    800063ea:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063ee:	f8842603          	lw	a2,-120(s0)
    800063f2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063f6:	00245697          	auipc	a3,0x245
    800063fa:	6da68693          	addi	a3,a3,1754 # 8024bad0 <disk>
    800063fe:	00258713          	addi	a4,a1,2
    80006402:	0712                	slli	a4,a4,0x4
    80006404:	9736                	add	a4,a4,a3
    80006406:	587d                	li	a6,-1
    80006408:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000640c:	0612                	slli	a2,a2,0x4
    8000640e:	9532                	add	a0,a0,a2
    80006410:	f9078793          	addi	a5,a5,-112
    80006414:	97b6                	add	a5,a5,a3
    80006416:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80006418:	629c                	ld	a5,0(a3)
    8000641a:	97b2                	add	a5,a5,a2
    8000641c:	4605                	li	a2,1
    8000641e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006420:	4509                	li	a0,2
    80006422:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80006426:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000642a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000642e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006432:	6698                	ld	a4,8(a3)
    80006434:	00275783          	lhu	a5,2(a4)
    80006438:	8b9d                	andi	a5,a5,7
    8000643a:	0786                	slli	a5,a5,0x1
    8000643c:	97ba                	add	a5,a5,a4
    8000643e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006442:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006446:	6698                	ld	a4,8(a3)
    80006448:	00275783          	lhu	a5,2(a4)
    8000644c:	2785                	addiw	a5,a5,1
    8000644e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006452:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006456:	100017b7          	lui	a5,0x10001
    8000645a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000645e:	004aa783          	lw	a5,4(s5)
    80006462:	00c79f63          	bne	a5,a2,80006480 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80006466:	00245917          	auipc	s2,0x245
    8000646a:	79290913          	addi	s2,s2,1938 # 8024bbf8 <disk+0x128>
  while(b->disk == 1) {
    8000646e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006470:	85ca                	mv	a1,s2
    80006472:	8556                	mv	a0,s5
    80006474:	81efc0ef          	jal	ra,80002492 <sleep>
  while(b->disk == 1) {
    80006478:	004aa783          	lw	a5,4(s5)
    8000647c:	fe978ae3          	beq	a5,s1,80006470 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80006480:	f8042903          	lw	s2,-128(s0)
    80006484:	00290793          	addi	a5,s2,2
    80006488:	00479713          	slli	a4,a5,0x4
    8000648c:	00245797          	auipc	a5,0x245
    80006490:	64478793          	addi	a5,a5,1604 # 8024bad0 <disk>
    80006494:	97ba                	add	a5,a5,a4
    80006496:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000649a:	00245997          	auipc	s3,0x245
    8000649e:	63698993          	addi	s3,s3,1590 # 8024bad0 <disk>
    800064a2:	00491713          	slli	a4,s2,0x4
    800064a6:	0009b783          	ld	a5,0(s3)
    800064aa:	97ba                	add	a5,a5,a4
    800064ac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064b0:	854a                	mv	a0,s2
    800064b2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064b6:	be9ff0ef          	jal	ra,8000609e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064ba:	8885                	andi	s1,s1,1
    800064bc:	f0fd                	bnez	s1,800064a2 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064be:	00245517          	auipc	a0,0x245
    800064c2:	73a50513          	addi	a0,a0,1850 # 8024bbf8 <disk+0x128>
    800064c6:	883fa0ef          	jal	ra,80000d48 <release>
}
    800064ca:	70e6                	ld	ra,120(sp)
    800064cc:	7446                	ld	s0,112(sp)
    800064ce:	74a6                	ld	s1,104(sp)
    800064d0:	7906                	ld	s2,96(sp)
    800064d2:	69e6                	ld	s3,88(sp)
    800064d4:	6a46                	ld	s4,80(sp)
    800064d6:	6aa6                	ld	s5,72(sp)
    800064d8:	6b06                	ld	s6,64(sp)
    800064da:	7be2                	ld	s7,56(sp)
    800064dc:	7c42                	ld	s8,48(sp)
    800064de:	7ca2                	ld	s9,40(sp)
    800064e0:	7d02                	ld	s10,32(sp)
    800064e2:	6de2                	ld	s11,24(sp)
    800064e4:	6109                	addi	sp,sp,128
    800064e6:	8082                	ret

00000000800064e8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064e8:	1101                	addi	sp,sp,-32
    800064ea:	ec06                	sd	ra,24(sp)
    800064ec:	e822                	sd	s0,16(sp)
    800064ee:	e426                	sd	s1,8(sp)
    800064f0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064f2:	00245497          	auipc	s1,0x245
    800064f6:	5de48493          	addi	s1,s1,1502 # 8024bad0 <disk>
    800064fa:	00245517          	auipc	a0,0x245
    800064fe:	6fe50513          	addi	a0,a0,1790 # 8024bbf8 <disk+0x128>
    80006502:	faefa0ef          	jal	ra,80000cb0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006506:	10001737          	lui	a4,0x10001
    8000650a:	533c                	lw	a5,96(a4)
    8000650c:	8b8d                	andi	a5,a5,3
    8000650e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006510:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006514:	689c                	ld	a5,16(s1)
    80006516:	0204d703          	lhu	a4,32(s1)
    8000651a:	0027d783          	lhu	a5,2(a5)
    8000651e:	04f70663          	beq	a4,a5,8000656a <virtio_disk_intr+0x82>
    __sync_synchronize();
    80006522:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006526:	6898                	ld	a4,16(s1)
    80006528:	0204d783          	lhu	a5,32(s1)
    8000652c:	8b9d                	andi	a5,a5,7
    8000652e:	078e                	slli	a5,a5,0x3
    80006530:	97ba                	add	a5,a5,a4
    80006532:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006534:	00278713          	addi	a4,a5,2
    80006538:	0712                	slli	a4,a4,0x4
    8000653a:	9726                	add	a4,a4,s1
    8000653c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006540:	e321                	bnez	a4,80006580 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006542:	0789                	addi	a5,a5,2
    80006544:	0792                	slli	a5,a5,0x4
    80006546:	97a6                	add	a5,a5,s1
    80006548:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000654a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000654e:	f91fb0ef          	jal	ra,800024de <wakeup>

    disk.used_idx += 1;
    80006552:	0204d783          	lhu	a5,32(s1)
    80006556:	2785                	addiw	a5,a5,1
    80006558:	17c2                	slli	a5,a5,0x30
    8000655a:	93c1                	srli	a5,a5,0x30
    8000655c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006560:	6898                	ld	a4,16(s1)
    80006562:	00275703          	lhu	a4,2(a4)
    80006566:	faf71ee3          	bne	a4,a5,80006522 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    8000656a:	00245517          	auipc	a0,0x245
    8000656e:	68e50513          	addi	a0,a0,1678 # 8024bbf8 <disk+0x128>
    80006572:	fd6fa0ef          	jal	ra,80000d48 <release>
}
    80006576:	60e2                	ld	ra,24(sp)
    80006578:	6442                	ld	s0,16(sp)
    8000657a:	64a2                	ld	s1,8(sp)
    8000657c:	6105                	addi	sp,sp,32
    8000657e:	8082                	ret
      panic("virtio_disk_intr status");
    80006580:	00002517          	auipc	a0,0x2
    80006584:	2d050513          	addi	a0,a0,720 # 80008850 <syscalls+0x458>
    80006588:	a02fa0ef          	jal	ra,8000078a <panic>

000000008000658c <shm_init>:
 * 
 * 创建并初始化保护共享内存对象的自旋锁。
 */
void
shm_init(void)
{
    8000658c:	1141                	addi	sp,sp,-16
    8000658e:	e406                	sd	ra,8(sp)
    80006590:	e022                	sd	s0,0(sp)
    80006592:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    80006594:	00002597          	auipc	a1,0x2
    80006598:	2d458593          	addi	a1,a1,724 # 80008868 <syscalls+0x470>
    8000659c:	00245517          	auipc	a0,0x245
    800065a0:	67450513          	addi	a0,a0,1652 # 8024bc10 <shmt>
    800065a4:	e8cfa0ef          	jal	ra,80000c30 <initlock>
}
    800065a8:	60a2                	ld	ra,8(sp)
    800065aa:	6402                	ld	s0,0(sp)
    800065ac:	0141                	addi	sp,sp,16
    800065ae:	8082                	ret

00000000800065b0 <shm_get>:
 *   2. 如果找到且满足条件，增加引用计数并返回
 *   3. 如果没找到，创建一个新的共享内存对象
 */
int
shm_get(int key, int npages)
{
    800065b0:	7179                	addi	sp,sp,-48
    800065b2:	f406                	sd	ra,40(sp)
    800065b4:	f022                	sd	s0,32(sp)
    800065b6:	ec26                	sd	s1,24(sp)
    800065b8:	e84a                	sd	s2,16(sp)
    800065ba:	e44e                	sd	s3,8(sp)
    800065bc:	1800                	addi	s0,sp,48
    800065be:	892a                	mv	s2,a0
    800065c0:	89ae                	mv	s3,a1
  acquire(&shmt.lock);
    800065c2:	00245517          	auipc	a0,0x245
    800065c6:	64e50513          	addi	a0,a0,1614 # 8024bc10 <shmt>
    800065ca:	ee6fa0ef          	jal	ra,80000cb0 <acquire>

  // 先查找已有的共享内存对象
  for(int i=0;i<NSHM;i++){
    800065ce:	00245697          	auipc	a3,0x245
    800065d2:	65a68693          	addi	a3,a3,1626 # 8024bc28 <shmt+0x18>
  acquire(&shmt.lock);
    800065d6:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    800065d8:	4481                	li	s1,0
    800065da:	6605                	lui	a2,0x1
    800065dc:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    800065e0:	4841                	li	a6,16
    800065e2:	a015                	j	80006606 <shm_get+0x56>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查对象是否已被标记删除
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
    800065e4:	00245517          	auipc	a0,0x245
    800065e8:	62c50513          	addi	a0,a0,1580 # 8024bc10 <shmt>
    800065ec:	f5cfa0ef          	jal	ra,80000d48 <release>
        return -1;
    800065f0:	54fd                	li	s1,-1
    800065f2:	a879                	j	80006690 <shm_get+0xe0>
      }
      // 检查请求的页数是否超过对象的总页数
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    800065f4:	853a                	mv	a0,a4
    800065f6:	f52fa0ef          	jal	ra,80000d48 <release>
        return -1;
    800065fa:	54fd                	li	s1,-1
    800065fc:	a851                	j	80006690 <shm_get+0xe0>
  for(int i=0;i<NSHM;i++){
    800065fe:	2485                	addiw	s1,s1,1
    80006600:	97b2                	add	a5,a5,a2
    80006602:	07048563          	beq	s1,a6,8000666c <shm_get+0xbc>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006606:	4398                	lw	a4,0(a5)
    80006608:	db7d                	beqz	a4,800065fe <shm_get+0x4e>
    8000660a:	43d8                	lw	a4,4(a5)
    8000660c:	ff2719e3          	bne	a4,s2,800065fe <shm_get+0x4e>
      if(shmt.obj[i].deleted){
    80006610:	6785                	lui	a5,0x1
    80006612:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006616:	02e486b3          	mul	a3,s1,a4
    8000661a:	00245717          	auipc	a4,0x245
    8000661e:	5f670713          	addi	a4,a4,1526 # 8024bc10 <shmt>
    80006622:	9736                	add	a4,a4,a3
    80006624:	97ba                	add	a5,a5,a4
    80006626:	82c7a783          	lw	a5,-2004(a5)
    8000662a:	ffcd                	bnez	a5,800065e4 <shm_get+0x34>
      if(npages > shmt.obj[i].npages){
    8000662c:	6785                	lui	a5,0x1
    8000662e:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006632:	02f487b3          	mul	a5,s1,a5
    80006636:	00245717          	auipc	a4,0x245
    8000663a:	5da70713          	addi	a4,a4,1498 # 8024bc10 <shmt>
    8000663e:	97ba                	add	a5,a5,a4
    80006640:	539c                	lw	a5,32(a5)
    80006642:	fb37c9e3          	blt	a5,s3,800065f4 <shm_get+0x44>
      }
      // 增加引用计数
      shmt.obj[i].refcnt++;
    80006646:	00245517          	auipc	a0,0x245
    8000664a:	5ca50513          	addi	a0,a0,1482 # 8024bc10 <shmt>
    8000664e:	6785                	lui	a5,0x1
    80006650:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006654:	02e48733          	mul	a4,s1,a4
    80006658:	972a                	add	a4,a4,a0
    8000665a:	97ba                	add	a5,a5,a4
    8000665c:	8287a703          	lw	a4,-2008(a5)
    80006660:	2705                	addiw	a4,a4,1
    80006662:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    80006666:	ee2fa0ef          	jal	ra,80000d48 <release>
      return i;
    8000666a:	a01d                	j	80006690 <shm_get+0xe0>
    }
  }

  // 如果没有找到，创建一个新的共享内存对象
  for(int i=0;i<NSHM;i++){
    8000666c:	4481                	li	s1,0
    8000666e:	6705                	lui	a4,0x1
    80006670:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006674:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    80006676:	429c                	lw	a5,0(a3)
    80006678:	c785                	beqz	a5,800066a0 <shm_get+0xf0>
  for(int i=0;i<NSHM;i++){
    8000667a:	2485                	addiw	s1,s1,1
    8000667c:	96ba                	add	a3,a3,a4
    8000667e:	fec49ce3          	bne	s1,a2,80006676 <shm_get+0xc6>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    80006682:	00245517          	auipc	a0,0x245
    80006686:	58e50513          	addi	a0,a0,1422 # 8024bc10 <shmt>
    8000668a:	ebefa0ef          	jal	ra,80000d48 <release>
  return -1;  // 没有空闲的共享内存对象槽位
    8000668e:	54fd                	li	s1,-1
}
    80006690:	8526                	mv	a0,s1
    80006692:	70a2                	ld	ra,40(sp)
    80006694:	7402                	ld	s0,32(sp)
    80006696:	64e2                	ld	s1,24(sp)
    80006698:	6942                	ld	s2,16(sp)
    8000669a:	69a2                	ld	s3,8(sp)
    8000669c:	6145                	addi	sp,sp,48
    8000669e:	8082                	ret
      shmt.obj[i].deleted = 0;
    800066a0:	00245617          	auipc	a2,0x245
    800066a4:	57060613          	addi	a2,a2,1392 # 8024bc10 <shmt>
    800066a8:	6785                	lui	a5,0x1
    800066aa:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800066ae:	02e486b3          	mul	a3,s1,a4
    800066b2:	00d60733          	add	a4,a2,a3
    800066b6:	97ba                	add	a5,a5,a4
    800066b8:	8207a623          	sw	zero,-2004(a5)
      shmt.obj[i].used = 1;
    800066bc:	4585                	li	a1,1
    800066be:	cf0c                	sw	a1,24(a4)
      shmt.obj[i].key = key;
    800066c0:	01272e23          	sw	s2,28(a4)
      shmt.obj[i].npages = npages;
    800066c4:	03372023          	sw	s3,32(a4)
      shmt.obj[i].refcnt = 1;
    800066c8:	82b7a423          	sw	a1,-2008(a5)
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
    800066cc:	02868793          	addi	a5,a3,40
    800066d0:	97b2                	add	a5,a5,a2
    800066d2:	00246717          	auipc	a4,0x246
    800066d6:	d6670713          	addi	a4,a4,-666 # 8024c438 <shmt+0x828>
    800066da:	9736                	add	a4,a4,a3
    800066dc:	0007b023          	sd	zero,0(a5)
    800066e0:	07a1                	addi	a5,a5,8
    800066e2:	fee79de3          	bne	a5,a4,800066dc <shm_get+0x12c>
      release(&shmt.lock);
    800066e6:	00245517          	auipc	a0,0x245
    800066ea:	52a50513          	addi	a0,a0,1322 # 8024bc10 <shmt>
    800066ee:	e5afa0ef          	jal	ra,80000d48 <release>
      return i;
    800066f2:	bf79                	j	80006690 <shm_get+0xe0>

00000000800066f4 <shm_put>:
 *   - 使用 kfree 释放物理页，kfree 会正确处理页的引用计数
 *   - 如果对象已被标记删除，当引用计数为 0 时也会被完全释放
 */
void
shm_put(int key)
{
    800066f4:	7179                	addi	sp,sp,-48
    800066f6:	f406                	sd	ra,40(sp)
    800066f8:	f022                	sd	s0,32(sp)
    800066fa:	ec26                	sd	s1,24(sp)
    800066fc:	e84a                	sd	s2,16(sp)
    800066fe:	e44e                	sd	s3,8(sp)
    80006700:	e052                	sd	s4,0(sp)
    80006702:	1800                	addi	s0,sp,48
    80006704:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    80006706:	00245517          	auipc	a0,0x245
    8000670a:	50a50513          	addi	a0,a0,1290 # 8024bc10 <shmt>
    8000670e:	da2fa0ef          	jal	ra,80000cb0 <acquire>
  for(int i=0;i<NSHM;i++){
    80006712:	00245797          	auipc	a5,0x245
    80006716:	51678793          	addi	a5,a5,1302 # 8024bc28 <shmt+0x18>
    8000671a:	4481                	li	s1,0
    8000671c:	6685                	lui	a3,0x1
    8000671e:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006722:	4641                	li	a2,16
    80006724:	a0b5                	j	80006790 <shm_put+0x9c>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查引用计数的有效性
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
    80006726:	00002517          	auipc	a0,0x2
    8000672a:	14a50513          	addi	a0,a0,330 # 80008870 <syscalls+0x478>
    8000672e:	85cfa0ef          	jal	ra,8000078a <panic>
      shmt.obj[i].refcnt--;
      
      // 如果引用计数为 0，释放所有资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j=0;j<shmt.obj[i].npages;j++){
    80006732:	2985                	addiw	s3,s3,1
    80006734:	0921                	addi	s2,s2,8
    80006736:	020a2783          	lw	a5,32(s4)
    8000673a:	00f9da63          	bge	s3,a5,8000674e <shm_put+0x5a>
          if(shmt.obj[i].pa[j]){
    8000673e:	00093503          	ld	a0,0(s2)
    80006742:	d965                	beqz	a0,80006732 <shm_put+0x3e>
            kfree((void*)shmt.obj[i].pa[j]);
    80006744:	b3afa0ef          	jal	ra,80000a7e <kfree>
            shmt.obj[i].pa[j] = 0;
    80006748:	00093023          	sd	zero,0(s2)
    8000674c:	b7dd                	j	80006732 <shm_put+0x3e>
          }
        }
        // 重置对象状态
        shmt.obj[i].used = 0;
    8000674e:	6785                	lui	a5,0x1
    80006750:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006754:	02e484b3          	mul	s1,s1,a4
    80006758:	00245717          	auipc	a4,0x245
    8000675c:	4b870713          	addi	a4,a4,1208 # 8024bc10 <shmt>
    80006760:	94ba                	add	s1,s1,a4
    80006762:	0004ac23          	sw	zero,24(s1)
        shmt.obj[i].deleted = 0;
    80006766:	97a6                	add	a5,a5,s1
    80006768:	8207a623          	sw	zero,-2004(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    8000676c:	00245517          	auipc	a0,0x245
    80006770:	4a450513          	addi	a0,a0,1188 # 8024bc10 <shmt>
    80006774:	dd4fa0ef          	jal	ra,80000d48 <release>
}
    80006778:	70a2                	ld	ra,40(sp)
    8000677a:	7402                	ld	s0,32(sp)
    8000677c:	64e2                	ld	s1,24(sp)
    8000677e:	6942                	ld	s2,16(sp)
    80006780:	69a2                	ld	s3,8(sp)
    80006782:	6a02                	ld	s4,0(sp)
    80006784:	6145                	addi	sp,sp,48
    80006786:	8082                	ret
  for(int i=0;i<NSHM;i++){
    80006788:	2485                	addiw	s1,s1,1
    8000678a:	97b6                	add	a5,a5,a3
    8000678c:	fec480e3          	beq	s1,a2,8000676c <shm_put+0x78>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006790:	4398                	lw	a4,0(a5)
    80006792:	db7d                	beqz	a4,80006788 <shm_put+0x94>
    80006794:	43d8                	lw	a4,4(a5)
    80006796:	ff2719e3          	bne	a4,s2,80006788 <shm_put+0x94>
      if(shmt.obj[i].refcnt < 1)
    8000679a:	6785                	lui	a5,0x1
    8000679c:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800067a0:	02e486b3          	mul	a3,s1,a4
    800067a4:	00245717          	auipc	a4,0x245
    800067a8:	46c70713          	addi	a4,a4,1132 # 8024bc10 <shmt>
    800067ac:	9736                	add	a4,a4,a3
    800067ae:	97ba                	add	a5,a5,a4
    800067b0:	8287a783          	lw	a5,-2008(a5)
    800067b4:	f6f059e3          	blez	a5,80006726 <shm_put+0x32>
      shmt.obj[i].refcnt--;
    800067b8:	37fd                	addiw	a5,a5,-1
    800067ba:	0007899b          	sext.w	s3,a5
    800067be:	6705                	lui	a4,0x1
    800067c0:	81870693          	addi	a3,a4,-2024 # 818 <_entry-0x7ffff7e8>
    800067c4:	02d48633          	mul	a2,s1,a3
    800067c8:	00245697          	auipc	a3,0x245
    800067cc:	44868693          	addi	a3,a3,1096 # 8024bc10 <shmt>
    800067d0:	96b2                	add	a3,a3,a2
    800067d2:	9736                	add	a4,a4,a3
    800067d4:	82f72423          	sw	a5,-2008(a4)
      if(shmt.obj[i].refcnt == 0){
    800067d8:	f8099ae3          	bnez	s3,8000676c <shm_put+0x78>
        for(int j=0;j<shmt.obj[i].npages;j++){
    800067dc:	529c                	lw	a5,32(a3)
    800067de:	f6f058e3          	blez	a5,8000674e <shm_put+0x5a>
    800067e2:	00245797          	auipc	a5,0x245
    800067e6:	45678793          	addi	a5,a5,1110 # 8024bc38 <shmt+0x28>
    800067ea:	00f60933          	add	s2,a2,a5
    800067ee:	8a36                	mv	s4,a3
    800067f0:	b7b9                	j	8000673e <shm_put+0x4a>

00000000800067f2 <shm_getpa>:
 *   3. 如果该页尚未分配，分配一个新的物理页并初始化为0
 *   4. 返回该页的物理地址
 */
uint64
shm_getpa(int key, int page_index)
{
    800067f2:	7179                	addi	sp,sp,-48
    800067f4:	f406                	sd	ra,40(sp)
    800067f6:	f022                	sd	s0,32(sp)
    800067f8:	ec26                	sd	s1,24(sp)
    800067fa:	e84a                	sd	s2,16(sp)
    800067fc:	e44e                	sd	s3,8(sp)
    800067fe:	e052                	sd	s4,0(sp)
    80006800:	1800                	addi	s0,sp,48
    80006802:	892a                	mv	s2,a0
    80006804:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    80006806:	00245517          	auipc	a0,0x245
    8000680a:	40a50513          	addi	a0,a0,1034 # 8024bc10 <shmt>
    8000680e:	ca2fa0ef          	jal	ra,80000cb0 <acquire>

  for(int i=0;i<NSHM;i++){
    80006812:	00245797          	auipc	a5,0x245
    80006816:	41678793          	addi	a5,a5,1046 # 8024bc28 <shmt+0x18>
    8000681a:	4481                	li	s1,0
    8000681c:	6685                	lui	a3,0x1
    8000681e:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006822:	4641                	li	a2,16
    80006824:	a82d                	j	8000685e <shm_getpa+0x6c>
        break;
      }
      
      // 如果该页尚未分配，执行惰性分配
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    80006826:	b86fa0ef          	jal	ra,80000bac <kalloc>
    8000682a:	8a2a                	mv	s4,a0
        if(mem == 0){
    8000682c:	cd41                	beqz	a0,800068c4 <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        // 初始化新分配的物理页为0
        memset(mem, 0, PGSIZE);
    8000682e:	6605                	lui	a2,0x1
    80006830:	4581                	li	a1,0
    80006832:	d52fa0ef          	jal	ra,80000d84 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    80006836:	00649793          	slli	a5,s1,0x6
    8000683a:	97a6                	add	a5,a5,s1
    8000683c:	078a                	slli	a5,a5,0x2
    8000683e:	8f85                	sub	a5,a5,s1
    80006840:	97ce                	add	a5,a5,s3
    80006842:	0791                	addi	a5,a5,4
    80006844:	078e                	slli	a5,a5,0x3
    80006846:	00245717          	auipc	a4,0x245
    8000684a:	3ca70713          	addi	a4,a4,970 # 8024bc10 <shmt>
    8000684e:	97ba                	add	a5,a5,a4
    80006850:	0147b423          	sd	s4,8(a5)
    80006854:	a0b9                	j	800068a2 <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    80006856:	2485                	addiw	s1,s1,1
    80006858:	97b6                	add	a5,a5,a3
    8000685a:	06c48463          	beq	s1,a2,800068c2 <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000685e:	4398                	lw	a4,0(a5)
    80006860:	db7d                	beqz	a4,80006856 <shm_getpa+0x64>
    80006862:	43d8                	lw	a4,4(a5)
    80006864:	ff2719e3          	bne	a4,s2,80006856 <shm_getpa+0x64>
        pa = 0;
    80006868:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    8000686a:	0409cd63          	bltz	s3,800068c4 <shm_getpa+0xd2>
    8000686e:	6785                	lui	a5,0x1
    80006870:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006874:	02f487b3          	mul	a5,s1,a5
    80006878:	00245717          	auipc	a4,0x245
    8000687c:	39870713          	addi	a4,a4,920 # 8024bc10 <shmt>
    80006880:	97ba                	add	a5,a5,a4
    80006882:	539c                	lw	a5,32(a5)
    80006884:	04f9d063          	bge	s3,a5,800068c4 <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    80006888:	00649793          	slli	a5,s1,0x6
    8000688c:	97a6                	add	a5,a5,s1
    8000688e:	078a                	slli	a5,a5,0x2
    80006890:	8f85                	sub	a5,a5,s1
    80006892:	97ce                	add	a5,a5,s3
    80006894:	0791                	addi	a5,a5,4
    80006896:	078e                	slli	a5,a5,0x3
    80006898:	97ba                	add	a5,a5,a4
    8000689a:	0087b903          	ld	s2,8(a5)
    8000689e:	f80904e3          	beqz	s2,80006826 <shm_getpa+0x34>
      }
      
      pa = shmt.obj[i].pa[page_index];
    800068a2:	00649793          	slli	a5,s1,0x6
    800068a6:	97a6                	add	a5,a5,s1
    800068a8:	078a                	slli	a5,a5,0x2
    800068aa:	8f85                	sub	a5,a5,s1
    800068ac:	97ce                	add	a5,a5,s3
    800068ae:	0791                	addi	a5,a5,4
    800068b0:	078e                	slli	a5,a5,0x3
    800068b2:	00245717          	auipc	a4,0x245
    800068b6:	35e70713          	addi	a4,a4,862 # 8024bc10 <shmt>
    800068ba:	97ba                	add	a5,a5,a4
    800068bc:	0087b903          	ld	s2,8(a5)
      break;
    800068c0:	a011                	j	800068c4 <shm_getpa+0xd2>
  uint64 pa = 0;
    800068c2:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    800068c4:	00245517          	auipc	a0,0x245
    800068c8:	34c50513          	addi	a0,a0,844 # 8024bc10 <shmt>
    800068cc:	c7cfa0ef          	jal	ra,80000d48 <release>
  vmstats_inc_shm();  // 更新共享内存统计信息
    800068d0:	4e4000ef          	jal	ra,80006db4 <vmstats_inc_shm>

  return pa;
}
    800068d4:	854a                	mv	a0,s2
    800068d6:	70a2                	ld	ra,40(sp)
    800068d8:	7402                	ld	s0,32(sp)
    800068da:	64e2                	ld	s1,24(sp)
    800068dc:	6942                	ld	s2,16(sp)
    800068de:	69a2                	ld	s3,8(sp)
    800068e0:	6a02                	ld	s4,0(sp)
    800068e2:	6145                	addi	sp,sp,48
    800068e4:	8082                	ret

00000000800068e6 <shm_ctl>:
 */
int
shm_ctl(int key, int cmd)
{
  // 目前仅支持 IPC_RMID 命令
  if(cmd != IPC_RMID)
    800068e6:	10059363          	bnez	a1,800069ec <shm_ctl+0x106>
{
    800068ea:	7139                	addi	sp,sp,-64
    800068ec:	fc06                	sd	ra,56(sp)
    800068ee:	f822                	sd	s0,48(sp)
    800068f0:	f426                	sd	s1,40(sp)
    800068f2:	f04a                	sd	s2,32(sp)
    800068f4:	ec4e                	sd	s3,24(sp)
    800068f6:	e852                	sd	s4,16(sp)
    800068f8:	e456                	sd	s5,8(sp)
    800068fa:	0080                	addi	s0,sp,64
    800068fc:	892a                	mv	s2,a0
    800068fe:	89ae                	mv	s3,a1
    return -1;

  acquire(&shmt.lock);
    80006900:	00245517          	auipc	a0,0x245
    80006904:	31050513          	addi	a0,a0,784 # 8024bc10 <shmt>
    80006908:	ba8fa0ef          	jal	ra,80000cb0 <acquire>

  for(int i = 0; i < NSHM; i++){
    8000690c:	00245797          	auipc	a5,0x245
    80006910:	31c78793          	addi	a5,a5,796 # 8024bc28 <shmt+0x18>
    80006914:	84ce                	mv	s1,s3
    80006916:	6685                	lui	a3,0x1
    80006918:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000691c:	4641                	li	a2,16
    8000691e:	a8b1                	j	8000697a <shm_ctl+0x94>
      // 如果当前没有任何进程引用，立即释放资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
    80006920:	95efa0ef          	jal	ra,80000a7e <kfree>
            shmt.obj[i].pa[j] = 0;
    80006924:	00093023          	sd	zero,0(s2)
        for(int j = 0; j < shmt.obj[i].npages; j++){
    80006928:	2a05                	addiw	s4,s4,1
    8000692a:	0921                	addi	s2,s2,8
    8000692c:	020aa783          	lw	a5,32(s5)
    80006930:	00fa5663          	bge	s4,a5,8000693c <shm_ctl+0x56>
          if(shmt.obj[i].pa[j]){
    80006934:	00093503          	ld	a0,0(s2)
    80006938:	d965                	beqz	a0,80006928 <shm_ctl+0x42>
    8000693a:	b7dd                	j	80006920 <shm_ctl+0x3a>
          }
        }
        // 完全重置对象状态
        shmt.obj[i].used = 0;
    8000693c:	6705                	lui	a4,0x1
    8000693e:	81870793          	addi	a5,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006942:	02f484b3          	mul	s1,s1,a5
    80006946:	00245797          	auipc	a5,0x245
    8000694a:	2ca78793          	addi	a5,a5,714 # 8024bc10 <shmt>
    8000694e:	94be                	add	s1,s1,a5
    80006950:	0004ac23          	sw	zero,24(s1)
        shmt.obj[i].deleted = 0;
    80006954:	9726                	add	a4,a4,s1
    80006956:	82072623          	sw	zero,-2004(a4)
        shmt.obj[i].key = 0;     
    8000695a:	0004ae23          	sw	zero,28(s1)
        shmt.obj[i].npages = 0;  
    8000695e:	0204a023          	sw	zero,32(s1)
      }

      release(&shmt.lock);
    80006962:	00245517          	auipc	a0,0x245
    80006966:	2ae50513          	addi	a0,a0,686 # 8024bc10 <shmt>
    8000696a:	bdefa0ef          	jal	ra,80000d48 <release>
      return 0;
    8000696e:	854e                	mv	a0,s3
    80006970:	a0ad                	j	800069da <shm_ctl+0xf4>
  for(int i = 0; i < NSHM; i++){
    80006972:	2485                	addiw	s1,s1,1
    80006974:	97b6                	add	a5,a5,a3
    80006976:	04c48b63          	beq	s1,a2,800069cc <shm_ctl+0xe6>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000697a:	4398                	lw	a4,0(a5)
    8000697c:	db7d                	beqz	a4,80006972 <shm_ctl+0x8c>
    8000697e:	43d8                	lw	a4,4(a5)
    80006980:	ff2719e3          	bne	a4,s2,80006972 <shm_ctl+0x8c>
      shmt.obj[i].deleted = 1;
    80006984:	6785                	lui	a5,0x1
    80006986:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000698a:	02e486b3          	mul	a3,s1,a4
    8000698e:	00245717          	auipc	a4,0x245
    80006992:	28270713          	addi	a4,a4,642 # 8024bc10 <shmt>
    80006996:	9736                	add	a4,a4,a3
    80006998:	97ba                	add	a5,a5,a4
    8000699a:	4705                	li	a4,1
    8000699c:	82e7a623          	sw	a4,-2004(a5)
      if(shmt.obj[i].refcnt == 0){
    800069a0:	8287aa03          	lw	s4,-2008(a5)
    800069a4:	fa0a1fe3          	bnez	s4,80006962 <shm_ctl+0x7c>
        for(int j = 0; j < shmt.obj[i].npages; j++){
    800069a8:	00245717          	auipc	a4,0x245
    800069ac:	26870713          	addi	a4,a4,616 # 8024bc10 <shmt>
    800069b0:	00d707b3          	add	a5,a4,a3
    800069b4:	539c                	lw	a5,32(a5)
    800069b6:	f8f053e3          	blez	a5,8000693c <shm_ctl+0x56>
    800069ba:	00245797          	auipc	a5,0x245
    800069be:	27e78793          	addi	a5,a5,638 # 8024bc38 <shmt+0x28>
    800069c2:	00f68933          	add	s2,a3,a5
    800069c6:	00d70ab3          	add	s5,a4,a3
    800069ca:	b7ad                	j	80006934 <shm_ctl+0x4e>
    }
  }

  release(&shmt.lock);
    800069cc:	00245517          	auipc	a0,0x245
    800069d0:	24450513          	addi	a0,a0,580 # 8024bc10 <shmt>
    800069d4:	b74fa0ef          	jal	ra,80000d48 <release>
  return -1; // key 对应的共享内存对象不存在
    800069d8:	557d                	li	a0,-1
}
    800069da:	70e2                	ld	ra,56(sp)
    800069dc:	7442                	ld	s0,48(sp)
    800069de:	74a2                	ld	s1,40(sp)
    800069e0:	7902                	ld	s2,32(sp)
    800069e2:	69e2                	ld	s3,24(sp)
    800069e4:	6a42                	ld	s4,16(sp)
    800069e6:	6aa2                	ld	s5,8(sp)
    800069e8:	6121                	addi	sp,sp,64
    800069ea:	8082                	ret
    return -1;
    800069ec:	557d                	li	a0,-1
}
    800069ee:	8082                	ret

00000000800069f0 <shm_is_deleted>:
 *   - 如果对象不存在，默认返回 0（允许创建新对象）
 *   - 用于在 shm_get 时检查是否可以创建或访问共享内存对象
 */
int
shm_is_deleted(int key)
{
    800069f0:	1101                	addi	sp,sp,-32
    800069f2:	ec06                	sd	ra,24(sp)
    800069f4:	e822                	sd	s0,16(sp)
    800069f6:	e426                	sd	s1,8(sp)
    800069f8:	1000                	addi	s0,sp,32
    800069fa:	84aa                	mv	s1,a0
  int del = 0; // 默认0,不存在就允许创建
  acquire(&shmt.lock);
    800069fc:	00245517          	auipc	a0,0x245
    80006a00:	21450513          	addi	a0,a0,532 # 8024bc10 <shmt>
    80006a04:	aacfa0ef          	jal	ra,80000cb0 <acquire>
  for(int i=0;i<NSHM;i++){
    80006a08:	00245797          	auipc	a5,0x245
    80006a0c:	22078793          	addi	a5,a5,544 # 8024bc28 <shmt+0x18>
    80006a10:	4701                	li	a4,0
    80006a12:	6605                	lui	a2,0x1
    80006a14:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006a18:	45c1                	li	a1,16
    80006a1a:	a029                	j	80006a24 <shm_is_deleted+0x34>
    80006a1c:	2705                	addiw	a4,a4,1
    80006a1e:	97b2                	add	a5,a5,a2
    80006a20:	02b70563          	beq	a4,a1,80006a4a <shm_is_deleted+0x5a>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006a24:	4394                	lw	a3,0(a5)
    80006a26:	dafd                	beqz	a3,80006a1c <shm_is_deleted+0x2c>
    80006a28:	43d4                	lw	a3,4(a5)
    80006a2a:	fe9699e3          	bne	a3,s1,80006a1c <shm_is_deleted+0x2c>
      del = shmt.obj[i].deleted;
    80006a2e:	6785                	lui	a5,0x1
    80006a30:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006a34:	02d70733          	mul	a4,a4,a3
    80006a38:	00245697          	auipc	a3,0x245
    80006a3c:	1d868693          	addi	a3,a3,472 # 8024bc10 <shmt>
    80006a40:	9736                	add	a4,a4,a3
    80006a42:	97ba                	add	a5,a5,a4
    80006a44:	82c7a483          	lw	s1,-2004(a5)
      break;
    80006a48:	a011                	j	80006a4c <shm_is_deleted+0x5c>
  int del = 0; // 默认0,不存在就允许创建
    80006a4a:	4481                	li	s1,0
    }
  }
  release(&shmt.lock);
    80006a4c:	00245517          	auipc	a0,0x245
    80006a50:	1c450513          	addi	a0,a0,452 # 8024bc10 <shmt>
    80006a54:	af4fa0ef          	jal	ra,80000d48 <release>
  //shm_dump(key);
  return del;
}
    80006a58:	8526                	mv	a0,s1
    80006a5a:	60e2                	ld	ra,24(sp)
    80006a5c:	6442                	ld	s0,16(sp)
    80006a5e:	64a2                	ld	s1,8(sp)
    80006a60:	6105                	addi	sp,sp,32
    80006a62:	8082                	ret

0000000080006a64 <sem_lookup>:
}

// 找到 key 对应 sem；不存在返回 -1
static int
sem_lookup(int key)
{
    80006a64:	1141                	addi	sp,sp,-16
    80006a66:	e422                	sd	s0,8(sp)
    80006a68:	0800                	addi	s0,sp,16
    80006a6a:	862a                	mv	a2,a0
  for(int i = 0; i < NSEM; i++){
    80006a6c:	0024d797          	auipc	a5,0x24d
    80006a70:	35478793          	addi	a5,a5,852 # 80253dc0 <semt+0x18>
    80006a74:	4501                	li	a0,0
    80006a76:	04000693          	li	a3,64
    80006a7a:	a029                	j	80006a84 <sem_lookup+0x20>
    80006a7c:	2505                	addiw	a0,a0,1
    80006a7e:	07c1                	addi	a5,a5,16
    80006a80:	00d50a63          	beq	a0,a3,80006a94 <sem_lookup+0x30>
    if(semt.s[i].used && semt.s[i].key == key)
    80006a84:	4398                	lw	a4,0(a5)
    80006a86:	db7d                	beqz	a4,80006a7c <sem_lookup+0x18>
    80006a88:	43d8                	lw	a4,4(a5)
    80006a8a:	fec719e3          	bne	a4,a2,80006a7c <sem_lookup+0x18>
      return i;
  }
  return -1;
}
    80006a8e:	6422                	ld	s0,8(sp)
    80006a90:	0141                	addi	sp,sp,16
    80006a92:	8082                	ret
  return -1;
    80006a94:	557d                	li	a0,-1
    80006a96:	bfe5                	j	80006a8e <sem_lookup+0x2a>

0000000080006a98 <seminit>:
{
    80006a98:	1141                	addi	sp,sp,-16
    80006a9a:	e406                	sd	ra,8(sp)
    80006a9c:	e022                	sd	s0,0(sp)
    80006a9e:	0800                	addi	s0,sp,16
  initlock(&semt.lock, "semt");
    80006aa0:	00002597          	auipc	a1,0x2
    80006aa4:	de058593          	addi	a1,a1,-544 # 80008880 <syscalls+0x488>
    80006aa8:	0024d517          	auipc	a0,0x24d
    80006aac:	30050513          	addi	a0,a0,768 # 80253da8 <semt>
    80006ab0:	980fa0ef          	jal	ra,80000c30 <initlock>
}
    80006ab4:	60a2                	ld	ra,8(sp)
    80006ab6:	6402                	ld	s0,0(sp)
    80006ab8:	0141                	addi	sp,sp,16
    80006aba:	8082                	ret

0000000080006abc <sem_open>:

// 创建或返回已有
int
sem_open(int key, int init)
{
    80006abc:	7179                	addi	sp,sp,-48
    80006abe:	f406                	sd	ra,40(sp)
    80006ac0:	f022                	sd	s0,32(sp)
    80006ac2:	ec26                	sd	s1,24(sp)
    80006ac4:	e84a                	sd	s2,16(sp)
    80006ac6:	e44e                	sd	s3,8(sp)
    80006ac8:	1800                	addi	s0,sp,48
    80006aca:	892a                	mv	s2,a0
    80006acc:	89ae                	mv	s3,a1
  acquire(&semt.lock);
    80006ace:	0024d517          	auipc	a0,0x24d
    80006ad2:	2da50513          	addi	a0,a0,730 # 80253da8 <semt>
    80006ad6:	9dafa0ef          	jal	ra,80000cb0 <acquire>

  int idx = sem_lookup(key);
    80006ada:	854a                	mv	a0,s2
    80006adc:	f89ff0ef          	jal	ra,80006a64 <sem_lookup>
  if(idx >= 0){
    80006ae0:	0024d717          	auipc	a4,0x24d
    80006ae4:	2e070713          	addi	a4,a4,736 # 80253dc0 <semt+0x18>
    release(&semt.lock);
    return 0;  // 已存在，直接成功
  }

  for(int i = 0; i < NSEM; i++){
    80006ae8:	4781                	li	a5,0
    80006aea:	04000693          	li	a3,64
  if(idx >= 0){
    80006aee:	02055063          	bgez	a0,80006b0e <sem_open+0x52>
    if(!semt.s[i].used){
    80006af2:	4304                	lw	s1,0(a4)
    80006af4:	c48d                	beqz	s1,80006b1e <sem_open+0x62>
  for(int i = 0; i < NSEM; i++){
    80006af6:	2785                	addiw	a5,a5,1
    80006af8:	0741                	addi	a4,a4,16
    80006afa:	fed79ce3          	bne	a5,a3,80006af2 <sem_open+0x36>
      release(&semt.lock);
      return 0;
    }
  }

  release(&semt.lock);
    80006afe:	0024d517          	auipc	a0,0x24d
    80006b02:	2aa50513          	addi	a0,a0,682 # 80253da8 <semt>
    80006b06:	a42fa0ef          	jal	ra,80000d48 <release>
  return -1;
    80006b0a:	54fd                	li	s1,-1
    80006b0c:	a815                	j	80006b40 <sem_open+0x84>
    release(&semt.lock);
    80006b0e:	0024d517          	auipc	a0,0x24d
    80006b12:	29a50513          	addi	a0,a0,666 # 80253da8 <semt>
    80006b16:	a32fa0ef          	jal	ra,80000d48 <release>
    return 0;  // 已存在，直接成功
    80006b1a:	4481                	li	s1,0
    80006b1c:	a015                	j	80006b40 <sem_open+0x84>
      semt.s[i].used = 1;
    80006b1e:	0024d517          	auipc	a0,0x24d
    80006b22:	28a50513          	addi	a0,a0,650 # 80253da8 <semt>
    80006b26:	0785                	addi	a5,a5,1
    80006b28:	0792                	slli	a5,a5,0x4
    80006b2a:	97aa                	add	a5,a5,a0
    80006b2c:	4705                	li	a4,1
    80006b2e:	c798                	sw	a4,8(a5)
      semt.s[i].key = key;
    80006b30:	0127a623          	sw	s2,12(a5)
      semt.s[i].val = init;
    80006b34:	0137a823          	sw	s3,16(a5)
      semt.s[i].waiters = 0;
    80006b38:	0007aa23          	sw	zero,20(a5)
      release(&semt.lock);
    80006b3c:	a0cfa0ef          	jal	ra,80000d48 <release>
}
    80006b40:	8526                	mv	a0,s1
    80006b42:	70a2                	ld	ra,40(sp)
    80006b44:	7402                	ld	s0,32(sp)
    80006b46:	64e2                	ld	s1,24(sp)
    80006b48:	6942                	ld	s2,16(sp)
    80006b4a:	69a2                	ld	s3,8(sp)
    80006b4c:	6145                	addi	sp,sp,48
    80006b4e:	8082                	ret

0000000080006b50 <sem_wait>:

int
sem_wait(int key)
{
    80006b50:	7179                	addi	sp,sp,-48
    80006b52:	f406                	sd	ra,40(sp)
    80006b54:	f022                	sd	s0,32(sp)
    80006b56:	ec26                	sd	s1,24(sp)
    80006b58:	e84a                	sd	s2,16(sp)
    80006b5a:	e44e                	sd	s3,8(sp)
    80006b5c:	e052                	sd	s4,0(sp)
    80006b5e:	1800                	addi	s0,sp,48
    80006b60:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006b62:	0024d517          	auipc	a0,0x24d
    80006b66:	24650513          	addi	a0,a0,582 # 80253da8 <semt>
    80006b6a:	946fa0ef          	jal	ra,80000cb0 <acquire>

  int idx = sem_lookup(key);
    80006b6e:	8526                	mv	a0,s1
    80006b70:	ef5ff0ef          	jal	ra,80006a64 <sem_lookup>
  if(idx < 0){
    80006b74:	06054e63          	bltz	a0,80006bf0 <sem_wait+0xa0>
    80006b78:	892a                	mv	s2,a0
    release(&semt.lock);
    return -1;
  }

  // while(val==0) sleep
  while(semt.s[idx].val == 0){
    80006b7a:	00150793          	addi	a5,a0,1
    80006b7e:	00479713          	slli	a4,a5,0x4
    80006b82:	0024d797          	auipc	a5,0x24d
    80006b86:	22678793          	addi	a5,a5,550 # 80253da8 <semt>
    80006b8a:	97ba                	add	a5,a5,a4
    80006b8c:	4b9c                	lw	a5,16(a5)
    80006b8e:	ef85                	bnez	a5,80006bc6 <sem_wait+0x76>
    semt.s[idx].waiters++;
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006b90:	00451993          	slli	s3,a0,0x4
    80006b94:	0024d797          	auipc	a5,0x24d
    80006b98:	22c78793          	addi	a5,a5,556 # 80253dc0 <semt+0x18>
    80006b9c:	99be                	add	s3,s3,a5
    semt.s[idx].waiters++;
    80006b9e:	0024da17          	auipc	s4,0x24d
    80006ba2:	20aa0a13          	addi	s4,s4,522 # 80253da8 <semt>
    80006ba6:	00150493          	addi	s1,a0,1
    80006baa:	0492                	slli	s1,s1,0x4
    80006bac:	94d2                	add	s1,s1,s4
    80006bae:	48dc                	lw	a5,20(s1)
    80006bb0:	2785                	addiw	a5,a5,1
    80006bb2:	c8dc                	sw	a5,20(s1)
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006bb4:	85d2                	mv	a1,s4
    80006bb6:	854e                	mv	a0,s3
    80006bb8:	8dbfb0ef          	jal	ra,80002492 <sleep>
    semt.s[idx].waiters--;
    80006bbc:	48dc                	lw	a5,20(s1)
    80006bbe:	37fd                	addiw	a5,a5,-1
    80006bc0:	c8dc                	sw	a5,20(s1)
  while(semt.s[idx].val == 0){
    80006bc2:	489c                	lw	a5,16(s1)
    80006bc4:	d7ed                	beqz	a5,80006bae <sem_wait+0x5e>
  }

  semt.s[idx].val--;
    80006bc6:	0024d517          	auipc	a0,0x24d
    80006bca:	1e250513          	addi	a0,a0,482 # 80253da8 <semt>
    80006bce:	0905                	addi	s2,s2,1
    80006bd0:	0912                	slli	s2,s2,0x4
    80006bd2:	992a                	add	s2,s2,a0
    80006bd4:	37fd                	addiw	a5,a5,-1
    80006bd6:	00f92823          	sw	a5,16(s2)
  release(&semt.lock);
    80006bda:	96efa0ef          	jal	ra,80000d48 <release>
  return 0;
    80006bde:	4501                	li	a0,0
}
    80006be0:	70a2                	ld	ra,40(sp)
    80006be2:	7402                	ld	s0,32(sp)
    80006be4:	64e2                	ld	s1,24(sp)
    80006be6:	6942                	ld	s2,16(sp)
    80006be8:	69a2                	ld	s3,8(sp)
    80006bea:	6a02                	ld	s4,0(sp)
    80006bec:	6145                	addi	sp,sp,48
    80006bee:	8082                	ret
    release(&semt.lock);
    80006bf0:	0024d517          	auipc	a0,0x24d
    80006bf4:	1b850513          	addi	a0,a0,440 # 80253da8 <semt>
    80006bf8:	950fa0ef          	jal	ra,80000d48 <release>
    return -1;
    80006bfc:	557d                	li	a0,-1
    80006bfe:	b7cd                	j	80006be0 <sem_wait+0x90>

0000000080006c00 <sem_post>:

int
sem_post(int key)
{
    80006c00:	1101                	addi	sp,sp,-32
    80006c02:	ec06                	sd	ra,24(sp)
    80006c04:	e822                	sd	s0,16(sp)
    80006c06:	e426                	sd	s1,8(sp)
    80006c08:	1000                	addi	s0,sp,32
    80006c0a:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006c0c:	0024d517          	auipc	a0,0x24d
    80006c10:	19c50513          	addi	a0,a0,412 # 80253da8 <semt>
    80006c14:	89cfa0ef          	jal	ra,80000cb0 <acquire>

  int idx = sem_lookup(key);
    80006c18:	8526                	mv	a0,s1
    80006c1a:	e4bff0ef          	jal	ra,80006a64 <sem_lookup>
  if(idx < 0){
    80006c1e:	02054a63          	bltz	a0,80006c52 <sem_post+0x52>
    release(&semt.lock);
    return -1;
  }

  semt.s[idx].val++;
    80006c22:	0024d497          	auipc	s1,0x24d
    80006c26:	18648493          	addi	s1,s1,390 # 80253da8 <semt>
    80006c2a:	0505                	addi	a0,a0,1
    80006c2c:	0512                	slli	a0,a0,0x4
    80006c2e:	00a48733          	add	a4,s1,a0
    80006c32:	4b1c                	lw	a5,16(a4)
    80006c34:	2785                	addiw	a5,a5,1
    80006c36:	cb1c                	sw	a5,16(a4)

  // 唤醒一个或全部：先做全部更简单也正确
  wakeup(&semt.s[idx]);
    80006c38:	0521                	addi	a0,a0,8
    80006c3a:	9526                	add	a0,a0,s1
    80006c3c:	8a3fb0ef          	jal	ra,800024de <wakeup>

  release(&semt.lock);
    80006c40:	8526                	mv	a0,s1
    80006c42:	906fa0ef          	jal	ra,80000d48 <release>
  return 0;
    80006c46:	4501                	li	a0,0
}
    80006c48:	60e2                	ld	ra,24(sp)
    80006c4a:	6442                	ld	s0,16(sp)
    80006c4c:	64a2                	ld	s1,8(sp)
    80006c4e:	6105                	addi	sp,sp,32
    80006c50:	8082                	ret
    release(&semt.lock);
    80006c52:	0024d517          	auipc	a0,0x24d
    80006c56:	15650513          	addi	a0,a0,342 # 80253da8 <semt>
    80006c5a:	8eefa0ef          	jal	ra,80000d48 <release>
    return -1;
    80006c5e:	557d                	li	a0,-1
    80006c60:	b7e5                	j	80006c48 <sem_post+0x48>

0000000080006c62 <sys_sem_open>:
#include "defs.h"


uint64
sys_sem_open(void)
{
    80006c62:	1101                	addi	sp,sp,-32
    80006c64:	ec06                	sd	ra,24(sp)
    80006c66:	e822                	sd	s0,16(sp)
    80006c68:	1000                	addi	s0,sp,32
  int key, init;
  argint(0, &key);
    80006c6a:	fec40593          	addi	a1,s0,-20
    80006c6e:	4501                	li	a0,0
    80006c70:	958fc0ef          	jal	ra,80002dc8 <argint>
  argint(1, &init);
    80006c74:	fe840593          	addi	a1,s0,-24
    80006c78:	4505                	li	a0,1
    80006c7a:	94efc0ef          	jal	ra,80002dc8 <argint>
  return sem_open(key, init);
    80006c7e:	fe842583          	lw	a1,-24(s0)
    80006c82:	fec42503          	lw	a0,-20(s0)
    80006c86:	e37ff0ef          	jal	ra,80006abc <sem_open>
}
    80006c8a:	60e2                	ld	ra,24(sp)
    80006c8c:	6442                	ld	s0,16(sp)
    80006c8e:	6105                	addi	sp,sp,32
    80006c90:	8082                	ret

0000000080006c92 <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80006c92:	1101                	addi	sp,sp,-32
    80006c94:	ec06                	sd	ra,24(sp)
    80006c96:	e822                	sd	s0,16(sp)
    80006c98:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006c9a:	fec40593          	addi	a1,s0,-20
    80006c9e:	4501                	li	a0,0
    80006ca0:	928fc0ef          	jal	ra,80002dc8 <argint>
  return sem_wait(key);
    80006ca4:	fec42503          	lw	a0,-20(s0)
    80006ca8:	ea9ff0ef          	jal	ra,80006b50 <sem_wait>
}
    80006cac:	60e2                	ld	ra,24(sp)
    80006cae:	6442                	ld	s0,16(sp)
    80006cb0:	6105                	addi	sp,sp,32
    80006cb2:	8082                	ret

0000000080006cb4 <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80006cb4:	1101                	addi	sp,sp,-32
    80006cb6:	ec06                	sd	ra,24(sp)
    80006cb8:	e822                	sd	s0,16(sp)
    80006cba:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006cbc:	fec40593          	addi	a1,s0,-20
    80006cc0:	4501                	li	a0,0
    80006cc2:	906fc0ef          	jal	ra,80002dc8 <argint>
  return sem_post(key);
    80006cc6:	fec42503          	lw	a0,-20(s0)
    80006cca:	f37ff0ef          	jal	ra,80006c00 <sem_post>
}
    80006cce:	60e2                	ld	ra,24(sp)
    80006cd0:	6442                	ld	s0,16(sp)
    80006cd2:	6105                	addi	sp,sp,32
    80006cd4:	8082                	ret

0000000080006cd6 <vmstatsinit>:
  uint64 shm_faults;
} vmstats;

void
vmstatsinit(void)
{
    80006cd6:	1141                	addi	sp,sp,-16
    80006cd8:	e406                	sd	ra,8(sp)
    80006cda:	e022                	sd	s0,0(sp)
    80006cdc:	0800                	addi	s0,sp,16
  initlock(&vmstats.lock, "vmstats");
    80006cde:	00002597          	auipc	a1,0x2
    80006ce2:	baa58593          	addi	a1,a1,-1110 # 80008888 <syscalls+0x490>
    80006ce6:	0024d517          	auipc	a0,0x24d
    80006cea:	4da50513          	addi	a0,a0,1242 # 802541c0 <vmstats>
    80006cee:	f43f90ef          	jal	ra,80000c30 <initlock>
}
    80006cf2:	60a2                	ld	ra,8(sp)
    80006cf4:	6402                	ld	s0,0(sp)
    80006cf6:	0141                	addi	sp,sp,16
    80006cf8:	8082                	ret

0000000080006cfa <vmstats_snapshot>:

// 给 sys_vmstats 用：读出一份快照
void
vmstats_snapshot(struct vmstats_user *out)
{
    80006cfa:	1101                	addi	sp,sp,-32
    80006cfc:	ec06                	sd	ra,24(sp)
    80006cfe:	e822                	sd	s0,16(sp)
    80006d00:	e426                	sd	s1,8(sp)
    80006d02:	e04a                	sd	s2,0(sp)
    80006d04:	1000                	addi	s0,sp,32
    80006d06:	84aa                	mv	s1,a0
  acquire(&vmstats.lock);
    80006d08:	0024d917          	auipc	s2,0x24d
    80006d0c:	4b890913          	addi	s2,s2,1208 # 802541c0 <vmstats>
    80006d10:	854a                	mv	a0,s2
    80006d12:	f9ff90ef          	jal	ra,80000cb0 <acquire>
  out->cow_faults  = vmstats.cow_faults;
    80006d16:	01893783          	ld	a5,24(s2)
    80006d1a:	e09c                	sd	a5,0(s1)
  out->lazy_faults = vmstats.lazy_faults;
    80006d1c:	02093783          	ld	a5,32(s2)
    80006d20:	e49c                	sd	a5,8(s1)
  out->shm_faults  = vmstats.shm_faults;
    80006d22:	02893783          	ld	a5,40(s2)
    80006d26:	e89c                	sd	a5,16(s1)
  release(&vmstats.lock);
    80006d28:	854a                	mv	a0,s2
    80006d2a:	81efa0ef          	jal	ra,80000d48 <release>

  out->kalloc_cnt = kalloc_cnt;
    80006d2e:	00002797          	auipc	a5,0x2
    80006d32:	bb27b783          	ld	a5,-1102(a5) # 800088e0 <kalloc_cnt>
    80006d36:	ec9c                	sd	a5,24(s1)
  out->copyin_bytes = copyin_bytes;
    80006d38:	00002797          	auipc	a5,0x2
    80006d3c:	ba07b783          	ld	a5,-1120(a5) # 800088d8 <copyin_bytes>
    80006d40:	f09c                	sd	a5,32(s1)
  out->copyout_bytes = copyout_bytes;
    80006d42:	00002797          	auipc	a5,0x2
    80006d46:	b8e7b783          	ld	a5,-1138(a5) # 800088d0 <copyout_bytes>
    80006d4a:	f49c                	sd	a5,40(s1)
}
    80006d4c:	60e2                	ld	ra,24(sp)
    80006d4e:	6442                	ld	s0,16(sp)
    80006d50:	64a2                	ld	s1,8(sp)
    80006d52:	6902                	ld	s2,0(sp)
    80006d54:	6105                	addi	sp,sp,32
    80006d56:	8082                	ret

0000000080006d58 <vmstats_inc_cow>:




// 给其他模块做计数：不追求绝对精确可以不加锁
void vmstats_inc_cow(void)  { acquire(&vmstats.lock); vmstats.cow_faults++;  release(&vmstats.lock); }
    80006d58:	1101                	addi	sp,sp,-32
    80006d5a:	ec06                	sd	ra,24(sp)
    80006d5c:	e822                	sd	s0,16(sp)
    80006d5e:	e426                	sd	s1,8(sp)
    80006d60:	1000                	addi	s0,sp,32
    80006d62:	0024d497          	auipc	s1,0x24d
    80006d66:	45e48493          	addi	s1,s1,1118 # 802541c0 <vmstats>
    80006d6a:	8526                	mv	a0,s1
    80006d6c:	f45f90ef          	jal	ra,80000cb0 <acquire>
    80006d70:	6c9c                	ld	a5,24(s1)
    80006d72:	0785                	addi	a5,a5,1
    80006d74:	ec9c                	sd	a5,24(s1)
    80006d76:	8526                	mv	a0,s1
    80006d78:	fd1f90ef          	jal	ra,80000d48 <release>
    80006d7c:	60e2                	ld	ra,24(sp)
    80006d7e:	6442                	ld	s0,16(sp)
    80006d80:	64a2                	ld	s1,8(sp)
    80006d82:	6105                	addi	sp,sp,32
    80006d84:	8082                	ret

0000000080006d86 <vmstats_inc_lazy>:
void vmstats_inc_lazy(void) { acquire(&vmstats.lock); vmstats.lazy_faults++; release(&vmstats.lock); }
    80006d86:	1101                	addi	sp,sp,-32
    80006d88:	ec06                	sd	ra,24(sp)
    80006d8a:	e822                	sd	s0,16(sp)
    80006d8c:	e426                	sd	s1,8(sp)
    80006d8e:	1000                	addi	s0,sp,32
    80006d90:	0024d497          	auipc	s1,0x24d
    80006d94:	43048493          	addi	s1,s1,1072 # 802541c0 <vmstats>
    80006d98:	8526                	mv	a0,s1
    80006d9a:	f17f90ef          	jal	ra,80000cb0 <acquire>
    80006d9e:	709c                	ld	a5,32(s1)
    80006da0:	0785                	addi	a5,a5,1
    80006da2:	f09c                	sd	a5,32(s1)
    80006da4:	8526                	mv	a0,s1
    80006da6:	fa3f90ef          	jal	ra,80000d48 <release>
    80006daa:	60e2                	ld	ra,24(sp)
    80006dac:	6442                	ld	s0,16(sp)
    80006dae:	64a2                	ld	s1,8(sp)
    80006db0:	6105                	addi	sp,sp,32
    80006db2:	8082                	ret

0000000080006db4 <vmstats_inc_shm>:
void vmstats_inc_shm(void)  { acquire(&vmstats.lock); vmstats.shm_faults++;  release(&vmstats.lock); }
    80006db4:	1101                	addi	sp,sp,-32
    80006db6:	ec06                	sd	ra,24(sp)
    80006db8:	e822                	sd	s0,16(sp)
    80006dba:	e426                	sd	s1,8(sp)
    80006dbc:	1000                	addi	s0,sp,32
    80006dbe:	0024d497          	auipc	s1,0x24d
    80006dc2:	40248493          	addi	s1,s1,1026 # 802541c0 <vmstats>
    80006dc6:	8526                	mv	a0,s1
    80006dc8:	ee9f90ef          	jal	ra,80000cb0 <acquire>
    80006dcc:	749c                	ld	a5,40(s1)
    80006dce:	0785                	addi	a5,a5,1
    80006dd0:	f49c                	sd	a5,40(s1)
    80006dd2:	8526                	mv	a0,s1
    80006dd4:	f75f90ef          	jal	ra,80000d48 <release>
    80006dd8:	60e2                	ld	ra,24(sp)
    80006dda:	6442                	ld	s0,16(sp)
    80006ddc:	64a2                	ld	s1,8(sp)
    80006dde:	6105                	addi	sp,sp,32
    80006de0:	8082                	ret
	...

0000000080007000 <_trampoline>:
        # user page table.
        #

        # save user a0 in sscratch so
        # a0 can be used to get at TRAPFRAME.
        csrw sscratch, a0
    80007000:	14051073          	csrw	sscratch,a0

        # each process has a separate p->trapframe memory area,
        # but it's mapped to the same virtual address
        # (TRAPFRAME) in every process's user page table.
        li a0, TRAPFRAME
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
        
        # save the user registers in TRAPFRAME
        sd ra, 40(a0)
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        sd sp, 48(a0)
    80007010:	02253823          	sd	sp,48(a0)
        sd gp, 56(a0)
    80007014:	02353c23          	sd	gp,56(a0)
        sd tp, 64(a0)
    80007018:	04453023          	sd	tp,64(a0)
        sd t0, 72(a0)
    8000701c:	04553423          	sd	t0,72(a0)
        sd t1, 80(a0)
    80007020:	04653823          	sd	t1,80(a0)
        sd t2, 88(a0)
    80007024:	04753c23          	sd	t2,88(a0)
        sd s0, 96(a0)
    80007028:	f120                	sd	s0,96(a0)
        sd s1, 104(a0)
    8000702a:	f524                	sd	s1,104(a0)
        sd a1, 120(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
        sd a2, 128(a0)
    8000702e:	e150                	sd	a2,128(a0)
        sd a3, 136(a0)
    80007030:	e554                	sd	a3,136(a0)
        sd a4, 144(a0)
    80007032:	e958                	sd	a4,144(a0)
        sd a5, 152(a0)
    80007034:	ed5c                	sd	a5,152(a0)
        sd a6, 160(a0)
    80007036:	0b053023          	sd	a6,160(a0)
        sd a7, 168(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
        sd s2, 176(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
        sd s3, 184(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
        sd s4, 192(a0)
    80007046:	0d453023          	sd	s4,192(a0)
        sd s5, 200(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
        sd s6, 208(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
        sd s7, 216(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
        sd s8, 224(a0)
    80007056:	0f853023          	sd	s8,224(a0)
        sd s9, 232(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
        sd s10, 240(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
        sd s11, 248(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
        sd t3, 256(a0)
    80007066:	11c53023          	sd	t3,256(a0)
        sd t4, 264(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
        sd t5, 272(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
        sd t6, 280(a0)
    80007072:	11f53c23          	sd	t6,280(a0)

	# save the user a0 in p->trapframe->a0
        csrr t0, sscratch
    80007076:	140022f3          	csrr	t0,sscratch
        sd t0, 112(a0)
    8000707a:	06553823          	sd	t0,112(a0)

        # initialize kernel stack pointer, from p->trapframe->kernel_sp
        ld sp, 8(a0)
    8000707e:	00853103          	ld	sp,8(a0)

        # make tp hold the current hartid, from p->trapframe->kernel_hartid
        ld tp, 32(a0)
    80007082:	02053203          	ld	tp,32(a0)

        # load the address of usertrap(), from p->trapframe->kernel_trap
        ld t0, 16(a0)
    80007086:	01053283          	ld	t0,16(a0)

        # fetch the kernel page table address, from p->trapframe->kernel_satp.
        ld t1, 0(a0)
    8000708a:	00053303          	ld	t1,0(a0)

        # wait for any previous memory operations to complete, so that
        # they use the user page table.
        sfence.vma zero, zero
    8000708e:	12000073          	sfence.vma

        # install the kernel page table.
        csrw satp, t1
    80007092:	18031073          	csrw	satp,t1

        # flush now-stale user entries from the TLB.
        sfence.vma zero, zero
    80007096:	12000073          	sfence.vma

        # call usertrap()
        jalr t0
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
userret:
        # usertrap() returns here, with user satp in a0.
        # return from kernel to user.

        # switch to the user page table.
        sfence.vma zero, zero
    8000709c:	12000073          	sfence.vma
        csrw satp, a0
    800070a0:	18051073          	csrw	satp,a0
        sfence.vma zero, zero
    800070a4:	12000073          	sfence.vma

        li a0, TRAPFRAME
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd

        # restore all but a0 from TRAPFRAME
        ld ra, 40(a0)
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        ld sp, 48(a0)
    800070b4:	03053103          	ld	sp,48(a0)
        ld gp, 56(a0)
    800070b8:	03853183          	ld	gp,56(a0)
        ld tp, 64(a0)
    800070bc:	04053203          	ld	tp,64(a0)
        ld t0, 72(a0)
    800070c0:	04853283          	ld	t0,72(a0)
        ld t1, 80(a0)
    800070c4:	05053303          	ld	t1,80(a0)
        ld t2, 88(a0)
    800070c8:	05853383          	ld	t2,88(a0)
        ld s0, 96(a0)
    800070cc:	7120                	ld	s0,96(a0)
        ld s1, 104(a0)
    800070ce:	7524                	ld	s1,104(a0)
        ld a1, 120(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
        ld a2, 128(a0)
    800070d2:	6150                	ld	a2,128(a0)
        ld a3, 136(a0)
    800070d4:	6554                	ld	a3,136(a0)
        ld a4, 144(a0)
    800070d6:	6958                	ld	a4,144(a0)
        ld a5, 152(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
        ld a6, 160(a0)
    800070da:	0a053803          	ld	a6,160(a0)
        ld a7, 168(a0)
    800070de:	0a853883          	ld	a7,168(a0)
        ld s2, 176(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
        ld s3, 184(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
        ld s4, 192(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
        ld s5, 200(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
        ld s6, 208(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
        ld s7, 216(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
        ld s8, 224(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
        ld s9, 232(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
        ld s10, 240(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
        ld s11, 248(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
        ld t3, 256(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
        ld t4, 264(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
        ld t5, 272(a0)
    80007112:	11053f03          	ld	t5,272(a0)
        ld t6, 280(a0)
    80007116:	11853f83          	ld	t6,280(a0)

	# restore user a0
        ld a0, 112(a0)
    8000711a:	7928                	ld	a0,112(a0)
        
        # return to user mode and user pc.
        # usertrapret() set up sstatus and sepc.
        sret
    8000711c:	10200073          	sret
	...
