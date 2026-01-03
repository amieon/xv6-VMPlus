
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
    80000004:	8a813103          	ld	sp,-1880(sp) # 800088a8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdaa5ef>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	ea478793          	addi	a5,a5,-348 # 80000f24 <main>
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
    8000010a:	724020ef          	jal	ra,8000282e <either_copyin>
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
    80000176:	79e50513          	addi	a0,a0,1950 # 80010910 <cons>
    8000017a:	335000ef          	jal	ra,80000cae <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	79248493          	addi	s1,s1,1938 # 80010910 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00011917          	auipc	s2,0x11
    8000018a:	82290913          	addi	s2,s2,-2014 # 800109a8 <cons+0x98>
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
    800001a4:	1f5010ef          	jal	ra,80001b98 <myproc>
    800001a8:	518020ef          	jal	ra,800026c0 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	2d6020ef          	jal	ra,80002488 <sleep>
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
    800001ea:	5fa020ef          	jal	ra,800027e4 <either_copyout>
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
    800001fe:	71650513          	addi	a0,a0,1814 # 80010910 <cons>
    80000202:	345000ef          	jal	ra,80000d46 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	70450513          	addi	a0,a0,1796 # 80010910 <cons>
    80000214:	333000ef          	jal	ra,80000d46 <release>
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
    80000242:	76f72523          	sw	a5,1898(a4) # 800109a8 <cons+0x98>
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
    8000028c:	68850513          	addi	a0,a0,1672 # 80010910 <cons>
    80000290:	21f000ef          	jal	ra,80000cae <acquire>

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
    800002aa:	5ce020ef          	jal	ra,80002878 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	66250513          	addi	a0,a0,1634 # 80010910 <cons>
    800002b6:	291000ef          	jal	ra,80000d46 <release>
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
    800002d2:	64270713          	addi	a4,a4,1602 # 80010910 <cons>
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
    800002f8:	61c78793          	addi	a5,a5,1564 # 80010910 <cons>
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
    80000326:	6867a783          	lw	a5,1670(a5) # 800109a8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	5da70713          	addi	a4,a4,1498 # 80010910 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	5ca48493          	addi	s1,s1,1482 # 80010910 <cons>
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
    80000382:	59270713          	addi	a4,a4,1426 # 80010910 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	60f72e23          	sw	a5,1564(a4) # 800109b0 <cons+0xa0>
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
    800003b6:	55e78793          	addi	a5,a5,1374 # 80010910 <cons>
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
    800003da:	5cc7ab23          	sw	a2,1494(a5) # 800109ac <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	5ca50513          	addi	a0,a0,1482 # 800109a8 <cons+0x98>
    800003e6:	0ee020ef          	jal	ra,800024d4 <wakeup>
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
    80000400:	51450513          	addi	a0,a0,1300 # 80010910 <cons>
    80000404:	02b000ef          	jal	ra,80000c2e <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0024a797          	auipc	a5,0x24a
    80000410:	68c78793          	addi	a5,a5,1676 # 8024aa98 <devsw>
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
    800004f8:	3d07a783          	lw	a5,976(a5) # 800088c4 <panicking>
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
    80000536:	48650513          	addi	a0,a0,1158 # 800109b8 <pr>
    8000053a:	774000ef          	jal	ra,80000cae <acquire>
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
    80000754:	1747a783          	lw	a5,372(a5) # 800088c4 <panicking>
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
    8000077e:	23e50513          	addi	a0,a0,574 # 800109b8 <pr>
    80000782:	5c4000ef          	jal	ra,80000d46 <release>
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
    8000079c:	1327a623          	sw	s2,300(a5) # 800088c4 <panicking>
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
    800007be:	1127a323          	sw	s2,262(a5) # 800088c0 <panicked>
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
    800007d8:	1e450513          	addi	a0,a0,484 # 800109b8 <pr>
    800007dc:	452000ef          	jal	ra,80000c2e <initlock>
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
    80000824:	1b050513          	addi	a0,a0,432 # 800109d0 <tx_lock>
    80000828:	406000ef          	jal	ra,80000c2e <initlock>
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
    80000852:	18250513          	addi	a0,a0,386 # 800109d0 <tx_lock>
    80000856:	458000ef          	jal	ra,80000cae <acquire>

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
    80000872:	05e48493          	addi	s1,s1,94 # 800088cc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	00010997          	auipc	s3,0x10
    8000087a:	15a98993          	addi	s3,s3,346 # 800109d0 <tx_lock>
    8000087e:	00008917          	auipc	s2,0x8
    80000882:	04a90913          	addi	s2,s2,74 # 800088c8 <tx_chan>
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
    80000892:	3f7010ef          	jal	ra,80002488 <sleep>
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
    800008b6:	11e50513          	addi	a0,a0,286 # 800109d0 <tx_lock>
    800008ba:	48c000ef          	jal	ra,80000d46 <release>
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
    800008e4:	fe47a783          	lw	a5,-28(a5) # 800088c4 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	fd67a783          	lw	a5,-42(a5) # 800088c0 <panicked>
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
    800008fa:	374000ef          	jal	ra,80000c6e <push_off>
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
    8000091a:	fae7a783          	lw	a5,-82(a5) # 800088c4 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	3c8000ef          	jal	ra,80000cf2 <pop_off>
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
    8000096a:	06a50513          	addi	a0,a0,106 # 800109d0 <tx_lock>
    8000096e:	340000ef          	jal	ra,80000cae <acquire>
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
    80000980:	05450513          	addi	a0,a0,84 # 800109d0 <tx_lock>
    80000984:	3c2000ef          	jal	ra,80000d46 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00008797          	auipc	a5,0x8
    80000990:	f407a023          	sw	zero,-192(a5) # 800088cc <tx_busy>
    wakeup(&tx_chan);
    80000994:	00008517          	auipc	a0,0x8
    80000998:	f3450513          	addi	a0,a0,-204 # 800088c8 <tx_chan>
    8000099c:	339010ef          	jal	ra,800024d4 <wakeup>
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
    800009c8:	04450513          	addi	a0,a0,68 # 80010a08 <kref>
    800009cc:	2e2000ef          	jal	ra,80000cae <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d0:	00010517          	auipc	a0,0x10
    800009d4:	03850513          	addi	a0,a0,56 # 80010a08 <kref>
    800009d8:	80b1                	srli	s1,s1,0xc
    800009da:	0491                	addi	s1,s1,4
    800009dc:	048a                	slli	s1,s1,0x2
    800009de:	94aa                	add	s1,s1,a0
    800009e0:	4484                	lw	s1,8(s1)
  release(&kref.lock);
    800009e2:	364000ef          	jal	ra,80000d46 <release>
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
    80000a02:	00a50513          	addi	a0,a0,10 # 80010a08 <kref>
    80000a06:	2a8000ef          	jal	ra,80000cae <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0a:	00c4d793          	srli	a5,s1,0xc
    80000a0e:	00010517          	auipc	a0,0x10
    80000a12:	ffa50513          	addi	a0,a0,-6 # 80010a08 <kref>
    80000a16:	0791                	addi	a5,a5,4
    80000a18:	078a                	slli	a5,a5,0x2
    80000a1a:	97aa                	add	a5,a5,a0
    80000a1c:	4798                	lw	a4,8(a5)
    80000a1e:	2705                	addiw	a4,a4,1
    80000a20:	0007049b          	sext.w	s1,a4
    80000a24:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000a26:	320000ef          	jal	ra,80000d46 <release>
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
    80000a46:	fc650513          	addi	a0,a0,-58 # 80010a08 <kref>
    80000a4a:	264000ef          	jal	ra,80000cae <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a4e:	00c4d793          	srli	a5,s1,0xc
    80000a52:	00010517          	auipc	a0,0x10
    80000a56:	fb650513          	addi	a0,a0,-74 # 80010a08 <kref>
    80000a5a:	0791                	addi	a5,a5,4
    80000a5c:	078a                	slli	a5,a5,0x2
    80000a5e:	97aa                	add	a5,a5,a0
    80000a60:	4798                	lw	a4,8(a5)
    80000a62:	377d                	addiw	a4,a4,-1
    80000a64:	0007049b          	sext.w	s1,a4
    80000a68:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000a6a:	2dc000ef          	jal	ra,80000d46 <release>
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
    80000a92:	78278793          	addi	a5,a5,1922 # 80254210 <end>
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
    80000ac8:	2ba000ef          	jal	ra,80000d82 <memset>
  acquire(&kmem.lock);
    80000acc:	00010917          	auipc	s2,0x10
    80000ad0:	f1c90913          	addi	s2,s2,-228 # 800109e8 <kmem>
    80000ad4:	854a                	mv	a0,s2
    80000ad6:	1d8000ef          	jal	ra,80000cae <acquire>
  r->next = kmem.freelist;
    80000ada:	01893783          	ld	a5,24(s2)
    80000ade:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ae0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ae4:	854a                	mv	a0,s2
    80000ae6:	260000ef          	jal	ra,80000d46 <release>
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
    80000b1a:	ef290913          	addi	s2,s2,-270 # 80010a08 <kref>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b1e:	4b05                	li	s6,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b20:	6a85                	lui	s5,0x1
    80000b22:	6a09                	lui	s4,0x2
    acquire(&kref.lock);
    80000b24:	854a                	mv	a0,s2
    80000b26:	188000ef          	jal	ra,80000cae <acquire>
    kref.refcnt[PA2IDX(p)] = 1;
    80000b2a:	00c4d793          	srli	a5,s1,0xc
    80000b2e:	0791                	addi	a5,a5,4
    80000b30:	078a                	slli	a5,a5,0x2
    80000b32:	97ca                	add	a5,a5,s2
    80000b34:	0167a423          	sw	s6,8(a5)
    release(&kref.lock);
    80000b38:	854a                	mv	a0,s2
    80000b3a:	20c000ef          	jal	ra,80000d46 <release>
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
    80000b76:	e7650513          	addi	a0,a0,-394 # 800109e8 <kmem>
    80000b7a:	0b4000ef          	jal	ra,80000c2e <initlock>
  initlock(&kref.lock, "kref");
    80000b7e:	00007597          	auipc	a1,0x7
    80000b82:	4ea58593          	addi	a1,a1,1258 # 80008068 <digits+0x30>
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	e8250513          	addi	a0,a0,-382 # 80010a08 <kref>
    80000b8e:	0a0000ef          	jal	ra,80000c2e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b92:	45c5                	li	a1,17
    80000b94:	05ee                	slli	a1,a1,0x1b
    80000b96:	00253517          	auipc	a0,0x253
    80000b9a:	67a50513          	addi	a0,a0,1658 # 80254210 <end>
    80000b9e:	f4fff0ef          	jal	ra,80000aec <freerange>
}
    80000ba2:	60a2                	ld	ra,8(sp)
    80000ba4:	6402                	ld	s0,0(sp)
    80000ba6:	0141                	addi	sp,sp,16
    80000ba8:	8082                	ret

0000000080000baa <kalloc>:
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
    80000bb8:	e3448493          	addi	s1,s1,-460 # 800109e8 <kmem>
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	0f0000ef          	jal	ra,80000cae <acquire>
  r = kmem.freelist;
    80000bc2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc4:	ccb1                	beqz	s1,80000c20 <kalloc+0x76>
    kmem.freelist = r->next;
    80000bc6:	609c                	ld	a5,0(s1)
    80000bc8:	00010517          	auipc	a0,0x10
    80000bcc:	e2050513          	addi	a0,a0,-480 # 800109e8 <kmem>
    80000bd0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bd2:	174000ef          	jal	ra,80000d46 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bd6:	6605                	lui	a2,0x1
    80000bd8:	4595                	li	a1,5
    80000bda:	8526                	mv	a0,s1
    80000bdc:	1a6000ef          	jal	ra,80000d82 <memset>
  
  //alloc出页后，默认引用数为1
  if(r){
  acquire(&kref.lock);
    80000be0:	00010517          	auipc	a0,0x10
    80000be4:	e2850513          	addi	a0,a0,-472 # 80010a08 <kref>
    80000be8:	0c6000ef          	jal	ra,80000cae <acquire>
  kref.refcnt[PA2IDX(r)] = 1;
    80000bec:	00010517          	auipc	a0,0x10
    80000bf0:	e1c50513          	addi	a0,a0,-484 # 80010a08 <kref>
    80000bf4:	00c4d793          	srli	a5,s1,0xc
    80000bf8:	0791                	addi	a5,a5,4
    80000bfa:	078a                	slli	a5,a5,0x2
    80000bfc:	97aa                	add	a5,a5,a0
    80000bfe:	4705                	li	a4,1
    80000c00:	c798                	sw	a4,8(a5)
  release(&kref.lock);
    80000c02:	144000ef          	jal	ra,80000d46 <release>
  }
  extern uint64 kalloc_cnt;
  kalloc_cnt++;
    80000c06:	00008717          	auipc	a4,0x8
    80000c0a:	cfa70713          	addi	a4,a4,-774 # 80008900 <kalloc_cnt>
    80000c0e:	631c                	ld	a5,0(a4)
    80000c10:	0785                	addi	a5,a5,1
    80000c12:	e31c                	sd	a5,0(a4)


  return (void*)r;
}
    80000c14:	8526                	mv	a0,s1
    80000c16:	60e2                	ld	ra,24(sp)
    80000c18:	6442                	ld	s0,16(sp)
    80000c1a:	64a2                	ld	s1,8(sp)
    80000c1c:	6105                	addi	sp,sp,32
    80000c1e:	8082                	ret
  release(&kmem.lock);
    80000c20:	00010517          	auipc	a0,0x10
    80000c24:	dc850513          	addi	a0,a0,-568 # 800109e8 <kmem>
    80000c28:	11e000ef          	jal	ra,80000d46 <release>
  if(r){
    80000c2c:	bfe9                	j	80000c06 <kalloc+0x5c>

0000000080000c2e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c2e:	1141                	addi	sp,sp,-16
    80000c30:	e422                	sd	s0,8(sp)
    80000c32:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c34:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c36:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c3a:	00053823          	sd	zero,16(a0)
}
    80000c3e:	6422                	ld	s0,8(sp)
    80000c40:	0141                	addi	sp,sp,16
    80000c42:	8082                	ret

0000000080000c44 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c44:	411c                	lw	a5,0(a0)
    80000c46:	e399                	bnez	a5,80000c4c <holding+0x8>
    80000c48:	4501                	li	a0,0
  return r;
}
    80000c4a:	8082                	ret
{
    80000c4c:	1101                	addi	sp,sp,-32
    80000c4e:	ec06                	sd	ra,24(sp)
    80000c50:	e822                	sd	s0,16(sp)
    80000c52:	e426                	sd	s1,8(sp)
    80000c54:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c56:	6904                	ld	s1,16(a0)
    80000c58:	725000ef          	jal	ra,80001b7c <mycpu>
    80000c5c:	40a48533          	sub	a0,s1,a0
    80000c60:	00153513          	seqz	a0,a0
}
    80000c64:	60e2                	ld	ra,24(sp)
    80000c66:	6442                	ld	s0,16(sp)
    80000c68:	64a2                	ld	s1,8(sp)
    80000c6a:	6105                	addi	sp,sp,32
    80000c6c:	8082                	ret

0000000080000c6e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c6e:	1101                	addi	sp,sp,-32
    80000c70:	ec06                	sd	ra,24(sp)
    80000c72:	e822                	sd	s0,16(sp)
    80000c74:	e426                	sd	s1,8(sp)
    80000c76:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100024f3          	csrr	s1,sstatus
    80000c7c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c80:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c82:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c86:	6f7000ef          	jal	ra,80001b7c <mycpu>
    80000c8a:	5d3c                	lw	a5,120(a0)
    80000c8c:	cb99                	beqz	a5,80000ca2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c8e:	6ef000ef          	jal	ra,80001b7c <mycpu>
    80000c92:	5d3c                	lw	a5,120(a0)
    80000c94:	2785                	addiw	a5,a5,1
    80000c96:	dd3c                	sw	a5,120(a0)
}
    80000c98:	60e2                	ld	ra,24(sp)
    80000c9a:	6442                	ld	s0,16(sp)
    80000c9c:	64a2                	ld	s1,8(sp)
    80000c9e:	6105                	addi	sp,sp,32
    80000ca0:	8082                	ret
    mycpu()->intena = old;
    80000ca2:	6db000ef          	jal	ra,80001b7c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ca6:	8085                	srli	s1,s1,0x1
    80000ca8:	8885                	andi	s1,s1,1
    80000caa:	dd64                	sw	s1,124(a0)
    80000cac:	b7cd                	j	80000c8e <push_off+0x20>

0000000080000cae <acquire>:
{
    80000cae:	1101                	addi	sp,sp,-32
    80000cb0:	ec06                	sd	ra,24(sp)
    80000cb2:	e822                	sd	s0,16(sp)
    80000cb4:	e426                	sd	s1,8(sp)
    80000cb6:	1000                	addi	s0,sp,32
    80000cb8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cba:	fb5ff0ef          	jal	ra,80000c6e <push_off>
  if(holding(lk))
    80000cbe:	8526                	mv	a0,s1
    80000cc0:	f85ff0ef          	jal	ra,80000c44 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cc4:	4705                	li	a4,1
  if(holding(lk))
    80000cc6:	e105                	bnez	a0,80000ce6 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cc8:	87ba                	mv	a5,a4
    80000cca:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cce:	2781                	sext.w	a5,a5
    80000cd0:	ffe5                	bnez	a5,80000cc8 <acquire+0x1a>
  __sync_synchronize();
    80000cd2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cd6:	6a7000ef          	jal	ra,80001b7c <mycpu>
    80000cda:	e888                	sd	a0,16(s1)
}
    80000cdc:	60e2                	ld	ra,24(sp)
    80000cde:	6442                	ld	s0,16(sp)
    80000ce0:	64a2                	ld	s1,8(sp)
    80000ce2:	6105                	addi	sp,sp,32
    80000ce4:	8082                	ret
    panic("acquire");
    80000ce6:	00007517          	auipc	a0,0x7
    80000cea:	38a50513          	addi	a0,a0,906 # 80008070 <digits+0x38>
    80000cee:	a9bff0ef          	jal	ra,80000788 <panic>

0000000080000cf2 <pop_off>:

void
pop_off(void)
{
    80000cf2:	1141                	addi	sp,sp,-16
    80000cf4:	e406                	sd	ra,8(sp)
    80000cf6:	e022                	sd	s0,0(sp)
    80000cf8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cfa:	683000ef          	jal	ra,80001b7c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cfe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d02:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d04:	e78d                	bnez	a5,80000d2e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d06:	5d3c                	lw	a5,120(a0)
    80000d08:	02f05963          	blez	a5,80000d3a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000d0c:	37fd                	addiw	a5,a5,-1
    80000d0e:	0007871b          	sext.w	a4,a5
    80000d12:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d14:	eb09                	bnez	a4,80000d26 <pop_off+0x34>
    80000d16:	5d7c                	lw	a5,124(a0)
    80000d18:	c799                	beqz	a5,80000d26 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d1a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d1e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d22:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d26:	60a2                	ld	ra,8(sp)
    80000d28:	6402                	ld	s0,0(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret
    panic("pop_off - interruptible");
    80000d2e:	00007517          	auipc	a0,0x7
    80000d32:	34a50513          	addi	a0,a0,842 # 80008078 <digits+0x40>
    80000d36:	a53ff0ef          	jal	ra,80000788 <panic>
    panic("pop_off");
    80000d3a:	00007517          	auipc	a0,0x7
    80000d3e:	35650513          	addi	a0,a0,854 # 80008090 <digits+0x58>
    80000d42:	a47ff0ef          	jal	ra,80000788 <panic>

0000000080000d46 <release>:
{
    80000d46:	1101                	addi	sp,sp,-32
    80000d48:	ec06                	sd	ra,24(sp)
    80000d4a:	e822                	sd	s0,16(sp)
    80000d4c:	e426                	sd	s1,8(sp)
    80000d4e:	1000                	addi	s0,sp,32
    80000d50:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d52:	ef3ff0ef          	jal	ra,80000c44 <holding>
    80000d56:	c105                	beqz	a0,80000d76 <release+0x30>
  lk->cpu = 0;
    80000d58:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d5c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d60:	0f50000f          	fence	iorw,ow
    80000d64:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d68:	f8bff0ef          	jal	ra,80000cf2 <pop_off>
}
    80000d6c:	60e2                	ld	ra,24(sp)
    80000d6e:	6442                	ld	s0,16(sp)
    80000d70:	64a2                	ld	s1,8(sp)
    80000d72:	6105                	addi	sp,sp,32
    80000d74:	8082                	ret
    panic("release");
    80000d76:	00007517          	auipc	a0,0x7
    80000d7a:	32250513          	addi	a0,a0,802 # 80008098 <digits+0x60>
    80000d7e:	a0bff0ef          	jal	ra,80000788 <panic>

0000000080000d82 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d82:	1141                	addi	sp,sp,-16
    80000d84:	e422                	sd	s0,8(sp)
    80000d86:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d88:	ca19                	beqz	a2,80000d9e <memset+0x1c>
    80000d8a:	87aa                	mv	a5,a0
    80000d8c:	1602                	slli	a2,a2,0x20
    80000d8e:	9201                	srli	a2,a2,0x20
    80000d90:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d94:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d98:	0785                	addi	a5,a5,1
    80000d9a:	fee79de3          	bne	a5,a4,80000d94 <memset+0x12>
  }
  return dst;
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000daa:	ca05                	beqz	a2,80000dda <memcmp+0x36>
    80000dac:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000db0:	1682                	slli	a3,a3,0x20
    80000db2:	9281                	srli	a3,a3,0x20
    80000db4:	0685                	addi	a3,a3,1
    80000db6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000db8:	00054783          	lbu	a5,0(a0)
    80000dbc:	0005c703          	lbu	a4,0(a1)
    80000dc0:	00e79863          	bne	a5,a4,80000dd0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dc4:	0505                	addi	a0,a0,1
    80000dc6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dc8:	fed518e3          	bne	a0,a3,80000db8 <memcmp+0x14>
  }

  return 0;
    80000dcc:	4501                	li	a0,0
    80000dce:	a019                	j	80000dd4 <memcmp+0x30>
      return *s1 - *s2;
    80000dd0:	40e7853b          	subw	a0,a5,a4
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
  return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <memcmp+0x30>

0000000080000dde <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000de4:	c205                	beqz	a2,80000e04 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000de6:	02a5e263          	bltu	a1,a0,80000e0a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dea:	1602                	slli	a2,a2,0x20
    80000dec:	9201                	srli	a2,a2,0x20
    80000dee:	00c587b3          	add	a5,a1,a2
{
    80000df2:	872a                	mv	a4,a0
      *d++ = *s++;
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	0705                	addi	a4,a4,1
    80000df8:	fff5c683          	lbu	a3,-1(a1)
    80000dfc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e00:	fef59ae3          	bne	a1,a5,80000df4 <memmove+0x16>

  return dst;
}
    80000e04:	6422                	ld	s0,8(sp)
    80000e06:	0141                	addi	sp,sp,16
    80000e08:	8082                	ret
  if(s < d && s + n > d){
    80000e0a:	02061693          	slli	a3,a2,0x20
    80000e0e:	9281                	srli	a3,a3,0x20
    80000e10:	00d58733          	add	a4,a1,a3
    80000e14:	fce57be3          	bgeu	a0,a4,80000dea <memmove+0xc>
    d += n;
    80000e18:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e1a:	fff6079b          	addiw	a5,a2,-1
    80000e1e:	1782                	slli	a5,a5,0x20
    80000e20:	9381                	srli	a5,a5,0x20
    80000e22:	fff7c793          	not	a5,a5
    80000e26:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e28:	177d                	addi	a4,a4,-1
    80000e2a:	16fd                	addi	a3,a3,-1
    80000e2c:	00074603          	lbu	a2,0(a4)
    80000e30:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e34:	fee79ae3          	bne	a5,a4,80000e28 <memmove+0x4a>
    80000e38:	b7f1                	j	80000e04 <memmove+0x26>

0000000080000e3a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e3a:	1141                	addi	sp,sp,-16
    80000e3c:	e406                	sd	ra,8(sp)
    80000e3e:	e022                	sd	s0,0(sp)
    80000e40:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e42:	f9dff0ef          	jal	ra,80000dde <memmove>
}
    80000e46:	60a2                	ld	ra,8(sp)
    80000e48:	6402                	ld	s0,0(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e54:	ce11                	beqz	a2,80000e70 <strncmp+0x22>
    80000e56:	00054783          	lbu	a5,0(a0)
    80000e5a:	cf89                	beqz	a5,80000e74 <strncmp+0x26>
    80000e5c:	0005c703          	lbu	a4,0(a1)
    80000e60:	00f71a63          	bne	a4,a5,80000e74 <strncmp+0x26>
    n--, p++, q++;
    80000e64:	367d                	addiw	a2,a2,-1
    80000e66:	0505                	addi	a0,a0,1
    80000e68:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e6a:	f675                	bnez	a2,80000e56 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e6c:	4501                	li	a0,0
    80000e6e:	a809                	j	80000e80 <strncmp+0x32>
    80000e70:	4501                	li	a0,0
    80000e72:	a039                	j	80000e80 <strncmp+0x32>
  if(n == 0)
    80000e74:	ca09                	beqz	a2,80000e86 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e76:	00054503          	lbu	a0,0(a0)
    80000e7a:	0005c783          	lbu	a5,0(a1)
    80000e7e:	9d1d                	subw	a0,a0,a5
}
    80000e80:	6422                	ld	s0,8(sp)
    80000e82:	0141                	addi	sp,sp,16
    80000e84:	8082                	ret
    return 0;
    80000e86:	4501                	li	a0,0
    80000e88:	bfe5                	j	80000e80 <strncmp+0x32>

0000000080000e8a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e8a:	1141                	addi	sp,sp,-16
    80000e8c:	e422                	sd	s0,8(sp)
    80000e8e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e90:	872a                	mv	a4,a0
    80000e92:	8832                	mv	a6,a2
    80000e94:	367d                	addiw	a2,a2,-1
    80000e96:	01005963          	blez	a6,80000ea8 <strncpy+0x1e>
    80000e9a:	0705                	addi	a4,a4,1
    80000e9c:	0005c783          	lbu	a5,0(a1)
    80000ea0:	fef70fa3          	sb	a5,-1(a4)
    80000ea4:	0585                	addi	a1,a1,1
    80000ea6:	f7f5                	bnez	a5,80000e92 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ea8:	86ba                	mv	a3,a4
    80000eaa:	00c05c63          	blez	a2,80000ec2 <strncpy+0x38>
    *s++ = 0;
    80000eae:	0685                	addi	a3,a3,1
    80000eb0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000eb4:	40d707bb          	subw	a5,a4,a3
    80000eb8:	37fd                	addiw	a5,a5,-1
    80000eba:	010787bb          	addw	a5,a5,a6
    80000ebe:	fef048e3          	bgtz	a5,80000eae <strncpy+0x24>
  return os;
}
    80000ec2:	6422                	ld	s0,8(sp)
    80000ec4:	0141                	addi	sp,sp,16
    80000ec6:	8082                	ret

0000000080000ec8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ec8:	1141                	addi	sp,sp,-16
    80000eca:	e422                	sd	s0,8(sp)
    80000ecc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ece:	02c05363          	blez	a2,80000ef4 <safestrcpy+0x2c>
    80000ed2:	fff6069b          	addiw	a3,a2,-1
    80000ed6:	1682                	slli	a3,a3,0x20
    80000ed8:	9281                	srli	a3,a3,0x20
    80000eda:	96ae                	add	a3,a3,a1
    80000edc:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ede:	00d58963          	beq	a1,a3,80000ef0 <safestrcpy+0x28>
    80000ee2:	0585                	addi	a1,a1,1
    80000ee4:	0785                	addi	a5,a5,1
    80000ee6:	fff5c703          	lbu	a4,-1(a1)
    80000eea:	fee78fa3          	sb	a4,-1(a5)
    80000eee:	fb65                	bnez	a4,80000ede <safestrcpy+0x16>
    ;
  *s = 0;
    80000ef0:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ef4:	6422                	ld	s0,8(sp)
    80000ef6:	0141                	addi	sp,sp,16
    80000ef8:	8082                	ret

0000000080000efa <strlen>:

int
strlen(const char *s)
{
    80000efa:	1141                	addi	sp,sp,-16
    80000efc:	e422                	sd	s0,8(sp)
    80000efe:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f00:	00054783          	lbu	a5,0(a0)
    80000f04:	cf91                	beqz	a5,80000f20 <strlen+0x26>
    80000f06:	0505                	addi	a0,a0,1
    80000f08:	87aa                	mv	a5,a0
    80000f0a:	4685                	li	a3,1
    80000f0c:	9e89                	subw	a3,a3,a0
    80000f0e:	00f6853b          	addw	a0,a3,a5
    80000f12:	0785                	addi	a5,a5,1
    80000f14:	fff7c703          	lbu	a4,-1(a5)
    80000f18:	fb7d                	bnez	a4,80000f0e <strlen+0x14>
    ;
  return n;
}
    80000f1a:	6422                	ld	s0,8(sp)
    80000f1c:	0141                	addi	sp,sp,16
    80000f1e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f20:	4501                	li	a0,0
    80000f22:	bfe5                	j	80000f1a <strlen+0x20>

0000000080000f24 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f24:	1141                	addi	sp,sp,-16
    80000f26:	e406                	sd	ra,8(sp)
    80000f28:	e022                	sd	s0,0(sp)
    80000f2a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f2c:	441000ef          	jal	ra,80001b6c <cpuid>
    seminit();

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f30:	00008717          	auipc	a4,0x8
    80000f34:	9a070713          	addi	a4,a4,-1632 # 800088d0 <started>
  if(cpuid() == 0){
    80000f38:	c51d                	beqz	a0,80000f66 <main+0x42>
    while(started == 0)
    80000f3a:	431c                	lw	a5,0(a4)
    80000f3c:	2781                	sext.w	a5,a5
    80000f3e:	dff5                	beqz	a5,80000f3a <main+0x16>
      ;
    __sync_synchronize();
    80000f40:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f44:	429000ef          	jal	ra,80001b6c <cpuid>
    80000f48:	85aa                	mv	a1,a0
    80000f4a:	00007517          	auipc	a0,0x7
    80000f4e:	16e50513          	addi	a0,a0,366 # 800080b8 <digits+0x80>
    80000f52:	d70ff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000f56:	08c000ef          	jal	ra,80000fe2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f5a:	251010ef          	jal	ra,800029aa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f5e:	0c6050ef          	jal	ra,80006024 <plicinithart>
  }

  scheduler();        
    80000f62:	38e010ef          	jal	ra,800022f0 <scheduler>
    consoleinit();
    80000f66:	c86ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000f6a:	85bff0ef          	jal	ra,800007c4 <printfinit>
    printf("\n");
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	15a50513          	addi	a0,a0,346 # 800080c8 <digits+0x90>
    80000f76:	d4cff0ef          	jal	ra,800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000f7a:	00007517          	auipc	a0,0x7
    80000f7e:	12650513          	addi	a0,a0,294 # 800080a0 <digits+0x68>
    80000f82:	d40ff0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80000f86:	00007517          	auipc	a0,0x7
    80000f8a:	14250513          	addi	a0,a0,322 # 800080c8 <digits+0x90>
    80000f8e:	d34ff0ef          	jal	ra,800004c2 <printf>
    vmstatsinit();
    80000f92:	53f050ef          	jal	ra,80006cd0 <vmstatsinit>
    kinit();         // physical page allocator
    80000f96:	bcdff0ef          	jal	ra,80000b62 <kinit>
    kvminit();       // create kernel page table
    80000f9a:	2d2000ef          	jal	ra,8000126c <kvminit>
    kvminithart();   // turn on paging
    80000f9e:	044000ef          	jal	ra,80000fe2 <kvminithart>
    procinit();      // process table
    80000fa2:	323000ef          	jal	ra,80001ac4 <procinit>
    trapinit();      // trap vectors
    80000fa6:	1e1010ef          	jal	ra,80002986 <trapinit>
    trapinithart();  // install kernel trap vector
    80000faa:	201010ef          	jal	ra,800029aa <trapinithart>
    plicinit();      // set up interrupt controller
    80000fae:	060050ef          	jal	ra,8000600e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fb2:	072050ef          	jal	ra,80006024 <plicinithart>
    binit();         // buffer cache
    80000fb6:	7a6020ef          	jal	ra,8000375c <binit>
    iinit();         // inode table
    80000fba:	517020ef          	jal	ra,80003cd0 <iinit>
    fileinit();      // file table
    80000fbe:	3ff030ef          	jal	ra,80004bbc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc2:	152050ef          	jal	ra,80006114 <virtio_disk_init>
    userinit();      // first user process
    80000fc6:	0f0010ef          	jal	ra,800020b6 <userinit>
    shm_init();
    80000fca:	5be050ef          	jal	ra,80006588 <shm_init>
    seminit();
    80000fce:	2c7050ef          	jal	ra,80006a94 <seminit>
    __sync_synchronize();
    80000fd2:	0ff0000f          	fence
    started = 1;
    80000fd6:	4785                	li	a5,1
    80000fd8:	00008717          	auipc	a4,0x8
    80000fdc:	8ef72c23          	sw	a5,-1800(a4) # 800088d0 <started>
    80000fe0:	b749                	j	80000f62 <main+0x3e>

0000000080000fe2 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e422                	sd	s0,8(sp)
    80000fe6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fe8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fec:	00008797          	auipc	a5,0x8
    80000ff0:	8ec7b783          	ld	a5,-1812(a5) # 800088d8 <kernel_pagetable>
    80000ff4:	83b1                	srli	a5,a5,0xc
    80000ff6:	577d                	li	a4,-1
    80000ff8:	177e                	slli	a4,a4,0x3f
    80000ffa:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ffc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001000:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001004:	6422                	ld	s0,8(sp)
    80001006:	0141                	addi	sp,sp,16
    80001008:	8082                	ret

000000008000100a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000100a:	7139                	addi	sp,sp,-64
    8000100c:	fc06                	sd	ra,56(sp)
    8000100e:	f822                	sd	s0,48(sp)
    80001010:	f426                	sd	s1,40(sp)
    80001012:	f04a                	sd	s2,32(sp)
    80001014:	ec4e                	sd	s3,24(sp)
    80001016:	e852                	sd	s4,16(sp)
    80001018:	e456                	sd	s5,8(sp)
    8000101a:	e05a                	sd	s6,0(sp)
    8000101c:	0080                	addi	s0,sp,64
    8000101e:	84aa                	mv	s1,a0
    80001020:	89ae                	mv	s3,a1
    80001022:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001024:	57fd                	li	a5,-1
    80001026:	83e9                	srli	a5,a5,0x1a
    80001028:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000102a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000102c:	02b7fc63          	bgeu	a5,a1,80001064 <walk+0x5a>
    panic("walk");
    80001030:	00007517          	auipc	a0,0x7
    80001034:	0a050513          	addi	a0,a0,160 # 800080d0 <digits+0x98>
    80001038:	f50ff0ef          	jal	ra,80000788 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000103c:	060a8263          	beqz	s5,800010a0 <walk+0x96>
    80001040:	b6bff0ef          	jal	ra,80000baa <kalloc>
    80001044:	84aa                	mv	s1,a0
    80001046:	c139                	beqz	a0,8000108c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001048:	6605                	lui	a2,0x1
    8000104a:	4581                	li	a1,0
    8000104c:	d37ff0ef          	jal	ra,80000d82 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001050:	00c4d793          	srli	a5,s1,0xc
    80001054:	07aa                	slli	a5,a5,0xa
    80001056:	0017e793          	ori	a5,a5,1
    8000105a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000105e:	3a5d                	addiw	s4,s4,-9 # 1ff7 <_entry-0x7fffe009>
    80001060:	036a0063          	beq	s4,s6,80001080 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001064:	0149d933          	srl	s2,s3,s4
    80001068:	1ff97913          	andi	s2,s2,511
    8000106c:	090e                	slli	s2,s2,0x3
    8000106e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001070:	00093483          	ld	s1,0(s2)
    80001074:	0014f793          	andi	a5,s1,1
    80001078:	d3f1                	beqz	a5,8000103c <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000107a:	80a9                	srli	s1,s1,0xa
    8000107c:	04b2                	slli	s1,s1,0xc
    8000107e:	b7c5                	j	8000105e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001080:	00c9d513          	srli	a0,s3,0xc
    80001084:	1ff57513          	andi	a0,a0,511
    80001088:	050e                	slli	a0,a0,0x3
    8000108a:	9526                	add	a0,a0,s1
}
    8000108c:	70e2                	ld	ra,56(sp)
    8000108e:	7442                	ld	s0,48(sp)
    80001090:	74a2                	ld	s1,40(sp)
    80001092:	7902                	ld	s2,32(sp)
    80001094:	69e2                	ld	s3,24(sp)
    80001096:	6a42                	ld	s4,16(sp)
    80001098:	6aa2                	ld	s5,8(sp)
    8000109a:	6b02                	ld	s6,0(sp)
    8000109c:	6121                	addi	sp,sp,64
    8000109e:	8082                	ret
        return 0;
    800010a0:	4501                	li	a0,0
    800010a2:	b7ed                	j	8000108c <walk+0x82>

00000000800010a4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010a4:	57fd                	li	a5,-1
    800010a6:	83e9                	srli	a5,a5,0x1a
    800010a8:	00b7f463          	bgeu	a5,a1,800010b0 <walkaddr+0xc>
    return 0;
    800010ac:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010ae:	8082                	ret
{
    800010b0:	1141                	addi	sp,sp,-16
    800010b2:	e406                	sd	ra,8(sp)
    800010b4:	e022                	sd	s0,0(sp)
    800010b6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010b8:	4601                	li	a2,0
    800010ba:	f51ff0ef          	jal	ra,8000100a <walk>
  if(pte == 0)
    800010be:	c105                	beqz	a0,800010de <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800010c0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010c2:	0117f693          	andi	a3,a5,17
    800010c6:	4745                	li	a4,17
    return 0;
    800010c8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010ca:	00e68663          	beq	a3,a4,800010d6 <walkaddr+0x32>
}
    800010ce:	60a2                	ld	ra,8(sp)
    800010d0:	6402                	ld	s0,0(sp)
    800010d2:	0141                	addi	sp,sp,16
    800010d4:	8082                	ret
  pa = PTE2PA(*pte);
    800010d6:	83a9                	srli	a5,a5,0xa
    800010d8:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010dc:	bfcd                	j	800010ce <walkaddr+0x2a>
    return 0;
    800010de:	4501                	li	a0,0
    800010e0:	b7fd                	j	800010ce <walkaddr+0x2a>

00000000800010e2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010e2:	715d                	addi	sp,sp,-80
    800010e4:	e486                	sd	ra,72(sp)
    800010e6:	e0a2                	sd	s0,64(sp)
    800010e8:	fc26                	sd	s1,56(sp)
    800010ea:	f84a                	sd	s2,48(sp)
    800010ec:	f44e                	sd	s3,40(sp)
    800010ee:	f052                	sd	s4,32(sp)
    800010f0:	ec56                	sd	s5,24(sp)
    800010f2:	e85a                	sd	s6,16(sp)
    800010f4:	e45e                	sd	s7,8(sp)
    800010f6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010f8:	03459793          	slli	a5,a1,0x34
    800010fc:	e7a9                	bnez	a5,80001146 <mappages+0x64>
    800010fe:	8aaa                	mv	s5,a0
    80001100:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001102:	03461793          	slli	a5,a2,0x34
    80001106:	e7b1                	bnez	a5,80001152 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001108:	ca39                	beqz	a2,8000115e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000110a:	77fd                	lui	a5,0xfffff
    8000110c:	963e                	add	a2,a2,a5
    8000110e:	00b609b3          	add	s3,a2,a1
  a = va;
    80001112:	892e                	mv	s2,a1
    80001114:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001118:	6b85                	lui	s7,0x1
    8000111a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000111e:	4605                	li	a2,1
    80001120:	85ca                	mv	a1,s2
    80001122:	8556                	mv	a0,s5
    80001124:	ee7ff0ef          	jal	ra,8000100a <walk>
    80001128:	c539                	beqz	a0,80001176 <mappages+0x94>
    if(*pte & PTE_V)
    8000112a:	611c                	ld	a5,0(a0)
    8000112c:	8b85                	andi	a5,a5,1
    8000112e:	ef95                	bnez	a5,8000116a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001130:	80b1                	srli	s1,s1,0xc
    80001132:	04aa                	slli	s1,s1,0xa
    80001134:	0164e4b3          	or	s1,s1,s6
    80001138:	0014e493          	ori	s1,s1,1
    8000113c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000113e:	05390863          	beq	s2,s3,8000118e <mappages+0xac>
    a += PGSIZE;
    80001142:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001144:	bfd9                	j	8000111a <mappages+0x38>
    panic("mappages: va not aligned");
    80001146:	00007517          	auipc	a0,0x7
    8000114a:	f9250513          	addi	a0,a0,-110 # 800080d8 <digits+0xa0>
    8000114e:	e3aff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size not aligned");
    80001152:	00007517          	auipc	a0,0x7
    80001156:	fa650513          	addi	a0,a0,-90 # 800080f8 <digits+0xc0>
    8000115a:	e2eff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	fba50513          	addi	a0,a0,-70 # 80008118 <digits+0xe0>
    80001166:	e22ff0ef          	jal	ra,80000788 <panic>
      panic("mappages: remap");
    8000116a:	00007517          	auipc	a0,0x7
    8000116e:	fbe50513          	addi	a0,a0,-66 # 80008128 <digits+0xf0>
    80001172:	e16ff0ef          	jal	ra,80000788 <panic>
      return -1;
    80001176:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001178:	60a6                	ld	ra,72(sp)
    8000117a:	6406                	ld	s0,64(sp)
    8000117c:	74e2                	ld	s1,56(sp)
    8000117e:	7942                	ld	s2,48(sp)
    80001180:	79a2                	ld	s3,40(sp)
    80001182:	7a02                	ld	s4,32(sp)
    80001184:	6ae2                	ld	s5,24(sp)
    80001186:	6b42                	ld	s6,16(sp)
    80001188:	6ba2                	ld	s7,8(sp)
    8000118a:	6161                	addi	sp,sp,80
    8000118c:	8082                	ret
  return 0;
    8000118e:	4501                	li	a0,0
    80001190:	b7e5                	j	80001178 <mappages+0x96>

0000000080001192 <kvmmap>:
{
    80001192:	1141                	addi	sp,sp,-16
    80001194:	e406                	sd	ra,8(sp)
    80001196:	e022                	sd	s0,0(sp)
    80001198:	0800                	addi	s0,sp,16
    8000119a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000119c:	86b2                	mv	a3,a2
    8000119e:	863e                	mv	a2,a5
    800011a0:	f43ff0ef          	jal	ra,800010e2 <mappages>
    800011a4:	e509                	bnez	a0,800011ae <kvmmap+0x1c>
}
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	addi	sp,sp,16
    800011ac:	8082                	ret
    panic("kvmmap");
    800011ae:	00007517          	auipc	a0,0x7
    800011b2:	f8a50513          	addi	a0,a0,-118 # 80008138 <digits+0x100>
    800011b6:	dd2ff0ef          	jal	ra,80000788 <panic>

00000000800011ba <kvmmake>:
{
    800011ba:	1101                	addi	sp,sp,-32
    800011bc:	ec06                	sd	ra,24(sp)
    800011be:	e822                	sd	s0,16(sp)
    800011c0:	e426                	sd	s1,8(sp)
    800011c2:	e04a                	sd	s2,0(sp)
    800011c4:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011c6:	9e5ff0ef          	jal	ra,80000baa <kalloc>
    800011ca:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011cc:	6605                	lui	a2,0x1
    800011ce:	4581                	li	a1,0
    800011d0:	bb3ff0ef          	jal	ra,80000d82 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	6685                	lui	a3,0x1
    800011d8:	10000637          	lui	a2,0x10000
    800011dc:	100005b7          	lui	a1,0x10000
    800011e0:	8526                	mv	a0,s1
    800011e2:	fb1ff0ef          	jal	ra,80001192 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011e6:	4719                	li	a4,6
    800011e8:	6685                	lui	a3,0x1
    800011ea:	10001637          	lui	a2,0x10001
    800011ee:	100015b7          	lui	a1,0x10001
    800011f2:	8526                	mv	a0,s1
    800011f4:	f9fff0ef          	jal	ra,80001192 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011f8:	4719                	li	a4,6
    800011fa:	040006b7          	lui	a3,0x4000
    800011fe:	0c000637          	lui	a2,0xc000
    80001202:	0c0005b7          	lui	a1,0xc000
    80001206:	8526                	mv	a0,s1
    80001208:	f8bff0ef          	jal	ra,80001192 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000120c:	00007917          	auipc	s2,0x7
    80001210:	df490913          	addi	s2,s2,-524 # 80008000 <etext>
    80001214:	4729                	li	a4,10
    80001216:	80007697          	auipc	a3,0x80007
    8000121a:	dea68693          	addi	a3,a3,-534 # 8000 <_entry-0x7fff8000>
    8000121e:	4605                	li	a2,1
    80001220:	067e                	slli	a2,a2,0x1f
    80001222:	85b2                	mv	a1,a2
    80001224:	8526                	mv	a0,s1
    80001226:	f6dff0ef          	jal	ra,80001192 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000122a:	4719                	li	a4,6
    8000122c:	46c5                	li	a3,17
    8000122e:	06ee                	slli	a3,a3,0x1b
    80001230:	412686b3          	sub	a3,a3,s2
    80001234:	864a                	mv	a2,s2
    80001236:	85ca                	mv	a1,s2
    80001238:	8526                	mv	a0,s1
    8000123a:	f59ff0ef          	jal	ra,80001192 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000123e:	4729                	li	a4,10
    80001240:	6685                	lui	a3,0x1
    80001242:	00006617          	auipc	a2,0x6
    80001246:	dbe60613          	addi	a2,a2,-578 # 80007000 <_trampoline>
    8000124a:	040005b7          	lui	a1,0x4000
    8000124e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001250:	05b2                	slli	a1,a1,0xc
    80001252:	8526                	mv	a0,s1
    80001254:	f3fff0ef          	jal	ra,80001192 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001258:	8526                	mv	a0,s1
    8000125a:	7e0000ef          	jal	ra,80001a3a <proc_mapstacks>
}
    8000125e:	8526                	mv	a0,s1
    80001260:	60e2                	ld	ra,24(sp)
    80001262:	6442                	ld	s0,16(sp)
    80001264:	64a2                	ld	s1,8(sp)
    80001266:	6902                	ld	s2,0(sp)
    80001268:	6105                	addi	sp,sp,32
    8000126a:	8082                	ret

000000008000126c <kvminit>:
{
    8000126c:	1141                	addi	sp,sp,-16
    8000126e:	e406                	sd	ra,8(sp)
    80001270:	e022                	sd	s0,0(sp)
    80001272:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001274:	f47ff0ef          	jal	ra,800011ba <kvmmake>
    80001278:	00007797          	auipc	a5,0x7
    8000127c:	66a7b023          	sd	a0,1632(a5) # 800088d8 <kernel_pagetable>
}
    80001280:	60a2                	ld	ra,8(sp)
    80001282:	6402                	ld	s0,0(sp)
    80001284:	0141                	addi	sp,sp,16
    80001286:	8082                	ret

0000000080001288 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001288:	1101                	addi	sp,sp,-32
    8000128a:	ec06                	sd	ra,24(sp)
    8000128c:	e822                	sd	s0,16(sp)
    8000128e:	e426                	sd	s1,8(sp)
    80001290:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001292:	919ff0ef          	jal	ra,80000baa <kalloc>
    80001296:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001298:	c509                	beqz	a0,800012a2 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000129a:	6605                	lui	a2,0x1
    8000129c:	4581                	li	a1,0
    8000129e:	ae5ff0ef          	jal	ra,80000d82 <memset>
  return pagetable;
}
    800012a2:	8526                	mv	a0,s1
    800012a4:	60e2                	ld	ra,24(sp)
    800012a6:	6442                	ld	s0,16(sp)
    800012a8:	64a2                	ld	s1,8(sp)
    800012aa:	6105                	addi	sp,sp,32
    800012ac:	8082                	ret

00000000800012ae <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012ae:	7139                	addi	sp,sp,-64
    800012b0:	fc06                	sd	ra,56(sp)
    800012b2:	f822                	sd	s0,48(sp)
    800012b4:	f426                	sd	s1,40(sp)
    800012b6:	f04a                	sd	s2,32(sp)
    800012b8:	ec4e                	sd	s3,24(sp)
    800012ba:	e852                	sd	s4,16(sp)
    800012bc:	e456                	sd	s5,8(sp)
    800012be:	e05a                	sd	s6,0(sp)
    800012c0:	0080                	addi	s0,sp,64
  
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c2:	03459793          	slli	a5,a1,0x34
    800012c6:	e785                	bnez	a5,800012ee <uvmunmap+0x40>
    800012c8:	8a2a                	mv	s4,a0
    800012ca:	892e                	mv	s2,a1
    800012cc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ce:	0632                	slli	a2,a2,0xc
    800012d0:	00b609b3          	add	s3,a2,a1
    800012d4:	6b05                	lui	s6,0x1
    800012d6:	0335e763          	bltu	a1,s3,80001304 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012da:	70e2                	ld	ra,56(sp)
    800012dc:	7442                	ld	s0,48(sp)
    800012de:	74a2                	ld	s1,40(sp)
    800012e0:	7902                	ld	s2,32(sp)
    800012e2:	69e2                	ld	s3,24(sp)
    800012e4:	6a42                	ld	s4,16(sp)
    800012e6:	6aa2                	ld	s5,8(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	6121                	addi	sp,sp,64
    800012ec:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ee:	00007517          	auipc	a0,0x7
    800012f2:	e5250513          	addi	a0,a0,-430 # 80008140 <digits+0x108>
    800012f6:	c92ff0ef          	jal	ra,80000788 <panic>
    *pte = 0;
    800012fa:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012fe:	995a                	add	s2,s2,s6
    80001300:	fd397de3          	bgeu	s2,s3,800012da <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001304:	4601                	li	a2,0
    80001306:	85ca                	mv	a1,s2
    80001308:	8552                	mv	a0,s4
    8000130a:	d01ff0ef          	jal	ra,8000100a <walk>
    8000130e:	84aa                	mv	s1,a0
    80001310:	d57d                	beqz	a0,800012fe <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001312:	611c                	ld	a5,0(a0)
    80001314:	0017f713          	andi	a4,a5,1
    80001318:	d37d                	beqz	a4,800012fe <uvmunmap+0x50>
    if(do_free){
    8000131a:	fe0a80e3          	beqz	s5,800012fa <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    8000131e:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001320:	00c79513          	slli	a0,a5,0xc
    80001324:	f56ff0ef          	jal	ra,80000a7a <kfree>
    80001328:	bfc9                	j	800012fa <uvmunmap+0x4c>

000000008000132a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000132a:	1101                	addi	sp,sp,-32
    8000132c:	ec06                	sd	ra,24(sp)
    8000132e:	e822                	sd	s0,16(sp)
    80001330:	e426                	sd	s1,8(sp)
    80001332:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001334:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001336:	00b67d63          	bgeu	a2,a1,80001350 <uvmdealloc+0x26>
    8000133a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000133c:	6785                	lui	a5,0x1
    8000133e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001340:	00f60733          	add	a4,a2,a5
    80001344:	76fd                	lui	a3,0xfffff
    80001346:	8f75                	and	a4,a4,a3
    80001348:	97ae                	add	a5,a5,a1
    8000134a:	8ff5                	and	a5,a5,a3
    8000134c:	00f76863          	bltu	a4,a5,8000135c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001350:	8526                	mv	a0,s1
    80001352:	60e2                	ld	ra,24(sp)
    80001354:	6442                	ld	s0,16(sp)
    80001356:	64a2                	ld	s1,8(sp)
    80001358:	6105                	addi	sp,sp,32
    8000135a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000135c:	8f99                	sub	a5,a5,a4
    8000135e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001360:	4685                	li	a3,1
    80001362:	0007861b          	sext.w	a2,a5
    80001366:	85ba                	mv	a1,a4
    80001368:	f47ff0ef          	jal	ra,800012ae <uvmunmap>
    8000136c:	b7d5                	j	80001350 <uvmdealloc+0x26>

000000008000136e <uvmalloc>:
  if(newsz < oldsz)
    8000136e:	08b66963          	bltu	a2,a1,80001400 <uvmalloc+0x92>
{
    80001372:	7139                	addi	sp,sp,-64
    80001374:	fc06                	sd	ra,56(sp)
    80001376:	f822                	sd	s0,48(sp)
    80001378:	f426                	sd	s1,40(sp)
    8000137a:	f04a                	sd	s2,32(sp)
    8000137c:	ec4e                	sd	s3,24(sp)
    8000137e:	e852                	sd	s4,16(sp)
    80001380:	e456                	sd	s5,8(sp)
    80001382:	e05a                	sd	s6,0(sp)
    80001384:	0080                	addi	s0,sp,64
    80001386:	8aaa                	mv	s5,a0
    80001388:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000138a:	6785                	lui	a5,0x1
    8000138c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000138e:	95be                	add	a1,a1,a5
    80001390:	77fd                	lui	a5,0xfffff
    80001392:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001396:	06c9f763          	bgeu	s3,a2,80001404 <uvmalloc+0x96>
    8000139a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000139c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800013a0:	80bff0ef          	jal	ra,80000baa <kalloc>
    800013a4:	84aa                	mv	s1,a0
    if(mem == 0){
    800013a6:	c11d                	beqz	a0,800013cc <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	9d7ff0ef          	jal	ra,80000d82 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013b0:	875a                	mv	a4,s6
    800013b2:	86a6                	mv	a3,s1
    800013b4:	6605                	lui	a2,0x1
    800013b6:	85ca                	mv	a1,s2
    800013b8:	8556                	mv	a0,s5
    800013ba:	d29ff0ef          	jal	ra,800010e2 <mappages>
    800013be:	e51d                	bnez	a0,800013ec <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013c0:	6785                	lui	a5,0x1
    800013c2:	993e                	add	s2,s2,a5
    800013c4:	fd496ee3          	bltu	s2,s4,800013a0 <uvmalloc+0x32>
  return newsz;
    800013c8:	8552                	mv	a0,s4
    800013ca:	a039                	j	800013d8 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    800013cc:	864e                	mv	a2,s3
    800013ce:	85ca                	mv	a1,s2
    800013d0:	8556                	mv	a0,s5
    800013d2:	f59ff0ef          	jal	ra,8000132a <uvmdealloc>
      return 0;
    800013d6:	4501                	li	a0,0
}
    800013d8:	70e2                	ld	ra,56(sp)
    800013da:	7442                	ld	s0,48(sp)
    800013dc:	74a2                	ld	s1,40(sp)
    800013de:	7902                	ld	s2,32(sp)
    800013e0:	69e2                	ld	s3,24(sp)
    800013e2:	6a42                	ld	s4,16(sp)
    800013e4:	6aa2                	ld	s5,8(sp)
    800013e6:	6b02                	ld	s6,0(sp)
    800013e8:	6121                	addi	sp,sp,64
    800013ea:	8082                	ret
      kfree(mem);
    800013ec:	8526                	mv	a0,s1
    800013ee:	e8cff0ef          	jal	ra,80000a7a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f2:	864e                	mv	a2,s3
    800013f4:	85ca                	mv	a1,s2
    800013f6:	8556                	mv	a0,s5
    800013f8:	f33ff0ef          	jal	ra,8000132a <uvmdealloc>
      return 0;
    800013fc:	4501                	li	a0,0
    800013fe:	bfe9                	j	800013d8 <uvmalloc+0x6a>
    return oldsz;
    80001400:	852e                	mv	a0,a1
}
    80001402:	8082                	ret
  return newsz;
    80001404:	8532                	mv	a0,a2
    80001406:	bfc9                	j	800013d8 <uvmalloc+0x6a>

0000000080001408 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001408:	7179                	addi	sp,sp,-48
    8000140a:	f406                	sd	ra,40(sp)
    8000140c:	f022                	sd	s0,32(sp)
    8000140e:	ec26                	sd	s1,24(sp)
    80001410:	e84a                	sd	s2,16(sp)
    80001412:	e44e                	sd	s3,8(sp)
    80001414:	e052                	sd	s4,0(sp)
    80001416:	1800                	addi	s0,sp,48
    80001418:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000141a:	84aa                	mv	s1,a0
    8000141c:	6905                	lui	s2,0x1
    8000141e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001420:	4985                	li	s3,1
    80001422:	a819                	j	80001438 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001424:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001426:	00c79513          	slli	a0,a5,0xc
    8000142a:	fdfff0ef          	jal	ra,80001408 <freewalk>
      pagetable[i] = 0;
    8000142e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001432:	04a1                	addi	s1,s1,8
    80001434:	01248f63          	beq	s1,s2,80001452 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001438:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000143a:	00f7f713          	andi	a4,a5,15
    8000143e:	ff3703e3          	beq	a4,s3,80001424 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001442:	8b85                	andi	a5,a5,1
    80001444:	d7fd                	beqz	a5,80001432 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001446:	00007517          	auipc	a0,0x7
    8000144a:	d1250513          	addi	a0,a0,-750 # 80008158 <digits+0x120>
    8000144e:	b3aff0ef          	jal	ra,80000788 <panic>
    }
  }
  kfree((void*)pagetable);
    80001452:	8552                	mv	a0,s4
    80001454:	e26ff0ef          	jal	ra,80000a7a <kfree>
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
    80001478:	f91ff0ef          	jal	ra,80001408 <freewalk>
}
    8000147c:	60e2                	ld	ra,24(sp)
    8000147e:	6442                	ld	s0,16(sp)
    80001480:	64a2                	ld	s1,8(sp)
    80001482:	6105                	addi	sp,sp,32
    80001484:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001486:	6785                	lui	a5,0x1
    80001488:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000148a:	95be                	add	a1,a1,a5
    8000148c:	4685                	li	a3,1
    8000148e:	00c5d613          	srli	a2,a1,0xc
    80001492:	4581                	li	a1,0
    80001494:	e1bff0ef          	jal	ra,800012ae <uvmunmap>
    80001498:	bff9                	j	80001476 <uvmfree+0xe>

000000008000149a <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    8000149a:	ce55                	beqz	a2,80001556 <uvmcopy+0xbc>
{
    8000149c:	715d                	addi	sp,sp,-80
    8000149e:	e486                	sd	ra,72(sp)
    800014a0:	e0a2                	sd	s0,64(sp)
    800014a2:	fc26                	sd	s1,56(sp)
    800014a4:	f84a                	sd	s2,48(sp)
    800014a6:	f44e                	sd	s3,40(sp)
    800014a8:	f052                	sd	s4,32(sp)
    800014aa:	ec56                	sd	s5,24(sp)
    800014ac:	e85a                	sd	s6,16(sp)
    800014ae:	e45e                	sd	s7,8(sp)
    800014b0:	0880                	addi	s0,sp,80
    800014b2:	8a2a                	mv	s4,a0
    800014b4:	8aae                	mv	s5,a1
    800014b6:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014b8:	4901                	li	s2,0
    if(flags & PTE_W){
      // 子进程和父进程映射要只读 + COW
      flags = (flags & ~PTE_W) | PTE_COW;

      // 父进程也要
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014ba:	7b7d                	lui	s6,0xfffff
    800014bc:	002b5b13          	srli	s6,s6,0x2
    800014c0:	a02d                	j	800014ea <uvmcopy+0x50>
    pa = PTE2PA(*pte);
    800014c2:	82a9                	srli	a3,a3,0xa
    800014c4:	00c69493          	slli	s1,a3,0xc
    }

    // 共享同一物理页：引用计数 +1
    kref_inc((void*)pa);
    800014c8:	8526                	mv	a0,s1
    800014ca:	d28ff0ef          	jal	ra,800009f2 <kref_inc>

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800014ce:	875e                	mv	a4,s7
    800014d0:	86a6                	mv	a3,s1
    800014d2:	6605                	lui	a2,0x1
    800014d4:	85ca                	mv	a1,s2
    800014d6:	8556                	mv	a0,s5
    800014d8:	c0bff0ef          	jal	ra,800010e2 <mappages>
    800014dc:	e529                	bnez	a0,80001526 <uvmcopy+0x8c>
    800014de:	12000073          	sfence.vma
  for(i = 0; i < sz; i += PGSIZE){
    800014e2:	6785                	lui	a5,0x1
    800014e4:	993e                	add	s2,s2,a5
    800014e6:	05397c63          	bgeu	s2,s3,8000153e <uvmcopy+0xa4>
    pte = walk(old, i, 0);
    800014ea:	4601                	li	a2,0
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8552                	mv	a0,s4
    800014f0:	b1bff0ef          	jal	ra,8000100a <walk>
    if(pte == 0)
    800014f4:	d57d                	beqz	a0,800014e2 <uvmcopy+0x48>
    if((*pte & PTE_V) == 0)
    800014f6:	6114                	ld	a3,0(a0)
    800014f8:	0016f793          	andi	a5,a3,1
    800014fc:	d3fd                	beqz	a5,800014e2 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    800014fe:	0006879b          	sext.w	a5,a3
    if((flags & PTE_U) == 0)
    80001502:	0106f713          	andi	a4,a3,16
    80001506:	df71                	beqz	a4,800014e2 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    80001508:	3ff7fb93          	andi	s7,a5,1023
    if(flags & PTE_W){
    8000150c:	8b91                	andi	a5,a5,4
    8000150e:	dbd5                	beqz	a5,800014c2 <uvmcopy+0x28>
      flags = (flags & ~PTE_W) | PTE_COW;
    80001510:	efbbf793          	andi	a5,s7,-261
    80001514:	1007eb93          	ori	s7,a5,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001518:	0166f733          	and	a4,a3,s6
    8000151c:	8fd9                	or	a5,a5,a4
    8000151e:	1017e793          	ori	a5,a5,257
    80001522:	e11c                	sd	a5,0(a0)
    80001524:	bf79                	j	800014c2 <uvmcopy+0x28>
      // map 失败要回滚 refcnt
      kref_dec((void*)pa);
    80001526:	8526                	mv	a0,s1
    80001528:	d0eff0ef          	jal	ra,80000a36 <kref_dec>
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调 kfree()， kfree 再对 refcnt--。
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000152c:	4685                	li	a3,1
    8000152e:	00c95613          	srli	a2,s2,0xc
    80001532:	4581                	li	a1,0
    80001534:	8556                	mv	a0,s5
    80001536:	d79ff0ef          	jal	ra,800012ae <uvmunmap>
  return -1;
    8000153a:	557d                	li	a0,-1
    8000153c:	a011                	j	80001540 <uvmcopy+0xa6>
  return 0;
    8000153e:	4501                	li	a0,0
}
    80001540:	60a6                	ld	ra,72(sp)
    80001542:	6406                	ld	s0,64(sp)
    80001544:	74e2                	ld	s1,56(sp)
    80001546:	7942                	ld	s2,48(sp)
    80001548:	79a2                	ld	s3,40(sp)
    8000154a:	7a02                	ld	s4,32(sp)
    8000154c:	6ae2                	ld	s5,24(sp)
    8000154e:	6b42                	ld	s6,16(sp)
    80001550:	6ba2                	ld	s7,8(sp)
    80001552:	6161                	addi	sp,sp,80
    80001554:	8082                	ret
  return 0;
    80001556:	4501                	li	a0,0
}
    80001558:	8082                	ret

000000008000155a <cowbreak>:
int
cowbreak(pagetable_t pagetable, uint64 va)
{
    8000155a:	7179                	addi	sp,sp,-48
    8000155c:	f406                	sd	ra,40(sp)
    8000155e:	f022                	sd	s0,32(sp)
    80001560:	ec26                	sd	s1,24(sp)
    80001562:	e84a                	sd	s2,16(sp)
    80001564:	e44e                	sd	s3,8(sp)
    80001566:	e052                	sd	s4,0(sp)
    80001568:	1800                	addi	s0,sp,48
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
    8000156a:	4601                	li	a2,0
    8000156c:	77fd                	lui	a5,0xfffff
    8000156e:	8dfd                	and	a1,a1,a5
    80001570:	a9bff0ef          	jal	ra,8000100a <walk>
  if(pte == 0)
    80001574:	cd51                	beqz	a0,80001610 <cowbreak+0xb6>
    80001576:	89aa                	mv	s3,a0
    return -1;
  if((*pte & PTE_V) == 0)
    80001578:	6104                	ld	s1,0(a0)
    return -1;
  if((*pte & PTE_U) == 0)
    8000157a:	0114f713          	andi	a4,s1,17
    8000157e:	47c5                	li	a5,17
    80001580:	08f71a63          	bne	a4,a5,80001614 <cowbreak+0xba>
    return -1;

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    80001584:	1044f793          	andi	a5,s1,260
    80001588:	10000713          	li	a4,256
    8000158c:	08e79663          	bne	a5,a4,80001618 <cowbreak+0xbe>
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);
    80001590:	3ff4f913          	andi	s2,s1,1023
  uint64 pa_old = PTE2PA(*pte);
    80001594:	00a4da13          	srli	s4,s1,0xa
    80001598:	0a32                	slli	s4,s4,0xc

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    8000159a:	8552                	mv	a0,s4
    8000159c:	c1cff0ef          	jal	ra,800009b8 <kref_get>
    800015a0:	4785                	li	a5,1
    800015a2:	04f50663          	beq	a0,a5,800015ee <cowbreak+0x94>
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    sfence_vma();
    return 0;
  }

  char *mem = kalloc();
    800015a6:	e04ff0ef          	jal	ra,80000baa <kalloc>
    800015aa:	84aa                	mv	s1,a0
  if(mem == 0)
    800015ac:	c925                	beqz	a0,8000161c <cowbreak+0xc2>
    return -1;

  memmove(mem, (void*)pa_old, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	85d2                	mv	a1,s4
    800015b2:	82dff0ef          	jal	ra,80000dde <memmove>

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);
    800015b6:	8552                	mv	a0,s4
    800015b8:	c7eff0ef          	jal	ra,80000a36 <kref_dec>

  // 更新 PTE：指向新页，变可写，清掉 COW
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015bc:	80b1                	srli	s1,s1,0xc
    800015be:	04aa                	slli	s1,s1,0xa
    800015c0:	00496913          	ori	s2,s2,4
    800015c4:	eff97913          	andi	s2,s2,-257
    800015c8:	0124e4b3          	or	s1,s1,s2
    800015cc:	0014e493          	ori	s1,s1,1
    800015d0:	0099b023          	sd	s1,0(s3)
    800015d4:	12000073          	sfence.vma

  sfence_vma();
  vmstats_inc_cow();
    800015d8:	77a050ef          	jal	ra,80006d52 <vmstats_inc_cow>

  return 0;
    800015dc:	4501                	li	a0,0
}
    800015de:	70a2                	ld	ra,40(sp)
    800015e0:	7402                	ld	s0,32(sp)
    800015e2:	64e2                	ld	s1,24(sp)
    800015e4:	6942                	ld	s2,16(sp)
    800015e6:	69a2                	ld	s3,8(sp)
    800015e8:	6a02                	ld	s4,0(sp)
    800015ea:	6145                	addi	sp,sp,48
    800015ec:	8082                	ret
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015ee:	00496913          	ori	s2,s2,4
    800015f2:	eff97913          	andi	s2,s2,-257
    800015f6:	77fd                	lui	a5,0xfffff
    800015f8:	8389                	srli	a5,a5,0x2
    800015fa:	8cfd                	and	s1,s1,a5
    800015fc:	00996933          	or	s2,s2,s1
    80001600:	00196913          	ori	s2,s2,1
    80001604:	0129b023          	sd	s2,0(s3)
    80001608:	12000073          	sfence.vma
    return 0;
    8000160c:	4501                	li	a0,0
    8000160e:	bfc1                	j	800015de <cowbreak+0x84>
    return -1;
    80001610:	557d                	li	a0,-1
    80001612:	b7f1                	j	800015de <cowbreak+0x84>
    return -1;
    80001614:	557d                	li	a0,-1
    80001616:	b7e1                	j	800015de <cowbreak+0x84>
    return -1;
    80001618:	557d                	li	a0,-1
    8000161a:	b7d1                	j	800015de <cowbreak+0x84>
    return -1;
    8000161c:	557d                	li	a0,-1
    8000161e:	b7c1                	j	800015de <cowbreak+0x84>

0000000080001620 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001620:	1141                	addi	sp,sp,-16
    80001622:	e406                	sd	ra,8(sp)
    80001624:	e022                	sd	s0,0(sp)
    80001626:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001628:	4601                	li	a2,0
    8000162a:	9e1ff0ef          	jal	ra,8000100a <walk>
  if(pte == 0)
    8000162e:	c901                	beqz	a0,8000163e <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001630:	611c                	ld	a5,0(a0)
    80001632:	9bbd                	andi	a5,a5,-17
    80001634:	e11c                	sd	a5,0(a0)
}
    80001636:	60a2                	ld	ra,8(sp)
    80001638:	6402                	ld	s0,0(sp)
    8000163a:	0141                	addi	sp,sp,16
    8000163c:	8082                	ret
    panic("uvmclear");
    8000163e:	00007517          	auipc	a0,0x7
    80001642:	b2a50513          	addi	a0,a0,-1238 # 80008168 <digits+0x130>
    80001646:	942ff0ef          	jal	ra,80000788 <panic>

000000008000164a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000164a:	c2cd                	beqz	a3,800016ec <copyinstr+0xa2>
{
    8000164c:	715d                	addi	sp,sp,-80
    8000164e:	e486                	sd	ra,72(sp)
    80001650:	e0a2                	sd	s0,64(sp)
    80001652:	fc26                	sd	s1,56(sp)
    80001654:	f84a                	sd	s2,48(sp)
    80001656:	f44e                	sd	s3,40(sp)
    80001658:	f052                	sd	s4,32(sp)
    8000165a:	ec56                	sd	s5,24(sp)
    8000165c:	e85a                	sd	s6,16(sp)
    8000165e:	e45e                	sd	s7,8(sp)
    80001660:	0880                	addi	s0,sp,80
    80001662:	8a2a                	mv	s4,a0
    80001664:	8b2e                	mv	s6,a1
    80001666:	8bb2                	mv	s7,a2
    80001668:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000166a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000166c:	6985                	lui	s3,0x1
    8000166e:	a02d                	j	80001698 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001670:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdaadf0>
    80001674:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001676:	37fd                	addiw	a5,a5,-1
    80001678:	0007851b          	sext.w	a0,a5
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
    80001696:	c4b9                	beqz	s1,800016e4 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80001698:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000169c:	85ca                	mv	a1,s2
    8000169e:	8552                	mv	a0,s4
    800016a0:	a05ff0ef          	jal	ra,800010a4 <walkaddr>
    if(pa0 == 0)
    800016a4:	c131                	beqz	a0,800016e8 <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    800016a6:	417906b3          	sub	a3,s2,s7
    800016aa:	96ce                	add	a3,a3,s3
    800016ac:	00d4f363          	bgeu	s1,a3,800016b2 <copyinstr+0x68>
    800016b0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016b2:	955e                	add	a0,a0,s7
    800016b4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016b8:	dee9                	beqz	a3,80001692 <copyinstr+0x48>
    800016ba:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016bc:	41650633          	sub	a2,a0,s6
    800016c0:	fff48593          	addi	a1,s1,-1
    800016c4:	95da                	add	a1,a1,s6
    while(n > 0){
    800016c6:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800016c8:	00f60733          	add	a4,a2,a5
    800016cc:	00074703          	lbu	a4,0(a4)
    800016d0:	d345                	beqz	a4,80001670 <copyinstr+0x26>
        *dst = *p;
    800016d2:	00e78023          	sb	a4,0(a5)
      --max;
    800016d6:	40f584b3          	sub	s1,a1,a5
      dst++;
    800016da:	0785                	addi	a5,a5,1
    while(n > 0){
    800016dc:	fed796e3          	bne	a5,a3,800016c8 <copyinstr+0x7e>
      dst++;
    800016e0:	8b3e                	mv	s6,a5
    800016e2:	bf45                	j	80001692 <copyinstr+0x48>
    800016e4:	4781                	li	a5,0
    800016e6:	bf41                	j	80001676 <copyinstr+0x2c>
      return -1;
    800016e8:	557d                	li	a0,-1
    800016ea:	bf49                	j	8000167c <copyinstr+0x32>
  int got_null = 0;
    800016ec:	4781                	li	a5,0
  if(got_null){
    800016ee:	37fd                	addiw	a5,a5,-1
    800016f0:	0007851b          	sext.w	a0,a5
}
    800016f4:	8082                	ret

00000000800016f6 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800016f6:	1141                	addi	sp,sp,-16
    800016f8:	e406                	sd	ra,8(sp)
    800016fa:	e022                	sd	s0,0(sp)
    800016fc:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800016fe:	4601                	li	a2,0
    80001700:	90bff0ef          	jal	ra,8000100a <walk>
  if (pte == 0) {
    80001704:	c519                	beqz	a0,80001712 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001706:	6108                	ld	a0,0(a0)
    return 0;
    80001708:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    8000170a:	60a2                	ld	ra,8(sp)
    8000170c:	6402                	ld	s0,0(sp)
    8000170e:	0141                	addi	sp,sp,16
    80001710:	8082                	ret
    return 0;
    80001712:	4501                	li	a0,0
    80001714:	bfdd                	j	8000170a <ismapped+0x14>

0000000080001716 <vmfault>:
{
    80001716:	7179                	addi	sp,sp,-48
    80001718:	f406                	sd	ra,40(sp)
    8000171a:	f022                	sd	s0,32(sp)
    8000171c:	ec26                	sd	s1,24(sp)
    8000171e:	e84a                	sd	s2,16(sp)
    80001720:	e44e                	sd	s3,8(sp)
    80001722:	e052                	sd	s4,0(sp)
    80001724:	1800                	addi	s0,sp,48
    80001726:	89aa                	mv	s3,a0
    80001728:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000172a:	46e000ef          	jal	ra,80001b98 <myproc>
  if (va >= p->sz)
    8000172e:	653c                	ld	a5,72(a0)
    80001730:	00f4ec63          	bltu	s1,a5,80001748 <vmfault+0x32>
    return 0;
    80001734:	4981                	li	s3,0
}
    80001736:	854e                	mv	a0,s3
    80001738:	70a2                	ld	ra,40(sp)
    8000173a:	7402                	ld	s0,32(sp)
    8000173c:	64e2                	ld	s1,24(sp)
    8000173e:	6942                	ld	s2,16(sp)
    80001740:	69a2                	ld	s3,8(sp)
    80001742:	6a02                	ld	s4,0(sp)
    80001744:	6145                	addi	sp,sp,48
    80001746:	8082                	ret
    80001748:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000174a:	77fd                	lui	a5,0xfffff
    8000174c:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    8000174e:	85a6                	mv	a1,s1
    80001750:	854e                	mv	a0,s3
    80001752:	fa5ff0ef          	jal	ra,800016f6 <ismapped>
    return 0;
    80001756:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001758:	fd79                	bnez	a0,80001736 <vmfault+0x20>
  mem = (uint64) kalloc();
    8000175a:	c50ff0ef          	jal	ra,80000baa <kalloc>
    8000175e:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001760:	d979                	beqz	a0,80001736 <vmfault+0x20>
  mem = (uint64) kalloc();
    80001762:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001764:	6605                	lui	a2,0x1
    80001766:	4581                	li	a1,0
    80001768:	e1aff0ef          	jal	ra,80000d82 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000176c:	4759                	li	a4,22
    8000176e:	86d2                	mv	a3,s4
    80001770:	6605                	lui	a2,0x1
    80001772:	85a6                	mv	a1,s1
    80001774:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001778:	96bff0ef          	jal	ra,800010e2 <mappages>
    8000177c:	dd4d                	beqz	a0,80001736 <vmfault+0x20>
    kfree((void *)mem);
    8000177e:	8552                	mv	a0,s4
    80001780:	afaff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    80001784:	4981                	li	s3,0
    80001786:	bf45                	j	80001736 <vmfault+0x20>

0000000080001788 <copyout>:
  while(len > 0){
    80001788:	cef1                	beqz	a3,80001864 <copyout+0xdc>
{
    8000178a:	7159                	addi	sp,sp,-112
    8000178c:	f486                	sd	ra,104(sp)
    8000178e:	f0a2                	sd	s0,96(sp)
    80001790:	eca6                	sd	s1,88(sp)
    80001792:	e8ca                	sd	s2,80(sp)
    80001794:	e4ce                	sd	s3,72(sp)
    80001796:	e0d2                	sd	s4,64(sp)
    80001798:	fc56                	sd	s5,56(sp)
    8000179a:	f85a                	sd	s6,48(sp)
    8000179c:	f45e                	sd	s7,40(sp)
    8000179e:	f062                	sd	s8,32(sp)
    800017a0:	ec66                	sd	s9,24(sp)
    800017a2:	e86a                	sd	s10,16(sp)
    800017a4:	e46e                	sd	s11,8(sp)
    800017a6:	1880                	addi	s0,sp,112
    800017a8:	8aaa                	mv	s5,a0
    800017aa:	8b2e                	mv	s6,a1
    800017ac:	8bb2                	mv	s7,a2
    800017ae:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800017b0:	74fd                	lui	s1,0xfffff
    800017b2:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800017b4:	57fd                	li	a5,-1
    800017b6:	83e9                	srli	a5,a5,0x1a
    800017b8:	0a97e863          	bltu	a5,s1,80001868 <copyout+0xe0>
    800017bc:	6d05                	lui	s10,0x1
    copyout_bytes += n;
    800017be:	00007c17          	auipc	s8,0x7
    800017c2:	132c0c13          	addi	s8,s8,306 # 800088f0 <copyout_bytes>
    if(va0 >= MAXVA)
    800017c6:	8cbe                	mv	s9,a5
    800017c8:	a091                	j	8000180c <copyout+0x84>
    if((*pte & PTE_W) == 0)
    800017ca:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
    800017ce:	8b91                	andi	a5,a5,4
    800017d0:	c7c5                	beqz	a5,80001878 <copyout+0xf0>
    n = PGSIZE - (dstva - va0);
    800017d2:	01a48db3          	add	s11,s1,s10
    800017d6:	416d89b3          	sub	s3,s11,s6
    800017da:	013a7363          	bgeu	s4,s3,800017e0 <copyout+0x58>
    800017de:	89d2                	mv	s3,s4
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017e0:	409b0533          	sub	a0,s6,s1
    800017e4:	0009861b          	sext.w	a2,s3
    800017e8:	85de                	mv	a1,s7
    800017ea:	954a                	add	a0,a0,s2
    800017ec:	df2ff0ef          	jal	ra,80000dde <memmove>
    len -= n;
    800017f0:	413a0a33          	sub	s4,s4,s3
    src += n;
    800017f4:	9bce                	add	s7,s7,s3
    copyout_bytes += n;
    800017f6:	000c3783          	ld	a5,0(s8)
    800017fa:	97ce                	add	a5,a5,s3
    800017fc:	00fc3023          	sd	a5,0(s8)
  while(len > 0){
    80001800:	060a0063          	beqz	s4,80001860 <copyout+0xd8>
    if(va0 >= MAXVA)
    80001804:	07bce463          	bltu	s9,s11,8000186c <copyout+0xe4>
    va0 = PGROUNDDOWN(dstva);
    80001808:	84ee                	mv	s1,s11
    dstva = va0 + PGSIZE;
    8000180a:	8b6e                	mv	s6,s11
    pa0 = walkaddr(pagetable, va0);
    8000180c:	85a6                	mv	a1,s1
    8000180e:	8556                	mv	a0,s5
    80001810:	895ff0ef          	jal	ra,800010a4 <walkaddr>
    80001814:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001816:	e901                	bnez	a0,80001826 <copyout+0x9e>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001818:	4601                	li	a2,0
    8000181a:	85a6                	mv	a1,s1
    8000181c:	8556                	mv	a0,s5
    8000181e:	ef9ff0ef          	jal	ra,80001716 <vmfault>
    80001822:	892a                	mv	s2,a0
    80001824:	c531                	beqz	a0,80001870 <copyout+0xe8>
    pte = walk(pagetable, va0, 0);
    80001826:	4601                	li	a2,0
    80001828:	85a6                	mv	a1,s1
    8000182a:	8556                	mv	a0,s5
    8000182c:	fdeff0ef          	jal	ra,8000100a <walk>
    80001830:	89aa                	mv	s3,a0
    if(pte && (*pte & PTE_COW)){
    80001832:	dd41                	beqz	a0,800017ca <copyout+0x42>
    80001834:	611c                	ld	a5,0(a0)
    80001836:	1007f793          	andi	a5,a5,256
    8000183a:	dbc1                	beqz	a5,800017ca <copyout+0x42>
      if(cowbreak(pagetable, va0) < 0)
    8000183c:	85a6                	mv	a1,s1
    8000183e:	8556                	mv	a0,s5
    80001840:	d1bff0ef          	jal	ra,8000155a <cowbreak>
    80001844:	02054863          	bltz	a0,80001874 <copyout+0xec>
      pte = walk(pagetable, va0, 0);
    80001848:	4601                	li	a2,0
    8000184a:	85a6                	mv	a1,s1
    8000184c:	8556                	mv	a0,s5
    8000184e:	fbcff0ef          	jal	ra,8000100a <walk>
    80001852:	89aa                	mv	s3,a0
      pa0 = walkaddr(pagetable, va0);
    80001854:	85a6                	mv	a1,s1
    80001856:	8556                	mv	a0,s5
    80001858:	84dff0ef          	jal	ra,800010a4 <walkaddr>
    8000185c:	892a                	mv	s2,a0
    8000185e:	b7b5                	j	800017ca <copyout+0x42>
  return 0;
    80001860:	4501                	li	a0,0
    80001862:	a821                	j	8000187a <copyout+0xf2>
    80001864:	4501                	li	a0,0
}
    80001866:	8082                	ret
      return -1;
    80001868:	557d                	li	a0,-1
    8000186a:	a801                	j	8000187a <copyout+0xf2>
    8000186c:	557d                	li	a0,-1
    8000186e:	a031                	j	8000187a <copyout+0xf2>
        return -1;
    80001870:	557d                	li	a0,-1
    80001872:	a021                	j	8000187a <copyout+0xf2>
        return -1;
    80001874:	557d                	li	a0,-1
    80001876:	a011                	j	8000187a <copyout+0xf2>
      return -1;
    80001878:	557d                	li	a0,-1
}
    8000187a:	70a6                	ld	ra,104(sp)
    8000187c:	7406                	ld	s0,96(sp)
    8000187e:	64e6                	ld	s1,88(sp)
    80001880:	6946                	ld	s2,80(sp)
    80001882:	69a6                	ld	s3,72(sp)
    80001884:	6a06                	ld	s4,64(sp)
    80001886:	7ae2                	ld	s5,56(sp)
    80001888:	7b42                	ld	s6,48(sp)
    8000188a:	7ba2                	ld	s7,40(sp)
    8000188c:	7c02                	ld	s8,32(sp)
    8000188e:	6ce2                	ld	s9,24(sp)
    80001890:	6d42                	ld	s10,16(sp)
    80001892:	6da2                	ld	s11,8(sp)
    80001894:	6165                	addi	sp,sp,112
    80001896:	8082                	ret

0000000080001898 <copyin>:
  while(len > 0){
    80001898:	c2c5                	beqz	a3,80001938 <copyin+0xa0>
{
    8000189a:	711d                	addi	sp,sp,-96
    8000189c:	ec86                	sd	ra,88(sp)
    8000189e:	e8a2                	sd	s0,80(sp)
    800018a0:	e4a6                	sd	s1,72(sp)
    800018a2:	e0ca                	sd	s2,64(sp)
    800018a4:	fc4e                	sd	s3,56(sp)
    800018a6:	f852                	sd	s4,48(sp)
    800018a8:	f456                	sd	s5,40(sp)
    800018aa:	f05a                	sd	s6,32(sp)
    800018ac:	ec5e                	sd	s7,24(sp)
    800018ae:	e862                	sd	s8,16(sp)
    800018b0:	e466                	sd	s9,8(sp)
    800018b2:	1080                	addi	s0,sp,96
    800018b4:	8c2a                	mv	s8,a0
    800018b6:	8aae                	mv	s5,a1
    800018b8:	8932                	mv	s2,a2
    800018ba:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800018bc:	7cfd                	lui	s9,0xfffff
    n = PGSIZE - (srcva - va0);
    800018be:	6b85                	lui	s7,0x1
    copyin_bytes += n; 
    800018c0:	00007b17          	auipc	s6,0x7
    800018c4:	038b0b13          	addi	s6,s6,56 # 800088f8 <copyin_bytes>
    800018c8:	a81d                	j	800018fe <copyin+0x66>
    n = PGSIZE - (srcva - va0);
    800018ca:	412984b3          	sub	s1,s3,s2
    800018ce:	94de                	add	s1,s1,s7
    800018d0:	009a7363          	bgeu	s4,s1,800018d6 <copyin+0x3e>
    800018d4:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018d6:	413905b3          	sub	a1,s2,s3
    800018da:	0004861b          	sext.w	a2,s1
    800018de:	95aa                	add	a1,a1,a0
    800018e0:	8556                	mv	a0,s5
    800018e2:	cfcff0ef          	jal	ra,80000dde <memmove>
    len -= n;
    800018e6:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800018ea:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800018ec:	01798933          	add	s2,s3,s7
    copyin_bytes += n; 
    800018f0:	000b3783          	ld	a5,0(s6)
    800018f4:	97a6                	add	a5,a5,s1
    800018f6:	00fb3023          	sd	a5,0(s6)
  while(len > 0){
    800018fa:	020a0163          	beqz	s4,8000191c <copyin+0x84>
    va0 = PGROUNDDOWN(srcva);
    800018fe:	019979b3          	and	s3,s2,s9
    pa0 = walkaddr(pagetable, va0);
    80001902:	85ce                	mv	a1,s3
    80001904:	8562                	mv	a0,s8
    80001906:	f9eff0ef          	jal	ra,800010a4 <walkaddr>
    if(pa0 == 0) {
    8000190a:	f161                	bnez	a0,800018ca <copyin+0x32>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000190c:	4601                	li	a2,0
    8000190e:	85ce                	mv	a1,s3
    80001910:	8562                	mv	a0,s8
    80001912:	e05ff0ef          	jal	ra,80001716 <vmfault>
    80001916:	f955                	bnez	a0,800018ca <copyin+0x32>
        return -1;
    80001918:	557d                	li	a0,-1
    8000191a:	a011                	j	8000191e <copyin+0x86>
  return 0;
    8000191c:	4501                	li	a0,0
}
    8000191e:	60e6                	ld	ra,88(sp)
    80001920:	6446                	ld	s0,80(sp)
    80001922:	64a6                	ld	s1,72(sp)
    80001924:	6906                	ld	s2,64(sp)
    80001926:	79e2                	ld	s3,56(sp)
    80001928:	7a42                	ld	s4,48(sp)
    8000192a:	7aa2                	ld	s5,40(sp)
    8000192c:	7b02                	ld	s6,32(sp)
    8000192e:	6be2                	ld	s7,24(sp)
    80001930:	6c42                	ld	s8,16(sp)
    80001932:	6ca2                	ld	s9,8(sp)
    80001934:	6125                	addi	sp,sp,96
    80001936:	8082                	ret
  return 0;
    80001938:	4501                	li	a0,0
}
    8000193a:	8082                	ret

000000008000193c <vmafault>:


uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    8000193c:	7139                	addi	sp,sp,-64
    8000193e:	fc06                	sd	ra,56(sp)
    80001940:	f822                	sd	s0,48(sp)
    80001942:	f426                	sd	s1,40(sp)
    80001944:	f04a                	sd	s2,32(sp)
    80001946:	ec4e                	sd	s3,24(sp)
    80001948:	e852                	sd	s4,16(sp)
    8000194a:	e456                	sd	s5,8(sp)
    8000194c:	0080                	addi	s0,sp,64
    8000194e:	8a2a                	mv	s4,a0
    80001950:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);
    80001952:	77fd                	lui	a5,0xfffff
    80001954:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va);
    80001958:	85ce                	mv	a1,s3
    8000195a:	74c010ef          	jal	ra,800030a6 <vma_find>
  if(v == 0) return 0;
    8000195e:	c961                	beqz	a0,80001a2e <vmafault+0xf2>
    80001960:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001962:	00090663          	beqz	s2,8000196e <vmafault+0x32>
    80001966:	4d1c                	lw	a5,24(a0)
    80001968:	8b89                	andi	a5,a5,2
    return 0;
    8000196a:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    8000196c:	c789                	beqz	a5,80001976 <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0)
    8000196e:	4c9c                	lw	a5,24(s1)
    80001970:	8b85                	andi	a5,a5,1
    return 0;
    80001972:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0)
    80001974:	eb99                	bnez	a5,8000198a <vmafault+0x4e>
    else kfree((void*)pa);
    return 0;
  }
  vmstats_inc_lazy();
  return (uint64)pa;
}
    80001976:	854a                	mv	a0,s2
    80001978:	70e2                	ld	ra,56(sp)
    8000197a:	7442                	ld	s0,48(sp)
    8000197c:	74a2                	ld	s1,40(sp)
    8000197e:	7902                	ld	s2,32(sp)
    80001980:	69e2                	ld	s3,24(sp)
    80001982:	6a42                	ld	s4,16(sp)
    80001984:	6aa2                	ld	s5,8(sp)
    80001986:	6121                	addi	sp,sp,64
    80001988:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    8000198a:	4601                	li	a2,0
    8000198c:	85ce                	mv	a1,s3
    8000198e:	050a3503          	ld	a0,80(s4)
    80001992:	e78ff0ef          	jal	ra,8000100a <walk>
  if(pte && (*pte & PTE_V)){
    80001996:	c115                	beqz	a0,800019ba <vmafault+0x7e>
    80001998:	611c                	ld	a5,0(a0)
    8000199a:	0017f913          	andi	s2,a5,1
    8000199e:	00090e63          	beqz	s2,800019ba <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    800019a2:	4c98                	lw	a4,24(s1)
    800019a4:	8b09                	andi	a4,a4,2
    800019a6:	c751                	beqz	a4,80001a32 <vmafault+0xf6>
    800019a8:	0047f713          	andi	a4,a5,4
    800019ac:	e749                	bnez	a4,80001a36 <vmafault+0xfa>
      *pte |= PTE_W;
    800019ae:	0047e793          	ori	a5,a5,4
    800019b2:	e11c                	sd	a5,0(a0)
    800019b4:	12000073          	sfence.vma
      return 1;
    800019b8:	bf7d                	j	80001976 <vmafault+0x3a>
  int idx = (va - v->start) / PGSIZE;
    800019ba:	648c                	ld	a1,8(s1)
  if(v->is_shm){
    800019bc:	509c                	lw	a5,32(s1)
    800019be:	cf89                	beqz	a5,800019d8 <vmafault+0x9c>
  int idx = (va - v->start) / PGSIZE;
    800019c0:	40b985b3          	sub	a1,s3,a1
    800019c4:	81b1                	srli	a1,a1,0xc
    pa = shm_getpa(v->shm_key, idx);
    800019c6:	2581                	sext.w	a1,a1
    800019c8:	50c8                	lw	a0,36(s1)
    800019ca:	625040ef          	jal	ra,800067ee <shm_getpa>
    800019ce:	892a                	mv	s2,a0
    if(pa == 0) return 0;
    800019d0:	d15d                	beqz	a0,80001976 <vmafault+0x3a>
    kref_inc((void*)pa);
    800019d2:	820ff0ef          	jal	ra,800009f2 <kref_inc>
    800019d6:	a819                	j	800019ec <vmafault+0xb0>
    char *mem = kalloc();
    800019d8:	9d2ff0ef          	jal	ra,80000baa <kalloc>
    800019dc:	8aaa                	mv	s5,a0
    if(mem == 0) return 0;
    800019de:	4901                	li	s2,0
    800019e0:	d959                	beqz	a0,80001976 <vmafault+0x3a>
    memset(mem, 0, PGSIZE);
    800019e2:	6605                	lui	a2,0x1
    800019e4:	4581                	li	a1,0
    800019e6:	b9cff0ef          	jal	ra,80000d82 <memset>
    pa = (uint64)mem;
    800019ea:	8956                	mv	s2,s5
  if(v->prot & PROT_READ)  perm |= PTE_R;
    800019ec:	4c9c                	lw	a5,24(s1)
    800019ee:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;
    800019f2:	4741                	li	a4,16
  if(v->prot & PROT_READ)  perm |= PTE_R;
    800019f4:	c291                	beqz	a3,800019f8 <vmafault+0xbc>
    800019f6:	4749                	li	a4,18
  if(v->prot & PROT_WRITE) perm |= PTE_W;
    800019f8:	8b89                	andi	a5,a5,2
    800019fa:	c399                	beqz	a5,80001a00 <vmafault+0xc4>
    800019fc:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    80001a00:	86ca                	mv	a3,s2
    80001a02:	6605                	lui	a2,0x1
    80001a04:	85ce                	mv	a1,s3
    80001a06:	050a3503          	ld	a0,80(s4)
    80001a0a:	ed8ff0ef          	jal	ra,800010e2 <mappages>
    80001a0e:	cd09                	beqz	a0,80001a28 <vmafault+0xec>
    if(v->is_shm) kref_dec((void*)pa);
    80001a10:	509c                	lw	a5,32(s1)
    80001a12:	c791                	beqz	a5,80001a1e <vmafault+0xe2>
    80001a14:	854a                	mv	a0,s2
    80001a16:	820ff0ef          	jal	ra,80000a36 <kref_dec>
    return 0;
    80001a1a:	4901                	li	s2,0
    80001a1c:	bfa9                	j	80001976 <vmafault+0x3a>
    else kfree((void*)pa);
    80001a1e:	854a                	mv	a0,s2
    80001a20:	85aff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    80001a24:	4901                	li	s2,0
    80001a26:	bf81                	j	80001976 <vmafault+0x3a>
  vmstats_inc_lazy();
    80001a28:	358050ef          	jal	ra,80006d80 <vmstats_inc_lazy>
  return (uint64)pa;
    80001a2c:	b7a9                	j	80001976 <vmafault+0x3a>
  if(v == 0) return 0;
    80001a2e:	4901                	li	s2,0
    80001a30:	b799                	j	80001976 <vmafault+0x3a>
    return 0;
    80001a32:	4901                	li	s2,0
    80001a34:	b789                	j	80001976 <vmafault+0x3a>
    80001a36:	4901                	li	s2,0
    80001a38:	bf3d                	j	80001976 <vmafault+0x3a>

0000000080001a3a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001a3a:	7139                	addi	sp,sp,-64
    80001a3c:	fc06                	sd	ra,56(sp)
    80001a3e:	f822                	sd	s0,48(sp)
    80001a40:	f426                	sd	s1,40(sp)
    80001a42:	f04a                	sd	s2,32(sp)
    80001a44:	ec4e                	sd	s3,24(sp)
    80001a46:	e852                	sd	s4,16(sp)
    80001a48:	e456                	sd	s5,8(sp)
    80001a4a:	e05a                	sd	s6,0(sp)
    80001a4c:	0080                	addi	s0,sp,64
    80001a4e:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a50:	0022f497          	auipc	s1,0x22f
    80001a54:	40048493          	addi	s1,s1,1024 # 80230e50 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a58:	8b26                	mv	s6,s1
    80001a5a:	00006a97          	auipc	s5,0x6
    80001a5e:	5a6a8a93          	addi	s5,s5,1446 # 80008000 <etext>
    80001a62:	04000937          	lui	s2,0x4000
    80001a66:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a68:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a6a:	0023fa17          	auipc	s4,0x23f
    80001a6e:	de6a0a13          	addi	s4,s4,-538 # 80240850 <tickslock>
    char *pa = kalloc();
    80001a72:	938ff0ef          	jal	ra,80000baa <kalloc>
    80001a76:	862a                	mv	a2,a0
    if(pa == 0)
    80001a78:	c121                	beqz	a0,80001ab8 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001a7a:	416485b3          	sub	a1,s1,s6
    80001a7e:	858d                	srai	a1,a1,0x3
    80001a80:	000ab783          	ld	a5,0(s5)
    80001a84:	02f585b3          	mul	a1,a1,a5
    80001a88:	2585                	addiw	a1,a1,1
    80001a8a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a8e:	4719                	li	a4,6
    80001a90:	6685                	lui	a3,0x1
    80001a92:	40b905b3          	sub	a1,s2,a1
    80001a96:	854e                	mv	a0,s3
    80001a98:	efaff0ef          	jal	ra,80001192 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a9c:	3e848493          	addi	s1,s1,1000
    80001aa0:	fd4499e3          	bne	s1,s4,80001a72 <proc_mapstacks+0x38>
  }
}
    80001aa4:	70e2                	ld	ra,56(sp)
    80001aa6:	7442                	ld	s0,48(sp)
    80001aa8:	74a2                	ld	s1,40(sp)
    80001aaa:	7902                	ld	s2,32(sp)
    80001aac:	69e2                	ld	s3,24(sp)
    80001aae:	6a42                	ld	s4,16(sp)
    80001ab0:	6aa2                	ld	s5,8(sp)
    80001ab2:	6b02                	ld	s6,0(sp)
    80001ab4:	6121                	addi	sp,sp,64
    80001ab6:	8082                	ret
      panic("kalloc");
    80001ab8:	00006517          	auipc	a0,0x6
    80001abc:	6c050513          	addi	a0,a0,1728 # 80008178 <digits+0x140>
    80001ac0:	cc9fe0ef          	jal	ra,80000788 <panic>

0000000080001ac4 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001ac4:	7139                	addi	sp,sp,-64
    80001ac6:	fc06                	sd	ra,56(sp)
    80001ac8:	f822                	sd	s0,48(sp)
    80001aca:	f426                	sd	s1,40(sp)
    80001acc:	f04a                	sd	s2,32(sp)
    80001ace:	ec4e                	sd	s3,24(sp)
    80001ad0:	e852                	sd	s4,16(sp)
    80001ad2:	e456                	sd	s5,8(sp)
    80001ad4:	e05a                	sd	s6,0(sp)
    80001ad6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001ad8:	00006597          	auipc	a1,0x6
    80001adc:	6a858593          	addi	a1,a1,1704 # 80008180 <digits+0x148>
    80001ae0:	0022f517          	auipc	a0,0x22f
    80001ae4:	f4050513          	addi	a0,a0,-192 # 80230a20 <pid_lock>
    80001ae8:	946ff0ef          	jal	ra,80000c2e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001aec:	00006597          	auipc	a1,0x6
    80001af0:	69c58593          	addi	a1,a1,1692 # 80008188 <digits+0x150>
    80001af4:	0022f517          	auipc	a0,0x22f
    80001af8:	f4450513          	addi	a0,a0,-188 # 80230a38 <wait_lock>
    80001afc:	932ff0ef          	jal	ra,80000c2e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b00:	0022f497          	auipc	s1,0x22f
    80001b04:	35048493          	addi	s1,s1,848 # 80230e50 <proc>
      initlock(&p->lock, "proc");
    80001b08:	00006b17          	auipc	s6,0x6
    80001b0c:	690b0b13          	addi	s6,s6,1680 # 80008198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001b10:	8aa6                	mv	s5,s1
    80001b12:	00006a17          	auipc	s4,0x6
    80001b16:	4eea0a13          	addi	s4,s4,1262 # 80008000 <etext>
    80001b1a:	04000937          	lui	s2,0x4000
    80001b1e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b22:	0023f997          	auipc	s3,0x23f
    80001b26:	d2e98993          	addi	s3,s3,-722 # 80240850 <tickslock>
      initlock(&p->lock, "proc");
    80001b2a:	85da                	mv	a1,s6
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	900ff0ef          	jal	ra,80000c2e <initlock>
      p->state = UNUSED;
    80001b32:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001b36:	415487b3          	sub	a5,s1,s5
    80001b3a:	878d                	srai	a5,a5,0x3
    80001b3c:	000a3703          	ld	a4,0(s4)
    80001b40:	02e787b3          	mul	a5,a5,a4
    80001b44:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdaadf1>
    80001b46:	00d7979b          	slliw	a5,a5,0xd
    80001b4a:	40f907b3          	sub	a5,s2,a5
    80001b4e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b50:	3e848493          	addi	s1,s1,1000
    80001b54:	fd349be3          	bne	s1,s3,80001b2a <procinit+0x66>
  }
}
    80001b58:	70e2                	ld	ra,56(sp)
    80001b5a:	7442                	ld	s0,48(sp)
    80001b5c:	74a2                	ld	s1,40(sp)
    80001b5e:	7902                	ld	s2,32(sp)
    80001b60:	69e2                	ld	s3,24(sp)
    80001b62:	6a42                	ld	s4,16(sp)
    80001b64:	6aa2                	ld	s5,8(sp)
    80001b66:	6b02                	ld	s6,0(sp)
    80001b68:	6121                	addi	sp,sp,64
    80001b6a:	8082                	ret

0000000080001b6c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b6c:	1141                	addi	sp,sp,-16
    80001b6e:	e422                	sd	s0,8(sp)
    80001b70:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b72:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b74:	2501                	sext.w	a0,a0
    80001b76:	6422                	ld	s0,8(sp)
    80001b78:	0141                	addi	sp,sp,16
    80001b7a:	8082                	ret

0000000080001b7c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001b7c:	1141                	addi	sp,sp,-16
    80001b7e:	e422                	sd	s0,8(sp)
    80001b80:	0800                	addi	s0,sp,16
    80001b82:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b84:	2781                	sext.w	a5,a5
    80001b86:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b88:	0022f517          	auipc	a0,0x22f
    80001b8c:	ec850513          	addi	a0,a0,-312 # 80230a50 <cpus>
    80001b90:	953e                	add	a0,a0,a5
    80001b92:	6422                	ld	s0,8(sp)
    80001b94:	0141                	addi	sp,sp,16
    80001b96:	8082                	ret

0000000080001b98 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b98:	1101                	addi	sp,sp,-32
    80001b9a:	ec06                	sd	ra,24(sp)
    80001b9c:	e822                	sd	s0,16(sp)
    80001b9e:	e426                	sd	s1,8(sp)
    80001ba0:	1000                	addi	s0,sp,32
  push_off();
    80001ba2:	8ccff0ef          	jal	ra,80000c6e <push_off>
    80001ba6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ba8:	2781                	sext.w	a5,a5
    80001baa:	079e                	slli	a5,a5,0x7
    80001bac:	0022f717          	auipc	a4,0x22f
    80001bb0:	e7470713          	addi	a4,a4,-396 # 80230a20 <pid_lock>
    80001bb4:	97ba                	add	a5,a5,a4
    80001bb6:	7b84                	ld	s1,48(a5)
  pop_off();
    80001bb8:	93aff0ef          	jal	ra,80000cf2 <pop_off>
  return p;
}
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	60e2                	ld	ra,24(sp)
    80001bc0:	6442                	ld	s0,16(sp)
    80001bc2:	64a2                	ld	s1,8(sp)
    80001bc4:	6105                	addi	sp,sp,32
    80001bc6:	8082                	ret

0000000080001bc8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001bc8:	7179                	addi	sp,sp,-48
    80001bca:	f406                	sd	ra,40(sp)
    80001bcc:	f022                	sd	s0,32(sp)
    80001bce:	ec26                	sd	s1,24(sp)
    80001bd0:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001bd2:	fc7ff0ef          	jal	ra,80001b98 <myproc>
    80001bd6:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001bd8:	96eff0ef          	jal	ra,80000d46 <release>

  if (first) {
    80001bdc:	00007797          	auipc	a5,0x7
    80001be0:	cb47a783          	lw	a5,-844(a5) # 80008890 <first.1>
    80001be4:	cf8d                	beqz	a5,80001c1e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001be6:	4505                	li	a0,1
    80001be8:	59a020ef          	jal	ra,80004182 <fsinit>

    first = 0;
    80001bec:	00007797          	auipc	a5,0x7
    80001bf0:	ca07a223          	sw	zero,-860(a5) # 80008890 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001bf4:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001bf8:	00006517          	auipc	a0,0x6
    80001bfc:	5a850513          	addi	a0,a0,1448 # 800081a0 <digits+0x168>
    80001c00:	fca43823          	sd	a0,-48(s0)
    80001c04:	fc043c23          	sd	zero,-40(s0)
    80001c08:	fd040593          	addi	a1,s0,-48
    80001c0c:	624030ef          	jal	ra,80005230 <kexec>
    80001c10:	6cbc                	ld	a5,88(s1)
    80001c12:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001c14:	6cbc                	ld	a5,88(s1)
    80001c16:	7bb8                	ld	a4,112(a5)
    80001c18:	57fd                	li	a5,-1
    80001c1a:	02f70d63          	beq	a4,a5,80001c54 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001c1e:	5a5000ef          	jal	ra,800029c2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c22:	68a8                	ld	a0,80(s1)
    80001c24:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c26:	04000737          	lui	a4,0x4000
    80001c2a:	00005797          	auipc	a5,0x5
    80001c2e:	47278793          	addi	a5,a5,1138 # 8000709c <userret>
    80001c32:	00005697          	auipc	a3,0x5
    80001c36:	3ce68693          	addi	a3,a3,974 # 80007000 <_trampoline>
    80001c3a:	8f95                	sub	a5,a5,a3
    80001c3c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001c3e:	0732                	slli	a4,a4,0xc
    80001c40:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c42:	577d                	li	a4,-1
    80001c44:	177e                	slli	a4,a4,0x3f
    80001c46:	8d59                	or	a0,a0,a4
    80001c48:	9782                	jalr	a5
}
    80001c4a:	70a2                	ld	ra,40(sp)
    80001c4c:	7402                	ld	s0,32(sp)
    80001c4e:	64e2                	ld	s1,24(sp)
    80001c50:	6145                	addi	sp,sp,48
    80001c52:	8082                	ret
      panic("exec");
    80001c54:	00006517          	auipc	a0,0x6
    80001c58:	55450513          	addi	a0,a0,1364 # 800081a8 <digits+0x170>
    80001c5c:	b2dfe0ef          	jal	ra,80000788 <panic>

0000000080001c60 <allocpid>:
{
    80001c60:	1101                	addi	sp,sp,-32
    80001c62:	ec06                	sd	ra,24(sp)
    80001c64:	e822                	sd	s0,16(sp)
    80001c66:	e426                	sd	s1,8(sp)
    80001c68:	e04a                	sd	s2,0(sp)
    80001c6a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c6c:	0022f917          	auipc	s2,0x22f
    80001c70:	db490913          	addi	s2,s2,-588 # 80230a20 <pid_lock>
    80001c74:	854a                	mv	a0,s2
    80001c76:	838ff0ef          	jal	ra,80000cae <acquire>
  pid = nextpid;
    80001c7a:	00007797          	auipc	a5,0x7
    80001c7e:	c1a78793          	addi	a5,a5,-998 # 80008894 <nextpid>
    80001c82:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c84:	0014871b          	addiw	a4,s1,1
    80001c88:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c8a:	854a                	mv	a0,s2
    80001c8c:	8baff0ef          	jal	ra,80000d46 <release>
}
    80001c90:	8526                	mv	a0,s1
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6902                	ld	s2,0(sp)
    80001c9a:	6105                	addi	sp,sp,32
    80001c9c:	8082                	ret

0000000080001c9e <delete_shm_from_vmas>:
delete_shm_from_vmas(struct vma *vmas){
    80001c9e:	7139                	addi	sp,sp,-64
    80001ca0:	fc06                	sd	ra,56(sp)
    80001ca2:	f822                	sd	s0,48(sp)
    80001ca4:	f426                	sd	s1,40(sp)
    80001ca6:	f04a                	sd	s2,32(sp)
    80001ca8:	ec4e                	sd	s3,24(sp)
    80001caa:	e852                	sd	s4,16(sp)
    80001cac:	e456                	sd	s5,8(sp)
    80001cae:	0080                	addi	s0,sp,64
    80001cb0:	8a2a                	mv	s4,a0
    80001cb2:	84aa                	mv	s1,a0
  for(int i = 0; i < NVMA; i++){
    80001cb4:	4901                	li	s2,0
    80001cb6:	02850a93          	addi	s5,a0,40
    80001cba:	49c1                	li	s3,16
    80001cbc:	a025                	j	80001ce4 <delete_shm_from_vmas+0x46>
    for(int j = 0; j < i; j++){
    80001cbe:	02878793          	addi	a5,a5,40
    80001cc2:	00d78a63          	beq	a5,a3,80001cd6 <delete_shm_from_vmas+0x38>
      if(vmas[j].used && vmas[j].is_shm && vmas[j].shm_key == key){
    80001cc6:	4398                	lw	a4,0(a5)
    80001cc8:	db7d                	beqz	a4,80001cbe <delete_shm_from_vmas+0x20>
    80001cca:	5398                	lw	a4,32(a5)
    80001ccc:	db6d                	beqz	a4,80001cbe <delete_shm_from_vmas+0x20>
    80001cce:	53d8                	lw	a4,36(a5)
    80001cd0:	fea717e3          	bne	a4,a0,80001cbe <delete_shm_from_vmas+0x20>
    80001cd4:	a019                	j	80001cda <delete_shm_from_vmas+0x3c>
    shm_put(key);
    80001cd6:	21b040ef          	jal	ra,800066f0 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001cda:	2905                	addiw	s2,s2,1
    80001cdc:	02848493          	addi	s1,s1,40
    80001ce0:	03390463          	beq	s2,s3,80001d08 <delete_shm_from_vmas+0x6a>
    if(!vmas[i].used || !vmas[i].is_shm) continue;
    80001ce4:	409c                	lw	a5,0(s1)
    80001ce6:	dbf5                	beqz	a5,80001cda <delete_shm_from_vmas+0x3c>
    80001ce8:	509c                	lw	a5,32(s1)
    80001cea:	dbe5                	beqz	a5,80001cda <delete_shm_from_vmas+0x3c>
    int key = vmas[i].shm_key;
    80001cec:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001cee:	ff2054e3          	blez	s2,80001cd6 <delete_shm_from_vmas+0x38>
    80001cf2:	fff9079b          	addiw	a5,s2,-1
    80001cf6:	1782                	slli	a5,a5,0x20
    80001cf8:	9381                	srli	a5,a5,0x20
    80001cfa:	00279693          	slli	a3,a5,0x2
    80001cfe:	96be                	add	a3,a3,a5
    80001d00:	068e                	slli	a3,a3,0x3
    80001d02:	96d6                	add	a3,a3,s5
    80001d04:	87d2                	mv	a5,s4
    80001d06:	b7c1                	j	80001cc6 <delete_shm_from_vmas+0x28>
}
    80001d08:	70e2                	ld	ra,56(sp)
    80001d0a:	7442                	ld	s0,48(sp)
    80001d0c:	74a2                	ld	s1,40(sp)
    80001d0e:	7902                	ld	s2,32(sp)
    80001d10:	69e2                	ld	s3,24(sp)
    80001d12:	6a42                	ld	s4,16(sp)
    80001d14:	6aa2                	ld	s5,8(sp)
    80001d16:	6121                	addi	sp,sp,64
    80001d18:	8082                	ret

0000000080001d1a <delete_shm_from_proc>:
delete_shm_from_proc(struct proc *p){
    80001d1a:	7139                	addi	sp,sp,-64
    80001d1c:	fc06                	sd	ra,56(sp)
    80001d1e:	f822                	sd	s0,48(sp)
    80001d20:	f426                	sd	s1,40(sp)
    80001d22:	f04a                	sd	s2,32(sp)
    80001d24:	ec4e                	sd	s3,24(sp)
    80001d26:	e852                	sd	s4,16(sp)
    80001d28:	e456                	sd	s5,8(sp)
    80001d2a:	0080                	addi	s0,sp,64
  for(int i = 0; i < NVMA; i++){
    80001d2c:	16850a93          	addi	s5,a0,360
delete_shm_from_proc(struct proc *p){
    80001d30:	84d6                	mv	s1,s5
  for(int i = 0; i < NVMA; i++){
    80001d32:	4901                	li	s2,0
    80001d34:	19050a13          	addi	s4,a0,400
    80001d38:	49c1                	li	s3,16
    80001d3a:	a025                	j	80001d62 <delete_shm_from_proc+0x48>
    for(int j = 0; j < i; j++){
    80001d3c:	02878793          	addi	a5,a5,40
    80001d40:	00d78a63          	beq	a5,a3,80001d54 <delete_shm_from_proc+0x3a>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001d44:	4398                	lw	a4,0(a5)
    80001d46:	db7d                	beqz	a4,80001d3c <delete_shm_from_proc+0x22>
    80001d48:	5398                	lw	a4,32(a5)
    80001d4a:	db6d                	beqz	a4,80001d3c <delete_shm_from_proc+0x22>
    80001d4c:	53d8                	lw	a4,36(a5)
    80001d4e:	fea717e3          	bne	a4,a0,80001d3c <delete_shm_from_proc+0x22>
    80001d52:	a019                	j	80001d58 <delete_shm_from_proc+0x3e>
    shm_put(key);
    80001d54:	19d040ef          	jal	ra,800066f0 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001d58:	2905                	addiw	s2,s2,1
    80001d5a:	02848493          	addi	s1,s1,40
    80001d5e:	03390463          	beq	s2,s3,80001d86 <delete_shm_from_proc+0x6c>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001d62:	409c                	lw	a5,0(s1)
    80001d64:	dbf5                	beqz	a5,80001d58 <delete_shm_from_proc+0x3e>
    80001d66:	509c                	lw	a5,32(s1)
    80001d68:	dbe5                	beqz	a5,80001d58 <delete_shm_from_proc+0x3e>
    int key = p->vmas[i].shm_key;
    80001d6a:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d6c:	ff2054e3          	blez	s2,80001d54 <delete_shm_from_proc+0x3a>
    80001d70:	fff9079b          	addiw	a5,s2,-1
    80001d74:	1782                	slli	a5,a5,0x20
    80001d76:	9381                	srli	a5,a5,0x20
    80001d78:	00279693          	slli	a3,a5,0x2
    80001d7c:	96be                	add	a3,a3,a5
    80001d7e:	068e                	slli	a3,a3,0x3
    80001d80:	96d2                	add	a3,a3,s4
    80001d82:	87d6                	mv	a5,s5
    80001d84:	b7c1                	j	80001d44 <delete_shm_from_proc+0x2a>
}
    80001d86:	70e2                	ld	ra,56(sp)
    80001d88:	7442                	ld	s0,48(sp)
    80001d8a:	74a2                	ld	s1,40(sp)
    80001d8c:	7902                	ld	s2,32(sp)
    80001d8e:	69e2                	ld	s3,24(sp)
    80001d90:	6a42                	ld	s4,16(sp)
    80001d92:	6aa2                	ld	s5,8(sp)
    80001d94:	6121                	addi	sp,sp,64
    80001d96:	8082                	ret

0000000080001d98 <vma_release_all>:
{
    80001d98:	7139                	addi	sp,sp,-64
    80001d9a:	fc06                	sd	ra,56(sp)
    80001d9c:	f822                	sd	s0,48(sp)
    80001d9e:	f426                	sd	s1,40(sp)
    80001da0:	f04a                	sd	s2,32(sp)
    80001da2:	ec4e                	sd	s3,24(sp)
    80001da4:	e852                	sd	s4,16(sp)
    80001da6:	e456                	sd	s5,8(sp)
    80001da8:	e05a                	sd	s6,0(sp)
    80001daa:	0080                	addi	s0,sp,64
    80001dac:	8b2a                	mv	s6,a0
  for(int i = 0; i < NVMA; i++){
    80001dae:	16850493          	addi	s1,a0,360
    80001db2:	3e850a13          	addi	s4,a0,1000
{
    80001db6:	8926                	mv	s2,s1
    80001db8:	a029                	j	80001dc2 <vma_release_all+0x2a>
  for(int i = 0; i < NVMA; i++){
    80001dba:	02890913          	addi	s2,s2,40
    80001dbe:	03490663          	beq	s2,s4,80001dea <vma_release_all+0x52>
    if(!v->used) continue;
    80001dc2:	00092783          	lw	a5,0(s2)
    80001dc6:	dbf5                	beqz	a5,80001dba <vma_release_all+0x22>
    uint64 start = v->start;
    80001dc8:	00893583          	ld	a1,8(s2)
    uint64 end   = v->end;
    80001dcc:	01093603          	ld	a2,16(s2)
    if(end <= start) continue;
    80001dd0:	fec5f5e3          	bgeu	a1,a2,80001dba <vma_release_all+0x22>
    int do_free = (v->is_shm ? 0 : 1);
    80001dd4:	02092683          	lw	a3,32(s2)
    uint64 npages = (end - start) / PGSIZE;
    80001dd8:	8e0d                	sub	a2,a2,a1
    uvmunmap(p->pagetable, start, npages, do_free);
    80001dda:	0016b693          	seqz	a3,a3
    80001dde:	8231                	srli	a2,a2,0xc
    80001de0:	050b3503          	ld	a0,80(s6)
    80001de4:	ccaff0ef          	jal	ra,800012ae <uvmunmap>
    80001de8:	bfc9                	j	80001dba <vma_release_all+0x22>
    80001dea:	8926                	mv	s2,s1
  for(int i = 0; i < NVMA; i++){
    80001dec:	4981                	li	s3,0
    80001dee:	190b0b13          	addi	s6,s6,400
    80001df2:	4ac1                	li	s5,16
    80001df4:	a891                	j	80001e48 <vma_release_all+0xb0>
    for(int j = 0; j < i; j++){
    80001df6:	02878793          	addi	a5,a5,40
    80001dfa:	04d78063          	beq	a5,a3,80001e3a <vma_release_all+0xa2>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001dfe:	4398                	lw	a4,0(a5)
    80001e00:	db7d                	beqz	a4,80001df6 <vma_release_all+0x5e>
    80001e02:	5398                	lw	a4,32(a5)
    80001e04:	db6d                	beqz	a4,80001df6 <vma_release_all+0x5e>
    80001e06:	53d8                	lw	a4,36(a5)
    80001e08:	fea717e3          	bne	a4,a0,80001df6 <vma_release_all+0x5e>
    80001e0c:	a80d                	j	80001e3e <vma_release_all+0xa6>
      p->vmas[i].shm_key = -1;
    80001e0e:	577d                	li	a4,-1
    80001e10:	a029                	j	80001e1a <vma_release_all+0x82>
  for(int i = 0; i < NVMA; i++){
    80001e12:	02848493          	addi	s1,s1,40
    80001e16:	05448e63          	beq	s1,s4,80001e72 <vma_release_all+0xda>
    if(p->vmas[i].used){
    80001e1a:	409c                	lw	a5,0(s1)
    80001e1c:	dbfd                	beqz	a5,80001e12 <vma_release_all+0x7a>
      p->vmas[i].used = 0;
    80001e1e:	0004a023          	sw	zero,0(s1)
      p->vmas[i].is_shm = 0;
    80001e22:	0204a023          	sw	zero,32(s1)
      p->vmas[i].shm_key = -1;
    80001e26:	d0d8                	sw	a4,36(s1)
      p->vmas[i].start = p->vmas[i].end = 0;
    80001e28:	0004b823          	sd	zero,16(s1)
    80001e2c:	0004b423          	sd	zero,8(s1)
      p->vmas[i].prot = p->vmas[i].flags = 0;
    80001e30:	0004ae23          	sw	zero,28(s1)
    80001e34:	0004ac23          	sw	zero,24(s1)
    80001e38:	bfe9                	j	80001e12 <vma_release_all+0x7a>
    shm_put(key);
    80001e3a:	0b7040ef          	jal	ra,800066f0 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001e3e:	2985                	addiw	s3,s3,1
    80001e40:	02890913          	addi	s2,s2,40
    80001e44:	fd5985e3          	beq	s3,s5,80001e0e <vma_release_all+0x76>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001e48:	00092783          	lw	a5,0(s2)
    80001e4c:	dbed                	beqz	a5,80001e3e <vma_release_all+0xa6>
    80001e4e:	02092783          	lw	a5,32(s2)
    80001e52:	d7f5                	beqz	a5,80001e3e <vma_release_all+0xa6>
    int key = p->vmas[i].shm_key;
    80001e54:	02492503          	lw	a0,36(s2)
    for(int j = 0; j < i; j++){
    80001e58:	ff3051e3          	blez	s3,80001e3a <vma_release_all+0xa2>
    80001e5c:	fff9879b          	addiw	a5,s3,-1
    80001e60:	1782                	slli	a5,a5,0x20
    80001e62:	9381                	srli	a5,a5,0x20
    80001e64:	00279693          	slli	a3,a5,0x2
    80001e68:	96be                	add	a3,a3,a5
    80001e6a:	068e                	slli	a3,a3,0x3
    80001e6c:	96da                	add	a3,a3,s6
    80001e6e:	87a6                	mv	a5,s1
    80001e70:	b779                	j	80001dfe <vma_release_all+0x66>
}
    80001e72:	70e2                	ld	ra,56(sp)
    80001e74:	7442                	ld	s0,48(sp)
    80001e76:	74a2                	ld	s1,40(sp)
    80001e78:	7902                	ld	s2,32(sp)
    80001e7a:	69e2                	ld	s3,24(sp)
    80001e7c:	6a42                	ld	s4,16(sp)
    80001e7e:	6aa2                	ld	s5,8(sp)
    80001e80:	6b02                	ld	s6,0(sp)
    80001e82:	6121                	addi	sp,sp,64
    80001e84:	8082                	ret

0000000080001e86 <proc_pagetable>:
{
    80001e86:	1101                	addi	sp,sp,-32
    80001e88:	ec06                	sd	ra,24(sp)
    80001e8a:	e822                	sd	s0,16(sp)
    80001e8c:	e426                	sd	s1,8(sp)
    80001e8e:	e04a                	sd	s2,0(sp)
    80001e90:	1000                	addi	s0,sp,32
    80001e92:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e94:	bf4ff0ef          	jal	ra,80001288 <uvmcreate>
    80001e98:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e9a:	cd05                	beqz	a0,80001ed2 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e9c:	4729                	li	a4,10
    80001e9e:	00005697          	auipc	a3,0x5
    80001ea2:	16268693          	addi	a3,a3,354 # 80007000 <_trampoline>
    80001ea6:	6605                	lui	a2,0x1
    80001ea8:	040005b7          	lui	a1,0x4000
    80001eac:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001eae:	05b2                	slli	a1,a1,0xc
    80001eb0:	a32ff0ef          	jal	ra,800010e2 <mappages>
    80001eb4:	02054663          	bltz	a0,80001ee0 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001eb8:	4719                	li	a4,6
    80001eba:	05893683          	ld	a3,88(s2)
    80001ebe:	6605                	lui	a2,0x1
    80001ec0:	020005b7          	lui	a1,0x2000
    80001ec4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ec6:	05b6                	slli	a1,a1,0xd
    80001ec8:	8526                	mv	a0,s1
    80001eca:	a18ff0ef          	jal	ra,800010e2 <mappages>
    80001ece:	00054f63          	bltz	a0,80001eec <proc_pagetable+0x66>
}
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	60e2                	ld	ra,24(sp)
    80001ed6:	6442                	ld	s0,16(sp)
    80001ed8:	64a2                	ld	s1,8(sp)
    80001eda:	6902                	ld	s2,0(sp)
    80001edc:	6105                	addi	sp,sp,32
    80001ede:	8082                	ret
    uvmfree(pagetable, 0);
    80001ee0:	4581                	li	a1,0
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	d84ff0ef          	jal	ra,80001468 <uvmfree>
    return 0;
    80001ee8:	4481                	li	s1,0
    80001eea:	b7e5                	j	80001ed2 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001eec:	4681                	li	a3,0
    80001eee:	4605                	li	a2,1
    80001ef0:	040005b7          	lui	a1,0x4000
    80001ef4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ef6:	05b2                	slli	a1,a1,0xc
    80001ef8:	8526                	mv	a0,s1
    80001efa:	bb4ff0ef          	jal	ra,800012ae <uvmunmap>
    uvmfree(pagetable, 0);
    80001efe:	4581                	li	a1,0
    80001f00:	8526                	mv	a0,s1
    80001f02:	d66ff0ef          	jal	ra,80001468 <uvmfree>
    return 0;
    80001f06:	4481                	li	s1,0
    80001f08:	b7e9                	j	80001ed2 <proc_pagetable+0x4c>

0000000080001f0a <vma_unmap_pagetable>:
{
    80001f0a:	7179                	addi	sp,sp,-48
    80001f0c:	f406                	sd	ra,40(sp)
    80001f0e:	f022                	sd	s0,32(sp)
    80001f10:	ec26                	sd	s1,24(sp)
    80001f12:	e84a                	sd	s2,16(sp)
    80001f14:	e44e                	sd	s3,8(sp)
    80001f16:	1800                	addi	s0,sp,48
    80001f18:	89aa                	mv	s3,a0
    80001f1a:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001f1c:	28058913          	addi	s2,a1,640
    80001f20:	a811                	j	80001f34 <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001f22:	4685                	li	a3,1
    80001f24:	8231                	srli	a2,a2,0xc
    80001f26:	854e                	mv	a0,s3
    80001f28:	b86ff0ef          	jal	ra,800012ae <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001f2c:	02848493          	addi	s1,s1,40
    80001f30:	01248b63          	beq	s1,s2,80001f46 <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001f34:	409c                	lw	a5,0(s1)
    80001f36:	dbfd                	beqz	a5,80001f2c <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001f38:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001f3a:	689c                	ld	a5,16(s1)
    80001f3c:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001f40:	feb786e3          	beq	a5,a1,80001f2c <vma_unmap_pagetable+0x22>
    80001f44:	bff9                	j	80001f22 <vma_unmap_pagetable+0x18>
}
    80001f46:	70a2                	ld	ra,40(sp)
    80001f48:	7402                	ld	s0,32(sp)
    80001f4a:	64e2                	ld	s1,24(sp)
    80001f4c:	6942                	ld	s2,16(sp)
    80001f4e:	69a2                	ld	s3,8(sp)
    80001f50:	6145                	addi	sp,sp,48
    80001f52:	8082                	ret

0000000080001f54 <proc_freepagetable>:
{
    80001f54:	1101                	addi	sp,sp,-32
    80001f56:	ec06                	sd	ra,24(sp)
    80001f58:	e822                	sd	s0,16(sp)
    80001f5a:	e426                	sd	s1,8(sp)
    80001f5c:	e04a                	sd	s2,0(sp)
    80001f5e:	1000                	addi	s0,sp,32
    80001f60:	84aa                	mv	s1,a0
    80001f62:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f64:	4681                	li	a3,0
    80001f66:	4605                	li	a2,1
    80001f68:	040005b7          	lui	a1,0x4000
    80001f6c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f6e:	05b2                	slli	a1,a1,0xc
    80001f70:	b3eff0ef          	jal	ra,800012ae <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f74:	4681                	li	a3,0
    80001f76:	4605                	li	a2,1
    80001f78:	020005b7          	lui	a1,0x2000
    80001f7c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001f7e:	05b6                	slli	a1,a1,0xd
    80001f80:	8526                	mv	a0,s1
    80001f82:	b2cff0ef          	jal	ra,800012ae <uvmunmap>
  uvmfree(pagetable, sz);
    80001f86:	85ca                	mv	a1,s2
    80001f88:	8526                	mv	a0,s1
    80001f8a:	cdeff0ef          	jal	ra,80001468 <uvmfree>
}
    80001f8e:	60e2                	ld	ra,24(sp)
    80001f90:	6442                	ld	s0,16(sp)
    80001f92:	64a2                	ld	s1,8(sp)
    80001f94:	6902                	ld	s2,0(sp)
    80001f96:	6105                	addi	sp,sp,32
    80001f98:	8082                	ret

0000000080001f9a <freeproc>:
{
    80001f9a:	1101                	addi	sp,sp,-32
    80001f9c:	ec06                	sd	ra,24(sp)
    80001f9e:	e822                	sd	s0,16(sp)
    80001fa0:	e426                	sd	s1,8(sp)
    80001fa2:	e04a                	sd	s2,0(sp)
    80001fa4:	1000                	addi	s0,sp,32
    80001fa6:	84aa                	mv	s1,a0
  vma_release_all(p);
    80001fa8:	df1ff0ef          	jal	ra,80001d98 <vma_release_all>
  if(p->trapframe)
    80001fac:	6ca8                	ld	a0,88(s1)
    80001fae:	c119                	beqz	a0,80001fb4 <freeproc+0x1a>
    kfree((void*)p->trapframe);
    80001fb0:	acbfe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001fb4:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001fb8:	68a8                	ld	a0,80(s1)
    80001fba:	c105                	beqz	a0,80001fda <freeproc+0x40>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001fbc:	16848913          	addi	s2,s1,360
    80001fc0:	85ca                	mv	a1,s2
    80001fc2:	f49ff0ef          	jal	ra,80001f0a <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001fc6:	28000613          	li	a2,640
    80001fca:	4581                	li	a1,0
    80001fcc:	854a                	mv	a0,s2
    80001fce:	db5fe0ef          	jal	ra,80000d82 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001fd2:	64ac                	ld	a1,72(s1)
    80001fd4:	68a8                	ld	a0,80(s1)
    80001fd6:	f7fff0ef          	jal	ra,80001f54 <proc_freepagetable>
  delete_shm_from_proc(p);
    80001fda:	8526                	mv	a0,s1
    80001fdc:	d3fff0ef          	jal	ra,80001d1a <delete_shm_from_proc>
  p->pagetable = 0;
    80001fe0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001fe4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001fe8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001fec:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ff0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ff4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ff8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ffc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002000:	0004ac23          	sw	zero,24(s1)
}
    80002004:	60e2                	ld	ra,24(sp)
    80002006:	6442                	ld	s0,16(sp)
    80002008:	64a2                	ld	s1,8(sp)
    8000200a:	6902                	ld	s2,0(sp)
    8000200c:	6105                	addi	sp,sp,32
    8000200e:	8082                	ret

0000000080002010 <allocproc>:
{
    80002010:	1101                	addi	sp,sp,-32
    80002012:	ec06                	sd	ra,24(sp)
    80002014:	e822                	sd	s0,16(sp)
    80002016:	e426                	sd	s1,8(sp)
    80002018:	e04a                	sd	s2,0(sp)
    8000201a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000201c:	0022f497          	auipc	s1,0x22f
    80002020:	e3448493          	addi	s1,s1,-460 # 80230e50 <proc>
    80002024:	0023f917          	auipc	s2,0x23f
    80002028:	82c90913          	addi	s2,s2,-2004 # 80240850 <tickslock>
    acquire(&p->lock);
    8000202c:	8526                	mv	a0,s1
    8000202e:	c81fe0ef          	jal	ra,80000cae <acquire>
    if(p->state == UNUSED) {
    80002032:	4c9c                	lw	a5,24(s1)
    80002034:	cb91                	beqz	a5,80002048 <allocproc+0x38>
      release(&p->lock);
    80002036:	8526                	mv	a0,s1
    80002038:	d0ffe0ef          	jal	ra,80000d46 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000203c:	3e848493          	addi	s1,s1,1000
    80002040:	ff2496e3          	bne	s1,s2,8000202c <allocproc+0x1c>
  return 0;
    80002044:	4481                	li	s1,0
    80002046:	a089                	j	80002088 <allocproc+0x78>
  p->pid = allocpid();
    80002048:	c19ff0ef          	jal	ra,80001c60 <allocpid>
    8000204c:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000204e:	4785                	li	a5,1
    80002050:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002052:	b59fe0ef          	jal	ra,80000baa <kalloc>
    80002056:	892a                	mv	s2,a0
    80002058:	eca8                	sd	a0,88(s1)
    8000205a:	cd15                	beqz	a0,80002096 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    8000205c:	8526                	mv	a0,s1
    8000205e:	e29ff0ef          	jal	ra,80001e86 <proc_pagetable>
    80002062:	892a                	mv	s2,a0
    80002064:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002066:	c121                	beqz	a0,800020a6 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80002068:	07000613          	li	a2,112
    8000206c:	4581                	li	a1,0
    8000206e:	06048513          	addi	a0,s1,96
    80002072:	d11fe0ef          	jal	ra,80000d82 <memset>
  p->context.ra = (uint64)forkret;
    80002076:	00000797          	auipc	a5,0x0
    8000207a:	b5278793          	addi	a5,a5,-1198 # 80001bc8 <forkret>
    8000207e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002080:	60bc                	ld	a5,64(s1)
    80002082:	6705                	lui	a4,0x1
    80002084:	97ba                	add	a5,a5,a4
    80002086:	f4bc                	sd	a5,104(s1)
}
    80002088:	8526                	mv	a0,s1
    8000208a:	60e2                	ld	ra,24(sp)
    8000208c:	6442                	ld	s0,16(sp)
    8000208e:	64a2                	ld	s1,8(sp)
    80002090:	6902                	ld	s2,0(sp)
    80002092:	6105                	addi	sp,sp,32
    80002094:	8082                	ret
    freeproc(p);
    80002096:	8526                	mv	a0,s1
    80002098:	f03ff0ef          	jal	ra,80001f9a <freeproc>
    release(&p->lock);
    8000209c:	8526                	mv	a0,s1
    8000209e:	ca9fe0ef          	jal	ra,80000d46 <release>
    return 0;
    800020a2:	84ca                	mv	s1,s2
    800020a4:	b7d5                	j	80002088 <allocproc+0x78>
    freeproc(p);
    800020a6:	8526                	mv	a0,s1
    800020a8:	ef3ff0ef          	jal	ra,80001f9a <freeproc>
    release(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	c99fe0ef          	jal	ra,80000d46 <release>
    return 0;
    800020b2:	84ca                	mv	s1,s2
    800020b4:	bfd1                	j	80002088 <allocproc+0x78>

00000000800020b6 <userinit>:
{
    800020b6:	1101                	addi	sp,sp,-32
    800020b8:	ec06                	sd	ra,24(sp)
    800020ba:	e822                	sd	s0,16(sp)
    800020bc:	e426                	sd	s1,8(sp)
    800020be:	1000                	addi	s0,sp,32
  p = allocproc();
    800020c0:	f51ff0ef          	jal	ra,80002010 <allocproc>
    800020c4:	84aa                	mv	s1,a0
  initproc = p;
    800020c6:	00007797          	auipc	a5,0x7
    800020ca:	80a7bd23          	sd	a0,-2022(a5) # 800088e0 <initproc>
  p->cwd = namei("/");
    800020ce:	00006517          	auipc	a0,0x6
    800020d2:	0e250513          	addi	a0,a0,226 # 800081b0 <digits+0x178>
    800020d6:	5b0020ef          	jal	ra,80004686 <namei>
    800020da:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800020de:	478d                	li	a5,3
    800020e0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800020e2:	8526                	mv	a0,s1
    800020e4:	c63fe0ef          	jal	ra,80000d46 <release>
}
    800020e8:	60e2                	ld	ra,24(sp)
    800020ea:	6442                	ld	s0,16(sp)
    800020ec:	64a2                	ld	s1,8(sp)
    800020ee:	6105                	addi	sp,sp,32
    800020f0:	8082                	ret

00000000800020f2 <growproc>:
{
    800020f2:	1101                	addi	sp,sp,-32
    800020f4:	ec06                	sd	ra,24(sp)
    800020f6:	e822                	sd	s0,16(sp)
    800020f8:	e426                	sd	s1,8(sp)
    800020fa:	e04a                	sd	s2,0(sp)
    800020fc:	1000                	addi	s0,sp,32
    800020fe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002100:	a99ff0ef          	jal	ra,80001b98 <myproc>
    80002104:	892a                	mv	s2,a0
  sz = p->sz;
    80002106:	652c                	ld	a1,72(a0)
  if(n > 0){
    80002108:	02905963          	blez	s1,8000213a <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    8000210c:	00b48633          	add	a2,s1,a1
    80002110:	020007b7          	lui	a5,0x2000
    80002114:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002116:	07b6                	slli	a5,a5,0xd
    80002118:	02c7ea63          	bltu	a5,a2,8000214c <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000211c:	4691                	li	a3,4
    8000211e:	6928                	ld	a0,80(a0)
    80002120:	a4eff0ef          	jal	ra,8000136e <uvmalloc>
    80002124:	85aa                	mv	a1,a0
    80002126:	c50d                	beqz	a0,80002150 <growproc+0x5e>
  p->sz = sz;
    80002128:	04b93423          	sd	a1,72(s2)
  return 0;
    8000212c:	4501                	li	a0,0
}
    8000212e:	60e2                	ld	ra,24(sp)
    80002130:	6442                	ld	s0,16(sp)
    80002132:	64a2                	ld	s1,8(sp)
    80002134:	6902                	ld	s2,0(sp)
    80002136:	6105                	addi	sp,sp,32
    80002138:	8082                	ret
  } else if(n < 0){
    8000213a:	fe04d7e3          	bgez	s1,80002128 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000213e:	00b48633          	add	a2,s1,a1
    80002142:	6928                	ld	a0,80(a0)
    80002144:	9e6ff0ef          	jal	ra,8000132a <uvmdealloc>
    80002148:	85aa                	mv	a1,a0
    8000214a:	bff9                	j	80002128 <growproc+0x36>
      return -1;
    8000214c:	557d                	li	a0,-1
    8000214e:	b7c5                	j	8000212e <growproc+0x3c>
      return -1;
    80002150:	557d                	li	a0,-1
    80002152:	bff1                	j	8000212e <growproc+0x3c>

0000000080002154 <kfork>:
{
    80002154:	715d                	addi	sp,sp,-80
    80002156:	e486                	sd	ra,72(sp)
    80002158:	e0a2                	sd	s0,64(sp)
    8000215a:	fc26                	sd	s1,56(sp)
    8000215c:	f84a                	sd	s2,48(sp)
    8000215e:	f44e                	sd	s3,40(sp)
    80002160:	f052                	sd	s4,32(sp)
    80002162:	ec56                	sd	s5,24(sp)
    80002164:	e85a                	sd	s6,16(sp)
    80002166:	e45e                	sd	s7,8(sp)
    80002168:	e062                	sd	s8,0(sp)
    8000216a:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    8000216c:	a2dff0ef          	jal	ra,80001b98 <myproc>
    80002170:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002172:	e9fff0ef          	jal	ra,80002010 <allocproc>
    80002176:	12050963          	beqz	a0,800022a8 <kfork+0x154>
    8000217a:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000217c:	048ab603          	ld	a2,72(s5)
    80002180:	692c                	ld	a1,80(a0)
    80002182:	050ab503          	ld	a0,80(s5)
    80002186:	b14ff0ef          	jal	ra,8000149a <uvmcopy>
    8000218a:	04054863          	bltz	a0,800021da <kfork+0x86>
  np->sz = p->sz;
    8000218e:	048ab783          	ld	a5,72(s5)
    80002192:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002196:	058ab683          	ld	a3,88(s5)
    8000219a:	87b6                	mv	a5,a3
    8000219c:	0589b703          	ld	a4,88(s3)
    800021a0:	12068693          	addi	a3,a3,288
    800021a4:	0007b803          	ld	a6,0(a5)
    800021a8:	6788                	ld	a0,8(a5)
    800021aa:	6b8c                	ld	a1,16(a5)
    800021ac:	6f90                	ld	a2,24(a5)
    800021ae:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800021b2:	e708                	sd	a0,8(a4)
    800021b4:	eb0c                	sd	a1,16(a4)
    800021b6:	ef10                	sd	a2,24(a4)
    800021b8:	02078793          	addi	a5,a5,32
    800021bc:	02070713          	addi	a4,a4,32
    800021c0:	fed792e3          	bne	a5,a3,800021a4 <kfork+0x50>
  np->trapframe->a0 = 0;
    800021c4:	0589b783          	ld	a5,88(s3)
    800021c8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800021cc:	0d0a8493          	addi	s1,s5,208
    800021d0:	0d098913          	addi	s2,s3,208
    800021d4:	150a8a13          	addi	s4,s5,336
    800021d8:	a829                	j	800021f2 <kfork+0x9e>
    freeproc(np);
    800021da:	854e                	mv	a0,s3
    800021dc:	dbfff0ef          	jal	ra,80001f9a <freeproc>
    release(&np->lock);
    800021e0:	854e                	mv	a0,s3
    800021e2:	b65fe0ef          	jal	ra,80000d46 <release>
    return -1;
    800021e6:	5c7d                	li	s8,-1
    800021e8:	a05d                	j	8000228e <kfork+0x13a>
  for(i = 0; i < NOFILE; i++)
    800021ea:	04a1                	addi	s1,s1,8
    800021ec:	0921                	addi	s2,s2,8
    800021ee:	01448963          	beq	s1,s4,80002200 <kfork+0xac>
    if(p->ofile[i])
    800021f2:	6088                	ld	a0,0(s1)
    800021f4:	d97d                	beqz	a0,800021ea <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    800021f6:	249020ef          	jal	ra,80004c3e <filedup>
    800021fa:	00a93023          	sd	a0,0(s2)
    800021fe:	b7f5                	j	800021ea <kfork+0x96>
  np->cwd = idup(p->cwd);
    80002200:	150ab503          	ld	a0,336(s5)
    80002204:	459010ef          	jal	ra,80003e5c <idup>
    80002208:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000220c:	4641                	li	a2,16
    8000220e:	158a8593          	addi	a1,s5,344
    80002212:	15898513          	addi	a0,s3,344
    80002216:	cb3fe0ef          	jal	ra,80000ec8 <safestrcpy>
  pid = np->pid;
    8000221a:	0309ac03          	lw	s8,48(s3)
  release(&np->lock);
    8000221e:	854e                	mv	a0,s3
    80002220:	b27fe0ef          	jal	ra,80000d46 <release>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    80002224:	16898b13          	addi	s6,s3,360
    80002228:	28000613          	li	a2,640
    8000222c:	168a8593          	addi	a1,s5,360
    80002230:	855a                	mv	a0,s6
    80002232:	badfe0ef          	jal	ra,80000dde <memmove>
    80002236:	84da                	mv	s1,s6
  for(int i = 0; i < NVMA; i++){
    80002238:	4901                	li	s2,0
    8000223a:	19098b93          	addi	s7,s3,400
    8000223e:	4a41                	li	s4,16
    80002240:	a069                	j	800022ca <kfork+0x176>
    for(int j = 0; j < i; j++){
    80002242:	02878793          	addi	a5,a5,40
    80002246:	06d78363          	beq	a5,a3,800022ac <kfork+0x158>
      if(np->vmas[j].used && np->vmas[j].is_shm && np->vmas[j].shm_key == key){
    8000224a:	4398                	lw	a4,0(a5)
    8000224c:	db7d                	beqz	a4,80002242 <kfork+0xee>
    8000224e:	5398                	lw	a4,32(a5)
    80002250:	db6d                	beqz	a4,80002242 <kfork+0xee>
    80002252:	53d8                	lw	a4,36(a5)
    80002254:	fea717e3          	bne	a4,a0,80002242 <kfork+0xee>
    80002258:	a0a5                	j	800022c0 <kfork+0x16c>
        freeproc(np);
    8000225a:	854e                	mv	a0,s3
    8000225c:	d3fff0ef          	jal	ra,80001f9a <freeproc>
        return -1;
    80002260:	5c7d                	li	s8,-1
    80002262:	a035                	j	8000228e <kfork+0x13a>
  acquire(&wait_lock);
    80002264:	0022e497          	auipc	s1,0x22e
    80002268:	7d448493          	addi	s1,s1,2004 # 80230a38 <wait_lock>
    8000226c:	8526                	mv	a0,s1
    8000226e:	a41fe0ef          	jal	ra,80000cae <acquire>
  np->parent = p;
    80002272:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002276:	8526                	mv	a0,s1
    80002278:	acffe0ef          	jal	ra,80000d46 <release>
  acquire(&np->lock);
    8000227c:	854e                	mv	a0,s3
    8000227e:	a31fe0ef          	jal	ra,80000cae <acquire>
  np->state = RUNNABLE;
    80002282:	478d                	li	a5,3
    80002284:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002288:	854e                	mv	a0,s3
    8000228a:	abdfe0ef          	jal	ra,80000d46 <release>
}
    8000228e:	8562                	mv	a0,s8
    80002290:	60a6                	ld	ra,72(sp)
    80002292:	6406                	ld	s0,64(sp)
    80002294:	74e2                	ld	s1,56(sp)
    80002296:	7942                	ld	s2,48(sp)
    80002298:	79a2                	ld	s3,40(sp)
    8000229a:	7a02                	ld	s4,32(sp)
    8000229c:	6ae2                	ld	s5,24(sp)
    8000229e:	6b42                	ld	s6,16(sp)
    800022a0:	6ba2                	ld	s7,8(sp)
    800022a2:	6c02                	ld	s8,0(sp)
    800022a4:	6161                	addi	sp,sp,80
    800022a6:	8082                	ret
    return -1;
    800022a8:	5c7d                	li	s8,-1
    800022aa:	b7d5                	j	8000228e <kfork+0x13a>
    int npages = (np->vmas[i].end - np->vmas[i].start) / PGSIZE;
    800022ac:	699c                	ld	a5,16(a1)
    800022ae:	6598                	ld	a4,8(a1)
    800022b0:	40e785b3          	sub	a1,a5,a4
    800022b4:	81b1                	srli	a1,a1,0xc
    if(shm_get(key, npages) < 0){
    800022b6:	2581                	sext.w	a1,a1
    800022b8:	2f4040ef          	jal	ra,800065ac <shm_get>
    800022bc:	f8054fe3          	bltz	a0,8000225a <kfork+0x106>
  for(int i = 0; i < NVMA; i++){
    800022c0:	2905                	addiw	s2,s2,1
    800022c2:	02848493          	addi	s1,s1,40
    800022c6:	f9490fe3          	beq	s2,s4,80002264 <kfork+0x110>
    if(!np->vmas[i].used || !np->vmas[i].is_shm) continue;
    800022ca:	85a6                	mv	a1,s1
    800022cc:	409c                	lw	a5,0(s1)
    800022ce:	dbed                	beqz	a5,800022c0 <kfork+0x16c>
    800022d0:	509c                	lw	a5,32(s1)
    800022d2:	d7fd                	beqz	a5,800022c0 <kfork+0x16c>
    int key = np->vmas[i].shm_key;
    800022d4:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    800022d6:	fd205be3          	blez	s2,800022ac <kfork+0x158>
    800022da:	fff9079b          	addiw	a5,s2,-1
    800022de:	1782                	slli	a5,a5,0x20
    800022e0:	9381                	srli	a5,a5,0x20
    800022e2:	00279693          	slli	a3,a5,0x2
    800022e6:	96be                	add	a3,a3,a5
    800022e8:	068e                	slli	a3,a3,0x3
    800022ea:	96de                	add	a3,a3,s7
    800022ec:	87da                	mv	a5,s6
    800022ee:	bfb1                	j	8000224a <kfork+0xf6>

00000000800022f0 <scheduler>:
{
    800022f0:	715d                	addi	sp,sp,-80
    800022f2:	e486                	sd	ra,72(sp)
    800022f4:	e0a2                	sd	s0,64(sp)
    800022f6:	fc26                	sd	s1,56(sp)
    800022f8:	f84a                	sd	s2,48(sp)
    800022fa:	f44e                	sd	s3,40(sp)
    800022fc:	f052                	sd	s4,32(sp)
    800022fe:	ec56                	sd	s5,24(sp)
    80002300:	e85a                	sd	s6,16(sp)
    80002302:	e45e                	sd	s7,8(sp)
    80002304:	e062                	sd	s8,0(sp)
    80002306:	0880                	addi	s0,sp,80
    80002308:	8792                	mv	a5,tp
  int id = r_tp();
    8000230a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000230c:	00779b13          	slli	s6,a5,0x7
    80002310:	0022e717          	auipc	a4,0x22e
    80002314:	71070713          	addi	a4,a4,1808 # 80230a20 <pid_lock>
    80002318:	975a                	add	a4,a4,s6
    8000231a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000231e:	0022e717          	auipc	a4,0x22e
    80002322:	73a70713          	addi	a4,a4,1850 # 80230a58 <cpus+0x8>
    80002326:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002328:	4c11                	li	s8,4
        c->proc = p;
    8000232a:	079e                	slli	a5,a5,0x7
    8000232c:	0022ea17          	auipc	s4,0x22e
    80002330:	6f4a0a13          	addi	s4,s4,1780 # 80230a20 <pid_lock>
    80002334:	9a3e                	add	s4,s4,a5
        found = 1;
    80002336:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002338:	0023e997          	auipc	s3,0x23e
    8000233c:	51898993          	addi	s3,s3,1304 # 80240850 <tickslock>
    80002340:	a83d                	j	8000237e <scheduler+0x8e>
      release(&p->lock);
    80002342:	8526                	mv	a0,s1
    80002344:	a03fe0ef          	jal	ra,80000d46 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002348:	3e848493          	addi	s1,s1,1000
    8000234c:	03348563          	beq	s1,s3,80002376 <scheduler+0x86>
      acquire(&p->lock);
    80002350:	8526                	mv	a0,s1
    80002352:	95dfe0ef          	jal	ra,80000cae <acquire>
      if(p->state == RUNNABLE) {
    80002356:	4c9c                	lw	a5,24(s1)
    80002358:	ff2795e3          	bne	a5,s2,80002342 <scheduler+0x52>
        p->state = RUNNING;
    8000235c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002360:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002364:	06048593          	addi	a1,s1,96
    80002368:	855a                	mv	a0,s6
    8000236a:	5b2000ef          	jal	ra,8000291c <swtch>
        c->proc = 0;
    8000236e:	020a3823          	sd	zero,48(s4)
        found = 1;
    80002372:	8ade                	mv	s5,s7
    80002374:	b7f9                	j	80002342 <scheduler+0x52>
    if(found == 0) {
    80002376:	000a9463          	bnez	s5,8000237e <scheduler+0x8e>
      asm volatile("wfi");
    8000237a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000237e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002382:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002386:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000238a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000238e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002390:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002394:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002396:	0022f497          	auipc	s1,0x22f
    8000239a:	aba48493          	addi	s1,s1,-1350 # 80230e50 <proc>
      if(p->state == RUNNABLE) {
    8000239e:	490d                	li	s2,3
    800023a0:	bf45                	j	80002350 <scheduler+0x60>

00000000800023a2 <sched>:
{
    800023a2:	7179                	addi	sp,sp,-48
    800023a4:	f406                	sd	ra,40(sp)
    800023a6:	f022                	sd	s0,32(sp)
    800023a8:	ec26                	sd	s1,24(sp)
    800023aa:	e84a                	sd	s2,16(sp)
    800023ac:	e44e                	sd	s3,8(sp)
    800023ae:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023b0:	fe8ff0ef          	jal	ra,80001b98 <myproc>
    800023b4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023b6:	88ffe0ef          	jal	ra,80000c44 <holding>
    800023ba:	c92d                	beqz	a0,8000242c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023bc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023be:	2781                	sext.w	a5,a5
    800023c0:	079e                	slli	a5,a5,0x7
    800023c2:	0022e717          	auipc	a4,0x22e
    800023c6:	65e70713          	addi	a4,a4,1630 # 80230a20 <pid_lock>
    800023ca:	97ba                	add	a5,a5,a4
    800023cc:	0a87a703          	lw	a4,168(a5)
    800023d0:	4785                	li	a5,1
    800023d2:	06f71363          	bne	a4,a5,80002438 <sched+0x96>
  if(p->state == RUNNING)
    800023d6:	4c98                	lw	a4,24(s1)
    800023d8:	4791                	li	a5,4
    800023da:	06f70563          	beq	a4,a5,80002444 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023de:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023e2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800023e4:	e7b5                	bnez	a5,80002450 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023e6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023e8:	0022e917          	auipc	s2,0x22e
    800023ec:	63890913          	addi	s2,s2,1592 # 80230a20 <pid_lock>
    800023f0:	2781                	sext.w	a5,a5
    800023f2:	079e                	slli	a5,a5,0x7
    800023f4:	97ca                	add	a5,a5,s2
    800023f6:	0ac7a983          	lw	s3,172(a5)
    800023fa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023fc:	2781                	sext.w	a5,a5
    800023fe:	079e                	slli	a5,a5,0x7
    80002400:	0022e597          	auipc	a1,0x22e
    80002404:	65858593          	addi	a1,a1,1624 # 80230a58 <cpus+0x8>
    80002408:	95be                	add	a1,a1,a5
    8000240a:	06048513          	addi	a0,s1,96
    8000240e:	50e000ef          	jal	ra,8000291c <swtch>
    80002412:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002414:	2781                	sext.w	a5,a5
    80002416:	079e                	slli	a5,a5,0x7
    80002418:	993e                	add	s2,s2,a5
    8000241a:	0b392623          	sw	s3,172(s2)
}
    8000241e:	70a2                	ld	ra,40(sp)
    80002420:	7402                	ld	s0,32(sp)
    80002422:	64e2                	ld	s1,24(sp)
    80002424:	6942                	ld	s2,16(sp)
    80002426:	69a2                	ld	s3,8(sp)
    80002428:	6145                	addi	sp,sp,48
    8000242a:	8082                	ret
    panic("sched p->lock");
    8000242c:	00006517          	auipc	a0,0x6
    80002430:	d8c50513          	addi	a0,a0,-628 # 800081b8 <digits+0x180>
    80002434:	b54fe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    80002438:	00006517          	auipc	a0,0x6
    8000243c:	d9050513          	addi	a0,a0,-624 # 800081c8 <digits+0x190>
    80002440:	b48fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    80002444:	00006517          	auipc	a0,0x6
    80002448:	d9450513          	addi	a0,a0,-620 # 800081d8 <digits+0x1a0>
    8000244c:	b3cfe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    80002450:	00006517          	auipc	a0,0x6
    80002454:	d9850513          	addi	a0,a0,-616 # 800081e8 <digits+0x1b0>
    80002458:	b30fe0ef          	jal	ra,80000788 <panic>

000000008000245c <yield>:
{
    8000245c:	1101                	addi	sp,sp,-32
    8000245e:	ec06                	sd	ra,24(sp)
    80002460:	e822                	sd	s0,16(sp)
    80002462:	e426                	sd	s1,8(sp)
    80002464:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002466:	f32ff0ef          	jal	ra,80001b98 <myproc>
    8000246a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000246c:	843fe0ef          	jal	ra,80000cae <acquire>
  p->state = RUNNABLE;
    80002470:	478d                	li	a5,3
    80002472:	cc9c                	sw	a5,24(s1)
  sched();
    80002474:	f2fff0ef          	jal	ra,800023a2 <sched>
  release(&p->lock);
    80002478:	8526                	mv	a0,s1
    8000247a:	8cdfe0ef          	jal	ra,80000d46 <release>
}
    8000247e:	60e2                	ld	ra,24(sp)
    80002480:	6442                	ld	s0,16(sp)
    80002482:	64a2                	ld	s1,8(sp)
    80002484:	6105                	addi	sp,sp,32
    80002486:	8082                	ret

0000000080002488 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002488:	7179                	addi	sp,sp,-48
    8000248a:	f406                	sd	ra,40(sp)
    8000248c:	f022                	sd	s0,32(sp)
    8000248e:	ec26                	sd	s1,24(sp)
    80002490:	e84a                	sd	s2,16(sp)
    80002492:	e44e                	sd	s3,8(sp)
    80002494:	1800                	addi	s0,sp,48
    80002496:	89aa                	mv	s3,a0
    80002498:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000249a:	efeff0ef          	jal	ra,80001b98 <myproc>
    8000249e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800024a0:	80ffe0ef          	jal	ra,80000cae <acquire>
  release(lk);
    800024a4:	854a                	mv	a0,s2
    800024a6:	8a1fe0ef          	jal	ra,80000d46 <release>

  // Go to sleep.
  p->chan = chan;
    800024aa:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024ae:	4789                	li	a5,2
    800024b0:	cc9c                	sw	a5,24(s1)

  sched();
    800024b2:	ef1ff0ef          	jal	ra,800023a2 <sched>

  // Tidy up.
  p->chan = 0;
    800024b6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024ba:	8526                	mv	a0,s1
    800024bc:	88bfe0ef          	jal	ra,80000d46 <release>
  acquire(lk);
    800024c0:	854a                	mv	a0,s2
    800024c2:	fecfe0ef          	jal	ra,80000cae <acquire>
}
    800024c6:	70a2                	ld	ra,40(sp)
    800024c8:	7402                	ld	s0,32(sp)
    800024ca:	64e2                	ld	s1,24(sp)
    800024cc:	6942                	ld	s2,16(sp)
    800024ce:	69a2                	ld	s3,8(sp)
    800024d0:	6145                	addi	sp,sp,48
    800024d2:	8082                	ret

00000000800024d4 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800024d4:	7139                	addi	sp,sp,-64
    800024d6:	fc06                	sd	ra,56(sp)
    800024d8:	f822                	sd	s0,48(sp)
    800024da:	f426                	sd	s1,40(sp)
    800024dc:	f04a                	sd	s2,32(sp)
    800024de:	ec4e                	sd	s3,24(sp)
    800024e0:	e852                	sd	s4,16(sp)
    800024e2:	e456                	sd	s5,8(sp)
    800024e4:	0080                	addi	s0,sp,64
    800024e6:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800024e8:	0022f497          	auipc	s1,0x22f
    800024ec:	96848493          	addi	s1,s1,-1688 # 80230e50 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800024f0:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024f2:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800024f4:	0023e917          	auipc	s2,0x23e
    800024f8:	35c90913          	addi	s2,s2,860 # 80240850 <tickslock>
    800024fc:	a801                	j	8000250c <wakeup+0x38>
      }
      release(&p->lock);
    800024fe:	8526                	mv	a0,s1
    80002500:	847fe0ef          	jal	ra,80000d46 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002504:	3e848493          	addi	s1,s1,1000
    80002508:	03248263          	beq	s1,s2,8000252c <wakeup+0x58>
    if(p != myproc()){
    8000250c:	e8cff0ef          	jal	ra,80001b98 <myproc>
    80002510:	fea48ae3          	beq	s1,a0,80002504 <wakeup+0x30>
      acquire(&p->lock);
    80002514:	8526                	mv	a0,s1
    80002516:	f98fe0ef          	jal	ra,80000cae <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000251a:	4c9c                	lw	a5,24(s1)
    8000251c:	ff3791e3          	bne	a5,s3,800024fe <wakeup+0x2a>
    80002520:	709c                	ld	a5,32(s1)
    80002522:	fd479ee3          	bne	a5,s4,800024fe <wakeup+0x2a>
        p->state = RUNNABLE;
    80002526:	0154ac23          	sw	s5,24(s1)
    8000252a:	bfd1                	j	800024fe <wakeup+0x2a>
    }
  }
}
    8000252c:	70e2                	ld	ra,56(sp)
    8000252e:	7442                	ld	s0,48(sp)
    80002530:	74a2                	ld	s1,40(sp)
    80002532:	7902                	ld	s2,32(sp)
    80002534:	69e2                	ld	s3,24(sp)
    80002536:	6a42                	ld	s4,16(sp)
    80002538:	6aa2                	ld	s5,8(sp)
    8000253a:	6121                	addi	sp,sp,64
    8000253c:	8082                	ret

000000008000253e <reparent>:
{
    8000253e:	7179                	addi	sp,sp,-48
    80002540:	f406                	sd	ra,40(sp)
    80002542:	f022                	sd	s0,32(sp)
    80002544:	ec26                	sd	s1,24(sp)
    80002546:	e84a                	sd	s2,16(sp)
    80002548:	e44e                	sd	s3,8(sp)
    8000254a:	e052                	sd	s4,0(sp)
    8000254c:	1800                	addi	s0,sp,48
    8000254e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002550:	0022f497          	auipc	s1,0x22f
    80002554:	90048493          	addi	s1,s1,-1792 # 80230e50 <proc>
      pp->parent = initproc;
    80002558:	00006a17          	auipc	s4,0x6
    8000255c:	388a0a13          	addi	s4,s4,904 # 800088e0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002560:	0023e997          	auipc	s3,0x23e
    80002564:	2f098993          	addi	s3,s3,752 # 80240850 <tickslock>
    80002568:	a029                	j	80002572 <reparent+0x34>
    8000256a:	3e848493          	addi	s1,s1,1000
    8000256e:	01348b63          	beq	s1,s3,80002584 <reparent+0x46>
    if(pp->parent == p){
    80002572:	7c9c                	ld	a5,56(s1)
    80002574:	ff279be3          	bne	a5,s2,8000256a <reparent+0x2c>
      pp->parent = initproc;
    80002578:	000a3503          	ld	a0,0(s4)
    8000257c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000257e:	f57ff0ef          	jal	ra,800024d4 <wakeup>
    80002582:	b7e5                	j	8000256a <reparent+0x2c>
}
    80002584:	70a2                	ld	ra,40(sp)
    80002586:	7402                	ld	s0,32(sp)
    80002588:	64e2                	ld	s1,24(sp)
    8000258a:	6942                	ld	s2,16(sp)
    8000258c:	69a2                	ld	s3,8(sp)
    8000258e:	6a02                	ld	s4,0(sp)
    80002590:	6145                	addi	sp,sp,48
    80002592:	8082                	ret

0000000080002594 <kexit>:
{
    80002594:	7179                	addi	sp,sp,-48
    80002596:	f406                	sd	ra,40(sp)
    80002598:	f022                	sd	s0,32(sp)
    8000259a:	ec26                	sd	s1,24(sp)
    8000259c:	e84a                	sd	s2,16(sp)
    8000259e:	e44e                	sd	s3,8(sp)
    800025a0:	e052                	sd	s4,0(sp)
    800025a2:	1800                	addi	s0,sp,48
    800025a4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025a6:	df2ff0ef          	jal	ra,80001b98 <myproc>
    800025aa:	89aa                	mv	s3,a0
  if(p == initproc)
    800025ac:	00006797          	auipc	a5,0x6
    800025b0:	3347b783          	ld	a5,820(a5) # 800088e0 <initproc>
    800025b4:	0d050493          	addi	s1,a0,208
    800025b8:	15050913          	addi	s2,a0,336
    800025bc:	00a79f63          	bne	a5,a0,800025da <kexit+0x46>
    panic("init exiting");
    800025c0:	00006517          	auipc	a0,0x6
    800025c4:	c4050513          	addi	a0,a0,-960 # 80008200 <digits+0x1c8>
    800025c8:	9c0fe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    800025cc:	6b8020ef          	jal	ra,80004c84 <fileclose>
      p->ofile[fd] = 0;
    800025d0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800025d4:	04a1                	addi	s1,s1,8
    800025d6:	01248563          	beq	s1,s2,800025e0 <kexit+0x4c>
    if(p->ofile[fd]){
    800025da:	6088                	ld	a0,0(s1)
    800025dc:	f965                	bnez	a0,800025cc <kexit+0x38>
    800025de:	bfdd                	j	800025d4 <kexit+0x40>
  begin_op();
    800025e0:	29a020ef          	jal	ra,8000487a <begin_op>
  iput(p->cwd);
    800025e4:	1509b503          	ld	a0,336(s3)
    800025e8:	229010ef          	jal	ra,80004010 <iput>
  end_op();
    800025ec:	2fc020ef          	jal	ra,800048e8 <end_op>
  p->cwd = 0;
    800025f0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025f4:	0022e497          	auipc	s1,0x22e
    800025f8:	44448493          	addi	s1,s1,1092 # 80230a38 <wait_lock>
    800025fc:	8526                	mv	a0,s1
    800025fe:	eb0fe0ef          	jal	ra,80000cae <acquire>
  reparent(p);
    80002602:	854e                	mv	a0,s3
    80002604:	f3bff0ef          	jal	ra,8000253e <reparent>
  wakeup(p->parent);
    80002608:	0389b503          	ld	a0,56(s3)
    8000260c:	ec9ff0ef          	jal	ra,800024d4 <wakeup>
  acquire(&p->lock);
    80002610:	854e                	mv	a0,s3
    80002612:	e9cfe0ef          	jal	ra,80000cae <acquire>
  p->xstate = status;
    80002616:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000261a:	4795                	li	a5,5
    8000261c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002620:	8526                	mv	a0,s1
    80002622:	f24fe0ef          	jal	ra,80000d46 <release>
  sched();
    80002626:	d7dff0ef          	jal	ra,800023a2 <sched>
  panic("zombie exit");
    8000262a:	00006517          	auipc	a0,0x6
    8000262e:	be650513          	addi	a0,a0,-1050 # 80008210 <digits+0x1d8>
    80002632:	956fe0ef          	jal	ra,80000788 <panic>

0000000080002636 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002636:	7179                	addi	sp,sp,-48
    80002638:	f406                	sd	ra,40(sp)
    8000263a:	f022                	sd	s0,32(sp)
    8000263c:	ec26                	sd	s1,24(sp)
    8000263e:	e84a                	sd	s2,16(sp)
    80002640:	e44e                	sd	s3,8(sp)
    80002642:	1800                	addi	s0,sp,48
    80002644:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002646:	0022f497          	auipc	s1,0x22f
    8000264a:	80a48493          	addi	s1,s1,-2038 # 80230e50 <proc>
    8000264e:	0023e997          	auipc	s3,0x23e
    80002652:	20298993          	addi	s3,s3,514 # 80240850 <tickslock>
    acquire(&p->lock);
    80002656:	8526                	mv	a0,s1
    80002658:	e56fe0ef          	jal	ra,80000cae <acquire>
    if(p->pid == pid){
    8000265c:	589c                	lw	a5,48(s1)
    8000265e:	01278b63          	beq	a5,s2,80002674 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002662:	8526                	mv	a0,s1
    80002664:	ee2fe0ef          	jal	ra,80000d46 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002668:	3e848493          	addi	s1,s1,1000
    8000266c:	ff3495e3          	bne	s1,s3,80002656 <kkill+0x20>
  }
  return -1;
    80002670:	557d                	li	a0,-1
    80002672:	a819                	j	80002688 <kkill+0x52>
      p->killed = 1;
    80002674:	4785                	li	a5,1
    80002676:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002678:	4c98                	lw	a4,24(s1)
    8000267a:	4789                	li	a5,2
    8000267c:	00f70d63          	beq	a4,a5,80002696 <kkill+0x60>
      release(&p->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	ec4fe0ef          	jal	ra,80000d46 <release>
      return 0;
    80002686:	4501                	li	a0,0
}
    80002688:	70a2                	ld	ra,40(sp)
    8000268a:	7402                	ld	s0,32(sp)
    8000268c:	64e2                	ld	s1,24(sp)
    8000268e:	6942                	ld	s2,16(sp)
    80002690:	69a2                	ld	s3,8(sp)
    80002692:	6145                	addi	sp,sp,48
    80002694:	8082                	ret
        p->state = RUNNABLE;
    80002696:	478d                	li	a5,3
    80002698:	cc9c                	sw	a5,24(s1)
    8000269a:	b7dd                	j	80002680 <kkill+0x4a>

000000008000269c <setkilled>:

void
setkilled(struct proc *p)
{
    8000269c:	1101                	addi	sp,sp,-32
    8000269e:	ec06                	sd	ra,24(sp)
    800026a0:	e822                	sd	s0,16(sp)
    800026a2:	e426                	sd	s1,8(sp)
    800026a4:	1000                	addi	s0,sp,32
    800026a6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026a8:	e06fe0ef          	jal	ra,80000cae <acquire>
  p->killed = 1;
    800026ac:	4785                	li	a5,1
    800026ae:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026b0:	8526                	mv	a0,s1
    800026b2:	e94fe0ef          	jal	ra,80000d46 <release>
}
    800026b6:	60e2                	ld	ra,24(sp)
    800026b8:	6442                	ld	s0,16(sp)
    800026ba:	64a2                	ld	s1,8(sp)
    800026bc:	6105                	addi	sp,sp,32
    800026be:	8082                	ret

00000000800026c0 <killed>:

int
killed(struct proc *p)
{
    800026c0:	1101                	addi	sp,sp,-32
    800026c2:	ec06                	sd	ra,24(sp)
    800026c4:	e822                	sd	s0,16(sp)
    800026c6:	e426                	sd	s1,8(sp)
    800026c8:	e04a                	sd	s2,0(sp)
    800026ca:	1000                	addi	s0,sp,32
    800026cc:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800026ce:	de0fe0ef          	jal	ra,80000cae <acquire>
  k = p->killed;
    800026d2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800026d6:	8526                	mv	a0,s1
    800026d8:	e6efe0ef          	jal	ra,80000d46 <release>
  return k;
}
    800026dc:	854a                	mv	a0,s2
    800026de:	60e2                	ld	ra,24(sp)
    800026e0:	6442                	ld	s0,16(sp)
    800026e2:	64a2                	ld	s1,8(sp)
    800026e4:	6902                	ld	s2,0(sp)
    800026e6:	6105                	addi	sp,sp,32
    800026e8:	8082                	ret

00000000800026ea <kwait>:
{
    800026ea:	715d                	addi	sp,sp,-80
    800026ec:	e486                	sd	ra,72(sp)
    800026ee:	e0a2                	sd	s0,64(sp)
    800026f0:	fc26                	sd	s1,56(sp)
    800026f2:	f84a                	sd	s2,48(sp)
    800026f4:	f44e                	sd	s3,40(sp)
    800026f6:	f052                	sd	s4,32(sp)
    800026f8:	ec56                	sd	s5,24(sp)
    800026fa:	e85a                	sd	s6,16(sp)
    800026fc:	e45e                	sd	s7,8(sp)
    800026fe:	e062                	sd	s8,0(sp)
    80002700:	0880                	addi	s0,sp,80
    80002702:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002704:	c94ff0ef          	jal	ra,80001b98 <myproc>
    80002708:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000270a:	0022e517          	auipc	a0,0x22e
    8000270e:	32e50513          	addi	a0,a0,814 # 80230a38 <wait_lock>
    80002712:	d9cfe0ef          	jal	ra,80000cae <acquire>
    havekids = 0;
    80002716:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002718:	4a15                	li	s4,5
        havekids = 1;
    8000271a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000271c:	0023e997          	auipc	s3,0x23e
    80002720:	13498993          	addi	s3,s3,308 # 80240850 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002724:	0022ec17          	auipc	s8,0x22e
    80002728:	314c0c13          	addi	s8,s8,788 # 80230a38 <wait_lock>
    havekids = 0;
    8000272c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000272e:	0022e497          	auipc	s1,0x22e
    80002732:	72248493          	addi	s1,s1,1826 # 80230e50 <proc>
    80002736:	a899                	j	8000278c <kwait+0xa2>
          pid = pp->pid;
    80002738:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000273c:	000b0c63          	beqz	s6,80002754 <kwait+0x6a>
    80002740:	4691                	li	a3,4
    80002742:	02c48613          	addi	a2,s1,44
    80002746:	85da                	mv	a1,s6
    80002748:	05093503          	ld	a0,80(s2)
    8000274c:	83cff0ef          	jal	ra,80001788 <copyout>
    80002750:	00054f63          	bltz	a0,8000276e <kwait+0x84>
          freeproc(pp);
    80002754:	8526                	mv	a0,s1
    80002756:	845ff0ef          	jal	ra,80001f9a <freeproc>
          release(&pp->lock);
    8000275a:	8526                	mv	a0,s1
    8000275c:	deafe0ef          	jal	ra,80000d46 <release>
          release(&wait_lock);
    80002760:	0022e517          	auipc	a0,0x22e
    80002764:	2d850513          	addi	a0,a0,728 # 80230a38 <wait_lock>
    80002768:	ddefe0ef          	jal	ra,80000d46 <release>
          return pid;
    8000276c:	a891                	j	800027c0 <kwait+0xd6>
            release(&pp->lock);
    8000276e:	8526                	mv	a0,s1
    80002770:	dd6fe0ef          	jal	ra,80000d46 <release>
            release(&wait_lock);
    80002774:	0022e517          	auipc	a0,0x22e
    80002778:	2c450513          	addi	a0,a0,708 # 80230a38 <wait_lock>
    8000277c:	dcafe0ef          	jal	ra,80000d46 <release>
            return -1;
    80002780:	59fd                	li	s3,-1
    80002782:	a83d                	j	800027c0 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002784:	3e848493          	addi	s1,s1,1000
    80002788:	03348063          	beq	s1,s3,800027a8 <kwait+0xbe>
      if(pp->parent == p){
    8000278c:	7c9c                	ld	a5,56(s1)
    8000278e:	ff279be3          	bne	a5,s2,80002784 <kwait+0x9a>
        acquire(&pp->lock);
    80002792:	8526                	mv	a0,s1
    80002794:	d1afe0ef          	jal	ra,80000cae <acquire>
        if(pp->state == ZOMBIE){
    80002798:	4c9c                	lw	a5,24(s1)
    8000279a:	f9478fe3          	beq	a5,s4,80002738 <kwait+0x4e>
        release(&pp->lock);
    8000279e:	8526                	mv	a0,s1
    800027a0:	da6fe0ef          	jal	ra,80000d46 <release>
        havekids = 1;
    800027a4:	8756                	mv	a4,s5
    800027a6:	bff9                	j	80002784 <kwait+0x9a>
    if(!havekids || killed(p)){
    800027a8:	c709                	beqz	a4,800027b2 <kwait+0xc8>
    800027aa:	854a                	mv	a0,s2
    800027ac:	f15ff0ef          	jal	ra,800026c0 <killed>
    800027b0:	c50d                	beqz	a0,800027da <kwait+0xf0>
      release(&wait_lock);
    800027b2:	0022e517          	auipc	a0,0x22e
    800027b6:	28650513          	addi	a0,a0,646 # 80230a38 <wait_lock>
    800027ba:	d8cfe0ef          	jal	ra,80000d46 <release>
      return -1;
    800027be:	59fd                	li	s3,-1
}
    800027c0:	854e                	mv	a0,s3
    800027c2:	60a6                	ld	ra,72(sp)
    800027c4:	6406                	ld	s0,64(sp)
    800027c6:	74e2                	ld	s1,56(sp)
    800027c8:	7942                	ld	s2,48(sp)
    800027ca:	79a2                	ld	s3,40(sp)
    800027cc:	7a02                	ld	s4,32(sp)
    800027ce:	6ae2                	ld	s5,24(sp)
    800027d0:	6b42                	ld	s6,16(sp)
    800027d2:	6ba2                	ld	s7,8(sp)
    800027d4:	6c02                	ld	s8,0(sp)
    800027d6:	6161                	addi	sp,sp,80
    800027d8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027da:	85e2                	mv	a1,s8
    800027dc:	854a                	mv	a0,s2
    800027de:	cabff0ef          	jal	ra,80002488 <sleep>
    havekids = 0;
    800027e2:	b7a9                	j	8000272c <kwait+0x42>

00000000800027e4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027e4:	7179                	addi	sp,sp,-48
    800027e6:	f406                	sd	ra,40(sp)
    800027e8:	f022                	sd	s0,32(sp)
    800027ea:	ec26                	sd	s1,24(sp)
    800027ec:	e84a                	sd	s2,16(sp)
    800027ee:	e44e                	sd	s3,8(sp)
    800027f0:	e052                	sd	s4,0(sp)
    800027f2:	1800                	addi	s0,sp,48
    800027f4:	84aa                	mv	s1,a0
    800027f6:	892e                	mv	s2,a1
    800027f8:	89b2                	mv	s3,a2
    800027fa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027fc:	b9cff0ef          	jal	ra,80001b98 <myproc>
  if(user_dst){
    80002800:	cc99                	beqz	s1,8000281e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002802:	86d2                	mv	a3,s4
    80002804:	864e                	mv	a2,s3
    80002806:	85ca                	mv	a1,s2
    80002808:	6928                	ld	a0,80(a0)
    8000280a:	f7ffe0ef          	jal	ra,80001788 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000280e:	70a2                	ld	ra,40(sp)
    80002810:	7402                	ld	s0,32(sp)
    80002812:	64e2                	ld	s1,24(sp)
    80002814:	6942                	ld	s2,16(sp)
    80002816:	69a2                	ld	s3,8(sp)
    80002818:	6a02                	ld	s4,0(sp)
    8000281a:	6145                	addi	sp,sp,48
    8000281c:	8082                	ret
    memmove((char *)dst, src, len);
    8000281e:	000a061b          	sext.w	a2,s4
    80002822:	85ce                	mv	a1,s3
    80002824:	854a                	mv	a0,s2
    80002826:	db8fe0ef          	jal	ra,80000dde <memmove>
    return 0;
    8000282a:	8526                	mv	a0,s1
    8000282c:	b7cd                	j	8000280e <either_copyout+0x2a>

000000008000282e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000282e:	7179                	addi	sp,sp,-48
    80002830:	f406                	sd	ra,40(sp)
    80002832:	f022                	sd	s0,32(sp)
    80002834:	ec26                	sd	s1,24(sp)
    80002836:	e84a                	sd	s2,16(sp)
    80002838:	e44e                	sd	s3,8(sp)
    8000283a:	e052                	sd	s4,0(sp)
    8000283c:	1800                	addi	s0,sp,48
    8000283e:	892a                	mv	s2,a0
    80002840:	84ae                	mv	s1,a1
    80002842:	89b2                	mv	s3,a2
    80002844:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002846:	b52ff0ef          	jal	ra,80001b98 <myproc>
  if(user_src){
    8000284a:	cc99                	beqz	s1,80002868 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000284c:	86d2                	mv	a3,s4
    8000284e:	864e                	mv	a2,s3
    80002850:	85ca                	mv	a1,s2
    80002852:	6928                	ld	a0,80(a0)
    80002854:	844ff0ef          	jal	ra,80001898 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002858:	70a2                	ld	ra,40(sp)
    8000285a:	7402                	ld	s0,32(sp)
    8000285c:	64e2                	ld	s1,24(sp)
    8000285e:	6942                	ld	s2,16(sp)
    80002860:	69a2                	ld	s3,8(sp)
    80002862:	6a02                	ld	s4,0(sp)
    80002864:	6145                	addi	sp,sp,48
    80002866:	8082                	ret
    memmove(dst, (char*)src, len);
    80002868:	000a061b          	sext.w	a2,s4
    8000286c:	85ce                	mv	a1,s3
    8000286e:	854a                	mv	a0,s2
    80002870:	d6efe0ef          	jal	ra,80000dde <memmove>
    return 0;
    80002874:	8526                	mv	a0,s1
    80002876:	b7cd                	j	80002858 <either_copyin+0x2a>

0000000080002878 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002878:	715d                	addi	sp,sp,-80
    8000287a:	e486                	sd	ra,72(sp)
    8000287c:	e0a2                	sd	s0,64(sp)
    8000287e:	fc26                	sd	s1,56(sp)
    80002880:	f84a                	sd	s2,48(sp)
    80002882:	f44e                	sd	s3,40(sp)
    80002884:	f052                	sd	s4,32(sp)
    80002886:	ec56                	sd	s5,24(sp)
    80002888:	e85a                	sd	s6,16(sp)
    8000288a:	e45e                	sd	s7,8(sp)
    8000288c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000288e:	00006517          	auipc	a0,0x6
    80002892:	83a50513          	addi	a0,a0,-1990 # 800080c8 <digits+0x90>
    80002896:	c2dfd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000289a:	0022e497          	auipc	s1,0x22e
    8000289e:	70e48493          	addi	s1,s1,1806 # 80230fa8 <proc+0x158>
    800028a2:	0023e917          	auipc	s2,0x23e
    800028a6:	10690913          	addi	s2,s2,262 # 802409a8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028aa:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800028ac:	00006997          	auipc	s3,0x6
    800028b0:	97498993          	addi	s3,s3,-1676 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    800028b4:	00006a97          	auipc	s5,0x6
    800028b8:	974a8a93          	addi	s5,s5,-1676 # 80008228 <digits+0x1f0>
    printf("\n");
    800028bc:	00006a17          	auipc	s4,0x6
    800028c0:	80ca0a13          	addi	s4,s4,-2036 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028c4:	00006b97          	auipc	s7,0x6
    800028c8:	9a4b8b93          	addi	s7,s7,-1628 # 80008268 <states.0>
    800028cc:	a829                	j	800028e6 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800028ce:	ed86a583          	lw	a1,-296(a3)
    800028d2:	8556                	mv	a0,s5
    800028d4:	beffd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    800028d8:	8552                	mv	a0,s4
    800028da:	be9fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028de:	3e848493          	addi	s1,s1,1000
    800028e2:	03248263          	beq	s1,s2,80002906 <procdump+0x8e>
    if(p->state == UNUSED)
    800028e6:	86a6                	mv	a3,s1
    800028e8:	ec04a783          	lw	a5,-320(s1)
    800028ec:	dbed                	beqz	a5,800028de <procdump+0x66>
      state = "???";
    800028ee:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028f0:	fcfb6fe3          	bltu	s6,a5,800028ce <procdump+0x56>
    800028f4:	02079713          	slli	a4,a5,0x20
    800028f8:	01d75793          	srli	a5,a4,0x1d
    800028fc:	97de                	add	a5,a5,s7
    800028fe:	6390                	ld	a2,0(a5)
    80002900:	f679                	bnez	a2,800028ce <procdump+0x56>
      state = "???";
    80002902:	864e                	mv	a2,s3
    80002904:	b7e9                	j	800028ce <procdump+0x56>
  }
}
    80002906:	60a6                	ld	ra,72(sp)
    80002908:	6406                	ld	s0,64(sp)
    8000290a:	74e2                	ld	s1,56(sp)
    8000290c:	7942                	ld	s2,48(sp)
    8000290e:	79a2                	ld	s3,40(sp)
    80002910:	7a02                	ld	s4,32(sp)
    80002912:	6ae2                	ld	s5,24(sp)
    80002914:	6b42                	ld	s6,16(sp)
    80002916:	6ba2                	ld	s7,8(sp)
    80002918:	6161                	addi	sp,sp,80
    8000291a:	8082                	ret

000000008000291c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000291c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002920:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002924:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002926:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002928:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000292c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002930:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002934:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002938:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000293c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002940:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002944:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002948:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000294c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002950:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002954:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002958:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000295a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000295c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002960:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002964:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002968:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000296c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002970:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002974:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002978:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000297c:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002980:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002984:	8082                	ret

0000000080002986 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002986:	1141                	addi	sp,sp,-16
    80002988:	e406                	sd	ra,8(sp)
    8000298a:	e022                	sd	s0,0(sp)
    8000298c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000298e:	00006597          	auipc	a1,0x6
    80002992:	90a58593          	addi	a1,a1,-1782 # 80008298 <states.0+0x30>
    80002996:	0023e517          	auipc	a0,0x23e
    8000299a:	eba50513          	addi	a0,a0,-326 # 80240850 <tickslock>
    8000299e:	a90fe0ef          	jal	ra,80000c2e <initlock>
}
    800029a2:	60a2                	ld	ra,8(sp)
    800029a4:	6402                	ld	s0,0(sp)
    800029a6:	0141                	addi	sp,sp,16
    800029a8:	8082                	ret

00000000800029aa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029aa:	1141                	addi	sp,sp,-16
    800029ac:	e422                	sd	s0,8(sp)
    800029ae:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029b0:	00003797          	auipc	a5,0x3
    800029b4:	60078793          	addi	a5,a5,1536 # 80005fb0 <kernelvec>
    800029b8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029bc:	6422                	ld	s0,8(sp)
    800029be:	0141                	addi	sp,sp,16
    800029c0:	8082                	ret

00000000800029c2 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800029c2:	1141                	addi	sp,sp,-16
    800029c4:	e406                	sd	ra,8(sp)
    800029c6:	e022                	sd	s0,0(sp)
    800029c8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029ca:	9ceff0ef          	jal	ra,80001b98 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029d2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029d8:	04000737          	lui	a4,0x4000
    800029dc:	00004797          	auipc	a5,0x4
    800029e0:	62478793          	addi	a5,a5,1572 # 80007000 <_trampoline>
    800029e4:	00004697          	auipc	a3,0x4
    800029e8:	61c68693          	addi	a3,a3,1564 # 80007000 <_trampoline>
    800029ec:	8f95                	sub	a5,a5,a3
    800029ee:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800029f0:	0732                	slli	a4,a4,0xc
    800029f2:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f4:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029f8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029fa:	18002773          	csrr	a4,satp
    800029fe:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a00:	6d38                	ld	a4,88(a0)
    80002a02:	613c                	ld	a5,64(a0)
    80002a04:	6685                	lui	a3,0x1
    80002a06:	97b6                	add	a5,a5,a3
    80002a08:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a0a:	6d3c                	ld	a5,88(a0)
    80002a0c:	00000717          	auipc	a4,0x0
    80002a10:	0f470713          	addi	a4,a4,244 # 80002b00 <usertrap>
    80002a14:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a16:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a18:	8712                	mv	a4,tp
    80002a1a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a1c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a20:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a24:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a28:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a2c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a2e:	6f9c                	ld	a5,24(a5)
    80002a30:	14179073          	csrw	sepc,a5
}
    80002a34:	60a2                	ld	ra,8(sp)
    80002a36:	6402                	ld	s0,0(sp)
    80002a38:	0141                	addi	sp,sp,16
    80002a3a:	8082                	ret

0000000080002a3c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a3c:	1101                	addi	sp,sp,-32
    80002a3e:	ec06                	sd	ra,24(sp)
    80002a40:	e822                	sd	s0,16(sp)
    80002a42:	e426                	sd	s1,8(sp)
    80002a44:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002a46:	926ff0ef          	jal	ra,80001b6c <cpuid>
    80002a4a:	cd19                	beqz	a0,80002a68 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a4c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a50:	000f4737          	lui	a4,0xf4
    80002a54:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a58:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a5a:	14d79073          	csrw	0x14d,a5
}
    80002a5e:	60e2                	ld	ra,24(sp)
    80002a60:	6442                	ld	s0,16(sp)
    80002a62:	64a2                	ld	s1,8(sp)
    80002a64:	6105                	addi	sp,sp,32
    80002a66:	8082                	ret
    acquire(&tickslock);
    80002a68:	0023e497          	auipc	s1,0x23e
    80002a6c:	de848493          	addi	s1,s1,-536 # 80240850 <tickslock>
    80002a70:	8526                	mv	a0,s1
    80002a72:	a3cfe0ef          	jal	ra,80000cae <acquire>
    ticks++;
    80002a76:	00006517          	auipc	a0,0x6
    80002a7a:	e7250513          	addi	a0,a0,-398 # 800088e8 <ticks>
    80002a7e:	411c                	lw	a5,0(a0)
    80002a80:	2785                	addiw	a5,a5,1
    80002a82:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002a84:	a51ff0ef          	jal	ra,800024d4 <wakeup>
    release(&tickslock);
    80002a88:	8526                	mv	a0,s1
    80002a8a:	abcfe0ef          	jal	ra,80000d46 <release>
    80002a8e:	bf7d                	j	80002a4c <clockintr+0x10>

0000000080002a90 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a90:	1101                	addi	sp,sp,-32
    80002a92:	ec06                	sd	ra,24(sp)
    80002a94:	e822                	sd	s0,16(sp)
    80002a96:	e426                	sd	s1,8(sp)
    80002a98:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a9a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a9e:	57fd                	li	a5,-1
    80002aa0:	17fe                	slli	a5,a5,0x3f
    80002aa2:	07a5                	addi	a5,a5,9
    80002aa4:	00f70d63          	beq	a4,a5,80002abe <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002aa8:	57fd                	li	a5,-1
    80002aaa:	17fe                	slli	a5,a5,0x3f
    80002aac:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002aae:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002ab0:	04f70463          	beq	a4,a5,80002af8 <devintr+0x68>
  }
}
    80002ab4:	60e2                	ld	ra,24(sp)
    80002ab6:	6442                	ld	s0,16(sp)
    80002ab8:	64a2                	ld	s1,8(sp)
    80002aba:	6105                	addi	sp,sp,32
    80002abc:	8082                	ret
    int irq = plic_claim();
    80002abe:	59a030ef          	jal	ra,80006058 <plic_claim>
    80002ac2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ac4:	47a9                	li	a5,10
    80002ac6:	02f50363          	beq	a0,a5,80002aec <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002aca:	4785                	li	a5,1
    80002acc:	02f50363          	beq	a0,a5,80002af2 <devintr+0x62>
    return 1;
    80002ad0:	4505                	li	a0,1
    } else if(irq){
    80002ad2:	d0ed                	beqz	s1,80002ab4 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ad4:	85a6                	mv	a1,s1
    80002ad6:	00005517          	auipc	a0,0x5
    80002ada:	7ca50513          	addi	a0,a0,1994 # 800082a0 <states.0+0x38>
    80002ade:	9e5fd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    80002ae2:	8526                	mv	a0,s1
    80002ae4:	594030ef          	jal	ra,80006078 <plic_complete>
    return 1;
    80002ae8:	4505                	li	a0,1
    80002aea:	b7e9                	j	80002ab4 <devintr+0x24>
      uartintr();
    80002aec:	e69fd0ef          	jal	ra,80000954 <uartintr>
    80002af0:	bfcd                	j	80002ae2 <devintr+0x52>
      virtio_disk_intr();
    80002af2:	1f3030ef          	jal	ra,800064e4 <virtio_disk_intr>
    80002af6:	b7f5                	j	80002ae2 <devintr+0x52>
    clockintr();
    80002af8:	f45ff0ef          	jal	ra,80002a3c <clockintr>
    return 2;
    80002afc:	4509                	li	a0,2
    80002afe:	bf5d                	j	80002ab4 <devintr+0x24>

0000000080002b00 <usertrap>:
{
    80002b00:	7179                	addi	sp,sp,-48
    80002b02:	f406                	sd	ra,40(sp)
    80002b04:	f022                	sd	s0,32(sp)
    80002b06:	ec26                	sd	s1,24(sp)
    80002b08:	e84a                	sd	s2,16(sp)
    80002b0a:	e44e                	sd	s3,8(sp)
    80002b0c:	e052                	sd	s4,0(sp)
    80002b0e:	1800                	addi	s0,sp,48
    80002b10:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b14:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b18:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b1c:	1007f793          	andi	a5,a5,256
    80002b20:	e3bd                	bnez	a5,80002b86 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b22:	00003797          	auipc	a5,0x3
    80002b26:	48e78793          	addi	a5,a5,1166 # 80005fb0 <kernelvec>
    80002b2a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b2e:	86aff0ef          	jal	ra,80001b98 <myproc>
    80002b32:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b34:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b36:	14102773          	csrr	a4,sepc
    80002b3a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b3c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b40:	47a1                	li	a5,8
    80002b42:	04f70863          	beq	a4,a5,80002b92 <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002b46:	f4bff0ef          	jal	ra,80002a90 <devintr>
    80002b4a:	892a                	mv	s2,a0
    80002b4c:	0c051e63          	bnez	a0,80002c28 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002b50:	47b5                	li	a5,13
    80002b52:	08f98663          	beq	s3,a5,80002bde <usertrap+0xde>
    80002b56:	47bd                	li	a5,15
    80002b58:	0af99363          	bne	s3,a5,80002bfe <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002b5c:	85d2                	mv	a1,s4
    80002b5e:	68a8                	ld	a0,80(s1)
    80002b60:	9fbfe0ef          	jal	ra,8000155a <cowbreak>
    80002b64:	c531                	beqz	a0,80002bb0 <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    80002b66:	4605                	li	a2,1
    80002b68:	85d2                	mv	a1,s4
    80002b6a:	8526                	mv	a0,s1
    80002b6c:	dd1fe0ef          	jal	ra,8000193c <vmafault>
    80002b70:	e121                	bnez	a0,80002bb0 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    80002b72:	4601                	li	a2,0
    80002b74:	85d2                	mv	a1,s4
    80002b76:	68a8                	ld	a0,80(s1)
    80002b78:	b9ffe0ef          	jal	ra,80001716 <vmfault>
    80002b7c:	e915                	bnez	a0,80002bb0 <usertrap+0xb0>
        setkilled(p);
    80002b7e:	8526                	mv	a0,s1
    80002b80:	b1dff0ef          	jal	ra,8000269c <setkilled>
    80002b84:	a035                	j	80002bb0 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002b86:	00005517          	auipc	a0,0x5
    80002b8a:	73a50513          	addi	a0,a0,1850 # 800082c0 <states.0+0x58>
    80002b8e:	bfbfd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    80002b92:	b2fff0ef          	jal	ra,800026c0 <killed>
    80002b96:	e121                	bnez	a0,80002bd6 <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002b98:	6cb8                	ld	a4,88(s1)
    80002b9a:	6f1c                	ld	a5,24(a4)
    80002b9c:	0791                	addi	a5,a5,4
    80002b9e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ba4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba8:	10079073          	csrw	sstatus,a5
    syscall();
    80002bac:	27c000ef          	jal	ra,80002e28 <syscall>
  if(killed(p))
    80002bb0:	8526                	mv	a0,s1
    80002bb2:	b0fff0ef          	jal	ra,800026c0 <killed>
    80002bb6:	ed35                	bnez	a0,80002c32 <usertrap+0x132>
  prepare_return();
    80002bb8:	e0bff0ef          	jal	ra,800029c2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bbc:	68a8                	ld	a0,80(s1)
    80002bbe:	8131                	srli	a0,a0,0xc
    80002bc0:	57fd                	li	a5,-1
    80002bc2:	17fe                	slli	a5,a5,0x3f
    80002bc4:	8d5d                	or	a0,a0,a5
}
    80002bc6:	70a2                	ld	ra,40(sp)
    80002bc8:	7402                	ld	s0,32(sp)
    80002bca:	64e2                	ld	s1,24(sp)
    80002bcc:	6942                	ld	s2,16(sp)
    80002bce:	69a2                	ld	s3,8(sp)
    80002bd0:	6a02                	ld	s4,0(sp)
    80002bd2:	6145                	addi	sp,sp,48
    80002bd4:	8082                	ret
      kexit(-1);
    80002bd6:	557d                	li	a0,-1
    80002bd8:	9bdff0ef          	jal	ra,80002594 <kexit>
    80002bdc:	bf75                	j	80002b98 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002bde:	4601                	li	a2,0
    80002be0:	85d2                	mv	a1,s4
    80002be2:	8526                	mv	a0,s1
    80002be4:	d59fe0ef          	jal	ra,8000193c <vmafault>
    80002be8:	f561                	bnez	a0,80002bb0 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002bea:	4605                	li	a2,1
    80002bec:	85d2                	mv	a1,s4
    80002bee:	68a8                	ld	a0,80(s1)
    80002bf0:	b27fe0ef          	jal	ra,80001716 <vmfault>
    80002bf4:	fd55                	bnez	a0,80002bb0 <usertrap+0xb0>
        setkilled(p);
    80002bf6:	8526                	mv	a0,s1
    80002bf8:	aa5ff0ef          	jal	ra,8000269c <setkilled>
    80002bfc:	bf55                	j	80002bb0 <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002bfe:	5890                	lw	a2,48(s1)
    80002c00:	85ce                	mv	a1,s3
    80002c02:	00005517          	auipc	a0,0x5
    80002c06:	6de50513          	addi	a0,a0,1758 # 800082e0 <states.0+0x78>
    80002c0a:	8b9fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0e:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002c12:	8652                	mv	a2,s4
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	6fc50513          	addi	a0,a0,1788 # 80008310 <states.0+0xa8>
    80002c1c:	8a7fd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    80002c20:	8526                	mv	a0,s1
    80002c22:	a7bff0ef          	jal	ra,8000269c <setkilled>
    80002c26:	b769                	j	80002bb0 <usertrap+0xb0>
  if(killed(p))
    80002c28:	8526                	mv	a0,s1
    80002c2a:	a97ff0ef          	jal	ra,800026c0 <killed>
    80002c2e:	c511                	beqz	a0,80002c3a <usertrap+0x13a>
    80002c30:	a011                	j	80002c34 <usertrap+0x134>
    80002c32:	4901                	li	s2,0
    kexit(-1);
    80002c34:	557d                	li	a0,-1
    80002c36:	95fff0ef          	jal	ra,80002594 <kexit>
  if(which_dev == 2)
    80002c3a:	4789                	li	a5,2
    80002c3c:	f6f91ee3          	bne	s2,a5,80002bb8 <usertrap+0xb8>
    yield();
    80002c40:	81dff0ef          	jal	ra,8000245c <yield>
    80002c44:	bf95                	j	80002bb8 <usertrap+0xb8>

0000000080002c46 <kerneltrap>:
{
    80002c46:	7179                	addi	sp,sp,-48
    80002c48:	f406                	sd	ra,40(sp)
    80002c4a:	f022                	sd	s0,32(sp)
    80002c4c:	ec26                	sd	s1,24(sp)
    80002c4e:	e84a                	sd	s2,16(sp)
    80002c50:	e44e                	sd	s3,8(sp)
    80002c52:	1800                	addi	s0,sp,48
    80002c54:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c58:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c5c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c60:	1004f793          	andi	a5,s1,256
    80002c64:	c795                	beqz	a5,80002c90 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c66:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c6a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c6c:	eb85                	bnez	a5,80002c9c <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002c6e:	e23ff0ef          	jal	ra,80002a90 <devintr>
    80002c72:	c91d                	beqz	a0,80002ca8 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002c74:	4789                	li	a5,2
    80002c76:	04f50a63          	beq	a0,a5,80002cca <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c7a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c7e:	10049073          	csrw	sstatus,s1
}
    80002c82:	70a2                	ld	ra,40(sp)
    80002c84:	7402                	ld	s0,32(sp)
    80002c86:	64e2                	ld	s1,24(sp)
    80002c88:	6942                	ld	s2,16(sp)
    80002c8a:	69a2                	ld	s3,8(sp)
    80002c8c:	6145                	addi	sp,sp,48
    80002c8e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c90:	00005517          	auipc	a0,0x5
    80002c94:	6a850513          	addi	a0,a0,1704 # 80008338 <states.0+0xd0>
    80002c98:	af1fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c9c:	00005517          	auipc	a0,0x5
    80002ca0:	6c450513          	addi	a0,a0,1732 # 80008360 <states.0+0xf8>
    80002ca4:	ae5fd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ca8:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cac:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002cb0:	85ce                	mv	a1,s3
    80002cb2:	00005517          	auipc	a0,0x5
    80002cb6:	6ce50513          	addi	a0,a0,1742 # 80008380 <states.0+0x118>
    80002cba:	809fd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002cbe:	00005517          	auipc	a0,0x5
    80002cc2:	6ea50513          	addi	a0,a0,1770 # 800083a8 <states.0+0x140>
    80002cc6:	ac3fd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002cca:	ecffe0ef          	jal	ra,80001b98 <myproc>
    80002cce:	d555                	beqz	a0,80002c7a <kerneltrap+0x34>
    yield();
    80002cd0:	f8cff0ef          	jal	ra,8000245c <yield>
    80002cd4:	b75d                	j	80002c7a <kerneltrap+0x34>

0000000080002cd6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cd6:	1101                	addi	sp,sp,-32
    80002cd8:	ec06                	sd	ra,24(sp)
    80002cda:	e822                	sd	s0,16(sp)
    80002cdc:	e426                	sd	s1,8(sp)
    80002cde:	1000                	addi	s0,sp,32
    80002ce0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ce2:	eb7fe0ef          	jal	ra,80001b98 <myproc>
  switch (n) {
    80002ce6:	4795                	li	a5,5
    80002ce8:	0497e163          	bltu	a5,s1,80002d2a <argraw+0x54>
    80002cec:	048a                	slli	s1,s1,0x2
    80002cee:	00005717          	auipc	a4,0x5
    80002cf2:	6f270713          	addi	a4,a4,1778 # 800083e0 <states.0+0x178>
    80002cf6:	94ba                	add	s1,s1,a4
    80002cf8:	409c                	lw	a5,0(s1)
    80002cfa:	97ba                	add	a5,a5,a4
    80002cfc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cfe:	6d3c                	ld	a5,88(a0)
    80002d00:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d02:	60e2                	ld	ra,24(sp)
    80002d04:	6442                	ld	s0,16(sp)
    80002d06:	64a2                	ld	s1,8(sp)
    80002d08:	6105                	addi	sp,sp,32
    80002d0a:	8082                	ret
    return p->trapframe->a1;
    80002d0c:	6d3c                	ld	a5,88(a0)
    80002d0e:	7fa8                	ld	a0,120(a5)
    80002d10:	bfcd                	j	80002d02 <argraw+0x2c>
    return p->trapframe->a2;
    80002d12:	6d3c                	ld	a5,88(a0)
    80002d14:	63c8                	ld	a0,128(a5)
    80002d16:	b7f5                	j	80002d02 <argraw+0x2c>
    return p->trapframe->a3;
    80002d18:	6d3c                	ld	a5,88(a0)
    80002d1a:	67c8                	ld	a0,136(a5)
    80002d1c:	b7dd                	j	80002d02 <argraw+0x2c>
    return p->trapframe->a4;
    80002d1e:	6d3c                	ld	a5,88(a0)
    80002d20:	6bc8                	ld	a0,144(a5)
    80002d22:	b7c5                	j	80002d02 <argraw+0x2c>
    return p->trapframe->a5;
    80002d24:	6d3c                	ld	a5,88(a0)
    80002d26:	6fc8                	ld	a0,152(a5)
    80002d28:	bfe9                	j	80002d02 <argraw+0x2c>
  panic("argraw");
    80002d2a:	00005517          	auipc	a0,0x5
    80002d2e:	68e50513          	addi	a0,a0,1678 # 800083b8 <states.0+0x150>
    80002d32:	a57fd0ef          	jal	ra,80000788 <panic>

0000000080002d36 <fetchaddr>:
{
    80002d36:	1101                	addi	sp,sp,-32
    80002d38:	ec06                	sd	ra,24(sp)
    80002d3a:	e822                	sd	s0,16(sp)
    80002d3c:	e426                	sd	s1,8(sp)
    80002d3e:	e04a                	sd	s2,0(sp)
    80002d40:	1000                	addi	s0,sp,32
    80002d42:	84aa                	mv	s1,a0
    80002d44:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d46:	e53fe0ef          	jal	ra,80001b98 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d4a:	653c                	ld	a5,72(a0)
    80002d4c:	02f4f663          	bgeu	s1,a5,80002d78 <fetchaddr+0x42>
    80002d50:	00848713          	addi	a4,s1,8
    80002d54:	02e7e463          	bltu	a5,a4,80002d7c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d58:	46a1                	li	a3,8
    80002d5a:	8626                	mv	a2,s1
    80002d5c:	85ca                	mv	a1,s2
    80002d5e:	6928                	ld	a0,80(a0)
    80002d60:	b39fe0ef          	jal	ra,80001898 <copyin>
    80002d64:	00a03533          	snez	a0,a0
    80002d68:	40a00533          	neg	a0,a0
}
    80002d6c:	60e2                	ld	ra,24(sp)
    80002d6e:	6442                	ld	s0,16(sp)
    80002d70:	64a2                	ld	s1,8(sp)
    80002d72:	6902                	ld	s2,0(sp)
    80002d74:	6105                	addi	sp,sp,32
    80002d76:	8082                	ret
    return -1;
    80002d78:	557d                	li	a0,-1
    80002d7a:	bfcd                	j	80002d6c <fetchaddr+0x36>
    80002d7c:	557d                	li	a0,-1
    80002d7e:	b7fd                	j	80002d6c <fetchaddr+0x36>

0000000080002d80 <fetchstr>:
{
    80002d80:	7179                	addi	sp,sp,-48
    80002d82:	f406                	sd	ra,40(sp)
    80002d84:	f022                	sd	s0,32(sp)
    80002d86:	ec26                	sd	s1,24(sp)
    80002d88:	e84a                	sd	s2,16(sp)
    80002d8a:	e44e                	sd	s3,8(sp)
    80002d8c:	1800                	addi	s0,sp,48
    80002d8e:	892a                	mv	s2,a0
    80002d90:	84ae                	mv	s1,a1
    80002d92:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d94:	e05fe0ef          	jal	ra,80001b98 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d98:	86ce                	mv	a3,s3
    80002d9a:	864a                	mv	a2,s2
    80002d9c:	85a6                	mv	a1,s1
    80002d9e:	6928                	ld	a0,80(a0)
    80002da0:	8abfe0ef          	jal	ra,8000164a <copyinstr>
    80002da4:	00054c63          	bltz	a0,80002dbc <fetchstr+0x3c>
  return strlen(buf);
    80002da8:	8526                	mv	a0,s1
    80002daa:	950fe0ef          	jal	ra,80000efa <strlen>
}
    80002dae:	70a2                	ld	ra,40(sp)
    80002db0:	7402                	ld	s0,32(sp)
    80002db2:	64e2                	ld	s1,24(sp)
    80002db4:	6942                	ld	s2,16(sp)
    80002db6:	69a2                	ld	s3,8(sp)
    80002db8:	6145                	addi	sp,sp,48
    80002dba:	8082                	ret
    return -1;
    80002dbc:	557d                	li	a0,-1
    80002dbe:	bfc5                	j	80002dae <fetchstr+0x2e>

0000000080002dc0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	1000                	addi	s0,sp,32
    80002dca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dcc:	f0bff0ef          	jal	ra,80002cd6 <argraw>
    80002dd0:	c088                	sw	a0,0(s1)
}
    80002dd2:	60e2                	ld	ra,24(sp)
    80002dd4:	6442                	ld	s0,16(sp)
    80002dd6:	64a2                	ld	s1,8(sp)
    80002dd8:	6105                	addi	sp,sp,32
    80002dda:	8082                	ret

0000000080002ddc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ddc:	1101                	addi	sp,sp,-32
    80002dde:	ec06                	sd	ra,24(sp)
    80002de0:	e822                	sd	s0,16(sp)
    80002de2:	e426                	sd	s1,8(sp)
    80002de4:	1000                	addi	s0,sp,32
    80002de6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002de8:	eefff0ef          	jal	ra,80002cd6 <argraw>
    80002dec:	e088                	sd	a0,0(s1)
}
    80002dee:	60e2                	ld	ra,24(sp)
    80002df0:	6442                	ld	s0,16(sp)
    80002df2:	64a2                	ld	s1,8(sp)
    80002df4:	6105                	addi	sp,sp,32
    80002df6:	8082                	ret

0000000080002df8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002df8:	7179                	addi	sp,sp,-48
    80002dfa:	f406                	sd	ra,40(sp)
    80002dfc:	f022                	sd	s0,32(sp)
    80002dfe:	ec26                	sd	s1,24(sp)
    80002e00:	e84a                	sd	s2,16(sp)
    80002e02:	1800                	addi	s0,sp,48
    80002e04:	84ae                	mv	s1,a1
    80002e06:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e08:	fd840593          	addi	a1,s0,-40
    80002e0c:	fd1ff0ef          	jal	ra,80002ddc <argaddr>
  return fetchstr(addr, buf, max);
    80002e10:	864a                	mv	a2,s2
    80002e12:	85a6                	mv	a1,s1
    80002e14:	fd843503          	ld	a0,-40(s0)
    80002e18:	f69ff0ef          	jal	ra,80002d80 <fetchstr>
}
    80002e1c:	70a2                	ld	ra,40(sp)
    80002e1e:	7402                	ld	s0,32(sp)
    80002e20:	64e2                	ld	s1,24(sp)
    80002e22:	6942                	ld	s2,16(sp)
    80002e24:	6145                	addi	sp,sp,48
    80002e26:	8082                	ret

0000000080002e28 <syscall>:
[SYS_vmstats]    sys_vmstats,
};

void
syscall(void)
{
    80002e28:	1101                	addi	sp,sp,-32
    80002e2a:	ec06                	sd	ra,24(sp)
    80002e2c:	e822                	sd	s0,16(sp)
    80002e2e:	e426                	sd	s1,8(sp)
    80002e30:	e04a                	sd	s2,0(sp)
    80002e32:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e34:	d65fe0ef          	jal	ra,80001b98 <myproc>
    80002e38:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e3a:	05853903          	ld	s2,88(a0)
    80002e3e:	0a893783          	ld	a5,168(s2)
    80002e42:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e46:	37fd                	addiw	a5,a5,-1
    80002e48:	4771                	li	a4,28
    80002e4a:	00f76f63          	bltu	a4,a5,80002e68 <syscall+0x40>
    80002e4e:	00369713          	slli	a4,a3,0x3
    80002e52:	00005797          	auipc	a5,0x5
    80002e56:	5a678793          	addi	a5,a5,1446 # 800083f8 <syscalls>
    80002e5a:	97ba                	add	a5,a5,a4
    80002e5c:	639c                	ld	a5,0(a5)
    80002e5e:	c789                	beqz	a5,80002e68 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e60:	9782                	jalr	a5
    80002e62:	06a93823          	sd	a0,112(s2)
    80002e66:	a829                	j	80002e80 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e68:	15848613          	addi	a2,s1,344
    80002e6c:	588c                	lw	a1,48(s1)
    80002e6e:	00005517          	auipc	a0,0x5
    80002e72:	55250513          	addi	a0,a0,1362 # 800083c0 <states.0+0x158>
    80002e76:	e4cfd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e7a:	6cbc                	ld	a5,88(s1)
    80002e7c:	577d                	li	a4,-1
    80002e7e:	fbb8                	sd	a4,112(a5)
  }
}
    80002e80:	60e2                	ld	ra,24(sp)
    80002e82:	6442                	ld	s0,16(sp)
    80002e84:	64a2                	ld	s1,8(sp)
    80002e86:	6902                	ld	s2,0(sp)
    80002e88:	6105                	addi	sp,sp,32
    80002e8a:	8082                	ret

0000000080002e8c <proc_has_shm_key>:
  }
  return best;
}
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
    80002e8c:	1141                	addi	sp,sp,-16
    80002e8e:	e422                	sd	s0,8(sp)
    80002e90:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002e92:	16850793          	addi	a5,a0,360
    80002e96:	3e850513          	addi	a0,a0,1000
    80002e9a:	a029                	j	80002ea4 <proc_has_shm_key+0x18>
    80002e9c:	02878793          	addi	a5,a5,40
    80002ea0:	00a78d63          	beq	a5,a0,80002eba <proc_has_shm_key+0x2e>
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    80002ea4:	fef60ce3          	beq	a2,a5,80002e9c <proc_has_shm_key+0x10>
    if(v->used && v->is_shm && v->shm_key == key)
    80002ea8:	4398                	lw	a4,0(a5)
    80002eaa:	db6d                	beqz	a4,80002e9c <proc_has_shm_key+0x10>
    80002eac:	5398                	lw	a4,32(a5)
    80002eae:	d77d                	beqz	a4,80002e9c <proc_has_shm_key+0x10>
    80002eb0:	53d8                	lw	a4,36(a5)
    80002eb2:	feb715e3          	bne	a4,a1,80002e9c <proc_has_shm_key+0x10>
      return 1;
    80002eb6:	4505                	li	a0,1
    80002eb8:	a011                	j	80002ebc <proc_has_shm_key+0x30>
  }
  return 0;
    80002eba:	4501                	li	a0,0
}
    80002ebc:	6422                	ld	s0,8(sp)
    80002ebe:	0141                	addi	sp,sp,16
    80002ec0:	8082                	ret

0000000080002ec2 <sys_exit>:
{
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	1000                	addi	s0,sp,32
  argint(0, &n);
    80002eca:	fec40593          	addi	a1,s0,-20
    80002ece:	4501                	li	a0,0
    80002ed0:	ef1ff0ef          	jal	ra,80002dc0 <argint>
  kexit(n);
    80002ed4:	fec42503          	lw	a0,-20(s0)
    80002ed8:	ebcff0ef          	jal	ra,80002594 <kexit>
}
    80002edc:	4501                	li	a0,0
    80002ede:	60e2                	ld	ra,24(sp)
    80002ee0:	6442                	ld	s0,16(sp)
    80002ee2:	6105                	addi	sp,sp,32
    80002ee4:	8082                	ret

0000000080002ee6 <sys_getpid>:
{
    80002ee6:	1141                	addi	sp,sp,-16
    80002ee8:	e406                	sd	ra,8(sp)
    80002eea:	e022                	sd	s0,0(sp)
    80002eec:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002eee:	cabfe0ef          	jal	ra,80001b98 <myproc>
}
    80002ef2:	5908                	lw	a0,48(a0)
    80002ef4:	60a2                	ld	ra,8(sp)
    80002ef6:	6402                	ld	s0,0(sp)
    80002ef8:	0141                	addi	sp,sp,16
    80002efa:	8082                	ret

0000000080002efc <sys_fork>:
{
    80002efc:	1141                	addi	sp,sp,-16
    80002efe:	e406                	sd	ra,8(sp)
    80002f00:	e022                	sd	s0,0(sp)
    80002f02:	0800                	addi	s0,sp,16
  return kfork();
    80002f04:	a50ff0ef          	jal	ra,80002154 <kfork>
}
    80002f08:	60a2                	ld	ra,8(sp)
    80002f0a:	6402                	ld	s0,0(sp)
    80002f0c:	0141                	addi	sp,sp,16
    80002f0e:	8082                	ret

0000000080002f10 <sys_wait>:
{
    80002f10:	1101                	addi	sp,sp,-32
    80002f12:	ec06                	sd	ra,24(sp)
    80002f14:	e822                	sd	s0,16(sp)
    80002f16:	1000                	addi	s0,sp,32
  argaddr(0, &p);
    80002f18:	fe840593          	addi	a1,s0,-24
    80002f1c:	4501                	li	a0,0
    80002f1e:	ebfff0ef          	jal	ra,80002ddc <argaddr>
  return kwait(p);
    80002f22:	fe843503          	ld	a0,-24(s0)
    80002f26:	fc4ff0ef          	jal	ra,800026ea <kwait>
}
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	6105                	addi	sp,sp,32
    80002f30:	8082                	ret

0000000080002f32 <sys_sbrk>:
{
    80002f32:	7179                	addi	sp,sp,-48
    80002f34:	f406                	sd	ra,40(sp)
    80002f36:	f022                	sd	s0,32(sp)
    80002f38:	ec26                	sd	s1,24(sp)
    80002f3a:	1800                	addi	s0,sp,48
  argint(0, &n);
    80002f3c:	fd840593          	addi	a1,s0,-40
    80002f40:	4501                	li	a0,0
    80002f42:	e7fff0ef          	jal	ra,80002dc0 <argint>
  argint(1, &t);
    80002f46:	fdc40593          	addi	a1,s0,-36
    80002f4a:	4505                	li	a0,1
    80002f4c:	e75ff0ef          	jal	ra,80002dc0 <argint>
  addr = myproc()->sz;
    80002f50:	c49fe0ef          	jal	ra,80001b98 <myproc>
    80002f54:	6524                	ld	s1,72(a0)
  if(t == SBRK_EAGER || n < 0) {
    80002f56:	fdc42703          	lw	a4,-36(s0)
    80002f5a:	4785                	li	a5,1
    80002f5c:	02f70763          	beq	a4,a5,80002f8a <sys_sbrk+0x58>
    80002f60:	fd842783          	lw	a5,-40(s0)
    80002f64:	0207c363          	bltz	a5,80002f8a <sys_sbrk+0x58>
    if(addr + n < addr)
    80002f68:	97a6                	add	a5,a5,s1
    80002f6a:	0297ee63          	bltu	a5,s1,80002fa6 <sys_sbrk+0x74>
    if(addr + n > TRAPFRAME)
    80002f6e:	02000737          	lui	a4,0x2000
    80002f72:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002f74:	0736                	slli	a4,a4,0xd
    80002f76:	02f76a63          	bltu	a4,a5,80002faa <sys_sbrk+0x78>
    myproc()->sz += n;
    80002f7a:	c1ffe0ef          	jal	ra,80001b98 <myproc>
    80002f7e:	fd842703          	lw	a4,-40(s0)
    80002f82:	653c                	ld	a5,72(a0)
    80002f84:	97ba                	add	a5,a5,a4
    80002f86:	e53c                	sd	a5,72(a0)
    80002f88:	a039                	j	80002f96 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002f8a:	fd842503          	lw	a0,-40(s0)
    80002f8e:	964ff0ef          	jal	ra,800020f2 <growproc>
    80002f92:	00054863          	bltz	a0,80002fa2 <sys_sbrk+0x70>
}
    80002f96:	8526                	mv	a0,s1
    80002f98:	70a2                	ld	ra,40(sp)
    80002f9a:	7402                	ld	s0,32(sp)
    80002f9c:	64e2                	ld	s1,24(sp)
    80002f9e:	6145                	addi	sp,sp,48
    80002fa0:	8082                	ret
      return -1;
    80002fa2:	54fd                	li	s1,-1
    80002fa4:	bfcd                	j	80002f96 <sys_sbrk+0x64>
      return -1;
    80002fa6:	54fd                	li	s1,-1
    80002fa8:	b7fd                	j	80002f96 <sys_sbrk+0x64>
      return -1;
    80002faa:	54fd                	li	s1,-1
    80002fac:	b7ed                	j	80002f96 <sys_sbrk+0x64>

0000000080002fae <sys_pause>:
{
    80002fae:	7139                	addi	sp,sp,-64
    80002fb0:	fc06                	sd	ra,56(sp)
    80002fb2:	f822                	sd	s0,48(sp)
    80002fb4:	f426                	sd	s1,40(sp)
    80002fb6:	f04a                	sd	s2,32(sp)
    80002fb8:	ec4e                	sd	s3,24(sp)
    80002fba:	0080                	addi	s0,sp,64
  argint(0, &n);
    80002fbc:	fcc40593          	addi	a1,s0,-52
    80002fc0:	4501                	li	a0,0
    80002fc2:	dffff0ef          	jal	ra,80002dc0 <argint>
  if(n < 0)
    80002fc6:	fcc42783          	lw	a5,-52(s0)
    80002fca:	0607c563          	bltz	a5,80003034 <sys_pause+0x86>
  acquire(&tickslock);
    80002fce:	0023e517          	auipc	a0,0x23e
    80002fd2:	88250513          	addi	a0,a0,-1918 # 80240850 <tickslock>
    80002fd6:	cd9fd0ef          	jal	ra,80000cae <acquire>
  ticks0 = ticks;
    80002fda:	00006917          	auipc	s2,0x6
    80002fde:	90e92903          	lw	s2,-1778(s2) # 800088e8 <ticks>
  while(ticks - ticks0 < n){
    80002fe2:	fcc42783          	lw	a5,-52(s0)
    80002fe6:	cb8d                	beqz	a5,80003018 <sys_pause+0x6a>
    sleep(&ticks, &tickslock);
    80002fe8:	0023e997          	auipc	s3,0x23e
    80002fec:	86898993          	addi	s3,s3,-1944 # 80240850 <tickslock>
    80002ff0:	00006497          	auipc	s1,0x6
    80002ff4:	8f848493          	addi	s1,s1,-1800 # 800088e8 <ticks>
    if(killed(myproc())){
    80002ff8:	ba1fe0ef          	jal	ra,80001b98 <myproc>
    80002ffc:	ec4ff0ef          	jal	ra,800026c0 <killed>
    80003000:	ed0d                	bnez	a0,8000303a <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80003002:	85ce                	mv	a1,s3
    80003004:	8526                	mv	a0,s1
    80003006:	c82ff0ef          	jal	ra,80002488 <sleep>
  while(ticks - ticks0 < n){
    8000300a:	409c                	lw	a5,0(s1)
    8000300c:	412787bb          	subw	a5,a5,s2
    80003010:	fcc42703          	lw	a4,-52(s0)
    80003014:	fee7e2e3          	bltu	a5,a4,80002ff8 <sys_pause+0x4a>
  release(&tickslock);
    80003018:	0023e517          	auipc	a0,0x23e
    8000301c:	83850513          	addi	a0,a0,-1992 # 80240850 <tickslock>
    80003020:	d27fd0ef          	jal	ra,80000d46 <release>
  return 0;
    80003024:	4501                	li	a0,0
}
    80003026:	70e2                	ld	ra,56(sp)
    80003028:	7442                	ld	s0,48(sp)
    8000302a:	74a2                	ld	s1,40(sp)
    8000302c:	7902                	ld	s2,32(sp)
    8000302e:	69e2                	ld	s3,24(sp)
    80003030:	6121                	addi	sp,sp,64
    80003032:	8082                	ret
    n = 0;
    80003034:	fc042623          	sw	zero,-52(s0)
    80003038:	bf59                	j	80002fce <sys_pause+0x20>
      release(&tickslock);
    8000303a:	0023e517          	auipc	a0,0x23e
    8000303e:	81650513          	addi	a0,a0,-2026 # 80240850 <tickslock>
    80003042:	d05fd0ef          	jal	ra,80000d46 <release>
      return -1;
    80003046:	557d                	li	a0,-1
    80003048:	bff9                	j	80003026 <sys_pause+0x78>

000000008000304a <sys_kill>:
{
    8000304a:	1101                	addi	sp,sp,-32
    8000304c:	ec06                	sd	ra,24(sp)
    8000304e:	e822                	sd	s0,16(sp)
    80003050:	1000                	addi	s0,sp,32
  argint(0, &pid);
    80003052:	fec40593          	addi	a1,s0,-20
    80003056:	4501                	li	a0,0
    80003058:	d69ff0ef          	jal	ra,80002dc0 <argint>
  return kkill(pid);
    8000305c:	fec42503          	lw	a0,-20(s0)
    80003060:	dd6ff0ef          	jal	ra,80002636 <kkill>
}
    80003064:	60e2                	ld	ra,24(sp)
    80003066:	6442                	ld	s0,16(sp)
    80003068:	6105                	addi	sp,sp,32
    8000306a:	8082                	ret

000000008000306c <sys_uptime>:
{
    8000306c:	1101                	addi	sp,sp,-32
    8000306e:	ec06                	sd	ra,24(sp)
    80003070:	e822                	sd	s0,16(sp)
    80003072:	e426                	sd	s1,8(sp)
    80003074:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003076:	0023d517          	auipc	a0,0x23d
    8000307a:	7da50513          	addi	a0,a0,2010 # 80240850 <tickslock>
    8000307e:	c31fd0ef          	jal	ra,80000cae <acquire>
  xticks = ticks;
    80003082:	00006497          	auipc	s1,0x6
    80003086:	8664a483          	lw	s1,-1946(s1) # 800088e8 <ticks>
  release(&tickslock);
    8000308a:	0023d517          	auipc	a0,0x23d
    8000308e:	7c650513          	addi	a0,a0,1990 # 80240850 <tickslock>
    80003092:	cb5fd0ef          	jal	ra,80000d46 <release>
}
    80003096:	02049513          	slli	a0,s1,0x20
    8000309a:	9101                	srli	a0,a0,0x20
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	64a2                	ld	s1,8(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret

00000000800030a6 <vma_find>:
{
    800030a6:	1141                	addi	sp,sp,-16
    800030a8:	e422                	sd	s0,8(sp)
    800030aa:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    800030ac:	16850793          	addi	a5,a0,360
    800030b0:	4701                	li	a4,0
    800030b2:	4841                	li	a6,16
    800030b4:	a031                	j	800030c0 <vma_find+0x1a>
    800030b6:	2705                	addiw	a4,a4,1
    800030b8:	02878793          	addi	a5,a5,40
    800030bc:	03070263          	beq	a4,a6,800030e0 <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    800030c0:	4394                	lw	a3,0(a5)
    800030c2:	daf5                	beqz	a3,800030b6 <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    800030c4:	6794                	ld	a3,8(a5)
    800030c6:	fed5e8e3          	bltu	a1,a3,800030b6 <vma_find+0x10>
    800030ca:	6b94                	ld	a3,16(a5)
    800030cc:	fed5f5e3          	bgeu	a1,a3,800030b6 <vma_find+0x10>
      return &p->vmas[i];
    800030d0:	00271793          	slli	a5,a4,0x2
    800030d4:	97ba                	add	a5,a5,a4
    800030d6:	078e                	slli	a5,a5,0x3
    800030d8:	16878793          	addi	a5,a5,360
    800030dc:	953e                	add	a0,a0,a5
    800030de:	a011                	j	800030e2 <vma_find+0x3c>
  return 0;
    800030e0:	4501                	li	a0,0
}
    800030e2:	6422                	ld	s0,8(sp)
    800030e4:	0141                	addi	sp,sp,16
    800030e6:	8082                	ret

00000000800030e8 <sys_mmap>:

uint64
sys_mmap(void)
{
    800030e8:	7119                	addi	sp,sp,-128
    800030ea:	fc86                	sd	ra,120(sp)
    800030ec:	f8a2                	sd	s0,112(sp)
    800030ee:	f4a6                	sd	s1,104(sp)
    800030f0:	f0ca                	sd	s2,96(sp)
    800030f2:	ecce                	sd	s3,88(sp)
    800030f4:	e8d2                	sd	s4,80(sp)
    800030f6:	e4d6                	sd	s5,72(sp)
    800030f8:	e0da                	sd	s6,64(sp)
    800030fa:	fc5e                	sd	s7,56(sp)
    800030fc:	f862                	sd	s8,48(sp)
    800030fe:	f466                	sd	s9,40(sp)
    80003100:	0100                	addi	s0,sp,128
  uint64 addr;
  int len, prot, flags, key = -1;
    80003102:	57fd                	li	a5,-1
    80003104:	f8f42423          	sw	a5,-120(s0)
  int did_shm_get = 0;
  int need_get = 0;
  int npages = 0;

  argaddr(0, &addr);
    80003108:	f9840593          	addi	a1,s0,-104
    8000310c:	4501                	li	a0,0
    8000310e:	ccfff0ef          	jal	ra,80002ddc <argaddr>
  argint(1, &len);
    80003112:	f9440593          	addi	a1,s0,-108
    80003116:	4505                	li	a0,1
    80003118:	ca9ff0ef          	jal	ra,80002dc0 <argint>
  argint(2, &prot);
    8000311c:	f9040593          	addi	a1,s0,-112
    80003120:	4509                	li	a0,2
    80003122:	c9fff0ef          	jal	ra,80002dc0 <argint>
  argint(3, &flags);
    80003126:	f8c40593          	addi	a1,s0,-116
    8000312a:	450d                	li	a0,3
    8000312c:	c95ff0ef          	jal	ra,80002dc0 <argint>
  argint(4, &key);
    80003130:	f8840593          	addi	a1,s0,-120
    80003134:	4511                	li	a0,4
    80003136:	c8bff0ef          	jal	ra,80002dc0 <argint>

  if(len <= 0) return (uint64)-1;
    8000313a:	f9442783          	lw	a5,-108(s0)
    8000313e:	1af05d63          	blez	a5,800032f8 <sys_mmap+0x210>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return (uint64)-1;
  if(plen > (MMAPTOP - MMAPBASE)) return (uint64)-1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return (uint64)-1;
    80003142:	f9042903          	lw	s2,-112(s0)
    80003146:	ffc97913          	andi	s2,s2,-4
    8000314a:	54fd                	li	s1,-1
    8000314c:	1a091763          	bnez	s2,800032fa <sys_mmap+0x212>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    80003150:	f8c42703          	lw	a4,-116(s0)
    80003154:	8b05                	andi	a4,a4,1
    80003156:	1a070263          	beqz	a4,800032fa <sys_mmap+0x212>
  if(addr != 0) return (uint64)-1;
    8000315a:	f9843a03          	ld	s4,-104(s0)
    8000315e:	180a1e63          	bnez	s4,800032fa <sys_mmap+0x212>
  uint64 plen = PGROUNDUP((uint64)len);
    80003162:	6705                	lui	a4,0x1
    80003164:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80003166:	00e789b3          	add	s3,a5,a4

  struct proc *p = myproc();
    8000316a:	a2ffe0ef          	jal	ra,80001b98 <myproc>
    8000316e:	8aaa                	mv	s5,a0

  //先把“是否需要 shm_get”算出来（此时还没创建/污染 vma）
  if(flags & MAP_SHARED){
    80003170:	f8c42b83          	lw	s7,-116(s0)
    80003174:	002bfb93          	andi	s7,s7,2
    80003178:	020b8563          	beqz	s7,800031a2 <sys_mmap+0xba>
    if(key < 0) return (uint64)-1;
    8000317c:	f8842503          	lw	a0,-120(s0)
    80003180:	16054d63          	bltz	a0,800032fa <sys_mmap+0x212>
    npages = plen / PGSIZE;
    80003184:	40c9dc13          	srai	s8,s3,0xc

    // rmid 后禁止新 attach
    if(shm_is_deleted(key))
    80003188:	065030ef          	jal	ra,800069ec <shm_is_deleted>
    8000318c:	16051763          	bnez	a0,800032fa <sys_mmap+0x212>
      return (uint64)-1;

    // 按进程计数：本进程首次引用才 shm_get
    if(!proc_has_shm_key(p, key, 0))
    80003190:	4601                	li	a2,0
    80003192:	f8842583          	lw	a1,-120(s0)
    80003196:	8556                	mv	a0,s5
    80003198:	cf5ff0ef          	jal	ra,80002e8c <proc_has_shm_key>
  int need_get = 0;
    8000319c:	00153b93          	seqz	s7,a0
    800031a0:	a011                	j	800031a4 <sys_mmap+0xbc>
  int npages = 0;
    800031a2:	8c5e                	mv	s8,s7
  for(int i = 0; i < NVMA; i++){
    800031a4:	168a8b13          	addi	s6,s5,360
  int npages = 0;
    800031a8:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    800031aa:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    800031ac:	4398                	lw	a4,0(a5)
    800031ae:	cb01                	beqz	a4,800031be <sys_mmap+0xd6>
  for(int i = 0; i < NVMA; i++){
    800031b0:	2905                	addiw	s2,s2,1
    800031b2:	02878793          	addi	a5,a5,40
    800031b6:	fed91be3          	bne	s2,a3,800031ac <sys_mmap+0xc4>
      need_get = 1;
  }

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    800031ba:	54fd                	li	s1,-1
    800031bc:	aa3d                	j	800032fa <sys_mmap+0x212>
  uint64 plen = PGROUNDUP((uint64)len);
    800031be:	74fd                	lui	s1,0xfffff
    800031c0:	0099f9b3          	and	s3,s3,s1
      return &p->vmas[i];
    800031c4:	00291c93          	slli	s9,s2,0x2
    800031c8:	012c8533          	add	a0,s9,s2
    800031cc:	050e                	slli	a0,a0,0x3
    800031ce:	16850513          	addi	a0,a0,360

  // 先清空这条 slot，避免失败时留下脏状态
  memset(v, 0, sizeof(*v));
    800031d2:	02800613          	li	a2,40
    800031d6:	4581                	li	a1,0
    800031d8:	9556                	add	a0,a0,s5
    800031da:	ba9fd0ef          	jal	ra,80000d82 <memset>
  v->shm_key = -1;
    800031de:	012c87b3          	add	a5,s9,s2
    800031e2:	078e                	slli	a5,a5,0x3
    800031e4:	97d6                	add	a5,a5,s5
    800031e6:	577d                	li	a4,-1
    800031e8:	18e7a623          	sw	a4,396(a5)
  len = PGROUNDUP(len);
    800031ec:	6805                	lui	a6,0x1
    800031ee:	187d                	addi	a6,a6,-1 # fff <_entry-0x7ffff001>
    800031f0:	984e                	add	a6,a6,s3
    800031f2:	00987833          	and	a6,a6,s1
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    800031f6:	400005b7          	lui	a1,0x40000
    800031fa:	95c2                	add	a1,a1,a6
    800031fc:	400004b7          	lui	s1,0x40000
    80003200:	3e8a8613          	addi	a2,s5,1000
    va = PGROUNDUP(jump);
    80003204:	6305                	lui	t1,0x1
    80003206:	137d                	addi	t1,t1,-1 # fff <_entry-0x7ffff001>
    80003208:	7e7d                	lui	t3,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    8000320a:	f3fff8b7          	lui	a7,0xf3fff
    8000320e:	08ba                	slli	a7,a7,0xe
    80003210:	01a8d893          	srli	a7,a7,0x1a
    80003214:	a81d                	j	8000324a <sys_mmap+0x162>
      if(best == 0 || e < best) best = e;
    80003216:	853a                	mv	a0,a4
  for(int i=0;i<NVMA;i++){
    80003218:	02878793          	addi	a5,a5,40
    8000321c:	00c78f63          	beq	a5,a2,8000323a <sys_mmap+0x152>
    if(!p->vmas[i].used) continue;
    80003220:	4398                	lw	a4,0(a5)
    80003222:	db7d                	beqz	a4,80003218 <sys_mmap+0x130>
    if(!(end <= s || start >= e)){
    80003224:	6798                	ld	a4,8(a5)
    80003226:	feb779e3          	bgeu	a4,a1,80003218 <sys_mmap+0x130>
    uint64 e = p->vmas[i].end;
    8000322a:	6b98                	ld	a4,16(a5)
    if(!(end <= s || start >= e)){
    8000322c:	fee4f6e3          	bgeu	s1,a4,80003218 <sys_mmap+0x130>
      if(best == 0 || e < best) best = e;
    80003230:	d17d                	beqz	a0,80003216 <sys_mmap+0x12e>
    80003232:	fea773e3          	bgeu	a4,a0,80003218 <sys_mmap+0x130>
    80003236:	853a                	mv	a0,a4
    80003238:	b7c5                	j	80003218 <sys_mmap+0x130>
    if(jump == 0){
    8000323a:	c919                	beqz	a0,80003250 <sys_mmap+0x168>
    va = PGROUNDUP(jump);
    8000323c:	951a                	add	a0,a0,t1
    8000323e:	01c574b3          	and	s1,a0,t3
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003242:	009805b3          	add	a1,a6,s1
    80003246:	06b8ee63          	bltu	a7,a1,800032c2 <sys_mmap+0x1da>
  int npages = 0;
    8000324a:	87da                	mv	a5,s6
  uint64 best = 0;
    8000324c:	8552                	mv	a0,s4
    8000324e:	bfc9                	j	80003220 <sys_mmap+0x138>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) goto bad;
  if(va < MMAPBASE || va + plen > MMAPTOP) goto bad;
    80003250:	400007b7          	lui	a5,0x40000
    80003254:	06f4e763          	bltu	s1,a5,800032c2 <sys_mmap+0x1da>
    80003258:	99a6                	add	s3,s3,s1
    8000325a:	010007b7          	lui	a5,0x1000
    8000325e:	17f5                	addi	a5,a5,-3 # fffffd <_entry-0x7f000003>
    80003260:	07ba                	slli	a5,a5,0xe
    80003262:	0737e063          	bltu	a5,s3,800032c2 <sys_mmap+0x1da>

  // 先写入 vma 基本信息
  v->used  = 1;
    80003266:	00291793          	slli	a5,s2,0x2
    8000326a:	97ca                	add	a5,a5,s2
    8000326c:	078e                	slli	a5,a5,0x3
    8000326e:	97d6                	add	a5,a5,s5
    80003270:	4705                	li	a4,1
    80003272:	16e7a423          	sw	a4,360(a5)
  v->start = va;
    80003276:	1697b823          	sd	s1,368(a5)
  v->end   = va + plen;
    8000327a:	1737bc23          	sd	s3,376(a5)
  v->prot  = prot;
    8000327e:	f9042703          	lw	a4,-112(s0)
    80003282:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    80003286:	f8c42703          	lw	a4,-116(s0)
    8000328a:	18e7a223          	sw	a4,388(a5)

  if(flags & MAP_SHARED){
    8000328e:	8b09                	andi	a4,a4,2
    80003290:	c72d                	beqz	a4,800032fa <sys_mmap+0x212>
    if(need_get){
    80003292:	020b9163          	bnez	s7,800032b4 <sys_mmap+0x1cc>
      if(shm_get(key, npages) < 0)
        goto bad;
      did_shm_get = 1;
    }
    v->is_shm = 1;
    80003296:	00291793          	slli	a5,s2,0x2
    8000329a:	01278733          	add	a4,a5,s2
    8000329e:	070e                	slli	a4,a4,0x3
    800032a0:	9756                	add	a4,a4,s5
    800032a2:	4685                	li	a3,1
    800032a4:	18d72423          	sw	a3,392(a4)
    v->shm_key = key;
    800032a8:	87ba                	mv	a5,a4
    800032aa:	f8842703          	lw	a4,-120(s0)
    800032ae:	18e7a623          	sw	a4,396(a5)
    800032b2:	a0a1                	j	800032fa <sys_mmap+0x212>
      if(shm_get(key, npages) < 0)
    800032b4:	85e2                	mv	a1,s8
    800032b6:	f8842503          	lw	a0,-120(s0)
    800032ba:	2f2030ef          	jal	ra,800065ac <shm_get>
    800032be:	fc055ce3          	bgez	a0,80003296 <sys_mmap+0x1ae>
bad:
  if(did_shm_get){
    shm_put(key);
  }
  if(v){
    v->used = 0;
    800032c2:	00291713          	slli	a4,s2,0x2
    800032c6:	012707b3          	add	a5,a4,s2
    800032ca:	078e                	slli	a5,a5,0x3
    800032cc:	97d6                	add	a5,a5,s5
    800032ce:	1607a423          	sw	zero,360(a5)
    v->is_shm = 0;
    800032d2:	1807a423          	sw	zero,392(a5)
    v->shm_key = -1;
    800032d6:	56fd                	li	a3,-1
    800032d8:	18d7a623          	sw	a3,396(a5)
    v->start = v->end = 0;
    800032dc:	1607bc23          	sd	zero,376(a5)
    800032e0:	1607b823          	sd	zero,368(a5)
    v->prot = v->flags = 0;
    800032e4:	1807a223          	sw	zero,388(a5)
    800032e8:	012707b3          	add	a5,a4,s2
    800032ec:	078e                	slli	a5,a5,0x3
    800032ee:	9abe                	add	s5,s5,a5
    800032f0:	180aa023          	sw	zero,384(s5)
  }
  return (uint64)-1;
    800032f4:	54fd                	li	s1,-1
    800032f6:	a011                	j	800032fa <sys_mmap+0x212>
  if(len <= 0) return (uint64)-1;
    800032f8:	54fd                	li	s1,-1
}
    800032fa:	8526                	mv	a0,s1
    800032fc:	70e6                	ld	ra,120(sp)
    800032fe:	7446                	ld	s0,112(sp)
    80003300:	74a6                	ld	s1,104(sp)
    80003302:	7906                	ld	s2,96(sp)
    80003304:	69e6                	ld	s3,88(sp)
    80003306:	6a46                	ld	s4,80(sp)
    80003308:	6aa6                	ld	s5,72(sp)
    8000330a:	6b06                	ld	s6,64(sp)
    8000330c:	7be2                	ld	s7,56(sp)
    8000330e:	7c42                	ld	s8,48(sp)
    80003310:	7ca2                	ld	s9,40(sp)
    80003312:	6109                	addi	sp,sp,128
    80003314:	8082                	ret

0000000080003316 <sys_munmap>:
}


uint64
sys_munmap(void)
{
    80003316:	7159                	addi	sp,sp,-112
    80003318:	f486                	sd	ra,104(sp)
    8000331a:	f0a2                	sd	s0,96(sp)
    8000331c:	eca6                	sd	s1,88(sp)
    8000331e:	e8ca                	sd	s2,80(sp)
    80003320:	e4ce                	sd	s3,72(sp)
    80003322:	e0d2                	sd	s4,64(sp)
    80003324:	fc56                	sd	s5,56(sp)
    80003326:	f85a                	sd	s6,48(sp)
    80003328:	f45e                	sd	s7,40(sp)
    8000332a:	f062                	sd	s8,32(sp)
    8000332c:	ec66                	sd	s9,24(sp)
    8000332e:	e86a                	sd	s10,16(sp)
    80003330:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    80003332:	867fe0ef          	jal	ra,80001b98 <myproc>
    80003336:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    80003338:	f9840593          	addi	a1,s0,-104
    8000333c:	4501                	li	a0,0
    8000333e:	a9fff0ef          	jal	ra,80002ddc <argaddr>
  argint(1, &len);
    80003342:	f9440593          	addi	a1,s0,-108
    80003346:	4505                	li	a0,1
    80003348:	a79ff0ef          	jal	ra,80002dc0 <argint>

  if(len <= 0) return (uint64)-1;
    8000334c:	f9442683          	lw	a3,-108(s0)
    80003350:	2cd05f63          	blez	a3,8000362e <sys_munmap+0x318>


  uint64 a = PGROUNDDOWN(uaddr);
    80003354:	f9843783          	ld	a5,-104(s0)
    80003358:	767d                	lui	a2,0xfffff
    8000335a:	00c7fa33          	and	s4,a5,a2
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    8000335e:	6705                	lui	a4,0x1
    80003360:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80003362:	00e78933          	add	s2,a5,a4
    80003366:	9936                	add	s2,s2,a3
    80003368:	00c97933          	and	s2,s2,a2
  if(b < a) return (uint64)-1;  // 溢出了
    8000336c:	557d                	li	a0,-1
    8000336e:	17496d63          	bltu	s2,s4,800034e8 <sys_munmap+0x1d2>
    80003372:	168a8b13          	addi	s6,s5,360
    80003376:	3e8a8993          	addi	s3,s5,1000
    8000337a:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    8000337c:	4801                	li	a6,0
    8000337e:	a029                	j	80003388 <sys_munmap+0x72>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    80003380:	02878793          	addi	a5,a5,40
    80003384:	01378663          	beq	a5,s3,80003390 <sys_munmap+0x7a>
    80003388:	4398                	lw	a4,0(a5)
    8000338a:	fb7d                	bnez	a4,80003380 <sys_munmap+0x6a>
    8000338c:	2805                	addiw	a6,a6,1
    8000338e:	bfcd                	j	80003380 <sys_munmap+0x6a>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    80003390:	8552                	mv	a0,s4
  int need_splits = 0;
    80003392:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    80003394:	4881                	li	a7,0
    80003396:	45c1                	li	a1,16
    80003398:	537d                	li	t1,-1
  while(cur < b){
    8000339a:	072a6163          	bltu	s4,s2,800033fc <sys_munmap+0xe6>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    8000339e:	43f85513          	srai	a0,a6,0x3f
    800033a2:	a299                	j	800034e8 <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    800033a4:	2705                	addiw	a4,a4,1
    800033a6:	02878793          	addi	a5,a5,40
    800033aa:	04b70c63          	beq	a4,a1,80003402 <sys_munmap+0xec>
    if(!p->vmas[i].used) continue;
    800033ae:	4394                	lw	a3,0(a5)
    800033b0:	daf5                	beqz	a3,800033a4 <sys_munmap+0x8e>
    if(!(b <= s || a >= e))   // overlap
    800033b2:	6794                	ld	a3,8(a5)
    800033b4:	ff26f8e3          	bgeu	a3,s2,800033a4 <sys_munmap+0x8e>
    800033b8:	6b94                	ld	a3,16(a5)
    800033ba:	fed575e3          	bgeu	a0,a3,800033a4 <sys_munmap+0x8e>
    if(vi < 0){
    800033be:	04074563          	bltz	a4,80003408 <sys_munmap+0xf2>
    uint64 seg_start = cur > v->start ? cur : v->start;
    800033c2:	00271793          	slli	a5,a4,0x2
    800033c6:	97ba                	add	a5,a5,a4
    800033c8:	078e                	slli	a5,a5,0x3
    800033ca:	97d6                	add	a5,a5,s5
    800033cc:	1707b683          	ld	a3,368(a5)
    800033d0:	8636                	mv	a2,a3
    800033d2:	00a6f363          	bgeu	a3,a0,800033d8 <sys_munmap+0xc2>
    800033d6:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    800033d8:	00271793          	slli	a5,a4,0x2
    800033dc:	97ba                	add	a5,a5,a4
    800033de:	078e                	slli	a5,a5,0x3
    800033e0:	97d6                	add	a5,a5,s5
    800033e2:	1787b783          	ld	a5,376(a5)
    800033e6:	853e                	mv	a0,a5
    800033e8:	00f97363          	bgeu	s2,a5,800033ee <sys_munmap+0xd8>
    800033ec:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    800033ee:	00c6f563          	bgeu	a3,a2,800033f8 <sys_munmap+0xe2>
    800033f2:	00f57363          	bgeu	a0,a5,800033f8 <sys_munmap+0xe2>
      need_splits++;
    800033f6:	2e05                	addiw	t3,t3,1 # fffffffffffff001 <end+0xffffffff7fdaadf1>
  while(cur < b){
    800033f8:	03257a63          	bgeu	a0,s2,8000342c <sys_munmap+0x116>
  int free_slots = 0;
    800033fc:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    800033fe:	8746                	mv	a4,a7
    80003400:	b77d                	j	800033ae <sys_munmap+0x98>
    80003402:	87da                	mv	a5,s6
    80003404:	869a                	mv	a3,t1
    80003406:	a801                	j	80003416 <sys_munmap+0x100>
    80003408:	87da                	mv	a5,s6
    8000340a:	869a                	mv	a3,t1
    8000340c:	a029                	j	80003416 <sys_munmap+0x100>
  for(int i = 0; i < NVMA; i++){
    8000340e:	02878793          	addi	a5,a5,40
    80003412:	01378b63          	beq	a5,s3,80003428 <sys_munmap+0x112>
    if(!p->vmas[i].used) continue;
    80003416:	4398                	lw	a4,0(a5)
    80003418:	db7d                	beqz	a4,8000340e <sys_munmap+0xf8>
    uint64 s = p->vmas[i].start;
    8000341a:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    8000341c:	fea769e3          	bltu	a4,a0,8000340e <sys_munmap+0xf8>
    80003420:	fed777e3          	bgeu	a4,a3,8000340e <sys_munmap+0xf8>
    80003424:	86ba                	mv	a3,a4
    80003426:	b7e5                	j	8000340e <sys_munmap+0xf8>
      if(ns == (uint64)-1 || ns >= b) break;
    80003428:	0126e963          	bltu	a3,s2,8000343a <sys_munmap+0x124>
    // 不做任何事，保持一致性
    return (uint64)-1;
    8000342c:	557d                	li	a0,-1
  if(need_splits > free_slots){
    8000342e:	0bc84d63          	blt	a6,t3,800034e8 <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    80003432:	4c01                	li	s8,0
    80003434:	4bc1                	li	s7,16
    80003436:	5cfd                	li	s9,-1
    80003438:	aac5                	j	80003628 <sys_munmap+0x312>
    8000343a:	8536                	mv	a0,a3
    8000343c:	b7c1                	j	800033fc <sys_munmap+0xe6>
    8000343e:	2485                	addiw	s1,s1,1 # 40000001 <_entry-0x3fffffff>
    80003440:	02878793          	addi	a5,a5,40
    80003444:	07748c63          	beq	s1,s7,800034bc <sys_munmap+0x1a6>
    if(!p->vmas[i].used) continue;
    80003448:	4398                	lw	a4,0(a5)
    8000344a:	db75                	beqz	a4,8000343e <sys_munmap+0x128>
    if(!(b <= s || a >= e))   // overlap
    8000344c:	6798                	ld	a4,8(a5)
    8000344e:	ff2778e3          	bgeu	a4,s2,8000343e <sys_munmap+0x128>
    80003452:	6b98                	ld	a4,16(a5)
    80003454:	feea75e3          	bgeu	s4,a4,8000343e <sys_munmap+0x128>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    80003458:	0604c563          	bltz	s1,800034c2 <sys_munmap+0x1ac>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    8000345c:	00249793          	slli	a5,s1,0x2
    80003460:	97a6                	add	a5,a5,s1
    80003462:	078e                	slli	a5,a5,0x3
    80003464:	97d6                	add	a5,a5,s5
    80003466:	1707bd03          	ld	s10,368(a5)
    8000346a:	014d7363          	bgeu	s10,s4,80003470 <sys_munmap+0x15a>
    8000346e:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003470:	00249793          	slli	a5,s1,0x2
    80003474:	97a6                	add	a5,a5,s1
    80003476:	078e                	slli	a5,a5,0x3
    80003478:	97d6                	add	a5,a5,s5
    8000347a:	1787ba03          	ld	s4,376(a5)
    8000347e:	01497363          	bgeu	s2,s4,80003484 <sys_munmap+0x16e>
    80003482:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    80003484:	094d6263          	bltu	s10,s4,80003508 <sys_munmap+0x1f2>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    80003488:	00249793          	slli	a5,s1,0x2
    8000348c:	97a6                	add	a5,a5,s1
    8000348e:	078e                	slli	a5,a5,0x3
    80003490:	97d6                	add	a5,a5,s5
    80003492:	1707b783          	ld	a5,368(a5)
    80003496:	11a7e463          	bltu	a5,s10,8000359e <sys_munmap+0x288>
    8000349a:	00249793          	slli	a5,s1,0x2
    8000349e:	97a6                	add	a5,a5,s1
    800034a0:	078e                	slli	a5,a5,0x3
    800034a2:	97d6                	add	a5,a5,s5
    800034a4:	1787b783          	ld	a5,376(a5)
    800034a8:	06fa7a63          	bgeu	s4,a5,8000351c <sys_munmap+0x206>
      //  v->shm_key, v->used, (void *)v->start, (void *)v->end);

      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    800034ac:	00249793          	slli	a5,s1,0x2
    800034b0:	97a6                	add	a5,a5,s1
    800034b2:	078e                	slli	a5,a5,0x3
    800034b4:	97d6                	add	a5,a5,s5
    800034b6:	1747b823          	sd	s4,368(a5)
    800034ba:	a2ad                	j	80003624 <sys_munmap+0x30e>
    800034bc:	87da                	mv	a5,s6
    800034be:	86e6                	mv	a3,s9
    800034c0:	a801                	j	800034d0 <sys_munmap+0x1ba>
    800034c2:	87da                	mv	a5,s6
    800034c4:	86e6                	mv	a3,s9
    800034c6:	a029                	j	800034d0 <sys_munmap+0x1ba>
  for(int i = 0; i < NVMA; i++){
    800034c8:	02878793          	addi	a5,a5,40
    800034cc:	01378b63          	beq	a5,s3,800034e2 <sys_munmap+0x1cc>
    if(!p->vmas[i].used) continue;
    800034d0:	4398                	lw	a4,0(a5)
    800034d2:	db7d                	beqz	a4,800034c8 <sys_munmap+0x1b2>
    uint64 s = p->vmas[i].start;
    800034d4:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    800034d6:	ff4769e3          	bltu	a4,s4,800034c8 <sys_munmap+0x1b2>
    800034da:	fed777e3          	bgeu	a4,a3,800034c8 <sys_munmap+0x1b2>
    800034de:	86ba                	mv	a3,a4
    800034e0:	b7e5                	j	800034c8 <sys_munmap+0x1b2>
      if(ns == (uint64)-1 || ns >= b) break;
    800034e2:	0326e163          	bltu	a3,s2,80003504 <sys_munmap+0x1ee>
    }

    cur = seg_end;
  }
  //shm_dump(1);
  return 0;
    800034e6:	4501                	li	a0,0
}
    800034e8:	70a6                	ld	ra,104(sp)
    800034ea:	7406                	ld	s0,96(sp)
    800034ec:	64e6                	ld	s1,88(sp)
    800034ee:	6946                	ld	s2,80(sp)
    800034f0:	69a6                	ld	s3,72(sp)
    800034f2:	6a06                	ld	s4,64(sp)
    800034f4:	7ae2                	ld	s5,56(sp)
    800034f6:	7b42                	ld	s6,48(sp)
    800034f8:	7ba2                	ld	s7,40(sp)
    800034fa:	7c02                	ld	s8,32(sp)
    800034fc:	6ce2                	ld	s9,24(sp)
    800034fe:	6d42                	ld	s10,16(sp)
    80003500:	6165                	addi	sp,sp,112
    80003502:	8082                	ret
    80003504:	8a36                	mv	s4,a3
    80003506:	a20d                	j	80003628 <sys_munmap+0x312>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    80003508:	41aa0633          	sub	a2,s4,s10
    8000350c:	4685                	li	a3,1
    8000350e:	8231                	srli	a2,a2,0xc
    80003510:	85ea                	mv	a1,s10
    80003512:	050ab503          	ld	a0,80(s5)
    80003516:	d99fd0ef          	jal	ra,800012ae <uvmunmap>
    8000351a:	b7bd                	j	80003488 <sys_munmap+0x172>
  if(v->used == 0) return;
    8000351c:	00249793          	slli	a5,s1,0x2
    80003520:	97a6                	add	a5,a5,s1
    80003522:	078e                	slli	a5,a5,0x3
    80003524:	97d6                	add	a5,a5,s5
    80003526:	1687a783          	lw	a5,360(a5)
    8000352a:	0e078d63          	beqz	a5,80003624 <sys_munmap+0x30e>
  if(v->is_shm){
    8000352e:	00249793          	slli	a5,s1,0x2
    80003532:	97a6                	add	a5,a5,s1
    80003534:	078e                	slli	a5,a5,0x3
    80003536:	97d6                	add	a5,a5,s5
    80003538:	1887a783          	lw	a5,392(a5)
    8000353c:	c785                	beqz	a5,80003564 <sys_munmap+0x24e>
    int key = v->shm_key;
    8000353e:	00249793          	slli	a5,s1,0x2
    80003542:	00978733          	add	a4,a5,s1
    80003546:	070e                	slli	a4,a4,0x3
    80003548:	9756                	add	a4,a4,s5
    8000354a:	18c72d03          	lw	s10,396(a4)
    struct vma *v = &p->vmas[vi];
    8000354e:	00978633          	add	a2,a5,s1
    80003552:	060e                	slli	a2,a2,0x3
    80003554:	16860613          	addi	a2,a2,360 # fffffffffffff168 <end+0xffffffff7fdaaf58>
    if(!proc_has_shm_key(p, key, v)){
    80003558:	9656                	add	a2,a2,s5
    8000355a:	85ea                	mv	a1,s10
    8000355c:	8556                	mv	a0,s5
    8000355e:	92fff0ef          	jal	ra,80002e8c <proc_has_shm_key>
    80003562:	c915                	beqz	a0,80003596 <sys_munmap+0x280>
  v->used = 0;
    80003564:	00249713          	slli	a4,s1,0x2
    80003568:	009707b3          	add	a5,a4,s1
    8000356c:	078e                	slli	a5,a5,0x3
    8000356e:	97d6                	add	a5,a5,s5
    80003570:	1607a423          	sw	zero,360(a5)
  v->start = v->end = 0;
    80003574:	1607bc23          	sd	zero,376(a5)
    80003578:	1607b823          	sd	zero,368(a5)
  v->prot = v->flags = 0;
    8000357c:	1807a223          	sw	zero,388(a5)
    80003580:	1807a023          	sw	zero,384(a5)
  v->is_shm = 0;
    80003584:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    80003588:	009707b3          	add	a5,a4,s1
    8000358c:	078e                	slli	a5,a5,0x3
    8000358e:	97d6                	add	a5,a5,s5
    80003590:	1997a623          	sw	s9,396(a5)
    80003594:	a841                	j	80003624 <sys_munmap+0x30e>
      shm_put(key);
    80003596:	856a                	mv	a0,s10
    80003598:	158030ef          	jal	ra,800066f0 <shm_put>
    8000359c:	b7e1                	j	80003564 <sys_munmap+0x24e>
    } else if(seg_start > v->start && seg_end >= v->end){
    8000359e:	00249793          	slli	a5,s1,0x2
    800035a2:	97a6                	add	a5,a5,s1
    800035a4:	078e                	slli	a5,a5,0x3
    800035a6:	97d6                	add	a5,a5,s5
    800035a8:	1787b783          	ld	a5,376(a5)
    800035ac:	00fa6a63          	bltu	s4,a5,800035c0 <sys_munmap+0x2aa>
      v->end = seg_start;
    800035b0:	00249793          	slli	a5,s1,0x2
    800035b4:	97a6                	add	a5,a5,s1
    800035b6:	078e                	slli	a5,a5,0x3
    800035b8:	97d6                	add	a5,a5,s5
    800035ba:	17a7bc23          	sd	s10,376(a5)
    800035be:	a09d                	j	80003624 <sys_munmap+0x30e>
    800035c0:	875a                	mv	a4,s6
    800035c2:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    800035c4:	4314                	lw	a3,0(a4)
    800035c6:	c699                	beqz	a3,800035d4 <sys_munmap+0x2be>
  for(int i = 0; i < NVMA; i++){
    800035c8:	2785                	addiw	a5,a5,1
    800035ca:	02870713          	addi	a4,a4,40
    800035ce:	ff779be3          	bne	a5,s7,800035c4 <sys_munmap+0x2ae>
  return -1;
    800035d2:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    800035d4:	00279593          	slli	a1,a5,0x2
    800035d8:	00f586b3          	add	a3,a1,a5
    800035dc:	068e                	slli	a3,a3,0x3
    800035de:	96d6                	add	a3,a3,s5
    800035e0:	00249613          	slli	a2,s1,0x2
    800035e4:	00960733          	add	a4,a2,s1
    800035e8:	070e                	slli	a4,a4,0x3
    800035ea:	9756                	add	a4,a4,s5
    800035ec:	16873303          	ld	t1,360(a4)
    800035f0:	17873883          	ld	a7,376(a4)
    800035f4:	18073803          	ld	a6,384(a4)
    800035f8:	18873503          	ld	a0,392(a4)
    800035fc:	1666b423          	sd	t1,360(a3) # 1168 <_entry-0x7fffee98>
    80003600:	1716bc23          	sd	a7,376(a3)
    80003604:	1906b023          	sd	a6,384(a3)
    80003608:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    8000360c:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    80003610:	17873703          	ld	a4,376(a4)
    80003614:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    80003618:	009607b3          	add	a5,a2,s1
    8000361c:	078e                	slli	a5,a5,0x3
    8000361e:	97d6                	add	a5,a5,s5
    80003620:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    80003624:	012a7763          	bgeu	s4,s2,80003632 <sys_munmap+0x31c>
  int need_splits = 0;
    80003628:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    8000362a:	84e2                	mv	s1,s8
    8000362c:	bd31                	j	80003448 <sys_munmap+0x132>
  if(len <= 0) return (uint64)-1;
    8000362e:	557d                	li	a0,-1
    80003630:	bd65                	j	800034e8 <sys_munmap+0x1d2>
  return 0;
    80003632:	4501                	li	a0,0
    80003634:	bd55                	j	800034e8 <sys_munmap+0x1d2>

0000000080003636 <sys_shmctl>:

uint64
sys_shmctl(void)
{
    80003636:	1101                	addi	sp,sp,-32
    80003638:	ec06                	sd	ra,24(sp)
    8000363a:	e822                	sd	s0,16(sp)
    8000363c:	1000                	addi	s0,sp,32
  int key, cmd;
  argint(0, &key);
    8000363e:	fec40593          	addi	a1,s0,-20
    80003642:	4501                	li	a0,0
    80003644:	f7cff0ef          	jal	ra,80002dc0 <argint>
  argint(1, &cmd);
    80003648:	fe840593          	addi	a1,s0,-24
    8000364c:	4505                	li	a0,1
    8000364e:	f72ff0ef          	jal	ra,80002dc0 <argint>
  return shm_ctl(key, cmd);
    80003652:	fe842583          	lw	a1,-24(s0)
    80003656:	fec42503          	lw	a0,-20(s0)
    8000365a:	288030ef          	jal	ra,800068e2 <shm_ctl>
}
    8000365e:	60e2                	ld	ra,24(sp)
    80003660:	6442                	ld	s0,16(sp)
    80003662:	6105                	addi	sp,sp,32
    80003664:	8082                	ret

0000000080003666 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003666:	7139                	addi	sp,sp,-64
    80003668:	fc06                	sd	ra,56(sp)
    8000366a:	f822                	sd	s0,48(sp)
    8000366c:	f426                	sd	s1,40(sp)
    8000366e:	f04a                	sd	s2,32(sp)
    80003670:	ec4e                	sd	s3,24(sp)
    80003672:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003674:	fcc40593          	addi	a1,s0,-52
    80003678:	4501                	li	a0,0
    8000367a:	f46ff0ef          	jal	ra,80002dc0 <argint>
  if(n < 0)
    8000367e:	fcc42783          	lw	a5,-52(s0)
    return -1;
    80003682:	557d                	li	a0,-1
  if(n < 0)
    80003684:	0407ce63          	bltz	a5,800036e0 <sys_sleep+0x7a>

  acquire(&tickslock);
    80003688:	0023d517          	auipc	a0,0x23d
    8000368c:	1c850513          	addi	a0,a0,456 # 80240850 <tickslock>
    80003690:	e1efd0ef          	jal	ra,80000cae <acquire>
  ticks0 = ticks;
    80003694:	00005917          	auipc	s2,0x5
    80003698:	25492903          	lw	s2,596(s2) # 800088e8 <ticks>
  while(ticks - ticks0 < n){
    8000369c:	fcc42783          	lw	a5,-52(s0)
    800036a0:	cb8d                	beqz	a5,800036d2 <sys_sleep+0x6c>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);  
    800036a2:	0023d997          	auipc	s3,0x23d
    800036a6:	1ae98993          	addi	s3,s3,430 # 80240850 <tickslock>
    800036aa:	00005497          	auipc	s1,0x5
    800036ae:	23e48493          	addi	s1,s1,574 # 800088e8 <ticks>
    if(killed(myproc())){
    800036b2:	ce6fe0ef          	jal	ra,80001b98 <myproc>
    800036b6:	80aff0ef          	jal	ra,800026c0 <killed>
    800036ba:	e915                	bnez	a0,800036ee <sys_sleep+0x88>
    sleep(&ticks, &tickslock);  
    800036bc:	85ce                	mv	a1,s3
    800036be:	8526                	mv	a0,s1
    800036c0:	dc9fe0ef          	jal	ra,80002488 <sleep>
  while(ticks - ticks0 < n){
    800036c4:	409c                	lw	a5,0(s1)
    800036c6:	412787bb          	subw	a5,a5,s2
    800036ca:	fcc42703          	lw	a4,-52(s0)
    800036ce:	fee7e2e3          	bltu	a5,a4,800036b2 <sys_sleep+0x4c>
  }
  release(&tickslock);
    800036d2:	0023d517          	auipc	a0,0x23d
    800036d6:	17e50513          	addi	a0,a0,382 # 80240850 <tickslock>
    800036da:	e6cfd0ef          	jal	ra,80000d46 <release>
  return 0;
    800036de:	4501                	li	a0,0
}
    800036e0:	70e2                	ld	ra,56(sp)
    800036e2:	7442                	ld	s0,48(sp)
    800036e4:	74a2                	ld	s1,40(sp)
    800036e6:	7902                	ld	s2,32(sp)
    800036e8:	69e2                	ld	s3,24(sp)
    800036ea:	6121                	addi	sp,sp,64
    800036ec:	8082                	ret
      release(&tickslock);
    800036ee:	0023d517          	auipc	a0,0x23d
    800036f2:	16250513          	addi	a0,a0,354 # 80240850 <tickslock>
    800036f6:	e50fd0ef          	jal	ra,80000d46 <release>
      return -1;
    800036fa:	557d                	li	a0,-1
    800036fc:	b7d5                	j	800036e0 <sys_sleep+0x7a>

00000000800036fe <sys_vmstats>:


uint64
sys_vmstats(void)
{
    800036fe:	715d                	addi	sp,sp,-80
    80003700:	e486                	sd	ra,72(sp)
    80003702:	e0a2                	sd	s0,64(sp)
    80003704:	0880                	addi	s0,sp,80
  uint64 uaddr;
  argaddr(0, &uaddr);
    80003706:	fe840593          	addi	a1,s0,-24
    8000370a:	4501                	li	a0,0
    8000370c:	ed0ff0ef          	jal	ra,80002ddc <argaddr>

  struct vmstats_user s;
  vmstats_snapshot(&s);
    80003710:	fb840513          	addi	a0,s0,-72
    80003714:	5e0030ef          	jal	ra,80006cf4 <vmstats_snapshot>

  extern uint64 kalloc_cnt, copyin_bytes, copyout_bytes;
  s.kalloc_cnt = kalloc_cnt;
    80003718:	00005797          	auipc	a5,0x5
    8000371c:	1e87b783          	ld	a5,488(a5) # 80008900 <kalloc_cnt>
    80003720:	fcf43823          	sd	a5,-48(s0)
  s.copyin_bytes = copyin_bytes;
    80003724:	00005797          	auipc	a5,0x5
    80003728:	1d47b783          	ld	a5,468(a5) # 800088f8 <copyin_bytes>
    8000372c:	fcf43c23          	sd	a5,-40(s0)
  s.copyout_bytes = copyout_bytes;
    80003730:	00005797          	auipc	a5,0x5
    80003734:	1c07b783          	ld	a5,448(a5) # 800088f0 <copyout_bytes>
    80003738:	fef43023          	sd	a5,-32(s0)

  if(copyout(myproc()->pagetable, uaddr, (char*)&s, sizeof(s)) < 0)
    8000373c:	c5cfe0ef          	jal	ra,80001b98 <myproc>
    80003740:	03000693          	li	a3,48
    80003744:	fb840613          	addi	a2,s0,-72
    80003748:	fe843583          	ld	a1,-24(s0)
    8000374c:	6928                	ld	a0,80(a0)
    8000374e:	83afe0ef          	jal	ra,80001788 <copyout>
    return -1;
  return 0;
    80003752:	957d                	srai	a0,a0,0x3f
    80003754:	60a6                	ld	ra,72(sp)
    80003756:	6406                	ld	s0,64(sp)
    80003758:	6161                	addi	sp,sp,80
    8000375a:	8082                	ret

000000008000375c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000375c:	7179                	addi	sp,sp,-48
    8000375e:	f406                	sd	ra,40(sp)
    80003760:	f022                	sd	s0,32(sp)
    80003762:	ec26                	sd	s1,24(sp)
    80003764:	e84a                	sd	s2,16(sp)
    80003766:	e44e                	sd	s3,8(sp)
    80003768:	e052                	sd	s4,0(sp)
    8000376a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000376c:	00005597          	auipc	a1,0x5
    80003770:	d7c58593          	addi	a1,a1,-644 # 800084e8 <syscalls+0xf0>
    80003774:	0023d517          	auipc	a0,0x23d
    80003778:	0f450513          	addi	a0,a0,244 # 80240868 <bcache>
    8000377c:	cb2fd0ef          	jal	ra,80000c2e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003780:	00245797          	auipc	a5,0x245
    80003784:	0e878793          	addi	a5,a5,232 # 80248868 <bcache+0x8000>
    80003788:	00245717          	auipc	a4,0x245
    8000378c:	34870713          	addi	a4,a4,840 # 80248ad0 <bcache+0x8268>
    80003790:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003794:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003798:	0023d497          	auipc	s1,0x23d
    8000379c:	0e848493          	addi	s1,s1,232 # 80240880 <bcache+0x18>
    b->next = bcache.head.next;
    800037a0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800037a2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800037a4:	00005a17          	auipc	s4,0x5
    800037a8:	d4ca0a13          	addi	s4,s4,-692 # 800084f0 <syscalls+0xf8>
    b->next = bcache.head.next;
    800037ac:	2b893783          	ld	a5,696(s2)
    800037b0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800037b2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800037b6:	85d2                	mv	a1,s4
    800037b8:	01048513          	addi	a0,s1,16
    800037bc:	302010ef          	jal	ra,80004abe <initsleeplock>
    bcache.head.next->prev = b;
    800037c0:	2b893783          	ld	a5,696(s2)
    800037c4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800037c6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037ca:	45848493          	addi	s1,s1,1112
    800037ce:	fd349fe3          	bne	s1,s3,800037ac <binit+0x50>
  }
}
    800037d2:	70a2                	ld	ra,40(sp)
    800037d4:	7402                	ld	s0,32(sp)
    800037d6:	64e2                	ld	s1,24(sp)
    800037d8:	6942                	ld	s2,16(sp)
    800037da:	69a2                	ld	s3,8(sp)
    800037dc:	6a02                	ld	s4,0(sp)
    800037de:	6145                	addi	sp,sp,48
    800037e0:	8082                	ret

00000000800037e2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800037e2:	7179                	addi	sp,sp,-48
    800037e4:	f406                	sd	ra,40(sp)
    800037e6:	f022                	sd	s0,32(sp)
    800037e8:	ec26                	sd	s1,24(sp)
    800037ea:	e84a                	sd	s2,16(sp)
    800037ec:	e44e                	sd	s3,8(sp)
    800037ee:	1800                	addi	s0,sp,48
    800037f0:	892a                	mv	s2,a0
    800037f2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800037f4:	0023d517          	auipc	a0,0x23d
    800037f8:	07450513          	addi	a0,a0,116 # 80240868 <bcache>
    800037fc:	cb2fd0ef          	jal	ra,80000cae <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003800:	00245497          	auipc	s1,0x245
    80003804:	3204b483          	ld	s1,800(s1) # 80248b20 <bcache+0x82b8>
    80003808:	00245797          	auipc	a5,0x245
    8000380c:	2c878793          	addi	a5,a5,712 # 80248ad0 <bcache+0x8268>
    80003810:	02f48b63          	beq	s1,a5,80003846 <bread+0x64>
    80003814:	873e                	mv	a4,a5
    80003816:	a021                	j	8000381e <bread+0x3c>
    80003818:	68a4                	ld	s1,80(s1)
    8000381a:	02e48663          	beq	s1,a4,80003846 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000381e:	449c                	lw	a5,8(s1)
    80003820:	ff279ce3          	bne	a5,s2,80003818 <bread+0x36>
    80003824:	44dc                	lw	a5,12(s1)
    80003826:	ff3799e3          	bne	a5,s3,80003818 <bread+0x36>
      b->refcnt++;
    8000382a:	40bc                	lw	a5,64(s1)
    8000382c:	2785                	addiw	a5,a5,1
    8000382e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003830:	0023d517          	auipc	a0,0x23d
    80003834:	03850513          	addi	a0,a0,56 # 80240868 <bcache>
    80003838:	d0efd0ef          	jal	ra,80000d46 <release>
      acquiresleep(&b->lock);
    8000383c:	01048513          	addi	a0,s1,16
    80003840:	2b4010ef          	jal	ra,80004af4 <acquiresleep>
      return b;
    80003844:	a889                	j	80003896 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003846:	00245497          	auipc	s1,0x245
    8000384a:	2d24b483          	ld	s1,722(s1) # 80248b18 <bcache+0x82b0>
    8000384e:	00245797          	auipc	a5,0x245
    80003852:	28278793          	addi	a5,a5,642 # 80248ad0 <bcache+0x8268>
    80003856:	00f48863          	beq	s1,a5,80003866 <bread+0x84>
    8000385a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000385c:	40bc                	lw	a5,64(s1)
    8000385e:	cb91                	beqz	a5,80003872 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003860:	64a4                	ld	s1,72(s1)
    80003862:	fee49de3          	bne	s1,a4,8000385c <bread+0x7a>
  panic("bget: no buffers");
    80003866:	00005517          	auipc	a0,0x5
    8000386a:	c9250513          	addi	a0,a0,-878 # 800084f8 <syscalls+0x100>
    8000386e:	f1bfc0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    80003872:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003876:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000387a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000387e:	4785                	li	a5,1
    80003880:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003882:	0023d517          	auipc	a0,0x23d
    80003886:	fe650513          	addi	a0,a0,-26 # 80240868 <bcache>
    8000388a:	cbcfd0ef          	jal	ra,80000d46 <release>
      acquiresleep(&b->lock);
    8000388e:	01048513          	addi	a0,s1,16
    80003892:	262010ef          	jal	ra,80004af4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003896:	409c                	lw	a5,0(s1)
    80003898:	cb89                	beqz	a5,800038aa <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000389a:	8526                	mv	a0,s1
    8000389c:	70a2                	ld	ra,40(sp)
    8000389e:	7402                	ld	s0,32(sp)
    800038a0:	64e2                	ld	s1,24(sp)
    800038a2:	6942                	ld	s2,16(sp)
    800038a4:	69a2                	ld	s3,8(sp)
    800038a6:	6145                	addi	sp,sp,48
    800038a8:	8082                	ret
    virtio_disk_rw(b, 0);
    800038aa:	4581                	li	a1,0
    800038ac:	8526                	mv	a0,s1
    800038ae:	21d020ef          	jal	ra,800062ca <virtio_disk_rw>
    b->valid = 1;
    800038b2:	4785                	li	a5,1
    800038b4:	c09c                	sw	a5,0(s1)
  return b;
    800038b6:	b7d5                	j	8000389a <bread+0xb8>

00000000800038b8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800038b8:	1101                	addi	sp,sp,-32
    800038ba:	ec06                	sd	ra,24(sp)
    800038bc:	e822                	sd	s0,16(sp)
    800038be:	e426                	sd	s1,8(sp)
    800038c0:	1000                	addi	s0,sp,32
    800038c2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038c4:	0541                	addi	a0,a0,16
    800038c6:	2ac010ef          	jal	ra,80004b72 <holdingsleep>
    800038ca:	c911                	beqz	a0,800038de <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800038cc:	4585                	li	a1,1
    800038ce:	8526                	mv	a0,s1
    800038d0:	1fb020ef          	jal	ra,800062ca <virtio_disk_rw>
}
    800038d4:	60e2                	ld	ra,24(sp)
    800038d6:	6442                	ld	s0,16(sp)
    800038d8:	64a2                	ld	s1,8(sp)
    800038da:	6105                	addi	sp,sp,32
    800038dc:	8082                	ret
    panic("bwrite");
    800038de:	00005517          	auipc	a0,0x5
    800038e2:	c3250513          	addi	a0,a0,-974 # 80008510 <syscalls+0x118>
    800038e6:	ea3fc0ef          	jal	ra,80000788 <panic>

00000000800038ea <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800038ea:	1101                	addi	sp,sp,-32
    800038ec:	ec06                	sd	ra,24(sp)
    800038ee:	e822                	sd	s0,16(sp)
    800038f0:	e426                	sd	s1,8(sp)
    800038f2:	e04a                	sd	s2,0(sp)
    800038f4:	1000                	addi	s0,sp,32
    800038f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038f8:	01050913          	addi	s2,a0,16
    800038fc:	854a                	mv	a0,s2
    800038fe:	274010ef          	jal	ra,80004b72 <holdingsleep>
    80003902:	c13d                	beqz	a0,80003968 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80003904:	854a                	mv	a0,s2
    80003906:	234010ef          	jal	ra,80004b3a <releasesleep>

  acquire(&bcache.lock);
    8000390a:	0023d517          	auipc	a0,0x23d
    8000390e:	f5e50513          	addi	a0,a0,-162 # 80240868 <bcache>
    80003912:	b9cfd0ef          	jal	ra,80000cae <acquire>
  b->refcnt--;
    80003916:	40bc                	lw	a5,64(s1)
    80003918:	37fd                	addiw	a5,a5,-1
    8000391a:	0007871b          	sext.w	a4,a5
    8000391e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003920:	eb05                	bnez	a4,80003950 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003922:	68bc                	ld	a5,80(s1)
    80003924:	64b8                	ld	a4,72(s1)
    80003926:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003928:	64bc                	ld	a5,72(s1)
    8000392a:	68b8                	ld	a4,80(s1)
    8000392c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000392e:	00245797          	auipc	a5,0x245
    80003932:	f3a78793          	addi	a5,a5,-198 # 80248868 <bcache+0x8000>
    80003936:	2b87b703          	ld	a4,696(a5)
    8000393a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000393c:	00245717          	auipc	a4,0x245
    80003940:	19470713          	addi	a4,a4,404 # 80248ad0 <bcache+0x8268>
    80003944:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003946:	2b87b703          	ld	a4,696(a5)
    8000394a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000394c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003950:	0023d517          	auipc	a0,0x23d
    80003954:	f1850513          	addi	a0,a0,-232 # 80240868 <bcache>
    80003958:	beefd0ef          	jal	ra,80000d46 <release>
}
    8000395c:	60e2                	ld	ra,24(sp)
    8000395e:	6442                	ld	s0,16(sp)
    80003960:	64a2                	ld	s1,8(sp)
    80003962:	6902                	ld	s2,0(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret
    panic("brelse");
    80003968:	00005517          	auipc	a0,0x5
    8000396c:	bb050513          	addi	a0,a0,-1104 # 80008518 <syscalls+0x120>
    80003970:	e19fc0ef          	jal	ra,80000788 <panic>

0000000080003974 <bpin>:

void
bpin(struct buf *b) {
    80003974:	1101                	addi	sp,sp,-32
    80003976:	ec06                	sd	ra,24(sp)
    80003978:	e822                	sd	s0,16(sp)
    8000397a:	e426                	sd	s1,8(sp)
    8000397c:	1000                	addi	s0,sp,32
    8000397e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003980:	0023d517          	auipc	a0,0x23d
    80003984:	ee850513          	addi	a0,a0,-280 # 80240868 <bcache>
    80003988:	b26fd0ef          	jal	ra,80000cae <acquire>
  b->refcnt++;
    8000398c:	40bc                	lw	a5,64(s1)
    8000398e:	2785                	addiw	a5,a5,1
    80003990:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003992:	0023d517          	auipc	a0,0x23d
    80003996:	ed650513          	addi	a0,a0,-298 # 80240868 <bcache>
    8000399a:	bacfd0ef          	jal	ra,80000d46 <release>
}
    8000399e:	60e2                	ld	ra,24(sp)
    800039a0:	6442                	ld	s0,16(sp)
    800039a2:	64a2                	ld	s1,8(sp)
    800039a4:	6105                	addi	sp,sp,32
    800039a6:	8082                	ret

00000000800039a8 <bunpin>:

void
bunpin(struct buf *b) {
    800039a8:	1101                	addi	sp,sp,-32
    800039aa:	ec06                	sd	ra,24(sp)
    800039ac:	e822                	sd	s0,16(sp)
    800039ae:	e426                	sd	s1,8(sp)
    800039b0:	1000                	addi	s0,sp,32
    800039b2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039b4:	0023d517          	auipc	a0,0x23d
    800039b8:	eb450513          	addi	a0,a0,-332 # 80240868 <bcache>
    800039bc:	af2fd0ef          	jal	ra,80000cae <acquire>
  b->refcnt--;
    800039c0:	40bc                	lw	a5,64(s1)
    800039c2:	37fd                	addiw	a5,a5,-1
    800039c4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039c6:	0023d517          	auipc	a0,0x23d
    800039ca:	ea250513          	addi	a0,a0,-350 # 80240868 <bcache>
    800039ce:	b78fd0ef          	jal	ra,80000d46 <release>
}
    800039d2:	60e2                	ld	ra,24(sp)
    800039d4:	6442                	ld	s0,16(sp)
    800039d6:	64a2                	ld	s1,8(sp)
    800039d8:	6105                	addi	sp,sp,32
    800039da:	8082                	ret

00000000800039dc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800039dc:	1101                	addi	sp,sp,-32
    800039de:	ec06                	sd	ra,24(sp)
    800039e0:	e822                	sd	s0,16(sp)
    800039e2:	e426                	sd	s1,8(sp)
    800039e4:	e04a                	sd	s2,0(sp)
    800039e6:	1000                	addi	s0,sp,32
    800039e8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800039ea:	00d5d59b          	srliw	a1,a1,0xd
    800039ee:	00245797          	auipc	a5,0x245
    800039f2:	5567a783          	lw	a5,1366(a5) # 80248f44 <sb+0x1c>
    800039f6:	9dbd                	addw	a1,a1,a5
    800039f8:	debff0ef          	jal	ra,800037e2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800039fc:	0074f713          	andi	a4,s1,7
    80003a00:	4785                	li	a5,1
    80003a02:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a06:	14ce                	slli	s1,s1,0x33
    80003a08:	90d9                	srli	s1,s1,0x36
    80003a0a:	00950733          	add	a4,a0,s1
    80003a0e:	05874703          	lbu	a4,88(a4)
    80003a12:	00e7f6b3          	and	a3,a5,a4
    80003a16:	c29d                	beqz	a3,80003a3c <bfree+0x60>
    80003a18:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a1a:	94aa                	add	s1,s1,a0
    80003a1c:	fff7c793          	not	a5,a5
    80003a20:	8f7d                	and	a4,a4,a5
    80003a22:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003a26:	7d7000ef          	jal	ra,800049fc <log_write>
  brelse(bp);
    80003a2a:	854a                	mv	a0,s2
    80003a2c:	ebfff0ef          	jal	ra,800038ea <brelse>
}
    80003a30:	60e2                	ld	ra,24(sp)
    80003a32:	6442                	ld	s0,16(sp)
    80003a34:	64a2                	ld	s1,8(sp)
    80003a36:	6902                	ld	s2,0(sp)
    80003a38:	6105                	addi	sp,sp,32
    80003a3a:	8082                	ret
    panic("freeing free block");
    80003a3c:	00005517          	auipc	a0,0x5
    80003a40:	ae450513          	addi	a0,a0,-1308 # 80008520 <syscalls+0x128>
    80003a44:	d45fc0ef          	jal	ra,80000788 <panic>

0000000080003a48 <balloc>:
{
    80003a48:	711d                	addi	sp,sp,-96
    80003a4a:	ec86                	sd	ra,88(sp)
    80003a4c:	e8a2                	sd	s0,80(sp)
    80003a4e:	e4a6                	sd	s1,72(sp)
    80003a50:	e0ca                	sd	s2,64(sp)
    80003a52:	fc4e                	sd	s3,56(sp)
    80003a54:	f852                	sd	s4,48(sp)
    80003a56:	f456                	sd	s5,40(sp)
    80003a58:	f05a                	sd	s6,32(sp)
    80003a5a:	ec5e                	sd	s7,24(sp)
    80003a5c:	e862                	sd	s8,16(sp)
    80003a5e:	e466                	sd	s9,8(sp)
    80003a60:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a62:	00245797          	auipc	a5,0x245
    80003a66:	4ca7a783          	lw	a5,1226(a5) # 80248f2c <sb+0x4>
    80003a6a:	cff1                	beqz	a5,80003b46 <balloc+0xfe>
    80003a6c:	8baa                	mv	s7,a0
    80003a6e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a70:	00245b17          	auipc	s6,0x245
    80003a74:	4b8b0b13          	addi	s6,s6,1208 # 80248f28 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a78:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a7a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a7c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a7e:	6c89                	lui	s9,0x2
    80003a80:	a0b5                	j	80003aec <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a82:	97ca                	add	a5,a5,s2
    80003a84:	8e55                	or	a2,a2,a3
    80003a86:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003a8a:	854a                	mv	a0,s2
    80003a8c:	771000ef          	jal	ra,800049fc <log_write>
        brelse(bp);
    80003a90:	854a                	mv	a0,s2
    80003a92:	e59ff0ef          	jal	ra,800038ea <brelse>
  bp = bread(dev, bno);
    80003a96:	85a6                	mv	a1,s1
    80003a98:	855e                	mv	a0,s7
    80003a9a:	d49ff0ef          	jal	ra,800037e2 <bread>
    80003a9e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003aa0:	40000613          	li	a2,1024
    80003aa4:	4581                	li	a1,0
    80003aa6:	05850513          	addi	a0,a0,88
    80003aaa:	ad8fd0ef          	jal	ra,80000d82 <memset>
  log_write(bp);
    80003aae:	854a                	mv	a0,s2
    80003ab0:	74d000ef          	jal	ra,800049fc <log_write>
  brelse(bp);
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	e35ff0ef          	jal	ra,800038ea <brelse>
}
    80003aba:	8526                	mv	a0,s1
    80003abc:	60e6                	ld	ra,88(sp)
    80003abe:	6446                	ld	s0,80(sp)
    80003ac0:	64a6                	ld	s1,72(sp)
    80003ac2:	6906                	ld	s2,64(sp)
    80003ac4:	79e2                	ld	s3,56(sp)
    80003ac6:	7a42                	ld	s4,48(sp)
    80003ac8:	7aa2                	ld	s5,40(sp)
    80003aca:	7b02                	ld	s6,32(sp)
    80003acc:	6be2                	ld	s7,24(sp)
    80003ace:	6c42                	ld	s8,16(sp)
    80003ad0:	6ca2                	ld	s9,8(sp)
    80003ad2:	6125                	addi	sp,sp,96
    80003ad4:	8082                	ret
    brelse(bp);
    80003ad6:	854a                	mv	a0,s2
    80003ad8:	e13ff0ef          	jal	ra,800038ea <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003adc:	015c87bb          	addw	a5,s9,s5
    80003ae0:	00078a9b          	sext.w	s5,a5
    80003ae4:	004b2703          	lw	a4,4(s6)
    80003ae8:	04eaff63          	bgeu	s5,a4,80003b46 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80003aec:	41fad79b          	sraiw	a5,s5,0x1f
    80003af0:	0137d79b          	srliw	a5,a5,0x13
    80003af4:	015787bb          	addw	a5,a5,s5
    80003af8:	40d7d79b          	sraiw	a5,a5,0xd
    80003afc:	01cb2583          	lw	a1,28(s6)
    80003b00:	9dbd                	addw	a1,a1,a5
    80003b02:	855e                	mv	a0,s7
    80003b04:	cdfff0ef          	jal	ra,800037e2 <bread>
    80003b08:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b0a:	004b2503          	lw	a0,4(s6)
    80003b0e:	000a849b          	sext.w	s1,s5
    80003b12:	8762                	mv	a4,s8
    80003b14:	fca4f1e3          	bgeu	s1,a0,80003ad6 <balloc+0x8e>
      m = 1 << (bi % 8);
    80003b18:	00777693          	andi	a3,a4,7
    80003b1c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b20:	41f7579b          	sraiw	a5,a4,0x1f
    80003b24:	01d7d79b          	srliw	a5,a5,0x1d
    80003b28:	9fb9                	addw	a5,a5,a4
    80003b2a:	4037d79b          	sraiw	a5,a5,0x3
    80003b2e:	00f90633          	add	a2,s2,a5
    80003b32:	05864603          	lbu	a2,88(a2)
    80003b36:	00c6f5b3          	and	a1,a3,a2
    80003b3a:	d5a1                	beqz	a1,80003a82 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b3c:	2705                	addiw	a4,a4,1
    80003b3e:	2485                	addiw	s1,s1,1
    80003b40:	fd471ae3          	bne	a4,s4,80003b14 <balloc+0xcc>
    80003b44:	bf49                	j	80003ad6 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003b46:	00005517          	auipc	a0,0x5
    80003b4a:	9f250513          	addi	a0,a0,-1550 # 80008538 <syscalls+0x140>
    80003b4e:	975fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003b52:	4481                	li	s1,0
    80003b54:	b79d                	j	80003aba <balloc+0x72>

0000000080003b56 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b56:	7179                	addi	sp,sp,-48
    80003b58:	f406                	sd	ra,40(sp)
    80003b5a:	f022                	sd	s0,32(sp)
    80003b5c:	ec26                	sd	s1,24(sp)
    80003b5e:	e84a                	sd	s2,16(sp)
    80003b60:	e44e                	sd	s3,8(sp)
    80003b62:	e052                	sd	s4,0(sp)
    80003b64:	1800                	addi	s0,sp,48
    80003b66:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b68:	47ad                	li	a5,11
    80003b6a:	02b7e663          	bltu	a5,a1,80003b96 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80003b6e:	02059793          	slli	a5,a1,0x20
    80003b72:	01e7d593          	srli	a1,a5,0x1e
    80003b76:	00b504b3          	add	s1,a0,a1
    80003b7a:	0504a903          	lw	s2,80(s1)
    80003b7e:	06091663          	bnez	s2,80003bea <bmap+0x94>
      addr = balloc(ip->dev);
    80003b82:	4108                	lw	a0,0(a0)
    80003b84:	ec5ff0ef          	jal	ra,80003a48 <balloc>
    80003b88:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b8c:	04090f63          	beqz	s2,80003bea <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80003b90:	0524a823          	sw	s2,80(s1)
    80003b94:	a899                	j	80003bea <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b96:	ff45849b          	addiw	s1,a1,-12
    80003b9a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003b9e:	0ff00793          	li	a5,255
    80003ba2:	06e7eb63          	bltu	a5,a4,80003c18 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003ba6:	08052903          	lw	s2,128(a0)
    80003baa:	00091b63          	bnez	s2,80003bc0 <bmap+0x6a>
      addr = balloc(ip->dev);
    80003bae:	4108                	lw	a0,0(a0)
    80003bb0:	e99ff0ef          	jal	ra,80003a48 <balloc>
    80003bb4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bb8:	02090963          	beqz	s2,80003bea <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003bbc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003bc0:	85ca                	mv	a1,s2
    80003bc2:	0009a503          	lw	a0,0(s3)
    80003bc6:	c1dff0ef          	jal	ra,800037e2 <bread>
    80003bca:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bcc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bd0:	02049713          	slli	a4,s1,0x20
    80003bd4:	01e75593          	srli	a1,a4,0x1e
    80003bd8:	00b784b3          	add	s1,a5,a1
    80003bdc:	0004a903          	lw	s2,0(s1)
    80003be0:	00090e63          	beqz	s2,80003bfc <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003be4:	8552                	mv	a0,s4
    80003be6:	d05ff0ef          	jal	ra,800038ea <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003bea:	854a                	mv	a0,s2
    80003bec:	70a2                	ld	ra,40(sp)
    80003bee:	7402                	ld	s0,32(sp)
    80003bf0:	64e2                	ld	s1,24(sp)
    80003bf2:	6942                	ld	s2,16(sp)
    80003bf4:	69a2                	ld	s3,8(sp)
    80003bf6:	6a02                	ld	s4,0(sp)
    80003bf8:	6145                	addi	sp,sp,48
    80003bfa:	8082                	ret
      addr = balloc(ip->dev);
    80003bfc:	0009a503          	lw	a0,0(s3)
    80003c00:	e49ff0ef          	jal	ra,80003a48 <balloc>
    80003c04:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c08:	fc090ee3          	beqz	s2,80003be4 <bmap+0x8e>
        a[bn] = addr;
    80003c0c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c10:	8552                	mv	a0,s4
    80003c12:	5eb000ef          	jal	ra,800049fc <log_write>
    80003c16:	b7f9                	j	80003be4 <bmap+0x8e>
  panic("bmap: out of range");
    80003c18:	00005517          	auipc	a0,0x5
    80003c1c:	93850513          	addi	a0,a0,-1736 # 80008550 <syscalls+0x158>
    80003c20:	b69fc0ef          	jal	ra,80000788 <panic>

0000000080003c24 <iget>:
{
    80003c24:	7179                	addi	sp,sp,-48
    80003c26:	f406                	sd	ra,40(sp)
    80003c28:	f022                	sd	s0,32(sp)
    80003c2a:	ec26                	sd	s1,24(sp)
    80003c2c:	e84a                	sd	s2,16(sp)
    80003c2e:	e44e                	sd	s3,8(sp)
    80003c30:	e052                	sd	s4,0(sp)
    80003c32:	1800                	addi	s0,sp,48
    80003c34:	89aa                	mv	s3,a0
    80003c36:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c38:	00245517          	auipc	a0,0x245
    80003c3c:	31050513          	addi	a0,a0,784 # 80248f48 <itable>
    80003c40:	86efd0ef          	jal	ra,80000cae <acquire>
  empty = 0;
    80003c44:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c46:	00245497          	auipc	s1,0x245
    80003c4a:	31a48493          	addi	s1,s1,794 # 80248f60 <itable+0x18>
    80003c4e:	00247697          	auipc	a3,0x247
    80003c52:	da268693          	addi	a3,a3,-606 # 8024a9f0 <log>
    80003c56:	a039                	j	80003c64 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c58:	02090963          	beqz	s2,80003c8a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c5c:	08848493          	addi	s1,s1,136
    80003c60:	02d48863          	beq	s1,a3,80003c90 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c64:	449c                	lw	a5,8(s1)
    80003c66:	fef059e3          	blez	a5,80003c58 <iget+0x34>
    80003c6a:	4098                	lw	a4,0(s1)
    80003c6c:	ff3716e3          	bne	a4,s3,80003c58 <iget+0x34>
    80003c70:	40d8                	lw	a4,4(s1)
    80003c72:	ff4713e3          	bne	a4,s4,80003c58 <iget+0x34>
      ip->ref++;
    80003c76:	2785                	addiw	a5,a5,1
    80003c78:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c7a:	00245517          	auipc	a0,0x245
    80003c7e:	2ce50513          	addi	a0,a0,718 # 80248f48 <itable>
    80003c82:	8c4fd0ef          	jal	ra,80000d46 <release>
      return ip;
    80003c86:	8926                	mv	s2,s1
    80003c88:	a02d                	j	80003cb2 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c8a:	fbe9                	bnez	a5,80003c5c <iget+0x38>
    80003c8c:	8926                	mv	s2,s1
    80003c8e:	b7f9                	j	80003c5c <iget+0x38>
  if(empty == 0)
    80003c90:	02090a63          	beqz	s2,80003cc4 <iget+0xa0>
  ip->dev = dev;
    80003c94:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c98:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c9c:	4785                	li	a5,1
    80003c9e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ca2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ca6:	00245517          	auipc	a0,0x245
    80003caa:	2a250513          	addi	a0,a0,674 # 80248f48 <itable>
    80003cae:	898fd0ef          	jal	ra,80000d46 <release>
}
    80003cb2:	854a                	mv	a0,s2
    80003cb4:	70a2                	ld	ra,40(sp)
    80003cb6:	7402                	ld	s0,32(sp)
    80003cb8:	64e2                	ld	s1,24(sp)
    80003cba:	6942                	ld	s2,16(sp)
    80003cbc:	69a2                	ld	s3,8(sp)
    80003cbe:	6a02                	ld	s4,0(sp)
    80003cc0:	6145                	addi	sp,sp,48
    80003cc2:	8082                	ret
    panic("iget: no inodes");
    80003cc4:	00005517          	auipc	a0,0x5
    80003cc8:	8a450513          	addi	a0,a0,-1884 # 80008568 <syscalls+0x170>
    80003ccc:	abdfc0ef          	jal	ra,80000788 <panic>

0000000080003cd0 <iinit>:
{
    80003cd0:	7179                	addi	sp,sp,-48
    80003cd2:	f406                	sd	ra,40(sp)
    80003cd4:	f022                	sd	s0,32(sp)
    80003cd6:	ec26                	sd	s1,24(sp)
    80003cd8:	e84a                	sd	s2,16(sp)
    80003cda:	e44e                	sd	s3,8(sp)
    80003cdc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003cde:	00005597          	auipc	a1,0x5
    80003ce2:	89a58593          	addi	a1,a1,-1894 # 80008578 <syscalls+0x180>
    80003ce6:	00245517          	auipc	a0,0x245
    80003cea:	26250513          	addi	a0,a0,610 # 80248f48 <itable>
    80003cee:	f41fc0ef          	jal	ra,80000c2e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003cf2:	00245497          	auipc	s1,0x245
    80003cf6:	27e48493          	addi	s1,s1,638 # 80248f70 <itable+0x28>
    80003cfa:	00247997          	auipc	s3,0x247
    80003cfe:	d0698993          	addi	s3,s3,-762 # 8024aa00 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d02:	00005917          	auipc	s2,0x5
    80003d06:	87e90913          	addi	s2,s2,-1922 # 80008580 <syscalls+0x188>
    80003d0a:	85ca                	mv	a1,s2
    80003d0c:	8526                	mv	a0,s1
    80003d0e:	5b1000ef          	jal	ra,80004abe <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d12:	08848493          	addi	s1,s1,136
    80003d16:	ff349ae3          	bne	s1,s3,80003d0a <iinit+0x3a>
}
    80003d1a:	70a2                	ld	ra,40(sp)
    80003d1c:	7402                	ld	s0,32(sp)
    80003d1e:	64e2                	ld	s1,24(sp)
    80003d20:	6942                	ld	s2,16(sp)
    80003d22:	69a2                	ld	s3,8(sp)
    80003d24:	6145                	addi	sp,sp,48
    80003d26:	8082                	ret

0000000080003d28 <ialloc>:
{
    80003d28:	715d                	addi	sp,sp,-80
    80003d2a:	e486                	sd	ra,72(sp)
    80003d2c:	e0a2                	sd	s0,64(sp)
    80003d2e:	fc26                	sd	s1,56(sp)
    80003d30:	f84a                	sd	s2,48(sp)
    80003d32:	f44e                	sd	s3,40(sp)
    80003d34:	f052                	sd	s4,32(sp)
    80003d36:	ec56                	sd	s5,24(sp)
    80003d38:	e85a                	sd	s6,16(sp)
    80003d3a:	e45e                	sd	s7,8(sp)
    80003d3c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d3e:	00245717          	auipc	a4,0x245
    80003d42:	1f672703          	lw	a4,502(a4) # 80248f34 <sb+0xc>
    80003d46:	4785                	li	a5,1
    80003d48:	04e7f663          	bgeu	a5,a4,80003d94 <ialloc+0x6c>
    80003d4c:	8aaa                	mv	s5,a0
    80003d4e:	8bae                	mv	s7,a1
    80003d50:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d52:	00245a17          	auipc	s4,0x245
    80003d56:	1d6a0a13          	addi	s4,s4,470 # 80248f28 <sb>
    80003d5a:	00048b1b          	sext.w	s6,s1
    80003d5e:	0044d593          	srli	a1,s1,0x4
    80003d62:	018a2783          	lw	a5,24(s4)
    80003d66:	9dbd                	addw	a1,a1,a5
    80003d68:	8556                	mv	a0,s5
    80003d6a:	a79ff0ef          	jal	ra,800037e2 <bread>
    80003d6e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d70:	05850993          	addi	s3,a0,88
    80003d74:	00f4f793          	andi	a5,s1,15
    80003d78:	079a                	slli	a5,a5,0x6
    80003d7a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d7c:	00099783          	lh	a5,0(s3)
    80003d80:	cf85                	beqz	a5,80003db8 <ialloc+0x90>
    brelse(bp);
    80003d82:	b69ff0ef          	jal	ra,800038ea <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d86:	0485                	addi	s1,s1,1
    80003d88:	00ca2703          	lw	a4,12(s4)
    80003d8c:	0004879b          	sext.w	a5,s1
    80003d90:	fce7e5e3          	bltu	a5,a4,80003d5a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d94:	00004517          	auipc	a0,0x4
    80003d98:	7f450513          	addi	a0,a0,2036 # 80008588 <syscalls+0x190>
    80003d9c:	f26fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003da0:	4501                	li	a0,0
}
    80003da2:	60a6                	ld	ra,72(sp)
    80003da4:	6406                	ld	s0,64(sp)
    80003da6:	74e2                	ld	s1,56(sp)
    80003da8:	7942                	ld	s2,48(sp)
    80003daa:	79a2                	ld	s3,40(sp)
    80003dac:	7a02                	ld	s4,32(sp)
    80003dae:	6ae2                	ld	s5,24(sp)
    80003db0:	6b42                	ld	s6,16(sp)
    80003db2:	6ba2                	ld	s7,8(sp)
    80003db4:	6161                	addi	sp,sp,80
    80003db6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003db8:	04000613          	li	a2,64
    80003dbc:	4581                	li	a1,0
    80003dbe:	854e                	mv	a0,s3
    80003dc0:	fc3fc0ef          	jal	ra,80000d82 <memset>
      dip->type = type;
    80003dc4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003dc8:	854a                	mv	a0,s2
    80003dca:	433000ef          	jal	ra,800049fc <log_write>
      brelse(bp);
    80003dce:	854a                	mv	a0,s2
    80003dd0:	b1bff0ef          	jal	ra,800038ea <brelse>
      return iget(dev, inum);
    80003dd4:	85da                	mv	a1,s6
    80003dd6:	8556                	mv	a0,s5
    80003dd8:	e4dff0ef          	jal	ra,80003c24 <iget>
    80003ddc:	b7d9                	j	80003da2 <ialloc+0x7a>

0000000080003dde <iupdate>:
{
    80003dde:	1101                	addi	sp,sp,-32
    80003de0:	ec06                	sd	ra,24(sp)
    80003de2:	e822                	sd	s0,16(sp)
    80003de4:	e426                	sd	s1,8(sp)
    80003de6:	e04a                	sd	s2,0(sp)
    80003de8:	1000                	addi	s0,sp,32
    80003dea:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dec:	415c                	lw	a5,4(a0)
    80003dee:	0047d79b          	srliw	a5,a5,0x4
    80003df2:	00245597          	auipc	a1,0x245
    80003df6:	14e5a583          	lw	a1,334(a1) # 80248f40 <sb+0x18>
    80003dfa:	9dbd                	addw	a1,a1,a5
    80003dfc:	4108                	lw	a0,0(a0)
    80003dfe:	9e5ff0ef          	jal	ra,800037e2 <bread>
    80003e02:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e04:	05850793          	addi	a5,a0,88
    80003e08:	40d8                	lw	a4,4(s1)
    80003e0a:	8b3d                	andi	a4,a4,15
    80003e0c:	071a                	slli	a4,a4,0x6
    80003e0e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003e10:	04449703          	lh	a4,68(s1)
    80003e14:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003e18:	04649703          	lh	a4,70(s1)
    80003e1c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003e20:	04849703          	lh	a4,72(s1)
    80003e24:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003e28:	04a49703          	lh	a4,74(s1)
    80003e2c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003e30:	44f8                	lw	a4,76(s1)
    80003e32:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e34:	03400613          	li	a2,52
    80003e38:	05048593          	addi	a1,s1,80
    80003e3c:	00c78513          	addi	a0,a5,12
    80003e40:	f9ffc0ef          	jal	ra,80000dde <memmove>
  log_write(bp);
    80003e44:	854a                	mv	a0,s2
    80003e46:	3b7000ef          	jal	ra,800049fc <log_write>
  brelse(bp);
    80003e4a:	854a                	mv	a0,s2
    80003e4c:	a9fff0ef          	jal	ra,800038ea <brelse>
}
    80003e50:	60e2                	ld	ra,24(sp)
    80003e52:	6442                	ld	s0,16(sp)
    80003e54:	64a2                	ld	s1,8(sp)
    80003e56:	6902                	ld	s2,0(sp)
    80003e58:	6105                	addi	sp,sp,32
    80003e5a:	8082                	ret

0000000080003e5c <idup>:
{
    80003e5c:	1101                	addi	sp,sp,-32
    80003e5e:	ec06                	sd	ra,24(sp)
    80003e60:	e822                	sd	s0,16(sp)
    80003e62:	e426                	sd	s1,8(sp)
    80003e64:	1000                	addi	s0,sp,32
    80003e66:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e68:	00245517          	auipc	a0,0x245
    80003e6c:	0e050513          	addi	a0,a0,224 # 80248f48 <itable>
    80003e70:	e3ffc0ef          	jal	ra,80000cae <acquire>
  ip->ref++;
    80003e74:	449c                	lw	a5,8(s1)
    80003e76:	2785                	addiw	a5,a5,1
    80003e78:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e7a:	00245517          	auipc	a0,0x245
    80003e7e:	0ce50513          	addi	a0,a0,206 # 80248f48 <itable>
    80003e82:	ec5fc0ef          	jal	ra,80000d46 <release>
}
    80003e86:	8526                	mv	a0,s1
    80003e88:	60e2                	ld	ra,24(sp)
    80003e8a:	6442                	ld	s0,16(sp)
    80003e8c:	64a2                	ld	s1,8(sp)
    80003e8e:	6105                	addi	sp,sp,32
    80003e90:	8082                	ret

0000000080003e92 <ilock>:
{
    80003e92:	1101                	addi	sp,sp,-32
    80003e94:	ec06                	sd	ra,24(sp)
    80003e96:	e822                	sd	s0,16(sp)
    80003e98:	e426                	sd	s1,8(sp)
    80003e9a:	e04a                	sd	s2,0(sp)
    80003e9c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e9e:	c105                	beqz	a0,80003ebe <ilock+0x2c>
    80003ea0:	84aa                	mv	s1,a0
    80003ea2:	451c                	lw	a5,8(a0)
    80003ea4:	00f05d63          	blez	a5,80003ebe <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003ea8:	0541                	addi	a0,a0,16
    80003eaa:	44b000ef          	jal	ra,80004af4 <acquiresleep>
  if(ip->valid == 0){
    80003eae:	40bc                	lw	a5,64(s1)
    80003eb0:	cf89                	beqz	a5,80003eca <ilock+0x38>
}
    80003eb2:	60e2                	ld	ra,24(sp)
    80003eb4:	6442                	ld	s0,16(sp)
    80003eb6:	64a2                	ld	s1,8(sp)
    80003eb8:	6902                	ld	s2,0(sp)
    80003eba:	6105                	addi	sp,sp,32
    80003ebc:	8082                	ret
    panic("ilock");
    80003ebe:	00004517          	auipc	a0,0x4
    80003ec2:	6e250513          	addi	a0,a0,1762 # 800085a0 <syscalls+0x1a8>
    80003ec6:	8c3fc0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003eca:	40dc                	lw	a5,4(s1)
    80003ecc:	0047d79b          	srliw	a5,a5,0x4
    80003ed0:	00245597          	auipc	a1,0x245
    80003ed4:	0705a583          	lw	a1,112(a1) # 80248f40 <sb+0x18>
    80003ed8:	9dbd                	addw	a1,a1,a5
    80003eda:	4088                	lw	a0,0(s1)
    80003edc:	907ff0ef          	jal	ra,800037e2 <bread>
    80003ee0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ee2:	05850593          	addi	a1,a0,88
    80003ee6:	40dc                	lw	a5,4(s1)
    80003ee8:	8bbd                	andi	a5,a5,15
    80003eea:	079a                	slli	a5,a5,0x6
    80003eec:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003eee:	00059783          	lh	a5,0(a1)
    80003ef2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ef6:	00259783          	lh	a5,2(a1)
    80003efa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003efe:	00459783          	lh	a5,4(a1)
    80003f02:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f06:	00659783          	lh	a5,6(a1)
    80003f0a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f0e:	459c                	lw	a5,8(a1)
    80003f10:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f12:	03400613          	li	a2,52
    80003f16:	05b1                	addi	a1,a1,12
    80003f18:	05048513          	addi	a0,s1,80
    80003f1c:	ec3fc0ef          	jal	ra,80000dde <memmove>
    brelse(bp);
    80003f20:	854a                	mv	a0,s2
    80003f22:	9c9ff0ef          	jal	ra,800038ea <brelse>
    ip->valid = 1;
    80003f26:	4785                	li	a5,1
    80003f28:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f2a:	04449783          	lh	a5,68(s1)
    80003f2e:	f3d1                	bnez	a5,80003eb2 <ilock+0x20>
      panic("ilock: no type");
    80003f30:	00004517          	auipc	a0,0x4
    80003f34:	67850513          	addi	a0,a0,1656 # 800085a8 <syscalls+0x1b0>
    80003f38:	851fc0ef          	jal	ra,80000788 <panic>

0000000080003f3c <iunlock>:
{
    80003f3c:	1101                	addi	sp,sp,-32
    80003f3e:	ec06                	sd	ra,24(sp)
    80003f40:	e822                	sd	s0,16(sp)
    80003f42:	e426                	sd	s1,8(sp)
    80003f44:	e04a                	sd	s2,0(sp)
    80003f46:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f48:	c505                	beqz	a0,80003f70 <iunlock+0x34>
    80003f4a:	84aa                	mv	s1,a0
    80003f4c:	01050913          	addi	s2,a0,16
    80003f50:	854a                	mv	a0,s2
    80003f52:	421000ef          	jal	ra,80004b72 <holdingsleep>
    80003f56:	cd09                	beqz	a0,80003f70 <iunlock+0x34>
    80003f58:	449c                	lw	a5,8(s1)
    80003f5a:	00f05b63          	blez	a5,80003f70 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003f5e:	854a                	mv	a0,s2
    80003f60:	3db000ef          	jal	ra,80004b3a <releasesleep>
}
    80003f64:	60e2                	ld	ra,24(sp)
    80003f66:	6442                	ld	s0,16(sp)
    80003f68:	64a2                	ld	s1,8(sp)
    80003f6a:	6902                	ld	s2,0(sp)
    80003f6c:	6105                	addi	sp,sp,32
    80003f6e:	8082                	ret
    panic("iunlock");
    80003f70:	00004517          	auipc	a0,0x4
    80003f74:	64850513          	addi	a0,a0,1608 # 800085b8 <syscalls+0x1c0>
    80003f78:	811fc0ef          	jal	ra,80000788 <panic>

0000000080003f7c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003f7c:	7179                	addi	sp,sp,-48
    80003f7e:	f406                	sd	ra,40(sp)
    80003f80:	f022                	sd	s0,32(sp)
    80003f82:	ec26                	sd	s1,24(sp)
    80003f84:	e84a                	sd	s2,16(sp)
    80003f86:	e44e                	sd	s3,8(sp)
    80003f88:	e052                	sd	s4,0(sp)
    80003f8a:	1800                	addi	s0,sp,48
    80003f8c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f8e:	05050493          	addi	s1,a0,80
    80003f92:	08050913          	addi	s2,a0,128
    80003f96:	a021                	j	80003f9e <itrunc+0x22>
    80003f98:	0491                	addi	s1,s1,4
    80003f9a:	01248b63          	beq	s1,s2,80003fb0 <itrunc+0x34>
    if(ip->addrs[i]){
    80003f9e:	408c                	lw	a1,0(s1)
    80003fa0:	dde5                	beqz	a1,80003f98 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fa2:	0009a503          	lw	a0,0(s3)
    80003fa6:	a37ff0ef          	jal	ra,800039dc <bfree>
      ip->addrs[i] = 0;
    80003faa:	0004a023          	sw	zero,0(s1)
    80003fae:	b7ed                	j	80003f98 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003fb0:	0809a583          	lw	a1,128(s3)
    80003fb4:	ed91                	bnez	a1,80003fd0 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fb6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003fba:	854e                	mv	a0,s3
    80003fbc:	e23ff0ef          	jal	ra,80003dde <iupdate>
}
    80003fc0:	70a2                	ld	ra,40(sp)
    80003fc2:	7402                	ld	s0,32(sp)
    80003fc4:	64e2                	ld	s1,24(sp)
    80003fc6:	6942                	ld	s2,16(sp)
    80003fc8:	69a2                	ld	s3,8(sp)
    80003fca:	6a02                	ld	s4,0(sp)
    80003fcc:	6145                	addi	sp,sp,48
    80003fce:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003fd0:	0009a503          	lw	a0,0(s3)
    80003fd4:	80fff0ef          	jal	ra,800037e2 <bread>
    80003fd8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003fda:	05850493          	addi	s1,a0,88
    80003fde:	45850913          	addi	s2,a0,1112
    80003fe2:	a021                	j	80003fea <itrunc+0x6e>
    80003fe4:	0491                	addi	s1,s1,4
    80003fe6:	01248963          	beq	s1,s2,80003ff8 <itrunc+0x7c>
      if(a[j])
    80003fea:	408c                	lw	a1,0(s1)
    80003fec:	dde5                	beqz	a1,80003fe4 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003fee:	0009a503          	lw	a0,0(s3)
    80003ff2:	9ebff0ef          	jal	ra,800039dc <bfree>
    80003ff6:	b7fd                	j	80003fe4 <itrunc+0x68>
    brelse(bp);
    80003ff8:	8552                	mv	a0,s4
    80003ffa:	8f1ff0ef          	jal	ra,800038ea <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ffe:	0809a583          	lw	a1,128(s3)
    80004002:	0009a503          	lw	a0,0(s3)
    80004006:	9d7ff0ef          	jal	ra,800039dc <bfree>
    ip->addrs[NDIRECT] = 0;
    8000400a:	0809a023          	sw	zero,128(s3)
    8000400e:	b765                	j	80003fb6 <itrunc+0x3a>

0000000080004010 <iput>:
{
    80004010:	1101                	addi	sp,sp,-32
    80004012:	ec06                	sd	ra,24(sp)
    80004014:	e822                	sd	s0,16(sp)
    80004016:	e426                	sd	s1,8(sp)
    80004018:	e04a                	sd	s2,0(sp)
    8000401a:	1000                	addi	s0,sp,32
    8000401c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000401e:	00245517          	auipc	a0,0x245
    80004022:	f2a50513          	addi	a0,a0,-214 # 80248f48 <itable>
    80004026:	c89fc0ef          	jal	ra,80000cae <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000402a:	4498                	lw	a4,8(s1)
    8000402c:	4785                	li	a5,1
    8000402e:	02f70163          	beq	a4,a5,80004050 <iput+0x40>
  ip->ref--;
    80004032:	449c                	lw	a5,8(s1)
    80004034:	37fd                	addiw	a5,a5,-1
    80004036:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004038:	00245517          	auipc	a0,0x245
    8000403c:	f1050513          	addi	a0,a0,-240 # 80248f48 <itable>
    80004040:	d07fc0ef          	jal	ra,80000d46 <release>
}
    80004044:	60e2                	ld	ra,24(sp)
    80004046:	6442                	ld	s0,16(sp)
    80004048:	64a2                	ld	s1,8(sp)
    8000404a:	6902                	ld	s2,0(sp)
    8000404c:	6105                	addi	sp,sp,32
    8000404e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004050:	40bc                	lw	a5,64(s1)
    80004052:	d3e5                	beqz	a5,80004032 <iput+0x22>
    80004054:	04a49783          	lh	a5,74(s1)
    80004058:	ffe9                	bnez	a5,80004032 <iput+0x22>
    acquiresleep(&ip->lock);
    8000405a:	01048913          	addi	s2,s1,16
    8000405e:	854a                	mv	a0,s2
    80004060:	295000ef          	jal	ra,80004af4 <acquiresleep>
    release(&itable.lock);
    80004064:	00245517          	auipc	a0,0x245
    80004068:	ee450513          	addi	a0,a0,-284 # 80248f48 <itable>
    8000406c:	cdbfc0ef          	jal	ra,80000d46 <release>
    itrunc(ip);
    80004070:	8526                	mv	a0,s1
    80004072:	f0bff0ef          	jal	ra,80003f7c <itrunc>
    ip->type = 0;
    80004076:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000407a:	8526                	mv	a0,s1
    8000407c:	d63ff0ef          	jal	ra,80003dde <iupdate>
    ip->valid = 0;
    80004080:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004084:	854a                	mv	a0,s2
    80004086:	2b5000ef          	jal	ra,80004b3a <releasesleep>
    acquire(&itable.lock);
    8000408a:	00245517          	auipc	a0,0x245
    8000408e:	ebe50513          	addi	a0,a0,-322 # 80248f48 <itable>
    80004092:	c1dfc0ef          	jal	ra,80000cae <acquire>
    80004096:	bf71                	j	80004032 <iput+0x22>

0000000080004098 <iunlockput>:
{
    80004098:	1101                	addi	sp,sp,-32
    8000409a:	ec06                	sd	ra,24(sp)
    8000409c:	e822                	sd	s0,16(sp)
    8000409e:	e426                	sd	s1,8(sp)
    800040a0:	1000                	addi	s0,sp,32
    800040a2:	84aa                	mv	s1,a0
  iunlock(ip);
    800040a4:	e99ff0ef          	jal	ra,80003f3c <iunlock>
  iput(ip);
    800040a8:	8526                	mv	a0,s1
    800040aa:	f67ff0ef          	jal	ra,80004010 <iput>
}
    800040ae:	60e2                	ld	ra,24(sp)
    800040b0:	6442                	ld	s0,16(sp)
    800040b2:	64a2                	ld	s1,8(sp)
    800040b4:	6105                	addi	sp,sp,32
    800040b6:	8082                	ret

00000000800040b8 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800040b8:	00245717          	auipc	a4,0x245
    800040bc:	e7c72703          	lw	a4,-388(a4) # 80248f34 <sb+0xc>
    800040c0:	4785                	li	a5,1
    800040c2:	0ae7ff63          	bgeu	a5,a4,80004180 <ireclaim+0xc8>
{
    800040c6:	7139                	addi	sp,sp,-64
    800040c8:	fc06                	sd	ra,56(sp)
    800040ca:	f822                	sd	s0,48(sp)
    800040cc:	f426                	sd	s1,40(sp)
    800040ce:	f04a                	sd	s2,32(sp)
    800040d0:	ec4e                	sd	s3,24(sp)
    800040d2:	e852                	sd	s4,16(sp)
    800040d4:	e456                	sd	s5,8(sp)
    800040d6:	e05a                	sd	s6,0(sp)
    800040d8:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800040da:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800040dc:	00050a1b          	sext.w	s4,a0
    800040e0:	00245a97          	auipc	s5,0x245
    800040e4:	e48a8a93          	addi	s5,s5,-440 # 80248f28 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800040e8:	00004b17          	auipc	s6,0x4
    800040ec:	4d8b0b13          	addi	s6,s6,1240 # 800085c0 <syscalls+0x1c8>
    800040f0:	a099                	j	80004136 <ireclaim+0x7e>
    800040f2:	85ce                	mv	a1,s3
    800040f4:	855a                	mv	a0,s6
    800040f6:	bccfc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    800040fa:	85ce                	mv	a1,s3
    800040fc:	8552                	mv	a0,s4
    800040fe:	b27ff0ef          	jal	ra,80003c24 <iget>
    80004102:	89aa                	mv	s3,a0
    brelse(bp);
    80004104:	854a                	mv	a0,s2
    80004106:	fe4ff0ef          	jal	ra,800038ea <brelse>
    if (ip) {
    8000410a:	00098f63          	beqz	s3,80004128 <ireclaim+0x70>
      begin_op();
    8000410e:	76c000ef          	jal	ra,8000487a <begin_op>
      ilock(ip);
    80004112:	854e                	mv	a0,s3
    80004114:	d7fff0ef          	jal	ra,80003e92 <ilock>
      iunlock(ip);
    80004118:	854e                	mv	a0,s3
    8000411a:	e23ff0ef          	jal	ra,80003f3c <iunlock>
      iput(ip);
    8000411e:	854e                	mv	a0,s3
    80004120:	ef1ff0ef          	jal	ra,80004010 <iput>
      end_op();
    80004124:	7c4000ef          	jal	ra,800048e8 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004128:	0485                	addi	s1,s1,1
    8000412a:	00caa703          	lw	a4,12(s5)
    8000412e:	0004879b          	sext.w	a5,s1
    80004132:	02e7fd63          	bgeu	a5,a4,8000416c <ireclaim+0xb4>
    80004136:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000413a:	0044d593          	srli	a1,s1,0x4
    8000413e:	018aa783          	lw	a5,24(s5)
    80004142:	9dbd                	addw	a1,a1,a5
    80004144:	8552                	mv	a0,s4
    80004146:	e9cff0ef          	jal	ra,800037e2 <bread>
    8000414a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000414c:	05850793          	addi	a5,a0,88
    80004150:	00f9f713          	andi	a4,s3,15
    80004154:	071a                	slli	a4,a4,0x6
    80004156:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80004158:	00079703          	lh	a4,0(a5)
    8000415c:	c701                	beqz	a4,80004164 <ireclaim+0xac>
    8000415e:	00679783          	lh	a5,6(a5)
    80004162:	dbc1                	beqz	a5,800040f2 <ireclaim+0x3a>
    brelse(bp);
    80004164:	854a                	mv	a0,s2
    80004166:	f84ff0ef          	jal	ra,800038ea <brelse>
    if (ip) {
    8000416a:	bf7d                	j	80004128 <ireclaim+0x70>
}
    8000416c:	70e2                	ld	ra,56(sp)
    8000416e:	7442                	ld	s0,48(sp)
    80004170:	74a2                	ld	s1,40(sp)
    80004172:	7902                	ld	s2,32(sp)
    80004174:	69e2                	ld	s3,24(sp)
    80004176:	6a42                	ld	s4,16(sp)
    80004178:	6aa2                	ld	s5,8(sp)
    8000417a:	6b02                	ld	s6,0(sp)
    8000417c:	6121                	addi	sp,sp,64
    8000417e:	8082                	ret
    80004180:	8082                	ret

0000000080004182 <fsinit>:
fsinit(int dev) {
    80004182:	7179                	addi	sp,sp,-48
    80004184:	f406                	sd	ra,40(sp)
    80004186:	f022                	sd	s0,32(sp)
    80004188:	ec26                	sd	s1,24(sp)
    8000418a:	e84a                	sd	s2,16(sp)
    8000418c:	e44e                	sd	s3,8(sp)
    8000418e:	1800                	addi	s0,sp,48
    80004190:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80004192:	4585                	li	a1,1
    80004194:	e4eff0ef          	jal	ra,800037e2 <bread>
    80004198:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000419a:	00245997          	auipc	s3,0x245
    8000419e:	d8e98993          	addi	s3,s3,-626 # 80248f28 <sb>
    800041a2:	02000613          	li	a2,32
    800041a6:	05850593          	addi	a1,a0,88
    800041aa:	854e                	mv	a0,s3
    800041ac:	c33fc0ef          	jal	ra,80000dde <memmove>
  brelse(bp);
    800041b0:	854a                	mv	a0,s2
    800041b2:	f38ff0ef          	jal	ra,800038ea <brelse>
  if(sb.magic != FSMAGIC)
    800041b6:	0009a703          	lw	a4,0(s3)
    800041ba:	102037b7          	lui	a5,0x10203
    800041be:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800041c2:	02f71363          	bne	a4,a5,800041e8 <fsinit+0x66>
  initlog(dev, &sb);
    800041c6:	00245597          	auipc	a1,0x245
    800041ca:	d6258593          	addi	a1,a1,-670 # 80248f28 <sb>
    800041ce:	8526                	mv	a0,s1
    800041d0:	61e000ef          	jal	ra,800047ee <initlog>
  ireclaim(dev);
    800041d4:	8526                	mv	a0,s1
    800041d6:	ee3ff0ef          	jal	ra,800040b8 <ireclaim>
}
    800041da:	70a2                	ld	ra,40(sp)
    800041dc:	7402                	ld	s0,32(sp)
    800041de:	64e2                	ld	s1,24(sp)
    800041e0:	6942                	ld	s2,16(sp)
    800041e2:	69a2                	ld	s3,8(sp)
    800041e4:	6145                	addi	sp,sp,48
    800041e6:	8082                	ret
    panic("invalid file system");
    800041e8:	00004517          	auipc	a0,0x4
    800041ec:	3f850513          	addi	a0,a0,1016 # 800085e0 <syscalls+0x1e8>
    800041f0:	d98fc0ef          	jal	ra,80000788 <panic>

00000000800041f4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041f4:	1141                	addi	sp,sp,-16
    800041f6:	e422                	sd	s0,8(sp)
    800041f8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041fa:	411c                	lw	a5,0(a0)
    800041fc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041fe:	415c                	lw	a5,4(a0)
    80004200:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004202:	04451783          	lh	a5,68(a0)
    80004206:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000420a:	04a51783          	lh	a5,74(a0)
    8000420e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004212:	04c56783          	lwu	a5,76(a0)
    80004216:	e99c                	sd	a5,16(a1)
}
    80004218:	6422                	ld	s0,8(sp)
    8000421a:	0141                	addi	sp,sp,16
    8000421c:	8082                	ret

000000008000421e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000421e:	457c                	lw	a5,76(a0)
    80004220:	0cd7ef63          	bltu	a5,a3,800042fe <readi+0xe0>
{
    80004224:	7159                	addi	sp,sp,-112
    80004226:	f486                	sd	ra,104(sp)
    80004228:	f0a2                	sd	s0,96(sp)
    8000422a:	eca6                	sd	s1,88(sp)
    8000422c:	e8ca                	sd	s2,80(sp)
    8000422e:	e4ce                	sd	s3,72(sp)
    80004230:	e0d2                	sd	s4,64(sp)
    80004232:	fc56                	sd	s5,56(sp)
    80004234:	f85a                	sd	s6,48(sp)
    80004236:	f45e                	sd	s7,40(sp)
    80004238:	f062                	sd	s8,32(sp)
    8000423a:	ec66                	sd	s9,24(sp)
    8000423c:	e86a                	sd	s10,16(sp)
    8000423e:	e46e                	sd	s11,8(sp)
    80004240:	1880                	addi	s0,sp,112
    80004242:	8b2a                	mv	s6,a0
    80004244:	8bae                	mv	s7,a1
    80004246:	8a32                	mv	s4,a2
    80004248:	84b6                	mv	s1,a3
    8000424a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000424c:	9f35                	addw	a4,a4,a3
    return 0;
    8000424e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004250:	08d76663          	bltu	a4,a3,800042dc <readi+0xbe>
  if(off + n > ip->size)
    80004254:	00e7f463          	bgeu	a5,a4,8000425c <readi+0x3e>
    n = ip->size - off;
    80004258:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000425c:	080a8f63          	beqz	s5,800042fa <readi+0xdc>
    80004260:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004262:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004266:	5c7d                	li	s8,-1
    80004268:	a80d                	j	8000429a <readi+0x7c>
    8000426a:	020d1d93          	slli	s11,s10,0x20
    8000426e:	020ddd93          	srli	s11,s11,0x20
    80004272:	05890613          	addi	a2,s2,88
    80004276:	86ee                	mv	a3,s11
    80004278:	963a                	add	a2,a2,a4
    8000427a:	85d2                	mv	a1,s4
    8000427c:	855e                	mv	a0,s7
    8000427e:	d66fe0ef          	jal	ra,800027e4 <either_copyout>
    80004282:	05850763          	beq	a0,s8,800042d0 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004286:	854a                	mv	a0,s2
    80004288:	e62ff0ef          	jal	ra,800038ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000428c:	013d09bb          	addw	s3,s10,s3
    80004290:	009d04bb          	addw	s1,s10,s1
    80004294:	9a6e                	add	s4,s4,s11
    80004296:	0559f163          	bgeu	s3,s5,800042d8 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    8000429a:	00a4d59b          	srliw	a1,s1,0xa
    8000429e:	855a                	mv	a0,s6
    800042a0:	8b7ff0ef          	jal	ra,80003b56 <bmap>
    800042a4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042a8:	c985                	beqz	a1,800042d8 <readi+0xba>
    bp = bread(ip->dev, addr);
    800042aa:	000b2503          	lw	a0,0(s6)
    800042ae:	d34ff0ef          	jal	ra,800037e2 <bread>
    800042b2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042b4:	3ff4f713          	andi	a4,s1,1023
    800042b8:	40ec87bb          	subw	a5,s9,a4
    800042bc:	413a86bb          	subw	a3,s5,s3
    800042c0:	8d3e                	mv	s10,a5
    800042c2:	2781                	sext.w	a5,a5
    800042c4:	0006861b          	sext.w	a2,a3
    800042c8:	faf671e3          	bgeu	a2,a5,8000426a <readi+0x4c>
    800042cc:	8d36                	mv	s10,a3
    800042ce:	bf71                	j	8000426a <readi+0x4c>
      brelse(bp);
    800042d0:	854a                	mv	a0,s2
    800042d2:	e18ff0ef          	jal	ra,800038ea <brelse>
      tot = -1;
    800042d6:	59fd                	li	s3,-1
  }
  return tot;
    800042d8:	0009851b          	sext.w	a0,s3
}
    800042dc:	70a6                	ld	ra,104(sp)
    800042de:	7406                	ld	s0,96(sp)
    800042e0:	64e6                	ld	s1,88(sp)
    800042e2:	6946                	ld	s2,80(sp)
    800042e4:	69a6                	ld	s3,72(sp)
    800042e6:	6a06                	ld	s4,64(sp)
    800042e8:	7ae2                	ld	s5,56(sp)
    800042ea:	7b42                	ld	s6,48(sp)
    800042ec:	7ba2                	ld	s7,40(sp)
    800042ee:	7c02                	ld	s8,32(sp)
    800042f0:	6ce2                	ld	s9,24(sp)
    800042f2:	6d42                	ld	s10,16(sp)
    800042f4:	6da2                	ld	s11,8(sp)
    800042f6:	6165                	addi	sp,sp,112
    800042f8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042fa:	89d6                	mv	s3,s5
    800042fc:	bff1                	j	800042d8 <readi+0xba>
    return 0;
    800042fe:	4501                	li	a0,0
}
    80004300:	8082                	ret

0000000080004302 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004302:	457c                	lw	a5,76(a0)
    80004304:	0ed7ea63          	bltu	a5,a3,800043f8 <writei+0xf6>
{
    80004308:	7159                	addi	sp,sp,-112
    8000430a:	f486                	sd	ra,104(sp)
    8000430c:	f0a2                	sd	s0,96(sp)
    8000430e:	eca6                	sd	s1,88(sp)
    80004310:	e8ca                	sd	s2,80(sp)
    80004312:	e4ce                	sd	s3,72(sp)
    80004314:	e0d2                	sd	s4,64(sp)
    80004316:	fc56                	sd	s5,56(sp)
    80004318:	f85a                	sd	s6,48(sp)
    8000431a:	f45e                	sd	s7,40(sp)
    8000431c:	f062                	sd	s8,32(sp)
    8000431e:	ec66                	sd	s9,24(sp)
    80004320:	e86a                	sd	s10,16(sp)
    80004322:	e46e                	sd	s11,8(sp)
    80004324:	1880                	addi	s0,sp,112
    80004326:	8aaa                	mv	s5,a0
    80004328:	8bae                	mv	s7,a1
    8000432a:	8a32                	mv	s4,a2
    8000432c:	8936                	mv	s2,a3
    8000432e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004330:	00e687bb          	addw	a5,a3,a4
    80004334:	0cd7e463          	bltu	a5,a3,800043fc <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004338:	00043737          	lui	a4,0x43
    8000433c:	0cf76263          	bltu	a4,a5,80004400 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004340:	0a0b0a63          	beqz	s6,800043f4 <writei+0xf2>
    80004344:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004346:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000434a:	5c7d                	li	s8,-1
    8000434c:	a825                	j	80004384 <writei+0x82>
    8000434e:	020d1d93          	slli	s11,s10,0x20
    80004352:	020ddd93          	srli	s11,s11,0x20
    80004356:	05848513          	addi	a0,s1,88
    8000435a:	86ee                	mv	a3,s11
    8000435c:	8652                	mv	a2,s4
    8000435e:	85de                	mv	a1,s7
    80004360:	953a                	add	a0,a0,a4
    80004362:	cccfe0ef          	jal	ra,8000282e <either_copyin>
    80004366:	05850a63          	beq	a0,s8,800043ba <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000436a:	8526                	mv	a0,s1
    8000436c:	690000ef          	jal	ra,800049fc <log_write>
    brelse(bp);
    80004370:	8526                	mv	a0,s1
    80004372:	d78ff0ef          	jal	ra,800038ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004376:	013d09bb          	addw	s3,s10,s3
    8000437a:	012d093b          	addw	s2,s10,s2
    8000437e:	9a6e                	add	s4,s4,s11
    80004380:	0569f063          	bgeu	s3,s6,800043c0 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004384:	00a9559b          	srliw	a1,s2,0xa
    80004388:	8556                	mv	a0,s5
    8000438a:	fccff0ef          	jal	ra,80003b56 <bmap>
    8000438e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004392:	c59d                	beqz	a1,800043c0 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004394:	000aa503          	lw	a0,0(s5)
    80004398:	c4aff0ef          	jal	ra,800037e2 <bread>
    8000439c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000439e:	3ff97713          	andi	a4,s2,1023
    800043a2:	40ec87bb          	subw	a5,s9,a4
    800043a6:	413b06bb          	subw	a3,s6,s3
    800043aa:	8d3e                	mv	s10,a5
    800043ac:	2781                	sext.w	a5,a5
    800043ae:	0006861b          	sext.w	a2,a3
    800043b2:	f8f67ee3          	bgeu	a2,a5,8000434e <writei+0x4c>
    800043b6:	8d36                	mv	s10,a3
    800043b8:	bf59                	j	8000434e <writei+0x4c>
      brelse(bp);
    800043ba:	8526                	mv	a0,s1
    800043bc:	d2eff0ef          	jal	ra,800038ea <brelse>
  }

  if(off > ip->size)
    800043c0:	04caa783          	lw	a5,76(s5)
    800043c4:	0127f463          	bgeu	a5,s2,800043cc <writei+0xca>
    ip->size = off;
    800043c8:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043cc:	8556                	mv	a0,s5
    800043ce:	a11ff0ef          	jal	ra,80003dde <iupdate>

  return tot;
    800043d2:	0009851b          	sext.w	a0,s3
}
    800043d6:	70a6                	ld	ra,104(sp)
    800043d8:	7406                	ld	s0,96(sp)
    800043da:	64e6                	ld	s1,88(sp)
    800043dc:	6946                	ld	s2,80(sp)
    800043de:	69a6                	ld	s3,72(sp)
    800043e0:	6a06                	ld	s4,64(sp)
    800043e2:	7ae2                	ld	s5,56(sp)
    800043e4:	7b42                	ld	s6,48(sp)
    800043e6:	7ba2                	ld	s7,40(sp)
    800043e8:	7c02                	ld	s8,32(sp)
    800043ea:	6ce2                	ld	s9,24(sp)
    800043ec:	6d42                	ld	s10,16(sp)
    800043ee:	6da2                	ld	s11,8(sp)
    800043f0:	6165                	addi	sp,sp,112
    800043f2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043f4:	89da                	mv	s3,s6
    800043f6:	bfd9                	j	800043cc <writei+0xca>
    return -1;
    800043f8:	557d                	li	a0,-1
}
    800043fa:	8082                	ret
    return -1;
    800043fc:	557d                	li	a0,-1
    800043fe:	bfe1                	j	800043d6 <writei+0xd4>
    return -1;
    80004400:	557d                	li	a0,-1
    80004402:	bfd1                	j	800043d6 <writei+0xd4>

0000000080004404 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004404:	1141                	addi	sp,sp,-16
    80004406:	e406                	sd	ra,8(sp)
    80004408:	e022                	sd	s0,0(sp)
    8000440a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000440c:	4639                	li	a2,14
    8000440e:	a41fc0ef          	jal	ra,80000e4e <strncmp>
}
    80004412:	60a2                	ld	ra,8(sp)
    80004414:	6402                	ld	s0,0(sp)
    80004416:	0141                	addi	sp,sp,16
    80004418:	8082                	ret

000000008000441a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000441a:	7139                	addi	sp,sp,-64
    8000441c:	fc06                	sd	ra,56(sp)
    8000441e:	f822                	sd	s0,48(sp)
    80004420:	f426                	sd	s1,40(sp)
    80004422:	f04a                	sd	s2,32(sp)
    80004424:	ec4e                	sd	s3,24(sp)
    80004426:	e852                	sd	s4,16(sp)
    80004428:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000442a:	04451703          	lh	a4,68(a0)
    8000442e:	4785                	li	a5,1
    80004430:	00f71a63          	bne	a4,a5,80004444 <dirlookup+0x2a>
    80004434:	892a                	mv	s2,a0
    80004436:	89ae                	mv	s3,a1
    80004438:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000443a:	457c                	lw	a5,76(a0)
    8000443c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000443e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004440:	e39d                	bnez	a5,80004466 <dirlookup+0x4c>
    80004442:	a095                	j	800044a6 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004444:	00004517          	auipc	a0,0x4
    80004448:	1b450513          	addi	a0,a0,436 # 800085f8 <syscalls+0x200>
    8000444c:	b3cfc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80004450:	00004517          	auipc	a0,0x4
    80004454:	1c050513          	addi	a0,a0,448 # 80008610 <syscalls+0x218>
    80004458:	b30fc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000445c:	24c1                	addiw	s1,s1,16
    8000445e:	04c92783          	lw	a5,76(s2)
    80004462:	04f4f163          	bgeu	s1,a5,800044a4 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004466:	4741                	li	a4,16
    80004468:	86a6                	mv	a3,s1
    8000446a:	fc040613          	addi	a2,s0,-64
    8000446e:	4581                	li	a1,0
    80004470:	854a                	mv	a0,s2
    80004472:	dadff0ef          	jal	ra,8000421e <readi>
    80004476:	47c1                	li	a5,16
    80004478:	fcf51ce3          	bne	a0,a5,80004450 <dirlookup+0x36>
    if(de.inum == 0)
    8000447c:	fc045783          	lhu	a5,-64(s0)
    80004480:	dff1                	beqz	a5,8000445c <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80004482:	fc240593          	addi	a1,s0,-62
    80004486:	854e                	mv	a0,s3
    80004488:	f7dff0ef          	jal	ra,80004404 <namecmp>
    8000448c:	f961                	bnez	a0,8000445c <dirlookup+0x42>
      if(poff)
    8000448e:	000a0463          	beqz	s4,80004496 <dirlookup+0x7c>
        *poff = off;
    80004492:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004496:	fc045583          	lhu	a1,-64(s0)
    8000449a:	00092503          	lw	a0,0(s2)
    8000449e:	f86ff0ef          	jal	ra,80003c24 <iget>
    800044a2:	a011                	j	800044a6 <dirlookup+0x8c>
  return 0;
    800044a4:	4501                	li	a0,0
}
    800044a6:	70e2                	ld	ra,56(sp)
    800044a8:	7442                	ld	s0,48(sp)
    800044aa:	74a2                	ld	s1,40(sp)
    800044ac:	7902                	ld	s2,32(sp)
    800044ae:	69e2                	ld	s3,24(sp)
    800044b0:	6a42                	ld	s4,16(sp)
    800044b2:	6121                	addi	sp,sp,64
    800044b4:	8082                	ret

00000000800044b6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044b6:	711d                	addi	sp,sp,-96
    800044b8:	ec86                	sd	ra,88(sp)
    800044ba:	e8a2                	sd	s0,80(sp)
    800044bc:	e4a6                	sd	s1,72(sp)
    800044be:	e0ca                	sd	s2,64(sp)
    800044c0:	fc4e                	sd	s3,56(sp)
    800044c2:	f852                	sd	s4,48(sp)
    800044c4:	f456                	sd	s5,40(sp)
    800044c6:	f05a                	sd	s6,32(sp)
    800044c8:	ec5e                	sd	s7,24(sp)
    800044ca:	e862                	sd	s8,16(sp)
    800044cc:	e466                	sd	s9,8(sp)
    800044ce:	e06a                	sd	s10,0(sp)
    800044d0:	1080                	addi	s0,sp,96
    800044d2:	84aa                	mv	s1,a0
    800044d4:	8b2e                	mv	s6,a1
    800044d6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800044d8:	00054703          	lbu	a4,0(a0)
    800044dc:	02f00793          	li	a5,47
    800044e0:	00f70f63          	beq	a4,a5,800044fe <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800044e4:	eb4fd0ef          	jal	ra,80001b98 <myproc>
    800044e8:	15053503          	ld	a0,336(a0)
    800044ec:	971ff0ef          	jal	ra,80003e5c <idup>
    800044f0:	8a2a                	mv	s4,a0
  while(*path == '/')
    800044f2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800044f6:	4cb5                	li	s9,13
  len = path - s;
    800044f8:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800044fa:	4c05                	li	s8,1
    800044fc:	a879                	j	8000459a <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    800044fe:	4585                	li	a1,1
    80004500:	4505                	li	a0,1
    80004502:	f22ff0ef          	jal	ra,80003c24 <iget>
    80004506:	8a2a                	mv	s4,a0
    80004508:	b7ed                	j	800044f2 <namex+0x3c>
      iunlockput(ip);
    8000450a:	8552                	mv	a0,s4
    8000450c:	b8dff0ef          	jal	ra,80004098 <iunlockput>
      return 0;
    80004510:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004512:	8552                	mv	a0,s4
    80004514:	60e6                	ld	ra,88(sp)
    80004516:	6446                	ld	s0,80(sp)
    80004518:	64a6                	ld	s1,72(sp)
    8000451a:	6906                	ld	s2,64(sp)
    8000451c:	79e2                	ld	s3,56(sp)
    8000451e:	7a42                	ld	s4,48(sp)
    80004520:	7aa2                	ld	s5,40(sp)
    80004522:	7b02                	ld	s6,32(sp)
    80004524:	6be2                	ld	s7,24(sp)
    80004526:	6c42                	ld	s8,16(sp)
    80004528:	6ca2                	ld	s9,8(sp)
    8000452a:	6d02                	ld	s10,0(sp)
    8000452c:	6125                	addi	sp,sp,96
    8000452e:	8082                	ret
      iunlock(ip);
    80004530:	8552                	mv	a0,s4
    80004532:	a0bff0ef          	jal	ra,80003f3c <iunlock>
      return ip;
    80004536:	bff1                	j	80004512 <namex+0x5c>
      iunlockput(ip);
    80004538:	8552                	mv	a0,s4
    8000453a:	b5fff0ef          	jal	ra,80004098 <iunlockput>
      return 0;
    8000453e:	8a4e                	mv	s4,s3
    80004540:	bfc9                	j	80004512 <namex+0x5c>
  len = path - s;
    80004542:	40998633          	sub	a2,s3,s1
    80004546:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000454a:	09acd063          	bge	s9,s10,800045ca <namex+0x114>
    memmove(name, s, DIRSIZ);
    8000454e:	4639                	li	a2,14
    80004550:	85a6                	mv	a1,s1
    80004552:	8556                	mv	a0,s5
    80004554:	88bfc0ef          	jal	ra,80000dde <memmove>
    80004558:	84ce                	mv	s1,s3
  while(*path == '/')
    8000455a:	0004c783          	lbu	a5,0(s1)
    8000455e:	01279763          	bne	a5,s2,8000456c <namex+0xb6>
    path++;
    80004562:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004564:	0004c783          	lbu	a5,0(s1)
    80004568:	ff278de3          	beq	a5,s2,80004562 <namex+0xac>
    ilock(ip);
    8000456c:	8552                	mv	a0,s4
    8000456e:	925ff0ef          	jal	ra,80003e92 <ilock>
    if(ip->type != T_DIR){
    80004572:	044a1783          	lh	a5,68(s4)
    80004576:	f9879ae3          	bne	a5,s8,8000450a <namex+0x54>
    if(nameiparent && *path == '\0'){
    8000457a:	000b0563          	beqz	s6,80004584 <namex+0xce>
    8000457e:	0004c783          	lbu	a5,0(s1)
    80004582:	d7dd                	beqz	a5,80004530 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004584:	865e                	mv	a2,s7
    80004586:	85d6                	mv	a1,s5
    80004588:	8552                	mv	a0,s4
    8000458a:	e91ff0ef          	jal	ra,8000441a <dirlookup>
    8000458e:	89aa                	mv	s3,a0
    80004590:	d545                	beqz	a0,80004538 <namex+0x82>
    iunlockput(ip);
    80004592:	8552                	mv	a0,s4
    80004594:	b05ff0ef          	jal	ra,80004098 <iunlockput>
    ip = next;
    80004598:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000459a:	0004c783          	lbu	a5,0(s1)
    8000459e:	01279763          	bne	a5,s2,800045ac <namex+0xf6>
    path++;
    800045a2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045a4:	0004c783          	lbu	a5,0(s1)
    800045a8:	ff278de3          	beq	a5,s2,800045a2 <namex+0xec>
  if(*path == 0)
    800045ac:	cb8d                	beqz	a5,800045de <namex+0x128>
  while(*path != '/' && *path != 0)
    800045ae:	0004c783          	lbu	a5,0(s1)
    800045b2:	89a6                	mv	s3,s1
  len = path - s;
    800045b4:	8d5e                	mv	s10,s7
    800045b6:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800045b8:	01278963          	beq	a5,s2,800045ca <namex+0x114>
    800045bc:	d3d9                	beqz	a5,80004542 <namex+0x8c>
    path++;
    800045be:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800045c0:	0009c783          	lbu	a5,0(s3)
    800045c4:	ff279ce3          	bne	a5,s2,800045bc <namex+0x106>
    800045c8:	bfad                	j	80004542 <namex+0x8c>
    memmove(name, s, len);
    800045ca:	2601                	sext.w	a2,a2
    800045cc:	85a6                	mv	a1,s1
    800045ce:	8556                	mv	a0,s5
    800045d0:	80ffc0ef          	jal	ra,80000dde <memmove>
    name[len] = 0;
    800045d4:	9d56                	add	s10,s10,s5
    800045d6:	000d0023          	sb	zero,0(s10) # 1000 <_entry-0x7ffff000>
    800045da:	84ce                	mv	s1,s3
    800045dc:	bfbd                	j	8000455a <namex+0xa4>
  if(nameiparent){
    800045de:	f20b0ae3          	beqz	s6,80004512 <namex+0x5c>
    iput(ip);
    800045e2:	8552                	mv	a0,s4
    800045e4:	a2dff0ef          	jal	ra,80004010 <iput>
    return 0;
    800045e8:	4a01                	li	s4,0
    800045ea:	b725                	j	80004512 <namex+0x5c>

00000000800045ec <dirlink>:
{
    800045ec:	7139                	addi	sp,sp,-64
    800045ee:	fc06                	sd	ra,56(sp)
    800045f0:	f822                	sd	s0,48(sp)
    800045f2:	f426                	sd	s1,40(sp)
    800045f4:	f04a                	sd	s2,32(sp)
    800045f6:	ec4e                	sd	s3,24(sp)
    800045f8:	e852                	sd	s4,16(sp)
    800045fa:	0080                	addi	s0,sp,64
    800045fc:	892a                	mv	s2,a0
    800045fe:	8a2e                	mv	s4,a1
    80004600:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004602:	4601                	li	a2,0
    80004604:	e17ff0ef          	jal	ra,8000441a <dirlookup>
    80004608:	e52d                	bnez	a0,80004672 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000460a:	04c92483          	lw	s1,76(s2)
    8000460e:	c48d                	beqz	s1,80004638 <dirlink+0x4c>
    80004610:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004612:	4741                	li	a4,16
    80004614:	86a6                	mv	a3,s1
    80004616:	fc040613          	addi	a2,s0,-64
    8000461a:	4581                	li	a1,0
    8000461c:	854a                	mv	a0,s2
    8000461e:	c01ff0ef          	jal	ra,8000421e <readi>
    80004622:	47c1                	li	a5,16
    80004624:	04f51b63          	bne	a0,a5,8000467a <dirlink+0x8e>
    if(de.inum == 0)
    80004628:	fc045783          	lhu	a5,-64(s0)
    8000462c:	c791                	beqz	a5,80004638 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000462e:	24c1                	addiw	s1,s1,16
    80004630:	04c92783          	lw	a5,76(s2)
    80004634:	fcf4efe3          	bltu	s1,a5,80004612 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004638:	4639                	li	a2,14
    8000463a:	85d2                	mv	a1,s4
    8000463c:	fc240513          	addi	a0,s0,-62
    80004640:	84bfc0ef          	jal	ra,80000e8a <strncpy>
  de.inum = inum;
    80004644:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004648:	4741                	li	a4,16
    8000464a:	86a6                	mv	a3,s1
    8000464c:	fc040613          	addi	a2,s0,-64
    80004650:	4581                	li	a1,0
    80004652:	854a                	mv	a0,s2
    80004654:	cafff0ef          	jal	ra,80004302 <writei>
    80004658:	1541                	addi	a0,a0,-16
    8000465a:	00a03533          	snez	a0,a0
    8000465e:	40a00533          	neg	a0,a0
}
    80004662:	70e2                	ld	ra,56(sp)
    80004664:	7442                	ld	s0,48(sp)
    80004666:	74a2                	ld	s1,40(sp)
    80004668:	7902                	ld	s2,32(sp)
    8000466a:	69e2                	ld	s3,24(sp)
    8000466c:	6a42                	ld	s4,16(sp)
    8000466e:	6121                	addi	sp,sp,64
    80004670:	8082                	ret
    iput(ip);
    80004672:	99fff0ef          	jal	ra,80004010 <iput>
    return -1;
    80004676:	557d                	li	a0,-1
    80004678:	b7ed                	j	80004662 <dirlink+0x76>
      panic("dirlink read");
    8000467a:	00004517          	auipc	a0,0x4
    8000467e:	fa650513          	addi	a0,a0,-90 # 80008620 <syscalls+0x228>
    80004682:	906fc0ef          	jal	ra,80000788 <panic>

0000000080004686 <namei>:

struct inode*
namei(char *path)
{
    80004686:	1101                	addi	sp,sp,-32
    80004688:	ec06                	sd	ra,24(sp)
    8000468a:	e822                	sd	s0,16(sp)
    8000468c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000468e:	fe040613          	addi	a2,s0,-32
    80004692:	4581                	li	a1,0
    80004694:	e23ff0ef          	jal	ra,800044b6 <namex>
}
    80004698:	60e2                	ld	ra,24(sp)
    8000469a:	6442                	ld	s0,16(sp)
    8000469c:	6105                	addi	sp,sp,32
    8000469e:	8082                	ret

00000000800046a0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800046a0:	1141                	addi	sp,sp,-16
    800046a2:	e406                	sd	ra,8(sp)
    800046a4:	e022                	sd	s0,0(sp)
    800046a6:	0800                	addi	s0,sp,16
    800046a8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800046aa:	4585                	li	a1,1
    800046ac:	e0bff0ef          	jal	ra,800044b6 <namex>
}
    800046b0:	60a2                	ld	ra,8(sp)
    800046b2:	6402                	ld	s0,0(sp)
    800046b4:	0141                	addi	sp,sp,16
    800046b6:	8082                	ret

00000000800046b8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800046b8:	1101                	addi	sp,sp,-32
    800046ba:	ec06                	sd	ra,24(sp)
    800046bc:	e822                	sd	s0,16(sp)
    800046be:	e426                	sd	s1,8(sp)
    800046c0:	e04a                	sd	s2,0(sp)
    800046c2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800046c4:	00246917          	auipc	s2,0x246
    800046c8:	32c90913          	addi	s2,s2,812 # 8024a9f0 <log>
    800046cc:	01892583          	lw	a1,24(s2)
    800046d0:	02492503          	lw	a0,36(s2)
    800046d4:	90eff0ef          	jal	ra,800037e2 <bread>
    800046d8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046da:	02892683          	lw	a3,40(s2)
    800046de:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046e0:	02d05863          	blez	a3,80004710 <write_head+0x58>
    800046e4:	00246797          	auipc	a5,0x246
    800046e8:	33878793          	addi	a5,a5,824 # 8024aa1c <log+0x2c>
    800046ec:	05c50713          	addi	a4,a0,92
    800046f0:	36fd                	addiw	a3,a3,-1
    800046f2:	02069613          	slli	a2,a3,0x20
    800046f6:	01e65693          	srli	a3,a2,0x1e
    800046fa:	00246617          	auipc	a2,0x246
    800046fe:	32660613          	addi	a2,a2,806 # 8024aa20 <log+0x30>
    80004702:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004704:	4390                	lw	a2,0(a5)
    80004706:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004708:	0791                	addi	a5,a5,4
    8000470a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000470c:	fed79ce3          	bne	a5,a3,80004704 <write_head+0x4c>
  }
  bwrite(buf);
    80004710:	8526                	mv	a0,s1
    80004712:	9a6ff0ef          	jal	ra,800038b8 <bwrite>
  brelse(buf);
    80004716:	8526                	mv	a0,s1
    80004718:	9d2ff0ef          	jal	ra,800038ea <brelse>
}
    8000471c:	60e2                	ld	ra,24(sp)
    8000471e:	6442                	ld	s0,16(sp)
    80004720:	64a2                	ld	s1,8(sp)
    80004722:	6902                	ld	s2,0(sp)
    80004724:	6105                	addi	sp,sp,32
    80004726:	8082                	ret

0000000080004728 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004728:	00246797          	auipc	a5,0x246
    8000472c:	2f07a783          	lw	a5,752(a5) # 8024aa18 <log+0x28>
    80004730:	0af05e63          	blez	a5,800047ec <install_trans+0xc4>
{
    80004734:	715d                	addi	sp,sp,-80
    80004736:	e486                	sd	ra,72(sp)
    80004738:	e0a2                	sd	s0,64(sp)
    8000473a:	fc26                	sd	s1,56(sp)
    8000473c:	f84a                	sd	s2,48(sp)
    8000473e:	f44e                	sd	s3,40(sp)
    80004740:	f052                	sd	s4,32(sp)
    80004742:	ec56                	sd	s5,24(sp)
    80004744:	e85a                	sd	s6,16(sp)
    80004746:	e45e                	sd	s7,8(sp)
    80004748:	0880                	addi	s0,sp,80
    8000474a:	8b2a                	mv	s6,a0
    8000474c:	00246a97          	auipc	s5,0x246
    80004750:	2d0a8a93          	addi	s5,s5,720 # 8024aa1c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004754:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004756:	00004b97          	auipc	s7,0x4
    8000475a:	edab8b93          	addi	s7,s7,-294 # 80008630 <syscalls+0x238>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000475e:	00246a17          	auipc	s4,0x246
    80004762:	292a0a13          	addi	s4,s4,658 # 8024a9f0 <log>
    80004766:	a025                	j	8000478e <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004768:	000aa603          	lw	a2,0(s5)
    8000476c:	85ce                	mv	a1,s3
    8000476e:	855e                	mv	a0,s7
    80004770:	d53fb0ef          	jal	ra,800004c2 <printf>
    80004774:	a839                	j	80004792 <install_trans+0x6a>
    brelse(lbuf);
    80004776:	854a                	mv	a0,s2
    80004778:	972ff0ef          	jal	ra,800038ea <brelse>
    brelse(dbuf);
    8000477c:	8526                	mv	a0,s1
    8000477e:	96cff0ef          	jal	ra,800038ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004782:	2985                	addiw	s3,s3,1
    80004784:	0a91                	addi	s5,s5,4
    80004786:	028a2783          	lw	a5,40(s4)
    8000478a:	04f9d663          	bge	s3,a5,800047d6 <install_trans+0xae>
    if(recovering) {
    8000478e:	fc0b1de3          	bnez	s6,80004768 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004792:	018a2583          	lw	a1,24(s4)
    80004796:	013585bb          	addw	a1,a1,s3
    8000479a:	2585                	addiw	a1,a1,1
    8000479c:	024a2503          	lw	a0,36(s4)
    800047a0:	842ff0ef          	jal	ra,800037e2 <bread>
    800047a4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800047a6:	000aa583          	lw	a1,0(s5)
    800047aa:	024a2503          	lw	a0,36(s4)
    800047ae:	834ff0ef          	jal	ra,800037e2 <bread>
    800047b2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047b4:	40000613          	li	a2,1024
    800047b8:	05890593          	addi	a1,s2,88
    800047bc:	05850513          	addi	a0,a0,88
    800047c0:	e1efc0ef          	jal	ra,80000dde <memmove>
    bwrite(dbuf);  // write dst to disk
    800047c4:	8526                	mv	a0,s1
    800047c6:	8f2ff0ef          	jal	ra,800038b8 <bwrite>
    if(recovering == 0)
    800047ca:	fa0b16e3          	bnez	s6,80004776 <install_trans+0x4e>
      bunpin(dbuf);
    800047ce:	8526                	mv	a0,s1
    800047d0:	9d8ff0ef          	jal	ra,800039a8 <bunpin>
    800047d4:	b74d                	j	80004776 <install_trans+0x4e>
}
    800047d6:	60a6                	ld	ra,72(sp)
    800047d8:	6406                	ld	s0,64(sp)
    800047da:	74e2                	ld	s1,56(sp)
    800047dc:	7942                	ld	s2,48(sp)
    800047de:	79a2                	ld	s3,40(sp)
    800047e0:	7a02                	ld	s4,32(sp)
    800047e2:	6ae2                	ld	s5,24(sp)
    800047e4:	6b42                	ld	s6,16(sp)
    800047e6:	6ba2                	ld	s7,8(sp)
    800047e8:	6161                	addi	sp,sp,80
    800047ea:	8082                	ret
    800047ec:	8082                	ret

00000000800047ee <initlog>:
{
    800047ee:	7179                	addi	sp,sp,-48
    800047f0:	f406                	sd	ra,40(sp)
    800047f2:	f022                	sd	s0,32(sp)
    800047f4:	ec26                	sd	s1,24(sp)
    800047f6:	e84a                	sd	s2,16(sp)
    800047f8:	e44e                	sd	s3,8(sp)
    800047fa:	1800                	addi	s0,sp,48
    800047fc:	892a                	mv	s2,a0
    800047fe:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004800:	00246497          	auipc	s1,0x246
    80004804:	1f048493          	addi	s1,s1,496 # 8024a9f0 <log>
    80004808:	00004597          	auipc	a1,0x4
    8000480c:	e4858593          	addi	a1,a1,-440 # 80008650 <syscalls+0x258>
    80004810:	8526                	mv	a0,s1
    80004812:	c1cfc0ef          	jal	ra,80000c2e <initlock>
  log.start = sb->logstart;
    80004816:	0149a583          	lw	a1,20(s3)
    8000481a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000481c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004820:	854a                	mv	a0,s2
    80004822:	fc1fe0ef          	jal	ra,800037e2 <bread>
  log.lh.n = lh->n;
    80004826:	4d34                	lw	a3,88(a0)
    80004828:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000482a:	02d05663          	blez	a3,80004856 <initlog+0x68>
    8000482e:	05c50793          	addi	a5,a0,92
    80004832:	00246717          	auipc	a4,0x246
    80004836:	1ea70713          	addi	a4,a4,490 # 8024aa1c <log+0x2c>
    8000483a:	36fd                	addiw	a3,a3,-1
    8000483c:	02069613          	slli	a2,a3,0x20
    80004840:	01e65693          	srli	a3,a2,0x1e
    80004844:	06050613          	addi	a2,a0,96
    80004848:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000484a:	4390                	lw	a2,0(a5)
    8000484c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000484e:	0791                	addi	a5,a5,4
    80004850:	0711                	addi	a4,a4,4
    80004852:	fed79ce3          	bne	a5,a3,8000484a <initlog+0x5c>
  brelse(buf);
    80004856:	894ff0ef          	jal	ra,800038ea <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000485a:	4505                	li	a0,1
    8000485c:	ecdff0ef          	jal	ra,80004728 <install_trans>
  log.lh.n = 0;
    80004860:	00246797          	auipc	a5,0x246
    80004864:	1a07ac23          	sw	zero,440(a5) # 8024aa18 <log+0x28>
  write_head(); // clear the log
    80004868:	e51ff0ef          	jal	ra,800046b8 <write_head>
}
    8000486c:	70a2                	ld	ra,40(sp)
    8000486e:	7402                	ld	s0,32(sp)
    80004870:	64e2                	ld	s1,24(sp)
    80004872:	6942                	ld	s2,16(sp)
    80004874:	69a2                	ld	s3,8(sp)
    80004876:	6145                	addi	sp,sp,48
    80004878:	8082                	ret

000000008000487a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000487a:	1101                	addi	sp,sp,-32
    8000487c:	ec06                	sd	ra,24(sp)
    8000487e:	e822                	sd	s0,16(sp)
    80004880:	e426                	sd	s1,8(sp)
    80004882:	e04a                	sd	s2,0(sp)
    80004884:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004886:	00246517          	auipc	a0,0x246
    8000488a:	16a50513          	addi	a0,a0,362 # 8024a9f0 <log>
    8000488e:	c20fc0ef          	jal	ra,80000cae <acquire>
  while(1){
    if(log.committing){
    80004892:	00246497          	auipc	s1,0x246
    80004896:	15e48493          	addi	s1,s1,350 # 8024a9f0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000489a:	4979                	li	s2,30
    8000489c:	a029                	j	800048a6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000489e:	85a6                	mv	a1,s1
    800048a0:	8526                	mv	a0,s1
    800048a2:	be7fd0ef          	jal	ra,80002488 <sleep>
    if(log.committing){
    800048a6:	509c                	lw	a5,32(s1)
    800048a8:	fbfd                	bnez	a5,8000489e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800048aa:	4cd8                	lw	a4,28(s1)
    800048ac:	2705                	addiw	a4,a4,1
    800048ae:	0007069b          	sext.w	a3,a4
    800048b2:	0027179b          	slliw	a5,a4,0x2
    800048b6:	9fb9                	addw	a5,a5,a4
    800048b8:	0017979b          	slliw	a5,a5,0x1
    800048bc:	5498                	lw	a4,40(s1)
    800048be:	9fb9                	addw	a5,a5,a4
    800048c0:	00f95763          	bge	s2,a5,800048ce <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048c4:	85a6                	mv	a1,s1
    800048c6:	8526                	mv	a0,s1
    800048c8:	bc1fd0ef          	jal	ra,80002488 <sleep>
    800048cc:	bfe9                	j	800048a6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800048ce:	00246517          	auipc	a0,0x246
    800048d2:	12250513          	addi	a0,a0,290 # 8024a9f0 <log>
    800048d6:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    800048d8:	c6efc0ef          	jal	ra,80000d46 <release>
      break;
    }
  }
}
    800048dc:	60e2                	ld	ra,24(sp)
    800048de:	6442                	ld	s0,16(sp)
    800048e0:	64a2                	ld	s1,8(sp)
    800048e2:	6902                	ld	s2,0(sp)
    800048e4:	6105                	addi	sp,sp,32
    800048e6:	8082                	ret

00000000800048e8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048e8:	7139                	addi	sp,sp,-64
    800048ea:	fc06                	sd	ra,56(sp)
    800048ec:	f822                	sd	s0,48(sp)
    800048ee:	f426                	sd	s1,40(sp)
    800048f0:	f04a                	sd	s2,32(sp)
    800048f2:	ec4e                	sd	s3,24(sp)
    800048f4:	e852                	sd	s4,16(sp)
    800048f6:	e456                	sd	s5,8(sp)
    800048f8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800048fa:	00246497          	auipc	s1,0x246
    800048fe:	0f648493          	addi	s1,s1,246 # 8024a9f0 <log>
    80004902:	8526                	mv	a0,s1
    80004904:	baafc0ef          	jal	ra,80000cae <acquire>
  log.outstanding -= 1;
    80004908:	4cdc                	lw	a5,28(s1)
    8000490a:	37fd                	addiw	a5,a5,-1
    8000490c:	0007891b          	sext.w	s2,a5
    80004910:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004912:	509c                	lw	a5,32(s1)
    80004914:	ef9d                	bnez	a5,80004952 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004916:	04091463          	bnez	s2,8000495e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000491a:	00246497          	auipc	s1,0x246
    8000491e:	0d648493          	addi	s1,s1,214 # 8024a9f0 <log>
    80004922:	4785                	li	a5,1
    80004924:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004926:	8526                	mv	a0,s1
    80004928:	c1efc0ef          	jal	ra,80000d46 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000492c:	549c                	lw	a5,40(s1)
    8000492e:	04f04b63          	bgtz	a5,80004984 <end_op+0x9c>
    acquire(&log.lock);
    80004932:	00246497          	auipc	s1,0x246
    80004936:	0be48493          	addi	s1,s1,190 # 8024a9f0 <log>
    8000493a:	8526                	mv	a0,s1
    8000493c:	b72fc0ef          	jal	ra,80000cae <acquire>
    log.committing = 0;
    80004940:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004944:	8526                	mv	a0,s1
    80004946:	b8ffd0ef          	jal	ra,800024d4 <wakeup>
    release(&log.lock);
    8000494a:	8526                	mv	a0,s1
    8000494c:	bfafc0ef          	jal	ra,80000d46 <release>
}
    80004950:	a00d                	j	80004972 <end_op+0x8a>
    panic("log.committing");
    80004952:	00004517          	auipc	a0,0x4
    80004956:	d0650513          	addi	a0,a0,-762 # 80008658 <syscalls+0x260>
    8000495a:	e2ffb0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    8000495e:	00246497          	auipc	s1,0x246
    80004962:	09248493          	addi	s1,s1,146 # 8024a9f0 <log>
    80004966:	8526                	mv	a0,s1
    80004968:	b6dfd0ef          	jal	ra,800024d4 <wakeup>
  release(&log.lock);
    8000496c:	8526                	mv	a0,s1
    8000496e:	bd8fc0ef          	jal	ra,80000d46 <release>
}
    80004972:	70e2                	ld	ra,56(sp)
    80004974:	7442                	ld	s0,48(sp)
    80004976:	74a2                	ld	s1,40(sp)
    80004978:	7902                	ld	s2,32(sp)
    8000497a:	69e2                	ld	s3,24(sp)
    8000497c:	6a42                	ld	s4,16(sp)
    8000497e:	6aa2                	ld	s5,8(sp)
    80004980:	6121                	addi	sp,sp,64
    80004982:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004984:	00246a97          	auipc	s5,0x246
    80004988:	098a8a93          	addi	s5,s5,152 # 8024aa1c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000498c:	00246a17          	auipc	s4,0x246
    80004990:	064a0a13          	addi	s4,s4,100 # 8024a9f0 <log>
    80004994:	018a2583          	lw	a1,24(s4)
    80004998:	012585bb          	addw	a1,a1,s2
    8000499c:	2585                	addiw	a1,a1,1
    8000499e:	024a2503          	lw	a0,36(s4)
    800049a2:	e41fe0ef          	jal	ra,800037e2 <bread>
    800049a6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049a8:	000aa583          	lw	a1,0(s5)
    800049ac:	024a2503          	lw	a0,36(s4)
    800049b0:	e33fe0ef          	jal	ra,800037e2 <bread>
    800049b4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049b6:	40000613          	li	a2,1024
    800049ba:	05850593          	addi	a1,a0,88
    800049be:	05848513          	addi	a0,s1,88
    800049c2:	c1cfc0ef          	jal	ra,80000dde <memmove>
    bwrite(to);  // write the log
    800049c6:	8526                	mv	a0,s1
    800049c8:	ef1fe0ef          	jal	ra,800038b8 <bwrite>
    brelse(from);
    800049cc:	854e                	mv	a0,s3
    800049ce:	f1dfe0ef          	jal	ra,800038ea <brelse>
    brelse(to);
    800049d2:	8526                	mv	a0,s1
    800049d4:	f17fe0ef          	jal	ra,800038ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049d8:	2905                	addiw	s2,s2,1
    800049da:	0a91                	addi	s5,s5,4
    800049dc:	028a2783          	lw	a5,40(s4)
    800049e0:	faf94ae3          	blt	s2,a5,80004994 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800049e4:	cd5ff0ef          	jal	ra,800046b8 <write_head>
    install_trans(0); // Now install writes to home locations
    800049e8:	4501                	li	a0,0
    800049ea:	d3fff0ef          	jal	ra,80004728 <install_trans>
    log.lh.n = 0;
    800049ee:	00246797          	auipc	a5,0x246
    800049f2:	0207a523          	sw	zero,42(a5) # 8024aa18 <log+0x28>
    write_head();    // Erase the transaction from the log
    800049f6:	cc3ff0ef          	jal	ra,800046b8 <write_head>
    800049fa:	bf25                	j	80004932 <end_op+0x4a>

00000000800049fc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800049fc:	1101                	addi	sp,sp,-32
    800049fe:	ec06                	sd	ra,24(sp)
    80004a00:	e822                	sd	s0,16(sp)
    80004a02:	e426                	sd	s1,8(sp)
    80004a04:	e04a                	sd	s2,0(sp)
    80004a06:	1000                	addi	s0,sp,32
    80004a08:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a0a:	00246917          	auipc	s2,0x246
    80004a0e:	fe690913          	addi	s2,s2,-26 # 8024a9f0 <log>
    80004a12:	854a                	mv	a0,s2
    80004a14:	a9afc0ef          	jal	ra,80000cae <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004a18:	02892603          	lw	a2,40(s2)
    80004a1c:	47f5                	li	a5,29
    80004a1e:	04c7cc63          	blt	a5,a2,80004a76 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a22:	00246797          	auipc	a5,0x246
    80004a26:	fea7a783          	lw	a5,-22(a5) # 8024aa0c <log+0x1c>
    80004a2a:	04f05c63          	blez	a5,80004a82 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a2e:	4781                	li	a5,0
    80004a30:	04c05f63          	blez	a2,80004a8e <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a34:	44cc                	lw	a1,12(s1)
    80004a36:	00246717          	auipc	a4,0x246
    80004a3a:	fe670713          	addi	a4,a4,-26 # 8024aa1c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004a3e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a40:	4314                	lw	a3,0(a4)
    80004a42:	04b68663          	beq	a3,a1,80004a8e <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004a46:	2785                	addiw	a5,a5,1
    80004a48:	0711                	addi	a4,a4,4
    80004a4a:	fef61be3          	bne	a2,a5,80004a40 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a4e:	0621                	addi	a2,a2,8
    80004a50:	060a                	slli	a2,a2,0x2
    80004a52:	00246797          	auipc	a5,0x246
    80004a56:	f9e78793          	addi	a5,a5,-98 # 8024a9f0 <log>
    80004a5a:	97b2                	add	a5,a5,a2
    80004a5c:	44d8                	lw	a4,12(s1)
    80004a5e:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004a60:	8526                	mv	a0,s1
    80004a62:	f13fe0ef          	jal	ra,80003974 <bpin>
    log.lh.n++;
    80004a66:	00246717          	auipc	a4,0x246
    80004a6a:	f8a70713          	addi	a4,a4,-118 # 8024a9f0 <log>
    80004a6e:	571c                	lw	a5,40(a4)
    80004a70:	2785                	addiw	a5,a5,1
    80004a72:	d71c                	sw	a5,40(a4)
    80004a74:	a80d                	j	80004aa6 <log_write+0xaa>
    panic("too big a transaction");
    80004a76:	00004517          	auipc	a0,0x4
    80004a7a:	bf250513          	addi	a0,a0,-1038 # 80008668 <syscalls+0x270>
    80004a7e:	d0bfb0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    80004a82:	00004517          	auipc	a0,0x4
    80004a86:	bfe50513          	addi	a0,a0,-1026 # 80008680 <syscalls+0x288>
    80004a8a:	cfffb0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    80004a8e:	00878693          	addi	a3,a5,8
    80004a92:	068a                	slli	a3,a3,0x2
    80004a94:	00246717          	auipc	a4,0x246
    80004a98:	f5c70713          	addi	a4,a4,-164 # 8024a9f0 <log>
    80004a9c:	9736                	add	a4,a4,a3
    80004a9e:	44d4                	lw	a3,12(s1)
    80004aa0:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004aa2:	faf60fe3          	beq	a2,a5,80004a60 <log_write+0x64>
  }
  release(&log.lock);
    80004aa6:	00246517          	auipc	a0,0x246
    80004aaa:	f4a50513          	addi	a0,a0,-182 # 8024a9f0 <log>
    80004aae:	a98fc0ef          	jal	ra,80000d46 <release>
}
    80004ab2:	60e2                	ld	ra,24(sp)
    80004ab4:	6442                	ld	s0,16(sp)
    80004ab6:	64a2                	ld	s1,8(sp)
    80004ab8:	6902                	ld	s2,0(sp)
    80004aba:	6105                	addi	sp,sp,32
    80004abc:	8082                	ret

0000000080004abe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004abe:	1101                	addi	sp,sp,-32
    80004ac0:	ec06                	sd	ra,24(sp)
    80004ac2:	e822                	sd	s0,16(sp)
    80004ac4:	e426                	sd	s1,8(sp)
    80004ac6:	e04a                	sd	s2,0(sp)
    80004ac8:	1000                	addi	s0,sp,32
    80004aca:	84aa                	mv	s1,a0
    80004acc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004ace:	00004597          	auipc	a1,0x4
    80004ad2:	bd258593          	addi	a1,a1,-1070 # 800086a0 <syscalls+0x2a8>
    80004ad6:	0521                	addi	a0,a0,8
    80004ad8:	956fc0ef          	jal	ra,80000c2e <initlock>
  lk->name = name;
    80004adc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004ae0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ae4:	0204a423          	sw	zero,40(s1)
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	64a2                	ld	s1,8(sp)
    80004aee:	6902                	ld	s2,0(sp)
    80004af0:	6105                	addi	sp,sp,32
    80004af2:	8082                	ret

0000000080004af4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004af4:	1101                	addi	sp,sp,-32
    80004af6:	ec06                	sd	ra,24(sp)
    80004af8:	e822                	sd	s0,16(sp)
    80004afa:	e426                	sd	s1,8(sp)
    80004afc:	e04a                	sd	s2,0(sp)
    80004afe:	1000                	addi	s0,sp,32
    80004b00:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b02:	00850913          	addi	s2,a0,8
    80004b06:	854a                	mv	a0,s2
    80004b08:	9a6fc0ef          	jal	ra,80000cae <acquire>
  while (lk->locked) {
    80004b0c:	409c                	lw	a5,0(s1)
    80004b0e:	c799                	beqz	a5,80004b1c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004b10:	85ca                	mv	a1,s2
    80004b12:	8526                	mv	a0,s1
    80004b14:	975fd0ef          	jal	ra,80002488 <sleep>
  while (lk->locked) {
    80004b18:	409c                	lw	a5,0(s1)
    80004b1a:	fbfd                	bnez	a5,80004b10 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004b1c:	4785                	li	a5,1
    80004b1e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b20:	878fd0ef          	jal	ra,80001b98 <myproc>
    80004b24:	591c                	lw	a5,48(a0)
    80004b26:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b28:	854a                	mv	a0,s2
    80004b2a:	a1cfc0ef          	jal	ra,80000d46 <release>
}
    80004b2e:	60e2                	ld	ra,24(sp)
    80004b30:	6442                	ld	s0,16(sp)
    80004b32:	64a2                	ld	s1,8(sp)
    80004b34:	6902                	ld	s2,0(sp)
    80004b36:	6105                	addi	sp,sp,32
    80004b38:	8082                	ret

0000000080004b3a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b3a:	1101                	addi	sp,sp,-32
    80004b3c:	ec06                	sd	ra,24(sp)
    80004b3e:	e822                	sd	s0,16(sp)
    80004b40:	e426                	sd	s1,8(sp)
    80004b42:	e04a                	sd	s2,0(sp)
    80004b44:	1000                	addi	s0,sp,32
    80004b46:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b48:	00850913          	addi	s2,a0,8
    80004b4c:	854a                	mv	a0,s2
    80004b4e:	960fc0ef          	jal	ra,80000cae <acquire>
  lk->locked = 0;
    80004b52:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b56:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	979fd0ef          	jal	ra,800024d4 <wakeup>
  release(&lk->lk);
    80004b60:	854a                	mv	a0,s2
    80004b62:	9e4fc0ef          	jal	ra,80000d46 <release>
}
    80004b66:	60e2                	ld	ra,24(sp)
    80004b68:	6442                	ld	s0,16(sp)
    80004b6a:	64a2                	ld	s1,8(sp)
    80004b6c:	6902                	ld	s2,0(sp)
    80004b6e:	6105                	addi	sp,sp,32
    80004b70:	8082                	ret

0000000080004b72 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b72:	7179                	addi	sp,sp,-48
    80004b74:	f406                	sd	ra,40(sp)
    80004b76:	f022                	sd	s0,32(sp)
    80004b78:	ec26                	sd	s1,24(sp)
    80004b7a:	e84a                	sd	s2,16(sp)
    80004b7c:	e44e                	sd	s3,8(sp)
    80004b7e:	1800                	addi	s0,sp,48
    80004b80:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b82:	00850913          	addi	s2,a0,8
    80004b86:	854a                	mv	a0,s2
    80004b88:	926fc0ef          	jal	ra,80000cae <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b8c:	409c                	lw	a5,0(s1)
    80004b8e:	ef89                	bnez	a5,80004ba8 <holdingsleep+0x36>
    80004b90:	4481                	li	s1,0
  release(&lk->lk);
    80004b92:	854a                	mv	a0,s2
    80004b94:	9b2fc0ef          	jal	ra,80000d46 <release>
  return r;
}
    80004b98:	8526                	mv	a0,s1
    80004b9a:	70a2                	ld	ra,40(sp)
    80004b9c:	7402                	ld	s0,32(sp)
    80004b9e:	64e2                	ld	s1,24(sp)
    80004ba0:	6942                	ld	s2,16(sp)
    80004ba2:	69a2                	ld	s3,8(sp)
    80004ba4:	6145                	addi	sp,sp,48
    80004ba6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ba8:	0284a983          	lw	s3,40(s1)
    80004bac:	fedfc0ef          	jal	ra,80001b98 <myproc>
    80004bb0:	5904                	lw	s1,48(a0)
    80004bb2:	413484b3          	sub	s1,s1,s3
    80004bb6:	0014b493          	seqz	s1,s1
    80004bba:	bfe1                	j	80004b92 <holdingsleep+0x20>

0000000080004bbc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004bbc:	1141                	addi	sp,sp,-16
    80004bbe:	e406                	sd	ra,8(sp)
    80004bc0:	e022                	sd	s0,0(sp)
    80004bc2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004bc4:	00004597          	auipc	a1,0x4
    80004bc8:	aec58593          	addi	a1,a1,-1300 # 800086b0 <syscalls+0x2b8>
    80004bcc:	00246517          	auipc	a0,0x246
    80004bd0:	f6c50513          	addi	a0,a0,-148 # 8024ab38 <ftable>
    80004bd4:	85afc0ef          	jal	ra,80000c2e <initlock>
}
    80004bd8:	60a2                	ld	ra,8(sp)
    80004bda:	6402                	ld	s0,0(sp)
    80004bdc:	0141                	addi	sp,sp,16
    80004bde:	8082                	ret

0000000080004be0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004be0:	1101                	addi	sp,sp,-32
    80004be2:	ec06                	sd	ra,24(sp)
    80004be4:	e822                	sd	s0,16(sp)
    80004be6:	e426                	sd	s1,8(sp)
    80004be8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004bea:	00246517          	auipc	a0,0x246
    80004bee:	f4e50513          	addi	a0,a0,-178 # 8024ab38 <ftable>
    80004bf2:	8bcfc0ef          	jal	ra,80000cae <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bf6:	00246497          	auipc	s1,0x246
    80004bfa:	f5a48493          	addi	s1,s1,-166 # 8024ab50 <ftable+0x18>
    80004bfe:	00247717          	auipc	a4,0x247
    80004c02:	ef270713          	addi	a4,a4,-270 # 8024baf0 <disk>
    if(f->ref == 0){
    80004c06:	40dc                	lw	a5,4(s1)
    80004c08:	cf89                	beqz	a5,80004c22 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c0a:	02848493          	addi	s1,s1,40
    80004c0e:	fee49ce3          	bne	s1,a4,80004c06 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c12:	00246517          	auipc	a0,0x246
    80004c16:	f2650513          	addi	a0,a0,-218 # 8024ab38 <ftable>
    80004c1a:	92cfc0ef          	jal	ra,80000d46 <release>
  return 0;
    80004c1e:	4481                	li	s1,0
    80004c20:	a809                	j	80004c32 <filealloc+0x52>
      f->ref = 1;
    80004c22:	4785                	li	a5,1
    80004c24:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c26:	00246517          	auipc	a0,0x246
    80004c2a:	f1250513          	addi	a0,a0,-238 # 8024ab38 <ftable>
    80004c2e:	918fc0ef          	jal	ra,80000d46 <release>
}
    80004c32:	8526                	mv	a0,s1
    80004c34:	60e2                	ld	ra,24(sp)
    80004c36:	6442                	ld	s0,16(sp)
    80004c38:	64a2                	ld	s1,8(sp)
    80004c3a:	6105                	addi	sp,sp,32
    80004c3c:	8082                	ret

0000000080004c3e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c3e:	1101                	addi	sp,sp,-32
    80004c40:	ec06                	sd	ra,24(sp)
    80004c42:	e822                	sd	s0,16(sp)
    80004c44:	e426                	sd	s1,8(sp)
    80004c46:	1000                	addi	s0,sp,32
    80004c48:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c4a:	00246517          	auipc	a0,0x246
    80004c4e:	eee50513          	addi	a0,a0,-274 # 8024ab38 <ftable>
    80004c52:	85cfc0ef          	jal	ra,80000cae <acquire>
  if(f->ref < 1)
    80004c56:	40dc                	lw	a5,4(s1)
    80004c58:	02f05063          	blez	a5,80004c78 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004c5c:	2785                	addiw	a5,a5,1
    80004c5e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c60:	00246517          	auipc	a0,0x246
    80004c64:	ed850513          	addi	a0,a0,-296 # 8024ab38 <ftable>
    80004c68:	8defc0ef          	jal	ra,80000d46 <release>
  return f;
}
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	60e2                	ld	ra,24(sp)
    80004c70:	6442                	ld	s0,16(sp)
    80004c72:	64a2                	ld	s1,8(sp)
    80004c74:	6105                	addi	sp,sp,32
    80004c76:	8082                	ret
    panic("filedup");
    80004c78:	00004517          	auipc	a0,0x4
    80004c7c:	a4050513          	addi	a0,a0,-1472 # 800086b8 <syscalls+0x2c0>
    80004c80:	b09fb0ef          	jal	ra,80000788 <panic>

0000000080004c84 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c84:	7139                	addi	sp,sp,-64
    80004c86:	fc06                	sd	ra,56(sp)
    80004c88:	f822                	sd	s0,48(sp)
    80004c8a:	f426                	sd	s1,40(sp)
    80004c8c:	f04a                	sd	s2,32(sp)
    80004c8e:	ec4e                	sd	s3,24(sp)
    80004c90:	e852                	sd	s4,16(sp)
    80004c92:	e456                	sd	s5,8(sp)
    80004c94:	0080                	addi	s0,sp,64
    80004c96:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c98:	00246517          	auipc	a0,0x246
    80004c9c:	ea050513          	addi	a0,a0,-352 # 8024ab38 <ftable>
    80004ca0:	80efc0ef          	jal	ra,80000cae <acquire>
  if(f->ref < 1)
    80004ca4:	40dc                	lw	a5,4(s1)
    80004ca6:	04f05963          	blez	a5,80004cf8 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004caa:	37fd                	addiw	a5,a5,-1
    80004cac:	0007871b          	sext.w	a4,a5
    80004cb0:	c0dc                	sw	a5,4(s1)
    80004cb2:	04e04963          	bgtz	a4,80004d04 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004cb6:	0004a903          	lw	s2,0(s1)
    80004cba:	0094ca83          	lbu	s5,9(s1)
    80004cbe:	0104ba03          	ld	s4,16(s1)
    80004cc2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004cc6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004cca:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004cce:	00246517          	auipc	a0,0x246
    80004cd2:	e6a50513          	addi	a0,a0,-406 # 8024ab38 <ftable>
    80004cd6:	870fc0ef          	jal	ra,80000d46 <release>

  if(ff.type == FD_PIPE){
    80004cda:	4785                	li	a5,1
    80004cdc:	04f90363          	beq	s2,a5,80004d22 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ce0:	3979                	addiw	s2,s2,-2
    80004ce2:	4785                	li	a5,1
    80004ce4:	0327e663          	bltu	a5,s2,80004d10 <fileclose+0x8c>
    begin_op();
    80004ce8:	b93ff0ef          	jal	ra,8000487a <begin_op>
    iput(ff.ip);
    80004cec:	854e                	mv	a0,s3
    80004cee:	b22ff0ef          	jal	ra,80004010 <iput>
    end_op();
    80004cf2:	bf7ff0ef          	jal	ra,800048e8 <end_op>
    80004cf6:	a829                	j	80004d10 <fileclose+0x8c>
    panic("fileclose");
    80004cf8:	00004517          	auipc	a0,0x4
    80004cfc:	9c850513          	addi	a0,a0,-1592 # 800086c0 <syscalls+0x2c8>
    80004d00:	a89fb0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    80004d04:	00246517          	auipc	a0,0x246
    80004d08:	e3450513          	addi	a0,a0,-460 # 8024ab38 <ftable>
    80004d0c:	83afc0ef          	jal	ra,80000d46 <release>
  }
}
    80004d10:	70e2                	ld	ra,56(sp)
    80004d12:	7442                	ld	s0,48(sp)
    80004d14:	74a2                	ld	s1,40(sp)
    80004d16:	7902                	ld	s2,32(sp)
    80004d18:	69e2                	ld	s3,24(sp)
    80004d1a:	6a42                	ld	s4,16(sp)
    80004d1c:	6aa2                	ld	s5,8(sp)
    80004d1e:	6121                	addi	sp,sp,64
    80004d20:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d22:	85d6                	mv	a1,s5
    80004d24:	8552                	mv	a0,s4
    80004d26:	2ec000ef          	jal	ra,80005012 <pipeclose>
    80004d2a:	b7dd                	j	80004d10 <fileclose+0x8c>

0000000080004d2c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d2c:	715d                	addi	sp,sp,-80
    80004d2e:	e486                	sd	ra,72(sp)
    80004d30:	e0a2                	sd	s0,64(sp)
    80004d32:	fc26                	sd	s1,56(sp)
    80004d34:	f84a                	sd	s2,48(sp)
    80004d36:	f44e                	sd	s3,40(sp)
    80004d38:	0880                	addi	s0,sp,80
    80004d3a:	84aa                	mv	s1,a0
    80004d3c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d3e:	e5bfc0ef          	jal	ra,80001b98 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d42:	409c                	lw	a5,0(s1)
    80004d44:	37f9                	addiw	a5,a5,-2
    80004d46:	4705                	li	a4,1
    80004d48:	02f76f63          	bltu	a4,a5,80004d86 <filestat+0x5a>
    80004d4c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d4e:	6c88                	ld	a0,24(s1)
    80004d50:	942ff0ef          	jal	ra,80003e92 <ilock>
    stati(f->ip, &st);
    80004d54:	fb840593          	addi	a1,s0,-72
    80004d58:	6c88                	ld	a0,24(s1)
    80004d5a:	c9aff0ef          	jal	ra,800041f4 <stati>
    iunlock(f->ip);
    80004d5e:	6c88                	ld	a0,24(s1)
    80004d60:	9dcff0ef          	jal	ra,80003f3c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d64:	46e1                	li	a3,24
    80004d66:	fb840613          	addi	a2,s0,-72
    80004d6a:	85ce                	mv	a1,s3
    80004d6c:	05093503          	ld	a0,80(s2)
    80004d70:	a19fc0ef          	jal	ra,80001788 <copyout>
    80004d74:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d78:	60a6                	ld	ra,72(sp)
    80004d7a:	6406                	ld	s0,64(sp)
    80004d7c:	74e2                	ld	s1,56(sp)
    80004d7e:	7942                	ld	s2,48(sp)
    80004d80:	79a2                	ld	s3,40(sp)
    80004d82:	6161                	addi	sp,sp,80
    80004d84:	8082                	ret
  return -1;
    80004d86:	557d                	li	a0,-1
    80004d88:	bfc5                	j	80004d78 <filestat+0x4c>

0000000080004d8a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d8a:	7179                	addi	sp,sp,-48
    80004d8c:	f406                	sd	ra,40(sp)
    80004d8e:	f022                	sd	s0,32(sp)
    80004d90:	ec26                	sd	s1,24(sp)
    80004d92:	e84a                	sd	s2,16(sp)
    80004d94:	e44e                	sd	s3,8(sp)
    80004d96:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d98:	00854783          	lbu	a5,8(a0)
    80004d9c:	cbc1                	beqz	a5,80004e2c <fileread+0xa2>
    80004d9e:	84aa                	mv	s1,a0
    80004da0:	89ae                	mv	s3,a1
    80004da2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004da4:	411c                	lw	a5,0(a0)
    80004da6:	4705                	li	a4,1
    80004da8:	04e78363          	beq	a5,a4,80004dee <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dac:	470d                	li	a4,3
    80004dae:	04e78563          	beq	a5,a4,80004df8 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004db2:	4709                	li	a4,2
    80004db4:	06e79663          	bne	a5,a4,80004e20 <fileread+0x96>
    ilock(f->ip);
    80004db8:	6d08                	ld	a0,24(a0)
    80004dba:	8d8ff0ef          	jal	ra,80003e92 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dbe:	874a                	mv	a4,s2
    80004dc0:	5094                	lw	a3,32(s1)
    80004dc2:	864e                	mv	a2,s3
    80004dc4:	4585                	li	a1,1
    80004dc6:	6c88                	ld	a0,24(s1)
    80004dc8:	c56ff0ef          	jal	ra,8000421e <readi>
    80004dcc:	892a                	mv	s2,a0
    80004dce:	00a05563          	blez	a0,80004dd8 <fileread+0x4e>
      f->off += r;
    80004dd2:	509c                	lw	a5,32(s1)
    80004dd4:	9fa9                	addw	a5,a5,a0
    80004dd6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004dd8:	6c88                	ld	a0,24(s1)
    80004dda:	962ff0ef          	jal	ra,80003f3c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004dde:	854a                	mv	a0,s2
    80004de0:	70a2                	ld	ra,40(sp)
    80004de2:	7402                	ld	s0,32(sp)
    80004de4:	64e2                	ld	s1,24(sp)
    80004de6:	6942                	ld	s2,16(sp)
    80004de8:	69a2                	ld	s3,8(sp)
    80004dea:	6145                	addi	sp,sp,48
    80004dec:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004dee:	6908                	ld	a0,16(a0)
    80004df0:	34e000ef          	jal	ra,8000513e <piperead>
    80004df4:	892a                	mv	s2,a0
    80004df6:	b7e5                	j	80004dde <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004df8:	02451783          	lh	a5,36(a0)
    80004dfc:	03079693          	slli	a3,a5,0x30
    80004e00:	92c1                	srli	a3,a3,0x30
    80004e02:	4725                	li	a4,9
    80004e04:	02d76663          	bltu	a4,a3,80004e30 <fileread+0xa6>
    80004e08:	0792                	slli	a5,a5,0x4
    80004e0a:	00246717          	auipc	a4,0x246
    80004e0e:	c8e70713          	addi	a4,a4,-882 # 8024aa98 <devsw>
    80004e12:	97ba                	add	a5,a5,a4
    80004e14:	639c                	ld	a5,0(a5)
    80004e16:	cf99                	beqz	a5,80004e34 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004e18:	4505                	li	a0,1
    80004e1a:	9782                	jalr	a5
    80004e1c:	892a                	mv	s2,a0
    80004e1e:	b7c1                	j	80004dde <fileread+0x54>
    panic("fileread");
    80004e20:	00004517          	auipc	a0,0x4
    80004e24:	8b050513          	addi	a0,a0,-1872 # 800086d0 <syscalls+0x2d8>
    80004e28:	961fb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004e2c:	597d                	li	s2,-1
    80004e2e:	bf45                	j	80004dde <fileread+0x54>
      return -1;
    80004e30:	597d                	li	s2,-1
    80004e32:	b775                	j	80004dde <fileread+0x54>
    80004e34:	597d                	li	s2,-1
    80004e36:	b765                	j	80004dde <fileread+0x54>

0000000080004e38 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e38:	715d                	addi	sp,sp,-80
    80004e3a:	e486                	sd	ra,72(sp)
    80004e3c:	e0a2                	sd	s0,64(sp)
    80004e3e:	fc26                	sd	s1,56(sp)
    80004e40:	f84a                	sd	s2,48(sp)
    80004e42:	f44e                	sd	s3,40(sp)
    80004e44:	f052                	sd	s4,32(sp)
    80004e46:	ec56                	sd	s5,24(sp)
    80004e48:	e85a                	sd	s6,16(sp)
    80004e4a:	e45e                	sd	s7,8(sp)
    80004e4c:	e062                	sd	s8,0(sp)
    80004e4e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e50:	00954783          	lbu	a5,9(a0)
    80004e54:	0e078863          	beqz	a5,80004f44 <filewrite+0x10c>
    80004e58:	892a                	mv	s2,a0
    80004e5a:	8b2e                	mv	s6,a1
    80004e5c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e5e:	411c                	lw	a5,0(a0)
    80004e60:	4705                	li	a4,1
    80004e62:	02e78263          	beq	a5,a4,80004e86 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e66:	470d                	li	a4,3
    80004e68:	02e78463          	beq	a5,a4,80004e90 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e6c:	4709                	li	a4,2
    80004e6e:	0ce79563          	bne	a5,a4,80004f38 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e72:	0ac05163          	blez	a2,80004f14 <filewrite+0xdc>
    int i = 0;
    80004e76:	4981                	li	s3,0
    80004e78:	6b85                	lui	s7,0x1
    80004e7a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004e7e:	6c05                	lui	s8,0x1
    80004e80:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004e84:	a041                	j	80004f04 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004e86:	6908                	ld	a0,16(a0)
    80004e88:	1e2000ef          	jal	ra,8000506a <pipewrite>
    80004e8c:	8a2a                	mv	s4,a0
    80004e8e:	a071                	j	80004f1a <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e90:	02451783          	lh	a5,36(a0)
    80004e94:	03079693          	slli	a3,a5,0x30
    80004e98:	92c1                	srli	a3,a3,0x30
    80004e9a:	4725                	li	a4,9
    80004e9c:	0ad76663          	bltu	a4,a3,80004f48 <filewrite+0x110>
    80004ea0:	0792                	slli	a5,a5,0x4
    80004ea2:	00246717          	auipc	a4,0x246
    80004ea6:	bf670713          	addi	a4,a4,-1034 # 8024aa98 <devsw>
    80004eaa:	97ba                	add	a5,a5,a4
    80004eac:	679c                	ld	a5,8(a5)
    80004eae:	cfd9                	beqz	a5,80004f4c <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004eb0:	4505                	li	a0,1
    80004eb2:	9782                	jalr	a5
    80004eb4:	8a2a                	mv	s4,a0
    80004eb6:	a095                	j	80004f1a <filewrite+0xe2>
    80004eb8:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ebc:	9bfff0ef          	jal	ra,8000487a <begin_op>
      ilock(f->ip);
    80004ec0:	01893503          	ld	a0,24(s2)
    80004ec4:	fcffe0ef          	jal	ra,80003e92 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ec8:	8756                	mv	a4,s5
    80004eca:	02092683          	lw	a3,32(s2)
    80004ece:	01698633          	add	a2,s3,s6
    80004ed2:	4585                	li	a1,1
    80004ed4:	01893503          	ld	a0,24(s2)
    80004ed8:	c2aff0ef          	jal	ra,80004302 <writei>
    80004edc:	84aa                	mv	s1,a0
    80004ede:	00a05763          	blez	a0,80004eec <filewrite+0xb4>
        f->off += r;
    80004ee2:	02092783          	lw	a5,32(s2)
    80004ee6:	9fa9                	addw	a5,a5,a0
    80004ee8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004eec:	01893503          	ld	a0,24(s2)
    80004ef0:	84cff0ef          	jal	ra,80003f3c <iunlock>
      end_op();
    80004ef4:	9f5ff0ef          	jal	ra,800048e8 <end_op>

      if(r != n1){
    80004ef8:	009a9f63          	bne	s5,s1,80004f16 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004efc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f00:	0149db63          	bge	s3,s4,80004f16 <filewrite+0xde>
      int n1 = n - i;
    80004f04:	413a04bb          	subw	s1,s4,s3
    80004f08:	0004879b          	sext.w	a5,s1
    80004f0c:	fafbd6e3          	bge	s7,a5,80004eb8 <filewrite+0x80>
    80004f10:	84e2                	mv	s1,s8
    80004f12:	b75d                	j	80004eb8 <filewrite+0x80>
    int i = 0;
    80004f14:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f16:	013a1f63          	bne	s4,s3,80004f34 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f1a:	8552                	mv	a0,s4
    80004f1c:	60a6                	ld	ra,72(sp)
    80004f1e:	6406                	ld	s0,64(sp)
    80004f20:	74e2                	ld	s1,56(sp)
    80004f22:	7942                	ld	s2,48(sp)
    80004f24:	79a2                	ld	s3,40(sp)
    80004f26:	7a02                	ld	s4,32(sp)
    80004f28:	6ae2                	ld	s5,24(sp)
    80004f2a:	6b42                	ld	s6,16(sp)
    80004f2c:	6ba2                	ld	s7,8(sp)
    80004f2e:	6c02                	ld	s8,0(sp)
    80004f30:	6161                	addi	sp,sp,80
    80004f32:	8082                	ret
    ret = (i == n ? n : -1);
    80004f34:	5a7d                	li	s4,-1
    80004f36:	b7d5                	j	80004f1a <filewrite+0xe2>
    panic("filewrite");
    80004f38:	00003517          	auipc	a0,0x3
    80004f3c:	7a850513          	addi	a0,a0,1960 # 800086e0 <syscalls+0x2e8>
    80004f40:	849fb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004f44:	5a7d                	li	s4,-1
    80004f46:	bfd1                	j	80004f1a <filewrite+0xe2>
      return -1;
    80004f48:	5a7d                	li	s4,-1
    80004f4a:	bfc1                	j	80004f1a <filewrite+0xe2>
    80004f4c:	5a7d                	li	s4,-1
    80004f4e:	b7f1                	j	80004f1a <filewrite+0xe2>

0000000080004f50 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f50:	7179                	addi	sp,sp,-48
    80004f52:	f406                	sd	ra,40(sp)
    80004f54:	f022                	sd	s0,32(sp)
    80004f56:	ec26                	sd	s1,24(sp)
    80004f58:	e84a                	sd	s2,16(sp)
    80004f5a:	e44e                	sd	s3,8(sp)
    80004f5c:	e052                	sd	s4,0(sp)
    80004f5e:	1800                	addi	s0,sp,48
    80004f60:	84aa                	mv	s1,a0
    80004f62:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f64:	0005b023          	sd	zero,0(a1)
    80004f68:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f6c:	c75ff0ef          	jal	ra,80004be0 <filealloc>
    80004f70:	e088                	sd	a0,0(s1)
    80004f72:	cd35                	beqz	a0,80004fee <pipealloc+0x9e>
    80004f74:	c6dff0ef          	jal	ra,80004be0 <filealloc>
    80004f78:	00aa3023          	sd	a0,0(s4)
    80004f7c:	c52d                	beqz	a0,80004fe6 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f7e:	c2dfb0ef          	jal	ra,80000baa <kalloc>
    80004f82:	892a                	mv	s2,a0
    80004f84:	cd31                	beqz	a0,80004fe0 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004f86:	4985                	li	s3,1
    80004f88:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f8c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f90:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f94:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f98:	00003597          	auipc	a1,0x3
    80004f9c:	75858593          	addi	a1,a1,1880 # 800086f0 <syscalls+0x2f8>
    80004fa0:	c8ffb0ef          	jal	ra,80000c2e <initlock>
  (*f0)->type = FD_PIPE;
    80004fa4:	609c                	ld	a5,0(s1)
    80004fa6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004faa:	609c                	ld	a5,0(s1)
    80004fac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004fb0:	609c                	ld	a5,0(s1)
    80004fb2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004fb6:	609c                	ld	a5,0(s1)
    80004fb8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004fbc:	000a3783          	ld	a5,0(s4)
    80004fc0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004fc4:	000a3783          	ld	a5,0(s4)
    80004fc8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004fcc:	000a3783          	ld	a5,0(s4)
    80004fd0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004fd4:	000a3783          	ld	a5,0(s4)
    80004fd8:	0127b823          	sd	s2,16(a5)
  return 0;
    80004fdc:	4501                	li	a0,0
    80004fde:	a005                	j	80004ffe <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004fe0:	6088                	ld	a0,0(s1)
    80004fe2:	e501                	bnez	a0,80004fea <pipealloc+0x9a>
    80004fe4:	a029                	j	80004fee <pipealloc+0x9e>
    80004fe6:	6088                	ld	a0,0(s1)
    80004fe8:	c11d                	beqz	a0,8000500e <pipealloc+0xbe>
    fileclose(*f0);
    80004fea:	c9bff0ef          	jal	ra,80004c84 <fileclose>
  if(*f1)
    80004fee:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ff2:	557d                	li	a0,-1
  if(*f1)
    80004ff4:	c789                	beqz	a5,80004ffe <pipealloc+0xae>
    fileclose(*f1);
    80004ff6:	853e                	mv	a0,a5
    80004ff8:	c8dff0ef          	jal	ra,80004c84 <fileclose>
  return -1;
    80004ffc:	557d                	li	a0,-1
}
    80004ffe:	70a2                	ld	ra,40(sp)
    80005000:	7402                	ld	s0,32(sp)
    80005002:	64e2                	ld	s1,24(sp)
    80005004:	6942                	ld	s2,16(sp)
    80005006:	69a2                	ld	s3,8(sp)
    80005008:	6a02                	ld	s4,0(sp)
    8000500a:	6145                	addi	sp,sp,48
    8000500c:	8082                	ret
  return -1;
    8000500e:	557d                	li	a0,-1
    80005010:	b7fd                	j	80004ffe <pipealloc+0xae>

0000000080005012 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005012:	1101                	addi	sp,sp,-32
    80005014:	ec06                	sd	ra,24(sp)
    80005016:	e822                	sd	s0,16(sp)
    80005018:	e426                	sd	s1,8(sp)
    8000501a:	e04a                	sd	s2,0(sp)
    8000501c:	1000                	addi	s0,sp,32
    8000501e:	84aa                	mv	s1,a0
    80005020:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005022:	c8dfb0ef          	jal	ra,80000cae <acquire>
  if(writable){
    80005026:	02090763          	beqz	s2,80005054 <pipeclose+0x42>
    pi->writeopen = 0;
    8000502a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000502e:	21848513          	addi	a0,s1,536
    80005032:	ca2fd0ef          	jal	ra,800024d4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005036:	2204b783          	ld	a5,544(s1)
    8000503a:	e785                	bnez	a5,80005062 <pipeclose+0x50>
    release(&pi->lock);
    8000503c:	8526                	mv	a0,s1
    8000503e:	d09fb0ef          	jal	ra,80000d46 <release>
    kfree((char*)pi);
    80005042:	8526                	mv	a0,s1
    80005044:	a37fb0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80005048:	60e2                	ld	ra,24(sp)
    8000504a:	6442                	ld	s0,16(sp)
    8000504c:	64a2                	ld	s1,8(sp)
    8000504e:	6902                	ld	s2,0(sp)
    80005050:	6105                	addi	sp,sp,32
    80005052:	8082                	ret
    pi->readopen = 0;
    80005054:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005058:	21c48513          	addi	a0,s1,540
    8000505c:	c78fd0ef          	jal	ra,800024d4 <wakeup>
    80005060:	bfd9                	j	80005036 <pipeclose+0x24>
    release(&pi->lock);
    80005062:	8526                	mv	a0,s1
    80005064:	ce3fb0ef          	jal	ra,80000d46 <release>
}
    80005068:	b7c5                	j	80005048 <pipeclose+0x36>

000000008000506a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000506a:	711d                	addi	sp,sp,-96
    8000506c:	ec86                	sd	ra,88(sp)
    8000506e:	e8a2                	sd	s0,80(sp)
    80005070:	e4a6                	sd	s1,72(sp)
    80005072:	e0ca                	sd	s2,64(sp)
    80005074:	fc4e                	sd	s3,56(sp)
    80005076:	f852                	sd	s4,48(sp)
    80005078:	f456                	sd	s5,40(sp)
    8000507a:	f05a                	sd	s6,32(sp)
    8000507c:	ec5e                	sd	s7,24(sp)
    8000507e:	e862                	sd	s8,16(sp)
    80005080:	1080                	addi	s0,sp,96
    80005082:	84aa                	mv	s1,a0
    80005084:	8aae                	mv	s5,a1
    80005086:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005088:	b11fc0ef          	jal	ra,80001b98 <myproc>
    8000508c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000508e:	8526                	mv	a0,s1
    80005090:	c1ffb0ef          	jal	ra,80000cae <acquire>
  while(i < n){
    80005094:	09405c63          	blez	s4,8000512c <pipewrite+0xc2>
  int i = 0;
    80005098:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000509a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000509c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800050a0:	21c48b93          	addi	s7,s1,540
    800050a4:	a81d                	j	800050da <pipewrite+0x70>
      release(&pi->lock);
    800050a6:	8526                	mv	a0,s1
    800050a8:	c9ffb0ef          	jal	ra,80000d46 <release>
      return -1;
    800050ac:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050ae:	854a                	mv	a0,s2
    800050b0:	60e6                	ld	ra,88(sp)
    800050b2:	6446                	ld	s0,80(sp)
    800050b4:	64a6                	ld	s1,72(sp)
    800050b6:	6906                	ld	s2,64(sp)
    800050b8:	79e2                	ld	s3,56(sp)
    800050ba:	7a42                	ld	s4,48(sp)
    800050bc:	7aa2                	ld	s5,40(sp)
    800050be:	7b02                	ld	s6,32(sp)
    800050c0:	6be2                	ld	s7,24(sp)
    800050c2:	6c42                	ld	s8,16(sp)
    800050c4:	6125                	addi	sp,sp,96
    800050c6:	8082                	ret
      wakeup(&pi->nread);
    800050c8:	8562                	mv	a0,s8
    800050ca:	c0afd0ef          	jal	ra,800024d4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050ce:	85a6                	mv	a1,s1
    800050d0:	855e                	mv	a0,s7
    800050d2:	bb6fd0ef          	jal	ra,80002488 <sleep>
  while(i < n){
    800050d6:	05495c63          	bge	s2,s4,8000512e <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800050da:	2204a783          	lw	a5,544(s1)
    800050de:	d7e1                	beqz	a5,800050a6 <pipewrite+0x3c>
    800050e0:	854e                	mv	a0,s3
    800050e2:	ddefd0ef          	jal	ra,800026c0 <killed>
    800050e6:	f161                	bnez	a0,800050a6 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050e8:	2184a783          	lw	a5,536(s1)
    800050ec:	21c4a703          	lw	a4,540(s1)
    800050f0:	2007879b          	addiw	a5,a5,512
    800050f4:	fcf70ae3          	beq	a4,a5,800050c8 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050f8:	4685                	li	a3,1
    800050fa:	01590633          	add	a2,s2,s5
    800050fe:	faf40593          	addi	a1,s0,-81
    80005102:	0509b503          	ld	a0,80(s3)
    80005106:	f92fc0ef          	jal	ra,80001898 <copyin>
    8000510a:	03650263          	beq	a0,s6,8000512e <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000510e:	21c4a783          	lw	a5,540(s1)
    80005112:	0017871b          	addiw	a4,a5,1
    80005116:	20e4ae23          	sw	a4,540(s1)
    8000511a:	1ff7f793          	andi	a5,a5,511
    8000511e:	97a6                	add	a5,a5,s1
    80005120:	faf44703          	lbu	a4,-81(s0)
    80005124:	00e78c23          	sb	a4,24(a5)
      i++;
    80005128:	2905                	addiw	s2,s2,1
    8000512a:	b775                	j	800050d6 <pipewrite+0x6c>
  int i = 0;
    8000512c:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000512e:	21848513          	addi	a0,s1,536
    80005132:	ba2fd0ef          	jal	ra,800024d4 <wakeup>
  release(&pi->lock);
    80005136:	8526                	mv	a0,s1
    80005138:	c0ffb0ef          	jal	ra,80000d46 <release>
  return i;
    8000513c:	bf8d                	j	800050ae <pipewrite+0x44>

000000008000513e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000513e:	715d                	addi	sp,sp,-80
    80005140:	e486                	sd	ra,72(sp)
    80005142:	e0a2                	sd	s0,64(sp)
    80005144:	fc26                	sd	s1,56(sp)
    80005146:	f84a                	sd	s2,48(sp)
    80005148:	f44e                	sd	s3,40(sp)
    8000514a:	f052                	sd	s4,32(sp)
    8000514c:	ec56                	sd	s5,24(sp)
    8000514e:	e85a                	sd	s6,16(sp)
    80005150:	0880                	addi	s0,sp,80
    80005152:	84aa                	mv	s1,a0
    80005154:	892e                	mv	s2,a1
    80005156:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005158:	a41fc0ef          	jal	ra,80001b98 <myproc>
    8000515c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000515e:	8526                	mv	a0,s1
    80005160:	b4ffb0ef          	jal	ra,80000cae <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005164:	2184a703          	lw	a4,536(s1)
    80005168:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000516c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005170:	02f71363          	bne	a4,a5,80005196 <piperead+0x58>
    80005174:	2244a783          	lw	a5,548(s1)
    80005178:	cf99                	beqz	a5,80005196 <piperead+0x58>
    if(killed(pr)){
    8000517a:	8552                	mv	a0,s4
    8000517c:	d44fd0ef          	jal	ra,800026c0 <killed>
    80005180:	e151                	bnez	a0,80005204 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005182:	85a6                	mv	a1,s1
    80005184:	854e                	mv	a0,s3
    80005186:	b02fd0ef          	jal	ra,80002488 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000518a:	2184a703          	lw	a4,536(s1)
    8000518e:	21c4a783          	lw	a5,540(s1)
    80005192:	fef701e3          	beq	a4,a5,80005174 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005196:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005198:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000519a:	05505363          	blez	s5,800051e0 <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    8000519e:	2184a783          	lw	a5,536(s1)
    800051a2:	21c4a703          	lw	a4,540(s1)
    800051a6:	02f70d63          	beq	a4,a5,800051e0 <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    800051aa:	1ff7f793          	andi	a5,a5,511
    800051ae:	97a6                	add	a5,a5,s1
    800051b0:	0187c783          	lbu	a5,24(a5)
    800051b4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800051b8:	4685                	li	a3,1
    800051ba:	fbf40613          	addi	a2,s0,-65
    800051be:	85ca                	mv	a1,s2
    800051c0:	050a3503          	ld	a0,80(s4)
    800051c4:	dc4fc0ef          	jal	ra,80001788 <copyout>
    800051c8:	05650363          	beq	a0,s6,8000520e <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800051cc:	2184a783          	lw	a5,536(s1)
    800051d0:	2785                	addiw	a5,a5,1
    800051d2:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051d6:	2985                	addiw	s3,s3,1
    800051d8:	0905                	addi	s2,s2,1
    800051da:	fd3a92e3          	bne	s5,s3,8000519e <piperead+0x60>
    800051de:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051e0:	21c48513          	addi	a0,s1,540
    800051e4:	af0fd0ef          	jal	ra,800024d4 <wakeup>
  release(&pi->lock);
    800051e8:	8526                	mv	a0,s1
    800051ea:	b5dfb0ef          	jal	ra,80000d46 <release>
  return i;
}
    800051ee:	854e                	mv	a0,s3
    800051f0:	60a6                	ld	ra,72(sp)
    800051f2:	6406                	ld	s0,64(sp)
    800051f4:	74e2                	ld	s1,56(sp)
    800051f6:	7942                	ld	s2,48(sp)
    800051f8:	79a2                	ld	s3,40(sp)
    800051fa:	7a02                	ld	s4,32(sp)
    800051fc:	6ae2                	ld	s5,24(sp)
    800051fe:	6b42                	ld	s6,16(sp)
    80005200:	6161                	addi	sp,sp,80
    80005202:	8082                	ret
      release(&pi->lock);
    80005204:	8526                	mv	a0,s1
    80005206:	b41fb0ef          	jal	ra,80000d46 <release>
      return -1;
    8000520a:	59fd                	li	s3,-1
    8000520c:	b7cd                	j	800051ee <piperead+0xb0>
      if(i == 0)
    8000520e:	fc0999e3          	bnez	s3,800051e0 <piperead+0xa2>
        i = -1;
    80005212:	89aa                	mv	s3,a0
    80005214:	b7f1                	j	800051e0 <piperead+0xa2>

0000000080005216 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005216:	1141                	addi	sp,sp,-16
    80005218:	e422                	sd	s0,8(sp)
    8000521a:	0800                	addi	s0,sp,16
    8000521c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000521e:	8905                	andi	a0,a0,1
    80005220:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005222:	8b89                	andi	a5,a5,2
    80005224:	c399                	beqz	a5,8000522a <flags2perm+0x14>
      perm |= PTE_W;
    80005226:	00456513          	ori	a0,a0,4
    return perm;
}
    8000522a:	6422                	ld	s0,8(sp)
    8000522c:	0141                	addi	sp,sp,16
    8000522e:	8082                	ret

0000000080005230 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005230:	b5010113          	addi	sp,sp,-1200
    80005234:	4a113423          	sd	ra,1192(sp)
    80005238:	4a813023          	sd	s0,1184(sp)
    8000523c:	48913c23          	sd	s1,1176(sp)
    80005240:	49213823          	sd	s2,1168(sp)
    80005244:	49313423          	sd	s3,1160(sp)
    80005248:	49413023          	sd	s4,1152(sp)
    8000524c:	47513c23          	sd	s5,1144(sp)
    80005250:	47613823          	sd	s6,1136(sp)
    80005254:	47713423          	sd	s7,1128(sp)
    80005258:	47813023          	sd	s8,1120(sp)
    8000525c:	45913c23          	sd	s9,1112(sp)
    80005260:	45a13823          	sd	s10,1104(sp)
    80005264:	45b13423          	sd	s11,1096(sp)
    80005268:	4b010413          	addi	s0,sp,1200
    8000526c:	84aa                	mv	s1,a0
    8000526e:	b6a43023          	sd	a0,-1184(s0)
    80005272:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005276:	923fc0ef          	jal	ra,80001b98 <myproc>
    8000527a:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    8000527e:	dfcff0ef          	jal	ra,8000487a <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80005282:	8526                	mv	a0,s1
    80005284:	c02ff0ef          	jal	ra,80004686 <namei>
    80005288:	cd25                	beqz	a0,80005300 <kexec+0xd0>
    8000528a:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000528c:	c07fe0ef          	jal	ra,80003e92 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005290:	04000713          	li	a4,64
    80005294:	4681                	li	a3,0
    80005296:	e5040613          	addi	a2,s0,-432
    8000529a:	4581                	li	a1,0
    8000529c:	8556                	mv	a0,s5
    8000529e:	f81fe0ef          	jal	ra,8000421e <readi>
    800052a2:	04000793          	li	a5,64
    800052a6:	00f51a63          	bne	a0,a5,800052ba <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800052aa:	e5042703          	lw	a4,-432(s0)
    800052ae:	464c47b7          	lui	a5,0x464c4
    800052b2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052b6:	04f70963          	beq	a4,a5,80005308 <kexec+0xd8>
    memset(p->vmas, 0, sizeof(p->vmas));
    vma_release_all(p);
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    800052ba:	8556                	mv	a0,s5
    800052bc:	dddfe0ef          	jal	ra,80004098 <iunlockput>
    end_op();
    800052c0:	e28ff0ef          	jal	ra,800048e8 <end_op>
  }
  return -1;
    800052c4:	557d                	li	a0,-1
}
    800052c6:	4a813083          	ld	ra,1192(sp)
    800052ca:	4a013403          	ld	s0,1184(sp)
    800052ce:	49813483          	ld	s1,1176(sp)
    800052d2:	49013903          	ld	s2,1168(sp)
    800052d6:	48813983          	ld	s3,1160(sp)
    800052da:	48013a03          	ld	s4,1152(sp)
    800052de:	47813a83          	ld	s5,1144(sp)
    800052e2:	47013b03          	ld	s6,1136(sp)
    800052e6:	46813b83          	ld	s7,1128(sp)
    800052ea:	46013c03          	ld	s8,1120(sp)
    800052ee:	45813c83          	ld	s9,1112(sp)
    800052f2:	45013d03          	ld	s10,1104(sp)
    800052f6:	44813d83          	ld	s11,1096(sp)
    800052fa:	4b010113          	addi	sp,sp,1200
    800052fe:	8082                	ret
    end_op();
    80005300:	de8ff0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005304:	557d                	li	a0,-1
    80005306:	b7c1                	j	800052c6 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80005308:	b7843503          	ld	a0,-1160(s0)
    8000530c:	b7bfc0ef          	jal	ra,80001e86 <proc_pagetable>
    80005310:	8baa                	mv	s7,a0
    80005312:	d545                	beqz	a0,800052ba <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005314:	e7042783          	lw	a5,-400(s0)
    80005318:	e8845703          	lhu	a4,-376(s0)
    8000531c:	0e070d63          	beqz	a4,80005416 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005320:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005324:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005328:	6a05                	lui	s4,0x1
    8000532a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000532e:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005332:	6d85                	lui	s11,0x1
    80005334:	7d7d                	lui	s10,0xfffff
    80005336:	a09d                	j	8000539c <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005338:	00003517          	auipc	a0,0x3
    8000533c:	3c050513          	addi	a0,a0,960 # 800086f8 <syscalls+0x300>
    80005340:	c48fb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005344:	874a                	mv	a4,s2
    80005346:	009c86bb          	addw	a3,s9,s1
    8000534a:	4581                	li	a1,0
    8000534c:	8556                	mv	a0,s5
    8000534e:	ed1fe0ef          	jal	ra,8000421e <readi>
    80005352:	2501                	sext.w	a0,a0
    80005354:	0ea91f63          	bne	s2,a0,80005452 <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    80005358:	009d84bb          	addw	s1,s11,s1
    8000535c:	013d09bb          	addw	s3,s10,s3
    80005360:	0364f063          	bgeu	s1,s6,80005380 <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80005364:	02049593          	slli	a1,s1,0x20
    80005368:	9181                	srli	a1,a1,0x20
    8000536a:	95e2                	add	a1,a1,s8
    8000536c:	855e                	mv	a0,s7
    8000536e:	d37fb0ef          	jal	ra,800010a4 <walkaddr>
    80005372:	862a                	mv	a2,a0
    if(pa == 0)
    80005374:	d171                	beqz	a0,80005338 <kexec+0x108>
      n = PGSIZE;
    80005376:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005378:	fd49f6e3          	bgeu	s3,s4,80005344 <kexec+0x114>
      n = sz - i;
    8000537c:	894e                	mv	s2,s3
    8000537e:	b7d9                	j	80005344 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005380:	b8843783          	ld	a5,-1144(s0)
    80005384:	0017869b          	addiw	a3,a5,1
    80005388:	b8d43423          	sd	a3,-1144(s0)
    8000538c:	b8043783          	ld	a5,-1152(s0)
    80005390:	0387879b          	addiw	a5,a5,56
    80005394:	e8845703          	lhu	a4,-376(s0)
    80005398:	08e6d163          	bge	a3,a4,8000541a <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000539c:	2781                	sext.w	a5,a5
    8000539e:	b8f43023          	sd	a5,-1152(s0)
    800053a2:	03800713          	li	a4,56
    800053a6:	86be                	mv	a3,a5
    800053a8:	e1840613          	addi	a2,s0,-488
    800053ac:	4581                	li	a1,0
    800053ae:	8556                	mv	a0,s5
    800053b0:	e6ffe0ef          	jal	ra,8000421e <readi>
    800053b4:	03800793          	li	a5,56
    800053b8:	08f51d63          	bne	a0,a5,80005452 <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    800053bc:	e1842783          	lw	a5,-488(s0)
    800053c0:	4705                	li	a4,1
    800053c2:	fae79fe3          	bne	a5,a4,80005380 <kexec+0x150>
    if(ph.memsz < ph.filesz)
    800053c6:	e4043483          	ld	s1,-448(s0)
    800053ca:	e3843783          	ld	a5,-456(s0)
    800053ce:	08f4e263          	bltu	s1,a5,80005452 <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053d2:	e2843783          	ld	a5,-472(s0)
    800053d6:	94be                	add	s1,s1,a5
    800053d8:	06f4ed63          	bltu	s1,a5,80005452 <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    800053dc:	b5843703          	ld	a4,-1192(s0)
    800053e0:	8ff9                	and	a5,a5,a4
    800053e2:	eba5                	bnez	a5,80005452 <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053e4:	e1c42503          	lw	a0,-484(s0)
    800053e8:	e2fff0ef          	jal	ra,80005216 <flags2perm>
    800053ec:	86aa                	mv	a3,a0
    800053ee:	8626                	mv	a2,s1
    800053f0:	b7043583          	ld	a1,-1168(s0)
    800053f4:	855e                	mv	a0,s7
    800053f6:	f79fb0ef          	jal	ra,8000136e <uvmalloc>
    800053fa:	b6a43823          	sd	a0,-1168(s0)
    800053fe:	c931                	beqz	a0,80005452 <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005400:	e2843c03          	ld	s8,-472(s0)
    80005404:	e2042c83          	lw	s9,-480(s0)
    80005408:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000540c:	f60b0ae3          	beqz	s6,80005380 <kexec+0x150>
    80005410:	89da                	mv	s3,s6
    80005412:	4481                	li	s1,0
    80005414:	bf81                	j	80005364 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005416:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    8000541a:	8556                	mv	a0,s5
    8000541c:	c7dfe0ef          	jal	ra,80004098 <iunlockput>
  end_op();
    80005420:	cc8ff0ef          	jal	ra,800048e8 <end_op>
  p = myproc();
    80005424:	f74fc0ef          	jal	ra,80001b98 <myproc>
    80005428:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    8000542c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005430:	6785                	lui	a5,0x1
    80005432:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005434:	b7043703          	ld	a4,-1168(s0)
    80005438:	00f705b3          	add	a1,a4,a5
    8000543c:	77fd                	lui	a5,0xfffff
    8000543e:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005440:	4691                	li	a3,4
    80005442:	6609                	lui	a2,0x2
    80005444:	962e                	add	a2,a2,a1
    80005446:	855e                	mv	a0,s7
    80005448:	f27fb0ef          	jal	ra,8000136e <uvmalloc>
    8000544c:	8b2a                	mv	s6,a0
  ip = 0;
    8000544e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005450:	e121                	bnez	a0,80005490 <kexec+0x260>
    delete_shm_from_proc(p);
    80005452:	b7843903          	ld	s2,-1160(s0)
    80005456:	854a                	mv	a0,s2
    80005458:	8c3fc0ef          	jal	ra,80001d1a <delete_shm_from_proc>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    8000545c:	16890493          	addi	s1,s2,360
    80005460:	85a6                	mv	a1,s1
    80005462:	05093503          	ld	a0,80(s2)
    80005466:	aa5fc0ef          	jal	ra,80001f0a <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    8000546a:	28000613          	li	a2,640
    8000546e:	4581                	li	a1,0
    80005470:	8526                	mv	a0,s1
    80005472:	911fb0ef          	jal	ra,80000d82 <memset>
    vma_release_all(p);
    80005476:	854a                	mv	a0,s2
    80005478:	921fc0ef          	jal	ra,80001d98 <vma_release_all>
    proc_freepagetable(p->pagetable, p->sz);
    8000547c:	04893583          	ld	a1,72(s2)
    80005480:	05093503          	ld	a0,80(s2)
    80005484:	ad1fc0ef          	jal	ra,80001f54 <proc_freepagetable>
  if(ip){
    80005488:	e20a99e3          	bnez	s5,800052ba <kexec+0x8a>
  return -1;
    8000548c:	557d                	li	a0,-1
    8000548e:	bd25                	j	800052c6 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005490:	75f9                	lui	a1,0xffffe
    80005492:	95aa                	add	a1,a1,a0
    80005494:	855e                	mv	a0,s7
    80005496:	98afc0ef          	jal	ra,80001620 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000549a:	7c7d                	lui	s8,0xfffff
    8000549c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000549e:	b6843783          	ld	a5,-1176(s0)
    800054a2:	6388                	ld	a0,0(a5)
    800054a4:	c125                	beqz	a0,80005504 <kexec+0x2d4>
    800054a6:	e9040993          	addi	s3,s0,-368
    800054aa:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    800054ae:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800054b0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800054b2:	a49fb0ef          	jal	ra,80000efa <strlen>
    800054b6:	0015079b          	addiw	a5,a0,1
    800054ba:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054be:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800054c2:	11896d63          	bltu	s2,s8,800055dc <kexec+0x3ac>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054c6:	b6843d03          	ld	s10,-1176(s0)
    800054ca:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdaadf0>
    800054ce:	8552                	mv	a0,s4
    800054d0:	a2bfb0ef          	jal	ra,80000efa <strlen>
    800054d4:	0015069b          	addiw	a3,a0,1
    800054d8:	8652                	mv	a2,s4
    800054da:	85ca                	mv	a1,s2
    800054dc:	855e                	mv	a0,s7
    800054de:	aaafc0ef          	jal	ra,80001788 <copyout>
    800054e2:	0e054f63          	bltz	a0,800055e0 <kexec+0x3b0>
    ustack[argc] = sp;
    800054e6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800054ea:	0485                	addi	s1,s1,1
    800054ec:	008d0793          	addi	a5,s10,8
    800054f0:	b6f43423          	sd	a5,-1176(s0)
    800054f4:	008d3503          	ld	a0,8(s10)
    800054f8:	c901                	beqz	a0,80005508 <kexec+0x2d8>
    if(argc >= MAXARG)
    800054fa:	09a1                	addi	s3,s3,8
    800054fc:	fb599be3          	bne	s3,s5,800054b2 <kexec+0x282>
  ip = 0;
    80005500:	4a81                	li	s5,0
    80005502:	bf81                	j	80005452 <kexec+0x222>
  sp = sz;
    80005504:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005506:	4481                	li	s1,0
  ustack[argc] = 0;
    80005508:	00349793          	slli	a5,s1,0x3
    8000550c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdaad80>
    80005510:	97a2                	add	a5,a5,s0
    80005512:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005516:	00148693          	addi	a3,s1,1
    8000551a:	068e                	slli	a3,a3,0x3
    8000551c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005520:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005524:	4a81                	li	s5,0
  if(sp < stackbase)
    80005526:	f38966e3          	bltu	s2,s8,80005452 <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000552a:	e9040613          	addi	a2,s0,-368
    8000552e:	85ca                	mv	a1,s2
    80005530:	855e                	mv	a0,s7
    80005532:	a56fc0ef          	jal	ra,80001788 <copyout>
    80005536:	0a054763          	bltz	a0,800055e4 <kexec+0x3b4>
  p->trapframe->a1 = sp;
    8000553a:	b7843783          	ld	a5,-1160(s0)
    8000553e:	6fbc                	ld	a5,88(a5)
    80005540:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005544:	b6043783          	ld	a5,-1184(s0)
    80005548:	0007c703          	lbu	a4,0(a5)
    8000554c:	cf11                	beqz	a4,80005568 <kexec+0x338>
    8000554e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005550:	02f00693          	li	a3,47
    80005554:	a039                	j	80005562 <kexec+0x332>
      last = s+1;
    80005556:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    8000555a:	0785                	addi	a5,a5,1
    8000555c:	fff7c703          	lbu	a4,-1(a5)
    80005560:	c701                	beqz	a4,80005568 <kexec+0x338>
    if(*s == '/')
    80005562:	fed71ce3          	bne	a4,a3,8000555a <kexec+0x32a>
    80005566:	bfc5                	j	80005556 <kexec+0x326>
  safestrcpy(p->name, last, sizeof(p->name));
    80005568:	4641                	li	a2,16
    8000556a:	b6043583          	ld	a1,-1184(s0)
    8000556e:	b7843a83          	ld	s5,-1160(s0)
    80005572:	158a8513          	addi	a0,s5,344
    80005576:	953fb0ef          	jal	ra,80000ec8 <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    8000557a:	168a8a13          	addi	s4,s5,360
    8000557e:	28000613          	li	a2,640
    80005582:	85d2                	mv	a1,s4
    80005584:	b9840513          	addi	a0,s0,-1128
    80005588:	857fb0ef          	jal	ra,80000dde <memmove>
  oldpagetable = p->pagetable;
    8000558c:	050ab983          	ld	s3,80(s5)
  vma_release_all(p);
    80005590:	8556                	mv	a0,s5
    80005592:	807fc0ef          	jal	ra,80001d98 <vma_release_all>
  p->pagetable = pagetable;
    80005596:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    8000559a:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;
    8000559e:	058ab783          	ld	a5,88(s5)
    800055a2:	e6843703          	ld	a4,-408(s0)
    800055a6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    800055a8:	058ab783          	ld	a5,88(s5)
    800055ac:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    800055b0:	28000613          	li	a2,640
    800055b4:	4581                	li	a1,0
    800055b6:	8552                	mv	a0,s4
    800055b8:	fcafb0ef          	jal	ra,80000d82 <memset>
  delete_shm_from_vmas(oldvmas);
    800055bc:	b9840513          	addi	a0,s0,-1128
    800055c0:	edefc0ef          	jal	ra,80001c9e <delete_shm_from_vmas>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    800055c4:	b9840593          	addi	a1,s0,-1128
    800055c8:	854e                	mv	a0,s3
    800055ca:	941fc0ef          	jal	ra,80001f0a <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    800055ce:	85e6                	mv	a1,s9
    800055d0:	854e                	mv	a0,s3
    800055d2:	983fc0ef          	jal	ra,80001f54 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800055d6:	0004851b          	sext.w	a0,s1
    800055da:	b1f5                	j	800052c6 <kexec+0x96>
  ip = 0;
    800055dc:	4a81                	li	s5,0
    800055de:	bd95                	j	80005452 <kexec+0x222>
    800055e0:	4a81                	li	s5,0
    800055e2:	bd85                	j	80005452 <kexec+0x222>
    800055e4:	4a81                	li	s5,0
    800055e6:	b5b5                	j	80005452 <kexec+0x222>

00000000800055e8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055e8:	7179                	addi	sp,sp,-48
    800055ea:	f406                	sd	ra,40(sp)
    800055ec:	f022                	sd	s0,32(sp)
    800055ee:	ec26                	sd	s1,24(sp)
    800055f0:	e84a                	sd	s2,16(sp)
    800055f2:	1800                	addi	s0,sp,48
    800055f4:	892e                	mv	s2,a1
    800055f6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800055f8:	fdc40593          	addi	a1,s0,-36
    800055fc:	fc4fd0ef          	jal	ra,80002dc0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005600:	fdc42703          	lw	a4,-36(s0)
    80005604:	47bd                	li	a5,15
    80005606:	02e7e963          	bltu	a5,a4,80005638 <argfd+0x50>
    8000560a:	d8efc0ef          	jal	ra,80001b98 <myproc>
    8000560e:	fdc42703          	lw	a4,-36(s0)
    80005612:	01a70793          	addi	a5,a4,26
    80005616:	078e                	slli	a5,a5,0x3
    80005618:	953e                	add	a0,a0,a5
    8000561a:	611c                	ld	a5,0(a0)
    8000561c:	c385                	beqz	a5,8000563c <argfd+0x54>
    return -1;
  if(pfd)
    8000561e:	00090463          	beqz	s2,80005626 <argfd+0x3e>
    *pfd = fd;
    80005622:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005626:	4501                	li	a0,0
  if(pf)
    80005628:	c091                	beqz	s1,8000562c <argfd+0x44>
    *pf = f;
    8000562a:	e09c                	sd	a5,0(s1)
}
    8000562c:	70a2                	ld	ra,40(sp)
    8000562e:	7402                	ld	s0,32(sp)
    80005630:	64e2                	ld	s1,24(sp)
    80005632:	6942                	ld	s2,16(sp)
    80005634:	6145                	addi	sp,sp,48
    80005636:	8082                	ret
    return -1;
    80005638:	557d                	li	a0,-1
    8000563a:	bfcd                	j	8000562c <argfd+0x44>
    8000563c:	557d                	li	a0,-1
    8000563e:	b7fd                	j	8000562c <argfd+0x44>

0000000080005640 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005640:	1101                	addi	sp,sp,-32
    80005642:	ec06                	sd	ra,24(sp)
    80005644:	e822                	sd	s0,16(sp)
    80005646:	e426                	sd	s1,8(sp)
    80005648:	1000                	addi	s0,sp,32
    8000564a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000564c:	d4cfc0ef          	jal	ra,80001b98 <myproc>
    80005650:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005652:	0d050793          	addi	a5,a0,208
    80005656:	4501                	li	a0,0
    80005658:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000565a:	6398                	ld	a4,0(a5)
    8000565c:	cb19                	beqz	a4,80005672 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000565e:	2505                	addiw	a0,a0,1
    80005660:	07a1                	addi	a5,a5,8
    80005662:	fed51ce3          	bne	a0,a3,8000565a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005666:	557d                	li	a0,-1
}
    80005668:	60e2                	ld	ra,24(sp)
    8000566a:	6442                	ld	s0,16(sp)
    8000566c:	64a2                	ld	s1,8(sp)
    8000566e:	6105                	addi	sp,sp,32
    80005670:	8082                	ret
      p->ofile[fd] = f;
    80005672:	01a50793          	addi	a5,a0,26
    80005676:	078e                	slli	a5,a5,0x3
    80005678:	963e                	add	a2,a2,a5
    8000567a:	e204                	sd	s1,0(a2)
      return fd;
    8000567c:	b7f5                	j	80005668 <fdalloc+0x28>

000000008000567e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000567e:	715d                	addi	sp,sp,-80
    80005680:	e486                	sd	ra,72(sp)
    80005682:	e0a2                	sd	s0,64(sp)
    80005684:	fc26                	sd	s1,56(sp)
    80005686:	f84a                	sd	s2,48(sp)
    80005688:	f44e                	sd	s3,40(sp)
    8000568a:	f052                	sd	s4,32(sp)
    8000568c:	ec56                	sd	s5,24(sp)
    8000568e:	e85a                	sd	s6,16(sp)
    80005690:	0880                	addi	s0,sp,80
    80005692:	8b2e                	mv	s6,a1
    80005694:	89b2                	mv	s3,a2
    80005696:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005698:	fb040593          	addi	a1,s0,-80
    8000569c:	804ff0ef          	jal	ra,800046a0 <nameiparent>
    800056a0:	84aa                	mv	s1,a0
    800056a2:	10050b63          	beqz	a0,800057b8 <create+0x13a>
    return 0;

  ilock(dp);
    800056a6:	fecfe0ef          	jal	ra,80003e92 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056aa:	4601                	li	a2,0
    800056ac:	fb040593          	addi	a1,s0,-80
    800056b0:	8526                	mv	a0,s1
    800056b2:	d69fe0ef          	jal	ra,8000441a <dirlookup>
    800056b6:	8aaa                	mv	s5,a0
    800056b8:	c521                	beqz	a0,80005700 <create+0x82>
    iunlockput(dp);
    800056ba:	8526                	mv	a0,s1
    800056bc:	9ddfe0ef          	jal	ra,80004098 <iunlockput>
    ilock(ip);
    800056c0:	8556                	mv	a0,s5
    800056c2:	fd0fe0ef          	jal	ra,80003e92 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056c6:	000b059b          	sext.w	a1,s6
    800056ca:	4789                	li	a5,2
    800056cc:	02f59563          	bne	a1,a5,800056f6 <create+0x78>
    800056d0:	044ad783          	lhu	a5,68(s5)
    800056d4:	37f9                	addiw	a5,a5,-2
    800056d6:	17c2                	slli	a5,a5,0x30
    800056d8:	93c1                	srli	a5,a5,0x30
    800056da:	4705                	li	a4,1
    800056dc:	00f76d63          	bltu	a4,a5,800056f6 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800056e0:	8556                	mv	a0,s5
    800056e2:	60a6                	ld	ra,72(sp)
    800056e4:	6406                	ld	s0,64(sp)
    800056e6:	74e2                	ld	s1,56(sp)
    800056e8:	7942                	ld	s2,48(sp)
    800056ea:	79a2                	ld	s3,40(sp)
    800056ec:	7a02                	ld	s4,32(sp)
    800056ee:	6ae2                	ld	s5,24(sp)
    800056f0:	6b42                	ld	s6,16(sp)
    800056f2:	6161                	addi	sp,sp,80
    800056f4:	8082                	ret
    iunlockput(ip);
    800056f6:	8556                	mv	a0,s5
    800056f8:	9a1fe0ef          	jal	ra,80004098 <iunlockput>
    return 0;
    800056fc:	4a81                	li	s5,0
    800056fe:	b7cd                	j	800056e0 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005700:	85da                	mv	a1,s6
    80005702:	4088                	lw	a0,0(s1)
    80005704:	e24fe0ef          	jal	ra,80003d28 <ialloc>
    80005708:	8a2a                	mv	s4,a0
    8000570a:	cd1d                	beqz	a0,80005748 <create+0xca>
  ilock(ip);
    8000570c:	f86fe0ef          	jal	ra,80003e92 <ilock>
  ip->major = major;
    80005710:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005714:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005718:	4905                	li	s2,1
    8000571a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000571e:	8552                	mv	a0,s4
    80005720:	ebefe0ef          	jal	ra,80003dde <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005724:	000b059b          	sext.w	a1,s6
    80005728:	03258563          	beq	a1,s2,80005752 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    8000572c:	004a2603          	lw	a2,4(s4)
    80005730:	fb040593          	addi	a1,s0,-80
    80005734:	8526                	mv	a0,s1
    80005736:	eb7fe0ef          	jal	ra,800045ec <dirlink>
    8000573a:	06054363          	bltz	a0,800057a0 <create+0x122>
  iunlockput(dp);
    8000573e:	8526                	mv	a0,s1
    80005740:	959fe0ef          	jal	ra,80004098 <iunlockput>
  return ip;
    80005744:	8ad2                	mv	s5,s4
    80005746:	bf69                	j	800056e0 <create+0x62>
    iunlockput(dp);
    80005748:	8526                	mv	a0,s1
    8000574a:	94ffe0ef          	jal	ra,80004098 <iunlockput>
    return 0;
    8000574e:	8ad2                	mv	s5,s4
    80005750:	bf41                	j	800056e0 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005752:	004a2603          	lw	a2,4(s4)
    80005756:	00003597          	auipc	a1,0x3
    8000575a:	fc258593          	addi	a1,a1,-62 # 80008718 <syscalls+0x320>
    8000575e:	8552                	mv	a0,s4
    80005760:	e8dfe0ef          	jal	ra,800045ec <dirlink>
    80005764:	02054e63          	bltz	a0,800057a0 <create+0x122>
    80005768:	40d0                	lw	a2,4(s1)
    8000576a:	00003597          	auipc	a1,0x3
    8000576e:	fb658593          	addi	a1,a1,-74 # 80008720 <syscalls+0x328>
    80005772:	8552                	mv	a0,s4
    80005774:	e79fe0ef          	jal	ra,800045ec <dirlink>
    80005778:	02054463          	bltz	a0,800057a0 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    8000577c:	004a2603          	lw	a2,4(s4)
    80005780:	fb040593          	addi	a1,s0,-80
    80005784:	8526                	mv	a0,s1
    80005786:	e67fe0ef          	jal	ra,800045ec <dirlink>
    8000578a:	00054b63          	bltz	a0,800057a0 <create+0x122>
    dp->nlink++;  // for ".."
    8000578e:	04a4d783          	lhu	a5,74(s1)
    80005792:	2785                	addiw	a5,a5,1
    80005794:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005798:	8526                	mv	a0,s1
    8000579a:	e44fe0ef          	jal	ra,80003dde <iupdate>
    8000579e:	b745                	j	8000573e <create+0xc0>
  ip->nlink = 0;
    800057a0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057a4:	8552                	mv	a0,s4
    800057a6:	e38fe0ef          	jal	ra,80003dde <iupdate>
  iunlockput(ip);
    800057aa:	8552                	mv	a0,s4
    800057ac:	8edfe0ef          	jal	ra,80004098 <iunlockput>
  iunlockput(dp);
    800057b0:	8526                	mv	a0,s1
    800057b2:	8e7fe0ef          	jal	ra,80004098 <iunlockput>
  return 0;
    800057b6:	b72d                	j	800056e0 <create+0x62>
    return 0;
    800057b8:	8aaa                	mv	s5,a0
    800057ba:	b71d                	j	800056e0 <create+0x62>

00000000800057bc <sys_dup>:
{
    800057bc:	7179                	addi	sp,sp,-48
    800057be:	f406                	sd	ra,40(sp)
    800057c0:	f022                	sd	s0,32(sp)
    800057c2:	ec26                	sd	s1,24(sp)
    800057c4:	e84a                	sd	s2,16(sp)
    800057c6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057c8:	fd840613          	addi	a2,s0,-40
    800057cc:	4581                	li	a1,0
    800057ce:	4501                	li	a0,0
    800057d0:	e19ff0ef          	jal	ra,800055e8 <argfd>
    return -1;
    800057d4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057d6:	00054f63          	bltz	a0,800057f4 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    800057da:	fd843903          	ld	s2,-40(s0)
    800057de:	854a                	mv	a0,s2
    800057e0:	e61ff0ef          	jal	ra,80005640 <fdalloc>
    800057e4:	84aa                	mv	s1,a0
    return -1;
    800057e6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057e8:	00054663          	bltz	a0,800057f4 <sys_dup+0x38>
  filedup(f);
    800057ec:	854a                	mv	a0,s2
    800057ee:	c50ff0ef          	jal	ra,80004c3e <filedup>
  return fd;
    800057f2:	87a6                	mv	a5,s1
}
    800057f4:	853e                	mv	a0,a5
    800057f6:	70a2                	ld	ra,40(sp)
    800057f8:	7402                	ld	s0,32(sp)
    800057fa:	64e2                	ld	s1,24(sp)
    800057fc:	6942                	ld	s2,16(sp)
    800057fe:	6145                	addi	sp,sp,48
    80005800:	8082                	ret

0000000080005802 <sys_read>:
{
    80005802:	7179                	addi	sp,sp,-48
    80005804:	f406                	sd	ra,40(sp)
    80005806:	f022                	sd	s0,32(sp)
    80005808:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000580a:	fd840593          	addi	a1,s0,-40
    8000580e:	4505                	li	a0,1
    80005810:	dccfd0ef          	jal	ra,80002ddc <argaddr>
  argint(2, &n);
    80005814:	fe440593          	addi	a1,s0,-28
    80005818:	4509                	li	a0,2
    8000581a:	da6fd0ef          	jal	ra,80002dc0 <argint>
  if(argfd(0, 0, &f) < 0)
    8000581e:	fe840613          	addi	a2,s0,-24
    80005822:	4581                	li	a1,0
    80005824:	4501                	li	a0,0
    80005826:	dc3ff0ef          	jal	ra,800055e8 <argfd>
    8000582a:	87aa                	mv	a5,a0
    return -1;
    8000582c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000582e:	0007ca63          	bltz	a5,80005842 <sys_read+0x40>
  return fileread(f, p, n);
    80005832:	fe442603          	lw	a2,-28(s0)
    80005836:	fd843583          	ld	a1,-40(s0)
    8000583a:	fe843503          	ld	a0,-24(s0)
    8000583e:	d4cff0ef          	jal	ra,80004d8a <fileread>
}
    80005842:	70a2                	ld	ra,40(sp)
    80005844:	7402                	ld	s0,32(sp)
    80005846:	6145                	addi	sp,sp,48
    80005848:	8082                	ret

000000008000584a <sys_write>:
{
    8000584a:	7179                	addi	sp,sp,-48
    8000584c:	f406                	sd	ra,40(sp)
    8000584e:	f022                	sd	s0,32(sp)
    80005850:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005852:	fd840593          	addi	a1,s0,-40
    80005856:	4505                	li	a0,1
    80005858:	d84fd0ef          	jal	ra,80002ddc <argaddr>
  argint(2, &n);
    8000585c:	fe440593          	addi	a1,s0,-28
    80005860:	4509                	li	a0,2
    80005862:	d5efd0ef          	jal	ra,80002dc0 <argint>
  if(argfd(0, 0, &f) < 0)
    80005866:	fe840613          	addi	a2,s0,-24
    8000586a:	4581                	li	a1,0
    8000586c:	4501                	li	a0,0
    8000586e:	d7bff0ef          	jal	ra,800055e8 <argfd>
    80005872:	87aa                	mv	a5,a0
    return -1;
    80005874:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005876:	0007ca63          	bltz	a5,8000588a <sys_write+0x40>
  return filewrite(f, p, n);
    8000587a:	fe442603          	lw	a2,-28(s0)
    8000587e:	fd843583          	ld	a1,-40(s0)
    80005882:	fe843503          	ld	a0,-24(s0)
    80005886:	db2ff0ef          	jal	ra,80004e38 <filewrite>
}
    8000588a:	70a2                	ld	ra,40(sp)
    8000588c:	7402                	ld	s0,32(sp)
    8000588e:	6145                	addi	sp,sp,48
    80005890:	8082                	ret

0000000080005892 <sys_close>:
{
    80005892:	1101                	addi	sp,sp,-32
    80005894:	ec06                	sd	ra,24(sp)
    80005896:	e822                	sd	s0,16(sp)
    80005898:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000589a:	fe040613          	addi	a2,s0,-32
    8000589e:	fec40593          	addi	a1,s0,-20
    800058a2:	4501                	li	a0,0
    800058a4:	d45ff0ef          	jal	ra,800055e8 <argfd>
    return -1;
    800058a8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058aa:	02054063          	bltz	a0,800058ca <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800058ae:	aeafc0ef          	jal	ra,80001b98 <myproc>
    800058b2:	fec42783          	lw	a5,-20(s0)
    800058b6:	07e9                	addi	a5,a5,26
    800058b8:	078e                	slli	a5,a5,0x3
    800058ba:	953e                	add	a0,a0,a5
    800058bc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800058c0:	fe043503          	ld	a0,-32(s0)
    800058c4:	bc0ff0ef          	jal	ra,80004c84 <fileclose>
  return 0;
    800058c8:	4781                	li	a5,0
}
    800058ca:	853e                	mv	a0,a5
    800058cc:	60e2                	ld	ra,24(sp)
    800058ce:	6442                	ld	s0,16(sp)
    800058d0:	6105                	addi	sp,sp,32
    800058d2:	8082                	ret

00000000800058d4 <sys_fstat>:
{
    800058d4:	1101                	addi	sp,sp,-32
    800058d6:	ec06                	sd	ra,24(sp)
    800058d8:	e822                	sd	s0,16(sp)
    800058da:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800058dc:	fe040593          	addi	a1,s0,-32
    800058e0:	4505                	li	a0,1
    800058e2:	cfafd0ef          	jal	ra,80002ddc <argaddr>
  if(argfd(0, 0, &f) < 0)
    800058e6:	fe840613          	addi	a2,s0,-24
    800058ea:	4581                	li	a1,0
    800058ec:	4501                	li	a0,0
    800058ee:	cfbff0ef          	jal	ra,800055e8 <argfd>
    800058f2:	87aa                	mv	a5,a0
    return -1;
    800058f4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058f6:	0007c863          	bltz	a5,80005906 <sys_fstat+0x32>
  return filestat(f, st);
    800058fa:	fe043583          	ld	a1,-32(s0)
    800058fe:	fe843503          	ld	a0,-24(s0)
    80005902:	c2aff0ef          	jal	ra,80004d2c <filestat>
}
    80005906:	60e2                	ld	ra,24(sp)
    80005908:	6442                	ld	s0,16(sp)
    8000590a:	6105                	addi	sp,sp,32
    8000590c:	8082                	ret

000000008000590e <sys_link>:
{
    8000590e:	7169                	addi	sp,sp,-304
    80005910:	f606                	sd	ra,296(sp)
    80005912:	f222                	sd	s0,288(sp)
    80005914:	ee26                	sd	s1,280(sp)
    80005916:	ea4a                	sd	s2,272(sp)
    80005918:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000591a:	08000613          	li	a2,128
    8000591e:	ed040593          	addi	a1,s0,-304
    80005922:	4501                	li	a0,0
    80005924:	cd4fd0ef          	jal	ra,80002df8 <argstr>
    return -1;
    80005928:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000592a:	0c054663          	bltz	a0,800059f6 <sys_link+0xe8>
    8000592e:	08000613          	li	a2,128
    80005932:	f5040593          	addi	a1,s0,-176
    80005936:	4505                	li	a0,1
    80005938:	cc0fd0ef          	jal	ra,80002df8 <argstr>
    return -1;
    8000593c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000593e:	0a054c63          	bltz	a0,800059f6 <sys_link+0xe8>
  begin_op();
    80005942:	f39fe0ef          	jal	ra,8000487a <begin_op>
  if((ip = namei(old)) == 0){
    80005946:	ed040513          	addi	a0,s0,-304
    8000594a:	d3dfe0ef          	jal	ra,80004686 <namei>
    8000594e:	84aa                	mv	s1,a0
    80005950:	c525                	beqz	a0,800059b8 <sys_link+0xaa>
  ilock(ip);
    80005952:	d40fe0ef          	jal	ra,80003e92 <ilock>
  if(ip->type == T_DIR){
    80005956:	04449703          	lh	a4,68(s1)
    8000595a:	4785                	li	a5,1
    8000595c:	06f70263          	beq	a4,a5,800059c0 <sys_link+0xb2>
  ip->nlink++;
    80005960:	04a4d783          	lhu	a5,74(s1)
    80005964:	2785                	addiw	a5,a5,1
    80005966:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000596a:	8526                	mv	a0,s1
    8000596c:	c72fe0ef          	jal	ra,80003dde <iupdate>
  iunlock(ip);
    80005970:	8526                	mv	a0,s1
    80005972:	dcafe0ef          	jal	ra,80003f3c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005976:	fd040593          	addi	a1,s0,-48
    8000597a:	f5040513          	addi	a0,s0,-176
    8000597e:	d23fe0ef          	jal	ra,800046a0 <nameiparent>
    80005982:	892a                	mv	s2,a0
    80005984:	c921                	beqz	a0,800059d4 <sys_link+0xc6>
  ilock(dp);
    80005986:	d0cfe0ef          	jal	ra,80003e92 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000598a:	00092703          	lw	a4,0(s2)
    8000598e:	409c                	lw	a5,0(s1)
    80005990:	02f71f63          	bne	a4,a5,800059ce <sys_link+0xc0>
    80005994:	40d0                	lw	a2,4(s1)
    80005996:	fd040593          	addi	a1,s0,-48
    8000599a:	854a                	mv	a0,s2
    8000599c:	c51fe0ef          	jal	ra,800045ec <dirlink>
    800059a0:	02054763          	bltz	a0,800059ce <sys_link+0xc0>
  iunlockput(dp);
    800059a4:	854a                	mv	a0,s2
    800059a6:	ef2fe0ef          	jal	ra,80004098 <iunlockput>
  iput(ip);
    800059aa:	8526                	mv	a0,s1
    800059ac:	e64fe0ef          	jal	ra,80004010 <iput>
  end_op();
    800059b0:	f39fe0ef          	jal	ra,800048e8 <end_op>
  return 0;
    800059b4:	4781                	li	a5,0
    800059b6:	a081                	j	800059f6 <sys_link+0xe8>
    end_op();
    800059b8:	f31fe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    800059bc:	57fd                	li	a5,-1
    800059be:	a825                	j	800059f6 <sys_link+0xe8>
    iunlockput(ip);
    800059c0:	8526                	mv	a0,s1
    800059c2:	ed6fe0ef          	jal	ra,80004098 <iunlockput>
    end_op();
    800059c6:	f23fe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    800059ca:	57fd                	li	a5,-1
    800059cc:	a02d                	j	800059f6 <sys_link+0xe8>
    iunlockput(dp);
    800059ce:	854a                	mv	a0,s2
    800059d0:	ec8fe0ef          	jal	ra,80004098 <iunlockput>
  ilock(ip);
    800059d4:	8526                	mv	a0,s1
    800059d6:	cbcfe0ef          	jal	ra,80003e92 <ilock>
  ip->nlink--;
    800059da:	04a4d783          	lhu	a5,74(s1)
    800059de:	37fd                	addiw	a5,a5,-1
    800059e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059e4:	8526                	mv	a0,s1
    800059e6:	bf8fe0ef          	jal	ra,80003dde <iupdate>
  iunlockput(ip);
    800059ea:	8526                	mv	a0,s1
    800059ec:	eacfe0ef          	jal	ra,80004098 <iunlockput>
  end_op();
    800059f0:	ef9fe0ef          	jal	ra,800048e8 <end_op>
  return -1;
    800059f4:	57fd                	li	a5,-1
}
    800059f6:	853e                	mv	a0,a5
    800059f8:	70b2                	ld	ra,296(sp)
    800059fa:	7412                	ld	s0,288(sp)
    800059fc:	64f2                	ld	s1,280(sp)
    800059fe:	6952                	ld	s2,272(sp)
    80005a00:	6155                	addi	sp,sp,304
    80005a02:	8082                	ret

0000000080005a04 <sys_unlink>:
{
    80005a04:	7151                	addi	sp,sp,-240
    80005a06:	f586                	sd	ra,232(sp)
    80005a08:	f1a2                	sd	s0,224(sp)
    80005a0a:	eda6                	sd	s1,216(sp)
    80005a0c:	e9ca                	sd	s2,208(sp)
    80005a0e:	e5ce                	sd	s3,200(sp)
    80005a10:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a12:	08000613          	li	a2,128
    80005a16:	f3040593          	addi	a1,s0,-208
    80005a1a:	4501                	li	a0,0
    80005a1c:	bdcfd0ef          	jal	ra,80002df8 <argstr>
    80005a20:	12054b63          	bltz	a0,80005b56 <sys_unlink+0x152>
  begin_op();
    80005a24:	e57fe0ef          	jal	ra,8000487a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a28:	fb040593          	addi	a1,s0,-80
    80005a2c:	f3040513          	addi	a0,s0,-208
    80005a30:	c71fe0ef          	jal	ra,800046a0 <nameiparent>
    80005a34:	84aa                	mv	s1,a0
    80005a36:	c54d                	beqz	a0,80005ae0 <sys_unlink+0xdc>
  ilock(dp);
    80005a38:	c5afe0ef          	jal	ra,80003e92 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a3c:	00003597          	auipc	a1,0x3
    80005a40:	cdc58593          	addi	a1,a1,-804 # 80008718 <syscalls+0x320>
    80005a44:	fb040513          	addi	a0,s0,-80
    80005a48:	9bdfe0ef          	jal	ra,80004404 <namecmp>
    80005a4c:	10050a63          	beqz	a0,80005b60 <sys_unlink+0x15c>
    80005a50:	00003597          	auipc	a1,0x3
    80005a54:	cd058593          	addi	a1,a1,-816 # 80008720 <syscalls+0x328>
    80005a58:	fb040513          	addi	a0,s0,-80
    80005a5c:	9a9fe0ef          	jal	ra,80004404 <namecmp>
    80005a60:	10050063          	beqz	a0,80005b60 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a64:	f2c40613          	addi	a2,s0,-212
    80005a68:	fb040593          	addi	a1,s0,-80
    80005a6c:	8526                	mv	a0,s1
    80005a6e:	9adfe0ef          	jal	ra,8000441a <dirlookup>
    80005a72:	892a                	mv	s2,a0
    80005a74:	0e050663          	beqz	a0,80005b60 <sys_unlink+0x15c>
  ilock(ip);
    80005a78:	c1afe0ef          	jal	ra,80003e92 <ilock>
  if(ip->nlink < 1)
    80005a7c:	04a91783          	lh	a5,74(s2)
    80005a80:	06f05463          	blez	a5,80005ae8 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a84:	04491703          	lh	a4,68(s2)
    80005a88:	4785                	li	a5,1
    80005a8a:	06f70563          	beq	a4,a5,80005af4 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80005a8e:	4641                	li	a2,16
    80005a90:	4581                	li	a1,0
    80005a92:	fc040513          	addi	a0,s0,-64
    80005a96:	aecfb0ef          	jal	ra,80000d82 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a9a:	4741                	li	a4,16
    80005a9c:	f2c42683          	lw	a3,-212(s0)
    80005aa0:	fc040613          	addi	a2,s0,-64
    80005aa4:	4581                	li	a1,0
    80005aa6:	8526                	mv	a0,s1
    80005aa8:	85bfe0ef          	jal	ra,80004302 <writei>
    80005aac:	47c1                	li	a5,16
    80005aae:	08f51563          	bne	a0,a5,80005b38 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80005ab2:	04491703          	lh	a4,68(s2)
    80005ab6:	4785                	li	a5,1
    80005ab8:	08f70663          	beq	a4,a5,80005b44 <sys_unlink+0x140>
  iunlockput(dp);
    80005abc:	8526                	mv	a0,s1
    80005abe:	ddafe0ef          	jal	ra,80004098 <iunlockput>
  ip->nlink--;
    80005ac2:	04a95783          	lhu	a5,74(s2)
    80005ac6:	37fd                	addiw	a5,a5,-1
    80005ac8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005acc:	854a                	mv	a0,s2
    80005ace:	b10fe0ef          	jal	ra,80003dde <iupdate>
  iunlockput(ip);
    80005ad2:	854a                	mv	a0,s2
    80005ad4:	dc4fe0ef          	jal	ra,80004098 <iunlockput>
  end_op();
    80005ad8:	e11fe0ef          	jal	ra,800048e8 <end_op>
  return 0;
    80005adc:	4501                	li	a0,0
    80005ade:	a079                	j	80005b6c <sys_unlink+0x168>
    end_op();
    80005ae0:	e09fe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005ae4:	557d                	li	a0,-1
    80005ae6:	a059                	j	80005b6c <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005ae8:	00003517          	auipc	a0,0x3
    80005aec:	c4050513          	addi	a0,a0,-960 # 80008728 <syscalls+0x330>
    80005af0:	c99fa0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005af4:	04c92703          	lw	a4,76(s2)
    80005af8:	02000793          	li	a5,32
    80005afc:	f8e7f9e3          	bgeu	a5,a4,80005a8e <sys_unlink+0x8a>
    80005b00:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b04:	4741                	li	a4,16
    80005b06:	86ce                	mv	a3,s3
    80005b08:	f1840613          	addi	a2,s0,-232
    80005b0c:	4581                	li	a1,0
    80005b0e:	854a                	mv	a0,s2
    80005b10:	f0efe0ef          	jal	ra,8000421e <readi>
    80005b14:	47c1                	li	a5,16
    80005b16:	00f51b63          	bne	a0,a5,80005b2c <sys_unlink+0x128>
    if(de.inum != 0)
    80005b1a:	f1845783          	lhu	a5,-232(s0)
    80005b1e:	ef95                	bnez	a5,80005b5a <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b20:	29c1                	addiw	s3,s3,16
    80005b22:	04c92783          	lw	a5,76(s2)
    80005b26:	fcf9efe3          	bltu	s3,a5,80005b04 <sys_unlink+0x100>
    80005b2a:	b795                	j	80005a8e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005b2c:	00003517          	auipc	a0,0x3
    80005b30:	c1450513          	addi	a0,a0,-1004 # 80008740 <syscalls+0x348>
    80005b34:	c55fa0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80005b38:	00003517          	auipc	a0,0x3
    80005b3c:	c2050513          	addi	a0,a0,-992 # 80008758 <syscalls+0x360>
    80005b40:	c49fa0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005b44:	04a4d783          	lhu	a5,74(s1)
    80005b48:	37fd                	addiw	a5,a5,-1
    80005b4a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b4e:	8526                	mv	a0,s1
    80005b50:	a8efe0ef          	jal	ra,80003dde <iupdate>
    80005b54:	b7a5                	j	80005abc <sys_unlink+0xb8>
    return -1;
    80005b56:	557d                	li	a0,-1
    80005b58:	a811                	j	80005b6c <sys_unlink+0x168>
    iunlockput(ip);
    80005b5a:	854a                	mv	a0,s2
    80005b5c:	d3cfe0ef          	jal	ra,80004098 <iunlockput>
  iunlockput(dp);
    80005b60:	8526                	mv	a0,s1
    80005b62:	d36fe0ef          	jal	ra,80004098 <iunlockput>
  end_op();
    80005b66:	d83fe0ef          	jal	ra,800048e8 <end_op>
  return -1;
    80005b6a:	557d                	li	a0,-1
}
    80005b6c:	70ae                	ld	ra,232(sp)
    80005b6e:	740e                	ld	s0,224(sp)
    80005b70:	64ee                	ld	s1,216(sp)
    80005b72:	694e                	ld	s2,208(sp)
    80005b74:	69ae                	ld	s3,200(sp)
    80005b76:	616d                	addi	sp,sp,240
    80005b78:	8082                	ret

0000000080005b7a <sys_open>:

uint64
sys_open(void)
{
    80005b7a:	7131                	addi	sp,sp,-192
    80005b7c:	fd06                	sd	ra,184(sp)
    80005b7e:	f922                	sd	s0,176(sp)
    80005b80:	f526                	sd	s1,168(sp)
    80005b82:	f14a                	sd	s2,160(sp)
    80005b84:	ed4e                	sd	s3,152(sp)
    80005b86:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b88:	f4c40593          	addi	a1,s0,-180
    80005b8c:	4505                	li	a0,1
    80005b8e:	a32fd0ef          	jal	ra,80002dc0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b92:	08000613          	li	a2,128
    80005b96:	f5040593          	addi	a1,s0,-176
    80005b9a:	4501                	li	a0,0
    80005b9c:	a5cfd0ef          	jal	ra,80002df8 <argstr>
    80005ba0:	87aa                	mv	a5,a0
    return -1;
    80005ba2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ba4:	0807cd63          	bltz	a5,80005c3e <sys_open+0xc4>

  begin_op();
    80005ba8:	cd3fe0ef          	jal	ra,8000487a <begin_op>

  if(omode & O_CREATE){
    80005bac:	f4c42783          	lw	a5,-180(s0)
    80005bb0:	2007f793          	andi	a5,a5,512
    80005bb4:	c3c5                	beqz	a5,80005c54 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005bb6:	4681                	li	a3,0
    80005bb8:	4601                	li	a2,0
    80005bba:	4589                	li	a1,2
    80005bbc:	f5040513          	addi	a0,s0,-176
    80005bc0:	abfff0ef          	jal	ra,8000567e <create>
    80005bc4:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bc6:	c159                	beqz	a0,80005c4c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bc8:	04449703          	lh	a4,68(s1)
    80005bcc:	478d                	li	a5,3
    80005bce:	00f71763          	bne	a4,a5,80005bdc <sys_open+0x62>
    80005bd2:	0464d703          	lhu	a4,70(s1)
    80005bd6:	47a5                	li	a5,9
    80005bd8:	0ae7e963          	bltu	a5,a4,80005c8a <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bdc:	804ff0ef          	jal	ra,80004be0 <filealloc>
    80005be0:	89aa                	mv	s3,a0
    80005be2:	0c050963          	beqz	a0,80005cb4 <sys_open+0x13a>
    80005be6:	a5bff0ef          	jal	ra,80005640 <fdalloc>
    80005bea:	892a                	mv	s2,a0
    80005bec:	0c054163          	bltz	a0,80005cae <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005bf0:	04449703          	lh	a4,68(s1)
    80005bf4:	478d                	li	a5,3
    80005bf6:	0af70163          	beq	a4,a5,80005c98 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005bfa:	4789                	li	a5,2
    80005bfc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c00:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c04:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c08:	f4c42783          	lw	a5,-180(s0)
    80005c0c:	0017c713          	xori	a4,a5,1
    80005c10:	8b05                	andi	a4,a4,1
    80005c12:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c16:	0037f713          	andi	a4,a5,3
    80005c1a:	00e03733          	snez	a4,a4
    80005c1e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c22:	4007f793          	andi	a5,a5,1024
    80005c26:	c791                	beqz	a5,80005c32 <sys_open+0xb8>
    80005c28:	04449703          	lh	a4,68(s1)
    80005c2c:	4789                	li	a5,2
    80005c2e:	06f70c63          	beq	a4,a5,80005ca6 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c32:	8526                	mv	a0,s1
    80005c34:	b08fe0ef          	jal	ra,80003f3c <iunlock>
  end_op();
    80005c38:	cb1fe0ef          	jal	ra,800048e8 <end_op>

  return fd;
    80005c3c:	854a                	mv	a0,s2
}
    80005c3e:	70ea                	ld	ra,184(sp)
    80005c40:	744a                	ld	s0,176(sp)
    80005c42:	74aa                	ld	s1,168(sp)
    80005c44:	790a                	ld	s2,160(sp)
    80005c46:	69ea                	ld	s3,152(sp)
    80005c48:	6129                	addi	sp,sp,192
    80005c4a:	8082                	ret
      end_op();
    80005c4c:	c9dfe0ef          	jal	ra,800048e8 <end_op>
      return -1;
    80005c50:	557d                	li	a0,-1
    80005c52:	b7f5                	j	80005c3e <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005c54:	f5040513          	addi	a0,s0,-176
    80005c58:	a2ffe0ef          	jal	ra,80004686 <namei>
    80005c5c:	84aa                	mv	s1,a0
    80005c5e:	c115                	beqz	a0,80005c82 <sys_open+0x108>
    ilock(ip);
    80005c60:	a32fe0ef          	jal	ra,80003e92 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c64:	04449703          	lh	a4,68(s1)
    80005c68:	4785                	li	a5,1
    80005c6a:	f4f71fe3          	bne	a4,a5,80005bc8 <sys_open+0x4e>
    80005c6e:	f4c42783          	lw	a5,-180(s0)
    80005c72:	d7ad                	beqz	a5,80005bdc <sys_open+0x62>
      iunlockput(ip);
    80005c74:	8526                	mv	a0,s1
    80005c76:	c22fe0ef          	jal	ra,80004098 <iunlockput>
      end_op();
    80005c7a:	c6ffe0ef          	jal	ra,800048e8 <end_op>
      return -1;
    80005c7e:	557d                	li	a0,-1
    80005c80:	bf7d                	j	80005c3e <sys_open+0xc4>
      end_op();
    80005c82:	c67fe0ef          	jal	ra,800048e8 <end_op>
      return -1;
    80005c86:	557d                	li	a0,-1
    80005c88:	bf5d                	j	80005c3e <sys_open+0xc4>
    iunlockput(ip);
    80005c8a:	8526                	mv	a0,s1
    80005c8c:	c0cfe0ef          	jal	ra,80004098 <iunlockput>
    end_op();
    80005c90:	c59fe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005c94:	557d                	li	a0,-1
    80005c96:	b765                	j	80005c3e <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005c98:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c9c:	04649783          	lh	a5,70(s1)
    80005ca0:	02f99223          	sh	a5,36(s3)
    80005ca4:	b785                	j	80005c04 <sys_open+0x8a>
    itrunc(ip);
    80005ca6:	8526                	mv	a0,s1
    80005ca8:	ad4fe0ef          	jal	ra,80003f7c <itrunc>
    80005cac:	b759                	j	80005c32 <sys_open+0xb8>
      fileclose(f);
    80005cae:	854e                	mv	a0,s3
    80005cb0:	fd5fe0ef          	jal	ra,80004c84 <fileclose>
    iunlockput(ip);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	be2fe0ef          	jal	ra,80004098 <iunlockput>
    end_op();
    80005cba:	c2ffe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005cbe:	557d                	li	a0,-1
    80005cc0:	bfbd                	j	80005c3e <sys_open+0xc4>

0000000080005cc2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005cc2:	7175                	addi	sp,sp,-144
    80005cc4:	e506                	sd	ra,136(sp)
    80005cc6:	e122                	sd	s0,128(sp)
    80005cc8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cca:	bb1fe0ef          	jal	ra,8000487a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005cce:	08000613          	li	a2,128
    80005cd2:	f7040593          	addi	a1,s0,-144
    80005cd6:	4501                	li	a0,0
    80005cd8:	920fd0ef          	jal	ra,80002df8 <argstr>
    80005cdc:	02054363          	bltz	a0,80005d02 <sys_mkdir+0x40>
    80005ce0:	4681                	li	a3,0
    80005ce2:	4601                	li	a2,0
    80005ce4:	4585                	li	a1,1
    80005ce6:	f7040513          	addi	a0,s0,-144
    80005cea:	995ff0ef          	jal	ra,8000567e <create>
    80005cee:	c911                	beqz	a0,80005d02 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cf0:	ba8fe0ef          	jal	ra,80004098 <iunlockput>
  end_op();
    80005cf4:	bf5fe0ef          	jal	ra,800048e8 <end_op>
  return 0;
    80005cf8:	4501                	li	a0,0
}
    80005cfa:	60aa                	ld	ra,136(sp)
    80005cfc:	640a                	ld	s0,128(sp)
    80005cfe:	6149                	addi	sp,sp,144
    80005d00:	8082                	ret
    end_op();
    80005d02:	be7fe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005d06:	557d                	li	a0,-1
    80005d08:	bfcd                	j	80005cfa <sys_mkdir+0x38>

0000000080005d0a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d0a:	7135                	addi	sp,sp,-160
    80005d0c:	ed06                	sd	ra,152(sp)
    80005d0e:	e922                	sd	s0,144(sp)
    80005d10:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d12:	b69fe0ef          	jal	ra,8000487a <begin_op>
  argint(1, &major);
    80005d16:	f6c40593          	addi	a1,s0,-148
    80005d1a:	4505                	li	a0,1
    80005d1c:	8a4fd0ef          	jal	ra,80002dc0 <argint>
  argint(2, &minor);
    80005d20:	f6840593          	addi	a1,s0,-152
    80005d24:	4509                	li	a0,2
    80005d26:	89afd0ef          	jal	ra,80002dc0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d2a:	08000613          	li	a2,128
    80005d2e:	f7040593          	addi	a1,s0,-144
    80005d32:	4501                	li	a0,0
    80005d34:	8c4fd0ef          	jal	ra,80002df8 <argstr>
    80005d38:	02054563          	bltz	a0,80005d62 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d3c:	f6841683          	lh	a3,-152(s0)
    80005d40:	f6c41603          	lh	a2,-148(s0)
    80005d44:	458d                	li	a1,3
    80005d46:	f7040513          	addi	a0,s0,-144
    80005d4a:	935ff0ef          	jal	ra,8000567e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d4e:	c911                	beqz	a0,80005d62 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d50:	b48fe0ef          	jal	ra,80004098 <iunlockput>
  end_op();
    80005d54:	b95fe0ef          	jal	ra,800048e8 <end_op>
  return 0;
    80005d58:	4501                	li	a0,0
}
    80005d5a:	60ea                	ld	ra,152(sp)
    80005d5c:	644a                	ld	s0,144(sp)
    80005d5e:	610d                	addi	sp,sp,160
    80005d60:	8082                	ret
    end_op();
    80005d62:	b87fe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005d66:	557d                	li	a0,-1
    80005d68:	bfcd                	j	80005d5a <sys_mknod+0x50>

0000000080005d6a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d6a:	7135                	addi	sp,sp,-160
    80005d6c:	ed06                	sd	ra,152(sp)
    80005d6e:	e922                	sd	s0,144(sp)
    80005d70:	e526                	sd	s1,136(sp)
    80005d72:	e14a                	sd	s2,128(sp)
    80005d74:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d76:	e23fb0ef          	jal	ra,80001b98 <myproc>
    80005d7a:	892a                	mv	s2,a0
  
  begin_op();
    80005d7c:	afffe0ef          	jal	ra,8000487a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d80:	08000613          	li	a2,128
    80005d84:	f6040593          	addi	a1,s0,-160
    80005d88:	4501                	li	a0,0
    80005d8a:	86efd0ef          	jal	ra,80002df8 <argstr>
    80005d8e:	04054163          	bltz	a0,80005dd0 <sys_chdir+0x66>
    80005d92:	f6040513          	addi	a0,s0,-160
    80005d96:	8f1fe0ef          	jal	ra,80004686 <namei>
    80005d9a:	84aa                	mv	s1,a0
    80005d9c:	c915                	beqz	a0,80005dd0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d9e:	8f4fe0ef          	jal	ra,80003e92 <ilock>
  if(ip->type != T_DIR){
    80005da2:	04449703          	lh	a4,68(s1)
    80005da6:	4785                	li	a5,1
    80005da8:	02f71863          	bne	a4,a5,80005dd8 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005dac:	8526                	mv	a0,s1
    80005dae:	98efe0ef          	jal	ra,80003f3c <iunlock>
  iput(p->cwd);
    80005db2:	15093503          	ld	a0,336(s2)
    80005db6:	a5afe0ef          	jal	ra,80004010 <iput>
  end_op();
    80005dba:	b2ffe0ef          	jal	ra,800048e8 <end_op>
  p->cwd = ip;
    80005dbe:	14993823          	sd	s1,336(s2)
  return 0;
    80005dc2:	4501                	li	a0,0
}
    80005dc4:	60ea                	ld	ra,152(sp)
    80005dc6:	644a                	ld	s0,144(sp)
    80005dc8:	64aa                	ld	s1,136(sp)
    80005dca:	690a                	ld	s2,128(sp)
    80005dcc:	610d                	addi	sp,sp,160
    80005dce:	8082                	ret
    end_op();
    80005dd0:	b19fe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005dd4:	557d                	li	a0,-1
    80005dd6:	b7fd                	j	80005dc4 <sys_chdir+0x5a>
    iunlockput(ip);
    80005dd8:	8526                	mv	a0,s1
    80005dda:	abefe0ef          	jal	ra,80004098 <iunlockput>
    end_op();
    80005dde:	b0bfe0ef          	jal	ra,800048e8 <end_op>
    return -1;
    80005de2:	557d                	li	a0,-1
    80005de4:	b7c5                	j	80005dc4 <sys_chdir+0x5a>

0000000080005de6 <sys_exec>:

uint64
sys_exec(void)
{
    80005de6:	7145                	addi	sp,sp,-464
    80005de8:	e786                	sd	ra,456(sp)
    80005dea:	e3a2                	sd	s0,448(sp)
    80005dec:	ff26                	sd	s1,440(sp)
    80005dee:	fb4a                	sd	s2,432(sp)
    80005df0:	f74e                	sd	s3,424(sp)
    80005df2:	f352                	sd	s4,416(sp)
    80005df4:	ef56                	sd	s5,408(sp)
    80005df6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005df8:	e3840593          	addi	a1,s0,-456
    80005dfc:	4505                	li	a0,1
    80005dfe:	fdffc0ef          	jal	ra,80002ddc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e02:	08000613          	li	a2,128
    80005e06:	f4040593          	addi	a1,s0,-192
    80005e0a:	4501                	li	a0,0
    80005e0c:	fedfc0ef          	jal	ra,80002df8 <argstr>
    80005e10:	87aa                	mv	a5,a0
    return -1;
    80005e12:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e14:	0a07c563          	bltz	a5,80005ebe <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005e18:	10000613          	li	a2,256
    80005e1c:	4581                	li	a1,0
    80005e1e:	e4040513          	addi	a0,s0,-448
    80005e22:	f61fa0ef          	jal	ra,80000d82 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e26:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e2a:	89a6                	mv	s3,s1
    80005e2c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e2e:	02000a13          	li	s4,32
    80005e32:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e36:	00391513          	slli	a0,s2,0x3
    80005e3a:	e3040593          	addi	a1,s0,-464
    80005e3e:	e3843783          	ld	a5,-456(s0)
    80005e42:	953e                	add	a0,a0,a5
    80005e44:	ef3fc0ef          	jal	ra,80002d36 <fetchaddr>
    80005e48:	02054663          	bltz	a0,80005e74 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005e4c:	e3043783          	ld	a5,-464(s0)
    80005e50:	cf8d                	beqz	a5,80005e8a <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e52:	d59fa0ef          	jal	ra,80000baa <kalloc>
    80005e56:	85aa                	mv	a1,a0
    80005e58:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e5c:	cd01                	beqz	a0,80005e74 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e5e:	6605                	lui	a2,0x1
    80005e60:	e3043503          	ld	a0,-464(s0)
    80005e64:	f1dfc0ef          	jal	ra,80002d80 <fetchstr>
    80005e68:	00054663          	bltz	a0,80005e74 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005e6c:	0905                	addi	s2,s2,1
    80005e6e:	09a1                	addi	s3,s3,8
    80005e70:	fd4911e3          	bne	s2,s4,80005e32 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e74:	f4040913          	addi	s2,s0,-192
    80005e78:	6088                	ld	a0,0(s1)
    80005e7a:	c129                	beqz	a0,80005ebc <sys_exec+0xd6>
    kfree(argv[i]);
    80005e7c:	bfffa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e80:	04a1                	addi	s1,s1,8
    80005e82:	ff249be3          	bne	s1,s2,80005e78 <sys_exec+0x92>
  return -1;
    80005e86:	557d                	li	a0,-1
    80005e88:	a81d                	j	80005ebe <sys_exec+0xd8>
      argv[i] = 0;
    80005e8a:	0a8e                	slli	s5,s5,0x3
    80005e8c:	fc0a8793          	addi	a5,s5,-64
    80005e90:	00878ab3          	add	s5,a5,s0
    80005e94:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005e98:	e4040593          	addi	a1,s0,-448
    80005e9c:	f4040513          	addi	a0,s0,-192
    80005ea0:	b90ff0ef          	jal	ra,80005230 <kexec>
    80005ea4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ea6:	f4040993          	addi	s3,s0,-192
    80005eaa:	6088                	ld	a0,0(s1)
    80005eac:	c511                	beqz	a0,80005eb8 <sys_exec+0xd2>
    kfree(argv[i]);
    80005eae:	bcdfa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb2:	04a1                	addi	s1,s1,8
    80005eb4:	ff349be3          	bne	s1,s3,80005eaa <sys_exec+0xc4>
  return ret;
    80005eb8:	854a                	mv	a0,s2
    80005eba:	a011                	j	80005ebe <sys_exec+0xd8>
  return -1;
    80005ebc:	557d                	li	a0,-1
}
    80005ebe:	60be                	ld	ra,456(sp)
    80005ec0:	641e                	ld	s0,448(sp)
    80005ec2:	74fa                	ld	s1,440(sp)
    80005ec4:	795a                	ld	s2,432(sp)
    80005ec6:	79ba                	ld	s3,424(sp)
    80005ec8:	7a1a                	ld	s4,416(sp)
    80005eca:	6afa                	ld	s5,408(sp)
    80005ecc:	6179                	addi	sp,sp,464
    80005ece:	8082                	ret

0000000080005ed0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ed0:	7139                	addi	sp,sp,-64
    80005ed2:	fc06                	sd	ra,56(sp)
    80005ed4:	f822                	sd	s0,48(sp)
    80005ed6:	f426                	sd	s1,40(sp)
    80005ed8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005eda:	cbffb0ef          	jal	ra,80001b98 <myproc>
    80005ede:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ee0:	fd840593          	addi	a1,s0,-40
    80005ee4:	4501                	li	a0,0
    80005ee6:	ef7fc0ef          	jal	ra,80002ddc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005eea:	fc840593          	addi	a1,s0,-56
    80005eee:	fd040513          	addi	a0,s0,-48
    80005ef2:	85eff0ef          	jal	ra,80004f50 <pipealloc>
    return -1;
    80005ef6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ef8:	0a054463          	bltz	a0,80005fa0 <sys_pipe+0xd0>
  fd0 = -1;
    80005efc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f00:	fd043503          	ld	a0,-48(s0)
    80005f04:	f3cff0ef          	jal	ra,80005640 <fdalloc>
    80005f08:	fca42223          	sw	a0,-60(s0)
    80005f0c:	08054163          	bltz	a0,80005f8e <sys_pipe+0xbe>
    80005f10:	fc843503          	ld	a0,-56(s0)
    80005f14:	f2cff0ef          	jal	ra,80005640 <fdalloc>
    80005f18:	fca42023          	sw	a0,-64(s0)
    80005f1c:	06054063          	bltz	a0,80005f7c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f20:	4691                	li	a3,4
    80005f22:	fc440613          	addi	a2,s0,-60
    80005f26:	fd843583          	ld	a1,-40(s0)
    80005f2a:	68a8                	ld	a0,80(s1)
    80005f2c:	85dfb0ef          	jal	ra,80001788 <copyout>
    80005f30:	00054e63          	bltz	a0,80005f4c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f34:	4691                	li	a3,4
    80005f36:	fc040613          	addi	a2,s0,-64
    80005f3a:	fd843583          	ld	a1,-40(s0)
    80005f3e:	0591                	addi	a1,a1,4
    80005f40:	68a8                	ld	a0,80(s1)
    80005f42:	847fb0ef          	jal	ra,80001788 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f46:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f48:	04055c63          	bgez	a0,80005fa0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005f4c:	fc442783          	lw	a5,-60(s0)
    80005f50:	07e9                	addi	a5,a5,26
    80005f52:	078e                	slli	a5,a5,0x3
    80005f54:	97a6                	add	a5,a5,s1
    80005f56:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f5a:	fc042783          	lw	a5,-64(s0)
    80005f5e:	07e9                	addi	a5,a5,26
    80005f60:	078e                	slli	a5,a5,0x3
    80005f62:	94be                	add	s1,s1,a5
    80005f64:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f68:	fd043503          	ld	a0,-48(s0)
    80005f6c:	d19fe0ef          	jal	ra,80004c84 <fileclose>
    fileclose(wf);
    80005f70:	fc843503          	ld	a0,-56(s0)
    80005f74:	d11fe0ef          	jal	ra,80004c84 <fileclose>
    return -1;
    80005f78:	57fd                	li	a5,-1
    80005f7a:	a01d                	j	80005fa0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005f7c:	fc442783          	lw	a5,-60(s0)
    80005f80:	0007c763          	bltz	a5,80005f8e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005f84:	07e9                	addi	a5,a5,26
    80005f86:	078e                	slli	a5,a5,0x3
    80005f88:	97a6                	add	a5,a5,s1
    80005f8a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005f8e:	fd043503          	ld	a0,-48(s0)
    80005f92:	cf3fe0ef          	jal	ra,80004c84 <fileclose>
    fileclose(wf);
    80005f96:	fc843503          	ld	a0,-56(s0)
    80005f9a:	cebfe0ef          	jal	ra,80004c84 <fileclose>
    return -1;
    80005f9e:	57fd                	li	a5,-1
}
    80005fa0:	853e                	mv	a0,a5
    80005fa2:	70e2                	ld	ra,56(sp)
    80005fa4:	7442                	ld	s0,48(sp)
    80005fa6:	74a2                	ld	s1,40(sp)
    80005fa8:	6121                	addi	sp,sp,64
    80005faa:	8082                	ret
    80005fac:	0000                	unimp
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
    80005fd6:	c71fc0ef          	jal	ra,80002c46 <kerneltrap>

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
    8000602c:	b41fb0ef          	jal	ra,80001b6c <cpuid>
  
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
    8000604a:	97aa                	add	a5,a5,a0
    8000604c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
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
    80006060:	b0dfb0ef          	jal	ra,80001b6c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006064:	00d5151b          	slliw	a0,a0,0xd
    80006068:	0c2017b7          	lui	a5,0xc201
    8000606c:	97aa                	add	a5,a5,a0
  return irq;
}
    8000606e:	43c8                	lw	a0,4(a5)
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
    80006084:	ae9fb0ef          	jal	ra,80001b6c <cpuid>
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
    800060b0:	a4478793          	addi	a5,a5,-1468 # 8024baf0 <disk>
    800060b4:	97aa                	add	a5,a5,a0
    800060b6:	0187c783          	lbu	a5,24(a5)
    800060ba:	e7b9                	bnez	a5,80006108 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060bc:	00451693          	slli	a3,a0,0x4
    800060c0:	00246797          	auipc	a5,0x246
    800060c4:	a3078793          	addi	a5,a5,-1488 # 8024baf0 <disk>
    800060c8:	6398                	ld	a4,0(a5)
    800060ca:	9736                	add	a4,a4,a3
    800060cc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800060d0:	6398                	ld	a4,0(a5)
    800060d2:	9736                	add	a4,a4,a3
    800060d4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800060d8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800060dc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800060e0:	97aa                	add	a5,a5,a0
    800060e2:	4705                	li	a4,1
    800060e4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800060e8:	00246517          	auipc	a0,0x246
    800060ec:	a2050513          	addi	a0,a0,-1504 # 8024bb08 <disk+0x18>
    800060f0:	be4fc0ef          	jal	ra,800024d4 <wakeup>
}
    800060f4:	60a2                	ld	ra,8(sp)
    800060f6:	6402                	ld	s0,0(sp)
    800060f8:	0141                	addi	sp,sp,16
    800060fa:	8082                	ret
    panic("free_desc 1");
    800060fc:	00002517          	auipc	a0,0x2
    80006100:	66c50513          	addi	a0,a0,1644 # 80008768 <syscalls+0x370>
    80006104:	e84fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80006108:	00002517          	auipc	a0,0x2
    8000610c:	67050513          	addi	a0,a0,1648 # 80008778 <syscalls+0x380>
    80006110:	e78fa0ef          	jal	ra,80000788 <panic>

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
    8000612c:	af050513          	addi	a0,a0,-1296 # 8024bc18 <disk+0x128>
    80006130:	afffa0ef          	jal	ra,80000c2e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006134:	100017b7          	lui	a5,0x10001
    80006138:	4398                	lw	a4,0(a5)
    8000613a:	2701                	sext.w	a4,a4
    8000613c:	747277b7          	lui	a5,0x74727
    80006140:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006144:	12f71f63          	bne	a4,a5,80006282 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006148:	100017b7          	lui	a5,0x10001
    8000614c:	43dc                	lw	a5,4(a5)
    8000614e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006150:	4709                	li	a4,2
    80006152:	12e79863          	bne	a5,a4,80006282 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006156:	100017b7          	lui	a5,0x10001
    8000615a:	479c                	lw	a5,8(a5)
    8000615c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000615e:	12e79263          	bne	a5,a4,80006282 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006162:	100017b7          	lui	a5,0x10001
    80006166:	47d8                	lw	a4,12(a5)
    80006168:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000616a:	554d47b7          	lui	a5,0x554d4
    8000616e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006172:	10f71863          	bne	a4,a5,80006282 <virtio_disk_init+0x16e>
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
    80006186:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006188:	c7ffe6b7          	lui	a3,0xc7ffe
    8000618c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47daa54f>
    80006190:	8f75                	and	a4,a4,a3
    80006192:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006194:	472d                	li	a4,11
    80006196:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006198:	5bbc                	lw	a5,112(a5)
    8000619a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000619e:	8ba1                	andi	a5,a5,8
    800061a0:	0e078763          	beqz	a5,8000628e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061a4:	100017b7          	lui	a5,0x10001
    800061a8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800061ac:	43fc                	lw	a5,68(a5)
    800061ae:	2781                	sext.w	a5,a5
    800061b0:	0e079563          	bnez	a5,8000629a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061b4:	100017b7          	lui	a5,0x10001
    800061b8:	5bdc                	lw	a5,52(a5)
    800061ba:	2781                	sext.w	a5,a5
  if(max == 0)
    800061bc:	0e078563          	beqz	a5,800062a6 <virtio_disk_init+0x192>
  if(max < NUM)
    800061c0:	471d                	li	a4,7
    800061c2:	0ef77863          	bgeu	a4,a5,800062b2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    800061c6:	9e5fa0ef          	jal	ra,80000baa <kalloc>
    800061ca:	00246497          	auipc	s1,0x246
    800061ce:	92648493          	addi	s1,s1,-1754 # 8024baf0 <disk>
    800061d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800061d4:	9d7fa0ef          	jal	ra,80000baa <kalloc>
    800061d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800061da:	9d1fa0ef          	jal	ra,80000baa <kalloc>
    800061de:	87aa                	mv	a5,a0
    800061e0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061e2:	6088                	ld	a0,0(s1)
    800061e4:	cd69                	beqz	a0,800062be <virtio_disk_init+0x1aa>
    800061e6:	00246717          	auipc	a4,0x246
    800061ea:	91273703          	ld	a4,-1774(a4) # 8024baf8 <disk+0x8>
    800061ee:	cb61                	beqz	a4,800062be <virtio_disk_init+0x1aa>
    800061f0:	c7f9                	beqz	a5,800062be <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    800061f2:	6605                	lui	a2,0x1
    800061f4:	4581                	li	a1,0
    800061f6:	b8dfa0ef          	jal	ra,80000d82 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061fa:	00246497          	auipc	s1,0x246
    800061fe:	8f648493          	addi	s1,s1,-1802 # 8024baf0 <disk>
    80006202:	6605                	lui	a2,0x1
    80006204:	4581                	li	a1,0
    80006206:	6488                	ld	a0,8(s1)
    80006208:	b7bfa0ef          	jal	ra,80000d82 <memset>
  memset(disk.used, 0, PGSIZE);
    8000620c:	6605                	lui	a2,0x1
    8000620e:	4581                	li	a1,0
    80006210:	6888                	ld	a0,16(s1)
    80006212:	b71fa0ef          	jal	ra,80000d82 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006216:	100017b7          	lui	a5,0x10001
    8000621a:	4721                	li	a4,8
    8000621c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000621e:	4098                	lw	a4,0(s1)
    80006220:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006224:	40d8                	lw	a4,4(s1)
    80006226:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000622a:	6498                	ld	a4,8(s1)
    8000622c:	0007069b          	sext.w	a3,a4
    80006230:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006234:	9701                	srai	a4,a4,0x20
    80006236:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000623a:	6898                	ld	a4,16(s1)
    8000623c:	0007069b          	sext.w	a3,a4
    80006240:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006244:	9701                	srai	a4,a4,0x20
    80006246:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000624a:	4705                	li	a4,1
    8000624c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000624e:	00e48c23          	sb	a4,24(s1)
    80006252:	00e48ca3          	sb	a4,25(s1)
    80006256:	00e48d23          	sb	a4,26(s1)
    8000625a:	00e48da3          	sb	a4,27(s1)
    8000625e:	00e48e23          	sb	a4,28(s1)
    80006262:	00e48ea3          	sb	a4,29(s1)
    80006266:	00e48f23          	sb	a4,30(s1)
    8000626a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000626e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006272:	0727a823          	sw	s2,112(a5)
}
    80006276:	60e2                	ld	ra,24(sp)
    80006278:	6442                	ld	s0,16(sp)
    8000627a:	64a2                	ld	s1,8(sp)
    8000627c:	6902                	ld	s2,0(sp)
    8000627e:	6105                	addi	sp,sp,32
    80006280:	8082                	ret
    panic("could not find virtio disk");
    80006282:	00002517          	auipc	a0,0x2
    80006286:	51650513          	addi	a0,a0,1302 # 80008798 <syscalls+0x3a0>
    8000628a:	cfefa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000628e:	00002517          	auipc	a0,0x2
    80006292:	52a50513          	addi	a0,a0,1322 # 800087b8 <syscalls+0x3c0>
    80006296:	cf2fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    8000629a:	00002517          	auipc	a0,0x2
    8000629e:	53e50513          	addi	a0,a0,1342 # 800087d8 <syscalls+0x3e0>
    800062a2:	ce6fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    800062a6:	00002517          	auipc	a0,0x2
    800062aa:	55250513          	addi	a0,a0,1362 # 800087f8 <syscalls+0x400>
    800062ae:	cdafa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    800062b2:	00002517          	auipc	a0,0x2
    800062b6:	56650513          	addi	a0,a0,1382 # 80008818 <syscalls+0x420>
    800062ba:	ccefa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    800062be:	00002517          	auipc	a0,0x2
    800062c2:	57a50513          	addi	a0,a0,1402 # 80008838 <syscalls+0x440>
    800062c6:	cc2fa0ef          	jal	ra,80000788 <panic>

00000000800062ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062ca:	7119                	addi	sp,sp,-128
    800062cc:	fc86                	sd	ra,120(sp)
    800062ce:	f8a2                	sd	s0,112(sp)
    800062d0:	f4a6                	sd	s1,104(sp)
    800062d2:	f0ca                	sd	s2,96(sp)
    800062d4:	ecce                	sd	s3,88(sp)
    800062d6:	e8d2                	sd	s4,80(sp)
    800062d8:	e4d6                	sd	s5,72(sp)
    800062da:	e0da                	sd	s6,64(sp)
    800062dc:	fc5e                	sd	s7,56(sp)
    800062de:	f862                	sd	s8,48(sp)
    800062e0:	f466                	sd	s9,40(sp)
    800062e2:	f06a                	sd	s10,32(sp)
    800062e4:	ec6e                	sd	s11,24(sp)
    800062e6:	0100                	addi	s0,sp,128
    800062e8:	8aaa                	mv	s5,a0
    800062ea:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062ec:	00c52d03          	lw	s10,12(a0)
    800062f0:	001d1d1b          	slliw	s10,s10,0x1
    800062f4:	1d02                	slli	s10,s10,0x20
    800062f6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800062fa:	00246517          	auipc	a0,0x246
    800062fe:	91e50513          	addi	a0,a0,-1762 # 8024bc18 <disk+0x128>
    80006302:	9adfa0ef          	jal	ra,80000cae <acquire>
  for(int i = 0; i < 3; i++){
    80006306:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006308:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000630a:	00245b97          	auipc	s7,0x245
    8000630e:	7e6b8b93          	addi	s7,s7,2022 # 8024baf0 <disk>
  for(int i = 0; i < 3; i++){
    80006312:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006314:	00246c97          	auipc	s9,0x246
    80006318:	904c8c93          	addi	s9,s9,-1788 # 8024bc18 <disk+0x128>
    8000631c:	a8a9                	j	80006376 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    8000631e:	00fb8733          	add	a4,s7,a5
    80006322:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006326:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006328:	0207c563          	bltz	a5,80006352 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000632c:	2905                	addiw	s2,s2,1
    8000632e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006330:	05690863          	beq	s2,s6,80006380 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80006334:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006336:	00245717          	auipc	a4,0x245
    8000633a:	7ba70713          	addi	a4,a4,1978 # 8024baf0 <disk>
    8000633e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006340:	01874683          	lbu	a3,24(a4)
    80006344:	fee9                	bnez	a3,8000631e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006346:	2785                	addiw	a5,a5,1
    80006348:	0705                	addi	a4,a4,1
    8000634a:	fe979be3          	bne	a5,s1,80006340 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000634e:	57fd                	li	a5,-1
    80006350:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006352:	01205b63          	blez	s2,80006368 <virtio_disk_rw+0x9e>
    80006356:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006358:	000a2503          	lw	a0,0(s4)
    8000635c:	d43ff0ef          	jal	ra,8000609e <free_desc>
      for(int j = 0; j < i; j++)
    80006360:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    80006362:	0a11                	addi	s4,s4,4
    80006364:	ff2d9ae3          	bne	s11,s2,80006358 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006368:	85e6                	mv	a1,s9
    8000636a:	00245517          	auipc	a0,0x245
    8000636e:	79e50513          	addi	a0,a0,1950 # 8024bb08 <disk+0x18>
    80006372:	916fc0ef          	jal	ra,80002488 <sleep>
  for(int i = 0; i < 3; i++){
    80006376:	f8040a13          	addi	s4,s0,-128
{
    8000637a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000637c:	894e                	mv	s2,s3
    8000637e:	bf5d                	j	80006334 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006380:	f8042503          	lw	a0,-128(s0)
    80006384:	00a50713          	addi	a4,a0,10
    80006388:	0712                	slli	a4,a4,0x4

  if(write)
    8000638a:	00245797          	auipc	a5,0x245
    8000638e:	76678793          	addi	a5,a5,1894 # 8024baf0 <disk>
    80006392:	00e786b3          	add	a3,a5,a4
    80006396:	01803633          	snez	a2,s8
    8000639a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000639c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800063a0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063a4:	f6070613          	addi	a2,a4,-160
    800063a8:	6394                	ld	a3,0(a5)
    800063aa:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063ac:	00870593          	addi	a1,a4,8
    800063b0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063b2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063b4:	0007b803          	ld	a6,0(a5)
    800063b8:	9642                	add	a2,a2,a6
    800063ba:	46c1                	li	a3,16
    800063bc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063be:	4585                	li	a1,1
    800063c0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800063c4:	f8442683          	lw	a3,-124(s0)
    800063c8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063cc:	0692                	slli	a3,a3,0x4
    800063ce:	9836                	add	a6,a6,a3
    800063d0:	058a8613          	addi	a2,s5,88
    800063d4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800063d8:	0007b803          	ld	a6,0(a5)
    800063dc:	96c2                	add	a3,a3,a6
    800063de:	40000613          	li	a2,1024
    800063e2:	c690                	sw	a2,8(a3)
  if(write)
    800063e4:	001c3613          	seqz	a2,s8
    800063e8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063ec:	00166613          	ori	a2,a2,1
    800063f0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800063f4:	f8842603          	lw	a2,-120(s0)
    800063f8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063fc:	00250693          	addi	a3,a0,2
    80006400:	0692                	slli	a3,a3,0x4
    80006402:	96be                	add	a3,a3,a5
    80006404:	58fd                	li	a7,-1
    80006406:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000640a:	0612                	slli	a2,a2,0x4
    8000640c:	9832                	add	a6,a6,a2
    8000640e:	f9070713          	addi	a4,a4,-112
    80006412:	973e                	add	a4,a4,a5
    80006414:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006418:	6398                	ld	a4,0(a5)
    8000641a:	9732                	add	a4,a4,a2
    8000641c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000641e:	4609                	li	a2,2
    80006420:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006424:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006428:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    8000642c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006430:	6794                	ld	a3,8(a5)
    80006432:	0026d703          	lhu	a4,2(a3)
    80006436:	8b1d                	andi	a4,a4,7
    80006438:	0706                	slli	a4,a4,0x1
    8000643a:	96ba                	add	a3,a3,a4
    8000643c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006440:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006444:	6798                	ld	a4,8(a5)
    80006446:	00275783          	lhu	a5,2(a4)
    8000644a:	2785                	addiw	a5,a5,1
    8000644c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006450:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006454:	100017b7          	lui	a5,0x10001
    80006458:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000645c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006460:	00245917          	auipc	s2,0x245
    80006464:	7b890913          	addi	s2,s2,1976 # 8024bc18 <disk+0x128>
  while(b->disk == 1) {
    80006468:	4485                	li	s1,1
    8000646a:	00b79a63          	bne	a5,a1,8000647e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    8000646e:	85ca                	mv	a1,s2
    80006470:	8556                	mv	a0,s5
    80006472:	816fc0ef          	jal	ra,80002488 <sleep>
  while(b->disk == 1) {
    80006476:	004aa783          	lw	a5,4(s5)
    8000647a:	fe978ae3          	beq	a5,s1,8000646e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    8000647e:	f8042903          	lw	s2,-128(s0)
    80006482:	00290713          	addi	a4,s2,2
    80006486:	0712                	slli	a4,a4,0x4
    80006488:	00245797          	auipc	a5,0x245
    8000648c:	66878793          	addi	a5,a5,1640 # 8024baf0 <disk>
    80006490:	97ba                	add	a5,a5,a4
    80006492:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006496:	00245997          	auipc	s3,0x245
    8000649a:	65a98993          	addi	s3,s3,1626 # 8024baf0 <disk>
    8000649e:	00491713          	slli	a4,s2,0x4
    800064a2:	0009b783          	ld	a5,0(s3)
    800064a6:	97ba                	add	a5,a5,a4
    800064a8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064ac:	854a                	mv	a0,s2
    800064ae:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064b2:	bedff0ef          	jal	ra,8000609e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064b6:	8885                	andi	s1,s1,1
    800064b8:	f0fd                	bnez	s1,8000649e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064ba:	00245517          	auipc	a0,0x245
    800064be:	75e50513          	addi	a0,a0,1886 # 8024bc18 <disk+0x128>
    800064c2:	885fa0ef          	jal	ra,80000d46 <release>
}
    800064c6:	70e6                	ld	ra,120(sp)
    800064c8:	7446                	ld	s0,112(sp)
    800064ca:	74a6                	ld	s1,104(sp)
    800064cc:	7906                	ld	s2,96(sp)
    800064ce:	69e6                	ld	s3,88(sp)
    800064d0:	6a46                	ld	s4,80(sp)
    800064d2:	6aa6                	ld	s5,72(sp)
    800064d4:	6b06                	ld	s6,64(sp)
    800064d6:	7be2                	ld	s7,56(sp)
    800064d8:	7c42                	ld	s8,48(sp)
    800064da:	7ca2                	ld	s9,40(sp)
    800064dc:	7d02                	ld	s10,32(sp)
    800064de:	6de2                	ld	s11,24(sp)
    800064e0:	6109                	addi	sp,sp,128
    800064e2:	8082                	ret

00000000800064e4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064e4:	1101                	addi	sp,sp,-32
    800064e6:	ec06                	sd	ra,24(sp)
    800064e8:	e822                	sd	s0,16(sp)
    800064ea:	e426                	sd	s1,8(sp)
    800064ec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064ee:	00245497          	auipc	s1,0x245
    800064f2:	60248493          	addi	s1,s1,1538 # 8024baf0 <disk>
    800064f6:	00245517          	auipc	a0,0x245
    800064fa:	72250513          	addi	a0,a0,1826 # 8024bc18 <disk+0x128>
    800064fe:	fb0fa0ef          	jal	ra,80000cae <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006502:	10001737          	lui	a4,0x10001
    80006506:	533c                	lw	a5,96(a4)
    80006508:	8b8d                	andi	a5,a5,3
    8000650a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000650c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006510:	689c                	ld	a5,16(s1)
    80006512:	0204d703          	lhu	a4,32(s1)
    80006516:	0027d783          	lhu	a5,2(a5)
    8000651a:	04f70663          	beq	a4,a5,80006566 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000651e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006522:	6898                	ld	a4,16(s1)
    80006524:	0204d783          	lhu	a5,32(s1)
    80006528:	8b9d                	andi	a5,a5,7
    8000652a:	078e                	slli	a5,a5,0x3
    8000652c:	97ba                	add	a5,a5,a4
    8000652e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006530:	00278713          	addi	a4,a5,2
    80006534:	0712                	slli	a4,a4,0x4
    80006536:	9726                	add	a4,a4,s1
    80006538:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000653c:	e321                	bnez	a4,8000657c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000653e:	0789                	addi	a5,a5,2
    80006540:	0792                	slli	a5,a5,0x4
    80006542:	97a6                	add	a5,a5,s1
    80006544:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006546:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000654a:	f8bfb0ef          	jal	ra,800024d4 <wakeup>

    disk.used_idx += 1;
    8000654e:	0204d783          	lhu	a5,32(s1)
    80006552:	2785                	addiw	a5,a5,1
    80006554:	17c2                	slli	a5,a5,0x30
    80006556:	93c1                	srli	a5,a5,0x30
    80006558:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000655c:	6898                	ld	a4,16(s1)
    8000655e:	00275703          	lhu	a4,2(a4)
    80006562:	faf71ee3          	bne	a4,a5,8000651e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80006566:	00245517          	auipc	a0,0x245
    8000656a:	6b250513          	addi	a0,a0,1714 # 8024bc18 <disk+0x128>
    8000656e:	fd8fa0ef          	jal	ra,80000d46 <release>
}
    80006572:	60e2                	ld	ra,24(sp)
    80006574:	6442                	ld	s0,16(sp)
    80006576:	64a2                	ld	s1,8(sp)
    80006578:	6105                	addi	sp,sp,32
    8000657a:	8082                	ret
      panic("virtio_disk_intr status");
    8000657c:	00002517          	auipc	a0,0x2
    80006580:	2d450513          	addi	a0,a0,724 # 80008850 <syscalls+0x458>
    80006584:	a04fa0ef          	jal	ra,80000788 <panic>

0000000080006588 <shm_init>:



void
shm_init(void)
{
    80006588:	1141                	addi	sp,sp,-16
    8000658a:	e406                	sd	ra,8(sp)
    8000658c:	e022                	sd	s0,0(sp)
    8000658e:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    80006590:	00002597          	auipc	a1,0x2
    80006594:	2d858593          	addi	a1,a1,728 # 80008868 <syscalls+0x470>
    80006598:	00245517          	auipc	a0,0x245
    8000659c:	69850513          	addi	a0,a0,1688 # 8024bc30 <shmt>
    800065a0:	e8efa0ef          	jal	ra,80000c2e <initlock>
}
    800065a4:	60a2                	ld	ra,8(sp)
    800065a6:	6402                	ld	s0,0(sp)
    800065a8:	0141                	addi	sp,sp,16
    800065aa:	8082                	ret

00000000800065ac <shm_get>:

// 找到或创建 key 对应对象，返回 index；失败返回 -1
int
shm_get(int key, int npages)
{
    800065ac:	7179                	addi	sp,sp,-48
    800065ae:	f406                	sd	ra,40(sp)
    800065b0:	f022                	sd	s0,32(sp)
    800065b2:	ec26                	sd	s1,24(sp)
    800065b4:	e84a                	sd	s2,16(sp)
    800065b6:	e44e                	sd	s3,8(sp)
    800065b8:	1800                	addi	s0,sp,48
    800065ba:	892a                	mv	s2,a0
    800065bc:	89ae                	mv	s3,a1
  acquire(&shmt.lock);
    800065be:	00245517          	auipc	a0,0x245
    800065c2:	67250513          	addi	a0,a0,1650 # 8024bc30 <shmt>
    800065c6:	ee8fa0ef          	jal	ra,80000cae <acquire>

  // 先找已有
  for(int i=0;i<NSHM;i++){
    800065ca:	00245697          	auipc	a3,0x245
    800065ce:	67e68693          	addi	a3,a3,1662 # 8024bc48 <shmt+0x18>
  acquire(&shmt.lock);
    800065d2:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    800065d4:	4481                	li	s1,0
    800065d6:	6605                	lui	a2,0x1
    800065d8:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    800065dc:	4841                	li	a6,16
    800065de:	a015                	j	80006602 <shm_get+0x56>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
    800065e0:	00245517          	auipc	a0,0x245
    800065e4:	65050513          	addi	a0,a0,1616 # 8024bc30 <shmt>
    800065e8:	f5efa0ef          	jal	ra,80000d46 <release>
        return -1;
    800065ec:	54fd                	li	s1,-1
    800065ee:	a879                	j	8000668c <shm_get+0xe0>
      }
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    800065f0:	853a                	mv	a0,a4
    800065f2:	f54fa0ef          	jal	ra,80000d46 <release>
        return -1;
    800065f6:	54fd                	li	s1,-1
    800065f8:	a851                	j	8000668c <shm_get+0xe0>
  for(int i=0;i<NSHM;i++){
    800065fa:	2485                	addiw	s1,s1,1
    800065fc:	97b2                	add	a5,a5,a2
    800065fe:	07048563          	beq	s1,a6,80006668 <shm_get+0xbc>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006602:	4398                	lw	a4,0(a5)
    80006604:	db7d                	beqz	a4,800065fa <shm_get+0x4e>
    80006606:	43d8                	lw	a4,4(a5)
    80006608:	ff2719e3          	bne	a4,s2,800065fa <shm_get+0x4e>
      if(shmt.obj[i].deleted){
    8000660c:	6785                	lui	a5,0x1
    8000660e:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006612:	02d486b3          	mul	a3,s1,a3
    80006616:	00245717          	auipc	a4,0x245
    8000661a:	61a70713          	addi	a4,a4,1562 # 8024bc30 <shmt>
    8000661e:	9736                	add	a4,a4,a3
    80006620:	97ba                	add	a5,a5,a4
    80006622:	82c7a783          	lw	a5,-2004(a5)
    80006626:	ffcd                	bnez	a5,800065e0 <shm_get+0x34>
      if(npages > shmt.obj[i].npages){
    80006628:	6785                	lui	a5,0x1
    8000662a:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000662e:	02f487b3          	mul	a5,s1,a5
    80006632:	00245717          	auipc	a4,0x245
    80006636:	5fe70713          	addi	a4,a4,1534 # 8024bc30 <shmt>
    8000663a:	97ba                	add	a5,a5,a4
    8000663c:	539c                	lw	a5,32(a5)
    8000663e:	fb37c9e3          	blt	a5,s3,800065f0 <shm_get+0x44>
      }
      shmt.obj[i].refcnt++;
    80006642:	00245517          	auipc	a0,0x245
    80006646:	5ee50513          	addi	a0,a0,1518 # 8024bc30 <shmt>
    8000664a:	6785                	lui	a5,0x1
    8000664c:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006650:	02e48733          	mul	a4,s1,a4
    80006654:	972a                	add	a4,a4,a0
    80006656:	97ba                	add	a5,a5,a4
    80006658:	8287a703          	lw	a4,-2008(a5)
    8000665c:	2705                	addiw	a4,a4,1
    8000665e:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    80006662:	ee4fa0ef          	jal	ra,80000d46 <release>
      return i;
    80006666:	a01d                	j	8000668c <shm_get+0xe0>
    }
  }

  // 再创建
  for(int i=0;i<NSHM;i++){
    80006668:	4481                	li	s1,0
    8000666a:	6705                	lui	a4,0x1
    8000666c:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006670:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    80006672:	429c                	lw	a5,0(a3)
    80006674:	c785                	beqz	a5,8000669c <shm_get+0xf0>
  for(int i=0;i<NSHM;i++){
    80006676:	2485                	addiw	s1,s1,1
    80006678:	96ba                	add	a3,a3,a4
    8000667a:	fec49ce3          	bne	s1,a2,80006672 <shm_get+0xc6>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    8000667e:	00245517          	auipc	a0,0x245
    80006682:	5b250513          	addi	a0,a0,1458 # 8024bc30 <shmt>
    80006686:	ec0fa0ef          	jal	ra,80000d46 <release>
  return -1;
    8000668a:	54fd                	li	s1,-1
}
    8000668c:	8526                	mv	a0,s1
    8000668e:	70a2                	ld	ra,40(sp)
    80006690:	7402                	ld	s0,32(sp)
    80006692:	64e2                	ld	s1,24(sp)
    80006694:	6942                	ld	s2,16(sp)
    80006696:	69a2                	ld	s3,8(sp)
    80006698:	6145                	addi	sp,sp,48
    8000669a:	8082                	ret
      shmt.obj[i].deleted = 0;
    8000669c:	00245617          	auipc	a2,0x245
    800066a0:	59460613          	addi	a2,a2,1428 # 8024bc30 <shmt>
    800066a4:	6785                	lui	a5,0x1
    800066a6:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800066aa:	02d486b3          	mul	a3,s1,a3
    800066ae:	00d60733          	add	a4,a2,a3
    800066b2:	97ba                	add	a5,a5,a4
    800066b4:	8207a623          	sw	zero,-2004(a5)
      shmt.obj[i].used = 1;
    800066b8:	4585                	li	a1,1
    800066ba:	cf0c                	sw	a1,24(a4)
      shmt.obj[i].key = key;
    800066bc:	01272e23          	sw	s2,28(a4)
      shmt.obj[i].npages = npages;
    800066c0:	03372023          	sw	s3,32(a4)
      shmt.obj[i].refcnt = 1;
    800066c4:	82b7a423          	sw	a1,-2008(a5)
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
    800066c8:	02868793          	addi	a5,a3,40
    800066cc:	97b2                	add	a5,a5,a2
    800066ce:	00246717          	auipc	a4,0x246
    800066d2:	d8a70713          	addi	a4,a4,-630 # 8024c458 <shmt+0x828>
    800066d6:	9736                	add	a4,a4,a3
    800066d8:	0007b023          	sd	zero,0(a5)
    800066dc:	07a1                	addi	a5,a5,8
    800066de:	fee79de3          	bne	a5,a4,800066d8 <shm_get+0x12c>
      release(&shmt.lock);
    800066e2:	00245517          	auipc	a0,0x245
    800066e6:	54e50513          	addi	a0,a0,1358 # 8024bc30 <shmt>
    800066ea:	e5cfa0ef          	jal	ra,80000d46 <release>
      return i;
    800066ee:	bf79                	j	8000668c <shm_get+0xe0>

00000000800066f0 <shm_put>:


// refcnt--，若为 0 则释放对象里的所有页（kfree 会走页 refcnt，安全）
void
shm_put(int key)
{
    800066f0:	7179                	addi	sp,sp,-48
    800066f2:	f406                	sd	ra,40(sp)
    800066f4:	f022                	sd	s0,32(sp)
    800066f6:	ec26                	sd	s1,24(sp)
    800066f8:	e84a                	sd	s2,16(sp)
    800066fa:	e44e                	sd	s3,8(sp)
    800066fc:	e052                	sd	s4,0(sp)
    800066fe:	1800                	addi	s0,sp,48
    80006700:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    80006702:	00245517          	auipc	a0,0x245
    80006706:	52e50513          	addi	a0,a0,1326 # 8024bc30 <shmt>
    8000670a:	da4fa0ef          	jal	ra,80000cae <acquire>
  for(int i=0;i<NSHM;i++){
    8000670e:	00245797          	auipc	a5,0x245
    80006712:	53a78793          	addi	a5,a5,1338 # 8024bc48 <shmt+0x18>
    80006716:	4481                	li	s1,0
    80006718:	6685                	lui	a3,0x1
    8000671a:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000671e:	4641                	li	a2,16
    80006720:	a0b5                	j	8000678c <shm_put+0x9c>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
    80006722:	00002517          	auipc	a0,0x2
    80006726:	14e50513          	addi	a0,a0,334 # 80008870 <syscalls+0x478>
    8000672a:	85efa0ef          	jal	ra,80000788 <panic>
      shmt.obj[i].refcnt--;
      if(shmt.obj[i].refcnt == 0){
        for(int j=0;j<shmt.obj[i].npages;j++){
    8000672e:	2985                	addiw	s3,s3,1
    80006730:	0921                	addi	s2,s2,8
    80006732:	020a2783          	lw	a5,32(s4)
    80006736:	00f9da63          	bge	s3,a5,8000674a <shm_put+0x5a>
          if(shmt.obj[i].pa[j]){
    8000673a:	00093503          	ld	a0,0(s2)
    8000673e:	d965                	beqz	a0,8000672e <shm_put+0x3e>
            kfree((void*)shmt.obj[i].pa[j]);
    80006740:	b3afa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    80006744:	00093023          	sd	zero,0(s2)
    80006748:	b7dd                	j	8000672e <shm_put+0x3e>
          }
        }
        shmt.obj[i].used = 0;
    8000674a:	6785                	lui	a5,0x1
    8000674c:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006750:	02e484b3          	mul	s1,s1,a4
    80006754:	00245717          	auipc	a4,0x245
    80006758:	4dc70713          	addi	a4,a4,1244 # 8024bc30 <shmt>
    8000675c:	9726                	add	a4,a4,s1
    8000675e:	00072c23          	sw	zero,24(a4)
        shmt.obj[i].deleted = 0;
    80006762:	97ba                	add	a5,a5,a4
    80006764:	8207a623          	sw	zero,-2004(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    80006768:	00245517          	auipc	a0,0x245
    8000676c:	4c850513          	addi	a0,a0,1224 # 8024bc30 <shmt>
    80006770:	dd6fa0ef          	jal	ra,80000d46 <release>
}
    80006774:	70a2                	ld	ra,40(sp)
    80006776:	7402                	ld	s0,32(sp)
    80006778:	64e2                	ld	s1,24(sp)
    8000677a:	6942                	ld	s2,16(sp)
    8000677c:	69a2                	ld	s3,8(sp)
    8000677e:	6a02                	ld	s4,0(sp)
    80006780:	6145                	addi	sp,sp,48
    80006782:	8082                	ret
  for(int i=0;i<NSHM;i++){
    80006784:	2485                	addiw	s1,s1,1
    80006786:	97b6                	add	a5,a5,a3
    80006788:	fec480e3          	beq	s1,a2,80006768 <shm_put+0x78>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000678c:	4398                	lw	a4,0(a5)
    8000678e:	db7d                	beqz	a4,80006784 <shm_put+0x94>
    80006790:	43d8                	lw	a4,4(a5)
    80006792:	ff2719e3          	bne	a4,s2,80006784 <shm_put+0x94>
      if(shmt.obj[i].refcnt < 1)
    80006796:	6785                	lui	a5,0x1
    80006798:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000679c:	02d486b3          	mul	a3,s1,a3
    800067a0:	00245717          	auipc	a4,0x245
    800067a4:	49070713          	addi	a4,a4,1168 # 8024bc30 <shmt>
    800067a8:	9736                	add	a4,a4,a3
    800067aa:	97ba                	add	a5,a5,a4
    800067ac:	8287a783          	lw	a5,-2008(a5)
    800067b0:	f6f059e3          	blez	a5,80006722 <shm_put+0x32>
      shmt.obj[i].refcnt--;
    800067b4:	37fd                	addiw	a5,a5,-1
    800067b6:	0007899b          	sext.w	s3,a5
    800067ba:	6705                	lui	a4,0x1
    800067bc:	81870613          	addi	a2,a4,-2024 # 818 <_entry-0x7ffff7e8>
    800067c0:	02c48633          	mul	a2,s1,a2
    800067c4:	00245697          	auipc	a3,0x245
    800067c8:	46c68693          	addi	a3,a3,1132 # 8024bc30 <shmt>
    800067cc:	96b2                	add	a3,a3,a2
    800067ce:	9736                	add	a4,a4,a3
    800067d0:	82f72423          	sw	a5,-2008(a4)
      if(shmt.obj[i].refcnt == 0){
    800067d4:	f8099ae3          	bnez	s3,80006768 <shm_put+0x78>
        for(int j=0;j<shmt.obj[i].npages;j++){
    800067d8:	529c                	lw	a5,32(a3)
    800067da:	f6f058e3          	blez	a5,8000674a <shm_put+0x5a>
    800067de:	00245797          	auipc	a5,0x245
    800067e2:	47a78793          	addi	a5,a5,1146 # 8024bc58 <shmt+0x28>
    800067e6:	00f60933          	add	s2,a2,a5
    800067ea:	8a36                	mv	s4,a3
    800067ec:	b7b9                	j	8000673a <shm_put+0x4a>

00000000800067ee <shm_getpa>:

// 取某页的 pa；若未分配则分配（lazy），返回 pa 或 0
uint64
shm_getpa(int key, int page_index)
{
    800067ee:	7179                	addi	sp,sp,-48
    800067f0:	f406                	sd	ra,40(sp)
    800067f2:	f022                	sd	s0,32(sp)
    800067f4:	ec26                	sd	s1,24(sp)
    800067f6:	e84a                	sd	s2,16(sp)
    800067f8:	e44e                	sd	s3,8(sp)
    800067fa:	e052                	sd	s4,0(sp)
    800067fc:	1800                	addi	s0,sp,48
    800067fe:	892a                	mv	s2,a0
    80006800:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    80006802:	00245517          	auipc	a0,0x245
    80006806:	42e50513          	addi	a0,a0,1070 # 8024bc30 <shmt>
    8000680a:	ca4fa0ef          	jal	ra,80000cae <acquire>

  for(int i=0;i<NSHM;i++){
    8000680e:	00245797          	auipc	a5,0x245
    80006812:	43a78793          	addi	a5,a5,1082 # 8024bc48 <shmt+0x18>
    80006816:	4481                	li	s1,0
    80006818:	6685                	lui	a3,0x1
    8000681a:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000681e:	4641                	li	a2,16
    80006820:	a82d                	j	8000685a <shm_getpa+0x6c>
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
        pa = 0;
        break;
      }
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    80006822:	b88fa0ef          	jal	ra,80000baa <kalloc>
    80006826:	8a2a                	mv	s4,a0
        if(mem == 0){
    80006828:	cd41                	beqz	a0,800068c0 <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        memset(mem, 0, PGSIZE);
    8000682a:	6605                	lui	a2,0x1
    8000682c:	4581                	li	a1,0
    8000682e:	d54fa0ef          	jal	ra,80000d82 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    80006832:	00649793          	slli	a5,s1,0x6
    80006836:	97a6                	add	a5,a5,s1
    80006838:	078a                	slli	a5,a5,0x2
    8000683a:	8f85                	sub	a5,a5,s1
    8000683c:	97ce                	add	a5,a5,s3
    8000683e:	0791                	addi	a5,a5,4
    80006840:	078e                	slli	a5,a5,0x3
    80006842:	00245717          	auipc	a4,0x245
    80006846:	3ee70713          	addi	a4,a4,1006 # 8024bc30 <shmt>
    8000684a:	97ba                	add	a5,a5,a4
    8000684c:	0147b423          	sd	s4,8(a5)
    80006850:	a0b9                	j	8000689e <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    80006852:	2485                	addiw	s1,s1,1
    80006854:	97b6                	add	a5,a5,a3
    80006856:	06c48463          	beq	s1,a2,800068be <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000685a:	4398                	lw	a4,0(a5)
    8000685c:	db7d                	beqz	a4,80006852 <shm_getpa+0x64>
    8000685e:	43d8                	lw	a4,4(a5)
    80006860:	ff2719e3          	bne	a4,s2,80006852 <shm_getpa+0x64>
        pa = 0;
    80006864:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    80006866:	0409cd63          	bltz	s3,800068c0 <shm_getpa+0xd2>
    8000686a:	6785                	lui	a5,0x1
    8000686c:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006870:	02f487b3          	mul	a5,s1,a5
    80006874:	00245717          	auipc	a4,0x245
    80006878:	3bc70713          	addi	a4,a4,956 # 8024bc30 <shmt>
    8000687c:	97ba                	add	a5,a5,a4
    8000687e:	539c                	lw	a5,32(a5)
    80006880:	04f9d063          	bge	s3,a5,800068c0 <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    80006884:	00649793          	slli	a5,s1,0x6
    80006888:	97a6                	add	a5,a5,s1
    8000688a:	078a                	slli	a5,a5,0x2
    8000688c:	8f85                	sub	a5,a5,s1
    8000688e:	97ce                	add	a5,a5,s3
    80006890:	0791                	addi	a5,a5,4
    80006892:	078e                	slli	a5,a5,0x3
    80006894:	97ba                	add	a5,a5,a4
    80006896:	0087b903          	ld	s2,8(a5)
    8000689a:	f80904e3          	beqz	s2,80006822 <shm_getpa+0x34>
      }
      pa = shmt.obj[i].pa[page_index];
    8000689e:	00649793          	slli	a5,s1,0x6
    800068a2:	97a6                	add	a5,a5,s1
    800068a4:	078a                	slli	a5,a5,0x2
    800068a6:	8f85                	sub	a5,a5,s1
    800068a8:	97ce                	add	a5,a5,s3
    800068aa:	0791                	addi	a5,a5,4
    800068ac:	078e                	slli	a5,a5,0x3
    800068ae:	00245717          	auipc	a4,0x245
    800068b2:	38270713          	addi	a4,a4,898 # 8024bc30 <shmt>
    800068b6:	97ba                	add	a5,a5,a4
    800068b8:	0087b903          	ld	s2,8(a5)
      break;
    800068bc:	a011                	j	800068c0 <shm_getpa+0xd2>
  uint64 pa = 0;
    800068be:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    800068c0:	00245517          	auipc	a0,0x245
    800068c4:	37050513          	addi	a0,a0,880 # 8024bc30 <shmt>
    800068c8:	c7efa0ef          	jal	ra,80000d46 <release>
  vmstats_inc_shm();
    800068cc:	4e2000ef          	jal	ra,80006dae <vmstats_inc_shm>

  return pa;
}
    800068d0:	854a                	mv	a0,s2
    800068d2:	70a2                	ld	ra,40(sp)
    800068d4:	7402                	ld	s0,32(sp)
    800068d6:	64e2                	ld	s1,24(sp)
    800068d8:	6942                	ld	s2,16(sp)
    800068da:	69a2                	ld	s3,8(sp)
    800068dc:	6a02                	ld	s4,0(sp)
    800068de:	6145                	addi	sp,sp,48
    800068e0:	8082                	ret

00000000800068e2 <shm_ctl>:


int
shm_ctl(int key, int cmd)
{
  if(cmd != IPC_RMID)
    800068e2:	10059363          	bnez	a1,800069e8 <shm_ctl+0x106>
{
    800068e6:	7139                	addi	sp,sp,-64
    800068e8:	fc06                	sd	ra,56(sp)
    800068ea:	f822                	sd	s0,48(sp)
    800068ec:	f426                	sd	s1,40(sp)
    800068ee:	f04a                	sd	s2,32(sp)
    800068f0:	ec4e                	sd	s3,24(sp)
    800068f2:	e852                	sd	s4,16(sp)
    800068f4:	e456                	sd	s5,8(sp)
    800068f6:	0080                	addi	s0,sp,64
    800068f8:	892a                	mv	s2,a0
    800068fa:	89ae                	mv	s3,a1
    return -1;

  acquire(&shmt.lock);
    800068fc:	00245517          	auipc	a0,0x245
    80006900:	33450513          	addi	a0,a0,820 # 8024bc30 <shmt>
    80006904:	baafa0ef          	jal	ra,80000cae <acquire>

  for(int i = 0; i < NSHM; i++){
    80006908:	00245797          	auipc	a5,0x245
    8000690c:	34078793          	addi	a5,a5,832 # 8024bc48 <shmt+0x18>
    80006910:	84ce                	mv	s1,s3
    80006912:	6685                	lui	a3,0x1
    80006914:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006918:	4641                	li	a2,16
    8000691a:	a8b1                	j	80006976 <shm_ctl+0x94>

      // 如果没人引用了，立刻释放
      if(shmt.obj[i].refcnt == 0){
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
    8000691c:	95efa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    80006920:	00093023          	sd	zero,0(s2)
        for(int j = 0; j < shmt.obj[i].npages; j++){
    80006924:	2a05                	addiw	s4,s4,1
    80006926:	0921                	addi	s2,s2,8
    80006928:	020aa783          	lw	a5,32(s5)
    8000692c:	00fa5663          	bge	s4,a5,80006938 <shm_ctl+0x56>
          if(shmt.obj[i].pa[j]){
    80006930:	00093503          	ld	a0,0(s2)
    80006934:	d965                	beqz	a0,80006924 <shm_ctl+0x42>
    80006936:	b7dd                	j	8000691c <shm_ctl+0x3a>
          }
        }
        shmt.obj[i].used = 0;
    80006938:	6705                	lui	a4,0x1
    8000693a:	81870793          	addi	a5,a4,-2024 # 818 <_entry-0x7ffff7e8>
    8000693e:	02f484b3          	mul	s1,s1,a5
    80006942:	00245797          	auipc	a5,0x245
    80006946:	2ee78793          	addi	a5,a5,750 # 8024bc30 <shmt>
    8000694a:	97a6                	add	a5,a5,s1
    8000694c:	0007ac23          	sw	zero,24(a5)
        shmt.obj[i].deleted = 0;
    80006950:	973e                	add	a4,a4,a5
    80006952:	82072623          	sw	zero,-2004(a4)
        shmt.obj[i].key = 0;     
    80006956:	0007ae23          	sw	zero,28(a5)
        shmt.obj[i].npages = 0;  
    8000695a:	0207a023          	sw	zero,32(a5)

      }


      release(&shmt.lock);
    8000695e:	00245517          	auipc	a0,0x245
    80006962:	2d250513          	addi	a0,a0,722 # 8024bc30 <shmt>
    80006966:	be0fa0ef          	jal	ra,80000d46 <release>
      return 0;
    8000696a:	854e                	mv	a0,s3
    8000696c:	a0ad                	j	800069d6 <shm_ctl+0xf4>
  for(int i = 0; i < NSHM; i++){
    8000696e:	2485                	addiw	s1,s1,1
    80006970:	97b6                	add	a5,a5,a3
    80006972:	04c48b63          	beq	s1,a2,800069c8 <shm_ctl+0xe6>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006976:	4398                	lw	a4,0(a5)
    80006978:	db7d                	beqz	a4,8000696e <shm_ctl+0x8c>
    8000697a:	43d8                	lw	a4,4(a5)
    8000697c:	ff2719e3          	bne	a4,s2,8000696e <shm_ctl+0x8c>
      shmt.obj[i].deleted = 1;
    80006980:	6785                	lui	a5,0x1
    80006982:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006986:	02d486b3          	mul	a3,s1,a3
    8000698a:	00245717          	auipc	a4,0x245
    8000698e:	2a670713          	addi	a4,a4,678 # 8024bc30 <shmt>
    80006992:	9736                	add	a4,a4,a3
    80006994:	97ba                	add	a5,a5,a4
    80006996:	4705                	li	a4,1
    80006998:	82e7a623          	sw	a4,-2004(a5)
      if(shmt.obj[i].refcnt == 0){
    8000699c:	8287aa03          	lw	s4,-2008(a5)
    800069a0:	fa0a1fe3          	bnez	s4,8000695e <shm_ctl+0x7c>
        for(int j = 0; j < shmt.obj[i].npages; j++){
    800069a4:	00245717          	auipc	a4,0x245
    800069a8:	28c70713          	addi	a4,a4,652 # 8024bc30 <shmt>
    800069ac:	00d707b3          	add	a5,a4,a3
    800069b0:	539c                	lw	a5,32(a5)
    800069b2:	f8f053e3          	blez	a5,80006938 <shm_ctl+0x56>
    800069b6:	00245797          	auipc	a5,0x245
    800069ba:	2a278793          	addi	a5,a5,674 # 8024bc58 <shmt+0x28>
    800069be:	00f68933          	add	s2,a3,a5
    800069c2:	00d70ab3          	add	s5,a4,a3
    800069c6:	b7ad                	j	80006930 <shm_ctl+0x4e>
    }
  }

  release(&shmt.lock);
    800069c8:	00245517          	auipc	a0,0x245
    800069cc:	26850513          	addi	a0,a0,616 # 8024bc30 <shmt>
    800069d0:	b76fa0ef          	jal	ra,80000d46 <release>
  return -1; // key 不存在
    800069d4:	557d                	li	a0,-1
}
    800069d6:	70e2                	ld	ra,56(sp)
    800069d8:	7442                	ld	s0,48(sp)
    800069da:	74a2                	ld	s1,40(sp)
    800069dc:	7902                	ld	s2,32(sp)
    800069de:	69e2                	ld	s3,24(sp)
    800069e0:	6a42                	ld	s4,16(sp)
    800069e2:	6aa2                	ld	s5,8(sp)
    800069e4:	6121                	addi	sp,sp,64
    800069e6:	8082                	ret
    return -1;
    800069e8:	557d                	li	a0,-1
}
    800069ea:	8082                	ret

00000000800069ec <shm_is_deleted>:

int
shm_is_deleted(int key)
{
    800069ec:	1101                	addi	sp,sp,-32
    800069ee:	ec06                	sd	ra,24(sp)
    800069f0:	e822                	sd	s0,16(sp)
    800069f2:	e426                	sd	s1,8(sp)
    800069f4:	1000                	addi	s0,sp,32
    800069f6:	84aa                	mv	s1,a0
  int del = 0; // 默认0,不存在就允许创建
  acquire(&shmt.lock);
    800069f8:	00245517          	auipc	a0,0x245
    800069fc:	23850513          	addi	a0,a0,568 # 8024bc30 <shmt>
    80006a00:	aaefa0ef          	jal	ra,80000cae <acquire>
  for(int i=0;i<NSHM;i++){
    80006a04:	00245797          	auipc	a5,0x245
    80006a08:	24478793          	addi	a5,a5,580 # 8024bc48 <shmt+0x18>
    80006a0c:	4701                	li	a4,0
    80006a0e:	6605                	lui	a2,0x1
    80006a10:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006a14:	45c1                	li	a1,16
    80006a16:	a029                	j	80006a20 <shm_is_deleted+0x34>
    80006a18:	2705                	addiw	a4,a4,1
    80006a1a:	97b2                	add	a5,a5,a2
    80006a1c:	02b70563          	beq	a4,a1,80006a46 <shm_is_deleted+0x5a>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006a20:	4394                	lw	a3,0(a5)
    80006a22:	dafd                	beqz	a3,80006a18 <shm_is_deleted+0x2c>
    80006a24:	43d4                	lw	a3,4(a5)
    80006a26:	fe9699e3          	bne	a3,s1,80006a18 <shm_is_deleted+0x2c>
      del = shmt.obj[i].deleted;
    80006a2a:	6785                	lui	a5,0x1
    80006a2c:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006a30:	02d70733          	mul	a4,a4,a3
    80006a34:	00245697          	auipc	a3,0x245
    80006a38:	1fc68693          	addi	a3,a3,508 # 8024bc30 <shmt>
    80006a3c:	9736                	add	a4,a4,a3
    80006a3e:	97ba                	add	a5,a5,a4
    80006a40:	82c7a483          	lw	s1,-2004(a5)
      break;
    80006a44:	a011                	j	80006a48 <shm_is_deleted+0x5c>
  int del = 0; // 默认0,不存在就允许创建
    80006a46:	4481                	li	s1,0
    }
  }
  release(&shmt.lock);
    80006a48:	00245517          	auipc	a0,0x245
    80006a4c:	1e850513          	addi	a0,a0,488 # 8024bc30 <shmt>
    80006a50:	af6fa0ef          	jal	ra,80000d46 <release>
  //shm_dump(key);
  return del;

}
    80006a54:	8526                	mv	a0,s1
    80006a56:	60e2                	ld	ra,24(sp)
    80006a58:	6442                	ld	s0,16(sp)
    80006a5a:	64a2                	ld	s1,8(sp)
    80006a5c:	6105                	addi	sp,sp,32
    80006a5e:	8082                	ret

0000000080006a60 <sem_lookup>:
}

// 找到 key 对应 sem；不存在返回 -1
static int
sem_lookup(int key)
{
    80006a60:	1141                	addi	sp,sp,-16
    80006a62:	e422                	sd	s0,8(sp)
    80006a64:	0800                	addi	s0,sp,16
    80006a66:	862a                	mv	a2,a0
  for(int i = 0; i < NSEM; i++){
    80006a68:	0024d797          	auipc	a5,0x24d
    80006a6c:	37878793          	addi	a5,a5,888 # 80253de0 <semt+0x18>
    80006a70:	4501                	li	a0,0
    80006a72:	04000693          	li	a3,64
    80006a76:	a029                	j	80006a80 <sem_lookup+0x20>
    80006a78:	2505                	addiw	a0,a0,1
    80006a7a:	07c1                	addi	a5,a5,16
    80006a7c:	00d50a63          	beq	a0,a3,80006a90 <sem_lookup+0x30>
    if(semt.s[i].used && semt.s[i].key == key)
    80006a80:	4398                	lw	a4,0(a5)
    80006a82:	db7d                	beqz	a4,80006a78 <sem_lookup+0x18>
    80006a84:	43d8                	lw	a4,4(a5)
    80006a86:	fec719e3          	bne	a4,a2,80006a78 <sem_lookup+0x18>
      return i;
  }
  return -1;
}
    80006a8a:	6422                	ld	s0,8(sp)
    80006a8c:	0141                	addi	sp,sp,16
    80006a8e:	8082                	ret
  return -1;
    80006a90:	557d                	li	a0,-1
    80006a92:	bfe5                	j	80006a8a <sem_lookup+0x2a>

0000000080006a94 <seminit>:
{
    80006a94:	1141                	addi	sp,sp,-16
    80006a96:	e406                	sd	ra,8(sp)
    80006a98:	e022                	sd	s0,0(sp)
    80006a9a:	0800                	addi	s0,sp,16
  initlock(&semt.lock, "semt");
    80006a9c:	00002597          	auipc	a1,0x2
    80006aa0:	de458593          	addi	a1,a1,-540 # 80008880 <syscalls+0x488>
    80006aa4:	0024d517          	auipc	a0,0x24d
    80006aa8:	32450513          	addi	a0,a0,804 # 80253dc8 <semt>
    80006aac:	982fa0ef          	jal	ra,80000c2e <initlock>
}
    80006ab0:	60a2                	ld	ra,8(sp)
    80006ab2:	6402                	ld	s0,0(sp)
    80006ab4:	0141                	addi	sp,sp,16
    80006ab6:	8082                	ret

0000000080006ab8 <sem_open>:

// 创建或返回已有
int
sem_open(int key, int init)
{
    80006ab8:	7179                	addi	sp,sp,-48
    80006aba:	f406                	sd	ra,40(sp)
    80006abc:	f022                	sd	s0,32(sp)
    80006abe:	ec26                	sd	s1,24(sp)
    80006ac0:	e84a                	sd	s2,16(sp)
    80006ac2:	e44e                	sd	s3,8(sp)
    80006ac4:	1800                	addi	s0,sp,48
    80006ac6:	892a                	mv	s2,a0
    80006ac8:	89ae                	mv	s3,a1
  acquire(&semt.lock);
    80006aca:	0024d517          	auipc	a0,0x24d
    80006ace:	2fe50513          	addi	a0,a0,766 # 80253dc8 <semt>
    80006ad2:	9dcfa0ef          	jal	ra,80000cae <acquire>

  int idx = sem_lookup(key);
    80006ad6:	854a                	mv	a0,s2
    80006ad8:	f89ff0ef          	jal	ra,80006a60 <sem_lookup>
  if(idx >= 0){
    80006adc:	0024d717          	auipc	a4,0x24d
    80006ae0:	30470713          	addi	a4,a4,772 # 80253de0 <semt+0x18>
    release(&semt.lock);
    return 0;  // 已存在，直接成功
  }

  for(int i = 0; i < NSEM; i++){
    80006ae4:	4781                	li	a5,0
    80006ae6:	04000693          	li	a3,64
  if(idx >= 0){
    80006aea:	02055063          	bgez	a0,80006b0a <sem_open+0x52>
    if(!semt.s[i].used){
    80006aee:	4304                	lw	s1,0(a4)
    80006af0:	c48d                	beqz	s1,80006b1a <sem_open+0x62>
  for(int i = 0; i < NSEM; i++){
    80006af2:	2785                	addiw	a5,a5,1
    80006af4:	0741                	addi	a4,a4,16
    80006af6:	fed79ce3          	bne	a5,a3,80006aee <sem_open+0x36>
      release(&semt.lock);
      return 0;
    }
  }

  release(&semt.lock);
    80006afa:	0024d517          	auipc	a0,0x24d
    80006afe:	2ce50513          	addi	a0,a0,718 # 80253dc8 <semt>
    80006b02:	a44fa0ef          	jal	ra,80000d46 <release>
  return -1;
    80006b06:	54fd                	li	s1,-1
    80006b08:	a815                	j	80006b3c <sem_open+0x84>
    release(&semt.lock);
    80006b0a:	0024d517          	auipc	a0,0x24d
    80006b0e:	2be50513          	addi	a0,a0,702 # 80253dc8 <semt>
    80006b12:	a34fa0ef          	jal	ra,80000d46 <release>
    return 0;  // 已存在，直接成功
    80006b16:	4481                	li	s1,0
    80006b18:	a015                	j	80006b3c <sem_open+0x84>
      semt.s[i].used = 1;
    80006b1a:	0024d517          	auipc	a0,0x24d
    80006b1e:	2ae50513          	addi	a0,a0,686 # 80253dc8 <semt>
    80006b22:	0785                	addi	a5,a5,1
    80006b24:	0792                	slli	a5,a5,0x4
    80006b26:	97aa                	add	a5,a5,a0
    80006b28:	4705                	li	a4,1
    80006b2a:	c798                	sw	a4,8(a5)
      semt.s[i].key = key;
    80006b2c:	0127a623          	sw	s2,12(a5)
      semt.s[i].val = init;
    80006b30:	0137a823          	sw	s3,16(a5)
      semt.s[i].waiters = 0;
    80006b34:	0007aa23          	sw	zero,20(a5)
      release(&semt.lock);
    80006b38:	a0efa0ef          	jal	ra,80000d46 <release>
}
    80006b3c:	8526                	mv	a0,s1
    80006b3e:	70a2                	ld	ra,40(sp)
    80006b40:	7402                	ld	s0,32(sp)
    80006b42:	64e2                	ld	s1,24(sp)
    80006b44:	6942                	ld	s2,16(sp)
    80006b46:	69a2                	ld	s3,8(sp)
    80006b48:	6145                	addi	sp,sp,48
    80006b4a:	8082                	ret

0000000080006b4c <sem_wait>:

int
sem_wait(int key)
{
    80006b4c:	7179                	addi	sp,sp,-48
    80006b4e:	f406                	sd	ra,40(sp)
    80006b50:	f022                	sd	s0,32(sp)
    80006b52:	ec26                	sd	s1,24(sp)
    80006b54:	e84a                	sd	s2,16(sp)
    80006b56:	e44e                	sd	s3,8(sp)
    80006b58:	e052                	sd	s4,0(sp)
    80006b5a:	1800                	addi	s0,sp,48
    80006b5c:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006b5e:	0024d517          	auipc	a0,0x24d
    80006b62:	26a50513          	addi	a0,a0,618 # 80253dc8 <semt>
    80006b66:	948fa0ef          	jal	ra,80000cae <acquire>

  int idx = sem_lookup(key);
    80006b6a:	8526                	mv	a0,s1
    80006b6c:	ef5ff0ef          	jal	ra,80006a60 <sem_lookup>
  if(idx < 0){
    80006b70:	06054d63          	bltz	a0,80006bea <sem_wait+0x9e>
    80006b74:	892a                	mv	s2,a0
    release(&semt.lock);
    return -1;
  }

  // while(val==0) sleep
  while(semt.s[idx].val == 0){
    80006b76:	00150713          	addi	a4,a0,1
    80006b7a:	0712                	slli	a4,a4,0x4
    80006b7c:	0024d797          	auipc	a5,0x24d
    80006b80:	24c78793          	addi	a5,a5,588 # 80253dc8 <semt>
    80006b84:	97ba                	add	a5,a5,a4
    80006b86:	4b9c                	lw	a5,16(a5)
    80006b88:	ef85                	bnez	a5,80006bc0 <sem_wait+0x74>
    semt.s[idx].waiters++;
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006b8a:	00451993          	slli	s3,a0,0x4
    80006b8e:	0024d797          	auipc	a5,0x24d
    80006b92:	25278793          	addi	a5,a5,594 # 80253de0 <semt+0x18>
    80006b96:	99be                	add	s3,s3,a5
    semt.s[idx].waiters++;
    80006b98:	0024da17          	auipc	s4,0x24d
    80006b9c:	230a0a13          	addi	s4,s4,560 # 80253dc8 <semt>
    80006ba0:	00150493          	addi	s1,a0,1
    80006ba4:	0492                	slli	s1,s1,0x4
    80006ba6:	94d2                	add	s1,s1,s4
    80006ba8:	48dc                	lw	a5,20(s1)
    80006baa:	2785                	addiw	a5,a5,1
    80006bac:	c8dc                	sw	a5,20(s1)
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006bae:	85d2                	mv	a1,s4
    80006bb0:	854e                	mv	a0,s3
    80006bb2:	8d7fb0ef          	jal	ra,80002488 <sleep>
    semt.s[idx].waiters--;
    80006bb6:	48dc                	lw	a5,20(s1)
    80006bb8:	37fd                	addiw	a5,a5,-1
    80006bba:	c8dc                	sw	a5,20(s1)
  while(semt.s[idx].val == 0){
    80006bbc:	489c                	lw	a5,16(s1)
    80006bbe:	d7ed                	beqz	a5,80006ba8 <sem_wait+0x5c>
  }

  semt.s[idx].val--;
    80006bc0:	0024d517          	auipc	a0,0x24d
    80006bc4:	20850513          	addi	a0,a0,520 # 80253dc8 <semt>
    80006bc8:	0905                	addi	s2,s2,1
    80006bca:	0912                	slli	s2,s2,0x4
    80006bcc:	992a                	add	s2,s2,a0
    80006bce:	37fd                	addiw	a5,a5,-1
    80006bd0:	00f92823          	sw	a5,16(s2)
  release(&semt.lock);
    80006bd4:	972fa0ef          	jal	ra,80000d46 <release>
  return 0;
    80006bd8:	4501                	li	a0,0
}
    80006bda:	70a2                	ld	ra,40(sp)
    80006bdc:	7402                	ld	s0,32(sp)
    80006bde:	64e2                	ld	s1,24(sp)
    80006be0:	6942                	ld	s2,16(sp)
    80006be2:	69a2                	ld	s3,8(sp)
    80006be4:	6a02                	ld	s4,0(sp)
    80006be6:	6145                	addi	sp,sp,48
    80006be8:	8082                	ret
    release(&semt.lock);
    80006bea:	0024d517          	auipc	a0,0x24d
    80006bee:	1de50513          	addi	a0,a0,478 # 80253dc8 <semt>
    80006bf2:	954fa0ef          	jal	ra,80000d46 <release>
    return -1;
    80006bf6:	557d                	li	a0,-1
    80006bf8:	b7cd                	j	80006bda <sem_wait+0x8e>

0000000080006bfa <sem_post>:

int
sem_post(int key)
{
    80006bfa:	1101                	addi	sp,sp,-32
    80006bfc:	ec06                	sd	ra,24(sp)
    80006bfe:	e822                	sd	s0,16(sp)
    80006c00:	e426                	sd	s1,8(sp)
    80006c02:	1000                	addi	s0,sp,32
    80006c04:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006c06:	0024d517          	auipc	a0,0x24d
    80006c0a:	1c250513          	addi	a0,a0,450 # 80253dc8 <semt>
    80006c0e:	8a0fa0ef          	jal	ra,80000cae <acquire>

  int idx = sem_lookup(key);
    80006c12:	8526                	mv	a0,s1
    80006c14:	e4dff0ef          	jal	ra,80006a60 <sem_lookup>
  if(idx < 0){
    80006c18:	02054a63          	bltz	a0,80006c4c <sem_post+0x52>
    release(&semt.lock);
    return -1;
  }

  semt.s[idx].val++;
    80006c1c:	0024d497          	auipc	s1,0x24d
    80006c20:	1ac48493          	addi	s1,s1,428 # 80253dc8 <semt>
    80006c24:	0505                	addi	a0,a0,1
    80006c26:	0512                	slli	a0,a0,0x4
    80006c28:	00a48733          	add	a4,s1,a0
    80006c2c:	4b1c                	lw	a5,16(a4)
    80006c2e:	2785                	addiw	a5,a5,1
    80006c30:	cb1c                	sw	a5,16(a4)

  // 唤醒一个或全部：先做全部更简单也正确
  wakeup(&semt.s[idx]);
    80006c32:	0521                	addi	a0,a0,8
    80006c34:	9526                	add	a0,a0,s1
    80006c36:	89ffb0ef          	jal	ra,800024d4 <wakeup>

  release(&semt.lock);
    80006c3a:	8526                	mv	a0,s1
    80006c3c:	90afa0ef          	jal	ra,80000d46 <release>
  return 0;
    80006c40:	4501                	li	a0,0
}
    80006c42:	60e2                	ld	ra,24(sp)
    80006c44:	6442                	ld	s0,16(sp)
    80006c46:	64a2                	ld	s1,8(sp)
    80006c48:	6105                	addi	sp,sp,32
    80006c4a:	8082                	ret
    release(&semt.lock);
    80006c4c:	0024d517          	auipc	a0,0x24d
    80006c50:	17c50513          	addi	a0,a0,380 # 80253dc8 <semt>
    80006c54:	8f2fa0ef          	jal	ra,80000d46 <release>
    return -1;
    80006c58:	557d                	li	a0,-1
    80006c5a:	b7e5                	j	80006c42 <sem_post+0x48>

0000000080006c5c <sys_sem_open>:
#include "defs.h"


uint64
sys_sem_open(void)
{
    80006c5c:	1101                	addi	sp,sp,-32
    80006c5e:	ec06                	sd	ra,24(sp)
    80006c60:	e822                	sd	s0,16(sp)
    80006c62:	1000                	addi	s0,sp,32
  int key, init;
  argint(0, &key);
    80006c64:	fec40593          	addi	a1,s0,-20
    80006c68:	4501                	li	a0,0
    80006c6a:	956fc0ef          	jal	ra,80002dc0 <argint>
  argint(1, &init);
    80006c6e:	fe840593          	addi	a1,s0,-24
    80006c72:	4505                	li	a0,1
    80006c74:	94cfc0ef          	jal	ra,80002dc0 <argint>
  return sem_open(key, init);
    80006c78:	fe842583          	lw	a1,-24(s0)
    80006c7c:	fec42503          	lw	a0,-20(s0)
    80006c80:	e39ff0ef          	jal	ra,80006ab8 <sem_open>
}
    80006c84:	60e2                	ld	ra,24(sp)
    80006c86:	6442                	ld	s0,16(sp)
    80006c88:	6105                	addi	sp,sp,32
    80006c8a:	8082                	ret

0000000080006c8c <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80006c8c:	1101                	addi	sp,sp,-32
    80006c8e:	ec06                	sd	ra,24(sp)
    80006c90:	e822                	sd	s0,16(sp)
    80006c92:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006c94:	fec40593          	addi	a1,s0,-20
    80006c98:	4501                	li	a0,0
    80006c9a:	926fc0ef          	jal	ra,80002dc0 <argint>
  return sem_wait(key);
    80006c9e:	fec42503          	lw	a0,-20(s0)
    80006ca2:	eabff0ef          	jal	ra,80006b4c <sem_wait>
}
    80006ca6:	60e2                	ld	ra,24(sp)
    80006ca8:	6442                	ld	s0,16(sp)
    80006caa:	6105                	addi	sp,sp,32
    80006cac:	8082                	ret

0000000080006cae <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80006cae:	1101                	addi	sp,sp,-32
    80006cb0:	ec06                	sd	ra,24(sp)
    80006cb2:	e822                	sd	s0,16(sp)
    80006cb4:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006cb6:	fec40593          	addi	a1,s0,-20
    80006cba:	4501                	li	a0,0
    80006cbc:	904fc0ef          	jal	ra,80002dc0 <argint>
  return sem_post(key);
    80006cc0:	fec42503          	lw	a0,-20(s0)
    80006cc4:	f37ff0ef          	jal	ra,80006bfa <sem_post>
}
    80006cc8:	60e2                	ld	ra,24(sp)
    80006cca:	6442                	ld	s0,16(sp)
    80006ccc:	6105                	addi	sp,sp,32
    80006cce:	8082                	ret

0000000080006cd0 <vmstatsinit>:
  uint64 shm_faults;
} vmstats;

void
vmstatsinit(void)
{
    80006cd0:	1141                	addi	sp,sp,-16
    80006cd2:	e406                	sd	ra,8(sp)
    80006cd4:	e022                	sd	s0,0(sp)
    80006cd6:	0800                	addi	s0,sp,16
  initlock(&vmstats.lock, "vmstats");
    80006cd8:	00002597          	auipc	a1,0x2
    80006cdc:	bb058593          	addi	a1,a1,-1104 # 80008888 <syscalls+0x490>
    80006ce0:	0024d517          	auipc	a0,0x24d
    80006ce4:	50050513          	addi	a0,a0,1280 # 802541e0 <vmstats>
    80006ce8:	f47f90ef          	jal	ra,80000c2e <initlock>
}
    80006cec:	60a2                	ld	ra,8(sp)
    80006cee:	6402                	ld	s0,0(sp)
    80006cf0:	0141                	addi	sp,sp,16
    80006cf2:	8082                	ret

0000000080006cf4 <vmstats_snapshot>:

// 给 sys_vmstats 用：读出一份快照
void
vmstats_snapshot(struct vmstats_user *out)
{
    80006cf4:	1101                	addi	sp,sp,-32
    80006cf6:	ec06                	sd	ra,24(sp)
    80006cf8:	e822                	sd	s0,16(sp)
    80006cfa:	e426                	sd	s1,8(sp)
    80006cfc:	e04a                	sd	s2,0(sp)
    80006cfe:	1000                	addi	s0,sp,32
    80006d00:	84aa                	mv	s1,a0
  acquire(&vmstats.lock);
    80006d02:	0024d917          	auipc	s2,0x24d
    80006d06:	4de90913          	addi	s2,s2,1246 # 802541e0 <vmstats>
    80006d0a:	854a                	mv	a0,s2
    80006d0c:	fa3f90ef          	jal	ra,80000cae <acquire>
  out->cow_faults  = vmstats.cow_faults;
    80006d10:	01893783          	ld	a5,24(s2)
    80006d14:	e09c                	sd	a5,0(s1)
  out->lazy_faults = vmstats.lazy_faults;
    80006d16:	02093783          	ld	a5,32(s2)
    80006d1a:	e49c                	sd	a5,8(s1)
  out->shm_faults  = vmstats.shm_faults;
    80006d1c:	02893783          	ld	a5,40(s2)
    80006d20:	e89c                	sd	a5,16(s1)
  release(&vmstats.lock);
    80006d22:	854a                	mv	a0,s2
    80006d24:	822fa0ef          	jal	ra,80000d46 <release>

  out->kalloc_cnt = kalloc_cnt;
    80006d28:	00002797          	auipc	a5,0x2
    80006d2c:	bd87b783          	ld	a5,-1064(a5) # 80008900 <kalloc_cnt>
    80006d30:	ec9c                	sd	a5,24(s1)
  out->copyin_bytes = copyin_bytes;
    80006d32:	00002797          	auipc	a5,0x2
    80006d36:	bc67b783          	ld	a5,-1082(a5) # 800088f8 <copyin_bytes>
    80006d3a:	f09c                	sd	a5,32(s1)
  out->copyout_bytes = copyout_bytes;
    80006d3c:	00002797          	auipc	a5,0x2
    80006d40:	bb47b783          	ld	a5,-1100(a5) # 800088f0 <copyout_bytes>
    80006d44:	f49c                	sd	a5,40(s1)
}
    80006d46:	60e2                	ld	ra,24(sp)
    80006d48:	6442                	ld	s0,16(sp)
    80006d4a:	64a2                	ld	s1,8(sp)
    80006d4c:	6902                	ld	s2,0(sp)
    80006d4e:	6105                	addi	sp,sp,32
    80006d50:	8082                	ret

0000000080006d52 <vmstats_inc_cow>:




// 给其他模块做计数：不追求绝对精确可以不加锁
void vmstats_inc_cow(void)  { acquire(&vmstats.lock); vmstats.cow_faults++;  release(&vmstats.lock); }
    80006d52:	1101                	addi	sp,sp,-32
    80006d54:	ec06                	sd	ra,24(sp)
    80006d56:	e822                	sd	s0,16(sp)
    80006d58:	e426                	sd	s1,8(sp)
    80006d5a:	1000                	addi	s0,sp,32
    80006d5c:	0024d497          	auipc	s1,0x24d
    80006d60:	48448493          	addi	s1,s1,1156 # 802541e0 <vmstats>
    80006d64:	8526                	mv	a0,s1
    80006d66:	f49f90ef          	jal	ra,80000cae <acquire>
    80006d6a:	6c9c                	ld	a5,24(s1)
    80006d6c:	0785                	addi	a5,a5,1
    80006d6e:	ec9c                	sd	a5,24(s1)
    80006d70:	8526                	mv	a0,s1
    80006d72:	fd5f90ef          	jal	ra,80000d46 <release>
    80006d76:	60e2                	ld	ra,24(sp)
    80006d78:	6442                	ld	s0,16(sp)
    80006d7a:	64a2                	ld	s1,8(sp)
    80006d7c:	6105                	addi	sp,sp,32
    80006d7e:	8082                	ret

0000000080006d80 <vmstats_inc_lazy>:
void vmstats_inc_lazy(void) { acquire(&vmstats.lock); vmstats.lazy_faults++; release(&vmstats.lock); }
    80006d80:	1101                	addi	sp,sp,-32
    80006d82:	ec06                	sd	ra,24(sp)
    80006d84:	e822                	sd	s0,16(sp)
    80006d86:	e426                	sd	s1,8(sp)
    80006d88:	1000                	addi	s0,sp,32
    80006d8a:	0024d497          	auipc	s1,0x24d
    80006d8e:	45648493          	addi	s1,s1,1110 # 802541e0 <vmstats>
    80006d92:	8526                	mv	a0,s1
    80006d94:	f1bf90ef          	jal	ra,80000cae <acquire>
    80006d98:	709c                	ld	a5,32(s1)
    80006d9a:	0785                	addi	a5,a5,1
    80006d9c:	f09c                	sd	a5,32(s1)
    80006d9e:	8526                	mv	a0,s1
    80006da0:	fa7f90ef          	jal	ra,80000d46 <release>
    80006da4:	60e2                	ld	ra,24(sp)
    80006da6:	6442                	ld	s0,16(sp)
    80006da8:	64a2                	ld	s1,8(sp)
    80006daa:	6105                	addi	sp,sp,32
    80006dac:	8082                	ret

0000000080006dae <vmstats_inc_shm>:
void vmstats_inc_shm(void)  { acquire(&vmstats.lock); vmstats.shm_faults++;  release(&vmstats.lock); }
    80006dae:	1101                	addi	sp,sp,-32
    80006db0:	ec06                	sd	ra,24(sp)
    80006db2:	e822                	sd	s0,16(sp)
    80006db4:	e426                	sd	s1,8(sp)
    80006db6:	1000                	addi	s0,sp,32
    80006db8:	0024d497          	auipc	s1,0x24d
    80006dbc:	42848493          	addi	s1,s1,1064 # 802541e0 <vmstats>
    80006dc0:	8526                	mv	a0,s1
    80006dc2:	eedf90ef          	jal	ra,80000cae <acquire>
    80006dc6:	749c                	ld	a5,40(s1)
    80006dc8:	0785                	addi	a5,a5,1
    80006dca:	f49c                	sd	a5,40(s1)
    80006dcc:	8526                	mv	a0,s1
    80006dce:	f79f90ef          	jal	ra,80000d46 <release>
    80006dd2:	60e2                	ld	ra,24(sp)
    80006dd4:	6442                	ld	s0,16(sp)
    80006dd6:	64a2                	ld	s1,8(sp)
    80006dd8:	6105                	addi	sp,sp,32
    80006dda:	8082                	ret
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
