
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
    80000004:	85813103          	ld	sp,-1960(sp) # 80008858 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdaaaa7>
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
    8000010a:	45e020ef          	jal	ra,80002568 <either_copyin>
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
    80000176:	72e50513          	addi	a0,a0,1838 # 800108a0 <cons>
    8000017a:	327000ef          	jal	ra,80000ca0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	72248493          	addi	s1,s1,1826 # 800108a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	7b290913          	addi	s2,s2,1970 # 80010938 <cons+0x98>
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
    800001a4:	195010ef          	jal	ra,80001b38 <myproc>
    800001a8:	252020ef          	jal	ra,800023fa <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	010020ef          	jal	ra,800021c2 <sleep>
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
    800001ea:	334020ef          	jal	ra,8000251e <either_copyout>
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
    800001fe:	6a650513          	addi	a0,a0,1702 # 800108a0 <cons>
    80000202:	337000ef          	jal	ra,80000d38 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	69450513          	addi	a0,a0,1684 # 800108a0 <cons>
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
    80000242:	6ef72d23          	sw	a5,1786(a4) # 80010938 <cons+0x98>
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
    8000028c:	61850513          	addi	a0,a0,1560 # 800108a0 <cons>
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
    800002aa:	308020ef          	jal	ra,800025b2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	5f250513          	addi	a0,a0,1522 # 800108a0 <cons>
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
    800002d2:	5d270713          	addi	a4,a4,1490 # 800108a0 <cons>
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
    800002f8:	5ac78793          	addi	a5,a5,1452 # 800108a0 <cons>
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
    80000326:	6167a783          	lw	a5,1558(a5) # 80010938 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	56a70713          	addi	a4,a4,1386 # 800108a0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	55a48493          	addi	s1,s1,1370 # 800108a0 <cons>
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
    80000382:	52270713          	addi	a4,a4,1314 # 800108a0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	5af72623          	sw	a5,1452(a4) # 80010940 <cons+0xa0>
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
    800003b6:	4ee78793          	addi	a5,a5,1262 # 800108a0 <cons>
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
    800003da:	56c7a323          	sw	a2,1382(a5) # 8001093c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	55a50513          	addi	a0,a0,1370 # 80010938 <cons+0x98>
    800003e6:	629010ef          	jal	ra,8000220e <wakeup>
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
    80000400:	4a450513          	addi	a0,a0,1188 # 800108a0 <cons>
    80000404:	01d000ef          	jal	ra,80000c20 <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0024a797          	auipc	a5,0x24a
    80000410:	61c78793          	addi	a5,a5,1564 # 8024aa28 <devsw>
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
    800004f8:	3807a783          	lw	a5,896(a5) # 80008874 <panicking>
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
    80000536:	41650513          	addi	a0,a0,1046 # 80010948 <pr>
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
    80000754:	1247a783          	lw	a5,292(a5) # 80008874 <panicking>
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
    8000077e:	1ce50513          	addi	a0,a0,462 # 80010948 <pr>
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
    8000079c:	0d27ae23          	sw	s2,220(a5) # 80008874 <panicking>
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
    800007be:	0b27ab23          	sw	s2,182(a5) # 80008870 <panicked>
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
    800007d8:	17450513          	addi	a0,a0,372 # 80010948 <pr>
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
    80000824:	14050513          	addi	a0,a0,320 # 80010960 <tx_lock>
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
    80000852:	11250513          	addi	a0,a0,274 # 80010960 <tx_lock>
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
    80000872:	00e48493          	addi	s1,s1,14 # 8000887c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	00010997          	auipc	s3,0x10
    8000087a:	0ea98993          	addi	s3,s3,234 # 80010960 <tx_lock>
    8000087e:	00008917          	auipc	s2,0x8
    80000882:	ffa90913          	addi	s2,s2,-6 # 80008878 <tx_chan>
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
    80000892:	131010ef          	jal	ra,800021c2 <sleep>
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
    800008b6:	0ae50513          	addi	a0,a0,174 # 80010960 <tx_lock>
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
    800008e4:	f947a783          	lw	a5,-108(a5) # 80008874 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	f867a783          	lw	a5,-122(a5) # 80008870 <panicked>
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
    8000091a:	f5e7a783          	lw	a5,-162(a5) # 80008874 <panicking>
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
    8000096a:	ffa50513          	addi	a0,a0,-6 # 80010960 <tx_lock>
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
    80000980:	fe450513          	addi	a0,a0,-28 # 80010960 <tx_lock>
    80000984:	3b4000ef          	jal	ra,80000d38 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00008797          	auipc	a5,0x8
    80000990:	ee07a823          	sw	zero,-272(a5) # 8000887c <tx_busy>
    wakeup(&tx_chan);
    80000994:	00008517          	auipc	a0,0x8
    80000998:	ee450513          	addi	a0,a0,-284 # 80008878 <tx_chan>
    8000099c:	073010ef          	jal	ra,8000220e <wakeup>
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
    800009c8:	fd450513          	addi	a0,a0,-44 # 80010998 <kref>
    800009cc:	2d4000ef          	jal	ra,80000ca0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d0:	00010517          	auipc	a0,0x10
    800009d4:	fc850513          	addi	a0,a0,-56 # 80010998 <kref>
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
    80000a02:	f9a50513          	addi	a0,a0,-102 # 80010998 <kref>
    80000a06:	29a000ef          	jal	ra,80000ca0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0a:	00c4d793          	srli	a5,s1,0xc
    80000a0e:	00010517          	auipc	a0,0x10
    80000a12:	f8a50513          	addi	a0,a0,-118 # 80010998 <kref>
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
    80000a46:	f5650513          	addi	a0,a0,-170 # 80010998 <kref>
    80000a4a:	256000ef          	jal	ra,80000ca0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a4e:	00c4d793          	srli	a5,s1,0xc
    80000a52:	00010517          	auipc	a0,0x10
    80000a56:	f4650513          	addi	a0,a0,-186 # 80010998 <kref>
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
    80000a92:	2ca78793          	addi	a5,a5,714 # 80253d58 <end>
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
    80000ad0:	eac90913          	addi	s2,s2,-340 # 80010978 <kmem>
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
    80000b1a:	e8290913          	addi	s2,s2,-382 # 80010998 <kref>
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
    80000b76:	e0650513          	addi	a0,a0,-506 # 80010978 <kmem>
    80000b7a:	0a6000ef          	jal	ra,80000c20 <initlock>
  initlock(&kref.lock, "kref");
    80000b7e:	00007597          	auipc	a1,0x7
    80000b82:	4ea58593          	addi	a1,a1,1258 # 80008068 <digits+0x30>
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	e1250513          	addi	a0,a0,-494 # 80010998 <kref>
    80000b8e:	092000ef          	jal	ra,80000c20 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b92:	45c5                	li	a1,17
    80000b94:	05ee                	slli	a1,a1,0x1b
    80000b96:	00253517          	auipc	a0,0x253
    80000b9a:	1c250513          	addi	a0,a0,450 # 80253d58 <end>
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
    80000bb8:	dc448493          	addi	s1,s1,-572 # 80010978 <kmem>
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	0e2000ef          	jal	ra,80000ca0 <acquire>
  r = kmem.freelist;
    80000bc2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc4:	c4b9                	beqz	s1,80000c12 <kalloc+0x68>
    kmem.freelist = r->next;
    80000bc6:	609c                	ld	a5,0(s1)
    80000bc8:	00010517          	auipc	a0,0x10
    80000bcc:	db050513          	addi	a0,a0,-592 # 80010978 <kmem>
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
    80000be4:	db850513          	addi	a0,a0,-584 # 80010998 <kref>
    80000be8:	0b8000ef          	jal	ra,80000ca0 <acquire>
  kref.refcnt[PA2IDX(r)] = 1;
    80000bec:	00010517          	auipc	a0,0x10
    80000bf0:	dac50513          	addi	a0,a0,-596 # 80010998 <kref>
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
    80000c16:	d6650513          	addi	a0,a0,-666 # 80010978 <kmem>
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
    80000c4a:	6d3000ef          	jal	ra,80001b1c <mycpu>
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
    80000c78:	6a5000ef          	jal	ra,80001b1c <mycpu>
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	cb99                	beqz	a5,80000c94 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c80:	69d000ef          	jal	ra,80001b1c <mycpu>
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
    80000c94:	689000ef          	jal	ra,80001b1c <mycpu>
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
    80000cc8:	655000ef          	jal	ra,80001b1c <mycpu>
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
    80000cec:	631000ef          	jal	ra,80001b1c <mycpu>
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
    80000de8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fdab2a9>
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
    80000f1e:	3ef000ef          	jal	ra,80001b0c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f22:	00008717          	auipc	a4,0x8
    80000f26:	95e70713          	addi	a4,a4,-1698 # 80008880 <started>
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
    80000f36:	3d7000ef          	jal	ra,80001b0c <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	17c50513          	addi	a0,a0,380 # 800080b8 <digits+0x80>
    80000f44:	d7eff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000f48:	080000ef          	jal	ra,80000fc8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	798010ef          	jal	ra,800026e4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	3d5040ef          	jal	ra,80005b24 <plicinithart>
  }

  scheduler();        
    80000f54:	0d6010ef          	jal	ra,8000202a <scheduler>
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
    80000f90:	2d5000ef          	jal	ra,80001a64 <procinit>
    trapinit();      // trap vectors
    80000f94:	72c010ef          	jal	ra,800026c0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	74c010ef          	jal	ra,800026e4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	373040ef          	jal	ra,80005b0e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	385040ef          	jal	ra,80005b24 <plicinithart>
    binit();         // buffer cache
    80000fa4:	2d6020ef          	jal	ra,8000327a <binit>
    iinit();         // inode table
    80000fa8:	047020ef          	jal	ra,800037ee <iinit>
    fileinit();      // file table
    80000fac:	72e030ef          	jal	ra,800046da <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	465040ef          	jal	ra,80005c14 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	6b1000ef          	jal	ra,80001e64 <userinit>
    __sync_synchronize();
    80000fb8:	0ff0000f          	fence
    started = 1;
    80000fbc:	4785                	li	a5,1
    80000fbe:	00008717          	auipc	a4,0x8
    80000fc2:	8cf72123          	sw	a5,-1854(a4) # 80008880 <started>
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
    80000fd6:	8b67b783          	ld	a5,-1866(a5) # 80008888 <kernel_pagetable>
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
    80001240:	79a000ef          	jal	ra,800019da <proc_mapstacks>
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
    80001262:	62a7b523          	sd	a0,1578(a5) # 80008888 <kernel_pagetable>
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
    80001652:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdab2a8>
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
    8000170c:	42c000ef          	jal	ra,80001b38 <myproc>
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
    8000176a:	cec5                	beqz	a3,80001822 <copyout+0xb8>
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
    80001788:	8a2a                	mv	s4,a0
    8000178a:	8aae                	mv	s5,a1
    8000178c:	8b32                	mv	s6,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001790:	74fd                	lui	s1,0xfffff
    80001792:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001794:	57fd                	li	a5,-1
    80001796:	83e9                	srli	a5,a5,0x1a
    80001798:	0897e763          	bltu	a5,s1,80001826 <copyout+0xbc>
    8000179c:	6c05                	lui	s8,0x1
    8000179e:	8bbe                	mv	s7,a5
    800017a0:	a825                	j	800017d8 <copyout+0x6e>
    if((*pte & PTE_W) == 0)
    800017a2:	611c                	ld	a5,0(a0)
    800017a4:	8b91                	andi	a5,a5,4
    800017a6:	cbc1                	beqz	a5,80001836 <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    800017a8:	01848d33          	add	s10,s1,s8
    800017ac:	415d0cb3          	sub	s9,s10,s5
    800017b0:	0199f363          	bgeu	s3,s9,800017b6 <copyout+0x4c>
    800017b4:	8cce                	mv	s9,s3
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017b6:	409a8533          	sub	a0,s5,s1
    800017ba:	000c861b          	sext.w	a2,s9
    800017be:	85da                	mv	a1,s6
    800017c0:	954a                	add	a0,a0,s2
    800017c2:	e0eff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    800017c6:	419989b3          	sub	s3,s3,s9
    src += n;
    800017ca:	9b66                	add	s6,s6,s9
  while(len > 0){
    800017cc:	04098963          	beqz	s3,8000181e <copyout+0xb4>
    if(va0 >= MAXVA)
    800017d0:	05abed63          	bltu	s7,s10,8000182a <copyout+0xc0>
    va0 = PGROUNDDOWN(dstva);
    800017d4:	84ea                	mv	s1,s10
    dstva = va0 + PGSIZE;
    800017d6:	8aea                	mv	s5,s10
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85a6                	mv	a1,s1
    800017da:	8552                	mv	a0,s4
    800017dc:	8afff0ef          	jal	ra,8000108a <walkaddr>
    800017e0:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800017e2:	e901                	bnez	a0,800017f2 <copyout+0x88>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800017e4:	4601                	li	a2,0
    800017e6:	85a6                	mv	a1,s1
    800017e8:	8552                	mv	a0,s4
    800017ea:	f0fff0ef          	jal	ra,800016f8 <vmfault>
    800017ee:	892a                	mv	s2,a0
    800017f0:	cd1d                	beqz	a0,8000182e <copyout+0xc4>
    pte = walk(pagetable, va0, 0);
    800017f2:	4601                	li	a2,0
    800017f4:	85a6                	mv	a1,s1
    800017f6:	8552                	mv	a0,s4
    800017f8:	ff8ff0ef          	jal	ra,80000ff0 <walk>
    if(pte && (*pte & PTE_COW)){
    800017fc:	d15d                	beqz	a0,800017a2 <copyout+0x38>
    800017fe:	611c                	ld	a5,0(a0)
    80001800:	1007f793          	andi	a5,a5,256
    80001804:	dfd9                	beqz	a5,800017a2 <copyout+0x38>
      if(cowbreak(pagetable, va0) < 0)
    80001806:	85a6                	mv	a1,s1
    80001808:	8552                	mv	a0,s4
    8000180a:	d37ff0ef          	jal	ra,80001540 <cowbreak>
    8000180e:	02054263          	bltz	a0,80001832 <copyout+0xc8>
      pte = walk(pagetable, va0, 0);
    80001812:	4601                	li	a2,0
    80001814:	85a6                	mv	a1,s1
    80001816:	8552                	mv	a0,s4
    80001818:	fd8ff0ef          	jal	ra,80000ff0 <walk>
    8000181c:	b759                	j	800017a2 <copyout+0x38>
  return 0;
    8000181e:	4501                	li	a0,0
    80001820:	a821                	j	80001838 <copyout+0xce>
    80001822:	4501                	li	a0,0
}
    80001824:	8082                	ret
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	a801                	j	80001838 <copyout+0xce>
    8000182a:	557d                	li	a0,-1
    8000182c:	a031                	j	80001838 <copyout+0xce>
        return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	a021                	j	80001838 <copyout+0xce>
        return -1;
    80001832:	557d                	li	a0,-1
    80001834:	a011                	j	80001838 <copyout+0xce>
      return -1;
    80001836:	557d                	li	a0,-1
}
    80001838:	60e6                	ld	ra,88(sp)
    8000183a:	6446                	ld	s0,80(sp)
    8000183c:	64a6                	ld	s1,72(sp)
    8000183e:	6906                	ld	s2,64(sp)
    80001840:	79e2                	ld	s3,56(sp)
    80001842:	7a42                	ld	s4,48(sp)
    80001844:	7aa2                	ld	s5,40(sp)
    80001846:	7b02                	ld	s6,32(sp)
    80001848:	6be2                	ld	s7,24(sp)
    8000184a:	6c42                	ld	s8,16(sp)
    8000184c:	6ca2                	ld	s9,8(sp)
    8000184e:	6d02                	ld	s10,0(sp)
    80001850:	6125                	addi	sp,sp,96
    80001852:	8082                	ret

0000000080001854 <copyin>:
  while(len > 0){
    80001854:	c6c9                	beqz	a3,800018de <copyin+0x8a>
{
    80001856:	715d                	addi	sp,sp,-80
    80001858:	e486                	sd	ra,72(sp)
    8000185a:	e0a2                	sd	s0,64(sp)
    8000185c:	fc26                	sd	s1,56(sp)
    8000185e:	f84a                	sd	s2,48(sp)
    80001860:	f44e                	sd	s3,40(sp)
    80001862:	f052                	sd	s4,32(sp)
    80001864:	ec56                	sd	s5,24(sp)
    80001866:	e85a                	sd	s6,16(sp)
    80001868:	e45e                	sd	s7,8(sp)
    8000186a:	e062                	sd	s8,0(sp)
    8000186c:	0880                	addi	s0,sp,80
    8000186e:	8baa                	mv	s7,a0
    80001870:	8aae                	mv	s5,a1
    80001872:	8932                	mv	s2,a2
    80001874:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001876:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001878:	6b05                	lui	s6,0x1
    8000187a:	a035                	j	800018a6 <copyin+0x52>
    8000187c:	412984b3          	sub	s1,s3,s2
    80001880:	94da                	add	s1,s1,s6
    80001882:	009a7363          	bgeu	s4,s1,80001888 <copyin+0x34>
    80001886:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001888:	413905b3          	sub	a1,s2,s3
    8000188c:	0004861b          	sext.w	a2,s1
    80001890:	95aa                	add	a1,a1,a0
    80001892:	8556                	mv	a0,s5
    80001894:	d3cff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    80001898:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000189c:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000189e:	01698933          	add	s2,s3,s6
  while(len > 0){
    800018a2:	020a0163          	beqz	s4,800018c4 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    800018a6:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800018aa:	85ce                	mv	a1,s3
    800018ac:	855e                	mv	a0,s7
    800018ae:	fdcff0ef          	jal	ra,8000108a <walkaddr>
    if(pa0 == 0) {
    800018b2:	f569                	bnez	a0,8000187c <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800018b4:	4601                	li	a2,0
    800018b6:	85ce                	mv	a1,s3
    800018b8:	855e                	mv	a0,s7
    800018ba:	e3fff0ef          	jal	ra,800016f8 <vmfault>
    800018be:	fd5d                	bnez	a0,8000187c <copyin+0x28>
        return -1;
    800018c0:	557d                	li	a0,-1
    800018c2:	a011                	j	800018c6 <copyin+0x72>
  return 0;
    800018c4:	4501                	li	a0,0
}
    800018c6:	60a6                	ld	ra,72(sp)
    800018c8:	6406                	ld	s0,64(sp)
    800018ca:	74e2                	ld	s1,56(sp)
    800018cc:	7942                	ld	s2,48(sp)
    800018ce:	79a2                	ld	s3,40(sp)
    800018d0:	7a02                	ld	s4,32(sp)
    800018d2:	6ae2                	ld	s5,24(sp)
    800018d4:	6b42                	ld	s6,16(sp)
    800018d6:	6ba2                	ld	s7,8(sp)
    800018d8:	6c02                	ld	s8,0(sp)
    800018da:	6161                	addi	sp,sp,80
    800018dc:	8082                	ret
  return 0;
    800018de:	4501                	li	a0,0
}
    800018e0:	8082                	ret

00000000800018e2 <vmafault>:


uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    800018e2:	7139                	addi	sp,sp,-64
    800018e4:	fc06                	sd	ra,56(sp)
    800018e6:	f822                	sd	s0,48(sp)
    800018e8:	f426                	sd	s1,40(sp)
    800018ea:	f04a                	sd	s2,32(sp)
    800018ec:	ec4e                	sd	s3,24(sp)
    800018ee:	e852                	sd	s4,16(sp)
    800018f0:	e456                	sd	s5,8(sp)
    800018f2:	0080                	addi	s0,sp,64
    800018f4:	8a2a                	mv	s4,a0
    800018f6:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);
    800018f8:	77fd                	lui	a5,0xfffff
    800018fa:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va);
    800018fe:	85ce                	mv	a1,s3
    80001900:	4aa010ef          	jal	ra,80002daa <vma_find>
  if(v == 0) return 0;
    80001904:	c569                	beqz	a0,800019ce <vmafault+0xec>
    80001906:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001908:	00090663          	beqz	s2,80001914 <vmafault+0x32>
    8000190c:	4d1c                	lw	a5,24(a0)
    8000190e:	8b89                	andi	a5,a5,2
    return 0;
    80001910:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001912:	c789                	beqz	a5,8000191c <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0)
    80001914:	4c9c                	lw	a5,24(s1)
    80001916:	8b85                	andi	a5,a5,1
    return 0;
    80001918:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0)
    8000191a:	eb99                	bnez	a5,80001930 <vmafault+0x4e>
    if(v->is_shm) kref_dec((void*)pa);
    else kfree((void*)pa);
    return 0;
  }
  return (uint64)pa;
}
    8000191c:	854a                	mv	a0,s2
    8000191e:	70e2                	ld	ra,56(sp)
    80001920:	7442                	ld	s0,48(sp)
    80001922:	74a2                	ld	s1,40(sp)
    80001924:	7902                	ld	s2,32(sp)
    80001926:	69e2                	ld	s3,24(sp)
    80001928:	6a42                	ld	s4,16(sp)
    8000192a:	6aa2                	ld	s5,8(sp)
    8000192c:	6121                	addi	sp,sp,64
    8000192e:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    80001930:	4601                	li	a2,0
    80001932:	85ce                	mv	a1,s3
    80001934:	050a3503          	ld	a0,80(s4)
    80001938:	eb8ff0ef          	jal	ra,80000ff0 <walk>
  if(pte && (*pte & PTE_V)){
    8000193c:	c115                	beqz	a0,80001960 <vmafault+0x7e>
    8000193e:	611c                	ld	a5,0(a0)
    80001940:	0017f913          	andi	s2,a5,1
    80001944:	00090e63          	beqz	s2,80001960 <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    80001948:	4c98                	lw	a4,24(s1)
    8000194a:	8b09                	andi	a4,a4,2
    8000194c:	c359                	beqz	a4,800019d2 <vmafault+0xf0>
    8000194e:	0047f713          	andi	a4,a5,4
    80001952:	e351                	bnez	a4,800019d6 <vmafault+0xf4>
      *pte |= PTE_W;
    80001954:	0047e793          	ori	a5,a5,4
    80001958:	e11c                	sd	a5,0(a0)
    8000195a:	12000073          	sfence.vma
      return 1;
    8000195e:	bf7d                	j	8000191c <vmafault+0x3a>
  int idx = (va - v->start) / PGSIZE;
    80001960:	648c                	ld	a1,8(s1)
  if(v->is_shm){
    80001962:	509c                	lw	a5,32(s1)
    80001964:	cf89                	beqz	a5,8000197e <vmafault+0x9c>
  int idx = (va - v->start) / PGSIZE;
    80001966:	40b985b3          	sub	a1,s3,a1
    8000196a:	81b1                	srli	a1,a1,0xc
    pa = shm_getpa(v->shm_key, idx);
    8000196c:	2581                	sext.w	a1,a1
    8000196e:	50c8                	lw	a0,36(s1)
    80001970:	157040ef          	jal	ra,800062c6 <shm_getpa>
    80001974:	892a                	mv	s2,a0
    if(pa == 0) return 0;
    80001976:	d15d                	beqz	a0,8000191c <vmafault+0x3a>
    kref_inc((void*)pa);
    80001978:	87aff0ef          	jal	ra,800009f2 <kref_inc>
    8000197c:	a819                	j	80001992 <vmafault+0xb0>
    char *mem = kalloc();
    8000197e:	a2cff0ef          	jal	ra,80000baa <kalloc>
    80001982:	8aaa                	mv	s5,a0
    if(mem == 0) return 0;
    80001984:	4901                	li	s2,0
    80001986:	d959                	beqz	a0,8000191c <vmafault+0x3a>
    memset(mem, 0, PGSIZE);
    80001988:	6605                	lui	a2,0x1
    8000198a:	4581                	li	a1,0
    8000198c:	be8ff0ef          	jal	ra,80000d74 <memset>
    pa = (uint64)mem;
    80001990:	8956                	mv	s2,s5
  if(v->prot & PROT_READ)  perm |= PTE_R;
    80001992:	4c9c                	lw	a5,24(s1)
    80001994:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;
    80001998:	4741                	li	a4,16
  if(v->prot & PROT_READ)  perm |= PTE_R;
    8000199a:	c291                	beqz	a3,8000199e <vmafault+0xbc>
    8000199c:	4749                	li	a4,18
  if(v->prot & PROT_WRITE) perm |= PTE_W;
    8000199e:	8b89                	andi	a5,a5,2
    800019a0:	c399                	beqz	a5,800019a6 <vmafault+0xc4>
    800019a2:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    800019a6:	86ca                	mv	a3,s2
    800019a8:	6605                	lui	a2,0x1
    800019aa:	85ce                	mv	a1,s3
    800019ac:	050a3503          	ld	a0,80(s4)
    800019b0:	f18ff0ef          	jal	ra,800010c8 <mappages>
    800019b4:	d525                	beqz	a0,8000191c <vmafault+0x3a>
    if(v->is_shm) kref_dec((void*)pa);
    800019b6:	509c                	lw	a5,32(s1)
    800019b8:	c791                	beqz	a5,800019c4 <vmafault+0xe2>
    800019ba:	854a                	mv	a0,s2
    800019bc:	87aff0ef          	jal	ra,80000a36 <kref_dec>
    return 0;
    800019c0:	4901                	li	s2,0
    800019c2:	bfa9                	j	8000191c <vmafault+0x3a>
    else kfree((void*)pa);
    800019c4:	854a                	mv	a0,s2
    800019c6:	8b4ff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    800019ca:	4901                	li	s2,0
    800019cc:	bf81                	j	8000191c <vmafault+0x3a>
  if(v == 0) return 0;
    800019ce:	4901                	li	s2,0
    800019d0:	b7b1                	j	8000191c <vmafault+0x3a>
    return 0;
    800019d2:	4901                	li	s2,0
    800019d4:	b7a1                	j	8000191c <vmafault+0x3a>
    800019d6:	4901                	li	s2,0
    800019d8:	b791                	j	8000191c <vmafault+0x3a>

00000000800019da <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800019da:	7139                	addi	sp,sp,-64
    800019dc:	fc06                	sd	ra,56(sp)
    800019de:	f822                	sd	s0,48(sp)
    800019e0:	f426                	sd	s1,40(sp)
    800019e2:	f04a                	sd	s2,32(sp)
    800019e4:	ec4e                	sd	s3,24(sp)
    800019e6:	e852                	sd	s4,16(sp)
    800019e8:	e456                	sd	s5,8(sp)
    800019ea:	e05a                	sd	s6,0(sp)
    800019ec:	0080                	addi	s0,sp,64
    800019ee:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800019f0:	0022f497          	auipc	s1,0x22f
    800019f4:	3f048493          	addi	s1,s1,1008 # 80230de0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800019f8:	8b26                	mv	s6,s1
    800019fa:	00006a97          	auipc	s5,0x6
    800019fe:	606a8a93          	addi	s5,s5,1542 # 80008000 <etext>
    80001a02:	04000937          	lui	s2,0x4000
    80001a06:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a08:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a0a:	0023fa17          	auipc	s4,0x23f
    80001a0e:	dd6a0a13          	addi	s4,s4,-554 # 802407e0 <tickslock>
    char *pa = kalloc();
    80001a12:	998ff0ef          	jal	ra,80000baa <kalloc>
    80001a16:	862a                	mv	a2,a0
    if(pa == 0)
    80001a18:	c121                	beqz	a0,80001a58 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001a1a:	416485b3          	sub	a1,s1,s6
    80001a1e:	858d                	srai	a1,a1,0x3
    80001a20:	000ab783          	ld	a5,0(s5)
    80001a24:	02f585b3          	mul	a1,a1,a5
    80001a28:	2585                	addiw	a1,a1,1
    80001a2a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a2e:	4719                	li	a4,6
    80001a30:	6685                	lui	a3,0x1
    80001a32:	40b905b3          	sub	a1,s2,a1
    80001a36:	854e                	mv	a0,s3
    80001a38:	f40ff0ef          	jal	ra,80001178 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a3c:	3e848493          	addi	s1,s1,1000
    80001a40:	fd4499e3          	bne	s1,s4,80001a12 <proc_mapstacks+0x38>
  }
}
    80001a44:	70e2                	ld	ra,56(sp)
    80001a46:	7442                	ld	s0,48(sp)
    80001a48:	74a2                	ld	s1,40(sp)
    80001a4a:	7902                	ld	s2,32(sp)
    80001a4c:	69e2                	ld	s3,24(sp)
    80001a4e:	6a42                	ld	s4,16(sp)
    80001a50:	6aa2                	ld	s5,8(sp)
    80001a52:	6b02                	ld	s6,0(sp)
    80001a54:	6121                	addi	sp,sp,64
    80001a56:	8082                	ret
      panic("kalloc");
    80001a58:	00006517          	auipc	a0,0x6
    80001a5c:	72050513          	addi	a0,a0,1824 # 80008178 <digits+0x140>
    80001a60:	d29fe0ef          	jal	ra,80000788 <panic>

0000000080001a64 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a64:	7139                	addi	sp,sp,-64
    80001a66:	fc06                	sd	ra,56(sp)
    80001a68:	f822                	sd	s0,48(sp)
    80001a6a:	f426                	sd	s1,40(sp)
    80001a6c:	f04a                	sd	s2,32(sp)
    80001a6e:	ec4e                	sd	s3,24(sp)
    80001a70:	e852                	sd	s4,16(sp)
    80001a72:	e456                	sd	s5,8(sp)
    80001a74:	e05a                	sd	s6,0(sp)
    80001a76:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a78:	00006597          	auipc	a1,0x6
    80001a7c:	70858593          	addi	a1,a1,1800 # 80008180 <digits+0x148>
    80001a80:	0022f517          	auipc	a0,0x22f
    80001a84:	f3050513          	addi	a0,a0,-208 # 802309b0 <pid_lock>
    80001a88:	998ff0ef          	jal	ra,80000c20 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a8c:	00006597          	auipc	a1,0x6
    80001a90:	6fc58593          	addi	a1,a1,1788 # 80008188 <digits+0x150>
    80001a94:	0022f517          	auipc	a0,0x22f
    80001a98:	f3450513          	addi	a0,a0,-204 # 802309c8 <wait_lock>
    80001a9c:	984ff0ef          	jal	ra,80000c20 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aa0:	0022f497          	auipc	s1,0x22f
    80001aa4:	34048493          	addi	s1,s1,832 # 80230de0 <proc>
      initlock(&p->lock, "proc");
    80001aa8:	00006b17          	auipc	s6,0x6
    80001aac:	6f0b0b13          	addi	s6,s6,1776 # 80008198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001ab0:	8aa6                	mv	s5,s1
    80001ab2:	00006a17          	auipc	s4,0x6
    80001ab6:	54ea0a13          	addi	s4,s4,1358 # 80008000 <etext>
    80001aba:	04000937          	lui	s2,0x4000
    80001abe:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ac0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ac2:	0023f997          	auipc	s3,0x23f
    80001ac6:	d1e98993          	addi	s3,s3,-738 # 802407e0 <tickslock>
      initlock(&p->lock, "proc");
    80001aca:	85da                	mv	a1,s6
    80001acc:	8526                	mv	a0,s1
    80001ace:	952ff0ef          	jal	ra,80000c20 <initlock>
      p->state = UNUSED;
    80001ad2:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001ad6:	415487b3          	sub	a5,s1,s5
    80001ada:	878d                	srai	a5,a5,0x3
    80001adc:	000a3703          	ld	a4,0(s4)
    80001ae0:	02e787b3          	mul	a5,a5,a4
    80001ae4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdab2a9>
    80001ae6:	00d7979b          	slliw	a5,a5,0xd
    80001aea:	40f907b3          	sub	a5,s2,a5
    80001aee:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001af0:	3e848493          	addi	s1,s1,1000
    80001af4:	fd349be3          	bne	s1,s3,80001aca <procinit+0x66>
  }
}
    80001af8:	70e2                	ld	ra,56(sp)
    80001afa:	7442                	ld	s0,48(sp)
    80001afc:	74a2                	ld	s1,40(sp)
    80001afe:	7902                	ld	s2,32(sp)
    80001b00:	69e2                	ld	s3,24(sp)
    80001b02:	6a42                	ld	s4,16(sp)
    80001b04:	6aa2                	ld	s5,8(sp)
    80001b06:	6b02                	ld	s6,0(sp)
    80001b08:	6121                	addi	sp,sp,64
    80001b0a:	8082                	ret

0000000080001b0c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b0c:	1141                	addi	sp,sp,-16
    80001b0e:	e422                	sd	s0,8(sp)
    80001b10:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b12:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b14:	2501                	sext.w	a0,a0
    80001b16:	6422                	ld	s0,8(sp)
    80001b18:	0141                	addi	sp,sp,16
    80001b1a:	8082                	ret

0000000080001b1c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001b1c:	1141                	addi	sp,sp,-16
    80001b1e:	e422                	sd	s0,8(sp)
    80001b20:	0800                	addi	s0,sp,16
    80001b22:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b24:	2781                	sext.w	a5,a5
    80001b26:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b28:	0022f517          	auipc	a0,0x22f
    80001b2c:	eb850513          	addi	a0,a0,-328 # 802309e0 <cpus>
    80001b30:	953e                	add	a0,a0,a5
    80001b32:	6422                	ld	s0,8(sp)
    80001b34:	0141                	addi	sp,sp,16
    80001b36:	8082                	ret

0000000080001b38 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b38:	1101                	addi	sp,sp,-32
    80001b3a:	ec06                	sd	ra,24(sp)
    80001b3c:	e822                	sd	s0,16(sp)
    80001b3e:	e426                	sd	s1,8(sp)
    80001b40:	1000                	addi	s0,sp,32
  push_off();
    80001b42:	91eff0ef          	jal	ra,80000c60 <push_off>
    80001b46:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b48:	2781                	sext.w	a5,a5
    80001b4a:	079e                	slli	a5,a5,0x7
    80001b4c:	0022f717          	auipc	a4,0x22f
    80001b50:	e6470713          	addi	a4,a4,-412 # 802309b0 <pid_lock>
    80001b54:	97ba                	add	a5,a5,a4
    80001b56:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b58:	98cff0ef          	jal	ra,80000ce4 <pop_off>
  return p;
}
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	60e2                	ld	ra,24(sp)
    80001b60:	6442                	ld	s0,16(sp)
    80001b62:	64a2                	ld	s1,8(sp)
    80001b64:	6105                	addi	sp,sp,32
    80001b66:	8082                	ret

0000000080001b68 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b68:	7179                	addi	sp,sp,-48
    80001b6a:	f406                	sd	ra,40(sp)
    80001b6c:	f022                	sd	s0,32(sp)
    80001b6e:	ec26                	sd	s1,24(sp)
    80001b70:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b72:	fc7ff0ef          	jal	ra,80001b38 <myproc>
    80001b76:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b78:	9c0ff0ef          	jal	ra,80000d38 <release>

  if (first) {
    80001b7c:	00007797          	auipc	a5,0x7
    80001b80:	cc47a783          	lw	a5,-828(a5) # 80008840 <first.1>
    80001b84:	cf8d                	beqz	a5,80001bbe <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b86:	4505                	li	a0,1
    80001b88:	118020ef          	jal	ra,80003ca0 <fsinit>

    first = 0;
    80001b8c:	00007797          	auipc	a5,0x7
    80001b90:	ca07aa23          	sw	zero,-844(a5) # 80008840 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b94:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b98:	00006517          	auipc	a0,0x6
    80001b9c:	60850513          	addi	a0,a0,1544 # 800081a0 <digits+0x168>
    80001ba0:	fca43823          	sd	a0,-48(s0)
    80001ba4:	fc043c23          	sd	zero,-40(s0)
    80001ba8:	fd040593          	addi	a1,s0,-48
    80001bac:	1a2030ef          	jal	ra,80004d4e <kexec>
    80001bb0:	6cbc                	ld	a5,88(s1)
    80001bb2:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001bb4:	6cbc                	ld	a5,88(s1)
    80001bb6:	7bb8                	ld	a4,112(a5)
    80001bb8:	57fd                	li	a5,-1
    80001bba:	02f70d63          	beq	a4,a5,80001bf4 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001bbe:	33f000ef          	jal	ra,800026fc <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001bc2:	68a8                	ld	a0,80(s1)
    80001bc4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001bc6:	04000737          	lui	a4,0x4000
    80001bca:	00005797          	auipc	a5,0x5
    80001bce:	4d278793          	addi	a5,a5,1234 # 8000709c <userret>
    80001bd2:	00005697          	auipc	a3,0x5
    80001bd6:	42e68693          	addi	a3,a3,1070 # 80007000 <_trampoline>
    80001bda:	8f95                	sub	a5,a5,a3
    80001bdc:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001bde:	0732                	slli	a4,a4,0xc
    80001be0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001be2:	577d                	li	a4,-1
    80001be4:	177e                	slli	a4,a4,0x3f
    80001be6:	8d59                	or	a0,a0,a4
    80001be8:	9782                	jalr	a5
}
    80001bea:	70a2                	ld	ra,40(sp)
    80001bec:	7402                	ld	s0,32(sp)
    80001bee:	64e2                	ld	s1,24(sp)
    80001bf0:	6145                	addi	sp,sp,48
    80001bf2:	8082                	ret
      panic("exec");
    80001bf4:	00006517          	auipc	a0,0x6
    80001bf8:	5b450513          	addi	a0,a0,1460 # 800081a8 <digits+0x170>
    80001bfc:	b8dfe0ef          	jal	ra,80000788 <panic>

0000000080001c00 <allocpid>:
{
    80001c00:	1101                	addi	sp,sp,-32
    80001c02:	ec06                	sd	ra,24(sp)
    80001c04:	e822                	sd	s0,16(sp)
    80001c06:	e426                	sd	s1,8(sp)
    80001c08:	e04a                	sd	s2,0(sp)
    80001c0a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c0c:	0022f917          	auipc	s2,0x22f
    80001c10:	da490913          	addi	s2,s2,-604 # 802309b0 <pid_lock>
    80001c14:	854a                	mv	a0,s2
    80001c16:	88aff0ef          	jal	ra,80000ca0 <acquire>
  pid = nextpid;
    80001c1a:	00007797          	auipc	a5,0x7
    80001c1e:	c2a78793          	addi	a5,a5,-982 # 80008844 <nextpid>
    80001c22:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c24:	0014871b          	addiw	a4,s1,1
    80001c28:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c2a:	854a                	mv	a0,s2
    80001c2c:	90cff0ef          	jal	ra,80000d38 <release>
}
    80001c30:	8526                	mv	a0,s1
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6902                	ld	s2,0(sp)
    80001c3a:	6105                	addi	sp,sp,32
    80001c3c:	8082                	ret

0000000080001c3e <proc_pagetable>:
{
    80001c3e:	1101                	addi	sp,sp,-32
    80001c40:	ec06                	sd	ra,24(sp)
    80001c42:	e822                	sd	s0,16(sp)
    80001c44:	e426                	sd	s1,8(sp)
    80001c46:	e04a                	sd	s2,0(sp)
    80001c48:	1000                	addi	s0,sp,32
    80001c4a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c4c:	e22ff0ef          	jal	ra,8000126e <uvmcreate>
    80001c50:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c52:	cd05                	beqz	a0,80001c8a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c54:	4729                	li	a4,10
    80001c56:	00005697          	auipc	a3,0x5
    80001c5a:	3aa68693          	addi	a3,a3,938 # 80007000 <_trampoline>
    80001c5e:	6605                	lui	a2,0x1
    80001c60:	040005b7          	lui	a1,0x4000
    80001c64:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c66:	05b2                	slli	a1,a1,0xc
    80001c68:	c60ff0ef          	jal	ra,800010c8 <mappages>
    80001c6c:	02054663          	bltz	a0,80001c98 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c70:	4719                	li	a4,6
    80001c72:	05893683          	ld	a3,88(s2)
    80001c76:	6605                	lui	a2,0x1
    80001c78:	020005b7          	lui	a1,0x2000
    80001c7c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c7e:	05b6                	slli	a1,a1,0xd
    80001c80:	8526                	mv	a0,s1
    80001c82:	c46ff0ef          	jal	ra,800010c8 <mappages>
    80001c86:	00054f63          	bltz	a0,80001ca4 <proc_pagetable+0x66>
}
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	60e2                	ld	ra,24(sp)
    80001c8e:	6442                	ld	s0,16(sp)
    80001c90:	64a2                	ld	s1,8(sp)
    80001c92:	6902                	ld	s2,0(sp)
    80001c94:	6105                	addi	sp,sp,32
    80001c96:	8082                	ret
    uvmfree(pagetable, 0);
    80001c98:	4581                	li	a1,0
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fb2ff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001ca0:	4481                	li	s1,0
    80001ca2:	b7e5                	j	80001c8a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ca4:	4681                	li	a3,0
    80001ca6:	4605                	li	a2,1
    80001ca8:	040005b7          	lui	a1,0x4000
    80001cac:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cae:	05b2                	slli	a1,a1,0xc
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	de2ff0ef          	jal	ra,80001294 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cb6:	4581                	li	a1,0
    80001cb8:	8526                	mv	a0,s1
    80001cba:	f94ff0ef          	jal	ra,8000144e <uvmfree>
    return 0;
    80001cbe:	4481                	li	s1,0
    80001cc0:	b7e9                	j	80001c8a <proc_pagetable+0x4c>

0000000080001cc2 <vma_unmap_pagetable>:
{
    80001cc2:	7179                	addi	sp,sp,-48
    80001cc4:	f406                	sd	ra,40(sp)
    80001cc6:	f022                	sd	s0,32(sp)
    80001cc8:	ec26                	sd	s1,24(sp)
    80001cca:	e84a                	sd	s2,16(sp)
    80001ccc:	e44e                	sd	s3,8(sp)
    80001cce:	1800                	addi	s0,sp,48
    80001cd0:	89aa                	mv	s3,a0
    80001cd2:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001cd4:	28058913          	addi	s2,a1,640
    80001cd8:	a811                	j	80001cec <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001cda:	4685                	li	a3,1
    80001cdc:	8231                	srli	a2,a2,0xc
    80001cde:	854e                	mv	a0,s3
    80001ce0:	db4ff0ef          	jal	ra,80001294 <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001ce4:	02848493          	addi	s1,s1,40
    80001ce8:	01248b63          	beq	s1,s2,80001cfe <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001cec:	409c                	lw	a5,0(s1)
    80001cee:	dbfd                	beqz	a5,80001ce4 <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001cf0:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001cf2:	689c                	ld	a5,16(s1)
    80001cf4:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001cf8:	feb786e3          	beq	a5,a1,80001ce4 <vma_unmap_pagetable+0x22>
    80001cfc:	bff9                	j	80001cda <vma_unmap_pagetable+0x18>
}
    80001cfe:	70a2                	ld	ra,40(sp)
    80001d00:	7402                	ld	s0,32(sp)
    80001d02:	64e2                	ld	s1,24(sp)
    80001d04:	6942                	ld	s2,16(sp)
    80001d06:	69a2                	ld	s3,8(sp)
    80001d08:	6145                	addi	sp,sp,48
    80001d0a:	8082                	ret

0000000080001d0c <proc_freepagetable>:
{
    80001d0c:	1101                	addi	sp,sp,-32
    80001d0e:	ec06                	sd	ra,24(sp)
    80001d10:	e822                	sd	s0,16(sp)
    80001d12:	e426                	sd	s1,8(sp)
    80001d14:	e04a                	sd	s2,0(sp)
    80001d16:	1000                	addi	s0,sp,32
    80001d18:	84aa                	mv	s1,a0
    80001d1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d1c:	4681                	li	a3,0
    80001d1e:	4605                	li	a2,1
    80001d20:	040005b7          	lui	a1,0x4000
    80001d24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d26:	05b2                	slli	a1,a1,0xc
    80001d28:	d6cff0ef          	jal	ra,80001294 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d2c:	4681                	li	a3,0
    80001d2e:	4605                	li	a2,1
    80001d30:	020005b7          	lui	a1,0x2000
    80001d34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d36:	05b6                	slli	a1,a1,0xd
    80001d38:	8526                	mv	a0,s1
    80001d3a:	d5aff0ef          	jal	ra,80001294 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d3e:	85ca                	mv	a1,s2
    80001d40:	8526                	mv	a0,s1
    80001d42:	f0cff0ef          	jal	ra,8000144e <uvmfree>
}
    80001d46:	60e2                	ld	ra,24(sp)
    80001d48:	6442                	ld	s0,16(sp)
    80001d4a:	64a2                	ld	s1,8(sp)
    80001d4c:	6902                	ld	s2,0(sp)
    80001d4e:	6105                	addi	sp,sp,32
    80001d50:	8082                	ret

0000000080001d52 <freeproc>:
{
    80001d52:	1101                	addi	sp,sp,-32
    80001d54:	ec06                	sd	ra,24(sp)
    80001d56:	e822                	sd	s0,16(sp)
    80001d58:	e426                	sd	s1,8(sp)
    80001d5a:	e04a                	sd	s2,0(sp)
    80001d5c:	1000                	addi	s0,sp,32
    80001d5e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d60:	6d28                	ld	a0,88(a0)
    80001d62:	c119                	beqz	a0,80001d68 <freeproc+0x16>
    kfree((void*)p->trapframe);
    80001d64:	d17fe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001d68:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001d6c:	68a8                	ld	a0,80(s1)
    80001d6e:	c105                	beqz	a0,80001d8e <freeproc+0x3c>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001d70:	16848913          	addi	s2,s1,360
    80001d74:	85ca                	mv	a1,s2
    80001d76:	f4dff0ef          	jal	ra,80001cc2 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001d7a:	28000613          	li	a2,640
    80001d7e:	4581                	li	a1,0
    80001d80:	854a                	mv	a0,s2
    80001d82:	ff3fe0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001d86:	64ac                	ld	a1,72(s1)
    80001d88:	68a8                	ld	a0,80(s1)
    80001d8a:	f83ff0ef          	jal	ra,80001d0c <proc_freepagetable>
  p->pagetable = 0;
    80001d8e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d92:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d96:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d9a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d9e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001da2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001da6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001daa:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001dae:	0004ac23          	sw	zero,24(s1)
}
    80001db2:	60e2                	ld	ra,24(sp)
    80001db4:	6442                	ld	s0,16(sp)
    80001db6:	64a2                	ld	s1,8(sp)
    80001db8:	6902                	ld	s2,0(sp)
    80001dba:	6105                	addi	sp,sp,32
    80001dbc:	8082                	ret

0000000080001dbe <allocproc>:
{
    80001dbe:	1101                	addi	sp,sp,-32
    80001dc0:	ec06                	sd	ra,24(sp)
    80001dc2:	e822                	sd	s0,16(sp)
    80001dc4:	e426                	sd	s1,8(sp)
    80001dc6:	e04a                	sd	s2,0(sp)
    80001dc8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dca:	0022f497          	auipc	s1,0x22f
    80001dce:	01648493          	addi	s1,s1,22 # 80230de0 <proc>
    80001dd2:	0023f917          	auipc	s2,0x23f
    80001dd6:	a0e90913          	addi	s2,s2,-1522 # 802407e0 <tickslock>
    acquire(&p->lock);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	ec5fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001de0:	4c9c                	lw	a5,24(s1)
    80001de2:	cb91                	beqz	a5,80001df6 <allocproc+0x38>
      release(&p->lock);
    80001de4:	8526                	mv	a0,s1
    80001de6:	f53fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dea:	3e848493          	addi	s1,s1,1000
    80001dee:	ff2496e3          	bne	s1,s2,80001dda <allocproc+0x1c>
  return 0;
    80001df2:	4481                	li	s1,0
    80001df4:	a089                	j	80001e36 <allocproc+0x78>
  p->pid = allocpid();
    80001df6:	e0bff0ef          	jal	ra,80001c00 <allocpid>
    80001dfa:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001dfc:	4785                	li	a5,1
    80001dfe:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001e00:	dabfe0ef          	jal	ra,80000baa <kalloc>
    80001e04:	892a                	mv	s2,a0
    80001e06:	eca8                	sd	a0,88(s1)
    80001e08:	cd15                	beqz	a0,80001e44 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	e33ff0ef          	jal	ra,80001c3e <proc_pagetable>
    80001e10:	892a                	mv	s2,a0
    80001e12:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001e14:	c121                	beqz	a0,80001e54 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001e16:	07000613          	li	a2,112
    80001e1a:	4581                	li	a1,0
    80001e1c:	06048513          	addi	a0,s1,96
    80001e20:	f55fe0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    80001e24:	00000797          	auipc	a5,0x0
    80001e28:	d4478793          	addi	a5,a5,-700 # 80001b68 <forkret>
    80001e2c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e2e:	60bc                	ld	a5,64(s1)
    80001e30:	6705                	lui	a4,0x1
    80001e32:	97ba                	add	a5,a5,a4
    80001e34:	f4bc                	sd	a5,104(s1)
}
    80001e36:	8526                	mv	a0,s1
    80001e38:	60e2                	ld	ra,24(sp)
    80001e3a:	6442                	ld	s0,16(sp)
    80001e3c:	64a2                	ld	s1,8(sp)
    80001e3e:	6902                	ld	s2,0(sp)
    80001e40:	6105                	addi	sp,sp,32
    80001e42:	8082                	ret
    freeproc(p);
    80001e44:	8526                	mv	a0,s1
    80001e46:	f0dff0ef          	jal	ra,80001d52 <freeproc>
    release(&p->lock);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	eedfe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001e50:	84ca                	mv	s1,s2
    80001e52:	b7d5                	j	80001e36 <allocproc+0x78>
    freeproc(p);
    80001e54:	8526                	mv	a0,s1
    80001e56:	efdff0ef          	jal	ra,80001d52 <freeproc>
    release(&p->lock);
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	eddfe0ef          	jal	ra,80000d38 <release>
    return 0;
    80001e60:	84ca                	mv	s1,s2
    80001e62:	bfd1                	j	80001e36 <allocproc+0x78>

0000000080001e64 <userinit>:
{
    80001e64:	1101                	addi	sp,sp,-32
    80001e66:	ec06                	sd	ra,24(sp)
    80001e68:	e822                	sd	s0,16(sp)
    80001e6a:	e426                	sd	s1,8(sp)
    80001e6c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e6e:	f51ff0ef          	jal	ra,80001dbe <allocproc>
    80001e72:	84aa                	mv	s1,a0
  initproc = p;
    80001e74:	00007797          	auipc	a5,0x7
    80001e78:	a0a7be23          	sd	a0,-1508(a5) # 80008890 <initproc>
  p->cwd = namei("/");
    80001e7c:	00006517          	auipc	a0,0x6
    80001e80:	33450513          	addi	a0,a0,820 # 800081b0 <digits+0x178>
    80001e84:	320020ef          	jal	ra,800041a4 <namei>
    80001e88:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e8c:	478d                	li	a5,3
    80001e8e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e90:	8526                	mv	a0,s1
    80001e92:	ea7fe0ef          	jal	ra,80000d38 <release>
}
    80001e96:	60e2                	ld	ra,24(sp)
    80001e98:	6442                	ld	s0,16(sp)
    80001e9a:	64a2                	ld	s1,8(sp)
    80001e9c:	6105                	addi	sp,sp,32
    80001e9e:	8082                	ret

0000000080001ea0 <growproc>:
{
    80001ea0:	1101                	addi	sp,sp,-32
    80001ea2:	ec06                	sd	ra,24(sp)
    80001ea4:	e822                	sd	s0,16(sp)
    80001ea6:	e426                	sd	s1,8(sp)
    80001ea8:	e04a                	sd	s2,0(sp)
    80001eaa:	1000                	addi	s0,sp,32
    80001eac:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001eae:	c8bff0ef          	jal	ra,80001b38 <myproc>
    80001eb2:	892a                	mv	s2,a0
  sz = p->sz;
    80001eb4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001eb6:	02905963          	blez	s1,80001ee8 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001eba:	00b48633          	add	a2,s1,a1
    80001ebe:	020007b7          	lui	a5,0x2000
    80001ec2:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001ec4:	07b6                	slli	a5,a5,0xd
    80001ec6:	02c7ea63          	bltu	a5,a2,80001efa <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001eca:	4691                	li	a3,4
    80001ecc:	6928                	ld	a0,80(a0)
    80001ece:	c86ff0ef          	jal	ra,80001354 <uvmalloc>
    80001ed2:	85aa                	mv	a1,a0
    80001ed4:	c50d                	beqz	a0,80001efe <growproc+0x5e>
  p->sz = sz;
    80001ed6:	04b93423          	sd	a1,72(s2)
  return 0;
    80001eda:	4501                	li	a0,0
}
    80001edc:	60e2                	ld	ra,24(sp)
    80001ede:	6442                	ld	s0,16(sp)
    80001ee0:	64a2                	ld	s1,8(sp)
    80001ee2:	6902                	ld	s2,0(sp)
    80001ee4:	6105                	addi	sp,sp,32
    80001ee6:	8082                	ret
  } else if(n < 0){
    80001ee8:	fe04d7e3          	bgez	s1,80001ed6 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eec:	00b48633          	add	a2,s1,a1
    80001ef0:	6928                	ld	a0,80(a0)
    80001ef2:	c1eff0ef          	jal	ra,80001310 <uvmdealloc>
    80001ef6:	85aa                	mv	a1,a0
    80001ef8:	bff9                	j	80001ed6 <growproc+0x36>
      return -1;
    80001efa:	557d                	li	a0,-1
    80001efc:	b7c5                	j	80001edc <growproc+0x3c>
      return -1;
    80001efe:	557d                	li	a0,-1
    80001f00:	bff1                	j	80001edc <growproc+0x3c>

0000000080001f02 <kfork>:
{
    80001f02:	7139                	addi	sp,sp,-64
    80001f04:	fc06                	sd	ra,56(sp)
    80001f06:	f822                	sd	s0,48(sp)
    80001f08:	f426                	sd	s1,40(sp)
    80001f0a:	f04a                	sd	s2,32(sp)
    80001f0c:	ec4e                	sd	s3,24(sp)
    80001f0e:	e852                	sd	s4,16(sp)
    80001f10:	e456                	sd	s5,8(sp)
    80001f12:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f14:	c25ff0ef          	jal	ra,80001b38 <myproc>
    80001f18:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f1a:	ea5ff0ef          	jal	ra,80001dbe <allocproc>
    80001f1e:	10050463          	beqz	a0,80002026 <kfork+0x124>
    80001f22:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f24:	048ab603          	ld	a2,72(s5)
    80001f28:	692c                	ld	a1,80(a0)
    80001f2a:	050ab503          	ld	a0,80(s5)
    80001f2e:	d52ff0ef          	jal	ra,80001480 <uvmcopy>
    80001f32:	04054863          	bltz	a0,80001f82 <kfork+0x80>
  np->sz = p->sz;
    80001f36:	048ab783          	ld	a5,72(s5)
    80001f3a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f3e:	058ab683          	ld	a3,88(s5)
    80001f42:	87b6                	mv	a5,a3
    80001f44:	0589b703          	ld	a4,88(s3)
    80001f48:	12068693          	addi	a3,a3,288
    80001f4c:	0007b803          	ld	a6,0(a5)
    80001f50:	6788                	ld	a0,8(a5)
    80001f52:	6b8c                	ld	a1,16(a5)
    80001f54:	6f90                	ld	a2,24(a5)
    80001f56:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001f5a:	e708                	sd	a0,8(a4)
    80001f5c:	eb0c                	sd	a1,16(a4)
    80001f5e:	ef10                	sd	a2,24(a4)
    80001f60:	02078793          	addi	a5,a5,32
    80001f64:	02070713          	addi	a4,a4,32
    80001f68:	fed792e3          	bne	a5,a3,80001f4c <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001f6c:	0589b783          	ld	a5,88(s3)
    80001f70:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f74:	0d0a8493          	addi	s1,s5,208
    80001f78:	0d098913          	addi	s2,s3,208
    80001f7c:	150a8a13          	addi	s4,s5,336
    80001f80:	a829                	j	80001f9a <kfork+0x98>
    freeproc(np);
    80001f82:	854e                	mv	a0,s3
    80001f84:	dcfff0ef          	jal	ra,80001d52 <freeproc>
    release(&np->lock);
    80001f88:	854e                	mv	a0,s3
    80001f8a:	daffe0ef          	jal	ra,80000d38 <release>
    return -1;
    80001f8e:	597d                	li	s2,-1
    80001f90:	a049                	j	80002012 <kfork+0x110>
  for(i = 0; i < NOFILE; i++)
    80001f92:	04a1                	addi	s1,s1,8
    80001f94:	0921                	addi	s2,s2,8
    80001f96:	01448963          	beq	s1,s4,80001fa8 <kfork+0xa6>
    if(p->ofile[i])
    80001f9a:	6088                	ld	a0,0(s1)
    80001f9c:	d97d                	beqz	a0,80001f92 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f9e:	7be020ef          	jal	ra,8000475c <filedup>
    80001fa2:	00a93023          	sd	a0,0(s2)
    80001fa6:	b7f5                	j	80001f92 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001fa8:	150ab503          	ld	a0,336(s5)
    80001fac:	1cf010ef          	jal	ra,8000397a <idup>
    80001fb0:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fb4:	4641                	li	a2,16
    80001fb6:	158a8593          	addi	a1,s5,344
    80001fba:	15898513          	addi	a0,s3,344
    80001fbe:	efdfe0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    80001fc2:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001fc6:	854e                	mv	a0,s3
    80001fc8:	d71fe0ef          	jal	ra,80000d38 <release>
  acquire(&wait_lock);
    80001fcc:	0022f497          	auipc	s1,0x22f
    80001fd0:	9fc48493          	addi	s1,s1,-1540 # 802309c8 <wait_lock>
    80001fd4:	8526                	mv	a0,s1
    80001fd6:	ccbfe0ef          	jal	ra,80000ca0 <acquire>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    80001fda:	28000613          	li	a2,640
    80001fde:	168a8593          	addi	a1,s5,360
    80001fe2:	16898513          	addi	a0,s3,360
    80001fe6:	debfe0ef          	jal	ra,80000dd0 <memmove>
  release(&wait_lock);
    80001fea:	8526                	mv	a0,s1
    80001fec:	d4dfe0ef          	jal	ra,80000d38 <release>
  acquire(&wait_lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	caffe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    80001ff6:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001ffa:	8526                	mv	a0,s1
    80001ffc:	d3dfe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    80002000:	854e                	mv	a0,s3
    80002002:	c9ffe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    80002006:	478d                	li	a5,3
    80002008:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000200c:	854e                	mv	a0,s3
    8000200e:	d2bfe0ef          	jal	ra,80000d38 <release>
}
    80002012:	854a                	mv	a0,s2
    80002014:	70e2                	ld	ra,56(sp)
    80002016:	7442                	ld	s0,48(sp)
    80002018:	74a2                	ld	s1,40(sp)
    8000201a:	7902                	ld	s2,32(sp)
    8000201c:	69e2                	ld	s3,24(sp)
    8000201e:	6a42                	ld	s4,16(sp)
    80002020:	6aa2                	ld	s5,8(sp)
    80002022:	6121                	addi	sp,sp,64
    80002024:	8082                	ret
    return -1;
    80002026:	597d                	li	s2,-1
    80002028:	b7ed                	j	80002012 <kfork+0x110>

000000008000202a <scheduler>:
{
    8000202a:	715d                	addi	sp,sp,-80
    8000202c:	e486                	sd	ra,72(sp)
    8000202e:	e0a2                	sd	s0,64(sp)
    80002030:	fc26                	sd	s1,56(sp)
    80002032:	f84a                	sd	s2,48(sp)
    80002034:	f44e                	sd	s3,40(sp)
    80002036:	f052                	sd	s4,32(sp)
    80002038:	ec56                	sd	s5,24(sp)
    8000203a:	e85a                	sd	s6,16(sp)
    8000203c:	e45e                	sd	s7,8(sp)
    8000203e:	e062                	sd	s8,0(sp)
    80002040:	0880                	addi	s0,sp,80
    80002042:	8792                	mv	a5,tp
  int id = r_tp();
    80002044:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002046:	00779b13          	slli	s6,a5,0x7
    8000204a:	0022f717          	auipc	a4,0x22f
    8000204e:	96670713          	addi	a4,a4,-1690 # 802309b0 <pid_lock>
    80002052:	975a                	add	a4,a4,s6
    80002054:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002058:	0022f717          	auipc	a4,0x22f
    8000205c:	99070713          	addi	a4,a4,-1648 # 802309e8 <cpus+0x8>
    80002060:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002062:	4c11                	li	s8,4
        c->proc = p;
    80002064:	079e                	slli	a5,a5,0x7
    80002066:	0022fa17          	auipc	s4,0x22f
    8000206a:	94aa0a13          	addi	s4,s4,-1718 # 802309b0 <pid_lock>
    8000206e:	9a3e                	add	s4,s4,a5
        found = 1;
    80002070:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002072:	0023e997          	auipc	s3,0x23e
    80002076:	76e98993          	addi	s3,s3,1902 # 802407e0 <tickslock>
    8000207a:	a83d                	j	800020b8 <scheduler+0x8e>
      release(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	cbbfe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002082:	3e848493          	addi	s1,s1,1000
    80002086:	03348563          	beq	s1,s3,800020b0 <scheduler+0x86>
      acquire(&p->lock);
    8000208a:	8526                	mv	a0,s1
    8000208c:	c15fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    80002090:	4c9c                	lw	a5,24(s1)
    80002092:	ff2795e3          	bne	a5,s2,8000207c <scheduler+0x52>
        p->state = RUNNING;
    80002096:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000209a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000209e:	06048593          	addi	a1,s1,96
    800020a2:	855a                	mv	a0,s6
    800020a4:	5b2000ef          	jal	ra,80002656 <swtch>
        c->proc = 0;
    800020a8:	020a3823          	sd	zero,48(s4)
        found = 1;
    800020ac:	8ade                	mv	s5,s7
    800020ae:	b7f9                	j	8000207c <scheduler+0x52>
    if(found == 0) {
    800020b0:	000a9463          	bnez	s5,800020b8 <scheduler+0x8e>
      asm volatile("wfi");
    800020b4:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020bc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020c0:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020c4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800020c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020ca:	10079073          	csrw	sstatus,a5
    int found = 0;
    800020ce:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800020d0:	0022f497          	auipc	s1,0x22f
    800020d4:	d1048493          	addi	s1,s1,-752 # 80230de0 <proc>
      if(p->state == RUNNABLE) {
    800020d8:	490d                	li	s2,3
    800020da:	bf45                	j	8000208a <scheduler+0x60>

00000000800020dc <sched>:
{
    800020dc:	7179                	addi	sp,sp,-48
    800020de:	f406                	sd	ra,40(sp)
    800020e0:	f022                	sd	s0,32(sp)
    800020e2:	ec26                	sd	s1,24(sp)
    800020e4:	e84a                	sd	s2,16(sp)
    800020e6:	e44e                	sd	s3,8(sp)
    800020e8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020ea:	a4fff0ef          	jal	ra,80001b38 <myproc>
    800020ee:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020f0:	b47fe0ef          	jal	ra,80000c36 <holding>
    800020f4:	c92d                	beqz	a0,80002166 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020f6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020f8:	2781                	sext.w	a5,a5
    800020fa:	079e                	slli	a5,a5,0x7
    800020fc:	0022f717          	auipc	a4,0x22f
    80002100:	8b470713          	addi	a4,a4,-1868 # 802309b0 <pid_lock>
    80002104:	97ba                	add	a5,a5,a4
    80002106:	0a87a703          	lw	a4,168(a5)
    8000210a:	4785                	li	a5,1
    8000210c:	06f71363          	bne	a4,a5,80002172 <sched+0x96>
  if(p->state == RUNNING)
    80002110:	4c98                	lw	a4,24(s1)
    80002112:	4791                	li	a5,4
    80002114:	06f70563          	beq	a4,a5,8000217e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002118:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000211c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000211e:	e7b5                	bnez	a5,8000218a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002120:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002122:	0022f917          	auipc	s2,0x22f
    80002126:	88e90913          	addi	s2,s2,-1906 # 802309b0 <pid_lock>
    8000212a:	2781                	sext.w	a5,a5
    8000212c:	079e                	slli	a5,a5,0x7
    8000212e:	97ca                	add	a5,a5,s2
    80002130:	0ac7a983          	lw	s3,172(a5)
    80002134:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002136:	2781                	sext.w	a5,a5
    80002138:	079e                	slli	a5,a5,0x7
    8000213a:	0022f597          	auipc	a1,0x22f
    8000213e:	8ae58593          	addi	a1,a1,-1874 # 802309e8 <cpus+0x8>
    80002142:	95be                	add	a1,a1,a5
    80002144:	06048513          	addi	a0,s1,96
    80002148:	50e000ef          	jal	ra,80002656 <swtch>
    8000214c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000214e:	2781                	sext.w	a5,a5
    80002150:	079e                	slli	a5,a5,0x7
    80002152:	993e                	add	s2,s2,a5
    80002154:	0b392623          	sw	s3,172(s2)
}
    80002158:	70a2                	ld	ra,40(sp)
    8000215a:	7402                	ld	s0,32(sp)
    8000215c:	64e2                	ld	s1,24(sp)
    8000215e:	6942                	ld	s2,16(sp)
    80002160:	69a2                	ld	s3,8(sp)
    80002162:	6145                	addi	sp,sp,48
    80002164:	8082                	ret
    panic("sched p->lock");
    80002166:	00006517          	auipc	a0,0x6
    8000216a:	05250513          	addi	a0,a0,82 # 800081b8 <digits+0x180>
    8000216e:	e1afe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    80002172:	00006517          	auipc	a0,0x6
    80002176:	05650513          	addi	a0,a0,86 # 800081c8 <digits+0x190>
    8000217a:	e0efe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    8000217e:	00006517          	auipc	a0,0x6
    80002182:	05a50513          	addi	a0,a0,90 # 800081d8 <digits+0x1a0>
    80002186:	e02fe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    8000218a:	00006517          	auipc	a0,0x6
    8000218e:	05e50513          	addi	a0,a0,94 # 800081e8 <digits+0x1b0>
    80002192:	df6fe0ef          	jal	ra,80000788 <panic>

0000000080002196 <yield>:
{
    80002196:	1101                	addi	sp,sp,-32
    80002198:	ec06                	sd	ra,24(sp)
    8000219a:	e822                	sd	s0,16(sp)
    8000219c:	e426                	sd	s1,8(sp)
    8000219e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021a0:	999ff0ef          	jal	ra,80001b38 <myproc>
    800021a4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021a6:	afbfe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    800021aa:	478d                	li	a5,3
    800021ac:	cc9c                	sw	a5,24(s1)
  sched();
    800021ae:	f2fff0ef          	jal	ra,800020dc <sched>
  release(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	b85fe0ef          	jal	ra,80000d38 <release>
}
    800021b8:	60e2                	ld	ra,24(sp)
    800021ba:	6442                	ld	s0,16(sp)
    800021bc:	64a2                	ld	s1,8(sp)
    800021be:	6105                	addi	sp,sp,32
    800021c0:	8082                	ret

00000000800021c2 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021c2:	7179                	addi	sp,sp,-48
    800021c4:	f406                	sd	ra,40(sp)
    800021c6:	f022                	sd	s0,32(sp)
    800021c8:	ec26                	sd	s1,24(sp)
    800021ca:	e84a                	sd	s2,16(sp)
    800021cc:	e44e                	sd	s3,8(sp)
    800021ce:	1800                	addi	s0,sp,48
    800021d0:	89aa                	mv	s3,a0
    800021d2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021d4:	965ff0ef          	jal	ra,80001b38 <myproc>
    800021d8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021da:	ac7fe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    800021de:	854a                	mv	a0,s2
    800021e0:	b59fe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    800021e4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021e8:	4789                	li	a5,2
    800021ea:	cc9c                	sw	a5,24(s1)

  sched();
    800021ec:	ef1ff0ef          	jal	ra,800020dc <sched>

  // Tidy up.
  p->chan = 0;
    800021f0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	b43fe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    800021fa:	854a                	mv	a0,s2
    800021fc:	aa5fe0ef          	jal	ra,80000ca0 <acquire>
}
    80002200:	70a2                	ld	ra,40(sp)
    80002202:	7402                	ld	s0,32(sp)
    80002204:	64e2                	ld	s1,24(sp)
    80002206:	6942                	ld	s2,16(sp)
    80002208:	69a2                	ld	s3,8(sp)
    8000220a:	6145                	addi	sp,sp,48
    8000220c:	8082                	ret

000000008000220e <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000220e:	7139                	addi	sp,sp,-64
    80002210:	fc06                	sd	ra,56(sp)
    80002212:	f822                	sd	s0,48(sp)
    80002214:	f426                	sd	s1,40(sp)
    80002216:	f04a                	sd	s2,32(sp)
    80002218:	ec4e                	sd	s3,24(sp)
    8000221a:	e852                	sd	s4,16(sp)
    8000221c:	e456                	sd	s5,8(sp)
    8000221e:	0080                	addi	s0,sp,64
    80002220:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002222:	0022f497          	auipc	s1,0x22f
    80002226:	bbe48493          	addi	s1,s1,-1090 # 80230de0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000222a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000222c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000222e:	0023e917          	auipc	s2,0x23e
    80002232:	5b290913          	addi	s2,s2,1458 # 802407e0 <tickslock>
    80002236:	a801                	j	80002246 <wakeup+0x38>
      }
      release(&p->lock);
    80002238:	8526                	mv	a0,s1
    8000223a:	afffe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000223e:	3e848493          	addi	s1,s1,1000
    80002242:	03248263          	beq	s1,s2,80002266 <wakeup+0x58>
    if(p != myproc()){
    80002246:	8f3ff0ef          	jal	ra,80001b38 <myproc>
    8000224a:	fea48ae3          	beq	s1,a0,8000223e <wakeup+0x30>
      acquire(&p->lock);
    8000224e:	8526                	mv	a0,s1
    80002250:	a51fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002254:	4c9c                	lw	a5,24(s1)
    80002256:	ff3791e3          	bne	a5,s3,80002238 <wakeup+0x2a>
    8000225a:	709c                	ld	a5,32(s1)
    8000225c:	fd479ee3          	bne	a5,s4,80002238 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002260:	0154ac23          	sw	s5,24(s1)
    80002264:	bfd1                	j	80002238 <wakeup+0x2a>
    }
  }
}
    80002266:	70e2                	ld	ra,56(sp)
    80002268:	7442                	ld	s0,48(sp)
    8000226a:	74a2                	ld	s1,40(sp)
    8000226c:	7902                	ld	s2,32(sp)
    8000226e:	69e2                	ld	s3,24(sp)
    80002270:	6a42                	ld	s4,16(sp)
    80002272:	6aa2                	ld	s5,8(sp)
    80002274:	6121                	addi	sp,sp,64
    80002276:	8082                	ret

0000000080002278 <reparent>:
{
    80002278:	7179                	addi	sp,sp,-48
    8000227a:	f406                	sd	ra,40(sp)
    8000227c:	f022                	sd	s0,32(sp)
    8000227e:	ec26                	sd	s1,24(sp)
    80002280:	e84a                	sd	s2,16(sp)
    80002282:	e44e                	sd	s3,8(sp)
    80002284:	e052                	sd	s4,0(sp)
    80002286:	1800                	addi	s0,sp,48
    80002288:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000228a:	0022f497          	auipc	s1,0x22f
    8000228e:	b5648493          	addi	s1,s1,-1194 # 80230de0 <proc>
      pp->parent = initproc;
    80002292:	00006a17          	auipc	s4,0x6
    80002296:	5fea0a13          	addi	s4,s4,1534 # 80008890 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000229a:	0023e997          	auipc	s3,0x23e
    8000229e:	54698993          	addi	s3,s3,1350 # 802407e0 <tickslock>
    800022a2:	a029                	j	800022ac <reparent+0x34>
    800022a4:	3e848493          	addi	s1,s1,1000
    800022a8:	01348b63          	beq	s1,s3,800022be <reparent+0x46>
    if(pp->parent == p){
    800022ac:	7c9c                	ld	a5,56(s1)
    800022ae:	ff279be3          	bne	a5,s2,800022a4 <reparent+0x2c>
      pp->parent = initproc;
    800022b2:	000a3503          	ld	a0,0(s4)
    800022b6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022b8:	f57ff0ef          	jal	ra,8000220e <wakeup>
    800022bc:	b7e5                	j	800022a4 <reparent+0x2c>
}
    800022be:	70a2                	ld	ra,40(sp)
    800022c0:	7402                	ld	s0,32(sp)
    800022c2:	64e2                	ld	s1,24(sp)
    800022c4:	6942                	ld	s2,16(sp)
    800022c6:	69a2                	ld	s3,8(sp)
    800022c8:	6a02                	ld	s4,0(sp)
    800022ca:	6145                	addi	sp,sp,48
    800022cc:	8082                	ret

00000000800022ce <kexit>:
{
    800022ce:	7179                	addi	sp,sp,-48
    800022d0:	f406                	sd	ra,40(sp)
    800022d2:	f022                	sd	s0,32(sp)
    800022d4:	ec26                	sd	s1,24(sp)
    800022d6:	e84a                	sd	s2,16(sp)
    800022d8:	e44e                	sd	s3,8(sp)
    800022da:	e052                	sd	s4,0(sp)
    800022dc:	1800                	addi	s0,sp,48
    800022de:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022e0:	859ff0ef          	jal	ra,80001b38 <myproc>
    800022e4:	89aa                	mv	s3,a0
  if(p == initproc)
    800022e6:	00006797          	auipc	a5,0x6
    800022ea:	5aa7b783          	ld	a5,1450(a5) # 80008890 <initproc>
    800022ee:	0d050493          	addi	s1,a0,208
    800022f2:	15050913          	addi	s2,a0,336
    800022f6:	00a79f63          	bne	a5,a0,80002314 <kexit+0x46>
    panic("init exiting");
    800022fa:	00006517          	auipc	a0,0x6
    800022fe:	f0650513          	addi	a0,a0,-250 # 80008200 <digits+0x1c8>
    80002302:	c86fe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    80002306:	49c020ef          	jal	ra,800047a2 <fileclose>
      p->ofile[fd] = 0;
    8000230a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000230e:	04a1                	addi	s1,s1,8
    80002310:	01248563          	beq	s1,s2,8000231a <kexit+0x4c>
    if(p->ofile[fd]){
    80002314:	6088                	ld	a0,0(s1)
    80002316:	f965                	bnez	a0,80002306 <kexit+0x38>
    80002318:	bfdd                	j	8000230e <kexit+0x40>
  begin_op();
    8000231a:	07e020ef          	jal	ra,80004398 <begin_op>
  iput(p->cwd);
    8000231e:	1509b503          	ld	a0,336(s3)
    80002322:	00d010ef          	jal	ra,80003b2e <iput>
  end_op();
    80002326:	0e0020ef          	jal	ra,80004406 <end_op>
  p->cwd = 0;
    8000232a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000232e:	0022e497          	auipc	s1,0x22e
    80002332:	69a48493          	addi	s1,s1,1690 # 802309c8 <wait_lock>
    80002336:	8526                	mv	a0,s1
    80002338:	969fe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    8000233c:	854e                	mv	a0,s3
    8000233e:	f3bff0ef          	jal	ra,80002278 <reparent>
  wakeup(p->parent);
    80002342:	0389b503          	ld	a0,56(s3)
    80002346:	ec9ff0ef          	jal	ra,8000220e <wakeup>
  acquire(&p->lock);
    8000234a:	854e                	mv	a0,s3
    8000234c:	955fe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    80002350:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002354:	4795                	li	a5,5
    80002356:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000235a:	8526                	mv	a0,s1
    8000235c:	9ddfe0ef          	jal	ra,80000d38 <release>
  sched();
    80002360:	d7dff0ef          	jal	ra,800020dc <sched>
  panic("zombie exit");
    80002364:	00006517          	auipc	a0,0x6
    80002368:	eac50513          	addi	a0,a0,-340 # 80008210 <digits+0x1d8>
    8000236c:	c1cfe0ef          	jal	ra,80000788 <panic>

0000000080002370 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002370:	7179                	addi	sp,sp,-48
    80002372:	f406                	sd	ra,40(sp)
    80002374:	f022                	sd	s0,32(sp)
    80002376:	ec26                	sd	s1,24(sp)
    80002378:	e84a                	sd	s2,16(sp)
    8000237a:	e44e                	sd	s3,8(sp)
    8000237c:	1800                	addi	s0,sp,48
    8000237e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002380:	0022f497          	auipc	s1,0x22f
    80002384:	a6048493          	addi	s1,s1,-1440 # 80230de0 <proc>
    80002388:	0023e997          	auipc	s3,0x23e
    8000238c:	45898993          	addi	s3,s3,1112 # 802407e0 <tickslock>
    acquire(&p->lock);
    80002390:	8526                	mv	a0,s1
    80002392:	90ffe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    80002396:	589c                	lw	a5,48(s1)
    80002398:	01278b63          	beq	a5,s2,800023ae <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	99bfe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023a2:	3e848493          	addi	s1,s1,1000
    800023a6:	ff3495e3          	bne	s1,s3,80002390 <kkill+0x20>
  }
  return -1;
    800023aa:	557d                	li	a0,-1
    800023ac:	a819                	j	800023c2 <kkill+0x52>
      p->killed = 1;
    800023ae:	4785                	li	a5,1
    800023b0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023b2:	4c98                	lw	a4,24(s1)
    800023b4:	4789                	li	a5,2
    800023b6:	00f70d63          	beq	a4,a5,800023d0 <kkill+0x60>
      release(&p->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	97dfe0ef          	jal	ra,80000d38 <release>
      return 0;
    800023c0:	4501                	li	a0,0
}
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6145                	addi	sp,sp,48
    800023ce:	8082                	ret
        p->state = RUNNABLE;
    800023d0:	478d                	li	a5,3
    800023d2:	cc9c                	sw	a5,24(s1)
    800023d4:	b7dd                	j	800023ba <kkill+0x4a>

00000000800023d6 <setkilled>:

void
setkilled(struct proc *p)
{
    800023d6:	1101                	addi	sp,sp,-32
    800023d8:	ec06                	sd	ra,24(sp)
    800023da:	e822                	sd	s0,16(sp)
    800023dc:	e426                	sd	s1,8(sp)
    800023de:	1000                	addi	s0,sp,32
    800023e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023e2:	8bffe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    800023e6:	4785                	li	a5,1
    800023e8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	94dfe0ef          	jal	ra,80000d38 <release>
}
    800023f0:	60e2                	ld	ra,24(sp)
    800023f2:	6442                	ld	s0,16(sp)
    800023f4:	64a2                	ld	s1,8(sp)
    800023f6:	6105                	addi	sp,sp,32
    800023f8:	8082                	ret

00000000800023fa <killed>:

int
killed(struct proc *p)
{
    800023fa:	1101                	addi	sp,sp,-32
    800023fc:	ec06                	sd	ra,24(sp)
    800023fe:	e822                	sd	s0,16(sp)
    80002400:	e426                	sd	s1,8(sp)
    80002402:	e04a                	sd	s2,0(sp)
    80002404:	1000                	addi	s0,sp,32
    80002406:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002408:	899fe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    8000240c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	927fe0ef          	jal	ra,80000d38 <release>
  return k;
}
    80002416:	854a                	mv	a0,s2
    80002418:	60e2                	ld	ra,24(sp)
    8000241a:	6442                	ld	s0,16(sp)
    8000241c:	64a2                	ld	s1,8(sp)
    8000241e:	6902                	ld	s2,0(sp)
    80002420:	6105                	addi	sp,sp,32
    80002422:	8082                	ret

0000000080002424 <kwait>:
{
    80002424:	715d                	addi	sp,sp,-80
    80002426:	e486                	sd	ra,72(sp)
    80002428:	e0a2                	sd	s0,64(sp)
    8000242a:	fc26                	sd	s1,56(sp)
    8000242c:	f84a                	sd	s2,48(sp)
    8000242e:	f44e                	sd	s3,40(sp)
    80002430:	f052                	sd	s4,32(sp)
    80002432:	ec56                	sd	s5,24(sp)
    80002434:	e85a                	sd	s6,16(sp)
    80002436:	e45e                	sd	s7,8(sp)
    80002438:	e062                	sd	s8,0(sp)
    8000243a:	0880                	addi	s0,sp,80
    8000243c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000243e:	efaff0ef          	jal	ra,80001b38 <myproc>
    80002442:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002444:	0022e517          	auipc	a0,0x22e
    80002448:	58450513          	addi	a0,a0,1412 # 802309c8 <wait_lock>
    8000244c:	855fe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    80002450:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002452:	4a15                	li	s4,5
        havekids = 1;
    80002454:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002456:	0023e997          	auipc	s3,0x23e
    8000245a:	38a98993          	addi	s3,s3,906 # 802407e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000245e:	0022ec17          	auipc	s8,0x22e
    80002462:	56ac0c13          	addi	s8,s8,1386 # 802309c8 <wait_lock>
    havekids = 0;
    80002466:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002468:	0022f497          	auipc	s1,0x22f
    8000246c:	97848493          	addi	s1,s1,-1672 # 80230de0 <proc>
    80002470:	a899                	j	800024c6 <kwait+0xa2>
          pid = pp->pid;
    80002472:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002476:	000b0c63          	beqz	s6,8000248e <kwait+0x6a>
    8000247a:	4691                	li	a3,4
    8000247c:	02c48613          	addi	a2,s1,44
    80002480:	85da                	mv	a1,s6
    80002482:	05093503          	ld	a0,80(s2)
    80002486:	ae4ff0ef          	jal	ra,8000176a <copyout>
    8000248a:	00054f63          	bltz	a0,800024a8 <kwait+0x84>
          freeproc(pp);
    8000248e:	8526                	mv	a0,s1
    80002490:	8c3ff0ef          	jal	ra,80001d52 <freeproc>
          release(&pp->lock);
    80002494:	8526                	mv	a0,s1
    80002496:	8a3fe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    8000249a:	0022e517          	auipc	a0,0x22e
    8000249e:	52e50513          	addi	a0,a0,1326 # 802309c8 <wait_lock>
    800024a2:	897fe0ef          	jal	ra,80000d38 <release>
          return pid;
    800024a6:	a891                	j	800024fa <kwait+0xd6>
            release(&pp->lock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	88ffe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    800024ae:	0022e517          	auipc	a0,0x22e
    800024b2:	51a50513          	addi	a0,a0,1306 # 802309c8 <wait_lock>
    800024b6:	883fe0ef          	jal	ra,80000d38 <release>
            return -1;
    800024ba:	59fd                	li	s3,-1
    800024bc:	a83d                	j	800024fa <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024be:	3e848493          	addi	s1,s1,1000
    800024c2:	03348063          	beq	s1,s3,800024e2 <kwait+0xbe>
      if(pp->parent == p){
    800024c6:	7c9c                	ld	a5,56(s1)
    800024c8:	ff279be3          	bne	a5,s2,800024be <kwait+0x9a>
        acquire(&pp->lock);
    800024cc:	8526                	mv	a0,s1
    800024ce:	fd2fe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    800024d2:	4c9c                	lw	a5,24(s1)
    800024d4:	f9478fe3          	beq	a5,s4,80002472 <kwait+0x4e>
        release(&pp->lock);
    800024d8:	8526                	mv	a0,s1
    800024da:	85ffe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    800024de:	8756                	mv	a4,s5
    800024e0:	bff9                	j	800024be <kwait+0x9a>
    if(!havekids || killed(p)){
    800024e2:	c709                	beqz	a4,800024ec <kwait+0xc8>
    800024e4:	854a                	mv	a0,s2
    800024e6:	f15ff0ef          	jal	ra,800023fa <killed>
    800024ea:	c50d                	beqz	a0,80002514 <kwait+0xf0>
      release(&wait_lock);
    800024ec:	0022e517          	auipc	a0,0x22e
    800024f0:	4dc50513          	addi	a0,a0,1244 # 802309c8 <wait_lock>
    800024f4:	845fe0ef          	jal	ra,80000d38 <release>
      return -1;
    800024f8:	59fd                	li	s3,-1
}
    800024fa:	854e                	mv	a0,s3
    800024fc:	60a6                	ld	ra,72(sp)
    800024fe:	6406                	ld	s0,64(sp)
    80002500:	74e2                	ld	s1,56(sp)
    80002502:	7942                	ld	s2,48(sp)
    80002504:	79a2                	ld	s3,40(sp)
    80002506:	7a02                	ld	s4,32(sp)
    80002508:	6ae2                	ld	s5,24(sp)
    8000250a:	6b42                	ld	s6,16(sp)
    8000250c:	6ba2                	ld	s7,8(sp)
    8000250e:	6c02                	ld	s8,0(sp)
    80002510:	6161                	addi	sp,sp,80
    80002512:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002514:	85e2                	mv	a1,s8
    80002516:	854a                	mv	a0,s2
    80002518:	cabff0ef          	jal	ra,800021c2 <sleep>
    havekids = 0;
    8000251c:	b7a9                	j	80002466 <kwait+0x42>

000000008000251e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000251e:	7179                	addi	sp,sp,-48
    80002520:	f406                	sd	ra,40(sp)
    80002522:	f022                	sd	s0,32(sp)
    80002524:	ec26                	sd	s1,24(sp)
    80002526:	e84a                	sd	s2,16(sp)
    80002528:	e44e                	sd	s3,8(sp)
    8000252a:	e052                	sd	s4,0(sp)
    8000252c:	1800                	addi	s0,sp,48
    8000252e:	84aa                	mv	s1,a0
    80002530:	892e                	mv	s2,a1
    80002532:	89b2                	mv	s3,a2
    80002534:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002536:	e02ff0ef          	jal	ra,80001b38 <myproc>
  if(user_dst){
    8000253a:	cc99                	beqz	s1,80002558 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000253c:	86d2                	mv	a3,s4
    8000253e:	864e                	mv	a2,s3
    80002540:	85ca                	mv	a1,s2
    80002542:	6928                	ld	a0,80(a0)
    80002544:	a26ff0ef          	jal	ra,8000176a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002548:	70a2                	ld	ra,40(sp)
    8000254a:	7402                	ld	s0,32(sp)
    8000254c:	64e2                	ld	s1,24(sp)
    8000254e:	6942                	ld	s2,16(sp)
    80002550:	69a2                	ld	s3,8(sp)
    80002552:	6a02                	ld	s4,0(sp)
    80002554:	6145                	addi	sp,sp,48
    80002556:	8082                	ret
    memmove((char *)dst, src, len);
    80002558:	000a061b          	sext.w	a2,s4
    8000255c:	85ce                	mv	a1,s3
    8000255e:	854a                	mv	a0,s2
    80002560:	871fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    80002564:	8526                	mv	a0,s1
    80002566:	b7cd                	j	80002548 <either_copyout+0x2a>

0000000080002568 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002568:	7179                	addi	sp,sp,-48
    8000256a:	f406                	sd	ra,40(sp)
    8000256c:	f022                	sd	s0,32(sp)
    8000256e:	ec26                	sd	s1,24(sp)
    80002570:	e84a                	sd	s2,16(sp)
    80002572:	e44e                	sd	s3,8(sp)
    80002574:	e052                	sd	s4,0(sp)
    80002576:	1800                	addi	s0,sp,48
    80002578:	892a                	mv	s2,a0
    8000257a:	84ae                	mv	s1,a1
    8000257c:	89b2                	mv	s3,a2
    8000257e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002580:	db8ff0ef          	jal	ra,80001b38 <myproc>
  if(user_src){
    80002584:	cc99                	beqz	s1,800025a2 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002586:	86d2                	mv	a3,s4
    80002588:	864e                	mv	a2,s3
    8000258a:	85ca                	mv	a1,s2
    8000258c:	6928                	ld	a0,80(a0)
    8000258e:	ac6ff0ef          	jal	ra,80001854 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002592:	70a2                	ld	ra,40(sp)
    80002594:	7402                	ld	s0,32(sp)
    80002596:	64e2                	ld	s1,24(sp)
    80002598:	6942                	ld	s2,16(sp)
    8000259a:	69a2                	ld	s3,8(sp)
    8000259c:	6a02                	ld	s4,0(sp)
    8000259e:	6145                	addi	sp,sp,48
    800025a0:	8082                	ret
    memmove(dst, (char*)src, len);
    800025a2:	000a061b          	sext.w	a2,s4
    800025a6:	85ce                	mv	a1,s3
    800025a8:	854a                	mv	a0,s2
    800025aa:	827fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    800025ae:	8526                	mv	a0,s1
    800025b0:	b7cd                	j	80002592 <either_copyin+0x2a>

00000000800025b2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025b2:	715d                	addi	sp,sp,-80
    800025b4:	e486                	sd	ra,72(sp)
    800025b6:	e0a2                	sd	s0,64(sp)
    800025b8:	fc26                	sd	s1,56(sp)
    800025ba:	f84a                	sd	s2,48(sp)
    800025bc:	f44e                	sd	s3,40(sp)
    800025be:	f052                	sd	s4,32(sp)
    800025c0:	ec56                	sd	s5,24(sp)
    800025c2:	e85a                	sd	s6,16(sp)
    800025c4:	e45e                	sd	s7,8(sp)
    800025c6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025c8:	00006517          	auipc	a0,0x6
    800025cc:	b0050513          	addi	a0,a0,-1280 # 800080c8 <digits+0x90>
    800025d0:	ef3fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025d4:	0022f497          	auipc	s1,0x22f
    800025d8:	96448493          	addi	s1,s1,-1692 # 80230f38 <proc+0x158>
    800025dc:	0023e917          	auipc	s2,0x23e
    800025e0:	35c90913          	addi	s2,s2,860 # 80240938 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025e6:	00006997          	auipc	s3,0x6
    800025ea:	c3a98993          	addi	s3,s3,-966 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    800025ee:	00006a97          	auipc	s5,0x6
    800025f2:	c3aa8a93          	addi	s5,s5,-966 # 80008228 <digits+0x1f0>
    printf("\n");
    800025f6:	00006a17          	auipc	s4,0x6
    800025fa:	ad2a0a13          	addi	s4,s4,-1326 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025fe:	00006b97          	auipc	s7,0x6
    80002602:	c6ab8b93          	addi	s7,s7,-918 # 80008268 <states.0>
    80002606:	a829                	j	80002620 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002608:	ed86a583          	lw	a1,-296(a3)
    8000260c:	8556                	mv	a0,s5
    8000260e:	eb5fd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80002612:	8552                	mv	a0,s4
    80002614:	eaffd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002618:	3e848493          	addi	s1,s1,1000
    8000261c:	03248263          	beq	s1,s2,80002640 <procdump+0x8e>
    if(p->state == UNUSED)
    80002620:	86a6                	mv	a3,s1
    80002622:	ec04a783          	lw	a5,-320(s1)
    80002626:	dbed                	beqz	a5,80002618 <procdump+0x66>
      state = "???";
    80002628:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000262a:	fcfb6fe3          	bltu	s6,a5,80002608 <procdump+0x56>
    8000262e:	02079713          	slli	a4,a5,0x20
    80002632:	01d75793          	srli	a5,a4,0x1d
    80002636:	97de                	add	a5,a5,s7
    80002638:	6390                	ld	a2,0(a5)
    8000263a:	f679                	bnez	a2,80002608 <procdump+0x56>
      state = "???";
    8000263c:	864e                	mv	a2,s3
    8000263e:	b7e9                	j	80002608 <procdump+0x56>
  }
}
    80002640:	60a6                	ld	ra,72(sp)
    80002642:	6406                	ld	s0,64(sp)
    80002644:	74e2                	ld	s1,56(sp)
    80002646:	7942                	ld	s2,48(sp)
    80002648:	79a2                	ld	s3,40(sp)
    8000264a:	7a02                	ld	s4,32(sp)
    8000264c:	6ae2                	ld	s5,24(sp)
    8000264e:	6b42                	ld	s6,16(sp)
    80002650:	6ba2                	ld	s7,8(sp)
    80002652:	6161                	addi	sp,sp,80
    80002654:	8082                	ret

0000000080002656 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002656:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000265a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000265e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002660:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002662:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002666:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000266a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000266e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002672:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002676:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000267a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000267e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002682:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002686:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000268a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000268e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002692:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002694:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002696:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000269a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000269e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800026a2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800026a6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800026aa:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800026ae:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800026b2:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800026b6:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800026ba:	0685bd83          	ld	s11,104(a1)
        
        ret
    800026be:	8082                	ret

00000000800026c0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026c0:	1141                	addi	sp,sp,-16
    800026c2:	e406                	sd	ra,8(sp)
    800026c4:	e022                	sd	s0,0(sp)
    800026c6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026c8:	00006597          	auipc	a1,0x6
    800026cc:	bd058593          	addi	a1,a1,-1072 # 80008298 <states.0+0x30>
    800026d0:	0023e517          	auipc	a0,0x23e
    800026d4:	11050513          	addi	a0,a0,272 # 802407e0 <tickslock>
    800026d8:	d48fe0ef          	jal	ra,80000c20 <initlock>
}
    800026dc:	60a2                	ld	ra,8(sp)
    800026de:	6402                	ld	s0,0(sp)
    800026e0:	0141                	addi	sp,sp,16
    800026e2:	8082                	ret

00000000800026e4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026e4:	1141                	addi	sp,sp,-16
    800026e6:	e422                	sd	s0,8(sp)
    800026e8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ea:	00003797          	auipc	a5,0x3
    800026ee:	3c678793          	addi	a5,a5,966 # 80005ab0 <kernelvec>
    800026f2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026f6:	6422                	ld	s0,8(sp)
    800026f8:	0141                	addi	sp,sp,16
    800026fa:	8082                	ret

00000000800026fc <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800026fc:	1141                	addi	sp,sp,-16
    800026fe:	e406                	sd	ra,8(sp)
    80002700:	e022                	sd	s0,0(sp)
    80002702:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002704:	c34ff0ef          	jal	ra,80001b38 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002708:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000270c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000270e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002712:	04000737          	lui	a4,0x4000
    80002716:	00005797          	auipc	a5,0x5
    8000271a:	8ea78793          	addi	a5,a5,-1814 # 80007000 <_trampoline>
    8000271e:	00005697          	auipc	a3,0x5
    80002722:	8e268693          	addi	a3,a3,-1822 # 80007000 <_trampoline>
    80002726:	8f95                	sub	a5,a5,a3
    80002728:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000272a:	0732                	slli	a4,a4,0xc
    8000272c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000272e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002732:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002734:	18002773          	csrr	a4,satp
    80002738:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000273a:	6d38                	ld	a4,88(a0)
    8000273c:	613c                	ld	a5,64(a0)
    8000273e:	6685                	lui	a3,0x1
    80002740:	97b6                	add	a5,a5,a3
    80002742:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002744:	6d3c                	ld	a5,88(a0)
    80002746:	00000717          	auipc	a4,0x0
    8000274a:	0f470713          	addi	a4,a4,244 # 8000283a <usertrap>
    8000274e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002750:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002752:	8712                	mv	a4,tp
    80002754:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002756:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000275a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000275e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002762:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002766:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002768:	6f9c                	ld	a5,24(a5)
    8000276a:	14179073          	csrw	sepc,a5
}
    8000276e:	60a2                	ld	ra,8(sp)
    80002770:	6402                	ld	s0,0(sp)
    80002772:	0141                	addi	sp,sp,16
    80002774:	8082                	ret

0000000080002776 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002776:	1101                	addi	sp,sp,-32
    80002778:	ec06                	sd	ra,24(sp)
    8000277a:	e822                	sd	s0,16(sp)
    8000277c:	e426                	sd	s1,8(sp)
    8000277e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002780:	b8cff0ef          	jal	ra,80001b0c <cpuid>
    80002784:	cd19                	beqz	a0,800027a2 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002786:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000278a:	000f4737          	lui	a4,0xf4
    8000278e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002792:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002794:	14d79073          	csrw	0x14d,a5
}
    80002798:	60e2                	ld	ra,24(sp)
    8000279a:	6442                	ld	s0,16(sp)
    8000279c:	64a2                	ld	s1,8(sp)
    8000279e:	6105                	addi	sp,sp,32
    800027a0:	8082                	ret
    acquire(&tickslock);
    800027a2:	0023e497          	auipc	s1,0x23e
    800027a6:	03e48493          	addi	s1,s1,62 # 802407e0 <tickslock>
    800027aa:	8526                	mv	a0,s1
    800027ac:	cf4fe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    800027b0:	00006517          	auipc	a0,0x6
    800027b4:	0e850513          	addi	a0,a0,232 # 80008898 <ticks>
    800027b8:	411c                	lw	a5,0(a0)
    800027ba:	2785                	addiw	a5,a5,1
    800027bc:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800027be:	a51ff0ef          	jal	ra,8000220e <wakeup>
    release(&tickslock);
    800027c2:	8526                	mv	a0,s1
    800027c4:	d74fe0ef          	jal	ra,80000d38 <release>
    800027c8:	bf7d                	j	80002786 <clockintr+0x10>

00000000800027ca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ca:	1101                	addi	sp,sp,-32
    800027cc:	ec06                	sd	ra,24(sp)
    800027ce:	e822                	sd	s0,16(sp)
    800027d0:	e426                	sd	s1,8(sp)
    800027d2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027d4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800027d8:	57fd                	li	a5,-1
    800027da:	17fe                	slli	a5,a5,0x3f
    800027dc:	07a5                	addi	a5,a5,9
    800027de:	00f70d63          	beq	a4,a5,800027f8 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800027e2:	57fd                	li	a5,-1
    800027e4:	17fe                	slli	a5,a5,0x3f
    800027e6:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800027e8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800027ea:	04f70463          	beq	a4,a5,80002832 <devintr+0x68>
  }
}
    800027ee:	60e2                	ld	ra,24(sp)
    800027f0:	6442                	ld	s0,16(sp)
    800027f2:	64a2                	ld	s1,8(sp)
    800027f4:	6105                	addi	sp,sp,32
    800027f6:	8082                	ret
    int irq = plic_claim();
    800027f8:	360030ef          	jal	ra,80005b58 <plic_claim>
    800027fc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027fe:	47a9                	li	a5,10
    80002800:	02f50363          	beq	a0,a5,80002826 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002804:	4785                	li	a5,1
    80002806:	02f50363          	beq	a0,a5,8000282c <devintr+0x62>
    return 1;
    8000280a:	4505                	li	a0,1
    } else if(irq){
    8000280c:	d0ed                	beqz	s1,800027ee <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    8000280e:	85a6                	mv	a1,s1
    80002810:	00006517          	auipc	a0,0x6
    80002814:	a9050513          	addi	a0,a0,-1392 # 800082a0 <states.0+0x38>
    80002818:	cabfd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    8000281c:	8526                	mv	a0,s1
    8000281e:	35a030ef          	jal	ra,80005b78 <plic_complete>
    return 1;
    80002822:	4505                	li	a0,1
    80002824:	b7e9                	j	800027ee <devintr+0x24>
      uartintr();
    80002826:	92efe0ef          	jal	ra,80000954 <uartintr>
    8000282a:	bfcd                	j	8000281c <devintr+0x52>
      virtio_disk_intr();
    8000282c:	7b8030ef          	jal	ra,80005fe4 <virtio_disk_intr>
    80002830:	b7f5                	j	8000281c <devintr+0x52>
    clockintr();
    80002832:	f45ff0ef          	jal	ra,80002776 <clockintr>
    return 2;
    80002836:	4509                	li	a0,2
    80002838:	bf5d                	j	800027ee <devintr+0x24>

000000008000283a <usertrap>:
{
    8000283a:	7179                	addi	sp,sp,-48
    8000283c:	f406                	sd	ra,40(sp)
    8000283e:	f022                	sd	s0,32(sp)
    80002840:	ec26                	sd	s1,24(sp)
    80002842:	e84a                	sd	s2,16(sp)
    80002844:	e44e                	sd	s3,8(sp)
    80002846:	e052                	sd	s4,0(sp)
    80002848:	1800                	addi	s0,sp,48
    8000284a:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000284e:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002852:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002856:	1007f793          	andi	a5,a5,256
    8000285a:	e3bd                	bnez	a5,800028c0 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000285c:	00003797          	auipc	a5,0x3
    80002860:	25478793          	addi	a5,a5,596 # 80005ab0 <kernelvec>
    80002864:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002868:	ad0ff0ef          	jal	ra,80001b38 <myproc>
    8000286c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000286e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002870:	14102773          	csrr	a4,sepc
    80002874:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002876:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000287a:	47a1                	li	a5,8
    8000287c:	04f70863          	beq	a4,a5,800028cc <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002880:	f4bff0ef          	jal	ra,800027ca <devintr>
    80002884:	892a                	mv	s2,a0
    80002886:	0c051e63          	bnez	a0,80002962 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    8000288a:	47b5                	li	a5,13
    8000288c:	08f98663          	beq	s3,a5,80002918 <usertrap+0xde>
    80002890:	47bd                	li	a5,15
    80002892:	0af99363          	bne	s3,a5,80002938 <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002896:	85d2                	mv	a1,s4
    80002898:	68a8                	ld	a0,80(s1)
    8000289a:	ca7fe0ef          	jal	ra,80001540 <cowbreak>
    8000289e:	c531                	beqz	a0,800028ea <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    800028a0:	4605                	li	a2,1
    800028a2:	85d2                	mv	a1,s4
    800028a4:	8526                	mv	a0,s1
    800028a6:	83cff0ef          	jal	ra,800018e2 <vmafault>
    800028aa:	e121                	bnez	a0,800028ea <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    800028ac:	4601                	li	a2,0
    800028ae:	85d2                	mv	a1,s4
    800028b0:	68a8                	ld	a0,80(s1)
    800028b2:	e47fe0ef          	jal	ra,800016f8 <vmfault>
    800028b6:	e915                	bnez	a0,800028ea <usertrap+0xb0>
        setkilled(p);
    800028b8:	8526                	mv	a0,s1
    800028ba:	b1dff0ef          	jal	ra,800023d6 <setkilled>
    800028be:	a035                	j	800028ea <usertrap+0xb0>
    panic("usertrap: not from user mode");
    800028c0:	00006517          	auipc	a0,0x6
    800028c4:	a0050513          	addi	a0,a0,-1536 # 800082c0 <states.0+0x58>
    800028c8:	ec1fd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    800028cc:	b2fff0ef          	jal	ra,800023fa <killed>
    800028d0:	e121                	bnez	a0,80002910 <usertrap+0xd6>
    p->trapframe->epc += 4;
    800028d2:	6cb8                	ld	a4,88(s1)
    800028d4:	6f1c                	ld	a5,24(a4)
    800028d6:	0791                	addi	a5,a5,4
    800028d8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028de:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028e2:	10079073          	csrw	sstatus,a5
    syscall();
    800028e6:	27c000ef          	jal	ra,80002b62 <syscall>
  if(killed(p))
    800028ea:	8526                	mv	a0,s1
    800028ec:	b0fff0ef          	jal	ra,800023fa <killed>
    800028f0:	ed35                	bnez	a0,8000296c <usertrap+0x132>
  prepare_return();
    800028f2:	e0bff0ef          	jal	ra,800026fc <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800028f6:	68a8                	ld	a0,80(s1)
    800028f8:	8131                	srli	a0,a0,0xc
    800028fa:	57fd                	li	a5,-1
    800028fc:	17fe                	slli	a5,a5,0x3f
    800028fe:	8d5d                	or	a0,a0,a5
}
    80002900:	70a2                	ld	ra,40(sp)
    80002902:	7402                	ld	s0,32(sp)
    80002904:	64e2                	ld	s1,24(sp)
    80002906:	6942                	ld	s2,16(sp)
    80002908:	69a2                	ld	s3,8(sp)
    8000290a:	6a02                	ld	s4,0(sp)
    8000290c:	6145                	addi	sp,sp,48
    8000290e:	8082                	ret
      kexit(-1);
    80002910:	557d                	li	a0,-1
    80002912:	9bdff0ef          	jal	ra,800022ce <kexit>
    80002916:	bf75                	j	800028d2 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002918:	4601                	li	a2,0
    8000291a:	85d2                	mv	a1,s4
    8000291c:	8526                	mv	a0,s1
    8000291e:	fc5fe0ef          	jal	ra,800018e2 <vmafault>
    80002922:	f561                	bnez	a0,800028ea <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002924:	4605                	li	a2,1
    80002926:	85d2                	mv	a1,s4
    80002928:	68a8                	ld	a0,80(s1)
    8000292a:	dcffe0ef          	jal	ra,800016f8 <vmfault>
    8000292e:	fd55                	bnez	a0,800028ea <usertrap+0xb0>
        setkilled(p);
    80002930:	8526                	mv	a0,s1
    80002932:	aa5ff0ef          	jal	ra,800023d6 <setkilled>
    80002936:	bf55                	j	800028ea <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002938:	5890                	lw	a2,48(s1)
    8000293a:	85ce                	mv	a1,s3
    8000293c:	00006517          	auipc	a0,0x6
    80002940:	9a450513          	addi	a0,a0,-1628 # 800082e0 <states.0+0x78>
    80002944:	b7ffd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002948:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    8000294c:	8652                	mv	a2,s4
    8000294e:	00006517          	auipc	a0,0x6
    80002952:	9c250513          	addi	a0,a0,-1598 # 80008310 <states.0+0xa8>
    80002956:	b6dfd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    8000295a:	8526                	mv	a0,s1
    8000295c:	a7bff0ef          	jal	ra,800023d6 <setkilled>
    80002960:	b769                	j	800028ea <usertrap+0xb0>
  if(killed(p))
    80002962:	8526                	mv	a0,s1
    80002964:	a97ff0ef          	jal	ra,800023fa <killed>
    80002968:	c511                	beqz	a0,80002974 <usertrap+0x13a>
    8000296a:	a011                	j	8000296e <usertrap+0x134>
    8000296c:	4901                	li	s2,0
    kexit(-1);
    8000296e:	557d                	li	a0,-1
    80002970:	95fff0ef          	jal	ra,800022ce <kexit>
  if(which_dev == 2)
    80002974:	4789                	li	a5,2
    80002976:	f6f91ee3          	bne	s2,a5,800028f2 <usertrap+0xb8>
    yield();
    8000297a:	81dff0ef          	jal	ra,80002196 <yield>
    8000297e:	bf95                	j	800028f2 <usertrap+0xb8>

0000000080002980 <kerneltrap>:
{
    80002980:	7179                	addi	sp,sp,-48
    80002982:	f406                	sd	ra,40(sp)
    80002984:	f022                	sd	s0,32(sp)
    80002986:	ec26                	sd	s1,24(sp)
    80002988:	e84a                	sd	s2,16(sp)
    8000298a:	e44e                	sd	s3,8(sp)
    8000298c:	1800                	addi	s0,sp,48
    8000298e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002992:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002996:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000299a:	1004f793          	andi	a5,s1,256
    8000299e:	c795                	beqz	a5,800029ca <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029a4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029a6:	eb85                	bnez	a5,800029d6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800029a8:	e23ff0ef          	jal	ra,800027ca <devintr>
    800029ac:	c91d                	beqz	a0,800029e2 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800029ae:	4789                	li	a5,2
    800029b0:	04f50a63          	beq	a0,a5,80002a04 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029b4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029b8:	10049073          	csrw	sstatus,s1
}
    800029bc:	70a2                	ld	ra,40(sp)
    800029be:	7402                	ld	s0,32(sp)
    800029c0:	64e2                	ld	s1,24(sp)
    800029c2:	6942                	ld	s2,16(sp)
    800029c4:	69a2                	ld	s3,8(sp)
    800029c6:	6145                	addi	sp,sp,48
    800029c8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ca:	00006517          	auipc	a0,0x6
    800029ce:	96e50513          	addi	a0,a0,-1682 # 80008338 <states.0+0xd0>
    800029d2:	db7fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    800029d6:	00006517          	auipc	a0,0x6
    800029da:	98a50513          	addi	a0,a0,-1654 # 80008360 <states.0+0xf8>
    800029de:	dabfd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800029ea:	85ce                	mv	a1,s3
    800029ec:	00006517          	auipc	a0,0x6
    800029f0:	99450513          	addi	a0,a0,-1644 # 80008380 <states.0+0x118>
    800029f4:	acffd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    800029f8:	00006517          	auipc	a0,0x6
    800029fc:	9b050513          	addi	a0,a0,-1616 # 800083a8 <states.0+0x140>
    80002a00:	d89fd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002a04:	934ff0ef          	jal	ra,80001b38 <myproc>
    80002a08:	d555                	beqz	a0,800029b4 <kerneltrap+0x34>
    yield();
    80002a0a:	f8cff0ef          	jal	ra,80002196 <yield>
    80002a0e:	b75d                	j	800029b4 <kerneltrap+0x34>

0000000080002a10 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a10:	1101                	addi	sp,sp,-32
    80002a12:	ec06                	sd	ra,24(sp)
    80002a14:	e822                	sd	s0,16(sp)
    80002a16:	e426                	sd	s1,8(sp)
    80002a18:	1000                	addi	s0,sp,32
    80002a1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a1c:	91cff0ef          	jal	ra,80001b38 <myproc>
  switch (n) {
    80002a20:	4795                	li	a5,5
    80002a22:	0497e163          	bltu	a5,s1,80002a64 <argraw+0x54>
    80002a26:	048a                	slli	s1,s1,0x2
    80002a28:	00006717          	auipc	a4,0x6
    80002a2c:	9b870713          	addi	a4,a4,-1608 # 800083e0 <states.0+0x178>
    80002a30:	94ba                	add	s1,s1,a4
    80002a32:	409c                	lw	a5,0(s1)
    80002a34:	97ba                	add	a5,a5,a4
    80002a36:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a38:	6d3c                	ld	a5,88(a0)
    80002a3a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a3c:	60e2                	ld	ra,24(sp)
    80002a3e:	6442                	ld	s0,16(sp)
    80002a40:	64a2                	ld	s1,8(sp)
    80002a42:	6105                	addi	sp,sp,32
    80002a44:	8082                	ret
    return p->trapframe->a1;
    80002a46:	6d3c                	ld	a5,88(a0)
    80002a48:	7fa8                	ld	a0,120(a5)
    80002a4a:	bfcd                	j	80002a3c <argraw+0x2c>
    return p->trapframe->a2;
    80002a4c:	6d3c                	ld	a5,88(a0)
    80002a4e:	63c8                	ld	a0,128(a5)
    80002a50:	b7f5                	j	80002a3c <argraw+0x2c>
    return p->trapframe->a3;
    80002a52:	6d3c                	ld	a5,88(a0)
    80002a54:	67c8                	ld	a0,136(a5)
    80002a56:	b7dd                	j	80002a3c <argraw+0x2c>
    return p->trapframe->a4;
    80002a58:	6d3c                	ld	a5,88(a0)
    80002a5a:	6bc8                	ld	a0,144(a5)
    80002a5c:	b7c5                	j	80002a3c <argraw+0x2c>
    return p->trapframe->a5;
    80002a5e:	6d3c                	ld	a5,88(a0)
    80002a60:	6fc8                	ld	a0,152(a5)
    80002a62:	bfe9                	j	80002a3c <argraw+0x2c>
  panic("argraw");
    80002a64:	00006517          	auipc	a0,0x6
    80002a68:	95450513          	addi	a0,a0,-1708 # 800083b8 <states.0+0x150>
    80002a6c:	d1dfd0ef          	jal	ra,80000788 <panic>

0000000080002a70 <fetchaddr>:
{
    80002a70:	1101                	addi	sp,sp,-32
    80002a72:	ec06                	sd	ra,24(sp)
    80002a74:	e822                	sd	s0,16(sp)
    80002a76:	e426                	sd	s1,8(sp)
    80002a78:	e04a                	sd	s2,0(sp)
    80002a7a:	1000                	addi	s0,sp,32
    80002a7c:	84aa                	mv	s1,a0
    80002a7e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a80:	8b8ff0ef          	jal	ra,80001b38 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a84:	653c                	ld	a5,72(a0)
    80002a86:	02f4f663          	bgeu	s1,a5,80002ab2 <fetchaddr+0x42>
    80002a8a:	00848713          	addi	a4,s1,8
    80002a8e:	02e7e463          	bltu	a5,a4,80002ab6 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a92:	46a1                	li	a3,8
    80002a94:	8626                	mv	a2,s1
    80002a96:	85ca                	mv	a1,s2
    80002a98:	6928                	ld	a0,80(a0)
    80002a9a:	dbbfe0ef          	jal	ra,80001854 <copyin>
    80002a9e:	00a03533          	snez	a0,a0
    80002aa2:	40a00533          	neg	a0,a0
}
    80002aa6:	60e2                	ld	ra,24(sp)
    80002aa8:	6442                	ld	s0,16(sp)
    80002aaa:	64a2                	ld	s1,8(sp)
    80002aac:	6902                	ld	s2,0(sp)
    80002aae:	6105                	addi	sp,sp,32
    80002ab0:	8082                	ret
    return -1;
    80002ab2:	557d                	li	a0,-1
    80002ab4:	bfcd                	j	80002aa6 <fetchaddr+0x36>
    80002ab6:	557d                	li	a0,-1
    80002ab8:	b7fd                	j	80002aa6 <fetchaddr+0x36>

0000000080002aba <fetchstr>:
{
    80002aba:	7179                	addi	sp,sp,-48
    80002abc:	f406                	sd	ra,40(sp)
    80002abe:	f022                	sd	s0,32(sp)
    80002ac0:	ec26                	sd	s1,24(sp)
    80002ac2:	e84a                	sd	s2,16(sp)
    80002ac4:	e44e                	sd	s3,8(sp)
    80002ac6:	1800                	addi	s0,sp,48
    80002ac8:	892a                	mv	s2,a0
    80002aca:	84ae                	mv	s1,a1
    80002acc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ace:	86aff0ef          	jal	ra,80001b38 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ad2:	86ce                	mv	a3,s3
    80002ad4:	864a                	mv	a2,s2
    80002ad6:	85a6                	mv	a1,s1
    80002ad8:	6928                	ld	a0,80(a0)
    80002ada:	b53fe0ef          	jal	ra,8000162c <copyinstr>
    80002ade:	00054c63          	bltz	a0,80002af6 <fetchstr+0x3c>
  return strlen(buf);
    80002ae2:	8526                	mv	a0,s1
    80002ae4:	c08fe0ef          	jal	ra,80000eec <strlen>
}
    80002ae8:	70a2                	ld	ra,40(sp)
    80002aea:	7402                	ld	s0,32(sp)
    80002aec:	64e2                	ld	s1,24(sp)
    80002aee:	6942                	ld	s2,16(sp)
    80002af0:	69a2                	ld	s3,8(sp)
    80002af2:	6145                	addi	sp,sp,48
    80002af4:	8082                	ret
    return -1;
    80002af6:	557d                	li	a0,-1
    80002af8:	bfc5                	j	80002ae8 <fetchstr+0x2e>

0000000080002afa <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002afa:	1101                	addi	sp,sp,-32
    80002afc:	ec06                	sd	ra,24(sp)
    80002afe:	e822                	sd	s0,16(sp)
    80002b00:	e426                	sd	s1,8(sp)
    80002b02:	1000                	addi	s0,sp,32
    80002b04:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b06:	f0bff0ef          	jal	ra,80002a10 <argraw>
    80002b0a:	c088                	sw	a0,0(s1)
}
    80002b0c:	60e2                	ld	ra,24(sp)
    80002b0e:	6442                	ld	s0,16(sp)
    80002b10:	64a2                	ld	s1,8(sp)
    80002b12:	6105                	addi	sp,sp,32
    80002b14:	8082                	ret

0000000080002b16 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b16:	1101                	addi	sp,sp,-32
    80002b18:	ec06                	sd	ra,24(sp)
    80002b1a:	e822                	sd	s0,16(sp)
    80002b1c:	e426                	sd	s1,8(sp)
    80002b1e:	1000                	addi	s0,sp,32
    80002b20:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b22:	eefff0ef          	jal	ra,80002a10 <argraw>
    80002b26:	e088                	sd	a0,0(s1)
}
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret

0000000080002b32 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b32:	7179                	addi	sp,sp,-48
    80002b34:	f406                	sd	ra,40(sp)
    80002b36:	f022                	sd	s0,32(sp)
    80002b38:	ec26                	sd	s1,24(sp)
    80002b3a:	e84a                	sd	s2,16(sp)
    80002b3c:	1800                	addi	s0,sp,48
    80002b3e:	84ae                	mv	s1,a1
    80002b40:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b42:	fd840593          	addi	a1,s0,-40
    80002b46:	fd1ff0ef          	jal	ra,80002b16 <argaddr>
  return fetchstr(addr, buf, max);
    80002b4a:	864a                	mv	a2,s2
    80002b4c:	85a6                	mv	a1,s1
    80002b4e:	fd843503          	ld	a0,-40(s0)
    80002b52:	f69ff0ef          	jal	ra,80002aba <fetchstr>
}
    80002b56:	70a2                	ld	ra,40(sp)
    80002b58:	7402                	ld	s0,32(sp)
    80002b5a:	64e2                	ld	s1,24(sp)
    80002b5c:	6942                	ld	s2,16(sp)
    80002b5e:	6145                	addi	sp,sp,48
    80002b60:	8082                	ret

0000000080002b62 <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80002b62:	1101                	addi	sp,sp,-32
    80002b64:	ec06                	sd	ra,24(sp)
    80002b66:	e822                	sd	s0,16(sp)
    80002b68:	e426                	sd	s1,8(sp)
    80002b6a:	e04a                	sd	s2,0(sp)
    80002b6c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b6e:	fcbfe0ef          	jal	ra,80001b38 <myproc>
    80002b72:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b74:	05853903          	ld	s2,88(a0)
    80002b78:	0a893783          	ld	a5,168(s2)
    80002b7c:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b80:	37fd                	addiw	a5,a5,-1
    80002b82:	4759                	li	a4,22
    80002b84:	00f76f63          	bltu	a4,a5,80002ba2 <syscall+0x40>
    80002b88:	00369713          	slli	a4,a3,0x3
    80002b8c:	00006797          	auipc	a5,0x6
    80002b90:	86c78793          	addi	a5,a5,-1940 # 800083f8 <syscalls>
    80002b94:	97ba                	add	a5,a5,a4
    80002b96:	639c                	ld	a5,0(a5)
    80002b98:	c789                	beqz	a5,80002ba2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b9a:	9782                	jalr	a5
    80002b9c:	06a93823          	sd	a0,112(s2)
    80002ba0:	a829                	j	80002bba <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ba2:	15848613          	addi	a2,s1,344
    80002ba6:	588c                	lw	a1,48(s1)
    80002ba8:	00006517          	auipc	a0,0x6
    80002bac:	81850513          	addi	a0,a0,-2024 # 800083c0 <states.0+0x158>
    80002bb0:	913fd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bb4:	6cbc                	ld	a5,88(s1)
    80002bb6:	577d                	li	a4,-1
    80002bb8:	fbb8                	sd	a4,112(a5)
  }
}
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	64a2                	ld	s1,8(sp)
    80002bc0:	6902                	ld	s2,0(sp)
    80002bc2:	6105                	addi	sp,sp,32
    80002bc4:	8082                	ret

0000000080002bc6 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002bc6:	1101                	addi	sp,sp,-32
    80002bc8:	ec06                	sd	ra,24(sp)
    80002bca:	e822                	sd	s0,16(sp)
    80002bcc:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bce:	fec40593          	addi	a1,s0,-20
    80002bd2:	4501                	li	a0,0
    80002bd4:	f27ff0ef          	jal	ra,80002afa <argint>
  kexit(n);
    80002bd8:	fec42503          	lw	a0,-20(s0)
    80002bdc:	ef2ff0ef          	jal	ra,800022ce <kexit>
  return 0;  // not reached
}
    80002be0:	4501                	li	a0,0
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	6105                	addi	sp,sp,32
    80002be8:	8082                	ret

0000000080002bea <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bea:	1141                	addi	sp,sp,-16
    80002bec:	e406                	sd	ra,8(sp)
    80002bee:	e022                	sd	s0,0(sp)
    80002bf0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bf2:	f47fe0ef          	jal	ra,80001b38 <myproc>
}
    80002bf6:	5908                	lw	a0,48(a0)
    80002bf8:	60a2                	ld	ra,8(sp)
    80002bfa:	6402                	ld	s0,0(sp)
    80002bfc:	0141                	addi	sp,sp,16
    80002bfe:	8082                	ret

0000000080002c00 <sys_fork>:

uint64
sys_fork(void)
{
    80002c00:	1141                	addi	sp,sp,-16
    80002c02:	e406                	sd	ra,8(sp)
    80002c04:	e022                	sd	s0,0(sp)
    80002c06:	0800                	addi	s0,sp,16
  return kfork();
    80002c08:	afaff0ef          	jal	ra,80001f02 <kfork>
}
    80002c0c:	60a2                	ld	ra,8(sp)
    80002c0e:	6402                	ld	s0,0(sp)
    80002c10:	0141                	addi	sp,sp,16
    80002c12:	8082                	ret

0000000080002c14 <sys_wait>:

uint64
sys_wait(void)
{
    80002c14:	1101                	addi	sp,sp,-32
    80002c16:	ec06                	sd	ra,24(sp)
    80002c18:	e822                	sd	s0,16(sp)
    80002c1a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c1c:	fe840593          	addi	a1,s0,-24
    80002c20:	4501                	li	a0,0
    80002c22:	ef5ff0ef          	jal	ra,80002b16 <argaddr>
  return kwait(p);
    80002c26:	fe843503          	ld	a0,-24(s0)
    80002c2a:	ffaff0ef          	jal	ra,80002424 <kwait>
}
    80002c2e:	60e2                	ld	ra,24(sp)
    80002c30:	6442                	ld	s0,16(sp)
    80002c32:	6105                	addi	sp,sp,32
    80002c34:	8082                	ret

0000000080002c36 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c36:	7179                	addi	sp,sp,-48
    80002c38:	f406                	sd	ra,40(sp)
    80002c3a:	f022                	sd	s0,32(sp)
    80002c3c:	ec26                	sd	s1,24(sp)
    80002c3e:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002c40:	fd840593          	addi	a1,s0,-40
    80002c44:	4501                	li	a0,0
    80002c46:	eb5ff0ef          	jal	ra,80002afa <argint>
  argint(1, &t);
    80002c4a:	fdc40593          	addi	a1,s0,-36
    80002c4e:	4505                	li	a0,1
    80002c50:	eabff0ef          	jal	ra,80002afa <argint>
  addr = myproc()->sz;
    80002c54:	ee5fe0ef          	jal	ra,80001b38 <myproc>
    80002c58:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002c5a:	fdc42703          	lw	a4,-36(s0)
    80002c5e:	4785                	li	a5,1
    80002c60:	02f70763          	beq	a4,a5,80002c8e <sys_sbrk+0x58>
    80002c64:	fd842783          	lw	a5,-40(s0)
    80002c68:	0207c363          	bltz	a5,80002c8e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002c6c:	97a6                	add	a5,a5,s1
    80002c6e:	0297ee63          	bltu	a5,s1,80002caa <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002c72:	02000737          	lui	a4,0x2000
    80002c76:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002c78:	0736                	slli	a4,a4,0xd
    80002c7a:	02f76a63          	bltu	a4,a5,80002cae <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002c7e:	ebbfe0ef          	jal	ra,80001b38 <myproc>
    80002c82:	fd842703          	lw	a4,-40(s0)
    80002c86:	653c                	ld	a5,72(a0)
    80002c88:	97ba                	add	a5,a5,a4
    80002c8a:	e53c                	sd	a5,72(a0)
    80002c8c:	a039                	j	80002c9a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002c8e:	fd842503          	lw	a0,-40(s0)
    80002c92:	a0eff0ef          	jal	ra,80001ea0 <growproc>
    80002c96:	00054863          	bltz	a0,80002ca6 <sys_sbrk+0x70>
  }
  return addr;
}
    80002c9a:	8526                	mv	a0,s1
    80002c9c:	70a2                	ld	ra,40(sp)
    80002c9e:	7402                	ld	s0,32(sp)
    80002ca0:	64e2                	ld	s1,24(sp)
    80002ca2:	6145                	addi	sp,sp,48
    80002ca4:	8082                	ret
      return -1;
    80002ca6:	54fd                	li	s1,-1
    80002ca8:	bfcd                	j	80002c9a <sys_sbrk+0x64>
      return -1;
    80002caa:	54fd                	li	s1,-1
    80002cac:	b7fd                	j	80002c9a <sys_sbrk+0x64>
      return -1;
    80002cae:	54fd                	li	s1,-1
    80002cb0:	b7ed                	j	80002c9a <sys_sbrk+0x64>

0000000080002cb2 <sys_pause>:

uint64
sys_pause(void)
{
    80002cb2:	7139                	addi	sp,sp,-64
    80002cb4:	fc06                	sd	ra,56(sp)
    80002cb6:	f822                	sd	s0,48(sp)
    80002cb8:	f426                	sd	s1,40(sp)
    80002cba:	f04a                	sd	s2,32(sp)
    80002cbc:	ec4e                	sd	s3,24(sp)
    80002cbe:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cc0:	fcc40593          	addi	a1,s0,-52
    80002cc4:	4501                	li	a0,0
    80002cc6:	e35ff0ef          	jal	ra,80002afa <argint>
  if(n < 0)
    80002cca:	fcc42783          	lw	a5,-52(s0)
    80002cce:	0607c563          	bltz	a5,80002d38 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002cd2:	0023e517          	auipc	a0,0x23e
    80002cd6:	b0e50513          	addi	a0,a0,-1266 # 802407e0 <tickslock>
    80002cda:	fc7fd0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002cde:	00006917          	auipc	s2,0x6
    80002ce2:	bba92903          	lw	s2,-1094(s2) # 80008898 <ticks>
  while(ticks - ticks0 < n){
    80002ce6:	fcc42783          	lw	a5,-52(s0)
    80002cea:	cb8d                	beqz	a5,80002d1c <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cec:	0023e997          	auipc	s3,0x23e
    80002cf0:	af498993          	addi	s3,s3,-1292 # 802407e0 <tickslock>
    80002cf4:	00006497          	auipc	s1,0x6
    80002cf8:	ba448493          	addi	s1,s1,-1116 # 80008898 <ticks>
    if(killed(myproc())){
    80002cfc:	e3dfe0ef          	jal	ra,80001b38 <myproc>
    80002d00:	efaff0ef          	jal	ra,800023fa <killed>
    80002d04:	ed0d                	bnez	a0,80002d3e <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002d06:	85ce                	mv	a1,s3
    80002d08:	8526                	mv	a0,s1
    80002d0a:	cb8ff0ef          	jal	ra,800021c2 <sleep>
  while(ticks - ticks0 < n){
    80002d0e:	409c                	lw	a5,0(s1)
    80002d10:	412787bb          	subw	a5,a5,s2
    80002d14:	fcc42703          	lw	a4,-52(s0)
    80002d18:	fee7e2e3          	bltu	a5,a4,80002cfc <sys_pause+0x4a>
  }
  release(&tickslock);
    80002d1c:	0023e517          	auipc	a0,0x23e
    80002d20:	ac450513          	addi	a0,a0,-1340 # 802407e0 <tickslock>
    80002d24:	814fe0ef          	jal	ra,80000d38 <release>
  return 0;
    80002d28:	4501                	li	a0,0
}
    80002d2a:	70e2                	ld	ra,56(sp)
    80002d2c:	7442                	ld	s0,48(sp)
    80002d2e:	74a2                	ld	s1,40(sp)
    80002d30:	7902                	ld	s2,32(sp)
    80002d32:	69e2                	ld	s3,24(sp)
    80002d34:	6121                	addi	sp,sp,64
    80002d36:	8082                	ret
    n = 0;
    80002d38:	fc042623          	sw	zero,-52(s0)
    80002d3c:	bf59                	j	80002cd2 <sys_pause+0x20>
      release(&tickslock);
    80002d3e:	0023e517          	auipc	a0,0x23e
    80002d42:	aa250513          	addi	a0,a0,-1374 # 802407e0 <tickslock>
    80002d46:	ff3fd0ef          	jal	ra,80000d38 <release>
      return -1;
    80002d4a:	557d                	li	a0,-1
    80002d4c:	bff9                	j	80002d2a <sys_pause+0x78>

0000000080002d4e <sys_kill>:

uint64
sys_kill(void)
{
    80002d4e:	1101                	addi	sp,sp,-32
    80002d50:	ec06                	sd	ra,24(sp)
    80002d52:	e822                	sd	s0,16(sp)
    80002d54:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d56:	fec40593          	addi	a1,s0,-20
    80002d5a:	4501                	li	a0,0
    80002d5c:	d9fff0ef          	jal	ra,80002afa <argint>
  return kkill(pid);
    80002d60:	fec42503          	lw	a0,-20(s0)
    80002d64:	e0cff0ef          	jal	ra,80002370 <kkill>
}
    80002d68:	60e2                	ld	ra,24(sp)
    80002d6a:	6442                	ld	s0,16(sp)
    80002d6c:	6105                	addi	sp,sp,32
    80002d6e:	8082                	ret

0000000080002d70 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d70:	1101                	addi	sp,sp,-32
    80002d72:	ec06                	sd	ra,24(sp)
    80002d74:	e822                	sd	s0,16(sp)
    80002d76:	e426                	sd	s1,8(sp)
    80002d78:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d7a:	0023e517          	auipc	a0,0x23e
    80002d7e:	a6650513          	addi	a0,a0,-1434 # 802407e0 <tickslock>
    80002d82:	f1ffd0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    80002d86:	00006497          	auipc	s1,0x6
    80002d8a:	b124a483          	lw	s1,-1262(s1) # 80008898 <ticks>
  release(&tickslock);
    80002d8e:	0023e517          	auipc	a0,0x23e
    80002d92:	a5250513          	addi	a0,a0,-1454 # 802407e0 <tickslock>
    80002d96:	fa3fd0ef          	jal	ra,80000d38 <release>
  return xticks;
}
    80002d9a:	02049513          	slli	a0,s1,0x20
    80002d9e:	9101                	srli	a0,a0,0x20
    80002da0:	60e2                	ld	ra,24(sp)
    80002da2:	6442                	ld	s0,16(sp)
    80002da4:	64a2                	ld	s1,8(sp)
    80002da6:	6105                	addi	sp,sp,32
    80002da8:	8082                	ret

0000000080002daa <vma_find>:
  return 0;
}

struct vma*
vma_find(struct proc *p, uint64 va)
{
    80002daa:	1141                	addi	sp,sp,-16
    80002dac:	e422                	sd	s0,8(sp)
    80002dae:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002db0:	16850793          	addi	a5,a0,360
    80002db4:	4701                	li	a4,0
    80002db6:	4841                	li	a6,16
    80002db8:	a031                	j	80002dc4 <vma_find+0x1a>
    80002dba:	2705                	addiw	a4,a4,1
    80002dbc:	02878793          	addi	a5,a5,40
    80002dc0:	03070263          	beq	a4,a6,80002de4 <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    80002dc4:	4394                	lw	a3,0(a5)
    80002dc6:	daf5                	beqz	a3,80002dba <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    80002dc8:	6794                	ld	a3,8(a5)
    80002dca:	fed5e8e3          	bltu	a1,a3,80002dba <vma_find+0x10>
    80002dce:	6b94                	ld	a3,16(a5)
    80002dd0:	fed5f5e3          	bgeu	a1,a3,80002dba <vma_find+0x10>
      return &p->vmas[i];
    80002dd4:	00271793          	slli	a5,a4,0x2
    80002dd8:	97ba                	add	a5,a5,a4
    80002dda:	078e                	slli	a5,a5,0x3
    80002ddc:	16878793          	addi	a5,a5,360
    80002de0:	953e                	add	a0,a0,a5
    80002de2:	a011                	j	80002de6 <vma_find+0x3c>
  }
  return 0;
    80002de4:	4501                	li	a0,0
}
    80002de6:	6422                	ld	s0,8(sp)
    80002de8:	0141                	addi	sp,sp,16
    80002dea:	8082                	ret

0000000080002dec <sys_mmap>:
  return best;
}

uint64
sys_mmap(void)
{
    80002dec:	711d                	addi	sp,sp,-96
    80002dee:	ec86                	sd	ra,88(sp)
    80002df0:	e8a2                	sd	s0,80(sp)
    80002df2:	e4a6                	sd	s1,72(sp)
    80002df4:	e0ca                	sd	s2,64(sp)
    80002df6:	fc4e                	sd	s3,56(sp)
    80002df8:	f852                	sd	s4,48(sp)
    80002dfa:	f456                	sd	s5,40(sp)
    80002dfc:	1080                	addi	s0,sp,96
  uint64 addr;
  int len, prot, flags, key = -1;
    80002dfe:	57fd                	li	a5,-1
    80002e00:	faf42423          	sw	a5,-88(s0)

  argaddr(0, &addr);
    80002e04:	fb840593          	addi	a1,s0,-72
    80002e08:	4501                	li	a0,0
    80002e0a:	d0dff0ef          	jal	ra,80002b16 <argaddr>
  argint(1, &len);
    80002e0e:	fb440593          	addi	a1,s0,-76
    80002e12:	4505                	li	a0,1
    80002e14:	ce7ff0ef          	jal	ra,80002afa <argint>
  argint(2, &prot);
    80002e18:	fb040593          	addi	a1,s0,-80
    80002e1c:	4509                	li	a0,2
    80002e1e:	cddff0ef          	jal	ra,80002afa <argint>
  argint(3, &flags);
    80002e22:	fac40593          	addi	a1,s0,-84
    80002e26:	450d                	li	a0,3
    80002e28:	cd3ff0ef          	jal	ra,80002afa <argint>
  argint(4, &key);
    80002e2c:	fa840593          	addi	a1,s0,-88
    80002e30:	4511                	li	a0,4
    80002e32:	cc9ff0ef          	jal	ra,80002afa <argint>

  if(len <= 0) return -1;
    80002e36:	fb442a83          	lw	s5,-76(s0)
    80002e3a:	13505763          	blez	s5,80002f68 <sys_mmap+0x17c>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return -1;                
  if(plen > (MMAPTOP - MMAPBASE)) return -1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return -1;  
    80002e3e:	fb042483          	lw	s1,-80(s0)
    80002e42:	98f1                	andi	s1,s1,-4
    80002e44:	5a7d                	li	s4,-1
    80002e46:	12049263          	bnez	s1,80002f6a <sys_mmap+0x17e>
  if((flags & MAP_ANON) == 0) return -1;
    80002e4a:	fac42783          	lw	a5,-84(s0)
    80002e4e:	8b85                	andi	a5,a5,1
    80002e50:	10078d63          	beqz	a5,80002f6a <sys_mmap+0x17e>
  if(addr != 0) return -1;            
    80002e54:	fb843903          	ld	s2,-72(s0)
    80002e58:	10091963          	bnez	s2,80002f6a <sys_mmap+0x17e>

  struct proc *p = myproc();
    80002e5c:	cddfe0ef          	jal	ra,80001b38 <myproc>
    80002e60:	89aa                	mv	s3,a0
  for(int i = 0; i < NVMA; i++){
    80002e62:	16850e13          	addi	t3,a0,360
  struct proc *p = myproc();
    80002e66:	87f2                	mv	a5,t3
  for(int i = 0; i < NVMA; i++){
    80002e68:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    80002e6a:	4398                	lw	a4,0(a5)
    80002e6c:	cb01                	beqz	a4,80002e7c <sys_mmap+0x90>
  for(int i = 0; i < NVMA; i++){
    80002e6e:	2485                	addiw	s1,s1,1
    80002e70:	02878793          	addi	a5,a5,40
    80002e74:	fed49be3          	bne	s1,a3,80002e6a <sys_mmap+0x7e>

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    80002e78:	5a7d                	li	s4,-1
    80002e7a:	a8c5                	j	80002f6a <sys_mmap+0x17e>
  uint64 plen = PGROUNDUP((uint64)len);
    80002e7c:	6785                	lui	a5,0x1
    80002e7e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002e80:	00fa85b3          	add	a1,s5,a5
    80002e84:	777d                	lui	a4,0xfffff
    80002e86:	00e5ff33          	and	t5,a1,a4
  len = PGROUNDUP(len);
    80002e8a:	97fa                	add	a5,a5,t5
    80002e8c:	00e7f8b3          	and	a7,a5,a4
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80002e90:	40000837          	lui	a6,0x40000
    80002e94:	9846                	add	a6,a6,a7
    80002e96:	40000a37          	lui	s4,0x40000
    80002e9a:	3e898613          	addi	a2,s3,1000
    va = PGROUNDUP(jump);
    80002e9e:	6e85                	lui	t4,0x1
    80002ea0:	1efd                	addi	t4,t4,-1 # fff <_entry-0x7ffff001>
    80002ea2:	7ffd                	lui	t6,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80002ea4:	f3fff337          	lui	t1,0xf3fff
    80002ea8:	033a                	slli	t1,t1,0xe
    80002eaa:	01a35313          	srli	t1,t1,0x1a
    80002eae:	a81d                	j	80002ee4 <sys_mmap+0xf8>
      if(best == 0 || e < best) best = e;
    80002eb0:	853a                	mv	a0,a4
  for(int i=0;i<NVMA;i++){
    80002eb2:	02878793          	addi	a5,a5,40
    80002eb6:	00c78f63          	beq	a5,a2,80002ed4 <sys_mmap+0xe8>
    if(!p->vmas[i].used) continue;
    80002eba:	4398                	lw	a4,0(a5)
    80002ebc:	db7d                	beqz	a4,80002eb2 <sys_mmap+0xc6>
    if(!(end <= s || start >= e)){
    80002ebe:	6798                	ld	a4,8(a5)
    80002ec0:	ff0779e3          	bgeu	a4,a6,80002eb2 <sys_mmap+0xc6>
    uint64 e = p->vmas[i].end;
    80002ec4:	6b98                	ld	a4,16(a5)
    if(!(end <= s || start >= e)){
    80002ec6:	feea76e3          	bgeu	s4,a4,80002eb2 <sys_mmap+0xc6>
      if(best == 0 || e < best) best = e;
    80002eca:	d17d                	beqz	a0,80002eb0 <sys_mmap+0xc4>
    80002ecc:	fea773e3          	bgeu	a4,a0,80002eb2 <sys_mmap+0xc6>
    80002ed0:	853a                	mv	a0,a4
    80002ed2:	b7c5                	j	80002eb2 <sys_mmap+0xc6>
    if(jump == 0){
    80002ed4:	c919                	beqz	a0,80002eea <sys_mmap+0xfe>
    va = PGROUNDUP(jump);
    80002ed6:	9576                	add	a0,a0,t4
    80002ed8:	01f57a33          	and	s4,a0,t6
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80002edc:	01488833          	add	a6,a7,s4
    80002ee0:	09036f63          	bltu	t1,a6,80002f7e <sys_mmap+0x192>
  struct proc *p = myproc();
    80002ee4:	87f2                	mv	a5,t3
  uint64 best = 0;
    80002ee6:	854a                	mv	a0,s2
    80002ee8:	bfc9                	j	80002eba <sys_mmap+0xce>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) return (uint64)-1;
    80002eea:	080a0c63          	beqz	s4,80002f82 <sys_mmap+0x196>
  
  v->used = 1;
    80002eee:	00249793          	slli	a5,s1,0x2
    80002ef2:	97a6                	add	a5,a5,s1
    80002ef4:	078e                	slli	a5,a5,0x3
    80002ef6:	97ce                	add	a5,a5,s3
    80002ef8:	4705                	li	a4,1
    80002efa:	16e7a423          	sw	a4,360(a5)
  v->start = va;
    80002efe:	1747b823          	sd	s4,368(a5)
  v->end = va + plen;
    80002f02:	9f52                	add	t5,t5,s4
    80002f04:	17e7bc23          	sd	t5,376(a5)
  v->prot = prot;
    80002f08:	fb042703          	lw	a4,-80(s0)
    80002f0c:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    80002f10:	fac42703          	lw	a4,-84(s0)
    80002f14:	18e7a223          	sw	a4,388(a5)
  v->is_shm = 0;
    80002f18:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    80002f1c:	56fd                	li	a3,-1
    80002f1e:	18d7a623          	sw	a3,396(a5)

  if(va < MMAPBASE || va + plen > MMAPTOP) return (uint64)-1;
    80002f22:	400007b7          	lui	a5,0x40000
    80002f26:	06fa6063          	bltu	s4,a5,80002f86 <sys_mmap+0x19a>
    80002f2a:	010007b7          	lui	a5,0x1000
    80002f2e:	17f5                	addi	a5,a5,-3 # fffffd <_entry-0x7f000003>
    80002f30:	07ba                	slli	a5,a5,0xe
    80002f32:	05e7ec63          	bltu	a5,t5,80002f8a <sys_mmap+0x19e>

  if(flags & MAP_SHARED){
    80002f36:	8b09                	andi	a4,a4,2
    80002f38:	cb0d                	beqz	a4,80002f6a <sys_mmap+0x17e>
    if(key < 0) return (uint64)-1;
    80002f3a:	fa842503          	lw	a0,-88(s0)
    80002f3e:	04054863          	bltz	a0,80002f8e <sys_mmap+0x1a2>
    int npages = plen / PGSIZE;
    if(shm_get(key, npages) < 0) return (uint64)-1; 
    80002f42:	85b1                	srai	a1,a1,0xc
    80002f44:	168030ef          	jal	ra,800060ac <shm_get>
    80002f48:	04054563          	bltz	a0,80002f92 <sys_mmap+0x1a6>
    v->is_shm = 1;
    80002f4c:	00249793          	slli	a5,s1,0x2
    80002f50:	00978733          	add	a4,a5,s1
    80002f54:	070e                	slli	a4,a4,0x3
    80002f56:	974e                	add	a4,a4,s3
    80002f58:	4685                	li	a3,1
    80002f5a:	18d72423          	sw	a3,392(a4) # fffffffffffff188 <end+0xffffffff7fdab430>
    v->shm_key = key;
    80002f5e:	fa842783          	lw	a5,-88(s0)
    80002f62:	18f72623          	sw	a5,396(a4)
    80002f66:	a011                	j	80002f6a <sys_mmap+0x17e>
  if(len <= 0) return -1;
    80002f68:	5a7d                	li	s4,-1
  }

  return va;
}
    80002f6a:	8552                	mv	a0,s4
    80002f6c:	60e6                	ld	ra,88(sp)
    80002f6e:	6446                	ld	s0,80(sp)
    80002f70:	64a6                	ld	s1,72(sp)
    80002f72:	6906                	ld	s2,64(sp)
    80002f74:	79e2                	ld	s3,56(sp)
    80002f76:	7a42                	ld	s4,48(sp)
    80002f78:	7aa2                	ld	s5,40(sp)
    80002f7a:	6125                	addi	sp,sp,96
    80002f7c:	8082                	ret
  if(va == 0) return (uint64)-1;
    80002f7e:	5a7d                	li	s4,-1
    80002f80:	b7ed                	j	80002f6a <sys_mmap+0x17e>
    80002f82:	5a7d                	li	s4,-1
    80002f84:	b7dd                	j	80002f6a <sys_mmap+0x17e>
  if(va < MMAPBASE || va + plen > MMAPTOP) return (uint64)-1;
    80002f86:	5a7d                	li	s4,-1
    80002f88:	b7cd                	j	80002f6a <sys_mmap+0x17e>
    80002f8a:	5a7d                	li	s4,-1
    80002f8c:	bff9                	j	80002f6a <sys_mmap+0x17e>
    if(key < 0) return (uint64)-1;
    80002f8e:	5a7d                	li	s4,-1
    80002f90:	bfe9                	j	80002f6a <sys_mmap+0x17e>
    if(shm_get(key, npages) < 0) return (uint64)-1; 
    80002f92:	5a7d                	li	s4,-1
    80002f94:	bfd9                	j	80002f6a <sys_mmap+0x17e>

0000000080002f96 <sys_munmap>:


uint64
sys_munmap(void)
{
    80002f96:	7159                	addi	sp,sp,-112
    80002f98:	f486                	sd	ra,104(sp)
    80002f9a:	f0a2                	sd	s0,96(sp)
    80002f9c:	eca6                	sd	s1,88(sp)
    80002f9e:	e8ca                	sd	s2,80(sp)
    80002fa0:	e4ce                	sd	s3,72(sp)
    80002fa2:	e0d2                	sd	s4,64(sp)
    80002fa4:	fc56                	sd	s5,56(sp)
    80002fa6:	f85a                	sd	s6,48(sp)
    80002fa8:	f45e                	sd	s7,40(sp)
    80002faa:	f062                	sd	s8,32(sp)
    80002fac:	ec66                	sd	s9,24(sp)
    80002fae:	e86a                	sd	s10,16(sp)
    80002fb0:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    80002fb2:	b87fe0ef          	jal	ra,80001b38 <myproc>
    80002fb6:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    80002fb8:	f9840593          	addi	a1,s0,-104
    80002fbc:	4501                	li	a0,0
    80002fbe:	b59ff0ef          	jal	ra,80002b16 <argaddr>
  argint(1, &len);
    80002fc2:	f9440593          	addi	a1,s0,-108
    80002fc6:	4505                	li	a0,1
    80002fc8:	b33ff0ef          	jal	ra,80002afa <argint>

  if(len <= 0) return (uint64)-1;
    80002fcc:	f9442683          	lw	a3,-108(s0)
    80002fd0:	2ad05163          	blez	a3,80003272 <sys_munmap+0x2dc>


  uint64 a = PGROUNDDOWN(uaddr);
    80002fd4:	f9843783          	ld	a5,-104(s0)
    80002fd8:	767d                	lui	a2,0xfffff
    80002fda:	00c7fa33          	and	s4,a5,a2
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    80002fde:	6705                	lui	a4,0x1
    80002fe0:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002fe2:	00e78933          	add	s2,a5,a4
    80002fe6:	9936                	add	s2,s2,a3
    80002fe8:	00c97933          	and	s2,s2,a2
  if(b < a) return (uint64)-1;  // 溢出了
    80002fec:	557d                	li	a0,-1
    80002fee:	19496e63          	bltu	s2,s4,8000318a <sys_munmap+0x1f4>
    80002ff2:	168a8b13          	addi	s6,s5,360
    80002ff6:	3e8a8993          	addi	s3,s5,1000
    80002ffa:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    80002ffc:	4801                	li	a6,0
    80002ffe:	a029                	j	80003008 <sys_munmap+0x72>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    80003000:	02878793          	addi	a5,a5,40
    80003004:	01378663          	beq	a5,s3,80003010 <sys_munmap+0x7a>
    80003008:	4398                	lw	a4,0(a5)
    8000300a:	fb7d                	bnez	a4,80003000 <sys_munmap+0x6a>
    8000300c:	2805                	addiw	a6,a6,1 # 40000001 <_entry-0x3fffffff>
    8000300e:	bfcd                	j	80003000 <sys_munmap+0x6a>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    80003010:	8552                	mv	a0,s4
  int need_splits = 0;
    80003012:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    80003014:	4881                	li	a7,0
    80003016:	45c1                	li	a1,16
    80003018:	537d                	li	t1,-1
  while(cur < b){
    8000301a:	072a6163          	bltu	s4,s2,8000307c <sys_munmap+0xe6>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    8000301e:	43f85513          	srai	a0,a6,0x3f
    80003022:	a2a5                	j	8000318a <sys_munmap+0x1f4>
  for(int i = 0; i < NVMA; i++){
    80003024:	2705                	addiw	a4,a4,1
    80003026:	02878793          	addi	a5,a5,40
    8000302a:	04b70c63          	beq	a4,a1,80003082 <sys_munmap+0xec>
    if(!p->vmas[i].used) continue;
    8000302e:	4394                	lw	a3,0(a5)
    80003030:	daf5                	beqz	a3,80003024 <sys_munmap+0x8e>
    if(!(b <= s || a >= e))   // overlap
    80003032:	6794                	ld	a3,8(a5)
    80003034:	ff26f8e3          	bgeu	a3,s2,80003024 <sys_munmap+0x8e>
    80003038:	6b94                	ld	a3,16(a5)
    8000303a:	fed575e3          	bgeu	a0,a3,80003024 <sys_munmap+0x8e>
    if(vi < 0){
    8000303e:	04074563          	bltz	a4,80003088 <sys_munmap+0xf2>
    uint64 seg_start = cur > v->start ? cur : v->start;
    80003042:	00271793          	slli	a5,a4,0x2
    80003046:	97ba                	add	a5,a5,a4
    80003048:	078e                	slli	a5,a5,0x3
    8000304a:	97d6                	add	a5,a5,s5
    8000304c:	1707b683          	ld	a3,368(a5)
    80003050:	8636                	mv	a2,a3
    80003052:	00a6f363          	bgeu	a3,a0,80003058 <sys_munmap+0xc2>
    80003056:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003058:	00271793          	slli	a5,a4,0x2
    8000305c:	97ba                	add	a5,a5,a4
    8000305e:	078e                	slli	a5,a5,0x3
    80003060:	97d6                	add	a5,a5,s5
    80003062:	1787b783          	ld	a5,376(a5)
    80003066:	853e                	mv	a0,a5
    80003068:	00f97363          	bgeu	s2,a5,8000306e <sys_munmap+0xd8>
    8000306c:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    8000306e:	00c6f563          	bgeu	a3,a2,80003078 <sys_munmap+0xe2>
    80003072:	00f57363          	bgeu	a0,a5,80003078 <sys_munmap+0xe2>
      need_splits++;
    80003076:	2e05                	addiw	t3,t3,1
  while(cur < b){
    80003078:	03257a63          	bgeu	a0,s2,800030ac <sys_munmap+0x116>
  int free_slots = 0;
    8000307c:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    8000307e:	8746                	mv	a4,a7
    80003080:	b77d                	j	8000302e <sys_munmap+0x98>
    80003082:	87da                	mv	a5,s6
    80003084:	869a                	mv	a3,t1
    80003086:	a801                	j	80003096 <sys_munmap+0x100>
    80003088:	87da                	mv	a5,s6
    8000308a:	869a                	mv	a3,t1
    8000308c:	a029                	j	80003096 <sys_munmap+0x100>
  for(int i = 0; i < NVMA; i++){
    8000308e:	02878793          	addi	a5,a5,40
    80003092:	01378b63          	beq	a5,s3,800030a8 <sys_munmap+0x112>
    if(!p->vmas[i].used) continue;
    80003096:	4398                	lw	a4,0(a5)
    80003098:	db7d                	beqz	a4,8000308e <sys_munmap+0xf8>
    uint64 s = p->vmas[i].start;
    8000309a:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    8000309c:	fea769e3          	bltu	a4,a0,8000308e <sys_munmap+0xf8>
    800030a0:	fed777e3          	bgeu	a4,a3,8000308e <sys_munmap+0xf8>
    800030a4:	86ba                	mv	a3,a4
    800030a6:	b7e5                	j	8000308e <sys_munmap+0xf8>
      if(ns == (uint64)-1 || ns >= b) break;
    800030a8:	0126e963          	bltu	a3,s2,800030ba <sys_munmap+0x124>
    // 不做任何事，保持一致性
    return (uint64)-1;
    800030ac:	557d                	li	a0,-1
  if(need_splits > free_slots){
    800030ae:	0dc84e63          	blt	a6,t3,8000318a <sys_munmap+0x1f4>
  for(int i = 0; i < NVMA; i++){
    800030b2:	4c01                	li	s8,0
    800030b4:	4bc1                	li	s7,16
    800030b6:	5cfd                	li	s9,-1
    800030b8:	aa55                	j	8000326c <sys_munmap+0x2d6>
    800030ba:	8536                	mv	a0,a3
    800030bc:	b7c1                	j	8000307c <sys_munmap+0xe6>
    800030be:	2485                	addiw	s1,s1,1
    800030c0:	02878793          	addi	a5,a5,40
    800030c4:	09748d63          	beq	s1,s7,8000315e <sys_munmap+0x1c8>
    if(!p->vmas[i].used) continue;
    800030c8:	4398                	lw	a4,0(a5)
    800030ca:	db75                	beqz	a4,800030be <sys_munmap+0x128>
    if(!(b <= s || a >= e))   // overlap
    800030cc:	6798                	ld	a4,8(a5)
    800030ce:	ff2778e3          	bgeu	a4,s2,800030be <sys_munmap+0x128>
    800030d2:	6b98                	ld	a4,16(a5)
    800030d4:	feea75e3          	bgeu	s4,a4,800030be <sys_munmap+0x128>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    800030d8:	0804c663          	bltz	s1,80003164 <sys_munmap+0x1ce>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    800030dc:	00249793          	slli	a5,s1,0x2
    800030e0:	97a6                	add	a5,a5,s1
    800030e2:	078e                	slli	a5,a5,0x3
    800030e4:	97d6                	add	a5,a5,s5
    800030e6:	1707bd03          	ld	s10,368(a5)
    800030ea:	014d7363          	bgeu	s10,s4,800030f0 <sys_munmap+0x15a>
    800030ee:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    800030f0:	00249793          	slli	a5,s1,0x2
    800030f4:	97a6                	add	a5,a5,s1
    800030f6:	078e                	slli	a5,a5,0x3
    800030f8:	97d6                	add	a5,a5,s5
    800030fa:	1787ba03          	ld	s4,376(a5)
    800030fe:	01497363          	bgeu	s2,s4,80003104 <sys_munmap+0x16e>
    80003102:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    80003104:	0b4d6363          	bltu	s10,s4,800031aa <sys_munmap+0x214>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    80003108:	00249793          	slli	a5,s1,0x2
    8000310c:	97a6                	add	a5,a5,s1
    8000310e:	078e                	slli	a5,a5,0x3
    80003110:	97d6                	add	a5,a5,s5
    80003112:	1707b783          	ld	a5,368(a5)
    80003116:	0da7e663          	bltu	a5,s10,800031e2 <sys_munmap+0x24c>
    8000311a:	00249793          	slli	a5,s1,0x2
    8000311e:	97a6                	add	a5,a5,s1
    80003120:	078e                	slli	a5,a5,0x3
    80003122:	97d6                	add	a5,a5,s5
    80003124:	1787b783          	ld	a5,376(a5)
    80003128:	0afa6563          	bltu	s4,a5,800031d2 <sys_munmap+0x23c>
      // 覆盖整条VMA删除
      if(v->is_shm){
    8000312c:	00249793          	slli	a5,s1,0x2
    80003130:	97a6                	add	a5,a5,s1
    80003132:	078e                	slli	a5,a5,0x3
    80003134:	97d6                	add	a5,a5,s5
    80003136:	1887a783          	lw	a5,392(a5)
    8000313a:	e3d1                	bnez	a5,800031be <sys_munmap+0x228>
        shm_put(v->shm_key);
      }
      v->used = 0;
    8000313c:	00249793          	slli	a5,s1,0x2
    80003140:	00978733          	add	a4,a5,s1
    80003144:	070e                	slli	a4,a4,0x3
    80003146:	9756                	add	a4,a4,s5
    80003148:	16072423          	sw	zero,360(a4)
      v->start = v->end = 0;
    8000314c:	16073c23          	sd	zero,376(a4)
    80003150:	16073823          	sd	zero,368(a4)
      v->prot = v->flags = 0;
    80003154:	18072223          	sw	zero,388(a4)
    80003158:	18072023          	sw	zero,384(a4)
    8000315c:	a231                	j	80003268 <sys_munmap+0x2d2>
    8000315e:	87da                	mv	a5,s6
    80003160:	86e6                	mv	a3,s9
    80003162:	a801                	j	80003172 <sys_munmap+0x1dc>
    80003164:	87da                	mv	a5,s6
    80003166:	86e6                	mv	a3,s9
    80003168:	a029                	j	80003172 <sys_munmap+0x1dc>
  for(int i = 0; i < NVMA; i++){
    8000316a:	02878793          	addi	a5,a5,40
    8000316e:	01378b63          	beq	a5,s3,80003184 <sys_munmap+0x1ee>
    if(!p->vmas[i].used) continue;
    80003172:	4398                	lw	a4,0(a5)
    80003174:	db7d                	beqz	a4,8000316a <sys_munmap+0x1d4>
    uint64 s = p->vmas[i].start;
    80003176:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    80003178:	ff4769e3          	bltu	a4,s4,8000316a <sys_munmap+0x1d4>
    8000317c:	fed777e3          	bgeu	a4,a3,8000316a <sys_munmap+0x1d4>
    80003180:	86ba                	mv	a3,a4
    80003182:	b7e5                	j	8000316a <sys_munmap+0x1d4>
      if(ns == (uint64)-1 || ns >= b) break;
    80003184:	0326e163          	bltu	a3,s2,800031a6 <sys_munmap+0x210>
    }

    cur = seg_end;
  }

  return 0;
    80003188:	4501                	li	a0,0
}
    8000318a:	70a6                	ld	ra,104(sp)
    8000318c:	7406                	ld	s0,96(sp)
    8000318e:	64e6                	ld	s1,88(sp)
    80003190:	6946                	ld	s2,80(sp)
    80003192:	69a6                	ld	s3,72(sp)
    80003194:	6a06                	ld	s4,64(sp)
    80003196:	7ae2                	ld	s5,56(sp)
    80003198:	7b42                	ld	s6,48(sp)
    8000319a:	7ba2                	ld	s7,40(sp)
    8000319c:	7c02                	ld	s8,32(sp)
    8000319e:	6ce2                	ld	s9,24(sp)
    800031a0:	6d42                	ld	s10,16(sp)
    800031a2:	6165                	addi	sp,sp,112
    800031a4:	8082                	ret
    800031a6:	8a36                	mv	s4,a3
    800031a8:	a0d1                	j	8000326c <sys_munmap+0x2d6>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    800031aa:	41aa0633          	sub	a2,s4,s10
    800031ae:	4685                	li	a3,1
    800031b0:	8231                	srli	a2,a2,0xc
    800031b2:	85ea                	mv	a1,s10
    800031b4:	050ab503          	ld	a0,80(s5)
    800031b8:	8dcfe0ef          	jal	ra,80001294 <uvmunmap>
    800031bc:	b7b1                	j	80003108 <sys_munmap+0x172>
        shm_put(v->shm_key);
    800031be:	00249793          	slli	a5,s1,0x2
    800031c2:	97a6                	add	a5,a5,s1
    800031c4:	078e                	slli	a5,a5,0x3
    800031c6:	97d6                	add	a5,a5,s5
    800031c8:	18c7a503          	lw	a0,396(a5)
    800031cc:	01a030ef          	jal	ra,800061e6 <shm_put>
    800031d0:	b7b5                	j	8000313c <sys_munmap+0x1a6>
      v->start = seg_end;
    800031d2:	00249793          	slli	a5,s1,0x2
    800031d6:	97a6                	add	a5,a5,s1
    800031d8:	078e                	slli	a5,a5,0x3
    800031da:	97d6                	add	a5,a5,s5
    800031dc:	1747b823          	sd	s4,368(a5)
    800031e0:	a061                	j	80003268 <sys_munmap+0x2d2>
    } else if(seg_start > v->start && seg_end >= v->end){
    800031e2:	00249793          	slli	a5,s1,0x2
    800031e6:	97a6                	add	a5,a5,s1
    800031e8:	078e                	slli	a5,a5,0x3
    800031ea:	97d6                	add	a5,a5,s5
    800031ec:	1787b783          	ld	a5,376(a5)
    800031f0:	00fa6a63          	bltu	s4,a5,80003204 <sys_munmap+0x26e>
      v->end = seg_start;
    800031f4:	00249793          	slli	a5,s1,0x2
    800031f8:	97a6                	add	a5,a5,s1
    800031fa:	078e                	slli	a5,a5,0x3
    800031fc:	97d6                	add	a5,a5,s5
    800031fe:	17a7bc23          	sd	s10,376(a5)
    80003202:	a09d                	j	80003268 <sys_munmap+0x2d2>
    80003204:	875a                	mv	a4,s6
    80003206:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    80003208:	4314                	lw	a3,0(a4)
    8000320a:	c699                	beqz	a3,80003218 <sys_munmap+0x282>
  for(int i = 0; i < NVMA; i++){
    8000320c:	2785                	addiw	a5,a5,1
    8000320e:	02870713          	addi	a4,a4,40
    80003212:	ff779be3          	bne	a5,s7,80003208 <sys_munmap+0x272>
  return -1;
    80003216:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    80003218:	00279593          	slli	a1,a5,0x2
    8000321c:	00f586b3          	add	a3,a1,a5
    80003220:	068e                	slli	a3,a3,0x3
    80003222:	96d6                	add	a3,a3,s5
    80003224:	00249613          	slli	a2,s1,0x2
    80003228:	00960733          	add	a4,a2,s1
    8000322c:	070e                	slli	a4,a4,0x3
    8000322e:	9756                	add	a4,a4,s5
    80003230:	16873303          	ld	t1,360(a4)
    80003234:	17873883          	ld	a7,376(a4)
    80003238:	18073803          	ld	a6,384(a4)
    8000323c:	18873503          	ld	a0,392(a4)
    80003240:	1666b423          	sd	t1,360(a3) # 1168 <_entry-0x7fffee98>
    80003244:	1716bc23          	sd	a7,376(a3)
    80003248:	1906b023          	sd	a6,384(a3)
    8000324c:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    80003250:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    80003254:	17873703          	ld	a4,376(a4)
    80003258:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    8000325c:	009607b3          	add	a5,a2,s1
    80003260:	078e                	slli	a5,a5,0x3
    80003262:	97d6                	add	a5,a5,s5
    80003264:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    80003268:	012a7763          	bgeu	s4,s2,80003276 <sys_munmap+0x2e0>
  int need_splits = 0;
    8000326c:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    8000326e:	84e2                	mv	s1,s8
    80003270:	bda1                	j	800030c8 <sys_munmap+0x132>
  if(len <= 0) return (uint64)-1;
    80003272:	557d                	li	a0,-1
    80003274:	bf19                	j	8000318a <sys_munmap+0x1f4>
  return 0;
    80003276:	4501                	li	a0,0
    80003278:	bf09                	j	8000318a <sys_munmap+0x1f4>

000000008000327a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000327a:	7179                	addi	sp,sp,-48
    8000327c:	f406                	sd	ra,40(sp)
    8000327e:	f022                	sd	s0,32(sp)
    80003280:	ec26                	sd	s1,24(sp)
    80003282:	e84a                	sd	s2,16(sp)
    80003284:	e44e                	sd	s3,8(sp)
    80003286:	e052                	sd	s4,0(sp)
    80003288:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000328a:	00005597          	auipc	a1,0x5
    8000328e:	22e58593          	addi	a1,a1,558 # 800084b8 <syscalls+0xc0>
    80003292:	0023d517          	auipc	a0,0x23d
    80003296:	56650513          	addi	a0,a0,1382 # 802407f8 <bcache>
    8000329a:	987fd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000329e:	00245797          	auipc	a5,0x245
    800032a2:	55a78793          	addi	a5,a5,1370 # 802487f8 <bcache+0x8000>
    800032a6:	00245717          	auipc	a4,0x245
    800032aa:	7ba70713          	addi	a4,a4,1978 # 80248a60 <bcache+0x8268>
    800032ae:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032b2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032b6:	0023d497          	auipc	s1,0x23d
    800032ba:	55a48493          	addi	s1,s1,1370 # 80240810 <bcache+0x18>
    b->next = bcache.head.next;
    800032be:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032c0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032c2:	00005a17          	auipc	s4,0x5
    800032c6:	1fea0a13          	addi	s4,s4,510 # 800084c0 <syscalls+0xc8>
    b->next = bcache.head.next;
    800032ca:	2b893783          	ld	a5,696(s2)
    800032ce:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800032d0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800032d4:	85d2                	mv	a1,s4
    800032d6:	01048513          	addi	a0,s1,16
    800032da:	302010ef          	jal	ra,800045dc <initsleeplock>
    bcache.head.next->prev = b;
    800032de:	2b893783          	ld	a5,696(s2)
    800032e2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032e4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032e8:	45848493          	addi	s1,s1,1112
    800032ec:	fd349fe3          	bne	s1,s3,800032ca <binit+0x50>
  }
}
    800032f0:	70a2                	ld	ra,40(sp)
    800032f2:	7402                	ld	s0,32(sp)
    800032f4:	64e2                	ld	s1,24(sp)
    800032f6:	6942                	ld	s2,16(sp)
    800032f8:	69a2                	ld	s3,8(sp)
    800032fa:	6a02                	ld	s4,0(sp)
    800032fc:	6145                	addi	sp,sp,48
    800032fe:	8082                	ret

0000000080003300 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003300:	7179                	addi	sp,sp,-48
    80003302:	f406                	sd	ra,40(sp)
    80003304:	f022                	sd	s0,32(sp)
    80003306:	ec26                	sd	s1,24(sp)
    80003308:	e84a                	sd	s2,16(sp)
    8000330a:	e44e                	sd	s3,8(sp)
    8000330c:	1800                	addi	s0,sp,48
    8000330e:	892a                	mv	s2,a0
    80003310:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003312:	0023d517          	auipc	a0,0x23d
    80003316:	4e650513          	addi	a0,a0,1254 # 802407f8 <bcache>
    8000331a:	987fd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000331e:	00245497          	auipc	s1,0x245
    80003322:	7924b483          	ld	s1,1938(s1) # 80248ab0 <bcache+0x82b8>
    80003326:	00245797          	auipc	a5,0x245
    8000332a:	73a78793          	addi	a5,a5,1850 # 80248a60 <bcache+0x8268>
    8000332e:	02f48b63          	beq	s1,a5,80003364 <bread+0x64>
    80003332:	873e                	mv	a4,a5
    80003334:	a021                	j	8000333c <bread+0x3c>
    80003336:	68a4                	ld	s1,80(s1)
    80003338:	02e48663          	beq	s1,a4,80003364 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000333c:	449c                	lw	a5,8(s1)
    8000333e:	ff279ce3          	bne	a5,s2,80003336 <bread+0x36>
    80003342:	44dc                	lw	a5,12(s1)
    80003344:	ff3799e3          	bne	a5,s3,80003336 <bread+0x36>
      b->refcnt++;
    80003348:	40bc                	lw	a5,64(s1)
    8000334a:	2785                	addiw	a5,a5,1
    8000334c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000334e:	0023d517          	auipc	a0,0x23d
    80003352:	4aa50513          	addi	a0,a0,1194 # 802407f8 <bcache>
    80003356:	9e3fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    8000335a:	01048513          	addi	a0,s1,16
    8000335e:	2b4010ef          	jal	ra,80004612 <acquiresleep>
      return b;
    80003362:	a889                	j	800033b4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003364:	00245497          	auipc	s1,0x245
    80003368:	7444b483          	ld	s1,1860(s1) # 80248aa8 <bcache+0x82b0>
    8000336c:	00245797          	auipc	a5,0x245
    80003370:	6f478793          	addi	a5,a5,1780 # 80248a60 <bcache+0x8268>
    80003374:	00f48863          	beq	s1,a5,80003384 <bread+0x84>
    80003378:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000337a:	40bc                	lw	a5,64(s1)
    8000337c:	cb91                	beqz	a5,80003390 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000337e:	64a4                	ld	s1,72(s1)
    80003380:	fee49de3          	bne	s1,a4,8000337a <bread+0x7a>
  panic("bget: no buffers");
    80003384:	00005517          	auipc	a0,0x5
    80003388:	14450513          	addi	a0,a0,324 # 800084c8 <syscalls+0xd0>
    8000338c:	bfcfd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    80003390:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003394:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003398:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000339c:	4785                	li	a5,1
    8000339e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033a0:	0023d517          	auipc	a0,0x23d
    800033a4:	45850513          	addi	a0,a0,1112 # 802407f8 <bcache>
    800033a8:	991fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    800033ac:	01048513          	addi	a0,s1,16
    800033b0:	262010ef          	jal	ra,80004612 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800033b4:	409c                	lw	a5,0(s1)
    800033b6:	cb89                	beqz	a5,800033c8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033b8:	8526                	mv	a0,s1
    800033ba:	70a2                	ld	ra,40(sp)
    800033bc:	7402                	ld	s0,32(sp)
    800033be:	64e2                	ld	s1,24(sp)
    800033c0:	6942                	ld	s2,16(sp)
    800033c2:	69a2                	ld	s3,8(sp)
    800033c4:	6145                	addi	sp,sp,48
    800033c6:	8082                	ret
    virtio_disk_rw(b, 0);
    800033c8:	4581                	li	a1,0
    800033ca:	8526                	mv	a0,s1
    800033cc:	1ff020ef          	jal	ra,80005dca <virtio_disk_rw>
    b->valid = 1;
    800033d0:	4785                	li	a5,1
    800033d2:	c09c                	sw	a5,0(s1)
  return b;
    800033d4:	b7d5                	j	800033b8 <bread+0xb8>

00000000800033d6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033d6:	1101                	addi	sp,sp,-32
    800033d8:	ec06                	sd	ra,24(sp)
    800033da:	e822                	sd	s0,16(sp)
    800033dc:	e426                	sd	s1,8(sp)
    800033de:	1000                	addi	s0,sp,32
    800033e0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033e2:	0541                	addi	a0,a0,16
    800033e4:	2ac010ef          	jal	ra,80004690 <holdingsleep>
    800033e8:	c911                	beqz	a0,800033fc <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033ea:	4585                	li	a1,1
    800033ec:	8526                	mv	a0,s1
    800033ee:	1dd020ef          	jal	ra,80005dca <virtio_disk_rw>
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	64a2                	ld	s1,8(sp)
    800033f8:	6105                	addi	sp,sp,32
    800033fa:	8082                	ret
    panic("bwrite");
    800033fc:	00005517          	auipc	a0,0x5
    80003400:	0e450513          	addi	a0,a0,228 # 800084e0 <syscalls+0xe8>
    80003404:	b84fd0ef          	jal	ra,80000788 <panic>

0000000080003408 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	e426                	sd	s1,8(sp)
    80003410:	e04a                	sd	s2,0(sp)
    80003412:	1000                	addi	s0,sp,32
    80003414:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003416:	01050913          	addi	s2,a0,16
    8000341a:	854a                	mv	a0,s2
    8000341c:	274010ef          	jal	ra,80004690 <holdingsleep>
    80003420:	c13d                	beqz	a0,80003486 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80003422:	854a                	mv	a0,s2
    80003424:	234010ef          	jal	ra,80004658 <releasesleep>

  acquire(&bcache.lock);
    80003428:	0023d517          	auipc	a0,0x23d
    8000342c:	3d050513          	addi	a0,a0,976 # 802407f8 <bcache>
    80003430:	871fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80003434:	40bc                	lw	a5,64(s1)
    80003436:	37fd                	addiw	a5,a5,-1
    80003438:	0007871b          	sext.w	a4,a5
    8000343c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000343e:	eb05                	bnez	a4,8000346e <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003440:	68bc                	ld	a5,80(s1)
    80003442:	64b8                	ld	a4,72(s1)
    80003444:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003446:	64bc                	ld	a5,72(s1)
    80003448:	68b8                	ld	a4,80(s1)
    8000344a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000344c:	00245797          	auipc	a5,0x245
    80003450:	3ac78793          	addi	a5,a5,940 # 802487f8 <bcache+0x8000>
    80003454:	2b87b703          	ld	a4,696(a5)
    80003458:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000345a:	00245717          	auipc	a4,0x245
    8000345e:	60670713          	addi	a4,a4,1542 # 80248a60 <bcache+0x8268>
    80003462:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003464:	2b87b703          	ld	a4,696(a5)
    80003468:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000346a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000346e:	0023d517          	auipc	a0,0x23d
    80003472:	38a50513          	addi	a0,a0,906 # 802407f8 <bcache>
    80003476:	8c3fd0ef          	jal	ra,80000d38 <release>
}
    8000347a:	60e2                	ld	ra,24(sp)
    8000347c:	6442                	ld	s0,16(sp)
    8000347e:	64a2                	ld	s1,8(sp)
    80003480:	6902                	ld	s2,0(sp)
    80003482:	6105                	addi	sp,sp,32
    80003484:	8082                	ret
    panic("brelse");
    80003486:	00005517          	auipc	a0,0x5
    8000348a:	06250513          	addi	a0,a0,98 # 800084e8 <syscalls+0xf0>
    8000348e:	afafd0ef          	jal	ra,80000788 <panic>

0000000080003492 <bpin>:

void
bpin(struct buf *b) {
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	1000                	addi	s0,sp,32
    8000349c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000349e:	0023d517          	auipc	a0,0x23d
    800034a2:	35a50513          	addi	a0,a0,858 # 802407f8 <bcache>
    800034a6:	ffafd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    800034aa:	40bc                	lw	a5,64(s1)
    800034ac:	2785                	addiw	a5,a5,1
    800034ae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034b0:	0023d517          	auipc	a0,0x23d
    800034b4:	34850513          	addi	a0,a0,840 # 802407f8 <bcache>
    800034b8:	881fd0ef          	jal	ra,80000d38 <release>
}
    800034bc:	60e2                	ld	ra,24(sp)
    800034be:	6442                	ld	s0,16(sp)
    800034c0:	64a2                	ld	s1,8(sp)
    800034c2:	6105                	addi	sp,sp,32
    800034c4:	8082                	ret

00000000800034c6 <bunpin>:

void
bunpin(struct buf *b) {
    800034c6:	1101                	addi	sp,sp,-32
    800034c8:	ec06                	sd	ra,24(sp)
    800034ca:	e822                	sd	s0,16(sp)
    800034cc:	e426                	sd	s1,8(sp)
    800034ce:	1000                	addi	s0,sp,32
    800034d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034d2:	0023d517          	auipc	a0,0x23d
    800034d6:	32650513          	addi	a0,a0,806 # 802407f8 <bcache>
    800034da:	fc6fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    800034de:	40bc                	lw	a5,64(s1)
    800034e0:	37fd                	addiw	a5,a5,-1
    800034e2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034e4:	0023d517          	auipc	a0,0x23d
    800034e8:	31450513          	addi	a0,a0,788 # 802407f8 <bcache>
    800034ec:	84dfd0ef          	jal	ra,80000d38 <release>
}
    800034f0:	60e2                	ld	ra,24(sp)
    800034f2:	6442                	ld	s0,16(sp)
    800034f4:	64a2                	ld	s1,8(sp)
    800034f6:	6105                	addi	sp,sp,32
    800034f8:	8082                	ret

00000000800034fa <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800034fa:	1101                	addi	sp,sp,-32
    800034fc:	ec06                	sd	ra,24(sp)
    800034fe:	e822                	sd	s0,16(sp)
    80003500:	e426                	sd	s1,8(sp)
    80003502:	e04a                	sd	s2,0(sp)
    80003504:	1000                	addi	s0,sp,32
    80003506:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003508:	00d5d59b          	srliw	a1,a1,0xd
    8000350c:	00246797          	auipc	a5,0x246
    80003510:	9c87a783          	lw	a5,-1592(a5) # 80248ed4 <sb+0x1c>
    80003514:	9dbd                	addw	a1,a1,a5
    80003516:	debff0ef          	jal	ra,80003300 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000351a:	0074f713          	andi	a4,s1,7
    8000351e:	4785                	li	a5,1
    80003520:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003524:	14ce                	slli	s1,s1,0x33
    80003526:	90d9                	srli	s1,s1,0x36
    80003528:	00950733          	add	a4,a0,s1
    8000352c:	05874703          	lbu	a4,88(a4)
    80003530:	00e7f6b3          	and	a3,a5,a4
    80003534:	c29d                	beqz	a3,8000355a <bfree+0x60>
    80003536:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003538:	94aa                	add	s1,s1,a0
    8000353a:	fff7c793          	not	a5,a5
    8000353e:	8f7d                	and	a4,a4,a5
    80003540:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003544:	7d7000ef          	jal	ra,8000451a <log_write>
  brelse(bp);
    80003548:	854a                	mv	a0,s2
    8000354a:	ebfff0ef          	jal	ra,80003408 <brelse>
}
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	64a2                	ld	s1,8(sp)
    80003554:	6902                	ld	s2,0(sp)
    80003556:	6105                	addi	sp,sp,32
    80003558:	8082                	ret
    panic("freeing free block");
    8000355a:	00005517          	auipc	a0,0x5
    8000355e:	f9650513          	addi	a0,a0,-106 # 800084f0 <syscalls+0xf8>
    80003562:	a26fd0ef          	jal	ra,80000788 <panic>

0000000080003566 <balloc>:
{
    80003566:	711d                	addi	sp,sp,-96
    80003568:	ec86                	sd	ra,88(sp)
    8000356a:	e8a2                	sd	s0,80(sp)
    8000356c:	e4a6                	sd	s1,72(sp)
    8000356e:	e0ca                	sd	s2,64(sp)
    80003570:	fc4e                	sd	s3,56(sp)
    80003572:	f852                	sd	s4,48(sp)
    80003574:	f456                	sd	s5,40(sp)
    80003576:	f05a                	sd	s6,32(sp)
    80003578:	ec5e                	sd	s7,24(sp)
    8000357a:	e862                	sd	s8,16(sp)
    8000357c:	e466                	sd	s9,8(sp)
    8000357e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003580:	00246797          	auipc	a5,0x246
    80003584:	93c7a783          	lw	a5,-1732(a5) # 80248ebc <sb+0x4>
    80003588:	cff1                	beqz	a5,80003664 <balloc+0xfe>
    8000358a:	8baa                	mv	s7,a0
    8000358c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000358e:	00246b17          	auipc	s6,0x246
    80003592:	92ab0b13          	addi	s6,s6,-1750 # 80248eb8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003596:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003598:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000359a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000359c:	6c89                	lui	s9,0x2
    8000359e:	a0b5                	j	8000360a <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035a0:	97ca                	add	a5,a5,s2
    800035a2:	8e55                	or	a2,a2,a3
    800035a4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035a8:	854a                	mv	a0,s2
    800035aa:	771000ef          	jal	ra,8000451a <log_write>
        brelse(bp);
    800035ae:	854a                	mv	a0,s2
    800035b0:	e59ff0ef          	jal	ra,80003408 <brelse>
  bp = bread(dev, bno);
    800035b4:	85a6                	mv	a1,s1
    800035b6:	855e                	mv	a0,s7
    800035b8:	d49ff0ef          	jal	ra,80003300 <bread>
    800035bc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035be:	40000613          	li	a2,1024
    800035c2:	4581                	li	a1,0
    800035c4:	05850513          	addi	a0,a0,88
    800035c8:	facfd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    800035cc:	854a                	mv	a0,s2
    800035ce:	74d000ef          	jal	ra,8000451a <log_write>
  brelse(bp);
    800035d2:	854a                	mv	a0,s2
    800035d4:	e35ff0ef          	jal	ra,80003408 <brelse>
}
    800035d8:	8526                	mv	a0,s1
    800035da:	60e6                	ld	ra,88(sp)
    800035dc:	6446                	ld	s0,80(sp)
    800035de:	64a6                	ld	s1,72(sp)
    800035e0:	6906                	ld	s2,64(sp)
    800035e2:	79e2                	ld	s3,56(sp)
    800035e4:	7a42                	ld	s4,48(sp)
    800035e6:	7aa2                	ld	s5,40(sp)
    800035e8:	7b02                	ld	s6,32(sp)
    800035ea:	6be2                	ld	s7,24(sp)
    800035ec:	6c42                	ld	s8,16(sp)
    800035ee:	6ca2                	ld	s9,8(sp)
    800035f0:	6125                	addi	sp,sp,96
    800035f2:	8082                	ret
    brelse(bp);
    800035f4:	854a                	mv	a0,s2
    800035f6:	e13ff0ef          	jal	ra,80003408 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035fa:	015c87bb          	addw	a5,s9,s5
    800035fe:	00078a9b          	sext.w	s5,a5
    80003602:	004b2703          	lw	a4,4(s6)
    80003606:	04eaff63          	bgeu	s5,a4,80003664 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    8000360a:	41fad79b          	sraiw	a5,s5,0x1f
    8000360e:	0137d79b          	srliw	a5,a5,0x13
    80003612:	015787bb          	addw	a5,a5,s5
    80003616:	40d7d79b          	sraiw	a5,a5,0xd
    8000361a:	01cb2583          	lw	a1,28(s6)
    8000361e:	9dbd                	addw	a1,a1,a5
    80003620:	855e                	mv	a0,s7
    80003622:	cdfff0ef          	jal	ra,80003300 <bread>
    80003626:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003628:	004b2503          	lw	a0,4(s6)
    8000362c:	000a849b          	sext.w	s1,s5
    80003630:	8762                	mv	a4,s8
    80003632:	fca4f1e3          	bgeu	s1,a0,800035f4 <balloc+0x8e>
      m = 1 << (bi % 8);
    80003636:	00777693          	andi	a3,a4,7
    8000363a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000363e:	41f7579b          	sraiw	a5,a4,0x1f
    80003642:	01d7d79b          	srliw	a5,a5,0x1d
    80003646:	9fb9                	addw	a5,a5,a4
    80003648:	4037d79b          	sraiw	a5,a5,0x3
    8000364c:	00f90633          	add	a2,s2,a5
    80003650:	05864603          	lbu	a2,88(a2) # fffffffffffff058 <end+0xffffffff7fdab300>
    80003654:	00c6f5b3          	and	a1,a3,a2
    80003658:	d5a1                	beqz	a1,800035a0 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000365a:	2705                	addiw	a4,a4,1
    8000365c:	2485                	addiw	s1,s1,1
    8000365e:	fd471ae3          	bne	a4,s4,80003632 <balloc+0xcc>
    80003662:	bf49                	j	800035f4 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003664:	00005517          	auipc	a0,0x5
    80003668:	ea450513          	addi	a0,a0,-348 # 80008508 <syscalls+0x110>
    8000366c:	e57fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003670:	4481                	li	s1,0
    80003672:	b79d                	j	800035d8 <balloc+0x72>

0000000080003674 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003674:	7179                	addi	sp,sp,-48
    80003676:	f406                	sd	ra,40(sp)
    80003678:	f022                	sd	s0,32(sp)
    8000367a:	ec26                	sd	s1,24(sp)
    8000367c:	e84a                	sd	s2,16(sp)
    8000367e:	e44e                	sd	s3,8(sp)
    80003680:	e052                	sd	s4,0(sp)
    80003682:	1800                	addi	s0,sp,48
    80003684:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003686:	47ad                	li	a5,11
    80003688:	02b7e663          	bltu	a5,a1,800036b4 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000368c:	02059793          	slli	a5,a1,0x20
    80003690:	01e7d593          	srli	a1,a5,0x1e
    80003694:	00b504b3          	add	s1,a0,a1
    80003698:	0504a903          	lw	s2,80(s1)
    8000369c:	06091663          	bnez	s2,80003708 <bmap+0x94>
      addr = balloc(ip->dev);
    800036a0:	4108                	lw	a0,0(a0)
    800036a2:	ec5ff0ef          	jal	ra,80003566 <balloc>
    800036a6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036aa:	04090f63          	beqz	s2,80003708 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    800036ae:	0524a823          	sw	s2,80(s1)
    800036b2:	a899                	j	80003708 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    800036b4:	ff45849b          	addiw	s1,a1,-12
    800036b8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036bc:	0ff00793          	li	a5,255
    800036c0:	06e7eb63          	bltu	a5,a4,80003736 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800036c4:	08052903          	lw	s2,128(a0)
    800036c8:	00091b63          	bnez	s2,800036de <bmap+0x6a>
      addr = balloc(ip->dev);
    800036cc:	4108                	lw	a0,0(a0)
    800036ce:	e99ff0ef          	jal	ra,80003566 <balloc>
    800036d2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036d6:	02090963          	beqz	s2,80003708 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800036da:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800036de:	85ca                	mv	a1,s2
    800036e0:	0009a503          	lw	a0,0(s3)
    800036e4:	c1dff0ef          	jal	ra,80003300 <bread>
    800036e8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800036ea:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800036ee:	02049713          	slli	a4,s1,0x20
    800036f2:	01e75593          	srli	a1,a4,0x1e
    800036f6:	00b784b3          	add	s1,a5,a1
    800036fa:	0004a903          	lw	s2,0(s1)
    800036fe:	00090e63          	beqz	s2,8000371a <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003702:	8552                	mv	a0,s4
    80003704:	d05ff0ef          	jal	ra,80003408 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003708:	854a                	mv	a0,s2
    8000370a:	70a2                	ld	ra,40(sp)
    8000370c:	7402                	ld	s0,32(sp)
    8000370e:	64e2                	ld	s1,24(sp)
    80003710:	6942                	ld	s2,16(sp)
    80003712:	69a2                	ld	s3,8(sp)
    80003714:	6a02                	ld	s4,0(sp)
    80003716:	6145                	addi	sp,sp,48
    80003718:	8082                	ret
      addr = balloc(ip->dev);
    8000371a:	0009a503          	lw	a0,0(s3)
    8000371e:	e49ff0ef          	jal	ra,80003566 <balloc>
    80003722:	0005091b          	sext.w	s2,a0
      if(addr){
    80003726:	fc090ee3          	beqz	s2,80003702 <bmap+0x8e>
        a[bn] = addr;
    8000372a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000372e:	8552                	mv	a0,s4
    80003730:	5eb000ef          	jal	ra,8000451a <log_write>
    80003734:	b7f9                	j	80003702 <bmap+0x8e>
  panic("bmap: out of range");
    80003736:	00005517          	auipc	a0,0x5
    8000373a:	dea50513          	addi	a0,a0,-534 # 80008520 <syscalls+0x128>
    8000373e:	84afd0ef          	jal	ra,80000788 <panic>

0000000080003742 <iget>:
{
    80003742:	7179                	addi	sp,sp,-48
    80003744:	f406                	sd	ra,40(sp)
    80003746:	f022                	sd	s0,32(sp)
    80003748:	ec26                	sd	s1,24(sp)
    8000374a:	e84a                	sd	s2,16(sp)
    8000374c:	e44e                	sd	s3,8(sp)
    8000374e:	e052                	sd	s4,0(sp)
    80003750:	1800                	addi	s0,sp,48
    80003752:	89aa                	mv	s3,a0
    80003754:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003756:	00245517          	auipc	a0,0x245
    8000375a:	78250513          	addi	a0,a0,1922 # 80248ed8 <itable>
    8000375e:	d42fd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003762:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003764:	00245497          	auipc	s1,0x245
    80003768:	78c48493          	addi	s1,s1,1932 # 80248ef0 <itable+0x18>
    8000376c:	00247697          	auipc	a3,0x247
    80003770:	21468693          	addi	a3,a3,532 # 8024a980 <log>
    80003774:	a039                	j	80003782 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003776:	02090963          	beqz	s2,800037a8 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000377a:	08848493          	addi	s1,s1,136
    8000377e:	02d48863          	beq	s1,a3,800037ae <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003782:	449c                	lw	a5,8(s1)
    80003784:	fef059e3          	blez	a5,80003776 <iget+0x34>
    80003788:	4098                	lw	a4,0(s1)
    8000378a:	ff3716e3          	bne	a4,s3,80003776 <iget+0x34>
    8000378e:	40d8                	lw	a4,4(s1)
    80003790:	ff4713e3          	bne	a4,s4,80003776 <iget+0x34>
      ip->ref++;
    80003794:	2785                	addiw	a5,a5,1
    80003796:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003798:	00245517          	auipc	a0,0x245
    8000379c:	74050513          	addi	a0,a0,1856 # 80248ed8 <itable>
    800037a0:	d98fd0ef          	jal	ra,80000d38 <release>
      return ip;
    800037a4:	8926                	mv	s2,s1
    800037a6:	a02d                	j	800037d0 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037a8:	fbe9                	bnez	a5,8000377a <iget+0x38>
    800037aa:	8926                	mv	s2,s1
    800037ac:	b7f9                	j	8000377a <iget+0x38>
  if(empty == 0)
    800037ae:	02090a63          	beqz	s2,800037e2 <iget+0xa0>
  ip->dev = dev;
    800037b2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800037b6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800037ba:	4785                	li	a5,1
    800037bc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800037c0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800037c4:	00245517          	auipc	a0,0x245
    800037c8:	71450513          	addi	a0,a0,1812 # 80248ed8 <itable>
    800037cc:	d6cfd0ef          	jal	ra,80000d38 <release>
}
    800037d0:	854a                	mv	a0,s2
    800037d2:	70a2                	ld	ra,40(sp)
    800037d4:	7402                	ld	s0,32(sp)
    800037d6:	64e2                	ld	s1,24(sp)
    800037d8:	6942                	ld	s2,16(sp)
    800037da:	69a2                	ld	s3,8(sp)
    800037dc:	6a02                	ld	s4,0(sp)
    800037de:	6145                	addi	sp,sp,48
    800037e0:	8082                	ret
    panic("iget: no inodes");
    800037e2:	00005517          	auipc	a0,0x5
    800037e6:	d5650513          	addi	a0,a0,-682 # 80008538 <syscalls+0x140>
    800037ea:	f9ffc0ef          	jal	ra,80000788 <panic>

00000000800037ee <iinit>:
{
    800037ee:	7179                	addi	sp,sp,-48
    800037f0:	f406                	sd	ra,40(sp)
    800037f2:	f022                	sd	s0,32(sp)
    800037f4:	ec26                	sd	s1,24(sp)
    800037f6:	e84a                	sd	s2,16(sp)
    800037f8:	e44e                	sd	s3,8(sp)
    800037fa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037fc:	00005597          	auipc	a1,0x5
    80003800:	d4c58593          	addi	a1,a1,-692 # 80008548 <syscalls+0x150>
    80003804:	00245517          	auipc	a0,0x245
    80003808:	6d450513          	addi	a0,a0,1748 # 80248ed8 <itable>
    8000380c:	c14fd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003810:	00245497          	auipc	s1,0x245
    80003814:	6f048493          	addi	s1,s1,1776 # 80248f00 <itable+0x28>
    80003818:	00247997          	auipc	s3,0x247
    8000381c:	17898993          	addi	s3,s3,376 # 8024a990 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003820:	00005917          	auipc	s2,0x5
    80003824:	d3090913          	addi	s2,s2,-720 # 80008550 <syscalls+0x158>
    80003828:	85ca                	mv	a1,s2
    8000382a:	8526                	mv	a0,s1
    8000382c:	5b1000ef          	jal	ra,800045dc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003830:	08848493          	addi	s1,s1,136
    80003834:	ff349ae3          	bne	s1,s3,80003828 <iinit+0x3a>
}
    80003838:	70a2                	ld	ra,40(sp)
    8000383a:	7402                	ld	s0,32(sp)
    8000383c:	64e2                	ld	s1,24(sp)
    8000383e:	6942                	ld	s2,16(sp)
    80003840:	69a2                	ld	s3,8(sp)
    80003842:	6145                	addi	sp,sp,48
    80003844:	8082                	ret

0000000080003846 <ialloc>:
{
    80003846:	715d                	addi	sp,sp,-80
    80003848:	e486                	sd	ra,72(sp)
    8000384a:	e0a2                	sd	s0,64(sp)
    8000384c:	fc26                	sd	s1,56(sp)
    8000384e:	f84a                	sd	s2,48(sp)
    80003850:	f44e                	sd	s3,40(sp)
    80003852:	f052                	sd	s4,32(sp)
    80003854:	ec56                	sd	s5,24(sp)
    80003856:	e85a                	sd	s6,16(sp)
    80003858:	e45e                	sd	s7,8(sp)
    8000385a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000385c:	00245717          	auipc	a4,0x245
    80003860:	66872703          	lw	a4,1640(a4) # 80248ec4 <sb+0xc>
    80003864:	4785                	li	a5,1
    80003866:	04e7f663          	bgeu	a5,a4,800038b2 <ialloc+0x6c>
    8000386a:	8aaa                	mv	s5,a0
    8000386c:	8bae                	mv	s7,a1
    8000386e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003870:	00245a17          	auipc	s4,0x245
    80003874:	648a0a13          	addi	s4,s4,1608 # 80248eb8 <sb>
    80003878:	00048b1b          	sext.w	s6,s1
    8000387c:	0044d593          	srli	a1,s1,0x4
    80003880:	018a2783          	lw	a5,24(s4)
    80003884:	9dbd                	addw	a1,a1,a5
    80003886:	8556                	mv	a0,s5
    80003888:	a79ff0ef          	jal	ra,80003300 <bread>
    8000388c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000388e:	05850993          	addi	s3,a0,88
    80003892:	00f4f793          	andi	a5,s1,15
    80003896:	079a                	slli	a5,a5,0x6
    80003898:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000389a:	00099783          	lh	a5,0(s3)
    8000389e:	cf85                	beqz	a5,800038d6 <ialloc+0x90>
    brelse(bp);
    800038a0:	b69ff0ef          	jal	ra,80003408 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038a4:	0485                	addi	s1,s1,1
    800038a6:	00ca2703          	lw	a4,12(s4)
    800038aa:	0004879b          	sext.w	a5,s1
    800038ae:	fce7e5e3          	bltu	a5,a4,80003878 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038b2:	00005517          	auipc	a0,0x5
    800038b6:	ca650513          	addi	a0,a0,-858 # 80008558 <syscalls+0x160>
    800038ba:	c09fc0ef          	jal	ra,800004c2 <printf>
  return 0;
    800038be:	4501                	li	a0,0
}
    800038c0:	60a6                	ld	ra,72(sp)
    800038c2:	6406                	ld	s0,64(sp)
    800038c4:	74e2                	ld	s1,56(sp)
    800038c6:	7942                	ld	s2,48(sp)
    800038c8:	79a2                	ld	s3,40(sp)
    800038ca:	7a02                	ld	s4,32(sp)
    800038cc:	6ae2                	ld	s5,24(sp)
    800038ce:	6b42                	ld	s6,16(sp)
    800038d0:	6ba2                	ld	s7,8(sp)
    800038d2:	6161                	addi	sp,sp,80
    800038d4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038d6:	04000613          	li	a2,64
    800038da:	4581                	li	a1,0
    800038dc:	854e                	mv	a0,s3
    800038de:	c96fd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    800038e2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038e6:	854a                	mv	a0,s2
    800038e8:	433000ef          	jal	ra,8000451a <log_write>
      brelse(bp);
    800038ec:	854a                	mv	a0,s2
    800038ee:	b1bff0ef          	jal	ra,80003408 <brelse>
      return iget(dev, inum);
    800038f2:	85da                	mv	a1,s6
    800038f4:	8556                	mv	a0,s5
    800038f6:	e4dff0ef          	jal	ra,80003742 <iget>
    800038fa:	b7d9                	j	800038c0 <ialloc+0x7a>

00000000800038fc <iupdate>:
{
    800038fc:	1101                	addi	sp,sp,-32
    800038fe:	ec06                	sd	ra,24(sp)
    80003900:	e822                	sd	s0,16(sp)
    80003902:	e426                	sd	s1,8(sp)
    80003904:	e04a                	sd	s2,0(sp)
    80003906:	1000                	addi	s0,sp,32
    80003908:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000390a:	415c                	lw	a5,4(a0)
    8000390c:	0047d79b          	srliw	a5,a5,0x4
    80003910:	00245597          	auipc	a1,0x245
    80003914:	5c05a583          	lw	a1,1472(a1) # 80248ed0 <sb+0x18>
    80003918:	9dbd                	addw	a1,a1,a5
    8000391a:	4108                	lw	a0,0(a0)
    8000391c:	9e5ff0ef          	jal	ra,80003300 <bread>
    80003920:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003922:	05850793          	addi	a5,a0,88
    80003926:	40d8                	lw	a4,4(s1)
    80003928:	8b3d                	andi	a4,a4,15
    8000392a:	071a                	slli	a4,a4,0x6
    8000392c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000392e:	04449703          	lh	a4,68(s1)
    80003932:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003936:	04649703          	lh	a4,70(s1)
    8000393a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000393e:	04849703          	lh	a4,72(s1)
    80003942:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003946:	04a49703          	lh	a4,74(s1)
    8000394a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000394e:	44f8                	lw	a4,76(s1)
    80003950:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003952:	03400613          	li	a2,52
    80003956:	05048593          	addi	a1,s1,80
    8000395a:	00c78513          	addi	a0,a5,12
    8000395e:	c72fd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003962:	854a                	mv	a0,s2
    80003964:	3b7000ef          	jal	ra,8000451a <log_write>
  brelse(bp);
    80003968:	854a                	mv	a0,s2
    8000396a:	a9fff0ef          	jal	ra,80003408 <brelse>
}
    8000396e:	60e2                	ld	ra,24(sp)
    80003970:	6442                	ld	s0,16(sp)
    80003972:	64a2                	ld	s1,8(sp)
    80003974:	6902                	ld	s2,0(sp)
    80003976:	6105                	addi	sp,sp,32
    80003978:	8082                	ret

000000008000397a <idup>:
{
    8000397a:	1101                	addi	sp,sp,-32
    8000397c:	ec06                	sd	ra,24(sp)
    8000397e:	e822                	sd	s0,16(sp)
    80003980:	e426                	sd	s1,8(sp)
    80003982:	1000                	addi	s0,sp,32
    80003984:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003986:	00245517          	auipc	a0,0x245
    8000398a:	55250513          	addi	a0,a0,1362 # 80248ed8 <itable>
    8000398e:	b12fd0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    80003992:	449c                	lw	a5,8(s1)
    80003994:	2785                	addiw	a5,a5,1
    80003996:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003998:	00245517          	auipc	a0,0x245
    8000399c:	54050513          	addi	a0,a0,1344 # 80248ed8 <itable>
    800039a0:	b98fd0ef          	jal	ra,80000d38 <release>
}
    800039a4:	8526                	mv	a0,s1
    800039a6:	60e2                	ld	ra,24(sp)
    800039a8:	6442                	ld	s0,16(sp)
    800039aa:	64a2                	ld	s1,8(sp)
    800039ac:	6105                	addi	sp,sp,32
    800039ae:	8082                	ret

00000000800039b0 <ilock>:
{
    800039b0:	1101                	addi	sp,sp,-32
    800039b2:	ec06                	sd	ra,24(sp)
    800039b4:	e822                	sd	s0,16(sp)
    800039b6:	e426                	sd	s1,8(sp)
    800039b8:	e04a                	sd	s2,0(sp)
    800039ba:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039bc:	c105                	beqz	a0,800039dc <ilock+0x2c>
    800039be:	84aa                	mv	s1,a0
    800039c0:	451c                	lw	a5,8(a0)
    800039c2:	00f05d63          	blez	a5,800039dc <ilock+0x2c>
  acquiresleep(&ip->lock);
    800039c6:	0541                	addi	a0,a0,16
    800039c8:	44b000ef          	jal	ra,80004612 <acquiresleep>
  if(ip->valid == 0){
    800039cc:	40bc                	lw	a5,64(s1)
    800039ce:	cf89                	beqz	a5,800039e8 <ilock+0x38>
}
    800039d0:	60e2                	ld	ra,24(sp)
    800039d2:	6442                	ld	s0,16(sp)
    800039d4:	64a2                	ld	s1,8(sp)
    800039d6:	6902                	ld	s2,0(sp)
    800039d8:	6105                	addi	sp,sp,32
    800039da:	8082                	ret
    panic("ilock");
    800039dc:	00005517          	auipc	a0,0x5
    800039e0:	b9450513          	addi	a0,a0,-1132 # 80008570 <syscalls+0x178>
    800039e4:	da5fc0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039e8:	40dc                	lw	a5,4(s1)
    800039ea:	0047d79b          	srliw	a5,a5,0x4
    800039ee:	00245597          	auipc	a1,0x245
    800039f2:	4e25a583          	lw	a1,1250(a1) # 80248ed0 <sb+0x18>
    800039f6:	9dbd                	addw	a1,a1,a5
    800039f8:	4088                	lw	a0,0(s1)
    800039fa:	907ff0ef          	jal	ra,80003300 <bread>
    800039fe:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a00:	05850593          	addi	a1,a0,88
    80003a04:	40dc                	lw	a5,4(s1)
    80003a06:	8bbd                	andi	a5,a5,15
    80003a08:	079a                	slli	a5,a5,0x6
    80003a0a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a0c:	00059783          	lh	a5,0(a1)
    80003a10:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a14:	00259783          	lh	a5,2(a1)
    80003a18:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a1c:	00459783          	lh	a5,4(a1)
    80003a20:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a24:	00659783          	lh	a5,6(a1)
    80003a28:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a2c:	459c                	lw	a5,8(a1)
    80003a2e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a30:	03400613          	li	a2,52
    80003a34:	05b1                	addi	a1,a1,12
    80003a36:	05048513          	addi	a0,s1,80
    80003a3a:	b96fd0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    80003a3e:	854a                	mv	a0,s2
    80003a40:	9c9ff0ef          	jal	ra,80003408 <brelse>
    ip->valid = 1;
    80003a44:	4785                	li	a5,1
    80003a46:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a48:	04449783          	lh	a5,68(s1)
    80003a4c:	f3d1                	bnez	a5,800039d0 <ilock+0x20>
      panic("ilock: no type");
    80003a4e:	00005517          	auipc	a0,0x5
    80003a52:	b2a50513          	addi	a0,a0,-1238 # 80008578 <syscalls+0x180>
    80003a56:	d33fc0ef          	jal	ra,80000788 <panic>

0000000080003a5a <iunlock>:
{
    80003a5a:	1101                	addi	sp,sp,-32
    80003a5c:	ec06                	sd	ra,24(sp)
    80003a5e:	e822                	sd	s0,16(sp)
    80003a60:	e426                	sd	s1,8(sp)
    80003a62:	e04a                	sd	s2,0(sp)
    80003a64:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a66:	c505                	beqz	a0,80003a8e <iunlock+0x34>
    80003a68:	84aa                	mv	s1,a0
    80003a6a:	01050913          	addi	s2,a0,16
    80003a6e:	854a                	mv	a0,s2
    80003a70:	421000ef          	jal	ra,80004690 <holdingsleep>
    80003a74:	cd09                	beqz	a0,80003a8e <iunlock+0x34>
    80003a76:	449c                	lw	a5,8(s1)
    80003a78:	00f05b63          	blez	a5,80003a8e <iunlock+0x34>
  releasesleep(&ip->lock);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	3db000ef          	jal	ra,80004658 <releasesleep>
}
    80003a82:	60e2                	ld	ra,24(sp)
    80003a84:	6442                	ld	s0,16(sp)
    80003a86:	64a2                	ld	s1,8(sp)
    80003a88:	6902                	ld	s2,0(sp)
    80003a8a:	6105                	addi	sp,sp,32
    80003a8c:	8082                	ret
    panic("iunlock");
    80003a8e:	00005517          	auipc	a0,0x5
    80003a92:	afa50513          	addi	a0,a0,-1286 # 80008588 <syscalls+0x190>
    80003a96:	cf3fc0ef          	jal	ra,80000788 <panic>

0000000080003a9a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a9a:	7179                	addi	sp,sp,-48
    80003a9c:	f406                	sd	ra,40(sp)
    80003a9e:	f022                	sd	s0,32(sp)
    80003aa0:	ec26                	sd	s1,24(sp)
    80003aa2:	e84a                	sd	s2,16(sp)
    80003aa4:	e44e                	sd	s3,8(sp)
    80003aa6:	e052                	sd	s4,0(sp)
    80003aa8:	1800                	addi	s0,sp,48
    80003aaa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003aac:	05050493          	addi	s1,a0,80
    80003ab0:	08050913          	addi	s2,a0,128
    80003ab4:	a021                	j	80003abc <itrunc+0x22>
    80003ab6:	0491                	addi	s1,s1,4
    80003ab8:	01248b63          	beq	s1,s2,80003ace <itrunc+0x34>
    if(ip->addrs[i]){
    80003abc:	408c                	lw	a1,0(s1)
    80003abe:	dde5                	beqz	a1,80003ab6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ac0:	0009a503          	lw	a0,0(s3)
    80003ac4:	a37ff0ef          	jal	ra,800034fa <bfree>
      ip->addrs[i] = 0;
    80003ac8:	0004a023          	sw	zero,0(s1)
    80003acc:	b7ed                	j	80003ab6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ace:	0809a583          	lw	a1,128(s3)
    80003ad2:	ed91                	bnez	a1,80003aee <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ad4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ad8:	854e                	mv	a0,s3
    80003ada:	e23ff0ef          	jal	ra,800038fc <iupdate>
}
    80003ade:	70a2                	ld	ra,40(sp)
    80003ae0:	7402                	ld	s0,32(sp)
    80003ae2:	64e2                	ld	s1,24(sp)
    80003ae4:	6942                	ld	s2,16(sp)
    80003ae6:	69a2                	ld	s3,8(sp)
    80003ae8:	6a02                	ld	s4,0(sp)
    80003aea:	6145                	addi	sp,sp,48
    80003aec:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003aee:	0009a503          	lw	a0,0(s3)
    80003af2:	80fff0ef          	jal	ra,80003300 <bread>
    80003af6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003af8:	05850493          	addi	s1,a0,88
    80003afc:	45850913          	addi	s2,a0,1112
    80003b00:	a021                	j	80003b08 <itrunc+0x6e>
    80003b02:	0491                	addi	s1,s1,4
    80003b04:	01248963          	beq	s1,s2,80003b16 <itrunc+0x7c>
      if(a[j])
    80003b08:	408c                	lw	a1,0(s1)
    80003b0a:	dde5                	beqz	a1,80003b02 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003b0c:	0009a503          	lw	a0,0(s3)
    80003b10:	9ebff0ef          	jal	ra,800034fa <bfree>
    80003b14:	b7fd                	j	80003b02 <itrunc+0x68>
    brelse(bp);
    80003b16:	8552                	mv	a0,s4
    80003b18:	8f1ff0ef          	jal	ra,80003408 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b1c:	0809a583          	lw	a1,128(s3)
    80003b20:	0009a503          	lw	a0,0(s3)
    80003b24:	9d7ff0ef          	jal	ra,800034fa <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b28:	0809a023          	sw	zero,128(s3)
    80003b2c:	b765                	j	80003ad4 <itrunc+0x3a>

0000000080003b2e <iput>:
{
    80003b2e:	1101                	addi	sp,sp,-32
    80003b30:	ec06                	sd	ra,24(sp)
    80003b32:	e822                	sd	s0,16(sp)
    80003b34:	e426                	sd	s1,8(sp)
    80003b36:	e04a                	sd	s2,0(sp)
    80003b38:	1000                	addi	s0,sp,32
    80003b3a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b3c:	00245517          	auipc	a0,0x245
    80003b40:	39c50513          	addi	a0,a0,924 # 80248ed8 <itable>
    80003b44:	95cfd0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b48:	4498                	lw	a4,8(s1)
    80003b4a:	4785                	li	a5,1
    80003b4c:	02f70163          	beq	a4,a5,80003b6e <iput+0x40>
  ip->ref--;
    80003b50:	449c                	lw	a5,8(s1)
    80003b52:	37fd                	addiw	a5,a5,-1
    80003b54:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b56:	00245517          	auipc	a0,0x245
    80003b5a:	38250513          	addi	a0,a0,898 # 80248ed8 <itable>
    80003b5e:	9dafd0ef          	jal	ra,80000d38 <release>
}
    80003b62:	60e2                	ld	ra,24(sp)
    80003b64:	6442                	ld	s0,16(sp)
    80003b66:	64a2                	ld	s1,8(sp)
    80003b68:	6902                	ld	s2,0(sp)
    80003b6a:	6105                	addi	sp,sp,32
    80003b6c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b6e:	40bc                	lw	a5,64(s1)
    80003b70:	d3e5                	beqz	a5,80003b50 <iput+0x22>
    80003b72:	04a49783          	lh	a5,74(s1)
    80003b76:	ffe9                	bnez	a5,80003b50 <iput+0x22>
    acquiresleep(&ip->lock);
    80003b78:	01048913          	addi	s2,s1,16
    80003b7c:	854a                	mv	a0,s2
    80003b7e:	295000ef          	jal	ra,80004612 <acquiresleep>
    release(&itable.lock);
    80003b82:	00245517          	auipc	a0,0x245
    80003b86:	35650513          	addi	a0,a0,854 # 80248ed8 <itable>
    80003b8a:	9aefd0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    80003b8e:	8526                	mv	a0,s1
    80003b90:	f0bff0ef          	jal	ra,80003a9a <itrunc>
    ip->type = 0;
    80003b94:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b98:	8526                	mv	a0,s1
    80003b9a:	d63ff0ef          	jal	ra,800038fc <iupdate>
    ip->valid = 0;
    80003b9e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	2b5000ef          	jal	ra,80004658 <releasesleep>
    acquire(&itable.lock);
    80003ba8:	00245517          	auipc	a0,0x245
    80003bac:	33050513          	addi	a0,a0,816 # 80248ed8 <itable>
    80003bb0:	8f0fd0ef          	jal	ra,80000ca0 <acquire>
    80003bb4:	bf71                	j	80003b50 <iput+0x22>

0000000080003bb6 <iunlockput>:
{
    80003bb6:	1101                	addi	sp,sp,-32
    80003bb8:	ec06                	sd	ra,24(sp)
    80003bba:	e822                	sd	s0,16(sp)
    80003bbc:	e426                	sd	s1,8(sp)
    80003bbe:	1000                	addi	s0,sp,32
    80003bc0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bc2:	e99ff0ef          	jal	ra,80003a5a <iunlock>
  iput(ip);
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	f67ff0ef          	jal	ra,80003b2e <iput>
}
    80003bcc:	60e2                	ld	ra,24(sp)
    80003bce:	6442                	ld	s0,16(sp)
    80003bd0:	64a2                	ld	s1,8(sp)
    80003bd2:	6105                	addi	sp,sp,32
    80003bd4:	8082                	ret

0000000080003bd6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003bd6:	00245717          	auipc	a4,0x245
    80003bda:	2ee72703          	lw	a4,750(a4) # 80248ec4 <sb+0xc>
    80003bde:	4785                	li	a5,1
    80003be0:	0ae7ff63          	bgeu	a5,a4,80003c9e <ireclaim+0xc8>
{
    80003be4:	7139                	addi	sp,sp,-64
    80003be6:	fc06                	sd	ra,56(sp)
    80003be8:	f822                	sd	s0,48(sp)
    80003bea:	f426                	sd	s1,40(sp)
    80003bec:	f04a                	sd	s2,32(sp)
    80003bee:	ec4e                	sd	s3,24(sp)
    80003bf0:	e852                	sd	s4,16(sp)
    80003bf2:	e456                	sd	s5,8(sp)
    80003bf4:	e05a                	sd	s6,0(sp)
    80003bf6:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003bf8:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003bfa:	00050a1b          	sext.w	s4,a0
    80003bfe:	00245a97          	auipc	s5,0x245
    80003c02:	2baa8a93          	addi	s5,s5,698 # 80248eb8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003c06:	00005b17          	auipc	s6,0x5
    80003c0a:	98ab0b13          	addi	s6,s6,-1654 # 80008590 <syscalls+0x198>
    80003c0e:	a099                	j	80003c54 <ireclaim+0x7e>
    80003c10:	85ce                	mv	a1,s3
    80003c12:	855a                	mv	a0,s6
    80003c14:	8affc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    80003c18:	85ce                	mv	a1,s3
    80003c1a:	8552                	mv	a0,s4
    80003c1c:	b27ff0ef          	jal	ra,80003742 <iget>
    80003c20:	89aa                	mv	s3,a0
    brelse(bp);
    80003c22:	854a                	mv	a0,s2
    80003c24:	fe4ff0ef          	jal	ra,80003408 <brelse>
    if (ip) {
    80003c28:	00098f63          	beqz	s3,80003c46 <ireclaim+0x70>
      begin_op();
    80003c2c:	76c000ef          	jal	ra,80004398 <begin_op>
      ilock(ip);
    80003c30:	854e                	mv	a0,s3
    80003c32:	d7fff0ef          	jal	ra,800039b0 <ilock>
      iunlock(ip);
    80003c36:	854e                	mv	a0,s3
    80003c38:	e23ff0ef          	jal	ra,80003a5a <iunlock>
      iput(ip);
    80003c3c:	854e                	mv	a0,s3
    80003c3e:	ef1ff0ef          	jal	ra,80003b2e <iput>
      end_op();
    80003c42:	7c4000ef          	jal	ra,80004406 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c46:	0485                	addi	s1,s1,1
    80003c48:	00caa703          	lw	a4,12(s5)
    80003c4c:	0004879b          	sext.w	a5,s1
    80003c50:	02e7fd63          	bgeu	a5,a4,80003c8a <ireclaim+0xb4>
    80003c54:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c58:	0044d593          	srli	a1,s1,0x4
    80003c5c:	018aa783          	lw	a5,24(s5)
    80003c60:	9dbd                	addw	a1,a1,a5
    80003c62:	8552                	mv	a0,s4
    80003c64:	e9cff0ef          	jal	ra,80003300 <bread>
    80003c68:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003c6a:	05850793          	addi	a5,a0,88
    80003c6e:	00f9f713          	andi	a4,s3,15
    80003c72:	071a                	slli	a4,a4,0x6
    80003c74:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003c76:	00079703          	lh	a4,0(a5)
    80003c7a:	c701                	beqz	a4,80003c82 <ireclaim+0xac>
    80003c7c:	00679783          	lh	a5,6(a5)
    80003c80:	dbc1                	beqz	a5,80003c10 <ireclaim+0x3a>
    brelse(bp);
    80003c82:	854a                	mv	a0,s2
    80003c84:	f84ff0ef          	jal	ra,80003408 <brelse>
    if (ip) {
    80003c88:	bf7d                	j	80003c46 <ireclaim+0x70>
}
    80003c8a:	70e2                	ld	ra,56(sp)
    80003c8c:	7442                	ld	s0,48(sp)
    80003c8e:	74a2                	ld	s1,40(sp)
    80003c90:	7902                	ld	s2,32(sp)
    80003c92:	69e2                	ld	s3,24(sp)
    80003c94:	6a42                	ld	s4,16(sp)
    80003c96:	6aa2                	ld	s5,8(sp)
    80003c98:	6b02                	ld	s6,0(sp)
    80003c9a:	6121                	addi	sp,sp,64
    80003c9c:	8082                	ret
    80003c9e:	8082                	ret

0000000080003ca0 <fsinit>:
fsinit(int dev) {
    80003ca0:	7179                	addi	sp,sp,-48
    80003ca2:	f406                	sd	ra,40(sp)
    80003ca4:	f022                	sd	s0,32(sp)
    80003ca6:	ec26                	sd	s1,24(sp)
    80003ca8:	e84a                	sd	s2,16(sp)
    80003caa:	e44e                	sd	s3,8(sp)
    80003cac:	1800                	addi	s0,sp,48
    80003cae:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003cb0:	4585                	li	a1,1
    80003cb2:	e4eff0ef          	jal	ra,80003300 <bread>
    80003cb6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cb8:	00245997          	auipc	s3,0x245
    80003cbc:	20098993          	addi	s3,s3,512 # 80248eb8 <sb>
    80003cc0:	02000613          	li	a2,32
    80003cc4:	05850593          	addi	a1,a0,88
    80003cc8:	854e                	mv	a0,s3
    80003cca:	906fd0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    80003cce:	854a                	mv	a0,s2
    80003cd0:	f38ff0ef          	jal	ra,80003408 <brelse>
  if(sb.magic != FSMAGIC)
    80003cd4:	0009a703          	lw	a4,0(s3)
    80003cd8:	102037b7          	lui	a5,0x10203
    80003cdc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ce0:	02f71363          	bne	a4,a5,80003d06 <fsinit+0x66>
  initlog(dev, &sb);
    80003ce4:	00245597          	auipc	a1,0x245
    80003ce8:	1d458593          	addi	a1,a1,468 # 80248eb8 <sb>
    80003cec:	8526                	mv	a0,s1
    80003cee:	61e000ef          	jal	ra,8000430c <initlog>
  ireclaim(dev);
    80003cf2:	8526                	mv	a0,s1
    80003cf4:	ee3ff0ef          	jal	ra,80003bd6 <ireclaim>
}
    80003cf8:	70a2                	ld	ra,40(sp)
    80003cfa:	7402                	ld	s0,32(sp)
    80003cfc:	64e2                	ld	s1,24(sp)
    80003cfe:	6942                	ld	s2,16(sp)
    80003d00:	69a2                	ld	s3,8(sp)
    80003d02:	6145                	addi	sp,sp,48
    80003d04:	8082                	ret
    panic("invalid file system");
    80003d06:	00005517          	auipc	a0,0x5
    80003d0a:	8aa50513          	addi	a0,a0,-1878 # 800085b0 <syscalls+0x1b8>
    80003d0e:	a7bfc0ef          	jal	ra,80000788 <panic>

0000000080003d12 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d12:	1141                	addi	sp,sp,-16
    80003d14:	e422                	sd	s0,8(sp)
    80003d16:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d18:	411c                	lw	a5,0(a0)
    80003d1a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d1c:	415c                	lw	a5,4(a0)
    80003d1e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d20:	04451783          	lh	a5,68(a0)
    80003d24:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d28:	04a51783          	lh	a5,74(a0)
    80003d2c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d30:	04c56783          	lwu	a5,76(a0)
    80003d34:	e99c                	sd	a5,16(a1)
}
    80003d36:	6422                	ld	s0,8(sp)
    80003d38:	0141                	addi	sp,sp,16
    80003d3a:	8082                	ret

0000000080003d3c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d3c:	457c                	lw	a5,76(a0)
    80003d3e:	0cd7ef63          	bltu	a5,a3,80003e1c <readi+0xe0>
{
    80003d42:	7159                	addi	sp,sp,-112
    80003d44:	f486                	sd	ra,104(sp)
    80003d46:	f0a2                	sd	s0,96(sp)
    80003d48:	eca6                	sd	s1,88(sp)
    80003d4a:	e8ca                	sd	s2,80(sp)
    80003d4c:	e4ce                	sd	s3,72(sp)
    80003d4e:	e0d2                	sd	s4,64(sp)
    80003d50:	fc56                	sd	s5,56(sp)
    80003d52:	f85a                	sd	s6,48(sp)
    80003d54:	f45e                	sd	s7,40(sp)
    80003d56:	f062                	sd	s8,32(sp)
    80003d58:	ec66                	sd	s9,24(sp)
    80003d5a:	e86a                	sd	s10,16(sp)
    80003d5c:	e46e                	sd	s11,8(sp)
    80003d5e:	1880                	addi	s0,sp,112
    80003d60:	8b2a                	mv	s6,a0
    80003d62:	8bae                	mv	s7,a1
    80003d64:	8a32                	mv	s4,a2
    80003d66:	84b6                	mv	s1,a3
    80003d68:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003d6a:	9f35                	addw	a4,a4,a3
    return 0;
    80003d6c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d6e:	08d76663          	bltu	a4,a3,80003dfa <readi+0xbe>
  if(off + n > ip->size)
    80003d72:	00e7f463          	bgeu	a5,a4,80003d7a <readi+0x3e>
    n = ip->size - off;
    80003d76:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d7a:	080a8f63          	beqz	s5,80003e18 <readi+0xdc>
    80003d7e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d80:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d84:	5c7d                	li	s8,-1
    80003d86:	a80d                	j	80003db8 <readi+0x7c>
    80003d88:	020d1d93          	slli	s11,s10,0x20
    80003d8c:	020ddd93          	srli	s11,s11,0x20
    80003d90:	05890613          	addi	a2,s2,88
    80003d94:	86ee                	mv	a3,s11
    80003d96:	963a                	add	a2,a2,a4
    80003d98:	85d2                	mv	a1,s4
    80003d9a:	855e                	mv	a0,s7
    80003d9c:	f82fe0ef          	jal	ra,8000251e <either_copyout>
    80003da0:	05850763          	beq	a0,s8,80003dee <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003da4:	854a                	mv	a0,s2
    80003da6:	e62ff0ef          	jal	ra,80003408 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003daa:	013d09bb          	addw	s3,s10,s3
    80003dae:	009d04bb          	addw	s1,s10,s1
    80003db2:	9a6e                	add	s4,s4,s11
    80003db4:	0559f163          	bgeu	s3,s5,80003df6 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003db8:	00a4d59b          	srliw	a1,s1,0xa
    80003dbc:	855a                	mv	a0,s6
    80003dbe:	8b7ff0ef          	jal	ra,80003674 <bmap>
    80003dc2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dc6:	c985                	beqz	a1,80003df6 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003dc8:	000b2503          	lw	a0,0(s6)
    80003dcc:	d34ff0ef          	jal	ra,80003300 <bread>
    80003dd0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dd2:	3ff4f713          	andi	a4,s1,1023
    80003dd6:	40ec87bb          	subw	a5,s9,a4
    80003dda:	413a86bb          	subw	a3,s5,s3
    80003dde:	8d3e                	mv	s10,a5
    80003de0:	2781                	sext.w	a5,a5
    80003de2:	0006861b          	sext.w	a2,a3
    80003de6:	faf671e3          	bgeu	a2,a5,80003d88 <readi+0x4c>
    80003dea:	8d36                	mv	s10,a3
    80003dec:	bf71                	j	80003d88 <readi+0x4c>
      brelse(bp);
    80003dee:	854a                	mv	a0,s2
    80003df0:	e18ff0ef          	jal	ra,80003408 <brelse>
      tot = -1;
    80003df4:	59fd                	li	s3,-1
  }
  return tot;
    80003df6:	0009851b          	sext.w	a0,s3
}
    80003dfa:	70a6                	ld	ra,104(sp)
    80003dfc:	7406                	ld	s0,96(sp)
    80003dfe:	64e6                	ld	s1,88(sp)
    80003e00:	6946                	ld	s2,80(sp)
    80003e02:	69a6                	ld	s3,72(sp)
    80003e04:	6a06                	ld	s4,64(sp)
    80003e06:	7ae2                	ld	s5,56(sp)
    80003e08:	7b42                	ld	s6,48(sp)
    80003e0a:	7ba2                	ld	s7,40(sp)
    80003e0c:	7c02                	ld	s8,32(sp)
    80003e0e:	6ce2                	ld	s9,24(sp)
    80003e10:	6d42                	ld	s10,16(sp)
    80003e12:	6da2                	ld	s11,8(sp)
    80003e14:	6165                	addi	sp,sp,112
    80003e16:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e18:	89d6                	mv	s3,s5
    80003e1a:	bff1                	j	80003df6 <readi+0xba>
    return 0;
    80003e1c:	4501                	li	a0,0
}
    80003e1e:	8082                	ret

0000000080003e20 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e20:	457c                	lw	a5,76(a0)
    80003e22:	0ed7ea63          	bltu	a5,a3,80003f16 <writei+0xf6>
{
    80003e26:	7159                	addi	sp,sp,-112
    80003e28:	f486                	sd	ra,104(sp)
    80003e2a:	f0a2                	sd	s0,96(sp)
    80003e2c:	eca6                	sd	s1,88(sp)
    80003e2e:	e8ca                	sd	s2,80(sp)
    80003e30:	e4ce                	sd	s3,72(sp)
    80003e32:	e0d2                	sd	s4,64(sp)
    80003e34:	fc56                	sd	s5,56(sp)
    80003e36:	f85a                	sd	s6,48(sp)
    80003e38:	f45e                	sd	s7,40(sp)
    80003e3a:	f062                	sd	s8,32(sp)
    80003e3c:	ec66                	sd	s9,24(sp)
    80003e3e:	e86a                	sd	s10,16(sp)
    80003e40:	e46e                	sd	s11,8(sp)
    80003e42:	1880                	addi	s0,sp,112
    80003e44:	8aaa                	mv	s5,a0
    80003e46:	8bae                	mv	s7,a1
    80003e48:	8a32                	mv	s4,a2
    80003e4a:	8936                	mv	s2,a3
    80003e4c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e4e:	00e687bb          	addw	a5,a3,a4
    80003e52:	0cd7e463          	bltu	a5,a3,80003f1a <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e56:	00043737          	lui	a4,0x43
    80003e5a:	0cf76263          	bltu	a4,a5,80003f1e <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e5e:	0a0b0a63          	beqz	s6,80003f12 <writei+0xf2>
    80003e62:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e64:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e68:	5c7d                	li	s8,-1
    80003e6a:	a825                	j	80003ea2 <writei+0x82>
    80003e6c:	020d1d93          	slli	s11,s10,0x20
    80003e70:	020ddd93          	srli	s11,s11,0x20
    80003e74:	05848513          	addi	a0,s1,88
    80003e78:	86ee                	mv	a3,s11
    80003e7a:	8652                	mv	a2,s4
    80003e7c:	85de                	mv	a1,s7
    80003e7e:	953a                	add	a0,a0,a4
    80003e80:	ee8fe0ef          	jal	ra,80002568 <either_copyin>
    80003e84:	05850a63          	beq	a0,s8,80003ed8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	690000ef          	jal	ra,8000451a <log_write>
    brelse(bp);
    80003e8e:	8526                	mv	a0,s1
    80003e90:	d78ff0ef          	jal	ra,80003408 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e94:	013d09bb          	addw	s3,s10,s3
    80003e98:	012d093b          	addw	s2,s10,s2
    80003e9c:	9a6e                	add	s4,s4,s11
    80003e9e:	0569f063          	bgeu	s3,s6,80003ede <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003ea2:	00a9559b          	srliw	a1,s2,0xa
    80003ea6:	8556                	mv	a0,s5
    80003ea8:	fccff0ef          	jal	ra,80003674 <bmap>
    80003eac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003eb0:	c59d                	beqz	a1,80003ede <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003eb2:	000aa503          	lw	a0,0(s5)
    80003eb6:	c4aff0ef          	jal	ra,80003300 <bread>
    80003eba:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ebc:	3ff97713          	andi	a4,s2,1023
    80003ec0:	40ec87bb          	subw	a5,s9,a4
    80003ec4:	413b06bb          	subw	a3,s6,s3
    80003ec8:	8d3e                	mv	s10,a5
    80003eca:	2781                	sext.w	a5,a5
    80003ecc:	0006861b          	sext.w	a2,a3
    80003ed0:	f8f67ee3          	bgeu	a2,a5,80003e6c <writei+0x4c>
    80003ed4:	8d36                	mv	s10,a3
    80003ed6:	bf59                	j	80003e6c <writei+0x4c>
      brelse(bp);
    80003ed8:	8526                	mv	a0,s1
    80003eda:	d2eff0ef          	jal	ra,80003408 <brelse>
  }

  if(off > ip->size)
    80003ede:	04caa783          	lw	a5,76(s5)
    80003ee2:	0127f463          	bgeu	a5,s2,80003eea <writei+0xca>
    ip->size = off;
    80003ee6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003eea:	8556                	mv	a0,s5
    80003eec:	a11ff0ef          	jal	ra,800038fc <iupdate>

  return tot;
    80003ef0:	0009851b          	sext.w	a0,s3
}
    80003ef4:	70a6                	ld	ra,104(sp)
    80003ef6:	7406                	ld	s0,96(sp)
    80003ef8:	64e6                	ld	s1,88(sp)
    80003efa:	6946                	ld	s2,80(sp)
    80003efc:	69a6                	ld	s3,72(sp)
    80003efe:	6a06                	ld	s4,64(sp)
    80003f00:	7ae2                	ld	s5,56(sp)
    80003f02:	7b42                	ld	s6,48(sp)
    80003f04:	7ba2                	ld	s7,40(sp)
    80003f06:	7c02                	ld	s8,32(sp)
    80003f08:	6ce2                	ld	s9,24(sp)
    80003f0a:	6d42                	ld	s10,16(sp)
    80003f0c:	6da2                	ld	s11,8(sp)
    80003f0e:	6165                	addi	sp,sp,112
    80003f10:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f12:	89da                	mv	s3,s6
    80003f14:	bfd9                	j	80003eea <writei+0xca>
    return -1;
    80003f16:	557d                	li	a0,-1
}
    80003f18:	8082                	ret
    return -1;
    80003f1a:	557d                	li	a0,-1
    80003f1c:	bfe1                	j	80003ef4 <writei+0xd4>
    return -1;
    80003f1e:	557d                	li	a0,-1
    80003f20:	bfd1                	j	80003ef4 <writei+0xd4>

0000000080003f22 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f22:	1141                	addi	sp,sp,-16
    80003f24:	e406                	sd	ra,8(sp)
    80003f26:	e022                	sd	s0,0(sp)
    80003f28:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f2a:	4639                	li	a2,14
    80003f2c:	f15fc0ef          	jal	ra,80000e40 <strncmp>
}
    80003f30:	60a2                	ld	ra,8(sp)
    80003f32:	6402                	ld	s0,0(sp)
    80003f34:	0141                	addi	sp,sp,16
    80003f36:	8082                	ret

0000000080003f38 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f38:	7139                	addi	sp,sp,-64
    80003f3a:	fc06                	sd	ra,56(sp)
    80003f3c:	f822                	sd	s0,48(sp)
    80003f3e:	f426                	sd	s1,40(sp)
    80003f40:	f04a                	sd	s2,32(sp)
    80003f42:	ec4e                	sd	s3,24(sp)
    80003f44:	e852                	sd	s4,16(sp)
    80003f46:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f48:	04451703          	lh	a4,68(a0)
    80003f4c:	4785                	li	a5,1
    80003f4e:	00f71a63          	bne	a4,a5,80003f62 <dirlookup+0x2a>
    80003f52:	892a                	mv	s2,a0
    80003f54:	89ae                	mv	s3,a1
    80003f56:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f58:	457c                	lw	a5,76(a0)
    80003f5a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f5c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f5e:	e39d                	bnez	a5,80003f84 <dirlookup+0x4c>
    80003f60:	a095                	j	80003fc4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003f62:	00004517          	auipc	a0,0x4
    80003f66:	66650513          	addi	a0,a0,1638 # 800085c8 <syscalls+0x1d0>
    80003f6a:	81ffc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80003f6e:	00004517          	auipc	a0,0x4
    80003f72:	67250513          	addi	a0,a0,1650 # 800085e0 <syscalls+0x1e8>
    80003f76:	813fc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f7a:	24c1                	addiw	s1,s1,16
    80003f7c:	04c92783          	lw	a5,76(s2)
    80003f80:	04f4f163          	bgeu	s1,a5,80003fc2 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f84:	4741                	li	a4,16
    80003f86:	86a6                	mv	a3,s1
    80003f88:	fc040613          	addi	a2,s0,-64
    80003f8c:	4581                	li	a1,0
    80003f8e:	854a                	mv	a0,s2
    80003f90:	dadff0ef          	jal	ra,80003d3c <readi>
    80003f94:	47c1                	li	a5,16
    80003f96:	fcf51ce3          	bne	a0,a5,80003f6e <dirlookup+0x36>
    if(de.inum == 0)
    80003f9a:	fc045783          	lhu	a5,-64(s0)
    80003f9e:	dff1                	beqz	a5,80003f7a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003fa0:	fc240593          	addi	a1,s0,-62
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	f7dff0ef          	jal	ra,80003f22 <namecmp>
    80003faa:	f961                	bnez	a0,80003f7a <dirlookup+0x42>
      if(poff)
    80003fac:	000a0463          	beqz	s4,80003fb4 <dirlookup+0x7c>
        *poff = off;
    80003fb0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003fb4:	fc045583          	lhu	a1,-64(s0)
    80003fb8:	00092503          	lw	a0,0(s2)
    80003fbc:	f86ff0ef          	jal	ra,80003742 <iget>
    80003fc0:	a011                	j	80003fc4 <dirlookup+0x8c>
  return 0;
    80003fc2:	4501                	li	a0,0
}
    80003fc4:	70e2                	ld	ra,56(sp)
    80003fc6:	7442                	ld	s0,48(sp)
    80003fc8:	74a2                	ld	s1,40(sp)
    80003fca:	7902                	ld	s2,32(sp)
    80003fcc:	69e2                	ld	s3,24(sp)
    80003fce:	6a42                	ld	s4,16(sp)
    80003fd0:	6121                	addi	sp,sp,64
    80003fd2:	8082                	ret

0000000080003fd4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fd4:	711d                	addi	sp,sp,-96
    80003fd6:	ec86                	sd	ra,88(sp)
    80003fd8:	e8a2                	sd	s0,80(sp)
    80003fda:	e4a6                	sd	s1,72(sp)
    80003fdc:	e0ca                	sd	s2,64(sp)
    80003fde:	fc4e                	sd	s3,56(sp)
    80003fe0:	f852                	sd	s4,48(sp)
    80003fe2:	f456                	sd	s5,40(sp)
    80003fe4:	f05a                	sd	s6,32(sp)
    80003fe6:	ec5e                	sd	s7,24(sp)
    80003fe8:	e862                	sd	s8,16(sp)
    80003fea:	e466                	sd	s9,8(sp)
    80003fec:	e06a                	sd	s10,0(sp)
    80003fee:	1080                	addi	s0,sp,96
    80003ff0:	84aa                	mv	s1,a0
    80003ff2:	8b2e                	mv	s6,a1
    80003ff4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ff6:	00054703          	lbu	a4,0(a0)
    80003ffa:	02f00793          	li	a5,47
    80003ffe:	00f70f63          	beq	a4,a5,8000401c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004002:	b37fd0ef          	jal	ra,80001b38 <myproc>
    80004006:	15053503          	ld	a0,336(a0)
    8000400a:	971ff0ef          	jal	ra,8000397a <idup>
    8000400e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004010:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004014:	4cb5                	li	s9,13
  len = path - s;
    80004016:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004018:	4c05                	li	s8,1
    8000401a:	a879                	j	800040b8 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000401c:	4585                	li	a1,1
    8000401e:	4505                	li	a0,1
    80004020:	f22ff0ef          	jal	ra,80003742 <iget>
    80004024:	8a2a                	mv	s4,a0
    80004026:	b7ed                	j	80004010 <namex+0x3c>
      iunlockput(ip);
    80004028:	8552                	mv	a0,s4
    8000402a:	b8dff0ef          	jal	ra,80003bb6 <iunlockput>
      return 0;
    8000402e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004030:	8552                	mv	a0,s4
    80004032:	60e6                	ld	ra,88(sp)
    80004034:	6446                	ld	s0,80(sp)
    80004036:	64a6                	ld	s1,72(sp)
    80004038:	6906                	ld	s2,64(sp)
    8000403a:	79e2                	ld	s3,56(sp)
    8000403c:	7a42                	ld	s4,48(sp)
    8000403e:	7aa2                	ld	s5,40(sp)
    80004040:	7b02                	ld	s6,32(sp)
    80004042:	6be2                	ld	s7,24(sp)
    80004044:	6c42                	ld	s8,16(sp)
    80004046:	6ca2                	ld	s9,8(sp)
    80004048:	6d02                	ld	s10,0(sp)
    8000404a:	6125                	addi	sp,sp,96
    8000404c:	8082                	ret
      iunlock(ip);
    8000404e:	8552                	mv	a0,s4
    80004050:	a0bff0ef          	jal	ra,80003a5a <iunlock>
      return ip;
    80004054:	bff1                	j	80004030 <namex+0x5c>
      iunlockput(ip);
    80004056:	8552                	mv	a0,s4
    80004058:	b5fff0ef          	jal	ra,80003bb6 <iunlockput>
      return 0;
    8000405c:	8a4e                	mv	s4,s3
    8000405e:	bfc9                	j	80004030 <namex+0x5c>
  len = path - s;
    80004060:	40998633          	sub	a2,s3,s1
    80004064:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004068:	09acd063          	bge	s9,s10,800040e8 <namex+0x114>
    memmove(name, s, DIRSIZ);
    8000406c:	4639                	li	a2,14
    8000406e:	85a6                	mv	a1,s1
    80004070:	8556                	mv	a0,s5
    80004072:	d5ffc0ef          	jal	ra,80000dd0 <memmove>
    80004076:	84ce                	mv	s1,s3
  while(*path == '/')
    80004078:	0004c783          	lbu	a5,0(s1)
    8000407c:	01279763          	bne	a5,s2,8000408a <namex+0xb6>
    path++;
    80004080:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004082:	0004c783          	lbu	a5,0(s1)
    80004086:	ff278de3          	beq	a5,s2,80004080 <namex+0xac>
    ilock(ip);
    8000408a:	8552                	mv	a0,s4
    8000408c:	925ff0ef          	jal	ra,800039b0 <ilock>
    if(ip->type != T_DIR){
    80004090:	044a1783          	lh	a5,68(s4)
    80004094:	f9879ae3          	bne	a5,s8,80004028 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80004098:	000b0563          	beqz	s6,800040a2 <namex+0xce>
    8000409c:	0004c783          	lbu	a5,0(s1)
    800040a0:	d7dd                	beqz	a5,8000404e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040a2:	865e                	mv	a2,s7
    800040a4:	85d6                	mv	a1,s5
    800040a6:	8552                	mv	a0,s4
    800040a8:	e91ff0ef          	jal	ra,80003f38 <dirlookup>
    800040ac:	89aa                	mv	s3,a0
    800040ae:	d545                	beqz	a0,80004056 <namex+0x82>
    iunlockput(ip);
    800040b0:	8552                	mv	a0,s4
    800040b2:	b05ff0ef          	jal	ra,80003bb6 <iunlockput>
    ip = next;
    800040b6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800040b8:	0004c783          	lbu	a5,0(s1)
    800040bc:	01279763          	bne	a5,s2,800040ca <namex+0xf6>
    path++;
    800040c0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040c2:	0004c783          	lbu	a5,0(s1)
    800040c6:	ff278de3          	beq	a5,s2,800040c0 <namex+0xec>
  if(*path == 0)
    800040ca:	cb8d                	beqz	a5,800040fc <namex+0x128>
  while(*path != '/' && *path != 0)
    800040cc:	0004c783          	lbu	a5,0(s1)
    800040d0:	89a6                	mv	s3,s1
  len = path - s;
    800040d2:	8d5e                	mv	s10,s7
    800040d4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800040d6:	01278963          	beq	a5,s2,800040e8 <namex+0x114>
    800040da:	d3d9                	beqz	a5,80004060 <namex+0x8c>
    path++;
    800040dc:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800040de:	0009c783          	lbu	a5,0(s3)
    800040e2:	ff279ce3          	bne	a5,s2,800040da <namex+0x106>
    800040e6:	bfad                	j	80004060 <namex+0x8c>
    memmove(name, s, len);
    800040e8:	2601                	sext.w	a2,a2
    800040ea:	85a6                	mv	a1,s1
    800040ec:	8556                	mv	a0,s5
    800040ee:	ce3fc0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    800040f2:	9d56                	add	s10,s10,s5
    800040f4:	000d0023          	sb	zero,0(s10)
    800040f8:	84ce                	mv	s1,s3
    800040fa:	bfbd                	j	80004078 <namex+0xa4>
  if(nameiparent){
    800040fc:	f20b0ae3          	beqz	s6,80004030 <namex+0x5c>
    iput(ip);
    80004100:	8552                	mv	a0,s4
    80004102:	a2dff0ef          	jal	ra,80003b2e <iput>
    return 0;
    80004106:	4a01                	li	s4,0
    80004108:	b725                	j	80004030 <namex+0x5c>

000000008000410a <dirlink>:
{
    8000410a:	7139                	addi	sp,sp,-64
    8000410c:	fc06                	sd	ra,56(sp)
    8000410e:	f822                	sd	s0,48(sp)
    80004110:	f426                	sd	s1,40(sp)
    80004112:	f04a                	sd	s2,32(sp)
    80004114:	ec4e                	sd	s3,24(sp)
    80004116:	e852                	sd	s4,16(sp)
    80004118:	0080                	addi	s0,sp,64
    8000411a:	892a                	mv	s2,a0
    8000411c:	8a2e                	mv	s4,a1
    8000411e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004120:	4601                	li	a2,0
    80004122:	e17ff0ef          	jal	ra,80003f38 <dirlookup>
    80004126:	e52d                	bnez	a0,80004190 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004128:	04c92483          	lw	s1,76(s2)
    8000412c:	c48d                	beqz	s1,80004156 <dirlink+0x4c>
    8000412e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004130:	4741                	li	a4,16
    80004132:	86a6                	mv	a3,s1
    80004134:	fc040613          	addi	a2,s0,-64
    80004138:	4581                	li	a1,0
    8000413a:	854a                	mv	a0,s2
    8000413c:	c01ff0ef          	jal	ra,80003d3c <readi>
    80004140:	47c1                	li	a5,16
    80004142:	04f51b63          	bne	a0,a5,80004198 <dirlink+0x8e>
    if(de.inum == 0)
    80004146:	fc045783          	lhu	a5,-64(s0)
    8000414a:	c791                	beqz	a5,80004156 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000414c:	24c1                	addiw	s1,s1,16
    8000414e:	04c92783          	lw	a5,76(s2)
    80004152:	fcf4efe3          	bltu	s1,a5,80004130 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004156:	4639                	li	a2,14
    80004158:	85d2                	mv	a1,s4
    8000415a:	fc240513          	addi	a0,s0,-62
    8000415e:	d1ffc0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    80004162:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004166:	4741                	li	a4,16
    80004168:	86a6                	mv	a3,s1
    8000416a:	fc040613          	addi	a2,s0,-64
    8000416e:	4581                	li	a1,0
    80004170:	854a                	mv	a0,s2
    80004172:	cafff0ef          	jal	ra,80003e20 <writei>
    80004176:	1541                	addi	a0,a0,-16
    80004178:	00a03533          	snez	a0,a0
    8000417c:	40a00533          	neg	a0,a0
}
    80004180:	70e2                	ld	ra,56(sp)
    80004182:	7442                	ld	s0,48(sp)
    80004184:	74a2                	ld	s1,40(sp)
    80004186:	7902                	ld	s2,32(sp)
    80004188:	69e2                	ld	s3,24(sp)
    8000418a:	6a42                	ld	s4,16(sp)
    8000418c:	6121                	addi	sp,sp,64
    8000418e:	8082                	ret
    iput(ip);
    80004190:	99fff0ef          	jal	ra,80003b2e <iput>
    return -1;
    80004194:	557d                	li	a0,-1
    80004196:	b7ed                	j	80004180 <dirlink+0x76>
      panic("dirlink read");
    80004198:	00004517          	auipc	a0,0x4
    8000419c:	45850513          	addi	a0,a0,1112 # 800085f0 <syscalls+0x1f8>
    800041a0:	de8fc0ef          	jal	ra,80000788 <panic>

00000000800041a4 <namei>:

struct inode*
namei(char *path)
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041ac:	fe040613          	addi	a2,s0,-32
    800041b0:	4581                	li	a1,0
    800041b2:	e23ff0ef          	jal	ra,80003fd4 <namex>
}
    800041b6:	60e2                	ld	ra,24(sp)
    800041b8:	6442                	ld	s0,16(sp)
    800041ba:	6105                	addi	sp,sp,32
    800041bc:	8082                	ret

00000000800041be <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041be:	1141                	addi	sp,sp,-16
    800041c0:	e406                	sd	ra,8(sp)
    800041c2:	e022                	sd	s0,0(sp)
    800041c4:	0800                	addi	s0,sp,16
    800041c6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041c8:	4585                	li	a1,1
    800041ca:	e0bff0ef          	jal	ra,80003fd4 <namex>
}
    800041ce:	60a2                	ld	ra,8(sp)
    800041d0:	6402                	ld	s0,0(sp)
    800041d2:	0141                	addi	sp,sp,16
    800041d4:	8082                	ret

00000000800041d6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041d6:	1101                	addi	sp,sp,-32
    800041d8:	ec06                	sd	ra,24(sp)
    800041da:	e822                	sd	s0,16(sp)
    800041dc:	e426                	sd	s1,8(sp)
    800041de:	e04a                	sd	s2,0(sp)
    800041e0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041e2:	00246917          	auipc	s2,0x246
    800041e6:	79e90913          	addi	s2,s2,1950 # 8024a980 <log>
    800041ea:	01892583          	lw	a1,24(s2)
    800041ee:	02492503          	lw	a0,36(s2)
    800041f2:	90eff0ef          	jal	ra,80003300 <bread>
    800041f6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041f8:	02892683          	lw	a3,40(s2)
    800041fc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041fe:	02d05863          	blez	a3,8000422e <write_head+0x58>
    80004202:	00246797          	auipc	a5,0x246
    80004206:	7aa78793          	addi	a5,a5,1962 # 8024a9ac <log+0x2c>
    8000420a:	05c50713          	addi	a4,a0,92
    8000420e:	36fd                	addiw	a3,a3,-1
    80004210:	02069613          	slli	a2,a3,0x20
    80004214:	01e65693          	srli	a3,a2,0x1e
    80004218:	00246617          	auipc	a2,0x246
    8000421c:	79860613          	addi	a2,a2,1944 # 8024a9b0 <log+0x30>
    80004220:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004222:	4390                	lw	a2,0(a5)
    80004224:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004226:	0791                	addi	a5,a5,4
    80004228:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000422a:	fed79ce3          	bne	a5,a3,80004222 <write_head+0x4c>
  }
  bwrite(buf);
    8000422e:	8526                	mv	a0,s1
    80004230:	9a6ff0ef          	jal	ra,800033d6 <bwrite>
  brelse(buf);
    80004234:	8526                	mv	a0,s1
    80004236:	9d2ff0ef          	jal	ra,80003408 <brelse>
}
    8000423a:	60e2                	ld	ra,24(sp)
    8000423c:	6442                	ld	s0,16(sp)
    8000423e:	64a2                	ld	s1,8(sp)
    80004240:	6902                	ld	s2,0(sp)
    80004242:	6105                	addi	sp,sp,32
    80004244:	8082                	ret

0000000080004246 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004246:	00246797          	auipc	a5,0x246
    8000424a:	7627a783          	lw	a5,1890(a5) # 8024a9a8 <log+0x28>
    8000424e:	0af05e63          	blez	a5,8000430a <install_trans+0xc4>
{
    80004252:	715d                	addi	sp,sp,-80
    80004254:	e486                	sd	ra,72(sp)
    80004256:	e0a2                	sd	s0,64(sp)
    80004258:	fc26                	sd	s1,56(sp)
    8000425a:	f84a                	sd	s2,48(sp)
    8000425c:	f44e                	sd	s3,40(sp)
    8000425e:	f052                	sd	s4,32(sp)
    80004260:	ec56                	sd	s5,24(sp)
    80004262:	e85a                	sd	s6,16(sp)
    80004264:	e45e                	sd	s7,8(sp)
    80004266:	0880                	addi	s0,sp,80
    80004268:	8b2a                	mv	s6,a0
    8000426a:	00246a97          	auipc	s5,0x246
    8000426e:	742a8a93          	addi	s5,s5,1858 # 8024a9ac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004272:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004274:	00004b97          	auipc	s7,0x4
    80004278:	38cb8b93          	addi	s7,s7,908 # 80008600 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000427c:	00246a17          	auipc	s4,0x246
    80004280:	704a0a13          	addi	s4,s4,1796 # 8024a980 <log>
    80004284:	a025                	j	800042ac <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004286:	000aa603          	lw	a2,0(s5)
    8000428a:	85ce                	mv	a1,s3
    8000428c:	855e                	mv	a0,s7
    8000428e:	a34fc0ef          	jal	ra,800004c2 <printf>
    80004292:	a839                	j	800042b0 <install_trans+0x6a>
    brelse(lbuf);
    80004294:	854a                	mv	a0,s2
    80004296:	972ff0ef          	jal	ra,80003408 <brelse>
    brelse(dbuf);
    8000429a:	8526                	mv	a0,s1
    8000429c:	96cff0ef          	jal	ra,80003408 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042a0:	2985                	addiw	s3,s3,1
    800042a2:	0a91                	addi	s5,s5,4
    800042a4:	028a2783          	lw	a5,40(s4)
    800042a8:	04f9d663          	bge	s3,a5,800042f4 <install_trans+0xae>
    if(recovering) {
    800042ac:	fc0b1de3          	bnez	s6,80004286 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042b0:	018a2583          	lw	a1,24(s4)
    800042b4:	013585bb          	addw	a1,a1,s3
    800042b8:	2585                	addiw	a1,a1,1
    800042ba:	024a2503          	lw	a0,36(s4)
    800042be:	842ff0ef          	jal	ra,80003300 <bread>
    800042c2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042c4:	000aa583          	lw	a1,0(s5)
    800042c8:	024a2503          	lw	a0,36(s4)
    800042cc:	834ff0ef          	jal	ra,80003300 <bread>
    800042d0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042d2:	40000613          	li	a2,1024
    800042d6:	05890593          	addi	a1,s2,88
    800042da:	05850513          	addi	a0,a0,88
    800042de:	af3fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800042e2:	8526                	mv	a0,s1
    800042e4:	8f2ff0ef          	jal	ra,800033d6 <bwrite>
    if(recovering == 0)
    800042e8:	fa0b16e3          	bnez	s6,80004294 <install_trans+0x4e>
      bunpin(dbuf);
    800042ec:	8526                	mv	a0,s1
    800042ee:	9d8ff0ef          	jal	ra,800034c6 <bunpin>
    800042f2:	b74d                	j	80004294 <install_trans+0x4e>
}
    800042f4:	60a6                	ld	ra,72(sp)
    800042f6:	6406                	ld	s0,64(sp)
    800042f8:	74e2                	ld	s1,56(sp)
    800042fa:	7942                	ld	s2,48(sp)
    800042fc:	79a2                	ld	s3,40(sp)
    800042fe:	7a02                	ld	s4,32(sp)
    80004300:	6ae2                	ld	s5,24(sp)
    80004302:	6b42                	ld	s6,16(sp)
    80004304:	6ba2                	ld	s7,8(sp)
    80004306:	6161                	addi	sp,sp,80
    80004308:	8082                	ret
    8000430a:	8082                	ret

000000008000430c <initlog>:
{
    8000430c:	7179                	addi	sp,sp,-48
    8000430e:	f406                	sd	ra,40(sp)
    80004310:	f022                	sd	s0,32(sp)
    80004312:	ec26                	sd	s1,24(sp)
    80004314:	e84a                	sd	s2,16(sp)
    80004316:	e44e                	sd	s3,8(sp)
    80004318:	1800                	addi	s0,sp,48
    8000431a:	892a                	mv	s2,a0
    8000431c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000431e:	00246497          	auipc	s1,0x246
    80004322:	66248493          	addi	s1,s1,1634 # 8024a980 <log>
    80004326:	00004597          	auipc	a1,0x4
    8000432a:	2fa58593          	addi	a1,a1,762 # 80008620 <syscalls+0x228>
    8000432e:	8526                	mv	a0,s1
    80004330:	8f1fc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    80004334:	0149a583          	lw	a1,20(s3)
    80004338:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000433a:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000433e:	854a                	mv	a0,s2
    80004340:	fc1fe0ef          	jal	ra,80003300 <bread>
  log.lh.n = lh->n;
    80004344:	4d34                	lw	a3,88(a0)
    80004346:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004348:	02d05663          	blez	a3,80004374 <initlog+0x68>
    8000434c:	05c50793          	addi	a5,a0,92
    80004350:	00246717          	auipc	a4,0x246
    80004354:	65c70713          	addi	a4,a4,1628 # 8024a9ac <log+0x2c>
    80004358:	36fd                	addiw	a3,a3,-1
    8000435a:	02069613          	slli	a2,a3,0x20
    8000435e:	01e65693          	srli	a3,a2,0x1e
    80004362:	06050613          	addi	a2,a0,96
    80004366:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004368:	4390                	lw	a2,0(a5)
    8000436a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000436c:	0791                	addi	a5,a5,4
    8000436e:	0711                	addi	a4,a4,4
    80004370:	fed79ce3          	bne	a5,a3,80004368 <initlog+0x5c>
  brelse(buf);
    80004374:	894ff0ef          	jal	ra,80003408 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004378:	4505                	li	a0,1
    8000437a:	ecdff0ef          	jal	ra,80004246 <install_trans>
  log.lh.n = 0;
    8000437e:	00246797          	auipc	a5,0x246
    80004382:	6207a523          	sw	zero,1578(a5) # 8024a9a8 <log+0x28>
  write_head(); // clear the log
    80004386:	e51ff0ef          	jal	ra,800041d6 <write_head>
}
    8000438a:	70a2                	ld	ra,40(sp)
    8000438c:	7402                	ld	s0,32(sp)
    8000438e:	64e2                	ld	s1,24(sp)
    80004390:	6942                	ld	s2,16(sp)
    80004392:	69a2                	ld	s3,8(sp)
    80004394:	6145                	addi	sp,sp,48
    80004396:	8082                	ret

0000000080004398 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004398:	1101                	addi	sp,sp,-32
    8000439a:	ec06                	sd	ra,24(sp)
    8000439c:	e822                	sd	s0,16(sp)
    8000439e:	e426                	sd	s1,8(sp)
    800043a0:	e04a                	sd	s2,0(sp)
    800043a2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043a4:	00246517          	auipc	a0,0x246
    800043a8:	5dc50513          	addi	a0,a0,1500 # 8024a980 <log>
    800043ac:	8f5fc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    800043b0:	00246497          	auipc	s1,0x246
    800043b4:	5d048493          	addi	s1,s1,1488 # 8024a980 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800043b8:	4979                	li	s2,30
    800043ba:	a029                	j	800043c4 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800043bc:	85a6                	mv	a1,s1
    800043be:	8526                	mv	a0,s1
    800043c0:	e03fd0ef          	jal	ra,800021c2 <sleep>
    if(log.committing){
    800043c4:	509c                	lw	a5,32(s1)
    800043c6:	fbfd                	bnez	a5,800043bc <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800043c8:	4cd8                	lw	a4,28(s1)
    800043ca:	2705                	addiw	a4,a4,1
    800043cc:	0007069b          	sext.w	a3,a4
    800043d0:	0027179b          	slliw	a5,a4,0x2
    800043d4:	9fb9                	addw	a5,a5,a4
    800043d6:	0017979b          	slliw	a5,a5,0x1
    800043da:	5498                	lw	a4,40(s1)
    800043dc:	9fb9                	addw	a5,a5,a4
    800043de:	00f95763          	bge	s2,a5,800043ec <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043e2:	85a6                	mv	a1,s1
    800043e4:	8526                	mv	a0,s1
    800043e6:	dddfd0ef          	jal	ra,800021c2 <sleep>
    800043ea:	bfe9                	j	800043c4 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800043ec:	00246517          	auipc	a0,0x246
    800043f0:	59450513          	addi	a0,a0,1428 # 8024a980 <log>
    800043f4:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    800043f6:	943fc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    800043fa:	60e2                	ld	ra,24(sp)
    800043fc:	6442                	ld	s0,16(sp)
    800043fe:	64a2                	ld	s1,8(sp)
    80004400:	6902                	ld	s2,0(sp)
    80004402:	6105                	addi	sp,sp,32
    80004404:	8082                	ret

0000000080004406 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004406:	7139                	addi	sp,sp,-64
    80004408:	fc06                	sd	ra,56(sp)
    8000440a:	f822                	sd	s0,48(sp)
    8000440c:	f426                	sd	s1,40(sp)
    8000440e:	f04a                	sd	s2,32(sp)
    80004410:	ec4e                	sd	s3,24(sp)
    80004412:	e852                	sd	s4,16(sp)
    80004414:	e456                	sd	s5,8(sp)
    80004416:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004418:	00246497          	auipc	s1,0x246
    8000441c:	56848493          	addi	s1,s1,1384 # 8024a980 <log>
    80004420:	8526                	mv	a0,s1
    80004422:	87ffc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    80004426:	4cdc                	lw	a5,28(s1)
    80004428:	37fd                	addiw	a5,a5,-1
    8000442a:	0007891b          	sext.w	s2,a5
    8000442e:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004430:	509c                	lw	a5,32(s1)
    80004432:	ef9d                	bnez	a5,80004470 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004434:	04091463          	bnez	s2,8000447c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004438:	00246497          	auipc	s1,0x246
    8000443c:	54848493          	addi	s1,s1,1352 # 8024a980 <log>
    80004440:	4785                	li	a5,1
    80004442:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004444:	8526                	mv	a0,s1
    80004446:	8f3fc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000444a:	549c                	lw	a5,40(s1)
    8000444c:	04f04b63          	bgtz	a5,800044a2 <end_op+0x9c>
    acquire(&log.lock);
    80004450:	00246497          	auipc	s1,0x246
    80004454:	53048493          	addi	s1,s1,1328 # 8024a980 <log>
    80004458:	8526                	mv	a0,s1
    8000445a:	847fc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    8000445e:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004462:	8526                	mv	a0,s1
    80004464:	dabfd0ef          	jal	ra,8000220e <wakeup>
    release(&log.lock);
    80004468:	8526                	mv	a0,s1
    8000446a:	8cffc0ef          	jal	ra,80000d38 <release>
}
    8000446e:	a00d                	j	80004490 <end_op+0x8a>
    panic("log.committing");
    80004470:	00004517          	auipc	a0,0x4
    80004474:	1b850513          	addi	a0,a0,440 # 80008628 <syscalls+0x230>
    80004478:	b10fc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    8000447c:	00246497          	auipc	s1,0x246
    80004480:	50448493          	addi	s1,s1,1284 # 8024a980 <log>
    80004484:	8526                	mv	a0,s1
    80004486:	d89fd0ef          	jal	ra,8000220e <wakeup>
  release(&log.lock);
    8000448a:	8526                	mv	a0,s1
    8000448c:	8adfc0ef          	jal	ra,80000d38 <release>
}
    80004490:	70e2                	ld	ra,56(sp)
    80004492:	7442                	ld	s0,48(sp)
    80004494:	74a2                	ld	s1,40(sp)
    80004496:	7902                	ld	s2,32(sp)
    80004498:	69e2                	ld	s3,24(sp)
    8000449a:	6a42                	ld	s4,16(sp)
    8000449c:	6aa2                	ld	s5,8(sp)
    8000449e:	6121                	addi	sp,sp,64
    800044a0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800044a2:	00246a97          	auipc	s5,0x246
    800044a6:	50aa8a93          	addi	s5,s5,1290 # 8024a9ac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044aa:	00246a17          	auipc	s4,0x246
    800044ae:	4d6a0a13          	addi	s4,s4,1238 # 8024a980 <log>
    800044b2:	018a2583          	lw	a1,24(s4)
    800044b6:	012585bb          	addw	a1,a1,s2
    800044ba:	2585                	addiw	a1,a1,1
    800044bc:	024a2503          	lw	a0,36(s4)
    800044c0:	e41fe0ef          	jal	ra,80003300 <bread>
    800044c4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044c6:	000aa583          	lw	a1,0(s5)
    800044ca:	024a2503          	lw	a0,36(s4)
    800044ce:	e33fe0ef          	jal	ra,80003300 <bread>
    800044d2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044d4:	40000613          	li	a2,1024
    800044d8:	05850593          	addi	a1,a0,88
    800044dc:	05848513          	addi	a0,s1,88
    800044e0:	8f1fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    800044e4:	8526                	mv	a0,s1
    800044e6:	ef1fe0ef          	jal	ra,800033d6 <bwrite>
    brelse(from);
    800044ea:	854e                	mv	a0,s3
    800044ec:	f1dfe0ef          	jal	ra,80003408 <brelse>
    brelse(to);
    800044f0:	8526                	mv	a0,s1
    800044f2:	f17fe0ef          	jal	ra,80003408 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044f6:	2905                	addiw	s2,s2,1
    800044f8:	0a91                	addi	s5,s5,4
    800044fa:	028a2783          	lw	a5,40(s4)
    800044fe:	faf94ae3          	blt	s2,a5,800044b2 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004502:	cd5ff0ef          	jal	ra,800041d6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004506:	4501                	li	a0,0
    80004508:	d3fff0ef          	jal	ra,80004246 <install_trans>
    log.lh.n = 0;
    8000450c:	00246797          	auipc	a5,0x246
    80004510:	4807ae23          	sw	zero,1180(a5) # 8024a9a8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004514:	cc3ff0ef          	jal	ra,800041d6 <write_head>
    80004518:	bf25                	j	80004450 <end_op+0x4a>

000000008000451a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000451a:	1101                	addi	sp,sp,-32
    8000451c:	ec06                	sd	ra,24(sp)
    8000451e:	e822                	sd	s0,16(sp)
    80004520:	e426                	sd	s1,8(sp)
    80004522:	e04a                	sd	s2,0(sp)
    80004524:	1000                	addi	s0,sp,32
    80004526:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004528:	00246917          	auipc	s2,0x246
    8000452c:	45890913          	addi	s2,s2,1112 # 8024a980 <log>
    80004530:	854a                	mv	a0,s2
    80004532:	f6efc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004536:	02892603          	lw	a2,40(s2)
    8000453a:	47f5                	li	a5,29
    8000453c:	04c7cc63          	blt	a5,a2,80004594 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004540:	00246797          	auipc	a5,0x246
    80004544:	45c7a783          	lw	a5,1116(a5) # 8024a99c <log+0x1c>
    80004548:	04f05c63          	blez	a5,800045a0 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000454c:	4781                	li	a5,0
    8000454e:	04c05f63          	blez	a2,800045ac <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004552:	44cc                	lw	a1,12(s1)
    80004554:	00246717          	auipc	a4,0x246
    80004558:	45870713          	addi	a4,a4,1112 # 8024a9ac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000455c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000455e:	4314                	lw	a3,0(a4)
    80004560:	04b68663          	beq	a3,a1,800045ac <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004564:	2785                	addiw	a5,a5,1
    80004566:	0711                	addi	a4,a4,4
    80004568:	fef61be3          	bne	a2,a5,8000455e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000456c:	0621                	addi	a2,a2,8
    8000456e:	060a                	slli	a2,a2,0x2
    80004570:	00246797          	auipc	a5,0x246
    80004574:	41078793          	addi	a5,a5,1040 # 8024a980 <log>
    80004578:	97b2                	add	a5,a5,a2
    8000457a:	44d8                	lw	a4,12(s1)
    8000457c:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000457e:	8526                	mv	a0,s1
    80004580:	f13fe0ef          	jal	ra,80003492 <bpin>
    log.lh.n++;
    80004584:	00246717          	auipc	a4,0x246
    80004588:	3fc70713          	addi	a4,a4,1020 # 8024a980 <log>
    8000458c:	571c                	lw	a5,40(a4)
    8000458e:	2785                	addiw	a5,a5,1
    80004590:	d71c                	sw	a5,40(a4)
    80004592:	a80d                	j	800045c4 <log_write+0xaa>
    panic("too big a transaction");
    80004594:	00004517          	auipc	a0,0x4
    80004598:	0a450513          	addi	a0,a0,164 # 80008638 <syscalls+0x240>
    8000459c:	9ecfc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    800045a0:	00004517          	auipc	a0,0x4
    800045a4:	0b050513          	addi	a0,a0,176 # 80008650 <syscalls+0x258>
    800045a8:	9e0fc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    800045ac:	00878693          	addi	a3,a5,8
    800045b0:	068a                	slli	a3,a3,0x2
    800045b2:	00246717          	auipc	a4,0x246
    800045b6:	3ce70713          	addi	a4,a4,974 # 8024a980 <log>
    800045ba:	9736                	add	a4,a4,a3
    800045bc:	44d4                	lw	a3,12(s1)
    800045be:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045c0:	faf60fe3          	beq	a2,a5,8000457e <log_write+0x64>
  }
  release(&log.lock);
    800045c4:	00246517          	auipc	a0,0x246
    800045c8:	3bc50513          	addi	a0,a0,956 # 8024a980 <log>
    800045cc:	f6cfc0ef          	jal	ra,80000d38 <release>
}
    800045d0:	60e2                	ld	ra,24(sp)
    800045d2:	6442                	ld	s0,16(sp)
    800045d4:	64a2                	ld	s1,8(sp)
    800045d6:	6902                	ld	s2,0(sp)
    800045d8:	6105                	addi	sp,sp,32
    800045da:	8082                	ret

00000000800045dc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045dc:	1101                	addi	sp,sp,-32
    800045de:	ec06                	sd	ra,24(sp)
    800045e0:	e822                	sd	s0,16(sp)
    800045e2:	e426                	sd	s1,8(sp)
    800045e4:	e04a                	sd	s2,0(sp)
    800045e6:	1000                	addi	s0,sp,32
    800045e8:	84aa                	mv	s1,a0
    800045ea:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045ec:	00004597          	auipc	a1,0x4
    800045f0:	08458593          	addi	a1,a1,132 # 80008670 <syscalls+0x278>
    800045f4:	0521                	addi	a0,a0,8
    800045f6:	e2afc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    800045fa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045fe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004602:	0204a423          	sw	zero,40(s1)
}
    80004606:	60e2                	ld	ra,24(sp)
    80004608:	6442                	ld	s0,16(sp)
    8000460a:	64a2                	ld	s1,8(sp)
    8000460c:	6902                	ld	s2,0(sp)
    8000460e:	6105                	addi	sp,sp,32
    80004610:	8082                	ret

0000000080004612 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004612:	1101                	addi	sp,sp,-32
    80004614:	ec06                	sd	ra,24(sp)
    80004616:	e822                	sd	s0,16(sp)
    80004618:	e426                	sd	s1,8(sp)
    8000461a:	e04a                	sd	s2,0(sp)
    8000461c:	1000                	addi	s0,sp,32
    8000461e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004620:	00850913          	addi	s2,a0,8
    80004624:	854a                	mv	a0,s2
    80004626:	e7afc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    8000462a:	409c                	lw	a5,0(s1)
    8000462c:	c799                	beqz	a5,8000463a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000462e:	85ca                	mv	a1,s2
    80004630:	8526                	mv	a0,s1
    80004632:	b91fd0ef          	jal	ra,800021c2 <sleep>
  while (lk->locked) {
    80004636:	409c                	lw	a5,0(s1)
    80004638:	fbfd                	bnez	a5,8000462e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000463a:	4785                	li	a5,1
    8000463c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000463e:	cfafd0ef          	jal	ra,80001b38 <myproc>
    80004642:	591c                	lw	a5,48(a0)
    80004644:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004646:	854a                	mv	a0,s2
    80004648:	ef0fc0ef          	jal	ra,80000d38 <release>
}
    8000464c:	60e2                	ld	ra,24(sp)
    8000464e:	6442                	ld	s0,16(sp)
    80004650:	64a2                	ld	s1,8(sp)
    80004652:	6902                	ld	s2,0(sp)
    80004654:	6105                	addi	sp,sp,32
    80004656:	8082                	ret

0000000080004658 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004658:	1101                	addi	sp,sp,-32
    8000465a:	ec06                	sd	ra,24(sp)
    8000465c:	e822                	sd	s0,16(sp)
    8000465e:	e426                	sd	s1,8(sp)
    80004660:	e04a                	sd	s2,0(sp)
    80004662:	1000                	addi	s0,sp,32
    80004664:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004666:	00850913          	addi	s2,a0,8
    8000466a:	854a                	mv	a0,s2
    8000466c:	e34fc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    80004670:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004674:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004678:	8526                	mv	a0,s1
    8000467a:	b95fd0ef          	jal	ra,8000220e <wakeup>
  release(&lk->lk);
    8000467e:	854a                	mv	a0,s2
    80004680:	eb8fc0ef          	jal	ra,80000d38 <release>
}
    80004684:	60e2                	ld	ra,24(sp)
    80004686:	6442                	ld	s0,16(sp)
    80004688:	64a2                	ld	s1,8(sp)
    8000468a:	6902                	ld	s2,0(sp)
    8000468c:	6105                	addi	sp,sp,32
    8000468e:	8082                	ret

0000000080004690 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004690:	7179                	addi	sp,sp,-48
    80004692:	f406                	sd	ra,40(sp)
    80004694:	f022                	sd	s0,32(sp)
    80004696:	ec26                	sd	s1,24(sp)
    80004698:	e84a                	sd	s2,16(sp)
    8000469a:	e44e                	sd	s3,8(sp)
    8000469c:	1800                	addi	s0,sp,48
    8000469e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046a0:	00850913          	addi	s2,a0,8
    800046a4:	854a                	mv	a0,s2
    800046a6:	dfafc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046aa:	409c                	lw	a5,0(s1)
    800046ac:	ef89                	bnez	a5,800046c6 <holdingsleep+0x36>
    800046ae:	4481                	li	s1,0
  release(&lk->lk);
    800046b0:	854a                	mv	a0,s2
    800046b2:	e86fc0ef          	jal	ra,80000d38 <release>
  return r;
}
    800046b6:	8526                	mv	a0,s1
    800046b8:	70a2                	ld	ra,40(sp)
    800046ba:	7402                	ld	s0,32(sp)
    800046bc:	64e2                	ld	s1,24(sp)
    800046be:	6942                	ld	s2,16(sp)
    800046c0:	69a2                	ld	s3,8(sp)
    800046c2:	6145                	addi	sp,sp,48
    800046c4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046c6:	0284a983          	lw	s3,40(s1)
    800046ca:	c6efd0ef          	jal	ra,80001b38 <myproc>
    800046ce:	5904                	lw	s1,48(a0)
    800046d0:	413484b3          	sub	s1,s1,s3
    800046d4:	0014b493          	seqz	s1,s1
    800046d8:	bfe1                	j	800046b0 <holdingsleep+0x20>

00000000800046da <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046da:	1141                	addi	sp,sp,-16
    800046dc:	e406                	sd	ra,8(sp)
    800046de:	e022                	sd	s0,0(sp)
    800046e0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046e2:	00004597          	auipc	a1,0x4
    800046e6:	f9e58593          	addi	a1,a1,-98 # 80008680 <syscalls+0x288>
    800046ea:	00246517          	auipc	a0,0x246
    800046ee:	3de50513          	addi	a0,a0,990 # 8024aac8 <ftable>
    800046f2:	d2efc0ef          	jal	ra,80000c20 <initlock>
}
    800046f6:	60a2                	ld	ra,8(sp)
    800046f8:	6402                	ld	s0,0(sp)
    800046fa:	0141                	addi	sp,sp,16
    800046fc:	8082                	ret

00000000800046fe <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046fe:	1101                	addi	sp,sp,-32
    80004700:	ec06                	sd	ra,24(sp)
    80004702:	e822                	sd	s0,16(sp)
    80004704:	e426                	sd	s1,8(sp)
    80004706:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004708:	00246517          	auipc	a0,0x246
    8000470c:	3c050513          	addi	a0,a0,960 # 8024aac8 <ftable>
    80004710:	d90fc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004714:	00246497          	auipc	s1,0x246
    80004718:	3cc48493          	addi	s1,s1,972 # 8024aae0 <ftable+0x18>
    8000471c:	00247717          	auipc	a4,0x247
    80004720:	36470713          	addi	a4,a4,868 # 8024ba80 <disk>
    if(f->ref == 0){
    80004724:	40dc                	lw	a5,4(s1)
    80004726:	cf89                	beqz	a5,80004740 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004728:	02848493          	addi	s1,s1,40
    8000472c:	fee49ce3          	bne	s1,a4,80004724 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004730:	00246517          	auipc	a0,0x246
    80004734:	39850513          	addi	a0,a0,920 # 8024aac8 <ftable>
    80004738:	e00fc0ef          	jal	ra,80000d38 <release>
  return 0;
    8000473c:	4481                	li	s1,0
    8000473e:	a809                	j	80004750 <filealloc+0x52>
      f->ref = 1;
    80004740:	4785                	li	a5,1
    80004742:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004744:	00246517          	auipc	a0,0x246
    80004748:	38450513          	addi	a0,a0,900 # 8024aac8 <ftable>
    8000474c:	decfc0ef          	jal	ra,80000d38 <release>
}
    80004750:	8526                	mv	a0,s1
    80004752:	60e2                	ld	ra,24(sp)
    80004754:	6442                	ld	s0,16(sp)
    80004756:	64a2                	ld	s1,8(sp)
    80004758:	6105                	addi	sp,sp,32
    8000475a:	8082                	ret

000000008000475c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000475c:	1101                	addi	sp,sp,-32
    8000475e:	ec06                	sd	ra,24(sp)
    80004760:	e822                	sd	s0,16(sp)
    80004762:	e426                	sd	s1,8(sp)
    80004764:	1000                	addi	s0,sp,32
    80004766:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004768:	00246517          	auipc	a0,0x246
    8000476c:	36050513          	addi	a0,a0,864 # 8024aac8 <ftable>
    80004770:	d30fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004774:	40dc                	lw	a5,4(s1)
    80004776:	02f05063          	blez	a5,80004796 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000477a:	2785                	addiw	a5,a5,1
    8000477c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000477e:	00246517          	auipc	a0,0x246
    80004782:	34a50513          	addi	a0,a0,842 # 8024aac8 <ftable>
    80004786:	db2fc0ef          	jal	ra,80000d38 <release>
  return f;
}
    8000478a:	8526                	mv	a0,s1
    8000478c:	60e2                	ld	ra,24(sp)
    8000478e:	6442                	ld	s0,16(sp)
    80004790:	64a2                	ld	s1,8(sp)
    80004792:	6105                	addi	sp,sp,32
    80004794:	8082                	ret
    panic("filedup");
    80004796:	00004517          	auipc	a0,0x4
    8000479a:	ef250513          	addi	a0,a0,-270 # 80008688 <syscalls+0x290>
    8000479e:	febfb0ef          	jal	ra,80000788 <panic>

00000000800047a2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047a2:	7139                	addi	sp,sp,-64
    800047a4:	fc06                	sd	ra,56(sp)
    800047a6:	f822                	sd	s0,48(sp)
    800047a8:	f426                	sd	s1,40(sp)
    800047aa:	f04a                	sd	s2,32(sp)
    800047ac:	ec4e                	sd	s3,24(sp)
    800047ae:	e852                	sd	s4,16(sp)
    800047b0:	e456                	sd	s5,8(sp)
    800047b2:	0080                	addi	s0,sp,64
    800047b4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047b6:	00246517          	auipc	a0,0x246
    800047ba:	31250513          	addi	a0,a0,786 # 8024aac8 <ftable>
    800047be:	ce2fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    800047c2:	40dc                	lw	a5,4(s1)
    800047c4:	04f05963          	blez	a5,80004816 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800047c8:	37fd                	addiw	a5,a5,-1
    800047ca:	0007871b          	sext.w	a4,a5
    800047ce:	c0dc                	sw	a5,4(s1)
    800047d0:	04e04963          	bgtz	a4,80004822 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047d4:	0004a903          	lw	s2,0(s1)
    800047d8:	0094ca83          	lbu	s5,9(s1)
    800047dc:	0104ba03          	ld	s4,16(s1)
    800047e0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047e4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047e8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047ec:	00246517          	auipc	a0,0x246
    800047f0:	2dc50513          	addi	a0,a0,732 # 8024aac8 <ftable>
    800047f4:	d44fc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    800047f8:	4785                	li	a5,1
    800047fa:	04f90363          	beq	s2,a5,80004840 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047fe:	3979                	addiw	s2,s2,-2
    80004800:	4785                	li	a5,1
    80004802:	0327e663          	bltu	a5,s2,8000482e <fileclose+0x8c>
    begin_op();
    80004806:	b93ff0ef          	jal	ra,80004398 <begin_op>
    iput(ff.ip);
    8000480a:	854e                	mv	a0,s3
    8000480c:	b22ff0ef          	jal	ra,80003b2e <iput>
    end_op();
    80004810:	bf7ff0ef          	jal	ra,80004406 <end_op>
    80004814:	a829                	j	8000482e <fileclose+0x8c>
    panic("fileclose");
    80004816:	00004517          	auipc	a0,0x4
    8000481a:	e7a50513          	addi	a0,a0,-390 # 80008690 <syscalls+0x298>
    8000481e:	f6bfb0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    80004822:	00246517          	auipc	a0,0x246
    80004826:	2a650513          	addi	a0,a0,678 # 8024aac8 <ftable>
    8000482a:	d0efc0ef          	jal	ra,80000d38 <release>
  }
}
    8000482e:	70e2                	ld	ra,56(sp)
    80004830:	7442                	ld	s0,48(sp)
    80004832:	74a2                	ld	s1,40(sp)
    80004834:	7902                	ld	s2,32(sp)
    80004836:	69e2                	ld	s3,24(sp)
    80004838:	6a42                	ld	s4,16(sp)
    8000483a:	6aa2                	ld	s5,8(sp)
    8000483c:	6121                	addi	sp,sp,64
    8000483e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004840:	85d6                	mv	a1,s5
    80004842:	8552                	mv	a0,s4
    80004844:	2ec000ef          	jal	ra,80004b30 <pipeclose>
    80004848:	b7dd                	j	8000482e <fileclose+0x8c>

000000008000484a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000484a:	715d                	addi	sp,sp,-80
    8000484c:	e486                	sd	ra,72(sp)
    8000484e:	e0a2                	sd	s0,64(sp)
    80004850:	fc26                	sd	s1,56(sp)
    80004852:	f84a                	sd	s2,48(sp)
    80004854:	f44e                	sd	s3,40(sp)
    80004856:	0880                	addi	s0,sp,80
    80004858:	84aa                	mv	s1,a0
    8000485a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000485c:	adcfd0ef          	jal	ra,80001b38 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004860:	409c                	lw	a5,0(s1)
    80004862:	37f9                	addiw	a5,a5,-2
    80004864:	4705                	li	a4,1
    80004866:	02f76f63          	bltu	a4,a5,800048a4 <filestat+0x5a>
    8000486a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000486c:	6c88                	ld	a0,24(s1)
    8000486e:	942ff0ef          	jal	ra,800039b0 <ilock>
    stati(f->ip, &st);
    80004872:	fb840593          	addi	a1,s0,-72
    80004876:	6c88                	ld	a0,24(s1)
    80004878:	c9aff0ef          	jal	ra,80003d12 <stati>
    iunlock(f->ip);
    8000487c:	6c88                	ld	a0,24(s1)
    8000487e:	9dcff0ef          	jal	ra,80003a5a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004882:	46e1                	li	a3,24
    80004884:	fb840613          	addi	a2,s0,-72
    80004888:	85ce                	mv	a1,s3
    8000488a:	05093503          	ld	a0,80(s2)
    8000488e:	eddfc0ef          	jal	ra,8000176a <copyout>
    80004892:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004896:	60a6                	ld	ra,72(sp)
    80004898:	6406                	ld	s0,64(sp)
    8000489a:	74e2                	ld	s1,56(sp)
    8000489c:	7942                	ld	s2,48(sp)
    8000489e:	79a2                	ld	s3,40(sp)
    800048a0:	6161                	addi	sp,sp,80
    800048a2:	8082                	ret
  return -1;
    800048a4:	557d                	li	a0,-1
    800048a6:	bfc5                	j	80004896 <filestat+0x4c>

00000000800048a8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048a8:	7179                	addi	sp,sp,-48
    800048aa:	f406                	sd	ra,40(sp)
    800048ac:	f022                	sd	s0,32(sp)
    800048ae:	ec26                	sd	s1,24(sp)
    800048b0:	e84a                	sd	s2,16(sp)
    800048b2:	e44e                	sd	s3,8(sp)
    800048b4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048b6:	00854783          	lbu	a5,8(a0)
    800048ba:	cbc1                	beqz	a5,8000494a <fileread+0xa2>
    800048bc:	84aa                	mv	s1,a0
    800048be:	89ae                	mv	s3,a1
    800048c0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048c2:	411c                	lw	a5,0(a0)
    800048c4:	4705                	li	a4,1
    800048c6:	04e78363          	beq	a5,a4,8000490c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048ca:	470d                	li	a4,3
    800048cc:	04e78563          	beq	a5,a4,80004916 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048d0:	4709                	li	a4,2
    800048d2:	06e79663          	bne	a5,a4,8000493e <fileread+0x96>
    ilock(f->ip);
    800048d6:	6d08                	ld	a0,24(a0)
    800048d8:	8d8ff0ef          	jal	ra,800039b0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048dc:	874a                	mv	a4,s2
    800048de:	5094                	lw	a3,32(s1)
    800048e0:	864e                	mv	a2,s3
    800048e2:	4585                	li	a1,1
    800048e4:	6c88                	ld	a0,24(s1)
    800048e6:	c56ff0ef          	jal	ra,80003d3c <readi>
    800048ea:	892a                	mv	s2,a0
    800048ec:	00a05563          	blez	a0,800048f6 <fileread+0x4e>
      f->off += r;
    800048f0:	509c                	lw	a5,32(s1)
    800048f2:	9fa9                	addw	a5,a5,a0
    800048f4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048f6:	6c88                	ld	a0,24(s1)
    800048f8:	962ff0ef          	jal	ra,80003a5a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048fc:	854a                	mv	a0,s2
    800048fe:	70a2                	ld	ra,40(sp)
    80004900:	7402                	ld	s0,32(sp)
    80004902:	64e2                	ld	s1,24(sp)
    80004904:	6942                	ld	s2,16(sp)
    80004906:	69a2                	ld	s3,8(sp)
    80004908:	6145                	addi	sp,sp,48
    8000490a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000490c:	6908                	ld	a0,16(a0)
    8000490e:	34e000ef          	jal	ra,80004c5c <piperead>
    80004912:	892a                	mv	s2,a0
    80004914:	b7e5                	j	800048fc <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004916:	02451783          	lh	a5,36(a0)
    8000491a:	03079693          	slli	a3,a5,0x30
    8000491e:	92c1                	srli	a3,a3,0x30
    80004920:	4725                	li	a4,9
    80004922:	02d76663          	bltu	a4,a3,8000494e <fileread+0xa6>
    80004926:	0792                	slli	a5,a5,0x4
    80004928:	00246717          	auipc	a4,0x246
    8000492c:	10070713          	addi	a4,a4,256 # 8024aa28 <devsw>
    80004930:	97ba                	add	a5,a5,a4
    80004932:	639c                	ld	a5,0(a5)
    80004934:	cf99                	beqz	a5,80004952 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004936:	4505                	li	a0,1
    80004938:	9782                	jalr	a5
    8000493a:	892a                	mv	s2,a0
    8000493c:	b7c1                	j	800048fc <fileread+0x54>
    panic("fileread");
    8000493e:	00004517          	auipc	a0,0x4
    80004942:	d6250513          	addi	a0,a0,-670 # 800086a0 <syscalls+0x2a8>
    80004946:	e43fb0ef          	jal	ra,80000788 <panic>
    return -1;
    8000494a:	597d                	li	s2,-1
    8000494c:	bf45                	j	800048fc <fileread+0x54>
      return -1;
    8000494e:	597d                	li	s2,-1
    80004950:	b775                	j	800048fc <fileread+0x54>
    80004952:	597d                	li	s2,-1
    80004954:	b765                	j	800048fc <fileread+0x54>

0000000080004956 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004956:	715d                	addi	sp,sp,-80
    80004958:	e486                	sd	ra,72(sp)
    8000495a:	e0a2                	sd	s0,64(sp)
    8000495c:	fc26                	sd	s1,56(sp)
    8000495e:	f84a                	sd	s2,48(sp)
    80004960:	f44e                	sd	s3,40(sp)
    80004962:	f052                	sd	s4,32(sp)
    80004964:	ec56                	sd	s5,24(sp)
    80004966:	e85a                	sd	s6,16(sp)
    80004968:	e45e                	sd	s7,8(sp)
    8000496a:	e062                	sd	s8,0(sp)
    8000496c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000496e:	00954783          	lbu	a5,9(a0)
    80004972:	0e078863          	beqz	a5,80004a62 <filewrite+0x10c>
    80004976:	892a                	mv	s2,a0
    80004978:	8b2e                	mv	s6,a1
    8000497a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000497c:	411c                	lw	a5,0(a0)
    8000497e:	4705                	li	a4,1
    80004980:	02e78263          	beq	a5,a4,800049a4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004984:	470d                	li	a4,3
    80004986:	02e78463          	beq	a5,a4,800049ae <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000498a:	4709                	li	a4,2
    8000498c:	0ce79563          	bne	a5,a4,80004a56 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004990:	0ac05163          	blez	a2,80004a32 <filewrite+0xdc>
    int i = 0;
    80004994:	4981                	li	s3,0
    80004996:	6b85                	lui	s7,0x1
    80004998:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000499c:	6c05                	lui	s8,0x1
    8000499e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049a2:	a041                	j	80004a22 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800049a4:	6908                	ld	a0,16(a0)
    800049a6:	1e2000ef          	jal	ra,80004b88 <pipewrite>
    800049aa:	8a2a                	mv	s4,a0
    800049ac:	a071                	j	80004a38 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049ae:	02451783          	lh	a5,36(a0)
    800049b2:	03079693          	slli	a3,a5,0x30
    800049b6:	92c1                	srli	a3,a3,0x30
    800049b8:	4725                	li	a4,9
    800049ba:	0ad76663          	bltu	a4,a3,80004a66 <filewrite+0x110>
    800049be:	0792                	slli	a5,a5,0x4
    800049c0:	00246717          	auipc	a4,0x246
    800049c4:	06870713          	addi	a4,a4,104 # 8024aa28 <devsw>
    800049c8:	97ba                	add	a5,a5,a4
    800049ca:	679c                	ld	a5,8(a5)
    800049cc:	cfd9                	beqz	a5,80004a6a <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800049ce:	4505                	li	a0,1
    800049d0:	9782                	jalr	a5
    800049d2:	8a2a                	mv	s4,a0
    800049d4:	a095                	j	80004a38 <filewrite+0xe2>
    800049d6:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049da:	9bfff0ef          	jal	ra,80004398 <begin_op>
      ilock(f->ip);
    800049de:	01893503          	ld	a0,24(s2)
    800049e2:	fcffe0ef          	jal	ra,800039b0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049e6:	8756                	mv	a4,s5
    800049e8:	02092683          	lw	a3,32(s2)
    800049ec:	01698633          	add	a2,s3,s6
    800049f0:	4585                	li	a1,1
    800049f2:	01893503          	ld	a0,24(s2)
    800049f6:	c2aff0ef          	jal	ra,80003e20 <writei>
    800049fa:	84aa                	mv	s1,a0
    800049fc:	00a05763          	blez	a0,80004a0a <filewrite+0xb4>
        f->off += r;
    80004a00:	02092783          	lw	a5,32(s2)
    80004a04:	9fa9                	addw	a5,a5,a0
    80004a06:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a0a:	01893503          	ld	a0,24(s2)
    80004a0e:	84cff0ef          	jal	ra,80003a5a <iunlock>
      end_op();
    80004a12:	9f5ff0ef          	jal	ra,80004406 <end_op>

      if(r != n1){
    80004a16:	009a9f63          	bne	s5,s1,80004a34 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004a1a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a1e:	0149db63          	bge	s3,s4,80004a34 <filewrite+0xde>
      int n1 = n - i;
    80004a22:	413a04bb          	subw	s1,s4,s3
    80004a26:	0004879b          	sext.w	a5,s1
    80004a2a:	fafbd6e3          	bge	s7,a5,800049d6 <filewrite+0x80>
    80004a2e:	84e2                	mv	s1,s8
    80004a30:	b75d                	j	800049d6 <filewrite+0x80>
    int i = 0;
    80004a32:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a34:	013a1f63          	bne	s4,s3,80004a52 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a38:	8552                	mv	a0,s4
    80004a3a:	60a6                	ld	ra,72(sp)
    80004a3c:	6406                	ld	s0,64(sp)
    80004a3e:	74e2                	ld	s1,56(sp)
    80004a40:	7942                	ld	s2,48(sp)
    80004a42:	79a2                	ld	s3,40(sp)
    80004a44:	7a02                	ld	s4,32(sp)
    80004a46:	6ae2                	ld	s5,24(sp)
    80004a48:	6b42                	ld	s6,16(sp)
    80004a4a:	6ba2                	ld	s7,8(sp)
    80004a4c:	6c02                	ld	s8,0(sp)
    80004a4e:	6161                	addi	sp,sp,80
    80004a50:	8082                	ret
    ret = (i == n ? n : -1);
    80004a52:	5a7d                	li	s4,-1
    80004a54:	b7d5                	j	80004a38 <filewrite+0xe2>
    panic("filewrite");
    80004a56:	00004517          	auipc	a0,0x4
    80004a5a:	c5a50513          	addi	a0,a0,-934 # 800086b0 <syscalls+0x2b8>
    80004a5e:	d2bfb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004a62:	5a7d                	li	s4,-1
    80004a64:	bfd1                	j	80004a38 <filewrite+0xe2>
      return -1;
    80004a66:	5a7d                	li	s4,-1
    80004a68:	bfc1                	j	80004a38 <filewrite+0xe2>
    80004a6a:	5a7d                	li	s4,-1
    80004a6c:	b7f1                	j	80004a38 <filewrite+0xe2>

0000000080004a6e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a6e:	7179                	addi	sp,sp,-48
    80004a70:	f406                	sd	ra,40(sp)
    80004a72:	f022                	sd	s0,32(sp)
    80004a74:	ec26                	sd	s1,24(sp)
    80004a76:	e84a                	sd	s2,16(sp)
    80004a78:	e44e                	sd	s3,8(sp)
    80004a7a:	e052                	sd	s4,0(sp)
    80004a7c:	1800                	addi	s0,sp,48
    80004a7e:	84aa                	mv	s1,a0
    80004a80:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a82:	0005b023          	sd	zero,0(a1)
    80004a86:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a8a:	c75ff0ef          	jal	ra,800046fe <filealloc>
    80004a8e:	e088                	sd	a0,0(s1)
    80004a90:	cd35                	beqz	a0,80004b0c <pipealloc+0x9e>
    80004a92:	c6dff0ef          	jal	ra,800046fe <filealloc>
    80004a96:	00aa3023          	sd	a0,0(s4)
    80004a9a:	c52d                	beqz	a0,80004b04 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a9c:	90efc0ef          	jal	ra,80000baa <kalloc>
    80004aa0:	892a                	mv	s2,a0
    80004aa2:	cd31                	beqz	a0,80004afe <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004aa4:	4985                	li	s3,1
    80004aa6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004aaa:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004aae:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ab2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ab6:	00004597          	auipc	a1,0x4
    80004aba:	c0a58593          	addi	a1,a1,-1014 # 800086c0 <syscalls+0x2c8>
    80004abe:	962fc0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    80004ac2:	609c                	ld	a5,0(s1)
    80004ac4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ac8:	609c                	ld	a5,0(s1)
    80004aca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ace:	609c                	ld	a5,0(s1)
    80004ad0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ad4:	609c                	ld	a5,0(s1)
    80004ad6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ada:	000a3783          	ld	a5,0(s4)
    80004ade:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ae2:	000a3783          	ld	a5,0(s4)
    80004ae6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004aea:	000a3783          	ld	a5,0(s4)
    80004aee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004af2:	000a3783          	ld	a5,0(s4)
    80004af6:	0127b823          	sd	s2,16(a5)
  return 0;
    80004afa:	4501                	li	a0,0
    80004afc:	a005                	j	80004b1c <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004afe:	6088                	ld	a0,0(s1)
    80004b00:	e501                	bnez	a0,80004b08 <pipealloc+0x9a>
    80004b02:	a029                	j	80004b0c <pipealloc+0x9e>
    80004b04:	6088                	ld	a0,0(s1)
    80004b06:	c11d                	beqz	a0,80004b2c <pipealloc+0xbe>
    fileclose(*f0);
    80004b08:	c9bff0ef          	jal	ra,800047a2 <fileclose>
  if(*f1)
    80004b0c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b10:	557d                	li	a0,-1
  if(*f1)
    80004b12:	c789                	beqz	a5,80004b1c <pipealloc+0xae>
    fileclose(*f1);
    80004b14:	853e                	mv	a0,a5
    80004b16:	c8dff0ef          	jal	ra,800047a2 <fileclose>
  return -1;
    80004b1a:	557d                	li	a0,-1
}
    80004b1c:	70a2                	ld	ra,40(sp)
    80004b1e:	7402                	ld	s0,32(sp)
    80004b20:	64e2                	ld	s1,24(sp)
    80004b22:	6942                	ld	s2,16(sp)
    80004b24:	69a2                	ld	s3,8(sp)
    80004b26:	6a02                	ld	s4,0(sp)
    80004b28:	6145                	addi	sp,sp,48
    80004b2a:	8082                	ret
  return -1;
    80004b2c:	557d                	li	a0,-1
    80004b2e:	b7fd                	j	80004b1c <pipealloc+0xae>

0000000080004b30 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b30:	1101                	addi	sp,sp,-32
    80004b32:	ec06                	sd	ra,24(sp)
    80004b34:	e822                	sd	s0,16(sp)
    80004b36:	e426                	sd	s1,8(sp)
    80004b38:	e04a                	sd	s2,0(sp)
    80004b3a:	1000                	addi	s0,sp,32
    80004b3c:	84aa                	mv	s1,a0
    80004b3e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b40:	960fc0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    80004b44:	02090763          	beqz	s2,80004b72 <pipeclose+0x42>
    pi->writeopen = 0;
    80004b48:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b4c:	21848513          	addi	a0,s1,536
    80004b50:	ebefd0ef          	jal	ra,8000220e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b54:	2204b783          	ld	a5,544(s1)
    80004b58:	e785                	bnez	a5,80004b80 <pipeclose+0x50>
    release(&pi->lock);
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	9dcfc0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    80004b60:	8526                	mv	a0,s1
    80004b62:	f19fb0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80004b66:	60e2                	ld	ra,24(sp)
    80004b68:	6442                	ld	s0,16(sp)
    80004b6a:	64a2                	ld	s1,8(sp)
    80004b6c:	6902                	ld	s2,0(sp)
    80004b6e:	6105                	addi	sp,sp,32
    80004b70:	8082                	ret
    pi->readopen = 0;
    80004b72:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b76:	21c48513          	addi	a0,s1,540
    80004b7a:	e94fd0ef          	jal	ra,8000220e <wakeup>
    80004b7e:	bfd9                	j	80004b54 <pipeclose+0x24>
    release(&pi->lock);
    80004b80:	8526                	mv	a0,s1
    80004b82:	9b6fc0ef          	jal	ra,80000d38 <release>
}
    80004b86:	b7c5                	j	80004b66 <pipeclose+0x36>

0000000080004b88 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b88:	711d                	addi	sp,sp,-96
    80004b8a:	ec86                	sd	ra,88(sp)
    80004b8c:	e8a2                	sd	s0,80(sp)
    80004b8e:	e4a6                	sd	s1,72(sp)
    80004b90:	e0ca                	sd	s2,64(sp)
    80004b92:	fc4e                	sd	s3,56(sp)
    80004b94:	f852                	sd	s4,48(sp)
    80004b96:	f456                	sd	s5,40(sp)
    80004b98:	f05a                	sd	s6,32(sp)
    80004b9a:	ec5e                	sd	s7,24(sp)
    80004b9c:	e862                	sd	s8,16(sp)
    80004b9e:	1080                	addi	s0,sp,96
    80004ba0:	84aa                	mv	s1,a0
    80004ba2:	8aae                	mv	s5,a1
    80004ba4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ba6:	f93fc0ef          	jal	ra,80001b38 <myproc>
    80004baa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004bac:	8526                	mv	a0,s1
    80004bae:	8f2fc0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    80004bb2:	09405c63          	blez	s4,80004c4a <pipewrite+0xc2>
  int i = 0;
    80004bb6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bb8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004bba:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004bbe:	21c48b93          	addi	s7,s1,540
    80004bc2:	a81d                	j	80004bf8 <pipewrite+0x70>
      release(&pi->lock);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	972fc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004bca:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bcc:	854a                	mv	a0,s2
    80004bce:	60e6                	ld	ra,88(sp)
    80004bd0:	6446                	ld	s0,80(sp)
    80004bd2:	64a6                	ld	s1,72(sp)
    80004bd4:	6906                	ld	s2,64(sp)
    80004bd6:	79e2                	ld	s3,56(sp)
    80004bd8:	7a42                	ld	s4,48(sp)
    80004bda:	7aa2                	ld	s5,40(sp)
    80004bdc:	7b02                	ld	s6,32(sp)
    80004bde:	6be2                	ld	s7,24(sp)
    80004be0:	6c42                	ld	s8,16(sp)
    80004be2:	6125                	addi	sp,sp,96
    80004be4:	8082                	ret
      wakeup(&pi->nread);
    80004be6:	8562                	mv	a0,s8
    80004be8:	e26fd0ef          	jal	ra,8000220e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bec:	85a6                	mv	a1,s1
    80004bee:	855e                	mv	a0,s7
    80004bf0:	dd2fd0ef          	jal	ra,800021c2 <sleep>
  while(i < n){
    80004bf4:	05495c63          	bge	s2,s4,80004c4c <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004bf8:	2204a783          	lw	a5,544(s1)
    80004bfc:	d7e1                	beqz	a5,80004bc4 <pipewrite+0x3c>
    80004bfe:	854e                	mv	a0,s3
    80004c00:	ffafd0ef          	jal	ra,800023fa <killed>
    80004c04:	f161                	bnez	a0,80004bc4 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c06:	2184a783          	lw	a5,536(s1)
    80004c0a:	21c4a703          	lw	a4,540(s1)
    80004c0e:	2007879b          	addiw	a5,a5,512
    80004c12:	fcf70ae3          	beq	a4,a5,80004be6 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c16:	4685                	li	a3,1
    80004c18:	01590633          	add	a2,s2,s5
    80004c1c:	faf40593          	addi	a1,s0,-81
    80004c20:	0509b503          	ld	a0,80(s3)
    80004c24:	c31fc0ef          	jal	ra,80001854 <copyin>
    80004c28:	03650263          	beq	a0,s6,80004c4c <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c2c:	21c4a783          	lw	a5,540(s1)
    80004c30:	0017871b          	addiw	a4,a5,1
    80004c34:	20e4ae23          	sw	a4,540(s1)
    80004c38:	1ff7f793          	andi	a5,a5,511
    80004c3c:	97a6                	add	a5,a5,s1
    80004c3e:	faf44703          	lbu	a4,-81(s0)
    80004c42:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c46:	2905                	addiw	s2,s2,1
    80004c48:	b775                	j	80004bf4 <pipewrite+0x6c>
  int i = 0;
    80004c4a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004c4c:	21848513          	addi	a0,s1,536
    80004c50:	dbefd0ef          	jal	ra,8000220e <wakeup>
  release(&pi->lock);
    80004c54:	8526                	mv	a0,s1
    80004c56:	8e2fc0ef          	jal	ra,80000d38 <release>
  return i;
    80004c5a:	bf8d                	j	80004bcc <pipewrite+0x44>

0000000080004c5c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c5c:	715d                	addi	sp,sp,-80
    80004c5e:	e486                	sd	ra,72(sp)
    80004c60:	e0a2                	sd	s0,64(sp)
    80004c62:	fc26                	sd	s1,56(sp)
    80004c64:	f84a                	sd	s2,48(sp)
    80004c66:	f44e                	sd	s3,40(sp)
    80004c68:	f052                	sd	s4,32(sp)
    80004c6a:	ec56                	sd	s5,24(sp)
    80004c6c:	e85a                	sd	s6,16(sp)
    80004c6e:	0880                	addi	s0,sp,80
    80004c70:	84aa                	mv	s1,a0
    80004c72:	892e                	mv	s2,a1
    80004c74:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c76:	ec3fc0ef          	jal	ra,80001b38 <myproc>
    80004c7a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c7c:	8526                	mv	a0,s1
    80004c7e:	822fc0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c82:	2184a703          	lw	a4,536(s1)
    80004c86:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c8a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c8e:	02f71363          	bne	a4,a5,80004cb4 <piperead+0x58>
    80004c92:	2244a783          	lw	a5,548(s1)
    80004c96:	cf99                	beqz	a5,80004cb4 <piperead+0x58>
    if(killed(pr)){
    80004c98:	8552                	mv	a0,s4
    80004c9a:	f60fd0ef          	jal	ra,800023fa <killed>
    80004c9e:	e151                	bnez	a0,80004d22 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ca0:	85a6                	mv	a1,s1
    80004ca2:	854e                	mv	a0,s3
    80004ca4:	d1efd0ef          	jal	ra,800021c2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ca8:	2184a703          	lw	a4,536(s1)
    80004cac:	21c4a783          	lw	a5,540(s1)
    80004cb0:	fef701e3          	beq	a4,a5,80004c92 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cb4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004cb6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cb8:	05505363          	blez	s5,80004cfe <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    80004cbc:	2184a783          	lw	a5,536(s1)
    80004cc0:	21c4a703          	lw	a4,540(s1)
    80004cc4:	02f70d63          	beq	a4,a5,80004cfe <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004cc8:	1ff7f793          	andi	a5,a5,511
    80004ccc:	97a6                	add	a5,a5,s1
    80004cce:	0187c783          	lbu	a5,24(a5)
    80004cd2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004cd6:	4685                	li	a3,1
    80004cd8:	fbf40613          	addi	a2,s0,-65
    80004cdc:	85ca                	mv	a1,s2
    80004cde:	050a3503          	ld	a0,80(s4)
    80004ce2:	a89fc0ef          	jal	ra,8000176a <copyout>
    80004ce6:	05650363          	beq	a0,s6,80004d2c <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004cea:	2184a783          	lw	a5,536(s1)
    80004cee:	2785                	addiw	a5,a5,1
    80004cf0:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cf4:	2985                	addiw	s3,s3,1
    80004cf6:	0905                	addi	s2,s2,1
    80004cf8:	fd3a92e3          	bne	s5,s3,80004cbc <piperead+0x60>
    80004cfc:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cfe:	21c48513          	addi	a0,s1,540
    80004d02:	d0cfd0ef          	jal	ra,8000220e <wakeup>
  release(&pi->lock);
    80004d06:	8526                	mv	a0,s1
    80004d08:	830fc0ef          	jal	ra,80000d38 <release>
  return i;
}
    80004d0c:	854e                	mv	a0,s3
    80004d0e:	60a6                	ld	ra,72(sp)
    80004d10:	6406                	ld	s0,64(sp)
    80004d12:	74e2                	ld	s1,56(sp)
    80004d14:	7942                	ld	s2,48(sp)
    80004d16:	79a2                	ld	s3,40(sp)
    80004d18:	7a02                	ld	s4,32(sp)
    80004d1a:	6ae2                	ld	s5,24(sp)
    80004d1c:	6b42                	ld	s6,16(sp)
    80004d1e:	6161                	addi	sp,sp,80
    80004d20:	8082                	ret
      release(&pi->lock);
    80004d22:	8526                	mv	a0,s1
    80004d24:	814fc0ef          	jal	ra,80000d38 <release>
      return -1;
    80004d28:	59fd                	li	s3,-1
    80004d2a:	b7cd                	j	80004d0c <piperead+0xb0>
      if(i == 0)
    80004d2c:	fc0999e3          	bnez	s3,80004cfe <piperead+0xa2>
        i = -1;
    80004d30:	89aa                	mv	s3,a0
    80004d32:	b7f1                	j	80004cfe <piperead+0xa2>

0000000080004d34 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004d34:	1141                	addi	sp,sp,-16
    80004d36:	e422                	sd	s0,8(sp)
    80004d38:	0800                	addi	s0,sp,16
    80004d3a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004d3c:	8905                	andi	a0,a0,1
    80004d3e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004d40:	8b89                	andi	a5,a5,2
    80004d42:	c399                	beqz	a5,80004d48 <flags2perm+0x14>
      perm |= PTE_W;
    80004d44:	00456513          	ori	a0,a0,4
    return perm;
}
    80004d48:	6422                	ld	s0,8(sp)
    80004d4a:	0141                	addi	sp,sp,16
    80004d4c:	8082                	ret

0000000080004d4e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004d4e:	b5010113          	addi	sp,sp,-1200
    80004d52:	4a113423          	sd	ra,1192(sp)
    80004d56:	4a813023          	sd	s0,1184(sp)
    80004d5a:	48913c23          	sd	s1,1176(sp)
    80004d5e:	49213823          	sd	s2,1168(sp)
    80004d62:	49313423          	sd	s3,1160(sp)
    80004d66:	49413023          	sd	s4,1152(sp)
    80004d6a:	47513c23          	sd	s5,1144(sp)
    80004d6e:	47613823          	sd	s6,1136(sp)
    80004d72:	47713423          	sd	s7,1128(sp)
    80004d76:	47813023          	sd	s8,1120(sp)
    80004d7a:	45913c23          	sd	s9,1112(sp)
    80004d7e:	45a13823          	sd	s10,1104(sp)
    80004d82:	45b13423          	sd	s11,1096(sp)
    80004d86:	4b010413          	addi	s0,sp,1200
    80004d8a:	84aa                	mv	s1,a0
    80004d8c:	b6a43023          	sd	a0,-1184(s0)
    80004d90:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d94:	da5fc0ef          	jal	ra,80001b38 <myproc>
    80004d98:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    80004d9c:	dfcff0ef          	jal	ra,80004398 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004da0:	8526                	mv	a0,s1
    80004da2:	c02ff0ef          	jal	ra,800041a4 <namei>
    80004da6:	cd25                	beqz	a0,80004e1e <kexec+0xd0>
    80004da8:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004daa:	c07fe0ef          	jal	ra,800039b0 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dae:	04000713          	li	a4,64
    80004db2:	4681                	li	a3,0
    80004db4:	e5040613          	addi	a2,s0,-432
    80004db8:	4581                	li	a1,0
    80004dba:	8556                	mv	a0,s5
    80004dbc:	f81fe0ef          	jal	ra,80003d3c <readi>
    80004dc0:	04000793          	li	a5,64
    80004dc4:	00f51a63          	bne	a0,a5,80004dd8 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004dc8:	e5042703          	lw	a4,-432(s0)
    80004dcc:	464c47b7          	lui	a5,0x464c4
    80004dd0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004dd4:	04f70963          	beq	a4,a5,80004e26 <kexec+0xd8>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    memset(p->vmas, 0, sizeof(p->vmas));
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    80004dd8:	8556                	mv	a0,s5
    80004dda:	dddfe0ef          	jal	ra,80003bb6 <iunlockput>
    end_op();
    80004dde:	e28ff0ef          	jal	ra,80004406 <end_op>
  }
  return -1;
    80004de2:	557d                	li	a0,-1
}
    80004de4:	4a813083          	ld	ra,1192(sp)
    80004de8:	4a013403          	ld	s0,1184(sp)
    80004dec:	49813483          	ld	s1,1176(sp)
    80004df0:	49013903          	ld	s2,1168(sp)
    80004df4:	48813983          	ld	s3,1160(sp)
    80004df8:	48013a03          	ld	s4,1152(sp)
    80004dfc:	47813a83          	ld	s5,1144(sp)
    80004e00:	47013b03          	ld	s6,1136(sp)
    80004e04:	46813b83          	ld	s7,1128(sp)
    80004e08:	46013c03          	ld	s8,1120(sp)
    80004e0c:	45813c83          	ld	s9,1112(sp)
    80004e10:	45013d03          	ld	s10,1104(sp)
    80004e14:	44813d83          	ld	s11,1096(sp)
    80004e18:	4b010113          	addi	sp,sp,1200
    80004e1c:	8082                	ret
    end_op();
    80004e1e:	de8ff0ef          	jal	ra,80004406 <end_op>
    return -1;
    80004e22:	557d                	li	a0,-1
    80004e24:	b7c1                	j	80004de4 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e26:	b7843503          	ld	a0,-1160(s0)
    80004e2a:	e15fc0ef          	jal	ra,80001c3e <proc_pagetable>
    80004e2e:	8baa                	mv	s7,a0
    80004e30:	d545                	beqz	a0,80004dd8 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e32:	e7042783          	lw	a5,-400(s0)
    80004e36:	e8845703          	lhu	a4,-376(s0)
    80004e3a:	0e070d63          	beqz	a4,80004f34 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e3e:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e42:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004e46:	6a05                	lui	s4,0x1
    80004e48:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004e4c:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004e50:	6d85                	lui	s11,0x1
    80004e52:	7d7d                	lui	s10,0xfffff
    80004e54:	a09d                	j	80004eba <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e56:	00004517          	auipc	a0,0x4
    80004e5a:	87250513          	addi	a0,a0,-1934 # 800086c8 <syscalls+0x2d0>
    80004e5e:	92bfb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e62:	874a                	mv	a4,s2
    80004e64:	009c86bb          	addw	a3,s9,s1
    80004e68:	4581                	li	a1,0
    80004e6a:	8556                	mv	a0,s5
    80004e6c:	ed1fe0ef          	jal	ra,80003d3c <readi>
    80004e70:	2501                	sext.w	a0,a0
    80004e72:	0ea91f63          	bne	s2,a0,80004f70 <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    80004e76:	009d84bb          	addw	s1,s11,s1
    80004e7a:	013d09bb          	addw	s3,s10,s3
    80004e7e:	0364f063          	bgeu	s1,s6,80004e9e <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004e82:	02049593          	slli	a1,s1,0x20
    80004e86:	9181                	srli	a1,a1,0x20
    80004e88:	95e2                	add	a1,a1,s8
    80004e8a:	855e                	mv	a0,s7
    80004e8c:	9fefc0ef          	jal	ra,8000108a <walkaddr>
    80004e90:	862a                	mv	a2,a0
    if(pa == 0)
    80004e92:	d171                	beqz	a0,80004e56 <kexec+0x108>
      n = PGSIZE;
    80004e94:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004e96:	fd49f6e3          	bgeu	s3,s4,80004e62 <kexec+0x114>
      n = sz - i;
    80004e9a:	894e                	mv	s2,s3
    80004e9c:	b7d9                	j	80004e62 <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e9e:	b8843783          	ld	a5,-1144(s0)
    80004ea2:	0017869b          	addiw	a3,a5,1
    80004ea6:	b8d43423          	sd	a3,-1144(s0)
    80004eaa:	b8043783          	ld	a5,-1152(s0)
    80004eae:	0387879b          	addiw	a5,a5,56
    80004eb2:	e8845703          	lhu	a4,-376(s0)
    80004eb6:	08e6d163          	bge	a3,a4,80004f38 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004eba:	2781                	sext.w	a5,a5
    80004ebc:	b8f43023          	sd	a5,-1152(s0)
    80004ec0:	03800713          	li	a4,56
    80004ec4:	86be                	mv	a3,a5
    80004ec6:	e1840613          	addi	a2,s0,-488
    80004eca:	4581                	li	a1,0
    80004ecc:	8556                	mv	a0,s5
    80004ece:	e6ffe0ef          	jal	ra,80003d3c <readi>
    80004ed2:	03800793          	li	a5,56
    80004ed6:	08f51d63          	bne	a0,a5,80004f70 <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    80004eda:	e1842783          	lw	a5,-488(s0)
    80004ede:	4705                	li	a4,1
    80004ee0:	fae79fe3          	bne	a5,a4,80004e9e <kexec+0x150>
    if(ph.memsz < ph.filesz)
    80004ee4:	e4043483          	ld	s1,-448(s0)
    80004ee8:	e3843783          	ld	a5,-456(s0)
    80004eec:	08f4e263          	bltu	s1,a5,80004f70 <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ef0:	e2843783          	ld	a5,-472(s0)
    80004ef4:	94be                	add	s1,s1,a5
    80004ef6:	06f4ed63          	bltu	s1,a5,80004f70 <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    80004efa:	b5843703          	ld	a4,-1192(s0)
    80004efe:	8ff9                	and	a5,a5,a4
    80004f00:	eba5                	bnez	a5,80004f70 <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f02:	e1c42503          	lw	a0,-484(s0)
    80004f06:	e2fff0ef          	jal	ra,80004d34 <flags2perm>
    80004f0a:	86aa                	mv	a3,a0
    80004f0c:	8626                	mv	a2,s1
    80004f0e:	b7043583          	ld	a1,-1168(s0)
    80004f12:	855e                	mv	a0,s7
    80004f14:	c40fc0ef          	jal	ra,80001354 <uvmalloc>
    80004f18:	b6a43823          	sd	a0,-1168(s0)
    80004f1c:	c931                	beqz	a0,80004f70 <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f1e:	e2843c03          	ld	s8,-472(s0)
    80004f22:	e2042c83          	lw	s9,-480(s0)
    80004f26:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f2a:	f60b0ae3          	beqz	s6,80004e9e <kexec+0x150>
    80004f2e:	89da                	mv	s3,s6
    80004f30:	4481                	li	s1,0
    80004f32:	bf81                	j	80004e82 <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f34:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    80004f38:	8556                	mv	a0,s5
    80004f3a:	c7dfe0ef          	jal	ra,80003bb6 <iunlockput>
  end_op();
    80004f3e:	cc8ff0ef          	jal	ra,80004406 <end_op>
  p = myproc();
    80004f42:	bf7fc0ef          	jal	ra,80001b38 <myproc>
    80004f46:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    80004f4a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004f4e:	6785                	lui	a5,0x1
    80004f50:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004f52:	b7043703          	ld	a4,-1168(s0)
    80004f56:	00f705b3          	add	a1,a4,a5
    80004f5a:	77fd                	lui	a5,0xfffff
    80004f5c:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004f5e:	4691                	li	a3,4
    80004f60:	6609                	lui	a2,0x2
    80004f62:	962e                	add	a2,a2,a1
    80004f64:	855e                	mv	a0,s7
    80004f66:	beefc0ef          	jal	ra,80001354 <uvmalloc>
    80004f6a:	8b2a                	mv	s6,a0
  ip = 0;
    80004f6c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004f6e:	e915                	bnez	a0,80004fa2 <kexec+0x254>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80004f70:	b7843903          	ld	s2,-1160(s0)
    80004f74:	16890493          	addi	s1,s2,360
    80004f78:	85a6                	mv	a1,s1
    80004f7a:	05093503          	ld	a0,80(s2)
    80004f7e:	d45fc0ef          	jal	ra,80001cc2 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80004f82:	28000613          	li	a2,640
    80004f86:	4581                	li	a1,0
    80004f88:	8526                	mv	a0,s1
    80004f8a:	debfb0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80004f8e:	04893583          	ld	a1,72(s2)
    80004f92:	05093503          	ld	a0,80(s2)
    80004f96:	d77fc0ef          	jal	ra,80001d0c <proc_freepagetable>
  if(ip){
    80004f9a:	e20a9fe3          	bnez	s5,80004dd8 <kexec+0x8a>
  return -1;
    80004f9e:	557d                	li	a0,-1
    80004fa0:	b591                	j	80004de4 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004fa2:	75f9                	lui	a1,0xffffe
    80004fa4:	95aa                	add	a1,a1,a0
    80004fa6:	855e                	mv	a0,s7
    80004fa8:	e5afc0ef          	jal	ra,80001602 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004fac:	7c7d                	lui	s8,0xfffff
    80004fae:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fb0:	b6843783          	ld	a5,-1176(s0)
    80004fb4:	6388                	ld	a0,0(a5)
    80004fb6:	c125                	beqz	a0,80005016 <kexec+0x2c8>
    80004fb8:	e9040993          	addi	s3,s0,-368
    80004fbc:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    80004fc0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fc2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fc4:	f29fb0ef          	jal	ra,80000eec <strlen>
    80004fc8:	0015079b          	addiw	a5,a0,1
    80004fcc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fd0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004fd4:	11896563          	bltu	s2,s8,800050de <kexec+0x390>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fd8:	b6843d03          	ld	s10,-1176(s0)
    80004fdc:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdab2a8>
    80004fe0:	8552                	mv	a0,s4
    80004fe2:	f0bfb0ef          	jal	ra,80000eec <strlen>
    80004fe6:	0015069b          	addiw	a3,a0,1
    80004fea:	8652                	mv	a2,s4
    80004fec:	85ca                	mv	a1,s2
    80004fee:	855e                	mv	a0,s7
    80004ff0:	f7afc0ef          	jal	ra,8000176a <copyout>
    80004ff4:	0e054763          	bltz	a0,800050e2 <kexec+0x394>
    ustack[argc] = sp;
    80004ff8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ffc:	0485                	addi	s1,s1,1
    80004ffe:	008d0793          	addi	a5,s10,8
    80005002:	b6f43423          	sd	a5,-1176(s0)
    80005006:	008d3503          	ld	a0,8(s10)
    8000500a:	c901                	beqz	a0,8000501a <kexec+0x2cc>
    if(argc >= MAXARG)
    8000500c:	09a1                	addi	s3,s3,8
    8000500e:	fb599be3          	bne	s3,s5,80004fc4 <kexec+0x276>
  ip = 0;
    80005012:	4a81                	li	s5,0
    80005014:	bfb1                	j	80004f70 <kexec+0x222>
  sp = sz;
    80005016:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005018:	4481                	li	s1,0
  ustack[argc] = 0;
    8000501a:	00349793          	slli	a5,s1,0x3
    8000501e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdab238>
    80005022:	97a2                	add	a5,a5,s0
    80005024:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005028:	00148693          	addi	a3,s1,1
    8000502c:	068e                	slli	a3,a3,0x3
    8000502e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005032:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005036:	4a81                	li	s5,0
  if(sp < stackbase)
    80005038:	f3896ce3          	bltu	s2,s8,80004f70 <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000503c:	e9040613          	addi	a2,s0,-368
    80005040:	85ca                	mv	a1,s2
    80005042:	855e                	mv	a0,s7
    80005044:	f26fc0ef          	jal	ra,8000176a <copyout>
    80005048:	08054f63          	bltz	a0,800050e6 <kexec+0x398>
  p->trapframe->a1 = sp;
    8000504c:	b7843783          	ld	a5,-1160(s0)
    80005050:	6fbc                	ld	a5,88(a5)
    80005052:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005056:	b6043783          	ld	a5,-1184(s0)
    8000505a:	0007c703          	lbu	a4,0(a5)
    8000505e:	cf11                	beqz	a4,8000507a <kexec+0x32c>
    80005060:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005062:	02f00693          	li	a3,47
    80005066:	a039                	j	80005074 <kexec+0x326>
      last = s+1;
    80005068:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    8000506c:	0785                	addi	a5,a5,1
    8000506e:	fff7c703          	lbu	a4,-1(a5)
    80005072:	c701                	beqz	a4,8000507a <kexec+0x32c>
    if(*s == '/')
    80005074:	fed71ce3          	bne	a4,a3,8000506c <kexec+0x31e>
    80005078:	bfc5                	j	80005068 <kexec+0x31a>
  safestrcpy(p->name, last, sizeof(p->name));
    8000507a:	4641                	li	a2,16
    8000507c:	b6043583          	ld	a1,-1184(s0)
    80005080:	b7843983          	ld	s3,-1160(s0)
    80005084:	15898513          	addi	a0,s3,344
    80005088:	e33fb0ef          	jal	ra,80000eba <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    8000508c:	16898a13          	addi	s4,s3,360
    80005090:	28000613          	li	a2,640
    80005094:	85d2                	mv	a1,s4
    80005096:	b9840513          	addi	a0,s0,-1128
    8000509a:	d37fb0ef          	jal	ra,80000dd0 <memmove>
  oldpagetable = p->pagetable;
    8000509e:	86ce                	mv	a3,s3
    800050a0:	0509b983          	ld	s3,80(s3)
  p->pagetable = pagetable;
    800050a4:	0576b823          	sd	s7,80(a3)
  p->sz = sz;
    800050a8:	0566b423          	sd	s6,72(a3)
  p->trapframe->epc = elf.entry;
    800050ac:	6ebc                	ld	a5,88(a3)
    800050ae:	e6843703          	ld	a4,-408(s0)
    800050b2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    800050b4:	6ebc                	ld	a5,88(a3)
    800050b6:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    800050ba:	28000613          	li	a2,640
    800050be:	4581                	li	a1,0
    800050c0:	8552                	mv	a0,s4
    800050c2:	cb3fb0ef          	jal	ra,80000d74 <memset>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    800050c6:	b9840593          	addi	a1,s0,-1128
    800050ca:	854e                	mv	a0,s3
    800050cc:	bf7fc0ef          	jal	ra,80001cc2 <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    800050d0:	85e6                	mv	a1,s9
    800050d2:	854e                	mv	a0,s3
    800050d4:	c39fc0ef          	jal	ra,80001d0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050d8:	0004851b          	sext.w	a0,s1
    800050dc:	b321                	j	80004de4 <kexec+0x96>
  ip = 0;
    800050de:	4a81                	li	s5,0
    800050e0:	bd41                	j	80004f70 <kexec+0x222>
    800050e2:	4a81                	li	s5,0
    800050e4:	b571                	j	80004f70 <kexec+0x222>
    800050e6:	4a81                	li	s5,0
    800050e8:	b561                	j	80004f70 <kexec+0x222>

00000000800050ea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050ea:	7179                	addi	sp,sp,-48
    800050ec:	f406                	sd	ra,40(sp)
    800050ee:	f022                	sd	s0,32(sp)
    800050f0:	ec26                	sd	s1,24(sp)
    800050f2:	e84a                	sd	s2,16(sp)
    800050f4:	1800                	addi	s0,sp,48
    800050f6:	892e                	mv	s2,a1
    800050f8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800050fa:	fdc40593          	addi	a1,s0,-36
    800050fe:	9fdfd0ef          	jal	ra,80002afa <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005102:	fdc42703          	lw	a4,-36(s0)
    80005106:	47bd                	li	a5,15
    80005108:	02e7e963          	bltu	a5,a4,8000513a <argfd+0x50>
    8000510c:	a2dfc0ef          	jal	ra,80001b38 <myproc>
    80005110:	fdc42703          	lw	a4,-36(s0)
    80005114:	01a70793          	addi	a5,a4,26
    80005118:	078e                	slli	a5,a5,0x3
    8000511a:	953e                	add	a0,a0,a5
    8000511c:	611c                	ld	a5,0(a0)
    8000511e:	c385                	beqz	a5,8000513e <argfd+0x54>
    return -1;
  if(pfd)
    80005120:	00090463          	beqz	s2,80005128 <argfd+0x3e>
    *pfd = fd;
    80005124:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005128:	4501                	li	a0,0
  if(pf)
    8000512a:	c091                	beqz	s1,8000512e <argfd+0x44>
    *pf = f;
    8000512c:	e09c                	sd	a5,0(s1)
}
    8000512e:	70a2                	ld	ra,40(sp)
    80005130:	7402                	ld	s0,32(sp)
    80005132:	64e2                	ld	s1,24(sp)
    80005134:	6942                	ld	s2,16(sp)
    80005136:	6145                	addi	sp,sp,48
    80005138:	8082                	ret
    return -1;
    8000513a:	557d                	li	a0,-1
    8000513c:	bfcd                	j	8000512e <argfd+0x44>
    8000513e:	557d                	li	a0,-1
    80005140:	b7fd                	j	8000512e <argfd+0x44>

0000000080005142 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005142:	1101                	addi	sp,sp,-32
    80005144:	ec06                	sd	ra,24(sp)
    80005146:	e822                	sd	s0,16(sp)
    80005148:	e426                	sd	s1,8(sp)
    8000514a:	1000                	addi	s0,sp,32
    8000514c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000514e:	9ebfc0ef          	jal	ra,80001b38 <myproc>
    80005152:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005154:	0d050793          	addi	a5,a0,208
    80005158:	4501                	li	a0,0
    8000515a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000515c:	6398                	ld	a4,0(a5)
    8000515e:	cb19                	beqz	a4,80005174 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005160:	2505                	addiw	a0,a0,1
    80005162:	07a1                	addi	a5,a5,8
    80005164:	fed51ce3          	bne	a0,a3,8000515c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005168:	557d                	li	a0,-1
}
    8000516a:	60e2                	ld	ra,24(sp)
    8000516c:	6442                	ld	s0,16(sp)
    8000516e:	64a2                	ld	s1,8(sp)
    80005170:	6105                	addi	sp,sp,32
    80005172:	8082                	ret
      p->ofile[fd] = f;
    80005174:	01a50793          	addi	a5,a0,26
    80005178:	078e                	slli	a5,a5,0x3
    8000517a:	963e                	add	a2,a2,a5
    8000517c:	e204                	sd	s1,0(a2)
      return fd;
    8000517e:	b7f5                	j	8000516a <fdalloc+0x28>

0000000080005180 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005180:	715d                	addi	sp,sp,-80
    80005182:	e486                	sd	ra,72(sp)
    80005184:	e0a2                	sd	s0,64(sp)
    80005186:	fc26                	sd	s1,56(sp)
    80005188:	f84a                	sd	s2,48(sp)
    8000518a:	f44e                	sd	s3,40(sp)
    8000518c:	f052                	sd	s4,32(sp)
    8000518e:	ec56                	sd	s5,24(sp)
    80005190:	e85a                	sd	s6,16(sp)
    80005192:	0880                	addi	s0,sp,80
    80005194:	8b2e                	mv	s6,a1
    80005196:	89b2                	mv	s3,a2
    80005198:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000519a:	fb040593          	addi	a1,s0,-80
    8000519e:	820ff0ef          	jal	ra,800041be <nameiparent>
    800051a2:	84aa                	mv	s1,a0
    800051a4:	10050b63          	beqz	a0,800052ba <create+0x13a>
    return 0;

  ilock(dp);
    800051a8:	809fe0ef          	jal	ra,800039b0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051ac:	4601                	li	a2,0
    800051ae:	fb040593          	addi	a1,s0,-80
    800051b2:	8526                	mv	a0,s1
    800051b4:	d85fe0ef          	jal	ra,80003f38 <dirlookup>
    800051b8:	8aaa                	mv	s5,a0
    800051ba:	c521                	beqz	a0,80005202 <create+0x82>
    iunlockput(dp);
    800051bc:	8526                	mv	a0,s1
    800051be:	9f9fe0ef          	jal	ra,80003bb6 <iunlockput>
    ilock(ip);
    800051c2:	8556                	mv	a0,s5
    800051c4:	fecfe0ef          	jal	ra,800039b0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051c8:	000b059b          	sext.w	a1,s6
    800051cc:	4789                	li	a5,2
    800051ce:	02f59563          	bne	a1,a5,800051f8 <create+0x78>
    800051d2:	044ad783          	lhu	a5,68(s5)
    800051d6:	37f9                	addiw	a5,a5,-2
    800051d8:	17c2                	slli	a5,a5,0x30
    800051da:	93c1                	srli	a5,a5,0x30
    800051dc:	4705                	li	a4,1
    800051de:	00f76d63          	bltu	a4,a5,800051f8 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800051e2:	8556                	mv	a0,s5
    800051e4:	60a6                	ld	ra,72(sp)
    800051e6:	6406                	ld	s0,64(sp)
    800051e8:	74e2                	ld	s1,56(sp)
    800051ea:	7942                	ld	s2,48(sp)
    800051ec:	79a2                	ld	s3,40(sp)
    800051ee:	7a02                	ld	s4,32(sp)
    800051f0:	6ae2                	ld	s5,24(sp)
    800051f2:	6b42                	ld	s6,16(sp)
    800051f4:	6161                	addi	sp,sp,80
    800051f6:	8082                	ret
    iunlockput(ip);
    800051f8:	8556                	mv	a0,s5
    800051fa:	9bdfe0ef          	jal	ra,80003bb6 <iunlockput>
    return 0;
    800051fe:	4a81                	li	s5,0
    80005200:	b7cd                	j	800051e2 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005202:	85da                	mv	a1,s6
    80005204:	4088                	lw	a0,0(s1)
    80005206:	e40fe0ef          	jal	ra,80003846 <ialloc>
    8000520a:	8a2a                	mv	s4,a0
    8000520c:	cd1d                	beqz	a0,8000524a <create+0xca>
  ilock(ip);
    8000520e:	fa2fe0ef          	jal	ra,800039b0 <ilock>
  ip->major = major;
    80005212:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005216:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000521a:	4905                	li	s2,1
    8000521c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005220:	8552                	mv	a0,s4
    80005222:	edafe0ef          	jal	ra,800038fc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005226:	000b059b          	sext.w	a1,s6
    8000522a:	03258563          	beq	a1,s2,80005254 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    8000522e:	004a2603          	lw	a2,4(s4)
    80005232:	fb040593          	addi	a1,s0,-80
    80005236:	8526                	mv	a0,s1
    80005238:	ed3fe0ef          	jal	ra,8000410a <dirlink>
    8000523c:	06054363          	bltz	a0,800052a2 <create+0x122>
  iunlockput(dp);
    80005240:	8526                	mv	a0,s1
    80005242:	975fe0ef          	jal	ra,80003bb6 <iunlockput>
  return ip;
    80005246:	8ad2                	mv	s5,s4
    80005248:	bf69                	j	800051e2 <create+0x62>
    iunlockput(dp);
    8000524a:	8526                	mv	a0,s1
    8000524c:	96bfe0ef          	jal	ra,80003bb6 <iunlockput>
    return 0;
    80005250:	8ad2                	mv	s5,s4
    80005252:	bf41                	j	800051e2 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005254:	004a2603          	lw	a2,4(s4)
    80005258:	00003597          	auipc	a1,0x3
    8000525c:	49058593          	addi	a1,a1,1168 # 800086e8 <syscalls+0x2f0>
    80005260:	8552                	mv	a0,s4
    80005262:	ea9fe0ef          	jal	ra,8000410a <dirlink>
    80005266:	02054e63          	bltz	a0,800052a2 <create+0x122>
    8000526a:	40d0                	lw	a2,4(s1)
    8000526c:	00003597          	auipc	a1,0x3
    80005270:	48458593          	addi	a1,a1,1156 # 800086f0 <syscalls+0x2f8>
    80005274:	8552                	mv	a0,s4
    80005276:	e95fe0ef          	jal	ra,8000410a <dirlink>
    8000527a:	02054463          	bltz	a0,800052a2 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    8000527e:	004a2603          	lw	a2,4(s4)
    80005282:	fb040593          	addi	a1,s0,-80
    80005286:	8526                	mv	a0,s1
    80005288:	e83fe0ef          	jal	ra,8000410a <dirlink>
    8000528c:	00054b63          	bltz	a0,800052a2 <create+0x122>
    dp->nlink++;  // for ".."
    80005290:	04a4d783          	lhu	a5,74(s1)
    80005294:	2785                	addiw	a5,a5,1
    80005296:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000529a:	8526                	mv	a0,s1
    8000529c:	e60fe0ef          	jal	ra,800038fc <iupdate>
    800052a0:	b745                	j	80005240 <create+0xc0>
  ip->nlink = 0;
    800052a2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800052a6:	8552                	mv	a0,s4
    800052a8:	e54fe0ef          	jal	ra,800038fc <iupdate>
  iunlockput(ip);
    800052ac:	8552                	mv	a0,s4
    800052ae:	909fe0ef          	jal	ra,80003bb6 <iunlockput>
  iunlockput(dp);
    800052b2:	8526                	mv	a0,s1
    800052b4:	903fe0ef          	jal	ra,80003bb6 <iunlockput>
  return 0;
    800052b8:	b72d                	j	800051e2 <create+0x62>
    return 0;
    800052ba:	8aaa                	mv	s5,a0
    800052bc:	b71d                	j	800051e2 <create+0x62>

00000000800052be <sys_dup>:
{
    800052be:	7179                	addi	sp,sp,-48
    800052c0:	f406                	sd	ra,40(sp)
    800052c2:	f022                	sd	s0,32(sp)
    800052c4:	ec26                	sd	s1,24(sp)
    800052c6:	e84a                	sd	s2,16(sp)
    800052c8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052ca:	fd840613          	addi	a2,s0,-40
    800052ce:	4581                	li	a1,0
    800052d0:	4501                	li	a0,0
    800052d2:	e19ff0ef          	jal	ra,800050ea <argfd>
    return -1;
    800052d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052d8:	00054f63          	bltz	a0,800052f6 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    800052dc:	fd843903          	ld	s2,-40(s0)
    800052e0:	854a                	mv	a0,s2
    800052e2:	e61ff0ef          	jal	ra,80005142 <fdalloc>
    800052e6:	84aa                	mv	s1,a0
    return -1;
    800052e8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052ea:	00054663          	bltz	a0,800052f6 <sys_dup+0x38>
  filedup(f);
    800052ee:	854a                	mv	a0,s2
    800052f0:	c6cff0ef          	jal	ra,8000475c <filedup>
  return fd;
    800052f4:	87a6                	mv	a5,s1
}
    800052f6:	853e                	mv	a0,a5
    800052f8:	70a2                	ld	ra,40(sp)
    800052fa:	7402                	ld	s0,32(sp)
    800052fc:	64e2                	ld	s1,24(sp)
    800052fe:	6942                	ld	s2,16(sp)
    80005300:	6145                	addi	sp,sp,48
    80005302:	8082                	ret

0000000080005304 <sys_read>:
{
    80005304:	7179                	addi	sp,sp,-48
    80005306:	f406                	sd	ra,40(sp)
    80005308:	f022                	sd	s0,32(sp)
    8000530a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000530c:	fd840593          	addi	a1,s0,-40
    80005310:	4505                	li	a0,1
    80005312:	805fd0ef          	jal	ra,80002b16 <argaddr>
  argint(2, &n);
    80005316:	fe440593          	addi	a1,s0,-28
    8000531a:	4509                	li	a0,2
    8000531c:	fdefd0ef          	jal	ra,80002afa <argint>
  if(argfd(0, 0, &f) < 0)
    80005320:	fe840613          	addi	a2,s0,-24
    80005324:	4581                	li	a1,0
    80005326:	4501                	li	a0,0
    80005328:	dc3ff0ef          	jal	ra,800050ea <argfd>
    8000532c:	87aa                	mv	a5,a0
    return -1;
    8000532e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005330:	0007ca63          	bltz	a5,80005344 <sys_read+0x40>
  return fileread(f, p, n);
    80005334:	fe442603          	lw	a2,-28(s0)
    80005338:	fd843583          	ld	a1,-40(s0)
    8000533c:	fe843503          	ld	a0,-24(s0)
    80005340:	d68ff0ef          	jal	ra,800048a8 <fileread>
}
    80005344:	70a2                	ld	ra,40(sp)
    80005346:	7402                	ld	s0,32(sp)
    80005348:	6145                	addi	sp,sp,48
    8000534a:	8082                	ret

000000008000534c <sys_write>:
{
    8000534c:	7179                	addi	sp,sp,-48
    8000534e:	f406                	sd	ra,40(sp)
    80005350:	f022                	sd	s0,32(sp)
    80005352:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005354:	fd840593          	addi	a1,s0,-40
    80005358:	4505                	li	a0,1
    8000535a:	fbcfd0ef          	jal	ra,80002b16 <argaddr>
  argint(2, &n);
    8000535e:	fe440593          	addi	a1,s0,-28
    80005362:	4509                	li	a0,2
    80005364:	f96fd0ef          	jal	ra,80002afa <argint>
  if(argfd(0, 0, &f) < 0)
    80005368:	fe840613          	addi	a2,s0,-24
    8000536c:	4581                	li	a1,0
    8000536e:	4501                	li	a0,0
    80005370:	d7bff0ef          	jal	ra,800050ea <argfd>
    80005374:	87aa                	mv	a5,a0
    return -1;
    80005376:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005378:	0007ca63          	bltz	a5,8000538c <sys_write+0x40>
  return filewrite(f, p, n);
    8000537c:	fe442603          	lw	a2,-28(s0)
    80005380:	fd843583          	ld	a1,-40(s0)
    80005384:	fe843503          	ld	a0,-24(s0)
    80005388:	dceff0ef          	jal	ra,80004956 <filewrite>
}
    8000538c:	70a2                	ld	ra,40(sp)
    8000538e:	7402                	ld	s0,32(sp)
    80005390:	6145                	addi	sp,sp,48
    80005392:	8082                	ret

0000000080005394 <sys_close>:
{
    80005394:	1101                	addi	sp,sp,-32
    80005396:	ec06                	sd	ra,24(sp)
    80005398:	e822                	sd	s0,16(sp)
    8000539a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000539c:	fe040613          	addi	a2,s0,-32
    800053a0:	fec40593          	addi	a1,s0,-20
    800053a4:	4501                	li	a0,0
    800053a6:	d45ff0ef          	jal	ra,800050ea <argfd>
    return -1;
    800053aa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053ac:	02054063          	bltz	a0,800053cc <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800053b0:	f88fc0ef          	jal	ra,80001b38 <myproc>
    800053b4:	fec42783          	lw	a5,-20(s0)
    800053b8:	07e9                	addi	a5,a5,26
    800053ba:	078e                	slli	a5,a5,0x3
    800053bc:	953e                	add	a0,a0,a5
    800053be:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800053c2:	fe043503          	ld	a0,-32(s0)
    800053c6:	bdcff0ef          	jal	ra,800047a2 <fileclose>
  return 0;
    800053ca:	4781                	li	a5,0
}
    800053cc:	853e                	mv	a0,a5
    800053ce:	60e2                	ld	ra,24(sp)
    800053d0:	6442                	ld	s0,16(sp)
    800053d2:	6105                	addi	sp,sp,32
    800053d4:	8082                	ret

00000000800053d6 <sys_fstat>:
{
    800053d6:	1101                	addi	sp,sp,-32
    800053d8:	ec06                	sd	ra,24(sp)
    800053da:	e822                	sd	s0,16(sp)
    800053dc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800053de:	fe040593          	addi	a1,s0,-32
    800053e2:	4505                	li	a0,1
    800053e4:	f32fd0ef          	jal	ra,80002b16 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800053e8:	fe840613          	addi	a2,s0,-24
    800053ec:	4581                	li	a1,0
    800053ee:	4501                	li	a0,0
    800053f0:	cfbff0ef          	jal	ra,800050ea <argfd>
    800053f4:	87aa                	mv	a5,a0
    return -1;
    800053f6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053f8:	0007c863          	bltz	a5,80005408 <sys_fstat+0x32>
  return filestat(f, st);
    800053fc:	fe043583          	ld	a1,-32(s0)
    80005400:	fe843503          	ld	a0,-24(s0)
    80005404:	c46ff0ef          	jal	ra,8000484a <filestat>
}
    80005408:	60e2                	ld	ra,24(sp)
    8000540a:	6442                	ld	s0,16(sp)
    8000540c:	6105                	addi	sp,sp,32
    8000540e:	8082                	ret

0000000080005410 <sys_link>:
{
    80005410:	7169                	addi	sp,sp,-304
    80005412:	f606                	sd	ra,296(sp)
    80005414:	f222                	sd	s0,288(sp)
    80005416:	ee26                	sd	s1,280(sp)
    80005418:	ea4a                	sd	s2,272(sp)
    8000541a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000541c:	08000613          	li	a2,128
    80005420:	ed040593          	addi	a1,s0,-304
    80005424:	4501                	li	a0,0
    80005426:	f0cfd0ef          	jal	ra,80002b32 <argstr>
    return -1;
    8000542a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000542c:	0c054663          	bltz	a0,800054f8 <sys_link+0xe8>
    80005430:	08000613          	li	a2,128
    80005434:	f5040593          	addi	a1,s0,-176
    80005438:	4505                	li	a0,1
    8000543a:	ef8fd0ef          	jal	ra,80002b32 <argstr>
    return -1;
    8000543e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005440:	0a054c63          	bltz	a0,800054f8 <sys_link+0xe8>
  begin_op();
    80005444:	f55fe0ef          	jal	ra,80004398 <begin_op>
  if((ip = namei(old)) == 0){
    80005448:	ed040513          	addi	a0,s0,-304
    8000544c:	d59fe0ef          	jal	ra,800041a4 <namei>
    80005450:	84aa                	mv	s1,a0
    80005452:	c525                	beqz	a0,800054ba <sys_link+0xaa>
  ilock(ip);
    80005454:	d5cfe0ef          	jal	ra,800039b0 <ilock>
  if(ip->type == T_DIR){
    80005458:	04449703          	lh	a4,68(s1)
    8000545c:	4785                	li	a5,1
    8000545e:	06f70263          	beq	a4,a5,800054c2 <sys_link+0xb2>
  ip->nlink++;
    80005462:	04a4d783          	lhu	a5,74(s1)
    80005466:	2785                	addiw	a5,a5,1
    80005468:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000546c:	8526                	mv	a0,s1
    8000546e:	c8efe0ef          	jal	ra,800038fc <iupdate>
  iunlock(ip);
    80005472:	8526                	mv	a0,s1
    80005474:	de6fe0ef          	jal	ra,80003a5a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005478:	fd040593          	addi	a1,s0,-48
    8000547c:	f5040513          	addi	a0,s0,-176
    80005480:	d3ffe0ef          	jal	ra,800041be <nameiparent>
    80005484:	892a                	mv	s2,a0
    80005486:	c921                	beqz	a0,800054d6 <sys_link+0xc6>
  ilock(dp);
    80005488:	d28fe0ef          	jal	ra,800039b0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000548c:	00092703          	lw	a4,0(s2)
    80005490:	409c                	lw	a5,0(s1)
    80005492:	02f71f63          	bne	a4,a5,800054d0 <sys_link+0xc0>
    80005496:	40d0                	lw	a2,4(s1)
    80005498:	fd040593          	addi	a1,s0,-48
    8000549c:	854a                	mv	a0,s2
    8000549e:	c6dfe0ef          	jal	ra,8000410a <dirlink>
    800054a2:	02054763          	bltz	a0,800054d0 <sys_link+0xc0>
  iunlockput(dp);
    800054a6:	854a                	mv	a0,s2
    800054a8:	f0efe0ef          	jal	ra,80003bb6 <iunlockput>
  iput(ip);
    800054ac:	8526                	mv	a0,s1
    800054ae:	e80fe0ef          	jal	ra,80003b2e <iput>
  end_op();
    800054b2:	f55fe0ef          	jal	ra,80004406 <end_op>
  return 0;
    800054b6:	4781                	li	a5,0
    800054b8:	a081                	j	800054f8 <sys_link+0xe8>
    end_op();
    800054ba:	f4dfe0ef          	jal	ra,80004406 <end_op>
    return -1;
    800054be:	57fd                	li	a5,-1
    800054c0:	a825                	j	800054f8 <sys_link+0xe8>
    iunlockput(ip);
    800054c2:	8526                	mv	a0,s1
    800054c4:	ef2fe0ef          	jal	ra,80003bb6 <iunlockput>
    end_op();
    800054c8:	f3ffe0ef          	jal	ra,80004406 <end_op>
    return -1;
    800054cc:	57fd                	li	a5,-1
    800054ce:	a02d                	j	800054f8 <sys_link+0xe8>
    iunlockput(dp);
    800054d0:	854a                	mv	a0,s2
    800054d2:	ee4fe0ef          	jal	ra,80003bb6 <iunlockput>
  ilock(ip);
    800054d6:	8526                	mv	a0,s1
    800054d8:	cd8fe0ef          	jal	ra,800039b0 <ilock>
  ip->nlink--;
    800054dc:	04a4d783          	lhu	a5,74(s1)
    800054e0:	37fd                	addiw	a5,a5,-1
    800054e2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054e6:	8526                	mv	a0,s1
    800054e8:	c14fe0ef          	jal	ra,800038fc <iupdate>
  iunlockput(ip);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ec8fe0ef          	jal	ra,80003bb6 <iunlockput>
  end_op();
    800054f2:	f15fe0ef          	jal	ra,80004406 <end_op>
  return -1;
    800054f6:	57fd                	li	a5,-1
}
    800054f8:	853e                	mv	a0,a5
    800054fa:	70b2                	ld	ra,296(sp)
    800054fc:	7412                	ld	s0,288(sp)
    800054fe:	64f2                	ld	s1,280(sp)
    80005500:	6952                	ld	s2,272(sp)
    80005502:	6155                	addi	sp,sp,304
    80005504:	8082                	ret

0000000080005506 <sys_unlink>:
{
    80005506:	7151                	addi	sp,sp,-240
    80005508:	f586                	sd	ra,232(sp)
    8000550a:	f1a2                	sd	s0,224(sp)
    8000550c:	eda6                	sd	s1,216(sp)
    8000550e:	e9ca                	sd	s2,208(sp)
    80005510:	e5ce                	sd	s3,200(sp)
    80005512:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005514:	08000613          	li	a2,128
    80005518:	f3040593          	addi	a1,s0,-208
    8000551c:	4501                	li	a0,0
    8000551e:	e14fd0ef          	jal	ra,80002b32 <argstr>
    80005522:	12054b63          	bltz	a0,80005658 <sys_unlink+0x152>
  begin_op();
    80005526:	e73fe0ef          	jal	ra,80004398 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000552a:	fb040593          	addi	a1,s0,-80
    8000552e:	f3040513          	addi	a0,s0,-208
    80005532:	c8dfe0ef          	jal	ra,800041be <nameiparent>
    80005536:	84aa                	mv	s1,a0
    80005538:	c54d                	beqz	a0,800055e2 <sys_unlink+0xdc>
  ilock(dp);
    8000553a:	c76fe0ef          	jal	ra,800039b0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000553e:	00003597          	auipc	a1,0x3
    80005542:	1aa58593          	addi	a1,a1,426 # 800086e8 <syscalls+0x2f0>
    80005546:	fb040513          	addi	a0,s0,-80
    8000554a:	9d9fe0ef          	jal	ra,80003f22 <namecmp>
    8000554e:	10050a63          	beqz	a0,80005662 <sys_unlink+0x15c>
    80005552:	00003597          	auipc	a1,0x3
    80005556:	19e58593          	addi	a1,a1,414 # 800086f0 <syscalls+0x2f8>
    8000555a:	fb040513          	addi	a0,s0,-80
    8000555e:	9c5fe0ef          	jal	ra,80003f22 <namecmp>
    80005562:	10050063          	beqz	a0,80005662 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005566:	f2c40613          	addi	a2,s0,-212
    8000556a:	fb040593          	addi	a1,s0,-80
    8000556e:	8526                	mv	a0,s1
    80005570:	9c9fe0ef          	jal	ra,80003f38 <dirlookup>
    80005574:	892a                	mv	s2,a0
    80005576:	0e050663          	beqz	a0,80005662 <sys_unlink+0x15c>
  ilock(ip);
    8000557a:	c36fe0ef          	jal	ra,800039b0 <ilock>
  if(ip->nlink < 1)
    8000557e:	04a91783          	lh	a5,74(s2)
    80005582:	06f05463          	blez	a5,800055ea <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005586:	04491703          	lh	a4,68(s2)
    8000558a:	4785                	li	a5,1
    8000558c:	06f70563          	beq	a4,a5,800055f6 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80005590:	4641                	li	a2,16
    80005592:	4581                	li	a1,0
    80005594:	fc040513          	addi	a0,s0,-64
    80005598:	fdcfb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000559c:	4741                	li	a4,16
    8000559e:	f2c42683          	lw	a3,-212(s0)
    800055a2:	fc040613          	addi	a2,s0,-64
    800055a6:	4581                	li	a1,0
    800055a8:	8526                	mv	a0,s1
    800055aa:	877fe0ef          	jal	ra,80003e20 <writei>
    800055ae:	47c1                	li	a5,16
    800055b0:	08f51563          	bne	a0,a5,8000563a <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800055b4:	04491703          	lh	a4,68(s2)
    800055b8:	4785                	li	a5,1
    800055ba:	08f70663          	beq	a4,a5,80005646 <sys_unlink+0x140>
  iunlockput(dp);
    800055be:	8526                	mv	a0,s1
    800055c0:	df6fe0ef          	jal	ra,80003bb6 <iunlockput>
  ip->nlink--;
    800055c4:	04a95783          	lhu	a5,74(s2)
    800055c8:	37fd                	addiw	a5,a5,-1
    800055ca:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055ce:	854a                	mv	a0,s2
    800055d0:	b2cfe0ef          	jal	ra,800038fc <iupdate>
  iunlockput(ip);
    800055d4:	854a                	mv	a0,s2
    800055d6:	de0fe0ef          	jal	ra,80003bb6 <iunlockput>
  end_op();
    800055da:	e2dfe0ef          	jal	ra,80004406 <end_op>
  return 0;
    800055de:	4501                	li	a0,0
    800055e0:	a079                	j	8000566e <sys_unlink+0x168>
    end_op();
    800055e2:	e25fe0ef          	jal	ra,80004406 <end_op>
    return -1;
    800055e6:	557d                	li	a0,-1
    800055e8:	a059                	j	8000566e <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800055ea:	00003517          	auipc	a0,0x3
    800055ee:	10e50513          	addi	a0,a0,270 # 800086f8 <syscalls+0x300>
    800055f2:	996fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055f6:	04c92703          	lw	a4,76(s2)
    800055fa:	02000793          	li	a5,32
    800055fe:	f8e7f9e3          	bgeu	a5,a4,80005590 <sys_unlink+0x8a>
    80005602:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005606:	4741                	li	a4,16
    80005608:	86ce                	mv	a3,s3
    8000560a:	f1840613          	addi	a2,s0,-232
    8000560e:	4581                	li	a1,0
    80005610:	854a                	mv	a0,s2
    80005612:	f2afe0ef          	jal	ra,80003d3c <readi>
    80005616:	47c1                	li	a5,16
    80005618:	00f51b63          	bne	a0,a5,8000562e <sys_unlink+0x128>
    if(de.inum != 0)
    8000561c:	f1845783          	lhu	a5,-232(s0)
    80005620:	ef95                	bnez	a5,8000565c <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005622:	29c1                	addiw	s3,s3,16
    80005624:	04c92783          	lw	a5,76(s2)
    80005628:	fcf9efe3          	bltu	s3,a5,80005606 <sys_unlink+0x100>
    8000562c:	b795                	j	80005590 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000562e:	00003517          	auipc	a0,0x3
    80005632:	0e250513          	addi	a0,a0,226 # 80008710 <syscalls+0x318>
    80005636:	952fb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    8000563a:	00003517          	auipc	a0,0x3
    8000563e:	0ee50513          	addi	a0,a0,238 # 80008728 <syscalls+0x330>
    80005642:	946fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005646:	04a4d783          	lhu	a5,74(s1)
    8000564a:	37fd                	addiw	a5,a5,-1
    8000564c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005650:	8526                	mv	a0,s1
    80005652:	aaafe0ef          	jal	ra,800038fc <iupdate>
    80005656:	b7a5                	j	800055be <sys_unlink+0xb8>
    return -1;
    80005658:	557d                	li	a0,-1
    8000565a:	a811                	j	8000566e <sys_unlink+0x168>
    iunlockput(ip);
    8000565c:	854a                	mv	a0,s2
    8000565e:	d58fe0ef          	jal	ra,80003bb6 <iunlockput>
  iunlockput(dp);
    80005662:	8526                	mv	a0,s1
    80005664:	d52fe0ef          	jal	ra,80003bb6 <iunlockput>
  end_op();
    80005668:	d9ffe0ef          	jal	ra,80004406 <end_op>
  return -1;
    8000566c:	557d                	li	a0,-1
}
    8000566e:	70ae                	ld	ra,232(sp)
    80005670:	740e                	ld	s0,224(sp)
    80005672:	64ee                	ld	s1,216(sp)
    80005674:	694e                	ld	s2,208(sp)
    80005676:	69ae                	ld	s3,200(sp)
    80005678:	616d                	addi	sp,sp,240
    8000567a:	8082                	ret

000000008000567c <sys_open>:

uint64
sys_open(void)
{
    8000567c:	7131                	addi	sp,sp,-192
    8000567e:	fd06                	sd	ra,184(sp)
    80005680:	f922                	sd	s0,176(sp)
    80005682:	f526                	sd	s1,168(sp)
    80005684:	f14a                	sd	s2,160(sp)
    80005686:	ed4e                	sd	s3,152(sp)
    80005688:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000568a:	f4c40593          	addi	a1,s0,-180
    8000568e:	4505                	li	a0,1
    80005690:	c6afd0ef          	jal	ra,80002afa <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005694:	08000613          	li	a2,128
    80005698:	f5040593          	addi	a1,s0,-176
    8000569c:	4501                	li	a0,0
    8000569e:	c94fd0ef          	jal	ra,80002b32 <argstr>
    800056a2:	87aa                	mv	a5,a0
    return -1;
    800056a4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056a6:	0807cd63          	bltz	a5,80005740 <sys_open+0xc4>

  begin_op();
    800056aa:	ceffe0ef          	jal	ra,80004398 <begin_op>

  if(omode & O_CREATE){
    800056ae:	f4c42783          	lw	a5,-180(s0)
    800056b2:	2007f793          	andi	a5,a5,512
    800056b6:	c3c5                	beqz	a5,80005756 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800056b8:	4681                	li	a3,0
    800056ba:	4601                	li	a2,0
    800056bc:	4589                	li	a1,2
    800056be:	f5040513          	addi	a0,s0,-176
    800056c2:	abfff0ef          	jal	ra,80005180 <create>
    800056c6:	84aa                	mv	s1,a0
    if(ip == 0){
    800056c8:	c159                	beqz	a0,8000574e <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056ca:	04449703          	lh	a4,68(s1)
    800056ce:	478d                	li	a5,3
    800056d0:	00f71763          	bne	a4,a5,800056de <sys_open+0x62>
    800056d4:	0464d703          	lhu	a4,70(s1)
    800056d8:	47a5                	li	a5,9
    800056da:	0ae7e963          	bltu	a5,a4,8000578c <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056de:	820ff0ef          	jal	ra,800046fe <filealloc>
    800056e2:	89aa                	mv	s3,a0
    800056e4:	0c050963          	beqz	a0,800057b6 <sys_open+0x13a>
    800056e8:	a5bff0ef          	jal	ra,80005142 <fdalloc>
    800056ec:	892a                	mv	s2,a0
    800056ee:	0c054163          	bltz	a0,800057b0 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056f2:	04449703          	lh	a4,68(s1)
    800056f6:	478d                	li	a5,3
    800056f8:	0af70163          	beq	a4,a5,8000579a <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056fc:	4789                	li	a5,2
    800056fe:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005702:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005706:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000570a:	f4c42783          	lw	a5,-180(s0)
    8000570e:	0017c713          	xori	a4,a5,1
    80005712:	8b05                	andi	a4,a4,1
    80005714:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005718:	0037f713          	andi	a4,a5,3
    8000571c:	00e03733          	snez	a4,a4
    80005720:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005724:	4007f793          	andi	a5,a5,1024
    80005728:	c791                	beqz	a5,80005734 <sys_open+0xb8>
    8000572a:	04449703          	lh	a4,68(s1)
    8000572e:	4789                	li	a5,2
    80005730:	06f70c63          	beq	a4,a5,800057a8 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005734:	8526                	mv	a0,s1
    80005736:	b24fe0ef          	jal	ra,80003a5a <iunlock>
  end_op();
    8000573a:	ccdfe0ef          	jal	ra,80004406 <end_op>

  return fd;
    8000573e:	854a                	mv	a0,s2
}
    80005740:	70ea                	ld	ra,184(sp)
    80005742:	744a                	ld	s0,176(sp)
    80005744:	74aa                	ld	s1,168(sp)
    80005746:	790a                	ld	s2,160(sp)
    80005748:	69ea                	ld	s3,152(sp)
    8000574a:	6129                	addi	sp,sp,192
    8000574c:	8082                	ret
      end_op();
    8000574e:	cb9fe0ef          	jal	ra,80004406 <end_op>
      return -1;
    80005752:	557d                	li	a0,-1
    80005754:	b7f5                	j	80005740 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005756:	f5040513          	addi	a0,s0,-176
    8000575a:	a4bfe0ef          	jal	ra,800041a4 <namei>
    8000575e:	84aa                	mv	s1,a0
    80005760:	c115                	beqz	a0,80005784 <sys_open+0x108>
    ilock(ip);
    80005762:	a4efe0ef          	jal	ra,800039b0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005766:	04449703          	lh	a4,68(s1)
    8000576a:	4785                	li	a5,1
    8000576c:	f4f71fe3          	bne	a4,a5,800056ca <sys_open+0x4e>
    80005770:	f4c42783          	lw	a5,-180(s0)
    80005774:	d7ad                	beqz	a5,800056de <sys_open+0x62>
      iunlockput(ip);
    80005776:	8526                	mv	a0,s1
    80005778:	c3efe0ef          	jal	ra,80003bb6 <iunlockput>
      end_op();
    8000577c:	c8bfe0ef          	jal	ra,80004406 <end_op>
      return -1;
    80005780:	557d                	li	a0,-1
    80005782:	bf7d                	j	80005740 <sys_open+0xc4>
      end_op();
    80005784:	c83fe0ef          	jal	ra,80004406 <end_op>
      return -1;
    80005788:	557d                	li	a0,-1
    8000578a:	bf5d                	j	80005740 <sys_open+0xc4>
    iunlockput(ip);
    8000578c:	8526                	mv	a0,s1
    8000578e:	c28fe0ef          	jal	ra,80003bb6 <iunlockput>
    end_op();
    80005792:	c75fe0ef          	jal	ra,80004406 <end_op>
    return -1;
    80005796:	557d                	li	a0,-1
    80005798:	b765                	j	80005740 <sys_open+0xc4>
    f->type = FD_DEVICE;
    8000579a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000579e:	04649783          	lh	a5,70(s1)
    800057a2:	02f99223          	sh	a5,36(s3)
    800057a6:	b785                	j	80005706 <sys_open+0x8a>
    itrunc(ip);
    800057a8:	8526                	mv	a0,s1
    800057aa:	af0fe0ef          	jal	ra,80003a9a <itrunc>
    800057ae:	b759                	j	80005734 <sys_open+0xb8>
      fileclose(f);
    800057b0:	854e                	mv	a0,s3
    800057b2:	ff1fe0ef          	jal	ra,800047a2 <fileclose>
    iunlockput(ip);
    800057b6:	8526                	mv	a0,s1
    800057b8:	bfefe0ef          	jal	ra,80003bb6 <iunlockput>
    end_op();
    800057bc:	c4bfe0ef          	jal	ra,80004406 <end_op>
    return -1;
    800057c0:	557d                	li	a0,-1
    800057c2:	bfbd                	j	80005740 <sys_open+0xc4>

00000000800057c4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057c4:	7175                	addi	sp,sp,-144
    800057c6:	e506                	sd	ra,136(sp)
    800057c8:	e122                	sd	s0,128(sp)
    800057ca:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057cc:	bcdfe0ef          	jal	ra,80004398 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057d0:	08000613          	li	a2,128
    800057d4:	f7040593          	addi	a1,s0,-144
    800057d8:	4501                	li	a0,0
    800057da:	b58fd0ef          	jal	ra,80002b32 <argstr>
    800057de:	02054363          	bltz	a0,80005804 <sys_mkdir+0x40>
    800057e2:	4681                	li	a3,0
    800057e4:	4601                	li	a2,0
    800057e6:	4585                	li	a1,1
    800057e8:	f7040513          	addi	a0,s0,-144
    800057ec:	995ff0ef          	jal	ra,80005180 <create>
    800057f0:	c911                	beqz	a0,80005804 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057f2:	bc4fe0ef          	jal	ra,80003bb6 <iunlockput>
  end_op();
    800057f6:	c11fe0ef          	jal	ra,80004406 <end_op>
  return 0;
    800057fa:	4501                	li	a0,0
}
    800057fc:	60aa                	ld	ra,136(sp)
    800057fe:	640a                	ld	s0,128(sp)
    80005800:	6149                	addi	sp,sp,144
    80005802:	8082                	ret
    end_op();
    80005804:	c03fe0ef          	jal	ra,80004406 <end_op>
    return -1;
    80005808:	557d                	li	a0,-1
    8000580a:	bfcd                	j	800057fc <sys_mkdir+0x38>

000000008000580c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000580c:	7135                	addi	sp,sp,-160
    8000580e:	ed06                	sd	ra,152(sp)
    80005810:	e922                	sd	s0,144(sp)
    80005812:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005814:	b85fe0ef          	jal	ra,80004398 <begin_op>
  argint(1, &major);
    80005818:	f6c40593          	addi	a1,s0,-148
    8000581c:	4505                	li	a0,1
    8000581e:	adcfd0ef          	jal	ra,80002afa <argint>
  argint(2, &minor);
    80005822:	f6840593          	addi	a1,s0,-152
    80005826:	4509                	li	a0,2
    80005828:	ad2fd0ef          	jal	ra,80002afa <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000582c:	08000613          	li	a2,128
    80005830:	f7040593          	addi	a1,s0,-144
    80005834:	4501                	li	a0,0
    80005836:	afcfd0ef          	jal	ra,80002b32 <argstr>
    8000583a:	02054563          	bltz	a0,80005864 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000583e:	f6841683          	lh	a3,-152(s0)
    80005842:	f6c41603          	lh	a2,-148(s0)
    80005846:	458d                	li	a1,3
    80005848:	f7040513          	addi	a0,s0,-144
    8000584c:	935ff0ef          	jal	ra,80005180 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005850:	c911                	beqz	a0,80005864 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005852:	b64fe0ef          	jal	ra,80003bb6 <iunlockput>
  end_op();
    80005856:	bb1fe0ef          	jal	ra,80004406 <end_op>
  return 0;
    8000585a:	4501                	li	a0,0
}
    8000585c:	60ea                	ld	ra,152(sp)
    8000585e:	644a                	ld	s0,144(sp)
    80005860:	610d                	addi	sp,sp,160
    80005862:	8082                	ret
    end_op();
    80005864:	ba3fe0ef          	jal	ra,80004406 <end_op>
    return -1;
    80005868:	557d                	li	a0,-1
    8000586a:	bfcd                	j	8000585c <sys_mknod+0x50>

000000008000586c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000586c:	7135                	addi	sp,sp,-160
    8000586e:	ed06                	sd	ra,152(sp)
    80005870:	e922                	sd	s0,144(sp)
    80005872:	e526                	sd	s1,136(sp)
    80005874:	e14a                	sd	s2,128(sp)
    80005876:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005878:	ac0fc0ef          	jal	ra,80001b38 <myproc>
    8000587c:	892a                	mv	s2,a0
  
  begin_op();
    8000587e:	b1bfe0ef          	jal	ra,80004398 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005882:	08000613          	li	a2,128
    80005886:	f6040593          	addi	a1,s0,-160
    8000588a:	4501                	li	a0,0
    8000588c:	aa6fd0ef          	jal	ra,80002b32 <argstr>
    80005890:	04054163          	bltz	a0,800058d2 <sys_chdir+0x66>
    80005894:	f6040513          	addi	a0,s0,-160
    80005898:	90dfe0ef          	jal	ra,800041a4 <namei>
    8000589c:	84aa                	mv	s1,a0
    8000589e:	c915                	beqz	a0,800058d2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800058a0:	910fe0ef          	jal	ra,800039b0 <ilock>
  if(ip->type != T_DIR){
    800058a4:	04449703          	lh	a4,68(s1)
    800058a8:	4785                	li	a5,1
    800058aa:	02f71863          	bne	a4,a5,800058da <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058ae:	8526                	mv	a0,s1
    800058b0:	9aafe0ef          	jal	ra,80003a5a <iunlock>
  iput(p->cwd);
    800058b4:	15093503          	ld	a0,336(s2)
    800058b8:	a76fe0ef          	jal	ra,80003b2e <iput>
  end_op();
    800058bc:	b4bfe0ef          	jal	ra,80004406 <end_op>
  p->cwd = ip;
    800058c0:	14993823          	sd	s1,336(s2)
  return 0;
    800058c4:	4501                	li	a0,0
}
    800058c6:	60ea                	ld	ra,152(sp)
    800058c8:	644a                	ld	s0,144(sp)
    800058ca:	64aa                	ld	s1,136(sp)
    800058cc:	690a                	ld	s2,128(sp)
    800058ce:	610d                	addi	sp,sp,160
    800058d0:	8082                	ret
    end_op();
    800058d2:	b35fe0ef          	jal	ra,80004406 <end_op>
    return -1;
    800058d6:	557d                	li	a0,-1
    800058d8:	b7fd                	j	800058c6 <sys_chdir+0x5a>
    iunlockput(ip);
    800058da:	8526                	mv	a0,s1
    800058dc:	adafe0ef          	jal	ra,80003bb6 <iunlockput>
    end_op();
    800058e0:	b27fe0ef          	jal	ra,80004406 <end_op>
    return -1;
    800058e4:	557d                	li	a0,-1
    800058e6:	b7c5                	j	800058c6 <sys_chdir+0x5a>

00000000800058e8 <sys_exec>:

uint64
sys_exec(void)
{
    800058e8:	7145                	addi	sp,sp,-464
    800058ea:	e786                	sd	ra,456(sp)
    800058ec:	e3a2                	sd	s0,448(sp)
    800058ee:	ff26                	sd	s1,440(sp)
    800058f0:	fb4a                	sd	s2,432(sp)
    800058f2:	f74e                	sd	s3,424(sp)
    800058f4:	f352                	sd	s4,416(sp)
    800058f6:	ef56                	sd	s5,408(sp)
    800058f8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800058fa:	e3840593          	addi	a1,s0,-456
    800058fe:	4505                	li	a0,1
    80005900:	a16fd0ef          	jal	ra,80002b16 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005904:	08000613          	li	a2,128
    80005908:	f4040593          	addi	a1,s0,-192
    8000590c:	4501                	li	a0,0
    8000590e:	a24fd0ef          	jal	ra,80002b32 <argstr>
    80005912:	87aa                	mv	a5,a0
    return -1;
    80005914:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005916:	0a07c563          	bltz	a5,800059c0 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    8000591a:	10000613          	li	a2,256
    8000591e:	4581                	li	a1,0
    80005920:	e4040513          	addi	a0,s0,-448
    80005924:	c50fb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005928:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000592c:	89a6                	mv	s3,s1
    8000592e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005930:	02000a13          	li	s4,32
    80005934:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005938:	00391513          	slli	a0,s2,0x3
    8000593c:	e3040593          	addi	a1,s0,-464
    80005940:	e3843783          	ld	a5,-456(s0)
    80005944:	953e                	add	a0,a0,a5
    80005946:	92afd0ef          	jal	ra,80002a70 <fetchaddr>
    8000594a:	02054663          	bltz	a0,80005976 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    8000594e:	e3043783          	ld	a5,-464(s0)
    80005952:	cf8d                	beqz	a5,8000598c <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005954:	a56fb0ef          	jal	ra,80000baa <kalloc>
    80005958:	85aa                	mv	a1,a0
    8000595a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000595e:	cd01                	beqz	a0,80005976 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005960:	6605                	lui	a2,0x1
    80005962:	e3043503          	ld	a0,-464(s0)
    80005966:	954fd0ef          	jal	ra,80002aba <fetchstr>
    8000596a:	00054663          	bltz	a0,80005976 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    8000596e:	0905                	addi	s2,s2,1
    80005970:	09a1                	addi	s3,s3,8
    80005972:	fd4911e3          	bne	s2,s4,80005934 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005976:	f4040913          	addi	s2,s0,-192
    8000597a:	6088                	ld	a0,0(s1)
    8000597c:	c129                	beqz	a0,800059be <sys_exec+0xd6>
    kfree(argv[i]);
    8000597e:	8fcfb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005982:	04a1                	addi	s1,s1,8
    80005984:	ff249be3          	bne	s1,s2,8000597a <sys_exec+0x92>
  return -1;
    80005988:	557d                	li	a0,-1
    8000598a:	a81d                	j	800059c0 <sys_exec+0xd8>
      argv[i] = 0;
    8000598c:	0a8e                	slli	s5,s5,0x3
    8000598e:	fc0a8793          	addi	a5,s5,-64
    80005992:	00878ab3          	add	s5,a5,s0
    80005996:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    8000599a:	e4040593          	addi	a1,s0,-448
    8000599e:	f4040513          	addi	a0,s0,-192
    800059a2:	bacff0ef          	jal	ra,80004d4e <kexec>
    800059a6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059a8:	f4040993          	addi	s3,s0,-192
    800059ac:	6088                	ld	a0,0(s1)
    800059ae:	c511                	beqz	a0,800059ba <sys_exec+0xd2>
    kfree(argv[i]);
    800059b0:	8cafb0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059b4:	04a1                	addi	s1,s1,8
    800059b6:	ff349be3          	bne	s1,s3,800059ac <sys_exec+0xc4>
  return ret;
    800059ba:	854a                	mv	a0,s2
    800059bc:	a011                	j	800059c0 <sys_exec+0xd8>
  return -1;
    800059be:	557d                	li	a0,-1
}
    800059c0:	60be                	ld	ra,456(sp)
    800059c2:	641e                	ld	s0,448(sp)
    800059c4:	74fa                	ld	s1,440(sp)
    800059c6:	795a                	ld	s2,432(sp)
    800059c8:	79ba                	ld	s3,424(sp)
    800059ca:	7a1a                	ld	s4,416(sp)
    800059cc:	6afa                	ld	s5,408(sp)
    800059ce:	6179                	addi	sp,sp,464
    800059d0:	8082                	ret

00000000800059d2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800059d2:	7139                	addi	sp,sp,-64
    800059d4:	fc06                	sd	ra,56(sp)
    800059d6:	f822                	sd	s0,48(sp)
    800059d8:	f426                	sd	s1,40(sp)
    800059da:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059dc:	95cfc0ef          	jal	ra,80001b38 <myproc>
    800059e0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800059e2:	fd840593          	addi	a1,s0,-40
    800059e6:	4501                	li	a0,0
    800059e8:	92efd0ef          	jal	ra,80002b16 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800059ec:	fc840593          	addi	a1,s0,-56
    800059f0:	fd040513          	addi	a0,s0,-48
    800059f4:	87aff0ef          	jal	ra,80004a6e <pipealloc>
    return -1;
    800059f8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800059fa:	0a054463          	bltz	a0,80005aa2 <sys_pipe+0xd0>
  fd0 = -1;
    800059fe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a02:	fd043503          	ld	a0,-48(s0)
    80005a06:	f3cff0ef          	jal	ra,80005142 <fdalloc>
    80005a0a:	fca42223          	sw	a0,-60(s0)
    80005a0e:	08054163          	bltz	a0,80005a90 <sys_pipe+0xbe>
    80005a12:	fc843503          	ld	a0,-56(s0)
    80005a16:	f2cff0ef          	jal	ra,80005142 <fdalloc>
    80005a1a:	fca42023          	sw	a0,-64(s0)
    80005a1e:	06054063          	bltz	a0,80005a7e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a22:	4691                	li	a3,4
    80005a24:	fc440613          	addi	a2,s0,-60
    80005a28:	fd843583          	ld	a1,-40(s0)
    80005a2c:	68a8                	ld	a0,80(s1)
    80005a2e:	d3dfb0ef          	jal	ra,8000176a <copyout>
    80005a32:	00054e63          	bltz	a0,80005a4e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a36:	4691                	li	a3,4
    80005a38:	fc040613          	addi	a2,s0,-64
    80005a3c:	fd843583          	ld	a1,-40(s0)
    80005a40:	0591                	addi	a1,a1,4
    80005a42:	68a8                	ld	a0,80(s1)
    80005a44:	d27fb0ef          	jal	ra,8000176a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a48:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a4a:	04055c63          	bgez	a0,80005aa2 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005a4e:	fc442783          	lw	a5,-60(s0)
    80005a52:	07e9                	addi	a5,a5,26
    80005a54:	078e                	slli	a5,a5,0x3
    80005a56:	97a6                	add	a5,a5,s1
    80005a58:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a5c:	fc042783          	lw	a5,-64(s0)
    80005a60:	07e9                	addi	a5,a5,26
    80005a62:	078e                	slli	a5,a5,0x3
    80005a64:	94be                	add	s1,s1,a5
    80005a66:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005a6a:	fd043503          	ld	a0,-48(s0)
    80005a6e:	d35fe0ef          	jal	ra,800047a2 <fileclose>
    fileclose(wf);
    80005a72:	fc843503          	ld	a0,-56(s0)
    80005a76:	d2dfe0ef          	jal	ra,800047a2 <fileclose>
    return -1;
    80005a7a:	57fd                	li	a5,-1
    80005a7c:	a01d                	j	80005aa2 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005a7e:	fc442783          	lw	a5,-60(s0)
    80005a82:	0007c763          	bltz	a5,80005a90 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005a86:	07e9                	addi	a5,a5,26
    80005a88:	078e                	slli	a5,a5,0x3
    80005a8a:	97a6                	add	a5,a5,s1
    80005a8c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005a90:	fd043503          	ld	a0,-48(s0)
    80005a94:	d0ffe0ef          	jal	ra,800047a2 <fileclose>
    fileclose(wf);
    80005a98:	fc843503          	ld	a0,-56(s0)
    80005a9c:	d07fe0ef          	jal	ra,800047a2 <fileclose>
    return -1;
    80005aa0:	57fd                	li	a5,-1
}
    80005aa2:	853e                	mv	a0,a5
    80005aa4:	70e2                	ld	ra,56(sp)
    80005aa6:	7442                	ld	s0,48(sp)
    80005aa8:	74a2                	ld	s1,40(sp)
    80005aaa:	6121                	addi	sp,sp,64
    80005aac:	8082                	ret
	...

0000000080005ab0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005ab0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005ab2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005ab4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005ab6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005ab8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005aba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005abc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005abe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005ac0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005ac2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005ac4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005ac6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005ac8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005aca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005acc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005ace:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005ad0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005ad2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005ad4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005ad6:	eabfc0ef          	jal	ra,80002980 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005ada:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005adc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005ade:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005ae0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005ae2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005ae4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005ae6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005ae8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005aea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005aec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005aee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005af0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005af2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005af4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005af6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005af8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005afa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005afc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005afe:	10200073          	sret
	...

0000000080005b0e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b0e:	1141                	addi	sp,sp,-16
    80005b10:	e422                	sd	s0,8(sp)
    80005b12:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005b14:	0c0007b7          	lui	a5,0xc000
    80005b18:	4705                	li	a4,1
    80005b1a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005b1c:	c3d8                	sw	a4,4(a5)
}
    80005b1e:	6422                	ld	s0,8(sp)
    80005b20:	0141                	addi	sp,sp,16
    80005b22:	8082                	ret

0000000080005b24 <plicinithart>:

void
plicinithart(void)
{
    80005b24:	1141                	addi	sp,sp,-16
    80005b26:	e406                	sd	ra,8(sp)
    80005b28:	e022                	sd	s0,0(sp)
    80005b2a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b2c:	fe1fb0ef          	jal	ra,80001b0c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005b30:	0085171b          	slliw	a4,a0,0x8
    80005b34:	0c0027b7          	lui	a5,0xc002
    80005b38:	97ba                	add	a5,a5,a4
    80005b3a:	40200713          	li	a4,1026
    80005b3e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005b42:	00d5151b          	slliw	a0,a0,0xd
    80005b46:	0c2017b7          	lui	a5,0xc201
    80005b4a:	97aa                	add	a5,a5,a0
    80005b4c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005b50:	60a2                	ld	ra,8(sp)
    80005b52:	6402                	ld	s0,0(sp)
    80005b54:	0141                	addi	sp,sp,16
    80005b56:	8082                	ret

0000000080005b58 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005b58:	1141                	addi	sp,sp,-16
    80005b5a:	e406                	sd	ra,8(sp)
    80005b5c:	e022                	sd	s0,0(sp)
    80005b5e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b60:	fadfb0ef          	jal	ra,80001b0c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005b64:	00d5151b          	slliw	a0,a0,0xd
    80005b68:	0c2017b7          	lui	a5,0xc201
    80005b6c:	97aa                	add	a5,a5,a0
  return irq;
}
    80005b6e:	43c8                	lw	a0,4(a5)
    80005b70:	60a2                	ld	ra,8(sp)
    80005b72:	6402                	ld	s0,0(sp)
    80005b74:	0141                	addi	sp,sp,16
    80005b76:	8082                	ret

0000000080005b78 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005b78:	1101                	addi	sp,sp,-32
    80005b7a:	ec06                	sd	ra,24(sp)
    80005b7c:	e822                	sd	s0,16(sp)
    80005b7e:	e426                	sd	s1,8(sp)
    80005b80:	1000                	addi	s0,sp,32
    80005b82:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005b84:	f89fb0ef          	jal	ra,80001b0c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005b88:	00d5151b          	slliw	a0,a0,0xd
    80005b8c:	0c2017b7          	lui	a5,0xc201
    80005b90:	97aa                	add	a5,a5,a0
    80005b92:	c3c4                	sw	s1,4(a5)
}
    80005b94:	60e2                	ld	ra,24(sp)
    80005b96:	6442                	ld	s0,16(sp)
    80005b98:	64a2                	ld	s1,8(sp)
    80005b9a:	6105                	addi	sp,sp,32
    80005b9c:	8082                	ret

0000000080005b9e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005b9e:	1141                	addi	sp,sp,-16
    80005ba0:	e406                	sd	ra,8(sp)
    80005ba2:	e022                	sd	s0,0(sp)
    80005ba4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005ba6:	479d                	li	a5,7
    80005ba8:	04a7ca63          	blt	a5,a0,80005bfc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005bac:	00246797          	auipc	a5,0x246
    80005bb0:	ed478793          	addi	a5,a5,-300 # 8024ba80 <disk>
    80005bb4:	97aa                	add	a5,a5,a0
    80005bb6:	0187c783          	lbu	a5,24(a5)
    80005bba:	e7b9                	bnez	a5,80005c08 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005bbc:	00451693          	slli	a3,a0,0x4
    80005bc0:	00246797          	auipc	a5,0x246
    80005bc4:	ec078793          	addi	a5,a5,-320 # 8024ba80 <disk>
    80005bc8:	6398                	ld	a4,0(a5)
    80005bca:	9736                	add	a4,a4,a3
    80005bcc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005bd0:	6398                	ld	a4,0(a5)
    80005bd2:	9736                	add	a4,a4,a3
    80005bd4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005bd8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005bdc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005be0:	97aa                	add	a5,a5,a0
    80005be2:	4705                	li	a4,1
    80005be4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005be8:	00246517          	auipc	a0,0x246
    80005bec:	eb050513          	addi	a0,a0,-336 # 8024ba98 <disk+0x18>
    80005bf0:	e1efc0ef          	jal	ra,8000220e <wakeup>
}
    80005bf4:	60a2                	ld	ra,8(sp)
    80005bf6:	6402                	ld	s0,0(sp)
    80005bf8:	0141                	addi	sp,sp,16
    80005bfa:	8082                	ret
    panic("free_desc 1");
    80005bfc:	00003517          	auipc	a0,0x3
    80005c00:	b3c50513          	addi	a0,a0,-1220 # 80008738 <syscalls+0x340>
    80005c04:	b85fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005c08:	00003517          	auipc	a0,0x3
    80005c0c:	b4050513          	addi	a0,a0,-1216 # 80008748 <syscalls+0x350>
    80005c10:	b79fa0ef          	jal	ra,80000788 <panic>

0000000080005c14 <virtio_disk_init>:
{
    80005c14:	1101                	addi	sp,sp,-32
    80005c16:	ec06                	sd	ra,24(sp)
    80005c18:	e822                	sd	s0,16(sp)
    80005c1a:	e426                	sd	s1,8(sp)
    80005c1c:	e04a                	sd	s2,0(sp)
    80005c1e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005c20:	00003597          	auipc	a1,0x3
    80005c24:	b3858593          	addi	a1,a1,-1224 # 80008758 <syscalls+0x360>
    80005c28:	00246517          	auipc	a0,0x246
    80005c2c:	f8050513          	addi	a0,a0,-128 # 8024bba8 <disk+0x128>
    80005c30:	ff1fa0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005c34:	100017b7          	lui	a5,0x10001
    80005c38:	4398                	lw	a4,0(a5)
    80005c3a:	2701                	sext.w	a4,a4
    80005c3c:	747277b7          	lui	a5,0x74727
    80005c40:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005c44:	12f71f63          	bne	a4,a5,80005d82 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005c48:	100017b7          	lui	a5,0x10001
    80005c4c:	43dc                	lw	a5,4(a5)
    80005c4e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005c50:	4709                	li	a4,2
    80005c52:	12e79863          	bne	a5,a4,80005d82 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005c56:	100017b7          	lui	a5,0x10001
    80005c5a:	479c                	lw	a5,8(a5)
    80005c5c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005c5e:	12e79263          	bne	a5,a4,80005d82 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005c62:	100017b7          	lui	a5,0x10001
    80005c66:	47d8                	lw	a4,12(a5)
    80005c68:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005c6a:	554d47b7          	lui	a5,0x554d4
    80005c6e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005c72:	10f71863          	bne	a4,a5,80005d82 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c76:	100017b7          	lui	a5,0x10001
    80005c7a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c7e:	4705                	li	a4,1
    80005c80:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c82:	470d                	li	a4,3
    80005c84:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005c86:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005c88:	c7ffe6b7          	lui	a3,0xc7ffe
    80005c8c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47daaa07>
    80005c90:	8f75                	and	a4,a4,a3
    80005c92:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c94:	472d                	li	a4,11
    80005c96:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005c98:	5bbc                	lw	a5,112(a5)
    80005c9a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005c9e:	8ba1                	andi	a5,a5,8
    80005ca0:	0e078763          	beqz	a5,80005d8e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ca4:	100017b7          	lui	a5,0x10001
    80005ca8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005cac:	43fc                	lw	a5,68(a5)
    80005cae:	2781                	sext.w	a5,a5
    80005cb0:	0e079563          	bnez	a5,80005d9a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005cb4:	100017b7          	lui	a5,0x10001
    80005cb8:	5bdc                	lw	a5,52(a5)
    80005cba:	2781                	sext.w	a5,a5
  if(max == 0)
    80005cbc:	0e078563          	beqz	a5,80005da6 <virtio_disk_init+0x192>
  if(max < NUM)
    80005cc0:	471d                	li	a4,7
    80005cc2:	0ef77863          	bgeu	a4,a5,80005db2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80005cc6:	ee5fa0ef          	jal	ra,80000baa <kalloc>
    80005cca:	00246497          	auipc	s1,0x246
    80005cce:	db648493          	addi	s1,s1,-586 # 8024ba80 <disk>
    80005cd2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005cd4:	ed7fa0ef          	jal	ra,80000baa <kalloc>
    80005cd8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005cda:	ed1fa0ef          	jal	ra,80000baa <kalloc>
    80005cde:	87aa                	mv	a5,a0
    80005ce0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ce2:	6088                	ld	a0,0(s1)
    80005ce4:	cd69                	beqz	a0,80005dbe <virtio_disk_init+0x1aa>
    80005ce6:	00246717          	auipc	a4,0x246
    80005cea:	da273703          	ld	a4,-606(a4) # 8024ba88 <disk+0x8>
    80005cee:	cb61                	beqz	a4,80005dbe <virtio_disk_init+0x1aa>
    80005cf0:	c7f9                	beqz	a5,80005dbe <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80005cf2:	6605                	lui	a2,0x1
    80005cf4:	4581                	li	a1,0
    80005cf6:	87efb0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005cfa:	00246497          	auipc	s1,0x246
    80005cfe:	d8648493          	addi	s1,s1,-634 # 8024ba80 <disk>
    80005d02:	6605                	lui	a2,0x1
    80005d04:	4581                	li	a1,0
    80005d06:	6488                	ld	a0,8(s1)
    80005d08:	86cfb0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    80005d0c:	6605                	lui	a2,0x1
    80005d0e:	4581                	li	a1,0
    80005d10:	6888                	ld	a0,16(s1)
    80005d12:	862fb0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d16:	100017b7          	lui	a5,0x10001
    80005d1a:	4721                	li	a4,8
    80005d1c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005d1e:	4098                	lw	a4,0(s1)
    80005d20:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005d24:	40d8                	lw	a4,4(s1)
    80005d26:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005d2a:	6498                	ld	a4,8(s1)
    80005d2c:	0007069b          	sext.w	a3,a4
    80005d30:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005d34:	9701                	srai	a4,a4,0x20
    80005d36:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005d3a:	6898                	ld	a4,16(s1)
    80005d3c:	0007069b          	sext.w	a3,a4
    80005d40:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005d44:	9701                	srai	a4,a4,0x20
    80005d46:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005d4a:	4705                	li	a4,1
    80005d4c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005d4e:	00e48c23          	sb	a4,24(s1)
    80005d52:	00e48ca3          	sb	a4,25(s1)
    80005d56:	00e48d23          	sb	a4,26(s1)
    80005d5a:	00e48da3          	sb	a4,27(s1)
    80005d5e:	00e48e23          	sb	a4,28(s1)
    80005d62:	00e48ea3          	sb	a4,29(s1)
    80005d66:	00e48f23          	sb	a4,30(s1)
    80005d6a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005d6e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d72:	0727a823          	sw	s2,112(a5)
}
    80005d76:	60e2                	ld	ra,24(sp)
    80005d78:	6442                	ld	s0,16(sp)
    80005d7a:	64a2                	ld	s1,8(sp)
    80005d7c:	6902                	ld	s2,0(sp)
    80005d7e:	6105                	addi	sp,sp,32
    80005d80:	8082                	ret
    panic("could not find virtio disk");
    80005d82:	00003517          	auipc	a0,0x3
    80005d86:	9e650513          	addi	a0,a0,-1562 # 80008768 <syscalls+0x370>
    80005d8a:	9fffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005d8e:	00003517          	auipc	a0,0x3
    80005d92:	9fa50513          	addi	a0,a0,-1542 # 80008788 <syscalls+0x390>
    80005d96:	9f3fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    80005d9a:	00003517          	auipc	a0,0x3
    80005d9e:	a0e50513          	addi	a0,a0,-1522 # 800087a8 <syscalls+0x3b0>
    80005da2:	9e7fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80005da6:	00003517          	auipc	a0,0x3
    80005daa:	a2250513          	addi	a0,a0,-1502 # 800087c8 <syscalls+0x3d0>
    80005dae:	9dbfa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80005db2:	00003517          	auipc	a0,0x3
    80005db6:	a3650513          	addi	a0,a0,-1482 # 800087e8 <syscalls+0x3f0>
    80005dba:	9cffa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    80005dbe:	00003517          	auipc	a0,0x3
    80005dc2:	a4a50513          	addi	a0,a0,-1462 # 80008808 <syscalls+0x410>
    80005dc6:	9c3fa0ef          	jal	ra,80000788 <panic>

0000000080005dca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005dca:	7119                	addi	sp,sp,-128
    80005dcc:	fc86                	sd	ra,120(sp)
    80005dce:	f8a2                	sd	s0,112(sp)
    80005dd0:	f4a6                	sd	s1,104(sp)
    80005dd2:	f0ca                	sd	s2,96(sp)
    80005dd4:	ecce                	sd	s3,88(sp)
    80005dd6:	e8d2                	sd	s4,80(sp)
    80005dd8:	e4d6                	sd	s5,72(sp)
    80005dda:	e0da                	sd	s6,64(sp)
    80005ddc:	fc5e                	sd	s7,56(sp)
    80005dde:	f862                	sd	s8,48(sp)
    80005de0:	f466                	sd	s9,40(sp)
    80005de2:	f06a                	sd	s10,32(sp)
    80005de4:	ec6e                	sd	s11,24(sp)
    80005de6:	0100                	addi	s0,sp,128
    80005de8:	8aaa                	mv	s5,a0
    80005dea:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005dec:	00c52d03          	lw	s10,12(a0)
    80005df0:	001d1d1b          	slliw	s10,s10,0x1
    80005df4:	1d02                	slli	s10,s10,0x20
    80005df6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005dfa:	00246517          	auipc	a0,0x246
    80005dfe:	dae50513          	addi	a0,a0,-594 # 8024bba8 <disk+0x128>
    80005e02:	e9ffa0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80005e06:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005e08:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005e0a:	00246b97          	auipc	s7,0x246
    80005e0e:	c76b8b93          	addi	s7,s7,-906 # 8024ba80 <disk>
  for(int i = 0; i < 3; i++){
    80005e12:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005e14:	00246c97          	auipc	s9,0x246
    80005e18:	d94c8c93          	addi	s9,s9,-620 # 8024bba8 <disk+0x128>
    80005e1c:	a8a9                	j	80005e76 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005e1e:	00fb8733          	add	a4,s7,a5
    80005e22:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005e26:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005e28:	0207c563          	bltz	a5,80005e52 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005e2c:	2905                	addiw	s2,s2,1
    80005e2e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005e30:	05690863          	beq	s2,s6,80005e80 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005e34:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005e36:	00246717          	auipc	a4,0x246
    80005e3a:	c4a70713          	addi	a4,a4,-950 # 8024ba80 <disk>
    80005e3e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005e40:	01874683          	lbu	a3,24(a4)
    80005e44:	fee9                	bnez	a3,80005e1e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005e46:	2785                	addiw	a5,a5,1
    80005e48:	0705                	addi	a4,a4,1
    80005e4a:	fe979be3          	bne	a5,s1,80005e40 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005e4e:	57fd                	li	a5,-1
    80005e50:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005e52:	01205b63          	blez	s2,80005e68 <virtio_disk_rw+0x9e>
    80005e56:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005e58:	000a2503          	lw	a0,0(s4)
    80005e5c:	d43ff0ef          	jal	ra,80005b9e <free_desc>
      for(int j = 0; j < i; j++)
    80005e60:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    80005e62:	0a11                	addi	s4,s4,4
    80005e64:	ff2d9ae3          	bne	s11,s2,80005e58 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005e68:	85e6                	mv	a1,s9
    80005e6a:	00246517          	auipc	a0,0x246
    80005e6e:	c2e50513          	addi	a0,a0,-978 # 8024ba98 <disk+0x18>
    80005e72:	b50fc0ef          	jal	ra,800021c2 <sleep>
  for(int i = 0; i < 3; i++){
    80005e76:	f8040a13          	addi	s4,s0,-128
{
    80005e7a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005e7c:	894e                	mv	s2,s3
    80005e7e:	bf5d                	j	80005e34 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005e80:	f8042503          	lw	a0,-128(s0)
    80005e84:	00a50713          	addi	a4,a0,10
    80005e88:	0712                	slli	a4,a4,0x4

  if(write)
    80005e8a:	00246797          	auipc	a5,0x246
    80005e8e:	bf678793          	addi	a5,a5,-1034 # 8024ba80 <disk>
    80005e92:	00e786b3          	add	a3,a5,a4
    80005e96:	01803633          	snez	a2,s8
    80005e9a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005e9c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005ea0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ea4:	f6070613          	addi	a2,a4,-160
    80005ea8:	6394                	ld	a3,0(a5)
    80005eaa:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005eac:	00870593          	addi	a1,a4,8
    80005eb0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005eb2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005eb4:	0007b803          	ld	a6,0(a5)
    80005eb8:	9642                	add	a2,a2,a6
    80005eba:	46c1                	li	a3,16
    80005ebc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ebe:	4585                	li	a1,1
    80005ec0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005ec4:	f8442683          	lw	a3,-124(s0)
    80005ec8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005ecc:	0692                	slli	a3,a3,0x4
    80005ece:	9836                	add	a6,a6,a3
    80005ed0:	058a8613          	addi	a2,s5,88
    80005ed4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005ed8:	0007b803          	ld	a6,0(a5)
    80005edc:	96c2                	add	a3,a3,a6
    80005ede:	40000613          	li	a2,1024
    80005ee2:	c690                	sw	a2,8(a3)
  if(write)
    80005ee4:	001c3613          	seqz	a2,s8
    80005ee8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005eec:	00166613          	ori	a2,a2,1
    80005ef0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005ef4:	f8842603          	lw	a2,-120(s0)
    80005ef8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005efc:	00250693          	addi	a3,a0,2
    80005f00:	0692                	slli	a3,a3,0x4
    80005f02:	96be                	add	a3,a3,a5
    80005f04:	58fd                	li	a7,-1
    80005f06:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f0a:	0612                	slli	a2,a2,0x4
    80005f0c:	9832                	add	a6,a6,a2
    80005f0e:	f9070713          	addi	a4,a4,-112
    80005f12:	973e                	add	a4,a4,a5
    80005f14:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005f18:	6398                	ld	a4,0(a5)
    80005f1a:	9732                	add	a4,a4,a2
    80005f1c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f1e:	4609                	li	a2,2
    80005f20:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005f24:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005f28:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005f2c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005f30:	6794                	ld	a3,8(a5)
    80005f32:	0026d703          	lhu	a4,2(a3)
    80005f36:	8b1d                	andi	a4,a4,7
    80005f38:	0706                	slli	a4,a4,0x1
    80005f3a:	96ba                	add	a3,a3,a4
    80005f3c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005f40:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005f44:	6798                	ld	a4,8(a5)
    80005f46:	00275783          	lhu	a5,2(a4)
    80005f4a:	2785                	addiw	a5,a5,1
    80005f4c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005f50:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005f54:	100017b7          	lui	a5,0x10001
    80005f58:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005f5c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005f60:	00246917          	auipc	s2,0x246
    80005f64:	c4890913          	addi	s2,s2,-952 # 8024bba8 <disk+0x128>
  while(b->disk == 1) {
    80005f68:	4485                	li	s1,1
    80005f6a:	00b79a63          	bne	a5,a1,80005f7e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005f6e:	85ca                	mv	a1,s2
    80005f70:	8556                	mv	a0,s5
    80005f72:	a50fc0ef          	jal	ra,800021c2 <sleep>
  while(b->disk == 1) {
    80005f76:	004aa783          	lw	a5,4(s5)
    80005f7a:	fe978ae3          	beq	a5,s1,80005f6e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005f7e:	f8042903          	lw	s2,-128(s0)
    80005f82:	00290713          	addi	a4,s2,2
    80005f86:	0712                	slli	a4,a4,0x4
    80005f88:	00246797          	auipc	a5,0x246
    80005f8c:	af878793          	addi	a5,a5,-1288 # 8024ba80 <disk>
    80005f90:	97ba                	add	a5,a5,a4
    80005f92:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005f96:	00246997          	auipc	s3,0x246
    80005f9a:	aea98993          	addi	s3,s3,-1302 # 8024ba80 <disk>
    80005f9e:	00491713          	slli	a4,s2,0x4
    80005fa2:	0009b783          	ld	a5,0(s3)
    80005fa6:	97ba                	add	a5,a5,a4
    80005fa8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005fac:	854a                	mv	a0,s2
    80005fae:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005fb2:	bedff0ef          	jal	ra,80005b9e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005fb6:	8885                	andi	s1,s1,1
    80005fb8:	f0fd                	bnez	s1,80005f9e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005fba:	00246517          	auipc	a0,0x246
    80005fbe:	bee50513          	addi	a0,a0,-1042 # 8024bba8 <disk+0x128>
    80005fc2:	d77fa0ef          	jal	ra,80000d38 <release>
}
    80005fc6:	70e6                	ld	ra,120(sp)
    80005fc8:	7446                	ld	s0,112(sp)
    80005fca:	74a6                	ld	s1,104(sp)
    80005fcc:	7906                	ld	s2,96(sp)
    80005fce:	69e6                	ld	s3,88(sp)
    80005fd0:	6a46                	ld	s4,80(sp)
    80005fd2:	6aa6                	ld	s5,72(sp)
    80005fd4:	6b06                	ld	s6,64(sp)
    80005fd6:	7be2                	ld	s7,56(sp)
    80005fd8:	7c42                	ld	s8,48(sp)
    80005fda:	7ca2                	ld	s9,40(sp)
    80005fdc:	7d02                	ld	s10,32(sp)
    80005fde:	6de2                	ld	s11,24(sp)
    80005fe0:	6109                	addi	sp,sp,128
    80005fe2:	8082                	ret

0000000080005fe4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005fe4:	1101                	addi	sp,sp,-32
    80005fe6:	ec06                	sd	ra,24(sp)
    80005fe8:	e822                	sd	s0,16(sp)
    80005fea:	e426                	sd	s1,8(sp)
    80005fec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005fee:	00246497          	auipc	s1,0x246
    80005ff2:	a9248493          	addi	s1,s1,-1390 # 8024ba80 <disk>
    80005ff6:	00246517          	auipc	a0,0x246
    80005ffa:	bb250513          	addi	a0,a0,-1102 # 8024bba8 <disk+0x128>
    80005ffe:	ca3fa0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006002:	10001737          	lui	a4,0x10001
    80006006:	533c                	lw	a5,96(a4)
    80006008:	8b8d                	andi	a5,a5,3
    8000600a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000600c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006010:	689c                	ld	a5,16(s1)
    80006012:	0204d703          	lhu	a4,32(s1)
    80006016:	0027d783          	lhu	a5,2(a5)
    8000601a:	04f70663          	beq	a4,a5,80006066 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000601e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006022:	6898                	ld	a4,16(s1)
    80006024:	0204d783          	lhu	a5,32(s1)
    80006028:	8b9d                	andi	a5,a5,7
    8000602a:	078e                	slli	a5,a5,0x3
    8000602c:	97ba                	add	a5,a5,a4
    8000602e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006030:	00278713          	addi	a4,a5,2
    80006034:	0712                	slli	a4,a4,0x4
    80006036:	9726                	add	a4,a4,s1
    80006038:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000603c:	e321                	bnez	a4,8000607c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000603e:	0789                	addi	a5,a5,2
    80006040:	0792                	slli	a5,a5,0x4
    80006042:	97a6                	add	a5,a5,s1
    80006044:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006046:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000604a:	9c4fc0ef          	jal	ra,8000220e <wakeup>

    disk.used_idx += 1;
    8000604e:	0204d783          	lhu	a5,32(s1)
    80006052:	2785                	addiw	a5,a5,1
    80006054:	17c2                	slli	a5,a5,0x30
    80006056:	93c1                	srli	a5,a5,0x30
    80006058:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000605c:	6898                	ld	a4,16(s1)
    8000605e:	00275703          	lhu	a4,2(a4)
    80006062:	faf71ee3          	bne	a4,a5,8000601e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80006066:	00246517          	auipc	a0,0x246
    8000606a:	b4250513          	addi	a0,a0,-1214 # 8024bba8 <disk+0x128>
    8000606e:	ccbfa0ef          	jal	ra,80000d38 <release>
}
    80006072:	60e2                	ld	ra,24(sp)
    80006074:	6442                	ld	s0,16(sp)
    80006076:	64a2                	ld	s1,8(sp)
    80006078:	6105                	addi	sp,sp,32
    8000607a:	8082                	ret
      panic("virtio_disk_intr status");
    8000607c:	00002517          	auipc	a0,0x2
    80006080:	7a450513          	addi	a0,a0,1956 # 80008820 <syscalls+0x428>
    80006084:	f04fa0ef          	jal	ra,80000788 <panic>

0000000080006088 <shm_init>:
  struct shmobj obj[NSHM];
} shmt;

void
shm_init(void)
{
    80006088:	1141                	addi	sp,sp,-16
    8000608a:	e406                	sd	ra,8(sp)
    8000608c:	e022                	sd	s0,0(sp)
    8000608e:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    80006090:	00002597          	auipc	a1,0x2
    80006094:	7a858593          	addi	a1,a1,1960 # 80008838 <syscalls+0x440>
    80006098:	00246517          	auipc	a0,0x246
    8000609c:	b2850513          	addi	a0,a0,-1240 # 8024bbc0 <shmt>
    800060a0:	b81fa0ef          	jal	ra,80000c20 <initlock>
}
    800060a4:	60a2                	ld	ra,8(sp)
    800060a6:	6402                	ld	s0,0(sp)
    800060a8:	0141                	addi	sp,sp,16
    800060aa:	8082                	ret

00000000800060ac <shm_get>:

// 找到或创建 key 对应对象，返回 index；失败返回 -1
int
shm_get(int key, int npages)
{
    800060ac:	7179                	addi	sp,sp,-48
    800060ae:	f406                	sd	ra,40(sp)
    800060b0:	f022                	sd	s0,32(sp)
    800060b2:	ec26                	sd	s1,24(sp)
    800060b4:	e84a                	sd	s2,16(sp)
    800060b6:	e44e                	sd	s3,8(sp)
    800060b8:	1800                	addi	s0,sp,48
    800060ba:	89aa                	mv	s3,a0
    800060bc:	892e                	mv	s2,a1
  acquire(&shmt.lock);
    800060be:	00246517          	auipc	a0,0x246
    800060c2:	b0250513          	addi	a0,a0,-1278 # 8024bbc0 <shmt>
    800060c6:	bdbfa0ef          	jal	ra,80000ca0 <acquire>

  // 先找已有
  for(int i=0;i<NSHM;i++){
    800060ca:	00246697          	auipc	a3,0x246
    800060ce:	b0e68693          	addi	a3,a3,-1266 # 8024bbd8 <shmt+0x18>
  acquire(&shmt.lock);
    800060d2:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    800060d4:	4481                	li	s1,0
    800060d6:	6605                	lui	a2,0x1
    800060d8:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    800060dc:	45c1                	li	a1,16
    800060de:	a811                	j	800060f2 <shm_get+0x46>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    800060e0:	853a                	mv	a0,a4
    800060e2:	c57fa0ef          	jal	ra,80000d38 <release>
        return -1;
    800060e6:	54fd                	li	s1,-1
    800060e8:	a8a5                	j	80006160 <shm_get+0xb4>
  for(int i=0;i<NSHM;i++){
    800060ea:	2485                	addiw	s1,s1,1
    800060ec:	97b2                	add	a5,a5,a2
    800060ee:	04b48763          	beq	s1,a1,8000613c <shm_get+0x90>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    800060f2:	4398                	lw	a4,0(a5)
    800060f4:	db7d                	beqz	a4,800060ea <shm_get+0x3e>
    800060f6:	43d8                	lw	a4,4(a5)
    800060f8:	ff3719e3          	bne	a4,s3,800060ea <shm_get+0x3e>
      if(npages > shmt.obj[i].npages){
    800060fc:	6785                	lui	a5,0x1
    800060fe:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006102:	02f487b3          	mul	a5,s1,a5
    80006106:	00246717          	auipc	a4,0x246
    8000610a:	aba70713          	addi	a4,a4,-1350 # 8024bbc0 <shmt>
    8000610e:	97ba                	add	a5,a5,a4
    80006110:	539c                	lw	a5,32(a5)
    80006112:	fd27c7e3          	blt	a5,s2,800060e0 <shm_get+0x34>
      }
      shmt.obj[i].refcnt++;
    80006116:	00246517          	auipc	a0,0x246
    8000611a:	aaa50513          	addi	a0,a0,-1366 # 8024bbc0 <shmt>
    8000611e:	6785                	lui	a5,0x1
    80006120:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006124:	02e48733          	mul	a4,s1,a4
    80006128:	972a                	add	a4,a4,a0
    8000612a:	97ba                	add	a5,a5,a4
    8000612c:	8287a703          	lw	a4,-2008(a5)
    80006130:	2705                	addiw	a4,a4,1
    80006132:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    80006136:	c03fa0ef          	jal	ra,80000d38 <release>
      return i;
    8000613a:	a01d                	j	80006160 <shm_get+0xb4>
    }
  }

  // 再创建
  for(int i=0;i<NSHM;i++){
    8000613c:	4481                	li	s1,0
    8000613e:	6705                	lui	a4,0x1
    80006140:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006144:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    80006146:	429c                	lw	a5,0(a3)
    80006148:	c785                	beqz	a5,80006170 <shm_get+0xc4>
  for(int i=0;i<NSHM;i++){
    8000614a:	2485                	addiw	s1,s1,1
    8000614c:	96ba                	add	a3,a3,a4
    8000614e:	fec49ce3          	bne	s1,a2,80006146 <shm_get+0x9a>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    80006152:	00246517          	auipc	a0,0x246
    80006156:	a6e50513          	addi	a0,a0,-1426 # 8024bbc0 <shmt>
    8000615a:	bdffa0ef          	jal	ra,80000d38 <release>
  return -1;
    8000615e:	54fd                	li	s1,-1
}
    80006160:	8526                	mv	a0,s1
    80006162:	70a2                	ld	ra,40(sp)
    80006164:	7402                	ld	s0,32(sp)
    80006166:	64e2                	ld	s1,24(sp)
    80006168:	6942                	ld	s2,16(sp)
    8000616a:	69a2                	ld	s3,8(sp)
    8000616c:	6145                	addi	sp,sp,48
    8000616e:	8082                	ret
      shmt.obj[i].used = 1;
    80006170:	6705                	lui	a4,0x1
    80006172:	81870693          	addi	a3,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006176:	02d486b3          	mul	a3,s1,a3
    8000617a:	00246797          	auipc	a5,0x246
    8000617e:	a4678793          	addi	a5,a5,-1466 # 8024bbc0 <shmt>
    80006182:	97b6                	add	a5,a5,a3
    80006184:	4685                	li	a3,1
    80006186:	cf94                	sw	a3,24(a5)
      shmt.obj[i].key = key;
    80006188:	0137ae23          	sw	s3,28(a5)
      shmt.obj[i].npages = npages;
    8000618c:	0327a023          	sw	s2,32(a5)
      shmt.obj[i].refcnt = 1;
    80006190:	973e                	add	a4,a4,a5
    80006192:	82d72423          	sw	a3,-2008(a4)
      for(int j=0;j<npages;j++) shmt.obj[i].pa[j] = 0;
    80006196:	05205163          	blez	s2,800061d8 <shm_get+0x12c>
    8000619a:	6785                	lui	a5,0x1
    8000619c:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800061a0:	02f487b3          	mul	a5,s1,a5
    800061a4:	00246717          	auipc	a4,0x246
    800061a8:	a4470713          	addi	a4,a4,-1468 # 8024bbe8 <shmt+0x28>
    800061ac:	97ba                	add	a5,a5,a4
    800061ae:	00649713          	slli	a4,s1,0x6
    800061b2:	9726                	add	a4,a4,s1
    800061b4:	070a                	slli	a4,a4,0x2
    800061b6:	8f05                	sub	a4,a4,s1
    800061b8:	397d                	addiw	s2,s2,-1
    800061ba:	1902                	slli	s2,s2,0x20
    800061bc:	02095913          	srli	s2,s2,0x20
    800061c0:	974a                	add	a4,a4,s2
    800061c2:	070e                	slli	a4,a4,0x3
    800061c4:	00246697          	auipc	a3,0x246
    800061c8:	a2c68693          	addi	a3,a3,-1492 # 8024bbf0 <shmt+0x30>
    800061cc:	9736                	add	a4,a4,a3
    800061ce:	0007b023          	sd	zero,0(a5)
    800061d2:	07a1                	addi	a5,a5,8
    800061d4:	fee79de3          	bne	a5,a4,800061ce <shm_get+0x122>
      release(&shmt.lock);
    800061d8:	00246517          	auipc	a0,0x246
    800061dc:	9e850513          	addi	a0,a0,-1560 # 8024bbc0 <shmt>
    800061e0:	b59fa0ef          	jal	ra,80000d38 <release>
      return i;
    800061e4:	bfb5                	j	80006160 <shm_get+0xb4>

00000000800061e6 <shm_put>:

// refcnt--，若为 0 则释放对象里的所有页（kfree 会走页 refcnt，安全）
void
shm_put(int key)
{
    800061e6:	7179                	addi	sp,sp,-48
    800061e8:	f406                	sd	ra,40(sp)
    800061ea:	f022                	sd	s0,32(sp)
    800061ec:	ec26                	sd	s1,24(sp)
    800061ee:	e84a                	sd	s2,16(sp)
    800061f0:	e44e                	sd	s3,8(sp)
    800061f2:	e052                	sd	s4,0(sp)
    800061f4:	1800                	addi	s0,sp,48
    800061f6:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    800061f8:	00246517          	auipc	a0,0x246
    800061fc:	9c850513          	addi	a0,a0,-1592 # 8024bbc0 <shmt>
    80006200:	aa1fa0ef          	jal	ra,80000ca0 <acquire>
  for(int i=0;i<NSHM;i++){
    80006204:	00246797          	auipc	a5,0x246
    80006208:	9d478793          	addi	a5,a5,-1580 # 8024bbd8 <shmt+0x18>
    8000620c:	4481                	li	s1,0
    8000620e:	6685                	lui	a3,0x1
    80006210:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006214:	4641                	li	a2,16
    80006216:	a8a9                	j	80006270 <shm_put+0x8a>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      shmt.obj[i].refcnt--;
      if(shmt.obj[i].refcnt == 0){
        for(int j=0;j<shmt.obj[i].npages;j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
    80006218:	863fa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    8000621c:	00093023          	sd	zero,0(s2)
        for(int j=0;j<shmt.obj[i].npages;j++){
    80006220:	2985                	addiw	s3,s3,1
    80006222:	0921                	addi	s2,s2,8
    80006224:	020a2783          	lw	a5,32(s4)
    80006228:	00f9d663          	bge	s3,a5,80006234 <shm_put+0x4e>
          if(shmt.obj[i].pa[j]){
    8000622c:	00093503          	ld	a0,0(s2)
    80006230:	d965                	beqz	a0,80006220 <shm_put+0x3a>
    80006232:	b7dd                	j	80006218 <shm_put+0x32>
          }
        }
        shmt.obj[i].used = 0;
    80006234:	6785                	lui	a5,0x1
    80006236:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000623a:	02f484b3          	mul	s1,s1,a5
    8000623e:	00246797          	auipc	a5,0x246
    80006242:	98278793          	addi	a5,a5,-1662 # 8024bbc0 <shmt>
    80006246:	97a6                	add	a5,a5,s1
    80006248:	0007ac23          	sw	zero,24(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    8000624c:	00246517          	auipc	a0,0x246
    80006250:	97450513          	addi	a0,a0,-1676 # 8024bbc0 <shmt>
    80006254:	ae5fa0ef          	jal	ra,80000d38 <release>
}
    80006258:	70a2                	ld	ra,40(sp)
    8000625a:	7402                	ld	s0,32(sp)
    8000625c:	64e2                	ld	s1,24(sp)
    8000625e:	6942                	ld	s2,16(sp)
    80006260:	69a2                	ld	s3,8(sp)
    80006262:	6a02                	ld	s4,0(sp)
    80006264:	6145                	addi	sp,sp,48
    80006266:	8082                	ret
  for(int i=0;i<NSHM;i++){
    80006268:	2485                	addiw	s1,s1,1
    8000626a:	97b6                	add	a5,a5,a3
    8000626c:	fec480e3          	beq	s1,a2,8000624c <shm_put+0x66>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006270:	4398                	lw	a4,0(a5)
    80006272:	db7d                	beqz	a4,80006268 <shm_put+0x82>
    80006274:	43d8                	lw	a4,4(a5)
    80006276:	ff2719e3          	bne	a4,s2,80006268 <shm_put+0x82>
      shmt.obj[i].refcnt--;
    8000627a:	6785                	lui	a5,0x1
    8000627c:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006280:	02d486b3          	mul	a3,s1,a3
    80006284:	00246717          	auipc	a4,0x246
    80006288:	93c70713          	addi	a4,a4,-1732 # 8024bbc0 <shmt>
    8000628c:	9736                	add	a4,a4,a3
    8000628e:	97ba                	add	a5,a5,a4
    80006290:	8287a703          	lw	a4,-2008(a5)
    80006294:	377d                	addiw	a4,a4,-1
    80006296:	0007099b          	sext.w	s3,a4
    8000629a:	82e7a423          	sw	a4,-2008(a5)
      if(shmt.obj[i].refcnt == 0){
    8000629e:	fa0997e3          	bnez	s3,8000624c <shm_put+0x66>
        for(int j=0;j<shmt.obj[i].npages;j++){
    800062a2:	00246717          	auipc	a4,0x246
    800062a6:	91e70713          	addi	a4,a4,-1762 # 8024bbc0 <shmt>
    800062aa:	00d707b3          	add	a5,a4,a3
    800062ae:	539c                	lw	a5,32(a5)
    800062b0:	f8f052e3          	blez	a5,80006234 <shm_put+0x4e>
    800062b4:	00246797          	auipc	a5,0x246
    800062b8:	93478793          	addi	a5,a5,-1740 # 8024bbe8 <shmt+0x28>
    800062bc:	00f68933          	add	s2,a3,a5
    800062c0:	00d70a33          	add	s4,a4,a3
    800062c4:	b7a5                	j	8000622c <shm_put+0x46>

00000000800062c6 <shm_getpa>:

// 取某页的 pa；若未分配则分配（lazy），返回 pa 或 0
uint64
shm_getpa(int key, int page_index)
{
    800062c6:	7179                	addi	sp,sp,-48
    800062c8:	f406                	sd	ra,40(sp)
    800062ca:	f022                	sd	s0,32(sp)
    800062cc:	ec26                	sd	s1,24(sp)
    800062ce:	e84a                	sd	s2,16(sp)
    800062d0:	e44e                	sd	s3,8(sp)
    800062d2:	e052                	sd	s4,0(sp)
    800062d4:	1800                	addi	s0,sp,48
    800062d6:	892a                	mv	s2,a0
    800062d8:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    800062da:	00246517          	auipc	a0,0x246
    800062de:	8e650513          	addi	a0,a0,-1818 # 8024bbc0 <shmt>
    800062e2:	9bffa0ef          	jal	ra,80000ca0 <acquire>

  for(int i=0;i<NSHM;i++){
    800062e6:	00246797          	auipc	a5,0x246
    800062ea:	8f278793          	addi	a5,a5,-1806 # 8024bbd8 <shmt+0x18>
    800062ee:	4481                	li	s1,0
    800062f0:	6685                	lui	a3,0x1
    800062f2:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    800062f6:	4641                	li	a2,16
    800062f8:	a82d                	j	80006332 <shm_getpa+0x6c>
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
        pa = 0;
        break;
      }
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    800062fa:	8b1fa0ef          	jal	ra,80000baa <kalloc>
    800062fe:	8a2a                	mv	s4,a0
        if(mem == 0){
    80006300:	cd41                	beqz	a0,80006398 <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        memset(mem, 0, PGSIZE);
    80006302:	6605                	lui	a2,0x1
    80006304:	4581                	li	a1,0
    80006306:	a6ffa0ef          	jal	ra,80000d74 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    8000630a:	00649793          	slli	a5,s1,0x6
    8000630e:	97a6                	add	a5,a5,s1
    80006310:	078a                	slli	a5,a5,0x2
    80006312:	8f85                	sub	a5,a5,s1
    80006314:	97ce                	add	a5,a5,s3
    80006316:	0791                	addi	a5,a5,4
    80006318:	078e                	slli	a5,a5,0x3
    8000631a:	00246717          	auipc	a4,0x246
    8000631e:	8a670713          	addi	a4,a4,-1882 # 8024bbc0 <shmt>
    80006322:	97ba                	add	a5,a5,a4
    80006324:	0147b423          	sd	s4,8(a5)
    80006328:	a0b9                	j	80006376 <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    8000632a:	2485                	addiw	s1,s1,1
    8000632c:	97b6                	add	a5,a5,a3
    8000632e:	06c48463          	beq	s1,a2,80006396 <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006332:	4398                	lw	a4,0(a5)
    80006334:	db7d                	beqz	a4,8000632a <shm_getpa+0x64>
    80006336:	43d8                	lw	a4,4(a5)
    80006338:	ff2719e3          	bne	a4,s2,8000632a <shm_getpa+0x64>
        pa = 0;
    8000633c:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    8000633e:	0409cd63          	bltz	s3,80006398 <shm_getpa+0xd2>
    80006342:	6785                	lui	a5,0x1
    80006344:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006348:	02f487b3          	mul	a5,s1,a5
    8000634c:	00246717          	auipc	a4,0x246
    80006350:	87470713          	addi	a4,a4,-1932 # 8024bbc0 <shmt>
    80006354:	97ba                	add	a5,a5,a4
    80006356:	539c                	lw	a5,32(a5)
    80006358:	04f9d063          	bge	s3,a5,80006398 <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    8000635c:	00649793          	slli	a5,s1,0x6
    80006360:	97a6                	add	a5,a5,s1
    80006362:	078a                	slli	a5,a5,0x2
    80006364:	8f85                	sub	a5,a5,s1
    80006366:	97ce                	add	a5,a5,s3
    80006368:	0791                	addi	a5,a5,4
    8000636a:	078e                	slli	a5,a5,0x3
    8000636c:	97ba                	add	a5,a5,a4
    8000636e:	0087b903          	ld	s2,8(a5)
    80006372:	f80904e3          	beqz	s2,800062fa <shm_getpa+0x34>
      }
      pa = shmt.obj[i].pa[page_index];
    80006376:	00649793          	slli	a5,s1,0x6
    8000637a:	97a6                	add	a5,a5,s1
    8000637c:	078a                	slli	a5,a5,0x2
    8000637e:	8f85                	sub	a5,a5,s1
    80006380:	97ce                	add	a5,a5,s3
    80006382:	0791                	addi	a5,a5,4
    80006384:	078e                	slli	a5,a5,0x3
    80006386:	00246717          	auipc	a4,0x246
    8000638a:	83a70713          	addi	a4,a4,-1990 # 8024bbc0 <shmt>
    8000638e:	97ba                	add	a5,a5,a4
    80006390:	0087b903          	ld	s2,8(a5)
      break;
    80006394:	a011                	j	80006398 <shm_getpa+0xd2>
  uint64 pa = 0;
    80006396:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    80006398:	00246517          	auipc	a0,0x246
    8000639c:	82850513          	addi	a0,a0,-2008 # 8024bbc0 <shmt>
    800063a0:	999fa0ef          	jal	ra,80000d38 <release>
  return pa;
}
    800063a4:	854a                	mv	a0,s2
    800063a6:	70a2                	ld	ra,40(sp)
    800063a8:	7402                	ld	s0,32(sp)
    800063aa:	64e2                	ld	s1,24(sp)
    800063ac:	6942                	ld	s2,16(sp)
    800063ae:	69a2                	ld	s3,8(sp)
    800063b0:	6a02                	ld	s4,0(sp)
    800063b2:	6145                	addi	sp,sp,48
    800063b4:	8082                	ret
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
