
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
    80000004:	89813103          	ld	sp,-1896(sp) # 80008898 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdaa64f>
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
    8000010a:	6dc020ef          	jal	ra,800027e6 <either_copyin>
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
    80000176:	76e50513          	addi	a0,a0,1902 # 800108e0 <cons>
    8000017a:	327000ef          	jal	ra,80000ca0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	76248493          	addi	s1,s1,1890 # 800108e0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	7f290913          	addi	s2,s2,2034 # 80010978 <cons+0x98>
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
    800001a4:	1ad010ef          	jal	ra,80001b50 <myproc>
    800001a8:	4d0020ef          	jal	ra,80002678 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	28e020ef          	jal	ra,80002440 <sleep>
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
    800001ea:	5b2020ef          	jal	ra,8000279c <either_copyout>
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
    800001fe:	6e650513          	addi	a0,a0,1766 # 800108e0 <cons>
    80000202:	337000ef          	jal	ra,80000d38 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	6d450513          	addi	a0,a0,1748 # 800108e0 <cons>
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
    80000242:	72f72d23          	sw	a5,1850(a4) # 80010978 <cons+0x98>
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
    8000028c:	65850513          	addi	a0,a0,1624 # 800108e0 <cons>
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
    800002aa:	586020ef          	jal	ra,80002830 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	63250513          	addi	a0,a0,1586 # 800108e0 <cons>
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
    800002d2:	61270713          	addi	a4,a4,1554 # 800108e0 <cons>
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
    800002f8:	5ec78793          	addi	a5,a5,1516 # 800108e0 <cons>
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
    80000326:	6567a783          	lw	a5,1622(a5) # 80010978 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	5aa70713          	addi	a4,a4,1450 # 800108e0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	59a48493          	addi	s1,s1,1434 # 800108e0 <cons>
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
    80000382:	56270713          	addi	a4,a4,1378 # 800108e0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	5ef72623          	sw	a5,1516(a4) # 80010980 <cons+0xa0>
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
    800003b6:	52e78793          	addi	a5,a5,1326 # 800108e0 <cons>
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
    800003da:	5ac7a323          	sw	a2,1446(a5) # 8001097c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	59a50513          	addi	a0,a0,1434 # 80010978 <cons+0x98>
    800003e6:	0a6020ef          	jal	ra,8000248c <wakeup>
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
    80000400:	4e450513          	addi	a0,a0,1252 # 800108e0 <cons>
    80000404:	01d000ef          	jal	ra,80000c20 <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0024a797          	auipc	a5,0x24a
    80000410:	65c78793          	addi	a5,a5,1628 # 8024aa68 <devsw>
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
    800004f8:	3c07a783          	lw	a5,960(a5) # 800088b4 <panicking>
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
    80000536:	45650513          	addi	a0,a0,1110 # 80010988 <pr>
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
    80000754:	1647a783          	lw	a5,356(a5) # 800088b4 <panicking>
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
    8000077e:	20e50513          	addi	a0,a0,526 # 80010988 <pr>
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
    8000079c:	1127ae23          	sw	s2,284(a5) # 800088b4 <panicking>
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
    800007be:	0f27ab23          	sw	s2,246(a5) # 800088b0 <panicked>
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
    800007d8:	1b450513          	addi	a0,a0,436 # 80010988 <pr>
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
    80000824:	18050513          	addi	a0,a0,384 # 800109a0 <tx_lock>
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
    80000852:	15250513          	addi	a0,a0,338 # 800109a0 <tx_lock>
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
    80000872:	04e48493          	addi	s1,s1,78 # 800088bc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	00010997          	auipc	s3,0x10
    8000087a:	12a98993          	addi	s3,s3,298 # 800109a0 <tx_lock>
    8000087e:	00008917          	auipc	s2,0x8
    80000882:	03a90913          	addi	s2,s2,58 # 800088b8 <tx_chan>
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
    80000892:	3af010ef          	jal	ra,80002440 <sleep>
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
    800008b6:	0ee50513          	addi	a0,a0,238 # 800109a0 <tx_lock>
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
    800008e4:	fd47a783          	lw	a5,-44(a5) # 800088b4 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	fc67a783          	lw	a5,-58(a5) # 800088b0 <panicked>
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
    8000091a:	f9e7a783          	lw	a5,-98(a5) # 800088b4 <panicking>
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
    8000096a:	03a50513          	addi	a0,a0,58 # 800109a0 <tx_lock>
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
    80000980:	02450513          	addi	a0,a0,36 # 800109a0 <tx_lock>
    80000984:	3b4000ef          	jal	ra,80000d38 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00008797          	auipc	a5,0x8
    80000990:	f207a823          	sw	zero,-208(a5) # 800088bc <tx_busy>
    wakeup(&tx_chan);
    80000994:	00008517          	auipc	a0,0x8
    80000998:	f2450513          	addi	a0,a0,-220 # 800088b8 <tx_chan>
    8000099c:	2f1010ef          	jal	ra,8000248c <wakeup>
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
    800009c8:	01450513          	addi	a0,a0,20 # 800109d8 <kref>
    800009cc:	2d4000ef          	jal	ra,80000ca0 <acquire>
  n = kref.refcnt[PA2IDX(pa)];
    800009d0:	00010517          	auipc	a0,0x10
    800009d4:	00850513          	addi	a0,a0,8 # 800109d8 <kref>
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
    80000a02:	fda50513          	addi	a0,a0,-38 # 800109d8 <kref>
    80000a06:	29a000ef          	jal	ra,80000ca0 <acquire>
  n = ++kref.refcnt[PA2IDX(pa)];
    80000a0a:	00c4d793          	srli	a5,s1,0xc
    80000a0e:	00010517          	auipc	a0,0x10
    80000a12:	fca50513          	addi	a0,a0,-54 # 800109d8 <kref>
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
    80000a46:	f9650513          	addi	a0,a0,-106 # 800109d8 <kref>
    80000a4a:	256000ef          	jal	ra,80000ca0 <acquire>
  n = --kref.refcnt[PA2IDX(pa)];
    80000a4e:	00c4d793          	srli	a5,s1,0xc
    80000a52:	00010517          	auipc	a0,0x10
    80000a56:	f8650513          	addi	a0,a0,-122 # 800109d8 <kref>
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
    80000a92:	72278793          	addi	a5,a5,1826 # 802541b0 <end>
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
    80000ad0:	eec90913          	addi	s2,s2,-276 # 800109b8 <kmem>
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
    80000b1a:	ec290913          	addi	s2,s2,-318 # 800109d8 <kref>
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
    80000b76:	e4650513          	addi	a0,a0,-442 # 800109b8 <kmem>
    80000b7a:	0a6000ef          	jal	ra,80000c20 <initlock>
  initlock(&kref.lock, "kref");
    80000b7e:	00007597          	auipc	a1,0x7
    80000b82:	4ea58593          	addi	a1,a1,1258 # 80008068 <digits+0x30>
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	e5250513          	addi	a0,a0,-430 # 800109d8 <kref>
    80000b8e:	092000ef          	jal	ra,80000c20 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b92:	45c5                	li	a1,17
    80000b94:	05ee                	slli	a1,a1,0x1b
    80000b96:	00253517          	auipc	a0,0x253
    80000b9a:	61a50513          	addi	a0,a0,1562 # 802541b0 <end>
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
    80000bb8:	e0448493          	addi	s1,s1,-508 # 800109b8 <kmem>
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	0e2000ef          	jal	ra,80000ca0 <acquire>
  r = kmem.freelist;
    80000bc2:	6c84                	ld	s1,24(s1)
  if(r)
    80000bc4:	c4b9                	beqz	s1,80000c12 <kalloc+0x68>
    kmem.freelist = r->next;
    80000bc6:	609c                	ld	a5,0(s1)
    80000bc8:	00010517          	auipc	a0,0x10
    80000bcc:	df050513          	addi	a0,a0,-528 # 800109b8 <kmem>
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
    80000be4:	df850513          	addi	a0,a0,-520 # 800109d8 <kref>
    80000be8:	0b8000ef          	jal	ra,80000ca0 <acquire>
  kref.refcnt[PA2IDX(r)] = 1;
    80000bec:	00010517          	auipc	a0,0x10
    80000bf0:	dec50513          	addi	a0,a0,-532 # 800109d8 <kref>
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
    80000c16:	da650513          	addi	a0,a0,-602 # 800109b8 <kmem>
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
    80000c4a:	6eb000ef          	jal	ra,80001b34 <mycpu>
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
    80000c78:	6bd000ef          	jal	ra,80001b34 <mycpu>
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	cb99                	beqz	a5,80000c94 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c80:	6b5000ef          	jal	ra,80001b34 <mycpu>
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
    80000c94:	6a1000ef          	jal	ra,80001b34 <mycpu>
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
    80000cc8:	66d000ef          	jal	ra,80001b34 <mycpu>
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
    80000cec:	649000ef          	jal	ra,80001b34 <mycpu>
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
    80000de8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fdaae51>
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
    80000f1e:	407000ef          	jal	ra,80001b24 <cpuid>
    seminit();

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f22:	00008717          	auipc	a4,0x8
    80000f26:	99e70713          	addi	a4,a4,-1634 # 800088c0 <started>
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
    80000f36:	3ef000ef          	jal	ra,80001b24 <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	17c50513          	addi	a0,a0,380 # 800080b8 <digits+0x80>
    80000f44:	d7eff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000f48:	088000ef          	jal	ra,80000fd0 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	217010ef          	jal	ra,80002962 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f50:	034050ef          	jal	ra,80005f84 <plicinithart>
  }

  scheduler();        
    80000f54:	354010ef          	jal	ra,800022a8 <scheduler>
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
    80000f88:	2d2000ef          	jal	ra,8000125a <kvminit>
    kvminithart();   // turn on paging
    80000f8c:	044000ef          	jal	ra,80000fd0 <kvminithart>
    procinit();      // process table
    80000f90:	2ed000ef          	jal	ra,80001a7c <procinit>
    trapinit();      // trap vectors
    80000f94:	1ab010ef          	jal	ra,8000293e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	1cb010ef          	jal	ra,80002962 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9c:	7d3040ef          	jal	ra,80005f6e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa0:	7e5040ef          	jal	ra,80005f84 <plicinithart>
    binit();         // buffer cache
    80000fa4:	712020ef          	jal	ra,800036b6 <binit>
    iinit();         // inode table
    80000fa8:	483020ef          	jal	ra,80003c2a <iinit>
    fileinit();      // file table
    80000fac:	36b030ef          	jal	ra,80004b16 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	0c4050ef          	jal	ra,80006074 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	0ba010ef          	jal	ra,8000206e <userinit>
    shm_init();
    80000fb8:	530050ef          	jal	ra,800064e8 <shm_init>
    seminit();
    80000fbc:	235050ef          	jal	ra,800069f0 <seminit>
    __sync_synchronize();
    80000fc0:	0ff0000f          	fence
    started = 1;
    80000fc4:	4785                	li	a5,1
    80000fc6:	00008717          	auipc	a4,0x8
    80000fca:	8ef72d23          	sw	a5,-1798(a4) # 800088c0 <started>
    80000fce:	b759                	j	80000f54 <main+0x3e>

0000000080000fd0 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000fd0:	1141                	addi	sp,sp,-16
    80000fd2:	e422                	sd	s0,8(sp)
    80000fd4:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fd6:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fda:	00008797          	auipc	a5,0x8
    80000fde:	8ee7b783          	ld	a5,-1810(a5) # 800088c8 <kernel_pagetable>
    80000fe2:	83b1                	srli	a5,a5,0xc
    80000fe4:	577d                	li	a4,-1
    80000fe6:	177e                	slli	a4,a4,0x3f
    80000fe8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fea:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ff2:	6422                	ld	s0,8(sp)
    80000ff4:	0141                	addi	sp,sp,16
    80000ff6:	8082                	ret

0000000080000ff8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ff8:	7139                	addi	sp,sp,-64
    80000ffa:	fc06                	sd	ra,56(sp)
    80000ffc:	f822                	sd	s0,48(sp)
    80000ffe:	f426                	sd	s1,40(sp)
    80001000:	f04a                	sd	s2,32(sp)
    80001002:	ec4e                	sd	s3,24(sp)
    80001004:	e852                	sd	s4,16(sp)
    80001006:	e456                	sd	s5,8(sp)
    80001008:	e05a                	sd	s6,0(sp)
    8000100a:	0080                	addi	s0,sp,64
    8000100c:	84aa                	mv	s1,a0
    8000100e:	89ae                	mv	s3,a1
    80001010:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001012:	57fd                	li	a5,-1
    80001014:	83e9                	srli	a5,a5,0x1a
    80001016:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001018:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000101a:	02b7fc63          	bgeu	a5,a1,80001052 <walk+0x5a>
    panic("walk");
    8000101e:	00007517          	auipc	a0,0x7
    80001022:	0b250513          	addi	a0,a0,178 # 800080d0 <digits+0x98>
    80001026:	f62ff0ef          	jal	ra,80000788 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000102a:	060a8263          	beqz	s5,8000108e <walk+0x96>
    8000102e:	b7dff0ef          	jal	ra,80000baa <kalloc>
    80001032:	84aa                	mv	s1,a0
    80001034:	c139                	beqz	a0,8000107a <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001036:	6605                	lui	a2,0x1
    80001038:	4581                	li	a1,0
    8000103a:	d3bff0ef          	jal	ra,80000d74 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000103e:	00c4d793          	srli	a5,s1,0xc
    80001042:	07aa                	slli	a5,a5,0xa
    80001044:	0017e793          	ori	a5,a5,1
    80001048:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000104c:	3a5d                	addiw	s4,s4,-9 # 1ff7 <_entry-0x7fffe009>
    8000104e:	036a0063          	beq	s4,s6,8000106e <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001052:	0149d933          	srl	s2,s3,s4
    80001056:	1ff97913          	andi	s2,s2,511
    8000105a:	090e                	slli	s2,s2,0x3
    8000105c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000105e:	00093483          	ld	s1,0(s2)
    80001062:	0014f793          	andi	a5,s1,1
    80001066:	d3f1                	beqz	a5,8000102a <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001068:	80a9                	srli	s1,s1,0xa
    8000106a:	04b2                	slli	s1,s1,0xc
    8000106c:	b7c5                	j	8000104c <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    8000106e:	00c9d513          	srli	a0,s3,0xc
    80001072:	1ff57513          	andi	a0,a0,511
    80001076:	050e                	slli	a0,a0,0x3
    80001078:	9526                	add	a0,a0,s1
}
    8000107a:	70e2                	ld	ra,56(sp)
    8000107c:	7442                	ld	s0,48(sp)
    8000107e:	74a2                	ld	s1,40(sp)
    80001080:	7902                	ld	s2,32(sp)
    80001082:	69e2                	ld	s3,24(sp)
    80001084:	6a42                	ld	s4,16(sp)
    80001086:	6aa2                	ld	s5,8(sp)
    80001088:	6b02                	ld	s6,0(sp)
    8000108a:	6121                	addi	sp,sp,64
    8000108c:	8082                	ret
        return 0;
    8000108e:	4501                	li	a0,0
    80001090:	b7ed                	j	8000107a <walk+0x82>

0000000080001092 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001092:	57fd                	li	a5,-1
    80001094:	83e9                	srli	a5,a5,0x1a
    80001096:	00b7f463          	bgeu	a5,a1,8000109e <walkaddr+0xc>
    return 0;
    8000109a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000109c:	8082                	ret
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010a6:	4601                	li	a2,0
    800010a8:	f51ff0ef          	jal	ra,80000ff8 <walk>
  if(pte == 0)
    800010ac:	c105                	beqz	a0,800010cc <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800010ae:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010b0:	0117f693          	andi	a3,a5,17
    800010b4:	4745                	li	a4,17
    return 0;
    800010b6:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010b8:	00e68663          	beq	a3,a4,800010c4 <walkaddr+0x32>
}
    800010bc:	60a2                	ld	ra,8(sp)
    800010be:	6402                	ld	s0,0(sp)
    800010c0:	0141                	addi	sp,sp,16
    800010c2:	8082                	ret
  pa = PTE2PA(*pte);
    800010c4:	83a9                	srli	a5,a5,0xa
    800010c6:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010ca:	bfcd                	j	800010bc <walkaddr+0x2a>
    return 0;
    800010cc:	4501                	li	a0,0
    800010ce:	b7fd                	j	800010bc <walkaddr+0x2a>

00000000800010d0 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010d0:	715d                	addi	sp,sp,-80
    800010d2:	e486                	sd	ra,72(sp)
    800010d4:	e0a2                	sd	s0,64(sp)
    800010d6:	fc26                	sd	s1,56(sp)
    800010d8:	f84a                	sd	s2,48(sp)
    800010da:	f44e                	sd	s3,40(sp)
    800010dc:	f052                	sd	s4,32(sp)
    800010de:	ec56                	sd	s5,24(sp)
    800010e0:	e85a                	sd	s6,16(sp)
    800010e2:	e45e                	sd	s7,8(sp)
    800010e4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010e6:	03459793          	slli	a5,a1,0x34
    800010ea:	e7a9                	bnez	a5,80001134 <mappages+0x64>
    800010ec:	8aaa                	mv	s5,a0
    800010ee:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800010f0:	03461793          	slli	a5,a2,0x34
    800010f4:	e7b1                	bnez	a5,80001140 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800010f6:	ca39                	beqz	a2,8000114c <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800010f8:	77fd                	lui	a5,0xfffff
    800010fa:	963e                	add	a2,a2,a5
    800010fc:	00b609b3          	add	s3,a2,a1
  a = va;
    80001100:	892e                	mv	s2,a1
    80001102:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001106:	6b85                	lui	s7,0x1
    80001108:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110c:	4605                	li	a2,1
    8000110e:	85ca                	mv	a1,s2
    80001110:	8556                	mv	a0,s5
    80001112:	ee7ff0ef          	jal	ra,80000ff8 <walk>
    80001116:	c539                	beqz	a0,80001164 <mappages+0x94>
    if(*pte & PTE_V)
    80001118:	611c                	ld	a5,0(a0)
    8000111a:	8b85                	andi	a5,a5,1
    8000111c:	ef95                	bnez	a5,80001158 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000111e:	80b1                	srli	s1,s1,0xc
    80001120:	04aa                	slli	s1,s1,0xa
    80001122:	0164e4b3          	or	s1,s1,s6
    80001126:	0014e493          	ori	s1,s1,1
    8000112a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000112c:	05390863          	beq	s2,s3,8000117c <mappages+0xac>
    a += PGSIZE;
    80001130:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001132:	bfd9                	j	80001108 <mappages+0x38>
    panic("mappages: va not aligned");
    80001134:	00007517          	auipc	a0,0x7
    80001138:	fa450513          	addi	a0,a0,-92 # 800080d8 <digits+0xa0>
    8000113c:	e4cff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size not aligned");
    80001140:	00007517          	auipc	a0,0x7
    80001144:	fb850513          	addi	a0,a0,-72 # 800080f8 <digits+0xc0>
    80001148:	e40ff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size");
    8000114c:	00007517          	auipc	a0,0x7
    80001150:	fcc50513          	addi	a0,a0,-52 # 80008118 <digits+0xe0>
    80001154:	e34ff0ef          	jal	ra,80000788 <panic>
      panic("mappages: remap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fd050513          	addi	a0,a0,-48 # 80008128 <digits+0xf0>
    80001160:	e28ff0ef          	jal	ra,80000788 <panic>
      return -1;
    80001164:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001166:	60a6                	ld	ra,72(sp)
    80001168:	6406                	ld	s0,64(sp)
    8000116a:	74e2                	ld	s1,56(sp)
    8000116c:	7942                	ld	s2,48(sp)
    8000116e:	79a2                	ld	s3,40(sp)
    80001170:	7a02                	ld	s4,32(sp)
    80001172:	6ae2                	ld	s5,24(sp)
    80001174:	6b42                	ld	s6,16(sp)
    80001176:	6ba2                	ld	s7,8(sp)
    80001178:	6161                	addi	sp,sp,80
    8000117a:	8082                	ret
  return 0;
    8000117c:	4501                	li	a0,0
    8000117e:	b7e5                	j	80001166 <mappages+0x96>

0000000080001180 <kvmmap>:
{
    80001180:	1141                	addi	sp,sp,-16
    80001182:	e406                	sd	ra,8(sp)
    80001184:	e022                	sd	s0,0(sp)
    80001186:	0800                	addi	s0,sp,16
    80001188:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000118a:	86b2                	mv	a3,a2
    8000118c:	863e                	mv	a2,a5
    8000118e:	f43ff0ef          	jal	ra,800010d0 <mappages>
    80001192:	e509                	bnez	a0,8000119c <kvmmap+0x1c>
}
    80001194:	60a2                	ld	ra,8(sp)
    80001196:	6402                	ld	s0,0(sp)
    80001198:	0141                	addi	sp,sp,16
    8000119a:	8082                	ret
    panic("kvmmap");
    8000119c:	00007517          	auipc	a0,0x7
    800011a0:	f9c50513          	addi	a0,a0,-100 # 80008138 <digits+0x100>
    800011a4:	de4ff0ef          	jal	ra,80000788 <panic>

00000000800011a8 <kvmmake>:
{
    800011a8:	1101                	addi	sp,sp,-32
    800011aa:	ec06                	sd	ra,24(sp)
    800011ac:	e822                	sd	s0,16(sp)
    800011ae:	e426                	sd	s1,8(sp)
    800011b0:	e04a                	sd	s2,0(sp)
    800011b2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011b4:	9f7ff0ef          	jal	ra,80000baa <kalloc>
    800011b8:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011ba:	6605                	lui	a2,0x1
    800011bc:	4581                	li	a1,0
    800011be:	bb7ff0ef          	jal	ra,80000d74 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011c2:	4719                	li	a4,6
    800011c4:	6685                	lui	a3,0x1
    800011c6:	10000637          	lui	a2,0x10000
    800011ca:	100005b7          	lui	a1,0x10000
    800011ce:	8526                	mv	a0,s1
    800011d0:	fb1ff0ef          	jal	ra,80001180 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	6685                	lui	a3,0x1
    800011d8:	10001637          	lui	a2,0x10001
    800011dc:	100015b7          	lui	a1,0x10001
    800011e0:	8526                	mv	a0,s1
    800011e2:	f9fff0ef          	jal	ra,80001180 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011e6:	4719                	li	a4,6
    800011e8:	040006b7          	lui	a3,0x4000
    800011ec:	0c000637          	lui	a2,0xc000
    800011f0:	0c0005b7          	lui	a1,0xc000
    800011f4:	8526                	mv	a0,s1
    800011f6:	f8bff0ef          	jal	ra,80001180 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011fa:	00007917          	auipc	s2,0x7
    800011fe:	e0690913          	addi	s2,s2,-506 # 80008000 <etext>
    80001202:	4729                	li	a4,10
    80001204:	80007697          	auipc	a3,0x80007
    80001208:	dfc68693          	addi	a3,a3,-516 # 8000 <_entry-0x7fff8000>
    8000120c:	4605                	li	a2,1
    8000120e:	067e                	slli	a2,a2,0x1f
    80001210:	85b2                	mv	a1,a2
    80001212:	8526                	mv	a0,s1
    80001214:	f6dff0ef          	jal	ra,80001180 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001218:	4719                	li	a4,6
    8000121a:	46c5                	li	a3,17
    8000121c:	06ee                	slli	a3,a3,0x1b
    8000121e:	412686b3          	sub	a3,a3,s2
    80001222:	864a                	mv	a2,s2
    80001224:	85ca                	mv	a1,s2
    80001226:	8526                	mv	a0,s1
    80001228:	f59ff0ef          	jal	ra,80001180 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122c:	4729                	li	a4,10
    8000122e:	6685                	lui	a3,0x1
    80001230:	00006617          	auipc	a2,0x6
    80001234:	dd060613          	addi	a2,a2,-560 # 80007000 <_trampoline>
    80001238:	040005b7          	lui	a1,0x4000
    8000123c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000123e:	05b2                	slli	a1,a1,0xc
    80001240:	8526                	mv	a0,s1
    80001242:	f3fff0ef          	jal	ra,80001180 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001246:	8526                	mv	a0,s1
    80001248:	7aa000ef          	jal	ra,800019f2 <proc_mapstacks>
}
    8000124c:	8526                	mv	a0,s1
    8000124e:	60e2                	ld	ra,24(sp)
    80001250:	6442                	ld	s0,16(sp)
    80001252:	64a2                	ld	s1,8(sp)
    80001254:	6902                	ld	s2,0(sp)
    80001256:	6105                	addi	sp,sp,32
    80001258:	8082                	ret

000000008000125a <kvminit>:
{
    8000125a:	1141                	addi	sp,sp,-16
    8000125c:	e406                	sd	ra,8(sp)
    8000125e:	e022                	sd	s0,0(sp)
    80001260:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001262:	f47ff0ef          	jal	ra,800011a8 <kvmmake>
    80001266:	00007797          	auipc	a5,0x7
    8000126a:	66a7b123          	sd	a0,1634(a5) # 800088c8 <kernel_pagetable>
}
    8000126e:	60a2                	ld	ra,8(sp)
    80001270:	6402                	ld	s0,0(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	92bff0ef          	jal	ra,80000baa <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	ae9ff0ef          	jal	ra,80000d74 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000129c:	7139                	addi	sp,sp,-64
    8000129e:	fc06                	sd	ra,56(sp)
    800012a0:	f822                	sd	s0,48(sp)
    800012a2:	f426                	sd	s1,40(sp)
    800012a4:	f04a                	sd	s2,32(sp)
    800012a6:	ec4e                	sd	s3,24(sp)
    800012a8:	e852                	sd	s4,16(sp)
    800012aa:	e456                	sd	s5,8(sp)
    800012ac:	e05a                	sd	s6,0(sp)
    800012ae:	0080                	addi	s0,sp,64
  
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012b0:	03459793          	slli	a5,a1,0x34
    800012b4:	e785                	bnez	a5,800012dc <uvmunmap+0x40>
    800012b6:	8a2a                	mv	s4,a0
    800012b8:	892e                	mv	s2,a1
    800012ba:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012bc:	0632                	slli	a2,a2,0xc
    800012be:	00b609b3          	add	s3,a2,a1
    800012c2:	6b05                	lui	s6,0x1
    800012c4:	0335e763          	bltu	a1,s3,800012f2 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012c8:	70e2                	ld	ra,56(sp)
    800012ca:	7442                	ld	s0,48(sp)
    800012cc:	74a2                	ld	s1,40(sp)
    800012ce:	7902                	ld	s2,32(sp)
    800012d0:	69e2                	ld	s3,24(sp)
    800012d2:	6a42                	ld	s4,16(sp)
    800012d4:	6aa2                	ld	s5,8(sp)
    800012d6:	6b02                	ld	s6,0(sp)
    800012d8:	6121                	addi	sp,sp,64
    800012da:	8082                	ret
    panic("uvmunmap: not aligned");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e6450513          	addi	a0,a0,-412 # 80008140 <digits+0x108>
    800012e4:	ca4ff0ef          	jal	ra,80000788 <panic>
    *pte = 0;
    800012e8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ec:	995a                	add	s2,s2,s6
    800012ee:	fd397de3          	bgeu	s2,s3,800012c8 <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800012f2:	4601                	li	a2,0
    800012f4:	85ca                	mv	a1,s2
    800012f6:	8552                	mv	a0,s4
    800012f8:	d01ff0ef          	jal	ra,80000ff8 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d57d                	beqz	a0,800012ec <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001300:	611c                	ld	a5,0(a0)
    80001302:	0017f713          	andi	a4,a5,1
    80001306:	d37d                	beqz	a4,800012ec <uvmunmap+0x50>
    if(do_free){
    80001308:	fe0a80e3          	beqz	s5,800012e8 <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    8000130c:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000130e:	00c79513          	slli	a0,a5,0xc
    80001312:	f68ff0ef          	jal	ra,80000a7a <kfree>
    80001316:	bfc9                	j	800012e8 <uvmunmap+0x4c>

0000000080001318 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001318:	1101                	addi	sp,sp,-32
    8000131a:	ec06                	sd	ra,24(sp)
    8000131c:	e822                	sd	s0,16(sp)
    8000131e:	e426                	sd	s1,8(sp)
    80001320:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001322:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001324:	00b67d63          	bgeu	a2,a1,8000133e <uvmdealloc+0x26>
    80001328:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000132a:	6785                	lui	a5,0x1
    8000132c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000132e:	00f60733          	add	a4,a2,a5
    80001332:	76fd                	lui	a3,0xfffff
    80001334:	8f75                	and	a4,a4,a3
    80001336:	97ae                	add	a5,a5,a1
    80001338:	8ff5                	and	a5,a5,a3
    8000133a:	00f76863          	bltu	a4,a5,8000134a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000133e:	8526                	mv	a0,s1
    80001340:	60e2                	ld	ra,24(sp)
    80001342:	6442                	ld	s0,16(sp)
    80001344:	64a2                	ld	s1,8(sp)
    80001346:	6105                	addi	sp,sp,32
    80001348:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000134a:	8f99                	sub	a5,a5,a4
    8000134c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000134e:	4685                	li	a3,1
    80001350:	0007861b          	sext.w	a2,a5
    80001354:	85ba                	mv	a1,a4
    80001356:	f47ff0ef          	jal	ra,8000129c <uvmunmap>
    8000135a:	b7d5                	j	8000133e <uvmdealloc+0x26>

000000008000135c <uvmalloc>:
  if(newsz < oldsz)
    8000135c:	08b66963          	bltu	a2,a1,800013ee <uvmalloc+0x92>
{
    80001360:	7139                	addi	sp,sp,-64
    80001362:	fc06                	sd	ra,56(sp)
    80001364:	f822                	sd	s0,48(sp)
    80001366:	f426                	sd	s1,40(sp)
    80001368:	f04a                	sd	s2,32(sp)
    8000136a:	ec4e                	sd	s3,24(sp)
    8000136c:	e852                	sd	s4,16(sp)
    8000136e:	e456                	sd	s5,8(sp)
    80001370:	e05a                	sd	s6,0(sp)
    80001372:	0080                	addi	s0,sp,64
    80001374:	8aaa                	mv	s5,a0
    80001376:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001378:	6785                	lui	a5,0x1
    8000137a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000137c:	95be                	add	a1,a1,a5
    8000137e:	77fd                	lui	a5,0xfffff
    80001380:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001384:	06c9f763          	bgeu	s3,a2,800013f2 <uvmalloc+0x96>
    80001388:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000138a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000138e:	81dff0ef          	jal	ra,80000baa <kalloc>
    80001392:	84aa                	mv	s1,a0
    if(mem == 0){
    80001394:	c11d                	beqz	a0,800013ba <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    80001396:	6605                	lui	a2,0x1
    80001398:	4581                	li	a1,0
    8000139a:	9dbff0ef          	jal	ra,80000d74 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000139e:	875a                	mv	a4,s6
    800013a0:	86a6                	mv	a3,s1
    800013a2:	6605                	lui	a2,0x1
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	d29ff0ef          	jal	ra,800010d0 <mappages>
    800013ac:	e51d                	bnez	a0,800013da <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013ae:	6785                	lui	a5,0x1
    800013b0:	993e                	add	s2,s2,a5
    800013b2:	fd496ee3          	bltu	s2,s4,8000138e <uvmalloc+0x32>
  return newsz;
    800013b6:	8552                	mv	a0,s4
    800013b8:	a039                	j	800013c6 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    800013ba:	864e                	mv	a2,s3
    800013bc:	85ca                	mv	a1,s2
    800013be:	8556                	mv	a0,s5
    800013c0:	f59ff0ef          	jal	ra,80001318 <uvmdealloc>
      return 0;
    800013c4:	4501                	li	a0,0
}
    800013c6:	70e2                	ld	ra,56(sp)
    800013c8:	7442                	ld	s0,48(sp)
    800013ca:	74a2                	ld	s1,40(sp)
    800013cc:	7902                	ld	s2,32(sp)
    800013ce:	69e2                	ld	s3,24(sp)
    800013d0:	6a42                	ld	s4,16(sp)
    800013d2:	6aa2                	ld	s5,8(sp)
    800013d4:	6b02                	ld	s6,0(sp)
    800013d6:	6121                	addi	sp,sp,64
    800013d8:	8082                	ret
      kfree(mem);
    800013da:	8526                	mv	a0,s1
    800013dc:	e9eff0ef          	jal	ra,80000a7a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013e0:	864e                	mv	a2,s3
    800013e2:	85ca                	mv	a1,s2
    800013e4:	8556                	mv	a0,s5
    800013e6:	f33ff0ef          	jal	ra,80001318 <uvmdealloc>
      return 0;
    800013ea:	4501                	li	a0,0
    800013ec:	bfe9                	j	800013c6 <uvmalloc+0x6a>
    return oldsz;
    800013ee:	852e                	mv	a0,a1
}
    800013f0:	8082                	ret
  return newsz;
    800013f2:	8532                	mv	a0,a2
    800013f4:	bfc9                	j	800013c6 <uvmalloc+0x6a>

00000000800013f6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013f6:	7179                	addi	sp,sp,-48
    800013f8:	f406                	sd	ra,40(sp)
    800013fa:	f022                	sd	s0,32(sp)
    800013fc:	ec26                	sd	s1,24(sp)
    800013fe:	e84a                	sd	s2,16(sp)
    80001400:	e44e                	sd	s3,8(sp)
    80001402:	e052                	sd	s4,0(sp)
    80001404:	1800                	addi	s0,sp,48
    80001406:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001408:	84aa                	mv	s1,a0
    8000140a:	6905                	lui	s2,0x1
    8000140c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000140e:	4985                	li	s3,1
    80001410:	a819                	j	80001426 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001412:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001414:	00c79513          	slli	a0,a5,0xc
    80001418:	fdfff0ef          	jal	ra,800013f6 <freewalk>
      pagetable[i] = 0;
    8000141c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001420:	04a1                	addi	s1,s1,8
    80001422:	01248f63          	beq	s1,s2,80001440 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001426:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001428:	00f7f713          	andi	a4,a5,15
    8000142c:	ff3703e3          	beq	a4,s3,80001412 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001430:	8b85                	andi	a5,a5,1
    80001432:	d7fd                	beqz	a5,80001420 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001434:	00007517          	auipc	a0,0x7
    80001438:	d2450513          	addi	a0,a0,-732 # 80008158 <digits+0x120>
    8000143c:	b4cff0ef          	jal	ra,80000788 <panic>
    }
  }
  kfree((void*)pagetable);
    80001440:	8552                	mv	a0,s4
    80001442:	e38ff0ef          	jal	ra,80000a7a <kfree>
}
    80001446:	70a2                	ld	ra,40(sp)
    80001448:	7402                	ld	s0,32(sp)
    8000144a:	64e2                	ld	s1,24(sp)
    8000144c:	6942                	ld	s2,16(sp)
    8000144e:	69a2                	ld	s3,8(sp)
    80001450:	6a02                	ld	s4,0(sp)
    80001452:	6145                	addi	sp,sp,48
    80001454:	8082                	ret

0000000080001456 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001456:	1101                	addi	sp,sp,-32
    80001458:	ec06                	sd	ra,24(sp)
    8000145a:	e822                	sd	s0,16(sp)
    8000145c:	e426                	sd	s1,8(sp)
    8000145e:	1000                	addi	s0,sp,32
    80001460:	84aa                	mv	s1,a0
  if(sz > 0)
    80001462:	e989                	bnez	a1,80001474 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001464:	8526                	mv	a0,s1
    80001466:	f91ff0ef          	jal	ra,800013f6 <freewalk>
}
    8000146a:	60e2                	ld	ra,24(sp)
    8000146c:	6442                	ld	s0,16(sp)
    8000146e:	64a2                	ld	s1,8(sp)
    80001470:	6105                	addi	sp,sp,32
    80001472:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001474:	6785                	lui	a5,0x1
    80001476:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001478:	95be                	add	a1,a1,a5
    8000147a:	4685                	li	a3,1
    8000147c:	00c5d613          	srli	a2,a1,0xc
    80001480:	4581                	li	a1,0
    80001482:	e1bff0ef          	jal	ra,8000129c <uvmunmap>
    80001486:	bff9                	j	80001464 <uvmfree+0xe>

0000000080001488 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001488:	ce55                	beqz	a2,80001544 <uvmcopy+0xbc>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8aae                	mv	s5,a1
    800014a4:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014a6:	4901                	li	s2,0
    if(flags & PTE_W){
      // 子进程和父进程映射要只读 + COW
      flags = (flags & ~PTE_W) | PTE_COW;

      // 父进程也要
      *pte = PA2PTE(pa) | flags | PTE_V;
    800014a8:	7b7d                	lui	s6,0xfffff
    800014aa:	002b5b13          	srli	s6,s6,0x2
    800014ae:	a02d                	j	800014d8 <uvmcopy+0x50>
    pa = PTE2PA(*pte);
    800014b0:	82a9                	srli	a3,a3,0xa
    800014b2:	00c69493          	slli	s1,a3,0xc
    }

    // 共享同一物理页：引用计数 +1
    kref_inc((void*)pa);
    800014b6:	8526                	mv	a0,s1
    800014b8:	d3aff0ef          	jal	ra,800009f2 <kref_inc>

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800014bc:	875e                	mv	a4,s7
    800014be:	86a6                	mv	a3,s1
    800014c0:	6605                	lui	a2,0x1
    800014c2:	85ca                	mv	a1,s2
    800014c4:	8556                	mv	a0,s5
    800014c6:	c0bff0ef          	jal	ra,800010d0 <mappages>
    800014ca:	e529                	bnez	a0,80001514 <uvmcopy+0x8c>
    800014cc:	12000073          	sfence.vma
  for(i = 0; i < sz; i += PGSIZE){
    800014d0:	6785                	lui	a5,0x1
    800014d2:	993e                	add	s2,s2,a5
    800014d4:	05397c63          	bgeu	s2,s3,8000152c <uvmcopy+0xa4>
    pte = walk(old, i, 0);
    800014d8:	4601                	li	a2,0
    800014da:	85ca                	mv	a1,s2
    800014dc:	8552                	mv	a0,s4
    800014de:	b1bff0ef          	jal	ra,80000ff8 <walk>
    if(pte == 0)
    800014e2:	d57d                	beqz	a0,800014d0 <uvmcopy+0x48>
    if((*pte & PTE_V) == 0)
    800014e4:	6114                	ld	a3,0(a0)
    800014e6:	0016f793          	andi	a5,a3,1
    800014ea:	d3fd                	beqz	a5,800014d0 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    800014ec:	0006879b          	sext.w	a5,a3
    if((flags & PTE_U) == 0)
    800014f0:	0106f713          	andi	a4,a3,16
    800014f4:	df71                	beqz	a4,800014d0 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    800014f6:	3ff7fb93          	andi	s7,a5,1023
    if(flags & PTE_W){
    800014fa:	8b91                	andi	a5,a5,4
    800014fc:	dbd5                	beqz	a5,800014b0 <uvmcopy+0x28>
      flags = (flags & ~PTE_W) | PTE_COW;
    800014fe:	efbbf793          	andi	a5,s7,-261
    80001502:	1007eb93          	ori	s7,a5,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001506:	0166f733          	and	a4,a3,s6
    8000150a:	8fd9                	or	a5,a5,a4
    8000150c:	1017e793          	ori	a5,a5,257
    80001510:	e11c                	sd	a5,0(a0)
    80001512:	bf79                	j	800014b0 <uvmcopy+0x28>
      // map 失败要回滚 refcnt
      kref_dec((void*)pa);
    80001514:	8526                	mv	a0,s1
    80001516:	d20ff0ef          	jal	ra,80000a36 <kref_dec>
  return 0;

err:
  // 回收子进程已经建立的映射：
  // do_free=1 会对每个 pa 调 kfree()， kfree 再对 refcnt--。
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000151a:	4685                	li	a3,1
    8000151c:	00c95613          	srli	a2,s2,0xc
    80001520:	4581                	li	a1,0
    80001522:	8556                	mv	a0,s5
    80001524:	d79ff0ef          	jal	ra,8000129c <uvmunmap>
  return -1;
    80001528:	557d                	li	a0,-1
    8000152a:	a011                	j	8000152e <uvmcopy+0xa6>
  return 0;
    8000152c:	4501                	li	a0,0
}
    8000152e:	60a6                	ld	ra,72(sp)
    80001530:	6406                	ld	s0,64(sp)
    80001532:	74e2                	ld	s1,56(sp)
    80001534:	7942                	ld	s2,48(sp)
    80001536:	79a2                	ld	s3,40(sp)
    80001538:	7a02                	ld	s4,32(sp)
    8000153a:	6ae2                	ld	s5,24(sp)
    8000153c:	6b42                	ld	s6,16(sp)
    8000153e:	6ba2                	ld	s7,8(sp)
    80001540:	6161                	addi	sp,sp,80
    80001542:	8082                	ret
  return 0;
    80001544:	4501                	li	a0,0
}
    80001546:	8082                	ret

0000000080001548 <cowbreak>:
int
cowbreak(pagetable_t pagetable, uint64 va)
{
    80001548:	7179                	addi	sp,sp,-48
    8000154a:	f406                	sd	ra,40(sp)
    8000154c:	f022                	sd	s0,32(sp)
    8000154e:	ec26                	sd	s1,24(sp)
    80001550:	e84a                	sd	s2,16(sp)
    80001552:	e44e                	sd	s3,8(sp)
    80001554:	e052                	sd	s4,0(sp)
    80001556:	1800                	addi	s0,sp,48
  va = PGROUNDDOWN(va);

  pte_t *pte = walk(pagetable, va, 0);
    80001558:	4601                	li	a2,0
    8000155a:	77fd                	lui	a5,0xfffff
    8000155c:	8dfd                	and	a1,a1,a5
    8000155e:	a9bff0ef          	jal	ra,80000ff8 <walk>
  if(pte == 0)
    80001562:	cd41                	beqz	a0,800015fa <cowbreak+0xb2>
    80001564:	89aa                	mv	s3,a0
    return -1;
  if((*pte & PTE_V) == 0)
    80001566:	6104                	ld	s1,0(a0)
    return -1;
  if((*pte & PTE_U) == 0)
    80001568:	0114f713          	andi	a4,s1,17
    8000156c:	47c5                	li	a5,17
    8000156e:	08f71863          	bne	a4,a5,800015fe <cowbreak+0xb6>
    return -1;

  // 必须是 COW 且当前不可写
  if(((*pte & PTE_COW) == 0) || ((*pte & PTE_W) != 0))
    80001572:	1044f793          	andi	a5,s1,260
    80001576:	10000713          	li	a4,256
    8000157a:	08e79463          	bne	a5,a4,80001602 <cowbreak+0xba>
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  uint flags = PTE_FLAGS(*pte);
    8000157e:	3ff4f913          	andi	s2,s1,1023
  uint64 pa_old = PTE2PA(*pte);
    80001582:	00a4da13          	srli	s4,s1,0xa
    80001586:	0a32                	slli	s4,s4,0xc

  // 如果只有一个引用，不用拷贝，直接恢复可写
  if(kref_get((void*)pa_old) == 1){
    80001588:	8552                	mv	a0,s4
    8000158a:	c2eff0ef          	jal	ra,800009b8 <kref_get>
    8000158e:	4785                	li	a5,1
    80001590:	04f50463          	beq	a0,a5,800015d8 <cowbreak+0x90>
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    sfence_vma();
    return 0;
  }

  char *mem = kalloc();
    80001594:	e16ff0ef          	jal	ra,80000baa <kalloc>
    80001598:	84aa                	mv	s1,a0
  if(mem == 0)
    8000159a:	c535                	beqz	a0,80001606 <cowbreak+0xbe>
    return -1;

  memmove(mem, (void*)pa_old, PGSIZE);
    8000159c:	6605                	lui	a2,0x1
    8000159e:	85d2                	mv	a1,s4
    800015a0:	831ff0ef          	jal	ra,80000dd0 <memmove>

  // 旧页引用计数 -1
  kref_dec((void*)pa_old);
    800015a4:	8552                	mv	a0,s4
    800015a6:	c90ff0ef          	jal	ra,80000a36 <kref_dec>

  // 更新 PTE：指向新页，变可写，清掉 COW
  *pte = PA2PTE((uint64)mem) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015aa:	80b1                	srli	s1,s1,0xc
    800015ac:	04aa                	slli	s1,s1,0xa
    800015ae:	00496913          	ori	s2,s2,4
    800015b2:	eff97913          	andi	s2,s2,-257
    800015b6:	0124e4b3          	or	s1,s1,s2
    800015ba:	0014e493          	ori	s1,s1,1
    800015be:	0099b023          	sd	s1,0(s3)
    800015c2:	12000073          	sfence.vma

  sfence_vma();
  return 0;
    800015c6:	4501                	li	a0,0
}
    800015c8:	70a2                	ld	ra,40(sp)
    800015ca:	7402                	ld	s0,32(sp)
    800015cc:	64e2                	ld	s1,24(sp)
    800015ce:	6942                	ld	s2,16(sp)
    800015d0:	69a2                	ld	s3,8(sp)
    800015d2:	6a02                	ld	s4,0(sp)
    800015d4:	6145                	addi	sp,sp,48
    800015d6:	8082                	ret
    *pte = PA2PTE(pa_old) | ((flags | PTE_W) & ~PTE_COW) | PTE_V;
    800015d8:	00496913          	ori	s2,s2,4
    800015dc:	eff97913          	andi	s2,s2,-257
    800015e0:	77fd                	lui	a5,0xfffff
    800015e2:	8389                	srli	a5,a5,0x2
    800015e4:	8cfd                	and	s1,s1,a5
    800015e6:	00996933          	or	s2,s2,s1
    800015ea:	00196913          	ori	s2,s2,1
    800015ee:	0129b023          	sd	s2,0(s3)
    800015f2:	12000073          	sfence.vma
    return 0;
    800015f6:	4501                	li	a0,0
    800015f8:	bfc1                	j	800015c8 <cowbreak+0x80>
    return -1;
    800015fa:	557d                	li	a0,-1
    800015fc:	b7f1                	j	800015c8 <cowbreak+0x80>
    return -1;
    800015fe:	557d                	li	a0,-1
    80001600:	b7e1                	j	800015c8 <cowbreak+0x80>
    return -1;
    80001602:	557d                	li	a0,-1
    80001604:	b7d1                	j	800015c8 <cowbreak+0x80>
    return -1;
    80001606:	557d                	li	a0,-1
    80001608:	b7c1                	j	800015c8 <cowbreak+0x80>

000000008000160a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000160a:	1141                	addi	sp,sp,-16
    8000160c:	e406                	sd	ra,8(sp)
    8000160e:	e022                	sd	s0,0(sp)
    80001610:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001612:	4601                	li	a2,0
    80001614:	9e5ff0ef          	jal	ra,80000ff8 <walk>
  if(pte == 0)
    80001618:	c901                	beqz	a0,80001628 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000161a:	611c                	ld	a5,0(a0)
    8000161c:	9bbd                	andi	a5,a5,-17
    8000161e:	e11c                	sd	a5,0(a0)
}
    80001620:	60a2                	ld	ra,8(sp)
    80001622:	6402                	ld	s0,0(sp)
    80001624:	0141                	addi	sp,sp,16
    80001626:	8082                	ret
    panic("uvmclear");
    80001628:	00007517          	auipc	a0,0x7
    8000162c:	b4050513          	addi	a0,a0,-1216 # 80008168 <digits+0x130>
    80001630:	958ff0ef          	jal	ra,80000788 <panic>

0000000080001634 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001634:	c2cd                	beqz	a3,800016d6 <copyinstr+0xa2>
{
    80001636:	715d                	addi	sp,sp,-80
    80001638:	e486                	sd	ra,72(sp)
    8000163a:	e0a2                	sd	s0,64(sp)
    8000163c:	fc26                	sd	s1,56(sp)
    8000163e:	f84a                	sd	s2,48(sp)
    80001640:	f44e                	sd	s3,40(sp)
    80001642:	f052                	sd	s4,32(sp)
    80001644:	ec56                	sd	s5,24(sp)
    80001646:	e85a                	sd	s6,16(sp)
    80001648:	e45e                	sd	s7,8(sp)
    8000164a:	0880                	addi	s0,sp,80
    8000164c:	8a2a                	mv	s4,a0
    8000164e:	8b2e                	mv	s6,a1
    80001650:	8bb2                	mv	s7,a2
    80001652:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001654:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001656:	6985                	lui	s3,0x1
    80001658:	a02d                	j	80001682 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000165a:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdaae50>
    8000165e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001660:	37fd                	addiw	a5,a5,-1
    80001662:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001666:	60a6                	ld	ra,72(sp)
    80001668:	6406                	ld	s0,64(sp)
    8000166a:	74e2                	ld	s1,56(sp)
    8000166c:	7942                	ld	s2,48(sp)
    8000166e:	79a2                	ld	s3,40(sp)
    80001670:	7a02                	ld	s4,32(sp)
    80001672:	6ae2                	ld	s5,24(sp)
    80001674:	6b42                	ld	s6,16(sp)
    80001676:	6ba2                	ld	s7,8(sp)
    80001678:	6161                	addi	sp,sp,80
    8000167a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000167c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001680:	c4b9                	beqz	s1,800016ce <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80001682:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001686:	85ca                	mv	a1,s2
    80001688:	8552                	mv	a0,s4
    8000168a:	a09ff0ef          	jal	ra,80001092 <walkaddr>
    if(pa0 == 0)
    8000168e:	c131                	beqz	a0,800016d2 <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80001690:	417906b3          	sub	a3,s2,s7
    80001694:	96ce                	add	a3,a3,s3
    80001696:	00d4f363          	bgeu	s1,a3,8000169c <copyinstr+0x68>
    8000169a:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000169c:	955e                	add	a0,a0,s7
    8000169e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016a2:	dee9                	beqz	a3,8000167c <copyinstr+0x48>
    800016a4:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016a6:	41650633          	sub	a2,a0,s6
    800016aa:	fff48593          	addi	a1,s1,-1
    800016ae:	95da                	add	a1,a1,s6
    while(n > 0){
    800016b0:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800016b2:	00f60733          	add	a4,a2,a5
    800016b6:	00074703          	lbu	a4,0(a4)
    800016ba:	d345                	beqz	a4,8000165a <copyinstr+0x26>
        *dst = *p;
    800016bc:	00e78023          	sb	a4,0(a5)
      --max;
    800016c0:	40f584b3          	sub	s1,a1,a5
      dst++;
    800016c4:	0785                	addi	a5,a5,1
    while(n > 0){
    800016c6:	fed796e3          	bne	a5,a3,800016b2 <copyinstr+0x7e>
      dst++;
    800016ca:	8b3e                	mv	s6,a5
    800016cc:	bf45                	j	8000167c <copyinstr+0x48>
    800016ce:	4781                	li	a5,0
    800016d0:	bf41                	j	80001660 <copyinstr+0x2c>
      return -1;
    800016d2:	557d                	li	a0,-1
    800016d4:	bf49                	j	80001666 <copyinstr+0x32>
  int got_null = 0;
    800016d6:	4781                	li	a5,0
  if(got_null){
    800016d8:	37fd                	addiw	a5,a5,-1
    800016da:	0007851b          	sext.w	a0,a5
}
    800016de:	8082                	ret

00000000800016e0 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800016e0:	1141                	addi	sp,sp,-16
    800016e2:	e406                	sd	ra,8(sp)
    800016e4:	e022                	sd	s0,0(sp)
    800016e6:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800016e8:	4601                	li	a2,0
    800016ea:	90fff0ef          	jal	ra,80000ff8 <walk>
  if (pte == 0) {
    800016ee:	c519                	beqz	a0,800016fc <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800016f0:	6108                	ld	a0,0(a0)
    return 0;
    800016f2:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800016f4:	60a2                	ld	ra,8(sp)
    800016f6:	6402                	ld	s0,0(sp)
    800016f8:	0141                	addi	sp,sp,16
    800016fa:	8082                	ret
    return 0;
    800016fc:	4501                	li	a0,0
    800016fe:	bfdd                	j	800016f4 <ismapped+0x14>

0000000080001700 <vmfault>:
{
    80001700:	7179                	addi	sp,sp,-48
    80001702:	f406                	sd	ra,40(sp)
    80001704:	f022                	sd	s0,32(sp)
    80001706:	ec26                	sd	s1,24(sp)
    80001708:	e84a                	sd	s2,16(sp)
    8000170a:	e44e                	sd	s3,8(sp)
    8000170c:	e052                	sd	s4,0(sp)
    8000170e:	1800                	addi	s0,sp,48
    80001710:	89aa                	mv	s3,a0
    80001712:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001714:	43c000ef          	jal	ra,80001b50 <myproc>
  if (va >= p->sz)
    80001718:	653c                	ld	a5,72(a0)
    8000171a:	00f4ec63          	bltu	s1,a5,80001732 <vmfault+0x32>
    return 0;
    8000171e:	4981                	li	s3,0
}
    80001720:	854e                	mv	a0,s3
    80001722:	70a2                	ld	ra,40(sp)
    80001724:	7402                	ld	s0,32(sp)
    80001726:	64e2                	ld	s1,24(sp)
    80001728:	6942                	ld	s2,16(sp)
    8000172a:	69a2                	ld	s3,8(sp)
    8000172c:	6a02                	ld	s4,0(sp)
    8000172e:	6145                	addi	sp,sp,48
    80001730:	8082                	ret
    80001732:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001734:	77fd                	lui	a5,0xfffff
    80001736:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001738:	85a6                	mv	a1,s1
    8000173a:	854e                	mv	a0,s3
    8000173c:	fa5ff0ef          	jal	ra,800016e0 <ismapped>
    return 0;
    80001740:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001742:	fd79                	bnez	a0,80001720 <vmfault+0x20>
  mem = (uint64) kalloc();
    80001744:	c66ff0ef          	jal	ra,80000baa <kalloc>
    80001748:	8a2a                	mv	s4,a0
  if(mem == 0)
    8000174a:	d979                	beqz	a0,80001720 <vmfault+0x20>
  mem = (uint64) kalloc();
    8000174c:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000174e:	6605                	lui	a2,0x1
    80001750:	4581                	li	a1,0
    80001752:	e22ff0ef          	jal	ra,80000d74 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001756:	4759                	li	a4,22
    80001758:	86d2                	mv	a3,s4
    8000175a:	6605                	lui	a2,0x1
    8000175c:	85a6                	mv	a1,s1
    8000175e:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001762:	96fff0ef          	jal	ra,800010d0 <mappages>
    80001766:	dd4d                	beqz	a0,80001720 <vmfault+0x20>
    kfree((void *)mem);
    80001768:	8552                	mv	a0,s4
    8000176a:	b10ff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    8000176e:	4981                	li	s3,0
    80001770:	bf45                	j	80001720 <vmfault+0x20>

0000000080001772 <copyout>:
  while(len > 0){
    80001772:	c6e1                	beqz	a3,8000183a <copyout+0xc8>
{
    80001774:	711d                	addi	sp,sp,-96
    80001776:	ec86                	sd	ra,88(sp)
    80001778:	e8a2                	sd	s0,80(sp)
    8000177a:	e4a6                	sd	s1,72(sp)
    8000177c:	e0ca                	sd	s2,64(sp)
    8000177e:	fc4e                	sd	s3,56(sp)
    80001780:	f852                	sd	s4,48(sp)
    80001782:	f456                	sd	s5,40(sp)
    80001784:	f05a                	sd	s6,32(sp)
    80001786:	ec5e                	sd	s7,24(sp)
    80001788:	e862                	sd	s8,16(sp)
    8000178a:	e466                	sd	s9,8(sp)
    8000178c:	e06a                	sd	s10,0(sp)
    8000178e:	1080                	addi	s0,sp,96
    80001790:	8b2a                	mv	s6,a0
    80001792:	8bae                	mv	s7,a1
    80001794:	8c32                	mv	s8,a2
    80001796:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001798:	74fd                	lui	s1,0xfffff
    8000179a:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000179c:	57fd                	li	a5,-1
    8000179e:	83e9                	srli	a5,a5,0x1a
    800017a0:	0897ef63          	bltu	a5,s1,8000183e <copyout+0xcc>
    800017a4:	6d05                	lui	s10,0x1
    800017a6:	8cbe                	mv	s9,a5
    800017a8:	a82d                	j	800017e2 <copyout+0x70>
    if((*pte & PTE_W) == 0)
    800017aa:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
    800017ae:	8b91                	andi	a5,a5,4
    800017b0:	cfd9                	beqz	a5,8000184e <copyout+0xdc>
    n = PGSIZE - (dstva - va0);
    800017b2:	01a48a33          	add	s4,s1,s10
    800017b6:	417a09b3          	sub	s3,s4,s7
    800017ba:	013af363          	bgeu	s5,s3,800017c0 <copyout+0x4e>
    800017be:	89d6                	mv	s3,s5
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017c0:	409b8533          	sub	a0,s7,s1
    800017c4:	0009861b          	sext.w	a2,s3
    800017c8:	85e2                	mv	a1,s8
    800017ca:	954a                	add	a0,a0,s2
    800017cc:	e04ff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    800017d0:	413a8ab3          	sub	s5,s5,s3
    src += n;
    800017d4:	9c4e                	add	s8,s8,s3
  while(len > 0){
    800017d6:	060a8063          	beqz	s5,80001836 <copyout+0xc4>
    if(va0 >= MAXVA)
    800017da:	074ce463          	bltu	s9,s4,80001842 <copyout+0xd0>
    va0 = PGROUNDDOWN(dstva);
    800017de:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    800017e0:	8bd2                	mv	s7,s4
    pa0 = walkaddr(pagetable, va0);
    800017e2:	85a6                	mv	a1,s1
    800017e4:	855a                	mv	a0,s6
    800017e6:	8adff0ef          	jal	ra,80001092 <walkaddr>
    800017ea:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800017ec:	e901                	bnez	a0,800017fc <copyout+0x8a>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800017ee:	4601                	li	a2,0
    800017f0:	85a6                	mv	a1,s1
    800017f2:	855a                	mv	a0,s6
    800017f4:	f0dff0ef          	jal	ra,80001700 <vmfault>
    800017f8:	892a                	mv	s2,a0
    800017fa:	c531                	beqz	a0,80001846 <copyout+0xd4>
    pte = walk(pagetable, va0, 0);
    800017fc:	4601                	li	a2,0
    800017fe:	85a6                	mv	a1,s1
    80001800:	855a                	mv	a0,s6
    80001802:	ff6ff0ef          	jal	ra,80000ff8 <walk>
    80001806:	89aa                	mv	s3,a0
    if(pte && (*pte & PTE_COW)){
    80001808:	d14d                	beqz	a0,800017aa <copyout+0x38>
    8000180a:	611c                	ld	a5,0(a0)
    8000180c:	1007f793          	andi	a5,a5,256
    80001810:	dfc9                	beqz	a5,800017aa <copyout+0x38>
      if(cowbreak(pagetable, va0) < 0)
    80001812:	85a6                	mv	a1,s1
    80001814:	855a                	mv	a0,s6
    80001816:	d33ff0ef          	jal	ra,80001548 <cowbreak>
    8000181a:	02054863          	bltz	a0,8000184a <copyout+0xd8>
      pte = walk(pagetable, va0, 0);
    8000181e:	4601                	li	a2,0
    80001820:	85a6                	mv	a1,s1
    80001822:	855a                	mv	a0,s6
    80001824:	fd4ff0ef          	jal	ra,80000ff8 <walk>
    80001828:	89aa                	mv	s3,a0
      pa0 = walkaddr(pagetable, va0);
    8000182a:	85a6                	mv	a1,s1
    8000182c:	855a                	mv	a0,s6
    8000182e:	865ff0ef          	jal	ra,80001092 <walkaddr>
    80001832:	892a                	mv	s2,a0
    80001834:	bf9d                	j	800017aa <copyout+0x38>
  return 0;
    80001836:	4501                	li	a0,0
    80001838:	a821                	j	80001850 <copyout+0xde>
    8000183a:	4501                	li	a0,0
}
    8000183c:	8082                	ret
      return -1;
    8000183e:	557d                	li	a0,-1
    80001840:	a801                	j	80001850 <copyout+0xde>
    80001842:	557d                	li	a0,-1
    80001844:	a031                	j	80001850 <copyout+0xde>
        return -1;
    80001846:	557d                	li	a0,-1
    80001848:	a021                	j	80001850 <copyout+0xde>
        return -1;
    8000184a:	557d                	li	a0,-1
    8000184c:	a011                	j	80001850 <copyout+0xde>
      return -1;
    8000184e:	557d                	li	a0,-1
}
    80001850:	60e6                	ld	ra,88(sp)
    80001852:	6446                	ld	s0,80(sp)
    80001854:	64a6                	ld	s1,72(sp)
    80001856:	6906                	ld	s2,64(sp)
    80001858:	79e2                	ld	s3,56(sp)
    8000185a:	7a42                	ld	s4,48(sp)
    8000185c:	7aa2                	ld	s5,40(sp)
    8000185e:	7b02                	ld	s6,32(sp)
    80001860:	6be2                	ld	s7,24(sp)
    80001862:	6c42                	ld	s8,16(sp)
    80001864:	6ca2                	ld	s9,8(sp)
    80001866:	6d02                	ld	s10,0(sp)
    80001868:	6125                	addi	sp,sp,96
    8000186a:	8082                	ret

000000008000186c <copyin>:
  while(len > 0){
    8000186c:	c6c9                	beqz	a3,800018f6 <copyin+0x8a>
{
    8000186e:	715d                	addi	sp,sp,-80
    80001870:	e486                	sd	ra,72(sp)
    80001872:	e0a2                	sd	s0,64(sp)
    80001874:	fc26                	sd	s1,56(sp)
    80001876:	f84a                	sd	s2,48(sp)
    80001878:	f44e                	sd	s3,40(sp)
    8000187a:	f052                	sd	s4,32(sp)
    8000187c:	ec56                	sd	s5,24(sp)
    8000187e:	e85a                	sd	s6,16(sp)
    80001880:	e45e                	sd	s7,8(sp)
    80001882:	e062                	sd	s8,0(sp)
    80001884:	0880                	addi	s0,sp,80
    80001886:	8baa                	mv	s7,a0
    80001888:	8aae                	mv	s5,a1
    8000188a:	8932                	mv	s2,a2
    8000188c:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000188e:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001890:	6b05                	lui	s6,0x1
    80001892:	a035                	j	800018be <copyin+0x52>
    80001894:	412984b3          	sub	s1,s3,s2
    80001898:	94da                	add	s1,s1,s6
    8000189a:	009a7363          	bgeu	s4,s1,800018a0 <copyin+0x34>
    8000189e:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018a0:	413905b3          	sub	a1,s2,s3
    800018a4:	0004861b          	sext.w	a2,s1
    800018a8:	95aa                	add	a1,a1,a0
    800018aa:	8556                	mv	a0,s5
    800018ac:	d24ff0ef          	jal	ra,80000dd0 <memmove>
    len -= n;
    800018b0:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800018b4:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800018b6:	01698933          	add	s2,s3,s6
  while(len > 0){
    800018ba:	020a0163          	beqz	s4,800018dc <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    800018be:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800018c2:	85ce                	mv	a1,s3
    800018c4:	855e                	mv	a0,s7
    800018c6:	fccff0ef          	jal	ra,80001092 <walkaddr>
    if(pa0 == 0) {
    800018ca:	f569                	bnez	a0,80001894 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800018cc:	4601                	li	a2,0
    800018ce:	85ce                	mv	a1,s3
    800018d0:	855e                	mv	a0,s7
    800018d2:	e2fff0ef          	jal	ra,80001700 <vmfault>
    800018d6:	fd5d                	bnez	a0,80001894 <copyin+0x28>
        return -1;
    800018d8:	557d                	li	a0,-1
    800018da:	a011                	j	800018de <copyin+0x72>
  return 0;
    800018dc:	4501                	li	a0,0
}
    800018de:	60a6                	ld	ra,72(sp)
    800018e0:	6406                	ld	s0,64(sp)
    800018e2:	74e2                	ld	s1,56(sp)
    800018e4:	7942                	ld	s2,48(sp)
    800018e6:	79a2                	ld	s3,40(sp)
    800018e8:	7a02                	ld	s4,32(sp)
    800018ea:	6ae2                	ld	s5,24(sp)
    800018ec:	6b42                	ld	s6,16(sp)
    800018ee:	6ba2                	ld	s7,8(sp)
    800018f0:	6c02                	ld	s8,0(sp)
    800018f2:	6161                	addi	sp,sp,80
    800018f4:	8082                	ret
  return 0;
    800018f6:	4501                	li	a0,0
}
    800018f8:	8082                	ret

00000000800018fa <vmafault>:


uint64
vmafault(struct proc *p, uint64 va, int iswrite)
{
    800018fa:	7139                	addi	sp,sp,-64
    800018fc:	fc06                	sd	ra,56(sp)
    800018fe:	f822                	sd	s0,48(sp)
    80001900:	f426                	sd	s1,40(sp)
    80001902:	f04a                	sd	s2,32(sp)
    80001904:	ec4e                	sd	s3,24(sp)
    80001906:	e852                	sd	s4,16(sp)
    80001908:	e456                	sd	s5,8(sp)
    8000190a:	0080                	addi	s0,sp,64
    8000190c:	8a2a                	mv	s4,a0
    8000190e:	8932                	mv	s2,a2
  va = PGROUNDDOWN(va);
    80001910:	77fd                	lui	a5,0xfffff
    80001912:	00f5f9b3          	and	s3,a1,a5

  struct vma *v = vma_find(p, va);
    80001916:	85ce                	mv	a1,s3
    80001918:	746010ef          	jal	ra,8000305e <vma_find>
  if(v == 0) return 0;
    8000191c:	c569                	beqz	a0,800019e6 <vmafault+0xec>
    8000191e:	84aa                	mv	s1,a0

  // 权限检查：VMA 不允许写但发生写 fault -> 不处理，让上层 kill
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    80001920:	00090663          	beqz	s2,8000192c <vmafault+0x32>
    80001924:	4d1c                	lw	a5,24(a0)
    80001926:	8b89                	andi	a5,a5,2
    return 0;
    80001928:	4901                	li	s2,0
  if(iswrite && (v->prot & PROT_WRITE) == 0)
    8000192a:	c789                	beqz	a5,80001934 <vmafault+0x3a>
  if((v->prot & PROT_READ) == 0)
    8000192c:	4c9c                	lw	a5,24(s1)
    8000192e:	8b85                	andi	a5,a5,1
    return 0;
    80001930:	4901                	li	s2,0
  if((v->prot & PROT_READ) == 0)
    80001932:	eb99                	bnez	a5,80001948 <vmafault+0x4e>
    if(v->is_shm) kref_dec((void*)pa);
    else kfree((void*)pa);
    return 0;
  }
  return (uint64)pa;
}
    80001934:	854a                	mv	a0,s2
    80001936:	70e2                	ld	ra,56(sp)
    80001938:	7442                	ld	s0,48(sp)
    8000193a:	74a2                	ld	s1,40(sp)
    8000193c:	7902                	ld	s2,32(sp)
    8000193e:	69e2                	ld	s3,24(sp)
    80001940:	6a42                	ld	s4,16(sp)
    80001942:	6aa2                	ld	s5,8(sp)
    80001944:	6121                	addi	sp,sp,64
    80001946:	8082                	ret
  pte_t *pte = walk(p->pagetable, va, 0);
    80001948:	4601                	li	a2,0
    8000194a:	85ce                	mv	a1,s3
    8000194c:	050a3503          	ld	a0,80(s4)
    80001950:	ea8ff0ef          	jal	ra,80000ff8 <walk>
  if(pte && (*pte & PTE_V)){
    80001954:	c115                	beqz	a0,80001978 <vmafault+0x7e>
    80001956:	611c                	ld	a5,0(a0)
    80001958:	0017f913          	andi	s2,a5,1
    8000195c:	00090e63          	beqz	s2,80001978 <vmafault+0x7e>
    if((v->prot & PROT_WRITE) && ((*pte & PTE_W) == 0)){
    80001960:	4c98                	lw	a4,24(s1)
    80001962:	8b09                	andi	a4,a4,2
    80001964:	c359                	beqz	a4,800019ea <vmafault+0xf0>
    80001966:	0047f713          	andi	a4,a5,4
    8000196a:	e351                	bnez	a4,800019ee <vmafault+0xf4>
      *pte |= PTE_W;
    8000196c:	0047e793          	ori	a5,a5,4
    80001970:	e11c                	sd	a5,0(a0)
    80001972:	12000073          	sfence.vma
      return 1;
    80001976:	bf7d                	j	80001934 <vmafault+0x3a>
  int idx = (va - v->start) / PGSIZE;
    80001978:	648c                	ld	a1,8(s1)
  if(v->is_shm){
    8000197a:	509c                	lw	a5,32(s1)
    8000197c:	cf89                	beqz	a5,80001996 <vmafault+0x9c>
  int idx = (va - v->start) / PGSIZE;
    8000197e:	40b985b3          	sub	a1,s3,a1
    80001982:	81b1                	srli	a1,a1,0xc
    pa = shm_getpa(v->shm_key, idx);
    80001984:	2581                	sext.w	a1,a1
    80001986:	50c8                	lw	a0,36(s1)
    80001988:	5c7040ef          	jal	ra,8000674e <shm_getpa>
    8000198c:	892a                	mv	s2,a0
    if(pa == 0) return 0;
    8000198e:	d15d                	beqz	a0,80001934 <vmafault+0x3a>
    kref_inc((void*)pa);
    80001990:	862ff0ef          	jal	ra,800009f2 <kref_inc>
    80001994:	a819                	j	800019aa <vmafault+0xb0>
    char *mem = kalloc();
    80001996:	a14ff0ef          	jal	ra,80000baa <kalloc>
    8000199a:	8aaa                	mv	s5,a0
    if(mem == 0) return 0;
    8000199c:	4901                	li	s2,0
    8000199e:	d959                	beqz	a0,80001934 <vmafault+0x3a>
    memset(mem, 0, PGSIZE);
    800019a0:	6605                	lui	a2,0x1
    800019a2:	4581                	li	a1,0
    800019a4:	bd0ff0ef          	jal	ra,80000d74 <memset>
    pa = (uint64)mem;
    800019a8:	8956                	mv	s2,s5
  if(v->prot & PROT_READ)  perm |= PTE_R;
    800019aa:	4c9c                	lw	a5,24(s1)
    800019ac:	0017f693          	andi	a3,a5,1
  int perm = PTE_U;
    800019b0:	4741                	li	a4,16
  if(v->prot & PROT_READ)  perm |= PTE_R;
    800019b2:	c291                	beqz	a3,800019b6 <vmafault+0xbc>
    800019b4:	4749                	li	a4,18
  if(v->prot & PROT_WRITE) perm |= PTE_W;
    800019b6:	8b89                	andi	a5,a5,2
    800019b8:	c399                	beqz	a5,800019be <vmafault+0xc4>
    800019ba:	00476713          	ori	a4,a4,4
  if(mappages(p->pagetable, va, PGSIZE, pa, perm) != 0){
    800019be:	86ca                	mv	a3,s2
    800019c0:	6605                	lui	a2,0x1
    800019c2:	85ce                	mv	a1,s3
    800019c4:	050a3503          	ld	a0,80(s4)
    800019c8:	f08ff0ef          	jal	ra,800010d0 <mappages>
    800019cc:	d525                	beqz	a0,80001934 <vmafault+0x3a>
    if(v->is_shm) kref_dec((void*)pa);
    800019ce:	509c                	lw	a5,32(s1)
    800019d0:	c791                	beqz	a5,800019dc <vmafault+0xe2>
    800019d2:	854a                	mv	a0,s2
    800019d4:	862ff0ef          	jal	ra,80000a36 <kref_dec>
    return 0;
    800019d8:	4901                	li	s2,0
    800019da:	bfa9                	j	80001934 <vmafault+0x3a>
    else kfree((void*)pa);
    800019dc:	854a                	mv	a0,s2
    800019de:	89cff0ef          	jal	ra,80000a7a <kfree>
    return 0;
    800019e2:	4901                	li	s2,0
    800019e4:	bf81                	j	80001934 <vmafault+0x3a>
  if(v == 0) return 0;
    800019e6:	4901                	li	s2,0
    800019e8:	b7b1                	j	80001934 <vmafault+0x3a>
    return 0;
    800019ea:	4901                	li	s2,0
    800019ec:	b7a1                	j	80001934 <vmafault+0x3a>
    800019ee:	4901                	li	s2,0
    800019f0:	b791                	j	80001934 <vmafault+0x3a>

00000000800019f2 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800019f2:	7139                	addi	sp,sp,-64
    800019f4:	fc06                	sd	ra,56(sp)
    800019f6:	f822                	sd	s0,48(sp)
    800019f8:	f426                	sd	s1,40(sp)
    800019fa:	f04a                	sd	s2,32(sp)
    800019fc:	ec4e                	sd	s3,24(sp)
    800019fe:	e852                	sd	s4,16(sp)
    80001a00:	e456                	sd	s5,8(sp)
    80001a02:	e05a                	sd	s6,0(sp)
    80001a04:	0080                	addi	s0,sp,64
    80001a06:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a08:	0022f497          	auipc	s1,0x22f
    80001a0c:	41848493          	addi	s1,s1,1048 # 80230e20 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a10:	8b26                	mv	s6,s1
    80001a12:	00006a97          	auipc	s5,0x6
    80001a16:	5eea8a93          	addi	s5,s5,1518 # 80008000 <etext>
    80001a1a:	04000937          	lui	s2,0x4000
    80001a1e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a20:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a22:	0023fa17          	auipc	s4,0x23f
    80001a26:	dfea0a13          	addi	s4,s4,-514 # 80240820 <tickslock>
    char *pa = kalloc();
    80001a2a:	980ff0ef          	jal	ra,80000baa <kalloc>
    80001a2e:	862a                	mv	a2,a0
    if(pa == 0)
    80001a30:	c121                	beqz	a0,80001a70 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001a32:	416485b3          	sub	a1,s1,s6
    80001a36:	858d                	srai	a1,a1,0x3
    80001a38:	000ab783          	ld	a5,0(s5)
    80001a3c:	02f585b3          	mul	a1,a1,a5
    80001a40:	2585                	addiw	a1,a1,1
    80001a42:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a46:	4719                	li	a4,6
    80001a48:	6685                	lui	a3,0x1
    80001a4a:	40b905b3          	sub	a1,s2,a1
    80001a4e:	854e                	mv	a0,s3
    80001a50:	f30ff0ef          	jal	ra,80001180 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a54:	3e848493          	addi	s1,s1,1000
    80001a58:	fd4499e3          	bne	s1,s4,80001a2a <proc_mapstacks+0x38>
  }
}
    80001a5c:	70e2                	ld	ra,56(sp)
    80001a5e:	7442                	ld	s0,48(sp)
    80001a60:	74a2                	ld	s1,40(sp)
    80001a62:	7902                	ld	s2,32(sp)
    80001a64:	69e2                	ld	s3,24(sp)
    80001a66:	6a42                	ld	s4,16(sp)
    80001a68:	6aa2                	ld	s5,8(sp)
    80001a6a:	6b02                	ld	s6,0(sp)
    80001a6c:	6121                	addi	sp,sp,64
    80001a6e:	8082                	ret
      panic("kalloc");
    80001a70:	00006517          	auipc	a0,0x6
    80001a74:	70850513          	addi	a0,a0,1800 # 80008178 <digits+0x140>
    80001a78:	d11fe0ef          	jal	ra,80000788 <panic>

0000000080001a7c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a7c:	7139                	addi	sp,sp,-64
    80001a7e:	fc06                	sd	ra,56(sp)
    80001a80:	f822                	sd	s0,48(sp)
    80001a82:	f426                	sd	s1,40(sp)
    80001a84:	f04a                	sd	s2,32(sp)
    80001a86:	ec4e                	sd	s3,24(sp)
    80001a88:	e852                	sd	s4,16(sp)
    80001a8a:	e456                	sd	s5,8(sp)
    80001a8c:	e05a                	sd	s6,0(sp)
    80001a8e:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a90:	00006597          	auipc	a1,0x6
    80001a94:	6f058593          	addi	a1,a1,1776 # 80008180 <digits+0x148>
    80001a98:	0022f517          	auipc	a0,0x22f
    80001a9c:	f5850513          	addi	a0,a0,-168 # 802309f0 <pid_lock>
    80001aa0:	980ff0ef          	jal	ra,80000c20 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001aa4:	00006597          	auipc	a1,0x6
    80001aa8:	6e458593          	addi	a1,a1,1764 # 80008188 <digits+0x150>
    80001aac:	0022f517          	auipc	a0,0x22f
    80001ab0:	f5c50513          	addi	a0,a0,-164 # 80230a08 <wait_lock>
    80001ab4:	96cff0ef          	jal	ra,80000c20 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab8:	0022f497          	auipc	s1,0x22f
    80001abc:	36848493          	addi	s1,s1,872 # 80230e20 <proc>
      initlock(&p->lock, "proc");
    80001ac0:	00006b17          	auipc	s6,0x6
    80001ac4:	6d8b0b13          	addi	s6,s6,1752 # 80008198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001ac8:	8aa6                	mv	s5,s1
    80001aca:	00006a17          	auipc	s4,0x6
    80001ace:	536a0a13          	addi	s4,s4,1334 # 80008000 <etext>
    80001ad2:	04000937          	lui	s2,0x4000
    80001ad6:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ad8:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ada:	0023f997          	auipc	s3,0x23f
    80001ade:	d4698993          	addi	s3,s3,-698 # 80240820 <tickslock>
      initlock(&p->lock, "proc");
    80001ae2:	85da                	mv	a1,s6
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	93aff0ef          	jal	ra,80000c20 <initlock>
      p->state = UNUSED;
    80001aea:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001aee:	415487b3          	sub	a5,s1,s5
    80001af2:	878d                	srai	a5,a5,0x3
    80001af4:	000a3703          	ld	a4,0(s4)
    80001af8:	02e787b3          	mul	a5,a5,a4
    80001afc:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fdaae51>
    80001afe:	00d7979b          	slliw	a5,a5,0xd
    80001b02:	40f907b3          	sub	a5,s2,a5
    80001b06:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b08:	3e848493          	addi	s1,s1,1000
    80001b0c:	fd349be3          	bne	s1,s3,80001ae2 <procinit+0x66>
  }
}
    80001b10:	70e2                	ld	ra,56(sp)
    80001b12:	7442                	ld	s0,48(sp)
    80001b14:	74a2                	ld	s1,40(sp)
    80001b16:	7902                	ld	s2,32(sp)
    80001b18:	69e2                	ld	s3,24(sp)
    80001b1a:	6a42                	ld	s4,16(sp)
    80001b1c:	6aa2                	ld	s5,8(sp)
    80001b1e:	6b02                	ld	s6,0(sp)
    80001b20:	6121                	addi	sp,sp,64
    80001b22:	8082                	ret

0000000080001b24 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b24:	1141                	addi	sp,sp,-16
    80001b26:	e422                	sd	s0,8(sp)
    80001b28:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b2a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b2c:	2501                	sext.w	a0,a0
    80001b2e:	6422                	ld	s0,8(sp)
    80001b30:	0141                	addi	sp,sp,16
    80001b32:	8082                	ret

0000000080001b34 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001b34:	1141                	addi	sp,sp,-16
    80001b36:	e422                	sd	s0,8(sp)
    80001b38:	0800                	addi	s0,sp,16
    80001b3a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b3c:	2781                	sext.w	a5,a5
    80001b3e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b40:	0022f517          	auipc	a0,0x22f
    80001b44:	ee050513          	addi	a0,a0,-288 # 80230a20 <cpus>
    80001b48:	953e                	add	a0,a0,a5
    80001b4a:	6422                	ld	s0,8(sp)
    80001b4c:	0141                	addi	sp,sp,16
    80001b4e:	8082                	ret

0000000080001b50 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	1000                	addi	s0,sp,32
  push_off();
    80001b5a:	906ff0ef          	jal	ra,80000c60 <push_off>
    80001b5e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b60:	2781                	sext.w	a5,a5
    80001b62:	079e                	slli	a5,a5,0x7
    80001b64:	0022f717          	auipc	a4,0x22f
    80001b68:	e8c70713          	addi	a4,a4,-372 # 802309f0 <pid_lock>
    80001b6c:	97ba                	add	a5,a5,a4
    80001b6e:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b70:	974ff0ef          	jal	ra,80000ce4 <pop_off>
  return p;
}
    80001b74:	8526                	mv	a0,s1
    80001b76:	60e2                	ld	ra,24(sp)
    80001b78:	6442                	ld	s0,16(sp)
    80001b7a:	64a2                	ld	s1,8(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret

0000000080001b80 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b80:	7179                	addi	sp,sp,-48
    80001b82:	f406                	sd	ra,40(sp)
    80001b84:	f022                	sd	s0,32(sp)
    80001b86:	ec26                	sd	s1,24(sp)
    80001b88:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b8a:	fc7ff0ef          	jal	ra,80001b50 <myproc>
    80001b8e:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b90:	9a8ff0ef          	jal	ra,80000d38 <release>

  if (first) {
    80001b94:	00007797          	auipc	a5,0x7
    80001b98:	cec7a783          	lw	a5,-788(a5) # 80008880 <first.1>
    80001b9c:	cf8d                	beqz	a5,80001bd6 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b9e:	4505                	li	a0,1
    80001ba0:	53c020ef          	jal	ra,800040dc <fsinit>

    first = 0;
    80001ba4:	00007797          	auipc	a5,0x7
    80001ba8:	cc07ae23          	sw	zero,-804(a5) # 80008880 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001bac:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001bb0:	00006517          	auipc	a0,0x6
    80001bb4:	5f050513          	addi	a0,a0,1520 # 800081a0 <digits+0x168>
    80001bb8:	fca43823          	sd	a0,-48(s0)
    80001bbc:	fc043c23          	sd	zero,-40(s0)
    80001bc0:	fd040593          	addi	a1,s0,-48
    80001bc4:	5c6030ef          	jal	ra,8000518a <kexec>
    80001bc8:	6cbc                	ld	a5,88(s1)
    80001bca:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001bcc:	6cbc                	ld	a5,88(s1)
    80001bce:	7bb8                	ld	a4,112(a5)
    80001bd0:	57fd                	li	a5,-1
    80001bd2:	02f70d63          	beq	a4,a5,80001c0c <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001bd6:	5a5000ef          	jal	ra,8000297a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001bda:	68a8                	ld	a0,80(s1)
    80001bdc:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001bde:	04000737          	lui	a4,0x4000
    80001be2:	00005797          	auipc	a5,0x5
    80001be6:	4ba78793          	addi	a5,a5,1210 # 8000709c <userret>
    80001bea:	00005697          	auipc	a3,0x5
    80001bee:	41668693          	addi	a3,a3,1046 # 80007000 <_trampoline>
    80001bf2:	8f95                	sub	a5,a5,a3
    80001bf4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001bf6:	0732                	slli	a4,a4,0xc
    80001bf8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001bfa:	577d                	li	a4,-1
    80001bfc:	177e                	slli	a4,a4,0x3f
    80001bfe:	8d59                	or	a0,a0,a4
    80001c00:	9782                	jalr	a5
}
    80001c02:	70a2                	ld	ra,40(sp)
    80001c04:	7402                	ld	s0,32(sp)
    80001c06:	64e2                	ld	s1,24(sp)
    80001c08:	6145                	addi	sp,sp,48
    80001c0a:	8082                	ret
      panic("exec");
    80001c0c:	00006517          	auipc	a0,0x6
    80001c10:	59c50513          	addi	a0,a0,1436 # 800081a8 <digits+0x170>
    80001c14:	b75fe0ef          	jal	ra,80000788 <panic>

0000000080001c18 <allocpid>:
{
    80001c18:	1101                	addi	sp,sp,-32
    80001c1a:	ec06                	sd	ra,24(sp)
    80001c1c:	e822                	sd	s0,16(sp)
    80001c1e:	e426                	sd	s1,8(sp)
    80001c20:	e04a                	sd	s2,0(sp)
    80001c22:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c24:	0022f917          	auipc	s2,0x22f
    80001c28:	dcc90913          	addi	s2,s2,-564 # 802309f0 <pid_lock>
    80001c2c:	854a                	mv	a0,s2
    80001c2e:	872ff0ef          	jal	ra,80000ca0 <acquire>
  pid = nextpid;
    80001c32:	00007797          	auipc	a5,0x7
    80001c36:	c5278793          	addi	a5,a5,-942 # 80008884 <nextpid>
    80001c3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c3c:	0014871b          	addiw	a4,s1,1
    80001c40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c42:	854a                	mv	a0,s2
    80001c44:	8f4ff0ef          	jal	ra,80000d38 <release>
}
    80001c48:	8526                	mv	a0,s1
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6902                	ld	s2,0(sp)
    80001c52:	6105                	addi	sp,sp,32
    80001c54:	8082                	ret

0000000080001c56 <delete_shm_from_vmas>:
delete_shm_from_vmas(struct vma *vmas){
    80001c56:	7139                	addi	sp,sp,-64
    80001c58:	fc06                	sd	ra,56(sp)
    80001c5a:	f822                	sd	s0,48(sp)
    80001c5c:	f426                	sd	s1,40(sp)
    80001c5e:	f04a                	sd	s2,32(sp)
    80001c60:	ec4e                	sd	s3,24(sp)
    80001c62:	e852                	sd	s4,16(sp)
    80001c64:	e456                	sd	s5,8(sp)
    80001c66:	0080                	addi	s0,sp,64
    80001c68:	8a2a                	mv	s4,a0
    80001c6a:	84aa                	mv	s1,a0
  for(int i = 0; i < NVMA; i++){
    80001c6c:	4901                	li	s2,0
    80001c6e:	02850a93          	addi	s5,a0,40
    80001c72:	49c1                	li	s3,16
    80001c74:	a025                	j	80001c9c <delete_shm_from_vmas+0x46>
    for(int j = 0; j < i; j++){
    80001c76:	02878793          	addi	a5,a5,40
    80001c7a:	00d78a63          	beq	a5,a3,80001c8e <delete_shm_from_vmas+0x38>
      if(vmas[j].used && vmas[j].is_shm && vmas[j].shm_key == key){
    80001c7e:	4398                	lw	a4,0(a5)
    80001c80:	db7d                	beqz	a4,80001c76 <delete_shm_from_vmas+0x20>
    80001c82:	5398                	lw	a4,32(a5)
    80001c84:	db6d                	beqz	a4,80001c76 <delete_shm_from_vmas+0x20>
    80001c86:	53d8                	lw	a4,36(a5)
    80001c88:	fea717e3          	bne	a4,a0,80001c76 <delete_shm_from_vmas+0x20>
    80001c8c:	a019                	j	80001c92 <delete_shm_from_vmas+0x3c>
    shm_put(key);
    80001c8e:	1c3040ef          	jal	ra,80006650 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001c92:	2905                	addiw	s2,s2,1
    80001c94:	02848493          	addi	s1,s1,40
    80001c98:	03390463          	beq	s2,s3,80001cc0 <delete_shm_from_vmas+0x6a>
    if(!vmas[i].used || !vmas[i].is_shm) continue;
    80001c9c:	409c                	lw	a5,0(s1)
    80001c9e:	dbf5                	beqz	a5,80001c92 <delete_shm_from_vmas+0x3c>
    80001ca0:	509c                	lw	a5,32(s1)
    80001ca2:	dbe5                	beqz	a5,80001c92 <delete_shm_from_vmas+0x3c>
    int key = vmas[i].shm_key;
    80001ca4:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001ca6:	ff2054e3          	blez	s2,80001c8e <delete_shm_from_vmas+0x38>
    80001caa:	fff9079b          	addiw	a5,s2,-1
    80001cae:	1782                	slli	a5,a5,0x20
    80001cb0:	9381                	srli	a5,a5,0x20
    80001cb2:	00279693          	slli	a3,a5,0x2
    80001cb6:	96be                	add	a3,a3,a5
    80001cb8:	068e                	slli	a3,a3,0x3
    80001cba:	96d6                	add	a3,a3,s5
    80001cbc:	87d2                	mv	a5,s4
    80001cbe:	b7c1                	j	80001c7e <delete_shm_from_vmas+0x28>
}
    80001cc0:	70e2                	ld	ra,56(sp)
    80001cc2:	7442                	ld	s0,48(sp)
    80001cc4:	74a2                	ld	s1,40(sp)
    80001cc6:	7902                	ld	s2,32(sp)
    80001cc8:	69e2                	ld	s3,24(sp)
    80001cca:	6a42                	ld	s4,16(sp)
    80001ccc:	6aa2                	ld	s5,8(sp)
    80001cce:	6121                	addi	sp,sp,64
    80001cd0:	8082                	ret

0000000080001cd2 <delete_shm_from_proc>:
delete_shm_from_proc(struct proc *p){
    80001cd2:	7139                	addi	sp,sp,-64
    80001cd4:	fc06                	sd	ra,56(sp)
    80001cd6:	f822                	sd	s0,48(sp)
    80001cd8:	f426                	sd	s1,40(sp)
    80001cda:	f04a                	sd	s2,32(sp)
    80001cdc:	ec4e                	sd	s3,24(sp)
    80001cde:	e852                	sd	s4,16(sp)
    80001ce0:	e456                	sd	s5,8(sp)
    80001ce2:	0080                	addi	s0,sp,64
  for(int i = 0; i < NVMA; i++){
    80001ce4:	16850a93          	addi	s5,a0,360
delete_shm_from_proc(struct proc *p){
    80001ce8:	84d6                	mv	s1,s5
  for(int i = 0; i < NVMA; i++){
    80001cea:	4901                	li	s2,0
    80001cec:	19050a13          	addi	s4,a0,400
    80001cf0:	49c1                	li	s3,16
    80001cf2:	a025                	j	80001d1a <delete_shm_from_proc+0x48>
    for(int j = 0; j < i; j++){
    80001cf4:	02878793          	addi	a5,a5,40
    80001cf8:	00d78a63          	beq	a5,a3,80001d0c <delete_shm_from_proc+0x3a>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001cfc:	4398                	lw	a4,0(a5)
    80001cfe:	db7d                	beqz	a4,80001cf4 <delete_shm_from_proc+0x22>
    80001d00:	5398                	lw	a4,32(a5)
    80001d02:	db6d                	beqz	a4,80001cf4 <delete_shm_from_proc+0x22>
    80001d04:	53d8                	lw	a4,36(a5)
    80001d06:	fea717e3          	bne	a4,a0,80001cf4 <delete_shm_from_proc+0x22>
    80001d0a:	a019                	j	80001d10 <delete_shm_from_proc+0x3e>
    shm_put(key);
    80001d0c:	145040ef          	jal	ra,80006650 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001d10:	2905                	addiw	s2,s2,1
    80001d12:	02848493          	addi	s1,s1,40
    80001d16:	03390463          	beq	s2,s3,80001d3e <delete_shm_from_proc+0x6c>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001d1a:	409c                	lw	a5,0(s1)
    80001d1c:	dbf5                	beqz	a5,80001d10 <delete_shm_from_proc+0x3e>
    80001d1e:	509c                	lw	a5,32(s1)
    80001d20:	dbe5                	beqz	a5,80001d10 <delete_shm_from_proc+0x3e>
    int key = p->vmas[i].shm_key;
    80001d22:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    80001d24:	ff2054e3          	blez	s2,80001d0c <delete_shm_from_proc+0x3a>
    80001d28:	fff9079b          	addiw	a5,s2,-1
    80001d2c:	1782                	slli	a5,a5,0x20
    80001d2e:	9381                	srli	a5,a5,0x20
    80001d30:	00279693          	slli	a3,a5,0x2
    80001d34:	96be                	add	a3,a3,a5
    80001d36:	068e                	slli	a3,a3,0x3
    80001d38:	96d2                	add	a3,a3,s4
    80001d3a:	87d6                	mv	a5,s5
    80001d3c:	b7c1                	j	80001cfc <delete_shm_from_proc+0x2a>
}
    80001d3e:	70e2                	ld	ra,56(sp)
    80001d40:	7442                	ld	s0,48(sp)
    80001d42:	74a2                	ld	s1,40(sp)
    80001d44:	7902                	ld	s2,32(sp)
    80001d46:	69e2                	ld	s3,24(sp)
    80001d48:	6a42                	ld	s4,16(sp)
    80001d4a:	6aa2                	ld	s5,8(sp)
    80001d4c:	6121                	addi	sp,sp,64
    80001d4e:	8082                	ret

0000000080001d50 <vma_release_all>:
{
    80001d50:	7139                	addi	sp,sp,-64
    80001d52:	fc06                	sd	ra,56(sp)
    80001d54:	f822                	sd	s0,48(sp)
    80001d56:	f426                	sd	s1,40(sp)
    80001d58:	f04a                	sd	s2,32(sp)
    80001d5a:	ec4e                	sd	s3,24(sp)
    80001d5c:	e852                	sd	s4,16(sp)
    80001d5e:	e456                	sd	s5,8(sp)
    80001d60:	e05a                	sd	s6,0(sp)
    80001d62:	0080                	addi	s0,sp,64
    80001d64:	8b2a                	mv	s6,a0
  for(int i = 0; i < NVMA; i++){
    80001d66:	16850493          	addi	s1,a0,360
    80001d6a:	3e850a13          	addi	s4,a0,1000
{
    80001d6e:	8926                	mv	s2,s1
    80001d70:	a029                	j	80001d7a <vma_release_all+0x2a>
  for(int i = 0; i < NVMA; i++){
    80001d72:	02890913          	addi	s2,s2,40
    80001d76:	03490663          	beq	s2,s4,80001da2 <vma_release_all+0x52>
    if(!v->used) continue;
    80001d7a:	00092783          	lw	a5,0(s2)
    80001d7e:	dbf5                	beqz	a5,80001d72 <vma_release_all+0x22>
    uint64 start = v->start;
    80001d80:	00893583          	ld	a1,8(s2)
    uint64 end   = v->end;
    80001d84:	01093603          	ld	a2,16(s2)
    if(end <= start) continue;
    80001d88:	fec5f5e3          	bgeu	a1,a2,80001d72 <vma_release_all+0x22>
    int do_free = (v->is_shm ? 0 : 1);
    80001d8c:	02092683          	lw	a3,32(s2)
    uint64 npages = (end - start) / PGSIZE;
    80001d90:	8e0d                	sub	a2,a2,a1
    uvmunmap(p->pagetable, start, npages, do_free);
    80001d92:	0016b693          	seqz	a3,a3
    80001d96:	8231                	srli	a2,a2,0xc
    80001d98:	050b3503          	ld	a0,80(s6)
    80001d9c:	d00ff0ef          	jal	ra,8000129c <uvmunmap>
    80001da0:	bfc9                	j	80001d72 <vma_release_all+0x22>
    80001da2:	8926                	mv	s2,s1
  for(int i = 0; i < NVMA; i++){
    80001da4:	4981                	li	s3,0
    80001da6:	190b0b13          	addi	s6,s6,400
    80001daa:	4ac1                	li	s5,16
    80001dac:	a891                	j	80001e00 <vma_release_all+0xb0>
    for(int j = 0; j < i; j++){
    80001dae:	02878793          	addi	a5,a5,40
    80001db2:	04d78063          	beq	a5,a3,80001df2 <vma_release_all+0xa2>
      if(p->vmas[j].used && p->vmas[j].is_shm && p->vmas[j].shm_key == key){
    80001db6:	4398                	lw	a4,0(a5)
    80001db8:	db7d                	beqz	a4,80001dae <vma_release_all+0x5e>
    80001dba:	5398                	lw	a4,32(a5)
    80001dbc:	db6d                	beqz	a4,80001dae <vma_release_all+0x5e>
    80001dbe:	53d8                	lw	a4,36(a5)
    80001dc0:	fea717e3          	bne	a4,a0,80001dae <vma_release_all+0x5e>
    80001dc4:	a80d                	j	80001df6 <vma_release_all+0xa6>
      p->vmas[i].shm_key = -1;
    80001dc6:	577d                	li	a4,-1
    80001dc8:	a029                	j	80001dd2 <vma_release_all+0x82>
  for(int i = 0; i < NVMA; i++){
    80001dca:	02848493          	addi	s1,s1,40
    80001dce:	05448e63          	beq	s1,s4,80001e2a <vma_release_all+0xda>
    if(p->vmas[i].used){
    80001dd2:	409c                	lw	a5,0(s1)
    80001dd4:	dbfd                	beqz	a5,80001dca <vma_release_all+0x7a>
      p->vmas[i].used = 0;
    80001dd6:	0004a023          	sw	zero,0(s1)
      p->vmas[i].is_shm = 0;
    80001dda:	0204a023          	sw	zero,32(s1)
      p->vmas[i].shm_key = -1;
    80001dde:	d0d8                	sw	a4,36(s1)
      p->vmas[i].start = p->vmas[i].end = 0;
    80001de0:	0004b823          	sd	zero,16(s1)
    80001de4:	0004b423          	sd	zero,8(s1)
      p->vmas[i].prot = p->vmas[i].flags = 0;
    80001de8:	0004ae23          	sw	zero,28(s1)
    80001dec:	0004ac23          	sw	zero,24(s1)
    80001df0:	bfe9                	j	80001dca <vma_release_all+0x7a>
    shm_put(key);
    80001df2:	05f040ef          	jal	ra,80006650 <shm_put>
  for(int i = 0; i < NVMA; i++){
    80001df6:	2985                	addiw	s3,s3,1
    80001df8:	02890913          	addi	s2,s2,40
    80001dfc:	fd5985e3          	beq	s3,s5,80001dc6 <vma_release_all+0x76>
    if(!p->vmas[i].used || !p->vmas[i].is_shm) continue;
    80001e00:	00092783          	lw	a5,0(s2)
    80001e04:	dbed                	beqz	a5,80001df6 <vma_release_all+0xa6>
    80001e06:	02092783          	lw	a5,32(s2)
    80001e0a:	d7f5                	beqz	a5,80001df6 <vma_release_all+0xa6>
    int key = p->vmas[i].shm_key;
    80001e0c:	02492503          	lw	a0,36(s2)
    for(int j = 0; j < i; j++){
    80001e10:	ff3051e3          	blez	s3,80001df2 <vma_release_all+0xa2>
    80001e14:	fff9879b          	addiw	a5,s3,-1
    80001e18:	1782                	slli	a5,a5,0x20
    80001e1a:	9381                	srli	a5,a5,0x20
    80001e1c:	00279693          	slli	a3,a5,0x2
    80001e20:	96be                	add	a3,a3,a5
    80001e22:	068e                	slli	a3,a3,0x3
    80001e24:	96da                	add	a3,a3,s6
    80001e26:	87a6                	mv	a5,s1
    80001e28:	b779                	j	80001db6 <vma_release_all+0x66>
}
    80001e2a:	70e2                	ld	ra,56(sp)
    80001e2c:	7442                	ld	s0,48(sp)
    80001e2e:	74a2                	ld	s1,40(sp)
    80001e30:	7902                	ld	s2,32(sp)
    80001e32:	69e2                	ld	s3,24(sp)
    80001e34:	6a42                	ld	s4,16(sp)
    80001e36:	6aa2                	ld	s5,8(sp)
    80001e38:	6b02                	ld	s6,0(sp)
    80001e3a:	6121                	addi	sp,sp,64
    80001e3c:	8082                	ret

0000000080001e3e <proc_pagetable>:
{
    80001e3e:	1101                	addi	sp,sp,-32
    80001e40:	ec06                	sd	ra,24(sp)
    80001e42:	e822                	sd	s0,16(sp)
    80001e44:	e426                	sd	s1,8(sp)
    80001e46:	e04a                	sd	s2,0(sp)
    80001e48:	1000                	addi	s0,sp,32
    80001e4a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e4c:	c2aff0ef          	jal	ra,80001276 <uvmcreate>
    80001e50:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e52:	cd05                	beqz	a0,80001e8a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e54:	4729                	li	a4,10
    80001e56:	00005697          	auipc	a3,0x5
    80001e5a:	1aa68693          	addi	a3,a3,426 # 80007000 <_trampoline>
    80001e5e:	6605                	lui	a2,0x1
    80001e60:	040005b7          	lui	a1,0x4000
    80001e64:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e66:	05b2                	slli	a1,a1,0xc
    80001e68:	a68ff0ef          	jal	ra,800010d0 <mappages>
    80001e6c:	02054663          	bltz	a0,80001e98 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e70:	4719                	li	a4,6
    80001e72:	05893683          	ld	a3,88(s2)
    80001e76:	6605                	lui	a2,0x1
    80001e78:	020005b7          	lui	a1,0x2000
    80001e7c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e7e:	05b6                	slli	a1,a1,0xd
    80001e80:	8526                	mv	a0,s1
    80001e82:	a4eff0ef          	jal	ra,800010d0 <mappages>
    80001e86:	00054f63          	bltz	a0,80001ea4 <proc_pagetable+0x66>
}
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	60e2                	ld	ra,24(sp)
    80001e8e:	6442                	ld	s0,16(sp)
    80001e90:	64a2                	ld	s1,8(sp)
    80001e92:	6902                	ld	s2,0(sp)
    80001e94:	6105                	addi	sp,sp,32
    80001e96:	8082                	ret
    uvmfree(pagetable, 0);
    80001e98:	4581                	li	a1,0
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	dbaff0ef          	jal	ra,80001456 <uvmfree>
    return 0;
    80001ea0:	4481                	li	s1,0
    80001ea2:	b7e5                	j	80001e8a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ea4:	4681                	li	a3,0
    80001ea6:	4605                	li	a2,1
    80001ea8:	040005b7          	lui	a1,0x4000
    80001eac:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001eae:	05b2                	slli	a1,a1,0xc
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	beaff0ef          	jal	ra,8000129c <uvmunmap>
    uvmfree(pagetable, 0);
    80001eb6:	4581                	li	a1,0
    80001eb8:	8526                	mv	a0,s1
    80001eba:	d9cff0ef          	jal	ra,80001456 <uvmfree>
    return 0;
    80001ebe:	4481                	li	s1,0
    80001ec0:	b7e9                	j	80001e8a <proc_pagetable+0x4c>

0000000080001ec2 <vma_unmap_pagetable>:
{
    80001ec2:	7179                	addi	sp,sp,-48
    80001ec4:	f406                	sd	ra,40(sp)
    80001ec6:	f022                	sd	s0,32(sp)
    80001ec8:	ec26                	sd	s1,24(sp)
    80001eca:	e84a                	sd	s2,16(sp)
    80001ecc:	e44e                	sd	s3,8(sp)
    80001ece:	1800                	addi	s0,sp,48
    80001ed0:	89aa                	mv	s3,a0
    80001ed2:	84ae                	mv	s1,a1
  for(int i = 0; i < NVMA; i++){
    80001ed4:	28058913          	addi	s2,a1,640
    80001ed8:	a811                	j	80001eec <vma_unmap_pagetable+0x2a>
        uvmunmap(pagetable, start, len/PGSIZE, 1);
    80001eda:	4685                	li	a3,1
    80001edc:	8231                	srli	a2,a2,0xc
    80001ede:	854e                	mv	a0,s3
    80001ee0:	bbcff0ef          	jal	ra,8000129c <uvmunmap>
  for(int i = 0; i < NVMA; i++){
    80001ee4:	02848493          	addi	s1,s1,40
    80001ee8:	01248b63          	beq	s1,s2,80001efe <vma_unmap_pagetable+0x3c>
    if(vmas[i].used){
    80001eec:	409c                	lw	a5,0(s1)
    80001eee:	dbfd                	beqz	a5,80001ee4 <vma_unmap_pagetable+0x22>
      uint64 start = vmas[i].start;
    80001ef0:	648c                	ld	a1,8(s1)
      uint64 len   = vmas[i].end - vmas[i].start;
    80001ef2:	689c                	ld	a5,16(s1)
    80001ef4:	40b78633          	sub	a2,a5,a1
      if(len > 0)
    80001ef8:	feb786e3          	beq	a5,a1,80001ee4 <vma_unmap_pagetable+0x22>
    80001efc:	bff9                	j	80001eda <vma_unmap_pagetable+0x18>
}
    80001efe:	70a2                	ld	ra,40(sp)
    80001f00:	7402                	ld	s0,32(sp)
    80001f02:	64e2                	ld	s1,24(sp)
    80001f04:	6942                	ld	s2,16(sp)
    80001f06:	69a2                	ld	s3,8(sp)
    80001f08:	6145                	addi	sp,sp,48
    80001f0a:	8082                	ret

0000000080001f0c <proc_freepagetable>:
{
    80001f0c:	1101                	addi	sp,sp,-32
    80001f0e:	ec06                	sd	ra,24(sp)
    80001f10:	e822                	sd	s0,16(sp)
    80001f12:	e426                	sd	s1,8(sp)
    80001f14:	e04a                	sd	s2,0(sp)
    80001f16:	1000                	addi	s0,sp,32
    80001f18:	84aa                	mv	s1,a0
    80001f1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f1c:	4681                	li	a3,0
    80001f1e:	4605                	li	a2,1
    80001f20:	040005b7          	lui	a1,0x4000
    80001f24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f26:	05b2                	slli	a1,a1,0xc
    80001f28:	b74ff0ef          	jal	ra,8000129c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f2c:	4681                	li	a3,0
    80001f2e:	4605                	li	a2,1
    80001f30:	020005b7          	lui	a1,0x2000
    80001f34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001f36:	05b6                	slli	a1,a1,0xd
    80001f38:	8526                	mv	a0,s1
    80001f3a:	b62ff0ef          	jal	ra,8000129c <uvmunmap>
  uvmfree(pagetable, sz);
    80001f3e:	85ca                	mv	a1,s2
    80001f40:	8526                	mv	a0,s1
    80001f42:	d14ff0ef          	jal	ra,80001456 <uvmfree>
}
    80001f46:	60e2                	ld	ra,24(sp)
    80001f48:	6442                	ld	s0,16(sp)
    80001f4a:	64a2                	ld	s1,8(sp)
    80001f4c:	6902                	ld	s2,0(sp)
    80001f4e:	6105                	addi	sp,sp,32
    80001f50:	8082                	ret

0000000080001f52 <freeproc>:
{
    80001f52:	1101                	addi	sp,sp,-32
    80001f54:	ec06                	sd	ra,24(sp)
    80001f56:	e822                	sd	s0,16(sp)
    80001f58:	e426                	sd	s1,8(sp)
    80001f5a:	e04a                	sd	s2,0(sp)
    80001f5c:	1000                	addi	s0,sp,32
    80001f5e:	84aa                	mv	s1,a0
  vma_release_all(p);
    80001f60:	df1ff0ef          	jal	ra,80001d50 <vma_release_all>
  if(p->trapframe)
    80001f64:	6ca8                	ld	a0,88(s1)
    80001f66:	c119                	beqz	a0,80001f6c <freeproc+0x1a>
    kfree((void*)p->trapframe);
    80001f68:	b13fe0ef          	jal	ra,80000a7a <kfree>
  p->trapframe = 0;
    80001f6c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable){
    80001f70:	68a8                	ld	a0,80(s1)
    80001f72:	c105                	beqz	a0,80001f92 <freeproc+0x40>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    80001f74:	16848913          	addi	s2,s1,360
    80001f78:	85ca                	mv	a1,s2
    80001f7a:	f49ff0ef          	jal	ra,80001ec2 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    80001f7e:	28000613          	li	a2,640
    80001f82:	4581                	li	a1,0
    80001f84:	854a                	mv	a0,s2
    80001f86:	deffe0ef          	jal	ra,80000d74 <memset>
    proc_freepagetable(p->pagetable, p->sz);
    80001f8a:	64ac                	ld	a1,72(s1)
    80001f8c:	68a8                	ld	a0,80(s1)
    80001f8e:	f7fff0ef          	jal	ra,80001f0c <proc_freepagetable>
  delete_shm_from_proc(p);
    80001f92:	8526                	mv	a0,s1
    80001f94:	d3fff0ef          	jal	ra,80001cd2 <delete_shm_from_proc>
  p->pagetable = 0;
    80001f98:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001f9c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001fa0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001fa4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001fa8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001fac:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001fb0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001fb4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001fb8:	0004ac23          	sw	zero,24(s1)
}
    80001fbc:	60e2                	ld	ra,24(sp)
    80001fbe:	6442                	ld	s0,16(sp)
    80001fc0:	64a2                	ld	s1,8(sp)
    80001fc2:	6902                	ld	s2,0(sp)
    80001fc4:	6105                	addi	sp,sp,32
    80001fc6:	8082                	ret

0000000080001fc8 <allocproc>:
{
    80001fc8:	1101                	addi	sp,sp,-32
    80001fca:	ec06                	sd	ra,24(sp)
    80001fcc:	e822                	sd	s0,16(sp)
    80001fce:	e426                	sd	s1,8(sp)
    80001fd0:	e04a                	sd	s2,0(sp)
    80001fd2:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fd4:	0022f497          	auipc	s1,0x22f
    80001fd8:	e4c48493          	addi	s1,s1,-436 # 80230e20 <proc>
    80001fdc:	0023f917          	auipc	s2,0x23f
    80001fe0:	84490913          	addi	s2,s2,-1980 # 80240820 <tickslock>
    acquire(&p->lock);
    80001fe4:	8526                	mv	a0,s1
    80001fe6:	cbbfe0ef          	jal	ra,80000ca0 <acquire>
    if(p->state == UNUSED) {
    80001fea:	4c9c                	lw	a5,24(s1)
    80001fec:	cb91                	beqz	a5,80002000 <allocproc+0x38>
      release(&p->lock);
    80001fee:	8526                	mv	a0,s1
    80001ff0:	d49fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ff4:	3e848493          	addi	s1,s1,1000
    80001ff8:	ff2496e3          	bne	s1,s2,80001fe4 <allocproc+0x1c>
  return 0;
    80001ffc:	4481                	li	s1,0
    80001ffe:	a089                	j	80002040 <allocproc+0x78>
  p->pid = allocpid();
    80002000:	c19ff0ef          	jal	ra,80001c18 <allocpid>
    80002004:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002006:	4785                	li	a5,1
    80002008:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000200a:	ba1fe0ef          	jal	ra,80000baa <kalloc>
    8000200e:	892a                	mv	s2,a0
    80002010:	eca8                	sd	a0,88(s1)
    80002012:	cd15                	beqz	a0,8000204e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80002014:	8526                	mv	a0,s1
    80002016:	e29ff0ef          	jal	ra,80001e3e <proc_pagetable>
    8000201a:	892a                	mv	s2,a0
    8000201c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000201e:	c121                	beqz	a0,8000205e <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80002020:	07000613          	li	a2,112
    80002024:	4581                	li	a1,0
    80002026:	06048513          	addi	a0,s1,96
    8000202a:	d4bfe0ef          	jal	ra,80000d74 <memset>
  p->context.ra = (uint64)forkret;
    8000202e:	00000797          	auipc	a5,0x0
    80002032:	b5278793          	addi	a5,a5,-1198 # 80001b80 <forkret>
    80002036:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002038:	60bc                	ld	a5,64(s1)
    8000203a:	6705                	lui	a4,0x1
    8000203c:	97ba                	add	a5,a5,a4
    8000203e:	f4bc                	sd	a5,104(s1)
}
    80002040:	8526                	mv	a0,s1
    80002042:	60e2                	ld	ra,24(sp)
    80002044:	6442                	ld	s0,16(sp)
    80002046:	64a2                	ld	s1,8(sp)
    80002048:	6902                	ld	s2,0(sp)
    8000204a:	6105                	addi	sp,sp,32
    8000204c:	8082                	ret
    freeproc(p);
    8000204e:	8526                	mv	a0,s1
    80002050:	f03ff0ef          	jal	ra,80001f52 <freeproc>
    release(&p->lock);
    80002054:	8526                	mv	a0,s1
    80002056:	ce3fe0ef          	jal	ra,80000d38 <release>
    return 0;
    8000205a:	84ca                	mv	s1,s2
    8000205c:	b7d5                	j	80002040 <allocproc+0x78>
    freeproc(p);
    8000205e:	8526                	mv	a0,s1
    80002060:	ef3ff0ef          	jal	ra,80001f52 <freeproc>
    release(&p->lock);
    80002064:	8526                	mv	a0,s1
    80002066:	cd3fe0ef          	jal	ra,80000d38 <release>
    return 0;
    8000206a:	84ca                	mv	s1,s2
    8000206c:	bfd1                	j	80002040 <allocproc+0x78>

000000008000206e <userinit>:
{
    8000206e:	1101                	addi	sp,sp,-32
    80002070:	ec06                	sd	ra,24(sp)
    80002072:	e822                	sd	s0,16(sp)
    80002074:	e426                	sd	s1,8(sp)
    80002076:	1000                	addi	s0,sp,32
  p = allocproc();
    80002078:	f51ff0ef          	jal	ra,80001fc8 <allocproc>
    8000207c:	84aa                	mv	s1,a0
  initproc = p;
    8000207e:	00007797          	auipc	a5,0x7
    80002082:	84a7b923          	sd	a0,-1966(a5) # 800088d0 <initproc>
  p->cwd = namei("/");
    80002086:	00006517          	auipc	a0,0x6
    8000208a:	12a50513          	addi	a0,a0,298 # 800081b0 <digits+0x178>
    8000208e:	552020ef          	jal	ra,800045e0 <namei>
    80002092:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002096:	478d                	li	a5,3
    80002098:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000209a:	8526                	mv	a0,s1
    8000209c:	c9dfe0ef          	jal	ra,80000d38 <release>
}
    800020a0:	60e2                	ld	ra,24(sp)
    800020a2:	6442                	ld	s0,16(sp)
    800020a4:	64a2                	ld	s1,8(sp)
    800020a6:	6105                	addi	sp,sp,32
    800020a8:	8082                	ret

00000000800020aa <growproc>:
{
    800020aa:	1101                	addi	sp,sp,-32
    800020ac:	ec06                	sd	ra,24(sp)
    800020ae:	e822                	sd	s0,16(sp)
    800020b0:	e426                	sd	s1,8(sp)
    800020b2:	e04a                	sd	s2,0(sp)
    800020b4:	1000                	addi	s0,sp,32
    800020b6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020b8:	a99ff0ef          	jal	ra,80001b50 <myproc>
    800020bc:	892a                	mv	s2,a0
  sz = p->sz;
    800020be:	652c                	ld	a1,72(a0)
  if(n > 0){
    800020c0:	02905963          	blez	s1,800020f2 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    800020c4:	00b48633          	add	a2,s1,a1
    800020c8:	020007b7          	lui	a5,0x2000
    800020cc:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    800020ce:	07b6                	slli	a5,a5,0xd
    800020d0:	02c7ea63          	bltu	a5,a2,80002104 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800020d4:	4691                	li	a3,4
    800020d6:	6928                	ld	a0,80(a0)
    800020d8:	a84ff0ef          	jal	ra,8000135c <uvmalloc>
    800020dc:	85aa                	mv	a1,a0
    800020de:	c50d                	beqz	a0,80002108 <growproc+0x5e>
  p->sz = sz;
    800020e0:	04b93423          	sd	a1,72(s2)
  return 0;
    800020e4:	4501                	li	a0,0
}
    800020e6:	60e2                	ld	ra,24(sp)
    800020e8:	6442                	ld	s0,16(sp)
    800020ea:	64a2                	ld	s1,8(sp)
    800020ec:	6902                	ld	s2,0(sp)
    800020ee:	6105                	addi	sp,sp,32
    800020f0:	8082                	ret
  } else if(n < 0){
    800020f2:	fe04d7e3          	bgez	s1,800020e0 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020f6:	00b48633          	add	a2,s1,a1
    800020fa:	6928                	ld	a0,80(a0)
    800020fc:	a1cff0ef          	jal	ra,80001318 <uvmdealloc>
    80002100:	85aa                	mv	a1,a0
    80002102:	bff9                	j	800020e0 <growproc+0x36>
      return -1;
    80002104:	557d                	li	a0,-1
    80002106:	b7c5                	j	800020e6 <growproc+0x3c>
      return -1;
    80002108:	557d                	li	a0,-1
    8000210a:	bff1                	j	800020e6 <growproc+0x3c>

000000008000210c <kfork>:
{
    8000210c:	715d                	addi	sp,sp,-80
    8000210e:	e486                	sd	ra,72(sp)
    80002110:	e0a2                	sd	s0,64(sp)
    80002112:	fc26                	sd	s1,56(sp)
    80002114:	f84a                	sd	s2,48(sp)
    80002116:	f44e                	sd	s3,40(sp)
    80002118:	f052                	sd	s4,32(sp)
    8000211a:	ec56                	sd	s5,24(sp)
    8000211c:	e85a                	sd	s6,16(sp)
    8000211e:	e45e                	sd	s7,8(sp)
    80002120:	e062                	sd	s8,0(sp)
    80002122:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    80002124:	a2dff0ef          	jal	ra,80001b50 <myproc>
    80002128:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000212a:	e9fff0ef          	jal	ra,80001fc8 <allocproc>
    8000212e:	12050963          	beqz	a0,80002260 <kfork+0x154>
    80002132:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002134:	048ab603          	ld	a2,72(s5)
    80002138:	692c                	ld	a1,80(a0)
    8000213a:	050ab503          	ld	a0,80(s5)
    8000213e:	b4aff0ef          	jal	ra,80001488 <uvmcopy>
    80002142:	04054863          	bltz	a0,80002192 <kfork+0x86>
  np->sz = p->sz;
    80002146:	048ab783          	ld	a5,72(s5)
    8000214a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000214e:	058ab683          	ld	a3,88(s5)
    80002152:	87b6                	mv	a5,a3
    80002154:	0589b703          	ld	a4,88(s3)
    80002158:	12068693          	addi	a3,a3,288
    8000215c:	0007b803          	ld	a6,0(a5)
    80002160:	6788                	ld	a0,8(a5)
    80002162:	6b8c                	ld	a1,16(a5)
    80002164:	6f90                	ld	a2,24(a5)
    80002166:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000216a:	e708                	sd	a0,8(a4)
    8000216c:	eb0c                	sd	a1,16(a4)
    8000216e:	ef10                	sd	a2,24(a4)
    80002170:	02078793          	addi	a5,a5,32
    80002174:	02070713          	addi	a4,a4,32
    80002178:	fed792e3          	bne	a5,a3,8000215c <kfork+0x50>
  np->trapframe->a0 = 0;
    8000217c:	0589b783          	ld	a5,88(s3)
    80002180:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002184:	0d0a8493          	addi	s1,s5,208
    80002188:	0d098913          	addi	s2,s3,208
    8000218c:	150a8a13          	addi	s4,s5,336
    80002190:	a829                	j	800021aa <kfork+0x9e>
    freeproc(np);
    80002192:	854e                	mv	a0,s3
    80002194:	dbfff0ef          	jal	ra,80001f52 <freeproc>
    release(&np->lock);
    80002198:	854e                	mv	a0,s3
    8000219a:	b9ffe0ef          	jal	ra,80000d38 <release>
    return -1;
    8000219e:	5c7d                	li	s8,-1
    800021a0:	a05d                	j	80002246 <kfork+0x13a>
  for(i = 0; i < NOFILE; i++)
    800021a2:	04a1                	addi	s1,s1,8
    800021a4:	0921                	addi	s2,s2,8
    800021a6:	01448963          	beq	s1,s4,800021b8 <kfork+0xac>
    if(p->ofile[i])
    800021aa:	6088                	ld	a0,0(s1)
    800021ac:	d97d                	beqz	a0,800021a2 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    800021ae:	1eb020ef          	jal	ra,80004b98 <filedup>
    800021b2:	00a93023          	sd	a0,0(s2)
    800021b6:	b7f5                	j	800021a2 <kfork+0x96>
  np->cwd = idup(p->cwd);
    800021b8:	150ab503          	ld	a0,336(s5)
    800021bc:	3fb010ef          	jal	ra,80003db6 <idup>
    800021c0:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800021c4:	4641                	li	a2,16
    800021c6:	158a8593          	addi	a1,s5,344
    800021ca:	15898513          	addi	a0,s3,344
    800021ce:	cedfe0ef          	jal	ra,80000eba <safestrcpy>
  pid = np->pid;
    800021d2:	0309ac03          	lw	s8,48(s3)
  release(&np->lock);
    800021d6:	854e                	mv	a0,s3
    800021d8:	b61fe0ef          	jal	ra,80000d38 <release>
  memmove(np->vmas, p->vmas, sizeof(p->vmas));
    800021dc:	16898b13          	addi	s6,s3,360
    800021e0:	28000613          	li	a2,640
    800021e4:	168a8593          	addi	a1,s5,360
    800021e8:	855a                	mv	a0,s6
    800021ea:	be7fe0ef          	jal	ra,80000dd0 <memmove>
    800021ee:	84da                	mv	s1,s6
  for(int i = 0; i < NVMA; i++){
    800021f0:	4901                	li	s2,0
    800021f2:	19098b93          	addi	s7,s3,400
    800021f6:	4a41                	li	s4,16
    800021f8:	a069                	j	80002282 <kfork+0x176>
    for(int j = 0; j < i; j++){
    800021fa:	02878793          	addi	a5,a5,40
    800021fe:	06d78363          	beq	a5,a3,80002264 <kfork+0x158>
      if(np->vmas[j].used && np->vmas[j].is_shm && np->vmas[j].shm_key == key){
    80002202:	4398                	lw	a4,0(a5)
    80002204:	db7d                	beqz	a4,800021fa <kfork+0xee>
    80002206:	5398                	lw	a4,32(a5)
    80002208:	db6d                	beqz	a4,800021fa <kfork+0xee>
    8000220a:	53d8                	lw	a4,36(a5)
    8000220c:	fea717e3          	bne	a4,a0,800021fa <kfork+0xee>
    80002210:	a0a5                	j	80002278 <kfork+0x16c>
        freeproc(np);
    80002212:	854e                	mv	a0,s3
    80002214:	d3fff0ef          	jal	ra,80001f52 <freeproc>
        return -1;
    80002218:	5c7d                	li	s8,-1
    8000221a:	a035                	j	80002246 <kfork+0x13a>
  acquire(&wait_lock);
    8000221c:	0022e497          	auipc	s1,0x22e
    80002220:	7ec48493          	addi	s1,s1,2028 # 80230a08 <wait_lock>
    80002224:	8526                	mv	a0,s1
    80002226:	a7bfe0ef          	jal	ra,80000ca0 <acquire>
  np->parent = p;
    8000222a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	b09fe0ef          	jal	ra,80000d38 <release>
  acquire(&np->lock);
    80002234:	854e                	mv	a0,s3
    80002236:	a6bfe0ef          	jal	ra,80000ca0 <acquire>
  np->state = RUNNABLE;
    8000223a:	478d                	li	a5,3
    8000223c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002240:	854e                	mv	a0,s3
    80002242:	af7fe0ef          	jal	ra,80000d38 <release>
}
    80002246:	8562                	mv	a0,s8
    80002248:	60a6                	ld	ra,72(sp)
    8000224a:	6406                	ld	s0,64(sp)
    8000224c:	74e2                	ld	s1,56(sp)
    8000224e:	7942                	ld	s2,48(sp)
    80002250:	79a2                	ld	s3,40(sp)
    80002252:	7a02                	ld	s4,32(sp)
    80002254:	6ae2                	ld	s5,24(sp)
    80002256:	6b42                	ld	s6,16(sp)
    80002258:	6ba2                	ld	s7,8(sp)
    8000225a:	6c02                	ld	s8,0(sp)
    8000225c:	6161                	addi	sp,sp,80
    8000225e:	8082                	ret
    return -1;
    80002260:	5c7d                	li	s8,-1
    80002262:	b7d5                	j	80002246 <kfork+0x13a>
    int npages = (np->vmas[i].end - np->vmas[i].start) / PGSIZE;
    80002264:	699c                	ld	a5,16(a1)
    80002266:	6598                	ld	a4,8(a1)
    80002268:	40e785b3          	sub	a1,a5,a4
    8000226c:	81b1                	srli	a1,a1,0xc
    if(shm_get(key, npages) < 0){
    8000226e:	2581                	sext.w	a1,a1
    80002270:	29c040ef          	jal	ra,8000650c <shm_get>
    80002274:	f8054fe3          	bltz	a0,80002212 <kfork+0x106>
  for(int i = 0; i < NVMA; i++){
    80002278:	2905                	addiw	s2,s2,1
    8000227a:	02848493          	addi	s1,s1,40
    8000227e:	f9490fe3          	beq	s2,s4,8000221c <kfork+0x110>
    if(!np->vmas[i].used || !np->vmas[i].is_shm) continue;
    80002282:	85a6                	mv	a1,s1
    80002284:	409c                	lw	a5,0(s1)
    80002286:	dbed                	beqz	a5,80002278 <kfork+0x16c>
    80002288:	509c                	lw	a5,32(s1)
    8000228a:	d7fd                	beqz	a5,80002278 <kfork+0x16c>
    int key = np->vmas[i].shm_key;
    8000228c:	50c8                	lw	a0,36(s1)
    for(int j = 0; j < i; j++){
    8000228e:	fd205be3          	blez	s2,80002264 <kfork+0x158>
    80002292:	fff9079b          	addiw	a5,s2,-1
    80002296:	1782                	slli	a5,a5,0x20
    80002298:	9381                	srli	a5,a5,0x20
    8000229a:	00279693          	slli	a3,a5,0x2
    8000229e:	96be                	add	a3,a3,a5
    800022a0:	068e                	slli	a3,a3,0x3
    800022a2:	96de                	add	a3,a3,s7
    800022a4:	87da                	mv	a5,s6
    800022a6:	bfb1                	j	80002202 <kfork+0xf6>

00000000800022a8 <scheduler>:
{
    800022a8:	715d                	addi	sp,sp,-80
    800022aa:	e486                	sd	ra,72(sp)
    800022ac:	e0a2                	sd	s0,64(sp)
    800022ae:	fc26                	sd	s1,56(sp)
    800022b0:	f84a                	sd	s2,48(sp)
    800022b2:	f44e                	sd	s3,40(sp)
    800022b4:	f052                	sd	s4,32(sp)
    800022b6:	ec56                	sd	s5,24(sp)
    800022b8:	e85a                	sd	s6,16(sp)
    800022ba:	e45e                	sd	s7,8(sp)
    800022bc:	e062                	sd	s8,0(sp)
    800022be:	0880                	addi	s0,sp,80
    800022c0:	8792                	mv	a5,tp
  int id = r_tp();
    800022c2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800022c4:	00779b13          	slli	s6,a5,0x7
    800022c8:	0022e717          	auipc	a4,0x22e
    800022cc:	72870713          	addi	a4,a4,1832 # 802309f0 <pid_lock>
    800022d0:	975a                	add	a4,a4,s6
    800022d2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800022d6:	0022e717          	auipc	a4,0x22e
    800022da:	75270713          	addi	a4,a4,1874 # 80230a28 <cpus+0x8>
    800022de:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800022e0:	4c11                	li	s8,4
        c->proc = p;
    800022e2:	079e                	slli	a5,a5,0x7
    800022e4:	0022ea17          	auipc	s4,0x22e
    800022e8:	70ca0a13          	addi	s4,s4,1804 # 802309f0 <pid_lock>
    800022ec:	9a3e                	add	s4,s4,a5
        found = 1;
    800022ee:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800022f0:	0023e997          	auipc	s3,0x23e
    800022f4:	53098993          	addi	s3,s3,1328 # 80240820 <tickslock>
    800022f8:	a83d                	j	80002336 <scheduler+0x8e>
      release(&p->lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	a3dfe0ef          	jal	ra,80000d38 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002300:	3e848493          	addi	s1,s1,1000
    80002304:	03348563          	beq	s1,s3,8000232e <scheduler+0x86>
      acquire(&p->lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	997fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == RUNNABLE) {
    8000230e:	4c9c                	lw	a5,24(s1)
    80002310:	ff2795e3          	bne	a5,s2,800022fa <scheduler+0x52>
        p->state = RUNNING;
    80002314:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002318:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000231c:	06048593          	addi	a1,s1,96
    80002320:	855a                	mv	a0,s6
    80002322:	5b2000ef          	jal	ra,800028d4 <swtch>
        c->proc = 0;
    80002326:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000232a:	8ade                	mv	s5,s7
    8000232c:	b7f9                	j	800022fa <scheduler+0x52>
    if(found == 0) {
    8000232e:	000a9463          	bnez	s5,80002336 <scheduler+0x8e>
      asm volatile("wfi");
    80002332:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002336:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000233a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000233e:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002342:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002346:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002348:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000234c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000234e:	0022f497          	auipc	s1,0x22f
    80002352:	ad248493          	addi	s1,s1,-1326 # 80230e20 <proc>
      if(p->state == RUNNABLE) {
    80002356:	490d                	li	s2,3
    80002358:	bf45                	j	80002308 <scheduler+0x60>

000000008000235a <sched>:
{
    8000235a:	7179                	addi	sp,sp,-48
    8000235c:	f406                	sd	ra,40(sp)
    8000235e:	f022                	sd	s0,32(sp)
    80002360:	ec26                	sd	s1,24(sp)
    80002362:	e84a                	sd	s2,16(sp)
    80002364:	e44e                	sd	s3,8(sp)
    80002366:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002368:	fe8ff0ef          	jal	ra,80001b50 <myproc>
    8000236c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000236e:	8c9fe0ef          	jal	ra,80000c36 <holding>
    80002372:	c92d                	beqz	a0,800023e4 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002374:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002376:	2781                	sext.w	a5,a5
    80002378:	079e                	slli	a5,a5,0x7
    8000237a:	0022e717          	auipc	a4,0x22e
    8000237e:	67670713          	addi	a4,a4,1654 # 802309f0 <pid_lock>
    80002382:	97ba                	add	a5,a5,a4
    80002384:	0a87a703          	lw	a4,168(a5)
    80002388:	4785                	li	a5,1
    8000238a:	06f71363          	bne	a4,a5,800023f0 <sched+0x96>
  if(p->state == RUNNING)
    8000238e:	4c98                	lw	a4,24(s1)
    80002390:	4791                	li	a5,4
    80002392:	06f70563          	beq	a4,a5,800023fc <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002396:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000239a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000239c:	e7b5                	bnez	a5,80002408 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000239e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023a0:	0022e917          	auipc	s2,0x22e
    800023a4:	65090913          	addi	s2,s2,1616 # 802309f0 <pid_lock>
    800023a8:	2781                	sext.w	a5,a5
    800023aa:	079e                	slli	a5,a5,0x7
    800023ac:	97ca                	add	a5,a5,s2
    800023ae:	0ac7a983          	lw	s3,172(a5)
    800023b2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023b4:	2781                	sext.w	a5,a5
    800023b6:	079e                	slli	a5,a5,0x7
    800023b8:	0022e597          	auipc	a1,0x22e
    800023bc:	67058593          	addi	a1,a1,1648 # 80230a28 <cpus+0x8>
    800023c0:	95be                	add	a1,a1,a5
    800023c2:	06048513          	addi	a0,s1,96
    800023c6:	50e000ef          	jal	ra,800028d4 <swtch>
    800023ca:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023cc:	2781                	sext.w	a5,a5
    800023ce:	079e                	slli	a5,a5,0x7
    800023d0:	993e                	add	s2,s2,a5
    800023d2:	0b392623          	sw	s3,172(s2)
}
    800023d6:	70a2                	ld	ra,40(sp)
    800023d8:	7402                	ld	s0,32(sp)
    800023da:	64e2                	ld	s1,24(sp)
    800023dc:	6942                	ld	s2,16(sp)
    800023de:	69a2                	ld	s3,8(sp)
    800023e0:	6145                	addi	sp,sp,48
    800023e2:	8082                	ret
    panic("sched p->lock");
    800023e4:	00006517          	auipc	a0,0x6
    800023e8:	dd450513          	addi	a0,a0,-556 # 800081b8 <digits+0x180>
    800023ec:	b9cfe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    800023f0:	00006517          	auipc	a0,0x6
    800023f4:	dd850513          	addi	a0,a0,-552 # 800081c8 <digits+0x190>
    800023f8:	b90fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    800023fc:	00006517          	auipc	a0,0x6
    80002400:	ddc50513          	addi	a0,a0,-548 # 800081d8 <digits+0x1a0>
    80002404:	b84fe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    80002408:	00006517          	auipc	a0,0x6
    8000240c:	de050513          	addi	a0,a0,-544 # 800081e8 <digits+0x1b0>
    80002410:	b78fe0ef          	jal	ra,80000788 <panic>

0000000080002414 <yield>:
{
    80002414:	1101                	addi	sp,sp,-32
    80002416:	ec06                	sd	ra,24(sp)
    80002418:	e822                	sd	s0,16(sp)
    8000241a:	e426                	sd	s1,8(sp)
    8000241c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000241e:	f32ff0ef          	jal	ra,80001b50 <myproc>
    80002422:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002424:	87dfe0ef          	jal	ra,80000ca0 <acquire>
  p->state = RUNNABLE;
    80002428:	478d                	li	a5,3
    8000242a:	cc9c                	sw	a5,24(s1)
  sched();
    8000242c:	f2fff0ef          	jal	ra,8000235a <sched>
  release(&p->lock);
    80002430:	8526                	mv	a0,s1
    80002432:	907fe0ef          	jal	ra,80000d38 <release>
}
    80002436:	60e2                	ld	ra,24(sp)
    80002438:	6442                	ld	s0,16(sp)
    8000243a:	64a2                	ld	s1,8(sp)
    8000243c:	6105                	addi	sp,sp,32
    8000243e:	8082                	ret

0000000080002440 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002440:	7179                	addi	sp,sp,-48
    80002442:	f406                	sd	ra,40(sp)
    80002444:	f022                	sd	s0,32(sp)
    80002446:	ec26                	sd	s1,24(sp)
    80002448:	e84a                	sd	s2,16(sp)
    8000244a:	e44e                	sd	s3,8(sp)
    8000244c:	1800                	addi	s0,sp,48
    8000244e:	89aa                	mv	s3,a0
    80002450:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002452:	efeff0ef          	jal	ra,80001b50 <myproc>
    80002456:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002458:	849fe0ef          	jal	ra,80000ca0 <acquire>
  release(lk);
    8000245c:	854a                	mv	a0,s2
    8000245e:	8dbfe0ef          	jal	ra,80000d38 <release>

  // Go to sleep.
  p->chan = chan;
    80002462:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002466:	4789                	li	a5,2
    80002468:	cc9c                	sw	a5,24(s1)

  sched();
    8000246a:	ef1ff0ef          	jal	ra,8000235a <sched>

  // Tidy up.
  p->chan = 0;
    8000246e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	8c5fe0ef          	jal	ra,80000d38 <release>
  acquire(lk);
    80002478:	854a                	mv	a0,s2
    8000247a:	827fe0ef          	jal	ra,80000ca0 <acquire>
}
    8000247e:	70a2                	ld	ra,40(sp)
    80002480:	7402                	ld	s0,32(sp)
    80002482:	64e2                	ld	s1,24(sp)
    80002484:	6942                	ld	s2,16(sp)
    80002486:	69a2                	ld	s3,8(sp)
    80002488:	6145                	addi	sp,sp,48
    8000248a:	8082                	ret

000000008000248c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000248c:	7139                	addi	sp,sp,-64
    8000248e:	fc06                	sd	ra,56(sp)
    80002490:	f822                	sd	s0,48(sp)
    80002492:	f426                	sd	s1,40(sp)
    80002494:	f04a                	sd	s2,32(sp)
    80002496:	ec4e                	sd	s3,24(sp)
    80002498:	e852                	sd	s4,16(sp)
    8000249a:	e456                	sd	s5,8(sp)
    8000249c:	0080                	addi	s0,sp,64
    8000249e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800024a0:	0022f497          	auipc	s1,0x22f
    800024a4:	98048493          	addi	s1,s1,-1664 # 80230e20 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800024a8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024aa:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ac:	0023e917          	auipc	s2,0x23e
    800024b0:	37490913          	addi	s2,s2,884 # 80240820 <tickslock>
    800024b4:	a801                	j	800024c4 <wakeup+0x38>
      }
      release(&p->lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	881fe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024bc:	3e848493          	addi	s1,s1,1000
    800024c0:	03248263          	beq	s1,s2,800024e4 <wakeup+0x58>
    if(p != myproc()){
    800024c4:	e8cff0ef          	jal	ra,80001b50 <myproc>
    800024c8:	fea48ae3          	beq	s1,a0,800024bc <wakeup+0x30>
      acquire(&p->lock);
    800024cc:	8526                	mv	a0,s1
    800024ce:	fd2fe0ef          	jal	ra,80000ca0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800024d2:	4c9c                	lw	a5,24(s1)
    800024d4:	ff3791e3          	bne	a5,s3,800024b6 <wakeup+0x2a>
    800024d8:	709c                	ld	a5,32(s1)
    800024da:	fd479ee3          	bne	a5,s4,800024b6 <wakeup+0x2a>
        p->state = RUNNABLE;
    800024de:	0154ac23          	sw	s5,24(s1)
    800024e2:	bfd1                	j	800024b6 <wakeup+0x2a>
    }
  }
}
    800024e4:	70e2                	ld	ra,56(sp)
    800024e6:	7442                	ld	s0,48(sp)
    800024e8:	74a2                	ld	s1,40(sp)
    800024ea:	7902                	ld	s2,32(sp)
    800024ec:	69e2                	ld	s3,24(sp)
    800024ee:	6a42                	ld	s4,16(sp)
    800024f0:	6aa2                	ld	s5,8(sp)
    800024f2:	6121                	addi	sp,sp,64
    800024f4:	8082                	ret

00000000800024f6 <reparent>:
{
    800024f6:	7179                	addi	sp,sp,-48
    800024f8:	f406                	sd	ra,40(sp)
    800024fa:	f022                	sd	s0,32(sp)
    800024fc:	ec26                	sd	s1,24(sp)
    800024fe:	e84a                	sd	s2,16(sp)
    80002500:	e44e                	sd	s3,8(sp)
    80002502:	e052                	sd	s4,0(sp)
    80002504:	1800                	addi	s0,sp,48
    80002506:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002508:	0022f497          	auipc	s1,0x22f
    8000250c:	91848493          	addi	s1,s1,-1768 # 80230e20 <proc>
      pp->parent = initproc;
    80002510:	00006a17          	auipc	s4,0x6
    80002514:	3c0a0a13          	addi	s4,s4,960 # 800088d0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002518:	0023e997          	auipc	s3,0x23e
    8000251c:	30898993          	addi	s3,s3,776 # 80240820 <tickslock>
    80002520:	a029                	j	8000252a <reparent+0x34>
    80002522:	3e848493          	addi	s1,s1,1000
    80002526:	01348b63          	beq	s1,s3,8000253c <reparent+0x46>
    if(pp->parent == p){
    8000252a:	7c9c                	ld	a5,56(s1)
    8000252c:	ff279be3          	bne	a5,s2,80002522 <reparent+0x2c>
      pp->parent = initproc;
    80002530:	000a3503          	ld	a0,0(s4)
    80002534:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002536:	f57ff0ef          	jal	ra,8000248c <wakeup>
    8000253a:	b7e5                	j	80002522 <reparent+0x2c>
}
    8000253c:	70a2                	ld	ra,40(sp)
    8000253e:	7402                	ld	s0,32(sp)
    80002540:	64e2                	ld	s1,24(sp)
    80002542:	6942                	ld	s2,16(sp)
    80002544:	69a2                	ld	s3,8(sp)
    80002546:	6a02                	ld	s4,0(sp)
    80002548:	6145                	addi	sp,sp,48
    8000254a:	8082                	ret

000000008000254c <kexit>:
{
    8000254c:	7179                	addi	sp,sp,-48
    8000254e:	f406                	sd	ra,40(sp)
    80002550:	f022                	sd	s0,32(sp)
    80002552:	ec26                	sd	s1,24(sp)
    80002554:	e84a                	sd	s2,16(sp)
    80002556:	e44e                	sd	s3,8(sp)
    80002558:	e052                	sd	s4,0(sp)
    8000255a:	1800                	addi	s0,sp,48
    8000255c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000255e:	df2ff0ef          	jal	ra,80001b50 <myproc>
    80002562:	89aa                	mv	s3,a0
  if(p == initproc)
    80002564:	00006797          	auipc	a5,0x6
    80002568:	36c7b783          	ld	a5,876(a5) # 800088d0 <initproc>
    8000256c:	0d050493          	addi	s1,a0,208
    80002570:	15050913          	addi	s2,a0,336
    80002574:	00a79f63          	bne	a5,a0,80002592 <kexit+0x46>
    panic("init exiting");
    80002578:	00006517          	auipc	a0,0x6
    8000257c:	c8850513          	addi	a0,a0,-888 # 80008200 <digits+0x1c8>
    80002580:	a08fe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    80002584:	65a020ef          	jal	ra,80004bde <fileclose>
      p->ofile[fd] = 0;
    80002588:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000258c:	04a1                	addi	s1,s1,8
    8000258e:	01248563          	beq	s1,s2,80002598 <kexit+0x4c>
    if(p->ofile[fd]){
    80002592:	6088                	ld	a0,0(s1)
    80002594:	f965                	bnez	a0,80002584 <kexit+0x38>
    80002596:	bfdd                	j	8000258c <kexit+0x40>
  begin_op();
    80002598:	23c020ef          	jal	ra,800047d4 <begin_op>
  iput(p->cwd);
    8000259c:	1509b503          	ld	a0,336(s3)
    800025a0:	1cb010ef          	jal	ra,80003f6a <iput>
  end_op();
    800025a4:	29e020ef          	jal	ra,80004842 <end_op>
  p->cwd = 0;
    800025a8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025ac:	0022e497          	auipc	s1,0x22e
    800025b0:	45c48493          	addi	s1,s1,1116 # 80230a08 <wait_lock>
    800025b4:	8526                	mv	a0,s1
    800025b6:	eeafe0ef          	jal	ra,80000ca0 <acquire>
  reparent(p);
    800025ba:	854e                	mv	a0,s3
    800025bc:	f3bff0ef          	jal	ra,800024f6 <reparent>
  wakeup(p->parent);
    800025c0:	0389b503          	ld	a0,56(s3)
    800025c4:	ec9ff0ef          	jal	ra,8000248c <wakeup>
  acquire(&p->lock);
    800025c8:	854e                	mv	a0,s3
    800025ca:	ed6fe0ef          	jal	ra,80000ca0 <acquire>
  p->xstate = status;
    800025ce:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025d2:	4795                	li	a5,5
    800025d4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800025d8:	8526                	mv	a0,s1
    800025da:	f5efe0ef          	jal	ra,80000d38 <release>
  sched();
    800025de:	d7dff0ef          	jal	ra,8000235a <sched>
  panic("zombie exit");
    800025e2:	00006517          	auipc	a0,0x6
    800025e6:	c2e50513          	addi	a0,a0,-978 # 80008210 <digits+0x1d8>
    800025ea:	99efe0ef          	jal	ra,80000788 <panic>

00000000800025ee <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800025ee:	7179                	addi	sp,sp,-48
    800025f0:	f406                	sd	ra,40(sp)
    800025f2:	f022                	sd	s0,32(sp)
    800025f4:	ec26                	sd	s1,24(sp)
    800025f6:	e84a                	sd	s2,16(sp)
    800025f8:	e44e                	sd	s3,8(sp)
    800025fa:	1800                	addi	s0,sp,48
    800025fc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025fe:	0022f497          	auipc	s1,0x22f
    80002602:	82248493          	addi	s1,s1,-2014 # 80230e20 <proc>
    80002606:	0023e997          	auipc	s3,0x23e
    8000260a:	21a98993          	addi	s3,s3,538 # 80240820 <tickslock>
    acquire(&p->lock);
    8000260e:	8526                	mv	a0,s1
    80002610:	e90fe0ef          	jal	ra,80000ca0 <acquire>
    if(p->pid == pid){
    80002614:	589c                	lw	a5,48(s1)
    80002616:	01278b63          	beq	a5,s2,8000262c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000261a:	8526                	mv	a0,s1
    8000261c:	f1cfe0ef          	jal	ra,80000d38 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002620:	3e848493          	addi	s1,s1,1000
    80002624:	ff3495e3          	bne	s1,s3,8000260e <kkill+0x20>
  }
  return -1;
    80002628:	557d                	li	a0,-1
    8000262a:	a819                	j	80002640 <kkill+0x52>
      p->killed = 1;
    8000262c:	4785                	li	a5,1
    8000262e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002630:	4c98                	lw	a4,24(s1)
    80002632:	4789                	li	a5,2
    80002634:	00f70d63          	beq	a4,a5,8000264e <kkill+0x60>
      release(&p->lock);
    80002638:	8526                	mv	a0,s1
    8000263a:	efefe0ef          	jal	ra,80000d38 <release>
      return 0;
    8000263e:	4501                	li	a0,0
}
    80002640:	70a2                	ld	ra,40(sp)
    80002642:	7402                	ld	s0,32(sp)
    80002644:	64e2                	ld	s1,24(sp)
    80002646:	6942                	ld	s2,16(sp)
    80002648:	69a2                	ld	s3,8(sp)
    8000264a:	6145                	addi	sp,sp,48
    8000264c:	8082                	ret
        p->state = RUNNABLE;
    8000264e:	478d                	li	a5,3
    80002650:	cc9c                	sw	a5,24(s1)
    80002652:	b7dd                	j	80002638 <kkill+0x4a>

0000000080002654 <setkilled>:

void
setkilled(struct proc *p)
{
    80002654:	1101                	addi	sp,sp,-32
    80002656:	ec06                	sd	ra,24(sp)
    80002658:	e822                	sd	s0,16(sp)
    8000265a:	e426                	sd	s1,8(sp)
    8000265c:	1000                	addi	s0,sp,32
    8000265e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002660:	e40fe0ef          	jal	ra,80000ca0 <acquire>
  p->killed = 1;
    80002664:	4785                	li	a5,1
    80002666:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002668:	8526                	mv	a0,s1
    8000266a:	ecefe0ef          	jal	ra,80000d38 <release>
}
    8000266e:	60e2                	ld	ra,24(sp)
    80002670:	6442                	ld	s0,16(sp)
    80002672:	64a2                	ld	s1,8(sp)
    80002674:	6105                	addi	sp,sp,32
    80002676:	8082                	ret

0000000080002678 <killed>:

int
killed(struct proc *p)
{
    80002678:	1101                	addi	sp,sp,-32
    8000267a:	ec06                	sd	ra,24(sp)
    8000267c:	e822                	sd	s0,16(sp)
    8000267e:	e426                	sd	s1,8(sp)
    80002680:	e04a                	sd	s2,0(sp)
    80002682:	1000                	addi	s0,sp,32
    80002684:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002686:	e1afe0ef          	jal	ra,80000ca0 <acquire>
  k = p->killed;
    8000268a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000268e:	8526                	mv	a0,s1
    80002690:	ea8fe0ef          	jal	ra,80000d38 <release>
  return k;
}
    80002694:	854a                	mv	a0,s2
    80002696:	60e2                	ld	ra,24(sp)
    80002698:	6442                	ld	s0,16(sp)
    8000269a:	64a2                	ld	s1,8(sp)
    8000269c:	6902                	ld	s2,0(sp)
    8000269e:	6105                	addi	sp,sp,32
    800026a0:	8082                	ret

00000000800026a2 <kwait>:
{
    800026a2:	715d                	addi	sp,sp,-80
    800026a4:	e486                	sd	ra,72(sp)
    800026a6:	e0a2                	sd	s0,64(sp)
    800026a8:	fc26                	sd	s1,56(sp)
    800026aa:	f84a                	sd	s2,48(sp)
    800026ac:	f44e                	sd	s3,40(sp)
    800026ae:	f052                	sd	s4,32(sp)
    800026b0:	ec56                	sd	s5,24(sp)
    800026b2:	e85a                	sd	s6,16(sp)
    800026b4:	e45e                	sd	s7,8(sp)
    800026b6:	e062                	sd	s8,0(sp)
    800026b8:	0880                	addi	s0,sp,80
    800026ba:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800026bc:	c94ff0ef          	jal	ra,80001b50 <myproc>
    800026c0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026c2:	0022e517          	auipc	a0,0x22e
    800026c6:	34650513          	addi	a0,a0,838 # 80230a08 <wait_lock>
    800026ca:	dd6fe0ef          	jal	ra,80000ca0 <acquire>
    havekids = 0;
    800026ce:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800026d0:	4a15                	li	s4,5
        havekids = 1;
    800026d2:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026d4:	0023e997          	auipc	s3,0x23e
    800026d8:	14c98993          	addi	s3,s3,332 # 80240820 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026dc:	0022ec17          	auipc	s8,0x22e
    800026e0:	32cc0c13          	addi	s8,s8,812 # 80230a08 <wait_lock>
    havekids = 0;
    800026e4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026e6:	0022e497          	auipc	s1,0x22e
    800026ea:	73a48493          	addi	s1,s1,1850 # 80230e20 <proc>
    800026ee:	a899                	j	80002744 <kwait+0xa2>
          pid = pp->pid;
    800026f0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026f4:	000b0c63          	beqz	s6,8000270c <kwait+0x6a>
    800026f8:	4691                	li	a3,4
    800026fa:	02c48613          	addi	a2,s1,44
    800026fe:	85da                	mv	a1,s6
    80002700:	05093503          	ld	a0,80(s2)
    80002704:	86eff0ef          	jal	ra,80001772 <copyout>
    80002708:	00054f63          	bltz	a0,80002726 <kwait+0x84>
          freeproc(pp);
    8000270c:	8526                	mv	a0,s1
    8000270e:	845ff0ef          	jal	ra,80001f52 <freeproc>
          release(&pp->lock);
    80002712:	8526                	mv	a0,s1
    80002714:	e24fe0ef          	jal	ra,80000d38 <release>
          release(&wait_lock);
    80002718:	0022e517          	auipc	a0,0x22e
    8000271c:	2f050513          	addi	a0,a0,752 # 80230a08 <wait_lock>
    80002720:	e18fe0ef          	jal	ra,80000d38 <release>
          return pid;
    80002724:	a891                	j	80002778 <kwait+0xd6>
            release(&pp->lock);
    80002726:	8526                	mv	a0,s1
    80002728:	e10fe0ef          	jal	ra,80000d38 <release>
            release(&wait_lock);
    8000272c:	0022e517          	auipc	a0,0x22e
    80002730:	2dc50513          	addi	a0,a0,732 # 80230a08 <wait_lock>
    80002734:	e04fe0ef          	jal	ra,80000d38 <release>
            return -1;
    80002738:	59fd                	li	s3,-1
    8000273a:	a83d                	j	80002778 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000273c:	3e848493          	addi	s1,s1,1000
    80002740:	03348063          	beq	s1,s3,80002760 <kwait+0xbe>
      if(pp->parent == p){
    80002744:	7c9c                	ld	a5,56(s1)
    80002746:	ff279be3          	bne	a5,s2,8000273c <kwait+0x9a>
        acquire(&pp->lock);
    8000274a:	8526                	mv	a0,s1
    8000274c:	d54fe0ef          	jal	ra,80000ca0 <acquire>
        if(pp->state == ZOMBIE){
    80002750:	4c9c                	lw	a5,24(s1)
    80002752:	f9478fe3          	beq	a5,s4,800026f0 <kwait+0x4e>
        release(&pp->lock);
    80002756:	8526                	mv	a0,s1
    80002758:	de0fe0ef          	jal	ra,80000d38 <release>
        havekids = 1;
    8000275c:	8756                	mv	a4,s5
    8000275e:	bff9                	j	8000273c <kwait+0x9a>
    if(!havekids || killed(p)){
    80002760:	c709                	beqz	a4,8000276a <kwait+0xc8>
    80002762:	854a                	mv	a0,s2
    80002764:	f15ff0ef          	jal	ra,80002678 <killed>
    80002768:	c50d                	beqz	a0,80002792 <kwait+0xf0>
      release(&wait_lock);
    8000276a:	0022e517          	auipc	a0,0x22e
    8000276e:	29e50513          	addi	a0,a0,670 # 80230a08 <wait_lock>
    80002772:	dc6fe0ef          	jal	ra,80000d38 <release>
      return -1;
    80002776:	59fd                	li	s3,-1
}
    80002778:	854e                	mv	a0,s3
    8000277a:	60a6                	ld	ra,72(sp)
    8000277c:	6406                	ld	s0,64(sp)
    8000277e:	74e2                	ld	s1,56(sp)
    80002780:	7942                	ld	s2,48(sp)
    80002782:	79a2                	ld	s3,40(sp)
    80002784:	7a02                	ld	s4,32(sp)
    80002786:	6ae2                	ld	s5,24(sp)
    80002788:	6b42                	ld	s6,16(sp)
    8000278a:	6ba2                	ld	s7,8(sp)
    8000278c:	6c02                	ld	s8,0(sp)
    8000278e:	6161                	addi	sp,sp,80
    80002790:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002792:	85e2                	mv	a1,s8
    80002794:	854a                	mv	a0,s2
    80002796:	cabff0ef          	jal	ra,80002440 <sleep>
    havekids = 0;
    8000279a:	b7a9                	j	800026e4 <kwait+0x42>

000000008000279c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000279c:	7179                	addi	sp,sp,-48
    8000279e:	f406                	sd	ra,40(sp)
    800027a0:	f022                	sd	s0,32(sp)
    800027a2:	ec26                	sd	s1,24(sp)
    800027a4:	e84a                	sd	s2,16(sp)
    800027a6:	e44e                	sd	s3,8(sp)
    800027a8:	e052                	sd	s4,0(sp)
    800027aa:	1800                	addi	s0,sp,48
    800027ac:	84aa                	mv	s1,a0
    800027ae:	892e                	mv	s2,a1
    800027b0:	89b2                	mv	s3,a2
    800027b2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027b4:	b9cff0ef          	jal	ra,80001b50 <myproc>
  if(user_dst){
    800027b8:	cc99                	beqz	s1,800027d6 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800027ba:	86d2                	mv	a3,s4
    800027bc:	864e                	mv	a2,s3
    800027be:	85ca                	mv	a1,s2
    800027c0:	6928                	ld	a0,80(a0)
    800027c2:	fb1fe0ef          	jal	ra,80001772 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027c6:	70a2                	ld	ra,40(sp)
    800027c8:	7402                	ld	s0,32(sp)
    800027ca:	64e2                	ld	s1,24(sp)
    800027cc:	6942                	ld	s2,16(sp)
    800027ce:	69a2                	ld	s3,8(sp)
    800027d0:	6a02                	ld	s4,0(sp)
    800027d2:	6145                	addi	sp,sp,48
    800027d4:	8082                	ret
    memmove((char *)dst, src, len);
    800027d6:	000a061b          	sext.w	a2,s4
    800027da:	85ce                	mv	a1,s3
    800027dc:	854a                	mv	a0,s2
    800027de:	df2fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    800027e2:	8526                	mv	a0,s1
    800027e4:	b7cd                	j	800027c6 <either_copyout+0x2a>

00000000800027e6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027e6:	7179                	addi	sp,sp,-48
    800027e8:	f406                	sd	ra,40(sp)
    800027ea:	f022                	sd	s0,32(sp)
    800027ec:	ec26                	sd	s1,24(sp)
    800027ee:	e84a                	sd	s2,16(sp)
    800027f0:	e44e                	sd	s3,8(sp)
    800027f2:	e052                	sd	s4,0(sp)
    800027f4:	1800                	addi	s0,sp,48
    800027f6:	892a                	mv	s2,a0
    800027f8:	84ae                	mv	s1,a1
    800027fa:	89b2                	mv	s3,a2
    800027fc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027fe:	b52ff0ef          	jal	ra,80001b50 <myproc>
  if(user_src){
    80002802:	cc99                	beqz	s1,80002820 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002804:	86d2                	mv	a3,s4
    80002806:	864e                	mv	a2,s3
    80002808:	85ca                	mv	a1,s2
    8000280a:	6928                	ld	a0,80(a0)
    8000280c:	860ff0ef          	jal	ra,8000186c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002810:	70a2                	ld	ra,40(sp)
    80002812:	7402                	ld	s0,32(sp)
    80002814:	64e2                	ld	s1,24(sp)
    80002816:	6942                	ld	s2,16(sp)
    80002818:	69a2                	ld	s3,8(sp)
    8000281a:	6a02                	ld	s4,0(sp)
    8000281c:	6145                	addi	sp,sp,48
    8000281e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002820:	000a061b          	sext.w	a2,s4
    80002824:	85ce                	mv	a1,s3
    80002826:	854a                	mv	a0,s2
    80002828:	da8fe0ef          	jal	ra,80000dd0 <memmove>
    return 0;
    8000282c:	8526                	mv	a0,s1
    8000282e:	b7cd                	j	80002810 <either_copyin+0x2a>

0000000080002830 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002830:	715d                	addi	sp,sp,-80
    80002832:	e486                	sd	ra,72(sp)
    80002834:	e0a2                	sd	s0,64(sp)
    80002836:	fc26                	sd	s1,56(sp)
    80002838:	f84a                	sd	s2,48(sp)
    8000283a:	f44e                	sd	s3,40(sp)
    8000283c:	f052                	sd	s4,32(sp)
    8000283e:	ec56                	sd	s5,24(sp)
    80002840:	e85a                	sd	s6,16(sp)
    80002842:	e45e                	sd	s7,8(sp)
    80002844:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002846:	00006517          	auipc	a0,0x6
    8000284a:	88250513          	addi	a0,a0,-1918 # 800080c8 <digits+0x90>
    8000284e:	c75fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002852:	0022e497          	auipc	s1,0x22e
    80002856:	72648493          	addi	s1,s1,1830 # 80230f78 <proc+0x158>
    8000285a:	0023e917          	auipc	s2,0x23e
    8000285e:	11e90913          	addi	s2,s2,286 # 80240978 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002862:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002864:	00006997          	auipc	s3,0x6
    80002868:	9bc98993          	addi	s3,s3,-1604 # 80008220 <digits+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    8000286c:	00006a97          	auipc	s5,0x6
    80002870:	9bca8a93          	addi	s5,s5,-1604 # 80008228 <digits+0x1f0>
    printf("\n");
    80002874:	00006a17          	auipc	s4,0x6
    80002878:	854a0a13          	addi	s4,s4,-1964 # 800080c8 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000287c:	00006b97          	auipc	s7,0x6
    80002880:	9ecb8b93          	addi	s7,s7,-1556 # 80008268 <states.0>
    80002884:	a829                	j	8000289e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002886:	ed86a583          	lw	a1,-296(a3)
    8000288a:	8556                	mv	a0,s5
    8000288c:	c37fd0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80002890:	8552                	mv	a0,s4
    80002892:	c31fd0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002896:	3e848493          	addi	s1,s1,1000
    8000289a:	03248263          	beq	s1,s2,800028be <procdump+0x8e>
    if(p->state == UNUSED)
    8000289e:	86a6                	mv	a3,s1
    800028a0:	ec04a783          	lw	a5,-320(s1)
    800028a4:	dbed                	beqz	a5,80002896 <procdump+0x66>
      state = "???";
    800028a6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a8:	fcfb6fe3          	bltu	s6,a5,80002886 <procdump+0x56>
    800028ac:	02079713          	slli	a4,a5,0x20
    800028b0:	01d75793          	srli	a5,a4,0x1d
    800028b4:	97de                	add	a5,a5,s7
    800028b6:	6390                	ld	a2,0(a5)
    800028b8:	f679                	bnez	a2,80002886 <procdump+0x56>
      state = "???";
    800028ba:	864e                	mv	a2,s3
    800028bc:	b7e9                	j	80002886 <procdump+0x56>
  }
}
    800028be:	60a6                	ld	ra,72(sp)
    800028c0:	6406                	ld	s0,64(sp)
    800028c2:	74e2                	ld	s1,56(sp)
    800028c4:	7942                	ld	s2,48(sp)
    800028c6:	79a2                	ld	s3,40(sp)
    800028c8:	7a02                	ld	s4,32(sp)
    800028ca:	6ae2                	ld	s5,24(sp)
    800028cc:	6b42                	ld	s6,16(sp)
    800028ce:	6ba2                	ld	s7,8(sp)
    800028d0:	6161                	addi	sp,sp,80
    800028d2:	8082                	ret

00000000800028d4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800028d4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800028d8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800028dc:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800028de:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800028e0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800028e4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800028e8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800028ec:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800028f0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800028f4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800028f8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800028fc:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002900:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002904:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002908:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000290c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002910:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002912:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002914:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002918:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000291c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002920:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002924:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002928:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000292c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002930:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002934:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002938:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000293c:	8082                	ret

000000008000293e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000293e:	1141                	addi	sp,sp,-16
    80002940:	e406                	sd	ra,8(sp)
    80002942:	e022                	sd	s0,0(sp)
    80002944:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002946:	00006597          	auipc	a1,0x6
    8000294a:	95258593          	addi	a1,a1,-1710 # 80008298 <states.0+0x30>
    8000294e:	0023e517          	auipc	a0,0x23e
    80002952:	ed250513          	addi	a0,a0,-302 # 80240820 <tickslock>
    80002956:	acafe0ef          	jal	ra,80000c20 <initlock>
}
    8000295a:	60a2                	ld	ra,8(sp)
    8000295c:	6402                	ld	s0,0(sp)
    8000295e:	0141                	addi	sp,sp,16
    80002960:	8082                	ret

0000000080002962 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002962:	1141                	addi	sp,sp,-16
    80002964:	e422                	sd	s0,8(sp)
    80002966:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002968:	00003797          	auipc	a5,0x3
    8000296c:	5a878793          	addi	a5,a5,1448 # 80005f10 <kernelvec>
    80002970:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002974:	6422                	ld	s0,8(sp)
    80002976:	0141                	addi	sp,sp,16
    80002978:	8082                	ret

000000008000297a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000297a:	1141                	addi	sp,sp,-16
    8000297c:	e406                	sd	ra,8(sp)
    8000297e:	e022                	sd	s0,0(sp)
    80002980:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002982:	9ceff0ef          	jal	ra,80001b50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002986:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000298a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000298c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002990:	04000737          	lui	a4,0x4000
    80002994:	00004797          	auipc	a5,0x4
    80002998:	66c78793          	addi	a5,a5,1644 # 80007000 <_trampoline>
    8000299c:	00004697          	auipc	a3,0x4
    800029a0:	66468693          	addi	a3,a3,1636 # 80007000 <_trampoline>
    800029a4:	8f95                	sub	a5,a5,a3
    800029a6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800029a8:	0732                	slli	a4,a4,0xc
    800029aa:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029ac:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029b2:	18002773          	csrr	a4,satp
    800029b6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029b8:	6d38                	ld	a4,88(a0)
    800029ba:	613c                	ld	a5,64(a0)
    800029bc:	6685                	lui	a3,0x1
    800029be:	97b6                	add	a5,a5,a3
    800029c0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029c2:	6d3c                	ld	a5,88(a0)
    800029c4:	00000717          	auipc	a4,0x0
    800029c8:	0f470713          	addi	a4,a4,244 # 80002ab8 <usertrap>
    800029cc:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029ce:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029d0:	8712                	mv	a4,tp
    800029d2:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029d8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029dc:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029e4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029e6:	6f9c                	ld	a5,24(a5)
    800029e8:	14179073          	csrw	sepc,a5
}
    800029ec:	60a2                	ld	ra,8(sp)
    800029ee:	6402                	ld	s0,0(sp)
    800029f0:	0141                	addi	sp,sp,16
    800029f2:	8082                	ret

00000000800029f4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	e426                	sd	s1,8(sp)
    800029fc:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800029fe:	926ff0ef          	jal	ra,80001b24 <cpuid>
    80002a02:	cd19                	beqz	a0,80002a20 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a04:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a08:	000f4737          	lui	a4,0xf4
    80002a0c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a10:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a12:	14d79073          	csrw	0x14d,a5
}
    80002a16:	60e2                	ld	ra,24(sp)
    80002a18:	6442                	ld	s0,16(sp)
    80002a1a:	64a2                	ld	s1,8(sp)
    80002a1c:	6105                	addi	sp,sp,32
    80002a1e:	8082                	ret
    acquire(&tickslock);
    80002a20:	0023e497          	auipc	s1,0x23e
    80002a24:	e0048493          	addi	s1,s1,-512 # 80240820 <tickslock>
    80002a28:	8526                	mv	a0,s1
    80002a2a:	a76fe0ef          	jal	ra,80000ca0 <acquire>
    ticks++;
    80002a2e:	00006517          	auipc	a0,0x6
    80002a32:	eaa50513          	addi	a0,a0,-342 # 800088d8 <ticks>
    80002a36:	411c                	lw	a5,0(a0)
    80002a38:	2785                	addiw	a5,a5,1
    80002a3a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002a3c:	a51ff0ef          	jal	ra,8000248c <wakeup>
    release(&tickslock);
    80002a40:	8526                	mv	a0,s1
    80002a42:	af6fe0ef          	jal	ra,80000d38 <release>
    80002a46:	bf7d                	j	80002a04 <clockintr+0x10>

0000000080002a48 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a48:	1101                	addi	sp,sp,-32
    80002a4a:	ec06                	sd	ra,24(sp)
    80002a4c:	e822                	sd	s0,16(sp)
    80002a4e:	e426                	sd	s1,8(sp)
    80002a50:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a52:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a56:	57fd                	li	a5,-1
    80002a58:	17fe                	slli	a5,a5,0x3f
    80002a5a:	07a5                	addi	a5,a5,9
    80002a5c:	00f70d63          	beq	a4,a5,80002a76 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a60:	57fd                	li	a5,-1
    80002a62:	17fe                	slli	a5,a5,0x3f
    80002a64:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a66:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a68:	04f70463          	beq	a4,a5,80002ab0 <devintr+0x68>
  }
}
    80002a6c:	60e2                	ld	ra,24(sp)
    80002a6e:	6442                	ld	s0,16(sp)
    80002a70:	64a2                	ld	s1,8(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret
    int irq = plic_claim();
    80002a76:	542030ef          	jal	ra,80005fb8 <plic_claim>
    80002a7a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a7c:	47a9                	li	a5,10
    80002a7e:	02f50363          	beq	a0,a5,80002aa4 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002a82:	4785                	li	a5,1
    80002a84:	02f50363          	beq	a0,a5,80002aaa <devintr+0x62>
    return 1;
    80002a88:	4505                	li	a0,1
    } else if(irq){
    80002a8a:	d0ed                	beqz	s1,80002a6c <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a8c:	85a6                	mv	a1,s1
    80002a8e:	00006517          	auipc	a0,0x6
    80002a92:	81250513          	addi	a0,a0,-2030 # 800082a0 <states.0+0x38>
    80002a96:	a2dfd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    80002a9a:	8526                	mv	a0,s1
    80002a9c:	53c030ef          	jal	ra,80005fd8 <plic_complete>
    return 1;
    80002aa0:	4505                	li	a0,1
    80002aa2:	b7e9                	j	80002a6c <devintr+0x24>
      uartintr();
    80002aa4:	eb1fd0ef          	jal	ra,80000954 <uartintr>
    80002aa8:	bfcd                	j	80002a9a <devintr+0x52>
      virtio_disk_intr();
    80002aaa:	19b030ef          	jal	ra,80006444 <virtio_disk_intr>
    80002aae:	b7f5                	j	80002a9a <devintr+0x52>
    clockintr();
    80002ab0:	f45ff0ef          	jal	ra,800029f4 <clockintr>
    return 2;
    80002ab4:	4509                	li	a0,2
    80002ab6:	bf5d                	j	80002a6c <devintr+0x24>

0000000080002ab8 <usertrap>:
{
    80002ab8:	7179                	addi	sp,sp,-48
    80002aba:	f406                	sd	ra,40(sp)
    80002abc:	f022                	sd	s0,32(sp)
    80002abe:	ec26                	sd	s1,24(sp)
    80002ac0:	e84a                	sd	s2,16(sp)
    80002ac2:	e44e                	sd	s3,8(sp)
    80002ac4:	e052                	sd	s4,0(sp)
    80002ac6:	1800                	addi	s0,sp,48
    80002ac8:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002acc:	14302a73          	csrr	s4,stval
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ad4:	1007f793          	andi	a5,a5,256
    80002ad8:	e3bd                	bnez	a5,80002b3e <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ada:	00003797          	auipc	a5,0x3
    80002ade:	43678793          	addi	a5,a5,1078 # 80005f10 <kernelvec>
    80002ae2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ae6:	86aff0ef          	jal	ra,80001b50 <myproc>
    80002aea:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002aec:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aee:	14102773          	csrr	a4,sepc
    80002af2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002af8:	47a1                	li	a5,8
    80002afa:	04f70863          	beq	a4,a5,80002b4a <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002afe:	f4bff0ef          	jal	ra,80002a48 <devintr>
    80002b02:	892a                	mv	s2,a0
    80002b04:	0c051e63          	bnez	a0,80002be0 <usertrap+0x128>
  } else if(sc == 13 || sc == 15) {
    80002b08:	47b5                	li	a5,13
    80002b0a:	08f98663          	beq	s3,a5,80002b96 <usertrap+0xde>
    80002b0e:	47bd                	li	a5,15
    80002b10:	0af99363          	bne	s3,a5,80002bb6 <usertrap+0xfe>
      if(cowbreak(p->pagetable, va) == 0) {
    80002b14:	85d2                	mv	a1,s4
    80002b16:	68a8                	ld	a0,80(s1)
    80002b18:	a31fe0ef          	jal	ra,80001548 <cowbreak>
    80002b1c:	c531                	beqz	a0,80002b68 <usertrap+0xb0>
      } else if(vmafault(p, va, 1) != 0) {
    80002b1e:	4605                	li	a2,1
    80002b20:	85d2                	mv	a1,s4
    80002b22:	8526                	mv	a0,s1
    80002b24:	dd7fe0ef          	jal	ra,800018fa <vmafault>
    80002b28:	e121                	bnez	a0,80002b68 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 0) != 0) {
    80002b2a:	4601                	li	a2,0
    80002b2c:	85d2                	mv	a1,s4
    80002b2e:	68a8                	ld	a0,80(s1)
    80002b30:	bd1fe0ef          	jal	ra,80001700 <vmfault>
    80002b34:	e915                	bnez	a0,80002b68 <usertrap+0xb0>
        setkilled(p);
    80002b36:	8526                	mv	a0,s1
    80002b38:	b1dff0ef          	jal	ra,80002654 <setkilled>
    80002b3c:	a035                	j	80002b68 <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002b3e:	00005517          	auipc	a0,0x5
    80002b42:	78250513          	addi	a0,a0,1922 # 800082c0 <states.0+0x58>
    80002b46:	c43fd0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    80002b4a:	b2fff0ef          	jal	ra,80002678 <killed>
    80002b4e:	e121                	bnez	a0,80002b8e <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002b50:	6cb8                	ld	a4,88(s1)
    80002b52:	6f1c                	ld	a5,24(a4)
    80002b54:	0791                	addi	a5,a5,4
    80002b56:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b58:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b5c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b60:	10079073          	csrw	sstatus,a5
    syscall();
    80002b64:	27c000ef          	jal	ra,80002de0 <syscall>
  if(killed(p))
    80002b68:	8526                	mv	a0,s1
    80002b6a:	b0fff0ef          	jal	ra,80002678 <killed>
    80002b6e:	ed35                	bnez	a0,80002bea <usertrap+0x132>
  prepare_return();
    80002b70:	e0bff0ef          	jal	ra,8000297a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b74:	68a8                	ld	a0,80(s1)
    80002b76:	8131                	srli	a0,a0,0xc
    80002b78:	57fd                	li	a5,-1
    80002b7a:	17fe                	slli	a5,a5,0x3f
    80002b7c:	8d5d                	or	a0,a0,a5
}
    80002b7e:	70a2                	ld	ra,40(sp)
    80002b80:	7402                	ld	s0,32(sp)
    80002b82:	64e2                	ld	s1,24(sp)
    80002b84:	6942                	ld	s2,16(sp)
    80002b86:	69a2                	ld	s3,8(sp)
    80002b88:	6a02                	ld	s4,0(sp)
    80002b8a:	6145                	addi	sp,sp,48
    80002b8c:	8082                	ret
      kexit(-1);
    80002b8e:	557d                	li	a0,-1
    80002b90:	9bdff0ef          	jal	ra,8000254c <kexit>
    80002b94:	bf75                	j	80002b50 <usertrap+0x98>
      if(vmafault(p, va, 0) != 0) {
    80002b96:	4601                	li	a2,0
    80002b98:	85d2                	mv	a1,s4
    80002b9a:	8526                	mv	a0,s1
    80002b9c:	d5ffe0ef          	jal	ra,800018fa <vmafault>
    80002ba0:	f561                	bnez	a0,80002b68 <usertrap+0xb0>
      } else if(vmfault(p->pagetable, va, 1) != 0) {
    80002ba2:	4605                	li	a2,1
    80002ba4:	85d2                	mv	a1,s4
    80002ba6:	68a8                	ld	a0,80(s1)
    80002ba8:	b59fe0ef          	jal	ra,80001700 <vmfault>
    80002bac:	fd55                	bnez	a0,80002b68 <usertrap+0xb0>
        setkilled(p);
    80002bae:	8526                	mv	a0,s1
    80002bb0:	aa5ff0ef          	jal	ra,80002654 <setkilled>
    80002bb4:	bf55                	j	80002b68 <usertrap+0xb0>
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", sc, p->pid);
    80002bb6:	5890                	lw	a2,48(s1)
    80002bb8:	85ce                	mv	a1,s3
    80002bba:	00005517          	auipc	a0,0x5
    80002bbe:	72650513          	addi	a0,a0,1830 # 800082e0 <states.0+0x78>
    80002bc2:	901fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bc6:	141025f3          	csrr	a1,sepc
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), va);
    80002bca:	8652                	mv	a2,s4
    80002bcc:	00005517          	auipc	a0,0x5
    80002bd0:	74450513          	addi	a0,a0,1860 # 80008310 <states.0+0xa8>
    80002bd4:	8effd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    80002bd8:	8526                	mv	a0,s1
    80002bda:	a7bff0ef          	jal	ra,80002654 <setkilled>
    80002bde:	b769                	j	80002b68 <usertrap+0xb0>
  if(killed(p))
    80002be0:	8526                	mv	a0,s1
    80002be2:	a97ff0ef          	jal	ra,80002678 <killed>
    80002be6:	c511                	beqz	a0,80002bf2 <usertrap+0x13a>
    80002be8:	a011                	j	80002bec <usertrap+0x134>
    80002bea:	4901                	li	s2,0
    kexit(-1);
    80002bec:	557d                	li	a0,-1
    80002bee:	95fff0ef          	jal	ra,8000254c <kexit>
  if(which_dev == 2)
    80002bf2:	4789                	li	a5,2
    80002bf4:	f6f91ee3          	bne	s2,a5,80002b70 <usertrap+0xb8>
    yield();
    80002bf8:	81dff0ef          	jal	ra,80002414 <yield>
    80002bfc:	bf95                	j	80002b70 <usertrap+0xb8>

0000000080002bfe <kerneltrap>:
{
    80002bfe:	7179                	addi	sp,sp,-48
    80002c00:	f406                	sd	ra,40(sp)
    80002c02:	f022                	sd	s0,32(sp)
    80002c04:	ec26                	sd	s1,24(sp)
    80002c06:	e84a                	sd	s2,16(sp)
    80002c08:	e44e                	sd	s3,8(sp)
    80002c0a:	1800                	addi	s0,sp,48
    80002c0c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c10:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c14:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c18:	1004f793          	andi	a5,s1,256
    80002c1c:	c795                	beqz	a5,80002c48 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c22:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c24:	eb85                	bnez	a5,80002c54 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002c26:	e23ff0ef          	jal	ra,80002a48 <devintr>
    80002c2a:	c91d                	beqz	a0,80002c60 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002c2c:	4789                	li	a5,2
    80002c2e:	04f50a63          	beq	a0,a5,80002c82 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c32:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c36:	10049073          	csrw	sstatus,s1
}
    80002c3a:	70a2                	ld	ra,40(sp)
    80002c3c:	7402                	ld	s0,32(sp)
    80002c3e:	64e2                	ld	s1,24(sp)
    80002c40:	6942                	ld	s2,16(sp)
    80002c42:	69a2                	ld	s3,8(sp)
    80002c44:	6145                	addi	sp,sp,48
    80002c46:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c48:	00005517          	auipc	a0,0x5
    80002c4c:	6f050513          	addi	a0,a0,1776 # 80008338 <states.0+0xd0>
    80002c50:	b39fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	70c50513          	addi	a0,a0,1804 # 80008360 <states.0+0xf8>
    80002c5c:	b2dfd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c60:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c64:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c68:	85ce                	mv	a1,s3
    80002c6a:	00005517          	auipc	a0,0x5
    80002c6e:	71650513          	addi	a0,a0,1814 # 80008380 <states.0+0x118>
    80002c72:	851fd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    80002c76:	00005517          	auipc	a0,0x5
    80002c7a:	73250513          	addi	a0,a0,1842 # 800083a8 <states.0+0x140>
    80002c7e:	b0bfd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c82:	ecffe0ef          	jal	ra,80001b50 <myproc>
    80002c86:	d555                	beqz	a0,80002c32 <kerneltrap+0x34>
    yield();
    80002c88:	f8cff0ef          	jal	ra,80002414 <yield>
    80002c8c:	b75d                	j	80002c32 <kerneltrap+0x34>

0000000080002c8e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	e426                	sd	s1,8(sp)
    80002c96:	1000                	addi	s0,sp,32
    80002c98:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c9a:	eb7fe0ef          	jal	ra,80001b50 <myproc>
  switch (n) {
    80002c9e:	4795                	li	a5,5
    80002ca0:	0497e163          	bltu	a5,s1,80002ce2 <argraw+0x54>
    80002ca4:	048a                	slli	s1,s1,0x2
    80002ca6:	00005717          	auipc	a4,0x5
    80002caa:	73a70713          	addi	a4,a4,1850 # 800083e0 <states.0+0x178>
    80002cae:	94ba                	add	s1,s1,a4
    80002cb0:	409c                	lw	a5,0(s1)
    80002cb2:	97ba                	add	a5,a5,a4
    80002cb4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cb6:	6d3c                	ld	a5,88(a0)
    80002cb8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	64a2                	ld	s1,8(sp)
    80002cc0:	6105                	addi	sp,sp,32
    80002cc2:	8082                	ret
    return p->trapframe->a1;
    80002cc4:	6d3c                	ld	a5,88(a0)
    80002cc6:	7fa8                	ld	a0,120(a5)
    80002cc8:	bfcd                	j	80002cba <argraw+0x2c>
    return p->trapframe->a2;
    80002cca:	6d3c                	ld	a5,88(a0)
    80002ccc:	63c8                	ld	a0,128(a5)
    80002cce:	b7f5                	j	80002cba <argraw+0x2c>
    return p->trapframe->a3;
    80002cd0:	6d3c                	ld	a5,88(a0)
    80002cd2:	67c8                	ld	a0,136(a5)
    80002cd4:	b7dd                	j	80002cba <argraw+0x2c>
    return p->trapframe->a4;
    80002cd6:	6d3c                	ld	a5,88(a0)
    80002cd8:	6bc8                	ld	a0,144(a5)
    80002cda:	b7c5                	j	80002cba <argraw+0x2c>
    return p->trapframe->a5;
    80002cdc:	6d3c                	ld	a5,88(a0)
    80002cde:	6fc8                	ld	a0,152(a5)
    80002ce0:	bfe9                	j	80002cba <argraw+0x2c>
  panic("argraw");
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	6d650513          	addi	a0,a0,1750 # 800083b8 <states.0+0x150>
    80002cea:	a9ffd0ef          	jal	ra,80000788 <panic>

0000000080002cee <fetchaddr>:
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	e04a                	sd	s2,0(sp)
    80002cf8:	1000                	addi	s0,sp,32
    80002cfa:	84aa                	mv	s1,a0
    80002cfc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cfe:	e53fe0ef          	jal	ra,80001b50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d02:	653c                	ld	a5,72(a0)
    80002d04:	02f4f663          	bgeu	s1,a5,80002d30 <fetchaddr+0x42>
    80002d08:	00848713          	addi	a4,s1,8
    80002d0c:	02e7e463          	bltu	a5,a4,80002d34 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d10:	46a1                	li	a3,8
    80002d12:	8626                	mv	a2,s1
    80002d14:	85ca                	mv	a1,s2
    80002d16:	6928                	ld	a0,80(a0)
    80002d18:	b55fe0ef          	jal	ra,8000186c <copyin>
    80002d1c:	00a03533          	snez	a0,a0
    80002d20:	40a00533          	neg	a0,a0
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6902                	ld	s2,0(sp)
    80002d2c:	6105                	addi	sp,sp,32
    80002d2e:	8082                	ret
    return -1;
    80002d30:	557d                	li	a0,-1
    80002d32:	bfcd                	j	80002d24 <fetchaddr+0x36>
    80002d34:	557d                	li	a0,-1
    80002d36:	b7fd                	j	80002d24 <fetchaddr+0x36>

0000000080002d38 <fetchstr>:
{
    80002d38:	7179                	addi	sp,sp,-48
    80002d3a:	f406                	sd	ra,40(sp)
    80002d3c:	f022                	sd	s0,32(sp)
    80002d3e:	ec26                	sd	s1,24(sp)
    80002d40:	e84a                	sd	s2,16(sp)
    80002d42:	e44e                	sd	s3,8(sp)
    80002d44:	1800                	addi	s0,sp,48
    80002d46:	892a                	mv	s2,a0
    80002d48:	84ae                	mv	s1,a1
    80002d4a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d4c:	e05fe0ef          	jal	ra,80001b50 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d50:	86ce                	mv	a3,s3
    80002d52:	864a                	mv	a2,s2
    80002d54:	85a6                	mv	a1,s1
    80002d56:	6928                	ld	a0,80(a0)
    80002d58:	8ddfe0ef          	jal	ra,80001634 <copyinstr>
    80002d5c:	00054c63          	bltz	a0,80002d74 <fetchstr+0x3c>
  return strlen(buf);
    80002d60:	8526                	mv	a0,s1
    80002d62:	98afe0ef          	jal	ra,80000eec <strlen>
}
    80002d66:	70a2                	ld	ra,40(sp)
    80002d68:	7402                	ld	s0,32(sp)
    80002d6a:	64e2                	ld	s1,24(sp)
    80002d6c:	6942                	ld	s2,16(sp)
    80002d6e:	69a2                	ld	s3,8(sp)
    80002d70:	6145                	addi	sp,sp,48
    80002d72:	8082                	ret
    return -1;
    80002d74:	557d                	li	a0,-1
    80002d76:	bfc5                	j	80002d66 <fetchstr+0x2e>

0000000080002d78 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d78:	1101                	addi	sp,sp,-32
    80002d7a:	ec06                	sd	ra,24(sp)
    80002d7c:	e822                	sd	s0,16(sp)
    80002d7e:	e426                	sd	s1,8(sp)
    80002d80:	1000                	addi	s0,sp,32
    80002d82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d84:	f0bff0ef          	jal	ra,80002c8e <argraw>
    80002d88:	c088                	sw	a0,0(s1)
}
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	64a2                	ld	s1,8(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret

0000000080002d94 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d94:	1101                	addi	sp,sp,-32
    80002d96:	ec06                	sd	ra,24(sp)
    80002d98:	e822                	sd	s0,16(sp)
    80002d9a:	e426                	sd	s1,8(sp)
    80002d9c:	1000                	addi	s0,sp,32
    80002d9e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002da0:	eefff0ef          	jal	ra,80002c8e <argraw>
    80002da4:	e088                	sd	a0,0(s1)
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002db0:	7179                	addi	sp,sp,-48
    80002db2:	f406                	sd	ra,40(sp)
    80002db4:	f022                	sd	s0,32(sp)
    80002db6:	ec26                	sd	s1,24(sp)
    80002db8:	e84a                	sd	s2,16(sp)
    80002dba:	1800                	addi	s0,sp,48
    80002dbc:	84ae                	mv	s1,a1
    80002dbe:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002dc0:	fd840593          	addi	a1,s0,-40
    80002dc4:	fd1ff0ef          	jal	ra,80002d94 <argaddr>
  return fetchstr(addr, buf, max);
    80002dc8:	864a                	mv	a2,s2
    80002dca:	85a6                	mv	a1,s1
    80002dcc:	fd843503          	ld	a0,-40(s0)
    80002dd0:	f69ff0ef          	jal	ra,80002d38 <fetchstr>
}
    80002dd4:	70a2                	ld	ra,40(sp)
    80002dd6:	7402                	ld	s0,32(sp)
    80002dd8:	64e2                	ld	s1,24(sp)
    80002dda:	6942                	ld	s2,16(sp)
    80002ddc:	6145                	addi	sp,sp,48
    80002dde:	8082                	ret

0000000080002de0 <syscall>:
[SYS_sem_post]   sys_sem_post,
};

void
syscall(void)
{
    80002de0:	1101                	addi	sp,sp,-32
    80002de2:	ec06                	sd	ra,24(sp)
    80002de4:	e822                	sd	s0,16(sp)
    80002de6:	e426                	sd	s1,8(sp)
    80002de8:	e04a                	sd	s2,0(sp)
    80002dea:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dec:	d65fe0ef          	jal	ra,80001b50 <myproc>
    80002df0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002df2:	05853903          	ld	s2,88(a0)
    80002df6:	0a893783          	ld	a5,168(s2)
    80002dfa:	0007869b          	sext.w	a3,a5
  // printf("syscall num=%d\n", num);

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dfe:	37fd                	addiw	a5,a5,-1
    80002e00:	476d                	li	a4,27
    80002e02:	00f76f63          	bltu	a4,a5,80002e20 <syscall+0x40>
    80002e06:	00369713          	slli	a4,a3,0x3
    80002e0a:	00005797          	auipc	a5,0x5
    80002e0e:	5ee78793          	addi	a5,a5,1518 # 800083f8 <syscalls>
    80002e12:	97ba                	add	a5,a5,a4
    80002e14:	639c                	ld	a5,0(a5)
    80002e16:	c789                	beqz	a5,80002e20 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e18:	9782                	jalr	a5
    80002e1a:	06a93823          	sd	a0,112(s2)
    80002e1e:	a829                	j	80002e38 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e20:	15848613          	addi	a2,s1,344
    80002e24:	588c                	lw	a1,48(s1)
    80002e26:	00005517          	auipc	a0,0x5
    80002e2a:	59a50513          	addi	a0,a0,1434 # 800083c0 <states.0+0x158>
    80002e2e:	e94fd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e32:	6cbc                	ld	a5,88(s1)
    80002e34:	577d                	li	a4,-1
    80002e36:	fbb8                	sd	a4,112(a5)
  }
}
    80002e38:	60e2                	ld	ra,24(sp)
    80002e3a:	6442                	ld	s0,16(sp)
    80002e3c:	64a2                	ld	s1,8(sp)
    80002e3e:	6902                	ld	s2,0(sp)
    80002e40:	6105                	addi	sp,sp,32
    80002e42:	8082                	ret

0000000080002e44 <proc_has_shm_key>:
  }
  return best;
}
static int
proc_has_shm_key(struct proc *p, int key, struct vma *skip)
{
    80002e44:	1141                	addi	sp,sp,-16
    80002e46:	e422                	sd	s0,8(sp)
    80002e48:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80002e4a:	16850793          	addi	a5,a0,360
    80002e4e:	3e850513          	addi	a0,a0,1000
    80002e52:	a029                	j	80002e5c <proc_has_shm_key+0x18>
    80002e54:	02878793          	addi	a5,a5,40
    80002e58:	00a78d63          	beq	a5,a0,80002e72 <proc_has_shm_key+0x2e>
    struct vma *v = &p->vmas[i];
    if(v == skip) continue;
    80002e5c:	fef60ce3          	beq	a2,a5,80002e54 <proc_has_shm_key+0x10>
    if(v->used && v->is_shm && v->shm_key == key)
    80002e60:	4398                	lw	a4,0(a5)
    80002e62:	db6d                	beqz	a4,80002e54 <proc_has_shm_key+0x10>
    80002e64:	5398                	lw	a4,32(a5)
    80002e66:	d77d                	beqz	a4,80002e54 <proc_has_shm_key+0x10>
    80002e68:	53d8                	lw	a4,36(a5)
    80002e6a:	feb715e3          	bne	a4,a1,80002e54 <proc_has_shm_key+0x10>
      return 1;
    80002e6e:	4505                	li	a0,1
    80002e70:	a011                	j	80002e74 <proc_has_shm_key+0x30>
  }
  return 0;
    80002e72:	4501                	li	a0,0
}
    80002e74:	6422                	ld	s0,8(sp)
    80002e76:	0141                	addi	sp,sp,16
    80002e78:	8082                	ret

0000000080002e7a <sys_exit>:
{
    80002e7a:	1101                	addi	sp,sp,-32
    80002e7c:	ec06                	sd	ra,24(sp)
    80002e7e:	e822                	sd	s0,16(sp)
    80002e80:	1000                	addi	s0,sp,32
  argint(0, &n);
    80002e82:	fec40593          	addi	a1,s0,-20
    80002e86:	4501                	li	a0,0
    80002e88:	ef1ff0ef          	jal	ra,80002d78 <argint>
  kexit(n);
    80002e8c:	fec42503          	lw	a0,-20(s0)
    80002e90:	ebcff0ef          	jal	ra,8000254c <kexit>
}
    80002e94:	4501                	li	a0,0
    80002e96:	60e2                	ld	ra,24(sp)
    80002e98:	6442                	ld	s0,16(sp)
    80002e9a:	6105                	addi	sp,sp,32
    80002e9c:	8082                	ret

0000000080002e9e <sys_getpid>:
{
    80002e9e:	1141                	addi	sp,sp,-16
    80002ea0:	e406                	sd	ra,8(sp)
    80002ea2:	e022                	sd	s0,0(sp)
    80002ea4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ea6:	cabfe0ef          	jal	ra,80001b50 <myproc>
}
    80002eaa:	5908                	lw	a0,48(a0)
    80002eac:	60a2                	ld	ra,8(sp)
    80002eae:	6402                	ld	s0,0(sp)
    80002eb0:	0141                	addi	sp,sp,16
    80002eb2:	8082                	ret

0000000080002eb4 <sys_fork>:
{
    80002eb4:	1141                	addi	sp,sp,-16
    80002eb6:	e406                	sd	ra,8(sp)
    80002eb8:	e022                	sd	s0,0(sp)
    80002eba:	0800                	addi	s0,sp,16
  return kfork();
    80002ebc:	a50ff0ef          	jal	ra,8000210c <kfork>
}
    80002ec0:	60a2                	ld	ra,8(sp)
    80002ec2:	6402                	ld	s0,0(sp)
    80002ec4:	0141                	addi	sp,sp,16
    80002ec6:	8082                	ret

0000000080002ec8 <sys_wait>:
{
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	1000                	addi	s0,sp,32
  argaddr(0, &p);
    80002ed0:	fe840593          	addi	a1,s0,-24
    80002ed4:	4501                	li	a0,0
    80002ed6:	ebfff0ef          	jal	ra,80002d94 <argaddr>
  return kwait(p);
    80002eda:	fe843503          	ld	a0,-24(s0)
    80002ede:	fc4ff0ef          	jal	ra,800026a2 <kwait>
}
    80002ee2:	60e2                	ld	ra,24(sp)
    80002ee4:	6442                	ld	s0,16(sp)
    80002ee6:	6105                	addi	sp,sp,32
    80002ee8:	8082                	ret

0000000080002eea <sys_sbrk>:
{
    80002eea:	7179                	addi	sp,sp,-48
    80002eec:	f406                	sd	ra,40(sp)
    80002eee:	f022                	sd	s0,32(sp)
    80002ef0:	ec26                	sd	s1,24(sp)
    80002ef2:	1800                	addi	s0,sp,48
  argint(0, &n);
    80002ef4:	fd840593          	addi	a1,s0,-40
    80002ef8:	4501                	li	a0,0
    80002efa:	e7fff0ef          	jal	ra,80002d78 <argint>
  argint(1, &t);
    80002efe:	fdc40593          	addi	a1,s0,-36
    80002f02:	4505                	li	a0,1
    80002f04:	e75ff0ef          	jal	ra,80002d78 <argint>
  addr = myproc()->sz;
    80002f08:	c49fe0ef          	jal	ra,80001b50 <myproc>
    80002f0c:	6524                	ld	s1,72(a0)
  if(t == SBRK_EAGER || n < 0) {
    80002f0e:	fdc42703          	lw	a4,-36(s0)
    80002f12:	4785                	li	a5,1
    80002f14:	02f70763          	beq	a4,a5,80002f42 <sys_sbrk+0x58>
    80002f18:	fd842783          	lw	a5,-40(s0)
    80002f1c:	0207c363          	bltz	a5,80002f42 <sys_sbrk+0x58>
    if(addr + n < addr)
    80002f20:	97a6                	add	a5,a5,s1
    80002f22:	0297ee63          	bltu	a5,s1,80002f5e <sys_sbrk+0x74>
    if(addr + n > TRAPFRAME)
    80002f26:	02000737          	lui	a4,0x2000
    80002f2a:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002f2c:	0736                	slli	a4,a4,0xd
    80002f2e:	02f76a63          	bltu	a4,a5,80002f62 <sys_sbrk+0x78>
    myproc()->sz += n;
    80002f32:	c1ffe0ef          	jal	ra,80001b50 <myproc>
    80002f36:	fd842703          	lw	a4,-40(s0)
    80002f3a:	653c                	ld	a5,72(a0)
    80002f3c:	97ba                	add	a5,a5,a4
    80002f3e:	e53c                	sd	a5,72(a0)
    80002f40:	a039                	j	80002f4e <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002f42:	fd842503          	lw	a0,-40(s0)
    80002f46:	964ff0ef          	jal	ra,800020aa <growproc>
    80002f4a:	00054863          	bltz	a0,80002f5a <sys_sbrk+0x70>
}
    80002f4e:	8526                	mv	a0,s1
    80002f50:	70a2                	ld	ra,40(sp)
    80002f52:	7402                	ld	s0,32(sp)
    80002f54:	64e2                	ld	s1,24(sp)
    80002f56:	6145                	addi	sp,sp,48
    80002f58:	8082                	ret
      return -1;
    80002f5a:	54fd                	li	s1,-1
    80002f5c:	bfcd                	j	80002f4e <sys_sbrk+0x64>
      return -1;
    80002f5e:	54fd                	li	s1,-1
    80002f60:	b7fd                	j	80002f4e <sys_sbrk+0x64>
      return -1;
    80002f62:	54fd                	li	s1,-1
    80002f64:	b7ed                	j	80002f4e <sys_sbrk+0x64>

0000000080002f66 <sys_pause>:
{
    80002f66:	7139                	addi	sp,sp,-64
    80002f68:	fc06                	sd	ra,56(sp)
    80002f6a:	f822                	sd	s0,48(sp)
    80002f6c:	f426                	sd	s1,40(sp)
    80002f6e:	f04a                	sd	s2,32(sp)
    80002f70:	ec4e                	sd	s3,24(sp)
    80002f72:	0080                	addi	s0,sp,64
  argint(0, &n);
    80002f74:	fcc40593          	addi	a1,s0,-52
    80002f78:	4501                	li	a0,0
    80002f7a:	dffff0ef          	jal	ra,80002d78 <argint>
  if(n < 0)
    80002f7e:	fcc42783          	lw	a5,-52(s0)
    80002f82:	0607c563          	bltz	a5,80002fec <sys_pause+0x86>
  acquire(&tickslock);
    80002f86:	0023e517          	auipc	a0,0x23e
    80002f8a:	89a50513          	addi	a0,a0,-1894 # 80240820 <tickslock>
    80002f8e:	d13fd0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    80002f92:	00006917          	auipc	s2,0x6
    80002f96:	94692903          	lw	s2,-1722(s2) # 800088d8 <ticks>
  while(ticks - ticks0 < n){
    80002f9a:	fcc42783          	lw	a5,-52(s0)
    80002f9e:	cb8d                	beqz	a5,80002fd0 <sys_pause+0x6a>
    sleep(&ticks, &tickslock);
    80002fa0:	0023e997          	auipc	s3,0x23e
    80002fa4:	88098993          	addi	s3,s3,-1920 # 80240820 <tickslock>
    80002fa8:	00006497          	auipc	s1,0x6
    80002fac:	93048493          	addi	s1,s1,-1744 # 800088d8 <ticks>
    if(killed(myproc())){
    80002fb0:	ba1fe0ef          	jal	ra,80001b50 <myproc>
    80002fb4:	ec4ff0ef          	jal	ra,80002678 <killed>
    80002fb8:	ed0d                	bnez	a0,80002ff2 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002fba:	85ce                	mv	a1,s3
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	c82ff0ef          	jal	ra,80002440 <sleep>
  while(ticks - ticks0 < n){
    80002fc2:	409c                	lw	a5,0(s1)
    80002fc4:	412787bb          	subw	a5,a5,s2
    80002fc8:	fcc42703          	lw	a4,-52(s0)
    80002fcc:	fee7e2e3          	bltu	a5,a4,80002fb0 <sys_pause+0x4a>
  release(&tickslock);
    80002fd0:	0023e517          	auipc	a0,0x23e
    80002fd4:	85050513          	addi	a0,a0,-1968 # 80240820 <tickslock>
    80002fd8:	d61fd0ef          	jal	ra,80000d38 <release>
  return 0;
    80002fdc:	4501                	li	a0,0
}
    80002fde:	70e2                	ld	ra,56(sp)
    80002fe0:	7442                	ld	s0,48(sp)
    80002fe2:	74a2                	ld	s1,40(sp)
    80002fe4:	7902                	ld	s2,32(sp)
    80002fe6:	69e2                	ld	s3,24(sp)
    80002fe8:	6121                	addi	sp,sp,64
    80002fea:	8082                	ret
    n = 0;
    80002fec:	fc042623          	sw	zero,-52(s0)
    80002ff0:	bf59                	j	80002f86 <sys_pause+0x20>
      release(&tickslock);
    80002ff2:	0023e517          	auipc	a0,0x23e
    80002ff6:	82e50513          	addi	a0,a0,-2002 # 80240820 <tickslock>
    80002ffa:	d3ffd0ef          	jal	ra,80000d38 <release>
      return -1;
    80002ffe:	557d                	li	a0,-1
    80003000:	bff9                	j	80002fde <sys_pause+0x78>

0000000080003002 <sys_kill>:
{
    80003002:	1101                	addi	sp,sp,-32
    80003004:	ec06                	sd	ra,24(sp)
    80003006:	e822                	sd	s0,16(sp)
    80003008:	1000                	addi	s0,sp,32
  argint(0, &pid);
    8000300a:	fec40593          	addi	a1,s0,-20
    8000300e:	4501                	li	a0,0
    80003010:	d69ff0ef          	jal	ra,80002d78 <argint>
  return kkill(pid);
    80003014:	fec42503          	lw	a0,-20(s0)
    80003018:	dd6ff0ef          	jal	ra,800025ee <kkill>
}
    8000301c:	60e2                	ld	ra,24(sp)
    8000301e:	6442                	ld	s0,16(sp)
    80003020:	6105                	addi	sp,sp,32
    80003022:	8082                	ret

0000000080003024 <sys_uptime>:
{
    80003024:	1101                	addi	sp,sp,-32
    80003026:	ec06                	sd	ra,24(sp)
    80003028:	e822                	sd	s0,16(sp)
    8000302a:	e426                	sd	s1,8(sp)
    8000302c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000302e:	0023d517          	auipc	a0,0x23d
    80003032:	7f250513          	addi	a0,a0,2034 # 80240820 <tickslock>
    80003036:	c6bfd0ef          	jal	ra,80000ca0 <acquire>
  xticks = ticks;
    8000303a:	00006497          	auipc	s1,0x6
    8000303e:	89e4a483          	lw	s1,-1890(s1) # 800088d8 <ticks>
  release(&tickslock);
    80003042:	0023d517          	auipc	a0,0x23d
    80003046:	7de50513          	addi	a0,a0,2014 # 80240820 <tickslock>
    8000304a:	ceffd0ef          	jal	ra,80000d38 <release>
}
    8000304e:	02049513          	slli	a0,s1,0x20
    80003052:	9101                	srli	a0,a0,0x20
    80003054:	60e2                	ld	ra,24(sp)
    80003056:	6442                	ld	s0,16(sp)
    80003058:	64a2                	ld	s1,8(sp)
    8000305a:	6105                	addi	sp,sp,32
    8000305c:	8082                	ret

000000008000305e <vma_find>:
{
    8000305e:	1141                	addi	sp,sp,-16
    80003060:	e422                	sd	s0,8(sp)
    80003062:	0800                	addi	s0,sp,16
  for(int i = 0; i < NVMA; i++){
    80003064:	16850793          	addi	a5,a0,360
    80003068:	4701                	li	a4,0
    8000306a:	4841                	li	a6,16
    8000306c:	a031                	j	80003078 <vma_find+0x1a>
    8000306e:	2705                	addiw	a4,a4,1
    80003070:	02878793          	addi	a5,a5,40
    80003074:	03070263          	beq	a4,a6,80003098 <vma_find+0x3a>
    if(!p->vmas[i].used) continue;
    80003078:	4394                	lw	a3,0(a5)
    8000307a:	daf5                	beqz	a3,8000306e <vma_find+0x10>
    if(va >= p->vmas[i].start && va < p->vmas[i].end)
    8000307c:	6794                	ld	a3,8(a5)
    8000307e:	fed5e8e3          	bltu	a1,a3,8000306e <vma_find+0x10>
    80003082:	6b94                	ld	a3,16(a5)
    80003084:	fed5f5e3          	bgeu	a1,a3,8000306e <vma_find+0x10>
      return &p->vmas[i];
    80003088:	00271793          	slli	a5,a4,0x2
    8000308c:	97ba                	add	a5,a5,a4
    8000308e:	078e                	slli	a5,a5,0x3
    80003090:	16878793          	addi	a5,a5,360
    80003094:	953e                	add	a0,a0,a5
    80003096:	a011                	j	8000309a <vma_find+0x3c>
  return 0;
    80003098:	4501                	li	a0,0
}
    8000309a:	6422                	ld	s0,8(sp)
    8000309c:	0141                	addi	sp,sp,16
    8000309e:	8082                	ret

00000000800030a0 <sys_mmap>:

uint64
sys_mmap(void)
{
    800030a0:	7119                	addi	sp,sp,-128
    800030a2:	fc86                	sd	ra,120(sp)
    800030a4:	f8a2                	sd	s0,112(sp)
    800030a6:	f4a6                	sd	s1,104(sp)
    800030a8:	f0ca                	sd	s2,96(sp)
    800030aa:	ecce                	sd	s3,88(sp)
    800030ac:	e8d2                	sd	s4,80(sp)
    800030ae:	e4d6                	sd	s5,72(sp)
    800030b0:	e0da                	sd	s6,64(sp)
    800030b2:	fc5e                	sd	s7,56(sp)
    800030b4:	f862                	sd	s8,48(sp)
    800030b6:	f466                	sd	s9,40(sp)
    800030b8:	0100                	addi	s0,sp,128
  uint64 addr;
  int len, prot, flags, key = -1;
    800030ba:	57fd                	li	a5,-1
    800030bc:	f8f42423          	sw	a5,-120(s0)
  int did_shm_get = 0;
  int need_get = 0;
  int npages = 0;

  argaddr(0, &addr);
    800030c0:	f9840593          	addi	a1,s0,-104
    800030c4:	4501                	li	a0,0
    800030c6:	ccfff0ef          	jal	ra,80002d94 <argaddr>
  argint(1, &len);
    800030ca:	f9440593          	addi	a1,s0,-108
    800030ce:	4505                	li	a0,1
    800030d0:	ca9ff0ef          	jal	ra,80002d78 <argint>
  argint(2, &prot);
    800030d4:	f9040593          	addi	a1,s0,-112
    800030d8:	4509                	li	a0,2
    800030da:	c9fff0ef          	jal	ra,80002d78 <argint>
  argint(3, &flags);
    800030de:	f8c40593          	addi	a1,s0,-116
    800030e2:	450d                	li	a0,3
    800030e4:	c95ff0ef          	jal	ra,80002d78 <argint>
  argint(4, &key);
    800030e8:	f8840593          	addi	a1,s0,-120
    800030ec:	4511                	li	a0,4
    800030ee:	c8bff0ef          	jal	ra,80002d78 <argint>

  if(len <= 0) return (uint64)-1;
    800030f2:	f9442783          	lw	a5,-108(s0)
    800030f6:	1af05d63          	blez	a5,800032b0 <sys_mmap+0x210>
  uint64 plen = PGROUNDUP((uint64)len);
  if(plen == 0) return (uint64)-1;
  if(plen > (MMAPTOP - MMAPBASE)) return (uint64)-1;

  if((prot & ~(PROT_READ|PROT_WRITE)) != 0) return (uint64)-1;
    800030fa:	f9042903          	lw	s2,-112(s0)
    800030fe:	ffc97913          	andi	s2,s2,-4
    80003102:	54fd                	li	s1,-1
    80003104:	1a091763          	bnez	s2,800032b2 <sys_mmap+0x212>
  if((flags & MAP_ANON) == 0) return (uint64)-1;
    80003108:	f8c42703          	lw	a4,-116(s0)
    8000310c:	8b05                	andi	a4,a4,1
    8000310e:	1a070263          	beqz	a4,800032b2 <sys_mmap+0x212>
  if(addr != 0) return (uint64)-1;
    80003112:	f9843a03          	ld	s4,-104(s0)
    80003116:	180a1e63          	bnez	s4,800032b2 <sys_mmap+0x212>
  uint64 plen = PGROUNDUP((uint64)len);
    8000311a:	6705                	lui	a4,0x1
    8000311c:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    8000311e:	00e789b3          	add	s3,a5,a4

  struct proc *p = myproc();
    80003122:	a2ffe0ef          	jal	ra,80001b50 <myproc>
    80003126:	8aaa                	mv	s5,a0

  //先把“是否需要 shm_get”算出来（此时还没创建/污染 vma）
  if(flags & MAP_SHARED){
    80003128:	f8c42b83          	lw	s7,-116(s0)
    8000312c:	002bfb93          	andi	s7,s7,2
    80003130:	020b8563          	beqz	s7,8000315a <sys_mmap+0xba>
    if(key < 0) return (uint64)-1;
    80003134:	f8842503          	lw	a0,-120(s0)
    80003138:	16054d63          	bltz	a0,800032b2 <sys_mmap+0x212>
    npages = plen / PGSIZE;
    8000313c:	40c9dc13          	srai	s8,s3,0xc

    // rmid 后禁止新 attach
    if(shm_is_deleted(key))
    80003140:	009030ef          	jal	ra,80006948 <shm_is_deleted>
    80003144:	16051763          	bnez	a0,800032b2 <sys_mmap+0x212>
      return (uint64)-1;

    // 按进程计数：本进程首次引用才 shm_get
    if(!proc_has_shm_key(p, key, 0))
    80003148:	4601                	li	a2,0
    8000314a:	f8842583          	lw	a1,-120(s0)
    8000314e:	8556                	mv	a0,s5
    80003150:	cf5ff0ef          	jal	ra,80002e44 <proc_has_shm_key>
  int need_get = 0;
    80003154:	00153b93          	seqz	s7,a0
    80003158:	a011                	j	8000315c <sys_mmap+0xbc>
  int npages = 0;
    8000315a:	8c5e                	mv	s8,s7
  for(int i = 0; i < NVMA; i++){
    8000315c:	168a8b13          	addi	s6,s5,360
  int npages = 0;
    80003160:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    80003162:	46c1                	li	a3,16
    if(!p->vmas[i].used)
    80003164:	4398                	lw	a4,0(a5)
    80003166:	cb01                	beqz	a4,80003176 <sys_mmap+0xd6>
  for(int i = 0; i < NVMA; i++){
    80003168:	2905                	addiw	s2,s2,1
    8000316a:	02878793          	addi	a5,a5,40
    8000316e:	fed91be3          	bne	s2,a3,80003164 <sys_mmap+0xc4>
      need_get = 1;
  }

  struct vma *v = vma_alloc_slot(p);
  if(v == 0) return (uint64)-1;
    80003172:	54fd                	li	s1,-1
    80003174:	aa3d                	j	800032b2 <sys_mmap+0x212>
  uint64 plen = PGROUNDUP((uint64)len);
    80003176:	74fd                	lui	s1,0xfffff
    80003178:	0099f9b3          	and	s3,s3,s1
      return &p->vmas[i];
    8000317c:	00291c93          	slli	s9,s2,0x2
    80003180:	012c8533          	add	a0,s9,s2
    80003184:	050e                	slli	a0,a0,0x3
    80003186:	16850513          	addi	a0,a0,360

  // 先清空这条 slot，避免失败时留下脏状态
  memset(v, 0, sizeof(*v));
    8000318a:	02800613          	li	a2,40
    8000318e:	4581                	li	a1,0
    80003190:	9556                	add	a0,a0,s5
    80003192:	be3fd0ef          	jal	ra,80000d74 <memset>
  v->shm_key = -1;
    80003196:	012c87b3          	add	a5,s9,s2
    8000319a:	078e                	slli	a5,a5,0x3
    8000319c:	97d6                	add	a5,a5,s5
    8000319e:	577d                	li	a4,-1
    800031a0:	18e7a623          	sw	a4,396(a5)
  len = PGROUNDUP(len);
    800031a4:	6805                	lui	a6,0x1
    800031a6:	187d                	addi	a6,a6,-1 # fff <_entry-0x7ffff001>
    800031a8:	984e                	add	a6,a6,s3
    800031aa:	00987833          	and	a6,a6,s1
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    800031ae:	400005b7          	lui	a1,0x40000
    800031b2:	95c2                	add	a1,a1,a6
    800031b4:	400004b7          	lui	s1,0x40000
    800031b8:	3e8a8613          	addi	a2,s5,1000
    va = PGROUNDUP(jump);
    800031bc:	6305                	lui	t1,0x1
    800031be:	137d                	addi	t1,t1,-1 # fff <_entry-0x7ffff001>
    800031c0:	7e7d                	lui	t3,0xfffff
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    800031c2:	f3fff8b7          	lui	a7,0xf3fff
    800031c6:	08ba                	slli	a7,a7,0xe
    800031c8:	01a8d893          	srli	a7,a7,0x1a
    800031cc:	a81d                	j	80003202 <sys_mmap+0x162>
      if(best == 0 || e < best) best = e;
    800031ce:	853a                	mv	a0,a4
  for(int i=0;i<NVMA;i++){
    800031d0:	02878793          	addi	a5,a5,40
    800031d4:	00c78f63          	beq	a5,a2,800031f2 <sys_mmap+0x152>
    if(!p->vmas[i].used) continue;
    800031d8:	4398                	lw	a4,0(a5)
    800031da:	db7d                	beqz	a4,800031d0 <sys_mmap+0x130>
    if(!(end <= s || start >= e)){
    800031dc:	6798                	ld	a4,8(a5)
    800031de:	feb779e3          	bgeu	a4,a1,800031d0 <sys_mmap+0x130>
    uint64 e = p->vmas[i].end;
    800031e2:	6b98                	ld	a4,16(a5)
    if(!(end <= s || start >= e)){
    800031e4:	fee4f6e3          	bgeu	s1,a4,800031d0 <sys_mmap+0x130>
      if(best == 0 || e < best) best = e;
    800031e8:	d17d                	beqz	a0,800031ce <sys_mmap+0x12e>
    800031ea:	fea773e3          	bgeu	a4,a0,800031d0 <sys_mmap+0x130>
    800031ee:	853a                	mv	a0,a4
    800031f0:	b7c5                	j	800031d0 <sys_mmap+0x130>
    if(jump == 0){
    800031f2:	c919                	beqz	a0,80003208 <sys_mmap+0x168>
    va = PGROUNDUP(jump);
    800031f4:	951a                	add	a0,a0,t1
    800031f6:	01c574b3          	and	s1,a0,t3
  for(uint64 va = MMAPBASE; va + len < MMAPTOP; ){
    800031fa:	009805b3          	add	a1,a6,s1
    800031fe:	06b8ee63          	bltu	a7,a1,8000327a <sys_mmap+0x1da>
  int npages = 0;
    80003202:	87da                	mv	a5,s6
  uint64 best = 0;
    80003204:	8552                	mv	a0,s4
    80003206:	bfc9                	j	800031d8 <sys_mmap+0x138>

  uint64 va = vma_find_space(p, plen);
  if(va == 0) goto bad;
  if(va < MMAPBASE || va + plen > MMAPTOP) goto bad;
    80003208:	400007b7          	lui	a5,0x40000
    8000320c:	06f4e763          	bltu	s1,a5,8000327a <sys_mmap+0x1da>
    80003210:	99a6                	add	s3,s3,s1
    80003212:	010007b7          	lui	a5,0x1000
    80003216:	17f5                	addi	a5,a5,-3 # fffffd <_entry-0x7f000003>
    80003218:	07ba                	slli	a5,a5,0xe
    8000321a:	0737e063          	bltu	a5,s3,8000327a <sys_mmap+0x1da>

  // 先写入 vma 基本信息
  v->used  = 1;
    8000321e:	00291793          	slli	a5,s2,0x2
    80003222:	97ca                	add	a5,a5,s2
    80003224:	078e                	slli	a5,a5,0x3
    80003226:	97d6                	add	a5,a5,s5
    80003228:	4705                	li	a4,1
    8000322a:	16e7a423          	sw	a4,360(a5)
  v->start = va;
    8000322e:	1697b823          	sd	s1,368(a5)
  v->end   = va + plen;
    80003232:	1737bc23          	sd	s3,376(a5)
  v->prot  = prot;
    80003236:	f9042703          	lw	a4,-112(s0)
    8000323a:	18e7a023          	sw	a4,384(a5)
  v->flags = flags;
    8000323e:	f8c42703          	lw	a4,-116(s0)
    80003242:	18e7a223          	sw	a4,388(a5)

  if(flags & MAP_SHARED){
    80003246:	8b09                	andi	a4,a4,2
    80003248:	c72d                	beqz	a4,800032b2 <sys_mmap+0x212>
    if(need_get){
    8000324a:	020b9163          	bnez	s7,8000326c <sys_mmap+0x1cc>
      if(shm_get(key, npages) < 0)
        goto bad;
      did_shm_get = 1;
    }
    v->is_shm = 1;
    8000324e:	00291793          	slli	a5,s2,0x2
    80003252:	01278733          	add	a4,a5,s2
    80003256:	070e                	slli	a4,a4,0x3
    80003258:	9756                	add	a4,a4,s5
    8000325a:	4685                	li	a3,1
    8000325c:	18d72423          	sw	a3,392(a4)
    v->shm_key = key;
    80003260:	87ba                	mv	a5,a4
    80003262:	f8842703          	lw	a4,-120(s0)
    80003266:	18e7a623          	sw	a4,396(a5)
    8000326a:	a0a1                	j	800032b2 <sys_mmap+0x212>
      if(shm_get(key, npages) < 0)
    8000326c:	85e2                	mv	a1,s8
    8000326e:	f8842503          	lw	a0,-120(s0)
    80003272:	29a030ef          	jal	ra,8000650c <shm_get>
    80003276:	fc055ce3          	bgez	a0,8000324e <sys_mmap+0x1ae>
bad:
  if(did_shm_get){
    shm_put(key);
  }
  if(v){
    v->used = 0;
    8000327a:	00291713          	slli	a4,s2,0x2
    8000327e:	012707b3          	add	a5,a4,s2
    80003282:	078e                	slli	a5,a5,0x3
    80003284:	97d6                	add	a5,a5,s5
    80003286:	1607a423          	sw	zero,360(a5)
    v->is_shm = 0;
    8000328a:	1807a423          	sw	zero,392(a5)
    v->shm_key = -1;
    8000328e:	56fd                	li	a3,-1
    80003290:	18d7a623          	sw	a3,396(a5)
    v->start = v->end = 0;
    80003294:	1607bc23          	sd	zero,376(a5)
    80003298:	1607b823          	sd	zero,368(a5)
    v->prot = v->flags = 0;
    8000329c:	1807a223          	sw	zero,388(a5)
    800032a0:	012707b3          	add	a5,a4,s2
    800032a4:	078e                	slli	a5,a5,0x3
    800032a6:	9abe                	add	s5,s5,a5
    800032a8:	180aa023          	sw	zero,384(s5)
  }
  return (uint64)-1;
    800032ac:	54fd                	li	s1,-1
    800032ae:	a011                	j	800032b2 <sys_mmap+0x212>
  if(len <= 0) return (uint64)-1;
    800032b0:	54fd                	li	s1,-1
}
    800032b2:	8526                	mv	a0,s1
    800032b4:	70e6                	ld	ra,120(sp)
    800032b6:	7446                	ld	s0,112(sp)
    800032b8:	74a6                	ld	s1,104(sp)
    800032ba:	7906                	ld	s2,96(sp)
    800032bc:	69e6                	ld	s3,88(sp)
    800032be:	6a46                	ld	s4,80(sp)
    800032c0:	6aa6                	ld	s5,72(sp)
    800032c2:	6b06                	ld	s6,64(sp)
    800032c4:	7be2                	ld	s7,56(sp)
    800032c6:	7c42                	ld	s8,48(sp)
    800032c8:	7ca2                	ld	s9,40(sp)
    800032ca:	6109                	addi	sp,sp,128
    800032cc:	8082                	ret

00000000800032ce <sys_munmap>:
}


uint64
sys_munmap(void)
{
    800032ce:	7159                	addi	sp,sp,-112
    800032d0:	f486                	sd	ra,104(sp)
    800032d2:	f0a2                	sd	s0,96(sp)
    800032d4:	eca6                	sd	s1,88(sp)
    800032d6:	e8ca                	sd	s2,80(sp)
    800032d8:	e4ce                	sd	s3,72(sp)
    800032da:	e0d2                	sd	s4,64(sp)
    800032dc:	fc56                	sd	s5,56(sp)
    800032de:	f85a                	sd	s6,48(sp)
    800032e0:	f45e                	sd	s7,40(sp)
    800032e2:	f062                	sd	s8,32(sp)
    800032e4:	ec66                	sd	s9,24(sp)
    800032e6:	e86a                	sd	s10,16(sp)
    800032e8:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    800032ea:	867fe0ef          	jal	ra,80001b50 <myproc>
    800032ee:	8aaa                	mv	s5,a0
  uint64 uaddr;
  int len;

  argaddr(0, &uaddr);
    800032f0:	f9840593          	addi	a1,s0,-104
    800032f4:	4501                	li	a0,0
    800032f6:	a9fff0ef          	jal	ra,80002d94 <argaddr>
  argint(1, &len);
    800032fa:	f9440593          	addi	a1,s0,-108
    800032fe:	4505                	li	a0,1
    80003300:	a79ff0ef          	jal	ra,80002d78 <argint>

  if(len <= 0) return (uint64)-1;
    80003304:	f9442683          	lw	a3,-108(s0)
    80003308:	2cd05f63          	blez	a3,800035e6 <sys_munmap+0x318>


  uint64 a = PGROUNDDOWN(uaddr);
    8000330c:	f9843783          	ld	a5,-104(s0)
    80003310:	767d                	lui	a2,0xfffff
    80003312:	00c7fa33          	and	s4,a5,a2
  uint64 b = PGROUNDUP(uaddr + (uint64)len);
    80003316:	6705                	lui	a4,0x1
    80003318:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    8000331a:	00e78933          	add	s2,a5,a4
    8000331e:	9936                	add	s2,s2,a3
    80003320:	00c97933          	and	s2,s2,a2
  if(b < a) return (uint64)-1;  // 溢出了
    80003324:	557d                	li	a0,-1
    80003326:	17496d63          	bltu	s2,s4,800034a0 <sys_munmap+0x1d2>
    8000332a:	168a8b13          	addi	s6,s5,360
    8000332e:	3e8a8993          	addi	s3,s5,1000
    80003332:	87da                	mv	a5,s6

  // 为了保证一致性，我们先预检查split槽位是否够 
  int need_splits = 0;
  int free_slots = 0;
    80003334:	4801                	li	a6,0
    80003336:	a029                	j	80003340 <sys_munmap+0x72>
  for(int i=0;i<NVMA;i++) if(!p->vmas[i].used) free_slots++;
    80003338:	02878793          	addi	a5,a5,40
    8000333c:	01378663          	beq	a5,s3,80003348 <sys_munmap+0x7a>
    80003340:	4398                	lw	a4,0(a5)
    80003342:	fb7d                	bnez	a4,80003338 <sys_munmap+0x6a>
    80003344:	2805                	addiw	a6,a6,1
    80003346:	bfcd                	j	80003338 <sys_munmap+0x6a>

  // 扫描所有受影响 VMA，统计“中间切”次数
  uint64 cur = a;
    80003348:	8552                	mv	a0,s4
  int need_splits = 0;
    8000334a:	4e01                	li	t3,0
  for(int i = 0; i < NVMA; i++){
    8000334c:	4881                	li	a7,0
    8000334e:	45c1                	li	a1,16
    80003350:	537d                	li	t1,-1
  while(cur < b){
    80003352:	072a6163          	bltu	s4,s2,800033b4 <sys_munmap+0xe6>
      need_splits++;

    cur = seg_end;
  }

  if(need_splits > free_slots){
    80003356:	43f85513          	srai	a0,a6,0x3f
    8000335a:	a299                	j	800034a0 <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    8000335c:	2705                	addiw	a4,a4,1
    8000335e:	02878793          	addi	a5,a5,40
    80003362:	04b70c63          	beq	a4,a1,800033ba <sys_munmap+0xec>
    if(!p->vmas[i].used) continue;
    80003366:	4394                	lw	a3,0(a5)
    80003368:	daf5                	beqz	a3,8000335c <sys_munmap+0x8e>
    if(!(b <= s || a >= e))   // overlap
    8000336a:	6794                	ld	a3,8(a5)
    8000336c:	ff26f8e3          	bgeu	a3,s2,8000335c <sys_munmap+0x8e>
    80003370:	6b94                	ld	a3,16(a5)
    80003372:	fed575e3          	bgeu	a0,a3,8000335c <sys_munmap+0x8e>
    if(vi < 0){
    80003376:	04074563          	bltz	a4,800033c0 <sys_munmap+0xf2>
    uint64 seg_start = cur > v->start ? cur : v->start;
    8000337a:	00271793          	slli	a5,a4,0x2
    8000337e:	97ba                	add	a5,a5,a4
    80003380:	078e                	slli	a5,a5,0x3
    80003382:	97d6                	add	a5,a5,s5
    80003384:	1707b683          	ld	a3,368(a5)
    80003388:	8636                	mv	a2,a3
    8000338a:	00a6f363          	bgeu	a3,a0,80003390 <sys_munmap+0xc2>
    8000338e:	862a                	mv	a2,a0
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003390:	00271793          	slli	a5,a4,0x2
    80003394:	97ba                	add	a5,a5,a4
    80003396:	078e                	slli	a5,a5,0x3
    80003398:	97d6                	add	a5,a5,s5
    8000339a:	1787b783          	ld	a5,376(a5)
    8000339e:	853e                	mv	a0,a5
    800033a0:	00f97363          	bgeu	s2,a5,800033a6 <sys_munmap+0xd8>
    800033a4:	854a                	mv	a0,s2
    if(v->start < seg_start && seg_end < v->end)
    800033a6:	00c6f563          	bgeu	a3,a2,800033b0 <sys_munmap+0xe2>
    800033aa:	00f57363          	bgeu	a0,a5,800033b0 <sys_munmap+0xe2>
      need_splits++;
    800033ae:	2e05                	addiw	t3,t3,1 # fffffffffffff001 <end+0xffffffff7fdaae51>
  while(cur < b){
    800033b0:	03257a63          	bgeu	a0,s2,800033e4 <sys_munmap+0x116>
  int free_slots = 0;
    800033b4:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    800033b6:	8746                	mv	a4,a7
    800033b8:	b77d                	j	80003366 <sys_munmap+0x98>
    800033ba:	87da                	mv	a5,s6
    800033bc:	869a                	mv	a3,t1
    800033be:	a801                	j	800033ce <sys_munmap+0x100>
    800033c0:	87da                	mv	a5,s6
    800033c2:	869a                	mv	a3,t1
    800033c4:	a029                	j	800033ce <sys_munmap+0x100>
  for(int i = 0; i < NVMA; i++){
    800033c6:	02878793          	addi	a5,a5,40
    800033ca:	01378b63          	beq	a5,s3,800033e0 <sys_munmap+0x112>
    if(!p->vmas[i].used) continue;
    800033ce:	4398                	lw	a4,0(a5)
    800033d0:	db7d                	beqz	a4,800033c6 <sys_munmap+0xf8>
    uint64 s = p->vmas[i].start;
    800033d2:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    800033d4:	fea769e3          	bltu	a4,a0,800033c6 <sys_munmap+0xf8>
    800033d8:	fed777e3          	bgeu	a4,a3,800033c6 <sys_munmap+0xf8>
    800033dc:	86ba                	mv	a3,a4
    800033de:	b7e5                	j	800033c6 <sys_munmap+0xf8>
      if(ns == (uint64)-1 || ns >= b) break;
    800033e0:	0126e963          	bltu	a3,s2,800033f2 <sys_munmap+0x124>
    // 不做任何事，保持一致性
    return (uint64)-1;
    800033e4:	557d                	li	a0,-1
  if(need_splits > free_slots){
    800033e6:	0bc84d63          	blt	a6,t3,800034a0 <sys_munmap+0x1d2>
  for(int i = 0; i < NVMA; i++){
    800033ea:	4c01                	li	s8,0
    800033ec:	4bc1                	li	s7,16
    800033ee:	5cfd                	li	s9,-1
    800033f0:	aac5                	j	800035e0 <sys_munmap+0x312>
    800033f2:	8536                	mv	a0,a3
    800033f4:	b7c1                	j	800033b4 <sys_munmap+0xe6>
    800033f6:	2485                	addiw	s1,s1,1 # 40000001 <_entry-0x3fffffff>
    800033f8:	02878793          	addi	a5,a5,40
    800033fc:	07748c63          	beq	s1,s7,80003474 <sys_munmap+0x1a6>
    if(!p->vmas[i].used) continue;
    80003400:	4398                	lw	a4,0(a5)
    80003402:	db75                	beqz	a4,800033f6 <sys_munmap+0x128>
    if(!(b <= s || a >= e))   // overlap
    80003404:	6798                	ld	a4,8(a5)
    80003406:	ff2778e3          	bgeu	a4,s2,800033f6 <sys_munmap+0x128>
    8000340a:	6b98                	ld	a4,16(a5)
    8000340c:	feea75e3          	bgeu	s4,a4,800033f6 <sys_munmap+0x128>

  //真正执行 unmap
  cur = a;
  while(cur < b){
    int vi = vma_find_overlap(p, cur, b);
    if(vi < 0){
    80003410:	0604c563          	bltz	s1,8000347a <sys_munmap+0x1ac>
      cur = ns;
      continue;
    }

    struct vma *v = &p->vmas[vi];
    uint64 seg_start = cur > v->start ? cur : v->start;
    80003414:	00249793          	slli	a5,s1,0x2
    80003418:	97a6                	add	a5,a5,s1
    8000341a:	078e                	slli	a5,a5,0x3
    8000341c:	97d6                	add	a5,a5,s5
    8000341e:	1707bd03          	ld	s10,368(a5)
    80003422:	014d7363          	bgeu	s10,s4,80003428 <sys_munmap+0x15a>
    80003426:	8d52                	mv	s10,s4
    uint64 seg_end   = b   < v->end   ? b   : v->end;
    80003428:	00249793          	slli	a5,s1,0x2
    8000342c:	97a6                	add	a5,a5,s1
    8000342e:	078e                	slli	a5,a5,0x3
    80003430:	97d6                	add	a5,a5,s5
    80003432:	1787ba03          	ld	s4,376(a5)
    80003436:	01497363          	bgeu	s2,s4,8000343c <sys_munmap+0x16e>
    8000343a:	8a4a                	mv	s4,s2

    // 先拆页表（按页）
    if(seg_end > seg_start){
    8000343c:	094d6263          	bltu	s10,s4,800034c0 <sys_munmap+0x1f2>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    }

    // 再更新VMA(四种情况)
    if(seg_start <= v->start && seg_end >= v->end){
    80003440:	00249793          	slli	a5,s1,0x2
    80003444:	97a6                	add	a5,a5,s1
    80003446:	078e                	slli	a5,a5,0x3
    80003448:	97d6                	add	a5,a5,s5
    8000344a:	1707b783          	ld	a5,368(a5)
    8000344e:	11a7e463          	bltu	a5,s10,80003556 <sys_munmap+0x288>
    80003452:	00249793          	slli	a5,s1,0x2
    80003456:	97a6                	add	a5,a5,s1
    80003458:	078e                	slli	a5,a5,0x3
    8000345a:	97d6                	add	a5,a5,s5
    8000345c:	1787b783          	ld	a5,376(a5)
    80003460:	06fa7a63          	bgeu	s4,a5,800034d4 <sys_munmap+0x206>
      //  v->shm_key, v->used, (void *)v->start, (void *)v->end);

      vma_delete(p, v);
    } else if(seg_start <= v->start && seg_end < v->end){
      // 从头砍
      v->start = seg_end;
    80003464:	00249793          	slli	a5,s1,0x2
    80003468:	97a6                	add	a5,a5,s1
    8000346a:	078e                	slli	a5,a5,0x3
    8000346c:	97d6                	add	a5,a5,s5
    8000346e:	1747b823          	sd	s4,368(a5)
    80003472:	a2ad                	j	800035dc <sys_munmap+0x30e>
    80003474:	87da                	mv	a5,s6
    80003476:	86e6                	mv	a3,s9
    80003478:	a801                	j	80003488 <sys_munmap+0x1ba>
    8000347a:	87da                	mv	a5,s6
    8000347c:	86e6                	mv	a3,s9
    8000347e:	a029                	j	80003488 <sys_munmap+0x1ba>
  for(int i = 0; i < NVMA; i++){
    80003480:	02878793          	addi	a5,a5,40
    80003484:	01378b63          	beq	a5,s3,8000349a <sys_munmap+0x1cc>
    if(!p->vmas[i].used) continue;
    80003488:	4398                	lw	a4,0(a5)
    8000348a:	db7d                	beqz	a4,80003480 <sys_munmap+0x1b2>
    uint64 s = p->vmas[i].start;
    8000348c:	6798                	ld	a4,8(a5)
    if(s >= x && s < best) best = s;
    8000348e:	ff4769e3          	bltu	a4,s4,80003480 <sys_munmap+0x1b2>
    80003492:	fed777e3          	bgeu	a4,a3,80003480 <sys_munmap+0x1b2>
    80003496:	86ba                	mv	a3,a4
    80003498:	b7e5                	j	80003480 <sys_munmap+0x1b2>
      if(ns == (uint64)-1 || ns >= b) break;
    8000349a:	0326e163          	bltu	a3,s2,800034bc <sys_munmap+0x1ee>
    }

    cur = seg_end;
  }
  //shm_dump(1);
  return 0;
    8000349e:	4501                	li	a0,0
}
    800034a0:	70a6                	ld	ra,104(sp)
    800034a2:	7406                	ld	s0,96(sp)
    800034a4:	64e6                	ld	s1,88(sp)
    800034a6:	6946                	ld	s2,80(sp)
    800034a8:	69a6                	ld	s3,72(sp)
    800034aa:	6a06                	ld	s4,64(sp)
    800034ac:	7ae2                	ld	s5,56(sp)
    800034ae:	7b42                	ld	s6,48(sp)
    800034b0:	7ba2                	ld	s7,40(sp)
    800034b2:	7c02                	ld	s8,32(sp)
    800034b4:	6ce2                	ld	s9,24(sp)
    800034b6:	6d42                	ld	s10,16(sp)
    800034b8:	6165                	addi	sp,sp,112
    800034ba:	8082                	ret
    800034bc:	8a36                	mv	s4,a3
    800034be:	a20d                	j	800035e0 <sys_munmap+0x312>
      uvmunmap(p->pagetable, seg_start, (seg_end - seg_start)/PGSIZE, 1);
    800034c0:	41aa0633          	sub	a2,s4,s10
    800034c4:	4685                	li	a3,1
    800034c6:	8231                	srli	a2,a2,0xc
    800034c8:	85ea                	mv	a1,s10
    800034ca:	050ab503          	ld	a0,80(s5)
    800034ce:	dcffd0ef          	jal	ra,8000129c <uvmunmap>
    800034d2:	b7bd                	j	80003440 <sys_munmap+0x172>
  if(v->used == 0) return;
    800034d4:	00249793          	slli	a5,s1,0x2
    800034d8:	97a6                	add	a5,a5,s1
    800034da:	078e                	slli	a5,a5,0x3
    800034dc:	97d6                	add	a5,a5,s5
    800034de:	1687a783          	lw	a5,360(a5)
    800034e2:	0e078d63          	beqz	a5,800035dc <sys_munmap+0x30e>
  if(v->is_shm){
    800034e6:	00249793          	slli	a5,s1,0x2
    800034ea:	97a6                	add	a5,a5,s1
    800034ec:	078e                	slli	a5,a5,0x3
    800034ee:	97d6                	add	a5,a5,s5
    800034f0:	1887a783          	lw	a5,392(a5)
    800034f4:	c785                	beqz	a5,8000351c <sys_munmap+0x24e>
    int key = v->shm_key;
    800034f6:	00249793          	slli	a5,s1,0x2
    800034fa:	00978733          	add	a4,a5,s1
    800034fe:	070e                	slli	a4,a4,0x3
    80003500:	9756                	add	a4,a4,s5
    80003502:	18c72d03          	lw	s10,396(a4)
    struct vma *v = &p->vmas[vi];
    80003506:	00978633          	add	a2,a5,s1
    8000350a:	060e                	slli	a2,a2,0x3
    8000350c:	16860613          	addi	a2,a2,360 # fffffffffffff168 <end+0xffffffff7fdaafb8>
    if(!proc_has_shm_key(p, key, v)){
    80003510:	9656                	add	a2,a2,s5
    80003512:	85ea                	mv	a1,s10
    80003514:	8556                	mv	a0,s5
    80003516:	92fff0ef          	jal	ra,80002e44 <proc_has_shm_key>
    8000351a:	c915                	beqz	a0,8000354e <sys_munmap+0x280>
  v->used = 0;
    8000351c:	00249713          	slli	a4,s1,0x2
    80003520:	009707b3          	add	a5,a4,s1
    80003524:	078e                	slli	a5,a5,0x3
    80003526:	97d6                	add	a5,a5,s5
    80003528:	1607a423          	sw	zero,360(a5)
  v->start = v->end = 0;
    8000352c:	1607bc23          	sd	zero,376(a5)
    80003530:	1607b823          	sd	zero,368(a5)
  v->prot = v->flags = 0;
    80003534:	1807a223          	sw	zero,388(a5)
    80003538:	1807a023          	sw	zero,384(a5)
  v->is_shm = 0;
    8000353c:	1807a423          	sw	zero,392(a5)
  v->shm_key = -1;
    80003540:	009707b3          	add	a5,a4,s1
    80003544:	078e                	slli	a5,a5,0x3
    80003546:	97d6                	add	a5,a5,s5
    80003548:	1997a623          	sw	s9,396(a5)
    8000354c:	a841                	j	800035dc <sys_munmap+0x30e>
      shm_put(key);
    8000354e:	856a                	mv	a0,s10
    80003550:	100030ef          	jal	ra,80006650 <shm_put>
    80003554:	b7e1                	j	8000351c <sys_munmap+0x24e>
    } else if(seg_start > v->start && seg_end >= v->end){
    80003556:	00249793          	slli	a5,s1,0x2
    8000355a:	97a6                	add	a5,a5,s1
    8000355c:	078e                	slli	a5,a5,0x3
    8000355e:	97d6                	add	a5,a5,s5
    80003560:	1787b783          	ld	a5,376(a5)
    80003564:	00fa6a63          	bltu	s4,a5,80003578 <sys_munmap+0x2aa>
      v->end = seg_start;
    80003568:	00249793          	slli	a5,s1,0x2
    8000356c:	97a6                	add	a5,a5,s1
    8000356e:	078e                	slli	a5,a5,0x3
    80003570:	97d6                	add	a5,a5,s5
    80003572:	17a7bc23          	sd	s10,376(a5)
    80003576:	a09d                	j	800035dc <sys_munmap+0x30e>
    80003578:	875a                	mv	a4,s6
    8000357a:	87e2                	mv	a5,s8
    if(!p->vmas[i].used)
    8000357c:	4314                	lw	a3,0(a4)
    8000357e:	c699                	beqz	a3,8000358c <sys_munmap+0x2be>
  for(int i = 0; i < NVMA; i++){
    80003580:	2785                	addiw	a5,a5,1
    80003582:	02870713          	addi	a4,a4,40
    80003586:	ff779be3          	bne	a5,s7,8000357c <sys_munmap+0x2ae>
  return -1;
    8000358a:	87e6                	mv	a5,s9
      p->vmas[ni] = *v;
    8000358c:	00279593          	slli	a1,a5,0x2
    80003590:	00f586b3          	add	a3,a1,a5
    80003594:	068e                	slli	a3,a3,0x3
    80003596:	96d6                	add	a3,a3,s5
    80003598:	00249613          	slli	a2,s1,0x2
    8000359c:	00960733          	add	a4,a2,s1
    800035a0:	070e                	slli	a4,a4,0x3
    800035a2:	9756                	add	a4,a4,s5
    800035a4:	16873303          	ld	t1,360(a4)
    800035a8:	17873883          	ld	a7,376(a4)
    800035ac:	18073803          	ld	a6,384(a4)
    800035b0:	18873503          	ld	a0,392(a4)
    800035b4:	1666b423          	sd	t1,360(a3) # 1168 <_entry-0x7fffee98>
    800035b8:	1716bc23          	sd	a7,376(a3)
    800035bc:	1906b023          	sd	a6,384(a3)
    800035c0:	18a6b423          	sd	a0,392(a3)
      p->vmas[ni].start = seg_end;
    800035c4:	1746b823          	sd	s4,368(a3)
      p->vmas[ni].end   = v->end;
    800035c8:	17873703          	ld	a4,376(a4)
    800035cc:	16e6bc23          	sd	a4,376(a3)
      v->end = seg_start;
    800035d0:	009607b3          	add	a5,a2,s1
    800035d4:	078e                	slli	a5,a5,0x3
    800035d6:	97d6                	add	a5,a5,s5
    800035d8:	17a7bc23          	sd	s10,376(a5)
  while(cur < b){
    800035dc:	012a7763          	bgeu	s4,s2,800035ea <sys_munmap+0x31c>
  int need_splits = 0;
    800035e0:	87da                	mv	a5,s6
  for(int i = 0; i < NVMA; i++){
    800035e2:	84e2                	mv	s1,s8
    800035e4:	bd31                	j	80003400 <sys_munmap+0x132>
  if(len <= 0) return (uint64)-1;
    800035e6:	557d                	li	a0,-1
    800035e8:	bd65                	j	800034a0 <sys_munmap+0x1d2>
  return 0;
    800035ea:	4501                	li	a0,0
    800035ec:	bd55                	j	800034a0 <sys_munmap+0x1d2>

00000000800035ee <sys_shmctl>:

uint64
sys_shmctl(void)
{
    800035ee:	1101                	addi	sp,sp,-32
    800035f0:	ec06                	sd	ra,24(sp)
    800035f2:	e822                	sd	s0,16(sp)
    800035f4:	1000                	addi	s0,sp,32
  int key, cmd;
  argint(0, &key);
    800035f6:	fec40593          	addi	a1,s0,-20
    800035fa:	4501                	li	a0,0
    800035fc:	f7cff0ef          	jal	ra,80002d78 <argint>
  argint(1, &cmd);
    80003600:	fe840593          	addi	a1,s0,-24
    80003604:	4505                	li	a0,1
    80003606:	f72ff0ef          	jal	ra,80002d78 <argint>
  return shm_ctl(key, cmd);
    8000360a:	fe842583          	lw	a1,-24(s0)
    8000360e:	fec42503          	lw	a0,-20(s0)
    80003612:	22c030ef          	jal	ra,8000683e <shm_ctl>
}
    80003616:	60e2                	ld	ra,24(sp)
    80003618:	6442                	ld	s0,16(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret

000000008000361e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000361e:	7139                	addi	sp,sp,-64
    80003620:	fc06                	sd	ra,56(sp)
    80003622:	f822                	sd	s0,48(sp)
    80003624:	f426                	sd	s1,40(sp)
    80003626:	f04a                	sd	s2,32(sp)
    80003628:	ec4e                	sd	s3,24(sp)
    8000362a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000362c:	fcc40593          	addi	a1,s0,-52
    80003630:	4501                	li	a0,0
    80003632:	f46ff0ef          	jal	ra,80002d78 <argint>
  if(n < 0)
    80003636:	fcc42783          	lw	a5,-52(s0)
    return -1;
    8000363a:	557d                	li	a0,-1
  if(n < 0)
    8000363c:	0407ce63          	bltz	a5,80003698 <sys_sleep+0x7a>

  acquire(&tickslock);
    80003640:	0023d517          	auipc	a0,0x23d
    80003644:	1e050513          	addi	a0,a0,480 # 80240820 <tickslock>
    80003648:	e58fd0ef          	jal	ra,80000ca0 <acquire>
  ticks0 = ticks;
    8000364c:	00005917          	auipc	s2,0x5
    80003650:	28c92903          	lw	s2,652(s2) # 800088d8 <ticks>
  while(ticks - ticks0 < n){
    80003654:	fcc42783          	lw	a5,-52(s0)
    80003658:	cb8d                	beqz	a5,8000368a <sys_sleep+0x6c>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);  
    8000365a:	0023d997          	auipc	s3,0x23d
    8000365e:	1c698993          	addi	s3,s3,454 # 80240820 <tickslock>
    80003662:	00005497          	auipc	s1,0x5
    80003666:	27648493          	addi	s1,s1,630 # 800088d8 <ticks>
    if(killed(myproc())){
    8000366a:	ce6fe0ef          	jal	ra,80001b50 <myproc>
    8000366e:	80aff0ef          	jal	ra,80002678 <killed>
    80003672:	e915                	bnez	a0,800036a6 <sys_sleep+0x88>
    sleep(&ticks, &tickslock);  
    80003674:	85ce                	mv	a1,s3
    80003676:	8526                	mv	a0,s1
    80003678:	dc9fe0ef          	jal	ra,80002440 <sleep>
  while(ticks - ticks0 < n){
    8000367c:	409c                	lw	a5,0(s1)
    8000367e:	412787bb          	subw	a5,a5,s2
    80003682:	fcc42703          	lw	a4,-52(s0)
    80003686:	fee7e2e3          	bltu	a5,a4,8000366a <sys_sleep+0x4c>
  }
  release(&tickslock);
    8000368a:	0023d517          	auipc	a0,0x23d
    8000368e:	19650513          	addi	a0,a0,406 # 80240820 <tickslock>
    80003692:	ea6fd0ef          	jal	ra,80000d38 <release>
  return 0;
    80003696:	4501                	li	a0,0
}
    80003698:	70e2                	ld	ra,56(sp)
    8000369a:	7442                	ld	s0,48(sp)
    8000369c:	74a2                	ld	s1,40(sp)
    8000369e:	7902                	ld	s2,32(sp)
    800036a0:	69e2                	ld	s3,24(sp)
    800036a2:	6121                	addi	sp,sp,64
    800036a4:	8082                	ret
      release(&tickslock);
    800036a6:	0023d517          	auipc	a0,0x23d
    800036aa:	17a50513          	addi	a0,a0,378 # 80240820 <tickslock>
    800036ae:	e8afd0ef          	jal	ra,80000d38 <release>
      return -1;
    800036b2:	557d                	li	a0,-1
    800036b4:	b7d5                	j	80003698 <sys_sleep+0x7a>

00000000800036b6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800036b6:	7179                	addi	sp,sp,-48
    800036b8:	f406                	sd	ra,40(sp)
    800036ba:	f022                	sd	s0,32(sp)
    800036bc:	ec26                	sd	s1,24(sp)
    800036be:	e84a                	sd	s2,16(sp)
    800036c0:	e44e                	sd	s3,8(sp)
    800036c2:	e052                	sd	s4,0(sp)
    800036c4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800036c6:	00005597          	auipc	a1,0x5
    800036ca:	e1a58593          	addi	a1,a1,-486 # 800084e0 <syscalls+0xe8>
    800036ce:	0023d517          	auipc	a0,0x23d
    800036d2:	16a50513          	addi	a0,a0,362 # 80240838 <bcache>
    800036d6:	d4afd0ef          	jal	ra,80000c20 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036da:	00245797          	auipc	a5,0x245
    800036de:	15e78793          	addi	a5,a5,350 # 80248838 <bcache+0x8000>
    800036e2:	00245717          	auipc	a4,0x245
    800036e6:	3be70713          	addi	a4,a4,958 # 80248aa0 <bcache+0x8268>
    800036ea:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036ee:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036f2:	0023d497          	auipc	s1,0x23d
    800036f6:	15e48493          	addi	s1,s1,350 # 80240850 <bcache+0x18>
    b->next = bcache.head.next;
    800036fa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036fc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036fe:	00005a17          	auipc	s4,0x5
    80003702:	deaa0a13          	addi	s4,s4,-534 # 800084e8 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003706:	2b893783          	ld	a5,696(s2)
    8000370a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000370c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003710:	85d2                	mv	a1,s4
    80003712:	01048513          	addi	a0,s1,16
    80003716:	302010ef          	jal	ra,80004a18 <initsleeplock>
    bcache.head.next->prev = b;
    8000371a:	2b893783          	ld	a5,696(s2)
    8000371e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003720:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003724:	45848493          	addi	s1,s1,1112
    80003728:	fd349fe3          	bne	s1,s3,80003706 <binit+0x50>
  }
}
    8000372c:	70a2                	ld	ra,40(sp)
    8000372e:	7402                	ld	s0,32(sp)
    80003730:	64e2                	ld	s1,24(sp)
    80003732:	6942                	ld	s2,16(sp)
    80003734:	69a2                	ld	s3,8(sp)
    80003736:	6a02                	ld	s4,0(sp)
    80003738:	6145                	addi	sp,sp,48
    8000373a:	8082                	ret

000000008000373c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000373c:	7179                	addi	sp,sp,-48
    8000373e:	f406                	sd	ra,40(sp)
    80003740:	f022                	sd	s0,32(sp)
    80003742:	ec26                	sd	s1,24(sp)
    80003744:	e84a                	sd	s2,16(sp)
    80003746:	e44e                	sd	s3,8(sp)
    80003748:	1800                	addi	s0,sp,48
    8000374a:	892a                	mv	s2,a0
    8000374c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000374e:	0023d517          	auipc	a0,0x23d
    80003752:	0ea50513          	addi	a0,a0,234 # 80240838 <bcache>
    80003756:	d4afd0ef          	jal	ra,80000ca0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000375a:	00245497          	auipc	s1,0x245
    8000375e:	3964b483          	ld	s1,918(s1) # 80248af0 <bcache+0x82b8>
    80003762:	00245797          	auipc	a5,0x245
    80003766:	33e78793          	addi	a5,a5,830 # 80248aa0 <bcache+0x8268>
    8000376a:	02f48b63          	beq	s1,a5,800037a0 <bread+0x64>
    8000376e:	873e                	mv	a4,a5
    80003770:	a021                	j	80003778 <bread+0x3c>
    80003772:	68a4                	ld	s1,80(s1)
    80003774:	02e48663          	beq	s1,a4,800037a0 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003778:	449c                	lw	a5,8(s1)
    8000377a:	ff279ce3          	bne	a5,s2,80003772 <bread+0x36>
    8000377e:	44dc                	lw	a5,12(s1)
    80003780:	ff3799e3          	bne	a5,s3,80003772 <bread+0x36>
      b->refcnt++;
    80003784:	40bc                	lw	a5,64(s1)
    80003786:	2785                	addiw	a5,a5,1
    80003788:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000378a:	0023d517          	auipc	a0,0x23d
    8000378e:	0ae50513          	addi	a0,a0,174 # 80240838 <bcache>
    80003792:	da6fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    80003796:	01048513          	addi	a0,s1,16
    8000379a:	2b4010ef          	jal	ra,80004a4e <acquiresleep>
      return b;
    8000379e:	a889                	j	800037f0 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037a0:	00245497          	auipc	s1,0x245
    800037a4:	3484b483          	ld	s1,840(s1) # 80248ae8 <bcache+0x82b0>
    800037a8:	00245797          	auipc	a5,0x245
    800037ac:	2f878793          	addi	a5,a5,760 # 80248aa0 <bcache+0x8268>
    800037b0:	00f48863          	beq	s1,a5,800037c0 <bread+0x84>
    800037b4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037b6:	40bc                	lw	a5,64(s1)
    800037b8:	cb91                	beqz	a5,800037cc <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037ba:	64a4                	ld	s1,72(s1)
    800037bc:	fee49de3          	bne	s1,a4,800037b6 <bread+0x7a>
  panic("bget: no buffers");
    800037c0:	00005517          	auipc	a0,0x5
    800037c4:	d3050513          	addi	a0,a0,-720 # 800084f0 <syscalls+0xf8>
    800037c8:	fc1fc0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    800037cc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800037d0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800037d4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037d8:	4785                	li	a5,1
    800037da:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037dc:	0023d517          	auipc	a0,0x23d
    800037e0:	05c50513          	addi	a0,a0,92 # 80240838 <bcache>
    800037e4:	d54fd0ef          	jal	ra,80000d38 <release>
      acquiresleep(&b->lock);
    800037e8:	01048513          	addi	a0,s1,16
    800037ec:	262010ef          	jal	ra,80004a4e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800037f0:	409c                	lw	a5,0(s1)
    800037f2:	cb89                	beqz	a5,80003804 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037f4:	8526                	mv	a0,s1
    800037f6:	70a2                	ld	ra,40(sp)
    800037f8:	7402                	ld	s0,32(sp)
    800037fa:	64e2                	ld	s1,24(sp)
    800037fc:	6942                	ld	s2,16(sp)
    800037fe:	69a2                	ld	s3,8(sp)
    80003800:	6145                	addi	sp,sp,48
    80003802:	8082                	ret
    virtio_disk_rw(b, 0);
    80003804:	4581                	li	a1,0
    80003806:	8526                	mv	a0,s1
    80003808:	223020ef          	jal	ra,8000622a <virtio_disk_rw>
    b->valid = 1;
    8000380c:	4785                	li	a5,1
    8000380e:	c09c                	sw	a5,0(s1)
  return b;
    80003810:	b7d5                	j	800037f4 <bread+0xb8>

0000000080003812 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003812:	1101                	addi	sp,sp,-32
    80003814:	ec06                	sd	ra,24(sp)
    80003816:	e822                	sd	s0,16(sp)
    80003818:	e426                	sd	s1,8(sp)
    8000381a:	1000                	addi	s0,sp,32
    8000381c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000381e:	0541                	addi	a0,a0,16
    80003820:	2ac010ef          	jal	ra,80004acc <holdingsleep>
    80003824:	c911                	beqz	a0,80003838 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003826:	4585                	li	a1,1
    80003828:	8526                	mv	a0,s1
    8000382a:	201020ef          	jal	ra,8000622a <virtio_disk_rw>
}
    8000382e:	60e2                	ld	ra,24(sp)
    80003830:	6442                	ld	s0,16(sp)
    80003832:	64a2                	ld	s1,8(sp)
    80003834:	6105                	addi	sp,sp,32
    80003836:	8082                	ret
    panic("bwrite");
    80003838:	00005517          	auipc	a0,0x5
    8000383c:	cd050513          	addi	a0,a0,-816 # 80008508 <syscalls+0x110>
    80003840:	f49fc0ef          	jal	ra,80000788 <panic>

0000000080003844 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003844:	1101                	addi	sp,sp,-32
    80003846:	ec06                	sd	ra,24(sp)
    80003848:	e822                	sd	s0,16(sp)
    8000384a:	e426                	sd	s1,8(sp)
    8000384c:	e04a                	sd	s2,0(sp)
    8000384e:	1000                	addi	s0,sp,32
    80003850:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003852:	01050913          	addi	s2,a0,16
    80003856:	854a                	mv	a0,s2
    80003858:	274010ef          	jal	ra,80004acc <holdingsleep>
    8000385c:	c13d                	beqz	a0,800038c2 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    8000385e:	854a                	mv	a0,s2
    80003860:	234010ef          	jal	ra,80004a94 <releasesleep>

  acquire(&bcache.lock);
    80003864:	0023d517          	auipc	a0,0x23d
    80003868:	fd450513          	addi	a0,a0,-44 # 80240838 <bcache>
    8000386c:	c34fd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    80003870:	40bc                	lw	a5,64(s1)
    80003872:	37fd                	addiw	a5,a5,-1
    80003874:	0007871b          	sext.w	a4,a5
    80003878:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000387a:	eb05                	bnez	a4,800038aa <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000387c:	68bc                	ld	a5,80(s1)
    8000387e:	64b8                	ld	a4,72(s1)
    80003880:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003882:	64bc                	ld	a5,72(s1)
    80003884:	68b8                	ld	a4,80(s1)
    80003886:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003888:	00245797          	auipc	a5,0x245
    8000388c:	fb078793          	addi	a5,a5,-80 # 80248838 <bcache+0x8000>
    80003890:	2b87b703          	ld	a4,696(a5)
    80003894:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003896:	00245717          	auipc	a4,0x245
    8000389a:	20a70713          	addi	a4,a4,522 # 80248aa0 <bcache+0x8268>
    8000389e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800038a0:	2b87b703          	ld	a4,696(a5)
    800038a4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800038a6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038aa:	0023d517          	auipc	a0,0x23d
    800038ae:	f8e50513          	addi	a0,a0,-114 # 80240838 <bcache>
    800038b2:	c86fd0ef          	jal	ra,80000d38 <release>
}
    800038b6:	60e2                	ld	ra,24(sp)
    800038b8:	6442                	ld	s0,16(sp)
    800038ba:	64a2                	ld	s1,8(sp)
    800038bc:	6902                	ld	s2,0(sp)
    800038be:	6105                	addi	sp,sp,32
    800038c0:	8082                	ret
    panic("brelse");
    800038c2:	00005517          	auipc	a0,0x5
    800038c6:	c4e50513          	addi	a0,a0,-946 # 80008510 <syscalls+0x118>
    800038ca:	ebffc0ef          	jal	ra,80000788 <panic>

00000000800038ce <bpin>:

void
bpin(struct buf *b) {
    800038ce:	1101                	addi	sp,sp,-32
    800038d0:	ec06                	sd	ra,24(sp)
    800038d2:	e822                	sd	s0,16(sp)
    800038d4:	e426                	sd	s1,8(sp)
    800038d6:	1000                	addi	s0,sp,32
    800038d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038da:	0023d517          	auipc	a0,0x23d
    800038de:	f5e50513          	addi	a0,a0,-162 # 80240838 <bcache>
    800038e2:	bbefd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt++;
    800038e6:	40bc                	lw	a5,64(s1)
    800038e8:	2785                	addiw	a5,a5,1
    800038ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038ec:	0023d517          	auipc	a0,0x23d
    800038f0:	f4c50513          	addi	a0,a0,-180 # 80240838 <bcache>
    800038f4:	c44fd0ef          	jal	ra,80000d38 <release>
}
    800038f8:	60e2                	ld	ra,24(sp)
    800038fa:	6442                	ld	s0,16(sp)
    800038fc:	64a2                	ld	s1,8(sp)
    800038fe:	6105                	addi	sp,sp,32
    80003900:	8082                	ret

0000000080003902 <bunpin>:

void
bunpin(struct buf *b) {
    80003902:	1101                	addi	sp,sp,-32
    80003904:	ec06                	sd	ra,24(sp)
    80003906:	e822                	sd	s0,16(sp)
    80003908:	e426                	sd	s1,8(sp)
    8000390a:	1000                	addi	s0,sp,32
    8000390c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000390e:	0023d517          	auipc	a0,0x23d
    80003912:	f2a50513          	addi	a0,a0,-214 # 80240838 <bcache>
    80003916:	b8afd0ef          	jal	ra,80000ca0 <acquire>
  b->refcnt--;
    8000391a:	40bc                	lw	a5,64(s1)
    8000391c:	37fd                	addiw	a5,a5,-1
    8000391e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003920:	0023d517          	auipc	a0,0x23d
    80003924:	f1850513          	addi	a0,a0,-232 # 80240838 <bcache>
    80003928:	c10fd0ef          	jal	ra,80000d38 <release>
}
    8000392c:	60e2                	ld	ra,24(sp)
    8000392e:	6442                	ld	s0,16(sp)
    80003930:	64a2                	ld	s1,8(sp)
    80003932:	6105                	addi	sp,sp,32
    80003934:	8082                	ret

0000000080003936 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003936:	1101                	addi	sp,sp,-32
    80003938:	ec06                	sd	ra,24(sp)
    8000393a:	e822                	sd	s0,16(sp)
    8000393c:	e426                	sd	s1,8(sp)
    8000393e:	e04a                	sd	s2,0(sp)
    80003940:	1000                	addi	s0,sp,32
    80003942:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003944:	00d5d59b          	srliw	a1,a1,0xd
    80003948:	00245797          	auipc	a5,0x245
    8000394c:	5cc7a783          	lw	a5,1484(a5) # 80248f14 <sb+0x1c>
    80003950:	9dbd                	addw	a1,a1,a5
    80003952:	debff0ef          	jal	ra,8000373c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003956:	0074f713          	andi	a4,s1,7
    8000395a:	4785                	li	a5,1
    8000395c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003960:	14ce                	slli	s1,s1,0x33
    80003962:	90d9                	srli	s1,s1,0x36
    80003964:	00950733          	add	a4,a0,s1
    80003968:	05874703          	lbu	a4,88(a4)
    8000396c:	00e7f6b3          	and	a3,a5,a4
    80003970:	c29d                	beqz	a3,80003996 <bfree+0x60>
    80003972:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003974:	94aa                	add	s1,s1,a0
    80003976:	fff7c793          	not	a5,a5
    8000397a:	8f7d                	and	a4,a4,a5
    8000397c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003980:	7d7000ef          	jal	ra,80004956 <log_write>
  brelse(bp);
    80003984:	854a                	mv	a0,s2
    80003986:	ebfff0ef          	jal	ra,80003844 <brelse>
}
    8000398a:	60e2                	ld	ra,24(sp)
    8000398c:	6442                	ld	s0,16(sp)
    8000398e:	64a2                	ld	s1,8(sp)
    80003990:	6902                	ld	s2,0(sp)
    80003992:	6105                	addi	sp,sp,32
    80003994:	8082                	ret
    panic("freeing free block");
    80003996:	00005517          	auipc	a0,0x5
    8000399a:	b8250513          	addi	a0,a0,-1150 # 80008518 <syscalls+0x120>
    8000399e:	debfc0ef          	jal	ra,80000788 <panic>

00000000800039a2 <balloc>:
{
    800039a2:	711d                	addi	sp,sp,-96
    800039a4:	ec86                	sd	ra,88(sp)
    800039a6:	e8a2                	sd	s0,80(sp)
    800039a8:	e4a6                	sd	s1,72(sp)
    800039aa:	e0ca                	sd	s2,64(sp)
    800039ac:	fc4e                	sd	s3,56(sp)
    800039ae:	f852                	sd	s4,48(sp)
    800039b0:	f456                	sd	s5,40(sp)
    800039b2:	f05a                	sd	s6,32(sp)
    800039b4:	ec5e                	sd	s7,24(sp)
    800039b6:	e862                	sd	s8,16(sp)
    800039b8:	e466                	sd	s9,8(sp)
    800039ba:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800039bc:	00245797          	auipc	a5,0x245
    800039c0:	5407a783          	lw	a5,1344(a5) # 80248efc <sb+0x4>
    800039c4:	cff1                	beqz	a5,80003aa0 <balloc+0xfe>
    800039c6:	8baa                	mv	s7,a0
    800039c8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800039ca:	00245b17          	auipc	s6,0x245
    800039ce:	52eb0b13          	addi	s6,s6,1326 # 80248ef8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039d2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800039d4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039d6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800039d8:	6c89                	lui	s9,0x2
    800039da:	a0b5                	j	80003a46 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    800039dc:	97ca                	add	a5,a5,s2
    800039de:	8e55                	or	a2,a2,a3
    800039e0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800039e4:	854a                	mv	a0,s2
    800039e6:	771000ef          	jal	ra,80004956 <log_write>
        brelse(bp);
    800039ea:	854a                	mv	a0,s2
    800039ec:	e59ff0ef          	jal	ra,80003844 <brelse>
  bp = bread(dev, bno);
    800039f0:	85a6                	mv	a1,s1
    800039f2:	855e                	mv	a0,s7
    800039f4:	d49ff0ef          	jal	ra,8000373c <bread>
    800039f8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039fa:	40000613          	li	a2,1024
    800039fe:	4581                	li	a1,0
    80003a00:	05850513          	addi	a0,a0,88
    80003a04:	b70fd0ef          	jal	ra,80000d74 <memset>
  log_write(bp);
    80003a08:	854a                	mv	a0,s2
    80003a0a:	74d000ef          	jal	ra,80004956 <log_write>
  brelse(bp);
    80003a0e:	854a                	mv	a0,s2
    80003a10:	e35ff0ef          	jal	ra,80003844 <brelse>
}
    80003a14:	8526                	mv	a0,s1
    80003a16:	60e6                	ld	ra,88(sp)
    80003a18:	6446                	ld	s0,80(sp)
    80003a1a:	64a6                	ld	s1,72(sp)
    80003a1c:	6906                	ld	s2,64(sp)
    80003a1e:	79e2                	ld	s3,56(sp)
    80003a20:	7a42                	ld	s4,48(sp)
    80003a22:	7aa2                	ld	s5,40(sp)
    80003a24:	7b02                	ld	s6,32(sp)
    80003a26:	6be2                	ld	s7,24(sp)
    80003a28:	6c42                	ld	s8,16(sp)
    80003a2a:	6ca2                	ld	s9,8(sp)
    80003a2c:	6125                	addi	sp,sp,96
    80003a2e:	8082                	ret
    brelse(bp);
    80003a30:	854a                	mv	a0,s2
    80003a32:	e13ff0ef          	jal	ra,80003844 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a36:	015c87bb          	addw	a5,s9,s5
    80003a3a:	00078a9b          	sext.w	s5,a5
    80003a3e:	004b2703          	lw	a4,4(s6)
    80003a42:	04eaff63          	bgeu	s5,a4,80003aa0 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80003a46:	41fad79b          	sraiw	a5,s5,0x1f
    80003a4a:	0137d79b          	srliw	a5,a5,0x13
    80003a4e:	015787bb          	addw	a5,a5,s5
    80003a52:	40d7d79b          	sraiw	a5,a5,0xd
    80003a56:	01cb2583          	lw	a1,28(s6)
    80003a5a:	9dbd                	addw	a1,a1,a5
    80003a5c:	855e                	mv	a0,s7
    80003a5e:	cdfff0ef          	jal	ra,8000373c <bread>
    80003a62:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a64:	004b2503          	lw	a0,4(s6)
    80003a68:	000a849b          	sext.w	s1,s5
    80003a6c:	8762                	mv	a4,s8
    80003a6e:	fca4f1e3          	bgeu	s1,a0,80003a30 <balloc+0x8e>
      m = 1 << (bi % 8);
    80003a72:	00777693          	andi	a3,a4,7
    80003a76:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a7a:	41f7579b          	sraiw	a5,a4,0x1f
    80003a7e:	01d7d79b          	srliw	a5,a5,0x1d
    80003a82:	9fb9                	addw	a5,a5,a4
    80003a84:	4037d79b          	sraiw	a5,a5,0x3
    80003a88:	00f90633          	add	a2,s2,a5
    80003a8c:	05864603          	lbu	a2,88(a2)
    80003a90:	00c6f5b3          	and	a1,a3,a2
    80003a94:	d5a1                	beqz	a1,800039dc <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a96:	2705                	addiw	a4,a4,1
    80003a98:	2485                	addiw	s1,s1,1
    80003a9a:	fd471ae3          	bne	a4,s4,80003a6e <balloc+0xcc>
    80003a9e:	bf49                	j	80003a30 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003aa0:	00005517          	auipc	a0,0x5
    80003aa4:	a9050513          	addi	a0,a0,-1392 # 80008530 <syscalls+0x138>
    80003aa8:	a1bfc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003aac:	4481                	li	s1,0
    80003aae:	b79d                	j	80003a14 <balloc+0x72>

0000000080003ab0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ab0:	7179                	addi	sp,sp,-48
    80003ab2:	f406                	sd	ra,40(sp)
    80003ab4:	f022                	sd	s0,32(sp)
    80003ab6:	ec26                	sd	s1,24(sp)
    80003ab8:	e84a                	sd	s2,16(sp)
    80003aba:	e44e                	sd	s3,8(sp)
    80003abc:	e052                	sd	s4,0(sp)
    80003abe:	1800                	addi	s0,sp,48
    80003ac0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003ac2:	47ad                	li	a5,11
    80003ac4:	02b7e663          	bltu	a5,a1,80003af0 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80003ac8:	02059793          	slli	a5,a1,0x20
    80003acc:	01e7d593          	srli	a1,a5,0x1e
    80003ad0:	00b504b3          	add	s1,a0,a1
    80003ad4:	0504a903          	lw	s2,80(s1)
    80003ad8:	06091663          	bnez	s2,80003b44 <bmap+0x94>
      addr = balloc(ip->dev);
    80003adc:	4108                	lw	a0,0(a0)
    80003ade:	ec5ff0ef          	jal	ra,800039a2 <balloc>
    80003ae2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ae6:	04090f63          	beqz	s2,80003b44 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80003aea:	0524a823          	sw	s2,80(s1)
    80003aee:	a899                	j	80003b44 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003af0:	ff45849b          	addiw	s1,a1,-12
    80003af4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003af8:	0ff00793          	li	a5,255
    80003afc:	06e7eb63          	bltu	a5,a4,80003b72 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b00:	08052903          	lw	s2,128(a0)
    80003b04:	00091b63          	bnez	s2,80003b1a <bmap+0x6a>
      addr = balloc(ip->dev);
    80003b08:	4108                	lw	a0,0(a0)
    80003b0a:	e99ff0ef          	jal	ra,800039a2 <balloc>
    80003b0e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b12:	02090963          	beqz	s2,80003b44 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b16:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b1a:	85ca                	mv	a1,s2
    80003b1c:	0009a503          	lw	a0,0(s3)
    80003b20:	c1dff0ef          	jal	ra,8000373c <bread>
    80003b24:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b26:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b2a:	02049713          	slli	a4,s1,0x20
    80003b2e:	01e75593          	srli	a1,a4,0x1e
    80003b32:	00b784b3          	add	s1,a5,a1
    80003b36:	0004a903          	lw	s2,0(s1)
    80003b3a:	00090e63          	beqz	s2,80003b56 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b3e:	8552                	mv	a0,s4
    80003b40:	d05ff0ef          	jal	ra,80003844 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b44:	854a                	mv	a0,s2
    80003b46:	70a2                	ld	ra,40(sp)
    80003b48:	7402                	ld	s0,32(sp)
    80003b4a:	64e2                	ld	s1,24(sp)
    80003b4c:	6942                	ld	s2,16(sp)
    80003b4e:	69a2                	ld	s3,8(sp)
    80003b50:	6a02                	ld	s4,0(sp)
    80003b52:	6145                	addi	sp,sp,48
    80003b54:	8082                	ret
      addr = balloc(ip->dev);
    80003b56:	0009a503          	lw	a0,0(s3)
    80003b5a:	e49ff0ef          	jal	ra,800039a2 <balloc>
    80003b5e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003b62:	fc090ee3          	beqz	s2,80003b3e <bmap+0x8e>
        a[bn] = addr;
    80003b66:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b6a:	8552                	mv	a0,s4
    80003b6c:	5eb000ef          	jal	ra,80004956 <log_write>
    80003b70:	b7f9                	j	80003b3e <bmap+0x8e>
  panic("bmap: out of range");
    80003b72:	00005517          	auipc	a0,0x5
    80003b76:	9d650513          	addi	a0,a0,-1578 # 80008548 <syscalls+0x150>
    80003b7a:	c0ffc0ef          	jal	ra,80000788 <panic>

0000000080003b7e <iget>:
{
    80003b7e:	7179                	addi	sp,sp,-48
    80003b80:	f406                	sd	ra,40(sp)
    80003b82:	f022                	sd	s0,32(sp)
    80003b84:	ec26                	sd	s1,24(sp)
    80003b86:	e84a                	sd	s2,16(sp)
    80003b88:	e44e                	sd	s3,8(sp)
    80003b8a:	e052                	sd	s4,0(sp)
    80003b8c:	1800                	addi	s0,sp,48
    80003b8e:	89aa                	mv	s3,a0
    80003b90:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b92:	00245517          	auipc	a0,0x245
    80003b96:	38650513          	addi	a0,a0,902 # 80248f18 <itable>
    80003b9a:	906fd0ef          	jal	ra,80000ca0 <acquire>
  empty = 0;
    80003b9e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ba0:	00245497          	auipc	s1,0x245
    80003ba4:	39048493          	addi	s1,s1,912 # 80248f30 <itable+0x18>
    80003ba8:	00247697          	auipc	a3,0x247
    80003bac:	e1868693          	addi	a3,a3,-488 # 8024a9c0 <log>
    80003bb0:	a039                	j	80003bbe <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bb2:	02090963          	beqz	s2,80003be4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003bb6:	08848493          	addi	s1,s1,136
    80003bba:	02d48863          	beq	s1,a3,80003bea <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003bbe:	449c                	lw	a5,8(s1)
    80003bc0:	fef059e3          	blez	a5,80003bb2 <iget+0x34>
    80003bc4:	4098                	lw	a4,0(s1)
    80003bc6:	ff3716e3          	bne	a4,s3,80003bb2 <iget+0x34>
    80003bca:	40d8                	lw	a4,4(s1)
    80003bcc:	ff4713e3          	bne	a4,s4,80003bb2 <iget+0x34>
      ip->ref++;
    80003bd0:	2785                	addiw	a5,a5,1
    80003bd2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003bd4:	00245517          	auipc	a0,0x245
    80003bd8:	34450513          	addi	a0,a0,836 # 80248f18 <itable>
    80003bdc:	95cfd0ef          	jal	ra,80000d38 <release>
      return ip;
    80003be0:	8926                	mv	s2,s1
    80003be2:	a02d                	j	80003c0c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003be4:	fbe9                	bnez	a5,80003bb6 <iget+0x38>
    80003be6:	8926                	mv	s2,s1
    80003be8:	b7f9                	j	80003bb6 <iget+0x38>
  if(empty == 0)
    80003bea:	02090a63          	beqz	s2,80003c1e <iget+0xa0>
  ip->dev = dev;
    80003bee:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003bf2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003bf6:	4785                	li	a5,1
    80003bf8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003bfc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c00:	00245517          	auipc	a0,0x245
    80003c04:	31850513          	addi	a0,a0,792 # 80248f18 <itable>
    80003c08:	930fd0ef          	jal	ra,80000d38 <release>
}
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	70a2                	ld	ra,40(sp)
    80003c10:	7402                	ld	s0,32(sp)
    80003c12:	64e2                	ld	s1,24(sp)
    80003c14:	6942                	ld	s2,16(sp)
    80003c16:	69a2                	ld	s3,8(sp)
    80003c18:	6a02                	ld	s4,0(sp)
    80003c1a:	6145                	addi	sp,sp,48
    80003c1c:	8082                	ret
    panic("iget: no inodes");
    80003c1e:	00005517          	auipc	a0,0x5
    80003c22:	94250513          	addi	a0,a0,-1726 # 80008560 <syscalls+0x168>
    80003c26:	b63fc0ef          	jal	ra,80000788 <panic>

0000000080003c2a <iinit>:
{
    80003c2a:	7179                	addi	sp,sp,-48
    80003c2c:	f406                	sd	ra,40(sp)
    80003c2e:	f022                	sd	s0,32(sp)
    80003c30:	ec26                	sd	s1,24(sp)
    80003c32:	e84a                	sd	s2,16(sp)
    80003c34:	e44e                	sd	s3,8(sp)
    80003c36:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003c38:	00005597          	auipc	a1,0x5
    80003c3c:	93858593          	addi	a1,a1,-1736 # 80008570 <syscalls+0x178>
    80003c40:	00245517          	auipc	a0,0x245
    80003c44:	2d850513          	addi	a0,a0,728 # 80248f18 <itable>
    80003c48:	fd9fc0ef          	jal	ra,80000c20 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c4c:	00245497          	auipc	s1,0x245
    80003c50:	2f448493          	addi	s1,s1,756 # 80248f40 <itable+0x28>
    80003c54:	00247997          	auipc	s3,0x247
    80003c58:	d7c98993          	addi	s3,s3,-644 # 8024a9d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c5c:	00005917          	auipc	s2,0x5
    80003c60:	91c90913          	addi	s2,s2,-1764 # 80008578 <syscalls+0x180>
    80003c64:	85ca                	mv	a1,s2
    80003c66:	8526                	mv	a0,s1
    80003c68:	5b1000ef          	jal	ra,80004a18 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c6c:	08848493          	addi	s1,s1,136
    80003c70:	ff349ae3          	bne	s1,s3,80003c64 <iinit+0x3a>
}
    80003c74:	70a2                	ld	ra,40(sp)
    80003c76:	7402                	ld	s0,32(sp)
    80003c78:	64e2                	ld	s1,24(sp)
    80003c7a:	6942                	ld	s2,16(sp)
    80003c7c:	69a2                	ld	s3,8(sp)
    80003c7e:	6145                	addi	sp,sp,48
    80003c80:	8082                	ret

0000000080003c82 <ialloc>:
{
    80003c82:	715d                	addi	sp,sp,-80
    80003c84:	e486                	sd	ra,72(sp)
    80003c86:	e0a2                	sd	s0,64(sp)
    80003c88:	fc26                	sd	s1,56(sp)
    80003c8a:	f84a                	sd	s2,48(sp)
    80003c8c:	f44e                	sd	s3,40(sp)
    80003c8e:	f052                	sd	s4,32(sp)
    80003c90:	ec56                	sd	s5,24(sp)
    80003c92:	e85a                	sd	s6,16(sp)
    80003c94:	e45e                	sd	s7,8(sp)
    80003c96:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c98:	00245717          	auipc	a4,0x245
    80003c9c:	26c72703          	lw	a4,620(a4) # 80248f04 <sb+0xc>
    80003ca0:	4785                	li	a5,1
    80003ca2:	04e7f663          	bgeu	a5,a4,80003cee <ialloc+0x6c>
    80003ca6:	8aaa                	mv	s5,a0
    80003ca8:	8bae                	mv	s7,a1
    80003caa:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003cac:	00245a17          	auipc	s4,0x245
    80003cb0:	24ca0a13          	addi	s4,s4,588 # 80248ef8 <sb>
    80003cb4:	00048b1b          	sext.w	s6,s1
    80003cb8:	0044d593          	srli	a1,s1,0x4
    80003cbc:	018a2783          	lw	a5,24(s4)
    80003cc0:	9dbd                	addw	a1,a1,a5
    80003cc2:	8556                	mv	a0,s5
    80003cc4:	a79ff0ef          	jal	ra,8000373c <bread>
    80003cc8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003cca:	05850993          	addi	s3,a0,88
    80003cce:	00f4f793          	andi	a5,s1,15
    80003cd2:	079a                	slli	a5,a5,0x6
    80003cd4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003cd6:	00099783          	lh	a5,0(s3)
    80003cda:	cf85                	beqz	a5,80003d12 <ialloc+0x90>
    brelse(bp);
    80003cdc:	b69ff0ef          	jal	ra,80003844 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ce0:	0485                	addi	s1,s1,1
    80003ce2:	00ca2703          	lw	a4,12(s4)
    80003ce6:	0004879b          	sext.w	a5,s1
    80003cea:	fce7e5e3          	bltu	a5,a4,80003cb4 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003cee:	00005517          	auipc	a0,0x5
    80003cf2:	89250513          	addi	a0,a0,-1902 # 80008580 <syscalls+0x188>
    80003cf6:	fccfc0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003cfa:	4501                	li	a0,0
}
    80003cfc:	60a6                	ld	ra,72(sp)
    80003cfe:	6406                	ld	s0,64(sp)
    80003d00:	74e2                	ld	s1,56(sp)
    80003d02:	7942                	ld	s2,48(sp)
    80003d04:	79a2                	ld	s3,40(sp)
    80003d06:	7a02                	ld	s4,32(sp)
    80003d08:	6ae2                	ld	s5,24(sp)
    80003d0a:	6b42                	ld	s6,16(sp)
    80003d0c:	6ba2                	ld	s7,8(sp)
    80003d0e:	6161                	addi	sp,sp,80
    80003d10:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003d12:	04000613          	li	a2,64
    80003d16:	4581                	li	a1,0
    80003d18:	854e                	mv	a0,s3
    80003d1a:	85afd0ef          	jal	ra,80000d74 <memset>
      dip->type = type;
    80003d1e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003d22:	854a                	mv	a0,s2
    80003d24:	433000ef          	jal	ra,80004956 <log_write>
      brelse(bp);
    80003d28:	854a                	mv	a0,s2
    80003d2a:	b1bff0ef          	jal	ra,80003844 <brelse>
      return iget(dev, inum);
    80003d2e:	85da                	mv	a1,s6
    80003d30:	8556                	mv	a0,s5
    80003d32:	e4dff0ef          	jal	ra,80003b7e <iget>
    80003d36:	b7d9                	j	80003cfc <ialloc+0x7a>

0000000080003d38 <iupdate>:
{
    80003d38:	1101                	addi	sp,sp,-32
    80003d3a:	ec06                	sd	ra,24(sp)
    80003d3c:	e822                	sd	s0,16(sp)
    80003d3e:	e426                	sd	s1,8(sp)
    80003d40:	e04a                	sd	s2,0(sp)
    80003d42:	1000                	addi	s0,sp,32
    80003d44:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d46:	415c                	lw	a5,4(a0)
    80003d48:	0047d79b          	srliw	a5,a5,0x4
    80003d4c:	00245597          	auipc	a1,0x245
    80003d50:	1c45a583          	lw	a1,452(a1) # 80248f10 <sb+0x18>
    80003d54:	9dbd                	addw	a1,a1,a5
    80003d56:	4108                	lw	a0,0(a0)
    80003d58:	9e5ff0ef          	jal	ra,8000373c <bread>
    80003d5c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d5e:	05850793          	addi	a5,a0,88
    80003d62:	40d8                	lw	a4,4(s1)
    80003d64:	8b3d                	andi	a4,a4,15
    80003d66:	071a                	slli	a4,a4,0x6
    80003d68:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d6a:	04449703          	lh	a4,68(s1)
    80003d6e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d72:	04649703          	lh	a4,70(s1)
    80003d76:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003d7a:	04849703          	lh	a4,72(s1)
    80003d7e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003d82:	04a49703          	lh	a4,74(s1)
    80003d86:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003d8a:	44f8                	lw	a4,76(s1)
    80003d8c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d8e:	03400613          	li	a2,52
    80003d92:	05048593          	addi	a1,s1,80
    80003d96:	00c78513          	addi	a0,a5,12
    80003d9a:	836fd0ef          	jal	ra,80000dd0 <memmove>
  log_write(bp);
    80003d9e:	854a                	mv	a0,s2
    80003da0:	3b7000ef          	jal	ra,80004956 <log_write>
  brelse(bp);
    80003da4:	854a                	mv	a0,s2
    80003da6:	a9fff0ef          	jal	ra,80003844 <brelse>
}
    80003daa:	60e2                	ld	ra,24(sp)
    80003dac:	6442                	ld	s0,16(sp)
    80003dae:	64a2                	ld	s1,8(sp)
    80003db0:	6902                	ld	s2,0(sp)
    80003db2:	6105                	addi	sp,sp,32
    80003db4:	8082                	ret

0000000080003db6 <idup>:
{
    80003db6:	1101                	addi	sp,sp,-32
    80003db8:	ec06                	sd	ra,24(sp)
    80003dba:	e822                	sd	s0,16(sp)
    80003dbc:	e426                	sd	s1,8(sp)
    80003dbe:	1000                	addi	s0,sp,32
    80003dc0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dc2:	00245517          	auipc	a0,0x245
    80003dc6:	15650513          	addi	a0,a0,342 # 80248f18 <itable>
    80003dca:	ed7fc0ef          	jal	ra,80000ca0 <acquire>
  ip->ref++;
    80003dce:	449c                	lw	a5,8(s1)
    80003dd0:	2785                	addiw	a5,a5,1
    80003dd2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dd4:	00245517          	auipc	a0,0x245
    80003dd8:	14450513          	addi	a0,a0,324 # 80248f18 <itable>
    80003ddc:	f5dfc0ef          	jal	ra,80000d38 <release>
}
    80003de0:	8526                	mv	a0,s1
    80003de2:	60e2                	ld	ra,24(sp)
    80003de4:	6442                	ld	s0,16(sp)
    80003de6:	64a2                	ld	s1,8(sp)
    80003de8:	6105                	addi	sp,sp,32
    80003dea:	8082                	ret

0000000080003dec <ilock>:
{
    80003dec:	1101                	addi	sp,sp,-32
    80003dee:	ec06                	sd	ra,24(sp)
    80003df0:	e822                	sd	s0,16(sp)
    80003df2:	e426                	sd	s1,8(sp)
    80003df4:	e04a                	sd	s2,0(sp)
    80003df6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003df8:	c105                	beqz	a0,80003e18 <ilock+0x2c>
    80003dfa:	84aa                	mv	s1,a0
    80003dfc:	451c                	lw	a5,8(a0)
    80003dfe:	00f05d63          	blez	a5,80003e18 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003e02:	0541                	addi	a0,a0,16
    80003e04:	44b000ef          	jal	ra,80004a4e <acquiresleep>
  if(ip->valid == 0){
    80003e08:	40bc                	lw	a5,64(s1)
    80003e0a:	cf89                	beqz	a5,80003e24 <ilock+0x38>
}
    80003e0c:	60e2                	ld	ra,24(sp)
    80003e0e:	6442                	ld	s0,16(sp)
    80003e10:	64a2                	ld	s1,8(sp)
    80003e12:	6902                	ld	s2,0(sp)
    80003e14:	6105                	addi	sp,sp,32
    80003e16:	8082                	ret
    panic("ilock");
    80003e18:	00004517          	auipc	a0,0x4
    80003e1c:	78050513          	addi	a0,a0,1920 # 80008598 <syscalls+0x1a0>
    80003e20:	969fc0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e24:	40dc                	lw	a5,4(s1)
    80003e26:	0047d79b          	srliw	a5,a5,0x4
    80003e2a:	00245597          	auipc	a1,0x245
    80003e2e:	0e65a583          	lw	a1,230(a1) # 80248f10 <sb+0x18>
    80003e32:	9dbd                	addw	a1,a1,a5
    80003e34:	4088                	lw	a0,0(s1)
    80003e36:	907ff0ef          	jal	ra,8000373c <bread>
    80003e3a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e3c:	05850593          	addi	a1,a0,88
    80003e40:	40dc                	lw	a5,4(s1)
    80003e42:	8bbd                	andi	a5,a5,15
    80003e44:	079a                	slli	a5,a5,0x6
    80003e46:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e48:	00059783          	lh	a5,0(a1)
    80003e4c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e50:	00259783          	lh	a5,2(a1)
    80003e54:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e58:	00459783          	lh	a5,4(a1)
    80003e5c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e60:	00659783          	lh	a5,6(a1)
    80003e64:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e68:	459c                	lw	a5,8(a1)
    80003e6a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e6c:	03400613          	li	a2,52
    80003e70:	05b1                	addi	a1,a1,12
    80003e72:	05048513          	addi	a0,s1,80
    80003e76:	f5bfc0ef          	jal	ra,80000dd0 <memmove>
    brelse(bp);
    80003e7a:	854a                	mv	a0,s2
    80003e7c:	9c9ff0ef          	jal	ra,80003844 <brelse>
    ip->valid = 1;
    80003e80:	4785                	li	a5,1
    80003e82:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e84:	04449783          	lh	a5,68(s1)
    80003e88:	f3d1                	bnez	a5,80003e0c <ilock+0x20>
      panic("ilock: no type");
    80003e8a:	00004517          	auipc	a0,0x4
    80003e8e:	71650513          	addi	a0,a0,1814 # 800085a0 <syscalls+0x1a8>
    80003e92:	8f7fc0ef          	jal	ra,80000788 <panic>

0000000080003e96 <iunlock>:
{
    80003e96:	1101                	addi	sp,sp,-32
    80003e98:	ec06                	sd	ra,24(sp)
    80003e9a:	e822                	sd	s0,16(sp)
    80003e9c:	e426                	sd	s1,8(sp)
    80003e9e:	e04a                	sd	s2,0(sp)
    80003ea0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ea2:	c505                	beqz	a0,80003eca <iunlock+0x34>
    80003ea4:	84aa                	mv	s1,a0
    80003ea6:	01050913          	addi	s2,a0,16
    80003eaa:	854a                	mv	a0,s2
    80003eac:	421000ef          	jal	ra,80004acc <holdingsleep>
    80003eb0:	cd09                	beqz	a0,80003eca <iunlock+0x34>
    80003eb2:	449c                	lw	a5,8(s1)
    80003eb4:	00f05b63          	blez	a5,80003eca <iunlock+0x34>
  releasesleep(&ip->lock);
    80003eb8:	854a                	mv	a0,s2
    80003eba:	3db000ef          	jal	ra,80004a94 <releasesleep>
}
    80003ebe:	60e2                	ld	ra,24(sp)
    80003ec0:	6442                	ld	s0,16(sp)
    80003ec2:	64a2                	ld	s1,8(sp)
    80003ec4:	6902                	ld	s2,0(sp)
    80003ec6:	6105                	addi	sp,sp,32
    80003ec8:	8082                	ret
    panic("iunlock");
    80003eca:	00004517          	auipc	a0,0x4
    80003ece:	6e650513          	addi	a0,a0,1766 # 800085b0 <syscalls+0x1b8>
    80003ed2:	8b7fc0ef          	jal	ra,80000788 <panic>

0000000080003ed6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ed6:	7179                	addi	sp,sp,-48
    80003ed8:	f406                	sd	ra,40(sp)
    80003eda:	f022                	sd	s0,32(sp)
    80003edc:	ec26                	sd	s1,24(sp)
    80003ede:	e84a                	sd	s2,16(sp)
    80003ee0:	e44e                	sd	s3,8(sp)
    80003ee2:	e052                	sd	s4,0(sp)
    80003ee4:	1800                	addi	s0,sp,48
    80003ee6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ee8:	05050493          	addi	s1,a0,80
    80003eec:	08050913          	addi	s2,a0,128
    80003ef0:	a021                	j	80003ef8 <itrunc+0x22>
    80003ef2:	0491                	addi	s1,s1,4
    80003ef4:	01248b63          	beq	s1,s2,80003f0a <itrunc+0x34>
    if(ip->addrs[i]){
    80003ef8:	408c                	lw	a1,0(s1)
    80003efa:	dde5                	beqz	a1,80003ef2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003efc:	0009a503          	lw	a0,0(s3)
    80003f00:	a37ff0ef          	jal	ra,80003936 <bfree>
      ip->addrs[i] = 0;
    80003f04:	0004a023          	sw	zero,0(s1)
    80003f08:	b7ed                	j	80003ef2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f0a:	0809a583          	lw	a1,128(s3)
    80003f0e:	ed91                	bnez	a1,80003f2a <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f10:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f14:	854e                	mv	a0,s3
    80003f16:	e23ff0ef          	jal	ra,80003d38 <iupdate>
}
    80003f1a:	70a2                	ld	ra,40(sp)
    80003f1c:	7402                	ld	s0,32(sp)
    80003f1e:	64e2                	ld	s1,24(sp)
    80003f20:	6942                	ld	s2,16(sp)
    80003f22:	69a2                	ld	s3,8(sp)
    80003f24:	6a02                	ld	s4,0(sp)
    80003f26:	6145                	addi	sp,sp,48
    80003f28:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f2a:	0009a503          	lw	a0,0(s3)
    80003f2e:	80fff0ef          	jal	ra,8000373c <bread>
    80003f32:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f34:	05850493          	addi	s1,a0,88
    80003f38:	45850913          	addi	s2,a0,1112
    80003f3c:	a021                	j	80003f44 <itrunc+0x6e>
    80003f3e:	0491                	addi	s1,s1,4
    80003f40:	01248963          	beq	s1,s2,80003f52 <itrunc+0x7c>
      if(a[j])
    80003f44:	408c                	lw	a1,0(s1)
    80003f46:	dde5                	beqz	a1,80003f3e <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003f48:	0009a503          	lw	a0,0(s3)
    80003f4c:	9ebff0ef          	jal	ra,80003936 <bfree>
    80003f50:	b7fd                	j	80003f3e <itrunc+0x68>
    brelse(bp);
    80003f52:	8552                	mv	a0,s4
    80003f54:	8f1ff0ef          	jal	ra,80003844 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f58:	0809a583          	lw	a1,128(s3)
    80003f5c:	0009a503          	lw	a0,0(s3)
    80003f60:	9d7ff0ef          	jal	ra,80003936 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f64:	0809a023          	sw	zero,128(s3)
    80003f68:	b765                	j	80003f10 <itrunc+0x3a>

0000000080003f6a <iput>:
{
    80003f6a:	1101                	addi	sp,sp,-32
    80003f6c:	ec06                	sd	ra,24(sp)
    80003f6e:	e822                	sd	s0,16(sp)
    80003f70:	e426                	sd	s1,8(sp)
    80003f72:	e04a                	sd	s2,0(sp)
    80003f74:	1000                	addi	s0,sp,32
    80003f76:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f78:	00245517          	auipc	a0,0x245
    80003f7c:	fa050513          	addi	a0,a0,-96 # 80248f18 <itable>
    80003f80:	d21fc0ef          	jal	ra,80000ca0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f84:	4498                	lw	a4,8(s1)
    80003f86:	4785                	li	a5,1
    80003f88:	02f70163          	beq	a4,a5,80003faa <iput+0x40>
  ip->ref--;
    80003f8c:	449c                	lw	a5,8(s1)
    80003f8e:	37fd                	addiw	a5,a5,-1
    80003f90:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f92:	00245517          	auipc	a0,0x245
    80003f96:	f8650513          	addi	a0,a0,-122 # 80248f18 <itable>
    80003f9a:	d9ffc0ef          	jal	ra,80000d38 <release>
}
    80003f9e:	60e2                	ld	ra,24(sp)
    80003fa0:	6442                	ld	s0,16(sp)
    80003fa2:	64a2                	ld	s1,8(sp)
    80003fa4:	6902                	ld	s2,0(sp)
    80003fa6:	6105                	addi	sp,sp,32
    80003fa8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003faa:	40bc                	lw	a5,64(s1)
    80003fac:	d3e5                	beqz	a5,80003f8c <iput+0x22>
    80003fae:	04a49783          	lh	a5,74(s1)
    80003fb2:	ffe9                	bnez	a5,80003f8c <iput+0x22>
    acquiresleep(&ip->lock);
    80003fb4:	01048913          	addi	s2,s1,16
    80003fb8:	854a                	mv	a0,s2
    80003fba:	295000ef          	jal	ra,80004a4e <acquiresleep>
    release(&itable.lock);
    80003fbe:	00245517          	auipc	a0,0x245
    80003fc2:	f5a50513          	addi	a0,a0,-166 # 80248f18 <itable>
    80003fc6:	d73fc0ef          	jal	ra,80000d38 <release>
    itrunc(ip);
    80003fca:	8526                	mv	a0,s1
    80003fcc:	f0bff0ef          	jal	ra,80003ed6 <itrunc>
    ip->type = 0;
    80003fd0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003fd4:	8526                	mv	a0,s1
    80003fd6:	d63ff0ef          	jal	ra,80003d38 <iupdate>
    ip->valid = 0;
    80003fda:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003fde:	854a                	mv	a0,s2
    80003fe0:	2b5000ef          	jal	ra,80004a94 <releasesleep>
    acquire(&itable.lock);
    80003fe4:	00245517          	auipc	a0,0x245
    80003fe8:	f3450513          	addi	a0,a0,-204 # 80248f18 <itable>
    80003fec:	cb5fc0ef          	jal	ra,80000ca0 <acquire>
    80003ff0:	bf71                	j	80003f8c <iput+0x22>

0000000080003ff2 <iunlockput>:
{
    80003ff2:	1101                	addi	sp,sp,-32
    80003ff4:	ec06                	sd	ra,24(sp)
    80003ff6:	e822                	sd	s0,16(sp)
    80003ff8:	e426                	sd	s1,8(sp)
    80003ffa:	1000                	addi	s0,sp,32
    80003ffc:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ffe:	e99ff0ef          	jal	ra,80003e96 <iunlock>
  iput(ip);
    80004002:	8526                	mv	a0,s1
    80004004:	f67ff0ef          	jal	ra,80003f6a <iput>
}
    80004008:	60e2                	ld	ra,24(sp)
    8000400a:	6442                	ld	s0,16(sp)
    8000400c:	64a2                	ld	s1,8(sp)
    8000400e:	6105                	addi	sp,sp,32
    80004010:	8082                	ret

0000000080004012 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004012:	00245717          	auipc	a4,0x245
    80004016:	ef272703          	lw	a4,-270(a4) # 80248f04 <sb+0xc>
    8000401a:	4785                	li	a5,1
    8000401c:	0ae7ff63          	bgeu	a5,a4,800040da <ireclaim+0xc8>
{
    80004020:	7139                	addi	sp,sp,-64
    80004022:	fc06                	sd	ra,56(sp)
    80004024:	f822                	sd	s0,48(sp)
    80004026:	f426                	sd	s1,40(sp)
    80004028:	f04a                	sd	s2,32(sp)
    8000402a:	ec4e                	sd	s3,24(sp)
    8000402c:	e852                	sd	s4,16(sp)
    8000402e:	e456                	sd	s5,8(sp)
    80004030:	e05a                	sd	s6,0(sp)
    80004032:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004034:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004036:	00050a1b          	sext.w	s4,a0
    8000403a:	00245a97          	auipc	s5,0x245
    8000403e:	ebea8a93          	addi	s5,s5,-322 # 80248ef8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80004042:	00004b17          	auipc	s6,0x4
    80004046:	576b0b13          	addi	s6,s6,1398 # 800085b8 <syscalls+0x1c0>
    8000404a:	a099                	j	80004090 <ireclaim+0x7e>
    8000404c:	85ce                	mv	a1,s3
    8000404e:	855a                	mv	a0,s6
    80004050:	c72fc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    80004054:	85ce                	mv	a1,s3
    80004056:	8552                	mv	a0,s4
    80004058:	b27ff0ef          	jal	ra,80003b7e <iget>
    8000405c:	89aa                	mv	s3,a0
    brelse(bp);
    8000405e:	854a                	mv	a0,s2
    80004060:	fe4ff0ef          	jal	ra,80003844 <brelse>
    if (ip) {
    80004064:	00098f63          	beqz	s3,80004082 <ireclaim+0x70>
      begin_op();
    80004068:	76c000ef          	jal	ra,800047d4 <begin_op>
      ilock(ip);
    8000406c:	854e                	mv	a0,s3
    8000406e:	d7fff0ef          	jal	ra,80003dec <ilock>
      iunlock(ip);
    80004072:	854e                	mv	a0,s3
    80004074:	e23ff0ef          	jal	ra,80003e96 <iunlock>
      iput(ip);
    80004078:	854e                	mv	a0,s3
    8000407a:	ef1ff0ef          	jal	ra,80003f6a <iput>
      end_op();
    8000407e:	7c4000ef          	jal	ra,80004842 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004082:	0485                	addi	s1,s1,1
    80004084:	00caa703          	lw	a4,12(s5)
    80004088:	0004879b          	sext.w	a5,s1
    8000408c:	02e7fd63          	bgeu	a5,a4,800040c6 <ireclaim+0xb4>
    80004090:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004094:	0044d593          	srli	a1,s1,0x4
    80004098:	018aa783          	lw	a5,24(s5)
    8000409c:	9dbd                	addw	a1,a1,a5
    8000409e:	8552                	mv	a0,s4
    800040a0:	e9cff0ef          	jal	ra,8000373c <bread>
    800040a4:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800040a6:	05850793          	addi	a5,a0,88
    800040aa:	00f9f713          	andi	a4,s3,15
    800040ae:	071a                	slli	a4,a4,0x6
    800040b0:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800040b2:	00079703          	lh	a4,0(a5)
    800040b6:	c701                	beqz	a4,800040be <ireclaim+0xac>
    800040b8:	00679783          	lh	a5,6(a5)
    800040bc:	dbc1                	beqz	a5,8000404c <ireclaim+0x3a>
    brelse(bp);
    800040be:	854a                	mv	a0,s2
    800040c0:	f84ff0ef          	jal	ra,80003844 <brelse>
    if (ip) {
    800040c4:	bf7d                	j	80004082 <ireclaim+0x70>
}
    800040c6:	70e2                	ld	ra,56(sp)
    800040c8:	7442                	ld	s0,48(sp)
    800040ca:	74a2                	ld	s1,40(sp)
    800040cc:	7902                	ld	s2,32(sp)
    800040ce:	69e2                	ld	s3,24(sp)
    800040d0:	6a42                	ld	s4,16(sp)
    800040d2:	6aa2                	ld	s5,8(sp)
    800040d4:	6b02                	ld	s6,0(sp)
    800040d6:	6121                	addi	sp,sp,64
    800040d8:	8082                	ret
    800040da:	8082                	ret

00000000800040dc <fsinit>:
fsinit(int dev) {
    800040dc:	7179                	addi	sp,sp,-48
    800040de:	f406                	sd	ra,40(sp)
    800040e0:	f022                	sd	s0,32(sp)
    800040e2:	ec26                	sd	s1,24(sp)
    800040e4:	e84a                	sd	s2,16(sp)
    800040e6:	e44e                	sd	s3,8(sp)
    800040e8:	1800                	addi	s0,sp,48
    800040ea:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800040ec:	4585                	li	a1,1
    800040ee:	e4eff0ef          	jal	ra,8000373c <bread>
    800040f2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800040f4:	00245997          	auipc	s3,0x245
    800040f8:	e0498993          	addi	s3,s3,-508 # 80248ef8 <sb>
    800040fc:	02000613          	li	a2,32
    80004100:	05850593          	addi	a1,a0,88
    80004104:	854e                	mv	a0,s3
    80004106:	ccbfc0ef          	jal	ra,80000dd0 <memmove>
  brelse(bp);
    8000410a:	854a                	mv	a0,s2
    8000410c:	f38ff0ef          	jal	ra,80003844 <brelse>
  if(sb.magic != FSMAGIC)
    80004110:	0009a703          	lw	a4,0(s3)
    80004114:	102037b7          	lui	a5,0x10203
    80004118:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000411c:	02f71363          	bne	a4,a5,80004142 <fsinit+0x66>
  initlog(dev, &sb);
    80004120:	00245597          	auipc	a1,0x245
    80004124:	dd858593          	addi	a1,a1,-552 # 80248ef8 <sb>
    80004128:	8526                	mv	a0,s1
    8000412a:	61e000ef          	jal	ra,80004748 <initlog>
  ireclaim(dev);
    8000412e:	8526                	mv	a0,s1
    80004130:	ee3ff0ef          	jal	ra,80004012 <ireclaim>
}
    80004134:	70a2                	ld	ra,40(sp)
    80004136:	7402                	ld	s0,32(sp)
    80004138:	64e2                	ld	s1,24(sp)
    8000413a:	6942                	ld	s2,16(sp)
    8000413c:	69a2                	ld	s3,8(sp)
    8000413e:	6145                	addi	sp,sp,48
    80004140:	8082                	ret
    panic("invalid file system");
    80004142:	00004517          	auipc	a0,0x4
    80004146:	49650513          	addi	a0,a0,1174 # 800085d8 <syscalls+0x1e0>
    8000414a:	e3efc0ef          	jal	ra,80000788 <panic>

000000008000414e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000414e:	1141                	addi	sp,sp,-16
    80004150:	e422                	sd	s0,8(sp)
    80004152:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004154:	411c                	lw	a5,0(a0)
    80004156:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004158:	415c                	lw	a5,4(a0)
    8000415a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000415c:	04451783          	lh	a5,68(a0)
    80004160:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004164:	04a51783          	lh	a5,74(a0)
    80004168:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000416c:	04c56783          	lwu	a5,76(a0)
    80004170:	e99c                	sd	a5,16(a1)
}
    80004172:	6422                	ld	s0,8(sp)
    80004174:	0141                	addi	sp,sp,16
    80004176:	8082                	ret

0000000080004178 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004178:	457c                	lw	a5,76(a0)
    8000417a:	0cd7ef63          	bltu	a5,a3,80004258 <readi+0xe0>
{
    8000417e:	7159                	addi	sp,sp,-112
    80004180:	f486                	sd	ra,104(sp)
    80004182:	f0a2                	sd	s0,96(sp)
    80004184:	eca6                	sd	s1,88(sp)
    80004186:	e8ca                	sd	s2,80(sp)
    80004188:	e4ce                	sd	s3,72(sp)
    8000418a:	e0d2                	sd	s4,64(sp)
    8000418c:	fc56                	sd	s5,56(sp)
    8000418e:	f85a                	sd	s6,48(sp)
    80004190:	f45e                	sd	s7,40(sp)
    80004192:	f062                	sd	s8,32(sp)
    80004194:	ec66                	sd	s9,24(sp)
    80004196:	e86a                	sd	s10,16(sp)
    80004198:	e46e                	sd	s11,8(sp)
    8000419a:	1880                	addi	s0,sp,112
    8000419c:	8b2a                	mv	s6,a0
    8000419e:	8bae                	mv	s7,a1
    800041a0:	8a32                	mv	s4,a2
    800041a2:	84b6                	mv	s1,a3
    800041a4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800041a6:	9f35                	addw	a4,a4,a3
    return 0;
    800041a8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800041aa:	08d76663          	bltu	a4,a3,80004236 <readi+0xbe>
  if(off + n > ip->size)
    800041ae:	00e7f463          	bgeu	a5,a4,800041b6 <readi+0x3e>
    n = ip->size - off;
    800041b2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041b6:	080a8f63          	beqz	s5,80004254 <readi+0xdc>
    800041ba:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041bc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800041c0:	5c7d                	li	s8,-1
    800041c2:	a80d                	j	800041f4 <readi+0x7c>
    800041c4:	020d1d93          	slli	s11,s10,0x20
    800041c8:	020ddd93          	srli	s11,s11,0x20
    800041cc:	05890613          	addi	a2,s2,88
    800041d0:	86ee                	mv	a3,s11
    800041d2:	963a                	add	a2,a2,a4
    800041d4:	85d2                	mv	a1,s4
    800041d6:	855e                	mv	a0,s7
    800041d8:	dc4fe0ef          	jal	ra,8000279c <either_copyout>
    800041dc:	05850763          	beq	a0,s8,8000422a <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800041e0:	854a                	mv	a0,s2
    800041e2:	e62ff0ef          	jal	ra,80003844 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041e6:	013d09bb          	addw	s3,s10,s3
    800041ea:	009d04bb          	addw	s1,s10,s1
    800041ee:	9a6e                	add	s4,s4,s11
    800041f0:	0559f163          	bgeu	s3,s5,80004232 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800041f4:	00a4d59b          	srliw	a1,s1,0xa
    800041f8:	855a                	mv	a0,s6
    800041fa:	8b7ff0ef          	jal	ra,80003ab0 <bmap>
    800041fe:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004202:	c985                	beqz	a1,80004232 <readi+0xba>
    bp = bread(ip->dev, addr);
    80004204:	000b2503          	lw	a0,0(s6)
    80004208:	d34ff0ef          	jal	ra,8000373c <bread>
    8000420c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000420e:	3ff4f713          	andi	a4,s1,1023
    80004212:	40ec87bb          	subw	a5,s9,a4
    80004216:	413a86bb          	subw	a3,s5,s3
    8000421a:	8d3e                	mv	s10,a5
    8000421c:	2781                	sext.w	a5,a5
    8000421e:	0006861b          	sext.w	a2,a3
    80004222:	faf671e3          	bgeu	a2,a5,800041c4 <readi+0x4c>
    80004226:	8d36                	mv	s10,a3
    80004228:	bf71                	j	800041c4 <readi+0x4c>
      brelse(bp);
    8000422a:	854a                	mv	a0,s2
    8000422c:	e18ff0ef          	jal	ra,80003844 <brelse>
      tot = -1;
    80004230:	59fd                	li	s3,-1
  }
  return tot;
    80004232:	0009851b          	sext.w	a0,s3
}
    80004236:	70a6                	ld	ra,104(sp)
    80004238:	7406                	ld	s0,96(sp)
    8000423a:	64e6                	ld	s1,88(sp)
    8000423c:	6946                	ld	s2,80(sp)
    8000423e:	69a6                	ld	s3,72(sp)
    80004240:	6a06                	ld	s4,64(sp)
    80004242:	7ae2                	ld	s5,56(sp)
    80004244:	7b42                	ld	s6,48(sp)
    80004246:	7ba2                	ld	s7,40(sp)
    80004248:	7c02                	ld	s8,32(sp)
    8000424a:	6ce2                	ld	s9,24(sp)
    8000424c:	6d42                	ld	s10,16(sp)
    8000424e:	6da2                	ld	s11,8(sp)
    80004250:	6165                	addi	sp,sp,112
    80004252:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004254:	89d6                	mv	s3,s5
    80004256:	bff1                	j	80004232 <readi+0xba>
    return 0;
    80004258:	4501                	li	a0,0
}
    8000425a:	8082                	ret

000000008000425c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000425c:	457c                	lw	a5,76(a0)
    8000425e:	0ed7ea63          	bltu	a5,a3,80004352 <writei+0xf6>
{
    80004262:	7159                	addi	sp,sp,-112
    80004264:	f486                	sd	ra,104(sp)
    80004266:	f0a2                	sd	s0,96(sp)
    80004268:	eca6                	sd	s1,88(sp)
    8000426a:	e8ca                	sd	s2,80(sp)
    8000426c:	e4ce                	sd	s3,72(sp)
    8000426e:	e0d2                	sd	s4,64(sp)
    80004270:	fc56                	sd	s5,56(sp)
    80004272:	f85a                	sd	s6,48(sp)
    80004274:	f45e                	sd	s7,40(sp)
    80004276:	f062                	sd	s8,32(sp)
    80004278:	ec66                	sd	s9,24(sp)
    8000427a:	e86a                	sd	s10,16(sp)
    8000427c:	e46e                	sd	s11,8(sp)
    8000427e:	1880                	addi	s0,sp,112
    80004280:	8aaa                	mv	s5,a0
    80004282:	8bae                	mv	s7,a1
    80004284:	8a32                	mv	s4,a2
    80004286:	8936                	mv	s2,a3
    80004288:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000428a:	00e687bb          	addw	a5,a3,a4
    8000428e:	0cd7e463          	bltu	a5,a3,80004356 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004292:	00043737          	lui	a4,0x43
    80004296:	0cf76263          	bltu	a4,a5,8000435a <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000429a:	0a0b0a63          	beqz	s6,8000434e <writei+0xf2>
    8000429e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800042a0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800042a4:	5c7d                	li	s8,-1
    800042a6:	a825                	j	800042de <writei+0x82>
    800042a8:	020d1d93          	slli	s11,s10,0x20
    800042ac:	020ddd93          	srli	s11,s11,0x20
    800042b0:	05848513          	addi	a0,s1,88
    800042b4:	86ee                	mv	a3,s11
    800042b6:	8652                	mv	a2,s4
    800042b8:	85de                	mv	a1,s7
    800042ba:	953a                	add	a0,a0,a4
    800042bc:	d2afe0ef          	jal	ra,800027e6 <either_copyin>
    800042c0:	05850a63          	beq	a0,s8,80004314 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800042c4:	8526                	mv	a0,s1
    800042c6:	690000ef          	jal	ra,80004956 <log_write>
    brelse(bp);
    800042ca:	8526                	mv	a0,s1
    800042cc:	d78ff0ef          	jal	ra,80003844 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042d0:	013d09bb          	addw	s3,s10,s3
    800042d4:	012d093b          	addw	s2,s10,s2
    800042d8:	9a6e                	add	s4,s4,s11
    800042da:	0569f063          	bgeu	s3,s6,8000431a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800042de:	00a9559b          	srliw	a1,s2,0xa
    800042e2:	8556                	mv	a0,s5
    800042e4:	fccff0ef          	jal	ra,80003ab0 <bmap>
    800042e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042ec:	c59d                	beqz	a1,8000431a <writei+0xbe>
    bp = bread(ip->dev, addr);
    800042ee:	000aa503          	lw	a0,0(s5)
    800042f2:	c4aff0ef          	jal	ra,8000373c <bread>
    800042f6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042f8:	3ff97713          	andi	a4,s2,1023
    800042fc:	40ec87bb          	subw	a5,s9,a4
    80004300:	413b06bb          	subw	a3,s6,s3
    80004304:	8d3e                	mv	s10,a5
    80004306:	2781                	sext.w	a5,a5
    80004308:	0006861b          	sext.w	a2,a3
    8000430c:	f8f67ee3          	bgeu	a2,a5,800042a8 <writei+0x4c>
    80004310:	8d36                	mv	s10,a3
    80004312:	bf59                	j	800042a8 <writei+0x4c>
      brelse(bp);
    80004314:	8526                	mv	a0,s1
    80004316:	d2eff0ef          	jal	ra,80003844 <brelse>
  }

  if(off > ip->size)
    8000431a:	04caa783          	lw	a5,76(s5)
    8000431e:	0127f463          	bgeu	a5,s2,80004326 <writei+0xca>
    ip->size = off;
    80004322:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004326:	8556                	mv	a0,s5
    80004328:	a11ff0ef          	jal	ra,80003d38 <iupdate>

  return tot;
    8000432c:	0009851b          	sext.w	a0,s3
}
    80004330:	70a6                	ld	ra,104(sp)
    80004332:	7406                	ld	s0,96(sp)
    80004334:	64e6                	ld	s1,88(sp)
    80004336:	6946                	ld	s2,80(sp)
    80004338:	69a6                	ld	s3,72(sp)
    8000433a:	6a06                	ld	s4,64(sp)
    8000433c:	7ae2                	ld	s5,56(sp)
    8000433e:	7b42                	ld	s6,48(sp)
    80004340:	7ba2                	ld	s7,40(sp)
    80004342:	7c02                	ld	s8,32(sp)
    80004344:	6ce2                	ld	s9,24(sp)
    80004346:	6d42                	ld	s10,16(sp)
    80004348:	6da2                	ld	s11,8(sp)
    8000434a:	6165                	addi	sp,sp,112
    8000434c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000434e:	89da                	mv	s3,s6
    80004350:	bfd9                	j	80004326 <writei+0xca>
    return -1;
    80004352:	557d                	li	a0,-1
}
    80004354:	8082                	ret
    return -1;
    80004356:	557d                	li	a0,-1
    80004358:	bfe1                	j	80004330 <writei+0xd4>
    return -1;
    8000435a:	557d                	li	a0,-1
    8000435c:	bfd1                	j	80004330 <writei+0xd4>

000000008000435e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000435e:	1141                	addi	sp,sp,-16
    80004360:	e406                	sd	ra,8(sp)
    80004362:	e022                	sd	s0,0(sp)
    80004364:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004366:	4639                	li	a2,14
    80004368:	ad9fc0ef          	jal	ra,80000e40 <strncmp>
}
    8000436c:	60a2                	ld	ra,8(sp)
    8000436e:	6402                	ld	s0,0(sp)
    80004370:	0141                	addi	sp,sp,16
    80004372:	8082                	ret

0000000080004374 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004374:	7139                	addi	sp,sp,-64
    80004376:	fc06                	sd	ra,56(sp)
    80004378:	f822                	sd	s0,48(sp)
    8000437a:	f426                	sd	s1,40(sp)
    8000437c:	f04a                	sd	s2,32(sp)
    8000437e:	ec4e                	sd	s3,24(sp)
    80004380:	e852                	sd	s4,16(sp)
    80004382:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004384:	04451703          	lh	a4,68(a0)
    80004388:	4785                	li	a5,1
    8000438a:	00f71a63          	bne	a4,a5,8000439e <dirlookup+0x2a>
    8000438e:	892a                	mv	s2,a0
    80004390:	89ae                	mv	s3,a1
    80004392:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004394:	457c                	lw	a5,76(a0)
    80004396:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004398:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000439a:	e39d                	bnez	a5,800043c0 <dirlookup+0x4c>
    8000439c:	a095                	j	80004400 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000439e:	00004517          	auipc	a0,0x4
    800043a2:	25250513          	addi	a0,a0,594 # 800085f0 <syscalls+0x1f8>
    800043a6:	be2fc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    800043aa:	00004517          	auipc	a0,0x4
    800043ae:	25e50513          	addi	a0,a0,606 # 80008608 <syscalls+0x210>
    800043b2:	bd6fc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043b6:	24c1                	addiw	s1,s1,16
    800043b8:	04c92783          	lw	a5,76(s2)
    800043bc:	04f4f163          	bgeu	s1,a5,800043fe <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043c0:	4741                	li	a4,16
    800043c2:	86a6                	mv	a3,s1
    800043c4:	fc040613          	addi	a2,s0,-64
    800043c8:	4581                	li	a1,0
    800043ca:	854a                	mv	a0,s2
    800043cc:	dadff0ef          	jal	ra,80004178 <readi>
    800043d0:	47c1                	li	a5,16
    800043d2:	fcf51ce3          	bne	a0,a5,800043aa <dirlookup+0x36>
    if(de.inum == 0)
    800043d6:	fc045783          	lhu	a5,-64(s0)
    800043da:	dff1                	beqz	a5,800043b6 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800043dc:	fc240593          	addi	a1,s0,-62
    800043e0:	854e                	mv	a0,s3
    800043e2:	f7dff0ef          	jal	ra,8000435e <namecmp>
    800043e6:	f961                	bnez	a0,800043b6 <dirlookup+0x42>
      if(poff)
    800043e8:	000a0463          	beqz	s4,800043f0 <dirlookup+0x7c>
        *poff = off;
    800043ec:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800043f0:	fc045583          	lhu	a1,-64(s0)
    800043f4:	00092503          	lw	a0,0(s2)
    800043f8:	f86ff0ef          	jal	ra,80003b7e <iget>
    800043fc:	a011                	j	80004400 <dirlookup+0x8c>
  return 0;
    800043fe:	4501                	li	a0,0
}
    80004400:	70e2                	ld	ra,56(sp)
    80004402:	7442                	ld	s0,48(sp)
    80004404:	74a2                	ld	s1,40(sp)
    80004406:	7902                	ld	s2,32(sp)
    80004408:	69e2                	ld	s3,24(sp)
    8000440a:	6a42                	ld	s4,16(sp)
    8000440c:	6121                	addi	sp,sp,64
    8000440e:	8082                	ret

0000000080004410 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004410:	711d                	addi	sp,sp,-96
    80004412:	ec86                	sd	ra,88(sp)
    80004414:	e8a2                	sd	s0,80(sp)
    80004416:	e4a6                	sd	s1,72(sp)
    80004418:	e0ca                	sd	s2,64(sp)
    8000441a:	fc4e                	sd	s3,56(sp)
    8000441c:	f852                	sd	s4,48(sp)
    8000441e:	f456                	sd	s5,40(sp)
    80004420:	f05a                	sd	s6,32(sp)
    80004422:	ec5e                	sd	s7,24(sp)
    80004424:	e862                	sd	s8,16(sp)
    80004426:	e466                	sd	s9,8(sp)
    80004428:	e06a                	sd	s10,0(sp)
    8000442a:	1080                	addi	s0,sp,96
    8000442c:	84aa                	mv	s1,a0
    8000442e:	8b2e                	mv	s6,a1
    80004430:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004432:	00054703          	lbu	a4,0(a0)
    80004436:	02f00793          	li	a5,47
    8000443a:	00f70f63          	beq	a4,a5,80004458 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000443e:	f12fd0ef          	jal	ra,80001b50 <myproc>
    80004442:	15053503          	ld	a0,336(a0)
    80004446:	971ff0ef          	jal	ra,80003db6 <idup>
    8000444a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000444c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004450:	4cb5                	li	s9,13
  len = path - s;
    80004452:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004454:	4c05                	li	s8,1
    80004456:	a879                	j	800044f4 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80004458:	4585                	li	a1,1
    8000445a:	4505                	li	a0,1
    8000445c:	f22ff0ef          	jal	ra,80003b7e <iget>
    80004460:	8a2a                	mv	s4,a0
    80004462:	b7ed                	j	8000444c <namex+0x3c>
      iunlockput(ip);
    80004464:	8552                	mv	a0,s4
    80004466:	b8dff0ef          	jal	ra,80003ff2 <iunlockput>
      return 0;
    8000446a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000446c:	8552                	mv	a0,s4
    8000446e:	60e6                	ld	ra,88(sp)
    80004470:	6446                	ld	s0,80(sp)
    80004472:	64a6                	ld	s1,72(sp)
    80004474:	6906                	ld	s2,64(sp)
    80004476:	79e2                	ld	s3,56(sp)
    80004478:	7a42                	ld	s4,48(sp)
    8000447a:	7aa2                	ld	s5,40(sp)
    8000447c:	7b02                	ld	s6,32(sp)
    8000447e:	6be2                	ld	s7,24(sp)
    80004480:	6c42                	ld	s8,16(sp)
    80004482:	6ca2                	ld	s9,8(sp)
    80004484:	6d02                	ld	s10,0(sp)
    80004486:	6125                	addi	sp,sp,96
    80004488:	8082                	ret
      iunlock(ip);
    8000448a:	8552                	mv	a0,s4
    8000448c:	a0bff0ef          	jal	ra,80003e96 <iunlock>
      return ip;
    80004490:	bff1                	j	8000446c <namex+0x5c>
      iunlockput(ip);
    80004492:	8552                	mv	a0,s4
    80004494:	b5fff0ef          	jal	ra,80003ff2 <iunlockput>
      return 0;
    80004498:	8a4e                	mv	s4,s3
    8000449a:	bfc9                	j	8000446c <namex+0x5c>
  len = path - s;
    8000449c:	40998633          	sub	a2,s3,s1
    800044a0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800044a4:	09acd063          	bge	s9,s10,80004524 <namex+0x114>
    memmove(name, s, DIRSIZ);
    800044a8:	4639                	li	a2,14
    800044aa:	85a6                	mv	a1,s1
    800044ac:	8556                	mv	a0,s5
    800044ae:	923fc0ef          	jal	ra,80000dd0 <memmove>
    800044b2:	84ce                	mv	s1,s3
  while(*path == '/')
    800044b4:	0004c783          	lbu	a5,0(s1)
    800044b8:	01279763          	bne	a5,s2,800044c6 <namex+0xb6>
    path++;
    800044bc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044be:	0004c783          	lbu	a5,0(s1)
    800044c2:	ff278de3          	beq	a5,s2,800044bc <namex+0xac>
    ilock(ip);
    800044c6:	8552                	mv	a0,s4
    800044c8:	925ff0ef          	jal	ra,80003dec <ilock>
    if(ip->type != T_DIR){
    800044cc:	044a1783          	lh	a5,68(s4)
    800044d0:	f9879ae3          	bne	a5,s8,80004464 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800044d4:	000b0563          	beqz	s6,800044de <namex+0xce>
    800044d8:	0004c783          	lbu	a5,0(s1)
    800044dc:	d7dd                	beqz	a5,8000448a <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800044de:	865e                	mv	a2,s7
    800044e0:	85d6                	mv	a1,s5
    800044e2:	8552                	mv	a0,s4
    800044e4:	e91ff0ef          	jal	ra,80004374 <dirlookup>
    800044e8:	89aa                	mv	s3,a0
    800044ea:	d545                	beqz	a0,80004492 <namex+0x82>
    iunlockput(ip);
    800044ec:	8552                	mv	a0,s4
    800044ee:	b05ff0ef          	jal	ra,80003ff2 <iunlockput>
    ip = next;
    800044f2:	8a4e                	mv	s4,s3
  while(*path == '/')
    800044f4:	0004c783          	lbu	a5,0(s1)
    800044f8:	01279763          	bne	a5,s2,80004506 <namex+0xf6>
    path++;
    800044fc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044fe:	0004c783          	lbu	a5,0(s1)
    80004502:	ff278de3          	beq	a5,s2,800044fc <namex+0xec>
  if(*path == 0)
    80004506:	cb8d                	beqz	a5,80004538 <namex+0x128>
  while(*path != '/' && *path != 0)
    80004508:	0004c783          	lbu	a5,0(s1)
    8000450c:	89a6                	mv	s3,s1
  len = path - s;
    8000450e:	8d5e                	mv	s10,s7
    80004510:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004512:	01278963          	beq	a5,s2,80004524 <namex+0x114>
    80004516:	d3d9                	beqz	a5,8000449c <namex+0x8c>
    path++;
    80004518:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000451a:	0009c783          	lbu	a5,0(s3)
    8000451e:	ff279ce3          	bne	a5,s2,80004516 <namex+0x106>
    80004522:	bfad                	j	8000449c <namex+0x8c>
    memmove(name, s, len);
    80004524:	2601                	sext.w	a2,a2
    80004526:	85a6                	mv	a1,s1
    80004528:	8556                	mv	a0,s5
    8000452a:	8a7fc0ef          	jal	ra,80000dd0 <memmove>
    name[len] = 0;
    8000452e:	9d56                	add	s10,s10,s5
    80004530:	000d0023          	sb	zero,0(s10) # 1000 <_entry-0x7ffff000>
    80004534:	84ce                	mv	s1,s3
    80004536:	bfbd                	j	800044b4 <namex+0xa4>
  if(nameiparent){
    80004538:	f20b0ae3          	beqz	s6,8000446c <namex+0x5c>
    iput(ip);
    8000453c:	8552                	mv	a0,s4
    8000453e:	a2dff0ef          	jal	ra,80003f6a <iput>
    return 0;
    80004542:	4a01                	li	s4,0
    80004544:	b725                	j	8000446c <namex+0x5c>

0000000080004546 <dirlink>:
{
    80004546:	7139                	addi	sp,sp,-64
    80004548:	fc06                	sd	ra,56(sp)
    8000454a:	f822                	sd	s0,48(sp)
    8000454c:	f426                	sd	s1,40(sp)
    8000454e:	f04a                	sd	s2,32(sp)
    80004550:	ec4e                	sd	s3,24(sp)
    80004552:	e852                	sd	s4,16(sp)
    80004554:	0080                	addi	s0,sp,64
    80004556:	892a                	mv	s2,a0
    80004558:	8a2e                	mv	s4,a1
    8000455a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000455c:	4601                	li	a2,0
    8000455e:	e17ff0ef          	jal	ra,80004374 <dirlookup>
    80004562:	e52d                	bnez	a0,800045cc <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004564:	04c92483          	lw	s1,76(s2)
    80004568:	c48d                	beqz	s1,80004592 <dirlink+0x4c>
    8000456a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000456c:	4741                	li	a4,16
    8000456e:	86a6                	mv	a3,s1
    80004570:	fc040613          	addi	a2,s0,-64
    80004574:	4581                	li	a1,0
    80004576:	854a                	mv	a0,s2
    80004578:	c01ff0ef          	jal	ra,80004178 <readi>
    8000457c:	47c1                	li	a5,16
    8000457e:	04f51b63          	bne	a0,a5,800045d4 <dirlink+0x8e>
    if(de.inum == 0)
    80004582:	fc045783          	lhu	a5,-64(s0)
    80004586:	c791                	beqz	a5,80004592 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004588:	24c1                	addiw	s1,s1,16
    8000458a:	04c92783          	lw	a5,76(s2)
    8000458e:	fcf4efe3          	bltu	s1,a5,8000456c <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004592:	4639                	li	a2,14
    80004594:	85d2                	mv	a1,s4
    80004596:	fc240513          	addi	a0,s0,-62
    8000459a:	8e3fc0ef          	jal	ra,80000e7c <strncpy>
  de.inum = inum;
    8000459e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045a2:	4741                	li	a4,16
    800045a4:	86a6                	mv	a3,s1
    800045a6:	fc040613          	addi	a2,s0,-64
    800045aa:	4581                	li	a1,0
    800045ac:	854a                	mv	a0,s2
    800045ae:	cafff0ef          	jal	ra,8000425c <writei>
    800045b2:	1541                	addi	a0,a0,-16
    800045b4:	00a03533          	snez	a0,a0
    800045b8:	40a00533          	neg	a0,a0
}
    800045bc:	70e2                	ld	ra,56(sp)
    800045be:	7442                	ld	s0,48(sp)
    800045c0:	74a2                	ld	s1,40(sp)
    800045c2:	7902                	ld	s2,32(sp)
    800045c4:	69e2                	ld	s3,24(sp)
    800045c6:	6a42                	ld	s4,16(sp)
    800045c8:	6121                	addi	sp,sp,64
    800045ca:	8082                	ret
    iput(ip);
    800045cc:	99fff0ef          	jal	ra,80003f6a <iput>
    return -1;
    800045d0:	557d                	li	a0,-1
    800045d2:	b7ed                	j	800045bc <dirlink+0x76>
      panic("dirlink read");
    800045d4:	00004517          	auipc	a0,0x4
    800045d8:	04450513          	addi	a0,a0,68 # 80008618 <syscalls+0x220>
    800045dc:	9acfc0ef          	jal	ra,80000788 <panic>

00000000800045e0 <namei>:

struct inode*
namei(char *path)
{
    800045e0:	1101                	addi	sp,sp,-32
    800045e2:	ec06                	sd	ra,24(sp)
    800045e4:	e822                	sd	s0,16(sp)
    800045e6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800045e8:	fe040613          	addi	a2,s0,-32
    800045ec:	4581                	li	a1,0
    800045ee:	e23ff0ef          	jal	ra,80004410 <namex>
}
    800045f2:	60e2                	ld	ra,24(sp)
    800045f4:	6442                	ld	s0,16(sp)
    800045f6:	6105                	addi	sp,sp,32
    800045f8:	8082                	ret

00000000800045fa <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045fa:	1141                	addi	sp,sp,-16
    800045fc:	e406                	sd	ra,8(sp)
    800045fe:	e022                	sd	s0,0(sp)
    80004600:	0800                	addi	s0,sp,16
    80004602:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004604:	4585                	li	a1,1
    80004606:	e0bff0ef          	jal	ra,80004410 <namex>
}
    8000460a:	60a2                	ld	ra,8(sp)
    8000460c:	6402                	ld	s0,0(sp)
    8000460e:	0141                	addi	sp,sp,16
    80004610:	8082                	ret

0000000080004612 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004612:	1101                	addi	sp,sp,-32
    80004614:	ec06                	sd	ra,24(sp)
    80004616:	e822                	sd	s0,16(sp)
    80004618:	e426                	sd	s1,8(sp)
    8000461a:	e04a                	sd	s2,0(sp)
    8000461c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000461e:	00246917          	auipc	s2,0x246
    80004622:	3a290913          	addi	s2,s2,930 # 8024a9c0 <log>
    80004626:	01892583          	lw	a1,24(s2)
    8000462a:	02492503          	lw	a0,36(s2)
    8000462e:	90eff0ef          	jal	ra,8000373c <bread>
    80004632:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004634:	02892683          	lw	a3,40(s2)
    80004638:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000463a:	02d05863          	blez	a3,8000466a <write_head+0x58>
    8000463e:	00246797          	auipc	a5,0x246
    80004642:	3ae78793          	addi	a5,a5,942 # 8024a9ec <log+0x2c>
    80004646:	05c50713          	addi	a4,a0,92
    8000464a:	36fd                	addiw	a3,a3,-1
    8000464c:	02069613          	slli	a2,a3,0x20
    80004650:	01e65693          	srli	a3,a2,0x1e
    80004654:	00246617          	auipc	a2,0x246
    80004658:	39c60613          	addi	a2,a2,924 # 8024a9f0 <log+0x30>
    8000465c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000465e:	4390                	lw	a2,0(a5)
    80004660:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004662:	0791                	addi	a5,a5,4
    80004664:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004666:	fed79ce3          	bne	a5,a3,8000465e <write_head+0x4c>
  }
  bwrite(buf);
    8000466a:	8526                	mv	a0,s1
    8000466c:	9a6ff0ef          	jal	ra,80003812 <bwrite>
  brelse(buf);
    80004670:	8526                	mv	a0,s1
    80004672:	9d2ff0ef          	jal	ra,80003844 <brelse>
}
    80004676:	60e2                	ld	ra,24(sp)
    80004678:	6442                	ld	s0,16(sp)
    8000467a:	64a2                	ld	s1,8(sp)
    8000467c:	6902                	ld	s2,0(sp)
    8000467e:	6105                	addi	sp,sp,32
    80004680:	8082                	ret

0000000080004682 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004682:	00246797          	auipc	a5,0x246
    80004686:	3667a783          	lw	a5,870(a5) # 8024a9e8 <log+0x28>
    8000468a:	0af05e63          	blez	a5,80004746 <install_trans+0xc4>
{
    8000468e:	715d                	addi	sp,sp,-80
    80004690:	e486                	sd	ra,72(sp)
    80004692:	e0a2                	sd	s0,64(sp)
    80004694:	fc26                	sd	s1,56(sp)
    80004696:	f84a                	sd	s2,48(sp)
    80004698:	f44e                	sd	s3,40(sp)
    8000469a:	f052                	sd	s4,32(sp)
    8000469c:	ec56                	sd	s5,24(sp)
    8000469e:	e85a                	sd	s6,16(sp)
    800046a0:	e45e                	sd	s7,8(sp)
    800046a2:	0880                	addi	s0,sp,80
    800046a4:	8b2a                	mv	s6,a0
    800046a6:	00246a97          	auipc	s5,0x246
    800046aa:	346a8a93          	addi	s5,s5,838 # 8024a9ec <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046ae:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800046b0:	00004b97          	auipc	s7,0x4
    800046b4:	f78b8b93          	addi	s7,s7,-136 # 80008628 <syscalls+0x230>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800046b8:	00246a17          	auipc	s4,0x246
    800046bc:	308a0a13          	addi	s4,s4,776 # 8024a9c0 <log>
    800046c0:	a025                	j	800046e8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800046c2:	000aa603          	lw	a2,0(s5)
    800046c6:	85ce                	mv	a1,s3
    800046c8:	855e                	mv	a0,s7
    800046ca:	df9fb0ef          	jal	ra,800004c2 <printf>
    800046ce:	a839                	j	800046ec <install_trans+0x6a>
    brelse(lbuf);
    800046d0:	854a                	mv	a0,s2
    800046d2:	972ff0ef          	jal	ra,80003844 <brelse>
    brelse(dbuf);
    800046d6:	8526                	mv	a0,s1
    800046d8:	96cff0ef          	jal	ra,80003844 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046dc:	2985                	addiw	s3,s3,1
    800046de:	0a91                	addi	s5,s5,4
    800046e0:	028a2783          	lw	a5,40(s4)
    800046e4:	04f9d663          	bge	s3,a5,80004730 <install_trans+0xae>
    if(recovering) {
    800046e8:	fc0b1de3          	bnez	s6,800046c2 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800046ec:	018a2583          	lw	a1,24(s4)
    800046f0:	013585bb          	addw	a1,a1,s3
    800046f4:	2585                	addiw	a1,a1,1
    800046f6:	024a2503          	lw	a0,36(s4)
    800046fa:	842ff0ef          	jal	ra,8000373c <bread>
    800046fe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004700:	000aa583          	lw	a1,0(s5)
    80004704:	024a2503          	lw	a0,36(s4)
    80004708:	834ff0ef          	jal	ra,8000373c <bread>
    8000470c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000470e:	40000613          	li	a2,1024
    80004712:	05890593          	addi	a1,s2,88
    80004716:	05850513          	addi	a0,a0,88
    8000471a:	eb6fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000471e:	8526                	mv	a0,s1
    80004720:	8f2ff0ef          	jal	ra,80003812 <bwrite>
    if(recovering == 0)
    80004724:	fa0b16e3          	bnez	s6,800046d0 <install_trans+0x4e>
      bunpin(dbuf);
    80004728:	8526                	mv	a0,s1
    8000472a:	9d8ff0ef          	jal	ra,80003902 <bunpin>
    8000472e:	b74d                	j	800046d0 <install_trans+0x4e>
}
    80004730:	60a6                	ld	ra,72(sp)
    80004732:	6406                	ld	s0,64(sp)
    80004734:	74e2                	ld	s1,56(sp)
    80004736:	7942                	ld	s2,48(sp)
    80004738:	79a2                	ld	s3,40(sp)
    8000473a:	7a02                	ld	s4,32(sp)
    8000473c:	6ae2                	ld	s5,24(sp)
    8000473e:	6b42                	ld	s6,16(sp)
    80004740:	6ba2                	ld	s7,8(sp)
    80004742:	6161                	addi	sp,sp,80
    80004744:	8082                	ret
    80004746:	8082                	ret

0000000080004748 <initlog>:
{
    80004748:	7179                	addi	sp,sp,-48
    8000474a:	f406                	sd	ra,40(sp)
    8000474c:	f022                	sd	s0,32(sp)
    8000474e:	ec26                	sd	s1,24(sp)
    80004750:	e84a                	sd	s2,16(sp)
    80004752:	e44e                	sd	s3,8(sp)
    80004754:	1800                	addi	s0,sp,48
    80004756:	892a                	mv	s2,a0
    80004758:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000475a:	00246497          	auipc	s1,0x246
    8000475e:	26648493          	addi	s1,s1,614 # 8024a9c0 <log>
    80004762:	00004597          	auipc	a1,0x4
    80004766:	ee658593          	addi	a1,a1,-282 # 80008648 <syscalls+0x250>
    8000476a:	8526                	mv	a0,s1
    8000476c:	cb4fc0ef          	jal	ra,80000c20 <initlock>
  log.start = sb->logstart;
    80004770:	0149a583          	lw	a1,20(s3)
    80004774:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004776:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000477a:	854a                	mv	a0,s2
    8000477c:	fc1fe0ef          	jal	ra,8000373c <bread>
  log.lh.n = lh->n;
    80004780:	4d34                	lw	a3,88(a0)
    80004782:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004784:	02d05663          	blez	a3,800047b0 <initlog+0x68>
    80004788:	05c50793          	addi	a5,a0,92
    8000478c:	00246717          	auipc	a4,0x246
    80004790:	26070713          	addi	a4,a4,608 # 8024a9ec <log+0x2c>
    80004794:	36fd                	addiw	a3,a3,-1
    80004796:	02069613          	slli	a2,a3,0x20
    8000479a:	01e65693          	srli	a3,a2,0x1e
    8000479e:	06050613          	addi	a2,a0,96
    800047a2:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800047a4:	4390                	lw	a2,0(a5)
    800047a6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800047a8:	0791                	addi	a5,a5,4
    800047aa:	0711                	addi	a4,a4,4
    800047ac:	fed79ce3          	bne	a5,a3,800047a4 <initlog+0x5c>
  brelse(buf);
    800047b0:	894ff0ef          	jal	ra,80003844 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800047b4:	4505                	li	a0,1
    800047b6:	ecdff0ef          	jal	ra,80004682 <install_trans>
  log.lh.n = 0;
    800047ba:	00246797          	auipc	a5,0x246
    800047be:	2207a723          	sw	zero,558(a5) # 8024a9e8 <log+0x28>
  write_head(); // clear the log
    800047c2:	e51ff0ef          	jal	ra,80004612 <write_head>
}
    800047c6:	70a2                	ld	ra,40(sp)
    800047c8:	7402                	ld	s0,32(sp)
    800047ca:	64e2                	ld	s1,24(sp)
    800047cc:	6942                	ld	s2,16(sp)
    800047ce:	69a2                	ld	s3,8(sp)
    800047d0:	6145                	addi	sp,sp,48
    800047d2:	8082                	ret

00000000800047d4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800047d4:	1101                	addi	sp,sp,-32
    800047d6:	ec06                	sd	ra,24(sp)
    800047d8:	e822                	sd	s0,16(sp)
    800047da:	e426                	sd	s1,8(sp)
    800047dc:	e04a                	sd	s2,0(sp)
    800047de:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800047e0:	00246517          	auipc	a0,0x246
    800047e4:	1e050513          	addi	a0,a0,480 # 8024a9c0 <log>
    800047e8:	cb8fc0ef          	jal	ra,80000ca0 <acquire>
  while(1){
    if(log.committing){
    800047ec:	00246497          	auipc	s1,0x246
    800047f0:	1d448493          	addi	s1,s1,468 # 8024a9c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800047f4:	4979                	li	s2,30
    800047f6:	a029                	j	80004800 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800047f8:	85a6                	mv	a1,s1
    800047fa:	8526                	mv	a0,s1
    800047fc:	c45fd0ef          	jal	ra,80002440 <sleep>
    if(log.committing){
    80004800:	509c                	lw	a5,32(s1)
    80004802:	fbfd                	bnez	a5,800047f8 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004804:	4cd8                	lw	a4,28(s1)
    80004806:	2705                	addiw	a4,a4,1
    80004808:	0007069b          	sext.w	a3,a4
    8000480c:	0027179b          	slliw	a5,a4,0x2
    80004810:	9fb9                	addw	a5,a5,a4
    80004812:	0017979b          	slliw	a5,a5,0x1
    80004816:	5498                	lw	a4,40(s1)
    80004818:	9fb9                	addw	a5,a5,a4
    8000481a:	00f95763          	bge	s2,a5,80004828 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000481e:	85a6                	mv	a1,s1
    80004820:	8526                	mv	a0,s1
    80004822:	c1ffd0ef          	jal	ra,80002440 <sleep>
    80004826:	bfe9                	j	80004800 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004828:	00246517          	auipc	a0,0x246
    8000482c:	19850513          	addi	a0,a0,408 # 8024a9c0 <log>
    80004830:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80004832:	d06fc0ef          	jal	ra,80000d38 <release>
      break;
    }
  }
}
    80004836:	60e2                	ld	ra,24(sp)
    80004838:	6442                	ld	s0,16(sp)
    8000483a:	64a2                	ld	s1,8(sp)
    8000483c:	6902                	ld	s2,0(sp)
    8000483e:	6105                	addi	sp,sp,32
    80004840:	8082                	ret

0000000080004842 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004842:	7139                	addi	sp,sp,-64
    80004844:	fc06                	sd	ra,56(sp)
    80004846:	f822                	sd	s0,48(sp)
    80004848:	f426                	sd	s1,40(sp)
    8000484a:	f04a                	sd	s2,32(sp)
    8000484c:	ec4e                	sd	s3,24(sp)
    8000484e:	e852                	sd	s4,16(sp)
    80004850:	e456                	sd	s5,8(sp)
    80004852:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004854:	00246497          	auipc	s1,0x246
    80004858:	16c48493          	addi	s1,s1,364 # 8024a9c0 <log>
    8000485c:	8526                	mv	a0,s1
    8000485e:	c42fc0ef          	jal	ra,80000ca0 <acquire>
  log.outstanding -= 1;
    80004862:	4cdc                	lw	a5,28(s1)
    80004864:	37fd                	addiw	a5,a5,-1
    80004866:	0007891b          	sext.w	s2,a5
    8000486a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000486c:	509c                	lw	a5,32(s1)
    8000486e:	ef9d                	bnez	a5,800048ac <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004870:	04091463          	bnez	s2,800048b8 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004874:	00246497          	auipc	s1,0x246
    80004878:	14c48493          	addi	s1,s1,332 # 8024a9c0 <log>
    8000487c:	4785                	li	a5,1
    8000487e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004880:	8526                	mv	a0,s1
    80004882:	cb6fc0ef          	jal	ra,80000d38 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004886:	549c                	lw	a5,40(s1)
    80004888:	04f04b63          	bgtz	a5,800048de <end_op+0x9c>
    acquire(&log.lock);
    8000488c:	00246497          	auipc	s1,0x246
    80004890:	13448493          	addi	s1,s1,308 # 8024a9c0 <log>
    80004894:	8526                	mv	a0,s1
    80004896:	c0afc0ef          	jal	ra,80000ca0 <acquire>
    log.committing = 0;
    8000489a:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    8000489e:	8526                	mv	a0,s1
    800048a0:	bedfd0ef          	jal	ra,8000248c <wakeup>
    release(&log.lock);
    800048a4:	8526                	mv	a0,s1
    800048a6:	c92fc0ef          	jal	ra,80000d38 <release>
}
    800048aa:	a00d                	j	800048cc <end_op+0x8a>
    panic("log.committing");
    800048ac:	00004517          	auipc	a0,0x4
    800048b0:	da450513          	addi	a0,a0,-604 # 80008650 <syscalls+0x258>
    800048b4:	ed5fb0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    800048b8:	00246497          	auipc	s1,0x246
    800048bc:	10848493          	addi	s1,s1,264 # 8024a9c0 <log>
    800048c0:	8526                	mv	a0,s1
    800048c2:	bcbfd0ef          	jal	ra,8000248c <wakeup>
  release(&log.lock);
    800048c6:	8526                	mv	a0,s1
    800048c8:	c70fc0ef          	jal	ra,80000d38 <release>
}
    800048cc:	70e2                	ld	ra,56(sp)
    800048ce:	7442                	ld	s0,48(sp)
    800048d0:	74a2                	ld	s1,40(sp)
    800048d2:	7902                	ld	s2,32(sp)
    800048d4:	69e2                	ld	s3,24(sp)
    800048d6:	6a42                	ld	s4,16(sp)
    800048d8:	6aa2                	ld	s5,8(sp)
    800048da:	6121                	addi	sp,sp,64
    800048dc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800048de:	00246a97          	auipc	s5,0x246
    800048e2:	10ea8a93          	addi	s5,s5,270 # 8024a9ec <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800048e6:	00246a17          	auipc	s4,0x246
    800048ea:	0daa0a13          	addi	s4,s4,218 # 8024a9c0 <log>
    800048ee:	018a2583          	lw	a1,24(s4)
    800048f2:	012585bb          	addw	a1,a1,s2
    800048f6:	2585                	addiw	a1,a1,1
    800048f8:	024a2503          	lw	a0,36(s4)
    800048fc:	e41fe0ef          	jal	ra,8000373c <bread>
    80004900:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004902:	000aa583          	lw	a1,0(s5)
    80004906:	024a2503          	lw	a0,36(s4)
    8000490a:	e33fe0ef          	jal	ra,8000373c <bread>
    8000490e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004910:	40000613          	li	a2,1024
    80004914:	05850593          	addi	a1,a0,88
    80004918:	05848513          	addi	a0,s1,88
    8000491c:	cb4fc0ef          	jal	ra,80000dd0 <memmove>
    bwrite(to);  // write the log
    80004920:	8526                	mv	a0,s1
    80004922:	ef1fe0ef          	jal	ra,80003812 <bwrite>
    brelse(from);
    80004926:	854e                	mv	a0,s3
    80004928:	f1dfe0ef          	jal	ra,80003844 <brelse>
    brelse(to);
    8000492c:	8526                	mv	a0,s1
    8000492e:	f17fe0ef          	jal	ra,80003844 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004932:	2905                	addiw	s2,s2,1
    80004934:	0a91                	addi	s5,s5,4
    80004936:	028a2783          	lw	a5,40(s4)
    8000493a:	faf94ae3          	blt	s2,a5,800048ee <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000493e:	cd5ff0ef          	jal	ra,80004612 <write_head>
    install_trans(0); // Now install writes to home locations
    80004942:	4501                	li	a0,0
    80004944:	d3fff0ef          	jal	ra,80004682 <install_trans>
    log.lh.n = 0;
    80004948:	00246797          	auipc	a5,0x246
    8000494c:	0a07a023          	sw	zero,160(a5) # 8024a9e8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004950:	cc3ff0ef          	jal	ra,80004612 <write_head>
    80004954:	bf25                	j	8000488c <end_op+0x4a>

0000000080004956 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004956:	1101                	addi	sp,sp,-32
    80004958:	ec06                	sd	ra,24(sp)
    8000495a:	e822                	sd	s0,16(sp)
    8000495c:	e426                	sd	s1,8(sp)
    8000495e:	e04a                	sd	s2,0(sp)
    80004960:	1000                	addi	s0,sp,32
    80004962:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004964:	00246917          	auipc	s2,0x246
    80004968:	05c90913          	addi	s2,s2,92 # 8024a9c0 <log>
    8000496c:	854a                	mv	a0,s2
    8000496e:	b32fc0ef          	jal	ra,80000ca0 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004972:	02892603          	lw	a2,40(s2)
    80004976:	47f5                	li	a5,29
    80004978:	04c7cc63          	blt	a5,a2,800049d0 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000497c:	00246797          	auipc	a5,0x246
    80004980:	0607a783          	lw	a5,96(a5) # 8024a9dc <log+0x1c>
    80004984:	04f05c63          	blez	a5,800049dc <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004988:	4781                	li	a5,0
    8000498a:	04c05f63          	blez	a2,800049e8 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000498e:	44cc                	lw	a1,12(s1)
    80004990:	00246717          	auipc	a4,0x246
    80004994:	05c70713          	addi	a4,a4,92 # 8024a9ec <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004998:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000499a:	4314                	lw	a3,0(a4)
    8000499c:	04b68663          	beq	a3,a1,800049e8 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800049a0:	2785                	addiw	a5,a5,1
    800049a2:	0711                	addi	a4,a4,4
    800049a4:	fef61be3          	bne	a2,a5,8000499a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800049a8:	0621                	addi	a2,a2,8
    800049aa:	060a                	slli	a2,a2,0x2
    800049ac:	00246797          	auipc	a5,0x246
    800049b0:	01478793          	addi	a5,a5,20 # 8024a9c0 <log>
    800049b4:	97b2                	add	a5,a5,a2
    800049b6:	44d8                	lw	a4,12(s1)
    800049b8:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800049ba:	8526                	mv	a0,s1
    800049bc:	f13fe0ef          	jal	ra,800038ce <bpin>
    log.lh.n++;
    800049c0:	00246717          	auipc	a4,0x246
    800049c4:	00070713          	mv	a4,a4
    800049c8:	571c                	lw	a5,40(a4)
    800049ca:	2785                	addiw	a5,a5,1
    800049cc:	d71c                	sw	a5,40(a4)
    800049ce:	a80d                	j	80004a00 <log_write+0xaa>
    panic("too big a transaction");
    800049d0:	00004517          	auipc	a0,0x4
    800049d4:	c9050513          	addi	a0,a0,-880 # 80008660 <syscalls+0x268>
    800049d8:	db1fb0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    800049dc:	00004517          	auipc	a0,0x4
    800049e0:	c9c50513          	addi	a0,a0,-868 # 80008678 <syscalls+0x280>
    800049e4:	da5fb0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    800049e8:	00878693          	addi	a3,a5,8
    800049ec:	068a                	slli	a3,a3,0x2
    800049ee:	00246717          	auipc	a4,0x246
    800049f2:	fd270713          	addi	a4,a4,-46 # 8024a9c0 <log>
    800049f6:	9736                	add	a4,a4,a3
    800049f8:	44d4                	lw	a3,12(s1)
    800049fa:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800049fc:	faf60fe3          	beq	a2,a5,800049ba <log_write+0x64>
  }
  release(&log.lock);
    80004a00:	00246517          	auipc	a0,0x246
    80004a04:	fc050513          	addi	a0,a0,-64 # 8024a9c0 <log>
    80004a08:	b30fc0ef          	jal	ra,80000d38 <release>
}
    80004a0c:	60e2                	ld	ra,24(sp)
    80004a0e:	6442                	ld	s0,16(sp)
    80004a10:	64a2                	ld	s1,8(sp)
    80004a12:	6902                	ld	s2,0(sp)
    80004a14:	6105                	addi	sp,sp,32
    80004a16:	8082                	ret

0000000080004a18 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a18:	1101                	addi	sp,sp,-32
    80004a1a:	ec06                	sd	ra,24(sp)
    80004a1c:	e822                	sd	s0,16(sp)
    80004a1e:	e426                	sd	s1,8(sp)
    80004a20:	e04a                	sd	s2,0(sp)
    80004a22:	1000                	addi	s0,sp,32
    80004a24:	84aa                	mv	s1,a0
    80004a26:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a28:	00004597          	auipc	a1,0x4
    80004a2c:	c7058593          	addi	a1,a1,-912 # 80008698 <syscalls+0x2a0>
    80004a30:	0521                	addi	a0,a0,8
    80004a32:	9eefc0ef          	jal	ra,80000c20 <initlock>
  lk->name = name;
    80004a36:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a3a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a3e:	0204a423          	sw	zero,40(s1)
}
    80004a42:	60e2                	ld	ra,24(sp)
    80004a44:	6442                	ld	s0,16(sp)
    80004a46:	64a2                	ld	s1,8(sp)
    80004a48:	6902                	ld	s2,0(sp)
    80004a4a:	6105                	addi	sp,sp,32
    80004a4c:	8082                	ret

0000000080004a4e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a4e:	1101                	addi	sp,sp,-32
    80004a50:	ec06                	sd	ra,24(sp)
    80004a52:	e822                	sd	s0,16(sp)
    80004a54:	e426                	sd	s1,8(sp)
    80004a56:	e04a                	sd	s2,0(sp)
    80004a58:	1000                	addi	s0,sp,32
    80004a5a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a5c:	00850913          	addi	s2,a0,8
    80004a60:	854a                	mv	a0,s2
    80004a62:	a3efc0ef          	jal	ra,80000ca0 <acquire>
  while (lk->locked) {
    80004a66:	409c                	lw	a5,0(s1)
    80004a68:	c799                	beqz	a5,80004a76 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004a6a:	85ca                	mv	a1,s2
    80004a6c:	8526                	mv	a0,s1
    80004a6e:	9d3fd0ef          	jal	ra,80002440 <sleep>
  while (lk->locked) {
    80004a72:	409c                	lw	a5,0(s1)
    80004a74:	fbfd                	bnez	a5,80004a6a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004a76:	4785                	li	a5,1
    80004a78:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a7a:	8d6fd0ef          	jal	ra,80001b50 <myproc>
    80004a7e:	591c                	lw	a5,48(a0)
    80004a80:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a82:	854a                	mv	a0,s2
    80004a84:	ab4fc0ef          	jal	ra,80000d38 <release>
}
    80004a88:	60e2                	ld	ra,24(sp)
    80004a8a:	6442                	ld	s0,16(sp)
    80004a8c:	64a2                	ld	s1,8(sp)
    80004a8e:	6902                	ld	s2,0(sp)
    80004a90:	6105                	addi	sp,sp,32
    80004a92:	8082                	ret

0000000080004a94 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a94:	1101                	addi	sp,sp,-32
    80004a96:	ec06                	sd	ra,24(sp)
    80004a98:	e822                	sd	s0,16(sp)
    80004a9a:	e426                	sd	s1,8(sp)
    80004a9c:	e04a                	sd	s2,0(sp)
    80004a9e:	1000                	addi	s0,sp,32
    80004aa0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004aa2:	00850913          	addi	s2,a0,8
    80004aa6:	854a                	mv	a0,s2
    80004aa8:	9f8fc0ef          	jal	ra,80000ca0 <acquire>
  lk->locked = 0;
    80004aac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ab0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	9d7fd0ef          	jal	ra,8000248c <wakeup>
  release(&lk->lk);
    80004aba:	854a                	mv	a0,s2
    80004abc:	a7cfc0ef          	jal	ra,80000d38 <release>
}
    80004ac0:	60e2                	ld	ra,24(sp)
    80004ac2:	6442                	ld	s0,16(sp)
    80004ac4:	64a2                	ld	s1,8(sp)
    80004ac6:	6902                	ld	s2,0(sp)
    80004ac8:	6105                	addi	sp,sp,32
    80004aca:	8082                	ret

0000000080004acc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004acc:	7179                	addi	sp,sp,-48
    80004ace:	f406                	sd	ra,40(sp)
    80004ad0:	f022                	sd	s0,32(sp)
    80004ad2:	ec26                	sd	s1,24(sp)
    80004ad4:	e84a                	sd	s2,16(sp)
    80004ad6:	e44e                	sd	s3,8(sp)
    80004ad8:	1800                	addi	s0,sp,48
    80004ada:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004adc:	00850913          	addi	s2,a0,8
    80004ae0:	854a                	mv	a0,s2
    80004ae2:	9befc0ef          	jal	ra,80000ca0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ae6:	409c                	lw	a5,0(s1)
    80004ae8:	ef89                	bnez	a5,80004b02 <holdingsleep+0x36>
    80004aea:	4481                	li	s1,0
  release(&lk->lk);
    80004aec:	854a                	mv	a0,s2
    80004aee:	a4afc0ef          	jal	ra,80000d38 <release>
  return r;
}
    80004af2:	8526                	mv	a0,s1
    80004af4:	70a2                	ld	ra,40(sp)
    80004af6:	7402                	ld	s0,32(sp)
    80004af8:	64e2                	ld	s1,24(sp)
    80004afa:	6942                	ld	s2,16(sp)
    80004afc:	69a2                	ld	s3,8(sp)
    80004afe:	6145                	addi	sp,sp,48
    80004b00:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b02:	0284a983          	lw	s3,40(s1)
    80004b06:	84afd0ef          	jal	ra,80001b50 <myproc>
    80004b0a:	5904                	lw	s1,48(a0)
    80004b0c:	413484b3          	sub	s1,s1,s3
    80004b10:	0014b493          	seqz	s1,s1
    80004b14:	bfe1                	j	80004aec <holdingsleep+0x20>

0000000080004b16 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b16:	1141                	addi	sp,sp,-16
    80004b18:	e406                	sd	ra,8(sp)
    80004b1a:	e022                	sd	s0,0(sp)
    80004b1c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b1e:	00004597          	auipc	a1,0x4
    80004b22:	b8a58593          	addi	a1,a1,-1142 # 800086a8 <syscalls+0x2b0>
    80004b26:	00246517          	auipc	a0,0x246
    80004b2a:	fe250513          	addi	a0,a0,-30 # 8024ab08 <ftable>
    80004b2e:	8f2fc0ef          	jal	ra,80000c20 <initlock>
}
    80004b32:	60a2                	ld	ra,8(sp)
    80004b34:	6402                	ld	s0,0(sp)
    80004b36:	0141                	addi	sp,sp,16
    80004b38:	8082                	ret

0000000080004b3a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b3a:	1101                	addi	sp,sp,-32
    80004b3c:	ec06                	sd	ra,24(sp)
    80004b3e:	e822                	sd	s0,16(sp)
    80004b40:	e426                	sd	s1,8(sp)
    80004b42:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b44:	00246517          	auipc	a0,0x246
    80004b48:	fc450513          	addi	a0,a0,-60 # 8024ab08 <ftable>
    80004b4c:	954fc0ef          	jal	ra,80000ca0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b50:	00246497          	auipc	s1,0x246
    80004b54:	fd048493          	addi	s1,s1,-48 # 8024ab20 <ftable+0x18>
    80004b58:	00247717          	auipc	a4,0x247
    80004b5c:	f6870713          	addi	a4,a4,-152 # 8024bac0 <disk>
    if(f->ref == 0){
    80004b60:	40dc                	lw	a5,4(s1)
    80004b62:	cf89                	beqz	a5,80004b7c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b64:	02848493          	addi	s1,s1,40
    80004b68:	fee49ce3          	bne	s1,a4,80004b60 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b6c:	00246517          	auipc	a0,0x246
    80004b70:	f9c50513          	addi	a0,a0,-100 # 8024ab08 <ftable>
    80004b74:	9c4fc0ef          	jal	ra,80000d38 <release>
  return 0;
    80004b78:	4481                	li	s1,0
    80004b7a:	a809                	j	80004b8c <filealloc+0x52>
      f->ref = 1;
    80004b7c:	4785                	li	a5,1
    80004b7e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b80:	00246517          	auipc	a0,0x246
    80004b84:	f8850513          	addi	a0,a0,-120 # 8024ab08 <ftable>
    80004b88:	9b0fc0ef          	jal	ra,80000d38 <release>
}
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	60e2                	ld	ra,24(sp)
    80004b90:	6442                	ld	s0,16(sp)
    80004b92:	64a2                	ld	s1,8(sp)
    80004b94:	6105                	addi	sp,sp,32
    80004b96:	8082                	ret

0000000080004b98 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b98:	1101                	addi	sp,sp,-32
    80004b9a:	ec06                	sd	ra,24(sp)
    80004b9c:	e822                	sd	s0,16(sp)
    80004b9e:	e426                	sd	s1,8(sp)
    80004ba0:	1000                	addi	s0,sp,32
    80004ba2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ba4:	00246517          	auipc	a0,0x246
    80004ba8:	f6450513          	addi	a0,a0,-156 # 8024ab08 <ftable>
    80004bac:	8f4fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004bb0:	40dc                	lw	a5,4(s1)
    80004bb2:	02f05063          	blez	a5,80004bd2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004bb6:	2785                	addiw	a5,a5,1
    80004bb8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004bba:	00246517          	auipc	a0,0x246
    80004bbe:	f4e50513          	addi	a0,a0,-178 # 8024ab08 <ftable>
    80004bc2:	976fc0ef          	jal	ra,80000d38 <release>
  return f;
}
    80004bc6:	8526                	mv	a0,s1
    80004bc8:	60e2                	ld	ra,24(sp)
    80004bca:	6442                	ld	s0,16(sp)
    80004bcc:	64a2                	ld	s1,8(sp)
    80004bce:	6105                	addi	sp,sp,32
    80004bd0:	8082                	ret
    panic("filedup");
    80004bd2:	00004517          	auipc	a0,0x4
    80004bd6:	ade50513          	addi	a0,a0,-1314 # 800086b0 <syscalls+0x2b8>
    80004bda:	baffb0ef          	jal	ra,80000788 <panic>

0000000080004bde <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004bde:	7139                	addi	sp,sp,-64
    80004be0:	fc06                	sd	ra,56(sp)
    80004be2:	f822                	sd	s0,48(sp)
    80004be4:	f426                	sd	s1,40(sp)
    80004be6:	f04a                	sd	s2,32(sp)
    80004be8:	ec4e                	sd	s3,24(sp)
    80004bea:	e852                	sd	s4,16(sp)
    80004bec:	e456                	sd	s5,8(sp)
    80004bee:	0080                	addi	s0,sp,64
    80004bf0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bf2:	00246517          	auipc	a0,0x246
    80004bf6:	f1650513          	addi	a0,a0,-234 # 8024ab08 <ftable>
    80004bfa:	8a6fc0ef          	jal	ra,80000ca0 <acquire>
  if(f->ref < 1)
    80004bfe:	40dc                	lw	a5,4(s1)
    80004c00:	04f05963          	blez	a5,80004c52 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004c04:	37fd                	addiw	a5,a5,-1
    80004c06:	0007871b          	sext.w	a4,a5
    80004c0a:	c0dc                	sw	a5,4(s1)
    80004c0c:	04e04963          	bgtz	a4,80004c5e <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c10:	0004a903          	lw	s2,0(s1)
    80004c14:	0094ca83          	lbu	s5,9(s1)
    80004c18:	0104ba03          	ld	s4,16(s1)
    80004c1c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c20:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c24:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c28:	00246517          	auipc	a0,0x246
    80004c2c:	ee050513          	addi	a0,a0,-288 # 8024ab08 <ftable>
    80004c30:	908fc0ef          	jal	ra,80000d38 <release>

  if(ff.type == FD_PIPE){
    80004c34:	4785                	li	a5,1
    80004c36:	04f90363          	beq	s2,a5,80004c7c <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c3a:	3979                	addiw	s2,s2,-2
    80004c3c:	4785                	li	a5,1
    80004c3e:	0327e663          	bltu	a5,s2,80004c6a <fileclose+0x8c>
    begin_op();
    80004c42:	b93ff0ef          	jal	ra,800047d4 <begin_op>
    iput(ff.ip);
    80004c46:	854e                	mv	a0,s3
    80004c48:	b22ff0ef          	jal	ra,80003f6a <iput>
    end_op();
    80004c4c:	bf7ff0ef          	jal	ra,80004842 <end_op>
    80004c50:	a829                	j	80004c6a <fileclose+0x8c>
    panic("fileclose");
    80004c52:	00004517          	auipc	a0,0x4
    80004c56:	a6650513          	addi	a0,a0,-1434 # 800086b8 <syscalls+0x2c0>
    80004c5a:	b2ffb0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    80004c5e:	00246517          	auipc	a0,0x246
    80004c62:	eaa50513          	addi	a0,a0,-342 # 8024ab08 <ftable>
    80004c66:	8d2fc0ef          	jal	ra,80000d38 <release>
  }
}
    80004c6a:	70e2                	ld	ra,56(sp)
    80004c6c:	7442                	ld	s0,48(sp)
    80004c6e:	74a2                	ld	s1,40(sp)
    80004c70:	7902                	ld	s2,32(sp)
    80004c72:	69e2                	ld	s3,24(sp)
    80004c74:	6a42                	ld	s4,16(sp)
    80004c76:	6aa2                	ld	s5,8(sp)
    80004c78:	6121                	addi	sp,sp,64
    80004c7a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c7c:	85d6                	mv	a1,s5
    80004c7e:	8552                	mv	a0,s4
    80004c80:	2ec000ef          	jal	ra,80004f6c <pipeclose>
    80004c84:	b7dd                	j	80004c6a <fileclose+0x8c>

0000000080004c86 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c86:	715d                	addi	sp,sp,-80
    80004c88:	e486                	sd	ra,72(sp)
    80004c8a:	e0a2                	sd	s0,64(sp)
    80004c8c:	fc26                	sd	s1,56(sp)
    80004c8e:	f84a                	sd	s2,48(sp)
    80004c90:	f44e                	sd	s3,40(sp)
    80004c92:	0880                	addi	s0,sp,80
    80004c94:	84aa                	mv	s1,a0
    80004c96:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c98:	eb9fc0ef          	jal	ra,80001b50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c9c:	409c                	lw	a5,0(s1)
    80004c9e:	37f9                	addiw	a5,a5,-2
    80004ca0:	4705                	li	a4,1
    80004ca2:	02f76f63          	bltu	a4,a5,80004ce0 <filestat+0x5a>
    80004ca6:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ca8:	6c88                	ld	a0,24(s1)
    80004caa:	942ff0ef          	jal	ra,80003dec <ilock>
    stati(f->ip, &st);
    80004cae:	fb840593          	addi	a1,s0,-72
    80004cb2:	6c88                	ld	a0,24(s1)
    80004cb4:	c9aff0ef          	jal	ra,8000414e <stati>
    iunlock(f->ip);
    80004cb8:	6c88                	ld	a0,24(s1)
    80004cba:	9dcff0ef          	jal	ra,80003e96 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cbe:	46e1                	li	a3,24
    80004cc0:	fb840613          	addi	a2,s0,-72
    80004cc4:	85ce                	mv	a1,s3
    80004cc6:	05093503          	ld	a0,80(s2)
    80004cca:	aa9fc0ef          	jal	ra,80001772 <copyout>
    80004cce:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004cd2:	60a6                	ld	ra,72(sp)
    80004cd4:	6406                	ld	s0,64(sp)
    80004cd6:	74e2                	ld	s1,56(sp)
    80004cd8:	7942                	ld	s2,48(sp)
    80004cda:	79a2                	ld	s3,40(sp)
    80004cdc:	6161                	addi	sp,sp,80
    80004cde:	8082                	ret
  return -1;
    80004ce0:	557d                	li	a0,-1
    80004ce2:	bfc5                	j	80004cd2 <filestat+0x4c>

0000000080004ce4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ce4:	7179                	addi	sp,sp,-48
    80004ce6:	f406                	sd	ra,40(sp)
    80004ce8:	f022                	sd	s0,32(sp)
    80004cea:	ec26                	sd	s1,24(sp)
    80004cec:	e84a                	sd	s2,16(sp)
    80004cee:	e44e                	sd	s3,8(sp)
    80004cf0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cf2:	00854783          	lbu	a5,8(a0)
    80004cf6:	cbc1                	beqz	a5,80004d86 <fileread+0xa2>
    80004cf8:	84aa                	mv	s1,a0
    80004cfa:	89ae                	mv	s3,a1
    80004cfc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cfe:	411c                	lw	a5,0(a0)
    80004d00:	4705                	li	a4,1
    80004d02:	04e78363          	beq	a5,a4,80004d48 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d06:	470d                	li	a4,3
    80004d08:	04e78563          	beq	a5,a4,80004d52 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d0c:	4709                	li	a4,2
    80004d0e:	06e79663          	bne	a5,a4,80004d7a <fileread+0x96>
    ilock(f->ip);
    80004d12:	6d08                	ld	a0,24(a0)
    80004d14:	8d8ff0ef          	jal	ra,80003dec <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d18:	874a                	mv	a4,s2
    80004d1a:	5094                	lw	a3,32(s1)
    80004d1c:	864e                	mv	a2,s3
    80004d1e:	4585                	li	a1,1
    80004d20:	6c88                	ld	a0,24(s1)
    80004d22:	c56ff0ef          	jal	ra,80004178 <readi>
    80004d26:	892a                	mv	s2,a0
    80004d28:	00a05563          	blez	a0,80004d32 <fileread+0x4e>
      f->off += r;
    80004d2c:	509c                	lw	a5,32(s1)
    80004d2e:	9fa9                	addw	a5,a5,a0
    80004d30:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d32:	6c88                	ld	a0,24(s1)
    80004d34:	962ff0ef          	jal	ra,80003e96 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d38:	854a                	mv	a0,s2
    80004d3a:	70a2                	ld	ra,40(sp)
    80004d3c:	7402                	ld	s0,32(sp)
    80004d3e:	64e2                	ld	s1,24(sp)
    80004d40:	6942                	ld	s2,16(sp)
    80004d42:	69a2                	ld	s3,8(sp)
    80004d44:	6145                	addi	sp,sp,48
    80004d46:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d48:	6908                	ld	a0,16(a0)
    80004d4a:	34e000ef          	jal	ra,80005098 <piperead>
    80004d4e:	892a                	mv	s2,a0
    80004d50:	b7e5                	j	80004d38 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d52:	02451783          	lh	a5,36(a0)
    80004d56:	03079693          	slli	a3,a5,0x30
    80004d5a:	92c1                	srli	a3,a3,0x30
    80004d5c:	4725                	li	a4,9
    80004d5e:	02d76663          	bltu	a4,a3,80004d8a <fileread+0xa6>
    80004d62:	0792                	slli	a5,a5,0x4
    80004d64:	00246717          	auipc	a4,0x246
    80004d68:	d0470713          	addi	a4,a4,-764 # 8024aa68 <devsw>
    80004d6c:	97ba                	add	a5,a5,a4
    80004d6e:	639c                	ld	a5,0(a5)
    80004d70:	cf99                	beqz	a5,80004d8e <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004d72:	4505                	li	a0,1
    80004d74:	9782                	jalr	a5
    80004d76:	892a                	mv	s2,a0
    80004d78:	b7c1                	j	80004d38 <fileread+0x54>
    panic("fileread");
    80004d7a:	00004517          	auipc	a0,0x4
    80004d7e:	94e50513          	addi	a0,a0,-1714 # 800086c8 <syscalls+0x2d0>
    80004d82:	a07fb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004d86:	597d                	li	s2,-1
    80004d88:	bf45                	j	80004d38 <fileread+0x54>
      return -1;
    80004d8a:	597d                	li	s2,-1
    80004d8c:	b775                	j	80004d38 <fileread+0x54>
    80004d8e:	597d                	li	s2,-1
    80004d90:	b765                	j	80004d38 <fileread+0x54>

0000000080004d92 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d92:	715d                	addi	sp,sp,-80
    80004d94:	e486                	sd	ra,72(sp)
    80004d96:	e0a2                	sd	s0,64(sp)
    80004d98:	fc26                	sd	s1,56(sp)
    80004d9a:	f84a                	sd	s2,48(sp)
    80004d9c:	f44e                	sd	s3,40(sp)
    80004d9e:	f052                	sd	s4,32(sp)
    80004da0:	ec56                	sd	s5,24(sp)
    80004da2:	e85a                	sd	s6,16(sp)
    80004da4:	e45e                	sd	s7,8(sp)
    80004da6:	e062                	sd	s8,0(sp)
    80004da8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004daa:	00954783          	lbu	a5,9(a0)
    80004dae:	0e078863          	beqz	a5,80004e9e <filewrite+0x10c>
    80004db2:	892a                	mv	s2,a0
    80004db4:	8b2e                	mv	s6,a1
    80004db6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004db8:	411c                	lw	a5,0(a0)
    80004dba:	4705                	li	a4,1
    80004dbc:	02e78263          	beq	a5,a4,80004de0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dc0:	470d                	li	a4,3
    80004dc2:	02e78463          	beq	a5,a4,80004dea <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dc6:	4709                	li	a4,2
    80004dc8:	0ce79563          	bne	a5,a4,80004e92 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dcc:	0ac05163          	blez	a2,80004e6e <filewrite+0xdc>
    int i = 0;
    80004dd0:	4981                	li	s3,0
    80004dd2:	6b85                	lui	s7,0x1
    80004dd4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004dd8:	6c05                	lui	s8,0x1
    80004dda:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004dde:	a041                	j	80004e5e <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004de0:	6908                	ld	a0,16(a0)
    80004de2:	1e2000ef          	jal	ra,80004fc4 <pipewrite>
    80004de6:	8a2a                	mv	s4,a0
    80004de8:	a071                	j	80004e74 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dea:	02451783          	lh	a5,36(a0)
    80004dee:	03079693          	slli	a3,a5,0x30
    80004df2:	92c1                	srli	a3,a3,0x30
    80004df4:	4725                	li	a4,9
    80004df6:	0ad76663          	bltu	a4,a3,80004ea2 <filewrite+0x110>
    80004dfa:	0792                	slli	a5,a5,0x4
    80004dfc:	00246717          	auipc	a4,0x246
    80004e00:	c6c70713          	addi	a4,a4,-916 # 8024aa68 <devsw>
    80004e04:	97ba                	add	a5,a5,a4
    80004e06:	679c                	ld	a5,8(a5)
    80004e08:	cfd9                	beqz	a5,80004ea6 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004e0a:	4505                	li	a0,1
    80004e0c:	9782                	jalr	a5
    80004e0e:	8a2a                	mv	s4,a0
    80004e10:	a095                	j	80004e74 <filewrite+0xe2>
    80004e12:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e16:	9bfff0ef          	jal	ra,800047d4 <begin_op>
      ilock(f->ip);
    80004e1a:	01893503          	ld	a0,24(s2)
    80004e1e:	fcffe0ef          	jal	ra,80003dec <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e22:	8756                	mv	a4,s5
    80004e24:	02092683          	lw	a3,32(s2)
    80004e28:	01698633          	add	a2,s3,s6
    80004e2c:	4585                	li	a1,1
    80004e2e:	01893503          	ld	a0,24(s2)
    80004e32:	c2aff0ef          	jal	ra,8000425c <writei>
    80004e36:	84aa                	mv	s1,a0
    80004e38:	00a05763          	blez	a0,80004e46 <filewrite+0xb4>
        f->off += r;
    80004e3c:	02092783          	lw	a5,32(s2)
    80004e40:	9fa9                	addw	a5,a5,a0
    80004e42:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e46:	01893503          	ld	a0,24(s2)
    80004e4a:	84cff0ef          	jal	ra,80003e96 <iunlock>
      end_op();
    80004e4e:	9f5ff0ef          	jal	ra,80004842 <end_op>

      if(r != n1){
    80004e52:	009a9f63          	bne	s5,s1,80004e70 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004e56:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e5a:	0149db63          	bge	s3,s4,80004e70 <filewrite+0xde>
      int n1 = n - i;
    80004e5e:	413a04bb          	subw	s1,s4,s3
    80004e62:	0004879b          	sext.w	a5,s1
    80004e66:	fafbd6e3          	bge	s7,a5,80004e12 <filewrite+0x80>
    80004e6a:	84e2                	mv	s1,s8
    80004e6c:	b75d                	j	80004e12 <filewrite+0x80>
    int i = 0;
    80004e6e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e70:	013a1f63          	bne	s4,s3,80004e8e <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e74:	8552                	mv	a0,s4
    80004e76:	60a6                	ld	ra,72(sp)
    80004e78:	6406                	ld	s0,64(sp)
    80004e7a:	74e2                	ld	s1,56(sp)
    80004e7c:	7942                	ld	s2,48(sp)
    80004e7e:	79a2                	ld	s3,40(sp)
    80004e80:	7a02                	ld	s4,32(sp)
    80004e82:	6ae2                	ld	s5,24(sp)
    80004e84:	6b42                	ld	s6,16(sp)
    80004e86:	6ba2                	ld	s7,8(sp)
    80004e88:	6c02                	ld	s8,0(sp)
    80004e8a:	6161                	addi	sp,sp,80
    80004e8c:	8082                	ret
    ret = (i == n ? n : -1);
    80004e8e:	5a7d                	li	s4,-1
    80004e90:	b7d5                	j	80004e74 <filewrite+0xe2>
    panic("filewrite");
    80004e92:	00004517          	auipc	a0,0x4
    80004e96:	84650513          	addi	a0,a0,-1978 # 800086d8 <syscalls+0x2e0>
    80004e9a:	8effb0ef          	jal	ra,80000788 <panic>
    return -1;
    80004e9e:	5a7d                	li	s4,-1
    80004ea0:	bfd1                	j	80004e74 <filewrite+0xe2>
      return -1;
    80004ea2:	5a7d                	li	s4,-1
    80004ea4:	bfc1                	j	80004e74 <filewrite+0xe2>
    80004ea6:	5a7d                	li	s4,-1
    80004ea8:	b7f1                	j	80004e74 <filewrite+0xe2>

0000000080004eaa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004eaa:	7179                	addi	sp,sp,-48
    80004eac:	f406                	sd	ra,40(sp)
    80004eae:	f022                	sd	s0,32(sp)
    80004eb0:	ec26                	sd	s1,24(sp)
    80004eb2:	e84a                	sd	s2,16(sp)
    80004eb4:	e44e                	sd	s3,8(sp)
    80004eb6:	e052                	sd	s4,0(sp)
    80004eb8:	1800                	addi	s0,sp,48
    80004eba:	84aa                	mv	s1,a0
    80004ebc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ebe:	0005b023          	sd	zero,0(a1)
    80004ec2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ec6:	c75ff0ef          	jal	ra,80004b3a <filealloc>
    80004eca:	e088                	sd	a0,0(s1)
    80004ecc:	cd35                	beqz	a0,80004f48 <pipealloc+0x9e>
    80004ece:	c6dff0ef          	jal	ra,80004b3a <filealloc>
    80004ed2:	00aa3023          	sd	a0,0(s4)
    80004ed6:	c52d                	beqz	a0,80004f40 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ed8:	cd3fb0ef          	jal	ra,80000baa <kalloc>
    80004edc:	892a                	mv	s2,a0
    80004ede:	cd31                	beqz	a0,80004f3a <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004ee0:	4985                	li	s3,1
    80004ee2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ee6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004eea:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004eee:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ef2:	00003597          	auipc	a1,0x3
    80004ef6:	7f658593          	addi	a1,a1,2038 # 800086e8 <syscalls+0x2f0>
    80004efa:	d27fb0ef          	jal	ra,80000c20 <initlock>
  (*f0)->type = FD_PIPE;
    80004efe:	609c                	ld	a5,0(s1)
    80004f00:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f04:	609c                	ld	a5,0(s1)
    80004f06:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f0a:	609c                	ld	a5,0(s1)
    80004f0c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f10:	609c                	ld	a5,0(s1)
    80004f12:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f16:	000a3783          	ld	a5,0(s4)
    80004f1a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f1e:	000a3783          	ld	a5,0(s4)
    80004f22:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f26:	000a3783          	ld	a5,0(s4)
    80004f2a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f2e:	000a3783          	ld	a5,0(s4)
    80004f32:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f36:	4501                	li	a0,0
    80004f38:	a005                	j	80004f58 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f3a:	6088                	ld	a0,0(s1)
    80004f3c:	e501                	bnez	a0,80004f44 <pipealloc+0x9a>
    80004f3e:	a029                	j	80004f48 <pipealloc+0x9e>
    80004f40:	6088                	ld	a0,0(s1)
    80004f42:	c11d                	beqz	a0,80004f68 <pipealloc+0xbe>
    fileclose(*f0);
    80004f44:	c9bff0ef          	jal	ra,80004bde <fileclose>
  if(*f1)
    80004f48:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f4c:	557d                	li	a0,-1
  if(*f1)
    80004f4e:	c789                	beqz	a5,80004f58 <pipealloc+0xae>
    fileclose(*f1);
    80004f50:	853e                	mv	a0,a5
    80004f52:	c8dff0ef          	jal	ra,80004bde <fileclose>
  return -1;
    80004f56:	557d                	li	a0,-1
}
    80004f58:	70a2                	ld	ra,40(sp)
    80004f5a:	7402                	ld	s0,32(sp)
    80004f5c:	64e2                	ld	s1,24(sp)
    80004f5e:	6942                	ld	s2,16(sp)
    80004f60:	69a2                	ld	s3,8(sp)
    80004f62:	6a02                	ld	s4,0(sp)
    80004f64:	6145                	addi	sp,sp,48
    80004f66:	8082                	ret
  return -1;
    80004f68:	557d                	li	a0,-1
    80004f6a:	b7fd                	j	80004f58 <pipealloc+0xae>

0000000080004f6c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f6c:	1101                	addi	sp,sp,-32
    80004f6e:	ec06                	sd	ra,24(sp)
    80004f70:	e822                	sd	s0,16(sp)
    80004f72:	e426                	sd	s1,8(sp)
    80004f74:	e04a                	sd	s2,0(sp)
    80004f76:	1000                	addi	s0,sp,32
    80004f78:	84aa                	mv	s1,a0
    80004f7a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f7c:	d25fb0ef          	jal	ra,80000ca0 <acquire>
  if(writable){
    80004f80:	02090763          	beqz	s2,80004fae <pipeclose+0x42>
    pi->writeopen = 0;
    80004f84:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f88:	21848513          	addi	a0,s1,536
    80004f8c:	d00fd0ef          	jal	ra,8000248c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f90:	2204b783          	ld	a5,544(s1)
    80004f94:	e785                	bnez	a5,80004fbc <pipeclose+0x50>
    release(&pi->lock);
    80004f96:	8526                	mv	a0,s1
    80004f98:	da1fb0ef          	jal	ra,80000d38 <release>
    kfree((char*)pi);
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	addfb0ef          	jal	ra,80000a7a <kfree>
  } else
    release(&pi->lock);
}
    80004fa2:	60e2                	ld	ra,24(sp)
    80004fa4:	6442                	ld	s0,16(sp)
    80004fa6:	64a2                	ld	s1,8(sp)
    80004fa8:	6902                	ld	s2,0(sp)
    80004faa:	6105                	addi	sp,sp,32
    80004fac:	8082                	ret
    pi->readopen = 0;
    80004fae:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fb2:	21c48513          	addi	a0,s1,540
    80004fb6:	cd6fd0ef          	jal	ra,8000248c <wakeup>
    80004fba:	bfd9                	j	80004f90 <pipeclose+0x24>
    release(&pi->lock);
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	d7bfb0ef          	jal	ra,80000d38 <release>
}
    80004fc2:	b7c5                	j	80004fa2 <pipeclose+0x36>

0000000080004fc4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004fc4:	711d                	addi	sp,sp,-96
    80004fc6:	ec86                	sd	ra,88(sp)
    80004fc8:	e8a2                	sd	s0,80(sp)
    80004fca:	e4a6                	sd	s1,72(sp)
    80004fcc:	e0ca                	sd	s2,64(sp)
    80004fce:	fc4e                	sd	s3,56(sp)
    80004fd0:	f852                	sd	s4,48(sp)
    80004fd2:	f456                	sd	s5,40(sp)
    80004fd4:	f05a                	sd	s6,32(sp)
    80004fd6:	ec5e                	sd	s7,24(sp)
    80004fd8:	e862                	sd	s8,16(sp)
    80004fda:	1080                	addi	s0,sp,96
    80004fdc:	84aa                	mv	s1,a0
    80004fde:	8aae                	mv	s5,a1
    80004fe0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fe2:	b6ffc0ef          	jal	ra,80001b50 <myproc>
    80004fe6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004fe8:	8526                	mv	a0,s1
    80004fea:	cb7fb0ef          	jal	ra,80000ca0 <acquire>
  while(i < n){
    80004fee:	09405c63          	blez	s4,80005086 <pipewrite+0xc2>
  int i = 0;
    80004ff2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ff4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ff6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ffa:	21c48b93          	addi	s7,s1,540
    80004ffe:	a81d                	j	80005034 <pipewrite+0x70>
      release(&pi->lock);
    80005000:	8526                	mv	a0,s1
    80005002:	d37fb0ef          	jal	ra,80000d38 <release>
      return -1;
    80005006:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005008:	854a                	mv	a0,s2
    8000500a:	60e6                	ld	ra,88(sp)
    8000500c:	6446                	ld	s0,80(sp)
    8000500e:	64a6                	ld	s1,72(sp)
    80005010:	6906                	ld	s2,64(sp)
    80005012:	79e2                	ld	s3,56(sp)
    80005014:	7a42                	ld	s4,48(sp)
    80005016:	7aa2                	ld	s5,40(sp)
    80005018:	7b02                	ld	s6,32(sp)
    8000501a:	6be2                	ld	s7,24(sp)
    8000501c:	6c42                	ld	s8,16(sp)
    8000501e:	6125                	addi	sp,sp,96
    80005020:	8082                	ret
      wakeup(&pi->nread);
    80005022:	8562                	mv	a0,s8
    80005024:	c68fd0ef          	jal	ra,8000248c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005028:	85a6                	mv	a1,s1
    8000502a:	855e                	mv	a0,s7
    8000502c:	c14fd0ef          	jal	ra,80002440 <sleep>
  while(i < n){
    80005030:	05495c63          	bge	s2,s4,80005088 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80005034:	2204a783          	lw	a5,544(s1)
    80005038:	d7e1                	beqz	a5,80005000 <pipewrite+0x3c>
    8000503a:	854e                	mv	a0,s3
    8000503c:	e3cfd0ef          	jal	ra,80002678 <killed>
    80005040:	f161                	bnez	a0,80005000 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005042:	2184a783          	lw	a5,536(s1)
    80005046:	21c4a703          	lw	a4,540(s1)
    8000504a:	2007879b          	addiw	a5,a5,512
    8000504e:	fcf70ae3          	beq	a4,a5,80005022 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005052:	4685                	li	a3,1
    80005054:	01590633          	add	a2,s2,s5
    80005058:	faf40593          	addi	a1,s0,-81
    8000505c:	0509b503          	ld	a0,80(s3)
    80005060:	80dfc0ef          	jal	ra,8000186c <copyin>
    80005064:	03650263          	beq	a0,s6,80005088 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005068:	21c4a783          	lw	a5,540(s1)
    8000506c:	0017871b          	addiw	a4,a5,1
    80005070:	20e4ae23          	sw	a4,540(s1)
    80005074:	1ff7f793          	andi	a5,a5,511
    80005078:	97a6                	add	a5,a5,s1
    8000507a:	faf44703          	lbu	a4,-81(s0)
    8000507e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005082:	2905                	addiw	s2,s2,1
    80005084:	b775                	j	80005030 <pipewrite+0x6c>
  int i = 0;
    80005086:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005088:	21848513          	addi	a0,s1,536
    8000508c:	c00fd0ef          	jal	ra,8000248c <wakeup>
  release(&pi->lock);
    80005090:	8526                	mv	a0,s1
    80005092:	ca7fb0ef          	jal	ra,80000d38 <release>
  return i;
    80005096:	bf8d                	j	80005008 <pipewrite+0x44>

0000000080005098 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005098:	715d                	addi	sp,sp,-80
    8000509a:	e486                	sd	ra,72(sp)
    8000509c:	e0a2                	sd	s0,64(sp)
    8000509e:	fc26                	sd	s1,56(sp)
    800050a0:	f84a                	sd	s2,48(sp)
    800050a2:	f44e                	sd	s3,40(sp)
    800050a4:	f052                	sd	s4,32(sp)
    800050a6:	ec56                	sd	s5,24(sp)
    800050a8:	e85a                	sd	s6,16(sp)
    800050aa:	0880                	addi	s0,sp,80
    800050ac:	84aa                	mv	s1,a0
    800050ae:	892e                	mv	s2,a1
    800050b0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050b2:	a9ffc0ef          	jal	ra,80001b50 <myproc>
    800050b6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050b8:	8526                	mv	a0,s1
    800050ba:	be7fb0ef          	jal	ra,80000ca0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050be:	2184a703          	lw	a4,536(s1)
    800050c2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050c6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050ca:	02f71363          	bne	a4,a5,800050f0 <piperead+0x58>
    800050ce:	2244a783          	lw	a5,548(s1)
    800050d2:	cf99                	beqz	a5,800050f0 <piperead+0x58>
    if(killed(pr)){
    800050d4:	8552                	mv	a0,s4
    800050d6:	da2fd0ef          	jal	ra,80002678 <killed>
    800050da:	e151                	bnez	a0,8000515e <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050dc:	85a6                	mv	a1,s1
    800050de:	854e                	mv	a0,s3
    800050e0:	b60fd0ef          	jal	ra,80002440 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050e4:	2184a703          	lw	a4,536(s1)
    800050e8:	21c4a783          	lw	a5,540(s1)
    800050ec:	fef701e3          	beq	a4,a5,800050ce <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050f0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800050f2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050f4:	05505363          	blez	s5,8000513a <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    800050f8:	2184a783          	lw	a5,536(s1)
    800050fc:	21c4a703          	lw	a4,540(s1)
    80005100:	02f70d63          	beq	a4,a5,8000513a <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80005104:	1ff7f793          	andi	a5,a5,511
    80005108:	97a6                	add	a5,a5,s1
    8000510a:	0187c783          	lbu	a5,24(a5)
    8000510e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005112:	4685                	li	a3,1
    80005114:	fbf40613          	addi	a2,s0,-65
    80005118:	85ca                	mv	a1,s2
    8000511a:	050a3503          	ld	a0,80(s4)
    8000511e:	e54fc0ef          	jal	ra,80001772 <copyout>
    80005122:	05650363          	beq	a0,s6,80005168 <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005126:	2184a783          	lw	a5,536(s1)
    8000512a:	2785                	addiw	a5,a5,1
    8000512c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005130:	2985                	addiw	s3,s3,1
    80005132:	0905                	addi	s2,s2,1
    80005134:	fd3a92e3          	bne	s5,s3,800050f8 <piperead+0x60>
    80005138:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000513a:	21c48513          	addi	a0,s1,540
    8000513e:	b4efd0ef          	jal	ra,8000248c <wakeup>
  release(&pi->lock);
    80005142:	8526                	mv	a0,s1
    80005144:	bf5fb0ef          	jal	ra,80000d38 <release>
  return i;
}
    80005148:	854e                	mv	a0,s3
    8000514a:	60a6                	ld	ra,72(sp)
    8000514c:	6406                	ld	s0,64(sp)
    8000514e:	74e2                	ld	s1,56(sp)
    80005150:	7942                	ld	s2,48(sp)
    80005152:	79a2                	ld	s3,40(sp)
    80005154:	7a02                	ld	s4,32(sp)
    80005156:	6ae2                	ld	s5,24(sp)
    80005158:	6b42                	ld	s6,16(sp)
    8000515a:	6161                	addi	sp,sp,80
    8000515c:	8082                	ret
      release(&pi->lock);
    8000515e:	8526                	mv	a0,s1
    80005160:	bd9fb0ef          	jal	ra,80000d38 <release>
      return -1;
    80005164:	59fd                	li	s3,-1
    80005166:	b7cd                	j	80005148 <piperead+0xb0>
      if(i == 0)
    80005168:	fc0999e3          	bnez	s3,8000513a <piperead+0xa2>
        i = -1;
    8000516c:	89aa                	mv	s3,a0
    8000516e:	b7f1                	j	8000513a <piperead+0xa2>

0000000080005170 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80005170:	1141                	addi	sp,sp,-16
    80005172:	e422                	sd	s0,8(sp)
    80005174:	0800                	addi	s0,sp,16
    80005176:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005178:	8905                	andi	a0,a0,1
    8000517a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000517c:	8b89                	andi	a5,a5,2
    8000517e:	c399                	beqz	a5,80005184 <flags2perm+0x14>
      perm |= PTE_W;
    80005180:	00456513          	ori	a0,a0,4
    return perm;
}
    80005184:	6422                	ld	s0,8(sp)
    80005186:	0141                	addi	sp,sp,16
    80005188:	8082                	ret

000000008000518a <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000518a:	b5010113          	addi	sp,sp,-1200
    8000518e:	4a113423          	sd	ra,1192(sp)
    80005192:	4a813023          	sd	s0,1184(sp)
    80005196:	48913c23          	sd	s1,1176(sp)
    8000519a:	49213823          	sd	s2,1168(sp)
    8000519e:	49313423          	sd	s3,1160(sp)
    800051a2:	49413023          	sd	s4,1152(sp)
    800051a6:	47513c23          	sd	s5,1144(sp)
    800051aa:	47613823          	sd	s6,1136(sp)
    800051ae:	47713423          	sd	s7,1128(sp)
    800051b2:	47813023          	sd	s8,1120(sp)
    800051b6:	45913c23          	sd	s9,1112(sp)
    800051ba:	45a13823          	sd	s10,1104(sp)
    800051be:	45b13423          	sd	s11,1096(sp)
    800051c2:	4b010413          	addi	s0,sp,1200
    800051c6:	84aa                	mv	s1,a0
    800051c8:	b6a43023          	sd	a0,-1184(s0)
    800051cc:	b6b43423          	sd	a1,-1176(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051d0:	981fc0ef          	jal	ra,80001b50 <myproc>
    800051d4:	b6a43c23          	sd	a0,-1160(s0)

  begin_op();
    800051d8:	dfcff0ef          	jal	ra,800047d4 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800051dc:	8526                	mv	a0,s1
    800051de:	c02ff0ef          	jal	ra,800045e0 <namei>
    800051e2:	cd25                	beqz	a0,8000525a <kexec+0xd0>
    800051e4:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051e6:	c07fe0ef          	jal	ra,80003dec <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051ea:	04000713          	li	a4,64
    800051ee:	4681                	li	a3,0
    800051f0:	e5040613          	addi	a2,s0,-432
    800051f4:	4581                	li	a1,0
    800051f6:	8556                	mv	a0,s5
    800051f8:	f81fe0ef          	jal	ra,80004178 <readi>
    800051fc:	04000793          	li	a5,64
    80005200:	00f51a63          	bne	a0,a5,80005214 <kexec+0x8a>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80005204:	e5042703          	lw	a4,-432(s0)
    80005208:	464c47b7          	lui	a5,0x464c4
    8000520c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005210:	04f70963          	beq	a4,a5,80005262 <kexec+0xd8>
    memset(p->vmas, 0, sizeof(p->vmas));
    vma_release_all(p);
    proc_freepagetable(p->pagetable, p->sz);
  }
  if(ip){
    iunlockput(ip);
    80005214:	8556                	mv	a0,s5
    80005216:	dddfe0ef          	jal	ra,80003ff2 <iunlockput>
    end_op();
    8000521a:	e28ff0ef          	jal	ra,80004842 <end_op>
  }
  return -1;
    8000521e:	557d                	li	a0,-1
}
    80005220:	4a813083          	ld	ra,1192(sp)
    80005224:	4a013403          	ld	s0,1184(sp)
    80005228:	49813483          	ld	s1,1176(sp)
    8000522c:	49013903          	ld	s2,1168(sp)
    80005230:	48813983          	ld	s3,1160(sp)
    80005234:	48013a03          	ld	s4,1152(sp)
    80005238:	47813a83          	ld	s5,1144(sp)
    8000523c:	47013b03          	ld	s6,1136(sp)
    80005240:	46813b83          	ld	s7,1128(sp)
    80005244:	46013c03          	ld	s8,1120(sp)
    80005248:	45813c83          	ld	s9,1112(sp)
    8000524c:	45013d03          	ld	s10,1104(sp)
    80005250:	44813d83          	ld	s11,1096(sp)
    80005254:	4b010113          	addi	sp,sp,1200
    80005258:	8082                	ret
    end_op();
    8000525a:	de8ff0ef          	jal	ra,80004842 <end_op>
    return -1;
    8000525e:	557d                	li	a0,-1
    80005260:	b7c1                	j	80005220 <kexec+0x96>
  if((pagetable = proc_pagetable(p)) == 0)
    80005262:	b7843503          	ld	a0,-1160(s0)
    80005266:	bd9fc0ef          	jal	ra,80001e3e <proc_pagetable>
    8000526a:	8baa                	mv	s7,a0
    8000526c:	d545                	beqz	a0,80005214 <kexec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000526e:	e7042783          	lw	a5,-400(s0)
    80005272:	e8845703          	lhu	a4,-376(s0)
    80005276:	0e070d63          	beqz	a4,80005370 <kexec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000527a:	b6043823          	sd	zero,-1168(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000527e:	b8043423          	sd	zero,-1144(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005282:	6a05                	lui	s4,0x1
    80005284:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005288:	b4e43c23          	sd	a4,-1192(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000528c:	6d85                	lui	s11,0x1
    8000528e:	7d7d                	lui	s10,0xfffff
    80005290:	a09d                	j	800052f6 <kexec+0x16c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005292:	00003517          	auipc	a0,0x3
    80005296:	45e50513          	addi	a0,a0,1118 # 800086f0 <syscalls+0x2f8>
    8000529a:	ceefb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000529e:	874a                	mv	a4,s2
    800052a0:	009c86bb          	addw	a3,s9,s1
    800052a4:	4581                	li	a1,0
    800052a6:	8556                	mv	a0,s5
    800052a8:	ed1fe0ef          	jal	ra,80004178 <readi>
    800052ac:	2501                	sext.w	a0,a0
    800052ae:	0ea91f63          	bne	s2,a0,800053ac <kexec+0x222>
  for(i = 0; i < sz; i += PGSIZE){
    800052b2:	009d84bb          	addw	s1,s11,s1
    800052b6:	013d09bb          	addw	s3,s10,s3
    800052ba:	0364f063          	bgeu	s1,s6,800052da <kexec+0x150>
    pa = walkaddr(pagetable, va + i);
    800052be:	02049593          	slli	a1,s1,0x20
    800052c2:	9181                	srli	a1,a1,0x20
    800052c4:	95e2                	add	a1,a1,s8
    800052c6:	855e                	mv	a0,s7
    800052c8:	dcbfb0ef          	jal	ra,80001092 <walkaddr>
    800052cc:	862a                	mv	a2,a0
    if(pa == 0)
    800052ce:	d171                	beqz	a0,80005292 <kexec+0x108>
      n = PGSIZE;
    800052d0:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052d2:	fd49f6e3          	bgeu	s3,s4,8000529e <kexec+0x114>
      n = sz - i;
    800052d6:	894e                	mv	s2,s3
    800052d8:	b7d9                	j	8000529e <kexec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052da:	b8843783          	ld	a5,-1144(s0)
    800052de:	0017869b          	addiw	a3,a5,1
    800052e2:	b8d43423          	sd	a3,-1144(s0)
    800052e6:	b8043783          	ld	a5,-1152(s0)
    800052ea:	0387879b          	addiw	a5,a5,56
    800052ee:	e8845703          	lhu	a4,-376(s0)
    800052f2:	08e6d163          	bge	a3,a4,80005374 <kexec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052f6:	2781                	sext.w	a5,a5
    800052f8:	b8f43023          	sd	a5,-1152(s0)
    800052fc:	03800713          	li	a4,56
    80005300:	86be                	mv	a3,a5
    80005302:	e1840613          	addi	a2,s0,-488
    80005306:	4581                	li	a1,0
    80005308:	8556                	mv	a0,s5
    8000530a:	e6ffe0ef          	jal	ra,80004178 <readi>
    8000530e:	03800793          	li	a5,56
    80005312:	08f51d63          	bne	a0,a5,800053ac <kexec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    80005316:	e1842783          	lw	a5,-488(s0)
    8000531a:	4705                	li	a4,1
    8000531c:	fae79fe3          	bne	a5,a4,800052da <kexec+0x150>
    if(ph.memsz < ph.filesz)
    80005320:	e4043483          	ld	s1,-448(s0)
    80005324:	e3843783          	ld	a5,-456(s0)
    80005328:	08f4e263          	bltu	s1,a5,800053ac <kexec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000532c:	e2843783          	ld	a5,-472(s0)
    80005330:	94be                	add	s1,s1,a5
    80005332:	06f4ed63          	bltu	s1,a5,800053ac <kexec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    80005336:	b5843703          	ld	a4,-1192(s0)
    8000533a:	8ff9                	and	a5,a5,a4
    8000533c:	eba5                	bnez	a5,800053ac <kexec+0x222>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000533e:	e1c42503          	lw	a0,-484(s0)
    80005342:	e2fff0ef          	jal	ra,80005170 <flags2perm>
    80005346:	86aa                	mv	a3,a0
    80005348:	8626                	mv	a2,s1
    8000534a:	b7043583          	ld	a1,-1168(s0)
    8000534e:	855e                	mv	a0,s7
    80005350:	80cfc0ef          	jal	ra,8000135c <uvmalloc>
    80005354:	b6a43823          	sd	a0,-1168(s0)
    80005358:	c931                	beqz	a0,800053ac <kexec+0x222>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000535a:	e2843c03          	ld	s8,-472(s0)
    8000535e:	e2042c83          	lw	s9,-480(s0)
    80005362:	e3842b03          	lw	s6,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005366:	f60b0ae3          	beqz	s6,800052da <kexec+0x150>
    8000536a:	89da                	mv	s3,s6
    8000536c:	4481                	li	s1,0
    8000536e:	bf81                	j	800052be <kexec+0x134>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005370:	b6043823          	sd	zero,-1168(s0)
  iunlockput(ip);
    80005374:	8556                	mv	a0,s5
    80005376:	c7dfe0ef          	jal	ra,80003ff2 <iunlockput>
  end_op();
    8000537a:	cc8ff0ef          	jal	ra,80004842 <end_op>
  p = myproc();
    8000537e:	fd2fc0ef          	jal	ra,80001b50 <myproc>
    80005382:	b6a43c23          	sd	a0,-1160(s0)
  uint64 oldsz = p->sz;
    80005386:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000538a:	6785                	lui	a5,0x1
    8000538c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000538e:	b7043703          	ld	a4,-1168(s0)
    80005392:	00f705b3          	add	a1,a4,a5
    80005396:	77fd                	lui	a5,0xfffff
    80005398:	8dfd                	and	a1,a1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000539a:	4691                	li	a3,4
    8000539c:	6609                	lui	a2,0x2
    8000539e:	962e                	add	a2,a2,a1
    800053a0:	855e                	mv	a0,s7
    800053a2:	fbbfb0ef          	jal	ra,8000135c <uvmalloc>
    800053a6:	8b2a                	mv	s6,a0
  ip = 0;
    800053a8:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800053aa:	e121                	bnez	a0,800053ea <kexec+0x260>
    delete_shm_from_proc(p);
    800053ac:	b7843903          	ld	s2,-1160(s0)
    800053b0:	854a                	mv	a0,s2
    800053b2:	921fc0ef          	jal	ra,80001cd2 <delete_shm_from_proc>
    vma_unmap_pagetable(p->pagetable, p->vmas);
    800053b6:	16890493          	addi	s1,s2,360
    800053ba:	85a6                	mv	a1,s1
    800053bc:	05093503          	ld	a0,80(s2)
    800053c0:	b03fc0ef          	jal	ra,80001ec2 <vma_unmap_pagetable>
    memset(p->vmas, 0, sizeof(p->vmas));
    800053c4:	28000613          	li	a2,640
    800053c8:	4581                	li	a1,0
    800053ca:	8526                	mv	a0,s1
    800053cc:	9a9fb0ef          	jal	ra,80000d74 <memset>
    vma_release_all(p);
    800053d0:	854a                	mv	a0,s2
    800053d2:	97ffc0ef          	jal	ra,80001d50 <vma_release_all>
    proc_freepagetable(p->pagetable, p->sz);
    800053d6:	04893583          	ld	a1,72(s2)
    800053da:	05093503          	ld	a0,80(s2)
    800053de:	b2ffc0ef          	jal	ra,80001f0c <proc_freepagetable>
  if(ip){
    800053e2:	e20a99e3          	bnez	s5,80005214 <kexec+0x8a>
  return -1;
    800053e6:	557d                	li	a0,-1
    800053e8:	bd25                	j	80005220 <kexec+0x96>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800053ea:	75f9                	lui	a1,0xffffe
    800053ec:	95aa                	add	a1,a1,a0
    800053ee:	855e                	mv	a0,s7
    800053f0:	a1afc0ef          	jal	ra,8000160a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800053f4:	7c7d                	lui	s8,0xfffff
    800053f6:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800053f8:	b6843783          	ld	a5,-1176(s0)
    800053fc:	6388                	ld	a0,0(a5)
    800053fe:	c125                	beqz	a0,8000545e <kexec+0x2d4>
    80005400:	e9040993          	addi	s3,s0,-368
    80005404:	f9040a93          	addi	s5,s0,-112
  sp = sz;
    80005408:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000540a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000540c:	ae1fb0ef          	jal	ra,80000eec <strlen>
    80005410:	0015079b          	addiw	a5,a0,1
    80005414:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005418:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000541c:	11896d63          	bltu	s2,s8,80005536 <kexec+0x3ac>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005420:	b6843d03          	ld	s10,-1176(s0)
    80005424:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7fdaae50>
    80005428:	8552                	mv	a0,s4
    8000542a:	ac3fb0ef          	jal	ra,80000eec <strlen>
    8000542e:	0015069b          	addiw	a3,a0,1
    80005432:	8652                	mv	a2,s4
    80005434:	85ca                	mv	a1,s2
    80005436:	855e                	mv	a0,s7
    80005438:	b3afc0ef          	jal	ra,80001772 <copyout>
    8000543c:	0e054f63          	bltz	a0,8000553a <kexec+0x3b0>
    ustack[argc] = sp;
    80005440:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005444:	0485                	addi	s1,s1,1
    80005446:	008d0793          	addi	a5,s10,8
    8000544a:	b6f43423          	sd	a5,-1176(s0)
    8000544e:	008d3503          	ld	a0,8(s10)
    80005452:	c901                	beqz	a0,80005462 <kexec+0x2d8>
    if(argc >= MAXARG)
    80005454:	09a1                	addi	s3,s3,8
    80005456:	fb599be3          	bne	s3,s5,8000540c <kexec+0x282>
  ip = 0;
    8000545a:	4a81                	li	s5,0
    8000545c:	bf81                	j	800053ac <kexec+0x222>
  sp = sz;
    8000545e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005460:	4481                	li	s1,0
  ustack[argc] = 0;
    80005462:	00349793          	slli	a5,s1,0x3
    80005466:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdaade0>
    8000546a:	97a2                	add	a5,a5,s0
    8000546c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005470:	00148693          	addi	a3,s1,1
    80005474:	068e                	slli	a3,a3,0x3
    80005476:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000547a:	ff097913          	andi	s2,s2,-16
  ip = 0;
    8000547e:	4a81                	li	s5,0
  if(sp < stackbase)
    80005480:	f38966e3          	bltu	s2,s8,800053ac <kexec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005484:	e9040613          	addi	a2,s0,-368
    80005488:	85ca                	mv	a1,s2
    8000548a:	855e                	mv	a0,s7
    8000548c:	ae6fc0ef          	jal	ra,80001772 <copyout>
    80005490:	0a054763          	bltz	a0,8000553e <kexec+0x3b4>
  p->trapframe->a1 = sp;
    80005494:	b7843783          	ld	a5,-1160(s0)
    80005498:	6fbc                	ld	a5,88(a5)
    8000549a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000549e:	b6043783          	ld	a5,-1184(s0)
    800054a2:	0007c703          	lbu	a4,0(a5)
    800054a6:	cf11                	beqz	a4,800054c2 <kexec+0x338>
    800054a8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800054aa:	02f00693          	li	a3,47
    800054ae:	a039                	j	800054bc <kexec+0x332>
      last = s+1;
    800054b0:	b6f43023          	sd	a5,-1184(s0)
  for(last=s=path; *s; s++)
    800054b4:	0785                	addi	a5,a5,1
    800054b6:	fff7c703          	lbu	a4,-1(a5)
    800054ba:	c701                	beqz	a4,800054c2 <kexec+0x338>
    if(*s == '/')
    800054bc:	fed71ce3          	bne	a4,a3,800054b4 <kexec+0x32a>
    800054c0:	bfc5                	j	800054b0 <kexec+0x326>
  safestrcpy(p->name, last, sizeof(p->name));
    800054c2:	4641                	li	a2,16
    800054c4:	b6043583          	ld	a1,-1184(s0)
    800054c8:	b7843a83          	ld	s5,-1160(s0)
    800054cc:	158a8513          	addi	a0,s5,344
    800054d0:	9ebfb0ef          	jal	ra,80000eba <safestrcpy>
  memmove(oldvmas, p->vmas, sizeof(oldvmas));
    800054d4:	168a8a13          	addi	s4,s5,360
    800054d8:	28000613          	li	a2,640
    800054dc:	85d2                	mv	a1,s4
    800054de:	b9840513          	addi	a0,s0,-1128
    800054e2:	8effb0ef          	jal	ra,80000dd0 <memmove>
  oldpagetable = p->pagetable;
    800054e6:	050ab983          	ld	s3,80(s5)
  vma_release_all(p);
    800054ea:	8556                	mv	a0,s5
    800054ec:	865fc0ef          	jal	ra,80001d50 <vma_release_all>
  p->pagetable = pagetable;
    800054f0:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800054f4:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;
    800054f8:	058ab783          	ld	a5,88(s5)
    800054fc:	e6843703          	ld	a4,-408(s0)
    80005500:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;
    80005502:	058ab783          	ld	a5,88(s5)
    80005506:	0327b823          	sd	s2,48(a5)
  memset(p->vmas, 0, sizeof(p->vmas));
    8000550a:	28000613          	li	a2,640
    8000550e:	4581                	li	a1,0
    80005510:	8552                	mv	a0,s4
    80005512:	863fb0ef          	jal	ra,80000d74 <memset>
  delete_shm_from_vmas(oldvmas);
    80005516:	b9840513          	addi	a0,s0,-1128
    8000551a:	f3cfc0ef          	jal	ra,80001c56 <delete_shm_from_vmas>
  vma_unmap_pagetable(oldpagetable, oldvmas);
    8000551e:	b9840593          	addi	a1,s0,-1128
    80005522:	854e                	mv	a0,s3
    80005524:	99ffc0ef          	jal	ra,80001ec2 <vma_unmap_pagetable>
  proc_freepagetable(oldpagetable, oldsz);
    80005528:	85e6                	mv	a1,s9
    8000552a:	854e                	mv	a0,s3
    8000552c:	9e1fc0ef          	jal	ra,80001f0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005530:	0004851b          	sext.w	a0,s1
    80005534:	b1f5                	j	80005220 <kexec+0x96>
  ip = 0;
    80005536:	4a81                	li	s5,0
    80005538:	bd95                	j	800053ac <kexec+0x222>
    8000553a:	4a81                	li	s5,0
    8000553c:	bd85                	j	800053ac <kexec+0x222>
    8000553e:	4a81                	li	s5,0
    80005540:	b5b5                	j	800053ac <kexec+0x222>

0000000080005542 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005542:	7179                	addi	sp,sp,-48
    80005544:	f406                	sd	ra,40(sp)
    80005546:	f022                	sd	s0,32(sp)
    80005548:	ec26                	sd	s1,24(sp)
    8000554a:	e84a                	sd	s2,16(sp)
    8000554c:	1800                	addi	s0,sp,48
    8000554e:	892e                	mv	s2,a1
    80005550:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005552:	fdc40593          	addi	a1,s0,-36
    80005556:	823fd0ef          	jal	ra,80002d78 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000555a:	fdc42703          	lw	a4,-36(s0)
    8000555e:	47bd                	li	a5,15
    80005560:	02e7e963          	bltu	a5,a4,80005592 <argfd+0x50>
    80005564:	decfc0ef          	jal	ra,80001b50 <myproc>
    80005568:	fdc42703          	lw	a4,-36(s0)
    8000556c:	01a70793          	addi	a5,a4,26
    80005570:	078e                	slli	a5,a5,0x3
    80005572:	953e                	add	a0,a0,a5
    80005574:	611c                	ld	a5,0(a0)
    80005576:	c385                	beqz	a5,80005596 <argfd+0x54>
    return -1;
  if(pfd)
    80005578:	00090463          	beqz	s2,80005580 <argfd+0x3e>
    *pfd = fd;
    8000557c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005580:	4501                	li	a0,0
  if(pf)
    80005582:	c091                	beqz	s1,80005586 <argfd+0x44>
    *pf = f;
    80005584:	e09c                	sd	a5,0(s1)
}
    80005586:	70a2                	ld	ra,40(sp)
    80005588:	7402                	ld	s0,32(sp)
    8000558a:	64e2                	ld	s1,24(sp)
    8000558c:	6942                	ld	s2,16(sp)
    8000558e:	6145                	addi	sp,sp,48
    80005590:	8082                	ret
    return -1;
    80005592:	557d                	li	a0,-1
    80005594:	bfcd                	j	80005586 <argfd+0x44>
    80005596:	557d                	li	a0,-1
    80005598:	b7fd                	j	80005586 <argfd+0x44>

000000008000559a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000559a:	1101                	addi	sp,sp,-32
    8000559c:	ec06                	sd	ra,24(sp)
    8000559e:	e822                	sd	s0,16(sp)
    800055a0:	e426                	sd	s1,8(sp)
    800055a2:	1000                	addi	s0,sp,32
    800055a4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055a6:	daafc0ef          	jal	ra,80001b50 <myproc>
    800055aa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055ac:	0d050793          	addi	a5,a0,208
    800055b0:	4501                	li	a0,0
    800055b2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055b4:	6398                	ld	a4,0(a5)
    800055b6:	cb19                	beqz	a4,800055cc <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800055b8:	2505                	addiw	a0,a0,1
    800055ba:	07a1                	addi	a5,a5,8
    800055bc:	fed51ce3          	bne	a0,a3,800055b4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055c0:	557d                	li	a0,-1
}
    800055c2:	60e2                	ld	ra,24(sp)
    800055c4:	6442                	ld	s0,16(sp)
    800055c6:	64a2                	ld	s1,8(sp)
    800055c8:	6105                	addi	sp,sp,32
    800055ca:	8082                	ret
      p->ofile[fd] = f;
    800055cc:	01a50793          	addi	a5,a0,26
    800055d0:	078e                	slli	a5,a5,0x3
    800055d2:	963e                	add	a2,a2,a5
    800055d4:	e204                	sd	s1,0(a2)
      return fd;
    800055d6:	b7f5                	j	800055c2 <fdalloc+0x28>

00000000800055d8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055d8:	715d                	addi	sp,sp,-80
    800055da:	e486                	sd	ra,72(sp)
    800055dc:	e0a2                	sd	s0,64(sp)
    800055de:	fc26                	sd	s1,56(sp)
    800055e0:	f84a                	sd	s2,48(sp)
    800055e2:	f44e                	sd	s3,40(sp)
    800055e4:	f052                	sd	s4,32(sp)
    800055e6:	ec56                	sd	s5,24(sp)
    800055e8:	e85a                	sd	s6,16(sp)
    800055ea:	0880                	addi	s0,sp,80
    800055ec:	8b2e                	mv	s6,a1
    800055ee:	89b2                	mv	s3,a2
    800055f0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055f2:	fb040593          	addi	a1,s0,-80
    800055f6:	804ff0ef          	jal	ra,800045fa <nameiparent>
    800055fa:	84aa                	mv	s1,a0
    800055fc:	10050b63          	beqz	a0,80005712 <create+0x13a>
    return 0;

  ilock(dp);
    80005600:	fecfe0ef          	jal	ra,80003dec <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005604:	4601                	li	a2,0
    80005606:	fb040593          	addi	a1,s0,-80
    8000560a:	8526                	mv	a0,s1
    8000560c:	d69fe0ef          	jal	ra,80004374 <dirlookup>
    80005610:	8aaa                	mv	s5,a0
    80005612:	c521                	beqz	a0,8000565a <create+0x82>
    iunlockput(dp);
    80005614:	8526                	mv	a0,s1
    80005616:	9ddfe0ef          	jal	ra,80003ff2 <iunlockput>
    ilock(ip);
    8000561a:	8556                	mv	a0,s5
    8000561c:	fd0fe0ef          	jal	ra,80003dec <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005620:	000b059b          	sext.w	a1,s6
    80005624:	4789                	li	a5,2
    80005626:	02f59563          	bne	a1,a5,80005650 <create+0x78>
    8000562a:	044ad783          	lhu	a5,68(s5)
    8000562e:	37f9                	addiw	a5,a5,-2
    80005630:	17c2                	slli	a5,a5,0x30
    80005632:	93c1                	srli	a5,a5,0x30
    80005634:	4705                	li	a4,1
    80005636:	00f76d63          	bltu	a4,a5,80005650 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000563a:	8556                	mv	a0,s5
    8000563c:	60a6                	ld	ra,72(sp)
    8000563e:	6406                	ld	s0,64(sp)
    80005640:	74e2                	ld	s1,56(sp)
    80005642:	7942                	ld	s2,48(sp)
    80005644:	79a2                	ld	s3,40(sp)
    80005646:	7a02                	ld	s4,32(sp)
    80005648:	6ae2                	ld	s5,24(sp)
    8000564a:	6b42                	ld	s6,16(sp)
    8000564c:	6161                	addi	sp,sp,80
    8000564e:	8082                	ret
    iunlockput(ip);
    80005650:	8556                	mv	a0,s5
    80005652:	9a1fe0ef          	jal	ra,80003ff2 <iunlockput>
    return 0;
    80005656:	4a81                	li	s5,0
    80005658:	b7cd                	j	8000563a <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000565a:	85da                	mv	a1,s6
    8000565c:	4088                	lw	a0,0(s1)
    8000565e:	e24fe0ef          	jal	ra,80003c82 <ialloc>
    80005662:	8a2a                	mv	s4,a0
    80005664:	cd1d                	beqz	a0,800056a2 <create+0xca>
  ilock(ip);
    80005666:	f86fe0ef          	jal	ra,80003dec <ilock>
  ip->major = major;
    8000566a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000566e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005672:	4905                	li	s2,1
    80005674:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005678:	8552                	mv	a0,s4
    8000567a:	ebefe0ef          	jal	ra,80003d38 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000567e:	000b059b          	sext.w	a1,s6
    80005682:	03258563          	beq	a1,s2,800056ac <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80005686:	004a2603          	lw	a2,4(s4)
    8000568a:	fb040593          	addi	a1,s0,-80
    8000568e:	8526                	mv	a0,s1
    80005690:	eb7fe0ef          	jal	ra,80004546 <dirlink>
    80005694:	06054363          	bltz	a0,800056fa <create+0x122>
  iunlockput(dp);
    80005698:	8526                	mv	a0,s1
    8000569a:	959fe0ef          	jal	ra,80003ff2 <iunlockput>
  return ip;
    8000569e:	8ad2                	mv	s5,s4
    800056a0:	bf69                	j	8000563a <create+0x62>
    iunlockput(dp);
    800056a2:	8526                	mv	a0,s1
    800056a4:	94ffe0ef          	jal	ra,80003ff2 <iunlockput>
    return 0;
    800056a8:	8ad2                	mv	s5,s4
    800056aa:	bf41                	j	8000563a <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056ac:	004a2603          	lw	a2,4(s4)
    800056b0:	00003597          	auipc	a1,0x3
    800056b4:	06058593          	addi	a1,a1,96 # 80008710 <syscalls+0x318>
    800056b8:	8552                	mv	a0,s4
    800056ba:	e8dfe0ef          	jal	ra,80004546 <dirlink>
    800056be:	02054e63          	bltz	a0,800056fa <create+0x122>
    800056c2:	40d0                	lw	a2,4(s1)
    800056c4:	00003597          	auipc	a1,0x3
    800056c8:	05458593          	addi	a1,a1,84 # 80008718 <syscalls+0x320>
    800056cc:	8552                	mv	a0,s4
    800056ce:	e79fe0ef          	jal	ra,80004546 <dirlink>
    800056d2:	02054463          	bltz	a0,800056fa <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    800056d6:	004a2603          	lw	a2,4(s4)
    800056da:	fb040593          	addi	a1,s0,-80
    800056de:	8526                	mv	a0,s1
    800056e0:	e67fe0ef          	jal	ra,80004546 <dirlink>
    800056e4:	00054b63          	bltz	a0,800056fa <create+0x122>
    dp->nlink++;  // for ".."
    800056e8:	04a4d783          	lhu	a5,74(s1)
    800056ec:	2785                	addiw	a5,a5,1
    800056ee:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056f2:	8526                	mv	a0,s1
    800056f4:	e44fe0ef          	jal	ra,80003d38 <iupdate>
    800056f8:	b745                	j	80005698 <create+0xc0>
  ip->nlink = 0;
    800056fa:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056fe:	8552                	mv	a0,s4
    80005700:	e38fe0ef          	jal	ra,80003d38 <iupdate>
  iunlockput(ip);
    80005704:	8552                	mv	a0,s4
    80005706:	8edfe0ef          	jal	ra,80003ff2 <iunlockput>
  iunlockput(dp);
    8000570a:	8526                	mv	a0,s1
    8000570c:	8e7fe0ef          	jal	ra,80003ff2 <iunlockput>
  return 0;
    80005710:	b72d                	j	8000563a <create+0x62>
    return 0;
    80005712:	8aaa                	mv	s5,a0
    80005714:	b71d                	j	8000563a <create+0x62>

0000000080005716 <sys_dup>:
{
    80005716:	7179                	addi	sp,sp,-48
    80005718:	f406                	sd	ra,40(sp)
    8000571a:	f022                	sd	s0,32(sp)
    8000571c:	ec26                	sd	s1,24(sp)
    8000571e:	e84a                	sd	s2,16(sp)
    80005720:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005722:	fd840613          	addi	a2,s0,-40
    80005726:	4581                	li	a1,0
    80005728:	4501                	li	a0,0
    8000572a:	e19ff0ef          	jal	ra,80005542 <argfd>
    return -1;
    8000572e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005730:	00054f63          	bltz	a0,8000574e <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80005734:	fd843903          	ld	s2,-40(s0)
    80005738:	854a                	mv	a0,s2
    8000573a:	e61ff0ef          	jal	ra,8000559a <fdalloc>
    8000573e:	84aa                	mv	s1,a0
    return -1;
    80005740:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005742:	00054663          	bltz	a0,8000574e <sys_dup+0x38>
  filedup(f);
    80005746:	854a                	mv	a0,s2
    80005748:	c50ff0ef          	jal	ra,80004b98 <filedup>
  return fd;
    8000574c:	87a6                	mv	a5,s1
}
    8000574e:	853e                	mv	a0,a5
    80005750:	70a2                	ld	ra,40(sp)
    80005752:	7402                	ld	s0,32(sp)
    80005754:	64e2                	ld	s1,24(sp)
    80005756:	6942                	ld	s2,16(sp)
    80005758:	6145                	addi	sp,sp,48
    8000575a:	8082                	ret

000000008000575c <sys_read>:
{
    8000575c:	7179                	addi	sp,sp,-48
    8000575e:	f406                	sd	ra,40(sp)
    80005760:	f022                	sd	s0,32(sp)
    80005762:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005764:	fd840593          	addi	a1,s0,-40
    80005768:	4505                	li	a0,1
    8000576a:	e2afd0ef          	jal	ra,80002d94 <argaddr>
  argint(2, &n);
    8000576e:	fe440593          	addi	a1,s0,-28
    80005772:	4509                	li	a0,2
    80005774:	e04fd0ef          	jal	ra,80002d78 <argint>
  if(argfd(0, 0, &f) < 0)
    80005778:	fe840613          	addi	a2,s0,-24
    8000577c:	4581                	li	a1,0
    8000577e:	4501                	li	a0,0
    80005780:	dc3ff0ef          	jal	ra,80005542 <argfd>
    80005784:	87aa                	mv	a5,a0
    return -1;
    80005786:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005788:	0007ca63          	bltz	a5,8000579c <sys_read+0x40>
  return fileread(f, p, n);
    8000578c:	fe442603          	lw	a2,-28(s0)
    80005790:	fd843583          	ld	a1,-40(s0)
    80005794:	fe843503          	ld	a0,-24(s0)
    80005798:	d4cff0ef          	jal	ra,80004ce4 <fileread>
}
    8000579c:	70a2                	ld	ra,40(sp)
    8000579e:	7402                	ld	s0,32(sp)
    800057a0:	6145                	addi	sp,sp,48
    800057a2:	8082                	ret

00000000800057a4 <sys_write>:
{
    800057a4:	7179                	addi	sp,sp,-48
    800057a6:	f406                	sd	ra,40(sp)
    800057a8:	f022                	sd	s0,32(sp)
    800057aa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057ac:	fd840593          	addi	a1,s0,-40
    800057b0:	4505                	li	a0,1
    800057b2:	de2fd0ef          	jal	ra,80002d94 <argaddr>
  argint(2, &n);
    800057b6:	fe440593          	addi	a1,s0,-28
    800057ba:	4509                	li	a0,2
    800057bc:	dbcfd0ef          	jal	ra,80002d78 <argint>
  if(argfd(0, 0, &f) < 0)
    800057c0:	fe840613          	addi	a2,s0,-24
    800057c4:	4581                	li	a1,0
    800057c6:	4501                	li	a0,0
    800057c8:	d7bff0ef          	jal	ra,80005542 <argfd>
    800057cc:	87aa                	mv	a5,a0
    return -1;
    800057ce:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057d0:	0007ca63          	bltz	a5,800057e4 <sys_write+0x40>
  return filewrite(f, p, n);
    800057d4:	fe442603          	lw	a2,-28(s0)
    800057d8:	fd843583          	ld	a1,-40(s0)
    800057dc:	fe843503          	ld	a0,-24(s0)
    800057e0:	db2ff0ef          	jal	ra,80004d92 <filewrite>
}
    800057e4:	70a2                	ld	ra,40(sp)
    800057e6:	7402                	ld	s0,32(sp)
    800057e8:	6145                	addi	sp,sp,48
    800057ea:	8082                	ret

00000000800057ec <sys_close>:
{
    800057ec:	1101                	addi	sp,sp,-32
    800057ee:	ec06                	sd	ra,24(sp)
    800057f0:	e822                	sd	s0,16(sp)
    800057f2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057f4:	fe040613          	addi	a2,s0,-32
    800057f8:	fec40593          	addi	a1,s0,-20
    800057fc:	4501                	li	a0,0
    800057fe:	d45ff0ef          	jal	ra,80005542 <argfd>
    return -1;
    80005802:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005804:	02054063          	bltz	a0,80005824 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005808:	b48fc0ef          	jal	ra,80001b50 <myproc>
    8000580c:	fec42783          	lw	a5,-20(s0)
    80005810:	07e9                	addi	a5,a5,26
    80005812:	078e                	slli	a5,a5,0x3
    80005814:	953e                	add	a0,a0,a5
    80005816:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000581a:	fe043503          	ld	a0,-32(s0)
    8000581e:	bc0ff0ef          	jal	ra,80004bde <fileclose>
  return 0;
    80005822:	4781                	li	a5,0
}
    80005824:	853e                	mv	a0,a5
    80005826:	60e2                	ld	ra,24(sp)
    80005828:	6442                	ld	s0,16(sp)
    8000582a:	6105                	addi	sp,sp,32
    8000582c:	8082                	ret

000000008000582e <sys_fstat>:
{
    8000582e:	1101                	addi	sp,sp,-32
    80005830:	ec06                	sd	ra,24(sp)
    80005832:	e822                	sd	s0,16(sp)
    80005834:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005836:	fe040593          	addi	a1,s0,-32
    8000583a:	4505                	li	a0,1
    8000583c:	d58fd0ef          	jal	ra,80002d94 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005840:	fe840613          	addi	a2,s0,-24
    80005844:	4581                	li	a1,0
    80005846:	4501                	li	a0,0
    80005848:	cfbff0ef          	jal	ra,80005542 <argfd>
    8000584c:	87aa                	mv	a5,a0
    return -1;
    8000584e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005850:	0007c863          	bltz	a5,80005860 <sys_fstat+0x32>
  return filestat(f, st);
    80005854:	fe043583          	ld	a1,-32(s0)
    80005858:	fe843503          	ld	a0,-24(s0)
    8000585c:	c2aff0ef          	jal	ra,80004c86 <filestat>
}
    80005860:	60e2                	ld	ra,24(sp)
    80005862:	6442                	ld	s0,16(sp)
    80005864:	6105                	addi	sp,sp,32
    80005866:	8082                	ret

0000000080005868 <sys_link>:
{
    80005868:	7169                	addi	sp,sp,-304
    8000586a:	f606                	sd	ra,296(sp)
    8000586c:	f222                	sd	s0,288(sp)
    8000586e:	ee26                	sd	s1,280(sp)
    80005870:	ea4a                	sd	s2,272(sp)
    80005872:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005874:	08000613          	li	a2,128
    80005878:	ed040593          	addi	a1,s0,-304
    8000587c:	4501                	li	a0,0
    8000587e:	d32fd0ef          	jal	ra,80002db0 <argstr>
    return -1;
    80005882:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005884:	0c054663          	bltz	a0,80005950 <sys_link+0xe8>
    80005888:	08000613          	li	a2,128
    8000588c:	f5040593          	addi	a1,s0,-176
    80005890:	4505                	li	a0,1
    80005892:	d1efd0ef          	jal	ra,80002db0 <argstr>
    return -1;
    80005896:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005898:	0a054c63          	bltz	a0,80005950 <sys_link+0xe8>
  begin_op();
    8000589c:	f39fe0ef          	jal	ra,800047d4 <begin_op>
  if((ip = namei(old)) == 0){
    800058a0:	ed040513          	addi	a0,s0,-304
    800058a4:	d3dfe0ef          	jal	ra,800045e0 <namei>
    800058a8:	84aa                	mv	s1,a0
    800058aa:	c525                	beqz	a0,80005912 <sys_link+0xaa>
  ilock(ip);
    800058ac:	d40fe0ef          	jal	ra,80003dec <ilock>
  if(ip->type == T_DIR){
    800058b0:	04449703          	lh	a4,68(s1)
    800058b4:	4785                	li	a5,1
    800058b6:	06f70263          	beq	a4,a5,8000591a <sys_link+0xb2>
  ip->nlink++;
    800058ba:	04a4d783          	lhu	a5,74(s1)
    800058be:	2785                	addiw	a5,a5,1
    800058c0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058c4:	8526                	mv	a0,s1
    800058c6:	c72fe0ef          	jal	ra,80003d38 <iupdate>
  iunlock(ip);
    800058ca:	8526                	mv	a0,s1
    800058cc:	dcafe0ef          	jal	ra,80003e96 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058d0:	fd040593          	addi	a1,s0,-48
    800058d4:	f5040513          	addi	a0,s0,-176
    800058d8:	d23fe0ef          	jal	ra,800045fa <nameiparent>
    800058dc:	892a                	mv	s2,a0
    800058de:	c921                	beqz	a0,8000592e <sys_link+0xc6>
  ilock(dp);
    800058e0:	d0cfe0ef          	jal	ra,80003dec <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800058e4:	00092703          	lw	a4,0(s2)
    800058e8:	409c                	lw	a5,0(s1)
    800058ea:	02f71f63          	bne	a4,a5,80005928 <sys_link+0xc0>
    800058ee:	40d0                	lw	a2,4(s1)
    800058f0:	fd040593          	addi	a1,s0,-48
    800058f4:	854a                	mv	a0,s2
    800058f6:	c51fe0ef          	jal	ra,80004546 <dirlink>
    800058fa:	02054763          	bltz	a0,80005928 <sys_link+0xc0>
  iunlockput(dp);
    800058fe:	854a                	mv	a0,s2
    80005900:	ef2fe0ef          	jal	ra,80003ff2 <iunlockput>
  iput(ip);
    80005904:	8526                	mv	a0,s1
    80005906:	e64fe0ef          	jal	ra,80003f6a <iput>
  end_op();
    8000590a:	f39fe0ef          	jal	ra,80004842 <end_op>
  return 0;
    8000590e:	4781                	li	a5,0
    80005910:	a081                	j	80005950 <sys_link+0xe8>
    end_op();
    80005912:	f31fe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005916:	57fd                	li	a5,-1
    80005918:	a825                	j	80005950 <sys_link+0xe8>
    iunlockput(ip);
    8000591a:	8526                	mv	a0,s1
    8000591c:	ed6fe0ef          	jal	ra,80003ff2 <iunlockput>
    end_op();
    80005920:	f23fe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005924:	57fd                	li	a5,-1
    80005926:	a02d                	j	80005950 <sys_link+0xe8>
    iunlockput(dp);
    80005928:	854a                	mv	a0,s2
    8000592a:	ec8fe0ef          	jal	ra,80003ff2 <iunlockput>
  ilock(ip);
    8000592e:	8526                	mv	a0,s1
    80005930:	cbcfe0ef          	jal	ra,80003dec <ilock>
  ip->nlink--;
    80005934:	04a4d783          	lhu	a5,74(s1)
    80005938:	37fd                	addiw	a5,a5,-1
    8000593a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000593e:	8526                	mv	a0,s1
    80005940:	bf8fe0ef          	jal	ra,80003d38 <iupdate>
  iunlockput(ip);
    80005944:	8526                	mv	a0,s1
    80005946:	eacfe0ef          	jal	ra,80003ff2 <iunlockput>
  end_op();
    8000594a:	ef9fe0ef          	jal	ra,80004842 <end_op>
  return -1;
    8000594e:	57fd                	li	a5,-1
}
    80005950:	853e                	mv	a0,a5
    80005952:	70b2                	ld	ra,296(sp)
    80005954:	7412                	ld	s0,288(sp)
    80005956:	64f2                	ld	s1,280(sp)
    80005958:	6952                	ld	s2,272(sp)
    8000595a:	6155                	addi	sp,sp,304
    8000595c:	8082                	ret

000000008000595e <sys_unlink>:
{
    8000595e:	7151                	addi	sp,sp,-240
    80005960:	f586                	sd	ra,232(sp)
    80005962:	f1a2                	sd	s0,224(sp)
    80005964:	eda6                	sd	s1,216(sp)
    80005966:	e9ca                	sd	s2,208(sp)
    80005968:	e5ce                	sd	s3,200(sp)
    8000596a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000596c:	08000613          	li	a2,128
    80005970:	f3040593          	addi	a1,s0,-208
    80005974:	4501                	li	a0,0
    80005976:	c3afd0ef          	jal	ra,80002db0 <argstr>
    8000597a:	12054b63          	bltz	a0,80005ab0 <sys_unlink+0x152>
  begin_op();
    8000597e:	e57fe0ef          	jal	ra,800047d4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005982:	fb040593          	addi	a1,s0,-80
    80005986:	f3040513          	addi	a0,s0,-208
    8000598a:	c71fe0ef          	jal	ra,800045fa <nameiparent>
    8000598e:	84aa                	mv	s1,a0
    80005990:	c54d                	beqz	a0,80005a3a <sys_unlink+0xdc>
  ilock(dp);
    80005992:	c5afe0ef          	jal	ra,80003dec <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005996:	00003597          	auipc	a1,0x3
    8000599a:	d7a58593          	addi	a1,a1,-646 # 80008710 <syscalls+0x318>
    8000599e:	fb040513          	addi	a0,s0,-80
    800059a2:	9bdfe0ef          	jal	ra,8000435e <namecmp>
    800059a6:	10050a63          	beqz	a0,80005aba <sys_unlink+0x15c>
    800059aa:	00003597          	auipc	a1,0x3
    800059ae:	d6e58593          	addi	a1,a1,-658 # 80008718 <syscalls+0x320>
    800059b2:	fb040513          	addi	a0,s0,-80
    800059b6:	9a9fe0ef          	jal	ra,8000435e <namecmp>
    800059ba:	10050063          	beqz	a0,80005aba <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059be:	f2c40613          	addi	a2,s0,-212
    800059c2:	fb040593          	addi	a1,s0,-80
    800059c6:	8526                	mv	a0,s1
    800059c8:	9adfe0ef          	jal	ra,80004374 <dirlookup>
    800059cc:	892a                	mv	s2,a0
    800059ce:	0e050663          	beqz	a0,80005aba <sys_unlink+0x15c>
  ilock(ip);
    800059d2:	c1afe0ef          	jal	ra,80003dec <ilock>
  if(ip->nlink < 1)
    800059d6:	04a91783          	lh	a5,74(s2)
    800059da:	06f05463          	blez	a5,80005a42 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059de:	04491703          	lh	a4,68(s2)
    800059e2:	4785                	li	a5,1
    800059e4:	06f70563          	beq	a4,a5,80005a4e <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800059e8:	4641                	li	a2,16
    800059ea:	4581                	li	a1,0
    800059ec:	fc040513          	addi	a0,s0,-64
    800059f0:	b84fb0ef          	jal	ra,80000d74 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059f4:	4741                	li	a4,16
    800059f6:	f2c42683          	lw	a3,-212(s0)
    800059fa:	fc040613          	addi	a2,s0,-64
    800059fe:	4581                	li	a1,0
    80005a00:	8526                	mv	a0,s1
    80005a02:	85bfe0ef          	jal	ra,8000425c <writei>
    80005a06:	47c1                	li	a5,16
    80005a08:	08f51563          	bne	a0,a5,80005a92 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80005a0c:	04491703          	lh	a4,68(s2)
    80005a10:	4785                	li	a5,1
    80005a12:	08f70663          	beq	a4,a5,80005a9e <sys_unlink+0x140>
  iunlockput(dp);
    80005a16:	8526                	mv	a0,s1
    80005a18:	ddafe0ef          	jal	ra,80003ff2 <iunlockput>
  ip->nlink--;
    80005a1c:	04a95783          	lhu	a5,74(s2)
    80005a20:	37fd                	addiw	a5,a5,-1
    80005a22:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a26:	854a                	mv	a0,s2
    80005a28:	b10fe0ef          	jal	ra,80003d38 <iupdate>
  iunlockput(ip);
    80005a2c:	854a                	mv	a0,s2
    80005a2e:	dc4fe0ef          	jal	ra,80003ff2 <iunlockput>
  end_op();
    80005a32:	e11fe0ef          	jal	ra,80004842 <end_op>
  return 0;
    80005a36:	4501                	li	a0,0
    80005a38:	a079                	j	80005ac6 <sys_unlink+0x168>
    end_op();
    80005a3a:	e09fe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005a3e:	557d                	li	a0,-1
    80005a40:	a059                	j	80005ac6 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005a42:	00003517          	auipc	a0,0x3
    80005a46:	cde50513          	addi	a0,a0,-802 # 80008720 <syscalls+0x328>
    80005a4a:	d3ffa0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a4e:	04c92703          	lw	a4,76(s2)
    80005a52:	02000793          	li	a5,32
    80005a56:	f8e7f9e3          	bgeu	a5,a4,800059e8 <sys_unlink+0x8a>
    80005a5a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a5e:	4741                	li	a4,16
    80005a60:	86ce                	mv	a3,s3
    80005a62:	f1840613          	addi	a2,s0,-232
    80005a66:	4581                	li	a1,0
    80005a68:	854a                	mv	a0,s2
    80005a6a:	f0efe0ef          	jal	ra,80004178 <readi>
    80005a6e:	47c1                	li	a5,16
    80005a70:	00f51b63          	bne	a0,a5,80005a86 <sys_unlink+0x128>
    if(de.inum != 0)
    80005a74:	f1845783          	lhu	a5,-232(s0)
    80005a78:	ef95                	bnez	a5,80005ab4 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a7a:	29c1                	addiw	s3,s3,16
    80005a7c:	04c92783          	lw	a5,76(s2)
    80005a80:	fcf9efe3          	bltu	s3,a5,80005a5e <sys_unlink+0x100>
    80005a84:	b795                	j	800059e8 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005a86:	00003517          	auipc	a0,0x3
    80005a8a:	cb250513          	addi	a0,a0,-846 # 80008738 <syscalls+0x340>
    80005a8e:	cfbfa0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80005a92:	00003517          	auipc	a0,0x3
    80005a96:	cbe50513          	addi	a0,a0,-834 # 80008750 <syscalls+0x358>
    80005a9a:	ceffa0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80005a9e:	04a4d783          	lhu	a5,74(s1)
    80005aa2:	37fd                	addiw	a5,a5,-1
    80005aa4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005aa8:	8526                	mv	a0,s1
    80005aaa:	a8efe0ef          	jal	ra,80003d38 <iupdate>
    80005aae:	b7a5                	j	80005a16 <sys_unlink+0xb8>
    return -1;
    80005ab0:	557d                	li	a0,-1
    80005ab2:	a811                	j	80005ac6 <sys_unlink+0x168>
    iunlockput(ip);
    80005ab4:	854a                	mv	a0,s2
    80005ab6:	d3cfe0ef          	jal	ra,80003ff2 <iunlockput>
  iunlockput(dp);
    80005aba:	8526                	mv	a0,s1
    80005abc:	d36fe0ef          	jal	ra,80003ff2 <iunlockput>
  end_op();
    80005ac0:	d83fe0ef          	jal	ra,80004842 <end_op>
  return -1;
    80005ac4:	557d                	li	a0,-1
}
    80005ac6:	70ae                	ld	ra,232(sp)
    80005ac8:	740e                	ld	s0,224(sp)
    80005aca:	64ee                	ld	s1,216(sp)
    80005acc:	694e                	ld	s2,208(sp)
    80005ace:	69ae                	ld	s3,200(sp)
    80005ad0:	616d                	addi	sp,sp,240
    80005ad2:	8082                	ret

0000000080005ad4 <sys_open>:

uint64
sys_open(void)
{
    80005ad4:	7131                	addi	sp,sp,-192
    80005ad6:	fd06                	sd	ra,184(sp)
    80005ad8:	f922                	sd	s0,176(sp)
    80005ada:	f526                	sd	s1,168(sp)
    80005adc:	f14a                	sd	s2,160(sp)
    80005ade:	ed4e                	sd	s3,152(sp)
    80005ae0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ae2:	f4c40593          	addi	a1,s0,-180
    80005ae6:	4505                	li	a0,1
    80005ae8:	a90fd0ef          	jal	ra,80002d78 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005aec:	08000613          	li	a2,128
    80005af0:	f5040593          	addi	a1,s0,-176
    80005af4:	4501                	li	a0,0
    80005af6:	abafd0ef          	jal	ra,80002db0 <argstr>
    80005afa:	87aa                	mv	a5,a0
    return -1;
    80005afc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005afe:	0807cd63          	bltz	a5,80005b98 <sys_open+0xc4>

  begin_op();
    80005b02:	cd3fe0ef          	jal	ra,800047d4 <begin_op>

  if(omode & O_CREATE){
    80005b06:	f4c42783          	lw	a5,-180(s0)
    80005b0a:	2007f793          	andi	a5,a5,512
    80005b0e:	c3c5                	beqz	a5,80005bae <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005b10:	4681                	li	a3,0
    80005b12:	4601                	li	a2,0
    80005b14:	4589                	li	a1,2
    80005b16:	f5040513          	addi	a0,s0,-176
    80005b1a:	abfff0ef          	jal	ra,800055d8 <create>
    80005b1e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b20:	c159                	beqz	a0,80005ba6 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b22:	04449703          	lh	a4,68(s1)
    80005b26:	478d                	li	a5,3
    80005b28:	00f71763          	bne	a4,a5,80005b36 <sys_open+0x62>
    80005b2c:	0464d703          	lhu	a4,70(s1)
    80005b30:	47a5                	li	a5,9
    80005b32:	0ae7e963          	bltu	a5,a4,80005be4 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b36:	804ff0ef          	jal	ra,80004b3a <filealloc>
    80005b3a:	89aa                	mv	s3,a0
    80005b3c:	0c050963          	beqz	a0,80005c0e <sys_open+0x13a>
    80005b40:	a5bff0ef          	jal	ra,8000559a <fdalloc>
    80005b44:	892a                	mv	s2,a0
    80005b46:	0c054163          	bltz	a0,80005c08 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b4a:	04449703          	lh	a4,68(s1)
    80005b4e:	478d                	li	a5,3
    80005b50:	0af70163          	beq	a4,a5,80005bf2 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b54:	4789                	li	a5,2
    80005b56:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b5a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b5e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b62:	f4c42783          	lw	a5,-180(s0)
    80005b66:	0017c713          	xori	a4,a5,1
    80005b6a:	8b05                	andi	a4,a4,1
    80005b6c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b70:	0037f713          	andi	a4,a5,3
    80005b74:	00e03733          	snez	a4,a4
    80005b78:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b7c:	4007f793          	andi	a5,a5,1024
    80005b80:	c791                	beqz	a5,80005b8c <sys_open+0xb8>
    80005b82:	04449703          	lh	a4,68(s1)
    80005b86:	4789                	li	a5,2
    80005b88:	06f70c63          	beq	a4,a5,80005c00 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	b08fe0ef          	jal	ra,80003e96 <iunlock>
  end_op();
    80005b92:	cb1fe0ef          	jal	ra,80004842 <end_op>

  return fd;
    80005b96:	854a                	mv	a0,s2
}
    80005b98:	70ea                	ld	ra,184(sp)
    80005b9a:	744a                	ld	s0,176(sp)
    80005b9c:	74aa                	ld	s1,168(sp)
    80005b9e:	790a                	ld	s2,160(sp)
    80005ba0:	69ea                	ld	s3,152(sp)
    80005ba2:	6129                	addi	sp,sp,192
    80005ba4:	8082                	ret
      end_op();
    80005ba6:	c9dfe0ef          	jal	ra,80004842 <end_op>
      return -1;
    80005baa:	557d                	li	a0,-1
    80005bac:	b7f5                	j	80005b98 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005bae:	f5040513          	addi	a0,s0,-176
    80005bb2:	a2ffe0ef          	jal	ra,800045e0 <namei>
    80005bb6:	84aa                	mv	s1,a0
    80005bb8:	c115                	beqz	a0,80005bdc <sys_open+0x108>
    ilock(ip);
    80005bba:	a32fe0ef          	jal	ra,80003dec <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bbe:	04449703          	lh	a4,68(s1)
    80005bc2:	4785                	li	a5,1
    80005bc4:	f4f71fe3          	bne	a4,a5,80005b22 <sys_open+0x4e>
    80005bc8:	f4c42783          	lw	a5,-180(s0)
    80005bcc:	d7ad                	beqz	a5,80005b36 <sys_open+0x62>
      iunlockput(ip);
    80005bce:	8526                	mv	a0,s1
    80005bd0:	c22fe0ef          	jal	ra,80003ff2 <iunlockput>
      end_op();
    80005bd4:	c6ffe0ef          	jal	ra,80004842 <end_op>
      return -1;
    80005bd8:	557d                	li	a0,-1
    80005bda:	bf7d                	j	80005b98 <sys_open+0xc4>
      end_op();
    80005bdc:	c67fe0ef          	jal	ra,80004842 <end_op>
      return -1;
    80005be0:	557d                	li	a0,-1
    80005be2:	bf5d                	j	80005b98 <sys_open+0xc4>
    iunlockput(ip);
    80005be4:	8526                	mv	a0,s1
    80005be6:	c0cfe0ef          	jal	ra,80003ff2 <iunlockput>
    end_op();
    80005bea:	c59fe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005bee:	557d                	li	a0,-1
    80005bf0:	b765                	j	80005b98 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005bf2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005bf6:	04649783          	lh	a5,70(s1)
    80005bfa:	02f99223          	sh	a5,36(s3)
    80005bfe:	b785                	j	80005b5e <sys_open+0x8a>
    itrunc(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ad4fe0ef          	jal	ra,80003ed6 <itrunc>
    80005c06:	b759                	j	80005b8c <sys_open+0xb8>
      fileclose(f);
    80005c08:	854e                	mv	a0,s3
    80005c0a:	fd5fe0ef          	jal	ra,80004bde <fileclose>
    iunlockput(ip);
    80005c0e:	8526                	mv	a0,s1
    80005c10:	be2fe0ef          	jal	ra,80003ff2 <iunlockput>
    end_op();
    80005c14:	c2ffe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005c18:	557d                	li	a0,-1
    80005c1a:	bfbd                	j	80005b98 <sys_open+0xc4>

0000000080005c1c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c1c:	7175                	addi	sp,sp,-144
    80005c1e:	e506                	sd	ra,136(sp)
    80005c20:	e122                	sd	s0,128(sp)
    80005c22:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c24:	bb1fe0ef          	jal	ra,800047d4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c28:	08000613          	li	a2,128
    80005c2c:	f7040593          	addi	a1,s0,-144
    80005c30:	4501                	li	a0,0
    80005c32:	97efd0ef          	jal	ra,80002db0 <argstr>
    80005c36:	02054363          	bltz	a0,80005c5c <sys_mkdir+0x40>
    80005c3a:	4681                	li	a3,0
    80005c3c:	4601                	li	a2,0
    80005c3e:	4585                	li	a1,1
    80005c40:	f7040513          	addi	a0,s0,-144
    80005c44:	995ff0ef          	jal	ra,800055d8 <create>
    80005c48:	c911                	beqz	a0,80005c5c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c4a:	ba8fe0ef          	jal	ra,80003ff2 <iunlockput>
  end_op();
    80005c4e:	bf5fe0ef          	jal	ra,80004842 <end_op>
  return 0;
    80005c52:	4501                	li	a0,0
}
    80005c54:	60aa                	ld	ra,136(sp)
    80005c56:	640a                	ld	s0,128(sp)
    80005c58:	6149                	addi	sp,sp,144
    80005c5a:	8082                	ret
    end_op();
    80005c5c:	be7fe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005c60:	557d                	li	a0,-1
    80005c62:	bfcd                	j	80005c54 <sys_mkdir+0x38>

0000000080005c64 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c64:	7135                	addi	sp,sp,-160
    80005c66:	ed06                	sd	ra,152(sp)
    80005c68:	e922                	sd	s0,144(sp)
    80005c6a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c6c:	b69fe0ef          	jal	ra,800047d4 <begin_op>
  argint(1, &major);
    80005c70:	f6c40593          	addi	a1,s0,-148
    80005c74:	4505                	li	a0,1
    80005c76:	902fd0ef          	jal	ra,80002d78 <argint>
  argint(2, &minor);
    80005c7a:	f6840593          	addi	a1,s0,-152
    80005c7e:	4509                	li	a0,2
    80005c80:	8f8fd0ef          	jal	ra,80002d78 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c84:	08000613          	li	a2,128
    80005c88:	f7040593          	addi	a1,s0,-144
    80005c8c:	4501                	li	a0,0
    80005c8e:	922fd0ef          	jal	ra,80002db0 <argstr>
    80005c92:	02054563          	bltz	a0,80005cbc <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c96:	f6841683          	lh	a3,-152(s0)
    80005c9a:	f6c41603          	lh	a2,-148(s0)
    80005c9e:	458d                	li	a1,3
    80005ca0:	f7040513          	addi	a0,s0,-144
    80005ca4:	935ff0ef          	jal	ra,800055d8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ca8:	c911                	beqz	a0,80005cbc <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005caa:	b48fe0ef          	jal	ra,80003ff2 <iunlockput>
  end_op();
    80005cae:	b95fe0ef          	jal	ra,80004842 <end_op>
  return 0;
    80005cb2:	4501                	li	a0,0
}
    80005cb4:	60ea                	ld	ra,152(sp)
    80005cb6:	644a                	ld	s0,144(sp)
    80005cb8:	610d                	addi	sp,sp,160
    80005cba:	8082                	ret
    end_op();
    80005cbc:	b87fe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005cc0:	557d                	li	a0,-1
    80005cc2:	bfcd                	j	80005cb4 <sys_mknod+0x50>

0000000080005cc4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cc4:	7135                	addi	sp,sp,-160
    80005cc6:	ed06                	sd	ra,152(sp)
    80005cc8:	e922                	sd	s0,144(sp)
    80005cca:	e526                	sd	s1,136(sp)
    80005ccc:	e14a                	sd	s2,128(sp)
    80005cce:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cd0:	e81fb0ef          	jal	ra,80001b50 <myproc>
    80005cd4:	892a                	mv	s2,a0
  
  begin_op();
    80005cd6:	afffe0ef          	jal	ra,800047d4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cda:	08000613          	li	a2,128
    80005cde:	f6040593          	addi	a1,s0,-160
    80005ce2:	4501                	li	a0,0
    80005ce4:	8ccfd0ef          	jal	ra,80002db0 <argstr>
    80005ce8:	04054163          	bltz	a0,80005d2a <sys_chdir+0x66>
    80005cec:	f6040513          	addi	a0,s0,-160
    80005cf0:	8f1fe0ef          	jal	ra,800045e0 <namei>
    80005cf4:	84aa                	mv	s1,a0
    80005cf6:	c915                	beqz	a0,80005d2a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005cf8:	8f4fe0ef          	jal	ra,80003dec <ilock>
  if(ip->type != T_DIR){
    80005cfc:	04449703          	lh	a4,68(s1)
    80005d00:	4785                	li	a5,1
    80005d02:	02f71863          	bne	a4,a5,80005d32 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d06:	8526                	mv	a0,s1
    80005d08:	98efe0ef          	jal	ra,80003e96 <iunlock>
  iput(p->cwd);
    80005d0c:	15093503          	ld	a0,336(s2)
    80005d10:	a5afe0ef          	jal	ra,80003f6a <iput>
  end_op();
    80005d14:	b2ffe0ef          	jal	ra,80004842 <end_op>
  p->cwd = ip;
    80005d18:	14993823          	sd	s1,336(s2)
  return 0;
    80005d1c:	4501                	li	a0,0
}
    80005d1e:	60ea                	ld	ra,152(sp)
    80005d20:	644a                	ld	s0,144(sp)
    80005d22:	64aa                	ld	s1,136(sp)
    80005d24:	690a                	ld	s2,128(sp)
    80005d26:	610d                	addi	sp,sp,160
    80005d28:	8082                	ret
    end_op();
    80005d2a:	b19fe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005d2e:	557d                	li	a0,-1
    80005d30:	b7fd                	j	80005d1e <sys_chdir+0x5a>
    iunlockput(ip);
    80005d32:	8526                	mv	a0,s1
    80005d34:	abefe0ef          	jal	ra,80003ff2 <iunlockput>
    end_op();
    80005d38:	b0bfe0ef          	jal	ra,80004842 <end_op>
    return -1;
    80005d3c:	557d                	li	a0,-1
    80005d3e:	b7c5                	j	80005d1e <sys_chdir+0x5a>

0000000080005d40 <sys_exec>:

uint64
sys_exec(void)
{
    80005d40:	7145                	addi	sp,sp,-464
    80005d42:	e786                	sd	ra,456(sp)
    80005d44:	e3a2                	sd	s0,448(sp)
    80005d46:	ff26                	sd	s1,440(sp)
    80005d48:	fb4a                	sd	s2,432(sp)
    80005d4a:	f74e                	sd	s3,424(sp)
    80005d4c:	f352                	sd	s4,416(sp)
    80005d4e:	ef56                	sd	s5,408(sp)
    80005d50:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d52:	e3840593          	addi	a1,s0,-456
    80005d56:	4505                	li	a0,1
    80005d58:	83cfd0ef          	jal	ra,80002d94 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005d5c:	08000613          	li	a2,128
    80005d60:	f4040593          	addi	a1,s0,-192
    80005d64:	4501                	li	a0,0
    80005d66:	84afd0ef          	jal	ra,80002db0 <argstr>
    80005d6a:	87aa                	mv	a5,a0
    return -1;
    80005d6c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d6e:	0a07c563          	bltz	a5,80005e18 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005d72:	10000613          	li	a2,256
    80005d76:	4581                	li	a1,0
    80005d78:	e4040513          	addi	a0,s0,-448
    80005d7c:	ff9fa0ef          	jal	ra,80000d74 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d80:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d84:	89a6                	mv	s3,s1
    80005d86:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d88:	02000a13          	li	s4,32
    80005d8c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d90:	00391513          	slli	a0,s2,0x3
    80005d94:	e3040593          	addi	a1,s0,-464
    80005d98:	e3843783          	ld	a5,-456(s0)
    80005d9c:	953e                	add	a0,a0,a5
    80005d9e:	f51fc0ef          	jal	ra,80002cee <fetchaddr>
    80005da2:	02054663          	bltz	a0,80005dce <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005da6:	e3043783          	ld	a5,-464(s0)
    80005daa:	cf8d                	beqz	a5,80005de4 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005dac:	dfffa0ef          	jal	ra,80000baa <kalloc>
    80005db0:	85aa                	mv	a1,a0
    80005db2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005db6:	cd01                	beqz	a0,80005dce <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005db8:	6605                	lui	a2,0x1
    80005dba:	e3043503          	ld	a0,-464(s0)
    80005dbe:	f7bfc0ef          	jal	ra,80002d38 <fetchstr>
    80005dc2:	00054663          	bltz	a0,80005dce <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005dc6:	0905                	addi	s2,s2,1
    80005dc8:	09a1                	addi	s3,s3,8
    80005dca:	fd4911e3          	bne	s2,s4,80005d8c <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dce:	f4040913          	addi	s2,s0,-192
    80005dd2:	6088                	ld	a0,0(s1)
    80005dd4:	c129                	beqz	a0,80005e16 <sys_exec+0xd6>
    kfree(argv[i]);
    80005dd6:	ca5fa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dda:	04a1                	addi	s1,s1,8
    80005ddc:	ff249be3          	bne	s1,s2,80005dd2 <sys_exec+0x92>
  return -1;
    80005de0:	557d                	li	a0,-1
    80005de2:	a81d                	j	80005e18 <sys_exec+0xd8>
      argv[i] = 0;
    80005de4:	0a8e                	slli	s5,s5,0x3
    80005de6:	fc0a8793          	addi	a5,s5,-64
    80005dea:	00878ab3          	add	s5,a5,s0
    80005dee:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005df2:	e4040593          	addi	a1,s0,-448
    80005df6:	f4040513          	addi	a0,s0,-192
    80005dfa:	b90ff0ef          	jal	ra,8000518a <kexec>
    80005dfe:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e00:	f4040993          	addi	s3,s0,-192
    80005e04:	6088                	ld	a0,0(s1)
    80005e06:	c511                	beqz	a0,80005e12 <sys_exec+0xd2>
    kfree(argv[i]);
    80005e08:	c73fa0ef          	jal	ra,80000a7a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e0c:	04a1                	addi	s1,s1,8
    80005e0e:	ff349be3          	bne	s1,s3,80005e04 <sys_exec+0xc4>
  return ret;
    80005e12:	854a                	mv	a0,s2
    80005e14:	a011                	j	80005e18 <sys_exec+0xd8>
  return -1;
    80005e16:	557d                	li	a0,-1
}
    80005e18:	60be                	ld	ra,456(sp)
    80005e1a:	641e                	ld	s0,448(sp)
    80005e1c:	74fa                	ld	s1,440(sp)
    80005e1e:	795a                	ld	s2,432(sp)
    80005e20:	79ba                	ld	s3,424(sp)
    80005e22:	7a1a                	ld	s4,416(sp)
    80005e24:	6afa                	ld	s5,408(sp)
    80005e26:	6179                	addi	sp,sp,464
    80005e28:	8082                	ret

0000000080005e2a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e2a:	7139                	addi	sp,sp,-64
    80005e2c:	fc06                	sd	ra,56(sp)
    80005e2e:	f822                	sd	s0,48(sp)
    80005e30:	f426                	sd	s1,40(sp)
    80005e32:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e34:	d1dfb0ef          	jal	ra,80001b50 <myproc>
    80005e38:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e3a:	fd840593          	addi	a1,s0,-40
    80005e3e:	4501                	li	a0,0
    80005e40:	f55fc0ef          	jal	ra,80002d94 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e44:	fc840593          	addi	a1,s0,-56
    80005e48:	fd040513          	addi	a0,s0,-48
    80005e4c:	85eff0ef          	jal	ra,80004eaa <pipealloc>
    return -1;
    80005e50:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e52:	0a054463          	bltz	a0,80005efa <sys_pipe+0xd0>
  fd0 = -1;
    80005e56:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e5a:	fd043503          	ld	a0,-48(s0)
    80005e5e:	f3cff0ef          	jal	ra,8000559a <fdalloc>
    80005e62:	fca42223          	sw	a0,-60(s0)
    80005e66:	08054163          	bltz	a0,80005ee8 <sys_pipe+0xbe>
    80005e6a:	fc843503          	ld	a0,-56(s0)
    80005e6e:	f2cff0ef          	jal	ra,8000559a <fdalloc>
    80005e72:	fca42023          	sw	a0,-64(s0)
    80005e76:	06054063          	bltz	a0,80005ed6 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e7a:	4691                	li	a3,4
    80005e7c:	fc440613          	addi	a2,s0,-60
    80005e80:	fd843583          	ld	a1,-40(s0)
    80005e84:	68a8                	ld	a0,80(s1)
    80005e86:	8edfb0ef          	jal	ra,80001772 <copyout>
    80005e8a:	00054e63          	bltz	a0,80005ea6 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e8e:	4691                	li	a3,4
    80005e90:	fc040613          	addi	a2,s0,-64
    80005e94:	fd843583          	ld	a1,-40(s0)
    80005e98:	0591                	addi	a1,a1,4
    80005e9a:	68a8                	ld	a0,80(s1)
    80005e9c:	8d7fb0ef          	jal	ra,80001772 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ea0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ea2:	04055c63          	bgez	a0,80005efa <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005ea6:	fc442783          	lw	a5,-60(s0)
    80005eaa:	07e9                	addi	a5,a5,26
    80005eac:	078e                	slli	a5,a5,0x3
    80005eae:	97a6                	add	a5,a5,s1
    80005eb0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005eb4:	fc042783          	lw	a5,-64(s0)
    80005eb8:	07e9                	addi	a5,a5,26
    80005eba:	078e                	slli	a5,a5,0x3
    80005ebc:	94be                	add	s1,s1,a5
    80005ebe:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ec2:	fd043503          	ld	a0,-48(s0)
    80005ec6:	d19fe0ef          	jal	ra,80004bde <fileclose>
    fileclose(wf);
    80005eca:	fc843503          	ld	a0,-56(s0)
    80005ece:	d11fe0ef          	jal	ra,80004bde <fileclose>
    return -1;
    80005ed2:	57fd                	li	a5,-1
    80005ed4:	a01d                	j	80005efa <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005ed6:	fc442783          	lw	a5,-60(s0)
    80005eda:	0007c763          	bltz	a5,80005ee8 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005ede:	07e9                	addi	a5,a5,26
    80005ee0:	078e                	slli	a5,a5,0x3
    80005ee2:	97a6                	add	a5,a5,s1
    80005ee4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ee8:	fd043503          	ld	a0,-48(s0)
    80005eec:	cf3fe0ef          	jal	ra,80004bde <fileclose>
    fileclose(wf);
    80005ef0:	fc843503          	ld	a0,-56(s0)
    80005ef4:	cebfe0ef          	jal	ra,80004bde <fileclose>
    return -1;
    80005ef8:	57fd                	li	a5,-1
}
    80005efa:	853e                	mv	a0,a5
    80005efc:	70e2                	ld	ra,56(sp)
    80005efe:	7442                	ld	s0,48(sp)
    80005f00:	74a2                	ld	s1,40(sp)
    80005f02:	6121                	addi	sp,sp,64
    80005f04:	8082                	ret
	...

0000000080005f10 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005f10:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005f12:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005f14:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005f16:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005f18:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005f1a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005f1c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005f1e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005f20:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005f22:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005f24:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005f26:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005f28:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005f2a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005f2c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005f2e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005f30:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005f32:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005f34:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005f36:	cc9fc0ef          	jal	ra,80002bfe <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005f3a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005f3c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005f3e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005f40:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005f42:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005f44:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005f46:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005f48:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005f4a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005f4c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005f4e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005f50:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005f52:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005f54:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005f56:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005f58:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005f5a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005f5c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005f5e:	10200073          	sret
	...

0000000080005f6e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f6e:	1141                	addi	sp,sp,-16
    80005f70:	e422                	sd	s0,8(sp)
    80005f72:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f74:	0c0007b7          	lui	a5,0xc000
    80005f78:	4705                	li	a4,1
    80005f7a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f7c:	c3d8                	sw	a4,4(a5)
}
    80005f7e:	6422                	ld	s0,8(sp)
    80005f80:	0141                	addi	sp,sp,16
    80005f82:	8082                	ret

0000000080005f84 <plicinithart>:

void
plicinithart(void)
{
    80005f84:	1141                	addi	sp,sp,-16
    80005f86:	e406                	sd	ra,8(sp)
    80005f88:	e022                	sd	s0,0(sp)
    80005f8a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f8c:	b99fb0ef          	jal	ra,80001b24 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f90:	0085171b          	slliw	a4,a0,0x8
    80005f94:	0c0027b7          	lui	a5,0xc002
    80005f98:	97ba                	add	a5,a5,a4
    80005f9a:	40200713          	li	a4,1026
    80005f9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fa2:	00d5151b          	slliw	a0,a0,0xd
    80005fa6:	0c2017b7          	lui	a5,0xc201
    80005faa:	97aa                	add	a5,a5,a0
    80005fac:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005fb0:	60a2                	ld	ra,8(sp)
    80005fb2:	6402                	ld	s0,0(sp)
    80005fb4:	0141                	addi	sp,sp,16
    80005fb6:	8082                	ret

0000000080005fb8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fb8:	1141                	addi	sp,sp,-16
    80005fba:	e406                	sd	ra,8(sp)
    80005fbc:	e022                	sd	s0,0(sp)
    80005fbe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fc0:	b65fb0ef          	jal	ra,80001b24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fc4:	00d5151b          	slliw	a0,a0,0xd
    80005fc8:	0c2017b7          	lui	a5,0xc201
    80005fcc:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fce:	43c8                	lw	a0,4(a5)
    80005fd0:	60a2                	ld	ra,8(sp)
    80005fd2:	6402                	ld	s0,0(sp)
    80005fd4:	0141                	addi	sp,sp,16
    80005fd6:	8082                	ret

0000000080005fd8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fd8:	1101                	addi	sp,sp,-32
    80005fda:	ec06                	sd	ra,24(sp)
    80005fdc:	e822                	sd	s0,16(sp)
    80005fde:	e426                	sd	s1,8(sp)
    80005fe0:	1000                	addi	s0,sp,32
    80005fe2:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fe4:	b41fb0ef          	jal	ra,80001b24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fe8:	00d5151b          	slliw	a0,a0,0xd
    80005fec:	0c2017b7          	lui	a5,0xc201
    80005ff0:	97aa                	add	a5,a5,a0
    80005ff2:	c3c4                	sw	s1,4(a5)
}
    80005ff4:	60e2                	ld	ra,24(sp)
    80005ff6:	6442                	ld	s0,16(sp)
    80005ff8:	64a2                	ld	s1,8(sp)
    80005ffa:	6105                	addi	sp,sp,32
    80005ffc:	8082                	ret

0000000080005ffe <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ffe:	1141                	addi	sp,sp,-16
    80006000:	e406                	sd	ra,8(sp)
    80006002:	e022                	sd	s0,0(sp)
    80006004:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006006:	479d                	li	a5,7
    80006008:	04a7ca63          	blt	a5,a0,8000605c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000600c:	00246797          	auipc	a5,0x246
    80006010:	ab478793          	addi	a5,a5,-1356 # 8024bac0 <disk>
    80006014:	97aa                	add	a5,a5,a0
    80006016:	0187c783          	lbu	a5,24(a5)
    8000601a:	e7b9                	bnez	a5,80006068 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000601c:	00451693          	slli	a3,a0,0x4
    80006020:	00246797          	auipc	a5,0x246
    80006024:	aa078793          	addi	a5,a5,-1376 # 8024bac0 <disk>
    80006028:	6398                	ld	a4,0(a5)
    8000602a:	9736                	add	a4,a4,a3
    8000602c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006030:	6398                	ld	a4,0(a5)
    80006032:	9736                	add	a4,a4,a3
    80006034:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006038:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000603c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006040:	97aa                	add	a5,a5,a0
    80006042:	4705                	li	a4,1
    80006044:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006048:	00246517          	auipc	a0,0x246
    8000604c:	a9050513          	addi	a0,a0,-1392 # 8024bad8 <disk+0x18>
    80006050:	c3cfc0ef          	jal	ra,8000248c <wakeup>
}
    80006054:	60a2                	ld	ra,8(sp)
    80006056:	6402                	ld	s0,0(sp)
    80006058:	0141                	addi	sp,sp,16
    8000605a:	8082                	ret
    panic("free_desc 1");
    8000605c:	00002517          	auipc	a0,0x2
    80006060:	70450513          	addi	a0,a0,1796 # 80008760 <syscalls+0x368>
    80006064:	f24fa0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80006068:	00002517          	auipc	a0,0x2
    8000606c:	70850513          	addi	a0,a0,1800 # 80008770 <syscalls+0x378>
    80006070:	f18fa0ef          	jal	ra,80000788 <panic>

0000000080006074 <virtio_disk_init>:
{
    80006074:	1101                	addi	sp,sp,-32
    80006076:	ec06                	sd	ra,24(sp)
    80006078:	e822                	sd	s0,16(sp)
    8000607a:	e426                	sd	s1,8(sp)
    8000607c:	e04a                	sd	s2,0(sp)
    8000607e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006080:	00002597          	auipc	a1,0x2
    80006084:	70058593          	addi	a1,a1,1792 # 80008780 <syscalls+0x388>
    80006088:	00246517          	auipc	a0,0x246
    8000608c:	b6050513          	addi	a0,a0,-1184 # 8024bbe8 <disk+0x128>
    80006090:	b91fa0ef          	jal	ra,80000c20 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006094:	100017b7          	lui	a5,0x10001
    80006098:	4398                	lw	a4,0(a5)
    8000609a:	2701                	sext.w	a4,a4
    8000609c:	747277b7          	lui	a5,0x74727
    800060a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060a4:	12f71f63          	bne	a4,a5,800061e2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060a8:	100017b7          	lui	a5,0x10001
    800060ac:	43dc                	lw	a5,4(a5)
    800060ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060b0:	4709                	li	a4,2
    800060b2:	12e79863          	bne	a5,a4,800061e2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060b6:	100017b7          	lui	a5,0x10001
    800060ba:	479c                	lw	a5,8(a5)
    800060bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060be:	12e79263          	bne	a5,a4,800061e2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060c2:	100017b7          	lui	a5,0x10001
    800060c6:	47d8                	lw	a4,12(a5)
    800060c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060ca:	554d47b7          	lui	a5,0x554d4
    800060ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060d2:	10f71863          	bne	a4,a5,800061e2 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060d6:	100017b7          	lui	a5,0x10001
    800060da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060de:	4705                	li	a4,1
    800060e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e2:	470d                	li	a4,3
    800060e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060e6:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060e8:	c7ffe6b7          	lui	a3,0xc7ffe
    800060ec:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47daa5af>
    800060f0:	8f75                	and	a4,a4,a3
    800060f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060f4:	472d                	li	a4,11
    800060f6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060f8:	5bbc                	lw	a5,112(a5)
    800060fa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060fe:	8ba1                	andi	a5,a5,8
    80006100:	0e078763          	beqz	a5,800061ee <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006104:	100017b7          	lui	a5,0x10001
    80006108:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000610c:	43fc                	lw	a5,68(a5)
    8000610e:	2781                	sext.w	a5,a5
    80006110:	0e079563          	bnez	a5,800061fa <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006114:	100017b7          	lui	a5,0x10001
    80006118:	5bdc                	lw	a5,52(a5)
    8000611a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000611c:	0e078563          	beqz	a5,80006206 <virtio_disk_init+0x192>
  if(max < NUM)
    80006120:	471d                	li	a4,7
    80006122:	0ef77863          	bgeu	a4,a5,80006212 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80006126:	a85fa0ef          	jal	ra,80000baa <kalloc>
    8000612a:	00246497          	auipc	s1,0x246
    8000612e:	99648493          	addi	s1,s1,-1642 # 8024bac0 <disk>
    80006132:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006134:	a77fa0ef          	jal	ra,80000baa <kalloc>
    80006138:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000613a:	a71fa0ef          	jal	ra,80000baa <kalloc>
    8000613e:	87aa                	mv	a5,a0
    80006140:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006142:	6088                	ld	a0,0(s1)
    80006144:	cd69                	beqz	a0,8000621e <virtio_disk_init+0x1aa>
    80006146:	00246717          	auipc	a4,0x246
    8000614a:	98273703          	ld	a4,-1662(a4) # 8024bac8 <disk+0x8>
    8000614e:	cb61                	beqz	a4,8000621e <virtio_disk_init+0x1aa>
    80006150:	c7f9                	beqz	a5,8000621e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80006152:	6605                	lui	a2,0x1
    80006154:	4581                	li	a1,0
    80006156:	c1ffa0ef          	jal	ra,80000d74 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000615a:	00246497          	auipc	s1,0x246
    8000615e:	96648493          	addi	s1,s1,-1690 # 8024bac0 <disk>
    80006162:	6605                	lui	a2,0x1
    80006164:	4581                	li	a1,0
    80006166:	6488                	ld	a0,8(s1)
    80006168:	c0dfa0ef          	jal	ra,80000d74 <memset>
  memset(disk.used, 0, PGSIZE);
    8000616c:	6605                	lui	a2,0x1
    8000616e:	4581                	li	a1,0
    80006170:	6888                	ld	a0,16(s1)
    80006172:	c03fa0ef          	jal	ra,80000d74 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006176:	100017b7          	lui	a5,0x10001
    8000617a:	4721                	li	a4,8
    8000617c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000617e:	4098                	lw	a4,0(s1)
    80006180:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006184:	40d8                	lw	a4,4(s1)
    80006186:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000618a:	6498                	ld	a4,8(s1)
    8000618c:	0007069b          	sext.w	a3,a4
    80006190:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006194:	9701                	srai	a4,a4,0x20
    80006196:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000619a:	6898                	ld	a4,16(s1)
    8000619c:	0007069b          	sext.w	a3,a4
    800061a0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061a4:	9701                	srai	a4,a4,0x20
    800061a6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061aa:	4705                	li	a4,1
    800061ac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800061ae:	00e48c23          	sb	a4,24(s1)
    800061b2:	00e48ca3          	sb	a4,25(s1)
    800061b6:	00e48d23          	sb	a4,26(s1)
    800061ba:	00e48da3          	sb	a4,27(s1)
    800061be:	00e48e23          	sb	a4,28(s1)
    800061c2:	00e48ea3          	sb	a4,29(s1)
    800061c6:	00e48f23          	sb	a4,30(s1)
    800061ca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061ce:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d2:	0727a823          	sw	s2,112(a5)
}
    800061d6:	60e2                	ld	ra,24(sp)
    800061d8:	6442                	ld	s0,16(sp)
    800061da:	64a2                	ld	s1,8(sp)
    800061dc:	6902                	ld	s2,0(sp)
    800061de:	6105                	addi	sp,sp,32
    800061e0:	8082                	ret
    panic("could not find virtio disk");
    800061e2:	00002517          	auipc	a0,0x2
    800061e6:	5ae50513          	addi	a0,a0,1454 # 80008790 <syscalls+0x398>
    800061ea:	d9efa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    800061ee:	00002517          	auipc	a0,0x2
    800061f2:	5c250513          	addi	a0,a0,1474 # 800087b0 <syscalls+0x3b8>
    800061f6:	d92fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    800061fa:	00002517          	auipc	a0,0x2
    800061fe:	5d650513          	addi	a0,a0,1494 # 800087d0 <syscalls+0x3d8>
    80006202:	d86fa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80006206:	00002517          	auipc	a0,0x2
    8000620a:	5ea50513          	addi	a0,a0,1514 # 800087f0 <syscalls+0x3f8>
    8000620e:	d7afa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80006212:	00002517          	auipc	a0,0x2
    80006216:	5fe50513          	addi	a0,a0,1534 # 80008810 <syscalls+0x418>
    8000621a:	d6efa0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    8000621e:	00002517          	auipc	a0,0x2
    80006222:	61250513          	addi	a0,a0,1554 # 80008830 <syscalls+0x438>
    80006226:	d62fa0ef          	jal	ra,80000788 <panic>

000000008000622a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000622a:	7119                	addi	sp,sp,-128
    8000622c:	fc86                	sd	ra,120(sp)
    8000622e:	f8a2                	sd	s0,112(sp)
    80006230:	f4a6                	sd	s1,104(sp)
    80006232:	f0ca                	sd	s2,96(sp)
    80006234:	ecce                	sd	s3,88(sp)
    80006236:	e8d2                	sd	s4,80(sp)
    80006238:	e4d6                	sd	s5,72(sp)
    8000623a:	e0da                	sd	s6,64(sp)
    8000623c:	fc5e                	sd	s7,56(sp)
    8000623e:	f862                	sd	s8,48(sp)
    80006240:	f466                	sd	s9,40(sp)
    80006242:	f06a                	sd	s10,32(sp)
    80006244:	ec6e                	sd	s11,24(sp)
    80006246:	0100                	addi	s0,sp,128
    80006248:	8aaa                	mv	s5,a0
    8000624a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000624c:	00c52d03          	lw	s10,12(a0)
    80006250:	001d1d1b          	slliw	s10,s10,0x1
    80006254:	1d02                	slli	s10,s10,0x20
    80006256:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000625a:	00246517          	auipc	a0,0x246
    8000625e:	98e50513          	addi	a0,a0,-1650 # 8024bbe8 <disk+0x128>
    80006262:	a3ffa0ef          	jal	ra,80000ca0 <acquire>
  for(int i = 0; i < 3; i++){
    80006266:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006268:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000626a:	00246b97          	auipc	s7,0x246
    8000626e:	856b8b93          	addi	s7,s7,-1962 # 8024bac0 <disk>
  for(int i = 0; i < 3; i++){
    80006272:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006274:	00246c97          	auipc	s9,0x246
    80006278:	974c8c93          	addi	s9,s9,-1676 # 8024bbe8 <disk+0x128>
    8000627c:	a8a9                	j	800062d6 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    8000627e:	00fb8733          	add	a4,s7,a5
    80006282:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006286:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006288:	0207c563          	bltz	a5,800062b2 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000628c:	2905                	addiw	s2,s2,1
    8000628e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006290:	05690863          	beq	s2,s6,800062e0 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80006294:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006296:	00246717          	auipc	a4,0x246
    8000629a:	82a70713          	addi	a4,a4,-2006 # 8024bac0 <disk>
    8000629e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800062a0:	01874683          	lbu	a3,24(a4)
    800062a4:	fee9                	bnez	a3,8000627e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800062a6:	2785                	addiw	a5,a5,1
    800062a8:	0705                	addi	a4,a4,1
    800062aa:	fe979be3          	bne	a5,s1,800062a0 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800062ae:	57fd                	li	a5,-1
    800062b0:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800062b2:	01205b63          	blez	s2,800062c8 <virtio_disk_rw+0x9e>
    800062b6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800062b8:	000a2503          	lw	a0,0(s4)
    800062bc:	d43ff0ef          	jal	ra,80005ffe <free_desc>
      for(int j = 0; j < i; j++)
    800062c0:	2d85                	addiw	s11,s11,1 # 1001 <_entry-0x7fffefff>
    800062c2:	0a11                	addi	s4,s4,4
    800062c4:	ff2d9ae3          	bne	s11,s2,800062b8 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062c8:	85e6                	mv	a1,s9
    800062ca:	00246517          	auipc	a0,0x246
    800062ce:	80e50513          	addi	a0,a0,-2034 # 8024bad8 <disk+0x18>
    800062d2:	96efc0ef          	jal	ra,80002440 <sleep>
  for(int i = 0; i < 3; i++){
    800062d6:	f8040a13          	addi	s4,s0,-128
{
    800062da:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062dc:	894e                	mv	s2,s3
    800062de:	bf5d                	j	80006294 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062e0:	f8042503          	lw	a0,-128(s0)
    800062e4:	00a50713          	addi	a4,a0,10
    800062e8:	0712                	slli	a4,a4,0x4

  if(write)
    800062ea:	00245797          	auipc	a5,0x245
    800062ee:	7d678793          	addi	a5,a5,2006 # 8024bac0 <disk>
    800062f2:	00e786b3          	add	a3,a5,a4
    800062f6:	01803633          	snez	a2,s8
    800062fa:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062fc:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006300:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006304:	f6070613          	addi	a2,a4,-160
    80006308:	6394                	ld	a3,0(a5)
    8000630a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000630c:	00870593          	addi	a1,a4,8
    80006310:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006312:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006314:	0007b803          	ld	a6,0(a5)
    80006318:	9642                	add	a2,a2,a6
    8000631a:	46c1                	li	a3,16
    8000631c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000631e:	4585                	li	a1,1
    80006320:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006324:	f8442683          	lw	a3,-124(s0)
    80006328:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000632c:	0692                	slli	a3,a3,0x4
    8000632e:	9836                	add	a6,a6,a3
    80006330:	058a8613          	addi	a2,s5,88
    80006334:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006338:	0007b803          	ld	a6,0(a5)
    8000633c:	96c2                	add	a3,a3,a6
    8000633e:	40000613          	li	a2,1024
    80006342:	c690                	sw	a2,8(a3)
  if(write)
    80006344:	001c3613          	seqz	a2,s8
    80006348:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000634c:	00166613          	ori	a2,a2,1
    80006350:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006354:	f8842603          	lw	a2,-120(s0)
    80006358:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000635c:	00250693          	addi	a3,a0,2
    80006360:	0692                	slli	a3,a3,0x4
    80006362:	96be                	add	a3,a3,a5
    80006364:	58fd                	li	a7,-1
    80006366:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000636a:	0612                	slli	a2,a2,0x4
    8000636c:	9832                	add	a6,a6,a2
    8000636e:	f9070713          	addi	a4,a4,-112
    80006372:	973e                	add	a4,a4,a5
    80006374:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006378:	6398                	ld	a4,0(a5)
    8000637a:	9732                	add	a4,a4,a2
    8000637c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000637e:	4609                	li	a2,2
    80006380:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006384:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006388:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    8000638c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006390:	6794                	ld	a3,8(a5)
    80006392:	0026d703          	lhu	a4,2(a3)
    80006396:	8b1d                	andi	a4,a4,7
    80006398:	0706                	slli	a4,a4,0x1
    8000639a:	96ba                	add	a3,a3,a4
    8000639c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800063a0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063a4:	6798                	ld	a4,8(a5)
    800063a6:	00275783          	lhu	a5,2(a4)
    800063aa:	2785                	addiw	a5,a5,1
    800063ac:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063b0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063b4:	100017b7          	lui	a5,0x10001
    800063b8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063bc:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800063c0:	00246917          	auipc	s2,0x246
    800063c4:	82890913          	addi	s2,s2,-2008 # 8024bbe8 <disk+0x128>
  while(b->disk == 1) {
    800063c8:	4485                	li	s1,1
    800063ca:	00b79a63          	bne	a5,a1,800063de <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800063ce:	85ca                	mv	a1,s2
    800063d0:	8556                	mv	a0,s5
    800063d2:	86efc0ef          	jal	ra,80002440 <sleep>
  while(b->disk == 1) {
    800063d6:	004aa783          	lw	a5,4(s5)
    800063da:	fe978ae3          	beq	a5,s1,800063ce <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800063de:	f8042903          	lw	s2,-128(s0)
    800063e2:	00290713          	addi	a4,s2,2
    800063e6:	0712                	slli	a4,a4,0x4
    800063e8:	00245797          	auipc	a5,0x245
    800063ec:	6d878793          	addi	a5,a5,1752 # 8024bac0 <disk>
    800063f0:	97ba                	add	a5,a5,a4
    800063f2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063f6:	00245997          	auipc	s3,0x245
    800063fa:	6ca98993          	addi	s3,s3,1738 # 8024bac0 <disk>
    800063fe:	00491713          	slli	a4,s2,0x4
    80006402:	0009b783          	ld	a5,0(s3)
    80006406:	97ba                	add	a5,a5,a4
    80006408:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000640c:	854a                	mv	a0,s2
    8000640e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006412:	bedff0ef          	jal	ra,80005ffe <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006416:	8885                	andi	s1,s1,1
    80006418:	f0fd                	bnez	s1,800063fe <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000641a:	00245517          	auipc	a0,0x245
    8000641e:	7ce50513          	addi	a0,a0,1998 # 8024bbe8 <disk+0x128>
    80006422:	917fa0ef          	jal	ra,80000d38 <release>
}
    80006426:	70e6                	ld	ra,120(sp)
    80006428:	7446                	ld	s0,112(sp)
    8000642a:	74a6                	ld	s1,104(sp)
    8000642c:	7906                	ld	s2,96(sp)
    8000642e:	69e6                	ld	s3,88(sp)
    80006430:	6a46                	ld	s4,80(sp)
    80006432:	6aa6                	ld	s5,72(sp)
    80006434:	6b06                	ld	s6,64(sp)
    80006436:	7be2                	ld	s7,56(sp)
    80006438:	7c42                	ld	s8,48(sp)
    8000643a:	7ca2                	ld	s9,40(sp)
    8000643c:	7d02                	ld	s10,32(sp)
    8000643e:	6de2                	ld	s11,24(sp)
    80006440:	6109                	addi	sp,sp,128
    80006442:	8082                	ret

0000000080006444 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006444:	1101                	addi	sp,sp,-32
    80006446:	ec06                	sd	ra,24(sp)
    80006448:	e822                	sd	s0,16(sp)
    8000644a:	e426                	sd	s1,8(sp)
    8000644c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000644e:	00245497          	auipc	s1,0x245
    80006452:	67248493          	addi	s1,s1,1650 # 8024bac0 <disk>
    80006456:	00245517          	auipc	a0,0x245
    8000645a:	79250513          	addi	a0,a0,1938 # 8024bbe8 <disk+0x128>
    8000645e:	843fa0ef          	jal	ra,80000ca0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006462:	10001737          	lui	a4,0x10001
    80006466:	533c                	lw	a5,96(a4)
    80006468:	8b8d                	andi	a5,a5,3
    8000646a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000646c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006470:	689c                	ld	a5,16(s1)
    80006472:	0204d703          	lhu	a4,32(s1)
    80006476:	0027d783          	lhu	a5,2(a5)
    8000647a:	04f70663          	beq	a4,a5,800064c6 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000647e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006482:	6898                	ld	a4,16(s1)
    80006484:	0204d783          	lhu	a5,32(s1)
    80006488:	8b9d                	andi	a5,a5,7
    8000648a:	078e                	slli	a5,a5,0x3
    8000648c:	97ba                	add	a5,a5,a4
    8000648e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006490:	00278713          	addi	a4,a5,2
    80006494:	0712                	slli	a4,a4,0x4
    80006496:	9726                	add	a4,a4,s1
    80006498:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000649c:	e321                	bnez	a4,800064dc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000649e:	0789                	addi	a5,a5,2
    800064a0:	0792                	slli	a5,a5,0x4
    800064a2:	97a6                	add	a5,a5,s1
    800064a4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800064a6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064aa:	fe3fb0ef          	jal	ra,8000248c <wakeup>

    disk.used_idx += 1;
    800064ae:	0204d783          	lhu	a5,32(s1)
    800064b2:	2785                	addiw	a5,a5,1
    800064b4:	17c2                	slli	a5,a5,0x30
    800064b6:	93c1                	srli	a5,a5,0x30
    800064b8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064bc:	6898                	ld	a4,16(s1)
    800064be:	00275703          	lhu	a4,2(a4)
    800064c2:	faf71ee3          	bne	a4,a5,8000647e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800064c6:	00245517          	auipc	a0,0x245
    800064ca:	72250513          	addi	a0,a0,1826 # 8024bbe8 <disk+0x128>
    800064ce:	86bfa0ef          	jal	ra,80000d38 <release>
}
    800064d2:	60e2                	ld	ra,24(sp)
    800064d4:	6442                	ld	s0,16(sp)
    800064d6:	64a2                	ld	s1,8(sp)
    800064d8:	6105                	addi	sp,sp,32
    800064da:	8082                	ret
      panic("virtio_disk_intr status");
    800064dc:	00002517          	auipc	a0,0x2
    800064e0:	36c50513          	addi	a0,a0,876 # 80008848 <syscalls+0x450>
    800064e4:	aa4fa0ef          	jal	ra,80000788 <panic>

00000000800064e8 <shm_init>:
  struct shmobj obj[NSHM];
} shmt;

void
shm_init(void)
{
    800064e8:	1141                	addi	sp,sp,-16
    800064ea:	e406                	sd	ra,8(sp)
    800064ec:	e022                	sd	s0,0(sp)
    800064ee:	0800                	addi	s0,sp,16
  initlock(&shmt.lock, "shmt");
    800064f0:	00002597          	auipc	a1,0x2
    800064f4:	37058593          	addi	a1,a1,880 # 80008860 <syscalls+0x468>
    800064f8:	00245517          	auipc	a0,0x245
    800064fc:	70850513          	addi	a0,a0,1800 # 8024bc00 <shmt>
    80006500:	f20fa0ef          	jal	ra,80000c20 <initlock>
}
    80006504:	60a2                	ld	ra,8(sp)
    80006506:	6402                	ld	s0,0(sp)
    80006508:	0141                	addi	sp,sp,16
    8000650a:	8082                	ret

000000008000650c <shm_get>:

// 找到或创建 key 对应对象，返回 index；失败返回 -1
int
shm_get(int key, int npages)
{
    8000650c:	7179                	addi	sp,sp,-48
    8000650e:	f406                	sd	ra,40(sp)
    80006510:	f022                	sd	s0,32(sp)
    80006512:	ec26                	sd	s1,24(sp)
    80006514:	e84a                	sd	s2,16(sp)
    80006516:	e44e                	sd	s3,8(sp)
    80006518:	1800                	addi	s0,sp,48
    8000651a:	892a                	mv	s2,a0
    8000651c:	89ae                	mv	s3,a1
  acquire(&shmt.lock);
    8000651e:	00245517          	auipc	a0,0x245
    80006522:	6e250513          	addi	a0,a0,1762 # 8024bc00 <shmt>
    80006526:	f7afa0ef          	jal	ra,80000ca0 <acquire>

  // 先找已有
  for(int i=0;i<NSHM;i++){
    8000652a:	00245697          	auipc	a3,0x245
    8000652e:	6ee68693          	addi	a3,a3,1774 # 8024bc18 <shmt+0x18>
  acquire(&shmt.lock);
    80006532:	87b6                	mv	a5,a3
  for(int i=0;i<NSHM;i++){
    80006534:	4481                	li	s1,0
    80006536:	6605                	lui	a2,0x1
    80006538:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    8000653c:	4841                	li	a6,16
    8000653e:	a015                	j	80006562 <shm_get+0x56>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(shmt.obj[i].deleted){
        release(&shmt.lock);
    80006540:	00245517          	auipc	a0,0x245
    80006544:	6c050513          	addi	a0,a0,1728 # 8024bc00 <shmt>
    80006548:	ff0fa0ef          	jal	ra,80000d38 <release>
        return -1;
    8000654c:	54fd                	li	s1,-1
    8000654e:	a879                	j	800065ec <shm_get+0xe0>
      }
      if(npages > shmt.obj[i].npages){
        release(&shmt.lock);
    80006550:	853a                	mv	a0,a4
    80006552:	fe6fa0ef          	jal	ra,80000d38 <release>
        return -1;
    80006556:	54fd                	li	s1,-1
    80006558:	a851                	j	800065ec <shm_get+0xe0>
  for(int i=0;i<NSHM;i++){
    8000655a:	2485                	addiw	s1,s1,1
    8000655c:	97b2                	add	a5,a5,a2
    8000655e:	07048563          	beq	s1,a6,800065c8 <shm_get+0xbc>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    80006562:	4398                	lw	a4,0(a5)
    80006564:	db7d                	beqz	a4,8000655a <shm_get+0x4e>
    80006566:	43d8                	lw	a4,4(a5)
    80006568:	ff2719e3          	bne	a4,s2,8000655a <shm_get+0x4e>
      if(shmt.obj[i].deleted){
    8000656c:	6785                	lui	a5,0x1
    8000656e:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    80006572:	02d486b3          	mul	a3,s1,a3
    80006576:	00245717          	auipc	a4,0x245
    8000657a:	68a70713          	addi	a4,a4,1674 # 8024bc00 <shmt>
    8000657e:	9736                	add	a4,a4,a3
    80006580:	97ba                	add	a5,a5,a4
    80006582:	82c7a783          	lw	a5,-2004(a5)
    80006586:	ffcd                	bnez	a5,80006540 <shm_get+0x34>
      if(npages > shmt.obj[i].npages){
    80006588:	6785                	lui	a5,0x1
    8000658a:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000658e:	02f487b3          	mul	a5,s1,a5
    80006592:	00245717          	auipc	a4,0x245
    80006596:	66e70713          	addi	a4,a4,1646 # 8024bc00 <shmt>
    8000659a:	97ba                	add	a5,a5,a4
    8000659c:	539c                	lw	a5,32(a5)
    8000659e:	fb37c9e3          	blt	a5,s3,80006550 <shm_get+0x44>
      }
      shmt.obj[i].refcnt++;
    800065a2:	00245517          	auipc	a0,0x245
    800065a6:	65e50513          	addi	a0,a0,1630 # 8024bc00 <shmt>
    800065aa:	6785                	lui	a5,0x1
    800065ac:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800065b0:	02e48733          	mul	a4,s1,a4
    800065b4:	972a                	add	a4,a4,a0
    800065b6:	97ba                	add	a5,a5,a4
    800065b8:	8287a703          	lw	a4,-2008(a5)
    800065bc:	2705                	addiw	a4,a4,1
    800065be:	82e7a423          	sw	a4,-2008(a5)
      release(&shmt.lock);
    800065c2:	f76fa0ef          	jal	ra,80000d38 <release>
      return i;
    800065c6:	a01d                	j	800065ec <shm_get+0xe0>
    }
  }

  // 再创建
  for(int i=0;i<NSHM;i++){
    800065c8:	4481                	li	s1,0
    800065ca:	6705                	lui	a4,0x1
    800065cc:	81870713          	addi	a4,a4,-2024 # 818 <_entry-0x7ffff7e8>
    800065d0:	4641                	li	a2,16
    if(!shmt.obj[i].used){
    800065d2:	429c                	lw	a5,0(a3)
    800065d4:	c785                	beqz	a5,800065fc <shm_get+0xf0>
  for(int i=0;i<NSHM;i++){
    800065d6:	2485                	addiw	s1,s1,1
    800065d8:	96ba                	add	a3,a3,a4
    800065da:	fec49ce3          	bne	s1,a2,800065d2 <shm_get+0xc6>
      release(&shmt.lock);
      return i;
    }
  }

  release(&shmt.lock);
    800065de:	00245517          	auipc	a0,0x245
    800065e2:	62250513          	addi	a0,a0,1570 # 8024bc00 <shmt>
    800065e6:	f52fa0ef          	jal	ra,80000d38 <release>
  return -1;
    800065ea:	54fd                	li	s1,-1
}
    800065ec:	8526                	mv	a0,s1
    800065ee:	70a2                	ld	ra,40(sp)
    800065f0:	7402                	ld	s0,32(sp)
    800065f2:	64e2                	ld	s1,24(sp)
    800065f4:	6942                	ld	s2,16(sp)
    800065f6:	69a2                	ld	s3,8(sp)
    800065f8:	6145                	addi	sp,sp,48
    800065fa:	8082                	ret
      shmt.obj[i].deleted = 0;
    800065fc:	00245617          	auipc	a2,0x245
    80006600:	60460613          	addi	a2,a2,1540 # 8024bc00 <shmt>
    80006604:	6785                	lui	a5,0x1
    80006606:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000660a:	02d486b3          	mul	a3,s1,a3
    8000660e:	00d60733          	add	a4,a2,a3
    80006612:	97ba                	add	a5,a5,a4
    80006614:	8207a623          	sw	zero,-2004(a5)
      shmt.obj[i].used = 1;
    80006618:	4585                	li	a1,1
    8000661a:	cf0c                	sw	a1,24(a4)
      shmt.obj[i].key = key;
    8000661c:	01272e23          	sw	s2,28(a4)
      shmt.obj[i].npages = npages;
    80006620:	03372023          	sw	s3,32(a4)
      shmt.obj[i].refcnt = 1;
    80006624:	82b7a423          	sw	a1,-2008(a5)
      for(int j=0;j<SHM_MAXPG;j++) shmt.obj[i].pa[j] = 0;
    80006628:	02868793          	addi	a5,a3,40
    8000662c:	97b2                	add	a5,a5,a2
    8000662e:	00246717          	auipc	a4,0x246
    80006632:	dfa70713          	addi	a4,a4,-518 # 8024c428 <shmt+0x828>
    80006636:	9736                	add	a4,a4,a3
    80006638:	0007b023          	sd	zero,0(a5)
    8000663c:	07a1                	addi	a5,a5,8
    8000663e:	fee79de3          	bne	a5,a4,80006638 <shm_get+0x12c>
      release(&shmt.lock);
    80006642:	00245517          	auipc	a0,0x245
    80006646:	5be50513          	addi	a0,a0,1470 # 8024bc00 <shmt>
    8000664a:	eeefa0ef          	jal	ra,80000d38 <release>
      return i;
    8000664e:	bf79                	j	800065ec <shm_get+0xe0>

0000000080006650 <shm_put>:


// refcnt--，若为 0 则释放对象里的所有页（kfree 会走页 refcnt，安全）
void
shm_put(int key)
{
    80006650:	7179                	addi	sp,sp,-48
    80006652:	f406                	sd	ra,40(sp)
    80006654:	f022                	sd	s0,32(sp)
    80006656:	ec26                	sd	s1,24(sp)
    80006658:	e84a                	sd	s2,16(sp)
    8000665a:	e44e                	sd	s3,8(sp)
    8000665c:	e052                	sd	s4,0(sp)
    8000665e:	1800                	addi	s0,sp,48
    80006660:	892a                	mv	s2,a0
  acquire(&shmt.lock);
    80006662:	00245517          	auipc	a0,0x245
    80006666:	59e50513          	addi	a0,a0,1438 # 8024bc00 <shmt>
    8000666a:	e36fa0ef          	jal	ra,80000ca0 <acquire>
  for(int i=0;i<NSHM;i++){
    8000666e:	00245797          	auipc	a5,0x245
    80006672:	5aa78793          	addi	a5,a5,1450 # 8024bc18 <shmt+0x18>
    80006676:	4481                	li	s1,0
    80006678:	6685                	lui	a3,0x1
    8000667a:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000667e:	4641                	li	a2,16
    80006680:	a0b5                	j	800066ec <shm_put+0x9c>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
      if(shmt.obj[i].refcnt < 1)
        panic("shm_put: refcnt");
    80006682:	00002517          	auipc	a0,0x2
    80006686:	1e650513          	addi	a0,a0,486 # 80008868 <syscalls+0x470>
    8000668a:	8fefa0ef          	jal	ra,80000788 <panic>
      shmt.obj[i].refcnt--;
      if(shmt.obj[i].refcnt == 0){
        for(int j=0;j<shmt.obj[i].npages;j++){
    8000668e:	2985                	addiw	s3,s3,1
    80006690:	0921                	addi	s2,s2,8
    80006692:	020a2783          	lw	a5,32(s4)
    80006696:	00f9da63          	bge	s3,a5,800066aa <shm_put+0x5a>
          if(shmt.obj[i].pa[j]){
    8000669a:	00093503          	ld	a0,0(s2)
    8000669e:	d965                	beqz	a0,8000668e <shm_put+0x3e>
            kfree((void*)shmt.obj[i].pa[j]);
    800066a0:	bdafa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    800066a4:	00093023          	sd	zero,0(s2)
    800066a8:	b7dd                	j	8000668e <shm_put+0x3e>
          }
        }
        shmt.obj[i].used = 0;
    800066aa:	6785                	lui	a5,0x1
    800066ac:	81878713          	addi	a4,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800066b0:	02e484b3          	mul	s1,s1,a4
    800066b4:	00245717          	auipc	a4,0x245
    800066b8:	54c70713          	addi	a4,a4,1356 # 8024bc00 <shmt>
    800066bc:	9726                	add	a4,a4,s1
    800066be:	00072c23          	sw	zero,24(a4)
        shmt.obj[i].deleted = 0;
    800066c2:	97ba                	add	a5,a5,a4
    800066c4:	8207a623          	sw	zero,-2004(a5)
      }
      break;
    }
  }
  release(&shmt.lock);
    800066c8:	00245517          	auipc	a0,0x245
    800066cc:	53850513          	addi	a0,a0,1336 # 8024bc00 <shmt>
    800066d0:	e68fa0ef          	jal	ra,80000d38 <release>
}
    800066d4:	70a2                	ld	ra,40(sp)
    800066d6:	7402                	ld	s0,32(sp)
    800066d8:	64e2                	ld	s1,24(sp)
    800066da:	6942                	ld	s2,16(sp)
    800066dc:	69a2                	ld	s3,8(sp)
    800066de:	6a02                	ld	s4,0(sp)
    800066e0:	6145                	addi	sp,sp,48
    800066e2:	8082                	ret
  for(int i=0;i<NSHM;i++){
    800066e4:	2485                	addiw	s1,s1,1
    800066e6:	97b6                	add	a5,a5,a3
    800066e8:	fec480e3          	beq	s1,a2,800066c8 <shm_put+0x78>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    800066ec:	4398                	lw	a4,0(a5)
    800066ee:	db7d                	beqz	a4,800066e4 <shm_put+0x94>
    800066f0:	43d8                	lw	a4,4(a5)
    800066f2:	ff2719e3          	bne	a4,s2,800066e4 <shm_put+0x94>
      if(shmt.obj[i].refcnt < 1)
    800066f6:	6785                	lui	a5,0x1
    800066f8:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800066fc:	02d486b3          	mul	a3,s1,a3
    80006700:	00245717          	auipc	a4,0x245
    80006704:	50070713          	addi	a4,a4,1280 # 8024bc00 <shmt>
    80006708:	9736                	add	a4,a4,a3
    8000670a:	97ba                	add	a5,a5,a4
    8000670c:	8287a783          	lw	a5,-2008(a5)
    80006710:	f6f059e3          	blez	a5,80006682 <shm_put+0x32>
      shmt.obj[i].refcnt--;
    80006714:	37fd                	addiw	a5,a5,-1
    80006716:	0007899b          	sext.w	s3,a5
    8000671a:	6705                	lui	a4,0x1
    8000671c:	81870613          	addi	a2,a4,-2024 # 818 <_entry-0x7ffff7e8>
    80006720:	02c48633          	mul	a2,s1,a2
    80006724:	00245697          	auipc	a3,0x245
    80006728:	4dc68693          	addi	a3,a3,1244 # 8024bc00 <shmt>
    8000672c:	96b2                	add	a3,a3,a2
    8000672e:	9736                	add	a4,a4,a3
    80006730:	82f72423          	sw	a5,-2008(a4)
      if(shmt.obj[i].refcnt == 0){
    80006734:	f8099ae3          	bnez	s3,800066c8 <shm_put+0x78>
        for(int j=0;j<shmt.obj[i].npages;j++){
    80006738:	529c                	lw	a5,32(a3)
    8000673a:	f6f058e3          	blez	a5,800066aa <shm_put+0x5a>
    8000673e:	00245797          	auipc	a5,0x245
    80006742:	4ea78793          	addi	a5,a5,1258 # 8024bc28 <shmt+0x28>
    80006746:	00f60933          	add	s2,a2,a5
    8000674a:	8a36                	mv	s4,a3
    8000674c:	b7b9                	j	8000669a <shm_put+0x4a>

000000008000674e <shm_getpa>:

// 取某页的 pa；若未分配则分配（lazy），返回 pa 或 0
uint64
shm_getpa(int key, int page_index)
{
    8000674e:	7179                	addi	sp,sp,-48
    80006750:	f406                	sd	ra,40(sp)
    80006752:	f022                	sd	s0,32(sp)
    80006754:	ec26                	sd	s1,24(sp)
    80006756:	e84a                	sd	s2,16(sp)
    80006758:	e44e                	sd	s3,8(sp)
    8000675a:	e052                	sd	s4,0(sp)
    8000675c:	1800                	addi	s0,sp,48
    8000675e:	892a                	mv	s2,a0
    80006760:	89ae                	mv	s3,a1
  uint64 pa = 0;
  acquire(&shmt.lock);
    80006762:	00245517          	auipc	a0,0x245
    80006766:	49e50513          	addi	a0,a0,1182 # 8024bc00 <shmt>
    8000676a:	d36fa0ef          	jal	ra,80000ca0 <acquire>

  for(int i=0;i<NSHM;i++){
    8000676e:	00245797          	auipc	a5,0x245
    80006772:	4aa78793          	addi	a5,a5,1194 # 8024bc18 <shmt+0x18>
    80006776:	4481                	li	s1,0
    80006778:	6685                	lui	a3,0x1
    8000677a:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    8000677e:	4641                	li	a2,16
    80006780:	a82d                	j	800067ba <shm_getpa+0x6c>
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
        pa = 0;
        break;
      }
      if(shmt.obj[i].pa[page_index] == 0){
        void *mem = kalloc();
    80006782:	c28fa0ef          	jal	ra,80000baa <kalloc>
    80006786:	8a2a                	mv	s4,a0
        if(mem == 0){
    80006788:	cd41                	beqz	a0,80006820 <shm_getpa+0xd2>
          pa = 0;
          break;
        }
        memset(mem, 0, PGSIZE);
    8000678a:	6605                	lui	a2,0x1
    8000678c:	4581                	li	a1,0
    8000678e:	de6fa0ef          	jal	ra,80000d74 <memset>
        shmt.obj[i].pa[page_index] = (uint64)mem;
    80006792:	00649793          	slli	a5,s1,0x6
    80006796:	97a6                	add	a5,a5,s1
    80006798:	078a                	slli	a5,a5,0x2
    8000679a:	8f85                	sub	a5,a5,s1
    8000679c:	97ce                	add	a5,a5,s3
    8000679e:	0791                	addi	a5,a5,4
    800067a0:	078e                	slli	a5,a5,0x3
    800067a2:	00245717          	auipc	a4,0x245
    800067a6:	45e70713          	addi	a4,a4,1118 # 8024bc00 <shmt>
    800067aa:	97ba                	add	a5,a5,a4
    800067ac:	0147b423          	sd	s4,8(a5)
    800067b0:	a0b9                	j	800067fe <shm_getpa+0xb0>
  for(int i=0;i<NSHM;i++){
    800067b2:	2485                	addiw	s1,s1,1
    800067b4:	97b6                	add	a5,a5,a3
    800067b6:	06c48463          	beq	s1,a2,8000681e <shm_getpa+0xd0>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    800067ba:	4398                	lw	a4,0(a5)
    800067bc:	db7d                	beqz	a4,800067b2 <shm_getpa+0x64>
    800067be:	43d8                	lw	a4,4(a5)
    800067c0:	ff2719e3          	bne	a4,s2,800067b2 <shm_getpa+0x64>
        pa = 0;
    800067c4:	4901                	li	s2,0
      if(page_index < 0 || page_index >= shmt.obj[i].npages){
    800067c6:	0409cd63          	bltz	s3,80006820 <shm_getpa+0xd2>
    800067ca:	6785                	lui	a5,0x1
    800067cc:	81878793          	addi	a5,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800067d0:	02f487b3          	mul	a5,s1,a5
    800067d4:	00245717          	auipc	a4,0x245
    800067d8:	42c70713          	addi	a4,a4,1068 # 8024bc00 <shmt>
    800067dc:	97ba                	add	a5,a5,a4
    800067de:	539c                	lw	a5,32(a5)
    800067e0:	04f9d063          	bge	s3,a5,80006820 <shm_getpa+0xd2>
      if(shmt.obj[i].pa[page_index] == 0){
    800067e4:	00649793          	slli	a5,s1,0x6
    800067e8:	97a6                	add	a5,a5,s1
    800067ea:	078a                	slli	a5,a5,0x2
    800067ec:	8f85                	sub	a5,a5,s1
    800067ee:	97ce                	add	a5,a5,s3
    800067f0:	0791                	addi	a5,a5,4
    800067f2:	078e                	slli	a5,a5,0x3
    800067f4:	97ba                	add	a5,a5,a4
    800067f6:	0087b903          	ld	s2,8(a5)
    800067fa:	f80904e3          	beqz	s2,80006782 <shm_getpa+0x34>
      }
      pa = shmt.obj[i].pa[page_index];
    800067fe:	00649793          	slli	a5,s1,0x6
    80006802:	97a6                	add	a5,a5,s1
    80006804:	078a                	slli	a5,a5,0x2
    80006806:	8f85                	sub	a5,a5,s1
    80006808:	97ce                	add	a5,a5,s3
    8000680a:	0791                	addi	a5,a5,4
    8000680c:	078e                	slli	a5,a5,0x3
    8000680e:	00245717          	auipc	a4,0x245
    80006812:	3f270713          	addi	a4,a4,1010 # 8024bc00 <shmt>
    80006816:	97ba                	add	a5,a5,a4
    80006818:	0087b903          	ld	s2,8(a5)
      break;
    8000681c:	a011                	j	80006820 <shm_getpa+0xd2>
  uint64 pa = 0;
    8000681e:	4901                	li	s2,0
    }
  }

  release(&shmt.lock);
    80006820:	00245517          	auipc	a0,0x245
    80006824:	3e050513          	addi	a0,a0,992 # 8024bc00 <shmt>
    80006828:	d10fa0ef          	jal	ra,80000d38 <release>
  return pa;
}
    8000682c:	854a                	mv	a0,s2
    8000682e:	70a2                	ld	ra,40(sp)
    80006830:	7402                	ld	s0,32(sp)
    80006832:	64e2                	ld	s1,24(sp)
    80006834:	6942                	ld	s2,16(sp)
    80006836:	69a2                	ld	s3,8(sp)
    80006838:	6a02                	ld	s4,0(sp)
    8000683a:	6145                	addi	sp,sp,48
    8000683c:	8082                	ret

000000008000683e <shm_ctl>:


int
shm_ctl(int key, int cmd)
{
  if(cmd != IPC_RMID)
    8000683e:	10059363          	bnez	a1,80006944 <shm_ctl+0x106>
{
    80006842:	7139                	addi	sp,sp,-64
    80006844:	fc06                	sd	ra,56(sp)
    80006846:	f822                	sd	s0,48(sp)
    80006848:	f426                	sd	s1,40(sp)
    8000684a:	f04a                	sd	s2,32(sp)
    8000684c:	ec4e                	sd	s3,24(sp)
    8000684e:	e852                	sd	s4,16(sp)
    80006850:	e456                	sd	s5,8(sp)
    80006852:	0080                	addi	s0,sp,64
    80006854:	892a                	mv	s2,a0
    80006856:	89ae                	mv	s3,a1
    return -1;

  acquire(&shmt.lock);
    80006858:	00245517          	auipc	a0,0x245
    8000685c:	3a850513          	addi	a0,a0,936 # 8024bc00 <shmt>
    80006860:	c40fa0ef          	jal	ra,80000ca0 <acquire>

  for(int i = 0; i < NSHM; i++){
    80006864:	00245797          	auipc	a5,0x245
    80006868:	3b478793          	addi	a5,a5,948 # 8024bc18 <shmt+0x18>
    8000686c:	84ce                	mv	s1,s3
    8000686e:	6685                	lui	a3,0x1
    80006870:	81868693          	addi	a3,a3,-2024 # 818 <_entry-0x7ffff7e8>
    80006874:	4641                	li	a2,16
    80006876:	a8b1                	j	800068d2 <shm_ctl+0x94>

      // 如果没人引用了，立刻释放
      if(shmt.obj[i].refcnt == 0){
        for(int j = 0; j < shmt.obj[i].npages; j++){
          if(shmt.obj[i].pa[j]){
            kfree((void*)shmt.obj[i].pa[j]);
    80006878:	a02fa0ef          	jal	ra,80000a7a <kfree>
            shmt.obj[i].pa[j] = 0;
    8000687c:	00093023          	sd	zero,0(s2)
        for(int j = 0; j < shmt.obj[i].npages; j++){
    80006880:	2a05                	addiw	s4,s4,1
    80006882:	0921                	addi	s2,s2,8
    80006884:	020aa783          	lw	a5,32(s5)
    80006888:	00fa5663          	bge	s4,a5,80006894 <shm_ctl+0x56>
          if(shmt.obj[i].pa[j]){
    8000688c:	00093503          	ld	a0,0(s2)
    80006890:	d965                	beqz	a0,80006880 <shm_ctl+0x42>
    80006892:	b7dd                	j	80006878 <shm_ctl+0x3a>
          }
        }
        shmt.obj[i].used = 0;
    80006894:	6705                	lui	a4,0x1
    80006896:	81870793          	addi	a5,a4,-2024 # 818 <_entry-0x7ffff7e8>
    8000689a:	02f484b3          	mul	s1,s1,a5
    8000689e:	00245797          	auipc	a5,0x245
    800068a2:	36278793          	addi	a5,a5,866 # 8024bc00 <shmt>
    800068a6:	97a6                	add	a5,a5,s1
    800068a8:	0007ac23          	sw	zero,24(a5)
        shmt.obj[i].deleted = 0;
    800068ac:	973e                	add	a4,a4,a5
    800068ae:	82072623          	sw	zero,-2004(a4)
        shmt.obj[i].key = 0;     
    800068b2:	0007ae23          	sw	zero,28(a5)
        shmt.obj[i].npages = 0;  
    800068b6:	0207a023          	sw	zero,32(a5)

      }


      release(&shmt.lock);
    800068ba:	00245517          	auipc	a0,0x245
    800068be:	34650513          	addi	a0,a0,838 # 8024bc00 <shmt>
    800068c2:	c76fa0ef          	jal	ra,80000d38 <release>
      return 0;
    800068c6:	854e                	mv	a0,s3
    800068c8:	a0ad                	j	80006932 <shm_ctl+0xf4>
  for(int i = 0; i < NSHM; i++){
    800068ca:	2485                	addiw	s1,s1,1
    800068cc:	97b6                	add	a5,a5,a3
    800068ce:	04c48b63          	beq	s1,a2,80006924 <shm_ctl+0xe6>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    800068d2:	4398                	lw	a4,0(a5)
    800068d4:	db7d                	beqz	a4,800068ca <shm_ctl+0x8c>
    800068d6:	43d8                	lw	a4,4(a5)
    800068d8:	ff2719e3          	bne	a4,s2,800068ca <shm_ctl+0x8c>
      shmt.obj[i].deleted = 1;
    800068dc:	6785                	lui	a5,0x1
    800068de:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    800068e2:	02d486b3          	mul	a3,s1,a3
    800068e6:	00245717          	auipc	a4,0x245
    800068ea:	31a70713          	addi	a4,a4,794 # 8024bc00 <shmt>
    800068ee:	9736                	add	a4,a4,a3
    800068f0:	97ba                	add	a5,a5,a4
    800068f2:	4705                	li	a4,1
    800068f4:	82e7a623          	sw	a4,-2004(a5)
      if(shmt.obj[i].refcnt == 0){
    800068f8:	8287aa03          	lw	s4,-2008(a5)
    800068fc:	fa0a1fe3          	bnez	s4,800068ba <shm_ctl+0x7c>
        for(int j = 0; j < shmt.obj[i].npages; j++){
    80006900:	00245717          	auipc	a4,0x245
    80006904:	30070713          	addi	a4,a4,768 # 8024bc00 <shmt>
    80006908:	00d707b3          	add	a5,a4,a3
    8000690c:	539c                	lw	a5,32(a5)
    8000690e:	f8f053e3          	blez	a5,80006894 <shm_ctl+0x56>
    80006912:	00245797          	auipc	a5,0x245
    80006916:	31678793          	addi	a5,a5,790 # 8024bc28 <shmt+0x28>
    8000691a:	00f68933          	add	s2,a3,a5
    8000691e:	00d70ab3          	add	s5,a4,a3
    80006922:	b7ad                	j	8000688c <shm_ctl+0x4e>
    }
  }

  release(&shmt.lock);
    80006924:	00245517          	auipc	a0,0x245
    80006928:	2dc50513          	addi	a0,a0,732 # 8024bc00 <shmt>
    8000692c:	c0cfa0ef          	jal	ra,80000d38 <release>
  return -1; // key 不存在
    80006930:	557d                	li	a0,-1
}
    80006932:	70e2                	ld	ra,56(sp)
    80006934:	7442                	ld	s0,48(sp)
    80006936:	74a2                	ld	s1,40(sp)
    80006938:	7902                	ld	s2,32(sp)
    8000693a:	69e2                	ld	s3,24(sp)
    8000693c:	6a42                	ld	s4,16(sp)
    8000693e:	6aa2                	ld	s5,8(sp)
    80006940:	6121                	addi	sp,sp,64
    80006942:	8082                	ret
    return -1;
    80006944:	557d                	li	a0,-1
}
    80006946:	8082                	ret

0000000080006948 <shm_is_deleted>:

int
shm_is_deleted(int key)
{
    80006948:	1101                	addi	sp,sp,-32
    8000694a:	ec06                	sd	ra,24(sp)
    8000694c:	e822                	sd	s0,16(sp)
    8000694e:	e426                	sd	s1,8(sp)
    80006950:	1000                	addi	s0,sp,32
    80006952:	84aa                	mv	s1,a0
  int del = 0; // 默认0,不存在就允许创建
  acquire(&shmt.lock);
    80006954:	00245517          	auipc	a0,0x245
    80006958:	2ac50513          	addi	a0,a0,684 # 8024bc00 <shmt>
    8000695c:	b44fa0ef          	jal	ra,80000ca0 <acquire>
  for(int i=0;i<NSHM;i++){
    80006960:	00245797          	auipc	a5,0x245
    80006964:	2b878793          	addi	a5,a5,696 # 8024bc18 <shmt+0x18>
    80006968:	4701                	li	a4,0
    8000696a:	6605                	lui	a2,0x1
    8000696c:	81860613          	addi	a2,a2,-2024 # 818 <_entry-0x7ffff7e8>
    80006970:	45c1                	li	a1,16
    80006972:	a029                	j	8000697c <shm_is_deleted+0x34>
    80006974:	2705                	addiw	a4,a4,1
    80006976:	97b2                	add	a5,a5,a2
    80006978:	02b70563          	beq	a4,a1,800069a2 <shm_is_deleted+0x5a>
    if(shmt.obj[i].used && shmt.obj[i].key == key){
    8000697c:	4394                	lw	a3,0(a5)
    8000697e:	dafd                	beqz	a3,80006974 <shm_is_deleted+0x2c>
    80006980:	43d4                	lw	a3,4(a5)
    80006982:	fe9699e3          	bne	a3,s1,80006974 <shm_is_deleted+0x2c>
      del = shmt.obj[i].deleted;
    80006986:	6785                	lui	a5,0x1
    80006988:	81878693          	addi	a3,a5,-2024 # 818 <_entry-0x7ffff7e8>
    8000698c:	02d70733          	mul	a4,a4,a3
    80006990:	00245697          	auipc	a3,0x245
    80006994:	27068693          	addi	a3,a3,624 # 8024bc00 <shmt>
    80006998:	9736                	add	a4,a4,a3
    8000699a:	97ba                	add	a5,a5,a4
    8000699c:	82c7a483          	lw	s1,-2004(a5)
      break;
    800069a0:	a011                	j	800069a4 <shm_is_deleted+0x5c>
  int del = 0; // 默认0,不存在就允许创建
    800069a2:	4481                	li	s1,0
    }
  }
  release(&shmt.lock);
    800069a4:	00245517          	auipc	a0,0x245
    800069a8:	25c50513          	addi	a0,a0,604 # 8024bc00 <shmt>
    800069ac:	b8cfa0ef          	jal	ra,80000d38 <release>
  //shm_dump(key);
  return del;

}
    800069b0:	8526                	mv	a0,s1
    800069b2:	60e2                	ld	ra,24(sp)
    800069b4:	6442                	ld	s0,16(sp)
    800069b6:	64a2                	ld	s1,8(sp)
    800069b8:	6105                	addi	sp,sp,32
    800069ba:	8082                	ret

00000000800069bc <sem_lookup>:
}

// 找到 key 对应 sem；不存在返回 -1
static int
sem_lookup(int key)
{
    800069bc:	1141                	addi	sp,sp,-16
    800069be:	e422                	sd	s0,8(sp)
    800069c0:	0800                	addi	s0,sp,16
    800069c2:	862a                	mv	a2,a0
  for(int i = 0; i < NSEM; i++){
    800069c4:	0024d797          	auipc	a5,0x24d
    800069c8:	3ec78793          	addi	a5,a5,1004 # 80253db0 <semt+0x18>
    800069cc:	4501                	li	a0,0
    800069ce:	04000693          	li	a3,64
    800069d2:	a029                	j	800069dc <sem_lookup+0x20>
    800069d4:	2505                	addiw	a0,a0,1
    800069d6:	07c1                	addi	a5,a5,16
    800069d8:	00d50a63          	beq	a0,a3,800069ec <sem_lookup+0x30>
    if(semt.s[i].used && semt.s[i].key == key)
    800069dc:	4398                	lw	a4,0(a5)
    800069de:	db7d                	beqz	a4,800069d4 <sem_lookup+0x18>
    800069e0:	43d8                	lw	a4,4(a5)
    800069e2:	fec719e3          	bne	a4,a2,800069d4 <sem_lookup+0x18>
      return i;
  }
  return -1;
}
    800069e6:	6422                	ld	s0,8(sp)
    800069e8:	0141                	addi	sp,sp,16
    800069ea:	8082                	ret
  return -1;
    800069ec:	557d                	li	a0,-1
    800069ee:	bfe5                	j	800069e6 <sem_lookup+0x2a>

00000000800069f0 <seminit>:
{
    800069f0:	1141                	addi	sp,sp,-16
    800069f2:	e406                	sd	ra,8(sp)
    800069f4:	e022                	sd	s0,0(sp)
    800069f6:	0800                	addi	s0,sp,16
  initlock(&semt.lock, "semt");
    800069f8:	00002597          	auipc	a1,0x2
    800069fc:	e8058593          	addi	a1,a1,-384 # 80008878 <syscalls+0x480>
    80006a00:	0024d517          	auipc	a0,0x24d
    80006a04:	39850513          	addi	a0,a0,920 # 80253d98 <semt>
    80006a08:	a18fa0ef          	jal	ra,80000c20 <initlock>
}
    80006a0c:	60a2                	ld	ra,8(sp)
    80006a0e:	6402                	ld	s0,0(sp)
    80006a10:	0141                	addi	sp,sp,16
    80006a12:	8082                	ret

0000000080006a14 <sem_open>:

// 创建或返回已有
int
sem_open(int key, int init)
{
    80006a14:	7179                	addi	sp,sp,-48
    80006a16:	f406                	sd	ra,40(sp)
    80006a18:	f022                	sd	s0,32(sp)
    80006a1a:	ec26                	sd	s1,24(sp)
    80006a1c:	e84a                	sd	s2,16(sp)
    80006a1e:	e44e                	sd	s3,8(sp)
    80006a20:	1800                	addi	s0,sp,48
    80006a22:	892a                	mv	s2,a0
    80006a24:	89ae                	mv	s3,a1
  acquire(&semt.lock);
    80006a26:	0024d517          	auipc	a0,0x24d
    80006a2a:	37250513          	addi	a0,a0,882 # 80253d98 <semt>
    80006a2e:	a72fa0ef          	jal	ra,80000ca0 <acquire>

  int idx = sem_lookup(key);
    80006a32:	854a                	mv	a0,s2
    80006a34:	f89ff0ef          	jal	ra,800069bc <sem_lookup>
  if(idx >= 0){
    80006a38:	0024d717          	auipc	a4,0x24d
    80006a3c:	37870713          	addi	a4,a4,888 # 80253db0 <semt+0x18>
    release(&semt.lock);
    return 0;  // 已存在，直接成功
  }

  for(int i = 0; i < NSEM; i++){
    80006a40:	4781                	li	a5,0
    80006a42:	04000693          	li	a3,64
  if(idx >= 0){
    80006a46:	02055063          	bgez	a0,80006a66 <sem_open+0x52>
    if(!semt.s[i].used){
    80006a4a:	4304                	lw	s1,0(a4)
    80006a4c:	c48d                	beqz	s1,80006a76 <sem_open+0x62>
  for(int i = 0; i < NSEM; i++){
    80006a4e:	2785                	addiw	a5,a5,1
    80006a50:	0741                	addi	a4,a4,16
    80006a52:	fed79ce3          	bne	a5,a3,80006a4a <sem_open+0x36>
      release(&semt.lock);
      return 0;
    }
  }

  release(&semt.lock);
    80006a56:	0024d517          	auipc	a0,0x24d
    80006a5a:	34250513          	addi	a0,a0,834 # 80253d98 <semt>
    80006a5e:	adafa0ef          	jal	ra,80000d38 <release>
  return -1;
    80006a62:	54fd                	li	s1,-1
    80006a64:	a815                	j	80006a98 <sem_open+0x84>
    release(&semt.lock);
    80006a66:	0024d517          	auipc	a0,0x24d
    80006a6a:	33250513          	addi	a0,a0,818 # 80253d98 <semt>
    80006a6e:	acafa0ef          	jal	ra,80000d38 <release>
    return 0;  // 已存在，直接成功
    80006a72:	4481                	li	s1,0
    80006a74:	a015                	j	80006a98 <sem_open+0x84>
      semt.s[i].used = 1;
    80006a76:	0024d517          	auipc	a0,0x24d
    80006a7a:	32250513          	addi	a0,a0,802 # 80253d98 <semt>
    80006a7e:	0785                	addi	a5,a5,1
    80006a80:	0792                	slli	a5,a5,0x4
    80006a82:	97aa                	add	a5,a5,a0
    80006a84:	4705                	li	a4,1
    80006a86:	c798                	sw	a4,8(a5)
      semt.s[i].key = key;
    80006a88:	0127a623          	sw	s2,12(a5)
      semt.s[i].val = init;
    80006a8c:	0137a823          	sw	s3,16(a5)
      semt.s[i].waiters = 0;
    80006a90:	0007aa23          	sw	zero,20(a5)
      release(&semt.lock);
    80006a94:	aa4fa0ef          	jal	ra,80000d38 <release>
}
    80006a98:	8526                	mv	a0,s1
    80006a9a:	70a2                	ld	ra,40(sp)
    80006a9c:	7402                	ld	s0,32(sp)
    80006a9e:	64e2                	ld	s1,24(sp)
    80006aa0:	6942                	ld	s2,16(sp)
    80006aa2:	69a2                	ld	s3,8(sp)
    80006aa4:	6145                	addi	sp,sp,48
    80006aa6:	8082                	ret

0000000080006aa8 <sem_wait>:

int
sem_wait(int key)
{
    80006aa8:	7179                	addi	sp,sp,-48
    80006aaa:	f406                	sd	ra,40(sp)
    80006aac:	f022                	sd	s0,32(sp)
    80006aae:	ec26                	sd	s1,24(sp)
    80006ab0:	e84a                	sd	s2,16(sp)
    80006ab2:	e44e                	sd	s3,8(sp)
    80006ab4:	e052                	sd	s4,0(sp)
    80006ab6:	1800                	addi	s0,sp,48
    80006ab8:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006aba:	0024d517          	auipc	a0,0x24d
    80006abe:	2de50513          	addi	a0,a0,734 # 80253d98 <semt>
    80006ac2:	9defa0ef          	jal	ra,80000ca0 <acquire>

  int idx = sem_lookup(key);
    80006ac6:	8526                	mv	a0,s1
    80006ac8:	ef5ff0ef          	jal	ra,800069bc <sem_lookup>
  if(idx < 0){
    80006acc:	06054d63          	bltz	a0,80006b46 <sem_wait+0x9e>
    80006ad0:	892a                	mv	s2,a0
    release(&semt.lock);
    return -1;
  }

  // while(val==0) sleep
  while(semt.s[idx].val == 0){
    80006ad2:	00150713          	addi	a4,a0,1
    80006ad6:	0712                	slli	a4,a4,0x4
    80006ad8:	0024d797          	auipc	a5,0x24d
    80006adc:	2c078793          	addi	a5,a5,704 # 80253d98 <semt>
    80006ae0:	97ba                	add	a5,a5,a4
    80006ae2:	4b9c                	lw	a5,16(a5)
    80006ae4:	ef85                	bnez	a5,80006b1c <sem_wait+0x74>
    semt.s[idx].waiters++;
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006ae6:	00451993          	slli	s3,a0,0x4
    80006aea:	0024d797          	auipc	a5,0x24d
    80006aee:	2c678793          	addi	a5,a5,710 # 80253db0 <semt+0x18>
    80006af2:	99be                	add	s3,s3,a5
    semt.s[idx].waiters++;
    80006af4:	0024da17          	auipc	s4,0x24d
    80006af8:	2a4a0a13          	addi	s4,s4,676 # 80253d98 <semt>
    80006afc:	00150493          	addi	s1,a0,1
    80006b00:	0492                	slli	s1,s1,0x4
    80006b02:	94d2                	add	s1,s1,s4
    80006b04:	48dc                	lw	a5,20(s1)
    80006b06:	2785                	addiw	a5,a5,1
    80006b08:	c8dc                	sw	a5,20(s1)
    sleep(&semt.s[idx], &semt.lock);   // 释放锁并睡，醒来后会重新拿到锁
    80006b0a:	85d2                	mv	a1,s4
    80006b0c:	854e                	mv	a0,s3
    80006b0e:	933fb0ef          	jal	ra,80002440 <sleep>
    semt.s[idx].waiters--;
    80006b12:	48dc                	lw	a5,20(s1)
    80006b14:	37fd                	addiw	a5,a5,-1
    80006b16:	c8dc                	sw	a5,20(s1)
  while(semt.s[idx].val == 0){
    80006b18:	489c                	lw	a5,16(s1)
    80006b1a:	d7ed                	beqz	a5,80006b04 <sem_wait+0x5c>
  }

  semt.s[idx].val--;
    80006b1c:	0024d517          	auipc	a0,0x24d
    80006b20:	27c50513          	addi	a0,a0,636 # 80253d98 <semt>
    80006b24:	0905                	addi	s2,s2,1
    80006b26:	0912                	slli	s2,s2,0x4
    80006b28:	992a                	add	s2,s2,a0
    80006b2a:	37fd                	addiw	a5,a5,-1
    80006b2c:	00f92823          	sw	a5,16(s2)
  release(&semt.lock);
    80006b30:	a08fa0ef          	jal	ra,80000d38 <release>
  return 0;
    80006b34:	4501                	li	a0,0
}
    80006b36:	70a2                	ld	ra,40(sp)
    80006b38:	7402                	ld	s0,32(sp)
    80006b3a:	64e2                	ld	s1,24(sp)
    80006b3c:	6942                	ld	s2,16(sp)
    80006b3e:	69a2                	ld	s3,8(sp)
    80006b40:	6a02                	ld	s4,0(sp)
    80006b42:	6145                	addi	sp,sp,48
    80006b44:	8082                	ret
    release(&semt.lock);
    80006b46:	0024d517          	auipc	a0,0x24d
    80006b4a:	25250513          	addi	a0,a0,594 # 80253d98 <semt>
    80006b4e:	9eafa0ef          	jal	ra,80000d38 <release>
    return -1;
    80006b52:	557d                	li	a0,-1
    80006b54:	b7cd                	j	80006b36 <sem_wait+0x8e>

0000000080006b56 <sem_post>:

int
sem_post(int key)
{
    80006b56:	1101                	addi	sp,sp,-32
    80006b58:	ec06                	sd	ra,24(sp)
    80006b5a:	e822                	sd	s0,16(sp)
    80006b5c:	e426                	sd	s1,8(sp)
    80006b5e:	1000                	addi	s0,sp,32
    80006b60:	84aa                	mv	s1,a0
  acquire(&semt.lock);
    80006b62:	0024d517          	auipc	a0,0x24d
    80006b66:	23650513          	addi	a0,a0,566 # 80253d98 <semt>
    80006b6a:	936fa0ef          	jal	ra,80000ca0 <acquire>

  int idx = sem_lookup(key);
    80006b6e:	8526                	mv	a0,s1
    80006b70:	e4dff0ef          	jal	ra,800069bc <sem_lookup>
  if(idx < 0){
    80006b74:	02054a63          	bltz	a0,80006ba8 <sem_post+0x52>
    release(&semt.lock);
    return -1;
  }

  semt.s[idx].val++;
    80006b78:	0024d497          	auipc	s1,0x24d
    80006b7c:	22048493          	addi	s1,s1,544 # 80253d98 <semt>
    80006b80:	0505                	addi	a0,a0,1
    80006b82:	0512                	slli	a0,a0,0x4
    80006b84:	00a48733          	add	a4,s1,a0
    80006b88:	4b1c                	lw	a5,16(a4)
    80006b8a:	2785                	addiw	a5,a5,1
    80006b8c:	cb1c                	sw	a5,16(a4)

  // 唤醒一个或全部：先做全部更简单也正确
  wakeup(&semt.s[idx]);
    80006b8e:	0521                	addi	a0,a0,8
    80006b90:	9526                	add	a0,a0,s1
    80006b92:	8fbfb0ef          	jal	ra,8000248c <wakeup>

  release(&semt.lock);
    80006b96:	8526                	mv	a0,s1
    80006b98:	9a0fa0ef          	jal	ra,80000d38 <release>
  return 0;
    80006b9c:	4501                	li	a0,0
}
    80006b9e:	60e2                	ld	ra,24(sp)
    80006ba0:	6442                	ld	s0,16(sp)
    80006ba2:	64a2                	ld	s1,8(sp)
    80006ba4:	6105                	addi	sp,sp,32
    80006ba6:	8082                	ret
    release(&semt.lock);
    80006ba8:	0024d517          	auipc	a0,0x24d
    80006bac:	1f050513          	addi	a0,a0,496 # 80253d98 <semt>
    80006bb0:	988fa0ef          	jal	ra,80000d38 <release>
    return -1;
    80006bb4:	557d                	li	a0,-1
    80006bb6:	b7e5                	j	80006b9e <sem_post+0x48>

0000000080006bb8 <sys_sem_open>:
#include "defs.h"


uint64
sys_sem_open(void)
{
    80006bb8:	1101                	addi	sp,sp,-32
    80006bba:	ec06                	sd	ra,24(sp)
    80006bbc:	e822                	sd	s0,16(sp)
    80006bbe:	1000                	addi	s0,sp,32
  int key, init;
  argint(0, &key);
    80006bc0:	fec40593          	addi	a1,s0,-20
    80006bc4:	4501                	li	a0,0
    80006bc6:	9b2fc0ef          	jal	ra,80002d78 <argint>
  argint(1, &init);
    80006bca:	fe840593          	addi	a1,s0,-24
    80006bce:	4505                	li	a0,1
    80006bd0:	9a8fc0ef          	jal	ra,80002d78 <argint>
  return sem_open(key, init);
    80006bd4:	fe842583          	lw	a1,-24(s0)
    80006bd8:	fec42503          	lw	a0,-20(s0)
    80006bdc:	e39ff0ef          	jal	ra,80006a14 <sem_open>
}
    80006be0:	60e2                	ld	ra,24(sp)
    80006be2:	6442                	ld	s0,16(sp)
    80006be4:	6105                	addi	sp,sp,32
    80006be6:	8082                	ret

0000000080006be8 <sys_sem_wait>:

uint64
sys_sem_wait(void)
{
    80006be8:	1101                	addi	sp,sp,-32
    80006bea:	ec06                	sd	ra,24(sp)
    80006bec:	e822                	sd	s0,16(sp)
    80006bee:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006bf0:	fec40593          	addi	a1,s0,-20
    80006bf4:	4501                	li	a0,0
    80006bf6:	982fc0ef          	jal	ra,80002d78 <argint>
  return sem_wait(key);
    80006bfa:	fec42503          	lw	a0,-20(s0)
    80006bfe:	eabff0ef          	jal	ra,80006aa8 <sem_wait>
}
    80006c02:	60e2                	ld	ra,24(sp)
    80006c04:	6442                	ld	s0,16(sp)
    80006c06:	6105                	addi	sp,sp,32
    80006c08:	8082                	ret

0000000080006c0a <sys_sem_post>:

uint64
sys_sem_post(void)
{
    80006c0a:	1101                	addi	sp,sp,-32
    80006c0c:	ec06                	sd	ra,24(sp)
    80006c0e:	e822                	sd	s0,16(sp)
    80006c10:	1000                	addi	s0,sp,32
  int key;
  argint(0, &key);
    80006c12:	fec40593          	addi	a1,s0,-20
    80006c16:	4501                	li	a0,0
    80006c18:	960fc0ef          	jal	ra,80002d78 <argint>
  return sem_post(key);
    80006c1c:	fec42503          	lw	a0,-20(s0)
    80006c20:	f37ff0ef          	jal	ra,80006b56 <sem_post>
}
    80006c24:	60e2                	ld	ra,24(sp)
    80006c26:	6442                	ld	s0,16(sp)
    80006c28:	6105                	addi	sp,sp,32
    80006c2a:	8082                	ret
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
