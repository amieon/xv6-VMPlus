
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
    80000004:	87813103          	ld	sp,-1928(sp) # 80008878 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdaaa87>
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
    8000010a:	68a020ef          	jal	ra,80002794 <either_copyin>
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
    80000176:	74e50513          	addi	a0,a0,1870 # 800108c0 <cons>
    8000017a:	327000ef          	jal	ra,80000ca0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	74248493          	addi	s1,s1,1858 # 800108c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	7d290913          	addi	s2,s2,2002 # 80010958 <cons+0x98>
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
    800001a8:	47e020ef          	jal	ra,80002626 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	23c020ef          	jal	ra,800023ee <sleep>
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
    800001ea:	560020ef          	jal	ra,8000274a <either_copyout>
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
    800001fe:	6c650513          	addi	a0,a0,1734 # 800108c0 <cons>
    80000202:	337000ef          	jal	ra,80000d38 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	6b450513          	addi	a0,a0,1716 # 800108c0 <cons>
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
    80000242:	70f72d23          	sw	a5,1818(a4) # 80010958 <cons+0x98>
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
    8000028c:	63850513          	addi	a0,a0,1592 # 800108c0 <cons>
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
    800002aa:	534020ef          	jal	ra,800027de <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	61250513          	addi	a0,a0,1554 # 800108c0 <cons>
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
    800002d2:	5f270713          	addi	a4,a4,1522 # 800108c0 <cons>
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
    800002f8:	5cc78793          	addi	a5,a5,1484 # 800108c0 <cons>
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
    80000326:	6367a783          	lw	a5,1590(a5) # 80010958 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	58a70713          	addi	a4,a4,1418 # 800108c0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	57a48493          	addi	s1,s1,1402 # 800108c0 <cons>
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
    80000382:	54270713          	addi	a4,a4,1346 # 800108c0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	5cf72623          	sw	a5,1484(a4) # 80010960 <cons+0xa0>
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
    800003b6:	50e78793          	addi	a5,a5,1294 # 800108c0 <cons>
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
    800003da:	58c7a323          	sw	a2,1414(a5) # 8001095c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	57a50513          	addi	a0,a0,1402 # 80010958 <cons+0x98>
    800003e6:	054020ef          	jal	ra,8000243a <wakeup>
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
    80000400:	4c450513          	addi	a0,a0,1220 # 800108c0 <cons>
    80000404:	01d000ef          	jal	ra,80000c20 <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0024a797          	auipc	a5,0x24a
    80000410:	63c78793          	addi	a5,a5,1596 # 8024aa48 <devsw>
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
    800004f8:	3a07a783          	lw	a5,928(a5) # 80008894 <panicking>
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
    80000536:	43650513          	addi	a0,a0,1078 # 80010968 <pr>
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
    80000754:	1447a783          	lw	a5,324(a5) # 80008894 <panicking>
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
    8000077e:	1ee50513          	addi	a0,a0,494 # 80010968 <pr>
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
    8000079c:	0f27ae23          	sw	s2,252(a5) # 80008894 <panicking>
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
    800007be:	0d27ab23          	sw	s2,214(a5) # 80008890 <panicked>
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
    800007d8:	19450513          	addi	a0,a0,404 # 80010968 <pr>
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
    80000824:	16050513          	addi	a0,a0,352 # 80010980 <tx_lock>
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
    80000852:	13250513          	addi	a0,a0,306 # 80010980 <tx_lock>
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
    80000872:	02e48493          	addi	s1,s1,46 # 8000889c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	00010997          	auipc	s3,0x10
    8000087a:	10a98993          	addi	s3,s3,266 # 80010980 <tx_lock>
    8000087e:	00008917          	auipc	s2,0x8
    80000882:	01a90913          	addi	s2,s2,26 # 80008898 <tx_chan>
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
    80000892:	35d010ef          	jal	ra,800023ee <sleep>
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
    800008b6:	0ce50513          	addi	a0,a0,206 # 80010980 <tx_lock>
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
    800008e4:	fb47a783          	lw	a5,-76(a5) # 80008894 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	fa67a783          	lw	a5,-90(a5) # 80008890 <panicked>
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
    8000091a:	f7e7a783          	lw	a5,-130(a5) # 80008894 <panicking>
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
    8000096a:	01a50513          	addi	a0,a0,26 # 80010980 <tx_lock>
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
    80000980:	00450513          	addi	a0,a0,4 # 80010980 <tx_lock>
    80000984:	3b4000ef          	jal	ra,80000d38 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00008797          	auipc	a5,0x8
    80000990:	f007a823          	sw	zero,-240(a5) # 8000889c <tx_busy>
    wakeup(&tx_chan);
    80000994:	00008517          	auipc	a0,0x8
    80000998:	f0450513          	addi	a0,a0,-252 # 80008898 <tx_chan>
    8000099c:	29f010ef          	jal	ra,8000243a <wakeup>
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
    800009c8:	ff450513          	addi	a0,a0,-12 # 800109b8 <kref>
    800009cc:	2d4000ef          	jal	ra,80000ca0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d0:	00010517          	auipc	a0,0x10
    800009d4:	fe850513          	addi	a0,a0,-24 # 800109b8 <kref>
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
    80000a02:	fba50513          	addi	a0,a0,-70 # 800109b8 <kref>
    80000a06:	29a000ef          	jal	ra,80000ca0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0a:	00c4d793          	srli	a5,s1,0xc
    80000a0e:	00010517          	auipc	a0,0x10
    80000a12:	faa50513          	addi	a0,a0,-86 # 800109b8 <kref>
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
    80000a46:	f7650513          	addi	a0,a0,-138 # 800109b8 <kref>
    80000a4a:	256000ef          	jal	ra,80000ca0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a4e:	00c4d793          	srli	a5,s1,0xc
    80000a52:	00010517          	auipc	a0,0x10
    80000a56:	f6650513          	addi	a0,a0,-154 # 800109b8 <kref>
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
    80000a92:	2ea78793          	addi	a5,a5,746 # 80253d78 <end>
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
    80000ad0:	ecc90913          	addi	s2,s2,-308 # 80010998 <kmem>
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
    80000b1a:	ea290913          	addi	s2,s2,-350 # 800109b8 <kref>
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
    80000b76:	e2650513          	addi	a0,a0,-474 # 80010998 <kmem>
    80000b7a:	0a6000ef          	jal	ra,80000c20 <initlock>
  initlock(&kref.lock, "kref");
    80000b7e:	00007597          	auipc	a1,0x7
    80000b82:	4ea58593          	addi	a1,a1,1258 # 80008068 <digits+0x30>
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	e3250513          	addi	a0,a0,-462 # 800109b8 <kref>
    80000b8e:	092000ef          	jal	ra,80000c20 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b92:	45c5                	li	a1,17
    80000b94:	05ee                	slli	a1,a1,0x1b
    80000b96:	00253517          	auipc	a0,0x253
    80000b9a:	1e250513          	addi	a0,a0,482 # 80253d78 <end>
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
    80000bb8:	de448493          	addi	s1,s1,-540 # 80010998 <kmem>
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	0e2000ef          	jal	ra,80000ca0 <acquire>
  r = kmem.freelist;
    80000bc2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc4:	c4b9                	beqz	s1,80000c12 <kalloc+0x68>
    kmem.freelist = r->next;
    80000bc6:	609c                	ld	a5,0(s1)
    80000bc8:	00010517          	auipc	a0,0x10
    80000bcc:	dd050513          	addi	a0,a0,-560 # 80010998 <kmem>
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
    80000be4:	dd850513          	addi	a0,a0,-552 # 800109b8 <kref>
    80000be8:	0b8000ef          	jal	ra,80000ca0 <acquire>
  kref.refcnt[PA2IDX(r)] = 1;
    80000bec:	00010517          	auipc	a0,0x10
    80000bf0:	dcc50513          	addi	a0,a0,-564 # 800109b8 <kref>
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
    80000c16:	d8650513          	addi	a0,a0,-634 # 80010998 <kmem>
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
    80000de8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fdab289>
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
    80000f26:	97e70713          	addi	a4,a4,-1666 # 800088a0 <started>
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
    80000f4c:	1c5010ef          	jal	ra,80002910 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	7d5040ef          	jal	ra,80005f24 <plicinithart>
  }

  scheduler();        
    80000f54:	302010ef          	jal	ra,80002256 <scheduler>
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
    80000f94:	159010ef          	jal	ra,800028ec <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	179010ef          	jal	ra,80002910 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	773040ef          	jal	ra,80005f0e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	785040ef          	jal	ra,80005f24 <plicinithart>
    binit();         // buffer cache
    80000fa4:	6c0020ef          	jal	ra,80003664 <binit>
    iinit();         // inode table
    80000fa8:	431020ef          	jal	ra,80003bd8 <iinit>
    fileinit();      // file table
    80000fac:	319030ef          	jal	ra,80004ac4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	064050ef          	jal	ra,80006014 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	068010ef          	jal	ra,8000201c <userinit>
    __sync_synchronize();
    80000fb8:	0ff0000f          	fence
    started = 1;
    80000fbc:	4785                	li	a5,1
    80000fbe:	00008717          	auipc	a4,0x8
    80000fc2:	8ef72123          	sw	a5,-1822(a4) # 800088a0 <started>
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
    80000fd6:	8d67b783          	ld	a5,-1834(a5) # 800088a8 <kernel_pagetable>
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
    80001262:	64a7b523          	sd	a0,1610(a5) # 800088a8 <kernel_pagetable>
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
    80001652:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdab288>
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
    80001910:	6fc010ef          	jal	ra,8000300c <vma_find>
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
    80001980:	56f040ef          	jal	ra,800066ee <shm_getpa>
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
    80001a04:	40048493          	addi	s1,s1,1024 # 80230e00 <proc>
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
    80001a1e:	de6a0a13          	addi	s4,s4,-538 # 80240800 <tickslock>
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
    80001a94:	f4050513          	addi	a0,a0,-192 # 802309d0 <pid_lock>
    80001a98:	988ff0ef          	jal	ra,80000c20 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a9c:	00006597          	auipc	a1,0x6
    80001aa0:	6ec58593          	addi	a1,a1,1772 # 80008188 <digits+0x150>
    80001aa4:	0022f517          	auipc	a0,0x22f
    80001aa8:	f4450513          	addi	a0,a0,-188 # 802309e8 <wait_lock>
    80001aac:	974ff0ef          	jal	ra,80000c20 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab0:	0022f497          	auipc	s1,0x22f
    80001ab4:	35048493          	addi	s1,s1,848 # 80230e00 <proc>
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
    80001ad6:	d2e98993          	addi	s3,s3,-722 # 80240800 <tickslock>
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
    80001af4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdab289>
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
    80001b3c:	ec850513          	addi	a0,a0,-312 # 80230a00 <cpus>
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
    80001b60:	e7470713          	addi	a4,a4,-396 # 802309d0 <pid_lock>
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
    80001b90:	cd47a783          	lw	a5,-812(a5) # 80008860 <first.1>
    80001b94:	cf8d                	beqz	a5,80001bce <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b96:	4505                	li	a0,1
    80001b98:	4f2020ef          	jal	ra,8000408a <fsinit>

    first = 0;
    80001b9c:	00007797          	auipc	a5,0x7
    80001ba0:	cc07a223          	sw	zero,-828(a5) # 80008860 <first.1>
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
    80001bbc:	57c030ef          	jal	ra,80005138 <kexec>
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
    80001bce:	55b000ef          	jal	ra,80002928 <prepare_return>
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
    80001c20:	db490913          	addi	s2,s2,-588 # 802309d0 <pid_lock>
    80001c24:	854a                	mv	a0,s2
    80001c26:	87aff0ef          	jal	ra,80000ca0 <acquire>
  pid = nextpid;
    80001c2a:	00007797          	auipc	a5,0x7
    80001c2e:	c3a78793          	addi	a5,a5,-966 # 80008864 <nextpid>
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
    80001c86:	16b040ef          	jal	ra,800065f0 <shm_put>
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
    80001d04:	0ed040ef          	jal	ra,800065f0 <shm_put>
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
    80001e5c:	7139                	addi	sp,sp,-64
    80001e5e:	fc06                	sd	ra,56(sp)
    80001e60:	f822                	sd	s0,48(sp)
    80001e62:	f426                	sd	s1,40(sp)
    80001e64:	f04a                	sd	s2,32(sp)
    80001e66:	ec4e                	sd	s3,24(sp)
    80001e68:	e852                	sd	s4,16(sp)
    80001e6a:	e456                	sd	s5,8(sp)
    80001e6c:	e05a                	sd	s6,0(sp)
    80001e6e:	0080                	addi	s0,sp,64
    80001e70:	8a2a                	mv	s4,a0
  for(int i = 0; i < NVMA; i++){
    80001e72:	16850493          	addi	s1,a0,360
{
    80001e76:	8926                	mv	s2,s1
  for(int i = 0; i < NVMA; i++){
    80001e78:	4981                	li	s3,0
    80001e7a:	19050b13          	addi	s6,a0,400
    80001e7e:	4ac1                	li	s5,16
    80001e80:	a0f1                	j	80001f4c <freeproc+0xf0>
    for(int j = 0; j < i; j++){
    80001e82:	02878793          	addi	a5,a5,40
    80001e86:	0ad78c63          	beq	a5,a3,80001f3e <freeproc+0xe2>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001e8a:	4398                	lw	a4,0(a5)
    80001e8c:	db7d                	beqz	a4,80001e82 <freeproc+0x26>
    80001e8e:	5398                	lw	a4,32(a5)
    80001e90:	db6d                	beqz	a4,80001e82 <freeproc+0x26>
    80001e92:	53d8                	lw	a4,36(a5)
    80001e94:	fea717e3          	bne	a4,a0,80001e82 <freeproc+0x26>
    80001e98:	a06d                	j	80001f42 <freeproc+0xe6>
    80001e9a:	3e8a0713          	addi	a4,s4,1000
      p->vmas[i].shm_key = -1;
    80001e9e:	56fd                	li	a3,-1
    80001ea0:	a029                	j	80001eaa <freeproc+0x4e>
  for(int i = 0; i < NVMA; i++){
    80001ea2:	02848493          	addi	s1,s1,40
    80001ea6:	02e48263          	beq	s1,a4,80001eca <freeproc+0x6e>
    if(p->vmas[i].used){
    80001eaa:	409c                	lw	a5,0(s1)
    80001eac:	dbfd                	beqz	a5,80001ea2 <freeproc+0x46>
      p->vmas[i].used = 0;
    80001eae:	0004a023          	sw	zero,0(s1)
      p->vmas[i].is_shm = 0;
    80001eb2:	0204a023          	sw	zero,32(s1)
      p->vmas[i].shm_key = -1;
    80001eb6:	d0d4                	sw	a3,36(s1)
      p->vmas[i].start = p->vmas[i].end = 0;
    80001eb8:	0004b823          	sd	zero,16(s1)
    80001ebc:	0004b423          	sd	zero,8(s1)
      p->vmas[i].prot = p->vmas[i].flags = 0;
    80001ec0:	0004ae23          	sw	zero,28(s1)
    80001ec4:	0004ac23          	sw	zero,24(s1)
    80001ec8:	bfe9                	j	80001ea2 <freeproc+0x46>
  if(p->trapframe)
    80001eca:	058a3503          	ld	a0,88(s4)
    80001ece:	c119                	beqz	a0,80001ed4 <freeproc+0x78>
    kfree((void*)p->trapframe);
    80001ed0:	babfe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001ed4:	040a3c23          	sd	zero,88(s4)
  if(p->pagetable){
    80001ed8:	050a3503          	ld	a0,80(s4)
    80001edc:	c115                	beqz	a0,80001f00 <freeproc+0xa4>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001ede:	168a0493          	addi	s1,s4,360
    80001ee2:	85a6                	mv	a1,s1
    80001ee4:	ee9ff0ef          	jal	ra,80001dcc <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001ee8:	28000613          	li	a2,640
    80001eec:	4581                	li	a1,0
    80001eee:	8526                	mv	a0,s1
    80001ef0:	e85fe0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001ef4:	048a3583          	ld	a1,72(s4)
    80001ef8:	050a3503          	ld	a0,80(s4)
    80001efc:	f1bff0ef          	jal	ra,80001e16 <proc_freepagetable>
  delete_shm_from_proc(p);
    80001f00:	8552                	mv	a0,s4
    80001f02:	dc9ff0ef          	jal	ra,80001cca <delete_shm_from_proc>
  p->pagetable = 0;
    80001f06:	040a3823          	sd	zero,80(s4)
  p->sz = 0;
    80001f0a:	040a3423          	sd	zero,72(s4)
  p->pid = 0;
    80001f0e:	020a2823          	sw	zero,48(s4)
  p->parent = 0;
    80001f12:	020a3c23          	sd	zero,56(s4)
  p->name[0] = 0;
    80001f16:	140a0c23          	sb	zero,344(s4)
  p->chan = 0;
    80001f1a:	020a3023          	sd	zero,32(s4)
  p->killed = 0;
    80001f1e:	020a2423          	sw	zero,40(s4)
  p->xstate = 0;
    80001f22:	020a2623          	sw	zero,44(s4)
  p->state = UNUSED;
    80001f26:	000a2c23          	sw	zero,24(s4)
}
    80001f2a:	70e2                	ld	ra,56(sp)
    80001f2c:	7442                	ld	s0,48(sp)
    80001f2e:	74a2                	ld	s1,40(sp)
    80001f30:	7902                	ld	s2,32(sp)
    80001f32:	69e2                	ld	s3,24(sp)
    80001f34:	6a42                	ld	s4,16(sp)
    80001f36:	6aa2                	ld	s5,8(sp)
    80001f38:	6b02                	ld	s6,0(sp)
    80001f3a:	6121                	addi	sp,sp,64
    80001f3c:	8082                	ret
    shm_put(key);
    80001f3e:	6b2040ef          	jal	ra,800065f0 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001f42:	2985                	addiw	s3,s3,1
    80001f44:	02890913          	addi	s2,s2,40
    80001f48:	f55989e3          	beq	s3,s5,80001e9a <freeproc+0x3e>
    if(!p->vmas[i].used || !p->vmas[i].is_shm)
    80001f4c:	00092783          	lw	a5,0(s2)
    80001f50:	dbed                	beqz	a5,80001f42 <freeproc+0xe6>
    80001f52:	02092783          	lw	a5,32(s2)
    80001f56:	d7f5                	beqz	a5,80001f42 <freeproc+0xe6>
    int key = p->vmas[i].shm_key;
    80001f58:	02492503          	lw	a0,36(s2)
    for(int j = 0; j < i; j++){
    80001f5c:	ff3051e3          	blez	s3,80001f3e <freeproc+0xe2>
    80001f60:	fff9879b          	addiw	a5,s3,-1
    80001f64:	1782                	slli	a5,a5,0x20
    80001f66:	9381                	srli	a5,a5,0x20
    80001f68:	00279693          	slli	a3,a5,0x2
    80001f6c:	96be                	add	a3,a3,a5
    80001f6e:	068e                	slli	a3,a3,0x3
    80001f70:	96da                	add	a3,a3,s6
    80001f72:	87a6                	mv	a5,s1
    80001f74:	bf19                	j	80001e8a <freeproc+0x2e>

0000000080001f76 <allocproc>:
{
    80001f76:	1101                	addi	sp,sp,-32
    80001f78:	ec06                	sd	ra,24(sp)
    80001f7a:	e822                	sd	s0,16(sp)
    80001f7c:	e426                	sd	s1,8(sp)
    80001f7e:	e04a                	sd	s2,0(sp)
    80001f80:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f82:	0022f497          	auipc	s1,0x22f
    80001f86:	e7e48493          	addi	s1,s1,-386 # 80230e00 <proc>
    80001f8a:	0023f917          	auipc	s2,0x23f
    80001f8e:	87690913          	addi	s2,s2,-1930 # 80240800 <tickslock>
    acquire(&p->lock);
    80001f92:	8526                	mv	a0,s1
    80001f94:	d0dfe0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001f98:	4c9c                	lw	a5,24(s1)
    80001f9a:	cb91                	beqz	a5,80001fae <allocproc+0x38>
      release(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	d9bfe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fa2:	3e848493          	addi	s1,s1,1000
    80001fa6:	ff2496e3          	bne	s1,s2,80001f92 <allocproc+0x1c>
  return 0;
    80001faa:	4481                	li	s1,0
    80001fac:	a089                	j	80001fee <allocproc+0x78>
  p->pid = allocpid();
    80001fae:	c63ff0ef          	jal	ra,80001c10 <allocpid>
    80001fb2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001fb4:	4785                	li	a5,1
    80001fb6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001fb8:	bf3fe0ef          	jal	ra,80000baa <kalloc>
    80001fbc:	892a                	mv	s2,a0
    80001fbe:	eca8                	sd	a0,88(s1)
    80001fc0:	cd15                	beqz	a0,80001ffc <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	d85ff0ef          	jal	ra,80001d48 <proc_pagetable>
    80001fc8:	892a                	mv	s2,a0
    80001fca:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001fcc:	c121                	beqz	a0,8000200c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001fce:	07000613          	li	a2,112
    80001fd2:	4581                	li	a1,0
    80001fd4:	06048513          	addi	a0,s1,96
    80001fd8:	d9dfe0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    80001fdc:	00000797          	auipc	a5,0x0
    80001fe0:	b9c78793          	addi	a5,a5,-1124 # 80001b78 <forkret>
    80001fe4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fe6:	60bc                	ld	a5,64(s1)
    80001fe8:	6705                	lui	a4,0x1
    80001fea:	97ba                	add	a5,a5,a4
    80001fec:	f4bc                	sd	a5,104(s1)
}
    80001fee:	8526                	mv	a0,s1
    80001ff0:	60e2                	ld	ra,24(sp)
    80001ff2:	6442                	ld	s0,16(sp)
    80001ff4:	64a2                	ld	s1,8(sp)
    80001ff6:	6902                	ld	s2,0(sp)
    80001ff8:	6105                	addi	sp,sp,32
    80001ffa:	8082                	ret
    freeproc(p);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	e5fff0ef          	jal	ra,80001e5c <freeproc>
    release(&p->lock);
    80002002:	8526                	mv	a0,s1
    80002004:	d35fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80002008:	84ca                	mv	s1,s2
    8000200a:	b7d5                	j	80001fee <allocproc+0x78>
    freeproc(p);
    8000200c:	8526                	mv	a0,s1
    8000200e:	e4fff0ef          	jal	ra,80001e5c <freeproc>
    release(&p->lock);
    80002012:	8526                	mv	a0,s1
    80002014:	d25fe0ef          	jal	ra,80000d38 <release>
    return 0;
    80002018:	84ca                	mv	s1,s2
    8000201a:	bfd1                	j	80001fee <allocproc+0x78>

000000008000201c <userinit>:
{
    8000201c:	1101                	addi	sp,sp,-32
    8000201e:	ec06                	sd	ra,24(sp)
    80002020:	e822                	sd	s0,16(sp)
    80002022:	e426                	sd	s1,8(sp)
    80002024:	1000                	addi	s0,sp,32
  p = allocproc();
    80002026:	f51ff0ef          	jal	ra,80001f76 <allocproc>
    8000202a:	84aa                	mv	s1,a0
  initproc = p;
    8000202c:	00007797          	auipc	a5,0x7
    80002030:	88a7b223          	sd	a0,-1916(a5) # 800088b0 <initproc>
  p->cwd = namei("/");
    80002034:	00006517          	auipc	a0,0x6
    80002038:	17c50513          	addi	a0,a0,380 # 800081b0 <digits+0x178>
    8000203c:	552020ef          	jal	ra,8000458e <namei>
    80002040:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002044:	478d                	li	a5,3
    80002046:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002048:	8526                	mv	a0,s1
    8000204a:	ceffe0ef          	jal	ra,80000d38 <release>
}
    8000204e:	60e2                	ld	ra,24(sp)
    80002050:	6442                	ld	s0,16(sp)
    80002052:	64a2                	ld	s1,8(sp)
    80002054:	6105                	addi	sp,sp,32
    80002056:	8082                	ret

0000000080002058 <growproc>:
{
    80002058:	1101                	addi	sp,sp,-32
    8000205a:	ec06                	sd	ra,24(sp)
    8000205c:	e822                	sd	s0,16(sp)
    8000205e:	e426                	sd	s1,8(sp)
    80002060:	e04a                	sd	s2,0(sp)
    80002062:	1000                	addi	s0,sp,32
    80002064:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002066:	ae3ff0ef          	jal	ra,80001b48 <myproc>
    8000206a:	892a                	mv	s2,a0
  sz = p->sz;
    8000206c:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000206e:	02905963          	blez	s1,800020a0 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80002072:	00b48633          	add	a2,s1,a1
    80002076:	020007b7          	lui	a5,0x2000
    8000207a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    8000207c:	07b6                	slli	a5,a5,0xd
    8000207e:	02c7ea63          	bltu	a5,a2,800020b2 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002082:	4691                	li	a3,4
    80002084:	6928                	ld	a0,80(a0)
    80002086:	aceff0ef          	jal	ra,80001354 <uvmalloc>
    8000208a:	85aa                	mv	a1,a0
    8000208c:	c50d                	beqz	a0,800020b6 <growproc+0x5e>
  p->sz = sz;
    8000208e:	04b93423          	sd	a1,72(s2)
  return 0;
    80002092:	4501                	li	a0,0
}
    80002094:	60e2                	ld	ra,24(sp)
    80002096:	6442                	ld	s0,16(sp)
    80002098:	64a2                	ld	s1,8(sp)
    8000209a:	6902                	ld	s2,0(sp)
    8000209c:	6105                	addi	sp,sp,32
    8000209e:	8082                	ret
  } else if(n < 0){
    800020a0:	fe04d7e3          	bgez	s1,8000208e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020a4:	00b48633          	add	a2,s1,a1
    800020a8:	6928                	ld	a0,80(a0)
    800020aa:	a66ff0ef          	jal	ra,80001310 <uvmdealloc>
    800020ae:	85aa                	mv	a1,a0
    800020b0:	bff9                	j	8000208e <growproc+0x36>
      return -1;
    800020b2:	557d                	li	a0,-1
    800020b4:	b7c5                	j	80002094 <growproc+0x3c>
      return -1;
    800020b6:	557d                	li	a0,-1
    800020b8:	bff1                	j	80002094 <growproc+0x3c>

00000000800020ba <kfork>:
{
    800020ba:	715d                	addi	sp,sp,-80
    800020bc:	e486                	sd	ra,72(sp)
    800020be:	e0a2                	sd	s0,64(sp)
    800020c0:	fc26                	sd	s1,56(sp)
    800020c2:	f84a                	sd	s2,48(sp)
    800020c4:	f44e                	sd	s3,40(sp)
    800020c6:	f052                	sd	s4,32(sp)
    800020c8:	ec56                	sd	s5,24(sp)
    800020ca:	e85a                	sd	s6,16(sp)
    800020cc:	e45e                	sd	s7,8(sp)
    800020ce:	e062                	sd	s8,0(sp)
    800020d0:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    800020d2:	a77ff0ef          	jal	ra,80001b48 <myproc>
    800020d6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800020d8:	e9fff0ef          	jal	ra,80001f76 <allocproc>
    800020dc:	12050963          	beqz	a0,8000220e <kfork+0x154>
    800020e0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020e2:	048ab603          	ld	a2,72(s5)
    800020e6:	692c                	ld	a1,80(a0)
    800020e8:	050ab503          	ld	a0,80(s5)
    800020ec:	b94ff0ef          	jal	ra,80001480 <uvmcopy>
    800020f0:	04054863          	bltz	a0,80002140 <kfork+0x86>
  np->sz = p->sz;
    800020f4:	048ab783          	ld	a5,72(s5)
    800020f8:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800020fc:	058ab683          	ld	a3,88(s5)
    80002100:	87b6                	mv	a5,a3
    80002102:	0589b703          	ld	a4,88(s3)
    80002106:	12068693          	addi	a3,a3,288
    8000210a:	0007b803          	ld	a6,0(a5)
    8000210e:	6788                	ld	a0,8(a5)
    80002110:	6b8c                	ld	a1,16(a5)
    80002112:	6f90                	ld	a2,24(a5)
    80002114:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002118:	e708                	sd	a0,8(a4)
    8000211a:	eb0c                	sd	a1,16(a4)
    8000211c:	ef10                	sd	a2,24(a4)
    8000211e:	02078793          	addi	a5,a5,32
    80002122:	02070713          	addi	a4,a4,32
    80002126:	fed792e3          	bne	a5,a3,8000210a <kfork+0x50>
  np->trapframe->a0 = 0;
    8000212a:	0589b783          	ld	a5,88(s3)
    8000212e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002132:	0d0a8493          	addi	s1,s5,208
    80002136:	0d098913          	addi	s2,s3,208
    8000213a:	150a8a13          	addi	s4,s5,336
    8000213e:	a829                	j	80002158 <kfork+0x9e>
    freeproc(np);
    80002140:	854e                	mv	a0,s3
    80002142:	d1bff0ef          	jal	ra,80001e5c <freeproc>
    release(&np->lock);
    80002146:	854e                	mv	a0,s3
    80002148:	bf1fe0ef          	jal	ra,80000d38 <release>
    return -1;
    8000214c:	5c7d                	li	s8,-1
    8000214e:	a05d                	j	800021f4 <kfork+0x13a>
  for(i = 0; i < NOFILE; i++)
    80002150:	04a1                	addi	s1,s1,8
    80002152:	0921                	addi	s2,s2,8
    80002154:	01448963          	beq	s1,s4,80002166 <kfork+0xac>
    if(p->ofile[i])
    80002158:	6088                	ld	a0,0(s1)
    8000215a:	d97d                	beqz	a0,80002150 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    8000215c:	1eb020ef          	jal	ra,80004b46 <filedup>
    80002160:	00a93023          	sd	a0,0(s2)
    80002164:	b7f5                	j	80002150 <kfork+0x96>
  np->cwd = idup(p->cwd);
    80002166:	150ab503          	ld	a0,336(s5)
    8000216a:	3fb010ef          	jal	ra,80003d64 <idup>
    8000216e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002172:	4641                	li	a2,16
    80002174:	158a8593          	addi	a1,s5,344
    80002178:	15898513          	addi	a0,s3,344
    8000217c:	d3ffe0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    80002180:	0309ac03          	lw	s8,48(s3)
  release(&np->lock);
    80002184:	854e                	mv	a0,s3
    80002186:	bb3fe0ef          	jal	ra,80000d38 <release>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    8000218a:	16898b13          	addi	s6,s3,360
    8000218e:	28000613          	li	a2,640
    80002192:	168a8593          	addi	a1,s5,360
    80002196:	855a                	mv	a0,s6
    80002198:	c39fe0ef          	jal	ra,80000dd0 <memmove>
    8000219c:	84da                	mv	s1,s6
  for(int i = 0; i < NVMA; i++){
    8000219e:	4901                	li	s2,0
    800021a0:	19098b93          	addi	s7,s3,400
    800021a4:	4a41                	li	s4,16
    800021a6:	a069                	j	80002230 <kfork+0x176>
    for(int j = 0; j < i; j++){
    800021a8:	02878793          	addi	a5,a5,40
    800021ac:	06d78363          	beq	a5,a3,80002212 <kfork+0x158>
      if(np->vmas[j].used && np->vmas[j].is_shm && np->vmas[j].shm_key == key){
    800021b0:	4398                	lw	a4,0(a5)
    800021b2:	db7d                	beqz	a4,800021a8 <kfork+0xee>
    800021b4:	5398                	lw	a4,32(a5)
    800021b6:	db6d                	beqz	a4,800021a8 <kfork+0xee>
    800021b8:	53d8                	lw	a4,36(a5)
    800021ba:	fea717e3          	bne	a4,a0,800021a8 <kfork+0xee>
    800021be:	a0a5                	j	80002226 <kfork+0x16c>
        freeproc(np);
    800021c0:	854e                	mv	a0,s3
    800021c2:	c9bff0ef          	jal	ra,80001e5c <freeproc>
        return -1;
    800021c6:	5c7d                	li	s8,-1
    800021c8:	a035                	j	800021f4 <kfork+0x13a>
  acquire(&wait_lock);
    800021ca:	0022f497          	auipc	s1,0x22f
    800021ce:	81e48493          	addi	s1,s1,-2018 # 802309e8 <wait_lock>
    800021d2:	8526                	mv	a0,s1
    800021d4:	acdfe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    800021d8:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	b5bfe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    800021e2:	854e                	mv	a0,s3
    800021e4:	abdfe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    800021e8:	478d                	li	a5,3
    800021ea:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800021ee:	854e                	mv	a0,s3
    800021f0:	b49fe0ef          	jal	ra,80000d38 <release>
}
    800021f4:	8562                	mv	a0,s8
    800021f6:	60a6                	ld	ra,72(sp)
    800021f8:	6406                	ld	s0,64(sp)
    800021fa:	74e2                	ld	s1,56(sp)
    800021fc:	7942                	ld	s2,48(sp)
    800021fe:	79a2                	ld	s3,40(sp)
    80002200:	7a02                	ld	s4,32(sp)
    80002202:	6ae2                	ld	s5,24(sp)
    80002204:	6b42                	ld	s6,16(sp)
    80002206:	6ba2                	ld	s7,8(sp)
    80002208:	6c02                	ld	s8,0(sp)
    8000220a:	6161                	addi	sp,sp,80
    8000220c:	8082                	ret
    return -1;
    8000220e:	5c7d                	li	s8,-1
    80002210:	b7d5                	j	800021f4 <kfork+0x13a>
    int npages = (np->vmas[i].end - np->vmas[i].start) / PGSIZE;
    80002212:	699c                	ld	a5,16(a1)
    80002214:	6598                	ld	a4,8(a1)
    80002216:	40e785b3          	sub	a1,a5,a4
    8000221a:	81b1                	srli	a1,a1,0xc
    if(shm_get(key, npages) < 0){
    8000221c:	2581                	sext.w	a1,a1
    8000221e:	28e040ef          	jal	ra,800064ac <shm_get>
    80002222:	f8054fe3          	bltz	a0,800021c0 <kfork+0x106>
  for(int i = 0; i < NVMA; i++){
    80002226:	2905                	addiw	s2,s2,1
    80002228:	02848493          	addi	s1,s1,40
    8000222c:	f9490fe3          	beq	s2,s4,800021ca <kfork+0x110>
    if(!np->vmas[i].used || !np->vmas[i].is_shm) continue;
    80002230:	85a6                	mv	a1,s1
    80002232:	409c                	lw	a5,0(s1)
    80002234:	dbed                	beqz	a5,80002226 <kfork+0x16c>
    80002236:	509c                	lw	a5,32(s1)
    80002238:	d7fd                	beqz	a5,80002226 <kfork+0x16c>
    int key = np->vmas[i].shm_key;
    8000223a:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    8000223c:	fd205be3          	blez	s2,80002212 <kfork+0x158>
    80002240:	fff9079b          	addiw	a5,s2,-1
    80002244:	1782                	slli	a5,a5,0x20
    80002246:	9381                	srli	a5,a5,0x20
    80002248:	00279693          	slli	a3,a5,0x2
    8000224c:	96be                	add	a3,a3,a5
    8000224e:	068e                	slli	a3,a3,0x3
    80002250:	96de                	add	a3,a3,s7
    80002252:	87da                	mv	a5,s6
    80002254:	bfb1                	j	800021b0 <kfork+0xf6>

0000000080002256 <scheduler>:
{
    80002256:	715d                	addi	sp,sp,-80
    80002258:	e486                	sd	ra,72(sp)
    8000225a:	e0a2                	sd	s0,64(sp)
    8000225c:	fc26                	sd	s1,56(sp)
    8000225e:	f84a                	sd	s2,48(sp)
    80002260:	f44e                	sd	s3,40(sp)
    80002262:	f052                	sd	s4,32(sp)
    80002264:	ec56                	sd	s5,24(sp)
    80002266:	e85a                	sd	s6,16(sp)
    80002268:	e45e                	sd	s7,8(sp)
    8000226a:	e062                	sd	s8,0(sp)
    8000226c:	0880                	addi	s0,sp,80
    8000226e:	8792                	mv	a5,tp
  int id = r_tp();
    80002270:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002272:	00779b13          	slli	s6,a5,0x7
    80002276:	0022e717          	auipc	a4,0x22e
    8000227a:	75a70713          	addi	a4,a4,1882 # 802309d0 <pid_lock>
    8000227e:	975a                	add	a4,a4,s6
    80002280:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002284:	0022e717          	auipc	a4,0x22e
    80002288:	78470713          	addi	a4,a4,1924 # 80230a08 <cpus+0x8>
    8000228c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000228e:	4c11                	li	s8,4
        c->proc = p;
    80002290:	079e                	slli	a5,a5,0x7
    80002292:	0022ea17          	auipc	s4,0x22e
    80002296:	73ea0a13          	addi	s4,s4,1854 # 802309d0 <pid_lock>
    8000229a:	9a3e                	add	s4,s4,a5
        found = 1;
    8000229c:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    8000229e:	0023e997          	auipc	s3,0x23e
    800022a2:	56298993          	addi	s3,s3,1378 # 80240800 <tickslock>
    800022a6:	a83d                	j	800022e4 <scheduler+0x8e>
      release(&p->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	a8ffe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800022ae:	3e848493          	addi	s1,s1,1000
    800022b2:	03348563          	beq	s1,s3,800022dc <scheduler+0x86>
      acquire(&p->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	9e9fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    800022bc:	4c9c                	lw	a5,24(s1)
    800022be:	ff2795e3          	bne	a5,s2,800022a8 <scheduler+0x52>
        p->state = RUNNING;
    800022c2:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800022c6:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800022ca:	06048593          	addi	a1,s1,96
    800022ce:	855a                	mv	a0,s6
    800022d0:	5b2000ef          	jal	ra,80002882 <swtch>
        c->proc = 0;
    800022d4:	020a3823          	sd	zero,48(s4)
        found = 1;
    800022d8:	8ade                	mv	s5,s7
    800022da:	b7f9                	j	800022a8 <scheduler+0x52>
    if(found == 0) {
    800022dc:	000a9463          	bnez	s5,800022e4 <scheduler+0x8e>
      asm volatile("wfi");
    800022e0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022e8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022ec:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022f0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800022f4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022f6:	10079073          	csrw	sstatus,a5
    int found = 0;
    800022fa:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800022fc:	0022f497          	auipc	s1,0x22f
    80002300:	b0448493          	addi	s1,s1,-1276 # 80230e00 <proc>
      if(p->state == RUNNABLE) {
    80002304:	490d                	li	s2,3
    80002306:	bf45                	j	800022b6 <scheduler+0x60>

0000000080002308 <sched>:
{
    80002308:	7179                	addi	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002316:	833ff0ef          	jal	ra,80001b48 <myproc>
    8000231a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000231c:	91bfe0ef          	jal	ra,80000c36 <holding>
    80002320:	c92d                	beqz	a0,80002392 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002322:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002324:	2781                	sext.w	a5,a5
    80002326:	079e                	slli	a5,a5,0x7
    80002328:	0022e717          	auipc	a4,0x22e
    8000232c:	6a870713          	addi	a4,a4,1704 # 802309d0 <pid_lock>
    80002330:	97ba                	add	a5,a5,a4
    80002332:	0a87a703          	lw	a4,168(a5)
    80002336:	4785                	li	a5,1
    80002338:	06f71363          	bne	a4,a5,8000239e <sched+0x96>
  if(p->state == RUNNING)
    8000233c:	4c98                	lw	a4,24(s1)
    8000233e:	4791                	li	a5,4
    80002340:	06f70563          	beq	a4,a5,800023aa <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002344:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002348:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000234a:	e7b5                	bnez	a5,800023b6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000234c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000234e:	0022e917          	auipc	s2,0x22e
    80002352:	68290913          	addi	s2,s2,1666 # 802309d0 <pid_lock>
    80002356:	2781                	sext.w	a5,a5
    80002358:	079e                	slli	a5,a5,0x7
    8000235a:	97ca                	add	a5,a5,s2
    8000235c:	0ac7a983          	lw	s3,172(a5)
    80002360:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002362:	2781                	sext.w	a5,a5
    80002364:	079e                	slli	a5,a5,0x7
    80002366:	0022e597          	auipc	a1,0x22e
    8000236a:	6a258593          	addi	a1,a1,1698 # 80230a08 <cpus+0x8>
    8000236e:	95be                	add	a1,a1,a5
    80002370:	06048513          	addi	a0,s1,96
    80002374:	50e000ef          	jal	ra,80002882 <swtch>
    80002378:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000237a:	2781                	sext.w	a5,a5
    8000237c:	079e                	slli	a5,a5,0x7
    8000237e:	993e                	add	s2,s2,a5
    80002380:	0b392623          	sw	s3,172(s2)
}
    80002384:	70a2                	ld	ra,40(sp)
    80002386:	7402                	ld	s0,32(sp)
    80002388:	64e2                	ld	s1,24(sp)
    8000238a:	6942                	ld	s2,16(sp)
    8000238c:	69a2                	ld	s3,8(sp)
    8000238e:	6145                	addi	sp,sp,48
    80002390:	8082                	ret
    panic("sched p->lock");
    80002392:	00006517          	auipc	a0,0x6
    80002396:	e2650513          	addi	a0,a0,-474 # 800081b8 <digits+0x180>
    8000239a:	beefe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    8000239e:	00006517          	auipc	a0,0x6
    800023a2:	e2a50513          	addi	a0,a0,-470 # 800081c8 <digits+0x190>
    800023a6:	be2fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    800023aa:	00006517          	auipc	a0,0x6
    800023ae:	e2e50513          	addi	a0,a0,-466 # 800081d8 <digits+0x1a0>
    800023b2:	bd6fe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    800023b6:	00006517          	auipc	a0,0x6
    800023ba:	e3250513          	addi	a0,a0,-462 # 800081e8 <digits+0x1b0>
    800023be:	bcafe0ef          	jal	ra,80000788 <panic>

00000000800023c2 <yield>:
{
    800023c2:	1101                	addi	sp,sp,-32
    800023c4:	ec06                	sd	ra,24(sp)
    800023c6:	e822                	sd	s0,16(sp)
    800023c8:	e426                	sd	s1,8(sp)
    800023ca:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800023cc:	f7cff0ef          	jal	ra,80001b48 <myproc>
    800023d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023d2:	8cffe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    800023d6:	478d                	li	a5,3
    800023d8:	cc9c                	sw	a5,24(s1)
  sched();
    800023da:	f2fff0ef          	jal	ra,80002308 <sched>
  release(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	959fe0ef          	jal	ra,80000d38 <release>
}
    800023e4:	60e2                	ld	ra,24(sp)
    800023e6:	6442                	ld	s0,16(sp)
    800023e8:	64a2                	ld	s1,8(sp)
    800023ea:	6105                	addi	sp,sp,32
    800023ec:	8082                	ret

00000000800023ee <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800023ee:	7179                	addi	sp,sp,-48
    800023f0:	f406                	sd	ra,40(sp)
    800023f2:	f022                	sd	s0,32(sp)
    800023f4:	ec26                	sd	s1,24(sp)
    800023f6:	e84a                	sd	s2,16(sp)
    800023f8:	e44e                	sd	s3,8(sp)
    800023fa:	1800                	addi	s0,sp,48
    800023fc:	89aa                	mv	s3,a0
    800023fe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002400:	f48ff0ef          	jal	ra,80001b48 <myproc>
    80002404:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002406:	89bfe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    8000240a:	854a                	mv	a0,s2
    8000240c:	92dfe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    80002410:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002414:	4789                	li	a5,2
    80002416:	cc9c                	sw	a5,24(s1)

  sched();
    80002418:	ef1ff0ef          	jal	ra,80002308 <sched>

  // Tidy up.
  p->chan = 0;
    8000241c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	917fe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    80002426:	854a                	mv	a0,s2
    80002428:	879fe0ef          	jal	ra,80000ca0 <acquire>
}
    8000242c:	70a2                	ld	ra,40(sp)
    8000242e:	7402                	ld	s0,32(sp)
    80002430:	64e2                	ld	s1,24(sp)
    80002432:	6942                	ld	s2,16(sp)
    80002434:	69a2                	ld	s3,8(sp)
    80002436:	6145                	addi	sp,sp,48
    80002438:	8082                	ret

000000008000243a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000243a:	7139                	addi	sp,sp,-64
    8000243c:	fc06                	sd	ra,56(sp)
    8000243e:	f822                	sd	s0,48(sp)
    80002440:	f426                	sd	s1,40(sp)
    80002442:	f04a                	sd	s2,32(sp)
    80002444:	ec4e                	sd	s3,24(sp)
    80002446:	e852                	sd	s4,16(sp)
    80002448:	e456                	sd	s5,8(sp)
    8000244a:	0080                	addi	s0,sp,64
    8000244c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000244e:	0022f497          	auipc	s1,0x22f
    80002452:	9b248493          	addi	s1,s1,-1614 # 80230e00 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002456:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002458:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000245a:	0023e917          	auipc	s2,0x23e
    8000245e:	3a690913          	addi	s2,s2,934 # 80240800 <tickslock>
    80002462:	a801                	j	80002472 <wakeup+0x38>
      }
      release(&p->lock);
    80002464:	8526                	mv	a0,s1
    80002466:	8d3fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000246a:	3e848493          	addi	s1,s1,1000
    8000246e:	03248263          	beq	s1,s2,80002492 <wakeup+0x58>
    if(p != myproc()){
    80002472:	ed6ff0ef          	jal	ra,80001b48 <myproc>
    80002476:	fea48ae3          	beq	s1,a0,8000246a <wakeup+0x30>
      acquire(&p->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	825fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002480:	4c9c                	lw	a5,24(s1)
    80002482:	ff3791e3          	bne	a5,s3,80002464 <wakeup+0x2a>
    80002486:	709c                	ld	a5,32(s1)
    80002488:	fd479ee3          	bne	a5,s4,80002464 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000248c:	0154ac23          	sw	s5,24(s1)
    80002490:	bfd1                	j	80002464 <wakeup+0x2a>
    }
  }
}
    80002492:	70e2                	ld	ra,56(sp)
    80002494:	7442                	ld	s0,48(sp)
    80002496:	74a2                	ld	s1,40(sp)
    80002498:	7902                	ld	s2,32(sp)
    8000249a:	69e2                	ld	s3,24(sp)
    8000249c:	6a42                	ld	s4,16(sp)
    8000249e:	6aa2                	ld	s5,8(sp)
    800024a0:	6121                	addi	sp,sp,64
    800024a2:	8082                	ret

00000000800024a4 <reparent>:
{
    800024a4:	7179                	addi	sp,sp,-48
    800024a6:	f406                	sd	ra,40(sp)
    800024a8:	f022                	sd	s0,32(sp)
    800024aa:	ec26                	sd	s1,24(sp)
    800024ac:	e84a                	sd	s2,16(sp)
    800024ae:	e44e                	sd	s3,8(sp)
    800024b0:	e052                	sd	s4,0(sp)
    800024b2:	1800                	addi	s0,sp,48
    800024b4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b6:	0022f497          	auipc	s1,0x22f
    800024ba:	94a48493          	addi	s1,s1,-1718 # 80230e00 <proc>
      pp->parent = initproc;
    800024be:	00006a17          	auipc	s4,0x6
    800024c2:	3f2a0a13          	addi	s4,s4,1010 # 800088b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024c6:	0023e997          	auipc	s3,0x23e
    800024ca:	33a98993          	addi	s3,s3,826 # 80240800 <tickslock>
    800024ce:	a029                	j	800024d8 <reparent+0x34>
    800024d0:	3e848493          	addi	s1,s1,1000
    800024d4:	01348b63          	beq	s1,s3,800024ea <reparent+0x46>
    if(pp->parent == p){
    800024d8:	7c9c                	ld	a5,56(s1)
    800024da:	ff279be3          	bne	a5,s2,800024d0 <reparent+0x2c>
      pp->parent = initproc;
    800024de:	000a3503          	ld	a0,0(s4)
    800024e2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024e4:	f57ff0ef          	jal	ra,8000243a <wakeup>
    800024e8:	b7e5                	j	800024d0 <reparent+0x2c>
}
    800024ea:	70a2                	ld	ra,40(sp)
    800024ec:	7402                	ld	s0,32(sp)
    800024ee:	64e2                	ld	s1,24(sp)
    800024f0:	6942                	ld	s2,16(sp)
    800024f2:	69a2                	ld	s3,8(sp)
    800024f4:	6a02                	ld	s4,0(sp)
    800024f6:	6145                	addi	sp,sp,48
    800024f8:	8082                	ret

00000000800024fa <kexit>:
{
    800024fa:	7179                	addi	sp,sp,-48
    800024fc:	f406                	sd	ra,40(sp)
    800024fe:	f022                	sd	s0,32(sp)
    80002500:	ec26                	sd	s1,24(sp)
    80002502:	e84a                	sd	s2,16(sp)
    80002504:	e44e                	sd	s3,8(sp)
    80002506:	e052                	sd	s4,0(sp)
    80002508:	1800                	addi	s0,sp,48
    8000250a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000250c:	e3cff0ef          	jal	ra,80001b48 <myproc>
    80002510:	89aa                	mv	s3,a0
  if(p == initproc)
    80002512:	00006797          	auipc	a5,0x6
    80002516:	39e7b783          	ld	a5,926(a5) # 800088b0 <initproc>
    8000251a:	0d050493          	addi	s1,a0,208
    8000251e:	15050913          	addi	s2,a0,336
    80002522:	00a79f63          	bne	a5,a0,80002540 <kexit+0x46>
    panic("init exiting");
    80002526:	00006517          	auipc	a0,0x6
    8000252a:	cda50513          	addi	a0,a0,-806 # 80008200 <digits+0x1c8>
    8000252e:	a5afe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    80002532:	65a020ef          	jal	ra,80004b8c <fileclose>
      p->ofile[fd] = 0;
    80002536:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000253a:	04a1                	addi	s1,s1,8
    8000253c:	01248563          	beq	s1,s2,80002546 <kexit+0x4c>
    if(p->ofile[fd]){
    80002540:	6088                	ld	a0,0(s1)
    80002542:	f965                	bnez	a0,80002532 <kexit+0x38>
    80002544:	bfdd                	j	8000253a <kexit+0x40>
  begin_op();
    80002546:	23c020ef          	jal	ra,80004782 <begin_op>
  iput(p->cwd);
    8000254a:	1509b503          	ld	a0,336(s3)
    8000254e:	1cb010ef          	jal	ra,80003f18 <iput>
  end_op();
    80002552:	29e020ef          	jal	ra,800047f0 <end_op>
  p->cwd = 0;
    80002556:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000255a:	0022e497          	auipc	s1,0x22e
    8000255e:	48e48493          	addi	s1,s1,1166 # 802309e8 <wait_lock>
    80002562:	8526                	mv	a0,s1
    80002564:	f3cfe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    80002568:	854e                	mv	a0,s3
    8000256a:	f3bff0ef          	jal	ra,800024a4 <reparent>
  wakeup(p->parent);
    8000256e:	0389b503          	ld	a0,56(s3)
    80002572:	ec9ff0ef          	jal	ra,8000243a <wakeup>
  acquire(&p->lock);
    80002576:	854e                	mv	a0,s3
    80002578:	f28fe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    8000257c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002580:	4795                	li	a5,5
    80002582:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002586:	8526                	mv	a0,s1
    80002588:	fb0fe0ef          	jal	ra,80000d38 <release>
  sched();
    8000258c:	d7dff0ef          	jal	ra,80002308 <sched>
  panic("zombie exit");
    80002590:	00006517          	auipc	a0,0x6
    80002594:	c8050513          	addi	a0,a0,-896 # 80008210 <digits+0x1d8>
    80002598:	9f0fe0ef          	jal	ra,80000788 <panic>

000000008000259c <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000259c:	7179                	addi	sp,sp,-48
    8000259e:	f406                	sd	ra,40(sp)
    800025a0:	f022                	sd	s0,32(sp)
    800025a2:	ec26                	sd	s1,24(sp)
    800025a4:	e84a                	sd	s2,16(sp)
    800025a6:	e44e                	sd	s3,8(sp)
    800025a8:	1800                	addi	s0,sp,48
    800025aa:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025ac:	0022f497          	auipc	s1,0x22f
    800025b0:	85448493          	addi	s1,s1,-1964 # 80230e00 <proc>
    800025b4:	0023e997          	auipc	s3,0x23e
    800025b8:	24c98993          	addi	s3,s3,588 # 80240800 <tickslock>
    acquire(&p->lock);
    800025bc:	8526                	mv	a0,s1
    800025be:	ee2fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    800025c2:	589c                	lw	a5,48(s1)
    800025c4:	01278b63          	beq	a5,s2,800025da <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025c8:	8526                	mv	a0,s1
    800025ca:	f6efe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ce:	3e848493          	addi	s1,s1,1000
    800025d2:	ff3495e3          	bne	s1,s3,800025bc <kkill+0x20>
  }
  return -1;
    800025d6:	557d                	li	a0,-1
    800025d8:	a819                	j	800025ee <kkill+0x52>
      p->killed = 1;
    800025da:	4785                	li	a5,1
    800025dc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800025de:	4c98                	lw	a4,24(s1)
    800025e0:	4789                	li	a5,2
    800025e2:	00f70d63          	beq	a4,a5,800025fc <kkill+0x60>
      release(&p->lock);
    800025e6:	8526                	mv	a0,s1
    800025e8:	f50fe0ef          	jal	ra,80000d38 <release>
      return 0;
    800025ec:	4501                	li	a0,0
}
    800025ee:	70a2                	ld	ra,40(sp)
    800025f0:	7402                	ld	s0,32(sp)
    800025f2:	64e2                	ld	s1,24(sp)
    800025f4:	6942                	ld	s2,16(sp)
    800025f6:	69a2                	ld	s3,8(sp)
    800025f8:	6145                	addi	sp,sp,48
    800025fa:	8082                	ret
        p->state = RUNNABLE;
    800025fc:	478d                	li	a5,3
    800025fe:	cc9c                	sw	a5,24(s1)
    80002600:	b7dd                	j	800025e6 <kkill+0x4a>

0000000080002602 <setkilled>:

void
setkilled(struct proc *p)
{
    80002602:	1101                	addi	sp,sp,-32
    80002604:	ec06                	sd	ra,24(sp)
    80002606:	e822                	sd	s0,16(sp)
    80002608:	e426                	sd	s1,8(sp)
    8000260a:	1000                	addi	s0,sp,32
    8000260c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000260e:	e92fe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    80002612:	4785                	li	a5,1
    80002614:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002616:	8526                	mv	a0,s1
    80002618:	f20fe0ef          	jal	ra,80000d38 <release>
}
    8000261c:	60e2                	ld	ra,24(sp)
    8000261e:	6442                	ld	s0,16(sp)
    80002620:	64a2                	ld	s1,8(sp)
    80002622:	6105                	addi	sp,sp,32
    80002624:	8082                	ret

0000000080002626 <killed>:

int
killed(struct proc *p)
{
    80002626:	1101                	addi	sp,sp,-32
    80002628:	ec06                	sd	ra,24(sp)
    8000262a:	e822                	sd	s0,16(sp)
    8000262c:	e426                	sd	s1,8(sp)
    8000262e:	e04a                	sd	s2,0(sp)
    80002630:	1000                	addi	s0,sp,32
    80002632:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002634:	e6cfe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    80002638:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	efafe0ef          	jal	ra,80000d38 <release>
  return k;
}
    80002642:	854a                	mv	a0,s2
    80002644:	60e2                	ld	ra,24(sp)
    80002646:	6442                	ld	s0,16(sp)
    80002648:	64a2                	ld	s1,8(sp)
    8000264a:	6902                	ld	s2,0(sp)
    8000264c:	6105                	addi	sp,sp,32
    8000264e:	8082                	ret

0000000080002650 <kwait>:
{
    80002650:	715d                	addi	sp,sp,-80
    80002652:	e486                	sd	ra,72(sp)
    80002654:	e0a2                	sd	s0,64(sp)
    80002656:	fc26                	sd	s1,56(sp)
    80002658:	f84a                	sd	s2,48(sp)
    8000265a:	f44e                	sd	s3,40(sp)
    8000265c:	f052                	sd	s4,32(sp)
    8000265e:	ec56                	sd	s5,24(sp)
    80002660:	e85a                	sd	s6,16(sp)
    80002662:	e45e                	sd	s7,8(sp)
    80002664:	e062                	sd	s8,0(sp)
    80002666:	0880                	addi	s0,sp,80
    80002668:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000266a:	cdeff0ef          	jal	ra,80001b48 <myproc>
    8000266e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002670:	0022e517          	auipc	a0,0x22e
    80002674:	37850513          	addi	a0,a0,888 # 802309e8 <wait_lock>
    80002678:	e28fe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    8000267c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000267e:	4a15                	li	s4,5
        havekids = 1;
    80002680:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002682:	0023e997          	auipc	s3,0x23e
    80002686:	17e98993          	addi	s3,s3,382 # 80240800 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000268a:	0022ec17          	auipc	s8,0x22e
    8000268e:	35ec0c13          	addi	s8,s8,862 # 802309e8 <wait_lock>
    havekids = 0;
    80002692:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002694:	0022e497          	auipc	s1,0x22e
    80002698:	76c48493          	addi	s1,s1,1900 # 80230e00 <proc>
    8000269c:	a899                	j	800026f2 <kwait+0xa2>
          pid = pp->pid;
    8000269e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026a2:	000b0c63          	beqz	s6,800026ba <kwait+0x6a>
    800026a6:	4691                	li	a3,4
    800026a8:	02c48613          	addi	a2,s1,44
    800026ac:	85da                	mv	a1,s6
    800026ae:	05093503          	ld	a0,80(s2)
    800026b2:	8b8ff0ef          	jal	ra,8000176a <copyout>
    800026b6:	00054f63          	bltz	a0,800026d4 <kwait+0x84>
          freeproc(pp);
    800026ba:	8526                	mv	a0,s1
    800026bc:	fa0ff0ef          	jal	ra,80001e5c <freeproc>
          release(&pp->lock);
    800026c0:	8526                	mv	a0,s1
    800026c2:	e76fe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    800026c6:	0022e517          	auipc	a0,0x22e
    800026ca:	32250513          	addi	a0,a0,802 # 802309e8 <wait_lock>
    800026ce:	e6afe0ef          	jal	ra,80000d38 <release>
          return pid;
    800026d2:	a891                	j	80002726 <kwait+0xd6>
            release(&pp->lock);
    800026d4:	8526                	mv	a0,s1
    800026d6:	e62fe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    800026da:	0022e517          	auipc	a0,0x22e
    800026de:	30e50513          	addi	a0,a0,782 # 802309e8 <wait_lock>
    800026e2:	e56fe0ef          	jal	ra,80000d38 <release>
            return -1;
    800026e6:	59fd                	li	s3,-1
    800026e8:	a83d                	j	80002726 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026ea:	3e848493          	addi	s1,s1,1000
    800026ee:	03348063          	beq	s1,s3,8000270e <kwait+0xbe>
      if(pp->parent == p){
    800026f2:	7c9c                	ld	a5,56(s1)
    800026f4:	ff279be3          	bne	a5,s2,800026ea <kwait+0x9a>
        acquire(&pp->lock);
    800026f8:	8526                	mv	a0,s1
    800026fa:	da6fe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    800026fe:	4c9c                	lw	a5,24(s1)
    80002700:	f9478fe3          	beq	a5,s4,8000269e <kwait+0x4e>
        release(&pp->lock);
    80002704:	8526                	mv	a0,s1
    80002706:	e32fe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    8000270a:	8756                	mv	a4,s5
    8000270c:	bff9                	j	800026ea <kwait+0x9a>
    if(!havekids || killed(p)){
    8000270e:	c709                	beqz	a4,80002718 <kwait+0xc8>
    80002710:	854a                	mv	a0,s2
    80002712:	f15ff0ef          	jal	ra,80002626 <killed>
    80002716:	c50d                	beqz	a0,80002740 <kwait+0xf0>
      release(&wait_lock);
    80002718:	0022e517          	auipc	a0,0x22e
    8000271c:	2d050513          	addi	a0,a0,720 # 802309e8 <wait_lock>
    80002720:	e18fe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002724:	59fd                	li	s3,-1
}
    80002726:	854e                	mv	a0,s3
    80002728:	60a6                	ld	ra,72(sp)
    8000272a:	6406                	ld	s0,64(sp)
    8000272c:	74e2                	ld	s1,56(sp)
    8000272e:	7942                	ld	s2,48(sp)
    80002730:	79a2                	ld	s3,40(sp)
    80002732:	7a02                	ld	s4,32(sp)
    80002734:	6ae2                	ld	s5,24(sp)
    80002736:	6b42                	ld	s6,16(sp)
    80002738:	6ba2                	ld	s7,8(sp)
    8000273a:	6c02                	ld	s8,0(sp)
    8000273c:	6161                	addi	sp,sp,80
    8000273e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002740:	85e2                	mv	a1,s8
    80002742:	854a                	mv	a0,s2
    80002744:	cabff0ef          	jal	ra,800023ee <sleep>
    havekids = 0;
    80002748:	b7a9                	j	80002692 <kwait+0x42>

000000008000274a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000274a:	7179                	addi	sp,sp,-48
    8000274c:	f406                	sd	ra,40(sp)
    8000274e:	f022                	sd	s0,32(sp)
    80002750:	ec26                	sd	s1,24(sp)
    80002752:	e84a                	sd	s2,16(sp)
    80002754:	e44e                	sd	s3,8(sp)
    80002756:	e052                	sd	s4,0(sp)
    80002758:	1800                	addi	s0,sp,48
    8000275a:	84aa                	mv	s1,a0
    8000275c:	892e                	mv	s2,a1
    8000275e:	89b2                	mv	s3,a2
    80002760:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002762:	be6ff0ef          	jal	ra,80001b48 <myproc>
  if(user_dst){
    80002766:	cc99                	beqz	s1,80002784 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002768:	86d2                	mv	a3,s4
    8000276a:	864e                	mv	a2,s3
    8000276c:	85ca                	mv	a1,s2
    8000276e:	6928                	ld	a0,80(a0)
    80002770:	ffbfe0ef          	jal	ra,8000176a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002774:	70a2                	ld	ra,40(sp)
    80002776:	7402                	ld	s0,32(sp)
    80002778:	64e2                	ld	s1,24(sp)
    8000277a:	6942                	ld	s2,16(sp)
    8000277c:	69a2                	ld	s3,8(sp)
    8000277e:	6a02                	ld	s4,0(sp)
    80002780:	6145                	addi	sp,sp,48
    80002782:	8082                	ret
    memmove((char *)dst, src, len);
    80002784:	000a061b          	sext.w	a2,s4
    80002788:	85ce                	mv	a1,s3
    8000278a:	854a                	mv	a0,s2
    8000278c:	e44fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    80002790:	8526                	mv	a0,s1
    80002792:	b7cd                	j	80002774 <either_copyout+0x2a>

0000000080002794 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002794:	7179                	addi	sp,sp,-48
    80002796:	f406                	sd	ra,40(sp)
    80002798:	f022                	sd	s0,32(sp)
    8000279a:	ec26                	sd	s1,24(sp)
    8000279c:	e84a                	sd	s2,16(sp)
    8000279e:	e44e                	sd	s3,8(sp)
    800027a0:	e052                	sd	s4,0(sp)
    800027a2:	1800                	addi	s0,sp,48
    800027a4:	892a                	mv	s2,a0
    800027a6:	84ae                	mv	s1,a1
    800027a8:	89b2                	mv	s3,a2
    800027aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027ac:	b9cff0ef          	jal	ra,80001b48 <myproc>
  if(user_src){
    800027b0:	cc99                	beqz	s1,800027ce <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800027b2:	86d2                	mv	a3,s4
    800027b4:	864e                	mv	a2,s3
    800027b6:	85ca                	mv	a1,s2
    800027b8:	6928                	ld	a0,80(a0)
    800027ba:	8aaff0ef          	jal	ra,80001864 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027be:	70a2                	ld	ra,40(sp)
    800027c0:	7402                	ld	s0,32(sp)
    800027c2:	64e2                	ld	s1,24(sp)
    800027c4:	6942                	ld	s2,16(sp)
    800027c6:	69a2                	ld	s3,8(sp)
    800027c8:	6a02                	ld	s4,0(sp)
    800027ca:	6145                	addi	sp,sp,48
    800027cc:	8082                	ret
    memmove(dst, (char*)src, len);
    800027ce:	000a061b          	sext.w	a2,s4
    800027d2:	85ce                	mv	a1,s3
    800027d4:	854a                	mv	a0,s2
    800027d6:	dfafe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    800027da:	8526                	mv	a0,s1
    800027dc:	b7cd                	j	800027be <either_copyin+0x2a>

00000000800027de <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027de:	715d                	addi	sp,sp,-80
    800027e0:	e486                	sd	ra,72(sp)
    800027e2:	e0a2                	sd	s0,64(sp)
    800027e4:	fc26                	sd	s1,56(sp)
    800027e6:	f84a                	sd	s2,48(sp)
    800027e8:	f44e                	sd	s3,40(sp)
    800027ea:	f052                	sd	s4,32(sp)
    800027ec:	ec56                	sd	s5,24(sp)
    800027ee:	e85a                	sd	s6,16(sp)
    800027f0:	e45e                	sd	s7,8(sp)
    800027f2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027f4:	00006517          	auipc	a0,0x6
    800027f8:	8d450513          	addi	a0,a0,-1836 # 800080c8 <digits+0x90>
    800027fc:	cc7fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002800:	0022e497          	auipc	s1,0x22e
    80002804:	75848493          	addi	s1,s1,1880 # 80230f58 <proc+0x158>
    80002808:	0023e917          	auipc	s2,0x23e
    8000280c:	15090913          	addi	s2,s2,336 # 80240958 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002810:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002812:	00006997          	auipc	s3,0x6
    80002816:	a0e98993          	addi	s3,s3,-1522 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    8000281a:	00006a97          	auipc	s5,0x6
    8000281e:	a0ea8a93          	addi	s5,s5,-1522 # 80008228 <digits+0x1f0>
    printf("\n");
    80002822:	00006a17          	auipc	s4,0x6
    80002826:	8a6a0a13          	addi	s4,s4,-1882 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000282a:	00006b97          	auipc	s7,0x6
    8000282e:	a3eb8b93          	addi	s7,s7,-1474 # 80008268 <states.0>
    80002832:	a829                	j	8000284c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002834:	ed86a583          	lw	a1,-296(a3)
    80002838:	8556                	mv	a0,s5
    8000283a:	c89fd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    8000283e:	8552                	mv	a0,s4
    80002840:	c83fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002844:	3e848493          	addi	s1,s1,1000
    80002848:	03248263          	beq	s1,s2,8000286c <procdump+0x8e>
    if(p->state == UNUSED)
    8000284c:	86a6                	mv	a3,s1
    8000284e:	ec04a783          	lw	a5,-320(s1)
    80002852:	dbed                	beqz	a5,80002844 <procdump+0x66>
      state = "???";
    80002854:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002856:	fcfb6fe3          	bltu	s6,a5,80002834 <procdump+0x56>
    8000285a:	02079713          	slli	a4,a5,0x20
    8000285e:	01d75793          	srli	a5,a4,0x1d
    80002862:	97de                	add	a5,a5,s7
    80002864:	6390                	ld	a2,0(a5)
    80002866:	f679                	bnez	a2,80002834 <procdump+0x56>
      state = "???";
    80002868:	864e                	mv	a2,s3
    8000286a:	b7e9                	j	80002834 <procdump+0x56>
  }
}
    8000286c:	60a6                	ld	ra,72(sp)
    8000286e:	6406                	ld	s0,64(sp)
    80002870:	74e2                	ld	s1,56(sp)
    80002872:	7942                	ld	s2,48(sp)
    80002874:	79a2                	ld	s3,40(sp)
    80002876:	7a02                	ld	s4,32(sp)
    80002878:	6ae2                	ld	s5,24(sp)
    8000287a:	6b42                	ld	s6,16(sp)
    8000287c:	6ba2                	ld	s7,8(sp)
    8000287e:	6161                	addi	sp,sp,80
    80002880:	8082                	ret

0000000080002882 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002882:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002886:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000288a:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000288c:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000288e:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002892:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002896:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000289a:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000289e:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800028a2:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800028a6:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800028aa:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800028ae:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800028b2:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800028b6:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800028ba:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800028be:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800028c0:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800028c2:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800028c6:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800028ca:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800028ce:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800028d2:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800028d6:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800028da:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800028de:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800028e2:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800028e6:	0685bd83          	ld	s11,104(a1)
        
        ret
    800028ea:	8082                	ret

00000000800028ec <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028ec:	1141                	addi	sp,sp,-16
    800028ee:	e406                	sd	ra,8(sp)
    800028f0:	e022                	sd	s0,0(sp)
    800028f2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028f4:	00006597          	auipc	a1,0x6
    800028f8:	9a458593          	addi	a1,a1,-1628 # 80008298 <states.0+0x30>
    800028fc:	0023e517          	auipc	a0,0x23e
    80002900:	f0450513          	addi	a0,a0,-252 # 80240800 <tickslock>
    80002904:	b1cfe0ef          	jal	ra,80000c20 <initlock>
}
    80002908:	60a2                	ld	ra,8(sp)
    8000290a:	6402                	ld	s0,0(sp)
    8000290c:	0141                	addi	sp,sp,16
    8000290e:	8082                	ret

0000000080002910 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002910:	1141                	addi	sp,sp,-16
    80002912:	e422                	sd	s0,8(sp)
    80002914:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002916:	00003797          	auipc	a5,0x3
    8000291a:	59a78793          	addi	a5,a5,1434 # 80005eb0 <kernelvec>
    8000291e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002922:	6422                	ld	s0,8(sp)
    80002924:	0141                	addi	sp,sp,16
    80002926:	8082                	ret

0000000080002928 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002928:	1141                	addi	sp,sp,-16
    8000292a:	e406                	sd	ra,8(sp)
    8000292c:	e022                	sd	s0,0(sp)
    8000292e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002930:	a18ff0ef          	jal	ra,80001b48 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002934:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002938:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000293a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000293e:	04000737          	lui	a4,0x4000
    80002942:	00004797          	auipc	a5,0x4
    80002946:	6be78793          	addi	a5,a5,1726 # 80007000 <_trampoline>
    8000294a:	00004697          	auipc	a3,0x4
    8000294e:	6b668693          	addi	a3,a3,1718 # 80007000 <_trampoline>
    80002952:	8f95                	sub	a5,a5,a3
    80002954:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002956:	0732                	slli	a4,a4,0xc
    80002958:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000295a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000295e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002960:	18002773          	csrr	a4,satp
    80002964:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002966:	6d38                	ld	a4,88(a0)
    80002968:	613c                	ld	a5,64(a0)
    8000296a:	6685                	lui	a3,0x1
    8000296c:	97b6                	add	a5,a5,a3
    8000296e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002970:	6d3c                	ld	a5,88(a0)
    80002972:	00000717          	auipc	a4,0x0
    80002976:	0f470713          	addi	a4,a4,244 # 80002a66 <usertrap>
    8000297a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000297c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000297e:	8712                	mv	a4,tp
    80002980:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002982:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002986:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000298a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000298e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002992:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002994:	6f9c                	ld	a5,24(a5)
    80002996:	14179073          	csrw	sepc,a5
}
    8000299a:	60a2                	ld	ra,8(sp)
    8000299c:	6402                	ld	s0,0(sp)
    8000299e:	0141                	addi	sp,sp,16
    800029a0:	8082                	ret

00000000800029a2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029a2:	1101                	addi	sp,sp,-32
    800029a4:	ec06                	sd	ra,24(sp)
    800029a6:	e822                	sd	s0,16(sp)
    800029a8:	e426                	sd	s1,8(sp)
    800029aa:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800029ac:	970ff0ef          	jal	ra,80001b1c <cpuid>
    800029b0:	cd19                	beqz	a0,800029ce <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800029b2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800029b6:	000f4737          	lui	a4,0xf4
    800029ba:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800029be:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800029c0:	14d79073          	csrw	0x14d,a5
}
    800029c4:	60e2                	ld	ra,24(sp)
    800029c6:	6442                	ld	s0,16(sp)
    800029c8:	64a2                	ld	s1,8(sp)
    800029ca:	6105                	addi	sp,sp,32
    800029cc:	8082                	ret
    acquire(&tickslock);
    800029ce:	0023e497          	auipc	s1,0x23e
    800029d2:	e3248493          	addi	s1,s1,-462 # 80240800 <tickslock>
    800029d6:	8526                	mv	a0,s1
    800029d8:	ac8fe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    800029dc:	00006517          	auipc	a0,0x6
    800029e0:	edc50513          	addi	a0,a0,-292 # 800088b8 <ticks>
    800029e4:	411c                	lw	a5,0(a0)
    800029e6:	2785                	addiw	a5,a5,1
    800029e8:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800029ea:	a51ff0ef          	jal	ra,8000243a <wakeup>
    release(&tickslock);
    800029ee:	8526                	mv	a0,s1
    800029f0:	b48fe0ef          	jal	ra,80000d38 <release>
    800029f4:	bf7d                	j	800029b2 <clockintr+0x10>

00000000800029f6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029f6:	1101                	addi	sp,sp,-32
    800029f8:	ec06                	sd	ra,24(sp)
    800029fa:	e822                	sd	s0,16(sp)
    800029fc:	e426                	sd	s1,8(sp)
    800029fe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a00:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a04:	57fd                	li	a5,-1
    80002a06:	17fe                	slli	a5,a5,0x3f
    80002a08:	07a5                	addi	a5,a5,9
    80002a0a:	00f70d63          	beq	a4,a5,80002a24 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a0e:	57fd                	li	a5,-1
    80002a10:	17fe                	slli	a5,a5,0x3f
    80002a12:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a14:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a16:	04f70463          	beq	a4,a5,80002a5e <devintr+0x68>
  }
}
    80002a1a:	60e2                	ld	ra,24(sp)
    80002a1c:	6442                	ld	s0,16(sp)
    80002a1e:	64a2                	ld	s1,8(sp)
    80002a20:	6105                	addi	sp,sp,32
    80002a22:	8082                	ret
    int irq = plic_claim();
    80002a24:	534030ef          	jal	ra,80005f58 <plic_claim>
    80002a28:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a2a:	47a9                	li	a5,10
    80002a2c:	02f50363          	beq	a0,a5,80002a52 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002a30:	4785                	li	a5,1
    80002a32:	02f50363          	beq	a0,a5,80002a58 <devintr+0x62>
    return 1;
    80002a36:	4505                	li	a0,1
    } else if(irq){
    80002a38:	d0ed                	beqz	s1,80002a1a <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a3a:	85a6                	mv	a1,s1
    80002a3c:	00006517          	auipc	a0,0x6
    80002a40:	86450513          	addi	a0,a0,-1948 # 800082a0 <states.0+0x38>
    80002a44:	a7ffd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    80002a48:	8526                	mv	a0,s1
    80002a4a:	52e030ef          	jal	ra,80005f78 <plic_complete>
    return 1;
    80002a4e:	4505                	li	a0,1
    80002a50:	b7e9                	j	80002a1a <devintr+0x24>
      uartintr();
    80002a52:	f03fd0ef          	jal	ra,80000954 <uartintr>
    80002a56:	bfcd                	j	80002a48 <devintr+0x52>
      virtio_disk_intr();
    80002a58:	18d030ef          	jal	ra,800063e4 <virtio_disk_intr>
    80002a5c:	b7f5                	j	80002a48 <devintr+0x52>
    clockintr();
    80002a5e:	f45ff0ef          	jal	ra,800029a2 <clockintr>
    return 2;
    80002a62:	4509                	li	a0,2
    80002a64:	bf5d                	j	80002a1a <devintr+0x24>

0000000080002a66 <usertrap>:
{
    80002a66:	7179                	addi	sp,sp,-48
    80002a68:	f406                	sd	ra,40(sp)
    80002a6a:	f022                	sd	s0,32(sp)
    80002a6c:	ec26                	sd	s1,24(sp)
    80002a6e:	e84a                	sd	s2,16(sp)
    80002a70:	e44e                	sd	s3,8(sp)
    80002a72:	e052                	sd	s4,0(sp)
    80002a74:	1800                	addi	s0,sp,48
    80002a76:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a7a:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a7e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a82:	1007f793          	andi	a5,a5,256
    80002a86:	e3bd                	bnez	a5,80002aec <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a88:	00003797          	auipc	a5,0x3
    80002a8c:	42878793          	addi	a5,a5,1064 # 80005eb0 <kernelvec>
    80002a90:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a94:	8b4ff0ef          	jal	ra,80001b48 <myproc>
    80002a98:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a9a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a9c:	14102773          	csrr	a4,sepc
    80002aa0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002aa6:	47a1                	li	a5,8
    80002aa8:	04f70863          	beq	a4,a5,80002af8 <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002aac:	f4bff0ef          	jal	ra,800029f6 <devintr>
    80002ab0:	892a                	mv	s2,a0
    80002ab2:	0c051e63          	bnez	a0,80002b8e <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002ab6:	47b5                	li	a5,13
    80002ab8:	08f98663          	beq	s3,a5,80002b44 <usertrap+0xde>
    80002abc:	47bd                	li	a5,15
    80002abe:	0af99363          	bne	s3,a5,80002b64 <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002ac2:	85d2                	mv	a1,s4
    80002ac4:	68a8                	ld	a0,80(s1)
    80002ac6:	a7bfe0ef          	jal	ra,80001540 <cowbreak>
    80002aca:	c531                	beqz	a0,80002b16 <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    80002acc:	4605                	li	a2,1
    80002ace:	85d2                	mv	a1,s4
    80002ad0:	8526                	mv	a0,s1
    80002ad2:	e21fe0ef          	jal	ra,800018f2 <vmafault>
    80002ad6:	e121                	bnez	a0,80002b16 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    80002ad8:	4601                	li	a2,0
    80002ada:	85d2                	mv	a1,s4
    80002adc:	68a8                	ld	a0,80(s1)
    80002ade:	c1bfe0ef          	jal	ra,800016f8 <vmfault>
    80002ae2:	e915                	bnez	a0,80002b16 <usertrap+0xb0>
        setkilled(p);
    80002ae4:	8526                	mv	a0,s1
    80002ae6:	b1dff0ef          	jal	ra,80002602 <setkilled>
    80002aea:	a035                	j	80002b16 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002aec:	00005517          	auipc	a0,0x5
    80002af0:	7d450513          	addi	a0,a0,2004 # 800082c0 <states.0+0x58>
    80002af4:	c95fd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    80002af8:	b2fff0ef          	jal	ra,80002626 <killed>
    80002afc:	e121                	bnez	a0,80002b3c <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002afe:	6cb8                	ld	a4,88(s1)
    80002b00:	6f1c                	ld	a5,24(a4)
    80002b02:	0791                	addi	a5,a5,4
    80002b04:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b06:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b0a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b0e:	10079073          	csrw	sstatus,a5
    syscall();
    80002b12:	27c000ef          	jal	ra,80002d8e <syscall>
  if(killed(p))
    80002b16:	8526                	mv	a0,s1
    80002b18:	b0fff0ef          	jal	ra,80002626 <killed>
    80002b1c:	ed35                	bnez	a0,80002b98 <usertrap+0x132>
  prepare_return();
    80002b1e:	e0bff0ef          	jal	ra,80002928 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b22:	68a8                	ld	a0,80(s1)
    80002b24:	8131                	srli	a0,a0,0xc
    80002b26:	57fd                	li	a5,-1
    80002b28:	17fe                	slli	a5,a5,0x3f
    80002b2a:	8d5d                	or	a0,a0,a5
}
    80002b2c:	70a2                	ld	ra,40(sp)
    80002b2e:	7402                	ld	s0,32(sp)
    80002b30:	64e2                	ld	s1,24(sp)
    80002b32:	6942                	ld	s2,16(sp)
    80002b34:	69a2                	ld	s3,8(sp)
    80002b36:	6a02                	ld	s4,0(sp)
    80002b38:	6145                	addi	sp,sp,48
    80002b3a:	8082                	ret
      kexit(-1);
    80002b3c:	557d                	li	a0,-1
    80002b3e:	9bdff0ef          	jal	ra,800024fa <kexit>
    80002b42:	bf75                	j	80002afe <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002b44:	4601                	li	a2,0
    80002b46:	85d2                	mv	a1,s4
    80002b48:	8526                	mv	a0,s1
    80002b4a:	da9fe0ef          	jal	ra,800018f2 <vmafault>
    80002b4e:	f561                	bnez	a0,80002b16 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002b50:	4605                	li	a2,1
    80002b52:	85d2                	mv	a1,s4
    80002b54:	68a8                	ld	a0,80(s1)
    80002b56:	ba3fe0ef          	jal	ra,800016f8 <vmfault>
    80002b5a:	fd55                	bnez	a0,80002b16 <usertrap+0xb0>
        setkilled(p);
    80002b5c:	8526                	mv	a0,s1
    80002b5e:	aa5ff0ef          	jal	ra,80002602 <setkilled>
    80002b62:	bf55                	j	80002b16 <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002b64:	5890                	lw	a2,48(s1)
    80002b66:	85ce                	mv	a1,s3
    80002b68:	00005517          	auipc	a0,0x5
    80002b6c:	77850513          	addi	a0,a0,1912 # 800082e0 <states.0+0x78>
    80002b70:	953fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b74:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002b78:	8652                	mv	a2,s4
    80002b7a:	00005517          	auipc	a0,0x5
    80002b7e:	79650513          	addi	a0,a0,1942 # 80008310 <states.0+0xa8>
    80002b82:	941fd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    80002b86:	8526                	mv	a0,s1
    80002b88:	a7bff0ef          	jal	ra,80002602 <setkilled>
    80002b8c:	b769                	j	80002b16 <usertrap+0xb0>
  if(killed(p))
    80002b8e:	8526                	mv	a0,s1
    80002b90:	a97ff0ef          	jal	ra,80002626 <killed>
    80002b94:	c511                	beqz	a0,80002ba0 <usertrap+0x13a>
    80002b96:	a011                	j	80002b9a <usertrap+0x134>
    80002b98:	4901                	li	s2,0
    kexit(-1);
    80002b9a:	557d                	li	a0,-1
    80002b9c:	95fff0ef          	jal	ra,800024fa <kexit>
  if(which_dev == 2)
    80002ba0:	4789                	li	a5,2
    80002ba2:	f6f91ee3          	bne	s2,a5,80002b1e <usertrap+0xb8>
    yield();
    80002ba6:	81dff0ef          	jal	ra,800023c2 <yield>
    80002baa:	bf95                	j	80002b1e <usertrap+0xb8>

0000000080002bac <kerneltrap>:
{
    80002bac:	7179                	addi	sp,sp,-48
    80002bae:	f406                	sd	ra,40(sp)
    80002bb0:	f022                	sd	s0,32(sp)
    80002bb2:	ec26                	sd	s1,24(sp)
    80002bb4:	e84a                	sd	s2,16(sp)
    80002bb6:	e44e                	sd	s3,8(sp)
    80002bb8:	1800                	addi	s0,sp,48
    80002bba:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbe:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bc2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bc6:	1004f793          	andi	a5,s1,256
    80002bca:	c795                	beqz	a5,80002bf6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bcc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bd0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bd2:	eb85                	bnez	a5,80002c02 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002bd4:	e23ff0ef          	jal	ra,800029f6 <devintr>
    80002bd8:	c91d                	beqz	a0,80002c0e <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002bda:	4789                	li	a5,2
    80002bdc:	04f50a63          	beq	a0,a5,80002c30 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002be0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002be4:	10049073          	csrw	sstatus,s1
}
    80002be8:	70a2                	ld	ra,40(sp)
    80002bea:	7402                	ld	s0,32(sp)
    80002bec:	64e2                	ld	s1,24(sp)
    80002bee:	6942                	ld	s2,16(sp)
    80002bf0:	69a2                	ld	s3,8(sp)
    80002bf2:	6145                	addi	sp,sp,48
    80002bf4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	74250513          	addi	a0,a0,1858 # 80008338 <states.0+0xd0>
    80002bfe:	b8bfd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c02:	00005517          	auipc	a0,0x5
    80002c06:	75e50513          	addi	a0,a0,1886 # 80008360 <states.0+0xf8>
    80002c0a:	b7ffd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c12:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c16:	85ce                	mv	a1,s3
    80002c18:	00005517          	auipc	a0,0x5
    80002c1c:	76850513          	addi	a0,a0,1896 # 80008380 <states.0+0x118>
    80002c20:	8a3fd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002c24:	00005517          	auipc	a0,0x5
    80002c28:	78450513          	addi	a0,a0,1924 # 800083a8 <states.0+0x140>
    80002c2c:	b5dfd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c30:	f19fe0ef          	jal	ra,80001b48 <myproc>
    80002c34:	d555                	beqz	a0,80002be0 <kerneltrap+0x34>
    yield();
    80002c36:	f8cff0ef          	jal	ra,800023c2 <yield>
    80002c3a:	b75d                	j	80002be0 <kerneltrap+0x34>

0000000080002c3c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c3c:	1101                	addi	sp,sp,-32
    80002c3e:	ec06                	sd	ra,24(sp)
    80002c40:	e822                	sd	s0,16(sp)
    80002c42:	e426                	sd	s1,8(sp)
    80002c44:	1000                	addi	s0,sp,32
    80002c46:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c48:	f01fe0ef          	jal	ra,80001b48 <myproc>
  switch (n) {
    80002c4c:	4795                	li	a5,5
    80002c4e:	0497e163          	bltu	a5,s1,80002c90 <argraw+0x54>
    80002c52:	048a                	slli	s1,s1,0x2
    80002c54:	00005717          	auipc	a4,0x5
    80002c58:	78c70713          	addi	a4,a4,1932 # 800083e0 <states.0+0x178>
    80002c5c:	94ba                	add	s1,s1,a4
    80002c5e:	409c                	lw	a5,0(s1)
    80002c60:	97ba                	add	a5,a5,a4
    80002c62:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c64:	6d3c                	ld	a5,88(a0)
    80002c66:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c68:	60e2                	ld	ra,24(sp)
    80002c6a:	6442                	ld	s0,16(sp)
    80002c6c:	64a2                	ld	s1,8(sp)
    80002c6e:	6105                	addi	sp,sp,32
    80002c70:	8082                	ret
    return p->trapframe->a1;
    80002c72:	6d3c                	ld	a5,88(a0)
    80002c74:	7fa8                	ld	a0,120(a5)
    80002c76:	bfcd                	j	80002c68 <argraw+0x2c>
    return p->trapframe->a2;
    80002c78:	6d3c                	ld	a5,88(a0)
    80002c7a:	63c8                	ld	a0,128(a5)
    80002c7c:	b7f5                	j	80002c68 <argraw+0x2c>
    return p->trapframe->a3;
    80002c7e:	6d3c                	ld	a5,88(a0)
    80002c80:	67c8                	ld	a0,136(a5)
    80002c82:	b7dd                	j	80002c68 <argraw+0x2c>
    return p->trapframe->a4;
    80002c84:	6d3c                	ld	a5,88(a0)
    80002c86:	6bc8                	ld	a0,144(a5)
    80002c88:	b7c5                	j	80002c68 <argraw+0x2c>
    return p->trapframe->a5;
    80002c8a:	6d3c                	ld	a5,88(a0)
    80002c8c:	6fc8                	ld	a0,152(a5)
    80002c8e:	bfe9                	j	80002c68 <argraw+0x2c>
  panic("argraw");
    80002c90:	00005517          	auipc	a0,0x5
    80002c94:	72850513          	addi	a0,a0,1832 # 800083b8 <states.0+0x150>
    80002c98:	af1fd0ef          	jal	ra,80000788 <panic>

0000000080002c9c <fetchaddr>:
{
    80002c9c:	1101                	addi	sp,sp,-32
    80002c9e:	ec06                	sd	ra,24(sp)
    80002ca0:	e822                	sd	s0,16(sp)
    80002ca2:	e426                	sd	s1,8(sp)
    80002ca4:	e04a                	sd	s2,0(sp)
    80002ca6:	1000                	addi	s0,sp,32
    80002ca8:	84aa                	mv	s1,a0
    80002caa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cac:	e9dfe0ef          	jal	ra,80001b48 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cb0:	653c                	ld	a5,72(a0)
    80002cb2:	02f4f663          	bgeu	s1,a5,80002cde <fetchaddr+0x42>
    80002cb6:	00848713          	addi	a4,s1,8
    80002cba:	02e7e463          	bltu	a5,a4,80002ce2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cbe:	46a1                	li	a3,8
    80002cc0:	8626                	mv	a2,s1
    80002cc2:	85ca                	mv	a1,s2
    80002cc4:	6928                	ld	a0,80(a0)
    80002cc6:	b9ffe0ef          	jal	ra,80001864 <copyin>
    80002cca:	00a03533          	snez	a0,a0
    80002cce:	40a00533          	neg	a0,a0
}
    80002cd2:	60e2                	ld	ra,24(sp)
    80002cd4:	6442                	ld	s0,16(sp)
    80002cd6:	64a2                	ld	s1,8(sp)
    80002cd8:	6902                	ld	s2,0(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret
    return -1;
    80002cde:	557d                	li	a0,-1
    80002ce0:	bfcd                	j	80002cd2 <fetchaddr+0x36>
    80002ce2:	557d                	li	a0,-1
    80002ce4:	b7fd                	j	80002cd2 <fetchaddr+0x36>

0000000080002ce6 <fetchstr>:
{
    80002ce6:	7179                	addi	sp,sp,-48
    80002ce8:	f406                	sd	ra,40(sp)
    80002cea:	f022                	sd	s0,32(sp)
    80002cec:	ec26                	sd	s1,24(sp)
    80002cee:	e84a                	sd	s2,16(sp)
    80002cf0:	e44e                	sd	s3,8(sp)
    80002cf2:	1800                	addi	s0,sp,48
    80002cf4:	892a                	mv	s2,a0
    80002cf6:	84ae                	mv	s1,a1
    80002cf8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cfa:	e4ffe0ef          	jal	ra,80001b48 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cfe:	86ce                	mv	a3,s3
    80002d00:	864a                	mv	a2,s2
    80002d02:	85a6                	mv	a1,s1
    80002d04:	6928                	ld	a0,80(a0)
    80002d06:	927fe0ef          	jal	ra,8000162c <copyinstr>
    80002d0a:	00054c63          	bltz	a0,80002d22 <fetchstr+0x3c>
  return strlen(buf);
    80002d0e:	8526                	mv	a0,s1
    80002d10:	9dcfe0ef          	jal	ra,80000eec <strlen>
}
    80002d14:	70a2                	ld	ra,40(sp)
    80002d16:	7402                	ld	s0,32(sp)
    80002d18:	64e2                	ld	s1,24(sp)
    80002d1a:	6942                	ld	s2,16(sp)
    80002d1c:	69a2                	ld	s3,8(sp)
    80002d1e:	6145                	addi	sp,sp,48
    80002d20:	8082                	ret
    return -1;
    80002d22:	557d                	li	a0,-1
    80002d24:	bfc5                	j	80002d14 <fetchstr+0x2e>

0000000080002d26 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d26:	1101                	addi	sp,sp,-32
    80002d28:	ec06                	sd	ra,24(sp)
    80002d2a:	e822                	sd	s0,16(sp)
    80002d2c:	e426                	sd	s1,8(sp)
    80002d2e:	1000                	addi	s0,sp,32
    80002d30:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d32:	f0bff0ef          	jal	ra,80002c3c <argraw>
    80002d36:	c088                	sw	a0,0(s1)
}
    80002d38:	60e2                	ld	ra,24(sp)
    80002d3a:	6442                	ld	s0,16(sp)
    80002d3c:	64a2                	ld	s1,8(sp)
    80002d3e:	6105                	addi	sp,sp,32
    80002d40:	8082                	ret

0000000080002d42 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d42:	1101                	addi	sp,sp,-32
    80002d44:	ec06                	sd	ra,24(sp)
    80002d46:	e822                	sd	s0,16(sp)
    80002d48:	e426                	sd	s1,8(sp)
    80002d4a:	1000                	addi	s0,sp,32
    80002d4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d4e:	eefff0ef          	jal	ra,80002c3c <argraw>
    80002d52:	e088                	sd	a0,0(s1)
}
    80002d54:	60e2                	ld	ra,24(sp)
    80002d56:	6442                	ld	s0,16(sp)
    80002d58:	64a2                	ld	s1,8(sp)
    80002d5a:	6105                	addi	sp,sp,32
    80002d5c:	8082                	ret

0000000080002d5e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d5e:	7179                	addi	sp,sp,-48
    80002d60:	f406                	sd	ra,40(sp)
    80002d62:	f022                	sd	s0,32(sp)
    80002d64:	ec26                	sd	s1,24(sp)
    80002d66:	e84a                	sd	s2,16(sp)
    80002d68:	1800                	addi	s0,sp,48
    80002d6a:	84ae                	mv	s1,a1
    80002d6c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d6e:	fd840593          	addi	a1,s0,-40
    80002d72:	fd1ff0ef          	jal	ra,80002d42 <argaddr>
  return fetchstr(addr, buf, max);
    80002d76:	864a                	mv	a2,s2
    80002d78:	85a6                	mv	a1,s1
    80002d7a:	fd843503          	ld	a0,-40(s0)
    80002d7e:	f69ff0ef          	jal	ra,80002ce6 <fetchstr>
}
    80002d82:	70a2                	ld	ra,40(sp)
    80002d84:	7402                	ld	s0,32(sp)
    80002d86:	64e2                	ld	s1,24(sp)
    80002d88:	6942                	ld	s2,16(sp)
    80002d8a:	6145                	addi	sp,sp,48
    80002d8c:	8082                	ret

0000000080002d8e <syscall>:

};

void
syscall(void)
{
    80002d8e:	1101                	addi	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	e426                	sd	s1,8(sp)
    80002d96:	e04a                	sd	s2,0(sp)
    80002d98:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d9a:	daffe0ef          	jal	ra,80001b48 <myproc>
    80002d9e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002da0:	05853903          	ld	s2,88(a0)
    80002da4:	0a893783          	ld	a5,168(s2)
    80002da8:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dac:	37fd                	addiw	a5,a5,-1
    80002dae:	4761                	li	a4,24
    80002db0:	00f76f63          	bltu	a4,a5,80002dce <syscall+0x40>
    80002db4:	00369713          	slli	a4,a3,0x3
    80002db8:	00005797          	auipc	a5,0x5
    80002dbc:	64078793          	addi	a5,a5,1600 # 800083f8 <syscalls>
    80002dc0:	97ba                	add	a5,a5,a4
    80002dc2:	639c                	ld	a5,0(a5)
    80002dc4:	c789                	beqz	a5,80002dce <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002dc6:	9782                	jalr	a5
    80002dc8:	06a93823          	sd	a0,112(s2)
    80002dcc:	a829                	j	80002de6 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002dce:	15848613          	addi	a2,s1,344
    80002dd2:	588c                	lw	a1,48(s1)
    80002dd4:	00005517          	auipc	a0,0x5
    80002dd8:	5ec50513          	addi	a0,a0,1516 # 800083c0 <states.0+0x158>
    80002ddc:	ee6fd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002de0:	6cbc                	ld	a5,88(s1)
    80002de2:	577d                	li	a4,-1
    80002de4:	fbb8                	sd	a4,112(a5)
  }
}
    80002de6:	60e2                	ld	ra,24(sp)
    80002de8:	6442                	ld	s0,16(sp)
    80002dea:	64a2                	ld	s1,8(sp)
    80002dec:	6902                	ld	s2,0(sp)
    80002dee:	6105                	addi	sp,sp,32
    80002df0:	8082                	ret

0000000080002df2 <proc_has_shm_key>:
  }
  return best;
}
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
    80002df2:	1141                	addi	sp,sp,-16
    80002df4:	e422                	sd	s0,8(sp)
    80002df6:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002df8:	16850793          	addi	a5,a0,360
    80002dfc:	3e850513          	addi	a0,a0,1000
    80002e00:	a029                	j	80002e0a <proc_has_shm_key+0x18>
    80002e02:	02878793          	addi	a5,a5,40
    80002e06:	00a78d63          	beq	a5,a0,80002e20 <proc_has_shm_key+0x2e>
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    80002e0a:	fef60ce3          	beq	a2,a5,80002e02 <proc_has_shm_key+0x10>
    if(v->used && v->is_shm && v->shm_key == key)
    80002e0e:	4398                	lw	a4,0(a5)
    80002e10:	db6d                	beqz	a4,80002e02 <proc_has_shm_key+0x10>
    80002e12:	5398                	lw	a4,32(a5)
    80002e14:	d77d                	beqz	a4,80002e02 <proc_has_shm_key+0x10>
    80002e16:	53d8                	lw	a4,36(a5)
    80002e18:	feb715e3          	bne	a4,a1,80002e02 <proc_has_shm_key+0x10>
      return 1;
    80002e1c:	4505                	li	a0,1
    80002e1e:	a011                	j	80002e22 <proc_has_shm_key+0x30>
  }
  return 0;
    80002e20:	4501                	li	a0,0
}
    80002e22:	6422                	ld	s0,8(sp)
    80002e24:	0141                	addi	sp,sp,16
    80002e26:	8082                	ret

0000000080002e28 <sys_exit>:
{
    80002e28:	1101                	addi	sp,sp,-32
    80002e2a:	ec06                	sd	ra,24(sp)
    80002e2c:	e822                	sd	s0,16(sp)
    80002e2e:	1000                	addi	s0,sp,32
  argint(0, &n);
    80002e30:	fec40593          	addi	a1,s0,-20
    80002e34:	4501                	li	a0,0
    80002e36:	ef1ff0ef          	jal	ra,80002d26 <argint>
  kexit(n);
    80002e3a:	fec42503          	lw	a0,-20(s0)
    80002e3e:	ebcff0ef          	jal	ra,800024fa <kexit>
}
    80002e42:	4501                	li	a0,0
    80002e44:	60e2                	ld	ra,24(sp)
    80002e46:	6442                	ld	s0,16(sp)
    80002e48:	6105                	addi	sp,sp,32
    80002e4a:	8082                	ret

0000000080002e4c <sys_getpid>:
{
    80002e4c:	1141                	addi	sp,sp,-16
    80002e4e:	e406                	sd	ra,8(sp)
    80002e50:	e022                	sd	s0,0(sp)
    80002e52:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e54:	cf5fe0ef          	jal	ra,80001b48 <myproc>
}
    80002e58:	5908                	lw	a0,48(a0)
    80002e5a:	60a2                	ld	ra,8(sp)
    80002e5c:	6402                	ld	s0,0(sp)
    80002e5e:	0141                	addi	sp,sp,16
    80002e60:	8082                	ret

0000000080002e62 <sys_fork>:
{
    80002e62:	1141                	addi	sp,sp,-16
    80002e64:	e406                	sd	ra,8(sp)
    80002e66:	e022                	sd	s0,0(sp)
    80002e68:	0800                	addi	s0,sp,16
  return kfork();
    80002e6a:	a50ff0ef          	jal	ra,800020ba <kfork>
}
    80002e6e:	60a2                	ld	ra,8(sp)
    80002e70:	6402                	ld	s0,0(sp)
    80002e72:	0141                	addi	sp,sp,16
    80002e74:	8082                	ret

0000000080002e76 <sys_wait>:
{
    80002e76:	1101                	addi	sp,sp,-32
    80002e78:	ec06                	sd	ra,24(sp)
    80002e7a:	e822                	sd	s0,16(sp)
    80002e7c:	1000                	addi	s0,sp,32
  argaddr(0, &p);
    80002e7e:	fe840593          	addi	a1,s0,-24
    80002e82:	4501                	li	a0,0
    80002e84:	ebfff0ef          	jal	ra,80002d42 <argaddr>
  return kwait(p);
    80002e88:	fe843503          	ld	a0,-24(s0)
    80002e8c:	fc4ff0ef          	jal	ra,80002650 <kwait>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	6105                	addi	sp,sp,32
    80002e96:	8082                	ret

0000000080002e98 <sys_sbrk>:
{
    80002e98:	7179                	addi	sp,sp,-48
    80002e9a:	f406                	sd	ra,40(sp)
    80002e9c:	f022                	sd	s0,32(sp)
    80002e9e:	ec26                	sd	s1,24(sp)
    80002ea0:	1800                	addi	s0,sp,48
  argint(0, &n);
    80002ea2:	fd840593          	addi	a1,s0,-40
    80002ea6:	4501                	li	a0,0
    80002ea8:	e7fff0ef          	jal	ra,80002d26 <argint>
  argint(1, &t);
    80002eac:	fdc40593          	addi	a1,s0,-36
    80002eb0:	4505                	li	a0,1
    80002eb2:	e75ff0ef          	jal	ra,80002d26 <argint>
  addr = myproc()->sz;
    80002eb6:	c93fe0ef          	jal	ra,80001b48 <myproc>
    80002eba:	6524                	ld	s1,72(a0)
  if(t == SBRK_EAGER || n < 0) {
    80002ebc:	fdc42703          	lw	a4,-36(s0)
    80002ec0:	4785                	li	a5,1
    80002ec2:	02f70763          	beq	a4,a5,80002ef0 <sys_sbrk+0x58>
    80002ec6:	fd842783          	lw	a5,-40(s0)
    80002eca:	0207c363          	bltz	a5,80002ef0 <sys_sbrk+0x58>
    if(addr + n < addr)
    80002ece:	97a6                	add	a5,a5,s1
    80002ed0:	0297ee63          	bltu	a5,s1,80002f0c <sys_sbrk+0x74>
    if(addr + n > TRAPFRAME)
    80002ed4:	02000737          	lui	a4,0x2000
    80002ed8:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002eda:	0736                	slli	a4,a4,0xd
    80002edc:	02f76a63          	bltu	a4,a5,80002f10 <sys_sbrk+0x78>
    myproc()->sz += n;
    80002ee0:	c69fe0ef          	jal	ra,80001b48 <myproc>
    80002ee4:	fd842703          	lw	a4,-40(s0)
    80002ee8:	653c                	ld	a5,72(a0)
    80002eea:	97ba                	add	a5,a5,a4
    80002eec:	e53c                	sd	a5,72(a0)
    80002eee:	a039                	j	80002efc <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002ef0:	fd842503          	lw	a0,-40(s0)
    80002ef4:	964ff0ef          	jal	ra,80002058 <growproc>
    80002ef8:	00054863          	bltz	a0,80002f08 <sys_sbrk+0x70>
}
    80002efc:	8526                	mv	a0,s1
    80002efe:	70a2                	ld	ra,40(sp)
    80002f00:	7402                	ld	s0,32(sp)
    80002f02:	64e2                	ld	s1,24(sp)
    80002f04:	6145                	addi	sp,sp,48
    80002f06:	8082                	ret
      return -1;
    80002f08:	54fd                	li	s1,-1
    80002f0a:	bfcd                	j	80002efc <sys_sbrk+0x64>
      return -1;
    80002f0c:	54fd                	li	s1,-1
    80002f0e:	b7fd                	j	80002efc <sys_sbrk+0x64>
      return -1;
    80002f10:	54fd                	li	s1,-1
    80002f12:	b7ed                	j	80002efc <sys_sbrk+0x64>

0000000080002f14 <sys_pause>:
{
    80002f14:	7139                	addi	sp,sp,-64
    80002f16:	fc06                	sd	ra,56(sp)
    80002f18:	f822                	sd	s0,48(sp)
    80002f1a:	f426                	sd	s1,40(sp)
    80002f1c:	f04a                	sd	s2,32(sp)
    80002f1e:	ec4e                	sd	s3,24(sp)
    80002f20:	0080                	addi	s0,sp,64
  argint(0, &n);
    80002f22:	fcc40593          	addi	a1,s0,-52
    80002f26:	4501                	li	a0,0
    80002f28:	dffff0ef          	jal	ra,80002d26 <argint>
  if(n < 0)
    80002f2c:	fcc42783          	lw	a5,-52(s0)
    80002f30:	0607c563          	bltz	a5,80002f9a <sys_pause+0x86>
  acquire(&tickslock);
    80002f34:	0023e517          	auipc	a0,0x23e
    80002f38:	8cc50513          	addi	a0,a0,-1844 # 80240800 <tickslock>
    80002f3c:	d65fd0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002f40:	00006917          	auipc	s2,0x6
    80002f44:	97892903          	lw	s2,-1672(s2) # 800088b8 <ticks>
  while(ticks - ticks0 < n){
    80002f48:	fcc42783          	lw	a5,-52(s0)
    80002f4c:	cb8d                	beqz	a5,80002f7e <sys_pause+0x6a>
    sleep(&ticks, &tickslock);
    80002f4e:	0023e997          	auipc	s3,0x23e
    80002f52:	8b298993          	addi	s3,s3,-1870 # 80240800 <tickslock>
    80002f56:	00006497          	auipc	s1,0x6
    80002f5a:	96248493          	addi	s1,s1,-1694 # 800088b8 <ticks>
    if(killed(myproc())){
    80002f5e:	bebfe0ef          	jal	ra,80001b48 <myproc>
    80002f62:	ec4ff0ef          	jal	ra,80002626 <killed>
    80002f66:	ed0d                	bnez	a0,80002fa0 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f68:	85ce                	mv	a1,s3
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	c82ff0ef          	jal	ra,800023ee <sleep>
  while(ticks - ticks0 < n){
    80002f70:	409c                	lw	a5,0(s1)
    80002f72:	412787bb          	subw	a5,a5,s2
    80002f76:	fcc42703          	lw	a4,-52(s0)
    80002f7a:	fee7e2e3          	bltu	a5,a4,80002f5e <sys_pause+0x4a>
  release(&tickslock);
    80002f7e:	0023e517          	auipc	a0,0x23e
    80002f82:	88250513          	addi	a0,a0,-1918 # 80240800 <tickslock>
    80002f86:	db3fd0ef          	jal	ra,80000d38 <release>
  return 0;
    80002f8a:	4501                	li	a0,0
}
    80002f8c:	70e2                	ld	ra,56(sp)
    80002f8e:	7442                	ld	s0,48(sp)
    80002f90:	74a2                	ld	s1,40(sp)
    80002f92:	7902                	ld	s2,32(sp)
    80002f94:	69e2                	ld	s3,24(sp)
    80002f96:	6121                	addi	sp,sp,64
    80002f98:	8082                	ret
    n = 0;
    80002f9a:	fc042623          	sw	zero,-52(s0)
    80002f9e:	bf59                	j	80002f34 <sys_pause+0x20>
      release(&tickslock);
    80002fa0:	0023e517          	auipc	a0,0x23e
    80002fa4:	86050513          	addi	a0,a0,-1952 # 80240800 <tickslock>
    80002fa8:	d91fd0ef          	jal	ra,80000d38 <release>
      return -1;
    80002fac:	557d                	li	a0,-1
    80002fae:	bff9                	j	80002f8c <sys_pause+0x78>

0000000080002fb0 <sys_kill>:
{
    80002fb0:	1101                	addi	sp,sp,-32
    80002fb2:	ec06                	sd	ra,24(sp)
    80002fb4:	e822                	sd	s0,16(sp)
    80002fb6:	1000                	addi	s0,sp,32
  argint(0, &pid);
    80002fb8:	fec40593          	addi	a1,s0,-20
    80002fbc:	4501                	li	a0,0
    80002fbe:	d69ff0ef          	jal	ra,80002d26 <argint>
  return kkill(pid);
    80002fc2:	fec42503          	lw	a0,-20(s0)
    80002fc6:	dd6ff0ef          	jal	ra,8000259c <kkill>
}
    80002fca:	60e2                	ld	ra,24(sp)
    80002fcc:	6442                	ld	s0,16(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret

0000000080002fd2 <sys_uptime>:
{
    80002fd2:	1101                	addi	sp,sp,-32
    80002fd4:	ec06                	sd	ra,24(sp)
    80002fd6:	e822                	sd	s0,16(sp)
    80002fd8:	e426                	sd	s1,8(sp)
    80002fda:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002fdc:	0023e517          	auipc	a0,0x23e
    80002fe0:	82450513          	addi	a0,a0,-2012 # 80240800 <tickslock>
    80002fe4:	cbdfd0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    80002fe8:	00006497          	auipc	s1,0x6
    80002fec:	8d04a483          	lw	s1,-1840(s1) # 800088b8 <ticks>
  release(&tickslock);
    80002ff0:	0023e517          	auipc	a0,0x23e
    80002ff4:	81050513          	addi	a0,a0,-2032 # 80240800 <tickslock>
    80002ff8:	d41fd0ef          	jal	ra,80000d38 <release>
}
    80002ffc:	02049513          	slli	a0,s1,0x20
    80003000:	9101                	srli	a0,a0,0x20
    80003002:	60e2                	ld	ra,24(sp)
    80003004:	6442                	ld	s0,16(sp)
    80003006:	64a2                	ld	s1,8(sp)
    80003008:	6105                	addi	sp,sp,32
    8000300a:	8082                	ret

000000008000300c <vma_find>:
{
    8000300c:	1141                	addi	sp,sp,-16
    8000300e:	e422                	sd	s0,8(sp)
    80003010:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80003012:	16850793          	addi	a5,a0,360
    80003016:	4701                	li	a4,0
    80003018:	4841                	li	a6,16
    8000301a:	a031                	j	80003026 <vma_find+0x1a>
    8000301c:	2705                	addiw	a4,a4,1
    8000301e:	02878793          	addi	a5,a5,40
    80003022:	03070263          	beq	a4,a6,80003046 <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    80003026:	4394                	lw	a3,0(a5)
    80003028:	daf5                	beqz	a3,8000301c <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    8000302a:	6794                	ld	a3,8(a5)
    8000302c:	fed5e8e3          	bltu	a1,a3,8000301c <vma_find+0x10>
    80003030:	6b94                	ld	a3,16(a5)
    80003032:	fed5f5e3          	bgeu	a1,a3,8000301c <vma_find+0x10>
      return &p->vmas[i];
    80003036:	00271793          	slli	a5,a4,0x2
    8000303a:	97ba                	add	a5,a5,a4
    8000303c:	078e                	slli	a5,a5,0x3
    8000303e:	16878793          	addi	a5,a5,360
    80003042:	953e                	add	a0,a0,a5
    80003044:	a011                	j	80003048 <vma_find+0x3c>
  return 0;
    80003046:	4501                	li	a0,0
}
    80003048:	6422                	ld	s0,8(sp)
    8000304a:	0141                	addi	sp,sp,16
    8000304c:	8082                	ret

000000008000304e <sys_mmap>:

uint64
sys_mmap(void)
{
    8000304e:	7119                	addi	sp,sp,-128
    80003050:	fc86                	sd	ra,120(sp)
    80003052:	f8a2                	sd	s0,112(sp)
    80003054:	f4a6                	sd	s1,104(sp)
    80003056:	f0ca                	sd	s2,96(sp)
    80003058:	ecce                	sd	s3,88(sp)
    8000305a:	e8d2                	sd	s4,80(sp)
    8000305c:	e4d6                	sd	s5,72(sp)
    8000305e:	e0da                	sd	s6,64(sp)
    80003060:	fc5e                	sd	s7,56(sp)
    80003062:	f862                	sd	s8,48(sp)
    80003064:	f466                	sd	s9,40(sp)
    80003066:	0100                	addi	s0,sp,128
  uint64 addr;
  int len, prot, flags, key = -1;
    80003068:	57fd                	li	a5,-1
    8000306a:	f8f42423          	sw	a5,-120(s0)
  int did_shm_get = 0;
  int need_get = 0;
  int npages = 0;

  argaddr(0, &addr);
    8000306e:	f9840593          	addi	a1,s0,-104
    80003072:	4501                	li	a0,0
    80003074:	ccfff0ef          	jal	ra,80002d42 <argaddr>
  argint(1, &len);
    80003078:	f9440593          	addi	a1,s0,-108
    8000307c:	4505                	li	a0,1
    8000307e:	ca9ff0ef          	jal	ra,80002d26 <argint>
  argint(2, &prot);
    80003082:	f9040593          	addi	a1,s0,-112
    80003086:	4509                	li	a0,2
    80003088:	c9fff0ef          	jal	ra,80002d26 <argint>
  argint(3, &flags);
    8000308c:	f8c40593          	addi	a1,s0,-116
    80003090:	450d                	li	a0,3
    80003092:	c95ff0ef          	jal	ra,80002d26 <argint>
  argint(4, &key);
    80003096:	f8840593          	addi	a1,s0,-120
    8000309a:	4511                	li	a0,4
    8000309c:	c8bff0ef          	jal	ra,80002d26 <argint>

  if(len <= 0) return (uint64)-1;
    800030a0:	f9442783          	lw	a5,-108(s0)
    800030a4:	1af05d63          	blez	a5,8000325e <sys_mmap+0x210>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return (uint64)-1;
  if(plen > (MMAPTOP - MMAPBASE)) return (uint64)-1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return (uint64)-1;
    800030a8:	f9042903          	lw	s2,-112(s0)
    800030ac:	ffc97913          	andi	s2,s2,-4
    800030b0:	54fd                	li	s1,-1
    800030b2:	1a091763          	bnez	s2,80003260 <sys_mmap+0x212>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    800030b6:	f8c42703          	lw	a4,-116(s0)
    800030ba:	8b05                	andi	a4,a4,1
    800030bc:	1a070263          	beqz	a4,80003260 <sys_mmap+0x212>
  if(addr != 0) return (uint64)-1;
    800030c0:	f9843a03          	ld	s4,-104(s0)
    800030c4:	180a1e63          	bnez	s4,80003260 <sys_mmap+0x212>
  uint64 plen = PGROUNDUP((uint64)len);
    800030c8:	6705                	lui	a4,0x1
    800030ca:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    800030cc:	00e789b3          	add	s3,a5,a4

  struct proc *p = myproc();
    800030d0:	a79fe0ef          	jal	ra,80001b48 <myproc>
    800030d4:	8aaa                	mv	s5,a0

  //先把“是否需要 shm_get”算出来（此时还没创建/污染 vma）
  if(flags & MAP_SHARED){
    800030d6:	f8c42b83          	lw	s7,-116(s0)
    800030da:	002bfb93          	andi	s7,s7,2
    800030de:	020b8563          	beqz	s7,80003108 <sys_mmap+0xba>
    if(key < 0) return (uint64)-1;
    800030e2:	f8842503          	lw	a0,-120(s0)
    800030e6:	16054d63          	bltz	a0,80003260 <sys_mmap+0x212>
    npages = plen / PGSIZE;
    800030ea:	40c9dc13          	srai	s8,s3,0xc

    // rmid 后禁止新 attach
    if(shm_is_deleted(key))
    800030ee:	7fa030ef          	jal	ra,800068e8 <shm_is_deleted>
    800030f2:	16051763          	bnez	a0,80003260 <sys_mmap+0x212>
      return (uint64)-1;

    // 按进程计数：本进程首次引用才 shm_get
    if(!proc_has_shm_key(p, key, 0))
    800030f6:	4601                	li	a2,0
    800030f8:	f8842583          	lw	a1,-120(s0)
    800030fc:	8556                	mv	a0,s5
    800030fe:	cf5ff0ef          	jal	ra,80002df2 <proc_has_shm_key>
  int need_get = 0;
    80003102:	00153b93          	seqz	s7,a0
    80003106:	a011                	j	8000310a <sys_mmap+0xbc>
  int npages = 0;
    80003108:	8c5e                	mv	s8,s7
  for(int i = 0; i < NVMA; i++){
    8000310a:	168a8b13          	addi	s6,s5,360
  int npages = 0;
    8000310e:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003110:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    80003112:	4398                	lw	a4,0(a5)
    80003114:	cb01                	beqz	a4,80003124 <sys_mmap+0xd6>
  for(int i = 0; i < NVMA; i++){
    80003116:	2905                	addiw	s2,s2,1
    80003118:	02878793          	addi	a5,a5,40
    8000311c:	fed91be3          	bne	s2,a3,80003112 <sys_mmap+0xc4>
      need_get = 1;
  }

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    80003120:	54fd                	li	s1,-1
    80003122:	aa3d                	j	80003260 <sys_mmap+0x212>
  uint64 plen = PGROUNDUP((uint64)len);
    80003124:	74fd                	lui	s1,0xfffff
    80003126:	0099f9b3          	and	s3,s3,s1
      return &p->vmas[i];
    8000312a:	00291c93          	slli	s9,s2,0x2
    8000312e:	012c8533          	add	a0,s9,s2
    80003132:	050e                	slli	a0,a0,0x3
    80003134:	16850513          	addi	a0,a0,360

  // 先清空这条 slot，避免失败时留下脏状态
  memset(v, 0, sizeof(*v));
    80003138:	02800613          	li	a2,40
    8000313c:	4581                	li	a1,0
    8000313e:	9556                	add	a0,a0,s5
    80003140:	c35fd0ef          	jal	ra,80000d74 <memset>
  v->shm_key = -1;
    80003144:	012c87b3          	add	a5,s9,s2
    80003148:	078e                	slli	a5,a5,0x3
    8000314a:	97d6                	add	a5,a5,s5
    8000314c:	577d                	li	a4,-1
    8000314e:	18e7a623          	sw	a4,396(a5)
  len = PGROUNDUP(len);
    80003152:	6805                	lui	a6,0x1
    80003154:	187d                	addi	a6,a6,-1 # fff <_entry-0x7ffff001>
    80003156:	984e                	add	a6,a6,s3
    80003158:	00987833          	and	a6,a6,s1
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    8000315c:	400005b7          	lui	a1,0x40000
    80003160:	95c2                	add	a1,a1,a6
    80003162:	400004b7          	lui	s1,0x40000
    80003166:	3e8a8613          	addi	a2,s5,1000
    va = PGROUNDUP(jump);
    8000316a:	6305                	lui	t1,0x1
    8000316c:	137d                	addi	t1,t1,-1 # fff <_entry-0x7ffff001>
    8000316e:	7e7d                	lui	t3,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    80003170:	f3fff8b7          	lui	a7,0xf3fff
    80003174:	08ba                	slli	a7,a7,0xe
    80003176:	01a8d893          	srli	a7,a7,0x1a
    8000317a:	a81d                	j	800031b0 <sys_mmap+0x162>
      if(best == 0 || e < best) best = e;
    8000317c:	853a                	mv	a0,a4
  for(int i=0;i<NVMA;i++){
    8000317e:	02878793          	addi	a5,a5,40
    80003182:	00c78f63          	beq	a5,a2,800031a0 <sys_mmap+0x152>
    if(!p->vmas[i].used) continue;
    80003186:	4398                	lw	a4,0(a5)
    80003188:	db7d                	beqz	a4,8000317e <sys_mmap+0x130>
    if(!(end <= s || start >= e)){
    8000318a:	6798                	ld	a4,8(a5)
    8000318c:	feb779e3          	bgeu	a4,a1,8000317e <sys_mmap+0x130>
    uint64 e = p->vmas[i].end;
    80003190:	6b98                	ld	a4,16(a5)
    if(!(end <= s || start >= e)){
    80003192:	fee4f6e3          	bgeu	s1,a4,8000317e <sys_mmap+0x130>
      if(best == 0 || e < best) best = e;
    80003196:	d17d                	beqz	a0,8000317c <sys_mmap+0x12e>
    80003198:	fea773e3          	bgeu	a4,a0,8000317e <sys_mmap+0x130>
    8000319c:	853a                	mv	a0,a4
    8000319e:	b7c5                	j	8000317e <sys_mmap+0x130>
    if(jump == 0){
    800031a0:	c919                	beqz	a0,800031b6 <sys_mmap+0x168>
    va = PGROUNDUP(jump);
    800031a2:	951a                	add	a0,a0,t1
    800031a4:	01c574b3          	and	s1,a0,t3
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    800031a8:	009805b3          	add	a1,a6,s1
    800031ac:	06b8ee63          	bltu	a7,a1,80003228 <sys_mmap+0x1da>
  int npages = 0;
    800031b0:	87da                	mv	a5,s6
  uint64 best = 0;
    800031b2:	8552                	mv	a0,s4
    800031b4:	bfc9                	j	80003186 <sys_mmap+0x138>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) goto bad;
  if(va < MMAPBASE || va + plen > MMAPTOP) goto bad;
    800031b6:	400007b7          	lui	a5,0x40000
    800031ba:	06f4e763          	bltu	s1,a5,80003228 <sys_mmap+0x1da>
    800031be:	99a6                	add	s3,s3,s1
    800031c0:	010007b7          	lui	a5,0x1000
    800031c4:	17f5                	addi	a5,a5,-3 # fffffd <_entry-0x7f000003>
    800031c6:	07ba                	slli	a5,a5,0xe
    800031c8:	0737e063          	bltu	a5,s3,80003228 <sys_mmap+0x1da>

  // 先写入 vma 基本信息
  v->used  = 1;
    800031cc:	00291793          	slli	a5,s2,0x2
    800031d0:	97ca                	add	a5,a5,s2
    800031d2:	078e                	slli	a5,a5,0x3
    800031d4:	97d6                	add	a5,a5,s5
    800031d6:	4705                	li	a4,1
    800031d8:	16e7a423          	sw	a4,360(a5)
  v->start = va;
    800031dc:	1697b823          	sd	s1,368(a5)
  v->end   = va + plen;
    800031e0:	1737bc23          	sd	s3,376(a5)
  v->prot  = prot;
    800031e4:	f9042703          	lw	a4,-112(s0)
    800031e8:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    800031ec:	f8c42703          	lw	a4,-116(s0)
    800031f0:	18e7a223          	sw	a4,388(a5)

  if(flags & MAP_SHARED){
    800031f4:	8b09                	andi	a4,a4,2
    800031f6:	c72d                	beqz	a4,80003260 <sys_mmap+0x212>
    if(need_get){
    800031f8:	020b9163          	bnez	s7,8000321a <sys_mmap+0x1cc>
      if(shm_get(key, npages) < 0)
        goto bad;
      did_shm_get = 1;
    }
    v->is_shm = 1;
    800031fc:	00291793          	slli	a5,s2,0x2
    80003200:	01278733          	add	a4,a5,s2
    80003204:	070e                	slli	a4,a4,0x3
    80003206:	9756                	add	a4,a4,s5
    80003208:	4685                	li	a3,1
    8000320a:	18d72423          	sw	a3,392(a4)
    v->shm_key = key;
    8000320e:	87ba                	mv	a5,a4
    80003210:	f8842703          	lw	a4,-120(s0)
    80003214:	18e7a623          	sw	a4,396(a5)
    80003218:	a0a1                	j	80003260 <sys_mmap+0x212>
      if(shm_get(key, npages) < 0)
    8000321a:	85e2                	mv	a1,s8
    8000321c:	f8842503          	lw	a0,-120(s0)
    80003220:	28c030ef          	jal	ra,800064ac <shm_get>
    80003224:	fc055ce3          	bgez	a0,800031fc <sys_mmap+0x1ae>
bad:
  if(did_shm_get){
    shm_put(key);
  }
  if(v){
    v->used = 0;
    80003228:	00291713          	slli	a4,s2,0x2
    8000322c:	012707b3          	add	a5,a4,s2
    80003230:	078e                	slli	a5,a5,0x3
    80003232:	97d6                	add	a5,a5,s5
    80003234:	1607a423          	sw	zero,360(a5)
    v->is_shm = 0;
    80003238:	1807a423          	sw	zero,392(a5)
    v->shm_key = -1;
    8000323c:	56fd                	li	a3,-1
    8000323e:	18d7a623          	sw	a3,396(a5)
    v->start = v->end = 0;
    80003242:	1607bc23          	sd	zero,376(a5)
    80003246:	1607b823          	sd	zero,368(a5)
    v->prot = v->flags = 0;
    8000324a:	1807a223          	sw	zero,388(a5)
    8000324e:	012707b3          	add	a5,a4,s2
    80003252:	078e                	slli	a5,a5,0x3
    80003254:	9abe                	add	s5,s5,a5
    80003256:	180aa023          	sw	zero,384(s5)
  }
  return (uint64)-1;
    8000325a:	54fd                	li	s1,-1
    8000325c:	a011                	j	80003260 <sys_mmap+0x212>
  if(len <= 0) return (uint64)-1;
    8000325e:	54fd                	li	s1,-1
}
    80003260:	8526                	mv	a0,s1
    80003262:	70e6                	ld	ra,120(sp)
    80003264:	7446                	ld	s0,112(sp)
    80003266:	74a6                	ld	s1,104(sp)
    80003268:	7906                	ld	s2,96(sp)
    8000326a:	69e6                	ld	s3,88(sp)
    8000326c:	6a46                	ld	s4,80(sp)
    8000326e:	6aa6                	ld	s5,72(sp)
    80003270:	6b06                	ld	s6,64(sp)
    80003272:	7be2                	ld	s7,56(sp)
    80003274:	7c42                	ld	s8,48(sp)
    80003276:	7ca2                	ld	s9,40(sp)
    80003278:	6109                	addi	sp,sp,128
    8000327a:	8082                	ret

000000008000327c <sys_munmap>:
}


uint64
sys_munmap(void)
{
    8000327c:	7159                	addi	sp,sp,-112
    8000327e:	f486                	sd	ra,104(sp)
    80003280:	f0a2                	sd	s0,96(sp)
    80003282:	eca6                	sd	s1,88(sp)
    80003284:	e8ca                	sd	s2,80(sp)
    80003286:	e4ce                	sd	s3,72(sp)
    80003288:	e0d2                	sd	s4,64(sp)
    8000328a:	fc56                	sd	s5,56(sp)
    8000328c:	f85a                	sd	s6,48(sp)
    8000328e:	f45e                	sd	s7,40(sp)
    80003290:	f062                	sd	s8,32(sp)
    80003292:	ec66                	sd	s9,24(sp)
    80003294:	e86a                	sd	s10,16(sp)
    80003296:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    80003298:	8b1fe0ef          	jal	ra,80001b48 <myproc>
    8000329c:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    8000329e:	f9840593          	addi	a1,s0,-104
    800032a2:	4501                	li	a0,0
    800032a4:	a9fff0ef          	jal	ra,80002d42 <argaddr>
  argint(1, &len);
    800032a8:	f9440593          	addi	a1,s0,-108
    800032ac:	4505                	li	a0,1
    800032ae:	a79ff0ef          	jal	ra,80002d26 <argint>

  if(len <= 0) return (uint64)-1;
    800032b2:	f9442683          	lw	a3,-108(s0)
    800032b6:	2cd05f63          	blez	a3,80003594 <sys_munmap+0x318>


  uint64 a = PGROUNDDOWN(uaddr);
    800032ba:	f9843783          	ld	a5,-104(s0)
    800032be:	767d                	lui	a2,0xfffff
    800032c0:	00c7fa33          	and	s4,a5,a2
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    800032c4:	6705                	lui	a4,0x1
    800032c6:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    800032c8:	00e78933          	add	s2,a5,a4
    800032cc:	9936                	add	s2,s2,a3
    800032ce:	00c97933          	and	s2,s2,a2
  if(b < a) return (uint64)-1;  // 溢出了
    800032d2:	557d                	li	a0,-1
    800032d4:	17496d63          	bltu	s2,s4,8000344e <sys_munmap+0x1d2>
    800032d8:	168a8b13          	addi	s6,s5,360
    800032dc:	3e8a8993          	addi	s3,s5,1000
    800032e0:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    800032e2:	4801                	li	a6,0
    800032e4:	a029                	j	800032ee <sys_munmap+0x72>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    800032e6:	02878793          	addi	a5,a5,40
    800032ea:	01378663          	beq	a5,s3,800032f6 <sys_munmap+0x7a>
    800032ee:	4398                	lw	a4,0(a5)
    800032f0:	fb7d                	bnez	a4,800032e6 <sys_munmap+0x6a>
    800032f2:	2805                	addiw	a6,a6,1
    800032f4:	bfcd                	j	800032e6 <sys_munmap+0x6a>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    800032f6:	8552                	mv	a0,s4
  int need_splits = 0;
    800032f8:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    800032fa:	4881                	li	a7,0
    800032fc:	45c1                	li	a1,16
    800032fe:	537d                	li	t1,-1
  while(cur < b){
    80003300:	072a6163          	bltu	s4,s2,80003362 <sys_munmap+0xe6>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    80003304:	43f85513          	srai	a0,a6,0x3f
    80003308:	a299                	j	8000344e <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    8000330a:	2705                	addiw	a4,a4,1
    8000330c:	02878793          	addi	a5,a5,40
    80003310:	04b70c63          	beq	a4,a1,80003368 <sys_munmap+0xec>
    if(!p->vmas[i].used) continue;
    80003314:	4394                	lw	a3,0(a5)
    80003316:	daf5                	beqz	a3,8000330a <sys_munmap+0x8e>
    if(!(b <= s || a >= e))   // overlap
    80003318:	6794                	ld	a3,8(a5)
    8000331a:	ff26f8e3          	bgeu	a3,s2,8000330a <sys_munmap+0x8e>
    8000331e:	6b94                	ld	a3,16(a5)
    80003320:	fed575e3          	bgeu	a0,a3,8000330a <sys_munmap+0x8e>
    if(vi < 0){
    80003324:	04074563          	bltz	a4,8000336e <sys_munmap+0xf2>
    uint64 seg_start = cur > v->start ? cur : v->start;
    80003328:	00271793          	slli	a5,a4,0x2
    8000332c:	97ba                	add	a5,a5,a4
    8000332e:	078e                	slli	a5,a5,0x3
    80003330:	97d6                	add	a5,a5,s5
    80003332:	1707b683          	ld	a3,368(a5)
    80003336:	8636                	mv	a2,a3
    80003338:	00a6f363          	bgeu	a3,a0,8000333e <sys_munmap+0xc2>
    8000333c:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    8000333e:	00271793          	slli	a5,a4,0x2
    80003342:	97ba                	add	a5,a5,a4
    80003344:	078e                	slli	a5,a5,0x3
    80003346:	97d6                	add	a5,a5,s5
    80003348:	1787b783          	ld	a5,376(a5)
    8000334c:	853e                	mv	a0,a5
    8000334e:	00f97363          	bgeu	s2,a5,80003354 <sys_munmap+0xd8>
    80003352:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    80003354:	00c6f563          	bgeu	a3,a2,8000335e <sys_munmap+0xe2>
    80003358:	00f57363          	bgeu	a0,a5,8000335e <sys_munmap+0xe2>
      need_splits++;
    8000335c:	2e05                	addiw	t3,t3,1 # fffffffffffff001 <end+0xffffffff7fdab289>
  while(cur < b){
    8000335e:	03257a63          	bgeu	a0,s2,80003392 <sys_munmap+0x116>
  int free_slots = 0;
    80003362:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003364:	8746                	mv	a4,a7
    80003366:	b77d                	j	80003314 <sys_munmap+0x98>
    80003368:	87da                	mv	a5,s6
    8000336a:	869a                	mv	a3,t1
    8000336c:	a801                	j	8000337c <sys_munmap+0x100>
    8000336e:	87da                	mv	a5,s6
    80003370:	869a                	mv	a3,t1
    80003372:	a029                	j	8000337c <sys_munmap+0x100>
  for(int i = 0; i < NVMA; i++){
    80003374:	02878793          	addi	a5,a5,40
    80003378:	01378b63          	beq	a5,s3,8000338e <sys_munmap+0x112>
    if(!p->vmas[i].used) continue;
    8000337c:	4398                	lw	a4,0(a5)
    8000337e:	db7d                	beqz	a4,80003374 <sys_munmap+0xf8>
    uint64 s = p->vmas[i].start;
    80003380:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    80003382:	fea769e3          	bltu	a4,a0,80003374 <sys_munmap+0xf8>
    80003386:	fed777e3          	bgeu	a4,a3,80003374 <sys_munmap+0xf8>
    8000338a:	86ba                	mv	a3,a4
    8000338c:	b7e5                	j	80003374 <sys_munmap+0xf8>
      if(ns == (uint64)-1 || ns >= b) break;
    8000338e:	0126e963          	bltu	a3,s2,800033a0 <sys_munmap+0x124>
    // 不做任何事，保持一致性
    return (uint64)-1;
    80003392:	557d                	li	a0,-1
  if(need_splits > free_slots){
    80003394:	0bc84d63          	blt	a6,t3,8000344e <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    80003398:	4c01                	li	s8,0
    8000339a:	4bc1                	li	s7,16
    8000339c:	5cfd                	li	s9,-1
    8000339e:	aac5                	j	8000358e <sys_munmap+0x312>
    800033a0:	8536                	mv	a0,a3
    800033a2:	b7c1                	j	80003362 <sys_munmap+0xe6>
    800033a4:	2485                	addiw	s1,s1,1 # 40000001 <_entry-0x3fffffff>
    800033a6:	02878793          	addi	a5,a5,40
    800033aa:	07748c63          	beq	s1,s7,80003422 <sys_munmap+0x1a6>
    if(!p->vmas[i].used) continue;
    800033ae:	4398                	lw	a4,0(a5)
    800033b0:	db75                	beqz	a4,800033a4 <sys_munmap+0x128>
    if(!(b <= s || a >= e))   // overlap
    800033b2:	6798                	ld	a4,8(a5)
    800033b4:	ff2778e3          	bgeu	a4,s2,800033a4 <sys_munmap+0x128>
    800033b8:	6b98                	ld	a4,16(a5)
    800033ba:	feea75e3          	bgeu	s4,a4,800033a4 <sys_munmap+0x128>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    800033be:	0604c563          	bltz	s1,80003428 <sys_munmap+0x1ac>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    800033c2:	00249793          	slli	a5,s1,0x2
    800033c6:	97a6                	add	a5,a5,s1
    800033c8:	078e                	slli	a5,a5,0x3
    800033ca:	97d6                	add	a5,a5,s5
    800033cc:	1707bd03          	ld	s10,368(a5)
    800033d0:	014d7363          	bgeu	s10,s4,800033d6 <sys_munmap+0x15a>
    800033d4:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    800033d6:	00249793          	slli	a5,s1,0x2
    800033da:	97a6                	add	a5,a5,s1
    800033dc:	078e                	slli	a5,a5,0x3
    800033de:	97d6                	add	a5,a5,s5
    800033e0:	1787ba03          	ld	s4,376(a5)
    800033e4:	01497363          	bgeu	s2,s4,800033ea <sys_munmap+0x16e>
    800033e8:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    800033ea:	094d6263          	bltu	s10,s4,8000346e <sys_munmap+0x1f2>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    800033ee:	00249793          	slli	a5,s1,0x2
    800033f2:	97a6                	add	a5,a5,s1
    800033f4:	078e                	slli	a5,a5,0x3
    800033f6:	97d6                	add	a5,a5,s5
    800033f8:	1707b783          	ld	a5,368(a5)
    800033fc:	11a7e463          	bltu	a5,s10,80003504 <sys_munmap+0x288>
    80003400:	00249793          	slli	a5,s1,0x2
    80003404:	97a6                	add	a5,a5,s1
    80003406:	078e                	slli	a5,a5,0x3
    80003408:	97d6                	add	a5,a5,s5
    8000340a:	1787b783          	ld	a5,376(a5)
    8000340e:	06fa7a63          	bgeu	s4,a5,80003482 <sys_munmap+0x206>
      //  v->shm_key, v->used, (void *)v->start, (void *)v->end);

      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    80003412:	00249793          	slli	a5,s1,0x2
    80003416:	97a6                	add	a5,a5,s1
    80003418:	078e                	slli	a5,a5,0x3
    8000341a:	97d6                	add	a5,a5,s5
    8000341c:	1747b823          	sd	s4,368(a5)
    80003420:	a2ad                	j	8000358a <sys_munmap+0x30e>
    80003422:	87da                	mv	a5,s6
    80003424:	86e6                	mv	a3,s9
    80003426:	a801                	j	80003436 <sys_munmap+0x1ba>
    80003428:	87da                	mv	a5,s6
    8000342a:	86e6                	mv	a3,s9
    8000342c:	a029                	j	80003436 <sys_munmap+0x1ba>
  for(int i = 0; i < NVMA; i++){
    8000342e:	02878793          	addi	a5,a5,40
    80003432:	01378b63          	beq	a5,s3,80003448 <sys_munmap+0x1cc>
    if(!p->vmas[i].used) continue;
    80003436:	4398                	lw	a4,0(a5)
    80003438:	db7d                	beqz	a4,8000342e <sys_munmap+0x1b2>
    uint64 s = p->vmas[i].start;
    8000343a:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    8000343c:	ff4769e3          	bltu	a4,s4,8000342e <sys_munmap+0x1b2>
    80003440:	fed777e3          	bgeu	a4,a3,8000342e <sys_munmap+0x1b2>
    80003444:	86ba                	mv	a3,a4
    80003446:	b7e5                	j	8000342e <sys_munmap+0x1b2>
      if(ns == (uint64)-1 || ns >= b) break;
    80003448:	0326e163          	bltu	a3,s2,8000346a <sys_munmap+0x1ee>
    }

    cur = seg_end;
  }
  //shm_dump(1);
  return 0;
    8000344c:	4501                	li	a0,0
}
    8000344e:	70a6                	ld	ra,104(sp)
    80003450:	7406                	ld	s0,96(sp)
    80003452:	64e6                	ld	s1,88(sp)
    80003454:	6946                	ld	s2,80(sp)
    80003456:	69a6                	ld	s3,72(sp)
    80003458:	6a06                	ld	s4,64(sp)
    8000345a:	7ae2                	ld	s5,56(sp)
    8000345c:	7b42                	ld	s6,48(sp)
    8000345e:	7ba2                	ld	s7,40(sp)
    80003460:	7c02                	ld	s8,32(sp)
    80003462:	6ce2                	ld	s9,24(sp)
    80003464:	6d42                	ld	s10,16(sp)
    80003466:	6165                	addi	sp,sp,112
    80003468:	8082                	ret
    8000346a:	8a36                	mv	s4,a3
    8000346c:	a20d                	j	8000358e <sys_munmap+0x312>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    8000346e:	41aa0633          	sub	a2,s4,s10
    80003472:	4685                	li	a3,1
    80003474:	8231                	srli	a2,a2,0xc
    80003476:	85ea                	mv	a1,s10
    80003478:	050ab503          	ld	a0,80(s5)
    8000347c:	e19fd0ef          	jal	ra,80001294 <uvmunmap>
    80003480:	b7bd                	j	800033ee <sys_munmap+0x172>
  if(v->used == 0) return;
    80003482:	00249793          	slli	a5,s1,0x2
    80003486:	97a6                	add	a5,a5,s1
    80003488:	078e                	slli	a5,a5,0x3
    8000348a:	97d6                	add	a5,a5,s5
    8000348c:	1687a783          	lw	a5,360(a5)
    80003490:	0e078d63          	beqz	a5,8000358a <sys_munmap+0x30e>
  if(v->is_shm){
    80003494:	00249793          	slli	a5,s1,0x2
    80003498:	97a6                	add	a5,a5,s1
    8000349a:	078e                	slli	a5,a5,0x3
    8000349c:	97d6                	add	a5,a5,s5
    8000349e:	1887a783          	lw	a5,392(a5)
    800034a2:	c785                	beqz	a5,800034ca <sys_munmap+0x24e>
    int key = v->shm_key;
    800034a4:	00249793          	slli	a5,s1,0x2
    800034a8:	00978733          	add	a4,a5,s1
    800034ac:	070e                	slli	a4,a4,0x3
    800034ae:	9756                	add	a4,a4,s5
    800034b0:	18c72d03          	lw	s10,396(a4)
    struct vma *v = &p->vmas[vi];
    800034b4:	00978633          	add	a2,a5,s1
    800034b8:	060e                	slli	a2,a2,0x3
    800034ba:	16860613          	addi	a2,a2,360 # fffffffffffff168 <end+0xffffffff7fdab3f0>
    if(!proc_has_shm_key(p, key, v)){
    800034be:	9656                	add	a2,a2,s5
    800034c0:	85ea                	mv	a1,s10
    800034c2:	8556                	mv	a0,s5
    800034c4:	92fff0ef          	jal	ra,80002df2 <proc_has_shm_key>
    800034c8:	c915                	beqz	a0,800034fc <sys_munmap+0x280>
  v->used = 0;
    800034ca:	00249713          	slli	a4,s1,0x2
    800034ce:	009707b3          	add	a5,a4,s1
    800034d2:	078e                	slli	a5,a5,0x3
    800034d4:	97d6                	add	a5,a5,s5
    800034d6:	1607a423          	sw	zero,360(a5)
  v->start = v->end = 0;
    800034da:	1607bc23          	sd	zero,376(a5)
    800034de:	1607b823          	sd	zero,368(a5)
  v->prot = v->flags = 0;
    800034e2:	1807a223          	sw	zero,388(a5)
    800034e6:	1807a023          	sw	zero,384(a5)
  v->is_shm = 0;
    800034ea:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    800034ee:	009707b3          	add	a5,a4,s1
    800034f2:	078e                	slli	a5,a5,0x3
    800034f4:	97d6                	add	a5,a5,s5
    800034f6:	1997a623          	sw	s9,396(a5)
    800034fa:	a841                	j	8000358a <sys_munmap+0x30e>
      shm_put(key);
    800034fc:	856a                	mv	a0,s10
    800034fe:	0f2030ef          	jal	ra,800065f0 <shm_put>
    80003502:	b7e1                	j	800034ca <sys_munmap+0x24e>
    } else if(seg_start > v->start && seg_end >= v->end){
    80003504:	00249793          	slli	a5,s1,0x2
    80003508:	97a6                	add	a5,a5,s1
    8000350a:	078e                	slli	a5,a5,0x3
    8000350c:	97d6                	add	a5,a5,s5
    8000350e:	1787b783          	ld	a5,376(a5)
    80003512:	00fa6a63          	bltu	s4,a5,80003526 <sys_munmap+0x2aa>
      v->end = seg_start;
    80003516:	00249793          	slli	a5,s1,0x2
    8000351a:	97a6                	add	a5,a5,s1
    8000351c:	078e                	slli	a5,a5,0x3
    8000351e:	97d6                	add	a5,a5,s5
    80003520:	17a7bc23          	sd	s10,376(a5)
    80003524:	a09d                	j	8000358a <sys_munmap+0x30e>
    80003526:	875a                	mv	a4,s6
    80003528:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    8000352a:	4314                	lw	a3,0(a4)
    8000352c:	c699                	beqz	a3,8000353a <sys_munmap+0x2be>
  for(int i = 0; i < NVMA; i++){
    8000352e:	2785                	addiw	a5,a5,1
    80003530:	02870713          	addi	a4,a4,40
    80003534:	ff779be3          	bne	a5,s7,8000352a <sys_munmap+0x2ae>
  return -1;
    80003538:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    8000353a:	00279593          	slli	a1,a5,0x2
    8000353e:	00f586b3          	add	a3,a1,a5
    80003542:	068e                	slli	a3,a3,0x3
    80003544:	96d6                	add	a3,a3,s5
    80003546:	00249613          	slli	a2,s1,0x2
    8000354a:	00960733          	add	a4,a2,s1
    8000354e:	070e                	slli	a4,a4,0x3
    80003550:	9756                	add	a4,a4,s5
    80003552:	16873303          	ld	t1,360(a4)
    80003556:	17873883          	ld	a7,376(a4)
    8000355a:	18073803          	ld	a6,384(a4)
    8000355e:	18873503          	ld	a0,392(a4)
    80003562:	1666b423          	sd	t1,360(a3) # 1168 <_entry-0x7fffee98>
    80003566:	1716bc23          	sd	a7,376(a3)
    8000356a:	1906b023          	sd	a6,384(a3)
    8000356e:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    80003572:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    80003576:	17873703          	ld	a4,376(a4)
    8000357a:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    8000357e:	009607b3          	add	a5,a2,s1
    80003582:	078e                	slli	a5,a5,0x3
    80003584:	97d6                	add	a5,a5,s5
    80003586:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    8000358a:	012a7763          	bgeu	s4,s2,80003598 <sys_munmap+0x31c>
  int need_splits = 0;
    8000358e:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003590:	84e2                	mv	s1,s8
    80003592:	bd31                	j	800033ae <sys_munmap+0x132>
  if(len <= 0) return (uint64)-1;
    80003594:	557d                	li	a0,-1
    80003596:	bd65                	j	8000344e <sys_munmap+0x1d2>
  return 0;
    80003598:	4501                	li	a0,0
    8000359a:	bd55                	j	8000344e <sys_munmap+0x1d2>

000000008000359c <sys_shmctl>:

uint64
sys_shmctl(void)
{
    8000359c:	1101                	addi	sp,sp,-32
    8000359e:	ec06                	sd	ra,24(sp)
    800035a0:	e822                	sd	s0,16(sp)
    800035a2:	1000                	addi	s0,sp,32
  int key, cmd;
  argint(0, &key);
    800035a4:	fec40593          	addi	a1,s0,-20
    800035a8:	4501                	li	a0,0
    800035aa:	f7cff0ef          	jal	ra,80002d26 <argint>
  argint(1, &cmd);
    800035ae:	fe840593          	addi	a1,s0,-24
    800035b2:	4505                	li	a0,1
    800035b4:	f72ff0ef          	jal	ra,80002d26 <argint>
  return shm_ctl(key, cmd);
    800035b8:	fe842583          	lw	a1,-24(s0)
    800035bc:	fec42503          	lw	a0,-20(s0)
    800035c0:	21e030ef          	jal	ra,800067de <shm_ctl>
}
    800035c4:	60e2                	ld	ra,24(sp)
    800035c6:	6442                	ld	s0,16(sp)
    800035c8:	6105                	addi	sp,sp,32
    800035ca:	8082                	ret

00000000800035cc <sys_sleep>:

uint64
sys_sleep(void)
{
    800035cc:	7139                	addi	sp,sp,-64
    800035ce:	fc06                	sd	ra,56(sp)
    800035d0:	f822                	sd	s0,48(sp)
    800035d2:	f426                	sd	s1,40(sp)
    800035d4:	f04a                	sd	s2,32(sp)
    800035d6:	ec4e                	sd	s3,24(sp)
    800035d8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800035da:	fcc40593          	addi	a1,s0,-52
    800035de:	4501                	li	a0,0
    800035e0:	f46ff0ef          	jal	ra,80002d26 <argint>
  if(n < 0)
    800035e4:	fcc42783          	lw	a5,-52(s0)
    return -1;
    800035e8:	557d                	li	a0,-1
  if(n < 0)
    800035ea:	0407ce63          	bltz	a5,80003646 <sys_sleep+0x7a>

  acquire(&tickslock);
    800035ee:	0023d517          	auipc	a0,0x23d
    800035f2:	21250513          	addi	a0,a0,530 # 80240800 <tickslock>
    800035f6:	eaafd0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    800035fa:	00005917          	auipc	s2,0x5
    800035fe:	2be92903          	lw	s2,702(s2) # 800088b8 <ticks>
  while(ticks - ticks0 < n){
    80003602:	fcc42783          	lw	a5,-52(s0)
    80003606:	cb8d                	beqz	a5,80003638 <sys_sleep+0x6c>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);  
    80003608:	0023d997          	auipc	s3,0x23d
    8000360c:	1f898993          	addi	s3,s3,504 # 80240800 <tickslock>
    80003610:	00005497          	auipc	s1,0x5
    80003614:	2a848493          	addi	s1,s1,680 # 800088b8 <ticks>
    if(killed(myproc())){
    80003618:	d30fe0ef          	jal	ra,80001b48 <myproc>
    8000361c:	80aff0ef          	jal	ra,80002626 <killed>
    80003620:	e915                	bnez	a0,80003654 <sys_sleep+0x88>
    sleep(&ticks, &tickslock);  
    80003622:	85ce                	mv	a1,s3
    80003624:	8526                	mv	a0,s1
    80003626:	dc9fe0ef          	jal	ra,800023ee <sleep>
  while(ticks - ticks0 < n){
    8000362a:	409c                	lw	a5,0(s1)
    8000362c:	412787bb          	subw	a5,a5,s2
    80003630:	fcc42703          	lw	a4,-52(s0)
    80003634:	fee7e2e3          	bltu	a5,a4,80003618 <sys_sleep+0x4c>
  }
  release(&tickslock);
    80003638:	0023d517          	auipc	a0,0x23d
    8000363c:	1c850513          	addi	a0,a0,456 # 80240800 <tickslock>
    80003640:	ef8fd0ef          	jal	ra,80000d38 <release>
  return 0;
    80003644:	4501                	li	a0,0
}
    80003646:	70e2                	ld	ra,56(sp)
    80003648:	7442                	ld	s0,48(sp)
    8000364a:	74a2                	ld	s1,40(sp)
    8000364c:	7902                	ld	s2,32(sp)
    8000364e:	69e2                	ld	s3,24(sp)
    80003650:	6121                	addi	sp,sp,64
    80003652:	8082                	ret
      release(&tickslock);
    80003654:	0023d517          	auipc	a0,0x23d
    80003658:	1ac50513          	addi	a0,a0,428 # 80240800 <tickslock>
    8000365c:	edcfd0ef          	jal	ra,80000d38 <release>
      return -1;
    80003660:	557d                	li	a0,-1
    80003662:	b7d5                	j	80003646 <sys_sleep+0x7a>

0000000080003664 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003664:	7179                	addi	sp,sp,-48
    80003666:	f406                	sd	ra,40(sp)
    80003668:	f022                	sd	s0,32(sp)
    8000366a:	ec26                	sd	s1,24(sp)
    8000366c:	e84a                	sd	s2,16(sp)
    8000366e:	e44e                	sd	s3,8(sp)
    80003670:	e052                	sd	s4,0(sp)
    80003672:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003674:	00005597          	auipc	a1,0x5
    80003678:	e5458593          	addi	a1,a1,-428 # 800084c8 <syscalls+0xd0>
    8000367c:	0023d517          	auipc	a0,0x23d
    80003680:	19c50513          	addi	a0,a0,412 # 80240818 <bcache>
    80003684:	d9cfd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003688:	00245797          	auipc	a5,0x245
    8000368c:	19078793          	addi	a5,a5,400 # 80248818 <bcache+0x8000>
    80003690:	00245717          	auipc	a4,0x245
    80003694:	3f070713          	addi	a4,a4,1008 # 80248a80 <bcache+0x8268>
    80003698:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000369c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036a0:	0023d497          	auipc	s1,0x23d
    800036a4:	19048493          	addi	s1,s1,400 # 80240830 <bcache+0x18>
    b->next = bcache.head.next;
    800036a8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036aa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036ac:	00005a17          	auipc	s4,0x5
    800036b0:	e24a0a13          	addi	s4,s4,-476 # 800084d0 <syscalls+0xd8>
    b->next = bcache.head.next;
    800036b4:	2b893783          	ld	a5,696(s2)
    800036b8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800036ba:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800036be:	85d2                	mv	a1,s4
    800036c0:	01048513          	addi	a0,s1,16
    800036c4:	302010ef          	jal	ra,800049c6 <initsleeplock>
    bcache.head.next->prev = b;
    800036c8:	2b893783          	ld	a5,696(s2)
    800036cc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800036ce:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036d2:	45848493          	addi	s1,s1,1112
    800036d6:	fd349fe3          	bne	s1,s3,800036b4 <binit+0x50>
  }
}
    800036da:	70a2                	ld	ra,40(sp)
    800036dc:	7402                	ld	s0,32(sp)
    800036de:	64e2                	ld	s1,24(sp)
    800036e0:	6942                	ld	s2,16(sp)
    800036e2:	69a2                	ld	s3,8(sp)
    800036e4:	6a02                	ld	s4,0(sp)
    800036e6:	6145                	addi	sp,sp,48
    800036e8:	8082                	ret

00000000800036ea <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800036ea:	7179                	addi	sp,sp,-48
    800036ec:	f406                	sd	ra,40(sp)
    800036ee:	f022                	sd	s0,32(sp)
    800036f0:	ec26                	sd	s1,24(sp)
    800036f2:	e84a                	sd	s2,16(sp)
    800036f4:	e44e                	sd	s3,8(sp)
    800036f6:	1800                	addi	s0,sp,48
    800036f8:	892a                	mv	s2,a0
    800036fa:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800036fc:	0023d517          	auipc	a0,0x23d
    80003700:	11c50513          	addi	a0,a0,284 # 80240818 <bcache>
    80003704:	d9cfd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003708:	00245497          	auipc	s1,0x245
    8000370c:	3c84b483          	ld	s1,968(s1) # 80248ad0 <bcache+0x82b8>
    80003710:	00245797          	auipc	a5,0x245
    80003714:	37078793          	addi	a5,a5,880 # 80248a80 <bcache+0x8268>
    80003718:	02f48b63          	beq	s1,a5,8000374e <bread+0x64>
    8000371c:	873e                	mv	a4,a5
    8000371e:	a021                	j	80003726 <bread+0x3c>
    80003720:	68a4                	ld	s1,80(s1)
    80003722:	02e48663          	beq	s1,a4,8000374e <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003726:	449c                	lw	a5,8(s1)
    80003728:	ff279ce3          	bne	a5,s2,80003720 <bread+0x36>
    8000372c:	44dc                	lw	a5,12(s1)
    8000372e:	ff3799e3          	bne	a5,s3,80003720 <bread+0x36>
      b->refcnt++;
    80003732:	40bc                	lw	a5,64(s1)
    80003734:	2785                	addiw	a5,a5,1
    80003736:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003738:	0023d517          	auipc	a0,0x23d
    8000373c:	0e050513          	addi	a0,a0,224 # 80240818 <bcache>
    80003740:	df8fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80003744:	01048513          	addi	a0,s1,16
    80003748:	2b4010ef          	jal	ra,800049fc <acquiresleep>
      return b;
    8000374c:	a889                	j	8000379e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000374e:	00245497          	auipc	s1,0x245
    80003752:	37a4b483          	ld	s1,890(s1) # 80248ac8 <bcache+0x82b0>
    80003756:	00245797          	auipc	a5,0x245
    8000375a:	32a78793          	addi	a5,a5,810 # 80248a80 <bcache+0x8268>
    8000375e:	00f48863          	beq	s1,a5,8000376e <bread+0x84>
    80003762:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003764:	40bc                	lw	a5,64(s1)
    80003766:	cb91                	beqz	a5,8000377a <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003768:	64a4                	ld	s1,72(s1)
    8000376a:	fee49de3          	bne	s1,a4,80003764 <bread+0x7a>
  panic("bget: no buffers");
    8000376e:	00005517          	auipc	a0,0x5
    80003772:	d6a50513          	addi	a0,a0,-662 # 800084d8 <syscalls+0xe0>
    80003776:	812fd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    8000377a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000377e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003782:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003786:	4785                	li	a5,1
    80003788:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000378a:	0023d517          	auipc	a0,0x23d
    8000378e:	08e50513          	addi	a0,a0,142 # 80240818 <bcache>
    80003792:	da6fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80003796:	01048513          	addi	a0,s1,16
    8000379a:	262010ef          	jal	ra,800049fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000379e:	409c                	lw	a5,0(s1)
    800037a0:	cb89                	beqz	a5,800037b2 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037a2:	8526                	mv	a0,s1
    800037a4:	70a2                	ld	ra,40(sp)
    800037a6:	7402                	ld	s0,32(sp)
    800037a8:	64e2                	ld	s1,24(sp)
    800037aa:	6942                	ld	s2,16(sp)
    800037ac:	69a2                	ld	s3,8(sp)
    800037ae:	6145                	addi	sp,sp,48
    800037b0:	8082                	ret
    virtio_disk_rw(b, 0);
    800037b2:	4581                	li	a1,0
    800037b4:	8526                	mv	a0,s1
    800037b6:	215020ef          	jal	ra,800061ca <virtio_disk_rw>
    b->valid = 1;
    800037ba:	4785                	li	a5,1
    800037bc:	c09c                	sw	a5,0(s1)
  return b;
    800037be:	b7d5                	j	800037a2 <bread+0xb8>

00000000800037c0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800037c0:	1101                	addi	sp,sp,-32
    800037c2:	ec06                	sd	ra,24(sp)
    800037c4:	e822                	sd	s0,16(sp)
    800037c6:	e426                	sd	s1,8(sp)
    800037c8:	1000                	addi	s0,sp,32
    800037ca:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037cc:	0541                	addi	a0,a0,16
    800037ce:	2ac010ef          	jal	ra,80004a7a <holdingsleep>
    800037d2:	c911                	beqz	a0,800037e6 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800037d4:	4585                	li	a1,1
    800037d6:	8526                	mv	a0,s1
    800037d8:	1f3020ef          	jal	ra,800061ca <virtio_disk_rw>
}
    800037dc:	60e2                	ld	ra,24(sp)
    800037de:	6442                	ld	s0,16(sp)
    800037e0:	64a2                	ld	s1,8(sp)
    800037e2:	6105                	addi	sp,sp,32
    800037e4:	8082                	ret
    panic("bwrite");
    800037e6:	00005517          	auipc	a0,0x5
    800037ea:	d0a50513          	addi	a0,a0,-758 # 800084f0 <syscalls+0xf8>
    800037ee:	f9bfc0ef          	jal	ra,80000788 <panic>

00000000800037f2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800037f2:	1101                	addi	sp,sp,-32
    800037f4:	ec06                	sd	ra,24(sp)
    800037f6:	e822                	sd	s0,16(sp)
    800037f8:	e426                	sd	s1,8(sp)
    800037fa:	e04a                	sd	s2,0(sp)
    800037fc:	1000                	addi	s0,sp,32
    800037fe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003800:	01050913          	addi	s2,a0,16
    80003804:	854a                	mv	a0,s2
    80003806:	274010ef          	jal	ra,80004a7a <holdingsleep>
    8000380a:	c13d                	beqz	a0,80003870 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    8000380c:	854a                	mv	a0,s2
    8000380e:	234010ef          	jal	ra,80004a42 <releasesleep>

  acquire(&bcache.lock);
    80003812:	0023d517          	auipc	a0,0x23d
    80003816:	00650513          	addi	a0,a0,6 # 80240818 <bcache>
    8000381a:	c86fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    8000381e:	40bc                	lw	a5,64(s1)
    80003820:	37fd                	addiw	a5,a5,-1
    80003822:	0007871b          	sext.w	a4,a5
    80003826:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003828:	eb05                	bnez	a4,80003858 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000382a:	68bc                	ld	a5,80(s1)
    8000382c:	64b8                	ld	a4,72(s1)
    8000382e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003830:	64bc                	ld	a5,72(s1)
    80003832:	68b8                	ld	a4,80(s1)
    80003834:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003836:	00245797          	auipc	a5,0x245
    8000383a:	fe278793          	addi	a5,a5,-30 # 80248818 <bcache+0x8000>
    8000383e:	2b87b703          	ld	a4,696(a5)
    80003842:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003844:	00245717          	auipc	a4,0x245
    80003848:	23c70713          	addi	a4,a4,572 # 80248a80 <bcache+0x8268>
    8000384c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000384e:	2b87b703          	ld	a4,696(a5)
    80003852:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003854:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003858:	0023d517          	auipc	a0,0x23d
    8000385c:	fc050513          	addi	a0,a0,-64 # 80240818 <bcache>
    80003860:	cd8fd0ef          	jal	ra,80000d38 <release>
}
    80003864:	60e2                	ld	ra,24(sp)
    80003866:	6442                	ld	s0,16(sp)
    80003868:	64a2                	ld	s1,8(sp)
    8000386a:	6902                	ld	s2,0(sp)
    8000386c:	6105                	addi	sp,sp,32
    8000386e:	8082                	ret
    panic("brelse");
    80003870:	00005517          	auipc	a0,0x5
    80003874:	c8850513          	addi	a0,a0,-888 # 800084f8 <syscalls+0x100>
    80003878:	f11fc0ef          	jal	ra,80000788 <panic>

000000008000387c <bpin>:

void
bpin(struct buf *b) {
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	e426                	sd	s1,8(sp)
    80003884:	1000                	addi	s0,sp,32
    80003886:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003888:	0023d517          	auipc	a0,0x23d
    8000388c:	f9050513          	addi	a0,a0,-112 # 80240818 <bcache>
    80003890:	c10fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    80003894:	40bc                	lw	a5,64(s1)
    80003896:	2785                	addiw	a5,a5,1
    80003898:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000389a:	0023d517          	auipc	a0,0x23d
    8000389e:	f7e50513          	addi	a0,a0,-130 # 80240818 <bcache>
    800038a2:	c96fd0ef          	jal	ra,80000d38 <release>
}
    800038a6:	60e2                	ld	ra,24(sp)
    800038a8:	6442                	ld	s0,16(sp)
    800038aa:	64a2                	ld	s1,8(sp)
    800038ac:	6105                	addi	sp,sp,32
    800038ae:	8082                	ret

00000000800038b0 <bunpin>:

void
bunpin(struct buf *b) {
    800038b0:	1101                	addi	sp,sp,-32
    800038b2:	ec06                	sd	ra,24(sp)
    800038b4:	e822                	sd	s0,16(sp)
    800038b6:	e426                	sd	s1,8(sp)
    800038b8:	1000                	addi	s0,sp,32
    800038ba:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038bc:	0023d517          	auipc	a0,0x23d
    800038c0:	f5c50513          	addi	a0,a0,-164 # 80240818 <bcache>
    800038c4:	bdcfd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    800038c8:	40bc                	lw	a5,64(s1)
    800038ca:	37fd                	addiw	a5,a5,-1
    800038cc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038ce:	0023d517          	auipc	a0,0x23d
    800038d2:	f4a50513          	addi	a0,a0,-182 # 80240818 <bcache>
    800038d6:	c62fd0ef          	jal	ra,80000d38 <release>
}
    800038da:	60e2                	ld	ra,24(sp)
    800038dc:	6442                	ld	s0,16(sp)
    800038de:	64a2                	ld	s1,8(sp)
    800038e0:	6105                	addi	sp,sp,32
    800038e2:	8082                	ret

00000000800038e4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038e4:	1101                	addi	sp,sp,-32
    800038e6:	ec06                	sd	ra,24(sp)
    800038e8:	e822                	sd	s0,16(sp)
    800038ea:	e426                	sd	s1,8(sp)
    800038ec:	e04a                	sd	s2,0(sp)
    800038ee:	1000                	addi	s0,sp,32
    800038f0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038f2:	00d5d59b          	srliw	a1,a1,0xd
    800038f6:	00245797          	auipc	a5,0x245
    800038fa:	5fe7a783          	lw	a5,1534(a5) # 80248ef4 <sb+0x1c>
    800038fe:	9dbd                	addw	a1,a1,a5
    80003900:	debff0ef          	jal	ra,800036ea <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003904:	0074f713          	andi	a4,s1,7
    80003908:	4785                	li	a5,1
    8000390a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000390e:	14ce                	slli	s1,s1,0x33
    80003910:	90d9                	srli	s1,s1,0x36
    80003912:	00950733          	add	a4,a0,s1
    80003916:	05874703          	lbu	a4,88(a4)
    8000391a:	00e7f6b3          	and	a3,a5,a4
    8000391e:	c29d                	beqz	a3,80003944 <bfree+0x60>
    80003920:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003922:	94aa                	add	s1,s1,a0
    80003924:	fff7c793          	not	a5,a5
    80003928:	8f7d                	and	a4,a4,a5
    8000392a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000392e:	7d7000ef          	jal	ra,80004904 <log_write>
  brelse(bp);
    80003932:	854a                	mv	a0,s2
    80003934:	ebfff0ef          	jal	ra,800037f2 <brelse>
}
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6902                	ld	s2,0(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret
    panic("freeing free block");
    80003944:	00005517          	auipc	a0,0x5
    80003948:	bbc50513          	addi	a0,a0,-1092 # 80008500 <syscalls+0x108>
    8000394c:	e3dfc0ef          	jal	ra,80000788 <panic>

0000000080003950 <balloc>:
{
    80003950:	711d                	addi	sp,sp,-96
    80003952:	ec86                	sd	ra,88(sp)
    80003954:	e8a2                	sd	s0,80(sp)
    80003956:	e4a6                	sd	s1,72(sp)
    80003958:	e0ca                	sd	s2,64(sp)
    8000395a:	fc4e                	sd	s3,56(sp)
    8000395c:	f852                	sd	s4,48(sp)
    8000395e:	f456                	sd	s5,40(sp)
    80003960:	f05a                	sd	s6,32(sp)
    80003962:	ec5e                	sd	s7,24(sp)
    80003964:	e862                	sd	s8,16(sp)
    80003966:	e466                	sd	s9,8(sp)
    80003968:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000396a:	00245797          	auipc	a5,0x245
    8000396e:	5727a783          	lw	a5,1394(a5) # 80248edc <sb+0x4>
    80003972:	cff1                	beqz	a5,80003a4e <balloc+0xfe>
    80003974:	8baa                	mv	s7,a0
    80003976:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003978:	00245b17          	auipc	s6,0x245
    8000397c:	560b0b13          	addi	s6,s6,1376 # 80248ed8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003980:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003982:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003984:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003986:	6c89                	lui	s9,0x2
    80003988:	a0b5                	j	800039f4 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000398a:	97ca                	add	a5,a5,s2
    8000398c:	8e55                	or	a2,a2,a3
    8000398e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003992:	854a                	mv	a0,s2
    80003994:	771000ef          	jal	ra,80004904 <log_write>
        brelse(bp);
    80003998:	854a                	mv	a0,s2
    8000399a:	e59ff0ef          	jal	ra,800037f2 <brelse>
  bp = bread(dev, bno);
    8000399e:	85a6                	mv	a1,s1
    800039a0:	855e                	mv	a0,s7
    800039a2:	d49ff0ef          	jal	ra,800036ea <bread>
    800039a6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039a8:	40000613          	li	a2,1024
    800039ac:	4581                	li	a1,0
    800039ae:	05850513          	addi	a0,a0,88
    800039b2:	bc2fd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    800039b6:	854a                	mv	a0,s2
    800039b8:	74d000ef          	jal	ra,80004904 <log_write>
  brelse(bp);
    800039bc:	854a                	mv	a0,s2
    800039be:	e35ff0ef          	jal	ra,800037f2 <brelse>
}
    800039c2:	8526                	mv	a0,s1
    800039c4:	60e6                	ld	ra,88(sp)
    800039c6:	6446                	ld	s0,80(sp)
    800039c8:	64a6                	ld	s1,72(sp)
    800039ca:	6906                	ld	s2,64(sp)
    800039cc:	79e2                	ld	s3,56(sp)
    800039ce:	7a42                	ld	s4,48(sp)
    800039d0:	7aa2                	ld	s5,40(sp)
    800039d2:	7b02                	ld	s6,32(sp)
    800039d4:	6be2                	ld	s7,24(sp)
    800039d6:	6c42                	ld	s8,16(sp)
    800039d8:	6ca2                	ld	s9,8(sp)
    800039da:	6125                	addi	sp,sp,96
    800039dc:	8082                	ret
    brelse(bp);
    800039de:	854a                	mv	a0,s2
    800039e0:	e13ff0ef          	jal	ra,800037f2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800039e4:	015c87bb          	addw	a5,s9,s5
    800039e8:	00078a9b          	sext.w	s5,a5
    800039ec:	004b2703          	lw	a4,4(s6)
    800039f0:	04eaff63          	bgeu	s5,a4,80003a4e <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    800039f4:	41fad79b          	sraiw	a5,s5,0x1f
    800039f8:	0137d79b          	srliw	a5,a5,0x13
    800039fc:	015787bb          	addw	a5,a5,s5
    80003a00:	40d7d79b          	sraiw	a5,a5,0xd
    80003a04:	01cb2583          	lw	a1,28(s6)
    80003a08:	9dbd                	addw	a1,a1,a5
    80003a0a:	855e                	mv	a0,s7
    80003a0c:	cdfff0ef          	jal	ra,800036ea <bread>
    80003a10:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a12:	004b2503          	lw	a0,4(s6)
    80003a16:	000a849b          	sext.w	s1,s5
    80003a1a:	8762                	mv	a4,s8
    80003a1c:	fca4f1e3          	bgeu	s1,a0,800039de <balloc+0x8e>
      m = 1 << (bi % 8);
    80003a20:	00777693          	andi	a3,a4,7
    80003a24:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a28:	41f7579b          	sraiw	a5,a4,0x1f
    80003a2c:	01d7d79b          	srliw	a5,a5,0x1d
    80003a30:	9fb9                	addw	a5,a5,a4
    80003a32:	4037d79b          	sraiw	a5,a5,0x3
    80003a36:	00f90633          	add	a2,s2,a5
    80003a3a:	05864603          	lbu	a2,88(a2)
    80003a3e:	00c6f5b3          	and	a1,a3,a2
    80003a42:	d5a1                	beqz	a1,8000398a <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a44:	2705                	addiw	a4,a4,1
    80003a46:	2485                	addiw	s1,s1,1
    80003a48:	fd471ae3          	bne	a4,s4,80003a1c <balloc+0xcc>
    80003a4c:	bf49                	j	800039de <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003a4e:	00005517          	auipc	a0,0x5
    80003a52:	aca50513          	addi	a0,a0,-1334 # 80008518 <syscalls+0x120>
    80003a56:	a6dfc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003a5a:	4481                	li	s1,0
    80003a5c:	b79d                	j	800039c2 <balloc+0x72>

0000000080003a5e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a5e:	7179                	addi	sp,sp,-48
    80003a60:	f406                	sd	ra,40(sp)
    80003a62:	f022                	sd	s0,32(sp)
    80003a64:	ec26                	sd	s1,24(sp)
    80003a66:	e84a                	sd	s2,16(sp)
    80003a68:	e44e                	sd	s3,8(sp)
    80003a6a:	e052                	sd	s4,0(sp)
    80003a6c:	1800                	addi	s0,sp,48
    80003a6e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a70:	47ad                	li	a5,11
    80003a72:	02b7e663          	bltu	a5,a1,80003a9e <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80003a76:	02059793          	slli	a5,a1,0x20
    80003a7a:	01e7d593          	srli	a1,a5,0x1e
    80003a7e:	00b504b3          	add	s1,a0,a1
    80003a82:	0504a903          	lw	s2,80(s1)
    80003a86:	06091663          	bnez	s2,80003af2 <bmap+0x94>
      addr = balloc(ip->dev);
    80003a8a:	4108                	lw	a0,0(a0)
    80003a8c:	ec5ff0ef          	jal	ra,80003950 <balloc>
    80003a90:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a94:	04090f63          	beqz	s2,80003af2 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80003a98:	0524a823          	sw	s2,80(s1)
    80003a9c:	a899                	j	80003af2 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003a9e:	ff45849b          	addiw	s1,a1,-12
    80003aa2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003aa6:	0ff00793          	li	a5,255
    80003aaa:	06e7eb63          	bltu	a5,a4,80003b20 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003aae:	08052903          	lw	s2,128(a0)
    80003ab2:	00091b63          	bnez	s2,80003ac8 <bmap+0x6a>
      addr = balloc(ip->dev);
    80003ab6:	4108                	lw	a0,0(a0)
    80003ab8:	e99ff0ef          	jal	ra,80003950 <balloc>
    80003abc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ac0:	02090963          	beqz	s2,80003af2 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003ac4:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003ac8:	85ca                	mv	a1,s2
    80003aca:	0009a503          	lw	a0,0(s3)
    80003ace:	c1dff0ef          	jal	ra,800036ea <bread>
    80003ad2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003ad4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003ad8:	02049713          	slli	a4,s1,0x20
    80003adc:	01e75593          	srli	a1,a4,0x1e
    80003ae0:	00b784b3          	add	s1,a5,a1
    80003ae4:	0004a903          	lw	s2,0(s1)
    80003ae8:	00090e63          	beqz	s2,80003b04 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003aec:	8552                	mv	a0,s4
    80003aee:	d05ff0ef          	jal	ra,800037f2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003af2:	854a                	mv	a0,s2
    80003af4:	70a2                	ld	ra,40(sp)
    80003af6:	7402                	ld	s0,32(sp)
    80003af8:	64e2                	ld	s1,24(sp)
    80003afa:	6942                	ld	s2,16(sp)
    80003afc:	69a2                	ld	s3,8(sp)
    80003afe:	6a02                	ld	s4,0(sp)
    80003b00:	6145                	addi	sp,sp,48
    80003b02:	8082                	ret
      addr = balloc(ip->dev);
    80003b04:	0009a503          	lw	a0,0(s3)
    80003b08:	e49ff0ef          	jal	ra,80003950 <balloc>
    80003b0c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003b10:	fc090ee3          	beqz	s2,80003aec <bmap+0x8e>
        a[bn] = addr;
    80003b14:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b18:	8552                	mv	a0,s4
    80003b1a:	5eb000ef          	jal	ra,80004904 <log_write>
    80003b1e:	b7f9                	j	80003aec <bmap+0x8e>
  panic("bmap: out of range");
    80003b20:	00005517          	auipc	a0,0x5
    80003b24:	a1050513          	addi	a0,a0,-1520 # 80008530 <syscalls+0x138>
    80003b28:	c61fc0ef          	jal	ra,80000788 <panic>

0000000080003b2c <iget>:
{
    80003b2c:	7179                	addi	sp,sp,-48
    80003b2e:	f406                	sd	ra,40(sp)
    80003b30:	f022                	sd	s0,32(sp)
    80003b32:	ec26                	sd	s1,24(sp)
    80003b34:	e84a                	sd	s2,16(sp)
    80003b36:	e44e                	sd	s3,8(sp)
    80003b38:	e052                	sd	s4,0(sp)
    80003b3a:	1800                	addi	s0,sp,48
    80003b3c:	89aa                	mv	s3,a0
    80003b3e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b40:	00245517          	auipc	a0,0x245
    80003b44:	3b850513          	addi	a0,a0,952 # 80248ef8 <itable>
    80003b48:	958fd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003b4c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b4e:	00245497          	auipc	s1,0x245
    80003b52:	3c248493          	addi	s1,s1,962 # 80248f10 <itable+0x18>
    80003b56:	00247697          	auipc	a3,0x247
    80003b5a:	e4a68693          	addi	a3,a3,-438 # 8024a9a0 <log>
    80003b5e:	a039                	j	80003b6c <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b60:	02090963          	beqz	s2,80003b92 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b64:	08848493          	addi	s1,s1,136
    80003b68:	02d48863          	beq	s1,a3,80003b98 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b6c:	449c                	lw	a5,8(s1)
    80003b6e:	fef059e3          	blez	a5,80003b60 <iget+0x34>
    80003b72:	4098                	lw	a4,0(s1)
    80003b74:	ff3716e3          	bne	a4,s3,80003b60 <iget+0x34>
    80003b78:	40d8                	lw	a4,4(s1)
    80003b7a:	ff4713e3          	bne	a4,s4,80003b60 <iget+0x34>
      ip->ref++;
    80003b7e:	2785                	addiw	a5,a5,1
    80003b80:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003b82:	00245517          	auipc	a0,0x245
    80003b86:	37650513          	addi	a0,a0,886 # 80248ef8 <itable>
    80003b8a:	9aefd0ef          	jal	ra,80000d38 <release>
      return ip;
    80003b8e:	8926                	mv	s2,s1
    80003b90:	a02d                	j	80003bba <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b92:	fbe9                	bnez	a5,80003b64 <iget+0x38>
    80003b94:	8926                	mv	s2,s1
    80003b96:	b7f9                	j	80003b64 <iget+0x38>
  if(empty == 0)
    80003b98:	02090a63          	beqz	s2,80003bcc <iget+0xa0>
  ip->dev = dev;
    80003b9c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003ba0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ba4:	4785                	li	a5,1
    80003ba6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003baa:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003bae:	00245517          	auipc	a0,0x245
    80003bb2:	34a50513          	addi	a0,a0,842 # 80248ef8 <itable>
    80003bb6:	982fd0ef          	jal	ra,80000d38 <release>
}
    80003bba:	854a                	mv	a0,s2
    80003bbc:	70a2                	ld	ra,40(sp)
    80003bbe:	7402                	ld	s0,32(sp)
    80003bc0:	64e2                	ld	s1,24(sp)
    80003bc2:	6942                	ld	s2,16(sp)
    80003bc4:	69a2                	ld	s3,8(sp)
    80003bc6:	6a02                	ld	s4,0(sp)
    80003bc8:	6145                	addi	sp,sp,48
    80003bca:	8082                	ret
    panic("iget: no inodes");
    80003bcc:	00005517          	auipc	a0,0x5
    80003bd0:	97c50513          	addi	a0,a0,-1668 # 80008548 <syscalls+0x150>
    80003bd4:	bb5fc0ef          	jal	ra,80000788 <panic>

0000000080003bd8 <iinit>:
{
    80003bd8:	7179                	addi	sp,sp,-48
    80003bda:	f406                	sd	ra,40(sp)
    80003bdc:	f022                	sd	s0,32(sp)
    80003bde:	ec26                	sd	s1,24(sp)
    80003be0:	e84a                	sd	s2,16(sp)
    80003be2:	e44e                	sd	s3,8(sp)
    80003be4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003be6:	00005597          	auipc	a1,0x5
    80003bea:	97258593          	addi	a1,a1,-1678 # 80008558 <syscalls+0x160>
    80003bee:	00245517          	auipc	a0,0x245
    80003bf2:	30a50513          	addi	a0,a0,778 # 80248ef8 <itable>
    80003bf6:	82afd0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bfa:	00245497          	auipc	s1,0x245
    80003bfe:	32648493          	addi	s1,s1,806 # 80248f20 <itable+0x28>
    80003c02:	00247997          	auipc	s3,0x247
    80003c06:	dae98993          	addi	s3,s3,-594 # 8024a9b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c0a:	00005917          	auipc	s2,0x5
    80003c0e:	95690913          	addi	s2,s2,-1706 # 80008560 <syscalls+0x168>
    80003c12:	85ca                	mv	a1,s2
    80003c14:	8526                	mv	a0,s1
    80003c16:	5b1000ef          	jal	ra,800049c6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c1a:	08848493          	addi	s1,s1,136
    80003c1e:	ff349ae3          	bne	s1,s3,80003c12 <iinit+0x3a>
}
    80003c22:	70a2                	ld	ra,40(sp)
    80003c24:	7402                	ld	s0,32(sp)
    80003c26:	64e2                	ld	s1,24(sp)
    80003c28:	6942                	ld	s2,16(sp)
    80003c2a:	69a2                	ld	s3,8(sp)
    80003c2c:	6145                	addi	sp,sp,48
    80003c2e:	8082                	ret

0000000080003c30 <ialloc>:
{
    80003c30:	715d                	addi	sp,sp,-80
    80003c32:	e486                	sd	ra,72(sp)
    80003c34:	e0a2                	sd	s0,64(sp)
    80003c36:	fc26                	sd	s1,56(sp)
    80003c38:	f84a                	sd	s2,48(sp)
    80003c3a:	f44e                	sd	s3,40(sp)
    80003c3c:	f052                	sd	s4,32(sp)
    80003c3e:	ec56                	sd	s5,24(sp)
    80003c40:	e85a                	sd	s6,16(sp)
    80003c42:	e45e                	sd	s7,8(sp)
    80003c44:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c46:	00245717          	auipc	a4,0x245
    80003c4a:	29e72703          	lw	a4,670(a4) # 80248ee4 <sb+0xc>
    80003c4e:	4785                	li	a5,1
    80003c50:	04e7f663          	bgeu	a5,a4,80003c9c <ialloc+0x6c>
    80003c54:	8aaa                	mv	s5,a0
    80003c56:	8bae                	mv	s7,a1
    80003c58:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c5a:	00245a17          	auipc	s4,0x245
    80003c5e:	27ea0a13          	addi	s4,s4,638 # 80248ed8 <sb>
    80003c62:	00048b1b          	sext.w	s6,s1
    80003c66:	0044d593          	srli	a1,s1,0x4
    80003c6a:	018a2783          	lw	a5,24(s4)
    80003c6e:	9dbd                	addw	a1,a1,a5
    80003c70:	8556                	mv	a0,s5
    80003c72:	a79ff0ef          	jal	ra,800036ea <bread>
    80003c76:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c78:	05850993          	addi	s3,a0,88
    80003c7c:	00f4f793          	andi	a5,s1,15
    80003c80:	079a                	slli	a5,a5,0x6
    80003c82:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c84:	00099783          	lh	a5,0(s3)
    80003c88:	cf85                	beqz	a5,80003cc0 <ialloc+0x90>
    brelse(bp);
    80003c8a:	b69ff0ef          	jal	ra,800037f2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c8e:	0485                	addi	s1,s1,1
    80003c90:	00ca2703          	lw	a4,12(s4)
    80003c94:	0004879b          	sext.w	a5,s1
    80003c98:	fce7e5e3          	bltu	a5,a4,80003c62 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	8cc50513          	addi	a0,a0,-1844 # 80008568 <syscalls+0x170>
    80003ca4:	81ffc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003ca8:	4501                	li	a0,0
}
    80003caa:	60a6                	ld	ra,72(sp)
    80003cac:	6406                	ld	s0,64(sp)
    80003cae:	74e2                	ld	s1,56(sp)
    80003cb0:	7942                	ld	s2,48(sp)
    80003cb2:	79a2                	ld	s3,40(sp)
    80003cb4:	7a02                	ld	s4,32(sp)
    80003cb6:	6ae2                	ld	s5,24(sp)
    80003cb8:	6b42                	ld	s6,16(sp)
    80003cba:	6ba2                	ld	s7,8(sp)
    80003cbc:	6161                	addi	sp,sp,80
    80003cbe:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003cc0:	04000613          	li	a2,64
    80003cc4:	4581                	li	a1,0
    80003cc6:	854e                	mv	a0,s3
    80003cc8:	8acfd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    80003ccc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003cd0:	854a                	mv	a0,s2
    80003cd2:	433000ef          	jal	ra,80004904 <log_write>
      brelse(bp);
    80003cd6:	854a                	mv	a0,s2
    80003cd8:	b1bff0ef          	jal	ra,800037f2 <brelse>
      return iget(dev, inum);
    80003cdc:	85da                	mv	a1,s6
    80003cde:	8556                	mv	a0,s5
    80003ce0:	e4dff0ef          	jal	ra,80003b2c <iget>
    80003ce4:	b7d9                	j	80003caa <ialloc+0x7a>

0000000080003ce6 <iupdate>:
{
    80003ce6:	1101                	addi	sp,sp,-32
    80003ce8:	ec06                	sd	ra,24(sp)
    80003cea:	e822                	sd	s0,16(sp)
    80003cec:	e426                	sd	s1,8(sp)
    80003cee:	e04a                	sd	s2,0(sp)
    80003cf0:	1000                	addi	s0,sp,32
    80003cf2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cf4:	415c                	lw	a5,4(a0)
    80003cf6:	0047d79b          	srliw	a5,a5,0x4
    80003cfa:	00245597          	auipc	a1,0x245
    80003cfe:	1f65a583          	lw	a1,502(a1) # 80248ef0 <sb+0x18>
    80003d02:	9dbd                	addw	a1,a1,a5
    80003d04:	4108                	lw	a0,0(a0)
    80003d06:	9e5ff0ef          	jal	ra,800036ea <bread>
    80003d0a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d0c:	05850793          	addi	a5,a0,88
    80003d10:	40d8                	lw	a4,4(s1)
    80003d12:	8b3d                	andi	a4,a4,15
    80003d14:	071a                	slli	a4,a4,0x6
    80003d16:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d18:	04449703          	lh	a4,68(s1)
    80003d1c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d20:	04649703          	lh	a4,70(s1)
    80003d24:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003d28:	04849703          	lh	a4,72(s1)
    80003d2c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003d30:	04a49703          	lh	a4,74(s1)
    80003d34:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003d38:	44f8                	lw	a4,76(s1)
    80003d3a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d3c:	03400613          	li	a2,52
    80003d40:	05048593          	addi	a1,s1,80
    80003d44:	00c78513          	addi	a0,a5,12
    80003d48:	888fd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003d4c:	854a                	mv	a0,s2
    80003d4e:	3b7000ef          	jal	ra,80004904 <log_write>
  brelse(bp);
    80003d52:	854a                	mv	a0,s2
    80003d54:	a9fff0ef          	jal	ra,800037f2 <brelse>
}
    80003d58:	60e2                	ld	ra,24(sp)
    80003d5a:	6442                	ld	s0,16(sp)
    80003d5c:	64a2                	ld	s1,8(sp)
    80003d5e:	6902                	ld	s2,0(sp)
    80003d60:	6105                	addi	sp,sp,32
    80003d62:	8082                	ret

0000000080003d64 <idup>:
{
    80003d64:	1101                	addi	sp,sp,-32
    80003d66:	ec06                	sd	ra,24(sp)
    80003d68:	e822                	sd	s0,16(sp)
    80003d6a:	e426                	sd	s1,8(sp)
    80003d6c:	1000                	addi	s0,sp,32
    80003d6e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d70:	00245517          	auipc	a0,0x245
    80003d74:	18850513          	addi	a0,a0,392 # 80248ef8 <itable>
    80003d78:	f29fc0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    80003d7c:	449c                	lw	a5,8(s1)
    80003d7e:	2785                	addiw	a5,a5,1
    80003d80:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d82:	00245517          	auipc	a0,0x245
    80003d86:	17650513          	addi	a0,a0,374 # 80248ef8 <itable>
    80003d8a:	faffc0ef          	jal	ra,80000d38 <release>
}
    80003d8e:	8526                	mv	a0,s1
    80003d90:	60e2                	ld	ra,24(sp)
    80003d92:	6442                	ld	s0,16(sp)
    80003d94:	64a2                	ld	s1,8(sp)
    80003d96:	6105                	addi	sp,sp,32
    80003d98:	8082                	ret

0000000080003d9a <ilock>:
{
    80003d9a:	1101                	addi	sp,sp,-32
    80003d9c:	ec06                	sd	ra,24(sp)
    80003d9e:	e822                	sd	s0,16(sp)
    80003da0:	e426                	sd	s1,8(sp)
    80003da2:	e04a                	sd	s2,0(sp)
    80003da4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003da6:	c105                	beqz	a0,80003dc6 <ilock+0x2c>
    80003da8:	84aa                	mv	s1,a0
    80003daa:	451c                	lw	a5,8(a0)
    80003dac:	00f05d63          	blez	a5,80003dc6 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003db0:	0541                	addi	a0,a0,16
    80003db2:	44b000ef          	jal	ra,800049fc <acquiresleep>
  if(ip->valid == 0){
    80003db6:	40bc                	lw	a5,64(s1)
    80003db8:	cf89                	beqz	a5,80003dd2 <ilock+0x38>
}
    80003dba:	60e2                	ld	ra,24(sp)
    80003dbc:	6442                	ld	s0,16(sp)
    80003dbe:	64a2                	ld	s1,8(sp)
    80003dc0:	6902                	ld	s2,0(sp)
    80003dc2:	6105                	addi	sp,sp,32
    80003dc4:	8082                	ret
    panic("ilock");
    80003dc6:	00004517          	auipc	a0,0x4
    80003dca:	7ba50513          	addi	a0,a0,1978 # 80008580 <syscalls+0x188>
    80003dce:	9bbfc0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dd2:	40dc                	lw	a5,4(s1)
    80003dd4:	0047d79b          	srliw	a5,a5,0x4
    80003dd8:	00245597          	auipc	a1,0x245
    80003ddc:	1185a583          	lw	a1,280(a1) # 80248ef0 <sb+0x18>
    80003de0:	9dbd                	addw	a1,a1,a5
    80003de2:	4088                	lw	a0,0(s1)
    80003de4:	907ff0ef          	jal	ra,800036ea <bread>
    80003de8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003dea:	05850593          	addi	a1,a0,88
    80003dee:	40dc                	lw	a5,4(s1)
    80003df0:	8bbd                	andi	a5,a5,15
    80003df2:	079a                	slli	a5,a5,0x6
    80003df4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003df6:	00059783          	lh	a5,0(a1)
    80003dfa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003dfe:	00259783          	lh	a5,2(a1)
    80003e02:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e06:	00459783          	lh	a5,4(a1)
    80003e0a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e0e:	00659783          	lh	a5,6(a1)
    80003e12:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e16:	459c                	lw	a5,8(a1)
    80003e18:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e1a:	03400613          	li	a2,52
    80003e1e:	05b1                	addi	a1,a1,12
    80003e20:	05048513          	addi	a0,s1,80
    80003e24:	fadfc0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    80003e28:	854a                	mv	a0,s2
    80003e2a:	9c9ff0ef          	jal	ra,800037f2 <brelse>
    ip->valid = 1;
    80003e2e:	4785                	li	a5,1
    80003e30:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e32:	04449783          	lh	a5,68(s1)
    80003e36:	f3d1                	bnez	a5,80003dba <ilock+0x20>
      panic("ilock: no type");
    80003e38:	00004517          	auipc	a0,0x4
    80003e3c:	75050513          	addi	a0,a0,1872 # 80008588 <syscalls+0x190>
    80003e40:	949fc0ef          	jal	ra,80000788 <panic>

0000000080003e44 <iunlock>:
{
    80003e44:	1101                	addi	sp,sp,-32
    80003e46:	ec06                	sd	ra,24(sp)
    80003e48:	e822                	sd	s0,16(sp)
    80003e4a:	e426                	sd	s1,8(sp)
    80003e4c:	e04a                	sd	s2,0(sp)
    80003e4e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e50:	c505                	beqz	a0,80003e78 <iunlock+0x34>
    80003e52:	84aa                	mv	s1,a0
    80003e54:	01050913          	addi	s2,a0,16
    80003e58:	854a                	mv	a0,s2
    80003e5a:	421000ef          	jal	ra,80004a7a <holdingsleep>
    80003e5e:	cd09                	beqz	a0,80003e78 <iunlock+0x34>
    80003e60:	449c                	lw	a5,8(s1)
    80003e62:	00f05b63          	blez	a5,80003e78 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003e66:	854a                	mv	a0,s2
    80003e68:	3db000ef          	jal	ra,80004a42 <releasesleep>
}
    80003e6c:	60e2                	ld	ra,24(sp)
    80003e6e:	6442                	ld	s0,16(sp)
    80003e70:	64a2                	ld	s1,8(sp)
    80003e72:	6902                	ld	s2,0(sp)
    80003e74:	6105                	addi	sp,sp,32
    80003e76:	8082                	ret
    panic("iunlock");
    80003e78:	00004517          	auipc	a0,0x4
    80003e7c:	72050513          	addi	a0,a0,1824 # 80008598 <syscalls+0x1a0>
    80003e80:	909fc0ef          	jal	ra,80000788 <panic>

0000000080003e84 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e84:	7179                	addi	sp,sp,-48
    80003e86:	f406                	sd	ra,40(sp)
    80003e88:	f022                	sd	s0,32(sp)
    80003e8a:	ec26                	sd	s1,24(sp)
    80003e8c:	e84a                	sd	s2,16(sp)
    80003e8e:	e44e                	sd	s3,8(sp)
    80003e90:	e052                	sd	s4,0(sp)
    80003e92:	1800                	addi	s0,sp,48
    80003e94:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e96:	05050493          	addi	s1,a0,80
    80003e9a:	08050913          	addi	s2,a0,128
    80003e9e:	a021                	j	80003ea6 <itrunc+0x22>
    80003ea0:	0491                	addi	s1,s1,4
    80003ea2:	01248b63          	beq	s1,s2,80003eb8 <itrunc+0x34>
    if(ip->addrs[i]){
    80003ea6:	408c                	lw	a1,0(s1)
    80003ea8:	dde5                	beqz	a1,80003ea0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003eaa:	0009a503          	lw	a0,0(s3)
    80003eae:	a37ff0ef          	jal	ra,800038e4 <bfree>
      ip->addrs[i] = 0;
    80003eb2:	0004a023          	sw	zero,0(s1)
    80003eb6:	b7ed                	j	80003ea0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003eb8:	0809a583          	lw	a1,128(s3)
    80003ebc:	ed91                	bnez	a1,80003ed8 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ebe:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ec2:	854e                	mv	a0,s3
    80003ec4:	e23ff0ef          	jal	ra,80003ce6 <iupdate>
}
    80003ec8:	70a2                	ld	ra,40(sp)
    80003eca:	7402                	ld	s0,32(sp)
    80003ecc:	64e2                	ld	s1,24(sp)
    80003ece:	6942                	ld	s2,16(sp)
    80003ed0:	69a2                	ld	s3,8(sp)
    80003ed2:	6a02                	ld	s4,0(sp)
    80003ed4:	6145                	addi	sp,sp,48
    80003ed6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ed8:	0009a503          	lw	a0,0(s3)
    80003edc:	80fff0ef          	jal	ra,800036ea <bread>
    80003ee0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ee2:	05850493          	addi	s1,a0,88
    80003ee6:	45850913          	addi	s2,a0,1112
    80003eea:	a021                	j	80003ef2 <itrunc+0x6e>
    80003eec:	0491                	addi	s1,s1,4
    80003eee:	01248963          	beq	s1,s2,80003f00 <itrunc+0x7c>
      if(a[j])
    80003ef2:	408c                	lw	a1,0(s1)
    80003ef4:	dde5                	beqz	a1,80003eec <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003ef6:	0009a503          	lw	a0,0(s3)
    80003efa:	9ebff0ef          	jal	ra,800038e4 <bfree>
    80003efe:	b7fd                	j	80003eec <itrunc+0x68>
    brelse(bp);
    80003f00:	8552                	mv	a0,s4
    80003f02:	8f1ff0ef          	jal	ra,800037f2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f06:	0809a583          	lw	a1,128(s3)
    80003f0a:	0009a503          	lw	a0,0(s3)
    80003f0e:	9d7ff0ef          	jal	ra,800038e4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f12:	0809a023          	sw	zero,128(s3)
    80003f16:	b765                	j	80003ebe <itrunc+0x3a>

0000000080003f18 <iput>:
{
    80003f18:	1101                	addi	sp,sp,-32
    80003f1a:	ec06                	sd	ra,24(sp)
    80003f1c:	e822                	sd	s0,16(sp)
    80003f1e:	e426                	sd	s1,8(sp)
    80003f20:	e04a                	sd	s2,0(sp)
    80003f22:	1000                	addi	s0,sp,32
    80003f24:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f26:	00245517          	auipc	a0,0x245
    80003f2a:	fd250513          	addi	a0,a0,-46 # 80248ef8 <itable>
    80003f2e:	d73fc0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f32:	4498                	lw	a4,8(s1)
    80003f34:	4785                	li	a5,1
    80003f36:	02f70163          	beq	a4,a5,80003f58 <iput+0x40>
  ip->ref--;
    80003f3a:	449c                	lw	a5,8(s1)
    80003f3c:	37fd                	addiw	a5,a5,-1
    80003f3e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f40:	00245517          	auipc	a0,0x245
    80003f44:	fb850513          	addi	a0,a0,-72 # 80248ef8 <itable>
    80003f48:	df1fc0ef          	jal	ra,80000d38 <release>
}
    80003f4c:	60e2                	ld	ra,24(sp)
    80003f4e:	6442                	ld	s0,16(sp)
    80003f50:	64a2                	ld	s1,8(sp)
    80003f52:	6902                	ld	s2,0(sp)
    80003f54:	6105                	addi	sp,sp,32
    80003f56:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f58:	40bc                	lw	a5,64(s1)
    80003f5a:	d3e5                	beqz	a5,80003f3a <iput+0x22>
    80003f5c:	04a49783          	lh	a5,74(s1)
    80003f60:	ffe9                	bnez	a5,80003f3a <iput+0x22>
    acquiresleep(&ip->lock);
    80003f62:	01048913          	addi	s2,s1,16
    80003f66:	854a                	mv	a0,s2
    80003f68:	295000ef          	jal	ra,800049fc <acquiresleep>
    release(&itable.lock);
    80003f6c:	00245517          	auipc	a0,0x245
    80003f70:	f8c50513          	addi	a0,a0,-116 # 80248ef8 <itable>
    80003f74:	dc5fc0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    80003f78:	8526                	mv	a0,s1
    80003f7a:	f0bff0ef          	jal	ra,80003e84 <itrunc>
    ip->type = 0;
    80003f7e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f82:	8526                	mv	a0,s1
    80003f84:	d63ff0ef          	jal	ra,80003ce6 <iupdate>
    ip->valid = 0;
    80003f88:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f8c:	854a                	mv	a0,s2
    80003f8e:	2b5000ef          	jal	ra,80004a42 <releasesleep>
    acquire(&itable.lock);
    80003f92:	00245517          	auipc	a0,0x245
    80003f96:	f6650513          	addi	a0,a0,-154 # 80248ef8 <itable>
    80003f9a:	d07fc0ef          	jal	ra,80000ca0 <acquire>
    80003f9e:	bf71                	j	80003f3a <iput+0x22>

0000000080003fa0 <iunlockput>:
{
    80003fa0:	1101                	addi	sp,sp,-32
    80003fa2:	ec06                	sd	ra,24(sp)
    80003fa4:	e822                	sd	s0,16(sp)
    80003fa6:	e426                	sd	s1,8(sp)
    80003fa8:	1000                	addi	s0,sp,32
    80003faa:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fac:	e99ff0ef          	jal	ra,80003e44 <iunlock>
  iput(ip);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	f67ff0ef          	jal	ra,80003f18 <iput>
}
    80003fb6:	60e2                	ld	ra,24(sp)
    80003fb8:	6442                	ld	s0,16(sp)
    80003fba:	64a2                	ld	s1,8(sp)
    80003fbc:	6105                	addi	sp,sp,32
    80003fbe:	8082                	ret

0000000080003fc0 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003fc0:	00245717          	auipc	a4,0x245
    80003fc4:	f2472703          	lw	a4,-220(a4) # 80248ee4 <sb+0xc>
    80003fc8:	4785                	li	a5,1
    80003fca:	0ae7ff63          	bgeu	a5,a4,80004088 <ireclaim+0xc8>
{
    80003fce:	7139                	addi	sp,sp,-64
    80003fd0:	fc06                	sd	ra,56(sp)
    80003fd2:	f822                	sd	s0,48(sp)
    80003fd4:	f426                	sd	s1,40(sp)
    80003fd6:	f04a                	sd	s2,32(sp)
    80003fd8:	ec4e                	sd	s3,24(sp)
    80003fda:	e852                	sd	s4,16(sp)
    80003fdc:	e456                	sd	s5,8(sp)
    80003fde:	e05a                	sd	s6,0(sp)
    80003fe0:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003fe2:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003fe4:	00050a1b          	sext.w	s4,a0
    80003fe8:	00245a97          	auipc	s5,0x245
    80003fec:	ef0a8a93          	addi	s5,s5,-272 # 80248ed8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003ff0:	00004b17          	auipc	s6,0x4
    80003ff4:	5b0b0b13          	addi	s6,s6,1456 # 800085a0 <syscalls+0x1a8>
    80003ff8:	a099                	j	8000403e <ireclaim+0x7e>
    80003ffa:	85ce                	mv	a1,s3
    80003ffc:	855a                	mv	a0,s6
    80003ffe:	cc4fc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    80004002:	85ce                	mv	a1,s3
    80004004:	8552                	mv	a0,s4
    80004006:	b27ff0ef          	jal	ra,80003b2c <iget>
    8000400a:	89aa                	mv	s3,a0
    brelse(bp);
    8000400c:	854a                	mv	a0,s2
    8000400e:	fe4ff0ef          	jal	ra,800037f2 <brelse>
    if (ip) {
    80004012:	00098f63          	beqz	s3,80004030 <ireclaim+0x70>
      begin_op();
    80004016:	76c000ef          	jal	ra,80004782 <begin_op>
      ilock(ip);
    8000401a:	854e                	mv	a0,s3
    8000401c:	d7fff0ef          	jal	ra,80003d9a <ilock>
      iunlock(ip);
    80004020:	854e                	mv	a0,s3
    80004022:	e23ff0ef          	jal	ra,80003e44 <iunlock>
      iput(ip);
    80004026:	854e                	mv	a0,s3
    80004028:	ef1ff0ef          	jal	ra,80003f18 <iput>
      end_op();
    8000402c:	7c4000ef          	jal	ra,800047f0 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004030:	0485                	addi	s1,s1,1
    80004032:	00caa703          	lw	a4,12(s5)
    80004036:	0004879b          	sext.w	a5,s1
    8000403a:	02e7fd63          	bgeu	a5,a4,80004074 <ireclaim+0xb4>
    8000403e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004042:	0044d593          	srli	a1,s1,0x4
    80004046:	018aa783          	lw	a5,24(s5)
    8000404a:	9dbd                	addw	a1,a1,a5
    8000404c:	8552                	mv	a0,s4
    8000404e:	e9cff0ef          	jal	ra,800036ea <bread>
    80004052:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80004054:	05850793          	addi	a5,a0,88
    80004058:	00f9f713          	andi	a4,s3,15
    8000405c:	071a                	slli	a4,a4,0x6
    8000405e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80004060:	00079703          	lh	a4,0(a5)
    80004064:	c701                	beqz	a4,8000406c <ireclaim+0xac>
    80004066:	00679783          	lh	a5,6(a5)
    8000406a:	dbc1                	beqz	a5,80003ffa <ireclaim+0x3a>
    brelse(bp);
    8000406c:	854a                	mv	a0,s2
    8000406e:	f84ff0ef          	jal	ra,800037f2 <brelse>
    if (ip) {
    80004072:	bf7d                	j	80004030 <ireclaim+0x70>
}
    80004074:	70e2                	ld	ra,56(sp)
    80004076:	7442                	ld	s0,48(sp)
    80004078:	74a2                	ld	s1,40(sp)
    8000407a:	7902                	ld	s2,32(sp)
    8000407c:	69e2                	ld	s3,24(sp)
    8000407e:	6a42                	ld	s4,16(sp)
    80004080:	6aa2                	ld	s5,8(sp)
    80004082:	6b02                	ld	s6,0(sp)
    80004084:	6121                	addi	sp,sp,64
    80004086:	8082                	ret
    80004088:	8082                	ret

000000008000408a <fsinit>:
fsinit(int dev) {
    8000408a:	7179                	addi	sp,sp,-48
    8000408c:	f406                	sd	ra,40(sp)
    8000408e:	f022                	sd	s0,32(sp)
    80004090:	ec26                	sd	s1,24(sp)
    80004092:	e84a                	sd	s2,16(sp)
    80004094:	e44e                	sd	s3,8(sp)
    80004096:	1800                	addi	s0,sp,48
    80004098:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    8000409a:	4585                	li	a1,1
    8000409c:	e4eff0ef          	jal	ra,800036ea <bread>
    800040a0:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800040a2:	00245997          	auipc	s3,0x245
    800040a6:	e3698993          	addi	s3,s3,-458 # 80248ed8 <sb>
    800040aa:	02000613          	li	a2,32
    800040ae:	05850593          	addi	a1,a0,88
    800040b2:	854e                	mv	a0,s3
    800040b4:	d1dfc0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    800040b8:	854a                	mv	a0,s2
    800040ba:	f38ff0ef          	jal	ra,800037f2 <brelse>
  if(sb.magic != FSMAGIC)
    800040be:	0009a703          	lw	a4,0(s3)
    800040c2:	102037b7          	lui	a5,0x10203
    800040c6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800040ca:	02f71363          	bne	a4,a5,800040f0 <fsinit+0x66>
  initlog(dev, &sb);
    800040ce:	00245597          	auipc	a1,0x245
    800040d2:	e0a58593          	addi	a1,a1,-502 # 80248ed8 <sb>
    800040d6:	8526                	mv	a0,s1
    800040d8:	61e000ef          	jal	ra,800046f6 <initlog>
  ireclaim(dev);
    800040dc:	8526                	mv	a0,s1
    800040de:	ee3ff0ef          	jal	ra,80003fc0 <ireclaim>
}
    800040e2:	70a2                	ld	ra,40(sp)
    800040e4:	7402                	ld	s0,32(sp)
    800040e6:	64e2                	ld	s1,24(sp)
    800040e8:	6942                	ld	s2,16(sp)
    800040ea:	69a2                	ld	s3,8(sp)
    800040ec:	6145                	addi	sp,sp,48
    800040ee:	8082                	ret
    panic("invalid file system");
    800040f0:	00004517          	auipc	a0,0x4
    800040f4:	4d050513          	addi	a0,a0,1232 # 800085c0 <syscalls+0x1c8>
    800040f8:	e90fc0ef          	jal	ra,80000788 <panic>

00000000800040fc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800040fc:	1141                	addi	sp,sp,-16
    800040fe:	e422                	sd	s0,8(sp)
    80004100:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004102:	411c                	lw	a5,0(a0)
    80004104:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004106:	415c                	lw	a5,4(a0)
    80004108:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000410a:	04451783          	lh	a5,68(a0)
    8000410e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004112:	04a51783          	lh	a5,74(a0)
    80004116:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000411a:	04c56783          	lwu	a5,76(a0)
    8000411e:	e99c                	sd	a5,16(a1)
}
    80004120:	6422                	ld	s0,8(sp)
    80004122:	0141                	addi	sp,sp,16
    80004124:	8082                	ret

0000000080004126 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004126:	457c                	lw	a5,76(a0)
    80004128:	0cd7ef63          	bltu	a5,a3,80004206 <readi+0xe0>
{
    8000412c:	7159                	addi	sp,sp,-112
    8000412e:	f486                	sd	ra,104(sp)
    80004130:	f0a2                	sd	s0,96(sp)
    80004132:	eca6                	sd	s1,88(sp)
    80004134:	e8ca                	sd	s2,80(sp)
    80004136:	e4ce                	sd	s3,72(sp)
    80004138:	e0d2                	sd	s4,64(sp)
    8000413a:	fc56                	sd	s5,56(sp)
    8000413c:	f85a                	sd	s6,48(sp)
    8000413e:	f45e                	sd	s7,40(sp)
    80004140:	f062                	sd	s8,32(sp)
    80004142:	ec66                	sd	s9,24(sp)
    80004144:	e86a                	sd	s10,16(sp)
    80004146:	e46e                	sd	s11,8(sp)
    80004148:	1880                	addi	s0,sp,112
    8000414a:	8b2a                	mv	s6,a0
    8000414c:	8bae                	mv	s7,a1
    8000414e:	8a32                	mv	s4,a2
    80004150:	84b6                	mv	s1,a3
    80004152:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004154:	9f35                	addw	a4,a4,a3
    return 0;
    80004156:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004158:	08d76663          	bltu	a4,a3,800041e4 <readi+0xbe>
  if(off + n > ip->size)
    8000415c:	00e7f463          	bgeu	a5,a4,80004164 <readi+0x3e>
    n = ip->size - off;
    80004160:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004164:	080a8f63          	beqz	s5,80004202 <readi+0xdc>
    80004168:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000416a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000416e:	5c7d                	li	s8,-1
    80004170:	a80d                	j	800041a2 <readi+0x7c>
    80004172:	020d1d93          	slli	s11,s10,0x20
    80004176:	020ddd93          	srli	s11,s11,0x20
    8000417a:	05890613          	addi	a2,s2,88
    8000417e:	86ee                	mv	a3,s11
    80004180:	963a                	add	a2,a2,a4
    80004182:	85d2                	mv	a1,s4
    80004184:	855e                	mv	a0,s7
    80004186:	dc4fe0ef          	jal	ra,8000274a <either_copyout>
    8000418a:	05850763          	beq	a0,s8,800041d8 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000418e:	854a                	mv	a0,s2
    80004190:	e62ff0ef          	jal	ra,800037f2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004194:	013d09bb          	addw	s3,s10,s3
    80004198:	009d04bb          	addw	s1,s10,s1
    8000419c:	9a6e                	add	s4,s4,s11
    8000419e:	0559f163          	bgeu	s3,s5,800041e0 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800041a2:	00a4d59b          	srliw	a1,s1,0xa
    800041a6:	855a                	mv	a0,s6
    800041a8:	8b7ff0ef          	jal	ra,80003a5e <bmap>
    800041ac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800041b0:	c985                	beqz	a1,800041e0 <readi+0xba>
    bp = bread(ip->dev, addr);
    800041b2:	000b2503          	lw	a0,0(s6)
    800041b6:	d34ff0ef          	jal	ra,800036ea <bread>
    800041ba:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041bc:	3ff4f713          	andi	a4,s1,1023
    800041c0:	40ec87bb          	subw	a5,s9,a4
    800041c4:	413a86bb          	subw	a3,s5,s3
    800041c8:	8d3e                	mv	s10,a5
    800041ca:	2781                	sext.w	a5,a5
    800041cc:	0006861b          	sext.w	a2,a3
    800041d0:	faf671e3          	bgeu	a2,a5,80004172 <readi+0x4c>
    800041d4:	8d36                	mv	s10,a3
    800041d6:	bf71                	j	80004172 <readi+0x4c>
      brelse(bp);
    800041d8:	854a                	mv	a0,s2
    800041da:	e18ff0ef          	jal	ra,800037f2 <brelse>
      tot = -1;
    800041de:	59fd                	li	s3,-1
  }
  return tot;
    800041e0:	0009851b          	sext.w	a0,s3
}
    800041e4:	70a6                	ld	ra,104(sp)
    800041e6:	7406                	ld	s0,96(sp)
    800041e8:	64e6                	ld	s1,88(sp)
    800041ea:	6946                	ld	s2,80(sp)
    800041ec:	69a6                	ld	s3,72(sp)
    800041ee:	6a06                	ld	s4,64(sp)
    800041f0:	7ae2                	ld	s5,56(sp)
    800041f2:	7b42                	ld	s6,48(sp)
    800041f4:	7ba2                	ld	s7,40(sp)
    800041f6:	7c02                	ld	s8,32(sp)
    800041f8:	6ce2                	ld	s9,24(sp)
    800041fa:	6d42                	ld	s10,16(sp)
    800041fc:	6da2                	ld	s11,8(sp)
    800041fe:	6165                	addi	sp,sp,112
    80004200:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004202:	89d6                	mv	s3,s5
    80004204:	bff1                	j	800041e0 <readi+0xba>
    return 0;
    80004206:	4501                	li	a0,0
}
    80004208:	8082                	ret

000000008000420a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000420a:	457c                	lw	a5,76(a0)
    8000420c:	0ed7ea63          	bltu	a5,a3,80004300 <writei+0xf6>
{
    80004210:	7159                	addi	sp,sp,-112
    80004212:	f486                	sd	ra,104(sp)
    80004214:	f0a2                	sd	s0,96(sp)
    80004216:	eca6                	sd	s1,88(sp)
    80004218:	e8ca                	sd	s2,80(sp)
    8000421a:	e4ce                	sd	s3,72(sp)
    8000421c:	e0d2                	sd	s4,64(sp)
    8000421e:	fc56                	sd	s5,56(sp)
    80004220:	f85a                	sd	s6,48(sp)
    80004222:	f45e                	sd	s7,40(sp)
    80004224:	f062                	sd	s8,32(sp)
    80004226:	ec66                	sd	s9,24(sp)
    80004228:	e86a                	sd	s10,16(sp)
    8000422a:	e46e                	sd	s11,8(sp)
    8000422c:	1880                	addi	s0,sp,112
    8000422e:	8aaa                	mv	s5,a0
    80004230:	8bae                	mv	s7,a1
    80004232:	8a32                	mv	s4,a2
    80004234:	8936                	mv	s2,a3
    80004236:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004238:	00e687bb          	addw	a5,a3,a4
    8000423c:	0cd7e463          	bltu	a5,a3,80004304 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004240:	00043737          	lui	a4,0x43
    80004244:	0cf76263          	bltu	a4,a5,80004308 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004248:	0a0b0a63          	beqz	s6,800042fc <writei+0xf2>
    8000424c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000424e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004252:	5c7d                	li	s8,-1
    80004254:	a825                	j	8000428c <writei+0x82>
    80004256:	020d1d93          	slli	s11,s10,0x20
    8000425a:	020ddd93          	srli	s11,s11,0x20
    8000425e:	05848513          	addi	a0,s1,88
    80004262:	86ee                	mv	a3,s11
    80004264:	8652                	mv	a2,s4
    80004266:	85de                	mv	a1,s7
    80004268:	953a                	add	a0,a0,a4
    8000426a:	d2afe0ef          	jal	ra,80002794 <either_copyin>
    8000426e:	05850a63          	beq	a0,s8,800042c2 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004272:	8526                	mv	a0,s1
    80004274:	690000ef          	jal	ra,80004904 <log_write>
    brelse(bp);
    80004278:	8526                	mv	a0,s1
    8000427a:	d78ff0ef          	jal	ra,800037f2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000427e:	013d09bb          	addw	s3,s10,s3
    80004282:	012d093b          	addw	s2,s10,s2
    80004286:	9a6e                	add	s4,s4,s11
    80004288:	0569f063          	bgeu	s3,s6,800042c8 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000428c:	00a9559b          	srliw	a1,s2,0xa
    80004290:	8556                	mv	a0,s5
    80004292:	fccff0ef          	jal	ra,80003a5e <bmap>
    80004296:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000429a:	c59d                	beqz	a1,800042c8 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000429c:	000aa503          	lw	a0,0(s5)
    800042a0:	c4aff0ef          	jal	ra,800036ea <bread>
    800042a4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042a6:	3ff97713          	andi	a4,s2,1023
    800042aa:	40ec87bb          	subw	a5,s9,a4
    800042ae:	413b06bb          	subw	a3,s6,s3
    800042b2:	8d3e                	mv	s10,a5
    800042b4:	2781                	sext.w	a5,a5
    800042b6:	0006861b          	sext.w	a2,a3
    800042ba:	f8f67ee3          	bgeu	a2,a5,80004256 <writei+0x4c>
    800042be:	8d36                	mv	s10,a3
    800042c0:	bf59                	j	80004256 <writei+0x4c>
      brelse(bp);
    800042c2:	8526                	mv	a0,s1
    800042c4:	d2eff0ef          	jal	ra,800037f2 <brelse>
  }

  if(off > ip->size)
    800042c8:	04caa783          	lw	a5,76(s5)
    800042cc:	0127f463          	bgeu	a5,s2,800042d4 <writei+0xca>
    ip->size = off;
    800042d0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800042d4:	8556                	mv	a0,s5
    800042d6:	a11ff0ef          	jal	ra,80003ce6 <iupdate>

  return tot;
    800042da:	0009851b          	sext.w	a0,s3
}
    800042de:	70a6                	ld	ra,104(sp)
    800042e0:	7406                	ld	s0,96(sp)
    800042e2:	64e6                	ld	s1,88(sp)
    800042e4:	6946                	ld	s2,80(sp)
    800042e6:	69a6                	ld	s3,72(sp)
    800042e8:	6a06                	ld	s4,64(sp)
    800042ea:	7ae2                	ld	s5,56(sp)
    800042ec:	7b42                	ld	s6,48(sp)
    800042ee:	7ba2                	ld	s7,40(sp)
    800042f0:	7c02                	ld	s8,32(sp)
    800042f2:	6ce2                	ld	s9,24(sp)
    800042f4:	6d42                	ld	s10,16(sp)
    800042f6:	6da2                	ld	s11,8(sp)
    800042f8:	6165                	addi	sp,sp,112
    800042fa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042fc:	89da                	mv	s3,s6
    800042fe:	bfd9                	j	800042d4 <writei+0xca>
    return -1;
    80004300:	557d                	li	a0,-1
}
    80004302:	8082                	ret
    return -1;
    80004304:	557d                	li	a0,-1
    80004306:	bfe1                	j	800042de <writei+0xd4>
    return -1;
    80004308:	557d                	li	a0,-1
    8000430a:	bfd1                	j	800042de <writei+0xd4>

000000008000430c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000430c:	1141                	addi	sp,sp,-16
    8000430e:	e406                	sd	ra,8(sp)
    80004310:	e022                	sd	s0,0(sp)
    80004312:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004314:	4639                	li	a2,14
    80004316:	b2bfc0ef          	jal	ra,80000e40 <strncmp>
}
    8000431a:	60a2                	ld	ra,8(sp)
    8000431c:	6402                	ld	s0,0(sp)
    8000431e:	0141                	addi	sp,sp,16
    80004320:	8082                	ret

0000000080004322 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004322:	7139                	addi	sp,sp,-64
    80004324:	fc06                	sd	ra,56(sp)
    80004326:	f822                	sd	s0,48(sp)
    80004328:	f426                	sd	s1,40(sp)
    8000432a:	f04a                	sd	s2,32(sp)
    8000432c:	ec4e                	sd	s3,24(sp)
    8000432e:	e852                	sd	s4,16(sp)
    80004330:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004332:	04451703          	lh	a4,68(a0)
    80004336:	4785                	li	a5,1
    80004338:	00f71a63          	bne	a4,a5,8000434c <dirlookup+0x2a>
    8000433c:	892a                	mv	s2,a0
    8000433e:	89ae                	mv	s3,a1
    80004340:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004342:	457c                	lw	a5,76(a0)
    80004344:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004346:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004348:	e39d                	bnez	a5,8000436e <dirlookup+0x4c>
    8000434a:	a095                	j	800043ae <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000434c:	00004517          	auipc	a0,0x4
    80004350:	28c50513          	addi	a0,a0,652 # 800085d8 <syscalls+0x1e0>
    80004354:	c34fc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80004358:	00004517          	auipc	a0,0x4
    8000435c:	29850513          	addi	a0,a0,664 # 800085f0 <syscalls+0x1f8>
    80004360:	c28fc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004364:	24c1                	addiw	s1,s1,16
    80004366:	04c92783          	lw	a5,76(s2)
    8000436a:	04f4f163          	bgeu	s1,a5,800043ac <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000436e:	4741                	li	a4,16
    80004370:	86a6                	mv	a3,s1
    80004372:	fc040613          	addi	a2,s0,-64
    80004376:	4581                	li	a1,0
    80004378:	854a                	mv	a0,s2
    8000437a:	dadff0ef          	jal	ra,80004126 <readi>
    8000437e:	47c1                	li	a5,16
    80004380:	fcf51ce3          	bne	a0,a5,80004358 <dirlookup+0x36>
    if(de.inum == 0)
    80004384:	fc045783          	lhu	a5,-64(s0)
    80004388:	dff1                	beqz	a5,80004364 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000438a:	fc240593          	addi	a1,s0,-62
    8000438e:	854e                	mv	a0,s3
    80004390:	f7dff0ef          	jal	ra,8000430c <namecmp>
    80004394:	f961                	bnez	a0,80004364 <dirlookup+0x42>
      if(poff)
    80004396:	000a0463          	beqz	s4,8000439e <dirlookup+0x7c>
        *poff = off;
    8000439a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000439e:	fc045583          	lhu	a1,-64(s0)
    800043a2:	00092503          	lw	a0,0(s2)
    800043a6:	f86ff0ef          	jal	ra,80003b2c <iget>
    800043aa:	a011                	j	800043ae <dirlookup+0x8c>
  return 0;
    800043ac:	4501                	li	a0,0
}
    800043ae:	70e2                	ld	ra,56(sp)
    800043b0:	7442                	ld	s0,48(sp)
    800043b2:	74a2                	ld	s1,40(sp)
    800043b4:	7902                	ld	s2,32(sp)
    800043b6:	69e2                	ld	s3,24(sp)
    800043b8:	6a42                	ld	s4,16(sp)
    800043ba:	6121                	addi	sp,sp,64
    800043bc:	8082                	ret

00000000800043be <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800043be:	711d                	addi	sp,sp,-96
    800043c0:	ec86                	sd	ra,88(sp)
    800043c2:	e8a2                	sd	s0,80(sp)
    800043c4:	e4a6                	sd	s1,72(sp)
    800043c6:	e0ca                	sd	s2,64(sp)
    800043c8:	fc4e                	sd	s3,56(sp)
    800043ca:	f852                	sd	s4,48(sp)
    800043cc:	f456                	sd	s5,40(sp)
    800043ce:	f05a                	sd	s6,32(sp)
    800043d0:	ec5e                	sd	s7,24(sp)
    800043d2:	e862                	sd	s8,16(sp)
    800043d4:	e466                	sd	s9,8(sp)
    800043d6:	e06a                	sd	s10,0(sp)
    800043d8:	1080                	addi	s0,sp,96
    800043da:	84aa                	mv	s1,a0
    800043dc:	8b2e                	mv	s6,a1
    800043de:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800043e0:	00054703          	lbu	a4,0(a0)
    800043e4:	02f00793          	li	a5,47
    800043e8:	00f70f63          	beq	a4,a5,80004406 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800043ec:	f5cfd0ef          	jal	ra,80001b48 <myproc>
    800043f0:	15053503          	ld	a0,336(a0)
    800043f4:	971ff0ef          	jal	ra,80003d64 <idup>
    800043f8:	8a2a                	mv	s4,a0
  while(*path == '/')
    800043fa:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800043fe:	4cb5                	li	s9,13
  len = path - s;
    80004400:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004402:	4c05                	li	s8,1
    80004404:	a879                	j	800044a2 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80004406:	4585                	li	a1,1
    80004408:	4505                	li	a0,1
    8000440a:	f22ff0ef          	jal	ra,80003b2c <iget>
    8000440e:	8a2a                	mv	s4,a0
    80004410:	b7ed                	j	800043fa <namex+0x3c>
      iunlockput(ip);
    80004412:	8552                	mv	a0,s4
    80004414:	b8dff0ef          	jal	ra,80003fa0 <iunlockput>
      return 0;
    80004418:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000441a:	8552                	mv	a0,s4
    8000441c:	60e6                	ld	ra,88(sp)
    8000441e:	6446                	ld	s0,80(sp)
    80004420:	64a6                	ld	s1,72(sp)
    80004422:	6906                	ld	s2,64(sp)
    80004424:	79e2                	ld	s3,56(sp)
    80004426:	7a42                	ld	s4,48(sp)
    80004428:	7aa2                	ld	s5,40(sp)
    8000442a:	7b02                	ld	s6,32(sp)
    8000442c:	6be2                	ld	s7,24(sp)
    8000442e:	6c42                	ld	s8,16(sp)
    80004430:	6ca2                	ld	s9,8(sp)
    80004432:	6d02                	ld	s10,0(sp)
    80004434:	6125                	addi	sp,sp,96
    80004436:	8082                	ret
      iunlock(ip);
    80004438:	8552                	mv	a0,s4
    8000443a:	a0bff0ef          	jal	ra,80003e44 <iunlock>
      return ip;
    8000443e:	bff1                	j	8000441a <namex+0x5c>
      iunlockput(ip);
    80004440:	8552                	mv	a0,s4
    80004442:	b5fff0ef          	jal	ra,80003fa0 <iunlockput>
      return 0;
    80004446:	8a4e                	mv	s4,s3
    80004448:	bfc9                	j	8000441a <namex+0x5c>
  len = path - s;
    8000444a:	40998633          	sub	a2,s3,s1
    8000444e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004452:	09acd063          	bge	s9,s10,800044d2 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80004456:	4639                	li	a2,14
    80004458:	85a6                	mv	a1,s1
    8000445a:	8556                	mv	a0,s5
    8000445c:	975fc0ef          	jal	ra,80000dd0 <memmove>
    80004460:	84ce                	mv	s1,s3
  while(*path == '/')
    80004462:	0004c783          	lbu	a5,0(s1)
    80004466:	01279763          	bne	a5,s2,80004474 <namex+0xb6>
    path++;
    8000446a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000446c:	0004c783          	lbu	a5,0(s1)
    80004470:	ff278de3          	beq	a5,s2,8000446a <namex+0xac>
    ilock(ip);
    80004474:	8552                	mv	a0,s4
    80004476:	925ff0ef          	jal	ra,80003d9a <ilock>
    if(ip->type != T_DIR){
    8000447a:	044a1783          	lh	a5,68(s4)
    8000447e:	f9879ae3          	bne	a5,s8,80004412 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80004482:	000b0563          	beqz	s6,8000448c <namex+0xce>
    80004486:	0004c783          	lbu	a5,0(s1)
    8000448a:	d7dd                	beqz	a5,80004438 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000448c:	865e                	mv	a2,s7
    8000448e:	85d6                	mv	a1,s5
    80004490:	8552                	mv	a0,s4
    80004492:	e91ff0ef          	jal	ra,80004322 <dirlookup>
    80004496:	89aa                	mv	s3,a0
    80004498:	d545                	beqz	a0,80004440 <namex+0x82>
    iunlockput(ip);
    8000449a:	8552                	mv	a0,s4
    8000449c:	b05ff0ef          	jal	ra,80003fa0 <iunlockput>
    ip = next;
    800044a0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800044a2:	0004c783          	lbu	a5,0(s1)
    800044a6:	01279763          	bne	a5,s2,800044b4 <namex+0xf6>
    path++;
    800044aa:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044ac:	0004c783          	lbu	a5,0(s1)
    800044b0:	ff278de3          	beq	a5,s2,800044aa <namex+0xec>
  if(*path == 0)
    800044b4:	cb8d                	beqz	a5,800044e6 <namex+0x128>
  while(*path != '/' && *path != 0)
    800044b6:	0004c783          	lbu	a5,0(s1)
    800044ba:	89a6                	mv	s3,s1
  len = path - s;
    800044bc:	8d5e                	mv	s10,s7
    800044be:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800044c0:	01278963          	beq	a5,s2,800044d2 <namex+0x114>
    800044c4:	d3d9                	beqz	a5,8000444a <namex+0x8c>
    path++;
    800044c6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800044c8:	0009c783          	lbu	a5,0(s3)
    800044cc:	ff279ce3          	bne	a5,s2,800044c4 <namex+0x106>
    800044d0:	bfad                	j	8000444a <namex+0x8c>
    memmove(name, s, len);
    800044d2:	2601                	sext.w	a2,a2
    800044d4:	85a6                	mv	a1,s1
    800044d6:	8556                	mv	a0,s5
    800044d8:	8f9fc0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    800044dc:	9d56                	add	s10,s10,s5
    800044de:	000d0023          	sb	zero,0(s10) # 1000 <_entry-0x7ffff000>
    800044e2:	84ce                	mv	s1,s3
    800044e4:	bfbd                	j	80004462 <namex+0xa4>
  if(nameiparent){
    800044e6:	f20b0ae3          	beqz	s6,8000441a <namex+0x5c>
    iput(ip);
    800044ea:	8552                	mv	a0,s4
    800044ec:	a2dff0ef          	jal	ra,80003f18 <iput>
    return 0;
    800044f0:	4a01                	li	s4,0
    800044f2:	b725                	j	8000441a <namex+0x5c>

00000000800044f4 <dirlink>:
{
    800044f4:	7139                	addi	sp,sp,-64
    800044f6:	fc06                	sd	ra,56(sp)
    800044f8:	f822                	sd	s0,48(sp)
    800044fa:	f426                	sd	s1,40(sp)
    800044fc:	f04a                	sd	s2,32(sp)
    800044fe:	ec4e                	sd	s3,24(sp)
    80004500:	e852                	sd	s4,16(sp)
    80004502:	0080                	addi	s0,sp,64
    80004504:	892a                	mv	s2,a0
    80004506:	8a2e                	mv	s4,a1
    80004508:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000450a:	4601                	li	a2,0
    8000450c:	e17ff0ef          	jal	ra,80004322 <dirlookup>
    80004510:	e52d                	bnez	a0,8000457a <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004512:	04c92483          	lw	s1,76(s2)
    80004516:	c48d                	beqz	s1,80004540 <dirlink+0x4c>
    80004518:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000451a:	4741                	li	a4,16
    8000451c:	86a6                	mv	a3,s1
    8000451e:	fc040613          	addi	a2,s0,-64
    80004522:	4581                	li	a1,0
    80004524:	854a                	mv	a0,s2
    80004526:	c01ff0ef          	jal	ra,80004126 <readi>
    8000452a:	47c1                	li	a5,16
    8000452c:	04f51b63          	bne	a0,a5,80004582 <dirlink+0x8e>
    if(de.inum == 0)
    80004530:	fc045783          	lhu	a5,-64(s0)
    80004534:	c791                	beqz	a5,80004540 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004536:	24c1                	addiw	s1,s1,16
    80004538:	04c92783          	lw	a5,76(s2)
    8000453c:	fcf4efe3          	bltu	s1,a5,8000451a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004540:	4639                	li	a2,14
    80004542:	85d2                	mv	a1,s4
    80004544:	fc240513          	addi	a0,s0,-62
    80004548:	935fc0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    8000454c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004550:	4741                	li	a4,16
    80004552:	86a6                	mv	a3,s1
    80004554:	fc040613          	addi	a2,s0,-64
    80004558:	4581                	li	a1,0
    8000455a:	854a                	mv	a0,s2
    8000455c:	cafff0ef          	jal	ra,8000420a <writei>
    80004560:	1541                	addi	a0,a0,-16
    80004562:	00a03533          	snez	a0,a0
    80004566:	40a00533          	neg	a0,a0
}
    8000456a:	70e2                	ld	ra,56(sp)
    8000456c:	7442                	ld	s0,48(sp)
    8000456e:	74a2                	ld	s1,40(sp)
    80004570:	7902                	ld	s2,32(sp)
    80004572:	69e2                	ld	s3,24(sp)
    80004574:	6a42                	ld	s4,16(sp)
    80004576:	6121                	addi	sp,sp,64
    80004578:	8082                	ret
    iput(ip);
    8000457a:	99fff0ef          	jal	ra,80003f18 <iput>
    return -1;
    8000457e:	557d                	li	a0,-1
    80004580:	b7ed                	j	8000456a <dirlink+0x76>
      panic("dirlink read");
    80004582:	00004517          	auipc	a0,0x4
    80004586:	07e50513          	addi	a0,a0,126 # 80008600 <syscalls+0x208>
    8000458a:	9fefc0ef          	jal	ra,80000788 <panic>

000000008000458e <namei>:

struct inode*
namei(char *path)
{
    8000458e:	1101                	addi	sp,sp,-32
    80004590:	ec06                	sd	ra,24(sp)
    80004592:	e822                	sd	s0,16(sp)
    80004594:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004596:	fe040613          	addi	a2,s0,-32
    8000459a:	4581                	li	a1,0
    8000459c:	e23ff0ef          	jal	ra,800043be <namex>
}
    800045a0:	60e2                	ld	ra,24(sp)
    800045a2:	6442                	ld	s0,16(sp)
    800045a4:	6105                	addi	sp,sp,32
    800045a6:	8082                	ret

00000000800045a8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045a8:	1141                	addi	sp,sp,-16
    800045aa:	e406                	sd	ra,8(sp)
    800045ac:	e022                	sd	s0,0(sp)
    800045ae:	0800                	addi	s0,sp,16
    800045b0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045b2:	4585                	li	a1,1
    800045b4:	e0bff0ef          	jal	ra,800043be <namex>
}
    800045b8:	60a2                	ld	ra,8(sp)
    800045ba:	6402                	ld	s0,0(sp)
    800045bc:	0141                	addi	sp,sp,16
    800045be:	8082                	ret

00000000800045c0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800045c0:	1101                	addi	sp,sp,-32
    800045c2:	ec06                	sd	ra,24(sp)
    800045c4:	e822                	sd	s0,16(sp)
    800045c6:	e426                	sd	s1,8(sp)
    800045c8:	e04a                	sd	s2,0(sp)
    800045ca:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800045cc:	00246917          	auipc	s2,0x246
    800045d0:	3d490913          	addi	s2,s2,980 # 8024a9a0 <log>
    800045d4:	01892583          	lw	a1,24(s2)
    800045d8:	02492503          	lw	a0,36(s2)
    800045dc:	90eff0ef          	jal	ra,800036ea <bread>
    800045e0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800045e2:	02892683          	lw	a3,40(s2)
    800045e6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800045e8:	02d05863          	blez	a3,80004618 <write_head+0x58>
    800045ec:	00246797          	auipc	a5,0x246
    800045f0:	3e078793          	addi	a5,a5,992 # 8024a9cc <log+0x2c>
    800045f4:	05c50713          	addi	a4,a0,92
    800045f8:	36fd                	addiw	a3,a3,-1
    800045fa:	02069613          	slli	a2,a3,0x20
    800045fe:	01e65693          	srli	a3,a2,0x1e
    80004602:	00246617          	auipc	a2,0x246
    80004606:	3ce60613          	addi	a2,a2,974 # 8024a9d0 <log+0x30>
    8000460a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000460c:	4390                	lw	a2,0(a5)
    8000460e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004610:	0791                	addi	a5,a5,4
    80004612:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004614:	fed79ce3          	bne	a5,a3,8000460c <write_head+0x4c>
  }
  bwrite(buf);
    80004618:	8526                	mv	a0,s1
    8000461a:	9a6ff0ef          	jal	ra,800037c0 <bwrite>
  brelse(buf);
    8000461e:	8526                	mv	a0,s1
    80004620:	9d2ff0ef          	jal	ra,800037f2 <brelse>
}
    80004624:	60e2                	ld	ra,24(sp)
    80004626:	6442                	ld	s0,16(sp)
    80004628:	64a2                	ld	s1,8(sp)
    8000462a:	6902                	ld	s2,0(sp)
    8000462c:	6105                	addi	sp,sp,32
    8000462e:	8082                	ret

0000000080004630 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004630:	00246797          	auipc	a5,0x246
    80004634:	3987a783          	lw	a5,920(a5) # 8024a9c8 <log+0x28>
    80004638:	0af05e63          	blez	a5,800046f4 <install_trans+0xc4>
{
    8000463c:	715d                	addi	sp,sp,-80
    8000463e:	e486                	sd	ra,72(sp)
    80004640:	e0a2                	sd	s0,64(sp)
    80004642:	fc26                	sd	s1,56(sp)
    80004644:	f84a                	sd	s2,48(sp)
    80004646:	f44e                	sd	s3,40(sp)
    80004648:	f052                	sd	s4,32(sp)
    8000464a:	ec56                	sd	s5,24(sp)
    8000464c:	e85a                	sd	s6,16(sp)
    8000464e:	e45e                	sd	s7,8(sp)
    80004650:	0880                	addi	s0,sp,80
    80004652:	8b2a                	mv	s6,a0
    80004654:	00246a97          	auipc	s5,0x246
    80004658:	378a8a93          	addi	s5,s5,888 # 8024a9cc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000465c:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000465e:	00004b97          	auipc	s7,0x4
    80004662:	fb2b8b93          	addi	s7,s7,-78 # 80008610 <syscalls+0x218>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004666:	00246a17          	auipc	s4,0x246
    8000466a:	33aa0a13          	addi	s4,s4,826 # 8024a9a0 <log>
    8000466e:	a025                	j	80004696 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004670:	000aa603          	lw	a2,0(s5)
    80004674:	85ce                	mv	a1,s3
    80004676:	855e                	mv	a0,s7
    80004678:	e4bfb0ef          	jal	ra,800004c2 <printf>
    8000467c:	a839                	j	8000469a <install_trans+0x6a>
    brelse(lbuf);
    8000467e:	854a                	mv	a0,s2
    80004680:	972ff0ef          	jal	ra,800037f2 <brelse>
    brelse(dbuf);
    80004684:	8526                	mv	a0,s1
    80004686:	96cff0ef          	jal	ra,800037f2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000468a:	2985                	addiw	s3,s3,1
    8000468c:	0a91                	addi	s5,s5,4
    8000468e:	028a2783          	lw	a5,40(s4)
    80004692:	04f9d663          	bge	s3,a5,800046de <install_trans+0xae>
    if(recovering) {
    80004696:	fc0b1de3          	bnez	s6,80004670 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000469a:	018a2583          	lw	a1,24(s4)
    8000469e:	013585bb          	addw	a1,a1,s3
    800046a2:	2585                	addiw	a1,a1,1
    800046a4:	024a2503          	lw	a0,36(s4)
    800046a8:	842ff0ef          	jal	ra,800036ea <bread>
    800046ac:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800046ae:	000aa583          	lw	a1,0(s5)
    800046b2:	024a2503          	lw	a0,36(s4)
    800046b6:	834ff0ef          	jal	ra,800036ea <bread>
    800046ba:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046bc:	40000613          	li	a2,1024
    800046c0:	05890593          	addi	a1,s2,88
    800046c4:	05850513          	addi	a0,a0,88
    800046c8:	f08fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800046cc:	8526                	mv	a0,s1
    800046ce:	8f2ff0ef          	jal	ra,800037c0 <bwrite>
    if(recovering == 0)
    800046d2:	fa0b16e3          	bnez	s6,8000467e <install_trans+0x4e>
      bunpin(dbuf);
    800046d6:	8526                	mv	a0,s1
    800046d8:	9d8ff0ef          	jal	ra,800038b0 <bunpin>
    800046dc:	b74d                	j	8000467e <install_trans+0x4e>
}
    800046de:	60a6                	ld	ra,72(sp)
    800046e0:	6406                	ld	s0,64(sp)
    800046e2:	74e2                	ld	s1,56(sp)
    800046e4:	7942                	ld	s2,48(sp)
    800046e6:	79a2                	ld	s3,40(sp)
    800046e8:	7a02                	ld	s4,32(sp)
    800046ea:	6ae2                	ld	s5,24(sp)
    800046ec:	6b42                	ld	s6,16(sp)
    800046ee:	6ba2                	ld	s7,8(sp)
    800046f0:	6161                	addi	sp,sp,80
    800046f2:	8082                	ret
    800046f4:	8082                	ret

00000000800046f6 <initlog>:
{
    800046f6:	7179                	addi	sp,sp,-48
    800046f8:	f406                	sd	ra,40(sp)
    800046fa:	f022                	sd	s0,32(sp)
    800046fc:	ec26                	sd	s1,24(sp)
    800046fe:	e84a                	sd	s2,16(sp)
    80004700:	e44e                	sd	s3,8(sp)
    80004702:	1800                	addi	s0,sp,48
    80004704:	892a                	mv	s2,a0
    80004706:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004708:	00246497          	auipc	s1,0x246
    8000470c:	29848493          	addi	s1,s1,664 # 8024a9a0 <log>
    80004710:	00004597          	auipc	a1,0x4
    80004714:	f2058593          	addi	a1,a1,-224 # 80008630 <syscalls+0x238>
    80004718:	8526                	mv	a0,s1
    8000471a:	d06fc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    8000471e:	0149a583          	lw	a1,20(s3)
    80004722:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004724:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004728:	854a                	mv	a0,s2
    8000472a:	fc1fe0ef          	jal	ra,800036ea <bread>
  log.lh.n = lh->n;
    8000472e:	4d34                	lw	a3,88(a0)
    80004730:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004732:	02d05663          	blez	a3,8000475e <initlog+0x68>
    80004736:	05c50793          	addi	a5,a0,92
    8000473a:	00246717          	auipc	a4,0x246
    8000473e:	29270713          	addi	a4,a4,658 # 8024a9cc <log+0x2c>
    80004742:	36fd                	addiw	a3,a3,-1
    80004744:	02069613          	slli	a2,a3,0x20
    80004748:	01e65693          	srli	a3,a2,0x1e
    8000474c:	06050613          	addi	a2,a0,96
    80004750:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004752:	4390                	lw	a2,0(a5)
    80004754:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004756:	0791                	addi	a5,a5,4
    80004758:	0711                	addi	a4,a4,4
    8000475a:	fed79ce3          	bne	a5,a3,80004752 <initlog+0x5c>
  brelse(buf);
    8000475e:	894ff0ef          	jal	ra,800037f2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004762:	4505                	li	a0,1
    80004764:	ecdff0ef          	jal	ra,80004630 <install_trans>
  log.lh.n = 0;
    80004768:	00246797          	auipc	a5,0x246
    8000476c:	2607a023          	sw	zero,608(a5) # 8024a9c8 <log+0x28>
  write_head(); // clear the log
    80004770:	e51ff0ef          	jal	ra,800045c0 <write_head>
}
    80004774:	70a2                	ld	ra,40(sp)
    80004776:	7402                	ld	s0,32(sp)
    80004778:	64e2                	ld	s1,24(sp)
    8000477a:	6942                	ld	s2,16(sp)
    8000477c:	69a2                	ld	s3,8(sp)
    8000477e:	6145                	addi	sp,sp,48
    80004780:	8082                	ret

0000000080004782 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004782:	1101                	addi	sp,sp,-32
    80004784:	ec06                	sd	ra,24(sp)
    80004786:	e822                	sd	s0,16(sp)
    80004788:	e426                	sd	s1,8(sp)
    8000478a:	e04a                	sd	s2,0(sp)
    8000478c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000478e:	00246517          	auipc	a0,0x246
    80004792:	21250513          	addi	a0,a0,530 # 8024a9a0 <log>
    80004796:	d0afc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    8000479a:	00246497          	auipc	s1,0x246
    8000479e:	20648493          	addi	s1,s1,518 # 8024a9a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800047a2:	4979                	li	s2,30
    800047a4:	a029                	j	800047ae <begin_op+0x2c>
      sleep(&log, &log.lock);
    800047a6:	85a6                	mv	a1,s1
    800047a8:	8526                	mv	a0,s1
    800047aa:	c45fd0ef          	jal	ra,800023ee <sleep>
    if(log.committing){
    800047ae:	509c                	lw	a5,32(s1)
    800047b0:	fbfd                	bnez	a5,800047a6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800047b2:	4cd8                	lw	a4,28(s1)
    800047b4:	2705                	addiw	a4,a4,1
    800047b6:	0007069b          	sext.w	a3,a4
    800047ba:	0027179b          	slliw	a5,a4,0x2
    800047be:	9fb9                	addw	a5,a5,a4
    800047c0:	0017979b          	slliw	a5,a5,0x1
    800047c4:	5498                	lw	a4,40(s1)
    800047c6:	9fb9                	addw	a5,a5,a4
    800047c8:	00f95763          	bge	s2,a5,800047d6 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800047cc:	85a6                	mv	a1,s1
    800047ce:	8526                	mv	a0,s1
    800047d0:	c1ffd0ef          	jal	ra,800023ee <sleep>
    800047d4:	bfe9                	j	800047ae <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800047d6:	00246517          	auipc	a0,0x246
    800047da:	1ca50513          	addi	a0,a0,458 # 8024a9a0 <log>
    800047de:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    800047e0:	d58fc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    800047e4:	60e2                	ld	ra,24(sp)
    800047e6:	6442                	ld	s0,16(sp)
    800047e8:	64a2                	ld	s1,8(sp)
    800047ea:	6902                	ld	s2,0(sp)
    800047ec:	6105                	addi	sp,sp,32
    800047ee:	8082                	ret

00000000800047f0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800047f0:	7139                	addi	sp,sp,-64
    800047f2:	fc06                	sd	ra,56(sp)
    800047f4:	f822                	sd	s0,48(sp)
    800047f6:	f426                	sd	s1,40(sp)
    800047f8:	f04a                	sd	s2,32(sp)
    800047fa:	ec4e                	sd	s3,24(sp)
    800047fc:	e852                	sd	s4,16(sp)
    800047fe:	e456                	sd	s5,8(sp)
    80004800:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004802:	00246497          	auipc	s1,0x246
    80004806:	19e48493          	addi	s1,s1,414 # 8024a9a0 <log>
    8000480a:	8526                	mv	a0,s1
    8000480c:	c94fc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    80004810:	4cdc                	lw	a5,28(s1)
    80004812:	37fd                	addiw	a5,a5,-1
    80004814:	0007891b          	sext.w	s2,a5
    80004818:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000481a:	509c                	lw	a5,32(s1)
    8000481c:	ef9d                	bnez	a5,8000485a <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    8000481e:	04091463          	bnez	s2,80004866 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004822:	00246497          	auipc	s1,0x246
    80004826:	17e48493          	addi	s1,s1,382 # 8024a9a0 <log>
    8000482a:	4785                	li	a5,1
    8000482c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000482e:	8526                	mv	a0,s1
    80004830:	d08fc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004834:	549c                	lw	a5,40(s1)
    80004836:	04f04b63          	bgtz	a5,8000488c <end_op+0x9c>
    acquire(&log.lock);
    8000483a:	00246497          	auipc	s1,0x246
    8000483e:	16648493          	addi	s1,s1,358 # 8024a9a0 <log>
    80004842:	8526                	mv	a0,s1
    80004844:	c5cfc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    80004848:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    8000484c:	8526                	mv	a0,s1
    8000484e:	bedfd0ef          	jal	ra,8000243a <wakeup>
    release(&log.lock);
    80004852:	8526                	mv	a0,s1
    80004854:	ce4fc0ef          	jal	ra,80000d38 <release>
}
    80004858:	a00d                	j	8000487a <end_op+0x8a>
    panic("log.committing");
    8000485a:	00004517          	auipc	a0,0x4
    8000485e:	dde50513          	addi	a0,a0,-546 # 80008638 <syscalls+0x240>
    80004862:	f27fb0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    80004866:	00246497          	auipc	s1,0x246
    8000486a:	13a48493          	addi	s1,s1,314 # 8024a9a0 <log>
    8000486e:	8526                	mv	a0,s1
    80004870:	bcbfd0ef          	jal	ra,8000243a <wakeup>
  release(&log.lock);
    80004874:	8526                	mv	a0,s1
    80004876:	cc2fc0ef          	jal	ra,80000d38 <release>
}
    8000487a:	70e2                	ld	ra,56(sp)
    8000487c:	7442                	ld	s0,48(sp)
    8000487e:	74a2                	ld	s1,40(sp)
    80004880:	7902                	ld	s2,32(sp)
    80004882:	69e2                	ld	s3,24(sp)
    80004884:	6a42                	ld	s4,16(sp)
    80004886:	6aa2                	ld	s5,8(sp)
    80004888:	6121                	addi	sp,sp,64
    8000488a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000488c:	00246a97          	auipc	s5,0x246
    80004890:	140a8a93          	addi	s5,s5,320 # 8024a9cc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004894:	00246a17          	auipc	s4,0x246
    80004898:	10ca0a13          	addi	s4,s4,268 # 8024a9a0 <log>
    8000489c:	018a2583          	lw	a1,24(s4)
    800048a0:	012585bb          	addw	a1,a1,s2
    800048a4:	2585                	addiw	a1,a1,1
    800048a6:	024a2503          	lw	a0,36(s4)
    800048aa:	e41fe0ef          	jal	ra,800036ea <bread>
    800048ae:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800048b0:	000aa583          	lw	a1,0(s5)
    800048b4:	024a2503          	lw	a0,36(s4)
    800048b8:	e33fe0ef          	jal	ra,800036ea <bread>
    800048bc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800048be:	40000613          	li	a2,1024
    800048c2:	05850593          	addi	a1,a0,88
    800048c6:	05848513          	addi	a0,s1,88
    800048ca:	d06fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    800048ce:	8526                	mv	a0,s1
    800048d0:	ef1fe0ef          	jal	ra,800037c0 <bwrite>
    brelse(from);
    800048d4:	854e                	mv	a0,s3
    800048d6:	f1dfe0ef          	jal	ra,800037f2 <brelse>
    brelse(to);
    800048da:	8526                	mv	a0,s1
    800048dc:	f17fe0ef          	jal	ra,800037f2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800048e0:	2905                	addiw	s2,s2,1
    800048e2:	0a91                	addi	s5,s5,4
    800048e4:	028a2783          	lw	a5,40(s4)
    800048e8:	faf94ae3          	blt	s2,a5,8000489c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800048ec:	cd5ff0ef          	jal	ra,800045c0 <write_head>
    install_trans(0); // Now install writes to home locations
    800048f0:	4501                	li	a0,0
    800048f2:	d3fff0ef          	jal	ra,80004630 <install_trans>
    log.lh.n = 0;
    800048f6:	00246797          	auipc	a5,0x246
    800048fa:	0c07a923          	sw	zero,210(a5) # 8024a9c8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800048fe:	cc3ff0ef          	jal	ra,800045c0 <write_head>
    80004902:	bf25                	j	8000483a <end_op+0x4a>

0000000080004904 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004904:	1101                	addi	sp,sp,-32
    80004906:	ec06                	sd	ra,24(sp)
    80004908:	e822                	sd	s0,16(sp)
    8000490a:	e426                	sd	s1,8(sp)
    8000490c:	e04a                	sd	s2,0(sp)
    8000490e:	1000                	addi	s0,sp,32
    80004910:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004912:	00246917          	auipc	s2,0x246
    80004916:	08e90913          	addi	s2,s2,142 # 8024a9a0 <log>
    8000491a:	854a                	mv	a0,s2
    8000491c:	b84fc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004920:	02892603          	lw	a2,40(s2)
    80004924:	47f5                	li	a5,29
    80004926:	04c7cc63          	blt	a5,a2,8000497e <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000492a:	00246797          	auipc	a5,0x246
    8000492e:	0927a783          	lw	a5,146(a5) # 8024a9bc <log+0x1c>
    80004932:	04f05c63          	blez	a5,8000498a <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004936:	4781                	li	a5,0
    80004938:	04c05f63          	blez	a2,80004996 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000493c:	44cc                	lw	a1,12(s1)
    8000493e:	00246717          	auipc	a4,0x246
    80004942:	08e70713          	addi	a4,a4,142 # 8024a9cc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004946:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004948:	4314                	lw	a3,0(a4)
    8000494a:	04b68663          	beq	a3,a1,80004996 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000494e:	2785                	addiw	a5,a5,1
    80004950:	0711                	addi	a4,a4,4
    80004952:	fef61be3          	bne	a2,a5,80004948 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004956:	0621                	addi	a2,a2,8
    80004958:	060a                	slli	a2,a2,0x2
    8000495a:	00246797          	auipc	a5,0x246
    8000495e:	04678793          	addi	a5,a5,70 # 8024a9a0 <log>
    80004962:	97b2                	add	a5,a5,a2
    80004964:	44d8                	lw	a4,12(s1)
    80004966:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004968:	8526                	mv	a0,s1
    8000496a:	f13fe0ef          	jal	ra,8000387c <bpin>
    log.lh.n++;
    8000496e:	00246717          	auipc	a4,0x246
    80004972:	03270713          	addi	a4,a4,50 # 8024a9a0 <log>
    80004976:	571c                	lw	a5,40(a4)
    80004978:	2785                	addiw	a5,a5,1
    8000497a:	d71c                	sw	a5,40(a4)
    8000497c:	a80d                	j	800049ae <log_write+0xaa>
    panic("too big a transaction");
    8000497e:	00004517          	auipc	a0,0x4
    80004982:	cca50513          	addi	a0,a0,-822 # 80008648 <syscalls+0x250>
    80004986:	e03fb0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    8000498a:	00004517          	auipc	a0,0x4
    8000498e:	cd650513          	addi	a0,a0,-810 # 80008660 <syscalls+0x268>
    80004992:	df7fb0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    80004996:	00878693          	addi	a3,a5,8
    8000499a:	068a                	slli	a3,a3,0x2
    8000499c:	00246717          	auipc	a4,0x246
    800049a0:	00470713          	addi	a4,a4,4 # 8024a9a0 <log>
    800049a4:	9736                	add	a4,a4,a3
    800049a6:	44d4                	lw	a3,12(s1)
    800049a8:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800049aa:	faf60fe3          	beq	a2,a5,80004968 <log_write+0x64>
  }
  release(&log.lock);
    800049ae:	00246517          	auipc	a0,0x246
    800049b2:	ff250513          	addi	a0,a0,-14 # 8024a9a0 <log>
    800049b6:	b82fc0ef          	jal	ra,80000d38 <release>
}
    800049ba:	60e2                	ld	ra,24(sp)
    800049bc:	6442                	ld	s0,16(sp)
    800049be:	64a2                	ld	s1,8(sp)
    800049c0:	6902                	ld	s2,0(sp)
    800049c2:	6105                	addi	sp,sp,32
    800049c4:	8082                	ret

00000000800049c6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800049c6:	1101                	addi	sp,sp,-32
    800049c8:	ec06                	sd	ra,24(sp)
    800049ca:	e822                	sd	s0,16(sp)
    800049cc:	e426                	sd	s1,8(sp)
    800049ce:	e04a                	sd	s2,0(sp)
    800049d0:	1000                	addi	s0,sp,32
    800049d2:	84aa                	mv	s1,a0
    800049d4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049d6:	00004597          	auipc	a1,0x4
    800049da:	caa58593          	addi	a1,a1,-854 # 80008680 <syscalls+0x288>
    800049de:	0521                	addi	a0,a0,8
    800049e0:	a40fc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    800049e4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049ec:	0204a423          	sw	zero,40(s1)
}
    800049f0:	60e2                	ld	ra,24(sp)
    800049f2:	6442                	ld	s0,16(sp)
    800049f4:	64a2                	ld	s1,8(sp)
    800049f6:	6902                	ld	s2,0(sp)
    800049f8:	6105                	addi	sp,sp,32
    800049fa:	8082                	ret

00000000800049fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049fc:	1101                	addi	sp,sp,-32
    800049fe:	ec06                	sd	ra,24(sp)
    80004a00:	e822                	sd	s0,16(sp)
    80004a02:	e426                	sd	s1,8(sp)
    80004a04:	e04a                	sd	s2,0(sp)
    80004a06:	1000                	addi	s0,sp,32
    80004a08:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a0a:	00850913          	addi	s2,a0,8
    80004a0e:	854a                	mv	a0,s2
    80004a10:	a90fc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    80004a14:	409c                	lw	a5,0(s1)
    80004a16:	c799                	beqz	a5,80004a24 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004a18:	85ca                	mv	a1,s2
    80004a1a:	8526                	mv	a0,s1
    80004a1c:	9d3fd0ef          	jal	ra,800023ee <sleep>
  while (lk->locked) {
    80004a20:	409c                	lw	a5,0(s1)
    80004a22:	fbfd                	bnez	a5,80004a18 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004a24:	4785                	li	a5,1
    80004a26:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a28:	920fd0ef          	jal	ra,80001b48 <myproc>
    80004a2c:	591c                	lw	a5,48(a0)
    80004a2e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a30:	854a                	mv	a0,s2
    80004a32:	b06fc0ef          	jal	ra,80000d38 <release>
}
    80004a36:	60e2                	ld	ra,24(sp)
    80004a38:	6442                	ld	s0,16(sp)
    80004a3a:	64a2                	ld	s1,8(sp)
    80004a3c:	6902                	ld	s2,0(sp)
    80004a3e:	6105                	addi	sp,sp,32
    80004a40:	8082                	ret

0000000080004a42 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a42:	1101                	addi	sp,sp,-32
    80004a44:	ec06                	sd	ra,24(sp)
    80004a46:	e822                	sd	s0,16(sp)
    80004a48:	e426                	sd	s1,8(sp)
    80004a4a:	e04a                	sd	s2,0(sp)
    80004a4c:	1000                	addi	s0,sp,32
    80004a4e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a50:	00850913          	addi	s2,a0,8
    80004a54:	854a                	mv	a0,s2
    80004a56:	a4afc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    80004a5a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a5e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a62:	8526                	mv	a0,s1
    80004a64:	9d7fd0ef          	jal	ra,8000243a <wakeup>
  release(&lk->lk);
    80004a68:	854a                	mv	a0,s2
    80004a6a:	acefc0ef          	jal	ra,80000d38 <release>
}
    80004a6e:	60e2                	ld	ra,24(sp)
    80004a70:	6442                	ld	s0,16(sp)
    80004a72:	64a2                	ld	s1,8(sp)
    80004a74:	6902                	ld	s2,0(sp)
    80004a76:	6105                	addi	sp,sp,32
    80004a78:	8082                	ret

0000000080004a7a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a7a:	7179                	addi	sp,sp,-48
    80004a7c:	f406                	sd	ra,40(sp)
    80004a7e:	f022                	sd	s0,32(sp)
    80004a80:	ec26                	sd	s1,24(sp)
    80004a82:	e84a                	sd	s2,16(sp)
    80004a84:	e44e                	sd	s3,8(sp)
    80004a86:	1800                	addi	s0,sp,48
    80004a88:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a8a:	00850913          	addi	s2,a0,8
    80004a8e:	854a                	mv	a0,s2
    80004a90:	a10fc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a94:	409c                	lw	a5,0(s1)
    80004a96:	ef89                	bnez	a5,80004ab0 <holdingsleep+0x36>
    80004a98:	4481                	li	s1,0
  release(&lk->lk);
    80004a9a:	854a                	mv	a0,s2
    80004a9c:	a9cfc0ef          	jal	ra,80000d38 <release>
  return r;
}
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	70a2                	ld	ra,40(sp)
    80004aa4:	7402                	ld	s0,32(sp)
    80004aa6:	64e2                	ld	s1,24(sp)
    80004aa8:	6942                	ld	s2,16(sp)
    80004aaa:	69a2                	ld	s3,8(sp)
    80004aac:	6145                	addi	sp,sp,48
    80004aae:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ab0:	0284a983          	lw	s3,40(s1)
    80004ab4:	894fd0ef          	jal	ra,80001b48 <myproc>
    80004ab8:	5904                	lw	s1,48(a0)
    80004aba:	413484b3          	sub	s1,s1,s3
    80004abe:	0014b493          	seqz	s1,s1
    80004ac2:	bfe1                	j	80004a9a <holdingsleep+0x20>

0000000080004ac4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ac4:	1141                	addi	sp,sp,-16
    80004ac6:	e406                	sd	ra,8(sp)
    80004ac8:	e022                	sd	s0,0(sp)
    80004aca:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004acc:	00004597          	auipc	a1,0x4
    80004ad0:	bc458593          	addi	a1,a1,-1084 # 80008690 <syscalls+0x298>
    80004ad4:	00246517          	auipc	a0,0x246
    80004ad8:	01450513          	addi	a0,a0,20 # 8024aae8 <ftable>
    80004adc:	944fc0ef          	jal	ra,80000c20 <initlock>
}
    80004ae0:	60a2                	ld	ra,8(sp)
    80004ae2:	6402                	ld	s0,0(sp)
    80004ae4:	0141                	addi	sp,sp,16
    80004ae6:	8082                	ret

0000000080004ae8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ae8:	1101                	addi	sp,sp,-32
    80004aea:	ec06                	sd	ra,24(sp)
    80004aec:	e822                	sd	s0,16(sp)
    80004aee:	e426                	sd	s1,8(sp)
    80004af0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004af2:	00246517          	auipc	a0,0x246
    80004af6:	ff650513          	addi	a0,a0,-10 # 8024aae8 <ftable>
    80004afa:	9a6fc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004afe:	00246497          	auipc	s1,0x246
    80004b02:	00248493          	addi	s1,s1,2 # 8024ab00 <ftable+0x18>
    80004b06:	00247717          	auipc	a4,0x247
    80004b0a:	f9a70713          	addi	a4,a4,-102 # 8024baa0 <disk>
    if(f->ref == 0){
    80004b0e:	40dc                	lw	a5,4(s1)
    80004b10:	cf89                	beqz	a5,80004b2a <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b12:	02848493          	addi	s1,s1,40
    80004b16:	fee49ce3          	bne	s1,a4,80004b0e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b1a:	00246517          	auipc	a0,0x246
    80004b1e:	fce50513          	addi	a0,a0,-50 # 8024aae8 <ftable>
    80004b22:	a16fc0ef          	jal	ra,80000d38 <release>
  return 0;
    80004b26:	4481                	li	s1,0
    80004b28:	a809                	j	80004b3a <filealloc+0x52>
      f->ref = 1;
    80004b2a:	4785                	li	a5,1
    80004b2c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b2e:	00246517          	auipc	a0,0x246
    80004b32:	fba50513          	addi	a0,a0,-70 # 8024aae8 <ftable>
    80004b36:	a02fc0ef          	jal	ra,80000d38 <release>
}
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	60e2                	ld	ra,24(sp)
    80004b3e:	6442                	ld	s0,16(sp)
    80004b40:	64a2                	ld	s1,8(sp)
    80004b42:	6105                	addi	sp,sp,32
    80004b44:	8082                	ret

0000000080004b46 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b46:	1101                	addi	sp,sp,-32
    80004b48:	ec06                	sd	ra,24(sp)
    80004b4a:	e822                	sd	s0,16(sp)
    80004b4c:	e426                	sd	s1,8(sp)
    80004b4e:	1000                	addi	s0,sp,32
    80004b50:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b52:	00246517          	auipc	a0,0x246
    80004b56:	f9650513          	addi	a0,a0,-106 # 8024aae8 <ftable>
    80004b5a:	946fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004b5e:	40dc                	lw	a5,4(s1)
    80004b60:	02f05063          	blez	a5,80004b80 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004b64:	2785                	addiw	a5,a5,1
    80004b66:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b68:	00246517          	auipc	a0,0x246
    80004b6c:	f8050513          	addi	a0,a0,-128 # 8024aae8 <ftable>
    80004b70:	9c8fc0ef          	jal	ra,80000d38 <release>
  return f;
}
    80004b74:	8526                	mv	a0,s1
    80004b76:	60e2                	ld	ra,24(sp)
    80004b78:	6442                	ld	s0,16(sp)
    80004b7a:	64a2                	ld	s1,8(sp)
    80004b7c:	6105                	addi	sp,sp,32
    80004b7e:	8082                	ret
    panic("filedup");
    80004b80:	00004517          	auipc	a0,0x4
    80004b84:	b1850513          	addi	a0,a0,-1256 # 80008698 <syscalls+0x2a0>
    80004b88:	c01fb0ef          	jal	ra,80000788 <panic>

0000000080004b8c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b8c:	7139                	addi	sp,sp,-64
    80004b8e:	fc06                	sd	ra,56(sp)
    80004b90:	f822                	sd	s0,48(sp)
    80004b92:	f426                	sd	s1,40(sp)
    80004b94:	f04a                	sd	s2,32(sp)
    80004b96:	ec4e                	sd	s3,24(sp)
    80004b98:	e852                	sd	s4,16(sp)
    80004b9a:	e456                	sd	s5,8(sp)
    80004b9c:	0080                	addi	s0,sp,64
    80004b9e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ba0:	00246517          	auipc	a0,0x246
    80004ba4:	f4850513          	addi	a0,a0,-184 # 8024aae8 <ftable>
    80004ba8:	8f8fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004bac:	40dc                	lw	a5,4(s1)
    80004bae:	04f05963          	blez	a5,80004c00 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004bb2:	37fd                	addiw	a5,a5,-1
    80004bb4:	0007871b          	sext.w	a4,a5
    80004bb8:	c0dc                	sw	a5,4(s1)
    80004bba:	04e04963          	bgtz	a4,80004c0c <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bbe:	0004a903          	lw	s2,0(s1)
    80004bc2:	0094ca83          	lbu	s5,9(s1)
    80004bc6:	0104ba03          	ld	s4,16(s1)
    80004bca:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004bce:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bd2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bd6:	00246517          	auipc	a0,0x246
    80004bda:	f1250513          	addi	a0,a0,-238 # 8024aae8 <ftable>
    80004bde:	95afc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    80004be2:	4785                	li	a5,1
    80004be4:	04f90363          	beq	s2,a5,80004c2a <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004be8:	3979                	addiw	s2,s2,-2
    80004bea:	4785                	li	a5,1
    80004bec:	0327e663          	bltu	a5,s2,80004c18 <fileclose+0x8c>
    begin_op();
    80004bf0:	b93ff0ef          	jal	ra,80004782 <begin_op>
    iput(ff.ip);
    80004bf4:	854e                	mv	a0,s3
    80004bf6:	b22ff0ef          	jal	ra,80003f18 <iput>
    end_op();
    80004bfa:	bf7ff0ef          	jal	ra,800047f0 <end_op>
    80004bfe:	a829                	j	80004c18 <fileclose+0x8c>
    panic("fileclose");
    80004c00:	00004517          	auipc	a0,0x4
    80004c04:	aa050513          	addi	a0,a0,-1376 # 800086a0 <syscalls+0x2a8>
    80004c08:	b81fb0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    80004c0c:	00246517          	auipc	a0,0x246
    80004c10:	edc50513          	addi	a0,a0,-292 # 8024aae8 <ftable>
    80004c14:	924fc0ef          	jal	ra,80000d38 <release>
  }
}
    80004c18:	70e2                	ld	ra,56(sp)
    80004c1a:	7442                	ld	s0,48(sp)
    80004c1c:	74a2                	ld	s1,40(sp)
    80004c1e:	7902                	ld	s2,32(sp)
    80004c20:	69e2                	ld	s3,24(sp)
    80004c22:	6a42                	ld	s4,16(sp)
    80004c24:	6aa2                	ld	s5,8(sp)
    80004c26:	6121                	addi	sp,sp,64
    80004c28:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c2a:	85d6                	mv	a1,s5
    80004c2c:	8552                	mv	a0,s4
    80004c2e:	2ec000ef          	jal	ra,80004f1a <pipeclose>
    80004c32:	b7dd                	j	80004c18 <fileclose+0x8c>

0000000080004c34 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c34:	715d                	addi	sp,sp,-80
    80004c36:	e486                	sd	ra,72(sp)
    80004c38:	e0a2                	sd	s0,64(sp)
    80004c3a:	fc26                	sd	s1,56(sp)
    80004c3c:	f84a                	sd	s2,48(sp)
    80004c3e:	f44e                	sd	s3,40(sp)
    80004c40:	0880                	addi	s0,sp,80
    80004c42:	84aa                	mv	s1,a0
    80004c44:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c46:	f03fc0ef          	jal	ra,80001b48 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c4a:	409c                	lw	a5,0(s1)
    80004c4c:	37f9                	addiw	a5,a5,-2
    80004c4e:	4705                	li	a4,1
    80004c50:	02f76f63          	bltu	a4,a5,80004c8e <filestat+0x5a>
    80004c54:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c56:	6c88                	ld	a0,24(s1)
    80004c58:	942ff0ef          	jal	ra,80003d9a <ilock>
    stati(f->ip, &st);
    80004c5c:	fb840593          	addi	a1,s0,-72
    80004c60:	6c88                	ld	a0,24(s1)
    80004c62:	c9aff0ef          	jal	ra,800040fc <stati>
    iunlock(f->ip);
    80004c66:	6c88                	ld	a0,24(s1)
    80004c68:	9dcff0ef          	jal	ra,80003e44 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c6c:	46e1                	li	a3,24
    80004c6e:	fb840613          	addi	a2,s0,-72
    80004c72:	85ce                	mv	a1,s3
    80004c74:	05093503          	ld	a0,80(s2)
    80004c78:	af3fc0ef          	jal	ra,8000176a <copyout>
    80004c7c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c80:	60a6                	ld	ra,72(sp)
    80004c82:	6406                	ld	s0,64(sp)
    80004c84:	74e2                	ld	s1,56(sp)
    80004c86:	7942                	ld	s2,48(sp)
    80004c88:	79a2                	ld	s3,40(sp)
    80004c8a:	6161                	addi	sp,sp,80
    80004c8c:	8082                	ret
  return -1;
    80004c8e:	557d                	li	a0,-1
    80004c90:	bfc5                	j	80004c80 <filestat+0x4c>

0000000080004c92 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c92:	7179                	addi	sp,sp,-48
    80004c94:	f406                	sd	ra,40(sp)
    80004c96:	f022                	sd	s0,32(sp)
    80004c98:	ec26                	sd	s1,24(sp)
    80004c9a:	e84a                	sd	s2,16(sp)
    80004c9c:	e44e                	sd	s3,8(sp)
    80004c9e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ca0:	00854783          	lbu	a5,8(a0)
    80004ca4:	cbc1                	beqz	a5,80004d34 <fileread+0xa2>
    80004ca6:	84aa                	mv	s1,a0
    80004ca8:	89ae                	mv	s3,a1
    80004caa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cac:	411c                	lw	a5,0(a0)
    80004cae:	4705                	li	a4,1
    80004cb0:	04e78363          	beq	a5,a4,80004cf6 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cb4:	470d                	li	a4,3
    80004cb6:	04e78563          	beq	a5,a4,80004d00 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cba:	4709                	li	a4,2
    80004cbc:	06e79663          	bne	a5,a4,80004d28 <fileread+0x96>
    ilock(f->ip);
    80004cc0:	6d08                	ld	a0,24(a0)
    80004cc2:	8d8ff0ef          	jal	ra,80003d9a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cc6:	874a                	mv	a4,s2
    80004cc8:	5094                	lw	a3,32(s1)
    80004cca:	864e                	mv	a2,s3
    80004ccc:	4585                	li	a1,1
    80004cce:	6c88                	ld	a0,24(s1)
    80004cd0:	c56ff0ef          	jal	ra,80004126 <readi>
    80004cd4:	892a                	mv	s2,a0
    80004cd6:	00a05563          	blez	a0,80004ce0 <fileread+0x4e>
      f->off += r;
    80004cda:	509c                	lw	a5,32(s1)
    80004cdc:	9fa9                	addw	a5,a5,a0
    80004cde:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ce0:	6c88                	ld	a0,24(s1)
    80004ce2:	962ff0ef          	jal	ra,80003e44 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ce6:	854a                	mv	a0,s2
    80004ce8:	70a2                	ld	ra,40(sp)
    80004cea:	7402                	ld	s0,32(sp)
    80004cec:	64e2                	ld	s1,24(sp)
    80004cee:	6942                	ld	s2,16(sp)
    80004cf0:	69a2                	ld	s3,8(sp)
    80004cf2:	6145                	addi	sp,sp,48
    80004cf4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cf6:	6908                	ld	a0,16(a0)
    80004cf8:	34e000ef          	jal	ra,80005046 <piperead>
    80004cfc:	892a                	mv	s2,a0
    80004cfe:	b7e5                	j	80004ce6 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d00:	02451783          	lh	a5,36(a0)
    80004d04:	03079693          	slli	a3,a5,0x30
    80004d08:	92c1                	srli	a3,a3,0x30
    80004d0a:	4725                	li	a4,9
    80004d0c:	02d76663          	bltu	a4,a3,80004d38 <fileread+0xa6>
    80004d10:	0792                	slli	a5,a5,0x4
    80004d12:	00246717          	auipc	a4,0x246
    80004d16:	d3670713          	addi	a4,a4,-714 # 8024aa48 <devsw>
    80004d1a:	97ba                	add	a5,a5,a4
    80004d1c:	639c                	ld	a5,0(a5)
    80004d1e:	cf99                	beqz	a5,80004d3c <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004d20:	4505                	li	a0,1
    80004d22:	9782                	jalr	a5
    80004d24:	892a                	mv	s2,a0
    80004d26:	b7c1                	j	80004ce6 <fileread+0x54>
    panic("fileread");
    80004d28:	00004517          	auipc	a0,0x4
    80004d2c:	98850513          	addi	a0,a0,-1656 # 800086b0 <syscalls+0x2b8>
    80004d30:	a59fb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004d34:	597d                	li	s2,-1
    80004d36:	bf45                	j	80004ce6 <fileread+0x54>
      return -1;
    80004d38:	597d                	li	s2,-1
    80004d3a:	b775                	j	80004ce6 <fileread+0x54>
    80004d3c:	597d                	li	s2,-1
    80004d3e:	b765                	j	80004ce6 <fileread+0x54>

0000000080004d40 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d40:	715d                	addi	sp,sp,-80
    80004d42:	e486                	sd	ra,72(sp)
    80004d44:	e0a2                	sd	s0,64(sp)
    80004d46:	fc26                	sd	s1,56(sp)
    80004d48:	f84a                	sd	s2,48(sp)
    80004d4a:	f44e                	sd	s3,40(sp)
    80004d4c:	f052                	sd	s4,32(sp)
    80004d4e:	ec56                	sd	s5,24(sp)
    80004d50:	e85a                	sd	s6,16(sp)
    80004d52:	e45e                	sd	s7,8(sp)
    80004d54:	e062                	sd	s8,0(sp)
    80004d56:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d58:	00954783          	lbu	a5,9(a0)
    80004d5c:	0e078863          	beqz	a5,80004e4c <filewrite+0x10c>
    80004d60:	892a                	mv	s2,a0
    80004d62:	8b2e                	mv	s6,a1
    80004d64:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d66:	411c                	lw	a5,0(a0)
    80004d68:	4705                	li	a4,1
    80004d6a:	02e78263          	beq	a5,a4,80004d8e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d6e:	470d                	li	a4,3
    80004d70:	02e78463          	beq	a5,a4,80004d98 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d74:	4709                	li	a4,2
    80004d76:	0ce79563          	bne	a5,a4,80004e40 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d7a:	0ac05163          	blez	a2,80004e1c <filewrite+0xdc>
    int i = 0;
    80004d7e:	4981                	li	s3,0
    80004d80:	6b85                	lui	s7,0x1
    80004d82:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004d86:	6c05                	lui	s8,0x1
    80004d88:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004d8c:	a041                	j	80004e0c <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004d8e:	6908                	ld	a0,16(a0)
    80004d90:	1e2000ef          	jal	ra,80004f72 <pipewrite>
    80004d94:	8a2a                	mv	s4,a0
    80004d96:	a071                	j	80004e22 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d98:	02451783          	lh	a5,36(a0)
    80004d9c:	03079693          	slli	a3,a5,0x30
    80004da0:	92c1                	srli	a3,a3,0x30
    80004da2:	4725                	li	a4,9
    80004da4:	0ad76663          	bltu	a4,a3,80004e50 <filewrite+0x110>
    80004da8:	0792                	slli	a5,a5,0x4
    80004daa:	00246717          	auipc	a4,0x246
    80004dae:	c9e70713          	addi	a4,a4,-866 # 8024aa48 <devsw>
    80004db2:	97ba                	add	a5,a5,a4
    80004db4:	679c                	ld	a5,8(a5)
    80004db6:	cfd9                	beqz	a5,80004e54 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004db8:	4505                	li	a0,1
    80004dba:	9782                	jalr	a5
    80004dbc:	8a2a                	mv	s4,a0
    80004dbe:	a095                	j	80004e22 <filewrite+0xe2>
    80004dc0:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004dc4:	9bfff0ef          	jal	ra,80004782 <begin_op>
      ilock(f->ip);
    80004dc8:	01893503          	ld	a0,24(s2)
    80004dcc:	fcffe0ef          	jal	ra,80003d9a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004dd0:	8756                	mv	a4,s5
    80004dd2:	02092683          	lw	a3,32(s2)
    80004dd6:	01698633          	add	a2,s3,s6
    80004dda:	4585                	li	a1,1
    80004ddc:	01893503          	ld	a0,24(s2)
    80004de0:	c2aff0ef          	jal	ra,8000420a <writei>
    80004de4:	84aa                	mv	s1,a0
    80004de6:	00a05763          	blez	a0,80004df4 <filewrite+0xb4>
        f->off += r;
    80004dea:	02092783          	lw	a5,32(s2)
    80004dee:	9fa9                	addw	a5,a5,a0
    80004df0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004df4:	01893503          	ld	a0,24(s2)
    80004df8:	84cff0ef          	jal	ra,80003e44 <iunlock>
      end_op();
    80004dfc:	9f5ff0ef          	jal	ra,800047f0 <end_op>

      if(r != n1){
    80004e00:	009a9f63          	bne	s5,s1,80004e1e <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004e04:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e08:	0149db63          	bge	s3,s4,80004e1e <filewrite+0xde>
      int n1 = n - i;
    80004e0c:	413a04bb          	subw	s1,s4,s3
    80004e10:	0004879b          	sext.w	a5,s1
    80004e14:	fafbd6e3          	bge	s7,a5,80004dc0 <filewrite+0x80>
    80004e18:	84e2                	mv	s1,s8
    80004e1a:	b75d                	j	80004dc0 <filewrite+0x80>
    int i = 0;
    80004e1c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e1e:	013a1f63          	bne	s4,s3,80004e3c <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e22:	8552                	mv	a0,s4
    80004e24:	60a6                	ld	ra,72(sp)
    80004e26:	6406                	ld	s0,64(sp)
    80004e28:	74e2                	ld	s1,56(sp)
    80004e2a:	7942                	ld	s2,48(sp)
    80004e2c:	79a2                	ld	s3,40(sp)
    80004e2e:	7a02                	ld	s4,32(sp)
    80004e30:	6ae2                	ld	s5,24(sp)
    80004e32:	6b42                	ld	s6,16(sp)
    80004e34:	6ba2                	ld	s7,8(sp)
    80004e36:	6c02                	ld	s8,0(sp)
    80004e38:	6161                	addi	sp,sp,80
    80004e3a:	8082                	ret
    ret = (i == n ? n : -1);
    80004e3c:	5a7d                	li	s4,-1
    80004e3e:	b7d5                	j	80004e22 <filewrite+0xe2>
    panic("filewrite");
    80004e40:	00004517          	auipc	a0,0x4
    80004e44:	88050513          	addi	a0,a0,-1920 # 800086c0 <syscalls+0x2c8>
    80004e48:	941fb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004e4c:	5a7d                	li	s4,-1
    80004e4e:	bfd1                	j	80004e22 <filewrite+0xe2>
      return -1;
    80004e50:	5a7d                	li	s4,-1
    80004e52:	bfc1                	j	80004e22 <filewrite+0xe2>
    80004e54:	5a7d                	li	s4,-1
    80004e56:	b7f1                	j	80004e22 <filewrite+0xe2>

0000000080004e58 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e58:	7179                	addi	sp,sp,-48
    80004e5a:	f406                	sd	ra,40(sp)
    80004e5c:	f022                	sd	s0,32(sp)
    80004e5e:	ec26                	sd	s1,24(sp)
    80004e60:	e84a                	sd	s2,16(sp)
    80004e62:	e44e                	sd	s3,8(sp)
    80004e64:	e052                	sd	s4,0(sp)
    80004e66:	1800                	addi	s0,sp,48
    80004e68:	84aa                	mv	s1,a0
    80004e6a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e6c:	0005b023          	sd	zero,0(a1)
    80004e70:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e74:	c75ff0ef          	jal	ra,80004ae8 <filealloc>
    80004e78:	e088                	sd	a0,0(s1)
    80004e7a:	cd35                	beqz	a0,80004ef6 <pipealloc+0x9e>
    80004e7c:	c6dff0ef          	jal	ra,80004ae8 <filealloc>
    80004e80:	00aa3023          	sd	a0,0(s4)
    80004e84:	c52d                	beqz	a0,80004eee <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e86:	d25fb0ef          	jal	ra,80000baa <kalloc>
    80004e8a:	892a                	mv	s2,a0
    80004e8c:	cd31                	beqz	a0,80004ee8 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004e8e:	4985                	li	s3,1
    80004e90:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e94:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e98:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e9c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ea0:	00004597          	auipc	a1,0x4
    80004ea4:	83058593          	addi	a1,a1,-2000 # 800086d0 <syscalls+0x2d8>
    80004ea8:	d79fb0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    80004eac:	609c                	ld	a5,0(s1)
    80004eae:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004eb2:	609c                	ld	a5,0(s1)
    80004eb4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004eb8:	609c                	ld	a5,0(s1)
    80004eba:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ebe:	609c                	ld	a5,0(s1)
    80004ec0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ec4:	000a3783          	ld	a5,0(s4)
    80004ec8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ecc:	000a3783          	ld	a5,0(s4)
    80004ed0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ed4:	000a3783          	ld	a5,0(s4)
    80004ed8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004edc:	000a3783          	ld	a5,0(s4)
    80004ee0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ee4:	4501                	li	a0,0
    80004ee6:	a005                	j	80004f06 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ee8:	6088                	ld	a0,0(s1)
    80004eea:	e501                	bnez	a0,80004ef2 <pipealloc+0x9a>
    80004eec:	a029                	j	80004ef6 <pipealloc+0x9e>
    80004eee:	6088                	ld	a0,0(s1)
    80004ef0:	c11d                	beqz	a0,80004f16 <pipealloc+0xbe>
    fileclose(*f0);
    80004ef2:	c9bff0ef          	jal	ra,80004b8c <fileclose>
  if(*f1)
    80004ef6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004efa:	557d                	li	a0,-1
  if(*f1)
    80004efc:	c789                	beqz	a5,80004f06 <pipealloc+0xae>
    fileclose(*f1);
    80004efe:	853e                	mv	a0,a5
    80004f00:	c8dff0ef          	jal	ra,80004b8c <fileclose>
  return -1;
    80004f04:	557d                	li	a0,-1
}
    80004f06:	70a2                	ld	ra,40(sp)
    80004f08:	7402                	ld	s0,32(sp)
    80004f0a:	64e2                	ld	s1,24(sp)
    80004f0c:	6942                	ld	s2,16(sp)
    80004f0e:	69a2                	ld	s3,8(sp)
    80004f10:	6a02                	ld	s4,0(sp)
    80004f12:	6145                	addi	sp,sp,48
    80004f14:	8082                	ret
  return -1;
    80004f16:	557d                	li	a0,-1
    80004f18:	b7fd                	j	80004f06 <pipealloc+0xae>

0000000080004f1a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f1a:	1101                	addi	sp,sp,-32
    80004f1c:	ec06                	sd	ra,24(sp)
    80004f1e:	e822                	sd	s0,16(sp)
    80004f20:	e426                	sd	s1,8(sp)
    80004f22:	e04a                	sd	s2,0(sp)
    80004f24:	1000                	addi	s0,sp,32
    80004f26:	84aa                	mv	s1,a0
    80004f28:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f2a:	d77fb0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    80004f2e:	02090763          	beqz	s2,80004f5c <pipeclose+0x42>
    pi->writeopen = 0;
    80004f32:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f36:	21848513          	addi	a0,s1,536
    80004f3a:	d00fd0ef          	jal	ra,8000243a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f3e:	2204b783          	ld	a5,544(s1)
    80004f42:	e785                	bnez	a5,80004f6a <pipeclose+0x50>
    release(&pi->lock);
    80004f44:	8526                	mv	a0,s1
    80004f46:	df3fb0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	b2ffb0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80004f50:	60e2                	ld	ra,24(sp)
    80004f52:	6442                	ld	s0,16(sp)
    80004f54:	64a2                	ld	s1,8(sp)
    80004f56:	6902                	ld	s2,0(sp)
    80004f58:	6105                	addi	sp,sp,32
    80004f5a:	8082                	ret
    pi->readopen = 0;
    80004f5c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f60:	21c48513          	addi	a0,s1,540
    80004f64:	cd6fd0ef          	jal	ra,8000243a <wakeup>
    80004f68:	bfd9                	j	80004f3e <pipeclose+0x24>
    release(&pi->lock);
    80004f6a:	8526                	mv	a0,s1
    80004f6c:	dcdfb0ef          	jal	ra,80000d38 <release>
}
    80004f70:	b7c5                	j	80004f50 <pipeclose+0x36>

0000000080004f72 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f72:	711d                	addi	sp,sp,-96
    80004f74:	ec86                	sd	ra,88(sp)
    80004f76:	e8a2                	sd	s0,80(sp)
    80004f78:	e4a6                	sd	s1,72(sp)
    80004f7a:	e0ca                	sd	s2,64(sp)
    80004f7c:	fc4e                	sd	s3,56(sp)
    80004f7e:	f852                	sd	s4,48(sp)
    80004f80:	f456                	sd	s5,40(sp)
    80004f82:	f05a                	sd	s6,32(sp)
    80004f84:	ec5e                	sd	s7,24(sp)
    80004f86:	e862                	sd	s8,16(sp)
    80004f88:	1080                	addi	s0,sp,96
    80004f8a:	84aa                	mv	s1,a0
    80004f8c:	8aae                	mv	s5,a1
    80004f8e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f90:	bb9fc0ef          	jal	ra,80001b48 <myproc>
    80004f94:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f96:	8526                	mv	a0,s1
    80004f98:	d09fb0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    80004f9c:	09405c63          	blez	s4,80005034 <pipewrite+0xc2>
  int i = 0;
    80004fa0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fa2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fa4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004fa8:	21c48b93          	addi	s7,s1,540
    80004fac:	a81d                	j	80004fe2 <pipewrite+0x70>
      release(&pi->lock);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	d89fb0ef          	jal	ra,80000d38 <release>
      return -1;
    80004fb4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004fb6:	854a                	mv	a0,s2
    80004fb8:	60e6                	ld	ra,88(sp)
    80004fba:	6446                	ld	s0,80(sp)
    80004fbc:	64a6                	ld	s1,72(sp)
    80004fbe:	6906                	ld	s2,64(sp)
    80004fc0:	79e2                	ld	s3,56(sp)
    80004fc2:	7a42                	ld	s4,48(sp)
    80004fc4:	7aa2                	ld	s5,40(sp)
    80004fc6:	7b02                	ld	s6,32(sp)
    80004fc8:	6be2                	ld	s7,24(sp)
    80004fca:	6c42                	ld	s8,16(sp)
    80004fcc:	6125                	addi	sp,sp,96
    80004fce:	8082                	ret
      wakeup(&pi->nread);
    80004fd0:	8562                	mv	a0,s8
    80004fd2:	c68fd0ef          	jal	ra,8000243a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fd6:	85a6                	mv	a1,s1
    80004fd8:	855e                	mv	a0,s7
    80004fda:	c14fd0ef          	jal	ra,800023ee <sleep>
  while(i < n){
    80004fde:	05495c63          	bge	s2,s4,80005036 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004fe2:	2204a783          	lw	a5,544(s1)
    80004fe6:	d7e1                	beqz	a5,80004fae <pipewrite+0x3c>
    80004fe8:	854e                	mv	a0,s3
    80004fea:	e3cfd0ef          	jal	ra,80002626 <killed>
    80004fee:	f161                	bnez	a0,80004fae <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ff0:	2184a783          	lw	a5,536(s1)
    80004ff4:	21c4a703          	lw	a4,540(s1)
    80004ff8:	2007879b          	addiw	a5,a5,512
    80004ffc:	fcf70ae3          	beq	a4,a5,80004fd0 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005000:	4685                	li	a3,1
    80005002:	01590633          	add	a2,s2,s5
    80005006:	faf40593          	addi	a1,s0,-81
    8000500a:	0509b503          	ld	a0,80(s3)
    8000500e:	857fc0ef          	jal	ra,80001864 <copyin>
    80005012:	03650263          	beq	a0,s6,80005036 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005016:	21c4a783          	lw	a5,540(s1)
    8000501a:	0017871b          	addiw	a4,a5,1
    8000501e:	20e4ae23          	sw	a4,540(s1)
    80005022:	1ff7f793          	andi	a5,a5,511
    80005026:	97a6                	add	a5,a5,s1
    80005028:	faf44703          	lbu	a4,-81(s0)
    8000502c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005030:	2905                	addiw	s2,s2,1
    80005032:	b775                	j	80004fde <pipewrite+0x6c>
  int i = 0;
    80005034:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005036:	21848513          	addi	a0,s1,536
    8000503a:	c00fd0ef          	jal	ra,8000243a <wakeup>
  release(&pi->lock);
    8000503e:	8526                	mv	a0,s1
    80005040:	cf9fb0ef          	jal	ra,80000d38 <release>
  return i;
    80005044:	bf8d                	j	80004fb6 <pipewrite+0x44>

0000000080005046 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005046:	715d                	addi	sp,sp,-80
    80005048:	e486                	sd	ra,72(sp)
    8000504a:	e0a2                	sd	s0,64(sp)
    8000504c:	fc26                	sd	s1,56(sp)
    8000504e:	f84a                	sd	s2,48(sp)
    80005050:	f44e                	sd	s3,40(sp)
    80005052:	f052                	sd	s4,32(sp)
    80005054:	ec56                	sd	s5,24(sp)
    80005056:	e85a                	sd	s6,16(sp)
    80005058:	0880                	addi	s0,sp,80
    8000505a:	84aa                	mv	s1,a0
    8000505c:	892e                	mv	s2,a1
    8000505e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005060:	ae9fc0ef          	jal	ra,80001b48 <myproc>
    80005064:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005066:	8526                	mv	a0,s1
    80005068:	c39fb0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000506c:	2184a703          	lw	a4,536(s1)
    80005070:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005074:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005078:	02f71363          	bne	a4,a5,8000509e <piperead+0x58>
    8000507c:	2244a783          	lw	a5,548(s1)
    80005080:	cf99                	beqz	a5,8000509e <piperead+0x58>
    if(killed(pr)){
    80005082:	8552                	mv	a0,s4
    80005084:	da2fd0ef          	jal	ra,80002626 <killed>
    80005088:	e151                	bnez	a0,8000510c <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000508a:	85a6                	mv	a1,s1
    8000508c:	854e                	mv	a0,s3
    8000508e:	b60fd0ef          	jal	ra,800023ee <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005092:	2184a703          	lw	a4,536(s1)
    80005096:	21c4a783          	lw	a5,540(s1)
    8000509a:	fef701e3          	beq	a4,a5,8000507c <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000509e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800050a0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050a2:	05505363          	blez	s5,800050e8 <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    800050a6:	2184a783          	lw	a5,536(s1)
    800050aa:	21c4a703          	lw	a4,540(s1)
    800050ae:	02f70d63          	beq	a4,a5,800050e8 <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    800050b2:	1ff7f793          	andi	a5,a5,511
    800050b6:	97a6                	add	a5,a5,s1
    800050b8:	0187c783          	lbu	a5,24(a5)
    800050bc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800050c0:	4685                	li	a3,1
    800050c2:	fbf40613          	addi	a2,s0,-65
    800050c6:	85ca                	mv	a1,s2
    800050c8:	050a3503          	ld	a0,80(s4)
    800050cc:	e9efc0ef          	jal	ra,8000176a <copyout>
    800050d0:	05650363          	beq	a0,s6,80005116 <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800050d4:	2184a783          	lw	a5,536(s1)
    800050d8:	2785                	addiw	a5,a5,1
    800050da:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050de:	2985                	addiw	s3,s3,1
    800050e0:	0905                	addi	s2,s2,1
    800050e2:	fd3a92e3          	bne	s5,s3,800050a6 <piperead+0x60>
    800050e6:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050e8:	21c48513          	addi	a0,s1,540
    800050ec:	b4efd0ef          	jal	ra,8000243a <wakeup>
  release(&pi->lock);
    800050f0:	8526                	mv	a0,s1
    800050f2:	c47fb0ef          	jal	ra,80000d38 <release>
  return i;
}
    800050f6:	854e                	mv	a0,s3
    800050f8:	60a6                	ld	ra,72(sp)
    800050fa:	6406                	ld	s0,64(sp)
    800050fc:	74e2                	ld	s1,56(sp)
    800050fe:	7942                	ld	s2,48(sp)
    80005100:	79a2                	ld	s3,40(sp)
    80005102:	7a02                	ld	s4,32(sp)
    80005104:	6ae2                	ld	s5,24(sp)
    80005106:	6b42                	ld	s6,16(sp)
    80005108:	6161                	addi	sp,sp,80
    8000510a:	8082                	ret
      release(&pi->lock);
    8000510c:	8526                	mv	a0,s1
    8000510e:	c2bfb0ef          	jal	ra,80000d38 <release>
      return -1;
    80005112:	59fd                	li	s3,-1
    80005114:	b7cd                	j	800050f6 <piperead+0xb0>
      if(i == 0)
    80005116:	fc0999e3          	bnez	s3,800050e8 <piperead+0xa2>
        i = -1;
    8000511a:	89aa                	mv	s3,a0
    8000511c:	b7f1                	j	800050e8 <piperead+0xa2>

000000008000511e <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000511e:	1141                	addi	sp,sp,-16
    80005120:	e422                	sd	s0,8(sp)
    80005122:	0800                	addi	s0,sp,16
    80005124:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005126:	8905                	andi	a0,a0,1
    80005128:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000512a:	8b89                	andi	a5,a5,2
    8000512c:	c399                	beqz	a5,80005132 <flags2perm+0x14>
      perm |= PTE_W;
    8000512e:	00456513          	ori	a0,a0,4
    return perm;
}
    80005132:	6422                	ld	s0,8(sp)
    80005134:	0141                	addi	sp,sp,16
    80005136:	8082                	ret

0000000080005138 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005138:	b5010113          	addi	sp,sp,-1200
    8000513c:	4a113423          	sd	ra,1192(sp)
    80005140:	4a813023          	sd	s0,1184(sp)
    80005144:	48913c23          	sd	s1,1176(sp)
    80005148:	49213823          	sd	s2,1168(sp)
    8000514c:	49313423          	sd	s3,1160(sp)
    80005150:	49413023          	sd	s4,1152(sp)
    80005154:	47513c23          	sd	s5,1144(sp)
    80005158:	47613823          	sd	s6,1136(sp)
    8000515c:	47713423          	sd	s7,1128(sp)
    80005160:	47813023          	sd	s8,1120(sp)
    80005164:	45913c23          	sd	s9,1112(sp)
    80005168:	45a13823          	sd	s10,1104(sp)
    8000516c:	45b13423          	sd	s11,1096(sp)
    80005170:	4b010413          	addi	s0,sp,1200
    80005174:	84aa                	mv	s1,a0
    80005176:	b6a43023          	sd	a0,-1184(s0)
    8000517a:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000517e:	9cbfc0ef          	jal	ra,80001b48 <myproc>
    80005182:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    80005186:	dfcff0ef          	jal	ra,80004782 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000518a:	8526                	mv	a0,s1
    8000518c:	c02ff0ef          	jal	ra,8000458e <namei>
    80005190:	cd25                	beqz	a0,80005208 <kexec+0xd0>
    80005192:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005194:	c07fe0ef          	jal	ra,80003d9a <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005198:	04000713          	li	a4,64
    8000519c:	4681                	li	a3,0
    8000519e:	e5040613          	addi	a2,s0,-432
    800051a2:	4581                	li	a1,0
    800051a4:	8556                	mv	a0,s5
    800051a6:	f81fe0ef          	jal	ra,80004126 <readi>
    800051aa:	04000793          	li	a5,64
    800051ae:	00f51a63          	bne	a0,a5,800051c2 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800051b2:	e5042703          	lw	a4,-432(s0)
    800051b6:	464c47b7          	lui	a5,0x464c4
    800051ba:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051be:	04f70963          	beq	a4,a5,80005210 <kexec+0xd8>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    memset(p->vmas, 0, sizeof(p->vmas));
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    800051c2:	8556                	mv	a0,s5
    800051c4:	dddfe0ef          	jal	ra,80003fa0 <iunlockput>
    end_op();
    800051c8:	e28ff0ef          	jal	ra,800047f0 <end_op>
  }
  return -1;
    800051cc:	557d                	li	a0,-1
}
    800051ce:	4a813083          	ld	ra,1192(sp)
    800051d2:	4a013403          	ld	s0,1184(sp)
    800051d6:	49813483          	ld	s1,1176(sp)
    800051da:	49013903          	ld	s2,1168(sp)
    800051de:	48813983          	ld	s3,1160(sp)
    800051e2:	48013a03          	ld	s4,1152(sp)
    800051e6:	47813a83          	ld	s5,1144(sp)
    800051ea:	47013b03          	ld	s6,1136(sp)
    800051ee:	46813b83          	ld	s7,1128(sp)
    800051f2:	46013c03          	ld	s8,1120(sp)
    800051f6:	45813c83          	ld	s9,1112(sp)
    800051fa:	45013d03          	ld	s10,1104(sp)
    800051fe:	44813d83          	ld	s11,1096(sp)
    80005202:	4b010113          	addi	sp,sp,1200
    80005206:	8082                	ret
    end_op();
    80005208:	de8ff0ef          	jal	ra,800047f0 <end_op>
    return -1;
    8000520c:	557d                	li	a0,-1
    8000520e:	b7c1                	j	800051ce <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80005210:	b7843503          	ld	a0,-1160(s0)
    80005214:	b35fc0ef          	jal	ra,80001d48 <proc_pagetable>
    80005218:	8baa                	mv	s7,a0
    8000521a:	d545                	beqz	a0,800051c2 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000521c:	e7042783          	lw	a5,-400(s0)
    80005220:	e8845703          	lhu	a4,-376(s0)
    80005224:	0e070d63          	beqz	a4,8000531e <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005228:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000522c:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005230:	6a05                	lui	s4,0x1
    80005232:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005236:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000523a:	6d85                	lui	s11,0x1
    8000523c:	7d7d                	lui	s10,0xfffff
    8000523e:	a09d                	j	800052a4 <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005240:	00003517          	auipc	a0,0x3
    80005244:	49850513          	addi	a0,a0,1176 # 800086d8 <syscalls+0x2e0>
    80005248:	d40fb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000524c:	874a                	mv	a4,s2
    8000524e:	009c86bb          	addw	a3,s9,s1
    80005252:	4581                	li	a1,0
    80005254:	8556                	mv	a0,s5
    80005256:	ed1fe0ef          	jal	ra,80004126 <readi>
    8000525a:	2501                	sext.w	a0,a0
    8000525c:	0ea91f63          	bne	s2,a0,8000535a <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    80005260:	009d84bb          	addw	s1,s11,s1
    80005264:	013d09bb          	addw	s3,s10,s3
    80005268:	0364f063          	bgeu	s1,s6,80005288 <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    8000526c:	02049593          	slli	a1,s1,0x20
    80005270:	9181                	srli	a1,a1,0x20
    80005272:	95e2                	add	a1,a1,s8
    80005274:	855e                	mv	a0,s7
    80005276:	e15fb0ef          	jal	ra,8000108a <walkaddr>
    8000527a:	862a                	mv	a2,a0
    if(pa == 0)
    8000527c:	d171                	beqz	a0,80005240 <kexec+0x108>
      n = PGSIZE;
    8000527e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005280:	fd49f6e3          	bgeu	s3,s4,8000524c <kexec+0x114>
      n = sz - i;
    80005284:	894e                	mv	s2,s3
    80005286:	b7d9                	j	8000524c <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005288:	b8843783          	ld	a5,-1144(s0)
    8000528c:	0017869b          	addiw	a3,a5,1
    80005290:	b8d43423          	sd	a3,-1144(s0)
    80005294:	b8043783          	ld	a5,-1152(s0)
    80005298:	0387879b          	addiw	a5,a5,56
    8000529c:	e8845703          	lhu	a4,-376(s0)
    800052a0:	08e6d163          	bge	a3,a4,80005322 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052a4:	2781                	sext.w	a5,a5
    800052a6:	b8f43023          	sd	a5,-1152(s0)
    800052aa:	03800713          	li	a4,56
    800052ae:	86be                	mv	a3,a5
    800052b0:	e1840613          	addi	a2,s0,-488
    800052b4:	4581                	li	a1,0
    800052b6:	8556                	mv	a0,s5
    800052b8:	e6ffe0ef          	jal	ra,80004126 <readi>
    800052bc:	03800793          	li	a5,56
    800052c0:	08f51d63          	bne	a0,a5,8000535a <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    800052c4:	e1842783          	lw	a5,-488(s0)
    800052c8:	4705                	li	a4,1
    800052ca:	fae79fe3          	bne	a5,a4,80005288 <kexec+0x150>
    if(ph.memsz < ph.filesz)
    800052ce:	e4043483          	ld	s1,-448(s0)
    800052d2:	e3843783          	ld	a5,-456(s0)
    800052d6:	08f4e263          	bltu	s1,a5,8000535a <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800052da:	e2843783          	ld	a5,-472(s0)
    800052de:	94be                	add	s1,s1,a5
    800052e0:	06f4ed63          	bltu	s1,a5,8000535a <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    800052e4:	b5843703          	ld	a4,-1192(s0)
    800052e8:	8ff9                	and	a5,a5,a4
    800052ea:	eba5                	bnez	a5,8000535a <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052ec:	e1c42503          	lw	a0,-484(s0)
    800052f0:	e2fff0ef          	jal	ra,8000511e <flags2perm>
    800052f4:	86aa                	mv	a3,a0
    800052f6:	8626                	mv	a2,s1
    800052f8:	b7043583          	ld	a1,-1168(s0)
    800052fc:	855e                	mv	a0,s7
    800052fe:	856fc0ef          	jal	ra,80001354 <uvmalloc>
    80005302:	b6a43823          	sd	a0,-1168(s0)
    80005306:	c931                	beqz	a0,8000535a <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005308:	e2843c03          	ld	s8,-472(s0)
    8000530c:	e2042c83          	lw	s9,-480(s0)
    80005310:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005314:	f60b0ae3          	beqz	s6,80005288 <kexec+0x150>
    80005318:	89da                	mv	s3,s6
    8000531a:	4481                	li	s1,0
    8000531c:	bf81                	j	8000526c <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000531e:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    80005322:	8556                	mv	a0,s5
    80005324:	c7dfe0ef          	jal	ra,80003fa0 <iunlockput>
  end_op();
    80005328:	cc8ff0ef          	jal	ra,800047f0 <end_op>
  p = myproc();
    8000532c:	81dfc0ef          	jal	ra,80001b48 <myproc>
    80005330:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    80005334:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005338:	6785                	lui	a5,0x1
    8000533a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000533c:	b7043703          	ld	a4,-1168(s0)
    80005340:	00f705b3          	add	a1,a4,a5
    80005344:	77fd                	lui	a5,0xfffff
    80005346:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005348:	4691                	li	a3,4
    8000534a:	6609                	lui	a2,0x2
    8000534c:	962e                	add	a2,a2,a1
    8000534e:	855e                	mv	a0,s7
    80005350:	804fc0ef          	jal	ra,80001354 <uvmalloc>
    80005354:	8b2a                	mv	s6,a0
  ip = 0;
    80005356:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005358:	ed0d                	bnez	a0,80005392 <kexec+0x25a>
    delete_shm_from_proc(p);
    8000535a:	b7843903          	ld	s2,-1160(s0)
    8000535e:	854a                	mv	a0,s2
    80005360:	96bfc0ef          	jal	ra,80001cca <delete_shm_from_proc>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80005364:	16890493          	addi	s1,s2,360
    80005368:	85a6                	mv	a1,s1
    8000536a:	05093503          	ld	a0,80(s2)
    8000536e:	a5ffc0ef          	jal	ra,80001dcc <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80005372:	28000613          	li	a2,640
    80005376:	4581                	li	a1,0
    80005378:	8526                	mv	a0,s1
    8000537a:	9fbfb0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    8000537e:	04893583          	ld	a1,72(s2)
    80005382:	05093503          	ld	a0,80(s2)
    80005386:	a91fc0ef          	jal	ra,80001e16 <proc_freepagetable>
  if(ip){
    8000538a:	e20a9ce3          	bnez	s5,800051c2 <kexec+0x8a>
  return -1;
    8000538e:	557d                	li	a0,-1
    80005390:	bd3d                	j	800051ce <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005392:	75f9                	lui	a1,0xffffe
    80005394:	95aa                	add	a1,a1,a0
    80005396:	855e                	mv	a0,s7
    80005398:	a6afc0ef          	jal	ra,80001602 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000539c:	7c7d                	lui	s8,0xfffff
    8000539e:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800053a0:	b6843783          	ld	a5,-1176(s0)
    800053a4:	6388                	ld	a0,0(a5)
    800053a6:	c125                	beqz	a0,80005406 <kexec+0x2ce>
    800053a8:	e9040993          	addi	s3,s0,-368
    800053ac:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    800053b0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800053b2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053b4:	b39fb0ef          	jal	ra,80000eec <strlen>
    800053b8:	0015079b          	addiw	a5,a0,1
    800053bc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053c0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800053c4:	11896963          	bltu	s2,s8,800054d6 <kexec+0x39e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053c8:	b6843d03          	ld	s10,-1176(s0)
    800053cc:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdab288>
    800053d0:	8552                	mv	a0,s4
    800053d2:	b1bfb0ef          	jal	ra,80000eec <strlen>
    800053d6:	0015069b          	addiw	a3,a0,1
    800053da:	8652                	mv	a2,s4
    800053dc:	85ca                	mv	a1,s2
    800053de:	855e                	mv	a0,s7
    800053e0:	b8afc0ef          	jal	ra,8000176a <copyout>
    800053e4:	0e054b63          	bltz	a0,800054da <kexec+0x3a2>
    ustack[argc] = sp;
    800053e8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053ec:	0485                	addi	s1,s1,1
    800053ee:	008d0793          	addi	a5,s10,8
    800053f2:	b6f43423          	sd	a5,-1176(s0)
    800053f6:	008d3503          	ld	a0,8(s10)
    800053fa:	c901                	beqz	a0,8000540a <kexec+0x2d2>
    if(argc >= MAXARG)
    800053fc:	09a1                	addi	s3,s3,8
    800053fe:	fb599be3          	bne	s3,s5,800053b4 <kexec+0x27c>
  ip = 0;
    80005402:	4a81                	li	s5,0
    80005404:	bf99                	j	8000535a <kexec+0x222>
  sp = sz;
    80005406:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005408:	4481                	li	s1,0
  ustack[argc] = 0;
    8000540a:	00349793          	slli	a5,s1,0x3
    8000540e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdab218>
    80005412:	97a2                	add	a5,a5,s0
    80005414:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005418:	00148693          	addi	a3,s1,1
    8000541c:	068e                	slli	a3,a3,0x3
    8000541e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005422:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005426:	4a81                	li	s5,0
  if(sp < stackbase)
    80005428:	f38969e3          	bltu	s2,s8,8000535a <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000542c:	e9040613          	addi	a2,s0,-368
    80005430:	85ca                	mv	a1,s2
    80005432:	855e                	mv	a0,s7
    80005434:	b36fc0ef          	jal	ra,8000176a <copyout>
    80005438:	0a054363          	bltz	a0,800054de <kexec+0x3a6>
  p->trapframe->a1 = sp;
    8000543c:	b7843783          	ld	a5,-1160(s0)
    80005440:	6fbc                	ld	a5,88(a5)
    80005442:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005446:	b6043783          	ld	a5,-1184(s0)
    8000544a:	0007c703          	lbu	a4,0(a5)
    8000544e:	cf11                	beqz	a4,8000546a <kexec+0x332>
    80005450:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005452:	02f00693          	li	a3,47
    80005456:	a039                	j	80005464 <kexec+0x32c>
      last = s+1;
    80005458:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    8000545c:	0785                	addi	a5,a5,1
    8000545e:	fff7c703          	lbu	a4,-1(a5)
    80005462:	c701                	beqz	a4,8000546a <kexec+0x332>
    if(*s == '/')
    80005464:	fed71ce3          	bne	a4,a3,8000545c <kexec+0x324>
    80005468:	bfc5                	j	80005458 <kexec+0x320>
  safestrcpy(p->name, last, sizeof(p->name));
    8000546a:	4641                	li	a2,16
    8000546c:	b6043583          	ld	a1,-1184(s0)
    80005470:	b7843983          	ld	s3,-1160(s0)
    80005474:	15898513          	addi	a0,s3,344
    80005478:	a43fb0ef          	jal	ra,80000eba <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    8000547c:	16898a13          	addi	s4,s3,360
    80005480:	28000613          	li	a2,640
    80005484:	85d2                	mv	a1,s4
    80005486:	b9840513          	addi	a0,s0,-1128
    8000548a:	947fb0ef          	jal	ra,80000dd0 <memmove>
  oldpagetable = p->pagetable;
    8000548e:	86ce                	mv	a3,s3
    80005490:	0509b983          	ld	s3,80(s3)
  p->pagetable = pagetable;
    80005494:	0576b823          	sd	s7,80(a3)
  p->sz = sz;
    80005498:	0566b423          	sd	s6,72(a3)
  p->trapframe->epc = elf.entry;
    8000549c:	6ebc                	ld	a5,88(a3)
    8000549e:	e6843703          	ld	a4,-408(s0)
    800054a2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    800054a4:	6ebc                	ld	a5,88(a3)
    800054a6:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    800054aa:	28000613          	li	a2,640
    800054ae:	4581                	li	a1,0
    800054b0:	8552                	mv	a0,s4
    800054b2:	8c3fb0ef          	jal	ra,80000d74 <memset>
  delete_shm_from_vmas(oldvmas);
    800054b6:	b9840513          	addi	a0,s0,-1128
    800054ba:	f94fc0ef          	jal	ra,80001c4e <delete_shm_from_vmas>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    800054be:	b9840593          	addi	a1,s0,-1128
    800054c2:	854e                	mv	a0,s3
    800054c4:	909fc0ef          	jal	ra,80001dcc <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    800054c8:	85e6                	mv	a1,s9
    800054ca:	854e                	mv	a0,s3
    800054cc:	94bfc0ef          	jal	ra,80001e16 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054d0:	0004851b          	sext.w	a0,s1
    800054d4:	b9ed                	j	800051ce <kexec+0x96>
  ip = 0;
    800054d6:	4a81                	li	s5,0
    800054d8:	b549                	j	8000535a <kexec+0x222>
    800054da:	4a81                	li	s5,0
    800054dc:	bdbd                	j	8000535a <kexec+0x222>
    800054de:	4a81                	li	s5,0
    800054e0:	bdad                	j	8000535a <kexec+0x222>

00000000800054e2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054e2:	7179                	addi	sp,sp,-48
    800054e4:	f406                	sd	ra,40(sp)
    800054e6:	f022                	sd	s0,32(sp)
    800054e8:	ec26                	sd	s1,24(sp)
    800054ea:	e84a                	sd	s2,16(sp)
    800054ec:	1800                	addi	s0,sp,48
    800054ee:	892e                	mv	s2,a1
    800054f0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054f2:	fdc40593          	addi	a1,s0,-36
    800054f6:	831fd0ef          	jal	ra,80002d26 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054fa:	fdc42703          	lw	a4,-36(s0)
    800054fe:	47bd                	li	a5,15
    80005500:	02e7e963          	bltu	a5,a4,80005532 <argfd+0x50>
    80005504:	e44fc0ef          	jal	ra,80001b48 <myproc>
    80005508:	fdc42703          	lw	a4,-36(s0)
    8000550c:	01a70793          	addi	a5,a4,26
    80005510:	078e                	slli	a5,a5,0x3
    80005512:	953e                	add	a0,a0,a5
    80005514:	611c                	ld	a5,0(a0)
    80005516:	c385                	beqz	a5,80005536 <argfd+0x54>
    return -1;
  if(pfd)
    80005518:	00090463          	beqz	s2,80005520 <argfd+0x3e>
    *pfd = fd;
    8000551c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005520:	4501                	li	a0,0
  if(pf)
    80005522:	c091                	beqz	s1,80005526 <argfd+0x44>
    *pf = f;
    80005524:	e09c                	sd	a5,0(s1)
}
    80005526:	70a2                	ld	ra,40(sp)
    80005528:	7402                	ld	s0,32(sp)
    8000552a:	64e2                	ld	s1,24(sp)
    8000552c:	6942                	ld	s2,16(sp)
    8000552e:	6145                	addi	sp,sp,48
    80005530:	8082                	ret
    return -1;
    80005532:	557d                	li	a0,-1
    80005534:	bfcd                	j	80005526 <argfd+0x44>
    80005536:	557d                	li	a0,-1
    80005538:	b7fd                	j	80005526 <argfd+0x44>

000000008000553a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000553a:	1101                	addi	sp,sp,-32
    8000553c:	ec06                	sd	ra,24(sp)
    8000553e:	e822                	sd	s0,16(sp)
    80005540:	e426                	sd	s1,8(sp)
    80005542:	1000                	addi	s0,sp,32
    80005544:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005546:	e02fc0ef          	jal	ra,80001b48 <myproc>
    8000554a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000554c:	0d050793          	addi	a5,a0,208
    80005550:	4501                	li	a0,0
    80005552:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005554:	6398                	ld	a4,0(a5)
    80005556:	cb19                	beqz	a4,8000556c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005558:	2505                	addiw	a0,a0,1
    8000555a:	07a1                	addi	a5,a5,8
    8000555c:	fed51ce3          	bne	a0,a3,80005554 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005560:	557d                	li	a0,-1
}
    80005562:	60e2                	ld	ra,24(sp)
    80005564:	6442                	ld	s0,16(sp)
    80005566:	64a2                	ld	s1,8(sp)
    80005568:	6105                	addi	sp,sp,32
    8000556a:	8082                	ret
      p->ofile[fd] = f;
    8000556c:	01a50793          	addi	a5,a0,26
    80005570:	078e                	slli	a5,a5,0x3
    80005572:	963e                	add	a2,a2,a5
    80005574:	e204                	sd	s1,0(a2)
      return fd;
    80005576:	b7f5                	j	80005562 <fdalloc+0x28>

0000000080005578 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005578:	715d                	addi	sp,sp,-80
    8000557a:	e486                	sd	ra,72(sp)
    8000557c:	e0a2                	sd	s0,64(sp)
    8000557e:	fc26                	sd	s1,56(sp)
    80005580:	f84a                	sd	s2,48(sp)
    80005582:	f44e                	sd	s3,40(sp)
    80005584:	f052                	sd	s4,32(sp)
    80005586:	ec56                	sd	s5,24(sp)
    80005588:	e85a                	sd	s6,16(sp)
    8000558a:	0880                	addi	s0,sp,80
    8000558c:	8b2e                	mv	s6,a1
    8000558e:	89b2                	mv	s3,a2
    80005590:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005592:	fb040593          	addi	a1,s0,-80
    80005596:	812ff0ef          	jal	ra,800045a8 <nameiparent>
    8000559a:	84aa                	mv	s1,a0
    8000559c:	10050b63          	beqz	a0,800056b2 <create+0x13a>
    return 0;

  ilock(dp);
    800055a0:	ffafe0ef          	jal	ra,80003d9a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055a4:	4601                	li	a2,0
    800055a6:	fb040593          	addi	a1,s0,-80
    800055aa:	8526                	mv	a0,s1
    800055ac:	d77fe0ef          	jal	ra,80004322 <dirlookup>
    800055b0:	8aaa                	mv	s5,a0
    800055b2:	c521                	beqz	a0,800055fa <create+0x82>
    iunlockput(dp);
    800055b4:	8526                	mv	a0,s1
    800055b6:	9ebfe0ef          	jal	ra,80003fa0 <iunlockput>
    ilock(ip);
    800055ba:	8556                	mv	a0,s5
    800055bc:	fdefe0ef          	jal	ra,80003d9a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055c0:	000b059b          	sext.w	a1,s6
    800055c4:	4789                	li	a5,2
    800055c6:	02f59563          	bne	a1,a5,800055f0 <create+0x78>
    800055ca:	044ad783          	lhu	a5,68(s5)
    800055ce:	37f9                	addiw	a5,a5,-2
    800055d0:	17c2                	slli	a5,a5,0x30
    800055d2:	93c1                	srli	a5,a5,0x30
    800055d4:	4705                	li	a4,1
    800055d6:	00f76d63          	bltu	a4,a5,800055f0 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055da:	8556                	mv	a0,s5
    800055dc:	60a6                	ld	ra,72(sp)
    800055de:	6406                	ld	s0,64(sp)
    800055e0:	74e2                	ld	s1,56(sp)
    800055e2:	7942                	ld	s2,48(sp)
    800055e4:	79a2                	ld	s3,40(sp)
    800055e6:	7a02                	ld	s4,32(sp)
    800055e8:	6ae2                	ld	s5,24(sp)
    800055ea:	6b42                	ld	s6,16(sp)
    800055ec:	6161                	addi	sp,sp,80
    800055ee:	8082                	ret
    iunlockput(ip);
    800055f0:	8556                	mv	a0,s5
    800055f2:	9affe0ef          	jal	ra,80003fa0 <iunlockput>
    return 0;
    800055f6:	4a81                	li	s5,0
    800055f8:	b7cd                	j	800055da <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055fa:	85da                	mv	a1,s6
    800055fc:	4088                	lw	a0,0(s1)
    800055fe:	e32fe0ef          	jal	ra,80003c30 <ialloc>
    80005602:	8a2a                	mv	s4,a0
    80005604:	cd1d                	beqz	a0,80005642 <create+0xca>
  ilock(ip);
    80005606:	f94fe0ef          	jal	ra,80003d9a <ilock>
  ip->major = major;
    8000560a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000560e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005612:	4905                	li	s2,1
    80005614:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005618:	8552                	mv	a0,s4
    8000561a:	eccfe0ef          	jal	ra,80003ce6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000561e:	000b059b          	sext.w	a1,s6
    80005622:	03258563          	beq	a1,s2,8000564c <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80005626:	004a2603          	lw	a2,4(s4)
    8000562a:	fb040593          	addi	a1,s0,-80
    8000562e:	8526                	mv	a0,s1
    80005630:	ec5fe0ef          	jal	ra,800044f4 <dirlink>
    80005634:	06054363          	bltz	a0,8000569a <create+0x122>
  iunlockput(dp);
    80005638:	8526                	mv	a0,s1
    8000563a:	967fe0ef          	jal	ra,80003fa0 <iunlockput>
  return ip;
    8000563e:	8ad2                	mv	s5,s4
    80005640:	bf69                	j	800055da <create+0x62>
    iunlockput(dp);
    80005642:	8526                	mv	a0,s1
    80005644:	95dfe0ef          	jal	ra,80003fa0 <iunlockput>
    return 0;
    80005648:	8ad2                	mv	s5,s4
    8000564a:	bf41                	j	800055da <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000564c:	004a2603          	lw	a2,4(s4)
    80005650:	00003597          	auipc	a1,0x3
    80005654:	0a858593          	addi	a1,a1,168 # 800086f8 <syscalls+0x300>
    80005658:	8552                	mv	a0,s4
    8000565a:	e9bfe0ef          	jal	ra,800044f4 <dirlink>
    8000565e:	02054e63          	bltz	a0,8000569a <create+0x122>
    80005662:	40d0                	lw	a2,4(s1)
    80005664:	00003597          	auipc	a1,0x3
    80005668:	09c58593          	addi	a1,a1,156 # 80008700 <syscalls+0x308>
    8000566c:	8552                	mv	a0,s4
    8000566e:	e87fe0ef          	jal	ra,800044f4 <dirlink>
    80005672:	02054463          	bltz	a0,8000569a <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80005676:	004a2603          	lw	a2,4(s4)
    8000567a:	fb040593          	addi	a1,s0,-80
    8000567e:	8526                	mv	a0,s1
    80005680:	e75fe0ef          	jal	ra,800044f4 <dirlink>
    80005684:	00054b63          	bltz	a0,8000569a <create+0x122>
    dp->nlink++;  // for ".."
    80005688:	04a4d783          	lhu	a5,74(s1)
    8000568c:	2785                	addiw	a5,a5,1
    8000568e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005692:	8526                	mv	a0,s1
    80005694:	e52fe0ef          	jal	ra,80003ce6 <iupdate>
    80005698:	b745                	j	80005638 <create+0xc0>
  ip->nlink = 0;
    8000569a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000569e:	8552                	mv	a0,s4
    800056a0:	e46fe0ef          	jal	ra,80003ce6 <iupdate>
  iunlockput(ip);
    800056a4:	8552                	mv	a0,s4
    800056a6:	8fbfe0ef          	jal	ra,80003fa0 <iunlockput>
  iunlockput(dp);
    800056aa:	8526                	mv	a0,s1
    800056ac:	8f5fe0ef          	jal	ra,80003fa0 <iunlockput>
  return 0;
    800056b0:	b72d                	j	800055da <create+0x62>
    return 0;
    800056b2:	8aaa                	mv	s5,a0
    800056b4:	b71d                	j	800055da <create+0x62>

00000000800056b6 <sys_dup>:
{
    800056b6:	7179                	addi	sp,sp,-48
    800056b8:	f406                	sd	ra,40(sp)
    800056ba:	f022                	sd	s0,32(sp)
    800056bc:	ec26                	sd	s1,24(sp)
    800056be:	e84a                	sd	s2,16(sp)
    800056c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056c2:	fd840613          	addi	a2,s0,-40
    800056c6:	4581                	li	a1,0
    800056c8:	4501                	li	a0,0
    800056ca:	e19ff0ef          	jal	ra,800054e2 <argfd>
    return -1;
    800056ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056d0:	00054f63          	bltz	a0,800056ee <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    800056d4:	fd843903          	ld	s2,-40(s0)
    800056d8:	854a                	mv	a0,s2
    800056da:	e61ff0ef          	jal	ra,8000553a <fdalloc>
    800056de:	84aa                	mv	s1,a0
    return -1;
    800056e0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056e2:	00054663          	bltz	a0,800056ee <sys_dup+0x38>
  filedup(f);
    800056e6:	854a                	mv	a0,s2
    800056e8:	c5eff0ef          	jal	ra,80004b46 <filedup>
  return fd;
    800056ec:	87a6                	mv	a5,s1
}
    800056ee:	853e                	mv	a0,a5
    800056f0:	70a2                	ld	ra,40(sp)
    800056f2:	7402                	ld	s0,32(sp)
    800056f4:	64e2                	ld	s1,24(sp)
    800056f6:	6942                	ld	s2,16(sp)
    800056f8:	6145                	addi	sp,sp,48
    800056fa:	8082                	ret

00000000800056fc <sys_read>:
{
    800056fc:	7179                	addi	sp,sp,-48
    800056fe:	f406                	sd	ra,40(sp)
    80005700:	f022                	sd	s0,32(sp)
    80005702:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005704:	fd840593          	addi	a1,s0,-40
    80005708:	4505                	li	a0,1
    8000570a:	e38fd0ef          	jal	ra,80002d42 <argaddr>
  argint(2, &n);
    8000570e:	fe440593          	addi	a1,s0,-28
    80005712:	4509                	li	a0,2
    80005714:	e12fd0ef          	jal	ra,80002d26 <argint>
  if(argfd(0, 0, &f) < 0)
    80005718:	fe840613          	addi	a2,s0,-24
    8000571c:	4581                	li	a1,0
    8000571e:	4501                	li	a0,0
    80005720:	dc3ff0ef          	jal	ra,800054e2 <argfd>
    80005724:	87aa                	mv	a5,a0
    return -1;
    80005726:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005728:	0007ca63          	bltz	a5,8000573c <sys_read+0x40>
  return fileread(f, p, n);
    8000572c:	fe442603          	lw	a2,-28(s0)
    80005730:	fd843583          	ld	a1,-40(s0)
    80005734:	fe843503          	ld	a0,-24(s0)
    80005738:	d5aff0ef          	jal	ra,80004c92 <fileread>
}
    8000573c:	70a2                	ld	ra,40(sp)
    8000573e:	7402                	ld	s0,32(sp)
    80005740:	6145                	addi	sp,sp,48
    80005742:	8082                	ret

0000000080005744 <sys_write>:
{
    80005744:	7179                	addi	sp,sp,-48
    80005746:	f406                	sd	ra,40(sp)
    80005748:	f022                	sd	s0,32(sp)
    8000574a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000574c:	fd840593          	addi	a1,s0,-40
    80005750:	4505                	li	a0,1
    80005752:	df0fd0ef          	jal	ra,80002d42 <argaddr>
  argint(2, &n);
    80005756:	fe440593          	addi	a1,s0,-28
    8000575a:	4509                	li	a0,2
    8000575c:	dcafd0ef          	jal	ra,80002d26 <argint>
  if(argfd(0, 0, &f) < 0)
    80005760:	fe840613          	addi	a2,s0,-24
    80005764:	4581                	li	a1,0
    80005766:	4501                	li	a0,0
    80005768:	d7bff0ef          	jal	ra,800054e2 <argfd>
    8000576c:	87aa                	mv	a5,a0
    return -1;
    8000576e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005770:	0007ca63          	bltz	a5,80005784 <sys_write+0x40>
  return filewrite(f, p, n);
    80005774:	fe442603          	lw	a2,-28(s0)
    80005778:	fd843583          	ld	a1,-40(s0)
    8000577c:	fe843503          	ld	a0,-24(s0)
    80005780:	dc0ff0ef          	jal	ra,80004d40 <filewrite>
}
    80005784:	70a2                	ld	ra,40(sp)
    80005786:	7402                	ld	s0,32(sp)
    80005788:	6145                	addi	sp,sp,48
    8000578a:	8082                	ret

000000008000578c <sys_close>:
{
    8000578c:	1101                	addi	sp,sp,-32
    8000578e:	ec06                	sd	ra,24(sp)
    80005790:	e822                	sd	s0,16(sp)
    80005792:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005794:	fe040613          	addi	a2,s0,-32
    80005798:	fec40593          	addi	a1,s0,-20
    8000579c:	4501                	li	a0,0
    8000579e:	d45ff0ef          	jal	ra,800054e2 <argfd>
    return -1;
    800057a2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057a4:	02054063          	bltz	a0,800057c4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800057a8:	ba0fc0ef          	jal	ra,80001b48 <myproc>
    800057ac:	fec42783          	lw	a5,-20(s0)
    800057b0:	07e9                	addi	a5,a5,26
    800057b2:	078e                	slli	a5,a5,0x3
    800057b4:	953e                	add	a0,a0,a5
    800057b6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800057ba:	fe043503          	ld	a0,-32(s0)
    800057be:	bceff0ef          	jal	ra,80004b8c <fileclose>
  return 0;
    800057c2:	4781                	li	a5,0
}
    800057c4:	853e                	mv	a0,a5
    800057c6:	60e2                	ld	ra,24(sp)
    800057c8:	6442                	ld	s0,16(sp)
    800057ca:	6105                	addi	sp,sp,32
    800057cc:	8082                	ret

00000000800057ce <sys_fstat>:
{
    800057ce:	1101                	addi	sp,sp,-32
    800057d0:	ec06                	sd	ra,24(sp)
    800057d2:	e822                	sd	s0,16(sp)
    800057d4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057d6:	fe040593          	addi	a1,s0,-32
    800057da:	4505                	li	a0,1
    800057dc:	d66fd0ef          	jal	ra,80002d42 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057e0:	fe840613          	addi	a2,s0,-24
    800057e4:	4581                	li	a1,0
    800057e6:	4501                	li	a0,0
    800057e8:	cfbff0ef          	jal	ra,800054e2 <argfd>
    800057ec:	87aa                	mv	a5,a0
    return -1;
    800057ee:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057f0:	0007c863          	bltz	a5,80005800 <sys_fstat+0x32>
  return filestat(f, st);
    800057f4:	fe043583          	ld	a1,-32(s0)
    800057f8:	fe843503          	ld	a0,-24(s0)
    800057fc:	c38ff0ef          	jal	ra,80004c34 <filestat>
}
    80005800:	60e2                	ld	ra,24(sp)
    80005802:	6442                	ld	s0,16(sp)
    80005804:	6105                	addi	sp,sp,32
    80005806:	8082                	ret

0000000080005808 <sys_link>:
{
    80005808:	7169                	addi	sp,sp,-304
    8000580a:	f606                	sd	ra,296(sp)
    8000580c:	f222                	sd	s0,288(sp)
    8000580e:	ee26                	sd	s1,280(sp)
    80005810:	ea4a                	sd	s2,272(sp)
    80005812:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005814:	08000613          	li	a2,128
    80005818:	ed040593          	addi	a1,s0,-304
    8000581c:	4501                	li	a0,0
    8000581e:	d40fd0ef          	jal	ra,80002d5e <argstr>
    return -1;
    80005822:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005824:	0c054663          	bltz	a0,800058f0 <sys_link+0xe8>
    80005828:	08000613          	li	a2,128
    8000582c:	f5040593          	addi	a1,s0,-176
    80005830:	4505                	li	a0,1
    80005832:	d2cfd0ef          	jal	ra,80002d5e <argstr>
    return -1;
    80005836:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005838:	0a054c63          	bltz	a0,800058f0 <sys_link+0xe8>
  begin_op();
    8000583c:	f47fe0ef          	jal	ra,80004782 <begin_op>
  if((ip = namei(old)) == 0){
    80005840:	ed040513          	addi	a0,s0,-304
    80005844:	d4bfe0ef          	jal	ra,8000458e <namei>
    80005848:	84aa                	mv	s1,a0
    8000584a:	c525                	beqz	a0,800058b2 <sys_link+0xaa>
  ilock(ip);
    8000584c:	d4efe0ef          	jal	ra,80003d9a <ilock>
  if(ip->type == T_DIR){
    80005850:	04449703          	lh	a4,68(s1)
    80005854:	4785                	li	a5,1
    80005856:	06f70263          	beq	a4,a5,800058ba <sys_link+0xb2>
  ip->nlink++;
    8000585a:	04a4d783          	lhu	a5,74(s1)
    8000585e:	2785                	addiw	a5,a5,1
    80005860:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005864:	8526                	mv	a0,s1
    80005866:	c80fe0ef          	jal	ra,80003ce6 <iupdate>
  iunlock(ip);
    8000586a:	8526                	mv	a0,s1
    8000586c:	dd8fe0ef          	jal	ra,80003e44 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005870:	fd040593          	addi	a1,s0,-48
    80005874:	f5040513          	addi	a0,s0,-176
    80005878:	d31fe0ef          	jal	ra,800045a8 <nameiparent>
    8000587c:	892a                	mv	s2,a0
    8000587e:	c921                	beqz	a0,800058ce <sys_link+0xc6>
  ilock(dp);
    80005880:	d1afe0ef          	jal	ra,80003d9a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005884:	00092703          	lw	a4,0(s2)
    80005888:	409c                	lw	a5,0(s1)
    8000588a:	02f71f63          	bne	a4,a5,800058c8 <sys_link+0xc0>
    8000588e:	40d0                	lw	a2,4(s1)
    80005890:	fd040593          	addi	a1,s0,-48
    80005894:	854a                	mv	a0,s2
    80005896:	c5ffe0ef          	jal	ra,800044f4 <dirlink>
    8000589a:	02054763          	bltz	a0,800058c8 <sys_link+0xc0>
  iunlockput(dp);
    8000589e:	854a                	mv	a0,s2
    800058a0:	f00fe0ef          	jal	ra,80003fa0 <iunlockput>
  iput(ip);
    800058a4:	8526                	mv	a0,s1
    800058a6:	e72fe0ef          	jal	ra,80003f18 <iput>
  end_op();
    800058aa:	f47fe0ef          	jal	ra,800047f0 <end_op>
  return 0;
    800058ae:	4781                	li	a5,0
    800058b0:	a081                	j	800058f0 <sys_link+0xe8>
    end_op();
    800058b2:	f3ffe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    800058b6:	57fd                	li	a5,-1
    800058b8:	a825                	j	800058f0 <sys_link+0xe8>
    iunlockput(ip);
    800058ba:	8526                	mv	a0,s1
    800058bc:	ee4fe0ef          	jal	ra,80003fa0 <iunlockput>
    end_op();
    800058c0:	f31fe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    800058c4:	57fd                	li	a5,-1
    800058c6:	a02d                	j	800058f0 <sys_link+0xe8>
    iunlockput(dp);
    800058c8:	854a                	mv	a0,s2
    800058ca:	ed6fe0ef          	jal	ra,80003fa0 <iunlockput>
  ilock(ip);
    800058ce:	8526                	mv	a0,s1
    800058d0:	ccafe0ef          	jal	ra,80003d9a <ilock>
  ip->nlink--;
    800058d4:	04a4d783          	lhu	a5,74(s1)
    800058d8:	37fd                	addiw	a5,a5,-1
    800058da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058de:	8526                	mv	a0,s1
    800058e0:	c06fe0ef          	jal	ra,80003ce6 <iupdate>
  iunlockput(ip);
    800058e4:	8526                	mv	a0,s1
    800058e6:	ebafe0ef          	jal	ra,80003fa0 <iunlockput>
  end_op();
    800058ea:	f07fe0ef          	jal	ra,800047f0 <end_op>
  return -1;
    800058ee:	57fd                	li	a5,-1
}
    800058f0:	853e                	mv	a0,a5
    800058f2:	70b2                	ld	ra,296(sp)
    800058f4:	7412                	ld	s0,288(sp)
    800058f6:	64f2                	ld	s1,280(sp)
    800058f8:	6952                	ld	s2,272(sp)
    800058fa:	6155                	addi	sp,sp,304
    800058fc:	8082                	ret

00000000800058fe <sys_unlink>:
{
    800058fe:	7151                	addi	sp,sp,-240
    80005900:	f586                	sd	ra,232(sp)
    80005902:	f1a2                	sd	s0,224(sp)
    80005904:	eda6                	sd	s1,216(sp)
    80005906:	e9ca                	sd	s2,208(sp)
    80005908:	e5ce                	sd	s3,200(sp)
    8000590a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000590c:	08000613          	li	a2,128
    80005910:	f3040593          	addi	a1,s0,-208
    80005914:	4501                	li	a0,0
    80005916:	c48fd0ef          	jal	ra,80002d5e <argstr>
    8000591a:	12054b63          	bltz	a0,80005a50 <sys_unlink+0x152>
  begin_op();
    8000591e:	e65fe0ef          	jal	ra,80004782 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005922:	fb040593          	addi	a1,s0,-80
    80005926:	f3040513          	addi	a0,s0,-208
    8000592a:	c7ffe0ef          	jal	ra,800045a8 <nameiparent>
    8000592e:	84aa                	mv	s1,a0
    80005930:	c54d                	beqz	a0,800059da <sys_unlink+0xdc>
  ilock(dp);
    80005932:	c68fe0ef          	jal	ra,80003d9a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005936:	00003597          	auipc	a1,0x3
    8000593a:	dc258593          	addi	a1,a1,-574 # 800086f8 <syscalls+0x300>
    8000593e:	fb040513          	addi	a0,s0,-80
    80005942:	9cbfe0ef          	jal	ra,8000430c <namecmp>
    80005946:	10050a63          	beqz	a0,80005a5a <sys_unlink+0x15c>
    8000594a:	00003597          	auipc	a1,0x3
    8000594e:	db658593          	addi	a1,a1,-586 # 80008700 <syscalls+0x308>
    80005952:	fb040513          	addi	a0,s0,-80
    80005956:	9b7fe0ef          	jal	ra,8000430c <namecmp>
    8000595a:	10050063          	beqz	a0,80005a5a <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000595e:	f2c40613          	addi	a2,s0,-212
    80005962:	fb040593          	addi	a1,s0,-80
    80005966:	8526                	mv	a0,s1
    80005968:	9bbfe0ef          	jal	ra,80004322 <dirlookup>
    8000596c:	892a                	mv	s2,a0
    8000596e:	0e050663          	beqz	a0,80005a5a <sys_unlink+0x15c>
  ilock(ip);
    80005972:	c28fe0ef          	jal	ra,80003d9a <ilock>
  if(ip->nlink < 1)
    80005976:	04a91783          	lh	a5,74(s2)
    8000597a:	06f05463          	blez	a5,800059e2 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000597e:	04491703          	lh	a4,68(s2)
    80005982:	4785                	li	a5,1
    80005984:	06f70563          	beq	a4,a5,800059ee <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80005988:	4641                	li	a2,16
    8000598a:	4581                	li	a1,0
    8000598c:	fc040513          	addi	a0,s0,-64
    80005990:	be4fb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005994:	4741                	li	a4,16
    80005996:	f2c42683          	lw	a3,-212(s0)
    8000599a:	fc040613          	addi	a2,s0,-64
    8000599e:	4581                	li	a1,0
    800059a0:	8526                	mv	a0,s1
    800059a2:	869fe0ef          	jal	ra,8000420a <writei>
    800059a6:	47c1                	li	a5,16
    800059a8:	08f51563          	bne	a0,a5,80005a32 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800059ac:	04491703          	lh	a4,68(s2)
    800059b0:	4785                	li	a5,1
    800059b2:	08f70663          	beq	a4,a5,80005a3e <sys_unlink+0x140>
  iunlockput(dp);
    800059b6:	8526                	mv	a0,s1
    800059b8:	de8fe0ef          	jal	ra,80003fa0 <iunlockput>
  ip->nlink--;
    800059bc:	04a95783          	lhu	a5,74(s2)
    800059c0:	37fd                	addiw	a5,a5,-1
    800059c2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059c6:	854a                	mv	a0,s2
    800059c8:	b1efe0ef          	jal	ra,80003ce6 <iupdate>
  iunlockput(ip);
    800059cc:	854a                	mv	a0,s2
    800059ce:	dd2fe0ef          	jal	ra,80003fa0 <iunlockput>
  end_op();
    800059d2:	e1ffe0ef          	jal	ra,800047f0 <end_op>
  return 0;
    800059d6:	4501                	li	a0,0
    800059d8:	a079                	j	80005a66 <sys_unlink+0x168>
    end_op();
    800059da:	e17fe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    800059de:	557d                	li	a0,-1
    800059e0:	a059                	j	80005a66 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800059e2:	00003517          	auipc	a0,0x3
    800059e6:	d2650513          	addi	a0,a0,-730 # 80008708 <syscalls+0x310>
    800059ea:	d9ffa0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059ee:	04c92703          	lw	a4,76(s2)
    800059f2:	02000793          	li	a5,32
    800059f6:	f8e7f9e3          	bgeu	a5,a4,80005988 <sys_unlink+0x8a>
    800059fa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059fe:	4741                	li	a4,16
    80005a00:	86ce                	mv	a3,s3
    80005a02:	f1840613          	addi	a2,s0,-232
    80005a06:	4581                	li	a1,0
    80005a08:	854a                	mv	a0,s2
    80005a0a:	f1cfe0ef          	jal	ra,80004126 <readi>
    80005a0e:	47c1                	li	a5,16
    80005a10:	00f51b63          	bne	a0,a5,80005a26 <sys_unlink+0x128>
    if(de.inum != 0)
    80005a14:	f1845783          	lhu	a5,-232(s0)
    80005a18:	ef95                	bnez	a5,80005a54 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a1a:	29c1                	addiw	s3,s3,16
    80005a1c:	04c92783          	lw	a5,76(s2)
    80005a20:	fcf9efe3          	bltu	s3,a5,800059fe <sys_unlink+0x100>
    80005a24:	b795                	j	80005988 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005a26:	00003517          	auipc	a0,0x3
    80005a2a:	cfa50513          	addi	a0,a0,-774 # 80008720 <syscalls+0x328>
    80005a2e:	d5bfa0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80005a32:	00003517          	auipc	a0,0x3
    80005a36:	d0650513          	addi	a0,a0,-762 # 80008738 <syscalls+0x340>
    80005a3a:	d4ffa0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005a3e:	04a4d783          	lhu	a5,74(s1)
    80005a42:	37fd                	addiw	a5,a5,-1
    80005a44:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	a9cfe0ef          	jal	ra,80003ce6 <iupdate>
    80005a4e:	b7a5                	j	800059b6 <sys_unlink+0xb8>
    return -1;
    80005a50:	557d                	li	a0,-1
    80005a52:	a811                	j	80005a66 <sys_unlink+0x168>
    iunlockput(ip);
    80005a54:	854a                	mv	a0,s2
    80005a56:	d4afe0ef          	jal	ra,80003fa0 <iunlockput>
  iunlockput(dp);
    80005a5a:	8526                	mv	a0,s1
    80005a5c:	d44fe0ef          	jal	ra,80003fa0 <iunlockput>
  end_op();
    80005a60:	d91fe0ef          	jal	ra,800047f0 <end_op>
  return -1;
    80005a64:	557d                	li	a0,-1
}
    80005a66:	70ae                	ld	ra,232(sp)
    80005a68:	740e                	ld	s0,224(sp)
    80005a6a:	64ee                	ld	s1,216(sp)
    80005a6c:	694e                	ld	s2,208(sp)
    80005a6e:	69ae                	ld	s3,200(sp)
    80005a70:	616d                	addi	sp,sp,240
    80005a72:	8082                	ret

0000000080005a74 <sys_open>:

uint64
sys_open(void)
{
    80005a74:	7131                	addi	sp,sp,-192
    80005a76:	fd06                	sd	ra,184(sp)
    80005a78:	f922                	sd	s0,176(sp)
    80005a7a:	f526                	sd	s1,168(sp)
    80005a7c:	f14a                	sd	s2,160(sp)
    80005a7e:	ed4e                	sd	s3,152(sp)
    80005a80:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a82:	f4c40593          	addi	a1,s0,-180
    80005a86:	4505                	li	a0,1
    80005a88:	a9efd0ef          	jal	ra,80002d26 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a8c:	08000613          	li	a2,128
    80005a90:	f5040593          	addi	a1,s0,-176
    80005a94:	4501                	li	a0,0
    80005a96:	ac8fd0ef          	jal	ra,80002d5e <argstr>
    80005a9a:	87aa                	mv	a5,a0
    return -1;
    80005a9c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a9e:	0807cd63          	bltz	a5,80005b38 <sys_open+0xc4>

  begin_op();
    80005aa2:	ce1fe0ef          	jal	ra,80004782 <begin_op>

  if(omode & O_CREATE){
    80005aa6:	f4c42783          	lw	a5,-180(s0)
    80005aaa:	2007f793          	andi	a5,a5,512
    80005aae:	c3c5                	beqz	a5,80005b4e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005ab0:	4681                	li	a3,0
    80005ab2:	4601                	li	a2,0
    80005ab4:	4589                	li	a1,2
    80005ab6:	f5040513          	addi	a0,s0,-176
    80005aba:	abfff0ef          	jal	ra,80005578 <create>
    80005abe:	84aa                	mv	s1,a0
    if(ip == 0){
    80005ac0:	c159                	beqz	a0,80005b46 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ac2:	04449703          	lh	a4,68(s1)
    80005ac6:	478d                	li	a5,3
    80005ac8:	00f71763          	bne	a4,a5,80005ad6 <sys_open+0x62>
    80005acc:	0464d703          	lhu	a4,70(s1)
    80005ad0:	47a5                	li	a5,9
    80005ad2:	0ae7e963          	bltu	a5,a4,80005b84 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ad6:	812ff0ef          	jal	ra,80004ae8 <filealloc>
    80005ada:	89aa                	mv	s3,a0
    80005adc:	0c050963          	beqz	a0,80005bae <sys_open+0x13a>
    80005ae0:	a5bff0ef          	jal	ra,8000553a <fdalloc>
    80005ae4:	892a                	mv	s2,a0
    80005ae6:	0c054163          	bltz	a0,80005ba8 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005aea:	04449703          	lh	a4,68(s1)
    80005aee:	478d                	li	a5,3
    80005af0:	0af70163          	beq	a4,a5,80005b92 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005af4:	4789                	li	a5,2
    80005af6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005afa:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005afe:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b02:	f4c42783          	lw	a5,-180(s0)
    80005b06:	0017c713          	xori	a4,a5,1
    80005b0a:	8b05                	andi	a4,a4,1
    80005b0c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b10:	0037f713          	andi	a4,a5,3
    80005b14:	00e03733          	snez	a4,a4
    80005b18:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b1c:	4007f793          	andi	a5,a5,1024
    80005b20:	c791                	beqz	a5,80005b2c <sys_open+0xb8>
    80005b22:	04449703          	lh	a4,68(s1)
    80005b26:	4789                	li	a5,2
    80005b28:	06f70c63          	beq	a4,a5,80005ba0 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b2c:	8526                	mv	a0,s1
    80005b2e:	b16fe0ef          	jal	ra,80003e44 <iunlock>
  end_op();
    80005b32:	cbffe0ef          	jal	ra,800047f0 <end_op>

  return fd;
    80005b36:	854a                	mv	a0,s2
}
    80005b38:	70ea                	ld	ra,184(sp)
    80005b3a:	744a                	ld	s0,176(sp)
    80005b3c:	74aa                	ld	s1,168(sp)
    80005b3e:	790a                	ld	s2,160(sp)
    80005b40:	69ea                	ld	s3,152(sp)
    80005b42:	6129                	addi	sp,sp,192
    80005b44:	8082                	ret
      end_op();
    80005b46:	cabfe0ef          	jal	ra,800047f0 <end_op>
      return -1;
    80005b4a:	557d                	li	a0,-1
    80005b4c:	b7f5                	j	80005b38 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005b4e:	f5040513          	addi	a0,s0,-176
    80005b52:	a3dfe0ef          	jal	ra,8000458e <namei>
    80005b56:	84aa                	mv	s1,a0
    80005b58:	c115                	beqz	a0,80005b7c <sys_open+0x108>
    ilock(ip);
    80005b5a:	a40fe0ef          	jal	ra,80003d9a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b5e:	04449703          	lh	a4,68(s1)
    80005b62:	4785                	li	a5,1
    80005b64:	f4f71fe3          	bne	a4,a5,80005ac2 <sys_open+0x4e>
    80005b68:	f4c42783          	lw	a5,-180(s0)
    80005b6c:	d7ad                	beqz	a5,80005ad6 <sys_open+0x62>
      iunlockput(ip);
    80005b6e:	8526                	mv	a0,s1
    80005b70:	c30fe0ef          	jal	ra,80003fa0 <iunlockput>
      end_op();
    80005b74:	c7dfe0ef          	jal	ra,800047f0 <end_op>
      return -1;
    80005b78:	557d                	li	a0,-1
    80005b7a:	bf7d                	j	80005b38 <sys_open+0xc4>
      end_op();
    80005b7c:	c75fe0ef          	jal	ra,800047f0 <end_op>
      return -1;
    80005b80:	557d                	li	a0,-1
    80005b82:	bf5d                	j	80005b38 <sys_open+0xc4>
    iunlockput(ip);
    80005b84:	8526                	mv	a0,s1
    80005b86:	c1afe0ef          	jal	ra,80003fa0 <iunlockput>
    end_op();
    80005b8a:	c67fe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    80005b8e:	557d                	li	a0,-1
    80005b90:	b765                	j	80005b38 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005b92:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b96:	04649783          	lh	a5,70(s1)
    80005b9a:	02f99223          	sh	a5,36(s3)
    80005b9e:	b785                	j	80005afe <sys_open+0x8a>
    itrunc(ip);
    80005ba0:	8526                	mv	a0,s1
    80005ba2:	ae2fe0ef          	jal	ra,80003e84 <itrunc>
    80005ba6:	b759                	j	80005b2c <sys_open+0xb8>
      fileclose(f);
    80005ba8:	854e                	mv	a0,s3
    80005baa:	fe3fe0ef          	jal	ra,80004b8c <fileclose>
    iunlockput(ip);
    80005bae:	8526                	mv	a0,s1
    80005bb0:	bf0fe0ef          	jal	ra,80003fa0 <iunlockput>
    end_op();
    80005bb4:	c3dfe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    80005bb8:	557d                	li	a0,-1
    80005bba:	bfbd                	j	80005b38 <sys_open+0xc4>

0000000080005bbc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bbc:	7175                	addi	sp,sp,-144
    80005bbe:	e506                	sd	ra,136(sp)
    80005bc0:	e122                	sd	s0,128(sp)
    80005bc2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bc4:	bbffe0ef          	jal	ra,80004782 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bc8:	08000613          	li	a2,128
    80005bcc:	f7040593          	addi	a1,s0,-144
    80005bd0:	4501                	li	a0,0
    80005bd2:	98cfd0ef          	jal	ra,80002d5e <argstr>
    80005bd6:	02054363          	bltz	a0,80005bfc <sys_mkdir+0x40>
    80005bda:	4681                	li	a3,0
    80005bdc:	4601                	li	a2,0
    80005bde:	4585                	li	a1,1
    80005be0:	f7040513          	addi	a0,s0,-144
    80005be4:	995ff0ef          	jal	ra,80005578 <create>
    80005be8:	c911                	beqz	a0,80005bfc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bea:	bb6fe0ef          	jal	ra,80003fa0 <iunlockput>
  end_op();
    80005bee:	c03fe0ef          	jal	ra,800047f0 <end_op>
  return 0;
    80005bf2:	4501                	li	a0,0
}
    80005bf4:	60aa                	ld	ra,136(sp)
    80005bf6:	640a                	ld	s0,128(sp)
    80005bf8:	6149                	addi	sp,sp,144
    80005bfa:	8082                	ret
    end_op();
    80005bfc:	bf5fe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    80005c00:	557d                	li	a0,-1
    80005c02:	bfcd                	j	80005bf4 <sys_mkdir+0x38>

0000000080005c04 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c04:	7135                	addi	sp,sp,-160
    80005c06:	ed06                	sd	ra,152(sp)
    80005c08:	e922                	sd	s0,144(sp)
    80005c0a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c0c:	b77fe0ef          	jal	ra,80004782 <begin_op>
  argint(1, &major);
    80005c10:	f6c40593          	addi	a1,s0,-148
    80005c14:	4505                	li	a0,1
    80005c16:	910fd0ef          	jal	ra,80002d26 <argint>
  argint(2, &minor);
    80005c1a:	f6840593          	addi	a1,s0,-152
    80005c1e:	4509                	li	a0,2
    80005c20:	906fd0ef          	jal	ra,80002d26 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c24:	08000613          	li	a2,128
    80005c28:	f7040593          	addi	a1,s0,-144
    80005c2c:	4501                	li	a0,0
    80005c2e:	930fd0ef          	jal	ra,80002d5e <argstr>
    80005c32:	02054563          	bltz	a0,80005c5c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c36:	f6841683          	lh	a3,-152(s0)
    80005c3a:	f6c41603          	lh	a2,-148(s0)
    80005c3e:	458d                	li	a1,3
    80005c40:	f7040513          	addi	a0,s0,-144
    80005c44:	935ff0ef          	jal	ra,80005578 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c48:	c911                	beqz	a0,80005c5c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c4a:	b56fe0ef          	jal	ra,80003fa0 <iunlockput>
  end_op();
    80005c4e:	ba3fe0ef          	jal	ra,800047f0 <end_op>
  return 0;
    80005c52:	4501                	li	a0,0
}
    80005c54:	60ea                	ld	ra,152(sp)
    80005c56:	644a                	ld	s0,144(sp)
    80005c58:	610d                	addi	sp,sp,160
    80005c5a:	8082                	ret
    end_op();
    80005c5c:	b95fe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    80005c60:	557d                	li	a0,-1
    80005c62:	bfcd                	j	80005c54 <sys_mknod+0x50>

0000000080005c64 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c64:	7135                	addi	sp,sp,-160
    80005c66:	ed06                	sd	ra,152(sp)
    80005c68:	e922                	sd	s0,144(sp)
    80005c6a:	e526                	sd	s1,136(sp)
    80005c6c:	e14a                	sd	s2,128(sp)
    80005c6e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c70:	ed9fb0ef          	jal	ra,80001b48 <myproc>
    80005c74:	892a                	mv	s2,a0
  
  begin_op();
    80005c76:	b0dfe0ef          	jal	ra,80004782 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c7a:	08000613          	li	a2,128
    80005c7e:	f6040593          	addi	a1,s0,-160
    80005c82:	4501                	li	a0,0
    80005c84:	8dafd0ef          	jal	ra,80002d5e <argstr>
    80005c88:	04054163          	bltz	a0,80005cca <sys_chdir+0x66>
    80005c8c:	f6040513          	addi	a0,s0,-160
    80005c90:	8fffe0ef          	jal	ra,8000458e <namei>
    80005c94:	84aa                	mv	s1,a0
    80005c96:	c915                	beqz	a0,80005cca <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c98:	902fe0ef          	jal	ra,80003d9a <ilock>
  if(ip->type != T_DIR){
    80005c9c:	04449703          	lh	a4,68(s1)
    80005ca0:	4785                	li	a5,1
    80005ca2:	02f71863          	bne	a4,a5,80005cd2 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ca6:	8526                	mv	a0,s1
    80005ca8:	99cfe0ef          	jal	ra,80003e44 <iunlock>
  iput(p->cwd);
    80005cac:	15093503          	ld	a0,336(s2)
    80005cb0:	a68fe0ef          	jal	ra,80003f18 <iput>
  end_op();
    80005cb4:	b3dfe0ef          	jal	ra,800047f0 <end_op>
  p->cwd = ip;
    80005cb8:	14993823          	sd	s1,336(s2)
  return 0;
    80005cbc:	4501                	li	a0,0
}
    80005cbe:	60ea                	ld	ra,152(sp)
    80005cc0:	644a                	ld	s0,144(sp)
    80005cc2:	64aa                	ld	s1,136(sp)
    80005cc4:	690a                	ld	s2,128(sp)
    80005cc6:	610d                	addi	sp,sp,160
    80005cc8:	8082                	ret
    end_op();
    80005cca:	b27fe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    80005cce:	557d                	li	a0,-1
    80005cd0:	b7fd                	j	80005cbe <sys_chdir+0x5a>
    iunlockput(ip);
    80005cd2:	8526                	mv	a0,s1
    80005cd4:	accfe0ef          	jal	ra,80003fa0 <iunlockput>
    end_op();
    80005cd8:	b19fe0ef          	jal	ra,800047f0 <end_op>
    return -1;
    80005cdc:	557d                	li	a0,-1
    80005cde:	b7c5                	j	80005cbe <sys_chdir+0x5a>

0000000080005ce0 <sys_exec>:

uint64
sys_exec(void)
{
    80005ce0:	7145                	addi	sp,sp,-464
    80005ce2:	e786                	sd	ra,456(sp)
    80005ce4:	e3a2                	sd	s0,448(sp)
    80005ce6:	ff26                	sd	s1,440(sp)
    80005ce8:	fb4a                	sd	s2,432(sp)
    80005cea:	f74e                	sd	s3,424(sp)
    80005cec:	f352                	sd	s4,416(sp)
    80005cee:	ef56                	sd	s5,408(sp)
    80005cf0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cf2:	e3840593          	addi	a1,s0,-456
    80005cf6:	4505                	li	a0,1
    80005cf8:	84afd0ef          	jal	ra,80002d42 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cfc:	08000613          	li	a2,128
    80005d00:	f4040593          	addi	a1,s0,-192
    80005d04:	4501                	li	a0,0
    80005d06:	858fd0ef          	jal	ra,80002d5e <argstr>
    80005d0a:	87aa                	mv	a5,a0
    return -1;
    80005d0c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d0e:	0a07c563          	bltz	a5,80005db8 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005d12:	10000613          	li	a2,256
    80005d16:	4581                	li	a1,0
    80005d18:	e4040513          	addi	a0,s0,-448
    80005d1c:	858fb0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d20:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d24:	89a6                	mv	s3,s1
    80005d26:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d28:	02000a13          	li	s4,32
    80005d2c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d30:	00391513          	slli	a0,s2,0x3
    80005d34:	e3040593          	addi	a1,s0,-464
    80005d38:	e3843783          	ld	a5,-456(s0)
    80005d3c:	953e                	add	a0,a0,a5
    80005d3e:	f5ffc0ef          	jal	ra,80002c9c <fetchaddr>
    80005d42:	02054663          	bltz	a0,80005d6e <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005d46:	e3043783          	ld	a5,-464(s0)
    80005d4a:	cf8d                	beqz	a5,80005d84 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d4c:	e5ffa0ef          	jal	ra,80000baa <kalloc>
    80005d50:	85aa                	mv	a1,a0
    80005d52:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d56:	cd01                	beqz	a0,80005d6e <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d58:	6605                	lui	a2,0x1
    80005d5a:	e3043503          	ld	a0,-464(s0)
    80005d5e:	f89fc0ef          	jal	ra,80002ce6 <fetchstr>
    80005d62:	00054663          	bltz	a0,80005d6e <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005d66:	0905                	addi	s2,s2,1
    80005d68:	09a1                	addi	s3,s3,8
    80005d6a:	fd4911e3          	bne	s2,s4,80005d2c <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d6e:	f4040913          	addi	s2,s0,-192
    80005d72:	6088                	ld	a0,0(s1)
    80005d74:	c129                	beqz	a0,80005db6 <sys_exec+0xd6>
    kfree(argv[i]);
    80005d76:	d05fa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d7a:	04a1                	addi	s1,s1,8
    80005d7c:	ff249be3          	bne	s1,s2,80005d72 <sys_exec+0x92>
  return -1;
    80005d80:	557d                	li	a0,-1
    80005d82:	a81d                	j	80005db8 <sys_exec+0xd8>
      argv[i] = 0;
    80005d84:	0a8e                	slli	s5,s5,0x3
    80005d86:	fc0a8793          	addi	a5,s5,-64
    80005d8a:	00878ab3          	add	s5,a5,s0
    80005d8e:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005d92:	e4040593          	addi	a1,s0,-448
    80005d96:	f4040513          	addi	a0,s0,-192
    80005d9a:	b9eff0ef          	jal	ra,80005138 <kexec>
    80005d9e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005da0:	f4040993          	addi	s3,s0,-192
    80005da4:	6088                	ld	a0,0(s1)
    80005da6:	c511                	beqz	a0,80005db2 <sys_exec+0xd2>
    kfree(argv[i]);
    80005da8:	cd3fa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dac:	04a1                	addi	s1,s1,8
    80005dae:	ff349be3          	bne	s1,s3,80005da4 <sys_exec+0xc4>
  return ret;
    80005db2:	854a                	mv	a0,s2
    80005db4:	a011                	j	80005db8 <sys_exec+0xd8>
  return -1;
    80005db6:	557d                	li	a0,-1
}
    80005db8:	60be                	ld	ra,456(sp)
    80005dba:	641e                	ld	s0,448(sp)
    80005dbc:	74fa                	ld	s1,440(sp)
    80005dbe:	795a                	ld	s2,432(sp)
    80005dc0:	79ba                	ld	s3,424(sp)
    80005dc2:	7a1a                	ld	s4,416(sp)
    80005dc4:	6afa                	ld	s5,408(sp)
    80005dc6:	6179                	addi	sp,sp,464
    80005dc8:	8082                	ret

0000000080005dca <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dca:	7139                	addi	sp,sp,-64
    80005dcc:	fc06                	sd	ra,56(sp)
    80005dce:	f822                	sd	s0,48(sp)
    80005dd0:	f426                	sd	s1,40(sp)
    80005dd2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dd4:	d75fb0ef          	jal	ra,80001b48 <myproc>
    80005dd8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dda:	fd840593          	addi	a1,s0,-40
    80005dde:	4501                	li	a0,0
    80005de0:	f63fc0ef          	jal	ra,80002d42 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005de4:	fc840593          	addi	a1,s0,-56
    80005de8:	fd040513          	addi	a0,s0,-48
    80005dec:	86cff0ef          	jal	ra,80004e58 <pipealloc>
    return -1;
    80005df0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005df2:	0a054463          	bltz	a0,80005e9a <sys_pipe+0xd0>
  fd0 = -1;
    80005df6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dfa:	fd043503          	ld	a0,-48(s0)
    80005dfe:	f3cff0ef          	jal	ra,8000553a <fdalloc>
    80005e02:	fca42223          	sw	a0,-60(s0)
    80005e06:	08054163          	bltz	a0,80005e88 <sys_pipe+0xbe>
    80005e0a:	fc843503          	ld	a0,-56(s0)
    80005e0e:	f2cff0ef          	jal	ra,8000553a <fdalloc>
    80005e12:	fca42023          	sw	a0,-64(s0)
    80005e16:	06054063          	bltz	a0,80005e76 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e1a:	4691                	li	a3,4
    80005e1c:	fc440613          	addi	a2,s0,-60
    80005e20:	fd843583          	ld	a1,-40(s0)
    80005e24:	68a8                	ld	a0,80(s1)
    80005e26:	945fb0ef          	jal	ra,8000176a <copyout>
    80005e2a:	00054e63          	bltz	a0,80005e46 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e2e:	4691                	li	a3,4
    80005e30:	fc040613          	addi	a2,s0,-64
    80005e34:	fd843583          	ld	a1,-40(s0)
    80005e38:	0591                	addi	a1,a1,4
    80005e3a:	68a8                	ld	a0,80(s1)
    80005e3c:	92ffb0ef          	jal	ra,8000176a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e40:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e42:	04055c63          	bgez	a0,80005e9a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005e46:	fc442783          	lw	a5,-60(s0)
    80005e4a:	07e9                	addi	a5,a5,26
    80005e4c:	078e                	slli	a5,a5,0x3
    80005e4e:	97a6                	add	a5,a5,s1
    80005e50:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e54:	fc042783          	lw	a5,-64(s0)
    80005e58:	07e9                	addi	a5,a5,26
    80005e5a:	078e                	slli	a5,a5,0x3
    80005e5c:	94be                	add	s1,s1,a5
    80005e5e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e62:	fd043503          	ld	a0,-48(s0)
    80005e66:	d27fe0ef          	jal	ra,80004b8c <fileclose>
    fileclose(wf);
    80005e6a:	fc843503          	ld	a0,-56(s0)
    80005e6e:	d1ffe0ef          	jal	ra,80004b8c <fileclose>
    return -1;
    80005e72:	57fd                	li	a5,-1
    80005e74:	a01d                	j	80005e9a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005e76:	fc442783          	lw	a5,-60(s0)
    80005e7a:	0007c763          	bltz	a5,80005e88 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005e7e:	07e9                	addi	a5,a5,26
    80005e80:	078e                	slli	a5,a5,0x3
    80005e82:	97a6                	add	a5,a5,s1
    80005e84:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e88:	fd043503          	ld	a0,-48(s0)
    80005e8c:	d01fe0ef          	jal	ra,80004b8c <fileclose>
    fileclose(wf);
    80005e90:	fc843503          	ld	a0,-56(s0)
    80005e94:	cf9fe0ef          	jal	ra,80004b8c <fileclose>
    return -1;
    80005e98:	57fd                	li	a5,-1
}
    80005e9a:	853e                	mv	a0,a5
    80005e9c:	70e2                	ld	ra,56(sp)
    80005e9e:	7442                	ld	s0,48(sp)
    80005ea0:	74a2                	ld	s1,40(sp)
    80005ea2:	6121                	addi	sp,sp,64
    80005ea4:	8082                	ret
	...

0000000080005eb0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005eb0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005eb2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005eb4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005eb6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005eb8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005eba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005ebc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005ebe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005ec0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005ec2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005ec4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005ec6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005ec8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005eca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005ecc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005ece:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005ed0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005ed2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005ed4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005ed6:	cd7fc0ef          	jal	ra,80002bac <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005eda:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005edc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005ede:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005ee0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005ee2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005ee4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005ee6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005ee8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005eea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005eec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005eee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005ef0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005ef2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005ef4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005ef6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005ef8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005efa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005efc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005efe:	10200073          	sret
	...

0000000080005f0e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f0e:	1141                	addi	sp,sp,-16
    80005f10:	e422                	sd	s0,8(sp)
    80005f12:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f14:	0c0007b7          	lui	a5,0xc000
    80005f18:	4705                	li	a4,1
    80005f1a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f1c:	c3d8                	sw	a4,4(a5)
}
    80005f1e:	6422                	ld	s0,8(sp)
    80005f20:	0141                	addi	sp,sp,16
    80005f22:	8082                	ret

0000000080005f24 <plicinithart>:

void
plicinithart(void)
{
    80005f24:	1141                	addi	sp,sp,-16
    80005f26:	e406                	sd	ra,8(sp)
    80005f28:	e022                	sd	s0,0(sp)
    80005f2a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f2c:	bf1fb0ef          	jal	ra,80001b1c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f30:	0085171b          	slliw	a4,a0,0x8
    80005f34:	0c0027b7          	lui	a5,0xc002
    80005f38:	97ba                	add	a5,a5,a4
    80005f3a:	40200713          	li	a4,1026
    80005f3e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f42:	00d5151b          	slliw	a0,a0,0xd
    80005f46:	0c2017b7          	lui	a5,0xc201
    80005f4a:	97aa                	add	a5,a5,a0
    80005f4c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f50:	60a2                	ld	ra,8(sp)
    80005f52:	6402                	ld	s0,0(sp)
    80005f54:	0141                	addi	sp,sp,16
    80005f56:	8082                	ret

0000000080005f58 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f58:	1141                	addi	sp,sp,-16
    80005f5a:	e406                	sd	ra,8(sp)
    80005f5c:	e022                	sd	s0,0(sp)
    80005f5e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f60:	bbdfb0ef          	jal	ra,80001b1c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f64:	00d5151b          	slliw	a0,a0,0xd
    80005f68:	0c2017b7          	lui	a5,0xc201
    80005f6c:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f6e:	43c8                	lw	a0,4(a5)
    80005f70:	60a2                	ld	ra,8(sp)
    80005f72:	6402                	ld	s0,0(sp)
    80005f74:	0141                	addi	sp,sp,16
    80005f76:	8082                	ret

0000000080005f78 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f78:	1101                	addi	sp,sp,-32
    80005f7a:	ec06                	sd	ra,24(sp)
    80005f7c:	e822                	sd	s0,16(sp)
    80005f7e:	e426                	sd	s1,8(sp)
    80005f80:	1000                	addi	s0,sp,32
    80005f82:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f84:	b99fb0ef          	jal	ra,80001b1c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f88:	00d5151b          	slliw	a0,a0,0xd
    80005f8c:	0c2017b7          	lui	a5,0xc201
    80005f90:	97aa                	add	a5,a5,a0
    80005f92:	c3c4                	sw	s1,4(a5)
}
    80005f94:	60e2                	ld	ra,24(sp)
    80005f96:	6442                	ld	s0,16(sp)
    80005f98:	64a2                	ld	s1,8(sp)
    80005f9a:	6105                	addi	sp,sp,32
    80005f9c:	8082                	ret

0000000080005f9e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f9e:	1141                	addi	sp,sp,-16
    80005fa0:	e406                	sd	ra,8(sp)
    80005fa2:	e022                	sd	s0,0(sp)
    80005fa4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fa6:	479d                	li	a5,7
    80005fa8:	04a7ca63          	blt	a5,a0,80005ffc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005fac:	00246797          	auipc	a5,0x246
    80005fb0:	af478793          	addi	a5,a5,-1292 # 8024baa0 <disk>
    80005fb4:	97aa                	add	a5,a5,a0
    80005fb6:	0187c783          	lbu	a5,24(a5)
    80005fba:	e7b9                	bnez	a5,80006008 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fbc:	00451693          	slli	a3,a0,0x4
    80005fc0:	00246797          	auipc	a5,0x246
    80005fc4:	ae078793          	addi	a5,a5,-1312 # 8024baa0 <disk>
    80005fc8:	6398                	ld	a4,0(a5)
    80005fca:	9736                	add	a4,a4,a3
    80005fcc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005fd0:	6398                	ld	a4,0(a5)
    80005fd2:	9736                	add	a4,a4,a3
    80005fd4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fd8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005fdc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005fe0:	97aa                	add	a5,a5,a0
    80005fe2:	4705                	li	a4,1
    80005fe4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005fe8:	00246517          	auipc	a0,0x246
    80005fec:	ad050513          	addi	a0,a0,-1328 # 8024bab8 <disk+0x18>
    80005ff0:	c4afc0ef          	jal	ra,8000243a <wakeup>
}
    80005ff4:	60a2                	ld	ra,8(sp)
    80005ff6:	6402                	ld	s0,0(sp)
    80005ff8:	0141                	addi	sp,sp,16
    80005ffa:	8082                	ret
    panic("free_desc 1");
    80005ffc:	00002517          	auipc	a0,0x2
    80006000:	74c50513          	addi	a0,a0,1868 # 80008748 <syscalls+0x350>
    80006004:	f84fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80006008:	00002517          	auipc	a0,0x2
    8000600c:	75050513          	addi	a0,a0,1872 # 80008758 <syscalls+0x360>
    80006010:	f78fa0ef          	jal	ra,80000788 <panic>

0000000080006014 <virtio_disk_init>:
{
    80006014:	1101                	addi	sp,sp,-32
    80006016:	ec06                	sd	ra,24(sp)
    80006018:	e822                	sd	s0,16(sp)
    8000601a:	e426                	sd	s1,8(sp)
    8000601c:	e04a                	sd	s2,0(sp)
    8000601e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006020:	00002597          	auipc	a1,0x2
    80006024:	74858593          	addi	a1,a1,1864 # 80008768 <syscalls+0x370>
    80006028:	00246517          	auipc	a0,0x246
    8000602c:	ba050513          	addi	a0,a0,-1120 # 8024bbc8 <disk+0x128>
    80006030:	bf1fa0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006034:	100017b7          	lui	a5,0x10001
    80006038:	4398                	lw	a4,0(a5)
    8000603a:	2701                	sext.w	a4,a4
    8000603c:	747277b7          	lui	a5,0x74727
    80006040:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006044:	12f71f63          	bne	a4,a5,80006182 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006048:	100017b7          	lui	a5,0x10001
    8000604c:	43dc                	lw	a5,4(a5)
    8000604e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006050:	4709                	li	a4,2
    80006052:	12e79863          	bne	a5,a4,80006182 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006056:	100017b7          	lui	a5,0x10001
    8000605a:	479c                	lw	a5,8(a5)
    8000605c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000605e:	12e79263          	bne	a5,a4,80006182 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006062:	100017b7          	lui	a5,0x10001
    80006066:	47d8                	lw	a4,12(a5)
    80006068:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000606a:	554d47b7          	lui	a5,0x554d4
    8000606e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006072:	10f71863          	bne	a4,a5,80006182 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006076:	100017b7          	lui	a5,0x10001
    8000607a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607e:	4705                	li	a4,1
    80006080:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006082:	470d                	li	a4,3
    80006084:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006086:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006088:	c7ffe6b7          	lui	a3,0xc7ffe
    8000608c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47daa9e7>
    80006090:	8f75                	and	a4,a4,a3
    80006092:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006094:	472d                	li	a4,11
    80006096:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006098:	5bbc                	lw	a5,112(a5)
    8000609a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000609e:	8ba1                	andi	a5,a5,8
    800060a0:	0e078763          	beqz	a5,8000618e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060a4:	100017b7          	lui	a5,0x10001
    800060a8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060ac:	43fc                	lw	a5,68(a5)
    800060ae:	2781                	sext.w	a5,a5
    800060b0:	0e079563          	bnez	a5,8000619a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060b4:	100017b7          	lui	a5,0x10001
    800060b8:	5bdc                	lw	a5,52(a5)
    800060ba:	2781                	sext.w	a5,a5
  if(max == 0)
    800060bc:	0e078563          	beqz	a5,800061a6 <virtio_disk_init+0x192>
  if(max < NUM)
    800060c0:	471d                	li	a4,7
    800060c2:	0ef77863          	bgeu	a4,a5,800061b2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    800060c6:	ae5fa0ef          	jal	ra,80000baa <kalloc>
    800060ca:	00246497          	auipc	s1,0x246
    800060ce:	9d648493          	addi	s1,s1,-1578 # 8024baa0 <disk>
    800060d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060d4:	ad7fa0ef          	jal	ra,80000baa <kalloc>
    800060d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060da:	ad1fa0ef          	jal	ra,80000baa <kalloc>
    800060de:	87aa                	mv	a5,a0
    800060e0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060e2:	6088                	ld	a0,0(s1)
    800060e4:	cd69                	beqz	a0,800061be <virtio_disk_init+0x1aa>
    800060e6:	00246717          	auipc	a4,0x246
    800060ea:	9c273703          	ld	a4,-1598(a4) # 8024baa8 <disk+0x8>
    800060ee:	cb61                	beqz	a4,800061be <virtio_disk_init+0x1aa>
    800060f0:	c7f9                	beqz	a5,800061be <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    800060f2:	6605                	lui	a2,0x1
    800060f4:	4581                	li	a1,0
    800060f6:	c7ffa0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060fa:	00246497          	auipc	s1,0x246
    800060fe:	9a648493          	addi	s1,s1,-1626 # 8024baa0 <disk>
    80006102:	6605                	lui	a2,0x1
    80006104:	4581                	li	a1,0
    80006106:	6488                	ld	a0,8(s1)
    80006108:	c6dfa0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    8000610c:	6605                	lui	a2,0x1
    8000610e:	4581                	li	a1,0
    80006110:	6888                	ld	a0,16(s1)
    80006112:	c63fa0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006116:	100017b7          	lui	a5,0x10001
    8000611a:	4721                	li	a4,8
    8000611c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000611e:	4098                	lw	a4,0(s1)
    80006120:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006124:	40d8                	lw	a4,4(s1)
    80006126:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000612a:	6498                	ld	a4,8(s1)
    8000612c:	0007069b          	sext.w	a3,a4
    80006130:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006134:	9701                	srai	a4,a4,0x20
    80006136:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000613a:	6898                	ld	a4,16(s1)
    8000613c:	0007069b          	sext.w	a3,a4
    80006140:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006144:	9701                	srai	a4,a4,0x20
    80006146:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000614a:	4705                	li	a4,1
    8000614c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000614e:	00e48c23          	sb	a4,24(s1)
    80006152:	00e48ca3          	sb	a4,25(s1)
    80006156:	00e48d23          	sb	a4,26(s1)
    8000615a:	00e48da3          	sb	a4,27(s1)
    8000615e:	00e48e23          	sb	a4,28(s1)
    80006162:	00e48ea3          	sb	a4,29(s1)
    80006166:	00e48f23          	sb	a4,30(s1)
    8000616a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000616e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006172:	0727a823          	sw	s2,112(a5)
}
    80006176:	60e2                	ld	ra,24(sp)
    80006178:	6442                	ld	s0,16(sp)
    8000617a:	64a2                	ld	s1,8(sp)
    8000617c:	6902                	ld	s2,0(sp)
    8000617e:	6105                	addi	sp,sp,32
    80006180:	8082                	ret
    panic("could not find virtio disk");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	5f650513          	addi	a0,a0,1526 # 80008778 <syscalls+0x380>
    8000618a:	dfefa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000618e:	00002517          	auipc	a0,0x2
    80006192:	60a50513          	addi	a0,a0,1546 # 80008798 <syscalls+0x3a0>
    80006196:	df2fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    8000619a:	00002517          	auipc	a0,0x2
    8000619e:	61e50513          	addi	a0,a0,1566 # 800087b8 <syscalls+0x3c0>
    800061a2:	de6fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    800061a6:	00002517          	auipc	a0,0x2
    800061aa:	63250513          	addi	a0,a0,1586 # 800087d8 <syscalls+0x3e0>
    800061ae:	ddafa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    800061b2:	00002517          	auipc	a0,0x2
    800061b6:	64650513          	addi	a0,a0,1606 # 800087f8 <syscalls+0x400>
    800061ba:	dcefa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    800061be:	00002517          	auipc	a0,0x2
    800061c2:	65a50513          	addi	a0,a0,1626 # 80008818 <syscalls+0x420>
    800061c6:	dc2fa0ef          	jal	ra,80000788 <panic>

00000000800061ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061ca:	7119                	addi	sp,sp,-128
    800061cc:	fc86                	sd	ra,120(sp)
    800061ce:	f8a2                	sd	s0,112(sp)
    800061d0:	f4a6                	sd	s1,104(sp)
    800061d2:	f0ca                	sd	s2,96(sp)
    800061d4:	ecce                	sd	s3,88(sp)
    800061d6:	e8d2                	sd	s4,80(sp)
    800061d8:	e4d6                	sd	s5,72(sp)
    800061da:	e0da                	sd	s6,64(sp)
    800061dc:	fc5e                	sd	s7,56(sp)
    800061de:	f862                	sd	s8,48(sp)
    800061e0:	f466                	sd	s9,40(sp)
    800061e2:	f06a                	sd	s10,32(sp)
    800061e4:	ec6e                	sd	s11,24(sp)
    800061e6:	0100                	addi	s0,sp,128
    800061e8:	8aaa                	mv	s5,a0
    800061ea:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061ec:	00c52d03          	lw	s10,12(a0)
    800061f0:	001d1d1b          	slliw	s10,s10,0x1
    800061f4:	1d02                	slli	s10,s10,0x20
    800061f6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800061fa:	00246517          	auipc	a0,0x246
    800061fe:	9ce50513          	addi	a0,a0,-1586 # 8024bbc8 <disk+0x128>
    80006202:	a9ffa0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80006206:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006208:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000620a:	00246b97          	auipc	s7,0x246
    8000620e:	896b8b93          	addi	s7,s7,-1898 # 8024baa0 <disk>
  for(int i = 0; i < 3; i++){
    80006212:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006214:	00246c97          	auipc	s9,0x246
    80006218:	9b4c8c93          	addi	s9,s9,-1612 # 8024bbc8 <disk+0x128>
    8000621c:	a8a9                	j	80006276 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    8000621e:	00fb8733          	add	a4,s7,a5
    80006222:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006226:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006228:	0207c563          	bltz	a5,80006252 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000622c:	2905                	addiw	s2,s2,1
    8000622e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006230:	05690863          	beq	s2,s6,80006280 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80006234:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006236:	00246717          	auipc	a4,0x246
    8000623a:	86a70713          	addi	a4,a4,-1942 # 8024baa0 <disk>
    8000623e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006240:	01874683          	lbu	a3,24(a4)
    80006244:	fee9                	bnez	a3,8000621e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006246:	2785                	addiw	a5,a5,1
    80006248:	0705                	addi	a4,a4,1
    8000624a:	fe979be3          	bne	a5,s1,80006240 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000624e:	57fd                	li	a5,-1
    80006250:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006252:	01205b63          	blez	s2,80006268 <virtio_disk_rw+0x9e>
    80006256:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006258:	000a2503          	lw	a0,0(s4)
    8000625c:	d43ff0ef          	jal	ra,80005f9e <free_desc>
      for(int j = 0; j < i; j++)
    80006260:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    80006262:	0a11                	addi	s4,s4,4
    80006264:	ff2d9ae3          	bne	s11,s2,80006258 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006268:	85e6                	mv	a1,s9
    8000626a:	00246517          	auipc	a0,0x246
    8000626e:	84e50513          	addi	a0,a0,-1970 # 8024bab8 <disk+0x18>
    80006272:	97cfc0ef          	jal	ra,800023ee <sleep>
  for(int i = 0; i < 3; i++){
    80006276:	f8040a13          	addi	s4,s0,-128
{
    8000627a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000627c:	894e                	mv	s2,s3
    8000627e:	bf5d                	j	80006234 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006280:	f8042503          	lw	a0,-128(s0)
    80006284:	00a50713          	addi	a4,a0,10
    80006288:	0712                	slli	a4,a4,0x4

  if(write)
    8000628a:	00246797          	auipc	a5,0x246
    8000628e:	81678793          	addi	a5,a5,-2026 # 8024baa0 <disk>
    80006292:	00e786b3          	add	a3,a5,a4
    80006296:	01803633          	snez	a2,s8
    8000629a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000629c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800062a0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062a4:	f6070613          	addi	a2,a4,-160
    800062a8:	6394                	ld	a3,0(a5)
    800062aa:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062ac:	00870593          	addi	a1,a4,8
    800062b0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062b2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062b4:	0007b803          	ld	a6,0(a5)
    800062b8:	9642                	add	a2,a2,a6
    800062ba:	46c1                	li	a3,16
    800062bc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062be:	4585                	li	a1,1
    800062c0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800062c4:	f8442683          	lw	a3,-124(s0)
    800062c8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062cc:	0692                	slli	a3,a3,0x4
    800062ce:	9836                	add	a6,a6,a3
    800062d0:	058a8613          	addi	a2,s5,88
    800062d4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800062d8:	0007b803          	ld	a6,0(a5)
    800062dc:	96c2                	add	a3,a3,a6
    800062de:	40000613          	li	a2,1024
    800062e2:	c690                	sw	a2,8(a3)
  if(write)
    800062e4:	001c3613          	seqz	a2,s8
    800062e8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062ec:	00166613          	ori	a2,a2,1
    800062f0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800062f4:	f8842603          	lw	a2,-120(s0)
    800062f8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800062fc:	00250693          	addi	a3,a0,2
    80006300:	0692                	slli	a3,a3,0x4
    80006302:	96be                	add	a3,a3,a5
    80006304:	58fd                	li	a7,-1
    80006306:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000630a:	0612                	slli	a2,a2,0x4
    8000630c:	9832                	add	a6,a6,a2
    8000630e:	f9070713          	addi	a4,a4,-112
    80006312:	973e                	add	a4,a4,a5
    80006314:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006318:	6398                	ld	a4,0(a5)
    8000631a:	9732                	add	a4,a4,a2
    8000631c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000631e:	4609                	li	a2,2
    80006320:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006324:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006328:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    8000632c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006330:	6794                	ld	a3,8(a5)
    80006332:	0026d703          	lhu	a4,2(a3)
    80006336:	8b1d                	andi	a4,a4,7
    80006338:	0706                	slli	a4,a4,0x1
    8000633a:	96ba                	add	a3,a3,a4
    8000633c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006340:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006344:	6798                	ld	a4,8(a5)
    80006346:	00275783          	lhu	a5,2(a4)
    8000634a:	2785                	addiw	a5,a5,1
    8000634c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006350:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006354:	100017b7          	lui	a5,0x10001
    80006358:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000635c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006360:	00246917          	auipc	s2,0x246
    80006364:	86890913          	addi	s2,s2,-1944 # 8024bbc8 <disk+0x128>
  while(b->disk == 1) {
    80006368:	4485                	li	s1,1
    8000636a:	00b79a63          	bne	a5,a1,8000637e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    8000636e:	85ca                	mv	a1,s2
    80006370:	8556                	mv	a0,s5
    80006372:	87cfc0ef          	jal	ra,800023ee <sleep>
  while(b->disk == 1) {
    80006376:	004aa783          	lw	a5,4(s5)
    8000637a:	fe978ae3          	beq	a5,s1,8000636e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    8000637e:	f8042903          	lw	s2,-128(s0)
    80006382:	00290713          	addi	a4,s2,2
    80006386:	0712                	slli	a4,a4,0x4
    80006388:	00245797          	auipc	a5,0x245
    8000638c:	71878793          	addi	a5,a5,1816 # 8024baa0 <disk>
    80006390:	97ba                	add	a5,a5,a4
    80006392:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006396:	00245997          	auipc	s3,0x245
    8000639a:	70a98993          	addi	s3,s3,1802 # 8024baa0 <disk>
    8000639e:	00491713          	slli	a4,s2,0x4
    800063a2:	0009b783          	ld	a5,0(s3)
    800063a6:	97ba                	add	a5,a5,a4
    800063a8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063ac:	854a                	mv	a0,s2
    800063ae:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063b2:	bedff0ef          	jal	ra,80005f9e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063b6:	8885                	andi	s1,s1,1
    800063b8:	f0fd                	bnez	s1,8000639e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063ba:	00246517          	auipc	a0,0x246
    800063be:	80e50513          	addi	a0,a0,-2034 # 8024bbc8 <disk+0x128>
    800063c2:	977fa0ef          	jal	ra,80000d38 <release>
}
    800063c6:	70e6                	ld	ra,120(sp)
    800063c8:	7446                	ld	s0,112(sp)
    800063ca:	74a6                	ld	s1,104(sp)
    800063cc:	7906                	ld	s2,96(sp)
    800063ce:	69e6                	ld	s3,88(sp)
    800063d0:	6a46                	ld	s4,80(sp)
    800063d2:	6aa6                	ld	s5,72(sp)
    800063d4:	6b06                	ld	s6,64(sp)
    800063d6:	7be2                	ld	s7,56(sp)
    800063d8:	7c42                	ld	s8,48(sp)
    800063da:	7ca2                	ld	s9,40(sp)
    800063dc:	7d02                	ld	s10,32(sp)
    800063de:	6de2                	ld	s11,24(sp)
    800063e0:	6109                	addi	sp,sp,128
    800063e2:	8082                	ret

00000000800063e4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063e4:	1101                	addi	sp,sp,-32
    800063e6:	ec06                	sd	ra,24(sp)
    800063e8:	e822                	sd	s0,16(sp)
    800063ea:	e426                	sd	s1,8(sp)
    800063ec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063ee:	00245497          	auipc	s1,0x245
    800063f2:	6b248493          	addi	s1,s1,1714 # 8024baa0 <disk>
    800063f6:	00245517          	auipc	a0,0x245
    800063fa:	7d250513          	addi	a0,a0,2002 # 8024bbc8 <disk+0x128>
    800063fe:	8a3fa0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006402:	10001737          	lui	a4,0x10001
    80006406:	533c                	lw	a5,96(a4)
    80006408:	8b8d                	andi	a5,a5,3
    8000640a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000640c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006410:	689c                	ld	a5,16(s1)
    80006412:	0204d703          	lhu	a4,32(s1)
    80006416:	0027d783          	lhu	a5,2(a5)
    8000641a:	04f70663          	beq	a4,a5,80006466 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000641e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006422:	6898                	ld	a4,16(s1)
    80006424:	0204d783          	lhu	a5,32(s1)
    80006428:	8b9d                	andi	a5,a5,7
    8000642a:	078e                	slli	a5,a5,0x3
    8000642c:	97ba                	add	a5,a5,a4
    8000642e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006430:	00278713          	addi	a4,a5,2
    80006434:	0712                	slli	a4,a4,0x4
    80006436:	9726                	add	a4,a4,s1
    80006438:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000643c:	e321                	bnez	a4,8000647c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000643e:	0789                	addi	a5,a5,2
    80006440:	0792                	slli	a5,a5,0x4
    80006442:	97a6                	add	a5,a5,s1
    80006444:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006446:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000644a:	ff1fb0ef          	jal	ra,8000243a <wakeup>

    disk.used_idx += 1;
    8000644e:	0204d783          	lhu	a5,32(s1)
    80006452:	2785                	addiw	a5,a5,1
    80006454:	17c2                	slli	a5,a5,0x30
    80006456:	93c1                	srli	a5,a5,0x30
    80006458:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000645c:	6898                	ld	a4,16(s1)
    8000645e:	00275703          	lhu	a4,2(a4)
    80006462:	faf71ee3          	bne	a4,a5,8000641e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80006466:	00245517          	auipc	a0,0x245
    8000646a:	76250513          	addi	a0,a0,1890 # 8024bbc8 <disk+0x128>
    8000646e:	8cbfa0ef          	jal	ra,80000d38 <release>
}
    80006472:	60e2                	ld	ra,24(sp)
    80006474:	6442                	ld	s0,16(sp)
    80006476:	64a2                	ld	s1,8(sp)
    80006478:	6105                	addi	sp,sp,32
    8000647a:	8082                	ret
      panic("virtio_disk_intr status");
    8000647c:	00002517          	auipc	a0,0x2
    80006480:	3b450513          	addi	a0,a0,948 # 80008830 <syscalls+0x438>
    80006484:	b04fa0ef          	jal	ra,80000788 <panic>

0000000080006488 <shm_init>:
  struct shmobj obj[NSHM];
} shmt;

void
shm_init(void)
{
    80006488:	1141                	addi	sp,sp,-16
    8000648a:	e406                	sd	ra,8(sp)
    8000648c:	e022                	sd	s0,0(sp)
    8000648e:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    80006490:	00002597          	auipc	a1,0x2
    80006494:	3b858593          	addi	a1,a1,952 # 80008848 <syscalls+0x450>
    80006498:	00245517          	auipc	a0,0x245
    8000649c:	74850513          	addi	a0,a0,1864 # 8024bbe0 <shmt>
    800064a0:	f80fa0ef          	jal	ra,80000c20 <initlock>
}
    800064a4:	60a2                	ld	ra,8(sp)
    800064a6:	6402                	ld	s0,0(sp)
    800064a8:	0141                	addi	sp,sp,16
    800064aa:	8082                	ret

00000000800064ac <shm_get>:

// 找到或创建 key 对应对象，返回 index；失败返回 -1
int
shm_get(int key, int npages)
{
    800064ac:	7179                	addi	sp,sp,-48
    800064ae:	f406                	sd	ra,40(sp)
    800064b0:	f022                	sd	s0,32(sp)
    800064b2:	ec26                	sd	s1,24(sp)
    800064b4:	e84a                	sd	s2,16(sp)
    800064b6:	e44e                	sd	s3,8(sp)
    800064b8:	1800                	addi	s0,sp,48
    800064ba:	892a                	mv	s2,a0
    800064bc:	89ae                	mv	s3,a1
  acquire(&shmt.lock);
    800064be:	00245517          	auipc	a0,0x245
    800064c2:	72250513          	addi	a0,a0,1826 # 8024bbe0 <shmt>
    800064c6:	fdafa0ef          	jal	ra,80000ca0 <acquire>

  // 先找已有
  for(int i=0;i<NSHM;i++){
    800064ca:	00245697          	auipc	a3,0x245
    800064ce:	72e68693          	addi	a3,a3,1838 # 8024bbf8 <shmt+0x18>
  acquire(&shmt.lock);
    800064d2:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    800064d4:	4481                	li	s1,0
    800064d6:	6605                	lui	a2,0x1
    800064d8:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    800064dc:	4841                	li	a6,16
    800064de:	a015                	j	80006502 <shm_get+0x56>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
    800064e0:	00245517          	auipc	a0,0x245
    800064e4:	70050513          	addi	a0,a0,1792 # 8024bbe0 <shmt>
    800064e8:	851fa0ef          	jal	ra,80000d38 <release>
        return -1;
    800064ec:	54fd                	li	s1,-1
    800064ee:	a879                	j	8000658c <shm_get+0xe0>
      }
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    800064f0:	853a                	mv	a0,a4
    800064f2:	847fa0ef          	jal	ra,80000d38 <release>
        return -1;
    800064f6:	54fd                	li	s1,-1
    800064f8:	a851                	j	8000658c <shm_get+0xe0>
  for(int i=0;i<NSHM;i++){
    800064fa:	2485                	addiw	s1,s1,1
    800064fc:	97b2                	add	a5,a5,a2
    800064fe:	07048563          	beq	s1,a6,80006568 <shm_get+0xbc>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006502:	4398                	lw	a4,0(a5)
    80006504:	db7d                	beqz	a4,800064fa <shm_get+0x4e>
    80006506:	43d8                	lw	a4,4(a5)
    80006508:	ff2719e3          	bne	a4,s2,800064fa <shm_get+0x4e>
      if(shmt.obj[i].deleted){
    8000650c:	6785                	lui	a5,0x1
    8000650e:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006512:	02d486b3          	mul	a3,s1,a3
    80006516:	00245717          	auipc	a4,0x245
    8000651a:	6ca70713          	addi	a4,a4,1738 # 8024bbe0 <shmt>
    8000651e:	9736                	add	a4,a4,a3
    80006520:	97ba                	add	a5,a5,a4
    80006522:	82c7a783          	lw	a5,-2004(a5)
    80006526:	ffcd                	bnez	a5,800064e0 <shm_get+0x34>
      if(npages > shmt.obj[i].npages){
    80006528:	6785                	lui	a5,0x1
    8000652a:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000652e:	02f487b3          	mul	a5,s1,a5
    80006532:	00245717          	auipc	a4,0x245
    80006536:	6ae70713          	addi	a4,a4,1710 # 8024bbe0 <shmt>
    8000653a:	97ba                	add	a5,a5,a4
    8000653c:	539c                	lw	a5,32(a5)
    8000653e:	fb37c9e3          	blt	a5,s3,800064f0 <shm_get+0x44>
      }
      shmt.obj[i].refcnt++;
    80006542:	00245517          	auipc	a0,0x245
    80006546:	69e50513          	addi	a0,a0,1694 # 8024bbe0 <shmt>
    8000654a:	6785                	lui	a5,0x1
    8000654c:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006550:	02e48733          	mul	a4,s1,a4
    80006554:	972a                	add	a4,a4,a0
    80006556:	97ba                	add	a5,a5,a4
    80006558:	8287a703          	lw	a4,-2008(a5)
    8000655c:	2705                	addiw	a4,a4,1
    8000655e:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    80006562:	fd6fa0ef          	jal	ra,80000d38 <release>
      return i;
    80006566:	a01d                	j	8000658c <shm_get+0xe0>
    }
  }

  // 再创建
  for(int i=0;i<NSHM;i++){
    80006568:	4481                	li	s1,0
    8000656a:	6705                	lui	a4,0x1
    8000656c:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006570:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    80006572:	429c                	lw	a5,0(a3)
    80006574:	c785                	beqz	a5,8000659c <shm_get+0xf0>
  for(int i=0;i<NSHM;i++){
    80006576:	2485                	addiw	s1,s1,1
    80006578:	96ba                	add	a3,a3,a4
    8000657a:	fec49ce3          	bne	s1,a2,80006572 <shm_get+0xc6>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    8000657e:	00245517          	auipc	a0,0x245
    80006582:	66250513          	addi	a0,a0,1634 # 8024bbe0 <shmt>
    80006586:	fb2fa0ef          	jal	ra,80000d38 <release>
  return -1;
    8000658a:	54fd                	li	s1,-1
}
    8000658c:	8526                	mv	a0,s1
    8000658e:	70a2                	ld	ra,40(sp)
    80006590:	7402                	ld	s0,32(sp)
    80006592:	64e2                	ld	s1,24(sp)
    80006594:	6942                	ld	s2,16(sp)
    80006596:	69a2                	ld	s3,8(sp)
    80006598:	6145                	addi	sp,sp,48
    8000659a:	8082                	ret
      shmt.obj[i].deleted = 0;
    8000659c:	00245617          	auipc	a2,0x245
    800065a0:	64460613          	addi	a2,a2,1604 # 8024bbe0 <shmt>
    800065a4:	6785                	lui	a5,0x1
    800065a6:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800065aa:	02d486b3          	mul	a3,s1,a3
    800065ae:	00d60733          	add	a4,a2,a3
    800065b2:	97ba                	add	a5,a5,a4
    800065b4:	8207a623          	sw	zero,-2004(a5)
      shmt.obj[i].used = 1;
    800065b8:	4585                	li	a1,1
    800065ba:	cf0c                	sw	a1,24(a4)
      shmt.obj[i].key = key;
    800065bc:	01272e23          	sw	s2,28(a4)
      shmt.obj[i].npages = npages;
    800065c0:	03372023          	sw	s3,32(a4)
      shmt.obj[i].refcnt = 1;
    800065c4:	82b7a423          	sw	a1,-2008(a5)
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
    800065c8:	02868793          	addi	a5,a3,40
    800065cc:	97b2                	add	a5,a5,a2
    800065ce:	00246717          	auipc	a4,0x246
    800065d2:	e3a70713          	addi	a4,a4,-454 # 8024c408 <shmt+0x828>
    800065d6:	9736                	add	a4,a4,a3
    800065d8:	0007b023          	sd	zero,0(a5)
    800065dc:	07a1                	addi	a5,a5,8
    800065de:	fee79de3          	bne	a5,a4,800065d8 <shm_get+0x12c>
      release(&shmt.lock);
    800065e2:	00245517          	auipc	a0,0x245
    800065e6:	5fe50513          	addi	a0,a0,1534 # 8024bbe0 <shmt>
    800065ea:	f4efa0ef          	jal	ra,80000d38 <release>
      return i;
    800065ee:	bf79                	j	8000658c <shm_get+0xe0>

00000000800065f0 <shm_put>:


// refcnt--，若为 0 则释放对象里的所有页（kfree 会走页 refcnt，安全）
void
shm_put(int key)
{
    800065f0:	7179                	addi	sp,sp,-48
    800065f2:	f406                	sd	ra,40(sp)
    800065f4:	f022                	sd	s0,32(sp)
    800065f6:	ec26                	sd	s1,24(sp)
    800065f8:	e84a                	sd	s2,16(sp)
    800065fa:	e44e                	sd	s3,8(sp)
    800065fc:	e052                	sd	s4,0(sp)
    800065fe:	1800                	addi	s0,sp,48
    80006600:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    80006602:	00245517          	auipc	a0,0x245
    80006606:	5de50513          	addi	a0,a0,1502 # 8024bbe0 <shmt>
    8000660a:	e96fa0ef          	jal	ra,80000ca0 <acquire>
  for(int i=0;i<NSHM;i++){
    8000660e:	00245797          	auipc	a5,0x245
    80006612:	5ea78793          	addi	a5,a5,1514 # 8024bbf8 <shmt+0x18>
    80006616:	4481                	li	s1,0
    80006618:	6685                	lui	a3,0x1
    8000661a:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000661e:	4641                	li	a2,16
    80006620:	a0b5                	j	8000668c <shm_put+0x9c>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
    80006622:	00002517          	auipc	a0,0x2
    80006626:	22e50513          	addi	a0,a0,558 # 80008850 <syscalls+0x458>
    8000662a:	95efa0ef          	jal	ra,80000788 <panic>
      shmt.obj[i].refcnt--;
      if(shmt.obj[i].refcnt == 0){
        for(int j=0;j<shmt.obj[i].npages;j++){
    8000662e:	2985                	addiw	s3,s3,1
    80006630:	0921                	addi	s2,s2,8
    80006632:	020a2783          	lw	a5,32(s4)
    80006636:	00f9da63          	bge	s3,a5,8000664a <shm_put+0x5a>
          if(shmt.obj[i].pa[j]){
    8000663a:	00093503          	ld	a0,0(s2)
    8000663e:	d965                	beqz	a0,8000662e <shm_put+0x3e>
            kfree((void*)shmt.obj[i].pa[j]);
    80006640:	c3afa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    80006644:	00093023          	sd	zero,0(s2)
    80006648:	b7dd                	j	8000662e <shm_put+0x3e>
          }
        }
        shmt.obj[i].used = 0;
    8000664a:	6785                	lui	a5,0x1
    8000664c:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006650:	02e484b3          	mul	s1,s1,a4
    80006654:	00245717          	auipc	a4,0x245
    80006658:	58c70713          	addi	a4,a4,1420 # 8024bbe0 <shmt>
    8000665c:	9726                	add	a4,a4,s1
    8000665e:	00072c23          	sw	zero,24(a4)
        shmt.obj[i].deleted = 0;
    80006662:	97ba                	add	a5,a5,a4
    80006664:	8207a623          	sw	zero,-2004(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    80006668:	00245517          	auipc	a0,0x245
    8000666c:	57850513          	addi	a0,a0,1400 # 8024bbe0 <shmt>
    80006670:	ec8fa0ef          	jal	ra,80000d38 <release>
}
    80006674:	70a2                	ld	ra,40(sp)
    80006676:	7402                	ld	s0,32(sp)
    80006678:	64e2                	ld	s1,24(sp)
    8000667a:	6942                	ld	s2,16(sp)
    8000667c:	69a2                	ld	s3,8(sp)
    8000667e:	6a02                	ld	s4,0(sp)
    80006680:	6145                	addi	sp,sp,48
    80006682:	8082                	ret
  for(int i=0;i<NSHM;i++){
    80006684:	2485                	addiw	s1,s1,1
    80006686:	97b6                	add	a5,a5,a3
    80006688:	fec480e3          	beq	s1,a2,80006668 <shm_put+0x78>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000668c:	4398                	lw	a4,0(a5)
    8000668e:	db7d                	beqz	a4,80006684 <shm_put+0x94>
    80006690:	43d8                	lw	a4,4(a5)
    80006692:	ff2719e3          	bne	a4,s2,80006684 <shm_put+0x94>
      if(shmt.obj[i].refcnt < 1)
    80006696:	6785                	lui	a5,0x1
    80006698:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000669c:	02d486b3          	mul	a3,s1,a3
    800066a0:	00245717          	auipc	a4,0x245
    800066a4:	54070713          	addi	a4,a4,1344 # 8024bbe0 <shmt>
    800066a8:	9736                	add	a4,a4,a3
    800066aa:	97ba                	add	a5,a5,a4
    800066ac:	8287a783          	lw	a5,-2008(a5)
    800066b0:	f6f059e3          	blez	a5,80006622 <shm_put+0x32>
      shmt.obj[i].refcnt--;
    800066b4:	37fd                	addiw	a5,a5,-1
    800066b6:	0007899b          	sext.w	s3,a5
    800066ba:	6705                	lui	a4,0x1
    800066bc:	81870613          	addi	a2,a4,-2024 # 818 <_entry-0x7ffff7e8>
    800066c0:	02c48633          	mul	a2,s1,a2
    800066c4:	00245697          	auipc	a3,0x245
    800066c8:	51c68693          	addi	a3,a3,1308 # 8024bbe0 <shmt>
    800066cc:	96b2                	add	a3,a3,a2
    800066ce:	9736                	add	a4,a4,a3
    800066d0:	82f72423          	sw	a5,-2008(a4)
      if(shmt.obj[i].refcnt == 0){
    800066d4:	f8099ae3          	bnez	s3,80006668 <shm_put+0x78>
        for(int j=0;j<shmt.obj[i].npages;j++){
    800066d8:	529c                	lw	a5,32(a3)
    800066da:	f6f058e3          	blez	a5,8000664a <shm_put+0x5a>
    800066de:	00245797          	auipc	a5,0x245
    800066e2:	52a78793          	addi	a5,a5,1322 # 8024bc08 <shmt+0x28>
    800066e6:	00f60933          	add	s2,a2,a5
    800066ea:	8a36                	mv	s4,a3
    800066ec:	b7b9                	j	8000663a <shm_put+0x4a>

00000000800066ee <shm_getpa>:

// 取某页的 pa；若未分配则分配（lazy），返回 pa 或 0
uint64
shm_getpa(int key, int page_index)
{
    800066ee:	7179                	addi	sp,sp,-48
    800066f0:	f406                	sd	ra,40(sp)
    800066f2:	f022                	sd	s0,32(sp)
    800066f4:	ec26                	sd	s1,24(sp)
    800066f6:	e84a                	sd	s2,16(sp)
    800066f8:	e44e                	sd	s3,8(sp)
    800066fa:	e052                	sd	s4,0(sp)
    800066fc:	1800                	addi	s0,sp,48
    800066fe:	892a                	mv	s2,a0
    80006700:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    80006702:	00245517          	auipc	a0,0x245
    80006706:	4de50513          	addi	a0,a0,1246 # 8024bbe0 <shmt>
    8000670a:	d96fa0ef          	jal	ra,80000ca0 <acquire>

  for(int i=0;i<NSHM;i++){
    8000670e:	00245797          	auipc	a5,0x245
    80006712:	4ea78793          	addi	a5,a5,1258 # 8024bbf8 <shmt+0x18>
    80006716:	4481                	li	s1,0
    80006718:	6685                	lui	a3,0x1
    8000671a:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000671e:	4641                	li	a2,16
    80006720:	a82d                	j	8000675a <shm_getpa+0x6c>
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
        pa = 0;
        break;
      }
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    80006722:	c88fa0ef          	jal	ra,80000baa <kalloc>
    80006726:	8a2a                	mv	s4,a0
        if(mem == 0){
    80006728:	cd41                	beqz	a0,800067c0 <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        memset(mem, 0, PGSIZE);
    8000672a:	6605                	lui	a2,0x1
    8000672c:	4581                	li	a1,0
    8000672e:	e46fa0ef          	jal	ra,80000d74 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    80006732:	00649793          	slli	a5,s1,0x6
    80006736:	97a6                	add	a5,a5,s1
    80006738:	078a                	slli	a5,a5,0x2
    8000673a:	8f85                	sub	a5,a5,s1
    8000673c:	97ce                	add	a5,a5,s3
    8000673e:	0791                	addi	a5,a5,4
    80006740:	078e                	slli	a5,a5,0x3
    80006742:	00245717          	auipc	a4,0x245
    80006746:	49e70713          	addi	a4,a4,1182 # 8024bbe0 <shmt>
    8000674a:	97ba                	add	a5,a5,a4
    8000674c:	0147b423          	sd	s4,8(a5)
    80006750:	a0b9                	j	8000679e <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    80006752:	2485                	addiw	s1,s1,1
    80006754:	97b6                	add	a5,a5,a3
    80006756:	06c48463          	beq	s1,a2,800067be <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000675a:	4398                	lw	a4,0(a5)
    8000675c:	db7d                	beqz	a4,80006752 <shm_getpa+0x64>
    8000675e:	43d8                	lw	a4,4(a5)
    80006760:	ff2719e3          	bne	a4,s2,80006752 <shm_getpa+0x64>
        pa = 0;
    80006764:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    80006766:	0409cd63          	bltz	s3,800067c0 <shm_getpa+0xd2>
    8000676a:	6785                	lui	a5,0x1
    8000676c:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006770:	02f487b3          	mul	a5,s1,a5
    80006774:	00245717          	auipc	a4,0x245
    80006778:	46c70713          	addi	a4,a4,1132 # 8024bbe0 <shmt>
    8000677c:	97ba                	add	a5,a5,a4
    8000677e:	539c                	lw	a5,32(a5)
    80006780:	04f9d063          	bge	s3,a5,800067c0 <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    80006784:	00649793          	slli	a5,s1,0x6
    80006788:	97a6                	add	a5,a5,s1
    8000678a:	078a                	slli	a5,a5,0x2
    8000678c:	8f85                	sub	a5,a5,s1
    8000678e:	97ce                	add	a5,a5,s3
    80006790:	0791                	addi	a5,a5,4
    80006792:	078e                	slli	a5,a5,0x3
    80006794:	97ba                	add	a5,a5,a4
    80006796:	0087b903          	ld	s2,8(a5)
    8000679a:	f80904e3          	beqz	s2,80006722 <shm_getpa+0x34>
      }
      pa = shmt.obj[i].pa[page_index];
    8000679e:	00649793          	slli	a5,s1,0x6
    800067a2:	97a6                	add	a5,a5,s1
    800067a4:	078a                	slli	a5,a5,0x2
    800067a6:	8f85                	sub	a5,a5,s1
    800067a8:	97ce                	add	a5,a5,s3
    800067aa:	0791                	addi	a5,a5,4
    800067ac:	078e                	slli	a5,a5,0x3
    800067ae:	00245717          	auipc	a4,0x245
    800067b2:	43270713          	addi	a4,a4,1074 # 8024bbe0 <shmt>
    800067b6:	97ba                	add	a5,a5,a4
    800067b8:	0087b903          	ld	s2,8(a5)
      break;
    800067bc:	a011                	j	800067c0 <shm_getpa+0xd2>
  uint64 pa = 0;
    800067be:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    800067c0:	00245517          	auipc	a0,0x245
    800067c4:	42050513          	addi	a0,a0,1056 # 8024bbe0 <shmt>
    800067c8:	d70fa0ef          	jal	ra,80000d38 <release>
  return pa;
}
    800067cc:	854a                	mv	a0,s2
    800067ce:	70a2                	ld	ra,40(sp)
    800067d0:	7402                	ld	s0,32(sp)
    800067d2:	64e2                	ld	s1,24(sp)
    800067d4:	6942                	ld	s2,16(sp)
    800067d6:	69a2                	ld	s3,8(sp)
    800067d8:	6a02                	ld	s4,0(sp)
    800067da:	6145                	addi	sp,sp,48
    800067dc:	8082                	ret

00000000800067de <shm_ctl>:


int
shm_ctl(int key, int cmd)
{
  if(cmd != IPC_RMID)
    800067de:	10059363          	bnez	a1,800068e4 <shm_ctl+0x106>
{
    800067e2:	7139                	addi	sp,sp,-64
    800067e4:	fc06                	sd	ra,56(sp)
    800067e6:	f822                	sd	s0,48(sp)
    800067e8:	f426                	sd	s1,40(sp)
    800067ea:	f04a                	sd	s2,32(sp)
    800067ec:	ec4e                	sd	s3,24(sp)
    800067ee:	e852                	sd	s4,16(sp)
    800067f0:	e456                	sd	s5,8(sp)
    800067f2:	0080                	addi	s0,sp,64
    800067f4:	892a                	mv	s2,a0
    800067f6:	89ae                	mv	s3,a1
    return -1;

  acquire(&shmt.lock);
    800067f8:	00245517          	auipc	a0,0x245
    800067fc:	3e850513          	addi	a0,a0,1000 # 8024bbe0 <shmt>
    80006800:	ca0fa0ef          	jal	ra,80000ca0 <acquire>

  for(int i = 0; i < NSHM; i++){
    80006804:	00245797          	auipc	a5,0x245
    80006808:	3f478793          	addi	a5,a5,1012 # 8024bbf8 <shmt+0x18>
    8000680c:	84ce                	mv	s1,s3
    8000680e:	6685                	lui	a3,0x1
    80006810:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006814:	4641                	li	a2,16
    80006816:	a8b1                	j	80006872 <shm_ctl+0x94>

      // 如果没人引用了，立刻释放
      if(shmt.obj[i].refcnt == 0){
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
    80006818:	a62fa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    8000681c:	00093023          	sd	zero,0(s2)
        for(int j = 0; j < shmt.obj[i].npages; j++){
    80006820:	2a05                	addiw	s4,s4,1
    80006822:	0921                	addi	s2,s2,8
    80006824:	020aa783          	lw	a5,32(s5)
    80006828:	00fa5663          	bge	s4,a5,80006834 <shm_ctl+0x56>
          if(shmt.obj[i].pa[j]){
    8000682c:	00093503          	ld	a0,0(s2)
    80006830:	d965                	beqz	a0,80006820 <shm_ctl+0x42>
    80006832:	b7dd                	j	80006818 <shm_ctl+0x3a>
          }
        }
        shmt.obj[i].used = 0;
    80006834:	6705                	lui	a4,0x1
    80006836:	81870793          	addi	a5,a4,-2024 # 818 <_entry-0x7ffff7e8>
    8000683a:	02f484b3          	mul	s1,s1,a5
    8000683e:	00245797          	auipc	a5,0x245
    80006842:	3a278793          	addi	a5,a5,930 # 8024bbe0 <shmt>
    80006846:	97a6                	add	a5,a5,s1
    80006848:	0007ac23          	sw	zero,24(a5)
        shmt.obj[i].deleted = 0;
    8000684c:	973e                	add	a4,a4,a5
    8000684e:	82072623          	sw	zero,-2004(a4)
        shmt.obj[i].key = 0;     
    80006852:	0007ae23          	sw	zero,28(a5)
        shmt.obj[i].npages = 0;  
    80006856:	0207a023          	sw	zero,32(a5)

      }


      release(&shmt.lock);
    8000685a:	00245517          	auipc	a0,0x245
    8000685e:	38650513          	addi	a0,a0,902 # 8024bbe0 <shmt>
    80006862:	cd6fa0ef          	jal	ra,80000d38 <release>
      return 0;
    80006866:	854e                	mv	a0,s3
    80006868:	a0ad                	j	800068d2 <shm_ctl+0xf4>
  for(int i = 0; i < NSHM; i++){
    8000686a:	2485                	addiw	s1,s1,1
    8000686c:	97b6                	add	a5,a5,a3
    8000686e:	04c48b63          	beq	s1,a2,800068c4 <shm_ctl+0xe6>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006872:	4398                	lw	a4,0(a5)
    80006874:	db7d                	beqz	a4,8000686a <shm_ctl+0x8c>
    80006876:	43d8                	lw	a4,4(a5)
    80006878:	ff2719e3          	bne	a4,s2,8000686a <shm_ctl+0x8c>
      shmt.obj[i].deleted = 1;
    8000687c:	6785                	lui	a5,0x1
    8000687e:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006882:	02d486b3          	mul	a3,s1,a3
    80006886:	00245717          	auipc	a4,0x245
    8000688a:	35a70713          	addi	a4,a4,858 # 8024bbe0 <shmt>
    8000688e:	9736                	add	a4,a4,a3
    80006890:	97ba                	add	a5,a5,a4
    80006892:	4705                	li	a4,1
    80006894:	82e7a623          	sw	a4,-2004(a5)
      if(shmt.obj[i].refcnt == 0){
    80006898:	8287aa03          	lw	s4,-2008(a5)
    8000689c:	fa0a1fe3          	bnez	s4,8000685a <shm_ctl+0x7c>
        for(int j = 0; j < shmt.obj[i].npages; j++){
    800068a0:	00245717          	auipc	a4,0x245
    800068a4:	34070713          	addi	a4,a4,832 # 8024bbe0 <shmt>
    800068a8:	00d707b3          	add	a5,a4,a3
    800068ac:	539c                	lw	a5,32(a5)
    800068ae:	f8f053e3          	blez	a5,80006834 <shm_ctl+0x56>
    800068b2:	00245797          	auipc	a5,0x245
    800068b6:	35678793          	addi	a5,a5,854 # 8024bc08 <shmt+0x28>
    800068ba:	00f68933          	add	s2,a3,a5
    800068be:	00d70ab3          	add	s5,a4,a3
    800068c2:	b7ad                	j	8000682c <shm_ctl+0x4e>
    }
  }

  release(&shmt.lock);
    800068c4:	00245517          	auipc	a0,0x245
    800068c8:	31c50513          	addi	a0,a0,796 # 8024bbe0 <shmt>
    800068cc:	c6cfa0ef          	jal	ra,80000d38 <release>
  return -1; // key 不存在
    800068d0:	557d                	li	a0,-1
}
    800068d2:	70e2                	ld	ra,56(sp)
    800068d4:	7442                	ld	s0,48(sp)
    800068d6:	74a2                	ld	s1,40(sp)
    800068d8:	7902                	ld	s2,32(sp)
    800068da:	69e2                	ld	s3,24(sp)
    800068dc:	6a42                	ld	s4,16(sp)
    800068de:	6aa2                	ld	s5,8(sp)
    800068e0:	6121                	addi	sp,sp,64
    800068e2:	8082                	ret
    return -1;
    800068e4:	557d                	li	a0,-1
}
    800068e6:	8082                	ret

00000000800068e8 <shm_is_deleted>:

int
shm_is_deleted(int key)
{
    800068e8:	1101                	addi	sp,sp,-32
    800068ea:	ec06                	sd	ra,24(sp)
    800068ec:	e822                	sd	s0,16(sp)
    800068ee:	e426                	sd	s1,8(sp)
    800068f0:	1000                	addi	s0,sp,32
    800068f2:	84aa                	mv	s1,a0
  int del = 0; // 默认0,不存在就允许创建
  acquire(&shmt.lock);
    800068f4:	00245517          	auipc	a0,0x245
    800068f8:	2ec50513          	addi	a0,a0,748 # 8024bbe0 <shmt>
    800068fc:	ba4fa0ef          	jal	ra,80000ca0 <acquire>
  for(int i=0;i<NSHM;i++){
    80006900:	00245797          	auipc	a5,0x245
    80006904:	2f878793          	addi	a5,a5,760 # 8024bbf8 <shmt+0x18>
    80006908:	4701                	li	a4,0
    8000690a:	6605                	lui	a2,0x1
    8000690c:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006910:	45c1                	li	a1,16
    80006912:	a029                	j	8000691c <shm_is_deleted+0x34>
    80006914:	2705                	addiw	a4,a4,1
    80006916:	97b2                	add	a5,a5,a2
    80006918:	02b70563          	beq	a4,a1,80006942 <shm_is_deleted+0x5a>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000691c:	4394                	lw	a3,0(a5)
    8000691e:	dafd                	beqz	a3,80006914 <shm_is_deleted+0x2c>
    80006920:	43d4                	lw	a3,4(a5)
    80006922:	fe9699e3          	bne	a3,s1,80006914 <shm_is_deleted+0x2c>
      del = shmt.obj[i].deleted;
    80006926:	6785                	lui	a5,0x1
    80006928:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000692c:	02d70733          	mul	a4,a4,a3
    80006930:	00245697          	auipc	a3,0x245
    80006934:	2b068693          	addi	a3,a3,688 # 8024bbe0 <shmt>
    80006938:	9736                	add	a4,a4,a3
    8000693a:	97ba                	add	a5,a5,a4
    8000693c:	82c7a483          	lw	s1,-2004(a5)
      break;
    80006940:	a011                	j	80006944 <shm_is_deleted+0x5c>
  int del = 0; // 默认0,不存在就允许创建
    80006942:	4481                	li	s1,0
    }
  }
  release(&shmt.lock);
    80006944:	00245517          	auipc	a0,0x245
    80006948:	29c50513          	addi	a0,a0,668 # 8024bbe0 <shmt>
    8000694c:	becfa0ef          	jal	ra,80000d38 <release>
  //shm_dump(key);
  return del;

}
    80006950:	8526                	mv	a0,s1
    80006952:	60e2                	ld	ra,24(sp)
    80006954:	6442                	ld	s0,16(sp)
    80006956:	64a2                	ld	s1,8(sp)
    80006958:	6105                	addi	sp,sp,32
    8000695a:	8082                	ret
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
