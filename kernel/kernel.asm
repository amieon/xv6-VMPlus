
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
    80000004:	90010113          	addi	sp,sp,-1792 # 80008900 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdaa5ff>
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
    8000010a:	744020ef          	jal	ra,8000284e <either_copyin>
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
    80000176:	78e50513          	addi	a0,a0,1934 # 80010900 <cons>
    8000017a:	337000ef          	jal	ra,80000cb0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	78248493          	addi	s1,s1,1922 # 80010900 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00011917          	auipc	s2,0x11
    8000018a:	81290913          	addi	s2,s2,-2030 # 80010998 <cons+0x98>
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
    800001a4:	20d010ef          	jal	ra,80001bb0 <myproc>
    800001a8:	538020ef          	jal	ra,800026e0 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	2f6020ef          	jal	ra,800024a8 <sleep>
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
    800001ea:	61a020ef          	jal	ra,80002804 <either_copyout>
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
    800001fe:	70650513          	addi	a0,a0,1798 # 80010900 <cons>
    80000202:	347000ef          	jal	ra,80000d48 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	6f450513          	addi	a0,a0,1780 # 80010900 <cons>
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
    80000242:	74f72d23          	sw	a5,1882(a4) # 80010998 <cons+0x98>
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
    8000028c:	67850513          	addi	a0,a0,1656 # 80010900 <cons>
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
    800002aa:	5ee020ef          	jal	ra,80002898 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	65250513          	addi	a0,a0,1618 # 80010900 <cons>
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
    800002d2:	63270713          	addi	a4,a4,1586 # 80010900 <cons>
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
    800002f8:	60c78793          	addi	a5,a5,1548 # 80010900 <cons>
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
    80000326:	6767a783          	lw	a5,1654(a5) # 80010998 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	5ca70713          	addi	a4,a4,1482 # 80010900 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	5ba48493          	addi	s1,s1,1466 # 80010900 <cons>
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
    80000382:	58270713          	addi	a4,a4,1410 # 80010900 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	60f72623          	sw	a5,1548(a4) # 800109a0 <cons+0xa0>
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
    800003b6:	54e78793          	addi	a5,a5,1358 # 80010900 <cons>
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
    800003da:	5cc7a323          	sw	a2,1478(a5) # 8001099c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	5ba50513          	addi	a0,a0,1466 # 80010998 <cons+0x98>
    800003e6:	10e020ef          	jal	ra,800024f4 <wakeup>
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
    80000400:	50450513          	addi	a0,a0,1284 # 80010900 <cons>
    80000404:	02d000ef          	jal	ra,80000c30 <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0024a797          	auipc	a5,0x24a
    80000410:	67c78793          	addi	a5,a5,1660 # 8024aa88 <devsw>
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
    80000538:	47450513          	addi	a0,a0,1140 # 800109a8 <pr>
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
    80000780:	22c50513          	addi	a0,a0,556 # 800109a8 <pr>
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
    800007da:	1d250513          	addi	a0,a0,466 # 800109a8 <pr>
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
    80000826:	19e50513          	addi	a0,a0,414 # 800109c0 <tx_lock>
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
    80000854:	17050513          	addi	a0,a0,368 # 800109c0 <tx_lock>
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
    8000087a:	14a98993          	addi	s3,s3,330 # 800109c0 <tx_lock>
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
    80000892:	417010ef          	jal	ra,800024a8 <sleep>
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
    800008b6:	10e50513          	addi	a0,a0,270 # 800109c0 <tx_lock>
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
    8000096e:	05650513          	addi	a0,a0,86 # 800109c0 <tx_lock>
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
    80000984:	04050513          	addi	a0,a0,64 # 800109c0 <tx_lock>
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
    800009a0:	355010ef          	jal	ra,800024f4 <wakeup>
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
    800009cc:	03050513          	addi	a0,a0,48 # 800109f8 <kref>
    800009d0:	2e0000ef          	jal	ra,80000cb0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d4:	00010517          	auipc	a0,0x10
    800009d8:	02450513          	addi	a0,a0,36 # 800109f8 <kref>
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
    80000a06:	ff650513          	addi	a0,a0,-10 # 800109f8 <kref>
    80000a0a:	2a6000ef          	jal	ra,80000cb0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0e:	00c4d793          	srli	a5,s1,0xc
    80000a12:	00010517          	auipc	a0,0x10
    80000a16:	fe650513          	addi	a0,a0,-26 # 800109f8 <kref>
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
    80000a4a:	fb250513          	addi	a0,a0,-78 # 800109f8 <kref>
    80000a4e:	262000ef          	jal	ra,80000cb0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a52:	00c4d793          	srli	a5,s1,0xc
    80000a56:	00010517          	auipc	a0,0x10
    80000a5a:	fa250513          	addi	a0,a0,-94 # 800109f8 <kref>
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
    80000a96:	76e78793          	addi	a5,a5,1902 # 80254200 <end>
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
    80000ad4:	f0890913          	addi	s2,s2,-248 # 800109d8 <kmem>
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
    80000b1c:	ee090913          	addi	s2,s2,-288 # 800109f8 <kref>
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
    80000b78:	e6450513          	addi	a0,a0,-412 # 800109d8 <kmem>
    80000b7c:	0b4000ef          	jal	ra,80000c30 <initlock>
  initlock(&kref.lock, "kref");
    80000b80:	00007597          	auipc	a1,0x7
    80000b84:	4e858593          	addi	a1,a1,1256 # 80008068 <digits+0x30>
    80000b88:	00010517          	auipc	a0,0x10
    80000b8c:	e7050513          	addi	a0,a0,-400 # 800109f8 <kref>
    80000b90:	0a0000ef          	jal	ra,80000c30 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b94:	45c5                	li	a1,17
    80000b96:	05ee                	slli	a1,a1,0x1b
    80000b98:	00253517          	auipc	a0,0x253
    80000b9c:	66850513          	addi	a0,a0,1640 # 80254200 <end>
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
    80000bba:	e2248493          	addi	s1,s1,-478 # 800109d8 <kmem>
    80000bbe:	8526                	mv	a0,s1
    80000bc0:	0f0000ef          	jal	ra,80000cb0 <acquire>
  r = kmem.freelist;
    80000bc4:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc6:	ccb1                	beqz	s1,80000c22 <kalloc+0x76>
    kmem.freelist = r->next;
    80000bc8:	609c                	ld	a5,0(s1)
    80000bca:	00010517          	auipc	a0,0x10
    80000bce:	e0e50513          	addi	a0,a0,-498 # 800109d8 <kmem>
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
    80000be6:	e1650513          	addi	a0,a0,-490 # 800109f8 <kref>
    80000bea:	0c6000ef          	jal	ra,80000cb0 <acquire>
    kref.refcnt[PA2IDX(r)] = 1;
    80000bee:	00010517          	auipc	a0,0x10
    80000bf2:	e0a50513          	addi	a0,a0,-502 # 800109f8 <kref>
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
    80000c0c:	ce870713          	addi	a4,a4,-792 # 800088f0 <kalloc_cnt>
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
    80000c26:	db650513          	addi	a0,a0,-586 # 800109d8 <kmem>
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
    80000c5a:	73b000ef          	jal	ra,80001b94 <mycpu>
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
    80000c88:	70d000ef          	jal	ra,80001b94 <mycpu>
    80000c8c:	5d3c                	lw	a5,120(a0)
    80000c8e:	cb99                	beqz	a5,80000ca4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c90:	705000ef          	jal	ra,80001b94 <mycpu>
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
    80000ca4:	6f1000ef          	jal	ra,80001b94 <mycpu>
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
    80000cd8:	6bd000ef          	jal	ra,80001b94 <mycpu>
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
    80000cfc:	699000ef          	jal	ra,80001b94 <mycpu>
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
    80000f2e:	457000ef          	jal	ra,80001b84 <cpuid>
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
    80000f46:	43f000ef          	jal	ra,80001b84 <cpuid>
    80000f4a:	85aa                	mv	a1,a0
    80000f4c:	00007517          	auipc	a0,0x7
    80000f50:	16c50513          	addi	a0,a0,364 # 800080b8 <digits+0x80>
    80000f54:	d70ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000f58:	08c000ef          	jal	ra,80000fe4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f5c:	26d010ef          	jal	ra,800029c8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f60:	0e4050ef          	jal	ra,80006044 <plicinithart>
  }

  scheduler();        
    80000f64:	3ac010ef          	jal	ra,80002310 <scheduler>
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
    80000f94:	563050ef          	jal	ra,80006cf6 <vmstatsinit>
    kinit();         // physical page allocator
    80000f98:	bcdff0ef          	jal	ra,80000b64 <kinit>
    kvminit();       // create kernel page table
    80000f9c:	2d2000ef          	jal	ra,8000126e <kvminit>
    kvminithart();   // turn on paging
    80000fa0:	044000ef          	jal	ra,80000fe4 <kvminithart>
    procinit();      // process table
    80000fa4:	339000ef          	jal	ra,80001adc <procinit>
    trapinit();      // trap vectors
    80000fa8:	1fd010ef          	jal	ra,800029a4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fac:	21d010ef          	jal	ra,800029c8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fb0:	07e050ef          	jal	ra,8000602e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fb4:	090050ef          	jal	ra,80006044 <plicinithart>
    binit();         // buffer cache
    80000fb8:	7d4020ef          	jal	ra,8000378c <binit>
    iinit();         // inode table
    80000fbc:	549020ef          	jal	ra,80003d04 <iinit>
    fileinit();      // file table
    80000fc0:	429030ef          	jal	ra,80004be8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc4:	170050ef          	jal	ra,80006134 <virtio_disk_init>
    userinit();      // first user process
    80000fc8:	10c010ef          	jal	ra,800020d4 <userinit>
    shm_init();
    80000fcc:	5e0050ef          	jal	ra,800065ac <shm_init>
    seminit();
    80000fd0:	2e9050ef          	jal	ra,80006ab8 <seminit>
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
    8000125c:	7f6000ef          	jal	ra,80001a52 <proc_mapstacks>
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
#else
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001498:	ca69                	beqz	a2,8000156a <uvmcopy+0xd2>
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
    800014ae:	e062                	sd	s8,0(sp)
    800014b0:	0880                	addi	s0,sp,80
    800014b2:	8a2a                	mv	s4,a0
    800014b4:	8b2e                	mv	s6,a1
    800014b6:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014b8:	4901                	li	s2,0
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
      // 映射失败，回滚引用计数
      kref_dec((void*)pa);
      goto err;
    }
    { extern uint64 fork_share_pages; fork_share_pages++; }
    800014ba:	00007a97          	auipc	s5,0x7
    800014be:	416a8a93          	addi	s5,s5,1046 # 800088d0 <fork_share_pages>
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014c2:	7bfd                	lui	s7,0xfffff
    800014c4:	002bdb93          	srli	s7,s7,0x2
    800014c8:	a815                	j	800014fc <uvmcopy+0x64>
    pa = PTE2PA(*pte);
    800014ca:	82a9                	srli	a3,a3,0xa
    800014cc:	00c69493          	slli	s1,a3,0xc
    kref_inc((void*)pa);
    800014d0:	8526                	mv	a0,s1
    800014d2:	d24ff0ef          	jal	ra,800009f6 <kref_inc>
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800014d6:	8762                	mv	a4,s8
    800014d8:	86a6                	mv	a3,s1
    800014da:	6605                	lui	a2,0x1
    800014dc:	85ca                	mv	a1,s2
    800014de:	855a                	mv	a0,s6
    800014e0:	c05ff0ef          	jal	ra,800010e4 <mappages>
    800014e4:	e931                	bnez	a0,80001538 <uvmcopy+0xa0>
    { extern uint64 fork_share_pages; fork_share_pages++; }
    800014e6:	000ab783          	ld	a5,0(s5)
    800014ea:	0785                	addi	a5,a5,1
    800014ec:	00fab023          	sd	a5,0(s5)
    800014f0:	12000073          	sfence.vma
  for(i = 0; i < sz; i += PGSIZE){
    800014f4:	6785                	lui	a5,0x1
    800014f6:	993e                	add	s2,s2,a5
    800014f8:	05397c63          	bgeu	s2,s3,80001550 <uvmcopy+0xb8>
    pte = walk(old, i, 0);
    800014fc:	4601                	li	a2,0
    800014fe:	85ca                	mv	a1,s2
    80001500:	8552                	mv	a0,s4
    80001502:	b0bff0ef          	jal	ra,8000100c <walk>
    if(pte == 0)
    80001506:	d57d                	beqz	a0,800014f4 <uvmcopy+0x5c>
    if((*pte & PTE_V) == 0)
    80001508:	6114                	ld	a3,0(a0)
    8000150a:	0016f793          	andi	a5,a3,1
    8000150e:	d3fd                	beqz	a5,800014f4 <uvmcopy+0x5c>
    flags = PTE_FLAGS(*pte);
    80001510:	0006879b          	sext.w	a5,a3
    if((flags & PTE_U) == 0)
    80001514:	0106f713          	andi	a4,a3,16
    80001518:	df71                	beqz	a4,800014f4 <uvmcopy+0x5c>
    flags = PTE_FLAGS(*pte);
    8000151a:	3ff7fc13          	andi	s8,a5,1023
    if(flags & PTE_W){
    8000151e:	8b91                	andi	a5,a5,4
    80001520:	d7cd                	beqz	a5,800014ca <uvmcopy+0x32>
      flags = (flags & ~PTE_W) | PTE_COW;
    80001522:	efbc7793          	andi	a5,s8,-261
    80001526:	1007ec13          	ori	s8,a5,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    8000152a:	0176f733          	and	a4,a3,s7
    8000152e:	8fd9                	or	a5,a5,a4
    80001530:	1017e793          	ori	a5,a5,257
    80001534:	e11c                	sd	a5,0(a0)
    80001536:	bf51                	j	800014ca <uvmcopy+0x32>
      kref_dec((void*)pa);
    80001538:	8526                	mv	a0,s1
    8000153a:	d00ff0ef          	jal	ra,80000a3a <kref_dec>
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调用 kfree()，kfree 会自动减少引用计数
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000153e:	4685                	li	a3,1
    80001540:	00c95613          	srli	a2,s2,0xc
    80001544:	4581                	li	a1,0
    80001546:	855a                	mv	a0,s6
    80001548:	d69ff0ef          	jal	ra,800012b0 <uvmunmap>
  return -1;
    8000154c:	557d                	li	a0,-1
    8000154e:	a011                	j	80001552 <uvmcopy+0xba>
  return 0;
    80001550:	4501                	li	a0,0
#endif
}
    80001552:	60a6                	ld	ra,72(sp)
    80001554:	6406                	ld	s0,64(sp)
    80001556:	74e2                	ld	s1,56(sp)
    80001558:	7942                	ld	s2,48(sp)
    8000155a:	79a2                	ld	s3,40(sp)
    8000155c:	7a02                	ld	s4,32(sp)
    8000155e:	6ae2                	ld	s5,24(sp)
    80001560:	6b42                	ld	s6,16(sp)
    80001562:	6ba2                	ld	s7,8(sp)
    80001564:	6c02                	ld	s8,0(sp)
    80001566:	6161                	addi	sp,sp,80
    80001568:	8082                	ret
  return 0;
    8000156a:	4501                	li	a0,0
}
    8000156c:	8082                	ret

000000008000156e <cowbreak>:
 *   - 该函数会在页表更新后刷新 TLB，确保更改立即生效
 *   - 当需要复制页面时，会更新 COW 统计信息
 */
int
cowbreak(pagetable_t pagetable, uint64 va)
{
    8000156e:	7179                	addi	sp,sp,-48
    80001570:	f406                	sd	ra,40(sp)
    80001572:	f022                	sd	s0,32(sp)
    80001574:	ec26                	sd	s1,24(sp)
    80001576:	e84a                	sd	s2,16(sp)
    80001578:	e44e                	sd	s3,8(sp)
    8000157a:	e052                	sd	s4,0(sp)
    8000157c:	1800                	addi	s0,sp,48
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
    8000157e:	4601                	li	a2,0
    80001580:	77fd                	lui	a5,0xfffff
    80001582:	8dfd                	and	a1,a1,a5
    80001584:	a89ff0ef          	jal	ra,8000100c <walk>
  if(pte == 0)
    80001588:	cd51                	beqz	a0,80001624 <cowbreak+0xb6>
    8000158a:	89aa                	mv	s3,a0
    return -1;                 // 页表项不存在
  if((*pte & PTE_V) == 0)
    8000158c:	6104                	ld	s1,0(a0)
    return -1;                 // 虚拟地址未映射到物理页
  if((*pte & PTE_U) == 0)
    8000158e:	0114f713          	andi	a4,s1,17
    80001592:	47c5                	li	a5,17
    80001594:	08f71a63          	bne	a4,a5,80001628 <cowbreak+0xba>
    return -1;                 // 非用户页

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    80001598:	1044f793          	andi	a5,s1,260
    8000159c:	10000713          	li	a4,256
    800015a0:	08e79663          	bne	a5,a4,8000162c <cowbreak+0xbe>
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);
    800015a4:	3ff4f913          	andi	s2,s1,1023
  uint64 pa_old = PTE2PA(*pte);
    800015a8:	00a4da13          	srli	s4,s1,0xa
    800015ac:	0a32                	slli	s4,s4,0xc

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    800015ae:	8552                	mv	a0,s4
    800015b0:	c0cff0ef          	jal	ra,800009bc <kref_get>
    800015b4:	4785                	li	a5,1
    800015b6:	04f50663          	beq	a0,a5,80001602 <cowbreak+0x94>
    sfence_vma();              // 刷新 TLB
    return 0;
  }

  // 分配新物理页
  char *mem = kalloc();
    800015ba:	df2ff0ef          	jal	ra,80000bac <kalloc>
    800015be:	84aa                	mv	s1,a0
  if(mem == 0)
    800015c0:	c925                	beqz	a0,80001630 <cowbreak+0xc2>
    return -1;                 // 内存分配失败

  // 复制旧页内容到新页
  memmove(mem, (void*)pa_old, PGSIZE);
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85d2                	mv	a1,s4
    800015c6:	81bff0ef          	jal	ra,80000de0 <memmove>

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);
    800015ca:	8552                	mv	a0,s4
    800015cc:	c6eff0ef          	jal	ra,80000a3a <kref_dec>

  // 更新 PTE：指向新页，变可写，清掉 COW 标志
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015d0:	80b1                	srli	s1,s1,0xc
    800015d2:	04aa                	slli	s1,s1,0xa
    800015d4:	00496913          	ori	s2,s2,4
    800015d8:	eff97913          	andi	s2,s2,-257
    800015dc:	0124e4b3          	or	s1,s1,s2
    800015e0:	0014e493          	ori	s1,s1,1
    800015e4:	0099b023          	sd	s1,0(s3) # fffffffffffff000 <end+0xffffffff7fdaae00>
    800015e8:	12000073          	sfence.vma

  sfence_vma();                // 刷新 TLB
  vmstats_inc_cow();           // 更新 COW 统计信息
    800015ec:	78c050ef          	jal	ra,80006d78 <vmstats_inc_cow>

  return 0;
    800015f0:	4501                	li	a0,0
}
    800015f2:	70a2                	ld	ra,40(sp)
    800015f4:	7402                	ld	s0,32(sp)
    800015f6:	64e2                	ld	s1,24(sp)
    800015f8:	6942                	ld	s2,16(sp)
    800015fa:	69a2                	ld	s3,8(sp)
    800015fc:	6a02                	ld	s4,0(sp)
    800015fe:	6145                	addi	sp,sp,48
    80001600:	8082                	ret
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    80001602:	00496913          	ori	s2,s2,4
    80001606:	eff97913          	andi	s2,s2,-257
    8000160a:	77fd                	lui	a5,0xfffff
    8000160c:	8389                	srli	a5,a5,0x2
    8000160e:	8cfd                	and	s1,s1,a5
    80001610:	00996933          	or	s2,s2,s1
    80001614:	00196913          	ori	s2,s2,1
    80001618:	0129b023          	sd	s2,0(s3)
    8000161c:	12000073          	sfence.vma
    return 0;
    80001620:	4501                	li	a0,0
    80001622:	bfc1                	j	800015f2 <cowbreak+0x84>
    return -1;                 // 页表项不存在
    80001624:	557d                	li	a0,-1
    80001626:	b7f1                	j	800015f2 <cowbreak+0x84>
    return -1;                 // 非用户页
    80001628:	557d                	li	a0,-1
    8000162a:	b7e1                	j	800015f2 <cowbreak+0x84>
    return -1;
    8000162c:	557d                	li	a0,-1
    8000162e:	b7d1                	j	800015f2 <cowbreak+0x84>
    return -1;                 // 内存分配失败
    80001630:	557d                	li	a0,-1
    80001632:	b7c1                	j	800015f2 <cowbreak+0x84>

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	addi	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	9cfff0ef          	jal	ra,8000100c <walk>
  if(pte == 0)
    80001642:	c901                	beqz	a0,80001652 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001644:	611c                	ld	a5,0(a0)
    80001646:	9bbd                	andi	a5,a5,-17
    80001648:	e11c                	sd	a5,0(a0)
}
    8000164a:	60a2                	ld	ra,8(sp)
    8000164c:	6402                	ld	s0,0(sp)
    8000164e:	0141                	addi	sp,sp,16
    80001650:	8082                	ret
    panic("uvmclear");
    80001652:	00007517          	auipc	a0,0x7
    80001656:	b1650513          	addi	a0,a0,-1258 # 80008168 <digits+0x130>
    8000165a:	930ff0ef          	jal	ra,8000078a <panic>

000000008000165e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000165e:	c2d5                	beqz	a3,80001702 <copyinstr+0xa4>
{
    80001660:	715d                	addi	sp,sp,-80
    80001662:	e486                	sd	ra,72(sp)
    80001664:	e0a2                	sd	s0,64(sp)
    80001666:	fc26                	sd	s1,56(sp)
    80001668:	f84a                	sd	s2,48(sp)
    8000166a:	f44e                	sd	s3,40(sp)
    8000166c:	f052                	sd	s4,32(sp)
    8000166e:	ec56                	sd	s5,24(sp)
    80001670:	e85a                	sd	s6,16(sp)
    80001672:	e45e                	sd	s7,8(sp)
    80001674:	0880                	addi	s0,sp,80
    80001676:	8a2a                	mv	s4,a0
    80001678:	8b2e                	mv	s6,a1
    8000167a:	8bb2                	mv	s7,a2
    8000167c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000167e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001680:	6985                	lui	s3,0x1
    80001682:	a035                	j	800016ae <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001684:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdaae00>
    80001688:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000168a:	0017b793          	seqz	a5,a5
    8000168e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001692:	60a6                	ld	ra,72(sp)
    80001694:	6406                	ld	s0,64(sp)
    80001696:	74e2                	ld	s1,56(sp)
    80001698:	7942                	ld	s2,48(sp)
    8000169a:	79a2                	ld	s3,40(sp)
    8000169c:	7a02                	ld	s4,32(sp)
    8000169e:	6ae2                	ld	s5,24(sp)
    800016a0:	6b42                	ld	s6,16(sp)
    800016a2:	6ba2                	ld	s7,8(sp)
    800016a4:	6161                	addi	sp,sp,80
    800016a6:	8082                	ret
    srcva = va0 + PGSIZE;
    800016a8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800016ac:	c4b9                	beqz	s1,800016fa <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    800016ae:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800016b2:	85ca                	mv	a1,s2
    800016b4:	8552                	mv	a0,s4
    800016b6:	9f1ff0ef          	jal	ra,800010a6 <walkaddr>
    if(pa0 == 0)
    800016ba:	c131                	beqz	a0,800016fe <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    800016bc:	41790833          	sub	a6,s2,s7
    800016c0:	984e                	add	a6,a6,s3
    if(n > max)
    800016c2:	0104f363          	bgeu	s1,a6,800016c8 <copyinstr+0x6a>
    800016c6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016c8:	955e                	add	a0,a0,s7
    800016ca:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016ce:	fc080de3          	beqz	a6,800016a8 <copyinstr+0x4a>
    800016d2:	985a                	add	a6,a6,s6
    800016d4:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016d6:	41650633          	sub	a2,a0,s6
    800016da:	14fd                	addi	s1,s1,-1
    800016dc:	9b26                	add	s6,s6,s1
    800016de:	00f60733          	add	a4,a2,a5
    800016e2:	00074703          	lbu	a4,0(a4)
    800016e6:	df59                	beqz	a4,80001684 <copyinstr+0x26>
        *dst = *p;
    800016e8:	00e78023          	sb	a4,0(a5)
      --max;
    800016ec:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016f0:	0785                	addi	a5,a5,1
    while(n > 0){
    800016f2:	ff0796e3          	bne	a5,a6,800016de <copyinstr+0x80>
      dst++;
    800016f6:	8b42                	mv	s6,a6
    800016f8:	bf45                	j	800016a8 <copyinstr+0x4a>
    800016fa:	4781                	li	a5,0
    800016fc:	b779                	j	8000168a <copyinstr+0x2c>
      return -1;
    800016fe:	557d                	li	a0,-1
    80001700:	bf49                	j	80001692 <copyinstr+0x34>
  int got_null = 0;
    80001702:	4781                	li	a5,0
  if(got_null){
    80001704:	0017b793          	seqz	a5,a5
    80001708:	40f00533          	neg	a0,a5
}
    8000170c:	8082                	ret

000000008000170e <ismapped>:
 *   - 仅检查映射存在性，不检查权限
 *   - 用于 vmfault 和其他内存管理函数中的辅助检查
 */
int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000170e:	1141                	addi	sp,sp,-16
    80001710:	e406                	sd	ra,8(sp)
    80001712:	e022                	sd	s0,0(sp)
    80001714:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001716:	4601                	li	a2,0
    80001718:	8f5ff0ef          	jal	ra,8000100c <walk>
  if (pte == 0) {               // 页表项不存在
    8000171c:	c519                	beqz	a0,8000172a <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    8000171e:	6108                	ld	a0,0(a0)
    return 0;
    80001720:	8905                	andi	a0,a0,1
    return 1;                   // 页表项存在且有效
  }
  return 0;                     // 页表项存在但无效
}
    80001722:	60a2                	ld	ra,8(sp)
    80001724:	6402                	ld	s0,0(sp)
    80001726:	0141                	addi	sp,sp,16
    80001728:	8082                	ret
    return 0;
    8000172a:	4501                	li	a0,0
    8000172c:	bfdd                	j	80001722 <ismapped+0x14>

000000008000172e <vmfault>:
{
    8000172e:	7179                	addi	sp,sp,-48
    80001730:	f406                	sd	ra,40(sp)
    80001732:	f022                	sd	s0,32(sp)
    80001734:	ec26                	sd	s1,24(sp)
    80001736:	e84a                	sd	s2,16(sp)
    80001738:	e44e                	sd	s3,8(sp)
    8000173a:	e052                	sd	s4,0(sp)
    8000173c:	1800                	addi	s0,sp,48
    8000173e:	89aa                	mv	s3,a0
    80001740:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001742:	46e000ef          	jal	ra,80001bb0 <myproc>
  if (va >= p->sz)              // 检查虚拟地址是否在进程地址空间范围内
    80001746:	653c                	ld	a5,72(a0)
    80001748:	00f4ec63          	bltu	s1,a5,80001760 <vmfault+0x32>
    return 0;
    8000174c:	4981                	li	s3,0
}
    8000174e:	854e                	mv	a0,s3
    80001750:	70a2                	ld	ra,40(sp)
    80001752:	7402                	ld	s0,32(sp)
    80001754:	64e2                	ld	s1,24(sp)
    80001756:	6942                	ld	s2,16(sp)
    80001758:	69a2                	ld	s3,8(sp)
    8000175a:	6a02                	ld	s4,0(sp)
    8000175c:	6145                	addi	sp,sp,48
    8000175e:	8082                	ret
    80001760:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);         // 向下对齐到页边界
    80001762:	75fd                	lui	a1,0xfffff
    80001764:	8ced                	and	s1,s1,a1
  if(ismapped(pagetable, va)) { // 检查是否已映射
    80001766:	85a6                	mv	a1,s1
    80001768:	854e                	mv	a0,s3
    8000176a:	fa5ff0ef          	jal	ra,8000170e <ismapped>
    return 0;
    8000176e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) { // 检查是否已映射
    80001770:	fd79                	bnez	a0,8000174e <vmfault+0x20>
  mem = (uint64) kalloc();      // 分配新物理页
    80001772:	c3aff0ef          	jal	ra,80000bac <kalloc>
    80001776:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001778:	d979                	beqz	a0,8000174e <vmfault+0x20>
  mem = (uint64) kalloc();      // 分配新物理页
    8000177a:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE); // 初始化为0
    8000177c:	6605                	lui	a2,0x1
    8000177e:	4581                	li	a1,0
    80001780:	e04ff0ef          	jal	ra,80000d84 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001784:	4759                	li	a4,22
    80001786:	86d2                	mv	a3,s4
    80001788:	6605                	lui	a2,0x1
    8000178a:	85a6                	mv	a1,s1
    8000178c:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001790:	955ff0ef          	jal	ra,800010e4 <mappages>
    80001794:	dd4d                	beqz	a0,8000174e <vmfault+0x20>
    kfree((void *)mem);         // 映射失败，释放物理页
    80001796:	8552                	mv	a0,s4
    80001798:	ae6ff0ef          	jal	ra,80000a7e <kfree>
    return 0;
    8000179c:	4981                	li	s3,0
    8000179e:	bf45                	j	8000174e <vmfault+0x20>

00000000800017a0 <copyout>:
  while(len > 0){
    800017a0:	cef1                	beqz	a3,8000187c <copyout+0xdc>
{
    800017a2:	7159                	addi	sp,sp,-112
    800017a4:	f486                	sd	ra,104(sp)
    800017a6:	f0a2                	sd	s0,96(sp)
    800017a8:	eca6                	sd	s1,88(sp)
    800017aa:	e8ca                	sd	s2,80(sp)
    800017ac:	e4ce                	sd	s3,72(sp)
    800017ae:	e0d2                	sd	s4,64(sp)
    800017b0:	fc56                	sd	s5,56(sp)
    800017b2:	f85a                	sd	s6,48(sp)
    800017b4:	f45e                	sd	s7,40(sp)
    800017b6:	f062                	sd	s8,32(sp)
    800017b8:	ec66                	sd	s9,24(sp)
    800017ba:	e86a                	sd	s10,16(sp)
    800017bc:	e46e                	sd	s11,8(sp)
    800017be:	1880                	addi	s0,sp,112
    800017c0:	8aaa                	mv	s5,a0
    800017c2:	8b2e                	mv	s6,a1
    800017c4:	8bb2                	mv	s7,a2
    800017c6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800017c8:	74fd                	lui	s1,0xfffff
    800017ca:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800017cc:	57fd                	li	a5,-1
    800017ce:	83e9                	srli	a5,a5,0x1a
    800017d0:	0a97e863          	bltu	a5,s1,80001880 <copyout+0xe0>
    800017d4:	6d05                	lui	s10,0x1
    copyout_bytes += n;
    800017d6:	00007c17          	auipc	s8,0x7
    800017da:	10ac0c13          	addi	s8,s8,266 # 800088e0 <copyout_bytes>
    if(va0 >= MAXVA)
    800017de:	8cbe                	mv	s9,a5
    800017e0:	a091                	j	80001824 <copyout+0x84>
    if((*pte & PTE_W) == 0)
    800017e2:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
    800017e6:	8b91                	andi	a5,a5,4
    800017e8:	c7c5                	beqz	a5,80001890 <copyout+0xf0>
    n = PGSIZE - (dstva - va0);
    800017ea:	01a48db3          	add	s11,s1,s10
    800017ee:	416d89b3          	sub	s3,s11,s6
    if(n > len)
    800017f2:	013a7363          	bgeu	s4,s3,800017f8 <copyout+0x58>
    800017f6:	89d2                	mv	s3,s4
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017f8:	409b0533          	sub	a0,s6,s1
    800017fc:	0009861b          	sext.w	a2,s3
    80001800:	85de                	mv	a1,s7
    80001802:	954a                	add	a0,a0,s2
    80001804:	ddcff0ef          	jal	ra,80000de0 <memmove>
    len -= n;
    80001808:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000180c:	9bce                	add	s7,s7,s3
    copyout_bytes += n;
    8000180e:	000c3783          	ld	a5,0(s8)
    80001812:	99be                	add	s3,s3,a5
    80001814:	013c3023          	sd	s3,0(s8)
  while(len > 0){
    80001818:	060a0063          	beqz	s4,80001878 <copyout+0xd8>
    if(va0 >= MAXVA)
    8000181c:	07bce463          	bltu	s9,s11,80001884 <copyout+0xe4>
    va0 = PGROUNDDOWN(dstva);
    80001820:	84ee                	mv	s1,s11
    dstva = va0 + PGSIZE;
    80001822:	8b6e                	mv	s6,s11
    pa0 = walkaddr(pagetable, va0);
    80001824:	85a6                	mv	a1,s1
    80001826:	8556                	mv	a0,s5
    80001828:	87fff0ef          	jal	ra,800010a6 <walkaddr>
    8000182c:	892a                	mv	s2,a0
    if(pa0 == 0) {
    8000182e:	e901                	bnez	a0,8000183e <copyout+0x9e>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001830:	4601                	li	a2,0
    80001832:	85a6                	mv	a1,s1
    80001834:	8556                	mv	a0,s5
    80001836:	ef9ff0ef          	jal	ra,8000172e <vmfault>
    8000183a:	892a                	mv	s2,a0
    8000183c:	c531                	beqz	a0,80001888 <copyout+0xe8>
    pte = walk(pagetable, va0, 0);
    8000183e:	4601                	li	a2,0
    80001840:	85a6                	mv	a1,s1
    80001842:	8556                	mv	a0,s5
    80001844:	fc8ff0ef          	jal	ra,8000100c <walk>
    80001848:	89aa                	mv	s3,a0
    if(pte && (*pte & PTE_COW)){
    8000184a:	dd41                	beqz	a0,800017e2 <copyout+0x42>
    8000184c:	611c                	ld	a5,0(a0)
    8000184e:	1007f793          	andi	a5,a5,256
    80001852:	dbc1                	beqz	a5,800017e2 <copyout+0x42>
      if(cowbreak(pagetable, va0) < 0)
    80001854:	85a6                	mv	a1,s1
    80001856:	8556                	mv	a0,s5
    80001858:	d17ff0ef          	jal	ra,8000156e <cowbreak>
    8000185c:	02054863          	bltz	a0,8000188c <copyout+0xec>
      pte = walk(pagetable, va0, 0);
    80001860:	4601                	li	a2,0
    80001862:	85a6                	mv	a1,s1
    80001864:	8556                	mv	a0,s5
    80001866:	fa6ff0ef          	jal	ra,8000100c <walk>
    8000186a:	89aa                	mv	s3,a0
      pa0 = walkaddr(pagetable, va0);
    8000186c:	85a6                	mv	a1,s1
    8000186e:	8556                	mv	a0,s5
    80001870:	837ff0ef          	jal	ra,800010a6 <walkaddr>
    80001874:	892a                	mv	s2,a0
    80001876:	b7b5                	j	800017e2 <copyout+0x42>
  return 0;
    80001878:	4501                	li	a0,0
    8000187a:	a821                	j	80001892 <copyout+0xf2>
    8000187c:	4501                	li	a0,0
}
    8000187e:	8082                	ret
      return -1;
    80001880:	557d                	li	a0,-1
    80001882:	a801                	j	80001892 <copyout+0xf2>
    80001884:	557d                	li	a0,-1
    80001886:	a031                	j	80001892 <copyout+0xf2>
        return -1;
    80001888:	557d                	li	a0,-1
    8000188a:	a021                	j	80001892 <copyout+0xf2>
        return -1;
    8000188c:	557d                	li	a0,-1
    8000188e:	a011                	j	80001892 <copyout+0xf2>
      return -1;
    80001890:	557d                	li	a0,-1
}
    80001892:	70a6                	ld	ra,104(sp)
    80001894:	7406                	ld	s0,96(sp)
    80001896:	64e6                	ld	s1,88(sp)
    80001898:	6946                	ld	s2,80(sp)
    8000189a:	69a6                	ld	s3,72(sp)
    8000189c:	6a06                	ld	s4,64(sp)
    8000189e:	7ae2                	ld	s5,56(sp)
    800018a0:	7b42                	ld	s6,48(sp)
    800018a2:	7ba2                	ld	s7,40(sp)
    800018a4:	7c02                	ld	s8,32(sp)
    800018a6:	6ce2                	ld	s9,24(sp)
    800018a8:	6d42                	ld	s10,16(sp)
    800018aa:	6da2                	ld	s11,8(sp)
    800018ac:	6165                	addi	sp,sp,112
    800018ae:	8082                	ret

00000000800018b0 <copyin>:
  while(len > 0){
    800018b0:	c2c5                	beqz	a3,80001950 <copyin+0xa0>
{
    800018b2:	711d                	addi	sp,sp,-96
    800018b4:	ec86                	sd	ra,88(sp)
    800018b6:	e8a2                	sd	s0,80(sp)
    800018b8:	e4a6                	sd	s1,72(sp)
    800018ba:	e0ca                	sd	s2,64(sp)
    800018bc:	fc4e                	sd	s3,56(sp)
    800018be:	f852                	sd	s4,48(sp)
    800018c0:	f456                	sd	s5,40(sp)
    800018c2:	f05a                	sd	s6,32(sp)
    800018c4:	ec5e                	sd	s7,24(sp)
    800018c6:	e862                	sd	s8,16(sp)
    800018c8:	e466                	sd	s9,8(sp)
    800018ca:	1080                	addi	s0,sp,96
    800018cc:	8c2a                	mv	s8,a0
    800018ce:	8aae                	mv	s5,a1
    800018d0:	8932                	mv	s2,a2
    800018d2:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800018d4:	7cfd                	lui	s9,0xfffff
    n = PGSIZE - (srcva - va0);
    800018d6:	6b85                	lui	s7,0x1
    copyin_bytes += n; 
    800018d8:	00007b17          	auipc	s6,0x7
    800018dc:	010b0b13          	addi	s6,s6,16 # 800088e8 <copyin_bytes>
    800018e0:	a81d                	j	80001916 <copyin+0x66>
    n = PGSIZE - (srcva - va0);
    800018e2:	412984b3          	sub	s1,s3,s2
    800018e6:	94de                	add	s1,s1,s7
    if(n > len)
    800018e8:	009a7363          	bgeu	s4,s1,800018ee <copyin+0x3e>
    800018ec:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018ee:	413905b3          	sub	a1,s2,s3
    800018f2:	0004861b          	sext.w	a2,s1
    800018f6:	95aa                	add	a1,a1,a0
    800018f8:	8556                	mv	a0,s5
    800018fa:	ce6ff0ef          	jal	ra,80000de0 <memmove>
    len -= n;
    800018fe:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001902:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001904:	01798933          	add	s2,s3,s7
    copyin_bytes += n; 
    80001908:	000b3783          	ld	a5,0(s6)
    8000190c:	94be                	add	s1,s1,a5
    8000190e:	009b3023          	sd	s1,0(s6)
  while(len > 0){
    80001912:	020a0163          	beqz	s4,80001934 <copyin+0x84>
    va0 = PGROUNDDOWN(srcva);
    80001916:	019979b3          	and	s3,s2,s9
    pa0 = walkaddr(pagetable, va0);
    8000191a:	85ce                	mv	a1,s3
    8000191c:	8562                	mv	a0,s8
    8000191e:	f88ff0ef          	jal	ra,800010a6 <walkaddr>
    if(pa0 == 0) {
    80001922:	f161                	bnez	a0,800018e2 <copyin+0x32>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001924:	4601                	li	a2,0
    80001926:	85ce                	mv	a1,s3
    80001928:	8562                	mv	a0,s8
    8000192a:	e05ff0ef          	jal	ra,8000172e <vmfault>
    8000192e:	f955                	bnez	a0,800018e2 <copyin+0x32>
        return -1;
    80001930:	557d                	li	a0,-1
    80001932:	a011                	j	80001936 <copyin+0x86>
  return 0;
    80001934:	4501                	li	a0,0
}
    80001936:	60e6                	ld	ra,88(sp)
    80001938:	6446                	ld	s0,80(sp)
    8000193a:	64a6                	ld	s1,72(sp)
    8000193c:	6906                	ld	s2,64(sp)
    8000193e:	79e2                	ld	s3,56(sp)
    80001940:	7a42                	ld	s4,48(sp)
    80001942:	7aa2                	ld	s5,40(sp)
    80001944:	7b02                	ld	s6,32(sp)
    80001946:	6be2                	ld	s7,24(sp)
    80001948:	6c42                	ld	s8,16(sp)
    8000194a:	6ca2                	ld	s9,8(sp)
    8000194c:	6125                	addi	sp,sp,96
    8000194e:	8082                	ret
  return 0;
    80001950:	4501                	li	a0,0
}
    80001952:	8082                	ret

0000000080001954 <vmafault>:
 *   - 支持匿名映射和共享内存映射两种类型
 *   - 失败时会自动回滚已分配的资源（如物理页）
 */
uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    80001954:	7139                	addi	sp,sp,-64
    80001956:	fc06                	sd	ra,56(sp)
    80001958:	f822                	sd	s0,48(sp)
    8000195a:	f426                	sd	s1,40(sp)
    8000195c:	f04a                	sd	s2,32(sp)
    8000195e:	ec4e                	sd	s3,24(sp)
    80001960:	e852                	sd	s4,16(sp)
    80001962:	e456                	sd	s5,8(sp)
    80001964:	0080                	addi	s0,sp,64
    80001966:	8a2a                	mv	s4,a0
    80001968:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);         // 向下对齐到页边界
    8000196a:	77fd                	lui	a5,0xfffff
    8000196c:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va); // 查找虚拟地址所属的 VMA
    80001970:	85ce                	mv	a1,s3
    80001972:	752010ef          	jal	ra,800030c4 <vma_find>
  if(v == 0) return 0;          // 不在任何 VMA 范围内
    80001976:	c961                	beqz	a0,80001a46 <vmafault+0xf2>
    80001978:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    8000197a:	00090663          	beqz	s2,80001986 <vmafault+0x32>
    8000197e:	4d1c                	lw	a5,24(a0)
    80001980:	8b89                	andi	a5,a5,2
    return 0;
    80001982:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001984:	c789                	beqz	a5,8000198e <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0) // VMA 不允许读 -> 不处理
    80001986:	4c9c                	lw	a5,24(s1)
    80001988:	8b85                	andi	a5,a5,1
    return 0;
    8000198a:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0) // VMA 不允许读 -> 不处理
    8000198c:	eb99                	bnez	a5,800019a2 <vmafault+0x4e>
    else kfree((void*)pa);            // 释放普通物理页
    return 0;
  }
  vmstats_inc_lazy();            // 更新惰性分配统计信息
  return (uint64)pa;             // 返回物理页地址
}
    8000198e:	854a                	mv	a0,s2
    80001990:	70e2                	ld	ra,56(sp)
    80001992:	7442                	ld	s0,48(sp)
    80001994:	74a2                	ld	s1,40(sp)
    80001996:	7902                	ld	s2,32(sp)
    80001998:	69e2                	ld	s3,24(sp)
    8000199a:	6a42                	ld	s4,16(sp)
    8000199c:	6aa2                	ld	s5,8(sp)
    8000199e:	6121                	addi	sp,sp,64
    800019a0:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    800019a2:	4601                	li	a2,0
    800019a4:	85ce                	mv	a1,s3
    800019a6:	050a3503          	ld	a0,80(s4) # 2050 <_entry-0x7fffdfb0>
    800019aa:	e62ff0ef          	jal	ra,8000100c <walk>
  if(pte && (*pte & PTE_V)){     // 如果已经映射
    800019ae:	c115                	beqz	a0,800019d2 <vmafault+0x7e>
    800019b0:	611c                	ld	a5,0(a0)
    800019b2:	0017f913          	andi	s2,a5,1
    800019b6:	00090e63          	beqz	s2,800019d2 <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    800019ba:	4c98                	lw	a4,24(s1)
    800019bc:	8b09                	andi	a4,a4,2
    800019be:	c751                	beqz	a4,80001a4a <vmafault+0xf6>
    800019c0:	0047f713          	andi	a4,a5,4
    800019c4:	e749                	bnez	a4,80001a4e <vmafault+0xfa>
      *pte |= PTE_W;
    800019c6:	0047e793          	ori	a5,a5,4
    800019ca:	e11c                	sd	a5,0(a0)
    800019cc:	12000073          	sfence.vma
      return 1;                  // 返回成功标志
    800019d0:	bf7d                	j	8000198e <vmafault+0x3a>
  if(v->is_shm){                 // 共享内存 VMA
    800019d2:	509c                	lw	a5,32(s1)
    800019d4:	cf91                	beqz	a5,800019f0 <vmafault+0x9c>
  int idx = (va - v->start) / PGSIZE; // 计算页在 VMA 中的索引
    800019d6:	648c                	ld	a1,8(s1)
    800019d8:	40b985b3          	sub	a1,s3,a1
    800019dc:	81b1                	srli	a1,a1,0xc
    pa = shm_getpa(v->shm_key, idx); // 从共享内存对象获取物理页
    800019de:	2581                	sext.w	a1,a1
    800019e0:	50c8                	lw	a0,36(s1)
    800019e2:	631040ef          	jal	ra,80006812 <shm_getpa>
    800019e6:	892a                	mv	s2,a0
    if(pa == 0) return 0;        // 获取失败
    800019e8:	d15d                	beqz	a0,8000198e <vmafault+0x3a>
    kref_inc((void*)pa);         // 增加共享页的引用计数
    800019ea:	80cff0ef          	jal	ra,800009f6 <kref_inc>
    800019ee:	a819                	j	80001a04 <vmafault+0xb0>
    char *mem = kalloc();        // 分配新的物理页
    800019f0:	9bcff0ef          	jal	ra,80000bac <kalloc>
    800019f4:	8aaa                	mv	s5,a0
    if(mem == 0) return 0;      // 分配失败
    800019f6:	4901                	li	s2,0
    800019f8:	d959                	beqz	a0,8000198e <vmafault+0x3a>
    memset(mem, 0, PGSIZE);     // 初始化为0
    800019fa:	6605                	lui	a2,0x1
    800019fc:	4581                	li	a1,0
    800019fe:	b86ff0ef          	jal	ra,80000d84 <memset>
    pa = (uint64)mem;
    80001a02:	8956                	mv	s2,s5
  if(v->prot & PROT_READ)  perm |= PTE_R; // 读权限
    80001a04:	4c9c                	lw	a5,24(s1)
    80001a06:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;              // 用户页标志
    80001a0a:	4741                	li	a4,16
  if(v->prot & PROT_READ)  perm |= PTE_R; // 读权限
    80001a0c:	c291                	beqz	a3,80001a10 <vmafault+0xbc>
    80001a0e:	4749                	li	a4,18
  if(v->prot & PROT_WRITE) perm |= PTE_W; // 写权限
    80001a10:	8b89                	andi	a5,a5,2
    80001a12:	c399                	beqz	a5,80001a18 <vmafault+0xc4>
    80001a14:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    80001a18:	86ca                	mv	a3,s2
    80001a1a:	6605                	lui	a2,0x1
    80001a1c:	85ce                	mv	a1,s3
    80001a1e:	050a3503          	ld	a0,80(s4)
    80001a22:	ec2ff0ef          	jal	ra,800010e4 <mappages>
    80001a26:	cd09                	beqz	a0,80001a40 <vmafault+0xec>
    if(v->is_shm) kref_dec((void*)pa); // 减少共享页引用计数
    80001a28:	509c                	lw	a5,32(s1)
    80001a2a:	c791                	beqz	a5,80001a36 <vmafault+0xe2>
    80001a2c:	854a                	mv	a0,s2
    80001a2e:	80cff0ef          	jal	ra,80000a3a <kref_dec>
    return 0;
    80001a32:	4901                	li	s2,0
    80001a34:	bfa9                	j	8000198e <vmafault+0x3a>
    else kfree((void*)pa);            // 释放普通物理页
    80001a36:	854a                	mv	a0,s2
    80001a38:	846ff0ef          	jal	ra,80000a7e <kfree>
    return 0;
    80001a3c:	4901                	li	s2,0
    80001a3e:	bf81                	j	8000198e <vmafault+0x3a>
  vmstats_inc_lazy();            // 更新惰性分配统计信息
    80001a40:	366050ef          	jal	ra,80006da6 <vmstats_inc_lazy>
  return (uint64)pa;             // 返回物理页地址
    80001a44:	b7a9                	j	8000198e <vmafault+0x3a>
  if(v == 0) return 0;          // 不在任何 VMA 范围内
    80001a46:	4901                	li	s2,0
    80001a48:	b799                	j	8000198e <vmafault+0x3a>
    return 0;
    80001a4a:	4901                	li	s2,0
    80001a4c:	b789                	j	8000198e <vmafault+0x3a>
    80001a4e:	4901                	li	s2,0
    80001a50:	bf3d                	j	8000198e <vmafault+0x3a>

0000000080001a52 <proc_mapstacks>:
 * 参数：
 *   kpgtbl - 内核页表
 */
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001a52:	7139                	addi	sp,sp,-64
    80001a54:	fc06                	sd	ra,56(sp)
    80001a56:	f822                	sd	s0,48(sp)
    80001a58:	f426                	sd	s1,40(sp)
    80001a5a:	f04a                	sd	s2,32(sp)
    80001a5c:	ec4e                	sd	s3,24(sp)
    80001a5e:	e852                	sd	s4,16(sp)
    80001a60:	e456                	sd	s5,8(sp)
    80001a62:	e05a                	sd	s6,0(sp)
    80001a64:	0080                	addi	s0,sp,64
    80001a66:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a68:	0022f497          	auipc	s1,0x22f
    80001a6c:	3d848493          	addi	s1,s1,984 # 80230e40 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a70:	8b26                	mv	s6,s1
    80001a72:	00006a97          	auipc	s5,0x6
    80001a76:	58ea8a93          	addi	s5,s5,1422 # 80008000 <etext>
    80001a7a:	04000937          	lui	s2,0x4000
    80001a7e:	197d                	addi	s2,s2,-1
    80001a80:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a82:	0023fa17          	auipc	s4,0x23f
    80001a86:	dbea0a13          	addi	s4,s4,-578 # 80240840 <tickslock>
    char *pa = kalloc();
    80001a8a:	922ff0ef          	jal	ra,80000bac <kalloc>
    80001a8e:	862a                	mv	a2,a0
    if(pa == 0)
    80001a90:	c121                	beqz	a0,80001ad0 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001a92:	416485b3          	sub	a1,s1,s6
    80001a96:	858d                	srai	a1,a1,0x3
    80001a98:	000ab783          	ld	a5,0(s5)
    80001a9c:	02f585b3          	mul	a1,a1,a5
    80001aa0:	2585                	addiw	a1,a1,1
    80001aa2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001aa6:	4719                	li	a4,6
    80001aa8:	6685                	lui	a3,0x1
    80001aaa:	40b905b3          	sub	a1,s2,a1
    80001aae:	854e                	mv	a0,s3
    80001ab0:	ee4ff0ef          	jal	ra,80001194 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab4:	3e848493          	addi	s1,s1,1000
    80001ab8:	fd4499e3          	bne	s1,s4,80001a8a <proc_mapstacks+0x38>
  }
}
    80001abc:	70e2                	ld	ra,56(sp)
    80001abe:	7442                	ld	s0,48(sp)
    80001ac0:	74a2                	ld	s1,40(sp)
    80001ac2:	7902                	ld	s2,32(sp)
    80001ac4:	69e2                	ld	s3,24(sp)
    80001ac6:	6a42                	ld	s4,16(sp)
    80001ac8:	6aa2                	ld	s5,8(sp)
    80001aca:	6b02                	ld	s6,0(sp)
    80001acc:	6121                	addi	sp,sp,64
    80001ace:	8082                	ret
      panic("kalloc");
    80001ad0:	00006517          	auipc	a0,0x6
    80001ad4:	6a850513          	addi	a0,a0,1704 # 80008178 <digits+0x140>
    80001ad8:	cb3fe0ef          	jal	ra,8000078a <panic>

0000000080001adc <procinit>:
 * 2. 为每个进程分配锁并初始化状态为UNUSED
 * 3. 设置每个进程的内核栈地址
 */
void
procinit(void)
{
    80001adc:	7139                	addi	sp,sp,-64
    80001ade:	fc06                	sd	ra,56(sp)
    80001ae0:	f822                	sd	s0,48(sp)
    80001ae2:	f426                	sd	s1,40(sp)
    80001ae4:	f04a                	sd	s2,32(sp)
    80001ae6:	ec4e                	sd	s3,24(sp)
    80001ae8:	e852                	sd	s4,16(sp)
    80001aea:	e456                	sd	s5,8(sp)
    80001aec:	e05a                	sd	s6,0(sp)
    80001aee:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001af0:	00006597          	auipc	a1,0x6
    80001af4:	69058593          	addi	a1,a1,1680 # 80008180 <digits+0x148>
    80001af8:	0022f517          	auipc	a0,0x22f
    80001afc:	f1850513          	addi	a0,a0,-232 # 80230a10 <pid_lock>
    80001b00:	930ff0ef          	jal	ra,80000c30 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b04:	00006597          	auipc	a1,0x6
    80001b08:	68458593          	addi	a1,a1,1668 # 80008188 <digits+0x150>
    80001b0c:	0022f517          	auipc	a0,0x22f
    80001b10:	f1c50513          	addi	a0,a0,-228 # 80230a28 <wait_lock>
    80001b14:	91cff0ef          	jal	ra,80000c30 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b18:	0022f497          	auipc	s1,0x22f
    80001b1c:	32848493          	addi	s1,s1,808 # 80230e40 <proc>
      initlock(&p->lock, "proc");
    80001b20:	00006b17          	auipc	s6,0x6
    80001b24:	678b0b13          	addi	s6,s6,1656 # 80008198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001b28:	8aa6                	mv	s5,s1
    80001b2a:	00006a17          	auipc	s4,0x6
    80001b2e:	4d6a0a13          	addi	s4,s4,1238 # 80008000 <etext>
    80001b32:	04000937          	lui	s2,0x4000
    80001b36:	197d                	addi	s2,s2,-1
    80001b38:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b3a:	0023f997          	auipc	s3,0x23f
    80001b3e:	d0698993          	addi	s3,s3,-762 # 80240840 <tickslock>
      initlock(&p->lock, "proc");
    80001b42:	85da                	mv	a1,s6
    80001b44:	8526                	mv	a0,s1
    80001b46:	8eaff0ef          	jal	ra,80000c30 <initlock>
      p->state = UNUSED;
    80001b4a:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001b4e:	415487b3          	sub	a5,s1,s5
    80001b52:	878d                	srai	a5,a5,0x3
    80001b54:	000a3703          	ld	a4,0(s4)
    80001b58:	02e787b3          	mul	a5,a5,a4
    80001b5c:	2785                	addiw	a5,a5,1
    80001b5e:	00d7979b          	slliw	a5,a5,0xd
    80001b62:	40f907b3          	sub	a5,s2,a5
    80001b66:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b68:	3e848493          	addi	s1,s1,1000
    80001b6c:	fd349be3          	bne	s1,s3,80001b42 <procinit+0x66>
  }
}
    80001b70:	70e2                	ld	ra,56(sp)
    80001b72:	7442                	ld	s0,48(sp)
    80001b74:	74a2                	ld	s1,40(sp)
    80001b76:	7902                	ld	s2,32(sp)
    80001b78:	69e2                	ld	s3,24(sp)
    80001b7a:	6a42                	ld	s4,16(sp)
    80001b7c:	6aa2                	ld	s5,8(sp)
    80001b7e:	6b02                	ld	s6,0(sp)
    80001b80:	6121                	addi	sp,sp,64
    80001b82:	8082                	ret

0000000080001b84 <cpuid>:
 * 返回值：
 *   当前CPU的ID
 */
int
cpuid()
{
    80001b84:	1141                	addi	sp,sp,-16
    80001b86:	e422                	sd	s0,8(sp)
    80001b88:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b8a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b8c:	2501                	sext.w	a0,a0
    80001b8e:	6422                	ld	s0,8(sp)
    80001b90:	0141                	addi	sp,sp,16
    80001b92:	8082                	ret

0000000080001b94 <mycpu>:
 * 返回值：
 *   当前CPU的cpu结构体指针
 */
struct cpu*
mycpu(void)
{
    80001b94:	1141                	addi	sp,sp,-16
    80001b96:	e422                	sd	s0,8(sp)
    80001b98:	0800                	addi	s0,sp,16
    80001b9a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b9c:	2781                	sext.w	a5,a5
    80001b9e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001ba0:	0022f517          	auipc	a0,0x22f
    80001ba4:	ea050513          	addi	a0,a0,-352 # 80230a40 <cpus>
    80001ba8:	953e                	add	a0,a0,a5
    80001baa:	6422                	ld	s0,8(sp)
    80001bac:	0141                	addi	sp,sp,16
    80001bae:	8082                	ret

0000000080001bb0 <myproc>:
 * 返回值：
 *   当前进程的proc结构体指针，如果没有则返回0
 */
struct proc*
myproc(void)
{
    80001bb0:	1101                	addi	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	1000                	addi	s0,sp,32
  push_off();
    80001bba:	8b6ff0ef          	jal	ra,80000c70 <push_off>
    80001bbe:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001bc0:	2781                	sext.w	a5,a5
    80001bc2:	079e                	slli	a5,a5,0x7
    80001bc4:	0022f717          	auipc	a4,0x22f
    80001bc8:	e4c70713          	addi	a4,a4,-436 # 80230a10 <pid_lock>
    80001bcc:	97ba                	add	a5,a5,a4
    80001bce:	7b84                	ld	s1,48(a5)
  pop_off();
    80001bd0:	924ff0ef          	jal	ra,80000cf4 <pop_off>
  return p;
}
    80001bd4:	8526                	mv	a0,s1
    80001bd6:	60e2                	ld	ra,24(sp)
    80001bd8:	6442                	ld	s0,16(sp)
    80001bda:	64a2                	ld	s1,8(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret

0000000080001be0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001be0:	7179                	addi	sp,sp,-48
    80001be2:	f406                	sd	ra,40(sp)
    80001be4:	f022                	sd	s0,32(sp)
    80001be6:	ec26                	sd	s1,24(sp)
    80001be8:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001bea:	fc7ff0ef          	jal	ra,80001bb0 <myproc>
    80001bee:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001bf0:	958ff0ef          	jal	ra,80000d48 <release>

  if (first) {
    80001bf4:	00007797          	auipc	a5,0x7
    80001bf8:	c9c7a783          	lw	a5,-868(a5) # 80008890 <first.1>
    80001bfc:	cf8d                	beqz	a5,80001c36 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001bfe:	4505                	li	a0,1
    80001c00:	5b4020ef          	jal	ra,800041b4 <fsinit>

    first = 0;
    80001c04:	00007797          	auipc	a5,0x7
    80001c08:	c807a623          	sw	zero,-884(a5) # 80008890 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001c0c:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001c10:	00006517          	auipc	a0,0x6
    80001c14:	59050513          	addi	a0,a0,1424 # 800081a0 <digits+0x168>
    80001c18:	fca43823          	sd	a0,-48(s0)
    80001c1c:	fc043c23          	sd	zero,-40(s0)
    80001c20:	fd040593          	addi	a1,s0,-48
    80001c24:	638030ef          	jal	ra,8000525c <kexec>
    80001c28:	6cbc                	ld	a5,88(s1)
    80001c2a:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001c2c:	6cbc                	ld	a5,88(s1)
    80001c2e:	7bb8                	ld	a4,112(a5)
    80001c30:	57fd                	li	a5,-1
    80001c32:	02f70d63          	beq	a4,a5,80001c6c <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001c36:	5ab000ef          	jal	ra,800029e0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c3a:	68a8                	ld	a0,80(s1)
    80001c3c:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c3e:	04000737          	lui	a4,0x4000
    80001c42:	00005797          	auipc	a5,0x5
    80001c46:	45a78793          	addi	a5,a5,1114 # 8000709c <userret>
    80001c4a:	00005697          	auipc	a3,0x5
    80001c4e:	3b668693          	addi	a3,a3,950 # 80007000 <_trampoline>
    80001c52:	8f95                	sub	a5,a5,a3
    80001c54:	177d                	addi	a4,a4,-1
    80001c56:	0732                	slli	a4,a4,0xc
    80001c58:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c5a:	577d                	li	a4,-1
    80001c5c:	177e                	slli	a4,a4,0x3f
    80001c5e:	8d59                	or	a0,a0,a4
    80001c60:	9782                	jalr	a5
}
    80001c62:	70a2                	ld	ra,40(sp)
    80001c64:	7402                	ld	s0,32(sp)
    80001c66:	64e2                	ld	s1,24(sp)
    80001c68:	6145                	addi	sp,sp,48
    80001c6a:	8082                	ret
      panic("exec");
    80001c6c:	00006517          	auipc	a0,0x6
    80001c70:	53c50513          	addi	a0,a0,1340 # 800081a8 <digits+0x170>
    80001c74:	b17fe0ef          	jal	ra,8000078a <panic>

0000000080001c78 <allocpid>:
{
    80001c78:	1101                	addi	sp,sp,-32
    80001c7a:	ec06                	sd	ra,24(sp)
    80001c7c:	e822                	sd	s0,16(sp)
    80001c7e:	e426                	sd	s1,8(sp)
    80001c80:	e04a                	sd	s2,0(sp)
    80001c82:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c84:	0022f917          	auipc	s2,0x22f
    80001c88:	d8c90913          	addi	s2,s2,-628 # 80230a10 <pid_lock>
    80001c8c:	854a                	mv	a0,s2
    80001c8e:	822ff0ef          	jal	ra,80000cb0 <acquire>
  pid = nextpid;
    80001c92:	00007797          	auipc	a5,0x7
    80001c96:	c0278793          	addi	a5,a5,-1022 # 80008894 <nextpid>
    80001c9a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c9c:	0014871b          	addiw	a4,s1,1
    80001ca0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ca2:	854a                	mv	a0,s2
    80001ca4:	8a4ff0ef          	jal	ra,80000d48 <release>
}
    80001ca8:	8526                	mv	a0,s1
    80001caa:	60e2                	ld	ra,24(sp)
    80001cac:	6442                	ld	s0,16(sp)
    80001cae:	64a2                	ld	s1,8(sp)
    80001cb0:	6902                	ld	s2,0(sp)
    80001cb2:	6105                	addi	sp,sp,32
    80001cb4:	8082                	ret

0000000080001cb6 <delete_shm_from_vmas>:
delete_shm_from_vmas(struct vma *vmas){
    80001cb6:	7139                	addi	sp,sp,-64
    80001cb8:	fc06                	sd	ra,56(sp)
    80001cba:	f822                	sd	s0,48(sp)
    80001cbc:	f426                	sd	s1,40(sp)
    80001cbe:	f04a                	sd	s2,32(sp)
    80001cc0:	ec4e                	sd	s3,24(sp)
    80001cc2:	e852                	sd	s4,16(sp)
    80001cc4:	e456                	sd	s5,8(sp)
    80001cc6:	0080                	addi	s0,sp,64
    80001cc8:	8a2a                	mv	s4,a0
    80001cca:	84aa                	mv	s1,a0
  for(int i = 0; i < NVMA; i++){
    80001ccc:	4901                	li	s2,0
    80001cce:	02850a93          	addi	s5,a0,40
    80001cd2:	49c1                	li	s3,16
    80001cd4:	a025                	j	80001cfc <delete_shm_from_vmas+0x46>
    for(int j = 0; j < i; j++){
    80001cd6:	02878793          	addi	a5,a5,40
    80001cda:	00d78a63          	beq	a5,a3,80001cee <delete_shm_from_vmas+0x38>
      if(vmas[j].used && vmas[j].is_shm && vmas[j].shm_key == key){
    80001cde:	4398                	lw	a4,0(a5)
    80001ce0:	db7d                	beqz	a4,80001cd6 <delete_shm_from_vmas+0x20>
    80001ce2:	5398                	lw	a4,32(a5)
    80001ce4:	db6d                	beqz	a4,80001cd6 <delete_shm_from_vmas+0x20>
    80001ce6:	53d8                	lw	a4,36(a5)
    80001ce8:	fea717e3          	bne	a4,a0,80001cd6 <delete_shm_from_vmas+0x20>
    80001cec:	a019                	j	80001cf2 <delete_shm_from_vmas+0x3c>
    shm_put(key);
    80001cee:	227040ef          	jal	ra,80006714 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001cf2:	2905                	addiw	s2,s2,1
    80001cf4:	02848493          	addi	s1,s1,40
    80001cf8:	03390563          	beq	s2,s3,80001d22 <delete_shm_from_vmas+0x6c>
    if(!vmas[i].used || !vmas[i].is_shm) continue;
    80001cfc:	409c                	lw	a5,0(s1)
    80001cfe:	dbf5                	beqz	a5,80001cf2 <delete_shm_from_vmas+0x3c>
    80001d00:	509c                	lw	a5,32(s1)
    80001d02:	dbe5                	beqz	a5,80001cf2 <delete_shm_from_vmas+0x3c>
    int key = vmas[i].shm_key;
    80001d04:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d06:	ff2054e3          	blez	s2,80001cee <delete_shm_from_vmas+0x38>
    80001d0a:	fff9069b          	addiw	a3,s2,-1
    80001d0e:	02069793          	slli	a5,a3,0x20
    80001d12:	9381                	srli	a5,a5,0x20
    80001d14:	00279693          	slli	a3,a5,0x2
    80001d18:	96be                	add	a3,a3,a5
    80001d1a:	068e                	slli	a3,a3,0x3
    80001d1c:	96d6                	add	a3,a3,s5
    80001d1e:	87d2                	mv	a5,s4
    80001d20:	bf7d                	j	80001cde <delete_shm_from_vmas+0x28>
}
    80001d22:	70e2                	ld	ra,56(sp)
    80001d24:	7442                	ld	s0,48(sp)
    80001d26:	74a2                	ld	s1,40(sp)
    80001d28:	7902                	ld	s2,32(sp)
    80001d2a:	69e2                	ld	s3,24(sp)
    80001d2c:	6a42                	ld	s4,16(sp)
    80001d2e:	6aa2                	ld	s5,8(sp)
    80001d30:	6121                	addi	sp,sp,64
    80001d32:	8082                	ret

0000000080001d34 <delete_shm_from_proc>:
delete_shm_from_proc(struct proc *p){
    80001d34:	7139                	addi	sp,sp,-64
    80001d36:	fc06                	sd	ra,56(sp)
    80001d38:	f822                	sd	s0,48(sp)
    80001d3a:	f426                	sd	s1,40(sp)
    80001d3c:	f04a                	sd	s2,32(sp)
    80001d3e:	ec4e                	sd	s3,24(sp)
    80001d40:	e852                	sd	s4,16(sp)
    80001d42:	e456                	sd	s5,8(sp)
    80001d44:	0080                	addi	s0,sp,64
  for(int i = 0; i < NVMA; i++){
    80001d46:	16850a93          	addi	s5,a0,360
delete_shm_from_proc(struct proc *p){
    80001d4a:	84d6                	mv	s1,s5
  for(int i = 0; i < NVMA; i++){
    80001d4c:	4901                	li	s2,0
    80001d4e:	19050a13          	addi	s4,a0,400
    80001d52:	49c1                	li	s3,16
    80001d54:	a025                	j	80001d7c <delete_shm_from_proc+0x48>
    for(int j = 0; j < i; j++){
    80001d56:	02878793          	addi	a5,a5,40
    80001d5a:	00d78a63          	beq	a5,a3,80001d6e <delete_shm_from_proc+0x3a>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001d5e:	4398                	lw	a4,0(a5)
    80001d60:	db7d                	beqz	a4,80001d56 <delete_shm_from_proc+0x22>
    80001d62:	5398                	lw	a4,32(a5)
    80001d64:	db6d                	beqz	a4,80001d56 <delete_shm_from_proc+0x22>
    80001d66:	53d8                	lw	a4,36(a5)
    80001d68:	fea717e3          	bne	a4,a0,80001d56 <delete_shm_from_proc+0x22>
    80001d6c:	a019                	j	80001d72 <delete_shm_from_proc+0x3e>
    shm_put(key);
    80001d6e:	1a7040ef          	jal	ra,80006714 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001d72:	2905                	addiw	s2,s2,1
    80001d74:	02848493          	addi	s1,s1,40
    80001d78:	03390563          	beq	s2,s3,80001da2 <delete_shm_from_proc+0x6e>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001d7c:	409c                	lw	a5,0(s1)
    80001d7e:	dbf5                	beqz	a5,80001d72 <delete_shm_from_proc+0x3e>
    80001d80:	509c                	lw	a5,32(s1)
    80001d82:	dbe5                	beqz	a5,80001d72 <delete_shm_from_proc+0x3e>
    int key = p->vmas[i].shm_key;
    80001d84:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d86:	ff2054e3          	blez	s2,80001d6e <delete_shm_from_proc+0x3a>
    80001d8a:	fff9069b          	addiw	a3,s2,-1
    80001d8e:	02069793          	slli	a5,a3,0x20
    80001d92:	9381                	srli	a5,a5,0x20
    80001d94:	00279693          	slli	a3,a5,0x2
    80001d98:	96be                	add	a3,a3,a5
    80001d9a:	068e                	slli	a3,a3,0x3
    80001d9c:	96d2                	add	a3,a3,s4
    80001d9e:	87d6                	mv	a5,s5
    80001da0:	bf7d                	j	80001d5e <delete_shm_from_proc+0x2a>
}
    80001da2:	70e2                	ld	ra,56(sp)
    80001da4:	7442                	ld	s0,48(sp)
    80001da6:	74a2                	ld	s1,40(sp)
    80001da8:	7902                	ld	s2,32(sp)
    80001daa:	69e2                	ld	s3,24(sp)
    80001dac:	6a42                	ld	s4,16(sp)
    80001dae:	6aa2                	ld	s5,8(sp)
    80001db0:	6121                	addi	sp,sp,64
    80001db2:	8082                	ret

0000000080001db4 <vma_release_all>:
{
    80001db4:	7139                	addi	sp,sp,-64
    80001db6:	fc06                	sd	ra,56(sp)
    80001db8:	f822                	sd	s0,48(sp)
    80001dba:	f426                	sd	s1,40(sp)
    80001dbc:	f04a                	sd	s2,32(sp)
    80001dbe:	ec4e                	sd	s3,24(sp)
    80001dc0:	e852                	sd	s4,16(sp)
    80001dc2:	e456                	sd	s5,8(sp)
    80001dc4:	e05a                	sd	s6,0(sp)
    80001dc6:	0080                	addi	s0,sp,64
    80001dc8:	8b2a                	mv	s6,a0
  for(int i = 0; i < NVMA; i++){
    80001dca:	16850493          	addi	s1,a0,360
    80001dce:	3e850a13          	addi	s4,a0,1000
{
    80001dd2:	8926                	mv	s2,s1
    80001dd4:	a029                	j	80001dde <vma_release_all+0x2a>
  for(int i = 0; i < NVMA; i++){
    80001dd6:	02890913          	addi	s2,s2,40
    80001dda:	03490663          	beq	s2,s4,80001e06 <vma_release_all+0x52>
    if(!v->used) continue;
    80001dde:	00092783          	lw	a5,0(s2)
    80001de2:	dbf5                	beqz	a5,80001dd6 <vma_release_all+0x22>
    uint64 start = v->start;
    80001de4:	00893583          	ld	a1,8(s2)
    uint64 end   = v->end;
    80001de8:	01093603          	ld	a2,16(s2)
    if(end <= start) continue;
    80001dec:	fec5f5e3          	bgeu	a1,a2,80001dd6 <vma_release_all+0x22>
    int do_free = (v->is_shm ? 0 : 1);
    80001df0:	02092683          	lw	a3,32(s2)
    uint64 npages = (end - start) / PGSIZE;
    80001df4:	8e0d                	sub	a2,a2,a1
    uvmunmap(p->pagetable, start, npages, do_free);
    80001df6:	0016b693          	seqz	a3,a3
    80001dfa:	8231                	srli	a2,a2,0xc
    80001dfc:	050b3503          	ld	a0,80(s6)
    80001e00:	cb0ff0ef          	jal	ra,800012b0 <uvmunmap>
    80001e04:	bfc9                	j	80001dd6 <vma_release_all+0x22>
    80001e06:	8926                	mv	s2,s1
  for(int i = 0; i < NVMA; i++){
    80001e08:	4981                	li	s3,0
    80001e0a:	190b0b13          	addi	s6,s6,400
    80001e0e:	4ac1                	li	s5,16
    80001e10:	a891                	j	80001e64 <vma_release_all+0xb0>
    for(int j = 0; j < i; j++){
    80001e12:	02878793          	addi	a5,a5,40
    80001e16:	04d78063          	beq	a5,a3,80001e56 <vma_release_all+0xa2>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001e1a:	4398                	lw	a4,0(a5)
    80001e1c:	db7d                	beqz	a4,80001e12 <vma_release_all+0x5e>
    80001e1e:	5398                	lw	a4,32(a5)
    80001e20:	db6d                	beqz	a4,80001e12 <vma_release_all+0x5e>
    80001e22:	53d8                	lw	a4,36(a5)
    80001e24:	fea717e3          	bne	a4,a0,80001e12 <vma_release_all+0x5e>
    80001e28:	a80d                	j	80001e5a <vma_release_all+0xa6>
      p->vmas[i].shm_key = -1;
    80001e2a:	577d                	li	a4,-1
    80001e2c:	a029                	j	80001e36 <vma_release_all+0x82>
  for(int i = 0; i < NVMA; i++){
    80001e2e:	02848493          	addi	s1,s1,40
    80001e32:	05448f63          	beq	s1,s4,80001e90 <vma_release_all+0xdc>
    if(p->vmas[i].used){
    80001e36:	409c                	lw	a5,0(s1)
    80001e38:	dbfd                	beqz	a5,80001e2e <vma_release_all+0x7a>
      p->vmas[i].used = 0;
    80001e3a:	0004a023          	sw	zero,0(s1)
      p->vmas[i].is_shm = 0;
    80001e3e:	0204a023          	sw	zero,32(s1)
      p->vmas[i].shm_key = -1;
    80001e42:	d0d8                	sw	a4,36(s1)
      p->vmas[i].start = p->vmas[i].end = 0;
    80001e44:	0004b823          	sd	zero,16(s1)
    80001e48:	0004b423          	sd	zero,8(s1)
      p->vmas[i].prot = p->vmas[i].flags = 0;
    80001e4c:	0004ae23          	sw	zero,28(s1)
    80001e50:	0004ac23          	sw	zero,24(s1)
    80001e54:	bfe9                	j	80001e2e <vma_release_all+0x7a>
    shm_put(key);
    80001e56:	0bf040ef          	jal	ra,80006714 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001e5a:	2985                	addiw	s3,s3,1
    80001e5c:	02890913          	addi	s2,s2,40
    80001e60:	fd5985e3          	beq	s3,s5,80001e2a <vma_release_all+0x76>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001e64:	00092783          	lw	a5,0(s2)
    80001e68:	dbed                	beqz	a5,80001e5a <vma_release_all+0xa6>
    80001e6a:	02092783          	lw	a5,32(s2)
    80001e6e:	d7f5                	beqz	a5,80001e5a <vma_release_all+0xa6>
    int key = p->vmas[i].shm_key;
    80001e70:	02492503          	lw	a0,36(s2)
    for(int j = 0; j < i; j++){
    80001e74:	ff3051e3          	blez	s3,80001e56 <vma_release_all+0xa2>
    80001e78:	fff9869b          	addiw	a3,s3,-1
    80001e7c:	02069793          	slli	a5,a3,0x20
    80001e80:	9381                	srli	a5,a5,0x20
    80001e82:	00279693          	slli	a3,a5,0x2
    80001e86:	96be                	add	a3,a3,a5
    80001e88:	068e                	slli	a3,a3,0x3
    80001e8a:	96da                	add	a3,a3,s6
    80001e8c:	87a6                	mv	a5,s1
    80001e8e:	b771                	j	80001e1a <vma_release_all+0x66>
}
    80001e90:	70e2                	ld	ra,56(sp)
    80001e92:	7442                	ld	s0,48(sp)
    80001e94:	74a2                	ld	s1,40(sp)
    80001e96:	7902                	ld	s2,32(sp)
    80001e98:	69e2                	ld	s3,24(sp)
    80001e9a:	6a42                	ld	s4,16(sp)
    80001e9c:	6aa2                	ld	s5,8(sp)
    80001e9e:	6b02                	ld	s6,0(sp)
    80001ea0:	6121                	addi	sp,sp,64
    80001ea2:	8082                	ret

0000000080001ea4 <proc_pagetable>:
{
    80001ea4:	1101                	addi	sp,sp,-32
    80001ea6:	ec06                	sd	ra,24(sp)
    80001ea8:	e822                	sd	s0,16(sp)
    80001eaa:	e426                	sd	s1,8(sp)
    80001eac:	e04a                	sd	s2,0(sp)
    80001eae:	1000                	addi	s0,sp,32
    80001eb0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001eb2:	bd8ff0ef          	jal	ra,8000128a <uvmcreate>
    80001eb6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001eb8:	cd05                	beqz	a0,80001ef0 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001eba:	4729                	li	a4,10
    80001ebc:	00005697          	auipc	a3,0x5
    80001ec0:	14468693          	addi	a3,a3,324 # 80007000 <_trampoline>
    80001ec4:	6605                	lui	a2,0x1
    80001ec6:	040005b7          	lui	a1,0x4000
    80001eca:	15fd                	addi	a1,a1,-1
    80001ecc:	05b2                	slli	a1,a1,0xc
    80001ece:	a16ff0ef          	jal	ra,800010e4 <mappages>
    80001ed2:	02054663          	bltz	a0,80001efe <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ed6:	4719                	li	a4,6
    80001ed8:	05893683          	ld	a3,88(s2)
    80001edc:	6605                	lui	a2,0x1
    80001ede:	020005b7          	lui	a1,0x2000
    80001ee2:	15fd                	addi	a1,a1,-1
    80001ee4:	05b6                	slli	a1,a1,0xd
    80001ee6:	8526                	mv	a0,s1
    80001ee8:	9fcff0ef          	jal	ra,800010e4 <mappages>
    80001eec:	00054f63          	bltz	a0,80001f0a <proc_pagetable+0x66>
}
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	60e2                	ld	ra,24(sp)
    80001ef4:	6442                	ld	s0,16(sp)
    80001ef6:	64a2                	ld	s1,8(sp)
    80001ef8:	6902                	ld	s2,0(sp)
    80001efa:	6105                	addi	sp,sp,32
    80001efc:	8082                	ret
    uvmfree(pagetable, 0);
    80001efe:	4581                	li	a1,0
    80001f00:	8526                	mv	a0,s1
    80001f02:	d66ff0ef          	jal	ra,80001468 <uvmfree>
    return 0;
    80001f06:	4481                	li	s1,0
    80001f08:	b7e5                	j	80001ef0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f0a:	4681                	li	a3,0
    80001f0c:	4605                	li	a2,1
    80001f0e:	040005b7          	lui	a1,0x4000
    80001f12:	15fd                	addi	a1,a1,-1
    80001f14:	05b2                	slli	a1,a1,0xc
    80001f16:	8526                	mv	a0,s1
    80001f18:	b98ff0ef          	jal	ra,800012b0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f1c:	4581                	li	a1,0
    80001f1e:	8526                	mv	a0,s1
    80001f20:	d48ff0ef          	jal	ra,80001468 <uvmfree>
    return 0;
    80001f24:	4481                	li	s1,0
    80001f26:	b7e9                	j	80001ef0 <proc_pagetable+0x4c>

0000000080001f28 <vma_unmap_pagetable>:
{
    80001f28:	7179                	addi	sp,sp,-48
    80001f2a:	f406                	sd	ra,40(sp)
    80001f2c:	f022                	sd	s0,32(sp)
    80001f2e:	ec26                	sd	s1,24(sp)
    80001f30:	e84a                	sd	s2,16(sp)
    80001f32:	e44e                	sd	s3,8(sp)
    80001f34:	1800                	addi	s0,sp,48
    80001f36:	89aa                	mv	s3,a0
    80001f38:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001f3a:	28058913          	addi	s2,a1,640 # 4000280 <_entry-0x7bfffd80>
    80001f3e:	a811                	j	80001f52 <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001f40:	4685                	li	a3,1
    80001f42:	8231                	srli	a2,a2,0xc
    80001f44:	854e                	mv	a0,s3
    80001f46:	b6aff0ef          	jal	ra,800012b0 <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001f4a:	02848493          	addi	s1,s1,40
    80001f4e:	01248b63          	beq	s1,s2,80001f64 <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001f52:	409c                	lw	a5,0(s1)
    80001f54:	dbfd                	beqz	a5,80001f4a <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001f56:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001f58:	689c                	ld	a5,16(s1)
    80001f5a:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001f5e:	feb786e3          	beq	a5,a1,80001f4a <vma_unmap_pagetable+0x22>
    80001f62:	bff9                	j	80001f40 <vma_unmap_pagetable+0x18>
}
    80001f64:	70a2                	ld	ra,40(sp)
    80001f66:	7402                	ld	s0,32(sp)
    80001f68:	64e2                	ld	s1,24(sp)
    80001f6a:	6942                	ld	s2,16(sp)
    80001f6c:	69a2                	ld	s3,8(sp)
    80001f6e:	6145                	addi	sp,sp,48
    80001f70:	8082                	ret

0000000080001f72 <proc_freepagetable>:
{
    80001f72:	1101                	addi	sp,sp,-32
    80001f74:	ec06                	sd	ra,24(sp)
    80001f76:	e822                	sd	s0,16(sp)
    80001f78:	e426                	sd	s1,8(sp)
    80001f7a:	e04a                	sd	s2,0(sp)
    80001f7c:	1000                	addi	s0,sp,32
    80001f7e:	84aa                	mv	s1,a0
    80001f80:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f82:	4681                	li	a3,0
    80001f84:	4605                	li	a2,1
    80001f86:	040005b7          	lui	a1,0x4000
    80001f8a:	15fd                	addi	a1,a1,-1
    80001f8c:	05b2                	slli	a1,a1,0xc
    80001f8e:	b22ff0ef          	jal	ra,800012b0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f92:	4681                	li	a3,0
    80001f94:	4605                	li	a2,1
    80001f96:	020005b7          	lui	a1,0x2000
    80001f9a:	15fd                	addi	a1,a1,-1
    80001f9c:	05b6                	slli	a1,a1,0xd
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	b10ff0ef          	jal	ra,800012b0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001fa4:	85ca                	mv	a1,s2
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	cc0ff0ef          	jal	ra,80001468 <uvmfree>
}
    80001fac:	60e2                	ld	ra,24(sp)
    80001fae:	6442                	ld	s0,16(sp)
    80001fb0:	64a2                	ld	s1,8(sp)
    80001fb2:	6902                	ld	s2,0(sp)
    80001fb4:	6105                	addi	sp,sp,32
    80001fb6:	8082                	ret

0000000080001fb8 <freeproc>:
{
    80001fb8:	1101                	addi	sp,sp,-32
    80001fba:	ec06                	sd	ra,24(sp)
    80001fbc:	e822                	sd	s0,16(sp)
    80001fbe:	e426                	sd	s1,8(sp)
    80001fc0:	e04a                	sd	s2,0(sp)
    80001fc2:	1000                	addi	s0,sp,32
    80001fc4:	84aa                	mv	s1,a0
  vma_release_all(p);
    80001fc6:	defff0ef          	jal	ra,80001db4 <vma_release_all>
  if(p->trapframe)
    80001fca:	6ca8                	ld	a0,88(s1)
    80001fcc:	c119                	beqz	a0,80001fd2 <freeproc+0x1a>
    kfree((void*)p->trapframe);
    80001fce:	ab1fe0ef          	jal	ra,80000a7e <kfree>
  p->trapframe = 0;
    80001fd2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001fd6:	68a8                	ld	a0,80(s1)
    80001fd8:	c105                	beqz	a0,80001ff8 <freeproc+0x40>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001fda:	16848913          	addi	s2,s1,360
    80001fde:	85ca                	mv	a1,s2
    80001fe0:	f49ff0ef          	jal	ra,80001f28 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001fe4:	28000613          	li	a2,640
    80001fe8:	4581                	li	a1,0
    80001fea:	854a                	mv	a0,s2
    80001fec:	d99fe0ef          	jal	ra,80000d84 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001ff0:	64ac                	ld	a1,72(s1)
    80001ff2:	68a8                	ld	a0,80(s1)
    80001ff4:	f7fff0ef          	jal	ra,80001f72 <proc_freepagetable>
  delete_shm_from_proc(p);
    80001ff8:	8526                	mv	a0,s1
    80001ffa:	d3bff0ef          	jal	ra,80001d34 <delete_shm_from_proc>
  p->pagetable = 0;
    80001ffe:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002002:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002006:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000200a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000200e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002012:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002016:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000201a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000201e:	0004ac23          	sw	zero,24(s1)
}
    80002022:	60e2                	ld	ra,24(sp)
    80002024:	6442                	ld	s0,16(sp)
    80002026:	64a2                	ld	s1,8(sp)
    80002028:	6902                	ld	s2,0(sp)
    8000202a:	6105                	addi	sp,sp,32
    8000202c:	8082                	ret

000000008000202e <allocproc>:
{
    8000202e:	1101                	addi	sp,sp,-32
    80002030:	ec06                	sd	ra,24(sp)
    80002032:	e822                	sd	s0,16(sp)
    80002034:	e426                	sd	s1,8(sp)
    80002036:	e04a                	sd	s2,0(sp)
    80002038:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000203a:	0022f497          	auipc	s1,0x22f
    8000203e:	e0648493          	addi	s1,s1,-506 # 80230e40 <proc>
    80002042:	0023e917          	auipc	s2,0x23e
    80002046:	7fe90913          	addi	s2,s2,2046 # 80240840 <tickslock>
    acquire(&p->lock);
    8000204a:	8526                	mv	a0,s1
    8000204c:	c65fe0ef          	jal	ra,80000cb0 <acquire>
    if(p->state == UNUSED) {
    80002050:	4c9c                	lw	a5,24(s1)
    80002052:	cb91                	beqz	a5,80002066 <allocproc+0x38>
      release(&p->lock);
    80002054:	8526                	mv	a0,s1
    80002056:	cf3fe0ef          	jal	ra,80000d48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000205a:	3e848493          	addi	s1,s1,1000
    8000205e:	ff2496e3          	bne	s1,s2,8000204a <allocproc+0x1c>
  return 0;
    80002062:	4481                	li	s1,0
    80002064:	a089                	j	800020a6 <allocproc+0x78>
  p->pid = allocpid();
    80002066:	c13ff0ef          	jal	ra,80001c78 <allocpid>
    8000206a:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000206c:	4785                	li	a5,1
    8000206e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002070:	b3dfe0ef          	jal	ra,80000bac <kalloc>
    80002074:	892a                	mv	s2,a0
    80002076:	eca8                	sd	a0,88(s1)
    80002078:	cd15                	beqz	a0,800020b4 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    8000207a:	8526                	mv	a0,s1
    8000207c:	e29ff0ef          	jal	ra,80001ea4 <proc_pagetable>
    80002080:	892a                	mv	s2,a0
    80002082:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002084:	c121                	beqz	a0,800020c4 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80002086:	07000613          	li	a2,112
    8000208a:	4581                	li	a1,0
    8000208c:	06048513          	addi	a0,s1,96
    80002090:	cf5fe0ef          	jal	ra,80000d84 <memset>
  p->context.ra = (uint64)forkret;
    80002094:	00000797          	auipc	a5,0x0
    80002098:	b4c78793          	addi	a5,a5,-1204 # 80001be0 <forkret>
    8000209c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000209e:	60bc                	ld	a5,64(s1)
    800020a0:	6705                	lui	a4,0x1
    800020a2:	97ba                	add	a5,a5,a4
    800020a4:	f4bc                	sd	a5,104(s1)
}
    800020a6:	8526                	mv	a0,s1
    800020a8:	60e2                	ld	ra,24(sp)
    800020aa:	6442                	ld	s0,16(sp)
    800020ac:	64a2                	ld	s1,8(sp)
    800020ae:	6902                	ld	s2,0(sp)
    800020b0:	6105                	addi	sp,sp,32
    800020b2:	8082                	ret
    freeproc(p);
    800020b4:	8526                	mv	a0,s1
    800020b6:	f03ff0ef          	jal	ra,80001fb8 <freeproc>
    release(&p->lock);
    800020ba:	8526                	mv	a0,s1
    800020bc:	c8dfe0ef          	jal	ra,80000d48 <release>
    return 0;
    800020c0:	84ca                	mv	s1,s2
    800020c2:	b7d5                	j	800020a6 <allocproc+0x78>
    freeproc(p);
    800020c4:	8526                	mv	a0,s1
    800020c6:	ef3ff0ef          	jal	ra,80001fb8 <freeproc>
    release(&p->lock);
    800020ca:	8526                	mv	a0,s1
    800020cc:	c7dfe0ef          	jal	ra,80000d48 <release>
    return 0;
    800020d0:	84ca                	mv	s1,s2
    800020d2:	bfd1                	j	800020a6 <allocproc+0x78>

00000000800020d4 <userinit>:
{
    800020d4:	1101                	addi	sp,sp,-32
    800020d6:	ec06                	sd	ra,24(sp)
    800020d8:	e822                	sd	s0,16(sp)
    800020da:	e426                	sd	s1,8(sp)
    800020dc:	1000                	addi	s0,sp,32
  p = allocproc();
    800020de:	f51ff0ef          	jal	ra,8000202e <allocproc>
    800020e2:	84aa                	mv	s1,a0
  initproc = p;
    800020e4:	00006797          	auipc	a5,0x6
    800020e8:	7ca7be23          	sd	a0,2012(a5) # 800088c0 <initproc>
  p->cwd = namei("/");
    800020ec:	00006517          	auipc	a0,0x6
    800020f0:	0c450513          	addi	a0,a0,196 # 800081b0 <digits+0x178>
    800020f4:	5be020ef          	jal	ra,800046b2 <namei>
    800020f8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800020fc:	478d                	li	a5,3
    800020fe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	c47fe0ef          	jal	ra,80000d48 <release>
}
    80002106:	60e2                	ld	ra,24(sp)
    80002108:	6442                	ld	s0,16(sp)
    8000210a:	64a2                	ld	s1,8(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <growproc>:
{
    80002110:	1101                	addi	sp,sp,-32
    80002112:	ec06                	sd	ra,24(sp)
    80002114:	e822                	sd	s0,16(sp)
    80002116:	e426                	sd	s1,8(sp)
    80002118:	e04a                	sd	s2,0(sp)
    8000211a:	1000                	addi	s0,sp,32
    8000211c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000211e:	a93ff0ef          	jal	ra,80001bb0 <myproc>
    80002122:	892a                	mv	s2,a0
  sz = p->sz;
    80002124:	652c                	ld	a1,72(a0)
  if(n > 0){
    80002126:	02905963          	blez	s1,80002158 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    8000212a:	00b48633          	add	a2,s1,a1
    8000212e:	020007b7          	lui	a5,0x2000
    80002132:	17fd                	addi	a5,a5,-1
    80002134:	07b6                	slli	a5,a5,0xd
    80002136:	02c7ea63          	bltu	a5,a2,8000216a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000213a:	4691                	li	a3,4
    8000213c:	6928                	ld	a0,80(a0)
    8000213e:	a32ff0ef          	jal	ra,80001370 <uvmalloc>
    80002142:	85aa                	mv	a1,a0
    80002144:	c50d                	beqz	a0,8000216e <growproc+0x5e>
  p->sz = sz;
    80002146:	04b93423          	sd	a1,72(s2)
  return 0;
    8000214a:	4501                	li	a0,0
}
    8000214c:	60e2                	ld	ra,24(sp)
    8000214e:	6442                	ld	s0,16(sp)
    80002150:	64a2                	ld	s1,8(sp)
    80002152:	6902                	ld	s2,0(sp)
    80002154:	6105                	addi	sp,sp,32
    80002156:	8082                	ret
  } else if(n < 0){
    80002158:	fe04d7e3          	bgez	s1,80002146 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000215c:	00b48633          	add	a2,s1,a1
    80002160:	6928                	ld	a0,80(a0)
    80002162:	9caff0ef          	jal	ra,8000132c <uvmdealloc>
    80002166:	85aa                	mv	a1,a0
    80002168:	bff9                	j	80002146 <growproc+0x36>
      return -1;
    8000216a:	557d                	li	a0,-1
    8000216c:	b7c5                	j	8000214c <growproc+0x3c>
      return -1;
    8000216e:	557d                	li	a0,-1
    80002170:	bff1                	j	8000214c <growproc+0x3c>

0000000080002172 <kfork>:
{
    80002172:	715d                	addi	sp,sp,-80
    80002174:	e486                	sd	ra,72(sp)
    80002176:	e0a2                	sd	s0,64(sp)
    80002178:	fc26                	sd	s1,56(sp)
    8000217a:	f84a                	sd	s2,48(sp)
    8000217c:	f44e                	sd	s3,40(sp)
    8000217e:	f052                	sd	s4,32(sp)
    80002180:	ec56                	sd	s5,24(sp)
    80002182:	e85a                	sd	s6,16(sp)
    80002184:	e45e                	sd	s7,8(sp)
    80002186:	e062                	sd	s8,0(sp)
    80002188:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    8000218a:	a27ff0ef          	jal	ra,80001bb0 <myproc>
    8000218e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002190:	e9fff0ef          	jal	ra,8000202e <allocproc>
    80002194:	12050963          	beqz	a0,800022c6 <kfork+0x154>
    80002198:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000219a:	048ab603          	ld	a2,72(s5)
    8000219e:	692c                	ld	a1,80(a0)
    800021a0:	050ab503          	ld	a0,80(s5)
    800021a4:	af4ff0ef          	jal	ra,80001498 <uvmcopy>
    800021a8:	04054863          	bltz	a0,800021f8 <kfork+0x86>
  np->sz = p->sz;
    800021ac:	048ab783          	ld	a5,72(s5)
    800021b0:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800021b4:	058ab683          	ld	a3,88(s5)
    800021b8:	87b6                	mv	a5,a3
    800021ba:	0589b703          	ld	a4,88(s3)
    800021be:	12068693          	addi	a3,a3,288
    800021c2:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    800021c6:	6788                	ld	a0,8(a5)
    800021c8:	6b8c                	ld	a1,16(a5)
    800021ca:	6f90                	ld	a2,24(a5)
    800021cc:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800021d0:	e708                	sd	a0,8(a4)
    800021d2:	eb0c                	sd	a1,16(a4)
    800021d4:	ef10                	sd	a2,24(a4)
    800021d6:	02078793          	addi	a5,a5,32
    800021da:	02070713          	addi	a4,a4,32
    800021de:	fed792e3          	bne	a5,a3,800021c2 <kfork+0x50>
  np->trapframe->a0 = 0;
    800021e2:	0589b783          	ld	a5,88(s3)
    800021e6:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800021ea:	0d0a8493          	addi	s1,s5,208
    800021ee:	0d098913          	addi	s2,s3,208
    800021f2:	150a8a13          	addi	s4,s5,336
    800021f6:	a829                	j	80002210 <kfork+0x9e>
    freeproc(np);
    800021f8:	854e                	mv	a0,s3
    800021fa:	dbfff0ef          	jal	ra,80001fb8 <freeproc>
    release(&np->lock);
    800021fe:	854e                	mv	a0,s3
    80002200:	b49fe0ef          	jal	ra,80000d48 <release>
    return -1;
    80002204:	5c7d                	li	s8,-1
    80002206:	a05d                	j	800022ac <kfork+0x13a>
  for(i = 0; i < NOFILE; i++)
    80002208:	04a1                	addi	s1,s1,8
    8000220a:	0921                	addi	s2,s2,8
    8000220c:	01448963          	beq	s1,s4,8000221e <kfork+0xac>
    if(p->ofile[i])
    80002210:	6088                	ld	a0,0(s1)
    80002212:	d97d                	beqz	a0,80002208 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    80002214:	257020ef          	jal	ra,80004c6a <filedup>
    80002218:	00a93023          	sd	a0,0(s2)
    8000221c:	b7f5                	j	80002208 <kfork+0x96>
  np->cwd = idup(p->cwd);
    8000221e:	150ab503          	ld	a0,336(s5)
    80002222:	46d010ef          	jal	ra,80003e8e <idup>
    80002226:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000222a:	4641                	li	a2,16
    8000222c:	158a8593          	addi	a1,s5,344
    80002230:	15898513          	addi	a0,s3,344
    80002234:	c97fe0ef          	jal	ra,80000eca <safestrcpy>
  pid = np->pid;
    80002238:	0309ac03          	lw	s8,48(s3)
  release(&np->lock);
    8000223c:	854e                	mv	a0,s3
    8000223e:	b0bfe0ef          	jal	ra,80000d48 <release>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    80002242:	16898b13          	addi	s6,s3,360
    80002246:	28000613          	li	a2,640
    8000224a:	168a8593          	addi	a1,s5,360
    8000224e:	855a                	mv	a0,s6
    80002250:	b91fe0ef          	jal	ra,80000de0 <memmove>
    80002254:	84da                	mv	s1,s6
  for(int i = 0; i < NVMA; i++){
    80002256:	4901                	li	s2,0
    80002258:	19098b93          	addi	s7,s3,400
    8000225c:	4a41                	li	s4,16
    8000225e:	a069                	j	800022e8 <kfork+0x176>
    for(int j = 0; j < i; j++){
    80002260:	02878793          	addi	a5,a5,40
    80002264:	06d78363          	beq	a5,a3,800022ca <kfork+0x158>
      if(np->vmas[j].used && np->vmas[j].is_shm && np->vmas[j].shm_key == key){
    80002268:	4398                	lw	a4,0(a5)
    8000226a:	db7d                	beqz	a4,80002260 <kfork+0xee>
    8000226c:	5398                	lw	a4,32(a5)
    8000226e:	db6d                	beqz	a4,80002260 <kfork+0xee>
    80002270:	53d8                	lw	a4,36(a5)
    80002272:	fea717e3          	bne	a4,a0,80002260 <kfork+0xee>
    80002276:	a0a5                	j	800022de <kfork+0x16c>
        freeproc(np);
    80002278:	854e                	mv	a0,s3
    8000227a:	d3fff0ef          	jal	ra,80001fb8 <freeproc>
        return -1;
    8000227e:	5c7d                	li	s8,-1
    80002280:	a035                	j	800022ac <kfork+0x13a>
  acquire(&wait_lock);
    80002282:	0022e497          	auipc	s1,0x22e
    80002286:	7a648493          	addi	s1,s1,1958 # 80230a28 <wait_lock>
    8000228a:	8526                	mv	a0,s1
    8000228c:	a25fe0ef          	jal	ra,80000cb0 <acquire>
  np->parent = p;
    80002290:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002294:	8526                	mv	a0,s1
    80002296:	ab3fe0ef          	jal	ra,80000d48 <release>
  acquire(&np->lock);
    8000229a:	854e                	mv	a0,s3
    8000229c:	a15fe0ef          	jal	ra,80000cb0 <acquire>
  np->state = RUNNABLE;
    800022a0:	478d                	li	a5,3
    800022a2:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800022a6:	854e                	mv	a0,s3
    800022a8:	aa1fe0ef          	jal	ra,80000d48 <release>
}
    800022ac:	8562                	mv	a0,s8
    800022ae:	60a6                	ld	ra,72(sp)
    800022b0:	6406                	ld	s0,64(sp)
    800022b2:	74e2                	ld	s1,56(sp)
    800022b4:	7942                	ld	s2,48(sp)
    800022b6:	79a2                	ld	s3,40(sp)
    800022b8:	7a02                	ld	s4,32(sp)
    800022ba:	6ae2                	ld	s5,24(sp)
    800022bc:	6b42                	ld	s6,16(sp)
    800022be:	6ba2                	ld	s7,8(sp)
    800022c0:	6c02                	ld	s8,0(sp)
    800022c2:	6161                	addi	sp,sp,80
    800022c4:	8082                	ret
    return -1;
    800022c6:	5c7d                	li	s8,-1
    800022c8:	b7d5                	j	800022ac <kfork+0x13a>
    int npages = (np->vmas[i].end - np->vmas[i].start) / PGSIZE;
    800022ca:	699c                	ld	a5,16(a1)
    800022cc:	658c                	ld	a1,8(a1)
    800022ce:	40b785b3          	sub	a1,a5,a1
    800022d2:	81b1                	srli	a1,a1,0xc
    if(shm_get(key, npages) < 0){
    800022d4:	2581                	sext.w	a1,a1
    800022d6:	2fa040ef          	jal	ra,800065d0 <shm_get>
    800022da:	f8054fe3          	bltz	a0,80002278 <kfork+0x106>
  for(int i = 0; i < NVMA; i++){
    800022de:	2905                	addiw	s2,s2,1
    800022e0:	02848493          	addi	s1,s1,40
    800022e4:	f9490fe3          	beq	s2,s4,80002282 <kfork+0x110>
    if(!np->vmas[i].used || !np->vmas[i].is_shm) continue;
    800022e8:	85a6                	mv	a1,s1
    800022ea:	409c                	lw	a5,0(s1)
    800022ec:	dbed                	beqz	a5,800022de <kfork+0x16c>
    800022ee:	509c                	lw	a5,32(s1)
    800022f0:	d7fd                	beqz	a5,800022de <kfork+0x16c>
    int key = np->vmas[i].shm_key;
    800022f2:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    800022f4:	fd205be3          	blez	s2,800022ca <kfork+0x158>
    800022f8:	fff9069b          	addiw	a3,s2,-1
    800022fc:	02069793          	slli	a5,a3,0x20
    80002300:	9381                	srli	a5,a5,0x20
    80002302:	00279693          	slli	a3,a5,0x2
    80002306:	96be                	add	a3,a3,a5
    80002308:	068e                	slli	a3,a3,0x3
    8000230a:	96de                	add	a3,a3,s7
    8000230c:	87da                	mv	a5,s6
    8000230e:	bfa9                	j	80002268 <kfork+0xf6>

0000000080002310 <scheduler>:
{
    80002310:	715d                	addi	sp,sp,-80
    80002312:	e486                	sd	ra,72(sp)
    80002314:	e0a2                	sd	s0,64(sp)
    80002316:	fc26                	sd	s1,56(sp)
    80002318:	f84a                	sd	s2,48(sp)
    8000231a:	f44e                	sd	s3,40(sp)
    8000231c:	f052                	sd	s4,32(sp)
    8000231e:	ec56                	sd	s5,24(sp)
    80002320:	e85a                	sd	s6,16(sp)
    80002322:	e45e                	sd	s7,8(sp)
    80002324:	e062                	sd	s8,0(sp)
    80002326:	0880                	addi	s0,sp,80
    80002328:	8792                	mv	a5,tp
  int id = r_tp();
    8000232a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000232c:	00779b13          	slli	s6,a5,0x7
    80002330:	0022e717          	auipc	a4,0x22e
    80002334:	6e070713          	addi	a4,a4,1760 # 80230a10 <pid_lock>
    80002338:	975a                	add	a4,a4,s6
    8000233a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000233e:	0022e717          	auipc	a4,0x22e
    80002342:	70a70713          	addi	a4,a4,1802 # 80230a48 <cpus+0x8>
    80002346:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002348:	4c11                	li	s8,4
        c->proc = p;
    8000234a:	079e                	slli	a5,a5,0x7
    8000234c:	0022ea17          	auipc	s4,0x22e
    80002350:	6c4a0a13          	addi	s4,s4,1732 # 80230a10 <pid_lock>
    80002354:	9a3e                	add	s4,s4,a5
        found = 1;
    80002356:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002358:	0023e997          	auipc	s3,0x23e
    8000235c:	4e898993          	addi	s3,s3,1256 # 80240840 <tickslock>
    80002360:	a83d                	j	8000239e <scheduler+0x8e>
      release(&p->lock);
    80002362:	8526                	mv	a0,s1
    80002364:	9e5fe0ef          	jal	ra,80000d48 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002368:	3e848493          	addi	s1,s1,1000
    8000236c:	03348563          	beq	s1,s3,80002396 <scheduler+0x86>
      acquire(&p->lock);
    80002370:	8526                	mv	a0,s1
    80002372:	93ffe0ef          	jal	ra,80000cb0 <acquire>
      if(p->state == RUNNABLE) {
    80002376:	4c9c                	lw	a5,24(s1)
    80002378:	ff2795e3          	bne	a5,s2,80002362 <scheduler+0x52>
        p->state = RUNNING;
    8000237c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002380:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002384:	06048593          	addi	a1,s1,96
    80002388:	855a                	mv	a0,s6
    8000238a:	5b0000ef          	jal	ra,8000293a <swtch>
        c->proc = 0;
    8000238e:	020a3823          	sd	zero,48(s4)
        found = 1;
    80002392:	8ade                	mv	s5,s7
    80002394:	b7f9                	j	80002362 <scheduler+0x52>
    if(found == 0) {
    80002396:	000a9463          	bnez	s5,8000239e <scheduler+0x8e>
      asm volatile("wfi");
    8000239a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000239e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023a6:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023aa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023ae:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023b0:	10079073          	csrw	sstatus,a5
    int found = 0;
    800023b4:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800023b6:	0022f497          	auipc	s1,0x22f
    800023ba:	a8a48493          	addi	s1,s1,-1398 # 80230e40 <proc>
      if(p->state == RUNNABLE) {
    800023be:	490d                	li	s2,3
    800023c0:	bf45                	j	80002370 <scheduler+0x60>

00000000800023c2 <sched>:
{
    800023c2:	7179                	addi	sp,sp,-48
    800023c4:	f406                	sd	ra,40(sp)
    800023c6:	f022                	sd	s0,32(sp)
    800023c8:	ec26                	sd	s1,24(sp)
    800023ca:	e84a                	sd	s2,16(sp)
    800023cc:	e44e                	sd	s3,8(sp)
    800023ce:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023d0:	fe0ff0ef          	jal	ra,80001bb0 <myproc>
    800023d4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023d6:	871fe0ef          	jal	ra,80000c46 <holding>
    800023da:	c92d                	beqz	a0,8000244c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023dc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023de:	2781                	sext.w	a5,a5
    800023e0:	079e                	slli	a5,a5,0x7
    800023e2:	0022e717          	auipc	a4,0x22e
    800023e6:	62e70713          	addi	a4,a4,1582 # 80230a10 <pid_lock>
    800023ea:	97ba                	add	a5,a5,a4
    800023ec:	0a87a703          	lw	a4,168(a5)
    800023f0:	4785                	li	a5,1
    800023f2:	06f71363          	bne	a4,a5,80002458 <sched+0x96>
  if(p->state == RUNNING)
    800023f6:	4c98                	lw	a4,24(s1)
    800023f8:	4791                	li	a5,4
    800023fa:	06f70563          	beq	a4,a5,80002464 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002402:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002404:	e7b5                	bnez	a5,80002470 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002406:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002408:	0022e917          	auipc	s2,0x22e
    8000240c:	60890913          	addi	s2,s2,1544 # 80230a10 <pid_lock>
    80002410:	2781                	sext.w	a5,a5
    80002412:	079e                	slli	a5,a5,0x7
    80002414:	97ca                	add	a5,a5,s2
    80002416:	0ac7a983          	lw	s3,172(a5)
    8000241a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000241c:	2781                	sext.w	a5,a5
    8000241e:	079e                	slli	a5,a5,0x7
    80002420:	0022e597          	auipc	a1,0x22e
    80002424:	62858593          	addi	a1,a1,1576 # 80230a48 <cpus+0x8>
    80002428:	95be                	add	a1,a1,a5
    8000242a:	06048513          	addi	a0,s1,96
    8000242e:	50c000ef          	jal	ra,8000293a <swtch>
    80002432:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002434:	2781                	sext.w	a5,a5
    80002436:	079e                	slli	a5,a5,0x7
    80002438:	97ca                	add	a5,a5,s2
    8000243a:	0b37a623          	sw	s3,172(a5)
}
    8000243e:	70a2                	ld	ra,40(sp)
    80002440:	7402                	ld	s0,32(sp)
    80002442:	64e2                	ld	s1,24(sp)
    80002444:	6942                	ld	s2,16(sp)
    80002446:	69a2                	ld	s3,8(sp)
    80002448:	6145                	addi	sp,sp,48
    8000244a:	8082                	ret
    panic("sched p->lock");
    8000244c:	00006517          	auipc	a0,0x6
    80002450:	d6c50513          	addi	a0,a0,-660 # 800081b8 <digits+0x180>
    80002454:	b36fe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80002458:	00006517          	auipc	a0,0x6
    8000245c:	d7050513          	addi	a0,a0,-656 # 800081c8 <digits+0x190>
    80002460:	b2afe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80002464:	00006517          	auipc	a0,0x6
    80002468:	d7450513          	addi	a0,a0,-652 # 800081d8 <digits+0x1a0>
    8000246c:	b1efe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    80002470:	00006517          	auipc	a0,0x6
    80002474:	d7850513          	addi	a0,a0,-648 # 800081e8 <digits+0x1b0>
    80002478:	b12fe0ef          	jal	ra,8000078a <panic>

000000008000247c <yield>:
{
    8000247c:	1101                	addi	sp,sp,-32
    8000247e:	ec06                	sd	ra,24(sp)
    80002480:	e822                	sd	s0,16(sp)
    80002482:	e426                	sd	s1,8(sp)
    80002484:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002486:	f2aff0ef          	jal	ra,80001bb0 <myproc>
    8000248a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000248c:	825fe0ef          	jal	ra,80000cb0 <acquire>
  p->state = RUNNABLE;
    80002490:	478d                	li	a5,3
    80002492:	cc9c                	sw	a5,24(s1)
  sched();
    80002494:	f2fff0ef          	jal	ra,800023c2 <sched>
  release(&p->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	8affe0ef          	jal	ra,80000d48 <release>
}
    8000249e:	60e2                	ld	ra,24(sp)
    800024a0:	6442                	ld	s0,16(sp)
    800024a2:	64a2                	ld	s1,8(sp)
    800024a4:	6105                	addi	sp,sp,32
    800024a6:	8082                	ret

00000000800024a8 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800024a8:	7179                	addi	sp,sp,-48
    800024aa:	f406                	sd	ra,40(sp)
    800024ac:	f022                	sd	s0,32(sp)
    800024ae:	ec26                	sd	s1,24(sp)
    800024b0:	e84a                	sd	s2,16(sp)
    800024b2:	e44e                	sd	s3,8(sp)
    800024b4:	1800                	addi	s0,sp,48
    800024b6:	89aa                	mv	s3,a0
    800024b8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024ba:	ef6ff0ef          	jal	ra,80001bb0 <myproc>
    800024be:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800024c0:	ff0fe0ef          	jal	ra,80000cb0 <acquire>
  release(lk);
    800024c4:	854a                	mv	a0,s2
    800024c6:	883fe0ef          	jal	ra,80000d48 <release>

  // Go to sleep.
  p->chan = chan;
    800024ca:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024ce:	4789                	li	a5,2
    800024d0:	cc9c                	sw	a5,24(s1)

  sched();
    800024d2:	ef1ff0ef          	jal	ra,800023c2 <sched>

  // Tidy up.
  p->chan = 0;
    800024d6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	86dfe0ef          	jal	ra,80000d48 <release>
  acquire(lk);
    800024e0:	854a                	mv	a0,s2
    800024e2:	fcefe0ef          	jal	ra,80000cb0 <acquire>
}
    800024e6:	70a2                	ld	ra,40(sp)
    800024e8:	7402                	ld	s0,32(sp)
    800024ea:	64e2                	ld	s1,24(sp)
    800024ec:	6942                	ld	s2,16(sp)
    800024ee:	69a2                	ld	s3,8(sp)
    800024f0:	6145                	addi	sp,sp,48
    800024f2:	8082                	ret

00000000800024f4 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800024f4:	7139                	addi	sp,sp,-64
    800024f6:	fc06                	sd	ra,56(sp)
    800024f8:	f822                	sd	s0,48(sp)
    800024fa:	f426                	sd	s1,40(sp)
    800024fc:	f04a                	sd	s2,32(sp)
    800024fe:	ec4e                	sd	s3,24(sp)
    80002500:	e852                	sd	s4,16(sp)
    80002502:	e456                	sd	s5,8(sp)
    80002504:	0080                	addi	s0,sp,64
    80002506:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002508:	0022f497          	auipc	s1,0x22f
    8000250c:	93848493          	addi	s1,s1,-1736 # 80230e40 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002510:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002512:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002514:	0023e917          	auipc	s2,0x23e
    80002518:	32c90913          	addi	s2,s2,812 # 80240840 <tickslock>
    8000251c:	a801                	j	8000252c <wakeup+0x38>
      }
      release(&p->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	829fe0ef          	jal	ra,80000d48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002524:	3e848493          	addi	s1,s1,1000
    80002528:	03248263          	beq	s1,s2,8000254c <wakeup+0x58>
    if(p != myproc()){
    8000252c:	e84ff0ef          	jal	ra,80001bb0 <myproc>
    80002530:	fea48ae3          	beq	s1,a0,80002524 <wakeup+0x30>
      acquire(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	f7afe0ef          	jal	ra,80000cb0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000253a:	4c9c                	lw	a5,24(s1)
    8000253c:	ff3791e3          	bne	a5,s3,8000251e <wakeup+0x2a>
    80002540:	709c                	ld	a5,32(s1)
    80002542:	fd479ee3          	bne	a5,s4,8000251e <wakeup+0x2a>
        p->state = RUNNABLE;
    80002546:	0154ac23          	sw	s5,24(s1)
    8000254a:	bfd1                	j	8000251e <wakeup+0x2a>
    }
  }
}
    8000254c:	70e2                	ld	ra,56(sp)
    8000254e:	7442                	ld	s0,48(sp)
    80002550:	74a2                	ld	s1,40(sp)
    80002552:	7902                	ld	s2,32(sp)
    80002554:	69e2                	ld	s3,24(sp)
    80002556:	6a42                	ld	s4,16(sp)
    80002558:	6aa2                	ld	s5,8(sp)
    8000255a:	6121                	addi	sp,sp,64
    8000255c:	8082                	ret

000000008000255e <reparent>:
{
    8000255e:	7179                	addi	sp,sp,-48
    80002560:	f406                	sd	ra,40(sp)
    80002562:	f022                	sd	s0,32(sp)
    80002564:	ec26                	sd	s1,24(sp)
    80002566:	e84a                	sd	s2,16(sp)
    80002568:	e44e                	sd	s3,8(sp)
    8000256a:	e052                	sd	s4,0(sp)
    8000256c:	1800                	addi	s0,sp,48
    8000256e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002570:	0022f497          	auipc	s1,0x22f
    80002574:	8d048493          	addi	s1,s1,-1840 # 80230e40 <proc>
      pp->parent = initproc;
    80002578:	00006a17          	auipc	s4,0x6
    8000257c:	348a0a13          	addi	s4,s4,840 # 800088c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002580:	0023e997          	auipc	s3,0x23e
    80002584:	2c098993          	addi	s3,s3,704 # 80240840 <tickslock>
    80002588:	a029                	j	80002592 <reparent+0x34>
    8000258a:	3e848493          	addi	s1,s1,1000
    8000258e:	01348b63          	beq	s1,s3,800025a4 <reparent+0x46>
    if(pp->parent == p){
    80002592:	7c9c                	ld	a5,56(s1)
    80002594:	ff279be3          	bne	a5,s2,8000258a <reparent+0x2c>
      pp->parent = initproc;
    80002598:	000a3503          	ld	a0,0(s4)
    8000259c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000259e:	f57ff0ef          	jal	ra,800024f4 <wakeup>
    800025a2:	b7e5                	j	8000258a <reparent+0x2c>
}
    800025a4:	70a2                	ld	ra,40(sp)
    800025a6:	7402                	ld	s0,32(sp)
    800025a8:	64e2                	ld	s1,24(sp)
    800025aa:	6942                	ld	s2,16(sp)
    800025ac:	69a2                	ld	s3,8(sp)
    800025ae:	6a02                	ld	s4,0(sp)
    800025b0:	6145                	addi	sp,sp,48
    800025b2:	8082                	ret

00000000800025b4 <kexit>:
{
    800025b4:	7179                	addi	sp,sp,-48
    800025b6:	f406                	sd	ra,40(sp)
    800025b8:	f022                	sd	s0,32(sp)
    800025ba:	ec26                	sd	s1,24(sp)
    800025bc:	e84a                	sd	s2,16(sp)
    800025be:	e44e                	sd	s3,8(sp)
    800025c0:	e052                	sd	s4,0(sp)
    800025c2:	1800                	addi	s0,sp,48
    800025c4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025c6:	deaff0ef          	jal	ra,80001bb0 <myproc>
    800025ca:	89aa                	mv	s3,a0
  if(p == initproc)
    800025cc:	00006797          	auipc	a5,0x6
    800025d0:	2f47b783          	ld	a5,756(a5) # 800088c0 <initproc>
    800025d4:	0d050493          	addi	s1,a0,208
    800025d8:	15050913          	addi	s2,a0,336
    800025dc:	00a79f63          	bne	a5,a0,800025fa <kexit+0x46>
    panic("init exiting");
    800025e0:	00006517          	auipc	a0,0x6
    800025e4:	c2050513          	addi	a0,a0,-992 # 80008200 <digits+0x1c8>
    800025e8:	9a2fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    800025ec:	6c4020ef          	jal	ra,80004cb0 <fileclose>
      p->ofile[fd] = 0;
    800025f0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800025f4:	04a1                	addi	s1,s1,8
    800025f6:	01248563          	beq	s1,s2,80002600 <kexit+0x4c>
    if(p->ofile[fd]){
    800025fa:	6088                	ld	a0,0(s1)
    800025fc:	f965                	bnez	a0,800025ec <kexit+0x38>
    800025fe:	bfdd                	j	800025f4 <kexit+0x40>
  begin_op();
    80002600:	2a2020ef          	jal	ra,800048a2 <begin_op>
  iput(p->cwd);
    80002604:	1509b503          	ld	a0,336(s3)
    80002608:	23b010ef          	jal	ra,80004042 <iput>
  end_op();
    8000260c:	306020ef          	jal	ra,80004912 <end_op>
  p->cwd = 0;
    80002610:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002614:	0022e497          	auipc	s1,0x22e
    80002618:	41448493          	addi	s1,s1,1044 # 80230a28 <wait_lock>
    8000261c:	8526                	mv	a0,s1
    8000261e:	e92fe0ef          	jal	ra,80000cb0 <acquire>
  reparent(p);
    80002622:	854e                	mv	a0,s3
    80002624:	f3bff0ef          	jal	ra,8000255e <reparent>
  wakeup(p->parent);
    80002628:	0389b503          	ld	a0,56(s3)
    8000262c:	ec9ff0ef          	jal	ra,800024f4 <wakeup>
  acquire(&p->lock);
    80002630:	854e                	mv	a0,s3
    80002632:	e7efe0ef          	jal	ra,80000cb0 <acquire>
  p->xstate = status;
    80002636:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000263a:	4795                	li	a5,5
    8000263c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002640:	8526                	mv	a0,s1
    80002642:	f06fe0ef          	jal	ra,80000d48 <release>
  sched();
    80002646:	d7dff0ef          	jal	ra,800023c2 <sched>
  panic("zombie exit");
    8000264a:	00006517          	auipc	a0,0x6
    8000264e:	bc650513          	addi	a0,a0,-1082 # 80008210 <digits+0x1d8>
    80002652:	938fe0ef          	jal	ra,8000078a <panic>

0000000080002656 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002656:	7179                	addi	sp,sp,-48
    80002658:	f406                	sd	ra,40(sp)
    8000265a:	f022                	sd	s0,32(sp)
    8000265c:	ec26                	sd	s1,24(sp)
    8000265e:	e84a                	sd	s2,16(sp)
    80002660:	e44e                	sd	s3,8(sp)
    80002662:	1800                	addi	s0,sp,48
    80002664:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002666:	0022e497          	auipc	s1,0x22e
    8000266a:	7da48493          	addi	s1,s1,2010 # 80230e40 <proc>
    8000266e:	0023e997          	auipc	s3,0x23e
    80002672:	1d298993          	addi	s3,s3,466 # 80240840 <tickslock>
    acquire(&p->lock);
    80002676:	8526                	mv	a0,s1
    80002678:	e38fe0ef          	jal	ra,80000cb0 <acquire>
    if(p->pid == pid){
    8000267c:	589c                	lw	a5,48(s1)
    8000267e:	01278b63          	beq	a5,s2,80002694 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002682:	8526                	mv	a0,s1
    80002684:	ec4fe0ef          	jal	ra,80000d48 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002688:	3e848493          	addi	s1,s1,1000
    8000268c:	ff3495e3          	bne	s1,s3,80002676 <kkill+0x20>
  }
  return -1;
    80002690:	557d                	li	a0,-1
    80002692:	a819                	j	800026a8 <kkill+0x52>
      p->killed = 1;
    80002694:	4785                	li	a5,1
    80002696:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002698:	4c98                	lw	a4,24(s1)
    8000269a:	4789                	li	a5,2
    8000269c:	00f70d63          	beq	a4,a5,800026b6 <kkill+0x60>
      release(&p->lock);
    800026a0:	8526                	mv	a0,s1
    800026a2:	ea6fe0ef          	jal	ra,80000d48 <release>
      return 0;
    800026a6:	4501                	li	a0,0
}
    800026a8:	70a2                	ld	ra,40(sp)
    800026aa:	7402                	ld	s0,32(sp)
    800026ac:	64e2                	ld	s1,24(sp)
    800026ae:	6942                	ld	s2,16(sp)
    800026b0:	69a2                	ld	s3,8(sp)
    800026b2:	6145                	addi	sp,sp,48
    800026b4:	8082                	ret
        p->state = RUNNABLE;
    800026b6:	478d                	li	a5,3
    800026b8:	cc9c                	sw	a5,24(s1)
    800026ba:	b7dd                	j	800026a0 <kkill+0x4a>

00000000800026bc <setkilled>:

void
setkilled(struct proc *p)
{
    800026bc:	1101                	addi	sp,sp,-32
    800026be:	ec06                	sd	ra,24(sp)
    800026c0:	e822                	sd	s0,16(sp)
    800026c2:	e426                	sd	s1,8(sp)
    800026c4:	1000                	addi	s0,sp,32
    800026c6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026c8:	de8fe0ef          	jal	ra,80000cb0 <acquire>
  p->killed = 1;
    800026cc:	4785                	li	a5,1
    800026ce:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026d0:	8526                	mv	a0,s1
    800026d2:	e76fe0ef          	jal	ra,80000d48 <release>
}
    800026d6:	60e2                	ld	ra,24(sp)
    800026d8:	6442                	ld	s0,16(sp)
    800026da:	64a2                	ld	s1,8(sp)
    800026dc:	6105                	addi	sp,sp,32
    800026de:	8082                	ret

00000000800026e0 <killed>:

int
killed(struct proc *p)
{
    800026e0:	1101                	addi	sp,sp,-32
    800026e2:	ec06                	sd	ra,24(sp)
    800026e4:	e822                	sd	s0,16(sp)
    800026e6:	e426                	sd	s1,8(sp)
    800026e8:	e04a                	sd	s2,0(sp)
    800026ea:	1000                	addi	s0,sp,32
    800026ec:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800026ee:	dc2fe0ef          	jal	ra,80000cb0 <acquire>
  k = p->killed;
    800026f2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800026f6:	8526                	mv	a0,s1
    800026f8:	e50fe0ef          	jal	ra,80000d48 <release>
  return k;
}
    800026fc:	854a                	mv	a0,s2
    800026fe:	60e2                	ld	ra,24(sp)
    80002700:	6442                	ld	s0,16(sp)
    80002702:	64a2                	ld	s1,8(sp)
    80002704:	6902                	ld	s2,0(sp)
    80002706:	6105                	addi	sp,sp,32
    80002708:	8082                	ret

000000008000270a <kwait>:
{
    8000270a:	715d                	addi	sp,sp,-80
    8000270c:	e486                	sd	ra,72(sp)
    8000270e:	e0a2                	sd	s0,64(sp)
    80002710:	fc26                	sd	s1,56(sp)
    80002712:	f84a                	sd	s2,48(sp)
    80002714:	f44e                	sd	s3,40(sp)
    80002716:	f052                	sd	s4,32(sp)
    80002718:	ec56                	sd	s5,24(sp)
    8000271a:	e85a                	sd	s6,16(sp)
    8000271c:	e45e                	sd	s7,8(sp)
    8000271e:	e062                	sd	s8,0(sp)
    80002720:	0880                	addi	s0,sp,80
    80002722:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002724:	c8cff0ef          	jal	ra,80001bb0 <myproc>
    80002728:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000272a:	0022e517          	auipc	a0,0x22e
    8000272e:	2fe50513          	addi	a0,a0,766 # 80230a28 <wait_lock>
    80002732:	d7efe0ef          	jal	ra,80000cb0 <acquire>
    havekids = 0;
    80002736:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002738:	4a15                	li	s4,5
        havekids = 1;
    8000273a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000273c:	0023e997          	auipc	s3,0x23e
    80002740:	10498993          	addi	s3,s3,260 # 80240840 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002744:	0022ec17          	auipc	s8,0x22e
    80002748:	2e4c0c13          	addi	s8,s8,740 # 80230a28 <wait_lock>
    havekids = 0;
    8000274c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000274e:	0022e497          	auipc	s1,0x22e
    80002752:	6f248493          	addi	s1,s1,1778 # 80230e40 <proc>
    80002756:	a899                	j	800027ac <kwait+0xa2>
          pid = pp->pid;
    80002758:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000275c:	000b0c63          	beqz	s6,80002774 <kwait+0x6a>
    80002760:	4691                	li	a3,4
    80002762:	02c48613          	addi	a2,s1,44
    80002766:	85da                	mv	a1,s6
    80002768:	05093503          	ld	a0,80(s2)
    8000276c:	834ff0ef          	jal	ra,800017a0 <copyout>
    80002770:	00054f63          	bltz	a0,8000278e <kwait+0x84>
          freeproc(pp);
    80002774:	8526                	mv	a0,s1
    80002776:	843ff0ef          	jal	ra,80001fb8 <freeproc>
          release(&pp->lock);
    8000277a:	8526                	mv	a0,s1
    8000277c:	dccfe0ef          	jal	ra,80000d48 <release>
          release(&wait_lock);
    80002780:	0022e517          	auipc	a0,0x22e
    80002784:	2a850513          	addi	a0,a0,680 # 80230a28 <wait_lock>
    80002788:	dc0fe0ef          	jal	ra,80000d48 <release>
          return pid;
    8000278c:	a891                	j	800027e0 <kwait+0xd6>
            release(&pp->lock);
    8000278e:	8526                	mv	a0,s1
    80002790:	db8fe0ef          	jal	ra,80000d48 <release>
            release(&wait_lock);
    80002794:	0022e517          	auipc	a0,0x22e
    80002798:	29450513          	addi	a0,a0,660 # 80230a28 <wait_lock>
    8000279c:	dacfe0ef          	jal	ra,80000d48 <release>
            return -1;
    800027a0:	59fd                	li	s3,-1
    800027a2:	a83d                	j	800027e0 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800027a4:	3e848493          	addi	s1,s1,1000
    800027a8:	03348063          	beq	s1,s3,800027c8 <kwait+0xbe>
      if(pp->parent == p){
    800027ac:	7c9c                	ld	a5,56(s1)
    800027ae:	ff279be3          	bne	a5,s2,800027a4 <kwait+0x9a>
        acquire(&pp->lock);
    800027b2:	8526                	mv	a0,s1
    800027b4:	cfcfe0ef          	jal	ra,80000cb0 <acquire>
        if(pp->state == ZOMBIE){
    800027b8:	4c9c                	lw	a5,24(s1)
    800027ba:	f9478fe3          	beq	a5,s4,80002758 <kwait+0x4e>
        release(&pp->lock);
    800027be:	8526                	mv	a0,s1
    800027c0:	d88fe0ef          	jal	ra,80000d48 <release>
        havekids = 1;
    800027c4:	8756                	mv	a4,s5
    800027c6:	bff9                	j	800027a4 <kwait+0x9a>
    if(!havekids || killed(p)){
    800027c8:	c709                	beqz	a4,800027d2 <kwait+0xc8>
    800027ca:	854a                	mv	a0,s2
    800027cc:	f15ff0ef          	jal	ra,800026e0 <killed>
    800027d0:	c50d                	beqz	a0,800027fa <kwait+0xf0>
      release(&wait_lock);
    800027d2:	0022e517          	auipc	a0,0x22e
    800027d6:	25650513          	addi	a0,a0,598 # 80230a28 <wait_lock>
    800027da:	d6efe0ef          	jal	ra,80000d48 <release>
      return -1;
    800027de:	59fd                	li	s3,-1
}
    800027e0:	854e                	mv	a0,s3
    800027e2:	60a6                	ld	ra,72(sp)
    800027e4:	6406                	ld	s0,64(sp)
    800027e6:	74e2                	ld	s1,56(sp)
    800027e8:	7942                	ld	s2,48(sp)
    800027ea:	79a2                	ld	s3,40(sp)
    800027ec:	7a02                	ld	s4,32(sp)
    800027ee:	6ae2                	ld	s5,24(sp)
    800027f0:	6b42                	ld	s6,16(sp)
    800027f2:	6ba2                	ld	s7,8(sp)
    800027f4:	6c02                	ld	s8,0(sp)
    800027f6:	6161                	addi	sp,sp,80
    800027f8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027fa:	85e2                	mv	a1,s8
    800027fc:	854a                	mv	a0,s2
    800027fe:	cabff0ef          	jal	ra,800024a8 <sleep>
    havekids = 0;
    80002802:	b7a9                	j	8000274c <kwait+0x42>

0000000080002804 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002804:	7179                	addi	sp,sp,-48
    80002806:	f406                	sd	ra,40(sp)
    80002808:	f022                	sd	s0,32(sp)
    8000280a:	ec26                	sd	s1,24(sp)
    8000280c:	e84a                	sd	s2,16(sp)
    8000280e:	e44e                	sd	s3,8(sp)
    80002810:	e052                	sd	s4,0(sp)
    80002812:	1800                	addi	s0,sp,48
    80002814:	84aa                	mv	s1,a0
    80002816:	892e                	mv	s2,a1
    80002818:	89b2                	mv	s3,a2
    8000281a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000281c:	b94ff0ef          	jal	ra,80001bb0 <myproc>
  if(user_dst){
    80002820:	cc99                	beqz	s1,8000283e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002822:	86d2                	mv	a3,s4
    80002824:	864e                	mv	a2,s3
    80002826:	85ca                	mv	a1,s2
    80002828:	6928                	ld	a0,80(a0)
    8000282a:	f77fe0ef          	jal	ra,800017a0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000282e:	70a2                	ld	ra,40(sp)
    80002830:	7402                	ld	s0,32(sp)
    80002832:	64e2                	ld	s1,24(sp)
    80002834:	6942                	ld	s2,16(sp)
    80002836:	69a2                	ld	s3,8(sp)
    80002838:	6a02                	ld	s4,0(sp)
    8000283a:	6145                	addi	sp,sp,48
    8000283c:	8082                	ret
    memmove((char *)dst, src, len);
    8000283e:	000a061b          	sext.w	a2,s4
    80002842:	85ce                	mv	a1,s3
    80002844:	854a                	mv	a0,s2
    80002846:	d9afe0ef          	jal	ra,80000de0 <memmove>
    return 0;
    8000284a:	8526                	mv	a0,s1
    8000284c:	b7cd                	j	8000282e <either_copyout+0x2a>

000000008000284e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000284e:	7179                	addi	sp,sp,-48
    80002850:	f406                	sd	ra,40(sp)
    80002852:	f022                	sd	s0,32(sp)
    80002854:	ec26                	sd	s1,24(sp)
    80002856:	e84a                	sd	s2,16(sp)
    80002858:	e44e                	sd	s3,8(sp)
    8000285a:	e052                	sd	s4,0(sp)
    8000285c:	1800                	addi	s0,sp,48
    8000285e:	892a                	mv	s2,a0
    80002860:	84ae                	mv	s1,a1
    80002862:	89b2                	mv	s3,a2
    80002864:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002866:	b4aff0ef          	jal	ra,80001bb0 <myproc>
  if(user_src){
    8000286a:	cc99                	beqz	s1,80002888 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000286c:	86d2                	mv	a3,s4
    8000286e:	864e                	mv	a2,s3
    80002870:	85ca                	mv	a1,s2
    80002872:	6928                	ld	a0,80(a0)
    80002874:	83cff0ef          	jal	ra,800018b0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002878:	70a2                	ld	ra,40(sp)
    8000287a:	7402                	ld	s0,32(sp)
    8000287c:	64e2                	ld	s1,24(sp)
    8000287e:	6942                	ld	s2,16(sp)
    80002880:	69a2                	ld	s3,8(sp)
    80002882:	6a02                	ld	s4,0(sp)
    80002884:	6145                	addi	sp,sp,48
    80002886:	8082                	ret
    memmove(dst, (char*)src, len);
    80002888:	000a061b          	sext.w	a2,s4
    8000288c:	85ce                	mv	a1,s3
    8000288e:	854a                	mv	a0,s2
    80002890:	d50fe0ef          	jal	ra,80000de0 <memmove>
    return 0;
    80002894:	8526                	mv	a0,s1
    80002896:	b7cd                	j	80002878 <either_copyin+0x2a>

0000000080002898 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002898:	715d                	addi	sp,sp,-80
    8000289a:	e486                	sd	ra,72(sp)
    8000289c:	e0a2                	sd	s0,64(sp)
    8000289e:	fc26                	sd	s1,56(sp)
    800028a0:	f84a                	sd	s2,48(sp)
    800028a2:	f44e                	sd	s3,40(sp)
    800028a4:	f052                	sd	s4,32(sp)
    800028a6:	ec56                	sd	s5,24(sp)
    800028a8:	e85a                	sd	s6,16(sp)
    800028aa:	e45e                	sd	s7,8(sp)
    800028ac:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800028ae:	00006517          	auipc	a0,0x6
    800028b2:	81a50513          	addi	a0,a0,-2022 # 800080c8 <digits+0x90>
    800028b6:	c0ffd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028ba:	0022e497          	auipc	s1,0x22e
    800028be:	6de48493          	addi	s1,s1,1758 # 80230f98 <proc+0x158>
    800028c2:	0023e917          	auipc	s2,0x23e
    800028c6:	0d690913          	addi	s2,s2,214 # 80240998 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028ca:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800028cc:	00006997          	auipc	s3,0x6
    800028d0:	95498993          	addi	s3,s3,-1708 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    800028d4:	00006a97          	auipc	s5,0x6
    800028d8:	954a8a93          	addi	s5,s5,-1708 # 80008228 <digits+0x1f0>
    printf("\n");
    800028dc:	00005a17          	auipc	s4,0x5
    800028e0:	7eca0a13          	addi	s4,s4,2028 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028e4:	00006b97          	auipc	s7,0x6
    800028e8:	984b8b93          	addi	s7,s7,-1660 # 80008268 <states.0>
    800028ec:	a829                	j	80002906 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800028ee:	ed86a583          	lw	a1,-296(a3)
    800028f2:	8556                	mv	a0,s5
    800028f4:	bd1fd0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    800028f8:	8552                	mv	a0,s4
    800028fa:	bcbfd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028fe:	3e848493          	addi	s1,s1,1000
    80002902:	03248163          	beq	s1,s2,80002924 <procdump+0x8c>
    if(p->state == UNUSED)
    80002906:	86a6                	mv	a3,s1
    80002908:	ec04a783          	lw	a5,-320(s1)
    8000290c:	dbed                	beqz	a5,800028fe <procdump+0x66>
      state = "???";
    8000290e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002910:	fcfb6fe3          	bltu	s6,a5,800028ee <procdump+0x56>
    80002914:	1782                	slli	a5,a5,0x20
    80002916:	9381                	srli	a5,a5,0x20
    80002918:	078e                	slli	a5,a5,0x3
    8000291a:	97de                	add	a5,a5,s7
    8000291c:	6390                	ld	a2,0(a5)
    8000291e:	fa61                	bnez	a2,800028ee <procdump+0x56>
      state = "???";
    80002920:	864e                	mv	a2,s3
    80002922:	b7f1                	j	800028ee <procdump+0x56>
  }
}
    80002924:	60a6                	ld	ra,72(sp)
    80002926:	6406                	ld	s0,64(sp)
    80002928:	74e2                	ld	s1,56(sp)
    8000292a:	7942                	ld	s2,48(sp)
    8000292c:	79a2                	ld	s3,40(sp)
    8000292e:	7a02                	ld	s4,32(sp)
    80002930:	6ae2                	ld	s5,24(sp)
    80002932:	6b42                	ld	s6,16(sp)
    80002934:	6ba2                	ld	s7,8(sp)
    80002936:	6161                	addi	sp,sp,80
    80002938:	8082                	ret

000000008000293a <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000293a:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000293e:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002942:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002944:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002946:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000294a:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000294e:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002952:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002956:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000295a:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000295e:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002962:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002966:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000296a:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000296e:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002972:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002976:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002978:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000297a:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000297e:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002982:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002986:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000298a:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000298e:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002992:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002996:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000299a:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000299e:	0685bd83          	ld	s11,104(a1)
        
        ret
    800029a2:	8082                	ret

00000000800029a4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029a4:	1141                	addi	sp,sp,-16
    800029a6:	e406                	sd	ra,8(sp)
    800029a8:	e022                	sd	s0,0(sp)
    800029aa:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029ac:	00006597          	auipc	a1,0x6
    800029b0:	8ec58593          	addi	a1,a1,-1812 # 80008298 <states.0+0x30>
    800029b4:	0023e517          	auipc	a0,0x23e
    800029b8:	e8c50513          	addi	a0,a0,-372 # 80240840 <tickslock>
    800029bc:	a74fe0ef          	jal	ra,80000c30 <initlock>
}
    800029c0:	60a2                	ld	ra,8(sp)
    800029c2:	6402                	ld	s0,0(sp)
    800029c4:	0141                	addi	sp,sp,16
    800029c6:	8082                	ret

00000000800029c8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029c8:	1141                	addi	sp,sp,-16
    800029ca:	e422                	sd	s0,8(sp)
    800029cc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029ce:	00003797          	auipc	a5,0x3
    800029d2:	60278793          	addi	a5,a5,1538 # 80005fd0 <kernelvec>
    800029d6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029da:	6422                	ld	s0,8(sp)
    800029dc:	0141                	addi	sp,sp,16
    800029de:	8082                	ret

00000000800029e0 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800029e0:	1141                	addi	sp,sp,-16
    800029e2:	e406                	sd	ra,8(sp)
    800029e4:	e022                	sd	s0,0(sp)
    800029e6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029e8:	9c8ff0ef          	jal	ra,80001bb0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029f0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029f6:	04000737          	lui	a4,0x4000
    800029fa:	00004797          	auipc	a5,0x4
    800029fe:	60678793          	addi	a5,a5,1542 # 80007000 <_trampoline>
    80002a02:	00004697          	auipc	a3,0x4
    80002a06:	5fe68693          	addi	a3,a3,1534 # 80007000 <_trampoline>
    80002a0a:	8f95                	sub	a5,a5,a3
    80002a0c:	177d                	addi	a4,a4,-1
    80002a0e:	0732                	slli	a4,a4,0xc
    80002a10:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a12:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a16:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a18:	18002773          	csrr	a4,satp
    80002a1c:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a1e:	6d38                	ld	a4,88(a0)
    80002a20:	613c                	ld	a5,64(a0)
    80002a22:	6685                	lui	a3,0x1
    80002a24:	97b6                	add	a5,a5,a3
    80002a26:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a28:	6d3c                	ld	a5,88(a0)
    80002a2a:	00000717          	auipc	a4,0x0
    80002a2e:	0f470713          	addi	a4,a4,244 # 80002b1e <usertrap>
    80002a32:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a34:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a36:	8712                	mv	a4,tp
    80002a38:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a3a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a3e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a42:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a46:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a4a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a4c:	6f9c                	ld	a5,24(a5)
    80002a4e:	14179073          	csrw	sepc,a5
}
    80002a52:	60a2                	ld	ra,8(sp)
    80002a54:	6402                	ld	s0,0(sp)
    80002a56:	0141                	addi	sp,sp,16
    80002a58:	8082                	ret

0000000080002a5a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a5a:	1101                	addi	sp,sp,-32
    80002a5c:	ec06                	sd	ra,24(sp)
    80002a5e:	e822                	sd	s0,16(sp)
    80002a60:	e426                	sd	s1,8(sp)
    80002a62:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002a64:	920ff0ef          	jal	ra,80001b84 <cpuid>
    80002a68:	cd19                	beqz	a0,80002a86 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a6a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a6e:	000f4737          	lui	a4,0xf4
    80002a72:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a76:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a78:	14d79073          	csrw	0x14d,a5
}
    80002a7c:	60e2                	ld	ra,24(sp)
    80002a7e:	6442                	ld	s0,16(sp)
    80002a80:	64a2                	ld	s1,8(sp)
    80002a82:	6105                	addi	sp,sp,32
    80002a84:	8082                	ret
    acquire(&tickslock);
    80002a86:	0023e497          	auipc	s1,0x23e
    80002a8a:	dba48493          	addi	s1,s1,-582 # 80240840 <tickslock>
    80002a8e:	8526                	mv	a0,s1
    80002a90:	a20fe0ef          	jal	ra,80000cb0 <acquire>
    ticks++;
    80002a94:	00006517          	auipc	a0,0x6
    80002a98:	e3450513          	addi	a0,a0,-460 # 800088c8 <ticks>
    80002a9c:	411c                	lw	a5,0(a0)
    80002a9e:	2785                	addiw	a5,a5,1
    80002aa0:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002aa2:	a53ff0ef          	jal	ra,800024f4 <wakeup>
    release(&tickslock);
    80002aa6:	8526                	mv	a0,s1
    80002aa8:	aa0fe0ef          	jal	ra,80000d48 <release>
    80002aac:	bf7d                	j	80002a6a <clockintr+0x10>

0000000080002aae <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002aae:	1101                	addi	sp,sp,-32
    80002ab0:	ec06                	sd	ra,24(sp)
    80002ab2:	e822                	sd	s0,16(sp)
    80002ab4:	e426                	sd	s1,8(sp)
    80002ab6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ab8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002abc:	57fd                	li	a5,-1
    80002abe:	17fe                	slli	a5,a5,0x3f
    80002ac0:	07a5                	addi	a5,a5,9
    80002ac2:	00f70d63          	beq	a4,a5,80002adc <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002ac6:	57fd                	li	a5,-1
    80002ac8:	17fe                	slli	a5,a5,0x3f
    80002aca:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002acc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002ace:	04f70463          	beq	a4,a5,80002b16 <devintr+0x68>
  }
}
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	64a2                	ld	s1,8(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret
    int irq = plic_claim();
    80002adc:	59c030ef          	jal	ra,80006078 <plic_claim>
    80002ae0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ae2:	47a9                	li	a5,10
    80002ae4:	02f50363          	beq	a0,a5,80002b0a <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002ae8:	4785                	li	a5,1
    80002aea:	02f50363          	beq	a0,a5,80002b10 <devintr+0x62>
    return 1;
    80002aee:	4505                	li	a0,1
    } else if(irq){
    80002af0:	d0ed                	beqz	s1,80002ad2 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002af2:	85a6                	mv	a1,s1
    80002af4:	00005517          	auipc	a0,0x5
    80002af8:	7ac50513          	addi	a0,a0,1964 # 800082a0 <states.0+0x38>
    80002afc:	9c9fd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002b00:	8526                	mv	a0,s1
    80002b02:	596030ef          	jal	ra,80006098 <plic_complete>
    return 1;
    80002b06:	4505                	li	a0,1
    80002b08:	b7e9                	j	80002ad2 <devintr+0x24>
      uartintr();
    80002b0a:	e4ffd0ef          	jal	ra,80000958 <uartintr>
    80002b0e:	bfcd                	j	80002b00 <devintr+0x52>
      virtio_disk_intr();
    80002b10:	1f9030ef          	jal	ra,80006508 <virtio_disk_intr>
    80002b14:	b7f5                	j	80002b00 <devintr+0x52>
    clockintr();
    80002b16:	f45ff0ef          	jal	ra,80002a5a <clockintr>
    return 2;
    80002b1a:	4509                	li	a0,2
    80002b1c:	bf5d                	j	80002ad2 <devintr+0x24>

0000000080002b1e <usertrap>:
{
    80002b1e:	7179                	addi	sp,sp,-48
    80002b20:	f406                	sd	ra,40(sp)
    80002b22:	f022                	sd	s0,32(sp)
    80002b24:	ec26                	sd	s1,24(sp)
    80002b26:	e84a                	sd	s2,16(sp)
    80002b28:	e44e                	sd	s3,8(sp)
    80002b2a:	e052                	sd	s4,0(sp)
    80002b2c:	1800                	addi	s0,sp,48
    80002b2e:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b32:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b36:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b3a:	1007f793          	andi	a5,a5,256
    80002b3e:	e3bd                	bnez	a5,80002ba4 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b40:	00003797          	auipc	a5,0x3
    80002b44:	49078793          	addi	a5,a5,1168 # 80005fd0 <kernelvec>
    80002b48:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b4c:	864ff0ef          	jal	ra,80001bb0 <myproc>
    80002b50:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b52:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b54:	14102773          	csrr	a4,sepc
    80002b58:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b5a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b5e:	47a1                	li	a5,8
    80002b60:	04f70863          	beq	a4,a5,80002bb0 <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002b64:	f4bff0ef          	jal	ra,80002aae <devintr>
    80002b68:	892a                	mv	s2,a0
    80002b6a:	0c051e63          	bnez	a0,80002c46 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002b6e:	47b5                	li	a5,13
    80002b70:	08f98663          	beq	s3,a5,80002bfc <usertrap+0xde>
    80002b74:	47bd                	li	a5,15
    80002b76:	0af99363          	bne	s3,a5,80002c1c <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002b7a:	85d2                	mv	a1,s4
    80002b7c:	68a8                	ld	a0,80(s1)
    80002b7e:	9f1fe0ef          	jal	ra,8000156e <cowbreak>
    80002b82:	c531                	beqz	a0,80002bce <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    80002b84:	4605                	li	a2,1
    80002b86:	85d2                	mv	a1,s4
    80002b88:	8526                	mv	a0,s1
    80002b8a:	dcbfe0ef          	jal	ra,80001954 <vmafault>
    80002b8e:	e121                	bnez	a0,80002bce <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    80002b90:	4601                	li	a2,0
    80002b92:	85d2                	mv	a1,s4
    80002b94:	68a8                	ld	a0,80(s1)
    80002b96:	b99fe0ef          	jal	ra,8000172e <vmfault>
    80002b9a:	e915                	bnez	a0,80002bce <usertrap+0xb0>
        setkilled(p);
    80002b9c:	8526                	mv	a0,s1
    80002b9e:	b1fff0ef          	jal	ra,800026bc <setkilled>
    80002ba2:	a035                	j	80002bce <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002ba4:	00005517          	auipc	a0,0x5
    80002ba8:	71c50513          	addi	a0,a0,1820 # 800082c0 <states.0+0x58>
    80002bac:	bdffd0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    80002bb0:	b31ff0ef          	jal	ra,800026e0 <killed>
    80002bb4:	e121                	bnez	a0,80002bf4 <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002bb6:	6cb8                	ld	a4,88(s1)
    80002bb8:	6f1c                	ld	a5,24(a4)
    80002bba:	0791                	addi	a5,a5,4
    80002bbc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bc2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc6:	10079073          	csrw	sstatus,a5
    syscall();
    80002bca:	27c000ef          	jal	ra,80002e46 <syscall>
  if(killed(p))
    80002bce:	8526                	mv	a0,s1
    80002bd0:	b11ff0ef          	jal	ra,800026e0 <killed>
    80002bd4:	ed35                	bnez	a0,80002c50 <usertrap+0x132>
  prepare_return();
    80002bd6:	e0bff0ef          	jal	ra,800029e0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bda:	68a8                	ld	a0,80(s1)
    80002bdc:	8131                	srli	a0,a0,0xc
    80002bde:	57fd                	li	a5,-1
    80002be0:	17fe                	slli	a5,a5,0x3f
    80002be2:	8d5d                	or	a0,a0,a5
}
    80002be4:	70a2                	ld	ra,40(sp)
    80002be6:	7402                	ld	s0,32(sp)
    80002be8:	64e2                	ld	s1,24(sp)
    80002bea:	6942                	ld	s2,16(sp)
    80002bec:	69a2                	ld	s3,8(sp)
    80002bee:	6a02                	ld	s4,0(sp)
    80002bf0:	6145                	addi	sp,sp,48
    80002bf2:	8082                	ret
      kexit(-1);
    80002bf4:	557d                	li	a0,-1
    80002bf6:	9bfff0ef          	jal	ra,800025b4 <kexit>
    80002bfa:	bf75                	j	80002bb6 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002bfc:	4601                	li	a2,0
    80002bfe:	85d2                	mv	a1,s4
    80002c00:	8526                	mv	a0,s1
    80002c02:	d53fe0ef          	jal	ra,80001954 <vmafault>
    80002c06:	f561                	bnez	a0,80002bce <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002c08:	4605                	li	a2,1
    80002c0a:	85d2                	mv	a1,s4
    80002c0c:	68a8                	ld	a0,80(s1)
    80002c0e:	b21fe0ef          	jal	ra,8000172e <vmfault>
    80002c12:	fd55                	bnez	a0,80002bce <usertrap+0xb0>
        setkilled(p);
    80002c14:	8526                	mv	a0,s1
    80002c16:	aa7ff0ef          	jal	ra,800026bc <setkilled>
    80002c1a:	bf55                	j	80002bce <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002c1c:	5890                	lw	a2,48(s1)
    80002c1e:	85ce                	mv	a1,s3
    80002c20:	00005517          	auipc	a0,0x5
    80002c24:	6c050513          	addi	a0,a0,1728 # 800082e0 <states.0+0x78>
    80002c28:	89dfd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c2c:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002c30:	8652                	mv	a2,s4
    80002c32:	00005517          	auipc	a0,0x5
    80002c36:	6de50513          	addi	a0,a0,1758 # 80008310 <states.0+0xa8>
    80002c3a:	88bfd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002c3e:	8526                	mv	a0,s1
    80002c40:	a7dff0ef          	jal	ra,800026bc <setkilled>
    80002c44:	b769                	j	80002bce <usertrap+0xb0>
  if(killed(p))
    80002c46:	8526                	mv	a0,s1
    80002c48:	a99ff0ef          	jal	ra,800026e0 <killed>
    80002c4c:	c511                	beqz	a0,80002c58 <usertrap+0x13a>
    80002c4e:	a011                	j	80002c52 <usertrap+0x134>
    80002c50:	4901                	li	s2,0
    kexit(-1);
    80002c52:	557d                	li	a0,-1
    80002c54:	961ff0ef          	jal	ra,800025b4 <kexit>
  if(which_dev == 2)
    80002c58:	4789                	li	a5,2
    80002c5a:	f6f91ee3          	bne	s2,a5,80002bd6 <usertrap+0xb8>
    yield();
    80002c5e:	81fff0ef          	jal	ra,8000247c <yield>
    80002c62:	bf95                	j	80002bd6 <usertrap+0xb8>

0000000080002c64 <kerneltrap>:
{
    80002c64:	7179                	addi	sp,sp,-48
    80002c66:	f406                	sd	ra,40(sp)
    80002c68:	f022                	sd	s0,32(sp)
    80002c6a:	ec26                	sd	s1,24(sp)
    80002c6c:	e84a                	sd	s2,16(sp)
    80002c6e:	e44e                	sd	s3,8(sp)
    80002c70:	1800                	addi	s0,sp,48
    80002c72:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c76:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c7a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c7e:	1004f793          	andi	a5,s1,256
    80002c82:	c795                	beqz	a5,80002cae <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c84:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c88:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c8a:	eb85                	bnez	a5,80002cba <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002c8c:	e23ff0ef          	jal	ra,80002aae <devintr>
    80002c90:	c91d                	beqz	a0,80002cc6 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002c92:	4789                	li	a5,2
    80002c94:	04f50a63          	beq	a0,a5,80002ce8 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c98:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c9c:	10049073          	csrw	sstatus,s1
}
    80002ca0:	70a2                	ld	ra,40(sp)
    80002ca2:	7402                	ld	s0,32(sp)
    80002ca4:	64e2                	ld	s1,24(sp)
    80002ca6:	6942                	ld	s2,16(sp)
    80002ca8:	69a2                	ld	s3,8(sp)
    80002caa:	6145                	addi	sp,sp,48
    80002cac:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cae:	00005517          	auipc	a0,0x5
    80002cb2:	68a50513          	addi	a0,a0,1674 # 80008338 <states.0+0xd0>
    80002cb6:	ad5fd0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80002cba:	00005517          	auipc	a0,0x5
    80002cbe:	6a650513          	addi	a0,a0,1702 # 80008360 <states.0+0xf8>
    80002cc2:	ac9fd0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cc6:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cca:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002cce:	85ce                	mv	a1,s3
    80002cd0:	00005517          	auipc	a0,0x5
    80002cd4:	6b050513          	addi	a0,a0,1712 # 80008380 <states.0+0x118>
    80002cd8:	fecfd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002cdc:	00005517          	auipc	a0,0x5
    80002ce0:	6cc50513          	addi	a0,a0,1740 # 800083a8 <states.0+0x140>
    80002ce4:	aa7fd0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    80002ce8:	ec9fe0ef          	jal	ra,80001bb0 <myproc>
    80002cec:	d555                	beqz	a0,80002c98 <kerneltrap+0x34>
    yield();
    80002cee:	f8eff0ef          	jal	ra,8000247c <yield>
    80002cf2:	b75d                	j	80002c98 <kerneltrap+0x34>

0000000080002cf4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	1000                	addi	s0,sp,32
    80002cfe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d00:	eb1fe0ef          	jal	ra,80001bb0 <myproc>
  switch (n) {
    80002d04:	4795                	li	a5,5
    80002d06:	0497e163          	bltu	a5,s1,80002d48 <argraw+0x54>
    80002d0a:	048a                	slli	s1,s1,0x2
    80002d0c:	00005717          	auipc	a4,0x5
    80002d10:	6d470713          	addi	a4,a4,1748 # 800083e0 <states.0+0x178>
    80002d14:	94ba                	add	s1,s1,a4
    80002d16:	409c                	lw	a5,0(s1)
    80002d18:	97ba                	add	a5,a5,a4
    80002d1a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d1c:	6d3c                	ld	a5,88(a0)
    80002d1e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d20:	60e2                	ld	ra,24(sp)
    80002d22:	6442                	ld	s0,16(sp)
    80002d24:	64a2                	ld	s1,8(sp)
    80002d26:	6105                	addi	sp,sp,32
    80002d28:	8082                	ret
    return p->trapframe->a1;
    80002d2a:	6d3c                	ld	a5,88(a0)
    80002d2c:	7fa8                	ld	a0,120(a5)
    80002d2e:	bfcd                	j	80002d20 <argraw+0x2c>
    return p->trapframe->a2;
    80002d30:	6d3c                	ld	a5,88(a0)
    80002d32:	63c8                	ld	a0,128(a5)
    80002d34:	b7f5                	j	80002d20 <argraw+0x2c>
    return p->trapframe->a3;
    80002d36:	6d3c                	ld	a5,88(a0)
    80002d38:	67c8                	ld	a0,136(a5)
    80002d3a:	b7dd                	j	80002d20 <argraw+0x2c>
    return p->trapframe->a4;
    80002d3c:	6d3c                	ld	a5,88(a0)
    80002d3e:	6bc8                	ld	a0,144(a5)
    80002d40:	b7c5                	j	80002d20 <argraw+0x2c>
    return p->trapframe->a5;
    80002d42:	6d3c                	ld	a5,88(a0)
    80002d44:	6fc8                	ld	a0,152(a5)
    80002d46:	bfe9                	j	80002d20 <argraw+0x2c>
  panic("argraw");
    80002d48:	00005517          	auipc	a0,0x5
    80002d4c:	67050513          	addi	a0,a0,1648 # 800083b8 <states.0+0x150>
    80002d50:	a3bfd0ef          	jal	ra,8000078a <panic>

0000000080002d54 <fetchaddr>:
{
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	e426                	sd	s1,8(sp)
    80002d5c:	e04a                	sd	s2,0(sp)
    80002d5e:	1000                	addi	s0,sp,32
    80002d60:	84aa                	mv	s1,a0
    80002d62:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d64:	e4dfe0ef          	jal	ra,80001bb0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d68:	653c                	ld	a5,72(a0)
    80002d6a:	02f4f663          	bgeu	s1,a5,80002d96 <fetchaddr+0x42>
    80002d6e:	00848713          	addi	a4,s1,8
    80002d72:	02e7e463          	bltu	a5,a4,80002d9a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d76:	46a1                	li	a3,8
    80002d78:	8626                	mv	a2,s1
    80002d7a:	85ca                	mv	a1,s2
    80002d7c:	6928                	ld	a0,80(a0)
    80002d7e:	b33fe0ef          	jal	ra,800018b0 <copyin>
    80002d82:	00a03533          	snez	a0,a0
    80002d86:	40a00533          	neg	a0,a0
}
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	64a2                	ld	s1,8(sp)
    80002d90:	6902                	ld	s2,0(sp)
    80002d92:	6105                	addi	sp,sp,32
    80002d94:	8082                	ret
    return -1;
    80002d96:	557d                	li	a0,-1
    80002d98:	bfcd                	j	80002d8a <fetchaddr+0x36>
    80002d9a:	557d                	li	a0,-1
    80002d9c:	b7fd                	j	80002d8a <fetchaddr+0x36>

0000000080002d9e <fetchstr>:
{
    80002d9e:	7179                	addi	sp,sp,-48
    80002da0:	f406                	sd	ra,40(sp)
    80002da2:	f022                	sd	s0,32(sp)
    80002da4:	ec26                	sd	s1,24(sp)
    80002da6:	e84a                	sd	s2,16(sp)
    80002da8:	e44e                	sd	s3,8(sp)
    80002daa:	1800                	addi	s0,sp,48
    80002dac:	892a                	mv	s2,a0
    80002dae:	84ae                	mv	s1,a1
    80002db0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002db2:	dfffe0ef          	jal	ra,80001bb0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002db6:	86ce                	mv	a3,s3
    80002db8:	864a                	mv	a2,s2
    80002dba:	85a6                	mv	a1,s1
    80002dbc:	6928                	ld	a0,80(a0)
    80002dbe:	8a1fe0ef          	jal	ra,8000165e <copyinstr>
    80002dc2:	00054c63          	bltz	a0,80002dda <fetchstr+0x3c>
  return strlen(buf);
    80002dc6:	8526                	mv	a0,s1
    80002dc8:	934fe0ef          	jal	ra,80000efc <strlen>
}
    80002dcc:	70a2                	ld	ra,40(sp)
    80002dce:	7402                	ld	s0,32(sp)
    80002dd0:	64e2                	ld	s1,24(sp)
    80002dd2:	6942                	ld	s2,16(sp)
    80002dd4:	69a2                	ld	s3,8(sp)
    80002dd6:	6145                	addi	sp,sp,48
    80002dd8:	8082                	ret
    return -1;
    80002dda:	557d                	li	a0,-1
    80002ddc:	bfc5                	j	80002dcc <fetchstr+0x2e>

0000000080002dde <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dde:	1101                	addi	sp,sp,-32
    80002de0:	ec06                	sd	ra,24(sp)
    80002de2:	e822                	sd	s0,16(sp)
    80002de4:	e426                	sd	s1,8(sp)
    80002de6:	1000                	addi	s0,sp,32
    80002de8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dea:	f0bff0ef          	jal	ra,80002cf4 <argraw>
    80002dee:	c088                	sw	a0,0(s1)
}
    80002df0:	60e2                	ld	ra,24(sp)
    80002df2:	6442                	ld	s0,16(sp)
    80002df4:	64a2                	ld	s1,8(sp)
    80002df6:	6105                	addi	sp,sp,32
    80002df8:	8082                	ret

0000000080002dfa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002dfa:	1101                	addi	sp,sp,-32
    80002dfc:	ec06                	sd	ra,24(sp)
    80002dfe:	e822                	sd	s0,16(sp)
    80002e00:	e426                	sd	s1,8(sp)
    80002e02:	1000                	addi	s0,sp,32
    80002e04:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e06:	eefff0ef          	jal	ra,80002cf4 <argraw>
    80002e0a:	e088                	sd	a0,0(s1)
}
    80002e0c:	60e2                	ld	ra,24(sp)
    80002e0e:	6442                	ld	s0,16(sp)
    80002e10:	64a2                	ld	s1,8(sp)
    80002e12:	6105                	addi	sp,sp,32
    80002e14:	8082                	ret

0000000080002e16 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e16:	7179                	addi	sp,sp,-48
    80002e18:	f406                	sd	ra,40(sp)
    80002e1a:	f022                	sd	s0,32(sp)
    80002e1c:	ec26                	sd	s1,24(sp)
    80002e1e:	e84a                	sd	s2,16(sp)
    80002e20:	1800                	addi	s0,sp,48
    80002e22:	84ae                	mv	s1,a1
    80002e24:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e26:	fd840593          	addi	a1,s0,-40
    80002e2a:	fd1ff0ef          	jal	ra,80002dfa <argaddr>
  return fetchstr(addr, buf, max);
    80002e2e:	864a                	mv	a2,s2
    80002e30:	85a6                	mv	a1,s1
    80002e32:	fd843503          	ld	a0,-40(s0)
    80002e36:	f69ff0ef          	jal	ra,80002d9e <fetchstr>
}
    80002e3a:	70a2                	ld	ra,40(sp)
    80002e3c:	7402                	ld	s0,32(sp)
    80002e3e:	64e2                	ld	s1,24(sp)
    80002e40:	6942                	ld	s2,16(sp)
    80002e42:	6145                	addi	sp,sp,48
    80002e44:	8082                	ret

0000000080002e46 <syscall>:
[SYS_vmstats]    sys_vmstats,
};

void
syscall(void)
{
    80002e46:	1101                	addi	sp,sp,-32
    80002e48:	ec06                	sd	ra,24(sp)
    80002e4a:	e822                	sd	s0,16(sp)
    80002e4c:	e426                	sd	s1,8(sp)
    80002e4e:	e04a                	sd	s2,0(sp)
    80002e50:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e52:	d5ffe0ef          	jal	ra,80001bb0 <myproc>
    80002e56:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e58:	05853903          	ld	s2,88(a0)
    80002e5c:	0a893783          	ld	a5,168(s2)
    80002e60:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e64:	37fd                	addiw	a5,a5,-1
    80002e66:	4771                	li	a4,28
    80002e68:	00f76f63          	bltu	a4,a5,80002e86 <syscall+0x40>
    80002e6c:	00369713          	slli	a4,a3,0x3
    80002e70:	00005797          	auipc	a5,0x5
    80002e74:	58878793          	addi	a5,a5,1416 # 800083f8 <syscalls>
    80002e78:	97ba                	add	a5,a5,a4
    80002e7a:	639c                	ld	a5,0(a5)
    80002e7c:	c789                	beqz	a5,80002e86 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e7e:	9782                	jalr	a5
    80002e80:	06a93823          	sd	a0,112(s2)
    80002e84:	a829                	j	80002e9e <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e86:	15848613          	addi	a2,s1,344
    80002e8a:	588c                	lw	a1,48(s1)
    80002e8c:	00005517          	auipc	a0,0x5
    80002e90:	53450513          	addi	a0,a0,1332 # 800083c0 <states.0+0x158>
    80002e94:	e30fd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e98:	6cbc                	ld	a5,88(s1)
    80002e9a:	577d                	li	a4,-1
    80002e9c:	fbb8                	sd	a4,112(a5)
  }
}
    80002e9e:	60e2                	ld	ra,24(sp)
    80002ea0:	6442                	ld	s0,16(sp)
    80002ea2:	64a2                	ld	s1,8(sp)
    80002ea4:	6902                	ld	s2,0(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret

0000000080002eaa <proc_has_shm_key>:
 * 用途：
 *   用于判断进程是否还有其他VMA引用同一个共享内存对象
 */
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
    80002eaa:	1141                	addi	sp,sp,-16
    80002eac:	e422                	sd	s0,8(sp)
    80002eae:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002eb0:	16850793          	addi	a5,a0,360
    80002eb4:	3e850513          	addi	a0,a0,1000
    80002eb8:	a029                	j	80002ec2 <proc_has_shm_key+0x18>
    80002eba:	02878793          	addi	a5,a5,40
    80002ebe:	00a78d63          	beq	a5,a0,80002ed8 <proc_has_shm_key+0x2e>
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    80002ec2:	fef60ce3          	beq	a2,a5,80002eba <proc_has_shm_key+0x10>
    if(v->used && v->is_shm && v->shm_key == key)
    80002ec6:	4398                	lw	a4,0(a5)
    80002ec8:	db6d                	beqz	a4,80002eba <proc_has_shm_key+0x10>
    80002eca:	5398                	lw	a4,32(a5)
    80002ecc:	d77d                	beqz	a4,80002eba <proc_has_shm_key+0x10>
    80002ece:	53d8                	lw	a4,36(a5)
    80002ed0:	feb715e3          	bne	a4,a1,80002eba <proc_has_shm_key+0x10>
      return 1;
    80002ed4:	4505                	li	a0,1
    80002ed6:	a011                	j	80002eda <proc_has_shm_key+0x30>
  }
  return 0;
    80002ed8:	4501                	li	a0,0
}
    80002eda:	6422                	ld	s0,8(sp)
    80002edc:	0141                	addi	sp,sp,16
    80002ede:	8082                	ret

0000000080002ee0 <sys_exit>:
{
    80002ee0:	1101                	addi	sp,sp,-32
    80002ee2:	ec06                	sd	ra,24(sp)
    80002ee4:	e822                	sd	s0,16(sp)
    80002ee6:	1000                	addi	s0,sp,32
  argint(0, &n);
    80002ee8:	fec40593          	addi	a1,s0,-20
    80002eec:	4501                	li	a0,0
    80002eee:	ef1ff0ef          	jal	ra,80002dde <argint>
  kexit(n);
    80002ef2:	fec42503          	lw	a0,-20(s0)
    80002ef6:	ebeff0ef          	jal	ra,800025b4 <kexit>
}
    80002efa:	4501                	li	a0,0
    80002efc:	60e2                	ld	ra,24(sp)
    80002efe:	6442                	ld	s0,16(sp)
    80002f00:	6105                	addi	sp,sp,32
    80002f02:	8082                	ret

0000000080002f04 <sys_getpid>:
{
    80002f04:	1141                	addi	sp,sp,-16
    80002f06:	e406                	sd	ra,8(sp)
    80002f08:	e022                	sd	s0,0(sp)
    80002f0a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f0c:	ca5fe0ef          	jal	ra,80001bb0 <myproc>
}
    80002f10:	5908                	lw	a0,48(a0)
    80002f12:	60a2                	ld	ra,8(sp)
    80002f14:	6402                	ld	s0,0(sp)
    80002f16:	0141                	addi	sp,sp,16
    80002f18:	8082                	ret

0000000080002f1a <sys_fork>:
{
    80002f1a:	1141                	addi	sp,sp,-16
    80002f1c:	e406                	sd	ra,8(sp)
    80002f1e:	e022                	sd	s0,0(sp)
    80002f20:	0800                	addi	s0,sp,16
  return kfork();
    80002f22:	a50ff0ef          	jal	ra,80002172 <kfork>
}
    80002f26:	60a2                	ld	ra,8(sp)
    80002f28:	6402                	ld	s0,0(sp)
    80002f2a:	0141                	addi	sp,sp,16
    80002f2c:	8082                	ret

0000000080002f2e <sys_wait>:
{
    80002f2e:	1101                	addi	sp,sp,-32
    80002f30:	ec06                	sd	ra,24(sp)
    80002f32:	e822                	sd	s0,16(sp)
    80002f34:	1000                	addi	s0,sp,32
  argaddr(0, &p);
    80002f36:	fe840593          	addi	a1,s0,-24
    80002f3a:	4501                	li	a0,0
    80002f3c:	ebfff0ef          	jal	ra,80002dfa <argaddr>
  return kwait(p);
    80002f40:	fe843503          	ld	a0,-24(s0)
    80002f44:	fc6ff0ef          	jal	ra,8000270a <kwait>
}
    80002f48:	60e2                	ld	ra,24(sp)
    80002f4a:	6442                	ld	s0,16(sp)
    80002f4c:	6105                	addi	sp,sp,32
    80002f4e:	8082                	ret

0000000080002f50 <sys_sbrk>:
{
    80002f50:	7179                	addi	sp,sp,-48
    80002f52:	f406                	sd	ra,40(sp)
    80002f54:	f022                	sd	s0,32(sp)
    80002f56:	ec26                	sd	s1,24(sp)
    80002f58:	1800                	addi	s0,sp,48
  argint(0, &n);
    80002f5a:	fd840593          	addi	a1,s0,-40
    80002f5e:	4501                	li	a0,0
    80002f60:	e7fff0ef          	jal	ra,80002dde <argint>
  argint(1, &t);
    80002f64:	fdc40593          	addi	a1,s0,-36
    80002f68:	4505                	li	a0,1
    80002f6a:	e75ff0ef          	jal	ra,80002dde <argint>
  addr = myproc()->sz;
    80002f6e:	c43fe0ef          	jal	ra,80001bb0 <myproc>
    80002f72:	6524                	ld	s1,72(a0)
  if(t == SBRK_EAGER || n < 0) {
    80002f74:	fdc42703          	lw	a4,-36(s0)
    80002f78:	4785                	li	a5,1
    80002f7a:	02f70763          	beq	a4,a5,80002fa8 <sys_sbrk+0x58>
    80002f7e:	fd842783          	lw	a5,-40(s0)
    80002f82:	0207c363          	bltz	a5,80002fa8 <sys_sbrk+0x58>
    if(addr + n < addr)
    80002f86:	97a6                	add	a5,a5,s1
    80002f88:	0297ee63          	bltu	a5,s1,80002fc4 <sys_sbrk+0x74>
    if(addr + n > TRAPFRAME)
    80002f8c:	02000737          	lui	a4,0x2000
    80002f90:	177d                	addi	a4,a4,-1
    80002f92:	0736                	slli	a4,a4,0xd
    80002f94:	02f76a63          	bltu	a4,a5,80002fc8 <sys_sbrk+0x78>
    myproc()->sz += n;
    80002f98:	c19fe0ef          	jal	ra,80001bb0 <myproc>
    80002f9c:	fd842703          	lw	a4,-40(s0)
    80002fa0:	653c                	ld	a5,72(a0)
    80002fa2:	97ba                	add	a5,a5,a4
    80002fa4:	e53c                	sd	a5,72(a0)
    80002fa6:	a039                	j	80002fb4 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002fa8:	fd842503          	lw	a0,-40(s0)
    80002fac:	964ff0ef          	jal	ra,80002110 <growproc>
    80002fb0:	00054863          	bltz	a0,80002fc0 <sys_sbrk+0x70>
}
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	70a2                	ld	ra,40(sp)
    80002fb8:	7402                	ld	s0,32(sp)
    80002fba:	64e2                	ld	s1,24(sp)
    80002fbc:	6145                	addi	sp,sp,48
    80002fbe:	8082                	ret
      return -1;
    80002fc0:	54fd                	li	s1,-1
    80002fc2:	bfcd                	j	80002fb4 <sys_sbrk+0x64>
      return -1;
    80002fc4:	54fd                	li	s1,-1
    80002fc6:	b7fd                	j	80002fb4 <sys_sbrk+0x64>
      return -1;
    80002fc8:	54fd                	li	s1,-1
    80002fca:	b7ed                	j	80002fb4 <sys_sbrk+0x64>

0000000080002fcc <sys_pause>:
{
    80002fcc:	7139                	addi	sp,sp,-64
    80002fce:	fc06                	sd	ra,56(sp)
    80002fd0:	f822                	sd	s0,48(sp)
    80002fd2:	f426                	sd	s1,40(sp)
    80002fd4:	f04a                	sd	s2,32(sp)
    80002fd6:	ec4e                	sd	s3,24(sp)
    80002fd8:	0080                	addi	s0,sp,64
  argint(0, &n);
    80002fda:	fcc40593          	addi	a1,s0,-52
    80002fde:	4501                	li	a0,0
    80002fe0:	dffff0ef          	jal	ra,80002dde <argint>
  if(n < 0)
    80002fe4:	fcc42783          	lw	a5,-52(s0)
    80002fe8:	0607c563          	bltz	a5,80003052 <sys_pause+0x86>
  acquire(&tickslock);
    80002fec:	0023e517          	auipc	a0,0x23e
    80002ff0:	85450513          	addi	a0,a0,-1964 # 80240840 <tickslock>
    80002ff4:	cbdfd0ef          	jal	ra,80000cb0 <acquire>
  ticks0 = ticks;
    80002ff8:	00006917          	auipc	s2,0x6
    80002ffc:	8d092903          	lw	s2,-1840(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    80003000:	fcc42783          	lw	a5,-52(s0)
    80003004:	cb8d                	beqz	a5,80003036 <sys_pause+0x6a>
    sleep(&ticks, &tickslock);
    80003006:	0023e997          	auipc	s3,0x23e
    8000300a:	83a98993          	addi	s3,s3,-1990 # 80240840 <tickslock>
    8000300e:	00006497          	auipc	s1,0x6
    80003012:	8ba48493          	addi	s1,s1,-1862 # 800088c8 <ticks>
    if(killed(myproc())){
    80003016:	b9bfe0ef          	jal	ra,80001bb0 <myproc>
    8000301a:	ec6ff0ef          	jal	ra,800026e0 <killed>
    8000301e:	ed0d                	bnez	a0,80003058 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80003020:	85ce                	mv	a1,s3
    80003022:	8526                	mv	a0,s1
    80003024:	c84ff0ef          	jal	ra,800024a8 <sleep>
  while(ticks - ticks0 < n){
    80003028:	409c                	lw	a5,0(s1)
    8000302a:	412787bb          	subw	a5,a5,s2
    8000302e:	fcc42703          	lw	a4,-52(s0)
    80003032:	fee7e2e3          	bltu	a5,a4,80003016 <sys_pause+0x4a>
  release(&tickslock);
    80003036:	0023e517          	auipc	a0,0x23e
    8000303a:	80a50513          	addi	a0,a0,-2038 # 80240840 <tickslock>
    8000303e:	d0bfd0ef          	jal	ra,80000d48 <release>
  return 0;
    80003042:	4501                	li	a0,0
}
    80003044:	70e2                	ld	ra,56(sp)
    80003046:	7442                	ld	s0,48(sp)
    80003048:	74a2                	ld	s1,40(sp)
    8000304a:	7902                	ld	s2,32(sp)
    8000304c:	69e2                	ld	s3,24(sp)
    8000304e:	6121                	addi	sp,sp,64
    80003050:	8082                	ret
    n = 0;
    80003052:	fc042623          	sw	zero,-52(s0)
    80003056:	bf59                	j	80002fec <sys_pause+0x20>
      release(&tickslock);
    80003058:	0023d517          	auipc	a0,0x23d
    8000305c:	7e850513          	addi	a0,a0,2024 # 80240840 <tickslock>
    80003060:	ce9fd0ef          	jal	ra,80000d48 <release>
      return -1;
    80003064:	557d                	li	a0,-1
    80003066:	bff9                	j	80003044 <sys_pause+0x78>

0000000080003068 <sys_kill>:
{
    80003068:	1101                	addi	sp,sp,-32
    8000306a:	ec06                	sd	ra,24(sp)
    8000306c:	e822                	sd	s0,16(sp)
    8000306e:	1000                	addi	s0,sp,32
  argint(0, &pid);
    80003070:	fec40593          	addi	a1,s0,-20
    80003074:	4501                	li	a0,0
    80003076:	d69ff0ef          	jal	ra,80002dde <argint>
  return kkill(pid);
    8000307a:	fec42503          	lw	a0,-20(s0)
    8000307e:	dd8ff0ef          	jal	ra,80002656 <kkill>
}
    80003082:	60e2                	ld	ra,24(sp)
    80003084:	6442                	ld	s0,16(sp)
    80003086:	6105                	addi	sp,sp,32
    80003088:	8082                	ret

000000008000308a <sys_uptime>:
{
    8000308a:	1101                	addi	sp,sp,-32
    8000308c:	ec06                	sd	ra,24(sp)
    8000308e:	e822                	sd	s0,16(sp)
    80003090:	e426                	sd	s1,8(sp)
    80003092:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003094:	0023d517          	auipc	a0,0x23d
    80003098:	7ac50513          	addi	a0,a0,1964 # 80240840 <tickslock>
    8000309c:	c15fd0ef          	jal	ra,80000cb0 <acquire>
  xticks = ticks;
    800030a0:	00006497          	auipc	s1,0x6
    800030a4:	8284a483          	lw	s1,-2008(s1) # 800088c8 <ticks>
  release(&tickslock);
    800030a8:	0023d517          	auipc	a0,0x23d
    800030ac:	79850513          	addi	a0,a0,1944 # 80240840 <tickslock>
    800030b0:	c99fd0ef          	jal	ra,80000d48 <release>
}
    800030b4:	02049513          	slli	a0,s1,0x20
    800030b8:	9101                	srli	a0,a0,0x20
    800030ba:	60e2                	ld	ra,24(sp)
    800030bc:	6442                	ld	s0,16(sp)
    800030be:	64a2                	ld	s1,8(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret

00000000800030c4 <vma_find>:
{
    800030c4:	1141                	addi	sp,sp,-16
    800030c6:	e422                	sd	s0,8(sp)
    800030c8:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    800030ca:	16850793          	addi	a5,a0,360
    800030ce:	4701                	li	a4,0
    800030d0:	4841                	li	a6,16
    800030d2:	a031                	j	800030de <vma_find+0x1a>
    800030d4:	2705                	addiw	a4,a4,1
    800030d6:	02878793          	addi	a5,a5,40
    800030da:	03070263          	beq	a4,a6,800030fe <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    800030de:	4394                	lw	a3,0(a5)
    800030e0:	daf5                	beqz	a3,800030d4 <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    800030e2:	6794                	ld	a3,8(a5)
    800030e4:	fed5e8e3          	bltu	a1,a3,800030d4 <vma_find+0x10>
    800030e8:	6b94                	ld	a3,16(a5)
    800030ea:	fed5f5e3          	bgeu	a1,a3,800030d4 <vma_find+0x10>
      return &p->vmas[i];
    800030ee:	00271793          	slli	a5,a4,0x2
    800030f2:	97ba                	add	a5,a5,a4
    800030f4:	078e                	slli	a5,a5,0x3
    800030f6:	16878793          	addi	a5,a5,360
    800030fa:	953e                	add	a0,a0,a5
    800030fc:	a011                	j	80003100 <vma_find+0x3c>
  return 0;  // 没有找到包含该虚拟地址的VMA
    800030fe:	4501                	li	a0,0
}
    80003100:	6422                	ld	s0,8(sp)
    80003102:	0141                	addi	sp,sp,16
    80003104:	8082                	ret

0000000080003106 <sys_mmap>:

uint64
sys_mmap(void)
{
    80003106:	7119                	addi	sp,sp,-128
    80003108:	fc86                	sd	ra,120(sp)
    8000310a:	f8a2                	sd	s0,112(sp)
    8000310c:	f4a6                	sd	s1,104(sp)
    8000310e:	f0ca                	sd	s2,96(sp)
    80003110:	ecce                	sd	s3,88(sp)
    80003112:	e8d2                	sd	s4,80(sp)
    80003114:	e4d6                	sd	s5,72(sp)
    80003116:	e0da                	sd	s6,64(sp)
    80003118:	fc5e                	sd	s7,56(sp)
    8000311a:	f862                	sd	s8,48(sp)
    8000311c:	f466                	sd	s9,40(sp)
    8000311e:	0100                	addi	s0,sp,128
  uint64 addr;
  int len, prot, flags, key = -1;
    80003120:	57fd                	li	a5,-1
    80003122:	f8f42423          	sw	a5,-120(s0)
  int did_shm_get = 0;
  int need_get = 0;
  int npages = 0;

  argaddr(0, &addr);
    80003126:	f9840593          	addi	a1,s0,-104
    8000312a:	4501                	li	a0,0
    8000312c:	ccfff0ef          	jal	ra,80002dfa <argaddr>
  argint(1, &len);
    80003130:	f9440593          	addi	a1,s0,-108
    80003134:	4505                	li	a0,1
    80003136:	ca9ff0ef          	jal	ra,80002dde <argint>
  argint(2, &prot);
    8000313a:	f9040593          	addi	a1,s0,-112
    8000313e:	4509                	li	a0,2
    80003140:	c9fff0ef          	jal	ra,80002dde <argint>
  argint(3, &flags);
    80003144:	f8c40593          	addi	a1,s0,-116
    80003148:	450d                	li	a0,3
    8000314a:	c95ff0ef          	jal	ra,80002dde <argint>
  argint(4, &key);
    8000314e:	f8840593          	addi	a1,s0,-120
    80003152:	4511                	li	a0,4
    80003154:	c8bff0ef          	jal	ra,80002dde <argint>

  if(len <= 0) return (uint64)-1;
    80003158:	f9442783          	lw	a5,-108(s0)
    8000315c:	1af05b63          	blez	a5,80003312 <sys_mmap+0x20c>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return (uint64)-1;
  if(plen > (MMAPTOP - MMAPBASE)) return (uint64)-1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return (uint64)-1;
    80003160:	f9042903          	lw	s2,-112(s0)
    80003164:	ffc97913          	andi	s2,s2,-4
    80003168:	54fd                	li	s1,-1
    8000316a:	1a091563          	bnez	s2,80003314 <sys_mmap+0x20e>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    8000316e:	f8c42703          	lw	a4,-116(s0)
    80003172:	8b05                	andi	a4,a4,1
    80003174:	1a070063          	beqz	a4,80003314 <sys_mmap+0x20e>
  if(addr != 0) return (uint64)-1;
    80003178:	f9843a03          	ld	s4,-104(s0)
    8000317c:	180a1c63          	bnez	s4,80003314 <sys_mmap+0x20e>
  uint64 plen = PGROUNDUP((uint64)len);
    80003180:	6985                	lui	s3,0x1
    80003182:	19fd                	addi	s3,s3,-1
    80003184:	99be                	add	s3,s3,a5

  struct proc *p = myproc();
    80003186:	a2bfe0ef          	jal	ra,80001bb0 <myproc>
    8000318a:	8aaa                	mv	s5,a0

  //先把“是否需要 shm_get”算出来（此时还没创建/污染 vma）
  if(flags & MAP_SHARED){
    8000318c:	f8c42b83          	lw	s7,-116(s0)
    80003190:	002bfb93          	andi	s7,s7,2
    80003194:	020b8563          	beqz	s7,800031be <sys_mmap+0xb8>
    if(key < 0) return (uint64)-1;
    80003198:	f8842503          	lw	a0,-120(s0)
    8000319c:	16054c63          	bltz	a0,80003314 <sys_mmap+0x20e>
    npages = plen / PGSIZE;
    800031a0:	40c9dc13          	srai	s8,s3,0xc

    // rmid 后禁止新 attach
    if(shm_is_deleted(key))
    800031a4:	06d030ef          	jal	ra,80006a10 <shm_is_deleted>
    800031a8:	16051663          	bnez	a0,80003314 <sys_mmap+0x20e>
      return (uint64)-1;

    // 按进程计数：本进程首次引用才 shm_get
    if(!proc_has_shm_key(p, key, 0))
    800031ac:	4601                	li	a2,0
    800031ae:	f8842583          	lw	a1,-120(s0)
    800031b2:	8556                	mv	a0,s5
    800031b4:	cf7ff0ef          	jal	ra,80002eaa <proc_has_shm_key>
  int need_get = 0;
    800031b8:	00153b93          	seqz	s7,a0
    800031bc:	a011                	j	800031c0 <sys_mmap+0xba>
  int npages = 0;
    800031be:	8c5e                	mv	s8,s7
  for(int i = 0; i < NVMA; i++){
    800031c0:	168a8b13          	addi	s6,s5,360
  int npages = 0;
    800031c4:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    800031c6:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    800031c8:	4398                	lw	a4,0(a5)
    800031ca:	cb01                	beqz	a4,800031da <sys_mmap+0xd4>
  for(int i = 0; i < NVMA; i++){
    800031cc:	2905                	addiw	s2,s2,1
    800031ce:	02878793          	addi	a5,a5,40
    800031d2:	fed91be3          	bne	s2,a3,800031c8 <sys_mmap+0xc2>
      need_get = 1;
  }

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    800031d6:	54fd                	li	s1,-1
    800031d8:	aa35                	j	80003314 <sys_mmap+0x20e>
  uint64 plen = PGROUNDUP((uint64)len);
    800031da:	74fd                	lui	s1,0xfffff
    800031dc:	0099f9b3          	and	s3,s3,s1
      return &p->vmas[i];
    800031e0:	00291c93          	slli	s9,s2,0x2
    800031e4:	012c8533          	add	a0,s9,s2
    800031e8:	050e                	slli	a0,a0,0x3
    800031ea:	16850513          	addi	a0,a0,360

  // 先清空这条 slot，避免失败时留下脏状态
  memset(v, 0, sizeof(*v));
    800031ee:	02800613          	li	a2,40
    800031f2:	4581                	li	a1,0
    800031f4:	9556                	add	a0,a0,s5
    800031f6:	b8ffd0ef          	jal	ra,80000d84 <memset>
  v->shm_key = -1;
    800031fa:	012c87b3          	add	a5,s9,s2
    800031fe:	078e                	slli	a5,a5,0x3
    80003200:	97d6                	add	a5,a5,s5
    80003202:	577d                	li	a4,-1
    80003204:	18e7a623          	sw	a4,396(a5)
  len = PGROUNDUP(len);  // 将长度向上对齐到页边界
    80003208:	6805                	lui	a6,0x1
    8000320a:	187d                	addi	a6,a6,-1
    8000320c:	984e                	add	a6,a6,s3
    8000320e:	00987833          	and	a6,a6,s1
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003212:	400005b7          	lui	a1,0x40000
    80003216:	95c2                	add	a1,a1,a6
    80003218:	400004b7          	lui	s1,0x40000
    8000321c:	3e8a8613          	addi	a2,s5,1000
    va = PGROUNDUP(jump);
    80003220:	6305                	lui	t1,0x1
    80003222:	137d                	addi	t1,t1,-1
    80003224:	7e7d                	lui	t3,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003226:	f3fff8b7          	lui	a7,0xf3fff
    8000322a:	08ba                	slli	a7,a7,0xe
    8000322c:	01a8d893          	srli	a7,a7,0x1a
    80003230:	a81d                	j	80003266 <sys_mmap+0x160>
      if(best == 0 || e < best) best = e;
    80003232:	8536                	mv	a0,a3
  for(int i=0; i<NVMA; i++){
    80003234:	02878793          	addi	a5,a5,40
    80003238:	00c78f63          	beq	a5,a2,80003256 <sys_mmap+0x150>
    if(!p->vmas[i].used) continue;
    8000323c:	4398                	lw	a4,0(a5)
    8000323e:	db7d                	beqz	a4,80003234 <sys_mmap+0x12e>
    uint64 e = p->vmas[i].end;
    80003240:	6b94                	ld	a3,16(a5)
    if(!(end <= s || start >= e)){
    80003242:	6798                	ld	a4,8(a5)
    80003244:	feb778e3          	bgeu	a4,a1,80003234 <sys_mmap+0x12e>
    80003248:	fed4f6e3          	bgeu	s1,a3,80003234 <sys_mmap+0x12e>
      if(best == 0 || e < best) best = e;
    8000324c:	d17d                	beqz	a0,80003232 <sys_mmap+0x12c>
    8000324e:	fea6f3e3          	bgeu	a3,a0,80003234 <sys_mmap+0x12e>
    80003252:	8536                	mv	a0,a3
    80003254:	b7c5                	j	80003234 <sys_mmap+0x12e>
    if(jump == 0){
    80003256:	c919                	beqz	a0,8000326c <sys_mmap+0x166>
    va = PGROUNDUP(jump);
    80003258:	951a                	add	a0,a0,t1
    8000325a:	01c574b3          	and	s1,a0,t3
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    8000325e:	009805b3          	add	a1,a6,s1
    80003262:	06b8ed63          	bltu	a7,a1,800032dc <sys_mmap+0x1d6>
  int npages = 0;
    80003266:	87da                	mv	a5,s6
  uint64 best = 0;
    80003268:	8552                	mv	a0,s4
    8000326a:	bfc9                	j	8000323c <sys_mmap+0x136>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) goto bad;
  if(va < MMAPBASE || va + plen > MMAPTOP) goto bad;
    8000326c:	400007b7          	lui	a5,0x40000
    80003270:	06f4e663          	bltu	s1,a5,800032dc <sys_mmap+0x1d6>
    80003274:	99a6                	add	s3,s3,s1
    80003276:	010007b7          	lui	a5,0x1000
    8000327a:	17f5                	addi	a5,a5,-3
    8000327c:	07ba                	slli	a5,a5,0xe
    8000327e:	0537ef63          	bltu	a5,s3,800032dc <sys_mmap+0x1d6>

  // 先写入 vma 基本信息
  v->used  = 1;
    80003282:	00291793          	slli	a5,s2,0x2
    80003286:	97ca                	add	a5,a5,s2
    80003288:	078e                	slli	a5,a5,0x3
    8000328a:	97d6                	add	a5,a5,s5
    8000328c:	4705                	li	a4,1
    8000328e:	16e7a423          	sw	a4,360(a5) # 1000168 <_entry-0x7efffe98>
  v->start = va;
    80003292:	1697b823          	sd	s1,368(a5)
  v->end   = va + plen;
    80003296:	1737bc23          	sd	s3,376(a5)
  v->prot  = prot;
    8000329a:	f9042703          	lw	a4,-112(s0)
    8000329e:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    800032a2:	f8c42703          	lw	a4,-116(s0)
    800032a6:	18e7a223          	sw	a4,388(a5)

  if(flags & MAP_SHARED){
    800032aa:	8b09                	andi	a4,a4,2
    800032ac:	c725                	beqz	a4,80003314 <sys_mmap+0x20e>
    if(need_get){
    800032ae:	020b9063          	bnez	s7,800032ce <sys_mmap+0x1c8>
      if(shm_get(key, npages) < 0)
        goto bad;
      did_shm_get = 1;
    }
    v->is_shm = 1;
    800032b2:	00291793          	slli	a5,s2,0x2
    800032b6:	01278733          	add	a4,a5,s2
    800032ba:	070e                	slli	a4,a4,0x3
    800032bc:	9756                	add	a4,a4,s5
    800032be:	4685                	li	a3,1
    800032c0:	18d72423          	sw	a3,392(a4) # 2000188 <_entry-0x7dfffe78>
    v->shm_key = key;
    800032c4:	f8842783          	lw	a5,-120(s0)
    800032c8:	18f72623          	sw	a5,396(a4)
    800032cc:	a0a1                	j	80003314 <sys_mmap+0x20e>
      if(shm_get(key, npages) < 0)
    800032ce:	85e2                	mv	a1,s8
    800032d0:	f8842503          	lw	a0,-120(s0)
    800032d4:	2fc030ef          	jal	ra,800065d0 <shm_get>
    800032d8:	fc055de3          	bgez	a0,800032b2 <sys_mmap+0x1ac>
bad:
  if(did_shm_get){
    shm_put(key);
  }
  if(v){
    v->used = 0;
    800032dc:	00291713          	slli	a4,s2,0x2
    800032e0:	012707b3          	add	a5,a4,s2
    800032e4:	078e                	slli	a5,a5,0x3
    800032e6:	97d6                	add	a5,a5,s5
    800032e8:	1607a423          	sw	zero,360(a5)
    v->is_shm = 0;
    800032ec:	1807a423          	sw	zero,392(a5)
    v->shm_key = -1;
    800032f0:	56fd                	li	a3,-1
    800032f2:	18d7a623          	sw	a3,396(a5)
    v->start = v->end = 0;
    800032f6:	1607bc23          	sd	zero,376(a5)
    800032fa:	1607b823          	sd	zero,368(a5)
    v->prot = v->flags = 0;
    800032fe:	1807a223          	sw	zero,388(a5)
    80003302:	012707b3          	add	a5,a4,s2
    80003306:	078e                	slli	a5,a5,0x3
    80003308:	9abe                	add	s5,s5,a5
    8000330a:	180aa023          	sw	zero,384(s5)
  }
  return (uint64)-1;
    8000330e:	54fd                	li	s1,-1
    80003310:	a011                	j	80003314 <sys_mmap+0x20e>
  if(len <= 0) return (uint64)-1;
    80003312:	54fd                	li	s1,-1
}
    80003314:	8526                	mv	a0,s1
    80003316:	70e6                	ld	ra,120(sp)
    80003318:	7446                	ld	s0,112(sp)
    8000331a:	74a6                	ld	s1,104(sp)
    8000331c:	7906                	ld	s2,96(sp)
    8000331e:	69e6                	ld	s3,88(sp)
    80003320:	6a46                	ld	s4,80(sp)
    80003322:	6aa6                	ld	s5,72(sp)
    80003324:	6b06                	ld	s6,64(sp)
    80003326:	7be2                	ld	s7,56(sp)
    80003328:	7c42                	ld	s8,48(sp)
    8000332a:	7ca2                	ld	s9,40(sp)
    8000332c:	6109                	addi	sp,sp,128
    8000332e:	8082                	ret

0000000080003330 <sys_munmap>:
}


uint64
sys_munmap(void)
{
    80003330:	7159                	addi	sp,sp,-112
    80003332:	f486                	sd	ra,104(sp)
    80003334:	f0a2                	sd	s0,96(sp)
    80003336:	eca6                	sd	s1,88(sp)
    80003338:	e8ca                	sd	s2,80(sp)
    8000333a:	e4ce                	sd	s3,72(sp)
    8000333c:	e0d2                	sd	s4,64(sp)
    8000333e:	fc56                	sd	s5,56(sp)
    80003340:	f85a                	sd	s6,48(sp)
    80003342:	f45e                	sd	s7,40(sp)
    80003344:	f062                	sd	s8,32(sp)
    80003346:	ec66                	sd	s9,24(sp)
    80003348:	e86a                	sd	s10,16(sp)
    8000334a:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    8000334c:	865fe0ef          	jal	ra,80001bb0 <myproc>
    80003350:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    80003352:	f9840593          	addi	a1,s0,-104
    80003356:	4501                	li	a0,0
    80003358:	aa3ff0ef          	jal	ra,80002dfa <argaddr>
  argint(1, &len);
    8000335c:	f9440593          	addi	a1,s0,-108
    80003360:	4505                	li	a0,1
    80003362:	a7dff0ef          	jal	ra,80002dde <argint>

  if(len <= 0) return (uint64)-1;
    80003366:	f9442703          	lw	a4,-108(s0)
    8000336a:	2ce05e63          	blez	a4,80003646 <sys_munmap+0x316>


  uint64 a = PGROUNDDOWN(uaddr);
    8000336e:	f9843783          	ld	a5,-104(s0)
    80003372:	76fd                	lui	a3,0xfffff
    80003374:	00d7fa33          	and	s4,a5,a3
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    80003378:	6905                	lui	s2,0x1
    8000337a:	197d                	addi	s2,s2,-1
    8000337c:	993e                	add	s2,s2,a5
    8000337e:	993a                	add	s2,s2,a4
    80003380:	00d97933          	and	s2,s2,a3
  if(b < a) return (uint64)-1;  // 溢出了
    80003384:	557d                	li	a0,-1
    80003386:	17496d63          	bltu	s2,s4,80003500 <sys_munmap+0x1d0>
    8000338a:	168a8b13          	addi	s6,s5,360
    8000338e:	3e8a8993          	addi	s3,s5,1000
    80003392:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    80003394:	4801                	li	a6,0
    80003396:	a029                	j	800033a0 <sys_munmap+0x70>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    80003398:	02878793          	addi	a5,a5,40
    8000339c:	01378663          	beq	a5,s3,800033a8 <sys_munmap+0x78>
    800033a0:	4398                	lw	a4,0(a5)
    800033a2:	fb7d                	bnez	a4,80003398 <sys_munmap+0x68>
    800033a4:	2805                	addiw	a6,a6,1
    800033a6:	bfcd                	j	80003398 <sys_munmap+0x68>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    800033a8:	8552                	mv	a0,s4
  int need_splits = 0;
    800033aa:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    800033ac:	4881                	li	a7,0
    800033ae:	45c1                	li	a1,16
    800033b0:	537d                	li	t1,-1
  while(cur < b){
    800033b2:	072a6163          	bltu	s4,s2,80003414 <sys_munmap+0xe4>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    800033b6:	43f85513          	srai	a0,a6,0x3f
    800033ba:	a299                	j	80003500 <sys_munmap+0x1d0>
  for(int i = 0; i < NVMA; i++){
    800033bc:	2705                	addiw	a4,a4,1
    800033be:	02878793          	addi	a5,a5,40
    800033c2:	04b70c63          	beq	a4,a1,8000341a <sys_munmap+0xea>
    if(!p->vmas[i].used) continue;
    800033c6:	4394                	lw	a3,0(a5)
    800033c8:	daf5                	beqz	a3,800033bc <sys_munmap+0x8c>
    if(!(b <= s || a >= e))   // 存在地址重叠
    800033ca:	6794                	ld	a3,8(a5)
    800033cc:	ff26f8e3          	bgeu	a3,s2,800033bc <sys_munmap+0x8c>
    800033d0:	6b94                	ld	a3,16(a5)
    800033d2:	fed575e3          	bgeu	a0,a3,800033bc <sys_munmap+0x8c>
    if(vi < 0){
    800033d6:	04074563          	bltz	a4,80003420 <sys_munmap+0xf0>
    uint64 seg_start = cur > v->start ? cur : v->start;
    800033da:	00271793          	slli	a5,a4,0x2
    800033de:	97ba                	add	a5,a5,a4
    800033e0:	078e                	slli	a5,a5,0x3
    800033e2:	97d6                	add	a5,a5,s5
    800033e4:	1707b683          	ld	a3,368(a5)
    800033e8:	8636                	mv	a2,a3
    800033ea:	00a6f363          	bgeu	a3,a0,800033f0 <sys_munmap+0xc0>
    800033ee:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    800033f0:	00271793          	slli	a5,a4,0x2
    800033f4:	97ba                	add	a5,a5,a4
    800033f6:	078e                	slli	a5,a5,0x3
    800033f8:	97d6                	add	a5,a5,s5
    800033fa:	1787b783          	ld	a5,376(a5)
    800033fe:	853e                	mv	a0,a5
    80003400:	00f97363          	bgeu	s2,a5,80003406 <sys_munmap+0xd6>
    80003404:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    80003406:	00c6f563          	bgeu	a3,a2,80003410 <sys_munmap+0xe0>
    8000340a:	00f57363          	bgeu	a0,a5,80003410 <sys_munmap+0xe0>
      need_splits++;
    8000340e:	2e05                	addiw	t3,t3,1
  while(cur < b){
    80003410:	03257a63          	bgeu	a0,s2,80003444 <sys_munmap+0x114>
  int free_slots = 0;
    80003414:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003416:	8746                	mv	a4,a7
    80003418:	b77d                	j	800033c6 <sys_munmap+0x96>
    8000341a:	87da                	mv	a5,s6
    8000341c:	869a                	mv	a3,t1
    8000341e:	a801                	j	8000342e <sys_munmap+0xfe>
    80003420:	87da                	mv	a5,s6
    80003422:	869a                	mv	a3,t1
    80003424:	a029                	j	8000342e <sys_munmap+0xfe>
  for(int i = 0; i < NVMA; i++){
    80003426:	02878793          	addi	a5,a5,40
    8000342a:	01378b63          	beq	a5,s3,80003440 <sys_munmap+0x110>
    if(!p->vmas[i].used) continue;
    8000342e:	4398                	lw	a4,0(a5)
    80003430:	db7d                	beqz	a4,80003426 <sys_munmap+0xf6>
    uint64 s = p->vmas[i].start;
    80003432:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    80003434:	fea769e3          	bltu	a4,a0,80003426 <sys_munmap+0xf6>
    80003438:	fed777e3          	bgeu	a4,a3,80003426 <sys_munmap+0xf6>
    8000343c:	86ba                	mv	a3,a4
    8000343e:	b7e5                	j	80003426 <sys_munmap+0xf6>
      if(ns == (uint64)-1 || ns >= b) break;
    80003440:	0126e963          	bltu	a3,s2,80003452 <sys_munmap+0x122>
    // 不做任何事，保持一致性
    return (uint64)-1;
    80003444:	557d                	li	a0,-1
  if(need_splits > free_slots){
    80003446:	0bc84d63          	blt	a6,t3,80003500 <sys_munmap+0x1d0>
  for(int i = 0; i < NVMA; i++){
    8000344a:	4c01                	li	s8,0
    8000344c:	4bc1                	li	s7,16
    8000344e:	5cfd                	li	s9,-1
    80003450:	aac5                	j	80003640 <sys_munmap+0x310>
    80003452:	8536                	mv	a0,a3
    80003454:	b7c1                	j	80003414 <sys_munmap+0xe4>
    80003456:	2485                	addiw	s1,s1,1
    80003458:	02878793          	addi	a5,a5,40
    8000345c:	07748c63          	beq	s1,s7,800034d4 <sys_munmap+0x1a4>
    if(!p->vmas[i].used) continue;
    80003460:	4398                	lw	a4,0(a5)
    80003462:	db75                	beqz	a4,80003456 <sys_munmap+0x126>
    if(!(b <= s || a >= e))   // 存在地址重叠
    80003464:	6798                	ld	a4,8(a5)
    80003466:	ff2778e3          	bgeu	a4,s2,80003456 <sys_munmap+0x126>
    8000346a:	6b98                	ld	a4,16(a5)
    8000346c:	feea75e3          	bgeu	s4,a4,80003456 <sys_munmap+0x126>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    80003470:	0604c563          	bltz	s1,800034da <sys_munmap+0x1aa>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    80003474:	00249793          	slli	a5,s1,0x2
    80003478:	97a6                	add	a5,a5,s1
    8000347a:	078e                	slli	a5,a5,0x3
    8000347c:	97d6                	add	a5,a5,s5
    8000347e:	1707bd03          	ld	s10,368(a5)
    80003482:	014d7363          	bgeu	s10,s4,80003488 <sys_munmap+0x158>
    80003486:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003488:	00249793          	slli	a5,s1,0x2
    8000348c:	97a6                	add	a5,a5,s1
    8000348e:	078e                	slli	a5,a5,0x3
    80003490:	97d6                	add	a5,a5,s5
    80003492:	1787ba03          	ld	s4,376(a5)
    80003496:	01497363          	bgeu	s2,s4,8000349c <sys_munmap+0x16c>
    8000349a:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    8000349c:	094d6263          	bltu	s10,s4,80003520 <sys_munmap+0x1f0>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    800034a0:	00249793          	slli	a5,s1,0x2
    800034a4:	97a6                	add	a5,a5,s1
    800034a6:	078e                	slli	a5,a5,0x3
    800034a8:	97d6                	add	a5,a5,s5
    800034aa:	1707b783          	ld	a5,368(a5)
    800034ae:	11a7e463          	bltu	a5,s10,800035b6 <sys_munmap+0x286>
    800034b2:	00249793          	slli	a5,s1,0x2
    800034b6:	97a6                	add	a5,a5,s1
    800034b8:	078e                	slli	a5,a5,0x3
    800034ba:	97d6                	add	a5,a5,s5
    800034bc:	1787b783          	ld	a5,376(a5)
    800034c0:	06fa7a63          	bgeu	s4,a5,80003534 <sys_munmap+0x204>
      //  v->shm_key, v->used, (void *)v->start, (void *)v->end);

      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    800034c4:	00249793          	slli	a5,s1,0x2
    800034c8:	97a6                	add	a5,a5,s1
    800034ca:	078e                	slli	a5,a5,0x3
    800034cc:	97d6                	add	a5,a5,s5
    800034ce:	1747b823          	sd	s4,368(a5)
    800034d2:	a2ad                	j	8000363c <sys_munmap+0x30c>
    800034d4:	87da                	mv	a5,s6
    800034d6:	86e6                	mv	a3,s9
    800034d8:	a801                	j	800034e8 <sys_munmap+0x1b8>
    800034da:	87da                	mv	a5,s6
    800034dc:	86e6                	mv	a3,s9
    800034de:	a029                	j	800034e8 <sys_munmap+0x1b8>
  for(int i = 0; i < NVMA; i++){
    800034e0:	02878793          	addi	a5,a5,40
    800034e4:	01378b63          	beq	a5,s3,800034fa <sys_munmap+0x1ca>
    if(!p->vmas[i].used) continue;
    800034e8:	4398                	lw	a4,0(a5)
    800034ea:	db7d                	beqz	a4,800034e0 <sys_munmap+0x1b0>
    uint64 s = p->vmas[i].start;
    800034ec:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    800034ee:	ff4769e3          	bltu	a4,s4,800034e0 <sys_munmap+0x1b0>
    800034f2:	fed777e3          	bgeu	a4,a3,800034e0 <sys_munmap+0x1b0>
    800034f6:	86ba                	mv	a3,a4
    800034f8:	b7e5                	j	800034e0 <sys_munmap+0x1b0>
      if(ns == (uint64)-1 || ns >= b) break;
    800034fa:	0326e163          	bltu	a3,s2,8000351c <sys_munmap+0x1ec>
    }

    cur = seg_end;
  }
  //shm_dump(1);
  return 0;
    800034fe:	4501                	li	a0,0
}
    80003500:	70a6                	ld	ra,104(sp)
    80003502:	7406                	ld	s0,96(sp)
    80003504:	64e6                	ld	s1,88(sp)
    80003506:	6946                	ld	s2,80(sp)
    80003508:	69a6                	ld	s3,72(sp)
    8000350a:	6a06                	ld	s4,64(sp)
    8000350c:	7ae2                	ld	s5,56(sp)
    8000350e:	7b42                	ld	s6,48(sp)
    80003510:	7ba2                	ld	s7,40(sp)
    80003512:	7c02                	ld	s8,32(sp)
    80003514:	6ce2                	ld	s9,24(sp)
    80003516:	6d42                	ld	s10,16(sp)
    80003518:	6165                	addi	sp,sp,112
    8000351a:	8082                	ret
    8000351c:	8a36                	mv	s4,a3
    8000351e:	a20d                	j	80003640 <sys_munmap+0x310>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    80003520:	41aa0633          	sub	a2,s4,s10
    80003524:	4685                	li	a3,1
    80003526:	8231                	srli	a2,a2,0xc
    80003528:	85ea                	mv	a1,s10
    8000352a:	050ab503          	ld	a0,80(s5)
    8000352e:	d83fd0ef          	jal	ra,800012b0 <uvmunmap>
    80003532:	b7bd                	j	800034a0 <sys_munmap+0x170>
  if(v->used == 0) return;
    80003534:	00249793          	slli	a5,s1,0x2
    80003538:	97a6                	add	a5,a5,s1
    8000353a:	078e                	slli	a5,a5,0x3
    8000353c:	97d6                	add	a5,a5,s5
    8000353e:	1687a783          	lw	a5,360(a5)
    80003542:	0e078d63          	beqz	a5,8000363c <sys_munmap+0x30c>
  if(v->is_shm){
    80003546:	00249793          	slli	a5,s1,0x2
    8000354a:	97a6                	add	a5,a5,s1
    8000354c:	078e                	slli	a5,a5,0x3
    8000354e:	97d6                	add	a5,a5,s5
    80003550:	1887a783          	lw	a5,392(a5)
    80003554:	c785                	beqz	a5,8000357c <sys_munmap+0x24c>
    int key = v->shm_key;
    80003556:	00249793          	slli	a5,s1,0x2
    8000355a:	00978733          	add	a4,a5,s1
    8000355e:	070e                	slli	a4,a4,0x3
    80003560:	9756                	add	a4,a4,s5
    80003562:	18c72d03          	lw	s10,396(a4)
    struct vma *v = &p->vmas[vi];
    80003566:	00978633          	add	a2,a5,s1
    8000356a:	060e                	slli	a2,a2,0x3
    8000356c:	16860613          	addi	a2,a2,360 # 1168 <_entry-0x7fffee98>
    if(!proc_has_shm_key(p, key, v)){
    80003570:	9656                	add	a2,a2,s5
    80003572:	85ea                	mv	a1,s10
    80003574:	8556                	mv	a0,s5
    80003576:	935ff0ef          	jal	ra,80002eaa <proc_has_shm_key>
    8000357a:	c915                	beqz	a0,800035ae <sys_munmap+0x27e>
  v->used = 0;
    8000357c:	00249713          	slli	a4,s1,0x2
    80003580:	009707b3          	add	a5,a4,s1
    80003584:	078e                	slli	a5,a5,0x3
    80003586:	97d6                	add	a5,a5,s5
    80003588:	1607a423          	sw	zero,360(a5)
  v->start = v->end = 0;
    8000358c:	1607bc23          	sd	zero,376(a5)
    80003590:	1607b823          	sd	zero,368(a5)
  v->prot = v->flags = 0;
    80003594:	1807a223          	sw	zero,388(a5)
    80003598:	1807a023          	sw	zero,384(a5)
  v->is_shm = 0;
    8000359c:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    800035a0:	009707b3          	add	a5,a4,s1
    800035a4:	078e                	slli	a5,a5,0x3
    800035a6:	97d6                	add	a5,a5,s5
    800035a8:	1997a623          	sw	s9,396(a5)
    800035ac:	a841                	j	8000363c <sys_munmap+0x30c>
      shm_put(key);  // 没有其他引用，释放共享内存
    800035ae:	856a                	mv	a0,s10
    800035b0:	164030ef          	jal	ra,80006714 <shm_put>
    800035b4:	b7e1                	j	8000357c <sys_munmap+0x24c>
    } else if(seg_start > v->start && seg_end >= v->end){
    800035b6:	00249793          	slli	a5,s1,0x2
    800035ba:	97a6                	add	a5,a5,s1
    800035bc:	078e                	slli	a5,a5,0x3
    800035be:	97d6                	add	a5,a5,s5
    800035c0:	1787b783          	ld	a5,376(a5)
    800035c4:	00fa6a63          	bltu	s4,a5,800035d8 <sys_munmap+0x2a8>
      v->end = seg_start;
    800035c8:	00249793          	slli	a5,s1,0x2
    800035cc:	97a6                	add	a5,a5,s1
    800035ce:	078e                	slli	a5,a5,0x3
    800035d0:	97d6                	add	a5,a5,s5
    800035d2:	17a7bc23          	sd	s10,376(a5)
    800035d6:	a09d                	j	8000363c <sys_munmap+0x30c>
    800035d8:	875a                	mv	a4,s6
    800035da:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    800035dc:	4314                	lw	a3,0(a4)
    800035de:	c699                	beqz	a3,800035ec <sys_munmap+0x2bc>
  for(int i = 0; i < NVMA; i++){
    800035e0:	2785                	addiw	a5,a5,1
    800035e2:	02870713          	addi	a4,a4,40
    800035e6:	ff779be3          	bne	a5,s7,800035dc <sys_munmap+0x2ac>
  return -1;  // 没有空闲的VMA索引
    800035ea:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    800035ec:	00279593          	slli	a1,a5,0x2
    800035f0:	00f586b3          	add	a3,a1,a5
    800035f4:	068e                	slli	a3,a3,0x3
    800035f6:	96d6                	add	a3,a3,s5
    800035f8:	00249613          	slli	a2,s1,0x2
    800035fc:	00960733          	add	a4,a2,s1
    80003600:	070e                	slli	a4,a4,0x3
    80003602:	9756                	add	a4,a4,s5
    80003604:	16873303          	ld	t1,360(a4)
    80003608:	17873883          	ld	a7,376(a4)
    8000360c:	18073803          	ld	a6,384(a4)
    80003610:	18873503          	ld	a0,392(a4)
    80003614:	1666b423          	sd	t1,360(a3) # fffffffffffff168 <end+0xffffffff7fdaaf68>
    80003618:	1716bc23          	sd	a7,376(a3)
    8000361c:	1906b023          	sd	a6,384(a3)
    80003620:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    80003624:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    80003628:	17873703          	ld	a4,376(a4)
    8000362c:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    80003630:	009607b3          	add	a5,a2,s1
    80003634:	078e                	slli	a5,a5,0x3
    80003636:	97d6                	add	a5,a5,s5
    80003638:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    8000363c:	012a7763          	bgeu	s4,s2,8000364a <sys_munmap+0x31a>
  int need_splits = 0;
    80003640:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003642:	84e2                	mv	s1,s8
    80003644:	bd31                	j	80003460 <sys_munmap+0x130>
  if(len <= 0) return (uint64)-1;
    80003646:	557d                	li	a0,-1
    80003648:	bd65                	j	80003500 <sys_munmap+0x1d0>
  return 0;
    8000364a:	4501                	li	a0,0
    8000364c:	bd55                	j	80003500 <sys_munmap+0x1d0>

000000008000364e <sys_shmctl>:

uint64
sys_shmctl(void)
{
    8000364e:	1101                	addi	sp,sp,-32
    80003650:	ec06                	sd	ra,24(sp)
    80003652:	e822                	sd	s0,16(sp)
    80003654:	1000                	addi	s0,sp,32
  int key, cmd;
  argint(0, &key);
    80003656:	fec40593          	addi	a1,s0,-20
    8000365a:	4501                	li	a0,0
    8000365c:	f82ff0ef          	jal	ra,80002dde <argint>
  argint(1, &cmd);
    80003660:	fe840593          	addi	a1,s0,-24
    80003664:	4505                	li	a0,1
    80003666:	f78ff0ef          	jal	ra,80002dde <argint>
  return shm_ctl(key, cmd);
    8000366a:	fe842583          	lw	a1,-24(s0)
    8000366e:	fec42503          	lw	a0,-20(s0)
    80003672:	294030ef          	jal	ra,80006906 <shm_ctl>
}
    80003676:	60e2                	ld	ra,24(sp)
    80003678:	6442                	ld	s0,16(sp)
    8000367a:	6105                	addi	sp,sp,32
    8000367c:	8082                	ret

000000008000367e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000367e:	7139                	addi	sp,sp,-64
    80003680:	fc06                	sd	ra,56(sp)
    80003682:	f822                	sd	s0,48(sp)
    80003684:	f426                	sd	s1,40(sp)
    80003686:	f04a                	sd	s2,32(sp)
    80003688:	ec4e                	sd	s3,24(sp)
    8000368a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000368c:	fcc40593          	addi	a1,s0,-52
    80003690:	4501                	li	a0,0
    80003692:	f4cff0ef          	jal	ra,80002dde <argint>
  if(n < 0)
    80003696:	fcc42783          	lw	a5,-52(s0)
    return -1;
    8000369a:	557d                	li	a0,-1
  if(n < 0)
    8000369c:	0407ce63          	bltz	a5,800036f8 <sys_sleep+0x7a>

  acquire(&tickslock);
    800036a0:	0023d517          	auipc	a0,0x23d
    800036a4:	1a050513          	addi	a0,a0,416 # 80240840 <tickslock>
    800036a8:	e08fd0ef          	jal	ra,80000cb0 <acquire>
  ticks0 = ticks;
    800036ac:	00005917          	auipc	s2,0x5
    800036b0:	21c92903          	lw	s2,540(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    800036b4:	fcc42783          	lw	a5,-52(s0)
    800036b8:	cb8d                	beqz	a5,800036ea <sys_sleep+0x6c>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);  
    800036ba:	0023d997          	auipc	s3,0x23d
    800036be:	18698993          	addi	s3,s3,390 # 80240840 <tickslock>
    800036c2:	00005497          	auipc	s1,0x5
    800036c6:	20648493          	addi	s1,s1,518 # 800088c8 <ticks>
    if(killed(myproc())){
    800036ca:	ce6fe0ef          	jal	ra,80001bb0 <myproc>
    800036ce:	812ff0ef          	jal	ra,800026e0 <killed>
    800036d2:	e915                	bnez	a0,80003706 <sys_sleep+0x88>
    sleep(&ticks, &tickslock);  
    800036d4:	85ce                	mv	a1,s3
    800036d6:	8526                	mv	a0,s1
    800036d8:	dd1fe0ef          	jal	ra,800024a8 <sleep>
  while(ticks - ticks0 < n){
    800036dc:	409c                	lw	a5,0(s1)
    800036de:	412787bb          	subw	a5,a5,s2
    800036e2:	fcc42703          	lw	a4,-52(s0)
    800036e6:	fee7e2e3          	bltu	a5,a4,800036ca <sys_sleep+0x4c>
  }
  release(&tickslock);
    800036ea:	0023d517          	auipc	a0,0x23d
    800036ee:	15650513          	addi	a0,a0,342 # 80240840 <tickslock>
    800036f2:	e56fd0ef          	jal	ra,80000d48 <release>
  return 0;
    800036f6:	4501                	li	a0,0
}
    800036f8:	70e2                	ld	ra,56(sp)
    800036fa:	7442                	ld	s0,48(sp)
    800036fc:	74a2                	ld	s1,40(sp)
    800036fe:	7902                	ld	s2,32(sp)
    80003700:	69e2                	ld	s3,24(sp)
    80003702:	6121                	addi	sp,sp,64
    80003704:	8082                	ret
      release(&tickslock);
    80003706:	0023d517          	auipc	a0,0x23d
    8000370a:	13a50513          	addi	a0,a0,314 # 80240840 <tickslock>
    8000370e:	e3afd0ef          	jal	ra,80000d48 <release>
      return -1;
    80003712:	557d                	li	a0,-1
    80003714:	b7d5                	j	800036f8 <sys_sleep+0x7a>

0000000080003716 <sys_vmstats>:


uint64
sys_vmstats(void)
{
    80003716:	711d                	addi	sp,sp,-96
    80003718:	ec86                	sd	ra,88(sp)
    8000371a:	e8a2                	sd	s0,80(sp)
    8000371c:	1080                	addi	s0,sp,96
  uint64 uaddr;
  argaddr(0, &uaddr);
    8000371e:	fe840593          	addi	a1,s0,-24
    80003722:	4501                	li	a0,0
    80003724:	ed6ff0ef          	jal	ra,80002dfa <argaddr>

  struct vmstats_user s;
  vmstats_snapshot(&s);
    80003728:	fa840513          	addi	a0,s0,-88
    8000372c:	5ee030ef          	jal	ra,80006d1a <vmstats_snapshot>

  extern uint64 kalloc_cnt, copyin_bytes, copyout_bytes, fork_copy_pages, fork_share_pages;
  s.kalloc_cnt = kalloc_cnt;
    80003730:	00005797          	auipc	a5,0x5
    80003734:	1c07b783          	ld	a5,448(a5) # 800088f0 <kalloc_cnt>
    80003738:	fcf43023          	sd	a5,-64(s0)
  s.copyin_bytes = copyin_bytes;
    8000373c:	00005797          	auipc	a5,0x5
    80003740:	1ac7b783          	ld	a5,428(a5) # 800088e8 <copyin_bytes>
    80003744:	fcf43423          	sd	a5,-56(s0)
  s.copyout_bytes = copyout_bytes;
    80003748:	00005797          	auipc	a5,0x5
    8000374c:	1987b783          	ld	a5,408(a5) # 800088e0 <copyout_bytes>
    80003750:	fcf43823          	sd	a5,-48(s0)
  s.fork_copy_pages  = fork_copy_pages;   
    80003754:	00005797          	auipc	a5,0x5
    80003758:	1847b783          	ld	a5,388(a5) # 800088d8 <fork_copy_pages>
    8000375c:	fcf43c23          	sd	a5,-40(s0)
  s.fork_share_pages = fork_share_pages;  
    80003760:	00005797          	auipc	a5,0x5
    80003764:	1707b783          	ld	a5,368(a5) # 800088d0 <fork_share_pages>
    80003768:	fef43023          	sd	a5,-32(s0)

  if(copyout(myproc()->pagetable, uaddr, (char*)&s, sizeof(s)) < 0)
    8000376c:	c44fe0ef          	jal	ra,80001bb0 <myproc>
    80003770:	04000693          	li	a3,64
    80003774:	fa840613          	addi	a2,s0,-88
    80003778:	fe843583          	ld	a1,-24(s0)
    8000377c:	6928                	ld	a0,80(a0)
    8000377e:	822fe0ef          	jal	ra,800017a0 <copyout>
    return -1;
  return 0;
    80003782:	957d                	srai	a0,a0,0x3f
    80003784:	60e6                	ld	ra,88(sp)
    80003786:	6446                	ld	s0,80(sp)
    80003788:	6125                	addi	sp,sp,96
    8000378a:	8082                	ret

000000008000378c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000378c:	7179                	addi	sp,sp,-48
    8000378e:	f406                	sd	ra,40(sp)
    80003790:	f022                	sd	s0,32(sp)
    80003792:	ec26                	sd	s1,24(sp)
    80003794:	e84a                	sd	s2,16(sp)
    80003796:	e44e                	sd	s3,8(sp)
    80003798:	e052                	sd	s4,0(sp)
    8000379a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000379c:	00005597          	auipc	a1,0x5
    800037a0:	d4c58593          	addi	a1,a1,-692 # 800084e8 <syscalls+0xf0>
    800037a4:	0023d517          	auipc	a0,0x23d
    800037a8:	0b450513          	addi	a0,a0,180 # 80240858 <bcache>
    800037ac:	c84fd0ef          	jal	ra,80000c30 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800037b0:	00245797          	auipc	a5,0x245
    800037b4:	0a878793          	addi	a5,a5,168 # 80248858 <bcache+0x8000>
    800037b8:	00245717          	auipc	a4,0x245
    800037bc:	30870713          	addi	a4,a4,776 # 80248ac0 <bcache+0x8268>
    800037c0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800037c4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037c8:	0023d497          	auipc	s1,0x23d
    800037cc:	0a848493          	addi	s1,s1,168 # 80240870 <bcache+0x18>
    b->next = bcache.head.next;
    800037d0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800037d2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800037d4:	00005a17          	auipc	s4,0x5
    800037d8:	d1ca0a13          	addi	s4,s4,-740 # 800084f0 <syscalls+0xf8>
    b->next = bcache.head.next;
    800037dc:	2b893783          	ld	a5,696(s2)
    800037e0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800037e2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800037e6:	85d2                	mv	a1,s4
    800037e8:	01048513          	addi	a0,s1,16
    800037ec:	2fe010ef          	jal	ra,80004aea <initsleeplock>
    bcache.head.next->prev = b;
    800037f0:	2b893783          	ld	a5,696(s2)
    800037f4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800037f6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037fa:	45848493          	addi	s1,s1,1112
    800037fe:	fd349fe3          	bne	s1,s3,800037dc <binit+0x50>
  }
}
    80003802:	70a2                	ld	ra,40(sp)
    80003804:	7402                	ld	s0,32(sp)
    80003806:	64e2                	ld	s1,24(sp)
    80003808:	6942                	ld	s2,16(sp)
    8000380a:	69a2                	ld	s3,8(sp)
    8000380c:	6a02                	ld	s4,0(sp)
    8000380e:	6145                	addi	sp,sp,48
    80003810:	8082                	ret

0000000080003812 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003812:	7179                	addi	sp,sp,-48
    80003814:	f406                	sd	ra,40(sp)
    80003816:	f022                	sd	s0,32(sp)
    80003818:	ec26                	sd	s1,24(sp)
    8000381a:	e84a                	sd	s2,16(sp)
    8000381c:	e44e                	sd	s3,8(sp)
    8000381e:	1800                	addi	s0,sp,48
    80003820:	892a                	mv	s2,a0
    80003822:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003824:	0023d517          	auipc	a0,0x23d
    80003828:	03450513          	addi	a0,a0,52 # 80240858 <bcache>
    8000382c:	c84fd0ef          	jal	ra,80000cb0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003830:	00245497          	auipc	s1,0x245
    80003834:	2e04b483          	ld	s1,736(s1) # 80248b10 <bcache+0x82b8>
    80003838:	00245797          	auipc	a5,0x245
    8000383c:	28878793          	addi	a5,a5,648 # 80248ac0 <bcache+0x8268>
    80003840:	02f48b63          	beq	s1,a5,80003876 <bread+0x64>
    80003844:	873e                	mv	a4,a5
    80003846:	a021                	j	8000384e <bread+0x3c>
    80003848:	68a4                	ld	s1,80(s1)
    8000384a:	02e48663          	beq	s1,a4,80003876 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000384e:	449c                	lw	a5,8(s1)
    80003850:	ff279ce3          	bne	a5,s2,80003848 <bread+0x36>
    80003854:	44dc                	lw	a5,12(s1)
    80003856:	ff3799e3          	bne	a5,s3,80003848 <bread+0x36>
      b->refcnt++;
    8000385a:	40bc                	lw	a5,64(s1)
    8000385c:	2785                	addiw	a5,a5,1
    8000385e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003860:	0023d517          	auipc	a0,0x23d
    80003864:	ff850513          	addi	a0,a0,-8 # 80240858 <bcache>
    80003868:	ce0fd0ef          	jal	ra,80000d48 <release>
      acquiresleep(&b->lock);
    8000386c:	01048513          	addi	a0,s1,16
    80003870:	2b0010ef          	jal	ra,80004b20 <acquiresleep>
      return b;
    80003874:	a889                	j	800038c6 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003876:	00245497          	auipc	s1,0x245
    8000387a:	2924b483          	ld	s1,658(s1) # 80248b08 <bcache+0x82b0>
    8000387e:	00245797          	auipc	a5,0x245
    80003882:	24278793          	addi	a5,a5,578 # 80248ac0 <bcache+0x8268>
    80003886:	00f48863          	beq	s1,a5,80003896 <bread+0x84>
    8000388a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000388c:	40bc                	lw	a5,64(s1)
    8000388e:	cb91                	beqz	a5,800038a2 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003890:	64a4                	ld	s1,72(s1)
    80003892:	fee49de3          	bne	s1,a4,8000388c <bread+0x7a>
  panic("bget: no buffers");
    80003896:	00005517          	auipc	a0,0x5
    8000389a:	c6250513          	addi	a0,a0,-926 # 800084f8 <syscalls+0x100>
    8000389e:	eedfc0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    800038a2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800038a6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800038aa:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800038ae:	4785                	li	a5,1
    800038b0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038b2:	0023d517          	auipc	a0,0x23d
    800038b6:	fa650513          	addi	a0,a0,-90 # 80240858 <bcache>
    800038ba:	c8efd0ef          	jal	ra,80000d48 <release>
      acquiresleep(&b->lock);
    800038be:	01048513          	addi	a0,s1,16
    800038c2:	25e010ef          	jal	ra,80004b20 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800038c6:	409c                	lw	a5,0(s1)
    800038c8:	cb89                	beqz	a5,800038da <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800038ca:	8526                	mv	a0,s1
    800038cc:	70a2                	ld	ra,40(sp)
    800038ce:	7402                	ld	s0,32(sp)
    800038d0:	64e2                	ld	s1,24(sp)
    800038d2:	6942                	ld	s2,16(sp)
    800038d4:	69a2                	ld	s3,8(sp)
    800038d6:	6145                	addi	sp,sp,48
    800038d8:	8082                	ret
    virtio_disk_rw(b, 0);
    800038da:	4581                	li	a1,0
    800038dc:	8526                	mv	a0,s1
    800038de:	20f020ef          	jal	ra,800062ec <virtio_disk_rw>
    b->valid = 1;
    800038e2:	4785                	li	a5,1
    800038e4:	c09c                	sw	a5,0(s1)
  return b;
    800038e6:	b7d5                	j	800038ca <bread+0xb8>

00000000800038e8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800038e8:	1101                	addi	sp,sp,-32
    800038ea:	ec06                	sd	ra,24(sp)
    800038ec:	e822                	sd	s0,16(sp)
    800038ee:	e426                	sd	s1,8(sp)
    800038f0:	1000                	addi	s0,sp,32
    800038f2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038f4:	0541                	addi	a0,a0,16
    800038f6:	2a8010ef          	jal	ra,80004b9e <holdingsleep>
    800038fa:	c911                	beqz	a0,8000390e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800038fc:	4585                	li	a1,1
    800038fe:	8526                	mv	a0,s1
    80003900:	1ed020ef          	jal	ra,800062ec <virtio_disk_rw>
}
    80003904:	60e2                	ld	ra,24(sp)
    80003906:	6442                	ld	s0,16(sp)
    80003908:	64a2                	ld	s1,8(sp)
    8000390a:	6105                	addi	sp,sp,32
    8000390c:	8082                	ret
    panic("bwrite");
    8000390e:	00005517          	auipc	a0,0x5
    80003912:	c0250513          	addi	a0,a0,-1022 # 80008510 <syscalls+0x118>
    80003916:	e75fc0ef          	jal	ra,8000078a <panic>

000000008000391a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000391a:	1101                	addi	sp,sp,-32
    8000391c:	ec06                	sd	ra,24(sp)
    8000391e:	e822                	sd	s0,16(sp)
    80003920:	e426                	sd	s1,8(sp)
    80003922:	e04a                	sd	s2,0(sp)
    80003924:	1000                	addi	s0,sp,32
    80003926:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003928:	01050913          	addi	s2,a0,16
    8000392c:	854a                	mv	a0,s2
    8000392e:	270010ef          	jal	ra,80004b9e <holdingsleep>
    80003932:	c13d                	beqz	a0,80003998 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80003934:	854a                	mv	a0,s2
    80003936:	230010ef          	jal	ra,80004b66 <releasesleep>

  acquire(&bcache.lock);
    8000393a:	0023d517          	auipc	a0,0x23d
    8000393e:	f1e50513          	addi	a0,a0,-226 # 80240858 <bcache>
    80003942:	b6efd0ef          	jal	ra,80000cb0 <acquire>
  b->refcnt--;
    80003946:	40bc                	lw	a5,64(s1)
    80003948:	37fd                	addiw	a5,a5,-1
    8000394a:	0007871b          	sext.w	a4,a5
    8000394e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003950:	eb05                	bnez	a4,80003980 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003952:	68bc                	ld	a5,80(s1)
    80003954:	64b8                	ld	a4,72(s1)
    80003956:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003958:	64bc                	ld	a5,72(s1)
    8000395a:	68b8                	ld	a4,80(s1)
    8000395c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000395e:	00245797          	auipc	a5,0x245
    80003962:	efa78793          	addi	a5,a5,-262 # 80248858 <bcache+0x8000>
    80003966:	2b87b703          	ld	a4,696(a5)
    8000396a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000396c:	00245717          	auipc	a4,0x245
    80003970:	15470713          	addi	a4,a4,340 # 80248ac0 <bcache+0x8268>
    80003974:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003976:	2b87b703          	ld	a4,696(a5)
    8000397a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000397c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003980:	0023d517          	auipc	a0,0x23d
    80003984:	ed850513          	addi	a0,a0,-296 # 80240858 <bcache>
    80003988:	bc0fd0ef          	jal	ra,80000d48 <release>
}
    8000398c:	60e2                	ld	ra,24(sp)
    8000398e:	6442                	ld	s0,16(sp)
    80003990:	64a2                	ld	s1,8(sp)
    80003992:	6902                	ld	s2,0(sp)
    80003994:	6105                	addi	sp,sp,32
    80003996:	8082                	ret
    panic("brelse");
    80003998:	00005517          	auipc	a0,0x5
    8000399c:	b8050513          	addi	a0,a0,-1152 # 80008518 <syscalls+0x120>
    800039a0:	debfc0ef          	jal	ra,8000078a <panic>

00000000800039a4 <bpin>:

void
bpin(struct buf *b) {
    800039a4:	1101                	addi	sp,sp,-32
    800039a6:	ec06                	sd	ra,24(sp)
    800039a8:	e822                	sd	s0,16(sp)
    800039aa:	e426                	sd	s1,8(sp)
    800039ac:	1000                	addi	s0,sp,32
    800039ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039b0:	0023d517          	auipc	a0,0x23d
    800039b4:	ea850513          	addi	a0,a0,-344 # 80240858 <bcache>
    800039b8:	af8fd0ef          	jal	ra,80000cb0 <acquire>
  b->refcnt++;
    800039bc:	40bc                	lw	a5,64(s1)
    800039be:	2785                	addiw	a5,a5,1
    800039c0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039c2:	0023d517          	auipc	a0,0x23d
    800039c6:	e9650513          	addi	a0,a0,-362 # 80240858 <bcache>
    800039ca:	b7efd0ef          	jal	ra,80000d48 <release>
}
    800039ce:	60e2                	ld	ra,24(sp)
    800039d0:	6442                	ld	s0,16(sp)
    800039d2:	64a2                	ld	s1,8(sp)
    800039d4:	6105                	addi	sp,sp,32
    800039d6:	8082                	ret

00000000800039d8 <bunpin>:

void
bunpin(struct buf *b) {
    800039d8:	1101                	addi	sp,sp,-32
    800039da:	ec06                	sd	ra,24(sp)
    800039dc:	e822                	sd	s0,16(sp)
    800039de:	e426                	sd	s1,8(sp)
    800039e0:	1000                	addi	s0,sp,32
    800039e2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039e4:	0023d517          	auipc	a0,0x23d
    800039e8:	e7450513          	addi	a0,a0,-396 # 80240858 <bcache>
    800039ec:	ac4fd0ef          	jal	ra,80000cb0 <acquire>
  b->refcnt--;
    800039f0:	40bc                	lw	a5,64(s1)
    800039f2:	37fd                	addiw	a5,a5,-1
    800039f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039f6:	0023d517          	auipc	a0,0x23d
    800039fa:	e6250513          	addi	a0,a0,-414 # 80240858 <bcache>
    800039fe:	b4afd0ef          	jal	ra,80000d48 <release>
}
    80003a02:	60e2                	ld	ra,24(sp)
    80003a04:	6442                	ld	s0,16(sp)
    80003a06:	64a2                	ld	s1,8(sp)
    80003a08:	6105                	addi	sp,sp,32
    80003a0a:	8082                	ret

0000000080003a0c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a0c:	1101                	addi	sp,sp,-32
    80003a0e:	ec06                	sd	ra,24(sp)
    80003a10:	e822                	sd	s0,16(sp)
    80003a12:	e426                	sd	s1,8(sp)
    80003a14:	e04a                	sd	s2,0(sp)
    80003a16:	1000                	addi	s0,sp,32
    80003a18:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a1a:	00d5d59b          	srliw	a1,a1,0xd
    80003a1e:	00245797          	auipc	a5,0x245
    80003a22:	5167a783          	lw	a5,1302(a5) # 80248f34 <sb+0x1c>
    80003a26:	9dbd                	addw	a1,a1,a5
    80003a28:	debff0ef          	jal	ra,80003812 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003a2c:	0074f713          	andi	a4,s1,7
    80003a30:	4785                	li	a5,1
    80003a32:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a36:	14ce                	slli	s1,s1,0x33
    80003a38:	90d9                	srli	s1,s1,0x36
    80003a3a:	00950733          	add	a4,a0,s1
    80003a3e:	05874703          	lbu	a4,88(a4)
    80003a42:	00e7f6b3          	and	a3,a5,a4
    80003a46:	c29d                	beqz	a3,80003a6c <bfree+0x60>
    80003a48:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a4a:	94aa                	add	s1,s1,a0
    80003a4c:	fff7c793          	not	a5,a5
    80003a50:	8ff9                	and	a5,a5,a4
    80003a52:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003a56:	7d1000ef          	jal	ra,80004a26 <log_write>
  brelse(bp);
    80003a5a:	854a                	mv	a0,s2
    80003a5c:	ebfff0ef          	jal	ra,8000391a <brelse>
}
    80003a60:	60e2                	ld	ra,24(sp)
    80003a62:	6442                	ld	s0,16(sp)
    80003a64:	64a2                	ld	s1,8(sp)
    80003a66:	6902                	ld	s2,0(sp)
    80003a68:	6105                	addi	sp,sp,32
    80003a6a:	8082                	ret
    panic("freeing free block");
    80003a6c:	00005517          	auipc	a0,0x5
    80003a70:	ab450513          	addi	a0,a0,-1356 # 80008520 <syscalls+0x128>
    80003a74:	d17fc0ef          	jal	ra,8000078a <panic>

0000000080003a78 <balloc>:
{
    80003a78:	711d                	addi	sp,sp,-96
    80003a7a:	ec86                	sd	ra,88(sp)
    80003a7c:	e8a2                	sd	s0,80(sp)
    80003a7e:	e4a6                	sd	s1,72(sp)
    80003a80:	e0ca                	sd	s2,64(sp)
    80003a82:	fc4e                	sd	s3,56(sp)
    80003a84:	f852                	sd	s4,48(sp)
    80003a86:	f456                	sd	s5,40(sp)
    80003a88:	f05a                	sd	s6,32(sp)
    80003a8a:	ec5e                	sd	s7,24(sp)
    80003a8c:	e862                	sd	s8,16(sp)
    80003a8e:	e466                	sd	s9,8(sp)
    80003a90:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a92:	00245797          	auipc	a5,0x245
    80003a96:	48a7a783          	lw	a5,1162(a5) # 80248f1c <sb+0x4>
    80003a9a:	0e078163          	beqz	a5,80003b7c <balloc+0x104>
    80003a9e:	8baa                	mv	s7,a0
    80003aa0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003aa2:	00245b17          	auipc	s6,0x245
    80003aa6:	476b0b13          	addi	s6,s6,1142 # 80248f18 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aaa:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003aac:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aae:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003ab0:	6c89                	lui	s9,0x2
    80003ab2:	a0b5                	j	80003b1e <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003ab4:	974a                	add	a4,a4,s2
    80003ab6:	8fd5                	or	a5,a5,a3
    80003ab8:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003abc:	854a                	mv	a0,s2
    80003abe:	769000ef          	jal	ra,80004a26 <log_write>
        brelse(bp);
    80003ac2:	854a                	mv	a0,s2
    80003ac4:	e57ff0ef          	jal	ra,8000391a <brelse>
  bp = bread(dev, bno);
    80003ac8:	85a6                	mv	a1,s1
    80003aca:	855e                	mv	a0,s7
    80003acc:	d47ff0ef          	jal	ra,80003812 <bread>
    80003ad0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003ad2:	40000613          	li	a2,1024
    80003ad6:	4581                	li	a1,0
    80003ad8:	05850513          	addi	a0,a0,88
    80003adc:	aa8fd0ef          	jal	ra,80000d84 <memset>
  log_write(bp);
    80003ae0:	854a                	mv	a0,s2
    80003ae2:	745000ef          	jal	ra,80004a26 <log_write>
  brelse(bp);
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	e33ff0ef          	jal	ra,8000391a <brelse>
}
    80003aec:	8526                	mv	a0,s1
    80003aee:	60e6                	ld	ra,88(sp)
    80003af0:	6446                	ld	s0,80(sp)
    80003af2:	64a6                	ld	s1,72(sp)
    80003af4:	6906                	ld	s2,64(sp)
    80003af6:	79e2                	ld	s3,56(sp)
    80003af8:	7a42                	ld	s4,48(sp)
    80003afa:	7aa2                	ld	s5,40(sp)
    80003afc:	7b02                	ld	s6,32(sp)
    80003afe:	6be2                	ld	s7,24(sp)
    80003b00:	6c42                	ld	s8,16(sp)
    80003b02:	6ca2                	ld	s9,8(sp)
    80003b04:	6125                	addi	sp,sp,96
    80003b06:	8082                	ret
    brelse(bp);
    80003b08:	854a                	mv	a0,s2
    80003b0a:	e11ff0ef          	jal	ra,8000391a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003b0e:	015c87bb          	addw	a5,s9,s5
    80003b12:	00078a9b          	sext.w	s5,a5
    80003b16:	004b2703          	lw	a4,4(s6)
    80003b1a:	06eaf163          	bgeu	s5,a4,80003b7c <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80003b1e:	41fad79b          	sraiw	a5,s5,0x1f
    80003b22:	0137d79b          	srliw	a5,a5,0x13
    80003b26:	015787bb          	addw	a5,a5,s5
    80003b2a:	40d7d79b          	sraiw	a5,a5,0xd
    80003b2e:	01cb2583          	lw	a1,28(s6)
    80003b32:	9dbd                	addw	a1,a1,a5
    80003b34:	855e                	mv	a0,s7
    80003b36:	cddff0ef          	jal	ra,80003812 <bread>
    80003b3a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b3c:	004b2503          	lw	a0,4(s6)
    80003b40:	000a849b          	sext.w	s1,s5
    80003b44:	8662                	mv	a2,s8
    80003b46:	fca4f1e3          	bgeu	s1,a0,80003b08 <balloc+0x90>
      m = 1 << (bi % 8);
    80003b4a:	41f6579b          	sraiw	a5,a2,0x1f
    80003b4e:	01d7d69b          	srliw	a3,a5,0x1d
    80003b52:	00c6873b          	addw	a4,a3,a2
    80003b56:	00777793          	andi	a5,a4,7
    80003b5a:	9f95                	subw	a5,a5,a3
    80003b5c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b60:	4037571b          	sraiw	a4,a4,0x3
    80003b64:	00e906b3          	add	a3,s2,a4
    80003b68:	0586c683          	lbu	a3,88(a3)
    80003b6c:	00d7f5b3          	and	a1,a5,a3
    80003b70:	d1b1                	beqz	a1,80003ab4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b72:	2605                	addiw	a2,a2,1
    80003b74:	2485                	addiw	s1,s1,1
    80003b76:	fd4618e3          	bne	a2,s4,80003b46 <balloc+0xce>
    80003b7a:	b779                	j	80003b08 <balloc+0x90>
  printf("balloc: out of blocks\n");
    80003b7c:	00005517          	auipc	a0,0x5
    80003b80:	9bc50513          	addi	a0,a0,-1604 # 80008538 <syscalls+0x140>
    80003b84:	941fc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003b88:	4481                	li	s1,0
    80003b8a:	b78d                	j	80003aec <balloc+0x74>

0000000080003b8c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b8c:	7179                	addi	sp,sp,-48
    80003b8e:	f406                	sd	ra,40(sp)
    80003b90:	f022                	sd	s0,32(sp)
    80003b92:	ec26                	sd	s1,24(sp)
    80003b94:	e84a                	sd	s2,16(sp)
    80003b96:	e44e                	sd	s3,8(sp)
    80003b98:	e052                	sd	s4,0(sp)
    80003b9a:	1800                	addi	s0,sp,48
    80003b9c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b9e:	47ad                	li	a5,11
    80003ba0:	02b7e563          	bltu	a5,a1,80003bca <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003ba4:	02059493          	slli	s1,a1,0x20
    80003ba8:	9081                	srli	s1,s1,0x20
    80003baa:	048a                	slli	s1,s1,0x2
    80003bac:	94aa                	add	s1,s1,a0
    80003bae:	0504a903          	lw	s2,80(s1)
    80003bb2:	06091663          	bnez	s2,80003c1e <bmap+0x92>
      addr = balloc(ip->dev);
    80003bb6:	4108                	lw	a0,0(a0)
    80003bb8:	ec1ff0ef          	jal	ra,80003a78 <balloc>
    80003bbc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bc0:	04090f63          	beqz	s2,80003c1e <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80003bc4:	0524a823          	sw	s2,80(s1)
    80003bc8:	a899                	j	80003c1e <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003bca:	ff45849b          	addiw	s1,a1,-12
    80003bce:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bd2:	0ff00793          	li	a5,255
    80003bd6:	06e7eb63          	bltu	a5,a4,80003c4c <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003bda:	08052903          	lw	s2,128(a0)
    80003bde:	00091b63          	bnez	s2,80003bf4 <bmap+0x68>
      addr = balloc(ip->dev);
    80003be2:	4108                	lw	a0,0(a0)
    80003be4:	e95ff0ef          	jal	ra,80003a78 <balloc>
    80003be8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bec:	02090963          	beqz	s2,80003c1e <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003bf0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003bf4:	85ca                	mv	a1,s2
    80003bf6:	0009a503          	lw	a0,0(s3)
    80003bfa:	c19ff0ef          	jal	ra,80003812 <bread>
    80003bfe:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003c00:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003c04:	02049593          	slli	a1,s1,0x20
    80003c08:	9181                	srli	a1,a1,0x20
    80003c0a:	058a                	slli	a1,a1,0x2
    80003c0c:	00b784b3          	add	s1,a5,a1
    80003c10:	0004a903          	lw	s2,0(s1)
    80003c14:	00090e63          	beqz	s2,80003c30 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003c18:	8552                	mv	a0,s4
    80003c1a:	d01ff0ef          	jal	ra,8000391a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c1e:	854a                	mv	a0,s2
    80003c20:	70a2                	ld	ra,40(sp)
    80003c22:	7402                	ld	s0,32(sp)
    80003c24:	64e2                	ld	s1,24(sp)
    80003c26:	6942                	ld	s2,16(sp)
    80003c28:	69a2                	ld	s3,8(sp)
    80003c2a:	6a02                	ld	s4,0(sp)
    80003c2c:	6145                	addi	sp,sp,48
    80003c2e:	8082                	ret
      addr = balloc(ip->dev);
    80003c30:	0009a503          	lw	a0,0(s3)
    80003c34:	e45ff0ef          	jal	ra,80003a78 <balloc>
    80003c38:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c3c:	fc090ee3          	beqz	s2,80003c18 <bmap+0x8c>
        a[bn] = addr;
    80003c40:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c44:	8552                	mv	a0,s4
    80003c46:	5e1000ef          	jal	ra,80004a26 <log_write>
    80003c4a:	b7f9                	j	80003c18 <bmap+0x8c>
  panic("bmap: out of range");
    80003c4c:	00005517          	auipc	a0,0x5
    80003c50:	90450513          	addi	a0,a0,-1788 # 80008550 <syscalls+0x158>
    80003c54:	b37fc0ef          	jal	ra,8000078a <panic>

0000000080003c58 <iget>:
{
    80003c58:	7179                	addi	sp,sp,-48
    80003c5a:	f406                	sd	ra,40(sp)
    80003c5c:	f022                	sd	s0,32(sp)
    80003c5e:	ec26                	sd	s1,24(sp)
    80003c60:	e84a                	sd	s2,16(sp)
    80003c62:	e44e                	sd	s3,8(sp)
    80003c64:	e052                	sd	s4,0(sp)
    80003c66:	1800                	addi	s0,sp,48
    80003c68:	89aa                	mv	s3,a0
    80003c6a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c6c:	00245517          	auipc	a0,0x245
    80003c70:	2cc50513          	addi	a0,a0,716 # 80248f38 <itable>
    80003c74:	83cfd0ef          	jal	ra,80000cb0 <acquire>
  empty = 0;
    80003c78:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c7a:	00245497          	auipc	s1,0x245
    80003c7e:	2d648493          	addi	s1,s1,726 # 80248f50 <itable+0x18>
    80003c82:	00247697          	auipc	a3,0x247
    80003c86:	d5e68693          	addi	a3,a3,-674 # 8024a9e0 <log>
    80003c8a:	a039                	j	80003c98 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c8c:	02090963          	beqz	s2,80003cbe <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c90:	08848493          	addi	s1,s1,136
    80003c94:	02d48863          	beq	s1,a3,80003cc4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c98:	449c                	lw	a5,8(s1)
    80003c9a:	fef059e3          	blez	a5,80003c8c <iget+0x34>
    80003c9e:	4098                	lw	a4,0(s1)
    80003ca0:	ff3716e3          	bne	a4,s3,80003c8c <iget+0x34>
    80003ca4:	40d8                	lw	a4,4(s1)
    80003ca6:	ff4713e3          	bne	a4,s4,80003c8c <iget+0x34>
      ip->ref++;
    80003caa:	2785                	addiw	a5,a5,1
    80003cac:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003cae:	00245517          	auipc	a0,0x245
    80003cb2:	28a50513          	addi	a0,a0,650 # 80248f38 <itable>
    80003cb6:	892fd0ef          	jal	ra,80000d48 <release>
      return ip;
    80003cba:	8926                	mv	s2,s1
    80003cbc:	a02d                	j	80003ce6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cbe:	fbe9                	bnez	a5,80003c90 <iget+0x38>
    80003cc0:	8926                	mv	s2,s1
    80003cc2:	b7f9                	j	80003c90 <iget+0x38>
  if(empty == 0)
    80003cc4:	02090a63          	beqz	s2,80003cf8 <iget+0xa0>
  ip->dev = dev;
    80003cc8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003ccc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003cd0:	4785                	li	a5,1
    80003cd2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003cd6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003cda:	00245517          	auipc	a0,0x245
    80003cde:	25e50513          	addi	a0,a0,606 # 80248f38 <itable>
    80003ce2:	866fd0ef          	jal	ra,80000d48 <release>
}
    80003ce6:	854a                	mv	a0,s2
    80003ce8:	70a2                	ld	ra,40(sp)
    80003cea:	7402                	ld	s0,32(sp)
    80003cec:	64e2                	ld	s1,24(sp)
    80003cee:	6942                	ld	s2,16(sp)
    80003cf0:	69a2                	ld	s3,8(sp)
    80003cf2:	6a02                	ld	s4,0(sp)
    80003cf4:	6145                	addi	sp,sp,48
    80003cf6:	8082                	ret
    panic("iget: no inodes");
    80003cf8:	00005517          	auipc	a0,0x5
    80003cfc:	87050513          	addi	a0,a0,-1936 # 80008568 <syscalls+0x170>
    80003d00:	a8bfc0ef          	jal	ra,8000078a <panic>

0000000080003d04 <iinit>:
{
    80003d04:	7179                	addi	sp,sp,-48
    80003d06:	f406                	sd	ra,40(sp)
    80003d08:	f022                	sd	s0,32(sp)
    80003d0a:	ec26                	sd	s1,24(sp)
    80003d0c:	e84a                	sd	s2,16(sp)
    80003d0e:	e44e                	sd	s3,8(sp)
    80003d10:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d12:	00005597          	auipc	a1,0x5
    80003d16:	86658593          	addi	a1,a1,-1946 # 80008578 <syscalls+0x180>
    80003d1a:	00245517          	auipc	a0,0x245
    80003d1e:	21e50513          	addi	a0,a0,542 # 80248f38 <itable>
    80003d22:	f0ffc0ef          	jal	ra,80000c30 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d26:	00245497          	auipc	s1,0x245
    80003d2a:	23a48493          	addi	s1,s1,570 # 80248f60 <itable+0x28>
    80003d2e:	00247997          	auipc	s3,0x247
    80003d32:	cc298993          	addi	s3,s3,-830 # 8024a9f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d36:	00005917          	auipc	s2,0x5
    80003d3a:	84a90913          	addi	s2,s2,-1974 # 80008580 <syscalls+0x188>
    80003d3e:	85ca                	mv	a1,s2
    80003d40:	8526                	mv	a0,s1
    80003d42:	5a9000ef          	jal	ra,80004aea <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d46:	08848493          	addi	s1,s1,136
    80003d4a:	ff349ae3          	bne	s1,s3,80003d3e <iinit+0x3a>
}
    80003d4e:	70a2                	ld	ra,40(sp)
    80003d50:	7402                	ld	s0,32(sp)
    80003d52:	64e2                	ld	s1,24(sp)
    80003d54:	6942                	ld	s2,16(sp)
    80003d56:	69a2                	ld	s3,8(sp)
    80003d58:	6145                	addi	sp,sp,48
    80003d5a:	8082                	ret

0000000080003d5c <ialloc>:
{
    80003d5c:	715d                	addi	sp,sp,-80
    80003d5e:	e486                	sd	ra,72(sp)
    80003d60:	e0a2                	sd	s0,64(sp)
    80003d62:	fc26                	sd	s1,56(sp)
    80003d64:	f84a                	sd	s2,48(sp)
    80003d66:	f44e                	sd	s3,40(sp)
    80003d68:	f052                	sd	s4,32(sp)
    80003d6a:	ec56                	sd	s5,24(sp)
    80003d6c:	e85a                	sd	s6,16(sp)
    80003d6e:	e45e                	sd	s7,8(sp)
    80003d70:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d72:	00245717          	auipc	a4,0x245
    80003d76:	1b272703          	lw	a4,434(a4) # 80248f24 <sb+0xc>
    80003d7a:	4785                	li	a5,1
    80003d7c:	04e7f663          	bgeu	a5,a4,80003dc8 <ialloc+0x6c>
    80003d80:	8aaa                	mv	s5,a0
    80003d82:	8bae                	mv	s7,a1
    80003d84:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d86:	00245a17          	auipc	s4,0x245
    80003d8a:	192a0a13          	addi	s4,s4,402 # 80248f18 <sb>
    80003d8e:	00048b1b          	sext.w	s6,s1
    80003d92:	0044d793          	srli	a5,s1,0x4
    80003d96:	018a2583          	lw	a1,24(s4)
    80003d9a:	9dbd                	addw	a1,a1,a5
    80003d9c:	8556                	mv	a0,s5
    80003d9e:	a75ff0ef          	jal	ra,80003812 <bread>
    80003da2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003da4:	05850993          	addi	s3,a0,88
    80003da8:	00f4f793          	andi	a5,s1,15
    80003dac:	079a                	slli	a5,a5,0x6
    80003dae:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003db0:	00099783          	lh	a5,0(s3)
    80003db4:	cf85                	beqz	a5,80003dec <ialloc+0x90>
    brelse(bp);
    80003db6:	b65ff0ef          	jal	ra,8000391a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dba:	0485                	addi	s1,s1,1
    80003dbc:	00ca2703          	lw	a4,12(s4)
    80003dc0:	0004879b          	sext.w	a5,s1
    80003dc4:	fce7e5e3          	bltu	a5,a4,80003d8e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003dc8:	00004517          	auipc	a0,0x4
    80003dcc:	7c050513          	addi	a0,a0,1984 # 80008588 <syscalls+0x190>
    80003dd0:	ef4fc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003dd4:	4501                	li	a0,0
}
    80003dd6:	60a6                	ld	ra,72(sp)
    80003dd8:	6406                	ld	s0,64(sp)
    80003dda:	74e2                	ld	s1,56(sp)
    80003ddc:	7942                	ld	s2,48(sp)
    80003dde:	79a2                	ld	s3,40(sp)
    80003de0:	7a02                	ld	s4,32(sp)
    80003de2:	6ae2                	ld	s5,24(sp)
    80003de4:	6b42                	ld	s6,16(sp)
    80003de6:	6ba2                	ld	s7,8(sp)
    80003de8:	6161                	addi	sp,sp,80
    80003dea:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003dec:	04000613          	li	a2,64
    80003df0:	4581                	li	a1,0
    80003df2:	854e                	mv	a0,s3
    80003df4:	f91fc0ef          	jal	ra,80000d84 <memset>
      dip->type = type;
    80003df8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003dfc:	854a                	mv	a0,s2
    80003dfe:	429000ef          	jal	ra,80004a26 <log_write>
      brelse(bp);
    80003e02:	854a                	mv	a0,s2
    80003e04:	b17ff0ef          	jal	ra,8000391a <brelse>
      return iget(dev, inum);
    80003e08:	85da                	mv	a1,s6
    80003e0a:	8556                	mv	a0,s5
    80003e0c:	e4dff0ef          	jal	ra,80003c58 <iget>
    80003e10:	b7d9                	j	80003dd6 <ialloc+0x7a>

0000000080003e12 <iupdate>:
{
    80003e12:	1101                	addi	sp,sp,-32
    80003e14:	ec06                	sd	ra,24(sp)
    80003e16:	e822                	sd	s0,16(sp)
    80003e18:	e426                	sd	s1,8(sp)
    80003e1a:	e04a                	sd	s2,0(sp)
    80003e1c:	1000                	addi	s0,sp,32
    80003e1e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e20:	415c                	lw	a5,4(a0)
    80003e22:	0047d79b          	srliw	a5,a5,0x4
    80003e26:	00245597          	auipc	a1,0x245
    80003e2a:	10a5a583          	lw	a1,266(a1) # 80248f30 <sb+0x18>
    80003e2e:	9dbd                	addw	a1,a1,a5
    80003e30:	4108                	lw	a0,0(a0)
    80003e32:	9e1ff0ef          	jal	ra,80003812 <bread>
    80003e36:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e38:	05850793          	addi	a5,a0,88
    80003e3c:	40c8                	lw	a0,4(s1)
    80003e3e:	893d                	andi	a0,a0,15
    80003e40:	051a                	slli	a0,a0,0x6
    80003e42:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e44:	04449703          	lh	a4,68(s1)
    80003e48:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e4c:	04649703          	lh	a4,70(s1)
    80003e50:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e54:	04849703          	lh	a4,72(s1)
    80003e58:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e5c:	04a49703          	lh	a4,74(s1)
    80003e60:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e64:	44f8                	lw	a4,76(s1)
    80003e66:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e68:	03400613          	li	a2,52
    80003e6c:	05048593          	addi	a1,s1,80
    80003e70:	0531                	addi	a0,a0,12
    80003e72:	f6ffc0ef          	jal	ra,80000de0 <memmove>
  log_write(bp);
    80003e76:	854a                	mv	a0,s2
    80003e78:	3af000ef          	jal	ra,80004a26 <log_write>
  brelse(bp);
    80003e7c:	854a                	mv	a0,s2
    80003e7e:	a9dff0ef          	jal	ra,8000391a <brelse>
}
    80003e82:	60e2                	ld	ra,24(sp)
    80003e84:	6442                	ld	s0,16(sp)
    80003e86:	64a2                	ld	s1,8(sp)
    80003e88:	6902                	ld	s2,0(sp)
    80003e8a:	6105                	addi	sp,sp,32
    80003e8c:	8082                	ret

0000000080003e8e <idup>:
{
    80003e8e:	1101                	addi	sp,sp,-32
    80003e90:	ec06                	sd	ra,24(sp)
    80003e92:	e822                	sd	s0,16(sp)
    80003e94:	e426                	sd	s1,8(sp)
    80003e96:	1000                	addi	s0,sp,32
    80003e98:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e9a:	00245517          	auipc	a0,0x245
    80003e9e:	09e50513          	addi	a0,a0,158 # 80248f38 <itable>
    80003ea2:	e0ffc0ef          	jal	ra,80000cb0 <acquire>
  ip->ref++;
    80003ea6:	449c                	lw	a5,8(s1)
    80003ea8:	2785                	addiw	a5,a5,1
    80003eaa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003eac:	00245517          	auipc	a0,0x245
    80003eb0:	08c50513          	addi	a0,a0,140 # 80248f38 <itable>
    80003eb4:	e95fc0ef          	jal	ra,80000d48 <release>
}
    80003eb8:	8526                	mv	a0,s1
    80003eba:	60e2                	ld	ra,24(sp)
    80003ebc:	6442                	ld	s0,16(sp)
    80003ebe:	64a2                	ld	s1,8(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret

0000000080003ec4 <ilock>:
{
    80003ec4:	1101                	addi	sp,sp,-32
    80003ec6:	ec06                	sd	ra,24(sp)
    80003ec8:	e822                	sd	s0,16(sp)
    80003eca:	e426                	sd	s1,8(sp)
    80003ecc:	e04a                	sd	s2,0(sp)
    80003ece:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ed0:	c105                	beqz	a0,80003ef0 <ilock+0x2c>
    80003ed2:	84aa                	mv	s1,a0
    80003ed4:	451c                	lw	a5,8(a0)
    80003ed6:	00f05d63          	blez	a5,80003ef0 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003eda:	0541                	addi	a0,a0,16
    80003edc:	445000ef          	jal	ra,80004b20 <acquiresleep>
  if(ip->valid == 0){
    80003ee0:	40bc                	lw	a5,64(s1)
    80003ee2:	cf89                	beqz	a5,80003efc <ilock+0x38>
}
    80003ee4:	60e2                	ld	ra,24(sp)
    80003ee6:	6442                	ld	s0,16(sp)
    80003ee8:	64a2                	ld	s1,8(sp)
    80003eea:	6902                	ld	s2,0(sp)
    80003eec:	6105                	addi	sp,sp,32
    80003eee:	8082                	ret
    panic("ilock");
    80003ef0:	00004517          	auipc	a0,0x4
    80003ef4:	6b050513          	addi	a0,a0,1712 # 800085a0 <syscalls+0x1a8>
    80003ef8:	893fc0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003efc:	40dc                	lw	a5,4(s1)
    80003efe:	0047d79b          	srliw	a5,a5,0x4
    80003f02:	00245597          	auipc	a1,0x245
    80003f06:	02e5a583          	lw	a1,46(a1) # 80248f30 <sb+0x18>
    80003f0a:	9dbd                	addw	a1,a1,a5
    80003f0c:	4088                	lw	a0,0(s1)
    80003f0e:	905ff0ef          	jal	ra,80003812 <bread>
    80003f12:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f14:	05850593          	addi	a1,a0,88
    80003f18:	40dc                	lw	a5,4(s1)
    80003f1a:	8bbd                	andi	a5,a5,15
    80003f1c:	079a                	slli	a5,a5,0x6
    80003f1e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f20:	00059783          	lh	a5,0(a1)
    80003f24:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f28:	00259783          	lh	a5,2(a1)
    80003f2c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f30:	00459783          	lh	a5,4(a1)
    80003f34:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f38:	00659783          	lh	a5,6(a1)
    80003f3c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f40:	459c                	lw	a5,8(a1)
    80003f42:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f44:	03400613          	li	a2,52
    80003f48:	05b1                	addi	a1,a1,12
    80003f4a:	05048513          	addi	a0,s1,80
    80003f4e:	e93fc0ef          	jal	ra,80000de0 <memmove>
    brelse(bp);
    80003f52:	854a                	mv	a0,s2
    80003f54:	9c7ff0ef          	jal	ra,8000391a <brelse>
    ip->valid = 1;
    80003f58:	4785                	li	a5,1
    80003f5a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f5c:	04449783          	lh	a5,68(s1)
    80003f60:	f3d1                	bnez	a5,80003ee4 <ilock+0x20>
      panic("ilock: no type");
    80003f62:	00004517          	auipc	a0,0x4
    80003f66:	64650513          	addi	a0,a0,1606 # 800085a8 <syscalls+0x1b0>
    80003f6a:	821fc0ef          	jal	ra,8000078a <panic>

0000000080003f6e <iunlock>:
{
    80003f6e:	1101                	addi	sp,sp,-32
    80003f70:	ec06                	sd	ra,24(sp)
    80003f72:	e822                	sd	s0,16(sp)
    80003f74:	e426                	sd	s1,8(sp)
    80003f76:	e04a                	sd	s2,0(sp)
    80003f78:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f7a:	c505                	beqz	a0,80003fa2 <iunlock+0x34>
    80003f7c:	84aa                	mv	s1,a0
    80003f7e:	01050913          	addi	s2,a0,16
    80003f82:	854a                	mv	a0,s2
    80003f84:	41b000ef          	jal	ra,80004b9e <holdingsleep>
    80003f88:	cd09                	beqz	a0,80003fa2 <iunlock+0x34>
    80003f8a:	449c                	lw	a5,8(s1)
    80003f8c:	00f05b63          	blez	a5,80003fa2 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003f90:	854a                	mv	a0,s2
    80003f92:	3d5000ef          	jal	ra,80004b66 <releasesleep>
}
    80003f96:	60e2                	ld	ra,24(sp)
    80003f98:	6442                	ld	s0,16(sp)
    80003f9a:	64a2                	ld	s1,8(sp)
    80003f9c:	6902                	ld	s2,0(sp)
    80003f9e:	6105                	addi	sp,sp,32
    80003fa0:	8082                	ret
    panic("iunlock");
    80003fa2:	00004517          	auipc	a0,0x4
    80003fa6:	61650513          	addi	a0,a0,1558 # 800085b8 <syscalls+0x1c0>
    80003faa:	fe0fc0ef          	jal	ra,8000078a <panic>

0000000080003fae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003fae:	7179                	addi	sp,sp,-48
    80003fb0:	f406                	sd	ra,40(sp)
    80003fb2:	f022                	sd	s0,32(sp)
    80003fb4:	ec26                	sd	s1,24(sp)
    80003fb6:	e84a                	sd	s2,16(sp)
    80003fb8:	e44e                	sd	s3,8(sp)
    80003fba:	e052                	sd	s4,0(sp)
    80003fbc:	1800                	addi	s0,sp,48
    80003fbe:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fc0:	05050493          	addi	s1,a0,80
    80003fc4:	08050913          	addi	s2,a0,128
    80003fc8:	a021                	j	80003fd0 <itrunc+0x22>
    80003fca:	0491                	addi	s1,s1,4
    80003fcc:	01248b63          	beq	s1,s2,80003fe2 <itrunc+0x34>
    if(ip->addrs[i]){
    80003fd0:	408c                	lw	a1,0(s1)
    80003fd2:	dde5                	beqz	a1,80003fca <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fd4:	0009a503          	lw	a0,0(s3)
    80003fd8:	a35ff0ef          	jal	ra,80003a0c <bfree>
      ip->addrs[i] = 0;
    80003fdc:	0004a023          	sw	zero,0(s1)
    80003fe0:	b7ed                	j	80003fca <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003fe2:	0809a583          	lw	a1,128(s3)
    80003fe6:	ed91                	bnez	a1,80004002 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fe8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003fec:	854e                	mv	a0,s3
    80003fee:	e25ff0ef          	jal	ra,80003e12 <iupdate>
}
    80003ff2:	70a2                	ld	ra,40(sp)
    80003ff4:	7402                	ld	s0,32(sp)
    80003ff6:	64e2                	ld	s1,24(sp)
    80003ff8:	6942                	ld	s2,16(sp)
    80003ffa:	69a2                	ld	s3,8(sp)
    80003ffc:	6a02                	ld	s4,0(sp)
    80003ffe:	6145                	addi	sp,sp,48
    80004000:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004002:	0009a503          	lw	a0,0(s3)
    80004006:	80dff0ef          	jal	ra,80003812 <bread>
    8000400a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000400c:	05850493          	addi	s1,a0,88
    80004010:	45850913          	addi	s2,a0,1112
    80004014:	a021                	j	8000401c <itrunc+0x6e>
    80004016:	0491                	addi	s1,s1,4
    80004018:	01248963          	beq	s1,s2,8000402a <itrunc+0x7c>
      if(a[j])
    8000401c:	408c                	lw	a1,0(s1)
    8000401e:	dde5                	beqz	a1,80004016 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80004020:	0009a503          	lw	a0,0(s3)
    80004024:	9e9ff0ef          	jal	ra,80003a0c <bfree>
    80004028:	b7fd                	j	80004016 <itrunc+0x68>
    brelse(bp);
    8000402a:	8552                	mv	a0,s4
    8000402c:	8efff0ef          	jal	ra,8000391a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004030:	0809a583          	lw	a1,128(s3)
    80004034:	0009a503          	lw	a0,0(s3)
    80004038:	9d5ff0ef          	jal	ra,80003a0c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000403c:	0809a023          	sw	zero,128(s3)
    80004040:	b765                	j	80003fe8 <itrunc+0x3a>

0000000080004042 <iput>:
{
    80004042:	1101                	addi	sp,sp,-32
    80004044:	ec06                	sd	ra,24(sp)
    80004046:	e822                	sd	s0,16(sp)
    80004048:	e426                	sd	s1,8(sp)
    8000404a:	e04a                	sd	s2,0(sp)
    8000404c:	1000                	addi	s0,sp,32
    8000404e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004050:	00245517          	auipc	a0,0x245
    80004054:	ee850513          	addi	a0,a0,-280 # 80248f38 <itable>
    80004058:	c59fc0ef          	jal	ra,80000cb0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000405c:	4498                	lw	a4,8(s1)
    8000405e:	4785                	li	a5,1
    80004060:	02f70163          	beq	a4,a5,80004082 <iput+0x40>
  ip->ref--;
    80004064:	449c                	lw	a5,8(s1)
    80004066:	37fd                	addiw	a5,a5,-1
    80004068:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000406a:	00245517          	auipc	a0,0x245
    8000406e:	ece50513          	addi	a0,a0,-306 # 80248f38 <itable>
    80004072:	cd7fc0ef          	jal	ra,80000d48 <release>
}
    80004076:	60e2                	ld	ra,24(sp)
    80004078:	6442                	ld	s0,16(sp)
    8000407a:	64a2                	ld	s1,8(sp)
    8000407c:	6902                	ld	s2,0(sp)
    8000407e:	6105                	addi	sp,sp,32
    80004080:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004082:	40bc                	lw	a5,64(s1)
    80004084:	d3e5                	beqz	a5,80004064 <iput+0x22>
    80004086:	04a49783          	lh	a5,74(s1)
    8000408a:	ffe9                	bnez	a5,80004064 <iput+0x22>
    acquiresleep(&ip->lock);
    8000408c:	01048913          	addi	s2,s1,16
    80004090:	854a                	mv	a0,s2
    80004092:	28f000ef          	jal	ra,80004b20 <acquiresleep>
    release(&itable.lock);
    80004096:	00245517          	auipc	a0,0x245
    8000409a:	ea250513          	addi	a0,a0,-350 # 80248f38 <itable>
    8000409e:	cabfc0ef          	jal	ra,80000d48 <release>
    itrunc(ip);
    800040a2:	8526                	mv	a0,s1
    800040a4:	f0bff0ef          	jal	ra,80003fae <itrunc>
    ip->type = 0;
    800040a8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040ac:	8526                	mv	a0,s1
    800040ae:	d65ff0ef          	jal	ra,80003e12 <iupdate>
    ip->valid = 0;
    800040b2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040b6:	854a                	mv	a0,s2
    800040b8:	2af000ef          	jal	ra,80004b66 <releasesleep>
    acquire(&itable.lock);
    800040bc:	00245517          	auipc	a0,0x245
    800040c0:	e7c50513          	addi	a0,a0,-388 # 80248f38 <itable>
    800040c4:	bedfc0ef          	jal	ra,80000cb0 <acquire>
    800040c8:	bf71                	j	80004064 <iput+0x22>

00000000800040ca <iunlockput>:
{
    800040ca:	1101                	addi	sp,sp,-32
    800040cc:	ec06                	sd	ra,24(sp)
    800040ce:	e822                	sd	s0,16(sp)
    800040d0:	e426                	sd	s1,8(sp)
    800040d2:	1000                	addi	s0,sp,32
    800040d4:	84aa                	mv	s1,a0
  iunlock(ip);
    800040d6:	e99ff0ef          	jal	ra,80003f6e <iunlock>
  iput(ip);
    800040da:	8526                	mv	a0,s1
    800040dc:	f67ff0ef          	jal	ra,80004042 <iput>
}
    800040e0:	60e2                	ld	ra,24(sp)
    800040e2:	6442                	ld	s0,16(sp)
    800040e4:	64a2                	ld	s1,8(sp)
    800040e6:	6105                	addi	sp,sp,32
    800040e8:	8082                	ret

00000000800040ea <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800040ea:	00245717          	auipc	a4,0x245
    800040ee:	e3a72703          	lw	a4,-454(a4) # 80248f24 <sb+0xc>
    800040f2:	4785                	li	a5,1
    800040f4:	0ae7ff63          	bgeu	a5,a4,800041b2 <ireclaim+0xc8>
{
    800040f8:	7139                	addi	sp,sp,-64
    800040fa:	fc06                	sd	ra,56(sp)
    800040fc:	f822                	sd	s0,48(sp)
    800040fe:	f426                	sd	s1,40(sp)
    80004100:	f04a                	sd	s2,32(sp)
    80004102:	ec4e                	sd	s3,24(sp)
    80004104:	e852                	sd	s4,16(sp)
    80004106:	e456                	sd	s5,8(sp)
    80004108:	e05a                	sd	s6,0(sp)
    8000410a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000410c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000410e:	00050a1b          	sext.w	s4,a0
    80004112:	00245a97          	auipc	s5,0x245
    80004116:	e06a8a93          	addi	s5,s5,-506 # 80248f18 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000411a:	00004b17          	auipc	s6,0x4
    8000411e:	4a6b0b13          	addi	s6,s6,1190 # 800085c0 <syscalls+0x1c8>
    80004122:	a099                	j	80004168 <ireclaim+0x7e>
    80004124:	85ce                	mv	a1,s3
    80004126:	855a                	mv	a0,s6
    80004128:	b9cfc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    8000412c:	85ce                	mv	a1,s3
    8000412e:	8552                	mv	a0,s4
    80004130:	b29ff0ef          	jal	ra,80003c58 <iget>
    80004134:	89aa                	mv	s3,a0
    brelse(bp);
    80004136:	854a                	mv	a0,s2
    80004138:	fe2ff0ef          	jal	ra,8000391a <brelse>
    if (ip) {
    8000413c:	00098f63          	beqz	s3,8000415a <ireclaim+0x70>
      begin_op();
    80004140:	762000ef          	jal	ra,800048a2 <begin_op>
      ilock(ip);
    80004144:	854e                	mv	a0,s3
    80004146:	d7fff0ef          	jal	ra,80003ec4 <ilock>
      iunlock(ip);
    8000414a:	854e                	mv	a0,s3
    8000414c:	e23ff0ef          	jal	ra,80003f6e <iunlock>
      iput(ip);
    80004150:	854e                	mv	a0,s3
    80004152:	ef1ff0ef          	jal	ra,80004042 <iput>
      end_op();
    80004156:	7bc000ef          	jal	ra,80004912 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000415a:	0485                	addi	s1,s1,1
    8000415c:	00caa703          	lw	a4,12(s5)
    80004160:	0004879b          	sext.w	a5,s1
    80004164:	02e7fd63          	bgeu	a5,a4,8000419e <ireclaim+0xb4>
    80004168:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000416c:	0044d793          	srli	a5,s1,0x4
    80004170:	018aa583          	lw	a1,24(s5)
    80004174:	9dbd                	addw	a1,a1,a5
    80004176:	8552                	mv	a0,s4
    80004178:	e9aff0ef          	jal	ra,80003812 <bread>
    8000417c:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000417e:	05850793          	addi	a5,a0,88
    80004182:	00f9f713          	andi	a4,s3,15
    80004186:	071a                	slli	a4,a4,0x6
    80004188:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000418a:	00079703          	lh	a4,0(a5)
    8000418e:	c701                	beqz	a4,80004196 <ireclaim+0xac>
    80004190:	00679783          	lh	a5,6(a5)
    80004194:	dbc1                	beqz	a5,80004124 <ireclaim+0x3a>
    brelse(bp);
    80004196:	854a                	mv	a0,s2
    80004198:	f82ff0ef          	jal	ra,8000391a <brelse>
    if (ip) {
    8000419c:	bf7d                	j	8000415a <ireclaim+0x70>
}
    8000419e:	70e2                	ld	ra,56(sp)
    800041a0:	7442                	ld	s0,48(sp)
    800041a2:	74a2                	ld	s1,40(sp)
    800041a4:	7902                	ld	s2,32(sp)
    800041a6:	69e2                	ld	s3,24(sp)
    800041a8:	6a42                	ld	s4,16(sp)
    800041aa:	6aa2                	ld	s5,8(sp)
    800041ac:	6b02                	ld	s6,0(sp)
    800041ae:	6121                	addi	sp,sp,64
    800041b0:	8082                	ret
    800041b2:	8082                	ret

00000000800041b4 <fsinit>:
fsinit(int dev) {
    800041b4:	7179                	addi	sp,sp,-48
    800041b6:	f406                	sd	ra,40(sp)
    800041b8:	f022                	sd	s0,32(sp)
    800041ba:	ec26                	sd	s1,24(sp)
    800041bc:	e84a                	sd	s2,16(sp)
    800041be:	e44e                	sd	s3,8(sp)
    800041c0:	1800                	addi	s0,sp,48
    800041c2:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800041c4:	4585                	li	a1,1
    800041c6:	e4cff0ef          	jal	ra,80003812 <bread>
    800041ca:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800041cc:	00245997          	auipc	s3,0x245
    800041d0:	d4c98993          	addi	s3,s3,-692 # 80248f18 <sb>
    800041d4:	02000613          	li	a2,32
    800041d8:	05850593          	addi	a1,a0,88
    800041dc:	854e                	mv	a0,s3
    800041de:	c03fc0ef          	jal	ra,80000de0 <memmove>
  brelse(bp);
    800041e2:	854a                	mv	a0,s2
    800041e4:	f36ff0ef          	jal	ra,8000391a <brelse>
  if(sb.magic != FSMAGIC)
    800041e8:	0009a703          	lw	a4,0(s3)
    800041ec:	102037b7          	lui	a5,0x10203
    800041f0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800041f4:	02f71363          	bne	a4,a5,8000421a <fsinit+0x66>
  initlog(dev, &sb);
    800041f8:	00245597          	auipc	a1,0x245
    800041fc:	d2058593          	addi	a1,a1,-736 # 80248f18 <sb>
    80004200:	8526                	mv	a0,s1
    80004202:	616000ef          	jal	ra,80004818 <initlog>
  ireclaim(dev);
    80004206:	8526                	mv	a0,s1
    80004208:	ee3ff0ef          	jal	ra,800040ea <ireclaim>
}
    8000420c:	70a2                	ld	ra,40(sp)
    8000420e:	7402                	ld	s0,32(sp)
    80004210:	64e2                	ld	s1,24(sp)
    80004212:	6942                	ld	s2,16(sp)
    80004214:	69a2                	ld	s3,8(sp)
    80004216:	6145                	addi	sp,sp,48
    80004218:	8082                	ret
    panic("invalid file system");
    8000421a:	00004517          	auipc	a0,0x4
    8000421e:	3c650513          	addi	a0,a0,966 # 800085e0 <syscalls+0x1e8>
    80004222:	d68fc0ef          	jal	ra,8000078a <panic>

0000000080004226 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004226:	1141                	addi	sp,sp,-16
    80004228:	e422                	sd	s0,8(sp)
    8000422a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000422c:	411c                	lw	a5,0(a0)
    8000422e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004230:	415c                	lw	a5,4(a0)
    80004232:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004234:	04451783          	lh	a5,68(a0)
    80004238:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000423c:	04a51783          	lh	a5,74(a0)
    80004240:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004244:	04c56783          	lwu	a5,76(a0)
    80004248:	e99c                	sd	a5,16(a1)
}
    8000424a:	6422                	ld	s0,8(sp)
    8000424c:	0141                	addi	sp,sp,16
    8000424e:	8082                	ret

0000000080004250 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004250:	457c                	lw	a5,76(a0)
    80004252:	0cd7ef63          	bltu	a5,a3,80004330 <readi+0xe0>
{
    80004256:	7159                	addi	sp,sp,-112
    80004258:	f486                	sd	ra,104(sp)
    8000425a:	f0a2                	sd	s0,96(sp)
    8000425c:	eca6                	sd	s1,88(sp)
    8000425e:	e8ca                	sd	s2,80(sp)
    80004260:	e4ce                	sd	s3,72(sp)
    80004262:	e0d2                	sd	s4,64(sp)
    80004264:	fc56                	sd	s5,56(sp)
    80004266:	f85a                	sd	s6,48(sp)
    80004268:	f45e                	sd	s7,40(sp)
    8000426a:	f062                	sd	s8,32(sp)
    8000426c:	ec66                	sd	s9,24(sp)
    8000426e:	e86a                	sd	s10,16(sp)
    80004270:	e46e                	sd	s11,8(sp)
    80004272:	1880                	addi	s0,sp,112
    80004274:	8b2a                	mv	s6,a0
    80004276:	8bae                	mv	s7,a1
    80004278:	8a32                	mv	s4,a2
    8000427a:	84b6                	mv	s1,a3
    8000427c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000427e:	9f35                	addw	a4,a4,a3
    return 0;
    80004280:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004282:	08d76663          	bltu	a4,a3,8000430e <readi+0xbe>
  if(off + n > ip->size)
    80004286:	00e7f463          	bgeu	a5,a4,8000428e <readi+0x3e>
    n = ip->size - off;
    8000428a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000428e:	080a8f63          	beqz	s5,8000432c <readi+0xdc>
    80004292:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004294:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004298:	5c7d                	li	s8,-1
    8000429a:	a80d                	j	800042cc <readi+0x7c>
    8000429c:	020d1d93          	slli	s11,s10,0x20
    800042a0:	020ddd93          	srli	s11,s11,0x20
    800042a4:	05890793          	addi	a5,s2,88
    800042a8:	86ee                	mv	a3,s11
    800042aa:	963e                	add	a2,a2,a5
    800042ac:	85d2                	mv	a1,s4
    800042ae:	855e                	mv	a0,s7
    800042b0:	d54fe0ef          	jal	ra,80002804 <either_copyout>
    800042b4:	05850763          	beq	a0,s8,80004302 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042b8:	854a                	mv	a0,s2
    800042ba:	e60ff0ef          	jal	ra,8000391a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042be:	013d09bb          	addw	s3,s10,s3
    800042c2:	009d04bb          	addw	s1,s10,s1
    800042c6:	9a6e                	add	s4,s4,s11
    800042c8:	0559f163          	bgeu	s3,s5,8000430a <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800042cc:	00a4d59b          	srliw	a1,s1,0xa
    800042d0:	855a                	mv	a0,s6
    800042d2:	8bbff0ef          	jal	ra,80003b8c <bmap>
    800042d6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042da:	c985                	beqz	a1,8000430a <readi+0xba>
    bp = bread(ip->dev, addr);
    800042dc:	000b2503          	lw	a0,0(s6)
    800042e0:	d32ff0ef          	jal	ra,80003812 <bread>
    800042e4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042e6:	3ff4f613          	andi	a2,s1,1023
    800042ea:	40cc87bb          	subw	a5,s9,a2
    800042ee:	413a873b          	subw	a4,s5,s3
    800042f2:	8d3e                	mv	s10,a5
    800042f4:	2781                	sext.w	a5,a5
    800042f6:	0007069b          	sext.w	a3,a4
    800042fa:	faf6f1e3          	bgeu	a3,a5,8000429c <readi+0x4c>
    800042fe:	8d3a                	mv	s10,a4
    80004300:	bf71                	j	8000429c <readi+0x4c>
      brelse(bp);
    80004302:	854a                	mv	a0,s2
    80004304:	e16ff0ef          	jal	ra,8000391a <brelse>
      tot = -1;
    80004308:	59fd                	li	s3,-1
  }
  return tot;
    8000430a:	0009851b          	sext.w	a0,s3
}
    8000430e:	70a6                	ld	ra,104(sp)
    80004310:	7406                	ld	s0,96(sp)
    80004312:	64e6                	ld	s1,88(sp)
    80004314:	6946                	ld	s2,80(sp)
    80004316:	69a6                	ld	s3,72(sp)
    80004318:	6a06                	ld	s4,64(sp)
    8000431a:	7ae2                	ld	s5,56(sp)
    8000431c:	7b42                	ld	s6,48(sp)
    8000431e:	7ba2                	ld	s7,40(sp)
    80004320:	7c02                	ld	s8,32(sp)
    80004322:	6ce2                	ld	s9,24(sp)
    80004324:	6d42                	ld	s10,16(sp)
    80004326:	6da2                	ld	s11,8(sp)
    80004328:	6165                	addi	sp,sp,112
    8000432a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000432c:	89d6                	mv	s3,s5
    8000432e:	bff1                	j	8000430a <readi+0xba>
    return 0;
    80004330:	4501                	li	a0,0
}
    80004332:	8082                	ret

0000000080004334 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004334:	457c                	lw	a5,76(a0)
    80004336:	0ed7ea63          	bltu	a5,a3,8000442a <writei+0xf6>
{
    8000433a:	7159                	addi	sp,sp,-112
    8000433c:	f486                	sd	ra,104(sp)
    8000433e:	f0a2                	sd	s0,96(sp)
    80004340:	eca6                	sd	s1,88(sp)
    80004342:	e8ca                	sd	s2,80(sp)
    80004344:	e4ce                	sd	s3,72(sp)
    80004346:	e0d2                	sd	s4,64(sp)
    80004348:	fc56                	sd	s5,56(sp)
    8000434a:	f85a                	sd	s6,48(sp)
    8000434c:	f45e                	sd	s7,40(sp)
    8000434e:	f062                	sd	s8,32(sp)
    80004350:	ec66                	sd	s9,24(sp)
    80004352:	e86a                	sd	s10,16(sp)
    80004354:	e46e                	sd	s11,8(sp)
    80004356:	1880                	addi	s0,sp,112
    80004358:	8aaa                	mv	s5,a0
    8000435a:	8bae                	mv	s7,a1
    8000435c:	8a32                	mv	s4,a2
    8000435e:	8936                	mv	s2,a3
    80004360:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004362:	00e687bb          	addw	a5,a3,a4
    80004366:	0cd7e463          	bltu	a5,a3,8000442e <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000436a:	00043737          	lui	a4,0x43
    8000436e:	0cf76263          	bltu	a4,a5,80004432 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004372:	0a0b0a63          	beqz	s6,80004426 <writei+0xf2>
    80004376:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004378:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000437c:	5c7d                	li	s8,-1
    8000437e:	a825                	j	800043b6 <writei+0x82>
    80004380:	020d1d93          	slli	s11,s10,0x20
    80004384:	020ddd93          	srli	s11,s11,0x20
    80004388:	05848793          	addi	a5,s1,88
    8000438c:	86ee                	mv	a3,s11
    8000438e:	8652                	mv	a2,s4
    80004390:	85de                	mv	a1,s7
    80004392:	953e                	add	a0,a0,a5
    80004394:	cbafe0ef          	jal	ra,8000284e <either_copyin>
    80004398:	05850a63          	beq	a0,s8,800043ec <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000439c:	8526                	mv	a0,s1
    8000439e:	688000ef          	jal	ra,80004a26 <log_write>
    brelse(bp);
    800043a2:	8526                	mv	a0,s1
    800043a4:	d76ff0ef          	jal	ra,8000391a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043a8:	013d09bb          	addw	s3,s10,s3
    800043ac:	012d093b          	addw	s2,s10,s2
    800043b0:	9a6e                	add	s4,s4,s11
    800043b2:	0569f063          	bgeu	s3,s6,800043f2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800043b6:	00a9559b          	srliw	a1,s2,0xa
    800043ba:	8556                	mv	a0,s5
    800043bc:	fd0ff0ef          	jal	ra,80003b8c <bmap>
    800043c0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043c4:	c59d                	beqz	a1,800043f2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800043c6:	000aa503          	lw	a0,0(s5)
    800043ca:	c48ff0ef          	jal	ra,80003812 <bread>
    800043ce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043d0:	3ff97513          	andi	a0,s2,1023
    800043d4:	40ac87bb          	subw	a5,s9,a0
    800043d8:	413b073b          	subw	a4,s6,s3
    800043dc:	8d3e                	mv	s10,a5
    800043de:	2781                	sext.w	a5,a5
    800043e0:	0007069b          	sext.w	a3,a4
    800043e4:	f8f6fee3          	bgeu	a3,a5,80004380 <writei+0x4c>
    800043e8:	8d3a                	mv	s10,a4
    800043ea:	bf59                	j	80004380 <writei+0x4c>
      brelse(bp);
    800043ec:	8526                	mv	a0,s1
    800043ee:	d2cff0ef          	jal	ra,8000391a <brelse>
  }

  if(off > ip->size)
    800043f2:	04caa783          	lw	a5,76(s5)
    800043f6:	0127f463          	bgeu	a5,s2,800043fe <writei+0xca>
    ip->size = off;
    800043fa:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043fe:	8556                	mv	a0,s5
    80004400:	a13ff0ef          	jal	ra,80003e12 <iupdate>

  return tot;
    80004404:	0009851b          	sext.w	a0,s3
}
    80004408:	70a6                	ld	ra,104(sp)
    8000440a:	7406                	ld	s0,96(sp)
    8000440c:	64e6                	ld	s1,88(sp)
    8000440e:	6946                	ld	s2,80(sp)
    80004410:	69a6                	ld	s3,72(sp)
    80004412:	6a06                	ld	s4,64(sp)
    80004414:	7ae2                	ld	s5,56(sp)
    80004416:	7b42                	ld	s6,48(sp)
    80004418:	7ba2                	ld	s7,40(sp)
    8000441a:	7c02                	ld	s8,32(sp)
    8000441c:	6ce2                	ld	s9,24(sp)
    8000441e:	6d42                	ld	s10,16(sp)
    80004420:	6da2                	ld	s11,8(sp)
    80004422:	6165                	addi	sp,sp,112
    80004424:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004426:	89da                	mv	s3,s6
    80004428:	bfd9                	j	800043fe <writei+0xca>
    return -1;
    8000442a:	557d                	li	a0,-1
}
    8000442c:	8082                	ret
    return -1;
    8000442e:	557d                	li	a0,-1
    80004430:	bfe1                	j	80004408 <writei+0xd4>
    return -1;
    80004432:	557d                	li	a0,-1
    80004434:	bfd1                	j	80004408 <writei+0xd4>

0000000080004436 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004436:	1141                	addi	sp,sp,-16
    80004438:	e406                	sd	ra,8(sp)
    8000443a:	e022                	sd	s0,0(sp)
    8000443c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000443e:	4639                	li	a2,14
    80004440:	a11fc0ef          	jal	ra,80000e50 <strncmp>
}
    80004444:	60a2                	ld	ra,8(sp)
    80004446:	6402                	ld	s0,0(sp)
    80004448:	0141                	addi	sp,sp,16
    8000444a:	8082                	ret

000000008000444c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000444c:	7139                	addi	sp,sp,-64
    8000444e:	fc06                	sd	ra,56(sp)
    80004450:	f822                	sd	s0,48(sp)
    80004452:	f426                	sd	s1,40(sp)
    80004454:	f04a                	sd	s2,32(sp)
    80004456:	ec4e                	sd	s3,24(sp)
    80004458:	e852                	sd	s4,16(sp)
    8000445a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000445c:	04451703          	lh	a4,68(a0)
    80004460:	4785                	li	a5,1
    80004462:	00f71a63          	bne	a4,a5,80004476 <dirlookup+0x2a>
    80004466:	892a                	mv	s2,a0
    80004468:	89ae                	mv	s3,a1
    8000446a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000446c:	457c                	lw	a5,76(a0)
    8000446e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004470:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004472:	e39d                	bnez	a5,80004498 <dirlookup+0x4c>
    80004474:	a095                	j	800044d8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004476:	00004517          	auipc	a0,0x4
    8000447a:	18250513          	addi	a0,a0,386 # 800085f8 <syscalls+0x200>
    8000447e:	b0cfc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    80004482:	00004517          	auipc	a0,0x4
    80004486:	18e50513          	addi	a0,a0,398 # 80008610 <syscalls+0x218>
    8000448a:	b00fc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000448e:	24c1                	addiw	s1,s1,16
    80004490:	04c92783          	lw	a5,76(s2)
    80004494:	04f4f163          	bgeu	s1,a5,800044d6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004498:	4741                	li	a4,16
    8000449a:	86a6                	mv	a3,s1
    8000449c:	fc040613          	addi	a2,s0,-64
    800044a0:	4581                	li	a1,0
    800044a2:	854a                	mv	a0,s2
    800044a4:	dadff0ef          	jal	ra,80004250 <readi>
    800044a8:	47c1                	li	a5,16
    800044aa:	fcf51ce3          	bne	a0,a5,80004482 <dirlookup+0x36>
    if(de.inum == 0)
    800044ae:	fc045783          	lhu	a5,-64(s0)
    800044b2:	dff1                	beqz	a5,8000448e <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800044b4:	fc240593          	addi	a1,s0,-62
    800044b8:	854e                	mv	a0,s3
    800044ba:	f7dff0ef          	jal	ra,80004436 <namecmp>
    800044be:	f961                	bnez	a0,8000448e <dirlookup+0x42>
      if(poff)
    800044c0:	000a0463          	beqz	s4,800044c8 <dirlookup+0x7c>
        *poff = off;
    800044c4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800044c8:	fc045583          	lhu	a1,-64(s0)
    800044cc:	00092503          	lw	a0,0(s2)
    800044d0:	f88ff0ef          	jal	ra,80003c58 <iget>
    800044d4:	a011                	j	800044d8 <dirlookup+0x8c>
  return 0;
    800044d6:	4501                	li	a0,0
}
    800044d8:	70e2                	ld	ra,56(sp)
    800044da:	7442                	ld	s0,48(sp)
    800044dc:	74a2                	ld	s1,40(sp)
    800044de:	7902                	ld	s2,32(sp)
    800044e0:	69e2                	ld	s3,24(sp)
    800044e2:	6a42                	ld	s4,16(sp)
    800044e4:	6121                	addi	sp,sp,64
    800044e6:	8082                	ret

00000000800044e8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044e8:	711d                	addi	sp,sp,-96
    800044ea:	ec86                	sd	ra,88(sp)
    800044ec:	e8a2                	sd	s0,80(sp)
    800044ee:	e4a6                	sd	s1,72(sp)
    800044f0:	e0ca                	sd	s2,64(sp)
    800044f2:	fc4e                	sd	s3,56(sp)
    800044f4:	f852                	sd	s4,48(sp)
    800044f6:	f456                	sd	s5,40(sp)
    800044f8:	f05a                	sd	s6,32(sp)
    800044fa:	ec5e                	sd	s7,24(sp)
    800044fc:	e862                	sd	s8,16(sp)
    800044fe:	e466                	sd	s9,8(sp)
    80004500:	1080                	addi	s0,sp,96
    80004502:	84aa                	mv	s1,a0
    80004504:	8aae                	mv	s5,a1
    80004506:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004508:	00054703          	lbu	a4,0(a0)
    8000450c:	02f00793          	li	a5,47
    80004510:	00f70f63          	beq	a4,a5,8000452e <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004514:	e9cfd0ef          	jal	ra,80001bb0 <myproc>
    80004518:	15053503          	ld	a0,336(a0)
    8000451c:	973ff0ef          	jal	ra,80003e8e <idup>
    80004520:	89aa                	mv	s3,a0
  while(*path == '/')
    80004522:	02f00913          	li	s2,47
  len = path - s;
    80004526:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004528:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000452a:	4b85                	li	s7,1
    8000452c:	a861                	j	800045c4 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    8000452e:	4585                	li	a1,1
    80004530:	4505                	li	a0,1
    80004532:	f26ff0ef          	jal	ra,80003c58 <iget>
    80004536:	89aa                	mv	s3,a0
    80004538:	b7ed                	j	80004522 <namex+0x3a>
      iunlockput(ip);
    8000453a:	854e                	mv	a0,s3
    8000453c:	b8fff0ef          	jal	ra,800040ca <iunlockput>
      return 0;
    80004540:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004542:	854e                	mv	a0,s3
    80004544:	60e6                	ld	ra,88(sp)
    80004546:	6446                	ld	s0,80(sp)
    80004548:	64a6                	ld	s1,72(sp)
    8000454a:	6906                	ld	s2,64(sp)
    8000454c:	79e2                	ld	s3,56(sp)
    8000454e:	7a42                	ld	s4,48(sp)
    80004550:	7aa2                	ld	s5,40(sp)
    80004552:	7b02                	ld	s6,32(sp)
    80004554:	6be2                	ld	s7,24(sp)
    80004556:	6c42                	ld	s8,16(sp)
    80004558:	6ca2                	ld	s9,8(sp)
    8000455a:	6125                	addi	sp,sp,96
    8000455c:	8082                	ret
      iunlock(ip);
    8000455e:	854e                	mv	a0,s3
    80004560:	a0fff0ef          	jal	ra,80003f6e <iunlock>
      return ip;
    80004564:	bff9                	j	80004542 <namex+0x5a>
      iunlockput(ip);
    80004566:	854e                	mv	a0,s3
    80004568:	b63ff0ef          	jal	ra,800040ca <iunlockput>
      return 0;
    8000456c:	89e6                	mv	s3,s9
    8000456e:	bfd1                	j	80004542 <namex+0x5a>
  len = path - s;
    80004570:	40b48633          	sub	a2,s1,a1
    80004574:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004578:	079c5c63          	bge	s8,s9,800045f0 <namex+0x108>
    memmove(name, s, DIRSIZ);
    8000457c:	4639                	li	a2,14
    8000457e:	8552                	mv	a0,s4
    80004580:	861fc0ef          	jal	ra,80000de0 <memmove>
  while(*path == '/')
    80004584:	0004c783          	lbu	a5,0(s1)
    80004588:	01279763          	bne	a5,s2,80004596 <namex+0xae>
    path++;
    8000458c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000458e:	0004c783          	lbu	a5,0(s1)
    80004592:	ff278de3          	beq	a5,s2,8000458c <namex+0xa4>
    ilock(ip);
    80004596:	854e                	mv	a0,s3
    80004598:	92dff0ef          	jal	ra,80003ec4 <ilock>
    if(ip->type != T_DIR){
    8000459c:	04499783          	lh	a5,68(s3)
    800045a0:	f9779de3          	bne	a5,s7,8000453a <namex+0x52>
    if(nameiparent && *path == '\0'){
    800045a4:	000a8563          	beqz	s5,800045ae <namex+0xc6>
    800045a8:	0004c783          	lbu	a5,0(s1)
    800045ac:	dbcd                	beqz	a5,8000455e <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045ae:	865a                	mv	a2,s6
    800045b0:	85d2                	mv	a1,s4
    800045b2:	854e                	mv	a0,s3
    800045b4:	e99ff0ef          	jal	ra,8000444c <dirlookup>
    800045b8:	8caa                	mv	s9,a0
    800045ba:	d555                	beqz	a0,80004566 <namex+0x7e>
    iunlockput(ip);
    800045bc:	854e                	mv	a0,s3
    800045be:	b0dff0ef          	jal	ra,800040ca <iunlockput>
    ip = next;
    800045c2:	89e6                	mv	s3,s9
  while(*path == '/')
    800045c4:	0004c783          	lbu	a5,0(s1)
    800045c8:	05279363          	bne	a5,s2,8000460e <namex+0x126>
    path++;
    800045cc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045ce:	0004c783          	lbu	a5,0(s1)
    800045d2:	ff278de3          	beq	a5,s2,800045cc <namex+0xe4>
  if(*path == 0)
    800045d6:	c78d                	beqz	a5,80004600 <namex+0x118>
    path++;
    800045d8:	85a6                	mv	a1,s1
  len = path - s;
    800045da:	8cda                	mv	s9,s6
    800045dc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800045de:	01278963          	beq	a5,s2,800045f0 <namex+0x108>
    800045e2:	d7d9                	beqz	a5,80004570 <namex+0x88>
    path++;
    800045e4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800045e6:	0004c783          	lbu	a5,0(s1)
    800045ea:	ff279ce3          	bne	a5,s2,800045e2 <namex+0xfa>
    800045ee:	b749                	j	80004570 <namex+0x88>
    memmove(name, s, len);
    800045f0:	2601                	sext.w	a2,a2
    800045f2:	8552                	mv	a0,s4
    800045f4:	fecfc0ef          	jal	ra,80000de0 <memmove>
    name[len] = 0;
    800045f8:	9cd2                	add	s9,s9,s4
    800045fa:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800045fe:	b759                	j	80004584 <namex+0x9c>
  if(nameiparent){
    80004600:	f40a81e3          	beqz	s5,80004542 <namex+0x5a>
    iput(ip);
    80004604:	854e                	mv	a0,s3
    80004606:	a3dff0ef          	jal	ra,80004042 <iput>
    return 0;
    8000460a:	4981                	li	s3,0
    8000460c:	bf1d                	j	80004542 <namex+0x5a>
  if(*path == 0)
    8000460e:	dbed                	beqz	a5,80004600 <namex+0x118>
  while(*path != '/' && *path != 0)
    80004610:	0004c783          	lbu	a5,0(s1)
    80004614:	85a6                	mv	a1,s1
    80004616:	b7f1                	j	800045e2 <namex+0xfa>

0000000080004618 <dirlink>:
{
    80004618:	7139                	addi	sp,sp,-64
    8000461a:	fc06                	sd	ra,56(sp)
    8000461c:	f822                	sd	s0,48(sp)
    8000461e:	f426                	sd	s1,40(sp)
    80004620:	f04a                	sd	s2,32(sp)
    80004622:	ec4e                	sd	s3,24(sp)
    80004624:	e852                	sd	s4,16(sp)
    80004626:	0080                	addi	s0,sp,64
    80004628:	892a                	mv	s2,a0
    8000462a:	8a2e                	mv	s4,a1
    8000462c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000462e:	4601                	li	a2,0
    80004630:	e1dff0ef          	jal	ra,8000444c <dirlookup>
    80004634:	e52d                	bnez	a0,8000469e <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004636:	04c92483          	lw	s1,76(s2)
    8000463a:	c48d                	beqz	s1,80004664 <dirlink+0x4c>
    8000463c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000463e:	4741                	li	a4,16
    80004640:	86a6                	mv	a3,s1
    80004642:	fc040613          	addi	a2,s0,-64
    80004646:	4581                	li	a1,0
    80004648:	854a                	mv	a0,s2
    8000464a:	c07ff0ef          	jal	ra,80004250 <readi>
    8000464e:	47c1                	li	a5,16
    80004650:	04f51b63          	bne	a0,a5,800046a6 <dirlink+0x8e>
    if(de.inum == 0)
    80004654:	fc045783          	lhu	a5,-64(s0)
    80004658:	c791                	beqz	a5,80004664 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000465a:	24c1                	addiw	s1,s1,16
    8000465c:	04c92783          	lw	a5,76(s2)
    80004660:	fcf4efe3          	bltu	s1,a5,8000463e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004664:	4639                	li	a2,14
    80004666:	85d2                	mv	a1,s4
    80004668:	fc240513          	addi	a0,s0,-62
    8000466c:	821fc0ef          	jal	ra,80000e8c <strncpy>
  de.inum = inum;
    80004670:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004674:	4741                	li	a4,16
    80004676:	86a6                	mv	a3,s1
    80004678:	fc040613          	addi	a2,s0,-64
    8000467c:	4581                	li	a1,0
    8000467e:	854a                	mv	a0,s2
    80004680:	cb5ff0ef          	jal	ra,80004334 <writei>
    80004684:	1541                	addi	a0,a0,-16
    80004686:	00a03533          	snez	a0,a0
    8000468a:	40a00533          	neg	a0,a0
}
    8000468e:	70e2                	ld	ra,56(sp)
    80004690:	7442                	ld	s0,48(sp)
    80004692:	74a2                	ld	s1,40(sp)
    80004694:	7902                	ld	s2,32(sp)
    80004696:	69e2                	ld	s3,24(sp)
    80004698:	6a42                	ld	s4,16(sp)
    8000469a:	6121                	addi	sp,sp,64
    8000469c:	8082                	ret
    iput(ip);
    8000469e:	9a5ff0ef          	jal	ra,80004042 <iput>
    return -1;
    800046a2:	557d                	li	a0,-1
    800046a4:	b7ed                	j	8000468e <dirlink+0x76>
      panic("dirlink read");
    800046a6:	00004517          	auipc	a0,0x4
    800046aa:	f7a50513          	addi	a0,a0,-134 # 80008620 <syscalls+0x228>
    800046ae:	8dcfc0ef          	jal	ra,8000078a <panic>

00000000800046b2 <namei>:

struct inode*
namei(char *path)
{
    800046b2:	1101                	addi	sp,sp,-32
    800046b4:	ec06                	sd	ra,24(sp)
    800046b6:	e822                	sd	s0,16(sp)
    800046b8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800046ba:	fe040613          	addi	a2,s0,-32
    800046be:	4581                	li	a1,0
    800046c0:	e29ff0ef          	jal	ra,800044e8 <namex>
}
    800046c4:	60e2                	ld	ra,24(sp)
    800046c6:	6442                	ld	s0,16(sp)
    800046c8:	6105                	addi	sp,sp,32
    800046ca:	8082                	ret

00000000800046cc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800046cc:	1141                	addi	sp,sp,-16
    800046ce:	e406                	sd	ra,8(sp)
    800046d0:	e022                	sd	s0,0(sp)
    800046d2:	0800                	addi	s0,sp,16
    800046d4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800046d6:	4585                	li	a1,1
    800046d8:	e11ff0ef          	jal	ra,800044e8 <namex>
}
    800046dc:	60a2                	ld	ra,8(sp)
    800046de:	6402                	ld	s0,0(sp)
    800046e0:	0141                	addi	sp,sp,16
    800046e2:	8082                	ret

00000000800046e4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800046e4:	1101                	addi	sp,sp,-32
    800046e6:	ec06                	sd	ra,24(sp)
    800046e8:	e822                	sd	s0,16(sp)
    800046ea:	e426                	sd	s1,8(sp)
    800046ec:	e04a                	sd	s2,0(sp)
    800046ee:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800046f0:	00246917          	auipc	s2,0x246
    800046f4:	2f090913          	addi	s2,s2,752 # 8024a9e0 <log>
    800046f8:	01892583          	lw	a1,24(s2)
    800046fc:	02492503          	lw	a0,36(s2)
    80004700:	912ff0ef          	jal	ra,80003812 <bread>
    80004704:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004706:	02892683          	lw	a3,40(s2)
    8000470a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000470c:	02d05763          	blez	a3,8000473a <write_head+0x56>
    80004710:	00246797          	auipc	a5,0x246
    80004714:	2fc78793          	addi	a5,a5,764 # 8024aa0c <log+0x2c>
    80004718:	05c50713          	addi	a4,a0,92
    8000471c:	36fd                	addiw	a3,a3,-1
    8000471e:	1682                	slli	a3,a3,0x20
    80004720:	9281                	srli	a3,a3,0x20
    80004722:	068a                	slli	a3,a3,0x2
    80004724:	00246617          	auipc	a2,0x246
    80004728:	2ec60613          	addi	a2,a2,748 # 8024aa10 <log+0x30>
    8000472c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000472e:	4390                	lw	a2,0(a5)
    80004730:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004732:	0791                	addi	a5,a5,4
    80004734:	0711                	addi	a4,a4,4
    80004736:	fed79ce3          	bne	a5,a3,8000472e <write_head+0x4a>
  }
  bwrite(buf);
    8000473a:	8526                	mv	a0,s1
    8000473c:	9acff0ef          	jal	ra,800038e8 <bwrite>
  brelse(buf);
    80004740:	8526                	mv	a0,s1
    80004742:	9d8ff0ef          	jal	ra,8000391a <brelse>
}
    80004746:	60e2                	ld	ra,24(sp)
    80004748:	6442                	ld	s0,16(sp)
    8000474a:	64a2                	ld	s1,8(sp)
    8000474c:	6902                	ld	s2,0(sp)
    8000474e:	6105                	addi	sp,sp,32
    80004750:	8082                	ret

0000000080004752 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004752:	00246797          	auipc	a5,0x246
    80004756:	2b67a783          	lw	a5,694(a5) # 8024aa08 <log+0x28>
    8000475a:	0af05e63          	blez	a5,80004816 <install_trans+0xc4>
{
    8000475e:	715d                	addi	sp,sp,-80
    80004760:	e486                	sd	ra,72(sp)
    80004762:	e0a2                	sd	s0,64(sp)
    80004764:	fc26                	sd	s1,56(sp)
    80004766:	f84a                	sd	s2,48(sp)
    80004768:	f44e                	sd	s3,40(sp)
    8000476a:	f052                	sd	s4,32(sp)
    8000476c:	ec56                	sd	s5,24(sp)
    8000476e:	e85a                	sd	s6,16(sp)
    80004770:	e45e                	sd	s7,8(sp)
    80004772:	0880                	addi	s0,sp,80
    80004774:	8b2a                	mv	s6,a0
    80004776:	00246a97          	auipc	s5,0x246
    8000477a:	296a8a93          	addi	s5,s5,662 # 8024aa0c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000477e:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004780:	00004b97          	auipc	s7,0x4
    80004784:	eb0b8b93          	addi	s7,s7,-336 # 80008630 <syscalls+0x238>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004788:	00246a17          	auipc	s4,0x246
    8000478c:	258a0a13          	addi	s4,s4,600 # 8024a9e0 <log>
    80004790:	a025                	j	800047b8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004792:	000aa603          	lw	a2,0(s5)
    80004796:	85ce                	mv	a1,s3
    80004798:	855e                	mv	a0,s7
    8000479a:	d2bfb0ef          	jal	ra,800004c4 <printf>
    8000479e:	a839                	j	800047bc <install_trans+0x6a>
    brelse(lbuf);
    800047a0:	854a                	mv	a0,s2
    800047a2:	978ff0ef          	jal	ra,8000391a <brelse>
    brelse(dbuf);
    800047a6:	8526                	mv	a0,s1
    800047a8:	972ff0ef          	jal	ra,8000391a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ac:	2985                	addiw	s3,s3,1
    800047ae:	0a91                	addi	s5,s5,4
    800047b0:	028a2783          	lw	a5,40(s4)
    800047b4:	04f9d663          	bge	s3,a5,80004800 <install_trans+0xae>
    if(recovering) {
    800047b8:	fc0b1de3          	bnez	s6,80004792 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047bc:	018a2583          	lw	a1,24(s4)
    800047c0:	013585bb          	addw	a1,a1,s3
    800047c4:	2585                	addiw	a1,a1,1
    800047c6:	024a2503          	lw	a0,36(s4)
    800047ca:	848ff0ef          	jal	ra,80003812 <bread>
    800047ce:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800047d0:	000aa583          	lw	a1,0(s5)
    800047d4:	024a2503          	lw	a0,36(s4)
    800047d8:	83aff0ef          	jal	ra,80003812 <bread>
    800047dc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047de:	40000613          	li	a2,1024
    800047e2:	05890593          	addi	a1,s2,88
    800047e6:	05850513          	addi	a0,a0,88
    800047ea:	df6fc0ef          	jal	ra,80000de0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800047ee:	8526                	mv	a0,s1
    800047f0:	8f8ff0ef          	jal	ra,800038e8 <bwrite>
    if(recovering == 0)
    800047f4:	fa0b16e3          	bnez	s6,800047a0 <install_trans+0x4e>
      bunpin(dbuf);
    800047f8:	8526                	mv	a0,s1
    800047fa:	9deff0ef          	jal	ra,800039d8 <bunpin>
    800047fe:	b74d                	j	800047a0 <install_trans+0x4e>
}
    80004800:	60a6                	ld	ra,72(sp)
    80004802:	6406                	ld	s0,64(sp)
    80004804:	74e2                	ld	s1,56(sp)
    80004806:	7942                	ld	s2,48(sp)
    80004808:	79a2                	ld	s3,40(sp)
    8000480a:	7a02                	ld	s4,32(sp)
    8000480c:	6ae2                	ld	s5,24(sp)
    8000480e:	6b42                	ld	s6,16(sp)
    80004810:	6ba2                	ld	s7,8(sp)
    80004812:	6161                	addi	sp,sp,80
    80004814:	8082                	ret
    80004816:	8082                	ret

0000000080004818 <initlog>:
{
    80004818:	7179                	addi	sp,sp,-48
    8000481a:	f406                	sd	ra,40(sp)
    8000481c:	f022                	sd	s0,32(sp)
    8000481e:	ec26                	sd	s1,24(sp)
    80004820:	e84a                	sd	s2,16(sp)
    80004822:	e44e                	sd	s3,8(sp)
    80004824:	1800                	addi	s0,sp,48
    80004826:	892a                	mv	s2,a0
    80004828:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000482a:	00246497          	auipc	s1,0x246
    8000482e:	1b648493          	addi	s1,s1,438 # 8024a9e0 <log>
    80004832:	00004597          	auipc	a1,0x4
    80004836:	e1e58593          	addi	a1,a1,-482 # 80008650 <syscalls+0x258>
    8000483a:	8526                	mv	a0,s1
    8000483c:	bf4fc0ef          	jal	ra,80000c30 <initlock>
  log.start = sb->logstart;
    80004840:	0149a583          	lw	a1,20(s3)
    80004844:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004846:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000484a:	854a                	mv	a0,s2
    8000484c:	fc7fe0ef          	jal	ra,80003812 <bread>
  log.lh.n = lh->n;
    80004850:	4d34                	lw	a3,88(a0)
    80004852:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004854:	02d05563          	blez	a3,8000487e <initlog+0x66>
    80004858:	05c50793          	addi	a5,a0,92
    8000485c:	00246717          	auipc	a4,0x246
    80004860:	1b070713          	addi	a4,a4,432 # 8024aa0c <log+0x2c>
    80004864:	36fd                	addiw	a3,a3,-1
    80004866:	1682                	slli	a3,a3,0x20
    80004868:	9281                	srli	a3,a3,0x20
    8000486a:	068a                	slli	a3,a3,0x2
    8000486c:	06050613          	addi	a2,a0,96
    80004870:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004872:	4390                	lw	a2,0(a5)
    80004874:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004876:	0791                	addi	a5,a5,4
    80004878:	0711                	addi	a4,a4,4
    8000487a:	fed79ce3          	bne	a5,a3,80004872 <initlog+0x5a>
  brelse(buf);
    8000487e:	89cff0ef          	jal	ra,8000391a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004882:	4505                	li	a0,1
    80004884:	ecfff0ef          	jal	ra,80004752 <install_trans>
  log.lh.n = 0;
    80004888:	00246797          	auipc	a5,0x246
    8000488c:	1807a023          	sw	zero,384(a5) # 8024aa08 <log+0x28>
  write_head(); // clear the log
    80004890:	e55ff0ef          	jal	ra,800046e4 <write_head>
}
    80004894:	70a2                	ld	ra,40(sp)
    80004896:	7402                	ld	s0,32(sp)
    80004898:	64e2                	ld	s1,24(sp)
    8000489a:	6942                	ld	s2,16(sp)
    8000489c:	69a2                	ld	s3,8(sp)
    8000489e:	6145                	addi	sp,sp,48
    800048a0:	8082                	ret

00000000800048a2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800048a2:	1101                	addi	sp,sp,-32
    800048a4:	ec06                	sd	ra,24(sp)
    800048a6:	e822                	sd	s0,16(sp)
    800048a8:	e426                	sd	s1,8(sp)
    800048aa:	e04a                	sd	s2,0(sp)
    800048ac:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800048ae:	00246517          	auipc	a0,0x246
    800048b2:	13250513          	addi	a0,a0,306 # 8024a9e0 <log>
    800048b6:	bfafc0ef          	jal	ra,80000cb0 <acquire>
  while(1){
    if(log.committing){
    800048ba:	00246497          	auipc	s1,0x246
    800048be:	12648493          	addi	s1,s1,294 # 8024a9e0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800048c2:	4979                	li	s2,30
    800048c4:	a029                	j	800048ce <begin_op+0x2c>
      sleep(&log, &log.lock);
    800048c6:	85a6                	mv	a1,s1
    800048c8:	8526                	mv	a0,s1
    800048ca:	bdffd0ef          	jal	ra,800024a8 <sleep>
    if(log.committing){
    800048ce:	509c                	lw	a5,32(s1)
    800048d0:	fbfd                	bnez	a5,800048c6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800048d2:	4cdc                	lw	a5,28(s1)
    800048d4:	0017871b          	addiw	a4,a5,1
    800048d8:	0007069b          	sext.w	a3,a4
    800048dc:	0027179b          	slliw	a5,a4,0x2
    800048e0:	9fb9                	addw	a5,a5,a4
    800048e2:	0017979b          	slliw	a5,a5,0x1
    800048e6:	5498                	lw	a4,40(s1)
    800048e8:	9fb9                	addw	a5,a5,a4
    800048ea:	00f95763          	bge	s2,a5,800048f8 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048ee:	85a6                	mv	a1,s1
    800048f0:	8526                	mv	a0,s1
    800048f2:	bb7fd0ef          	jal	ra,800024a8 <sleep>
    800048f6:	bfe1                	j	800048ce <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800048f8:	00246517          	auipc	a0,0x246
    800048fc:	0e850513          	addi	a0,a0,232 # 8024a9e0 <log>
    80004900:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80004902:	c46fc0ef          	jal	ra,80000d48 <release>
      break;
    }
  }
}
    80004906:	60e2                	ld	ra,24(sp)
    80004908:	6442                	ld	s0,16(sp)
    8000490a:	64a2                	ld	s1,8(sp)
    8000490c:	6902                	ld	s2,0(sp)
    8000490e:	6105                	addi	sp,sp,32
    80004910:	8082                	ret

0000000080004912 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004912:	7139                	addi	sp,sp,-64
    80004914:	fc06                	sd	ra,56(sp)
    80004916:	f822                	sd	s0,48(sp)
    80004918:	f426                	sd	s1,40(sp)
    8000491a:	f04a                	sd	s2,32(sp)
    8000491c:	ec4e                	sd	s3,24(sp)
    8000491e:	e852                	sd	s4,16(sp)
    80004920:	e456                	sd	s5,8(sp)
    80004922:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004924:	00246497          	auipc	s1,0x246
    80004928:	0bc48493          	addi	s1,s1,188 # 8024a9e0 <log>
    8000492c:	8526                	mv	a0,s1
    8000492e:	b82fc0ef          	jal	ra,80000cb0 <acquire>
  log.outstanding -= 1;
    80004932:	4cdc                	lw	a5,28(s1)
    80004934:	37fd                	addiw	a5,a5,-1
    80004936:	0007891b          	sext.w	s2,a5
    8000493a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000493c:	509c                	lw	a5,32(s1)
    8000493e:	ef9d                	bnez	a5,8000497c <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004940:	04091463          	bnez	s2,80004988 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004944:	00246497          	auipc	s1,0x246
    80004948:	09c48493          	addi	s1,s1,156 # 8024a9e0 <log>
    8000494c:	4785                	li	a5,1
    8000494e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004950:	8526                	mv	a0,s1
    80004952:	bf6fc0ef          	jal	ra,80000d48 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004956:	549c                	lw	a5,40(s1)
    80004958:	04f04b63          	bgtz	a5,800049ae <end_op+0x9c>
    acquire(&log.lock);
    8000495c:	00246497          	auipc	s1,0x246
    80004960:	08448493          	addi	s1,s1,132 # 8024a9e0 <log>
    80004964:	8526                	mv	a0,s1
    80004966:	b4afc0ef          	jal	ra,80000cb0 <acquire>
    log.committing = 0;
    8000496a:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    8000496e:	8526                	mv	a0,s1
    80004970:	b85fd0ef          	jal	ra,800024f4 <wakeup>
    release(&log.lock);
    80004974:	8526                	mv	a0,s1
    80004976:	bd2fc0ef          	jal	ra,80000d48 <release>
}
    8000497a:	a00d                	j	8000499c <end_op+0x8a>
    panic("log.committing");
    8000497c:	00004517          	auipc	a0,0x4
    80004980:	cdc50513          	addi	a0,a0,-804 # 80008658 <syscalls+0x260>
    80004984:	e07fb0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80004988:	00246497          	auipc	s1,0x246
    8000498c:	05848493          	addi	s1,s1,88 # 8024a9e0 <log>
    80004990:	8526                	mv	a0,s1
    80004992:	b63fd0ef          	jal	ra,800024f4 <wakeup>
  release(&log.lock);
    80004996:	8526                	mv	a0,s1
    80004998:	bb0fc0ef          	jal	ra,80000d48 <release>
}
    8000499c:	70e2                	ld	ra,56(sp)
    8000499e:	7442                	ld	s0,48(sp)
    800049a0:	74a2                	ld	s1,40(sp)
    800049a2:	7902                	ld	s2,32(sp)
    800049a4:	69e2                	ld	s3,24(sp)
    800049a6:	6a42                	ld	s4,16(sp)
    800049a8:	6aa2                	ld	s5,8(sp)
    800049aa:	6121                	addi	sp,sp,64
    800049ac:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800049ae:	00246a97          	auipc	s5,0x246
    800049b2:	05ea8a93          	addi	s5,s5,94 # 8024aa0c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049b6:	00246a17          	auipc	s4,0x246
    800049ba:	02aa0a13          	addi	s4,s4,42 # 8024a9e0 <log>
    800049be:	018a2583          	lw	a1,24(s4)
    800049c2:	012585bb          	addw	a1,a1,s2
    800049c6:	2585                	addiw	a1,a1,1
    800049c8:	024a2503          	lw	a0,36(s4)
    800049cc:	e47fe0ef          	jal	ra,80003812 <bread>
    800049d0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049d2:	000aa583          	lw	a1,0(s5)
    800049d6:	024a2503          	lw	a0,36(s4)
    800049da:	e39fe0ef          	jal	ra,80003812 <bread>
    800049de:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049e0:	40000613          	li	a2,1024
    800049e4:	05850593          	addi	a1,a0,88
    800049e8:	05848513          	addi	a0,s1,88
    800049ec:	bf4fc0ef          	jal	ra,80000de0 <memmove>
    bwrite(to);  // write the log
    800049f0:	8526                	mv	a0,s1
    800049f2:	ef7fe0ef          	jal	ra,800038e8 <bwrite>
    brelse(from);
    800049f6:	854e                	mv	a0,s3
    800049f8:	f23fe0ef          	jal	ra,8000391a <brelse>
    brelse(to);
    800049fc:	8526                	mv	a0,s1
    800049fe:	f1dfe0ef          	jal	ra,8000391a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a02:	2905                	addiw	s2,s2,1
    80004a04:	0a91                	addi	s5,s5,4
    80004a06:	028a2783          	lw	a5,40(s4)
    80004a0a:	faf94ae3          	blt	s2,a5,800049be <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a0e:	cd7ff0ef          	jal	ra,800046e4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a12:	4501                	li	a0,0
    80004a14:	d3fff0ef          	jal	ra,80004752 <install_trans>
    log.lh.n = 0;
    80004a18:	00246797          	auipc	a5,0x246
    80004a1c:	fe07a823          	sw	zero,-16(a5) # 8024aa08 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004a20:	cc5ff0ef          	jal	ra,800046e4 <write_head>
    80004a24:	bf25                	j	8000495c <end_op+0x4a>

0000000080004a26 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a26:	1101                	addi	sp,sp,-32
    80004a28:	ec06                	sd	ra,24(sp)
    80004a2a:	e822                	sd	s0,16(sp)
    80004a2c:	e426                	sd	s1,8(sp)
    80004a2e:	e04a                	sd	s2,0(sp)
    80004a30:	1000                	addi	s0,sp,32
    80004a32:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a34:	00246917          	auipc	s2,0x246
    80004a38:	fac90913          	addi	s2,s2,-84 # 8024a9e0 <log>
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	a72fc0ef          	jal	ra,80000cb0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004a42:	02892603          	lw	a2,40(s2)
    80004a46:	47f5                	li	a5,29
    80004a48:	04c7cc63          	blt	a5,a2,80004aa0 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a4c:	00246797          	auipc	a5,0x246
    80004a50:	fb07a783          	lw	a5,-80(a5) # 8024a9fc <log+0x1c>
    80004a54:	04f05c63          	blez	a5,80004aac <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a58:	4781                	li	a5,0
    80004a5a:	04c05f63          	blez	a2,80004ab8 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a5e:	44cc                	lw	a1,12(s1)
    80004a60:	00246717          	auipc	a4,0x246
    80004a64:	fac70713          	addi	a4,a4,-84 # 8024aa0c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004a68:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a6a:	4314                	lw	a3,0(a4)
    80004a6c:	04b68663          	beq	a3,a1,80004ab8 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004a70:	2785                	addiw	a5,a5,1
    80004a72:	0711                	addi	a4,a4,4
    80004a74:	fef61be3          	bne	a2,a5,80004a6a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a78:	0621                	addi	a2,a2,8
    80004a7a:	060a                	slli	a2,a2,0x2
    80004a7c:	00246797          	auipc	a5,0x246
    80004a80:	f6478793          	addi	a5,a5,-156 # 8024a9e0 <log>
    80004a84:	963e                	add	a2,a2,a5
    80004a86:	44dc                	lw	a5,12(s1)
    80004a88:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	f19fe0ef          	jal	ra,800039a4 <bpin>
    log.lh.n++;
    80004a90:	00246717          	auipc	a4,0x246
    80004a94:	f5070713          	addi	a4,a4,-176 # 8024a9e0 <log>
    80004a98:	571c                	lw	a5,40(a4)
    80004a9a:	2785                	addiw	a5,a5,1
    80004a9c:	d71c                	sw	a5,40(a4)
    80004a9e:	a815                	j	80004ad2 <log_write+0xac>
    panic("too big a transaction");
    80004aa0:	00004517          	auipc	a0,0x4
    80004aa4:	bc850513          	addi	a0,a0,-1080 # 80008668 <syscalls+0x270>
    80004aa8:	ce3fb0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80004aac:	00004517          	auipc	a0,0x4
    80004ab0:	bd450513          	addi	a0,a0,-1068 # 80008680 <syscalls+0x288>
    80004ab4:	cd7fb0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80004ab8:	00878713          	addi	a4,a5,8
    80004abc:	00271693          	slli	a3,a4,0x2
    80004ac0:	00246717          	auipc	a4,0x246
    80004ac4:	f2070713          	addi	a4,a4,-224 # 8024a9e0 <log>
    80004ac8:	9736                	add	a4,a4,a3
    80004aca:	44d4                	lw	a3,12(s1)
    80004acc:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004ace:	faf60ee3          	beq	a2,a5,80004a8a <log_write+0x64>
  }
  release(&log.lock);
    80004ad2:	00246517          	auipc	a0,0x246
    80004ad6:	f0e50513          	addi	a0,a0,-242 # 8024a9e0 <log>
    80004ada:	a6efc0ef          	jal	ra,80000d48 <release>
}
    80004ade:	60e2                	ld	ra,24(sp)
    80004ae0:	6442                	ld	s0,16(sp)
    80004ae2:	64a2                	ld	s1,8(sp)
    80004ae4:	6902                	ld	s2,0(sp)
    80004ae6:	6105                	addi	sp,sp,32
    80004ae8:	8082                	ret

0000000080004aea <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004aea:	1101                	addi	sp,sp,-32
    80004aec:	ec06                	sd	ra,24(sp)
    80004aee:	e822                	sd	s0,16(sp)
    80004af0:	e426                	sd	s1,8(sp)
    80004af2:	e04a                	sd	s2,0(sp)
    80004af4:	1000                	addi	s0,sp,32
    80004af6:	84aa                	mv	s1,a0
    80004af8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004afa:	00004597          	auipc	a1,0x4
    80004afe:	ba658593          	addi	a1,a1,-1114 # 800086a0 <syscalls+0x2a8>
    80004b02:	0521                	addi	a0,a0,8
    80004b04:	92cfc0ef          	jal	ra,80000c30 <initlock>
  lk->name = name;
    80004b08:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b0c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b10:	0204a423          	sw	zero,40(s1)
}
    80004b14:	60e2                	ld	ra,24(sp)
    80004b16:	6442                	ld	s0,16(sp)
    80004b18:	64a2                	ld	s1,8(sp)
    80004b1a:	6902                	ld	s2,0(sp)
    80004b1c:	6105                	addi	sp,sp,32
    80004b1e:	8082                	ret

0000000080004b20 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b20:	1101                	addi	sp,sp,-32
    80004b22:	ec06                	sd	ra,24(sp)
    80004b24:	e822                	sd	s0,16(sp)
    80004b26:	e426                	sd	s1,8(sp)
    80004b28:	e04a                	sd	s2,0(sp)
    80004b2a:	1000                	addi	s0,sp,32
    80004b2c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b2e:	00850913          	addi	s2,a0,8
    80004b32:	854a                	mv	a0,s2
    80004b34:	97cfc0ef          	jal	ra,80000cb0 <acquire>
  while (lk->locked) {
    80004b38:	409c                	lw	a5,0(s1)
    80004b3a:	c799                	beqz	a5,80004b48 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004b3c:	85ca                	mv	a1,s2
    80004b3e:	8526                	mv	a0,s1
    80004b40:	969fd0ef          	jal	ra,800024a8 <sleep>
  while (lk->locked) {
    80004b44:	409c                	lw	a5,0(s1)
    80004b46:	fbfd                	bnez	a5,80004b3c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004b48:	4785                	li	a5,1
    80004b4a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b4c:	864fd0ef          	jal	ra,80001bb0 <myproc>
    80004b50:	591c                	lw	a5,48(a0)
    80004b52:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b54:	854a                	mv	a0,s2
    80004b56:	9f2fc0ef          	jal	ra,80000d48 <release>
}
    80004b5a:	60e2                	ld	ra,24(sp)
    80004b5c:	6442                	ld	s0,16(sp)
    80004b5e:	64a2                	ld	s1,8(sp)
    80004b60:	6902                	ld	s2,0(sp)
    80004b62:	6105                	addi	sp,sp,32
    80004b64:	8082                	ret

0000000080004b66 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b66:	1101                	addi	sp,sp,-32
    80004b68:	ec06                	sd	ra,24(sp)
    80004b6a:	e822                	sd	s0,16(sp)
    80004b6c:	e426                	sd	s1,8(sp)
    80004b6e:	e04a                	sd	s2,0(sp)
    80004b70:	1000                	addi	s0,sp,32
    80004b72:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b74:	00850913          	addi	s2,a0,8
    80004b78:	854a                	mv	a0,s2
    80004b7a:	936fc0ef          	jal	ra,80000cb0 <acquire>
  lk->locked = 0;
    80004b7e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b82:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b86:	8526                	mv	a0,s1
    80004b88:	96dfd0ef          	jal	ra,800024f4 <wakeup>
  release(&lk->lk);
    80004b8c:	854a                	mv	a0,s2
    80004b8e:	9bafc0ef          	jal	ra,80000d48 <release>
}
    80004b92:	60e2                	ld	ra,24(sp)
    80004b94:	6442                	ld	s0,16(sp)
    80004b96:	64a2                	ld	s1,8(sp)
    80004b98:	6902                	ld	s2,0(sp)
    80004b9a:	6105                	addi	sp,sp,32
    80004b9c:	8082                	ret

0000000080004b9e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b9e:	7179                	addi	sp,sp,-48
    80004ba0:	f406                	sd	ra,40(sp)
    80004ba2:	f022                	sd	s0,32(sp)
    80004ba4:	ec26                	sd	s1,24(sp)
    80004ba6:	e84a                	sd	s2,16(sp)
    80004ba8:	e44e                	sd	s3,8(sp)
    80004baa:	1800                	addi	s0,sp,48
    80004bac:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004bae:	00850913          	addi	s2,a0,8
    80004bb2:	854a                	mv	a0,s2
    80004bb4:	8fcfc0ef          	jal	ra,80000cb0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004bb8:	409c                	lw	a5,0(s1)
    80004bba:	ef89                	bnez	a5,80004bd4 <holdingsleep+0x36>
    80004bbc:	4481                	li	s1,0
  release(&lk->lk);
    80004bbe:	854a                	mv	a0,s2
    80004bc0:	988fc0ef          	jal	ra,80000d48 <release>
  return r;
}
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	70a2                	ld	ra,40(sp)
    80004bc8:	7402                	ld	s0,32(sp)
    80004bca:	64e2                	ld	s1,24(sp)
    80004bcc:	6942                	ld	s2,16(sp)
    80004bce:	69a2                	ld	s3,8(sp)
    80004bd0:	6145                	addi	sp,sp,48
    80004bd2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004bd4:	0284a983          	lw	s3,40(s1)
    80004bd8:	fd9fc0ef          	jal	ra,80001bb0 <myproc>
    80004bdc:	5904                	lw	s1,48(a0)
    80004bde:	413484b3          	sub	s1,s1,s3
    80004be2:	0014b493          	seqz	s1,s1
    80004be6:	bfe1                	j	80004bbe <holdingsleep+0x20>

0000000080004be8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004be8:	1141                	addi	sp,sp,-16
    80004bea:	e406                	sd	ra,8(sp)
    80004bec:	e022                	sd	s0,0(sp)
    80004bee:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004bf0:	00004597          	auipc	a1,0x4
    80004bf4:	ac058593          	addi	a1,a1,-1344 # 800086b0 <syscalls+0x2b8>
    80004bf8:	00246517          	auipc	a0,0x246
    80004bfc:	f3050513          	addi	a0,a0,-208 # 8024ab28 <ftable>
    80004c00:	830fc0ef          	jal	ra,80000c30 <initlock>
}
    80004c04:	60a2                	ld	ra,8(sp)
    80004c06:	6402                	ld	s0,0(sp)
    80004c08:	0141                	addi	sp,sp,16
    80004c0a:	8082                	ret

0000000080004c0c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c0c:	1101                	addi	sp,sp,-32
    80004c0e:	ec06                	sd	ra,24(sp)
    80004c10:	e822                	sd	s0,16(sp)
    80004c12:	e426                	sd	s1,8(sp)
    80004c14:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c16:	00246517          	auipc	a0,0x246
    80004c1a:	f1250513          	addi	a0,a0,-238 # 8024ab28 <ftable>
    80004c1e:	892fc0ef          	jal	ra,80000cb0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c22:	00246497          	auipc	s1,0x246
    80004c26:	f1e48493          	addi	s1,s1,-226 # 8024ab40 <ftable+0x18>
    80004c2a:	00247717          	auipc	a4,0x247
    80004c2e:	eb670713          	addi	a4,a4,-330 # 8024bae0 <disk>
    if(f->ref == 0){
    80004c32:	40dc                	lw	a5,4(s1)
    80004c34:	cf89                	beqz	a5,80004c4e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c36:	02848493          	addi	s1,s1,40
    80004c3a:	fee49ce3          	bne	s1,a4,80004c32 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c3e:	00246517          	auipc	a0,0x246
    80004c42:	eea50513          	addi	a0,a0,-278 # 8024ab28 <ftable>
    80004c46:	902fc0ef          	jal	ra,80000d48 <release>
  return 0;
    80004c4a:	4481                	li	s1,0
    80004c4c:	a809                	j	80004c5e <filealloc+0x52>
      f->ref = 1;
    80004c4e:	4785                	li	a5,1
    80004c50:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c52:	00246517          	auipc	a0,0x246
    80004c56:	ed650513          	addi	a0,a0,-298 # 8024ab28 <ftable>
    80004c5a:	8eefc0ef          	jal	ra,80000d48 <release>
}
    80004c5e:	8526                	mv	a0,s1
    80004c60:	60e2                	ld	ra,24(sp)
    80004c62:	6442                	ld	s0,16(sp)
    80004c64:	64a2                	ld	s1,8(sp)
    80004c66:	6105                	addi	sp,sp,32
    80004c68:	8082                	ret

0000000080004c6a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c6a:	1101                	addi	sp,sp,-32
    80004c6c:	ec06                	sd	ra,24(sp)
    80004c6e:	e822                	sd	s0,16(sp)
    80004c70:	e426                	sd	s1,8(sp)
    80004c72:	1000                	addi	s0,sp,32
    80004c74:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c76:	00246517          	auipc	a0,0x246
    80004c7a:	eb250513          	addi	a0,a0,-334 # 8024ab28 <ftable>
    80004c7e:	832fc0ef          	jal	ra,80000cb0 <acquire>
  if(f->ref < 1)
    80004c82:	40dc                	lw	a5,4(s1)
    80004c84:	02f05063          	blez	a5,80004ca4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004c88:	2785                	addiw	a5,a5,1
    80004c8a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c8c:	00246517          	auipc	a0,0x246
    80004c90:	e9c50513          	addi	a0,a0,-356 # 8024ab28 <ftable>
    80004c94:	8b4fc0ef          	jal	ra,80000d48 <release>
  return f;
}
    80004c98:	8526                	mv	a0,s1
    80004c9a:	60e2                	ld	ra,24(sp)
    80004c9c:	6442                	ld	s0,16(sp)
    80004c9e:	64a2                	ld	s1,8(sp)
    80004ca0:	6105                	addi	sp,sp,32
    80004ca2:	8082                	ret
    panic("filedup");
    80004ca4:	00004517          	auipc	a0,0x4
    80004ca8:	a1450513          	addi	a0,a0,-1516 # 800086b8 <syscalls+0x2c0>
    80004cac:	adffb0ef          	jal	ra,8000078a <panic>

0000000080004cb0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004cb0:	7139                	addi	sp,sp,-64
    80004cb2:	fc06                	sd	ra,56(sp)
    80004cb4:	f822                	sd	s0,48(sp)
    80004cb6:	f426                	sd	s1,40(sp)
    80004cb8:	f04a                	sd	s2,32(sp)
    80004cba:	ec4e                	sd	s3,24(sp)
    80004cbc:	e852                	sd	s4,16(sp)
    80004cbe:	e456                	sd	s5,8(sp)
    80004cc0:	0080                	addi	s0,sp,64
    80004cc2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004cc4:	00246517          	auipc	a0,0x246
    80004cc8:	e6450513          	addi	a0,a0,-412 # 8024ab28 <ftable>
    80004ccc:	fe5fb0ef          	jal	ra,80000cb0 <acquire>
  if(f->ref < 1)
    80004cd0:	40dc                	lw	a5,4(s1)
    80004cd2:	04f05963          	blez	a5,80004d24 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004cd6:	37fd                	addiw	a5,a5,-1
    80004cd8:	0007871b          	sext.w	a4,a5
    80004cdc:	c0dc                	sw	a5,4(s1)
    80004cde:	04e04963          	bgtz	a4,80004d30 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ce2:	0004a903          	lw	s2,0(s1)
    80004ce6:	0094ca83          	lbu	s5,9(s1)
    80004cea:	0104ba03          	ld	s4,16(s1)
    80004cee:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004cf2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004cf6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004cfa:	00246517          	auipc	a0,0x246
    80004cfe:	e2e50513          	addi	a0,a0,-466 # 8024ab28 <ftable>
    80004d02:	846fc0ef          	jal	ra,80000d48 <release>

  if(ff.type == FD_PIPE){
    80004d06:	4785                	li	a5,1
    80004d08:	04f90363          	beq	s2,a5,80004d4e <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d0c:	3979                	addiw	s2,s2,-2
    80004d0e:	4785                	li	a5,1
    80004d10:	0327e663          	bltu	a5,s2,80004d3c <fileclose+0x8c>
    begin_op();
    80004d14:	b8fff0ef          	jal	ra,800048a2 <begin_op>
    iput(ff.ip);
    80004d18:	854e                	mv	a0,s3
    80004d1a:	b28ff0ef          	jal	ra,80004042 <iput>
    end_op();
    80004d1e:	bf5ff0ef          	jal	ra,80004912 <end_op>
    80004d22:	a829                	j	80004d3c <fileclose+0x8c>
    panic("fileclose");
    80004d24:	00004517          	auipc	a0,0x4
    80004d28:	99c50513          	addi	a0,a0,-1636 # 800086c0 <syscalls+0x2c8>
    80004d2c:	a5ffb0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80004d30:	00246517          	auipc	a0,0x246
    80004d34:	df850513          	addi	a0,a0,-520 # 8024ab28 <ftable>
    80004d38:	810fc0ef          	jal	ra,80000d48 <release>
  }
}
    80004d3c:	70e2                	ld	ra,56(sp)
    80004d3e:	7442                	ld	s0,48(sp)
    80004d40:	74a2                	ld	s1,40(sp)
    80004d42:	7902                	ld	s2,32(sp)
    80004d44:	69e2                	ld	s3,24(sp)
    80004d46:	6a42                	ld	s4,16(sp)
    80004d48:	6aa2                	ld	s5,8(sp)
    80004d4a:	6121                	addi	sp,sp,64
    80004d4c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d4e:	85d6                	mv	a1,s5
    80004d50:	8552                	mv	a0,s4
    80004d52:	2ec000ef          	jal	ra,8000503e <pipeclose>
    80004d56:	b7dd                	j	80004d3c <fileclose+0x8c>

0000000080004d58 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d58:	715d                	addi	sp,sp,-80
    80004d5a:	e486                	sd	ra,72(sp)
    80004d5c:	e0a2                	sd	s0,64(sp)
    80004d5e:	fc26                	sd	s1,56(sp)
    80004d60:	f84a                	sd	s2,48(sp)
    80004d62:	f44e                	sd	s3,40(sp)
    80004d64:	0880                	addi	s0,sp,80
    80004d66:	84aa                	mv	s1,a0
    80004d68:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d6a:	e47fc0ef          	jal	ra,80001bb0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d6e:	409c                	lw	a5,0(s1)
    80004d70:	37f9                	addiw	a5,a5,-2
    80004d72:	4705                	li	a4,1
    80004d74:	02f76f63          	bltu	a4,a5,80004db2 <filestat+0x5a>
    80004d78:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d7a:	6c88                	ld	a0,24(s1)
    80004d7c:	948ff0ef          	jal	ra,80003ec4 <ilock>
    stati(f->ip, &st);
    80004d80:	fb840593          	addi	a1,s0,-72
    80004d84:	6c88                	ld	a0,24(s1)
    80004d86:	ca0ff0ef          	jal	ra,80004226 <stati>
    iunlock(f->ip);
    80004d8a:	6c88                	ld	a0,24(s1)
    80004d8c:	9e2ff0ef          	jal	ra,80003f6e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d90:	46e1                	li	a3,24
    80004d92:	fb840613          	addi	a2,s0,-72
    80004d96:	85ce                	mv	a1,s3
    80004d98:	05093503          	ld	a0,80(s2)
    80004d9c:	a05fc0ef          	jal	ra,800017a0 <copyout>
    80004da0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004da4:	60a6                	ld	ra,72(sp)
    80004da6:	6406                	ld	s0,64(sp)
    80004da8:	74e2                	ld	s1,56(sp)
    80004daa:	7942                	ld	s2,48(sp)
    80004dac:	79a2                	ld	s3,40(sp)
    80004dae:	6161                	addi	sp,sp,80
    80004db0:	8082                	ret
  return -1;
    80004db2:	557d                	li	a0,-1
    80004db4:	bfc5                	j	80004da4 <filestat+0x4c>

0000000080004db6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004db6:	7179                	addi	sp,sp,-48
    80004db8:	f406                	sd	ra,40(sp)
    80004dba:	f022                	sd	s0,32(sp)
    80004dbc:	ec26                	sd	s1,24(sp)
    80004dbe:	e84a                	sd	s2,16(sp)
    80004dc0:	e44e                	sd	s3,8(sp)
    80004dc2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004dc4:	00854783          	lbu	a5,8(a0)
    80004dc8:	cbc1                	beqz	a5,80004e58 <fileread+0xa2>
    80004dca:	84aa                	mv	s1,a0
    80004dcc:	89ae                	mv	s3,a1
    80004dce:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dd0:	411c                	lw	a5,0(a0)
    80004dd2:	4705                	li	a4,1
    80004dd4:	04e78363          	beq	a5,a4,80004e1a <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dd8:	470d                	li	a4,3
    80004dda:	04e78563          	beq	a5,a4,80004e24 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dde:	4709                	li	a4,2
    80004de0:	06e79663          	bne	a5,a4,80004e4c <fileread+0x96>
    ilock(f->ip);
    80004de4:	6d08                	ld	a0,24(a0)
    80004de6:	8deff0ef          	jal	ra,80003ec4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dea:	874a                	mv	a4,s2
    80004dec:	5094                	lw	a3,32(s1)
    80004dee:	864e                	mv	a2,s3
    80004df0:	4585                	li	a1,1
    80004df2:	6c88                	ld	a0,24(s1)
    80004df4:	c5cff0ef          	jal	ra,80004250 <readi>
    80004df8:	892a                	mv	s2,a0
    80004dfa:	00a05563          	blez	a0,80004e04 <fileread+0x4e>
      f->off += r;
    80004dfe:	509c                	lw	a5,32(s1)
    80004e00:	9fa9                	addw	a5,a5,a0
    80004e02:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004e04:	6c88                	ld	a0,24(s1)
    80004e06:	968ff0ef          	jal	ra,80003f6e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004e0a:	854a                	mv	a0,s2
    80004e0c:	70a2                	ld	ra,40(sp)
    80004e0e:	7402                	ld	s0,32(sp)
    80004e10:	64e2                	ld	s1,24(sp)
    80004e12:	6942                	ld	s2,16(sp)
    80004e14:	69a2                	ld	s3,8(sp)
    80004e16:	6145                	addi	sp,sp,48
    80004e18:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e1a:	6908                	ld	a0,16(a0)
    80004e1c:	34e000ef          	jal	ra,8000516a <piperead>
    80004e20:	892a                	mv	s2,a0
    80004e22:	b7e5                	j	80004e0a <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e24:	02451783          	lh	a5,36(a0)
    80004e28:	03079693          	slli	a3,a5,0x30
    80004e2c:	92c1                	srli	a3,a3,0x30
    80004e2e:	4725                	li	a4,9
    80004e30:	02d76663          	bltu	a4,a3,80004e5c <fileread+0xa6>
    80004e34:	0792                	slli	a5,a5,0x4
    80004e36:	00246717          	auipc	a4,0x246
    80004e3a:	c5270713          	addi	a4,a4,-942 # 8024aa88 <devsw>
    80004e3e:	97ba                	add	a5,a5,a4
    80004e40:	639c                	ld	a5,0(a5)
    80004e42:	cf99                	beqz	a5,80004e60 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004e44:	4505                	li	a0,1
    80004e46:	9782                	jalr	a5
    80004e48:	892a                	mv	s2,a0
    80004e4a:	b7c1                	j	80004e0a <fileread+0x54>
    panic("fileread");
    80004e4c:	00004517          	auipc	a0,0x4
    80004e50:	88450513          	addi	a0,a0,-1916 # 800086d0 <syscalls+0x2d8>
    80004e54:	937fb0ef          	jal	ra,8000078a <panic>
    return -1;
    80004e58:	597d                	li	s2,-1
    80004e5a:	bf45                	j	80004e0a <fileread+0x54>
      return -1;
    80004e5c:	597d                	li	s2,-1
    80004e5e:	b775                	j	80004e0a <fileread+0x54>
    80004e60:	597d                	li	s2,-1
    80004e62:	b765                	j	80004e0a <fileread+0x54>

0000000080004e64 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e64:	715d                	addi	sp,sp,-80
    80004e66:	e486                	sd	ra,72(sp)
    80004e68:	e0a2                	sd	s0,64(sp)
    80004e6a:	fc26                	sd	s1,56(sp)
    80004e6c:	f84a                	sd	s2,48(sp)
    80004e6e:	f44e                	sd	s3,40(sp)
    80004e70:	f052                	sd	s4,32(sp)
    80004e72:	ec56                	sd	s5,24(sp)
    80004e74:	e85a                	sd	s6,16(sp)
    80004e76:	e45e                	sd	s7,8(sp)
    80004e78:	e062                	sd	s8,0(sp)
    80004e7a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e7c:	00954783          	lbu	a5,9(a0)
    80004e80:	0e078863          	beqz	a5,80004f70 <filewrite+0x10c>
    80004e84:	892a                	mv	s2,a0
    80004e86:	8aae                	mv	s5,a1
    80004e88:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e8a:	411c                	lw	a5,0(a0)
    80004e8c:	4705                	li	a4,1
    80004e8e:	02e78263          	beq	a5,a4,80004eb2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e92:	470d                	li	a4,3
    80004e94:	02e78463          	beq	a5,a4,80004ebc <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e98:	4709                	li	a4,2
    80004e9a:	0ce79563          	bne	a5,a4,80004f64 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e9e:	0ac05163          	blez	a2,80004f40 <filewrite+0xdc>
    int i = 0;
    80004ea2:	4981                	li	s3,0
    80004ea4:	6b05                	lui	s6,0x1
    80004ea6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004eaa:	6b85                	lui	s7,0x1
    80004eac:	c00b8b9b          	addiw	s7,s7,-1024
    80004eb0:	a041                	j	80004f30 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004eb2:	6908                	ld	a0,16(a0)
    80004eb4:	1e2000ef          	jal	ra,80005096 <pipewrite>
    80004eb8:	8a2a                	mv	s4,a0
    80004eba:	a071                	j	80004f46 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ebc:	02451783          	lh	a5,36(a0)
    80004ec0:	03079693          	slli	a3,a5,0x30
    80004ec4:	92c1                	srli	a3,a3,0x30
    80004ec6:	4725                	li	a4,9
    80004ec8:	0ad76663          	bltu	a4,a3,80004f74 <filewrite+0x110>
    80004ecc:	0792                	slli	a5,a5,0x4
    80004ece:	00246717          	auipc	a4,0x246
    80004ed2:	bba70713          	addi	a4,a4,-1094 # 8024aa88 <devsw>
    80004ed6:	97ba                	add	a5,a5,a4
    80004ed8:	679c                	ld	a5,8(a5)
    80004eda:	cfd9                	beqz	a5,80004f78 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004edc:	4505                	li	a0,1
    80004ede:	9782                	jalr	a5
    80004ee0:	8a2a                	mv	s4,a0
    80004ee2:	a095                	j	80004f46 <filewrite+0xe2>
    80004ee4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ee8:	9bbff0ef          	jal	ra,800048a2 <begin_op>
      ilock(f->ip);
    80004eec:	01893503          	ld	a0,24(s2)
    80004ef0:	fd5fe0ef          	jal	ra,80003ec4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ef4:	8762                	mv	a4,s8
    80004ef6:	02092683          	lw	a3,32(s2)
    80004efa:	01598633          	add	a2,s3,s5
    80004efe:	4585                	li	a1,1
    80004f00:	01893503          	ld	a0,24(s2)
    80004f04:	c30ff0ef          	jal	ra,80004334 <writei>
    80004f08:	84aa                	mv	s1,a0
    80004f0a:	00a05763          	blez	a0,80004f18 <filewrite+0xb4>
        f->off += r;
    80004f0e:	02092783          	lw	a5,32(s2)
    80004f12:	9fa9                	addw	a5,a5,a0
    80004f14:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f18:	01893503          	ld	a0,24(s2)
    80004f1c:	852ff0ef          	jal	ra,80003f6e <iunlock>
      end_op();
    80004f20:	9f3ff0ef          	jal	ra,80004912 <end_op>

      if(r != n1){
    80004f24:	009c1f63          	bne	s8,s1,80004f42 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004f28:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f2c:	0149db63          	bge	s3,s4,80004f42 <filewrite+0xde>
      int n1 = n - i;
    80004f30:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004f34:	84be                	mv	s1,a5
    80004f36:	2781                	sext.w	a5,a5
    80004f38:	fafb56e3          	bge	s6,a5,80004ee4 <filewrite+0x80>
    80004f3c:	84de                	mv	s1,s7
    80004f3e:	b75d                	j	80004ee4 <filewrite+0x80>
    int i = 0;
    80004f40:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f42:	013a1f63          	bne	s4,s3,80004f60 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f46:	8552                	mv	a0,s4
    80004f48:	60a6                	ld	ra,72(sp)
    80004f4a:	6406                	ld	s0,64(sp)
    80004f4c:	74e2                	ld	s1,56(sp)
    80004f4e:	7942                	ld	s2,48(sp)
    80004f50:	79a2                	ld	s3,40(sp)
    80004f52:	7a02                	ld	s4,32(sp)
    80004f54:	6ae2                	ld	s5,24(sp)
    80004f56:	6b42                	ld	s6,16(sp)
    80004f58:	6ba2                	ld	s7,8(sp)
    80004f5a:	6c02                	ld	s8,0(sp)
    80004f5c:	6161                	addi	sp,sp,80
    80004f5e:	8082                	ret
    ret = (i == n ? n : -1);
    80004f60:	5a7d                	li	s4,-1
    80004f62:	b7d5                	j	80004f46 <filewrite+0xe2>
    panic("filewrite");
    80004f64:	00003517          	auipc	a0,0x3
    80004f68:	77c50513          	addi	a0,a0,1916 # 800086e0 <syscalls+0x2e8>
    80004f6c:	81ffb0ef          	jal	ra,8000078a <panic>
    return -1;
    80004f70:	5a7d                	li	s4,-1
    80004f72:	bfd1                	j	80004f46 <filewrite+0xe2>
      return -1;
    80004f74:	5a7d                	li	s4,-1
    80004f76:	bfc1                	j	80004f46 <filewrite+0xe2>
    80004f78:	5a7d                	li	s4,-1
    80004f7a:	b7f1                	j	80004f46 <filewrite+0xe2>

0000000080004f7c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f7c:	7179                	addi	sp,sp,-48
    80004f7e:	f406                	sd	ra,40(sp)
    80004f80:	f022                	sd	s0,32(sp)
    80004f82:	ec26                	sd	s1,24(sp)
    80004f84:	e84a                	sd	s2,16(sp)
    80004f86:	e44e                	sd	s3,8(sp)
    80004f88:	e052                	sd	s4,0(sp)
    80004f8a:	1800                	addi	s0,sp,48
    80004f8c:	84aa                	mv	s1,a0
    80004f8e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f90:	0005b023          	sd	zero,0(a1)
    80004f94:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f98:	c75ff0ef          	jal	ra,80004c0c <filealloc>
    80004f9c:	e088                	sd	a0,0(s1)
    80004f9e:	cd35                	beqz	a0,8000501a <pipealloc+0x9e>
    80004fa0:	c6dff0ef          	jal	ra,80004c0c <filealloc>
    80004fa4:	00aa3023          	sd	a0,0(s4)
    80004fa8:	c52d                	beqz	a0,80005012 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004faa:	c03fb0ef          	jal	ra,80000bac <kalloc>
    80004fae:	892a                	mv	s2,a0
    80004fb0:	cd31                	beqz	a0,8000500c <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004fb2:	4985                	li	s3,1
    80004fb4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004fb8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004fbc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004fc0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004fc4:	00003597          	auipc	a1,0x3
    80004fc8:	72c58593          	addi	a1,a1,1836 # 800086f0 <syscalls+0x2f8>
    80004fcc:	c65fb0ef          	jal	ra,80000c30 <initlock>
  (*f0)->type = FD_PIPE;
    80004fd0:	609c                	ld	a5,0(s1)
    80004fd2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004fd6:	609c                	ld	a5,0(s1)
    80004fd8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004fdc:	609c                	ld	a5,0(s1)
    80004fde:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004fe2:	609c                	ld	a5,0(s1)
    80004fe4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004fe8:	000a3783          	ld	a5,0(s4)
    80004fec:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ff0:	000a3783          	ld	a5,0(s4)
    80004ff4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ff8:	000a3783          	ld	a5,0(s4)
    80004ffc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005000:	000a3783          	ld	a5,0(s4)
    80005004:	0127b823          	sd	s2,16(a5)
  return 0;
    80005008:	4501                	li	a0,0
    8000500a:	a005                	j	8000502a <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000500c:	6088                	ld	a0,0(s1)
    8000500e:	e501                	bnez	a0,80005016 <pipealloc+0x9a>
    80005010:	a029                	j	8000501a <pipealloc+0x9e>
    80005012:	6088                	ld	a0,0(s1)
    80005014:	c11d                	beqz	a0,8000503a <pipealloc+0xbe>
    fileclose(*f0);
    80005016:	c9bff0ef          	jal	ra,80004cb0 <fileclose>
  if(*f1)
    8000501a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000501e:	557d                	li	a0,-1
  if(*f1)
    80005020:	c789                	beqz	a5,8000502a <pipealloc+0xae>
    fileclose(*f1);
    80005022:	853e                	mv	a0,a5
    80005024:	c8dff0ef          	jal	ra,80004cb0 <fileclose>
  return -1;
    80005028:	557d                	li	a0,-1
}
    8000502a:	70a2                	ld	ra,40(sp)
    8000502c:	7402                	ld	s0,32(sp)
    8000502e:	64e2                	ld	s1,24(sp)
    80005030:	6942                	ld	s2,16(sp)
    80005032:	69a2                	ld	s3,8(sp)
    80005034:	6a02                	ld	s4,0(sp)
    80005036:	6145                	addi	sp,sp,48
    80005038:	8082                	ret
  return -1;
    8000503a:	557d                	li	a0,-1
    8000503c:	b7fd                	j	8000502a <pipealloc+0xae>

000000008000503e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000503e:	1101                	addi	sp,sp,-32
    80005040:	ec06                	sd	ra,24(sp)
    80005042:	e822                	sd	s0,16(sp)
    80005044:	e426                	sd	s1,8(sp)
    80005046:	e04a                	sd	s2,0(sp)
    80005048:	1000                	addi	s0,sp,32
    8000504a:	84aa                	mv	s1,a0
    8000504c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000504e:	c63fb0ef          	jal	ra,80000cb0 <acquire>
  if(writable){
    80005052:	02090763          	beqz	s2,80005080 <pipeclose+0x42>
    pi->writeopen = 0;
    80005056:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000505a:	21848513          	addi	a0,s1,536
    8000505e:	c96fd0ef          	jal	ra,800024f4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005062:	2204b783          	ld	a5,544(s1)
    80005066:	e785                	bnez	a5,8000508e <pipeclose+0x50>
    release(&pi->lock);
    80005068:	8526                	mv	a0,s1
    8000506a:	cdffb0ef          	jal	ra,80000d48 <release>
    kfree((char*)pi);
    8000506e:	8526                	mv	a0,s1
    80005070:	a0ffb0ef          	jal	ra,80000a7e <kfree>
  } else
    release(&pi->lock);
}
    80005074:	60e2                	ld	ra,24(sp)
    80005076:	6442                	ld	s0,16(sp)
    80005078:	64a2                	ld	s1,8(sp)
    8000507a:	6902                	ld	s2,0(sp)
    8000507c:	6105                	addi	sp,sp,32
    8000507e:	8082                	ret
    pi->readopen = 0;
    80005080:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005084:	21c48513          	addi	a0,s1,540
    80005088:	c6cfd0ef          	jal	ra,800024f4 <wakeup>
    8000508c:	bfd9                	j	80005062 <pipeclose+0x24>
    release(&pi->lock);
    8000508e:	8526                	mv	a0,s1
    80005090:	cb9fb0ef          	jal	ra,80000d48 <release>
}
    80005094:	b7c5                	j	80005074 <pipeclose+0x36>

0000000080005096 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005096:	711d                	addi	sp,sp,-96
    80005098:	ec86                	sd	ra,88(sp)
    8000509a:	e8a2                	sd	s0,80(sp)
    8000509c:	e4a6                	sd	s1,72(sp)
    8000509e:	e0ca                	sd	s2,64(sp)
    800050a0:	fc4e                	sd	s3,56(sp)
    800050a2:	f852                	sd	s4,48(sp)
    800050a4:	f456                	sd	s5,40(sp)
    800050a6:	f05a                	sd	s6,32(sp)
    800050a8:	ec5e                	sd	s7,24(sp)
    800050aa:	e862                	sd	s8,16(sp)
    800050ac:	1080                	addi	s0,sp,96
    800050ae:	84aa                	mv	s1,a0
    800050b0:	8aae                	mv	s5,a1
    800050b2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800050b4:	afdfc0ef          	jal	ra,80001bb0 <myproc>
    800050b8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800050ba:	8526                	mv	a0,s1
    800050bc:	bf5fb0ef          	jal	ra,80000cb0 <acquire>
  while(i < n){
    800050c0:	09405c63          	blez	s4,80005158 <pipewrite+0xc2>
  int i = 0;
    800050c4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050c6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800050c8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800050cc:	21c48b93          	addi	s7,s1,540
    800050d0:	a81d                	j	80005106 <pipewrite+0x70>
      release(&pi->lock);
    800050d2:	8526                	mv	a0,s1
    800050d4:	c75fb0ef          	jal	ra,80000d48 <release>
      return -1;
    800050d8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050da:	854a                	mv	a0,s2
    800050dc:	60e6                	ld	ra,88(sp)
    800050de:	6446                	ld	s0,80(sp)
    800050e0:	64a6                	ld	s1,72(sp)
    800050e2:	6906                	ld	s2,64(sp)
    800050e4:	79e2                	ld	s3,56(sp)
    800050e6:	7a42                	ld	s4,48(sp)
    800050e8:	7aa2                	ld	s5,40(sp)
    800050ea:	7b02                	ld	s6,32(sp)
    800050ec:	6be2                	ld	s7,24(sp)
    800050ee:	6c42                	ld	s8,16(sp)
    800050f0:	6125                	addi	sp,sp,96
    800050f2:	8082                	ret
      wakeup(&pi->nread);
    800050f4:	8562                	mv	a0,s8
    800050f6:	bfefd0ef          	jal	ra,800024f4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050fa:	85a6                	mv	a1,s1
    800050fc:	855e                	mv	a0,s7
    800050fe:	baafd0ef          	jal	ra,800024a8 <sleep>
  while(i < n){
    80005102:	05495c63          	bge	s2,s4,8000515a <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80005106:	2204a783          	lw	a5,544(s1)
    8000510a:	d7e1                	beqz	a5,800050d2 <pipewrite+0x3c>
    8000510c:	854e                	mv	a0,s3
    8000510e:	dd2fd0ef          	jal	ra,800026e0 <killed>
    80005112:	f161                	bnez	a0,800050d2 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005114:	2184a783          	lw	a5,536(s1)
    80005118:	21c4a703          	lw	a4,540(s1)
    8000511c:	2007879b          	addiw	a5,a5,512
    80005120:	fcf70ae3          	beq	a4,a5,800050f4 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005124:	4685                	li	a3,1
    80005126:	01590633          	add	a2,s2,s5
    8000512a:	faf40593          	addi	a1,s0,-81
    8000512e:	0509b503          	ld	a0,80(s3)
    80005132:	f7efc0ef          	jal	ra,800018b0 <copyin>
    80005136:	03650263          	beq	a0,s6,8000515a <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000513a:	21c4a783          	lw	a5,540(s1)
    8000513e:	0017871b          	addiw	a4,a5,1
    80005142:	20e4ae23          	sw	a4,540(s1)
    80005146:	1ff7f793          	andi	a5,a5,511
    8000514a:	97a6                	add	a5,a5,s1
    8000514c:	faf44703          	lbu	a4,-81(s0)
    80005150:	00e78c23          	sb	a4,24(a5)
      i++;
    80005154:	2905                	addiw	s2,s2,1
    80005156:	b775                	j	80005102 <pipewrite+0x6c>
  int i = 0;
    80005158:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000515a:	21848513          	addi	a0,s1,536
    8000515e:	b96fd0ef          	jal	ra,800024f4 <wakeup>
  release(&pi->lock);
    80005162:	8526                	mv	a0,s1
    80005164:	be5fb0ef          	jal	ra,80000d48 <release>
  return i;
    80005168:	bf8d                	j	800050da <pipewrite+0x44>

000000008000516a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000516a:	715d                	addi	sp,sp,-80
    8000516c:	e486                	sd	ra,72(sp)
    8000516e:	e0a2                	sd	s0,64(sp)
    80005170:	fc26                	sd	s1,56(sp)
    80005172:	f84a                	sd	s2,48(sp)
    80005174:	f44e                	sd	s3,40(sp)
    80005176:	f052                	sd	s4,32(sp)
    80005178:	ec56                	sd	s5,24(sp)
    8000517a:	e85a                	sd	s6,16(sp)
    8000517c:	0880                	addi	s0,sp,80
    8000517e:	84aa                	mv	s1,a0
    80005180:	892e                	mv	s2,a1
    80005182:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005184:	a2dfc0ef          	jal	ra,80001bb0 <myproc>
    80005188:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000518a:	8526                	mv	a0,s1
    8000518c:	b25fb0ef          	jal	ra,80000cb0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005190:	2184a703          	lw	a4,536(s1)
    80005194:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005198:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000519c:	02f71363          	bne	a4,a5,800051c2 <piperead+0x58>
    800051a0:	2244a783          	lw	a5,548(s1)
    800051a4:	cf99                	beqz	a5,800051c2 <piperead+0x58>
    if(killed(pr)){
    800051a6:	8552                	mv	a0,s4
    800051a8:	d38fd0ef          	jal	ra,800026e0 <killed>
    800051ac:	e149                	bnez	a0,8000522e <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051ae:	85a6                	mv	a1,s1
    800051b0:	854e                	mv	a0,s3
    800051b2:	af6fd0ef          	jal	ra,800024a8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051b6:	2184a703          	lw	a4,536(s1)
    800051ba:	21c4a783          	lw	a5,540(s1)
    800051be:	fef701e3          	beq	a4,a5,800051a0 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051c2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800051c4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051c6:	05505263          	blez	s5,8000520a <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    800051ca:	2184a783          	lw	a5,536(s1)
    800051ce:	21c4a703          	lw	a4,540(s1)
    800051d2:	02f70c63          	beq	a4,a5,8000520a <piperead+0xa0>
    ch = pi->data[pi->nread % PIPESIZE];
    800051d6:	1ff7f793          	andi	a5,a5,511
    800051da:	97a6                	add	a5,a5,s1
    800051dc:	0187c783          	lbu	a5,24(a5)
    800051e0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800051e4:	4685                	li	a3,1
    800051e6:	fbf40613          	addi	a2,s0,-65
    800051ea:	85ca                	mv	a1,s2
    800051ec:	050a3503          	ld	a0,80(s4)
    800051f0:	db0fc0ef          	jal	ra,800017a0 <copyout>
    800051f4:	05650263          	beq	a0,s6,80005238 <piperead+0xce>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800051f8:	2184a783          	lw	a5,536(s1)
    800051fc:	2785                	addiw	a5,a5,1
    800051fe:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005202:	2985                	addiw	s3,s3,1
    80005204:	0905                	addi	s2,s2,1
    80005206:	fd3a92e3          	bne	s5,s3,800051ca <piperead+0x60>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000520a:	21c48513          	addi	a0,s1,540
    8000520e:	ae6fd0ef          	jal	ra,800024f4 <wakeup>
  release(&pi->lock);
    80005212:	8526                	mv	a0,s1
    80005214:	b35fb0ef          	jal	ra,80000d48 <release>
  return i;
}
    80005218:	854e                	mv	a0,s3
    8000521a:	60a6                	ld	ra,72(sp)
    8000521c:	6406                	ld	s0,64(sp)
    8000521e:	74e2                	ld	s1,56(sp)
    80005220:	7942                	ld	s2,48(sp)
    80005222:	79a2                	ld	s3,40(sp)
    80005224:	7a02                	ld	s4,32(sp)
    80005226:	6ae2                	ld	s5,24(sp)
    80005228:	6b42                	ld	s6,16(sp)
    8000522a:	6161                	addi	sp,sp,80
    8000522c:	8082                	ret
      release(&pi->lock);
    8000522e:	8526                	mv	a0,s1
    80005230:	b19fb0ef          	jal	ra,80000d48 <release>
      return -1;
    80005234:	59fd                	li	s3,-1
    80005236:	b7cd                	j	80005218 <piperead+0xae>
      if(i == 0)
    80005238:	fc0999e3          	bnez	s3,8000520a <piperead+0xa0>
        i = -1;
    8000523c:	89aa                	mv	s3,a0
    8000523e:	b7f1                	j	8000520a <piperead+0xa0>

0000000080005240 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005240:	1141                	addi	sp,sp,-16
    80005242:	e422                	sd	s0,8(sp)
    80005244:	0800                	addi	s0,sp,16
    80005246:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005248:	8905                	andi	a0,a0,1
    8000524a:	c111                	beqz	a0,8000524e <flags2perm+0xe>
      perm = PTE_X;
    8000524c:	4521                	li	a0,8
    if(flags & 0x2)
    8000524e:	8b89                	andi	a5,a5,2
    80005250:	c399                	beqz	a5,80005256 <flags2perm+0x16>
      perm |= PTE_W;
    80005252:	00456513          	ori	a0,a0,4
    return perm;
}
    80005256:	6422                	ld	s0,8(sp)
    80005258:	0141                	addi	sp,sp,16
    8000525a:	8082                	ret

000000008000525c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000525c:	b5010113          	addi	sp,sp,-1200
    80005260:	4a113423          	sd	ra,1192(sp)
    80005264:	4a813023          	sd	s0,1184(sp)
    80005268:	48913c23          	sd	s1,1176(sp)
    8000526c:	49213823          	sd	s2,1168(sp)
    80005270:	49313423          	sd	s3,1160(sp)
    80005274:	49413023          	sd	s4,1152(sp)
    80005278:	47513c23          	sd	s5,1144(sp)
    8000527c:	47613823          	sd	s6,1136(sp)
    80005280:	47713423          	sd	s7,1128(sp)
    80005284:	47813023          	sd	s8,1120(sp)
    80005288:	45913c23          	sd	s9,1112(sp)
    8000528c:	45a13823          	sd	s10,1104(sp)
    80005290:	45b13423          	sd	s11,1096(sp)
    80005294:	4b010413          	addi	s0,sp,1200
    80005298:	84aa                	mv	s1,a0
    8000529a:	b6a43023          	sd	a0,-1184(s0)
    8000529e:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800052a2:	90ffc0ef          	jal	ra,80001bb0 <myproc>
    800052a6:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    800052aa:	df8ff0ef          	jal	ra,800048a2 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800052ae:	8526                	mv	a0,s1
    800052b0:	c02ff0ef          	jal	ra,800046b2 <namei>
    800052b4:	cd25                	beqz	a0,8000532c <kexec+0xd0>
    800052b6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800052b8:	c0dfe0ef          	jal	ra,80003ec4 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800052bc:	04000713          	li	a4,64
    800052c0:	4681                	li	a3,0
    800052c2:	e5040613          	addi	a2,s0,-432
    800052c6:	4581                	li	a1,0
    800052c8:	8556                	mv	a0,s5
    800052ca:	f87fe0ef          	jal	ra,80004250 <readi>
    800052ce:	04000793          	li	a5,64
    800052d2:	00f51a63          	bne	a0,a5,800052e6 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800052d6:	e5042703          	lw	a4,-432(s0)
    800052da:	464c47b7          	lui	a5,0x464c4
    800052de:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052e2:	04f70963          	beq	a4,a5,80005334 <kexec+0xd8>
    memset(p->vmas, 0, sizeof(p->vmas));
    vma_release_all(p);
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    800052e6:	8556                	mv	a0,s5
    800052e8:	de3fe0ef          	jal	ra,800040ca <iunlockput>
    end_op();
    800052ec:	e26ff0ef          	jal	ra,80004912 <end_op>
  }
  return -1;
    800052f0:	557d                	li	a0,-1
}
    800052f2:	4a813083          	ld	ra,1192(sp)
    800052f6:	4a013403          	ld	s0,1184(sp)
    800052fa:	49813483          	ld	s1,1176(sp)
    800052fe:	49013903          	ld	s2,1168(sp)
    80005302:	48813983          	ld	s3,1160(sp)
    80005306:	48013a03          	ld	s4,1152(sp)
    8000530a:	47813a83          	ld	s5,1144(sp)
    8000530e:	47013b03          	ld	s6,1136(sp)
    80005312:	46813b83          	ld	s7,1128(sp)
    80005316:	46013c03          	ld	s8,1120(sp)
    8000531a:	45813c83          	ld	s9,1112(sp)
    8000531e:	45013d03          	ld	s10,1104(sp)
    80005322:	44813d83          	ld	s11,1096(sp)
    80005326:	4b010113          	addi	sp,sp,1200
    8000532a:	8082                	ret
    end_op();
    8000532c:	de6ff0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005330:	557d                	li	a0,-1
    80005332:	b7c1                	j	800052f2 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80005334:	b7843503          	ld	a0,-1160(s0)
    80005338:	b6dfc0ef          	jal	ra,80001ea4 <proc_pagetable>
    8000533c:	8baa                	mv	s7,a0
    8000533e:	d545                	beqz	a0,800052e6 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005340:	e7042783          	lw	a5,-400(s0)
    80005344:	e8845703          	lhu	a4,-376(s0)
    80005348:	0e070d63          	beqz	a4,80005442 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000534c:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005350:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005354:	6a05                	lui	s4,0x1
    80005356:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000535a:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000535e:	6d85                	lui	s11,0x1
    80005360:	7d7d                	lui	s10,0xfffff
    80005362:	a09d                	j	800053c8 <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005364:	00003517          	auipc	a0,0x3
    80005368:	39450513          	addi	a0,a0,916 # 800086f8 <syscalls+0x300>
    8000536c:	c1efb0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005370:	874a                	mv	a4,s2
    80005372:	009c86bb          	addw	a3,s9,s1
    80005376:	4581                	li	a1,0
    80005378:	8556                	mv	a0,s5
    8000537a:	ed7fe0ef          	jal	ra,80004250 <readi>
    8000537e:	2501                	sext.w	a0,a0
    80005380:	0ea91e63          	bne	s2,a0,8000547c <kexec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80005384:	009d84bb          	addw	s1,s11,s1
    80005388:	013d09bb          	addw	s3,s10,s3
    8000538c:	0364f063          	bgeu	s1,s6,800053ac <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80005390:	02049593          	slli	a1,s1,0x20
    80005394:	9181                	srli	a1,a1,0x20
    80005396:	95e2                	add	a1,a1,s8
    80005398:	855e                	mv	a0,s7
    8000539a:	d0dfb0ef          	jal	ra,800010a6 <walkaddr>
    8000539e:	862a                	mv	a2,a0
    if(pa == 0)
    800053a0:	d171                	beqz	a0,80005364 <kexec+0x108>
      n = PGSIZE;
    800053a2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800053a4:	fd49f6e3          	bgeu	s3,s4,80005370 <kexec+0x114>
      n = sz - i;
    800053a8:	894e                	mv	s2,s3
    800053aa:	b7d9                	j	80005370 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053ac:	b8843783          	ld	a5,-1144(s0)
    800053b0:	0017869b          	addiw	a3,a5,1
    800053b4:	b8d43423          	sd	a3,-1144(s0)
    800053b8:	b8043783          	ld	a5,-1152(s0)
    800053bc:	0387879b          	addiw	a5,a5,56
    800053c0:	e8845703          	lhu	a4,-376(s0)
    800053c4:	08e6d163          	bge	a3,a4,80005446 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053c8:	2781                	sext.w	a5,a5
    800053ca:	b8f43023          	sd	a5,-1152(s0)
    800053ce:	03800713          	li	a4,56
    800053d2:	86be                	mv	a3,a5
    800053d4:	e1840613          	addi	a2,s0,-488
    800053d8:	4581                	li	a1,0
    800053da:	8556                	mv	a0,s5
    800053dc:	e75fe0ef          	jal	ra,80004250 <readi>
    800053e0:	03800793          	li	a5,56
    800053e4:	08f51c63          	bne	a0,a5,8000547c <kexec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    800053e8:	e1842783          	lw	a5,-488(s0)
    800053ec:	4705                	li	a4,1
    800053ee:	fae79fe3          	bne	a5,a4,800053ac <kexec+0x150>
    if(ph.memsz < ph.filesz)
    800053f2:	e4043483          	ld	s1,-448(s0)
    800053f6:	e3843783          	ld	a5,-456(s0)
    800053fa:	08f4e163          	bltu	s1,a5,8000547c <kexec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053fe:	e2843783          	ld	a5,-472(s0)
    80005402:	94be                	add	s1,s1,a5
    80005404:	06f4ec63          	bltu	s1,a5,8000547c <kexec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80005408:	b5843703          	ld	a4,-1192(s0)
    8000540c:	8ff9                	and	a5,a5,a4
    8000540e:	e7bd                	bnez	a5,8000547c <kexec+0x220>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005410:	e1c42503          	lw	a0,-484(s0)
    80005414:	e2dff0ef          	jal	ra,80005240 <flags2perm>
    80005418:	86aa                	mv	a3,a0
    8000541a:	8626                	mv	a2,s1
    8000541c:	b7043583          	ld	a1,-1168(s0)
    80005420:	855e                	mv	a0,s7
    80005422:	f4ffb0ef          	jal	ra,80001370 <uvmalloc>
    80005426:	b6a43823          	sd	a0,-1168(s0)
    8000542a:	c929                	beqz	a0,8000547c <kexec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000542c:	e2843c03          	ld	s8,-472(s0)
    80005430:	e2042c83          	lw	s9,-480(s0)
    80005434:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005438:	f60b0ae3          	beqz	s6,800053ac <kexec+0x150>
    8000543c:	89da                	mv	s3,s6
    8000543e:	4481                	li	s1,0
    80005440:	bf81                	j	80005390 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005442:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    80005446:	8556                	mv	a0,s5
    80005448:	c83fe0ef          	jal	ra,800040ca <iunlockput>
  end_op();
    8000544c:	cc6ff0ef          	jal	ra,80004912 <end_op>
  p = myproc();
    80005450:	f60fc0ef          	jal	ra,80001bb0 <myproc>
    80005454:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    80005458:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000545c:	6585                	lui	a1,0x1
    8000545e:	15fd                	addi	a1,a1,-1
    80005460:	b7043783          	ld	a5,-1168(s0)
    80005464:	95be                	add	a1,a1,a5
    80005466:	77fd                	lui	a5,0xfffff
    80005468:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000546a:	4691                	li	a3,4
    8000546c:	6609                	lui	a2,0x2
    8000546e:	962e                	add	a2,a2,a1
    80005470:	855e                	mv	a0,s7
    80005472:	efffb0ef          	jal	ra,80001370 <uvmalloc>
    80005476:	8b2a                	mv	s6,a0
  ip = 0;
    80005478:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000547a:	e121                	bnez	a0,800054ba <kexec+0x25e>
    delete_shm_from_proc(p);
    8000547c:	b7843903          	ld	s2,-1160(s0)
    80005480:	854a                	mv	a0,s2
    80005482:	8b3fc0ef          	jal	ra,80001d34 <delete_shm_from_proc>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80005486:	16890493          	addi	s1,s2,360
    8000548a:	85a6                	mv	a1,s1
    8000548c:	05093503          	ld	a0,80(s2)
    80005490:	a99fc0ef          	jal	ra,80001f28 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80005494:	28000613          	li	a2,640
    80005498:	4581                	li	a1,0
    8000549a:	8526                	mv	a0,s1
    8000549c:	8e9fb0ef          	jal	ra,80000d84 <memset>
    vma_release_all(p);
    800054a0:	854a                	mv	a0,s2
    800054a2:	913fc0ef          	jal	ra,80001db4 <vma_release_all>
    proc_freepagetable(p->pagetable, p->sz);
    800054a6:	04893583          	ld	a1,72(s2)
    800054aa:	05093503          	ld	a0,80(s2)
    800054ae:	ac5fc0ef          	jal	ra,80001f72 <proc_freepagetable>
  if(ip){
    800054b2:	e20a9ae3          	bnez	s5,800052e6 <kexec+0x8a>
  return -1;
    800054b6:	557d                	li	a0,-1
    800054b8:	bd2d                	j	800052f2 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800054ba:	75f9                	lui	a1,0xffffe
    800054bc:	95aa                	add	a1,a1,a0
    800054be:	855e                	mv	a0,s7
    800054c0:	974fc0ef          	jal	ra,80001634 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800054c4:	7c7d                	lui	s8,0xfffff
    800054c6:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800054c8:	b6843783          	ld	a5,-1176(s0)
    800054cc:	6388                	ld	a0,0(a5)
    800054ce:	c125                	beqz	a0,8000552e <kexec+0x2d2>
    800054d0:	e9040993          	addi	s3,s0,-368
    800054d4:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    800054d8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800054da:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800054dc:	a21fb0ef          	jal	ra,80000efc <strlen>
    800054e0:	0015079b          	addiw	a5,a0,1
    800054e4:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054e8:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800054ec:	11896d63          	bltu	s2,s8,80005606 <kexec+0x3aa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054f0:	b6843d03          	ld	s10,-1176(s0)
    800054f4:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdaae00>
    800054f8:	8552                	mv	a0,s4
    800054fa:	a03fb0ef          	jal	ra,80000efc <strlen>
    800054fe:	0015069b          	addiw	a3,a0,1
    80005502:	8652                	mv	a2,s4
    80005504:	85ca                	mv	a1,s2
    80005506:	855e                	mv	a0,s7
    80005508:	a98fc0ef          	jal	ra,800017a0 <copyout>
    8000550c:	0e054f63          	bltz	a0,8000560a <kexec+0x3ae>
    ustack[argc] = sp;
    80005510:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005514:	0485                	addi	s1,s1,1
    80005516:	008d0793          	addi	a5,s10,8
    8000551a:	b6f43423          	sd	a5,-1176(s0)
    8000551e:	008d3503          	ld	a0,8(s10)
    80005522:	c901                	beqz	a0,80005532 <kexec+0x2d6>
    if(argc >= MAXARG)
    80005524:	09a1                	addi	s3,s3,8
    80005526:	fb599be3          	bne	s3,s5,800054dc <kexec+0x280>
  ip = 0;
    8000552a:	4a81                	li	s5,0
    8000552c:	bf81                	j	8000547c <kexec+0x220>
  sp = sz;
    8000552e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005530:	4481                	li	s1,0
  ustack[argc] = 0;
    80005532:	00349793          	slli	a5,s1,0x3
    80005536:	f9040713          	addi	a4,s0,-112
    8000553a:	97ba                	add	a5,a5,a4
    8000553c:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7fdaad00>
  sp -= (argc+1) * sizeof(uint64);
    80005540:	00148693          	addi	a3,s1,1
    80005544:	068e                	slli	a3,a3,0x3
    80005546:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000554a:	ff097913          	andi	s2,s2,-16
  ip = 0;
    8000554e:	4a81                	li	s5,0
  if(sp < stackbase)
    80005550:	f38966e3          	bltu	s2,s8,8000547c <kexec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005554:	e9040613          	addi	a2,s0,-368
    80005558:	85ca                	mv	a1,s2
    8000555a:	855e                	mv	a0,s7
    8000555c:	a44fc0ef          	jal	ra,800017a0 <copyout>
    80005560:	0a054763          	bltz	a0,8000560e <kexec+0x3b2>
  p->trapframe->a1 = sp;
    80005564:	b7843783          	ld	a5,-1160(s0)
    80005568:	6fbc                	ld	a5,88(a5)
    8000556a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000556e:	b6043783          	ld	a5,-1184(s0)
    80005572:	0007c703          	lbu	a4,0(a5)
    80005576:	cf11                	beqz	a4,80005592 <kexec+0x336>
    80005578:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000557a:	02f00693          	li	a3,47
    8000557e:	a039                	j	8000558c <kexec+0x330>
      last = s+1;
    80005580:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    80005584:	0785                	addi	a5,a5,1
    80005586:	fff7c703          	lbu	a4,-1(a5)
    8000558a:	c701                	beqz	a4,80005592 <kexec+0x336>
    if(*s == '/')
    8000558c:	fed71ce3          	bne	a4,a3,80005584 <kexec+0x328>
    80005590:	bfc5                	j	80005580 <kexec+0x324>
  safestrcpy(p->name, last, sizeof(p->name));
    80005592:	4641                	li	a2,16
    80005594:	b6043583          	ld	a1,-1184(s0)
    80005598:	b7843a83          	ld	s5,-1160(s0)
    8000559c:	158a8513          	addi	a0,s5,344
    800055a0:	92bfb0ef          	jal	ra,80000eca <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    800055a4:	168a8a13          	addi	s4,s5,360
    800055a8:	28000613          	li	a2,640
    800055ac:	85d2                	mv	a1,s4
    800055ae:	b9840513          	addi	a0,s0,-1128
    800055b2:	82ffb0ef          	jal	ra,80000de0 <memmove>
  oldpagetable = p->pagetable;
    800055b6:	050ab983          	ld	s3,80(s5)
  vma_release_all(p);
    800055ba:	8556                	mv	a0,s5
    800055bc:	ff8fc0ef          	jal	ra,80001db4 <vma_release_all>
  p->pagetable = pagetable;
    800055c0:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800055c4:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;
    800055c8:	058ab783          	ld	a5,88(s5)
    800055cc:	e6843703          	ld	a4,-408(s0)
    800055d0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    800055d2:	058ab783          	ld	a5,88(s5)
    800055d6:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    800055da:	28000613          	li	a2,640
    800055de:	4581                	li	a1,0
    800055e0:	8552                	mv	a0,s4
    800055e2:	fa2fb0ef          	jal	ra,80000d84 <memset>
  delete_shm_from_vmas(oldvmas);
    800055e6:	b9840513          	addi	a0,s0,-1128
    800055ea:	eccfc0ef          	jal	ra,80001cb6 <delete_shm_from_vmas>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    800055ee:	b9840593          	addi	a1,s0,-1128
    800055f2:	854e                	mv	a0,s3
    800055f4:	935fc0ef          	jal	ra,80001f28 <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    800055f8:	85e6                	mv	a1,s9
    800055fa:	854e                	mv	a0,s3
    800055fc:	977fc0ef          	jal	ra,80001f72 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005600:	0004851b          	sext.w	a0,s1
    80005604:	b1fd                	j	800052f2 <kexec+0x96>
  ip = 0;
    80005606:	4a81                	li	s5,0
    80005608:	bd95                	j	8000547c <kexec+0x220>
    8000560a:	4a81                	li	s5,0
    8000560c:	bd85                	j	8000547c <kexec+0x220>
    8000560e:	4a81                	li	s5,0
    80005610:	b5b5                	j	8000547c <kexec+0x220>

0000000080005612 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005612:	7179                	addi	sp,sp,-48
    80005614:	f406                	sd	ra,40(sp)
    80005616:	f022                	sd	s0,32(sp)
    80005618:	ec26                	sd	s1,24(sp)
    8000561a:	e84a                	sd	s2,16(sp)
    8000561c:	1800                	addi	s0,sp,48
    8000561e:	892e                	mv	s2,a1
    80005620:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005622:	fdc40593          	addi	a1,s0,-36
    80005626:	fb8fd0ef          	jal	ra,80002dde <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000562a:	fdc42703          	lw	a4,-36(s0)
    8000562e:	47bd                	li	a5,15
    80005630:	02e7e963          	bltu	a5,a4,80005662 <argfd+0x50>
    80005634:	d7cfc0ef          	jal	ra,80001bb0 <myproc>
    80005638:	fdc42703          	lw	a4,-36(s0)
    8000563c:	01a70793          	addi	a5,a4,26
    80005640:	078e                	slli	a5,a5,0x3
    80005642:	953e                	add	a0,a0,a5
    80005644:	611c                	ld	a5,0(a0)
    80005646:	c385                	beqz	a5,80005666 <argfd+0x54>
    return -1;
  if(pfd)
    80005648:	00090463          	beqz	s2,80005650 <argfd+0x3e>
    *pfd = fd;
    8000564c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005650:	4501                	li	a0,0
  if(pf)
    80005652:	c091                	beqz	s1,80005656 <argfd+0x44>
    *pf = f;
    80005654:	e09c                	sd	a5,0(s1)
}
    80005656:	70a2                	ld	ra,40(sp)
    80005658:	7402                	ld	s0,32(sp)
    8000565a:	64e2                	ld	s1,24(sp)
    8000565c:	6942                	ld	s2,16(sp)
    8000565e:	6145                	addi	sp,sp,48
    80005660:	8082                	ret
    return -1;
    80005662:	557d                	li	a0,-1
    80005664:	bfcd                	j	80005656 <argfd+0x44>
    80005666:	557d                	li	a0,-1
    80005668:	b7fd                	j	80005656 <argfd+0x44>

000000008000566a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000566a:	1101                	addi	sp,sp,-32
    8000566c:	ec06                	sd	ra,24(sp)
    8000566e:	e822                	sd	s0,16(sp)
    80005670:	e426                	sd	s1,8(sp)
    80005672:	1000                	addi	s0,sp,32
    80005674:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005676:	d3afc0ef          	jal	ra,80001bb0 <myproc>
    8000567a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000567c:	0d050793          	addi	a5,a0,208
    80005680:	4501                	li	a0,0
    80005682:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005684:	6398                	ld	a4,0(a5)
    80005686:	cb19                	beqz	a4,8000569c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005688:	2505                	addiw	a0,a0,1
    8000568a:	07a1                	addi	a5,a5,8
    8000568c:	fed51ce3          	bne	a0,a3,80005684 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005690:	557d                	li	a0,-1
}
    80005692:	60e2                	ld	ra,24(sp)
    80005694:	6442                	ld	s0,16(sp)
    80005696:	64a2                	ld	s1,8(sp)
    80005698:	6105                	addi	sp,sp,32
    8000569a:	8082                	ret
      p->ofile[fd] = f;
    8000569c:	01a50793          	addi	a5,a0,26
    800056a0:	078e                	slli	a5,a5,0x3
    800056a2:	963e                	add	a2,a2,a5
    800056a4:	e204                	sd	s1,0(a2)
      return fd;
    800056a6:	b7f5                	j	80005692 <fdalloc+0x28>

00000000800056a8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800056a8:	715d                	addi	sp,sp,-80
    800056aa:	e486                	sd	ra,72(sp)
    800056ac:	e0a2                	sd	s0,64(sp)
    800056ae:	fc26                	sd	s1,56(sp)
    800056b0:	f84a                	sd	s2,48(sp)
    800056b2:	f44e                	sd	s3,40(sp)
    800056b4:	f052                	sd	s4,32(sp)
    800056b6:	ec56                	sd	s5,24(sp)
    800056b8:	e85a                	sd	s6,16(sp)
    800056ba:	0880                	addi	s0,sp,80
    800056bc:	8b2e                	mv	s6,a1
    800056be:	89b2                	mv	s3,a2
    800056c0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056c2:	fb040593          	addi	a1,s0,-80
    800056c6:	806ff0ef          	jal	ra,800046cc <nameiparent>
    800056ca:	84aa                	mv	s1,a0
    800056cc:	10050b63          	beqz	a0,800057e2 <create+0x13a>
    return 0;

  ilock(dp);
    800056d0:	ff4fe0ef          	jal	ra,80003ec4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056d4:	4601                	li	a2,0
    800056d6:	fb040593          	addi	a1,s0,-80
    800056da:	8526                	mv	a0,s1
    800056dc:	d71fe0ef          	jal	ra,8000444c <dirlookup>
    800056e0:	8aaa                	mv	s5,a0
    800056e2:	c521                	beqz	a0,8000572a <create+0x82>
    iunlockput(dp);
    800056e4:	8526                	mv	a0,s1
    800056e6:	9e5fe0ef          	jal	ra,800040ca <iunlockput>
    ilock(ip);
    800056ea:	8556                	mv	a0,s5
    800056ec:	fd8fe0ef          	jal	ra,80003ec4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056f0:	000b059b          	sext.w	a1,s6
    800056f4:	4789                	li	a5,2
    800056f6:	02f59563          	bne	a1,a5,80005720 <create+0x78>
    800056fa:	044ad783          	lhu	a5,68(s5)
    800056fe:	37f9                	addiw	a5,a5,-2
    80005700:	17c2                	slli	a5,a5,0x30
    80005702:	93c1                	srli	a5,a5,0x30
    80005704:	4705                	li	a4,1
    80005706:	00f76d63          	bltu	a4,a5,80005720 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000570a:	8556                	mv	a0,s5
    8000570c:	60a6                	ld	ra,72(sp)
    8000570e:	6406                	ld	s0,64(sp)
    80005710:	74e2                	ld	s1,56(sp)
    80005712:	7942                	ld	s2,48(sp)
    80005714:	79a2                	ld	s3,40(sp)
    80005716:	7a02                	ld	s4,32(sp)
    80005718:	6ae2                	ld	s5,24(sp)
    8000571a:	6b42                	ld	s6,16(sp)
    8000571c:	6161                	addi	sp,sp,80
    8000571e:	8082                	ret
    iunlockput(ip);
    80005720:	8556                	mv	a0,s5
    80005722:	9a9fe0ef          	jal	ra,800040ca <iunlockput>
    return 0;
    80005726:	4a81                	li	s5,0
    80005728:	b7cd                	j	8000570a <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000572a:	85da                	mv	a1,s6
    8000572c:	4088                	lw	a0,0(s1)
    8000572e:	e2efe0ef          	jal	ra,80003d5c <ialloc>
    80005732:	8a2a                	mv	s4,a0
    80005734:	cd1d                	beqz	a0,80005772 <create+0xca>
  ilock(ip);
    80005736:	f8efe0ef          	jal	ra,80003ec4 <ilock>
  ip->major = major;
    8000573a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000573e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005742:	4905                	li	s2,1
    80005744:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005748:	8552                	mv	a0,s4
    8000574a:	ec8fe0ef          	jal	ra,80003e12 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000574e:	000b059b          	sext.w	a1,s6
    80005752:	03258563          	beq	a1,s2,8000577c <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80005756:	004a2603          	lw	a2,4(s4)
    8000575a:	fb040593          	addi	a1,s0,-80
    8000575e:	8526                	mv	a0,s1
    80005760:	eb9fe0ef          	jal	ra,80004618 <dirlink>
    80005764:	06054363          	bltz	a0,800057ca <create+0x122>
  iunlockput(dp);
    80005768:	8526                	mv	a0,s1
    8000576a:	961fe0ef          	jal	ra,800040ca <iunlockput>
  return ip;
    8000576e:	8ad2                	mv	s5,s4
    80005770:	bf69                	j	8000570a <create+0x62>
    iunlockput(dp);
    80005772:	8526                	mv	a0,s1
    80005774:	957fe0ef          	jal	ra,800040ca <iunlockput>
    return 0;
    80005778:	8ad2                	mv	s5,s4
    8000577a:	bf41                	j	8000570a <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000577c:	004a2603          	lw	a2,4(s4)
    80005780:	00003597          	auipc	a1,0x3
    80005784:	f9858593          	addi	a1,a1,-104 # 80008718 <syscalls+0x320>
    80005788:	8552                	mv	a0,s4
    8000578a:	e8ffe0ef          	jal	ra,80004618 <dirlink>
    8000578e:	02054e63          	bltz	a0,800057ca <create+0x122>
    80005792:	40d0                	lw	a2,4(s1)
    80005794:	00003597          	auipc	a1,0x3
    80005798:	f8c58593          	addi	a1,a1,-116 # 80008720 <syscalls+0x328>
    8000579c:	8552                	mv	a0,s4
    8000579e:	e7bfe0ef          	jal	ra,80004618 <dirlink>
    800057a2:	02054463          	bltz	a0,800057ca <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    800057a6:	004a2603          	lw	a2,4(s4)
    800057aa:	fb040593          	addi	a1,s0,-80
    800057ae:	8526                	mv	a0,s1
    800057b0:	e69fe0ef          	jal	ra,80004618 <dirlink>
    800057b4:	00054b63          	bltz	a0,800057ca <create+0x122>
    dp->nlink++;  // for ".."
    800057b8:	04a4d783          	lhu	a5,74(s1)
    800057bc:	2785                	addiw	a5,a5,1
    800057be:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057c2:	8526                	mv	a0,s1
    800057c4:	e4efe0ef          	jal	ra,80003e12 <iupdate>
    800057c8:	b745                	j	80005768 <create+0xc0>
  ip->nlink = 0;
    800057ca:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057ce:	8552                	mv	a0,s4
    800057d0:	e42fe0ef          	jal	ra,80003e12 <iupdate>
  iunlockput(ip);
    800057d4:	8552                	mv	a0,s4
    800057d6:	8f5fe0ef          	jal	ra,800040ca <iunlockput>
  iunlockput(dp);
    800057da:	8526                	mv	a0,s1
    800057dc:	8effe0ef          	jal	ra,800040ca <iunlockput>
  return 0;
    800057e0:	b72d                	j	8000570a <create+0x62>
    return 0;
    800057e2:	8aaa                	mv	s5,a0
    800057e4:	b71d                	j	8000570a <create+0x62>

00000000800057e6 <sys_dup>:
{
    800057e6:	7179                	addi	sp,sp,-48
    800057e8:	f406                	sd	ra,40(sp)
    800057ea:	f022                	sd	s0,32(sp)
    800057ec:	ec26                	sd	s1,24(sp)
    800057ee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057f0:	fd840613          	addi	a2,s0,-40
    800057f4:	4581                	li	a1,0
    800057f6:	4501                	li	a0,0
    800057f8:	e1bff0ef          	jal	ra,80005612 <argfd>
    return -1;
    800057fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057fe:	00054f63          	bltz	a0,8000581c <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80005802:	fd843503          	ld	a0,-40(s0)
    80005806:	e65ff0ef          	jal	ra,8000566a <fdalloc>
    8000580a:	84aa                	mv	s1,a0
    return -1;
    8000580c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000580e:	00054763          	bltz	a0,8000581c <sys_dup+0x36>
  filedup(f);
    80005812:	fd843503          	ld	a0,-40(s0)
    80005816:	c54ff0ef          	jal	ra,80004c6a <filedup>
  return fd;
    8000581a:	87a6                	mv	a5,s1
}
    8000581c:	853e                	mv	a0,a5
    8000581e:	70a2                	ld	ra,40(sp)
    80005820:	7402                	ld	s0,32(sp)
    80005822:	64e2                	ld	s1,24(sp)
    80005824:	6145                	addi	sp,sp,48
    80005826:	8082                	ret

0000000080005828 <sys_read>:
{
    80005828:	7179                	addi	sp,sp,-48
    8000582a:	f406                	sd	ra,40(sp)
    8000582c:	f022                	sd	s0,32(sp)
    8000582e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005830:	fd840593          	addi	a1,s0,-40
    80005834:	4505                	li	a0,1
    80005836:	dc4fd0ef          	jal	ra,80002dfa <argaddr>
  argint(2, &n);
    8000583a:	fe440593          	addi	a1,s0,-28
    8000583e:	4509                	li	a0,2
    80005840:	d9efd0ef          	jal	ra,80002dde <argint>
  if(argfd(0, 0, &f) < 0)
    80005844:	fe840613          	addi	a2,s0,-24
    80005848:	4581                	li	a1,0
    8000584a:	4501                	li	a0,0
    8000584c:	dc7ff0ef          	jal	ra,80005612 <argfd>
    80005850:	87aa                	mv	a5,a0
    return -1;
    80005852:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005854:	0007ca63          	bltz	a5,80005868 <sys_read+0x40>
  return fileread(f, p, n);
    80005858:	fe442603          	lw	a2,-28(s0)
    8000585c:	fd843583          	ld	a1,-40(s0)
    80005860:	fe843503          	ld	a0,-24(s0)
    80005864:	d52ff0ef          	jal	ra,80004db6 <fileread>
}
    80005868:	70a2                	ld	ra,40(sp)
    8000586a:	7402                	ld	s0,32(sp)
    8000586c:	6145                	addi	sp,sp,48
    8000586e:	8082                	ret

0000000080005870 <sys_write>:
{
    80005870:	7179                	addi	sp,sp,-48
    80005872:	f406                	sd	ra,40(sp)
    80005874:	f022                	sd	s0,32(sp)
    80005876:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005878:	fd840593          	addi	a1,s0,-40
    8000587c:	4505                	li	a0,1
    8000587e:	d7cfd0ef          	jal	ra,80002dfa <argaddr>
  argint(2, &n);
    80005882:	fe440593          	addi	a1,s0,-28
    80005886:	4509                	li	a0,2
    80005888:	d56fd0ef          	jal	ra,80002dde <argint>
  if(argfd(0, 0, &f) < 0)
    8000588c:	fe840613          	addi	a2,s0,-24
    80005890:	4581                	li	a1,0
    80005892:	4501                	li	a0,0
    80005894:	d7fff0ef          	jal	ra,80005612 <argfd>
    80005898:	87aa                	mv	a5,a0
    return -1;
    8000589a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000589c:	0007ca63          	bltz	a5,800058b0 <sys_write+0x40>
  return filewrite(f, p, n);
    800058a0:	fe442603          	lw	a2,-28(s0)
    800058a4:	fd843583          	ld	a1,-40(s0)
    800058a8:	fe843503          	ld	a0,-24(s0)
    800058ac:	db8ff0ef          	jal	ra,80004e64 <filewrite>
}
    800058b0:	70a2                	ld	ra,40(sp)
    800058b2:	7402                	ld	s0,32(sp)
    800058b4:	6145                	addi	sp,sp,48
    800058b6:	8082                	ret

00000000800058b8 <sys_close>:
{
    800058b8:	1101                	addi	sp,sp,-32
    800058ba:	ec06                	sd	ra,24(sp)
    800058bc:	e822                	sd	s0,16(sp)
    800058be:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058c0:	fe040613          	addi	a2,s0,-32
    800058c4:	fec40593          	addi	a1,s0,-20
    800058c8:	4501                	li	a0,0
    800058ca:	d49ff0ef          	jal	ra,80005612 <argfd>
    return -1;
    800058ce:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058d0:	02054063          	bltz	a0,800058f0 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800058d4:	adcfc0ef          	jal	ra,80001bb0 <myproc>
    800058d8:	fec42783          	lw	a5,-20(s0)
    800058dc:	07e9                	addi	a5,a5,26
    800058de:	078e                	slli	a5,a5,0x3
    800058e0:	97aa                	add	a5,a5,a0
    800058e2:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800058e6:	fe043503          	ld	a0,-32(s0)
    800058ea:	bc6ff0ef          	jal	ra,80004cb0 <fileclose>
  return 0;
    800058ee:	4781                	li	a5,0
}
    800058f0:	853e                	mv	a0,a5
    800058f2:	60e2                	ld	ra,24(sp)
    800058f4:	6442                	ld	s0,16(sp)
    800058f6:	6105                	addi	sp,sp,32
    800058f8:	8082                	ret

00000000800058fa <sys_fstat>:
{
    800058fa:	1101                	addi	sp,sp,-32
    800058fc:	ec06                	sd	ra,24(sp)
    800058fe:	e822                	sd	s0,16(sp)
    80005900:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005902:	fe040593          	addi	a1,s0,-32
    80005906:	4505                	li	a0,1
    80005908:	cf2fd0ef          	jal	ra,80002dfa <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000590c:	fe840613          	addi	a2,s0,-24
    80005910:	4581                	li	a1,0
    80005912:	4501                	li	a0,0
    80005914:	cffff0ef          	jal	ra,80005612 <argfd>
    80005918:	87aa                	mv	a5,a0
    return -1;
    8000591a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000591c:	0007c863          	bltz	a5,8000592c <sys_fstat+0x32>
  return filestat(f, st);
    80005920:	fe043583          	ld	a1,-32(s0)
    80005924:	fe843503          	ld	a0,-24(s0)
    80005928:	c30ff0ef          	jal	ra,80004d58 <filestat>
}
    8000592c:	60e2                	ld	ra,24(sp)
    8000592e:	6442                	ld	s0,16(sp)
    80005930:	6105                	addi	sp,sp,32
    80005932:	8082                	ret

0000000080005934 <sys_link>:
{
    80005934:	7169                	addi	sp,sp,-304
    80005936:	f606                	sd	ra,296(sp)
    80005938:	f222                	sd	s0,288(sp)
    8000593a:	ee26                	sd	s1,280(sp)
    8000593c:	ea4a                	sd	s2,272(sp)
    8000593e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005940:	08000613          	li	a2,128
    80005944:	ed040593          	addi	a1,s0,-304
    80005948:	4501                	li	a0,0
    8000594a:	cccfd0ef          	jal	ra,80002e16 <argstr>
    return -1;
    8000594e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005950:	0c054663          	bltz	a0,80005a1c <sys_link+0xe8>
    80005954:	08000613          	li	a2,128
    80005958:	f5040593          	addi	a1,s0,-176
    8000595c:	4505                	li	a0,1
    8000595e:	cb8fd0ef          	jal	ra,80002e16 <argstr>
    return -1;
    80005962:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005964:	0a054c63          	bltz	a0,80005a1c <sys_link+0xe8>
  begin_op();
    80005968:	f3bfe0ef          	jal	ra,800048a2 <begin_op>
  if((ip = namei(old)) == 0){
    8000596c:	ed040513          	addi	a0,s0,-304
    80005970:	d43fe0ef          	jal	ra,800046b2 <namei>
    80005974:	84aa                	mv	s1,a0
    80005976:	c525                	beqz	a0,800059de <sys_link+0xaa>
  ilock(ip);
    80005978:	d4cfe0ef          	jal	ra,80003ec4 <ilock>
  if(ip->type == T_DIR){
    8000597c:	04449703          	lh	a4,68(s1)
    80005980:	4785                	li	a5,1
    80005982:	06f70263          	beq	a4,a5,800059e6 <sys_link+0xb2>
  ip->nlink++;
    80005986:	04a4d783          	lhu	a5,74(s1)
    8000598a:	2785                	addiw	a5,a5,1
    8000598c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005990:	8526                	mv	a0,s1
    80005992:	c80fe0ef          	jal	ra,80003e12 <iupdate>
  iunlock(ip);
    80005996:	8526                	mv	a0,s1
    80005998:	dd6fe0ef          	jal	ra,80003f6e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000599c:	fd040593          	addi	a1,s0,-48
    800059a0:	f5040513          	addi	a0,s0,-176
    800059a4:	d29fe0ef          	jal	ra,800046cc <nameiparent>
    800059a8:	892a                	mv	s2,a0
    800059aa:	c921                	beqz	a0,800059fa <sys_link+0xc6>
  ilock(dp);
    800059ac:	d18fe0ef          	jal	ra,80003ec4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059b0:	00092703          	lw	a4,0(s2)
    800059b4:	409c                	lw	a5,0(s1)
    800059b6:	02f71f63          	bne	a4,a5,800059f4 <sys_link+0xc0>
    800059ba:	40d0                	lw	a2,4(s1)
    800059bc:	fd040593          	addi	a1,s0,-48
    800059c0:	854a                	mv	a0,s2
    800059c2:	c57fe0ef          	jal	ra,80004618 <dirlink>
    800059c6:	02054763          	bltz	a0,800059f4 <sys_link+0xc0>
  iunlockput(dp);
    800059ca:	854a                	mv	a0,s2
    800059cc:	efefe0ef          	jal	ra,800040ca <iunlockput>
  iput(ip);
    800059d0:	8526                	mv	a0,s1
    800059d2:	e70fe0ef          	jal	ra,80004042 <iput>
  end_op();
    800059d6:	f3dfe0ef          	jal	ra,80004912 <end_op>
  return 0;
    800059da:	4781                	li	a5,0
    800059dc:	a081                	j	80005a1c <sys_link+0xe8>
    end_op();
    800059de:	f35fe0ef          	jal	ra,80004912 <end_op>
    return -1;
    800059e2:	57fd                	li	a5,-1
    800059e4:	a825                	j	80005a1c <sys_link+0xe8>
    iunlockput(ip);
    800059e6:	8526                	mv	a0,s1
    800059e8:	ee2fe0ef          	jal	ra,800040ca <iunlockput>
    end_op();
    800059ec:	f27fe0ef          	jal	ra,80004912 <end_op>
    return -1;
    800059f0:	57fd                	li	a5,-1
    800059f2:	a02d                	j	80005a1c <sys_link+0xe8>
    iunlockput(dp);
    800059f4:	854a                	mv	a0,s2
    800059f6:	ed4fe0ef          	jal	ra,800040ca <iunlockput>
  ilock(ip);
    800059fa:	8526                	mv	a0,s1
    800059fc:	cc8fe0ef          	jal	ra,80003ec4 <ilock>
  ip->nlink--;
    80005a00:	04a4d783          	lhu	a5,74(s1)
    80005a04:	37fd                	addiw	a5,a5,-1
    80005a06:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	c06fe0ef          	jal	ra,80003e12 <iupdate>
  iunlockput(ip);
    80005a10:	8526                	mv	a0,s1
    80005a12:	eb8fe0ef          	jal	ra,800040ca <iunlockput>
  end_op();
    80005a16:	efdfe0ef          	jal	ra,80004912 <end_op>
  return -1;
    80005a1a:	57fd                	li	a5,-1
}
    80005a1c:	853e                	mv	a0,a5
    80005a1e:	70b2                	ld	ra,296(sp)
    80005a20:	7412                	ld	s0,288(sp)
    80005a22:	64f2                	ld	s1,280(sp)
    80005a24:	6952                	ld	s2,272(sp)
    80005a26:	6155                	addi	sp,sp,304
    80005a28:	8082                	ret

0000000080005a2a <sys_unlink>:
{
    80005a2a:	7151                	addi	sp,sp,-240
    80005a2c:	f586                	sd	ra,232(sp)
    80005a2e:	f1a2                	sd	s0,224(sp)
    80005a30:	eda6                	sd	s1,216(sp)
    80005a32:	e9ca                	sd	s2,208(sp)
    80005a34:	e5ce                	sd	s3,200(sp)
    80005a36:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a38:	08000613          	li	a2,128
    80005a3c:	f3040593          	addi	a1,s0,-208
    80005a40:	4501                	li	a0,0
    80005a42:	bd4fd0ef          	jal	ra,80002e16 <argstr>
    80005a46:	12054b63          	bltz	a0,80005b7c <sys_unlink+0x152>
  begin_op();
    80005a4a:	e59fe0ef          	jal	ra,800048a2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a4e:	fb040593          	addi	a1,s0,-80
    80005a52:	f3040513          	addi	a0,s0,-208
    80005a56:	c77fe0ef          	jal	ra,800046cc <nameiparent>
    80005a5a:	84aa                	mv	s1,a0
    80005a5c:	c54d                	beqz	a0,80005b06 <sys_unlink+0xdc>
  ilock(dp);
    80005a5e:	c66fe0ef          	jal	ra,80003ec4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a62:	00003597          	auipc	a1,0x3
    80005a66:	cb658593          	addi	a1,a1,-842 # 80008718 <syscalls+0x320>
    80005a6a:	fb040513          	addi	a0,s0,-80
    80005a6e:	9c9fe0ef          	jal	ra,80004436 <namecmp>
    80005a72:	10050a63          	beqz	a0,80005b86 <sys_unlink+0x15c>
    80005a76:	00003597          	auipc	a1,0x3
    80005a7a:	caa58593          	addi	a1,a1,-854 # 80008720 <syscalls+0x328>
    80005a7e:	fb040513          	addi	a0,s0,-80
    80005a82:	9b5fe0ef          	jal	ra,80004436 <namecmp>
    80005a86:	10050063          	beqz	a0,80005b86 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a8a:	f2c40613          	addi	a2,s0,-212
    80005a8e:	fb040593          	addi	a1,s0,-80
    80005a92:	8526                	mv	a0,s1
    80005a94:	9b9fe0ef          	jal	ra,8000444c <dirlookup>
    80005a98:	892a                	mv	s2,a0
    80005a9a:	0e050663          	beqz	a0,80005b86 <sys_unlink+0x15c>
  ilock(ip);
    80005a9e:	c26fe0ef          	jal	ra,80003ec4 <ilock>
  if(ip->nlink < 1)
    80005aa2:	04a91783          	lh	a5,74(s2)
    80005aa6:	06f05463          	blez	a5,80005b0e <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005aaa:	04491703          	lh	a4,68(s2)
    80005aae:	4785                	li	a5,1
    80005ab0:	06f70563          	beq	a4,a5,80005b1a <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80005ab4:	4641                	li	a2,16
    80005ab6:	4581                	li	a1,0
    80005ab8:	fc040513          	addi	a0,s0,-64
    80005abc:	ac8fb0ef          	jal	ra,80000d84 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ac0:	4741                	li	a4,16
    80005ac2:	f2c42683          	lw	a3,-212(s0)
    80005ac6:	fc040613          	addi	a2,s0,-64
    80005aca:	4581                	li	a1,0
    80005acc:	8526                	mv	a0,s1
    80005ace:	867fe0ef          	jal	ra,80004334 <writei>
    80005ad2:	47c1                	li	a5,16
    80005ad4:	08f51563          	bne	a0,a5,80005b5e <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80005ad8:	04491703          	lh	a4,68(s2)
    80005adc:	4785                	li	a5,1
    80005ade:	08f70663          	beq	a4,a5,80005b6a <sys_unlink+0x140>
  iunlockput(dp);
    80005ae2:	8526                	mv	a0,s1
    80005ae4:	de6fe0ef          	jal	ra,800040ca <iunlockput>
  ip->nlink--;
    80005ae8:	04a95783          	lhu	a5,74(s2)
    80005aec:	37fd                	addiw	a5,a5,-1
    80005aee:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005af2:	854a                	mv	a0,s2
    80005af4:	b1efe0ef          	jal	ra,80003e12 <iupdate>
  iunlockput(ip);
    80005af8:	854a                	mv	a0,s2
    80005afa:	dd0fe0ef          	jal	ra,800040ca <iunlockput>
  end_op();
    80005afe:	e15fe0ef          	jal	ra,80004912 <end_op>
  return 0;
    80005b02:	4501                	li	a0,0
    80005b04:	a079                	j	80005b92 <sys_unlink+0x168>
    end_op();
    80005b06:	e0dfe0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005b0a:	557d                	li	a0,-1
    80005b0c:	a059                	j	80005b92 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005b0e:	00003517          	auipc	a0,0x3
    80005b12:	c1a50513          	addi	a0,a0,-998 # 80008728 <syscalls+0x330>
    80005b16:	c75fa0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b1a:	04c92703          	lw	a4,76(s2)
    80005b1e:	02000793          	li	a5,32
    80005b22:	f8e7f9e3          	bgeu	a5,a4,80005ab4 <sys_unlink+0x8a>
    80005b26:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b2a:	4741                	li	a4,16
    80005b2c:	86ce                	mv	a3,s3
    80005b2e:	f1840613          	addi	a2,s0,-232
    80005b32:	4581                	li	a1,0
    80005b34:	854a                	mv	a0,s2
    80005b36:	f1afe0ef          	jal	ra,80004250 <readi>
    80005b3a:	47c1                	li	a5,16
    80005b3c:	00f51b63          	bne	a0,a5,80005b52 <sys_unlink+0x128>
    if(de.inum != 0)
    80005b40:	f1845783          	lhu	a5,-232(s0)
    80005b44:	ef95                	bnez	a5,80005b80 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b46:	29c1                	addiw	s3,s3,16
    80005b48:	04c92783          	lw	a5,76(s2)
    80005b4c:	fcf9efe3          	bltu	s3,a5,80005b2a <sys_unlink+0x100>
    80005b50:	b795                	j	80005ab4 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005b52:	00003517          	auipc	a0,0x3
    80005b56:	bee50513          	addi	a0,a0,-1042 # 80008740 <syscalls+0x348>
    80005b5a:	c31fa0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80005b5e:	00003517          	auipc	a0,0x3
    80005b62:	bfa50513          	addi	a0,a0,-1030 # 80008758 <syscalls+0x360>
    80005b66:	c25fa0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80005b6a:	04a4d783          	lhu	a5,74(s1)
    80005b6e:	37fd                	addiw	a5,a5,-1
    80005b70:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b74:	8526                	mv	a0,s1
    80005b76:	a9cfe0ef          	jal	ra,80003e12 <iupdate>
    80005b7a:	b7a5                	j	80005ae2 <sys_unlink+0xb8>
    return -1;
    80005b7c:	557d                	li	a0,-1
    80005b7e:	a811                	j	80005b92 <sys_unlink+0x168>
    iunlockput(ip);
    80005b80:	854a                	mv	a0,s2
    80005b82:	d48fe0ef          	jal	ra,800040ca <iunlockput>
  iunlockput(dp);
    80005b86:	8526                	mv	a0,s1
    80005b88:	d42fe0ef          	jal	ra,800040ca <iunlockput>
  end_op();
    80005b8c:	d87fe0ef          	jal	ra,80004912 <end_op>
  return -1;
    80005b90:	557d                	li	a0,-1
}
    80005b92:	70ae                	ld	ra,232(sp)
    80005b94:	740e                	ld	s0,224(sp)
    80005b96:	64ee                	ld	s1,216(sp)
    80005b98:	694e                	ld	s2,208(sp)
    80005b9a:	69ae                	ld	s3,200(sp)
    80005b9c:	616d                	addi	sp,sp,240
    80005b9e:	8082                	ret

0000000080005ba0 <sys_open>:

uint64
sys_open(void)
{
    80005ba0:	7131                	addi	sp,sp,-192
    80005ba2:	fd06                	sd	ra,184(sp)
    80005ba4:	f922                	sd	s0,176(sp)
    80005ba6:	f526                	sd	s1,168(sp)
    80005ba8:	f14a                	sd	s2,160(sp)
    80005baa:	ed4e                	sd	s3,152(sp)
    80005bac:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bae:	f4c40593          	addi	a1,s0,-180
    80005bb2:	4505                	li	a0,1
    80005bb4:	a2afd0ef          	jal	ra,80002dde <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bb8:	08000613          	li	a2,128
    80005bbc:	f5040593          	addi	a1,s0,-176
    80005bc0:	4501                	li	a0,0
    80005bc2:	a54fd0ef          	jal	ra,80002e16 <argstr>
    80005bc6:	87aa                	mv	a5,a0
    return -1;
    80005bc8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bca:	0807cd63          	bltz	a5,80005c64 <sys_open+0xc4>

  begin_op();
    80005bce:	cd5fe0ef          	jal	ra,800048a2 <begin_op>

  if(omode & O_CREATE){
    80005bd2:	f4c42783          	lw	a5,-180(s0)
    80005bd6:	2007f793          	andi	a5,a5,512
    80005bda:	c3c5                	beqz	a5,80005c7a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005bdc:	4681                	li	a3,0
    80005bde:	4601                	li	a2,0
    80005be0:	4589                	li	a1,2
    80005be2:	f5040513          	addi	a0,s0,-176
    80005be6:	ac3ff0ef          	jal	ra,800056a8 <create>
    80005bea:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bec:	c159                	beqz	a0,80005c72 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bee:	04449703          	lh	a4,68(s1)
    80005bf2:	478d                	li	a5,3
    80005bf4:	00f71763          	bne	a4,a5,80005c02 <sys_open+0x62>
    80005bf8:	0464d703          	lhu	a4,70(s1)
    80005bfc:	47a5                	li	a5,9
    80005bfe:	0ae7e963          	bltu	a5,a4,80005cb0 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c02:	80aff0ef          	jal	ra,80004c0c <filealloc>
    80005c06:	89aa                	mv	s3,a0
    80005c08:	0c050963          	beqz	a0,80005cda <sys_open+0x13a>
    80005c0c:	a5fff0ef          	jal	ra,8000566a <fdalloc>
    80005c10:	892a                	mv	s2,a0
    80005c12:	0c054163          	bltz	a0,80005cd4 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c16:	04449703          	lh	a4,68(s1)
    80005c1a:	478d                	li	a5,3
    80005c1c:	0af70163          	beq	a4,a5,80005cbe <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c20:	4789                	li	a5,2
    80005c22:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c26:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c2a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c2e:	f4c42783          	lw	a5,-180(s0)
    80005c32:	0017c713          	xori	a4,a5,1
    80005c36:	8b05                	andi	a4,a4,1
    80005c38:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c3c:	0037f713          	andi	a4,a5,3
    80005c40:	00e03733          	snez	a4,a4
    80005c44:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c48:	4007f793          	andi	a5,a5,1024
    80005c4c:	c791                	beqz	a5,80005c58 <sys_open+0xb8>
    80005c4e:	04449703          	lh	a4,68(s1)
    80005c52:	4789                	li	a5,2
    80005c54:	06f70c63          	beq	a4,a5,80005ccc <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c58:	8526                	mv	a0,s1
    80005c5a:	b14fe0ef          	jal	ra,80003f6e <iunlock>
  end_op();
    80005c5e:	cb5fe0ef          	jal	ra,80004912 <end_op>

  return fd;
    80005c62:	854a                	mv	a0,s2
}
    80005c64:	70ea                	ld	ra,184(sp)
    80005c66:	744a                	ld	s0,176(sp)
    80005c68:	74aa                	ld	s1,168(sp)
    80005c6a:	790a                	ld	s2,160(sp)
    80005c6c:	69ea                	ld	s3,152(sp)
    80005c6e:	6129                	addi	sp,sp,192
    80005c70:	8082                	ret
      end_op();
    80005c72:	ca1fe0ef          	jal	ra,80004912 <end_op>
      return -1;
    80005c76:	557d                	li	a0,-1
    80005c78:	b7f5                	j	80005c64 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005c7a:	f5040513          	addi	a0,s0,-176
    80005c7e:	a35fe0ef          	jal	ra,800046b2 <namei>
    80005c82:	84aa                	mv	s1,a0
    80005c84:	c115                	beqz	a0,80005ca8 <sys_open+0x108>
    ilock(ip);
    80005c86:	a3efe0ef          	jal	ra,80003ec4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c8a:	04449703          	lh	a4,68(s1)
    80005c8e:	4785                	li	a5,1
    80005c90:	f4f71fe3          	bne	a4,a5,80005bee <sys_open+0x4e>
    80005c94:	f4c42783          	lw	a5,-180(s0)
    80005c98:	d7ad                	beqz	a5,80005c02 <sys_open+0x62>
      iunlockput(ip);
    80005c9a:	8526                	mv	a0,s1
    80005c9c:	c2efe0ef          	jal	ra,800040ca <iunlockput>
      end_op();
    80005ca0:	c73fe0ef          	jal	ra,80004912 <end_op>
      return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	bf7d                	j	80005c64 <sys_open+0xc4>
      end_op();
    80005ca8:	c6bfe0ef          	jal	ra,80004912 <end_op>
      return -1;
    80005cac:	557d                	li	a0,-1
    80005cae:	bf5d                	j	80005c64 <sys_open+0xc4>
    iunlockput(ip);
    80005cb0:	8526                	mv	a0,s1
    80005cb2:	c18fe0ef          	jal	ra,800040ca <iunlockput>
    end_op();
    80005cb6:	c5dfe0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005cba:	557d                	li	a0,-1
    80005cbc:	b765                	j	80005c64 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005cbe:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cc2:	04649783          	lh	a5,70(s1)
    80005cc6:	02f99223          	sh	a5,36(s3)
    80005cca:	b785                	j	80005c2a <sys_open+0x8a>
    itrunc(ip);
    80005ccc:	8526                	mv	a0,s1
    80005cce:	ae0fe0ef          	jal	ra,80003fae <itrunc>
    80005cd2:	b759                	j	80005c58 <sys_open+0xb8>
      fileclose(f);
    80005cd4:	854e                	mv	a0,s3
    80005cd6:	fdbfe0ef          	jal	ra,80004cb0 <fileclose>
    iunlockput(ip);
    80005cda:	8526                	mv	a0,s1
    80005cdc:	beefe0ef          	jal	ra,800040ca <iunlockput>
    end_op();
    80005ce0:	c33fe0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005ce4:	557d                	li	a0,-1
    80005ce6:	bfbd                	j	80005c64 <sys_open+0xc4>

0000000080005ce8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ce8:	7175                	addi	sp,sp,-144
    80005cea:	e506                	sd	ra,136(sp)
    80005cec:	e122                	sd	s0,128(sp)
    80005cee:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cf0:	bb3fe0ef          	jal	ra,800048a2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005cf4:	08000613          	li	a2,128
    80005cf8:	f7040593          	addi	a1,s0,-144
    80005cfc:	4501                	li	a0,0
    80005cfe:	918fd0ef          	jal	ra,80002e16 <argstr>
    80005d02:	02054363          	bltz	a0,80005d28 <sys_mkdir+0x40>
    80005d06:	4681                	li	a3,0
    80005d08:	4601                	li	a2,0
    80005d0a:	4585                	li	a1,1
    80005d0c:	f7040513          	addi	a0,s0,-144
    80005d10:	999ff0ef          	jal	ra,800056a8 <create>
    80005d14:	c911                	beqz	a0,80005d28 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d16:	bb4fe0ef          	jal	ra,800040ca <iunlockput>
  end_op();
    80005d1a:	bf9fe0ef          	jal	ra,80004912 <end_op>
  return 0;
    80005d1e:	4501                	li	a0,0
}
    80005d20:	60aa                	ld	ra,136(sp)
    80005d22:	640a                	ld	s0,128(sp)
    80005d24:	6149                	addi	sp,sp,144
    80005d26:	8082                	ret
    end_op();
    80005d28:	bebfe0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005d2c:	557d                	li	a0,-1
    80005d2e:	bfcd                	j	80005d20 <sys_mkdir+0x38>

0000000080005d30 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d30:	7135                	addi	sp,sp,-160
    80005d32:	ed06                	sd	ra,152(sp)
    80005d34:	e922                	sd	s0,144(sp)
    80005d36:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d38:	b6bfe0ef          	jal	ra,800048a2 <begin_op>
  argint(1, &major);
    80005d3c:	f6c40593          	addi	a1,s0,-148
    80005d40:	4505                	li	a0,1
    80005d42:	89cfd0ef          	jal	ra,80002dde <argint>
  argint(2, &minor);
    80005d46:	f6840593          	addi	a1,s0,-152
    80005d4a:	4509                	li	a0,2
    80005d4c:	892fd0ef          	jal	ra,80002dde <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d50:	08000613          	li	a2,128
    80005d54:	f7040593          	addi	a1,s0,-144
    80005d58:	4501                	li	a0,0
    80005d5a:	8bcfd0ef          	jal	ra,80002e16 <argstr>
    80005d5e:	02054563          	bltz	a0,80005d88 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d62:	f6841683          	lh	a3,-152(s0)
    80005d66:	f6c41603          	lh	a2,-148(s0)
    80005d6a:	458d                	li	a1,3
    80005d6c:	f7040513          	addi	a0,s0,-144
    80005d70:	939ff0ef          	jal	ra,800056a8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d74:	c911                	beqz	a0,80005d88 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d76:	b54fe0ef          	jal	ra,800040ca <iunlockput>
  end_op();
    80005d7a:	b99fe0ef          	jal	ra,80004912 <end_op>
  return 0;
    80005d7e:	4501                	li	a0,0
}
    80005d80:	60ea                	ld	ra,152(sp)
    80005d82:	644a                	ld	s0,144(sp)
    80005d84:	610d                	addi	sp,sp,160
    80005d86:	8082                	ret
    end_op();
    80005d88:	b8bfe0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005d8c:	557d                	li	a0,-1
    80005d8e:	bfcd                	j	80005d80 <sys_mknod+0x50>

0000000080005d90 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d90:	7135                	addi	sp,sp,-160
    80005d92:	ed06                	sd	ra,152(sp)
    80005d94:	e922                	sd	s0,144(sp)
    80005d96:	e526                	sd	s1,136(sp)
    80005d98:	e14a                	sd	s2,128(sp)
    80005d9a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d9c:	e15fb0ef          	jal	ra,80001bb0 <myproc>
    80005da0:	892a                	mv	s2,a0
  
  begin_op();
    80005da2:	b01fe0ef          	jal	ra,800048a2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005da6:	08000613          	li	a2,128
    80005daa:	f6040593          	addi	a1,s0,-160
    80005dae:	4501                	li	a0,0
    80005db0:	866fd0ef          	jal	ra,80002e16 <argstr>
    80005db4:	04054163          	bltz	a0,80005df6 <sys_chdir+0x66>
    80005db8:	f6040513          	addi	a0,s0,-160
    80005dbc:	8f7fe0ef          	jal	ra,800046b2 <namei>
    80005dc0:	84aa                	mv	s1,a0
    80005dc2:	c915                	beqz	a0,80005df6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005dc4:	900fe0ef          	jal	ra,80003ec4 <ilock>
  if(ip->type != T_DIR){
    80005dc8:	04449703          	lh	a4,68(s1)
    80005dcc:	4785                	li	a5,1
    80005dce:	02f71863          	bne	a4,a5,80005dfe <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005dd2:	8526                	mv	a0,s1
    80005dd4:	99afe0ef          	jal	ra,80003f6e <iunlock>
  iput(p->cwd);
    80005dd8:	15093503          	ld	a0,336(s2)
    80005ddc:	a66fe0ef          	jal	ra,80004042 <iput>
  end_op();
    80005de0:	b33fe0ef          	jal	ra,80004912 <end_op>
  p->cwd = ip;
    80005de4:	14993823          	sd	s1,336(s2)
  return 0;
    80005de8:	4501                	li	a0,0
}
    80005dea:	60ea                	ld	ra,152(sp)
    80005dec:	644a                	ld	s0,144(sp)
    80005dee:	64aa                	ld	s1,136(sp)
    80005df0:	690a                	ld	s2,128(sp)
    80005df2:	610d                	addi	sp,sp,160
    80005df4:	8082                	ret
    end_op();
    80005df6:	b1dfe0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005dfa:	557d                	li	a0,-1
    80005dfc:	b7fd                	j	80005dea <sys_chdir+0x5a>
    iunlockput(ip);
    80005dfe:	8526                	mv	a0,s1
    80005e00:	acafe0ef          	jal	ra,800040ca <iunlockput>
    end_op();
    80005e04:	b0ffe0ef          	jal	ra,80004912 <end_op>
    return -1;
    80005e08:	557d                	li	a0,-1
    80005e0a:	b7c5                	j	80005dea <sys_chdir+0x5a>

0000000080005e0c <sys_exec>:

uint64
sys_exec(void)
{
    80005e0c:	7145                	addi	sp,sp,-464
    80005e0e:	e786                	sd	ra,456(sp)
    80005e10:	e3a2                	sd	s0,448(sp)
    80005e12:	ff26                	sd	s1,440(sp)
    80005e14:	fb4a                	sd	s2,432(sp)
    80005e16:	f74e                	sd	s3,424(sp)
    80005e18:	f352                	sd	s4,416(sp)
    80005e1a:	ef56                	sd	s5,408(sp)
    80005e1c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e1e:	e3840593          	addi	a1,s0,-456
    80005e22:	4505                	li	a0,1
    80005e24:	fd7fc0ef          	jal	ra,80002dfa <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e28:	08000613          	li	a2,128
    80005e2c:	f4040593          	addi	a1,s0,-192
    80005e30:	4501                	li	a0,0
    80005e32:	fe5fc0ef          	jal	ra,80002e16 <argstr>
    80005e36:	87aa                	mv	a5,a0
    return -1;
    80005e38:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e3a:	0a07c463          	bltz	a5,80005ee2 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005e3e:	10000613          	li	a2,256
    80005e42:	4581                	li	a1,0
    80005e44:	e4040513          	addi	a0,s0,-448
    80005e48:	f3dfa0ef          	jal	ra,80000d84 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e4c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e50:	89a6                	mv	s3,s1
    80005e52:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e54:	02000a13          	li	s4,32
    80005e58:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e5c:	00391793          	slli	a5,s2,0x3
    80005e60:	e3040593          	addi	a1,s0,-464
    80005e64:	e3843503          	ld	a0,-456(s0)
    80005e68:	953e                	add	a0,a0,a5
    80005e6a:	eebfc0ef          	jal	ra,80002d54 <fetchaddr>
    80005e6e:	02054663          	bltz	a0,80005e9a <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005e72:	e3043783          	ld	a5,-464(s0)
    80005e76:	cf8d                	beqz	a5,80005eb0 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e78:	d35fa0ef          	jal	ra,80000bac <kalloc>
    80005e7c:	85aa                	mv	a1,a0
    80005e7e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e82:	cd01                	beqz	a0,80005e9a <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e84:	6605                	lui	a2,0x1
    80005e86:	e3043503          	ld	a0,-464(s0)
    80005e8a:	f15fc0ef          	jal	ra,80002d9e <fetchstr>
    80005e8e:	00054663          	bltz	a0,80005e9a <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005e92:	0905                	addi	s2,s2,1
    80005e94:	09a1                	addi	s3,s3,8
    80005e96:	fd4911e3          	bne	s2,s4,80005e58 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e9a:	10048913          	addi	s2,s1,256
    80005e9e:	6088                	ld	a0,0(s1)
    80005ea0:	c121                	beqz	a0,80005ee0 <sys_exec+0xd4>
    kfree(argv[i]);
    80005ea2:	bddfa0ef          	jal	ra,80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ea6:	04a1                	addi	s1,s1,8
    80005ea8:	ff249be3          	bne	s1,s2,80005e9e <sys_exec+0x92>
  return -1;
    80005eac:	557d                	li	a0,-1
    80005eae:	a815                	j	80005ee2 <sys_exec+0xd6>
      argv[i] = 0;
    80005eb0:	0a8e                	slli	s5,s5,0x3
    80005eb2:	fc040793          	addi	a5,s0,-64
    80005eb6:	9abe                	add	s5,s5,a5
    80005eb8:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005ebc:	e4040593          	addi	a1,s0,-448
    80005ec0:	f4040513          	addi	a0,s0,-192
    80005ec4:	b98ff0ef          	jal	ra,8000525c <kexec>
    80005ec8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eca:	10048993          	addi	s3,s1,256
    80005ece:	6088                	ld	a0,0(s1)
    80005ed0:	c511                	beqz	a0,80005edc <sys_exec+0xd0>
    kfree(argv[i]);
    80005ed2:	badfa0ef          	jal	ra,80000a7e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ed6:	04a1                	addi	s1,s1,8
    80005ed8:	ff349be3          	bne	s1,s3,80005ece <sys_exec+0xc2>
  return ret;
    80005edc:	854a                	mv	a0,s2
    80005ede:	a011                	j	80005ee2 <sys_exec+0xd6>
  return -1;
    80005ee0:	557d                	li	a0,-1
}
    80005ee2:	60be                	ld	ra,456(sp)
    80005ee4:	641e                	ld	s0,448(sp)
    80005ee6:	74fa                	ld	s1,440(sp)
    80005ee8:	795a                	ld	s2,432(sp)
    80005eea:	79ba                	ld	s3,424(sp)
    80005eec:	7a1a                	ld	s4,416(sp)
    80005eee:	6afa                	ld	s5,408(sp)
    80005ef0:	6179                	addi	sp,sp,464
    80005ef2:	8082                	ret

0000000080005ef4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ef4:	7139                	addi	sp,sp,-64
    80005ef6:	fc06                	sd	ra,56(sp)
    80005ef8:	f822                	sd	s0,48(sp)
    80005efa:	f426                	sd	s1,40(sp)
    80005efc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005efe:	cb3fb0ef          	jal	ra,80001bb0 <myproc>
    80005f02:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f04:	fd840593          	addi	a1,s0,-40
    80005f08:	4501                	li	a0,0
    80005f0a:	ef1fc0ef          	jal	ra,80002dfa <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f0e:	fc840593          	addi	a1,s0,-56
    80005f12:	fd040513          	addi	a0,s0,-48
    80005f16:	866ff0ef          	jal	ra,80004f7c <pipealloc>
    return -1;
    80005f1a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f1c:	0a054463          	bltz	a0,80005fc4 <sys_pipe+0xd0>
  fd0 = -1;
    80005f20:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f24:	fd043503          	ld	a0,-48(s0)
    80005f28:	f42ff0ef          	jal	ra,8000566a <fdalloc>
    80005f2c:	fca42223          	sw	a0,-60(s0)
    80005f30:	08054163          	bltz	a0,80005fb2 <sys_pipe+0xbe>
    80005f34:	fc843503          	ld	a0,-56(s0)
    80005f38:	f32ff0ef          	jal	ra,8000566a <fdalloc>
    80005f3c:	fca42023          	sw	a0,-64(s0)
    80005f40:	06054063          	bltz	a0,80005fa0 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f44:	4691                	li	a3,4
    80005f46:	fc440613          	addi	a2,s0,-60
    80005f4a:	fd843583          	ld	a1,-40(s0)
    80005f4e:	68a8                	ld	a0,80(s1)
    80005f50:	851fb0ef          	jal	ra,800017a0 <copyout>
    80005f54:	00054e63          	bltz	a0,80005f70 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f58:	4691                	li	a3,4
    80005f5a:	fc040613          	addi	a2,s0,-64
    80005f5e:	fd843583          	ld	a1,-40(s0)
    80005f62:	0591                	addi	a1,a1,4
    80005f64:	68a8                	ld	a0,80(s1)
    80005f66:	83bfb0ef          	jal	ra,800017a0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f6a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f6c:	04055c63          	bgez	a0,80005fc4 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005f70:	fc442783          	lw	a5,-60(s0)
    80005f74:	07e9                	addi	a5,a5,26
    80005f76:	078e                	slli	a5,a5,0x3
    80005f78:	97a6                	add	a5,a5,s1
    80005f7a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f7e:	fc042503          	lw	a0,-64(s0)
    80005f82:	0569                	addi	a0,a0,26
    80005f84:	050e                	slli	a0,a0,0x3
    80005f86:	94aa                	add	s1,s1,a0
    80005f88:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f8c:	fd043503          	ld	a0,-48(s0)
    80005f90:	d21fe0ef          	jal	ra,80004cb0 <fileclose>
    fileclose(wf);
    80005f94:	fc843503          	ld	a0,-56(s0)
    80005f98:	d19fe0ef          	jal	ra,80004cb0 <fileclose>
    return -1;
    80005f9c:	57fd                	li	a5,-1
    80005f9e:	a01d                	j	80005fc4 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005fa0:	fc442783          	lw	a5,-60(s0)
    80005fa4:	0007c763          	bltz	a5,80005fb2 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005fa8:	07e9                	addi	a5,a5,26
    80005faa:	078e                	slli	a5,a5,0x3
    80005fac:	94be                	add	s1,s1,a5
    80005fae:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fb2:	fd043503          	ld	a0,-48(s0)
    80005fb6:	cfbfe0ef          	jal	ra,80004cb0 <fileclose>
    fileclose(wf);
    80005fba:	fc843503          	ld	a0,-56(s0)
    80005fbe:	cf3fe0ef          	jal	ra,80004cb0 <fileclose>
    return -1;
    80005fc2:	57fd                	li	a5,-1
}
    80005fc4:	853e                	mv	a0,a5
    80005fc6:	70e2                	ld	ra,56(sp)
    80005fc8:	7442                	ld	s0,48(sp)
    80005fca:	74a2                	ld	s1,40(sp)
    80005fcc:	6121                	addi	sp,sp,64
    80005fce:	8082                	ret

0000000080005fd0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005fd0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005fd2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005fd4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005fd6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005fd8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005fda:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005fdc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005fde:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005fe0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005fe2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005fe4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005fe6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005fe8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005fea:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005fec:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005fee:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005ff0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005ff2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005ff4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005ff6:	c6ffc0ef          	jal	ra,80002c64 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005ffa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005ffc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005ffe:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006000:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006002:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006004:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006006:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006008:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000600a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000600c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000600e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80006010:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80006012:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80006014:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80006016:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80006018:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000601a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000601c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000601e:	10200073          	sret
	...

000000008000602e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000602e:	1141                	addi	sp,sp,-16
    80006030:	e422                	sd	s0,8(sp)
    80006032:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006034:	0c0007b7          	lui	a5,0xc000
    80006038:	4705                	li	a4,1
    8000603a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000603c:	c3d8                	sw	a4,4(a5)
}
    8000603e:	6422                	ld	s0,8(sp)
    80006040:	0141                	addi	sp,sp,16
    80006042:	8082                	ret

0000000080006044 <plicinithart>:

void
plicinithart(void)
{
    80006044:	1141                	addi	sp,sp,-16
    80006046:	e406                	sd	ra,8(sp)
    80006048:	e022                	sd	s0,0(sp)
    8000604a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000604c:	b39fb0ef          	jal	ra,80001b84 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006050:	0085171b          	slliw	a4,a0,0x8
    80006054:	0c0027b7          	lui	a5,0xc002
    80006058:	97ba                	add	a5,a5,a4
    8000605a:	40200713          	li	a4,1026
    8000605e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006062:	00d5151b          	slliw	a0,a0,0xd
    80006066:	0c2017b7          	lui	a5,0xc201
    8000606a:	953e                	add	a0,a0,a5
    8000606c:	00052023          	sw	zero,0(a0)
}
    80006070:	60a2                	ld	ra,8(sp)
    80006072:	6402                	ld	s0,0(sp)
    80006074:	0141                	addi	sp,sp,16
    80006076:	8082                	ret

0000000080006078 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006078:	1141                	addi	sp,sp,-16
    8000607a:	e406                	sd	ra,8(sp)
    8000607c:	e022                	sd	s0,0(sp)
    8000607e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006080:	b05fb0ef          	jal	ra,80001b84 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006084:	00d5179b          	slliw	a5,a0,0xd
    80006088:	0c201537          	lui	a0,0xc201
    8000608c:	953e                	add	a0,a0,a5
  return irq;
}
    8000608e:	4148                	lw	a0,4(a0)
    80006090:	60a2                	ld	ra,8(sp)
    80006092:	6402                	ld	s0,0(sp)
    80006094:	0141                	addi	sp,sp,16
    80006096:	8082                	ret

0000000080006098 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006098:	1101                	addi	sp,sp,-32
    8000609a:	ec06                	sd	ra,24(sp)
    8000609c:	e822                	sd	s0,16(sp)
    8000609e:	e426                	sd	s1,8(sp)
    800060a0:	1000                	addi	s0,sp,32
    800060a2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060a4:	ae1fb0ef          	jal	ra,80001b84 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060a8:	00d5151b          	slliw	a0,a0,0xd
    800060ac:	0c2017b7          	lui	a5,0xc201
    800060b0:	97aa                	add	a5,a5,a0
    800060b2:	c3c4                	sw	s1,4(a5)
}
    800060b4:	60e2                	ld	ra,24(sp)
    800060b6:	6442                	ld	s0,16(sp)
    800060b8:	64a2                	ld	s1,8(sp)
    800060ba:	6105                	addi	sp,sp,32
    800060bc:	8082                	ret

00000000800060be <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060be:	1141                	addi	sp,sp,-16
    800060c0:	e406                	sd	ra,8(sp)
    800060c2:	e022                	sd	s0,0(sp)
    800060c4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060c6:	479d                	li	a5,7
    800060c8:	04a7ca63          	blt	a5,a0,8000611c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800060cc:	00246797          	auipc	a5,0x246
    800060d0:	a1478793          	addi	a5,a5,-1516 # 8024bae0 <disk>
    800060d4:	97aa                	add	a5,a5,a0
    800060d6:	0187c783          	lbu	a5,24(a5)
    800060da:	e7b9                	bnez	a5,80006128 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060dc:	00451613          	slli	a2,a0,0x4
    800060e0:	00246797          	auipc	a5,0x246
    800060e4:	a0078793          	addi	a5,a5,-1536 # 8024bae0 <disk>
    800060e8:	6394                	ld	a3,0(a5)
    800060ea:	96b2                	add	a3,a3,a2
    800060ec:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800060f0:	6398                	ld	a4,0(a5)
    800060f2:	9732                	add	a4,a4,a2
    800060f4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800060f8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800060fc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006100:	953e                	add	a0,a0,a5
    80006102:	4785                	li	a5,1
    80006104:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006108:	00246517          	auipc	a0,0x246
    8000610c:	9f050513          	addi	a0,a0,-1552 # 8024baf8 <disk+0x18>
    80006110:	be4fc0ef          	jal	ra,800024f4 <wakeup>
}
    80006114:	60a2                	ld	ra,8(sp)
    80006116:	6402                	ld	s0,0(sp)
    80006118:	0141                	addi	sp,sp,16
    8000611a:	8082                	ret
    panic("free_desc 1");
    8000611c:	00002517          	auipc	a0,0x2
    80006120:	64c50513          	addi	a0,a0,1612 # 80008768 <syscalls+0x370>
    80006124:	e66fa0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80006128:	00002517          	auipc	a0,0x2
    8000612c:	65050513          	addi	a0,a0,1616 # 80008778 <syscalls+0x380>
    80006130:	e5afa0ef          	jal	ra,8000078a <panic>

0000000080006134 <virtio_disk_init>:
{
    80006134:	1101                	addi	sp,sp,-32
    80006136:	ec06                	sd	ra,24(sp)
    80006138:	e822                	sd	s0,16(sp)
    8000613a:	e426                	sd	s1,8(sp)
    8000613c:	e04a                	sd	s2,0(sp)
    8000613e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006140:	00002597          	auipc	a1,0x2
    80006144:	64858593          	addi	a1,a1,1608 # 80008788 <syscalls+0x390>
    80006148:	00246517          	auipc	a0,0x246
    8000614c:	ac050513          	addi	a0,a0,-1344 # 8024bc08 <disk+0x128>
    80006150:	ae1fa0ef          	jal	ra,80000c30 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006154:	100017b7          	lui	a5,0x10001
    80006158:	4398                	lw	a4,0(a5)
    8000615a:	2701                	sext.w	a4,a4
    8000615c:	747277b7          	lui	a5,0x74727
    80006160:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006164:	14f71063          	bne	a4,a5,800062a4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006168:	100017b7          	lui	a5,0x10001
    8000616c:	43dc                	lw	a5,4(a5)
    8000616e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006170:	4709                	li	a4,2
    80006172:	12e79963          	bne	a5,a4,800062a4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006176:	100017b7          	lui	a5,0x10001
    8000617a:	479c                	lw	a5,8(a5)
    8000617c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000617e:	12e79363          	bne	a5,a4,800062a4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006182:	100017b7          	lui	a5,0x10001
    80006186:	47d8                	lw	a4,12(a5)
    80006188:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000618a:	554d47b7          	lui	a5,0x554d4
    8000618e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006192:	10f71963          	bne	a4,a5,800062a4 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006196:	100017b7          	lui	a5,0x10001
    8000619a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000619e:	4705                	li	a4,1
    800061a0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061a2:	470d                	li	a4,3
    800061a4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061a6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061a8:	c7ffe737          	lui	a4,0xc7ffe
    800061ac:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47daa55f>
    800061b0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061b2:	2701                	sext.w	a4,a4
    800061b4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061b6:	472d                	li	a4,11
    800061b8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800061ba:	5bbc                	lw	a5,112(a5)
    800061bc:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061c0:	8ba1                	andi	a5,a5,8
    800061c2:	0e078763          	beqz	a5,800062b0 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061c6:	100017b7          	lui	a5,0x10001
    800061ca:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800061ce:	43fc                	lw	a5,68(a5)
    800061d0:	2781                	sext.w	a5,a5
    800061d2:	0e079563          	bnez	a5,800062bc <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061d6:	100017b7          	lui	a5,0x10001
    800061da:	5bdc                	lw	a5,52(a5)
    800061dc:	2781                	sext.w	a5,a5
  if(max == 0)
    800061de:	0e078563          	beqz	a5,800062c8 <virtio_disk_init+0x194>
  if(max < NUM)
    800061e2:	471d                	li	a4,7
    800061e4:	0ef77863          	bgeu	a4,a5,800062d4 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    800061e8:	9c5fa0ef          	jal	ra,80000bac <kalloc>
    800061ec:	00246497          	auipc	s1,0x246
    800061f0:	8f448493          	addi	s1,s1,-1804 # 8024bae0 <disk>
    800061f4:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800061f6:	9b7fa0ef          	jal	ra,80000bac <kalloc>
    800061fa:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800061fc:	9b1fa0ef          	jal	ra,80000bac <kalloc>
    80006200:	87aa                	mv	a5,a0
    80006202:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006204:	6088                	ld	a0,0(s1)
    80006206:	cd69                	beqz	a0,800062e0 <virtio_disk_init+0x1ac>
    80006208:	00246717          	auipc	a4,0x246
    8000620c:	8e073703          	ld	a4,-1824(a4) # 8024bae8 <disk+0x8>
    80006210:	cb61                	beqz	a4,800062e0 <virtio_disk_init+0x1ac>
    80006212:	c7f9                	beqz	a5,800062e0 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80006214:	6605                	lui	a2,0x1
    80006216:	4581                	li	a1,0
    80006218:	b6dfa0ef          	jal	ra,80000d84 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000621c:	00246497          	auipc	s1,0x246
    80006220:	8c448493          	addi	s1,s1,-1852 # 8024bae0 <disk>
    80006224:	6605                	lui	a2,0x1
    80006226:	4581                	li	a1,0
    80006228:	6488                	ld	a0,8(s1)
    8000622a:	b5bfa0ef          	jal	ra,80000d84 <memset>
  memset(disk.used, 0, PGSIZE);
    8000622e:	6605                	lui	a2,0x1
    80006230:	4581                	li	a1,0
    80006232:	6888                	ld	a0,16(s1)
    80006234:	b51fa0ef          	jal	ra,80000d84 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006238:	100017b7          	lui	a5,0x10001
    8000623c:	4721                	li	a4,8
    8000623e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006240:	4098                	lw	a4,0(s1)
    80006242:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006246:	40d8                	lw	a4,4(s1)
    80006248:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000624c:	6498                	ld	a4,8(s1)
    8000624e:	0007069b          	sext.w	a3,a4
    80006252:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006256:	9701                	srai	a4,a4,0x20
    80006258:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000625c:	6898                	ld	a4,16(s1)
    8000625e:	0007069b          	sext.w	a3,a4
    80006262:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006266:	9701                	srai	a4,a4,0x20
    80006268:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000626c:	4705                	li	a4,1
    8000626e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006270:	00e48c23          	sb	a4,24(s1)
    80006274:	00e48ca3          	sb	a4,25(s1)
    80006278:	00e48d23          	sb	a4,26(s1)
    8000627c:	00e48da3          	sb	a4,27(s1)
    80006280:	00e48e23          	sb	a4,28(s1)
    80006284:	00e48ea3          	sb	a4,29(s1)
    80006288:	00e48f23          	sb	a4,30(s1)
    8000628c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006290:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006294:	0727a823          	sw	s2,112(a5)
}
    80006298:	60e2                	ld	ra,24(sp)
    8000629a:	6442                	ld	s0,16(sp)
    8000629c:	64a2                	ld	s1,8(sp)
    8000629e:	6902                	ld	s2,0(sp)
    800062a0:	6105                	addi	sp,sp,32
    800062a2:	8082                	ret
    panic("could not find virtio disk");
    800062a4:	00002517          	auipc	a0,0x2
    800062a8:	4f450513          	addi	a0,a0,1268 # 80008798 <syscalls+0x3a0>
    800062ac:	cdefa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    800062b0:	00002517          	auipc	a0,0x2
    800062b4:	50850513          	addi	a0,a0,1288 # 800087b8 <syscalls+0x3c0>
    800062b8:	cd2fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    800062bc:	00002517          	auipc	a0,0x2
    800062c0:	51c50513          	addi	a0,a0,1308 # 800087d8 <syscalls+0x3e0>
    800062c4:	cc6fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    800062c8:	00002517          	auipc	a0,0x2
    800062cc:	53050513          	addi	a0,a0,1328 # 800087f8 <syscalls+0x400>
    800062d0:	cbafa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    800062d4:	00002517          	auipc	a0,0x2
    800062d8:	54450513          	addi	a0,a0,1348 # 80008818 <syscalls+0x420>
    800062dc:	caefa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    800062e0:	00002517          	auipc	a0,0x2
    800062e4:	55850513          	addi	a0,a0,1368 # 80008838 <syscalls+0x440>
    800062e8:	ca2fa0ef          	jal	ra,8000078a <panic>

00000000800062ec <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062ec:	7119                	addi	sp,sp,-128
    800062ee:	fc86                	sd	ra,120(sp)
    800062f0:	f8a2                	sd	s0,112(sp)
    800062f2:	f4a6                	sd	s1,104(sp)
    800062f4:	f0ca                	sd	s2,96(sp)
    800062f6:	ecce                	sd	s3,88(sp)
    800062f8:	e8d2                	sd	s4,80(sp)
    800062fa:	e4d6                	sd	s5,72(sp)
    800062fc:	e0da                	sd	s6,64(sp)
    800062fe:	fc5e                	sd	s7,56(sp)
    80006300:	f862                	sd	s8,48(sp)
    80006302:	f466                	sd	s9,40(sp)
    80006304:	f06a                	sd	s10,32(sp)
    80006306:	ec6e                	sd	s11,24(sp)
    80006308:	0100                	addi	s0,sp,128
    8000630a:	8aaa                	mv	s5,a0
    8000630c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000630e:	00c52d03          	lw	s10,12(a0)
    80006312:	001d1d1b          	slliw	s10,s10,0x1
    80006316:	1d02                	slli	s10,s10,0x20
    80006318:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000631c:	00246517          	auipc	a0,0x246
    80006320:	8ec50513          	addi	a0,a0,-1812 # 8024bc08 <disk+0x128>
    80006324:	98dfa0ef          	jal	ra,80000cb0 <acquire>
  for(int i = 0; i < 3; i++){
    80006328:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000632a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000632c:	00245b97          	auipc	s7,0x245
    80006330:	7b4b8b93          	addi	s7,s7,1972 # 8024bae0 <disk>
  for(int i = 0; i < 3; i++){
    80006334:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006336:	00246c97          	auipc	s9,0x246
    8000633a:	8d2c8c93          	addi	s9,s9,-1838 # 8024bc08 <disk+0x128>
    8000633e:	a8a9                	j	80006398 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006340:	00fb8733          	add	a4,s7,a5
    80006344:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006348:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000634a:	0207c563          	bltz	a5,80006374 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000634e:	2905                	addiw	s2,s2,1
    80006350:	0611                	addi	a2,a2,4
    80006352:	05690863          	beq	s2,s6,800063a2 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80006356:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006358:	00245717          	auipc	a4,0x245
    8000635c:	78870713          	addi	a4,a4,1928 # 8024bae0 <disk>
    80006360:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006362:	01874683          	lbu	a3,24(a4)
    80006366:	fee9                	bnez	a3,80006340 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006368:	2785                	addiw	a5,a5,1
    8000636a:	0705                	addi	a4,a4,1
    8000636c:	fe979be3          	bne	a5,s1,80006362 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006370:	57fd                	li	a5,-1
    80006372:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006374:	01205b63          	blez	s2,8000638a <virtio_disk_rw+0x9e>
    80006378:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000637a:	000a2503          	lw	a0,0(s4)
    8000637e:	d41ff0ef          	jal	ra,800060be <free_desc>
      for(int j = 0; j < i; j++)
    80006382:	2d85                	addiw	s11,s11,1
    80006384:	0a11                	addi	s4,s4,4
    80006386:	ffb91ae3          	bne	s2,s11,8000637a <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000638a:	85e6                	mv	a1,s9
    8000638c:	00245517          	auipc	a0,0x245
    80006390:	76c50513          	addi	a0,a0,1900 # 8024baf8 <disk+0x18>
    80006394:	914fc0ef          	jal	ra,800024a8 <sleep>
  for(int i = 0; i < 3; i++){
    80006398:	f8040a13          	addi	s4,s0,-128
{
    8000639c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000639e:	894e                	mv	s2,s3
    800063a0:	bf5d                	j	80006356 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063a2:	f8042583          	lw	a1,-128(s0)
    800063a6:	00a58793          	addi	a5,a1,10
    800063aa:	0792                	slli	a5,a5,0x4

  if(write)
    800063ac:	00245617          	auipc	a2,0x245
    800063b0:	73460613          	addi	a2,a2,1844 # 8024bae0 <disk>
    800063b4:	00f60733          	add	a4,a2,a5
    800063b8:	018036b3          	snez	a3,s8
    800063bc:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063be:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800063c2:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063c6:	f6078693          	addi	a3,a5,-160
    800063ca:	6218                	ld	a4,0(a2)
    800063cc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063ce:	00878513          	addi	a0,a5,8
    800063d2:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063d4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063d6:	6208                	ld	a0,0(a2)
    800063d8:	96aa                	add	a3,a3,a0
    800063da:	4741                	li	a4,16
    800063dc:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063de:	4705                	li	a4,1
    800063e0:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063e4:	f8442703          	lw	a4,-124(s0)
    800063e8:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063ec:	0712                	slli	a4,a4,0x4
    800063ee:	953a                	add	a0,a0,a4
    800063f0:	058a8693          	addi	a3,s5,88
    800063f4:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063f6:	6208                	ld	a0,0(a2)
    800063f8:	972a                	add	a4,a4,a0
    800063fa:	40000693          	li	a3,1024
    800063fe:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006400:	001c3c13          	seqz	s8,s8
    80006404:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006406:	001c6c13          	ori	s8,s8,1
    8000640a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000640e:	f8842603          	lw	a2,-120(s0)
    80006412:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006416:	00245697          	auipc	a3,0x245
    8000641a:	6ca68693          	addi	a3,a3,1738 # 8024bae0 <disk>
    8000641e:	00258713          	addi	a4,a1,2
    80006422:	0712                	slli	a4,a4,0x4
    80006424:	9736                	add	a4,a4,a3
    80006426:	587d                	li	a6,-1
    80006428:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000642c:	0612                	slli	a2,a2,0x4
    8000642e:	9532                	add	a0,a0,a2
    80006430:	f9078793          	addi	a5,a5,-112
    80006434:	97b6                	add	a5,a5,a3
    80006436:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80006438:	629c                	ld	a5,0(a3)
    8000643a:	97b2                	add	a5,a5,a2
    8000643c:	4605                	li	a2,1
    8000643e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006440:	4509                	li	a0,2
    80006442:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80006446:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000644a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000644e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006452:	6698                	ld	a4,8(a3)
    80006454:	00275783          	lhu	a5,2(a4)
    80006458:	8b9d                	andi	a5,a5,7
    8000645a:	0786                	slli	a5,a5,0x1
    8000645c:	97ba                	add	a5,a5,a4
    8000645e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006462:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006466:	6698                	ld	a4,8(a3)
    80006468:	00275783          	lhu	a5,2(a4)
    8000646c:	2785                	addiw	a5,a5,1
    8000646e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006472:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006476:	100017b7          	lui	a5,0x10001
    8000647a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000647e:	004aa783          	lw	a5,4(s5)
    80006482:	00c79f63          	bne	a5,a2,800064a0 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80006486:	00245917          	auipc	s2,0x245
    8000648a:	78290913          	addi	s2,s2,1922 # 8024bc08 <disk+0x128>
  while(b->disk == 1) {
    8000648e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006490:	85ca                	mv	a1,s2
    80006492:	8556                	mv	a0,s5
    80006494:	814fc0ef          	jal	ra,800024a8 <sleep>
  while(b->disk == 1) {
    80006498:	004aa783          	lw	a5,4(s5)
    8000649c:	fe978ae3          	beq	a5,s1,80006490 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800064a0:	f8042903          	lw	s2,-128(s0)
    800064a4:	00290793          	addi	a5,s2,2
    800064a8:	00479713          	slli	a4,a5,0x4
    800064ac:	00245797          	auipc	a5,0x245
    800064b0:	63478793          	addi	a5,a5,1588 # 8024bae0 <disk>
    800064b4:	97ba                	add	a5,a5,a4
    800064b6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064ba:	00245997          	auipc	s3,0x245
    800064be:	62698993          	addi	s3,s3,1574 # 8024bae0 <disk>
    800064c2:	00491713          	slli	a4,s2,0x4
    800064c6:	0009b783          	ld	a5,0(s3)
    800064ca:	97ba                	add	a5,a5,a4
    800064cc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064d0:	854a                	mv	a0,s2
    800064d2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064d6:	be9ff0ef          	jal	ra,800060be <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064da:	8885                	andi	s1,s1,1
    800064dc:	f0fd                	bnez	s1,800064c2 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064de:	00245517          	auipc	a0,0x245
    800064e2:	72a50513          	addi	a0,a0,1834 # 8024bc08 <disk+0x128>
    800064e6:	863fa0ef          	jal	ra,80000d48 <release>
}
    800064ea:	70e6                	ld	ra,120(sp)
    800064ec:	7446                	ld	s0,112(sp)
    800064ee:	74a6                	ld	s1,104(sp)
    800064f0:	7906                	ld	s2,96(sp)
    800064f2:	69e6                	ld	s3,88(sp)
    800064f4:	6a46                	ld	s4,80(sp)
    800064f6:	6aa6                	ld	s5,72(sp)
    800064f8:	6b06                	ld	s6,64(sp)
    800064fa:	7be2                	ld	s7,56(sp)
    800064fc:	7c42                	ld	s8,48(sp)
    800064fe:	7ca2                	ld	s9,40(sp)
    80006500:	7d02                	ld	s10,32(sp)
    80006502:	6de2                	ld	s11,24(sp)
    80006504:	6109                	addi	sp,sp,128
    80006506:	8082                	ret

0000000080006508 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006508:	1101                	addi	sp,sp,-32
    8000650a:	ec06                	sd	ra,24(sp)
    8000650c:	e822                	sd	s0,16(sp)
    8000650e:	e426                	sd	s1,8(sp)
    80006510:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006512:	00245497          	auipc	s1,0x245
    80006516:	5ce48493          	addi	s1,s1,1486 # 8024bae0 <disk>
    8000651a:	00245517          	auipc	a0,0x245
    8000651e:	6ee50513          	addi	a0,a0,1774 # 8024bc08 <disk+0x128>
    80006522:	f8efa0ef          	jal	ra,80000cb0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006526:	10001737          	lui	a4,0x10001
    8000652a:	533c                	lw	a5,96(a4)
    8000652c:	8b8d                	andi	a5,a5,3
    8000652e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006530:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006534:	689c                	ld	a5,16(s1)
    80006536:	0204d703          	lhu	a4,32(s1)
    8000653a:	0027d783          	lhu	a5,2(a5)
    8000653e:	04f70663          	beq	a4,a5,8000658a <virtio_disk_intr+0x82>
    __sync_synchronize();
    80006542:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006546:	6898                	ld	a4,16(s1)
    80006548:	0204d783          	lhu	a5,32(s1)
    8000654c:	8b9d                	andi	a5,a5,7
    8000654e:	078e                	slli	a5,a5,0x3
    80006550:	97ba                	add	a5,a5,a4
    80006552:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006554:	00278713          	addi	a4,a5,2
    80006558:	0712                	slli	a4,a4,0x4
    8000655a:	9726                	add	a4,a4,s1
    8000655c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006560:	e321                	bnez	a4,800065a0 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006562:	0789                	addi	a5,a5,2
    80006564:	0792                	slli	a5,a5,0x4
    80006566:	97a6                	add	a5,a5,s1
    80006568:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000656a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000656e:	f87fb0ef          	jal	ra,800024f4 <wakeup>

    disk.used_idx += 1;
    80006572:	0204d783          	lhu	a5,32(s1)
    80006576:	2785                	addiw	a5,a5,1
    80006578:	17c2                	slli	a5,a5,0x30
    8000657a:	93c1                	srli	a5,a5,0x30
    8000657c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006580:	6898                	ld	a4,16(s1)
    80006582:	00275703          	lhu	a4,2(a4)
    80006586:	faf71ee3          	bne	a4,a5,80006542 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    8000658a:	00245517          	auipc	a0,0x245
    8000658e:	67e50513          	addi	a0,a0,1662 # 8024bc08 <disk+0x128>
    80006592:	fb6fa0ef          	jal	ra,80000d48 <release>
}
    80006596:	60e2                	ld	ra,24(sp)
    80006598:	6442                	ld	s0,16(sp)
    8000659a:	64a2                	ld	s1,8(sp)
    8000659c:	6105                	addi	sp,sp,32
    8000659e:	8082                	ret
      panic("virtio_disk_intr status");
    800065a0:	00002517          	auipc	a0,0x2
    800065a4:	2b050513          	addi	a0,a0,688 # 80008850 <syscalls+0x458>
    800065a8:	9e2fa0ef          	jal	ra,8000078a <panic>

00000000800065ac <shm_init>:
 * 
 * 创建并初始化保护共享内存对象的自旋锁。
 */
void
shm_init(void)
{
    800065ac:	1141                	addi	sp,sp,-16
    800065ae:	e406                	sd	ra,8(sp)
    800065b0:	e022                	sd	s0,0(sp)
    800065b2:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    800065b4:	00002597          	auipc	a1,0x2
    800065b8:	2b458593          	addi	a1,a1,692 # 80008868 <syscalls+0x470>
    800065bc:	00245517          	auipc	a0,0x245
    800065c0:	66450513          	addi	a0,a0,1636 # 8024bc20 <shmt>
    800065c4:	e6cfa0ef          	jal	ra,80000c30 <initlock>
}
    800065c8:	60a2                	ld	ra,8(sp)
    800065ca:	6402                	ld	s0,0(sp)
    800065cc:	0141                	addi	sp,sp,16
    800065ce:	8082                	ret

00000000800065d0 <shm_get>:
 *   2. 如果找到且满足条件，增加引用计数并返回
 *   3. 如果没找到，创建一个新的共享内存对象
 */
int
shm_get(int key, int npages)
{
    800065d0:	7179                	addi	sp,sp,-48
    800065d2:	f406                	sd	ra,40(sp)
    800065d4:	f022                	sd	s0,32(sp)
    800065d6:	ec26                	sd	s1,24(sp)
    800065d8:	e84a                	sd	s2,16(sp)
    800065da:	e44e                	sd	s3,8(sp)
    800065dc:	1800                	addi	s0,sp,48
    800065de:	892a                	mv	s2,a0
    800065e0:	89ae                	mv	s3,a1
  acquire(&shmt.lock);
    800065e2:	00245517          	auipc	a0,0x245
    800065e6:	63e50513          	addi	a0,a0,1598 # 8024bc20 <shmt>
    800065ea:	ec6fa0ef          	jal	ra,80000cb0 <acquire>

  // 先查找已有的共享内存对象
  for(int i=0;i<NSHM;i++){
    800065ee:	00245697          	auipc	a3,0x245
    800065f2:	64a68693          	addi	a3,a3,1610 # 8024bc38 <shmt+0x18>
  acquire(&shmt.lock);
    800065f6:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    800065f8:	4481                	li	s1,0
    800065fa:	6605                	lui	a2,0x1
    800065fc:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006600:	4841                	li	a6,16
    80006602:	a015                	j	80006626 <shm_get+0x56>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查对象是否已被标记删除
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
    80006604:	00245517          	auipc	a0,0x245
    80006608:	61c50513          	addi	a0,a0,1564 # 8024bc20 <shmt>
    8000660c:	f3cfa0ef          	jal	ra,80000d48 <release>
        return -1;
    80006610:	54fd                	li	s1,-1
    80006612:	a879                	j	800066b0 <shm_get+0xe0>
      }
      // 检查请求的页数是否超过对象的总页数
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    80006614:	853a                	mv	a0,a4
    80006616:	f32fa0ef          	jal	ra,80000d48 <release>
        return -1;
    8000661a:	54fd                	li	s1,-1
    8000661c:	a851                	j	800066b0 <shm_get+0xe0>
  for(int i=0;i<NSHM;i++){
    8000661e:	2485                	addiw	s1,s1,1
    80006620:	97b2                	add	a5,a5,a2
    80006622:	07048563          	beq	s1,a6,8000668c <shm_get+0xbc>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006626:	4398                	lw	a4,0(a5)
    80006628:	db7d                	beqz	a4,8000661e <shm_get+0x4e>
    8000662a:	43d8                	lw	a4,4(a5)
    8000662c:	ff2719e3          	bne	a4,s2,8000661e <shm_get+0x4e>
      if(shmt.obj[i].deleted){
    80006630:	6785                	lui	a5,0x1
    80006632:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006636:	02e486b3          	mul	a3,s1,a4
    8000663a:	00245717          	auipc	a4,0x245
    8000663e:	5e670713          	addi	a4,a4,1510 # 8024bc20 <shmt>
    80006642:	9736                	add	a4,a4,a3
    80006644:	97ba                	add	a5,a5,a4
    80006646:	82c7a783          	lw	a5,-2004(a5)
    8000664a:	ffcd                	bnez	a5,80006604 <shm_get+0x34>
      if(npages > shmt.obj[i].npages){
    8000664c:	6785                	lui	a5,0x1
    8000664e:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006652:	02f487b3          	mul	a5,s1,a5
    80006656:	00245717          	auipc	a4,0x245
    8000665a:	5ca70713          	addi	a4,a4,1482 # 8024bc20 <shmt>
    8000665e:	97ba                	add	a5,a5,a4
    80006660:	539c                	lw	a5,32(a5)
    80006662:	fb37c9e3          	blt	a5,s3,80006614 <shm_get+0x44>
      }
      // 增加引用计数
      shmt.obj[i].refcnt++;
    80006666:	00245517          	auipc	a0,0x245
    8000666a:	5ba50513          	addi	a0,a0,1466 # 8024bc20 <shmt>
    8000666e:	6785                	lui	a5,0x1
    80006670:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006674:	02e48733          	mul	a4,s1,a4
    80006678:	972a                	add	a4,a4,a0
    8000667a:	97ba                	add	a5,a5,a4
    8000667c:	8287a703          	lw	a4,-2008(a5)
    80006680:	2705                	addiw	a4,a4,1
    80006682:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    80006686:	ec2fa0ef          	jal	ra,80000d48 <release>
      return i;
    8000668a:	a01d                	j	800066b0 <shm_get+0xe0>
    }
  }

  // 如果没有找到，创建一个新的共享内存对象
  for(int i=0;i<NSHM;i++){
    8000668c:	4481                	li	s1,0
    8000668e:	6705                	lui	a4,0x1
    80006690:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006694:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    80006696:	429c                	lw	a5,0(a3)
    80006698:	c785                	beqz	a5,800066c0 <shm_get+0xf0>
  for(int i=0;i<NSHM;i++){
    8000669a:	2485                	addiw	s1,s1,1
    8000669c:	96ba                	add	a3,a3,a4
    8000669e:	fec49ce3          	bne	s1,a2,80006696 <shm_get+0xc6>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    800066a2:	00245517          	auipc	a0,0x245
    800066a6:	57e50513          	addi	a0,a0,1406 # 8024bc20 <shmt>
    800066aa:	e9efa0ef          	jal	ra,80000d48 <release>
  return -1;  // 没有空闲的共享内存对象槽位
    800066ae:	54fd                	li	s1,-1
}
    800066b0:	8526                	mv	a0,s1
    800066b2:	70a2                	ld	ra,40(sp)
    800066b4:	7402                	ld	s0,32(sp)
    800066b6:	64e2                	ld	s1,24(sp)
    800066b8:	6942                	ld	s2,16(sp)
    800066ba:	69a2                	ld	s3,8(sp)
    800066bc:	6145                	addi	sp,sp,48
    800066be:	8082                	ret
      shmt.obj[i].deleted = 0;
    800066c0:	00245617          	auipc	a2,0x245
    800066c4:	56060613          	addi	a2,a2,1376 # 8024bc20 <shmt>
    800066c8:	6785                	lui	a5,0x1
    800066ca:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800066ce:	02e486b3          	mul	a3,s1,a4
    800066d2:	00d60733          	add	a4,a2,a3
    800066d6:	97ba                	add	a5,a5,a4
    800066d8:	8207a623          	sw	zero,-2004(a5)
      shmt.obj[i].used = 1;
    800066dc:	4585                	li	a1,1
    800066de:	cf0c                	sw	a1,24(a4)
      shmt.obj[i].key = key;
    800066e0:	01272e23          	sw	s2,28(a4)
      shmt.obj[i].npages = npages;
    800066e4:	03372023          	sw	s3,32(a4)
      shmt.obj[i].refcnt = 1;
    800066e8:	82b7a423          	sw	a1,-2008(a5)
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
    800066ec:	02868793          	addi	a5,a3,40
    800066f0:	97b2                	add	a5,a5,a2
    800066f2:	00246717          	auipc	a4,0x246
    800066f6:	d5670713          	addi	a4,a4,-682 # 8024c448 <shmt+0x828>
    800066fa:	9736                	add	a4,a4,a3
    800066fc:	0007b023          	sd	zero,0(a5)
    80006700:	07a1                	addi	a5,a5,8
    80006702:	fee79de3          	bne	a5,a4,800066fc <shm_get+0x12c>
      release(&shmt.lock);
    80006706:	00245517          	auipc	a0,0x245
    8000670a:	51a50513          	addi	a0,a0,1306 # 8024bc20 <shmt>
    8000670e:	e3afa0ef          	jal	ra,80000d48 <release>
      return i;
    80006712:	bf79                	j	800066b0 <shm_get+0xe0>

0000000080006714 <shm_put>:
 *   - 使用 kfree 释放物理页，kfree 会正确处理页的引用计数
 *   - 如果对象已被标记删除，当引用计数为 0 时也会被完全释放
 */
void
shm_put(int key)
{
    80006714:	7179                	addi	sp,sp,-48
    80006716:	f406                	sd	ra,40(sp)
    80006718:	f022                	sd	s0,32(sp)
    8000671a:	ec26                	sd	s1,24(sp)
    8000671c:	e84a                	sd	s2,16(sp)
    8000671e:	e44e                	sd	s3,8(sp)
    80006720:	e052                	sd	s4,0(sp)
    80006722:	1800                	addi	s0,sp,48
    80006724:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    80006726:	00245517          	auipc	a0,0x245
    8000672a:	4fa50513          	addi	a0,a0,1274 # 8024bc20 <shmt>
    8000672e:	d82fa0ef          	jal	ra,80000cb0 <acquire>
  for(int i=0;i<NSHM;i++){
    80006732:	00245797          	auipc	a5,0x245
    80006736:	50678793          	addi	a5,a5,1286 # 8024bc38 <shmt+0x18>
    8000673a:	4481                	li	s1,0
    8000673c:	6685                	lui	a3,0x1
    8000673e:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006742:	4641                	li	a2,16
    80006744:	a0b5                	j	800067b0 <shm_put+0x9c>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      // 检查引用计数的有效性
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
    80006746:	00002517          	auipc	a0,0x2
    8000674a:	12a50513          	addi	a0,a0,298 # 80008870 <syscalls+0x478>
    8000674e:	83cfa0ef          	jal	ra,8000078a <panic>
      shmt.obj[i].refcnt--;
      
      // 如果引用计数为 0，释放所有资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j=0;j<shmt.obj[i].npages;j++){
    80006752:	2985                	addiw	s3,s3,1
    80006754:	0921                	addi	s2,s2,8
    80006756:	020a2783          	lw	a5,32(s4)
    8000675a:	00f9da63          	bge	s3,a5,8000676e <shm_put+0x5a>
          if(shmt.obj[i].pa[j]){
    8000675e:	00093503          	ld	a0,0(s2)
    80006762:	d965                	beqz	a0,80006752 <shm_put+0x3e>
            kfree((void*)shmt.obj[i].pa[j]);
    80006764:	b1afa0ef          	jal	ra,80000a7e <kfree>
            shmt.obj[i].pa[j] = 0;
    80006768:	00093023          	sd	zero,0(s2)
    8000676c:	b7dd                	j	80006752 <shm_put+0x3e>
          }
        }
        // 重置对象状态
        shmt.obj[i].used = 0;
    8000676e:	6785                	lui	a5,0x1
    80006770:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006774:	02e484b3          	mul	s1,s1,a4
    80006778:	00245717          	auipc	a4,0x245
    8000677c:	4a870713          	addi	a4,a4,1192 # 8024bc20 <shmt>
    80006780:	94ba                	add	s1,s1,a4
    80006782:	0004ac23          	sw	zero,24(s1)
        shmt.obj[i].deleted = 0;
    80006786:	97a6                	add	a5,a5,s1
    80006788:	8207a623          	sw	zero,-2004(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    8000678c:	00245517          	auipc	a0,0x245
    80006790:	49450513          	addi	a0,a0,1172 # 8024bc20 <shmt>
    80006794:	db4fa0ef          	jal	ra,80000d48 <release>
}
    80006798:	70a2                	ld	ra,40(sp)
    8000679a:	7402                	ld	s0,32(sp)
    8000679c:	64e2                	ld	s1,24(sp)
    8000679e:	6942                	ld	s2,16(sp)
    800067a0:	69a2                	ld	s3,8(sp)
    800067a2:	6a02                	ld	s4,0(sp)
    800067a4:	6145                	addi	sp,sp,48
    800067a6:	8082                	ret
  for(int i=0;i<NSHM;i++){
    800067a8:	2485                	addiw	s1,s1,1
    800067aa:	97b6                	add	a5,a5,a3
    800067ac:	fec480e3          	beq	s1,a2,8000678c <shm_put+0x78>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    800067b0:	4398                	lw	a4,0(a5)
    800067b2:	db7d                	beqz	a4,800067a8 <shm_put+0x94>
    800067b4:	43d8                	lw	a4,4(a5)
    800067b6:	ff2719e3          	bne	a4,s2,800067a8 <shm_put+0x94>
      if(shmt.obj[i].refcnt < 1)
    800067ba:	6785                	lui	a5,0x1
    800067bc:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800067c0:	02e486b3          	mul	a3,s1,a4
    800067c4:	00245717          	auipc	a4,0x245
    800067c8:	45c70713          	addi	a4,a4,1116 # 8024bc20 <shmt>
    800067cc:	9736                	add	a4,a4,a3
    800067ce:	97ba                	add	a5,a5,a4
    800067d0:	8287a783          	lw	a5,-2008(a5)
    800067d4:	f6f059e3          	blez	a5,80006746 <shm_put+0x32>
      shmt.obj[i].refcnt--;
    800067d8:	37fd                	addiw	a5,a5,-1
    800067da:	0007899b          	sext.w	s3,a5
    800067de:	6705                	lui	a4,0x1
    800067e0:	81870693          	addi	a3,a4,-2024 # 818 <_entry-0x7ffff7e8>
    800067e4:	02d48633          	mul	a2,s1,a3
    800067e8:	00245697          	auipc	a3,0x245
    800067ec:	43868693          	addi	a3,a3,1080 # 8024bc20 <shmt>
    800067f0:	96b2                	add	a3,a3,a2
    800067f2:	9736                	add	a4,a4,a3
    800067f4:	82f72423          	sw	a5,-2008(a4)
      if(shmt.obj[i].refcnt == 0){
    800067f8:	f8099ae3          	bnez	s3,8000678c <shm_put+0x78>
        for(int j=0;j<shmt.obj[i].npages;j++){
    800067fc:	529c                	lw	a5,32(a3)
    800067fe:	f6f058e3          	blez	a5,8000676e <shm_put+0x5a>
    80006802:	00245797          	auipc	a5,0x245
    80006806:	44678793          	addi	a5,a5,1094 # 8024bc48 <shmt+0x28>
    8000680a:	00f60933          	add	s2,a2,a5
    8000680e:	8a36                	mv	s4,a3
    80006810:	b7b9                	j	8000675e <shm_put+0x4a>

0000000080006812 <shm_getpa>:
 *   3. 如果该页尚未分配，分配一个新的物理页并初始化为0
 *   4. 返回该页的物理地址
 */
uint64
shm_getpa(int key, int page_index)
{
    80006812:	7179                	addi	sp,sp,-48
    80006814:	f406                	sd	ra,40(sp)
    80006816:	f022                	sd	s0,32(sp)
    80006818:	ec26                	sd	s1,24(sp)
    8000681a:	e84a                	sd	s2,16(sp)
    8000681c:	e44e                	sd	s3,8(sp)
    8000681e:	e052                	sd	s4,0(sp)
    80006820:	1800                	addi	s0,sp,48
    80006822:	892a                	mv	s2,a0
    80006824:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    80006826:	00245517          	auipc	a0,0x245
    8000682a:	3fa50513          	addi	a0,a0,1018 # 8024bc20 <shmt>
    8000682e:	c82fa0ef          	jal	ra,80000cb0 <acquire>

  for(int i=0;i<NSHM;i++){
    80006832:	00245797          	auipc	a5,0x245
    80006836:	40678793          	addi	a5,a5,1030 # 8024bc38 <shmt+0x18>
    8000683a:	4481                	li	s1,0
    8000683c:	6685                	lui	a3,0x1
    8000683e:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006842:	4641                	li	a2,16
    80006844:	a82d                	j	8000687e <shm_getpa+0x6c>
        break;
      }
      
      // 如果该页尚未分配，执行惰性分配
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    80006846:	b66fa0ef          	jal	ra,80000bac <kalloc>
    8000684a:	8a2a                	mv	s4,a0
        if(mem == 0){
    8000684c:	cd41                	beqz	a0,800068e4 <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        // 初始化新分配的物理页为0
        memset(mem, 0, PGSIZE);
    8000684e:	6605                	lui	a2,0x1
    80006850:	4581                	li	a1,0
    80006852:	d32fa0ef          	jal	ra,80000d84 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    80006856:	00649793          	slli	a5,s1,0x6
    8000685a:	97a6                	add	a5,a5,s1
    8000685c:	078a                	slli	a5,a5,0x2
    8000685e:	8f85                	sub	a5,a5,s1
    80006860:	97ce                	add	a5,a5,s3
    80006862:	0791                	addi	a5,a5,4
    80006864:	078e                	slli	a5,a5,0x3
    80006866:	00245717          	auipc	a4,0x245
    8000686a:	3ba70713          	addi	a4,a4,954 # 8024bc20 <shmt>
    8000686e:	97ba                	add	a5,a5,a4
    80006870:	0147b423          	sd	s4,8(a5)
    80006874:	a0b9                	j	800068c2 <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    80006876:	2485                	addiw	s1,s1,1
    80006878:	97b6                	add	a5,a5,a3
    8000687a:	06c48463          	beq	s1,a2,800068e2 <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000687e:	4398                	lw	a4,0(a5)
    80006880:	db7d                	beqz	a4,80006876 <shm_getpa+0x64>
    80006882:	43d8                	lw	a4,4(a5)
    80006884:	ff2719e3          	bne	a4,s2,80006876 <shm_getpa+0x64>
        pa = 0;
    80006888:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    8000688a:	0409cd63          	bltz	s3,800068e4 <shm_getpa+0xd2>
    8000688e:	6785                	lui	a5,0x1
    80006890:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006894:	02f487b3          	mul	a5,s1,a5
    80006898:	00245717          	auipc	a4,0x245
    8000689c:	38870713          	addi	a4,a4,904 # 8024bc20 <shmt>
    800068a0:	97ba                	add	a5,a5,a4
    800068a2:	539c                	lw	a5,32(a5)
    800068a4:	04f9d063          	bge	s3,a5,800068e4 <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    800068a8:	00649793          	slli	a5,s1,0x6
    800068ac:	97a6                	add	a5,a5,s1
    800068ae:	078a                	slli	a5,a5,0x2
    800068b0:	8f85                	sub	a5,a5,s1
    800068b2:	97ce                	add	a5,a5,s3
    800068b4:	0791                	addi	a5,a5,4
    800068b6:	078e                	slli	a5,a5,0x3
    800068b8:	97ba                	add	a5,a5,a4
    800068ba:	0087b903          	ld	s2,8(a5)
    800068be:	f80904e3          	beqz	s2,80006846 <shm_getpa+0x34>
      }
      
      pa = shmt.obj[i].pa[page_index];
    800068c2:	00649793          	slli	a5,s1,0x6
    800068c6:	97a6                	add	a5,a5,s1
    800068c8:	078a                	slli	a5,a5,0x2
    800068ca:	8f85                	sub	a5,a5,s1
    800068cc:	97ce                	add	a5,a5,s3
    800068ce:	0791                	addi	a5,a5,4
    800068d0:	078e                	slli	a5,a5,0x3
    800068d2:	00245717          	auipc	a4,0x245
    800068d6:	34e70713          	addi	a4,a4,846 # 8024bc20 <shmt>
    800068da:	97ba                	add	a5,a5,a4
    800068dc:	0087b903          	ld	s2,8(a5)
      break;
    800068e0:	a011                	j	800068e4 <shm_getpa+0xd2>
  uint64 pa = 0;
    800068e2:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    800068e4:	00245517          	auipc	a0,0x245
    800068e8:	33c50513          	addi	a0,a0,828 # 8024bc20 <shmt>
    800068ec:	c5cfa0ef          	jal	ra,80000d48 <release>
  vmstats_inc_shm();  // 更新共享内存统计信息
    800068f0:	4e4000ef          	jal	ra,80006dd4 <vmstats_inc_shm>

  return pa;
}
    800068f4:	854a                	mv	a0,s2
    800068f6:	70a2                	ld	ra,40(sp)
    800068f8:	7402                	ld	s0,32(sp)
    800068fa:	64e2                	ld	s1,24(sp)
    800068fc:	6942                	ld	s2,16(sp)
    800068fe:	69a2                	ld	s3,8(sp)
    80006900:	6a02                	ld	s4,0(sp)
    80006902:	6145                	addi	sp,sp,48
    80006904:	8082                	ret

0000000080006906 <shm_ctl>:
 */
int
shm_ctl(int key, int cmd)
{
  // 目前仅支持 IPC_RMID 命令
  if(cmd != IPC_RMID)
    80006906:	10059363          	bnez	a1,80006a0c <shm_ctl+0x106>
{
    8000690a:	7139                	addi	sp,sp,-64
    8000690c:	fc06                	sd	ra,56(sp)
    8000690e:	f822                	sd	s0,48(sp)
    80006910:	f426                	sd	s1,40(sp)
    80006912:	f04a                	sd	s2,32(sp)
    80006914:	ec4e                	sd	s3,24(sp)
    80006916:	e852                	sd	s4,16(sp)
    80006918:	e456                	sd	s5,8(sp)
    8000691a:	0080                	addi	s0,sp,64
    8000691c:	892a                	mv	s2,a0
    8000691e:	89ae                	mv	s3,a1
    return -1;

  acquire(&shmt.lock);
    80006920:	00245517          	auipc	a0,0x245
    80006924:	30050513          	addi	a0,a0,768 # 8024bc20 <shmt>
    80006928:	b88fa0ef          	jal	ra,80000cb0 <acquire>

  for(int i = 0; i < NSHM; i++){
    8000692c:	00245797          	auipc	a5,0x245
    80006930:	30c78793          	addi	a5,a5,780 # 8024bc38 <shmt+0x18>
    80006934:	84ce                	mv	s1,s3
    80006936:	6685                	lui	a3,0x1
    80006938:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000693c:	4641                	li	a2,16
    8000693e:	a8b1                	j	8000699a <shm_ctl+0x94>
      // 如果当前没有任何进程引用，立即释放资源
      if(shmt.obj[i].refcnt == 0){
        // 释放所有已分配的物理页
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
    80006940:	93efa0ef          	jal	ra,80000a7e <kfree>
            shmt.obj[i].pa[j] = 0;
    80006944:	00093023          	sd	zero,0(s2)
        for(int j = 0; j < shmt.obj[i].npages; j++){
    80006948:	2a05                	addiw	s4,s4,1
    8000694a:	0921                	addi	s2,s2,8
    8000694c:	020aa783          	lw	a5,32(s5)
    80006950:	00fa5663          	bge	s4,a5,8000695c <shm_ctl+0x56>
          if(shmt.obj[i].pa[j]){
    80006954:	00093503          	ld	a0,0(s2)
    80006958:	d965                	beqz	a0,80006948 <shm_ctl+0x42>
    8000695a:	b7dd                	j	80006940 <shm_ctl+0x3a>
          }
        }
        // 完全重置对象状态
        shmt.obj[i].used = 0;
    8000695c:	6705                	lui	a4,0x1
    8000695e:	81870793          	addi	a5,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006962:	02f484b3          	mul	s1,s1,a5
    80006966:	00245797          	auipc	a5,0x245
    8000696a:	2ba78793          	addi	a5,a5,698 # 8024bc20 <shmt>
    8000696e:	94be                	add	s1,s1,a5
    80006970:	0004ac23          	sw	zero,24(s1)
        shmt.obj[i].deleted = 0;
    80006974:	9726                	add	a4,a4,s1
    80006976:	82072623          	sw	zero,-2004(a4)
        shmt.obj[i].key = 0;     
    8000697a:	0004ae23          	sw	zero,28(s1)
        shmt.obj[i].npages = 0;  
    8000697e:	0204a023          	sw	zero,32(s1)
      }

      release(&shmt.lock);
    80006982:	00245517          	auipc	a0,0x245
    80006986:	29e50513          	addi	a0,a0,670 # 8024bc20 <shmt>
    8000698a:	bbefa0ef          	jal	ra,80000d48 <release>
      return 0;
    8000698e:	854e                	mv	a0,s3
    80006990:	a0ad                	j	800069fa <shm_ctl+0xf4>
  for(int i = 0; i < NSHM; i++){
    80006992:	2485                	addiw	s1,s1,1
    80006994:	97b6                	add	a5,a5,a3
    80006996:	04c48b63          	beq	s1,a2,800069ec <shm_ctl+0xe6>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000699a:	4398                	lw	a4,0(a5)
    8000699c:	db7d                	beqz	a4,80006992 <shm_ctl+0x8c>
    8000699e:	43d8                	lw	a4,4(a5)
    800069a0:	ff2719e3          	bne	a4,s2,80006992 <shm_ctl+0x8c>
      shmt.obj[i].deleted = 1;
    800069a4:	6785                	lui	a5,0x1
    800069a6:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800069aa:	02e486b3          	mul	a3,s1,a4
    800069ae:	00245717          	auipc	a4,0x245
    800069b2:	27270713          	addi	a4,a4,626 # 8024bc20 <shmt>
    800069b6:	9736                	add	a4,a4,a3
    800069b8:	97ba                	add	a5,a5,a4
    800069ba:	4705                	li	a4,1
    800069bc:	82e7a623          	sw	a4,-2004(a5)
      if(shmt.obj[i].refcnt == 0){
    800069c0:	8287aa03          	lw	s4,-2008(a5)
    800069c4:	fa0a1fe3          	bnez	s4,80006982 <shm_ctl+0x7c>
        for(int j = 0; j < shmt.obj[i].npages; j++){
    800069c8:	00245717          	auipc	a4,0x245
    800069cc:	25870713          	addi	a4,a4,600 # 8024bc20 <shmt>
    800069d0:	00d707b3          	add	a5,a4,a3
    800069d4:	539c                	lw	a5,32(a5)
    800069d6:	f8f053e3          	blez	a5,8000695c <shm_ctl+0x56>
    800069da:	00245797          	auipc	a5,0x245
    800069de:	26e78793          	addi	a5,a5,622 # 8024bc48 <shmt+0x28>
    800069e2:	00f68933          	add	s2,a3,a5
    800069e6:	00d70ab3          	add	s5,a4,a3
    800069ea:	b7ad                	j	80006954 <shm_ctl+0x4e>
    }
  }

  release(&shmt.lock);
    800069ec:	00245517          	auipc	a0,0x245
    800069f0:	23450513          	addi	a0,a0,564 # 8024bc20 <shmt>
    800069f4:	b54fa0ef          	jal	ra,80000d48 <release>
  return -1; // key 对应的共享内存对象不存在
    800069f8:	557d                	li	a0,-1
}
    800069fa:	70e2                	ld	ra,56(sp)
    800069fc:	7442                	ld	s0,48(sp)
    800069fe:	74a2                	ld	s1,40(sp)
    80006a00:	7902                	ld	s2,32(sp)
    80006a02:	69e2                	ld	s3,24(sp)
    80006a04:	6a42                	ld	s4,16(sp)
    80006a06:	6aa2                	ld	s5,8(sp)
    80006a08:	6121                	addi	sp,sp,64
    80006a0a:	8082                	ret
    return -1;
    80006a0c:	557d                	li	a0,-1
}
    80006a0e:	8082                	ret

0000000080006a10 <shm_is_deleted>:
 *   - 如果对象不存在，默认返回 0（允许创建新对象）
 *   - 用于在 shm_get 时检查是否可以创建或访问共享内存对象
 */
int
shm_is_deleted(int key)
{
    80006a10:	1101                	addi	sp,sp,-32
    80006a12:	ec06                	sd	ra,24(sp)
    80006a14:	e822                	sd	s0,16(sp)
    80006a16:	e426                	sd	s1,8(sp)
    80006a18:	1000                	addi	s0,sp,32
    80006a1a:	84aa                	mv	s1,a0
  int del = 0; // 默认0,不存在就允许创建
  acquire(&shmt.lock);
    80006a1c:	00245517          	auipc	a0,0x245
    80006a20:	20450513          	addi	a0,a0,516 # 8024bc20 <shmt>
    80006a24:	a8cfa0ef          	jal	ra,80000cb0 <acquire>
  for(int i=0;i<NSHM;i++){
    80006a28:	00245797          	auipc	a5,0x245
    80006a2c:	21078793          	addi	a5,a5,528 # 8024bc38 <shmt+0x18>
    80006a30:	4701                	li	a4,0
    80006a32:	6605                	lui	a2,0x1
    80006a34:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006a38:	45c1                	li	a1,16
    80006a3a:	a029                	j	80006a44 <shm_is_deleted+0x34>
    80006a3c:	2705                	addiw	a4,a4,1
    80006a3e:	97b2                	add	a5,a5,a2
    80006a40:	02b70563          	beq	a4,a1,80006a6a <shm_is_deleted+0x5a>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006a44:	4394                	lw	a3,0(a5)
    80006a46:	dafd                	beqz	a3,80006a3c <shm_is_deleted+0x2c>
    80006a48:	43d4                	lw	a3,4(a5)
    80006a4a:	fe9699e3          	bne	a3,s1,80006a3c <shm_is_deleted+0x2c>
      del = shmt.obj[i].deleted;
    80006a4e:	6785                	lui	a5,0x1
    80006a50:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006a54:	02d70733          	mul	a4,a4,a3
    80006a58:	00245697          	auipc	a3,0x245
    80006a5c:	1c868693          	addi	a3,a3,456 # 8024bc20 <shmt>
    80006a60:	9736                	add	a4,a4,a3
    80006a62:	97ba                	add	a5,a5,a4
    80006a64:	82c7a483          	lw	s1,-2004(a5)
      break;
    80006a68:	a011                	j	80006a6c <shm_is_deleted+0x5c>
  int del = 0; // 默认0,不存在就允许创建
    80006a6a:	4481                	li	s1,0
    }
  }
  release(&shmt.lock);
    80006a6c:	00245517          	auipc	a0,0x245
    80006a70:	1b450513          	addi	a0,a0,436 # 8024bc20 <shmt>
    80006a74:	ad4fa0ef          	jal	ra,80000d48 <release>
  //shm_dump(key);
  return del;
}
    80006a78:	8526                	mv	a0,s1
    80006a7a:	60e2                	ld	ra,24(sp)
    80006a7c:	6442                	ld	s0,16(sp)
    80006a7e:	64a2                	ld	s1,8(sp)
    80006a80:	6105                	addi	sp,sp,32
    80006a82:	8082                	ret

0000000080006a84 <sem_lookup>:
}

// 找到 key 对应 sem；不存在返回 -1
static int
sem_lookup(int key)
{
    80006a84:	1141                	addi	sp,sp,-16
    80006a86:	e422                	sd	s0,8(sp)
    80006a88:	0800                	addi	s0,sp,16
    80006a8a:	862a                	mv	a2,a0
  for(int i = 0; i < NSEM; i++){
    80006a8c:	0024d797          	auipc	a5,0x24d
    80006a90:	34478793          	addi	a5,a5,836 # 80253dd0 <semt+0x18>
    80006a94:	4501                	li	a0,0
    80006a96:	04000693          	li	a3,64
    80006a9a:	a029                	j	80006aa4 <sem_lookup+0x20>
    80006a9c:	2505                	addiw	a0,a0,1
    80006a9e:	07c1                	addi	a5,a5,16
    80006aa0:	00d50a63          	beq	a0,a3,80006ab4 <sem_lookup+0x30>
    if(semt.s[i].used && semt.s[i].key == key)
    80006aa4:	4398                	lw	a4,0(a5)
    80006aa6:	db7d                	beqz	a4,80006a9c <sem_lookup+0x18>
    80006aa8:	43d8                	lw	a4,4(a5)
    80006aaa:	fec719e3          	bne	a4,a2,80006a9c <sem_lookup+0x18>
      return i;
  }
  return -1;
}
    80006aae:	6422                	ld	s0,8(sp)
    80006ab0:	0141                	addi	sp,sp,16
    80006ab2:	8082                	ret
  return -1;
    80006ab4:	557d                	li	a0,-1
    80006ab6:	bfe5                	j	80006aae <sem_lookup+0x2a>

0000000080006ab8 <seminit>:
{
    80006ab8:	1141                	addi	sp,sp,-16
    80006aba:	e406                	sd	ra,8(sp)
    80006abc:	e022                	sd	s0,0(sp)
    80006abe:	0800                	addi	s0,sp,16
  initlock(&semt.lock, "semt");
    80006ac0:	00002597          	auipc	a1,0x2
    80006ac4:	dc058593          	addi	a1,a1,-576 # 80008880 <syscalls+0x488>
    80006ac8:	0024d517          	auipc	a0,0x24d
    80006acc:	2f050513          	addi	a0,a0,752 # 80253db8 <semt>
    80006ad0:	960fa0ef          	jal	ra,80000c30 <initlock>
}
    80006ad4:	60a2                	ld	ra,8(sp)
    80006ad6:	6402                	ld	s0,0(sp)
    80006ad8:	0141                	addi	sp,sp,16
    80006ada:	8082                	ret

0000000080006adc <sem_open>:

// 创建或返回已有
int
sem_open(int key, int init)
{
    80006adc:	7179                	addi	sp,sp,-48
    80006ade:	f406                	sd	ra,40(sp)
    80006ae0:	f022                	sd	s0,32(sp)
    80006ae2:	ec26                	sd	s1,24(sp)
    80006ae4:	e84a                	sd	s2,16(sp)
    80006ae6:	e44e                	sd	s3,8(sp)
    80006ae8:	1800                	addi	s0,sp,48
    80006aea:	892a                	mv	s2,a0
    80006aec:	89ae                	mv	s3,a1
  acquire(&semt.lock);
    80006aee:	0024d517          	auipc	a0,0x24d
    80006af2:	2ca50513          	addi	a0,a0,714 # 80253db8 <semt>
    80006af6:	9bafa0ef          	jal	ra,80000cb0 <acquire>

  int idx = sem_lookup(key);
    80006afa:	854a                	mv	a0,s2
    80006afc:	f89ff0ef          	jal	ra,80006a84 <sem_lookup>
  if(idx >= 0){
    80006b00:	0024d717          	auipc	a4,0x24d
    80006b04:	2d070713          	addi	a4,a4,720 # 80253dd0 <semt+0x18>
    release(&semt.lock);
    return 0;  // 已存在，直接成功
  }

  for(int i = 0; i < NSEM; i++){
    80006b08:	4781                	li	a5,0
    80006b0a:	04000693          	li	a3,64
  if(idx >= 0){
    80006b0e:	02055063          	bgez	a0,80006b2e <sem_open+0x52>
    if(!semt.s[i].used){
    80006b12:	4304                	lw	s1,0(a4)
    80006b14:	c48d                	beqz	s1,80006b3e <sem_open+0x62>
  for(int i = 0; i < NSEM; i++){
    80006b16:	2785                	addiw	a5,a5,1
    80006b18:	0741                	addi	a4,a4,16
    80006b1a:	fed79ce3          	bne	a5,a3,80006b12 <sem_open+0x36>
      release(&semt.lock);
      return 0;
    }
  }

  release(&semt.lock);
    80006b1e:	0024d517          	auipc	a0,0x24d
    80006b22:	29a50513          	addi	a0,a0,666 # 80253db8 <semt>
    80006b26:	a22fa0ef          	jal	ra,80000d48 <release>
  return -1;
    80006b2a:	54fd                	li	s1,-1
    80006b2c:	a815                	j	80006b60 <sem_open+0x84>
    release(&semt.lock);
    80006b2e:	0024d517          	auipc	a0,0x24d
    80006b32:	28a50513          	addi	a0,a0,650 # 80253db8 <semt>
    80006b36:	a12fa0ef          	jal	ra,80000d48 <release>
    return 0;  // 已存在，直接成功
    80006b3a:	4481                	li	s1,0
    80006b3c:	a015                	j	80006b60 <sem_open+0x84>
      semt.s[i].used = 1;
    80006b3e:	0024d517          	auipc	a0,0x24d
    80006b42:	27a50513          	addi	a0,a0,634 # 80253db8 <semt>
    80006b46:	0785                	addi	a5,a5,1
    80006b48:	0792                	slli	a5,a5,0x4
    80006b4a:	97aa                	add	a5,a5,a0
    80006b4c:	4705                	li	a4,1
    80006b4e:	c798                	sw	a4,8(a5)
      semt.s[i].key = key;
    80006b50:	0127a623          	sw	s2,12(a5)
      semt.s[i].val = init;
    80006b54:	0137a823          	sw	s3,16(a5)
      semt.s[i].waiters = 0;
    80006b58:	0007aa23          	sw	zero,20(a5)
      release(&semt.lock);
    80006b5c:	9ecfa0ef          	jal	ra,80000d48 <release>
}
    80006b60:	8526                	mv	a0,s1
    80006b62:	70a2                	ld	ra,40(sp)
    80006b64:	7402                	ld	s0,32(sp)
    80006b66:	64e2                	ld	s1,24(sp)
    80006b68:	6942                	ld	s2,16(sp)
    80006b6a:	69a2                	ld	s3,8(sp)
    80006b6c:	6145                	addi	sp,sp,48
    80006b6e:	8082                	ret

0000000080006b70 <sem_wait>:

int
sem_wait(int key)
{
    80006b70:	7179                	addi	sp,sp,-48
    80006b72:	f406                	sd	ra,40(sp)
    80006b74:	f022                	sd	s0,32(sp)
    80006b76:	ec26                	sd	s1,24(sp)
    80006b78:	e84a                	sd	s2,16(sp)
    80006b7a:	e44e                	sd	s3,8(sp)
    80006b7c:	e052                	sd	s4,0(sp)
    80006b7e:	1800                	addi	s0,sp,48
    80006b80:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006b82:	0024d517          	auipc	a0,0x24d
    80006b86:	23650513          	addi	a0,a0,566 # 80253db8 <semt>
    80006b8a:	926fa0ef          	jal	ra,80000cb0 <acquire>

  int idx = sem_lookup(key);
    80006b8e:	8526                	mv	a0,s1
    80006b90:	ef5ff0ef          	jal	ra,80006a84 <sem_lookup>
  if(idx < 0){
    80006b94:	06054e63          	bltz	a0,80006c10 <sem_wait+0xa0>
    80006b98:	892a                	mv	s2,a0
    release(&semt.lock);
    return -1;
  }

  // while(val==0) sleep
  while(semt.s[idx].val == 0){
    80006b9a:	00150793          	addi	a5,a0,1
    80006b9e:	00479713          	slli	a4,a5,0x4
    80006ba2:	0024d797          	auipc	a5,0x24d
    80006ba6:	21678793          	addi	a5,a5,534 # 80253db8 <semt>
    80006baa:	97ba                	add	a5,a5,a4
    80006bac:	4b9c                	lw	a5,16(a5)
    80006bae:	ef85                	bnez	a5,80006be6 <sem_wait+0x76>
    semt.s[idx].waiters++;
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006bb0:	00451993          	slli	s3,a0,0x4
    80006bb4:	0024d797          	auipc	a5,0x24d
    80006bb8:	21c78793          	addi	a5,a5,540 # 80253dd0 <semt+0x18>
    80006bbc:	99be                	add	s3,s3,a5
    semt.s[idx].waiters++;
    80006bbe:	0024da17          	auipc	s4,0x24d
    80006bc2:	1faa0a13          	addi	s4,s4,506 # 80253db8 <semt>
    80006bc6:	00150493          	addi	s1,a0,1
    80006bca:	0492                	slli	s1,s1,0x4
    80006bcc:	94d2                	add	s1,s1,s4
    80006bce:	48dc                	lw	a5,20(s1)
    80006bd0:	2785                	addiw	a5,a5,1
    80006bd2:	c8dc                	sw	a5,20(s1)
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006bd4:	85d2                	mv	a1,s4
    80006bd6:	854e                	mv	a0,s3
    80006bd8:	8d1fb0ef          	jal	ra,800024a8 <sleep>
    semt.s[idx].waiters--;
    80006bdc:	48dc                	lw	a5,20(s1)
    80006bde:	37fd                	addiw	a5,a5,-1
    80006be0:	c8dc                	sw	a5,20(s1)
  while(semt.s[idx].val == 0){
    80006be2:	489c                	lw	a5,16(s1)
    80006be4:	d7ed                	beqz	a5,80006bce <sem_wait+0x5e>
  }

  semt.s[idx].val--;
    80006be6:	0024d517          	auipc	a0,0x24d
    80006bea:	1d250513          	addi	a0,a0,466 # 80253db8 <semt>
    80006bee:	0905                	addi	s2,s2,1
    80006bf0:	0912                	slli	s2,s2,0x4
    80006bf2:	992a                	add	s2,s2,a0
    80006bf4:	37fd                	addiw	a5,a5,-1
    80006bf6:	00f92823          	sw	a5,16(s2)
  release(&semt.lock);
    80006bfa:	94efa0ef          	jal	ra,80000d48 <release>
  return 0;
    80006bfe:	4501                	li	a0,0
}
    80006c00:	70a2                	ld	ra,40(sp)
    80006c02:	7402                	ld	s0,32(sp)
    80006c04:	64e2                	ld	s1,24(sp)
    80006c06:	6942                	ld	s2,16(sp)
    80006c08:	69a2                	ld	s3,8(sp)
    80006c0a:	6a02                	ld	s4,0(sp)
    80006c0c:	6145                	addi	sp,sp,48
    80006c0e:	8082                	ret
    release(&semt.lock);
    80006c10:	0024d517          	auipc	a0,0x24d
    80006c14:	1a850513          	addi	a0,a0,424 # 80253db8 <semt>
    80006c18:	930fa0ef          	jal	ra,80000d48 <release>
    return -1;
    80006c1c:	557d                	li	a0,-1
    80006c1e:	b7cd                	j	80006c00 <sem_wait+0x90>

0000000080006c20 <sem_post>:

int
sem_post(int key)
{
    80006c20:	1101                	addi	sp,sp,-32
    80006c22:	ec06                	sd	ra,24(sp)
    80006c24:	e822                	sd	s0,16(sp)
    80006c26:	e426                	sd	s1,8(sp)
    80006c28:	1000                	addi	s0,sp,32
    80006c2a:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006c2c:	0024d517          	auipc	a0,0x24d
    80006c30:	18c50513          	addi	a0,a0,396 # 80253db8 <semt>
    80006c34:	87cfa0ef          	jal	ra,80000cb0 <acquire>

  int idx = sem_lookup(key);
    80006c38:	8526                	mv	a0,s1
    80006c3a:	e4bff0ef          	jal	ra,80006a84 <sem_lookup>
  if(idx < 0){
    80006c3e:	02054a63          	bltz	a0,80006c72 <sem_post+0x52>
    release(&semt.lock);
    return -1;
  }

  semt.s[idx].val++;
    80006c42:	0024d497          	auipc	s1,0x24d
    80006c46:	17648493          	addi	s1,s1,374 # 80253db8 <semt>
    80006c4a:	0505                	addi	a0,a0,1
    80006c4c:	0512                	slli	a0,a0,0x4
    80006c4e:	00a48733          	add	a4,s1,a0
    80006c52:	4b1c                	lw	a5,16(a4)
    80006c54:	2785                	addiw	a5,a5,1
    80006c56:	cb1c                	sw	a5,16(a4)

  // 唤醒一个或全部：先做全部更简单也正确
  wakeup(&semt.s[idx]);
    80006c58:	0521                	addi	a0,a0,8
    80006c5a:	9526                	add	a0,a0,s1
    80006c5c:	899fb0ef          	jal	ra,800024f4 <wakeup>

  release(&semt.lock);
    80006c60:	8526                	mv	a0,s1
    80006c62:	8e6fa0ef          	jal	ra,80000d48 <release>
  return 0;
    80006c66:	4501                	li	a0,0
}
    80006c68:	60e2                	ld	ra,24(sp)
    80006c6a:	6442                	ld	s0,16(sp)
    80006c6c:	64a2                	ld	s1,8(sp)
    80006c6e:	6105                	addi	sp,sp,32
    80006c70:	8082                	ret
    release(&semt.lock);
    80006c72:	0024d517          	auipc	a0,0x24d
    80006c76:	14650513          	addi	a0,a0,326 # 80253db8 <semt>
    80006c7a:	8cefa0ef          	jal	ra,80000d48 <release>
    return -1;
    80006c7e:	557d                	li	a0,-1
    80006c80:	b7e5                	j	80006c68 <sem_post+0x48>

0000000080006c82 <sys_sem_open>:
#include "defs.h"


uint64
sys_sem_open(void)
{
    80006c82:	1101                	addi	sp,sp,-32
    80006c84:	ec06                	sd	ra,24(sp)
    80006c86:	e822                	sd	s0,16(sp)
    80006c88:	1000                	addi	s0,sp,32
  int key, init;
  argint(0, &key);
    80006c8a:	fec40593          	addi	a1,s0,-20
    80006c8e:	4501                	li	a0,0
    80006c90:	94efc0ef          	jal	ra,80002dde <argint>
  argint(1, &init);
    80006c94:	fe840593          	addi	a1,s0,-24
    80006c98:	4505                	li	a0,1
    80006c9a:	944fc0ef          	jal	ra,80002dde <argint>
  return sem_open(key, init);
    80006c9e:	fe842583          	lw	a1,-24(s0)
    80006ca2:	fec42503          	lw	a0,-20(s0)
    80006ca6:	e37ff0ef          	jal	ra,80006adc <sem_open>
}
    80006caa:	60e2                	ld	ra,24(sp)
    80006cac:	6442                	ld	s0,16(sp)
    80006cae:	6105                	addi	sp,sp,32
    80006cb0:	8082                	ret

0000000080006cb2 <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80006cb2:	1101                	addi	sp,sp,-32
    80006cb4:	ec06                	sd	ra,24(sp)
    80006cb6:	e822                	sd	s0,16(sp)
    80006cb8:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006cba:	fec40593          	addi	a1,s0,-20
    80006cbe:	4501                	li	a0,0
    80006cc0:	91efc0ef          	jal	ra,80002dde <argint>
  return sem_wait(key);
    80006cc4:	fec42503          	lw	a0,-20(s0)
    80006cc8:	ea9ff0ef          	jal	ra,80006b70 <sem_wait>
}
    80006ccc:	60e2                	ld	ra,24(sp)
    80006cce:	6442                	ld	s0,16(sp)
    80006cd0:	6105                	addi	sp,sp,32
    80006cd2:	8082                	ret

0000000080006cd4 <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80006cd4:	1101                	addi	sp,sp,-32
    80006cd6:	ec06                	sd	ra,24(sp)
    80006cd8:	e822                	sd	s0,16(sp)
    80006cda:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006cdc:	fec40593          	addi	a1,s0,-20
    80006ce0:	4501                	li	a0,0
    80006ce2:	8fcfc0ef          	jal	ra,80002dde <argint>
  return sem_post(key);
    80006ce6:	fec42503          	lw	a0,-20(s0)
    80006cea:	f37ff0ef          	jal	ra,80006c20 <sem_post>
}
    80006cee:	60e2                	ld	ra,24(sp)
    80006cf0:	6442                	ld	s0,16(sp)
    80006cf2:	6105                	addi	sp,sp,32
    80006cf4:	8082                	ret

0000000080006cf6 <vmstatsinit>:
  uint64 shm_faults;
} vmstats;

void
vmstatsinit(void)
{
    80006cf6:	1141                	addi	sp,sp,-16
    80006cf8:	e406                	sd	ra,8(sp)
    80006cfa:	e022                	sd	s0,0(sp)
    80006cfc:	0800                	addi	s0,sp,16
  initlock(&vmstats.lock, "vmstats");
    80006cfe:	00002597          	auipc	a1,0x2
    80006d02:	b8a58593          	addi	a1,a1,-1142 # 80008888 <syscalls+0x490>
    80006d06:	0024d517          	auipc	a0,0x24d
    80006d0a:	4ca50513          	addi	a0,a0,1226 # 802541d0 <vmstats>
    80006d0e:	f23f90ef          	jal	ra,80000c30 <initlock>
}
    80006d12:	60a2                	ld	ra,8(sp)
    80006d14:	6402                	ld	s0,0(sp)
    80006d16:	0141                	addi	sp,sp,16
    80006d18:	8082                	ret

0000000080006d1a <vmstats_snapshot>:

// 给 sys_vmstats 用：读出一份快照
void
vmstats_snapshot(struct vmstats_user *out)
{
    80006d1a:	1101                	addi	sp,sp,-32
    80006d1c:	ec06                	sd	ra,24(sp)
    80006d1e:	e822                	sd	s0,16(sp)
    80006d20:	e426                	sd	s1,8(sp)
    80006d22:	e04a                	sd	s2,0(sp)
    80006d24:	1000                	addi	s0,sp,32
    80006d26:	84aa                	mv	s1,a0
  acquire(&vmstats.lock);
    80006d28:	0024d917          	auipc	s2,0x24d
    80006d2c:	4a890913          	addi	s2,s2,1192 # 802541d0 <vmstats>
    80006d30:	854a                	mv	a0,s2
    80006d32:	f7ff90ef          	jal	ra,80000cb0 <acquire>
  out->cow_faults  = vmstats.cow_faults;
    80006d36:	01893783          	ld	a5,24(s2)
    80006d3a:	e09c                	sd	a5,0(s1)
  out->lazy_faults = vmstats.lazy_faults;
    80006d3c:	02093783          	ld	a5,32(s2)
    80006d40:	e49c                	sd	a5,8(s1)
  out->shm_faults  = vmstats.shm_faults;
    80006d42:	02893783          	ld	a5,40(s2)
    80006d46:	e89c                	sd	a5,16(s1)
  release(&vmstats.lock);
    80006d48:	854a                	mv	a0,s2
    80006d4a:	ffff90ef          	jal	ra,80000d48 <release>

  out->kalloc_cnt = kalloc_cnt;
    80006d4e:	00002797          	auipc	a5,0x2
    80006d52:	ba27b783          	ld	a5,-1118(a5) # 800088f0 <kalloc_cnt>
    80006d56:	ec9c                	sd	a5,24(s1)
  out->copyin_bytes = copyin_bytes;
    80006d58:	00002797          	auipc	a5,0x2
    80006d5c:	b907b783          	ld	a5,-1136(a5) # 800088e8 <copyin_bytes>
    80006d60:	f09c                	sd	a5,32(s1)
  out->copyout_bytes = copyout_bytes;
    80006d62:	00002797          	auipc	a5,0x2
    80006d66:	b7e7b783          	ld	a5,-1154(a5) # 800088e0 <copyout_bytes>
    80006d6a:	f49c                	sd	a5,40(s1)
}
    80006d6c:	60e2                	ld	ra,24(sp)
    80006d6e:	6442                	ld	s0,16(sp)
    80006d70:	64a2                	ld	s1,8(sp)
    80006d72:	6902                	ld	s2,0(sp)
    80006d74:	6105                	addi	sp,sp,32
    80006d76:	8082                	ret

0000000080006d78 <vmstats_inc_cow>:




// 给其他模块做计数：不追求绝对精确可以不加锁
void vmstats_inc_cow(void)  { acquire(&vmstats.lock); vmstats.cow_faults++;  release(&vmstats.lock); }
    80006d78:	1101                	addi	sp,sp,-32
    80006d7a:	ec06                	sd	ra,24(sp)
    80006d7c:	e822                	sd	s0,16(sp)
    80006d7e:	e426                	sd	s1,8(sp)
    80006d80:	1000                	addi	s0,sp,32
    80006d82:	0024d497          	auipc	s1,0x24d
    80006d86:	44e48493          	addi	s1,s1,1102 # 802541d0 <vmstats>
    80006d8a:	8526                	mv	a0,s1
    80006d8c:	f25f90ef          	jal	ra,80000cb0 <acquire>
    80006d90:	6c9c                	ld	a5,24(s1)
    80006d92:	0785                	addi	a5,a5,1
    80006d94:	ec9c                	sd	a5,24(s1)
    80006d96:	8526                	mv	a0,s1
    80006d98:	fb1f90ef          	jal	ra,80000d48 <release>
    80006d9c:	60e2                	ld	ra,24(sp)
    80006d9e:	6442                	ld	s0,16(sp)
    80006da0:	64a2                	ld	s1,8(sp)
    80006da2:	6105                	addi	sp,sp,32
    80006da4:	8082                	ret

0000000080006da6 <vmstats_inc_lazy>:
void vmstats_inc_lazy(void) { acquire(&vmstats.lock); vmstats.lazy_faults++; release(&vmstats.lock); }
    80006da6:	1101                	addi	sp,sp,-32
    80006da8:	ec06                	sd	ra,24(sp)
    80006daa:	e822                	sd	s0,16(sp)
    80006dac:	e426                	sd	s1,8(sp)
    80006dae:	1000                	addi	s0,sp,32
    80006db0:	0024d497          	auipc	s1,0x24d
    80006db4:	42048493          	addi	s1,s1,1056 # 802541d0 <vmstats>
    80006db8:	8526                	mv	a0,s1
    80006dba:	ef7f90ef          	jal	ra,80000cb0 <acquire>
    80006dbe:	709c                	ld	a5,32(s1)
    80006dc0:	0785                	addi	a5,a5,1
    80006dc2:	f09c                	sd	a5,32(s1)
    80006dc4:	8526                	mv	a0,s1
    80006dc6:	f83f90ef          	jal	ra,80000d48 <release>
    80006dca:	60e2                	ld	ra,24(sp)
    80006dcc:	6442                	ld	s0,16(sp)
    80006dce:	64a2                	ld	s1,8(sp)
    80006dd0:	6105                	addi	sp,sp,32
    80006dd2:	8082                	ret

0000000080006dd4 <vmstats_inc_shm>:
void vmstats_inc_shm(void)  { acquire(&vmstats.lock); vmstats.shm_faults++;  release(&vmstats.lock); }
    80006dd4:	1101                	addi	sp,sp,-32
    80006dd6:	ec06                	sd	ra,24(sp)
    80006dd8:	e822                	sd	s0,16(sp)
    80006dda:	e426                	sd	s1,8(sp)
    80006ddc:	1000                	addi	s0,sp,32
    80006dde:	0024d497          	auipc	s1,0x24d
    80006de2:	3f248493          	addi	s1,s1,1010 # 802541d0 <vmstats>
    80006de6:	8526                	mv	a0,s1
    80006de8:	ec9f90ef          	jal	ra,80000cb0 <acquire>
    80006dec:	749c                	ld	a5,40(s1)
    80006dee:	0785                	addi	a5,a5,1
    80006df0:	f49c                	sd	a5,40(s1)
    80006df2:	8526                	mv	a0,s1
    80006df4:	f55f90ef          	jal	ra,80000d48 <release>
    80006df8:	60e2                	ld	ra,24(sp)
    80006dfa:	6442                	ld	s0,16(sp)
    80006dfc:	64a2                	ld	s1,8(sp)
    80006dfe:	6105                	addi	sp,sp,32
    80006e00:	8082                	ret
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
